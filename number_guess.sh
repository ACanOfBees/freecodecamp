#!/bin/bash
PSQL="psql --username=freecodecamp --dbname=number_guess -t --no-align -c"

PLAY_GAME(){
  USERNAME=$1
  NUM_BEST_GAME=$2
  # game start
  SECRET_NUMBER=$(( $RANDOM % 1000 + 1 ))
  # initialize counter
  COUNTER=0
  echo "Guess the secret number between 1 and 1000:"
  while [[ $NUMBER != $SECRET_NUMBER ]]
  do
    # count try
    COUNTER=$(( $COUNTER + 1 ))
    # input number
    read NUMBER
    # if input is a number
    if [[ $NUMBER =~ ^[0-9]+$ ]]
    then
      # if input is higher than random number
      if [[ $NUMBER > $SECRET_NUMBER ]]
      then
        echo "It's lower than that, guess again:"
      # if input is lower than random number
      elif [[ $NUMBER < $SECRET_NUMBER ]]
      then
        echo "It's higher than that, guess again:"
      # if number == secret number
      else
        echo "You guessed it in $COUNTER tries. The secret number was $SECRET_NUMBER. Nice job!"
        # update games_played
        UPDATE_GAMES_PLAYED=$($PSQL "update users set games_played=games_played+1 where username='$USERNAME'")
        # if counter < best game
        if [[ $COUNTER < $NUM_BEST_GAME || $NUM_BEST_GAME == 0 ]]
        then
          # update best game
          UPDATE_BEST_GUESSES=$($PSQL "update users set best_game=$COUNTER where username='$USERNAME'")
        fi
      fi
    # if input is not a number
    else
      echo "That is not an integer, guess again:"
    fi  
  done
}

# input username
echo "Enter your username:"
read USERNAME

# fetch user data
DATA=($(echo $($PSQL "select games_played, best_game from users where username='$USERNAME'") | sed 's/|/ /g'))
GAMES_PLAYED=${DATA[0]}
NUM_BEST_GAME=${DATA[1]}

# if data found
if [[ $GAMES_PLAYED ]] 
then
  echo "Welcome back, $USERNAME! You have played $GAMES_PLAYED games, and your best game took $NUM_BEST_GAME guesses."
else
  # if username not found
  echo "Welcome, $USERNAME! It looks like this is your first time here."
  # add user
  INSERT_USER=$($PSQL "insert into users(username) values('$USERNAME')")
  # set best game to 0
  NUM_BEST_GAME=0
fi

PLAY_GAME $USERNAME $NUM_BEST_GAME