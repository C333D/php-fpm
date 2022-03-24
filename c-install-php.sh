#!/bin/bash

#
# c-install-php.sh - (c) by C333D - 03/2022
# build v2.0
#

###define variables
basedir=$(pwd)
now=`date +"%Y-%m-%d"`
nower=`date +"%Y-%m-%d-%H:%M:%S"`


###define help function
HELP()
{
        echo "!-------------------------------- HELP FUNCTION --------------------------------!"
        echo "!- Install and configure any php-fpm version automatically.                    -!"
        echo "!-                                                                             -!"
        echo "!- Usage:                                                                      -!"
        echo "!- Specify the following options including the arguments as you need them:     -!"
        echo "!- PHP version:   -p \"PHPVERSION\"                                              -!"
        echo "!- APT actions:   -a \"yes|ja\" or \"no|nein\"                                     -!"
        echo "!- TYPE:          -t \"web|typo\" or \"crm\"                                       -!"
        echo "!-                                                                             -!"
        echo "!- Syntax:                                                                     -!"
        echo "!- ./c-install-php.sh -p PHPVERSION -a yes|no -t typo|web|crm                  -!"
        echo "!-                                                                             -!"
        echo "!- Example 1:                                                                  -!"
        echo "!- ./c-install-php.sh -p 7.4.24 -a no -t typo                                  -!"
        echo "!- Example 2:                                                                  -!"
        echo "!- sudo ./c-install-php.sh -p 8.0.11 -a yes -t crm                             -!"
        echo "!-                                                                             -!"
        echo "!- The following files need to be present in your current work directory:      -!"
        echo "!- 1. c-php.ini                                                                -!"
        echo "!- 2. c-php-fpm.conf                                                           -!"
        echo "!- 3. c-www.conf                                                               -!"
        echo "!- 4. c-php-X.X.X-fpm                                                          -!"
        echo "!-------------------------------------------------------------------------------!"
}


CHECKDEPENDENCIES()
{
###check for root/sudo permissions
if [ "$EUID" -ne 0 ]; then
        echo "!- This script must be executed as root or with sudo permissions!"
        echo "!- To check the syntax or usage type -h and try again"
        echo "!- Exit script -!"
        exit 1;
fi
###check if needed files are present
if [[ ! -f $basedir/c-php.ini || ! -f $basedir/c-php-fpm.conf || ! -f $basedir/c-www.conf || ! -f $basedir/c-php-X.X.X-fpm  ]]; then
                echo "!- Missing needed files in your current work directory!"
                echo "!- Please check usage with -h and try again"
                echo "!- Exit script -!"
                exit 1;
fi
}


###redundant echos
MISSINGPARAM()
{
    echo "!- "
    echo "!- Missing parameters!"
    echo "!- Please check the help function below!"
    echo "!- "
    HELP
    exit 1;
}


###check if all needed parameters are set
CHECKPARAM-P()
{
if [ -z "${p}" ]; then
	MISSINGPARAM
elif [[ `wget https://www.php.net/distributions/php-$p.tar.gz 2>&1 | grep 'ERROR 404: Not Found.'` ]]; then
        echo "!- Checking if provided php version is valid"
        echo "!- This: \"$p\" is not a valid php version!"
        echo "!- Please specify a valid php version to continue"
        echo "!- "
        HELP
        exit 1;
else 
	echo "!- Checking if provided php version is valid"
	echo "!- Php version is valid!"
fi
}

CHECKPARAM-A()
{
if [ -z "${a}" ]; then
	MISSINGPARAM
elif [[ $a != [yY] && $a != [yY][eE][sS] && $a != [jJ] && $a != [jJ][aA] && $a != [nN] && $a != [nN][oO] && $a != [nN][eE][iI][nN] ]]; then
	echo "!- Checking if provided apt action option is valid"
        echo "!- Invalid Option: \"-a $a\""
        echo "!- Please check the help function below!"
	echo "!- "
	HELP
	exit 1;
else
	echo "!- Checking if provided apt action option is valid"
	echo "!- Apt action is valid!"
fi
}

CHECKPARAM-T()
{
if [ -z "${t}" ]; then
	MISSINGPARAM
elif [[ $t != [tT] && $t != [wW] && $t != [tT][yY][pP][oO] && $t != [wW][eE][bB] && $t != [cC] && $t != [cC][rR][mM] ]]; then
	echo "!- Checking if provided type option is valid"
	echo "!- Invalid Option: \"-t $t\""
	echo "!- Please check the help function below!"
	echo "!- "
	HELP
	exit 1;
else
	echo "!- Checking if provided type option is valid"
	echo "!- Type action is vaild!"
fi
}


