#!/bin/bash

#
# c-install-php.sh - (c) by C333D - 10/2021
# build v1.2
#

###define help function
HELP()
{
        echo "!-------------------------------- HELP FUNCTION --------------------------------!"
        echo "!- Install and configure any php-fpm version automatically.                    -!"
        echo "!-                                                                             -!"
        echo "!- Usage:                                                                      -!"
        echo "!- Specify the wanted PHP-Versionnumber after the script name and              -!"
        echo "!- 'Yes' or 'No' if this script should install the needed apt packages         -!"
        echo "!-                                                                             -!"
        echo "!- Syntax:                                                                     -!"
        echo "!- ./c-install-php.sh PHP-VERSIONUMBER yes|no                                  -!"
        echo "!-                                                                             -!"
        echo "!- Example 1:                                                                  -!"
        echo "!- ./c-install-php.sh 7.4.24 no                                                -!"
        echo "!- Example 2:                                                                  -!"
        echo "!- sudo ./c-install-php.sh 8.0.11 yes                                          -!"
        echo "!-                                                                             -!"
        echo "!- The following files need to be present in your current work directory:      -!"
        echo "!- 1. c-php.ini                                                                -!"
        echo "!- 2. c-php-fpm.conf                                                           -!"
        echo "!- 3. c-www.conf                                                               -!"
        echo "!- 4. c-php-X.X.X-fpm                                                          -!"
        echo "!-------------------------------------------------------------------------------!"
}


###display help option if input incorrect
while getopts ":h" option; do
   case $option in
      h)
	HELP
	exit;;
      \?)
      	HELP
      	exit;;
   esac
done


###define variables
basedir=$(pwd)
phpversion=$(echo $1 | cut -f1-2 -d".")
now=`date +"%Y-%m-%d"`
nower=`date +"%Y-%m-%d-%H:%M:%S"`

###starting script
echo "!- Start script -!"
echo "!- c-install-php.sh - (c) by C333D - 10/2021"
echo "!----"


###check for root/sudo permissions
if [ "$EUID" -ne 0 ]; then
        echo "!- This script must be executed as root or with sudo permissions..."
        echo "!- To check the syntax or usage type -h|--help and try again"
        echo "!- Exit script -!"
        exit 1;
fi


###check if needed files are present
if [[ ! -f $basedir/c-php.ini || ! -f $basedir/c-php-fpm.conf || ! -f $basedir/c-www.conf || ! -f $basedir/c-php-X.X.X-fpm  ]]; then
                echo "!- Missing needed files in your current work directory!"
                echo "!- Please check usage with -h|--help and try again"
                echo "!- Exit script -!"
                exit 1;
fi


###download php.tar.gz
if [[ `wget https://www.php.net/distributions/php-$1.tar.gz 2>&1 | grep 'ERROR 404: Not Found.'` ]]; then
		echo "!- Cannot download php version..."
		echo "!- Your input  \"$1\" is not a vaild option"
		echo "!- Please check usage with -h|--help and try again"
		echo "!- Exit script -!"
		exit 1;
	else
		echo "!- Downloading php version..."
fi


