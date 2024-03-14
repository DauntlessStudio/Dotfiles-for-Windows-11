function Set-ChromeAsDefaultBrowser {
    Add-Type -AssemblyName 'System.Windows.Forms'
    Start-Process $env:windir\system32\control.exe -ArgumentList '/name Microsoft.DefaultPrograms /page pageDefaultProgram\pageAdvancedSettings?pszAppName=google%20chrome'
    Sleep 2
    [System.Windows.Forms.SendKeys]::SendWait("{TAB} {TAB}{TAB} ")
}

choco install -y "googlechrome";
Set-ChromeAsDefaultBrowser;