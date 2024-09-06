

# Auto-Discovery-Auto-Deployment

## Project Goal 
To deploy a higly available, self-healing, scalable and secured containerised Monolithic Java application, using Jenkins pipeline in Amazon Web Services (AWS).

## Tech Stack 
* Terraform - used as infrastructure as code (IaC) 
* AWS - used for cloud infrastructure.
* Git - used as version control system, Repository
* Bastion Host - used as EC2 to manage access to cloud resources in a private subnet, a secure internal network. 
* Jenkins - used as continuous integration continuous deployment/delivery CICD tool
* SonarQube - used as code analysis tool for vulnerabilities
* Ansible - used as configuration management tool
* Docker - used as containerisation tool
* S3 Bucket - used for remote management of terraform state file
* Hashicorp Vault - used to manage database credentials
* NewRelic - used as full-stack montoring tool
* Jira/Confluence - used as work management and documentation tool


## Project Overview
This project contains a bash script for auto-discovery of new instances that are provisioned by the auto-scaling group. The IP addresses of the auto-discovered instances are echoed onto the ansible inventory file, whereupon ansible deploys the application on those discovered instances.

Each instance or server provisioned by the auto-scaling group is pre-configured in the following manner via user data during provisioning:
1. Install docker hence setup as a docker server.
2. Create a script directory and copy a script into that directory, - this script manages docker container on the EC2 instance, pulling updates from a Nexus repository.

Whenever the auto-discovery bash script is triggered via a CRON job, ansible server uses the auto-discovery script to check auto-scaling group for the new instances it has provisioned.
It is only then that the script which manages docker container on the EC2 instance is triggered, pull Nexus repository image.

Take note that auto-scaling group is in a private subnet, which is connected to via application load balancer

The Vault server is provisioned by bash script for automated management of credentials 

## Note that to be able to adapt this code or replicate this project for your personal use, you must change the following values outlined below
/*

    • In the root main file, you must change the following to your own values to be able to use this code to run your own application: 
        ◦ change the domain to your own domain under (data "aws_acm_certificate") 
        ◦ change the availability zones to values relevant to your region, under module “vpc” module avz1 and avz2 
        ◦ change ami values to the values relevant to your aws region, under module “nexus”, module “jenkins” 
        ◦ change newrelic values, nr-key, nr-acc-id, nr-region, under module “jenkins” 
        ◦ change ami values to the values relevant to your aws region, under module “prod-asg” 
        ◦ change ami-id relevant to your region, under module “bastion” 
        ◦ change ami relevant to your region, under module “sonarqube” 
        ◦ change ami values to the values relevant to your aws region, under module “stage-asg” 
        ◦ change newrelic values, newrelic-user-license, newrelic-acct-id, under module “prod-asg” and “stage-asg” 
        ◦ change domain_name, jenkins_domain_name, nexus_domain_name, sonarqube_domain_name, prod_domain_name, and stage_domain_name values to your domain, under module “route53” 
        ◦ change ami value of red_hat to ami relevant to your region, under module “ansible” 
        ◦ change new relic values, newrelic-license-key, newrelic-acct-id, under module “ansible” 
    • change within vault/main.tf region, profile(profile that you set via AWS CLI), under provider “aws” 
    • change within vault/main.tf, ami(relevant to your region), var1(region), under resource "aws_instance" "vault_server" 
    • change within vault/main.tf, name(add domain), under data "aws_route53_zone" "route53_zone" 
    • change within vault/main.tf, name(add domain), under resource "aws_route53_record" "vault_record" 
    • change within vault/main.tf, domain_name(add domain), subject_alternative_names(add domain), under resource "aws_acm_certificate" "acm-cert" 
    • change within vault/main.tf, availability_zones, under resource "aws_elb" "vault_lb" 
    • change within vault/variable.tf, default(ami), under variable "ami-ubuntu" 
    • change within backend.tf, in the main project folder, region, profile(profile that you have set via AWS CLI) 
    • change within remote_state/main.tf, region, profile, under provider “aws” 
    • change within backend.tf, region, profile, under backend “s3” 
    • change within provider.tf which is in the same directory hierarchy as the root main.tf, region, profile, token, and address (domain name) 
    • change within variable.tf which is in the same directory hierarchy as the root main.tf, default.? 
    • change the NEW_RELIC_API_KEY and NEW_RELIC_ACCOUNT_ID within modules/nexus/nexus-script.tf and modules/sonarqube/sonarqube.tf 
    Note that to get your new relic values, signup for a New Relic Account, then click to generate new key copy and save key, also copy new relic account id.

*/ 