###apply apt packages if told so
if [[ $2 == [yY] || $2 == [yY][eE][sS] || $2 == [jJ] || $2 == [jJ][aA] ]]; then
	echo "!----"
        echo "!- You have selected \"yes\""
        echo "!- Preparing apt actions..."
        echo "!- Looking for Systeminformation"
        if cat /etc/issue | grep -q Ubuntu; then
        	system=$(cat /etc/issue | grep Ubuntu | cut -f2 -d" " | cut -f1-2 -d".")
	        if [[ $system == "22.04" ]]; then 
			echo "!- Ubuntu $system detected"
			echo "!- Starting apt update & install..."
       	 		apt update > /dev/null 2>&1
	       		apt build-dep php$phpversion > /dev/null 2>&1
			apt install zip unzip autoconf automake libtool libsodium-dev libargon2-dev redis-server rsync > /dev/null 2>&1
		elif [[ $system == "20.04" ]]; then 
			echo "!- Ubuntu $system detected"
			echo "!- Starting apt update & install..."
                	apt update > /dev/null 2>&1
	                apt build-dep php$phpversion > /dev/null 2>&1
	                apt install zip unzip autoconf automake libtool libsodium-dev libargon2-dev redis-server rsync > /dev/null 2>&1
		elif [[ $system == "18.04" ]]; then
			echo "!- Ubuntu $system detected"
			echo "!- Starting apt update & install..."
	                apt update > /dev/null 2>&1
	                apt build-dep php$phpversion > /dev/null 2>&1
	                apt install zip unzip autoconf automake libtool libsodium-dev libargon2-dev redis-server rsync > /dev/null 2>&1
	        elif [[ $system == "16.04" ]]; then
			echo "!- Ubuntu $system detected"
			echo "!- Starting apt update & install..."
	        	apt update > /dev/null 2>&1
	                apt build-dep php$phpversion > /dev/null 2>&1
	                apt install zip unzip autoconf automake libtool redis-server libsodium-dev rsync > /dev/null 2>&1
	                if [[ ! -d "/usr/src/php/argon2" ]]; then
	                	mkdir -p /usr/src/php/argon2
	                fi
			wget https://github.com/P-H-C/phc-winner-argon2/archive/refs/heads/master.zip -O /usr/src/php/argon2/argon2.zip > /dev/null 2>&1
			unzip /usr/src/php/argon2/argon2.zip
			cd /usr/src/php/argon2/phc-winner-argon2/ && ./configure && make && make install > /dev/null 2>&1
			cd $basedir 
	        elif [[ $system == "14.04" ]]; then
			echo "!- Ubuntu $system detected"
			echo "!- Starting apt update & install..."
                        apt update > /dev/null 2>&1
                        apt build-dep php$phpversion > /dev/null 2>&1
                        apt install zip unzip autoconf automake libtool redis-server libsodium-dev rsync > /dev/null 2>&1
                        if [[ ! -d "/usr/src/php/argon2" ]]; then
                                mkdir -p /usr/src/php/argon2
                        fi
                        wget https://github.com/P-H-C/phc-winner-argon2/archive/refs/heads/master.zip -O /usr/src/php/argon2/argon2.zip > /dev/null 2>&1
                        unzip /usr/src/php/argon2/argon2.zip
                        cd /usr/src/php/argon2/phc-winner-argon2/ && ./configure && make && make install > /dev/null 2>&1
                        cd $basedir
	        else 
			echo "!----"
	        	echo "!- Your system version is not supported yet"
	        	echo "!- No apt actions are performed!"
	        	echo "!- Please install the needed dependencies manually"
	        	echo "!- and rerun the script with the \"no\" option!"
			echo "!- Exit script -!"
			exit 1;
		fi
	else
		echo "!----"
                echo "!- Cannot detect current system version"
                echo "!- No apt actions are performed!"
                echo "!- Please install the needed dependencies manually"
                echo "!- and rerun the script with the \"no\" option!"
                echo "!- Exit script -!"
                exit 1;
	fi
elif [[ $2 == [nN] || $2 == [nN][oO] || $2 == [nN][eE][iI][nN]] ]]; then
	echo "!----"
	echo "!- You have selected \"no\""
	echo "!- No apt actions are performed!"
	echo "!- Continue with the script..." 
elif [ -z $2 ]; then
	echo "!----" 
	echo "!- You did not specify to install the needed apt packages"
	echo "!- Therefore skipping the apt actions..."
	echo "!----"
	echo "!- If you forgot to specify \"yes\""
	echo "!- cancel the script in the next 10 seconds by hand"
	echo "!- and rerun the script with the \"yes\" option!"
	sleep 10
fi


###link libc-client
if [ ! -f "/usr/lib/x86_64-linux-gnu/libc-client.a" ]; then
		echo "!----"
		echo "!- Linking libc-client for imap..."
		ln -s /usr/lib/libc-client.a /usr/lib/x86_64-linux-gnu/libc-client.a
	else
		echo "!----"
		echo "!- /usr/lib/x86_64-linux-gnu/libc-client.a already linked - skipping..."
fi


###create directorys
echo "!----"
echo "!- Creating directorys..." 
if [ ! -d "/usr/src/php" ]; then
		echo "!- /usr/src/php created"
		mkdir /usr/src/php
	else
		echo "!- /usr/src/php already exists - skipping..."
fi
if [ ! -d "/php-sockets" ]; then
		echo "!- /php-sockets created"
		mkdir /php-sockets
		chown -R www-data:www-data /php-sockets
	else
		echo "!- /php-sockets already exists - skipping..."
