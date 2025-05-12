# Eventually, this will "process" everything available in "staging" to "src/MP_data", delete from staging (optionally), and then "builds" everything in src/MP_data

$deleteStaging = $false # make $true in PROD

##########################
Set-Location -Path $PSScriptRoot 
$tempFolder =    "..\temp"
$stagingFolder = "..\staging"
$dataFolder = "..\src\MP_data"

function Invoke-GenericMethod { 
    param ( 
        $object,  
        [string]$methodName,  
        [type[]]$typeArguments,  
        [object[]]$parameters = $null  
    ) 
    [System.Reflection.MethodInfo]$method = $object.GetType().GetMethod($methodName) 
    [System.Reflection.MethodInfo]$genericMethod = $method.MakeGenericMethod($typeArguments) 
    $genericMethod.Invoke($object, $parameters)
}
function Test-IsBrowserRenderableFile {
    param (
        $fileExt,
        $fileStream,
        [int]$SampleSize = 512 # 4096
    )

    # File extensions typically viewable in modern browsers
    $browserRenderableExtensions = @(
        '.html', '.htm', '.css', '.js', '.json', '.xml', '.config',
        '.txt', '.vbs', '.ps1', '.sql', '.py', '.csv', '.md', '.rdl', '.rpdl',
        '.jpg', '.jpeg', '.png', '.gif', '.bmp', '.webp', '.svg'
    )   
    if ($browserRenderableExtensions -contains $fileExt.ToLower()) {
        return $true
    }

    # Fallback: check for mostly printable content (e.g., .log or unknown extension)
    try {
        $bytes = New-Object byte[] $SampleSize
        $read = $fileStream.Read($bytes, 0, $SampleSize)
    } catch {
        Write-Error "Error reading file stream: $_"
        return $false
    }
    if ($read -eq 0) {
        return $false
    }
    $printableCount = ($bytes | Where-Object {
        ($_ -ge 32 -and $_ -le 126) -or ($_ -in 9, 10, 13)
    }).Count
    $ratio = $printableCount / $read
    return $ratio -gt 0.9
}
function ProcessMpResource($resource, $resourceStream , $mpID, $mpVersion) {
    $newMpResourceFullPath = [System.IO.Path]::Combine( (Resolve-Path -Path $dataFolder) , $mpID, $mpVersion, $resource.FileName)
    $fs = [System.IO.File]::Create($newMpResourceFullPath)                       
    $resourceStream.CopyTo($fs);
    $fs.Flush();
    $fs.Close();
    if ($resource.FileName.ToLower().EndsWith(".sh")) {
        #crop everything after this line bcz it's binary and huge   #####>>- This must be the last line of this script, followed by a single empty line. -<<#####
        $rawContent =  Get-Content -Path $newMpResourceFullPath -Raw
        $newContent = $rawContent.Substring(0,  $rawContent.IndexOf('#####>>- This must be the last line of this script, followed by a single empty line. -<<#####') )
        New-Item -Path $newMpResourceFullPath -Value $newContent -ItemType File -Force | Out-Null
    }
}
function ProcessUnsealedMpXml([string]$MpXmlFullPath, [bool]$IsExtractedFromSealedMP) {
    [xml]$xmlDoc = [xml]::new()    
    $xmlDoc.Load($MpXmlFullPath)

    if ( $IsExtractedFromSealedMP -eq $false -and $xmlDoc.DocumentElement.SelectSingleNode('/ManagementPack/Resources/Resource') ) {
        Write-Warning "Unsealed MP '$MpXmlFullPath' contains a <Resource> element. Still processing it but better to provide the MPB instead."
    }
    
    $mpIdentity = $xmlDoc.DocumentElement.SelectSingleNode('/ManagementPack/Manifest/Identity')
    $mpID = $mpIdentity.SelectSingleNode('ID').InnerText
    $mpVersion = $mpIdentity.SelectSingleNode('Version').InnerText

    New-Item -Path $dataFolder -Name $mpID -ItemType Directory -ErrorAction SilentlyContinue | Out-Null
    New-Item -Path $dataFolder -Name "$mpID\$mpVersion" -ItemType Directory -ErrorAction SilentlyContinue | Out-Null
    $xmlDoc = $null

    $newMPFullPath = [System.IO.Path]::Combine( (Resolve-Path -Path $dataFolder) , $mpID, $mpVersion, "MP.xml")
    Copy-Item -Path $MpXmlFullPath -Destination $newMPFullPath -Force
}
function ProcessSealedMP([string]$MPFullPath) {
    $mp = [Microsoft.EnterpriseManagement.Configuration.ManagementPack]::new($MPFullPath)    $writer = [Microsoft.EnterpriseManagement.Configuration.IO.ManagementPackXmlWriter]::new( [System.IO.FileInfo]::new($MPFullPath).DirectoryName )
    $newMpXmlFileFullPath = $writer.WriteManagementPack($mp)
    ProcessUnsealedMpXml -MpXmlFullPath $newMpXmlFileFullPath -IsExtractedFromSealedMP $true
}
function ProcessMPB([string]$mpbFullPath) {
    $mpfs = [Microsoft.EnterpriseManagement.Configuration.IO.ManagementPackFileStore]::new( [System.IO.FileInfo]::new($MPBFullPath).DirectoryName )    $mpbReader = [Microsoft.EnterpriseManagement.Packaging.ManagementPackBundleFactory]::CreateBundleReader()    $mpb = $mpbReader.Read($mpbFullPath, $mpfs)    foreach($mp in $mpb.ManagementPacks) {        #save MP as XML        $writer = [Microsoft.EnterpriseManagement.Configuration.IO.ManagementPackXmlWriter]::new( [System.IO.FileInfo]::new($mpbFullPath).DirectoryName )
        $newMpXmlFileFullPath = $writer.WriteManagementPack($mp)        ProcessUnsealedMpXml -MpXmlFullPath $newMpXmlFileFullPath -IsExtractedFromSealedMP $true        #save resources in MPB that are declared in each MP/XML        $streams = $mpb.GetStreams($mp)        $resources = Invoke-GenericMethod $mp "GetResources" ([Microsoft.EnterpriseManagement.Configuration.ManagementPackResource])  #  PS equivalent of C#:  var resources = mp.GetResources<ManagementPackResource>();        foreach ($resource in $resources) {            if ($streams.Keys.Contains($resource.Name)) {            
                if (-not (Test-IsBrowserRenderableFile -fileExt ([System.IO.Path]::GetExtension($resource.FileName)) -fileStream ($streams[$resource.Name]) )) {  # save only if "printable in a web page"
                    continue
                }
                $streams[$resource.Name].Seek(0, [System.IO.SeekOrigin]::Begin) | Out-Null #rewind to beginning
                ProcessMpResource -resource $resource -resourceStream $streams[$resource.Name] -mpID $mp.Name -mpVersion $mp.Version.ToString()
            }            else {                Write-Warning "Resource '$($resource.Name)' not found inside '$([System.IO.FileInfo]::new($mpbFullPath).Name)' for MP '$($mp.Name)'"            }        }    }
}

