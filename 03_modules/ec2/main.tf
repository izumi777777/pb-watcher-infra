# --- EC2を構築する ---
resource "aws_instance" "app" {
  ami                         = var.ami_id
  instance_type               = var.instance_type
  subnet_id                   = var.subnet_id
  vpc_security_group_ids      = [var.security_group_id]
  associate_public_ip_address = true
  key_name                    = "terraform_keypair"
  iam_instance_profile        = var.iam_instance_profile

  # --- ユーザーデータ（初期化スクリプト） ---
  user_data = <<-EOF
    #!/bin/bash
    # システムの更新
    dnf update -y

    # Docker & Git のインストール (Amazon Linux 2023想定)
    dnf install -y docker git
    
    # Docker サービスの起動と有効化
    systemctl start docker
    systemctl enable docker

    # ec2-user を docker グループに追加（再ログイン後に sudo なしで docker が打てるように）
    usermod -aG docker ec2-user

    # ディレクトリの作成
    mkdir -p /home/ec2-user/work/python/p-bandai-monitor
    
    # 所有権を ec2-user に変更
    chown -R ec2-user:ec2-user /home/ec2-user/work
    
    # 完了の印（デバッグ用）
    echo "Setup Complete" > /home/ec2-user/setup_done.txt
  EOF

  tags = {
    Name = "${var.project_name}-${var.env}-ec2"
  }
}