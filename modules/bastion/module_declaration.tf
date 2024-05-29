module "bastion" {
  source            = ""  
  subnet_id         = 
  ssh_key           = ""
  allowed_hosts     = [""]
  internal_networks = []
  disk_size         = 10
  instance_type     = "t2.micro"
  project           = ""
}