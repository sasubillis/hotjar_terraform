# connect to aws
#==========================
provider "aws" {
  access_key = "${var.aws_access_key}"
  secret_key = "${var.aws_secret_key}"
  region = "${var.aws_region}"
}

# deploy ec2 instance with centos ami . this is comissioning node
#==========================
resource "aws_instance" "deploynode" {
  # Customized  my own centos, ex. selinux disabled as it is not production server, sshd config changed
  ami = "${var.ami_id}"
  instance_type = "t2.medium"
  vpc_security_group_ids = ["${aws_security_group.allow_ssh_http.id}"]
  key_name = "${var.ssh_key_name}"
  availability_zone = "us-east-1a"

  tags {
    Name = "Installation node"
  }
  root_block_device {
   delete_on_termination = "true"
  }
  provisioner "file" {
     source = "../conf/infrastructure_aws.tgz"
     destination = "/tmp/infrastructure_aws.tgz"
     connection {
         type = "ssh"
         user = "centos"
         private_key = "${file("/root/sreenu.pem")}"
     }
  }
  #user_data = "#!/bin/bash\nmkdir /ephemeral; mkfs.xfs /dev/xvdb -f; mount /dev/xvdb /ephemeral;"
  user_data = "${file("${path.module}/user_data_comm.sh")}"

}


# deploy ec2 instances for ETL Spark cluster
#==========================
resource "aws_instance" "etlnode" {
  # Customized  my own centos, ex. selinux disabled as it is not production server, sshd config changed
  ami = "${var.ami_id}"
  instance_type = "t2.medium"
  vpc_security_group_ids = ["${aws_security_group.allow_ssh_http.id}"]
  key_name = "${var.ssh_key_name}"
  count = 3
  availability_zone = "us-east-1a"
  root_block_device {
   delete_on_termination = "true"
  }

  tags {
    Name = "etlsparknode-${count.index} "
  }
  user_data = "${file("${path.module}/user_data_etl.sh")}"
}
# ----------------------------------------------------------------------------
# CREATE THE SECURITY GROUP THAT'S APPLIED TO THE EC2 INSTANCE
# ---------------------------------------------------------------------------

resource "aws_security_group" "allow_ssh_http" {
  name = "allow ssh and http port 80 traffic"
  description = "Allow inbound SSH and HTTP 80 traffic from any IP"

  ingress {
      from_port = 22
      to_port = 22
      protocol = "tcp"
      cidr_blocks = ["0.0.0.0/0"]
  }
  ingress {
      from_port = 80
      to_port = 80
      protocol = "tcp"
      cidr_blocks = ["0.0.0.0/0"]
  }
  ingress {
      from_port = 8080
      to_port = 8080
      protocol = "tcp"
      cidr_blocks = ["0.0.0.0/0"]
  }
  ingress {
      from_port = 9200
      to_port = 9200
      protocol = "tcp"
      cidr_blocks = ["0.0.0.0/0"]
  }
  ingress {
      from_port = 5050
      to_port = 5050
      protocol = "tcp"
      cidr_blocks = ["0.0.0.0/0"]
  }
  ingress {
      from_port = 50070
      to_port = 50070
      protocol = "tcp"
      cidr_blocks = ["0.0.0.0/0"]
  }
  ingress {
      from_port = 4040
      to_port = 4040
      protocol = "tcp"
      cidr_blocks = ["0.0.0.0/0"]
  }
  egress {
      from_port = 0
      to_port = 0
      protocol = "-1"
      cidr_blocks = ["0.0.0.0/0"]
  }

  tags {
    Name = "Allow SSH anf HTTP"
  }
}


resource "aws_ebs_volume" "ephemeral" {
    availability_zone = "us-east-1a"
    size = 20
    tags {
        Name = "ephemeral disk"
    }
}

resource "aws_ebs_volume" "etl" {
    availability_zone = "us-east-1a"
    size = 20
    count = 3
    tags {
        Name = "ephemeral disk"
    }
}

resource "aws_volume_attachment" "ebs_att_comm" {
  device_name = "/dev/xvdb"
  skip_destroy = "true"
  volume_id = "${aws_ebs_volume.ephemeral.id}"
  instance_id = "${aws_instance.deploynode.id}"
}

resource "aws_volume_attachment" "ebs_att_etl" {
  count = 3
  device_name = "/dev/xvdb"
  skip_destroy = "true"
  volume_id = "${element(aws_ebs_volume.etl.*.id, count.index)}"
  instance_id = "${element(aws_instance.etlnode.*.id, count.index)}"
}


#user_data = "#!/bin/bash\nmkdir /data; mount /dev/xvdh /data;"
#availability_zone = "${element(var.azs, count.index)}"


#resource "aws_s3_bucket" "bootstrapbucket" {
#    bucket = "bootstrapbucket"
#}
