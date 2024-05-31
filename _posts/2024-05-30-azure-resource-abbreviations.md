---
title: "Azure Resource Abbreviations"
excerpt: "Efficiently manage Azure resource naming in an automated way. Keep your abbreviations up-to-date for a standardized approach."
tagline: "Keep your Azure resource abbreviations up to date"
header:
  overlay_color: "#24292f"
  teaser: /assets/images/azure/resource-abbreviations/bicep.webp
tags:
  - azure
  - iac
---

## Overview

In the ever-expanding landscape of Azure services, maintaining a coherent and standardized naming convention for resources is a familiar challenge for cloud practitioners. We've all found ourselves navigating through documentation, juggling abbreviations to ensure consistency. To simplify this common struggle, I have written a Python script. It automates the extraction of Azure resource abbreviations, ensuring a more personalized and efficient approach to managing cloud nomenclature.

## Python Script

{% highlight python %}
{% raw %}
import argparse
import json
import re

import requests
from bs4 import BeautifulSoup

def fetch_resource_abbreviations(url) -> dict[str, str]:
    response = requests.get(url)
    soup = BeautifulSoup(markup=response.text, features="html.parser")
    content_div = soup.find(name="div", attrs={"class": "content"})
    tables = content_div.find_all("table")
    data = {}
    acronyms = ("AI|IP|VM|BI|HD|DB|SQL|CDN|IoT|API|SignalR|WebPubSub|StorSimple|ExpressRoute")
    regex = r"^([A-Z][a-z]*$)|.*(?:{}).*".format(acronyms)
    for table in tables:
        rows = table.find_all("tr")
        for row in rows[1:]:
            cells = row.find_all("td")
            resource = cells[0].get_text()
            abbreviation = cells[2].get_text()
            # Ignore entries where the abbreviation is enclosed in < and >
            if not (abbreviation.startswith("<") and abbreviation.endswith(">")):
                # Split the resource string into words
                words = re.split(r"\W+", resource)
                # Convert each word to title case unless it's already in camel case
                words = [word if re.match(regex, word) else word.title() for word in words]
                # Join the words back together and remove any remaining non-alphanumeric characters
                resource = "".join(words)
                data[resource] = abbreviation
    return data

def main(file_path) -> None:
    url = "https://learn.microsoft.com/en-us/azure/cloud-adoption-framework/ready/azure-best-practices/resource-abbreviations"
    data = fetch_resource_abbreviations(url)
    with open(file=file_path, mode="w") as f:
        json.dump(obj=data, fp=f, indent=2)
        f.write("\n")

if __name__ == "__main__":
    parser = argparse.ArgumentParser()
    parser.add_argument(
        "-f",
        "--file",
        help="The path to the file where the data will be written",
        default="abbreviations.json",
    )
    args = parser.parse_args()
    main(args.file)
{% endraw %}
{% endhighlight %}

This Python script is designed to scrape a webpage for Azure resource abbreviations and save them to a JSON file.

It uses the `requests` library to fetch the webpage and `beautifulsoup4` to parse the HTML. The `fetch_resource_abbreviations function` retrieves the webpage, finds the relevant data in the HTML tables, and returns a dictionary mapping resource names to their abbreviations.

The main function calls `fetch_resource_abbreviations` and then writes the resulting data to a file. The script uses `argparse` to allow the user to specify the output file path via command line arguments. If no file path is provided, the data is written to `abbreviations.json` by default.

To run the script, you can use the following command:

{% highlight bash %}
{% raw %}
python update_resource_abbreviations.py -f ./bicep/abbreviations.json
{% endraw %}
{% endhighlight %}

## Example Output

