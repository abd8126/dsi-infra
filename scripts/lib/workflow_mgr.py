import json
import time
from typing import Dict, List, Tuple
from urllib.parse import urlparse
from os.path import dirname

import boto3
from botocore.exceptions import ClientError
import os
import re

from dsi_framework.src.dsi.workflow_attribute_extractor import DsiWorkflowAttributeExtractor

from . import utils
from dsi_framework.src.dsi.aws_context import AWSContext

TRANSFORM_RE = re.compile(r"[_-]+transform[_-]+")
EXTRACT_RE = re.compile(r"[_-]+extract[_-]+")

DEFAULT_BLUEPRINT_NAME = "default"

class Workflow(object):
    tenant: str
    name: str
    path: str
    local: bool
    remote: bool
    nodes: List[Dict[str, any]]
    local_obj: Dict[str, any]

    def __init__(self, mgr, workflow_id: str = None, path: str = None):
        self.mgr: WorkflowManager = mgr
        self.workflow_id = workflow_id
        self.path = path
        self.local = False
        self.remote = False
        self.local_obj = None
        self.root_folder = None
        if self.path is not None:
            wae = DsiWorkflowAttributeExtractor(os.path.dirname(self.path))

            self.name = wae.get_workflow_name()
            self.workflow_group_name = wae.get_workflow_group_name()
            self.tenant = wae.get_tenant_name()
            base_path = wae.get_base_path()
            self.tenant_folder = os.path.join(base_path, "src", self.tenant)
            if (not self.workflow_group_name):
                self.workflow_group_name = ""

            self.workflow_folder = os.path.join(self.tenant_folder, "workflows", self.workflow_group_name, self.name)
            
            self.workflow_group_folder = os.path.join(base_path, self.tenant, self.workflow_group_name)
            self.root_folder = self.workflow_folder
            self.tenant_lib_folder = os.path.join(self.tenant_folder, "libs")
            self.global_lib_folder = os.path.join(wae.get_base_path(), "libs")
            
            self.list_local_scripts()
            # load workflow from local path
            self._load_local()
            pass
        pass

    def __repr__(self):
        return f"Workflow: {self.key} -> [LOCAL: {self.local} | REMOTE: {self.remote}]"

    def __str__(self):
        return self.key

    @property
    def key(self):
        if (self.workflow_group_name == ""):
            result = f"{self.tenant}-{self.name}"
        else:
            result = f"{self.tenant}-{self.workflow_group_name}-{self.name}"
        return result 

    def _load_local(self):
        with open(self.path, 'r') as input_file:
            self.local_obj = json.load(input_file)
            self.local = True

    def load_remote(self, throw_if_not_found=True):
        try:
            found = True
            wf_object = self.mgr.client.get_workflow(Name=self.key, IncludeGraph=True)
            if wf_object is None or 'Workflow' not in wf_object or wf_object['Workflow'] is None:
                found = False
            if (not found and throw_if_not_found):
                raise Exception('Workflow not found')
            if found:
                wf = wf_object['Workflow']
                if 'Graph' not in wf or 'Nodes' not in wf['Graph'] or not isinstance(wf['Graph']['Nodes'], list):
                    raise Exception('Workflow Graph not found')
                self.nodes = wf['Graph']['Nodes']
                for node in self.nodes:
                    self.process_node(node)

                self.remote = True
        except Exception as e:
            if (throw_if_not_found):
                print(f"Unable to get Workflow: {self.key} -> {e}")
            self.remote = False

    def delete_remote_workflow_children_objects(self):
        try:
            wf_object = self.mgr.client.get_workflow(Name=self.key, IncludeGraph=True)
            if wf_object is None or 'Workflow' not in wf_object or wf_object['Workflow'] is None:
                raise Exception('Workflow not found')
            wf = wf_object['Workflow']
            if 'Graph' not in wf or 'Nodes' not in wf['Graph'] or not isinstance(wf['Graph']['Nodes'], list):
                raise Exception('Workflow Graph not found')
            self.remote = True
            self.nodes = wf['Graph']['Nodes']
            for node in self.nodes:
                #print(json.dumps(node))
                self.delete_node(node)
            self.nodes = []
            self.remote = False
        except Exception as e:
            print(f"Unable to get Workflow: {self.key} -> {e}")
            self.remote = False

    def process_node(self, node):
        # go get the data
        if 'Type' not in node or 'Name' not in node:
            return
        node_type = node['Type']
        node_name = node['Name']
        if node_type == "JOB":
            self.process_job(self.mgr.get_job(node_name))
        elif node_type == "TRIGGER":
            self.process_trigger(self.mgr.get_trigger(node_name))
        elif node_type == "CRAWLER":
            self.process_crawler(self.mgr.get_crawler(node_name))

    def delete_node(self, node):
        # go get the data
        if 'Type' not in node or 'Name' not in node:
            return
        node_type = node['Type']
        node_name = node['Name']
        if node_type == "JOB":
            self.mgr.delete_job(node_name)
        elif node_type == "TRIGGER":
            self.mgr.delete_trigger(node_name)
        elif node_type == "CRAWLER":
            self.mgr.delete_crawler(node_name)
        else:
            print(f"Unable to process unknown node_type {node_type} for node {node_name}")

    def process_job(self, job):
        if job is None or 'Job' not in job:
            return
        job = job['Job']
        # print(json.dumps(job, indent=4, sort_keys=True, default=str))
        if 'Command' not in job or job['Command'] is None or 'ScriptLocation' not in job['Command']:
            return
        name = job['Name']
        script = job['Command']['ScriptLocation']
        local_target_script = None
        if EXTRACT_RE.search(name):
            local_target_script = self.local_obj['ExtractScriptNameNoExt']
        elif TRANSFORM_RE.search(name):
            local_target_script = self.local_obj['TransformScriptNameNoExt']
        else:
            print(f"Workflow Job {self.key} -> {name} is neither an extract or transform job")
            return

        # print(local_target_script)
        parsed_uri = urlparse(script)
        file = os.path.basename(parsed_uri.path)
        root_path = os.path.dirname(parsed_uri.path)
        if file != local_target_script + ".py":
            if self.mgr.verbose:
                print(
                    f"Workflow Job File {self.key} -> {name} // {file} is different from local workflow-config.json value {local_target_script}")
            new_uri = f"{parsed_uri.scheme}://{parsed_uri.netloc}{root_path}/{local_target_script}.py"
            print(f"Job Script File change needed for [Job: {name}] in {self.key}: {script} -> {new_uri}")

    def process_crawler(self, crawler):
        pass

    def process_trigger(self, trigger):
        if trigger is None or 'Trigger' not in trigger:
            return
        trigger = trigger['Trigger']
        trigger_type = trigger['Type']
        trigger_state = trigger['State']
        if trigger_state != "ACTIVATED":
            return
        elif trigger_type == "SCHEDULED":
            if 'Schedule' not in trigger:
                print(f"Workflow Trigger {self.key} -> {trigger['Name']} has no schedule set in AWS")
                return
            trigger_schedule = trigger['Schedule']
            if 'FrequencyCronFormat' not in self.local_obj:
                print(f"Workflow Trigger {self.key} -> {trigger['Name']} has a current schedule but none is set in workflow-config.json")
                return
            current_schedule = self.local_obj['FrequencyCronFormat']
            if current_schedule == "" or current_schedule is None:
                print(f"Workflow Trigger {self.key} -> {trigger['Name']} has a current schedule but none is set in workflow-config.json")
                return
            #print(f"Trigger Schedule Change needed for {self.key}: {trigger_schedule} -> {current_schedule}")

    def list_local_scripts(self):
        if self.root_folder is not None:
            # get all py files at path
            #print(f"Script root folder {self.root_folder}")
            self.local_scripts = [x for x in utils.get_files_in_dir_with_ext(self.workflow_folder)]
            self.local_scripts.extend([x for x in utils.get_files_in_dir_with_ext(self.tenant_lib_folder)])
            self.local_scripts.extend([x for x in utils.get_files_in_dir_with_ext(self.global_lib_folder)])
            return [x[1] for x in self.local_scripts]
        return []

    def upload_scripts(self):
        # ExtractScriptNameNoExt and TransformScriptNameNoExt
        if self.local and self.local_obj is not None:
            new_list: List[Tuple[str, str]] = []
            for script_item in self.local_scripts:
                extractScriptNameNoExt = self.local_obj['ExtractScriptNameNoExt']
                transformScriptNameNoExt = self.local_obj['TransformScriptNameNoExt']
                if script_item[1] == extractScriptNameNoExt or \
                        script_item[1] == transformScriptNameNoExt or \
                        script_item[1] == f"{extractScriptNameNoExt}.py" or \
                        script_item[1] == f"{transformScriptNameNoExt}.py":
                    new_list.append(script_item)
            if len(new_list) > 0:
                self.mgr.s3_upload_scripts(self.tenant, self.workflow_group_name, self.name, new_list)
            else:
                raise Exception(f'The scripts specified in workflow-config.json do not exist in the target directory {self.tenant} {self.name}')

        # extraPythonLibs

        extraPythonLibs = self.local_obj['ExtraPythonLibs']
        file_list = []
        for script_item in self.local_scripts:
            for lib_file in extraPythonLibs:
                if lib_file == script_item[1]:
                    file_list.append(script_item)
        if len(file_list) > 0:
            self.mgr.s3_upload_scripts(tenant=self.tenant, workflow_group=None, workflow=None, file_list=file_list)
        else:
            print("No ExtraPythonLibs to upload")

    def delete_uploaded_scripts(self):
        # ExtractScriptNameNoExt and TransformScriptNameNoExt
        if self.local and self.local_obj is not None:
            new_list: List[Tuple[str, str]] = []
            for script_item in self.local_scripts:
                extractScriptNameNoExt = self.local_obj['ExtractScriptNameNoExt']
                transformScriptNameNoExt = self.local_obj['TransformScriptNameNoExt']
                if script_item[1] == extractScriptNameNoExt or \
                        script_item[1] == transformScriptNameNoExt or \
                        script_item[1] == f"{extractScriptNameNoExt}.py" or \
                        script_item[1] == f"{transformScriptNameNoExt}.py":
                    new_list.append(script_item)
            if len(new_list) > 0:
                self.mgr.s3_delete_scripts(self.tenant, self.workflow_group_name, self.name, new_list)
            else:
                raise ('The scripts epecified in workflow-config.json do not exist in the target directory')


