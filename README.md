# Alert_Intune_Token

This script will send you a mail when your Intune token certificates are almost expiring.
You have to add a APP in AAD (https://learn.microsoft.com/en-us/azure/active-directory/develop/quickstart-register-app), with the following permissions: DeviceManagementServiceConfig.Read.All & Directory.Read.All .

The scripts uses a certificate to authenticate. With the script cert-liners.ps1 you can make your own self signed certificate. The certificate expires after 3 years, you add years if want by changing 
"(Get-Date).AddYears(3)"
Ofcourse change the file paths.

In the controle_certificates.ps1
Add your APP id, Tenant ID and the thumbprint of the certificate(Please remember the device that runs the scripts has to have the certifcate in his store.). 
Also add addresses to line 54, 55
Add your credentials for sending mail in line 62
