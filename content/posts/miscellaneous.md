---
title: "Miscellaneous"
date: 2022-07-07T14:17:15+01:00
draft: true
---

# Miscellaneous Projects and tasks not ticketed

* Updated a script in the 'Getting Started' repo which gave me visibility of Team conventions ie branching the repo, submitting a merge request and notifying the correct Slack channel

* Looked at Go docs and then UCCLI cli. Familiarized myself with the codebase and then decided to pick off an easy first issue. The issue required a link to the release page to be provided when the upgrade command is run. This was found in the update.go file and only required a `fmt.Printf` statement. Submitted merge request and talked through the CI/CD pipeline for the project with product owner.

* Peer reviewed HACK-3095 for Barrington. Remove transit_subnet_route_legacy_common_stage once team have migrated from BB Macs

```
module "transit_subnet_route_legacy_common_stage" {

  source                  = "./vendor/modules/terraform-aws-transit-subnet-route"

  config                  = module.config

  data                    = module.data

  core_infra              = module.core_infra

  target_subnets          = ["public", "private", "data"]

  cidr                    = "10.219.16.0/24"

  conditional_provisoning = local.provision_to_legacy_common_stage

}
```

Involved running terraform plans in 12 repos, reviewing the changes, liasing with other team members to check changes and errors and then merging the feature branch. Ran into problems with vault permissions on the vault stack which I will step through.

HACK 4175 - adding users to qa2 environment for access to Atlas Mongodb. Had to add email address to environment object in terraform file. Errors thrown so paired with Royston and he explained that user had to have an atlas account before plan could be applied.

Advised mos who raised ticket and once account was set I was able to invite to relevant group. Once invite was accepted then I was able to add to the TF and apply the plan in relevant workspaces so the mos had access

HACK 4231 - Cert renewal

HACK 4234 gilab access for new MOS
