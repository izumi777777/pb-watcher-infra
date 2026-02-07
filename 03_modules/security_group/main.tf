# セキュリティグループの器（ハコ）を作成
resource "aws_security_group" "this" {
  name        = "${var.project_name}-${var.env}-sg"
  description = "Allow inbound traffic"
  vpc_id      = var.vpc_id # VPCモジュールから渡されるID

  tags = {
    Name = "${var.project_name}-${var.env}-sg"
  }
}

# インバウンドルール (例: SSH)
resource "aws_security_group_rule" "ingress_ssh" {
  type              = "ingress"
  from_port         = 22
  to_port           = 22
  protocol          = "tcp"
  cidr_blocks      = ["114.51.91.221/32"] # 運用時は特定のIPに絞るのが推奨
  security_group_id = aws_security_group.this.id
}

# アウトバウンドルール (全ての通信を許可)
resource "aws_security_group_rule" "egress_all" {
  type              = "egress"
  from_port         = 0
  to_port           = 0
  protocol          = "-1"
  cidr_blocks      = ["0.0.0.0/0"]
  security_group_id = aws_security_group.this.id
}

# インバウンドルール (例: HTTP)
resource "aws_security_group_rule" "ingress_app" {
  type              = "ingress"
  from_port         = 80
  to_port           = 80
  protocol          = "tcp"
  cidr_blocks       = ["0.0.0.0/0"] # あなたの現在のグローバルIP
  security_group_id = aws_security_group.this.id
}