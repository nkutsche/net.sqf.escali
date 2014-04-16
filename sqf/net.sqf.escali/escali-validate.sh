#!/bin/bash

# 	Copyright (c) 2014 Nico Kutscherauer
	
# 	This file is part of Escali Schematron.

# 	Escali Schematron is free software: you can redistribute it and/or modify
# 	it under the terms of the GNU General Public License as published by
# 	the Free Software Foundation, either version 3 of the License, or
# 	(at your option) any later version.

# 	Escali Schematron is distributed in the hope that it will be useful,
# 	but WITHOUT ANY WARRANTY; without even the implied warranty of
# 	MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
# 	GNU General Public License for more details.

# 	You should have received a copy of the GNU General Public License
# 	along with Escali Schematron.  If not, see http://www.gnu.org/licenses/gpl-3.0.

calldir=$(pwd)
escali_dir=$(readlink -f $(dirname $0))

source=$(readlink -f $1)
schema=$(readlink -f $2)

calabash=$escali_dir/lib/calabash/

if [ -n "$3" ]; 
then 
out=$(readlink -f $3);
fi

config=$escali_dir/META-INF/config.xml
html=$escali_dir/temp/report.html

user_entry=${4-yes}

cd $calabash

java -cp "calabash.jar" com.xmlcalabash.drivers.Main --input source=$source --input schema=$schema --input config=$config --output html=$html $escali_dir/xml/xproc/escali-validation.xpl

xdg-open $html

if [ -n "$3" ];
	then
	echo The schematron report should be opened automaticaly. If not you will "find" it here:
	echo $html
	echo 
	echo The Schematron report contains the IDs of the QuickFix to execute them:
	echo 
	echo Sample:
	echo ID                      Descritpion
	echo [fix] name-dxex-dxex    this is a QuickFix
	echo
	echo In this example the ID is name-dxex-dxex.
	echo 
	echo Please enter the ID of the QuickFix to execute. If you do not want to execute a QuickFix, "type" exit.

	read -p "ID of the QuickFix:" fix_id

	
	if ! test "$fix_id" = "exit" ; 
		then 
		if test "$user_entry" = "yes";
			then
			echo 
			echo If the QuickFix needs a user entry it is listed on the report.
			echo Sample:
			echo ID                            Descritpion
			echo [fix] name-dxex-dxex          this is a QuickFix
			echo      [user-entry] entry-name  This is an user entry
			echo      [user-entry] other-entry This is another user entry
			echo 
			echo In order to set the value of the user entry type it using following pattern:
			echo entry-name=\"[value]\"\;other-entry=\"[next-value]\"
			echo 
			echo If the QuickFix does not have user entries just use the [enter] key
			echo 
			read -p "Enter the user entries of the fixes:" entries
		fi

		java -cp "calabash.jar" com.xmlcalabash.drivers.Main --input config=$config $escali_dir/xml/xproc/escali-quickFix.xpl fixId=$fix_id userEntries=$entries system="sh"

		cp $escali_dir/temp/tempOutput.xml $out
		
	fi
	
fi

cd $calldir
