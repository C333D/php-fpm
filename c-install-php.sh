#!/bin/bash 

#
# c-install-php.sh - (c) by C333D
# build v2.3
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
        echo "!- Specify the following options including the arguments as you need them      -!"
	echo "!-                                                                             -!"
	echo "!- ---REQUIRED---                                                              -!"
        echo "!- PHP version:                       -p \"PHPVERSION\"                          -!"
        echo "!- APT actions:                       -a \"yes|ja\" or \"no|nein\"                 -!"
        echo "!- TYPE:                              -t \"web|typo\" or \"crm\"                   -!"
	echo "!-                                                                             -!"        
        echo "!- ---OPTIONAL---                                                              -!"
	echo "!- Automatic/No User Interaction:     -n                                       -!"
	echo "!- TAG/Prefix:                        -c \"STRING\"                              -!"
	echo "!- HELP:                              -h                                       -!"
        echo "!-                                                                             -!"
        echo "!- Syntax:                                                                     -!"
        echo "!- ./c-install-php.sh -p PHPVERSION -a yes|no -t typo|web|crm                  -!"
        echo "!-                                                                             -!"
        echo "!- Example 1:                                                                  -!"
        echo "!- ./c-install-php.sh -p 7.4.24 -a no -t typo -n                               -!"
        echo "!- Example 2:                                                                  -!"
        echo "!- sudo bash c-install-php.sh -p 8.0.11 -a yes -t crm -c audi                  -!"
        echo "!-                                                                             -!"
        echo "!- The following files need to be present in your current work directory:      -!"
        echo "!- 1. c-php.ini                                                                -!"
        echo "!- 2. c-php-fpm.conf                                                           -!"
        echo "!- 3. c-www.conf                                                               -!"
        echo "!- 4. c-php-X.X.X-fpm                                                          -!"
        echo "!-                                                                             -!"
        echo "!- Check README.md for more detailed instructions                              -!"
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
elif [[ `wget https://www.php.net/distributions/php-$p.tar.gz 2>&1 | grep '404: Not Found.'` ]]; then
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

CHECKPARAM-C()
{
if [ -z "${c}" ]; then
	echo "!- No custom prefix specified - skipping" 
else
	if [[ $c = *[[:space:]]* ]]; then
		echo "!- Option \"-c $c\" contains a space, which is not allowed!"
		echo "!- Please check the help function below!"
        	echo "!- "
	        HELP
	        exit 1;
	else
		c="-${c}"
	        echo "!- You have specified a custom prefix"
	        echo "!- This means php will be installed in the following folder:"
	        echo "!- \"/opt/php-$p-fpm$c\""
		echo "!- If this is not wanted, press Ctrl+C within the next 10 seconds!"
		sleep 10
	fi
fi
}


