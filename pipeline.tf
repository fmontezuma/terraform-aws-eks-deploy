resource "aws_s3_bucket" "codepipeline_bucket" {
  bucket = "${format("%.63s", "${data.aws_caller_identity.current.account_id}-k8s-pipeline-${var.env}")}"
  acl    = "private"
}

resource "aws_codepipeline" "codepipeline" {
  name     = "k8s-deploy-${var.env}"
  role_arn = "${var.codepipeline_role_arn}"

  artifact_store {
    location = "${aws_s3_bucket.codepipeline_bucket.bucket}"
    type     = "S3"
  }

  stage {
    name = "Source"

    action {
      name             = "Source"
      category         = "Source"
      owner            = "AWS"
      provider         = "CodeCommit"
      version          = "1"
      output_artifacts = ["source_output"]

      configuration = {
        RepositoryName = "k8s-deploy"
        BranchName = "${var.env}"
      }
    }
  }

  stage {
    name = "DeployToKubernetes"

    action {
      name             = "DeployToKubernetes"
      category         = "Build"
      owner            = "AWS"
      provider         = "CodeBuild"
      input_artifacts  = ["source_output"]
      version          = "1"

      configuration = {
        ProjectName = "${aws_codebuild_project.deploy.name}"
      }
    }
  }
}
