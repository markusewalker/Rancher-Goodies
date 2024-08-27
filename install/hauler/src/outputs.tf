output "rke2_server_public_dns" {
  value = aws_instance.rke2_server.public_dns
}

output "rke2_agent1_public_dns" {
  value = aws_instance.rke2_agent1.public_dns
}

output "rke2_agent2_public_dns" {
  value = aws_instance.rke2_agent2.public_dns
}

output "registry_public_dns" {
  value = aws_instance.registry.public_dns
}

output "client_public_dns" {
  value = aws_instance.client.public_dns
}