###define checklibcclient function
CHECKLIBCCLIENT()
{
	if [ ! -f "/usr/lib/libc-client.a" ]; then
		apt-get install -y libc-client-dev > /dev/null 2>&1
	fi
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


###check for php build-dep number
CHECKBUILDNUMBER()
{
        if [[ ! -z $(apt-cache search php8.1) ]]; then
                checkbuild=8.1
        elif [[ ! -z $(apt-cache search php8.0) ]]; then
                checkbuild=8.0
        elif [[ ! -z $(apt-cache search php7.4) ]]; then
                checkbuild=7.4
        elif [[ ! -z $(apt-cache search php7.3) ]]; then
                checkbuild=7.3
	elif [[ ! -z $(apt-cache search php7.2) ]]; then
                checkbuild=7.2
        elif [[ ! -z $(apt-cache search php7.1) ]]; then
                checkbuild=7.1
        elif [[ ! -z $(apt-cache search php7) ]]; then
                checkbuild=7
        elif [[ ! -z $(apt-cache search php5) ]]; then
                checkbuild=5
        fi
}


###define downloadphp function
DOWNLOADPHP()
{
	CHECKDIR
        echo "!- Checking if php-$p already exists"
        if [[ -d "/usr/src/php/php-$p/" || -d "/opt/php-$p-fpm$c/" ]]; then
		if [[ "$auto" == "true" ]]; then
			if [ -d "/usr/src/php/php-$p/" ]; then
                        	echo "!- Move old php-$p source dir to php-$p-backup-$nower"
	                        rsync -a --ignore-existing --remove-source-files /usr/src/php/php-$p/ /usr/src/php/php-$p-backup-$nower/ && find /usr/src/php/php-$p -depth -type d -empty -delete
                        fi
                        if [ -d "/opt/php-$p-fpm$c/" ]; then
	                        echo "!- Move old php-$p install dir to php-$p-fpm$c-backup-$nower"
                                rsync -a --ignore-existing --remove-source-files /opt/php-$p-fpm$c/ /opt/php-$p-fpm$c-backup-$nower/ && find /opt/php-$p-fpm$c -depth -type d -empty -delete
                        fi
                        echo "!- Extracting the new php version to /usr/src/php"
                        tar xzf php-$p.tar.gz -C /usr/src/php
		elif [[ "$auto" != "true" ]]; then
			echo "!- php-$p already exists! Backup the exsisting php version?"
			select yn in "\"Yes\" [press 1]" "\"No\" [press 2]"; do
			case $yn in
				"\"Yes\" [press 1]" ) echo "!- Backing up the old php version"
	                              if [ -d "/usr/src/php/php-$p/" ]; then
	                                 echo "!- Move old php-$p source dir to php-$p-backup-$nower"
	                                 rsync -a --ignore-existing --remove-source-files /usr/src/php/php-$p/ /usr/src/php/php-$p-backup-$nower/ && find /usr/src/php/php-$p -depth -type d -empty -delete
	                              fi
	                              if [ -d "/opt/php-$p-fpm$c/" ]; then
	                                 echo "!- Move old php-$p install dir to php-$p-fpm$c-backup-$nower"
	                                 rsync -a --ignore-existing --remove-source-files /opt/php-$p-fpm$c/ /opt/php-$p-fpm$c-backup-$nower/ && find /opt/php-$p-fpm$c -depth -type d -empty -delete
	                              fi
	                              echo "!- Extracting the new php version to /usr/src/php"
	                              tar xzf php-$p.tar.gz -C /usr/src/php
	                              break
	                              ;;
	                        "\"No\" [press 2]" )  echo "!- Not backing up the old php version"
				      echo "!- Overwriting the exsisting php version"
	                              tar xzf php-$p.tar.gz -C /usr/src/php
	                              break
	                              ;;
	                esac
	            done
		fi
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
                	system=Ubuntu
                	systemnumber=$(cat /etc/issue | grep Ubuntu | cut -f2 -d" " | cut -f1-2 -d".")
		elif cat /etc/issue | grep -q Debian; then
			system=Debian
			systemnumber=$(cat /etc/issue | grep Debian | cut -f3 -d" ")
                else
                         echo "!- Cannot detect current system version"
                         echo "!- No apt actions are performed!"
                         echo "!- Please install the needed dependencies manually"
                         echo "!- and rerun the script with the \"-a no\" option!"
                         echo "!- Exit script -!"
                         exit 1;
		fi
                                                                                                                                
                if [[ $systemnumber == "22.04" ]] || [[ $systemnumber == "12" ]]; then
                         echo "!- $system $systemnumber detected"
                         echo "!- Starting apt update & install"
                         apt-get update > /dev/null 2>&1
                         CHECKBUILDNUMBER
                         apt-get build-dep php$checkbuild -y > /dev/null 2>&1
                         apt-get install zip unzip autoconf automake libtool libmcrypt-dev libsodium-dev libargon2-dev redis-server rsync -y > /dev/null 2>&1
			 CHECKLIBCCLIENT
                elif [[ $systemnumber == "20.04" ]] || [[ $systemnumber == "11" ]]; then
                         echo "!- $system $systemnumber detected"
                         echo "!- Starting apt update & install"
                         apt-get update > /dev/null 2>&1
                         CHECKBUILDNUMBER
                         apt-get build-dep php$checkbuild -y > /dev/null 2>&1
                         apt-get install zip unzip autoconf automake libtool libmcrypt-dev libsodium-dev libargon2-dev redis-server rsync -y > /dev/null 2>&1
			 CHECKLIBCCLIENT
                elif [[ $systemnumber == "18.04" ]] || [[ $systemnumber == "10" ]]; then
                         echo "!- $system $systemnumber detected"
                         echo "!- Starting apt update & install"
                         apt-get update > /dev/null 2>&1
                         CHECKBUILDNUMBER
                         apt-get build-dep php$checkbuild -y > /dev/null 2>&1
                         apt-get install zip unzip autoconf automake libtool libmcrypt-dev libsodium-dev libargon2-dev redis-server rsync -y > /dev/null 2>&1
			 CHECKLIBCCLIENT
                elif [[ $systemnumber == "16.04" ]] || [[ $systemnumber == "9" ]]; then
                         echo "!- $system $systemnumber detected"
                         echo "!- Starting apt update & install"
                         apt-get update > /dev/null 2>&1
                         CHECKBUILDNUMBER
                         apt-get build-dep php$checkbuild -y > /dev/null 2>&1
                         apt-get install zip unzip autoconf automake libtool libmcrypt-dev redis-server libsodium-dev rsync -y > /dev/null 2>&1
			 CHECKLIBCCLIENT
                         if [ ! -d "/usr/src/php/argon2" ]; then
	                 	mkdir -p /usr/src/php/argon2
                         fi
                         wget https://github.com/P-H-C/phc-winner-argon2/archive/refs/heads/master.zip -O /usr/src/php/argon2/argon2.zip > /dev/null 2>&1
			 if [ ! -d "/usr/src/php/argon2/phc-winner-argon2-master" ]; then
                   	 	unzip /usr/src/php/argon2/argon2.zip -d /usr/src/php/argon2/ > /dev/null 2>&1
                         	cd /usr/src/php/argon2/phc-winner-argon2-master/ && ./configure && make && make install > /dev/null 2>&1
			 else
                         	echo "!- Directory \"/usr/src/php/argon2/phc-winner-argon2-master\" already exists!"
                         	echo "!- Assuming argon2 is already installed (skipping configure / make / make install)"
                         fi
                         rm /usr/src/php/argon2/argon2.zip
                         cd $basedir
                elif [[ $systemnumber == "14.04" ]] || [[ $systemnumber == "8" ]]; then
                         echo "!- $system $systemnumber detected"
                         echo "!- Starting apt update & install"
                         apt-get update > /dev/null 2>&1
                         CHECKBUILDNUMBER
                         apt-get build-dep php$checkbuild -y > /dev/null 2>&1
                         apt-get install zip unzip autoconf automake libtool libmcrypt-dev redis-server libsodium-dev rsync -y > /dev/null 2>&1
			 CHECKLIBCCLIENT
                         if [ ! -d "/usr/src/php/argon2" ]; then
	                         mkdir -p /usr/src/php/argon2
                         fi
                         wget https://github.com/P-H-C/phc-winner-argon2/archive/refs/heads/master.zip -O /usr/src/php/argon2/argon2.zip > /dev/null 2>&1
                         if [ ! -d "/usr/src/php/argon2/phc-winner-argon2-master" ]; then
                         	unzip /usr/src/php/argon2/argon2.zip -d /usr/src/php/argon2/ > /dev/null 2>&1
                         	cd /usr/src/php/argon2/phc-winner-argon2-master/ && ./configure && make && make install > /dev/null 2>&1
                         else
	                         echo "!- Directory \"/usr/src/php/argon2/phc-winner-argon2-master\" already exists!"
	                         echo "!- Assuming argon2 is already installed (skipping configure / make / make install)"
                         fi
			 rm /usr/src/php/argon2/argon2.zip
                         cd $basedir
                else
                         echo "!- Your system version is not supported yet"
                         echo "!- No apt actions are performed!"
                         echo "!- Please install the needed dependencies manually"
                         echo "!- and rerun the script with the \"no\" option!"
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


