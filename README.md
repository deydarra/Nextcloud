1. After pulling the git repository create 3 empty folder in a root directory of repository: 
    mkdir nextcloud postgresql portainer

2. Add to AD DNS Server A records with your relevant IP address of VM. You should add at least 2 A records for nextcloud and portainer.
    In this example we have:
        kos-nextcloud.intern.tconet.de => 192.168.0.40
        kos-portainer.intern.tconet.de => 192.168.0.40

3. The access nginx standart configuration file can be found at the path: /nginx/nginx.cong , you shouldn't  make changes in this file.

4. The reverse proxy nginx configuration file can be found at the path: /nginx-reverse-proxy/reverse.conf  , you should change only server_name parameters which you have configured previosly in your AD DNS Server. Use the A records. Redirection is made directly by container name.

5. Manipulation with cerificates.
    a) First of all 'san.conf' file should be changed. The file exist at the path: /nginx-reverse-proxy/certs . You should also change CN and DNS parameters in this config and configure it as you have configured in AD DNS Server A records.
    
    b) Than you should create certificate sign request file and private key with next command:
        
        openssl req -new -newkey rsa:4096 -nodes -keyout nextcloud.key -out nextcloud.csr -config san.conf
    
    c) After that copy the nextcloud.csr file to AD CA Server. In AD CA Server run the command with  powershell:
        
        certreq -submit -attrib "CertificateTemplate:WebServer" nextcloud.csr nextcloud.cer            
    
    This command create two files *.cer and *.rsp 
    Copy this files back to the Debian Server in the folder /nginx-reverse-proxy/certs

    d) You should also add root AD CA certificate to your VM. Go to the AD CA Server, open "Zertifizierungsstelle" => right click on the server => "Eigenschaften" => "Zertifikat anzeigen" => "Details" => "In Datei kopieren" => "Base-64-codiert X.509(.CER)" => and give the name as the AD CA Server name. Copy this *.cer file to the directory on your Debian VM /usr/local/share/ca-certificates/ and run the commands:
        sudo mv *.cer *.crt
        sudo update-ca-certificates

6. '.env' file in root directory stores the necessary environment variables as usernames and passwords which can be changed on demand. You SHOULD ADD or CHANGE trusted NEXTCLOUD_TRUSTED_DOMAINS parameter. Your all domain names  and ip addresses on which nextcloud is accessible should be added. In this example it's:
    NEXTCLOUD_TRUSTED_DOMAINS=localhost 127.0.0.1 192.168.0.40 kos-nextcloud.intern.tconet.de

7. In conclusion you can run the command:
    docker compose up -d





##-------------------------------ADDITIONAL----------------------------------------

1. If the password for admin has been lost, use the follow command:
    docker exec -u www-data -it nextcloud php occ maintenance:mode --off
    docker exec -u www-data -it nextcloud php occ user:resetpassword admin


LOGS:
    nextcloud: /var/www/html/data/nextcloud.log

##-------------------------------ADDITIONAL----------------------------------------