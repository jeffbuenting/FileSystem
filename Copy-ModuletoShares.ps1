<# 
    .Synopsis
        Copies module to the network share so other system can use it
#>

$Module = 'filesystem'
$Source = "F:\GitHub\$Module\$($Module)"
$InternalDestination = "\\VASLNAS.stratuslivedemo.com\Deploys\SLConfigs\Powershell\Modules\$Module"
$RemoteDestination = "j:\Powershell\Modules\$Module"


If ( -Not ( Test-Path $InternalDestination ) ) { New-Item -Path $InternalDestination -ItemType Directory }
copy-item "$($Source).*" -Destination $InternalDestination -Force


# ----- map drive to remote and connect with different username / password
New-PSDrive -Name 'J' -PSProvider FileSystem -Root \\RWVA-ADFS\SLConfigs -Credential stratuscloud1\jeff.buenting

If ( -Not ( Test-Path $RemoteDestination ) ) { New-Item -Path $RemoteDestination -ItemType Directory }
Copy-Item -Path "$($Source).*" -Destination $RemoteDestination -Force


# ----- Cleanup
Remove-PSDrive -Name J

Write-Output "Module has been copied to both Internal and External repositories"
