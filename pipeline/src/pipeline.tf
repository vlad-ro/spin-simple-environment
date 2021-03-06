
resource "aws_codepipeline" "simple_env_pipeline" {
  name     = "simple_env_pipeline"
  role_arn = "${aws_iam_role.simple_env_pipeline_role.arn}"

  artifact_store {
    location = "${aws_s3_bucket.artefact_repository.bucket}"
    type     = "S3"
    # encryption_key {
    #   id   = "${data.aws_kms_alias.s3kmskey.arn}"
    #   type = "KMS"
    # }
  }

  stage {
    name = "Checkout"

    action {
      name             = "Checkout"
      category         = "Source"
      owner            = "AWS"
      provider         = "CodeCommit"
      version          = "1"

      output_artifacts  = [ "simple-env-infra-source" ],

      configuration {
        RepositoryName = "simple-env"
        BranchName     = "master"
      }
    }
  }

  stage {
    name = "Package"

    action {
      name            = "Package"
      category        = "Build"
      owner           = "AWS"
      provider        = "CodeBuild"
      version         = "1"

      input_artifacts = [ "simple-env-infra-source" ]
      output_artifacts  = [ "simple-env-infra-package" ]

      configuration {
        ProjectName = "${aws_codebuild_project.simple-env-packaging-project.name}"
      }
    }
  }

  stage {
    name = "TestApply"

    action {
      name            = "TestApply"
      category        = "Build"
      owner           = "AWS"
      provider        = "CodeBuild"
      version         = "1"

      input_artifacts = [ "simple-env-infra-package" ]
      output_artifacts  = [ "simple-env-testapply-results" ]

      configuration {
        ProjectName = "${aws_codebuild_project.simple-env-testapply-project.name}"
      }
    }
  }

  stage {
    name = "ProdApply"

    action {
      name            = "ProdApply"
      category        = "Build"
      owner           = "AWS"
      provider        = "CodeBuild"
      version         = "1"

      input_artifacts = [ "simple-env-infra-package" ]
      output_artifacts  = [ "simple-env-prodapply-results" ]

      configuration {
        ProjectName = "${aws_codebuild_project.simple-env-prodapply-project.name}"
      }
    }
  }
}
