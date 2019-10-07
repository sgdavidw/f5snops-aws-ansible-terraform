/*
variable "web_server_ami" {
  description = "web server ami is region specific, defaults to us-east-1"
  default     = "ami-40d28157"
  }
*/

variable "web_server_ami" {
  type = map(string)

  default = {
    "us-east-1"      = "ami-a4c7edb2"
    "ap-southeast-1" = "ami-77af2014"
    #"us-west-2"      = "ami-6df1e514"
     "us-west-2"     = "ami-037e684b1e151a1be"
  }
}

variable "aws_region" {
  description = "aws region (default is us-east-1)"
  default     = "us-east-1"
}

variable "bigIqLicenseManager" {
  description = "Management IP address of the BigIQ License Manager"
  default     = "null"
}

variable "bigIqLicensePoolName" {
  description = "BigIQ License Pool name"
  default     = "BigIQLicensePool"
}

variable "server_port" {
  description = "The port the server will use for HTTP requests"
  default     = 80
}

variable "server_ssl_port" {
  description = "The port the server will use for HTTPS requests"
  default     = 443
}

variable "aws_keypair" {
  description = "The name of an existing key pair. In AWS Console: NETWORK & SECURITY -> Key Pairs"
}

variable "emailid" {
  description = "emailid"
}

variable "waf_emailid" {
  description = "waf email notification"
  default     = ""
}

variable "emailidsan" {
  description = "emailidsan"
}

variable "restrictedSrcAddress" {
  type        = list(string)
  description = "Lock down management access by source IP address or network"
  default     = ["0.0.0.0/0", "10.0.0.0/16"]
}

variable "aws_alias" {
  description = "Link alias to AWS Console"
}

