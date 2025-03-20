# Linux esentials

Download and install Docker Desktop, then from terminal run an Ubuntu container:
```
docker run -it ubuntu
```

1. Lookup the Public IP of cloudflare.com

```
apt update && apt install -y dnsutils

nslookup cloudflare.com

Server:         192.168.65.7
Address:        192.168.65.7#53

Non-authoritative answer:
Name:   cloudflare.com
Address: 104.16.132.229
Name:   cloudflare.com
Address: 104.16.133.229
Name:   cloudflare.com
Address: 2606:4700::6810:85e5
Name:   cloudflare.com
Address: 2606:4700::6810:84e5
```

2. Map IP address 8.8.8.8 to hostname google-dns
```
echo "8.8.8.8 google-dns" >> /etc/hosts
```
- check /etc/hosts file
```
cat /etc/hosts | grep "google-dns"
```
- check the mapping after installing ping
```
apt-get install -y iputils-ping
ping -c 3 google-dns
```

3. Check if the DNS Port is Open for google-dns

- install netcat
```
apt install -y netcat-openbsd  
```

- run:
```
nc -zv google-dns 53
```

4. Modify the System to Use Google’s Public DNS
- Change the nameserver to 8.8.8.8 instead of the default local
configuration.
```
echo "nameserver 8.8.8.8" > /etc/resolv.conf
```

- Perform another public IP lookup for cloudflare.com and compare the
results.
```
nslookup cloudflare.com
Server:         8.8.8.8
Address:        8.8.8.8#53

Non-authoritative answer:
Name:   cloudflare.com
Address: 104.16.132.229
Name:   cloudflare.com
Address: 104.16.133.229
```

5. Install and verify that Nginx service is running

```
apt install -y nginx

service nginx start

service nginx status
```
6. Find the Listening Port for Nginx

```
apt install net-tools -y
netstat -tulpn nginx
```
- nginx is listening on port 80

Bonus / Nice to Have:

• Change the Nginx Listening port to 8080
```
sed -i 's/listen 80/listen 8080/g' /etc/nginx/sites-available/default
sed -i 's/listen \[::\]:80/listen [::]:8080/g' /etc/nginx sites-available/default
service nginx restart
netstat -tulpn nginx

tcp        0      0 0.0.0.0:8080            0.0.0.0:*               LISTEN      864/nginx: master p 
tcp6       0      0 :::8080                 :::*                    LISTEN      864/nginx: master p 
 
```

• Modify the default HTML page title from: "Welcome to nginx!" → "I have completed
the Linux part of the DevOps internship project"
- navigate to html file location
```
cd /var/www/html
```
- replace "Welcome to nginx!" with "I have completed the Linux part of the DevOps internship project" using sed command

```
sed -i 's/Welcome to nginx!/I have completed the Linux part of the DevOps internship project/g' index.nginx-debian.html
```
- check the changes
```
cat index.nginx-debian.html 
<!DOCTYPE html>
<html>
<head>
<title>I have completed the Linux part of the DevOps internship project</title>
```
