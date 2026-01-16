# Explanation: Outputs are your mission report—what got built and where to find it.
output "bos_vpc_id" {
  value = aws_vpc.bos_vpc01.id
}

output "bos_public_subnet_ids" {
  value = aws_subnet.bos_public_subnets[*].id
}

output "bos_private_subnet_ids" {
  value = aws_subnet.bos_private_subnets[*].id
}

output "bos_ec2_instance_id" {
  value = aws_instance.bos_ec201_private_bonus.id
}

output "bos_rds_endpoint" {
  value = aws_db_instance.bos_rds01.address
}

output "bos_sns_topic_arn" {
  value = aws_sns_topic.bos_sns_topic01.arn
}

output "bos_log_group_name" {
  value = aws_cloudwatch_log_group.bos_log_group01.name
}

#Bonus-A outputs (append to outputs.tf)

# Explanation: These outputs prove bos built private hyperspace lanes (endpoints) instead of public chaos.
output "bos_vpce_ssm_id" {
  value = aws_vpc_endpoint.bos_vpce_ssm01.id
}

output "bos_vpce_logs_id" {
  value = aws_vpc_endpoint.bos_vpce_logs01.id
}

output "bos_vpce_secrets_id" {
  value = aws_vpc_endpoint.bos_vpce_secrets01.id
}

output "bos_vpce_s3_id" {
  value = aws_vpc_endpoint.bos_vpce_s3_gw01.id
}

output "bos_private_ec2_instance_id_bonus" {
  value = aws_instance.bos_ec201_private_bonus.id
}

