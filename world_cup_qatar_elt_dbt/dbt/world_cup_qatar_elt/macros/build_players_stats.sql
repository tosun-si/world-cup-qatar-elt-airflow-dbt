{%
    macro build_player_stats(
        stat_indicator,
        appearances,
        brandSponsorAndUsed,
        club,
        position,
        playerDob,
        playerName
    )
%}

STRUCT(
    MAX({{ stat_indicator }}) AS {{ stat_indicator }},
    ARRAY_AGG(
        IF(
            {{ stat_indicator }} = 0 OR {{ stat_indicator }} = 0.00,
            NULL,
            STRUCT(
                {{ appearances }},
                {{ brandSponsorAndUsed }},
                {{ club }},
                {{ position }},
                {{ playerDob }},
                {{ playerName }}
            )
        )
        ORDER BY {{ stat_indicator }} DESC LIMIT 1
    )
    [OFFSET(0)] AS players
)

{% endmacro %}