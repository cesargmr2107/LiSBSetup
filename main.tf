
/* LOGIN TO AWS */
provider "aws"{
    access_key = var.aws_access_key
    secret_key = var.aws_secret_key
    region = var.aws_region
}

/* KEY PAIR WHICH WILL BE ATTACHED TO THE AWS INSTANCES */
resource "aws_key_pair" "key_pair"{
    key_name = "lisb-key-pair"
    public_key = file("keys/id_rsa.pub")
}