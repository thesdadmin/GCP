Configuration SQLInstall
{

    param(
    	[Parameter(Mandatory)]
	[PSCredential]$Password
    )

    Import-DscResource -ModuleName SqlServerDsc
    Import-DSCResource -ModuleName PSDesiredStateConfiguration
     
     
    node localhost
    {
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
              SAPwd	              = $Password
	          SecurityMode        = 'SQL'
              TCPEnabled          = $true
              DependsOn           = '[WindowsFeature]NetFramework45'       
         }

         SQLDatabase CreateDbaDatabase {
             DependsOn = '[Sqlsetup]InstallDefaultInstance'
             ServerName = $Node.NodeName
             InstanceName = 'MSSQLSERVER'
             Name         = 'AdventureWorks2016'
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
