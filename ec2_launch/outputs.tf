output "privateips" {
    value = "${join(",", aws_instance.deploynode.public_ip,aws_instance.etlnode.*.private_ip)}"
}
