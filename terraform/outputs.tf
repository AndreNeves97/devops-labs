

output "s3_bucket_name" {
  value = aws_s3_bucket.this.id
}

output "public_subnet_arns" {
  value = aws_subnet.public[*].arn
}

output "private_subnet_arns" {
  value = aws_subnet.private[*].arn
}
output "public_route_table_id" {
  value = aws_route_table.public.id
}

output "private_route_table_id" {
  value = aws_route_table.private.id
}

output "eks_cluster_id" {
  value = aws_eks_cluster.this.id
}

output "eks_cluster_current_user_access_entry_arn" {
  value = aws_eks_access_entry.current_user.principal_arn
}

output "github_oidc_role_arn" {
  value = aws_iam_role.github.arn
}
