/*

1) Create 1 internet gateway
2) Create 3 Elastic IPs
3) 3 NAT Gateways (1 in each availability zone) and associate Elastic IPs to them

*/


resource "aws_internet_gateway" "gw" {
  vpc_id = aws_vpc.vpc.id
}

resource "aws_eip" "nat" {
  count = length(var.availability_zones)

  vpc = true

  tags = merge(
    var.tags,
    { "Name" = "${var.environment_name}-nat-eip" },
  )
}

resource "aws_nat_gateway" "nat" {
  count = length(var.availability_zones)

  allocation_id = element(aws_eip.nat.*.id, count.index)
  subnet_id     = element(aws_subnet.public-subnet.*.id, count.index)

  tags = merge(
    var.tags,
    { "Name" = "${var.environment_name}-nat-gateway" },
  )

  depends_on = [aws_internet_gateway.gw]
}
