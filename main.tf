locals {
  name = "ad.${var.domain_name}"
  short_name = "${upper(element(split(".", var.domain_name),0))}"
  alias = "${lower(local.short_name)}"
  base_dn = "DC=${replace(local.name, ".", ",DC=")}"

  common_tags = "${map(
    "Terraform", "true",
    "Environment", "${terraform.workspace}",
  )}"
}


resource "aws_subnet" "this" {
  count = 2

  vpc_id            = "${var.vpc_id}"
  availability_zone = "${var.availability_zones[count.index]}"
  cidr_block        = "${var.cidr_blocks[count.index]}"

  tags = "${merge(
    local.common_tags,
    map(
      "Name", "${local.alias}-directory-${var.availability_zones[count.index]}"
    )
  )}"
}

resource "aws_directory_service_directory" "this" {
  name       = "${local.name}"
  short_name = "${local.short_name}"

  password = "${var.password}"
  edition  = "Standard"
  type     = "MicrosoftAD"

  enable_sso = true
  alias      = "${local.alias}"

  vpc_settings = {
    vpc_id = "${var.vpc_id}"
    subnet_ids = [ "${aws_subnet.this.*.id}" ]
  }
}

data "template_file" "sudo_ldif" {
  template = "${file("${path.module}/templates/sudo.ldif")}"
  vars {
    base_dn = "${local.base_dn}"
  }
}

data "template_file" "sudo_start_schema_extension" {
  template = "${file("${path.module}/templates/start-schema-extension.json")}"

  vars {
    directory_id = "${aws_directory_service_directory.this.id}"
    ldif_content = "${jsonencode(data.template_file.sudo_ldif.rendered)}"
    description  = "sudo-1.8.19p2"
  }
}

resource "local_file" "sudo_start_schema_extension" {
  content     = "${data.template_file.sudo_start_schema_extension.rendered}"
  filename = "${path.module}/.internal/sudo--${aws_directory_service_directory.this.id}.json"

  provisioner "local-exec" {
    command = "aws --profile amd-nomr-tears-u ds start-schema-extension --cli-input-json file://${path.module}/.internal/sudo--${aws_directory_service_directory.this.id}.json"
  }
}
