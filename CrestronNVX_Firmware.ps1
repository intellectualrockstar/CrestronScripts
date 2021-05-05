param ($version = "5.1.4651.00035", $username = "admin")

Import-Module PSCrestron

$password = Read-Host -assecurestring "Please enter the password for $username"
$password = [System.Runtime.InteropServices.Marshal]::PtrToStringAuto([System.Runtime.InteropServices.Marshal]::SecureStringToBSTR($password))

function get-Folderlocation([string]$Message, [string]$InitialDirectory, [switch]$NoNewFolderButton)
{
    <#
    $browseForFolderOptions = 0
    #$InitialDirectory = (new-object -COM Shell.Application).Namespace(0x05).Self.Path #Make this whatever you want
    $InitialDirectory = 'C:\'
    $browseForFolderOptions += 512

    $app = New-Object -ComObject Shell.Application
    $folder = $app.BrowseForFolder(0, $Message, $browseForFolderOptions, $InitialDirectory)
    if ($folder) { $selectedDirectory = $folder.Self.Path } else { $selectedDirectory = '' }
    [System.Runtime.Interopservices.Marshal]::ReleaseComObject($app) > $null
    return $selectedDirectory
    #>

    Add-Type -AssemblyName System.Windows.Forms
    $browser = New-Object System.Windows.Forms.FolderBrowserDialog -Property @{
        ShowNewFolderButton = $false
        Description = "Folder Containing Firmware Files"
    }
    $null = $browser.ShowDialog()
    $path = $browser.SelectedPath

    return $path

}

$userSelectedFolder = get-Folderlocation("Select Folder with Firmware Zip Files")

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
#Write-host 'Are these files the correct Version?'
#Read-Host -Prompt "Press Enter to Contiune"

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

foreach ($device in $devs)
{
    Write-Host 'Getting Details for Device:' $device.IP $device.Description
    $info = Get-VersionInfo -Device $devs.IP -Secure -Username $username -Password $password

    if($info.VersionPUF -notmatch $version)
    {
        if($info.Prompt -match 'NVX-E30' -or $info.Prompt -match 'NVX-D30')
        {
            $type2 += $info
            Write-Host 'Version Mis-match. Set to load' $fw2File
        }
        elseif($info.Prompt -match 'NVX-35')
        {
            $type1 += $info
            Write-Host 'Version Mis-match. Set to load' $fw1File
        }
        elseif($info.Prompt -match 'NVX-36')
        {
            $type3 += $info
            Write-Host 'Version Mis-match. Set to load' $fw3File
        }
        else
        {
            Write-Host 'Prompt does not match a known NVX unit. Ignoring Device'
        }
        
    }
    else
    {
        Write-Host 'Versions Already Match. Not updating'    
    }
}

#start the job

Write-Host "starting scripting block, check back in 30 minutes"

$type1 | Invoke-RunspaceJob -SharedVariables fw1 username password -ScriptBlock {
    Send-CrestronFirmware -Device $_.IPAddress -LocalFile $fw1 -ImageUpdate -Password $password -Secure -Username $username
}

$type2 | Invoke-RunspaceJob -SharedVariables fw2 username password -ScriptBlock {
    Send-CrestronFirmware -Device $_.IPAddress -LocalFile $fw2 -ImageUpdate -Password $password -Secure -Username $username
}

$type3 | Invoke-RunspaceJob -SharedVariables fw3 username password -ScriptBlock {
    Send-CrestronFirmware -Device $_.IPAddress -LocalFile $fw3 -ImageUpdate -Password $password -Secure -Username $username
}

Write-Host "done"
Read-Host -Prompt "press enter to exit"