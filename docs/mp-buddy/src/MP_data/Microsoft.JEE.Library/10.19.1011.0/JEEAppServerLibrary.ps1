##########################################################################################
# <copyright file="JEEAppServerLibrary.ps1" company="Microsoft">
#     Copyright (c) Microsoft Corporation.  All rights reserved.
# </copyright>
# <summary>Library functions to access a JEE application server and validate
#          the ServerName, Port and protocol. </summary>
##########################################################################################

Set-PSDebug -Strict

##########################################################################################
#
# Load one assembly
# Parameter assemblyname - Name of assembly to load
# Returns                - An Assembly object
#
##########################################################################################
function GetAssembly($assemblyname)
{
	return [System.Reflection.Assembly]::LoadWithPartialName($assemblyname)
}

##########################################################################################
#
# Load one assembly and log if fail
# Parameter assemblyname - Name of assembly to load
# Returns                - An Assembly object
#
##########################################################################################
function Load-Assembly($assemblyname,$verbose)
{
	$assembly = GetAssembly $assemblyname
	if (!$assembly)
	{ 
        if($verbose)
        {
	        Write-host -foregroundcolor Red "Failed to load assembly $assemblyname" 
        }
	}
    return $assembly
}

##########################################################################################
#
# Load the assemblies needed
# Returns                - An Assembly object
#
##########################################################################################
function Load-Assemblies()
{
	$result = Load-Assembly "Microsoft.EnterpriseManagement.OperationsManager" $true
    if($result -ne $null)
    {
       $result = Load-Assembly "Microsoft.EnterpriseManagement.OperationsManager.Common" $true
    }

    return $result
}

##########################################################################################
#
# Get the JEE connector for the management group or create one if one does not exist
# Parameter managementGroup - The management group reference object
# Returns                   - A JEE connector
#
##########################################################################################
function GetJEEConnector($managementGroup)
{
	$mcfAdmin = $managementGroup.GetConnectorFrameworkAdministration()
	$JEEConnector = new-object Guid("0607F2C4-A652-4ece-87BB-795ACA31E458")

	try 
	{
	    $monitoringConnector = $mcfAdmin.GetMonitoringConnector($JEEConnector)
	} 
	catch 
	{
		$connectorInfo = new-object Microsoft.EnterpriseManagement.ConnectorFramework.ConnectorInfo

		$connectorInfo.DiscoveryDataIsManaged = $true
		$connectorInfo.Description = "This is a JEE Connector used for JEE App Server Discovery."
		$connectorInfo.DisplayName = "JEE Connector"
		$connectorInfo.Name = "JEE Connector"
		    
		$monitoringConnector =  $mcfAdmin.Setup($connectorInfo, $JEEConnector)
		$monitoringConnector.Initialize()
	}

	return $monitoringConnector
}

##########################################################################################
#
# Release the reference to the JEE connector 
# Parameter managementGroup - The management group reference object
#
##########################################################################################
function CleanupJEEConnector($managementGroup)
{
	$mcfAdmin = $managementGroup.GetConnectorFrameworkAdministration()
	$JEEConnector = new-object Guid("0607F2C4-A652-4ece-87BB-795ACA31E458")

	try
	{
	    $monitoringConnector = $mcfAdmin.GetMonitoringConnector($JEEConnector)
		$monitoringConnector.Uninitialize()
		$mcfAdmin.Cleanup($monitoringConnector)
	}
	catch 
	{
        Write-Host "Unable to Un-Initialize and cleanup the MonitoringConnector"
	}
}

##########################################################################################
#
# Get the monitoring class object.
# Parameter managementGroup  - ManagementGroup object
# Parameter className        - Name of class
# Returns                    - A MonitoringClass object
#
##########################################################################################
function GetMonitoringClass($managementGroup, $className)
{
	$monitoringClasses = $managementGroup.GetMonitoringClasses($className)

	return $monitoringClasses[0];
}

##########################################################################################
#
# Get Management Group for computer with given name (need to be FQDN)
# Parameter computername - Name of computer to use
# Returns                - A new ManagementGroup object
#
##########################################################################################
function GetManagementGroup($computername)
{
	return new-object Microsoft.EnterpriseManagement.ManagementGroup($Computername)
}

##########################################################################################
#
# Get computer object from WMI
# Returns - A WMI object for current computer
#
##########################################################################################
function GetWmiComputer()
{
    return Get-WmiObject -Class Win32_ComputerSystem
}

##########################################################################################
#
# Get FQDN for current computer
# Returns - Name of current computer as FQDN
#
##########################################################################################
function GetComputerName()
{
    $currentComputer = GetWmiComputer  
    return $currentcomputer.Name + "." + $currentComputer.Domain
}

