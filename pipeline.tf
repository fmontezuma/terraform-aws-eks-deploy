resource "aws_codepipeline" "codepipeline" {
  name     = "${var.project_name}-k8s-deploy-${var.env}"
  role_arn = "${var.codepipeline_role_arn}"

  artifact_store {
    location = "${var.pipeline_s3_bucket}"
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
        RepositoryName = "${var.project_name}-k8s-deploy"
        BranchName = "${var.env}"
        PollForSourceChanges = false
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
