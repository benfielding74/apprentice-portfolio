---
title: "Hack 4235"
categories: [problem solving]
tags: [problem solving techniques, plan-do-check-act]
date: 2022-10-22T18:12:03+01:00
draft: false
---

#### Situation

Configuration of Jenkins controller and agents is done by means of a Jenkins module which holds all of the Jenkins configuration in a mixture of xml and other files.

#### Task

In order to standardize the configuration, utilize consul templates to configure application within the `terraform-aws-jenkins` module.

#### Action

I decided to use the Plan-Do-Check-Act problem solving technique in my workflow for this ticket as I felt it would be most appropriate. It is recommended for use when you are developing a new or improved design of a process, product or service, implementing any change, or starting a new improvement. As this was an iteration of our Jenkins stack that was designed to implement new security features and would require testing I felt this would be a good fit. [(*K6*)]({{< ref "/posts/work-mapping-table#K6.1">}})

> The Plan-Do-Check-Act technique:
>
>Plan - plan what needs to be done
>  what is the core problem that needs to be solved?
>  what resources do we have?
>  what resources do we need?
>  what is the best solution for fixing the problem?
>  definition of done/what are the goals/what does success look like?
>
>  DO - apply everything that has been considered during the previous stage -incorporate on a small scale in a controlled environment
>
>  Check - audit the plans execution see if it worked and monitor, analyze faults and problems
>
>  Act - adopt if objectives met, may become standard baseline, make improvements

I first had to do some research to understand how the current configuration works, how the files were structured, and decide how I would implement any possible solution. 

In applying my plan (the Do stage) I updated the maven settings to be .ctmpl files instead of .xml files. I changed the references to credentials within the .xml files to reference instead a vault path and I updated the cloudinit_base.tmpl so that referenced the new file. I then added a new path in the Vault UI to hold the credentials. I then added a gradle.properties file holding the configuration for that.

```xml

<settingsSecurity>
  <master>{{ with secret "/secrets-infra/jenkins/generic/maven" }}{{ .Data.data.security_password }}{{ end }}</master>
</settingsSecurity>

```

*example of abstracting credentials to Vault*

I had to run my changes in a worker node within a test environment that we have to check if my changes were working. I ran into errors with the maven settings and new files that I had created. To identify the cause of some of these errors I had to ssh into the Jenkins instance and verify that /var/lib/jenkins/.m2 had the templates I had created in a rendered format. I could also check the status of Jenkins and query the startup logs. I debugged these errors one by one which mostly involved adjusting syntax and file paths for the changes I had made. Once I had everything working as it had been with the config in .xml I submitted a merge request and waited for a review by a senior.

#### Result

MR approved and merged and my changes rolled out to all environments. Ticket was beneficial to me as it started to give me an understanding of how Jenkins works and how we can utilize Vault to protect credentials within pipelines. Ticket benefitted the team and other feature teams using Jenkins as it enhanced security and the use of consul templates made the configuration easier to understand and amend.

