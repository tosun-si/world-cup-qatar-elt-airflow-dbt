{{config(
        materialized='table',
        partition_by={
          "field": "ingestionDate",
          "data_type": "timestamp",
          "granularity": "day"
        },
        cluster_by = ["teamName"]
)}}

with

team_players_stat_raw AS (
    SELECT * FROM {{ ref('team_players_stat_raw_cleaned') }}
),

goalKeepersStats AS (
    SELECT
        nationality,
        STRUCT(
            playerName,
            appearances,
            savePercentage,
            cleanSheets
        ) AS goalKeeperStatsStruct
    FROM team_players_stat_raw
    WHERE isGoalKeeperStatsExist is TRUE
),

goalKeeperStatsPerTeam AS (
    SELECT
        nationality,
        ARRAY_AGG(goalKeeperStatsStruct ORDER BY goalKeeperStatsStruct.savePercentage DESC LIMIT 1)[OFFSET(0)] AS stats
    FROM goalKeepersStats
    GROUP BY
        nationality
)

SELECT
    statRaw.nationality AS teamName,
    nationalTeamKitSponsor,
    fifaRanking,
    SUM(goalsScored) AS teamTotalGoals,
    current_timestamp() AS ingestionDate,

    goalKeeperStatsPerTeam.stats AS goalKeeper,

    {{
        build_player_stats(
            'goalsScored',
            'appearances',
            'brandSponsorAndUsed',
            'club',
            'position',
            'playerDob',
            'playerName'
        )
    }}
    AS topScorers,

    {{
        build_player_stats(
            'assistsProvided',
            'appearances',
            'brandSponsorAndUsed',
            'club',
            'position',
            'playerDob',
            'playerName'
        )
    }}
    AS bestPassers,

    {{
        build_player_stats(
            'dribblesPerNinety',
            'appearances',
            'brandSponsorAndUsed',
            'club',
            'position',
            'playerDob',
            'playerName'
        )
    }}
    AS bestDribblers,

    {{
        build_player_stats(
            'appearances',
            'appearances',
            'brandSponsorAndUsed',
            'club',
            'position',
            'playerDob',
            'playerName'
        )
    }}
    AS playersMostAppearances,

    {{
        build_player_stats(
            'totalDuelsWonPerNinety',
            'appearances',
            'brandSponsorAndUsed',
            'club',
            'position',
            'playerDob',
            'playerName'
        )
    }}
    AS playersMostDuelsWon,

    {{
        build_player_stats(
            'interceptionsPerNinety',
            'appearances',
            'brandSponsorAndUsed',
            'club',
            'position',
            'playerDob',
            'playerName'
        )
    }}
    AS playersMostInterception,

    {{
        build_player_stats(
            'tacklesPerNinety',
            'appearances',
            'brandSponsorAndUsed',
            'club',
            'position',
            'playerDob',
            'playerName'
        )
    }}
    AS playersMostSuccessfulTackles

FROM team_players_stat_raw statRaw
JOIN goalKeeperStatsPerTeam ON statRaw.nationality = goalKeeperStatsPerTeam.nationality
GROUP BY
    statRaw.nationality,
    nationalTeamKitSponsor,
    fifaRanking,
    goalKeeperStatsPerTeam.stats