##########################################################################################
# 
# Parse the input URL and return the Domain , Protocol and port.
#   Parameter jeeAppServer  - URL for the Application server
#   Returns                 - appServerHost, appServerPort, protocol
#                               or NULL if the URL is invalid
# 
##########################################################################################
function ParseURL($jeeAppServer)
{
    $appServer = $null
    $appServerHost = $null
    $appServerPort = $null
    $protocol = $null
    $result = $null

    if ($jeeAppServer)
    {
        $appServer = $jeeAppServer.Trim()
        $intLen = $appServer.Length

        if (($intLen -gt 0) -and (!$appServer.StartsWith("'"))) 
        {
            $intProtocol = $appServer.IndexOf("://")
            if ($intProtocol -gt 0) 
            {
                $protocol = $appServer.Substring(0, $intProtocol)

                #Get the HostName from the URL httpx://HostName:1234/abc
                $intHost = $appServer.IndexOf(":", $intProtocol+3)
                if ($intHost -gt 0) 
                {
                    # If a port has been supplied
                    if(($intLen-$intHost) -gt 1)
                    {
                        $appServerHost = $appServer.Substring($intProtocol+3, $intHost-$intProtocol-3) 
                        $thePort = $appServer.Substring($intHost+1)
                        trap 
                        {
                            continue
                        } 
                        $appServerPort = [int]$thePort
                    }
                }
                else
                {
                    #Get the HostName from the URL httpx://HostName/abc
                    $intHost = $appServer.IndexOf("/", $intProtocol+3)
                    if ($intHost -gt 0) 
                    {
                        $appServerPort = 80;
                        $appServerHost = $appServer.Substring($intProtocol+3, $intHost-$intProtocol-3) 
                    }
                    else
                    {
                        #Get the HostName from the URL httpx://HostName
                        $appServerPort = 80;
                        $appServerHost = $appServer.Substring($intProtocol + 3)
                    }
                }

                if (($appServerHost) -and ($appServerPort) -and 
                    ( ($protocol.ToLower().CompareTo("http") -eq 0) -or ($protocol.ToLower().CompareTo("https") -eq 0) ))
                {
                    $result = @{"appServerHost" = $appServerHost; "appServerPort" = $appServerPort; "protocol" = $protocol}
                }
            }
        }
    }
    return $result
}

##########################################################################################
# 
# Validate whether the supplied server type and version are supported.
#   Parameter serverType     - a string representation of the server type e.g. "Tomcat", "JBoss"
#   Parameter serverVersion  - the version number of the application server
#   Returns                  - true if the application server and version are supported else false
# 
##########################################################################################
function IsSupportedAppServer($serverType, $serverVersion)
{
    $isSupported = $false;
    if ($serverType.CompareTo("Tomcat") -eq 0)
    {
        if (($serverVersion -eq "5") -or 
            ($serverVersion -eq "6") -or 
            ($serverVersion -eq "7")) 
        {
            $isSupported = $true
        }
    }
    elseif ($serverType.CompareTo("JBoss") -eq 0)
    {
        if (($serverVersion -eq "4") -or 
            ($serverVersion -eq "5") -or 
            ($serverVersion -eq "6")) 
        {
            $isSupported = $true
        }
    }
    elseif ($serverType.CompareTo("WebSphere") -eq 0)
    {
        if (($serverVersion -eq "6") -or 
            ($serverVersion -eq "7")) 
        {
            $isSupported = $true
        }
    }
    elseif ($serverType.CompareTo("WebLogic") -eq 0)
    {
        if (($serverVersion -eq "10") -or 
            ($serverVersion -eq "11")) 
        {
            $isSupported = $true
        }
    }
    return $isSupported
}

##########################################################################################
# 
# Perform a webclient call to retrieve the application server name and version.
# If a username is supplied to this function is imples that secure communication is requested, the function 
# will request the password from the user and use these credentials to connect to the application server.
#   Parameter jeeAppServerQuery - the URL to the Stats/Info BeanSpy query.
#   Parameter locUserName       - the user name for basic authentication.
#   Returns                     - the xml response recieved from the call or NULL if the connection failed.
# 
##########################################################################################
function DoRequest($jeeAppServerQuery, $locUserName)
{
    $probe = $null

    $wc = new-object net.WebClient
    if ($locUserName -ne "")
    {
		$Password = Read-Host "Enter password:" -AsSecureString 
		$UnsecurePwd = [Runtime.InteropServices.Marshal]::PtrToStringAuto([Runtime.InteropServices.Marshal]::SecureStringToBSTR($Password))

        $cred = New-Object net.NetworkCredential($locUserName, $UnsecurePwd)
        $wc.set_Credentials($cred)
    }

    try 
    {
        $probe = $wc.downloadString($jeeAppServerQuery)
    }
    catch 
    {
        Write-Host "WebClient call failed to server: " $jeeAppServer -ForegroundColor Red
        return $null
    }
    return [xml] $probe
}

