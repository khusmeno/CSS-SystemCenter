$sqlInstance = 'sql2017'
$sqlDatabase = 'OperationsManager'

##########################
Set-Location -Path $PSScriptRoot 
$targetFolder = "..\staging"
$result = Invoke-Sqlcmd -ServerInstance $sqlInstance -Database $sqlDatabase -Query "select MPName, mpxml, MPVersion from managementpack where MPKeyToken='31bf3856ad364e35'"  -MaxCharLength 100MB
foreach($mpxml in $result) {
    $outputFilePath = [System.IO.Path]::Combine($targetFolder, $mpxml["MPName"] + "." + $mpxml["MPVersion"] + ".xml")
    $mpxml["mpxml"] | Out-File -FilePath $outputFilePath -Encoding UTF8 -Force
    Write-Host "saving from sql to: $outputFilePath"
}


