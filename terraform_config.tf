terraform {
  required_version = "0.11.13"
}

provider "aws" {
  region              = "${var.region}"
  profile             = "${var.profile}"
  allowed_account_ids = ["${var.account_id}"]
}
