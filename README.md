1. After pulling the git repository create 3 empty folder in a root directory of repository if they was not be created automaticaly: 

    mkdir nextcloud postgresql portainer

2. Add DNS A record with relevant VM's IP address. You should add at least three CN records for the nextcloud, portainer and authelia containers.
    In this example we have:
        
        kos-nextcloud.intern.tconet.de => 192.168.0.40
        kos-portainer.intern.tconet.de => 192.168.0.40
        kos.authelia.intern.tconet.de  => 192.168.0.40

3. In the nginx configuration file '/nginx-reverse-proxy/reverse.conf', you should change only "server_name" parameter for each relevant virtual server. In the "proxy_pass" parameter you should use the relevant docker's container name.

5. Manipulation with cerificates:

    a) In this test example only one certificate is used for three domains. In the '/nginx-reverse-proxy/certs/san.conf' file change the alternative names [alt_names] for each relevant nginx virtual server. IN PRODUCTION ISSUE THE CERTIFICATE FOR EACH DOMAIN:

    b) Than you should create certificate sign request file and private key with next command:
        
        openssl req -new -newkey rsa:4096 -nodes -keyout nextcloud.key -out nextcloud.csr -config san.conf
    
    c) After that copy the nextcloud.csr file to AD CA Server. In AD CA Server run the command with  powershell:
        
        certreq -submit -attrib "CertificateTemplate:WebServer" nextcloud.csr nextcloud.cer            
    
    This command create two files "*.cer" and "*.rsp". Copy this files back to the Debian Server in the folder /nginx-reverse-proxy/certs

    d) You should also add root AD CA certificate to your VM. Go to the AD CA Server, open "Zertifizierungsstelle" => right click on the server => "Eigenschaften" => "Zertifikat anzeigen" => "Details" => "In Datei kopieren" => "Base-64-codiert X.509(.CER)" => and give the name as the AD CA Server name. Copy this "*.cer" file to the directory on your Debian VM /usr/local/share/ca-certificates/ and run the commands:

        sudo mv *.cer *.crt
        sudo update-ca-certificates

    This root CA certificate should be also added into nextcloud container, that's why you should put it to the following path '/nginx-reverse-proxy/certs/'.

6. The '.env' file in root directory stores the necessary environment variables as usernames and passwords which can be changed on demand. You SHOULD ADD or CHANGE trusted NEXTCLOUD_TRUSTED_DOMAINS parameter. Your all domain names  and ip addresses on which nextcloud is accessible should be added. In this example it's:
    NEXTCLOUD_TRUSTED_DOMAINS=localhost 127.0.0.1 192.168.0.40 kos-nextcloud.intern.tconet.de

7. Paste the code below into the following config file '/nextcloud/config/config.php'

    $CONFIG = array (
    'memcache.local' => '\\OC\\Memcache\\APCu',
    'apps_paths' =>
    array (
        0 =>
        array (
        'path' => '/var/www/html/apps',
        'url' => '/apps',
        'writable' => false,
        ),
        1 =>
        array (
        'path' => '/var/www/html/custom_apps',
        'url' => '/custom_apps',
        'writable' => true,
        ),
    ),
    'memcache.distributed' => '\\OC\\Memcache\\Redis',
    'memcache.locking' => '\\OC\\Memcache\\Redis',
    'redis' =>
    array (
        'host' => 'redis',
        'password' => 'RedisPassword2025',
        'port' => 6379,
    ),
    'upgrade.disable-web' => true,
    'instanceid' => 'oc4hwy6mewm0',
    'passwordsalt' => 'Xg70oN4vx76Agcz6PjsoCvvj6HfeTl',
    'secret' => 's1ysS+7BVXCQ3EEd118eAEU4YNKF9LHkUxVtT7BerEsFnqb3',
    'trusted_domains' =>
    array (
        0 => 'kos-nextcloud.intern.tconet.de',                # update it
        1 => 'kos-authelia.intern.tconet.de',                 # update it  
    ),
    'trusted_proxies' =>
    array (
        0 => '192.168.0.40/24',                               # update it   
    ),
    'datadirectory' => '/var/www/html/data',
    'dbtype' => 'pgsql',
    'version' => '34.0.0.12',
    'overwrite.cli.url' => 'https://kos-nextcloud.intern.tconet.de',   # update it
    'dbname' => 'nextcloud',
    'dbhost' => 'postgresql',
    'dbtableprefix' => 'oc_',
    'dbuser' => 'oc_admin',
    'dbpassword' => 'Xlu;f:)<,cv5y]wQ/EEY1A9Ix.3Ps~',
    'installed' => true,
    'oidc_login_provider_url' => 'https://kos-authelia.intern.tconet.de',    # update it
    'oidc_login_client_id' => 'nextcloud',
    'oidc_login_client_secret' => 'Sb80PL8IJ5SY7DNyGUVSPVCG971sXzKTpMDkiQWFJeYX_qkHtzdpf_UBO5F1zY8lUbaasH2d',   # update it, random secret from step 8
    'oidc_login_auto_redirect' => false,
    'oidc_login_end_session_redirect' => false,
    'oidc_login_button_text' => 'Log in with Authelia',
    'oidc_login_hide_password_form' => false,
    'oidc_login_use_id_token' => false,
    'oidc_login_attributes' =>
    array (
        'id' => 'preferred_username',
        'name' => 'name',
        'mail' => 'email',
        'groups' => 'groups',
        'is_admin' => 'is_nextcloud_admin',
    ),
    'oidc_login_default_group' => 'oidc',
    'oidc_login_use_external_storage' => false,
    'oidc_login_scope' => 'openid profile email groups nextcloud_userinfo',
    'oidc_login_proxy_ldap' => true,
    'oidc_login_disable_registration' => true,
    'oidc_login_redir_fallback' => false,
    'oidc_login_tls_verify' => true,
    'oidc_create_groups' => false,
    'oidc_login_webdav_enabled' => false,
    'oidc_login_password_authentication' => false,
    'oidc_login_public_key_caching_time' => 86400,
    'oidc_login_min_time_between_jwks_requests' => 10,
    'oidc_login_well_known_caching_time' => 86400,
    'oidc_login_update_avatar' => false,
    'oidc_login_code_challenge_method' => 'S256',
    'user_oidc' =>
    array (
        'default_token_endpoint_auth_method' => 'client_secret_post',
        'auto_provision' => false,
        'soft_auto_provision' => false,
        'disable_account_creation' => true,
    ),
    'allow_local_remote_servers' => 'true',
    'ldapProviderFactory' => 'OCA\\User_LDAP\\LDAPProviderFactory',
    );

8. To create the Authelias secrets, do the following

    docker exec -it authelia sh
    authelia crypto hash generate pbkdf2 --variant sha512 --random --random.length 72 --random.charset rfc3986

    Than paste the "digest" secret into following file 'authelia/configuration.yml', parameter "client_secret". Paste the another secret into '/nextcloud/config/config.php', 'oidc_login_client_secret' parameter.

9. In conclusion you can run the command:
    
    docker compose up -d





##-------------------------------ADDITIONAL----------------------------------------

1. If the password for admin has been lost, use the follow command:
    docker exec -u www-data -it nextcloud php occ maintenance:mode --off
    docker exec -u www-data -it nextcloud php occ user:resetpassword admin


LOGS:
    nextcloud: /var/www/html/data/nextcloud.log

##-------------------------------ADDITIONAL----------------------------------------