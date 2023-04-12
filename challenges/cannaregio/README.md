# cannaregio

## How postgresql_anonymizer works

- The masking engine creates a view mask.users that will apply the masking rules over the public.users table.
- The masking engine revokes all permissions from the role ctf on the table public.users
- The masking engine changes the search_path of the ctf  to 'mask, public'

With this search_path trick, when the role ctf types SELECT * FROM users  instead of selecting the public.users table, it will select the mask.users view.

## Bypassing

The role is incorrectly configured to have access to public.users directly. This means that when doing `SELECT * FROM users;` mask.users will be used, but you can directly query the raw data with `SELECT * FROM public.users;`.

docker pull registry.gitlab.com/dalibo/postgresql_anonymizer:stable

``` sql
SELECT anon.start_dynamic_masking();

-- replace with sakila or something
CREATE DATABASE storefront;

CREATE ROLE ctf WITH LOGIN NOSUPERUSER NOCREATEDB NOCREATEROLE NOREPLICATION PASSWORD 'ctf';

GRANT pg_read_all_data TO ctf;

<!-- GRANT CONNECT ON DATABASE storefront TO ctf; -->
<!-- GRANT USAGE ON SCHEMA public TO ctf; -->

<!-- GRANT SELECT ON ALL TABLES IN SCHEMA public TO ctf; -->
<!-- GRANT SELECT ON ALL SEQUENCES IN SCHEMA public TO ctf; -->
<!-- REVOKE CREATE ON SCHEMA public FROM PUBLIC; -->

SECURITY LABEL FOR anon ON ROLE ctf IS 'MASKED';

SECURITY LABEL FOR anon
  ON COLUMN users.email
  IS 'MASKED WITH VALUE ''CONFIDENTIAL'' ';
```
