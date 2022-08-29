#DsiDataConsumer
resource "template_file" "DsiDataConsumer" {
  count    = length(var.tenant)
  template = file("./policies/DsiDataConsumer_s3_bucket_policy.json.tpl")
   
   vars = {
     tenant      = "${var.tenant[count.index]}"
     workspace   = "${terraform.workspace}"
     aws-account-id = var.aws-account-id
   }
 }
 
 resource "template_file" "assumerole-policy-1" {
    count              = length(var.tenant) 
    template = file("./policies/trust_relationship_role_policy.json.tpl")

    vars = {
      aws-account-id = var.aws-account-id
      DsiDataConsumerUser = "${aws_iam_user.user1.*.name[count.index]}"
    }
  }
  

resource "aws_iam_policy" "DsiDataConsumer" {
  count = length(var.tenant) 
  name = "${var.tenant[count.index]}DsiDataConsumer_s3_bucket_policy"
  policy = "${resource.template_file.DsiDataConsumer.*.rendered[count.index]}"
}

resource "aws_iam_role" "DsiDataConsumer" {
  count              = length(var.tenant)  
  name               = "${var.tenant[count.index]}DsiDataConsumerRole"
  assume_role_policy = "${resource.template_file.assumerole-policy-1.*.rendered[count.index]}"
}


resource "aws_iam_role_policy_attachment" "attach1" {
  count      = length(var.tenant) 
  policy_arn = "${aws_iam_policy.DsiDataConsumer.*.arn[count.index]}"
  role       = "${aws_iam_role.DsiDataConsumer.*.name[count.index]}"
}

/*
resource "aws_iam_user_policy_attachment" "s3-attach" {
  count      =  length(var.tenant) 
  user       = "${aws_iam_user.user1.*.name[count.index]}"
  policy_arn = "${aws_iam_policy.DsiDataConsumer.*.arn[count.index]}"
}
*/

#ETLGlueService
 resource "template_file" "ETLGlueService" {
    count  = length(var.tenant)
    template = file("./policies/etlglueserviceuser_s3_bucket_policy.json.tpl")

    vars = {
      tenant      = "${var.tenant[count.index]}"
      tenant1     = lower("${var.tenant[count.index]}")
      workspace   = "${terraform.workspace}"
      aws-account-id = var.aws-account-id
    }
  }

 resource "template_file" "assumerole-policy-2" {
    count              = length(var.tenant) 
    template = file("./policies/trust_relationship_role_policy_2.json.tpl")

    vars = {
      aws-account-id = var.aws-account-id
     # ETLGlueServiceRunnerUser = "${aws_iam_user.user2.*.name[count.index]}"
    }
  }
 
resource "aws_iam_policy" "ETLGlueService" {
  count  = length(var.tenant)
  name   = "${var.tenant[count.index]}etlglueserviceuser_s3_bucket_policy"
  policy = "${resource.template_file.ETLGlueService.*.rendered[count.index]}"
}

resource "aws_iam_role" "ETLGlueService" {
  count              = length(var.tenant) 
  name               = "${var.tenant[count.index]}ETLGlueServiceRunnerRole"
  assume_role_policy = "${resource.template_file.assumerole-policy-2.*.rendered[count.index]}"
}

resource "aws_iam_role_policy_attachment" "attach2" {
  count      = length(var.tenant) 
  policy_arn = "${aws_iam_policy.ETLGlueService.*.arn[count.index]}"
  role       = "${aws_iam_role.ETLGlueService.*.name[count.index]}"
}

#Create custom policy for athena Appuser
			
resource "template_file" "DsiDataConsumer-athena" {
  count    = length(var.tenant)
  template = file("./policies/athena-custom-policy.json.tpl")
   
   vars = {
     tenant      = "${var.tenant[count.index]}"
     tenant1     = lower("${var.tenant[count.index]}")
     workspace   = "${terraform.workspace}"
	   aws_region  =  var.aws_region
	   aws-account-id = var.aws-account-id
   }
 }
 
 resource "aws_iam_policy" "DsiDataConsumer-athena" {
   count = length(var.tenant) 
   name = "${var.tenant[count.index]}DsiDataConsumer-athena-policy"
   policy = "${resource.template_file.DsiDataConsumer-athena.*.rendered[count.index]}"
 }
 
 
 resource "aws_iam_role_policy_attachment" "athena" {
   count      = length(var.tenant) 
   policy_arn = "${aws_iam_policy.DsiDataConsumer-athena.*.arn[count.index]}"
   role       = "${aws_iam_role.DsiDataConsumer.*.name[count.index]}"
 }

/*
 resource "aws_iam_user_policy_attachment" "athena-attach" {
  count      =  length(var.tenant) 
  user       = "${aws_iam_user.user1.*.name[count.index]}"
  policy_arn = "${aws_iam_policy.DsiDataConsumer-athena.*.arn[count.index]}"
}
*/

# ETLGlueServiceRunnerRole attach to ETLDev group

resource "aws_iam_group_policy_attachment" "ETLDev-attach" {
  count      = length(var.tenant) 
  group      = "${aws_iam_group.developers.*.name[count.index]}"
  policy_arn = "${aws_iam_policy.ETLGlueService.*.arn[count.index]}"
 
}



#BlueprintRunnerRole
resource "template_file" "BlueprintRunner" {
  count    = length(var.tenant)
  template = file("./policies/blueprintrunner_etl_glue_policy.json.tpl")
   
   vars = {
     tenant      = "${var.tenant[count.index]}"
     workspace   = "${terraform.workspace}"
     aws-account-id = var.aws-account-id
   }
 }
 
 resource "template_file" "blueprint-assumerole-policy" {
    count              = length(var.tenant) 
    template = file("./policies/blueprint_trust_relationship_role_policy.json.tpl")
  }
  
  
