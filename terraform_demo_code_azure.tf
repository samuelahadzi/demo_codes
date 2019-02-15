# Configure the Microsoft Azure Provider
provider "azurerm" {
    # Whilst version is optional, we /strongly recommend/ using it to pin the version of the Provider being used
    version = "=1.21.0"
    subscription_id = "72fe589e-571b-4552-afaf-8de7d9c7e083"
    tenant_id       = "400b47ce-ffad-4d65-bdf3-1a2f5312e597"
}

# Create a resource group if it doesn’t exist
resource "azurerm_resource_group" "pferesourcegroup" {
    name     = "pfeResourceGroup"
    location = "westeurope"

    tags {
		environment = "Production"
    }
}

# Create virtual network
resource "azurerm_virtual_network" "pfenetwork" {
    name                = "pfeVnet"
    address_space       = ["192.168.0.0/16"]
    location            = "westeurope"
    resource_group_name = "${azurerm_resource_group.pferesourcegroup.name}"

    tags {
        environment = "Production"
    }
}

# Create subnet
resource "azurerm_subnet" "pfesubnet" {
    name                 = "pfeSubnet"
    resource_group_name  = "${azurerm_resource_group.pferesourcegroup.name}"
    virtual_network_name = "${azurerm_virtual_network.pfenetwork.name}"
    address_prefix       = "192.168.1.0/24"
}

# Create public IPs
resource "azurerm_public_ip" "pfepublicipforvm1" {
    name                         = "pfePublicIPforVM1"
    location                     = "westeurope"
    resource_group_name          = "${azurerm_resource_group.pferesourcegroup.name}"
    allocation_method            = "Dynamic"

    tags {
        environment = "Production"
    }
}

# Create public IPs
resource "azurerm_public_ip" "pfepublicipforvm2" {
    name                         = "pfePublicIPforVM2"
    location                     = "westeurope"
    resource_group_name          = "${azurerm_resource_group.pferesourcegroup.name}"
    allocation_method            = "Dynamic"

    tags {
        environment = "Production"
    }
}

# Create public IPs
resource "azurerm_public_ip" "pfepublicipforlb" {
    name                         = "pfePublicIPForLB"
    location                     = "westeurope"
    resource_group_name          = "${azurerm_resource_group.pferesourcegroup.name}"
    allocation_method            = "Static"

    tags {
        environment = "Production"
    }
}

# Create Network Security Group and rule
resource "azurerm_network_security_group" "pfensg" {
    name                = "pfeNetworkSecurityGroup"
    location            = "westeurope"
    resource_group_name = "${azurerm_resource_group.pferesourcegroup.name}"

    security_rule {
        name                       = "SSH"
        priority                   = 1001
        direction                  = "Inbound"
        access                     = "Allow"
        protocol                   = "Tcp"
        source_port_range          = "*"
        destination_port_range     = "22"
        source_address_prefix      = "*"
        destination_address_prefix = "*"
    }

    security_rule {
        name                       = "HTTP80"
        priority                   = 1002
        direction                  = "Inbound"
        access                     = "Allow"
        protocol                   = "Tcp"
        source_port_range          = "*"
        destination_port_range     = "80"
        source_address_prefix      = "*"
        destination_address_prefix = "*"
    }

    security_rule {
        name                       = "HTTP8080"
        priority                   = 1003
        direction                  = "Inbound"
        access                     = "Allow"
        protocol                   = "Tcp"
        source_port_range          = "*"
        destination_port_range     = "8080"
        source_address_prefix      = "*"
        destination_address_prefix = "*"
    }

    security_rule {
        name                       = "HTTPS"
        priority                   = 1004
        direction                  = "Inbound"
        access                     = "Allow"
        protocol                   = "Tcp"
        source_port_range          = "*"
        destination_port_range     = "443"
        source_address_prefix      = "*"
        destination_address_prefix = "*"
    }

    security_rule {
        name                       = "PORT5601"
        priority                   = 1005
        direction                  = "Inbound"
        access                     = "Allow"
        protocol                   = "Tcp"
        source_port_range          = "*"
        destination_port_range     = "5601"
        source_address_prefix      = "*"
        destination_address_prefix = "*"
    }

    security_rule {
        name                       = "PORT9200"
        priority                   = 1006
        direction                  = "Inbound"
        access                     = "Allow"
        protocol                   = "*"
        source_port_range          = "*"
        destination_port_range     = "9200"
        source_address_prefix      = "*"
        destination_address_prefix = "*"
    }

    security_rule {
        name                       = "PORT5044"
        priority                   = 1007
        direction                  = "Inbound"
        access                     = "Allow"
        protocol                   = "*"
        source_port_range          = "*"
        destination_port_range     = "5044"
        source_address_prefix      = "*"
        destination_address_prefix = "*"
    }

    security_rule {
        name                       = "PORT1337"
        priority                   = 1008
        direction                  = "Inbound"
        access                     = "Allow"
        protocol                   = "*"
        source_port_range          = "*"
        destination_port_range     = "1337"
        source_address_prefix      = "*"
        destination_address_prefix = "*"
    }

    security_rule {
        name                       = "PORT3389"
        priority                   = 1009
        direction                  = "Inbound"
        access                     = "Allow"
        protocol                   = "*"
        source_port_range          = "*"
        destination_port_range     = "3389"
        source_address_prefix      = "*"
        destination_address_prefix = "*"
    }

    tags {
        environment = "Production"
    }
}

