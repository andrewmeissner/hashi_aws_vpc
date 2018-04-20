data "external" "hashi-keygen" {
  program = ["${path.root}/scripts/hashi-keygens.sh"]
}
