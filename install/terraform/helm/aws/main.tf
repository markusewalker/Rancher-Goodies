terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "5.53.0"
    }
  }
}

provider "aws" {
  access_key = var.aws_access_key
  secret_key = var.aws_secret_key
  region     = var.aws_region
}

resource "aws_instance" "rke2_client" {
  ami                         = var.aws_ami
  associate_public_ip_address = true
  instance_type               = var.aws_instance_type
  key_name                    = var.key_name
  subnet_id                   = var.aws_subnet
  vpc_security_group_ids      = [var.aws_security_group]

  root_block_device {
    volume_size = var.aws_instance_size
  }

  tags = {
    Name = var.aws_client_prefix
  }

  connection {
    type        = var.ssh_connection_type
    host        = self.public_ip
    user        = var.aws_user
    private_key = file(var.ssh_private_key_path)
    timeout     = var.ssh_timeout
  }
}

resource "aws_instance" "rke2_server" {
  ami                         = var.aws_ami
  associate_public_ip_address = true
  instance_type               = var.aws_instance_type
  key_name                    = var.key_name
  subnet_id                   = var.aws_subnet
  vpc_security_group_ids      = [var.aws_security_group]

  root_block_device {
    volume_size = var.aws_instance_size
  }

  tags = {
    Name = var.aws_server_prefix
  }

  connection {
    type        = var.ssh_connection_type
    host        = self.public_ip
    user        = var.aws_user
    private_key = file(var.ssh_private_key_path)
    timeout     = var.ssh_timeout
  }
}

resource "aws_instance" "rke2_agent1" {
  ami                         = var.aws_ami
  associate_public_ip_address = true
  instance_type               = var.aws_instance_type
  key_name                    = var.key_name
  subnet_id                   = var.aws_subnet
  vpc_security_group_ids      = [var.aws_security_group]

  root_block_device {
    volume_size = var.aws_instance_size
  }

  tags = {
    Name = var.aws_agent1_prefix
  }

  connection {
    type        = var.ssh_connection_type
    host        = self.public_ip
    user        = var.aws_user
    private_key = file(var.ssh_private_key_path)
    timeout     = var.ssh_timeout
  }
}

resource "aws_instance" "rke2_agent2" {
  ami                         = var.aws_ami
  associate_public_ip_address = true
  instance_type               = var.aws_instance_type
  key_name                    = var.key_name
  subnet_id                   = var.aws_subnet
  vpc_security_group_ids      = [var.aws_security_group]

  root_block_device {
    volume_size = var.aws_instance_size
  }

  tags = {
    Name = var.aws_agent2_prefix
  }

  connection {
    type        = var.ssh_connection_type
    host        = self.public_ip
    user        = var.aws_user
    private_key = file(var.ssh_private_key_path)
    timeout     = var.ssh_timeout
  }
}

locals {
  rke2_instance_ids = {
    rke2_server = aws_instance.rke2_server.id,
    rke2_agent1 = aws_instance.rke2_agent1.id,
    rke2_agent2 = aws_instance.rke2_agent2.id
  }
}

resource "aws_lb_target_group_attachment" "aws_tg_attachment_80_server" {
  for_each         = local.rke2_instance_ids
  target_group_arn = aws_lb_target_group.aws_tg_80.arn
  target_id        = each.value
  port             = 80
}

resource "aws_lb_target_group_attachment" "aws_tg_attachment_443_server" {
  for_each         = local.rke2_instance_ids
  target_group_arn = aws_lb_target_group.aws_tg_443.arn
  target_id        = each.value
  port             = 443
}

resource "aws_lb_target_group_attachment" "aws_tg_attachment_6443_server" {
  for_each         = local.rke2_instance_ids
  target_group_arn = aws_lb_target_group.aws_tg_6443.arn
  target_id        = each.value
  port             = 6443
}

resource "aws_lb_target_group_attachment" "aws_tg_attachment_9345_server" {
  for_each         = local.rke2_instance_ids
  target_group_arn = aws_lb_target_group.aws_tg_9345.arn
  target_id        = each.value
  port             = 9345
}

