$ErrorActionPreference = "Stop"
function Add-LabVM {
    param (
        [string]$VMName,
        [int64]$MemorySize
    )
    $VMVhdx = "D:\hyper-v\vhds\$VMName.vhdx"
    write-host "=================[$VMName]================="

    if (! (Test-Path $VMVhdx)) {
        Write-Host "copy hardrive to $VMVhdx"
        Copy-Item "D:\packer\builds\packer-alma89\Virtual Hard Disks\packer-alma89.vhdx" -Destination $VMVhdx
    }

    if (! (Get-VM -Name $VMName -ErrorAction SilentlyContinue)) {
        Write-Host "create VM $VMName, memory: $MemorySize"
        New-VM -Name $VMName -MemoryStartupBytes $MemorySize -Path "D:\hyper-v\vms\Virtual Machines" -VHDPath $VMVhdx -Generation 2 -SwitchName "bridge"
        Set-VMFirmware -VMName $VMName -SecureBootTemplate MicrosoftUEFICertificateAuthority
        Set-Vm -ProcessorCount 2 -Name $VMName
        Set-VMMemory -DynamicMemoryEnabled $false -VMName $VMName
        Set-VMNetworkAdapterVlan -VMName $VMName -Access -VlanId 70
    }
    write-host "=========================================="
}


Add-LabVM -VMName lab-schema-registry-0 -MemorySize 2GB
Add-LabVM -VMName lab-schema-registry-1 -MemorySize 2GB
Add-LabVM -VMName lab-connect-0 -MemorySize 2GB
Add-LabVM -VMName lab-zookeeper-0 -MemorySize 1GB
Add-LabVM -VMName lab-zookeeper-1 -MemorySize 1GB
Add-LabVM -VMName lab-zookeeper-2 -MemorySize 1GB
Add-LabVM -VMName lab-kafka-0 -MemorySize 4GB
Add-LabVM -VMName lab-kafka-1 -MemorySize 4GB
Add-LabVM -VMName lab-kafka-2 -MemorySize 4GB
Add-LabVM -VMName lab-ksql-0 -MemorySize 4GB
Add-LabVM -VMName lab-control-center-0 -MemorySize 6GB
Add-LabVM -VMName lab-ldap-0 -MemorySize 1GB
