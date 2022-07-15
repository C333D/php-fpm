# Install and configure any php-fpm version for Ubuntu/Debian automatically.

<h2>Supported Platforms:</h2>

 - Ubuntu 14.04 LTS / Debian 8
 - Ubuntu 16.04 LTS / Debian 9
 - Ubuntu 18.04 LTS / Debian 10
 - Ubuntu 20.04 LTS / Debian 11
 - Ubuntu 22.04 LTS / Debian 12

<h2>Info:</h2>
Needs to be executed as root or with sudo permissions (to install the needed dependencies). 
 
After a successfull installation, the php-fpm will be installed to /opt/your-php-version/, will run as user www-data and has the opcache and redis extensions enabled. 

<h2>Usage:</h2>
Clone git repo, chmod +x c-install-php.sh, execute script as shown below! 

Specify the following options including the arguments as you need them:
```
PHP version:			-p "PHPVERSION"
APT actions:			-a "yes|ja" or "no|nein"
TYPE:				-t "web|typo" or "crm"
AUTOMATIC/NO USER INTERACTION:	-n                      //Warning! This WILL OVERWRITE the current socket!
CUSTOM TAG/PREFIX:		-c "string"
FOR HELP:			-h

```

<h2>Syntax:</h2>

```
./c-install-php.sh -p PHPVERSION -a yes|no -t typo|web|crm 
	
  - Example 1: 
		./c-install-php.sh -p 7.4.24 -a no -t typo -n
  - Example 2: 
		sudo bash c-install-php.sh -p 8.0.11 -a yes -t crm -c audi 

```
<h2>Note:</h2>

The parameter "-p", "-a" and "-t" are required - the other ones are optional!

If "-n" is specified then any user interactions are omitted. **THIS MEANS THAT THE CURRENT PHP WEBSOCKET WILL BE OVERWRITTEN** if there is already an installed php version of the same branch! The exsiting php directorys will be backed up!

If "-c custom-string" is specified then php will be installed to /opt/your-php-version-YOUR-CUSTOM-STRING/ [this is useful if you want to installed the same version multiple times]!

**The following files need to be present in your current work directory:**
- c-php.ini 
- c-php-fpm.conf 
- c-www.conf 
- c-php-X.X.X-fpm 
 
