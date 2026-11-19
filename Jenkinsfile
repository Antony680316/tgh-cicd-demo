// The pipeline logic lives in the internally reviewed shared library
// (tgh-cicd-pipeline-lib). Changes to this file require CODEOWNERS review.
@Library('tgh-cicd') _

tghDockerPipeline(
    appName:    'tgh-cicd-demo',
    appPort:    8080,
    healthPath: '/health',
    composeFile: 'deploy/compose.yaml'
)
