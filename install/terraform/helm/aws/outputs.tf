output "rke2_client_public_dns" {
  value = aws_instance.rke2_client.public_dns
}

output "rke2_server_public_dns" {
  value = aws_instance.rke2_server.public_dns
}

output "rke2_server_private_ip" {
  value = aws_instance.rke2_server.private_ip
}

output "rke2_agent1_public_dns" {
  value = aws_instance.rke2_agent1.public_dns
}

output "rke2_agent2_public_dns" {
  value = aws_instance.rke2_agent2.public_dns
}