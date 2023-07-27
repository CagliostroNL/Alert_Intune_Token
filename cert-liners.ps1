$certname = "AppleExpiration"    ## Replace {certificateName}
$cert = New-SelfSignedCertificate -Subject "CN=$certname" -CertStoreLocation "Cert:\CurrentUser\My" -KeyExportPolicy Exportable -KeySpec Signature -KeyLength 2048 -KeyAlgorithm RSA -HashAlgorithm SHA256 -NotAfter (Get-Date).AddYears(3)
Export-Certificate -Cert $cert -FilePath "C:\Users\username\Desktop\$certname.cer"
$mypwd = ConvertTo-SecureString -String "passwordhere" -Force -AsPlainText  ## Replace {myPassword}
Export-PfxCertificate -Cert $cert -FilePath "C:\Users\username\Desktop\$certname.pfx" -Password $mypwd   ## Specify your preferred location