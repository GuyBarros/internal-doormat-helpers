#Start by requesting Azure AD Developer access via Doormat.
#then request a temporary Azure Subscription

#using doormat web UI, login to the Azure Portal

# if you requested the correct AD Roles, the your tenant ID will be this
az account clear
az login --tenant 237fbc04-c52a-458b-af97-eaf7157c0cd4
# choose the correct subscription

#Tenant: 237fbc04-c52a-458b-af97-eaf7157c0cd4
#Subscription: guy-azure-20240930-test (02405acf-a75a-4a87-be6f-25943dc6cb6c)

#Add your Azure wif enabled Vault
export VAULT_ADDR=<YOUR_VAULT_ADDRESS>
export VAULT_TOKEN=<YOUR_VAULT_TOKEN>

AZURE_DETAILS=$(az account show)

export TF_VAR_subscription_id=$(echo $AZURE_DETAILS | jq -r .id)
export TF_VAR_public_oidc_issuer_url=$(echo $VAULT_ADDR)


terraform init

terraform plan

terraform apply


