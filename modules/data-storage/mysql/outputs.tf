output "address" {
  value       = aws_db_instance.example.address
  description = "Connect db at this endpoint"
}
output "port" {
  value       = aws_db_instance.example.port
  description = "The Port the db is listening on"
}