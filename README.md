
# Overview

Setup CI/CD Pipeline for Building terraform and Ensuring Quality Releases of a Python web application.

## Details

The 'Ensuring Quality Releases' project is part of the 'DevOps Engineer for Microsoft Azure' nanodegree program from [Udacity](https://udacity.com) :

* Use Terraform to create the following resources for a specific environment tier:
  1. AppService
  2. Network
  3. Network Security Group
  4. Public IP
  5. Resource Group
  6. Linux VM

* Use Azure DevOps CI/CD pipeline:
  1. Create the tasks that allow for Terraform to run and create the above resources
![pycharm1](imgs/browser-1-report-teraform.PNG)
![pycharm1](imgs/browser-2-report-teraform.PNG)
  2. Publish a package called FakeRestAPI as an artifact
![pycharm1](imgs/browser-deployment-api.PNG)
![pycharm1](imgs/browser-test.PNG)
  3. Execute Test Suites for Postman
![pycharm1](imgs/browser-1-report-postman-test.PNG)
![pycharm1](imgs/browser-2-report-postman-test.PNG)
  3. Publish Newman Result
![pycharm1](imgs/browser-1-report-newman-publish.PNG)
![pycharm1](imgs/browser-2-report-newman-publish.PNG)
![pycharm1](imgs/browser-3-report-newman-publish.PNG)
  4. Execute Test Suites for Selenium
![pycharm1](imgs/browser-1-report-selenium-test.PNG)
![pycharm1](imgs/browser-2-report-selenium-test.PNG)
  5. Execute Test Suites for JMeter
![pycharm1](imgs/browser-1-report-jmeter-test.PNG)
![pycharm1](imgs/browser-2-report-jmeter-test.PNG)
![pycharm1](imgs/browser-3-report-jmeter-endurance-test.PNG)
![pycharm1](imgs/browser-3-report-jmeter-stress-test.PNG)
* Set up email alerting for the app service
![pycharm1](imgs/outlook-rule.PNG)
![pycharm1](imgs/outlook-alert.PNG)
![pycharm1](imgs/graph-rule.PNG)
* Set up log analytics
![pycharm1](imgs/log-analytics.PNG)
![pycharm1](imgs/log-analytics-app-service.PNG)
* Set up custom logging in log analytics
![pycharm1](imgs/log-analytics-custom-selenium.PNG)

## Instructions

#### Create the service principal

Login to azure

```
az login
```

Create a service principal for terraform

```
​az ad sp create-for-rbac --query "{​​​​​ client_id: appId, client_secret: password, tenant_id: tenant }​​​​​"
```

#### Create and run the pipeline

Open [azure devops](https://dev.azure.com/) and create a new project

Go to **Project Settings** > **Service Connections** > **New Service Connection** > **Azure Resource Manager** > **Next** > **Service Principal (Automatic)** > **Next** > **Subscription**

Choose your subscription and fill the name of service connection

Create a pipeline connected to github and select this repo. The [azure-pipelines.yml](azure-pipelines.yml)

Go to **Pipelines** > **Library** > **Seure files**

Import your ssh publickey.pub and terraform.tfvars with the infos below

1. **subscription_id** - the azure subscription ID
2. **client_id** - the appid of the service principal
3. **client_secret** - the password of the service principal
4. **tenant_id** - the azure tenant ID
5. **location** - the region to create the azure resources in
6. **resource_group** - the name of the resource group to create the app service and VM
7. **application_type** - this name has to be globally unique
8. **virtual_network_name** - ths name of the virtual network
9. **address_space** - the address space
10. **address_prefix_test** - the address prefix

Run the pipeline. On the first run it will fail deployment. This is because we need to manually configure the VM to allow the pipeline to connect to it

Go to **Pipelines** > **Environments**. Click your environment > **Add Resource** > **Virtual Machines** > **Next**. Select **Linux** operating system. Copy the registration script to the clipboard

Connect SSH to the VM using public IP of the VM

```
ssh adminuser@public_ip
```

Paste the registration script into the terminal. Select Y for tags, write TEST, Select Y for unzip. The VM can now be managed by the pipeline. Re-run the failed job. The pipeline run should complete successfully

* Set up email alerting for the app service

In the azure portal go to the app service > **Alerts** > **New Alert Rule**. Add an HTTP 404 condition and add a threshold value of 1. This will create an alert if there are two or more consecutive 404 alerts. Click **Done**.

Create an action group with notification type **Email/SMS message/Push/Voice** and choose the email option. Set the alert rule name and severity

Visit the URL of non-existent page of the app service more than once it should trigger the email alert

* Set up log analytics

Go to the app service > **Diagnostic Settings** > **+ Add Diagnostic Setting**. Tick **AppServiceHTTPLogs** and **Send to Log Analytics Workspace**. Select a workspace > **Save**

Go back to the app service > **App Service Logs**. Turn on **Detailed Error Messages** and **Failed Request Tracing** > **Save**

Restart the app service

Go to the log analytics workspace > **Logs**. Run the following query

```
AppServiceHTTPLogs
| where TimeGenerated > ago(2h)
| summarize count() by TimeGenerated, CsHost, Result,Type, CsMethod, ScStatus
```

This should show some log results

* Set up custom logging

In the log analytics workspace go to **Advanced Settings** > **Data** > **Custom Logs** > **Add +** > **Choose File**

Select the file  **[selenium.txt](automatedtesting/selenium/selenium.txt)** > **Next** > **Next**

Put in the following paths as type **Linux**:
1. /var/log/selenium/selenium.txt
2. /var/log/selenium
3. /var/log/selenium/*.txt

Give it a name and click **Done**. Tick the box **Apply below configuration to my linux machines**.

Go back to the log analytics workspace > **Virtual Machines**. Click your VM > **Connect**. This will install the agent on the VM, allowing azure to collect logs from it

Go back to the log analytics workspace > **Logs**. From the **Custom Logs** dropdown double-click the custom log just created and run the query. You should see the selenium logs
