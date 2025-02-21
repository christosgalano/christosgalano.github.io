---
title: "CI/CD Guide"
excerpt: "Explore CI/CD practices and enhance your development workflow with this comprehensive guide."
tagline: "Streamlining Your Development Process: A CI/CD Guide"
header:
  overlay_color: "#24292f"
  teaser: assets/images/ci-cd/cicd-1.webp
tags:
  - ci-cd
mermaid: true
---

## Overview

In today's dynamic software development landscape, the buzz surrounding Continuous Integration and Continuous Deployment (CI/CD) has become a defining force. As organizations strive for faster and more reliable software delivery, CI/CD has emerged as a vital practice. This guide is your gateway to the world of CI/CD, providing answers to common questions, valuable insights, and a concise overview of CI/CD workflows. It also introduces you to a range of potential tools for each stage of the CI/CD pipeline, equipping developers and DevOps professionals alike with the knowledge to effectively implement and streamline their development and deployment processes. Whether you want to enhance code quality, streamline deployments, or explore new possibilities, this guide will be your practical resource for CI/CD.

## Continuous Integration - CI

<div class="mermaid">
graph LR
subgraph common
    UO[User/Organization] --> VC[Version control] --> C[Code]
    C --> SC[Security scan]
end
subgraph application-code
    SC --> STAA[Static analysis]
    STAA --> B[Build]
    B --> FUN[Functional tests]
end
subgraph infrastructure-code
    SC --> STAI[Static analysis]
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

### Static analysis

Static analysis involves examining the codebase without code execution. Its purpose is to spot potential issues, ensure code quality, and confirm compliance with standards. This process includes the use of linters, code formatters, and static analysis tools. Static analysis aims to catch problems early in the development process. In the case of infrastructure code, it helps detect misconfigurations and security issues while ensuring alignment with required standards and best practices.

Useful tools for application code:

