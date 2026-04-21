function Set-ChromeAsDefaultBrowser {
    Add-Type -AssemblyName 'System.Windows.Forms'
    Start-Process $env:windir\system32\control.exe -ArgumentList '/name Microsoft.DefaultPrograms /page pageDefaultProgram\pageAdvancedSettings?pszAppName=google%20chrome'
    Sleep 2
    [System.Windows.Forms.SendKeys]::SendWait("{TAB} {TAB}{TAB} ")
}

function Set-Git-Configuration {
  Write-Host "Configuring Git:" -ForegroundColor "Green";
  git config --global init.defaultBranch "main";
  git config --global user.name $Config.GitUserName;
  git config --global user.email $Config.GitUserEmail;
  Write-Host "Git was successfully configured." -ForegroundColor "Green";
}

function Set-Gnu-Configuration {
    [Environment]::SetEnvironmentVariable("Path", $env:Path + ";C:\Program Files (x86)\GnuWin32\bin", "User");
    Write-Host "GnuWin was succesfully configured" -ForegroundColor "Green";
}

function Set-VSCode-Configuration {
  $VSCodeSettingsPath = Join-Path -Path $env:appdata -ChildPath "Code" | Join-Path -ChildPath "User";
  $DotfilesVSCodeSettingsFolder = Join-Path -Path $DotfilesWorkFolder -ChildPath "VSCode";
  
  if (-not (Test-Path -Path $VSCodeSettingsPath)) {
    Write-Host "Configuring Visual Studio Code:" -ForegroundColor "Green";
    New-Item $VSCodeSettingsPath -ItemType directory;
  }

  Get-ChildItem -Path "${DotfilesVSCodeSettingsFolder}\*" -Include "*.json" -Recurse | Copy-Item -Destination $VSCodeSettingsPath;

  code --install-extension "acarreiro.calculate";
  code --install-extension "eamodio.gitlens";
  code --install-extension "albymor.increment-selection";
  code --install-extension "visualstudioexptteam.vscodeintellicode";
  code --install-extension "pkief.material-icon-theme";
  code --install-extension "misodee.vscode-nbt";
  code --install-extension "jannisx11.snowstorm";
  code --install-extension "ms-vscode-remote.remote-wsl";
}

function Set-WSL-Configuration {
    wsl -d Debian -u root sh -c "apt-get update && apt-get install -y curl xz-utils";
    wsl -d Debian sh -c "curl --proto '=https' --tlsv1.2 -L https://nixos.org/nix/install | sh -s -- --no-daemon";
    wsl sh -c "git config --global include.path /mnt/c/Users/$env:USERNAME/.gitconfig";
}

function Set-Dotnet-Configuration {
    dotnet tool install --global dotnet-ef;
}

function Set-Github-Configuration {
    Write-Host "`a"
    gh auth login;
}

Set-ChromeAsDefaultBrowser;
Set-Git-Configuration;
Set-Gnu-Configuration;
Set-VSCode-Configuration;
Set-WSL-Configuration;
Set-Dotnet-Configuration;
Set-Github-Configuration;