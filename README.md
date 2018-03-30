# Running Drupal 7 as an Azure App Service (aka web app or website)
## How to Setup Docker
### How to Build the Base Docker Image
1. Rename `Dockerfile` to `Dockerfile.PRIMARY.txt`
2. Rename `Dockerfile.BASE.txt` to `Dockerfile` (with no file name extension)

3. Run `docker build --rm -f Dockerfile -t creg7smg.azurecr.io/drupal7_for_docker:base .`

>creg7smg.azurecr.io is the name of my Docker repository. Replace it with your repository name.

4. Run `docker push creg7smg.azurecr.io/drupal7_for_docker:base` . Again replace creg7smg.azurecr.io with the name of your Docker repository.

5. Rename `Dockerfile` back to `Dockerfile.BASE.txt`
6. Rename `Dockerfile.PRIMARY.txt` back to `Dockerfile`

### How to Build the Image with your Drupal Site
 1. Run `docker build --rm -f Dockerfile -t drupal7_for_docker:latest .` 

### How to Run your Site Locally
1. Run `docker run --rm -it -p 2222:2222 -p 80:80 drupal7_for_docker:latest`
2. To get to the bash prompt inside of your now running container:
`docker exec -it vigilant_elion /bin/sh`
>Replace vigilant_elion with the name of your running container. To see what containers are running, run `docker ps -a`


## How to Create Your Website In Azure
> Prerequisite: complete the steps in the section above: How to Build the Base Image

1. Install the [Azure CLI](https://docs.microsoft.com/en-us/cli/azure/install-azure-cli?view=azure-cli-latest) on your local machine.

2. Login. For help,
 see [here](https://docs.microsoft.com/en-us/cli/azure/?view=azure-cli-latest#az_login).

     `az login`

3. Edit the following parameters and then copy/paste into the Azure CLI. To do so, open PowerShell, the Windows Command Prompt, or Bash and then paste.
```
SUBSCRIPTION="Your Subscription Name"
RESOURCEGROUP="rg-smg-euwe"
LOCATION="westeurope"
PLANNAME="myappserviceplan"
PLANSKU="B1"
SITENAME="myappservice829601"
RUNTIME="DOCKER|mycontainerregistryname.azurecr.io/drupal7_for_docker:base"
IMAGENAME="mycontainerregistryname.azurecr.io/drupal7_for_docker:base"
SERVERURL="https://mycontainerregistryname.azurecr.io"
SERVERUSER="MyContainerRegistryUsername"
SERVERPASSWORD="your password here"
```
> Replace the values above with your customer values. For example, replace mycontainerregistryname with the name of your Azure container registery. Get your the `SERVERUSER` and `SERVERPASSWORD` from the Azure Container Registery section of the Azure portal. The `RUNTIME` and `IMAGENAME` should be identical except for the `DOCKER|`

> To see a list all of the available subscriptions run `az account list -o table`

> Pricing for the different plan SKUs is [here](https://azure.microsoft.com/en-us/pricing/details/app-service/).

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

### How to Configure you Azure App Service 
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