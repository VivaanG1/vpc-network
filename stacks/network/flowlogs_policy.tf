data "aws_iam_policy_document" "flow_log_assume_role_policy" {
  version = "2012-10-17"

  statement {
    actions = ["sts:AssumeRole"]
    effect  = "Allow"
    principals {
      type        = "Service"
      identifiers = ["vpc-flow-logs.amazonaws.com"]
    }
  }
}

data "aws_iam_policy_document" "cloudwatch_logs_policy" {
  version = "2012-10-17"

  statement {
    actions   = [
      "logs:CreateLogGroup",
      "logs:CreateLogStream",
      "logs:PutLogEvents",
      "logs:DescribeLogGroups",
      "logs:DescribeLogStreams",
    ]
    effect = "Allow"

    resources = [
      "${aws_cloudwatch_log_group.flow_log_group.arn}:*",
    ]
  }
}

resource "aws_iam_role" "flow_log_role" {
  name = "${var.environment}-sdp-flow-log-role"
  assume_role_policy = data.aws_iam_policy_document.flow_log_assume_role_policy.json
}

resource "aws_iam_policy" "cloudwatch_logs_policy" {
  name        = "${var.environment}-sdp-flow-log-policy"
  description = "Provides full access to CloudWatch Logs"
  policy = data.aws_iam_policy_document.cloudwatch_logs_policy.json
}

resource "aws_iam_policy_attachment" "flow_log_policy_attachment" {
  name       = "${var.environment}-sdp-flow-log-policy-attachment"
  roles      = aws_iam_role.flow_log_role.name
  policy_arn = aws_iam_policy.cloudwatch_logs_policy.arn
}