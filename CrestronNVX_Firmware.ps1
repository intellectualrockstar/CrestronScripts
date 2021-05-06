<#
.Description    
Autodiscovers Crestron NVX Devices and Checks firmware version. Uploads firmware if versions do not match.
.PARAMETER version
Version Number of PUF to update to
.PARAMETER AutoUpgrade
Auto-sends firmware without prompting
.PARAMETER IgnoreDowngrade
Automatically Ignores devices with newer firmware
#>

param ([string]$version = "5.1.4651.00035", [string]$username = "admin", [string]$password, [switch]$AutoUpgrade = $false, [switch]$IgnoreDowngrade = $false)

Import-Module PSCrestron

#If Password param is empty, prompt for password
if ([string]::IsNullOrEmpty($password))
{
    $securepassword = Read-Host -assecurestring "Please enter the password for $username"
    $password = [System.Runtime.InteropServices.Marshal]::PtrToStringAuto([System.Runtime.InteropServices.Marshal]::SecureStringToBSTR($securepassword))   
}


function get-Folderlocation()
{
    Add-Type -AssemblyName System.Windows.Forms
    $browser = New-Object System.Windows.Forms.FolderBrowserDialog -Property @{
        ShowNewFolderButton = $false
        Description = "Folder Containing Firmware Files"
    }
    $null = $browser.ShowDialog()
    $path = $browser.SelectedPath

    return $path
}

function get-VersionArray([string]$ver)
{
    $s = $ver.Split(".") | % {[int]$_}

    return $s
}

$userSelectedFolder = get-Folderlocation
$ver = get-VersionArray($version)

#variables
$fw1File = Get-ChildItem -Path $userSelectedFolder -Filter *nvx-35x*.zip #NVX-3x Series Firmware Path
$fw2File = Get-ChildItem -Path $userSelectedFolder -Filter *nvx-ed30*.zip #NVX-ED Series Firmware Path
$fw3File = Get-ChildItem -Path $userSelectedFolder -Filter *nvx-36x*.zip #NVX-ED Series Firmware Path

if([string]::IsNullOrWhitespace($fw1File) -or [string]::IsNullOrWhitespace($fw2File) -or [string]::IsNullOrWhitespace($fw1File))
{
    Write-Host 'Folder must contain firmware for all NVX Models'
    Break
}
else 
{
    $fw1 = Join-Path $userSelectedFolder $fw1File
    $fw2 = Join-Path $userSelectedFolder $fw2File
    $fw3 = Join-Path $userSelectedFolder $fw3File

    Write-Host 'Found '$fw1
    Write-Host 'Found '$fw2
    Write-Host 'Found '$fw3
}

$title    = ''
$question = 'Are the above firmware files correct??'
$choices  = '&Yes', '&No'

$decision = $Host.UI.PromptForChoice($title, $question, $choices, 0)
if ($decision -eq 0) {
    Write-Host 'Continuing'
} else {
    Write-Host 'Exiting Script'
    Break
}


Write-Host "Running auto discovery... (This could take some time)"
$devs = Get-AutoDiscovery -Pattern nvx

$count = 0

$type1 = @()
$type2 = @()
$type3 = @()

