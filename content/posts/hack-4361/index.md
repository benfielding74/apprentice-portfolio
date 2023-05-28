---
title: "Hack 4361"
date: 2023-01-23T18:57:19+01:00
draft: true
---

### Situation

The Nomad health check for the Find and Refer kong-traefik service is failing[^1]. Following Traefik deployment a smoke test is run, this test simply curls some endpoints specific to the deployment. A response code HTTP 200 is the expected response, anything else will cause the health check to fail. Some preliminary investigation has identified that the health check is curling an incorrect end point.

### Task

The requirements of the ticket are to adjust the health check as neccessary and test in sandbox environment to ensure it's working.

### Action

First I cloned the Traefik repo and ran a deployment in the sandbox environment so I could see what was currently happening. THe configuration was

```hcl

check { 
  type = “http”
  port = “https” 
  protocol = “https” 
  tls_skip_verify = true 
  path =“/healthcheck” 
  interval = “30s” 
  timeout = “15s” 
  }

```

Once I had deployed, the agent is alive and reachable but there was no output at all for the healthcheck. The gitlab pipeline fails with `http error 000` suggesting timeout or nothing at all at the endpoint. A colleague suggested that the path value should be changed to `/ping` and looking at configuration for other healthchecks I saw that a lot of check protocols were set to `http` rather than `https`. I made these changes and deployed once again with the following configuration

```hcl

check { 
  type = “http”
  port = “http” 
  protocol = “http” 
  tls_skip_verify = true 
  path =“/ping” 
  interval = “30s” 
  timeout = “15s” 
  }

  ```

This configuration would not even allow the Traefik instance to deploy or become available though the Jenkins pipeline does not give any errors and suggests that the deployment has been successful. The Traefik documentation suggests that `/ping` is the correct endpoint but that does not work. The protocol does need to be `https` for a successful deployment. I also tried to run without a specific port value as suggested in some examples seen on the internet but that does not allow the Kong service to be configured and the deployment pipeline fails.

I reviewed the documentation again and examined an existing job in Prometheus(which was working). What I discovered was that a ping endpoint has to be declared within the traefik-kong configuration before it is used in the check stanza. My final configuration was this

```hcl

traefik-kong:
  dashboard:true
  insecure:true
  ping:
    entryPoint: "traefik"

check { 
  type = “http”
  port = “traefik” # which is hitting port 8081 for the healthcheck
  protocol = “http” 
  tls_skip_verify = true 
  path =“/ping” 
  interval = “30s” 
  timeout = “15s” 
  }

  ```

### Result

I applied this configuration in the sandbox environment and checked against the Consul UI that the healthcheck was returning a 200 code. Once this was confirmed I submitted a merge request. This was approved and I deployed to all non prod environments using the gitlab CI/CD pipelines and then carried out a targeted deployment to production suing Jenkins. This ticket was important for the team as the healthcheck is an important check that let's us know our infrastructure is working and available and the apps that the feature teams deploy are accessible. 

This ticket gave me an opportunity to learn about Traefik and reverse proxies. I learnt how they are configured and also learnt about carrying out healthchecks on endpoints adn the importance of this in monitoring our infrastructure.

[^1]: ***Kong Gateway** is a lightweight, fast, and flexible cloud-native API gateway. An API gateway is a reverse proxy that lets you manage, configure, and route requests to your APIs. Kong Gateway runs in front of any RESTful API and can be extended through modules and plugins. It’s designed to run on decentralized architectures, including hybrid-cloud and multi-cloud deployments. **Traefik** is a reverse proxy that sits between client requests and the backend services that handle those requests. It works by inspecting incoming requests and using a set of rules to determine how to route the request to the appropriate backend service*