###define automatic function
AUTOMATIC()
{
        if [[ -L "/php-sockets/php-current-$phpversion" ]]; then
                if [[ "$auto" == "true" ]]; then
			echo "!- The socket \"php-current-$phpversion\" already exists!"
			echo "!- Hence you specifed \"automatic/no user interaction\" the current socket will NOT be overwritten!"
                        overwritten="false"
                elif [[ "$auto" != "true" ]]; then
                echo "!- The socket \"php-current-$phpversion\" already exists!"
                echo "!- Do you want the new installed phpversion to become the current socket?"
                select yn in "\"Yes\" [press 1]" "\"No\" [press 2]"; do
                        case $yn in
                                "\"Yes\" [press 1]" ) echo "!- NOTE: This only changed the symlink, the old php is still running!"
                                        rm /php-sockets/php-current-$phpversion
                                        ln -s /php-sockets/php-$p-fpm$c /php-sockets/php-current-$phpversion
                                        chown -h www-data:www-data /php-sockets/php-current-$phpversion
                                        echo "!- Please consider to deactivate the obsolete versions for security and performance reasons!"
                                        break
                                        ;;
                                "\"No\" [press 2]" ) echo "!- Ok, the current symlink will remain"
                                        overwritten="false"
                                        echo "!- Please consider to deactivate the obsolete versions for security and performance reasons!"
                                        break
                                        ;;
                        esac
                done
                fi
        else
        ln -s /php-sockets/php-$p-fpm$c /php-sockets/php-current-$phpversion
        chown -h www-data:www-data /php-sockets/php-current-$phpversion
        fi
}