<details>
  <summary>abbreviations.json</summary>
{% highlight json %}
{% raw %}
{
  "AISearch": "srch",
  "AzureAIServicesMultiServiceAccount": "aisa",
  "AzureAIVideoIndexer": "avi",
  "AzureMachineLearningWorkspace": "mlw",
  "AzureOpenAIService": "oai",
  "BotService": "bot",
  "ComputerVision": "cv",
  "ContentModerator": "cm",
  "ContentSafety": "cs",
  "CustomVisionPrediction": "cstv",
  "CustomVisionTraining": "cstvt",
  "DocumentIntelligence": "di",
  "FaceAPI": "face",
  "HealthInsights": "hi",
  "ImmersiveReader": "ir",
  "LanguageService": "lang",
  "SpeechService": "spch",
  "Translator": "trsl",
  "AzureAnalysisServicesServer": "as",
  "AzureDatabricksWorkspace": "dbw",
  "AzureDataExplorerCluster": "dec",
  "AzureDataExplorerClusterDatabase": "dedb",
  "AzureDataFactory": "adf",
  "AzureDigitalTwinInstance": "dt",
  "AzureStreamAnalytics": "asa",
  "AzureSynapseAnalyticsPrivateLinkHub": "synplh",
  "AzureSynapseAnalyticsSQLDedicatedPool": "syndp",
  "AzureSynapseAnalyticsSparkPool": "synsp",
  "AzureSynapseAnalyticsWorkspaces": "synw",
  "DataLakeStoreAccount": "dls",
  "DataLakeAnalyticsAccount": "dla",
  "EventHubsNamespace": "evhns",
  "EventHub": "evh",
  "EventGridDomain": "evgd",
  "EventGridSubscriptions": "evgs",
  "EventGridTopic": "evgt",
  "EventGridSystemTopic": "egst",
  "HDInsightHadoopCluster": "hadoop",
  "HDInsightHbaseCluster": "hbase",
  "HDInsightKafkaCluster": "kafka",
  "HDInsightSparkCluster": "spark",
  "HDInsightStormCluster": "storm",
  "HDInsightMlServicesCluster": "mls",
  "IoTHub": "iot",
  "ProvisioningServices": "provs",
  "ProvisioningServicesCertificate": "pcert",
  "PowerBIEmbedded": "pbi",
  "TimeSeriesInsightsEnvironment": "tsi",
  "AppServiceEnvironment": "ase",
  "AppServicePlan": "asp",
  "AzureLoadTestingInstance": "lt",
  "AvailabilitySet": "avail",
  "AzureArcEnabledServer": "arcs",
  "AzureArcEnabledKubernetesCluster": "arck",
  "BatchAccounts": "ba",
  "CloudService": "cld",
  "CommunicationServices": "acs",
  "DiskEncryptionSet": "des",
  "FunctionApp": "func",
  "Gallery": "gal",
  "HostingEnvironment": "host",
  "ImageTemplate": "it",
  "ManagedDiskOs": "osdisk",
  "ManagedDiskData": "disk",
  "NotificationHubs": "ntf",
  "NotificationHubsNamespace": "ntfns",
  "ProximityPlacementGroup": "ppg",
  "RestorePointCollection": "rpc",
  "Snapshot": "snap",
  "StaticWebApp": "stapp",
  "VirtualMachine": "vm",
  "VirtualMachineScaleSet": "vmss",
  "VirtualMachineMaintenanceConfiguration": "mc",
  "VMStorageAccount": "stvm",
  "WebApp": "app",
  "AksCluster": "aks",
  "AksSystemNodePool": "npsystem",
  "AksUserNodePool": "np",
  "ContainerApps": "ca",
  "ContainerAppsEnvironment": "cae",
  "ContainerRegistry": "cr",
  "ContainerInstance": "ci",
  "ServiceFabricCluster": "sf",
  "ServiceFabricManagedCluster": "sfmc",
  "AzureCosmosDBDatabase": "cosmos",
  "AzureCosmosDBForApacheCassandraAccount": "coscas",
  "AzureCosmosDBForMongoDBAccount": "cosmon",
  "AzureCosmosDBForNoSQLAccount": "cosno",
  "AzureCosmosDBForTableAccount": "costab",
  "AzureCosmosDBForApacheGremlinAccount": "cosgrm",
  "AzureCosmosDBPostgreSQLCluster": "cospos",
  "AzureCacheForRedisInstance": "redis",
  "AzureSQLDatabaseServer": "sql",
  "AzureSQLDatabase": "sqldb",
  "AzureSQLElasticJobAgent": "sqlja",
  "AzureSQLElasticPool": "sqlep",
  "MariaDBServer": "maria",
  "MariaDBDatabase": "mariadb",
  "MySQLDatabase": "mysql",
  "PostgreSQLDatabase": "psql",
  "SQLServerStretchDatabase": "sqlstrdb",
  "SQLManagedInstance": "sqlmi",
  "AppConfigurationStore": "appcs",
  "MapsAccount": "map",
  "SignalR": "sigr",
  "WebPubSub": "wps",
  "AzureManagedGrafana": "amg",
  "APIManagementServiceInstance": "apim",
  "IntegrationAccount": "ia",
  "LogicApp": "logic",
  "ServiceBusNamespace": "sbns",
  "ServiceBusQueue": "sbq",
  "ServiceBusTopic": "sbt",
  "ServiceBusTopicSubscription": "sbts",
  "AutomationAccount": "aa",
  "ApplicationInsights": "appi",
  "AzureMonitorActionGroup": "ag",
  "AzureMonitorDataCollectionRules": "dcr",
  "Blueprint": "bp",
  "BlueprintAssignment": "bpa",
  "DataCollectionEndpoint": "dce",
  "LogAnalyticsWorkspace": "log",
  "LogAnalyticsQueryPacks": "pack",
  "ManagementGroup": "mg",
  "MicrosoftPurviewInstance": "pview",
  "ResourceGroup": "rg",
  "TemplateSpecsName": "ts",
  "AzureMigrateProject": "migr",
  "DatabaseMigrationServiceInstance": "dms",
  "RecoveryServicesVault": "rsv",
  "ApplicationGateway": "agw",
  "ApplicationSecurityGroupAsg": "asg",
  "CDNProfile": "cdnp",
  "CDNEndpoint": "cdne",
  "Connections": "con",
  "DnsForwardingRuleset": "dnsfrs",
  "DnsPrivateResolver": "dnspr",
  "DnsPrivateResolverInboundEndpoint": "in",
  "DnsPrivateResolverOutboundEndpoint": "out",
  "Firewall": "afw",
  "FirewallPolicy": "afwp",
  "ExpressRouteCircuit": "erc",
  "ExpressRouteGateway": "ergw",
  "FrontDoorStandardPremiumProfile": "afd",
  "FrontDoorStandardPremiumEndpoint": "fde",
  "FrontDoorFirewallPolicy": "fdfp",
  "FrontDoorClassic": "afd",
  "IPGroup": "ipg",
  "LoadBalancerInternal": "lbi",
  "LoadBalancerExternal": "lbe",
  "LoadBalancerRule": "rule",
  "LocalNetworkGateway": "lgw",
  "NatGateway": "ng",
  "NetworkInterfaceNic": "nic",
  "NetworkSecurityGroupNsg": "nsg",
  "NetworkSecurityGroupNsgSecurityRules": "nsgsr",
  "NetworkWatcher": "nw",
  "PrivateLink": "pl",
  "PrivateEndpoint": "pep",
  "PublicIPAddress": "pip",
  "PublicIPAddressPrefix": "ippre",
  "RouteFilter": "rf",
  "RouteServer": "rtserv",
  "RouteTable": "rt",
  "ServiceEndpointPolicy": "se",
  "TrafficManagerProfile": "traf",
  "UserDefinedRouteUdr": "udr",
  "VirtualNetwork": "vnet",
  "VirtualNetworkGateway": "vgw",
  "VirtualNetworkManager": "vnm",
  "VirtualNetworkPeering": "peer",
  "VirtualNetworkSubnet": "snet",
  "VirtualWan": "vwan",
  "VirtualWanHub": "vhub",
  "AzureBastion": "bas",
  "KeyVault": "kv",
  "KeyVaultManagedHsm": "kvmhsm",
  "ManagedIdentity": "id",
  "SshKey": "sshkey",
  "VpnGateway": "vpng",
  "VpnConnection": "vcn",
  "VpnSite": "vst",
  "WebApplicationFirewallWafPolicy": "waf",
  "WebApplicationFirewallWafPolicyRuleGroup": "wafrg",
  "AzureStorSimple": "ssimp",
  "BackupVaultName": "bvault",
  "BackupVaultPolicy": "bkpol",
  "FileShare": "share",
  "StorageAccount": "st",
  "StorageSyncServiceName": "sss",
  "AzureLabServicesLabPlan": "lp",
  "VirtualDesktopHostPool": "vdpool",
  "VirtualDesktopApplicationGroup": "vdag",
  "VirtualDesktopWorkspace": "vdws",
  "VirtualDesktopScalingPlan": "vdscaling"
}
{% endraw %}
{% endhighlight %}
</details>

