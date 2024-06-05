provider "aws" {
  region = "eu-west-3"
  profile = "set19"
}

resource "aws_s3_bucket" "s3-set19" {
  bucket = "set19-remote-tf"
  force_destroy = true

  tags = {
    Name        = "set19-remote-tf"
  }
}

resource "aws_dynamodb_table" "dynamodb-tfstate" {
  name           = "petclinic"
  read_capacity  = 10
  write_capacity = 10
  hash_key       = "LockId"
  attribute {
    name = "LockId"
    type = "S"
  }

}