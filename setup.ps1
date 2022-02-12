Start-Transcript
## Install .NET Core 2.0
Invoke-WebRequest "https://dot.net/v1/dotnet-install.ps1" -OutFile "./dotnet-install.ps1"
./dotnet-install.ps1 -Channel 2.0 -InstallDir c:\dotnet

# Install Post-Git
#Write-host "Installing Posh-Git"
#Install-PackageProvider -Name NuGet -MinimumVersion 2.8.5.201 -force

# Install chocolately to be able to install git
Invoke-WebRequest 'https://chocolatey.org/install.ps1' -OutFile "./choco-install.ps1"
./choco-install.ps1

# Install Git with choco
choco install git -y
choco install openssh -y -f
cd "C:\Program Files\OpenSSH-Win64"
./install-sshd.ps1
Set-service sshd -StartupType Automatic
Start-Service sshd
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
.\setup.exe /Action=RunDiscovery /q #verify
Set-Service SQLSERVERAGENT -StartupType Automatic
Start-Service SQLSERVERAGENT

Restart-Computer

Invoke-Sqlcmd -ServerInstance localhost
   2 cat C:\install.ini
   3 $connectionString = 'Data Source={0};database={1};User ID={2};Password={3}' -f $ServerName,$DatabaseName,$userN...
   4 $sqlConnection = New-Object System.Data.SqlClient.SqlConnection $connectionString
   5 $sqlConnection.Open()
   6 Invoke-Sqlcmd -Query "CREATE DATABASE YourDB" -ServerInstance YourInstance
   7 Invoke-Sqlcmd -Query "CREATE DATABASE YourDB" -ServerInstance localhost
   8 Invoke-Sqlcmd -Query "CREATE DATABASE YourDB" -ServerInstance localhost
   9 Invoke-Sqlcmd -Query "show databases" -ServerInstance localhost
  10 Invoke-Sqlcmd -Query "select databases" -ServerInstance localhost
  11 gsutil ls
  12 gsutil cp gs://router-image-vmdk/employees.sql .
  13 Restore-SqlDatabase -ServerInstance localhost -Database YourDB -BackupFile .\employees.sql
  14 Restore-SqlDatabase -ServerInstance localhost -Database YourDB -BackupFile \\employees.sql
  15 Restore-SqlDatabase -ServerInstance localhost -Database YourDB -BackupFile \\employees.sql
  16 move .\employees.sql c:\
  17 Restore-SqlDatabase -ServerInstance localhost -Database YourDB -BackupFile c:\employees.sql
  18 Invoke-Sqlcmd -InputFile C:\employees.sql -ServerInstance localhost -Database YourDB
  19 Invoke-Sqlcmd -Query "CREATE DATABASE employees" -ServerInstance localhost
  20 Invoke-Sqlcmd -InputFile C:\employees.sql -ServerInstance localhost -Database YourDB
  21 Invoke-Sqlcmd -ServerInstance localhost -Database YourDB
71 Invoke-Sqlcmd -ServerInstance localhost -Database YourDB -Query $values
  72 echo $values
  73 vim .\values.sql
  74 $values=$(cat .\values.sql)
  75 Invoke-Sqlcmd -ServerInstance localhost -Database YourDB -Query $values
  76 vim .\values.sql
  77 $values=$(cat .\values.sql)
  78 Invoke-Sqlcmd -ServerInstance localhost -Database YourDB -Query $values
  79 vim .\values.sql
  80 vim .\values.sql
  81 $values=$(cat .\values.sql)
  82 Invoke-Sqlcmd -ServerInstance localhost -Database YourDB -Query $values
  83 vim .\values.sql
  84 $values=$(cat .\values.sql)
  85 Invoke-Sqlcmd -ServerInstance localhost -Database YourDB -Query $values
  86 cat .\values.sql
  87 Invoke-Sqlcmd -ServerInstance localhost -Database YourDB -Query INSERT INTO employees VALUES (10001,'1953-09-02...
  88 Invoke-Sqlcmd -ServerInstance localhost -Database YourDB -Query "NSERT INTO employees VALUES (10001,'1953-09-02...
  89 Invoke-Sqlcmd -ServerInstance localhost -Database YourDB -Query  "INSERT INTO employees VALUES (10001,'1953-09-...
  90 cat .\values.sql
  91 Backup-SqlDatabase -ServerInstance localhost -Database YourDB
  92 dir
  93 Backup-SqlDatabase -ServerInstance localhost -Database YourDB -BackupFile c:\mainDB.bak
  94 Backup-SqlDatabase -ServerInstance localhost -Database YourDB -BackupFile \mainDB.bak
 100 Backup-SqlDatabase -ServerInstance localhost -Database YourDB -BackupFile \mainDB.bak
 101 Backup-SqlDatabase -ServerInstance localhost -Database YourDB -BackupFile ./inDB.bak
 102 dir
 103 Backup-SqlDatabase -ServerInstance localhost -Database YourDB -BackupFile C:\Users\aman_wolde\main.bak
 104 dir /s
 105 find .
 106 find /
 107 find
 108 find c:
 109  cd '.\Program Files\Microsoft SQL Server'
 110 dir
 111 cd .\MSSQL13.MSSQLSERVER
 112 dir
 113 cd .\MSSQL
 114 dir
 115 cd .\Backup
 116 dir
Invoke-Sqlcmd -ServerInstance localhost -Query  "drop database YourDB"