## Usage with Bicep

To use the produced JSON file in a Bicep file, you can load the file's contents into a variable and use it to generate resource names.

{% highlight terraform %}
{% raw %}
@sys.description('Abbreviations for resource names.')
# disable-next-line no-unused-vars
var abbreviations = sys.loadJsonContent('./abbreviations.json')

// usage: "${abbreviations.<resource_name>}"
{% endraw %}
{% endhighlight %}

If you use an editor like Visual Studio Code with the Bicep extension, you can use the `abbreviations` variable to generate resource names with IntelliSense.

![abbreviations-1](/assets/images/azure/resource-abbreviations/abbreviations-1.webp)

![abbreviations-2](/assets/images/azure/resource-abbreviations/abbreviations-2.webp)

## Usage with Terraform

To use the produced JSON file in a Terraform file, you can load the file's contents into a local variable and use it to generate resource names.

{% highlight terraform %}
{% raw %}
locals {
  abbreviations = jsondecode(file("${path.module}/abbreviations.json"))
}

# usage: "${local.abbreviations.<resource_name>}"
{% endraw %}
{% endhighlight %}

## GitHub Actions

You can automate the process of updating the abbreviations JSON file by using GitHub Actions. Here's an example workflow that runs the Python script on a schedule and creates a pull request if the file has changed.

