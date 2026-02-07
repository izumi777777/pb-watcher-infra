variable "replications" {
  description = "CRRの送信元・送信先バケットのペア定義"
  type = map(object({
    source_bucket = string
    dest_bucket   = string
  }))
}

variable "replication_role_arn" {
  type = string
}
