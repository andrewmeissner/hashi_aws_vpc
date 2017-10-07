variable "max_clients" {
  description = "The maximum number of clients to spin up"
  type        = "string"
}

variable "min_clients" {
  description = "The minimum number of clients to spin up"
  type        = "string"
}

variable "desired_clients" {
  description = "The number of lients you want running"
  type        = "string"
}

variable "cluster_name" {
  description = "The type of instance the scheduler will use to determine what to deploy to the nodes."
  type        = "string"
}

variable "region" {
  description = "The region to deploy the instances in"
  type        = "string"
}

variable "instance_type" {
  description = "The type of EC2 Instances to run for each node in the cluster"
  type        = "string"
}

variable "ami" {
  description = "The ID of the AMI to run in this cluster."
  type        = "string"
}

variable "availability_zones" {
  description = "The availability zones into which the EC2 Instances should be deployed."
  type        = "list"
  default     = []
}

variable "subnet_ids" {
  description = "The subnet IDs into which the EC2 Instances should be deployed."
  type        = "list"
  default     = []
}

variable "iam_instance_profile_name" {
  description = "The IAM profile to attach to the instances"
  type        = "string"
  default     = ""
}

variable "key_name" {
  description = "The SSH key to use to SSH into the instances"
  type        = "string"
  default     = ""
}

variable "security_group_ids" {
  description = "The security group IDs to associate with the instances"
  type        = "list"
  default     = []
}

variable "associate_public_ip_address" {
  description = "Whether or not to associate a public ip address"
  type        = "string"
  default     = false
}

variable "termination_policies" {
  description = "A list of policies to decide how the instances in the ASG should be termianted"
  type        = "list"
  default     = ["Default"]
}

variable "ignition_user_ids" {
  description = "A list of user ids from ignition"
  type        = "list"
  default     = []
}

variable "ignition_group_ids" {
  description = "A list of group ids from ignition"
  type        = "list"
  default     = []
}

variable "ignition_systemd_ids" {
  description = "A list of systemd unit ids from ignition"
  type        = "list"
  default     = []
}
