def mount_lake_container(pAdlsContainerName):
  
    """
    mount_lake_container: 
        Takes a container name and mounts it to Databricks for easy access. 
        Prints out the name of the mount point. 
        Uses a service princple to authenticate. 
    Key Vault SecretScopeName = "KeyVault"
    Key Vault Secret with Data Lake Name: DataLakeStorageAccountName
    Key Vault Secret with ClientID = "DataLakeAuthServicePrincipleClientID"
    Key Vault Secret with ClientSecret = "DataLakeAuthServicePrincipleClientSecret"
    Key Vault Secret with TenantID = "DataLakeAuthServicePrincipleTenantID"
    """

    # KeyVault Secret Scope Name - use a variable because it is referenced multiple times
    vSecretScopeName = "KeyVault" # Fixed standardised name. To ensure deployment from DEV to PROD is seemless. 

    # Define the variables used for creating connection strings - Data Lake Related
    vAdlsAccountName = dbutils.secrets.get(scope=vSecretScopeName,key="DataLakeStorageAccountName") # e.g. "dummydatalake" - the storage account name itself
    vAdlsContainerName = pAdlsContainerName # e.g. rawdata, bronze, silver, gold, platinum etc.
    vMountPoint = "/mnt/datalake_" + vAdlsContainerName #fixed since we already parameterised the container name. Ensures there is a standard in mount point naming

    # Define the variables that have the names of the secrets in key vault that store the sensitive information we need for the conenction via Service Principle Auth
    vSecretClientID = "DataLakeAuthServicePrincipleClientID" #Name of the generic key vault secret contianing the Service Principle Name.
    vSecretClientSecret = "DataLakeAuthServicePrincipleClientSecret" #Name of the generic key vault secret contianing the Service Principle Password. 
    vSecretTenantID = "DataLakeAuthServicePrincipleTenantID" #Name of the generic key vault secret contianing the Tenant ID.

    # Get the actual secrets from key vault for the service principle
    vApplicationId = dbutils.secrets.get(scope=vSecretScopeName, key=vSecretClientID) # Application (Client) ID
    vAuthenticationKey = dbutils.secrets.get(scope=vSecretScopeName, key=vSecretClientSecret) # Application (Client) Secret Key
    vTenantId = dbutils.secrets.get(scope=vSecretScopeName, key=vSecretTenantID) # Directory (Tenant) ID

    # Using the secrets above, generate the URL to the storage account and the authentication endpoint for OAuth
    vEndpoint = "https://login.microsoftonline.com/" + vTenantId + "/oauth2/token" #Fixed URL for the endpoint
    vSource = "abfss://" + vAdlsContainerName + "@" + vAdlsAccountName + ".dfs.core.windows.net/"

    # Connecting using Service Principal secrets and OAuth
    vConfigs = {"fs.azure.account.auth.type": "OAuth", #standard
               "fs.azure.account.oauth.provider.type": "org.apache.hadoop.fs.azurebfs.oauth2.ClientCredsTokenProvider", #standard
               "fs.azure.account.oauth2.client.id": vApplicationId,
               "fs.azure.account.oauth2.client.secret": vAuthenticationKey,
               "fs.azure.account.oauth2.client.endpoint": vEndpoint}

    # Mount Data Lake Storage to Databricks File System only if the container is not already mounted
    # First generate a list of all mount points available already via dbutils.fs.mounts()
    # Then it checks the list for the new mount point we are trying to generate.
    if not any(mount.mountPoint == vMountPoint for mount in dbutils.fs.mounts()): 
      dbutils.fs.mount(
        source = vSource,
        mount_point = vMountPoint,
        extra_configs = vConfigs)

    # print the mount point used for troubleshooting in the consuming notebook
    print("Mount Point: " + vMountPoint)