# Cabinet Office - Data Science & Insight Platform
Data Science platform infrastructure for use by tenants in the Cabinet Office deployed in [AWS](aws.amazon.com)
## Infrastructure Overview
[Terraform](https://www.terraform.io) is used to deploy all infrastructure components.
Modules and deployments are defined in the [terraform](./terraform) directory.
## DSI-COLLAB-FRAMEWORK Submodule

So the submodule dsi-collab-framework (https://github.com/cabinetoffie maince/dsi-collab-framework.git) has been cloned into dsi_framework as a git submodule. To update this submodule use the following command:

```shell
$ git submodule init
$ git submodule update --init

When changes have been made to dsi-collab-framework and you intend to update the submodule with these changes, run the following command:
$ git submodule foreach git pull origin main
```
## workflowcli
The `workflowcli` command line utility allows a user to create, list, retrieve and update workflows between the local environment and AWS Glue.
If run locally a temporary docker container will be spun up to ensure the commands are run inside the correct environment.
### Setup
A virtual environment must be created to use the script.
```shell
python3 -m venv venv
source venv/bin/activate
pip install -r requirements.txt
```
This will install the requirements to run the script
#### Global Arguments
```shell
$ ./scripts/workflowcli -h
usage: workflowcli [-h] [-r REGION] [-d DSI_COLLAB_DIR] [-p PROFILE] [-v] [-e ENVIRONMENT]
                   {list,list-remote,get,update,create,delete,blueprint-runs,blueprint-run,list-tables,list-databases,delete-table,list-scripts,upload-scripts,run-all} ...
positional arguments:
  {list,list-remote,get,update,create,delete,blueprint-runs,blueprint-run,list-tables,list-databases,delete-table,list-scripts,upload-scripts,run-all}
optional arguments:
  -h, --help            show this help message and exit
  -r REGION, --region REGION
                        The AWS Region to use. Will default to AWS_REGION environment variable
  -d DSI_COLLAB_DIR, --dsi-collab-dir DSI_COLLAB_DIR
                        The Path to use for 'dsi-collab'. Inside a container this is the mounted folder.
  -p PROFILE, --profile PROFILE
                        The AWS Profile to use. Will default to AWS_PROFILE environment variable
  -v, --verbose         Show verbose output
  -e ENVIRONMENT, --environment ENVIRONMENT
                        AWS Environment to run script against. Valid values are: ['dev', 'smgm', 'stage', 'sitcen']
```
### create [workflow_name]
This creates a new workflow with specified name. If the workflow already exists remotely, it throws an error.
### list
This command will list workflows in the local environment
```shell
$ ./scripts/workflowcli list
Workflow: CDDO-Contract
Workflow: CDDO-DOaS
Workflow: CDDO-FE
Workflow: CDDO-OSCAR
Workflow: CDDO-template
Workflow: IPA-template
Workflow: No10-template
Workflow: Shared-example
Workflow: SitCen-wr-api1-admission-metrics
Workflow: SitCen-wr-api1-deaths
Workflow: SitCen-wr-api1-nhs-metrics
Workflow: SitCen-wr-api1-nhs-winter-risks
Workflow: SitCen-wr-api1-stp-level
Workflow: SitCen-wr-api2-weather-warning
Workflow: SitCen-wr-api3-flood-guidance
Workflow: SitCen-wr-api5-boc
Workflow: SitCen-wr-api6-cqc-social-care
Workflow: SitCen-wr-api8-flood-alerts
```
### get [workflow_name]
This command will go and retrieve a local workflow configuration and will check the local configuration against the remote configuration and will display if anything needs to be changed. The user can then use the `update` command to perform these changes.
```shell
$ ./scripts/workflowcli get SitCen-wr-api8-flood-alerts
Workflow Trigger SitCen-wr-api8-flood-alerts -> SitCen-wr-api8-flood-alerts_starting_trigger has a current schedule but none is set in workflow-config.json
Job Script File change needed for [Job: SitCen-wr-api8-flood-alerts-extract_a66f1a2f] in SitCen-wr-api8-flood-alerts: s3://all-dev-tenant-scripts-bucket/SitCen/wr-api8-flood-alerts/api8_flood_alerts.py -> s3://all-dev-tenant-scripts-bucket/SitCen/wr-api8-flood-alerts/api8_flood_alerts_extract.py
Workflow: SitCen-wr-api8-flood-alerts -> [LOCAL: True | REMOTE: True]
```
### create [workflow_name]
This command will check for the existence of an existing workflow, remove all associated, triggers, jobs and crawlers before creating a new instance of the workflow from the `default` blueprint
```shell
$ ./scripts/workflowcli create SitCen-wr-api8-flood-alerts
```
### update [workflow_name]
This gets the specified workflow and updates it with any changes in the workflow parameters by first removing the workflow and re-creating it.
```shell
$ ./scripts/workflowcli update SitCen-wr-api8-flood-alerts
```
### delete [workflow_name]
This can be used to delete an already existing workflow and associated triggers, jobs and crawlers.
```shell
$ ./scripts/workflowcli delete SitCen-wr-api8-flood-alerts
```
### run-all [--delete] [-t, --tenant (tenant)]
This command will create (and optionally delete if the workflows and associated
artifacts exist) all workflows optionally targeting a single tenant.
```shell
# RUN ALL WORKFLOWS FOR ALL TENANTS BUT SKIP ANY THAT EXIST
$ ./scripts/workflowcli run-all
```
```shell
# RUN ALL WORKFLOWS DELETING ANY THAT EXIST
$ ./scripts/workflowcli run-all --delete
```
```shell
# RUN ALL WORKFLOWS FOR THE SitCen TENANT BUT SKIP ANY THAT EXIST
$ ./scripts/workflowcli run-all -t SitCen
```
```shell
# RUN ALL WORKFLOWS DELETING ANY THAT EXIST BUT ONLY FOR THE SitCen TENANT
$ ./scripts/workflowcli run-all -t SitCen --delete
```
```shell
# RUN ALL WORKFLOWS DELETING AND NOT RECREATING ANY THAT EXIST BUT ONLY FOR THE SitCen TENANT
$ ./scripts/workflowcli -e dev run-all -t SitCen --delete --delete_only
```
