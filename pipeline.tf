variable "environments" {
    type    = "list"
    default = ["dev", "hml", "prod"]
}

resource "aws_s3_bucket" "codepipeline_bucket" {
  count = length(var.environments)
  bucket = "k8s-pipeline-bucket-${var.environments[count.index]}"
  acl    = "private"
}

resource "aws_codepipeline" "codepipeline" {
  count = length(var.environments)
  name     = "k8s-pipeline-${var.environments[count.index]}"
  role_arn = "${var.codepipeline_role_arn}"

  artifact_store {
    location = "${aws_s3_bucket.codepipeline_bucket[count.index].bucket}"
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
        RepositoryName = "k8s-deployment"
        BranchName = "${var.environments[count.index]}"
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
        ProjectName = "${aws_codebuild_project.deploy[count.index].name}"
      }
    }
  }
}
