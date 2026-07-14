#!/bin/bash

# Database connection
PSQL="psql --username=freecodecamp --dbname=periodic_table -t --no-align -c"

# If no argument, print usage message
if [[ -z $1 ]]; then
  echo "Please provide an element as an argument."
  exit 0
fi

# Determine if input is a number or string
ARG=$1
if [[ $ARG =~ ^[0-9]+$ ]]; then
  # Atomic number
  QUERY="SELECT e.atomic_number, e.symbol, e.name, t.type, p.atomic_mass, p.melting_point_celsius, p.boiling_point_celsius
         FROM elements e
         JOIN properties p ON e.atomic_number = p.atomic_number
         JOIN types t ON p.type_id = t.type_id
         WHERE e.atomic_number = $ARG"
else
  # Symbol or name (case-insensitive)
  QUERY="SELECT e.atomic_number, e.symbol, e.name, t.type, p.atomic_mass, p.melting_point_celsius, p.boiling_point_celsius
         FROM elements e
         JOIN properties p ON e.atomic_number = p.atomic_number
         JOIN types t ON p.type_id = t.type_id
         WHERE e.symbol = '$ARG' OR e.name = '$ARG'"
fi

# Execute query
RESULT=$($PSQL "$QUERY")

# If no result, print not found
if [[ -z $RESULT ]]; then
  echo "I could not find that element in the database."
  exit 0
fi

# Parse the result
IFS='|' read -r ATOMIC_NUMBER SYMBOL NAME TYPE MASS MELTING BOILING <<< "$RESULT"

# Output in required format
echo "The element with atomic number $ATOMIC_NUMBER is $NAME ($SYMBOL). It's a $TYPE, with a mass of $MASS amu. $NAME has a melting point of $MELTING celsius and a boiling point of $BOILING celsius."