## Azure resource provider ##
provider "azurerm" {
  version = "=1.14.8"
}

## Azure resource group for the kubernetes cluster ##
resource "azm_kubl" {
  name     = "${var.resource_group_name}"
  location = "${var.location}"
}

## AKS kubernetes cluster ##
resource "azm_kubl_cluster" { 
  name                = "${var.cluster_name}"
  resource_group_name = "${azm_kubl_cluster.name}"
  location            = "${azm_kubl_cluster.location}"
  dns_prefix          = "${var.dns_prefix}"

  linux_profile {
    admin_username ="${var.admin_username}"

    ## SSH key is generated using "tls_private_key" resource
    ssh_key {
      key_data = "${trimspace(tls_private_key.key.public_key_openssh)} ${var.admin_username}@azure.com"
    }
  }

  agent_pool_profile {
    name            = "default"
    count           = "${var.agent_count}"
    vm_size         = "Standard_D2"
    os_type         = "Linux"
    os_disk_size_gb = 30
  }

  service_principal {
    client_id     = "${var.client_id}"
    client_secret = "${var.client_secret}"
  }

  tags = {
    Environment = "dev"
  }
}

## Private key for the kubernetes cluster ##
resource "tls_private_key" "key" {
  algorithm   = "RSA"
}

## Save the private key in the local workspace ##
resource "null_resource" "save-key" {
  triggers = {
    key = "${tls_private_key.key.private_key_pem}"
  }

  provisioner "local-exec" {
    command = <<EOF
      mkdir -p ${path.module}/.ssh
      echo "${tls_private_key.key.private_key_pem}" > ${path.module}/.ssh/id_rsa
      chmod 0600 ${path.module}/.ssh/id_rsa
EOF
  }
}

## Outputs ##

# Example attributes available for output


output "kube_config" {
  value = azm_kubl_cluster.kube_config_raw
}

output "host" {
  value = azm_kubl_cluster.aks_demo.kube_config.0.host
}

output "configure" {
  value = <<CONFIGURE
Run the following commands to configure kubernetes client:
$ terraform output kube_config > ~/.kube/aksconfig
$ export KUBECONFIG=~/.kube/aksconfig
Test configuration using kubectl
$ kubectl get nodes
CONFIGURE
}