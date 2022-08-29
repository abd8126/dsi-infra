{
	"Version": "2012-10-17",
	"Statement": [
		{
			"Sid": "VisualEditor0",
			"Effect": "Allow",
			"Action": [
				"glue:CreateJob",
				"glue:GetCrawler",
				"glue:GetTrigger",
				"glue:DeleteCrawler",
				"glue:CreateTrigger",
				"glue:DeleteTrigger",
				"glue:DeleteJob",
				"glue:CreateWorkflow",
				"glue:DeleteWorkflow",
				"glue:GetJob",
				"glue:GetWorkflow",
				"glue:CreateCrawler",
				"glue:CreateTable"
			],
			"Resource": "*"
		},
		{
			"Sid": "VisualEditor1",
			"Effect": "Allow",
			"Action": "iam:PassRole",
			"Resource": "arn:aws:iam::${aws-account-id}:role/${tenant}ETLGlueServiceRunnerRole"
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