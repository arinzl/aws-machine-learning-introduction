data "template_file" "buildspec" {
  template = file("${path.module}/../buildspec.yml.tpl")
  vars = {
    s3bucket = module.artifact_bucket.s3_bucket_id
  }
}

resource "local_file" "buildspec" {
  filename = "${path.module}/../buildspec.yml"
  content  = data.template_file.buildspec.rendered
}
