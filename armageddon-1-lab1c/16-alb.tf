############################################
# Bonus B - ALB (Public) -> Target Group (Private EC2) + TLS + WAF + Monitoring
############################################

locals {
  # Explanation: This is the roar address — where the galaxy finds your app.
  bos_fqdn = "${var.app_subdomain}.${var.domain_name}"
}

############################################
# Security Group: ALB
############################################

# Explanation: The ALB SG is the blast shield — only allow what the Rebellion needs (80/443).
resource "aws_security_group" "bos_alb_sg01" {
  name        = "${var.project_name}-alb-sg01"
  description = "ALB security group"
  vpc_id      = aws_vpc.bos_vpc01.id

  # TODO: students add inbound 80/443 from 0.0.0.0/0
  # TODO: students set outbound to target group port (usually 80) to private targets

  tags = {
    Name = "${var.project_name}-alb-sg01"
  }
}

# Explanation: bos only opens the hangar door — allow ALB -> EC2 on app port (e.g., 80).
resource "aws_security_group_rule" "bos_ec2_ingress_from_alb01" {
  type                     = "ingress"
  security_group_id        = aws_security_group.bos_ec2_sg01.id
  from_port                = 80
  to_port                  = 80
  protocol                 = "tcp"
  source_security_group_id = aws_security_group.bos_alb_sg01.id

  # TODO: students ensure EC2 app listens on this port (or change to 8080, etc.)
}

############################################
# Application Load Balancer
############################################

# Explanation: The ALB is your public customs checkpoint — it speaks TLS and forwards to private targets.
resource "aws_lb" "bos_alb01" {
  name               = "${var.project_name}-alb01"
  load_balancer_type = "application"
  internal           = false

  security_groups = [aws_security_group.bos_alb_sg01.id]
  subnets         = aws_subnet.bos_public_subnets[*].id

  # TODO: students can enable access logs to S3 as a stretch goal

  tags = {
    Name = "${var.project_name}-alb01"
  }
}

############################################
# ALB Listeners: HTTP -> HTTPS redirect, HTTPS -> TG
############################################

# Explanation: HTTP listener is the decoy airlock — it redirects everyone to the secure entrance.
resource "aws_lb_listener" "bos_http_listener01" {
  load_balancer_arn = aws_lb.bos_alb01.arn
  port              = 80
  protocol          = "HTTP"

  default_action {
    type = "redirect"
    redirect {
      port        = "443"
      protocol    = "HTTPS"
      status_code = "HTTP_301"
    }
  }
}

# Explanation: HTTPS listener is the real hangar bay — TLS terminates here, then traffic goes to private targets.
resource "aws_lb_listener" "bos_https_listener01" {
  load_balancer_arn = aws_lb.bos_alb01.arn
  port              = 443
  protocol          = "HTTPS"
  ssl_policy        = "ELBSecurityPolicy-TLS13-1-2-2021-06"
  certificate_arn   = aws_acm_certificate_validation.bos_acm_validation01.certificate_arn

  default_action {
    type             = "forward"
    target_group_arn = aws_lb_target_group.bos_tg01.arn
  }

  depends_on = [aws_acm_certificate_validation.bos_acm_validation01]
}

############################################
# Enable ALB access logs (on the ALB resource)
############################################

# Explanation: Turn on access logs—bos wants receipts when something goes wrong.
# NOTE: This is a skeleton patch: students must merge this into aws_lb.bos_alb01
# by adding/accessing the `access_logs` block. Terraform does not support "partial" blocks.
#
# Add this inside resource "aws_lb" "bos_alb01" { ... } in bonus_b.tf:
#
# access_logs {
#   bucket  = aws_s3_bucket.bos_alb_logs_bucket01[0].bucket
#   prefix  = var.alb_access_logs_prefix
#   enabled = var.enable_alb_access_logs
# }