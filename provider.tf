provider "aws" {
  region = "eu-west-3"
}
provider "vault" {
  token = ""
  address = "https://vault.greatminds.sbs"
  
}