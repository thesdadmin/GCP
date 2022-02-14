## sql-automate

Creates a new Windows Core server and installs SQL Server. Then restores the database from a backup.

### Usage
`terraform.tfvars`
```hcl
project          = "your-project-name"
subnet           = "default"
image_project    = "windows-cloud"
vpc_project      = "your-project-name"
windows_vm_image = "windows-server-2019-dc-core-v20220210"
vm_size          = "n1-standard-2"
region           = "us-central1"
db_name          = "yourdb"
db_user          = "aman_w"
db_user_pass     = "rH}w9KWc31s+"
bucket           = "your-bucket-name"
```
