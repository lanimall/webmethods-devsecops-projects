data "template_file" "inventory-ansible" {
  template = file("${path.cwd}/helper_scripts/ansible-inventory.template")

  vars = {
    apigateway1_dns = length(aws_route53_record.apigateway-a-record)>0 ? aws_route53_record.apigateway-a-record.0.name : "null"
    apigateway2_dns = length(aws_route53_record.apigateway-a-record)>1 ? aws_route53_record.apigateway-a-record.1.name : "null"

    apigateway1_hostname = length(aws_instance.apigateway)>0 ? aws_instance.apigateway.0.private_dns : "null"
    apigateway2_hostname = length(aws_instance.apigateway)>1 ? aws_instance.apigateway.1.private_dns : "null"

    apigateway-internaldatastore1_dns = length(aws_route53_record.internaldatastore-a-record)>0 ? aws_route53_record.internaldatastore-a-record.0.name : "null"
    apigateway-internaldatastore2_dns = length(aws_route53_record.internaldatastore-a-record)>1 ? aws_route53_record.internaldatastore-a-record.1.name : "null"
    apigateway-internaldatastore3_dns = length(aws_route53_record.internaldatastore-a-record)>2 ? aws_route53_record.internaldatastore-a-record.2.name : "null"
    
    apigateway-internaldatastore1_hostname = length(aws_instance.internaldatastore)>0 ? aws_instance.internaldatastore.0.private_dns : "null"
    apigateway-internaldatastore2_hostname = length(aws_instance.internaldatastore)>1 ? aws_instance.internaldatastore.1.private_dns : "null"
    apigateway-internaldatastore3_hostname = length(aws_instance.internaldatastore)>2 ? aws_instance.internaldatastore.2.private_dns : "null"
    
    apiportal1_dns = length(aws_route53_record.apiportal-a-record)>0 ? aws_route53_record.apiportal-a-record.0.name : "null"
    apiportal1_hostname = length(aws_instance.apiportal)>0 ? aws_instance.apiportal.0.private_dns : "null"
  }
}

resource "local_file" "inventory-ansible" {
  content  = data.template_file.inventory-ansible.rendered
  filename = "${path.cwd}/outputs/${local.name_prefix_long}/ansible-inventory"
}