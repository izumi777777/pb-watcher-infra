resource "aws_vpc" "main" {
  cidr_block           = var.vpc_cidr
  enable_dns_support   = true
  enable_dns_hostnames = true

  tags = {
    Name = "${var.project_name}-${var.env}-vpc"
  }
}

# インターネットゲートウェイ
resource "aws_internet_gateway" "igw" {
  vpc_id = aws_vpc.main.id
  tags   = { Name = "${var.project_name}-${var.env}-igw" }
}

# 例としてパブリックサブネットを1つ作成
resource "aws_subnet" "public_1a" {
  vpc_id            = aws_vpc.main.id
  cidr_block        = cidrsubnet(var.vpc_cidr, 8, 1) # 自動計算
  availability_zone = "ap-northeast-1a"
  tags              = { Name = "${var.project_name}-${var.env}-public-1a" }
}

# 1cサブネットの定義（これが足りなかった！）
# resource "aws_subnet" "public_1c" {
#   vpc_id            = aws_vpc.main.id
#   cidr_block        = cidrsubnet(var.vpc_cidr, 8, 2) # 1aが "1" なら、こちらは "2" にして重複を避ける
#   availability_zone = "ap-northeast-1c"
#   tags              = { Name = "${var.project_name}-${var.env}-public-1c" }
# }

# パブリック用ルートテーブル
resource "aws_route_table" "public" {
  vpc_id = aws_vpc.main.id
  
  # デフォルトルート
  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.igw.id
  }

  tags = {Name = "${var.project_name}-${var.env}-public-rt"}

}

# 3. ルートテーブルをサブネットに紐付け (Association)
resource "aws_route_table_association" "public_1a" {
  subnet_id      = aws_subnet.public_1a.id
  route_table_id = aws_route_table.public.id
}

# resource "aws_route_table_association" "public_1c" {
#   subnet_id      = aws_subnet.public_1c.id
#   route_table_id = aws_route_table.public.id
# }