###define checklibcclient function
CHECKLIBCCLIENT()
{
        if [ ! -f "/usr/lib/x86_64-linux-gnu/libc-client.a" ]; then
                        echo "!- Linking libc-client"
                        ln -s /usr/lib/libc-client.a /usr/lib/x86_64-linux-gnu/libc-client.a
                else
                        echo "!- /usr/lib/x86_64-linux-gnu/libc-client.a already linked - skipping"
        fi
}


###define checkdir function
CHECKDIR()
{
        echo "!- Creating directorys"
        if [ ! -d "/usr/src/php" ]; then
                        echo "!- /usr/src/php created"
                        mkdir /usr/src/php
                else
                        echo "!- /usr/src/php already exists - skipping"
        fi
        if [ ! -d "/php-sockets" ]; then
                        echo "!- /php-sockets created"
                        mkdir /php-sockets
                        chown -R www-data:www-data /php-sockets
                else
                        echo "!- /php-sockets already exists - skipping"
        fi
}


###define downloadphp function
DOWNLOADPHP()
{
	CHECKDIR
        echo "!- Checking if php-$p already exists"
        if [[ -d "/usr/src/php/php-$p/" || -d "/opt/php-$p-fpm/" ]]; then
            echo "!- php-$p already exists! Backup the exsisting php version?"
            select yn in "Yes" "No"; do
                case $yn in
                        Yes ) echo "!- Backing up the old php version"
                              if [ -d "/usr/src/php/php-$p/" ]; then
                                 echo "!- Move old php-$p source dir to php-$p-backup-$nower"
                                 rsync -a --ignore-existing --remove-source-files /usr/src/php/php-$p/ /usr/src/php/php-$p-backup-$nower/ && find /usr/src/php/php-$p -depth -type d -empty -delete
                              fi
                              if [ -d "/opt/php-$p-fpm/" ]; then
                                 echo "!- Move old php-$p install dir to php-$p-fpm-backup-$nower"
                                 rsync -a --ignore-existing --remove-source-files /opt/php-$p-fpm/ /opt/php-$p-fpm-backup-$nower/ && find /opt/php-$p-fpm -depth -type d -empty -delete
                              fi
                              echo "!- Extracting the new php version to /usr/src/php"
                              tar xzf php-$p.tar.gz -C /usr/src/php
                              break
                              ;;
                        No )  echo "!- Not backing up the old php version"
			      echo "!- Overwriting the exsisting php version"
                              tar xzf php-$p.tar.gz -C /usr/src/php
                              break
                              ;;
                esac
            done
            else
                echo "!- No old version deteced"
                echo "!- Extracting the new php version to /usr/src/php"
                tar xzf php-$p.tar.gz -C /usr/src/php
        fi
}


