output "vpc_id" {
  value = aws_vpc.vpc.id
}
output "igw_id" {
  value = aws_internet_gateway.igw.id
}
output "ngw_id" {
  value = aws_nat_gateway.nat.id
}
output "pubsn1_id" {
  value = aws_subnet.public_subnet1.id
}
output "pubsn2_id" {
  value = aws_subnet.public_subnet2.id
}
output "prvsn1_id" {
  value = aws_subnet.private_subnet1.id
}
output "privsn2_id" {
  value = aws_subnet.private_subnet2.id
}
output "pub-rt_id" {
  value = aws_route_table.pub-rt.id
}
output "prv-rt_id" {
  value = aws_route_table.prv-rt.id
}
output "rta-pub1_id" {
  value = aws_route_table_association.rta-pub1.id
}
output "rta-pub2_id" {
  value = aws_route_table_association.rta-pub2.id
}
output "rta-prv1_id" {
  value = aws_route_table_association.rta-prv1
}
output "rta-prv2_id" {
  value = aws_route_table_association.rta-prv2
}

