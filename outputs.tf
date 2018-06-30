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
