# php-fpm

Install and configure any php-fpm version for Ubuntu automatically.

Supported Platforms: 
  - Ubuntu 14.04 LTS
  - Ubuntu 16.04 LTS
  - Ubuntu 18.04 LTS
  - Ubuntu 20.04 LTS
  - Ubuntu 22.04 LTS


Info:
Needs to be executed as root or with sudo permissions (to install the needed dependencies)


Usage:
Clone git repo, chmod +x c-install-php.sh, ./c-install-php.sh --help


!-------------------------------- HELP FUNCTION --------------------------------!
!- Install and configure any php-fpm version automatically.                    -!
!-                                                                             -!
!- Usage:                                                                      -!
!- Specify the wanted PHP-Versionnumber after the script name and              -!
!- 'Yes' or 'No' if this script should install the needed apt packages         -!
!-                                                                             -!
!- Syntax:                                                                     -!
!- ./c-install-php.sh PHP-VERSIONUMBER yes|no                                  -!
!-                                                                             -!
!- Example 1:                                                                  -!
!- ./c-install-php.sh 7.4.24 no                                                -!
!- Example 2:                                                                  -!
!- sudo ./c-install-php.sh 8.0.11 yes                                          -!
!-                                                                             -!
!- The following files need to be present in your current work directory:      -!
!- 1. c-php.ini                                                                -!
!- 2. c-php-fpm.conf                                                           -!
!- 3. c-www.conf                                                               -!
!- 4. c-php-X.X.X-fpm                                                          -!
!-------------------------------------------------------------------------------!
