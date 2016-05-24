sl C:\ExploringAspNetCore\SampleApp\src\SmokeTests

# Restore the nuget references
& "C:\Program Files\dotnet\dotnet.exe" restore

# Run the smoke tests
& "C:\Program Files\dotnet\dotnet.exe" test

exit $LastExitCode