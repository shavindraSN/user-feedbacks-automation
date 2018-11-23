# user-feedbacks-automation
This repository contain scripts for user-feedbacks application infrastructure automation and application deployment using Terraform

## Content 

1. Architecture Diagram
2. Pre-Requisites  and Setup
3. Resources
4. Process

### 1. Architecture Diagram
This application is used AWS commonly known **Scenario 2** setup
![alt text](https://docs.aws.amazon.com/vpc/latest/userguide/images/nat-gateway-diagram.png)

### 2. Pre-Requisites and setup
1. Clone this repository
2. Mac or Linux OS with Bash support
3. AWS Account
4. IAM user with Access key and Secret Key
5. Add your Access keys and Secret Keys to **terraform.tfvars** file
6. Plan the automation. Run following command inside the **user-feedbacks-automation** directory
```console
foo@bar:user-feedbacks-automation $ terraform plan  --var-file="../tfvars/terraform.tfvars"
```
7. Apply the changes
```console
foo@bar:user-feedbacks-automation $ terraform apply  --var-file="../tfvars/terraform.tfvars" -auto-approve
```

### 3. Resources

Following resources will be created with these terraform scripts
1. VPC
2. Private and Public Subnet
3. NAT Gateway
4. Internet Gateway
5. 2 Route Tables
6. 2 Route Table associations
7. 3 Security Groups (Public ELB, Public Instance, Private)
8. RDS Endpoint
9. S3 Bucket to store application package
10. Elastic Beanstalk Instance
11. Elastic Load Balancer

### 4. Process
In this section Deployment flow will be described
1. VPC is created.
2. Create Public and Private subnets.
3. Internet Gateways is created and connected with Public subnet to communicate with the Internet.
4. NAT Gateways is created and connected to private subnet to provide connectivity to Internet and other AWS Services while avoiding Internet initiating connections.
5. Create Security Groups for Load Balancer, Elastic Beanstalk application and RDS service.
6. Provision RDS instance and write the **End Point** details to .env file of the application. This will enable application to communicate with the database.
7. Application code is zipped.
7. Create S3 Bucket and upload the package .zip file
9. Provision Elastic Beanstalk Service with the .zip of the application code uploaded to S3.
10. At the end of the execution of all terraform scripts, CName for the Beanstalk application will be displayed.