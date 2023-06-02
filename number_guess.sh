#!/bin/bash
PSQL="psql --username=freecodecamp --dbname=number_guess -t --no-align -c"
MAIN_MENU() {
  read SECRET_NR
  if ! [[ $SECRET_NR =~ ^[0-9]+$ ]] 
  then
    echo "That is not an integer, guess again:"
    MAIN_MENU
  else
    NR_OF_GUESSES=$(( $NR_OF_GUESSES + 1 ))
    if [[ $SECRET_NR -gt $NR_TO_GUESS ]]
    then
      echo "It's lower than that, guess again:"
      MAIN_MENU
    elif [[ $SECRET_NR -lt $NR_TO_GUESS ]]
    then
      echo "It's higher than that, guess again:"
      MAIN_MENU
    else
      echo "You guessed it in $NR_OF_GUESSES tries. The secret number was $NR_TO_GUESS. Nice job!"
      UPDATE_CUSTOMER_GAMES=$($PSQL "UPDATE client SET games_db=$GAMES_PLAYED+1 WHERE client_id=$CUSTOMER_ID")
      if [[ $NR_OF_GUESSES -lt $BEST_GAME ]]
      then
         UPDATE_CUSTOMER_RESULT=$($PSQL "UPDATE client SET best_db=$NR_OF_GUESSES WHERE client_id=$CUSTOMER_ID")
      fi
    fi
  fi
}

INIT() {
  echo -e "Enter your username:"
  read USERNAME
  USERNAME="$(echo -e "${USERNAME}" | sed -e 's/^[[:space:]]*//')"
  if [[ ${#USERNAME} -lt 1 ]] ||  [[ ${#USERNAME} -gt 22 ]]   
  then
    INIT
  else
    CUSTOMER_ID=$($PSQL "SELECT client_id FROM client WHERE username_db = '$USERNAME'")
    if [[ -z $CUSTOMER_ID ]]
    then
      echo "Welcome, $USERNAME! It looks like this is your first time here."
      INSERT_CUSTOMER_RESULT=$($PSQL "INSERT INTO  client(username_db) VALUES('$USERNAME')")
      CUSTOMER_ID=$($PSQL "SELECT client_id FROM client WHERE username_db = '$USERNAME'")
      GAMES_PLAYED=$($PSQL "SELECT games_db FROM client WHERE client_id=$CUSTOMER_ID")
      BEST_GAME=$($PSQL "SELECT best_db FROM client WHERE client_id=$CUSTOMER_ID") 
    else 
      GAMES_PLAYED=$($PSQL "SELECT games_db FROM client WHERE client_id=$CUSTOMER_ID")
      BEST_GAME=$($PSQL "SELECT best_db FROM client WHERE client_id=$CUSTOMER_ID")  
      echo "Welcome back, $USERNAME! You have played $GAMES_PLAYED games, and your best game took $BEST_GAME guesses."
    fi

    NR_TO_GUESS=$(( $RANDOM % 1000 + 1 ))
    NR_OF_GUESSES=0
    echo "Guess the secret number between 1 and 1000:"
  fi
}

INIT
MAIN_MENU