###define aptaction function
APTACTION()
{
                echo "!- Preparing apt actions"
                echo "!- Looking for Systeminformation"
                if cat /etc/issue | grep -q Ubuntu; then
                        system=$(cat /etc/issue | grep Ubuntu | cut -f2 -d" " | cut -f1-2 -d".")
                        if [[ $system == "22.04" ]]; then
                                echo "!- Ubuntu $system detected"
                                echo "!- Starting apt update & install"
                                apt update > /dev/null 2>&1
                                apt build-dep php$phpversion -y > /dev/null 2>&1
                                apt install zip unzip autoconf automake libtool libsodium-dev libargon2-dev redis-server rsync -y > /dev/null 2>&1
                        elif [[ $system == "20.04" ]]; then
                                echo "!- Ubuntu $system detected"
                                echo "!- Starting apt update & install"
                                apt update > /dev/null 2>&1
                                apt build-dep php$phpversion -y > /dev/null 2>&1
                                apt install zip unzip autoconf automake libtool libsodium-dev libargon2-dev redis-server rsync -y > /dev/null 2>&1
                        elif [[ $system == "18.04" ]]; then
                                echo "!- Ubuntu $system detected"
                                echo "!- Starting apt update & install"
                                apt update > /dev/null 2>&1
                                apt build-dep php$phpversion -y > /dev/null 2>&1
                                apt install zip unzip autoconf automake libtool libsodium-dev libargon2-dev redis-server rsync -y > /dev/null 2>&1
                        elif [[ $system == "16.04" ]]; then
                                echo "!- Ubuntu $system detected"
                                echo "!- Starting apt update & install"
                                apt update > /dev/null 2>&1
                                apt build-dep php$phpversion -y > /dev/null 2>&1
                                apt install zip unzip autoconf automake libtool redis-server libsodium-dev rsync -y > /dev/null 2>&1
                                if [[ ! -d "/usr/src/php/argon2" ]]; then
                                        mkdir -p /usr/src/php/argon2
                                fi
                                wget https://github.com/P-H-C/phc-winner-argon2/archive/refs/heads/master.zip -O /usr/src/php/argon2/argon2.zip > /dev/null 2>&1
                                unzip /usr/src/php/argon2/argon2.zip
                                cd /usr/src/php/argon2/phc-winner-argon2/ && ./configure && make && make install > /dev/null 2>&1
                                cd $basedir
                        elif [[ $system == "14.04" ]]; then
                                echo "!- Ubuntu $system detected"
                                echo "!- Starting apt update & install"
                                apt update > /dev/null 2>&1
                                apt build-dep php$phpversion -y > /dev/null 2>&1
                                apt install zip unzip autoconf automake libtool redis-server libsodium-dev rsync -y > /dev/null 2>&1
                                if [[ ! -d "/usr/src/php/argon2" ]]; then
                                        mkdir -p /usr/src/php/argon2
                                fi
                                wget https://github.com/P-H-C/phc-winner-argon2/archive/refs/heads/master.zip -O /usr/src/php/argon2/argon2.zip > /dev/null 2>&1
                                unzip /usr/src/php/argon2/argon2.zip
                                cd /usr/src/php/argon2/phc-winner-argon2/ && ./configure && make && make install > /dev/null 2>&1
                                cd $basedir
                        else
                                echo "!- Your system version is not supported yet"
                                echo "!- No apt actions are performed!"
                                echo "!- Please install the needed dependencies manually"
                                echo "!- and rerun the script with the \"no\" option!"
                                echo "!- Exit script -!"
                                exit 1;
                        fi
                else
                echo "!- Cannot detect current system version"
                echo "!- No apt actions are performed!"
                echo "!- Please install the needed dependencies manually"
                echo "!- and rerun the script with the \"-a no\" option!"
                echo "!- Exit script -!"
                exit 1;
                fi
}


###define noaptaction function
NOAPTACTION()
{
                echo "!- You have selected \"no\" hence no apt actions are performed!"
                echo "!- Continuing with the script"
}


