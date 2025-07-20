data "external" "myip" {
  program = ["bash", "${path.module}/get-my-ip.sh"]
}

locals {
  # my_ip = "${data.external.myip.result.ip}/32"
  my_ip = "49.206.46.188/32"

}
