############################################
# Bonus B - Route53 (Hosted Zone + DNS records + ACM validation + ALIAS to ALB)
############################################

locals {
  # Explanation: bos needs a home planet—Route53 hosted zone is your DNS territory.
  bos_zone_name = var.domain_name

  # Explanation: Use either Terraform-managed zone or a pre-existing zone ID (students choose their destiny).
  bos_zone_id = var.manage_route53_in_terraform ? aws_route53_zone.bos_zone01[0].zone_id : var.route53_hosted_zone_id

  # Explanation: This is the app address that will growl at the galaxy (app.bos-growl.com).
  bos_app_fqdn = "${var.app_subdomain}.${var.domain_name}"
}

############################################
# Hosted Zone (optional creation)
############################################

# Explanation: A hosted zone is like claiming Kashyyyk in DNS—names here become law across the galaxy.
resource "aws_route53_zone" "bos_zone01" {
  count = var.manage_route53_in_terraform ? 1 : 0

  name = local.bos_zone_name

  tags = {
    Name = "${var.project_name}-zone01"
  }
}