---
title: "Hack 3985"
date: 2022-09-30T09:57:16+01:00
draft: true
---

#### Situation

Team HACK use separate AWS accounts to provision the various parts of the infrastructure for each project that they work on. Older projects built with Terragrunt are archived and so the team is unable to use Terraform to destroy the created resources. These resources are generating costs each month for services that are no longer running.

#### Task

Myself and another apprentice on the team were given a project to audit these legacy accounts and record costs then to devise a solution to automate the removal of resources after migrating app logs to a new, dedicated log account. THe task was broken into stages. First we would audit and record costs, secondly we would test our automation on non production accounts with a set of project tags and finally we would decommission and remove the legacy production resources. We would then be able to show cost savings to DWP.

#### Action

We used cloudability and AWS cost management to export an excel of the relevant project tags and associated costs
We decided to each look at a different aspect of hte task so my colleague looked at migrating logs to the new account using automation and I looked at deleting the resources.

I first spent some time looking at documentation for the AWS Cli as I felt I could make a bash script to run in each account to delete resources.

After some research I had 3 scripts ready for deleting s3 buckets, ecs instances and associated registries. I created some resources for testing and the bash scripts seemed to work fine however when I can to use them in the non production account my scripts did not behave as I expected and I encountered a lot of errors. This lead me to further reading on AWS resources.

I discovered that if if s3 buckets are set up with versioning enabled then you are unable to delete them using normal cli commands. Also order has to be correctly followed when deleting instances, remove lb's and target groups before deleting and then delete ECR associated.

Devised and tested further scripts then discovered that maximum number of items in list functions was causing issues with buckets that had lots of items. Another work round then was to implement loops to work through chunks of data.

Log groups had to be exported, further script. Only one export task per account at a time.

Decided to look instead at python boto3 library for AWS and translated my bash scripts into working python scripts.

#### Result

Outline of tickets/projects/accounts that we have worked in. Savings made.

Short run through of use of our automation in the FAR ticket and further improvements made?
