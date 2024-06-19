data "aws_availability_zones" "available" {}

module vpc {
    source = "terraform-aws-modules/vpc/aws"
   
    name = "${ var.project }-vpc"
    cidr = "10.0.0.0/16"
    
    azs = data.aws_availability_zones.available.names
    private_subnets = ["10.0.1.0/24", "10.0.2.0/24", "10.0.3.0/24"]
    public_subnets =  ["10.0.4.0/24", "10.0.5.0/24", "10.0.6.0/24"]
    
    enable_nat_gateway = true
    single_nat_gateway = true
    
    enable_dns_hostnames= true
    tags = {
        "Name" = "${ var.project }-vpc"
    }
    public_subnet_tags = {
        "Name" = "${ var.project }-public-subnet"
    }
    private_subnet_tags = {
        "Name" = "${ var.project }-private-subnet"
    }
}

resource "aws_security_group_rule" "ssh" {
  security_group_id = "${ module.vpc.default_security_group_id }"
  type              = "ingress"
  from_port         = 22
  to_port           = 22
  protocol          = "tcp"
  cidr_blocks       = ["0.0.0.0/0"]
  description       = "SSH allow"

  depends_on = [
    module.vpc
  ] 
}

resource "aws_security_group_rule" "k8s_api_port" {
  security_group_id = "${ module.vpc.default_security_group_id }"
  type              = "ingress"
  from_port         = 6443
  to_port           = 6443
  protocol          = "tcp"
  cidr_blocks       = ["0.0.0.0/0"]
  description       = "Kubernetes API server"

  depends_on = [
    module.vpc
  ] 
}

resource "aws_security_group_rule" "etcd_port" {
  security_group_id = "${ module.vpc.default_security_group_id }"
  type              = "ingress"
  from_port         = 2379
  to_port           = 2380
  protocol          = "tcp"
  cidr_blocks       = ["0.0.0.0/0"]
  description       = "etcd server client API"

  depends_on = [
    module.vpc
  ] 
}

resource "aws_security_group_rule" "kubelet_api_port" {
  security_group_id = "${ module.vpc.default_security_group_id }"
  type              = "ingress"
  from_port         = 10250
  to_port           = 10250
  protocol          = "tcp"
  cidr_blocks       = ["0.0.0.0/0"]
  description       = "Kubelet API"

  depends_on = [
    module.vpc
  ] 
}

resource "aws_security_group_rule" "kube_scheduler_port" {
  security_group_id = "${ module.vpc.default_security_group_id }"
  type              = "ingress"
  from_port         = 10259
  to_port           = 10259
  protocol          = "tcp"
  cidr_blocks       = ["0.0.0.0/0"]
  description       = "kube-scheduler"

  depends_on = [
    module.vpc
  ] 
}

resource "aws_security_group_rule" "kube_controller_manager_port" {
  security_group_id = "${ module.vpc.default_security_group_id }"
  type              = "ingress"
  from_port         = 10257
  to_port           = 10257
  protocol          = "tcp"
  cidr_blocks       = ["0.0.0.0/0"]
  description       = "kube-controller-manager"

  depends_on = [
    module.vpc
  ] 
}

resource "aws_security_group_rule" "kube_proxy_port" {
  security_group_id = "${ module.vpc.default_security_group_id }"
  type              = "ingress"
  from_port         = 10256
  to_port           = 10256
  protocol          = "tcp"
  cidr_blocks       = ["0.0.0.0/0"]
  description       = "kube-proxy"

  depends_on = [
    module.vpc
  ] 
}

resource "aws_security_group_rule" "nodeport_sevices_port" {
  security_group_id = "${ module.vpc.default_security_group_id }"
  type              = "ingress"
  from_port         = 30000
  to_port           = 32767
  protocol          = "tcp"
  cidr_blocks       = ["0.0.0.0/0"]
  description       = "NodePort Services"

  depends_on = [
    module.vpc
  ] 
}

resource "aws_security_group_rule" "http_port" {
  security_group_id = "${ module.vpc.default_security_group_id }"
  type              = "ingress"
  from_port         = 80
  to_port           = 80
  protocol          = "tcp"
  cidr_blocks       = ["0.0.0.0/0"]
  description       = "HTTP allow"

  depends_on = [
    module.vpc
  ] 
}

resource "aws_security_group_rule" "https_port" {
  security_group_id = "${ module.vpc.default_security_group_id }"
  type              = "ingress"
  from_port         = 443
  to_port           = 443
  protocol          = "tcp"
  cidr_blocks       = ["0.0.0.0/0"]
  description       = "HTTPS allow"

  depends_on = [
    module.vpc
  ] 
}

resource "aws_security_group_rule" "dns_port" {
  security_group_id = "${ module.vpc.default_security_group_id }"
  type              = "ingress"
  from_port         = 53
  to_port           = 53
  protocol          = "tcp"
  cidr_blocks       = ["0.0.0.0/0"]
  description       = "DNS allow"

  depends_on = [
    module.vpc
  ] 
}

resource "aws_security_group_rule" "outbound" {
  security_group_id = "${ module.vpc.default_security_group_id }"
  type              = "egress"
  to_port           = 0
  protocol          = "-1"
  cidr_blocks       = ["0.0.0.0/0"]
  from_port         = 0
  description       = "All outbound traffic allow"

  depends_on = [
    module.vpc
  ] 
}