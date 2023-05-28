---
title: "AMI Refresh Project"
date: 2023-05-28T17:14:42+01:00
draft: true
---

#### Situation

In order to patch vulnerabilities and install software version updates so as to decrease the attack surface or servers and ensure they are equipped to support feature team applications, a process is in place within our department that builds a new Amazon Machine Image.  This is then updated within the application and infrastructure stacks by applying Terraform before finally Auto Scaling Group refreshes are manually carried out to apply the new launch templates. This manual process is carried out on a bi-weekly basis. The ASG refresh for production environment has to be carried out as an Out-of-hours task.

#### Task

A project team has been assembled consisting of myself, another apprentice and a fast-stream staff member, supported by two of the senior engineers. Our task is to find a way to automate the process of refreshing the auto scaling groups and testing that they are running. This turned out to be phase one of the task/project as once we had completed this intial step we were asked to also implement automation for the AMI build and the launch template updates. 

#### Action

Due to the scale of the project we each took on different tasks throughout. I first researched how we used Hashicorp Packer to build the AMI. This is done with a Jenkins build job that is scheduled to build each week. Once the AMI is built it is pushed to AWS Elastic Container Registry where it can be used by the launch templates. We discussed as a team how to trigger the Lambda that would handle the ASG refreshes and it was decided to use resource tagging to add meta data to the ASG's that logic in the Lambda code could use to determine if it needed to be refreshed as part of that event.

#### Result