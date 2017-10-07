resource "aws_instance" "instance" {
  count                       = "${var.num_nodes}"
  ami                         = "${var.ami}"
  instance_type               = "${var.instance_type}"
  key_name                    = "${var.key_name}"
  vpc_security_group_ids      = ["${var.security_group_ids}"]
  associate_public_ip_address = "${var.associate_public_ip_address}"
  subnet_id                   = "${element(var.possible_subnets, count.index)}"
  iam_instance_profile        = "${var.iam_profile}"
  user_data                   = "${var.user_data}"
  tags                        = "${merge(var.tags, map("Name", format("%s%s%s", var.name, var.num_nodes > 1 ? "-" : "", var.num_nodes > 1 ? "${count.index+1}" : "")))}"
}
