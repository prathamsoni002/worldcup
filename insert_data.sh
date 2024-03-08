#!/bin/bash

if [[ $1 == "test" ]]; then
  PSQL="psql --username=postgres --dbname=worldcuptest -t --no-align -c"
else
  PSQL="psql --username=freecodecamp --dbname=worldcup -t --no-align -c"
fi

# Do not change code above this line. Use the PSQL variable above to query your database.
echo "$($PSQL "TRUNCATE TABLE teams, games RESTART IDENTITY;")"
# Skip the header line from the CSV file
tail -n +2 games.csv | awk 'BEGIN { FS="," } { print $3 "\n" $4 }' | sort -u | while read -r NAME; do
  echo "Entering the details: $NAME"
  echo "$($PSQL "INSERT INTO teams (name) VALUES ('$NAME')")"
done


# Skip the header line from the CSV file
tail -n +2 games.csv | while IFS="," read YEAR ROUND WINNER OPPONENT WINNER_GOALS OPPONENT_GOALS; do   
  # Retrieve winner and opponent IDs
  WINNER_ID=$(echo "$($PSQL "SELECT team_id FROM teams WHERE name = '$WINNER'")")
  OPPONENT_ID=$(echo "$($PSQL "SELECT team_id FROM teams WHERE name = '$OPPONENT'")")
  
  # Insert the data into the database: worldcup :: table: games
  echo -e "\nEntering the details: $YEAR, $ROUND, $WINNER_GOALS, $OPPONENT_GOALS"
  echo "$($PSQL "INSERT INTO games (year, round, winner_id, opponent_id, winner_goals, opponent_goals) VALUES ('$YEAR', '$ROUND', $WINNER_ID, $OPPONENT_ID, $WINNER_GOALS, $OPPONENT_GOALS)")"
done

