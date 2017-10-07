variable "num_servers" {
  description = "The number of servers to spin up."
  type        = "string"
  default     = 3
}

variable "consul_name" {
  description = "The name of the consul nodes"
  type        = "string"
  default     = "consul"
}

variable "nomad_name" {
  description = "The name the nomad servers register with consul"
  type        = "string"
  default     = "nomad"
}

variable "ami" {
  description = "The ami to use"
  type        = "string"
  default     = ""
}

variable "instance_type" {
  description = "The instance type to use"
  type        = "string"
  default     = ""
}

variable "region" {
  description = "The region to deploy in"
  type        = "string"
  default     = "us-east-1"
}

variable "possible_subnets" {
  description = "Possible subnets to deploy the instance in.  Iterated through the num_servers variable."
  type        = "list"
  default     = []
}

variable "security_group_ids" {
  description = "The security groups to attach to the instance"
  type        = "list"
  default     = []
}

variable "associate_public_ip_address" {
  description = "Whether or not to associate a public IP address"
  type        = "string"
  default     = false
}

variable "key_name" {
  description = "The key to use to SSH into the instance"
  type        = "string"
  default     = ""
}

variable "iam_profile" {
  description = "The IAM profile to give the instance"
  type        = "string"
  default     = ""
}

variable "ignition_user_ids" {
  description = "The ids of users from an ignition data source"
  type        = "list"
  default     = []
}

variable "ignition_group_ids" {
  description = "The ids of groups from an ignition data source"
  type        = "list"
  default     = []
}

variable "ignition_systemd_ids" {
  description = "The ids of systemd units from an ignition data source"
  type        = "list"
  default     = []
}

variable "tags" {
  description = "The tags to attach to the instance"
  type        = "map"
  default     = {}
}

variable "r53_zone_id" {
  description = "The id of the route53 zone to create DNS entries"
  type        = "string"
  default     = ""
}
