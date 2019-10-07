resource "aws_elb" "f5-autoscale-waf-elb" {
  name = "waf-${var.emailidsan}"

  cross_zone_load_balancing = true
  security_groups           = ["${aws_security_group.elb.id}"]
  subnets                   = ["${aws_subnet.public-a.id}", "${aws_subnet.public-b.id}"]

  listener {
    lb_port            = 443
    lb_protocol        = "https"
    instance_port      = "${var.server_port}"
    instance_protocol  = "http"
    ssl_certificate_id = "${aws_iam_server_certificate.elb_cert.arn}"
  }
}

resource "aws_cloudformation_stack" "f5-autoscale-waf" {
  name         = "waf-${var.emailidsan}-${aws_vpc.terraform-vpc.id}"
  capabilities = ["CAPABILITY_IAM"]

  provisioner "local-exec" {
    when    = "destroy"
    command = "lab-cleanup"
  }
  
  parameters {
    #DEPLOYMENT
    deploymentName           = "waf-${var.emailidsan}"
    Vpc                      = "${aws_vpc.terraform-vpc.id}"
    availabilityZones        = "${var.aws_region}a,${var.aws_region}b"
    subnets                  = "${aws_subnet.public-a.id},${aws_subnet.public-b.id}"
    bigipElasticLoadBalancer = "${aws_elb.f5-autoscale-waf-elb.name}"

    #INSTANCE CONFIGURATION
    sshKey            = "${var.aws_keypair}"
    throughput        = "25Mbps"
    instanceType      = "m5.xlarge"
    bigIpModules      = "ltm:nominal,asm:nominal"
    imageName	      = "AdvancedWaf"
    adminUsername     = "admin"
    managementGuiPort = 8443
    timezone          = "UTC"
    ntpServer         = "0.pool.ntp.org"
    restrictedSrcAddress = "0.0.0.0/0"
    restrictedSrcAddressApp	= "0.0.0.0/0"

    #AUTO SCALING CONFIGURATION
    scalingMinSize          = "1"
    scalingMaxSize          = "2"
    scaleDownBytesThreshold = 10000
    scaleUpBytesThreshold   = 35000
    notificationEmail       = "${var.waf_emailid != "" ? var.waf_emailid : var.emailid}"

    #WAF VIRTUAL SERVICE CONFIGURATION
    virtualServicePort      = "${var.server_port}"
    applicationPort         = "${var.server_port}"
    applicationPoolTagKey   = "findme"
    applicationPoolTagValue = "web"
    policyLevel             = "low"

    #TAGS
    application = "f5app"
    environment = "f5env"
    group       = "f5group"
    owner       = "f5owner"
    costcenter  = "f5costcenter"
  }

  #CloudFormation templates triggered from Terraform must be hosted on AWS S3.
  #template_url = "https://s3.amazonaws.com/f5-public-cloud/f5-hourly-autoscale-bigip-waf_v3.1.0.template"
  template_url = "https://s3.amazonaws.com/f5-cft/f5-payg-autoscale-bigip-waf.template"
}
