Set-ExecutionPolicy Bypass
Start-Transcript
## Install .NET Core 2.0
Invoke-WebRequest "https://dot.net/v1/dotnet-install.ps1" -OutFile "./dotnet-install.ps1"
./dotnet-install.ps1 -Channel 2.0 -InstallDir c:\dotnet

# Install chocolately to be able to install git
Invoke-WebRequest 'https://chocolatey.org/install.ps1' -OutFile "./choco-install.ps1"
./choco-install.ps1

# Install Git with choco
#choco install git nssm openssh -y -f
#choco install openssh -y -f

# Install ssh for admin puproses
#cd "C:\Program Files\OpenSSH-Win64"
#./install-sshd.ps1
#Set-service sshd -StartupType Automatic
#Start-Service sshd

Write-Output "SSH installing..."
Add-WindowsCapability -Online -Name OpenSSH.Server~~~~0.0.1.0
# Start the sshd service
Start-Service sshd

# OPTIONAL but recommended:
Set-Service -Name sshd -StartupType 'Automatic'
Write-Output "SSH installed!!"

# Confirm the Firewall rule is configured. It should be created automatically by setup. Run the following to verify
if (!(Get-NetFirewallRule -Name "OpenSSH-Server-In-TCP" -ErrorAction SilentlyContinue | Select-Object Name, Enabled)) {
    Write-Output "Firewall Rule 'OpenSSH-Server-In-TCP' does not exist, creating it..."
    New-NetFirewallRule -Name 'OpenSSH-Server-In-TCP' -DisplayName 'OpenSSH Server (sshd)' -Enabled True -Direction Inbound -Protocol TCP -Action Allow -LocalPort 22
} else {
    Write-Output "Firewall rule 'OpenSSH-Server-In-TCP' has been created and exists."
}

#Install sql server
mkdir c:\tmp\
gsutil cp gs://${backup_bucket}/SQLServer2016SP2-FullSlipstream-x64-ENU.iso C:\tmp\
Mount-DiskImage -ImagePath C:\tmp\SQLServer2016SP2-FullSlipstream-x64-ENU.iso -StorageType ISO -PassThru
d:
echo '[OPTIONS]
ACTION="Install"
FEATURES=SQLENGINE
INSTANCENAME="MSSQLSERVER"
INSTANCEID="MSSQLSERVER"
SQLSVCACCOUNT="NT Service\MSSQLSERVER"
SQLSYSADMINACCOUNTS="${db_user}"
IAcceptSQLServerLicenseTerms="True"' > c:\install.ini
.\setup.exe /Q /ConfigurationFile=c:\install.ini

#verify installation
.\setup.exe /Action=RunDiscovery /q
Set-Service SQLSERVERAGENT -StartupType Automatic
Start-Service SQLSERVERAGENT

# import sqlserver module
gsutil cp gs://${backup_bucket}/sqlserver.21.1.18257-preview.nupkg .
Move-Item -Path .\sqlserver.21.1.18257.nupkg -Destination .\sqlserver.21.1.18257.zip
Expand-Archive -Path .\sqlserver.21.1.18257.zip
New-Item -Path $env:ProgramFiles\powershell\7\Modules\SqlServer -ItemType Directory
Move-Item -Path .\sqlserver.21.1.18257 -Destination .\21.1.18257
Move-Item -Path .\21.1.18257 -Destination $env:ProgramFiles\powershell\7\Modules\SqlServer
dir $env:ProgramFiles\powershell\7\Modules\SqlServer
Write-Output "SqlServer module installed"

#Install-Module -Name SqlServer -force

# get db backup from gcs
gsutil cp gs://${backup_bucket}/${db_name}.bak "C:\Program Files\Microsoft SQL Server\MSSQL13.MSSQLSERVER\MSSQL\Backup\${db_name}.bak"

# restore db
Restore-SqlDatabase -ServerInstance localhost -BackupFile ${db_name}.bak -Database ${db_name}
Get-SqlDatabase -ServerInstance localhost > c:\db_list.txt
Invoke-Sqlcmd -ServerInstance localhost -Database ${db_name} -Query "select * from invokeTable" > c:\invokeTable.txt