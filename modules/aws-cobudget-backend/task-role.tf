data "aws_iam_policy_document" "cobudget_task_assume_policy" {
  statement {
    actions = ["sts:AssumeRole"]

    principals {
      type        = "Service"
      identifiers = ["ecs-tasks.amazonaws.com"]
    }
  }
}

resource "aws_iam_role" "cobudget_task_role" {
  name               = "cobudget-task-role"
  assume_role_policy = data.aws_iam_policy_document.cobudget_task_assume_policy.json
}

data "aws_iam_policy_document" "cobudget_task_policy" {
  statement {
    actions   = ["s3:ListBucket"]
    resources = [
      aws_s3_bucket.cobudget.arn
    ]
  }

  statement {
    actions = [
      "s3:PutObject",
      "s3:GetObject",
      "s3:DeleteObject"
    ]
    resources = [
      "${aws_s3_bucket.cobudget.arn}/*"
    ]
  }
}

resource "aws_iam_policy" "cobudget_task_policy" {
  name        = "cobudget_task_policy"
  description = "Policy with permissions required by CoBudget app"
  policy      = data.aws_iam_policy_document.cobudget_task_policy.json
}

resource "aws_iam_role_policy_attachment" "cobudget_task_policy" {
  role       = aws_iam_role.cobudget_task_role.name
  policy_arn = aws_iam_policy.cobudget_task_policy.arn
}
