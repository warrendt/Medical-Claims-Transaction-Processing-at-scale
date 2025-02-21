#!/usr/bin/pwsh

Param(
    [parameter(Mandatory=$true)][string]$resourceGroup,
    [parameter(Mandatory=$true)][string]$location,
    [parameter(Mandatory=$true)][string]$suffix,
    [parameter(Mandatory=$true)][string]$openAiName,
    [parameter(Mandatory=$true)][string]$openAiCompletionsDeployment,
    [parameter(Mandatory=$true)][string]$openAiRg,
    [parameter(Mandatory=$true)][bool]$deployAks
)

Push-Location $($MyInvocation.InvocationName | Split-Path)
$sourceFolder=$(Join-Path -Path ../.. -ChildPath infrastructure)

if ($deployAks) {
    $script="aksmain.bicep"
} else {
    $script="acamain.bicep"
}

Write-Host "--------------------------------------------------------" -ForegroundColor Yellow
Write-Host "Deploying Bicep script $script" -ForegroundColor Yellow
Write-Host "-------------------------------------------------------- " -ForegroundColor Yellow
$env:BICEP_RESOURCE_TYPED_PARAMS_AND_OUTPUTS_EXPERIMENTAL="true"
$rg = $(az group show -n $resourceGroup -o json | ConvertFrom-Json)
if (-not $rg) {
    Write-Host "Creating resource group $resourceGroup in $location" -ForegroundColor Yellow
    az group create -n $resourceGroup -l $location
}

Write-Host "Beginning the Bicep deployment..." -ForegroundColor Yellow
Push-Location $sourceFolder
$deploymentState = $(az deployment group create -g $resourceGroup --template-file $script --parameters suffix=$suffix --parameters openAiName=$openAiName --parameters openAiDeployment=$openAiCompletionsDeployment --parameters openAiRg=$openAiRg --query "properties.provisioningState" -o tsv) 
Pop-Location
Pop-Location
