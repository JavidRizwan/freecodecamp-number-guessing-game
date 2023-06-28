#!/bin/bash

PSQL="psql --username=freecodecamp --dbname=number_guess -t --no-align -c"

echo Enter your username:
read USERNAME

USER_ID=$($PSQL "SELECT user_id FROM users WHERE username='$USERNAME'")

if [[ -z $USER_ID ]]
then
  echo "Welcome, $USERNAME! It looks like this is your first time here."
else
  GAMES_PLAYED=$($PSQL "SELECT COUNT(number_of_guesses) FROM games WHERE user_id=$USER_ID")
  BEST_GAME=$($PSQL "SELECT MIN(number_of_guesses) FROM games WHERE user_id=$USER_ID")
 
  echo "Welcome back, $USERNAME! You have played $GAMES_PLAYED games, and your best game took $BEST_GAME guesses."
 
fi

RANDOM_NUMBER=$((1 + $RANDOM % 1000))
echo "Guess the secret number between 1 and 1000:"

RANDOM_NUMBER_CHECK () {
  read GUESS
  if [[ $GUESS =~ ^[0-9]+$ ]]
  then
    if [[ $RANDOM_NUMBER = $GUESS ]]
    then
      if [[ -z $USER_ID ]]
      then
        INSERT_USERNAME_RESULT=$($PSQL "INSERT INTO users(username) VALUES('$USERNAME')");
      fi
      USER_ID=$($PSQL "SELECT user_id FROM users WHERE username='$USERNAME'")
      INSERT_GAME_RESULT=$($PSQL "INSERT INTO games(number_of_guesses, user_id) VALUES($1, $USER_ID)")
      echo "You guessed it in $1 tries. The secret number was $RANDOM_NUMBER. Nice job!"
    else
      if [[ $RANDOM_NUMBER > $GUESS ]]
      then
        echo "It's higher than that, guess again:"
        RANDOM_NUMBER_CHECK $(($1+1))
      else
        echo "It's lower than that, guess again:"
        RANDOM_NUMBER_CHECK $(($1+1))
      fi
    fi
  else
    echo "That is not an integer, guess again:"
    RANDOM_NUMBER_CHECK $(($1+1))
  fi
}

RANDOM_NUMBER_CHECK 1
