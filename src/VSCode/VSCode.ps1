function Set-VSCode-Configuration {
  $VSCodeSettingsPath = Join-Path -Path $env:appdata -ChildPath "Code" | Join-Path -ChildPath "User";
  $DotfilesVSCodeSettingsFolder = Join-Path -Path $DotfilesWorkFolder -ChildPath "VSCode";
  
  if (-not (Test-Path -Path $VSCodeSettingsPath)) {
    Write-Host "Configuring Visual Studio Code:" -ForegroundColor "Green";
    New-Item $VSCodeSettingsPath -ItemType directory;
  }

  Get-ChildItem -Path "${DotfilesVSCodeSettingsFolder}\*" -Include "*.json" -Recurse | Copy-Item -Destination $VSCodeSettingsPath;
}

choco install -y "vscode" --params "/NoDesktopIcon /NoQuicklaunchIcon /NoContextMenuFiles /NoContextMenuFolders";
Set-VSCode-Configuration;
refreshenv;
code --install-extension "blockceptionltd.blockceptionvscodeminecraftbedrockdevelopmentextension";
code --install-extension "acarreiro.calculate";
code --install-extension "eamodio.gitlens";
code --install-extension "albymor.increment-selection";
code --install-extension "visualstudioexptteam.vscodeintellicode";
code --install-extension "pkief.material-icon-theme";
code --install-extension "misodee.vscode-nbt";
code --install-extension "jannisx11.snowstorm";