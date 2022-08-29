{
    "Version": "2012-10-17",
    "Statement": [
        {
            "Effect": "Allow",
            "Action": [
                "athena:*"
            ],
            "Resource": [
                "arn:aws:athena:${aws_region}:${aws-account-id}:workgroup/primary"
            ]
        },
        {
            "Effect": "Allow",
            "Action": [
                "glue:GetDatabase",
                "glue:GetDatabases",
                "glue:GetTable",
                "glue:GetTables",
                "glue:BatchGetPartition",
                "glue:BatchCreatePartition"

            ],
            "Resource": [
                "arn:aws:glue:eu-west-2:${aws-account-id}:catalog",
                "arn:aws:glue:eu-west-2:${aws-account-id}:database/${tenant1}_database",
                "arn:aws:glue:eu-west-2:${aws-account-id}:table/${tenant1}_database/*"
            ]
        },
        {
            "Effect": "Allow",
            "Action": [
                "sns:ListTopics",
                "sns:GetTopicAttributes"
            ],
            "Resource": [
                "*"
            ]
        },
        {
            "Effect": "Allow",
            "Action": [
                "cloudwatch:PutMetricAlarm",
                "cloudwatch:DescribeAlarms",
                "cloudwatch:DeleteAlarms"
            ],
            "Resource": [
                "*"
            ]
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