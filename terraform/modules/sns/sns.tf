# SNS Module
# Davy Jones
# Cloudreach

#---------- CREATE SNS TOPIC ----------#
resource "aws_sns_topic" "env" {
  name = "${var.prefix}-${var.env}-topic"
}

#---------- CREATE SNS SUBSCRIPTION ----------#
resource "aws_cloudformation_stack" "sns_email_sub" {
  name = "${var.prefix}-${var.env}-sns-email-subscription"

  template_body = <<STACK
{
  "AWSTemplateFormatVersion": "2010-09-09",
  "Resources": {
    "SNSEmailSubscription" : {
      "Type" : "AWS::SNS::Subscription",
      "Properties" : {
        "Endpoint" : "${var.email}",
        "Protocol" : "email",
        "TopicArn" : "${aws_sns_topic.env.arn}"
      }
    }
  }
}
STACK

}
