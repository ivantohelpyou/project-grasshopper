param (
    [string]$Action = "both"
)

# Load configuration
. ./load-config.ps1
$config = Load-Config -ConfigPath "./simple-export.json"

# Install Power Platform CLI if not already installed
. ./install-pac-cli.ps1
Install-PacCli

Write-Host "Action: '$Action'"
switch ($Action.ToLower()) {
    "export" {
        Write-Host "Action: Export"
        # Export unmanaged solutions
        . ./export-unmanaged-solutions.ps1 -Config $config
    }
    "import" {
        Write-Host "Action: Import"
        # Import managed solutions
        . ./import-managed-solutions.ps1 -Config $config
    }
    default {
        Write-Host "Action: Both (Export and Import)"
        # Export unmanaged solutions
        . ./export-unmanaged-solutions.ps1 -Config $config

        # Import managed solutions
        . ./import-managed-solutions.ps1 -Config $config
    }
}

Write-Host "All solutions processed successfully."