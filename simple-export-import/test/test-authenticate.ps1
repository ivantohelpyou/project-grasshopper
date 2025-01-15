# Import the function
. ../authenticate.ps1

# Define the environment URL to authenticate with
$environmentUrl = "https://mztape-base.crm.dynamics.com"

# Call the function to authenticate
Authenticate -EnvironmentUrl $environmentUrl