resource "aws_s3_bucket" "test" {
    bucket = "backup-bucket-ucpintegrador"

    tags = {
        Name        = "Backup storage"
        Environment = "Dev"
    }
}


resource "aws_s3_object" "backup_files" {
  bucket = aws_s3_bucket.test.id
  key    = "ruta/del/archivo/backup.zip"  
  source = "/ruta/local/del/archivo/backup.zip"  

  tags = {
    Name = "Archivo de backup"  
  }
}

resource "aws_instance" "instance1" {
  ami           = "ami-08a0d1e16fc3f61ea"
  instance_type = "t2.micro"
  
  tags = {
    Name = "Integrador-Alta-Disponibilidad-ec2-instance1"
  }

  provisioner "local-exec" {
    command = "echo ${aws_instance.instance1.public_ip}"
  }

  iam_instance_profile = aws_iam_instance_profile.ec2_instance_profile.name
}

resource "aws_instance" "instance2" {
  ami           = "ami-08a0d1e16fc3f61ea"
  instance_type = "t2.micro"
  
  tags = {
    Name = "Integrador-Alta-Disponibilidad-ec2-instance2"
  }

  provisioner "local-exec" {
    command = "echo ${aws_instance.instance2.public_ip}"
  }

  iam_instance_profile = aws_iam_instance_profile.ec2_instance_profile.name
}


resource "aws_iam_role" "ec2_s3_access_role" {
  name = "ec2_s3_access_role"

  assume_role_policy = jsonencode({
    Version = "2012-10-17",
    Statement = [
      {
        Effect = "Allow",
        Principal = {
          Service = "ec2.amazonaws.com"
        },
        Action = "sts:AssumeRole"
      }
    ]
  })
}

resource "aws_iam_policy" "s3_access_policy" {
  name = "s3_access_policy"

  policy = jsonencode({
    Version = "2012-10-17",
    Statement = [
      {
        Effect = "Allow",
        Action = [
          "s3:ListBucket",
          "s3:GetObject",
          "s3:PutObject"
        ],
        Resource = [
          aws_s3_bucket.test.arn,
          "${aws_s3_bucket.test.arn}/*"
        ]
      }
    ]
  })
}

resource "aws_s3_object" "Sito_Web" {
  bucket = aws_s3_bucket.test.id
  key    = "index.html"        
  source = "index.html"
  acl    = "public-read"
}

resource "aws_iam_role_policy_attachment" "attach_s3_policy" {
  role       = aws_iam_role.ec2_s3_access_role.name
  policy_arn = aws_iam_policy.s3_access_policy.arn
}

resource "aws_iam_instance_profile" "ec2_instance_profile" {
  name = "ec2_instance_profile"
  role = aws_iam_role.ec2_s3_access_role.name
}

output "instance1_ip" {
  value = aws_instance.instance1.public_ip
}

output "instance2_ip" {
  value = aws_instance.instance2.public_ip
}