output "public_ip" {
  value       = aws_instance.windows_workspace.public_ip
  description = "WindowsマシンのパブリックIPアドレス"
}