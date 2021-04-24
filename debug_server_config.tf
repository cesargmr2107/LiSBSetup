
/* VPN SERVER INSTANCE CONFIGURATION FILE */

/*SpamFilter SMTP server instance */
resource "aws_instance" "RemoteSMTPServer" {
  
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
        command = "sleep 5; ANSIBLE_HOST_KEY_CHECKING=False ansible-playbook -i '${self.public_ip},' -u admin --private-key keys/id_rsa ansible_debug_setup.yml"
    }
    
    tags = {
        Name = "RemoteSMTPServer"
    }
}

