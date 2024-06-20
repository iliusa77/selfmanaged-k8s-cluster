variable "project" {
  default = "selfmanaged-k8s-cluster"
}

variable "region" {
  default = "eu-west-2"
}

variable "profile" {
    description = "AWS credentials profile you want to use"
}

variable "instance_type" {
  default = "t2.medium" #2vCPU #4gb RAM
}

variable "ami" {
  default = "ami-09627c82937ccdd6d" #Ubuntu 22.04 LTS
}


variable "public_key" {
  default = "ssh-rsa AAAAB3NzaC1yc2EAAAADAQABAAACAQDKdRQpaWvSTq+3r5yu/4U+CzIxF5Km9I1tmhx/XaWo4eyUg0DYe+BqZ2UgbcWfbtVtA2mkZ2l0zddxEsUT7DWqpTUuti76ImZFvjU3q7OMtbf8mUVlxSZ2fdK01Xg8mVvifakTdPi4x/o6ApWHkNPv2EW5mdJOYUPWXloIGhnuy2RJFDJR4TVQJWQopKImuzOID9c71xJEP2U32So2zTTwx6CHXxeW5YBE9CXybyGk5DCp664/ak6PTe0SHAw9IBMOe++GaQI+7zt0UlF3eGe1IrzAD3tnFBsNMHhklYXDX8/5+xZ8UkGAme84dMauCfOZmDZT/ZY+85myjU+8R7zad6hT3DkJ+3ip0wqq4xjmXJ8T5GSmYIdIkgh+33SNoc7jFTppckk1v+kgs8VM98r+uqa77sQ4VMSK2cLOxMjFF0iU195aX0qy8KxfNTbmz64EehyhLJZq4/JsDUAeqAGpqPetX+AQT9rT8OWY+VHVhk7x8Ih9NDYE4m6pUxWVkg/VSlKhXDqQkXQFSg24pzqsKuen6dgoOdK+TgnfOgfx0U52u5fpv6JtwAJjZTREhyDsY1hQ3n+2SWgtmZyG8A9Xzu1CrWZYbO0yzOievsnuhVNcdxqmC2G+AfGZlEPlPcXyBsDzm9Y06rcZPvq+1xaimCrpLwr6dMM4THDeHiqEtw== macuser@MacBook-Pro-Mac.local"
}

variable "root_block_volume_type" {
  default = "gp3"
}
variable "root_block_throughput" {
  default = 125
}
variable "root_block_volume_size" {
  default = 50
}
variable "root_block_iops" {
  default = 3000
}

variable "ec2_availability_zones" {
  default = ["eu-west-2a", "eu-west-2b", "eu-west-2c"]
}

variable "cidrsubnet" {
  default     = "10.0.128.0/24"
}
