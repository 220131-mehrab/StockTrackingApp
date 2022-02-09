#!/bin/bash
##Script to download Yahoo historical quotes using the new cookie authenticated site.
##
## Usage: get-yahoo-quotes SYMBOL
##
##
## Author: Brad Lucas brad@beaconhill.com
## Latest: https://github.com/bradlucas/get-yahoo-quotes
##
## Copyright (c) 2017 Brad Lucas - All Rights Reserved
##
##
## History
##
## 06-03-2017 : Created script
##
## ----------------------------------------------------------------------------------------------------

SYMBOL=$1
startD=$2
endD=$3
#The $1 is for the symbol of the stock
#The $2 is for the start date
#The $3 is for the end date
if [[ -z $SYMBOL ]]; then
  echo "Please enter a SYMBOL as the first parameter to this script"
  exit
fi
#The first if is to check the year  
regex="([0-9]??[0-9])/([0-9]??[0-9])/([0-9][0-9][0-9][0-9])"
if [[  $startD =~ $regex ]]; then
	yearStart=${BASH_REMATCH[3]}
	#echo "Year is $yearStart"
	if (( $yearStart < 1970 || $yearStart > 2021 )); then	
		echo "Invalid Date Format"
		exit
	fi	
fi
#This if is to check the start date.
#If there is something invalid. It will exit the script
if [[ -z $(date -d "$startD" +%s) ]]; then
	echo "Invalid Date"
	exit
fi
#This if is to check if the user entered the end date
#It will exit the program if the format of the date is wrong
#It will also exit the script if end year is before the start year
if [[ ! -z "$endD" ]]; then
	if [[ -z $(date -d "$endD" +%s) ]]; then
		echo "Invalid Date"
		exit
	fi
	regex2="([0-9]??[0-9])/([0-9]??[0-9])/([0-9][0-9][0-9][0-9])"
	if [[ $endD =~ $regex2 ]]; then
		
	yearEnd=${BASH_REMATCH[3]}
		if (( $yearEnd < $yearStart )); then	
			echo "The end year cannot be before the start year"
			exit
		fi	
	fi
fi
#This if is to "assume" the end date if ther user doesn't input the end date
if [[ -z "$endD" ]]; then
	#echo "Empty end date"
	regex1="([0-9]??[0-9])/([0-9]??[0-9])/([0-9][0-9][0-9][0-9])"
	if [[ $startD =~ $regex1 ]]; then
		month=${BASH_REMATCH[1]}
		date=${BASH_REMATCH[2]}
		year=${BASH_REMATCH[3]}
		isLeap="False"
		#echo "Year of starting is $year"
		#This is to check if the "Starting year" is a leap year 
		#to determine the end date of the month of that year
		if (( $year%4 != 0 )); then	
			#echo "Hello in $year%4"
			isLeap="False"	
		elif ! (( $year%100  )); then
			isLeap="True"
		elif ! (( $year%400  )); then
			isLeap="False"
		else
			isLeap="True"
		fi
		#echo "isLeap value is: $isLeap"
		#These if is to check if the month is 4 6 9, and 11 because there 30 days in those months
		if (($month == 4 || $month == 6 || $month == 9  || $month == 11)); then
			#echo "Hello in 4 6 9 11"
			date1="30"
		fi
		#This if is to determine the end date of those month
		#Feb with leap year is 29, not leap year is 28, and the rest of the month is 31 days
		if (( $month != 4 && $month != 6 && $month != 9  && $month != 11 )); then
			#echo "Hello in NOT 4 6 9 11"
			if [[ $isLeap == "True" ]] && (( $month == 2  )); then
				#echo "Hello True leap year and month is 2"
				date1="29"
			fi
			if [[ $isLeap == "False" ]] && (( $month == 2  )); then
				date1="28"
			fi
			if (( $month != 2  )); then
				date1="31"
			fi
		fi

	fi
	#Concatenate the string of the appropriate month/date/year	
	asendD="${month}/${date1}/${year}"
	endD="$asendD"
		echo "asendD is $asendD"
		echo "endD is $endD"
fi

echo "Downloading quotes for $SYMBOL"


function log () {
  # To remove logging comment echo statement and uncoment the :
  echo $1
  # :
}

# Period values are 'Seconds since 1970-01-01 00:00:00 UTC'. Also known as Unix time or epoch time.
# Let's just assume we want it all and ask for a date range that starts at 1/1/1970.
# NOTE: This doesn't work for old synbols like IBM which has Yahoo has back to 1962
#Ecpoch converter
startD=$(date -d "$startD 12:00AM" +%s)
endD=$(date -d "$endD 11:59PM" +%s)
START_DATE=$startD
END_DATE=$endD

# Store the cookie in a temp file
cookieJar=$(mktemp)

# Get the crumb value
function getCrumb () {
  # Sometimes the value has an octal character
  # echo will convert it
  # https://stackoverflow.com/a/28328480

  # curl the url then replace the } characters with line feeds. This takes the large json one line and turns it into about 3000 lines
  # grep for the CrumbStore line
  # then copy out the value
  # lastly, remove any quotes
  echo -en "$(curl -s --cookie-jar $cookieJar $1)" | tr "}" "\n" | grep CrumbStore | cut -d':' -f 3 | sed 's+"++g'
}

# TODO If crumb is blank then we probably don't have a valid symbol
URL="https://finance.yahoo.com/quote/$SYMBOL/?p=$SYMBOL"
log $URL
crumb=$(getCrumb $URL)
log $crumb
log "CRUMB: $crumb"
if [[ -z $crumb ]]; then
  echo "Error finding a valid crumb value"
  exit
fi


# Build url with SYMBOL, START_DATE, END_DATE
BASE_URL="https://query1.finance.yahoo.com/v7/finance/download/$SYMBOL?period1=$START_DATE&period2=$END_DATE&interval=1d&events=history"
log $BASE_URL

# Add the crumb value
URL="$BASE_URL&crumb=$crumb"
log "URL: $URL"

# Download to
curl -s --cookie $cookieJar  $URL > result.csv

echo "Data dowmloaded to result.csv"

