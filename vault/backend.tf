terraform {
  backend "s3" {
    bucket = "set19-remote-tf"
    key = "set19-vault/tfstate"
    dynamodb_table = "petclinic"
    region = "eu-west-2"
    encrypt = true
    profile ="default"
  }
}
