#!/bin/bash
#Read User Input
echo "What is the name of the Proxies?"
read name
echo "How many proxies do you want?"
read vms

#Set GCP Environment
rm -f ~/.ssh/google_compute_known_hosts

# Main Section
counter=1
while [ $counter -le $vms ]
do
#Create VM Process
gcloud compute instances create $name$counter --zone=us-east4-a --machine-type e2-medium --image-family=centos-7 --image-project=centos-cloud --tags http-server,https-server,hoe
gcloud compute ssh emmarsoto2020@$name$counter --zone=us-east4-a --ssh-key-file=~/.ssh/google_compute_engine --command="sudo yum install wget -y"
gcloud compute ssh emmarsoto2020@$name$counter --zone=us-east4-a --ssh-key-file=~/.ssh/google_compute_engine --command="sudo wget -O proxy.sh https://raw.githubusercontent.com/infosecirvin/proxy/main/proxy.sh"
gcloud compute ssh emmarsoto2020@$name$counter --zone=us-east4-a --ssh-key-file=~/.ssh/google_compute_engine --command="chmod +x proxy.sh && sudo bash proxy.sh"
((counter++))
done
