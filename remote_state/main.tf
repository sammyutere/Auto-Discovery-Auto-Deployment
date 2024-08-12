provider "aws" {
  region = "eu-west-2"
  profile = "default"
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
  hash_key       = "LockID"
  attribute {
    name = "LockID"
    type = "S"
  }

}

