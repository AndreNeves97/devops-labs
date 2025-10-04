# resource "aws_network_interface" "public_instance" {
#   subnet_id   = element(aws_subnet.public, 0).id
#   private_ips = ["10.0.0.1"]

#   security_groups = [aws_security_group.allow_ssh.id]

#   tags = {
#     Name = "public-instance-network-interface"
#   }
# }

# resource "aws_instance" "public_instance" {
#   ami           = "ami-0b0012dad04fbe3d7"
#   instance_type = "t3.micro"
#   key_name      = "teste"

#   primary_network_interface {
#     network_interface_id = aws_network_interface.public_instance.id
#   }


#   tags = {
#     Name = "public-instance"
#   }
# }
