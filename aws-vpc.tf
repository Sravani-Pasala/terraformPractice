
provider "aws" {
	region = "${var.aws_region}"
}

data "aws_caller_identity" "current" {}

resource "aws_vpc" "devVpc" {
	cidr_block = "${var.aws_dev_vpc_cidr_block}"

	tags {
		Name = "${var.aws_dev_vpc_name}"
	}
}

resource "aws_internet_gateway" "devVpcGateway" {
	vpc_id = "${aws_vpc.devVpc.id}"
}

resource "aws_vpc_peering_connection" "default2dev" {
	peer_owner_id = "${data.aws_caller_identity.current.account_id}"
	peer_vpc_id = "${aws_vpc.devVpc.id}"
	vpc_id = "${var.aws_vpc_id}"
	auto_accept = true
}

resource "aws_route" "defaultToDev" {
	route_table_id = "${var.aws_vpc_route_table_id}"
	destination_cidr_block = "${aws_vpc.devVpc.cidr_block}"
	vpc_peering_connection_id = "${aws_vpc_peering_connection.default2dev.id}"
}

resource "aws_route" "devToDefault" {
        route_table_id = "${aws_vpc.devVpc.main_route_table_id}"
        destination_cidr_block = "${var.aws_vpc_cidr_block}"
        vpc_peering_connection_id = "${aws_vpc_peering_connection.default2dev.id}"
}

resource "aws_security_group" "devSecurityGroup" {
	name = "devSecurityGroup"
	description = "Security Group for dev VPC"
	
	ingress {
		from_port = 22
		to_port = 22
		protocol = "tcp"
		cidr_blocks = ["${var.aws_vpc_cidr_block}"]
	}

	vpc_id = "${aws_vpc.devVpc.id}"

}

resource "aws_subnet" "subnetPrivate" {
	vpc_id = "${aws_vpc.devVpc.id}"
	cidr_block = "${var.aws_private_cidr_block}"

	tags {
		Name = "${var.aws_subnet_private_name}"
	}
} 

resource "aws_subnet" "subnetProtected" {
        vpc_id = "${aws_vpc.devVpc.id}"
        cidr_block = "${var.aws_protected_cidr_block}"

        tags {
                Name = "${var.aws_subnet_protected_name}"
        }
}

resource "aws_subnet" "subnetPublic" {
        vpc_id = "${aws_vpc.devVpc.id}"
        cidr_block = "${var.aws_public_cidr_block}"

        tags {
                Name = "${var.aws_subnet_public_name}"
        }
}

resource "aws_instance" "privateVM" {
	ami = "${var.aws_ami}"
	instance_type = "${var.aws_instance_type}"
	key_name = "${var.aws_key_name}"
	subnet_id = "${aws_subnet.subnetPrivate.id}"
	associate_public_ip_address = true
	security_groups = ["${aws_security_group.devSecurityGroup.id}"]
	tags {
		Name = "${var.aws_private_instance_name}"
		Description = "VM 1"
	}
}

resource "aws_instance" "protectedVM" {
        ami = "${var.aws_ami}"
        instance_type = "${var.aws_instance_type}"
        key_name = "${var.aws_key_name}"
        subnet_id = "${aws_subnet.subnetProtected.id}"
        associate_public_ip_address = true
        security_groups = ["${aws_security_group.devSecurityGroup.id}"]
        tags {
                Name = "${var.aws_protected_instance_name}"
                Description = "VM 2"
        }
}

resource "aws_instance" "publicVM" {
        ami = "${var.aws_ami}"
        instance_type = "${var.aws_instance_type}"
        key_name = "${var.aws_key_name}"
        subnet_id = "${aws_subnet.subnetPublic.id}"
        associate_public_ip_address = true
        security_groups = ["${aws_security_group.devSecurityGroup.id}"]
        tags {
                Name = "${var.aws_public_instance_name}"
                Description = "VM 3"
        }
}

output "privateVMip" {
	value = "${aws_instance.privateVM.private_ip}"
}

output "protectedVMip" {
        value = "${aws_instance.protectedVM.private_ip}"
}

output "publicVMip" {
        value = "${aws_instance.publicVM.private_ip}"
}

