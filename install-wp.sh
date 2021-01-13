#!/bin/bash

# plugin version
VERSION=0.0.1

#================================================================
# HEADER
#================================================================
#% SYNOPSIS
#+    ${SCRIPT_NAME} property args ...
#%
#% DESCRIPTION
#%    Assistant for quick installation of WordPress platform
#%    using WP-CLI on the Linux
#%
#% OPTIONS
#%    -v, --ver, --version          Program version
#%    -db, --database, --dbname     Database name
#%    -dbu, --dbuser                Database user name
#%    -dbp, --dbpass                Database password
#%    -loc, --locale                Locale language code "en_DB"
#%    -u, --url                     Site URL
#%    -p, --path, --location        Site path of the root
#%    -t, --title                   Site title
#%    -a, --admin, --user           Administrator username
#%    -e, --email                   Administrator e-mail
#%    -pw, --password               Administrator password
#%    -plug, --plugins              <plugin|zip|url>
#%    -theme, --themes              <theme|zip|url>
#%
#%    -h, --help                    Help content
#%
#%    --no-update                   No update after installation
#%    --no-plugins-delete           No delete default plugins
#%    --no-clear-demo               No clear demo content
#%
#%
#% EXAMPLE
#%    ${SCRIPT_NAME} -db test_database arg arg ...
#%
#================================================================
#- IMPLEMENTATION
#-    version         ${SCRIPT_NAME} (www.infinitumform.com) 0.0.1
#-    author          Ivijan-Stefan Stipić
#-    copyright       Copyright (c) https://www.infinitumform.com
#-    license         GNU General Public License
#-
#================================================================
# END_OF_HEADER
#================================================================

#== read header ==#
SCRIPT_HEADSIZE=$(head -200 ${0} |grep -n "^# END_OF_HEADER" | cut -f1 -d:)
SCRIPT_NAME="$(basename ${0})"

#== usage functions ==#
usagefull() { head -${SCRIPT_HEADSIZE:-99} ${0} | grep -e "^#[%+-]" | sed -e "s/^#[%+-]//g" -e "s/\${SCRIPT_NAME}/${SCRIPT_NAME}/g" ; }

#================================================================
# Variables what you can change to automate things
#================================================================
# Site path
WP_PATH=$PWD;
# WP Config
SITE_URL=''
# Database name
DBNAME=''
# Datbase user
DBUSER=''
# Database password
DBPASS=''
# Database locale
LOCALE="en_DB"
# Site title
SITE_TITLE=''
# Administrator username
ADMIN_USER=''
# Administrator password
ADMIN_PASSWORD=''
# Administrator e-mail
ADMIN_EMAIL=''
# Install plugins
INSTALL_PLUGINS=''
# Install themes
INSTALL_THEMES=''

#================================================================
# Check if WP-CLI exists
#================================================================
if ! command -v wp &> /dev/null; then
    echo
	echo
	echo -e "\033[1;32;41mCommand line interface for WordPress (WP-CLI) missing on your server.\e[0m"
	echo
	echo -e "\033[1;34;34mFirst, download wp-cli.phar using wget or curl. For example:\e[0m"
	echo "curl -O https://raw.githubusercontent.com/wp-cli/builds/gh-pages/phar/wp-cli.phar"
	echo
	echo -e "\033[1;34;34mThen, check if it works:\e[0m"
	echo "php wp-cli.phar --info"
	echo
	echo -e "\033[1;34;34mTo be able to type just wp, instead of php wp-cli.phar, you need to make the file executable and move it to somewhere in your PATH. For example:\e[0m"
	echo "chmod +x wp-cli.phar"
	echo "sudo mv wp-cli.phar /usr/local/bin/wp"
	echo
	echo -e "\033[1;32;32mAfter this you can run this script properly!\e[0m"
	echo
	echo
    exit 1;
fi