##########################################################################################
# 
# Perform a webclient call to retrieve the application server name and version.
#   Parameter jeeAppServer        - the URL to the application server.
#   Parameter locAppServerType    - optional value to override the server type.
#   Parameter locAppServerVersion - optional value to override the server version.
#   Parameter locUserName         - the user name for basic authentication.
#   Returns                       - appServerType and appServerVersion
# 
##########################################################################################
function QueryAppServer($jeeAppServer, $locAppServerType, $locAppServerVersion, $locUserName)
{
    $appServerType = "unknown"
    $appServerVersion = "unknown"
    $prName = $null
    $prVersion = $null
    $requestResult = $null
    $Result = $null

    ######################################################################################
    # If the user has specified the ServerType and Version then there is no need to
    # connect to the URL and atempt to retrieve them.
    ######################################################################################
    if (($locAppServerType -ne "") -and ($locAppServerVersion -ne "") -and 
        (IsSupportedAppServer $locAppServerType $locAppServerVersion))
    {
        $appServerType = $locAppServerType
        $appServerVersion = $locAppServerVersion
        $Result = @{"appServerType" = $appServerType; "appServerVersion" = $appServerVersion}
    }
    else
    {
        if ($jeeAppServer.EndsWith("/")) 
        {
            $jeeAppServer = $jeeAppServer.SubString(0, $jeeAppServer.Length -1)
        }
        $infoUrl = $jeeAppServer + "/BeanSpy/Stats/Info"

        $requestResult = DoRequest $infoUrl $locUserName
    
        if($requestResult -ne $null) 
        {
            $prName = $requestResult.Info.JEEServer.Properties.AppServerName."#text"
            $prVersion = $requestResult.Info.JEEServer.Properties.AppServerVersion."#text"
    
            if ($prName -ne $null)
            {
                #Is the app server JBoss?
                if ($prName.Contains("JBoss"))
                {
                    $appServerType = "JBoss"
                    if ($prVersion -ne $null) 
                    {
                        $ver = $prVersion.Substring(0)
                        $intVer = $prVersion.IndexOf(".")

                        if ($intVer -gt 0)
                        {
                            $ver = $prVersion.Substring(0,$intVer) 
                        }
                        $appServerVersion = $ver
                    }
                }
                #Is the app server Tomcat?
                elseif ($prName.Contains("Tomcat"))
                {
                    $appServerType = "Tomcat"

                    $intVer = $prName.IndexOf("Tomcat/") + 7
                    
                    $ver = $prName.Substring($intVer, 1)
                    $intDot = $prName.IndexOf(".", $intVer)

                    if ($intDot -gt 0)
                    {
                        $ver = $prName.Substring($intVer,$intDot-$intVer) 
                    }
                    $appServerVersion = $ver
                }
                #Is the app server WebSphere?
                elseif ($prName.Contains("WebSphere"))
                {
                    $appServerType = "WebSphere"
                    if ($prVersion -ne $null) 
                    {
                        $ver = $prVersion.Substring(0)
                        $intVer = $prVersion.IndexOf(".")

                        if ($intVer -gt 0)
                        {
                            $ver = $prVersion.Substring(0,$intVer) 
                        }
                        $appServerVersion = $ver
                    }
                }
                #Is the app server WebLogic?
                elseif ($prName.Contains("WebLogic"))
                {
                    $appServerType = "WebLogic"
                    $Major = $null
                    $Minor = $null
                    $Revision = $null
                    $intStartVer = $prName.IndexOf("WebLogic ") + 9

                    # Is there possibly a version number after the name
                    $len = $prName.Length
                    if ($len -gt $intStartVer)
                    {
                        $intDot = $prName.IndexOf(".",$intStartVer)
                        if($intDot -gt 0)
                        {
                            $Major = $prName.Substring($intStartVer,$intDot-$intStartVer)
                            $intDotMin = $prName.IndexOf(".",$intDot+1)
                            if( $intDotMin -gt 0 )
                            {
                                $Minor = $prName.Substring($intDot+1,$intDotMin-$intDot-1)
                                $intSpace = $prName.IndexOf(" ",$intDotMin+1)
                                if($intSpace -gt 0)
                                {
                                    $Revision = $prName.Substring($intDotMin+1,$intSpace-$intDotMin-1)
                                }
                                else
                                {
                                    $Revision = $prName.Substring($intDotMin+1)
                                }
                            }
                            else
                            {
                                $intSpace = $prName.IndexOf(" ",$intDot+1)
                                if($intSpace -gt 0)
                                {
                                    $Minor = $prName.Substring($intDot+1,$intSpace-$intDot)
                                }
                                else
                                {
                                    $Minor = $prName.Substring($intDot+1)
                                }
                            }
                        }
                        else
                        {
                            $intSpace = $prName.IndexOf(" ",$intStartVer)
                            if($intSpace -gt 0)
                            {
                                $Major = $prName.Substring($intStartVer,$intSpace-$intStartVer)
                            }
                        }

                        if($Major -eq "10")
                        {
                            if($Minor -gt "3")
                            {
                                $appServerVersion = "11"
                            }
                            elseif ($Minor -lt "3")
                            {
                                $appServerVersion = "10"
                            }
                            elseif($Minor -eq "3")
                            {
                                if($Revision -gt "0")
                                {
                                    $appServerVersion = "11"
                                }
                                else
                                {
                                    $appServerVersion = "10"
                                }
                            }
                        }
                        else
                        {
                            $appServerVersion = $Major
                        }

                    }
                }
                $Result = @{"appServerType" = $appServerType; "appServerVersion" = $appServerVersion}
            }
        }
    }
    return $Result
}
	

