from terraform_to_str import compile_terraform_files

KEYWORDS = ["resource \"aws_glue_catalog_table\"", "resource \"aws_s3_bucket_object\"",
            "resource \"aws_glue_job\"", "resource \"aws_glue_workflow\"", "resource \"aws_glue_trigger\""]


def test_terraform():
    """ Test that each terraform script in the directory does the following:
            (1) creates a landing schema
            (2) creates a landing script bucket
            (3) creates an extraction Glue job
            (4) creates a staging schema
            (5) creates a staging data bucket
            (6) creates a transformation Glue job
            (7) creates a Glue workflow
            (8 / 9) creates two Glue triggers
        by searching for their Terraform resource names in
        the Terraform script.
    """
    condition_lst = []
    for terraform_file in compile_terraform_files():
        condition_lst.append(check_conditions(terraform_file))
    assert all(condition_lst)


def check_conditions(terraform_file):
    """Checks conditions outlined above for each complied Terraform file."""
    return all(check_keywords(terraform_file)) and check_comments(terraform_file)


def check_keywords(terraform_file):
    """Check existence of proper strings for conditions outlined above"""
    condition_lst = []
    condition_lst.append("resource \"aws_glue_catalog_table\"" in terraform_file)
    condition_lst.append("resource \"aws_s3_bucket_object\"" in terraform_file)
    condition_lst.append("resource \"aws_glue_job\"" in terraform_file)
    #   ensure duplicates exist by searching over the file without the first
    #   instances of the strings
    condition_lst.append("resource \"aws_glue_catalog_table\"" in terraform_file[terraform_file.index(
        "resource \"aws_glue_catalog_table\"") + 10:])
    condition_lst.append("resource \"aws_s3_bucket_object\"" in terraform_file[terraform_file.index(
        "resource \"aws_s3_bucket_object\"") + 10:])
    condition_lst.append(
        "resource \"aws_glue_job\"" in terraform_file[terraform_file.index("resource \"aws_glue_job\"") + 10:])
    condition_lst.append("resource \"aws_glue_workflow\"" in terraform_file)
    condition_lst.append("resource \"aws_glue_trigger\"" in terraform_file)
    condition_lst.append(
        "resource \"aws_glue_trigger\"" in terraform_file[terraform_file.index("resource \"aws_glue_trigger\"") + 3:])
    return condition_lst


def check_comments(terraform_file):
    """Check that no proper strings are preceded by comments"""
    # loop through lines of tf file
    for line in terraform_file.splitlines():
        # loop through keywords
        for keyword in KEYWORDS:
            # if line is contains keyword and line is a comment, immediately return false
            if keyword in line and line.lstrip()[0] == '#':
                return False
    return True
