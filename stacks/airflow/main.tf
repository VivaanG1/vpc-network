resource "aws_mwaa_environment" "airflow_instance" {
  dag_s3_path           = "dags/"
  requirements_s3_path  = "requirements/requirements.txt"
  execution_role_arn    = aws_iam_role.airflow_iam_role.arn
  name                  = "${var.environment}-sdp-airflow"
  webserver_access_mode = "PUBLIC_ONLY"

  network_configuration {
    security_group_ids = [aws_security_group.airflow_sg.id]
    subnet_ids         = var.private_subnet_ids
  }

  source_bucket_arn = aws_s3_bucket.airflow_bucket.arn
  depends_on        = [aws_iam_role_policy_attachment.airflow_iam_attachment]
}