def _load_local_workflows(mgr, tenant: str, path: str) -> Dict[str, Workflow]:
    found_workflows: Dict[str, Workflow] = {}
    # look in the directories to see if there are any workflow-config.json files
    dirs = utils.get_folders_at_path(path)
    for dir in dirs:
        fullpath = os.path.join(path, dir)
        subdirs = []
        subdirs = utils.get_folders_at_path(fullpath)
        has_subdirs = len(subdirs) > 0
        if (not has_subdirs):
            subdirs = [dir]

        for subdir in subdirs:  
            if (not has_subdirs):
                workflow_path = os.path.join(fullpath, "workflow-config.json")
            else:
                workflow_path = os.path.join(fullpath, subdir, "workflow-config.json")

            if os.path.exists(workflow_path):
                if (not has_subdirs):
                    workflow_id = f"{tenant}-{dir}"
                else:
                    workflow_id = f"{tenant}-{dir}-{subdir}"
                #print(f"Found workflow: {workflow_id}")
                found_workflows[workflow_id] = Workflow(mgr, workflow_id = workflow_id, path = workflow_path)

    return found_workflows


class WorkflowManager:
    root_path: str
    verbose: bool
    region: str
    profile: str
    context: AWSContext
    local_cache: Dict[str, Workflow]

    def __init__(self, region: str, env: str, profile: str, root_path: str = utils.get_root_dir(), verbose: bool = False):
        self.profile = profile
        self.aws_ctx_cache = {}
        self.region = region
        self.env = env
        self.script_bucket = f"all-{env}-tenant-scripts-bucket"
        self.context = AWSContext(self.region, self.profile, self.env)
        self.client = self.context.client("glue")
        self.root_path = root_path
        self.local_cache = None
        self.verbose = verbose
        self.s3 = None
        if self.verbose:
            print(f"Running against root directory: {self.root_path}")

    def get_s3_cli(self):
        if self.s3 is None:
            self.s3 = self.context.client("s3")
        return self.s3

    def list(self):
        # get a list of workflows on the local file system and remotely
        # return self.list_and_mix_workflows()
        local = self.list_local()
        return [k for k, v in local.items()]

    def list_and_mix_workflows(self) -> Dict[str, Workflow]:
        local = self.list_local()

        # with available local go get remote configs for workflows

        for k, wf in local.items():
            wf.load_remote()
        return local

    def list_remote_blueprints(self):
        try:
            # ctx = self.get_tenant_ctx(tenant)
            blueprints = self.client.list_blueprints()
            print(json.dumps(blueprints))
            return blueprints
        except Exception as e:
            print(f"ERROR: Unable to get blueprints from AWS -> {e}")
            return []

    def get_all_remote(self) -> Dict[str, Dict[str, any]]:
        try:
            workflows = self.list_remote()
            if self.verbose:
                print(json.dumps(workflows))
            if isinstance(workflows, list):
                for wf_name in workflows:
                    wf_raw = self.get_remote(wf_name)
                    print(wf_raw)
            return workflows
        except Exception as e:
            print(f"ERROR: Unable to get Workflows from AWS -> {e}")
            return {}

    def list_remote(self) -> List[str]:
        workflows = self.client.list_workflows()
        if self.verbose:
            print(json.dumps(workflows))
        if "Workflows" in workflows and isinstance(workflows["Workflows"], list):
            return workflows["Workflows"]
        return []


    def list_local(self) -> Dict[str, Workflow]:
        if self.local_cache is not None and len(self.local_cache.keys()) > 0:
            return self.local_cache
        # get a list of local workflows in a known location..
        found_workflows: Dict[str, Workflow] = {}
        dirs = utils.get_folders_at_path(self.root_path)
        for dir in dirs:
            search_path = os.path.join(self.root_path, dir)
            if 'workflows' in utils.get_folders_at_path(search_path):
                wf_path = os.path.join(search_path, "workflows")
                loaded_workflows = _load_local_workflows(self, tenant=dir, path=wf_path)
                for k, wf in loaded_workflows.items():
                    found_workflows[k] = wf
        self.local_cache = found_workflows
        return found_workflows

    def get(self, workflow, throw_if_remote_not_found=True):
        local = self.list_local()
        if workflow in local:
            wf = local.get(workflow)
            wf.load_remote(throw_if_remote_not_found)
            return wf

    def get_local(self):
        pass

    def get_trigger(self, trigger_name):
        try:
            trigger = self.client.get_trigger(Name=trigger_name)
            return trigger
        except Exception as e:
            return None

    def delete_trigger(self, trigger_name):
        print(f"deleting trigger {trigger_name}")
        self.client.delete_trigger(Name=trigger_name)

    def get_job(self, job_name):
        try:
            job = self.client.get_job(JobName=job_name)
            return job
        except Exception as e:
            return None

    def delete_job(self, job_name):
        print(f"deleting job {job_name}")
        self.client.delete_job(JobName=job_name)

    def get_crawler(self, crawler_name):
        try:
            crawler = self.client.get_crawler(Name=crawler_name)
            return crawler
        except Exception as e:
            return None

    def delete_crawler(self, crawler_name):
        print(f"deleting crawler {crawler_name}")
        response = self.client.delete_crawler(Name=crawler_name)
        #print(f"Response from delete crawler is\n {response}")

    def get_policy(self, policy_name):
        iam = boto3.resource("iam")

        policy = iam.Policy(f"arn:aws:iam::515924272305:policy/{policy_name}")
        policy.load()  # calls GetRole to load attributes
        return policy

    def policy_exists(self, policy_name):
        try:
            policy = self.get_policy(policy_name)
        except ClientError:
            return False
        else:
            return policy

    def role_exists(self, role_name):
        iam = boto3.resource("iam")
        try:
            role = iam.Role(role_name)
            role.load()  # calls GetRole to load attributes
        except ClientError:
            return False
        else:
            return role

    def get_blueprint_role(self, tenant):
        role_name = f"{tenant}BlueprintRunnerRole"
        current_role = self.role_exists(role_name)
        return current_role

    def exists_remote(self, workflow_name: str):
        wf_list = self.list_remote()
        if workflow_name in wf_list:
            return True
        return False


    def extract_blueprint_name_from_config(self, target_wf_obj):
        if "BlueprintName" in target_wf_obj:
            if target_wf_obj["BlueprintName"]:
                return target_wf_obj["BlueprintName"]

        return DEFAULT_BLUEPRINT_NAME

    def create(self, workflow_name: str):
        # create a workflow using the blueprint..
        print(f"************************ starting blueprint run for {workflow_name}")
        # check if it exists remotely
        if not self.exists_remote(workflow_name):
            # get the local instance
            target_wf = self.get(workflow_name, False)
            if target_wf is None or not target_wf.local:
                raise Exception(f"Unable to find workflow {workflow_name} locally in order to create it")

            blueprint_name = self.extract_blueprint_name_from_config(target_wf.local_obj)
            blueprint_role = self.get_blueprint_role(target_wf.tenant)

            # ensure values from the directory structure and script params override workflow-config values which may not be set correctly by devs
            target_wf.local_obj['EnvName'] = self.env
            target_wf.local_obj['TenantName'] = target_wf.tenant
            target_wf.local_obj['WorkflowName'] = target_wf.name
            target_wf.local_obj['WorkflowGroupName'] = target_wf.workflow_group_name
            
            target_wf.upload_scripts()

            blueprint_run = self.client.start_blueprint_run(BlueprintName=blueprint_name,
                                                            RoleArn=blueprint_role.arn,
                                                            Parameters=json.dumps(target_wf.local_obj))

            #print(f"Blueprint Run Status: {blueprint_run['ResponseMetadata']['HTTPStatusCode']}  RunID: {blueprint_run['RunId']}")
            #print(json.dumps(blueprint_run, indent=4, sort_keys=True, default=str))
            if 'ResponseMetadata' in blueprint_run and blueprint_run['ResponseMetadata']['HTTPStatusCode'] == 200:
                return f"Workflow {workflow_name} created successfully."
            else:
                raise Exception(f"Unable to create {workflow_name} workflow")
        else:
            raise Exception(
                f"Workflow {workflow_name} already exists in AWS. You cannot create an existing workflow. Consider using update instead.")

    def update(self, workflow_id: str):
        # delete a workflow and all associated jobs, schedulers and crawlers
        if self.exists_remote(workflow_id):
            self.delete(workflow_id)
            #time.sleep(10)
            #print("Sleeping for 10 seconds to help delete complete on server")
            self.create(workflow_id)
            return f"Workflow {workflow_id} updated successfully"
        else:
            print(f"Unable to find workflow {workflow_id} to update")

    def delete(self, workflow_id: str):
        # delete a workflow and all associated jobs, schedulers, catalogue tables and crawlers
        if self.exists_remote(workflow_id):
            target_wf = self.get(workflow_id)
            if target_wf is not None:
                print(f"Deleting {workflow_id}")
                target_wf.delete_remote_workflow_children_objects()
                self.remove_data_calatog_tables(target_wf.tenant, target_wf.name)
                self.client.delete_workflow(Name=workflow_id)
                target_wf.delete_uploaded_scripts()
                return f"{workflow_id} workflow deleted successfully"
        else:
            print(f"Unable to find workflow {workflow_id} to delete")

    def sync(self):
        pass

    def get_blueprint_runs(self, format_json=False):
        runs = self.client.get_blueprint_runs(BlueprintName="default")["BlueprintRuns"]
        if format_json:
            return runs
        for run in runs:
            # "Parameters": "{\"WorkflowName\":\"test_tenant_workflow\"
            workflow_id = ""
            if 'Parameters' in run:
                try:
                    run["Parameters"] = json.loads(run["Parameters"])
                    if 'WorkflowName' in run["Parameters"]:
                        workflow_id = f" [Workflow -> {run['Parameters']['WorkflowName']}]"
                finally:
                    pass

            print(f"Run: {run['BlueprintName']} :: {run['RunId']} {run['State']} {workflow_id}")

    def get_blueprint_run(self, run_id):
        run: Dict[str, any] = self.client.get_blueprint_run(BlueprintName="default", RunId=run_id)["BlueprintRun"]
        run["Parameters"] = json.loads(run["Parameters"])
        return run

    def list_databases(self):
        dbs = self.client.get_databases()
        if 'DatabaseList' in dbs:
            return [x["Name"] for x in dbs['DatabaseList']]
        return []

    def list_tables(self, db: str):
        tables = self.client.get_tables(DatabaseName=db)
        if 'TableList' in tables and len(tables['TableList']) > 0:
            return [x['Name'] for x in tables['TableList']]
        print(f"No tables found in database {db}")
        return []

    def delete_table(self, db: str, table: str):
        self.client.delete_table(DatabaseName=db, Name=table)

    def remove_data_calatog_tables(self, tenant_name, workflow_raw_name):
        # find and delete glue catalog tables belonging to this workflow
        #tenant_name = workflow_name.split("-")[0]
        table_name = workflow_raw_name.replace("-", "_")

        glue_catalog_databases = self.list_databases()

        for database in glue_catalog_databases:
            if database.split("_")[0].lower() == tenant_name.lower():
                # list and delete tables
                tables = self.list_tables(db=database)
                for table in tables:
                    if table.lower() == table_name:
                        self.delete_table(db=database, table=table)

    def s3_list_objects(self, path: str):
        s3 = self.get_s3_cli()
        resp = s3.list_objects_v2(Bucket=self.script_bucket, Prefix=path)
        if 'Contents' in resp:
            return resp['Contents']
        return []

    def s3_get_object(self, path: str):
        s3 = self.get_s3_cli()
        resp = s3.get_object(Bucket=self.script_bucket, Key=path)
        print(json.dumps(resp, indent=4, sort_keys=True, default=str))
        return resp

    def s3_object_exists(self, path: str):
        if self.s3_get_object(path) is not None:
            return True
        return False

    def get_file_s3_key(self, file: Tuple[str, str], tenant, workflow_group, workflow):
        if workflow is None:
            s3_key = f"{tenant}/{file[1]}"
        elif workflow_group != "":
            s3_key = f"{tenant}/{workflow_group}/{workflow}/{file[1]}"
        else:
            s3_key = f"{tenant}/{workflow}/{file[1]}"

        return s3_key

    def s3_upload_scripts(self, tenant: str, workflow_group: str, workflow: str, file_list: List[Tuple[str, str]]):
        # this will upload target files to dest in S3
        s3 = self.get_s3_cli()
        for file in file_list:
            s3_key = self.get_file_s3_key(file, tenant, workflow_group, workflow)

            #print(f"Uploading {file[0]} to {s3_key}")
            with open(file[0], "rb") as f:
                s3.put_object(Bucket=self.script_bucket, Key=s3_key, Body=f)

    def s3_delete_scripts(self, tenant: str, workflow_group: str, workflow: str, file_list: List[Tuple[str, str]]):
        # this will delete target files in dest in S3
        s3 = self.get_s3_cli()
        for file in file_list:
            s3_key = self.get_file_s3_key(file, tenant, workflow_group, workflow)
            #print(f"Deleting {file[0]} in {s3_key}")
            s3.delete_object(Bucket=self.script_bucket, Key=s3_key)

    def run_all(self, target_tenant: str = None, do_delete: bool = False, do_create: bool = True):
        # this function will create/run all workflows, optionally deleting them (via update) if required..
        local = self.list_local()
        target_list = []
        for key, wf in local.items():
            #print(f"Key: {key}  WF {wf.name}")
            if target_tenant is not None and wf.tenant == target_tenant:
                target_list.append(wf)
            elif target_tenant is None:
                target_list.append(wf)
        if len(target_list) > 0:
            for wf in target_list:

                workflow_id = wf.key
                if not do_delete:
                    if self.exists_remote(workflow_id):
                        print(f"Unable to create and run {workflow_id} as it already exists remotely. Pass the --delete flag to enable deletion before creation.")
                    else:
                        if do_create:
                            self.create(workflow_id)
                else:
                    if do_create:
                        if self.exists_remote(workflow_id):
                            self.update(workflow_id)
                        else:
                            self.create(workflow_id)
                    else:
                        if self.exists_remote(workflow_id):
                            self.delete(workflow_id)
                
                print("Sleeping for 10 seconds")
                time.sleep(10)
