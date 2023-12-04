resource "aws_iam_policy" "SegCOPS_boundary" {
  name        = "SecurityBoundaryPolicySegCOPS"
  description = "Security Boundary Policy SegCOPS"
  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Action = [
          "securityhub:*",
          "shield:*",
          "network-firewall:*",
          "kms:*",
          "waf:*",
          "guardduty:*",
          "fms:*"
        ]
        Effect   = "Allow"
        Resource = "*"
      },
    ]
  })
}
