#!/bin/sh
if [ $# -lt 3 ]; then
    echo "usage: ./2024-OSS-Project1.sh file1 file2 file3"
    exit 1
elif [[ $1 != *.csv ]] || [[ $2 != *.csv ]] || [[ $3 != *.csv ]]; then
    echo "error: Invalid file format."
    exit 1
fi

echo "*********OSS1 - Project1*********"
echo "*     StudentID : 12212305      *"
echo "*     Name : Yoon Jiwon         *"
echo "*********************************"

answer=0
while [ $answer != 7 ]
do
    echo -e
    echo "[MENU]"
    echo "1. Get the data of Heung-Min Son's Current Club, Apperances, Goals, Assists in players.csv"
    echo "2. Get the team data to enter a league position in teams.csv"
    echo "3. Get the Top-3 Attendance matches in matches.csv"
    echo "4. Get the team's league position and team's top scorer in teams.csv & players.csv"
    echo "5. Get the modified format of date_GMT in matches.csv"
    echo "6. Get the data of the winning team by the largest difference on home stadium in teams.csv & matches.csv"
    echo "7. Exit"
    read -p "Enter your CHOICE (1~7) : " answer
    
    case "$answer" in
    1)
        read -p "Do you want to get the Heung-Min Son's data? (y/n) : " yORn
        if [ $yORn = y ]; then
            cat players.csv | grep "Heung-Min Son" | awk -F ',' '{printf("Team: %s, Apperance: %d, Goal: %d, Assist: %d\n", $4, $6, $7, $8)}'
        fi ;;
    2)
        read -p "What do you want to get the team data of league_position[1~20] : " league_position
        cat teams.csv | awk -F ',' -v lp=$league_position '$6==lp {print $6, $1, $2/($2+$3+$4)}'
        ;;
    3)
        read -p "Do you want to know Top-3 attendance data? (y/n) : " yORn
        if [ $yORn = y ]; then 
            echo "***Top-3 Attendace Match***"
            cat matches.csv | sort -nr -t, -k2 | awk -F ',' 'NR<=3 {printf("\n%s vs %s (%s)\n%d %s\n", $3, $4, $1, $2, $7)}'
        fi ;;
    4)
        read -p "Do you want to get each team's ranking and the highest-scoring player? (y/n) : " yORn
        if [ $yORn = y ]; then 
            team_ranking=$(cat teams.csv | sort -n -t, -k6 | cut -d, -f1 | awk 'NR>1')
            rank=1   
            IFS=$'\n'
            for var in $team_ranking;
            do
                echo -e
                echo $rank $var
                cat players.csv | grep "$var" -a | sort -rn -t, -k7 | awk -F ',' 'NR==1 {printf("%s %d\n",$1, $7)}'
                ((rank++))
            done
        fi ;;
    5)
        read -p "Do you want to modify the format of date? (y/n) : " yORn
        if [ $yORn = y ]; then 
            cat matches.csv | cut -d, -f1 | sed 's/Aug \([0-9]\{2\}\) \([0-9]\{4\}\) -/\2\/03\/\1/g' | awk 'NR>1 && NR<=11'
        fi ;;
    6)
        IFS=$'\n'
        PS3="Enter your team number : "
        select var in $(cat teams.csv | cut -d, -f1 | awk 'NR>1')
        do
            max_difference_score=0
            home_team_won_matches=$(cat matches.csv | awk -F ',' -v team=$var '$3==team && $5>$6')
            
            for var2 in $home_team_won_matches;
            do  
                home_score=$(echo $var2 | cut -d, -f5)
                away_score=$(echo $var2 | cut -d, -f6)
                cur_score=$(($home_score-$away_score))
                if [ $max_difference_score -lt $cur_score ]; then 
                    max_difference_score=$cur_score
                fi
            done 
            cat matches.csv | awk -F ',' -v team=$var '$3==team && '"$max_difference_score"'==($5-$6) {printf("\n%s\n%s %d vs %d %s\n", $1, $3, $5, $6, $4)}'
            break
        done
        ;;
    7)
        echo "Bye!" ;;
    *)
        echo "Please enter your choice between 1 to 7." ;;
    esac 
done