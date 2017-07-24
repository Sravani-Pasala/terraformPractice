provider "aws" { 
     region = "${var.aws_region}"
}

resource "aws_subnet" "devSubnet" {
     vpc_id = "${var.aws_vpc_id}"
     cidr_block = "${var.aws_cidr_block}"
     
     tags {
          Name = "${var.name}"
     }
}
