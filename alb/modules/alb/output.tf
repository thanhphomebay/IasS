output "alb_id" {
  description = "The name of the ELB"
  value       = try(aws_lb.this.id, "")
}

output "alb_arn" {
  description = "The ARN of the ELB"
  value       = try(aws_lb.this.arn, "")
}

output "alb_name" {
  description = "The name of the ELB"
  value       = try(aws_lb.this.name, "")
}

output "alb_dns_name" {
  description = "The DNS name of the ELB"
  value       = try(aws_lb.this.dns_name, "")
}

output "alb_zone_id" {
  description = "The canonical hosted zone ID of the ELB (to be used in a Route 53 Alias record)"
  value       = try(aws_lb.this.zone_id, "")
}
