Param(
    # The EC2 key pair assigned to all instances launched.
    [Parameter(mandatory=$true)]
    [string]
    $ec2KeyPair,

    # The instance type for the beta stage
    [Parameter()]
    [string]
    $betaInstanceType = "t2.small",

    # The instance type for the prod stage
    [Parameter()]
    [string]
    $prodInstanceType = "t2.medium",

	# true or false if you want the RDP port opened.
    [Parameter()]
    [bool]
    $openRDPPort
)

function _LaunchCloudFormationStack([string]$bucketName, [string]$betaInstanceType, [string]$prodInstanceType, [string]$keyPair, [bool]$openRDP)
{
    Write-Host "Creating CloudFormation Stack to launch an EC2 instance and configure it for CodeDeploy deployments"

    $templatePath = [System.IO.Path]::GetFullPath([System.IO.Path]::Combine($PSScriptRoot, "./CloudFormationSetupProject/cloudformation.template"))
    $templateBody = [System.IO.File]::ReadAllText($templatePath)

    $imageId = (Get-EC2ImageByName WINDOWS_2012R2_BASE).ImageId

    if ($openRDP) 
    {
        $openRDPTranslated = "Yes"
    }
    else 
    {
        $openRDPTranslated = "No"
    }

    $parameters = @(
        @{ParameterKey = "ImageId"; ParameterValue = $imageId},
        @{ParameterKey = "BetaInstanceType"; ParameterValue = $betaInstanceType},
        @{ParameterKey = "ProdInstanceType"; ParameterValue = $prodInstanceType},
        @{ParameterKey = "EC2KeyName"; ParameterValue = $keyPair},
        @{ParameterKey = "OpenRemoteDesktopPort"; ParameterValue = $openRDPTranslated},
        @{ParameterKey = "PipelineBucket"; ParameterValue = $bucketName}
    )

    $stackId = New-CFNStack -StackName "ExploringAspNetCore-Part2" -Capability "CAPABILITY_IAM" -Parameter $parameters -TemplateBody $templateBody
    $stackId
}


function _SetupPipelineBucket()
{
    $bucketName = ("ExploringAspNetCore-Part2-" + [System.DateTime]::Now.Ticks).ToLowerInvariant()
    $bucket = New-S3Bucket -BucketName $bucketName
    Write-S3BucketVersioning -BucketName $bucketName -VersioningConfig_Status Enabled

    Write-Host 'Setting up S3 source for pipeline: ' $bucketName
    Add-Type -assembly "system.io.compression.filesystem"
    $source = [System.io.Path]::Combine($PSScriptRoot, '..')
    $destination = [System.io.Path]::Combine([System.io.Path]::GetTempPath(),  'aws-blog-net-exploring-aspnet-core.zip')
    If (Test-Path $destination)
    {
	    Remove-Item $destination
    }
    
    Write-Host 'Zipping up repository for initial deployment in pipeline'
    [io.compression.zipfile]::CreateFromDirectory($source, $destination)

    Write-Host 'Writing zip to S3'
    Write-S3Object -BucketName $bucketName -File $destination -Key 'aws-blog-net-exploring-aspnet-core.zip'

    $bucketName
}

function ProcessInput([string]$betaInstanceType,[string]$prodInstanceType,[string]$keyPair,[bool]$openRDPPort)
{
    if ((Get-AWSCredentials) -eq $null)
    {
        throw "You must set credentials via Set-AWSCredentials before running this cmdlet."
    }
    if ((Get-DefaultAWSRegion) -eq $null)
    {
        throw "You must set a region via Set-DefaultAWSRegion before running this cmdlet."
    }

    $bucketName = _SetupPipelineBucket
    $stackId = _LaunchCloudFormationStack $bucketName $betaInstanceType $prodInstanceType $keyPair $openRDPPort
    $stack = Get-CFNStack -StackName $stackId

    while ($stack.StackStatus.Value.toLower().EndsWith('in_progress'))
    {
        $stack = Get-CFNStack -StackName $stackId
        "Waiting for CloudFormation Stack to be created"
        Start-Sleep -Seconds 10
    }

    if ($stack.StackStatus -ne "CREATE_COMPLETE") 
    {
        "CloudFormation Stack was not successfully created, view the stack events for further information on the failure"
        Exit
    }

    $betaDNS = ""
    $prodDNS = ""

    ForEach($output in $stack.Outputs)
    {
        if($output.OutputKey -eq "CodeDeployTrustRoleARN")
        {
            $serviceRoleARN = $output.OutputValue
        }
        elseif($output.OutputKey -eq "BetaDNS")
        {
            $betaDNS = $output.OutputValue        
        }
        elseif($output.OutputKey -eq "ProdDNS")
        {
            $prodDNS = $output.OutputValue        
        }
    }


    ("CodePipeline environment setup complete")
    ("Beta Stage DNS: " + $betaDNS)
    ("Prod Stage DNS: " + $prodDNS)
    ("S3 Bucket for Pipeline Source: " + $bucketName)
    ("S3 Object Key for Pipeline Source: aws-blog-net-exploring-aspnet-core.zip")
}


ProcessInput $betaInstanceType $prodInstanceType $ec2KeyPair $openRDPPort