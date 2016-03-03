sl C:\ExploringAspNetCore\SampleApp\src\SmokeTests

# Install the latest dnx runtime
C:\Windows\system32\config\systemprofile\.dnx\bin\dnvm install latest -p

# Restore the nuget references
dnu restore

# Run the smoke tests
dnx test

exit $LastExitCode