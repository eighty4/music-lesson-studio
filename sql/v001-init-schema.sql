create schema music_lesson_studio;

create table music_lesson_studio.logins
(
    id       serial primary key,
    email    varchar   not null,
    token    char(6)   not null
        constraint token_length_chk check (char_length(token) = 6),
    created  timestamp not null default now(),
    verified timestamp
);

create table music_lesson_studio.users
(
    id      uuid primary key   default gen_random_uuid(),
    email   varchar   not null,
    name    varchar   not null,
    created timestamp not null default now()
);

create table music_lesson_studio.schools
(
    id      uuid primary key   default gen_random_uuid(),
    name    varchar   not null,
    created timestamp not null default now()
);

create table music_lesson_studio.admins
(
    user_id   uuid not null references music_lesson_studio.users (id),
    school_id uuid not null references music_lesson_studio.schools (id),
    constraint admin_pkey primary key (user_id, school_id)
);

create table music_lesson_studio.teachers
(
    user_id   uuid not null references music_lesson_studio.users (id),
    school_id uuid not null references music_lesson_studio.schools (id),
    constraint teacher_pkey primary key (user_id, school_id)
);

create table music_lesson_studio.courses
(
    id      uuid primary key   default gen_random_uuid(),
    name    varchar   not null,
    created timestamp not null default now()
);

create table music_lesson_studio.classes
(
    id             uuid primary key   default gen_random_uuid(),
    start_date     timestamp not null,
    duration_weeks int       not null
        constraint duration_weeks_pos_int_chk check (duration_weeks > 0),
    created        timestamp not null default now()
);

create table music_lesson_studio.lesson_plans
(
    id      uuid primary key   default gen_random_uuid(),
    name    varchar   not null,
    created timestamp not null default now()
);

create table music_lesson_studio.lesson_units
(
    id      uuid primary key   default gen_random_uuid(),
    name    varchar   not null,
    created timestamp not null default now()
);
