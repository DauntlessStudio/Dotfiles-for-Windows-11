function Set-Gnu-Configuration {
    [Environment]::SetEnvironmentVariable("Path", $env:Path + ";C:\Program Files (x86)\GnuWin32\bin", "User");
    Write-Host "GnuWin was succesfully configured" -ForegroundColor "Green";
}

choco install -y "gnuwin32-coreutils.install";
Set-Gnu-Configuration;