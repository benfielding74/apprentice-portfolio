---
title: "Hack 3985"
date: 2022-09-30T09:57:16+01:00
draft: true
---

#### Situation

Team HACK use multiple AWS accounts to provision infrastructure for each project that they work on. Older projects built with Terragrunt are archived and so the team is unable to use Terraform to destroy the created resources. These resources are generating costs each month for services that are no longer running.

#### Task

Myself and another apprentice on the team were given a project to audit these legacy accounts, record costs and then devise a solution to automate the removal of resources after migrating app logs to a new, dedicated log account. With the help of the delivery manager and tech lead we broke the 'Epic' into more manageable tasks that we could complete individually or pair up on. First we would audit and record costs for each account, secondly we would test our automation on non production accounts with a set of project tags and finally we would decommission and remove the legacy production resources. We would then be able to show cost savings to DWP.

#### Action

We used Cloudability alongside AWS cost management to export an excel of the relevant project tags and associated costs for the accounts.
We decided to each look at a different aspect of the task so my colleague started to investigate automating the migration of logs to a dedicated account. I started to look at how I would automate the deletion of resources.

I first spent some time looking at AWS documentation and performing a Google search to see if I could find any further information or options for automating this task. I quickly found software that was available called [AWS Nuke](https://github.com/rebuy-de/aws-nuke) which promised to remove all AWS resources within a given account. After reading the documentation I decided this would not be an appropriate service to use as the task was to remove selected resources with specific project tags. I decided to try and use AWS CLI commands within a bash script that could be run with some user input to target the resources and delete them.

After some further research I had 3 scripts which would delete s3 buckets, ecs instances and associated Elastic Container Registries. I created some resources for testing and the bash scripts seemed to work fine however when I tried to use them in the non production account my scripts did not behave as I expected and I encountered a lot of errors. <Something here about debugging, testing, revision. Iterative process>.

I discovered that if if s3 buckets are set up with versioning enabled then you are unable to delete them using normal cli commands. A strict order has to be followed when deleting instances, remove lb's and target groups before deleting and then delete ECR associated.

Devised and tested further scripts then discovered that maximum number of items in list functions was causing issues with buckets that had lots of items. Another work round then was to implement loops to work through chunks of data.

Examples of code and things I'm looking at.

Log groups had to be exported, further script. Only one export task per account at a time.

Decided to look instead at python boto3 library for AWS and translated my bash scripts into working python scripts.

Final part of my task was to prepare suitable documentation to explain the process and how to use the scripts.

#### Result

Outline of tickets/projects/accounts that we have worked in. Savings made. Need to finish those tickets.

Short run through of use of my automation in the FAR ticket and further improvements made such as parrallelism and running on an instance to avoid timeouts caused by the VPN timing out etc
