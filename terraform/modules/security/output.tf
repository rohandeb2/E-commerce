output "eks_node_sg_id" {
  value = aws_security_group.eks_nodes.id
}

output "db_sg_id" {
  value = aws_security_group.db_sg.id
}

output "waf_acl_arn" {
  value = aws_wafv2_web_acl.main.arn
}