$GitHubRepositoryAuthor = "DauntlessStudio";
$GitHubRepositoryName = "Dotfiles-for-Windows-11";
$DotfilesFolder = Join-Path -Path $HOME -ChildPath ".dotfiles";
$DotfilesWorkFolder = Join-Path -Path $DotfilesFolder -ChildPath "${GitHubRepositoryName}-main" | Join-Path -ChildPath "src";
$DotfilesHelpersFolder = Join-Path -Path $DotfilesWorkFolder -ChildPath "Helpers";
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
Set-Configuration-File -DotfilesConfigFile $DotfilesConfigFile -ComputerName $ComputerName -GitUserName $GitUserName -GitUserEmail $GitUserEmail -WorkspaceDisk $WorkspaceDisk;

# Load user configuration from persistence
$Config = Get-Configuration-File -DotfilesConfigFile $DotfilesConfigFile;

# Set alias for HKEY_CLASSES_ROOT
Set-PSDrive-HKCR;

if (-not (Get-PackageProvider-Installation-Status -PackageProviderName "NuGet")) {
  Write-Host "Installing NuGet as package provider:" -ForegroundColor "Green";
  Install-PackageProvider -Name "NuGet" -Force;
}

if (-not (Get-PSRepository-Trusted-Status -PSRepositoryName "PSGallery")) {
  Write-Host "Setting up PSGallery as PowerShell trusted repository:" -ForegroundColor "Green";
  Set-PSRepository -Name "PSGallery" -InstallationPolicy Trusted;
}

if (-not (Get-Module-Installation-Status -ModuleName "PackageManagement" -ModuleMinimumVersion "1.4.6")) {
  Write-Host "Updating PackageManagement module:" -ForegroundColor "Green";
  [Net.ServicePointManager]::SecurityProtocol = [Net.SecurityProtocolType]::Tls12;
  Install-Module -Name "PackageManagement" -Force -MinimumVersion "1.4.6" -Scope "CurrentUser" -AllowClobber -Repository "PSGallery";
}

# Reboot the PC and rerun the script after installing wsl only if it is not installed yet
$wslCheck = wsl --status
if ("not installed" -match $wslCheck) {
  Write-Host "WSL not detected. Initiating installation and mandatory reboot..." -ForegroundColor "Cyan"
  
  # Register this script to run again after the reboot
  Register-DotfilesScript-As-RunOnce;

  # Install WSL (This enables Virtual Machine Platform & WSL features)
  wsl --install -d Debian
  Invoke-Expression (Join-Path -Path $DotfilesWorkFolder -ChildPath "Chocolatey" | Join-Path -ChildPath "Chocolatey.ps1");
  
  Write-Host "Restarting in 10 seconds to finalize WSL installation..." -ForegroundColor "Yellow"
  Start-Sleep -Seconds 10
  Restart-Computer
  return # Stop execution of the rest of the script
}

# Run scripts
Invoke-Expression (Join-Path -Path $DotfilesWorkFolder -ChildPath "Windows" | Join-Path -ChildPath "Windows.ps1");
Invoke-Expression (Join-Path -Path $DotfilesWorkFolder -ChildPath "WSL" | Join-Path -ChildPath "WSL.ps1");
Invoke-Expression (Join-Path -Path $DotfilesWorkFolder -ChildPath "WorkspaceFolder" | Join-Path -ChildPath "WorkspaceFolder.ps1");
Invoke-Expression (Join-Path -Path $DotfilesWorkFolder -ChildPath "Docker" | Join-Path -ChildPath "Docker.ps1");
Invoke-Expression (Join-Path -Path $DotfilesWorkFolder -ChildPath "Chrome" | Join-Path -ChildPath "Chrome.ps1");
Invoke-Expression (Join-Path -Path $DotfilesWorkFolder -ChildPath "Flutter" | Join-Path -ChildPath "Flutter.ps1");
Invoke-Expression (Join-Path -Path $DotfilesWorkFolder -ChildPath "Git" | Join-Path -ChildPath "Git.ps1");
Invoke-Expression (Join-Path -Path $DotfilesWorkFolder -ChildPath "GitHub" | Join-Path -ChildPath "Git.ps1");
Invoke-Expression (Join-Path -Path $DotfilesWorkFolder -ChildPath "GnuWin" | Join-Path -ChildPath "GnuWin.ps1");
Invoke-Expression (Join-Path -Path $DotfilesWorkFolder -ChildPath "VSCode" | Join-Path -ChildPath "VSCode.ps1");
Invoke-Expression (Join-Path -Path $DotfilesWorkFolder -ChildPath "Dotnet" | Join-Path -ChildPath "Dotnet.ps1");
Invoke-Expression (Join-Path -Path $DotfilesWorkFolder -ChildPath "VisualStudio" | Join-Path -ChildPath "VisualStudio.ps1");
Invoke-Expression (Join-Path -Path $DotfilesWorkFolder -ChildPath "AndroidStudio" | Join-Path -ChildPath "AndroidStudio.ps1");

# Clean
# Unregister script from RunOnce
Remove-DotfilesScript-From-RunOnce;

Write-Host "Deleting Desktop shortcuts:" -ForegroundColor "Green";
Remove-Desktop-Shortcuts;

Write-Host "Cleaning Dotfiles workspace:" -ForegroundColor "Green";
Remove-Item $DotfilesFolder -Recurse -Force -ErrorAction SilentlyContinue;

gh auth login;

Write-Host "The process has finished." -ForegroundColor "Yellow";

Write-Host "Restarting the PC in 10 seconds..." -ForegroundColor "Green";
Start-Sleep -Seconds 10;
Restart-Computer;

Stop-Transcript