- [SonarQube](https://www.sonarqube.org/)
- [Code Climate](https://codeclimate.com/)
- [Codacy](https://www.codacy.com/)
- [CodeFactor](https://www.codefactor.io/)

Useful tools for infrastructure code:

- [PSRule](https://microsoft.github.io/PSRule)
- [Template Analyzer](https://github.com/Azure/template-analyzer)
- [Checkov](https://www.checkov.io/)
- [tflint](https://github.com/terraform-linters/tflint)
- [Ansible-lint](https://ansible-lint.readthedocs.io/)
- [Conftest](https://github.com/open-policy-agent/conftest)
- [Kubeconform](https://github.com/yannh/kubeconform)

### Functional tests

Functional tests are designed to verify that the application or library behaves as expected. Examples of functional tests include:

- **unit tests**: test individual units of code, such as functions or classes, in isolation
- **smoke tests**: test the critical components of the application to ensure that it is functioning as expected
- **integration tests**: test the interaction between different components of the application
- **regression tests**: test the application to ensure that new changes do not break existing functionality
- **end-to-end tests**: test the application or library as a whole, and are typically used to simulate real-world scenarios

Useful tools for application code:

- [Selenium](https://www.selenium.dev/)
- [JUnit](https://junit.org/junit5/)
- [Cypress](https://www.cypress.io/)
- [Playwright](https://playwright.dev/)
- [Karate](https://github.com/karatelabs/karate)

Useful tools for infrastructure code:

- [Terratest](https://terratest.gruntwork.io/)
- [Kitchen-Terraform](https://github.com/newcontext-oss/kitchen-terraform)

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
- [Chaos Mesh](https://chaos-mesh.org/)

### Security tests

Security tests are designed to identify potential vulnerabilities and weaknesses in your application's security and ensure that it meets the required security standards. Examples of security tests include:

- **vulnerability scanning:** scan the application for known vulnerabilities
- **penetration testing:** simulate real-world attacks to identify potential vulnerabilities and assess the effectiveness of security measures
- **security code review:** automated analysis of the application's source code to identify security flaws or insecure coding practices

Useful tools for application code:

- [OWASP ZAP](https://www.zaproxy.org/)
- [OpenVAS](https://www.openvas.org/)
- [Bandit](https://github.com/PyCQA/bandit)
- [Nikto](https://cirt.net/Nikto2)
- [DevSkim](https://github.com/microsoft/DevSkim)
- [MSDO](https://github.com/microsoft/security-devops-action)
- [Ethical Check](https://www.ethicalcheck.dev/)

Useful tools for infrastructure code:

- [Snyk](https://snyk.io/)
- [Terrascan](https://runterrascan.io/)
- [tfsec](https://aquasecurity.github.io/tfsec)
- [MSDO](https://github.com/microsoft/security-devops-action)
- [OpenSSF Scorecard](https://github.com/ossf/scorecard)
- [Kubesec](https://kubesec.io/)

### Dry run

The dry run step involves simulating the deployment of infrastructure changes without actually making any modifications to the production environment. It allows you to validate the proposed changes, detect any potential issues or conflicts, and ensure that the infrastructure configuration is in a deployable state. This step can help catch errors or misconfigurations early on.

Examples of dry runs:

- `terraform plan`
- `az deployment <scope> what-if`
- `ansible-playbook --check`

### Smoke tests

Smoke testing comprises relatively shallow yet wide tests that validate the application's critical components. It is often a short and low-cost test that may rapidly assess if the application has properly launched in production.

If your CI/CD processes have reached a certain level of maturity, it is advisable to include a step for smoke testing. In this step, you deploy your infrastructure changes to a temporary environment. By leveraging this approach, you can ensure that the changes behave as expected, ensure that the infrastructure is provisioned and configured as intended,  and finally minimize the risk of introducing unforeseen issues or disruptions in the live system.

## Best practices

### Continuous Integration

1. **Automate Your Builds:** Automate the process of building your application whenever code changes are pushed to the repository. This ensures consistent and reproducible builds.

2. **Use Version Control:** Utilize a robust version control system (VCS) like Git to manage your codebase. Create branches for feature development and ensure proper version control practices.

3. **Run Comprehensive Tests:** Implement a suite of tests, including unit tests, integration tests, and code quality checks, as part of your CI pipeline. These tests should run automatically on every code change.

4. **Monitor and Report:** Set up monitoring and reporting tools to track the results of your CI builds. Quickly identify and address any failed builds or test cases.

5. **Parallelize Builds:** If possible, parallelize your CI builds to save time and increase efficiency. This is especially important for larger codebases.

6. **Maintain a Clean Codebase:** Encourage developers to follow coding standards and best practices. Implement code reviews to catch issues early and maintain a clean codebase.

7. **Implement Continuous Feedback:** Provide feedback to developers as soon as possible. Utilize tools like code quality reports and test coverage reports to give developers insights into the health of their code.

8. **Artifact Management**:** Store builds artifacts in a central repository for easy access and versioning. This ensures that you can deploy specific versions of your application with confidence.

### Continuous Delivery/Deployment

1. **Automate Deployments:** Automate the deployment process to eliminate manual errors and ensure consistency across environments.

2. **Immutable Infrastructure:** Consider adopting the concept of immutable infrastructure, where you replace the entire infrastructure for each deployment. This reduces configuration drift and enhances reliability.

3. **Environment Parity:** Keep development, test, and production environments as similar as possible to avoid surprises during deployment. Infrastructure as Code (IaC) tools can help achieve this.

4. **Rollback Plan:** Always have a rollback plan in place in case a deployment fails. Being able to quickly revert to a previous version is crucial for minimizing downtime.

5. **Blue-Green Deployments:** Implement blue-green deployments to reduce downtime during updates. This involves running two identical environments (blue and green) and switching traffic to the new version seamlessly.

6. **Continuous Monitoring:** Set up comprehensive monitoring and alerting to track the performance of your application in production. Detect issues proactively and respond swiftly.

7. **Deployment Pipelines:** Create deployment pipelines that include multiple stages (e.g., development, testing, staging) to ensure rigorous testing before changes reach production. You can explore different branch deployment models to optimize your pipeline approach. Check out my article on [Branch Deployment Models](https://christosgalano.github.io/branch-deployment-models/) for insights into the best approaches when deploying through pipelines.

8. **Configuration Management:** Manage configuration settings separately from code to allow for easy changes without code modifications. Tools like environment variables or configuration files can help.

9. **Security Considerations:** Include security testing as part of your CD pipeline to identify vulnerabilities early. Implement security best practices at every stage of deployment.

10. **Documentation:** Maintain clear and up-to-date documentation for your deployment processes. This helps in onboarding new team members and ensures consistent practices.

## Summary

In summary, this CI/CD guide provides essential guidelines and introduces engineers to the world of Continuous Integration and Continuous Deployment. It offers a comprehensive framework for modern software development and deployment practices, emphasizing the significance of continuous improvement, streamlined code integration, automated testing, and dependable delivery processes.

By embracing these principles and adopting best practices, teams can cultivate collaboration, enhance code quality, fortify security measures, and accelerate software releases. CI/CD isn't just a methodology; it represents a cultural shift that empowers organizations to adapt swiftly to the rapidly evolving technology landscape.

As you embark on your CI/CD journey, remember that it's not solely about reaching the final destination but equally about embracing the learning journey itself. Each step forward brings you closer to achieving excellence in software development and delivery.

## Resources

- [**The fundamentals of continuous integration in DevOps**](https://resources.github.com/devops/fundamentals/ci-cd/integration/)
- [**What is a DevOps pipeline? A complete guide**](https://resources.github.com/devops/pipeline/)
- [**Branch Deployment Models**](https://christosgalano.github.io/branch-deployment-models/)
- [**terraform-template-repo**](https://github.com/christosgalano/terraform-template-repo)
- [**devops-with-github-example**](https://github.com/christosgalano/devops-with-github-example)
