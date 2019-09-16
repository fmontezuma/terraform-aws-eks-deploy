resource "aws_cloudwatch_event_rule" "rule" {
  name = "${var.project_name}-k8s-deploy-${var.env}"
  role = "${var.codepipeline_role_arn}"
  event_pattern = <<PATTERN
{
	"source":["aws.codecommit"],
	"detail-type":["CodeCommit Repository State Change"],
	"resources":["${aws_codepipeline.codepipeline.arn}"],
	"detail":{
		"referenceType":["branch"],
		"referenceName":["master"]
	}
}
PATTERN
}

resource "aws_cloudwatch_event_target" "target" {
  rule      = aws_cloudwatch_event_rule.rule.name
  arn       = aws_codepipeline.codepipeline.arn
}