# SIG # Begin signature block
# MIIbPAYJKoZIhvcNAQcCoIIbLTCCGykCAQExCzAJBgUrDgMCGgUAMGkGCisGAQQB
# gjcCAQSgWzBZMDQGCisGAQQBgjcCAR4wJgIDAQAABBAfzDtgWUsITrck0sYpfvNR
# AgEAAgEAAgEAAgEAAgEAMCEwCQYFKw4DAhoFAAQU0EBGOIHySVu5LwvGOfJ/bH/3
# Db2gghXyMIIEoDCCA4igAwIBAgIKYRr16gAAAAAAajANBgkqhkiG9w0BAQUFADB5
# MQswCQYDVQQGEwJVUzETMBEGA1UECBMKV2FzaGluZ3RvbjEQMA4GA1UEBxMHUmVk
# bW9uZDEeMBwGA1UEChMVTWljcm9zb2Z0IENvcnBvcmF0aW9uMSMwIQYDVQQDExpN
# aWNyb3NvZnQgQ29kZSBTaWduaW5nIFBDQTAeFw0xMTExMDEyMjM5MTdaFw0xMzAy
# MDEyMjQ5MTdaMIGDMQswCQYDVQQGEwJVUzETMBEGA1UECBMKV2FzaGluZ3RvbjEQ
# MA4GA1UEBxMHUmVkbW9uZDEeMBwGA1UEChMVTWljcm9zb2Z0IENvcnBvcmF0aW9u
# MQ0wCwYDVQQLEwRNT1BSMR4wHAYDVQQDExVNaWNyb3NvZnQgQ29ycG9yYXRpb24w
# ggEiMA0GCSqGSIb3DQEBAQUAA4IBDwAwggEKAoIBAQDDqR/PfCN/MR4GJYnddXm5
# z5NLYZK2lfLvqiWdd/NLWm1JkMzgMbimAjeHdK/yrKBglLjHTiX+h9hY0iBOLfE6
# ZS6SW6Zd5pV14DTlUCGcfTmXto5EI2YWpmUg4Dbrivqd4stgAfwqZMiHRRTxHsrN
# KKy65VdZJtzsxUpsmuYDGikyPwCeg6wlDYTM3W+2arst94Q6bWYx6DZw/4SSkPdA
# dp6ILkfWKxH3j+ASZSu8X+8V/PfsAWi3RQzuwASwDre9eGuujeRQ8TXingHS4etb
# cYJhISDz1MneHLgCRWVJvn61N4anzexa37h2IPwRE1H8+ipQqrQe0DqAvmPK3IFH
# AgMBAAGjggEdMIIBGTATBgNVHSUEDDAKBggrBgEFBQcDAzAdBgNVHQ4EFgQUAAOm
# 5aLEcaKCw492zSwNEuKdSigwDgYDVR0PAQH/BAQDAgeAMB8GA1UdIwQYMBaAFFdF
# dBxdsPbIQwXgjFQtjzKn/kiWMFYGA1UdHwRPME0wS6BJoEeGRWh0dHA6Ly9jcmwu
# bWljcm9zb2Z0LmNvbS9wa2kvY3JsL3Byb2R1Y3RzL01pY0NvZFNpZ1BDQV8wOC0z
# MS0yMDEwLmNybDBaBggrBgEFBQcBAQROMEwwSgYIKwYBBQUHMAKGPmh0dHA6Ly93
# d3cubWljcm9zb2Z0LmNvbS9wa2kvY2VydHMvTWljQ29kU2lnUENBXzA4LTMxLTIw
# MTAuY3J0MA0GCSqGSIb3DQEBBQUAA4IBAQCQ9/h5kmnIj2uKYO58wa4+gThS9LrP
# mYzwLT0T9K72YfB1OE5Zxj8HQ/kHfMdT5JFi1qh2FHWUhlmyuhDCf2wVPxkVww4v
# fjnDz/5UJ1iUNWEHeW1RV7AS4epjcooWZuufOSozBDWLg94KXjG8nx3uNUUNXceX
# 3yrgnX86SfvjSEUy3zZtCW52VVWsNMV5XW4C1cyXifOoaH0U6ml7C1V9AozETTC8
# Yvd7peygkvAOKg6vV5spSM22IaXqHe/cCfWrYtYN7DVfa5nUsfB3Uvl36T9smFbA
# XDahTl4Q9Ix6EZcgIDEIeW5yFl8cMFeby3yiVfVwbHjsoUMgruywNYsYMIIEujCC
# A6KgAwIBAgIKYQUZlgAAAAAAGzANBgkqhkiG9w0BAQUFADB3MQswCQYDVQQGEwJV
# UzETMBEGA1UECBMKV2FzaGluZ3RvbjEQMA4GA1UEBxMHUmVkbW9uZDEeMBwGA1UE
# ChMVTWljcm9zb2Z0IENvcnBvcmF0aW9uMSEwHwYDVQQDExhNaWNyb3NvZnQgVGlt
# ZS1TdGFtcCBQQ0EwHhcNMTEwNzI1MjA0MjE5WhcNMTIxMDI1MjA0MjE5WjCBszEL
# MAkGA1UEBhMCVVMxEzARBgNVBAgTCldhc2hpbmd0b24xEDAOBgNVBAcTB1JlZG1v
# bmQxHjAcBgNVBAoTFU1pY3Jvc29mdCBDb3Jwb3JhdGlvbjENMAsGA1UECxMETU9Q
# UjEnMCUGA1UECxMebkNpcGhlciBEU0UgRVNOOjlFNzgtODY0Qi0wMzlEMSUwIwYD
# VQQDExxNaWNyb3NvZnQgVGltZS1TdGFtcCBTZXJ2aWNlMIIBIjANBgkqhkiG9w0B
# AQEFAAOCAQ8AMIIBCgKCAQEA08s7U6KfRKN6q01WcVOKd6o3k34BPv2rAqNTqf/R
# sSLFAJDndW7uGOiBDhPF2GEAvh+gdjsEDQTFBKCo/ENTBqEEBLkLkpgCYjjv1DMS
# 9ys9e++tRVeFlSCf12M0nGJGjr6u4NmeOfapVf3P53fmNRPvXOi/SJNPGkMHWDiK
# f4UUbOrJ0Et6gm7L0xVgCBSJlKhbPzrJPyB9bS9YGn3Kiji8w8I5aNgtWBoj7SoQ
# CFogjIKl7dGXRZKFzMM3g98NmHzF07bgmVPYeAj15SMhB2KGWmppGf1w+VM0gfcl
# MRmGh4vAVZr9qkw1Ff1b6ZXJq1OYKV8speElD2TF8rAndQIDAQABo4IBCTCCAQUw
# HQYDVR0OBBYEFHkj56ENvlUsaBgpYoJn1vPhNjhaMB8GA1UdIwQYMBaAFCM0+NlS
# RnAK7UD7dvuzK7DDNbMPMFQGA1UdHwRNMEswSaBHoEWGQ2h0dHA6Ly9jcmwubWlj
# cm9zb2Z0LmNvbS9wa2kvY3JsL3Byb2R1Y3RzL01pY3Jvc29mdFRpbWVTdGFtcFBD
# QS5jcmwwWAYIKwYBBQUHAQEETDBKMEgGCCsGAQUFBzAChjxodHRwOi8vd3d3Lm1p
# Y3Jvc29mdC5jb20vcGtpL2NlcnRzL01pY3Jvc29mdFRpbWVTdGFtcFBDQS5jcnQw
# EwYDVR0lBAwwCgYIKwYBBQUHAwgwDQYJKoZIhvcNAQEFBQADggEBAEfCdoFbMd1v
# 0zyZ8npsfpcTUCwFFxsQuEShtYz0Vs+9sCG0ZG1hHNju6Ov1ku5DohhEw/r67622
# XH+XbUu1Q/snYXgIVHyx+a+YCrR0xKroLVDEff59TqGZ1icot67Y37GPgyKOzvN5
# /GEUbb/rzISw36O7WwW36lT1Yh1sJ6ZjS/rjofq734WWZWlTsLZxmGQmZr3F8Vxi
# vJH0PZxLQgANzzgFFCZa3CoFS39qmTjY3XOZos6MUCSepOv1P4p4zFSZXSVmpEEG
# KK9JxLRSlOzeAoNk/k3U/0ui/CmA2+4/qzztM4jKvyJg0Fw7BLAKtJhtPKc6T5rR
# ARYRYopBdqAwggYHMIID76ADAgECAgphFmg0AAAAAAAcMA0GCSqGSIb3DQEBBQUA
# MF8xEzARBgoJkiaJk/IsZAEZFgNjb20xGTAXBgoJkiaJk/IsZAEZFgltaWNyb3Nv
# ZnQxLTArBgNVBAMTJE1pY3Jvc29mdCBSb290IENlcnRpZmljYXRlIEF1dGhvcml0
# eTAeFw0wNzA0MDMxMjUzMDlaFw0yMTA0MDMxMzAzMDlaMHcxCzAJBgNVBAYTAlVT
# MRMwEQYDVQQIEwpXYXNoaW5ndG9uMRAwDgYDVQQHEwdSZWRtb25kMR4wHAYDVQQK
# ExVNaWNyb3NvZnQgQ29ycG9yYXRpb24xITAfBgNVBAMTGE1pY3Jvc29mdCBUaW1l
# LVN0YW1wIFBDQTCCASIwDQYJKoZIhvcNAQEBBQADggEPADCCAQoCggEBAJ+hbLHf
# 20iSKnxrLhnhveLjxZlRI1Ctzt0YTiQP7tGn0UytdDAgEesH1VSVFUmUG0KSrphc
# MCbaAGvoe73siQcP9w4EmPCJzB/LMySHnfL0Zxws/HvniB3q506jocEjU8qN+kXP
# CdBer9CwQgSi+aZsk2fXKNxGU7CG0OUoRi4nrIZPVVIM5AMs+2qQkDBuh/NZMJ36
# ftaXs+ghl3740hPzCLdTbVK0RZCfSABKR2YRJylmqJfk0waBSqL5hKcRRxQJgp+E
# 7VV4/gGaHVAIhQAQMEbtt94jRrvELVSfrx54QTF3zJvfO4OToWECtR0Nsfz3m7IB
# ziJLVP/5BcPCIAsCAwEAAaOCAaswggGnMA8GA1UdEwEB/wQFMAMBAf8wHQYDVR0O
# BBYEFCM0+NlSRnAK7UD7dvuzK7DDNbMPMAsGA1UdDwQEAwIBhjAQBgkrBgEEAYI3
# FQEEAwIBADCBmAYDVR0jBIGQMIGNgBQOrIJgQFYnl+UlE/wq4QpTlVnkpKFjpGEw
# XzETMBEGCgmSJomT8ixkARkWA2NvbTEZMBcGCgmSJomT8ixkARkWCW1pY3Jvc29m
# dDEtMCsGA1UEAxMkTWljcm9zb2Z0IFJvb3QgQ2VydGlmaWNhdGUgQXV0aG9yaXR5
# ghB5rRahSqClrUxzWPQHEy5lMFAGA1UdHwRJMEcwRaBDoEGGP2h0dHA6Ly9jcmwu
# bWljcm9zb2Z0LmNvbS9wa2kvY3JsL3Byb2R1Y3RzL21pY3Jvc29mdHJvb3RjZXJ0
# LmNybDBUBggrBgEFBQcBAQRIMEYwRAYIKwYBBQUHMAKGOGh0dHA6Ly93d3cubWlj
# cm9zb2Z0LmNvbS9wa2kvY2VydHMvTWljcm9zb2Z0Um9vdENlcnQuY3J0MBMGA1Ud
# JQQMMAoGCCsGAQUFBwMIMA0GCSqGSIb3DQEBBQUAA4ICAQAQl4rDXANENt3ptK13
# 2855UU0BsS50cVttDBOrzr57j7gu1BKijG1iuFcCy04gE1CZ3XpA4le7r1iaHOEd
# AYasu3jyi9DsOwHu4r6PCgXIjUji8FMV3U+rkuTnjWrVgMHmlPIGL4UD6ZEqJCJw
# +/b85HiZLg33B+JwvBhOnY5rCnKVuKE5nGctxVEO6mJcPxaYiyA/4gcaMvnMMUp2
# MT0rcgvI6nA9/4UKE9/CCmGO8Ne4F+tOi3/FNSteo7/rvH0LQnvUU3Ih7jDKu3hl
# XFsBFwoUDtLaFJj1PLlmWLMtL+f5hYbMUVbonXCUbKw5TNT2eb+qGHpiKe+imyk0
# BncaYsk9Hm0fgvALxyy7z0Oz5fnsfbXjpKh0NbhOxXEjEiZ2CzxSjHFaRkMUvLOz
# sE1nyJ9C/4B5IYCeFTBm6EISXhrIniIh0EPpK+m79EjMLNTYMoBMJipIJF9a6lbv
# pt6Znco6b72BJ3QGEe52Ib+bgsEnVLaxaj2JoXZhtG6hE6a/qkfwEm/9ijJssv7f
# UciMI8lmvZ0dhxJkAj0tr1mPuOQh5bWwymO0eFQF1EEuUKyUsKV4q7OglnUa2ZKH
# E3UiLzKoCG6gW4wlv6DvhMoh1useT8ma7kng9wFlb4kLfchpyOZu6qeXzjEp/w7F
# W1zYTRuh2Povnj8uVRZryROj/TCCBoEwggRpoAMCAQICCmEVCCcAAAAAAAwwDQYJ
# KoZIhvcNAQEFBQAwXzETMBEGCgmSJomT8ixkARkWA2NvbTEZMBcGCgmSJomT8ixk
# ARkWCW1pY3Jvc29mdDEtMCsGA1UEAxMkTWljcm9zb2Z0IFJvb3QgQ2VydGlmaWNh
# dGUgQXV0aG9yaXR5MB4XDTA2MDEyNTIzMjIzMloXDTE3MDEyNTIzMzIzMloweTEL
# MAkGA1UEBhMCVVMxEzARBgNVBAgTCldhc2hpbmd0b24xEDAOBgNVBAcTB1JlZG1v
# bmQxHjAcBgNVBAoTFU1pY3Jvc29mdCBDb3Jwb3JhdGlvbjEjMCEGA1UEAxMaTWlj
# cm9zb2Z0IENvZGUgU2lnbmluZyBQQ0EwggEiMA0GCSqGSIb3DQEBAQUAA4IBDwAw
# ggEKAoIBAQCfjd+FN4yxBlZmNk7UCus2I5Eer6uNWOnEz8GfOgokxMTEXrDuFRTF
# +j6ZM2sZaXL0fAVf5ZklRNc1GYqQ3CiOkAzv1ZBhrd7cGHAtg8lvr4Us+N25uTD9
# cXgcg/3IqbmCZw16uMEJwrwWl1c/HJjTadcwkJCQjTAf2CbUnnuI2eIJ7ZdJResE
# UoF1e7i1IrguVrvXz6lOPAqDoqg6xa22AQ5qzyK0Ix9s1Sfnt37BtNUyrXklHEKG
# 4p2F9FfaG1kvLSaSKcWz14WjnmBalOZ7nHtegjRLbf/U7ifQotzRkAzOfQ4VfIis
# NMfAbJiESslEeWgo3yKDDbiKLEhh4v4RAgMBAAGjggIjMIICHzAQBgkrBgEEAYI3
# FQEEAwIBADAdBgNVHQ4EFgQUV0V0HF2w9shDBeCMVC2PMqf+SJYwCwYDVR0PBAQD
# AgHGMA8GA1UdEwEB/wQFMAMBAf8wgZgGA1UdIwSBkDCBjYAUDqyCYEBWJ5flJRP8
# KuEKU5VZ5KShY6RhMF8xEzARBgoJkiaJk/IsZAEZFgNjb20xGTAXBgoJkiaJk/Is
# ZAEZFgltaWNyb3NvZnQxLTArBgNVBAMTJE1pY3Jvc29mdCBSb290IENlcnRpZmlj
# YXRlIEF1dGhvcml0eYIQea0WoUqgpa1Mc1j0BxMuZTBQBgNVHR8ESTBHMEWgQ6BB
# hj9odHRwOi8vY3JsLm1pY3Jvc29mdC5jb20vcGtpL2NybC9wcm9kdWN0cy9taWNy
# b3NvZnRyb290Y2VydC5jcmwwVAYIKwYBBQUHAQEESDBGMEQGCCsGAQUFBzAChjho
# dHRwOi8vd3d3Lm1pY3Jvc29mdC5jb20vcGtpL2NlcnRzL01pY3Jvc29mdFJvb3RD
# ZXJ0LmNydDB2BgNVHSAEbzBtMGsGCSsGAQQBgjcVLzBeMFwGCCsGAQUFBwICMFAe
# TgBDAG8AcAB5AHIAaQBnAGgAdAAgAKkAIAAyADAAMAA2ACAATQBpAGMAcgBvAHMA
# bwBmAHQAIABDAG8AcgBwAG8AcgBhAHQAaQBvAG4ALjATBgNVHSUEDDAKBggrBgEF
# BQcDAzANBgkqhkiG9w0BAQUFAAOCAgEAMLywIKRioKfvOSZhPdysxpnQhsQu9YMy
# ZV4iPpvWhvjotp/Ki9Y7dQuhkT5M3WR0jEnyiIwYZ2z+FWZGuDpGQpfIkTfUJLHn
# rNPqQRSDd9PJTwVfoxRSv5akLz5WWxB1zlPDzgVUabRlySSlD+EluBq5TeUCuVAe
# T7OYDB2VAu4iWa0iywV0CwRFewRZ4NgPs+tM+GDdwnie0bqfa/fz7n5EEUDSvbqb
# SxYIbqS+VeSmOBKjSPQcVXqKINF9/pHblI8vwntrpmSFT6PlLDQpXQu/9cc4L8Qg
# xFYx9mnOhfgKkezQ1q66OAUM625PTJwDKaqi/BigKQwNXFxWI1faHJYNyCY2wUTL
# 5eHmb4nnj+mYtXPTeOPtowE8dOVevGz2IYlnBeyXnbWx/a+m6XKlwzThL5/59Go5
# 4i0Eglv80JyufJ0R+ea1Uxl0ujlKOet9QrNKOzc9wkp7J5jn4k6bG0pUOGojN75q
# t0ju6kINSSSRjrcELpdv5OdFu49N/WDZ11nC2IDWYDR7t6GTIP6BuKqlXAnpig2+
# KE1+1+gP7WV40TFfuWbb30LnC8wCB43f/yAGo0VltLMyjS6R4k20qcn6vGsEDrKf
# 6p/epMkKlvSN99iYqPCFAghZpCCmLAsa8lIG7WnlZBgb4KOr3sp8FGFDuGX1NqNV
# EytnLE0bMEwxggS0MIIEsAIBATCBhzB5MQswCQYDVQQGEwJVUzETMBEGA1UECBMK
# V2FzaGluZ3RvbjEQMA4GA1UEBxMHUmVkbW9uZDEeMBwGA1UEChMVTWljcm9zb2Z0
# IENvcnBvcmF0aW9uMSMwIQYDVQQDExpNaWNyb3NvZnQgQ29kZSBTaWduaW5nIFBD
# QQIKYRr16gAAAAAAajAJBgUrDgMCGgUAoIHhMBkGCSqGSIb3DQEJAzEMBgorBgEE
# AYI3AgEEMBwGCisGAQQBgjcCAQsxDjAMBgorBgEEAYI3AgEVMCMGCSqGSIb3DQEJ
# BDEWBBR3Z9AZW5muTu+iJ30pG4A8fA61hTCBgAYKKwYBBAGCNwIBDDFyMHCgRIBC
# AFMAeQBzAHQAZQBtACAAQwBlAG4AdABlAHIAIAAyADAAMQAyACAATQBQACAAZgBv
# AHIAIABKAGEAdgBhACAARQBFoSiAJmh0dHA6Ly93d3cubWljcm9zb2Z0LmNvbS9T
# eXN0ZW1DZW50ZXIgMA0GCSqGSIb3DQEBAQUABIIBACY5f7ugFQ9e4VUa/9x05U7s
# tcCiDvzA5zcnG4L/chqcVs5HJJES7FiBg3v0uHptxR3CV/qXN4hvJFOkXi/1/w1m
# ZKJHkUxZN8OioOMlteqyyzXfzEKxC8sieWAbzMxgK5MYCAzlKABYnOpwiMGW/rOJ
# znw/lckib0bjG2V4sDPhWZO9u/WdWzizAyy+1g5AsFyTGP5C0wsZlkXBS6TQDmHh
# ze1kWc752vjRW7OI2LuWCUnekSHmC0+2dJsfNr/u03FVTpqfW4Csbmx2EZZj9Z4S
# ME/UT35t5xsBJhSpw7q5etKoR8k7G+6SbDAV/JwMQVlK8dvv4A1N6TIgWzVkaCeh
# ggIdMIICGQYJKoZIhvcNAQkGMYICCjCCAgYCAQEwgYUwdzELMAkGA1UEBhMCVVMx
# EzARBgNVBAgTCldhc2hpbmd0b24xEDAOBgNVBAcTB1JlZG1vbmQxHjAcBgNVBAoT
# FU1pY3Jvc29mdCBDb3Jwb3JhdGlvbjEhMB8GA1UEAxMYTWljcm9zb2Z0IFRpbWUt
# U3RhbXAgUENBAgphBRmWAAAAAAAbMAcGBSsOAwIaoF0wGAYJKoZIhvcNAQkDMQsG
# CSqGSIb3DQEHATAcBgkqhkiG9w0BCQUxDxcNMTExMjA2MjMwNTMxWjAjBgkqhkiG
# 9w0BCQQxFgQUsDibvK1MKiDIJGF8sZ7U01RZoi0wDQYJKoZIhvcNAQEFBQAEggEA
# Ko1tRIKLQEEk4ZfG5UQq5PAknadWgvGhr/Afn7oFmy40neqaqVTjHPjq0iPLc2Y2
# cqUNWjCIRT4VzrERQmJa8dWjlmFP3CWIg3Ou4Inht3r6JJtXwFhDx5MMGT+wwSHy
# Z2Ezv4WsLFYRPKpfjhpgmNspSI7sxFOgtBSyNkz+zijuPQVkDVLfWvJhckJg+OIY
# yNes8P+8tixDrjYaAnd43nJFtZ+lh0+u/Onj+lqGNoIXDxkSQ4u9GgnASSVpd0xb
# XnvWkkWzAJRx8Rl3IXMfwEkkF1kgR3/oaOZuuWWVKb90SUbtA2Z0Rf4sVzx/xd+B
# ytqfvOOwqbaqH5i1YsRouA==
# SIG # End signature block
