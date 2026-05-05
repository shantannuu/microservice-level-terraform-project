resource "aws_security_group" "this" {
  name = var.sg_name
  description = var.sg_description
  vpc_id = var.vpc_id

  tags = merge(local.common_tags, {
        Name = "${var.env}-sg"
   }, var.sg_tags)

}

resource "aws_security_group_rule" "ingress" {
    for_each = {
        for idx, rule in var.ingress_rules : idx => rule
    }

    type = "ingress"
    security_group_id = aws_security_group.this.id

    from_port = each.value.from_port
    to_port = each.value.to_port
    protocol = each.value.protocol
    cidr_blocks = lookup(each.value, "cidr_blocks", null)
    ipv6_cidr_blocks = lookup(each.value, "ipv6_cidr_blocks", null)

    source_security_group_id = length(lookup(each.value, "sg_ids", [])) > 0 ? lookup(each.value, "sg_ids", [])[0] : null
}

resource "aws_security_group_rule" "egress" {
  for_each = {
    for idx, rule in var.egress_rules : idx => rule
  }

  type              = "egress"
  security_group_id = aws_security_group.this.id

  from_port   = each.value.from_port
  to_port     = each.value.to_port
  protocol    = each.value.protocol
  cidr_blocks = each.value.cidr_blocks
}

  

