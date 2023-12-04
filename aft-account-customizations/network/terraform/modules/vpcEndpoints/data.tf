data "aws_iam_policy_document" "this" {
  statement {
    actions = [
      "logs:CreateLogStream",
      "logs:PutLogEvents",
    ]

    resources = ["arn:aws:logs:*:*:log-group:/aws/route53/*"]

    principals {
      identifiers = ["route53.amazonaws.com"]
      type        = "Service"
    }
  }
}

data "aws_region" "hosted_zone_region" {}

data "aws_vpc_endpoint_service" "interfaces" {
  for_each = var.endpoints
  service      = lookup(each.value, "service", null )
  service_type = lookup(each.value, "service_type", null)
}