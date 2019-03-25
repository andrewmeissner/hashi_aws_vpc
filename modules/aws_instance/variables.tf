variable "name" {
  description = "The name of the instance"
  type        = "string"
  default     = ""
}

variable "region" {
  description = "The region to in which to standup the resources"
  type        = "string"
  default     = "us-east-1"
}

variable "num_nodes" {
  description = "The number of nodes to spin up"
  default     = 1
}

variable "volume_type" {
  description = "The type of volume"
  type        = "string"
  default     = "standard"
}

variable "volume_size" {
  description = "The size of the volume in GB"
  default     = 8
}

variable "ami" {
  description = "The AMI to use"
  type        = "string"
  default     = ""
}

variable "instance_type" {
  description = "The instance type (defaults to t2.micro)"
  type        = "string"
  default     = "t2.micro"
}

variable "key_name" {
  description = "The key name to use to SSH into the instances"
  type        = "string"
  default     = ""
}

variable "possible_subnets" {
  description = "A list of possible subnets to deploy into"
  type        = "list"
  default     = []
}

variable "security_group_ids" {
  description = "The IDs of the security groups to associate with the instances"
  type        = "list"
  default     = []
}

variable "associate_public_ip_address" {
  description = "Whether or not to associate a public ip address (defaults to false)"
  default     = false
}

variable "user_data" {
  description = "The user data the instance should use on stand up"
  type        = "string"
  default     = ""
}

variable "tags" {
  description = "The instance tags to associate"
  type        = "map"
  default     = {}
}

variable "iam_profile" {
  description = "The IAM profile to attach to the instance"
  type        = "string"
  default     = ""
}
