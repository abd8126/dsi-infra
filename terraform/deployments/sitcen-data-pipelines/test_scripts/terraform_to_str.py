import os
from typing import List

FILES_TO_IGNORE = ["main.tf", "iam.tf", "variables.tf"]
TERRAFORM_DEPLOYMENTS_PATHNAME = ".."


def terraform_to_str(pathname: str) -> str:
    """Convert a terraform file to a string. To be used as a helper method."""
    s = ''
    with open(pathname, 'r') as terraform_file:
        for line in terraform_file:
            s += line
    return s


def compile_terraform_files() -> List[str]:
    """Return list of terraform files converted to strings."""
    # initialize empty list to contain files
    compiled_terraform_files = []
    # go back a directory
    directory = os.fsencode(TERRAFORM_DEPLOYMENTS_PATHNAME)
    # loop through files in terraform deployments directory
    for file in os.listdir(directory):
        filename = '../' + os.fsdecode(file)
        if filename.endswith(".tf") and filename not in FILES_TO_IGNORE:
            compiled_terraform_files.append(terraform_to_str(filename))
    return compiled_terraform_files
