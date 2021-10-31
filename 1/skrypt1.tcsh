#!/bin/tcsh -f
#Karolina Gora 1

set opts =(`getopt -q -s tcsh -o hq -- $argv`)
set getopt_status=$?

if ($getopt_status == 1) then
	echo "Unknown option!"
	goto help;
endif

foreach opt ($opts)
	if ($opt == -h) then
		goto help;
	endif
end
	
foreach opt ($opts)
	switch($opt)
	case -q:
		exit 0;
	case --:
		breaksw;
	endsw
end

uinfo:
  set username=$USER
  echo $username
  echo getent passwd $username | awk -F : '{print $5}' | awk -F , '{print $1}'

exit 0

#Display help
help:
  echo "Description: returns login, name and lastname of current user."
  echo
  echo "Options:"
  echo -e "-h --help\tDisplays help"
  echo -e "-q --quiet\tQuiet mode"
  exit 1;