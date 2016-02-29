function _deleteStack()
{
    $stack = (Get-CFNStack -StackName "ExploringAspNetCore-Part1" | Where-Object {$_.StackName -eq "ExploringAspNetCore-Part1"})
    if($stack -ne $null)
    {
        Write-Host "Deleting CloudFormation existing stack"
        Remove-CFNStack $stack.StackName -Force
    }
}

function _deleteCodeDeployPrimitives()
{
    $applications = Get-CDApplicationList | Where-Object {$_.StartsWith("ExploringAspNetCorePart1")}
    foreach($application in $applications)
    {
        $deploymentGroups = Get-CDDeploymentGroupList -ApplicationName $application
        foreach($deploymentGroup in $deploymentGroups.DeploymentGroups)
        {
            Write-Host ("Deleting Deployment Group " + $deploymentGroup)
            Remove-CDDeploymentGroup -ApplicationName $application -DeploymentGroupName $deploymentGroup -Force
        }

        Write-Host ("Deleting CodeDeploy Application " + $application)
        Remove-CDApplication -ApplicationName  $application -Force
    }
}

_deleteCodeDeployPrimitives
_deleteStack