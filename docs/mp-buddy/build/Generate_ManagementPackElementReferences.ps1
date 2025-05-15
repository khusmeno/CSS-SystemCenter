<#
This generates the content of mp-buddy\src\assets\MpElementReferences.xml
It does not need to be run anymore, unless MP schema changes in the future. (which is not expected to happen)
#>

Set-Location $PSScriptRoot
#even though we ask to load the (CLR v4.0) core dll from the same folder, it can be loaded from GAC, where it can be a newer version (CLR v4.5) which has references to EWS and Identity.Client.
[reflection.assembly]::loadfrom((Get-ChildItem -Path "Microsoft.Exchange.WebServices.dll").FullName) | Out-Null
[reflection.assembly]::loadfrom((Get-ChildItem -Path "Microsoft.Identity.Client.dll").FullName)  | Out-Null
$core = [reflection.assembly]::loadfile((Get-ChildItem -Path "Microsoft.EnterpriseManagement.Core.dll").FullName) 

#by default the XmlTag is the same as the type name without the "ManagementPack" prefix, but for same types it's different. This hashtable contains these exceptions.
$xmlTagMappings = @{}
$xmlTagMappings.Add("Class","ClassType")
$xmlTagMappings.Add("Relationship","RelationshipType")
$xmlTagMappings.Add("Enumeration","EnumerationValue")
$xmlTagMappings.Add("AssemblyResource","Assembly")

$types = $core.GetTypes()
foreach($type in $types) {
    if ($type.FullName.StartsWith("Microsoft.EnterpriseManagement.Configuration.ManagementPack")) {
        foreach($prop in $type.GetProperties()) {
            if ($type.Name -like "*Class*") {
                $x=0
            }

            if ($prop.PropertyType.Name -eq 'ManagementPackElementReference`1' -and $type -eq $prop.DeclaringType) #                -and $prop.CustomAttributes.AttributeType -eq [Microsoft.EnterpriseManagement.Configuration.CriteriaPropertyMappingAttribute] `#                -and $prop.CustomAttributes.ConstructorArguments.Value -eq $prop.Name)
               
            {
                $SourceType = $type.Name
                $SourceProperty = $prop.Name
                $TargetType = $prop.PropertyType.GenericTypeArguments[0].Name
                   
                $SourceTypeXmlTag = $SourceType.Replace("ManagementPack","")
                $TargetTypeXmlTag = $TargetType.Replace("ManagementPack","")
                    
                if ($xmlTagMappings[$SourceTypeXmlTag]) {
                    $SourceTypeXmlTag = $xmlTagMappings[$SourceTypeXmlTag]
                }
                if ($xmlTagMappings[$TargetTypeXmlTag]) {
                    $TargetTypeXmlTag = $xmlTagMappings[$TargetTypeXmlTag]
                }
                "<MpElementReference SourceType=`"$SourceTypeXmlTag`" SourceProperty=`"$SourceProperty`" TargetType=`"$TargetTypeXmlTag`" />"
            }
        }
    }
}

