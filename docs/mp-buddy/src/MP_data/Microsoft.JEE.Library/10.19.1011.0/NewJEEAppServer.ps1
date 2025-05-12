##########################################################################################
# <copyright file="NewJEEAppServer.ps1" company="Microsoft">
#     Copyright (c) Microsoft Corporation.  All rights reserved.
# </copyright>
# <summary>Powershell script to perform a first stage discovery of a Java JEE 
# application server. The output is a discovered OM 
# "Microsoft.JEE.Universal.ApplicationServer" object. </summary>
##########################################################################################

param([switch]$help,
    $ManagementServer = "",
	$JEEAppServerType = "",
	$JEEAppServerVersion = "",
	$UserName = "",
	$Target = "")

begin 
{
    Set-PSDebug -Strict
    . .\JEEAppServerLibrary.ps1

    ##########################################################################################
    # 
	# Processes one app server. 
    # The input URL is parsed for correctness and the hostname and port are extracted. 
    # The application server type and version are either obtained from the command 
    # line arguments or queried from the application server if not specified on the command line.
    #
    # If all the requirements are met a new Operations Manager Discovery data item 
    # is created using these attributes.
    # 
    #   Parameter jeeAppServer        - the URL to the application server.
    # 
    ##########################################################################################
    function ProcessJEEAppServer($jeeAppServer)
    {
        #
        # Validate that the input URL is correctly formed, the protocol, port and hostname are
        # extracted from the URL
        #
		$appServerProp = ParseURL $jeeAppServer
		if ($appServerProp -eq $null) 
        {
            Write-Host -foregroundcolor Red "`nFailed to Parse the URL `: $jeeAppServer `n"
            return;
        }
		$appServerHost = $appServerProp["appServerHost"]
		$appServerPort = $appServerProp["appServerPort"] 
		$appServerProtocol = $appServerProp["protocol"] 

		if ($ManagementServer -eq "")
		{
			$ManagementServer = GetComputerName;
		}
	    $managementGroup = GetManagementGroup $ManagementServer

		# 
        # Get the Discovery class		
        #
	    $jeeAppServerClass = GetMonitoringClass $managementGroup "Microsoft.JEE.Universal.ApplicationServer"
        if( $jeeAppServerClass -eq $null )
        {
            #the Microsoft.JEE.Universal.ApplicationServer MP has not been loaded
            Write-Host  -foregroundcolor Red "`nFailed to load class (Microsoft.JEE.Universal.ApplicationServer) from the imported MP's," 
            Write-Host  -foregroundcolor Red "please ensure MP's JEE MP's are imported.`n"
            return;
        }
	    $jeeAppServerObject = new-object Microsoft.EnterpriseManagement.Monitoring.CustomMonitoringObject($jeeAppServerClass)

	    $baseAppServerClass = GetMonitoringClass $managementGroup "Microsoft.JEE.ApplicationServer.Instance"
		
		$monitoredProp = QueryAppServer $jeeAppServer $JEEAppServerType $JEEAppServerVersion $UserName

		if ($monitoredProp -eq $null) 
        { 
            Write-Host -foregroundcolor Red "Unable to determine the application server type and version `: $jeeAppServer `n"
            return 
        }
		$appServerType = $monitoredProp["appServerType"]
		$appServerVersion = $monitoredProp["appServerVersion"]
		

		$id = "$($appServerHost):$($appServerPort):universal"

	    $jeeAppServerObject.SetMonitoringPropertyValue($baseAppServerClass.GetMonitoringProperty("Id"), $id)
	    $jeeAppServerObject.SetMonitoringPropertyValue($baseAppServerClass.GetMonitoringProperty("HostName"), $appServerHost)
		if ($appServerProtocol.CompareTo("http") -eq 0)
		{
	    	$jeeAppServerObject.SetMonitoringPropertyValue($baseAppServerClass.GetMonitoringProperty("HttpPort"), $appServerPort)
		}
		else
		{
	    	$jeeAppServerObject.SetMonitoringPropertyValue($baseAppServerClass.GetMonitoringProperty("HttpsPort"), $appServerPort)
		}
	    $jeeAppServerObject.SetMonitoringPropertyValue($baseAppServerClass.GetMonitoringProperty("Version"), $appServerVersion)
	    $jeeAppServerObject.SetMonitoringPropertyValue($baseAppServerClass.GetMonitoringProperty("DiskPath"), "")
	    $jeeAppServerObject.SetMonitoringPropertyValue($jeeAppServerClass.GetMonitoringProperty("AppServerType"), $appServerType)
	    $jeeAppServerObject.SetMonitoringPropertyValue($jeeAppServerClass.GetMonitoringProperty("Protocol"), $appServerProtocol)
	    $jeeAppServerObject.SetMonitoringPropertyValue($jeeAppServerClass.GetMonitoringProperty("Port"), $appServerPort)
	    $discoveryData = new-object Microsoft.EnterpriseManagement.ConnectorFramework.IncrementalMonitoringDiscoveryData
	    $discoveryData.Add($jeeAppServerObject)
		
		$mc = GetJEEConnector $managementGroup
		$discoveryData.Commit($mc)
		Write-Host -noNewLine  "Processed app server: "
		Write-Host  -noNewLine -foregroundcolor Green $jeeAppServer
		Write-Host -noNewLine  "   type: "
		Write-Host  -noNewLine -foregroundcolor Green $appServerType
		Write-Host -noNewLine  "   Version: "
		Write-Host -foregroundcolor Green $appServerVersion
    }

    ##########################################################################################
    
    # Print help text.
    if ($Help)
    {
        $helpstr =  "`n`nNew-JEEAppServer.ps1`n" +
                    "`n" +
                    "Discovers JEE App Servers into Operations Manager.  BeanSpy should be deployed to each application server to be discovered.`n" +
                    "`n" +
                    "Input:`n" +
                    "  The script accepts a number of JEE App Servers on the input pipe.`n" +
                    "  Each JEE App Server is represented as a fully qualified URL, for example, http://www.contoso.com:8080.`n" +
                    "`n" +
                    "Output:`n" +
                    "  The script displays an error message for each app server it fails to discover.`n" +
                    "`n" +
                    "Parameters:`n" +
                    "  ManagementServer         - Name of OpsMgr server to use.  Use current computer if not specified`n" +
                    "  JEEAppServerType         - Supported types are JBoss, Tomcat, WebSphere, and WebLogic.`n" +
                    "                             Will query each application server if not specified.`n" +
                    "  JEEAppServerVersion      - Supported versions are JBoss 4, 5, 6, Tomcat 5, 6, 7, WebSphere 6, 7, and WebLogic 10, 11.`n" +
                    "                             Will query each application server if not specified.`n" +
                    "  UserName                 - User name to access the App Server URL. If provided, the script will prompt for password`n" +
                    "  Target                   - Additional JEE App Server to discover`n" +
                    "                             (done before any JEE App Server piped into the script)`n" +
                    "  help                     - Prints this help`n" +
                    "`n" +
                    "Examples:`n" +
                    "  New-JEEAppServer.ps1 -Target http://www.contoso.com:8080`n" +
                    "  type c:\MyAppServers.txt | New-JEEAppServer.ps1 -JEEAppServerType WebLogic -JEEAppServerVersion 11 `n" +
                    "  type c:\MyAppServers.txt | New-JEEAppServer.ps1 -UserName mymonitor`n"
                    "`n"
        Write-Host $helpstr
        exit
    }

    #    
    # Load the assemblies required by this script
    #
    if( Load-Assemblies -eq $true )
    {
        # If we have one target as command line input we process it first.
        if ($Target -ne "") 
        {
            ProcessJEEAppServer $Target
        }
    }
}

