version: 0.1
phases:
  build:
    commands:
      - echo Build started on `date`
      - aws cloudformation package --template-file samTemplate.yml --s3-bucket ${s3bucket} --output-template-file outputSamTemplate.yml
  post_build:
    commands:
      - echo Build completed on `date`
artifacts:
  files:
    - outputSamTemplate.yml