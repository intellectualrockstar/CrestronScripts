param ($outputpath = (new-object -COM Shell.Application).Namespace(0x05).Self.Path)

Import-Module PSCrestron

$date = Get-Date -Format "yyyyMMdd_HHmm"
$filename = 'CrestronDiscovery_' + $date +'.csv'

$outputfile = Join-Path $outputpath $filename

Write-Host 'Running Auto-Discovery...'

$devs = Get-AutoDiscovery 

$count = 1

foreach ($device in $devs)
{
    Write-Host 'Getting Details for Device'$count':' $device.IP $device.Description

    if ($device.Description -match 'NVX')
        {
            Get-VersionInfo -Device $device.IP -Secure -Username "admin" -Password "admin" | Export-Csv $outputfile -Append
        }
    else 
        {
            Get-VersionInfo -Device $device.IP | Export-Csv $outputfile -Append
        }
    $count++ 
}   

Write-Host 'Device info placed in ' $($outputfile) 