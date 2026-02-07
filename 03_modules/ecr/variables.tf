variable "repository_name" { type = string }
variable "image_tag_mutability" { 
  type    = string
  default = "MUTABLE" # 「MUTABLE」に設定することで、同じタグでのプッシュ（上書き）を許可します(開発用)
}
variable "scan_on_push" {
  type    = bool
  default = true
}
variable "untagged_image_count" {
  type    = number
  default = 5 # タグなしイメージを保持する数
}