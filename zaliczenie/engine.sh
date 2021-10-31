#!/bin/bash

Help(){
  #Display help
  echo "Description: Gives mechanizms for game MasterMind. Launches game.pl."
  echo
  echo "Options:"
  echo -e "-h --help\tDisplays help"
  echo -e "-t TRY, --try TRY\tChecks given combination"
  echo -e "-s [easy/medium/hard], --start [easy/medium/hard]\tStart with mode"
}

while (( "$#" )); do
    arg=$1
    case $arg in
        -h|--help)
            help=1
            ;;
        -t|--try)
            shift
            try=$1
            ;;
        -s|--start)
            shift
            start=$1 #arg is the mode level
            ;;
        *)
            echo -e "Error: Unknown argument '$arg'.\n"
            print_help
            exit 1
    esac
    shift
done


if (( help )) ; then
    print_help
    exit 0
fi


exit 0
