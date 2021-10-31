#!/bin/bash

declare -g -A board
declare -g -A feedback

declare -a code
declare -a colors=("r" "y" "b" "g" "p") #"red" "yellow" "blue" "green" "purple"
rounds=10
slots=4

missed="◇"
hit="◆"

function display_board {
    for y in $(seq 1 $rounds); do
        for x in $(seq 1 $slots); do
            if [[ ${board[$x,$y]} != " " ]] ; then
                echo -n " ${board[$x,$y]} "
            else
                echo -n "__ "
            fi
        done
        echo -n "| "
        for x in $(seq 1 $slots); do
            echo -n ${feedback[$x, $y]}" "
        done
        echo
    done
}

function empty_board {
    # ()
    for y in $(seq 1 $rounds); do
        for x in $(seq 1 $slots); do 
            board[$x,$y]=' '
            feedback[$x,$y]=' '
        done
    done
}

function set_board {
    # (round, try)
    for x in $(seq 1 $slots); do 
        eval board[$x,$round]=${try:$x-1:1}
    done
}

function get_try {
    # ()
    read -n 4 -a try
    echo $try
}

function set_game {
    for c in $(seq 1 ${slots}); do
        rand=$[$RANDOM % ${#colors[@]}]
        code[$c]=${colors[$rand]}
    done
    echo ${code[*]}
}

function check_try {
    # (round, try)
    declare -a hit_indexes
    declare -a missed_indexes
    i=1
    for x in $(seq 1 $slots); do 
        if [[ ${try[*]:$x-1:1} == ${code[*]:$x:1} ]]; then
            feedback[$i, $round]=$hit
            hit_indexes[(( i-1 ))]=$x
            (( i=i+1 ))
        fi
    done

    if [[ $i != $(( $slots + 1)) ]]; then
        for x in $(seq 1 $slots); do 
            if [[ ! " ${hit_indexes[*]} " =~ $x ]]; then
                # echo "x = " $x
                for c in $(seq 1 $slots); do 
                    # echo "c = " $c
                    if [[ $x != $c && (! " ${hit_indexes[*]} " =~ $c) && (! " ${missed_indexes[*]} " =~ $c) && ${code[*]:$c:1} == ${try[*]:$x-1:1} ]]; then
                        # echo "x " $x "sprawdzam z c = " $c
                        missed_indexes[(( i-1 ))]=$c
                        feedback[$i, $round]=$missed
                        (( i=i+1 ))
                    fi
                done
            fi
        done
    else
        return 1
    fi
}

function game {
    set_game
    empty_board
    display_board

    game_on=0
    round=0

    while [[ $round -lt $rounds && $game_on -eq 0 ]]; do
        (( round=round+1 ))

        echo "Guess the code"
        try=$(get_try)
        echo $try

        set_board $round $try
        check_try $round $try wtf
        game_on=$?
        echo game_on
        display_board
    done

    echo -e "GAME END\t\t rounds: " $round
}

game

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
            Help
            exit 1
    esac
    shift
done


if (( help )) ; then
    Help
    exit 0
fi

exit 0
