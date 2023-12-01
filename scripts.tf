## Terraform for scripts to bootstrap
locals {
  templatefiles = [
    
    
  ]

  script_contents = [
    for t in local.templatefiles : templatefile(t.name, t.variables)
  ]

  script_output_generated = [
    for t in local.templatefiles : "${path.module}/output/windows/${replace(basename(t.name), ".tpl", "")}"
  ]

  # reference in the main user_data for each windows system
  script_files = [
    for tf in local.templatefiles :
    replace(basename(tf.name), ".tpl", "")
  ]
}

resource "local_file" "generated_scripts" {

  count = length(local.templatefiles)

  filename = local.script_output_generated[count.index]
  content  = local.script_contents[count.index]
}
