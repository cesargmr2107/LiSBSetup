
/* VPN SERVER INSTANCE CONFIGURATION FILE */

/*SpamFilter SMTP server instance */
resource "aws_instance" "SpamFilterServer" {
  
    // Debian 10 Buster AMI
    ami           = "ami-04e905a52ec8010b2"

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

    provisioner "local-exec" {
        command = "ANSIBLE_HOST_KEY_CHECKING=False ansible-playbook -i '${self.public_ip},' -u admin --private-key keys/id_rsa ansible_server_setup.yml"
    }
    
    tags = {
        Name = "SpamFilterServer"
    }
}

/* Security group which allows everything into a resource (for testing purposes) */
resource "aws_security_group" "allow_everything" {
  name        = "allow_everything"
  description = "Allows all traffic from anywhere"

  ingress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = [ "0.0.0.0/0" ]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = [ "0.0.0.0/0" ]
  }
}