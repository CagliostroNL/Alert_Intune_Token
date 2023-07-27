#Needed scope = DeviceManagementServiceConfig.Read.All & Directory.Read.All 
$APP_ID = ""
$TENANT_ID = ""
$Thumb = ""

Connect-MgGraph -ClientID $APP_ID -TenantId $TENANT_ID -CertificateThumbprint $Thumb
#Control date is set to 14 days. If days to expiration is less then 14 days the mail will be send.
$DateNow = Get-Date -Format yyyy-MM-dd
$ControlDays = 14
$Cert_Push = (Invoke-MgGraphRequest -Method GET -Uri https://graph.microsoft.com/v1.0/deviceManagement/applePushNotificationCertificate).expirationDateTime
$Cert_VVPToken = ((Invoke-MgGraphRequest -Method GET -Uri https://graph.microsoft.com/v1.0/deviceAppManagement/vppTokens).Value).("ExpirationDateTime")
$Cert_DEP = ((Invoke-MgGraphRequest -Method GET -Uri https://graph.microsoft.com/beta/deviceManagement/depOnboardingSettings).Value).("tokenExpirationDateTime")
$Klant = ((Invoke-MgGraphRequest -Method GET -Uri https://graph.microsoft.com/v1.0/domains).Value |  where-object {$_.IsDefault -eq $True}).Id

function Compare-Date()
{
    [CmdletBinding()]
    param (
        [Parameter(Mandatory)]
        [DateTime]$Date     
    )
    (New-TimeSpan -Start $DateNow -End $Date).Days
}


$body =  @"

    "Apple token in Intune Tenant: '$Klant' is expiring:"

                    Token:
                    "TOKEN_N"
                    Expiration date (US-DATE):
                    "TOKEN_EXP"
                    Days to expiration:
                    "DAYS_EXPIRATION"
            

"@

function Control-Certificate {
    param (
        [Parameter(Mandatory)]
        [string]$Certificate,
        [Parameter(Mandatory)]
        $Cert_info
    )

        if ((Compare-Date -Date $Cert_info) -le $ControlDays)
        {
            $body = $body.Replace("TOKEN_N", $Certificate)
            $body = $body.Replace("TOKEN_EXP", $Cert_info)
            $body = $body.Replace("DAYS_EXPIRATION", (Compare-Date -Date $Cert_info))
            
            $EmailTo = ""
            $EmailFrom = ""
            $Subject = "Alert Apple Token is expiring" 
            $SMTPServer = "smtp.office365.com" 

            $SMTPMessage = New-Object System.Net.Mail.MailMessage($EmailFrom,$EmailTo,$Subject,$Body)
            $SMTPClient = New-Object Net.Mail.SmtpClient($SmtpServer, 587) 
            $SMTPClient.EnableSsl = $true
            $SMTPClient.Credentials = New-Object System.Net.NetworkCredential("mailadress", "password"); 
            $SMTPClient.Send($SMTPMessage)

        }


}

Control-Certificate -Certificate "Apple Push Certificate" -Cert_info $Cert_Push
Control-Certificate -Certificate "DEP Certificate" -Cert_info $Cert_DEP
Control-Certificate -Certificate "VVP Token Certificate" -Cert_info $Cert_VVPToken

Disconnect-MgGraph