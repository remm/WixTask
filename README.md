# Task

You need to create high-available micro-service under AWS.

Service has to listen on TCP port and return back to the client morse-code of clients IP address.
AWS infrastructure have to
1. be multi-region (f.e. us-east-1, eu-west-1, ap-southeast-1) and to respond from the nearest to client location
2. be easy scalable

Answer should contain 
1. source code of micro-service
2. terraform files or set of AWS cli instruction for the creation of infrastructure (if not all requirements are solvable by terraform - You shall describe additional steps)


# How to check

* Clone repo
* Export AWS credentials:

```bash
export AWS_ACCESS_KEY_ID=""
export AWS_SECRET_ACCESS_KEY=""
export AWS_DEFAULT_REGION=""
```

* Run terraform provision in terraform dir

```bash
terraform plan
terraform apply -auto-approve
```

* Login to instances
* Clone repo to instances
* Run listener on instances

```bash
python3 socket_listener.py
```

* Connect to load balancer endpoint

```bash
nc balancer-lb-tf-709a4a973898cb2c.elb.us-east-1.amazonaws.com 11000
```

#Result


On server:

```
ubuntu@ip-172-31-80-130:~$ python3 socket_listener.py 
Sending b'.---- --... ..--- .-.-.- ...-- .---- .-.-.- ----. ..... .-.-.- .---- ----- -.... ' to 172.31.95.106
Sending b'----. ....- .-.-.- .---- ..... ---.. .-.-.- ---.. ..... .-.-.- .---- ...-- .---- ' to 94.158.85.131
Sending b'.---- --... ..--- .-.-.- ...-- .---- .-.-.- ----. ..... .-.-.- .---- ----- -.... ' to 172.31.95.106
```

On client:

```
➜  ~ nc balancer-lb-tf-709a4a973898cb2c.elb.us-east-1.amazonaws.com 11000
----. ....- .-.-.- .---- ..... ---.. .-.-.- ---.. ..... .-.-.- .---- ...-- .---- 
```