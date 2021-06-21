# ELB Module
# Davy Jones
# Cloudreach

resource "aws_acm_certificate" "default" {
  domain_name = "${var.domain_name}"
  subject_alternative_names = ["*.${var.domain_name}"]
  validation_method = "DNS"

  lifecycle {
    create_before_destroy = true
  }
}

resource "aws_route53_record" "validation" {
  count =  2
  zone_id = var.zone_id
  name = element(aws_acm_certificate.default.domain_validation_options.*.resource_record_name, count.index)
  type    = element(aws_acm_certificate.default.domain_validation_options.*.resource_record_type, count.index)
  records = [element(aws_acm_certificate.default.domain_validation_options.*.resource_record_value, count.index)] 
  ttl = "300"
}

resource "aws_acm_certificate_validation" "default" {
    certificate_arn = "${aws_acm_certificate.default.arn}"
    validation_record_fqdns = aws_route53_record.validation.*.fqdn
}

#--------- CREATE WEB ELB SECURITY GROUP ---------#
resource "aws_security_group" "web_elb" {
  name        = "${var.prefix}-${var.env}-${var.layer}-elb-sg"
  vpc_id      = "${var.vpc_id}"
  description = "Web ELB Security Group"


  ingress {
    from_port   = 443
    to_port     = 443
    protocol    = "tcp"
    cidr_blocks = ["${var.ingress_cidr}"]
  }

  ingress {
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    cidr_blocks = ["${var.ingress_cidr}"]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
}

#---------- ACCESS LOGS S3 BUCKET ----------#
resource "aws_s3_bucket" "elb_access_logs" {
  bucket = "${var.prefix}-${var.env}-${var.layer}-elb-access-logs"

  policy = <<EOF
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Effect": "Allow",
      "Principal": {
        "AWS": "arn:aws:iam::156460612806:root"
      },
      "Action": "s3:PutObject",
      "Resource": "arn:aws:s3:::${var.prefix}-${var.env}-${var.layer}-elb-access-logs/*"
    }
  ]
}
EOF


  # lifecycle {
  #   prevent_destroy = true
  # }
}

#--------- ELB ---------#
resource "aws_elb" "elb" {
  name            = "${var.prefix}-${var.env}-${var.layer}-elb"
  subnets         = ["${var.subnets}"]
  security_groups = ["${aws_security_group.web_elb.id}"]
  internal        = "${var.internal}"

  access_logs {
    bucket        = "${aws_s3_bucket.elb_access_logs.bucket}"
    bucket_prefix = "${var.prefix}-${var.env}-${var.layer}-elb"
    interval      = 60
  }

  listener {
    instance_port      = 80
    instance_protocol  = "http"
    lb_port            = 443
    lb_protocol        = "https"
    ssl_certificate_id = "${aws_acm_certificate.default.arn}"
  }

  listener {
    instance_port     = 80
    instance_protocol = "http"
    lb_port           = 80
    lb_protocol       = "http"
  }

  health_check {
    healthy_threshold   = 2
    unhealthy_threshold = 3
    timeout             = 5
    target              = "HTTP:80/status"
    interval            = 10
  }

  connection_draining         = true
  connection_draining_timeout = 250

}
