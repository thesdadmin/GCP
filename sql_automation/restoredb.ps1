## Restore Dbabase

1. gsutil cp gs://somebucket/somefolder/somesqlbackup.bk E:\SOMEDIRECTORY\somesqlbackup.bk

##Import the DBATOOLS module and run the script
2. Import-Module DBATOOLS


##If Database uses certificate encryption for SQL backups, if not, skip to step 5
##Steps are simpler if using PWSH 7.2
3. $securepass = Get-Credential usernamedoesntmatter | Select-Object -ExpandProperty Password
4. Restore-DbaDbCertificate -SqlInstance Server1 -Path \\Server1\Certificates -DecryptionPassword $securepass

##Restore the Database
## If SQL instance is the default "MSSQLSERVER" use the server's computer name for the SqlInstance property

Restore-DbaDatabase -SqlInstance server1\instance1 -Path \\server2\backups
