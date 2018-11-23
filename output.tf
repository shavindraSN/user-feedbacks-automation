output "rds_endpoint" {
  value = "${aws_db_instance.mysql_db.endpoint}"
}

output "eb_cname" {
  value = "${aws_elastic_beanstalk_environment.userfeedbackenv-app.cname}"
}