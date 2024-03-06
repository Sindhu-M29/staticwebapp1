terraform {
  required_providers {
    azurerm = {
      source  = "hashicorp/azurerm"
      version = "3.8"
    }
  }
}

provider "azurerm" {
  features {}
}

resource "azurerm_resource_group" "RG" {
  name     = "staticwebapp1"
  location = "East US"
}

resource "azurerm_storage_account" "staticwebfiles" {
  name                     = "mystaticwebfiles"
  resource_group_name      = azurerm_resource_group.RG.name
  location                 = azurerm_resource_group.RG.location
  account_tier             = "Standard"
  account_replication_type = "GRS"
  
  access_tier = "Hot"

  static_website {
    index_document = "index.html"
  }
}

resource "azurerm_storage_container" "web" {
  name                  = "webapp"
  storage_account_name  = azurerm_storage_account.staticwebfiles.name
  container_access_type = "blob"
}
variable "source_folder" {
  description = "/home/azureuser/sindhu-static-site"
}

resource "azurerm_storage_blob" "folder_contents" {
  for_each               = fileset(var.source_folder, "*")
  name                   = "webapp/${each.key}"
  storage_account_name   = azurerm_storage_account.staticwebfiles.name
  storage_container_name = azurerm_storage_container.web.name
  type                   = "Block"
  source                 = "${var.source_folder}/${each.value}"
  content_type           = filetype("${var.source_folder}/${each.value}")
}

resource "azurerm_storage_blob" "blobfiles" {
  name                   = "webapp-zip"
  storage_account_name   = azurerm_storage_account.staticwebfiles.name
  storage_container_name = azurerm_storage_container.web.name
  type                   = "Block"
  source                 = "/home/azureuser/sindhu-static-site/index.html"
  content_type           = "text/html"
}

resource "azurerm_storage_blob" "html_blob" {
  name                   = "webapp/index.html"
  storage_account_name   = azurerm_storage_account.staticwebfiles.name
  storage_container_name = azurerm_storage_container.web.name
  type                   = "Block"
  source                 = "/home/azureuser/sindhu-static-site/index.html"
  content_type           = "text/html"
}

resource "azurerm_storage_blob" "css_blob" {
  name                   = "webapp/style.css"
  storage_account_name   = azurerm_storage_account.staticwebfiles.name
  storage_container_name = azurerm_storage_container.web.name
  type                   = "Block"
  source                 = "/home/azureuser/sindhu-static-site/style.css"
  content_type           = "text/css"
}
