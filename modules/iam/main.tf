locals {
  managed_policy_name_entries = {
    for item in flatten([
      for role_name, cfg in var.roles : [
        for policy_name in try(cfg.managed_policy_names, []) : {
          key         = "${role_name}|${policy_name}"
          policy_name = policy_name
        }
      ]
    ]) :
    item.key => item.policy_name
  }

  role_policy_attachment_list = flatten([
    for role_name, cfg in var.roles : [
      for policy_arn in [for policy_name in try(cfg.managed_policy_names, []) : data.aws_iam_policy.by_name["${role_name}|${policy_name}"].arn] : {
        role_name  = role_name
        policy_arn = policy_arn
      }
    ]
  ])

  role_policy_attachment_map = {
    for item in local.role_policy_attachment_list :
    "${item.role_name}|${item.policy_arn}" => item
  }

  inline_policy_list = flatten([
    for role_name, cfg in var.roles : [
      for policy_name, policy_json in try(cfg.inline_policies, {}) : {
        role_name   = role_name
        policy_name = policy_name
        policy_json = policy_json
      }
    ]
  ])

  inline_policy_map = {
    for item in local.inline_policy_list :
    "${item.role_name}|${item.policy_name}" => item
  }
}

data "aws_iam_policy" "by_name" {
  for_each = local.managed_policy_name_entries
  name     = each.value
}

data "aws_iam_policy_document" "assume_role" {
  for_each = var.roles

  dynamic "statement" {
    for_each = length(try(each.value.assume_role_services, [])) > 0 ? [1] : []
    content {
      effect  = "Allow"
      actions = ["sts:AssumeRole"]
      principals {
        type        = "Service"
        identifiers = each.value.assume_role_services
      }
    }
  }

  dynamic "statement" {
    for_each = length(try(each.value.assume_role_arns, [])) > 0 ? [1] : []
    content {
      effect  = "Allow"
      actions = ["sts:AssumeRole"]
      principals {
        type        = "AWS"
        identifiers = each.value.assume_role_arns
      }
    }
  }
}

resource "aws_iam_role" "this" {
  for_each = var.roles

  name                 = each.key
  description          = try(each.value.description, null)
  path                 = try(each.value.path, "/")
  max_session_duration = try(each.value.max_session_duration, 3600)

  assume_role_policy = data.aws_iam_policy_document.assume_role[each.key].json
  tags               = merge(var.tags, try(each.value.tags, {}))
}

resource "aws_iam_role_policy_attachment" "managed" {
  for_each = local.role_policy_attachment_map

  role       = aws_iam_role.this[each.value.role_name].name
  policy_arn = each.value.policy_arn
}

resource "aws_iam_role_policy" "inline" {
  for_each = local.inline_policy_map

  name   = each.value.policy_name
  role   = aws_iam_role.this[each.value.role_name].name
  policy = each.value.policy_json
}
