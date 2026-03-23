# 1. Dynamically fetch the latest Amazon Linux 2023 AMI
data "aws_ami" "amazon_linux_2023" {
  most_recent = true
  owners      = ["amazon"]

  filter {
    name   = "name"
    values = ["al2023-ami-2023.*-x86_64"]
  }
}

# 2. Create IAM Role for AWS Systems Manager (SSM)
resource "aws_iam_role" "ssm_role" {
  name = "cubic-defense-ssm-role"

  # Trust policy: Allow EC2 service to assume this role
  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Action = "sts:AssumeRole"
        Effect = "Allow"
        Principal = {
          Service = "ec2.amazonaws.com"
        }
      }
    ]
  })
}

# 3. Attach the AWS managed SSM policy to our role
resource "aws_iam_role_policy_attachment" "ssm_policy" {
  role       = aws_iam_role.ssm_role.name
  policy_arn = "arn:aws:iam::aws:policy/AmazonSSMManagedInstanceCore"
}

# 4. Create an Instance Profile (The container that attaches the role to the EC2)
resource "aws_iam_instance_profile" "ssm_profile" {
  name = "cubic-defense-ssm-profile"
  role = aws_iam_role.ssm_role.name
}

# 5. Provision the EC2 Instance in the Private Subnet
resource "aws_instance" "app_server" {
  ami           = data.aws_ami.amazon_linux_2023.id
  instance_type = "t3.micro" # Cost-effective instance type

  # Place the server securely in the FIRST Private Subnet
  subnet_id = module.vpc.private_subnets[0]

  # Apply our Zero-Trust Private Security Group
  vpc_security_group_ids = [aws_security_group.private_sg.id]

  # Attach the IAM Profile for session access (NO SSH KEYS REQUIRED)
  iam_instance_profile = aws_iam_instance_profile.ssm_profile.name

  tags = {
    Name = "cubic-defense-app-server"
    Tier = "Private"
  }
}