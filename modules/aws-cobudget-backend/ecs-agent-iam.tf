data "aws_iam_policy_document" "ecs_ec2_assume_role" {
  statement {
    actions = ["sts:AssumeRole"]

    principals {
      type        = "Service"
      identifiers = ["ec2.amazonaws.com"]
    }
  }
}

resource "aws_iam_role" "cobudget_ecs_agent" {
  name               = "cobudget-ecs-agent"
  assume_role_policy = data.aws_iam_policy_document.ecs_ec2_assume_role.json
}

resource "aws_iam_role_policy_attachment" "cobudget_ecs_agent" {
  role       = aws_iam_role.cobudget_ecs_agent.name
  policy_arn = "arn:aws:iam::aws:policy/service-role/AmazonEC2ContainerServiceforEC2Role"
}