# Create network interface
resource "azurerm_network_interface" "pfenicforvm1" {
    name                = "pfeNICforVM1"
    location            = "westeurope"
    resource_group_name = "${azurerm_resource_group.pferesourcegroup.name}"
    network_security_group_id = "${azurerm_network_security_group.pfensg.id}"

    ip_configuration {
        name                          = "pfeNICforVM1Configuration"
        subnet_id                     = "${azurerm_subnet.pfesubnet.id}"
        private_ip_address_allocation = "dynamic"
        public_ip_address_id          = "${azurerm_public_ip.pfepublicipforvm1.id}"

    }

    tags {
        environment = "Production"
    }
}

# Create network interface
resource "azurerm_network_interface" "pfenicforvm2" {
    name                = "pfeNICforVM2"
    location            = "westeurope"
    resource_group_name = "${azurerm_resource_group.pferesourcegroup.name}"
    network_security_group_id = "${azurerm_network_security_group.pfensg.id}"

    ip_configuration {
        name                          = "pfeNICforVM2Configuration"
        subnet_id                     = "${azurerm_subnet.pfesubnet.id}"
        private_ip_address_allocation = "dynamic"
        public_ip_address_id          = "${azurerm_public_ip.pfepublicipforvm2.id}"

    }

    tags {
        environment = "Production"
    }
}

# Generate random text for a unique storage account name
resource "random_id" "randomId" {
    keepers = {
        # Generate a new ID only when a new resource group is defined
        resource_group = "${azurerm_resource_group.pferesourcegroup.name}"
    }

    byte_length = 8
}

# Create storage account for boot diagnostics
resource "azurerm_storage_account" "pfestorageaccount" {
    name                = "diag${random_id.randomId.hex}"
    resource_group_name = "${azurerm_resource_group.pferesourcegroup.name}"
    location            = "westeurope"
    account_replication_type = "LRS"
    account_tier = "Standard"

    tags {
        environment = "Production"
    }
}

# Create loadbalancer
resource "azurerm_lb" "pfelb" {
    name                  = "pfeLB"
    location              = "westeurope"
    resource_group_name   = "${azurerm_resource_group.pferesourcegroup.name}"

    frontend_ip_configuration {
        name                 = "pfeLBPublicAdress"
        public_ip_address_id = "${azurerm_public_ip.pfepublicipforlb.id}"
        private_ip_address   = "192.168.1.101"
    }

    tags {
        environment = "Production"
    }
}

# Create linux virtual machine
resource "azurerm_virtual_machine" "pfevm1" {
    name                  = "pfeVM1"
    location              = "westeurope"
    resource_group_name   = "${azurerm_resource_group.pferesourcegroup.name}"
    network_interface_ids = ["${azurerm_network_interface.pfenicforvm1.id}"]
    vm_size               = "Standard_DS1_v2"

    storage_os_disk {
        name              = "pfeVM1OsDisk"
        caching           = "ReadWrite"
        create_option     = "FromImage"
        managed_disk_type = "Premium_LRS"
    }

    storage_image_reference {
        publisher = "Canonical"
        offer     = "UbuntuServer"
        sku       = "16.04.0-LTS"
        version   = "latest"
    }

    os_profile {
        computer_name  = "pfeVM1"
        admin_username = "azureuser"
        admin_password = "Itsatest1"
    }

    os_profile_linux_config {
        disable_password_authentication = false
       # ssh_keys {
       #     path     = "/home/azureuser/.ssh/authorized_keys"
       #     key_data = "ssh-rsa AAAAB3Nz{snip}hwhqT9h"
       # }
    }

    boot_diagnostics {
        enabled     = "true"
        storage_uri = "${azurerm_storage_account.pfestorageaccount.primary_blob_endpoint}"
    }

    tags {
        environment = "Production"
    }
}

# Create windows virtual machine
resource "azurerm_virtual_machine" "pfevm2" {
    name                  = "pfeVM2"
    location              = "westeurope"
    resource_group_name   = "${azurerm_resource_group.pferesourcegroup.name}"
    network_interface_ids = ["${azurerm_network_interface.pfenicforvm2.id}"]
    vm_size               = "Standard_B2s"

    storage_os_disk {
        name              = "pfeVM2OsDisk"
        caching           = "ReadWrite"
        create_option     = "FromImage"
        managed_disk_type = "Premium_LRS"
    }

    storage_image_reference {
        publisher = "MicrosoftWindowsServer"
        offer     = "WindowsServer"
        sku       = "2016-Datacenter-Server-Core-smalldisk"
        version   = "latest"
    }

    os_profile {
        computer_name  = "pfeVM2"
        admin_username = "azureuser"
        admin_password = "Itsatest1"
    }

    os_profile_windows_config {
      
    }

    boot_diagnostics {
        enabled     = "true"
        storage_uri = "${azurerm_storage_account.pfestorageaccount.primary_blob_endpoint}"
    }

    tags {
        environment = "Production"
    }
}