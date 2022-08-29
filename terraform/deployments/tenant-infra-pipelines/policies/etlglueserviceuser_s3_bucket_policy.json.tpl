{
   "Version":"2012-10-17",
   "Statement":[
      {
         "Effect":"Allow",
         "Action":[
            "s3:ListAllMyBuckets",
            "s3:GetBucketLocation"
         ],
         "Resource":"arn:aws:s3:::*"
      },
      {
         "Effect":"Allow",
         "Action":[
            "s3:ListBucket",
            "s3:GetBucketLocation"
         ],
          "Resource": [
            "arn:aws:s3:::all-${workspace}-tenant-bucket",
            "arn:aws:s3:::all-${workspace}-tenant-scripts-bucket",
            "arn:aws:s3:::all-${workspace}-tenant-landing-bucket",
            "arn:aws:s3:::all-${workspace}-tenant-pre-landing-bucket"
            ],
         "Condition":{
            "StringLike":{
               "s3:prefix":[
                  "${tenant}/*"
               ]
            }
         }
      },
      {
        "Action": [
            "s3:ListBucket", 
            "s3:GetBucketLocation"
        ],
        "Condition": {
            "StringLike": {
                "s3:prefix": [
                    "blueprints/*"
                ]
            }
        },
        "Effect": "Allow",
        "Resource": [
            "arn:aws:s3:::all-${workspace}-tenant-scripts-bucket"
        ]
    },
     
      {
         "Effect":"Allow",
         "Action":"s3:GetObject",
         "Resource": [
             "arn:aws:s3:::all-${workspace}-tenant-bucket/${tenant}/repository/*",
             "arn:aws:s3:::all-${workspace}-tenant-pre-landing-bucket/${tenant}/*",
             "arn:aws:s3:::all-${workspace}-tenant-scripts-bucket/${tenant}/*",
             "arn:aws:s3:::all-${workspace}-tenant-landing-bucket/${tenant}/*"
         ]
      },
      {
         "Effect":"Allow",
         "Action":[
            "s3:PutObject",
            "s3:GetObject"
         ],
         "Resource": [
             "arn:aws:s3:::all-${workspace}-tenant-bucket/${tenant}/temp/*",
             "arn:aws:s3:::all-${workspace}-tenant-bucket/${tenant}/repository/*",
             "arn:aws:s3:::all-${workspace}-tenant-landing-bucket/${tenant}/*",
             "arn:aws:s3:::all-${workspace}-tenant-pre-landing-bucket/${tenant}/*"
         ]    
      },
      {
         "Effect":"Allow",
         "Action":[
            "secretsmanager:GetSecretValue",
            "secretsmanager:DescribeSecret",
            "secretsmanager:List*"
         ],
         "Resource":"arn:aws:secretsmanager:eu-west-2:${aws-account-id}:secret:${workspace}/${tenant}/*"
      },
      {
         "Effect":"Allow",
         "Action":[
            "glue:GetDatabase",
            "glue:GetDatabases",
            "glue:UpdateDatabase",
            "glue:CreateTable",
            "glue:DeleteTable",
            "glue:BatchDeleteTable",
            "glue:UpdateTable",
            "glue:GetTable",
            "glue:GetTables",
            "glue:BatchGetPartition",
            "glue:BatchCreatePartition",
            "glue:GetPartitions"
         ],
         "Resource":[
            "arn:aws:glue:eu-west-2:${aws-account-id}:catalog",
            "arn:aws:glue:eu-west-2:${aws-account-id}:database/${tenant1}_database",
            "arn:aws:glue:eu-west-2:${aws-account-id}:table/${tenant1}_database/*",
            "arn:aws:glue:eu-west-2:${aws-account-id}:database/${tenant1}_landing_database",
            "arn:aws:glue:eu-west-2:${aws-account-id}:table/${tenant1}_landing_database/*"
         ]
      },
      {
         "Effect":"Allow",
         "Action":[
             "glue:GetConnection",
             "ec2:DescribeSubnets",
             "ec2:DescribeSecurityGroups",
             "ec2:CreateTags",
             "ec2:DeleteTags",
             "ec2:CreateNetworkInterface",
             "ec2:DeleteNetworkInterface",
             "ec2:DescribeVpcEndpoints",
             "ec2:DescribeRouteTables",
             "ec2:DescribeNetworkInterfaces"
         ],
         "Resource": "*"
     },

      {
         "Effect":"Allow",
         "Action":[
            "logs:CreateLogGroup",
            "logs:CreateLogStream",
            "logs:PutLogEvents",
            "logs:DescribeLogStreams"
         ],
         "Resource":"arn:aws:logs:eu-west-2:${aws-account-id}:log-group:${tenant}GlueLogGroup"
      },
      {
         "Action": [
            "cloudwatch:PutMetricData"
         ],
            "Effect": "Allow",
            "Resource": "*"
      },
      {
            "Effect": "Allow",
            "Action": [
                "secretsmanager:GetResourcePolicy",
                "secretsmanager:DescribeSecret",
                "secretsmanager:GetSecretValue",
                "secretsmanager:ListSecretVersionIds"
            ],
            "Resource":"arn:aws:secretsmanager:eu-west-2:${aws-account-id}:secret:${workspace}/${tenant}/*"
                
      }	
   ]
}