output "alb_id" {
  value       = module.alb.alb_id
}

output "alb_arn" {
  value       = module.alb.alb_arn
}

output "alb_name" {
  value       = module.alb.alb_name
}

output "alb_dns_name" {
  value       = module.alb.alb_dns_name
}

output "alb_zone_id" {
  description = "The canonical hosted zone ID of the ELB (to be used in a Route 53 Alias record)"
  value       = module.alb.alb_zone_id
}


output "vpc_id" {
  value = module.networking.vpc_id
}
 output "public_subnet" {
  value = module.networking.public_subnet
 }
 output "private_subnet" {
  value = module.networking.private_subnet
 }