fi


###check if directory already exists
echo "!----"
echo "!- Checking if php-$1 already exists..."
if [[ -d "/usr/src/php/php-$1/" || -d "/opt/php-$1-fpm/" ]]; then
    echo "!- php-$1 already exists..."
    echo "!- Backup old version and continue with the install or quit the script?"
    select yn in "Yes" "No"; do
	case $yn in
 		Yes ) echo "!- Ok continuing..."
 		      if [ -d "/usr/src/php/php-$1/" ]; then 
		         echo "!- Move old php-$1 source dir to php-$1-backup-$nower..."
			 rsync -a --ignore-existing --remove-source-files /usr/src/php/php-$1/ /usr/src/php/php-$1-backup-$nower/ && rmdir /usr/src/php/php-$1
		      fi
		      if [ -d "/opt/php-$1-fpm/" ]; then
		         echo "!- Move old php-$1 install dir to php-$1-fpm-backup-$nower..."
			 rsync -a --ignore-existing --remove-source-files /opt/php-$1-fpm/ /opt/php-$1-fpm-backup-$nower/ && rmdir /opt/php-$1-fpm
		      fi
		      echo "!- Extracting the new php version to /usr/src/php..."
		      tar xzf php-$1.tar.gz -C /usr/src/php
		      break
		      ;;
		No )  echo "!- Ok quiting script..."
		      exit 1;
		      ;;
	esac
    done
    else
    	echo "!- Extracting the new php version to /usr/src/php..."
        tar xzf php-$1.tar.gz -C /usr/src/php
fi


###cleanup
echo "!----"
echo "!- Deleting .tar.gz file..."
rm php-$1.tar.gz


###configure php
echo "!----"
echo "!- Configuring php..."
echo "!- This process can take several minutes depending on your system!"
if [[ $phpversion == "7.4" ]]; then
        cd /usr/src/php/php-$1/ && ./configure --prefix=/opt/php-$1-fpm --without-pdo-pgsql --with-zlib-dir --enable-mbstring --with-freetype --with-libxml --enable-soap --enable-calendar --with-curl --with-zlib --enable-gd --without-pgsql --disable-rpath --enable-inline-optimization --with-bz2 --with-zlib --enable-sockets --enable-sysvsem --enable-sysvshm --enable-pcntl --enable-mbregex --with-mhash --with-zip --with-pdo-mysql --with-mysqli --with-jpeg --with-openssl --with-libdir=/lib/x86_64-linux-gnu --enable-ftp --with-kerberos --with-gettext --enable-fpm --enable-bcmath --enable-tokenizer --with-mysql-sock=/var/lib/mysql/mysql.sock --enable-mysqlnd --enable-intl --with-sodium --with-password-argon2 --enable-exif --with-pcre-jit --with-pear --with-imap --with-imap-ssl --with-ldap > /usr/src/php/php-$1/c-configure-log-$now.log
        echo "!- Configuration done - check logfile under \"/usr/src/php/php-$1/c-configure-log-$now.log\" for further information"
elif [[ $phpversion == "7.3" ]]; then
        cd /usr/src/php/php-$1/ && ./configure --prefix=/opt/php-$1-fpm --without-pdo-pgsql --with-zlib-dir --enable-mbstring --with-libxml-dir=/usr --enable-soap --enable-calendar --with-curl --with-zlib --with-gd --without-pgsql --disable-rpath --enable-inline-optimization --with-bz2 --with-zlib --enable-sockets --enable-sysvsem --enable-sysvshm --enable-pcntl --enable-mbregex --with-mhash --enable-zip --with-pcre-regex --with-pdo-mysql --with-mysqli --with-openssl --with-libdir=/lib/x86_64-linux-gnu --enable-ftp --with-kerberos --with-gettext --enable-fpm --enable-bcmath --enable-tokenizer --enable-mysqlnd --enable-intl --without-libzip --with-sodium --with-password-argon2 --with-imap --with-imap-ssl --with-mysql-sock=/var/run/mysqld/mysqld.sock --with-ldap > /usr/src/php/php-$1/c-configure-log-$now.log
        echo "!- Configuration done - check logfile under \"/usr/src/php/php-$1/c-configure-log-$now.log\" for further information"
