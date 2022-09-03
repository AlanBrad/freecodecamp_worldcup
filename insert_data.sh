#! /bin/bash

if [[ $1 == "test" ]]
then
  PSQL="psql --username=postgres --dbname=worldcuptest -t --no-align -c"
else
  PSQL="psql --username=freecodecamp --dbname=worldcup -t --no-align -c"
fi

# Do not change code above this line. Use the PSQL variable above to query your database.
echo $($PSQL "TRUNCATE TABLE games, teams")

cat games.csv | while IFS="," read YEAR ROUND WINNER OPPONENT WINNER_GOALS OPPONENT_GOALS
do
  if [[ $YEAR != year ]]
    then
      #insert teams
      #
      #get winner_team_id
      WINNER_TEAM_ID=$($PSQL "select team_id from teams where name='$WINNER'")

      #if not found
      if [[ -z $WINNER_TEAM_ID ]]
        then
          #insert winner
          INSERT_WINNER_RESULT=$($PSQL "insert into teams(name) values ('$WINNER')")
          if [[ $INSERT_WINNER_RESULT == "INSERT 0 1" ]]
            then
              echo Inserted into teams, winner: $WINNER
          fi
          #get new team_id
          WINNER_TEAM_ID=$($PSQL "select team_id from teams where name='$WINNER'")
      fi

      #get opponent_team_id
      OPPONENT_TEAM_ID=$($PSQL "select team_id from teams where name='$OPPONENT'")

      #if not found
      if [[ -z $OPPONENT_TEAM_ID ]]
        then
          #insert opponent
          INSERT_OPPONENT_RESULT=$($PSQL "insert into teams(name) values ('$OPPONENT')")
          if [[ $INSERT_OPPONENT_RESULT == "INSERT 0 1" ]]
            then
              echo Inserted into teams, opponent: $OPPONENT
          fi
          #get new team_id
          OPPONENT_TEAM_ID=$($PSQL "select team_id from teams where name='$WINNER'")
      fi

      #insert games
      #
      #get game_id
      GAME_ID=$($PSQL "select game_id from games inner join teams as w on games.winner_id=w.team_id inner join teams as o on games.opponent_id=o.team_id where year=$YEAR and round='$ROUND' and w.name='$WINNER' and o.name='$OPPONENT' and winner_goals=$WINNER_GOALS and opponent_goals=$OPPONENT_GOALS")

      #if not found
      if [[ -z $GAME_ID ]]
        then
          #insert games row
          INSERT_GAMES_RESULT=$($PSQL "insert into games(year, round, winner_id, opponent_id, winner_goals, opponent_goals) values ($YEAR, '$ROUND', $WINNER_TEAM_ID, $OPPONENT_TEAM_ID, $WINNER_GOALS, $OPPONENT_GOALS)")
          if [[ $INSERT_GAMES_RESULT == "INSERT 0 1" ]]
            then
              echo Inserted into games, $YEAR, $ROUND, $WINNER, $OPPONENT, $WINNER_GOALS, $OPPONENT_GOALS 
          fi
          #get new game_id
          GAME_ID=$($PSQL "select game_id from games inner join teams as w on games.winner_id=w.team_id inner join teams as o on games.opponent_id=o.team_id where year=$YEAR and round='$ROUND' and w.name='$WINNER' and o.name='$OPPONENT' and winner_goals=$WINNER_GOALS and opponent_goals=$OPPONENT_GOALS")
      fi
                                                                                                                                 #YEAR ROUND WINNER OPPONENT WINNER_GOALS OPPONENT_GOALS
  fi
done
