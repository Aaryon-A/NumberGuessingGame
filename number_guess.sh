#!/bin/bash

PSQL="psql --username=freecodecamp --dbname=number_guess -t --no-align -c"
SECRET_NUMBER=$((1 + $RANDOM % 1000))

echo "~~~ Number Guessing Game ~~~"
echo -e "\n\nEnter your username: "

read USERNAME
USERNAME_STATUS=$($PSQL "SELECT username FROM users WHERE username='$USERNAME'")

if [[ $USERNAME_STATUS ]]
then
  GAMES_PLAYED=$($PSQL "SELECT games_played FROM users WHERE username='$USERNAME'")
  BEST_GAME=$($PSQL "SELECT best_game FROM users WHERE username='$USERNAME'")

  echo -e "\nWelcome back, $USERNAME! You have played $GAMES_PLAYED games, and your best game took $BEST_GAME guesses."
else
  echo -e "\nWelcome, $USERNAME! It looks like this is your first time here."
  INSERT_USER=$($PSQL "INSERT INTO users(username) VALUES('$USERNAME')")
fi

GUESS_NUMBER() {
  if [[ $1 ]]
  then
    echo -e "\n$1"
  fi
}

GUESS_NUMBER
GUESS=0
NUMBER_OF_GUESSES=0
echo -e "\nGuess the secret number between 1 and 1000:"

while [[ $GUESS != $SECRET_NUMBER ]]
do
  if [[ ! $GUESS =~ ^[0-9]+$ ]]
  then
    GUESS_NUMBER "That is not an integer, guess again:"
  fi

  read GUESS
  NUMBER_OF_GUESSES=$(($NUMBER_OF_GUESSES+1))
  if [[ $GUESS > $SECRET_NUMBER ]]
  then
    GUESS_NUMBER "It's lower than that, guess again:"
  elif [[ $GUESS < $SECRET_NUMBER ]]
  then
    GUESS_NUMBER "It's higher than that, guess again:"
  fi

done

echo -e "\nYou guessed it in $NUMBER_OF_GUESSES tries. The secret number was $SECRET_NUMBER. Nice job!"

GAMES_PLAYED=$(($GAMES_PLAYED + 1))
CHANGE_GAMES_PLAYED=$($PSQL "UPDATE users SET games_played=$GAMES_PLAYED WHERE username='$USERNAME'")

if [[ $NUMBER_OF_GUESSES < $BEST_GAME ]]
then
  CHANGE_BEST_GUESSES=$($PSQL "UPDATE users SET best_game=$NUMBER_OF_GUESSES WHERE username='$USERNAME'")
elif [[ -z $USERNAME_STATUS ]]
then
  CHANGE_BEST_GUESSES=$($PSQL "UPDATE users SET best_game=$NUMBER_OF_GUESSES WHERE username='$USERNAME'")
fi