foreach ($device in $devs)
{
    Write-Host 'Getting Details for Device:' $device.IP
    $info = Get-VersionInfo -Device $device.IP -Secure -Username $username -Password $password

    if(![string]::IsNullOrEmpty($info.ErrorMessage.Trim()))
    {
        Write-Host "Device " $device.IP "has an Error Message" $info.ErrorMessage
    }
    
    if($info.VersionPUF -ne $version) #Check if Puf Does not Match
    {
        Write-Host $info.VersionPUF
        #Compare versions to see request is higher or lower
        $dver = get-VersionArray($info.VersionPUF)
        
        #major version
        if($dver[0] -gt $ver[0])
        {
            #This is a downgrade
            $downgrade = $true
        }
        elseif($dver[0] -lt $ver[0])
        {
            #this is an upgrade
            $upgrade = $true
        }
        elseif($dver[0] -eq $ver[0]) 
        {
            #Major matches, check Minor
            if($dver[1] -gt $ver[1])
            {
                #This is a downgrade
                $downgrade = $true
            }
            elseif($dver[1] -lt $ver[1])
            {
                #this is an upgrade
                $upgrade = $true
            }
            elseif($dver[1] -eq $ver[1]) 
            {
                #Minor matches, check micro
                if($dver[2] -gt $ver[2])
                {
                    #This is a downgrade
                    $downgrade = $true
                }
                elseif($dver[2] -lt $ver[2])
                {
                    #this is an upgrade
                    $upgrade = $true
                }
                elseif($dver[2] -eq $ver[2]) 
                {
                    #Micro matches, check nano
                    if($dver[3] -gt $ver[3])
                    {
                        #This is a downgrade
                        $downgrade = $true
                    }
                    elseif($dver[3] -lt $ver[3])
                    {
                        #this is an upgrade
                        $upgrade = $true
                    }
                    elseif($dver[3] -eq $ver[3]) 
                    {
                        #Why did I even get here! The versions match!
                        Write-Host 'What? Versions Already Match. Not updating'  
                    }  
                }   
            }
        }

        if($downgrade -And $IgnoreDowngrade -eq $false)
        {
            $title    = 'Downgrade Warning!'
            $question = "Downgrade Device " + $info.Hostname + "??"
            $choices  = '&Yes', '&No'

            $decision = $Host.UI.PromptForChoice($title, $question, $choices, 0)
            if ($decision -eq 0) 
            {
                Write-Host 'Adding to Queue'
                $addDev = $true
            } 
            else 
            {
                Write-Host 'Ignoring Device'
                $addDev = $false
            }
        }
        elseif($upgrade)
        {
            $addDev = $true
        }

        if($addDev)
        {
            $info | Add-Member -NotePropertyName username -NotePropertyValue $username
            $info | Add-Member -NotePropertyName password -NotePropertyValue $password

            if($info.Prompt -match 'NVX-E30' -or $info.Prompt -match 'NVX-D30')
            {
                $type2 += $info
                Write-Host 'Version Mis-match. Set to load' $fw2File
                $count++
            }
            elseif($info.Prompt -match 'NVX-35')
            {
                $type1 += $info
                Write-Host 'Version Mis-match. Set to load' $fw1File
                $count++
            }
            elseif($info.Prompt -match 'NVX-36')
            {
                $type3 += $info
                Write-Host 'Version Mis-match. Set to load' $fw3File
                $count++
            }
            else
            {
                Write-Host 'Prompt does not match a known NVX unit. Ignoring Device'
            }
        }
    }
    else
    {
        Write-Host 'Versions Already Match. Not updating'    
    }
}

$time = [math]::ceiling(($count * 10) / 8)



if($count -ne 0)
{
    #Ask for Conformation to continue with Updates


    #start the job
    Write-Host "Starting Background Firmware push on $count devices. Estimated time to complete is $time minutes. "
    Write-Host "DO NOT POWER OFF DEIVCES OR STOP THIS SCRIPT!"
    if($type1)
    {
        $type1 | Invoke-RunspaceJob -ThrottleLimit 8 -SharedVariables fw1 -ShowProgress -ScriptBlock {
            Send-CrestronFirmware -Device $_.IPAddress -LocalFile $fw1 -ImageUpdate -Secure -Username $_.username -Password $_.password
        }
    }
    if($type2)
    {
        $type2 | Invoke-RunspaceJob -ThrottleLimit 8 -SharedVariables fw2 -ShowProgress -ScriptBlock {
            Send-CrestronFirmware -Device $_.IPAddress -LocalFile $fw2 -ImageUpdate -Secure -Username $_.username -Password $_.password
        }
    }
    if($type3)
    {
        $type3 | Invoke-RunspaceJob -ThrottleLimit 8 -SharedVariables fw3 -ShowProgress -ScriptBlock {
            Send-CrestronFirmware -Device $_.IPAddress -LocalFile $fw3 -ImageUpdate -Secure -Username $_.username -Password $_.password
        }
    }
    Write-Host 'Done!'
}
else 
{
    Write-Host "No devices require updating."    
}

Read-Host -Prompt "Press Enter to Exit"