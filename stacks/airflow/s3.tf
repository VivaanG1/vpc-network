resource "aws_s3_bucket" "airflow_bucket" {
  bucket = "${var.environment}-sdp-airflow-dags"
}

resource "aws_s3_bucket_versioning" "airflow_bucket" {
  bucket = aws_s3_bucket.airflow_bucket.id
  versioning_configuration {
    status = "Enabled"
  }
}

resource "aws_s3_object" "dag_folder" {
  bucket = aws_s3_bucket.airflow_bucket.id
  key    = "dags/"
}