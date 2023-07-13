output "virtual_machines" {
  value       = { for o in flatten([
    for index, team in var.teams : [
      for member in team.members : {
        member   = member
        team = index
      }
  ]]) : o.team => o }
  description = "The provisioned virtual machines on harvester. (Format: [harvester_virtualmachine](https://registry.terraform.io/providers/harvester/harvester/latest/docs/data-sources/virtualmachine))"
}