## To Test run the application, Do the Following Shown Below:

Change directory to **remote_state directory** and run, **terraform init**, **terraform apply -auto-approve**   
Change directory to **backend.tf** which is in the same directory hierarchy as the root main.tf and run, terraform init, terraform apply -auto-approve  
Change directory to provider.tf which is in the same directory hierarchy as the root main.tf
and run, terraform init, terraform apply -auto-approve  

Go to AWS console and add your domain name to Route53, choose public hosting.
(If domain provider is different from AWS) remember to change the Name Servers links for your domain to the AWS Name Server links copied from your AWS Route53 resource.

Change directory to vault directory and run, terraform init, terraform apply -auto-approve


Next you may wish to ssh into the vault server and check if its user data is completely installed, use the command **ssh -i vault-private-key ubuntu@vault_server_ip**

Now you may wish to check the vault server terminal logs and verify that the user-data has been successfully installed use the command cat /var/log/cloud-init-output.log 

To see vault server user interface, on your brower, type vault.domain-name eg, vault.linuxclaud.com
Do not do anything yet with the browser user interface at this stage.

Establish ssh connection into the vault server, with the command, **ssh -i vault-private-key ubuntu@vault_server_ip** The server IP is present as an output value, in your terminal after you provisioned the vault server.

Now in the vault server terminal to generate vault token, run the command **vault operator init**

Copy the initial root token 

Next go to provider.tf which is in the same directory hierarchy as the root main.tf and paste the root token there.
Take note that whenever you destroy and reprovision your vault server resource, you have to do this process again.

Next in the vault server terminal run the command **vault login** and paste the initial root token you copied earlier.

Next define the secret path that was defined in the root main.tf as,

data "vault_generic_secret" "vault_secret" { 
    path = "secret/database"
}

To create this path in the vault sever, run the command, **vault secrets enable -path=secret/ kv** in the vault server terminal.


Next in the vault server terminal run the command, **vault kv put secret/database username=admin password=admin123**

To check the secret was successfully entered, in vault server terminal, type **vault kv get secret/database**

Next you can check these key value in the vault server user interface, via its domain, vault.domain-name eg, vault.linuxclaud.com
Enter the initial root token to login and click on the relevant links to see the key values that we created via the vault server terminal.

- Change directory to root main.tf, run, terraform init, terraform apply -auto-approve
    Allow about 5-10 minutes for the user data of the resources you have just provisioned to implemented on the servers.

