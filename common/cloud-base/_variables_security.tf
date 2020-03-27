variable "bastion_key_name" {
  description = "secure bastion ssh key name"
}

variable "bastion_publickey_path" {
  description = "My secure bastion ssh public key"
}

variable "internalnode_key_name" {
  description = "secure bastion ssh key name"
}

variable "internalnode_publickey_path" {
  description = "My secure internal ssh public key"
}

variable "ssl_cert_mainlb_key_path" {
  description = "local path to the SSL key for the LB"
}

variable "ssl_cert_mainlb_pub_path" {
  description = "local path to the SSL cert for the LB"
}

variable "ssl_cert_mainlb_ca_path" {
  description = "local path to the SSL CA path for the LB"
}