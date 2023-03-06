## Creates OS Config assignment in a Zone. Applies automation to SQL servers that have
## enable OSConfig metadata tag and osconfig label
resource "google_os_config_os_policy_assignment" "sql_backup" {
  ##depends_on = [module.tandem_app_svc_acc_dev]
  instance_filter {
    all = false
    inclusion_labels {
      labels = {
        osconfig = "sql"
      }
    }
  }


  location = var.zone
  name     = var.os_sql_policy_assignment_name
  os_policies {
    id   = "cna-sql-sys-policy"
    mode = "ENFORCEMENT"
    resource_groups {
      resources {
        id = "install-maint-plan-sys"
        exec {
          validate {
            interpreter = "POWERSHELL"
            script      = <<EOT
              if ((Get-DbaAgentJob -SqlInstance $env:ComputerName -Job "DatabaseBackup - SYSTEM_DATABASES - FULL").JobID -ne $null)
              {exit 100}
              else
              {exit 101}
              EOT
          }
          enforce {
            interpreter = "POWERSHELL"
            script      = <<EOT
              $sysdb = Get-DbaDatabase -SQLInstance $env:ComputerName -Database master
              $params = @{
              SqlInstance = $env:ComputerName
              Database = $sysdb.name
              ReplaceExisting = $true
              InstallJobs = $true
              LogToTable = $true
              BackupLocation = 'N:\'
              CleanupTime = 176
              Verbose = $true
              InstallParallel = $true
              LocalFile = 'C:\sqlmaintenancesolution.zip'
              }
              Install-DBAMaintenanceSolution @params 6>&1 2>&1 >> C:\scriptsys.txt
              Start-DbaAgentJob -sqlinstance $env:computername -Job "DatabaseBackup - SYSTEM_DATABASES - FULL"
              exit 100
            EOT
          }
        }
      }
      resources {
        id = "config-sql-backup-sched"
        exec {
          validate {
            interpreter = "POWERSHELL"
            script      = <<EOT
              $systemdbjob = 'DatabaseBackup - SYSTEM_DATABASES - FULL'
              if ((Get-DbaAgentJob -sqlinstance $env:computername -job $systemdbjob).HasSchedule -eq $true) {exit 100} else {exit 101}
              EOT
          }
          enforce {
            interpreter = "POWERSHELL"
            script      = <<EOT
              $systemdbjob = 'DatabaseBackup - SYSTEM_DATABASES - FULL'
              New-DbaAgentSchedule -SQLInstance $env:Computername `
              -Schedule SysDBBK `
              -FrequencyType Daily `
              -Starttime "170000" `
              -job $systemdbjob `
              -Force
              exit 100
              EOT
          }
        }
      }
      resources {
        id = "gcs-script-sys"
        exec {
          validate {
            interpreter = "POWERSHELL"
            script      = <<EOT
              if ((Test-path N:\script\GCSsys.ps1) -eq $True) {exit 100} else {exit 101}
              EOT
          }
          enforce {
            interpreter = "POWERSHELL"
            script      = <<EOT
              $commanddb = @"
              `$sysdbs=(Get-DbaDatabase -sqlinstance $env:computerName -Database master,model,msdb).name
              foreach (`$db in `$sysdbs) {
              Set-Location N:\$env:computername\`$db\FULL `n
              gsutil -m cp -n -r . gs://${var.gcs_sql_bkt_full}/sqlbackups/$env:computername/`$db/FULL/
              }
              "@
              if (Test-Path N:\script) {
              $commanddb > N:\script\GCSsys.ps1
              exit 100
              }
              elseif ((Test-Path N:\Script) -eq $false){
              mkdir N:\script
              $commanddb > N:\script\GCSsys.ps1
              exit 100
              }
              else {exit 101}
            EOT
          }
        }
      }

      resources {
        id = "gcs-upload-configure-sysdb"
        exec {
          validate {
            interpreter = "POWERSHELL"
            script      = <<EOT
              if  ((Get-DbaAgentJobStep -SQLInstance $env:computerName -Job "DatabaseBackup - SYSTEM_DATABASES - FULL").count -gt 1)
              {exit 100} else {exit 101}
              EOT
          }
          enforce {
            interpreter = "POWERSHELL"
            script      = <<EOT
              $jobstep = @"
              powershell.exe -File N:\script\GCSsys.ps1 -ExecutionPolicy Bypass
              "@
              $systemdbjob = "DatabaseBackup - SYSTEM_DATABASES - FULL"
              Set-DbaAgentJobStep -SqlInstance $env:ComputerName `
              -Job $systemdbjob `
              -StepName $systemdbjob `
              -OnSuccessAction GoToNextStep
              New-DbaAgentJobStep -SQLInstance $env:computername `
              -StepName 'Upload to GCS' `
              -StepId 2 `
              -Job $systemdbjob `
              -SubSystem Powershell `
              -Command $jobstep `
              -Force
              exit 100
              EOT
          }
        }
      }
      resources {
        id = "cconfigure-sysdb-notifications"
        exec {
          validate {
            interpreter = "POWERSHELL"
            script      = <<EOT
              if  ((Get-DbaAgentJob -SQLInstance $env:computerName -Job "DatabaseBackup - SYSTEM_DATABASES - FULL").EventLogLevel -eq "Always")
              {exit 100} else {exit 101}
              EOT
          }
          enforce {
            interpreter = "POWERSHELL"
            script      = <<EOT
              $systemdbjob = 'DatabaseBackup - SYSTEM_DATABASES - FULL'
              Set-DbaAgentJob -SQLInstance $env:computerName -job $systemdbjob -EventLogLevel Always -Enabled
              exit 100
              EOT
          }
        }
      }
    }
  }

  os_policies {
    id   = "cna-sql-userdb-policy"
    mode = "ENFORCEMENT"
    resource_groups {
      resources {
        id = "install-maint-plan-userdb"
        exec {
          validate {
            interpreter = "POWERSHELL"
            script      = <<EOT
              if ((Get-DbaAgentJob -SqlInstance $env:ComputerName -Job "DatabaseBackup - USER_DATABASES - FULL").JobID -ne $null)
              {exit 100}
              else
              {exit 101}
              EOT
          }
          enforce {
            interpreter = "POWERSHELL"
            script      = <<EOT
              import-module dbatools
              $userdb = Get-DbaDatabase -SQLInstance $env:ComputerName -ExcludeSystem | select -first 1
              $params = @{
              SqlInstance = $env:ComputerName
              Database = $userdb.name
              ReplaceExisting = $false
              InstallJobs = $true
              LogToTable = $true
              BackupLocation = 'N:\'
              CleanupTime = 1080
              Verbose = $true
              InstallParallel = $true
              LocalFile = 'C:\sqlmaintenancesolution.zip' }
              Install-DBAMaintenanceSolution @params 6>&1 2>&1 >> C:\scriptuser.txt
              Start-DbaAgentJob -sqlinstance $env:computername -job "DatabaseBakckup - USER_DATABASES - FULL"
              exit 100
              EOT
          }
        }
      }
      resources {
        id = "userdb-check-bk"
        exec {
          validate {
            interpreter = "POWERSHELL"
            script      = <<EOT
            if ((Get-DbaAgentJob -SqlInstance $env:COMPUTERNAME -Job "DatabaseBackup - USER_DATABASES - FULL").LastRunDate -gt (Get-Date).AddDays(-7)) {exit 100} else {exit 101}
            EOT
          }
          enforce {
            interpreter = "POWERSHELL"
            script      = <<EOT
            Start-DbaAgentJob -sqlinstance $env:computername -job "DatabaseBakckup - USER_DATABASES - FULL"
            exit 100
            EOT
          }
        }
      }
      resources {
        id = "config-sql-backup-userdb"
        exec {
          validate {
            interpreter = "POWERSHELL"
            script      = <<EOT
              $userdbjob = 'DatabaseBackup - USER_DATABASES - FULL'
              if ((Get-DbaAgentJob -sqlinstance $env:computername -job $userdbjob).HasSchedule -eq $true) {exit 100} else {exit 101}
              EOT
          }
          enforce {
            interpreter = "POWERSHELL"
            script      = <<EOT
              $userdbjob = "DatabaseBackup - USER_DATABASES - FULL"
              New-DbaAgentSchedule -SQLInstance $env:Computername `
              -Schedule UserDBBK `
              -FrequencyType Weekly `
              -Starttime "173000" `
              -job $userdbjob `
              -Force
              exit 100
              EOT
          }
        }
      }
      resources {
        id = "config-sql-backup-diff"
        exec {
          validate {
            interpreter = "POWERSHELL"
            script      = <<EOT
              $userlogjob = 'DatabaseBackup - USER_DATABASES - DIFF'
              if ((Get-DbaAgentJob -sqlinstance $env:computername -job $userlogjob).HasSchedule -eq $true) {exit 100} else {exit 101}
              EOT
          }
          enforce {
            interpreter = "POWERSHELL"
            script      = <<EOT
              $userdiffjob = 'DatabaseBackup - USER_DATABASES - DIFF'
              New-DbaAgentSchedule -SQLInstance $env:Computername `
              -Schedule DBDIFFBK `
              -FrequencyType Daily `
              -FrequencyInterval Everday `
              -Starttime '170000' `
              -job $userdiffjob `
              -Force
              exit 100
              EOT
          }
        }
      }
      resources {
        id = "gcs-script-full"
        exec {
          validate {
            interpreter = "POWERSHELL"
            script      = <<EOT
              if ((Test-path N:\script\GCSfull.ps1) -eq $True) {exit 100} else {exit 101
              EOT
          }
          enforce {
            interpreter = "POWERSHELL"
            script      = <<EOT
              $commanddb = @"
              `$userdbs=(Get-DbaDatabase -sqlinstance $env:computerName -ExcludeSystem).name
              foreach (`$db in `$userdbs) {
              Set-Location N:\$env:computername\`$db\FULL `n
              gsutil -m cp -n -r . gs://${var.gcs_sql_bkt_full}/sqlbackups/$env:computername/`$db/FULL/
              }
              "@
              if (Test-Path N:\script) {
              $commanddb > N:\script\GCSfull.ps1
              exit 100
              }
              elseif ((Test-Path N:\script) -eq $false){
              mkdir N:\script
              $commanddb > N:\script\GCSfull.ps1
              exit 100
              }
              else {exit 101}
              EOT
          }
        }
      }
      resources {
        id = "gcs-upload-configure-usrdb"
        exec {
          validate {
            interpreter = "POWERSHELL"
            script      = <<EOT
              if  ((Get-DbaAgentJobStep -SQLInstance $env:computerName -Job "DatabaseBackup - USER_DATABASES - FULL").count -gt 1)
              {exit 100} else {exit 101}
              EOT
          }
          enforce {
            interpreter = "POWERSHELL"
            script      = <<EOT
              $jobstep = @"
              powershell.exe -File N:\script\GCSfull.ps1 -ExecutionPolicy Bypass
              "@
              $userdbjob = "DatabaseBackup - USER_DATABASES - FULL"
              Set-DbaAgentJobStep -SqlInstance $env:ComputerName `
              -Job $userdbjob `
              -StepName $userdbjob `
              -OnSuccessAction GoToNextStep
              New-DbaAgentJobStep -SQLInstance $env:computername `
              -StepName 'Upload to GCS' `
              -StepId 2 `
              -Job $userdbjob `
              -SubSystem Powershell `
              -Command $jobstep `
              -Force
              exit 100
              EOT
          }
        }
      }
      resources {
        id = "gcs-script-diff"
        exec {
          validate {
            interpreter = "POWERSHELL"
            script      = <<EOT
              if ((Test-path N:\script\GCSdiff.ps1) -eq $True) {exit 100} else {exit 101}
              EOT
          }
          enforce {
            interpreter = "POWERSHELL"
            script      = <<EOT
              $commanddb = @"
              `$userdbs=(Get-DbaDatabase -sqlinstance $env:computerName -ExcludeSystem).name
              foreach (`$db in `$userdbs) {
              Set-Location N:\$env:computername\`$db\DIFF `n
              gsutil -m cp -n -r . gs://${var.gcs_sql_bkt_diff}/sqlbackups/$env:computername/`$db/DIFF/
              }
              "@
              if (Test-Path N:\script)  {
              $commanddb > N:\script\GCSdiff.ps1
              exit 100
              }
              elseif ((Test-Path N:\script) -eq $false){
              mkdir N:\script
              $commanddb > N:\script\GCSdiff.ps1
              exit 100
              }
              else {exit 101}
              EOT
          }
        }
      }
      resources {
        id = "gcs-upload-configure-usr-diff"
        exec {
          validate {
            interpreter = "POWERSHELL"
            script      = <<EOT
              if  ((Get-DbaAgentJobStep -SQLInstance $env:computerName -Job "DatabaseBackup - USER_DATABASES - DIFF").count -gt 1)
              {exit 100} else {exit 101}
              EOT
          }
          enforce {
            interpreter = "POWERSHELL"
            script      = <<EOT
              $userdiffjob = "DatabaseBackup - USER_DATABASES - DIFF"
              $jobstep = @"
              powershell.exe -File N:\script\GCSdiff.ps1 -ExecutionPolicy Bypass
              "@
              Set-DbaAgentJobStep -SqlInstance $env:ComputerName `
              -Job $userdiffjob `
              -StepName $userdiffjob `
              -OnSuccessAction GoToNextStep
              New-DbaAgentJobStep -SQLInstance $env:computername `
              -StepName 'Upload to GCS' `
              -StepId 2 `
              -Job $userdiffjob `
              -SubSystem Powershell `
              -Command $jobstep `
              -Force
              exit 100
            EOT
          }
        }
      }
      resources {
        id = "configure-userdb-notifications"
        exec {
          validate {
            interpreter = "POWERSHELL"
            script      = <<EOT
              if  ((Get-DbaAgentJob -SQLInstance $env:computerName -Job "DatabaseBackup - USER_DATABASES - FULL").EventLogLevel -eq "Always")
              {exit 100} else {exit 101}
              EOT
          }
          enforce {
            interpreter = "POWERSHELL"
            script      = <<EOT
              $userdbjob = 'DatabaseBackup - USER_DATABASES - FULL'
              Set-DbaAgentJob -SQLInstance $env:computerName -job $userdbjob -EventLogLevel Always
              exit 100
            EOT
          }
        }
      }
      resources {
        id = "configure-userdiff-notifications"
        exec {
          validate {
            interpreter = "POWERSHELL"
            script      = <<EOT
              if  ((Get-DbaAgentJob -SQLInstance $env:computerName -Job "DatabaseBackup - USER_DATABASES - DIFF").EventLogLevel -eq "Always")
              {exit 100} else {exit 101}
            EOT
          }
          enforce {
            interpreter = "POWERSHELL"
            script      = <<EOT
              $userdiffjob = 'DatabaseBackup - USER_DATABASES - DIFF'
              Set-DbaAgentJob -SQLInstance $env:computerName -job $userdiffjob -EventLogLevel Always
              exit 100
            EOT
          }
        }
      }
    }
  }

  os_policies {
    id   = "cna-sql-bk-retention-policy"
    mode = "ENFORCEMENT"
    resource_groups {
      resources {
        id = "sql-bk-full-retention"
        exec {
          validate {
            interpreter = "POWERSHELL"
            script      = <<EOT
              $job = "DatabaseBackup - USER_DATABASES - FULL"
              $cmd=(Get-DbaAgentJobStep -SqlInstance $env:COMPUTERNAME -Job $job).properties| ? name -eq "Command" | select -ExpandProperty value -First 1
              if ($cmd -match '1080') {exit 100} else {exit 101}}
              EOT
          }
          enforce {
            interpreter = "POWERSHELL"
            script      = <<EOT
              $job = "DatabaseBackup - USER_DATABASES - FULL"
              $cmd=@"
              EXECUTE [dbo].[DatabaseBackup] `n
              @Databases = 'USER_DATABASES', `n
              @Directory = N'N:\', `n
              @BackupType = 'FULL', `n
              @Verify = 'Y', `n
              @CheckSum = 'Y', `n
              @LogToTable = 'Y', `n
              @CleanupTime=1080
              "@
              Set-DbaAgentJobStep -SqlInstance $env:COMPUTERNAME -Job $job -StepName $job -Command $cmd
              exit 100
              EOT
          }
        }
      }
    }
  }

  rollout {
    disruption_budget {
      percent = "50"
    }
    min_wait_duration = "3.5s"
  }

}