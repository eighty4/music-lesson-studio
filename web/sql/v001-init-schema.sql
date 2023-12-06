create schema music_lesson_studio;

create table music_lesson_studio.logins
(
    id serial primary key,
    email varchar not null,
    token char(6) not null constraint token_length_chk check (char_length(token) = 6),
    created timestamp not null default now()
);

create table music_lesson_studio.users
(
    id      uuid primary key   default gen_random_uuid(),
    email   varchar   not null,
    name    varchar   not null,
    created timestamp not null default now()
);

create table music_lesson_studio.organizations
(
    id      uuid primary key   default gen_random_uuid(),
    name    varchar   not null,
    created timestamp not null default now()
);

create table music_lesson_studio.teachers
(
    user_id uuid not null references users(id),
    organization_id uuid not null references organizations(id),
    constraint teacher_pkey primary key (user_id, organization_id)
);

create table music_lesson_studio.courses
(
    id uuid primary key default gen_random_uuid(),
    name varchar not null,
    created timestamp not null default now()
);

create table music_lesson_studio.classes
(
    id uuid primary key default gen_random_uuid(),
    created timestamp not null default now()
);

create table music_lesson_studio.lesson_plans
(
    id uuid primary key default gen_random_uuid(),
    created timestamp not null default now()
);

create table music_lesson_studio.lesson_units
(
    id uuid primary key default gen_random_uuid(),
    created timestamp not null default now()
);
