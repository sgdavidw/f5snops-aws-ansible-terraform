Task 0 - Prerequisites
----------------------

.. important:: Your student account, decryption password and IP address of the BigIQ License Server will be announced at the start of the lab.

Though the environment runs on a shared AWS account, every student wil build and work in a dedicated AWS VPC.

For this lab, a Ravello Windows 10 remote desktop jump host and Linux web based shell will be provided as a consistent starting point. [access instructions here].

Alternatively, you can run the lab from any laptop or workstation with:

- a working installation of docker on any operating system
- an Internet connection
- a web browser compatible with the aws web console. Any of the aws supported browsers will do:
  https://aws.amazon.com/premiumsupport/knowledge-center/browsers-management-console/

1. Install Docker:

   - Mac:
     https://docs.docker.com/docker-for-mac/

   - Linux:
     https://docs.docker.com/engine/installation/

   - Windows:
     https://docs.docker.com/docker-for-windows/install/

.. warning:: Docker for Windows is based on Microsoft Hyper-V and will disable VMWware Workstation if running on the same machine. If you have VMWare Workstation, do not install Docker for Windows. Stick to the webshell.

2. Access to the lab is restriced by source IP address. Confirm your source IP address:

   - http://www.ipchicken.com
   - http://www.iplocation.net
   - http://www.whatismyip.com

Task 1 - Prepare the F5-Super-Netops container, create your AWS lab account, and build the AWS lab environment
--------------------------------------------------------------------------------------------------------------

Let's asssume:

- Student account name = "user01@f5.io"
- Decryption password = "green-eggs-and-ham"
- Big-IQ License Manager = "null" because it's not used.

1. From the lab web shell, pull down the f5-super-netops container image, launch the super-netops docker container in interactive mode, map port 22 on the container with 2222 on the host, and port 80 on the container with 8080 on the host, then name the container with your username.

Cut and past the command below to accomplish the steps above. Replace "user01" with the userXX assigned to you.

.. code-block:: bash

   docker run -p 8080:80 -p 2222:22 -it --name user01 f5devcentral/f5-super-netops-container:base

2. Once the build scripts complete and you're at the root bash prompt [root@f5-super-netops] [/] #, dettach from the running container by pressing <CTRL> + P + Q. This will drop you back down to the Bash shell. From here, check that your container is running, and ssh to the running container.

.. code-block:: bash

   docker ps
   ssh -p 2222 snops@localhost

...password is "default".

Switch to root:

su -

...password is "default".

2. Export your student account and decryption password variables. Your student account will be used to create an AWS console login as well as to tag all of the objects created in AWS so you can quickly identify them when when working in the AWS web console. The decryption password will be used to grant access to the shared aws account both via the AWS API and as the password for the AWS web console. Replace the emailid and decryptPassword values below with the student account name and decryption password assigned to you at the start of the lab.

.. code-block:: bash

export emailid=user01@f5.io
export decryptPassword=green-eggs-and-ham
export

...confirm the exported variables are correct.

3. Create an AWS account and other onboarding steps:

- Change to your home directory. 
- Clone the git repository for this lab.
- Change to the working directory.
- Run the start script.

Cut and paste the commands below to accomplish the steps above.
   
.. code-block:: bash

   cd ~
   git clone https://github.com/TonyMarfil/marfil-f5-terraform
   cd ~/marfil-f5-terraform/
   source ./start

.. attention:: For a smooth ride, always invoke commands as root, from inside the cloned git repository. To check you're in the right place:

.. code-block:: bash
   
   pwd

...output should read "/root/marfil-f5-terraform"


4. Invoke terraform. If the IP address of the Big-IQ License Manager has been provided for you at the beginning of the lab, enter it when prompted for "Management IP address of the BigIQ License Manager". Otherwise, we will use utility licenseing and so enter "null".

.. code-block:: bash

   terraform plan

   terraform apply

5. Once "terraform apply" completes, you can test your web server instances and ELB are up:

.. code-block:: bash

   while :; do curl `terraform output elb_dns_name`; sleep 1; done

You should see a reply 'Hello, World'. Hit <ctrl>+C to stop.

When 'terraform apply' completes, note the \*\*aws_alias\*\* and vpc-id values. Open up your \*\*aws_alias\*\* link in a browser and login to the AWS console with the email address and password you created during the install. You can always get these values by invoking terraform output with the variable name:

.. code-block:: bash

   terraform output **aws_alias**
   terraform output vpc-id

.. warning:: terraform apply will take five minutes to complete, but the environment will not be ready for another 15 minutes as the Big-IP virtual editions and supporting infrastructure wake up. In the meantime, we can begin to explore the AWS lab environment.

=================================

Task 2 - Login to the AWS console and explore the F5 / AWS lab environment
--------------------------------------------------------------------------

