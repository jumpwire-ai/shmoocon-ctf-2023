#!/usr/bin/env bash

# Title of this theme:
title="theme_login"

# functions:

download_image_files() {
	# The list of images to be downloaded is defined in $ndscustomimages ( see near the end of this file )
	# The source of the images is defined in the openNDS config

	for nameofimage in $ndscustomimages; do
		get_image_file "$nameofimage"
	done
}

download_data_files() {
	# The list of files to be downloaded is defined in $ndscustomfiles ( see near the end of this file )
	# The source of the files is defined in the openNDS config

	for nameoffile in $ndscustomfiles; do
		get_data_file "$nameoffile"
	done
}


generate_splash_sequence() {
	name_email_login
}

header() {
# Define a common header html for every page served
	echo "<!eDOCTYPE html>
		<html>
		<head>
		<meta http-equiv=\"Cache-Control\" content=\"no-cache, no-store, must-revalidate\">
		<meta http-equiv=\"Pragma\" content=\"no-cache\">
		<meta http-equiv=\"Expires\" content=\"0\">
		<meta charset=\"utf-8\">
		<meta name=\"viewport\" content=\"width=device-width, initial-scale=1.0\">
		<link rel=\"shortcut icon\" href=\"/images/splash.png\" type=\"image/x-icon\">
		<link rel=\"stylesheet\" type=\"text/css\" href=\"/splash.css\">
		<title>$gatewayname</title>
		</head>
		<body>
		<div class=\"offset\">
		<med-blue>
			$gatewayname <br>
		</med-blue>
		<div class=\"insert\" style=\"max-width:100%;\">
		<img src=\"$logo\" alt=\"Placeholder: Logo.\"><br>
		<b>$logo_message</b><br>
	"
}

footer() {
	# Define a common footer html for every page served
	year=$(date +'%Y')
	echo "
		<hr>
		</div>
		</div>
		</body>
		</html>
	"

	exit 0
}

name_email_login() {
	  # In this example, we check that both the password and email address fields have been filled in.
	  # If not then serve the initial page, again if necessary.
	  # We are not doing any specific validation here, but here is the place to do it if you need to.
	  #
	  # Note if only one of password or email address fields is entered then that value will be preserved
	  # and displayed on the page when it is re-served.

    welcome_message

    # Reject every login with an error
	  if [ ! -z "$password" ] && [ ! -z "$emailaddress" ]; then
		    error_message
	  fi

	  login_form
	  footer
}

welcome_message() {
	echo "
		<big-red>Welcome!</big-red><br>
		<med-blue>The flag is $flag</med-blue><br>
		<italic-black>
		  Please login to access our intranet.
		</italic-black>
		<hr>
  "
}

login_form() {
	# Define a login form

  echo "
		<form action=\"/opennds_preauth/\" method=\"get\">
			<input type=\"hidden\" name=\"fas\" value=\"$fas\">
      <input type=\"email\" name=\"emailaddress\" value=\"$emailaddress\" autocomplete=\"on\" ><br>Email<br><br>
			<input type=\"password\" name=\"password\" value=\"$password\" autocomplete=\"off\" ><br>Password<br><br>
			$custom_inputs
			<input type=\"submit\" value=\"Login\" >
		</form>
		<br>
	"

	footer
}

error_message() {
	  # If we got here, we have both the password and emailaddress fields as completed on the login page on the client,
    # sleep for a random amount of time between 1 and 2 seconds
    sleep_ms=$(( $RANDOM % 99 + 1 ))
    sleep $(printf '1.%02d' $sleep_ms)
	  echo "
		<big-red>
			Invalid email/password.
		</big-red>
		<br>
	"
}