###define webtype function
WEBTYPE()
{
                echo "!- Configuring php for \"WEB|TYPO\""
                echo "!- This process can take several minutes depending on your system!"
                if [[ $phpversion == "7.4" ]]; then
                        cd /usr/src/php/php-$p/ && ./configure --prefix=/opt/php-$p-fpm --without-pdo-pgsql --with-zlib-dir --enable-mbstring --with-freetype --with-libxml --enable-soap --enable-calendar --with-curl --with-zlib --enable-gd --without-pgsql --disable-rpath --enable-inline-optimization --with-bz2 --with-zlib --enable-sockets --enable-sysvsem --enable-sysvshm --enable-pcntl --enable-mbregex --with-mhash --with-zip --with-pdo-mysql --with-mysqli --with-jpeg --with-openssl --with-libdir=/lib/x86_64-linux-gnu --enable-ftp --with-kerberos --with-gettext --enable-fpm --enable-bcmath --enable-tokenizer --with-mysql-sock=/var/lib/mysql/mysql.sock --enable-mysqlnd --enable-intl --with-sodium --with-password-argon2 --enable-exif --with-pcre-jit --with-pear >> $log
			echo -e "\n\n----------------------------\nCONFIGURE FINISHED\n$(date)\n----------------------------\n\n" >> $log
                        echo "!- Configuration done - check logfile \"$log\" for further information"
                elif [[ $phpversion == "7.3" ]]; then
                        cd /usr/src/php/php-$p/ && ./configure --prefix=/opt/php-$p-fpm --without-pdo-pgsql --with-zlib-dir --enable-mbstring --with-libxml-dir=/usr --enable-soap --enable-calendar --with-curl --with-zlib --with-gd --without-pgsql --disable-rpath --enable-inline-optimization --with-bz2 --with-zlib --enable-sockets --enable-sysvsem --enable-sysvshm --enable-pcntl --enable-mbregex --with-mhash --enable-zip --with-pcre-regex --with-pdo-mysql --with-mysqli --with-openssl --with-libdir=/lib/x86_64-linux-gnu --enable-ftp --with-kerberos --with-gettext --enable-fpm --enable-bcmath --enable-tokenizer --enable-mysqlnd --enable-intl --without-libzip --with-sodium --with-password-argon2 --with-mysql-sock=/var/run/mysqld/mysqld.sock >> $log
                        echo -e "\n\n----------------------------\nCONFIGURE FINISHED\n$(date)\n----------------------------\n\n" >> $log
                        echo "!- Configuration done - check logfile \"$log\" for further information"
                elif [[ $phpversion == "7.1" ]]; then
                        cd /usr/src/php/php-$p/ && ./configure --prefix=/opt/php-$p-fpm --with-pdo-pgsql --with-zlib-dir --with-freetype-dir --enable-mbstring --with-libxml-dir=/usr --enable-soap --enable-calendar --with-curl --with-mcrypt --with-zlib --with-gd --with-pgsql --disable-rpath --enable-inline-optimization --with-bz2 --with-zlib --enable-sockets --enable-sysvsem --enable-sysvshm --enable-pcntl --enable-mbregex --with-mhash --enable-zip --with-pcre-regex --with-mysql --with-pdo-mysql --with-mysqli --with-jpeg-dir=/usr --with-png-dir=/usr --enable-gd-native-ttf --with-openssl --with-libdir=/lib/x86_64-linux-gnu --enable-ftp --with-kerberos --with-gettext --enable-fpm --enable-bcmath --enable-tokenizer --with-mysql-sock=/var/run/mysqld/mysqld.sock --enable-mysqlnd >> $log
                        echo -e "\n\n----------------------------\nCONFIGURE FINISHED\n$(date)\n----------------------------\n\n" >> $log
                        echo "!- Configuration done - check logfile \"$log\" for further information"
                elif [[ $phpversion == "5.6" ]]; then
                        cd /usr/src/php/php-$p/ && ./configure --prefix=/opt/php-$p-fpm --with-zlib-dir --with-freetype-dir --enable-mbstring --with-libxml-dir=/usr --enable-soap --enable-calendar --with-curl --with-mcrypt --with-zlib --with-gd --disable-rpath --enable-inline-optimization --with-bz2 --with-zlib --enable-sockets --enable-sysvsem --enable-sysvshm --enable-pcntl --enable-mbregex --with-mhash --enable-zip --with-pcre-regex --with-mysql --with-mysqli --with-jpeg-dir=/usr --with-png-dir=/usr --enable-gd-native-ttf --with-openssl --with-libdir=/lib/x86_64-linux-gnu --enable-ftp --with-kerberos --with-gettext --enable-fpm --enable-bcmath --enable-opcache --without-pdo-sqlite --without-pgsql --enable-sockets --disable-pdo --enable-tokenizer --with-pear >> $log
                        echo -e "\n\n----------------------------\nCONFIGURE FINISHED\n$(date)\n----------------------------\n\n" >> $log
                        echo "!- Configuration done - check logfile \"$log\" for further information"
                elif [[ $phpversion == "8.0" ]]; then
                        cd /usr/src/php/php-$p/ && ./configure --prefix=/opt/php-$p-fpm --without-pdo-pgsql --with-zlib-dir --enable-mbstring --with-freetype --with-libxml --enable-soap --enable-calendar --with-curl --with-zlib --enable-gd --without-pgsql --disable-rpath --with-bz2 --with-zlib --enable-sockets --enable-sysvsem --enable-sysvshm --enable-pcntl --enable-mbregex --with-mhash --with-zip --with-pdo-mysql --with-mysqli --with-jpeg --with-openssl --with-libdir=/lib/x86_64-linux-gnu --enable-ftp --with-kerberos --with-gettext --enable-fpm --enable-bcmath --enable-tokenizer --with-mysql-sock=/var/lib/mysql/mysql.sock --enable-mysqlnd --enable-intl --with-sodium --with-password-argon2 --enable-exif --with-pcre-jit --with-pear >> $log
                        echo -e "\n\n----------------------------\nCONFIGURE FINISHED\n$(date)\n----------------------------\n\n" >> $log
                        echo "!- Configuration done - check logfile \"$log\" for further information"
                else
                        echo "!- Your PHP Version \"$phpversion\" is not supported yet."
                        echo "!- Exit script -!"
                        exit 1;
                fi
}


