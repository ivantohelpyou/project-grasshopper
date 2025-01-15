# Import the function
. ../get-solutions.ps1

# Define the environment URL
$environmentUrl = "https://mztape-base.crm.dynamics.com"

# Call the function to get raw solutions output
$solutionsOutput = Get-Solutions -EnvironmentUrl $environmentUrl -Verbose

# Print the raw solutions output
Write-Host "Raw solutions output:"
Write-Host $solutionsOutput