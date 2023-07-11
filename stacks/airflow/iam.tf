data "aws_partition" "current" {}

data "aws_region" "current" {}

data "aws_caller_identity" "current" {}

resource "aws_iam_policy" "airflow_iam_policy" {
  name        = "${var.environment}-sdp-airflow-policy"
  description = "access to Airflow permissions"
  path        = "/"

  policy = jsonencode({
    "Version" : "2012-10-17",
    "Statement" : [
      {
        "Effect" : "Allow",
        "Action" : "airflow:PublishMetrics",
        "Resource" : "arn:aws:airflow:${data.aws_region.current.name}:${data.aws_caller_identity.current.account_id}:environment/${var.environment}-sdp-airflow"
      },
      {
        "Effect" : "Deny",
        "Action" : "s3:ListAllMyBuckets",
        "Resource" : [
          "arn:aws:s3:::${aws_s3_bucket.airflow_bucket.id}",
          "arn:aws:s3:::${aws_s3_bucket.airflow_bucket.id}/*"
        ]
      },
      {
        "Effect" : "Allow",
        "Action" : [
          "s3:GetObject*",
          "s3:GetBucket*",
          "s3:List*"
        ],
        "Resource" : [
          "arn:aws:s3:::${aws_s3_bucket.airflow_bucket.id}",
          "arn:aws:s3:::${aws_s3_bucket.airflow_bucket.id}/*"
        ]
      },
      {
        "Effect" : "Allow",
        "Action" : [
          "logs:CreateLogStream",
          "logs:CreateLogGroup",
          "logs:PutLogEvents",
          "logs:GetLogEvents",
          "logs:GetLogRecord",
          "logs:GetLogGroupFields",
          "logs:GetQueryResults"
        ],
        "Resource" : [
          "arn:aws:logs:${data.aws_region.current.name}:${data.aws_caller_identity.current.account_id}:log-group:airflow-${var.environment}-sdp-airflow-*"
        ]
      },
      {
        "Effect" : "Allow",
        "Action" : [
          "logs:DescribeLogGroups"
        ],
        "Resource" : [
          "*"
        ]
      },
      {
        "Effect" : "Allow",
        "Action" : "cloudwatch:PutMetricData",
        "Resource" : "*"
      },
      {
        "Effect" : "Allow",
        "Action" : [
          "sqs:ChangeMessageVisibility",
          "sqs:DeleteMessage",
          "sqs:GetQueueAttributes",
          "sqs:GetQueueUrl",
          "sqs:ReceiveMessage",
          "sqs:SendMessage"
        ],
        "Resource" : "arn:aws:sqs:${data.aws_region.current.name}:*:airflow-celery-*"
      },
      {
        "Effect" : "Allow",
        "Action" : [
          "kms:Decrypt",
          "kms:DescribeKey",
          "kms:GenerateDataKey*",
          "kms:Encrypt"
        ],
        "NotResource" : "arn:aws:kms:*:${data.aws_caller_identity.current.account_id}:key/*",
        "Condition" : {
          "StringLike" : {
            "kms:ViaService" : [
              "sqs.${data.aws_region.current.name}.amazonaws.com"
            ]
          }
        }
      }
    ]
  })
}

resource "aws_iam_role" "airflow_iam_role" {
  name        = "${var.environment}-sdp-airflow-role"
  description = "role to attach with airflow"

  assume_role_policy = jsonencode({
    "Version" : "2012-10-17",
    "Statement" : [
      {
        "Effect" : "Allow",
        "Principal" : {
          "Service" : [
            "airflow.amazonaws.com",
            "airflow-env.amazonaws.com"
          ]
        },
        "Action" : "sts:AssumeRole"
      }
    ]
  })
}

resource "aws_iam_role_policy_attachment" "airflow_iam_attachment" {
  role       = aws_iam_role.airflow_iam_role.name
  policy_arn = aws_iam_policy.airflow_iam_policy.arn
}