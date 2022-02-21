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

### Concourse CI
You can run this pipeline in Concourse CI by using the following command:
```
docker-compose up -d
fly -t tutorial set-pipeline -p sql -c job.yml -n  &&  \
  fly -t tutorial trigger-job --job sql/restore-job --watch
```
You will need to set `((gcp.*))` instances in `job.yml` file to actual values you want to use in Terraform.

Follow the guide on [vault credential manager](https://concourse-ci.org/vault-credential-manager.html)
section `Configuring the secrets engine` to set up your own Vault instance.