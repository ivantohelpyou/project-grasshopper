# Project Grasshopper: Solution Hydration within Development Environments in Power Platform

This repository, Project Grasshopper, provides scripts and templates to automate the export and import of solutions within your Power Platform development environments. The process leverages Azure Key Vault for secure credential storage and involves configuring JSON files, deploying resources using Bicep, and running PowerShell scripts.

## Prerequisites

- **Azure CLI**: Ensure you have the Azure CLI installed.
- **Power Platform CLI (pac cli)**: Ensure you have the Power Platform CLI installed.

## Simple Export-Import

### What It Is

The simple-export-import process is designed to streamline the export and import of solutions across multiple environments in Power Platform. It uses a configuration template to specify the environments and solutions to be managed.

### How to Use It

1. **Fill Out and Rename the JSON Template**: Start by filling out the `simple-export.template.json` file with your environment URLs and solution names. Once completed, rename the file to `simple-export.json`.
2. **Run the Script**: Execute the provided PowerShell scripts to perform the export and import operations based on the configurations specified in the JSON file.

### What It Does

The script reads the `simple-export.json` file to determine which environments and solutions to process. It then authenticates with each environment, exports the specified unmanaged and managed solutions, and stores them in a structured folder format.

### Expected Folder Structure

When you run the script, it will create an `exports` folder with the following structure:

```
exports/
    <environment-url>/
        <solution-name>/
            <version>/
                <solution-files>
```

Each environment will have its own directory, and within each environment directory, there will be subdirectories for each solution, organized by version.

### What to Expect

- **Exported Solutions**: The specified solutions will be exported from the environments and saved in the `exports` folder.
- **Logs and Output**: The script will provide console output indicating the progress and status of the export and import operations.
- **Secure Storage**: Credentials and other sensitive information will be securely managed using Azure Key Vault.

## Addendum: Deploy-Config Folder

The `deploy-config` folder contains configuration files and scripts for deploying resources considered for a future version of the solution hydration process. This includes:

- **Bicep Files**: Used to deploy Azure resources such as Key Vault, Storage Account, and Azure AD applications.
- **Configuration Files**: JSON files that specify the deployment parameters, such as subscription ID, tenant ID, resource group name, and service principal details.
- **Deployment Scripts**: PowerShell scripts that automate the deployment process, including setting up the service principal and assigning roles.

By following the instructions and using the provided templates and scripts, you can efficiently manage the export and import of solutions within your Power Platform development environments.