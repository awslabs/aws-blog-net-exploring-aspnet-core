sl C:\ExploringAspNetCore\SampleApp\src\SampleApp

# Download the bootstrapper dnvm install script
iex ((new-object net.webclient).DownloadString('https://dist.asp.net/dnvm/dnvminstall.ps1'))

# Install the latest dnx runtime
C:\Windows\system32\config\systemprofile\.dnx\bin\dnvm install latest -p

# Restore the nuget references
dnu restore

# Publish application with all of its dependencies and runtime for IIS to use
dnu publish --configuration release -o c:\ExploringAspNetCore\publish --runtime active


# Point IIS wwwroot of the published folder. CodeDeploy uses 32 bit version of PowerShell.
# To make use the IIS PowerShell CmdLets we need call the 64 bit version of PowerShell.
C:\Windows\SysNative\WindowsPowerShell\v1.0\powershell.exe -Command {Import-Module WebAdministration; Set-ItemProperty 'IIS:\sites\Default Web Site' -Name physicalPath -Value c:\ExploringAspNetCore\publish\wwwroot}