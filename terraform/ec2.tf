# create default vpc if one does not exit
resource "aws_default_vpc" "default_vpc" {
  tags = {
    Name = "default vpc"
  }
}


# use data source to get all avalablility zones in region
data "aws_availability_zones" "available_zones" {}


# create default subnet if one does not exit
resource "aws_default_subnet" "default_az1" {
  availability_zone = data.aws_availability_zones.available_zones.names[0]

  tags = {
    Name = "default subnet"
  }
}


# create security group for the ec2 instance
resource "aws_security_group" "ec2_security_group" {
  name        = "ec2 security group"
  description = "allow access on ports 80, 8080 and 22"
  vpc_id      = aws_default_vpc.default_vpc.id

  ingress {
    description = "http access"
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }
  ingress {
    description = "https access"
    from_port   = 443
    to_port     = 443
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }
  ingress {
    description = "Custom TCP"
    from_port   = 8080
    to_port     = 8080
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  ingress {
    description = "ssh access"
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = -1
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = {
    Name = "Security Group for EC2"
  }
}

# launch the ec2 instance
resource "aws_instance" "ec2_instance" {
  ami                    = "ami-0e8d228ad90af673b"
  instance_type          = "t2.micro"
  subnet_id              = aws_default_subnet.default_az1.id
  vpc_security_group_ids = [aws_security_group.ec2_security_group.id]
  key_name               = "test-ec2-key"

//  # copy the docker-install.sh from the branch to the ec2 instance
//  provisioner "file" {
//    source      = file("docker-install.sh")
//    destination = "/home/ec2-user/docker-install.sh"
//  }
//
//  provisioner "remote-exec" {
//    connection {
//      type = "ssh"
//      user = "ec2-user"
//      host = "${aws_instance.ec2_instance.public_ip}"
//      private_key = "${file("~/Downloads/ec2-key.pem")}"
//      agent = false
//      timeout = "2m"
//    }
//
//    inline = [
//      "sudo chmod +x /home/ec2-user/docker-install.sh",
//      "sh /home/ec2-user/docker-install.sh",
//    ]
//  }
  tags = {
    Name = "Sample EC2 Instance"
  }
}

resource "null_resource" "cluster" {
  # Changes to any instance of the cluster requires re-provisioning
  triggers = {
    cluster_instance_ids = aws_instance.ec2_instance.id
  }
  connection {
    host = aws_instance.ec2_instance.public_ip
  }
  provisioner "remote-exec" {
    # Bootstrap script called with private_ip of each node in the clutser
    inline = [
      "docker-install.sh ${aws_instance.ec2_instance.private_ip}",
    ]
  }
}

//# an empty resource block
//resource "null_resource" "name" {
//
//  # ssh into the ec2 instance
//  connection {
//    type = "ssh"
//    user = "ec2-user"
//    private_key = file("~/Downloads/ec2_key.pem")
//    host = aws_instance.ec2_instance.public_ip
//  }
//
//  # copy the docker-install.sh from the branch to the ec2 instance
//  provisioner "file" {
//    source      = file("docker-install.sh")
//    destination = "/home/ec2-user/docker-install.sh"
//  }
//
//  provisioner "remote-exec" {
//    inline = [
//      "sudo chmod +x /home/ec2-user/docker-install.sh",
//      "sh /home/ec2-user/docker-install.sh",
//    ]
//  }
//}