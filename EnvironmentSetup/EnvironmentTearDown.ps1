if ((Get-AWSCredentials) -eq $null)
{
    throw "You must set credentials via Set-AWSCredentials before running this cmdlet."
}
if ((Get-DefaultAWSRegion) -eq $null)
{
    throw "You must set a region via Set-DefaultAWSRegion before running this cmdlet."
}

function _deletePipelineBucket()
{
    Get-S3Bucket | Where-Object {$_.BucketName.StartsWith("exploringaspnetcore-part2-")} | foreach {Write-Host 'Deleting pipeline bucket:' $_.BucketName; Remove-S3Bucket -BucketName $_.BucketName -DeleteBucketContent -Force}    
}

function _deleteStack()
{
    $stack = (Get-CFNStack -StackName "ExploringAspNetCore-Part2" | Where-Object {$_.StackName -eq "ExploringAspNetCore-Part2"})
    if($stack -ne $null)
    {
        Write-Host "Deleting CloudFormation existing stack"
        Remove-CFNStack $stack.StackName -Force
    }
}


_deletePipelineBucket
_deleteStack