resource "aws_lb_target_group_attachment" "aws_tg_attachment_80" {
  for_each         = local.rke2_instance_ids
  target_group_arn = aws_lb_target_group.aws_tg_80.arn
  target_id        = each.value
  port             = 80
}

resource "aws_lb" "aws_nlb" {
  internal           = false
  load_balancer_type = "network"
  subnets            = [var.aws_subnet]
  name               = "${var.aws_prefix}-nlb"
}

resource "aws_lb_target_group" "aws_tg_80" {
  port     = 80
  protocol = "TCP"
  vpc_id   = var.aws_vpc
  name     = "${var.aws_prefix}-tg-80"
  health_check {
    protocol            = "HTTP"
    port                = "traffic-port"
    path                = "/ping"
    interval            = 10
    timeout             = 6
    healthy_threshold   = 3
    unhealthy_threshold = 3
    matcher             = "200-399"
  }
}

resource "aws_lb_target_group" "aws_tg_443" {
  port     = 443
  protocol = "TCP"
  vpc_id   = var.aws_vpc
  name     = "${var.aws_prefix}-tg-443"
  health_check {
    protocol            = "HTTP"
    port                = 80
    path                = "/ping"
    interval            = 10
    timeout             = 6
    healthy_threshold   = 3
    unhealthy_threshold = 3
    matcher             = "200-399"
  }
}

resource "aws_lb_target_group" "aws_tg_6443" {
  port     = 6443
  protocol = "TCP"
  vpc_id   = var.aws_vpc
  name     = "${var.aws_prefix}-tg-6443"
  health_check {
    protocol            = "HTTP"
    port                = 80
    path                = "/ping"
    interval            = 10
    timeout             = 6
    healthy_threshold   = 3
    unhealthy_threshold = 3
    matcher             = "200-399"
  }
}

resource "aws_lb_target_group" "aws_tg_9345" {
  port     = 9345
  protocol = "TCP"
  vpc_id   = var.aws_vpc
  name     = "${var.aws_prefix}-tg-9345"
  health_check {
    protocol            = "HTTP"
    port                = 80
    path                = "/ping"
    interval            = 10
    timeout             = 6
    healthy_threshold   = 3
    unhealthy_threshold = 3
    matcher             = "200-399"
  }
}

resource "aws_lb_listener" "aws_nlb_listener_80" {
  load_balancer_arn = aws_lb.aws_nlb.arn
  port              = "80"
  protocol          = "TCP"
  default_action {
    type             = "forward"
    target_group_arn = aws_lb_target_group.aws_tg_80.arn
  }
}

resource "aws_lb_listener" "aws_nlb_listener_443" {
  load_balancer_arn = aws_lb.aws_nlb.arn
  port              = "443"
  protocol          = "TCP"
  default_action {
    type             = "forward"
    target_group_arn = aws_lb_target_group.aws_tg_443.arn
  }
}

resource "aws_lb_listener" "aws_nlb_listener_6443" {
  load_balancer_arn = aws_lb.aws_nlb.arn
  port              = "6443"
  protocol          = "TCP"
  default_action {
    type             = "forward"
    target_group_arn = aws_lb_target_group.aws_tg_6443.arn
  }
}

resource "aws_lb_listener" "aws_nlb_listener_9345" {
  load_balancer_arn = aws_lb.aws_nlb.arn
  port              = "9345"
  protocol          = "TCP"
  default_action {
    type             = "forward"
    target_group_arn = aws_lb_target_group.aws_tg_9345.arn
  }
}

resource "aws_route53_record" "aws_route53" {
  zone_id = data.aws_route53_zone.selected.zone_id
  name    = var.aws_prefix
  type    = "CNAME"
  ttl     = "300"
  records = [aws_lb.aws_nlb.dns_name]
}

data "aws_route53_zone" "selected" {
  name         = var.aws_route53_zone
  private_zone = false
}