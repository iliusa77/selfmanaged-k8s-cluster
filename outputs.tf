output "instance_1_public_ip" {
  value = aws_instance.server[0].public_ip
}

output "instance_2_public_ip" {
  value = aws_instance.server[1].public_ip
}

output "instance_3_public_ip" {
  value = aws_instance.server[2].public_ip
}

output "instance_1_private_ip" {
  value = aws_instance.server[0].private_ip
}

output "instance_2_private_ip" {
  value = aws_instance.server[1].private_ip
}

output "instance_3_private_ip" {
  value = aws_instance.server[2].private_ip
}