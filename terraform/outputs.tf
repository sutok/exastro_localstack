output "bastion_public_ip" {
  value = aws_instance.bastion.public_ip
}

output "app_private_ip" {
  value = aws_instance.app.private_ip
}

output "db_private_ip" {
  value = aws_instance.db.private_ip
}

output "acm_certificate_arn" {
  value = aws_acm_certificate.main.arn
}
