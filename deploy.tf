data "aws_caller_identity" "current" {}
data "aws_region" "current" {}

resource "aws_codebuild_project" "deploy" {
  name          = "k8s-deploy-${var.env}"
  description   = "Deploy process for k8s-deploy"
  service_role  = "${var.codebuild_deploy_role_arn}"

  artifacts {
    type = "NO_ARTIFACTS"
  }

  environment {
    compute_type                = "BUILD_GENERAL1_SMALL"
    image                       = "aws/codebuild/standard:2.0-1.10.0"
    type                        = "LINUX_CONTAINER"
    image_pull_credentials_type = "CODEBUILD"
    privileged_mode = "true"
  }

  source {
    type            = "CODECOMMIT"
    location        = "https://git-codecommit.${data.aws_region.current.name}.amazonaws.com/v1/repos/k8s-deploy"
    git_clone_depth = 1
    buildspec = templatefile("${path.module}/deploy-buildspec.json.tpl", {account_id = "${data.aws_caller_identity.current.account_id}", region = "${data.aws_region.current.name}", eks_cluster_name = "${var.eks_cluster_name}" })
  }
}
