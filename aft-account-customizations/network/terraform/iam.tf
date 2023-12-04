data "aws_iam_policy_document" "policy" {
  #checkov:skip=CKV_AWS_111: Some RAM resource names are inpredictable. The permission needs to cover 
  #checkov:skip=CKV_AWS_356: Some Describe permissions don't have a specific resource to cover, so the "*" is needed
  version = "2012-10-17"
  statement {
    sid    = "RAMReadWrite"
    effect = "Allow"
    actions = [
      "ram:CreateResourceShare",
      "ram:UpdateResourceShare",
      "ram:TagResource",
      "ram:UntagResource",
      "ram:AssociateResourceShare",
      "ram:DeleteResourceShare",
      "ram:DisassociateResourceShare"
    ]
    resources = ["arn:aws:ram:*:${data.aws_caller_identity.current.account_id}:resource-share/*"]
  }
  statement {
    sid    = "VPCAttachmentReadWrite"
    effect = "Allow"
    actions = [
      "ec2:CreateTransitGatewayVpcAttachment",
      "ec2:DeleteTransitGatewayVpcAttachment",
      "ec2:CreateTags",
      "ec2:DeleteTags"
    ]
    resources = ["arn:aws:ec2:*:${data.aws_caller_identity.current.account_id}:transit-gateway-attachment/*"]
  }
  statement {
    sid    = "PermissionsWithNoResourceSpecification"
    effect = "Allow"
    actions = [
      "ec2:EnableTransitGatewayRouteTablePropagation",
      "ec2:DisableTransitGatewayRouteTablePropagation",
      "ec2:ReplaceRouteTableAssociation",
      "ec2:DisassociateTransitGatewayRouteTable",
      "ec2:AssociateTransitGatewayRouteTable",
      "ec2:GetTransitGatewayRouteTableAssociations",
      "ec2:GetTransitGatewayRouteTablePropagations",
      "ec2:DescribeTransitGateways",
			"ec2:DescribeTransitGatewayRouteTables",
			"ec2:DescribeTags",
      "ec2:DescribeVpcs",
      "route53:ListHostedZones",
      "route53:GetHostedZone",
      "route53:ListResourceRecordSets",
      "route53:ListTagsForResource",
      "route53:AssociateVPCWithHostedZone",
      "route53:CreateVPCAssociationAuthorization",
      "route53:ListVPCAssociationAuthorizations",
      "route53:DeleteVPCAssociationAuthorization",
      "route53resolver:ListResolverRules",
      "route53resolver:ListTagsForResource",
      "route53resolver:ListResolverRuleAssociations",
      "route53resolver:ListResolverEndpoints",
      "route53resolver:ListResolverConfigs",
      "route53resolver:AssociateResolverRule"
    ]
    resources = ["*"]
  }
  statement {
    sid    = "AllowGetParameters"
    effect = "Allow"
    actions = [
      "ssm:GetParameter"
    ]
    resources = ["*"]
  }
}

data "aws_iam_policy_document" "assume_role_policy" {
  version = "2012-10-17"
  statement {
    sid    = "AllowAWSAFTAdmin"
    effect = "Allow"
    principals {
      type        = "AWS"
      identifiers = [
          "arn:aws:sts::{AFT_ACCOUNT_ID}:assumed-role/AWSAFTAdmin/AWSAFT-Session", #CHECK
          "arn:aws:iam::{AFT_ACCOUNT_ID}:role/AWSAFTAdmin"
          ]
    }
    actions = ["sts:AssumeRole"]
    condition {
      test     = "ForAnyValue:StringEquals"
      variable = "aws:PrincipalOrgID"
      values   = ["o-w6ho8nwy30"] #CHECK
    }
  }
}

## CREATE IAM ROLE FOR AFT NETWORK ACCOUNT ##
resource "aws_iam_role" "AFTNetworkRole" {
  name               = "AFTNetworkRole"
  assume_role_policy = data.aws_iam_policy_document.assume_role_policy.json
}

## CREATE IAM ROLE POLICY FOR AFT NETWORK ACCOUNT ##
resource "aws_iam_role_policy" "PermissionsAFTNetwork" {
  name   = "PermissionsAFTNetwork"
  role   = aws_iam_role.AFTNetworkRole.id
  policy = data.aws_iam_policy_document.policy.json
}