variable "ami-ubuntu" {
    default = "ami-07c1b39b7b3d2525d"
}
variable "ssh_user" {
    default = "ubuntu"
}

variable "ssh_key" {
  default = "./vault-private-key"
}