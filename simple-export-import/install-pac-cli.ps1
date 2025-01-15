function Install-PacCli {
    if (-not (Get-Command pac -ErrorAction SilentlyContinue)) {
        Write-Host "Installing Power Platform CLI..."
        
        # Install Power Platform CLI
        dotnet tool install --global Microsoft.PowerApps.CLI.Tool
        if ($LASTEXITCODE -ne 0) {
            Write-Error "Failed to install Power Platform CLI"
            exit $LASTEXITCODE
        }

        Write-Host "Power Platform CLI installed successfully."
    } else {
        Write-Host "Power Platform CLI is already installed."
    }
}