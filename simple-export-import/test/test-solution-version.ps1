# Import the function
. ../get-solution-version.ps1

# Define the environment URL and solution unique name
$environmentUrl = "https://mztape-base.crm.dynamics.com"
$solutionUniqueName = "MztapeBaseLayer"

# Call the function to get the solution version
$version = Get-SolutionVersion -EnvironmentUrl $environmentUrl -SolutionUniqueName $solutionUniqueName

# Print the solution version
Write-Host "Solution version: $($version.Major).$($version.Minor).$($version.Build).$($version.Revision)"