###check opts
while getopts "p:a:t:c:hn" option; do
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
      n)
      	auto=true
      	;;
      c)
        c=${OPTARG}
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
echo "!- c-install-php.sh"
echo "!----"
CHECKDEPENDENCIES
CHECKPARAM-P
CHECKPARAM-A
CHECKPARAM-T
CHECKPARAM-C
DOWNLOADPHP
if [[ $a == [yY] || $a == [yY][eE][sS] || $a == [jJ] || $a == [jJ][aA] ]];then
	APTACTION
elif [[ $a == [nN] || $a == [nN][oO] || $a == [nN][eE][iI][nN]] ]];then
        NOAPTACTION
fi
if [[ $t == [tT] || $t == [wW] || $t == [tT][yY][pP][oO] || $t == [wW][eE][bB] ]];then
        echo "!- Configuring php for \"WEB|TYPO\""
elif [[ $t == [cC] || $t == [cC][rR][mM] ]];then
        CRM="--with-imap --with-imap-ssl --with-ldap"
	echo "!- Configuring php for \"CRM\""
fi


###Change directory for configuration
cd /usr/src/php/php-$p/


###Get configure options
echo "!- This process can take several minutes depending on your system!"
if [[ $phpversion == "5.6" ]]; then
	CONFPHP56="--enable-inline-optimization --with-gd --enable-zip --with-pdo-pgsql  --without-pdo-sqlite --disable-pdo --with-jpeg-dir=/usr --with-mcrypt --enable-opcache --with-png-dir=/usr --with-freetype-dir --enable-gd-native-ttf --with-libxml-dir=/usr --with-pcre-regex"
elif [[ $phpversion == "7.0" ]]; then
	CONFPHP70="--enable-inline-optimization --with-gd --enable-zip --with-pdo-pgsql --with-pgsql --with-jpeg-dir=/usr --enable-opcache --with-png-dir=/usr --enable-gd-native-ttf --with-mcrypt --with-xmlrpc --with-xsl --with-freetype-dir --with-libxml-dir=/usr --with-pcre-regex"
