# Mac Lab

## Overview

Mac Lab is a simple terraform template creating a customizable Mac OS lab for security testing and Apple developer use cases.  It automatically builds a Mac mini computer attached through Thunderbolt to the AWS Nitro system.  From Amazon, "There is no hypervisor involved, and you get full bare metal performance of the underlying Mac mini.  An EC2 dedicated host reserves a Mac mini for your usage."

* A Mac mini running on M2 but can be customized for Intel, M1, or M2 Pro.
* A dedicated host running on a bare metal server connected to AWS Nitro system
* Mac connected to AWS VPC with subnets and Security groups
* A flexible and customizable configuration for user-data that allows injecting customized scripts and bootstrap configuration.  See the **Customizing** section for more information.

This template can be extended to allow automation for scaling a fleet of Macs leveraging AWS services such as EBS volumes, snapshots, and other services.

![Remote Desktop](mac-ss.png "Remote Desktop")

### Mac Architectures

Easily test and swap between different Mac architectures such as M1, M2, Intel, or M2Pro.

The default terraform file, ```mac1.tf```, builds an M2 mac.  You can build a different architecture by using a template in the ```examples``` directory.  Simply copy the terraform file and replace the existing ```mac1.tf``` file in this directory.

**Intel (x86_64):**
```
cp examples/mac-intel-example.tf mac1.tf
```

**M1:**
```
cp examples/mac-m1-example.tf mac1.tf
```

**M2 (Default):**
```
cp examples/mac-m2-example.tf mac1.tf
```

**M2Pro:**
```
cp examples/mac-m2pro-example.tf mac1.tf
```

## Remote Access

### SSH

Grab the output from ```terraform output``` which should show your EC2 Mac instance's public DNS.  The SSH key is already created and in your local directory as ```ssh_key.pem```.  Can others access my Mac?  See the **Important Firewall and White listing** for more information.  The output should look like this:

```
SSH Access - Mac 1
----------
ssh -i ssh_key.pem ec2-user@ec2-3-17-144-231.us-east-2.compute.amazonaws.com
```

Type those command and you're in.
```
% ssh -i ssh_key.pem ec2-user@ec2-3-17-144-231.us-east-2.compute.amazonaws.com
Last login: Sat Dec  2 15:01:00 2023

    ┌───┬──┐   __|  __|_  )
    │ ╷╭╯╷ │   _|  (     /
    │  └╮  │  ___|\___|___|
    │ ╰─┼╯ │  Amazon EC2
    └───┴──┘  macOS Ventura 13.6.1
```

### GUI Connection:  VNC or Apple Remote Desktop (ARN)

These instructions below were adapted from Amazon's docs because the default ports they listed caused issues.  Verified that this works Mac-to-Mac.

Reference:  https://docs.aws.amazon.com/AWSEC2/latest/UserGuide/ec2-mac-instances.html#mac-instance-vnc

1. You need a VNC or ARD client.  If you're connecting from a Mac you can use the built-in screen sharing application.

2. SSH into your Mac and setup the ec2-user password (will be automated soon through bootstrap script)
```
sudo passwd ec2-user
```

3.  Enable and start MacOS screen sharing (will be automated soon through bootstrap script):
```
sudo launchctl enable system/com.apple.screensharing
sudo launchctl load -w /System/Library/LaunchDaemons/com.apple.screensharing.plist
```

4.  Disconnect from the SSH session by typing ```exit```

5.  From your computer, type the following command, replacing the ```instance-public-dns-fqdn```.  This will set up port forwarding over SSH.  The -L will set up a local port of 22590 which will be forwarded over SSH to your remote Mac instance listening on port 5900.  Ensure that you stay connected for the duration of the remote desktop connectedion needed. 

```
sudo ssh -L 22590:localhost:5900 -i ssh_key.pem ec2-user@instance-public-dns-fqdn
```

6. From your local computer, use the ARD or VNC client that supports Apple Remote Desktop (ARD) to connect to localhost:22590. For example, use the screen sharing application on macOS as follows:
- Open Finder and select Go.
- Select Connect to Server.
- In the Server Address field, enter vnc://localhost:22590

You should now see the image above and can enter the credentials for your ec2-user.

## IMPORTANT BEFORE BUILDING:  PLEASE READ

Amazon requires your Mac instance to run on a dedicated EC2 host allocated in your AWS account.  When you spin up this lab, it automatically allocates a dedicated host required to run your Mac.  Here is an explanation directly from Amazon on this:  "As I explained previously, when using EC2 Mac instances, there is no virtual machine involved. These are running on bare metal servers, each hosting a Mac mini."

**This host must be allocated to your account for 24 hours and can't be destroyed until it has been 24 hours**.  

So if you spin this up, you can destory after 24 hours.  When you run a ```terraform destroy```, you will see this prior to 24 hours.  The host needs 24 hours to be released:

```
│ Error: releasing EC2 Host (h-06a303b1211602365): 1 error occurred:
│ 	* h-06a303b1211602365: Client.HostMinAllocationPeriodUnexpired: Unable to release Dedicated Host h-06a303b1211602365. mac2-m2.metal hosts must be allocated to your AWS account for at least 24 hour(s). You can release this host any time after 2023-12-03T14:33:06.089Z.
```

So if you are building this, just understand you'll need to wait 24 hours to finally destroy or release the dedicated host.

## Requirements and Setup

Tested with:
* Mac OS 13.4
* terraform 1.5.7

Clone this repository:
```
git clone https://github.com/iknowjason/MacLab
```

Credentials Setup:

Generate an IAM programmatic access key that has permissions to build resources in your AWS account.  Setup your .env to load these environment variables.  You can also use the direnv tool to hook into your shell and populate the .envrc.  Should look something like this in your .env or .envrc:

```
export AWS_ACCESS_KEY_ID="VALUE"
export AWS_SECRET_ACCESS_KEY="VALUE"
```

## Build and Destroy Resources

### Run terraform init
Change into the AutomatedEmulation working directory and type:

```
terraform init
```

### Run terraform plan or apply
```
terraform apply -auto-approve
```
or
```
terraform plan -out=run.plan
terraform apply run.plan
```

### Destroy resources
```
terraform destroy -auto-approve
```

### View terraform created resources
The lab has been created with important terraform outputs showing services, endpoints, IP addresses, and credentials.  To view them:
```
terraform output
```

## Customizing

## Important Firewall and White Listing
Inbound SSH access to your Mac should only be allowed sourced from your public IPv4 address.  By default when you run terraform apply, your public IPv4 address is determined via a query to ifconfig.so and the ```terraform.tfstate``` is updated automatically.  If your location changes, simply run ```terraform apply``` to update the security groups with your new public IPv4 address.  If ifconfig.me returns a public IPv6 address,  your terraform will break.  In that case you'll have to customize the white list.  To change the white list for custom rules, update this variable in ```sg.tf```:
```
locals {
  src_ip = "${chomp(data.http.firewall_allowed.response_body)}/32"
  #src_ip = "0.0.0.0/0"
}
```

## Future

This terraform was automatically generated by the ```Operator Lab``` tool. To get future releases of the tool, follow twitter.com/securitypuck.

For an Azure version of this tool, check out PurpleCloud (https://www.purplecloud.network)




