#Start by loging in to your tenant 
#using doormat web UI, login to the Azure Portal

# choose the correct subscription

# if you requested the correct AD Roles, the your tenant ID will have the same ending.
az login --tenant 237fbc04-c52a-458b-af97-eaf7157c0cd4


#Tenant: 237fbc04-c52a-458b-af97-eaf7157c0cd4
#Subscription: guy-azure-20240930-test (02405acf-a75a-4a87-be6f-25943dc6cb6c)

#Add your Azure wif enabled Vault
export VAULT_ADDR=<YOUR_VAULT_ADDRESS>
export VAULT_TOKEN=<YOUR_VAULT_TOKEN>

AZURE_DETAILS=$(az account show)

export TF_VAR_subscription_id=$(echo $AZURE_DETAILS | jq -r .id)
export TF_VAR_vault_addr=$(echo $VAULT_ADDR)
export TF_VAR_vault_app_name=vault-platform-all-in-one


terraform init

terraform plan

terraform apply


