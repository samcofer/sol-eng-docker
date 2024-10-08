#!/bin/sh
### from: https://www.askapache.com/shellscript/apache-printenv-improvement/
###
### ASKAPACHE ENVIRONMENT DEBUGGER - Display Environment Variables using perl and builtin commands
### Version 1.0.2
###
### ---------------------------------------------------------------------------------------
### This work is licensed under the Creative Commons Attribution 3.0 United States License.
### To view a copy of this license, visit http://creativecommons.org/licenses/by/3.0/us/
### or send a letter to Creative Commons, 171 Second Street, Suite 300,
### San Francisco, California, 94105, USA.
### See https://www.askapache.com/about/disclaimer-and-license/ for info.
### ----------------------------------------------------------------------------------------
###
### Usage:
###
###   Place in public web directory request from your web browser.
###
###
### Install:
###
###   1. Place in public web directory like /cgi-bin/ and rename askapache-env.cgi
###   2. chmod 744 or chmod u+x
###   3. Add Options +ExecCGI to the top of /cgi-bin/.htaccess which should be chmod 644
###   4. Add your IP address to the MY_ALLOWED_IP variable in the config below (https://www.askapache.com/online-tools/whoami/)
###
###   Optionally you can add these lines to your .htaccess (https://www.askapache.com/htaccess/)
###   file to only allow from IP Address 208.113.183.103
###
###   Order Deny,Allow
###   Deny from All
###   Allow from 208.113.183.103

### CONFIGURATION

# command line
if [ -e $GATEWAY_INTERFACE ]; then

echo "+ ARGS: ${0}"

echo "+-----------------------------------------------------+"
echo "| env                                                 |";
echo "+=====================================================+";
env | sort;echo;echo

echo "+-----------------------------------------------------+"
echo "| PERL PRINTENV                                       |";
echo "+=====================================================+";
perl -e'foreach $var (sort(keys(%ENV))) {$val = $ENV{$var};$val =~ s|n|\n|g;$val =~ s|"|\"|g;print "${var}="${val}"n"}';echo;echo

echo "+-----------------------------------------------------+"
echo "| declare                                             |";
echo "+=====================================================+";
declare | sort;echo;echo

else

echo "Content-type: text/plain; charset=iso-8859-1";echo

echo "+ ARGS: ${0}"

echo "+-----------------------------------------------------+"
echo "| env                                                 |";
echo "+=====================================================+";
env | sort;echo;echo

echo "+-----------------------------------------------------+"
echo "| PERL PRINTENV                                       |";
echo "+=====================================================+";
perl -e'foreach $var (sort(keys(%ENV))) {$val = $ENV{$var};$val =~ s|n|\n|g;$val =~ s|"|\"|g;print "${var}="${val}"n"}';echo;echo

fi

exit 0
