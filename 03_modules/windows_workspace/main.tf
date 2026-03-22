# 最新の Windows Server 2022 (日本語版) のAMIを自動取得
data "aws_ami" "windows_2022_ja" {
  most_recent = true
  owners      = ["amazon"]

  filter {
    name   = "name"
    values = ["Windows_Server-2022-Japanese-Full-Base-*"]
  }
}

# Windows用の専用セキュリティグループ
resource "aws_security_group" "windows_sg" {
  name        = "${var.project_name}-${var.env}-windows-sg"
  description = "Security group for Windows Workspace (RDP)"
  vpc_id      = var.vpc_id 

  ingress {
    from_port   = 3389
    to_port     = 3389
    protocol    = "tcp"
    # 外（ルート）から渡されたIPアドレスを使用
    cidr_blocks = ["${var.my_global_ip}/32"] 
    description = "Allow RDP from my home network"
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
  
  tags = {
    Name = "${var.project_name}-${var.env}-windows-sg"
  }
}

# Windows EC2インスタンス本体
resource "aws_instance" "windows_workspace" {
  ami                         = data.aws_ami.windows_2022_ja.id
  instance_type               = "m5d.xlarge"
  subnet_id                   = var.subnet_id
  vpc_security_group_ids      = [aws_security_group.windows_sg.id]
  associate_public_ip_address = true
  key_name                    = var.key_name

  root_block_device {
    volume_type = "gp3"
    volume_size = 64
    encrypted   = true
  }

  tags = {
    Name = "windows-workspace"
  }

  lifecycle {
    # 変更を無視したい属性を指定します
    # 全ての変更を無視したい場合は all を指定
    ignore_changes = all
    
    # 特定の項目（例：AMIやタグなど）だけ固定したい場合はリストで指定
    # ignore_changes = [
    #   ami,
    #   user_data,
    #   instance_type,
    #   tags,
    # ]
  }

}