CloudFormation templates is the AWS backed decalarative way to deploy full application stacks to AWS. F5 Virtual Edition can be deployed via CloudFormation Templates and are fully supported by the support organization. (You can open a ticket and 

- Auto scaling the BIG-IP VE Web Application Firewall in AWS:

 https://github.com/F5Networks/f5-aws-cloudformation/tree/master/supported/solutions/autoscale/waf/

.. image:: ./images/config-diagram-autoscale-waf.png

- ...and the experimental version of "Deploying the BIG-IP in AWS - Clustered 2-NIC across Availability Zones" which supports automatic Big-IQ Licensing:

 https://github.com/F5Networks/f5-aws-cloudformation/tree/master/supported/cluster/2nic/across-az-ha

.. image:: ./images/aws-2nic-cluster-across-azs.png

2. Track things are going well in the AWS management console: Services => Management Tools => CloudFormation template. When done, both of your deployed CloudFormation templates will be Status: CREATE_COMPLETE.

#. Use the alias aws console link, email address and password you created earlier to login to the aws console. Navigate to Services => Networking & Content Delivery => VPC. Click on # VPCs. In the search field type your user account name. You should see your VPC details. VPC stands for virtual private cloud, this is the slice of the amazon cloud that has been dedicated for your lab environment.

# In the upper right hand corner, ensure you are in the N. Virginia region (us-east-1).

#. Services => Compute => EC2 => Resources => # Running Instances. In the search filter enter your username. You should see your newly created EC2 instances running.

#. The web application is hosted on webaz1.0 in one availability zone and webaz2.0 in another availability zone. Highlight web-az1.0, in the "Description" tab below note the availability zone. Highlight web-az2.0 and do the same.

#. Three Big-IP virtual editions are running:

  - BIGIP1 and BIGIP2 are in a cross availability zone cluster that was deployed via a CloudFormation template.
  - BIG-IP Autoscale Instance is the first F5 web application firewall Big-IP Virtual Edition provisioned for Application Security Manager. Depending on configurable traffic thresholds the WAF will scale from 1 to N instances. These threholds are controlled via an auto scale group policy...

5. Cloud-init. Version 13 of Big-IP supports cloud-init. Right click on BIGIP1 => Instance Settings => View/Change User Data. Cloud-init is the industry standard way to inject commands into an F5 cloud image to automate all aspects of the on-boarding process: https://cloud-init.io/.

#. Services => Compute => EC2 => AUTO SCALING => Auto Scaling Groups.
   - In the search filter enter your username. Highlight the waf... auto scaling group.
   - Under the "Scaling Policies" tab below review the policy for scaling up and scaling down.

#. Services => Compute => EC2 => LOAD BALANCING => Load Balancers. In the search filter enter your username. You should see your newly created elastic load balancers running.
  - Choose the tf-elb-userXX load balancer and highlight the "Instances" tab below. This is the load balancer that is in front of your simple web application hosted on web-az1.0 and web-az2.0.
  - Choose the waf-userXX load balancer and highlight the "Instances" tab below. This is the load balancer that is in front of your F5 web application firewall(s). 

#. GitHub. Fully supported F5 Networks Solutions are hosted in the official F5 Networks GitHub repository:
   - https://github.com/f5networks
   - We are running the lab from the f5-super-devops container: https://github.com/f5devcentral/f5-super-netops-container
   - AWS CloudFormation templates: https://github.com/F5Networks/f5-aws-cloudformation

#. We used terraform to trigger two CloudFormation templates:

  - Auto scaling the BIG-IP VE Web Application Firewall in AWS:

   https://github.com/F5Networks/f5-aws-cloudformation/tree/master/supported/solutions/autoscale/waf/

.. image:: ./images/config-diagram-autoscale-waf.png

  - ...and the experimental version of "Deploying the BIG-IP in AWS - Clustered 2-NIC across Availability Zones" which supports automatic Big-IQ Licensing:

   https://github.com/F5Networks/f5-aws-cloudformation/tree/master/supported/cluster/2nic/across-az-ha

.. image:: ./images/aws-2nic-cluster-across-azs.png

#. From the AWS management console: Services => Management Tools => CloudFormation template. Both of your deployed CloudFormation templates will be Status: CREATE_COMPLETE. Here you can expand and review the steps or troubleshoot if something went wrong.

Task 4 - Verify a healthy F5 environment
----------------------------------------

1. Find the public IP management address of the three BigIP instances that we created. Let's confirm they're up.

.. code-block:: bash

   ssh -i ./MyKeyPair-[email address].pem admin@[public ip address or DNS name of autoscale waf bigip]

2. Verify the auto-scale WAF is up and the virtual server is up. 

.. code-block:: bash

   modify /auth password admin
   # enter [mylabpass] when prompted
   save sys config
   show ltm virtual-address

3. Login to the AWS Console and find the DNS name of the WAF autoscale load balancer. Services => EC2 => Load Balancers. Filter with your email address. Under the Description tab beneath look for the \*DNS name.

4. From the f5-super-netops container test our https service is up:

.. code-block:: bash

   curl -k https://waf-x-x.us-east-1.elb.amazonaws.com where waf-x-x is the dns name you noted in the AWS console.
   Hello, World

.. code-block:: bash

   ssh -i ./MyKeyPair-[email address].pem admin@[public ip address of primary cross-az hav bigip]

.. code-block:: bash

   modify auth user admin password mylabpass
   save sys config

Task 5 - Deploy a virtual server on a BigIP Cluster across two Availability Zones
----------------------------------------------------------------------------------

1. Navigate to AWS Console -> Services -> EC2 -> Running Instances. Note the IPv4 Public IP addresses for the two instances named: "Big-IP: f5-cluster"

2. Highlight the primary Big-IP : f5-cluster. In the Description tab, note the first assigned Elastic IP, this is the public management IP address. Note the Secondary private IP. This is the IP to be assigned to the virtual server we will soon configure.

3. Highlight the second Big-IP : f5-cluster. In the Description tab, note the first assigned Elastic IP, this is the public management IP address. note the Secondary private IP. This is the IP to be assigned to the virtual server we will soon configure.

4. Use MyKeyPair-[email address].pem generated previously to ssh to the management IP address of the BigIPs noted in steps 3 and 4 above.

5. Create an admin password so you can login to the configuration utility (web ui).

.. code-block:: bash

   modify auth user admin password mylabpass
   save sys config

6. Login to the active BigIP configuration utility (web ui).

7. The "HA_Across_AZs" iApp will already be deployed in the Common partition.

8. Download the latest iApp package from https://downloads.f5.com. I tested with iapps-1.0.0.455.0.zip.

9. Extract \iapps-1.0.0.455.0\TCP\Release_Candidates\f5.tcp.v1.0.0rc2.tmpl. This is the tested version of the iApp.

10. Import f5.tcp.v1.0.0rc2.tmpl to the primary BigIP. The secondary BigIP should pick up the configuration change automatically.

11. Deploy an iApp using the f5.tcp.v1.0.0rc2.tmpl template.

12. Configure iApp:

    Select "Advanced" from "Template Selection"

    Traffic Group: UNCHECK "Inherit traffic group from current partition / path"

    Name: **vs1**

    High Availability. What IP address do you want to use for the virtual server? **Secondary private IP address of the first BigIP.**

.. note:: The preconfigured HA_Across_AZs iApp has both IP addresses for the virtual servers prepopulated. The virtual server IP address configured here must match the virtual server IP address configured in the HA_Across_AZs iApp.

   What is the associated service port? **HTTP(80)**

   What IP address do you wish to use for the TCP virtual server in the other data center or availability zone? **Secondary private IP address of the second BigIP.**

.. note:: The preconfigured HA_Across_AZs iApp has both IP addresses for the virtual servers prepopulated. The virtual server IP address configured here must match the virtual server IP address configured in the HA_Across_AZs iApp.

   Which servers are part of this pool? **Private IP address of web-az1.0 and web-az2.0.** Port: **80**

   **Finished!**

13. Login to the standby BigIP configuration utility (web ui) and confirm the changes are in sync.

14. Confirm the virtual server is up!

.. code-block:: bash

   curl http://52.205.85.86


   StatusCode        : 200
   StatusDescription : OK
   Content           : Hello, World
   ...


Stop the active BigIP instance in AZ1 via the AWS console and the elastic IP will 'float' over to the second BigIP.

Task 7 - Application Services iApp, Service Discovery iApp, and Ansible! Deploy http virtual server with iRule for 0-day attack.
--------------------------------------------------------------------------------------------------------------------------------

- Under development
- Deploy the Service Discovery iApp and use tags to automatically create and populate F5 BigIP pools.
- Deploy the previous task's iApp programmatically via Ansible.
- Deploy http virtual server with iRule for 0-day attack with Application Services iApp.

Task 8 - Enable Bot protection and autoscale WAF
------------------------------------------------
- Under development

Task 9 - Nuke environment
-------------------------
1.  AWS Console -> Services -> Storage -> S3. Filter for your S3 buckets. My test email is t.marfil@f5.io so I filter on 'marfil'. Delete your two S3 buckets prefaced with ha- and waf-.

2. AWS Console => Services => Compute => EC2. Auto Scaling Groups. Filter on your email address. Same style filter as S3, no special characters. I filter on 'marfil'.

3. Click on 'Instances' tab below. Select your Instance. Actions => Instance Protection => Remove Scale In Protection.

4. From the f5-super-netops terminal:

.. code-block:: bash

   terraform destroy

5. After destroy completes, remove MyKeyPair-[email address]. From the AWS Console -> Services -> NETWORK & SECURITY -> Key Pairs -> Delete MyKeyPair-[email address].

6. Remove User. From the AWS Console -> Services -> Security, Identity & Compliance ->  IAM -> Users. Filter by email address. Delete user.

.. note:: Many thanks to Yevgeniy Brikman for his excellent *Terraform: Up and Running: Writing Infrastructure as Code 1st Edition* that helped me get started. http://shop.oreilly.com/product/0636920061939.do