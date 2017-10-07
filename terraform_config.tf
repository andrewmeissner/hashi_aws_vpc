terraform {
  required_version = "0.10.7"
}

provider "aws" {
  region              = "${var.region}"
  profile             = "andrew"
  allowed_account_ids = ["${var.account_id}"]
}
