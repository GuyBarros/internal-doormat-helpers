locals {
  development_stack_subjects = ["organization:${var.organization_id}:*"]
  jwt_audience               = "terraform-stacks-private-preview"
}

# Terraform Cloud production OpenID provider.
resource "aws_iam_openid_connect_provider" "stacks" {
  url = "https://app.terraform.io"

  client_id_list  = [local.jwt_audience]
  thumbprint_list = ["9E99A48A9960B14926BB7F3B02E22DA2B0AB7280"]
}

# This role is assumed by Terraform Cloud dynamic credentials, accepting any
# stack that matches the subject string in local.development_stack_subjects.
resource "aws_iam_role" "stacks" {
  name = var.role_name
  assume_role_policy = jsonencode({
    "Version" : "2012-10-17",
    "Statement" : [
      {
        "Action" : "sts:AssumeRoleWithWebIdentity",
        "Effect" : "Allow",
        "Principal" : {
          "Federated" = aws_iam_openid_connect_provider.stacks.arn,
        },
        "Condition" : {
          "StringEquals" : {
            "app.terraform.io:aud" : local.jwt_audience,
          },
          "StringLike" : {
            "app.terraform.io:sub" : local.development_stack_subjects,
          },
        },
      },
    ],
  })

  tags = {
    "Source" = "aws-openid-role-for-stacks"
  }
}

# This policy permits the specified allowed actions, always including the
# mandatory action to get the caller identity.
resource "aws_iam_role_policy" "stacks" {
  name = "stacks"
  role = aws_iam_role.stacks.id

  policy = jsonencode({
    "Version" : "2012-10-17",
    "Statement" : [
      {
        "Action" : concat(var.allowed_actions, [
          "sts:GetCallerIdentity",
        ]),
        "Effect" : "Allow",
        "Resource" : "*"
      }
    ]
  })
}

# Emit the role ARN, for use in the stack configuration.
output "role_arn" {
  value = aws_iam_role.stacks.arn
}