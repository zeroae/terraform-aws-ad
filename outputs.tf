output subnet_ids {
  value = "${aws_subnet.this.*.id}"
}

output dns_ip_addresses {
  value = "${aws_directory_service_directory.this.dns_ip_addresses}"
}

output base_dn {
  value = "${local.base_dn}"
}

output domain_name {
  value = "${local.name}"
}
