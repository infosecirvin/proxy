#!/bin/bash
#Read User Input
echo "What is the name of the Proxies?"
read name
echo "How many proxies do you want?"
read vms

#Set GCP Environment
rm -f ~/.ssh/google_compute_known_hosts
gcloud config set project elevated-range-302802

# Main Section
counter=1
while [ $counter -le $vms ]
do
#Create VM Process
gcloud compute instances create $name$counter --zone=us-east4-a --machine-type e2-medium --image-family=centos-7 --image-project=centos-cloud --tags http-server,https-server,hoe
gcloud compute ssh emmarsoto2020@$name$counter --zone=us-east4-a --ssh-key-file=~/.ssh/google_compute_engine --command="sudo yum install wget -y"
gcloud compute ssh emmarsoto2020@$name$counter --zone=us-east4-a --ssh-key-file=~/.ssh/google_compute_engine --command="sudo wget -O proxy.sh "

#Setup Squid Proxy
gcloud compute ssh emmarsoto2020@$name$counter --zone=us-east4-a --ssh-key-file=~/.ssh/google_compute_engine --command="sudo yum install nano squid httpd-tools -y"
gcloud compute ssh emmarsoto2020@$name$counter --zone=us-east4-a --ssh-key-file=~/.ssh/google_compute_engine --command="sudo htpasswd -bc /etc/squid/passwd bacon piggy"

gcloud compute ssh emmarsoto2020@$name$counter --zone=us-east4-a --ssh-key-file=~/.ssh/google_compute_engine --command="sudo rm /etc/squid/squid.conf"
gcloud compute ssh emmarsoto2020@$name$counter --zone=us-east4-a --ssh-key-file=~/.ssh/google_compute_engine --command="sudo echo auth_param basic program /usr/lib64/squid/basic_ncsa_auth /etc/squid/passwd >> /etc/squid/squid.conf"
gcloud compute ssh emmarsoto2020@$name$counter --zone=us-east4-a --ssh-key-file=~/.ssh/google_compute_engine --command="sudo echo auth_param basic realm proxy >> /etc/squid/squid.conf"
gcloud compute ssh emmarsoto2020@$name$counter --zone=us-east4-a --ssh-key-file=~/.ssh/google_compute_engine --command="sudo echo acl authenticated proxy_auth REQUIRED >> /etc/squid/squid.conf"
gcloud compute ssh emmarsoto2020@$name$counter --zone=us-east4-a --ssh-key-file=~/.ssh/google_compute_engine --command="sudo echo acl smtp port 25 >> /etc/squid/squid.conf"
gcloud compute ssh emmarsoto2020@$name$counter --zone=us-east4-a --ssh-key-file=~/.ssh/google_compute_engine --command="sudo echo http_access allow authenticated >> /etc/squid/squid.conf"
gcloud compute ssh emmarsoto2020@$name$counter --zone=us-east4-a --ssh-key-file=~/.ssh/google_compute_engine --command="sudo echo http_port 0.0.0.0:3128 >> /etc/squid/squid.conf"
gcloud compute ssh emmarsoto2020@$name$counter --zone=us-east4-a --ssh-key-file=~/.ssh/google_compute_engine --command="sudo echo http_access deny smtp >> /etc/squid/squid.conf"
gcloud compute ssh emmarsoto2020@$name$counter --zone=us-east4-a --ssh-key-file=~/.ssh/google_compute_engine --command="sudo echo http_access deny all >> /etc/squid/squid.conf"
gcloud compute ssh emmarsoto2020@$name$counter --zone=us-east4-a --ssh-key-file=~/.ssh/google_compute_engine --command="sudo echo forwarded_for delete >> /etc/squid/squid.conf"

gcloud compute ssh emmarsoto2020@$name$counter --zone=us-east4-a --ssh-key-file=~/.ssh/google_compute_engine --command="sudo touch /etc/squid/blacklist.acl"
gcloud compute ssh emmarsoto2020@$name$counter --zone=us-east4-a --ssh-key-file=~/.ssh/google_compute_engine --command="sudo systemctl restart squid.service && sudo systemctl enable squid.service"
gcloud compute ssh emmarsoto2020@$name$counter --zone=us-east4-a --ssh-key-file=~/.ssh/google_compute_engine --command="sudo iptables -I INPUT -p tcp --dport 3128 -j ACCEPT"
gcloud compute ssh emmarsoto2020@$name$counter --zone=us-east4-a --ssh-key-file=~/.ssh/google_compute_engine --command="sudo iptables-save"
((counter++))
done
