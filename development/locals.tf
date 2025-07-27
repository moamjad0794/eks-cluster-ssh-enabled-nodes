data "external" "myip" {
  program = ["bash", "${path.module}/get-my-ip.sh"]
}

locals {
  # my_ip = "${data.external.myip.result.ip}/32"
  my_ip = "106.200.30.169/32"

}
