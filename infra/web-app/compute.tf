# Hardcoded to latest stable Canonical Ubuntu 26.04 LTS ARM64 image.
data "aws_ssm_parameter" "ubuntu" {
  name = "/aws/service/canonical/ubuntu/server/26.04/stable/current/arm64/hvm/ebs-gp3/ami-id"
}

locals {
  asg_name         = "${var.project}-web"
  launch_hook_name = "bootstrap"
}

resource "aws_launch_template" "this" {
  name_prefix   = "${var.project}-web-"
  image_id      = nonsensitive(data.aws_ssm_parameter.ubuntu.value)
  instance_type = "t4g.small"

  iam_instance_profile {
    name = aws_iam_instance_profile.this.name
  }

  network_interfaces {
    device_index                = 0
    associate_public_ip_address = true
    delete_on_termination       = true
    security_groups             = [aws_security_group.instance.id]
  }

  metadata_options {
    http_endpoint               = "enabled"
    http_tokens                 = "required"
    http_put_response_hop_limit = 1
  }

  block_device_mappings {
    device_name = "/dev/sda1"
    ebs {
      volume_type           = "gp3"
      volume_size           = 30
      encrypted             = true
      delete_on_termination = true
    }
  }

  credit_specification {
    cpu_credits = "standard"
  }

  user_data = base64encode(templatefile("${path.module}/user-data.sh.tftpl", {
    image     = var.image_tag
    region    = data.aws_region.current.region
    asg_name  = local.asg_name
    hook_name = local.launch_hook_name
    cloudwatch_config = jsonencode({
      agent = { region = data.aws_region.current.region }
      logs = {
        force_flush_interval = 5
        logs_collected = {
          files = {
            collect_list = [for log in ["cloud-init.log", "cloud-init-output.log"] : {
              file_path       = "/var/log/${log}"
              log_group_name  = aws_cloudwatch_log_group.this.name
              log_stream_name = "{instance_id}/${log}"
            }]
          }
        }
      }
    })
  }))

  tag_specifications {
    resource_type = "instance"
    tags = {
      Name    = "${var.project}-web"
      Project = var.project
    }
  }

  tag_specifications {
    resource_type = "volume"
    tags = {
      Name    = "${var.project}-web"
      Project = var.project
    }
  }

  # References above only cover the instance profile and security group, not
  # the policies and rules attached to them.
  depends_on = [
    aws_iam_role_policy.instance,
    aws_iam_role_policy_attachment.ssm,
    aws_vpc_security_group_ingress_rule.instance_from_alb,
    aws_vpc_security_group_egress_rule.instance_all
  ]
}

resource "aws_autoscaling_group" "this" {
  name                      = local.asg_name
  min_size                  = 2
  desired_capacity          = 2
  max_size                  = 2
  vpc_zone_identifier       = var.public_subnet_ids
  target_group_arns         = [aws_lb_target_group.this.arn]
  health_check_type         = "ELB"
  health_check_grace_period = 300
  default_instance_warmup   = 120
  min_elb_capacity          = 2
  wait_for_capacity_timeout = "15m"

  launch_template {
    id      = aws_launch_template.this.id
    version = aws_launch_template.this.latest_version
  }

  initial_lifecycle_hook {
    name                 = local.launch_hook_name
    lifecycle_transition = "autoscaling:EC2_INSTANCE_LAUNCHING"
    heartbeat_timeout    = 120
    default_result       = "ABANDON"
  }

  instance_refresh {
    strategy = "Rolling"
    preferences {
      min_healthy_percentage = 100
      max_healthy_percentage = 150
      instance_warmup        = 120
    }
  }

  depends_on = [
    aws_lb_listener.http,
    aws_vpc_security_group_ingress_rule.http,
    aws_vpc_security_group_egress_rule.alb_to_instance
  ]
}
