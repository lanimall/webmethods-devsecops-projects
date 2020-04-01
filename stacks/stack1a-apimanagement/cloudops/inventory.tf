data "template_file" "inventory-ansible" {
  template = file("${path.cwd}/helper_scripts/inventory-ansible")

  vars = {
    dns_apigateway1       = aws_route53_record.apigateway-a-record[0].name
    hostname_apigateway1  = aws_instance.apigateway[0].private_dns
    dns_apiportal1        = aws_route53_record.apiportal-a-record[0].name
    hostname_apiportal1   = aws_instance.apiportal[0].private_dns
  }
}

resource "local_file" "inventory-ansible" {
  content  = data.template_file.inventory-ansible.rendered
  filename = "${path.cwd}/outputs/${local.name_prefix_long}/ansible-inventory"
}