output "address" {
  value       = module.mysql.address
  description = "Connect db at this endpoint"
}
output "port" {
  value       = module.mysql.port
  description = "The Port the db is listening on"
}