# Running a Customer Docker Container in an Azure App Service (aka web app or website)
>This tutorial deploys Drupal 7. However, the steps and pricipals can be applied to other customer containers too.
## Prerequisites (required)
1. Install the [Azure CLI](https://docs.microsoft.com/en-us/cli/azure/install-azure-cli?view=azure-cli-latest) on your local machine.
2. Install [Docker CE](https://docs.docker.com/install/) on your local machine. 
3. Create a [Docker Hub](https://hub.docker.com) account or an [Azure Container Registry] (ACR).(https://docs.microsoft.com/en-us/azure/container-registry/container-registry-get-started-portal).
4. Note your username and password for ACR or for Docker Hub. You'll need the credentials to push your Docker image to the repository. The ACR credentials are not the same as the credentials you use to log into the Azure portal. 
## Prerequisites (optional)
1. If you are new to Docker, read the [overview](https://docs.docker.com/engine/docker-overview/).
2. Install [Visual Studio Code](https://code.visualstudio.com/) (VS Code).
3. Install the [VS Code Azure Account Extension ](https://marketplace.visualstudio.com/items?itemName=ms-vscode.azure-account).
4. Install the [VS Code Docker Extension](https://marketplace.visualstudio.com/items?itemName=PeterJausovec.vscode-docker).
 
## Instructions 
### How to Build the Base Docker Image
>WHY? The base image takes several minutes to create. Waiting several minutes everytime you deploy your web site gets tedious. Instead I like to create a base image, and then I build my main image everytime I deploy. Because the main image is based on the base image, the main image is created in less than 30 seconds.

1. Run `docker build --rm -f "Dockerfile.BASE" -t creg7smg.azurecr.io/drupal-7-as-an-azure-app-service:base .` (NOTE: include the period. If you are using Docker Hub and not ACS, remove `creg7smg.azurecr.io/`)
>creg7smg.azurecr.io is the name of my Docker repository. Replace it with your repository name.

<details><summary>Visual Studio Code - Build (click here)</summary>
<p>

![myimage]

[myimage]: images/VSCode-Dockerfile_Build.png 
</p>
</details>

### How to Build the Main Docker Image
1. Edit line 1 of `Dockerfile`. The `FROM` command should reference the base image name For example:
 `FROM creg7smg.azurecr.io/drupal-7-as-an-azure-app-service:base`
2. Run `docker build --rm -f "Dockerfile.MAIN" -t creg7smg.azurecr.io/drupal-7-as-an-azure-app-service:latest .`

<details><summary>Visual Studio Code - Run (click here)</summary>
<p>

![myimage]

[myimage]: images/VSCode-Dockerfile_Run.png 
</p>
</details>

### How to Run your Site Locally
1. Run `docker run --rm -it -p 2222:2222 -p 80:80 drupal-7-as-an-azure-app-service:latest`
2. Open a web browser and navigate to http://localhost. You should see the Drual logo and the title "Select an installation profile"
3. To get to the bash prompt inside of your now running container, in another terminal window, run:
`docker exec -it vigilant_elion /bin/sh`
>Replace vigilant_elion with the name of your running container. To see what containers are running and their names, run `docker ps -a`

>If you successfully got to the webpage showing the Drupal logo, you can move to the next steps. Otherwise, it's time to troubleshoot.

4. You'll now push (upload) both the base image and the main images to a container registery so that others, including Azure, can use it: Run `docker push creg7smg.azurecr.io/drupal-7-as-an-azure-app-service:base` . Again replace creg7smg.azurecr.io with the name of your Docker repository.
5. Now push the main image. Run `docker push creg7smg.azurecr.io/drupal-7-as-an-azure-app-service:latest`

<details><summary>Visual Studio Code - Push (click here)</summary>
<p>

![myimage]

[myimage]: images/VSCode-Dockerfile_Push.png 
</p>
</details>

## How to Create Your Website In Azure
> Prerequisite: complete the steps in the section above: How to Build the Base Image

1. Open a command prompt to use the Azure CLI. First, login. For help,
 see [here](https://docs.microsoft.com/en-us/cli/azure/authenticate-azure-cli?view=azure-cli-latest).

     `az login`

2. Edit the following parameters and then copy/paste into the Azure CLI. Remove the `$` in from each parameter if you are in bash. Keep the dollar signs if you are in PowerShell.
```
$SUBSCRIPTION="Your Subscription Name"
$RESOURCEGROUP="rg-smg-euwe"
$LOCATION="westeurope"
$PLANNAME="myappserviceplan"
$PLANSKU="B1"
$SITENAME="myappservice829601"
$RUNTIME="DOCKER|mycontainerregistryname.azurecr.io/drupal7_for_docker:base"
$IMAGENAME="mycontainerregistryname.azurecr.io/drupal7_for_docker:base"
$SERVERURL="https://mycontainerregistryname.azurecr.io"
$SERVERUSER="MyContainerRegistryUsername"
$SERVERPASSWORD="your password here"
```
> Replace the values above with your custom values. For example, replace mycontainerregistryname with the name of your Azure container registery. Get your the `SERVERUSER` and `SERVERPASSWORD` from the Azure Container Registery section of the Azure portal. The `RUNTIME` and `IMAGENAME` should be identical except for the `DOCKER|`

> To see a list all of the available subscriptions run `az account list -o table`

> Pricing for the different plan SKUs is [here](https://azure.microsoft.com/en-us/pricing/details/app-service/).

> To get a list of Azure locations (regions) where a particular VM size (sku) is avaialble run: `az appservice list-locations --linux-workers-enabled --output table --subscription $SUBSCRIPTION --sku B1`

> List of potentially available regions for the LOCATION parameter: centralus, eastasia, southeastasia, eastus, eastus2, westus, westus2, northcentralus, southcentralus, westcentralus, northeurope, westeurope, japaneast, japanwest, brazilsouth, australiasoutheast, australiaeast, westindia, southindia, centralindia, canadacentral, canadaeast, uksouth, ukwest, koreacentral, koreasouth, francecentral

5. Set the default subscription for subsequent operations

    `az account set --subscription $SUBSCRIPTION`

6. Create a resource group for your application

    `az group create --name $RESOURCEGROUP --location $LOCATION`

7. Create an app service plan (a virtual machine) where your site will run

    `az appservice plan create --name $PLANNAME --location $LOCATION --is-linux --sku $PLANSKU --resource-group $RESOURCEGROUP`

8. Create the web application (app service) on the plan. specify the node version your app requires

    `az webapp create --name $SITENAME --plan $PLANNAME --deployment-container-image-name $IMAGENAME --resource-group $RESOURCEGROUP`

9. Configure the container information

    `az webapp config container set --docker-custom-image-name $IMAGENAME --docker-registry-server-url $SERVERURL --docker-registry-server-user $SERVERUSER --docker-registry-server-password $SERVERPASSWORD  --name $SITENAME --resource-group $RESOURCEGROUP`

### How to Configure your Azure App Service 

PowerShell
$props = (Invoke-AzureRMResourceAction -ResourceGroupName $myResourceGroup `
 -ResourceType Microsoft.Web/sites/Config -Name $mySite/appsettings `
 -Action list -ApiVersion 2015-08-01 -Force).Properties

$hash = @{}
 $props | Get-Member -MemberType NoteProperty | % { $hash[$_.Name] = $props.($_.Name) }

$hash.WEBSITES_ENABLE_APP_SERVICE_STORAGE" = "true"
$hash.WEBSITES_CONTAINER_START_TIME_LIMIT = "600"

Set-AzureRmWebApp -ResourceGroup  $myResourceGroup -Name $mySite -AppSettings $hash 

1. Add or update the application settings. To do so, using the Azure portal, navigate to your app service. Under settings scroll down until you see `Application settings`
2. Since we need your Drupal files to be persisted, add or update the Setting ```WEBSITES_ENABLE_APP_SERVICE_STORAGE``` = true 
>If the ```WEBSITES_ENABLE_APP_SERVICE_STORAGE``` setting is false, the /home/ directory will not be shared across scale instances, and files that are written there will not be persisted across restarts.
3. Pulling and running your image may need some time. Add or update the setting: ```WEBSITES_CONTAINER_START_TIME_LIMIT``` = 600
4. FTP into your app service and update settings.php to reflect your Drupal database location. Instructions are [here](https://docs.microsoft.com/en-us/azure/app-service/app-service-deploy-ftp?toc=%2fazure%2fapp-service%2fcontainers%2ftoc.json).

## How to Deploy Code Changes to your Azure App Service
1. Set up continuous delivery as described [here](https://blogs.msdn.microsoft.com/devops/2017/05/10/use-azure-portal-to-setup-continuous-delivery-for-web-app-on-linux/). Alternatively, follow the steps [here](https://docs.microsoft.com/en-us/vsts/build-release/apps/cd/azure/aspnet-core-to-acr?view=vsts).
   
    ![alt text](https://docs.microsoft.com/en-us/vsts/build-release/apps/cd/azure/_img/aspnet-core-to-acr/cicddockerflow.png?view=vsts)


## Troubleshooting
1. Turn on diagnostics inside of your app service. To do so, in the Azure portal, navigate to your app service. Under settings scroll down until you see `Diagnostic logs`. 
2. Full documentation is [here](https://docs.microsoft.com/en-us/azure/app-service/containers/).
3. Read the [FAQ](https://docs.microsoft.com/en-us/azure/app-service/containers/app-service-linux-faq).
