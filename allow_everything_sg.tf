
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