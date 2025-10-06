1. The access nginx standart configuration file can be found at the path: /nginx/nginx.cong , you shouldn't  make changes in this file.
    The reverse proxy nginx configuration file can be found at the path: /nginx-reverse-proxy/reverse.conf  , you shuold change the ip-addresses for your real IP.
2. Create the certificates with LetsEncrypt service if nextcloud should be accessible in internrt or selfsigned if it's accessible local without internet.
    a) local:
        openssl req -x509 -nodes -newkey rsa:2048 -days 365 \
		-keyout /home/tconet/nc/nginx-reverse-proxy/certs/nextcloud.key \
		-out /home/tconet/nc/nginx-reverse-proxy/certs/nextcloud.crt \
		-subj "/CN=192.168.0.40"

3. '.env' file stores the necessary environment variables that can be changed on demand.

4.  After docker compose has started, trusted domain should be added to config.php file or to '.env' file. It means that all IP address and  all domains name on which nextcloud is accessible should be added to this file. It can be done  by addition in  /nc/nextcloud/config/config.php  file:
        'trusted_domains' =>
        array (
            0 => 'localhost',
            1 => 'intern.tconet.de',
        ),
or  to '.env' file with environment:
    NEXTCLOUD_TRUSTED_DOMAINS=localhost 127.0.0.1 192.168.0.40

5. If the password for admin has been lost, use the follow command:
    docker exec -u www-data -it nextcloud php occ maintenance:mode --off
    docker exec -u www-data -it nextcloud php occ user:resetpassword admin


LOGS:
    nextcloud: /var/www/html/data/nextcloud.log