resource "aws_cloudformation_stack" "f5-bigip-single-nic-bigiq" {
  name         = "bigip-${var.emailidsan}-${aws_vpc.terraform-vpc.id}"
  capabilities = ["CAPABILITY_IAM"]

  parameters {
    #NETWORKING CONFIGURATION

    Vpc                          = "${aws_vpc.terraform-vpc.id}"
    subnet1Az1                   = "${aws_subnet.public-a.id}"

    #INSTANCE CONFIGURATION

    imageName            = "Best"
    instanceType         = "m4.xlarge"
    managementGuiPort = 8443
    sshKey            = "${var.aws_keypair}"
    restrictedSrcAddress = "0.0.0.0/0"
    restrictedSrcAddressApp = "0.0.0.0/0"
    ntpServer            = "0.pool.ntp.org"
    ntpServer         = "0.pool.ntp.org"
    timezone          = "UTC"

    #BIG-IQ LICENSING CONFIGURATION

    bigIqAddress         = "${var.bigIqLicenseManager}"
    bigIqUsername        = "admin"
    bigIqPasswordS3Arn   = "arn:aws:s3:::f5-public-cloud/passwd"
    bigIqLicensePoolName = "${var.bigIqLicensePoolName}"
    bigIqLicenseSkuKeyword1 = "BT"
    bigIqLicenseUnitOfMeasure = "yearly"

    #TAGS

    application = "f5app"
    environment = "f5env"
    group       = "ltm"
    owner       = "${var.emailid}"
    costcenter  = "f5costcenter"
  }

  #CloudFormation templates triggered from Terraform must be hosted on AWS S3. Experimental hosted in non-canonical S3 bucket.
  template_url = "https://s3.amazonaws.com/f5-public-cloud/f5-existing-stack-bigiq-1nic-bigip_asm_avr_v3.1.0.template"
}
