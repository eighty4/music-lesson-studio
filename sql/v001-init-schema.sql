create schema music_lesson_studio;

create type music_lesson_studio.instrument as enum ('banjo', 'guitar', 'mandolin', 'ukulele');

create table music_lesson_studio.logins
(
    id       serial primary key,
    email    varchar   not null
        constraint email_valid_chk check (email ~* '^.*@.*$'),
    token    char(6)   not null
        constraint token_length_chk check (char_length(token) = 6),
    path     varchar
        constraint path_valid_chk check (path ~* '^(\/[a-z0-9\-\_]*)+(\?.*)?$'),
    created  timestamp not null default now(),
    verified timestamp
);

create index login_email_index on music_lesson_studio.logins using btree (email);
create index login_token_index on music_lesson_studio.logins using btree (token);

create table music_lesson_studio.users
(
    id      uuid primary key not null default gen_random_uuid(),
    email   varchar          not null
        constraint email_valid_chk check (email ~* '^.*@.*$'),
    name    varchar          not null,
    created timestamp        not null default now()
);

create table music_lesson_studio.schools
(
    id      uuid primary key not null default gen_random_uuid(),
    name    varchar          not null,
    created timestamp        not null default now()
);

create table music_lesson_studio.teachers
(
    user_id   uuid    not null references music_lesson_studio.users (id),
    school_id uuid    not null references music_lesson_studio.schools (id),
    admin     boolean not null default false,
    constraint teacher_pkey primary key (user_id, school_id)
);

create table music_lesson_studio.courses
(
    id      uuid primary key not null default gen_random_uuid(),
    name    varchar          not null,
    created timestamp        not null default now()
);

create table music_lesson_studio.classes
(
    id             uuid primary key not null default gen_random_uuid(),
    start_date     timestamp        not null,
    duration_weeks int              not null
        constraint duration_weeks_pos_int_chk check (duration_weeks > 0),
    created        timestamp        not null default now()
);

create table music_lesson_studio.lesson_plans
(
    id         uuid primary key               not null default gen_random_uuid(),
    user_id    uuid                           not null references music_lesson_studio.users (id),
    name       varchar                        not null,
    instrument music_lesson_studio.instrument not null,
    created    timestamp                      not null default now(),
    updated    timestamp                      not null default now()
);

create table music_lesson_studio.lesson_units
(
    id             uuid primary key   default gen_random_uuid(),
    lesson_plan_id uuid      not null references music_lesson_studio.lesson_plans (id),
    name           varchar   not null,
    created        timestamp not null default now()
);
