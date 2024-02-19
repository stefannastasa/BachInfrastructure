variable "access_key" {
  description = "AWS access key ID"
}

variable "secret_key" {
  description = "AWS secret access key"
}

provider "aws" {
	region = "eu-central-1"
	access_key = var.access_key
	secret_key = var.secret_key
}

resource "aws_s3_bucket" "handnotes_bucket" {
	bucket = "handnotes"
}

resource "aws_s3_bucket_cors_configuration" "handnotes_cors_config" {
	bucket = aws_s3_bucket.handnotes_bucket.id

	cors_rule {
		allowed_headers = ["*"]
    		allowed_methods = ["GET"]
    		allowed_origins = ["*"]
    		expose_headers  = ["ETag"]
    		max_age_seconds = 3000	
	}

}

resource "aws_iam_user" "handnotes_user" {
	name 	= "handnotes-user"
}

resource "aws_iam_access_key" "backend_access_key" {
	user = aws_iam_user.handnotes_user.name
}

resource "aws_iam_policy" "backend_ap" {

	name 	= "signed-url-policy"
	policy 	= jsonencode({
		Version 	= "2012-10-17",
		Statement	= [{
			Effect		= "Allow",
			Action		= [
				"s3:GetObject",
				"s3:ListBucket",
				"s3:PutObject"

			],
			Resource = [
				"${aws_s3_bucket.handnotes_bucket.arn}/*"
			]
		}]
	})
}

resource "aws_iam_user_policy_attachment" "upload_download_attachment" {
	user 		= aws_iam_user.handnotes_user.name
	policy_arn 	= aws_iam_policy.backend_ap.arn 
}
