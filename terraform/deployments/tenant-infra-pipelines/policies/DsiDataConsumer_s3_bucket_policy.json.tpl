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
            "Resource":"arn:aws:s3:::all-${workspace}-tenant-bucket",
            "Condition":{
               "StringLike":{
                  "s3:prefix":[
                     "${tenant}/*"
                  ]
               }
            }
         },
         {
            "Effect":"Allow",
            "Action":[
               "s3:ListBucket",
               "s3:GetBucketLocation",
               "s3:GetObject"
            ],
            "Resource":"arn:aws:s3:::all-${workspace}-tenant-bucket"
         },
         {
            "Effect":"Allow",
            "Action":[
               "s3:GetObject",
               "s3:GetBucketLocation"
            ],
            "Resource":"arn:aws:s3:::all-${workspace}-tenant-bucket/${tenant}/repository/*"
         },
         {
            "Effect":"Allow",
            "Action":[
               "s3:GetObject",
               "s3:GetBucketLocation",
               "s3:PutObject"
            ],
            "Resource":"arn:aws:s3:::all-${workspace}-tenant-bucket/${tenant}/temp/*"
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