resource "aws_iam_policy" "BlueprintRunner" {
  count = length(var.tenant) 
  name = "${var.tenant[count.index]}BlueprintRunnerPolicy"

  policy = "${resource.template_file.BlueprintRunner.*.rendered[count.index]}"
}

resource "aws_iam_role" "BlueprintRunner" {
  count              = length(var.tenant)  
  name               = "${var.tenant[count.index]}BlueprintRunnerRole"
  assume_role_policy = "${resource.template_file.blueprint-assumerole-policy.*.rendered[count.index]}"
}

resource "aws_iam_role_policy_attachment" "blueprint-attach" {
  count = length(var.tenant) 
  policy_arn = "${aws_iam_policy.BlueprintRunner.*.arn[count.index]}"
  role       = "${aws_iam_role.BlueprintRunner.*.name[count.index]}"
}


#DsiDataConsumer S3 policy and athena policy attach to DsiDataConsumerUserGroup 

resource "aws_iam_group_policy_attachment" "DsiDataConsumer-attach" {
  count      = length(var.tenant) 
  group      = "${aws_iam_group.consumergrp.*.name[count.index]}"
  policy_arn = "${aws_iam_policy.DsiDataConsumer.*.arn[count.index]}"
 
}

resource "aws_iam_group_policy_attachment" "DsiDataConsumer-athena-attach" {
  count      = length(var.tenant) 
  group      = "${aws_iam_group.consumergrp.*.name[count.index]}"
  policy_arn = "${aws_iam_policy.DsiDataConsumer-athena.*.arn[count.index]}"

}

# Admin Read only user role


resource "template_file" "AdminReadOnly" {
    count              = length(var.tenant) 
    template = file("./policies/trust_relationship_admin_role_policy.json.tpl")

    vars = {
      aws-account-id = var.aws-account-id
      AdminReadOnly = "${aws_iam_saml_provider.AdminReadOnly.*.name[count.index]}"
    }
  }

resource "aws_iam_role" "AdminReadOnly" {
  count              = length(var.tenant)  
  name               = "${var.tenant[count.index]}AdminReadOnlyRole"
  assume_role_policy = "${resource.template_file.AdminReadOnly.*.rendered[count.index]}"
}

resource "aws_iam_role_policy_attachment" "AdminReadOnly" {
  count      = length(var.tenant) 
  role       = "${aws_iam_role.AdminReadOnly.*.name[count.index]}"
  policy_arn = "arn:aws:iam::aws:policy/ReadOnlyAccess"
}

# SelfAdmin  role

resource "template_file" "SelfAdmin" {
    count              = length(var.tenant) 
    template = file("./policies/trust_relationship_SelfAdmin_role_policy.json.tpl")

    vars = {
      aws-account-id = var.aws-account-id
      SelfAdmin = "${aws_iam_saml_provider.SelfAdmin.*.name[count.index]}"
    }
  }
  

resource "template_file" "SelfAdmin_1" {
  count    = length(var.tenant)
  template = file("./policies/SelfAdminUser_kms_policy.json.tpl")
   
   vars = {
     tenant      = "${var.tenant[count.index]}"
     workspace   = "${terraform.workspace}"
   }
 }

resource "aws_iam_policy" "SelfAdmin" {
  count = length(var.tenant) 
  name = "${var.tenant[count.index]}SelfAdmin_kms_policy"
  policy = "${resource.template_file.SelfAdmin_1.*.rendered[count.index]}"
}

resource "aws_iam_role" "SelfAdmin" {
  count              = length(var.tenant)  
  name               = "${var.tenant[count.index]}SelfAdminRole"
  assume_role_policy = "${resource.template_file.SelfAdmin.*.rendered[count.index]}"
}

resource "aws_iam_role_policy_attachment" "SelfAdmin" {
  count      = length(var.tenant) 
  role       = "${aws_iam_role.SelfAdmin.*.name[count.index]}"
  policy_arn = "${aws_iam_policy.SelfAdmin.*.arn[count.index]}"
}

#PreLandingRole
resource "template_file" "preLanding" {
  count    = length(var.tenant)
  template = file("./policies/prelanding_user_policy.json.tpl")
  
  
  vars = {
    tenant      = "${var.tenant[count.index]}"
    aws-account-id = var.aws-account-id
    workspace   = "${terraform.workspace}"
   }
 }

resource "template_file" "prelanding-assumerole-policy" {
    count              = length(var.tenant) 
    template = file("./policies/prelanding_trust_relationship_role_policy.json.tpl")

    vars = {
     PreLanding = "${aws_iam_saml_provider.PreLanding.*.name[count.index]}"
     aws-account-id = var.aws-account-id
   }
  }
  
resource "aws_iam_policy" "PreLandingPolicy" {
  count = length(var.tenant) 
  name = "${var.tenant[count.index]}PreLandingPolicy"
  policy = "${resource.template_file.preLanding.*.rendered[count.index]}"
}
resource "aws_iam_role" "PreLandingRole" {
  count              = length(var.tenant)  
  name               = "${var.tenant[count.index]}PreLandingRole"
  assume_role_policy = "${resource.template_file.prelanding-assumerole-policy.*.rendered[count.index]}"
}

resource "aws_iam_role_policy_attachment" "prelanding-attach" {
  count = length(var.tenant) 
  policy_arn = "${aws_iam_policy.PreLandingPolicy.*.arn[count.index]}"
  role       = "${aws_iam_role.PreLandingRole.*.name[count.index]}"
}