elif [[ $phpversion == "7.1" ]]; then
        cd /usr/src/php/php-$1/ && ./configure --prefix=/opt/php-$1-fpm --with-pdo-pgsql --with-zlib-dir --with-freetype-dir --enable-mbstring --with-libxml-dir=/usr --enable-soap --enable-calendar --with-curl --with-mcrypt --with-zlib --with-gd --with-pgsql --disable-rpath --enable-inline-optimization --with-bz2 --with-zlib --enable-sockets --enable-sysvsem --enable-sysvshm --enable-pcntl --enable-mbregex --with-mhash --enable-zip --with-pcre-regex --with-mysql --with-pdo-mysql --with-mysqli --with-jpeg-dir=/usr --with-png-dir=/usr --enable-gd-native-ttf --with-openssl --with-libdir=/lib/x86_64-linux-gnu --enable-ftp --with-imap --with-imap-ssl --with-kerberos --with-gettext --enable-fpm --enable-bcmath --enable-tokenizer --with-mysql-sock=/var/run/mysqld/mysqld.sock --enable-mysqlnd --with-ldap > /usr/src/php/php-$1/c-configure-log-$now.log
        echo "!- Configuration done - check logfile under \"/usr/src/php/php-$1/c-configure-log-$now.log\" for further information"
elif [[ $phpversion == "5.6" ]]; then
        cd /usr/src/php/php-$1/ && ./configure --prefix=/opt/php-$1-fpm --with-zlib-dir --with-freetype-dir --enable-mbstring --with-libxml-dir=/usr --enable-soap --enable-calendar --with-curl --with-mcrypt --with-zlib --with-gd --disable-rpath --enable-inline-optimization --with-bz2 --with-zlib --enable-sockets --enable-sysvsem --enable-sysvshm --enable-pcntl --enable-mbregex --with-mhash --enable-zip --with-pcre-regex --with-mysql --with-mysqli --with-jpeg-dir=/usr --with-png-dir=/usr --enable-gd-native-ttf --with-openssl --with-libdir=/lib/x86_64-linux-gnu --enable-ftp --with-imap --with-imap-ssl --with-kerberos --with-gettext --enable-fpm --enable-bcmath --enable-opcache --without-pdo-sqlite --without-pgsql --enable-sockets --disable-pdo --enable-tokenizer --with-pear --with-ldap > /usr/src/php/php-$1/c-configure-log-$now.log
        echo "!- Configuration done - check logfile under \"/usr/src/php/php-$1/c-configure-log-$now.log\" for further information"
elif [[ $phpversion == "8.0" ]]; then
        cd /usr/src/php/php-$1/ && ./configure --prefix=/opt/php-$1-fpm --without-pdo-pgsql --with-zlib-dir --enable-mbstring --with-freetype --with-libxml --enable-soap --enable-calendar --with-curl --with-zlib --enable-gd --without-pgsql --disable-rpath --with-bz2 --with-zlib --enable-sockets --enable-sysvsem --enable-sysvshm --enable-pcntl --enable-mbregex --with-mhash --with-zip --with-pdo-mysql --with-mysqli --with-jpeg --with-openssl --with-libdir=/lib/x86_64-linux-gnu --enable-ftp --with-kerberos --with-gettext --enable-fpm --enable-bcmath --enable-tokenizer --with-mysql-sock=/var/lib/mysql/mysql.sock --enable-mysqlnd --enable-intl --with-sodium --with-password-argon2 --enable-exif --with-pcre-jit --with-pear --with-imap --with-imap-ssl --with-ldap > /usr/src/php/php-$1/c-configure-log-$now.log
        echo "!- Configuration done - check logfile under \"/usr/src/php/php-$1/c-configure-log-$now.log\" for further information"
else
                echo "!- Cannot find the right configure for PHP-$phpversion..."
                echo "!- Exit script -!"
		exit 1;
fi


###make php
echo "!----"
echo "!- Makeing php..."
echo "!- This process also can take several minutes depending on your system!"
cores=$(nproc)
core=$(( $cores*75/100 ))
cd /usr/src/php/php-$1/ && make -j$core > /dev/null 2>&1


###install php
echo "!----"
echo "!- Installing php..."
cd /usr/src/php/php-$1/ && make install > /dev/null 2>&1


