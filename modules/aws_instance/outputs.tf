output "public_ip" {
  description = "The public IP of the newly spun up instance"
  value       = "${aws_instance.instance.public_ip}"
}

output "private_ips" {
  description = "The private IPs of the spun up instances"
  value       = ["${aws_instance.instance.*.private_ip}"]
}
