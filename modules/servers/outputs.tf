output "server_ips" {
  description = "The private IPs of the spun up servers"
  value       = ["${aws_instance.server.*.private_ip}"]
}
