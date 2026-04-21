$GitHubRepositoryAuthor = "DauntlessStudio";
$GitHubRepositoryName = "Dotfiles-for-Windows-11";
$DotfilesFolder = Join-Path -Path $HOME -ChildPath ".dotfiles";
$DotfilesWorkFolder = Join-Path -Path $DotfilesFolder -ChildPath "${GitHubRepositoryName}-main" | Join-Path -ChildPath "src";
$DotfilesHelpersFolder = Join-Path -Path $DotfilesWorkFolder -ChildPath "Helpers";
$DotfilesPackagesFolder = Join-Path -Path $DotfilesWorkFolder -ChildPath "Dependencies";
$DotfilesConfigFile = Join-Path -Path $DotfilesFolder -ChildPath "${GitHubRepositoryName}-main" | Join-Path -ChildPath "config.json";

$LogPath = Join-Path -Path $HOME -ChildPath "dotfiles_setup.log"
Start-Transcript -Path $LogPath -Append

Write-Host "Welcome to Dotfiles for Microsoft Windows 11" -ForegroundColor "Yellow";
Write-Host "Please don't use your device while the script is running." -ForegroundColor "Yellow";

# Load helpers
Write-Host "Loading helpers:" -ForegroundColor "Green";
$DotfilesHelpers = Get-ChildItem -Path "${DotfilesHelpersFolder}\*" -Include *.ps1 -Recurse;
foreach ($DotfilesHelper in $DotfilesHelpers) {
  . $DotfilesHelper;
};

# Save user configuration in persistence
Set-Configuration-File -DotfilesConfigFile $DotfilesConfigFile -ComputerName $ComputerName -GitUserName $GitUserName -GitUserEmail $GitUserEmail -WorkspaceDisk $WorkspaceDisk -Progress "Setup";

# Load user configuration from persistence
$Config = Get-Configuration-File -DotfilesConfigFile $DotfilesConfigFile;

# Set alias for HKEY_CLASSES_ROOT
Set-PSDrive-HKCR;

if ("Setup" -match $Config.Progress) {
  $wslCheck = wsl --status
  if ("not installed" -match $wslCheck) {
    Write-Host "WSL not detected. Initiating installation and mandatory reboot..." -ForegroundColor "Cyan"
    
    # Register this script to run again after the reboot
    Register-DotfilesScript-As-RunOnce;

    # Install Debian as default
    wsl --install -d Debian
    Invoke-Expression (Join-Path -Path $DotfilesWorkFolder -ChildPath "Windows" | Join-Path -ChildPath "Windows.ps1");
    Invoke-Expression (Join-Path -Path $DotfilesWorkFolder -ChildPath "Chocolatey" | Join-Path -ChildPath "Chocolatey.ps1");
    
    # Prepare to run packages on next reload
    Update-Configuration-File -DotfilesConfigFile $DotfilesConfigFile -Config $Config -Progress "InstallPackages";
    Write-Host "Restarting in 10 seconds to finalize WSL installation..." -ForegroundColor "Yellow";
    Start-Sleep -Seconds 10;
    Restart-Computer;
    return
  }
}

if ("InstallPackages" -match $Config.Progress) {
  Invoke-Expression (Join-Path -Path $DotfilesWorkFolder -ChildPath "Dependencies" | Join-Path -ChildPath "Install.ps1");

  # Register this script to run again after the reboot
  Register-DotfilesScript-As-RunOnce;

  Update-Configuration-File -DotfilesConfigFile $DotfilesConfigFile -Config $Config -Progress "Finalize";
  Write-Host "Restarting in 10 seconds to restart environment..." -ForegroundColor "Yellow";
  Start-Sleep -Seconds 10;
  Restart-Computer;
  return;
}

if (-not ("Finalize" -match $Config.Progress)) {
  return;
}

# Setup now installed packages
Invoke-Expression (Join-Path -Path $DotfilesWorkFolder -ChildPath "Dependencies" | Join-Path -ChildPath "Setup.ps1");

# Clean
Remove-DotfilesScript-From-RunOnce;

Write-Host "Deleting Desktop shortcuts:" -ForegroundColor "Green";
Remove-Desktop-Shortcuts;

Write-Host "Cleaning Dotfiles workspace:" -ForegroundColor "Green";
Remove-Item $DotfilesFolder -Recurse -Force -ErrorAction SilentlyContinue;

Write-Host "The process has finished." -ForegroundColor "Yellow";

Write-Host "Restarting the PC in 10 seconds..." -ForegroundColor "Green";
Start-Sleep -Seconds 10;
Restart-Computer;

Stop-Transcript