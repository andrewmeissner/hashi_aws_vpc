data "template_file" "ignition_data" {
  template = "${data.ignition_config.client_config.rendered}"

  vars {
    client_type = "${var.cluster_name}"
  }
}

resource "aws_launch_configuration" "launch_configuration" {
  instance_type               = "${var.instance_type}"
  name_prefix                 = "${var.cluster_name}-"
  image_id                    = "${var.ami}"
  iam_instance_profile        = "${var.iam_instance_profile_name}"
  key_name                    = "${var.key_name}"
  security_groups             = ["${var.security_group_ids}"]
  associate_public_ip_address = "${var.associate_public_ip_address}"
  user_data                   = "${data.template_file.ignition_data.rendered}"

  lifecycle {
    create_before_destroy = true
    ignore_changes        = ["name"]
  }
}

resource "aws_autoscaling_group" "autoscaling_group" {
  max_size             = "${var.max_clients}"
  min_size             = "${var.min_clients}"
  desired_capacity     = "${var.desired_clients}"
  launch_configuration = "${aws_launch_configuration.launch_configuration.name}"
  availability_zones   = ["${var.availability_zones}"]
  vpc_zone_identifier  = ["${var.subnet_ids}"]
  health_check_type    = "EC2"
  termination_policies = ["${var.termination_policies}"]

  tag {
    key                 = "Name"
    value               = "${var.cluster_name}"
    propagate_at_launch = true
  }

  tag {
    key                 = "Terraform"
    value               = "true"
    propagate_at_launch = true
  }

  lifecycle {
    create_before_destroy = true
  }
}

resource "aws_autoscaling_policy" "policy" {
  name                   = "${var.cluster_name}-policy"
  autoscaling_group_name = "${aws_autoscaling_group.autoscaling_group.name}"
  adjustment_type        = "ChangeInCapacity"
  policy_type            = "SimpleScaling"
  cooldown               = 30
  scaling_adjustment     = 3
}