###define crmtype function
CRMTYPE()
{
                echo "!- Configuring php for \"CRM\""
                echo "!- This process can take several minutes depending on your system!"
                if [[ $phpversion == "7.4" ]]; then
                        cd /usr/src/php/php-$p/ && ./configure --prefix=/opt/php-$p-fpm --without-pdo-pgsql --with-zlib-dir --enable-mbstring --with-freetype --with-libxml --enable-soap --enable-calendar --with-curl --with-zlib --enable-gd --without-pgsql --disable-rpath --enable-inline-optimization --with-bz2 --with-zlib --enable-sockets --enable-sysvsem --enable-sysvshm --enable-pcntl --enable-mbregex --with-mhash --with-zip --with-pdo-mysql --with-mysqli --with-jpeg --with-openssl --with-libdir=/lib/x86_64-linux-gnu --enable-ftp --with-kerberos --with-gettext --enable-fpm --enable-bcmath --enable-tokenizer --with-mysql-sock=/var/lib/mysql/mysql.sock --enable-mysqlnd --enable-intl --with-sodium --with-password-argon2 --enable-exif --with-pcre-jit --with-pear --with-imap --with-imap-ssl --with-ldap >> $log
                        echo -e "\n\n----------------------------\nCONFIGURE FINISHED\n$(date)\n----------------------------\n\n" >> $log
                        echo "!- Configuration done - check logfile \"$log\" for further information"
                elif [[ $phpversion == "7.3" ]]; then
                        cd /usr/src/php/php-$p/ && ./configure --prefix=/opt/php-$p-fpm --without-pdo-pgsql --with-zlib-dir --enable-mbstring --with-libxml-dir=/usr --enable-soap --enable-calendar --with-curl --with-zlib --with-gd --without-pgsql --disable-rpath --enable-inline-optimization --with-bz2 --with-zlib --enable-sockets --enable-sysvsem --enable-sysvshm --enable-pcntl --enable-mbregex --with-mhash --enable-zip --with-pcre-regex --with-pdo-mysql --with-mysqli --with-openssl --with-libdir=/lib/x86_64-linux-gnu --enable-ftp --with-kerberos --with-gettext --enable-fpm --enable-bcmath --enable-tokenizer --enable-mysqlnd --enable-intl --without-libzip --with-sodium --with-password-argon2 --with-imap --with-imap-ssl --with-mysql-sock=/var/run/mysqld/mysqld.sock --with-ldap >> $log
                        echo -e "\n\n----------------------------\nCONFIGURE FINISHED\n$(date)\n----------------------------\n\n" >> $log
                        echo "!- Configuration done - check logfile \"$log\" for further information"
                elif [[ $phpversion == "7.1" ]]; then
                        cd /usr/src/php/php-$p/ && ./configure --prefix=/opt/php-$p-fpm --with-pdo-pgsql --with-zlib-dir --with-freetype-dir --enable-mbstring --with-libxml-dir=/usr --enable-soap --enable-calendar --with-curl --with-mcrypt --with-zlib --with-gd --with-pgsql --disable-rpath --enable-inline-optimization --with-bz2 --with-zlib --enable-sockets --enable-sysvsem --enable-sysvshm --enable-pcntl --enable-mbregex --with-mhash --enable-zip --with-pcre-regex --with-mysql --with-pdo-mysql --with-mysqli --with-jpeg-dir=/usr --with-png-dir=/usr --enable-gd-native-ttf --with-openssl --with-libdir=/lib/x86_64-linux-gnu --enable-ftp --with-imap --with-imap-ssl --with-kerberos --with-gettext --enable-fpm --enable-bcmath --enable-tokenizer --with-mysql-sock=/var/run/mysqld/mysqld.sock --enable-mysqlnd --with-ldap >> $log
                        echo -e "\n\n----------------------------\nCONFIGURE FINISHED\n$(date)\n----------------------------\n\n" >> $log
                        echo "!- Configuration done - check logfile \"$log\" for further information"
                elif [[ $phpversion == "5.6" ]]; then
                        cd /usr/src/php/php-$p/ && ./configure --prefix=/opt/php-$p-fpm --with-zlib-dir --with-freetype-dir --enable-mbstring --with-libxml-dir=/usr --enable-soap --enable-calendar --with-curl --with-mcrypt --with-zlib --with-gd --disable-rpath --enable-inline-optimization --with-bz2 --with-zlib --enable-sockets --enable-sysvsem --enable-sysvshm --enable-pcntl --enable-mbregex --with-mhash --enable-zip --with-pcre-regex --with-mysql --with-mysqli --with-jpeg-dir=/usr --with-png-dir=/usr --enable-gd-native-ttf --with-openssl --with-libdir=/lib/x86_64-linux-gnu --enable-ftp --with-imap --with-imap-ssl --with-kerberos --with-gettext --enable-fpm --enable-bcmath --enable-opcache --without-pdo-sqlite --without-pgsql --enable-sockets --disable-pdo --enable-tokenizer --with-pear --with-ldap >> $log
                        echo -e "\n\n----------------------------\nCONFIGURE FINISHED\n$(date)\n----------------------------\n\n" >> $log 
                        echo "!- Configuration done - check logfile \"$log\" for further information"
                elif [[ $phpversion == "8.0" ]]; then
                        cd /usr/src/php/php-$p/ && ./configure --prefix=/opt/php-$p-fpm --without-pdo-pgsql --with-zlib-dir --enable-mbstring --with-freetype --with-libxml --enable-soap --enable-calendar --with-curl --with-zlib --enable-gd --without-pgsql --disable-rpath --with-bz2 --with-zlib --enable-sockets --enable-sysvsem --enable-sysvshm --enable-pcntl --enable-mbregex --with-mhash --with-zip --with-pdo-mysql --with-mysqli --with-jpeg --with-openssl --with-libdir=/lib/x86_64-linux-gnu --enable-ftp --with-kerberos --with-gettext --enable-fpm --enable-bcmath --enable-tokenizer --with-mysql-sock=/var/lib/mysql/mysql.sock --enable-mysqlnd --enable-intl --with-sodium --with-password-argon2 --enable-exif --with-pcre-jit --with-pear --with-imap --with-imap-ssl --with-ldap >> $log
                        echo -e "\n\n----------------------------\nCONFIGURE FINISHED\n$(date)\n----------------------------\n\n" >> $log
                        echo "!- Configuration done - check logfile \"$log\" for further information"
                else
                        echo "!- Your PHP Version \"$phpversion\" is not supported yet."
                        echo "!- Exit script -!"
                        exit 1;
                fi
}


