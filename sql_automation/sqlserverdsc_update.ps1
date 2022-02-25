$User = "sa"
$pass = "Password1234"
$MyCredential=New-Object -TypeName System.Management.Automation.PSCredential `
 -ArgumentList $User, (ConvertTo-SecureString -asplaintext -force $pass)
 


Configuration SQLInstall
{
  
  Import-DscResource -ModuleName SqlServerDsc,PSDesiredStateConfiguration,StorageDSC,SQLServer 
  
    node localhost
    {
        WaitForDisk Disk1
        {
             DiskId = 1
             RetryIntervalSec = 60
             RetryCount = 60
        }

        Disk DVolume
        {
             DiskId = 1
             DriveLetter = 'D'
             Size = 24GB
             FSLabel = 'Data'
             DependsOn = '[WaitForDisk]Disk1'
        }

        WaitForDisk Disk2
        {
             DiskId = 2
             RetryIntervalSec = 60
             RetryCount = 60
        }

        Disk EVolume
        {
             DiskId = 2
             DriveLetter = 'E'
             Size = 24GB
             FSLabel = 'SQL Backups'
             DependsOn = '[WaitForDisk]Disk2'
        }


	    WindowsFeature 'NetFramework45'
         {
              Name   = 'NET-Framework-45-Core'
              Ensure = 'Present'
         }

         File CreateDataDir {
            DestinationPath = 'D:\SQL2016\SQLData\'
            Ensure          = 'Present'
            Type            = 'Directory'
         }
         
         File CreateLogDir {
            DestinationPath = 'D:\SQL2016\SQLLogs\'
            Ensure          = 'Present'
            Type            = 'Directory'
        }

        File CreateBackupDir {
            DestinationPath = 'E:\SQL_Backups\'
            Ensure          = 'Present'
            Type            = 'Directory'
        }
      
        SqlSetup InstallDefaultInstance
         {
              InstanceName        = 'MSSQLSERVER'
              Features            = 'SQLENGINE'
              SourcePath          = 'C:\SQL2016'
              SQLUserDBDir        = 'D:\SQL2016\SQLData'
              SQLUserDBLogDir     = 'D:\SQL2016\SQLLogs'
              SQLBackupDir        = 'E:\SQL_Backups\'
              InstallSQLDataDir   = 'D:\SQL2016\SQLData'
              SQLSysAdminAccounts = @('Administrators')
              SAPwd	              = $MyCredential
	          SecurityMode        = 'SQL'
              TCPEnabled          = $true
              AgtSvcStartupType   = 'Automatic'
              DependsOn           = '[WindowsFeature]NetFramework45'       
         }

         SQLDatabase CreateDbaDatabase {
             DependsOn = '[Sqlsetup]InstallDefaultInstance'
             ServerName = $Node.NodeName
             InstanceName = 'MSSQLSERVER'
             Name         = 'AdventureWorks2016'
             RecoveryModel = 'Full'
         }
    }
  
}

$cd = @{
	AllNodes = @(
	@{
		NodeName = 'localhost'
		PSDscAllowPlainTextPassword = $true
	}
       )
     } 
SQLInstall -Output C:\DSC_MOF\ -ConfigurationData $cd
