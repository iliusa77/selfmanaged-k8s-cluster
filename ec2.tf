resource "aws_subnet" "subnet" {
  count             = length(var.ec2_availability_zones)
  vpc_id            = module.vpc.vpc_id
  cidr_block        = cidrsubnet("${var.cidrsubnet}", 4, count.index)
  availability_zone = var.ec2_availability_zones[count.index]

  tags = {
    Name = "${var.project}-subnet-${count.index}"
  }
}

resource "aws_key_pair" "deployer" {
  key_name   = "${var.project}-ssh-key"
  public_key = var.public_key
}

resource "aws_instance" "server" {
  count                       = length(var.ec2_availability_zones)
  ami                         = var.ami
  instance_type               = var.instance_type
  key_name                    = "${var.project}-ssh-key"
  subnet_id                   = module.vpc.public_subnets[0]
  vpc_security_group_ids      = ["${module.vpc.default_security_group_id}"]
  associate_public_ip_address = true
  user_data                   = templatefile("./ec2_user_data.sh", {})

  root_block_device {
    delete_on_termination = true
    encrypted             = false
    iops                  = var.root_block_iops
    throughput            = var.root_block_throughput
    volume_size           = var.root_block_volume_size
    volume_type           = var.root_block_volume_type
  }

  tags = {
    Name        = "${var.project}-${count.index}"
    Environment = "dev"
  }

  depends_on = [
    module.vpc,
    aws_subnet.subnet
  ]
}
