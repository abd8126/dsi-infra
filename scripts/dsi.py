import sys
import boto3
import argparse

# add user by using: python dsi.py add-etldev 
# delete user by using: python dsi.py delete-etldev

CMD_ADD_ETLDEV = "add-etldev"
CMD_DELETE_ETLDEV = "delete-etldev"

iam = boto3.resource('iam')
iam_client = boto3.client('iam')

parser = argparse.ArgumentParser("dsi")
parser.add_argument("cmd", help=CMD_ADD_ETLDEV, type=str)

args = parser.parse_args()

cmd = args.cmd
 
email = input("Enter user email: ")

username = f"{email}-etldev"


if (cmd == CMD_ADD_ETLDEV):
    tenant_name = input("Enter tenant name: ")
    search_group_name = f"{tenant_name}ETLDevUserGroup"

    print(f"Attempting to add an etldev user {username} and put into usergroup {search_group_name}")
    created_user = None
    try:
        created_user = iam.create_user(UserName=username)
    except:
        created_user = None
        print(f"* Failed to create user {username}\nThey may exist already - will still attempt to add to group")


    if (created_user is not None):
        access_key_response = iam_client.create_access_key(UserName=username)
        access_key_inner = access_key_response['AccessKey']
        print("\n********************\n")
        print(f"Send these access details to user with email: {email}")
        print(f"ACCESS KEY ID: {access_key_inner['AccessKeyId']}")
        print(f"ACCESS KEY: {access_key_inner['SecretAccessKey']}")
        print("\n********************\n")

    
    group_list_rsp = iam_client.list_groups()
    group_list = group_list_rsp['Groups']

    tenant_group = None

    
    for group in group_list:
        if (group['GroupName'] == search_group_name):
            tenant_group = group
            break

    if (tenant_group is not None):
        iam_client.add_user_to_group(GroupName=search_group_name, UserName=username)
        print(f"Added user {username} to group {search_group_name}")
    else:
        print(f"Group not found: {search_group_name} * Could not add user to group")

elif (cmd == CMD_DELETE_ETLDEV):
    if (username.endswith("-etldev")):
        delete_yn = input(f"Are you sure you wish to DELETE user {username}? (Y/N): ")
        if (delete_yn == "y" or delete_yn == "Y"):
            group_list = iam_client.list_groups_for_user(UserName=username)
            
            for group in group_list['Groups']:
                iam_client.remove_user_from_group(GroupName=group['GroupName'], UserName=username)
                print(f"Removed user from group {group['GroupName']}")
            
            access_key_list = iam_client.list_access_keys(UserName=username)
            
            for access_key_meta in access_key_list['AccessKeyMetadata']:
                access_key_id = access_key_meta['AccessKeyId']
                iam_client.delete_access_key(UserName=username, AccessKeyId=access_key_id)
                print(f"Removed AccessKeyId: {access_key_id}")

            user_to_delete = iam.User(username)
            user_to_delete.delete()
            print(f"Deleted user: {username}")
    else:
        print("**** This script can only delete etl-dev users - NO ACTION TAKEN")
