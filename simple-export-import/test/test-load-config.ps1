# Import the function
. ../load-config.ps1

# Define the path to the configuration file
$configPath = "../simple-export.json"

# Call the function and capture the output
$config = Load-Config -ConfigPath $configPath

# Print the loaded configuration
Write-Host "Loaded configuration:"
$config.environments | ForEach-Object { 
    Write-Host "Environment URL: $($_.url)"
    Write-Host "  Solutions: $($_.solutions -join ', ')"
}