elif [[ $phpversion == "7.1" ]]; then
	CONFPHP71="--enable-inline-optimization --with-gd --enable-zip --with-pdo-pgsql --with-pgsql --with-jpeg-dir=/usr --with-mcrypt --with-png-dir=/usr --with-freetype-dir --enable-gd-native-ttf --with-libxml-dir=/usr --with-pcre-regex --enable-mysqlnd"
elif [[ $phpversion == "7.3" ]]; then
	CONFPHP73="--enable-inline-optimization --with-gd --enable-zip --without-pdo-pgsql --with-jpeg-dir=/usr --with-freetype-dir --with-libxml-dir=/usr --with-pcre-regex --enable-mysqlnd --enable-intl --with-sodium --with-password-argon2"
elif [[ $phpversion == "7.4" ]]; then
	CONFPHP74="--enable-inline-optimization --enable-gd --with-zip --without-pdo-pgsql --with-jpeg --with-freetype --with-libxml --with-sodium --enable-mysqlnd --enable-intl --with-pcre-jit --with-password-argon2"
elif [[ $phpversion == "8.0" ]] || [[ $phpversion == "8.1" ]]; then
	CONFPHP8="--enable-gd --with-zip --without-pdo-pgsql --with-jpeg --with-freetype --with-libxml --enable-mysqlnd --enable-intl --with-sodium --with-pcre-jit --with-password-argon2"
else
        echo "!- Your PHP Version \"$phpversion\" is not supported yet."
        echo "!- Exit script -!"
        exit 1;
fi


###Start configure
./configure --prefix=/opt/php-$p-fpm$c --enable-soap --enable-calendar --with-curl --with-zlib --with-zlib-dir --enable-mbstring --disable-rpath --enable-sockets --with-bz2 --enable-pcntl --enable-mbregex --enable-sysvsem --enable-sysvshm --with-mhash --without-pgsql --with-pdo-mysql --with-mysqli --with-mysql-sock=/var/lib/mysql/mysql.sock --with-openssl --enable-ftp --with-kerberos --enable-fpm --with-gettext --enable-bcmath --enable-tokenizer --enable-exif --with-pear --with-libdir=/lib/x86_64-linux-gnu $CONFPHP56 $CONFPHP70 $CONFPHP71 $CONFPHP73 $CONFPHP74 $CONFPHP8 $CRM >> $log
echo -e "\n\n-----------------------------\nCONFIGURATION FINISHED\n$(date)\n-----------------------------\n\n" >> $log
echo "!- Configuration done - check logfile \"$log\" for further information"


###make php
echo "!- Makeing php"
echo "!- This process also can take several minutes depending on your system!"
cores=$(nproc)
core=$(( $cores*75/100 ))
make -j$core > /dev/null 2>&1


###install php
echo "!- Installing php"
make install > /dev/null 2>&1


###cleanup
echo "!- Deleting php-$p.tar.gz file"
find $basedir/ -name "php-$p.tar.gz*" -type f -delete


###apply config changes
echo "!- Appling needed config files"
cd $basedir/

sed 's/X.X.X-fpm/'"${p}-fpm${c}"'/g' c-php-fpm.conf > /opt/php-$p-fpm$c/etc/php-fpm.conf
if [ ! -f "/opt/php-$p-fpm$c/etc/php-fpm.conf" ]; then
        echo "!- /opt/php-$p-fpm$c/etc/php-fpm.conf could not be created!"
fi
sed 's/X.X.X-fpm/'"${p}-fpm${c}"'/g' c-www.conf > /opt/php-$p-fpm$c/etc/php-fpm.d/www.conf
if [ ! -f "/opt/php-$p-fpm$c/etc/php-fpm.d/www.conf" ]; then
        echo "!- /opt/php-$p-fpm$c/etc/php-fpm.d/www.conf could not be created!"
