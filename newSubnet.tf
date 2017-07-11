provider "aws" { 
     region = "${var.aws_region}"
     shared_credentials_file = "${var.aws_creds_file}"
}

resource "aws_subnet" "testingSubnet" {
     vpc_id = "${var.aws_vpc_id}"
     cidr_block = "${var.aws_cidr_block}"
     
     tags {
          Name = "${var.name}"
     }
}
