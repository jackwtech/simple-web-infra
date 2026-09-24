output "vpc_id" {
  value = aws_vpc.this.id
}

output "public_subnet_ids" {
  value = [for az in var.availability_zones : aws_subnet.public[az].id]

  depends_on = [aws_route.internet, aws_route_table_association.public]
}