fi
sed 's/X.X.X-fpm/'"${p}-fpm${c}"'/g' c-php.ini > /opt/php-$p-fpm$c/lib/php.ini
if [ ! -f "/opt/php-$p-fpm$c/lib/php.ini" ]; then
        echo "!- /opt/php-$p-fpm$c/lib/php.ini could not be created!"
fi

if [[ $p == "7.4."* ]]; then
        sed -i 's/KKKKKKKKK/20190902/g' /opt/php-$p-fpm$c/lib/php.ini
elif [[ $p == "7.3."* ]]; then
        sed -i 's/KKKKKKKKK/20180731/g' /opt/php-$p-fpm$c/lib/php.ini
elif [[ $p == "7.1."* ]]; then
        sed -i 's/KKKKKKKKK/20160303/g' /opt/php-$p-fpm$c/lib/php.ini
elif [[ $p == "5.6."* ]]; then
        sed -i 's/KKKKKKKKK/20131226/g' /opt/php-$p-fpm$c/lib/php.ini
elif [[ $p == "8.0."* ]]; then
        sed -i 's/KKKKKKKKK/20200930/g' /opt/php-$p-fpm$c/lib/php.ini
elif [[ $p == "8.1."* ]]; then
        sed -i 's/KKKKKKKKK/20210902/g' /opt/php-$p-fpm$c/lib/php.ini
else
                echo "!- IMPORTANT:"
                echo "!- Cannot change opcache.so path in /opt/php-$p-fpm$c/lib/php.ini"
                echo "!- You need to change it manually after!"
fi

echo "!- Creating startup-script"
sed 's/X.X.X-fpm/'"${p}-fpm${c}"'/g' c-php-X.X.X-fpm > /etc/init.d/php-$p-fpm$c


###download and install redis extension
echo "!- Downloading redis extension"
wget https://pecl.php.net/get/redis -O /opt/php-$p-fpm$c/etc/redis.tgz > /dev/null 2>&1
echo "!- Installing redis extension"
cd /opt/php-$p-fpm$c/etc/ && yes "" | ../bin/pecl -C pear.conf install redis.tgz  > /dev/null 2>&1
if [ -f "$basedir/redis.tgz" ]; then
        rm $basedir/redis.tgz
fi


###start php
echo "!- Starting php"
chmod +x /etc/init.d/php-$p-fpm$c
/etc/init.d/php-$p-fpm$c start > /dev/null 2>&1


###Symlink to current socket
AUTOMATIC


###chown log
echo "!- Chown log to www-data"
chown www-data:www-data /var/log/php-$p-fpm$c.log


###enable autostart
echo "!- Enabling autostart for php"
update-rc.d php-$p-fpm$c defaults


###Check if php is running
echo "!- Check if php started correctly"
if pgrep -f php-$p-fpm$c >/dev/null 2>&1; then
        echo "!----"
        echo "!- PHP successfully installed and started!"
        echo "!- Exit script -!"
        echo "!---- "
        echo "!- \"How to add the php handler to your apache vhost\""
        echo "!- "
        echo "!- 1.) Enable apache modules:"
        echo "!- a2enmod proxy proxy_fcgi"
        echo "!- "
        echo "!- 2.) Insert the following to your apache vhost configuration:"
        echo "!- <FilesMatch \.php$>"
        if [[ "$overwritten" -eq "false" ]];then
                echo "!- SetHandler \"proxy:unix:/php-sockets/php-$p-fpm$c|fcgi://localhost/\""
        elif [ -z $overwritten ]; then
                echo "!- SetHandler \"proxy:unix:/php-sockets/php-current-$phpversion|fcgi://localhost/\""
        fi
        echo "!- </FilesMatch>"
        echo "!- AddType text/html .php"
        echo "!- "
        echo "!- 3.) Safe configuration and reload apache:"
	echo "!- /etc/init.d/apache2 reload"
	echo "!----"
        exit 0;
else
	echo "!----"
        echo "!- Cannot confirm that php is running!"
        echo "!- Exit script -!"
        echo "!----"
fi

exit 0;
