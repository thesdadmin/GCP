Install-PackageProvider -Name NuGet -MinimumVersion 2.8.5.201 -Force
Set-PSRepository -Name 'PSGallery' -InstallationPolicy Trusted
Find-module  Dbatools,SQLServer,SqlServerDsc,PSDesiredStateConfiguration,StorageDSC | install-module -scope AllUsers -Force
gsutil cp gs://lab_iso/sqlserverdsc.ps1 C:\sqlserverdsc.ps1
gsutil cp gs://lab_iso/sql2016.iso C:\sql2016.iso
mkdir C:\SQL2016
$mountResult = Mount-DiskImage -ImagePath 'C:\sql2016.iso' -PassThru
$volumeInfo = $mountResult | Get-Volume
$driveInfo = Get-PSDrive -Name $volumeInfo.DriveLetter
Copy-Item -Path ( Join-Path -Path $driveInfo.Root -ChildPath '*' ) -Destination C:\SQL2016\ -Recurse
Dismount-DiskImage -ImagePath 'C:\sql2016.iso'
New-Item -Type file C:\ospolicy_log.txt
New-Item -Type Directory C:\DSC_MOF

pwsh.exe C:\sqlserverdsc.ps1
pwsh.exe -Command "Start-DSCConfiguration -path C:\DSC_MOF -Wait -Verbose"