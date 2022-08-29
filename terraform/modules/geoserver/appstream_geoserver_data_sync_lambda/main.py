import boto3
from typing import List
from os import listdir, remove, environ
from os.path import isfile, join, isdir
from pathlib import Path

s3 = boto3.client('s3')
s3_bucket_name = environ['BUCKET_NAME']
s3_prefix = 'geoserver'
efs_shared_path = '/mnt/geoserver/shared/'
path = Path(efs_shared_path)


def objects_to_sync(s3_client, bucket, dir_to_copy) -> List[str]:
    all_objects_in_prefix = s3_client.list_objects_v2(
        Bucket=bucket,
        Prefix=f'{dir_to_copy}/'
    )

    all_keys_in_prefix = [item['Key'] for item in all_objects_in_prefix['Contents']]

    try:
        all_keys_in_prefix.remove(f'{s3_prefix}/')
    except ValueError:
        print('Base object not in list of objects to copy. Continue...')

    return [key.split(f'{s3_prefix}/')[1] for key in all_keys_in_prefix]


def handler(event, context):
    objects = objects_to_sync(s3, s3_bucket_name, s3_prefix)

    if not isdir(efs_shared_path):
        print(f'{efs_shared_path} path does not exist, creating directory.')
        path.mkdir(parents=True, exist_ok=True)

    files_in_efs = [f for f in listdir(efs_shared_path) if isfile(join(efs_shared_path, f))]

    copied_objects = 0
    for object in objects:
        if object not in files_in_efs:
            print(f'Copying {object} to efs')
            s3.download_file(s3_bucket_name, f'{s3_prefix}/{object}', f'{efs_shared_path}{object}')
            copied_objects += 1

    deleted_files = 0
    for file in files_in_efs:
        if file not in objects:
            remove(f'{efs_shared_path}{file}')
            deleted_files += 1

    print(f"Copied objects: {copied_objects}")
    print(f"Deleted files: {deleted_files}")