###check opts
while getopts "p:a:t:h" option; do
   case "${option}" in
      h)
        HELP
        exit;;
      p)
        p=${OPTARG}
        phpversion=$(echo $p | cut -f1-2 -d".")
	log="/usr/src/php/php-$p/c-configure.log"
        ;;
      a)
        a=${OPTARG}
        ;;
      t)
        t=${OPTARG}
        ;;
      \?)
        echo "!- Invalid Argument!"
        echo "!- Please check the help function below!"
	echo "!- "
        HELP
        exit 1
        ;;
   esac
done
shift $((OPTIND -1))


###starting script
echo "!- Start script -!"
echo "!----"
echo "!- c-install-php.sh - (c) by C333D"
echo "!----"
CHECKDEPENDENCIES
CHECKPARAM-P
CHECKPARAM-A
CHECKPARAM-T
DOWNLOADPHP
if [[ $a == [yY] || $a == [yY][eE][sS] || $a == [jJ] || $a == [jJ][aA] ]];then
	APTACTION
elif [[ $a == [nN] || $a == [nN][oO] || $a == [nN][eE][iI][nN]] ]];then
        NOAPTACTION
fi
if [[ $t == [tT] || $t == [wW] || $t == [tT][yY][pP][oO] || $t == [wW][eE][bB] ]];then
        WEBTYPE
elif [[ $t == [cC] || $t == [cC][rR][mM] ]];then
        CRMTYPE
fi


###cleanup
echo "!- Deleting php-$p.tar.gz file"
find $basedir/ -name "php-$p.tar.gz*" -type f -delete


###make php
echo "!- Makeing php"
echo "!- This process also can take several minutes depending on your system!"
cores=$(nproc)
core=$(( $cores*75/100 ))
cd /usr/src/php/php-$p/ && make -j$core > /dev/null 2>&1


