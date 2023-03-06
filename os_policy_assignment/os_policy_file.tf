##Upload objects
/*resource "google_storage_bucket_object" "dbatools" {
  name   = "dbatools.zip"
  source = "./dbatools.zip"
  bucket = var.gcs_media_bkt
}
resource "google_storage_bucket_object" "sqlmaintenancesolution" {
  name   = "sqlmaintenancesolution.zip"
  source = "./sqlmaintenancesolution.zip"
  bucket = var.gcs_media_bkt
}
*/
##create policy to copy objects to OS
resource "google_os_config_os_policy_assignment" "sql_tools" {
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
  name     = var.os_file_policy_assignment_name
  os_policies {
    id   = "copy-modules"
    mode = "ENFORCEMENT"
    resource_groups {
      resources {
        id = "dbatools-copy"
        ## Checks if the DBATOOLS module is installed in the OS
        exec {
          validate {
            interpreter = "POWERSHELL"
            script      = <<EOF
            If ((Get-Modules -ListAvailable DBAtools).exportedcommands.count -gt 1) {exit 100} else {echo 101}
            EOF
          }
          enforce {
            ## Installs Module to Powershell System Path. 
            interpreter = "POWERSHELL"
            script      = <<EOF
            gsutil cp gs://${var.gcs_media_bkt}/modules/dbatools.zip C:\modules\dbatools.zip
            mkdir "C:\Program Files\WindowsPowershell\Moduels\dbatools"
            Expand-Archive -LiteralPath 'C:\modules\dbatools.zip' -DestinationPath 'C:\Program Files\WindowsPowershell\Modules\dbatools'
            Get-ChildItem 'C:\Program Files\WindowsPowershell\Modules\dbatools' -recurse |Unblock-File
            EOF
          }
        }
      }
      ## Checks if the SQL Maintenance solution ZIP file is present. 
      resources {
        id = "sqlmaintenancesolution-copy"
        file {
          state = "PRESENT"
          file {
            allow_insecure = true
            gcs {
              bucket = var.gcs_media_bkt
              object = "modules/sqlmaintenancesolution.zip"
            }
          }
          path = "C:\\sqlmaintenancesolution.zip"
        }
      }
    }
  }
  rollout {
    disruption_budget {
      percent = 100
    }
    min_wait_duration = "60s"
  }
}