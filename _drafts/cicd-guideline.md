---
title: "CI/CD Guideline"
excerpt: "In today's post we look at CI/CD guideline."
tagline: "Introduction to CI/CD"
header:
  overlay_color: "#24292f"
  teaser: assets/images/ci-cd/cicd-1.webp
tags:
  - ci-cd
toc: true
related: true
mermaid: true
---

## Continuous Integration - CI

<div class="mermaid">
graph LR
subgraph common
    UO[User/Organization] --> VC[Version control] --> C[Code]
    C --> SC[Security scan]
end
subgraph application-code
    SC --> B[Build]
    B --> STAA[Static tests]
    STAA --> FUN[Functional tests]
end
subgraph infrastructure-code
    SC --> STAI[Static tests]
    STAI --> SECI[Security tests]
end
</div>

## Continuous Delivery/Deployment - CD

<div class="mermaid">
graph LR
subgraph common
    CI[Continuous Integration] --> A[Artifact]
end
subgraph application-code
    A --> DTA[Deploy to test]
    DTA --> SMA[Smoke tests]
    SMA --> SEC[Security tests]
    SEC --> NONFUN[Non-functional tests]
    NONFUN -- optional --> APRA[Approval]
    APRA --> DEPA[Deploy to production]
end
subgraph infrastructure-code
    A --> DRY[Dry run]
    DRY --> DTI[Deploy to test]
    DTI --> SMI[Smoke tests]
    SMI -- optional --> APRI[Approval]
    APRI --> DEPI[Deploy to production]
end
</div>

## Vocabulary

### Version control

Version control systems (VCS) enable developers to collaborate on code by providing a platform to store, retrieve, review, and work together on the same codebase simultaneously.

