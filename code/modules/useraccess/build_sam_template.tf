data "template_file" "sam_template" {
  template = file("${path.module}/../samTemplate.yml.tpl")
  vars = {
    my_lambdarole = aws_iam_role.lambda.arn
    my_app_name   = var.app_name

  }
}

resource "local_file" "sam_template" {
  filename = "${path.module}/../samTemplate.yml"
  content  = data.template_file.sam_template.rendered
}