process 
{
    # Process any targets in pipe.
    if ($_) 
    {
        ProcessJEEAppServer $_
    }
}

end 
{
}

# SIG # Begin signature block
# MIIbPAYJKoZIhvcNAQcCoIIbLTCCGykCAQExCzAJBgUrDgMCGgUAMGkGCisGAQQB
# gjcCAQSgWzBZMDQGCisGAQQBgjcCAR4wJgIDAQAABBAfzDtgWUsITrck0sYpfvNR
# AgEAAgEAAgEAAgEAAgEAMCEwCQYFKw4DAhoFAAQUiLhp/zcWqQo7cRPyq9b3GHJ5
# J1egghXyMIIEoDCCA4igAwIBAgIKYRr16gAAAAAAajANBgkqhkiG9w0BAQUFADB5
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
# BDEWBBSVn6TdvuCg0qCjkHYUSuySVaHg0TCBgAYKKwYBBAGCNwIBDDFyMHCgRIBC
# AFMAeQBzAHQAZQBtACAAQwBlAG4AdABlAHIAIAAyADAAMQAyACAATQBQACAAZgBv
# AHIAIABKAGEAdgBhACAARQBFoSiAJmh0dHA6Ly93d3cubWljcm9zb2Z0LmNvbS9T
# eXN0ZW1DZW50ZXIgMA0GCSqGSIb3DQEBAQUABIIBAFfEt3QZfIBTmg4Fi01ABR+c
# MVcsaRXO9mxZYYPinCkZwqN6w6T3zTraAV5083dcWJoE3Yr+YEEoKbGX+PSnm3rD
# D3xJG/32kz/mPntZLCbO0UCYefffUtf+9djVXMAPBdw8ti0phrurInEY71ZoPXWp
# QOGjdNKM9wIhhV1cIXgPFfYGYjJ3YuPeBGGzLrurGxXoCGX65g6Gnq0d+SUQhZFC
# ASMRpp53t3ajwnAwj3RmJiwBWqNFmROufC1/mLGJ0LqqdCxyVnUiRS5icMJD4KQ+
# q9XjPD6AhBU6uol9JU7/1sHQikCaGyenkRsfTF+iv22O+IGFIPfPssLqgFj3uIOh
# ggIdMIICGQYJKoZIhvcNAQkGMYICCjCCAgYCAQEwgYUwdzELMAkGA1UEBhMCVVMx
# EzARBgNVBAgTCldhc2hpbmd0b24xEDAOBgNVBAcTB1JlZG1vbmQxHjAcBgNVBAoT
# FU1pY3Jvc29mdCBDb3Jwb3JhdGlvbjEhMB8GA1UEAxMYTWljcm9zb2Z0IFRpbWUt
# U3RhbXAgUENBAgphBRmWAAAAAAAbMAcGBSsOAwIaoF0wGAYJKoZIhvcNAQkDMQsG
# CSqGSIb3DQEHATAcBgkqhkiG9w0BCQUxDxcNMTExMjA2MjMwNTMxWjAjBgkqhkiG
# 9w0BCQQxFgQUkG1ro6/941jldwUL/zvKCxCyIEIwDQYJKoZIhvcNAQEFBQAEggEA
# zB6gQTRouZIY5MEtsn6faoRhpPpSSKBhENgKSKCa6nHlfc4ERsCvHChS73mo0aXO
# unUQ6qSpoldIbCp/JezXOKIh9jLnSOX1UeI5PCdjANItx8SH/tnBmEnYg4wAzCjd
# tRcLSKBM+IbU6n4JizDQI8eGqizIAFENOcVPlPL5a3kSw2MY2qNFfOpE24aVvBfV
# SUmM0aVvgpmVdtDwSSav5orUU17zEHhfvwXKd/uQctD8YnmSW3Oh60IL1gZhnu0o
# 9a3zdwj0KD9u9AXaizCmewC54Sp7C8GRXbaQeoXS8ua5XKENsV7YtqcnMQUQ8djs
# 9EW664qUb99WXrBqEPMTSA==
# SIG # End signature block
