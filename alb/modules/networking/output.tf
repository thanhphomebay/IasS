/* using the output as an input for another module */
output "vpc_id" {
  value = "${aws_vpc.vpc.id}"
}
 output "public_subnet" {
  value = "${aws_subnet.public_subnet.*.id}"
 }
 output "private_subnet" {
  value = "${aws_subnet.private_subnet.*.id}"
 }
