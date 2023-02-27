---
title: "Hack Hw255"
date: 2022-12-05T12:13:26Z
draft: true
---

### Situation

A developer from one of the feature teams has raised a ticket to get access to the production database. They have tested their requirement to provide reports against statistical data in a non production environment and now need production access to inform a local job service trial and future national reporting. They have already raised a ticket with the Secure Design team and have been granted authorisation under guidelines to access the production database for a defined time period.

### Task

SDS have granted permissions for them to have Read Only access to the production database and write access to Charts in Mongodb Atlas in line with security policies and clearances and the Data Protection act 2018. My task is to explore roles and permissions with mongodb atlas Charts to provide the minimum amount of access to the production database whilst still being able to fully use the charts feature and then to implement this in the existing Terraform project stack before documenting the changes.

### Actions

* Research roles and permissions in mongodb - least privilege etc reference article
* Test on myself permissions and ability to create and edit charts - stages
* Discuss with colleague and with senior
* Attempt to create a custom role in UI without success, further reading (reference articles)
* CLarify access with SDS - SC cleared have access to prod but not ideal so proceed with least possible permission reference our security clearance stuff and GDPR k3 and k22
* Support ticket with mongodb - clarified that user needs data access to prod to work with charts
* Set up access in Mongodb UI
* Document process and apply to Terraform within project so it is a repeatable process
* Peer review on Terraform changes and on documentation


My first step was to review the current Terraform code to see how the data access was currently granted and what permissions were already in place. This gave me some idea of how permissions currently worked. Users are added to a group within the terraform project with roles defined such as Project Owner, Admin Access, Read Only Access etc. I went through the Mongo DB documentation for both database access and Charts access. I referenced a Mongo DB log article about granting least permissions.

I then tested my access and the process to create charts so I could see what the least possible access would be needed to be able to create charts. The process to do this is ….
I would need to grant x level of access. In peer review with my team, seniors didn’t think this level of access was within the scope of the SDS ticket and so I decided to ask SDS if this access would be ok. They gave approval for access. I documented the process and applied everything in Terraform so it was a repeatable process. Put my MR in for review and merged my changes. This gives limited access to the data which can easily be revoked by targeting a Terraform apply against the mongodb module.

### Result.

I learnt about Charts in mongodb and mostly about levels of access and granting least privilege. I learnt about Data Protection and only granting access to the data that is required for a task and only for as long as this access is needed.

* Benefits to the business

KSB's - potentially K3 implications of giving access to a prod database with live customer data, automation with Terraform ensuring that measures are in place to remove access - mongo db compass facility to grant 6 hours access

