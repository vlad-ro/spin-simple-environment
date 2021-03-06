
resource "aws_codebuild_project" "simple-env-prodapply-project" {
  name         = "SimpleEnv_ProdApply_Project"
  description  = "CodeBuild project to apply terraform to the simple-env production instance"
  build_timeout      = "10"
  service_role = "${aws_iam_role.simple_env_terraform_codebuild_role.arn}"

  environment {
    compute_type = "BUILD_GENERAL1_SMALL"
    image        = "aws/codebuild/ruby:2.3.1"
    type         = "LINUX_CONTAINER"

    environment_variable {
      "name"  = "ENV"
      "value" = "prod"
    }

  }

  source {
    type = "CODEPIPELINE"
    buildspec = "buildspec_apply.yml"
  }

  artifacts {
    type = "CODEPIPELINE"
  }
}

