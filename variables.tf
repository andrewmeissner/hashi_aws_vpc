variable "account_id" {
  description = "Account ID to prevent mistakenly blowing up the world"
  type        = "string"
}

variable "region" {
  description = "AWS Region"
  type        = "string"
}

variable "ami_id" {
  description = "The CoreOS AMI with consul-template, consul, and nomad binaries installed in /opt/bin"
  type        = "string"
}

variable "openvpn_pw" {
  description = "The default password for OpenVPN Access Server"
  type        = "string"
  default     = "myvpntest"
}
