# Define the paramters you will provide values for at runtime
param
(
    [parameter(Mandatory = $true)] [String] $globalParametersFilePath,
    [parameter(Mandatory = $true)] [String] $resourceGroupName,
    [parameter(Mandatory = $true)] [String] $dataFactoryName
)

# Import the cmdlets you will need below
Import-Module Az.DataFactory

# Define a new jsonb object you will populate and use as new content for the file
$newGlobalParameters = New-Object 'system.collections.generic.dictionary[string,Microsoft.Azure.Management.DataFactory.Models.GlobalParameterSpecification]'

# Write out a message for debugging and logging purposes
Write-Host "Getting global parameters JSON from: " $globalParametersFilePath

# Get the current content of the json file
$factoryFileJson = Get-Content $globalParametersFilePath

# Write out a message for debugging and logging purposes
Write-Host "Parsing JSON..."

# Convert the JSON String of the variable to a JSON OBject types variable
$factoryFileObject = [Newtonsoft.Json.Linq.JObject]::Parse($factoryFileJson)

# For each paramter in the file you need to alter, perform some actions in a for each loop
foreach ($gp in $factoryFileObject.properties.globalParameters.GetEnumerator()) {
    # Write out a message for debugging and logging purposes
    Write-Host "Adding global parameter:" $gp.Key

    # Get the value of the current loop iteration's referenced paramter
    $globalParameterValue = $gp.Value.ToObject([Microsoft.Azure.Management.DataFactory.Models.GlobalParameterSpecification])

    # Add the current loop iteration's referenced paramter to a collection
    $newGlobalParameters.Add($gp.Key, $globalParameterValue)
}

# Get the context of the target data factory to update
$dataFactory = Get-AzDataFactoryV2 -ResourceGroupName $resourceGroupName -Name $dataFactoryName

# Assign your new paramter values to this context value in memory
$dataFactory.GlobalParameters = $newGlobalParameters

# Write out a message for debugging and logging purposes
Write-Host "Updating" $newGlobalParameters.Count "global parameters."

# Force update the target data factory
Set-AzDataFactoryV2 -InputObject $dataFactory -Force