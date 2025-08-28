pg_dump: warning: there are circular foreign-key constraints on this table:
pg_dump: detail: key
pg_dump: hint: You might not be able to restore the dump without using --disable-triggers or temporarily dropping the constraints.
pg_dump: hint: Consider using a full dump instead of a --data-only dump to avoid this problem.
--
-- PostgreSQL database dump
--

-- Dumped from database version 15.8
-- Dumped by pg_dump version 15.8

SET statement_timeout = 0;
SET lock_timeout = 0;
SET idle_in_transaction_session_timeout = 0;
SET client_encoding = 'UTF8';
SET standard_conforming_strings = on;
SELECT pg_catalog.set_config('search_path', '', false);
SET check_function_bodies = false;
SET xmloption = content;
SET client_min_messages = warning;
SET row_security = off;

--
-- Name: _realtime; Type: SCHEMA; Schema: -; Owner: postgres
--

CREATE SCHEMA _realtime;


ALTER SCHEMA _realtime OWNER TO postgres;

--
-- Name: auth; Type: SCHEMA; Schema: -; Owner: supabase_admin
--

CREATE SCHEMA auth;


ALTER SCHEMA auth OWNER TO supabase_admin;

--
-- Name: extensions; Type: SCHEMA; Schema: -; Owner: postgres
--

CREATE SCHEMA extensions;


ALTER SCHEMA extensions OWNER TO postgres;

--
-- Name: graphql; Type: SCHEMA; Schema: -; Owner: supabase_admin
--

CREATE SCHEMA graphql;


ALTER SCHEMA graphql OWNER TO supabase_admin;

--
-- Name: graphql_public; Type: SCHEMA; Schema: -; Owner: supabase_admin
--

CREATE SCHEMA graphql_public;


ALTER SCHEMA graphql_public OWNER TO supabase_admin;

--
-- Name: pg_net; Type: EXTENSION; Schema: -; Owner: -
--

CREATE EXTENSION IF NOT EXISTS pg_net WITH SCHEMA extensions;


--
-- Name: EXTENSION pg_net; Type: COMMENT; Schema: -; Owner: 
--

COMMENT ON EXTENSION pg_net IS 'Async HTTP';


--
-- Name: pgbouncer; Type: SCHEMA; Schema: -; Owner: pgbouncer
--

CREATE SCHEMA pgbouncer;


ALTER SCHEMA pgbouncer OWNER TO pgbouncer;

--
-- Name: pgsodium; Type: SCHEMA; Schema: -; Owner: supabase_admin
--

CREATE SCHEMA pgsodium;


ALTER SCHEMA pgsodium OWNER TO supabase_admin;

--
-- Name: pgsodium; Type: EXTENSION; Schema: -; Owner: -
--

CREATE EXTENSION IF NOT EXISTS pgsodium WITH SCHEMA pgsodium;


--
-- Name: EXTENSION pgsodium; Type: COMMENT; Schema: -; Owner: 
--

COMMENT ON EXTENSION pgsodium IS 'Pgsodium is a modern cryptography library for Postgres.';


--
-- Name: realtime; Type: SCHEMA; Schema: -; Owner: supabase_admin
--

CREATE SCHEMA realtime;


ALTER SCHEMA realtime OWNER TO supabase_admin;

--
-- Name: storage; Type: SCHEMA; Schema: -; Owner: supabase_admin
--

CREATE SCHEMA storage;


ALTER SCHEMA storage OWNER TO supabase_admin;

--
-- Name: supabase_functions; Type: SCHEMA; Schema: -; Owner: supabase_admin
--

CREATE SCHEMA supabase_functions;


ALTER SCHEMA supabase_functions OWNER TO supabase_admin;

--
-- Name: vault; Type: SCHEMA; Schema: -; Owner: supabase_admin
--

CREATE SCHEMA vault;


ALTER SCHEMA vault OWNER TO supabase_admin;

--
-- Name: pg_graphql; Type: EXTENSION; Schema: -; Owner: -
--

CREATE EXTENSION IF NOT EXISTS pg_graphql WITH SCHEMA graphql;


--
-- Name: EXTENSION pg_graphql; Type: COMMENT; Schema: -; Owner: 
--

COMMENT ON EXTENSION pg_graphql IS 'pg_graphql: GraphQL support';


--
-- Name: pg_stat_statements; Type: EXTENSION; Schema: -; Owner: -
--

CREATE EXTENSION IF NOT EXISTS pg_stat_statements WITH SCHEMA extensions;


--
-- Name: EXTENSION pg_stat_statements; Type: COMMENT; Schema: -; Owner: 
--

COMMENT ON EXTENSION pg_stat_statements IS 'track planning and execution statistics of all SQL statements executed';


--
-- Name: pgcrypto; Type: EXTENSION; Schema: -; Owner: -
--

CREATE EXTENSION IF NOT EXISTS pgcrypto WITH SCHEMA extensions;


--
-- Name: EXTENSION pgcrypto; Type: COMMENT; Schema: -; Owner: 
--

COMMENT ON EXTENSION pgcrypto IS 'cryptographic functions';


--
-- Name: pgjwt; Type: EXTENSION; Schema: -; Owner: -
--

CREATE EXTENSION IF NOT EXISTS pgjwt WITH SCHEMA extensions;


--
-- Name: EXTENSION pgjwt; Type: COMMENT; Schema: -; Owner: 
--

COMMENT ON EXTENSION pgjwt IS 'JSON Web Token API for Postgresql';


--
-- Name: supabase_vault; Type: EXTENSION; Schema: -; Owner: -
--

CREATE EXTENSION IF NOT EXISTS supabase_vault WITH SCHEMA vault;


--
-- Name: EXTENSION supabase_vault; Type: COMMENT; Schema: -; Owner: 
--

COMMENT ON EXTENSION supabase_vault IS 'Supabase Vault Extension';


--
-- Name: uuid-ossp; Type: EXTENSION; Schema: -; Owner: -
--

CREATE EXTENSION IF NOT EXISTS "uuid-ossp" WITH SCHEMA extensions;


--
-- Name: EXTENSION "uuid-ossp"; Type: COMMENT; Schema: -; Owner: 
--

COMMENT ON EXTENSION "uuid-ossp" IS 'generate universally unique identifiers (UUIDs)';


--
-- Name: aal_level; Type: TYPE; Schema: auth; Owner: supabase_auth_admin
--

CREATE TYPE auth.aal_level AS ENUM (
    'aal1',
    'aal2',
    'aal3'
);


ALTER TYPE auth.aal_level OWNER TO supabase_auth_admin;

--
-- Name: code_challenge_method; Type: TYPE; Schema: auth; Owner: supabase_auth_admin
--

CREATE TYPE auth.code_challenge_method AS ENUM (
    's256',
    'plain'
);


ALTER TYPE auth.code_challenge_method OWNER TO supabase_auth_admin;

--
-- Name: factor_status; Type: TYPE; Schema: auth; Owner: supabase_auth_admin
--

CREATE TYPE auth.factor_status AS ENUM (
    'unverified',
    'verified'
);


ALTER TYPE auth.factor_status OWNER TO supabase_auth_admin;

--
-- Name: factor_type; Type: TYPE; Schema: auth; Owner: supabase_auth_admin
--

CREATE TYPE auth.factor_type AS ENUM (
    'totp',
    'webauthn',
    'phone'
);


ALTER TYPE auth.factor_type OWNER TO supabase_auth_admin;

--
-- Name: one_time_token_type; Type: TYPE; Schema: auth; Owner: supabase_auth_admin
--

CREATE TYPE auth.one_time_token_type AS ENUM (
    'confirmation_token',
    'reauthentication_token',
    'recovery_token',
    'email_change_token_new',
    'email_change_token_current',
    'phone_change_token'
);


ALTER TYPE auth.one_time_token_type OWNER TO supabase_auth_admin;

--
-- Name: action; Type: TYPE; Schema: realtime; Owner: supabase_admin
--

CREATE TYPE realtime.action AS ENUM (
    'INSERT',
    'UPDATE',
    'DELETE',
    'TRUNCATE',
    'ERROR'
);


ALTER TYPE realtime.action OWNER TO supabase_admin;

--
-- Name: equality_op; Type: TYPE; Schema: realtime; Owner: supabase_admin
--

CREATE TYPE realtime.equality_op AS ENUM (
    'eq',
    'neq',
    'lt',
    'lte',
    'gt',
    'gte',
    'in'
);


ALTER TYPE realtime.equality_op OWNER TO supabase_admin;

--
-- Name: user_defined_filter; Type: TYPE; Schema: realtime; Owner: supabase_admin
--

CREATE TYPE realtime.user_defined_filter AS (
	column_name text,
	op realtime.equality_op,
	value text
);


ALTER TYPE realtime.user_defined_filter OWNER TO supabase_admin;

--
-- Name: wal_column; Type: TYPE; Schema: realtime; Owner: supabase_admin
--

CREATE TYPE realtime.wal_column AS (
	name text,
	type_name text,
	type_oid oid,
	value jsonb,
	is_pkey boolean,
	is_selectable boolean
);


ALTER TYPE realtime.wal_column OWNER TO supabase_admin;

--
-- Name: wal_rls; Type: TYPE; Schema: realtime; Owner: supabase_admin
--

CREATE TYPE realtime.wal_rls AS (
	wal jsonb,
	is_rls_enabled boolean,
	subscription_ids uuid[],
	errors text[]
);


ALTER TYPE realtime.wal_rls OWNER TO supabase_admin;

--
-- Name: email(); Type: FUNCTION; Schema: auth; Owner: supabase_auth_admin
--

CREATE FUNCTION auth.email() RETURNS text
    LANGUAGE sql STABLE
    AS $$
  select 
  coalesce(
    nullif(current_setting('request.jwt.claim.email', true), ''),
    (nullif(current_setting('request.jwt.claims', true), '')::jsonb ->> 'email')
  )::text
$$;


ALTER FUNCTION auth.email() OWNER TO supabase_auth_admin;

--
-- Name: FUNCTION email(); Type: COMMENT; Schema: auth; Owner: supabase_auth_admin
--

COMMENT ON FUNCTION auth.email() IS 'Deprecated. Use auth.jwt() -> ''email'' instead.';


--
-- Name: jwt(); Type: FUNCTION; Schema: auth; Owner: supabase_auth_admin
--

CREATE FUNCTION auth.jwt() RETURNS jsonb
    LANGUAGE sql STABLE
    AS $$
  select 
    coalesce(
        nullif(current_setting('request.jwt.claim', true), ''),
        nullif(current_setting('request.jwt.claims', true), '')
    )::jsonb
$$;


ALTER FUNCTION auth.jwt() OWNER TO supabase_auth_admin;

--
-- Name: role(); Type: FUNCTION; Schema: auth; Owner: supabase_auth_admin
--

CREATE FUNCTION auth.role() RETURNS text
    LANGUAGE sql STABLE
    AS $$
  select 
  coalesce(
    nullif(current_setting('request.jwt.claim.role', true), ''),
    (nullif(current_setting('request.jwt.claims', true), '')::jsonb ->> 'role')
  )::text
$$;


ALTER FUNCTION auth.role() OWNER TO supabase_auth_admin;

--
-- Name: FUNCTION role(); Type: COMMENT; Schema: auth; Owner: supabase_auth_admin
--

COMMENT ON FUNCTION auth.role() IS 'Deprecated. Use auth.jwt() -> ''role'' instead.';


--
-- Name: uid(); Type: FUNCTION; Schema: auth; Owner: supabase_auth_admin
--

CREATE FUNCTION auth.uid() RETURNS uuid
    LANGUAGE sql STABLE
    AS $$
  select 
  coalesce(
    nullif(current_setting('request.jwt.claim.sub', true), ''),
    (nullif(current_setting('request.jwt.claims', true), '')::jsonb ->> 'sub')
  )::uuid
$$;


ALTER FUNCTION auth.uid() OWNER TO supabase_auth_admin;

--
-- Name: FUNCTION uid(); Type: COMMENT; Schema: auth; Owner: supabase_auth_admin
--

COMMENT ON FUNCTION auth.uid() IS 'Deprecated. Use auth.jwt() -> ''sub'' instead.';


--
-- Name: grant_pg_cron_access(); Type: FUNCTION; Schema: extensions; Owner: postgres
--

CREATE FUNCTION extensions.grant_pg_cron_access() RETURNS event_trigger
    LANGUAGE plpgsql
    AS $$
BEGIN
  IF EXISTS (
    SELECT
    FROM pg_event_trigger_ddl_commands() AS ev
    JOIN pg_extension AS ext
    ON ev.objid = ext.oid
    WHERE ext.extname = 'pg_cron'
  )
  THEN
    grant usage on schema cron to postgres with grant option;

    alter default privileges in schema cron grant all on tables to postgres with grant option;
    alter default privileges in schema cron grant all on functions to postgres with grant option;
    alter default privileges in schema cron grant all on sequences to postgres with grant option;

    alter default privileges for user supabase_admin in schema cron grant all
        on sequences to postgres with grant option;
    alter default privileges for user supabase_admin in schema cron grant all
        on tables to postgres with grant option;
    alter default privileges for user supabase_admin in schema cron grant all
        on functions to postgres with grant option;

    grant all privileges on all tables in schema cron to postgres with grant option;
    revoke all on table cron.job from postgres;
    grant select on table cron.job to postgres with grant option;
  END IF;
END;
$$;


ALTER FUNCTION extensions.grant_pg_cron_access() OWNER TO postgres;

--
-- Name: FUNCTION grant_pg_cron_access(); Type: COMMENT; Schema: extensions; Owner: postgres
--

COMMENT ON FUNCTION extensions.grant_pg_cron_access() IS 'Grants access to pg_cron';


--
-- Name: grant_pg_graphql_access(); Type: FUNCTION; Schema: extensions; Owner: supabase_admin
--

CREATE FUNCTION extensions.grant_pg_graphql_access() RETURNS event_trigger
    LANGUAGE plpgsql
    AS $_$
DECLARE
    func_is_graphql_resolve bool;
BEGIN
    func_is_graphql_resolve = (
        SELECT n.proname = 'resolve'
        FROM pg_event_trigger_ddl_commands() AS ev
        LEFT JOIN pg_catalog.pg_proc AS n
        ON ev.objid = n.oid
    );

    IF func_is_graphql_resolve
    THEN
        -- Update public wrapper to pass all arguments through to the pg_graphql resolve func
        DROP FUNCTION IF EXISTS graphql_public.graphql;
        create or replace function graphql_public.graphql(
            "operationName" text default null,
            query text default null,
            variables jsonb default null,
            extensions jsonb default null
        )
            returns jsonb
            language sql
        as $$
            select graphql.resolve(
                query := query,
                variables := coalesce(variables, '{}'),
                "operationName" := "operationName",
                extensions := extensions
            );
        $$;

        -- This hook executes when `graphql.resolve` is created. That is not necessarily the last
        -- function in the extension so we need to grant permissions on existing entities AND
        -- update default permissions to any others that are created after `graphql.resolve`
        grant usage on schema graphql to postgres, anon, authenticated, service_role;
        grant select on all tables in schema graphql to postgres, anon, authenticated, service_role;
        grant execute on all functions in schema graphql to postgres, anon, authenticated, service_role;
        grant all on all sequences in schema graphql to postgres, anon, authenticated, service_role;
        alter default privileges in schema graphql grant all on tables to postgres, anon, authenticated, service_role;
        alter default privileges in schema graphql grant all on functions to postgres, anon, authenticated, service_role;
        alter default privileges in schema graphql grant all on sequences to postgres, anon, authenticated, service_role;

        -- Allow postgres role to allow granting usage on graphql and graphql_public schemas to custom roles
        grant usage on schema graphql_public to postgres with grant option;
        grant usage on schema graphql to postgres with grant option;
    END IF;

END;
$_$;


ALTER FUNCTION extensions.grant_pg_graphql_access() OWNER TO supabase_admin;

--
-- Name: FUNCTION grant_pg_graphql_access(); Type: COMMENT; Schema: extensions; Owner: supabase_admin
--

COMMENT ON FUNCTION extensions.grant_pg_graphql_access() IS 'Grants access to pg_graphql';


--
-- Name: grant_pg_net_access(); Type: FUNCTION; Schema: extensions; Owner: postgres
--

CREATE FUNCTION extensions.grant_pg_net_access() RETURNS event_trigger
    LANGUAGE plpgsql
    AS $$
BEGIN
  IF EXISTS (
    SELECT 1
    FROM pg_event_trigger_ddl_commands() AS ev
    JOIN pg_extension AS ext
    ON ev.objid = ext.oid
    WHERE ext.extname = 'pg_net'
  )
  THEN
    GRANT USAGE ON SCHEMA net TO supabase_functions_admin, postgres, anon, authenticated, service_role;

    ALTER function net.http_get(url text, params jsonb, headers jsonb, timeout_milliseconds integer) SECURITY DEFINER;
    ALTER function net.http_post(url text, body jsonb, params jsonb, headers jsonb, timeout_milliseconds integer) SECURITY DEFINER;

    ALTER function net.http_get(url text, params jsonb, headers jsonb, timeout_milliseconds integer) SET search_path = net;
    ALTER function net.http_post(url text, body jsonb, params jsonb, headers jsonb, timeout_milliseconds integer) SET search_path = net;

    REVOKE ALL ON FUNCTION net.http_get(url text, params jsonb, headers jsonb, timeout_milliseconds integer) FROM PUBLIC;
    REVOKE ALL ON FUNCTION net.http_post(url text, body jsonb, params jsonb, headers jsonb, timeout_milliseconds integer) FROM PUBLIC;

    GRANT EXECUTE ON FUNCTION net.http_get(url text, params jsonb, headers jsonb, timeout_milliseconds integer) TO supabase_functions_admin, postgres, anon, authenticated, service_role;
    GRANT EXECUTE ON FUNCTION net.http_post(url text, body jsonb, params jsonb, headers jsonb, timeout_milliseconds integer) TO supabase_functions_admin, postgres, anon, authenticated, service_role;
  END IF;
END;
$$;


ALTER FUNCTION extensions.grant_pg_net_access() OWNER TO postgres;

--
-- Name: FUNCTION grant_pg_net_access(); Type: COMMENT; Schema: extensions; Owner: postgres
--

COMMENT ON FUNCTION extensions.grant_pg_net_access() IS 'Grants access to pg_net';


--
-- Name: pgrst_ddl_watch(); Type: FUNCTION; Schema: extensions; Owner: supabase_admin
--

CREATE FUNCTION extensions.pgrst_ddl_watch() RETURNS event_trigger
    LANGUAGE plpgsql
    AS $$
DECLARE
  cmd record;
BEGIN
  FOR cmd IN SELECT * FROM pg_event_trigger_ddl_commands()
  LOOP
    IF cmd.command_tag IN (
      'CREATE SCHEMA', 'ALTER SCHEMA'
    , 'CREATE TABLE', 'CREATE TABLE AS', 'SELECT INTO', 'ALTER TABLE'
    , 'CREATE FOREIGN TABLE', 'ALTER FOREIGN TABLE'
    , 'CREATE VIEW', 'ALTER VIEW'
    , 'CREATE MATERIALIZED VIEW', 'ALTER MATERIALIZED VIEW'
    , 'CREATE FUNCTION', 'ALTER FUNCTION'
    , 'CREATE TRIGGER'
    , 'CREATE TYPE', 'ALTER TYPE'
    , 'CREATE RULE'
    , 'COMMENT'
    )
    -- don't notify in case of CREATE TEMP table or other objects created on pg_temp
    AND cmd.schema_name is distinct from 'pg_temp'
    THEN
      NOTIFY pgrst, 'reload schema';
    END IF;
  END LOOP;
END; $$;


ALTER FUNCTION extensions.pgrst_ddl_watch() OWNER TO supabase_admin;

--
-- Name: pgrst_drop_watch(); Type: FUNCTION; Schema: extensions; Owner: supabase_admin
--

CREATE FUNCTION extensions.pgrst_drop_watch() RETURNS event_trigger
    LANGUAGE plpgsql
    AS $$
DECLARE
  obj record;
BEGIN
  FOR obj IN SELECT * FROM pg_event_trigger_dropped_objects()
  LOOP
    IF obj.object_type IN (
      'schema'
    , 'table'
    , 'foreign table'
    , 'view'
    , 'materialized view'
    , 'function'
    , 'trigger'
    , 'type'
    , 'rule'
    )
    AND obj.is_temporary IS false -- no pg_temp objects
    THEN
      NOTIFY pgrst, 'reload schema';
    END IF;
  END LOOP;
END; $$;


ALTER FUNCTION extensions.pgrst_drop_watch() OWNER TO supabase_admin;

--
-- Name: set_graphql_placeholder(); Type: FUNCTION; Schema: extensions; Owner: supabase_admin
--

CREATE FUNCTION extensions.set_graphql_placeholder() RETURNS event_trigger
    LANGUAGE plpgsql
    AS $_$
    DECLARE
    graphql_is_dropped bool;
    BEGIN
    graphql_is_dropped = (
        SELECT ev.schema_name = 'graphql_public'
        FROM pg_event_trigger_dropped_objects() AS ev
        WHERE ev.schema_name = 'graphql_public'
    );

    IF graphql_is_dropped
    THEN
        create or replace function graphql_public.graphql(
            "operationName" text default null,
            query text default null,
            variables jsonb default null,
            extensions jsonb default null
        )
            returns jsonb
            language plpgsql
        as $$
            DECLARE
                server_version float;
            BEGIN
                server_version = (SELECT (SPLIT_PART((select version()), ' ', 2))::float);

                IF server_version >= 14 THEN
                    RETURN jsonb_build_object(
                        'errors', jsonb_build_array(
                            jsonb_build_object(
                                'message', 'pg_graphql extension is not enabled.'
                            )
                        )
                    );
                ELSE
                    RETURN jsonb_build_object(
                        'errors', jsonb_build_array(
                            jsonb_build_object(
                                'message', 'pg_graphql is only available on projects running Postgres 14 onwards.'
                            )
                        )
                    );
                END IF;
            END;
        $$;
    END IF;

    END;
$_$;


ALTER FUNCTION extensions.set_graphql_placeholder() OWNER TO supabase_admin;

--
-- Name: FUNCTION set_graphql_placeholder(); Type: COMMENT; Schema: extensions; Owner: supabase_admin
--

COMMENT ON FUNCTION extensions.set_graphql_placeholder() IS 'Reintroduces placeholder function for graphql_public.graphql';


--
-- Name: get_auth(text); Type: FUNCTION; Schema: pgbouncer; Owner: postgres
--

CREATE FUNCTION pgbouncer.get_auth(p_usename text) RETURNS TABLE(username text, password text)
    LANGUAGE plpgsql SECURITY DEFINER
    AS $$
BEGIN
    RAISE WARNING 'PgBouncer auth request: %', p_usename;

    RETURN QUERY
    SELECT usename::TEXT, passwd::TEXT FROM pg_catalog.pg_shadow
    WHERE usename = p_usename;
END;
$$;


ALTER FUNCTION pgbouncer.get_auth(p_usename text) OWNER TO postgres;

--
-- Name: apply_rls(jsonb, integer); Type: FUNCTION; Schema: realtime; Owner: supabase_admin
--

CREATE FUNCTION realtime.apply_rls(wal jsonb, max_record_bytes integer DEFAULT (1024 * 1024)) RETURNS SETOF realtime.wal_rls
    LANGUAGE plpgsql
    AS $$
declare
-- Regclass of the table e.g. public.notes
entity_ regclass = (quote_ident(wal ->> 'schema') || '.' || quote_ident(wal ->> 'table'))::regclass;

-- I, U, D, T: insert, update ...
action realtime.action = (
    case wal ->> 'action'
        when 'I' then 'INSERT'
        when 'U' then 'UPDATE'
        when 'D' then 'DELETE'
        else 'ERROR'
    end
);

-- Is row level security enabled for the table
is_rls_enabled bool = relrowsecurity from pg_class where oid = entity_;

subscriptions realtime.subscription[] = array_agg(subs)
    from
        realtime.subscription subs
    where
        subs.entity = entity_;

-- Subscription vars
roles regrole[] = array_agg(distinct us.claims_role::text)
    from
        unnest(subscriptions) us;

working_role regrole;
claimed_role regrole;
claims jsonb;

subscription_id uuid;
subscription_has_access bool;
visible_to_subscription_ids uuid[] = '{}';

-- structured info for wal's columns
columns realtime.wal_column[];
-- previous identity values for update/delete
old_columns realtime.wal_column[];

error_record_exceeds_max_size boolean = octet_length(wal::text) > max_record_bytes;

-- Primary jsonb output for record
output jsonb;

begin
perform set_config('role', null, true);

columns =
    array_agg(
        (
            x->>'name',
            x->>'type',
            x->>'typeoid',
            realtime.cast(
                (x->'value') #>> '{}',
                coalesce(
                    (x->>'typeoid')::regtype, -- null when wal2json version <= 2.4
                    (x->>'type')::regtype
                )
            ),
            (pks ->> 'name') is not null,
            true
        )::realtime.wal_column
    )
    from
        jsonb_array_elements(wal -> 'columns') x
        left join jsonb_array_elements(wal -> 'pk') pks
            on (x ->> 'name') = (pks ->> 'name');

old_columns =
    array_agg(
        (
            x->>'name',
            x->>'type',
            x->>'typeoid',
            realtime.cast(
                (x->'value') #>> '{}',
                coalesce(
                    (x->>'typeoid')::regtype, -- null when wal2json version <= 2.4
                    (x->>'type')::regtype
                )
            ),
            (pks ->> 'name') is not null,
            true
        )::realtime.wal_column
    )
    from
        jsonb_array_elements(wal -> 'identity') x
        left join jsonb_array_elements(wal -> 'pk') pks
            on (x ->> 'name') = (pks ->> 'name');

for working_role in select * from unnest(roles) loop

    -- Update `is_selectable` for columns and old_columns
    columns =
        array_agg(
            (
                c.name,
                c.type_name,
                c.type_oid,
                c.value,
                c.is_pkey,
                pg_catalog.has_column_privilege(working_role, entity_, c.name, 'SELECT')
            )::realtime.wal_column
        )
        from
            unnest(columns) c;

    old_columns =
            array_agg(
                (
                    c.name,
                    c.type_name,
                    c.type_oid,
                    c.value,
                    c.is_pkey,
                    pg_catalog.has_column_privilege(working_role, entity_, c.name, 'SELECT')
                )::realtime.wal_column
            )
            from
                unnest(old_columns) c;

    if action <> 'DELETE' and count(1) = 0 from unnest(columns) c where c.is_pkey then
        return next (
            jsonb_build_object(
                'schema', wal ->> 'schema',
                'table', wal ->> 'table',
                'type', action
            ),
            is_rls_enabled,
            -- subscriptions is already filtered by entity
            (select array_agg(s.subscription_id) from unnest(subscriptions) as s where claims_role = working_role),
            array['Error 400: Bad Request, no primary key']
        )::realtime.wal_rls;

    -- The claims role does not have SELECT permission to the primary key of entity
    elsif action <> 'DELETE' and sum(c.is_selectable::int) <> count(1) from unnest(columns) c where c.is_pkey then
        return next (
            jsonb_build_object(
                'schema', wal ->> 'schema',
                'table', wal ->> 'table',
                'type', action
            ),
            is_rls_enabled,
            (select array_agg(s.subscription_id) from unnest(subscriptions) as s where claims_role = working_role),
            array['Error 401: Unauthorized']
        )::realtime.wal_rls;

    else
        output = jsonb_build_object(
            'schema', wal ->> 'schema',
            'table', wal ->> 'table',
            'type', action,
            'commit_timestamp', to_char(
                ((wal ->> 'timestamp')::timestamptz at time zone 'utc'),
                'YYYY-MM-DD"T"HH24:MI:SS.MS"Z"'
            ),
            'columns', (
                select
                    jsonb_agg(
                        jsonb_build_object(
                            'name', pa.attname,
                            'type', pt.typname
                        )
                        order by pa.attnum asc
                    )
                from
                    pg_attribute pa
                    join pg_type pt
                        on pa.atttypid = pt.oid
                where
                    attrelid = entity_
                    and attnum > 0
                    and pg_catalog.has_column_privilege(working_role, entity_, pa.attname, 'SELECT')
            )
        )
        -- Add "record" key for insert and update
        || case
            when action in ('INSERT', 'UPDATE') then
                jsonb_build_object(
                    'record',
                    (
                        select
                            jsonb_object_agg(
                                -- if unchanged toast, get column name and value from old record
                                coalesce((c).name, (oc).name),
                                case
                                    when (c).name is null then (oc).value
                                    else (c).value
                                end
                            )
                        from
                            unnest(columns) c
                            full outer join unnest(old_columns) oc
                                on (c).name = (oc).name
                        where
                            coalesce((c).is_selectable, (oc).is_selectable)
                            and ( not error_record_exceeds_max_size or (octet_length((c).value::text) <= 64))
                    )
                )
            else '{}'::jsonb
        end
        -- Add "old_record" key for update and delete
        || case
            when action = 'UPDATE' then
                jsonb_build_object(
                        'old_record',
                        (
                            select jsonb_object_agg((c).name, (c).value)
                            from unnest(old_columns) c
                            where
                                (c).is_selectable
                                and ( not error_record_exceeds_max_size or (octet_length((c).value::text) <= 64))
                        )
                    )
            when action = 'DELETE' then
                jsonb_build_object(
                    'old_record',
                    (
                        select jsonb_object_agg((c).name, (c).value)
                        from unnest(old_columns) c
                        where
                            (c).is_selectable
                            and ( not error_record_exceeds_max_size or (octet_length((c).value::text) <= 64))
                            and ( not is_rls_enabled or (c).is_pkey ) -- if RLS enabled, we can't secure deletes so filter to pkey
                    )
                )
            else '{}'::jsonb
        end;

        -- Create the prepared statement
        if is_rls_enabled and action <> 'DELETE' then
            if (select 1 from pg_prepared_statements where name = 'walrus_rls_stmt' limit 1) > 0 then
                deallocate walrus_rls_stmt;
            end if;
            execute realtime.build_prepared_statement_sql('walrus_rls_stmt', entity_, columns);
        end if;

        visible_to_subscription_ids = '{}';

        for subscription_id, claims in (
                select
                    subs.subscription_id,
                    subs.claims
                from
                    unnest(subscriptions) subs
                where
                    subs.entity = entity_
                    and subs.claims_role = working_role
                    and (
                        realtime.is_visible_through_filters(columns, subs.filters)
                        or (
                          action = 'DELETE'
                          and realtime.is_visible_through_filters(old_columns, subs.filters)
                        )
                    )
        ) loop

            if not is_rls_enabled or action = 'DELETE' then
                visible_to_subscription_ids = visible_to_subscription_ids || subscription_id;
            else
                -- Check if RLS allows the role to see the record
                perform
                    -- Trim leading and trailing quotes from working_role because set_config
                    -- doesn't recognize the role as valid if they are included
                    set_config('role', trim(both '"' from working_role::text), true),
                    set_config('request.jwt.claims', claims::text, true);

                execute 'execute walrus_rls_stmt' into subscription_has_access;

                if subscription_has_access then
                    visible_to_subscription_ids = visible_to_subscription_ids || subscription_id;
                end if;
            end if;
        end loop;

        perform set_config('role', null, true);

        return next (
            output,
            is_rls_enabled,
            visible_to_subscription_ids,
            case
                when error_record_exceeds_max_size then array['Error 413: Payload Too Large']
                else '{}'
            end
        )::realtime.wal_rls;

    end if;
end loop;

perform set_config('role', null, true);
end;
$$;


ALTER FUNCTION realtime.apply_rls(wal jsonb, max_record_bytes integer) OWNER TO supabase_admin;

--
-- Name: broadcast_changes(text, text, text, text, text, record, record, text); Type: FUNCTION; Schema: realtime; Owner: supabase_admin
--

CREATE FUNCTION realtime.broadcast_changes(topic_name text, event_name text, operation text, table_name text, table_schema text, new record, old record, level text DEFAULT 'ROW'::text) RETURNS void
    LANGUAGE plpgsql
    AS $$
DECLARE
    -- Declare a variable to hold the JSONB representation of the row
    row_data jsonb := '{}'::jsonb;
BEGIN
    IF level = 'STATEMENT' THEN
        RAISE EXCEPTION 'function can only be triggered for each row, not for each statement';
    END IF;
    -- Check the operation type and handle accordingly
    IF operation = 'INSERT' OR operation = 'UPDATE' OR operation = 'DELETE' THEN
        row_data := jsonb_build_object('old_record', OLD, 'record', NEW, 'operation', operation, 'table', table_name, 'schema', table_schema);
        PERFORM realtime.send (row_data, event_name, topic_name);
    ELSE
        RAISE EXCEPTION 'Unexpected operation type: %', operation;
    END IF;
EXCEPTION
    WHEN OTHERS THEN
        RAISE EXCEPTION 'Failed to process the row: %', SQLERRM;
END;

$$;


ALTER FUNCTION realtime.broadcast_changes(topic_name text, event_name text, operation text, table_name text, table_schema text, new record, old record, level text) OWNER TO supabase_admin;

--
-- Name: build_prepared_statement_sql(text, regclass, realtime.wal_column[]); Type: FUNCTION; Schema: realtime; Owner: supabase_admin
--

CREATE FUNCTION realtime.build_prepared_statement_sql(prepared_statement_name text, entity regclass, columns realtime.wal_column[]) RETURNS text
    LANGUAGE sql
    AS $$
      /*
      Builds a sql string that, if executed, creates a prepared statement to
      tests retrive a row from *entity* by its primary key columns.
      Example
          select realtime.build_prepared_statement_sql('public.notes', '{"id"}'::text[], '{"bigint"}'::text[])
      */
          select
      'prepare ' || prepared_statement_name || ' as
          select
              exists(
                  select
                      1
                  from
                      ' || entity || '
                  where
                      ' || string_agg(quote_ident(pkc.name) || '=' || quote_nullable(pkc.value #>> '{}') , ' and ') || '
              )'
          from
              unnest(columns) pkc
          where
              pkc.is_pkey
          group by
              entity
      $$;


ALTER FUNCTION realtime.build_prepared_statement_sql(prepared_statement_name text, entity regclass, columns realtime.wal_column[]) OWNER TO supabase_admin;

--
-- Name: cast(text, regtype); Type: FUNCTION; Schema: realtime; Owner: supabase_admin
--

CREATE FUNCTION realtime."cast"(val text, type_ regtype) RETURNS jsonb
    LANGUAGE plpgsql IMMUTABLE
    AS $$
    declare
      res jsonb;
    begin
      execute format('select to_jsonb(%L::'|| type_::text || ')', val)  into res;
      return res;
    end
    $$;


ALTER FUNCTION realtime."cast"(val text, type_ regtype) OWNER TO supabase_admin;

--
-- Name: check_equality_op(realtime.equality_op, regtype, text, text); Type: FUNCTION; Schema: realtime; Owner: supabase_admin
--

CREATE FUNCTION realtime.check_equality_op(op realtime.equality_op, type_ regtype, val_1 text, val_2 text) RETURNS boolean
    LANGUAGE plpgsql IMMUTABLE
    AS $$
      /*
      Casts *val_1* and *val_2* as type *type_* and check the *op* condition for truthiness
      */
      declare
          op_symbol text = (
              case
                  when op = 'eq' then '='
                  when op = 'neq' then '!='
                  when op = 'lt' then '<'
                  when op = 'lte' then '<='
                  when op = 'gt' then '>'
                  when op = 'gte' then '>='
                  when op = 'in' then '= any'
                  else 'UNKNOWN OP'
              end
          );
          res boolean;
      begin
          execute format(
              'select %L::'|| type_::text || ' ' || op_symbol
              || ' ( %L::'
              || (
                  case
                      when op = 'in' then type_::text || '[]'
                      else type_::text end
              )
              || ')', val_1, val_2) into res;
          return res;
      end;
      $$;


ALTER FUNCTION realtime.check_equality_op(op realtime.equality_op, type_ regtype, val_1 text, val_2 text) OWNER TO supabase_admin;

--
-- Name: is_visible_through_filters(realtime.wal_column[], realtime.user_defined_filter[]); Type: FUNCTION; Schema: realtime; Owner: supabase_admin
--

CREATE FUNCTION realtime.is_visible_through_filters(columns realtime.wal_column[], filters realtime.user_defined_filter[]) RETURNS boolean
    LANGUAGE sql IMMUTABLE
    AS $_$
    /*
    Should the record be visible (true) or filtered out (false) after *filters* are applied
    */
        select
            -- Default to allowed when no filters present
            $2 is null -- no filters. this should not happen because subscriptions has a default
            or array_length($2, 1) is null -- array length of an empty array is null
            or bool_and(
                coalesce(
                    realtime.check_equality_op(
                        op:=f.op,
                        type_:=coalesce(
                            col.type_oid::regtype, -- null when wal2json version <= 2.4
                            col.type_name::regtype
                        ),
                        -- cast jsonb to text
                        val_1:=col.value #>> '{}',
                        val_2:=f.value
                    ),
                    false -- if null, filter does not match
                )
            )
        from
            unnest(filters) f
            join unnest(columns) col
                on f.column_name = col.name;
    $_$;


ALTER FUNCTION realtime.is_visible_through_filters(columns realtime.wal_column[], filters realtime.user_defined_filter[]) OWNER TO supabase_admin;

--
-- Name: list_changes(name, name, integer, integer); Type: FUNCTION; Schema: realtime; Owner: supabase_admin
--

CREATE FUNCTION realtime.list_changes(publication name, slot_name name, max_changes integer, max_record_bytes integer) RETURNS SETOF realtime.wal_rls
    LANGUAGE sql
    SET log_min_messages TO 'fatal'
    AS $$
      with pub as (
        select
          concat_ws(
            ',',
            case when bool_or(pubinsert) then 'insert' else null end,
            case when bool_or(pubupdate) then 'update' else null end,
            case when bool_or(pubdelete) then 'delete' else null end
          ) as w2j_actions,
          coalesce(
            string_agg(
              realtime.quote_wal2json(format('%I.%I', schemaname, tablename)::regclass),
              ','
            ) filter (where ppt.tablename is not null and ppt.tablename not like '% %'),
            ''
          ) w2j_add_tables
        from
          pg_publication pp
          left join pg_publication_tables ppt
            on pp.pubname = ppt.pubname
        where
          pp.pubname = publication
        group by
          pp.pubname
        limit 1
      ),
      w2j as (
        select
          x.*, pub.w2j_add_tables
        from
          pub,
          pg_logical_slot_get_changes(
            slot_name, null, max_changes,
            'include-pk', 'true',
            'include-transaction', 'false',
            'include-timestamp', 'true',
            'include-type-oids', 'true',
            'format-version', '2',
            'actions', pub.w2j_actions,
            'add-tables', pub.w2j_add_tables
          ) x
      )
      select
        xyz.wal,
        xyz.is_rls_enabled,
        xyz.subscription_ids,
        xyz.errors
      from
        w2j,
        realtime.apply_rls(
          wal := w2j.data::jsonb,
          max_record_bytes := max_record_bytes
        ) xyz(wal, is_rls_enabled, subscription_ids, errors)
      where
        w2j.w2j_add_tables <> ''
        and xyz.subscription_ids[1] is not null
    $$;


ALTER FUNCTION realtime.list_changes(publication name, slot_name name, max_changes integer, max_record_bytes integer) OWNER TO supabase_admin;

--
-- Name: quote_wal2json(regclass); Type: FUNCTION; Schema: realtime; Owner: supabase_admin
--

CREATE FUNCTION realtime.quote_wal2json(entity regclass) RETURNS text
    LANGUAGE sql IMMUTABLE STRICT
    AS $$
      select
        (
          select string_agg('' || ch,'')
          from unnest(string_to_array(nsp.nspname::text, null)) with ordinality x(ch, idx)
          where
            not (x.idx = 1 and x.ch = '"')
            and not (
              x.idx = array_length(string_to_array(nsp.nspname::text, null), 1)
              and x.ch = '"'
            )
        )
        || '.'
        || (
          select string_agg('' || ch,'')
          from unnest(string_to_array(pc.relname::text, null)) with ordinality x(ch, idx)
          where
            not (x.idx = 1 and x.ch = '"')
            and not (
              x.idx = array_length(string_to_array(nsp.nspname::text, null), 1)
              and x.ch = '"'
            )
          )
      from
        pg_class pc
        join pg_namespace nsp
          on pc.relnamespace = nsp.oid
      where
        pc.oid = entity
    $$;


ALTER FUNCTION realtime.quote_wal2json(entity regclass) OWNER TO supabase_admin;

--
-- Name: send(jsonb, text, text, boolean); Type: FUNCTION; Schema: realtime; Owner: supabase_admin
--

CREATE FUNCTION realtime.send(payload jsonb, event text, topic text, private boolean DEFAULT true) RETURNS void
    LANGUAGE plpgsql
    AS $$
DECLARE
  partition_name text;
BEGIN
  partition_name := 'messages_' || to_char(NOW(), 'YYYY_MM_DD');

  IF NOT EXISTS (
    SELECT 1
    FROM pg_class c
    JOIN pg_namespace n ON n.oid = c.relnamespace
    WHERE n.nspname = 'realtime'
    AND c.relname = partition_name
  ) THEN
    EXECUTE format(
      'CREATE TABLE realtime.%I PARTITION OF realtime.messages FOR VALUES FROM (%L) TO (%L)',
      partition_name,
      NOW(),
      (NOW() + interval '1 day')::timestamp
    );
  END IF;

  INSERT INTO realtime.messages (payload, event, topic, private, extension)
  VALUES (payload, event, topic, private, 'broadcast');
END;
$$;


ALTER FUNCTION realtime.send(payload jsonb, event text, topic text, private boolean) OWNER TO supabase_admin;

--
-- Name: subscription_check_filters(); Type: FUNCTION; Schema: realtime; Owner: supabase_admin
--

CREATE FUNCTION realtime.subscription_check_filters() RETURNS trigger
    LANGUAGE plpgsql
    AS $$
    /*
    Validates that the user defined filters for a subscription:
    - refer to valid columns that the claimed role may access
    - values are coercable to the correct column type
    */
    declare
        col_names text[] = coalesce(
                array_agg(c.column_name order by c.ordinal_position),
                '{}'::text[]
            )
            from
                information_schema.columns c
            where
                format('%I.%I', c.table_schema, c.table_name)::regclass = new.entity
                and pg_catalog.has_column_privilege(
                    (new.claims ->> 'role'),
                    format('%I.%I', c.table_schema, c.table_name)::regclass,
                    c.column_name,
                    'SELECT'
                );
        filter realtime.user_defined_filter;
        col_type regtype;

        in_val jsonb;
    begin
        for filter in select * from unnest(new.filters) loop
            -- Filtered column is valid
            if not filter.column_name = any(col_names) then
                raise exception 'invalid column for filter %', filter.column_name;
            end if;

            -- Type is sanitized and safe for string interpolation
            col_type = (
                select atttypid::regtype
                from pg_catalog.pg_attribute
                where attrelid = new.entity
                      and attname = filter.column_name
            );
            if col_type is null then
                raise exception 'failed to lookup type for column %', filter.column_name;
            end if;

            -- Set maximum number of entries for in filter
            if filter.op = 'in'::realtime.equality_op then
                in_val = realtime.cast(filter.value, (col_type::text || '[]')::regtype);
                if coalesce(jsonb_array_length(in_val), 0) > 100 then
                    raise exception 'too many values for `in` filter. Maximum 100';
                end if;
            else
                -- raises an exception if value is not coercable to type
                perform realtime.cast(filter.value, col_type);
            end if;

        end loop;

        -- Apply consistent order to filters so the unique constraint on
        -- (subscription_id, entity, filters) can't be tricked by a different filter order
        new.filters = coalesce(
            array_agg(f order by f.column_name, f.op, f.value),
            '{}'
        ) from unnest(new.filters) f;

        return new;
    end;
    $$;


ALTER FUNCTION realtime.subscription_check_filters() OWNER TO supabase_admin;

--
-- Name: to_regrole(text); Type: FUNCTION; Schema: realtime; Owner: supabase_admin
--

CREATE FUNCTION realtime.to_regrole(role_name text) RETURNS regrole
    LANGUAGE sql IMMUTABLE
    AS $$ select role_name::regrole $$;


ALTER FUNCTION realtime.to_regrole(role_name text) OWNER TO supabase_admin;

--
-- Name: topic(); Type: FUNCTION; Schema: realtime; Owner: supabase_realtime_admin
--

CREATE FUNCTION realtime.topic() RETURNS text
    LANGUAGE sql STABLE
    AS $$
select nullif(current_setting('realtime.topic', true), '')::text;
$$;


ALTER FUNCTION realtime.topic() OWNER TO supabase_realtime_admin;

--
-- Name: can_insert_object(text, text, uuid, jsonb); Type: FUNCTION; Schema: storage; Owner: supabase_storage_admin
--

CREATE FUNCTION storage.can_insert_object(bucketid text, name text, owner uuid, metadata jsonb) RETURNS void
    LANGUAGE plpgsql
    AS $$
BEGIN
  INSERT INTO "storage"."objects" ("bucket_id", "name", "owner", "metadata") VALUES (bucketid, name, owner, metadata);
  -- hack to rollback the successful insert
  RAISE sqlstate 'PT200' using
  message = 'ROLLBACK',
  detail = 'rollback successful insert';
END
$$;


ALTER FUNCTION storage.can_insert_object(bucketid text, name text, owner uuid, metadata jsonb) OWNER TO supabase_storage_admin;

--
-- Name: extension(text); Type: FUNCTION; Schema: storage; Owner: supabase_storage_admin
--

CREATE FUNCTION storage.extension(name text) RETURNS text
    LANGUAGE plpgsql
    AS $$
DECLARE
_parts text[];
_filename text;
BEGIN
	select string_to_array(name, '/') into _parts;
	select _parts[array_length(_parts,1)] into _filename;
	-- @todo return the last part instead of 2
	return reverse(split_part(reverse(_filename), '.', 1));
END
$$;


ALTER FUNCTION storage.extension(name text) OWNER TO supabase_storage_admin;

--
-- Name: filename(text); Type: FUNCTION; Schema: storage; Owner: supabase_storage_admin
--

CREATE FUNCTION storage.filename(name text) RETURNS text
    LANGUAGE plpgsql
    AS $$
DECLARE
_parts text[];
BEGIN
	select string_to_array(name, '/') into _parts;
	return _parts[array_length(_parts,1)];
END
$$;


ALTER FUNCTION storage.filename(name text) OWNER TO supabase_storage_admin;

--
-- Name: foldername(text); Type: FUNCTION; Schema: storage; Owner: supabase_storage_admin
--

CREATE FUNCTION storage.foldername(name text) RETURNS text[]
    LANGUAGE plpgsql
    AS $$
DECLARE
_parts text[];
BEGIN
	select string_to_array(name, '/') into _parts;
	return _parts[1:array_length(_parts,1)-1];
END
$$;


ALTER FUNCTION storage.foldername(name text) OWNER TO supabase_storage_admin;

--
-- Name: get_size_by_bucket(); Type: FUNCTION; Schema: storage; Owner: supabase_storage_admin
--

CREATE FUNCTION storage.get_size_by_bucket() RETURNS TABLE(size bigint, bucket_id text)
    LANGUAGE plpgsql
    AS $$
BEGIN
    return query
        select sum((metadata->>'size')::int) as size, obj.bucket_id
        from "storage".objects as obj
        group by obj.bucket_id;
END
$$;


ALTER FUNCTION storage.get_size_by_bucket() OWNER TO supabase_storage_admin;

--
-- Name: list_multipart_uploads_with_delimiter(text, text, text, integer, text, text); Type: FUNCTION; Schema: storage; Owner: supabase_storage_admin
--

CREATE FUNCTION storage.list_multipart_uploads_with_delimiter(bucket_id text, prefix_param text, delimiter_param text, max_keys integer DEFAULT 100, next_key_token text DEFAULT ''::text, next_upload_token text DEFAULT ''::text) RETURNS TABLE(key text, id text, created_at timestamp with time zone)
    LANGUAGE plpgsql
    AS $_$
BEGIN
    RETURN QUERY EXECUTE
        'SELECT DISTINCT ON(key COLLATE "C") * from (
            SELECT
                CASE
                    WHEN position($2 IN substring(key from length($1) + 1)) > 0 THEN
                        substring(key from 1 for length($1) + position($2 IN substring(key from length($1) + 1)))
                    ELSE
                        key
                END AS key, id, created_at
            FROM
                storage.s3_multipart_uploads
            WHERE
                bucket_id = $5 AND
                key ILIKE $1 || ''%'' AND
                CASE
                    WHEN $4 != '''' AND $6 = '''' THEN
                        CASE
                            WHEN position($2 IN substring(key from length($1) + 1)) > 0 THEN
                                substring(key from 1 for length($1) + position($2 IN substring(key from length($1) + 1))) COLLATE "C" > $4
                            ELSE
                                key COLLATE "C" > $4
                            END
                    ELSE
                        true
                END AND
                CASE
                    WHEN $6 != '''' THEN
                        id COLLATE "C" > $6
                    ELSE
                        true
                    END
            ORDER BY
                key COLLATE "C" ASC, created_at ASC) as e order by key COLLATE "C" LIMIT $3'
        USING prefix_param, delimiter_param, max_keys, next_key_token, bucket_id, next_upload_token;
END;
$_$;


ALTER FUNCTION storage.list_multipart_uploads_with_delimiter(bucket_id text, prefix_param text, delimiter_param text, max_keys integer, next_key_token text, next_upload_token text) OWNER TO supabase_storage_admin;

--
-- Name: list_objects_with_delimiter(text, text, text, integer, text, text); Type: FUNCTION; Schema: storage; Owner: supabase_storage_admin
--

CREATE FUNCTION storage.list_objects_with_delimiter(bucket_id text, prefix_param text, delimiter_param text, max_keys integer DEFAULT 100, start_after text DEFAULT ''::text, next_token text DEFAULT ''::text) RETURNS TABLE(name text, id uuid, metadata jsonb, updated_at timestamp with time zone)
    LANGUAGE plpgsql
    AS $_$
BEGIN
    RETURN QUERY EXECUTE
        'SELECT DISTINCT ON(name COLLATE "C") * from (
            SELECT
                CASE
                    WHEN position($2 IN substring(name from length($1) + 1)) > 0 THEN
                        substring(name from 1 for length($1) + position($2 IN substring(name from length($1) + 1)))
                    ELSE
                        name
                END AS name, id, metadata, updated_at
            FROM
                storage.objects
            WHERE
                bucket_id = $5 AND
                name ILIKE $1 || ''%'' AND
                CASE
                    WHEN $6 != '''' THEN
                    name COLLATE "C" > $6
                ELSE true END
                AND CASE
                    WHEN $4 != '''' THEN
                        CASE
                            WHEN position($2 IN substring(name from length($1) + 1)) > 0 THEN
                                substring(name from 1 for length($1) + position($2 IN substring(name from length($1) + 1))) COLLATE "C" > $4
                            ELSE
                                name COLLATE "C" > $4
                            END
                    ELSE
                        true
                END
            ORDER BY
                name COLLATE "C" ASC) as e order by name COLLATE "C" LIMIT $3'
        USING prefix_param, delimiter_param, max_keys, next_token, bucket_id, start_after;
END;
$_$;


ALTER FUNCTION storage.list_objects_with_delimiter(bucket_id text, prefix_param text, delimiter_param text, max_keys integer, start_after text, next_token text) OWNER TO supabase_storage_admin;

--
-- Name: operation(); Type: FUNCTION; Schema: storage; Owner: supabase_storage_admin
--

CREATE FUNCTION storage.operation() RETURNS text
    LANGUAGE plpgsql STABLE
    AS $$
BEGIN
    RETURN current_setting('storage.operation', true);
END;
$$;


ALTER FUNCTION storage.operation() OWNER TO supabase_storage_admin;

--
-- Name: search(text, text, integer, integer, integer, text, text, text); Type: FUNCTION; Schema: storage; Owner: supabase_storage_admin
--

CREATE FUNCTION storage.search(prefix text, bucketname text, limits integer DEFAULT 100, levels integer DEFAULT 1, offsets integer DEFAULT 0, search text DEFAULT ''::text, sortcolumn text DEFAULT 'name'::text, sortorder text DEFAULT 'asc'::text) RETURNS TABLE(name text, id uuid, updated_at timestamp with time zone, created_at timestamp with time zone, last_accessed_at timestamp with time zone, metadata jsonb)
    LANGUAGE plpgsql STABLE
    AS $_$
declare
  v_order_by text;
  v_sort_order text;
begin
  case
    when sortcolumn = 'name' then
      v_order_by = 'name';
    when sortcolumn = 'updated_at' then
      v_order_by = 'updated_at';
    when sortcolumn = 'created_at' then
      v_order_by = 'created_at';
    when sortcolumn = 'last_accessed_at' then
      v_order_by = 'last_accessed_at';
    else
      v_order_by = 'name';
  end case;

  case
    when sortorder = 'asc' then
      v_sort_order = 'asc';
    when sortorder = 'desc' then
      v_sort_order = 'desc';
    else
      v_sort_order = 'asc';
  end case;

  v_order_by = v_order_by || ' ' || v_sort_order;

  return query execute
    'with folders as (
       select path_tokens[$1] as folder
       from storage.objects
         where objects.name ilike $2 || $3 || ''%''
           and bucket_id = $4
           and array_length(objects.path_tokens, 1) <> $1
       group by folder
       order by folder ' || v_sort_order || '
     )
     (select folder as "name",
            null as id,
            null as updated_at,
            null as created_at,
            null as last_accessed_at,
            null as metadata from folders)
     union all
     (select path_tokens[$1] as "name",
            id,
            updated_at,
            created_at,
            last_accessed_at,
            metadata
     from storage.objects
     where objects.name ilike $2 || $3 || ''%''
       and bucket_id = $4
       and array_length(objects.path_tokens, 1) = $1
     order by ' || v_order_by || ')
     limit $5
     offset $6' using levels, prefix, search, bucketname, limits, offsets;
end;
$_$;


ALTER FUNCTION storage.search(prefix text, bucketname text, limits integer, levels integer, offsets integer, search text, sortcolumn text, sortorder text) OWNER TO supabase_storage_admin;

--
-- Name: update_updated_at_column(); Type: FUNCTION; Schema: storage; Owner: supabase_storage_admin
--

CREATE FUNCTION storage.update_updated_at_column() RETURNS trigger
    LANGUAGE plpgsql
    AS $$
BEGIN
    NEW.updated_at = now();
    RETURN NEW; 
END;
$$;


ALTER FUNCTION storage.update_updated_at_column() OWNER TO supabase_storage_admin;

--
-- Name: http_request(); Type: FUNCTION; Schema: supabase_functions; Owner: supabase_functions_admin
--

CREATE FUNCTION supabase_functions.http_request() RETURNS trigger
    LANGUAGE plpgsql SECURITY DEFINER
    SET search_path TO 'supabase_functions'
    AS $$
  DECLARE
    request_id bigint;
    payload jsonb;
    url text := TG_ARGV[0]::text;
    method text := TG_ARGV[1]::text;
    headers jsonb DEFAULT '{}'::jsonb;
    params jsonb DEFAULT '{}'::jsonb;
    timeout_ms integer DEFAULT 1000;
  BEGIN
    IF url IS NULL OR url = 'null' THEN
      RAISE EXCEPTION 'url argument is missing';
    END IF;

    IF method IS NULL OR method = 'null' THEN
      RAISE EXCEPTION 'method argument is missing';
    END IF;

    IF TG_ARGV[2] IS NULL OR TG_ARGV[2] = 'null' THEN
      headers = '{"Content-Type": "application/json"}'::jsonb;
    ELSE
      headers = TG_ARGV[2]::jsonb;
    END IF;

    IF TG_ARGV[3] IS NULL OR TG_ARGV[3] = 'null' THEN
      params = '{}'::jsonb;
    ELSE
      params = TG_ARGV[3]::jsonb;
    END IF;

    IF TG_ARGV[4] IS NULL OR TG_ARGV[4] = 'null' THEN
      timeout_ms = 1000;
    ELSE
      timeout_ms = TG_ARGV[4]::integer;
    END IF;

    CASE
      WHEN method = 'GET' THEN
        SELECT http_get INTO request_id FROM net.http_get(
          url,
          params,
          headers,
          timeout_ms
        );
      WHEN method = 'POST' THEN
        payload = jsonb_build_object(
          'old_record', OLD,
          'record', NEW,
          'type', TG_OP,
          'table', TG_TABLE_NAME,
          'schema', TG_TABLE_SCHEMA
        );

        SELECT http_post INTO request_id FROM net.http_post(
          url,
          payload,
          params,
          headers,
          timeout_ms
        );
      ELSE
        RAISE EXCEPTION 'method argument % is invalid', method;
    END CASE;

    INSERT INTO supabase_functions.hooks
      (hook_table_id, hook_name, request_id)
    VALUES
      (TG_RELID, TG_NAME, request_id);

    RETURN NEW;
  END
$$;


ALTER FUNCTION supabase_functions.http_request() OWNER TO supabase_functions_admin;

--
-- Name: secrets_encrypt_secret_secret(); Type: FUNCTION; Schema: vault; Owner: supabase_admin
--

CREATE FUNCTION vault.secrets_encrypt_secret_secret() RETURNS trigger
    LANGUAGE plpgsql
    AS $$
		BEGIN
		        new.secret = CASE WHEN new.secret IS NULL THEN NULL ELSE
			CASE WHEN new.key_id IS NULL THEN NULL ELSE pg_catalog.encode(
			  pgsodium.crypto_aead_det_encrypt(
				pg_catalog.convert_to(new.secret, 'utf8'),
				pg_catalog.convert_to((new.id::text || new.description::text || new.created_at::text || new.updated_at::text)::text, 'utf8'),
				new.key_id::uuid,
				new.nonce
			  ),
				'base64') END END;
		RETURN new;
		END;
		$$;


ALTER FUNCTION vault.secrets_encrypt_secret_secret() OWNER TO supabase_admin;

SET default_tablespace = '';

SET default_table_access_method = heap;

--
-- Name: extensions; Type: TABLE; Schema: _realtime; Owner: supabase_admin
--

CREATE TABLE _realtime.extensions (
    id uuid NOT NULL,
    type text,
    settings jsonb,
    tenant_external_id text,
    inserted_at timestamp(0) without time zone NOT NULL,
    updated_at timestamp(0) without time zone NOT NULL
);


ALTER TABLE _realtime.extensions OWNER TO supabase_admin;

--
-- Name: schema_migrations; Type: TABLE; Schema: _realtime; Owner: supabase_admin
--

CREATE TABLE _realtime.schema_migrations (
    version bigint NOT NULL,
    inserted_at timestamp(0) without time zone
);


ALTER TABLE _realtime.schema_migrations OWNER TO supabase_admin;

--
-- Name: tenants; Type: TABLE; Schema: _realtime; Owner: supabase_admin
--

CREATE TABLE _realtime.tenants (
    id uuid NOT NULL,
    name text,
    external_id text,
    jwt_secret text,
    max_concurrent_users integer DEFAULT 200 NOT NULL,
    inserted_at timestamp(0) without time zone NOT NULL,
    updated_at timestamp(0) without time zone NOT NULL,
    max_events_per_second integer DEFAULT 100 NOT NULL,
    postgres_cdc_default text DEFAULT 'postgres_cdc_rls'::text,
    max_bytes_per_second integer DEFAULT 100000 NOT NULL,
    max_channels_per_client integer DEFAULT 100 NOT NULL,
    max_joins_per_second integer DEFAULT 500 NOT NULL,
    suspend boolean DEFAULT false,
    jwt_jwks jsonb,
    notify_private_alpha boolean DEFAULT false,
    private_only boolean DEFAULT false NOT NULL
);


ALTER TABLE _realtime.tenants OWNER TO supabase_admin;

--
-- Name: audit_log_entries; Type: TABLE; Schema: auth; Owner: supabase_auth_admin
--

CREATE TABLE auth.audit_log_entries (
    instance_id uuid,
    id uuid NOT NULL,
    payload json,
    created_at timestamp with time zone,
    ip_address character varying(64) DEFAULT ''::character varying NOT NULL
);


ALTER TABLE auth.audit_log_entries OWNER TO supabase_auth_admin;

--
-- Name: TABLE audit_log_entries; Type: COMMENT; Schema: auth; Owner: supabase_auth_admin
--

COMMENT ON TABLE auth.audit_log_entries IS 'Auth: Audit trail for user actions.';


--
-- Name: flow_state; Type: TABLE; Schema: auth; Owner: supabase_auth_admin
--

CREATE TABLE auth.flow_state (
    id uuid NOT NULL,
    user_id uuid,
    auth_code text NOT NULL,
    code_challenge_method auth.code_challenge_method NOT NULL,
    code_challenge text NOT NULL,
    provider_type text NOT NULL,
    provider_access_token text,
    provider_refresh_token text,
    created_at timestamp with time zone,
    updated_at timestamp with time zone,
    authentication_method text NOT NULL,
    auth_code_issued_at timestamp with time zone
);


ALTER TABLE auth.flow_state OWNER TO supabase_auth_admin;

--
-- Name: TABLE flow_state; Type: COMMENT; Schema: auth; Owner: supabase_auth_admin
--

COMMENT ON TABLE auth.flow_state IS 'stores metadata for pkce logins';


--
-- Name: identities; Type: TABLE; Schema: auth; Owner: supabase_auth_admin
--

CREATE TABLE auth.identities (
    provider_id text NOT NULL,
    user_id uuid NOT NULL,
    identity_data jsonb NOT NULL,
    provider text NOT NULL,
    last_sign_in_at timestamp with time zone,
    created_at timestamp with time zone,
    updated_at timestamp with time zone,
    email text GENERATED ALWAYS AS (lower((identity_data ->> 'email'::text))) STORED,
    id uuid DEFAULT gen_random_uuid() NOT NULL
);


ALTER TABLE auth.identities OWNER TO supabase_auth_admin;

--
-- Name: TABLE identities; Type: COMMENT; Schema: auth; Owner: supabase_auth_admin
--

COMMENT ON TABLE auth.identities IS 'Auth: Stores identities associated to a user.';


--
-- Name: COLUMN identities.email; Type: COMMENT; Schema: auth; Owner: supabase_auth_admin
--

COMMENT ON COLUMN auth.identities.email IS 'Auth: Email is a generated column that references the optional email property in the identity_data';


--
-- Name: instances; Type: TABLE; Schema: auth; Owner: supabase_auth_admin
--

CREATE TABLE auth.instances (
    id uuid NOT NULL,
    uuid uuid,
    raw_base_config text,
    created_at timestamp with time zone,
    updated_at timestamp with time zone
);


ALTER TABLE auth.instances OWNER TO supabase_auth_admin;

--
-- Name: TABLE instances; Type: COMMENT; Schema: auth; Owner: supabase_auth_admin
--

COMMENT ON TABLE auth.instances IS 'Auth: Manages users across multiple sites.';


--
-- Name: mfa_amr_claims; Type: TABLE; Schema: auth; Owner: supabase_auth_admin
--

CREATE TABLE auth.mfa_amr_claims (
    session_id uuid NOT NULL,
    created_at timestamp with time zone NOT NULL,
    updated_at timestamp with time zone NOT NULL,
    authentication_method text NOT NULL,
    id uuid NOT NULL
);


ALTER TABLE auth.mfa_amr_claims OWNER TO supabase_auth_admin;

--
-- Name: TABLE mfa_amr_claims; Type: COMMENT; Schema: auth; Owner: supabase_auth_admin
--

COMMENT ON TABLE auth.mfa_amr_claims IS 'auth: stores authenticator method reference claims for multi factor authentication';


--
-- Name: mfa_challenges; Type: TABLE; Schema: auth; Owner: supabase_auth_admin
--

CREATE TABLE auth.mfa_challenges (
    id uuid NOT NULL,
    factor_id uuid NOT NULL,
    created_at timestamp with time zone NOT NULL,
    verified_at timestamp with time zone,
    ip_address inet NOT NULL,
    otp_code text,
    web_authn_session_data jsonb
);


ALTER TABLE auth.mfa_challenges OWNER TO supabase_auth_admin;

--
-- Name: TABLE mfa_challenges; Type: COMMENT; Schema: auth; Owner: supabase_auth_admin
--

COMMENT ON TABLE auth.mfa_challenges IS 'auth: stores metadata about challenge requests made';


--
-- Name: mfa_factors; Type: TABLE; Schema: auth; Owner: supabase_auth_admin
--

CREATE TABLE auth.mfa_factors (
    id uuid NOT NULL,
    user_id uuid NOT NULL,
    friendly_name text,
    factor_type auth.factor_type NOT NULL,
    status auth.factor_status NOT NULL,
    created_at timestamp with time zone NOT NULL,
    updated_at timestamp with time zone NOT NULL,
    secret text,
    phone text,
    last_challenged_at timestamp with time zone,
    web_authn_credential jsonb,
    web_authn_aaguid uuid
);


ALTER TABLE auth.mfa_factors OWNER TO supabase_auth_admin;

--
-- Name: TABLE mfa_factors; Type: COMMENT; Schema: auth; Owner: supabase_auth_admin
--

COMMENT ON TABLE auth.mfa_factors IS 'auth: stores metadata about factors';


--
-- Name: one_time_tokens; Type: TABLE; Schema: auth; Owner: supabase_auth_admin
--

CREATE TABLE auth.one_time_tokens (
    id uuid NOT NULL,
    user_id uuid NOT NULL,
    token_type auth.one_time_token_type NOT NULL,
    token_hash text NOT NULL,
    relates_to text NOT NULL,
    created_at timestamp without time zone DEFAULT now() NOT NULL,
    updated_at timestamp without time zone DEFAULT now() NOT NULL,
    CONSTRAINT one_time_tokens_token_hash_check CHECK ((char_length(token_hash) > 0))
);


ALTER TABLE auth.one_time_tokens OWNER TO supabase_auth_admin;

--
-- Name: refresh_tokens; Type: TABLE; Schema: auth; Owner: supabase_auth_admin
--

CREATE TABLE auth.refresh_tokens (
    instance_id uuid,
    id bigint NOT NULL,
    token character varying(255),
    user_id character varying(255),
    revoked boolean,
    created_at timestamp with time zone,
    updated_at timestamp with time zone,
    parent character varying(255),
    session_id uuid
);


ALTER TABLE auth.refresh_tokens OWNER TO supabase_auth_admin;

--
-- Name: TABLE refresh_tokens; Type: COMMENT; Schema: auth; Owner: supabase_auth_admin
--

COMMENT ON TABLE auth.refresh_tokens IS 'Auth: Store of tokens used to refresh JWT tokens once they expire.';


--
-- Name: refresh_tokens_id_seq; Type: SEQUENCE; Schema: auth; Owner: supabase_auth_admin
--

CREATE SEQUENCE auth.refresh_tokens_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER TABLE auth.refresh_tokens_id_seq OWNER TO supabase_auth_admin;

--
-- Name: refresh_tokens_id_seq; Type: SEQUENCE OWNED BY; Schema: auth; Owner: supabase_auth_admin
--

ALTER SEQUENCE auth.refresh_tokens_id_seq OWNED BY auth.refresh_tokens.id;


--
-- Name: saml_providers; Type: TABLE; Schema: auth; Owner: supabase_auth_admin
--

CREATE TABLE auth.saml_providers (
    id uuid NOT NULL,
    sso_provider_id uuid NOT NULL,
    entity_id text NOT NULL,
    metadata_xml text NOT NULL,
    metadata_url text,
    attribute_mapping jsonb,
    created_at timestamp with time zone,
    updated_at timestamp with time zone,
    name_id_format text,
    CONSTRAINT "entity_id not empty" CHECK ((char_length(entity_id) > 0)),
    CONSTRAINT "metadata_url not empty" CHECK (((metadata_url = NULL::text) OR (char_length(metadata_url) > 0))),
    CONSTRAINT "metadata_xml not empty" CHECK ((char_length(metadata_xml) > 0))
);


ALTER TABLE auth.saml_providers OWNER TO supabase_auth_admin;

--
-- Name: TABLE saml_providers; Type: COMMENT; Schema: auth; Owner: supabase_auth_admin
--

COMMENT ON TABLE auth.saml_providers IS 'Auth: Manages SAML Identity Provider connections.';


--
-- Name: saml_relay_states; Type: TABLE; Schema: auth; Owner: supabase_auth_admin
--

CREATE TABLE auth.saml_relay_states (
    id uuid NOT NULL,
    sso_provider_id uuid NOT NULL,
    request_id text NOT NULL,
    for_email text,
    redirect_to text,
    created_at timestamp with time zone,
    updated_at timestamp with time zone,
    flow_state_id uuid,
    CONSTRAINT "request_id not empty" CHECK ((char_length(request_id) > 0))
);


ALTER TABLE auth.saml_relay_states OWNER TO supabase_auth_admin;

--
-- Name: TABLE saml_relay_states; Type: COMMENT; Schema: auth; Owner: supabase_auth_admin
--

COMMENT ON TABLE auth.saml_relay_states IS 'Auth: Contains SAML Relay State information for each Service Provider initiated login.';


--
-- Name: schema_migrations; Type: TABLE; Schema: auth; Owner: supabase_auth_admin
--

CREATE TABLE auth.schema_migrations (
    version character varying(255) NOT NULL
);


ALTER TABLE auth.schema_migrations OWNER TO supabase_auth_admin;

--
-- Name: TABLE schema_migrations; Type: COMMENT; Schema: auth; Owner: supabase_auth_admin
--

COMMENT ON TABLE auth.schema_migrations IS 'Auth: Manages updates to the auth system.';


--
-- Name: sessions; Type: TABLE; Schema: auth; Owner: supabase_auth_admin
--

CREATE TABLE auth.sessions (
    id uuid NOT NULL,
    user_id uuid NOT NULL,
    created_at timestamp with time zone,
    updated_at timestamp with time zone,
    factor_id uuid,
    aal auth.aal_level,
    not_after timestamp with time zone,
    refreshed_at timestamp without time zone,
    user_agent text,
    ip inet,
    tag text
);


ALTER TABLE auth.sessions OWNER TO supabase_auth_admin;

--
-- Name: TABLE sessions; Type: COMMENT; Schema: auth; Owner: supabase_auth_admin
--

COMMENT ON TABLE auth.sessions IS 'Auth: Stores session data associated to a user.';


--
-- Name: COLUMN sessions.not_after; Type: COMMENT; Schema: auth; Owner: supabase_auth_admin
--

COMMENT ON COLUMN auth.sessions.not_after IS 'Auth: Not after is a nullable column that contains a timestamp after which the session should be regarded as expired.';


--
-- Name: sso_domains; Type: TABLE; Schema: auth; Owner: supabase_auth_admin
--

CREATE TABLE auth.sso_domains (
    id uuid NOT NULL,
    sso_provider_id uuid NOT NULL,
    domain text NOT NULL,
    created_at timestamp with time zone,
    updated_at timestamp with time zone,
    CONSTRAINT "domain not empty" CHECK ((char_length(domain) > 0))
);


ALTER TABLE auth.sso_domains OWNER TO supabase_auth_admin;

--
-- Name: TABLE sso_domains; Type: COMMENT; Schema: auth; Owner: supabase_auth_admin
--

COMMENT ON TABLE auth.sso_domains IS 'Auth: Manages SSO email address domain mapping to an SSO Identity Provider.';


--
-- Name: sso_providers; Type: TABLE; Schema: auth; Owner: supabase_auth_admin
--

CREATE TABLE auth.sso_providers (
    id uuid NOT NULL,
    resource_id text,
    created_at timestamp with time zone,
    updated_at timestamp with time zone,
    CONSTRAINT "resource_id not empty" CHECK (((resource_id = NULL::text) OR (char_length(resource_id) > 0)))
);


ALTER TABLE auth.sso_providers OWNER TO supabase_auth_admin;

--
-- Name: TABLE sso_providers; Type: COMMENT; Schema: auth; Owner: supabase_auth_admin
--

COMMENT ON TABLE auth.sso_providers IS 'Auth: Manages SSO identity provider information; see saml_providers for SAML.';


--
-- Name: COLUMN sso_providers.resource_id; Type: COMMENT; Schema: auth; Owner: supabase_auth_admin
--

COMMENT ON COLUMN auth.sso_providers.resource_id IS 'Auth: Uniquely identifies a SSO provider according to a user-chosen resource ID (case insensitive), useful in infrastructure as code.';


--
-- Name: users; Type: TABLE; Schema: auth; Owner: supabase_auth_admin
--

CREATE TABLE auth.users (
    instance_id uuid,
    id uuid NOT NULL,
    aud character varying(255),
    role character varying(255),
    email character varying(255),
    encrypted_password character varying(255),
    email_confirmed_at timestamp with time zone,
    invited_at timestamp with time zone,
    confirmation_token character varying(255),
    confirmation_sent_at timestamp with time zone,
    recovery_token character varying(255),
    recovery_sent_at timestamp with time zone,
    email_change_token_new character varying(255),
    email_change character varying(255),
    email_change_sent_at timestamp with time zone,
    last_sign_in_at timestamp with time zone,
    raw_app_meta_data jsonb,
    raw_user_meta_data jsonb,
    is_super_admin boolean,
    created_at timestamp with time zone,
    updated_at timestamp with time zone,
    phone text DEFAULT NULL::character varying,
    phone_confirmed_at timestamp with time zone,
    phone_change text DEFAULT ''::character varying,
    phone_change_token character varying(255) DEFAULT ''::character varying,
    phone_change_sent_at timestamp with time zone,
    confirmed_at timestamp with time zone GENERATED ALWAYS AS (LEAST(email_confirmed_at, phone_confirmed_at)) STORED,
    email_change_token_current character varying(255) DEFAULT ''::character varying,
    email_change_confirm_status smallint DEFAULT 0,
    banned_until timestamp with time zone,
    reauthentication_token character varying(255) DEFAULT ''::character varying,
    reauthentication_sent_at timestamp with time zone,
    is_sso_user boolean DEFAULT false NOT NULL,
    deleted_at timestamp with time zone,
    is_anonymous boolean DEFAULT false NOT NULL,
    CONSTRAINT users_email_change_confirm_status_check CHECK (((email_change_confirm_status >= 0) AND (email_change_confirm_status <= 2)))
);


ALTER TABLE auth.users OWNER TO supabase_auth_admin;

--
-- Name: TABLE users; Type: COMMENT; Schema: auth; Owner: supabase_auth_admin
--

COMMENT ON TABLE auth.users IS 'Auth: Stores user login data within a secure schema.';


--
-- Name: COLUMN users.is_sso_user; Type: COMMENT; Schema: auth; Owner: supabase_auth_admin
--

COMMENT ON COLUMN auth.users.is_sso_user IS 'Auth: Set this column to true when the account comes from SSO. These accounts can have duplicate emails.';


--
-- Name: complaint_actions; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.complaint_actions (
    action_id bigint NOT NULL,
    created_at timestamp with time zone DEFAULT now() NOT NULL,
    complaint_id bigint,
    action_by text NOT NULL,
    action text,
    remarks text,
    confidential boolean,
    documents uuid[]
);


ALTER TABLE public.complaint_actions OWNER TO postgres;

--
-- Name: TABLE complaint_actions; Type: COMMENT; Schema: public; Owner: postgres
--

COMMENT ON TABLE public.complaint_actions IS 'actions made for complaints';


--
-- Name: COLUMN complaint_actions.complaint_id; Type: COMMENT; Schema: public; Owner: postgres
--

COMMENT ON COLUMN public.complaint_actions.complaint_id IS 'actions made for complaint';


--
-- Name: COLUMN complaint_actions.action_by; Type: COMMENT; Schema: public; Owner: postgres
--

COMMENT ON COLUMN public.complaint_actions.action_by IS 'action taken by';


--
-- Name: COLUMN complaint_actions.action; Type: COMMENT; Schema: public; Owner: postgres
--

COMMENT ON COLUMN public.complaint_actions.action IS 'the action taken';


--
-- Name: COLUMN complaint_actions.remarks; Type: COMMENT; Schema: public; Owner: postgres
--

COMMENT ON COLUMN public.complaint_actions.remarks IS 'the remark left by action creator';


--
-- Name: COLUMN complaint_actions.confidential; Type: COMMENT; Schema: public; Owner: postgres
--

COMMENT ON COLUMN public.complaint_actions.confidential IS 'is the action confidential?';


--
-- Name: complaint_actions_id_seq; Type: SEQUENCE; Schema: public; Owner: postgres
--

ALTER TABLE public.complaint_actions ALTER COLUMN action_id ADD GENERATED BY DEFAULT AS IDENTITY (
    SEQUENCE NAME public.complaint_actions_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1
);


--
-- Name: complaints; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.complaints (
    complaint_id bigint NOT NULL,
    created_at timestamp with time zone DEFAULT now() NOT NULL,
    support_needed text,
    confidentiality boolean,
    type text,
    description text,
    status text DEFAULT 'submitted'::text,
    documents uuid[],
    complainant uuid DEFAULT auth.uid() NOT NULL,
    last_action bigint,
    other_type text,
    accused text NOT NULL,
    accused_is_org boolean NOT NULL
);


ALTER TABLE public.complaints OWNER TO postgres;

--
-- Name: TABLE complaints; Type: COMMENT; Schema: public; Owner: postgres
--

COMMENT ON TABLE public.complaints IS 'stores all the complaints lodged by complainants.';


--
-- Name: COLUMN complaints.documents; Type: COMMENT; Schema: public; Owner: postgres
--

COMMENT ON COLUMN public.complaints.documents IS 'all documents submitted when first lodging a complaint';


--
-- Name: COLUMN complaints.complainant; Type: COMMENT; Schema: public; Owner: postgres
--

COMMENT ON COLUMN public.complaints.complainant IS 'who lodged the complaint?';


--
-- Name: COLUMN complaints.last_action; Type: COMMENT; Schema: public; Owner: postgres
--

COMMENT ON COLUMN public.complaints.last_action IS 'last action id';


--
-- Name: COLUMN complaints.other_type; Type: COMMENT; Schema: public; Owner: postgres
--

COMMENT ON COLUMN public.complaints.other_type IS 'description of other type';


--
-- Name: COLUMN complaints.accused; Type: COMMENT; Schema: public; Owner: postgres
--

COMMENT ON COLUMN public.complaints.accused IS 'name of the organization or individual being accused';


--
-- Name: COLUMN complaints.accused_is_org; Type: COMMENT; Schema: public; Owner: postgres
--

COMMENT ON COLUMN public.complaints.accused_is_org IS 'is the accused an organization';


--
-- Name: complaints_complaint_id_seq; Type: SEQUENCE; Schema: public; Owner: postgres
--

ALTER TABLE public.complaints ALTER COLUMN complaint_id ADD GENERATED BY DEFAULT AS IDENTITY (
    SEQUENCE NAME public.complaints_complaint_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1
);


--
-- Name: summary; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.summary (
    id bigint NOT NULL,
    created_at timestamp with time zone DEFAULT now() NOT NULL,
    hide boolean DEFAULT true,
    accused text,
    complaint_id bigint,
    complaint_date date,
    summary text
);


ALTER TABLE public.summary OWNER TO postgres;

--
-- Name: COLUMN summary.accused; Type: COMMENT; Schema: public; Owner: postgres
--

COMMENT ON COLUMN public.summary.accused IS 'organization or individual the complaint was lodged against';


--
-- Name: COLUMN summary.complaint_id; Type: COMMENT; Schema: public; Owner: postgres
--

COMMENT ON COLUMN public.summary.complaint_id IS 'the id of the complaint';


--
-- Name: COLUMN summary.summary; Type: COMMENT; Schema: public; Owner: postgres
--

COMMENT ON COLUMN public.summary.summary IS 'summary of the complaint';


--
-- Name: summary_id_seq; Type: SEQUENCE; Schema: public; Owner: postgres
--

ALTER TABLE public.summary ALTER COLUMN id ADD GENERATED BY DEFAULT AS IDENTITY (
    SEQUENCE NAME public.summary_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1
);


--
-- Name: user; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public."user" (
    id bigint NOT NULL,
    created_at timestamp with time zone DEFAULT now() NOT NULL,
    user_id uuid DEFAULT auth.uid() NOT NULL,
    organization text,
    phone text,
    address text,
    postcode numeric,
    state text,
    country text,
    name text
);


ALTER TABLE public."user" OWNER TO postgres;

--
-- Name: TABLE "user"; Type: COMMENT; Schema: public; Owner: postgres
--

COMMENT ON TABLE public."user" IS 'user data table';


--
-- Name: COLUMN "user".name; Type: COMMENT; Schema: public; Owner: postgres
--

COMMENT ON COLUMN public."user".name IS 'name of the user';


--
-- Name: user_id_seq; Type: SEQUENCE; Schema: public; Owner: postgres
--

ALTER TABLE public."user" ALTER COLUMN id ADD GENERATED BY DEFAULT AS IDENTITY (
    SEQUENCE NAME public.user_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1
);


--
-- Name: messages; Type: TABLE; Schema: realtime; Owner: supabase_realtime_admin
--

CREATE TABLE realtime.messages (
    topic text NOT NULL,
    extension text NOT NULL,
    payload jsonb,
    event text,
    private boolean DEFAULT false,
    updated_at timestamp without time zone DEFAULT now() NOT NULL,
    inserted_at timestamp without time zone DEFAULT now() NOT NULL,
    id uuid DEFAULT gen_random_uuid() NOT NULL
)
PARTITION BY RANGE (inserted_at);


ALTER TABLE realtime.messages OWNER TO supabase_realtime_admin;

--
-- Name: schema_migrations; Type: TABLE; Schema: realtime; Owner: supabase_admin
--

CREATE TABLE realtime.schema_migrations (
    version bigint NOT NULL,
    inserted_at timestamp(0) without time zone
);


ALTER TABLE realtime.schema_migrations OWNER TO supabase_admin;

--
-- Name: subscription; Type: TABLE; Schema: realtime; Owner: supabase_admin
--

CREATE TABLE realtime.subscription (
    id bigint NOT NULL,
    subscription_id uuid NOT NULL,
    entity regclass NOT NULL,
    filters realtime.user_defined_filter[] DEFAULT '{}'::realtime.user_defined_filter[] NOT NULL,
    claims jsonb NOT NULL,
    claims_role regrole GENERATED ALWAYS AS (realtime.to_regrole((claims ->> 'role'::text))) STORED NOT NULL,
    created_at timestamp without time zone DEFAULT timezone('utc'::text, now()) NOT NULL
);


ALTER TABLE realtime.subscription OWNER TO supabase_admin;

--
-- Name: subscription_id_seq; Type: SEQUENCE; Schema: realtime; Owner: supabase_admin
--

ALTER TABLE realtime.subscription ALTER COLUMN id ADD GENERATED ALWAYS AS IDENTITY (
    SEQUENCE NAME realtime.subscription_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1
);


--
-- Name: buckets; Type: TABLE; Schema: storage; Owner: supabase_storage_admin
--

CREATE TABLE storage.buckets (
    id text NOT NULL,
    name text NOT NULL,
    owner uuid,
    created_at timestamp with time zone DEFAULT now(),
    updated_at timestamp with time zone DEFAULT now(),
    public boolean DEFAULT false,
    avif_autodetection boolean DEFAULT false,
    file_size_limit bigint,
    allowed_mime_types text[],
    owner_id text
);


ALTER TABLE storage.buckets OWNER TO supabase_storage_admin;

--
-- Name: COLUMN buckets.owner; Type: COMMENT; Schema: storage; Owner: supabase_storage_admin
--

COMMENT ON COLUMN storage.buckets.owner IS 'Field is deprecated, use owner_id instead';


--
-- Name: migrations; Type: TABLE; Schema: storage; Owner: supabase_storage_admin
--

CREATE TABLE storage.migrations (
    id integer NOT NULL,
    name character varying(100) NOT NULL,
    hash character varying(40) NOT NULL,
    executed_at timestamp without time zone DEFAULT CURRENT_TIMESTAMP
);


ALTER TABLE storage.migrations OWNER TO supabase_storage_admin;

--
-- Name: objects; Type: TABLE; Schema: storage; Owner: supabase_storage_admin
--

CREATE TABLE storage.objects (
    id uuid DEFAULT gen_random_uuid() NOT NULL,
    bucket_id text,
    name text,
    owner uuid,
    created_at timestamp with time zone DEFAULT now(),
    updated_at timestamp with time zone DEFAULT now(),
    last_accessed_at timestamp with time zone DEFAULT now(),
    metadata jsonb,
    path_tokens text[] GENERATED ALWAYS AS (string_to_array(name, '/'::text)) STORED,
    version text,
    owner_id text,
    user_metadata jsonb
);


ALTER TABLE storage.objects OWNER TO supabase_storage_admin;

--
-- Name: COLUMN objects.owner; Type: COMMENT; Schema: storage; Owner: supabase_storage_admin
--

COMMENT ON COLUMN storage.objects.owner IS 'Field is deprecated, use owner_id instead';


--
-- Name: s3_multipart_uploads; Type: TABLE; Schema: storage; Owner: supabase_storage_admin
--

CREATE TABLE storage.s3_multipart_uploads (
    id text NOT NULL,
    in_progress_size bigint DEFAULT 0 NOT NULL,
    upload_signature text NOT NULL,
    bucket_id text NOT NULL,
    key text NOT NULL COLLATE pg_catalog."C",
    version text NOT NULL,
    owner_id text,
    created_at timestamp with time zone DEFAULT now() NOT NULL,
    user_metadata jsonb
);


ALTER TABLE storage.s3_multipart_uploads OWNER TO supabase_storage_admin;

--
-- Name: s3_multipart_uploads_parts; Type: TABLE; Schema: storage; Owner: supabase_storage_admin
--

CREATE TABLE storage.s3_multipart_uploads_parts (
    id uuid DEFAULT gen_random_uuid() NOT NULL,
    upload_id text NOT NULL,
    size bigint DEFAULT 0 NOT NULL,
    part_number integer NOT NULL,
    bucket_id text NOT NULL,
    key text NOT NULL COLLATE pg_catalog."C",
    etag text NOT NULL,
    owner_id text,
    version text NOT NULL,
    created_at timestamp with time zone DEFAULT now() NOT NULL
);


ALTER TABLE storage.s3_multipart_uploads_parts OWNER TO supabase_storage_admin;

--
-- Name: hooks; Type: TABLE; Schema: supabase_functions; Owner: supabase_functions_admin
--

CREATE TABLE supabase_functions.hooks (
    id bigint NOT NULL,
    hook_table_id integer NOT NULL,
    hook_name text NOT NULL,
    created_at timestamp with time zone DEFAULT now() NOT NULL,
    request_id bigint
);


ALTER TABLE supabase_functions.hooks OWNER TO supabase_functions_admin;

--
-- Name: TABLE hooks; Type: COMMENT; Schema: supabase_functions; Owner: supabase_functions_admin
--

COMMENT ON TABLE supabase_functions.hooks IS 'Supabase Functions Hooks: Audit trail for triggered hooks.';


--
-- Name: hooks_id_seq; Type: SEQUENCE; Schema: supabase_functions; Owner: supabase_functions_admin
--

CREATE SEQUENCE supabase_functions.hooks_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER TABLE supabase_functions.hooks_id_seq OWNER TO supabase_functions_admin;

--
-- Name: hooks_id_seq; Type: SEQUENCE OWNED BY; Schema: supabase_functions; Owner: supabase_functions_admin
--

ALTER SEQUENCE supabase_functions.hooks_id_seq OWNED BY supabase_functions.hooks.id;


--
-- Name: migrations; Type: TABLE; Schema: supabase_functions; Owner: supabase_functions_admin
--

CREATE TABLE supabase_functions.migrations (
    version text NOT NULL,
    inserted_at timestamp with time zone DEFAULT now() NOT NULL
);


ALTER TABLE supabase_functions.migrations OWNER TO supabase_functions_admin;

--
-- Name: decrypted_secrets; Type: VIEW; Schema: vault; Owner: supabase_admin
--

CREATE VIEW vault.decrypted_secrets AS
 SELECT secrets.id,
    secrets.name,
    secrets.description,
    secrets.secret,
        CASE
            WHEN (secrets.secret IS NULL) THEN NULL::text
            ELSE
            CASE
                WHEN (secrets.key_id IS NULL) THEN NULL::text
                ELSE convert_from(pgsodium.crypto_aead_det_decrypt(decode(secrets.secret, 'base64'::text), convert_to(((((secrets.id)::text || secrets.description) || (secrets.created_at)::text) || (secrets.updated_at)::text), 'utf8'::name), secrets.key_id, secrets.nonce), 'utf8'::name)
            END
        END AS decrypted_secret,
    secrets.key_id,
    secrets.nonce,
    secrets.created_at,
    secrets.updated_at
   FROM vault.secrets;


ALTER TABLE vault.decrypted_secrets OWNER TO supabase_admin;

--
-- Name: refresh_tokens id; Type: DEFAULT; Schema: auth; Owner: supabase_auth_admin
--

ALTER TABLE ONLY auth.refresh_tokens ALTER COLUMN id SET DEFAULT nextval('auth.refresh_tokens_id_seq'::regclass);


--
-- Name: hooks id; Type: DEFAULT; Schema: supabase_functions; Owner: supabase_functions_admin
--

ALTER TABLE ONLY supabase_functions.hooks ALTER COLUMN id SET DEFAULT nextval('supabase_functions.hooks_id_seq'::regclass);


--
-- Data for Name: extensions; Type: TABLE DATA; Schema: _realtime; Owner: supabase_admin
--

COPY _realtime.extensions (id, type, settings, tenant_external_id, inserted_at, updated_at) FROM stdin;
8f716442-9b0e-4aed-9551-80e559c7d8af	postgres_cdc_rls	{"region": "us-east-1", "db_host": "czjL7HswmBBHlBkpdCqW2FeSYq4tOAJtdTcgYmrmm6s=", "db_name": "sWBpZNdjggEPTQVlI52Zfw==", "db_port": "+enMDFi1J/3IrrquHHwUmA==", "db_user": "uxbEq/zz8DXVD53TOI1zmw==", "slot_name": "supabase_realtime_replication_slot", "db_password": "sWBpZNdjggEPTQVlI52Zfw==", "publication": "supabase_realtime", "ssl_enforced": false, "poll_interval_ms": 100, "poll_max_changes": 100, "poll_max_record_bytes": 1048576}	realtime-dev	2025-02-18 08:19:04	2025-02-18 08:19:04
\.


--
-- Data for Name: schema_migrations; Type: TABLE DATA; Schema: _realtime; Owner: supabase_admin
--

COPY _realtime.schema_migrations (version, inserted_at) FROM stdin;
20210706140551	2025-01-19 04:53:01
20220329161857	2025-01-19 04:53:01
20220410212326	2025-01-19 04:53:01
20220506102948	2025-01-19 04:53:01
20220527210857	2025-01-19 04:53:01
20220815211129	2025-01-19 04:53:01
20220815215024	2025-01-19 04:53:01
20220818141501	2025-01-19 04:53:01
20221018173709	2025-01-19 04:53:01
20221102172703	2025-01-19 04:53:01
20221223010058	2025-01-19 04:53:01
20230110180046	2025-01-19 04:53:01
20230810220907	2025-01-19 04:53:01
20230810220924	2025-01-19 04:53:01
20231024094642	2025-01-19 04:53:01
20240306114423	2025-01-19 04:53:01
20240418082835	2025-01-19 04:53:01
20240625211759	2025-01-19 04:53:01
20240704172020	2025-01-19 04:53:01
20240902173232	2025-01-19 04:53:01
20241106103258	2025-01-19 04:53:01
\.


--
-- Data for Name: tenants; Type: TABLE DATA; Schema: _realtime; Owner: supabase_admin
--

COPY _realtime.tenants (id, name, external_id, jwt_secret, max_concurrent_users, inserted_at, updated_at, max_events_per_second, postgres_cdc_default, max_bytes_per_second, max_channels_per_client, max_joins_per_second, suspend, jwt_jwks, notify_private_alpha, private_only) FROM stdin;
a4ae8cde-9615-4742-9618-9000ba46b73f	realtime-dev	realtime-dev	iNjicxc4+llvc9wovDvqymwfnj9teWMlyOIbJ8Fh6j2WNU8CIJ2ZgjR6MUIKqSmeDmvpsKLsZ9jgXJmQPpwL8w==	200	2025-02-18 08:19:04	2025-02-18 08:19:04	100	postgres_cdc_rls	100000	100	100	f	{"keys": [{"k": "c3VwZXItc2VjcmV0LWp3dC10b2tlbi13aXRoLWF0LWxlYXN0LTMyLWNoYXJhY3RlcnMtbG9uZw", "kty": "oct"}]}	f	f
\.


--
-- Data for Name: audit_log_entries; Type: TABLE DATA; Schema: auth; Owner: supabase_auth_admin
--

COPY auth.audit_log_entries (instance_id, id, payload, created_at, ip_address) FROM stdin;
00000000-0000-0000-0000-000000000000	ca149788-4143-4683-b509-d9e4af1c2cdb	{"action":"user_signedup","actor_id":"7c879e8b-8740-4f75-b7a1-e9cee9cb3377","actor_username":"marzouq@marzex.tech","actor_via_sso":false,"log_type":"team","traits":{"provider":"email"}}	2025-01-19 05:09:34.971252+00	
00000000-0000-0000-0000-000000000000	e1aeef88-29e0-4230-ab07-92aaa3af9306	{"action":"login","actor_id":"7c879e8b-8740-4f75-b7a1-e9cee9cb3377","actor_username":"marzouq@marzex.tech","actor_via_sso":false,"log_type":"account","traits":{"provider":"email"}}	2025-01-19 05:09:34.973551+00	
00000000-0000-0000-0000-000000000000	f38b391e-153e-44d7-9885-7fd0f4da4948	{"action":"user_repeated_signup","actor_id":"7c879e8b-8740-4f75-b7a1-e9cee9cb3377","actor_username":"marzouq@marzex.tech","actor_via_sso":false,"log_type":"user","traits":{"provider":"email"}}	2025-01-19 05:10:08.225752+00	
00000000-0000-0000-0000-000000000000	ed740142-ed47-4252-bcae-74f5e653df90	{"action":"login","actor_id":"7c879e8b-8740-4f75-b7a1-e9cee9cb3377","actor_username":"marzouq@marzex.tech","actor_via_sso":false,"log_type":"account","traits":{"provider":"email"}}	2025-01-19 05:10:26.269037+00	
00000000-0000-0000-0000-000000000000	1650c2a4-f4df-40c4-91c4-d97164fbc84f	{"action":"login","actor_id":"7c879e8b-8740-4f75-b7a1-e9cee9cb3377","actor_username":"marzouq@marzex.tech","actor_via_sso":false,"log_type":"account","traits":{"provider":"email"}}	2025-01-19 05:11:27.550815+00	
00000000-0000-0000-0000-000000000000	f7149aa6-ac51-44c3-bfd5-17b9b8ac908f	{"action":"login","actor_id":"7c879e8b-8740-4f75-b7a1-e9cee9cb3377","actor_username":"marzouq@marzex.tech","actor_via_sso":false,"log_type":"account","traits":{"provider":"email"}}	2025-01-19 05:12:12.327667+00	
00000000-0000-0000-0000-000000000000	370b3bef-3aaa-4e3b-8a09-5e73dffdfc5d	{"action":"login","actor_id":"7c879e8b-8740-4f75-b7a1-e9cee9cb3377","actor_username":"marzouq@marzex.tech","actor_via_sso":false,"log_type":"account","traits":{"provider":"email"}}	2025-01-19 05:13:00.105911+00	
00000000-0000-0000-0000-000000000000	4553412f-cc69-4bdb-8f00-b4de63896314	{"action":"login","actor_id":"7c879e8b-8740-4f75-b7a1-e9cee9cb3377","actor_username":"marzouq@marzex.tech","actor_via_sso":false,"log_type":"account","traits":{"provider":"email"}}	2025-01-19 05:13:20.971296+00	
00000000-0000-0000-0000-000000000000	3e187f55-2863-494c-a02d-6bd7589b61b6	{"action":"user_signedup","actor_id":"ec07902d-bc1a-4d79-9d75-e4afb2da40d9","actor_username":"test@marzex.tech","actor_via_sso":false,"log_type":"team","traits":{"provider":"email"}}	2025-01-19 05:14:13.447262+00	
00000000-0000-0000-0000-000000000000	efc18b84-e201-4edb-99e5-9440efa581f3	{"action":"login","actor_id":"ec07902d-bc1a-4d79-9d75-e4afb2da40d9","actor_username":"test@marzex.tech","actor_via_sso":false,"log_type":"account","traits":{"provider":"email"}}	2025-01-19 05:14:13.448952+00	
00000000-0000-0000-0000-000000000000	95ec8db1-7e31-46a8-90c0-7b6fea1c9cbf	{"action":"login","actor_id":"7c879e8b-8740-4f75-b7a1-e9cee9cb3377","actor_username":"marzouq@marzex.tech","actor_via_sso":false,"log_type":"account","traits":{"provider":"email"}}	2025-01-19 05:47:53.352001+00	
00000000-0000-0000-0000-000000000000	0be8fa28-1528-47ca-bade-e3d53a6c3b9c	{"action":"user_deleted","actor_id":"00000000-0000-0000-0000-000000000000","actor_username":"service_role","actor_via_sso":false,"log_type":"team","traits":{"user_email":"test@marzex.tech","user_id":"ec07902d-bc1a-4d79-9d75-e4afb2da40d9","user_phone":""}}	2025-01-19 05:52:48.129755+00	
00000000-0000-0000-0000-000000000000	b621c354-44c1-4e65-b43c-e7c2f16b9c2b	{"action":"user_deleted","actor_id":"00000000-0000-0000-0000-000000000000","actor_username":"service_role","actor_via_sso":false,"log_type":"team","traits":{"user_email":"marzouq@marzex.tech","user_id":"7c879e8b-8740-4f75-b7a1-e9cee9cb3377","user_phone":""}}	2025-01-19 05:53:23.365641+00	
00000000-0000-0000-0000-000000000000	5d426300-ac18-43e8-85e9-438bd0c1a748	{"action":"user_signedup","actor_id":"8a146a1b-44a0-4f38-91fb-f9f50a0e72f3","actor_username":"marzouq@marzex.tech","actor_via_sso":false,"log_type":"team","traits":{"provider":"email"}}	2025-01-19 05:54:12.821578+00	
00000000-0000-0000-0000-000000000000	301fb2ff-8141-484c-9745-164d2f4b2cd1	{"action":"login","actor_id":"8a146a1b-44a0-4f38-91fb-f9f50a0e72f3","actor_username":"marzouq@marzex.tech","actor_via_sso":false,"log_type":"account","traits":{"provider":"email"}}	2025-01-19 05:54:12.824348+00	
00000000-0000-0000-0000-000000000000	c1e2d9f4-367f-4392-9d0b-59aab2fd4cb6	{"action":"login","actor_id":"8a146a1b-44a0-4f38-91fb-f9f50a0e72f3","actor_username":"marzouq@marzex.tech","actor_via_sso":false,"log_type":"account","traits":{"provider":"email"}}	2025-01-19 06:13:38.153039+00	
00000000-0000-0000-0000-000000000000	1d0565d7-7878-434b-b3e7-b4f62165da81	{"action":"login","actor_id":"8a146a1b-44a0-4f38-91fb-f9f50a0e72f3","actor_username":"marzouq@marzex.tech","actor_via_sso":false,"log_type":"account","traits":{"provider":"email"}}	2025-01-19 06:34:55.582717+00	
00000000-0000-0000-0000-000000000000	667e7380-2d99-47de-9151-592962b9db48	{"action":"user_signedup","actor_id":"427cd040-7ba0-41fb-85af-2c18214fd310","actor_username":"test@marzex.tech","actor_via_sso":false,"log_type":"team","traits":{"provider":"email"}}	2025-01-19 06:35:23.447832+00	
00000000-0000-0000-0000-000000000000	36ca3b34-700c-4d25-9fb4-5a65560e5d60	{"action":"login","actor_id":"427cd040-7ba0-41fb-85af-2c18214fd310","actor_username":"test@marzex.tech","actor_via_sso":false,"log_type":"account","traits":{"provider":"email"}}	2025-01-19 06:35:23.450529+00	
00000000-0000-0000-0000-000000000000	338808c5-db36-440b-8dc7-04ea1bdc0a11	{"action":"user_deleted","actor_id":"00000000-0000-0000-0000-000000000000","actor_username":"service_role","actor_via_sso":false,"log_type":"team","traits":{"user_email":"marzouq@marzex.tech","user_id":"8a146a1b-44a0-4f38-91fb-f9f50a0e72f3","user_phone":""}}	2025-01-19 06:36:08.242312+00	
00000000-0000-0000-0000-000000000000	4e9f240e-0985-4207-bb6c-9e08167a2138	{"action":"user_deleted","actor_id":"00000000-0000-0000-0000-000000000000","actor_username":"service_role","actor_via_sso":false,"log_type":"team","traits":{"user_email":"test@marzex.tech","user_id":"427cd040-7ba0-41fb-85af-2c18214fd310","user_phone":""}}	2025-01-19 06:36:12.089726+00	
00000000-0000-0000-0000-000000000000	64c8edec-4f00-439c-83c9-64169b489ee2	{"action":"user_signedup","actor_id":"c3dd5b40-9fea-422d-a9f3-95877e7924c1","actor_username":"marzouq@marzex.tech","actor_via_sso":false,"log_type":"team","traits":{"provider":"email"}}	2025-01-19 06:36:23.78196+00	
00000000-0000-0000-0000-000000000000	8d32793e-2113-4161-8d08-ca2ac144063f	{"action":"login","actor_id":"c3dd5b40-9fea-422d-a9f3-95877e7924c1","actor_username":"marzouq@marzex.tech","actor_via_sso":false,"log_type":"account","traits":{"provider":"email"}}	2025-01-19 06:36:23.785162+00	
00000000-0000-0000-0000-000000000000	5c051834-b25d-4680-aa81-979e59c86514	{"action":"user_deleted","actor_id":"00000000-0000-0000-0000-000000000000","actor_username":"service_role","actor_via_sso":false,"log_type":"team","traits":{"user_email":"marzouq@marzex.tech","user_id":"c3dd5b40-9fea-422d-a9f3-95877e7924c1","user_phone":""}}	2025-01-19 06:37:39.229446+00	
00000000-0000-0000-0000-000000000000	8583a40e-ab77-4c16-b921-f7124a9070ce	{"action":"user_signedup","actor_id":"c6da1f3c-5b87-4ff2-a2c7-7e4e21857350","actor_username":"marzouq@marzex.tech","actor_via_sso":false,"log_type":"team","traits":{"provider":"email"}}	2025-01-19 06:38:03.865638+00	
00000000-0000-0000-0000-000000000000	93611bfc-aa84-4feb-9841-fe712c0b9ccf	{"action":"login","actor_id":"c6da1f3c-5b87-4ff2-a2c7-7e4e21857350","actor_username":"marzouq@marzex.tech","actor_via_sso":false,"log_type":"account","traits":{"provider":"email"}}	2025-01-19 06:38:03.86899+00	
00000000-0000-0000-0000-000000000000	a20802cd-ccc1-4c10-b0be-7fe5d534bc0e	{"action":"user_deleted","actor_id":"00000000-0000-0000-0000-000000000000","actor_username":"service_role","actor_via_sso":false,"log_type":"team","traits":{"user_email":"marzouq@marzex.tech","user_id":"c6da1f3c-5b87-4ff2-a2c7-7e4e21857350","user_phone":""}}	2025-01-19 06:49:11.248+00	
00000000-0000-0000-0000-000000000000	630c95fb-4ebf-45c8-a16b-f9bad44dc1a9	{"action":"user_signedup","actor_id":"ac33ba66-9fbe-4f48-9794-be8ef22dcd94","actor_username":"marzouq@marzex.tech","actor_via_sso":false,"log_type":"team","traits":{"provider":"email"}}	2025-01-19 06:49:39.905565+00	
00000000-0000-0000-0000-000000000000	6b5f18c0-dc3f-491a-a49b-7a1c915665e4	{"action":"login","actor_id":"ac33ba66-9fbe-4f48-9794-be8ef22dcd94","actor_username":"marzouq@marzex.tech","actor_via_sso":false,"log_type":"account","traits":{"provider":"email"}}	2025-01-19 06:49:39.90789+00	
00000000-0000-0000-0000-000000000000	b11a3c98-d81b-4ede-871e-f2384d7b2fc5	{"action":"user_deleted","actor_id":"00000000-0000-0000-0000-000000000000","actor_username":"service_role","actor_via_sso":false,"log_type":"team","traits":{"user_email":"marzouq@marzex.tech","user_id":"ac33ba66-9fbe-4f48-9794-be8ef22dcd94","user_phone":""}}	2025-01-19 06:50:07.16712+00	
00000000-0000-0000-0000-000000000000	c7247f34-ddb7-4e2a-b76b-bc737038181d	{"action":"user_signedup","actor_id":"88bbd060-1b74-475a-83aa-785dec133827","actor_username":"marzouq@marzex.tech","actor_via_sso":false,"log_type":"team","traits":{"provider":"email"}}	2025-01-19 06:50:12.286495+00	
00000000-0000-0000-0000-000000000000	b3b550a5-982d-4579-a627-d5fb36db1538	{"action":"login","actor_id":"88bbd060-1b74-475a-83aa-785dec133827","actor_username":"marzouq@marzex.tech","actor_via_sso":false,"log_type":"account","traits":{"provider":"email"}}	2025-01-19 06:50:12.29571+00	
00000000-0000-0000-0000-000000000000	4f05742b-a464-4f64-8ef2-31484183dc1a	{"action":"user_deleted","actor_id":"00000000-0000-0000-0000-000000000000","actor_username":"service_role","actor_via_sso":false,"log_type":"team","traits":{"user_email":"marzouq@marzex.tech","user_id":"88bbd060-1b74-475a-83aa-785dec133827","user_phone":""}}	2025-01-19 06:50:20.25445+00	
00000000-0000-0000-0000-000000000000	ed993bf8-0866-4aa8-8a17-b4a08cf1f91d	{"action":"user_signedup","actor_id":"3aa665b7-a4dd-40d8-b647-82e6ce3b3e16","actor_username":"marzouq@marzex.tech","actor_via_sso":false,"log_type":"team","traits":{"provider":"email"}}	2025-01-19 06:50:37.255138+00	
00000000-0000-0000-0000-000000000000	64f18194-db51-4324-aa74-18dea3c5c6ef	{"action":"login","actor_id":"3aa665b7-a4dd-40d8-b647-82e6ce3b3e16","actor_username":"marzouq@marzex.tech","actor_via_sso":false,"log_type":"account","traits":{"provider":"email"}}	2025-01-19 06:50:37.25678+00	
00000000-0000-0000-0000-000000000000	5401416f-5405-4611-9f3f-d380a9f2e9fe	{"action":"login","actor_id":"3aa665b7-a4dd-40d8-b647-82e6ce3b3e16","actor_username":"marzouq@marzex.tech","actor_via_sso":false,"log_type":"account","traits":{"provider":"email"}}	2025-01-19 07:33:42.534302+00	
00000000-0000-0000-0000-000000000000	e429275e-b263-4a70-aeeb-26385df1cc03	{"action":"login","actor_id":"3aa665b7-a4dd-40d8-b647-82e6ce3b3e16","actor_username":"marzouq@marzex.tech","actor_via_sso":false,"log_type":"account","traits":{"provider":"email"}}	2025-01-19 07:34:55.507283+00	
00000000-0000-0000-0000-000000000000	389edca4-402f-4a44-b70b-da623fd23f8d	{"action":"token_refreshed","actor_id":"3aa665b7-a4dd-40d8-b647-82e6ce3b3e16","actor_username":"marzouq@marzex.tech","actor_via_sso":false,"log_type":"token"}	2025-01-19 08:46:52.510162+00	
00000000-0000-0000-0000-000000000000	dac41cdd-db79-4d02-b60b-f5087c7a8afa	{"action":"token_revoked","actor_id":"3aa665b7-a4dd-40d8-b647-82e6ce3b3e16","actor_username":"marzouq@marzex.tech","actor_via_sso":false,"log_type":"token"}	2025-01-19 08:46:52.510327+00	
00000000-0000-0000-0000-000000000000	424d1ace-5129-4a3b-83df-da9115a4cdc6	{"action":"login","actor_id":"3aa665b7-a4dd-40d8-b647-82e6ce3b3e16","actor_username":"marzouq@marzex.tech","actor_via_sso":false,"log_type":"account","traits":{"provider":"email"}}	2025-01-19 08:47:22.058651+00	
00000000-0000-0000-0000-000000000000	014a8f12-a622-4497-acc1-d672fe89346b	{"action":"login","actor_id":"3aa665b7-a4dd-40d8-b647-82e6ce3b3e16","actor_username":"marzouq@marzex.tech","actor_via_sso":false,"log_type":"account","traits":{"provider":"email"}}	2025-01-19 08:47:34.326789+00	
00000000-0000-0000-0000-000000000000	1b4ab80c-e8ec-41b1-a5a1-beaaee997e88	{"action":"login","actor_id":"3aa665b7-a4dd-40d8-b647-82e6ce3b3e16","actor_username":"marzouq@marzex.tech","actor_via_sso":false,"log_type":"account","traits":{"provider":"email"}}	2025-01-19 08:51:39.544319+00	
00000000-0000-0000-0000-000000000000	143f4042-42bf-41ac-bfcf-926c0c90495f	{"action":"token_refreshed","actor_id":"3aa665b7-a4dd-40d8-b647-82e6ce3b3e16","actor_username":"marzouq@marzex.tech","actor_via_sso":false,"log_type":"token"}	2025-01-19 11:02:51.230647+00	
00000000-0000-0000-0000-000000000000	ac1de92f-dc02-4ce5-bfd9-86c176531221	{"action":"token_revoked","actor_id":"3aa665b7-a4dd-40d8-b647-82e6ce3b3e16","actor_username":"marzouq@marzex.tech","actor_via_sso":false,"log_type":"token"}	2025-01-19 11:02:51.230893+00	
00000000-0000-0000-0000-000000000000	2d43f127-9e4e-44c8-9a75-9616e8724750	{"action":"token_refreshed","actor_id":"3aa665b7-a4dd-40d8-b647-82e6ce3b3e16","actor_username":"marzouq@marzex.tech","actor_via_sso":false,"log_type":"token"}	2025-01-19 12:01:14.232405+00	
00000000-0000-0000-0000-000000000000	016b3836-7c87-42bb-86f0-c67a1eab9e2b	{"action":"token_revoked","actor_id":"3aa665b7-a4dd-40d8-b647-82e6ce3b3e16","actor_username":"marzouq@marzex.tech","actor_via_sso":false,"log_type":"token"}	2025-01-19 12:01:14.23261+00	
00000000-0000-0000-0000-000000000000	1cd78bb2-30d0-4015-8663-cd487b177348	{"action":"token_refreshed","actor_id":"3aa665b7-a4dd-40d8-b647-82e6ce3b3e16","actor_username":"marzouq@marzex.tech","actor_via_sso":false,"log_type":"token"}	2025-01-19 12:59:47.688677+00	
00000000-0000-0000-0000-000000000000	7e6a863e-7146-4824-8ccd-1b81efa53d9b	{"action":"token_revoked","actor_id":"3aa665b7-a4dd-40d8-b647-82e6ce3b3e16","actor_username":"marzouq@marzex.tech","actor_via_sso":false,"log_type":"token"}	2025-01-19 12:59:47.688936+00	
00000000-0000-0000-0000-000000000000	954d80bf-7f49-4378-a914-360de7df912d	{"action":"token_refreshed","actor_id":"3aa665b7-a4dd-40d8-b647-82e6ce3b3e16","actor_username":"marzouq@marzex.tech","actor_via_sso":false,"log_type":"token"}	2025-01-19 14:02:06.591227+00	
00000000-0000-0000-0000-000000000000	40100bae-54af-4796-8085-6ecd7bbd14bf	{"action":"token_revoked","actor_id":"3aa665b7-a4dd-40d8-b647-82e6ce3b3e16","actor_username":"marzouq@marzex.tech","actor_via_sso":false,"log_type":"token"}	2025-01-19 14:02:06.591564+00	
00000000-0000-0000-0000-000000000000	8ccbb38e-ee0b-40cf-b8b0-13718d4080c4	{"action":"login","actor_id":"3aa665b7-a4dd-40d8-b647-82e6ce3b3e16","actor_username":"marzouq@marzex.tech","actor_via_sso":false,"log_type":"account","traits":{"provider":"email"}}	2025-01-19 14:51:23.471186+00	
00000000-0000-0000-0000-000000000000	00078f46-add0-4e8c-987f-bd134c933945	{"action":"token_refreshed","actor_id":"3aa665b7-a4dd-40d8-b647-82e6ce3b3e16","actor_username":"marzouq@marzex.tech","actor_via_sso":false,"log_type":"token"}	2025-01-20 12:33:11.61687+00	
00000000-0000-0000-0000-000000000000	88e2e42c-64f8-4436-aaf6-0ff254762228	{"action":"token_revoked","actor_id":"3aa665b7-a4dd-40d8-b647-82e6ce3b3e16","actor_username":"marzouq@marzex.tech","actor_via_sso":false,"log_type":"token"}	2025-01-20 12:33:11.617931+00	
00000000-0000-0000-0000-000000000000	fadbbfd5-8518-4eec-baec-f4c06d31a719	{"action":"login","actor_id":"3aa665b7-a4dd-40d8-b647-82e6ce3b3e16","actor_username":"marzouq@marzex.tech","actor_via_sso":false,"log_type":"account","traits":{"provider":"email"}}	2025-01-20 12:49:32.921997+00	
00000000-0000-0000-0000-000000000000	2bbfaeea-a1b2-4d3e-b38c-824401b48cb8	{"action":"login","actor_id":"3aa665b7-a4dd-40d8-b647-82e6ce3b3e16","actor_username":"marzouq@marzex.tech","actor_via_sso":false,"log_type":"account","traits":{"provider":"email"}}	2025-01-20 12:49:44.868587+00	
00000000-0000-0000-0000-000000000000	34f78205-cdef-4996-b5ca-69fdf1d2b310	{"action":"token_refreshed","actor_id":"3aa665b7-a4dd-40d8-b647-82e6ce3b3e16","actor_username":"marzouq@marzex.tech","actor_via_sso":false,"log_type":"token"}	2025-01-20 13:31:15.69768+00	
00000000-0000-0000-0000-000000000000	8c2fae0f-dc34-4cc4-9ac5-2bc572274f09	{"action":"token_revoked","actor_id":"3aa665b7-a4dd-40d8-b647-82e6ce3b3e16","actor_username":"marzouq@marzex.tech","actor_via_sso":false,"log_type":"token"}	2025-01-20 13:31:15.697902+00	
00000000-0000-0000-0000-000000000000	358317c9-e623-4134-ad0a-6fbaeca52979	{"action":"token_refreshed","actor_id":"3aa665b7-a4dd-40d8-b647-82e6ce3b3e16","actor_username":"marzouq@marzex.tech","actor_via_sso":false,"log_type":"token"}	2025-01-20 13:49:21.931129+00	
00000000-0000-0000-0000-000000000000	1fc9fa57-f09b-42b0-bf12-1b700ef0f7e2	{"action":"token_revoked","actor_id":"3aa665b7-a4dd-40d8-b647-82e6ce3b3e16","actor_username":"marzouq@marzex.tech","actor_via_sso":false,"log_type":"token"}	2025-01-20 13:49:21.931349+00	
00000000-0000-0000-0000-000000000000	412b1a5e-216a-464b-b3c1-621020e78e23	{"action":"token_refreshed","actor_id":"3aa665b7-a4dd-40d8-b647-82e6ce3b3e16","actor_username":"marzouq@marzex.tech","actor_via_sso":false,"log_type":"token"}	2025-01-20 13:49:33.87641+00	
00000000-0000-0000-0000-000000000000	9dc40849-7172-4126-833e-e8b4db7fa86d	{"action":"token_revoked","actor_id":"3aa665b7-a4dd-40d8-b647-82e6ce3b3e16","actor_username":"marzouq@marzex.tech","actor_via_sso":false,"log_type":"token"}	2025-01-20 13:49:33.876614+00	
00000000-0000-0000-0000-000000000000	d8a0c7fb-b939-4185-aa71-a21fbfdbdc60	{"action":"token_refreshed","actor_id":"3aa665b7-a4dd-40d8-b647-82e6ce3b3e16","actor_username":"marzouq@marzex.tech","actor_via_sso":false,"log_type":"token"}	2025-01-20 14:49:10.941632+00	
00000000-0000-0000-0000-000000000000	1b4cc452-7d1b-44a0-bdf5-b969259aa6dc	{"action":"token_revoked","actor_id":"3aa665b7-a4dd-40d8-b647-82e6ce3b3e16","actor_username":"marzouq@marzex.tech","actor_via_sso":false,"log_type":"token"}	2025-01-20 14:49:10.948447+00	
00000000-0000-0000-0000-000000000000	1ccc0f95-9fa8-4573-8a29-7cfe9ef48297	{"action":"token_refreshed","actor_id":"3aa665b7-a4dd-40d8-b647-82e6ce3b3e16","actor_username":"marzouq@marzex.tech","actor_via_sso":false,"log_type":"token"}	2025-01-20 14:49:22.891416+00	
00000000-0000-0000-0000-000000000000	c6a8aa67-e3e8-479c-8b50-5c163ee3b887	{"action":"token_revoked","actor_id":"3aa665b7-a4dd-40d8-b647-82e6ce3b3e16","actor_username":"marzouq@marzex.tech","actor_via_sso":false,"log_type":"token"}	2025-01-20 14:49:22.891649+00	
00000000-0000-0000-0000-000000000000	32476157-3144-4d18-828b-a2fa916aa24e	{"action":"token_refreshed","actor_id":"3aa665b7-a4dd-40d8-b647-82e6ce3b3e16","actor_username":"marzouq@marzex.tech","actor_via_sso":false,"log_type":"token"}	2025-01-20 15:48:59.958079+00	
00000000-0000-0000-0000-000000000000	383c9c0a-c449-4bb8-946f-d32e4e9b1fbe	{"action":"token_revoked","actor_id":"3aa665b7-a4dd-40d8-b647-82e6ce3b3e16","actor_username":"marzouq@marzex.tech","actor_via_sso":false,"log_type":"token"}	2025-01-20 15:48:59.958342+00	
00000000-0000-0000-0000-000000000000	396ded86-0574-4483-a60a-671b3441a4b4	{"action":"token_refreshed","actor_id":"3aa665b7-a4dd-40d8-b647-82e6ce3b3e16","actor_username":"marzouq@marzex.tech","actor_via_sso":false,"log_type":"token"}	2025-01-20 15:49:11.906369+00	
00000000-0000-0000-0000-000000000000	215390cf-0cc9-4f15-a52f-9c88934f652d	{"action":"token_revoked","actor_id":"3aa665b7-a4dd-40d8-b647-82e6ce3b3e16","actor_username":"marzouq@marzex.tech","actor_via_sso":false,"log_type":"token"}	2025-01-20 15:49:11.906628+00	
00000000-0000-0000-0000-000000000000	438445bb-335d-4bc6-8ff0-9351ff2ed0e5	{"action":"token_refreshed","actor_id":"3aa665b7-a4dd-40d8-b647-82e6ce3b3e16","actor_username":"marzouq@marzex.tech","actor_via_sso":false,"log_type":"token"}	2025-01-21 12:20:43.541435+00	
00000000-0000-0000-0000-000000000000	0fd6d114-f00c-40ba-a48a-0aa6c5ac28a7	{"action":"token_revoked","actor_id":"3aa665b7-a4dd-40d8-b647-82e6ce3b3e16","actor_username":"marzouq@marzex.tech","actor_via_sso":false,"log_type":"token"}	2025-01-21 12:20:43.542438+00	
00000000-0000-0000-0000-000000000000	96182bd4-7336-4d0b-91d1-fe9282c96977	{"action":"token_refreshed","actor_id":"3aa665b7-a4dd-40d8-b647-82e6ce3b3e16","actor_username":"marzouq@marzex.tech","actor_via_sso":false,"log_type":"token"}	2025-01-21 13:19:00.211045+00	
00000000-0000-0000-0000-000000000000	21fa6637-95ea-4591-911b-f1e6db60d0cd	{"action":"token_revoked","actor_id":"3aa665b7-a4dd-40d8-b647-82e6ce3b3e16","actor_username":"marzouq@marzex.tech","actor_via_sso":false,"log_type":"token"}	2025-01-21 13:19:00.211289+00	
00000000-0000-0000-0000-000000000000	98a5c21c-b0a5-42eb-ba74-347af84f259f	{"action":"token_refreshed","actor_id":"3aa665b7-a4dd-40d8-b647-82e6ce3b3e16","actor_username":"marzouq@marzex.tech","actor_via_sso":false,"log_type":"token"}	2025-01-21 15:24:37.393745+00	
00000000-0000-0000-0000-000000000000	4d90a54c-ee6a-4503-a0af-669e10d2b098	{"action":"token_revoked","actor_id":"3aa665b7-a4dd-40d8-b647-82e6ce3b3e16","actor_username":"marzouq@marzex.tech","actor_via_sso":false,"log_type":"token"}	2025-01-21 15:24:37.39396+00	
00000000-0000-0000-0000-000000000000	3f68fbf4-0ca3-40e5-b2d0-dc08d1373f72	{"action":"token_refreshed","actor_id":"3aa665b7-a4dd-40d8-b647-82e6ce3b3e16","actor_username":"marzouq@marzex.tech","actor_via_sso":false,"log_type":"token"}	2025-01-22 07:09:43.165035+00	
00000000-0000-0000-0000-000000000000	1792f7e1-70f4-4f77-af15-2017a784e212	{"action":"token_revoked","actor_id":"3aa665b7-a4dd-40d8-b647-82e6ce3b3e16","actor_username":"marzouq@marzex.tech","actor_via_sso":false,"log_type":"token"}	2025-01-22 07:09:43.16637+00	
00000000-0000-0000-0000-000000000000	295fbdd4-b43b-425b-b201-affe9332b496	{"action":"token_refreshed","actor_id":"3aa665b7-a4dd-40d8-b647-82e6ce3b3e16","actor_username":"marzouq@marzex.tech","actor_via_sso":false,"log_type":"token"}	2025-01-22 08:19:57.390424+00	
00000000-0000-0000-0000-000000000000	adbff579-2c05-4fcb-b828-30186eac6fbb	{"action":"token_revoked","actor_id":"3aa665b7-a4dd-40d8-b647-82e6ce3b3e16","actor_username":"marzouq@marzex.tech","actor_via_sso":false,"log_type":"token"}	2025-01-22 08:19:57.390825+00	
00000000-0000-0000-0000-000000000000	a0584013-2f57-459b-9dca-b0500dfcadb4	{"action":"login","actor_id":"3aa665b7-a4dd-40d8-b647-82e6ce3b3e16","actor_username":"marzouq@marzex.tech","actor_via_sso":false,"log_type":"account","traits":{"provider":"email"}}	2025-01-22 12:57:05.316926+00	
00000000-0000-0000-0000-000000000000	7d612b39-8608-46b8-bb11-546c17336791	{"action":"login","actor_id":"3aa665b7-a4dd-40d8-b647-82e6ce3b3e16","actor_username":"marzouq@marzex.tech","actor_via_sso":false,"log_type":"account","traits":{"provider":"email"}}	2025-01-22 13:14:00.953111+00	
00000000-0000-0000-0000-000000000000	511d49b6-ba9e-4819-91d4-7f0744731979	{"action":"token_refreshed","actor_id":"3aa665b7-a4dd-40d8-b647-82e6ce3b3e16","actor_username":"marzouq@marzex.tech","actor_via_sso":false,"log_type":"token"}	2025-01-22 13:56:55.328819+00	
00000000-0000-0000-0000-000000000000	939d74cb-b22c-451b-86bc-900bc218219d	{"action":"token_revoked","actor_id":"3aa665b7-a4dd-40d8-b647-82e6ce3b3e16","actor_username":"marzouq@marzex.tech","actor_via_sso":false,"log_type":"token"}	2025-01-22 13:56:55.329034+00	
00000000-0000-0000-0000-000000000000	167a31d9-d2b0-4e9d-9a0c-1c777125bf0d	{"action":"token_refreshed","actor_id":"3aa665b7-a4dd-40d8-b647-82e6ce3b3e16","actor_username":"marzouq@marzex.tech","actor_via_sso":false,"log_type":"token"}	2025-01-22 14:13:49.968978+00	
00000000-0000-0000-0000-000000000000	a501405b-ae52-4298-b16f-78a8b189f0fb	{"action":"token_revoked","actor_id":"3aa665b7-a4dd-40d8-b647-82e6ce3b3e16","actor_username":"marzouq@marzex.tech","actor_via_sso":false,"log_type":"token"}	2025-01-22 14:13:49.969194+00	
00000000-0000-0000-0000-000000000000	df2c4dc4-9d7c-4eb2-8319-1677e3dd67cd	{"action":"token_refreshed","actor_id":"3aa665b7-a4dd-40d8-b647-82e6ce3b3e16","actor_username":"marzouq@marzex.tech","actor_via_sso":false,"log_type":"token"}	2025-01-22 14:56:45.344906+00	
00000000-0000-0000-0000-000000000000	db4a0ed4-08ac-4a23-9be2-be2f46d474e4	{"action":"token_revoked","actor_id":"3aa665b7-a4dd-40d8-b647-82e6ce3b3e16","actor_username":"marzouq@marzex.tech","actor_via_sso":false,"log_type":"token"}	2025-01-22 14:56:45.345143+00	
00000000-0000-0000-0000-000000000000	f6e13493-2eb0-4454-bdda-5f040935010a	{"action":"token_refreshed","actor_id":"3aa665b7-a4dd-40d8-b647-82e6ce3b3e16","actor_username":"marzouq@marzex.tech","actor_via_sso":false,"log_type":"token"}	2025-01-22 15:08:07.15529+00	
00000000-0000-0000-0000-000000000000	719d5975-9b94-46c6-93f0-6b7aac42415e	{"action":"token_revoked","actor_id":"3aa665b7-a4dd-40d8-b647-82e6ce3b3e16","actor_username":"marzouq@marzex.tech","actor_via_sso":false,"log_type":"token"}	2025-01-22 15:08:07.155609+00	
00000000-0000-0000-0000-000000000000	34546a37-c73c-43b7-927a-e2b3a61981de	{"action":"token_refreshed","actor_id":"3aa665b7-a4dd-40d8-b647-82e6ce3b3e16","actor_username":"marzouq@marzex.tech","actor_via_sso":false,"log_type":"token"}	2025-01-22 15:13:38.990567+00	
00000000-0000-0000-0000-000000000000	ccf50700-8fa6-4db9-be8e-068522d865d1	{"action":"token_revoked","actor_id":"3aa665b7-a4dd-40d8-b647-82e6ce3b3e16","actor_username":"marzouq@marzex.tech","actor_via_sso":false,"log_type":"token"}	2025-01-22 15:13:38.990798+00	
00000000-0000-0000-0000-000000000000	d696ea83-f04d-40bb-8ee3-74d91c2794c4	{"action":"token_refreshed","actor_id":"3aa665b7-a4dd-40d8-b647-82e6ce3b3e16","actor_username":"marzouq@marzex.tech","actor_via_sso":false,"log_type":"token"}	2025-01-22 16:06:30.502264+00	
00000000-0000-0000-0000-000000000000	bf2027b6-7905-4dda-aac1-a76beb4eae1f	{"action":"token_revoked","actor_id":"3aa665b7-a4dd-40d8-b647-82e6ce3b3e16","actor_username":"marzouq@marzex.tech","actor_via_sso":false,"log_type":"token"}	2025-01-22 16:06:30.502532+00	
00000000-0000-0000-0000-000000000000	4afebf66-0218-4097-abab-2ba903a6cef1	{"action":"login","actor_id":"3aa665b7-a4dd-40d8-b647-82e6ce3b3e16","actor_username":"marzouq@marzex.tech","actor_via_sso":false,"log_type":"account","traits":{"provider":"email"}}	2025-01-22 16:21:19.245188+00	
00000000-0000-0000-0000-000000000000	23b5abfb-3f19-464d-9aee-4dba00886f77	{"action":"login","actor_id":"3aa665b7-a4dd-40d8-b647-82e6ce3b3e16","actor_username":"marzouq@marzex.tech","actor_via_sso":false,"log_type":"account","traits":{"provider":"email"}}	2025-01-22 16:32:51.992118+00	
00000000-0000-0000-0000-000000000000	082dc368-8475-4fff-bc2d-f030fe019c15	{"action":"login","actor_id":"3aa665b7-a4dd-40d8-b647-82e6ce3b3e16","actor_username":"marzouq@marzex.tech","actor_via_sso":false,"log_type":"account","traits":{"provider":"email"}}	2025-01-22 16:37:38.231435+00	
00000000-0000-0000-0000-000000000000	d72489e4-c755-4c26-b801-211f879f83e8	{"action":"token_refreshed","actor_id":"3aa665b7-a4dd-40d8-b647-82e6ce3b3e16","actor_username":"marzouq@marzex.tech","actor_via_sso":false,"log_type":"token"}	2025-01-22 17:06:22.126754+00	
00000000-0000-0000-0000-000000000000	4872182f-0531-4c71-9380-f7db48b6d47c	{"action":"token_revoked","actor_id":"3aa665b7-a4dd-40d8-b647-82e6ce3b3e16","actor_username":"marzouq@marzex.tech","actor_via_sso":false,"log_type":"token"}	2025-01-22 17:06:22.127153+00	
00000000-0000-0000-0000-000000000000	3bd6d25a-af81-4748-8437-e63dbd8f08cc	{"action":"token_refreshed","actor_id":"3aa665b7-a4dd-40d8-b647-82e6ce3b3e16","actor_username":"marzouq@marzex.tech","actor_via_sso":false,"log_type":"token"}	2025-01-22 17:37:28.246823+00	
00000000-0000-0000-0000-000000000000	d0ac3bde-39a3-4267-ad14-7c114b407bb8	{"action":"token_revoked","actor_id":"3aa665b7-a4dd-40d8-b647-82e6ce3b3e16","actor_username":"marzouq@marzex.tech","actor_via_sso":false,"log_type":"token"}	2025-01-22 17:37:28.247033+00	
00000000-0000-0000-0000-000000000000	7c7fdae9-a2ec-451a-9ead-942d1b342a71	{"action":"token_refreshed","actor_id":"3aa665b7-a4dd-40d8-b647-82e6ce3b3e16","actor_username":"marzouq@marzex.tech","actor_via_sso":false,"log_type":"token"}	2025-01-22 17:37:28.252741+00	
00000000-0000-0000-0000-000000000000	074a9938-0a27-4a35-8366-6655dd851826	{"action":"token_revoked","actor_id":"3aa665b7-a4dd-40d8-b647-82e6ce3b3e16","actor_username":"marzouq@marzex.tech","actor_via_sso":false,"log_type":"token"}	2025-01-22 17:37:28.252915+00	
00000000-0000-0000-0000-000000000000	be62b84a-14d5-46d2-93df-69c013602d94	{"action":"token_refreshed","actor_id":"3aa665b7-a4dd-40d8-b647-82e6ce3b3e16","actor_username":"marzouq@marzex.tech","actor_via_sso":false,"log_type":"token"}	2025-01-22 18:04:39.128871+00	
00000000-0000-0000-0000-000000000000	a4dd39f5-cf2c-4b05-be8d-52ac2af18989	{"action":"token_revoked","actor_id":"3aa665b7-a4dd-40d8-b647-82e6ce3b3e16","actor_username":"marzouq@marzex.tech","actor_via_sso":false,"log_type":"token"}	2025-01-22 18:04:39.129108+00	
00000000-0000-0000-0000-000000000000	2988c483-57ac-421f-9dde-c61f4b126961	{"action":"token_refreshed","actor_id":"3aa665b7-a4dd-40d8-b647-82e6ce3b3e16","actor_username":"marzouq@marzex.tech","actor_via_sso":false,"log_type":"token"}	2025-01-23 04:17:55.379509+00	
00000000-0000-0000-0000-000000000000	ebf132ac-5070-48a4-bb7e-fd9836406345	{"action":"token_revoked","actor_id":"3aa665b7-a4dd-40d8-b647-82e6ce3b3e16","actor_username":"marzouq@marzex.tech","actor_via_sso":false,"log_type":"token"}	2025-01-23 04:17:55.380509+00	
00000000-0000-0000-0000-000000000000	178b45d9-ea3b-4ccf-9e3e-e48812acf9f3	{"action":"login","actor_id":"3aa665b7-a4dd-40d8-b647-82e6ce3b3e16","actor_username":"marzouq@marzex.tech","actor_via_sso":false,"log_type":"account","traits":{"provider":"email"}}	2025-01-23 04:19:14.341005+00	
00000000-0000-0000-0000-000000000000	65600013-06a9-4940-a161-c44b1f6af50f	{"action":"token_refreshed","actor_id":"3aa665b7-a4dd-40d8-b647-82e6ce3b3e16","actor_username":"marzouq@marzex.tech","actor_via_sso":false,"log_type":"token"}	2025-01-23 05:18:33.642666+00	
00000000-0000-0000-0000-000000000000	5252cce5-1d2d-404f-8dc7-6ce95ad7d94a	{"action":"token_revoked","actor_id":"3aa665b7-a4dd-40d8-b647-82e6ce3b3e16","actor_username":"marzouq@marzex.tech","actor_via_sso":false,"log_type":"token"}	2025-01-23 05:18:33.642905+00	
00000000-0000-0000-0000-000000000000	2b821c6f-d730-4080-bb0a-32010d2a173a	{"action":"user_signedup","actor_id":"f17d8111-cccf-4b85-afa7-ed9ad199e0ea","actor_username":"test@marzex.tech","actor_via_sso":false,"log_type":"team","traits":{"provider":"email"}}	2025-01-23 05:32:06.521043+00	
00000000-0000-0000-0000-000000000000	ee938cfa-553f-4fbe-a69e-4d5adaf204e6	{"action":"login","actor_id":"f17d8111-cccf-4b85-afa7-ed9ad199e0ea","actor_username":"test@marzex.tech","actor_via_sso":false,"log_type":"account","traits":{"provider":"email"}}	2025-01-23 05:32:06.523461+00	
00000000-0000-0000-0000-000000000000	e85a4631-2b9f-485d-b763-a27961f2cdee	{"action":"login","actor_id":"3aa665b7-a4dd-40d8-b647-82e6ce3b3e16","actor_username":"marzouq@marzex.tech","actor_via_sso":false,"log_type":"account","traits":{"provider":"email"}}	2025-01-23 05:34:20.060868+00	
00000000-0000-0000-0000-000000000000	4c90970a-8e39-4684-8002-c726b05bed2b	{"action":"token_refreshed","actor_id":"3aa665b7-a4dd-40d8-b647-82e6ce3b3e16","actor_username":"marzouq@marzex.tech","actor_via_sso":false,"log_type":"token"}	2025-01-23 06:36:58.091215+00	
00000000-0000-0000-0000-000000000000	f040e442-326c-4929-9825-1e93e975cbe6	{"action":"token_revoked","actor_id":"3aa665b7-a4dd-40d8-b647-82e6ce3b3e16","actor_username":"marzouq@marzex.tech","actor_via_sso":false,"log_type":"token"}	2025-01-23 06:36:58.091555+00	
00000000-0000-0000-0000-000000000000	ff347e10-ba27-4d77-b4af-18022bf55339	{"action":"login","actor_id":"3aa665b7-a4dd-40d8-b647-82e6ce3b3e16","actor_username":"marzouq@marzex.tech","actor_via_sso":false,"log_type":"account","traits":{"provider":"email"}}	2025-01-23 06:59:13.93146+00	
00000000-0000-0000-0000-000000000000	347a61ec-c380-4d27-837b-c3c8f1e7b854	{"action":"login","actor_id":"3aa665b7-a4dd-40d8-b647-82e6ce3b3e16","actor_username":"marzouq@marzex.tech","actor_via_sso":false,"log_type":"account","traits":{"provider":"email"}}	2025-01-23 07:04:02.755394+00	
00000000-0000-0000-0000-000000000000	2148f6f1-5baa-44ee-9ef2-137cea5a0921	{"action":"login","actor_id":"f17d8111-cccf-4b85-afa7-ed9ad199e0ea","actor_username":"test@marzex.tech","actor_via_sso":false,"log_type":"account","traits":{"provider":"email"}}	2025-01-23 07:16:40.906149+00	
00000000-0000-0000-0000-000000000000	e20d66fa-c3e2-46c9-b6fe-b9368b5e3d29	{"action":"login","actor_id":"3aa665b7-a4dd-40d8-b647-82e6ce3b3e16","actor_username":"marzouq@marzex.tech","actor_via_sso":false,"log_type":"account","traits":{"provider":"email"}}	2025-01-23 07:19:11.51542+00	
00000000-0000-0000-0000-000000000000	e8aff2ff-f52a-45df-9882-270ca21decd9	{"action":"token_refreshed","actor_id":"3aa665b7-a4dd-40d8-b647-82e6ce3b3e16","actor_username":"marzouq@marzex.tech","actor_via_sso":false,"log_type":"token"}	2025-01-23 08:17:13.927368+00	
00000000-0000-0000-0000-000000000000	83f6f2ed-76cc-42c7-8f68-b72f3ed28008	{"action":"token_revoked","actor_id":"3aa665b7-a4dd-40d8-b647-82e6ce3b3e16","actor_username":"marzouq@marzex.tech","actor_via_sso":false,"log_type":"token"}	2025-01-23 08:17:13.92762+00	
00000000-0000-0000-0000-000000000000	3e025477-3d27-4b6f-a65b-77d992ef2fa9	{"action":"token_refreshed","actor_id":"3aa665b7-a4dd-40d8-b647-82e6ce3b3e16","actor_username":"marzouq@marzex.tech","actor_via_sso":false,"log_type":"token"}	2025-01-23 12:46:38.550255+00	
00000000-0000-0000-0000-000000000000	84bd1a1f-f9dc-4399-86f0-9c1aa180dd95	{"action":"token_revoked","actor_id":"3aa665b7-a4dd-40d8-b647-82e6ce3b3e16","actor_username":"marzouq@marzex.tech","actor_via_sso":false,"log_type":"token"}	2025-01-23 12:46:38.551457+00	
00000000-0000-0000-0000-000000000000	8adec6d9-e968-4a3d-9b1f-a67783164b73	{"action":"token_refreshed","actor_id":"3aa665b7-a4dd-40d8-b647-82e6ce3b3e16","actor_username":"marzouq@marzex.tech","actor_via_sso":false,"log_type":"token"}	2025-01-27 09:40:39.553948+00	
00000000-0000-0000-0000-000000000000	cf701f65-6777-45e0-953f-48e4e203abe3	{"action":"token_revoked","actor_id":"3aa665b7-a4dd-40d8-b647-82e6ce3b3e16","actor_username":"marzouq@marzex.tech","actor_via_sso":false,"log_type":"token"}	2025-01-27 09:40:39.55496+00	
00000000-0000-0000-0000-000000000000	b039607a-502c-4d7d-8ed8-3c25b22cb04c	{"action":"token_refreshed","actor_id":"3aa665b7-a4dd-40d8-b647-82e6ce3b3e16","actor_username":"marzouq@marzex.tech","actor_via_sso":false,"log_type":"token"}	2025-01-28 12:08:14.721651+00	
00000000-0000-0000-0000-000000000000	bcbb8ecc-0d69-4b24-aad6-b5e9c4803716	{"action":"token_revoked","actor_id":"3aa665b7-a4dd-40d8-b647-82e6ce3b3e16","actor_username":"marzouq@marzex.tech","actor_via_sso":false,"log_type":"token"}	2025-01-28 12:08:14.72278+00	
00000000-0000-0000-0000-000000000000	7219f98c-f276-4a7d-9c39-fd9589fb64f5	{"action":"token_refreshed","actor_id":"3aa665b7-a4dd-40d8-b647-82e6ce3b3e16","actor_username":"marzouq@marzex.tech","actor_via_sso":false,"log_type":"token"}	2025-01-28 13:37:17.856073+00	
00000000-0000-0000-0000-000000000000	f4815c04-62c8-46b7-9a7e-6f054b021bf8	{"action":"token_revoked","actor_id":"3aa665b7-a4dd-40d8-b647-82e6ce3b3e16","actor_username":"marzouq@marzex.tech","actor_via_sso":false,"log_type":"token"}	2025-01-28 13:37:17.856334+00	
00000000-0000-0000-0000-000000000000	fc1784d7-5f44-4ebf-9c4f-8e9e69269f88	{"action":"token_refreshed","actor_id":"3aa665b7-a4dd-40d8-b647-82e6ce3b3e16","actor_username":"marzouq@marzex.tech","actor_via_sso":false,"log_type":"token"}	2025-01-28 14:37:32.688918+00	
00000000-0000-0000-0000-000000000000	f353d4f5-0f35-4476-a886-fbcb20e7419c	{"action":"token_revoked","actor_id":"3aa665b7-a4dd-40d8-b647-82e6ce3b3e16","actor_username":"marzouq@marzex.tech","actor_via_sso":false,"log_type":"token"}	2025-01-28 14:37:32.689129+00	
00000000-0000-0000-0000-000000000000	fedcb808-da33-4ab4-b3b1-e5c2bd60e6ac	{"action":"token_refreshed","actor_id":"3aa665b7-a4dd-40d8-b647-82e6ce3b3e16","actor_username":"marzouq@marzex.tech","actor_via_sso":false,"log_type":"token"}	2025-01-28 15:50:38.280528+00	
00000000-0000-0000-0000-000000000000	f46aad23-d7d8-4b40-b2c6-9409da9ded8d	{"action":"token_revoked","actor_id":"3aa665b7-a4dd-40d8-b647-82e6ce3b3e16","actor_username":"marzouq@marzex.tech","actor_via_sso":false,"log_type":"token"}	2025-01-28 15:50:38.28073+00	
00000000-0000-0000-0000-000000000000	a10ae06e-58d8-4018-b2c4-8587dfad6e31	{"action":"token_refreshed","actor_id":"3aa665b7-a4dd-40d8-b647-82e6ce3b3e16","actor_username":"marzouq@marzex.tech","actor_via_sso":false,"log_type":"token"}	2025-01-29 13:26:27.346996+00	
00000000-0000-0000-0000-000000000000	13044971-75ec-4728-a4f9-0c6b4f5b3538	{"action":"token_revoked","actor_id":"3aa665b7-a4dd-40d8-b647-82e6ce3b3e16","actor_username":"marzouq@marzex.tech","actor_via_sso":false,"log_type":"token"}	2025-01-29 13:26:27.348454+00	
00000000-0000-0000-0000-000000000000	7a013315-bf5d-4e3b-98a6-3699d5d3a7a4	{"action":"token_refreshed","actor_id":"3aa665b7-a4dd-40d8-b647-82e6ce3b3e16","actor_username":"marzouq@marzex.tech","actor_via_sso":false,"log_type":"token"}	2025-01-29 14:25:32.186026+00	
00000000-0000-0000-0000-000000000000	13ae8ddf-f8c4-47ed-a304-e97f062571fa	{"action":"token_revoked","actor_id":"3aa665b7-a4dd-40d8-b647-82e6ce3b3e16","actor_username":"marzouq@marzex.tech","actor_via_sso":false,"log_type":"token"}	2025-01-29 14:25:32.186294+00	
00000000-0000-0000-0000-000000000000	795fae81-b897-4286-9014-8a5a40d4651a	{"action":"token_refreshed","actor_id":"3aa665b7-a4dd-40d8-b647-82e6ce3b3e16","actor_username":"marzouq@marzex.tech","actor_via_sso":false,"log_type":"token"}	2025-01-30 06:30:33.7904+00	
00000000-0000-0000-0000-000000000000	8bcb3f8c-6f3a-4c0f-b9ca-db473db9b5d1	{"action":"token_revoked","actor_id":"3aa665b7-a4dd-40d8-b647-82e6ce3b3e16","actor_username":"marzouq@marzex.tech","actor_via_sso":false,"log_type":"token"}	2025-01-30 06:30:33.791825+00	
00000000-0000-0000-0000-000000000000	d40ceb9a-b6ad-436b-bb3d-bd34d7084019	{"action":"token_refreshed","actor_id":"3aa665b7-a4dd-40d8-b647-82e6ce3b3e16","actor_username":"marzouq@marzex.tech","actor_via_sso":false,"log_type":"token"}	2025-01-30 08:19:52.702685+00	
00000000-0000-0000-0000-000000000000	1cf45298-d584-4d5e-92b1-c4fa5887266c	{"action":"token_revoked","actor_id":"3aa665b7-a4dd-40d8-b647-82e6ce3b3e16","actor_username":"marzouq@marzex.tech","actor_via_sso":false,"log_type":"token"}	2025-01-30 08:19:52.702953+00	
00000000-0000-0000-0000-000000000000	235f2d59-0f6a-41a8-af98-b03abfce4d38	{"action":"token_refreshed","actor_id":"3aa665b7-a4dd-40d8-b647-82e6ce3b3e16","actor_username":"marzouq@marzex.tech","actor_via_sso":false,"log_type":"token"}	2025-01-30 09:32:06.120231+00	
00000000-0000-0000-0000-000000000000	4037cba9-fae9-4fff-9345-b453ae25d740	{"action":"token_revoked","actor_id":"3aa665b7-a4dd-40d8-b647-82e6ce3b3e16","actor_username":"marzouq@marzex.tech","actor_via_sso":false,"log_type":"token"}	2025-01-30 09:32:06.120555+00	
00000000-0000-0000-0000-000000000000	dc27a3fd-cd9c-4392-a959-208f6e846e72	{"action":"token_refreshed","actor_id":"3aa665b7-a4dd-40d8-b647-82e6ce3b3e16","actor_username":"marzouq@marzex.tech","actor_via_sso":false,"log_type":"token"}	2025-01-30 10:44:56.802907+00	
00000000-0000-0000-0000-000000000000	8e27ff63-9162-4bb7-a279-c0c9e57aa94f	{"action":"token_revoked","actor_id":"3aa665b7-a4dd-40d8-b647-82e6ce3b3e16","actor_username":"marzouq@marzex.tech","actor_via_sso":false,"log_type":"token"}	2025-01-30 10:44:56.803208+00	
00000000-0000-0000-0000-000000000000	08c22320-cf0f-4d7d-af00-1439152bddef	{"action":"token_refreshed","actor_id":"3aa665b7-a4dd-40d8-b647-82e6ce3b3e16","actor_username":"marzouq@marzex.tech","actor_via_sso":false,"log_type":"token"}	2025-01-30 12:25:11.046651+00	
00000000-0000-0000-0000-000000000000	278439b0-4e87-46d5-afe6-c2ef635cbf67	{"action":"token_revoked","actor_id":"3aa665b7-a4dd-40d8-b647-82e6ce3b3e16","actor_username":"marzouq@marzex.tech","actor_via_sso":false,"log_type":"token"}	2025-01-30 12:25:11.046845+00	
00000000-0000-0000-0000-000000000000	7ba9f2e0-8c33-4c9d-854f-088c18b6f656	{"action":"token_refreshed","actor_id":"3aa665b7-a4dd-40d8-b647-82e6ce3b3e16","actor_username":"marzouq@marzex.tech","actor_via_sso":false,"log_type":"token"}	2025-01-30 14:01:46.036108+00	
00000000-0000-0000-0000-000000000000	57a6d33b-e2ee-4dfe-a950-4e0253ce8f8f	{"action":"token_revoked","actor_id":"3aa665b7-a4dd-40d8-b647-82e6ce3b3e16","actor_username":"marzouq@marzex.tech","actor_via_sso":false,"log_type":"token"}	2025-01-30 14:01:46.036389+00	
00000000-0000-0000-0000-000000000000	c8c5d65c-3628-458a-9acf-ccfa7a9b7652	{"action":"token_refreshed","actor_id":"3aa665b7-a4dd-40d8-b647-82e6ce3b3e16","actor_username":"marzouq@marzex.tech","actor_via_sso":false,"log_type":"token"}	2025-02-01 12:57:59.836062+00	
00000000-0000-0000-0000-000000000000	64c40fc5-b32e-41e9-9d79-866b0506a516	{"action":"token_revoked","actor_id":"3aa665b7-a4dd-40d8-b647-82e6ce3b3e16","actor_username":"marzouq@marzex.tech","actor_via_sso":false,"log_type":"token"}	2025-02-01 12:57:59.837792+00	
00000000-0000-0000-0000-000000000000	c0b645f5-5ca0-4712-ae8c-39ae9392e85c	{"action":"token_refreshed","actor_id":"3aa665b7-a4dd-40d8-b647-82e6ce3b3e16","actor_username":"marzouq@marzex.tech","actor_via_sso":false,"log_type":"token"}	2025-02-01 14:32:30.673362+00	
00000000-0000-0000-0000-000000000000	b83b8e27-b2cb-4267-83eb-7b3fabbb078a	{"action":"token_revoked","actor_id":"3aa665b7-a4dd-40d8-b647-82e6ce3b3e16","actor_username":"marzouq@marzex.tech","actor_via_sso":false,"log_type":"token"}	2025-02-01 14:32:30.67365+00	
00000000-0000-0000-0000-000000000000	e953330d-f2c2-4121-b3be-e7c596d7dd94	{"action":"token_refreshed","actor_id":"3aa665b7-a4dd-40d8-b647-82e6ce3b3e16","actor_username":"marzouq@marzex.tech","actor_via_sso":false,"log_type":"token"}	2025-02-01 16:02:15.546768+00	
00000000-0000-0000-0000-000000000000	e84757a9-c14f-4706-ac4b-5f6d67c0337e	{"action":"token_revoked","actor_id":"3aa665b7-a4dd-40d8-b647-82e6ce3b3e16","actor_username":"marzouq@marzex.tech","actor_via_sso":false,"log_type":"token"}	2025-02-01 16:02:15.547022+00	
00000000-0000-0000-0000-000000000000	e124acba-33fe-46ba-a94b-2654cc04ec05	{"action":"token_refreshed","actor_id":"3aa665b7-a4dd-40d8-b647-82e6ce3b3e16","actor_username":"marzouq@marzex.tech","actor_via_sso":false,"log_type":"token"}	2025-02-02 04:55:32.064988+00	
00000000-0000-0000-0000-000000000000	9f79a48e-a7b6-4068-b893-609db241c85e	{"action":"token_revoked","actor_id":"3aa665b7-a4dd-40d8-b647-82e6ce3b3e16","actor_username":"marzouq@marzex.tech","actor_via_sso":false,"log_type":"token"}	2025-02-02 04:55:32.06591+00	
00000000-0000-0000-0000-000000000000	9edbf72e-212b-4f68-969b-68e640c7ade9	{"action":"token_refreshed","actor_id":"3aa665b7-a4dd-40d8-b647-82e6ce3b3e16","actor_username":"marzouq@marzex.tech","actor_via_sso":false,"log_type":"token"}	2025-02-02 06:08:03.64492+00	
00000000-0000-0000-0000-000000000000	d3f2d9ef-649d-4e83-9e9c-fb44d3b1e579	{"action":"token_revoked","actor_id":"3aa665b7-a4dd-40d8-b647-82e6ce3b3e16","actor_username":"marzouq@marzex.tech","actor_via_sso":false,"log_type":"token"}	2025-02-02 06:08:03.645178+00	
00000000-0000-0000-0000-000000000000	b94f34bc-75ec-4ea6-ad44-4a0e3a716dee	{"action":"token_refreshed","actor_id":"3aa665b7-a4dd-40d8-b647-82e6ce3b3e16","actor_username":"marzouq@marzex.tech","actor_via_sso":false,"log_type":"token"}	2025-02-02 09:22:31.812124+00	
00000000-0000-0000-0000-000000000000	9de4a59e-958b-4911-9e1c-2845d27e4c35	{"action":"token_revoked","actor_id":"3aa665b7-a4dd-40d8-b647-82e6ce3b3e16","actor_username":"marzouq@marzex.tech","actor_via_sso":false,"log_type":"token"}	2025-02-02 09:22:31.812394+00	
00000000-0000-0000-0000-000000000000	8e16023e-8b26-4a90-aa16-24637ba28f1e	{"action":"token_refreshed","actor_id":"3aa665b7-a4dd-40d8-b647-82e6ce3b3e16","actor_username":"marzouq@marzex.tech","actor_via_sso":false,"log_type":"token"}	2025-02-02 10:21:18.436875+00	
00000000-0000-0000-0000-000000000000	ef6d257e-0bea-44ed-abe4-9ae9009b02ce	{"action":"token_revoked","actor_id":"3aa665b7-a4dd-40d8-b647-82e6ce3b3e16","actor_username":"marzouq@marzex.tech","actor_via_sso":false,"log_type":"token"}	2025-02-02 10:21:18.437102+00	
00000000-0000-0000-0000-000000000000	76533623-15da-468d-8421-17ce33f36d16	{"action":"token_refreshed","actor_id":"3aa665b7-a4dd-40d8-b647-82e6ce3b3e16","actor_username":"marzouq@marzex.tech","actor_via_sso":false,"log_type":"token"}	2025-02-02 12:16:33.474384+00	
00000000-0000-0000-0000-000000000000	66d01b2e-5b20-47f3-8510-d63c8de02c29	{"action":"token_revoked","actor_id":"3aa665b7-a4dd-40d8-b647-82e6ce3b3e16","actor_username":"marzouq@marzex.tech","actor_via_sso":false,"log_type":"token"}	2025-02-02 12:16:33.474631+00	
00000000-0000-0000-0000-000000000000	2ccf97e2-1815-4dc1-acc5-ebc8fce8d1d0	{"action":"token_refreshed","actor_id":"3aa665b7-a4dd-40d8-b647-82e6ce3b3e16","actor_username":"marzouq@marzex.tech","actor_via_sso":false,"log_type":"token"}	2025-02-02 13:16:46.8129+00	
00000000-0000-0000-0000-000000000000	b8a5922e-194d-4feb-ab94-3494f39c6661	{"action":"token_revoked","actor_id":"3aa665b7-a4dd-40d8-b647-82e6ce3b3e16","actor_username":"marzouq@marzex.tech","actor_via_sso":false,"log_type":"token"}	2025-02-02 13:16:46.813127+00	
00000000-0000-0000-0000-000000000000	102173ba-6872-4f6e-83a2-57195d077358	{"action":"login","actor_id":"3aa665b7-a4dd-40d8-b647-82e6ce3b3e16","actor_username":"marzouq@marzex.tech","actor_via_sso":false,"log_type":"account","traits":{"provider":"email"}}	2025-02-02 14:06:17.687167+00	
00000000-0000-0000-0000-000000000000	6eb02fe8-742b-4c5d-ad18-28ee95646d8e	{"action":"token_refreshed","actor_id":"3aa665b7-a4dd-40d8-b647-82e6ce3b3e16","actor_username":"marzouq@marzex.tech","actor_via_sso":false,"log_type":"token"}	2025-02-02 14:14:58.120137+00	
00000000-0000-0000-0000-000000000000	d71cd378-f179-437a-8ce0-357ab700ed74	{"action":"token_revoked","actor_id":"3aa665b7-a4dd-40d8-b647-82e6ce3b3e16","actor_username":"marzouq@marzex.tech","actor_via_sso":false,"log_type":"token"}	2025-02-02 14:14:58.120368+00	
00000000-0000-0000-0000-000000000000	004b728e-40b8-42bd-8a6e-e2cef792f426	{"action":"token_refreshed","actor_id":"3aa665b7-a4dd-40d8-b647-82e6ce3b3e16","actor_username":"marzouq@marzex.tech","actor_via_sso":false,"log_type":"token"}	2025-02-02 15:04:38.956192+00	
00000000-0000-0000-0000-000000000000	52e1b82e-1eee-4b01-ada0-30a56afdd489	{"action":"token_revoked","actor_id":"3aa665b7-a4dd-40d8-b647-82e6ce3b3e16","actor_username":"marzouq@marzex.tech","actor_via_sso":false,"log_type":"token"}	2025-02-02 15:04:38.956447+00	
00000000-0000-0000-0000-000000000000	5d9ac83b-994e-442f-847e-45ba040c31d7	{"action":"token_refreshed","actor_id":"3aa665b7-a4dd-40d8-b647-82e6ce3b3e16","actor_username":"marzouq@marzex.tech","actor_via_sso":false,"log_type":"token"}	2025-02-03 13:28:02.920638+00	
00000000-0000-0000-0000-000000000000	9ea25491-d0ce-4c82-bd79-56c88ab6d02c	{"action":"token_revoked","actor_id":"3aa665b7-a4dd-40d8-b647-82e6ce3b3e16","actor_username":"marzouq@marzex.tech","actor_via_sso":false,"log_type":"token"}	2025-02-03 13:28:02.921897+00	
00000000-0000-0000-0000-000000000000	eadeb54e-fb6f-4d5f-a271-8a73c1fcc9cb	{"action":"token_refreshed","actor_id":"3aa665b7-a4dd-40d8-b647-82e6ce3b3e16","actor_username":"marzouq@marzex.tech","actor_via_sso":false,"log_type":"token"}	2025-02-03 14:43:40.800239+00	
00000000-0000-0000-0000-000000000000	bb23b765-6e5b-44b9-a019-bd70477a3d44	{"action":"token_revoked","actor_id":"3aa665b7-a4dd-40d8-b647-82e6ce3b3e16","actor_username":"marzouq@marzex.tech","actor_via_sso":false,"log_type":"token"}	2025-02-03 14:43:40.800517+00	
00000000-0000-0000-0000-000000000000	42e17ee6-6785-4b1c-8832-6d6c3ceb4cc8	{"action":"token_refreshed","actor_id":"3aa665b7-a4dd-40d8-b647-82e6ce3b3e16","actor_username":"marzouq@marzex.tech","actor_via_sso":false,"log_type":"token"}	2025-02-04 13:05:38.70787+00	
00000000-0000-0000-0000-000000000000	699d7f48-a818-408f-98b3-57b998fdbc8c	{"action":"token_revoked","actor_id":"3aa665b7-a4dd-40d8-b647-82e6ce3b3e16","actor_username":"marzouq@marzex.tech","actor_via_sso":false,"log_type":"token"}	2025-02-04 13:05:38.708946+00	
00000000-0000-0000-0000-000000000000	2e134822-585d-4089-9953-686913469e8a	{"action":"token_refreshed","actor_id":"3aa665b7-a4dd-40d8-b647-82e6ce3b3e16","actor_username":"marzouq@marzex.tech","actor_via_sso":false,"log_type":"token"}	2025-02-04 14:03:38.226539+00	
00000000-0000-0000-0000-000000000000	97208738-08aa-426f-8fc5-50a2d8dd7565	{"action":"token_revoked","actor_id":"3aa665b7-a4dd-40d8-b647-82e6ce3b3e16","actor_username":"marzouq@marzex.tech","actor_via_sso":false,"log_type":"token"}	2025-02-04 14:03:38.226758+00	
00000000-0000-0000-0000-000000000000	cefeac3c-1460-4d60-b431-10083bba66c0	{"action":"token_refreshed","actor_id":"3aa665b7-a4dd-40d8-b647-82e6ce3b3e16","actor_username":"marzouq@marzex.tech","actor_via_sso":false,"log_type":"token"}	2025-02-04 15:30:18.134709+00	
00000000-0000-0000-0000-000000000000	d78bfe9b-8751-4cb6-9beb-83424c3983f1	{"action":"token_revoked","actor_id":"3aa665b7-a4dd-40d8-b647-82e6ce3b3e16","actor_username":"marzouq@marzex.tech","actor_via_sso":false,"log_type":"token"}	2025-02-04 15:30:18.1349+00	
00000000-0000-0000-0000-000000000000	4acddcd1-c66f-4958-aa12-fa9bf739446d	{"action":"token_refreshed","actor_id":"3aa665b7-a4dd-40d8-b647-82e6ce3b3e16","actor_username":"marzouq@marzex.tech","actor_via_sso":false,"log_type":"token"}	2025-02-05 07:00:53.915853+00	
00000000-0000-0000-0000-000000000000	94d49dff-7f9b-4a7d-8056-5d38455e377c	{"action":"token_revoked","actor_id":"3aa665b7-a4dd-40d8-b647-82e6ce3b3e16","actor_username":"marzouq@marzex.tech","actor_via_sso":false,"log_type":"token"}	2025-02-05 07:00:53.917037+00	
00000000-0000-0000-0000-000000000000	d8a69f39-b3a7-44d1-a321-001cecab61b4	{"action":"token_refreshed","actor_id":"3aa665b7-a4dd-40d8-b647-82e6ce3b3e16","actor_username":"marzouq@marzex.tech","actor_via_sso":false,"log_type":"token"}	2025-02-05 09:59:07.649822+00	
00000000-0000-0000-0000-000000000000	80ae58d5-7d1e-47d1-b8d0-42a50988ed6c	{"action":"token_revoked","actor_id":"3aa665b7-a4dd-40d8-b647-82e6ce3b3e16","actor_username":"marzouq@marzex.tech","actor_via_sso":false,"log_type":"token"}	2025-02-05 09:59:07.650017+00	
00000000-0000-0000-0000-000000000000	c95423f5-016f-4f78-8c22-93219b370615	{"action":"token_refreshed","actor_id":"3aa665b7-a4dd-40d8-b647-82e6ce3b3e16","actor_username":"marzouq@marzex.tech","actor_via_sso":false,"log_type":"token"}	2025-02-05 11:46:21.516096+00	
00000000-0000-0000-0000-000000000000	bc431b31-b58d-42d2-88da-8cca198a49cc	{"action":"token_revoked","actor_id":"3aa665b7-a4dd-40d8-b647-82e6ce3b3e16","actor_username":"marzouq@marzex.tech","actor_via_sso":false,"log_type":"token"}	2025-02-05 11:46:21.516374+00	
00000000-0000-0000-0000-000000000000	7e556604-a4a5-4726-afe8-3067356906bd	{"action":"token_refreshed","actor_id":"3aa665b7-a4dd-40d8-b647-82e6ce3b3e16","actor_username":"marzouq@marzex.tech","actor_via_sso":false,"log_type":"token"}	2025-02-05 13:05:06.608604+00	
00000000-0000-0000-0000-000000000000	d923d124-a85d-4e78-adf9-89c65cfd7196	{"action":"token_revoked","actor_id":"3aa665b7-a4dd-40d8-b647-82e6ce3b3e16","actor_username":"marzouq@marzex.tech","actor_via_sso":false,"log_type":"token"}	2025-02-05 13:05:06.60886+00	
00000000-0000-0000-0000-000000000000	db3310f4-8f49-4c38-a40f-697fa393809b	{"action":"login","actor_id":"3aa665b7-a4dd-40d8-b647-82e6ce3b3e16","actor_username":"marzouq@marzex.tech","actor_via_sso":false,"log_type":"account","traits":{"provider":"email"}}	2025-02-05 13:38:30.505011+00	
00000000-0000-0000-0000-000000000000	e225470f-5a24-47af-9406-4d484ab4b9d2	{"action":"login","actor_id":"3aa665b7-a4dd-40d8-b647-82e6ce3b3e16","actor_username":"marzouq@marzex.tech","actor_via_sso":false,"log_type":"account","traits":{"provider":"email"}}	2025-02-05 13:43:18.310428+00	
00000000-0000-0000-0000-000000000000	3324c631-700b-4208-bc82-393376ee1695	{"action":"token_refreshed","actor_id":"3aa665b7-a4dd-40d8-b647-82e6ce3b3e16","actor_username":"marzouq@marzex.tech","actor_via_sso":false,"log_type":"token"}	2025-02-05 14:41:40.539218+00	
00000000-0000-0000-0000-000000000000	f9198863-0589-446e-b177-6c5571dd82d3	{"action":"token_revoked","actor_id":"3aa665b7-a4dd-40d8-b647-82e6ce3b3e16","actor_username":"marzouq@marzex.tech","actor_via_sso":false,"log_type":"token"}	2025-02-05 14:41:40.539482+00	
00000000-0000-0000-0000-000000000000	fc69967d-611c-4e75-bee1-8a223b4a67bf	{"action":"token_refreshed","actor_id":"3aa665b7-a4dd-40d8-b647-82e6ce3b3e16","actor_username":"marzouq@marzex.tech","actor_via_sso":false,"log_type":"token"}	2025-02-05 14:49:22.06913+00	
00000000-0000-0000-0000-000000000000	d7892fdc-1d13-4668-8e7b-85377482d297	{"action":"token_revoked","actor_id":"3aa665b7-a4dd-40d8-b647-82e6ce3b3e16","actor_username":"marzouq@marzex.tech","actor_via_sso":false,"log_type":"token"}	2025-02-05 14:49:22.069364+00	
00000000-0000-0000-0000-000000000000	6d5df1ab-dccc-43c7-9106-6fd7ba134f4c	{"action":"token_refreshed","actor_id":"3aa665b7-a4dd-40d8-b647-82e6ce3b3e16","actor_username":"marzouq@marzex.tech","actor_via_sso":false,"log_type":"token"}	2025-02-10 06:29:21.02084+00	
00000000-0000-0000-0000-000000000000	a35ca662-e2b2-4be7-8171-18c1ee5d5950	{"action":"token_revoked","actor_id":"3aa665b7-a4dd-40d8-b647-82e6ce3b3e16","actor_username":"marzouq@marzex.tech","actor_via_sso":false,"log_type":"token"}	2025-02-10 06:29:21.021599+00	
00000000-0000-0000-0000-000000000000	73d1f843-48ca-41e5-99ab-10514abb09d9	{"action":"token_refreshed","actor_id":"3aa665b7-a4dd-40d8-b647-82e6ce3b3e16","actor_username":"marzouq@marzex.tech","actor_via_sso":false,"log_type":"token"}	2025-02-10 08:02:09.570911+00	
00000000-0000-0000-0000-000000000000	6370b8d2-a7f9-4ff6-8dcd-849f7e253405	{"action":"token_revoked","actor_id":"3aa665b7-a4dd-40d8-b647-82e6ce3b3e16","actor_username":"marzouq@marzex.tech","actor_via_sso":false,"log_type":"token"}	2025-02-10 08:02:09.571157+00	
00000000-0000-0000-0000-000000000000	43e8c755-2510-41ae-aa92-3187692d497e	{"action":"token_refreshed","actor_id":"3aa665b7-a4dd-40d8-b647-82e6ce3b3e16","actor_username":"marzouq@marzex.tech","actor_via_sso":false,"log_type":"token"}	2025-02-10 10:59:56.82631+00	
00000000-0000-0000-0000-000000000000	93ffae4b-3474-406e-a176-d62b878cdf7d	{"action":"token_revoked","actor_id":"3aa665b7-a4dd-40d8-b647-82e6ce3b3e16","actor_username":"marzouq@marzex.tech","actor_via_sso":false,"log_type":"token"}	2025-02-10 10:59:56.826538+00	
00000000-0000-0000-0000-000000000000	f6a05425-59e2-44b6-892c-a4963a73a8a9	{"action":"token_refreshed","actor_id":"3aa665b7-a4dd-40d8-b647-82e6ce3b3e16","actor_username":"marzouq@marzex.tech","actor_via_sso":false,"log_type":"token"}	2025-02-10 11:58:23.612435+00	
00000000-0000-0000-0000-000000000000	7f075386-d5b2-4742-8083-0fb528751474	{"action":"token_revoked","actor_id":"3aa665b7-a4dd-40d8-b647-82e6ce3b3e16","actor_username":"marzouq@marzex.tech","actor_via_sso":false,"log_type":"token"}	2025-02-10 11:58:23.612775+00	
00000000-0000-0000-0000-000000000000	df694ce1-ae86-45a9-b950-c5ed8abc4d56	{"action":"token_refreshed","actor_id":"3aa665b7-a4dd-40d8-b647-82e6ce3b3e16","actor_username":"marzouq@marzex.tech","actor_via_sso":false,"log_type":"token"}	2025-02-10 12:56:26.094356+00	
00000000-0000-0000-0000-000000000000	ae65af2c-ccba-4978-84b6-52e12a02e9d6	{"action":"token_revoked","actor_id":"3aa665b7-a4dd-40d8-b647-82e6ce3b3e16","actor_username":"marzouq@marzex.tech","actor_via_sso":false,"log_type":"token"}	2025-02-10 12:56:26.09455+00	
00000000-0000-0000-0000-000000000000	1b78b262-e621-4d2c-923f-27a59aabcf53	{"action":"token_refreshed","actor_id":"3aa665b7-a4dd-40d8-b647-82e6ce3b3e16","actor_username":"marzouq@marzex.tech","actor_via_sso":false,"log_type":"token"}	2025-02-10 14:06:54.268771+00	
00000000-0000-0000-0000-000000000000	a6c68ce4-fe9a-46ae-a1a2-bca9fa172bf6	{"action":"token_revoked","actor_id":"3aa665b7-a4dd-40d8-b647-82e6ce3b3e16","actor_username":"marzouq@marzex.tech","actor_via_sso":false,"log_type":"token"}	2025-02-10 14:06:54.268977+00	
00000000-0000-0000-0000-000000000000	1f2f9707-c807-4b55-81d6-756ac35c5b4d	{"action":"login","actor_id":"3aa665b7-a4dd-40d8-b647-82e6ce3b3e16","actor_username":"marzouq@marzex.tech","actor_via_sso":false,"log_type":"account","traits":{"provider":"email"}}	2025-02-10 14:36:26.241927+00	
00000000-0000-0000-0000-000000000000	640c515a-e2e2-422a-b644-98b633917c93	{"action":"token_refreshed","actor_id":"3aa665b7-a4dd-40d8-b647-82e6ce3b3e16","actor_username":"marzouq@marzex.tech","actor_via_sso":false,"log_type":"token"}	2025-02-10 16:04:41.098801+00	
00000000-0000-0000-0000-000000000000	598ca1c5-b53d-4839-ae6f-49e50a49dcb3	{"action":"token_revoked","actor_id":"3aa665b7-a4dd-40d8-b647-82e6ce3b3e16","actor_username":"marzouq@marzex.tech","actor_via_sso":false,"log_type":"token"}	2025-02-10 16:04:41.099042+00	
00000000-0000-0000-0000-000000000000	e47ae2d3-90bd-483a-b531-e55f025e2716	{"action":"token_refreshed","actor_id":"3aa665b7-a4dd-40d8-b647-82e6ce3b3e16","actor_username":"marzouq@marzex.tech","actor_via_sso":false,"log_type":"token"}	2025-02-10 18:38:41.945836+00	
00000000-0000-0000-0000-000000000000	01ae9345-19ae-4c81-849b-2fc0aad48713	{"action":"token_revoked","actor_id":"3aa665b7-a4dd-40d8-b647-82e6ce3b3e16","actor_username":"marzouq@marzex.tech","actor_via_sso":false,"log_type":"token"}	2025-02-10 18:38:41.946064+00	
00000000-0000-0000-0000-000000000000	9d18d40f-52a5-4b94-9063-a7201209f13d	{"action":"token_refreshed","actor_id":"3aa665b7-a4dd-40d8-b647-82e6ce3b3e16","actor_username":"marzouq@marzex.tech","actor_via_sso":false,"log_type":"token"}	2025-02-11 06:21:04.289105+00	
00000000-0000-0000-0000-000000000000	4340b022-89ea-4892-982f-004043396a59	{"action":"token_revoked","actor_id":"3aa665b7-a4dd-40d8-b647-82e6ce3b3e16","actor_username":"marzouq@marzex.tech","actor_via_sso":false,"log_type":"token"}	2025-02-11 06:21:04.290546+00	
00000000-0000-0000-0000-000000000000	b9072e49-5101-4853-b78e-cd02adab1cd2	{"action":"login","actor_id":"3aa665b7-a4dd-40d8-b647-82e6ce3b3e16","actor_username":"marzouq@marzex.tech","actor_via_sso":false,"log_type":"account","traits":{"provider":"email"}}	2025-02-11 06:21:46.771646+00	
00000000-0000-0000-0000-000000000000	87739e7a-e043-40cb-b2ed-51c8d1e52764	{"action":"token_refreshed","actor_id":"3aa665b7-a4dd-40d8-b647-82e6ce3b3e16","actor_username":"marzouq@marzex.tech","actor_via_sso":false,"log_type":"token"}	2025-02-11 07:19:47.139487+00	
00000000-0000-0000-0000-000000000000	ac261fa5-c36b-4092-a57d-1c0774955656	{"action":"token_revoked","actor_id":"3aa665b7-a4dd-40d8-b647-82e6ce3b3e16","actor_username":"marzouq@marzex.tech","actor_via_sso":false,"log_type":"token"}	2025-02-11 07:19:47.139694+00	
00000000-0000-0000-0000-000000000000	f9083733-0938-41fc-8b20-e7efc68f8457	{"action":"token_refreshed","actor_id":"3aa665b7-a4dd-40d8-b647-82e6ce3b3e16","actor_username":"marzouq@marzex.tech","actor_via_sso":false,"log_type":"token"}	2025-02-11 08:55:10.672254+00	
00000000-0000-0000-0000-000000000000	43fe0dd0-4e14-44d9-ba54-9596b6256fcd	{"action":"token_revoked","actor_id":"3aa665b7-a4dd-40d8-b647-82e6ce3b3e16","actor_username":"marzouq@marzex.tech","actor_via_sso":false,"log_type":"token"}	2025-02-11 08:55:10.672488+00	
00000000-0000-0000-0000-000000000000	49d26435-5bae-4ef0-8324-a0180ceba730	{"action":"token_refreshed","actor_id":"3aa665b7-a4dd-40d8-b647-82e6ce3b3e16","actor_username":"marzouq@marzex.tech","actor_via_sso":false,"log_type":"token"}	2025-02-11 10:56:35.793048+00	
00000000-0000-0000-0000-000000000000	f5d61a74-5dac-484d-b328-99fd0ca450b4	{"action":"token_revoked","actor_id":"3aa665b7-a4dd-40d8-b647-82e6ce3b3e16","actor_username":"marzouq@marzex.tech","actor_via_sso":false,"log_type":"token"}	2025-02-11 10:56:35.793314+00	
00000000-0000-0000-0000-000000000000	95b3ca34-9581-4d68-ba0b-25d0e61e4dad	{"action":"token_refreshed","actor_id":"3aa665b7-a4dd-40d8-b647-82e6ce3b3e16","actor_username":"marzouq@marzex.tech","actor_via_sso":false,"log_type":"token"}	2025-02-11 11:59:26.445086+00	
00000000-0000-0000-0000-000000000000	67263ad2-d833-4308-b63f-4467075ab03c	{"action":"token_revoked","actor_id":"3aa665b7-a4dd-40d8-b647-82e6ce3b3e16","actor_username":"marzouq@marzex.tech","actor_via_sso":false,"log_type":"token"}	2025-02-11 11:59:26.445304+00	
00000000-0000-0000-0000-000000000000	a9d65d6f-7694-4927-9d21-a1f2f172b453	{"action":"token_refreshed","actor_id":"3aa665b7-a4dd-40d8-b647-82e6ce3b3e16","actor_username":"marzouq@marzex.tech","actor_via_sso":false,"log_type":"token"}	2025-02-11 13:16:54.859329+00	
00000000-0000-0000-0000-000000000000	3585d86e-e1c6-43fe-87fb-e06728f9b10c	{"action":"token_revoked","actor_id":"3aa665b7-a4dd-40d8-b647-82e6ce3b3e16","actor_username":"marzouq@marzex.tech","actor_via_sso":false,"log_type":"token"}	2025-02-11 13:16:54.859586+00	
00000000-0000-0000-0000-000000000000	8ba49962-a5cd-495f-9773-d45087cdb7ff	{"action":"token_refreshed","actor_id":"3aa665b7-a4dd-40d8-b647-82e6ce3b3e16","actor_username":"marzouq@marzex.tech","actor_via_sso":false,"log_type":"token"}	2025-02-11 14:45:01.140605+00	
00000000-0000-0000-0000-000000000000	c98f64d2-7e78-431c-b9dd-3974fd50ecbf	{"action":"token_revoked","actor_id":"3aa665b7-a4dd-40d8-b647-82e6ce3b3e16","actor_username":"marzouq@marzex.tech","actor_via_sso":false,"log_type":"token"}	2025-02-11 14:45:01.140945+00	
00000000-0000-0000-0000-000000000000	4e3f4805-888b-41f9-9114-ea2c9952bddb	{"action":"login","actor_id":"3aa665b7-a4dd-40d8-b647-82e6ce3b3e16","actor_username":"marzouq@marzex.tech","actor_via_sso":false,"log_type":"account","traits":{"provider":"email"}}	2025-02-11 14:45:38.367667+00	
00000000-0000-0000-0000-000000000000	aa8cba07-87e3-452e-931e-5d4b3ccc95fd	{"action":"token_refreshed","actor_id":"3aa665b7-a4dd-40d8-b647-82e6ce3b3e16","actor_username":"marzouq@marzex.tech","actor_via_sso":false,"log_type":"token"}	2025-02-11 15:50:29.692322+00	
00000000-0000-0000-0000-000000000000	bf364025-18c7-4c47-b988-060d242f1469	{"action":"token_revoked","actor_id":"3aa665b7-a4dd-40d8-b647-82e6ce3b3e16","actor_username":"marzouq@marzex.tech","actor_via_sso":false,"log_type":"token"}	2025-02-11 15:50:29.69262+00	
00000000-0000-0000-0000-000000000000	1fc2204b-ead8-4dd3-9ffb-2cb32dfa365c	{"action":"login","actor_id":"3aa665b7-a4dd-40d8-b647-82e6ce3b3e16","actor_username":"marzouq@marzex.tech","actor_via_sso":false,"log_type":"account","traits":{"provider":"email"}}	2025-02-12 03:00:56.066627+00	
00000000-0000-0000-0000-000000000000	00e53f10-3420-459f-aa62-f53db309d41e	{"action":"login","actor_id":"3aa665b7-a4dd-40d8-b647-82e6ce3b3e16","actor_username":"marzouq@marzex.tech","actor_via_sso":false,"log_type":"account","traits":{"provider":"email"}}	2025-02-12 03:37:55.096793+00	
00000000-0000-0000-0000-000000000000	8850bc09-8259-4c7b-9c12-e2568fdb0505	{"action":"login","actor_id":"3aa665b7-a4dd-40d8-b647-82e6ce3b3e16","actor_username":"marzouq@marzex.tech","actor_via_sso":false,"log_type":"account","traits":{"provider":"email"}}	2025-02-12 03:39:23.366288+00	
00000000-0000-0000-0000-000000000000	aeec4fec-283c-42bf-b313-9dde04431e3c	{"action":"login","actor_id":"3aa665b7-a4dd-40d8-b647-82e6ce3b3e16","actor_username":"marzouq@marzex.tech","actor_via_sso":false,"log_type":"account","traits":{"provider":"email"}}	2025-02-15 13:22:09.012901+00	
00000000-0000-0000-0000-000000000000	9114e9d2-fd72-498a-ab9b-718fe99bf8bb	{"action":"login","actor_id":"3aa665b7-a4dd-40d8-b647-82e6ce3b3e16","actor_username":"marzouq@marzex.tech","actor_via_sso":false,"log_type":"account","traits":{"provider":"email"}}	2025-02-15 13:39:22.122196+00	
00000000-0000-0000-0000-000000000000	f2db4a89-7657-400a-976b-4b703d446e1b	{"action":"logout","actor_id":"3aa665b7-a4dd-40d8-b647-82e6ce3b3e16","actor_username":"marzouq@marzex.tech","actor_via_sso":false,"log_type":"account"}	2025-02-15 13:41:17.034148+00	
00000000-0000-0000-0000-000000000000	e0af2964-915b-4540-b1a9-92abe33082a8	{"action":"login","actor_id":"3aa665b7-a4dd-40d8-b647-82e6ce3b3e16","actor_username":"marzouq@marzex.tech","actor_via_sso":false,"log_type":"account","traits":{"provider":"email"}}	2025-02-15 13:48:57.636851+00	
00000000-0000-0000-0000-000000000000	2fe2d635-366a-4c2f-ad86-adc43c797228	{"action":"login","actor_id":"3aa665b7-a4dd-40d8-b647-82e6ce3b3e16","actor_username":"marzouq@marzex.tech","actor_via_sso":false,"log_type":"account","traits":{"provider":"email"}}	2025-02-16 14:10:46.854552+00	
00000000-0000-0000-0000-000000000000	15b4a133-9611-4151-bb81-520f2d37a9c1	{"action":"token_refreshed","actor_id":"3aa665b7-a4dd-40d8-b647-82e6ce3b3e16","actor_username":"marzouq@marzex.tech","actor_via_sso":false,"log_type":"token"}	2025-02-16 15:09:08.873946+00	
00000000-0000-0000-0000-000000000000	ad8f11ac-f160-418d-bca1-dfb2336f3b15	{"action":"token_revoked","actor_id":"3aa665b7-a4dd-40d8-b647-82e6ce3b3e16","actor_username":"marzouq@marzex.tech","actor_via_sso":false,"log_type":"token"}	2025-02-16 15:09:08.874204+00	
00000000-0000-0000-0000-000000000000	c706534b-ead9-4d11-913c-a28afdddfe3a	{"action":"login","actor_id":"3aa665b7-a4dd-40d8-b647-82e6ce3b3e16","actor_username":"marzouq@marzex.tech","actor_via_sso":false,"log_type":"account","traits":{"provider":"email"}}	2025-02-16 15:32:43.364819+00	
00000000-0000-0000-0000-000000000000	2abc942f-9b27-4a7c-a7ab-aed64bc595bd	{"action":"logout","actor_id":"3aa665b7-a4dd-40d8-b647-82e6ce3b3e16","actor_username":"marzouq@marzex.tech","actor_via_sso":false,"log_type":"account"}	2025-02-16 15:57:37.837908+00	
00000000-0000-0000-0000-000000000000	105cf402-da3b-4ae6-a8c6-57230d257dac	{"action":"login","actor_id":"3aa665b7-a4dd-40d8-b647-82e6ce3b3e16","actor_username":"marzouq@marzex.tech","actor_via_sso":false,"log_type":"account","traits":{"provider":"email"}}	2025-02-16 16:05:45.837187+00	
00000000-0000-0000-0000-000000000000	72eadce3-6d14-4bdf-bc92-e11e678d1595	{"action":"logout","actor_id":"3aa665b7-a4dd-40d8-b647-82e6ce3b3e16","actor_username":"marzouq@marzex.tech","actor_via_sso":false,"log_type":"account"}	2025-02-16 16:07:25.50523+00	
00000000-0000-0000-0000-000000000000	63a6ec59-01cb-40bf-a727-24013494a109	{"action":"login","actor_id":"3aa665b7-a4dd-40d8-b647-82e6ce3b3e16","actor_username":"marzouq@marzex.tech","actor_via_sso":false,"log_type":"account","traits":{"provider":"email"}}	2025-02-16 16:08:26.841704+00	
00000000-0000-0000-0000-000000000000	58055437-4015-469c-a8c3-3b9b75e296f0	{"action":"logout","actor_id":"3aa665b7-a4dd-40d8-b647-82e6ce3b3e16","actor_username":"marzouq@marzex.tech","actor_via_sso":false,"log_type":"account"}	2025-02-16 16:40:15.911275+00	
00000000-0000-0000-0000-000000000000	3d2f56d6-3747-463d-bff4-621b9ad5d89e	{"action":"login","actor_id":"3aa665b7-a4dd-40d8-b647-82e6ce3b3e16","actor_username":"marzouq@marzex.tech","actor_via_sso":false,"log_type":"account","traits":{"provider":"email"}}	2025-02-16 16:40:33.110898+00	
00000000-0000-0000-0000-000000000000	6ba47eca-5ebe-48c3-bfb1-0d733a95d465	{"action":"token_refreshed","actor_id":"3aa665b7-a4dd-40d8-b647-82e6ce3b3e16","actor_username":"marzouq@marzex.tech","actor_via_sso":false,"log_type":"token"}	2025-02-16 17:38:47.655794+00	
00000000-0000-0000-0000-000000000000	547a0b0d-d575-4eda-a76c-1dc380563709	{"action":"token_revoked","actor_id":"3aa665b7-a4dd-40d8-b647-82e6ce3b3e16","actor_username":"marzouq@marzex.tech","actor_via_sso":false,"log_type":"token"}	2025-02-16 17:38:47.656033+00	
00000000-0000-0000-0000-000000000000	3853a3ee-8e6d-4702-9e0b-7f31f0f033ee	{"action":"login","actor_id":"3aa665b7-a4dd-40d8-b647-82e6ce3b3e16","actor_username":"marzouq@marzex.tech","actor_via_sso":false,"log_type":"account","traits":{"provider":"email"}}	2025-02-17 03:23:38.907358+00	
00000000-0000-0000-0000-000000000000	af3b1691-edf4-4ce5-a78e-568ff44d087b	{"action":"login","actor_id":"3aa665b7-a4dd-40d8-b647-82e6ce3b3e16","actor_username":"marzouq@marzex.tech","actor_via_sso":false,"log_type":"account","traits":{"provider":"email"}}	2025-02-17 03:37:12.763796+00	
00000000-0000-0000-0000-000000000000	acbde2e3-91a3-45a2-9245-e1f93fc3435e	{"action":"logout","actor_id":"3aa665b7-a4dd-40d8-b647-82e6ce3b3e16","actor_username":"marzouq@marzex.tech","actor_via_sso":false,"log_type":"account"}	2025-02-17 03:47:11.785194+00	
00000000-0000-0000-0000-000000000000	e1dabd4e-a2b3-403c-bc62-f16d17a15a2e	{"action":"login","actor_id":"3aa665b7-a4dd-40d8-b647-82e6ce3b3e16","actor_username":"marzouq@marzex.tech","actor_via_sso":false,"log_type":"account","traits":{"provider":"email"}}	2025-02-18 08:01:42.268995+00	
\.


--
-- Data for Name: flow_state; Type: TABLE DATA; Schema: auth; Owner: supabase_auth_admin
--

COPY auth.flow_state (id, user_id, auth_code, code_challenge_method, code_challenge, provider_type, provider_access_token, provider_refresh_token, created_at, updated_at, authentication_method, auth_code_issued_at) FROM stdin;
\.


--
-- Data for Name: identities; Type: TABLE DATA; Schema: auth; Owner: supabase_auth_admin
--

COPY auth.identities (provider_id, user_id, identity_data, provider, last_sign_in_at, created_at, updated_at, id) FROM stdin;
3aa665b7-a4dd-40d8-b647-82e6ce3b3e16	3aa665b7-a4dd-40d8-b647-82e6ce3b3e16	{"sub": "3aa665b7-a4dd-40d8-b647-82e6ce3b3e16", "email": "marzouq@marzex.tech", "email_verified": false, "phone_verified": false}	email	2025-01-19 06:50:37.254424+00	2025-01-19 06:50:37.254442+00	2025-01-19 06:50:37.254442+00	95c7c7f8-ce76-43ba-a88f-d058ea2ba607
f17d8111-cccf-4b85-afa7-ed9ad199e0ea	f17d8111-cccf-4b85-afa7-ed9ad199e0ea	{"sub": "f17d8111-cccf-4b85-afa7-ed9ad199e0ea", "email": "test@marzex.tech", "email_verified": false, "phone_verified": false}	email	2025-01-23 05:32:06.520119+00	2025-01-23 05:32:06.520143+00	2025-01-23 05:32:06.520143+00	f040fa44-e470-4bc3-b7ac-87ec38147b64
\.


--
-- Data for Name: instances; Type: TABLE DATA; Schema: auth; Owner: supabase_auth_admin
--

COPY auth.instances (id, uuid, raw_base_config, created_at, updated_at) FROM stdin;
\.


--
-- Data for Name: mfa_amr_claims; Type: TABLE DATA; Schema: auth; Owner: supabase_auth_admin
--

COPY auth.mfa_amr_claims (session_id, created_at, updated_at, authentication_method, id) FROM stdin;
f796102b-f38c-4cb2-bd5f-98f8b7414085	2025-01-23 05:32:06.524425+00	2025-01-23 05:32:06.524425+00	password	5505434b-5201-4869-8a31-0e913baeb584
8d090f14-e9c7-4f10-a9be-ce08457f23ce	2025-01-23 07:16:40.907399+00	2025-01-23 07:16:40.907399+00	password	b96133eb-d0ba-4695-900a-bae1e90d8b46
0b3cb8af-27a5-4aa8-8501-e45dc0146103	2025-02-18 08:01:42.273378+00	2025-02-18 08:01:42.273378+00	password	caf0f148-2f58-4be4-8383-dce111867ca8
\.


--
-- Data for Name: mfa_challenges; Type: TABLE DATA; Schema: auth; Owner: supabase_auth_admin
--

COPY auth.mfa_challenges (id, factor_id, created_at, verified_at, ip_address, otp_code, web_authn_session_data) FROM stdin;
\.


--
-- Data for Name: mfa_factors; Type: TABLE DATA; Schema: auth; Owner: supabase_auth_admin
--

COPY auth.mfa_factors (id, user_id, friendly_name, factor_type, status, created_at, updated_at, secret, phone, last_challenged_at, web_authn_credential, web_authn_aaguid) FROM stdin;
\.


--
-- Data for Name: one_time_tokens; Type: TABLE DATA; Schema: auth; Owner: supabase_auth_admin
--

COPY auth.one_time_tokens (id, user_id, token_type, token_hash, relates_to, created_at, updated_at) FROM stdin;
\.


--
-- Data for Name: refresh_tokens; Type: TABLE DATA; Schema: auth; Owner: supabase_auth_admin
--

COPY auth.refresh_tokens (instance_id, id, token, user_id, revoked, created_at, updated_at, parent, session_id) FROM stdin;
00000000-0000-0000-0000-000000000000	207	rpM28_QkpWBkTAScWFj6FA	3aa665b7-a4dd-40d8-b647-82e6ce3b3e16	f	2025-02-18 08:01:42.271103+00	2025-02-18 08:01:42.271103+00	\N	0b3cb8af-27a5-4aa8-8501-e45dc0146103
00000000-0000-0000-0000-000000000000	62	n1U_u5ZlaOf076Fb_YieUQ	f17d8111-cccf-4b85-afa7-ed9ad199e0ea	f	2025-01-23 05:32:06.52399+00	2025-01-23 05:32:06.52399+00	\N	f796102b-f38c-4cb2-bd5f-98f8b7414085
00000000-0000-0000-0000-000000000000	67	ibfsFmkUeg-J8W5anp4gRA	f17d8111-cccf-4b85-afa7-ed9ad199e0ea	f	2025-01-23 07:16:40.906814+00	2025-01-23 07:16:40.906814+00	\N	8d090f14-e9c7-4f10-a9be-ce08457f23ce
\.


--
-- Data for Name: saml_providers; Type: TABLE DATA; Schema: auth; Owner: supabase_auth_admin
--

COPY auth.saml_providers (id, sso_provider_id, entity_id, metadata_xml, metadata_url, attribute_mapping, created_at, updated_at, name_id_format) FROM stdin;
\.


--
-- Data for Name: saml_relay_states; Type: TABLE DATA; Schema: auth; Owner: supabase_auth_admin
--

COPY auth.saml_relay_states (id, sso_provider_id, request_id, for_email, redirect_to, created_at, updated_at, flow_state_id) FROM stdin;
\.


--
-- Data for Name: schema_migrations; Type: TABLE DATA; Schema: auth; Owner: supabase_auth_admin
--

COPY auth.schema_migrations (version) FROM stdin;
20171026211738
20171026211808
20171026211834
20180103212743
20180108183307
20180119214651
20180125194653
00
20210710035447
20210722035447
20210730183235
20210909172000
20210927181326
20211122151130
20211124214934
20211202183645
20220114185221
20220114185340
20220224000811
20220323170000
20220429102000
20220531120530
20220614074223
20220811173540
20221003041349
20221003041400
20221011041400
20221020193600
20221021073300
20221021082433
20221027105023
20221114143122
20221114143410
20221125140132
20221208132122
20221215195500
20221215195800
20221215195900
20230116124310
20230116124412
20230131181311
20230322519590
20230402418590
20230411005111
20230508135423
20230523124323
20230818113222
20230914180801
20231027141322
20231114161723
20231117164230
20240115144230
20240214120130
20240306115329
20240314092811
20240427152123
20240612123726
20240729123726
20240802193726
20240806073726
20241009103726
\.


--
-- Data for Name: sessions; Type: TABLE DATA; Schema: auth; Owner: supabase_auth_admin
--

COPY auth.sessions (id, user_id, created_at, updated_at, factor_id, aal, not_after, refreshed_at, user_agent, ip, tag) FROM stdin;
0b3cb8af-27a5-4aa8-8501-e45dc0146103	3aa665b7-a4dd-40d8-b647-82e6ce3b3e16	2025-02-18 08:01:42.270281+00	2025-02-18 08:01:42.270281+00	\N	aal1	\N	\N	Mozilla/5.0 (X11; Linux x86_64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/131.0.0.0 Safari/537.36	172.25.0.1	\N
f796102b-f38c-4cb2-bd5f-98f8b7414085	f17d8111-cccf-4b85-afa7-ed9ad199e0ea	2025-01-23 05:32:06.523713+00	2025-01-23 05:32:06.523713+00	\N	aal1	\N	\N	Mozilla/5.0 (X11; Linux x86_64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/131.0.0.0 Safari/537.36	172.18.0.1	\N
8d090f14-e9c7-4f10-a9be-ce08457f23ce	f17d8111-cccf-4b85-afa7-ed9ad199e0ea	2025-01-23 07:16:40.906505+00	2025-01-23 07:16:40.906505+00	\N	aal1	\N	\N	Mozilla/5.0 (X11; Linux x86_64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/131.0.0.0 Safari/537.36	172.18.0.1	\N
\.


--
-- Data for Name: sso_domains; Type: TABLE DATA; Schema: auth; Owner: supabase_auth_admin
--

COPY auth.sso_domains (id, sso_provider_id, domain, created_at, updated_at) FROM stdin;
\.


--
-- Data for Name: sso_providers; Type: TABLE DATA; Schema: auth; Owner: supabase_auth_admin
--

COPY auth.sso_providers (id, resource_id, created_at, updated_at) FROM stdin;
\.


--
-- Data for Name: users; Type: TABLE DATA; Schema: auth; Owner: supabase_auth_admin
--

COPY auth.users (instance_id, id, aud, role, email, encrypted_password, email_confirmed_at, invited_at, confirmation_token, confirmation_sent_at, recovery_token, recovery_sent_at, email_change_token_new, email_change, email_change_sent_at, last_sign_in_at, raw_app_meta_data, raw_user_meta_data, is_super_admin, created_at, updated_at, phone, phone_confirmed_at, phone_change, phone_change_token, phone_change_sent_at, email_change_token_current, email_change_confirm_status, banned_until, reauthentication_token, reauthentication_sent_at, is_sso_user, deleted_at, is_anonymous) FROM stdin;
00000000-0000-0000-0000-000000000000	f17d8111-cccf-4b85-afa7-ed9ad199e0ea	authenticated	authenticated	test@marzex.tech	$2a$10$e0f85tX1rDi2ItrNVzzug.CPEeE1YFgPY4eXrlLwJEk0V76RHvjBa	2025-01-23 05:32:06.52122+00	\N		\N		\N			\N	2025-01-23 07:16:40.906458+00	{"provider": "email", "providers": ["email"]}	{"sub": "f17d8111-cccf-4b85-afa7-ed9ad199e0ea", "email": "test@marzex.tech", "email_verified": true, "phone_verified": false}	\N	2025-01-23 05:32:06.518086+00	2025-01-23 07:16:40.907308+00	\N	\N			\N		0	\N		\N	f	\N	f
00000000-0000-0000-0000-000000000000	3aa665b7-a4dd-40d8-b647-82e6ce3b3e16	authenticated	authenticated	marzouq@marzex.tech	$2a$10$D/qv1uXSVxq/Bp.xv5YLY.QlUnZjFsRI07Q9Zwphaeb69/FrVncle	2025-01-19 06:50:37.25535+00	\N		\N		\N			\N	2025-02-18 08:01:42.270244+00	{"provider": "email", "providers": ["email"]}	{"sub": "3aa665b7-a4dd-40d8-b647-82e6ce3b3e16", "email": "marzouq@marzex.tech", "email_verified": true, "phone_verified": false}	\N	2025-01-19 06:50:37.253574+00	2025-02-18 08:01:42.273146+00	\N	\N			\N		0	\N		\N	f	\N	f
\.


--
-- Data for Name: key; Type: TABLE DATA; Schema: pgsodium; Owner: supabase_admin
--

COPY pgsodium.key (id, status, created, expires, key_type, key_id, key_context, name, associated_data, raw_key, raw_key_nonce, parent_key, comment, user_data) FROM stdin;
\.


--
-- Data for Name: complaint_actions; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public.complaint_actions (action_id, created_at, complaint_id, action_by, action, remarks, confidential, documents) FROM stdin;
2	2024-06-24 00:00:00+00	22	lronaghan1@wordpress.com	Notified	Praesent id massa id nisl venenatis lacinia. Aenean sit amet justo. Morbi ut odio.\n\nCras mi pede, malesuada in, imperdiet et, commodo vulputate, justo. In blandit ultrices enim. Lorem ipsum dolor sit amet, consectetuer adipiscing elit.	t	\N
3	2024-04-03 00:00:00+00	22	dstenners2@prweb.com	Escalated	Sed ante. Vivamus tortor. Duis mattis egestas metus.\n\nAenean fermentum. Donec ut mauris eget massa tempor convallis. Nulla neque libero, convallis eget, eleifend luctus, ultricies eu, nibh.\n\nQuisque id justo sit amet sapien dignissim vestibulum. Vestibulum ante ipsum primis in faucibus orci luctus et ultrices posuere cubilia Curae; Nulla dapibus dolor vel est. Donec odio justo, sollicitudin ut, suscipit a, feugiat et, eros.	t	\N
4	2025-01-05 00:00:00+00	22	tcapun3@wordpress.org	Escalated	Nulla ut erat id mauris vulputate elementum. Nullam varius. Nulla facilisi.\n\nCras non velit nec nisi vulputate nonummy. Maecenas tincidunt lacus at velit. Vivamus vel nulla eget eros elementum pellentesque.\n\nQuisque porta volutpat erat. Quisque erat eros, viverra eget, congue eget, semper rutrum, nulla. Nunc purus.	f	\N
5	2024-10-01 00:00:00+00	22	lvaissiere4@chron.com	Investigated	Etiam vel augue. Vestibulum rutrum rutrum neque. Aenean auctor gravida sem.\n\nPraesent id massa id nisl venenatis lacinia. Aenean sit amet justo. Morbi ut odio.	t	\N
6	2024-05-03 00:00:00+00	22	vstanislaw5@macromedia.com	Reviewed	Fusce consequat. Nulla nisl. Nunc nisl.	t	\N
7	2024-11-05 00:00:00+00	22	mchinnery6@storify.com	Requested	Fusce consequat. Nulla nisl. Nunc nisl.\n\nDuis bibendum, felis sed interdum venenatis, turpis enim blandit mi, in porttitor pede justo eu massa. Donec dapibus. Duis at velit eu est congue elementum.\n\nIn hac habitasse platea dictumst. Morbi vestibulum, velit id pretium iaculis, diam erat fermentum justo, nec condimentum neque sapien placerat ante. Nulla justo.	t	\N
8	2024-06-25 00:00:00+00	22	ekollasch7@i2i.jp	Investigated	Proin eu mi. Nulla ac enim. In tempor, turpis nec euismod scelerisque, quam turpis adipiscing lorem, vitae mattis nibh ligula nec sem.\n\nDuis aliquam convallis nunc. Proin at turpis a pede posuere nonummy. Integer non velit.\n\nDonec diam neque, vestibulum eget, vulputate ut, ultrices vel, augue. Vestibulum ante ipsum primis in faucibus orci luctus et ultrices posuere cubilia Curae; Donec pharetra, magna vestibulum aliquet ultrices, erat tortor sollicitudin mi, sit amet lobortis sapien sapien non mi. Integer ac neque.	f	\N
9	2024-02-11 00:00:00+00	22	vcawse8@histats.com	Reviewed	Integer tincidunt ante vel ipsum. Praesent blandit lacinia erat. Vestibulum sed magna at nunc commodo placerat.	f	\N
10	2025-01-12 00:00:00+00	22	odrayn9@vkontakte.ru	Resolved	Maecenas tristique, est et tempus semper, est quam pharetra magna, ac consequat metus sapien ut nunc. Vestibulum ante ipsum primis in faucibus orci luctus et ultrices posuere cubilia Curae; Mauris viverra diam vitae quam. Suspendisse potenti.\n\nNullam porttitor lacus at turpis. Donec posuere metus vitae ipsum. Aliquam non mauris.\n\nMorbi non lectus. Aliquam sit amet diam in magna bibendum imperdiet. Nullam orci pede, venenatis non, sodales sed, tincidunt eu, felis.	f	\N
1	2024-02-09 00:00:00+00	22	nschelle0@freewebs.com	Notified	Proin interdum mauris non ligula pellentesque ultrices. Phasellus id sapien in sapien iaculis congue. Vivamus metus arcu, adipiscing molestie, hendrerit at, vulputate vitae, nisl.\n\nAenean lectus. Pellentesque eget nunc. Donec quis orci eget orci vehicula condimentum.	t	{a5c17d77-ef53-4b14-8e67-7863c54a66ad,dac14523-a80b-4f77-a560-d55b332f0f46}
100	2024-09-29 00:00:00+00	23	dpierucci0@nasa.gov	Investigated	Vestibulum quam sapien, varius ut, blandit non, interdum in, ante. Vestibulum ante ipsum primis in faucibus orci luctus et ultrices posuere cubilia Curae; Duis faucibus accumsan odio. Curabitur convallis.	t	\N
101	2024-04-09 00:00:00+00	23	dinnes1@scribd.com	Investigated	Proin leo odio, porttitor id, consequat in, consequat ut, nulla. Sed accumsan felis. Ut at dolor quis odio consequat varius.\n\nInteger ac leo. Pellentesque ultrices mattis odio. Donec vitae nisi.	t	\N
102	2024-08-17 00:00:00+00	23	vgillise2@engadget.com	Reviewed	Curabitur at ipsum ac tellus semper interdum. Mauris ullamcorper purus sit amet nulla. Quisque arcu libero, rutrum ac, lobortis vel, dapibus at, diam.	f	\N
103	2024-02-28 00:00:00+00	23	adas3@amazon.com	Escalated	Integer ac leo. Pellentesque ultrices mattis odio. Donec vitae nisi.	t	\N
104	2024-08-19 00:00:00+00	23	gargue4@hp.com	Investigated	Curabitur gravida nisi at nibh. In hac habitasse platea dictumst. Aliquam augue quam, sollicitudin vitae, consectetuer eget, rutrum at, lorem.	t	\N
105	2024-06-30 00:00:00+00	23	lpethrick5@constantcontact.com	Escalated	Aenean fermentum. Donec ut mauris eget massa tempor convallis. Nulla neque libero, convallis eget, eleifend luctus, ultricies eu, nibh.	f	\N
106	2024-08-13 00:00:00+00	23	hkyffin6@shop-pro.jp	Escalated	In congue. Etiam justo. Etiam pretium iaculis justo.\n\nIn hac habitasse platea dictumst. Etiam faucibus cursus urna. Ut tellus.	t	\N
107	2024-09-02 00:00:00+00	23	jsimeone7@deviantart.com	Investigated	In congue. Etiam justo. Etiam pretium iaculis justo.\n\nIn hac habitasse platea dictumst. Etiam faucibus cursus urna. Ut tellus.	t	\N
108	2024-08-10 00:00:00+00	23	ccambridge8@cmu.edu	Investigated	Aliquam quis turpis eget elit sodales scelerisque. Mauris sit amet eros. Suspendisse accumsan tortor quis turpis.\n\nSed ante. Vivamus tortor. Duis mattis egestas metus.\n\nAenean fermentum. Donec ut mauris eget massa tempor convallis. Nulla neque libero, convallis eget, eleifend luctus, ultricies eu, nibh.	t	\N
48	2025-02-16 14:57:59.008753+00	23	CGU	Invalid	asdas	f	{}
109	2025-01-23 04:39:34+00	23	kbarniss9@amazon.co.jp	Notified	Duis aliquam convallis nunc. Proin at turpis a pede posuere nonummy. Integer non velit.\n\nDonec diam neque, vestibulum eget, vulputate ut, ultrices vel, augue. Vestibulum ante ipsum primis in faucibus orci luctus et ultrices posuere cubilia Curae; Donec pharetra, magna vestibulum aliquet ultrices, erat tortor sollicitudin mi, sit amet lobortis sapien sapien non mi. Integer ac neque.	t	{a5c17d77-ef53-4b14-8e67-7863c54a66ad,dac14523-a80b-4f77-a560-d55b332f0f46}
14	2025-02-03 09:44:07.389235+00	23	admin	reviewed	Initial review completed	f	{a5c17d77-ef53-4b14-8e67-7863c54a66ad,dac14523-a80b-4f77-a560-d55b332f0f46}
16	2025-02-05 13:12:14.739542+00	25	Marzouq	select_action	test	t	{}
17	2025-02-05 13:12:48.690619+00	25	Marzouq	action1	testing	t	{}
18	2025-02-05 13:26:40.418197+00	25	Marzouq	select_action	testing	f	{afb58738-6353-4266-a0c1-24223adeed28}
19	2025-02-10 06:49:41.965321+00	23		action2	This is a test	t	{c88268c1-0ac3-41bb-89ff-1ee7162ff463}
20	2025-02-10 14:09:20.850339+00	20		Resolved	This is a closing update. thanks	f	{}
21	2025-02-10 14:12:16.981453+00	20		Invalid	Ooo lalala	f	{}
22	2025-02-10 14:12:36.634325+00	20		Investigation	oo lalala	f	{}
23	2025-02-10 14:12:58.444866+00	20		Investigation	asdasdassd	f	{}
24	2025-02-10 14:15:14.160373+00	20		Resolved	dasdadasa	f	{}
25	2025-02-10 14:15:19.467321+00	20		Investigation	asdassdadas	f	{}
26	2025-02-10 14:15:26.041278+00	20		Invalid	asdasdas	f	{}
27	2025-02-10 14:15:30.390381+00	20		Request for evidence	asdasdas	f	{}
28	2025-02-11 06:43:39.090734+00	22	3aa665b7-a4dd-40d8-b647-82e6ce3b3e16	evidence	asf	f	{6b5c91fa-2016-404b-be97-2498d8431ebf}
29	2025-02-11 06:47:33.444389+00	27	3aa665b7-a4dd-40d8-b647-82e6ce3b3e16	evidence	this is additional evidence	f	{b692f716-628d-48f5-a22f-73956bc7396f}
30	2025-02-11 06:47:54.247374+00	27	marzouq@marzex.tech	evidence	new evidence	f	{0a2c4470-be22-4ff6-89db-637ae215dc2d}
32	2025-02-11 07:08:31.046041+00	22	marzouq@marzex.tech	evidence	dasda	f	{1ef163c4-d86b-4fa9-9bf7-df310ae1f8f9}
34	2025-02-12 03:07:29.220116+00	22		Invalid	This complaint is not valid	f	{d2c231a3-56e7-42bf-ab28-2f83c9911a58}
35	2025-02-12 14:08:59.382899+00	22	CGU	Investigation	asdasd	f	{}
36	2025-02-12 14:11:36.214384+00	22	CGU	Review	this is a test	f	{}
37	2025-02-13 13:15:41.991574+00	23	CGU	Resolved	fasfas	f	{}
38	2025-02-13 14:19:17.154884+00	25	CGU	Resolved	asdsa	f	{}
39	2025-02-13 14:23:59.022765+00	25	CGU	Resolved	asdas	f	{}
40	2025-02-13 14:25:09.601851+00	25	CGU	Resolved	asdasd	t	{}
41	2025-02-13 14:25:31.439236+00	25	CGU	Resolved	asdas	f	{}
42	2025-02-13 14:26:06.499346+00	25	CGU	Resolved	asddas	f	{}
43	2025-02-16 14:11:03.681996+00	23	CGU	Invalid	asdas	f	{}
44	2025-02-16 14:11:37.208163+00	23	marzouq@marzex.tech	appeal	aasdasd	f	{}
45	2025-02-16 14:12:37.256607+00	23	marzouq@marzex.tech	appeal	asfdsad	f	{1e58ad66-d44e-44d5-9e4c-44637c0c4c4b}
46	2025-02-16 14:54:56.666064+00	23	CGU	Resolved		f	{}
47	2025-02-16 14:56:48.625775+00	23	marzouq@marzex.tech	appeal	asdd	f	{}
49	2025-02-16 14:58:29.290189+00	23	marzouq@marzex.tech	appealed	cssdf	f	{}
50	2025-02-16 14:59:12.276334+00	20	CGU	Resolved	aasd	f	{}
51	2025-02-16 15:04:26.533544+00	23	CGU	Resolved	asd	f	{}
52	2025-02-16 15:10:56.871107+00	23	marzouq@marzex.tech	closed	\N	f	\N
53	2025-02-16 15:13:42.055035+00	23	CGU	Invalid	asdasd	f	{}
54	2025-02-16 15:13:58.209048+00	23	marzouq@marzex.tech	closed	Satisfied with outcome.	f	\N
55	2025-02-16 15:23:44.538522+00	23	CGU	Invalid	asd	f	{}
56	2025-02-16 15:23:56.915096+00	23	marzouq@marzex.tech	closed	Satisfied with outcome.	f	\N
57	2025-02-16 15:33:03.327699+00	23	CGU	Invalid	sdfg	f	{}
58	2025-02-16 15:33:10.040986+00	23	marzouq@marzex.tech	appealed	sdfsfs	f	{}
59	2025-02-16 15:33:16.138237+00	23	marzouq@marzex.tech	closed	Satisfied with outcome.	f	\N
60	2025-02-16 15:33:25.200937+00	23	CGU	Invalid	asda	f	{}
61	2025-02-16 15:34:52.433122+00	23	marzouq@marzex.tech	closed	Satisfied with outcome.	f	\N
62	2025-02-17 03:33:06.998758+00	20	marzouq@marzex.tech	closed	Satisfied with outcome.	f	\N
63	2025-02-17 03:33:23.370805+00	26	marzouq@marzex.tech	evidence	test	f	{3e7ffe0e-601d-4fa8-bc80-ec1e4feaff72}
64	2025-02-17 03:34:59.859913+00	26	CGU	Resolved	This is just for the user	f	{}
65	2025-02-17 03:38:37.801236+00	25	CGU	Resolved	this is for the user's eyes only	f	{1b71c69e-30f0-4c84-9c5b-0a2f660956fa}
66	2025-02-17 03:39:53.495417+00	26	marzouq@marzex.tech	closed	Satisfied with outcome.	f	\N
\.


--
-- Data for Name: complaints; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public.complaints (complaint_id, created_at, support_needed, confidentiality, type, description, status, documents, complainant, last_action, other_type, accused, accused_is_org) FROM stdin;
21	2025-01-19 14:48:24.228484+00	["Communication with female staff"]	t	Logo misuse	dfs	submitted	{2dfee0f7-0ca4-4c70-b49c-8379f301b4c2,0e5097ba-0154-4a76-b55d-73ef0c6d0b1b}	3aa665b7-a4dd-40d8-b647-82e6ce3b3e16	\N	\N	test org	t
27	2025-01-23 07:13:52.625719+00	["Translation and interpretation","Communication with female staff"]	t	Non-compliance to MSPO Certification Scheme Document: Chain of Custody of Oil Palm	sdfsdf	submitted	{b2be8e80-d51e-449f-9e65-15c38176cc7b}	3aa665b7-a4dd-40d8-b647-82e6ce3b3e16	\N	\N	fs	t
20	2025-01-19 14:48:07.345436+00	["Communication with female staff"]	t	Logo misuse	ads	closed	{a5c17d77-ef53-4b14-8e67-7863c54a66ad,dac14523-a80b-4f77-a560-d55b332f0f46}	3aa665b7-a4dd-40d8-b647-82e6ce3b3e16	62	\N	test org	t
25	2025-01-23 05:33:46.83043+00	["Communication with female staff"]	t	Non-compliance to MSPO Certification Scheme Document	He's making me work too much	resolved	{2d9ba0f3-7887-4d21-adcd-2cbc31c6e18a}	f17d8111-cccf-4b85-afa7-ed9ad199e0ea	65	\N	Me	f
26	2025-01-23 07:09:25.963717+00	["Translation and interpretation"]	t	Non-compliance to MSPO Certification Scheme Document	Testing	closed	{}	3aa665b7-a4dd-40d8-b647-82e6ce3b3e16	66	\N	felpa	f
22	2025-01-21 12:53:56.890895+00	["Communication with female staff"]	f	Non-compliance to new planting and establishment guidelines	They palaud me :(	under review	{7bc59806-9caa-4ff1-a6cd-7f4e2cf9b176}	3aa665b7-a4dd-40d8-b647-82e6ce3b3e16	36	\N	felpa	f
23	2025-01-23 04:33:05.932322+00	["Translation and interpretation"]	f	Non-compliance to MSPO Certification Scheme Document: Chain of Custody of Oil Palm	Lorem Ipsum is simply dummy text of the printing and typesetting industry. Lorem Ipsum has been the industry's standard dummy text ever since the 1500s, when an unknown printer took a galley of type and scrambled it to make a type specimen book. It has survived not only five centuries, but also the leap into electronic typesetting, remaining essentially unchanged. It was popularised in the 1960s with the release of Letraset sheets containing Lorem Ipsum passages, and more recently with desktop publishing software like Aldus PageMaker including versions of Lorem Ipsum.	closed	{bc2befb3-39b3-49f7-b492-1ade1499bf10,a5c17d77-ef53-4b14-8e67-7863c54a66ad,dac14523-a80b-4f77-a560-d55b332f0f46}	3aa665b7-a4dd-40d8-b647-82e6ce3b3e16	61	\N	Dietz	t
28	2025-02-16 16:36:47.284096+00	["Communication with female staff","Translation and interpretation"]	t	Non-compliance to MSPO Certification Scheme Document: Chain of Custody of Oil Palm	sdfds	submitted	{}	3aa665b7-a4dd-40d8-b647-82e6ce3b3e16	\N	\N	sdfsd	f
29	2025-02-16 16:45:17.100114+00	["Communication with female staff","Translation and interpretation"]	t	Non-compliance to SIA Guidelines & approach	dsad	submitted	{}	3aa665b7-a4dd-40d8-b647-82e6ce3b3e16	\N	\N	test org	f
\.


--
-- Data for Name: summary; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public.summary (id, created_at, hide, accused, complaint_id, complaint_date, summary) FROM stdin;
5	2025-02-16 14:54:56.681796+00	f	Dietz	23	2025-01-23	asd
6	2025-02-16 14:59:12.333135+00	f	test org	20	2025-01-19	asfdc
4	2025-02-13 14:26:06.511955+00	f	Me	25	2025-01-23	Lorem Ipsum is simply dummy text of the printing and typesetting industry. Lorem Ipsum has been the industry's standard dummy text ever since the 1500s, when an unknown printer took a galley of type and scrambled it to make a type specimen book. It has survived not only five centuries, but also the leap isadsadfanto electronic typesetting, remaining essentially unchanged. It was popularised in the 1960s with the release of Letraset sheets containing Lorem Ipsum passages, and more recently with desktop publishing software like Aldus PageMaker including versions of Lorem Ipsum.
8	2025-02-17 03:34:59.878113+00	f	felpa	26	2025-01-23	This is a public summary. this can be edited
\.


--
-- Data for Name: user; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public."user" (id, created_at, user_id, organization, phone, address, postcode, state, country, name) FROM stdin;
2	2025-01-19 06:50:37.270222+00	3aa665b7-a4dd-40d8-b647-82e6ce3b3e16		0199899379	A-15-6, Riana Green East Condo	53300	Kuala Lumpur	Malaysia	\N
3	2025-01-23 05:32:06.53527+00	f17d8111-cccf-4b85-afa7-ed9ad199e0ea		0199899379	A-15-6, Riana Green East Condo	53300	KL	Malaysia	\N
\.


--
-- Data for Name: schema_migrations; Type: TABLE DATA; Schema: realtime; Owner: supabase_admin
--

COPY realtime.schema_migrations (version, inserted_at) FROM stdin;
20211116024918	2025-01-19 04:53:02
20211116045059	2025-01-19 04:53:02
20211116050929	2025-01-19 04:53:02
20211116051442	2025-01-19 04:53:02
20211116212300	2025-01-19 04:53:02
20211116213355	2025-01-19 04:53:02
20211116213934	2025-01-19 04:53:02
20211116214523	2025-01-19 04:53:02
20211122062447	2025-01-19 04:53:02
20211124070109	2025-01-19 04:53:02
20211202204204	2025-01-19 04:53:02
20211202204605	2025-01-19 04:53:02
20211210212804	2025-01-19 04:53:02
20211228014915	2025-01-19 04:53:02
20220107221237	2025-01-19 04:53:02
20220228202821	2025-01-19 04:53:02
20220312004840	2025-01-19 04:53:02
20220603231003	2025-01-19 04:53:02
20220603232444	2025-01-19 04:53:02
20220615214548	2025-01-19 04:53:02
20220712093339	2025-01-19 04:53:02
20220908172859	2025-01-19 04:53:02
20220916233421	2025-01-19 04:53:02
20230119133233	2025-01-19 04:53:02
20230128025114	2025-01-19 04:53:02
20230128025212	2025-01-19 04:53:02
20230227211149	2025-01-19 04:53:02
20230228184745	2025-01-19 04:53:02
20230308225145	2025-01-19 04:53:02
20230328144023	2025-01-19 04:53:02
20231018144023	2025-01-19 04:53:02
20231204144023	2025-01-19 04:53:02
20231204144024	2025-01-19 04:53:02
20231204144025	2025-01-19 04:53:02
20240108234812	2025-01-19 04:53:02
20240109165339	2025-01-19 04:53:02
20240227174441	2025-01-19 04:53:02
20240311171622	2025-01-19 04:53:02
20240321100241	2025-01-19 04:53:02
20240401105812	2025-01-19 04:53:02
20240418121054	2025-01-19 04:53:02
20240523004032	2025-01-19 04:53:02
20240618124746	2025-01-19 04:53:02
20240801235015	2025-01-19 04:53:02
20240805133720	2025-01-19 04:53:02
20240827160934	2025-01-19 04:53:02
20240919163303	2025-01-19 04:53:02
20240919163305	2025-01-19 04:53:02
20241019105805	2025-01-19 04:53:02
20241030150047	2025-01-19 04:53:02
20241108114728	2025-01-19 04:53:02
20241121104152	2025-01-19 04:53:02
20241130184212	2025-01-19 04:53:02
\.


--
-- Data for Name: subscription; Type: TABLE DATA; Schema: realtime; Owner: supabase_admin
--

COPY realtime.subscription (id, subscription_id, entity, filters, claims, created_at) FROM stdin;
\.


--
-- Data for Name: buckets; Type: TABLE DATA; Schema: storage; Owner: supabase_storage_admin
--

COPY storage.buckets (id, name, owner, created_at, updated_at, public, avif_autodetection, file_size_limit, allowed_mime_types, owner_id) FROM stdin;
complaints_documents	complaints_documents	\N	2025-01-19 11:28:26.679688+00	2025-01-19 11:28:26.679688+00	f	f	\N	\N	\N
\.


--
-- Data for Name: migrations; Type: TABLE DATA; Schema: storage; Owner: supabase_storage_admin
--

COPY storage.migrations (id, name, hash, executed_at) FROM stdin;
0	create-migrations-table	e18db593bcde2aca2a408c4d1100f6abba2195df	2025-01-19 04:53:05.879354
1	initialmigration	6ab16121fbaa08bbd11b712d05f358f9b555d777	2025-01-19 04:53:05.882603
2	storage-schema	5c7968fd083fcea04050c1b7f6253c9771b99011	2025-01-19 04:53:05.884577
3	pathtoken-column	2cb1b0004b817b29d5b0a971af16bafeede4b70d	2025-01-19 04:53:05.890548
4	add-migrations-rls	427c5b63fe1c5937495d9c635c263ee7a5905058	2025-01-19 04:53:05.906705
5	add-size-functions	79e081a1455b63666c1294a440f8ad4b1e6a7f84	2025-01-19 04:53:05.908579
6	change-column-name-in-get-size	f93f62afdf6613ee5e7e815b30d02dc990201044	2025-01-19 04:53:05.910518
7	add-rls-to-buckets	e7e7f86adbc51049f341dfe8d30256c1abca17aa	2025-01-19 04:53:05.912569
8	add-public-to-buckets	fd670db39ed65f9d08b01db09d6202503ca2bab3	2025-01-19 04:53:05.914571
9	fix-search-function	3a0af29f42e35a4d101c259ed955b67e1bee6825	2025-01-19 04:53:05.916474
10	search-files-search-function	68dc14822daad0ffac3746a502234f486182ef6e	2025-01-19 04:53:05.918133
11	add-trigger-to-auto-update-updated_at-column	7425bdb14366d1739fa8a18c83100636d74dcaa2	2025-01-19 04:53:05.920582
12	add-automatic-avif-detection-flag	8e92e1266eb29518b6a4c5313ab8f29dd0d08df9	2025-01-19 04:53:05.922656
13	add-bucket-custom-limits	cce962054138135cd9a8c4bcd531598684b25e7d	2025-01-19 04:53:05.924581
14	use-bytes-for-max-size	941c41b346f9802b411f06f30e972ad4744dad27	2025-01-19 04:53:05.926496
15	add-can-insert-object-function	934146bc38ead475f4ef4b555c524ee5d66799e5	2025-01-19 04:53:05.94068
16	add-version	76debf38d3fd07dcfc747ca49096457d95b1221b	2025-01-19 04:53:05.942525
17	drop-owner-foreign-key	f1cbb288f1b7a4c1eb8c38504b80ae2a0153d101	2025-01-19 04:53:05.944555
18	add_owner_id_column_deprecate_owner	e7a511b379110b08e2f214be852c35414749fe66	2025-01-19 04:53:05.94649
19	alter-default-value-objects-id	02e5e22a78626187e00d173dc45f58fa66a4f043	2025-01-19 04:53:05.948598
20	list-objects-with-delimiter	cd694ae708e51ba82bf012bba00caf4f3b6393b7	2025-01-19 04:53:05.950539
21	s3-multipart-uploads	8c804d4a566c40cd1e4cc5b3725a664a9303657f	2025-01-19 04:53:05.956488
22	s3-multipart-uploads-big-ints	9737dc258d2397953c9953d9b86920b8be0cdb73	2025-01-19 04:53:05.974538
23	optimize-search-function	9d7e604cddc4b56a5422dc68c9313f4a1b6f132c	2025-01-19 04:53:05.996513
24	operation-function	8312e37c2bf9e76bbe841aa5fda889206d2bf8aa	2025-01-19 04:53:05.998532
25	custom-metadata	67eb93b7e8d401cafcdc97f9ac779e71a79bfe03	2025-01-19 04:53:06.000573
\.


--
-- Data for Name: objects; Type: TABLE DATA; Schema: storage; Owner: supabase_storage_admin
--

COPY storage.objects (id, bucket_id, name, owner, created_at, updated_at, last_accessed_at, metadata, version, owner_id, user_metadata) FROM stdin;
a5c17d77-ef53-4b14-8e67-7863c54a66ad	complaints_documents	3aa665b7-a4dd-40d8-b647-82e6ce3b3e16/1737298087314_Screenshot from 2025-01-19 14-24-39.png	3aa665b7-a4dd-40d8-b647-82e6ce3b3e16	2025-01-19 14:48:07.322564+00	2025-01-19 14:48:07.322564+00	2025-01-19 14:48:07.322564+00	{"eTag": "\\"8e5f57f96122f45f3b93f983a23cb248\\"", "size": 79045, "mimetype": "image/png", "cacheControl": "max-age=3600", "lastModified": "2025-01-19T14:48:07.320Z", "contentLength": 79045, "httpStatusCode": 200}	74e1e193-596f-439b-a68e-51077122b17e	3aa665b7-a4dd-40d8-b647-82e6ce3b3e16	{}
dac14523-a80b-4f77-a560-d55b332f0f46	complaints_documents	3aa665b7-a4dd-40d8-b647-82e6ce3b3e16/1737298087328_Screenshot from 2025-01-19 18-49-37.png	3aa665b7-a4dd-40d8-b647-82e6ce3b3e16	2025-01-19 14:48:07.335715+00	2025-01-19 14:48:07.335715+00	2025-01-19 14:48:07.335715+00	{"eTag": "\\"68c94c68ae78cb8b4d5275a8c7b21c3c\\"", "size": 61305, "mimetype": "image/png", "cacheControl": "max-age=3600", "lastModified": "2025-01-19T14:48:07.333Z", "contentLength": 61305, "httpStatusCode": 200}	5365621d-d7fe-4e71-807b-8357755faabb	3aa665b7-a4dd-40d8-b647-82e6ce3b3e16	{}
2dfee0f7-0ca4-4c70-b49c-8379f301b4c2	complaints_documents	3aa665b7-a4dd-40d8-b647-82e6ce3b3e16/1737298104200_Template154.webp	3aa665b7-a4dd-40d8-b647-82e6ce3b3e16	2025-01-19 14:48:24.208356+00	2025-01-19 14:48:24.208356+00	2025-01-19 14:48:24.208356+00	{"eTag": "\\"7f91a35d82855d0ead9ecb1ec2a51181\\"", "size": 84944, "mimetype": "image/webp", "cacheControl": "max-age=3600", "lastModified": "2025-01-19T14:48:24.206Z", "contentLength": 84944, "httpStatusCode": 200}	7698a435-d1ad-4d73-acbf-ae4f44ce124d	3aa665b7-a4dd-40d8-b647-82e6ce3b3e16	{}
0e5097ba-0154-4a76-b55d-73ef0c6d0b1b	complaints_documents	3aa665b7-a4dd-40d8-b647-82e6ce3b3e16/1737298104214_Screenshot from 2025-01-19 14-24-39.png	3aa665b7-a4dd-40d8-b647-82e6ce3b3e16	2025-01-19 14:48:24.220563+00	2025-01-19 14:48:24.220563+00	2025-01-19 14:48:24.220563+00	{"eTag": "\\"8e5f57f96122f45f3b93f983a23cb248\\"", "size": 79045, "mimetype": "image/png", "cacheControl": "max-age=3600", "lastModified": "2025-01-19T14:48:24.218Z", "contentLength": 79045, "httpStatusCode": 200}	f0e45806-e330-404f-a25f-4f4db9d5d1ea	3aa665b7-a4dd-40d8-b647-82e6ce3b3e16	{}
b2be8e80-d51e-449f-9e65-15c38176cc7b	complaints_documents	3aa665b7-a4dd-40d8-b647-82e6ce3b3e16/1737616432595_dac14523-a80b-4f77-a560-d55b332f0f46.png	3aa665b7-a4dd-40d8-b647-82e6ce3b3e16	2025-01-23 07:13:52.610892+00	2025-01-23 07:13:52.610892+00	2025-01-23 07:13:52.610892+00	{"eTag": "\\"68c94c68ae78cb8b4d5275a8c7b21c3c\\"", "size": 61305, "mimetype": "image/png", "cacheControl": "max-age=3600", "lastModified": "2025-01-23T07:13:52.609Z", "contentLength": 61305, "httpStatusCode": 200}	1e3a3ac7-3244-4c7d-93fc-5fb61247af5d	3aa665b7-a4dd-40d8-b647-82e6ce3b3e16	{}
63d52d44-5bcc-4f37-a73d-de8006796fc2	complaints_documents	3aa665b7-a4dd-40d8-b647-82e6ce3b3e16/1738759791717_undefined	\N	2025-02-05 12:49:51.742168+00	2025-02-05 12:49:51.742168+00	2025-02-05 12:49:51.742168+00	{"eTag": "\\"1441a7909c087dbbe7ce59881b9df8b9\\"", "size": 15, "mimetype": "text/plain;charset=UTF-8", "cacheControl": "max-age=3600", "lastModified": "2025-02-05T12:49:51.740Z", "contentLength": 15, "httpStatusCode": 200}	ed8a14e9-b55a-4455-b089-ce4591ff0104	\N	{}
3b272c36-8f91-4c0f-b72a-eca6060c0864	complaints_documents	3aa665b7-a4dd-40d8-b647-82e6ce3b3e16/1738759791748_undefined	\N	2025-02-05 12:49:51.754337+00	2025-02-05 12:49:51.754337+00	2025-02-05 12:49:51.754337+00	{"eTag": "\\"1441a7909c087dbbe7ce59881b9df8b9\\"", "size": 15, "mimetype": "text/plain;charset=UTF-8", "cacheControl": "max-age=3600", "lastModified": "2025-02-05T12:49:51.752Z", "contentLength": 15, "httpStatusCode": 200}	2d030840-dedf-4a28-87d7-be6a3c757ec4	\N	{}
94daccf8-f1e6-4932-a389-991cf9e23544	complaints_documents	f17d8111-cccf-4b85-afa7-ed9ad199e0ea/1738761013133_pose.png	\N	2025-02-05 13:10:13.203524+00	2025-02-05 13:10:13.203524+00	2025-02-05 13:10:13.203524+00	{"eTag": "\\"0a39406816cfa4c60104fd517a420f84\\"", "size": 5481544, "mimetype": "text/plain;charset=UTF-8", "cacheControl": "max-age=3600", "lastModified": "2025-02-05T13:10:13.182Z", "contentLength": 5481544, "httpStatusCode": 200}	f93bc7e5-dee2-4fd7-84a7-7ee2b905ca94	\N	{}
7bc59806-9caa-4ff1-a6cd-7f4e2cf9b176	complaints_documents	3aa665b7-a4dd-40d8-b647-82e6ce3b3e16/1737464036834_NDA - Marzouq .pdf	3aa665b7-a4dd-40d8-b647-82e6ce3b3e16	2025-01-21 12:53:56.872207+00	2025-01-21 12:53:56.872207+00	2025-01-21 12:53:56.872207+00	{"eTag": "\\"ec1533a9f1b8e10dd576715234ca4cb4\\"", "size": 657093, "mimetype": "application/pdf", "cacheControl": "max-age=3600", "lastModified": "2025-01-21T12:53:56.865Z", "contentLength": 657093, "httpStatusCode": 200}	097e8072-2a01-4aa6-b5c8-ff359f9b7aa5	3aa665b7-a4dd-40d8-b647-82e6ce3b3e16	{}
e975b76d-bb94-49ac-9309-5ef02735a0f8	complaints_documents	3aa665b7-a4dd-40d8-b647-82e6ce3b3e16/.emptyFolderPlaceholder	\N	2025-01-19 14:03:12.503359+00	2025-01-19 14:03:12.503359+00	2025-01-19 14:03:12.503359+00	{"eTag": "\\"d41d8cd98f00b204e9800998ecf8427e\\"", "size": 0, "mimetype": "application/octet-stream", "cacheControl": "max-age=3600", "lastModified": "2025-01-19T14:03:12.501Z", "contentLength": 0, "httpStatusCode": 200}	a5eedb84-c282-47a8-aa0c-805e603193ff	\N	{}
bc2befb3-39b3-49f7-b492-1ade1499bf10	complaints_documents	3aa665b7-a4dd-40d8-b647-82e6ce3b3e16/1737606785896_Freelance Agreement_Marzouq Abedur Rahman_signed bySM.pdf	3aa665b7-a4dd-40d8-b647-82e6ce3b3e16	2025-01-23 04:33:05.916129+00	2025-01-23 04:33:05.916129+00	2025-01-23 04:33:05.916129+00	{"eTag": "\\"1a6fccb1ae163f7230771eb628df455a\\"", "size": 838729, "mimetype": "application/pdf", "cacheControl": "max-age=3600", "lastModified": "2025-01-23T04:33:05.909Z", "contentLength": 838729, "httpStatusCode": 200}	8f6917f3-f834-4ce8-9bf3-1023e9258c83	3aa665b7-a4dd-40d8-b647-82e6ce3b3e16	{}
9bb1ec95-8f70-4b5d-ad79-c2f5e8357bc4	complaints_documents	3aa665b7-a4dd-40d8-b647-82e6ce3b3e16/1737297018646_Screenshot from 2025-01-19 14-24-39.png	3aa665b7-a4dd-40d8-b647-82e6ce3b3e16	2025-01-19 14:30:18.661511+00	2025-01-19 14:30:18.661511+00	2025-01-19 14:30:18.661511+00	{"eTag": "\\"8e5f57f96122f45f3b93f983a23cb248\\"", "size": 79045, "mimetype": "image/png", "cacheControl": "max-age=3600", "lastModified": "2025-01-19T14:30:18.659Z", "contentLength": 79045, "httpStatusCode": 200}	8f4c8f96-6203-4703-8831-c97afce588ae	3aa665b7-a4dd-40d8-b647-82e6ce3b3e16	{}
a4bbebe0-0ccb-4814-b591-953f3774296c	complaints_documents	3aa665b7-a4dd-40d8-b647-82e6ce3b3e16/1737297547211_USER MANUAL COMPLAINT MODULE ( USERS LOGIN) Ver July 2022-Updated 15072022.pdf	3aa665b7-a4dd-40d8-b647-82e6ce3b3e16	2025-01-19 14:39:07.240436+00	2025-01-19 14:39:07.240436+00	2025-01-19 14:39:07.240436+00	{"eTag": "\\"6d36cdbf1d72c2a065317b0f10c7ce4c\\"", "size": 2085740, "mimetype": "application/pdf", "cacheControl": "max-age=3600", "lastModified": "2025-01-19T14:39:07.232Z", "contentLength": 2085740, "httpStatusCode": 200}	33a73d92-c649-4fd6-923c-d3b827103bcf	3aa665b7-a4dd-40d8-b647-82e6ce3b3e16	{}
6d4094fe-c4a5-41c5-a068-f670971497a9	complaints_documents	3aa665b7-a4dd-40d8-b647-82e6ce3b3e16/1737297978546_Template154.webp	3aa665b7-a4dd-40d8-b647-82e6ce3b3e16	2025-01-19 14:46:18.561022+00	2025-01-19 14:46:18.561022+00	2025-01-19 14:46:18.561022+00	{"eTag": "\\"7f91a35d82855d0ead9ecb1ec2a51181\\"", "size": 84944, "mimetype": "image/webp", "cacheControl": "max-age=3600", "lastModified": "2025-01-19T14:46:18.559Z", "contentLength": 84944, "httpStatusCode": 200}	a94d4419-5e73-4c3b-870b-ae56e615c44c	3aa665b7-a4dd-40d8-b647-82e6ce3b3e16	{}
df86f9b6-e18e-40fb-b0b4-e5c269038b74	complaints_documents	3aa665b7-a4dd-40d8-b647-82e6ce3b3e16/1737297978568_Screenshot from 2025-01-19 14-24-39.png	3aa665b7-a4dd-40d8-b647-82e6ce3b3e16	2025-01-19 14:46:18.574505+00	2025-01-19 14:46:18.574505+00	2025-01-19 14:46:18.574505+00	{"eTag": "\\"8e5f57f96122f45f3b93f983a23cb248\\"", "size": 79045, "mimetype": "image/png", "cacheControl": "max-age=3600", "lastModified": "2025-01-19T14:46:18.573Z", "contentLength": 79045, "httpStatusCode": 200}	ee31b1e5-32b8-4307-b40e-661aadccf921	3aa665b7-a4dd-40d8-b647-82e6ce3b3e16	{}
37c22151-13bb-445f-ba81-a53fa6cfc3a9	complaints_documents	3aa665b7-a4dd-40d8-b647-82e6ce3b3e16/1737297988585_Screenshot from 2025-01-19 14-24-39.png	3aa665b7-a4dd-40d8-b647-82e6ce3b3e16	2025-01-19 14:46:28.595467+00	2025-01-19 14:46:28.595467+00	2025-01-19 14:46:28.595467+00	{"eTag": "\\"8e5f57f96122f45f3b93f983a23cb248\\"", "size": 79045, "mimetype": "image/png", "cacheControl": "max-age=3600", "lastModified": "2025-01-19T14:46:28.593Z", "contentLength": 79045, "httpStatusCode": 200}	6b307b79-9b94-4105-9026-4fc391556c13	3aa665b7-a4dd-40d8-b647-82e6ce3b3e16	{}
8da79587-b26a-4ca4-9603-8999f6090dcb	complaints_documents	3aa665b7-a4dd-40d8-b647-82e6ce3b3e16/1737297992101_Screenshot from 2025-01-19 14-24-39.png	3aa665b7-a4dd-40d8-b647-82e6ce3b3e16	2025-01-19 14:46:32.110101+00	2025-01-19 14:46:32.110101+00	2025-01-19 14:46:32.110101+00	{"eTag": "\\"8e5f57f96122f45f3b93f983a23cb248\\"", "size": 79045, "mimetype": "image/png", "cacheControl": "max-age=3600", "lastModified": "2025-01-19T14:46:32.108Z", "contentLength": 79045, "httpStatusCode": 200}	f4d674f2-d5f8-485d-b0fd-7e81c4aeee24	3aa665b7-a4dd-40d8-b647-82e6ce3b3e16	{}
3158d73f-73cc-4723-8997-23bb0584e554	complaints_documents	3aa665b7-a4dd-40d8-b647-82e6ce3b3e16/1737297992123_USER MANUAL COMPLAINT MODULE ( USERS LOGIN) Ver July 2022-Updated 15072022.pdf	3aa665b7-a4dd-40d8-b647-82e6ce3b3e16	2025-01-19 14:46:32.144188+00	2025-01-19 14:46:32.144188+00	2025-01-19 14:46:32.144188+00	{"eTag": "\\"6d36cdbf1d72c2a065317b0f10c7ce4c\\"", "size": 2085740, "mimetype": "application/pdf", "cacheControl": "max-age=3600", "lastModified": "2025-01-19T14:46:32.137Z", "contentLength": 2085740, "httpStatusCode": 200}	d6f90006-489c-4a31-99ff-cdedd7b61f27	3aa665b7-a4dd-40d8-b647-82e6ce3b3e16	{}
a8d04a3a-d186-4158-a0fa-93352f524bd7	complaints_documents	3aa665b7-a4dd-40d8-b647-82e6ce3b3e16/1737297994072_USER MANUAL COMPLAINT MODULE ( USERS LOGIN) Ver July 2022-Updated 15072022.pdf	3aa665b7-a4dd-40d8-b647-82e6ce3b3e16	2025-01-19 14:46:34.094048+00	2025-01-19 14:46:34.094048+00	2025-01-19 14:46:34.094048+00	{"eTag": "\\"6d36cdbf1d72c2a065317b0f10c7ce4c\\"", "size": 2085740, "mimetype": "application/pdf", "cacheControl": "max-age=3600", "lastModified": "2025-01-19T14:46:34.087Z", "contentLength": 2085740, "httpStatusCode": 200}	dd3c7ac3-6848-4947-82d4-cf35a1fc0858	3aa665b7-a4dd-40d8-b647-82e6ce3b3e16	{}
5e862638-824c-4f9a-a5c8-623e402bfa79	complaints_documents	3aa665b7-a4dd-40d8-b647-82e6ce3b3e16/1737298042428_Template154.webp	3aa665b7-a4dd-40d8-b647-82e6ce3b3e16	2025-01-19 14:47:22.43712+00	2025-01-19 14:47:22.43712+00	2025-01-19 14:47:22.43712+00	{"eTag": "\\"7f91a35d82855d0ead9ecb1ec2a51181\\"", "size": 84944, "mimetype": "image/webp", "cacheControl": "max-age=3600", "lastModified": "2025-01-19T14:47:22.435Z", "contentLength": 84944, "httpStatusCode": 200}	103404ec-0822-4dbe-b04f-4e440e29f06d	3aa665b7-a4dd-40d8-b647-82e6ce3b3e16	{}
512bf7f6-cb8b-4093-99fe-6cb703ccf99d	complaints_documents	3aa665b7-a4dd-40d8-b647-82e6ce3b3e16/1737298042455_Screenshot from 2025-01-19 14-24-39.png	3aa665b7-a4dd-40d8-b647-82e6ce3b3e16	2025-01-19 14:47:22.464112+00	2025-01-19 14:47:22.464112+00	2025-01-19 14:47:22.464112+00	{"eTag": "\\"8e5f57f96122f45f3b93f983a23cb248\\"", "size": 79045, "mimetype": "image/png", "cacheControl": "max-age=3600", "lastModified": "2025-01-19T14:47:22.462Z", "contentLength": 79045, "httpStatusCode": 200}	95260ac6-6da7-4ce3-9a15-273d95aea880	3aa665b7-a4dd-40d8-b647-82e6ce3b3e16	{}
2d9ba0f3-7887-4d21-adcd-2cbc31c6e18a	complaints_documents	f17d8111-cccf-4b85-afa7-ed9ad199e0ea/1737610426799_MOCK_DATA.csv	f17d8111-cccf-4b85-afa7-ed9ad199e0ea	2025-01-23 05:33:46.814891+00	2025-01-23 05:33:46.814891+00	2025-01-23 05:33:46.814891+00	{"eTag": "\\"372ed6536fe8bbbb10e655319b302113\\"", "size": 3544, "mimetype": "text/csv", "cacheControl": "max-age=3600", "lastModified": "2025-01-23T05:33:46.813Z", "contentLength": 3544, "httpStatusCode": 200}	36420034-8826-46c7-b24f-78d31af5d824	f17d8111-cccf-4b85-afa7-ed9ad199e0ea	{}
0b295e71-0fda-4fd5-9357-6d235976247d	complaints_documents	3aa665b7-a4dd-40d8-b647-82e6ce3b3e16/1737298057812_Template154.webp	3aa665b7-a4dd-40d8-b647-82e6ce3b3e16	2025-01-19 14:47:37.820264+00	2025-01-19 14:47:37.820264+00	2025-01-19 14:47:37.820264+00	{"eTag": "\\"7f91a35d82855d0ead9ecb1ec2a51181\\"", "size": 84944, "mimetype": "image/webp", "cacheControl": "max-age=3600", "lastModified": "2025-01-19T14:47:37.818Z", "contentLength": 84944, "httpStatusCode": 200}	3494b4b2-097f-4763-887e-c34057d1f001	3aa665b7-a4dd-40d8-b647-82e6ce3b3e16	{}
ea0a53d3-1255-46d6-8fba-5ff74378ad82	complaints_documents	3aa665b7-a4dd-40d8-b647-82e6ce3b3e16/1737298057830_Screenshot from 2025-01-19 14-24-39.png	3aa665b7-a4dd-40d8-b647-82e6ce3b3e16	2025-01-19 14:47:37.837987+00	2025-01-19 14:47:37.837987+00	2025-01-19 14:47:37.837987+00	{"eTag": "\\"8e5f57f96122f45f3b93f983a23cb248\\"", "size": 79045, "mimetype": "image/png", "cacheControl": "max-age=3600", "lastModified": "2025-01-19T14:47:37.836Z", "contentLength": 79045, "httpStatusCode": 200}	102e22f9-abe0-46e4-b5ec-b077f5eabd2a	3aa665b7-a4dd-40d8-b647-82e6ce3b3e16	{}
bd42ffde-2368-4adb-899d-e2f0bc7c7d80	complaints_documents	3aa665b7-a4dd-40d8-b647-82e6ce3b3e16/1738760136456_Jan.jpg	\N	2025-02-05 12:55:36.489552+00	2025-02-05 12:55:36.489552+00	2025-02-05 12:55:36.489552+00	{"eTag": "\\"ba85e096fd530df668004657bd64e44c\\"", "size": 10140, "mimetype": "text/plain;charset=UTF-8", "cacheControl": "max-age=3600", "lastModified": "2025-02-05T12:55:36.488Z", "contentLength": 10140, "httpStatusCode": 200}	a06007c9-b53a-411c-b4e7-584ee70bd884	\N	{}
3cf274d1-58f9-4016-8393-326e83805aac	complaints_documents	3aa665b7-a4dd-40d8-b647-82e6ce3b3e16/1738760136497_LOI draft - Dr. Affendy.docx	\N	2025-02-05 12:55:36.507903+00	2025-02-05 12:55:36.507903+00	2025-02-05 12:55:36.507903+00	{"eTag": "\\"b1cfa7c4a368d2ef6eb88b7921b11681\\"", "size": 17200, "mimetype": "text/plain;charset=UTF-8", "cacheControl": "max-age=3600", "lastModified": "2025-02-05T12:55:36.505Z", "contentLength": 17200, "httpStatusCode": 200}	92dfffcc-7d12-462a-a394-f2a404297aed	\N	{}
578e5ddd-65fd-42a6-b4fe-c3e267d2b060	complaints_documents	f17d8111-cccf-4b85-afa7-ed9ad199e0ea/1738761077538_pose.png	\N	2025-02-05 13:11:17.610386+00	2025-02-05 13:11:17.610386+00	2025-02-05 13:11:17.610386+00	{"eTag": "\\"0a39406816cfa4c60104fd517a420f84\\"", "size": 5481544, "mimetype": "text/plain;charset=UTF-8", "cacheControl": "max-age=3600", "lastModified": "2025-02-05T13:11:17.591Z", "contentLength": 5481544, "httpStatusCode": 200}	b01b427e-2737-4ea2-afde-d1ec45041783	\N	{}
751e8daf-a411-4a62-a0a0-f23792048548	complaints_documents	f17d8111-cccf-4b85-afa7-ed9ad199e0ea/1738761095435_different_scenes.png	\N	2025-02-05 13:11:35.515917+00	2025-02-05 13:11:35.515917+00	2025-02-05 13:11:35.515917+00	{"eTag": "\\"512ac624b4c31dc685955dc77fbf1e62\\"", "size": 8213569, "mimetype": "text/plain;charset=UTF-8", "cacheControl": "max-age=3600", "lastModified": "2025-02-05T13:11:35.493Z", "contentLength": 8213569, "httpStatusCode": 200}	809addc4-cdb1-4448-9533-58e580262601	\N	{}
eb5078fe-574e-4e41-8560-49aa59fd8e92	complaints_documents	f17d8111-cccf-4b85-afa7-ed9ad199e0ea/1738761181556_Jan.jpg	\N	2025-02-05 13:13:01.582488+00	2025-02-05 13:13:01.582488+00	2025-02-05 13:13:01.582488+00	{"eTag": "\\"ba85e096fd530df668004657bd64e44c\\"", "size": 10140, "mimetype": "text/plain;charset=UTF-8", "cacheControl": "max-age=3600", "lastModified": "2025-02-05T13:13:01.580Z", "contentLength": 10140, "httpStatusCode": 200}	0a895c42-92b3-4cbb-82c8-64a0d4f14678	\N	{}
1334d5f5-1513-4d0f-8462-8e3bc0b2bed3	complaints_documents	f17d8111-cccf-4b85-afa7-ed9ad199e0ea/1738761199614_pose.png	\N	2025-02-05 13:13:19.675582+00	2025-02-05 13:13:19.675582+00	2025-02-05 13:13:19.675582+00	{"eTag": "\\"0a39406816cfa4c60104fd517a420f84\\"", "size": 5481544, "mimetype": "text/plain;charset=UTF-8", "cacheControl": "max-age=3600", "lastModified": "2025-02-05T13:13:19.657Z", "contentLength": 5481544, "httpStatusCode": 200}	a36ade9c-288d-4eaf-838b-fbf04858d337	\N	{}
2b6e620d-4fe5-4848-8a57-3430a07248da	complaints_documents	f17d8111-cccf-4b85-afa7-ed9ad199e0ea/1738761871745_different_scenes.png	\N	2025-02-05 13:24:31.831886+00	2025-02-05 13:24:31.831886+00	2025-02-05 13:24:31.831886+00	{"eTag": "\\"512ac624b4c31dc685955dc77fbf1e62\\"", "size": 8213569, "mimetype": "text/plain;charset=UTF-8", "cacheControl": "max-age=3600", "lastModified": "2025-02-05T13:24:31.809Z", "contentLength": 8213569, "httpStatusCode": 200}	ad52add0-fc63-4df3-871d-c89cbcf1479f	\N	{}
afb58738-6353-4266-a0c1-24223adeed28	complaints_documents	f17d8111-cccf-4b85-afa7-ed9ad199e0ea/1738762000367_dataset_demo.png	\N	2025-02-05 13:26:40.40784+00	2025-02-05 13:26:40.40784+00	2025-02-05 13:26:40.40784+00	{"eTag": "\\"ef842ef2b0f11f6d76b442732db69e27\\"", "size": 1703150, "mimetype": "text/plain;charset=UTF-8", "cacheControl": "max-age=3600", "lastModified": "2025-02-05T13:26:40.401Z", "contentLength": 1703150, "httpStatusCode": 200}	2e4d7df6-44fe-446d-8396-446e2d6434ae	\N	{}
c88268c1-0ac3-41bb-89ff-1ee7162ff463	complaints_documents	3aa665b7-a4dd-40d8-b647-82e6ce3b3e16/1739170181915_Jan.jpg	\N	2025-02-10 06:49:41.952343+00	2025-02-10 06:49:41.952343+00	2025-02-10 06:49:41.952343+00	{"eTag": "\\"ba85e096fd530df668004657bd64e44c\\"", "size": 10140, "mimetype": "text/plain;charset=UTF-8", "cacheControl": "max-age=3600", "lastModified": "2025-02-10T06:49:41.947Z", "contentLength": 10140, "httpStatusCode": 200}	01eb3d50-0207-4028-8f75-ad22c738afe3	\N	{}
04709e8a-5235-4c7c-b3ca-57fcc0509dbd	complaints_documents	3aa665b7-a4dd-40d8-b647-82e6ce3b3e16/4d5b4b84-057c-4c93-9da6-f142367f0710.csv	3aa665b7-a4dd-40d8-b647-82e6ce3b3e16	2025-02-10 15:01:54.945907+00	2025-02-10 15:01:54.945907+00	2025-02-10 15:01:54.945907+00	{"eTag": "\\"372ed6536fe8bbbb10e655319b302113\\"", "size": 3544, "mimetype": "text/csv", "cacheControl": "max-age=3600", "lastModified": "2025-02-10T15:01:54.944Z", "contentLength": 3544, "httpStatusCode": 200}	bb928cd8-d73f-4318-9330-e3c7b36aa032	3aa665b7-a4dd-40d8-b647-82e6ce3b3e16	{}
be914ab4-c0c1-45cf-9595-1ebd02273ffb	complaints_documents	3aa665b7-a4dd-40d8-b647-82e6ce3b3e16/a9ddce59-9e8c-4bc6-aac2-937a2542624b.png	3aa665b7-a4dd-40d8-b647-82e6ce3b3e16	2025-02-11 06:22:08.958307+00	2025-02-11 06:22:08.958307+00	2025-02-11 06:22:08.958307+00	{"eTag": "\\"0a39406816cfa4c60104fd517a420f84\\"", "size": 5481544, "mimetype": "image/png", "cacheControl": "max-age=3600", "lastModified": "2025-02-11T06:22:08.930Z", "contentLength": 5481544, "httpStatusCode": 200}	35208675-4528-44a3-8b21-acca2d23733d	3aa665b7-a4dd-40d8-b647-82e6ce3b3e16	{}
fd0508ae-dea2-4cd7-b487-76cd8da8f034	complaints_documents	3aa665b7-a4dd-40d8-b647-82e6ce3b3e16/dc27c061-a9eb-4a2a-b060-373cbe05a772.json	3aa665b7-a4dd-40d8-b647-82e6ce3b3e16	2025-02-11 06:31:20.901329+00	2025-02-11 06:31:20.901329+00	2025-02-11 06:31:20.901329+00	{"eTag": "\\"dfc565bf81e83b52e658a07ce46f8afa\\"", "size": 1651, "mimetype": "application/json", "cacheControl": "max-age=3600", "lastModified": "2025-02-11T06:31:20.899Z", "contentLength": 1651, "httpStatusCode": 200}	fa441ccc-c4a6-4a53-b0de-5975451efa3b	3aa665b7-a4dd-40d8-b647-82e6ce3b3e16	{}
076550f3-3f19-4c50-bc98-2ea9bea32775	complaints_documents	3aa665b7-a4dd-40d8-b647-82e6ce3b3e16/d5ccb582-5a79-414b-bdf8-35d39dd8c972.json	3aa665b7-a4dd-40d8-b647-82e6ce3b3e16	2025-02-11 06:35:05.562282+00	2025-02-11 06:35:05.562282+00	2025-02-11 06:35:05.562282+00	{"eTag": "\\"dfc565bf81e83b52e658a07ce46f8afa\\"", "size": 1651, "mimetype": "application/json", "cacheControl": "max-age=3600", "lastModified": "2025-02-11T06:35:05.561Z", "contentLength": 1651, "httpStatusCode": 200}	5f3cfb7d-3b8e-491f-84fa-24bea7da56d2	3aa665b7-a4dd-40d8-b647-82e6ce3b3e16	{}
1828cf98-29b7-46a0-8085-3af6ed20f60b	complaints_documents	3aa665b7-a4dd-40d8-b647-82e6ce3b3e16/46dac45d-2f1a-4191-93e1-20ebd3099d76.jpeg	3aa665b7-a4dd-40d8-b647-82e6ce3b3e16	2025-02-11 06:35:26.332407+00	2025-02-11 06:35:26.332407+00	2025-02-11 06:35:26.332407+00	{"eTag": "\\"3930ee17f29538a825b37f239fce74b7\\"", "size": 139608, "mimetype": "image/jpeg", "cacheControl": "max-age=3600", "lastModified": "2025-02-11T06:35:26.329Z", "contentLength": 139608, "httpStatusCode": 200}	b5abbc6c-d80c-438d-b478-44c0d0311b23	3aa665b7-a4dd-40d8-b647-82e6ce3b3e16	{}
c0a330f1-5f44-4869-bf1c-74630b52a00d	complaints_documents	3aa665b7-a4dd-40d8-b647-82e6ce3b3e16/600e6f8a-20df-40cf-88f9-1fc5946d5101.csv	3aa665b7-a4dd-40d8-b647-82e6ce3b3e16	2025-02-11 06:37:13.845306+00	2025-02-11 06:37:13.845306+00	2025-02-11 06:37:13.845306+00	{"eTag": "\\"c2675e4e4c2dd800caca3e2e9cdb19fb\\"", "size": 42123115, "mimetype": "text/csv", "cacheControl": "max-age=3600", "lastModified": "2025-02-11T06:37:13.701Z", "contentLength": 42123115, "httpStatusCode": 200}	26d8ceb2-d634-49fc-bce5-d01103d5199a	3aa665b7-a4dd-40d8-b647-82e6ce3b3e16	{}
6b5c91fa-2016-404b-be97-2498d8431ebf	complaints_documents	3aa665b7-a4dd-40d8-b647-82e6ce3b3e16/96eaa75f-8d66-4f5f-b731-0661ac75d68e.List_of_Companies_2023-03-23.pdf	3aa665b7-a4dd-40d8-b647-82e6ce3b3e16	2025-02-11 06:43:39.079286+00	2025-02-11 06:43:39.079286+00	2025-02-11 06:43:39.079286+00	{"eTag": "\\"7aaed3168a679bac246332fb466af96e\\"", "size": 305278, "mimetype": "application/pdf", "cacheControl": "max-age=3600", "lastModified": "2025-02-11T06:43:39.077Z", "contentLength": 305278, "httpStatusCode": 200}	333aa267-053e-4bb0-a8ba-1d9ab95d3bf2	3aa665b7-a4dd-40d8-b647-82e6ce3b3e16	{}
b692f716-628d-48f5-a22f-73956bc7396f	complaints_documents	3aa665b7-a4dd-40d8-b647-82e6ce3b3e16/ab786b00-ef29-45d1-956b-2eba17474f8b.demo.gif	3aa665b7-a4dd-40d8-b647-82e6ce3b3e16	2025-02-11 06:47:33.421884+00	2025-02-11 06:47:33.421884+00	2025-02-11 06:47:33.421884+00	{"eTag": "\\"c87038d5fc520f8453a0634ffb9807a3\\"", "size": 4330847, "mimetype": "image/gif", "cacheControl": "max-age=3600", "lastModified": "2025-02-11T06:47:33.405Z", "contentLength": 4330847, "httpStatusCode": 200}	277b8062-d80f-42b1-8d61-84d27dc18efc	3aa665b7-a4dd-40d8-b647-82e6ce3b3e16	{}
0a2c4470-be22-4ff6-89db-637ae215dc2d	complaints_documents	3aa665b7-a4dd-40d8-b647-82e6ce3b3e16/ad075a30-91a4-47e9-8f91-3a719e818130-moon2.jpeg	3aa665b7-a4dd-40d8-b647-82e6ce3b3e16	2025-02-11 06:47:54.235784+00	2025-02-11 06:47:54.235784+00	2025-02-11 06:47:54.235784+00	{"eTag": "\\"3930ee17f29538a825b37f239fce74b7\\"", "size": 139608, "mimetype": "image/jpeg", "cacheControl": "max-age=3600", "lastModified": "2025-02-11T06:47:54.197Z", "contentLength": 139608, "httpStatusCode": 200}	4caa21fd-9b2c-435c-a65c-d66774c2bd28	3aa665b7-a4dd-40d8-b647-82e6ce3b3e16	{}
5da7e3d6-c981-4287-93a8-07e7e2ddd3dc	complaints_documents	3aa665b7-a4dd-40d8-b647-82e6ce3b3e16/693c8025-71c9-450c-b2e8-77dff223b293-1737610426799_MOCK_DATA.csv	3aa665b7-a4dd-40d8-b647-82e6ce3b3e16	2025-02-11 07:02:35.923813+00	2025-02-11 07:02:35.923813+00	2025-02-11 07:02:35.923813+00	{"eTag": "\\"372ed6536fe8bbbb10e655319b302113\\"", "size": 3544, "mimetype": "text/csv", "cacheControl": "max-age=3600", "lastModified": "2025-02-11T07:02:35.922Z", "contentLength": 3544, "httpStatusCode": 200}	a328bdec-56d0-467b-b783-35bfff3264bd	3aa665b7-a4dd-40d8-b647-82e6ce3b3e16	{}
1ef163c4-d86b-4fa9-9bf7-df310ae1f8f9	complaints_documents	3aa665b7-a4dd-40d8-b647-82e6ce3b3e16/f974b44e-117c-4bf8-9698-4f12da649d0d-self_cited_papers (2).csv	3aa665b7-a4dd-40d8-b647-82e6ce3b3e16	2025-02-11 07:08:31.035713+00	2025-02-11 07:08:31.035713+00	2025-02-11 07:08:31.035713+00	{"eTag": "\\"52e668176464f7701f004a24c3be6fa1\\"", "size": 1459856, "mimetype": "text/csv", "cacheControl": "max-age=3600", "lastModified": "2025-02-11T07:08:31.029Z", "contentLength": 1459856, "httpStatusCode": 200}	0ce36be0-7ea2-4971-b365-74b52c54d2f3	3aa665b7-a4dd-40d8-b647-82e6ce3b3e16	{}
310e40bd-ff3f-4196-9ed8-134466568cbf	complaints_documents	3aa665b7-a4dd-40d8-b647-82e6ce3b3e16/2d0df3dc-e909-452e-9bc1-8fcca5877099-803adc34-e544-11ef-a6a6-769fca1489e4.xlsx	3aa665b7-a4dd-40d8-b647-82e6ce3b3e16	2025-02-11 07:08:56.136536+00	2025-02-11 07:08:56.136536+00	2025-02-11 07:08:56.136536+00	{"eTag": "\\"9b83ecf66e73210591ee2a46678d9352\\"", "size": 231679, "mimetype": "application/wps-office.xlsx", "cacheControl": "max-age=3600", "lastModified": "2025-02-11T07:08:56.135Z", "contentLength": 231679, "httpStatusCode": 200}	0aabf0e7-8d17-450f-a4dc-847b39bed146	3aa665b7-a4dd-40d8-b647-82e6ce3b3e16	{}
d2c231a3-56e7-42bf-ab28-2f83c9911a58	complaints_documents	3aa665b7-a4dd-40d8-b647-82e6ce3b3e16/1739329649161_author_summary.csv	\N	2025-02-12 03:07:29.199148+00	2025-02-12 03:07:29.199148+00	2025-02-12 03:07:29.199148+00	{"eTag": "\\"c29edfb772bc38aedc528c808e59e4a0\\"", "size": 95842, "mimetype": "text/plain;charset=UTF-8", "cacheControl": "max-age=3600", "lastModified": "2025-02-12T03:07:29.195Z", "contentLength": 95842, "httpStatusCode": 200}	ac0a0d77-e487-4016-b3f4-81efd2cd92e6	\N	{}
1e58ad66-d44e-44d5-9e4c-44637c0c4c4b	complaints_documents	3aa665b7-a4dd-40d8-b647-82e6ce3b3e16/b7e4cac0-b000-4c05-831a-2a37c36d1e14-complaints.pdf	3aa665b7-a4dd-40d8-b647-82e6ce3b3e16	2025-02-16 14:12:37.24147+00	2025-02-16 14:12:37.24147+00	2025-02-16 14:12:37.24147+00	{"eTag": "\\"e30b142a99171c7202b0b50c5ef429a6\\"", "size": 3751612, "mimetype": "application/pdf", "cacheControl": "max-age=3600", "lastModified": "2025-02-16T14:12:37.219Z", "contentLength": 3751612, "httpStatusCode": 200}	46c2c898-9bfc-48ca-8028-13f08adb79a7	3aa665b7-a4dd-40d8-b647-82e6ce3b3e16	{}
3e7ffe0e-601d-4fa8-bc80-ec1e4feaff72	complaints_documents	3aa665b7-a4dd-40d8-b647-82e6ce3b3e16/7df66b2b-ef01-458d-bfad-f23201f101b2-complaints.pdf	3aa665b7-a4dd-40d8-b647-82e6ce3b3e16	2025-02-17 03:33:23.352446+00	2025-02-17 03:33:23.352446+00	2025-02-17 03:33:23.352446+00	{"eTag": "\\"e30b142a99171c7202b0b50c5ef429a6\\"", "size": 3751612, "mimetype": "application/pdf", "cacheControl": "max-age=3600", "lastModified": "2025-02-17T03:33:23.334Z", "contentLength": 3751612, "httpStatusCode": 200}	0ec50fe1-0707-48f8-9a5a-43d8b9db6b1b	3aa665b7-a4dd-40d8-b647-82e6ce3b3e16	{}
1b71c69e-30f0-4c84-9c5b-0a2f660956fa	complaints_documents	f17d8111-cccf-4b85-afa7-ed9ad199e0ea/1739763517766_summaries.xlsx	\N	2025-02-17 03:38:37.792152+00	2025-02-17 03:38:37.792152+00	2025-02-17 03:38:37.792152+00	{"eTag": "\\"a46409ae65c90bf0226073b5625f9a6d\\"", "size": 16897, "mimetype": "text/plain;charset=UTF-8", "cacheControl": "max-age=3600", "lastModified": "2025-02-17T03:38:37.790Z", "contentLength": 16897, "httpStatusCode": 200}	97635d13-6dce-4e32-aae5-295994f6234a	\N	{}
\.


--
-- Data for Name: s3_multipart_uploads; Type: TABLE DATA; Schema: storage; Owner: supabase_storage_admin
--

COPY storage.s3_multipart_uploads (id, in_progress_size, upload_signature, bucket_id, key, version, owner_id, created_at, user_metadata) FROM stdin;
\.


--
-- Data for Name: s3_multipart_uploads_parts; Type: TABLE DATA; Schema: storage; Owner: supabase_storage_admin
--

COPY storage.s3_multipart_uploads_parts (id, upload_id, size, part_number, bucket_id, key, etag, owner_id, version, created_at) FROM stdin;
\.


--
-- Data for Name: hooks; Type: TABLE DATA; Schema: supabase_functions; Owner: supabase_functions_admin
--

COPY supabase_functions.hooks (id, hook_table_id, hook_name, created_at, request_id) FROM stdin;
\.


--
-- Data for Name: migrations; Type: TABLE DATA; Schema: supabase_functions; Owner: supabase_functions_admin
--

COPY supabase_functions.migrations (version, inserted_at) FROM stdin;
initial	2025-01-19 04:52:49.837588+00
20210809183423_update_grants	2025-01-19 04:52:49.837588+00
\.


--
-- Data for Name: secrets; Type: TABLE DATA; Schema: vault; Owner: supabase_admin
--

COPY vault.secrets (id, name, description, secret, key_id, nonce, created_at, updated_at) FROM stdin;
\.


--
-- Name: refresh_tokens_id_seq; Type: SEQUENCE SET; Schema: auth; Owner: supabase_auth_admin
--

SELECT pg_catalog.setval('auth.refresh_tokens_id_seq', 207, true);


--
-- Name: key_key_id_seq; Type: SEQUENCE SET; Schema: pgsodium; Owner: supabase_admin
--

SELECT pg_catalog.setval('pgsodium.key_key_id_seq', 1, false);


--
-- Name: complaint_actions_id_seq; Type: SEQUENCE SET; Schema: public; Owner: postgres
--

SELECT pg_catalog.setval('public.complaint_actions_id_seq', 66, true);


--
-- Name: complaints_complaint_id_seq; Type: SEQUENCE SET; Schema: public; Owner: postgres
--

SELECT pg_catalog.setval('public.complaints_complaint_id_seq', 29, true);


--
-- Name: summary_id_seq; Type: SEQUENCE SET; Schema: public; Owner: postgres
--

SELECT pg_catalog.setval('public.summary_id_seq', 9, true);


--
-- Name: user_id_seq; Type: SEQUENCE SET; Schema: public; Owner: postgres
--

SELECT pg_catalog.setval('public.user_id_seq', 3, true);


--
-- Name: subscription_id_seq; Type: SEQUENCE SET; Schema: realtime; Owner: supabase_admin
--

SELECT pg_catalog.setval('realtime.subscription_id_seq', 1, false);


--
-- Name: hooks_id_seq; Type: SEQUENCE SET; Schema: supabase_functions; Owner: supabase_functions_admin
--

SELECT pg_catalog.setval('supabase_functions.hooks_id_seq', 1, false);


--
-- Name: extensions extensions_pkey; Type: CONSTRAINT; Schema: _realtime; Owner: supabase_admin
--

ALTER TABLE ONLY _realtime.extensions
    ADD CONSTRAINT extensions_pkey PRIMARY KEY (id);


--
-- Name: schema_migrations schema_migrations_pkey; Type: CONSTRAINT; Schema: _realtime; Owner: supabase_admin
--

ALTER TABLE ONLY _realtime.schema_migrations
    ADD CONSTRAINT schema_migrations_pkey PRIMARY KEY (version);


--
-- Name: tenants tenants_pkey; Type: CONSTRAINT; Schema: _realtime; Owner: supabase_admin
--

ALTER TABLE ONLY _realtime.tenants
    ADD CONSTRAINT tenants_pkey PRIMARY KEY (id);


--
-- Name: mfa_amr_claims amr_id_pk; Type: CONSTRAINT; Schema: auth; Owner: supabase_auth_admin
--

ALTER TABLE ONLY auth.mfa_amr_claims
    ADD CONSTRAINT amr_id_pk PRIMARY KEY (id);


--
-- Name: audit_log_entries audit_log_entries_pkey; Type: CONSTRAINT; Schema: auth; Owner: supabase_auth_admin
--

ALTER TABLE ONLY auth.audit_log_entries
    ADD CONSTRAINT audit_log_entries_pkey PRIMARY KEY (id);


--
-- Name: flow_state flow_state_pkey; Type: CONSTRAINT; Schema: auth; Owner: supabase_auth_admin
--

ALTER TABLE ONLY auth.flow_state
    ADD CONSTRAINT flow_state_pkey PRIMARY KEY (id);


--
-- Name: identities identities_pkey; Type: CONSTRAINT; Schema: auth; Owner: supabase_auth_admin
--

ALTER TABLE ONLY auth.identities
    ADD CONSTRAINT identities_pkey PRIMARY KEY (id);


--
-- Name: identities identities_provider_id_provider_unique; Type: CONSTRAINT; Schema: auth; Owner: supabase_auth_admin
--

ALTER TABLE ONLY auth.identities
    ADD CONSTRAINT identities_provider_id_provider_unique UNIQUE (provider_id, provider);


--
-- Name: instances instances_pkey; Type: CONSTRAINT; Schema: auth; Owner: supabase_auth_admin
--

ALTER TABLE ONLY auth.instances
    ADD CONSTRAINT instances_pkey PRIMARY KEY (id);


--
-- Name: mfa_amr_claims mfa_amr_claims_session_id_authentication_method_pkey; Type: CONSTRAINT; Schema: auth; Owner: supabase_auth_admin
--

ALTER TABLE ONLY auth.mfa_amr_claims
    ADD CONSTRAINT mfa_amr_claims_session_id_authentication_method_pkey UNIQUE (session_id, authentication_method);


--
-- Name: mfa_challenges mfa_challenges_pkey; Type: CONSTRAINT; Schema: auth; Owner: supabase_auth_admin
--

ALTER TABLE ONLY auth.mfa_challenges
    ADD CONSTRAINT mfa_challenges_pkey PRIMARY KEY (id);


--
-- Name: mfa_factors mfa_factors_last_challenged_at_key; Type: CONSTRAINT; Schema: auth; Owner: supabase_auth_admin
--

ALTER TABLE ONLY auth.mfa_factors
    ADD CONSTRAINT mfa_factors_last_challenged_at_key UNIQUE (last_challenged_at);


--
-- Name: mfa_factors mfa_factors_pkey; Type: CONSTRAINT; Schema: auth; Owner: supabase_auth_admin
--

ALTER TABLE ONLY auth.mfa_factors
    ADD CONSTRAINT mfa_factors_pkey PRIMARY KEY (id);


--
-- Name: one_time_tokens one_time_tokens_pkey; Type: CONSTRAINT; Schema: auth; Owner: supabase_auth_admin
--

ALTER TABLE ONLY auth.one_time_tokens
    ADD CONSTRAINT one_time_tokens_pkey PRIMARY KEY (id);


--
-- Name: refresh_tokens refresh_tokens_pkey; Type: CONSTRAINT; Schema: auth; Owner: supabase_auth_admin
--

ALTER TABLE ONLY auth.refresh_tokens
    ADD CONSTRAINT refresh_tokens_pkey PRIMARY KEY (id);


--
-- Name: refresh_tokens refresh_tokens_token_unique; Type: CONSTRAINT; Schema: auth; Owner: supabase_auth_admin
--

ALTER TABLE ONLY auth.refresh_tokens
    ADD CONSTRAINT refresh_tokens_token_unique UNIQUE (token);


--
-- Name: saml_providers saml_providers_entity_id_key; Type: CONSTRAINT; Schema: auth; Owner: supabase_auth_admin
--

ALTER TABLE ONLY auth.saml_providers
    ADD CONSTRAINT saml_providers_entity_id_key UNIQUE (entity_id);


--
-- Name: saml_providers saml_providers_pkey; Type: CONSTRAINT; Schema: auth; Owner: supabase_auth_admin
--

ALTER TABLE ONLY auth.saml_providers
    ADD CONSTRAINT saml_providers_pkey PRIMARY KEY (id);


--
-- Name: saml_relay_states saml_relay_states_pkey; Type: CONSTRAINT; Schema: auth; Owner: supabase_auth_admin
--

ALTER TABLE ONLY auth.saml_relay_states
    ADD CONSTRAINT saml_relay_states_pkey PRIMARY KEY (id);


--
-- Name: schema_migrations schema_migrations_pkey; Type: CONSTRAINT; Schema: auth; Owner: supabase_auth_admin
--

ALTER TABLE ONLY auth.schema_migrations
    ADD CONSTRAINT schema_migrations_pkey PRIMARY KEY (version);


--
-- Name: sessions sessions_pkey; Type: CONSTRAINT; Schema: auth; Owner: supabase_auth_admin
--

ALTER TABLE ONLY auth.sessions
    ADD CONSTRAINT sessions_pkey PRIMARY KEY (id);


--
-- Name: sso_domains sso_domains_pkey; Type: CONSTRAINT; Schema: auth; Owner: supabase_auth_admin
--

ALTER TABLE ONLY auth.sso_domains
    ADD CONSTRAINT sso_domains_pkey PRIMARY KEY (id);


--
-- Name: sso_providers sso_providers_pkey; Type: CONSTRAINT; Schema: auth; Owner: supabase_auth_admin
--

ALTER TABLE ONLY auth.sso_providers
    ADD CONSTRAINT sso_providers_pkey PRIMARY KEY (id);


--
-- Name: users users_phone_key; Type: CONSTRAINT; Schema: auth; Owner: supabase_auth_admin
--

ALTER TABLE ONLY auth.users
    ADD CONSTRAINT users_phone_key UNIQUE (phone);


--
-- Name: users users_pkey; Type: CONSTRAINT; Schema: auth; Owner: supabase_auth_admin
--

ALTER TABLE ONLY auth.users
    ADD CONSTRAINT users_pkey PRIMARY KEY (id);


--
-- Name: complaint_actions complaint_actions_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.complaint_actions
    ADD CONSTRAINT complaint_actions_pkey PRIMARY KEY (action_id);


--
-- Name: complaints complaints_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.complaints
    ADD CONSTRAINT complaints_pkey PRIMARY KEY (complaint_id);


--
-- Name: summary summary_complaint_id_key; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.summary
    ADD CONSTRAINT summary_complaint_id_key UNIQUE (complaint_id);


--
-- Name: summary summary_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.summary
    ADD CONSTRAINT summary_pkey PRIMARY KEY (id);


--
-- Name: user user_id_key; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public."user"
    ADD CONSTRAINT user_id_key UNIQUE (id);


--
-- Name: user user_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public."user"
    ADD CONSTRAINT user_pkey PRIMARY KEY (id, user_id);


--
-- Name: user user_user_id_key; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public."user"
    ADD CONSTRAINT user_user_id_key UNIQUE (user_id);


--
-- Name: messages messages_pkey; Type: CONSTRAINT; Schema: realtime; Owner: supabase_realtime_admin
--

ALTER TABLE ONLY realtime.messages
    ADD CONSTRAINT messages_pkey PRIMARY KEY (id, inserted_at);


--
-- Name: subscription pk_subscription; Type: CONSTRAINT; Schema: realtime; Owner: supabase_admin
--

ALTER TABLE ONLY realtime.subscription
    ADD CONSTRAINT pk_subscription PRIMARY KEY (id);


--
-- Name: schema_migrations schema_migrations_pkey; Type: CONSTRAINT; Schema: realtime; Owner: supabase_admin
--

ALTER TABLE ONLY realtime.schema_migrations
    ADD CONSTRAINT schema_migrations_pkey PRIMARY KEY (version);


--
-- Name: buckets buckets_pkey; Type: CONSTRAINT; Schema: storage; Owner: supabase_storage_admin
--

ALTER TABLE ONLY storage.buckets
    ADD CONSTRAINT buckets_pkey PRIMARY KEY (id);


--
-- Name: migrations migrations_name_key; Type: CONSTRAINT; Schema: storage; Owner: supabase_storage_admin
--

ALTER TABLE ONLY storage.migrations
    ADD CONSTRAINT migrations_name_key UNIQUE (name);


--
-- Name: migrations migrations_pkey; Type: CONSTRAINT; Schema: storage; Owner: supabase_storage_admin
--

ALTER TABLE ONLY storage.migrations
    ADD CONSTRAINT migrations_pkey PRIMARY KEY (id);


--
-- Name: objects objects_pkey; Type: CONSTRAINT; Schema: storage; Owner: supabase_storage_admin
--

ALTER TABLE ONLY storage.objects
    ADD CONSTRAINT objects_pkey PRIMARY KEY (id);


--
-- Name: s3_multipart_uploads_parts s3_multipart_uploads_parts_pkey; Type: CONSTRAINT; Schema: storage; Owner: supabase_storage_admin
--

ALTER TABLE ONLY storage.s3_multipart_uploads_parts
    ADD CONSTRAINT s3_multipart_uploads_parts_pkey PRIMARY KEY (id);


--
-- Name: s3_multipart_uploads s3_multipart_uploads_pkey; Type: CONSTRAINT; Schema: storage; Owner: supabase_storage_admin
--

ALTER TABLE ONLY storage.s3_multipart_uploads
    ADD CONSTRAINT s3_multipart_uploads_pkey PRIMARY KEY (id);


--
-- Name: hooks hooks_pkey; Type: CONSTRAINT; Schema: supabase_functions; Owner: supabase_functions_admin
--

ALTER TABLE ONLY supabase_functions.hooks
    ADD CONSTRAINT hooks_pkey PRIMARY KEY (id);


--
-- Name: migrations migrations_pkey; Type: CONSTRAINT; Schema: supabase_functions; Owner: supabase_functions_admin
--

ALTER TABLE ONLY supabase_functions.migrations
    ADD CONSTRAINT migrations_pkey PRIMARY KEY (version);


--
-- Name: extensions_tenant_external_id_index; Type: INDEX; Schema: _realtime; Owner: supabase_admin
--

CREATE INDEX extensions_tenant_external_id_index ON _realtime.extensions USING btree (tenant_external_id);


--
-- Name: extensions_tenant_external_id_type_index; Type: INDEX; Schema: _realtime; Owner: supabase_admin
--

CREATE UNIQUE INDEX extensions_tenant_external_id_type_index ON _realtime.extensions USING btree (tenant_external_id, type);


--
-- Name: tenants_external_id_index; Type: INDEX; Schema: _realtime; Owner: supabase_admin
--

CREATE UNIQUE INDEX tenants_external_id_index ON _realtime.tenants USING btree (external_id);


--
-- Name: audit_logs_instance_id_idx; Type: INDEX; Schema: auth; Owner: supabase_auth_admin
--

CREATE INDEX audit_logs_instance_id_idx ON auth.audit_log_entries USING btree (instance_id);


--
-- Name: confirmation_token_idx; Type: INDEX; Schema: auth; Owner: supabase_auth_admin
--

CREATE UNIQUE INDEX confirmation_token_idx ON auth.users USING btree (confirmation_token) WHERE ((confirmation_token)::text !~ '^[0-9 ]*$'::text);


--
-- Name: email_change_token_current_idx; Type: INDEX; Schema: auth; Owner: supabase_auth_admin
--

CREATE UNIQUE INDEX email_change_token_current_idx ON auth.users USING btree (email_change_token_current) WHERE ((email_change_token_current)::text !~ '^[0-9 ]*$'::text);


--
-- Name: email_change_token_new_idx; Type: INDEX; Schema: auth; Owner: supabase_auth_admin
--

CREATE UNIQUE INDEX email_change_token_new_idx ON auth.users USING btree (email_change_token_new) WHERE ((email_change_token_new)::text !~ '^[0-9 ]*$'::text);


--
-- Name: factor_id_created_at_idx; Type: INDEX; Schema: auth; Owner: supabase_auth_admin
--

CREATE INDEX factor_id_created_at_idx ON auth.mfa_factors USING btree (user_id, created_at);


--
-- Name: flow_state_created_at_idx; Type: INDEX; Schema: auth; Owner: supabase_auth_admin
--

CREATE INDEX flow_state_created_at_idx ON auth.flow_state USING btree (created_at DESC);


--
-- Name: identities_email_idx; Type: INDEX; Schema: auth; Owner: supabase_auth_admin
--

CREATE INDEX identities_email_idx ON auth.identities USING btree (email text_pattern_ops);


--
-- Name: INDEX identities_email_idx; Type: COMMENT; Schema: auth; Owner: supabase_auth_admin
--

COMMENT ON INDEX auth.identities_email_idx IS 'Auth: Ensures indexed queries on the email column';


--
-- Name: identities_user_id_idx; Type: INDEX; Schema: auth; Owner: supabase_auth_admin
--

CREATE INDEX identities_user_id_idx ON auth.identities USING btree (user_id);


--
-- Name: idx_auth_code; Type: INDEX; Schema: auth; Owner: supabase_auth_admin
--

CREATE INDEX idx_auth_code ON auth.flow_state USING btree (auth_code);


--
-- Name: idx_user_id_auth_method; Type: INDEX; Schema: auth; Owner: supabase_auth_admin
--

CREATE INDEX idx_user_id_auth_method ON auth.flow_state USING btree (user_id, authentication_method);


--
-- Name: mfa_challenge_created_at_idx; Type: INDEX; Schema: auth; Owner: supabase_auth_admin
--

CREATE INDEX mfa_challenge_created_at_idx ON auth.mfa_challenges USING btree (created_at DESC);


--
-- Name: mfa_factors_user_friendly_name_unique; Type: INDEX; Schema: auth; Owner: supabase_auth_admin
--

CREATE UNIQUE INDEX mfa_factors_user_friendly_name_unique ON auth.mfa_factors USING btree (friendly_name, user_id) WHERE (TRIM(BOTH FROM friendly_name) <> ''::text);


--
-- Name: mfa_factors_user_id_idx; Type: INDEX; Schema: auth; Owner: supabase_auth_admin
--

CREATE INDEX mfa_factors_user_id_idx ON auth.mfa_factors USING btree (user_id);


--
-- Name: one_time_tokens_relates_to_hash_idx; Type: INDEX; Schema: auth; Owner: supabase_auth_admin
--

CREATE INDEX one_time_tokens_relates_to_hash_idx ON auth.one_time_tokens USING hash (relates_to);


--
-- Name: one_time_tokens_token_hash_hash_idx; Type: INDEX; Schema: auth; Owner: supabase_auth_admin
--

CREATE INDEX one_time_tokens_token_hash_hash_idx ON auth.one_time_tokens USING hash (token_hash);


--
-- Name: one_time_tokens_user_id_token_type_key; Type: INDEX; Schema: auth; Owner: supabase_auth_admin
--

CREATE UNIQUE INDEX one_time_tokens_user_id_token_type_key ON auth.one_time_tokens USING btree (user_id, token_type);


--
-- Name: reauthentication_token_idx; Type: INDEX; Schema: auth; Owner: supabase_auth_admin
--

CREATE UNIQUE INDEX reauthentication_token_idx ON auth.users USING btree (reauthentication_token) WHERE ((reauthentication_token)::text !~ '^[0-9 ]*$'::text);


--
-- Name: recovery_token_idx; Type: INDEX; Schema: auth; Owner: supabase_auth_admin
--

CREATE UNIQUE INDEX recovery_token_idx ON auth.users USING btree (recovery_token) WHERE ((recovery_token)::text !~ '^[0-9 ]*$'::text);


--
-- Name: refresh_tokens_instance_id_idx; Type: INDEX; Schema: auth; Owner: supabase_auth_admin
--

CREATE INDEX refresh_tokens_instance_id_idx ON auth.refresh_tokens USING btree (instance_id);


--
-- Name: refresh_tokens_instance_id_user_id_idx; Type: INDEX; Schema: auth; Owner: supabase_auth_admin
--

CREATE INDEX refresh_tokens_instance_id_user_id_idx ON auth.refresh_tokens USING btree (instance_id, user_id);


--
-- Name: refresh_tokens_parent_idx; Type: INDEX; Schema: auth; Owner: supabase_auth_admin
--

CREATE INDEX refresh_tokens_parent_idx ON auth.refresh_tokens USING btree (parent);


--
-- Name: refresh_tokens_session_id_revoked_idx; Type: INDEX; Schema: auth; Owner: supabase_auth_admin
--

CREATE INDEX refresh_tokens_session_id_revoked_idx ON auth.refresh_tokens USING btree (session_id, revoked);


--
-- Name: refresh_tokens_updated_at_idx; Type: INDEX; Schema: auth; Owner: supabase_auth_admin
--

CREATE INDEX refresh_tokens_updated_at_idx ON auth.refresh_tokens USING btree (updated_at DESC);


--
-- Name: saml_providers_sso_provider_id_idx; Type: INDEX; Schema: auth; Owner: supabase_auth_admin
--

CREATE INDEX saml_providers_sso_provider_id_idx ON auth.saml_providers USING btree (sso_provider_id);


--
-- Name: saml_relay_states_created_at_idx; Type: INDEX; Schema: auth; Owner: supabase_auth_admin
--

CREATE INDEX saml_relay_states_created_at_idx ON auth.saml_relay_states USING btree (created_at DESC);


--
-- Name: saml_relay_states_for_email_idx; Type: INDEX; Schema: auth; Owner: supabase_auth_admin
--

CREATE INDEX saml_relay_states_for_email_idx ON auth.saml_relay_states USING btree (for_email);


--
-- Name: saml_relay_states_sso_provider_id_idx; Type: INDEX; Schema: auth; Owner: supabase_auth_admin
--

CREATE INDEX saml_relay_states_sso_provider_id_idx ON auth.saml_relay_states USING btree (sso_provider_id);


--
-- Name: sessions_not_after_idx; Type: INDEX; Schema: auth; Owner: supabase_auth_admin
--

CREATE INDEX sessions_not_after_idx ON auth.sessions USING btree (not_after DESC);


--
-- Name: sessions_user_id_idx; Type: INDEX; Schema: auth; Owner: supabase_auth_admin
--

CREATE INDEX sessions_user_id_idx ON auth.sessions USING btree (user_id);


--
-- Name: sso_domains_domain_idx; Type: INDEX; Schema: auth; Owner: supabase_auth_admin
--

CREATE UNIQUE INDEX sso_domains_domain_idx ON auth.sso_domains USING btree (lower(domain));


--
-- Name: sso_domains_sso_provider_id_idx; Type: INDEX; Schema: auth; Owner: supabase_auth_admin
--

CREATE INDEX sso_domains_sso_provider_id_idx ON auth.sso_domains USING btree (sso_provider_id);


--
-- Name: sso_providers_resource_id_idx; Type: INDEX; Schema: auth; Owner: supabase_auth_admin
--

CREATE UNIQUE INDEX sso_providers_resource_id_idx ON auth.sso_providers USING btree (lower(resource_id));


--
-- Name: unique_phone_factor_per_user; Type: INDEX; Schema: auth; Owner: supabase_auth_admin
--

CREATE UNIQUE INDEX unique_phone_factor_per_user ON auth.mfa_factors USING btree (user_id, phone);


--
-- Name: user_id_created_at_idx; Type: INDEX; Schema: auth; Owner: supabase_auth_admin
--

CREATE INDEX user_id_created_at_idx ON auth.sessions USING btree (user_id, created_at);


--
-- Name: users_email_partial_key; Type: INDEX; Schema: auth; Owner: supabase_auth_admin
--

CREATE UNIQUE INDEX users_email_partial_key ON auth.users USING btree (email) WHERE (is_sso_user = false);


--
-- Name: INDEX users_email_partial_key; Type: COMMENT; Schema: auth; Owner: supabase_auth_admin
--

COMMENT ON INDEX auth.users_email_partial_key IS 'Auth: A partial unique index that applies only when is_sso_user is false';


--
-- Name: users_instance_id_email_idx; Type: INDEX; Schema: auth; Owner: supabase_auth_admin
--

CREATE INDEX users_instance_id_email_idx ON auth.users USING btree (instance_id, lower((email)::text));


--
-- Name: users_instance_id_idx; Type: INDEX; Schema: auth; Owner: supabase_auth_admin
--

CREATE INDEX users_instance_id_idx ON auth.users USING btree (instance_id);


--
-- Name: users_is_anonymous_idx; Type: INDEX; Schema: auth; Owner: supabase_auth_admin
--

CREATE INDEX users_is_anonymous_idx ON auth.users USING btree (is_anonymous);


--
-- Name: ix_realtime_subscription_entity; Type: INDEX; Schema: realtime; Owner: supabase_admin
--

CREATE INDEX ix_realtime_subscription_entity ON realtime.subscription USING btree (entity);


--
-- Name: subscription_subscription_id_entity_filters_key; Type: INDEX; Schema: realtime; Owner: supabase_admin
--

CREATE UNIQUE INDEX subscription_subscription_id_entity_filters_key ON realtime.subscription USING btree (subscription_id, entity, filters);


--
-- Name: bname; Type: INDEX; Schema: storage; Owner: supabase_storage_admin
--

CREATE UNIQUE INDEX bname ON storage.buckets USING btree (name);


--
-- Name: bucketid_objname; Type: INDEX; Schema: storage; Owner: supabase_storage_admin
--

CREATE UNIQUE INDEX bucketid_objname ON storage.objects USING btree (bucket_id, name);


--
-- Name: idx_multipart_uploads_list; Type: INDEX; Schema: storage; Owner: supabase_storage_admin
--

CREATE INDEX idx_multipart_uploads_list ON storage.s3_multipart_uploads USING btree (bucket_id, key, created_at);


--
-- Name: idx_objects_bucket_id_name; Type: INDEX; Schema: storage; Owner: supabase_storage_admin
--

CREATE INDEX idx_objects_bucket_id_name ON storage.objects USING btree (bucket_id, name COLLATE "C");


--
-- Name: name_prefix_search; Type: INDEX; Schema: storage; Owner: supabase_storage_admin
--

CREATE INDEX name_prefix_search ON storage.objects USING btree (name text_pattern_ops);


--
-- Name: supabase_functions_hooks_h_table_id_h_name_idx; Type: INDEX; Schema: supabase_functions; Owner: supabase_functions_admin
--

CREATE INDEX supabase_functions_hooks_h_table_id_h_name_idx ON supabase_functions.hooks USING btree (hook_table_id, hook_name);


--
-- Name: supabase_functions_hooks_request_id_idx; Type: INDEX; Schema: supabase_functions; Owner: supabase_functions_admin
--

CREATE INDEX supabase_functions_hooks_request_id_idx ON supabase_functions.hooks USING btree (request_id);


--
-- Name: subscription tr_check_filters; Type: TRIGGER; Schema: realtime; Owner: supabase_admin
--

CREATE TRIGGER tr_check_filters BEFORE INSERT OR UPDATE ON realtime.subscription FOR EACH ROW EXECUTE FUNCTION realtime.subscription_check_filters();


--
-- Name: objects update_objects_updated_at; Type: TRIGGER; Schema: storage; Owner: supabase_storage_admin
--

CREATE TRIGGER update_objects_updated_at BEFORE UPDATE ON storage.objects FOR EACH ROW EXECUTE FUNCTION storage.update_updated_at_column();


--
-- Name: extensions extensions_tenant_external_id_fkey; Type: FK CONSTRAINT; Schema: _realtime; Owner: supabase_admin
--

ALTER TABLE ONLY _realtime.extensions
    ADD CONSTRAINT extensions_tenant_external_id_fkey FOREIGN KEY (tenant_external_id) REFERENCES _realtime.tenants(external_id) ON DELETE CASCADE;


--
-- Name: identities identities_user_id_fkey; Type: FK CONSTRAINT; Schema: auth; Owner: supabase_auth_admin
--

ALTER TABLE ONLY auth.identities
    ADD CONSTRAINT identities_user_id_fkey FOREIGN KEY (user_id) REFERENCES auth.users(id) ON DELETE CASCADE;


--
-- Name: mfa_amr_claims mfa_amr_claims_session_id_fkey; Type: FK CONSTRAINT; Schema: auth; Owner: supabase_auth_admin
--

ALTER TABLE ONLY auth.mfa_amr_claims
    ADD CONSTRAINT mfa_amr_claims_session_id_fkey FOREIGN KEY (session_id) REFERENCES auth.sessions(id) ON DELETE CASCADE;


--
-- Name: mfa_challenges mfa_challenges_auth_factor_id_fkey; Type: FK CONSTRAINT; Schema: auth; Owner: supabase_auth_admin
--

ALTER TABLE ONLY auth.mfa_challenges
    ADD CONSTRAINT mfa_challenges_auth_factor_id_fkey FOREIGN KEY (factor_id) REFERENCES auth.mfa_factors(id) ON DELETE CASCADE;


--
-- Name: mfa_factors mfa_factors_user_id_fkey; Type: FK CONSTRAINT; Schema: auth; Owner: supabase_auth_admin
--

ALTER TABLE ONLY auth.mfa_factors
    ADD CONSTRAINT mfa_factors_user_id_fkey FOREIGN KEY (user_id) REFERENCES auth.users(id) ON DELETE CASCADE;


--
-- Name: one_time_tokens one_time_tokens_user_id_fkey; Type: FK CONSTRAINT; Schema: auth; Owner: supabase_auth_admin
--

ALTER TABLE ONLY auth.one_time_tokens
    ADD CONSTRAINT one_time_tokens_user_id_fkey FOREIGN KEY (user_id) REFERENCES auth.users(id) ON DELETE CASCADE;


--
-- Name: refresh_tokens refresh_tokens_session_id_fkey; Type: FK CONSTRAINT; Schema: auth; Owner: supabase_auth_admin
--

ALTER TABLE ONLY auth.refresh_tokens
    ADD CONSTRAINT refresh_tokens_session_id_fkey FOREIGN KEY (session_id) REFERENCES auth.sessions(id) ON DELETE CASCADE;


--
-- Name: saml_providers saml_providers_sso_provider_id_fkey; Type: FK CONSTRAINT; Schema: auth; Owner: supabase_auth_admin
--

ALTER TABLE ONLY auth.saml_providers
    ADD CONSTRAINT saml_providers_sso_provider_id_fkey FOREIGN KEY (sso_provider_id) REFERENCES auth.sso_providers(id) ON DELETE CASCADE;


--
-- Name: saml_relay_states saml_relay_states_flow_state_id_fkey; Type: FK CONSTRAINT; Schema: auth; Owner: supabase_auth_admin
--

ALTER TABLE ONLY auth.saml_relay_states
    ADD CONSTRAINT saml_relay_states_flow_state_id_fkey FOREIGN KEY (flow_state_id) REFERENCES auth.flow_state(id) ON DELETE CASCADE;


--
-- Name: saml_relay_states saml_relay_states_sso_provider_id_fkey; Type: FK CONSTRAINT; Schema: auth; Owner: supabase_auth_admin
--

ALTER TABLE ONLY auth.saml_relay_states
    ADD CONSTRAINT saml_relay_states_sso_provider_id_fkey FOREIGN KEY (sso_provider_id) REFERENCES auth.sso_providers(id) ON DELETE CASCADE;


--
-- Name: sessions sessions_user_id_fkey; Type: FK CONSTRAINT; Schema: auth; Owner: supabase_auth_admin
--

ALTER TABLE ONLY auth.sessions
    ADD CONSTRAINT sessions_user_id_fkey FOREIGN KEY (user_id) REFERENCES auth.users(id) ON DELETE CASCADE;


--
-- Name: sso_domains sso_domains_sso_provider_id_fkey; Type: FK CONSTRAINT; Schema: auth; Owner: supabase_auth_admin
--

ALTER TABLE ONLY auth.sso_domains
    ADD CONSTRAINT sso_domains_sso_provider_id_fkey FOREIGN KEY (sso_provider_id) REFERENCES auth.sso_providers(id) ON DELETE CASCADE;


--
-- Name: complaint_actions complaint_actions_complaint_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.complaint_actions
    ADD CONSTRAINT complaint_actions_complaint_id_fkey FOREIGN KEY (complaint_id) REFERENCES public.complaints(complaint_id);


--
-- Name: complaints complaints_complainant_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.complaints
    ADD CONSTRAINT complaints_complainant_fkey FOREIGN KEY (complainant) REFERENCES public."user"(user_id);


--
-- Name: complaints complaints_last_action_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.complaints
    ADD CONSTRAINT complaints_last_action_fkey FOREIGN KEY (last_action) REFERENCES public.complaint_actions(action_id);


--
-- Name: summary summary_complaint_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.summary
    ADD CONSTRAINT summary_complaint_id_fkey FOREIGN KEY (complaint_id) REFERENCES public.complaints(complaint_id);


--
-- Name: objects objects_bucketId_fkey; Type: FK CONSTRAINT; Schema: storage; Owner: supabase_storage_admin
--

ALTER TABLE ONLY storage.objects
    ADD CONSTRAINT "objects_bucketId_fkey" FOREIGN KEY (bucket_id) REFERENCES storage.buckets(id);


--
-- Name: s3_multipart_uploads s3_multipart_uploads_bucket_id_fkey; Type: FK CONSTRAINT; Schema: storage; Owner: supabase_storage_admin
--

ALTER TABLE ONLY storage.s3_multipart_uploads
    ADD CONSTRAINT s3_multipart_uploads_bucket_id_fkey FOREIGN KEY (bucket_id) REFERENCES storage.buckets(id);


--
-- Name: s3_multipart_uploads_parts s3_multipart_uploads_parts_bucket_id_fkey; Type: FK CONSTRAINT; Schema: storage; Owner: supabase_storage_admin
--

ALTER TABLE ONLY storage.s3_multipart_uploads_parts
    ADD CONSTRAINT s3_multipart_uploads_parts_bucket_id_fkey FOREIGN KEY (bucket_id) REFERENCES storage.buckets(id);


--
-- Name: s3_multipart_uploads_parts s3_multipart_uploads_parts_upload_id_fkey; Type: FK CONSTRAINT; Schema: storage; Owner: supabase_storage_admin
--

ALTER TABLE ONLY storage.s3_multipart_uploads_parts
    ADD CONSTRAINT s3_multipart_uploads_parts_upload_id_fkey FOREIGN KEY (upload_id) REFERENCES storage.s3_multipart_uploads(id) ON DELETE CASCADE;


--
-- Name: audit_log_entries; Type: ROW SECURITY; Schema: auth; Owner: supabase_auth_admin
--

ALTER TABLE auth.audit_log_entries ENABLE ROW LEVEL SECURITY;

--
-- Name: flow_state; Type: ROW SECURITY; Schema: auth; Owner: supabase_auth_admin
--

ALTER TABLE auth.flow_state ENABLE ROW LEVEL SECURITY;

--
-- Name: identities; Type: ROW SECURITY; Schema: auth; Owner: supabase_auth_admin
--

ALTER TABLE auth.identities ENABLE ROW LEVEL SECURITY;

--
-- Name: instances; Type: ROW SECURITY; Schema: auth; Owner: supabase_auth_admin
--

ALTER TABLE auth.instances ENABLE ROW LEVEL SECURITY;

--
-- Name: mfa_amr_claims; Type: ROW SECURITY; Schema: auth; Owner: supabase_auth_admin
--

ALTER TABLE auth.mfa_amr_claims ENABLE ROW LEVEL SECURITY;

--
-- Name: mfa_challenges; Type: ROW SECURITY; Schema: auth; Owner: supabase_auth_admin
--

ALTER TABLE auth.mfa_challenges ENABLE ROW LEVEL SECURITY;

--
-- Name: mfa_factors; Type: ROW SECURITY; Schema: auth; Owner: supabase_auth_admin
--

ALTER TABLE auth.mfa_factors ENABLE ROW LEVEL SECURITY;

--
-- Name: one_time_tokens; Type: ROW SECURITY; Schema: auth; Owner: supabase_auth_admin
--

ALTER TABLE auth.one_time_tokens ENABLE ROW LEVEL SECURITY;

--
-- Name: refresh_tokens; Type: ROW SECURITY; Schema: auth; Owner: supabase_auth_admin
--

ALTER TABLE auth.refresh_tokens ENABLE ROW LEVEL SECURITY;

--
-- Name: saml_providers; Type: ROW SECURITY; Schema: auth; Owner: supabase_auth_admin
--

ALTER TABLE auth.saml_providers ENABLE ROW LEVEL SECURITY;

--
-- Name: saml_relay_states; Type: ROW SECURITY; Schema: auth; Owner: supabase_auth_admin
--

ALTER TABLE auth.saml_relay_states ENABLE ROW LEVEL SECURITY;

--
-- Name: schema_migrations; Type: ROW SECURITY; Schema: auth; Owner: supabase_auth_admin
--

ALTER TABLE auth.schema_migrations ENABLE ROW LEVEL SECURITY;

--
-- Name: sessions; Type: ROW SECURITY; Schema: auth; Owner: supabase_auth_admin
--

ALTER TABLE auth.sessions ENABLE ROW LEVEL SECURITY;

--
-- Name: sso_domains; Type: ROW SECURITY; Schema: auth; Owner: supabase_auth_admin
--

ALTER TABLE auth.sso_domains ENABLE ROW LEVEL SECURITY;

--
-- Name: sso_providers; Type: ROW SECURITY; Schema: auth; Owner: supabase_auth_admin
--

ALTER TABLE auth.sso_providers ENABLE ROW LEVEL SECURITY;

--
-- Name: users; Type: ROW SECURITY; Schema: auth; Owner: supabase_auth_admin
--

ALTER TABLE auth.users ENABLE ROW LEVEL SECURITY;

--
-- Name: complaint_actions Disable updates for closed; Type: POLICY; Schema: public; Owner: postgres
--

CREATE POLICY "Disable updates for closed" ON public.complaint_actions FOR INSERT TO authenticated WITH CHECK ((EXISTS ( SELECT 1
   FROM public.complaints
  WHERE ((complaints.complaint_id = complaint_actions.complaint_id) AND (complaints.complainant = auth.uid()) AND (NOT complaint_actions.confidential) AND (complaints.status <> ALL (ARRAY['closed'::text])) AND (complaint_actions.action = ANY (ARRAY['evidence'::text, 'appealed'::text, 'closed'::text]))))));


--
-- Name: complaints Enable insert for users based on user_id; Type: POLICY; Schema: public; Owner: postgres
--

CREATE POLICY "Enable insert for users based on user_id" ON public.complaints FOR INSERT WITH CHECK ((( SELECT auth.uid() AS uid) = complainant));


--
-- Name: user Enable insert for users based on user_id; Type: POLICY; Schema: public; Owner: postgres
--

CREATE POLICY "Enable insert for users based on user_id" ON public."user" FOR INSERT WITH CHECK ((( SELECT auth.uid() AS uid) = user_id));


--
-- Name: complaints Enable users to view their own data only; Type: POLICY; Schema: public; Owner: postgres
--

CREATE POLICY "Enable users to view their own data only" ON public.complaints FOR SELECT TO authenticated USING ((( SELECT auth.uid() AS uid) = complainant));


--
-- Name: complaint_actions Select only allowed; Type: POLICY; Schema: public; Owner: postgres
--

CREATE POLICY "Select only allowed" ON public.complaint_actions FOR SELECT TO authenticated USING ((EXISTS ( SELECT 1
   FROM public.complaints
  WHERE ((complaints.complaint_id = complaint_actions.complaint_id) AND (complaints.complainant = auth.uid()) AND (NOT complaint_actions.confidential)))));


--
-- Name: complaint_actions; Type: ROW SECURITY; Schema: public; Owner: postgres
--

ALTER TABLE public.complaint_actions ENABLE ROW LEVEL SECURITY;

--
-- Name: complaints; Type: ROW SECURITY; Schema: public; Owner: postgres
--

ALTER TABLE public.complaints ENABLE ROW LEVEL SECURITY;

--
-- Name: summary get all summaries; Type: POLICY; Schema: public; Owner: postgres
--

CREATE POLICY "get all summaries" ON public.summary FOR SELECT TO authenticated, anon USING ((hide = false));


--
-- Name: summary; Type: ROW SECURITY; Schema: public; Owner: postgres
--

ALTER TABLE public.summary ENABLE ROW LEVEL SECURITY;

--
-- Name: user; Type: ROW SECURITY; Schema: public; Owner: postgres
--

ALTER TABLE public."user" ENABLE ROW LEVEL SECURITY;

--
-- Name: messages; Type: ROW SECURITY; Schema: realtime; Owner: supabase_realtime_admin
--

ALTER TABLE realtime.messages ENABLE ROW LEVEL SECURITY;

--
-- Name: objects Give users access to own folder mmosip_0; Type: POLICY; Schema: storage; Owner: supabase_storage_admin
--

CREATE POLICY "Give users access to own folder mmosip_0" ON storage.objects FOR SELECT USING (((bucket_id = 'complaints_documents'::text) AND (( SELECT (auth.uid())::text AS uid) = (storage.foldername(name))[1])));


--
-- Name: objects Give users access to own folder mmosip_1; Type: POLICY; Schema: storage; Owner: supabase_storage_admin
--

CREATE POLICY "Give users access to own folder mmosip_1" ON storage.objects FOR INSERT WITH CHECK (((bucket_id = 'complaints_documents'::text) AND (( SELECT (auth.uid())::text AS uid) = (storage.foldername(name))[1])));


--
-- Name: buckets; Type: ROW SECURITY; Schema: storage; Owner: supabase_storage_admin
--

ALTER TABLE storage.buckets ENABLE ROW LEVEL SECURITY;

--
-- Name: migrations; Type: ROW SECURITY; Schema: storage; Owner: supabase_storage_admin
--

ALTER TABLE storage.migrations ENABLE ROW LEVEL SECURITY;

--
-- Name: objects; Type: ROW SECURITY; Schema: storage; Owner: supabase_storage_admin
--

ALTER TABLE storage.objects ENABLE ROW LEVEL SECURITY;

--
-- Name: s3_multipart_uploads; Type: ROW SECURITY; Schema: storage; Owner: supabase_storage_admin
--

ALTER TABLE storage.s3_multipart_uploads ENABLE ROW LEVEL SECURITY;

--
-- Name: s3_multipart_uploads_parts; Type: ROW SECURITY; Schema: storage; Owner: supabase_storage_admin
--

ALTER TABLE storage.s3_multipart_uploads_parts ENABLE ROW LEVEL SECURITY;

--
-- Name: supabase_realtime; Type: PUBLICATION; Schema: -; Owner: postgres
--

CREATE PUBLICATION supabase_realtime WITH (publish = 'insert, update, delete, truncate');


ALTER PUBLICATION supabase_realtime OWNER TO postgres;

--
-- Name: SCHEMA auth; Type: ACL; Schema: -; Owner: supabase_admin
--

GRANT USAGE ON SCHEMA auth TO anon;
GRANT USAGE ON SCHEMA auth TO authenticated;
GRANT USAGE ON SCHEMA auth TO service_role;
GRANT ALL ON SCHEMA auth TO supabase_auth_admin;
GRANT ALL ON SCHEMA auth TO dashboard_user;
GRANT ALL ON SCHEMA auth TO postgres;


--
-- Name: SCHEMA extensions; Type: ACL; Schema: -; Owner: postgres
--

GRANT USAGE ON SCHEMA extensions TO anon;
GRANT USAGE ON SCHEMA extensions TO authenticated;
GRANT USAGE ON SCHEMA extensions TO service_role;
GRANT ALL ON SCHEMA extensions TO dashboard_user;


--
-- Name: SCHEMA net; Type: ACL; Schema: -; Owner: supabase_admin
--

GRANT USAGE ON SCHEMA net TO supabase_functions_admin;
GRANT USAGE ON SCHEMA net TO postgres;
GRANT USAGE ON SCHEMA net TO anon;
GRANT USAGE ON SCHEMA net TO authenticated;
GRANT USAGE ON SCHEMA net TO service_role;


--
-- Name: SCHEMA public; Type: ACL; Schema: -; Owner: pg_database_owner
--

GRANT USAGE ON SCHEMA public TO postgres;
GRANT USAGE ON SCHEMA public TO anon;
GRANT USAGE ON SCHEMA public TO authenticated;
GRANT USAGE ON SCHEMA public TO service_role;


--
-- Name: SCHEMA realtime; Type: ACL; Schema: -; Owner: supabase_admin
--

GRANT USAGE ON SCHEMA realtime TO postgres;
GRANT USAGE ON SCHEMA realtime TO anon;
GRANT USAGE ON SCHEMA realtime TO authenticated;
GRANT USAGE ON SCHEMA realtime TO service_role;
GRANT ALL ON SCHEMA realtime TO supabase_realtime_admin;


--
-- Name: SCHEMA storage; Type: ACL; Schema: -; Owner: supabase_admin
--

GRANT ALL ON SCHEMA storage TO postgres;
GRANT USAGE ON SCHEMA storage TO anon;
GRANT USAGE ON SCHEMA storage TO authenticated;
GRANT USAGE ON SCHEMA storage TO service_role;
GRANT ALL ON SCHEMA storage TO supabase_storage_admin;
GRANT ALL ON SCHEMA storage TO dashboard_user;


--
-- Name: SCHEMA supabase_functions; Type: ACL; Schema: -; Owner: supabase_admin
--

GRANT USAGE ON SCHEMA supabase_functions TO postgres;
GRANT USAGE ON SCHEMA supabase_functions TO anon;
GRANT USAGE ON SCHEMA supabase_functions TO authenticated;
GRANT USAGE ON SCHEMA supabase_functions TO service_role;
GRANT ALL ON SCHEMA supabase_functions TO supabase_functions_admin;


--
-- Name: FUNCTION email(); Type: ACL; Schema: auth; Owner: supabase_auth_admin
--

GRANT ALL ON FUNCTION auth.email() TO dashboard_user;


--
-- Name: FUNCTION jwt(); Type: ACL; Schema: auth; Owner: supabase_auth_admin
--

GRANT ALL ON FUNCTION auth.jwt() TO postgres;
GRANT ALL ON FUNCTION auth.jwt() TO dashboard_user;


--
-- Name: FUNCTION role(); Type: ACL; Schema: auth; Owner: supabase_auth_admin
--

GRANT ALL ON FUNCTION auth.role() TO dashboard_user;


--
-- Name: FUNCTION uid(); Type: ACL; Schema: auth; Owner: supabase_auth_admin
--

GRANT ALL ON FUNCTION auth.uid() TO dashboard_user;


--
-- Name: FUNCTION algorithm_sign(signables text, secret text, algorithm text); Type: ACL; Schema: extensions; Owner: supabase_admin
--

GRANT ALL ON FUNCTION extensions.algorithm_sign(signables text, secret text, algorithm text) TO dashboard_user;
GRANT ALL ON FUNCTION extensions.algorithm_sign(signables text, secret text, algorithm text) TO postgres WITH GRANT OPTION;


--
-- Name: FUNCTION armor(bytea); Type: ACL; Schema: extensions; Owner: supabase_admin
--

GRANT ALL ON FUNCTION extensions.armor(bytea) TO dashboard_user;
GRANT ALL ON FUNCTION extensions.armor(bytea) TO postgres WITH GRANT OPTION;


--
-- Name: FUNCTION armor(bytea, text[], text[]); Type: ACL; Schema: extensions; Owner: supabase_admin
--

GRANT ALL ON FUNCTION extensions.armor(bytea, text[], text[]) TO dashboard_user;
GRANT ALL ON FUNCTION extensions.armor(bytea, text[], text[]) TO postgres WITH GRANT OPTION;


--
-- Name: FUNCTION crypt(text, text); Type: ACL; Schema: extensions; Owner: supabase_admin
--

GRANT ALL ON FUNCTION extensions.crypt(text, text) TO dashboard_user;
GRANT ALL ON FUNCTION extensions.crypt(text, text) TO postgres WITH GRANT OPTION;


--
-- Name: FUNCTION dearmor(text); Type: ACL; Schema: extensions; Owner: supabase_admin
--

GRANT ALL ON FUNCTION extensions.dearmor(text) TO dashboard_user;
GRANT ALL ON FUNCTION extensions.dearmor(text) TO postgres WITH GRANT OPTION;


--
-- Name: FUNCTION decrypt(bytea, bytea, text); Type: ACL; Schema: extensions; Owner: supabase_admin
--

GRANT ALL ON FUNCTION extensions.decrypt(bytea, bytea, text) TO dashboard_user;
GRANT ALL ON FUNCTION extensions.decrypt(bytea, bytea, text) TO postgres WITH GRANT OPTION;


--
-- Name: FUNCTION decrypt_iv(bytea, bytea, bytea, text); Type: ACL; Schema: extensions; Owner: supabase_admin
--

GRANT ALL ON FUNCTION extensions.decrypt_iv(bytea, bytea, bytea, text) TO dashboard_user;
GRANT ALL ON FUNCTION extensions.decrypt_iv(bytea, bytea, bytea, text) TO postgres WITH GRANT OPTION;


--
-- Name: FUNCTION digest(bytea, text); Type: ACL; Schema: extensions; Owner: supabase_admin
--

GRANT ALL ON FUNCTION extensions.digest(bytea, text) TO dashboard_user;
GRANT ALL ON FUNCTION extensions.digest(bytea, text) TO postgres WITH GRANT OPTION;


--
-- Name: FUNCTION digest(text, text); Type: ACL; Schema: extensions; Owner: supabase_admin
--

GRANT ALL ON FUNCTION extensions.digest(text, text) TO dashboard_user;
GRANT ALL ON FUNCTION extensions.digest(text, text) TO postgres WITH GRANT OPTION;


--
-- Name: FUNCTION encrypt(bytea, bytea, text); Type: ACL; Schema: extensions; Owner: supabase_admin
--

GRANT ALL ON FUNCTION extensions.encrypt(bytea, bytea, text) TO dashboard_user;
GRANT ALL ON FUNCTION extensions.encrypt(bytea, bytea, text) TO postgres WITH GRANT OPTION;


--
-- Name: FUNCTION encrypt_iv(bytea, bytea, bytea, text); Type: ACL; Schema: extensions; Owner: supabase_admin
--

GRANT ALL ON FUNCTION extensions.encrypt_iv(bytea, bytea, bytea, text) TO dashboard_user;
GRANT ALL ON FUNCTION extensions.encrypt_iv(bytea, bytea, bytea, text) TO postgres WITH GRANT OPTION;


--
-- Name: FUNCTION gen_random_bytes(integer); Type: ACL; Schema: extensions; Owner: supabase_admin
--

GRANT ALL ON FUNCTION extensions.gen_random_bytes(integer) TO dashboard_user;
GRANT ALL ON FUNCTION extensions.gen_random_bytes(integer) TO postgres WITH GRANT OPTION;


--
-- Name: FUNCTION gen_random_uuid(); Type: ACL; Schema: extensions; Owner: supabase_admin
--

GRANT ALL ON FUNCTION extensions.gen_random_uuid() TO dashboard_user;
GRANT ALL ON FUNCTION extensions.gen_random_uuid() TO postgres WITH GRANT OPTION;


--
-- Name: FUNCTION gen_salt(text); Type: ACL; Schema: extensions; Owner: supabase_admin
--

GRANT ALL ON FUNCTION extensions.gen_salt(text) TO dashboard_user;
GRANT ALL ON FUNCTION extensions.gen_salt(text) TO postgres WITH GRANT OPTION;


--
-- Name: FUNCTION gen_salt(text, integer); Type: ACL; Schema: extensions; Owner: supabase_admin
--

GRANT ALL ON FUNCTION extensions.gen_salt(text, integer) TO dashboard_user;
GRANT ALL ON FUNCTION extensions.gen_salt(text, integer) TO postgres WITH GRANT OPTION;


--
-- Name: FUNCTION grant_pg_cron_access(); Type: ACL; Schema: extensions; Owner: postgres
--

REVOKE ALL ON FUNCTION extensions.grant_pg_cron_access() FROM postgres;
GRANT ALL ON FUNCTION extensions.grant_pg_cron_access() TO postgres WITH GRANT OPTION;
GRANT ALL ON FUNCTION extensions.grant_pg_cron_access() TO dashboard_user;


--
-- Name: FUNCTION grant_pg_graphql_access(); Type: ACL; Schema: extensions; Owner: supabase_admin
--

GRANT ALL ON FUNCTION extensions.grant_pg_graphql_access() TO postgres WITH GRANT OPTION;


--
-- Name: FUNCTION grant_pg_net_access(); Type: ACL; Schema: extensions; Owner: postgres
--

REVOKE ALL ON FUNCTION extensions.grant_pg_net_access() FROM postgres;
GRANT ALL ON FUNCTION extensions.grant_pg_net_access() TO postgres WITH GRANT OPTION;
GRANT ALL ON FUNCTION extensions.grant_pg_net_access() TO dashboard_user;


--
-- Name: FUNCTION hmac(bytea, bytea, text); Type: ACL; Schema: extensions; Owner: supabase_admin
--

GRANT ALL ON FUNCTION extensions.hmac(bytea, bytea, text) TO dashboard_user;
GRANT ALL ON FUNCTION extensions.hmac(bytea, bytea, text) TO postgres WITH GRANT OPTION;


--
-- Name: FUNCTION hmac(text, text, text); Type: ACL; Schema: extensions; Owner: supabase_admin
--

GRANT ALL ON FUNCTION extensions.hmac(text, text, text) TO dashboard_user;
GRANT ALL ON FUNCTION extensions.hmac(text, text, text) TO postgres WITH GRANT OPTION;


--
-- Name: FUNCTION pg_stat_statements(showtext boolean, OUT userid oid, OUT dbid oid, OUT toplevel boolean, OUT queryid bigint, OUT query text, OUT plans bigint, OUT total_plan_time double precision, OUT min_plan_time double precision, OUT max_plan_time double precision, OUT mean_plan_time double precision, OUT stddev_plan_time double precision, OUT calls bigint, OUT total_exec_time double precision, OUT min_exec_time double precision, OUT max_exec_time double precision, OUT mean_exec_time double precision, OUT stddev_exec_time double precision, OUT rows bigint, OUT shared_blks_hit bigint, OUT shared_blks_read bigint, OUT shared_blks_dirtied bigint, OUT shared_blks_written bigint, OUT local_blks_hit bigint, OUT local_blks_read bigint, OUT local_blks_dirtied bigint, OUT local_blks_written bigint, OUT temp_blks_read bigint, OUT temp_blks_written bigint, OUT blk_read_time double precision, OUT blk_write_time double precision, OUT temp_blk_read_time double precision, OUT temp_blk_write_time double precision, OUT wal_records bigint, OUT wal_fpi bigint, OUT wal_bytes numeric, OUT jit_functions bigint, OUT jit_generation_time double precision, OUT jit_inlining_count bigint, OUT jit_inlining_time double precision, OUT jit_optimization_count bigint, OUT jit_optimization_time double precision, OUT jit_emission_count bigint, OUT jit_emission_time double precision); Type: ACL; Schema: extensions; Owner: supabase_admin
--

GRANT ALL ON FUNCTION extensions.pg_stat_statements(showtext boolean, OUT userid oid, OUT dbid oid, OUT toplevel boolean, OUT queryid bigint, OUT query text, OUT plans bigint, OUT total_plan_time double precision, OUT min_plan_time double precision, OUT max_plan_time double precision, OUT mean_plan_time double precision, OUT stddev_plan_time double precision, OUT calls bigint, OUT total_exec_time double precision, OUT min_exec_time double precision, OUT max_exec_time double precision, OUT mean_exec_time double precision, OUT stddev_exec_time double precision, OUT rows bigint, OUT shared_blks_hit bigint, OUT shared_blks_read bigint, OUT shared_blks_dirtied bigint, OUT shared_blks_written bigint, OUT local_blks_hit bigint, OUT local_blks_read bigint, OUT local_blks_dirtied bigint, OUT local_blks_written bigint, OUT temp_blks_read bigint, OUT temp_blks_written bigint, OUT blk_read_time double precision, OUT blk_write_time double precision, OUT temp_blk_read_time double precision, OUT temp_blk_write_time double precision, OUT wal_records bigint, OUT wal_fpi bigint, OUT wal_bytes numeric, OUT jit_functions bigint, OUT jit_generation_time double precision, OUT jit_inlining_count bigint, OUT jit_inlining_time double precision, OUT jit_optimization_count bigint, OUT jit_optimization_time double precision, OUT jit_emission_count bigint, OUT jit_emission_time double precision) TO postgres WITH GRANT OPTION;


--
-- Name: FUNCTION pg_stat_statements_info(OUT dealloc bigint, OUT stats_reset timestamp with time zone); Type: ACL; Schema: extensions; Owner: supabase_admin
--

GRANT ALL ON FUNCTION extensions.pg_stat_statements_info(OUT dealloc bigint, OUT stats_reset timestamp with time zone) TO postgres WITH GRANT OPTION;


--
-- Name: FUNCTION pg_stat_statements_reset(userid oid, dbid oid, queryid bigint); Type: ACL; Schema: extensions; Owner: supabase_admin
--

GRANT ALL ON FUNCTION extensions.pg_stat_statements_reset(userid oid, dbid oid, queryid bigint) TO postgres WITH GRANT OPTION;


--
-- Name: FUNCTION pgp_armor_headers(text, OUT key text, OUT value text); Type: ACL; Schema: extensions; Owner: supabase_admin
--

GRANT ALL ON FUNCTION extensions.pgp_armor_headers(text, OUT key text, OUT value text) TO dashboard_user;
GRANT ALL ON FUNCTION extensions.pgp_armor_headers(text, OUT key text, OUT value text) TO postgres WITH GRANT OPTION;


--
-- Name: FUNCTION pgp_key_id(bytea); Type: ACL; Schema: extensions; Owner: supabase_admin
--

GRANT ALL ON FUNCTION extensions.pgp_key_id(bytea) TO dashboard_user;
GRANT ALL ON FUNCTION extensions.pgp_key_id(bytea) TO postgres WITH GRANT OPTION;


--
-- Name: FUNCTION pgp_pub_decrypt(bytea, bytea); Type: ACL; Schema: extensions; Owner: supabase_admin
--

GRANT ALL ON FUNCTION extensions.pgp_pub_decrypt(bytea, bytea) TO dashboard_user;
GRANT ALL ON FUNCTION extensions.pgp_pub_decrypt(bytea, bytea) TO postgres WITH GRANT OPTION;


--
-- Name: FUNCTION pgp_pub_decrypt(bytea, bytea, text); Type: ACL; Schema: extensions; Owner: supabase_admin
--

GRANT ALL ON FUNCTION extensions.pgp_pub_decrypt(bytea, bytea, text) TO dashboard_user;
GRANT ALL ON FUNCTION extensions.pgp_pub_decrypt(bytea, bytea, text) TO postgres WITH GRANT OPTION;


--
-- Name: FUNCTION pgp_pub_decrypt(bytea, bytea, text, text); Type: ACL; Schema: extensions; Owner: supabase_admin
--

GRANT ALL ON FUNCTION extensions.pgp_pub_decrypt(bytea, bytea, text, text) TO dashboard_user;
GRANT ALL ON FUNCTION extensions.pgp_pub_decrypt(bytea, bytea, text, text) TO postgres WITH GRANT OPTION;


--
-- Name: FUNCTION pgp_pub_decrypt_bytea(bytea, bytea); Type: ACL; Schema: extensions; Owner: supabase_admin
--

GRANT ALL ON FUNCTION extensions.pgp_pub_decrypt_bytea(bytea, bytea) TO dashboard_user;
GRANT ALL ON FUNCTION extensions.pgp_pub_decrypt_bytea(bytea, bytea) TO postgres WITH GRANT OPTION;


--
-- Name: FUNCTION pgp_pub_decrypt_bytea(bytea, bytea, text); Type: ACL; Schema: extensions; Owner: supabase_admin
--

GRANT ALL ON FUNCTION extensions.pgp_pub_decrypt_bytea(bytea, bytea, text) TO dashboard_user;
GRANT ALL ON FUNCTION extensions.pgp_pub_decrypt_bytea(bytea, bytea, text) TO postgres WITH GRANT OPTION;


--
-- Name: FUNCTION pgp_pub_decrypt_bytea(bytea, bytea, text, text); Type: ACL; Schema: extensions; Owner: supabase_admin
--

GRANT ALL ON FUNCTION extensions.pgp_pub_decrypt_bytea(bytea, bytea, text, text) TO dashboard_user;
GRANT ALL ON FUNCTION extensions.pgp_pub_decrypt_bytea(bytea, bytea, text, text) TO postgres WITH GRANT OPTION;


--
-- Name: FUNCTION pgp_pub_encrypt(text, bytea); Type: ACL; Schema: extensions; Owner: supabase_admin
--

GRANT ALL ON FUNCTION extensions.pgp_pub_encrypt(text, bytea) TO dashboard_user;
GRANT ALL ON FUNCTION extensions.pgp_pub_encrypt(text, bytea) TO postgres WITH GRANT OPTION;


--
-- Name: FUNCTION pgp_pub_encrypt(text, bytea, text); Type: ACL; Schema: extensions; Owner: supabase_admin
--

GRANT ALL ON FUNCTION extensions.pgp_pub_encrypt(text, bytea, text) TO dashboard_user;
GRANT ALL ON FUNCTION extensions.pgp_pub_encrypt(text, bytea, text) TO postgres WITH GRANT OPTION;


--
-- Name: FUNCTION pgp_pub_encrypt_bytea(bytea, bytea); Type: ACL; Schema: extensions; Owner: supabase_admin
--

GRANT ALL ON FUNCTION extensions.pgp_pub_encrypt_bytea(bytea, bytea) TO dashboard_user;
GRANT ALL ON FUNCTION extensions.pgp_pub_encrypt_bytea(bytea, bytea) TO postgres WITH GRANT OPTION;


--
-- Name: FUNCTION pgp_pub_encrypt_bytea(bytea, bytea, text); Type: ACL; Schema: extensions; Owner: supabase_admin
--

GRANT ALL ON FUNCTION extensions.pgp_pub_encrypt_bytea(bytea, bytea, text) TO dashboard_user;
GRANT ALL ON FUNCTION extensions.pgp_pub_encrypt_bytea(bytea, bytea, text) TO postgres WITH GRANT OPTION;


--
-- Name: FUNCTION pgp_sym_decrypt(bytea, text); Type: ACL; Schema: extensions; Owner: supabase_admin
--

GRANT ALL ON FUNCTION extensions.pgp_sym_decrypt(bytea, text) TO dashboard_user;
GRANT ALL ON FUNCTION extensions.pgp_sym_decrypt(bytea, text) TO postgres WITH GRANT OPTION;


--
-- Name: FUNCTION pgp_sym_decrypt(bytea, text, text); Type: ACL; Schema: extensions; Owner: supabase_admin
--

GRANT ALL ON FUNCTION extensions.pgp_sym_decrypt(bytea, text, text) TO dashboard_user;
GRANT ALL ON FUNCTION extensions.pgp_sym_decrypt(bytea, text, text) TO postgres WITH GRANT OPTION;


--
-- Name: FUNCTION pgp_sym_decrypt_bytea(bytea, text); Type: ACL; Schema: extensions; Owner: supabase_admin
--

GRANT ALL ON FUNCTION extensions.pgp_sym_decrypt_bytea(bytea, text) TO dashboard_user;
GRANT ALL ON FUNCTION extensions.pgp_sym_decrypt_bytea(bytea, text) TO postgres WITH GRANT OPTION;


--
-- Name: FUNCTION pgp_sym_decrypt_bytea(bytea, text, text); Type: ACL; Schema: extensions; Owner: supabase_admin
--

GRANT ALL ON FUNCTION extensions.pgp_sym_decrypt_bytea(bytea, text, text) TO dashboard_user;
GRANT ALL ON FUNCTION extensions.pgp_sym_decrypt_bytea(bytea, text, text) TO postgres WITH GRANT OPTION;


--
-- Name: FUNCTION pgp_sym_encrypt(text, text); Type: ACL; Schema: extensions; Owner: supabase_admin
--

GRANT ALL ON FUNCTION extensions.pgp_sym_encrypt(text, text) TO dashboard_user;
GRANT ALL ON FUNCTION extensions.pgp_sym_encrypt(text, text) TO postgres WITH GRANT OPTION;


--
-- Name: FUNCTION pgp_sym_encrypt(text, text, text); Type: ACL; Schema: extensions; Owner: supabase_admin
--

GRANT ALL ON FUNCTION extensions.pgp_sym_encrypt(text, text, text) TO dashboard_user;
GRANT ALL ON FUNCTION extensions.pgp_sym_encrypt(text, text, text) TO postgres WITH GRANT OPTION;


--
-- Name: FUNCTION pgp_sym_encrypt_bytea(bytea, text); Type: ACL; Schema: extensions; Owner: supabase_admin
--

GRANT ALL ON FUNCTION extensions.pgp_sym_encrypt_bytea(bytea, text) TO dashboard_user;
GRANT ALL ON FUNCTION extensions.pgp_sym_encrypt_bytea(bytea, text) TO postgres WITH GRANT OPTION;


--
-- Name: FUNCTION pgp_sym_encrypt_bytea(bytea, text, text); Type: ACL; Schema: extensions; Owner: supabase_admin
--

GRANT ALL ON FUNCTION extensions.pgp_sym_encrypt_bytea(bytea, text, text) TO dashboard_user;
GRANT ALL ON FUNCTION extensions.pgp_sym_encrypt_bytea(bytea, text, text) TO postgres WITH GRANT OPTION;


--
-- Name: FUNCTION pgrst_ddl_watch(); Type: ACL; Schema: extensions; Owner: supabase_admin
--

GRANT ALL ON FUNCTION extensions.pgrst_ddl_watch() TO postgres WITH GRANT OPTION;


--
-- Name: FUNCTION pgrst_drop_watch(); Type: ACL; Schema: extensions; Owner: supabase_admin
--

GRANT ALL ON FUNCTION extensions.pgrst_drop_watch() TO postgres WITH GRANT OPTION;


--
-- Name: FUNCTION set_graphql_placeholder(); Type: ACL; Schema: extensions; Owner: supabase_admin
--

GRANT ALL ON FUNCTION extensions.set_graphql_placeholder() TO postgres WITH GRANT OPTION;


--
-- Name: FUNCTION sign(payload json, secret text, algorithm text); Type: ACL; Schema: extensions; Owner: supabase_admin
--

GRANT ALL ON FUNCTION extensions.sign(payload json, secret text, algorithm text) TO dashboard_user;
GRANT ALL ON FUNCTION extensions.sign(payload json, secret text, algorithm text) TO postgres WITH GRANT OPTION;


--
-- Name: FUNCTION try_cast_double(inp text); Type: ACL; Schema: extensions; Owner: supabase_admin
--

GRANT ALL ON FUNCTION extensions.try_cast_double(inp text) TO dashboard_user;
GRANT ALL ON FUNCTION extensions.try_cast_double(inp text) TO postgres WITH GRANT OPTION;


--
-- Name: FUNCTION url_decode(data text); Type: ACL; Schema: extensions; Owner: supabase_admin
--

GRANT ALL ON FUNCTION extensions.url_decode(data text) TO dashboard_user;
GRANT ALL ON FUNCTION extensions.url_decode(data text) TO postgres WITH GRANT OPTION;


--
-- Name: FUNCTION url_encode(data bytea); Type: ACL; Schema: extensions; Owner: supabase_admin
--

GRANT ALL ON FUNCTION extensions.url_encode(data bytea) TO dashboard_user;
GRANT ALL ON FUNCTION extensions.url_encode(data bytea) TO postgres WITH GRANT OPTION;


--
-- Name: FUNCTION uuid_generate_v1(); Type: ACL; Schema: extensions; Owner: supabase_admin
--

GRANT ALL ON FUNCTION extensions.uuid_generate_v1() TO dashboard_user;
GRANT ALL ON FUNCTION extensions.uuid_generate_v1() TO postgres WITH GRANT OPTION;


--
-- Name: FUNCTION uuid_generate_v1mc(); Type: ACL; Schema: extensions; Owner: supabase_admin
--

GRANT ALL ON FUNCTION extensions.uuid_generate_v1mc() TO dashboard_user;
GRANT ALL ON FUNCTION extensions.uuid_generate_v1mc() TO postgres WITH GRANT OPTION;


--
-- Name: FUNCTION uuid_generate_v3(namespace uuid, name text); Type: ACL; Schema: extensions; Owner: supabase_admin
--

GRANT ALL ON FUNCTION extensions.uuid_generate_v3(namespace uuid, name text) TO dashboard_user;
GRANT ALL ON FUNCTION extensions.uuid_generate_v3(namespace uuid, name text) TO postgres WITH GRANT OPTION;


--
-- Name: FUNCTION uuid_generate_v4(); Type: ACL; Schema: extensions; Owner: supabase_admin
--

GRANT ALL ON FUNCTION extensions.uuid_generate_v4() TO dashboard_user;
GRANT ALL ON FUNCTION extensions.uuid_generate_v4() TO postgres WITH GRANT OPTION;


--
-- Name: FUNCTION uuid_generate_v5(namespace uuid, name text); Type: ACL; Schema: extensions; Owner: supabase_admin
--

GRANT ALL ON FUNCTION extensions.uuid_generate_v5(namespace uuid, name text) TO dashboard_user;
GRANT ALL ON FUNCTION extensions.uuid_generate_v5(namespace uuid, name text) TO postgres WITH GRANT OPTION;


--
-- Name: FUNCTION uuid_nil(); Type: ACL; Schema: extensions; Owner: supabase_admin
--

GRANT ALL ON FUNCTION extensions.uuid_nil() TO dashboard_user;
GRANT ALL ON FUNCTION extensions.uuid_nil() TO postgres WITH GRANT OPTION;


--
-- Name: FUNCTION uuid_ns_dns(); Type: ACL; Schema: extensions; Owner: supabase_admin
--

GRANT ALL ON FUNCTION extensions.uuid_ns_dns() TO dashboard_user;
GRANT ALL ON FUNCTION extensions.uuid_ns_dns() TO postgres WITH GRANT OPTION;


--
-- Name: FUNCTION uuid_ns_oid(); Type: ACL; Schema: extensions; Owner: supabase_admin
--

GRANT ALL ON FUNCTION extensions.uuid_ns_oid() TO dashboard_user;
GRANT ALL ON FUNCTION extensions.uuid_ns_oid() TO postgres WITH GRANT OPTION;


--
-- Name: FUNCTION uuid_ns_url(); Type: ACL; Schema: extensions; Owner: supabase_admin
--

GRANT ALL ON FUNCTION extensions.uuid_ns_url() TO dashboard_user;
GRANT ALL ON FUNCTION extensions.uuid_ns_url() TO postgres WITH GRANT OPTION;


--
-- Name: FUNCTION uuid_ns_x500(); Type: ACL; Schema: extensions; Owner: supabase_admin
--

GRANT ALL ON FUNCTION extensions.uuid_ns_x500() TO dashboard_user;
GRANT ALL ON FUNCTION extensions.uuid_ns_x500() TO postgres WITH GRANT OPTION;


--
-- Name: FUNCTION verify(token text, secret text, algorithm text); Type: ACL; Schema: extensions; Owner: supabase_admin
--

GRANT ALL ON FUNCTION extensions.verify(token text, secret text, algorithm text) TO dashboard_user;
GRANT ALL ON FUNCTION extensions.verify(token text, secret text, algorithm text) TO postgres WITH GRANT OPTION;


--
-- Name: FUNCTION graphql("operationName" text, query text, variables jsonb, extensions jsonb); Type: ACL; Schema: graphql_public; Owner: supabase_admin
--

GRANT ALL ON FUNCTION graphql_public.graphql("operationName" text, query text, variables jsonb, extensions jsonb) TO postgres;
GRANT ALL ON FUNCTION graphql_public.graphql("operationName" text, query text, variables jsonb, extensions jsonb) TO anon;
GRANT ALL ON FUNCTION graphql_public.graphql("operationName" text, query text, variables jsonb, extensions jsonb) TO authenticated;
GRANT ALL ON FUNCTION graphql_public.graphql("operationName" text, query text, variables jsonb, extensions jsonb) TO service_role;


--
-- Name: FUNCTION http_get(url text, params jsonb, headers jsonb, timeout_milliseconds integer); Type: ACL; Schema: net; Owner: supabase_admin
--

REVOKE ALL ON FUNCTION net.http_get(url text, params jsonb, headers jsonb, timeout_milliseconds integer) FROM PUBLIC;
GRANT ALL ON FUNCTION net.http_get(url text, params jsonb, headers jsonb, timeout_milliseconds integer) TO supabase_functions_admin;
GRANT ALL ON FUNCTION net.http_get(url text, params jsonb, headers jsonb, timeout_milliseconds integer) TO postgres;
GRANT ALL ON FUNCTION net.http_get(url text, params jsonb, headers jsonb, timeout_milliseconds integer) TO anon;
GRANT ALL ON FUNCTION net.http_get(url text, params jsonb, headers jsonb, timeout_milliseconds integer) TO authenticated;
GRANT ALL ON FUNCTION net.http_get(url text, params jsonb, headers jsonb, timeout_milliseconds integer) TO service_role;


--
-- Name: FUNCTION http_post(url text, body jsonb, params jsonb, headers jsonb, timeout_milliseconds integer); Type: ACL; Schema: net; Owner: supabase_admin
--

REVOKE ALL ON FUNCTION net.http_post(url text, body jsonb, params jsonb, headers jsonb, timeout_milliseconds integer) FROM PUBLIC;
GRANT ALL ON FUNCTION net.http_post(url text, body jsonb, params jsonb, headers jsonb, timeout_milliseconds integer) TO supabase_functions_admin;
GRANT ALL ON FUNCTION net.http_post(url text, body jsonb, params jsonb, headers jsonb, timeout_milliseconds integer) TO postgres;
GRANT ALL ON FUNCTION net.http_post(url text, body jsonb, params jsonb, headers jsonb, timeout_milliseconds integer) TO anon;
GRANT ALL ON FUNCTION net.http_post(url text, body jsonb, params jsonb, headers jsonb, timeout_milliseconds integer) TO authenticated;
GRANT ALL ON FUNCTION net.http_post(url text, body jsonb, params jsonb, headers jsonb, timeout_milliseconds integer) TO service_role;


--
-- Name: FUNCTION get_auth(p_usename text); Type: ACL; Schema: pgbouncer; Owner: postgres
--

REVOKE ALL ON FUNCTION pgbouncer.get_auth(p_usename text) FROM PUBLIC;
GRANT ALL ON FUNCTION pgbouncer.get_auth(p_usename text) TO pgbouncer;


--
-- Name: FUNCTION crypto_aead_det_decrypt(message bytea, additional bytea, key_uuid uuid, nonce bytea); Type: ACL; Schema: pgsodium; Owner: pgsodium_keymaker
--

GRANT ALL ON FUNCTION pgsodium.crypto_aead_det_decrypt(message bytea, additional bytea, key_uuid uuid, nonce bytea) TO service_role;


--
-- Name: FUNCTION crypto_aead_det_encrypt(message bytea, additional bytea, key_uuid uuid, nonce bytea); Type: ACL; Schema: pgsodium; Owner: pgsodium_keymaker
--

GRANT ALL ON FUNCTION pgsodium.crypto_aead_det_encrypt(message bytea, additional bytea, key_uuid uuid, nonce bytea) TO service_role;


--
-- Name: FUNCTION crypto_aead_det_keygen(); Type: ACL; Schema: pgsodium; Owner: supabase_admin
--

GRANT ALL ON FUNCTION pgsodium.crypto_aead_det_keygen() TO service_role;


--
-- Name: FUNCTION apply_rls(wal jsonb, max_record_bytes integer); Type: ACL; Schema: realtime; Owner: supabase_admin
--

GRANT ALL ON FUNCTION realtime.apply_rls(wal jsonb, max_record_bytes integer) TO postgres;
GRANT ALL ON FUNCTION realtime.apply_rls(wal jsonb, max_record_bytes integer) TO dashboard_user;
GRANT ALL ON FUNCTION realtime.apply_rls(wal jsonb, max_record_bytes integer) TO anon;
GRANT ALL ON FUNCTION realtime.apply_rls(wal jsonb, max_record_bytes integer) TO authenticated;
GRANT ALL ON FUNCTION realtime.apply_rls(wal jsonb, max_record_bytes integer) TO service_role;
GRANT ALL ON FUNCTION realtime.apply_rls(wal jsonb, max_record_bytes integer) TO supabase_realtime_admin;


--
-- Name: FUNCTION broadcast_changes(topic_name text, event_name text, operation text, table_name text, table_schema text, new record, old record, level text); Type: ACL; Schema: realtime; Owner: supabase_admin
--

GRANT ALL ON FUNCTION realtime.broadcast_changes(topic_name text, event_name text, operation text, table_name text, table_schema text, new record, old record, level text) TO postgres;
GRANT ALL ON FUNCTION realtime.broadcast_changes(topic_name text, event_name text, operation text, table_name text, table_schema text, new record, old record, level text) TO dashboard_user;


--
-- Name: FUNCTION build_prepared_statement_sql(prepared_statement_name text, entity regclass, columns realtime.wal_column[]); Type: ACL; Schema: realtime; Owner: supabase_admin
--

GRANT ALL ON FUNCTION realtime.build_prepared_statement_sql(prepared_statement_name text, entity regclass, columns realtime.wal_column[]) TO postgres;
GRANT ALL ON FUNCTION realtime.build_prepared_statement_sql(prepared_statement_name text, entity regclass, columns realtime.wal_column[]) TO dashboard_user;
GRANT ALL ON FUNCTION realtime.build_prepared_statement_sql(prepared_statement_name text, entity regclass, columns realtime.wal_column[]) TO anon;
GRANT ALL ON FUNCTION realtime.build_prepared_statement_sql(prepared_statement_name text, entity regclass, columns realtime.wal_column[]) TO authenticated;
GRANT ALL ON FUNCTION realtime.build_prepared_statement_sql(prepared_statement_name text, entity regclass, columns realtime.wal_column[]) TO service_role;
GRANT ALL ON FUNCTION realtime.build_prepared_statement_sql(prepared_statement_name text, entity regclass, columns realtime.wal_column[]) TO supabase_realtime_admin;


--
-- Name: FUNCTION "cast"(val text, type_ regtype); Type: ACL; Schema: realtime; Owner: supabase_admin
--

GRANT ALL ON FUNCTION realtime."cast"(val text, type_ regtype) TO postgres;
GRANT ALL ON FUNCTION realtime."cast"(val text, type_ regtype) TO dashboard_user;
GRANT ALL ON FUNCTION realtime."cast"(val text, type_ regtype) TO anon;
GRANT ALL ON FUNCTION realtime."cast"(val text, type_ regtype) TO authenticated;
GRANT ALL ON FUNCTION realtime."cast"(val text, type_ regtype) TO service_role;
GRANT ALL ON FUNCTION realtime."cast"(val text, type_ regtype) TO supabase_realtime_admin;


--
-- Name: FUNCTION check_equality_op(op realtime.equality_op, type_ regtype, val_1 text, val_2 text); Type: ACL; Schema: realtime; Owner: supabase_admin
--

GRANT ALL ON FUNCTION realtime.check_equality_op(op realtime.equality_op, type_ regtype, val_1 text, val_2 text) TO postgres;
GRANT ALL ON FUNCTION realtime.check_equality_op(op realtime.equality_op, type_ regtype, val_1 text, val_2 text) TO dashboard_user;
GRANT ALL ON FUNCTION realtime.check_equality_op(op realtime.equality_op, type_ regtype, val_1 text, val_2 text) TO anon;
GRANT ALL ON FUNCTION realtime.check_equality_op(op realtime.equality_op, type_ regtype, val_1 text, val_2 text) TO authenticated;
GRANT ALL ON FUNCTION realtime.check_equality_op(op realtime.equality_op, type_ regtype, val_1 text, val_2 text) TO service_role;
GRANT ALL ON FUNCTION realtime.check_equality_op(op realtime.equality_op, type_ regtype, val_1 text, val_2 text) TO supabase_realtime_admin;


--
-- Name: FUNCTION is_visible_through_filters(columns realtime.wal_column[], filters realtime.user_defined_filter[]); Type: ACL; Schema: realtime; Owner: supabase_admin
--

GRANT ALL ON FUNCTION realtime.is_visible_through_filters(columns realtime.wal_column[], filters realtime.user_defined_filter[]) TO postgres;
GRANT ALL ON FUNCTION realtime.is_visible_through_filters(columns realtime.wal_column[], filters realtime.user_defined_filter[]) TO dashboard_user;
GRANT ALL ON FUNCTION realtime.is_visible_through_filters(columns realtime.wal_column[], filters realtime.user_defined_filter[]) TO anon;
GRANT ALL ON FUNCTION realtime.is_visible_through_filters(columns realtime.wal_column[], filters realtime.user_defined_filter[]) TO authenticated;
GRANT ALL ON FUNCTION realtime.is_visible_through_filters(columns realtime.wal_column[], filters realtime.user_defined_filter[]) TO service_role;
GRANT ALL ON FUNCTION realtime.is_visible_through_filters(columns realtime.wal_column[], filters realtime.user_defined_filter[]) TO supabase_realtime_admin;


--
-- Name: FUNCTION list_changes(publication name, slot_name name, max_changes integer, max_record_bytes integer); Type: ACL; Schema: realtime; Owner: supabase_admin
--

GRANT ALL ON FUNCTION realtime.list_changes(publication name, slot_name name, max_changes integer, max_record_bytes integer) TO postgres;
GRANT ALL ON FUNCTION realtime.list_changes(publication name, slot_name name, max_changes integer, max_record_bytes integer) TO dashboard_user;
GRANT ALL ON FUNCTION realtime.list_changes(publication name, slot_name name, max_changes integer, max_record_bytes integer) TO anon;
GRANT ALL ON FUNCTION realtime.list_changes(publication name, slot_name name, max_changes integer, max_record_bytes integer) TO authenticated;
GRANT ALL ON FUNCTION realtime.list_changes(publication name, slot_name name, max_changes integer, max_record_bytes integer) TO service_role;
GRANT ALL ON FUNCTION realtime.list_changes(publication name, slot_name name, max_changes integer, max_record_bytes integer) TO supabase_realtime_admin;


--
-- Name: FUNCTION quote_wal2json(entity regclass); Type: ACL; Schema: realtime; Owner: supabase_admin
--

GRANT ALL ON FUNCTION realtime.quote_wal2json(entity regclass) TO postgres;
GRANT ALL ON FUNCTION realtime.quote_wal2json(entity regclass) TO dashboard_user;
GRANT ALL ON FUNCTION realtime.quote_wal2json(entity regclass) TO anon;
GRANT ALL ON FUNCTION realtime.quote_wal2json(entity regclass) TO authenticated;
GRANT ALL ON FUNCTION realtime.quote_wal2json(entity regclass) TO service_role;
GRANT ALL ON FUNCTION realtime.quote_wal2json(entity regclass) TO supabase_realtime_admin;


--
-- Name: FUNCTION send(payload jsonb, event text, topic text, private boolean); Type: ACL; Schema: realtime; Owner: supabase_admin
--

GRANT ALL ON FUNCTION realtime.send(payload jsonb, event text, topic text, private boolean) TO postgres;
GRANT ALL ON FUNCTION realtime.send(payload jsonb, event text, topic text, private boolean) TO dashboard_user;


--
-- Name: FUNCTION subscription_check_filters(); Type: ACL; Schema: realtime; Owner: supabase_admin
--

GRANT ALL ON FUNCTION realtime.subscription_check_filters() TO postgres;
GRANT ALL ON FUNCTION realtime.subscription_check_filters() TO dashboard_user;
GRANT ALL ON FUNCTION realtime.subscription_check_filters() TO anon;
GRANT ALL ON FUNCTION realtime.subscription_check_filters() TO authenticated;
GRANT ALL ON FUNCTION realtime.subscription_check_filters() TO service_role;
GRANT ALL ON FUNCTION realtime.subscription_check_filters() TO supabase_realtime_admin;


--
-- Name: FUNCTION to_regrole(role_name text); Type: ACL; Schema: realtime; Owner: supabase_admin
--

GRANT ALL ON FUNCTION realtime.to_regrole(role_name text) TO postgres;
GRANT ALL ON FUNCTION realtime.to_regrole(role_name text) TO dashboard_user;
GRANT ALL ON FUNCTION realtime.to_regrole(role_name text) TO anon;
GRANT ALL ON FUNCTION realtime.to_regrole(role_name text) TO authenticated;
GRANT ALL ON FUNCTION realtime.to_regrole(role_name text) TO service_role;
GRANT ALL ON FUNCTION realtime.to_regrole(role_name text) TO supabase_realtime_admin;


--
-- Name: FUNCTION topic(); Type: ACL; Schema: realtime; Owner: supabase_realtime_admin
--

GRANT ALL ON FUNCTION realtime.topic() TO postgres;
GRANT ALL ON FUNCTION realtime.topic() TO dashboard_user;


--
-- Name: FUNCTION http_request(); Type: ACL; Schema: supabase_functions; Owner: supabase_functions_admin
--

REVOKE ALL ON FUNCTION supabase_functions.http_request() FROM PUBLIC;
GRANT ALL ON FUNCTION supabase_functions.http_request() TO postgres;
GRANT ALL ON FUNCTION supabase_functions.http_request() TO anon;
GRANT ALL ON FUNCTION supabase_functions.http_request() TO authenticated;
GRANT ALL ON FUNCTION supabase_functions.http_request() TO service_role;


--
-- Name: TABLE audit_log_entries; Type: ACL; Schema: auth; Owner: supabase_auth_admin
--

GRANT ALL ON TABLE auth.audit_log_entries TO dashboard_user;
GRANT INSERT,REFERENCES,DELETE,TRIGGER,TRUNCATE,UPDATE ON TABLE auth.audit_log_entries TO postgres;
GRANT SELECT ON TABLE auth.audit_log_entries TO postgres WITH GRANT OPTION;


--
-- Name: TABLE flow_state; Type: ACL; Schema: auth; Owner: supabase_auth_admin
--

GRANT INSERT,REFERENCES,DELETE,TRIGGER,TRUNCATE,UPDATE ON TABLE auth.flow_state TO postgres;
GRANT SELECT ON TABLE auth.flow_state TO postgres WITH GRANT OPTION;
GRANT ALL ON TABLE auth.flow_state TO dashboard_user;


--
-- Name: TABLE identities; Type: ACL; Schema: auth; Owner: supabase_auth_admin
--

GRANT INSERT,REFERENCES,DELETE,TRIGGER,TRUNCATE,UPDATE ON TABLE auth.identities TO postgres;
GRANT SELECT ON TABLE auth.identities TO postgres WITH GRANT OPTION;
GRANT ALL ON TABLE auth.identities TO dashboard_user;


--
-- Name: TABLE instances; Type: ACL; Schema: auth; Owner: supabase_auth_admin
--

GRANT ALL ON TABLE auth.instances TO dashboard_user;
GRANT INSERT,REFERENCES,DELETE,TRIGGER,TRUNCATE,UPDATE ON TABLE auth.instances TO postgres;
GRANT SELECT ON TABLE auth.instances TO postgres WITH GRANT OPTION;


--
-- Name: TABLE mfa_amr_claims; Type: ACL; Schema: auth; Owner: supabase_auth_admin
--

GRANT INSERT,REFERENCES,DELETE,TRIGGER,TRUNCATE,UPDATE ON TABLE auth.mfa_amr_claims TO postgres;
GRANT SELECT ON TABLE auth.mfa_amr_claims TO postgres WITH GRANT OPTION;
GRANT ALL ON TABLE auth.mfa_amr_claims TO dashboard_user;


--
-- Name: TABLE mfa_challenges; Type: ACL; Schema: auth; Owner: supabase_auth_admin
--

GRANT INSERT,REFERENCES,DELETE,TRIGGER,TRUNCATE,UPDATE ON TABLE auth.mfa_challenges TO postgres;
GRANT SELECT ON TABLE auth.mfa_challenges TO postgres WITH GRANT OPTION;
GRANT ALL ON TABLE auth.mfa_challenges TO dashboard_user;


--
-- Name: TABLE mfa_factors; Type: ACL; Schema: auth; Owner: supabase_auth_admin
--

GRANT INSERT,REFERENCES,DELETE,TRIGGER,TRUNCATE,UPDATE ON TABLE auth.mfa_factors TO postgres;
GRANT SELECT ON TABLE auth.mfa_factors TO postgres WITH GRANT OPTION;
GRANT ALL ON TABLE auth.mfa_factors TO dashboard_user;


--
-- Name: TABLE one_time_tokens; Type: ACL; Schema: auth; Owner: supabase_auth_admin
--

GRANT INSERT,REFERENCES,DELETE,TRIGGER,TRUNCATE,UPDATE ON TABLE auth.one_time_tokens TO postgres;
GRANT SELECT ON TABLE auth.one_time_tokens TO postgres WITH GRANT OPTION;
GRANT ALL ON TABLE auth.one_time_tokens TO dashboard_user;


--
-- Name: TABLE refresh_tokens; Type: ACL; Schema: auth; Owner: supabase_auth_admin
--

GRANT ALL ON TABLE auth.refresh_tokens TO dashboard_user;
GRANT INSERT,REFERENCES,DELETE,TRIGGER,TRUNCATE,UPDATE ON TABLE auth.refresh_tokens TO postgres;
GRANT SELECT ON TABLE auth.refresh_tokens TO postgres WITH GRANT OPTION;


--
-- Name: SEQUENCE refresh_tokens_id_seq; Type: ACL; Schema: auth; Owner: supabase_auth_admin
--

GRANT ALL ON SEQUENCE auth.refresh_tokens_id_seq TO dashboard_user;
GRANT ALL ON SEQUENCE auth.refresh_tokens_id_seq TO postgres;


--
-- Name: TABLE saml_providers; Type: ACL; Schema: auth; Owner: supabase_auth_admin
--

GRANT INSERT,REFERENCES,DELETE,TRIGGER,TRUNCATE,UPDATE ON TABLE auth.saml_providers TO postgres;
GRANT SELECT ON TABLE auth.saml_providers TO postgres WITH GRANT OPTION;
GRANT ALL ON TABLE auth.saml_providers TO dashboard_user;


--
-- Name: TABLE saml_relay_states; Type: ACL; Schema: auth; Owner: supabase_auth_admin
--

GRANT INSERT,REFERENCES,DELETE,TRIGGER,TRUNCATE,UPDATE ON TABLE auth.saml_relay_states TO postgres;
GRANT SELECT ON TABLE auth.saml_relay_states TO postgres WITH GRANT OPTION;
GRANT ALL ON TABLE auth.saml_relay_states TO dashboard_user;


--
-- Name: TABLE schema_migrations; Type: ACL; Schema: auth; Owner: supabase_auth_admin
--

GRANT ALL ON TABLE auth.schema_migrations TO dashboard_user;
GRANT INSERT,REFERENCES,DELETE,TRIGGER,TRUNCATE,UPDATE ON TABLE auth.schema_migrations TO postgres;
GRANT SELECT ON TABLE auth.schema_migrations TO postgres WITH GRANT OPTION;


--
-- Name: TABLE sessions; Type: ACL; Schema: auth; Owner: supabase_auth_admin
--

GRANT INSERT,REFERENCES,DELETE,TRIGGER,TRUNCATE,UPDATE ON TABLE auth.sessions TO postgres;
GRANT SELECT ON TABLE auth.sessions TO postgres WITH GRANT OPTION;
GRANT ALL ON TABLE auth.sessions TO dashboard_user;


--
-- Name: TABLE sso_domains; Type: ACL; Schema: auth; Owner: supabase_auth_admin
--

GRANT INSERT,REFERENCES,DELETE,TRIGGER,TRUNCATE,UPDATE ON TABLE auth.sso_domains TO postgres;
GRANT SELECT ON TABLE auth.sso_domains TO postgres WITH GRANT OPTION;
GRANT ALL ON TABLE auth.sso_domains TO dashboard_user;


--
-- Name: TABLE sso_providers; Type: ACL; Schema: auth; Owner: supabase_auth_admin
--

GRANT INSERT,REFERENCES,DELETE,TRIGGER,TRUNCATE,UPDATE ON TABLE auth.sso_providers TO postgres;
GRANT SELECT ON TABLE auth.sso_providers TO postgres WITH GRANT OPTION;
GRANT ALL ON TABLE auth.sso_providers TO dashboard_user;


--
-- Name: TABLE users; Type: ACL; Schema: auth; Owner: supabase_auth_admin
--

GRANT ALL ON TABLE auth.users TO dashboard_user;
GRANT INSERT,REFERENCES,DELETE,TRIGGER,TRUNCATE,UPDATE ON TABLE auth.users TO postgres;
GRANT SELECT ON TABLE auth.users TO postgres WITH GRANT OPTION;


--
-- Name: TABLE pg_stat_statements; Type: ACL; Schema: extensions; Owner: supabase_admin
--

GRANT ALL ON TABLE extensions.pg_stat_statements TO postgres WITH GRANT OPTION;


--
-- Name: TABLE pg_stat_statements_info; Type: ACL; Schema: extensions; Owner: supabase_admin
--

GRANT ALL ON TABLE extensions.pg_stat_statements_info TO postgres WITH GRANT OPTION;


--
-- Name: TABLE decrypted_key; Type: ACL; Schema: pgsodium; Owner: supabase_admin
--

GRANT ALL ON TABLE pgsodium.decrypted_key TO pgsodium_keyholder;


--
-- Name: TABLE masking_rule; Type: ACL; Schema: pgsodium; Owner: supabase_admin
--

GRANT ALL ON TABLE pgsodium.masking_rule TO pgsodium_keyholder;


--
-- Name: TABLE mask_columns; Type: ACL; Schema: pgsodium; Owner: supabase_admin
--

GRANT ALL ON TABLE pgsodium.mask_columns TO pgsodium_keyholder;


--
-- Name: TABLE complaint_actions; Type: ACL; Schema: public; Owner: postgres
--

GRANT ALL ON TABLE public.complaint_actions TO anon;
GRANT ALL ON TABLE public.complaint_actions TO authenticated;
GRANT ALL ON TABLE public.complaint_actions TO service_role;


--
-- Name: SEQUENCE complaint_actions_id_seq; Type: ACL; Schema: public; Owner: postgres
--

GRANT ALL ON SEQUENCE public.complaint_actions_id_seq TO anon;
GRANT ALL ON SEQUENCE public.complaint_actions_id_seq TO authenticated;
GRANT ALL ON SEQUENCE public.complaint_actions_id_seq TO service_role;


--
-- Name: TABLE complaints; Type: ACL; Schema: public; Owner: postgres
--

GRANT ALL ON TABLE public.complaints TO anon;
GRANT ALL ON TABLE public.complaints TO authenticated;
GRANT ALL ON TABLE public.complaints TO service_role;


--
-- Name: SEQUENCE complaints_complaint_id_seq; Type: ACL; Schema: public; Owner: postgres
--

GRANT ALL ON SEQUENCE public.complaints_complaint_id_seq TO anon;
GRANT ALL ON SEQUENCE public.complaints_complaint_id_seq TO authenticated;
GRANT ALL ON SEQUENCE public.complaints_complaint_id_seq TO service_role;


--
-- Name: TABLE summary; Type: ACL; Schema: public; Owner: postgres
--

GRANT ALL ON TABLE public.summary TO anon;
GRANT ALL ON TABLE public.summary TO authenticated;
GRANT ALL ON TABLE public.summary TO service_role;


--
-- Name: SEQUENCE summary_id_seq; Type: ACL; Schema: public; Owner: postgres
--

GRANT ALL ON SEQUENCE public.summary_id_seq TO anon;
GRANT ALL ON SEQUENCE public.summary_id_seq TO authenticated;
GRANT ALL ON SEQUENCE public.summary_id_seq TO service_role;


--
-- Name: TABLE "user"; Type: ACL; Schema: public; Owner: postgres
--

GRANT ALL ON TABLE public."user" TO anon;
GRANT ALL ON TABLE public."user" TO authenticated;
GRANT ALL ON TABLE public."user" TO service_role;


--
-- Name: SEQUENCE user_id_seq; Type: ACL; Schema: public; Owner: postgres
--

GRANT ALL ON SEQUENCE public.user_id_seq TO anon;
GRANT ALL ON SEQUENCE public.user_id_seq TO authenticated;
GRANT ALL ON SEQUENCE public.user_id_seq TO service_role;


--
-- Name: TABLE messages; Type: ACL; Schema: realtime; Owner: supabase_realtime_admin
--

GRANT ALL ON TABLE realtime.messages TO postgres;
GRANT ALL ON TABLE realtime.messages TO dashboard_user;
GRANT SELECT,INSERT,UPDATE ON TABLE realtime.messages TO anon;
GRANT SELECT,INSERT,UPDATE ON TABLE realtime.messages TO authenticated;
GRANT SELECT,INSERT,UPDATE ON TABLE realtime.messages TO service_role;


--
-- Name: TABLE schema_migrations; Type: ACL; Schema: realtime; Owner: supabase_admin
--

GRANT ALL ON TABLE realtime.schema_migrations TO postgres;
GRANT ALL ON TABLE realtime.schema_migrations TO dashboard_user;
GRANT SELECT ON TABLE realtime.schema_migrations TO anon;
GRANT SELECT ON TABLE realtime.schema_migrations TO authenticated;
GRANT SELECT ON TABLE realtime.schema_migrations TO service_role;
GRANT ALL ON TABLE realtime.schema_migrations TO supabase_realtime_admin;


--
-- Name: TABLE subscription; Type: ACL; Schema: realtime; Owner: supabase_admin
--

GRANT ALL ON TABLE realtime.subscription TO postgres;
GRANT ALL ON TABLE realtime.subscription TO dashboard_user;
GRANT SELECT ON TABLE realtime.subscription TO anon;
GRANT SELECT ON TABLE realtime.subscription TO authenticated;
GRANT SELECT ON TABLE realtime.subscription TO service_role;
GRANT ALL ON TABLE realtime.subscription TO supabase_realtime_admin;


--
-- Name: SEQUENCE subscription_id_seq; Type: ACL; Schema: realtime; Owner: supabase_admin
--

GRANT ALL ON SEQUENCE realtime.subscription_id_seq TO postgres;
GRANT ALL ON SEQUENCE realtime.subscription_id_seq TO dashboard_user;
GRANT USAGE ON SEQUENCE realtime.subscription_id_seq TO anon;
GRANT USAGE ON SEQUENCE realtime.subscription_id_seq TO authenticated;
GRANT USAGE ON SEQUENCE realtime.subscription_id_seq TO service_role;
GRANT ALL ON SEQUENCE realtime.subscription_id_seq TO supabase_realtime_admin;


--
-- Name: TABLE buckets; Type: ACL; Schema: storage; Owner: supabase_storage_admin
--

GRANT ALL ON TABLE storage.buckets TO anon;
GRANT ALL ON TABLE storage.buckets TO authenticated;
GRANT ALL ON TABLE storage.buckets TO service_role;
GRANT ALL ON TABLE storage.buckets TO postgres;


--
-- Name: TABLE migrations; Type: ACL; Schema: storage; Owner: supabase_storage_admin
--

GRANT ALL ON TABLE storage.migrations TO anon;
GRANT ALL ON TABLE storage.migrations TO authenticated;
GRANT ALL ON TABLE storage.migrations TO service_role;
GRANT ALL ON TABLE storage.migrations TO postgres;


--
-- Name: TABLE objects; Type: ACL; Schema: storage; Owner: supabase_storage_admin
--

GRANT ALL ON TABLE storage.objects TO anon;
GRANT ALL ON TABLE storage.objects TO authenticated;
GRANT ALL ON TABLE storage.objects TO service_role;
GRANT ALL ON TABLE storage.objects TO postgres;


--
-- Name: TABLE s3_multipart_uploads; Type: ACL; Schema: storage; Owner: supabase_storage_admin
--

GRANT ALL ON TABLE storage.s3_multipart_uploads TO service_role;
GRANT SELECT ON TABLE storage.s3_multipart_uploads TO authenticated;
GRANT SELECT ON TABLE storage.s3_multipart_uploads TO anon;


--
-- Name: TABLE s3_multipart_uploads_parts; Type: ACL; Schema: storage; Owner: supabase_storage_admin
--

GRANT ALL ON TABLE storage.s3_multipart_uploads_parts TO service_role;
GRANT SELECT ON TABLE storage.s3_multipart_uploads_parts TO authenticated;
GRANT SELECT ON TABLE storage.s3_multipart_uploads_parts TO anon;


--
-- Name: TABLE hooks; Type: ACL; Schema: supabase_functions; Owner: supabase_functions_admin
--

GRANT ALL ON TABLE supabase_functions.hooks TO postgres;
GRANT ALL ON TABLE supabase_functions.hooks TO anon;
GRANT ALL ON TABLE supabase_functions.hooks TO authenticated;
GRANT ALL ON TABLE supabase_functions.hooks TO service_role;


--
-- Name: SEQUENCE hooks_id_seq; Type: ACL; Schema: supabase_functions; Owner: supabase_functions_admin
--

GRANT ALL ON SEQUENCE supabase_functions.hooks_id_seq TO postgres;
GRANT ALL ON SEQUENCE supabase_functions.hooks_id_seq TO anon;
GRANT ALL ON SEQUENCE supabase_functions.hooks_id_seq TO authenticated;
GRANT ALL ON SEQUENCE supabase_functions.hooks_id_seq TO service_role;


--
-- Name: TABLE migrations; Type: ACL; Schema: supabase_functions; Owner: supabase_functions_admin
--

GRANT ALL ON TABLE supabase_functions.migrations TO postgres;
GRANT ALL ON TABLE supabase_functions.migrations TO anon;
GRANT ALL ON TABLE supabase_functions.migrations TO authenticated;
GRANT ALL ON TABLE supabase_functions.migrations TO service_role;


--
-- Name: DEFAULT PRIVILEGES FOR SEQUENCES; Type: DEFAULT ACL; Schema: auth; Owner: supabase_auth_admin
--

ALTER DEFAULT PRIVILEGES FOR ROLE supabase_auth_admin IN SCHEMA auth GRANT ALL ON SEQUENCES  TO postgres;
ALTER DEFAULT PRIVILEGES FOR ROLE supabase_auth_admin IN SCHEMA auth GRANT ALL ON SEQUENCES  TO dashboard_user;


--
-- Name: DEFAULT PRIVILEGES FOR FUNCTIONS; Type: DEFAULT ACL; Schema: auth; Owner: supabase_auth_admin
--

ALTER DEFAULT PRIVILEGES FOR ROLE supabase_auth_admin IN SCHEMA auth GRANT ALL ON FUNCTIONS  TO postgres;
ALTER DEFAULT PRIVILEGES FOR ROLE supabase_auth_admin IN SCHEMA auth GRANT ALL ON FUNCTIONS  TO dashboard_user;


--
-- Name: DEFAULT PRIVILEGES FOR TABLES; Type: DEFAULT ACL; Schema: auth; Owner: supabase_auth_admin
--

ALTER DEFAULT PRIVILEGES FOR ROLE supabase_auth_admin IN SCHEMA auth GRANT ALL ON TABLES  TO postgres;
ALTER DEFAULT PRIVILEGES FOR ROLE supabase_auth_admin IN SCHEMA auth GRANT ALL ON TABLES  TO dashboard_user;


--
-- Name: DEFAULT PRIVILEGES FOR SEQUENCES; Type: DEFAULT ACL; Schema: extensions; Owner: supabase_admin
--

ALTER DEFAULT PRIVILEGES FOR ROLE supabase_admin IN SCHEMA extensions GRANT ALL ON SEQUENCES  TO postgres WITH GRANT OPTION;


--
-- Name: DEFAULT PRIVILEGES FOR FUNCTIONS; Type: DEFAULT ACL; Schema: extensions; Owner: supabase_admin
--

ALTER DEFAULT PRIVILEGES FOR ROLE supabase_admin IN SCHEMA extensions GRANT ALL ON FUNCTIONS  TO postgres WITH GRANT OPTION;


--
-- Name: DEFAULT PRIVILEGES FOR TABLES; Type: DEFAULT ACL; Schema: extensions; Owner: supabase_admin
--

ALTER DEFAULT PRIVILEGES FOR ROLE supabase_admin IN SCHEMA extensions GRANT ALL ON TABLES  TO postgres WITH GRANT OPTION;


--
-- Name: DEFAULT PRIVILEGES FOR SEQUENCES; Type: DEFAULT ACL; Schema: graphql; Owner: supabase_admin
--

ALTER DEFAULT PRIVILEGES FOR ROLE supabase_admin IN SCHEMA graphql GRANT ALL ON SEQUENCES  TO postgres;
ALTER DEFAULT PRIVILEGES FOR ROLE supabase_admin IN SCHEMA graphql GRANT ALL ON SEQUENCES  TO anon;
ALTER DEFAULT PRIVILEGES FOR ROLE supabase_admin IN SCHEMA graphql GRANT ALL ON SEQUENCES  TO authenticated;
ALTER DEFAULT PRIVILEGES FOR ROLE supabase_admin IN SCHEMA graphql GRANT ALL ON SEQUENCES  TO service_role;


--
-- Name: DEFAULT PRIVILEGES FOR FUNCTIONS; Type: DEFAULT ACL; Schema: graphql; Owner: supabase_admin
--

ALTER DEFAULT PRIVILEGES FOR ROLE supabase_admin IN SCHEMA graphql GRANT ALL ON FUNCTIONS  TO postgres;
ALTER DEFAULT PRIVILEGES FOR ROLE supabase_admin IN SCHEMA graphql GRANT ALL ON FUNCTIONS  TO anon;
ALTER DEFAULT PRIVILEGES FOR ROLE supabase_admin IN SCHEMA graphql GRANT ALL ON FUNCTIONS  TO authenticated;
ALTER DEFAULT PRIVILEGES FOR ROLE supabase_admin IN SCHEMA graphql GRANT ALL ON FUNCTIONS  TO service_role;


--
-- Name: DEFAULT PRIVILEGES FOR TABLES; Type: DEFAULT ACL; Schema: graphql; Owner: supabase_admin
--

ALTER DEFAULT PRIVILEGES FOR ROLE supabase_admin IN SCHEMA graphql GRANT ALL ON TABLES  TO postgres;
ALTER DEFAULT PRIVILEGES FOR ROLE supabase_admin IN SCHEMA graphql GRANT ALL ON TABLES  TO anon;
ALTER DEFAULT PRIVILEGES FOR ROLE supabase_admin IN SCHEMA graphql GRANT ALL ON TABLES  TO authenticated;
ALTER DEFAULT PRIVILEGES FOR ROLE supabase_admin IN SCHEMA graphql GRANT ALL ON TABLES  TO service_role;


--
-- Name: DEFAULT PRIVILEGES FOR SEQUENCES; Type: DEFAULT ACL; Schema: graphql_public; Owner: supabase_admin
--

ALTER DEFAULT PRIVILEGES FOR ROLE supabase_admin IN SCHEMA graphql_public GRANT ALL ON SEQUENCES  TO postgres;
ALTER DEFAULT PRIVILEGES FOR ROLE supabase_admin IN SCHEMA graphql_public GRANT ALL ON SEQUENCES  TO anon;
ALTER DEFAULT PRIVILEGES FOR ROLE supabase_admin IN SCHEMA graphql_public GRANT ALL ON SEQUENCES  TO authenticated;
ALTER DEFAULT PRIVILEGES FOR ROLE supabase_admin IN SCHEMA graphql_public GRANT ALL ON SEQUENCES  TO service_role;


--
-- Name: DEFAULT PRIVILEGES FOR FUNCTIONS; Type: DEFAULT ACL; Schema: graphql_public; Owner: supabase_admin
--

ALTER DEFAULT PRIVILEGES FOR ROLE supabase_admin IN SCHEMA graphql_public GRANT ALL ON FUNCTIONS  TO postgres;
ALTER DEFAULT PRIVILEGES FOR ROLE supabase_admin IN SCHEMA graphql_public GRANT ALL ON FUNCTIONS  TO anon;
ALTER DEFAULT PRIVILEGES FOR ROLE supabase_admin IN SCHEMA graphql_public GRANT ALL ON FUNCTIONS  TO authenticated;
ALTER DEFAULT PRIVILEGES FOR ROLE supabase_admin IN SCHEMA graphql_public GRANT ALL ON FUNCTIONS  TO service_role;


--
-- Name: DEFAULT PRIVILEGES FOR TABLES; Type: DEFAULT ACL; Schema: graphql_public; Owner: supabase_admin
--

ALTER DEFAULT PRIVILEGES FOR ROLE supabase_admin IN SCHEMA graphql_public GRANT ALL ON TABLES  TO postgres;
ALTER DEFAULT PRIVILEGES FOR ROLE supabase_admin IN SCHEMA graphql_public GRANT ALL ON TABLES  TO anon;
ALTER DEFAULT PRIVILEGES FOR ROLE supabase_admin IN SCHEMA graphql_public GRANT ALL ON TABLES  TO authenticated;
ALTER DEFAULT PRIVILEGES FOR ROLE supabase_admin IN SCHEMA graphql_public GRANT ALL ON TABLES  TO service_role;


--
-- Name: DEFAULT PRIVILEGES FOR SEQUENCES; Type: DEFAULT ACL; Schema: pgsodium; Owner: supabase_admin
--

ALTER DEFAULT PRIVILEGES FOR ROLE supabase_admin IN SCHEMA pgsodium GRANT ALL ON SEQUENCES  TO pgsodium_keyholder;


--
-- Name: DEFAULT PRIVILEGES FOR TABLES; Type: DEFAULT ACL; Schema: pgsodium; Owner: supabase_admin
--

ALTER DEFAULT PRIVILEGES FOR ROLE supabase_admin IN SCHEMA pgsodium GRANT ALL ON TABLES  TO pgsodium_keyholder;


--
-- Name: DEFAULT PRIVILEGES FOR SEQUENCES; Type: DEFAULT ACL; Schema: pgsodium_masks; Owner: supabase_admin
--

ALTER DEFAULT PRIVILEGES FOR ROLE supabase_admin IN SCHEMA pgsodium_masks GRANT ALL ON SEQUENCES  TO pgsodium_keyiduser;


--
-- Name: DEFAULT PRIVILEGES FOR FUNCTIONS; Type: DEFAULT ACL; Schema: pgsodium_masks; Owner: supabase_admin
--

ALTER DEFAULT PRIVILEGES FOR ROLE supabase_admin IN SCHEMA pgsodium_masks GRANT ALL ON FUNCTIONS  TO pgsodium_keyiduser;


--
-- Name: DEFAULT PRIVILEGES FOR TABLES; Type: DEFAULT ACL; Schema: pgsodium_masks; Owner: supabase_admin
--

ALTER DEFAULT PRIVILEGES FOR ROLE supabase_admin IN SCHEMA pgsodium_masks GRANT ALL ON TABLES  TO pgsodium_keyiduser;


--
-- Name: DEFAULT PRIVILEGES FOR SEQUENCES; Type: DEFAULT ACL; Schema: public; Owner: postgres
--

ALTER DEFAULT PRIVILEGES FOR ROLE postgres IN SCHEMA public GRANT ALL ON SEQUENCES  TO postgres;
ALTER DEFAULT PRIVILEGES FOR ROLE postgres IN SCHEMA public GRANT ALL ON SEQUENCES  TO anon;
ALTER DEFAULT PRIVILEGES FOR ROLE postgres IN SCHEMA public GRANT ALL ON SEQUENCES  TO authenticated;
ALTER DEFAULT PRIVILEGES FOR ROLE postgres IN SCHEMA public GRANT ALL ON SEQUENCES  TO service_role;


--
-- Name: DEFAULT PRIVILEGES FOR SEQUENCES; Type: DEFAULT ACL; Schema: public; Owner: supabase_admin
--

ALTER DEFAULT PRIVILEGES FOR ROLE supabase_admin IN SCHEMA public GRANT ALL ON SEQUENCES  TO postgres;
ALTER DEFAULT PRIVILEGES FOR ROLE supabase_admin IN SCHEMA public GRANT ALL ON SEQUENCES  TO anon;
ALTER DEFAULT PRIVILEGES FOR ROLE supabase_admin IN SCHEMA public GRANT ALL ON SEQUENCES  TO authenticated;
ALTER DEFAULT PRIVILEGES FOR ROLE supabase_admin IN SCHEMA public GRANT ALL ON SEQUENCES  TO service_role;


--
-- Name: DEFAULT PRIVILEGES FOR FUNCTIONS; Type: DEFAULT ACL; Schema: public; Owner: postgres
--

ALTER DEFAULT PRIVILEGES FOR ROLE postgres IN SCHEMA public GRANT ALL ON FUNCTIONS  TO postgres;
ALTER DEFAULT PRIVILEGES FOR ROLE postgres IN SCHEMA public GRANT ALL ON FUNCTIONS  TO anon;
ALTER DEFAULT PRIVILEGES FOR ROLE postgres IN SCHEMA public GRANT ALL ON FUNCTIONS  TO authenticated;
ALTER DEFAULT PRIVILEGES FOR ROLE postgres IN SCHEMA public GRANT ALL ON FUNCTIONS  TO service_role;


--
-- Name: DEFAULT PRIVILEGES FOR FUNCTIONS; Type: DEFAULT ACL; Schema: public; Owner: supabase_admin
--

ALTER DEFAULT PRIVILEGES FOR ROLE supabase_admin IN SCHEMA public GRANT ALL ON FUNCTIONS  TO postgres;
ALTER DEFAULT PRIVILEGES FOR ROLE supabase_admin IN SCHEMA public GRANT ALL ON FUNCTIONS  TO anon;
ALTER DEFAULT PRIVILEGES FOR ROLE supabase_admin IN SCHEMA public GRANT ALL ON FUNCTIONS  TO authenticated;
ALTER DEFAULT PRIVILEGES FOR ROLE supabase_admin IN SCHEMA public GRANT ALL ON FUNCTIONS  TO service_role;


--
-- Name: DEFAULT PRIVILEGES FOR TABLES; Type: DEFAULT ACL; Schema: public; Owner: postgres
--

ALTER DEFAULT PRIVILEGES FOR ROLE postgres IN SCHEMA public GRANT ALL ON TABLES  TO postgres;
ALTER DEFAULT PRIVILEGES FOR ROLE postgres IN SCHEMA public GRANT ALL ON TABLES  TO anon;
ALTER DEFAULT PRIVILEGES FOR ROLE postgres IN SCHEMA public GRANT ALL ON TABLES  TO authenticated;
ALTER DEFAULT PRIVILEGES FOR ROLE postgres IN SCHEMA public GRANT ALL ON TABLES  TO service_role;


--
-- Name: DEFAULT PRIVILEGES FOR TABLES; Type: DEFAULT ACL; Schema: public; Owner: supabase_admin
--

ALTER DEFAULT PRIVILEGES FOR ROLE supabase_admin IN SCHEMA public GRANT ALL ON TABLES  TO postgres;
ALTER DEFAULT PRIVILEGES FOR ROLE supabase_admin IN SCHEMA public GRANT ALL ON TABLES  TO anon;
ALTER DEFAULT PRIVILEGES FOR ROLE supabase_admin IN SCHEMA public GRANT ALL ON TABLES  TO authenticated;
ALTER DEFAULT PRIVILEGES FOR ROLE supabase_admin IN SCHEMA public GRANT ALL ON TABLES  TO service_role;


--
-- Name: DEFAULT PRIVILEGES FOR SEQUENCES; Type: DEFAULT ACL; Schema: realtime; Owner: supabase_admin
--

ALTER DEFAULT PRIVILEGES FOR ROLE supabase_admin IN SCHEMA realtime GRANT ALL ON SEQUENCES  TO postgres;
ALTER DEFAULT PRIVILEGES FOR ROLE supabase_admin IN SCHEMA realtime GRANT ALL ON SEQUENCES  TO dashboard_user;


--
-- Name: DEFAULT PRIVILEGES FOR FUNCTIONS; Type: DEFAULT ACL; Schema: realtime; Owner: supabase_admin
--

ALTER DEFAULT PRIVILEGES FOR ROLE supabase_admin IN SCHEMA realtime GRANT ALL ON FUNCTIONS  TO postgres;
ALTER DEFAULT PRIVILEGES FOR ROLE supabase_admin IN SCHEMA realtime GRANT ALL ON FUNCTIONS  TO dashboard_user;


--
-- Name: DEFAULT PRIVILEGES FOR TABLES; Type: DEFAULT ACL; Schema: realtime; Owner: supabase_admin
--

ALTER DEFAULT PRIVILEGES FOR ROLE supabase_admin IN SCHEMA realtime GRANT ALL ON TABLES  TO postgres;
ALTER DEFAULT PRIVILEGES FOR ROLE supabase_admin IN SCHEMA realtime GRANT ALL ON TABLES  TO dashboard_user;


--
-- Name: DEFAULT PRIVILEGES FOR SEQUENCES; Type: DEFAULT ACL; Schema: storage; Owner: postgres
--

ALTER DEFAULT PRIVILEGES FOR ROLE postgres IN SCHEMA storage GRANT ALL ON SEQUENCES  TO postgres;
ALTER DEFAULT PRIVILEGES FOR ROLE postgres IN SCHEMA storage GRANT ALL ON SEQUENCES  TO anon;
ALTER DEFAULT PRIVILEGES FOR ROLE postgres IN SCHEMA storage GRANT ALL ON SEQUENCES  TO authenticated;
ALTER DEFAULT PRIVILEGES FOR ROLE postgres IN SCHEMA storage GRANT ALL ON SEQUENCES  TO service_role;


--
-- Name: DEFAULT PRIVILEGES FOR FUNCTIONS; Type: DEFAULT ACL; Schema: storage; Owner: postgres
--

ALTER DEFAULT PRIVILEGES FOR ROLE postgres IN SCHEMA storage GRANT ALL ON FUNCTIONS  TO postgres;
ALTER DEFAULT PRIVILEGES FOR ROLE postgres IN SCHEMA storage GRANT ALL ON FUNCTIONS  TO anon;
ALTER DEFAULT PRIVILEGES FOR ROLE postgres IN SCHEMA storage GRANT ALL ON FUNCTIONS  TO authenticated;
ALTER DEFAULT PRIVILEGES FOR ROLE postgres IN SCHEMA storage GRANT ALL ON FUNCTIONS  TO service_role;


--
-- Name: DEFAULT PRIVILEGES FOR TABLES; Type: DEFAULT ACL; Schema: storage; Owner: postgres
--

ALTER DEFAULT PRIVILEGES FOR ROLE postgres IN SCHEMA storage GRANT ALL ON TABLES  TO postgres;
ALTER DEFAULT PRIVILEGES FOR ROLE postgres IN SCHEMA storage GRANT ALL ON TABLES  TO anon;
ALTER DEFAULT PRIVILEGES FOR ROLE postgres IN SCHEMA storage GRANT ALL ON TABLES  TO authenticated;
ALTER DEFAULT PRIVILEGES FOR ROLE postgres IN SCHEMA storage GRANT ALL ON TABLES  TO service_role;


--
-- Name: DEFAULT PRIVILEGES FOR SEQUENCES; Type: DEFAULT ACL; Schema: supabase_functions; Owner: supabase_admin
--

ALTER DEFAULT PRIVILEGES FOR ROLE supabase_admin IN SCHEMA supabase_functions GRANT ALL ON SEQUENCES  TO postgres;
ALTER DEFAULT PRIVILEGES FOR ROLE supabase_admin IN SCHEMA supabase_functions GRANT ALL ON SEQUENCES  TO anon;
ALTER DEFAULT PRIVILEGES FOR ROLE supabase_admin IN SCHEMA supabase_functions GRANT ALL ON SEQUENCES  TO authenticated;
ALTER DEFAULT PRIVILEGES FOR ROLE supabase_admin IN SCHEMA supabase_functions GRANT ALL ON SEQUENCES  TO service_role;


--
-- Name: DEFAULT PRIVILEGES FOR FUNCTIONS; Type: DEFAULT ACL; Schema: supabase_functions; Owner: supabase_admin
--

ALTER DEFAULT PRIVILEGES FOR ROLE supabase_admin IN SCHEMA supabase_functions GRANT ALL ON FUNCTIONS  TO postgres;
ALTER DEFAULT PRIVILEGES FOR ROLE supabase_admin IN SCHEMA supabase_functions GRANT ALL ON FUNCTIONS  TO anon;
ALTER DEFAULT PRIVILEGES FOR ROLE supabase_admin IN SCHEMA supabase_functions GRANT ALL ON FUNCTIONS  TO authenticated;
ALTER DEFAULT PRIVILEGES FOR ROLE supabase_admin IN SCHEMA supabase_functions GRANT ALL ON FUNCTIONS  TO service_role;


--
-- Name: DEFAULT PRIVILEGES FOR TABLES; Type: DEFAULT ACL; Schema: supabase_functions; Owner: supabase_admin
--

ALTER DEFAULT PRIVILEGES FOR ROLE supabase_admin IN SCHEMA supabase_functions GRANT ALL ON TABLES  TO postgres;
ALTER DEFAULT PRIVILEGES FOR ROLE supabase_admin IN SCHEMA supabase_functions GRANT ALL ON TABLES  TO anon;
ALTER DEFAULT PRIVILEGES FOR ROLE supabase_admin IN SCHEMA supabase_functions GRANT ALL ON TABLES  TO authenticated;
ALTER DEFAULT PRIVILEGES FOR ROLE supabase_admin IN SCHEMA supabase_functions GRANT ALL ON TABLES  TO service_role;


--
-- Name: issue_graphql_placeholder; Type: EVENT TRIGGER; Schema: -; Owner: supabase_admin
--

CREATE EVENT TRIGGER issue_graphql_placeholder ON sql_drop
         WHEN TAG IN ('DROP EXTENSION')
   EXECUTE FUNCTION extensions.set_graphql_placeholder();


ALTER EVENT TRIGGER issue_graphql_placeholder OWNER TO supabase_admin;

--
-- Name: issue_pg_cron_access; Type: EVENT TRIGGER; Schema: -; Owner: supabase_admin
--

CREATE EVENT TRIGGER issue_pg_cron_access ON ddl_command_end
         WHEN TAG IN ('CREATE EXTENSION')
   EXECUTE FUNCTION extensions.grant_pg_cron_access();


ALTER EVENT TRIGGER issue_pg_cron_access OWNER TO supabase_admin;

--
-- Name: issue_pg_graphql_access; Type: EVENT TRIGGER; Schema: -; Owner: supabase_admin
--

CREATE EVENT TRIGGER issue_pg_graphql_access ON ddl_command_end
         WHEN TAG IN ('CREATE FUNCTION')
   EXECUTE FUNCTION extensions.grant_pg_graphql_access();


ALTER EVENT TRIGGER issue_pg_graphql_access OWNER TO supabase_admin;

--
-- Name: issue_pg_net_access; Type: EVENT TRIGGER; Schema: -; Owner: postgres
--

CREATE EVENT TRIGGER issue_pg_net_access ON ddl_command_end
         WHEN TAG IN ('CREATE EXTENSION')
   EXECUTE FUNCTION extensions.grant_pg_net_access();


ALTER EVENT TRIGGER issue_pg_net_access OWNER TO postgres;

--
-- Name: pgrst_ddl_watch; Type: EVENT TRIGGER; Schema: -; Owner: supabase_admin
--

CREATE EVENT TRIGGER pgrst_ddl_watch ON ddl_command_end
   EXECUTE FUNCTION extensions.pgrst_ddl_watch();


ALTER EVENT TRIGGER pgrst_ddl_watch OWNER TO supabase_admin;

--
-- Name: pgrst_drop_watch; Type: EVENT TRIGGER; Schema: -; Owner: supabase_admin
--

CREATE EVENT TRIGGER pgrst_drop_watch ON sql_drop
   EXECUTE FUNCTION extensions.pgrst_drop_watch();


ALTER EVENT TRIGGER pgrst_drop_watch OWNER TO supabase_admin;

--
-- PostgreSQL database dump complete
--

