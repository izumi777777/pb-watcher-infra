variable "project_name" { type = string }
variable "env" { type = string }
variable "vpc_id" { type = string }
variable "subnet_id" { type = string }
variable "key_name" { type = string }
variable "my_global_ip" { 
  type = string 
  description = "RDP接続を許可する自身のグローバルIPアドレス"
}