The most popular VCS system is [Git](https://git-scm.com/), which offers a wide range of features and flexibility. Git allows developers to track changes, create branches for experimentation, merge code seamlessly, and resolve conflicts efficiently. It also provides a comprehensive historical log of modifications, making it easier to analyze the evolution of the codebase.

### Code

The code is the core of the CI pipeline. It is the element that is being scanned, built, and tested. The code could be either application code or infrastructure code.

Examples of application code:

- Python
- C++
- Go
- Java

Examples of infrastructure code:

- Terraform modules
- Bicep modules
- Ansible playbooks
- Kubernetes manifests

### Security scan

Here, the code is scanned for sensitive information, such as passwords, API keys, and other credentials. This is done to ensure that no sensitive information is accidentally committed to the repository, where it could be exposed to unauthorized parties.

Tools like [GitGuardian](https://www.gitguardian.com/) can be used to automate this process by scanning the codebase for sensitive information and alerting developers if any is found. You can also use [GitHub's secret scanning](https://docs.github.com/en/code-security/secret-scanning) with push protection to prevent secrets from being pushed to the repository, and thus avoid the need to scan for them.

### Build

In the build stage of a CI pipeline, a build script or tool is utilized to download dependencies, compile or build the artifact, and enable the execution of the application or installation of the library. This process ensures that all necessary dependencies are acquired and that the artifact is successfully constructed, enabling the subsequent operations to be carried out effectively.

There are two key benefits to this approach. Firstly, the application is built in a standardized environment, mitigating the "works in my machine" syndrome that can lead to inconsistencies and errors when deploying on different systems. Secondly, by automating the build process, any changes that break the build are immediately identified and flagged, enabling developers to promptly identify and troubleshoot the issue.

To ensure efficiency and reliability, the build step in a CI pipeline should be fully automated, without requiring manual intervention. This allows for consistent and reproducible builds, minimizing human error and enabling developers to focus on other tasks while the build process runs autonomously.

### Static tests

Static tests are checks performed on the codebase without executing the code. They help identify potential issues, ensure code quality, and verify adherence to standards. These tests can include linters, code formatters, and static analysis tools. The goal is to catch potential problems early in the development process. For infrastructure code, static tests can be used to identify potential misconfigurations or security issues. They can also validate that the code adheres to the required standards and best practices.

Useful tools for application code:

- [SonarQube](https://www.sonarqube.org/)
- [Code Climate](https://codeclimate.com/)
- [Codacy](https://www.codacy.com/)
- [CodeFactor](https://www.codefactor.io/)

Useful tools for infrastructure code:

- [PSRule](https://microsoft.github.io/PSRule)
- [Terratest](https://terratest.gruntwork.io/)
- [Checkov](https://www.checkov.io/)
- [tflint](https://github.com/terraform-linters/tflint)
- [Ansible-lint](https://ansible-lint.readthedocs.io/)

### Functional tests

Functional tests are designed to verify that the application or library behaves as expected. Examples of functional tests include:

- **unit tests**: test individual units of code, such as functions or classes, in isolation
- **integration tests**: test the interaction between different components of the application
- **end-to-end tests**: test the application or library as a whole, and are typically used to simulate real-world scenarios

Useful tools:

- [Selenium](https://www.selenium.dev/)
- [JUnit](https://junit.org/junit5/)
- [Mocha](https://mochajs.org/)

### Non-functional tests

Non-functional tests assess the performance, scalability, reliability, and other aspects of your software that are not directly related to its functionality. These tests are typically carried out using a testing framework, such as [JMeter](https://jmeter.apache.org/), which simulates real-world scenarios and measures the performance under different conditions. Examples of non-functional tests include:

- **load testing:** assess the application's behavior and performance under expected and peak loads to identify bottlenecks or performance issues
- **stress testing:** determine the stability and robustness of the system
- **usability testing:** evaluate the user interface (UI) and user experience (UX) aspects of the software to ensure it is intuitive and user-friendly
- **compatibility testing:** verify that the software functions correctly across different environments, platforms, and devices

The goal is to ensure that the software meets the desired quality attributes.

Useful tools:

- [JMeter](https://jmeter.apache.org/)
- [Gatling](https://gatling.io/)
- [Locust](https://locust.io/)

### Security tests

Security tests are designed to identify potential vulnerabilities and weaknesses in your application's security, and ensure that it meets the required security standards. Examples of security tests include:

- **vulnerability scanning:** scan the application for known vulnerabilities
- **penetration testing:** simulate real-world attacks to identify potential vulnerabilities and assess the effectiveness of security measures
- **security code review:** automated analysis of the application's source code to identify security flaws or insecure coding practices

Useful tools for application code:

- [OWASP ZAP](https://www.zaproxy.org/)
- [OpenVAS](https://www.openvas.org/)
- [Nikto](https://cirt.net/Nikto2)

Useful tools for infrastructure code:

- [Snyk](https://snyk.io/)
- [Terrascan](https://runterrascan.io/)
- [tfsec](https://aquasecurity.github.io/tfsec)

### Dry run

The dry run step involves simulating the deployment of infrastructure changes without actually making any modifications to the production environment. It allows you to validate the proposed changes, detect any potential issues or conflicts, and ensure that the infrastructure configuration is in a deployable state. This step can help catch errors or misconfigurations early on.

Examples of dry runs:

- `terraform plan`
- `az deployment <scope> what-if`
- `ansible-playbook --check`

### Smoke tests

Smoke testing comprises of relatively shallow yet wide tests that validate the application's critical components. It is often a short and low-cost test that may rapidly assess if the application has properly launched in production.

If your CI/CD processes have reached a certain level of maturity, it is advisable to include a step for smoke testing. In this step you deploy your infrastructure changes to a temporary environment. By leveraging this approach, you can ensure that the changes behave as expected, ensure that the infrastructure is provisioned and configured as intended,  and finally minimize the risk of introducing unforeseen issues or disruptions in the live system.

## Summary

In summary, this CI/CD guide provides essential guidelines and introduces engineers to the world of Continuous Integration and Continuous Deployment. It offers a comprehensive framework for modern software development and deployment practices, emphasizing the significance of continuous improvement, streamlined code integration, automated testing, and dependable delivery processes.

By embracing these principles and adopting best practices, teams can cultivate collaboration, enhance code quality, fortify security measures, and accelerate software releases. CI/CD isn't just a methodology; it represents a cultural shift that empowers organizations to adapt swiftly in the rapidly evolving technology landscape.

As you embark on your CI/CD journey, remember that it's not solely about reaching the final destination but equally about embracing the learning journey itself. Each step forward brings you closer to achieving excellence in software development and delivery.

## Resources

- [The fundamentals of continuous integration in DevOps](https://resources.github.com/devops/fundamentals/ci-cd/integration/)
- [What is a DevOps pipeline? A complete guide](https://resources.github.com/devops/pipeline/)
- [Branch Deployment Models](https://christosgalano.github.io/github/branch-deployment-models/)
- [terraform-template-repo](https://github.com/christosgalano/terraform-template-repo)
- [devops-with-github-example](https://github.com/christosgalano/devops-with-github-example)
