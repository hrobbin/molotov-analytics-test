-- Requête pour visualiser parmis ceux qui sont actuellement abonnés à l'offre Molotov Extra
-- les requêtes ont été réalisées sur bigquery et transposées içi elles utilisent des fonctions GoogleSQL 
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
        sum(watch.duration) > 7200
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
),
abonnements_extra_actifs as (
    select
        subscriptions.user_id
    from
        `molotov.subscriptions` as subscriptions
    where
          subscriptions.product_name = 'Molotov Extra'
        and subscriptions.subscription_begin_date <= '2023-10-20'
        and (subscriptions.subscription_end_date is null or subscriptions.subscription_end_date > '2023-10-20')
)

select
      count(distinct u.id) as total_users
    , count(distinct s.user_id) as extra_subscribers
    , safe_divide(count(distinct s.user_id), count(distinct u.id)) as subscription_rate
from
    details_utilisateurs u
join
    visionnage_mobile m on u.id = m.user_id
left join
    abonnements_extra_actifs s on u.id = s.user_id;

