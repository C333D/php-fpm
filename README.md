# Install and configure any php-fpm version for Ubuntu automatically.

<h2>Supported Platforms:</h2>
  - Ubuntu 14.04 LTS</br>
  - Ubuntu 16.04 LTS</br>
  - Ubuntu 18.04 LTS</br>
  - Ubuntu 20.04 LTS</br>
  - Ubuntu 22.04 LTS</br>
</br>
<h2>Info:</h2>
Needs to be executed as root or with sudo permissions (to install the needed dependencies)</br>
</br>
<h2>Usage:</h2>
Clone git repo, chmod +x c-install-php.sh, execute script as shown below</br>
</br>
Specify the wanted PHP-Versionnumber after the script name and 'Yes' or 'No' if this script should install the needed apt packages</br>
</br>
To check for elp - specify the -h|--help option (./c-install-php.sh --help)</br>
</br>
<h2>Syntax:</h2>
./c-install-php.sh PHP-VERSIONUMBER yes|no<br/>
</br>
	- Example 1:</br>
		./c-install-php.sh 7.4.24 no</br>
</br>
	- Example 2:</br>
		sudo ./c-install-php.sh 8.0.11 yes</br>
</br>
</br>
</br>
The following files need to be present in your current work directory:</br>
- c-php.ini</br>
- c-php-fpm.conf</br> 
- c-www.conf</br>
- c-php-X.X.X-fpm</br>
</br>
