resource "aws_acm_certificate" "main" {
  domain_name       = "example.local"
  validation_method = "DNS"

  lifecycle {
    create_before_destroy = true
  }

  tags = { Name = "${var.project}-cert" }
}

# 本番環境では以下を追加すること:
# resource "aws_acm_certificate_validation" "main" {
#   certificate_arn         = aws_acm_certificate.main.arn
#   validation_record_fqdns = [for r in aws_route53_record.cert_validation : r.fqdn]
# }

# NOTE: ELB / ALB は LocalStack Community版では非対応のため省略
# 本番環境では aws_lb (ALB) または aws_elb (Classic ELB) を使用すること
