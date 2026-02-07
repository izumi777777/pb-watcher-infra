# modules/security_group/outputs.tf

output "sg_id" {
  value = aws_security_group.this.id
}

# --- 以下の vpc_id や public_subnet_1a_id の記述があれば削除してください ---
# これらは modules/vpc/outputs.tf に書くべき内容です。