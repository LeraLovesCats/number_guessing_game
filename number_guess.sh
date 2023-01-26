#!/bin/bash

PSQL="psql --username=freecodecamp --dbname=number_guess -t --no-align -c"

echo "Enter your username:"
read USERNAME

USER=$($PSQL "SELECT username FROM number_guess WHERE username='$USERNAME'")

if [[ -z $USER ]]
then
echo "Welcome, $USERNAME! It looks like this is your first time here."
echo $($PSQL "INSERT INTO number_guess(username, best_game, games_played) VALUES('$USERNAME', 0, 0)")
else
BEST_GAME=$($PSQL "SELECT best_game FROM number_guess WHERE username='$USERNAME'")
GAMES_PLAYED=$($PSQL "SELECT games_played FROM number_guess WHERE username='$USERNAME'")
echo "Welcome back, $USERNAME! You have played $GAMES_PLAYED games, and your best game took $BEST_GAME guesses." 
fi

echo "Guess the secret number between 1 and 1000:"
read INPUT

RANDOM_NUMBER=$(( $RANDOM % 10 + 1 ))
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

BEST_GAME=$($PSQL "SELECT best_game FROM number_guess WHERE username='$USERNAME'")
GAMES_PLAYED=$($PSQL "SELECT games_played FROM number_guess WHERE username='$USERNAME'")
((GAMES_PLAYED++))
echo $($PSQL "UPDATE number_guess SET games_played=$GAMES_PLAYED WHERE username='$USERNAME'")

if [[ $NUMBER_OF_GUESSES < $BEST_GAME || $BEST_GAME == 0 ]]
then
echo $($PSQL "UPDATE number_guess SET best_game=$NUMBER_OF_GUESSES WHERE username='$USERNAME'")
fi  