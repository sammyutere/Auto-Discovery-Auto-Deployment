variable "key_name" {
  description = "The name for the key pair. Conflicts with `key_name_prefix`"
  type        = string
  default     = null
}

variable "create_private_key" {
  description = "whether to create private key"
  type        = bool
  default     = false
}