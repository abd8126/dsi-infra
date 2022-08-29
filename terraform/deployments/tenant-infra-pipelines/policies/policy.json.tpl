{
    "Version": "2012-10-17",
    "Statement": [
        {
            "Effect": "Allow",
            "Action": "kms:DescribeKey",
            "Resource": "*"
        },
        {
            "Effect": "Allow",
            "Action": [
                "kms:Decrypt",
                "kms:Encrypt",
                "kms:GenerateDataKey",
                "kms:ReEncryptTo",
                "kms:ReEncryptFrom"
            ],
            "Resource": "*",
            "Condition": {
                "StringLike": {
                    "kms:ViaService": [
                        "dynamodb.*.amazonaws.com",
                        "ec2.*.amazonaws.com",
                        "elasticfilesystem.*.amazonaws.com",
                        "rds.*.amazonaws.com"
                    ]
                }
            }
        },
        {
            "Effect": "Allow",
            "Action": "kms:CreateGrant",
            "Resource": "*",
            "Condition": {
                "Bool": {
                    "kms:GrantIsForAWSResource": "true"
                }
            }
        },

 {
      "Sid":"S3BucketRestorePermissions",
      "Action":[
        "s3:CreateBucket",
        "s3:ListBucketVersions",
        "s3:ListBucket",
        "s3:GetBucketVersioning",
        "s3:GetBucketLocation",
        "s3:PutBucketVersioning"
      ],
      "Effect":"Allow",
      "Resource":[
        "arn:aws:s3:::*"
      ]
    },
    {
      "Sid":"S3ObjectRestorePermissions",
      "Action":[
        "s3:GetObject",
        "s3:GetObjectVersion",
        "s3:DeleteObject",
        "s3:PutObjectVersionAcl",
        "s3:GetObjectVersionAcl",
        "s3:GetObjectTagging",
        "s3:PutObjectTagging",
        "s3:GetObjectAcl",
        "s3:PutObjectAcl",
        "s3:PutObject",
        "s3:ListMultipartUploadParts"
      ],
      "Effect":"Allow",
      "Resource":[
        "arn:aws:s3:::*/*"
      ]
    },
    {
      "Sid":"S3KMSPermissions",
      "Action":[
        "kms:Decrypt",
        "kms:DescribeKey",
        "kms:GenerateDataKey"
      ],
      "Effect":"Allow",
      "Resource":"*",
      "Condition":{
        "StringLike":{
          "kms:ViaService":"s3.*.amazonaws.com"
        }
      }
    },

 {
      "Sid":"S3BucketBackupPermissions",
      "Action":[
        "s3:GetInventoryConfiguration",
        "s3:PutInventoryConfiguration",
        "s3:ListBucketVersions",
        "s3:ListBucket",
        "s3:GetBucketVersioning",
        "s3:GetBucketNotification",
        "s3:PutBucketNotification",
        "s3:GetBucketLocation",
        "s3:GetBucketTagging"
      ],
      "Effect":"Allow",
      "Resource":[
        "arn:aws:s3:::*"
      ]
    },
    {
      "Sid":"S3ObjectBackupPermissions",
      "Action":[
        "s3:GetObjectAcl",
        "s3:GetObject",
        "s3:GetObjectVersionTagging",
        "s3:GetObjectVersionAcl",
        "s3:GetObjectTagging",
        "s3:GetObjectVersion"
      ],
      "Effect":"Allow",
      "Resource":[
        "arn:aws:s3:::*/*"
      ]
    },
    {
      "Sid":"S3GlobalPermissions",
      "Action":[
        "s3:ListAllMyBuckets"
      ],
      "Effect":"Allow",
      "Resource":[
        "*"
      ]
    },
    {
      "Sid":"KMSBackupPermissions",
      "Action":[
        "kms:Decrypt",
        "kms:DescribeKey"
      ],
      "Effect":"Allow",
      "Resource":"*",
      "Condition":{
        "StringLike":{
          "kms:ViaService":"s3.*.amazonaws.com"
        }
      }
    },
    {
      "Sid":"EventsPermissions",
      "Action":[
        "events:DescribeRule",
        "events:EnableRule",
        "events:PutRule",
        "events:DeleteRule",
        "events:PutTargets",
        "events:RemoveTargets",
        "events:ListTargetsByRule",
        "events:DisableRule"
      ],
      "Effect":"Allow",
      "Resource":"arn:aws:events:*:*:rule/AwsBackupManagedRule*"
    },
    {
      "Sid":"EventsMetricsGlobalPermissions",
      "Action":[
        "cloudwatch:GetMetricData",
        "events:ListRules"
      ],
      "Effect":"Allow",
      "Resource":"*"
    },








        {
            "Effect": "Allow",
            "Action": [
                "backup:DescribeBackupVault",
                "backup:CopyIntoBackupVault"
            ],
            "Resource": "arn:aws:backup:*:*:backup-vault:*"
        },
        {
            "Effect": "Allow",
            "Action": [
                "backup:CopyFromBackupVault"
            ],
            "Resource": "*"
        },
        {
            "Action": [
                "elasticfilesystem:Backup",
                "elasticfilesystem:DescribeTags"
            ],
            "Resource": "arn:aws:elasticfilesystem:*:*:file-system/*",
            "Effect": "Allow"
        },
        {
            "Action": [
                "kms:Decrypt",
                "kms:GenerateDataKey"
            ],
            "Effect": "Allow",
            "Resource": "*",
            "Condition": {
                "StringLike": {
                    "kms:ViaService": [
                        "dynamodb.*.amazonaws.com"
                    ]
                }
            }
        },
        {
            "Action": "kms:DescribeKey",
            "Effect": "Allow",
            "Resource": "*"
        },
        {
            "Action": "kms:CreateGrant",
            "Effect": "Allow",
            "Resource": "*",
            "Condition": {
                "Bool": {
                    "kms:GrantIsForAWSResource": "true"
                }
            }
        },
        {
            "Action": [
                "kms:GenerateDataKeyWithoutPlaintext"
            ],
            "Effect": "Allow",
            "Resource": "arn:aws:kms:*:*:key/*",
            "Condition": {
                "StringLike": {
                    "kms:ViaService": [
                        "ec2.*.amazonaws.com"
                    ]
                }
            }
        },
        {
            "Action": [
                "tag:GetResources"
            ],
            "Resource": "*",
            "Effect": "Allow"
        },
        {
            "Effect": "Allow",
            "Action": [
                "ssm:CancelCommand",
                "ssm:GetCommandInvocation"
            ],
            "Resource": "*"
        },
        {
            "Effect": "Allow",
            "Action": "ssm:SendCommand",
            "Resource": [
                "arn:aws:ssm:*:*:document/AWSEC2-CreateVssSnapshot",
                "arn:aws:ec2:*:*:instance/*"
            ]
        },
        {
            "Action": "fsx:DescribeBackups",
            "Effect": "Allow",
            "Resource": "arn:aws:fsx:*:*:backup/*"
        },
        {
            "Sid": "BackupGatewayBackupPermissions",
            "Effect": "Allow",
            "Action": [
                "backup-gateway:Backup",
                "backup-gateway:ListTagsForResource"
            ],
            "Resource": "arn:aws:backup-gateway:*:*:vm/*"
        }
    ]
}