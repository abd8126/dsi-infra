# Geoserver module

This module deploys Geoserver as a container in an ECS Fargate task. The data directory is persisted within EFS and traffic is routed through an ALB.

## Usage

```hcl
module "geoserver" {
  source = "../../modules/geoserver"

  name               = "dsi-geoserver"
  vpc_id             = "vpc-12345abc"
  private_subnet_ids = ["subnet-123", "subnet-456"]
  public_subnet_ids  = ["subnet-789", "subnet-321"]
  ami_id             = "ami-02f5781cba46a5e8a"
  sub_domain_name    = "geo"
  hosted_zone_name   = "myorg.com"
}

```

### Notes

During initial setup, the aws_lb_listener.http_to_https resource needs to be changed to forward directly to the target group. The required changes are commented out in the [server.tf](./server.tf) file. Once this is done, log in to Geoserver and set-up the proxy settings. The aws_lb_listener.http_to_https can then be switched back to forward http traffic to https.