landing_page() {
	originurl=$(printf "${originurl//%/\\x}")
	gatewayurl=$(printf "${gatewayurl//%/\\x}")

	# Add the user credentials to $userinfo for the log
	userinfo="$userinfo, email=$emailaddress"

	# authenticate and write to the log - returns with $ndsstatus set
	auth_log

	# output the landing page - note many CPD implementations will close as soon as Internet access is detected
	# The client may not see this page, or only see it briefly
	auth_success="
		<p>
			<big-red>
				You are now logged in and have been granted access to the Internet.
			</big-red>
			<hr>
			<img style=\"width:100%; max-width: 100%;\" src=\"$banner3\" alt=\"Placeholder: Banner1.\"><br>
			<b>$banner3_message</b><br>
		</p>
		<hr>
		<p>
			<italic-black>
				You can use your Browser, Email and other network Apps as you normally would.
			</italic-black>

			(Your device originally requested $originurl)
			<hr>
			Click or tap Continue to show the status of your account.
		</p>
		<form>
			<input type=\"button\" VALUE=\"Continue\" onClick=\"location.href='$gatewayurl'\" >
		</form>
		<hr>
	"
	auth_fail="
		<p>
			<big-red>
				Something went wrong and you have failed to log in.
			</big-red>
			<hr>
			<img style=\"width:100%; max-width: 100%;\" src=\"$banner3\" alt=\"Placeholder: Banner1.\"><br>
			<b>$banner3_message</b><br>
		</p>
		<hr>
		<p>
			<italic-black>
				Your login attempt probably timed out.
			</italic-black>
		</p>
		<p>
			<br>
			Click or tap Continue to try again.
		</p>
		<form>
			<input type=\"button\" VALUE=\"Continue\" onClick=\"location.href='$originurl'\" >
		</form>
		<hr>
	"

	if [ "$ndsstatus" = "authenticated" ]; then
		echo "$auth_success"
	else
		echo "$auth_fail"
	fi

	footer
}

#### end of functions ####


#################################################
#						#
#  Start - Main entry point for this Theme	#
#						#
#  Parameters set here overide those		#
#  set in libopennds.sh			#
#						#
#################################################

# Quotas and Data Rates
#########################################
# Set length of session in minutes (eg 24 hours is 1440 minutes - if set to 0 then defaults to global sessiontimeout value):
# eg for 100 mins:
# session_length="100"
#
# eg for 20 hours:
# session_length=$((20*60))
#
# eg for 20 hours and 30 minutes:
# session_length=$((20*60+30))
session_length="0"

# Set Rate and Quota values for the client
# The session length, rate and quota values could be determined by this script, on a per client basis.
# rates are in kb/s, quotas are in kB. - if set to 0 then defaults to global value).
upload_rate="0"
download_rate="0"
upload_quota="0"
download_quota="0"

quotas="$session_length $upload_rate $download_rate $upload_quota $download_quota"

# Define the list of Parameters we expect to be sent sent from openNDS ($ndsparamlist):
# Note you can add custom parameters to the config file and to read them you must also add them here.
# Custom parameters are "Portal" information and are the same for all clients eg "admin_email" and "location"
ndscustomparams="input logo_message banner2_message banner3_message flag"
ndscustomimages="logo_png banner2_jpg banner3_jpg"
ndscustomfiles=""

ndsparamlist="$ndsparamlist $ndscustomparams $ndscustomimages $ndscustomfiles"

# The list of FAS Variables used in the Login Dialogue generated by this script is $fasvarlist and defined in libopennds.sh
#
# Additional FAS defined variables (defined in this theme) should be added to $fasvarlist here.
additionalthemevars="password emailaddress"

fasvarlist="$fasvarlist $additionalthemevars"

# You can choose to define a custom string. This will be b64 encoded and sent to openNDS.
# There it will be made available to be displayed in the output of ndsctl json as well as being sent
#	to the BinAuth post authentication processing script if enabled.
# Set the variable $binauth_custom to the desired value.
# Values set here can be overridden by the themespec file

#binauth_custom="This is sample text sent from \"$title\" to \"BinAuth\" for post authentication processing."

# Encode and activate the custom string
#encode_custom

# Set the user info string for logs (this can contain any useful information)
userinfo="$title"

# Customise the Logfile location. Note: the default uses the tmpfs "temporary" directory to prevent flash wear.
# Override the defaults to a custom location eg a mounted USB stick.
#mountpoint="/mylogdrivemountpoint"
#logdir="$mountpoint/ndslog/"
#logname="ndslog.log"

# seed the bash random number generator
RANDOM=$(date +%s%N | cut -b10-19)
