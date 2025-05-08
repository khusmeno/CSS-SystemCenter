# Eventually, this will "process" everything available in "staging" to "src/MP_data", delete from staging (optionally), and then "builds" everything in src/MP_data

$deleteStaging = $false

##########################
Set-Location -Path $PSScriptRoot 
$stagingFolder = "..\staging"
$dataFolder = "..\src\MP_data"

# todo extract unsealed MP.xmls from mp and mpb files in staging into staging .......................
# 1. MPB


# 2. MP


# now start reading from staging and writing to data
$MpXMLsInStaging = Get-ChildItem -Path "$stagingFolder\*.xml" -Recurse
foreach($MpXMLInStaging in $MpXMLsInStaging) {
    [xml]$xmlDoc = [xml]::new()    
    $xmlDoc.Load($MpXMLInStaging.FullName)

    $mpIdentity = $xmlDoc.DocumentElement.SelectSingleNode('/ManagementPack/Manifest/Identity')
    $mpID = $mpIdentity.SelectSingleNode('ID').InnerText
    $mpVersion = $mpIdentity.SelectSingleNode('Version').InnerText

    Write-Host "$mpID $mpVersion"
    New-Item -Path $dataFolder -Name $mpID -ItemType Directory -ErrorAction SilentlyContinue | Out-Null
    New-Item -Path $dataFolder -Name "$mpID\$mpVersion" -ItemType Directory -ErrorAction SilentlyContinue | Out-Null
    $xmlDoc = $null

    $newMPFullPath = [System.IO.Path]::Combine( (Resolve-Path -Path $dataFolder) , $mpID, $mpVersion, "MP.xml")
    Copy-Item -Path $MpXMLInStaging.FullName -Destination $newMPFullPath -Force
}

###3
$mpList = @{}

$List_MP = "List_MP.xml"
Get-Item -Path "$dataFolder\$List_MP"  -ErrorAction SilentlyContinue | Remove-Item -Force
$mpFolders = Get-ChildItem -Path $dataFolder
foreach($mpFolder in $mpFolders) {
    $mpInfo = @{}

    Get-Item -Path ([System.IO.Path]::Combine($dataFolder, $mpFolder, "List_MPVersion.xml")) -ErrorAction SilentlyContinue | Remove-Item -Force
    $mpVersionFolders = Get-ChildItem $mpFolder.FullName
    $mpVersions = @()
    $list_MPVersion = @()
    foreach($mpVersionFolder in $mpVersionFolders) {
    # todo: delete the mpversionFolder if does not have mp.xml inside or if mp.xml is not a valid mp?????
        $mpVersions += [version]::new($mpVersionFolder.Name)
    }
    if ($mpVersions.Count -gt 0) {

        $list_MPVersion_Content = "<List>`n"
        $sortedMpVersions = $mpVersions | Sort-Object
        foreach($sortedMpVersion in $sortedMpVersions) {
            $list_MPVersion_Content += "`n<MPVersion Version='$($sortedMpVersion.ToString())' />"
        }
        $list_MPVersion_Content += "`n</List>"
        $list_MPVersion_Content | Out-File -FilePath ([System.IO.Path]::Combine($dataFolder, $mpFolder, "List_MPVersion.xml")) -Encoding UTF8 -Force
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
$List_MP_Content | Out-File -FilePath ([System.IO.Path]::Combine($dataFolder, $List_MP)) -Encoding UTF8


if ($deleteStaging) {
    Get-ChildItem -Path $stagingFolder\* -Include *.xml,*.mp,*.mpb -Recurse | Remove-Item -Force
}