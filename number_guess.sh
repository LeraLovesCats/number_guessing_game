#!/bin/bash

PSQL="psql --username=freecodecamp --dbname=number_guess -t --no-align -c"

echo "Enter your username:"
read USERNAME

USERNAME_INFO=$($PSQL "SELECT username FROM number_guess WHERE username='$USERNAME'")

if [[ -z $USERNAME_INFO ]]
then
echo "Welcome, $USERNAME! It looks like this is your first time here."
else
USERNAME_INFO=$($PSQL "SELECT * FROM number_guess WHERE username='$USERNAME'")
echo "$USERNAME_INFO" | while IFS="|" read USERNAME BEST_GAME GAMES_PLAYED
do
echo "Welcome back, $USERNAME! You have played $GAMES_PLAYED games, and your best game took $BEST_GAME guesses."
done
fi

echo "Guess the secret number between 1 and 1000:"
read INPUT

RANDOM_NUMBER=$(( $RANDOM % 1000 + 1 ))
NUMBER_OF_GUESSES=1

while [[ $INPUT != $RANDOM_NUMBER ]]
do
  if [[ $INPUT =~ ^[0-9]+$ ]]
  then
    if [[ $RANDOM_NUMBER -lt $INPUT ]]
    then
    echo "It's lower than that, guess again:"
    read INPUT
    ((NUMBER_OF_GUESSES++))
    else 
    echo "It's higher than that, guess again:"
    read INPUT
    ((NUMBER_OF_GUESSES++))
    fi
  else
  echo "That is not an integer, guess again:"
  read INPUT  
fi
done

echo "You guessed it in $NUMBER_OF_GUESSES tries. The secret number was $RANDOM_NUMBER. Nice job!" 

if [[ -z $USERNAME_INFO ]]
then
GAMES_PLAYED=1
echo $($PSQL "INSERT INTO number_guess(username, best_game, games_played) VALUES('$USERNAME', $NUMBER_OF_GUESSES, $GAMES_PLAYED)")
else
  BEST_GAME=$($PSQL "SELECT best_game FROM number_guess WHERE username='$USERNAME'")
  GAMES_PLAYED=$($PSQL "SELECT games_played FROM number_guess WHERE username='$USERNAME'")
  ((GAMES_PLAYED++))
  if [[ $NUMBER_OF_GUESSES -lt $BEST_GAME ]]
  then
  echo $($PSQL "UPDATE number_guess SET best_game=$NUMBER_OF_GUESSES, games_played=$GAMES_PLAYED WHERE username='$USERNAME'")
  else
  echo $($PSQL "UPDATE number_guess SET games_played=$GAMES_PLAYED WHERE username='$USERNAME'")
  fi  
fi



