## CSV file must have headers CurrentIP, IPAddress, Hostname, IPMask, Defrouter, MasterIP, IPID
param($filename)

Import-Module PSCrestron


if ([string]::IsNullOrEmpty($filename))
{
    Add-Type -AssemblyName System.Windows.Forms
    $FileBrowser = New-Object System.Windows.Forms.OpenFileDialog 
    $FileBrowser.filter = 'CSV |*.csv' 
    [VOID]$FileBrowser.ShowDialog()
    $filename = $FileBrowser.FileNames
}

if([string]::IsNullOrEmpty($filename))
{
    Write-Host "Invalid File"
}
else 
{
    
    Write-Host "Opening CSV" $filename

    $csv = Import-Csv $filename

    Foreach ($el in $csv) 
    {

        if($el.Secure -like 'yes')
        {
            Write-Host 'Opening Secure Session to Device at'$el.CurrentIP
            $session = Open-CrestronSession -Device $el.CurrentIP -secure -Username "admin" -Password "admin"
        
            $cmd1 = 'hostname ' + $el.Hostname 
            Write-Host 'Setting:' $cmd1
            Invoke-CrestronSession $session $cmd1
            
            $cmd2 = 'IPA 0 ' + $el.IPAddress 
            Write-Host 'Setting:' $cmd2
            Invoke-CrestronSession $session  $cmd2

            $cmd3 = 'IPMask 0 ' + $el.IPMask 
            Write-Host 'Setting:' $cmd3
            Invoke-CrestronSession $session  $cmd3

            $cmd4 = 'DefRouter 0 ' + $el.Defrouter 
            Write-Host 'Setting:' $cmd4
            Invoke-CrestronSession $session  $cmd4

            $cmd5 = 'Addm ' + $el.IPID + ' ' + $el.MasterIP  
            Write-Host 'Setting:' $cmd5
            Invoke-CrestronSession $session  $cmd5

            $cmd6 = "DHCP 0 off"
            Write-Host 'Setting:' $cmd6
            Invoke-CrestronSession $session  $cmd6

            $cmd7 = "REBOOT"
            Write-Host 'Rebooting Device'
            Invoke-CrestronSession $session  $cmd7

            Write-Host 'Closing Session'
            Close-CrestronSession $session
            
        }
        else
        {
            Write-Host 'Opening Plain Session to Device at '$el.IPAddress
        }
    }
}