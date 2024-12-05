{{config(
        materialized='view'
)}}

SELECT
    nationality,
    SAFE_CAST(goalsScored AS INT64) AS goalsScored,
    SAFE_CAST(assistsProvided AS INT64) AS assistsProvided,
    SAFE_CAST(dribblesPerNinety AS FLOAT64) AS dribblesPerNinety,
    SAFE_CAST(appearances AS INT64) AS appearances,
    SAFE_CAST(totalDuelsWonPerNinety AS FLOAT64) AS totalDuelsWonPerNinety,
    SAFE_CAST(interceptionsPerNinety AS FLOAT64) AS interceptionsPerNinety,
    SAFE_CAST(tacklesPerNinety AS FLOAT64) AS tacklesPerNinety,
    brandSponsorAndUsed,
    club,
    savePercentage,
    IF(savePercentage <> "-", TRUE, FALSE) AS isGoalKeeperStatsExist,
    fifaRanking,
    position,
    playerName,
    cleanSheets,
    nationalTeamKitSponsor,
    nationalTeamJerseyNumber,
    playerDob
from `{{ target.dataset }}.team_players_stat_raw`