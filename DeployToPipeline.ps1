if ((Get-AWSCredentials) -eq $null)
{
    throw "You must set credentials via Set-AWSCredentials before running this cmdlet."
}
if ((Get-DefaultAWSRegion) -eq $null)
{
    throw "You must set a region via Set-DefaultAWSRegion before running this cmdlet."
}

function _deployRepository()
{
    $pipelineSourceConfig = (Get-CPPipeline ExploringAspNetCore-Part2).Stages[0].Actions[0].Configuration
    $bucketName = $pipelineSourceConfig["S3Bucket"]
    $s3Key = $pipelineSourceConfig["S3ObjectKey"]

    Write-Host 'Zipping Repository'
    Add-Type -assembly "system.io.compression.filesystem"
    $destination = [System.io.Path]::Combine([System.io.Path]::GetTempPath(),  'aws-blog-net-exploring-aspnet-core.zip')
    If (Test-Path $destination)
    {
	    Remove-Item $destination
    }
    
    Write-Host 'Zipping up repository for initial deployment in pipeline'
    [io.compression.zipfile]::CreateFromDirectory($PSScriptRoot, $destination)

    Write-Host 'Writing zip to S3 ' $bucketName
    Write-S3Object -BucketName $bucketName -File $destination -Key $s3Key

    $bucketName
}


_deployRepository