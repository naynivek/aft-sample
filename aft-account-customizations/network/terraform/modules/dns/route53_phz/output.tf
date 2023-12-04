output "prd_zone_id" {
  value       = aws_route53_zone.prd.zone_id
  description = "The hosted prd zone id"
}
output "zone_id" {
  value       = aws_route53_zone.nprd.zone_id
  description = "The hosted nprd zone id"
}