###apply config changes
echo "!----"
echo "!- Appling needed config files..."
cd $basedir/
sed 's/X.X.X/'"${1}"'/g' c-php-fpm.conf > /opt/php-$1-fpm/etc/php-fpm.conf
if [ ! -f "/opt/php-$1-fpm/etc/php-fpm.conf" ]; then
	echo "!- /opt/php-$1-fpm/etc/php-fpm.conf could not be created!"
fi
sed 's/X.X.X/'"${1}"'/g' c-www.conf > /opt/php-$1-fpm/etc/php-fpm.d/www.conf
if [ ! -f "/opt/php-$1-fpm/etc/php-fpm.d/www.conf" ]; then
	echo "!- /opt/php-$1-fpm/etc/php-fpm.d/www.conf could not be created!"
fi
sed 's/X.X.X/'"${1}"'/g' c-php.ini > /opt/php-$1-fpm/lib/php.ini
if [ ! -f "/opt/php-$1-fpm/lib/php.ini" ]; then
	echo "!- /opt/php-$1-fpm/lib/php.ini could not be created!"
fi

if [[ $1 == "7.4."* ]]; then
	sed -i 's/KKKKKKKKK/20190902/g' /opt/php-$1-fpm/lib/php.ini
elif [[ $1 == "7.3."* ]]; then
	sed -i 's/KKKKKKKKK/20180731/g' /opt/php-$1-fpm/lib/php.ini
elif [[ $1 == "7.1."* ]]; then
	sed -i 's/KKKKKKKKK/20160303/g' /opt/php-$1-fpm/lib/php.ini
elif [[ $1 == "5.6."* ]]; then
	sed -i 's/KKKKKKKKK/20131226/g' /opt/php-$1-fpm/lib/php.ini
elif [[ $1 == "8.0."* ]]; then
	sed -i 's/KKKKKKKKK/20200930/g' /opt/php-$1-fpm/lib/php.ini
else
		echo "!- IMPORTANT:"
		echo "!- Cannot change opcache.so path in /opt/php-$1-fpm/lib/php.ini"
		echo "!- You need to change it manually after!"
fi

echo "!----"
echo "!- Creating startup-script..." 
sed 's/X.X.X/'"${1}"'/g' c-php-X.X.X-fpm > /etc/init.d/php-$1-fpm


###download and install redis extension
echo "!----"
echo "!- Downloading redis extension..."
wget https://pecl.php.net/get/redis -O /opt/php-$1-fpm/etc/redis.tgz > /dev/null 2>&1
echo "!- Installing redis extension..."
cd /opt/php-$1-fpm/etc/ && yes "" | ../bin/pecl -c pear.conf install redis.tgz  > /dev/null 2>&1
if [ -f "$basedir/redis.tgz" ]; then
	rm $basedir/redis.tgz
fi	


###start php
echo "!----"
echo "!- Starting php..."
chmod +x /etc/init.d/php-$1-fpm
/etc/init.d/php-$1-fpm start > /dev/null 2>&1


###chown log
echo "!----"
echo "!- Chown log to www-data..."
chown www-data:www-data /var/log/php-$1-fpm.log


###enable autostart
echo "!----"
echo "!- Enabling autostart for php..."
update-rc.d php-$1-fpm defaults


###Check if php is running
echo "!----"
echo "!- Check if php is startable..."
echo "!----"
if pgrep -f php-$1-fpm >/dev/null 2>&1; then
        echo "!- PHP successfully installed and started!"
        echo "!----"
        echo "!-----------------------------------------------------------------------------!"
        echo "!- How to add the php handler to your apache vhost                           -!"
        echo "!-                                                                           -!"
        echo "!- Enable apache modules:                                                    -!"
        echo "!- a2enmod proxy proxy_fcgi                                                  -!"
        echo "!-                                                                           -!"
        echo "!- Insert the following to your apache vhost configuration:                  -!"
        echo "!- <FilesMatch \.php$>                                                       -!"
        echo "!- SetHandler \"proxy:unix:/php-sockets/php-$1-fpm|fcgi://localhost/\"     -!"
        echo "!- </FilesMatch>                                                             -!"
        echo "!- AddType text/html .php                                                    -!"
        echo "!-                                                                           -!"
        echo "!-----------------------------------------------------------------------------!"
        echo "!----"
        echo "!- Exit script -!"
	exit 0;
else
	echo "!- Cannot confirm that php is running!"
	echo "!----"
	echo "!- Exit script -!"
fi

exit 0;