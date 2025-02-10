#!/bin/bash
PSQL="psql --username=freecodecamp --dbname=number_guess -t --no-align -c"

echo Enter your username:
read USERNAME

SELECT_USER_RESULT=$($PSQL "SELECT username FROM users WHERE username = '$USERNAME'")

# check if it's first time or existing user
if [[ -z $SELECT_USER_RESULT ]]; then
  echo -e "Welcome, $USERNAME! It looks like this is your first time here."
  INSERT_USERNAME_RESULT=$($PSQL "INSERT INTO users (username) VALUES ('$USERNAME')")
  USERID=$($PSQL "SELECT user_id FROM users WHERE username = '$USERNAME'")

else 
  USERID=$($PSQL "SELECT user_id FROM users WHERE username = '$USERNAME'")
  N_GAMES=$($PSQL "SELECT COUNT(*) FROM games WHERE user_id = $USERID")
  BEST_GAME=$($PSQL "SELECT MAX(number_of_guesses) FROM games WHERE user_id = $USERID")
  echo -e "Welcome back, $USERNAME! You have played $N_GAMES games, and your best game took $BEST_GAME guesses."
fi

# play game
echo Guess the secret number between 1 and 1000:

NUMBER=$((1 + RANDOM % 1000))
N_GUESSES=0

# keep asking for input until guess matches number and track number of guesses
while true; do
    read GUESS
    ((N_GUESSES++))

    # if input is not an integer
    if [[ ! $GUESS =~ ^[0-9]+$ ]]; then
        echo "That is not an integer, guess again:"
    
    elif [[ $GUESS -gt $NUMBER ]]; then
        echo "It's lower than that, guess again:"
    
    elif [[ $GUESS -lt $NUMBER ]]; then
        echo "It's higher than that, guess again:"
    
    elif [[ $GUESS -eq $NUMBER ]]; then
        echo "You guessed it in $N_GUESSES tries. The secret number was $NUMBER. Nice job!"
        INSERT_GAME_RESULT=$($PSQL "INSERT INTO games (user_id, number_of_guesses) VALUES ($USERID, $N_GUESSES)")
        break
    fi
done