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

HACK 4234 gitlab access for new MOS

HACK - 161 Move Terraform to Gitlab CI/CD for non prod
s:Implementing gitlab CI/CD in projects in non prod environments
T: Implement Gitlab CI/CD to carry out code checks, plan, and apply Terraform.

prepare and upload yml file for project to https://git.ss.build.uc.internal/dwp/uc/platform/hcl2/cicd-pipelines
reference yml in CI/CD pipeline settings
Update project variables
Update README
A:Written .yml file for project on feature branch in cicd-pipelines

Spoken with Pete - Delivery Systems team who will provide project-config and vault access for the pipeline.
R: implemented pipeline
![pipeline](pipeline.png)
Received feedback
![feedback](feedback.png)

Hack 4237 Create AWS account and access using Terraform

HACK 4235 - abstracting secrets from repo to pull from vault instead -
  when to use plan do check act cycle:
  - starting a new imporvement project
  -developing a new or improved design of a process, product or service
  -implementing any change

  Plan - plan what needs to be done
  what is the core problem that needs to be solved
  what resources do we have
  what resources do we need
  what is the best solution for fixing the problem
  definition of done/what are the goals/what does success look like

  DO - apply everything that has been considered during the previous stage -incorporate on a small scale in a controlled environment

  Check - audit the plans execution see if it worked and monitor, analyse faults and problems

  Act - adopt if objectives met, may become standard baseline, make improvements
  

HW-277 - Updating onboarding docs and creating off boarding docs including HW273 to update the start-here repo

HACK 4361 - Fix the FAR Kong Persistence Service NOmad Health Check
s: The Nomad health check for the FAR Kong Traefik service is failing (probably always has). The check isn't valid. 

Example: https://consul.orc.mgmt-prod.uc.internal:8501/ui/eu-west-2/services/traefik-far-prod-kong/instances

refer-to-provision-service/traefik repository.
t:The correct endpoint is /ping. Adjust the health check as necessary, test in sandbox and then roll out to all envs.
a: Clone the repo, update the variables, test.

This did not go as planned -

Original =
check {
        type     = "http"
        port     = "https"
        protocol = "https"
        tls_skip_verify = true
        path     = "/healthcheck"
        interval = "30s"
        timeout  = "15s"
      }

SI suggested change "/healthcheck" to "ping"
May need to change protocol to http?

First run >
Pipeline acceptance always fails on the smoketest script. I need to check this.
Should deploy to <https://consul.orc.mgmt-nonprod.uc.internal:8501/ui/eu-west-2/services>

Agent is alive and reachable but no output at all for the check. Pipeline fails with http error 000 suggesting timeout or nothing at all at endpoint.

Second run >
Change protocol to http

check {
        type     = "http"
        port     = "http"
        protocol = "http"
        tls_skip_verify = true
        path     = "/ping"
        interval = "30s"
        timeout  = "15s"
      }

Something goes wrong with this and it doesn't even deploy?
Tried to deploy again and double checked all of the env variables
This time it deployed but I had forgotten to change to my branch

Tried again and it doesn't seem to deploy even though the pipeline suggests that it does

changed port back to https and left protocol as http which deployed but didn't pass checks again.

Next step is to try endpoint health with this config
Still not giving anything back

Now testing mirroring /metrics (which works) by changing endpoint to /kong

CHanging endpoint back to healthcheck with http protocol

So I need to do a bit of research for the check block. Script seems to indicate /health so I'll try that as well

docs suggest ping is the correct endpoint so why does that not work or not deploy?

check {
        type     = "http"
        port     = "http"
        protocol = "https"
        tls_skip_verify = true
        path     = "/ping"
        interval = "30s"
        timeout  = "15s"
      }

doesn't deploy

check {
        type     = "http"
        port     = "http"
        protocol = "http"
        tls_skip_verify = true
        path     = "/ping"
        interval = "30s"
        timeout  = "15s"
      }

doesn't deploy

Tried running without a specific port and the kong service will not configure and plan fails
Result/Outcome:

Final change looked like:
  check {
    type      = "http"
    port      = "traefik" # which is hitting port 8081
    protocol  = "http"
    tls_skip_verify   = true
    path      = "/ping"
    interval  = "30s"
    timeout   = "15s"
  }

What I discovered through reading the documents and examining the existing job in prometheus(which did work) is that you have to declare a ping endpoint as so:

  traefik-kong:
    dashboard: true
    insecure: true
  ping:
    entryPoint: "traefik"

Changed was applied in sandbox and MR merged with no comment. Then I rolled out in all non prod envs. Everything up to stage is handled in gitlab ci/cd with stage and prod being handled in Jenkins still (SDP issue).



