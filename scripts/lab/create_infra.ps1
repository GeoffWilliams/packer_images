. $PSScriptRoot\common.ps1

Add-LabVM  -VMName lab-mssql-0 `
    -ImageUrl "http://nexus.infrastructure.asio:8081/repository/raw/hyperv/hyperv_alma_8.10-0.vhdx" `
    -MemorySize 4GB

Add-LabVM  -VMName lab-postgresql-0 `
    -ImageUrl "http://nexus.infrastructure.asio:8081/repository/raw/hyperv/hyperv_alma_9.5-0.vhdx" `
    -MemorySize 1GB

Add-LabVM  -VMName lab-box-0 `
    -ImageUrl "http://nexus.infrastructure.asio:8081/repository/raw/hyperv/hyperv_alma_9.5-0.vhdx" `
    -MemorySize 1GB
