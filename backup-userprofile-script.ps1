$destination = "\\192.168.1.50\public"
$folders = "Desktop",
    "Downloads",
    "Favorites",
    "Documents",
    "Pictures"
$username = $env:username
$userProfile = $env:userprofile
$appData = $env:localAPPDATA
$timestamp = Get-Date -Format "dd-MMM-yyyy-hh-mm"

Write-Host -ForegroundColor Green "Calculating backup size for $username"
foreach ($f in $folders) {
    $currentLocalFolder = $userProfile + "\" + $f
    $currentRemoteFolder = $destination + "\" + $username + "\" + $timestamp + "\" + $f
    $currentFolderSize = (Get-ChildItem -ErrorAction SilentlyContinue $currentLocalFolder -Recurse -Force | Measure-Object -ErrorAction SilentlyContinue -Property Length -Sum).Sum / 1MB
    $currentFolderSizeRounded = [System.Math]::Round($currentFolderSize)
    $totalBackupSize = [System.Math]::Round($totalBackupSize + $currentFolderSize)
    Write-Host -ForegroundColor Yellow "$f... ($currentFolderSizeRounded MB)"
}
Write-Host -ForegroundColor Yellow "Total backup size for $username is $totalBackupSize MB"


$message = "Would you like to proceed the backup?";
$Yes = New-Object System.Management.Automation.Host.ChoiceDescription "&Yes","Yes";
$No = New-Object System.Management.Automation.Host.ChoiceDescription "&No","No";
$choices = [System.Management.Automation.Host.ChoiceDescription[]] ($Yes,$No);
$answer = $Host.UI.PromptForChoice($caption, $message, $choices, 0)
if ($answer -eq 0) {
    foreach ($f in $folders) {
        $currentLocalFolder = $userProfile + "\" + $f
        $currentRemoteFolder = $destination + "\" + $username + "\" + $timestamp + "\" + $f
        $currentFolderSize = (Get-ChildItem -ErrorAction SilentlyContinue $currentLocalFolder -Recurse -Force | Measure-Object -ErrorAction SilentlyContinue -Property Length -Sum).Sum / 1MB
        $currentFolderSizeRounded = [System.Math]::Round($currentFolderSize)
        $totalBackupSize = [System.Math]::Round($totalBackupSize + $currentFolderSize)
        Write-Host -ForegroundColor Cyan "Backing up $f... ($currentFolderSizeRounded MB)"
        Copy-Item -ErrorAction SilentlyContinue -Recurse $currentLocalFolder $currentRemoteFolder
    }
    

    Write-Host -ForegroundColor Green "Backup complete!"
    Write-Host -ForegroundColor Green "Backup location:" $destination\$username\$timestamp\
} else {
    Write-Host -ForegroundColor Red "Aborting process"
    Exit-PSHostProcess
}