#================================================================
# Set arguments
#================================================================
while [ $# -gt 0 ] ;
	do
		case $1 in
		-v | --ver | --version)
			echo "Version: $VERSION"
			exit 0;
		;;
		-db | --database | --dbname)
			DBNAME="$2"
		;;
		-dbu | --dbuser)
			DBUSER="$2"
		;;
		-dbp | --dbpass)
			DBPASS="$2"
		;;
		-loc | --locale)
			LOCALE="$2"
		;;
		-u | --url)
			SITE_URL="$2"
		;;
		-t | --title)
			SITE_TITLE="$2"
		;;
		-a | --user | --admin)
			ADMIN_USER="$2"
		;;
		-pw | --password)
			ADMIN_PASSWORD="$2"
		;;
		-e | --email)
			ADMIN_EMAIL="$2"
		;;
		-p | --path | --location)
			WP_PATH="$2"
		;;
		-plug | --plugins)
			if [ -z "$INSTALL_PLUGINS" ]; then
				INSTALL_PLUGINS="$2"
			else
				INSTALL_PLUGINS="$INSTALL_PLUGINS $2"
			fi
		;;
		-theme | --themes)
			if [ -z "$INSTALL_THEMES" ]; then
				INSTALL_THEMES="$2"
			else
				INSTALL_THEMES="$INSTALL_THEMES $2"
			fi
		;;
		--no-update)
			NO_UPDATE = 'true'
		;;
		--no-plugins-delete)
			NO_PLUGINS_DELETE = 'true'
		;;
		--no-clear-demo)
			NO_CLEAR_DEMO = 'true'
		;;
		-h | --help)
			usagefull
			exit 0;
		;;
	esac
shift
done

#================================================================
# Create directory if not exists
#================================================================
if [ ! -d $WP_PATH ]
then
	mkdir $WP_PATH
fi

# Download WordPress core to directory
#================================================================
if [ -z "$WP_PATH" ]; then
	echo "Path missing."
	echo -e "\033[1;32;41mInstallation fail!\e[0m"
	exit 1;
else
	wp core download --path="$WP_PATH" --debug --force
fi

#================================================================
# Create configuration file
#================================================================
if [ -z "$SITE_URL" ] || [ -z "$SITE_TITLE" ] || [ -z "$ADMIN_USER" ] || [ -z "$ADMIN_PASSWORD" ] || [ -z "$ADMIN_EMAIL" ] || [ -z "$DBNAME" ] || [ -z "$DBUSER" ] || [ -z "$DBPASS" ] || [ -z "$LOCALE" ]; then
	echo "Some of the main data missing."
	echo -e "\033[1;32;41mInstallation fail!\e[0m"
	exit 1;
else
	wp config create --path="$WP_PATH" --dbname="$DBNAME" --dbuser="$DBUSER" --dbpass="$DBPASS" --locale="$LOCALE" --force
fi

#================================================================
# Finally install WordPress to the server
#================================================================
if [ -z "$SITE_URL" ] || [ -z "$SITE_TITLE" ] || [ -z "$ADMIN_USER" ] || [ -z "$ADMIN_PASSWORD" ] || [ -z "$ADMIN_EMAIL" ]; then
	echo "Some of the main data missing."
	echo -e "\033[1;32;41mInstallation fail!\e[0m"
	exit 1;
else
	wp core install --path="$WP_PATH" --url="$SITE_URL" --title="$SITE_TITLE" --admin_user="$ADMIN_USER" --admin_password="$ADMIN_PASSWORD" --admin_email="$ADMIN_EMAIL"
fi

#================================================================
# Delete plugins what noone needs
#================================================================
if [ -z ${NO_PLUGINS_DELETE+x} ]; then 
	echo "Starting to delete useless plugins."
	wp plugin delete $(wp plugin list --path="$WP_PATH" --status=inactive --field=name) --path="$WP_PATH"
fi

#================================================================
# Install plugins
#================================================================
if [ -z "$INSTALL_PLUGINS" ]; then
	echo "No additional plugins installed."
else
	echo "Plugin installation begins."
	wp plugin install $INSTALL_PLUGINS --path="$WP_PATH" --force
fi

#================================================================
# Install themes
#================================================================
if [ -z "$INSTALL_THEMES" ]; then
	echo "No additional themes installed."
else
	echo "Theme installation begins."
	wp theme install $INSTALL_THEMES --path="$WP_PATH" --force
fi

#================================================================
# Clear demo trash
#================================================================
if [ -z ${NO_CLEAR_DEMO+x} ]; then
	echo "Starting to delete demo comments."
	wp comment delete $(wp comment list --path="$WP_PATH" --format=ids) --path="$WP_PATH" --force
	echo "Starting to delete demo posts."
	wp post delete $(wp post list --path="$WP_PATH" --post_type='post' --format=ids) --path="$WP_PATH" --force
fi

#================================================================
# Made all up to date
#================================================================
if [ -z ${NO_UPDATE+x} ]; then
	echo "Starting theme update."
	wp theme update --path="$WP_PATH" --all
fi

#================================================================
# Everything is done
#================================================================
echo -e "\033[1;32;32mWordpress is installed!\e[0m"
echo "Path: $WP_PATH"
echo "URL: $SITE_URL"
echo

# end