###install php
echo "!- Installing php"
cd /usr/src/php/php-$p/ && make install > /dev/null 2>&1


###apply config changes
echo "!- Appling needed config files"
cd $basedir/
sed 's/X.X.X/'"${p}"'/g' c-php-fpm.conf > /opt/php-$p-fpm/etc/php-fpm.conf
if [ ! -f "/opt/php-$p-fpm/etc/php-fpm.conf" ]; then
        echo "!- /opt/php-$p-fpm/etc/php-fpm.conf could not be created!"
fi
sed 's/X.X.X/'"${p}"'/g' c-www.conf > /opt/php-$p-fpm/etc/php-fpm.d/www.conf
if [ ! -f "/opt/php-$p-fpm/etc/php-fpm.d/www.conf" ]; then
        echo "!- /opt/php-$p-fpm/etc/php-fpm.d/www.conf could not be created!"
fi
sed 's/X.X.X/'"${p}"'/g' c-php.ini > /opt/php-$p-fpm/lib/php.ini
if [ ! -f "/opt/php-$p-fpm/lib/php.ini" ]; then
        echo "!- /opt/php-$p-fpm/lib/php.ini could not be created!"
fi

if [[ $p == "7.4."* ]]; then
        sed -i 's/KKKKKKKKK/20190902/g' /opt/php-$p-fpm/lib/php.ini
elif [[ $p == "7.3."* ]]; then
        sed -i 's/KKKKKKKKK/20180731/g' /opt/php-$p-fpm/lib/php.ini
elif [[ $p == "7.1."* ]]; then
        sed -i 's/KKKKKKKKK/20160303/g' /opt/php-$p-fpm/lib/php.ini
elif [[ $p == "5.6."* ]]; then
        sed -i 's/KKKKKKKKK/20131226/g' /opt/php-$p-fpm/lib/php.ini
elif [[ $p == "8.0."* ]]; then
        sed -i 's/KKKKKKKKK/20200930/g' /opt/php-$p-fpm/lib/php.ini
else
                echo "!- IMPORTANT:"
                echo "!- Cannot change opcache.so path in /opt/php-$p-fpm/lib/php.ini"
                echo "!- You need to change it manually after!"
fi

echo "!- Creating startup-script"
sed 's/X.X.X/'"${p}"'/g' c-php-X.X.X-fpm > /etc/init.d/php-$p-fpm


###download and install redis extension
echo "!- Downloading redis extension"
wget https://pecl.php.net/get/redis -O /opt/php-$p-fpm/etc/redis.tgz > /dev/null 2>&1
echo "!- Installing redis extension"
cd /opt/php-$p-fpm/etc/ && yes "" | ../bin/pecl -c pear.conf install redis.tgz  > /dev/null 2>&1
if [ -f "$basedir/redis.tgz" ]; then
        rm $basedir/redis.tgz
fi


###start php
echo "!- Starting php"
chmod +x /etc/init.d/php-$p-fpm
/etc/init.d/php-$p-fpm start > /dev/null 2>&1


###chown log
echo "!- Chown log to www-data"
chown www-data:www-data /var/log/php-$p-fpm.log


###enable autostart
echo "!- Enabling autostart for php"
update-rc.d php-$p-fpm defaults


###Check if php is running
echo "!- Check if php is startable"
if pgrep -f php-$p-fpm >/dev/null 2>&1; then
        echo "!- PHP successfully installed and started!"
        echo "!-----------------------------------------------------------------------------!"
        echo "!- How to add the php handler to your apache vhost                           -!"
        echo "!-                                                                           -!"
        echo "!- Enable apache modules:                                                    -!"
        echo "!- a2enmod proxy proxy_fcgi                                                  -!"
        echo "!-                                                                           -!"
        echo "!- Insert the following to your apache vhost configuration:                  -!"
        echo "!- <FilesMatch \.php$>                                                       -!"
        echo "!- SetHandler \"proxy:unix:/php-sockets/php-$p-fpm|fcgi://localhost/\"     -!"
        echo "!- </FilesMatch>                                                             -!"
        echo "!- AddType text/html .php                                                    -!"
        echo "!-                                                                           -!"
        echo "!-----------------------------------------------------------------------------!"
        echo "!- Exit script -!"
        exit 0;
else
        echo "!- Cannot confirm that php is running!"
        echo "!- Exit script -!"
fi

exit 0;