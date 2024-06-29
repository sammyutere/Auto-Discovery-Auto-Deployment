variable "ami-ubuntu" {
    default = "ami-00ac45f3035ff009e"
}
variable "ssh_user" {
    default = "ubuntu"
}

variable "ssh_key" {
  default = "./vault-private-key"
}