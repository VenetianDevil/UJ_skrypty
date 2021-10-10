#!/bin/bash
#Karolina Gora 1

Help(){
  #Display help
  echo "Description: returns login, name and lastname of current user."
  echo
  echo "Options:"
  echo -e "-h --help\tDisplays help"
  echo -e "-q --quiet\tQuiet mode"
}

for opt in "$@"
do
  case $opt in
    --help | -h)
      # echo $1
      Help
      exit 0;;
  esac
done

while [ ! $# -eq 0 ]
do
  case "$1" in
    --quiet | -q)
      exit 0;;
    -*)
      echo "Error: Invalid option"
      echo
      Help
      exit 1;;
  esac
  shift
done

login=$(whoami)
name=$(getent passwd $login | awk -F : '{print $5}' | awk -F , '{print $1}')

echo $login
echo $name
exit 0