{% highlight yaml %}
{% raw %}
# File: update-resource-abbreviations.yaml

name: Update Resource Abbreviations

on:
  schedule:
    - cron: '0 6 ** 1'  # Runs at 06:00, only on Monday
  workflow_dispatch:

concurrency:
  group: ${{ github.workflow }}
  cancel-in-progress: true

jobs:
  update-abbreviations:
    runs-on: ubuntu-latest
    permissions:
      issues: write
      contents: write
      pull-requests: write
    steps:
      - name: Check out code
        uses: actions/checkout@v4

      - name: Set up Python
        uses: actions/setup-python@v5
        with:
          python-version: '3.x'

      - name: Install dependencies
        run: |
          python -m pip install --upgrade pip
          pip install requests beautifulsoup4

      - name: Run update script
        run: python ./.github/scripts/update_resource_abbreviations.py -f ./bicep/abbreviations.json

      - name: Check for changes
        id: git-diff
        run: |
          change=false
          if git status --porcelain | grep -E 'bicep/abbreviations.json'; then
            change=true
          fi
          echo "changed=$change" >> $GITHUB_OUTPUT

      - name: Create/Update branch and commit changes
        if: steps.git-diff.outputs.changed == 'true'
        env:
          BRANCH_NAME: update-resource-abbreviations
        run: |
          git pull origin main
          git switch ${{ env.BRANCH_NAME }} || git switch -c ${{ env.BRANCH_NAME }}
          git config --global user.name 'GitHub Actions'
          git config --global user.email 'github-actions[bot]@users.noreply.github.com'
          git add bicep/abbreviations.json
          git commit -m 'Update resource abbreviations'
          git push --set-upstream origin ${{ env.BRANCH_NAME }}

      # Make sure to enable *Allow GitHub Actions to create and approve pull requests* under Settings > Actions
      - name: Create pull request
        if: steps.git-diff.outputs.changed == 'true'
        env:
          GITHUB_TOKEN: ${{ secrets.GITHUB_TOKEN }}
          BRANCH_NAME: update-resource-abbreviations
        run: |
          gh pr create \
          --base ${{ github.ref_name }} \
          --head ${{ env.BRANCH_NAME }} \
          --title "Update resource abbreviations" \
          --body "Automated changes by GitHub Actions regarding the *bicep/abbreviations.json* file."
{% endraw %}
{% endhighlight %}

![pull-request-1](/assets/images/azure/resource-abbreviations/pull-request-1.webp)

![pull-request-2](/assets/images/azure/resource-abbreviations/pull-request-2.webp)

## Summary

Automating the extraction and maintenance of Azure resource abbreviations with this Python script enhances efficiency and consistency in resource naming practices. By keeping abbreviations up-to-date, developers and cloud practitioners can ensure clarity and conformity in resource naming conventions, contributing to a well-organized and easily understandable Azure infrastructure.

## Resources

- [**Resource Abbreviations**](https://learn.microsoft.com/en-us/azure/cloud-adoption-framework/ready/azure-best-practices/resource-abbreviations)