#create MP folders
[reflection.assembly]::loadfrom((Get-ChildItem -Path "Microsoft.EnterpriseManagement.Packaging.dll").FullName)[reflection.assembly]::loadfrom((Get-ChildItem -Path "Microsoft.EnterpriseManagement.Core.dll").FullName)$filesInStagingToProcess = Get-ChildItem -Path "$stagingFolder" -Recurse -Include *.xml,*.mp,*.mpb
foreach($fileInStagingToProcess in $filesInStagingToProcess) {
    Write-Host $fileInStagingToProcess.FullName
    $fileExt = [System.IO.Path]::GetExtension($fileInStagingToProcess.FullName).ToLower()

    if ($fileExt -eq ".xml") {
        ProcessUnsealedMpXml -MpXmlFullPath $fileInStagingToProcess.FullName -IsExtractedFromSealedMP $false
    }
    elseif ($fileExt -eq ".mp") {
        ProcessSealedMP -MPFullPath $fileInStagingToProcess.FullName
    }
    elseif ($fileExt -eq ".mpb") {        
        ProcessMPB -mpbFullPath $fileInStagingToProcess.FullName
    }
}

#build
$mpList = @{}
$mpFolders = Get-ChildItem -Path $dataFolder -Directory
foreach($mpFolder in $mpFolders) {
    Write-Host $mpFolder.Name
    $mpInfo = @{}

    Get-Item -Path ([System.IO.Path]::Combine($dataFolder, $mpFolder, "List_MPVersion.xml")) -ErrorAction SilentlyContinue | Remove-Item -Force
    $mpVersionFolders = Get-ChildItem $mpFolder.FullName
    $mpVersions = @()
    $list_MPVersion = @()
    foreach($mpVersionFolder in $mpVersionFolders) {
        if (Test-Path -Path ([System.IO.Path]::Combine($dataFolder, $mpFolder, $mpVersionFolder, "MP.xml")) ) {
            $mpVersions += [version]::new($mpVersionFolder.Name)
        }
    }
    if ($mpVersions.Count -gt 0) {

        $list_MPVersion_Content = "<List>`n"
        $sortedMpVersions = $mpVersions | Sort-Object
        foreach($sortedMpVersion in $sortedMpVersions) {
            $list_MPVersion_Content += "`n<MPVersion Version='$($sortedMpVersion.ToString())' />"
        }
        $list_MPVersion_Content += "`n</List>"
        $list_MPVersion_Content | Out-File -FilePath ([System.IO.Path]::Combine($dataFolder, $mpFolder, "List_MPVersion.xml")) -Encoding unicode -Force

        $maxMpVersion = $mpVersions | Sort-Object -Descending | Select-Object -First 1
        $mpInfo.Add("LatestVersion", $maxMpVersion.ToString())

        [xml]$xmlDoc = [xml]::new()
        $mpPath = Resolve-Path -Path ([System.IO.Path]::Combine( $dataFolder , $mpFolder.Name, $maxMpVersion.ToString(), "MP.xml"))
        $xmlDoc.Load($mpPath)
        $mpDisplayName = ""
        $mpDescription = ""
        $mpDisplayStringNode = $xmlDoc.DocumentElement.SelectSingleNode("/ManagementPack/LanguagePacks/LanguagePack[@ID='ENU']/DisplayStrings/DisplayString[@ElementID='$($mpFolder.Name)']")
        if ($mpDisplayStringNode) {
            $mpDisplayName = $mpDisplayStringNode.Name
            $mpDescription = $mpDisplayStringNode.Description
        }
        if ($mpDisplayName -eq "") {
            $mpFriendlyNameNode = $xmlDoc.DocumentElement.SelectSingleNode('/ManagementPack/Manifest/Name')
            if ($mpFriendlyNameNode) {
                $mpDisplayName = $mpFriendlyNameNode.InnerText
            }
        }
        $mpInfo.Add("Name", $mpDisplayName )
        $mpInfo.Add("Description", $mpDescription )

        $mpList.Add($mpFolder.Name, $mpInfo)
    }
}
$sortedMPs = $mpList.GetEnumerator() | Sort-Object Key
$List_MP_Content = "<List>`n"
foreach($mp in $sortedMPs) {
    $List_MP_Content += "`n<ManagementPack ID='$($mp.Key.ToString())' LatestVersion='$($mp.Value['LatestVersion'])' Name='$($mp.Value['Name'])' Description='$($mp.Value['Description'])' />"
}
$List_MP_Content += "`n</List>"
$List_MP_Content | Out-File -FilePath ([System.IO.Path]::Combine($dataFolder, "List_MP.xml")) -Force -Encoding unicode

if ($deleteStaging) {
    Get-ChildItem -Path $stagingFolder\* -Include *.xml,*.mp,*.mpb -Recurse | Remove-Item -Force
}