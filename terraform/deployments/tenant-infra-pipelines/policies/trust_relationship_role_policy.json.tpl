{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Effect": "Allow",
      "Principal": {
        "AWS": "arn:aws:iam::${aws-account-id}:user/${DsiDataConsumerUser}"
      },
      "Action": "sts:AssumeRole",
      "Condition": {}
    }
  ]
}
