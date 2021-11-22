#!/bin/bash

declare -g -A board
declare -g -A feedback

declare -a code
declare -a colors=("r" "y" "b" "g" "p") #"red" "yellow" "blue" "green" "purple"
rounds=10
slots=4

missed="o"
hit="+"

function display_board {
    # echo -n "feed: " ${feedback[1,1]}
    # echo -n "boardCheck: " ${board[1,1]}
    echo
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
            echo -n ${feedback[$x,$y]}" "
        done
        echo
    done
}

function display_game_raw {
    echo -en "board:$(($rounds)):$(($slots)):"
    for y in $(seq 1 $rounds); do
        for x in $(seq 1 $slots); do
            if [[ ${board[$x,$y]} != " " ]] ; then
                echo -n "${board[$x,$y]},"
            else
                echo -n ","
            fi
        done
    done
    echo -n ":"
    for y in $(seq 1 $rounds); do
        for x in $(seq 1 $slots); do
            echo -n ${feedback[$x,$y]}","
        done
    done
    echo -n ":"
    echo ${code[*]} | tr ' ' ","
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
    read -e -n 4 -a try
    echo $try
}

function set_game {
    for c in $(seq 1 ${slots}); do
        rand=$[$RANDOM % ${#colors[@]}]
        code[$c]=${colors[$rand]}
    done
    # echo ${code[*]}
}

# TODO sprawdzanie czy literki nie są spoza zakresu - tryValidation()
function check_try {
    # (round, try)
    declare -a hit_indexes
    declare -a missed_indexes
    i=1
    for x in $(seq 1 $slots); do 
        if [[ ${try[*]:$x-1:1} == ${code[*]:$x:1} ]]; then
            feedback[$i,$round]=$hit
            hit_indexes[(( i-1 ))]=$x
            (( i=i+1 ))
        fi
    done

    # sprawdzam jeśli kod nie został odgadnięty 
    if [[ $i != $(( $slots + 1)) ]]; then
        for x in $(seq 1 $slots); do 
            if [[ ! " ${hit_indexes[*]} " =~ $x ]]; then
                # echo "x = " $x
                for c in $(seq 1 $slots); do 
                    # echo "c = " $c
                    if [[ $x != $c && (! " ${hit_indexes[*]} " =~ $c) && (! " ${missed_indexes[*]} " =~ $c) && ${code[*]:$c:1} == ${try[*]:$x-1:1} ]]; then
                        # echo "x " $x "sprawdzam z c = " $c
                        missed_indexes[(( i-1 ))]=$c
                        feedback[$i,$round]=$missed
                        (( i=i+1 ))
                        break
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

        echo
        echo "Guess the code"
        echo 
        try=$(get_try)
        # echo $try

        set_board $round $try
        check_try $round $try
        game_on=$?
        # echo $game_on
        display_board
    done

    echo -e "GAME END\t\t rounds: " $round
}

Help(){
  #Display help
  echo "Description: Contains mechanizms for game MasterMind. Try: perl game.pl."
	echo "usage: $0 [-h] [-g] [-t] [-0]"
  echo
  echo "Options:"
  echo -e "-h --help\t\t\t\t\t\tDisplays help"
  echo -e "-g GAME, --game GAME FEEDBACK\t\t\t\tSet initial game"
  echo -e "-t TRY ROUND, --try TRY ROUND\t\t\t\t\tChecks given combination for given round"
  # echo -e "-s, --start\t\t\t\t\t\tStart the game"
  echo -e "-0\t\t\t\t\t\t\tReturn initial game"
}

while (( "$#" )); do
    arg=$1
    case $arg in
        -h|--help)
            help=1
            ;;
        -g|--game)
            isb=true
            shift
            initial_game=$1
            ;;
        -t|--try)
            shift
            try=$1
            round=$2
            shift
            ;;
        # -s|--start)
        #     shift
        #     start=1
        #     ;;
        -0)
            is0=true
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

if [[ "$is0" == true ]] ; then
    empty_board
    set_game
fi

if [[ "$isb" == true ]] ; then
    tmp=($(echo -n $initial_game | tr ':' "\n"))
    if [[ "${tmp[0]}" != "board" ]] ; then
        exit 1;
    fi
    rounds=$((${tmp[1]}))
    slots=$((${tmp[2]}))
    empty_board
    tmp_board=($(echo -n ${tmp[3]} | sed 's/,,/,_,/g;s/,,/,_,/g;s/^,/_,/g;s/,$//g' | tr ',' "\n"))
    # echo "temp 3" $initial_game
    tmp_feedback=($(echo -n ${tmp[4]} | sed 's/,,/,_,/g;s/,,/,_,/g;s/^,/_,/g;s/,$//g' | tr ',' "\n"))
    code=($(echo -n \t,${tmp[5]} | tr ',' " "))
    unset 'code[0]'
    # echo "code " ${code[0]}
    i=0
    for y in $(seq 1 $rounds) ; do
        for x in $(seq 1 $slots) ; do 
            char=${tmp_board[$i]}
            # echo "$i $x $y $char"
            if [[ "$char" == "_" || "$char" == "" ]] ; then
              board[$x,$y]=' '
            else
              board[$x,$y]=$char
            fi
            i=$(($i + 1))
        done
    done
    i=0
    for y in $(seq 1 $rounds) ; do
        for x in $(seq 1 $slots) ; do 
            char=${tmp_feedback[$i]}
            # echo "$i $x $y $char"
            if [[ "$char" == "_" || "$char" == "" ]] ; then
              feedback[$x,$y]=' '
            else
              feedback[$x,$y]=$char #niby działa ale jak wypisujemy w display to nic nie ma ????????????????
              # echo -n "feed: x$x y$y" ${feedback[$x,$y]}
            fi
            i=$(($i + 1))
        done
    done
fi

if [[ "$try" != "" ]] ; then
  # echo "echo code: " ${code[*]} "echo try: " $try

  set_board $round $try
  check_try $round $try
  win=$?

  display_game_raw
  if [[ $round -lt $rounds && $win -eq 0  ]] ; then
    echo "win:" 0 #w trakcie
  elif [[ $round -le $rounds && $win -eq 1  ]] ; then
    echo "win:" 1 #wygrana
  elif [[ $round -eq $rounds && $win -eq 0  ]] ; then
    echo "win:" -1 #przefrana
  fi

  # display_board
  
  exit 0
fi

if [[ "$is0" == "true" ]] ; then
    display_game_raw
    exit 0
fi

# if (( start )) ; then
#     echo "Find the code"
#     echo
#     echo "Use first letter of the color to try it in a sequence."
#     echo "Don't use spaces!"
#     echo "Aviable colors:"
#     echo -e "red" "yellow" "blue" "green" "purple"
#     echo 
#     game
# fi

exit 0
