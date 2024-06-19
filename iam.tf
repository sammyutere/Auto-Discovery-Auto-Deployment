resource "aws_iam_role" "pet_role" {
  name = "petaccess-role"

  assume_role_policy = jsonencode({
    Version = "2012-10-17",
    Statement = [
      {
        Action = "sts:AssumeRole",
        Effect = "Allow",
        Principal = {
          Service = "ec2.amazonaws.com"
        }
      }
    ]
  })

  tags = {
    Name = "petaccess-role"
  }
}

resource "aws_iam_role_policy_attachment" "s3-attach" {
  role     = aws_iam_role.pet_role.id
  policy_arn = "arn:aws:iam::aws:policy/AmazonS3FullAccess"
}