## Updating pet-set19 branch RDS Endpoint on application.properties
Within this application repo https://github.com/CloudHight/usteam.git, 
Click on dorp down menu from main, select pet-set19 branch 
Follow this path **src/main/resources/** click on templates, then click on application.properties to get to application.properties file. 
Within this file, on line 3, change the url for this **spring.datasource.url=${MYSQL_URL:jdbc:mysql://???/petclinic}** to your RDS endpoint, 
Replace only this relevant section ???, with your RDS Endpoint, for example, **petclinic.cb4mkka6s8su.eu-west-2.rds.amazonaws.com:3306** 
Within this file, on line 4, change the username to the username you configured for the database within the Vault server, in this case, for example, **admin**
Within this file, on the line 5, change the password to the password you configured for the database within the Vault server, in this case, for example, **admin123**
This rds endpoint url can be found as one of the output parameters that were generated when you provisioned the resources of the root main.

Use the sonarqube domain name to access the sonarqube server, on your browser, type, https://sonarqube.domain-name eg  https://sonarqube.linuxclaud.com

Login to sonarqube server using the username and password defined in its module script, username=admin password=admin 
Change when prompted to username and password login credentials of your choice, it is suggested, Username=admin Password-admin123.

Click on Administration tab

Under Administration, click security, select Users, under Tokens, click the horizontal stripe selection menu, beside Administrator, in the new window that opens, Add Name **sonarqube** and click generate token, copy and save the token, to be used later.

Under Administration, click configuration, select webhooks, click on create tab.
Add Name **sonarqube**
Add URL https://jenkins.domain-name eg  https://jenkins.linuxclaud.com/sonarqube-webhook
Click create


Next from the root main terminal, ssh into Nexus server, with the command, **ssh -i petclinic-private-key ec2-user@nexus-server-ip**

In the dialogue box that appears, copy the admin password directory path, hence use the command on the nexus terminal **sudo cat /app/sonatype-work/nexus3/admin.password**

Copy the admin password characters, 

Next access the nexus server user interface on your browser, type, nexus.domain-name eg, nexus.linuxclaud.com

Click on, Sign-in

On the Nexus browser interface dialogue box, type for Username: admin and paste the password you copied in the password box.

Click Next in the dialogue box that appears

Enter password of your choice and confirm password, it is suggested, admin123

Choose disable anonymous access, and click next

Click finish

Click on the cogwheel, click on Repository in the left hand pane, then click create repository

- In the drop down list select maven2(hosted)
    Under Name, type name of choice eg, nexus-repo
    Under version policy, select mixed
    Under Deployment policy, select Allow redeploy
    Click create repository

- Next click create repository at the top pane
    In the drop down list select docker(hosted)
    Under Name, chose name of choice eg, docker-repo
    Select HTTP radio button and enter 8085 as port value
    Select HTTPS radio button and enter 443 as port value
    Under Enable Docker V1 API, select the radio button 
    Click create repository

- Next under security, click on Realms
    Double click on **Docker Bearer Token Realm**
    Click on save 

Exit Nexus terminal 

Access Jenkins via bastion host, since Jenkins is in a private subnet.
Exit connection to Nexus terminal, and establish ssh connection from the root main terminal into the bastion host using the command **ssh -i petclinic-private-key ubuntu@bastion-server-ip** 

In the bastion terminal, run the command, **ssh ec2-user@jenkins-server-ip**

To have access to Jenkins administrator password to setup Jenkins from the browser, on the Jenkins terminal run, **sudo cat /var/lib/jenkins/secrets/initialAdminPassword**

Copy the admin password string of characters

Use the Jenkins server domain name to access its user interface on your browser, type, jenkins.domain-name eg, jenkins.linuxclaud.com

Paste in the Administrator password field, the Jenkins admin password you copied 

Click on the Install suggested plugins box

Once installation is complete, in the box that appears, type to fill, Username, Password, Confirm password, Full name, E-mail address. It is suggest, admin, admin123, admin, your-email.
Then click Save and Continue

Click Save and Finish then click Start using Jenkins

## Adding Jenkins Plugins
Next return to click on manage jenkins
Click on plugins, click on available plugins

- Type ssh in the available plugins search bar and select SSH Agent radio button
- Type nexus in the available plugins search bar and select Nexus Artifact Uploader radio button
- Type maven in the available plugins search bar and select Maven Integration radio button
- Type sonar in the available plugins search bar and select SonarQube Scanner radio button
- Type slack in the available plugins search bar and select Slack Notification radio button
- Type docker in the available plugins search bar and select Docker radio button
- Type pipeline in the available plugins search bar and select Pipeline Stage View radio button
- Type owasp in the available plugins search bar and select OWASP Dependency-check radio button
Click on install

## Configuring Jenkins Tools
In the Jenkins account area that opens, click on manage jenkins, click on Tools 
Under JDK installations, click Add JDK, under Name, type **java**
Next return to your Jenkins terminal and run the command, **mvn -version**

Copy the runtime:, eg, /usr/lib/jvm/java-11-openjdk-11.0.24.0.8-2.el9.x86_64

Return to your Jenkins browser account area, in the JAVA_HOME field, paste the runtime: you copied

Page down to Maven installations, Under Maven installations, click Add Maven, Under Name, type **maven**

Next return to your Jenkins terminal and copy the path, eg, /usr/share/maven from Maven home: which came about from the mvn -version command you ran earlier.

Return to your Jenkins browser account area, in the MAVEN_HOME field, paste the path from Maven home: you copied
Click save


Next return to manage jenkins, click on Tools 
Under Docker installations, click Add docker
In the Name field type **docker**
Click install automatically radio button
In the drop down menu of Add installer, select Download from docker.com
Docker version should be latest

Under Dependency-Check installations, click Add Dependency-Check 
In the Name field type **DP-Check**
Click install automatically radio button
In the drop down menu of Add installer, select install from github.com
Select dependency check latest version
Click Apply and Save

It is important to use NVD API key, when you setup dependency check, otherwise you dependency check part of the Jenkins pipeline will run slowly.
To generate the API key from the National Vulnerability Database, use this link https://nvd.nist.gov/developers/request-an-api-key  

## Adding credentials on Jenkins
Next return to manage jenkins, click on credentials, click on global, click on Add credentials
Under New credentials, for Kind select username and password 
Scope is Global
Username is your git username 
Password is your git token generated from your github account
ID and Description, you may type git-creds
Click Create


Next Click Add credentials 
Under New credentials, for Kind select Secret text
Scope is Global 
In the Secret field enter the sonar token you generated earlier. 
ID and Description, you type **sonarqube**
Click Create


Next Click Add credentials
Under New credentials, for Kind select Secret text
Scope is Global
Secret is your nexus username eg admin
ID and Description, you may type nexus-username
Click Create


Next Click Add credentials
Under New credentials, for Kind select Secret text
Scope is Global
Secret is your nexus password eg admin123
ID and Description, you may type nexus-password
Click Create

Next Click Add credentials
Under New credentials, for Kind select Secret text
Scope is Global
Secret is your nexus repo url eg https://nexus.linuxclaud.com/  
For ID and Description, type nexus-repo

**OR For the url use, nexus server ip:8085**

Click Create

Next click Add credentials
Under New Credentials, for Kind select Username and Password
Scope is Global 
Username: eg admin, Password: eg admin123
ID and Description, type nexus-creds

## To generate slack token, before setting up slack credential
To generate token, go to Slack Apps search for Jenkins, Select Jenkins, click configuration, click Add to Slack.
Under Post to Channel field, select the channel you which to send notifications to.
Click Add Jenkins CI Integrations
Page down to the token field, copy token.
Click Save Settings

Next Click Add credentials 
Under New credentials, for Kind select Secret text
Scope is Global 

In the Secret field enter the Slack token you would have generated
For ID and Description, type slack
Click Create


Next Click Add credentials 
Under New credentials, for Kind select SSH Username with private key
Scope is Global
ID – type ansible-key
Description – ansible-key
Username – ec2-user
Under Private key, click Enter directly

Within the code files, Go to the petclinic-private-key directory which is in the same hierarchy as the root main.tf 
Copy the private key.
Click on Add, paste the private key
Click create

## To configure Jenkins System
Next return to manage jenkins, click on System 
Scroll down to Slack
Under workspace field, enter slack account username
Under Credential, select the credential description you setup earlier
Under Default channel/member id field, type the slack channel name where notifications will be sent.
Click on test connection tab, You should see Success!


Page through to SonarQube servers
Click on Environment variables radio button
Under SonarQube installations
Click Add SonarQube
In the Name field, type **sonarqube** 
In Server URL field type the sonarqube url eg, https://sonarqube.linuxclaud.com
Under Server authentication token, select **sonarqube** 
Page down, click Apply and Save 


## To setup webhook between Jenkins and Github Repository
Within Jenkins browser account, under admin drop down menu, click configure 
Under API Token, click Add new token, click Generate 
Copy the token generated, save it to be used later.
Click Apply and Save

Setup webhook in your github account,
Click settings in the usteam repository page, click webhook
Use jenkins url eg, http://jenkins.linuxclaud.com/github-webhook
Paste the Jenkins API token generated in the Secret field

## Getting Application Repo and Updating Jenkins Pipeline Script File
Fork the usteam repository from this link, https://github.com/sammyutere/usteam.git  
You must uncheck the box fork only main
Click on main drop down menu and select the branch pet-set19
The Jenkins file path is, usteam/ pet-set19 branch, then under target click on Jenkins file 
Within the Jenkinsfile, at the far top right, click on the edit pen,
Change ansible ip and other parameters in the Jenkins file as follows:

Line 52 to your domain name for example, nexus.linuxclaud.com
Line 82 to the IP address of your ansible server
Line 89 to your domain name for example, https://stage.linuxclaud.com
Line 91 to your domain name for example, https://stage.linuxclaud.com
Line 110 to the IP address of your ansible server 
Line 117 to your domain name for example, https://prod.linuxclaud.com
Line 119 to your domain name for example, https://prod.linuxclaud.com

## Setting up Jenkins Pipeline
Go to Jenkins, Click Dashboard, Click New item
Enter item Name
Click Pipeline,
Click ok
In the window that apears, Under build triggers, select **Github hook trigger for GitScm pooling**
In the window that appears, Under pipeline, select Pipeline script from SCM
Under SCM, select git
In Repository URL type for example https://github.com/sammyutere/usteam.git 
For Credentials select git-creds
In Branch Specifier, type, */pet-set19
In Script Path, type, Jenkinsfile
Click Apply Save
Click Build Now

For NewRelic - secret text - API key
In the pet-set19 branch in line 14 of the docker file, ensure you enter your own NewRelic license key 

*/

