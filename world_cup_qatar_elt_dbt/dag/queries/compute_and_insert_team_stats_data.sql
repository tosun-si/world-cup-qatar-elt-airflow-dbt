INSERT INTO `{{project_id}}.{{dataset}}.{{team_stat_table}}`
(
    teamName,
    teamScore,
    teamSlogan,
    teamTotalGoals,
    topScorerStats,
    bestPasserStats,
    ingestionDate
)
SELECT
    team_stats.teamName,
    team_stats.teamScore,
    team_slogan.teamSlogan,
    sum(scorer.goals) as teamTotalGoals,
    ARRAY_AGG(
        STRUCT(
            scorer.scorerFirstName AS firstName,
            scorer.scorerLastName AS lastName,
            scorer.goals AS goals,
            scorer.games AS games
        )
        ORDER BY scorer.goals DESC LIMIT 1
    )[OFFSET(0)] AS topScorerStats,
    ARRAY_AGG(
        STRUCT(
            scorer.scorerFirstName AS firstName,
            scorer.scorerLastName AS lastName,
            scorer.goalAssists AS goalAssists,
            scorer.games AS games
        )
        ORDER BY scorer.goalAssists DESC LIMIT 1
    )[OFFSET(0)] AS bestPasserStats,
    current_timestamp() as ingestionDate
FROM `{{project_id}}.{{dataset}}.{{team_stat_raw_table}}` team_stats
INNER JOIN `{{project_id}}.{{dataset}}.team_slogan` team_slogan ON team_stats.teamName = team_slogan.teamName,
UNNEST(team_stats.scorers) AS scorer
GROUP BY
    team_stats.teamName,
    team_stats.teamScore,
    team_slogan.teamSlogan;

