AWSTemplateFormatVersion: "2010-09-09"
Transform: AWS::Serverless-2016-10-31
Description: "Simple python lambda function via ci-cd"
Resources:
  MyLambdaFunctoin:
    Type: "AWS::Serverless::Function"
    Properties:
      Handler: myapp.lambda_handler
      Runtime: python3.10
      FunctionName: "${my_app_name}"
      CodeUri: ./appfolder
      MemorySize: 128
      Timeout:    30
      Role:       '${my_lambdarole}'
      Environment:
        Variables:
          ENDPOINT_NAME: "test-for-${my_app_name}"

