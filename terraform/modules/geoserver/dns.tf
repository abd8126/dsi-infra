resource "aws_acm_certificate" "cert" {
  domain_name       = "${var.sub_domain_name}.${var.hosted_zone_name}"
  validation_method = "DNS"

  subject_alternative_names = ["*.${var.sub_domain_name}.${var.hosted_zone_name}"]

  tags = {
    Name = var.name
  }

  lifecycle {
    create_before_destroy = true
  }
}

resource "aws_route53_record" "acm_certificate" {
  for_each = {
    for dvo in aws_acm_certificate.cert.domain_validation_options : dvo.domain_name => {
      name    = dvo.resource_record_name
      record  = dvo.resource_record_value
      type    = dvo.resource_record_type
      zone_id = data.aws_route53_zone.co.zone_id
    }
  }

  allow_overwrite = true
  name            = each.value.name
  records         = [each.value.record]
  ttl             = 60
  type            = each.value.type
  zone_id         = each.value.zone_id
}

resource "aws_acm_certificate_validation" "cert_validation" {
  certificate_arn         = aws_acm_certificate.cert.arn
  validation_record_fqdns = [for record in aws_route53_record.acm_certificate : record.fqdn]
}

resource "aws_route53_record" "cname_to_alb" {
  zone_id = data.aws_route53_zone.co.id
  name    = "${var.sub_domain_name}.${var.hosted_zone_name}"
  type    = "CNAME"
  ttl     = "60"
  records = [aws_lb.geoserver.dns_name]
}
