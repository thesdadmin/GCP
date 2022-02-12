Start-Transcript
## Install .NET Core 2.0
Invoke-WebRequest "https://dot.net/v1/dotnet-install.ps1" -OutFile "./dotnet-install.ps1"
./dotnet-install.ps1 -Channel 2.0 -InstallDir c:\dotnet

# Install chocolately to be able to install git
Invoke-WebRequest 'https://chocolatey.org/install.ps1' -OutFile "./choco-install.ps1"
./choco-install.ps1

# Install Git with choco
choco install git -y
choco install openssh -y -f

# Install ssh for admin puproses
cd "C:\Program Files\OpenSSH-Win64"
./install-sshd.ps1
Set-service sshd -StartupType Automatic
Start-Service sshd

#Install sql server
gsutil cp gs://router-image-vmdk/SQLServer2016SP2-FullSlipstream-x64-ENU.iso C:\Users\aman_wolde\Downloads\
Mount-DiskImage -ImagePath C:\Users\aman_wolde\Downloads\SQLServer2016SP2-FullSlipstream-x64-ENU.iso  -StorageType ISO -PassThru
d:
echo '[OPTIONS]
ACTION="Install"
FEATURES=SQLENGINE
INSTANCENAME="MSSQLSERVER"
INSTANCEID="MSSQLSERVER"
SQLSVCACCOUNT="NT Service\MSSQLSERVER"
SQLSYSADMINACCOUNTS="aman_wolde"
IAcceptSQLServerLicenseTerms="True"' > c:\install.ini
.\setup.exe /QS  /ConfigurationFile=c:\install.ini

#verify installation
.\setup.exe /Action=RunDiscovery /q
Set-Service SQLSERVERAGENT -StartupType Automatic
Start-Service SQLSERVERAGENT

# import sqlserver module
Install-Module -Name SqlServer -force

# get db backup from gcs
gsutil cp gs://router-image-vmdk/yourdb.bak "C:\Program Files\Microsoft SQL Server\MSSQL13.MSSQLSERVER\MSSQL\Backup\yourdb.bak"

# restore db
Restore-SqlDatabase -ServerInstance localhost -BackupFile yourdb.bak -Database YourDB
Get-SqlDatabase -ServerInstance localhost
Invoke-Sqlcmd -ServerInstance localhost -Database YourDB -Query "select * from invokeTable"
Restart-Computer


Invoke-Sqlcmd -ServerInstance localhost -Database YourDB -Query "CREATE TABLE invokeTable (Id TINYINT, IdData VARCHAR(5))"
Invoke-Sqlcmd -ServerInstance localhost -Database YourDB -Query "INSERT INTO invokeTable VALUES (1,'A'), (2,'B'), (3,'C'), (4,'E'),(5,'F')"
Invoke-Sqlcmd -ServerInstance localhost -Query  "drop database YourDB"
Invoke-Sqlcmd -ServerInstance localhost -Query "USE master; ALTER DATABASE YourDB SET SINGLE_USER WITH ROLLBACK IMMEDIATE; DROP DATABASE YourDB"
Restore-SqlDatabase -ServerInstance localhost -BackupFile .\yourdb.bak -Database YourDB
Get-SqlDatabase -ServerInstance localhost
Invoke-Sqlcmd -ServerInstance localhost -Database YourDB -Query "select * from invokeTable"