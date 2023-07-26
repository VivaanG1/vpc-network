data "aws_partition" "current" {}

data "aws_region" "current" {}

data "aws_caller_identity" "current" {}

data "aws_iam_policy_document" "airflow_iam_policy" {
  version = "2012-10-17"

  statement {
    actions   = ["airflow:PublishMetrics"]
    resources = ["arn:aws:airflow:${data.aws_region.current.name}:${data.aws_caller_identity.current.account_id}:environment/${var.environment}-sdp-airflow"]
    effect    = "Allow"
  }

  statement {
    actions   = ["s3:ListAllMyBuckets"]
    resources = [
      "arn:aws:s3:::${aws_s3_bucket.airflow_bucket.id}",
      "arn:aws:s3:::${aws_s3_bucket.airflow_bucket.id}/*",
    ]
    effect = "Deny"
  }

  statement {
    actions = [
      "s3:GetObject*",
      "s3:GetBucket*",
      "s3:List*",
    ]
    resources = [
      "arn:aws:s3:::${aws_s3_bucket.airflow_bucket.id}",
      "arn:aws:s3:::${aws_s3_bucket.airflow_bucket.id}/*",
    ]
    effect = "Allow"
  }

  statement {
    actions = [
      "logs:CreateLogStream",
      "logs:CreateLogGroup",
      "logs:PutLogEvents",
      "logs:GetLogEvents",
      "logs:GetLogRecord",
      "logs:GetLogGroupFields",
      "logs:GetQueryResults",
    ]
    resources = [
      "arn:aws:logs:${data.aws_region.current.name}:${data.aws_caller_identity.current.account_id}:log-group:airflow-${var.environment}-sdp-airflow-*",
    ]
    effect = "Allow"
  }

  statement {
    actions   = ["logs:DescribeLogGroups"]
    resources = ["*"]
    effect    = "Allow"
  }

  statement {
    actions   = ["cloudwatch:PutMetricData"]
    resources = ["*"]
    effect    = "Allow"
  }

  statement {
    actions   = ["sqs:ChangeMessageVisibility", "sqs:DeleteMessage", "sqs:GetQueueAttributes", "sqs:GetQueueUrl", "sqs:ReceiveMessage", "sqs:SendMessage"]
    resources = ["arn:aws:sqs:${data.aws_region.current.name}:*:airflow-celery-*"]
    effect    = "Allow"
  }

  statement {
    actions = ["kms:Decrypt", "kms:DescribeKey", "kms:GenerateDataKey*", "kms:Encrypt"]
    not_resources = ["arn:aws:kms:*:${data.aws_caller_identity.current.account_id}:key/*"]
    effect = "Allow"

    condition {
      test     = "StringLike"
      variable = "kms:ViaService"

      values = ["sqs.${data.aws_region.current.name}.amazonaws.com"]
    }
  }
}

data "aws_iam_policy_document" "airflow_assume_role_policy" {
  version = "2012-10-17"

  statement {
    actions = ["sts:AssumeRole"]
    effect  = "Allow"
    principals {
      type        = "Service"
      identifiers = ["airflow.amazonaws.com", "airflow-env.amazonaws.com"]
    }
  }
}

resource "aws_iam_policy" "airflow_iam_policy" {
  name        = "${var.environment}-sdp-airflow-policy"
  description = "access to Airflow permissions"
  path        = "/"
  policy      = data.aws_iam_policy_document.airflow_iam_policy.json
}

resource "aws_iam_role" "airflow_iam_role" {
  name        = "${var.environment}-sdp-airflow-role"
  description = "role to attach with airflow"

  assume_role_policy = data.aws_iam_policy_document.airflow_assume_role_policy.json
}

resource "aws_iam_role_policy_attachment" "airflow_iam_attachment" {
  role       = aws_iam_role.airflow_iam_role.name
  policy_arn = aws_iam_policy.airflow_iam_policy.arn
}