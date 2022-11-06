resource "aws_route53_zone" "cobudget" {
  name    = var.backend_url
  comment = "Zone for CoBudget backend"
}

resource "aws_route53_record" "cobudget" {
  name    = ""
  type    = "A"
  zone_id = aws_route53_zone.cobudget.zone_id
  ttl     = 300
  records = [aws_instance.cobudget.public_ip]
}