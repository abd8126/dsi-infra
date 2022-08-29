# Structure Folder

```
.
├── environment
│   ├── environment.tfvars
├── functions
│   ├── lambda_authentication.py
│   ├── lambda_function.py
├── main.tf
├── variables.tf
└── README.md



## Terraform

To execute the terraform run the commands: (Repeat for every tenant)
```
terraform init
terraform workspace new [workspace_name]
terraform workspace select [workspace_name] //For switching to another workspace
terraform plan -var-file="environment/environment.tfvars"
terraform apply -var-file="environment/environment.tfvars" //for creating the infrastracture
## Below only to be used if we need to destroy the infra for a tenant
terraform destroy -var-file="environment/environment.tfvars" //for destroying the infrastracture
```

The terraform will create the lambda functions, the api gateway and the authorizer for the token authorization

To test, run a curl command as follows (change the url, API and tokem as required):
curl --location --request POST “https://x650zsbpd9.execute-api.eu-west-2.amazonaws.com/cw356_dev/SitCen/repository/winter-risks/api1-admission-metrics/run-api1_admission_metrics-1-part-r-00000” --header “Authorization: token-a0a36da71f755258”