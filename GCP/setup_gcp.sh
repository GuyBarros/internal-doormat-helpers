export VAULT_ADDR=$(terraform output -json | jq -r .vault_url.value)
export VAULT_TOKEN=$(jq -r ."root_token" vault-init.json)

#Auth into Doormat GCP Account
gcloud auth login
gcloud auth application-default login


#GCP Setup
export GCP_PROJECT_ID=$(gcloud projects list --format=json | jq -r ".[0].projectId")

gcloud config set project $GCP_PROJECT_ID

gcloud services enable iam.googleapis.com
gcloud services enable cloudresourcemanager.googleapis.com


gcloud services list --enabled | grep 'resource\|iam'


gcloud iam service-accounts create \
    VaultServiceAccount \
    --display-name="VaultServiceAccount"

gcloud iam roles create VaultServiceRole \
    --project=$GCP_PROJECT_ID \
    --title=VaultServiceRole \
    --stage=GA \
    --permissions=iam.serviceAccounts.create,iam.serviceAccounts.delete,iam.serviceAccounts.get,iam.serviceAccounts.list,iam.serviceAccounts.update,iam.serviceAccountKeys.create,iam.serviceAccountKeys.delete,iam.serviceAccountKeys.get,iam.serviceAccountKeys.list,iam.serviceAccounts.getAccessToken,resourcemanager.projects.getIamPolicy,resourcemanager.projects.setIamPolicy


ROLE_NAME=$(gcloud iam roles list --project=$GCP_PROJECT_ID --format=json --filter="vault" | jq -r ".[0].name" )

SERVICE_ACCOUNT=$(gcloud iam service-accounts list --project=$GCP_PROJECT_ID --filter=vault --format=json | jq -r ".[].email")

gcloud projects add-iam-policy-binding $GCP_PROJECT_ID \
    --member="serviceAccount:$SERVICE_ACCOUNT" \
    --role="$ROLE_NAME"

gcloud iam service-accounts keys create VaultServiceAccountKey.json \
    --iam-account=$SERVICE_ACCOUNT \
    --project=$GCP_PROJECT_ID

tee ./gcpbindings.hcl <<EOF
 resource "//cloudresourcemanager.googleapis.com/projects/$GCP_PROJECT_ID" {
        roles = ["roles/viewer"]
      }
EOF

# Vault Setup
vault secrets enable gcp

vault write gcp/config \
    ttl="2m" \
    max_ttl="10m" \
    credentials=@VaultServiceAccountKey.json

vault write gcp/roleset/test \
    project=$GCP_PROJECT_ID \
    secret_type="access_token"  \
    token_scopes="https://www.googleapis.com/auth/cloud-platform" \
    bindings=@gcpbindings.hcl

vault read gcp/roleset/test/token