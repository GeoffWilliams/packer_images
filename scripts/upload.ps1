# This script equivalent to one line BASH+curl script
#
# supply on command line:
# -Artifact hyper-v_alma_8.10
# -Release 0

param(
    [string]$Artifact,
    [string]$Release,
    [string]$BuildDir = "D:\packer"
)

$Username = "hyperv"
$Password = Get-Content -Raw $HOME\.nexus_password.txt
$URL = "https://nexus.infrastructure.asio:8443/repository/raw"

$Base64Auth = [Convert]::ToBase64String([Text.Encoding]::ASCII.GetBytes("$Username`:$Password"))
$Headers = @{
    Authorization = "Basic $Base64Auth"
}

$UploadUrl = "$URL/hyperv/$Artifact-$Release.vhdx"
write-host "Uploading $UploadUrl"

$ProgressPreference = 'SilentlyContinue'
Invoke-RestMethod -Uri $UploadUrl `
    -Method Put `
    -Headers $Headers `
    -InFile "$BuildDir\builds\$Artifact\Virtual Hard Disks\$Artifact.vhdx"`
    -SkipCertificateCheck