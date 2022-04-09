/*

1) For each availability zone, create a route table.
2) For each route table created in step 1, create a default route and point to the NAT gateway.
3) For each availability zone, associate the route table from step 1 to the respective Management subnets.
4) For each availability zone, associate the route table from step 1 to the respective Service subnets.
5) Create a route table with a default route pointing to the VPC's internet gateway
6) For each availability zone, associate the route table from step 1 to the respective Public subnets.

*/

resource "aws_route_table" "deployment" {
  count  = length(var.availability_zones)
  vpc_id = aws_vpc.vpc.id
}

resource "aws_route" "nat-gateway-route" {
  count = length(var.availability_zones)

  route_table_id         = element(aws_route_table.deployment[*].id, count.index)
  nat_gateway_id         = aws_nat_gateway.nat[0].id
  destination_cidr_block = "0.0.0.0/0"
}

resource "aws_route_table_association" "route-management-subnet" {
  count          = length(var.availability_zones)
  subnet_id      = element(aws_subnet.management-subnet[*].id, count.index)
  route_table_id = element(aws_route_table.deployment[*].id, count.index)
}

resource "aws_route_table_association" "route-services-subnet" {
  count          = length(var.availability_zones)
  subnet_id      = element(aws_subnet.services-subnet[*].id, count.index)
  route_table_id = element(aws_route_table.deployment[*].id, count.index)
}

resource "aws_route_table" "public-route-table" {
  vpc_id = aws_vpc.vpc.id

  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.gw.id
  }
}

resource "aws_route_table_association" "route-public-subnet" {
  count          = length(var.availability_zones)
  subnet_id      = element(aws_subnet.public-subnet[*].id, count.index)
  route_table_id = aws_route_table.public-route-table.id
}
