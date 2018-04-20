output "hashi_crypts" {
  description = "hashi encryption key"
  value       = "${data.external.hashi-keygen.result}"
}
