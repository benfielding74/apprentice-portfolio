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

I first spent some time looking at AWS documentation and performing a Google search to see if I could find any further information or options for automating this task. I quickly found software that was available called [AWS Nuke](https://github.com/rebuy-de/aws-nuke) which is a tool that removes all services and resources from a given account. After reading the documentation I decided this would not be an appropriate service to use as the task was to remove selected resources with specific project tags. I decided that a bespoke solution was required and I decided to wrap AWS Cli commands within a bash script with some user input to provide account names and project tags. This would allow the user to target deletion of only the project tags they had selected. I created some resources in the non prod account to test my script and everything seemed to work.

![First iteration of the bash script](bash1.svg)

*Fig 1: The first iteration of my bash script to delete s3 buckets*

Once I tried to use the script on real resources I started to experience errors and the scripts were not performing as I had expected. I received error messages indicating that 'versioned' buckets cannot be deleted. After reviewing the bucket settings and reading the AWS Cli documents I realised I would have to implement some further steps to my script to delete first versions (what are versions) then delete markers (what are delete markers) then the objects within the bucket and finally the bucket itself.

My second iteration of the script added additional commands wrapped within functions to delete the version markers and delete markers in the buckets. I worked through this slowly using errors to debug and improve my script

![Second iteration of the bash script](bash2.svg)

Devised and tested further scripts to do the same with Elastic Container Services and Registries then worked through the project tags in the non prod account on my first ticket to remove all services leaving only the log buckets to be migrated as part of my colleagues work.

Log groups had to be exported, further script. Only one export task per account at a time.

Decided to look instead at python boto3 library for AWS and translated my bash scripts into working python scripts.

Final part of my task was to prepare suitable documentation to explain the process and how to use the scripts.

#### Result

Outline of tickets/projects/accounts that we have worked in. Savings made. Need to finish those tickets.

Short run through of use of my automation in the FAR ticket and further improvements made such as parrallelism and running on an instance to avoid timeouts caused by the VPN timing out etc

Agile - iterations of my scripts to improve the process and handle new problems
