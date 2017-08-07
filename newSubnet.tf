provider "aws" {
	region = "us-east-1"
}

resource "aws_subnet" "subnetTest" {
	vpc_id = "vpc-2ef74757"
	cidr_block = "172.31.80.0/20"

	tags {
		Name = "aSubnet"
	}
} 

output "subnetID" {
	value = "${aws_subnet.subnetTest.id}"
}
