#! /bin/bash
PSQL="psql --username=freecodecamp --dbname=periodic_table -t --no-align -c"

if [[ -z $1 ]]; then
  echo Please provide an element as an argument.
  exit
fi

# check if input is numeric
if [[ $1 =~ ^[0-9]+$ ]]; then
  ATOMIC_NUMBER=$($PSQL "SELECT atomic_number FROM elements WHERE atomic_number = $1")

  # if atomic_number not found
  if [[ -z $ATOMIC_NUMBER ]]; then
    echo I could not find that element in the database.
    exit

  else
    # get other element properties
    NAME=$($PSQL "SELECT name FROM elements WHERE atomic_number = $ATOMIC_NUMBER")
    SYMBOL=$($PSQL "SELECT symbol FROM elements WHERE atomic_number = $ATOMIC_NUMBER")
  fi

# check if input is >2 characters
elif [[ ${#1} -gt 2 ]]; then
  NAME=$($PSQL "SELECT name FROM elements WHERE name = '$1'")
  # if name not found
  if [[ -z $NAME ]]; then
    echo I could not find that element in the database.
    exit
  else
    # get other element properties
    ATOMIC_NUMBER=$($PSQL "SELECT atomic_number FROM elements WHERE name = '$NAME'")
    SYMBOL=$($PSQL "SELECT symbol FROM elements WHERE name = '$NAME'")
  fi

else
  SYMBOL=$($PSQL "SELECT symbol FROM elements WHERE symbol = '$1'")
  # if symbol not found
  if [[ -z $SYMBOL ]]; then
    echo I could not find that element in the database.
    exit
  else
    # get other element properties
    ATOMIC_NUMBER=$($PSQL "SELECT atomic_number FROM elements WHERE symbol = '$SYMBOL'")
    NAME=$($PSQL "SELECT name FROM elements WHERE symbol = '$SYMBOL'")
  fi
fi

MASS=$($PSQL "SELECT atomic_mass FROM properties WHERE atomic_number = $ATOMIC_NUMBER")
MELTING_POINT=$($PSQL "SELECT melting_point_celsius FROM properties WHERE atomic_number = $ATOMIC_NUMBER")
BOILING_POINT=$($PSQL "SELECT boiling_point_celsius FROM properties WHERE atomic_number = $ATOMIC_NUMBER")
TYPE=$($PSQL "SELECT type FROM properties AS p LEFT JOIN types AS t ON p.type_id = t.type_id  WHERE atomic_number = $ATOMIC_NUMBER")

# GET_NAME $INPUT
echo -e "The element with atomic number $ATOMIC_NUMBER is $NAME ($SYMBOL). It's a $TYPE, with a mass of $MASS amu. $NAME has a melting point of $MELTING_POINT celsius and a boiling point of $BOILING_POINT celsius."
