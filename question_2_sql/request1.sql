-- A la date actuelle du 3 mai 2024, aucun des utilisateurs âgés de + de 30 ans ayant regardé 2h de film sur mobile en mai 2023 avait moins de 14 mois depuis la création du compte. 
-- On part donc du principe que la date actuelle est la date la plus récente de la table watch 2023-10-20

with visionnage_mobile as (
    select
          watch.user_id
        , sum(watch.duration) as total_seconds_watched
    from
        `molotov.watch` as watch
    where
          watch.device_type = 'phone'
        and watch.program_kind = 'Films'
        and extract(year from watch.date_day) = 2023
        and extract(month from watch.date_day) = 5
    group by
        watch.user_id
    having
        sum(watch.duration) > 7200 -- plus de deux heures en secondes
),
details_utilisateurs as (
    select
          users.id
        , users.birthday
        , users.account_creation_date
        , date_diff(date('2023-10-20'), date(users.birthday), year) as age
        , date_diff(date('2023-10-20'), date(users.account_creation_date), month) as months_since_signup
    from
        `molotov.users` as users
    where
          date_diff(date('2023-10-20'), date(users.birthday), year) > 30
        and date_diff(date('2023-10-20'), date(users.account_creation_date), month) < 12
)

select
      u.id
    , u.birthday
    , u.account_creation_date
    , u.age
    , u.months_since_signup
    , m.total_seconds_watched
from
    details_utilisateurs u
inner join
    visionnage_mobile m on u.id = m.user_id;
