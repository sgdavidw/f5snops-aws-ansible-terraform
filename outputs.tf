output "bigIqLicenseManager" {
  value = "${var.bigIqLicenseManager}"
}

output "alb_dns_name" {
  value = "${aws_lb.front_end.dns_name}"
}

output "vpc-id" {
  value = "${aws_vpc.terraform-vpc.id}"
}

output "sshKey" {
  value = "${var.aws_keypair}"
}

output ssl_certificate_id {
  value = "${aws_iam_server_certificate.elb_cert.arn}"
}

output "**aws_alias**" {
  value = "${var.aws_alias}"
}

output "cloudformation_outputs" {
  value = "${aws_cloudformation_stack.f5-bigip-single-nic-bigiq.outputs}"
}

output "web-server-1" {
  value = "${aws_instance.example-a.private_ip}"
}

output "web-server-2" {
  value = "${aws_instance.example-b.private_ip}"
}

output "asg-lb" {
  value = "${aws_elb.asg-lb.name}"
}

output "vpn-gw" {
  value = "${aws_vpn_gateway.vpn_gw.id}"
}