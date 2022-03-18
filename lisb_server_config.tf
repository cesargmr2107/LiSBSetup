
/* VPN SERVER INSTANCE CONFIGURATION FILE */

/*LiSB SMTP server instance */
resource "aws_instance" "LiSBServer" {
  
    // Server AMI
	ami           = var.instance_ami

    // Instance type chosen by user
    instance_type = var.instance_type

    // Subnet of user's VPC
    subnet_id = var.subnet_id

    // Assigning key pair
    key_name = aws_key_pair.key_pair.key_name

    // Turning off source and destination check 
    source_dest_check = false

    // Assigning default VPN server's security group 
    vpc_security_group_ids = [
        aws_security_group.allow_everything.id
    ]

    // S3 full access profile
    iam_instance_profile = "${aws_iam_instance_profile.EC2FullS3AccessProfile.name}"

    // Provisioners for Ansible configuration

    provisioner "remote-exec" {
    	inline = [":"]		
		connection {
			host = "${self.public_ip}"
			type        = "ssh"
			user        = "admin"
			private_key = "${file("keys/id_rsa")}"
		}
    }

    provisioner "local-exec" {
        command = "ANSIBLE_HOST_KEY_CHECKING=False ansible-playbook -i '${self.public_ip},' -u admin --private-key keys/id_rsa provisioning-setup/ansible_server_setup.yml --extra-vars='domain=${self.public_dns}'"
    }
    
    tags = {
        Name = "LiSBServer",
        Snapshot = "true"
    }
}

/* IAM ROLE, POLICY AND PROFILE THAT ALLOW S3 FULL ACCESS */

resource "aws_iam_role" "EC2FullS3AccessRole" {
    name = "EC2FullS3AccessRole"

    assume_role_policy = jsonencode({
        "Version": "2012-10-17",
        "Statement": [
            {
                "Action": "sts:AssumeRole",
                "Principal": {
                    "Service": "ec2.amazonaws.com"
                },
                "Effect": "Allow",
                "Sid": ""
            }
        ]
    })
}

resource "aws_iam_role_policy" "EC2FullS3AccessPolicy" {
  name = "EC2FullS3AccessPolicy"
  role = "${aws_iam_role.EC2FullS3AccessRole.id}"

  policy = jsonencode({
    "Version": "2012-10-17",
    "Statement": [
        {
        "Action": [
            "s3:*"
        ],
        "Effect": "Allow",
        "Resource": "*"
        }
    ]
  })

}

resource "aws_iam_instance_profile" "EC2FullS3AccessProfile" {
  name = "EC2FullS3AccessProfile"
  role = "${aws_iam_role.EC2FullS3AccessRole.name}"
}
