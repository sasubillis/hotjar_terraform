output "privateips" {
    value = "${join(",", aws_instance.etlnode.*.private_ip)}"
}
