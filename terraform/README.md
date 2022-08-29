# Terraform deployments and modules

## Module usage

AWS Modules from the [Terraform Registry](https://registry.terraform.io/namespaces/terraform-aws-modules) are used whenever possible. This reduces the need to write custom code.

## Deployments

Terraform is applied from within the separate deployment directories. Modules and any other resources are defined within these directories. Deployment to separate environments are done using [Terraform Workspaces](https://www.terraform.io/docs/language/state/workspaces.html).
Running Terraform locally will require access to AWS credentials. [These can be set up in many ways](https://docs.aws.amazon.com/cli/latest/userguide/cli-chap-configure.html). To list existing workspaces, run:

```hcl
terraform init
```

and then:

```hcl
terraform workspace list
```

### Base Deployment
The base deployment needs to be deployed first as it creates resources such as a VPC and networking components that other deployment rely on.

### Geo Deployment
Geospatial/GIS resources have been grouped into the geo deployment.
