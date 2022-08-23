############################################################
# AUTHOR  : Filip Vagner
# EMAIL   : filip.vagner@hotmail.com
# DATE    : 01-08-2020
# COMMENT : Powershell script to copy files from one location to another.
#           Verify that files were copied and then remove in original location.
#           Removed files and folders are logged.
#           Files and folders that could not be removed are logged.
#           
###########################################################

$currentDate = Get-Date -Format yyyy-MM-dd
$samespaceItemsPath = 'E:\Voicebot\Samespace'
$voximplantItemsPath = 'E:\Voicebot\Voximplant'
$psdriveLogErrorPath = "E:\Voicebot\Logs\PsdriveError.txt"
$samespaceLogRemovedPath = "E:\Voicebot\Logs\$currentDate-Samespace-RemovedItems.txt"
$samespaceLogErrorPath = "E:\Voicebot\Logs\$currentDate-Samespace-RemovedItemsError.txt"
$voximplantLogRemovedPath = "E:\Voicebot\Logs\$currentDate-Voximplant-RemovedItems.txt"
$voximplantLogErrorPath = "E:\Voicebot\Logs\$currentDate-Voximplant-RemovedItemsError.txt"
$encryptedPasswordToAccessNas = Get-Content -Path "E:\nas.txt" | ConvertTo-SecureString
$userNameToAccessNas = 'IpAddress\username'
$credentialsToAccessNas = New-Object -TypeName System.Management.Automation.PSCredential($userNameToAccessNas, $encryptedPasswordToAccessNas)
$samespacePsDriveName = 'Samespace'
$voximplantPsDriveName = 'Voximplant'
$samespaceNasRoot = '\\IpAddress\data\Samespace'
$voximplantNasRoot = '\\IpAddress\data\Voximplant'
$samespaceDirectories = New-Object -TypeName "System.Collections.ArrayList"
$voximplantDirectories = New-Object -TypeName "System.Collections.ArrayList"
$itemsOlderThan = -3

New-PSDrive -Name $samespacePsDriveName -PSProvider 'FileSystem' -Root $samespaceNasRoot -Credential $credentialsToAccessNas
New-PSDrive -Name $voximplantPsDriveName -PSProvider 'FileSystem' -Root $voximplantNasRoot -Credential $credentialsToAccessNas

if (((Get-PSDrive).Name -notcontains 'Samespace') -or ((Get-PSDrive).Name -notcontains 'Voximplant')) {
    Write-Output "$currentDate - Some PSDrive could not be connected" | Out-File $psdriveLogErrorPath -Append
    exit
}

# Samespace copy block
## Getting list of folders and files on call rec server and copy to NAS server
$samespaceItems = Get-ChildItem -Path $samespaceItemsPath -Recurse | Where-Object {$_.CreationTime -lt (Get-Date).AddMonths($itemsOlderThan)}
foreach ($samespaceItem in $samespaceItems) {
    Copy-Item -Path $samespaceItem.FullName -Destination $samespaceItem.FullName.Replace($samespaceItemsPath, $samespaceNasRoot)
}

## Veryfing that files were copied to NAS sevrer and removing them on call rec server
foreach ($samespaceItem in $samespaceItems) {
    if ([System.IO.File]::Exists($samespaceItem.FullName)) {
        if (Test-Path -Path $samespaceItem.FullName.Replace($samespaceItemsPath, $samespaceNasRoot)) {
            Remove-Item -Path $samespaceItem.FullName -Confirm:$false
            Write-Output "File $($samespaceItem.FullName) was removed" | Out-File $samespaceLogRemovedPath -Append
        } else {
            Write-Output "File $($samespaceItem.FullName) is missing in destination" | Out-File $samespaceLogErrorPath -Append
        }
    }
    if ([System.IO.Directory]::Exists($samespaceItem.FullName)) {
        $samespaceDirectories.Add($samespaceItem.FullName)
    }
}

foreach ($samespaceDirectory in $samespaceDirectories | Sort-Object -Property Length -Descending) {
    if ([System.IO.Directory]::Exists($samespaceDirectory)) {
        if (([System.IO.Directory]::GetFiles($samespaceDirectory)) -or ([System.IO.Directory]::GetDirectories($samespaceDirectory))) {
            Write-Output "Directory $samespaceDirectory could not be removed (is not empty)" | Out-File $samespaceLogErrorPath -Append
        } else {
            Remove-Item -Path $samespaceDirectory -Confirm:$false
            Write-Output "Directory $samespaceDirectory was removed" | Out-File $samespaceLogRemovedPath -Append
        }
    }
}

# Voximplant copy block
## Getting list of folders and files on call rec server and copy to NAS server
$voximplantItems = Get-ChildItem -Path $voximplantItemsPath -Recurse | Where-Object {$_.CreationTime -lt (Get-Date).AddMonths($itemsOlderThan)}
foreach ($voximplantItem in $voximplantItems) {
    Copy-Item -Path $voximplantItem.FullName -Destination $voximplantItem.FullName.Replace($voximplantItemsPath, $voximplantNasRoot)
}

## Veryfing that files were copied to NAS sevrer and removing them on call rec server
foreach ($voximplantItem in $voximplantItems) {
    if ([System.IO.File]::Exists($voximplantItem.FullName)) {
        if (Test-Path -Path $voximplantItem.FullName.Replace($voximplantItemsPath, $voximplantNasRoot)) {
            Remove-Item -Path $voximplantItem.FullName -Confirm:$false
            Write-Output "File $($voximplantItem.FullName) was removed" | Out-File $voximplantLogRemovedPath -Append
        } else {
            Write-Output "File $($voximplantItem.FullName) is missing in destination" | Out-File $voximplantLogErrorPath -Append
        }
    }
    if ([System.IO.Directory]::Exists($voximplantItem.FullName)) {
        $voximplantDirectories.Add($voximplantItem.FullName)
    }
}

foreach ($voximplantDirectory in $voximplantDirectories | Sort-Object -Property Length -Descending) {
    if ([System.IO.Directory]::Exists($voximplantDirectory)) {
        if (([System.IO.Directory]::GetFiles($voximplantDirectory)) -or ([System.IO.Directory]::GetDirectories($voximplantDirectory))) {
            Write-Output "Directory $voximplantDirectory could not be removed (is not empty)" | Out-File $voximplantLogErrorPath -Append
        } else {
            Remove-Item -Path $voximplantDirectory -Confirm:$false
            Write-Output "Directory $voximplantDirectory was removed" | Out-File $voximplantLogRemovedPath -Append
        }
    }
}
