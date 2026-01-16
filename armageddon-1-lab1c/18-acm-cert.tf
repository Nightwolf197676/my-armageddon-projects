############################################
# ACM Certificate (TLS) for app.bos-growl.com
############################################

# Explanation: TLS is the diplomatic passport — browsers trust you, and bos stops growling at plaintext.
resource "aws_acm_certificate" "bos_acm_cert01" {
  domain_name       = local.bos_fqdn
  validation_method = var.certificate_validation_method

  # TODO: students can add subject_alternative_names like var.domain_name if desired

  tags = {
    Name = "${var.project_name}-acm-cert01"
  }
}

# Explanation: DNS validation records are the “prove you own the planet” ritual — Route53 makes this elegant.
# TODO: students implement aws_route53_record(s) if they manage DNS in Route53.
# resource "aws_route53_record" "bos_acm_validation" { ... }

# Explanation: Once validated, ACM becomes the “green checkmark” — until then, ALB HTTPS won’t work.
resource "aws_acm_certificate_validation" "bos_acm_validation01" {
  certificate_arn = aws_acm_certificate.bos_acm_cert01.arn

  # TODO: if using DNS validation, students must pass validation_record_fqdns
  # validation_record_fqdns = [aws_route53_record.bos_acm_validation.fqdn]
}

############################################
# ACM DNS Validation Records
############################################

# Explanation: ACM asks “prove you own this planet”—DNS validation is bos roaring in the right place.
resource "aws_route53_record" "bos_acm_validation_records01" {
  for_each = var.certificate_validation_method == "DNS" ? {
    for dvo in aws_acm_certificate.bos_acm_cert01.domain_validation_options :
    dvo.domain_name => {
      name   = dvo.resource_record_name
      type   = dvo.resource_record_type
      record = dvo.resource_record_value
    }
  } : {}

  zone_id = local.bos_zone_id
  name    = each.value.name
  type    = each.value.type
  ttl     = 60

  records = [each.value.record]
}

# Explanation: This ties the “proof record” back to ACM—bos gets his green checkmark for TLS.
resource "aws_acm_certificate_validation" "bos_acm_validation01_dns_bonus" {
  count = var.certificate_validation_method == "DNS" ? 1 : 0

  certificate_arn = aws_acm_certificate.bos_acm_cert01.arn

  validation_record_fqdns = [
    for r in aws_route53_record.bos_acm_validation_records01 : r.fqdn
  ]
}
