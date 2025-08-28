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
-- Name: auth; Type: SCHEMA; Schema: -; Owner: -
--

CREATE SCHEMA auth;


--
-- Name: public; Type: SCHEMA; Schema: -; Owner: -
--

CREATE SCHEMA public;


--
-- Name: SCHEMA public; Type: COMMENT; Schema: -; Owner: -
--

COMMENT ON SCHEMA public IS 'standard public schema';


--
-- Name: aal_level; Type: TYPE; Schema: auth; Owner: -
--

CREATE TYPE auth.aal_level AS ENUM (
    'aal1',
    'aal2',
    'aal3'
);


--
-- Name: code_challenge_method; Type: TYPE; Schema: auth; Owner: -
--

CREATE TYPE auth.code_challenge_method AS ENUM (
    's256',
    'plain'
);


--
-- Name: factor_status; Type: TYPE; Schema: auth; Owner: -
--

CREATE TYPE auth.factor_status AS ENUM (
    'unverified',
    'verified'
);


--
-- Name: factor_type; Type: TYPE; Schema: auth; Owner: -
--

CREATE TYPE auth.factor_type AS ENUM (
    'totp',
    'webauthn',
    'phone'
);


--
-- Name: one_time_token_type; Type: TYPE; Schema: auth; Owner: -
--

CREATE TYPE auth.one_time_token_type AS ENUM (
    'confirmation_token',
    'reauthentication_token',
    'recovery_token',
    'email_change_token_new',
    'email_change_token_current',
    'phone_change_token'
);


--
-- Name: email(); Type: FUNCTION; Schema: auth; Owner: -
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


--
-- Name: FUNCTION email(); Type: COMMENT; Schema: auth; Owner: -
--

COMMENT ON FUNCTION auth.email() IS 'Deprecated. Use auth.jwt() -> ''email'' instead.';


--
-- Name: jwt(); Type: FUNCTION; Schema: auth; Owner: -
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


--
-- Name: role(); Type: FUNCTION; Schema: auth; Owner: -
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


--
-- Name: FUNCTION role(); Type: COMMENT; Schema: auth; Owner: -
--

COMMENT ON FUNCTION auth.role() IS 'Deprecated. Use auth.jwt() -> ''role'' instead.';


--
-- Name: uid(); Type: FUNCTION; Schema: auth; Owner: -
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


--
-- Name: FUNCTION uid(); Type: COMMENT; Schema: auth; Owner: -
--

COMMENT ON FUNCTION auth.uid() IS 'Deprecated. Use auth.jwt() -> ''sub'' instead.';


SET default_tablespace = '';

SET default_table_access_method = heap;

--
-- Name: audit_log_entries; Type: TABLE; Schema: auth; Owner: -
--

CREATE TABLE auth.audit_log_entries (
    instance_id uuid,
    id uuid NOT NULL,
    payload json,
    created_at timestamp with time zone,
    ip_address character varying(64) DEFAULT ''::character varying NOT NULL
);


--
-- Name: TABLE audit_log_entries; Type: COMMENT; Schema: auth; Owner: -
--

COMMENT ON TABLE auth.audit_log_entries IS 'Auth: Audit trail for user actions.';


--
-- Name: flow_state; Type: TABLE; Schema: auth; Owner: -
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


--
-- Name: TABLE flow_state; Type: COMMENT; Schema: auth; Owner: -
--

COMMENT ON TABLE auth.flow_state IS 'stores metadata for pkce logins';


--
-- Name: identities; Type: TABLE; Schema: auth; Owner: -
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


--
-- Name: TABLE identities; Type: COMMENT; Schema: auth; Owner: -
--

COMMENT ON TABLE auth.identities IS 'Auth: Stores identities associated to a user.';


--
-- Name: COLUMN identities.email; Type: COMMENT; Schema: auth; Owner: -
--

COMMENT ON COLUMN auth.identities.email IS 'Auth: Email is a generated column that references the optional email property in the identity_data';


--
-- Name: instances; Type: TABLE; Schema: auth; Owner: -
--

CREATE TABLE auth.instances (
    id uuid NOT NULL,
    uuid uuid,
    raw_base_config text,
    created_at timestamp with time zone,
    updated_at timestamp with time zone
);


--
-- Name: TABLE instances; Type: COMMENT; Schema: auth; Owner: -
--

COMMENT ON TABLE auth.instances IS 'Auth: Manages users across multiple sites.';


--
-- Name: mfa_amr_claims; Type: TABLE; Schema: auth; Owner: -
--

CREATE TABLE auth.mfa_amr_claims (
    session_id uuid NOT NULL,
    created_at timestamp with time zone NOT NULL,
    updated_at timestamp with time zone NOT NULL,
    authentication_method text NOT NULL,
    id uuid NOT NULL
);


--
-- Name: TABLE mfa_amr_claims; Type: COMMENT; Schema: auth; Owner: -
--

COMMENT ON TABLE auth.mfa_amr_claims IS 'auth: stores authenticator method reference claims for multi factor authentication';


--
-- Name: mfa_challenges; Type: TABLE; Schema: auth; Owner: -
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


--
-- Name: TABLE mfa_challenges; Type: COMMENT; Schema: auth; Owner: -
--

COMMENT ON TABLE auth.mfa_challenges IS 'auth: stores metadata about challenge requests made';


--
-- Name: mfa_factors; Type: TABLE; Schema: auth; Owner: -
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


--
-- Name: TABLE mfa_factors; Type: COMMENT; Schema: auth; Owner: -
--

COMMENT ON TABLE auth.mfa_factors IS 'auth: stores metadata about factors';


--
-- Name: one_time_tokens; Type: TABLE; Schema: auth; Owner: -
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


--
-- Name: refresh_tokens; Type: TABLE; Schema: auth; Owner: -
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


--
-- Name: TABLE refresh_tokens; Type: COMMENT; Schema: auth; Owner: -
--

COMMENT ON TABLE auth.refresh_tokens IS 'Auth: Store of tokens used to refresh JWT tokens once they expire.';


--
-- Name: refresh_tokens_id_seq; Type: SEQUENCE; Schema: auth; Owner: -
--

CREATE SEQUENCE auth.refresh_tokens_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: refresh_tokens_id_seq; Type: SEQUENCE OWNED BY; Schema: auth; Owner: -
--

ALTER SEQUENCE auth.refresh_tokens_id_seq OWNED BY auth.refresh_tokens.id;


--
-- Name: saml_providers; Type: TABLE; Schema: auth; Owner: -
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


--
-- Name: TABLE saml_providers; Type: COMMENT; Schema: auth; Owner: -
--

COMMENT ON TABLE auth.saml_providers IS 'Auth: Manages SAML Identity Provider connections.';


--
-- Name: saml_relay_states; Type: TABLE; Schema: auth; Owner: -
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


--
-- Name: TABLE saml_relay_states; Type: COMMENT; Schema: auth; Owner: -
--

COMMENT ON TABLE auth.saml_relay_states IS 'Auth: Contains SAML Relay State information for each Service Provider initiated login.';


--
-- Name: schema_migrations; Type: TABLE; Schema: auth; Owner: -
--

CREATE TABLE auth.schema_migrations (
    version character varying(255) NOT NULL
);


--
-- Name: TABLE schema_migrations; Type: COMMENT; Schema: auth; Owner: -
--

COMMENT ON TABLE auth.schema_migrations IS 'Auth: Manages updates to the auth system.';


--
-- Name: sessions; Type: TABLE; Schema: auth; Owner: -
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


--
-- Name: TABLE sessions; Type: COMMENT; Schema: auth; Owner: -
--

COMMENT ON TABLE auth.sessions IS 'Auth: Stores session data associated to a user.';


--
-- Name: COLUMN sessions.not_after; Type: COMMENT; Schema: auth; Owner: -
--

COMMENT ON COLUMN auth.sessions.not_after IS 'Auth: Not after is a nullable column that contains a timestamp after which the session should be regarded as expired.';


--
-- Name: sso_domains; Type: TABLE; Schema: auth; Owner: -
--

CREATE TABLE auth.sso_domains (
    id uuid NOT NULL,
    sso_provider_id uuid NOT NULL,
    domain text NOT NULL,
    created_at timestamp with time zone,
    updated_at timestamp with time zone,
    CONSTRAINT "domain not empty" CHECK ((char_length(domain) > 0))
);


--
-- Name: TABLE sso_domains; Type: COMMENT; Schema: auth; Owner: -
--

COMMENT ON TABLE auth.sso_domains IS 'Auth: Manages SSO email address domain mapping to an SSO Identity Provider.';


--
-- Name: sso_providers; Type: TABLE; Schema: auth; Owner: -
--

CREATE TABLE auth.sso_providers (
    id uuid NOT NULL,
    resource_id text,
    created_at timestamp with time zone,
    updated_at timestamp with time zone,
    CONSTRAINT "resource_id not empty" CHECK (((resource_id = NULL::text) OR (char_length(resource_id) > 0)))
);


--
-- Name: TABLE sso_providers; Type: COMMENT; Schema: auth; Owner: -
--

COMMENT ON TABLE auth.sso_providers IS 'Auth: Manages SSO identity provider information; see saml_providers for SAML.';


--
-- Name: COLUMN sso_providers.resource_id; Type: COMMENT; Schema: auth; Owner: -
--

COMMENT ON COLUMN auth.sso_providers.resource_id IS 'Auth: Uniquely identifies a SSO provider according to a user-chosen resource ID (case insensitive), useful in infrastructure as code.';


--
-- Name: users; Type: TABLE; Schema: auth; Owner: -
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


--
-- Name: TABLE users; Type: COMMENT; Schema: auth; Owner: -
--

COMMENT ON TABLE auth.users IS 'Auth: Stores user login data within a secure schema.';


--
-- Name: COLUMN users.is_sso_user; Type: COMMENT; Schema: auth; Owner: -
--

COMMENT ON COLUMN auth.users.is_sso_user IS 'Auth: Set this column to true when the account comes from SSO. These accounts can have duplicate emails.';


--
-- Name: change_password_request; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.change_password_request (
    change_password_request_id integer NOT NULL,
    uuid uuid DEFAULT extensions.uuid_generate_v4(),
    new_password character varying(150),
    user_id uuid,
    used boolean,
    trigger_from character varying(20),
    expired_at timestamp without time zone,
    created_at timestamp without time zone DEFAULT now()
);


--
-- Name: change_password_request_change_password_request_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public.change_password_request_change_password_request_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: change_password_request_change_password_request_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE public.change_password_request_change_password_request_id_seq OWNED BY public.change_password_request.change_password_request_id;


--
-- Name: complaint_actions; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.complaint_actions (
    action_id bigint NOT NULL,
    created_at timestamp with time zone DEFAULT now() NOT NULL,
    complaint_id bigint,
    action_by text NOT NULL,
    action text,
    remarks text,
    confidential boolean,
    documents uuid[],
    pending_evidence boolean DEFAULT false,
    prev_complaint_id integer,
    email character varying(200)
);


--
-- Name: TABLE complaint_actions; Type: COMMENT; Schema: public; Owner: -
--

COMMENT ON TABLE public.complaint_actions IS 'actions made for complaints';


--
-- Name: COLUMN complaint_actions.complaint_id; Type: COMMENT; Schema: public; Owner: -
--

COMMENT ON COLUMN public.complaint_actions.complaint_id IS 'actions made for complaint';


--
-- Name: COLUMN complaint_actions.action_by; Type: COMMENT; Schema: public; Owner: -
--

COMMENT ON COLUMN public.complaint_actions.action_by IS 'action taken by';


--
-- Name: COLUMN complaint_actions.action; Type: COMMENT; Schema: public; Owner: -
--

COMMENT ON COLUMN public.complaint_actions.action IS 'the action taken';


--
-- Name: COLUMN complaint_actions.remarks; Type: COMMENT; Schema: public; Owner: -
--

COMMENT ON COLUMN public.complaint_actions.remarks IS 'the remark left by action creator';


--
-- Name: COLUMN complaint_actions.confidential; Type: COMMENT; Schema: public; Owner: -
--

COMMENT ON COLUMN public.complaint_actions.confidential IS 'is the action confidential?';


--
-- Name: complaint_actions_id_seq; Type: SEQUENCE; Schema: public; Owner: -
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
-- Name: complaints; Type: TABLE; Schema: public; Owner: -
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
    complainant uuid DEFAULT auth.uid(),
    last_action bigint,
    other_type text,
    accused text NOT NULL,
    accused_is_org boolean NOT NULL,
    owned_by bigint,
    prev_complaint_id integer,
    prev_complainant_email character varying(200)
);


--
-- Name: TABLE complaints; Type: COMMENT; Schema: public; Owner: -
--

COMMENT ON TABLE public.complaints IS 'stores all the complaints lodged by complainants.';


--
-- Name: COLUMN complaints.documents; Type: COMMENT; Schema: public; Owner: -
--

COMMENT ON COLUMN public.complaints.documents IS 'all documents submitted when first lodging a complaint';


--
-- Name: COLUMN complaints.complainant; Type: COMMENT; Schema: public; Owner: -
--

COMMENT ON COLUMN public.complaints.complainant IS 'who lodged the complaint?';


--
-- Name: COLUMN complaints.last_action; Type: COMMENT; Schema: public; Owner: -
--

COMMENT ON COLUMN public.complaints.last_action IS 'last action id';


--
-- Name: COLUMN complaints.other_type; Type: COMMENT; Schema: public; Owner: -
--

COMMENT ON COLUMN public.complaints.other_type IS 'description of other type';


--
-- Name: COLUMN complaints.accused; Type: COMMENT; Schema: public; Owner: -
--

COMMENT ON COLUMN public.complaints.accused IS 'name of the organization or individual being accused';


--
-- Name: COLUMN complaints.accused_is_org; Type: COMMENT; Schema: public; Owner: -
--

COMMENT ON COLUMN public.complaints.accused_is_org IS 'is the accused an organization';


--
-- Name: complaints_complaint_id_seq; Type: SEQUENCE; Schema: public; Owner: -
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
-- Name: summary; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.summary (
    id bigint NOT NULL,
    created_at timestamp with time zone DEFAULT now() NOT NULL,
    hide boolean DEFAULT true,
    accused text,
    complaint_id bigint,
    complaint_date date,
    summary text,
    prev_complaint_id integer
);


--
-- Name: COLUMN summary.accused; Type: COMMENT; Schema: public; Owner: -
--

COMMENT ON COLUMN public.summary.accused IS 'organization or individual the complaint was lodged against';


--
-- Name: COLUMN summary.complaint_id; Type: COMMENT; Schema: public; Owner: -
--

COMMENT ON COLUMN public.summary.complaint_id IS 'the id of the complaint';


--
-- Name: COLUMN summary.summary; Type: COMMENT; Schema: public; Owner: -
--

COMMENT ON COLUMN public.summary.summary IS 'summary of the complaint';


--
-- Name: summary_id_seq; Type: SEQUENCE; Schema: public; Owner: -
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
-- Name: user; Type: TABLE; Schema: public; Owner: -
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
    name text,
    email character varying,
    prev_pwd character varying
);


--
-- Name: TABLE "user"; Type: COMMENT; Schema: public; Owner: -
--

COMMENT ON TABLE public."user" IS 'user data table';


--
-- Name: COLUMN "user".name; Type: COMMENT; Schema: public; Owner: -
--

COMMENT ON COLUMN public."user".name IS 'name of the user';


--
-- Name: user_id_seq; Type: SEQUENCE; Schema: public; Owner: -
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
-- Name: refresh_tokens id; Type: DEFAULT; Schema: auth; Owner: -
--

ALTER TABLE ONLY auth.refresh_tokens ALTER COLUMN id SET DEFAULT nextval('auth.refresh_tokens_id_seq'::regclass);


--
-- Name: change_password_request change_password_request_id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.change_password_request ALTER COLUMN change_password_request_id SET DEFAULT nextval('public.change_password_request_change_password_request_id_seq'::regclass);


--
-- Data for Name: audit_log_entries; Type: TABLE DATA; Schema: auth; Owner: -
--

COPY auth.audit_log_entries (instance_id, id, payload, created_at, ip_address) FROM stdin;
00000000-0000-0000-0000-000000000000	49d88425-062c-4bff-885b-38635e569b8e	{"action":"user_signedup","actor_id":"0a293fdd-d64a-4a9e-b46c-fad7f2175e01","actor_username":"marz@marzex.tech","actor_via_sso":false,"log_type":"team","traits":{"provider":"email"}}	2025-02-18 18:24:13.494723+00	
00000000-0000-0000-0000-000000000000	bf7cd0c1-f90a-4007-afd1-7cb95434e63c	{"action":"login","actor_id":"0a293fdd-d64a-4a9e-b46c-fad7f2175e01","actor_username":"marz@marzex.tech","actor_via_sso":false,"log_type":"account","traits":{"provider":"email"}}	2025-02-18 18:24:13.504501+00	
00000000-0000-0000-0000-000000000000	fabde978-348f-49fa-8a83-286cfe9446f5	{"action":"logout","actor_id":"0a293fdd-d64a-4a9e-b46c-fad7f2175e01","actor_username":"marz@marzex.tech","actor_via_sso":false,"log_type":"account"}	2025-02-18 18:26:10.205334+00	
00000000-0000-0000-0000-000000000000	7a9ac7f4-a31f-492b-98a6-d5a2341d4514	{"action":"login","actor_id":"0a293fdd-d64a-4a9e-b46c-fad7f2175e01","actor_username":"marz@marzex.tech","actor_via_sso":false,"log_type":"account","traits":{"provider":"email"}}	2025-02-18 18:32:50.985291+00	
00000000-0000-0000-0000-000000000000	7e9f8af2-f231-45f0-b296-998cfd1a946a	{"action":"logout","actor_id":"0a293fdd-d64a-4a9e-b46c-fad7f2175e01","actor_username":"marz@marzex.tech","actor_via_sso":false,"log_type":"account"}	2025-02-18 18:33:44.347508+00	
00000000-0000-0000-0000-000000000000	64d3efbb-d848-4d84-b7c1-085b57d3898f	{"action":"user_signedup","actor_id":"0955eea6-fdc3-48b6-beca-f30e05cfe912","actor_username":"hazwan@mspo.org.my","actor_via_sso":false,"log_type":"team","traits":{"provider":"email"}}	2025-06-14 18:41:49.69423+00	
00000000-0000-0000-0000-000000000000	6d3fb684-fa2f-4759-a306-4c4f20f609d8	{"action":"login","actor_id":"0955eea6-fdc3-48b6-beca-f30e05cfe912","actor_username":"hazwan@mspo.org.my","actor_via_sso":false,"log_type":"account","traits":{"provider":"email"}}	2025-06-14 18:41:49.757955+00	
00000000-0000-0000-0000-000000000000	f995adab-4e89-435b-b69d-ce0b9eb523c8	{"action":"login","actor_id":"0955eea6-fdc3-48b6-beca-f30e05cfe912","actor_username":"hazwan@mspo.org.my","actor_via_sso":false,"log_type":"account","traits":{"provider":"email"}}	2025-06-14 18:43:45.517359+00	
00000000-0000-0000-0000-000000000000	9d4d13aa-cc2c-4f02-a10f-80f5572339b9	{"action":"token_refreshed","actor_id":"0955eea6-fdc3-48b6-beca-f30e05cfe912","actor_username":"hazwan@mspo.org.my","actor_via_sso":false,"log_type":"token"}	2025-06-14 23:49:52.329959+00	
00000000-0000-0000-0000-000000000000	12dc7163-0d48-41e1-84ed-f64983092a1d	{"action":"token_revoked","actor_id":"0955eea6-fdc3-48b6-beca-f30e05cfe912","actor_username":"hazwan@mspo.org.my","actor_via_sso":false,"log_type":"token"}	2025-06-14 23:49:52.330446+00	
00000000-0000-0000-0000-000000000000	75810c63-66d0-4489-9d43-2c866576cd29	{"action":"token_refreshed","actor_id":"0955eea6-fdc3-48b6-beca-f30e05cfe912","actor_username":"hazwan@mspo.org.my","actor_via_sso":false,"log_type":"token"}	2025-06-15 06:06:23.173409+00	
00000000-0000-0000-0000-000000000000	a3aabe6a-cb7f-4ae0-95ba-55302518c9a3	{"action":"token_revoked","actor_id":"0955eea6-fdc3-48b6-beca-f30e05cfe912","actor_username":"hazwan@mspo.org.my","actor_via_sso":false,"log_type":"token"}	2025-06-15 06:06:23.173839+00	
00000000-0000-0000-0000-000000000000	f4dc2bde-292e-4696-9fc6-3cd0c703adff	{"action":"login","actor_id":"0955eea6-fdc3-48b6-beca-f30e05cfe912","actor_username":"hazwan@mspo.org.my","actor_via_sso":false,"log_type":"account","traits":{"provider":"email"}}	2025-06-15 08:00:25.857012+00	
00000000-0000-0000-0000-000000000000	98876911-dbcd-4676-8de3-fa51b7d2a9ee	{"action":"logout","actor_id":"0955eea6-fdc3-48b6-beca-f30e05cfe912","actor_username":"hazwan@mspo.org.my","actor_via_sso":false,"log_type":"account"}	2025-06-15 08:04:49.411561+00	
00000000-0000-0000-0000-000000000000	c2e3e837-edfd-4550-8a5a-6f522e5b2fe9	{"action":"login","actor_id":"0955eea6-fdc3-48b6-beca-f30e05cfe912","actor_username":"hazwan@mspo.org.my","actor_via_sso":false,"log_type":"account","traits":{"provider":"email"}}	2025-06-15 09:06:50.771468+00	
00000000-0000-0000-0000-000000000000	45a79172-6790-4c60-86e8-e919cab440e2	{"action":"logout","actor_id":"0955eea6-fdc3-48b6-beca-f30e05cfe912","actor_username":"hazwan@mspo.org.my","actor_via_sso":false,"log_type":"account"}	2025-06-15 09:26:56.129591+00	
00000000-0000-0000-0000-000000000000	24e621cc-2f9c-42e2-90a9-c345ac1ea0ad	{"action":"user_signedup","actor_id":"a007885a-80b3-4486-b31c-6652abca3e12","actor_username":"firdaus@mspo.org.my","actor_via_sso":false,"log_type":"team","traits":{"provider":"email"}}	2025-06-15 09:36:05.773148+00	
00000000-0000-0000-0000-000000000000	7ce99363-f0a2-4c24-96c6-21d4126ad434	{"action":"login","actor_id":"a007885a-80b3-4486-b31c-6652abca3e12","actor_username":"firdaus@mspo.org.my","actor_via_sso":false,"log_type":"account","traits":{"provider":"email"}}	2025-06-15 09:36:05.775271+00	
00000000-0000-0000-0000-000000000000	cd134c3b-6570-4e2f-b192-43cea975e2a9	{"action":"login","actor_id":"0955eea6-fdc3-48b6-beca-f30e05cfe912","actor_username":"hazwan@mspo.org.my","actor_via_sso":false,"log_type":"account","traits":{"provider":"email"}}	2025-06-15 09:57:13.996415+00	
00000000-0000-0000-0000-000000000000	3b278200-de54-4265-835b-41626352aef7	{"action":"token_refreshed","actor_id":"0955eea6-fdc3-48b6-beca-f30e05cfe912","actor_username":"hazwan@mspo.org.my","actor_via_sso":false,"log_type":"token"}	2025-06-15 14:23:30.812078+00	
00000000-0000-0000-0000-000000000000	1c0290fc-c11d-48ac-a59e-8a484ce4fe85	{"action":"token_revoked","actor_id":"0955eea6-fdc3-48b6-beca-f30e05cfe912","actor_username":"hazwan@mspo.org.my","actor_via_sso":false,"log_type":"token"}	2025-06-15 14:23:30.812518+00	
00000000-0000-0000-0000-000000000000	1ac745ce-d5d0-4dd4-988f-9f763e626278	{"action":"user_signedup","actor_id":"b7592049-9546-4bd4-9bc7-33d77d747af0","actor_username":"hemanathan@airei.com.my","actor_via_sso":false,"log_type":"team","traits":{"provider":"email"}}	2025-06-15 14:38:32.836106+00	
00000000-0000-0000-0000-000000000000	82246189-0d6a-4502-85d6-b930975e6e5f	{"action":"login","actor_id":"b7592049-9546-4bd4-9bc7-33d77d747af0","actor_username":"hemanathan@airei.com.my","actor_via_sso":false,"log_type":"account","traits":{"provider":"email"}}	2025-06-15 14:38:32.838197+00	
00000000-0000-0000-0000-000000000000	4e2119a5-4e5b-44c2-958a-764fcac35fb2	{"action":"user_signedup","actor_id":"663cd7e5-73f0-4c16-b7a8-a579107fda69","actor_username":"k@gmail.com","actor_via_sso":false,"log_type":"team","traits":{"provider":"email"}}	2025-06-15 14:38:32.940128+00	
00000000-0000-0000-0000-000000000000	dea6c711-d6ae-428d-aace-db74964f9da1	{"action":"login","actor_id":"663cd7e5-73f0-4c16-b7a8-a579107fda69","actor_username":"k@gmail.com","actor_via_sso":false,"log_type":"account","traits":{"provider":"email"}}	2025-06-15 14:38:32.941956+00	
00000000-0000-0000-0000-000000000000	c2a5df74-ce85-463f-8d3b-b86d02bc0404	{"action":"user_signedup","actor_id":"081efe3b-09b5-4e34-9194-cbcb30cc77d9","actor_username":"kamarulsipi.mohd@gmail.com","actor_via_sso":false,"log_type":"team","traits":{"provider":"email"}}	2025-06-15 14:38:33.037554+00	
00000000-0000-0000-0000-000000000000	ed0dd29e-5eca-4cae-aae9-c4edb59b3f57	{"action":"login","actor_id":"081efe3b-09b5-4e34-9194-cbcb30cc77d9","actor_username":"kamarulsipi.mohd@gmail.com","actor_via_sso":false,"log_type":"account","traits":{"provider":"email"}}	2025-06-15 14:38:33.039226+00	
00000000-0000-0000-0000-000000000000	57717f9c-ae10-4d30-a7f0-f3fc6d272365	{"action":"user_signedup","actor_id":"5de03212-53a6-465c-857b-34e113374e81","actor_username":"kamarul.sipi@airei.com.my","actor_via_sso":false,"log_type":"team","traits":{"provider":"email"}}	2025-06-15 14:38:33.132445+00	
00000000-0000-0000-0000-000000000000	728a3445-ef9b-4a48-b118-edf03ed9ae31	{"action":"login","actor_id":"5de03212-53a6-465c-857b-34e113374e81","actor_username":"kamarul.sipi@airei.com.my","actor_via_sso":false,"log_type":"account","traits":{"provider":"email"}}	2025-06-15 14:38:33.134386+00	
00000000-0000-0000-0000-000000000000	d3b2a2fc-666e-41bd-b0bd-077448a250f2	{"action":"user_signedup","actor_id":"1207343f-7e2b-4f82-88ed-7b559f837c08","actor_username":"hemanarhan@airei.com.my","actor_via_sso":false,"log_type":"team","traits":{"provider":"email"}}	2025-06-15 14:38:33.237285+00	
00000000-0000-0000-0000-000000000000	d714021f-5484-4870-8e92-02f691e3639d	{"action":"login","actor_id":"1207343f-7e2b-4f82-88ed-7b559f837c08","actor_username":"hemanarhan@airei.com.my","actor_via_sso":false,"log_type":"account","traits":{"provider":"email"}}	2025-06-15 14:38:33.23881+00	
00000000-0000-0000-0000-000000000000	91021dca-7fce-447b-9e68-7bbde4b13d13	{"action":"user_signedup","actor_id":"884b5358-cd7d-4b03-84af-fde5a996ac76","actor_username":"s@gmail.com","actor_via_sso":false,"log_type":"team","traits":{"provider":"email"}}	2025-06-15 14:38:33.333175+00	
00000000-0000-0000-0000-000000000000	5ff625f3-72cf-46d6-b820-085367e12ab6	{"action":"login","actor_id":"884b5358-cd7d-4b03-84af-fde5a996ac76","actor_username":"s@gmail.com","actor_via_sso":false,"log_type":"account","traits":{"provider":"email"}}	2025-06-15 14:38:33.33501+00	
00000000-0000-0000-0000-000000000000	f9deed87-e5d3-44e4-8536-6119f49ec3a4	{"action":"user_signedup","actor_id":"9c533f9b-0de2-4184-8679-ac4124139717","actor_username":"kamaroyamatha@gmail.com","actor_via_sso":false,"log_type":"team","traits":{"provider":"email"}}	2025-06-15 14:38:33.429862+00	
00000000-0000-0000-0000-000000000000	cde5c210-8a93-4026-ae1a-ea6130d63722	{"action":"login","actor_id":"9c533f9b-0de2-4184-8679-ac4124139717","actor_username":"kamaroyamatha@gmail.com","actor_via_sso":false,"log_type":"account","traits":{"provider":"email"}}	2025-06-15 14:38:33.431618+00	
00000000-0000-0000-0000-000000000000	84d27570-acf3-49fb-b998-f462d7b32060	{"action":"user_signedup","actor_id":"46f9cd41-b08e-4e32-81eb-bb1d3323b3b2","actor_username":"nasiha@mpocc.org.my","actor_via_sso":false,"log_type":"team","traits":{"provider":"email"}}	2025-06-15 14:38:33.534522+00	
00000000-0000-0000-0000-000000000000	6800bd18-73c3-4ca2-b510-fc3b462c4218	{"action":"login","actor_id":"46f9cd41-b08e-4e32-81eb-bb1d3323b3b2","actor_username":"nasiha@mpocc.org.my","actor_via_sso":false,"log_type":"account","traits":{"provider":"email"}}	2025-06-15 14:38:33.536429+00	
00000000-0000-0000-0000-000000000000	2e20a286-12f3-4395-a8e3-c102e10509ba	{"action":"user_signedup","actor_id":"4d6dc0fa-8a2f-4073-9bbd-85425124beb0","actor_username":"leo_gee87@yahoo.com","actor_via_sso":false,"log_type":"team","traits":{"provider":"email"}}	2025-06-15 14:38:33.64536+00	
00000000-0000-0000-0000-000000000000	84db1768-adeb-43dc-8a81-5eb9e17c6579	{"action":"login","actor_id":"4d6dc0fa-8a2f-4073-9bbd-85425124beb0","actor_username":"leo_gee87@yahoo.com","actor_via_sso":false,"log_type":"account","traits":{"provider":"email"}}	2025-06-15 14:38:33.647014+00	
00000000-0000-0000-0000-000000000000	536c5047-24e6-42c0-804f-d73c4cfec8e3	{"action":"user_signedup","actor_id":"e81e22aa-0578-4fb2-8d0b-5665be08b8ee","actor_username":"janechinshuikwen@gmail.com","actor_via_sso":false,"log_type":"team","traits":{"provider":"email"}}	2025-06-15 14:38:33.747919+00	
00000000-0000-0000-0000-000000000000	4ad6c6db-5118-4b0c-bf49-a907653949cb	{"action":"login","actor_id":"e81e22aa-0578-4fb2-8d0b-5665be08b8ee","actor_username":"janechinshuikwen@gmail.com","actor_via_sso":false,"log_type":"account","traits":{"provider":"email"}}	2025-06-15 14:38:33.749785+00	
00000000-0000-0000-0000-000000000000	51d44fda-3405-4c62-8849-b3ee7980d023	{"action":"user_signedup","actor_id":"bf3f6921-ab2d-4b8b-936f-38da5143c31d","actor_username":"rusnanit78@gmail.com","actor_via_sso":false,"log_type":"team","traits":{"provider":"email"}}	2025-06-15 14:38:33.839743+00	
00000000-0000-0000-0000-000000000000	6adb49b3-aeef-4b0c-980c-d976f5694348	{"action":"login","actor_id":"bf3f6921-ab2d-4b8b-936f-38da5143c31d","actor_username":"rusnanit78@gmail.com","actor_via_sso":false,"log_type":"account","traits":{"provider":"email"}}	2025-06-15 14:38:33.841232+00	
00000000-0000-0000-0000-000000000000	1bc55f50-a37b-4d21-9e43-67e3dd0eab46	{"action":"user_signedup","actor_id":"3d06ba74-5af0-499d-81fa-6a61febaa57d","actor_username":"nuramsconsultant@gmail.com","actor_via_sso":false,"log_type":"team","traits":{"provider":"email"}}	2025-06-15 14:38:33.933865+00	
00000000-0000-0000-0000-000000000000	c3dba16d-b29b-4963-bf31-bb68f0e38c75	{"action":"login","actor_id":"3d06ba74-5af0-499d-81fa-6a61febaa57d","actor_username":"nuramsconsultant@gmail.com","actor_via_sso":false,"log_type":"account","traits":{"provider":"email"}}	2025-06-15 14:38:33.935257+00	
00000000-0000-0000-0000-000000000000	1cac9d2a-2011-4ceb-87ed-8a978e450724	{"action":"user_signedup","actor_id":"d0e4fb36-fb0a-4767-a333-531cbb37e035","actor_username":"sriganda2003@gmail.com","actor_via_sso":false,"log_type":"team","traits":{"provider":"email"}}	2025-06-15 14:38:34.027413+00	
00000000-0000-0000-0000-000000000000	33d9d3fc-37fb-4666-b5d4-df7a1b72d0b3	{"action":"login","actor_id":"d0e4fb36-fb0a-4767-a333-531cbb37e035","actor_username":"sriganda2003@gmail.com","actor_via_sso":false,"log_type":"account","traits":{"provider":"email"}}	2025-06-15 14:38:34.029064+00	
00000000-0000-0000-0000-000000000000	caccc296-c15c-4796-9b39-ab37508c2920	{"action":"user_signedup","actor_id":"cedde969-4985-499b-a05c-5325099bf7aa","actor_username":"goldenelate.pom@gmail.com","actor_via_sso":false,"log_type":"team","traits":{"provider":"email"}}	2025-06-15 14:38:34.121303+00	
00000000-0000-0000-0000-000000000000	5cb7538b-2445-4f92-8358-f9e896aa5fe1	{"action":"login","actor_id":"cedde969-4985-499b-a05c-5325099bf7aa","actor_username":"goldenelate.pom@gmail.com","actor_via_sso":false,"log_type":"account","traits":{"provider":"email"}}	2025-06-15 14:38:34.122898+00	
00000000-0000-0000-0000-000000000000	f266094d-a458-4e7e-a7d7-0f8cb0b90d8d	{"action":"user_signedup","actor_id":"13b7d6b3-42a7-40ec-b227-f1b91f791dcc","actor_username":"amirul@kksl.com.my","actor_via_sso":false,"log_type":"team","traits":{"provider":"email"}}	2025-06-15 14:38:34.228707+00	
00000000-0000-0000-0000-000000000000	d8e6ee7a-5c3b-42c4-b147-fabdc1ed2193	{"action":"login","actor_id":"13b7d6b3-42a7-40ec-b227-f1b91f791dcc","actor_username":"amirul@kksl.com.my","actor_via_sso":false,"log_type":"account","traits":{"provider":"email"}}	2025-06-15 14:38:34.230341+00	
00000000-0000-0000-0000-000000000000	1b43dc5b-000f-43d0-be9a-f6dec3d16777	{"action":"user_signedup","actor_id":"4287988f-93ab-4a3c-9790-77473ef7f799","actor_username":"ephremryanalphonsus@gmail.com","actor_via_sso":false,"log_type":"team","traits":{"provider":"email"}}	2025-06-15 14:38:34.32917+00	
00000000-0000-0000-0000-000000000000	b79ca451-029e-4443-a196-ce7351812d14	{"action":"login","actor_id":"4287988f-93ab-4a3c-9790-77473ef7f799","actor_username":"ephremryanalphonsus@gmail.com","actor_via_sso":false,"log_type":"account","traits":{"provider":"email"}}	2025-06-15 14:38:34.330672+00	
00000000-0000-0000-0000-000000000000	2457954c-099e-4d8e-9381-b2f4059793e5	{"action":"user_signedup","actor_id":"12c58e57-7eb9-4e61-a298-52c44ab6e5e2","actor_username":"chongchungwai@icloud.com","actor_via_sso":false,"log_type":"team","traits":{"provider":"email"}}	2025-06-15 14:38:34.420917+00	
00000000-0000-0000-0000-000000000000	c6cc13ff-514f-47a5-9ba1-824f07c70674	{"action":"login","actor_id":"12c58e57-7eb9-4e61-a298-52c44ab6e5e2","actor_username":"chongchungwai@icloud.com","actor_via_sso":false,"log_type":"account","traits":{"provider":"email"}}	2025-06-15 14:38:34.422576+00	
00000000-0000-0000-0000-000000000000	76860928-89aa-4f51-8452-679d3c706c96	{"action":"user_signedup","actor_id":"f36f7e40-f5fb-4c87-a096-a88c211d6bd2","actor_username":"n.hazirahismail@gmail.com","actor_via_sso":false,"log_type":"team","traits":{"provider":"email"}}	2025-06-15 14:38:34.523053+00	
00000000-0000-0000-0000-000000000000	5feba4fa-9d50-4770-a57b-736e95a566d8	{"action":"login","actor_id":"f36f7e40-f5fb-4c87-a096-a88c211d6bd2","actor_username":"n.hazirahismail@gmail.com","actor_via_sso":false,"log_type":"account","traits":{"provider":"email"}}	2025-06-15 14:38:34.524569+00	
00000000-0000-0000-0000-000000000000	b2a66953-f331-4587-a799-e52f4272c250	{"action":"user_signedup","actor_id":"812c46f2-6962-4df8-90c0-f5dee109c540","actor_username":"varmavarma186@gmail.com","actor_via_sso":false,"log_type":"team","traits":{"provider":"email"}}	2025-06-15 14:38:34.616616+00	
00000000-0000-0000-0000-000000000000	0b4f73f5-0d67-437c-b34a-f04e646a4324	{"action":"login","actor_id":"812c46f2-6962-4df8-90c0-f5dee109c540","actor_username":"varmavarma186@gmail.com","actor_via_sso":false,"log_type":"account","traits":{"provider":"email"}}	2025-06-15 14:38:34.618224+00	
00000000-0000-0000-0000-000000000000	e514d9bb-1407-445f-b85f-a152604b0f91	{"action":"user_signedup","actor_id":"a54f43bc-3510-4267-9c02-de241f28979b","actor_username":"foemalaysia@gmail.com","actor_via_sso":false,"log_type":"team","traits":{"provider":"email"}}	2025-06-15 14:38:34.737323+00	
00000000-0000-0000-0000-000000000000	f96e705d-808c-472c-beb9-2df8cfa5580c	{"action":"login","actor_id":"a54f43bc-3510-4267-9c02-de241f28979b","actor_username":"foemalaysia@gmail.com","actor_via_sso":false,"log_type":"account","traits":{"provider":"email"}}	2025-06-15 14:38:34.739635+00	
00000000-0000-0000-0000-000000000000	36f31184-8ed5-476a-b49c-1df12ae3407a	{"action":"user_signedup","actor_id":"ded6488b-469e-484e-b815-a00534d3e10f","actor_username":"ameer.h@fgvholdings.com","actor_via_sso":false,"log_type":"team","traits":{"provider":"email"}}	2025-06-15 14:38:34.838712+00	
00000000-0000-0000-0000-000000000000	62d097dc-9932-4a6c-a3b0-c1a28905c9cd	{"action":"login","actor_id":"ded6488b-469e-484e-b815-a00534d3e10f","actor_username":"ameer.h@fgvholdings.com","actor_via_sso":false,"log_type":"account","traits":{"provider":"email"}}	2025-06-15 14:38:34.840434+00	
00000000-0000-0000-0000-000000000000	c537eedd-e33d-4de9-a854-5a6a43a330f9	{"action":"user_signedup","actor_id":"c0c0c1da-11f3-4065-aa98-82084870eea4","actor_username":"aldosualin@gmail.com","actor_via_sso":false,"log_type":"team","traits":{"provider":"email"}}	2025-06-15 14:38:34.932189+00	
00000000-0000-0000-0000-000000000000	e435b000-abb0-43bf-ae66-3702e135f5b5	{"action":"login","actor_id":"c0c0c1da-11f3-4065-aa98-82084870eea4","actor_username":"aldosualin@gmail.com","actor_via_sso":false,"log_type":"account","traits":{"provider":"email"}}	2025-06-15 14:38:34.933683+00	
00000000-0000-0000-0000-000000000000	4affb6ca-0590-4e72-bd14-e6207839cd39	{"action":"user_signedup","actor_id":"e0cf9d78-629a-4f0c-8c5e-d4eb659c758a","actor_username":"jamal@ggc.my","actor_via_sso":false,"log_type":"team","traits":{"provider":"email"}}	2025-06-15 14:38:35.019767+00	
00000000-0000-0000-0000-000000000000	73abbe54-cba2-48b4-bf4c-0d636dfb3b3f	{"action":"login","actor_id":"e0cf9d78-629a-4f0c-8c5e-d4eb659c758a","actor_username":"jamal@ggc.my","actor_via_sso":false,"log_type":"account","traits":{"provider":"email"}}	2025-06-15 14:38:35.021237+00	
00000000-0000-0000-0000-000000000000	0d0e17e3-f51c-471e-912b-1509de470f38	{"action":"user_signedup","actor_id":"0f718b43-671c-4b6f-b906-34ee7b45b4b2","actor_username":"thilaganarthan@gmail.com","actor_via_sso":false,"log_type":"team","traits":{"provider":"email"}}	2025-06-15 14:38:35.111032+00	
00000000-0000-0000-0000-000000000000	d44ee982-900d-4384-81c7-44e08bb055e0	{"action":"login","actor_id":"0f718b43-671c-4b6f-b906-34ee7b45b4b2","actor_username":"thilaganarthan@gmail.com","actor_via_sso":false,"log_type":"account","traits":{"provider":"email"}}	2025-06-15 14:38:35.11255+00	
00000000-0000-0000-0000-000000000000	ef56bde7-8f50-4529-ba56-4b1cedd8e65d	{"action":"user_signedup","actor_id":"c3430ef8-bea7-4d77-840d-7e1847682f45","actor_username":"gmm@ioigroup.com","actor_via_sso":false,"log_type":"team","traits":{"provider":"email"}}	2025-06-15 14:38:35.205884+00	
00000000-0000-0000-0000-000000000000	1013e73a-c2a6-453d-9a1c-13355d4421ec	{"action":"login","actor_id":"c3430ef8-bea7-4d77-840d-7e1847682f45","actor_username":"gmm@ioigroup.com","actor_via_sso":false,"log_type":"account","traits":{"provider":"email"}}	2025-06-15 14:38:35.207667+00	
00000000-0000-0000-0000-000000000000	bbf63965-35b9-4301-bc3f-300197669d1c	{"action":"user_signedup","actor_id":"0dfa2c7d-310b-4a83-98f5-197421843955","actor_username":"wzynole@gmail.com","actor_via_sso":false,"log_type":"team","traits":{"provider":"email"}}	2025-06-15 14:38:35.307198+00	
00000000-0000-0000-0000-000000000000	4a8988cf-15b1-48f2-b7f4-6deded0953e6	{"action":"login","actor_id":"0dfa2c7d-310b-4a83-98f5-197421843955","actor_username":"wzynole@gmail.com","actor_via_sso":false,"log_type":"account","traits":{"provider":"email"}}	2025-06-15 14:38:35.30882+00	
00000000-0000-0000-0000-000000000000	d0be633d-31e4-4a85-b156-ce72220d8f77	{"action":"user_signedup","actor_id":"b0b2df8d-3835-4d06-a95d-d6a376b95ea1","actor_username":"adeline.stefanie.ta@gmail.com","actor_via_sso":false,"log_type":"team","traits":{"provider":"email"}}	2025-06-15 14:38:35.402095+00	
00000000-0000-0000-0000-000000000000	ddd95508-04d3-4530-bdcd-a8f3c3a67668	{"action":"login","actor_id":"b0b2df8d-3835-4d06-a95d-d6a376b95ea1","actor_username":"adeline.stefanie.ta@gmail.com","actor_via_sso":false,"log_type":"account","traits":{"provider":"email"}}	2025-06-15 14:38:35.404386+00	
00000000-0000-0000-0000-000000000000	fac603a4-d5aa-4d7d-bf4e-da0b5c094750	{"action":"user_signedup","actor_id":"1f99b32d-2a96-4760-b450-ed45b0abe4d1","actor_username":"monalizalidom81@gmail.com","actor_via_sso":false,"log_type":"team","traits":{"provider":"email"}}	2025-06-15 14:38:35.501305+00	
00000000-0000-0000-0000-000000000000	c49a95d0-80a7-4670-8b8c-cfb1dd37a97c	{"action":"login","actor_id":"1f99b32d-2a96-4760-b450-ed45b0abe4d1","actor_username":"monalizalidom81@gmail.com","actor_via_sso":false,"log_type":"account","traits":{"provider":"email"}}	2025-06-15 14:38:35.502864+00	
00000000-0000-0000-0000-000000000000	bb5e773f-299b-4307-b91b-7d0496356692	{"action":"user_signedup","actor_id":"1b9260e9-b2bc-4ac3-86ed-cd13d669bd46","actor_username":"suryantiselalukecewa@gmail.com","actor_via_sso":false,"log_type":"team","traits":{"provider":"email"}}	2025-06-15 14:38:35.600331+00	
00000000-0000-0000-0000-000000000000	101a67b7-232d-4b5b-b729-4c16d9f9b749	{"action":"login","actor_id":"1b9260e9-b2bc-4ac3-86ed-cd13d669bd46","actor_username":"suryantiselalukecewa@gmail.com","actor_via_sso":false,"log_type":"account","traits":{"provider":"email"}}	2025-06-15 14:38:35.602115+00	
00000000-0000-0000-0000-000000000000	9e9eb11c-508d-486a-96ba-f016a2e7292f	{"action":"user_signedup","actor_id":"457acf64-4b5a-49a5-8f67-2aa577cec7ec","actor_username":"hazirah@airei.com.my","actor_via_sso":false,"log_type":"team","traits":{"provider":"email"}}	2025-06-15 14:38:35.695847+00	
00000000-0000-0000-0000-000000000000	8c4ed3f3-ffd2-4084-b34c-847599b86351	{"action":"login","actor_id":"457acf64-4b5a-49a5-8f67-2aa577cec7ec","actor_username":"hazirah@airei.com.my","actor_via_sso":false,"log_type":"account","traits":{"provider":"email"}}	2025-06-15 14:38:35.69734+00	
00000000-0000-0000-0000-000000000000	70c4234a-7ae6-4397-bf63-8743f3239890	{"action":"user_signedup","actor_id":"f22bd07e-28a0-4135-b73e-fb6629087485","actor_username":"suburbanpom@gmail.com","actor_via_sso":false,"log_type":"team","traits":{"provider":"email"}}	2025-06-15 14:38:35.791364+00	
00000000-0000-0000-0000-000000000000	55d82c99-ce32-48ee-bef1-58994aaed5be	{"action":"login","actor_id":"f22bd07e-28a0-4135-b73e-fb6629087485","actor_username":"suburbanpom@gmail.com","actor_via_sso":false,"log_type":"account","traits":{"provider":"email"}}	2025-06-15 14:38:35.792987+00	
00000000-0000-0000-0000-000000000000	694d1b9c-efcc-454e-9548-623e98d12eb6	{"action":"user_signedup","actor_id":"80708127-7fdf-4c9d-8b6f-315c374c0cf4","actor_username":"kyting@jayatiasa.net","actor_via_sso":false,"log_type":"team","traits":{"provider":"email"}}	2025-06-15 14:38:35.885196+00	
00000000-0000-0000-0000-000000000000	3ea8ebb6-a0d5-4793-890b-bd74b35f9738	{"action":"login","actor_id":"80708127-7fdf-4c9d-8b6f-315c374c0cf4","actor_username":"kyting@jayatiasa.net","actor_via_sso":false,"log_type":"account","traits":{"provider":"email"}}	2025-06-15 14:38:35.886826+00	
00000000-0000-0000-0000-000000000000	a36b7ce9-8307-4350-935b-27a1408ca55b	{"action":"user_signedup","actor_id":"536203a3-6335-4c60-ae6f-f852135c5419","actor_username":"amiratul.aniqah@mpob.gov.my","actor_via_sso":false,"log_type":"team","traits":{"provider":"email"}}	2025-06-15 14:38:35.988757+00	
00000000-0000-0000-0000-000000000000	a8982b82-f50c-44ea-b59e-37be479740fa	{"action":"login","actor_id":"536203a3-6335-4c60-ae6f-f852135c5419","actor_username":"amiratul.aniqah@mpob.gov.my","actor_via_sso":false,"log_type":"account","traits":{"provider":"email"}}	2025-06-15 14:38:35.990356+00	
00000000-0000-0000-0000-000000000000	5b51268a-8c4f-4953-8b36-5abcca3b17ec	{"action":"user_signedup","actor_id":"4da24124-a1ef-4efe-832d-a89ddfd8945a","actor_username":"mutuagungmalaysia@gmail.com","actor_via_sso":false,"log_type":"team","traits":{"provider":"email"}}	2025-06-15 14:38:36.085149+00	
00000000-0000-0000-0000-000000000000	16497c6c-2ba9-4ea7-b243-67f72b15a99f	{"action":"login","actor_id":"4da24124-a1ef-4efe-832d-a89ddfd8945a","actor_username":"mutuagungmalaysia@gmail.com","actor_via_sso":false,"log_type":"account","traits":{"provider":"email"}}	2025-06-15 14:38:36.08665+00	
00000000-0000-0000-0000-000000000000	f5ed1b4d-6de4-4366-af25-4137ea4b8077	{"action":"user_signedup","actor_id":"3ce70501-e74f-4420-bc0a-3eac51f2dbe4","actor_username":"sadiahq@gmail.com","actor_via_sso":false,"log_type":"team","traits":{"provider":"email"}}	2025-06-15 14:38:36.178507+00	
00000000-0000-0000-0000-000000000000	b41f25b2-f369-4ca4-90ac-9705dddf97ae	{"action":"login","actor_id":"3ce70501-e74f-4420-bc0a-3eac51f2dbe4","actor_username":"sadiahq@gmail.com","actor_via_sso":false,"log_type":"account","traits":{"provider":"email"}}	2025-06-15 14:38:36.179987+00	
00000000-0000-0000-0000-000000000000	27684747-e5dd-436c-979a-3c3d6a929df8	{"action":"user_signedup","actor_id":"d8d76d24-14d4-4e46-92ad-5907d27fe2e0","actor_username":"hasronnorraimi@yahoo.com","actor_via_sso":false,"log_type":"team","traits":{"provider":"email"}}	2025-06-15 14:38:36.274432+00	
00000000-0000-0000-0000-000000000000	16ff6676-c5ac-4a19-808d-46dcf06191e0	{"action":"login","actor_id":"d8d76d24-14d4-4e46-92ad-5907d27fe2e0","actor_username":"hasronnorraimi@yahoo.com","actor_via_sso":false,"log_type":"account","traits":{"provider":"email"}}	2025-06-15 14:38:36.276147+00	
00000000-0000-0000-0000-000000000000	8cdb508b-2fd4-444b-9bb5-600b60574946	{"action":"user_signedup","actor_id":"e80a6ccf-333b-407f-ae20-ae04ee67f667","actor_username":"josephjanting@gmail.com","actor_via_sso":false,"log_type":"team","traits":{"provider":"email"}}	2025-06-15 14:38:36.371191+00	
00000000-0000-0000-0000-000000000000	d2680572-8103-4fba-8687-1428231bd0e1	{"action":"login","actor_id":"e80a6ccf-333b-407f-ae20-ae04ee67f667","actor_username":"josephjanting@gmail.com","actor_via_sso":false,"log_type":"account","traits":{"provider":"email"}}	2025-06-15 14:38:36.372774+00	
00000000-0000-0000-0000-000000000000	c0357294-6ca0-4486-a969-fccae723eef0	{"action":"user_signedup","actor_id":"7c42038f-aa20-4f20-ba43-839d3474a560","actor_username":"rusdi@primulagemilang.com","actor_via_sso":false,"log_type":"team","traits":{"provider":"email"}}	2025-06-15 14:38:36.470642+00	
00000000-0000-0000-0000-000000000000	49bfd21b-df77-4cac-a24f-a244c001a51f	{"action":"login","actor_id":"7c42038f-aa20-4f20-ba43-839d3474a560","actor_username":"rusdi@primulagemilang.com","actor_via_sso":false,"log_type":"account","traits":{"provider":"email"}}	2025-06-15 14:38:36.47245+00	
00000000-0000-0000-0000-000000000000	76cc577f-b1f7-479d-b1a1-62eabb294280	{"action":"user_signedup","actor_id":"a0b845cc-2c32-421e-9f3e-ebfe8e22cd15","actor_username":"spadmukahmill@gmail.com","actor_via_sso":false,"log_type":"team","traits":{"provider":"email"}}	2025-06-15 14:38:36.565856+00	
00000000-0000-0000-0000-000000000000	441d1399-6bce-441e-b87a-8fd52694c258	{"action":"login","actor_id":"a0b845cc-2c32-421e-9f3e-ebfe8e22cd15","actor_username":"spadmukahmill@gmail.com","actor_via_sso":false,"log_type":"account","traits":{"provider":"email"}}	2025-06-15 14:38:36.567377+00	
00000000-0000-0000-0000-000000000000	12aa419f-c480-4844-8e61-4b2ac5d5035b	{"action":"user_signedup","actor_id":"e5871981-e66c-4c44-9183-0e8084e874c9","actor_username":"luangbadol@gmail.com","actor_via_sso":false,"log_type":"team","traits":{"provider":"email"}}	2025-06-15 14:38:36.668767+00	
00000000-0000-0000-0000-000000000000	2af6950e-c935-4a7b-8649-d1dfa8463001	{"action":"login","actor_id":"e5871981-e66c-4c44-9183-0e8084e874c9","actor_username":"luangbadol@gmail.com","actor_via_sso":false,"log_type":"account","traits":{"provider":"email"}}	2025-06-15 14:38:36.670213+00	
00000000-0000-0000-0000-000000000000	36a87497-8037-4b43-82be-449771f76c10	{"action":"user_signedup","actor_id":"582f5571-b638-444b-9527-12503ce384a3","actor_username":"adninaminurrashid@gmail.com","actor_via_sso":false,"log_type":"team","traits":{"provider":"email"}}	2025-06-15 14:38:36.762276+00	
00000000-0000-0000-0000-000000000000	2f5c994e-0e46-406a-90e0-7991c7c810f0	{"action":"login","actor_id":"582f5571-b638-444b-9527-12503ce384a3","actor_username":"adninaminurrashid@gmail.com","actor_via_sso":false,"log_type":"account","traits":{"provider":"email"}}	2025-06-15 14:38:36.763822+00	
00000000-0000-0000-0000-000000000000	e11e3985-761b-4e86-8e63-3093aaa6e0d9	{"action":"user_signedup","actor_id":"05039a36-049a-47b0-9e99-6de64a44acbd","actor_username":"mspo2019@yahoo.com","actor_via_sso":false,"log_type":"team","traits":{"provider":"email"}}	2025-06-15 14:38:36.860386+00	
00000000-0000-0000-0000-000000000000	047ed353-4127-4702-a232-94337c32d68c	{"action":"login","actor_id":"05039a36-049a-47b0-9e99-6de64a44acbd","actor_username":"mspo2019@yahoo.com","actor_via_sso":false,"log_type":"account","traits":{"provider":"email"}}	2025-06-15 14:38:36.86206+00	
00000000-0000-0000-0000-000000000000	bec9a93c-4fe8-4878-9967-f34da3a03964	{"action":"user_signedup","actor_id":"14e4c67b-bcde-4704-a97f-0dcbe1717dc5","actor_username":"whistlecert@gmail.com","actor_via_sso":false,"log_type":"team","traits":{"provider":"email"}}	2025-06-15 14:38:36.953925+00	
00000000-0000-0000-0000-000000000000	c8e37fb5-bde2-4b36-bdb0-c118669884ee	{"action":"login","actor_id":"14e4c67b-bcde-4704-a97f-0dcbe1717dc5","actor_username":"whistlecert@gmail.com","actor_via_sso":false,"log_type":"account","traits":{"provider":"email"}}	2025-06-15 14:38:36.955603+00	
00000000-0000-0000-0000-000000000000	1000d018-b3b2-4051-99ef-67db3b35167a	{"action":"user_signedup","actor_id":"4e33cfac-f5fe-4c35-9861-84d7917606ae","actor_username":"rveerasa@hotmail.com","actor_via_sso":false,"log_type":"team","traits":{"provider":"email"}}	2025-06-15 14:38:37.049837+00	
00000000-0000-0000-0000-000000000000	175f7b22-760d-4b90-8618-cd21c4619032	{"action":"login","actor_id":"4e33cfac-f5fe-4c35-9861-84d7917606ae","actor_username":"rveerasa@hotmail.com","actor_via_sso":false,"log_type":"account","traits":{"provider":"email"}}	2025-06-15 14:38:37.051573+00	
00000000-0000-0000-0000-000000000000	a8f24c43-70e4-4831-b393-ef520d2f9f48	{"action":"user_signedup","actor_id":"34e9281c-a3b1-412d-ba7e-fe29dad024c9","actor_username":"mateksadiahq@gmail.com","actor_via_sso":false,"log_type":"team","traits":{"provider":"email"}}	2025-06-15 14:38:37.139793+00	
00000000-0000-0000-0000-000000000000	d0104a3b-4654-4b03-91d3-2086dede8324	{"action":"login","actor_id":"34e9281c-a3b1-412d-ba7e-fe29dad024c9","actor_username":"mateksadiahq@gmail.com","actor_via_sso":false,"log_type":"account","traits":{"provider":"email"}}	2025-06-15 14:38:37.141428+00	
00000000-0000-0000-0000-000000000000	b5b25c17-ede2-4ee8-8a3e-dc8f466f6c17	{"action":"user_signedup","actor_id":"8d6c1385-fa01-48c7-b761-4e0ebdcab162","actor_username":"hello@bliss.com","actor_via_sso":false,"log_type":"team","traits":{"provider":"email"}}	2025-06-15 14:38:37.242149+00	
00000000-0000-0000-0000-000000000000	ec9800c0-6878-4669-85d0-4f0718b16915	{"action":"login","actor_id":"8d6c1385-fa01-48c7-b761-4e0ebdcab162","actor_username":"hello@bliss.com","actor_via_sso":false,"log_type":"account","traits":{"provider":"email"}}	2025-06-15 14:38:37.24363+00	
00000000-0000-0000-0000-000000000000	812091e9-1c2b-4e08-ac41-8f51f1d31181	{"action":"user_signedup","actor_id":"d8b08679-718a-49dc-a81d-141d5a5b048d","actor_username":"sustainabilitypr.ppom@gmail.com","actor_via_sso":false,"log_type":"team","traits":{"provider":"email"}}	2025-06-15 14:38:37.339208+00	
00000000-0000-0000-0000-000000000000	02f8fa3c-a5e2-4621-8652-883f56419a2f	{"action":"login","actor_id":"d8b08679-718a-49dc-a81d-141d5a5b048d","actor_username":"sustainabilitypr.ppom@gmail.com","actor_via_sso":false,"log_type":"account","traits":{"provider":"email"}}	2025-06-15 14:38:37.341048+00	
00000000-0000-0000-0000-000000000000	b6f13a81-ff54-4c76-9f56-d8796057683b	{"action":"user_signedup","actor_id":"54003f0f-9dc2-4142-a7a3-37781c6caa2f","actor_username":"muhsienbadrulisham@gmail.com","actor_via_sso":false,"log_type":"team","traits":{"provider":"email"}}	2025-06-15 14:38:37.435189+00	
00000000-0000-0000-0000-000000000000	4516fb5f-d15f-47f7-9683-8c208b69feb3	{"action":"login","actor_id":"54003f0f-9dc2-4142-a7a3-37781c6caa2f","actor_username":"muhsienbadrulisham@gmail.com","actor_via_sso":false,"log_type":"account","traits":{"provider":"email"}}	2025-06-15 14:38:37.437119+00	
00000000-0000-0000-0000-000000000000	c76b23fa-ae3d-4d2e-88c9-a8d1c092ed9c	{"action":"user_signedup","actor_id":"0a7806d8-7b08-4629-bcfc-b5304bc684c4","actor_username":"murshidayusoff@gmail.com","actor_via_sso":false,"log_type":"team","traits":{"provider":"email"}}	2025-06-15 14:38:37.525849+00	
00000000-0000-0000-0000-000000000000	4083497d-bcda-4395-be0c-aceded1eb77e	{"action":"login","actor_id":"0a7806d8-7b08-4629-bcfc-b5304bc684c4","actor_username":"murshidayusoff@gmail.com","actor_via_sso":false,"log_type":"account","traits":{"provider":"email"}}	2025-06-15 14:38:37.527545+00	
00000000-0000-0000-0000-000000000000	51344f82-461a-4821-9bd1-39beb2aa7c48	{"action":"user_signedup","actor_id":"2abe0ef5-50a6-4f32-bcd0-ccbb192771c5","actor_username":"chitra.loganathan@agrobank.com.my","actor_via_sso":false,"log_type":"team","traits":{"provider":"email"}}	2025-06-15 14:38:37.620594+00	
00000000-0000-0000-0000-000000000000	ce7042a4-dc29-4926-916c-e74b0d90c370	{"action":"login","actor_id":"2abe0ef5-50a6-4f32-bcd0-ccbb192771c5","actor_username":"chitra.loganathan@agrobank.com.my","actor_via_sso":false,"log_type":"account","traits":{"provider":"email"}}	2025-06-15 14:38:37.62204+00	
00000000-0000-0000-0000-000000000000	eeef8fcb-d497-4843-8337-e869b4675238	{"action":"user_signedup","actor_id":"0919a2be-3b19-418f-91e8-ae8a8ffd3e48","actor_username":"baxteraymond@gmail.com","actor_via_sso":false,"log_type":"team","traits":{"provider":"email"}}	2025-06-15 14:38:37.728759+00	
00000000-0000-0000-0000-000000000000	71f4cb34-f294-48aa-8340-387c43c9e762	{"action":"login","actor_id":"0919a2be-3b19-418f-91e8-ae8a8ffd3e48","actor_username":"baxteraymond@gmail.com","actor_via_sso":false,"log_type":"account","traits":{"provider":"email"}}	2025-06-15 14:38:37.730759+00	
00000000-0000-0000-0000-000000000000	bb909676-1228-4916-b5b1-303ac844a466	{"action":"user_signedup","actor_id":"01f2db6b-0dc0-45f1-842b-aced9d793fe6","actor_username":"nazmizain4499@yahoo.com","actor_via_sso":false,"log_type":"team","traits":{"provider":"email"}}	2025-06-15 14:38:37.821264+00	
00000000-0000-0000-0000-000000000000	ea7af4d8-87de-4f6a-b5fa-77961f1dd119	{"action":"login","actor_id":"01f2db6b-0dc0-45f1-842b-aced9d793fe6","actor_username":"nazmizain4499@yahoo.com","actor_via_sso":false,"log_type":"account","traits":{"provider":"email"}}	2025-06-15 14:38:37.822895+00	
00000000-0000-0000-0000-000000000000	c3277cac-f719-4b8d-879e-8f949c46f67c	{"action":"user_signedup","actor_id":"2fc4583b-c10b-423a-a6fe-a5e25b7bc801","actor_username":"monsokmill@gmail.com","actor_via_sso":false,"log_type":"team","traits":{"provider":"email"}}	2025-06-15 14:38:37.924382+00	
00000000-0000-0000-0000-000000000000	78979c3c-0e1c-47fb-a839-a5ae4da3c212	{"action":"login","actor_id":"2fc4583b-c10b-423a-a6fe-a5e25b7bc801","actor_username":"monsokmill@gmail.com","actor_via_sso":false,"log_type":"account","traits":{"provider":"email"}}	2025-06-15 14:38:37.926044+00	
00000000-0000-0000-0000-000000000000	8c02b821-88e7-419a-b23c-e7c6dfd388d8	{"action":"user_signedup","actor_id":"15f0f3a4-341a-4342-bca2-11c1d03d82a6","actor_username":"parameswaran_subramaniam@jabil.com","actor_via_sso":false,"log_type":"team","traits":{"provider":"email"}}	2025-06-15 14:38:38.027308+00	
00000000-0000-0000-0000-000000000000	c08c3790-afb5-46b6-9083-1cea33cbc0c7	{"action":"login","actor_id":"15f0f3a4-341a-4342-bca2-11c1d03d82a6","actor_username":"parameswaran_subramaniam@jabil.com","actor_via_sso":false,"log_type":"account","traits":{"provider":"email"}}	2025-06-15 14:38:38.028936+00	
00000000-0000-0000-0000-000000000000	03571898-0c97-4180-b894-2dddaa0e1237	{"action":"user_signedup","actor_id":"4af83a63-96e1-44ea-a7aa-749a66e5fcd7","actor_username":"michaeln@sarawak.gov.my","actor_via_sso":false,"log_type":"team","traits":{"provider":"email"}}	2025-06-15 14:38:38.119758+00	
00000000-0000-0000-0000-000000000000	12f81037-6ec4-4a64-8695-57d21661bb4a	{"action":"login","actor_id":"4af83a63-96e1-44ea-a7aa-749a66e5fcd7","actor_username":"michaeln@sarawak.gov.my","actor_via_sso":false,"log_type":"account","traits":{"provider":"email"}}	2025-06-15 14:38:38.121418+00	
00000000-0000-0000-0000-000000000000	48cd2ab2-7ca1-4984-a597-46b3e635067c	{"action":"user_signedup","actor_id":"24f097e0-aad9-486d-887d-590379cf8f78","actor_username":"kasthuri@unitedmalacca.com.my","actor_via_sso":false,"log_type":"team","traits":{"provider":"email"}}	2025-06-15 14:38:38.215702+00	
00000000-0000-0000-0000-000000000000	08280ecb-62d2-4ed7-9601-6d82ae1c93b9	{"action":"login","actor_id":"24f097e0-aad9-486d-887d-590379cf8f78","actor_username":"kasthuri@unitedmalacca.com.my","actor_via_sso":false,"log_type":"account","traits":{"provider":"email"}}	2025-06-15 14:38:38.217202+00	
00000000-0000-0000-0000-000000000000	e84b52c5-38c4-42cc-9fe5-f17498640dcb	{"action":"user_signedup","actor_id":"3a62ecb7-b6c8-4883-9066-4e1a871adc12","actor_username":"test@yahoo.com","actor_via_sso":false,"log_type":"team","traits":{"provider":"email"}}	2025-06-15 14:38:38.30632+00	
00000000-0000-0000-0000-000000000000	daa1b895-c72b-44ad-9fd5-25892d43d11d	{"action":"login","actor_id":"3a62ecb7-b6c8-4883-9066-4e1a871adc12","actor_username":"test@yahoo.com","actor_via_sso":false,"log_type":"account","traits":{"provider":"email"}}	2025-06-15 14:38:38.307939+00	
00000000-0000-0000-0000-000000000000	cb7db577-c737-46fd-8922-100241b05f7d	{"action":"user_signedup","actor_id":"bdbfe7f9-be3d-45db-9e74-0bafc00e3da8","actor_username":"rudy_patrick@ymail.com","actor_via_sso":false,"log_type":"team","traits":{"provider":"email"}}	2025-06-15 14:38:38.402787+00	
00000000-0000-0000-0000-000000000000	3782a9b2-1837-4027-8455-06dfe45efaaa	{"action":"login","actor_id":"bdbfe7f9-be3d-45db-9e74-0bafc00e3da8","actor_username":"rudy_patrick@ymail.com","actor_via_sso":false,"log_type":"account","traits":{"provider":"email"}}	2025-06-15 14:38:38.404277+00	
00000000-0000-0000-0000-000000000000	7c36a364-7796-48c1-b5bb-5d4a75e802fd	{"action":"user_signedup","actor_id":"8d17a10c-9baa-4371-be70-35eff53317e4","actor_username":"padil5595@gmail.com","actor_via_sso":false,"log_type":"team","traits":{"provider":"email"}}	2025-06-15 14:38:38.490746+00	
00000000-0000-0000-0000-000000000000	40b5b0e8-b36e-4efa-b0aa-d03d17d7a337	{"action":"login","actor_id":"8d17a10c-9baa-4371-be70-35eff53317e4","actor_username":"padil5595@gmail.com","actor_via_sso":false,"log_type":"account","traits":{"provider":"email"}}	2025-06-15 14:38:38.492206+00	
00000000-0000-0000-0000-000000000000	0bb875b6-c5b4-4aeb-b11c-469984d5b768	{"action":"user_signedup","actor_id":"e8e773cd-d387-4efc-b92e-98dd804a3dd3","actor_username":"nurulsyahira336@gmail.com","actor_via_sso":false,"log_type":"team","traits":{"provider":"email"}}	2025-06-15 14:38:38.581934+00	
00000000-0000-0000-0000-000000000000	f2e66315-9d37-4efc-9a21-47f2db7494ff	{"action":"login","actor_id":"e8e773cd-d387-4efc-b92e-98dd804a3dd3","actor_username":"nurulsyahira336@gmail.com","actor_via_sso":false,"log_type":"account","traits":{"provider":"email"}}	2025-06-15 14:38:38.584296+00	
00000000-0000-0000-0000-000000000000	60a5aa21-c905-4224-8f95-637cf0a9b10d	{"action":"user_signedup","actor_id":"e1ccea0a-ccc5-48c9-98dd-26a48399ec52","actor_username":"suhaidakanjisuhaida@gmail.com","actor_via_sso":false,"log_type":"team","traits":{"provider":"email"}}	2025-06-15 14:38:38.676163+00	
00000000-0000-0000-0000-000000000000	81d11bf7-4dbb-4b13-9144-82b1d2e2a6df	{"action":"login","actor_id":"e1ccea0a-ccc5-48c9-98dd-26a48399ec52","actor_username":"suhaidakanjisuhaida@gmail.com","actor_via_sso":false,"log_type":"account","traits":{"provider":"email"}}	2025-06-15 14:38:38.677868+00	
00000000-0000-0000-0000-000000000000	2b6933fe-92b6-4bd4-8df7-7066fc7f9766	{"action":"user_signedup","actor_id":"cc6ec44c-3285-40f9-84fd-fe38f6cac978","actor_username":"ravestan@gmail.com","actor_via_sso":false,"log_type":"team","traits":{"provider":"email"}}	2025-06-15 14:38:38.778885+00	
00000000-0000-0000-0000-000000000000	0b93737d-420c-4b3d-8828-de1f660a64c1	{"action":"login","actor_id":"cc6ec44c-3285-40f9-84fd-fe38f6cac978","actor_username":"ravestan@gmail.com","actor_via_sso":false,"log_type":"account","traits":{"provider":"email"}}	2025-06-15 14:38:38.780455+00	
00000000-0000-0000-0000-000000000000	5828ce11-ddb5-4385-9375-5cd09b0f9da3	{"action":"user_signedup","actor_id":"5ad2dbaf-6d13-47a0-b9d2-47b7adb86ff0","actor_username":"imj800120@gmail.com","actor_via_sso":false,"log_type":"team","traits":{"provider":"email"}}	2025-06-15 14:38:38.876362+00	
00000000-0000-0000-0000-000000000000	0053d868-8d8b-4319-8bde-40f2e377ca90	{"action":"login","actor_id":"5ad2dbaf-6d13-47a0-b9d2-47b7adb86ff0","actor_username":"imj800120@gmail.com","actor_via_sso":false,"log_type":"account","traits":{"provider":"email"}}	2025-06-15 14:38:38.87788+00	
00000000-0000-0000-0000-000000000000	4b19cb91-bf29-4c8d-9475-a29e7e405b65	{"action":"user_signedup","actor_id":"7d417c53-b437-40ff-911a-8d9eef5e2977","actor_username":"tajuddinkamil@yahoo.com","actor_via_sso":false,"log_type":"team","traits":{"provider":"email"}}	2025-06-15 14:38:38.976313+00	
00000000-0000-0000-0000-000000000000	a792aa19-f9de-49a6-a2b2-bb609869c2e7	{"action":"login","actor_id":"7d417c53-b437-40ff-911a-8d9eef5e2977","actor_username":"tajuddinkamil@yahoo.com","actor_via_sso":false,"log_type":"account","traits":{"provider":"email"}}	2025-06-15 14:38:38.977815+00	
00000000-0000-0000-0000-000000000000	cddba0fb-ec68-4249-a480-86f37b37ed22	{"action":"user_signedup","actor_id":"e6dae6f9-e483-4071-923d-095f173ed23e","actor_username":"dylan.j.ong@gmail.com","actor_via_sso":false,"log_type":"team","traits":{"provider":"email"}}	2025-06-15 14:38:39.068885+00	
00000000-0000-0000-0000-000000000000	63d5dcad-db77-44a8-beed-24f00d0b9783	{"action":"login","actor_id":"e6dae6f9-e483-4071-923d-095f173ed23e","actor_username":"dylan.j.ong@gmail.com","actor_via_sso":false,"log_type":"account","traits":{"provider":"email"}}	2025-06-15 14:38:39.070528+00	
00000000-0000-0000-0000-000000000000	96ea0ebb-86e3-4d32-b2f3-1689ec0dc504	{"action":"user_signedup","actor_id":"24d8cbc0-b247-4c06-bd71-80c775c228f0","actor_username":"solidorient2812@gmail.com","actor_via_sso":false,"log_type":"team","traits":{"provider":"email"}}	2025-06-15 14:38:39.160983+00	
00000000-0000-0000-0000-000000000000	48107623-57e9-4daa-ab88-28a9d7e923df	{"action":"login","actor_id":"24d8cbc0-b247-4c06-bd71-80c775c228f0","actor_username":"solidorient2812@gmail.com","actor_via_sso":false,"log_type":"account","traits":{"provider":"email"}}	2025-06-15 14:38:39.16297+00	
00000000-0000-0000-0000-000000000000	68de26d6-67f0-49b2-9319-23275f8b7fc8	{"action":"user_signedup","actor_id":"c03ad22a-b91d-4788-9b2e-d4e016651a9b","actor_username":"jasrsb@gmail.com","actor_via_sso":false,"log_type":"team","traits":{"provider":"email"}}	2025-06-15 14:38:39.264626+00	
00000000-0000-0000-0000-000000000000	3bfcd78f-e29d-494b-b969-ca8f5a9e93e9	{"action":"login","actor_id":"c03ad22a-b91d-4788-9b2e-d4e016651a9b","actor_username":"jasrsb@gmail.com","actor_via_sso":false,"log_type":"account","traits":{"provider":"email"}}	2025-06-15 14:38:39.266468+00	
00000000-0000-0000-0000-000000000000	00ffed12-f8fe-4350-aa80-85a2a348eef9	{"action":"user_signedup","actor_id":"fe48a53d-699e-4b91-9987-efdd47b9b34b","actor_username":"andyaw8149@gmail.com","actor_via_sso":false,"log_type":"team","traits":{"provider":"email"}}	2025-06-15 14:38:39.364044+00	
00000000-0000-0000-0000-000000000000	88aaaf82-3826-4151-86c5-eb6375e1d27e	{"action":"login","actor_id":"fe48a53d-699e-4b91-9987-efdd47b9b34b","actor_username":"andyaw8149@gmail.com","actor_via_sso":false,"log_type":"account","traits":{"provider":"email"}}	2025-06-15 14:38:39.365581+00	
00000000-0000-0000-0000-000000000000	058dade2-da8d-4841-bfd9-1364beb7a3c8	{"action":"user_signedup","actor_id":"54762cd7-e15c-4dfe-b8c3-620921ec2366","actor_username":"rose_rmy@hotmail.com","actor_via_sso":false,"log_type":"team","traits":{"provider":"email"}}	2025-06-15 14:38:39.463535+00	
00000000-0000-0000-0000-000000000000	11c5de86-d8ca-48ad-93ec-241c6dab7ce3	{"action":"login","actor_id":"54762cd7-e15c-4dfe-b8c3-620921ec2366","actor_username":"rose_rmy@hotmail.com","actor_via_sso":false,"log_type":"account","traits":{"provider":"email"}}	2025-06-15 14:38:39.465309+00	
00000000-0000-0000-0000-000000000000	16620093-5269-4282-b0d0-563968c5945f	{"action":"user_signedup","actor_id":"6b17a4a1-6399-4241-8bae-98ce72ffd9b8","actor_username":"syafiqdanial1803@hotmail.com","actor_via_sso":false,"log_type":"team","traits":{"provider":"email"}}	2025-06-15 14:38:39.562219+00	
00000000-0000-0000-0000-000000000000	27f2434d-79cc-472e-992c-b2739b1cdbdc	{"action":"login","actor_id":"6b17a4a1-6399-4241-8bae-98ce72ffd9b8","actor_username":"syafiqdanial1803@hotmail.com","actor_via_sso":false,"log_type":"account","traits":{"provider":"email"}}	2025-06-15 14:38:39.563936+00	
00000000-0000-0000-0000-000000000000	0557d856-402a-4a5b-a8bc-fb8baeed3281	{"action":"user_signedup","actor_id":"646b90b4-51f9-44ce-9e89-41492cb826f9","actor_username":"siing8807@gmail.com","actor_via_sso":false,"log_type":"team","traits":{"provider":"email"}}	2025-06-15 14:38:39.660747+00	
00000000-0000-0000-0000-000000000000	d1343312-bb40-44c1-a0ff-f266c7cdd38e	{"action":"login","actor_id":"646b90b4-51f9-44ce-9e89-41492cb826f9","actor_username":"siing8807@gmail.com","actor_via_sso":false,"log_type":"account","traits":{"provider":"email"}}	2025-06-15 14:38:39.662207+00	
00000000-0000-0000-0000-000000000000	28f3641d-fc5e-4963-afa0-8518ced7af05	{"action":"user_signedup","actor_id":"6f88c691-03be-4853-8903-67e2bca0d234","actor_username":"kitying88@gmail.com","actor_via_sso":false,"log_type":"team","traits":{"provider":"email"}}	2025-06-15 14:38:39.770823+00	
00000000-0000-0000-0000-000000000000	66564875-df40-4a5c-ac4a-8adf0100fc91	{"action":"login","actor_id":"6f88c691-03be-4853-8903-67e2bca0d234","actor_username":"kitying88@gmail.com","actor_via_sso":false,"log_type":"account","traits":{"provider":"email"}}	2025-06-15 14:38:39.772565+00	
00000000-0000-0000-0000-000000000000	5bc736e8-e307-4a08-bee0-97ae6ac05530	{"action":"user_signedup","actor_id":"33f581a6-b5de-49d8-acdd-1166f5a55844","actor_username":"burnbakar1538@gmail.com","actor_via_sso":false,"log_type":"team","traits":{"provider":"email"}}	2025-06-15 14:38:39.870747+00	
00000000-0000-0000-0000-000000000000	ea06c85c-0658-4241-8cc2-16b1cfab694b	{"action":"login","actor_id":"33f581a6-b5de-49d8-acdd-1166f5a55844","actor_username":"burnbakar1538@gmail.com","actor_via_sso":false,"log_type":"account","traits":{"provider":"email"}}	2025-06-15 14:38:39.872176+00	
00000000-0000-0000-0000-000000000000	28352b5e-b1bf-404c-830b-cbab4c24aa46	{"action":"user_signedup","actor_id":"a31bd0c1-174b-4922-a1b7-e60acc9b25b4","actor_username":"wl.young@davoslife.com","actor_via_sso":false,"log_type":"team","traits":{"provider":"email"}}	2025-06-15 14:38:39.966451+00	
00000000-0000-0000-0000-000000000000	0db5eb73-b200-48be-b0da-4ce93405b743	{"action":"login","actor_id":"a31bd0c1-174b-4922-a1b7-e60acc9b25b4","actor_username":"wl.young@davoslife.com","actor_via_sso":false,"log_type":"account","traits":{"provider":"email"}}	2025-06-15 14:38:39.967983+00	
00000000-0000-0000-0000-000000000000	6736bfb5-8602-470c-a731-46215e4f0b6d	{"action":"user_signedup","actor_id":"0492f0e6-5805-44af-aa74-4db0c77a4140","actor_username":"cbpb860009@gmail.com","actor_via_sso":false,"log_type":"team","traits":{"provider":"email"}}	2025-06-15 14:38:40.063206+00	
00000000-0000-0000-0000-000000000000	eec1a534-4f7a-48cd-8cc6-bcbf3da179ec	{"action":"login","actor_id":"0492f0e6-5805-44af-aa74-4db0c77a4140","actor_username":"cbpb860009@gmail.com","actor_via_sso":false,"log_type":"account","traits":{"provider":"email"}}	2025-06-15 14:38:40.064673+00	
00000000-0000-0000-0000-000000000000	2f651165-14c5-4459-a3c8-58457ab289f9	{"action":"user_signedup","actor_id":"6a07ae1f-58b7-49a3-b140-407f7039c517","actor_username":"mages@op.shh.my","actor_via_sso":false,"log_type":"team","traits":{"provider":"email"}}	2025-06-15 14:38:40.153464+00	
00000000-0000-0000-0000-000000000000	3d1dbaf3-3696-4c30-befb-91ac3ee0bfd0	{"action":"login","actor_id":"6a07ae1f-58b7-49a3-b140-407f7039c517","actor_username":"mages@op.shh.my","actor_via_sso":false,"log_type":"account","traits":{"provider":"email"}}	2025-06-15 14:38:40.154924+00	
00000000-0000-0000-0000-000000000000	b6b74e6f-c91a-4bc5-a046-73e06380cb42	{"action":"user_signedup","actor_id":"25c9e59a-dddc-4e8d-9b27-4033d9f1274a","actor_username":"elink.hidayat@gmail.com","actor_via_sso":false,"log_type":"team","traits":{"provider":"email"}}	2025-06-15 14:38:40.245841+00	
00000000-0000-0000-0000-000000000000	ef7db0dc-db19-47a5-9fae-d9348f20e1e7	{"action":"login","actor_id":"25c9e59a-dddc-4e8d-9b27-4033d9f1274a","actor_username":"elink.hidayat@gmail.com","actor_via_sso":false,"log_type":"account","traits":{"provider":"email"}}	2025-06-15 14:38:40.247331+00	
00000000-0000-0000-0000-000000000000	2cb84b00-f0b0-46f2-adaa-865bcdc91266	{"action":"user_signedup","actor_id":"4120635d-c542-437d-9cea-9319b2338db0","actor_username":"allariff@st.gov.my","actor_via_sso":false,"log_type":"team","traits":{"provider":"email"}}	2025-06-15 14:38:40.342715+00	
00000000-0000-0000-0000-000000000000	3279b6d1-d06d-40fd-9868-28e8aa61446e	{"action":"login","actor_id":"4120635d-c542-437d-9cea-9319b2338db0","actor_username":"allariff@st.gov.my","actor_via_sso":false,"log_type":"account","traits":{"provider":"email"}}	2025-06-15 14:38:40.344368+00	
00000000-0000-0000-0000-000000000000	c75b7d14-269c-4b03-bbc8-5add9a1d14be	{"action":"user_signedup","actor_id":"93a02249-5316-49a2-9ac7-12b4c8905133","actor_username":"zuki.ak@fgvholdings.com","actor_via_sso":false,"log_type":"team","traits":{"provider":"email"}}	2025-06-15 14:38:40.444216+00	
00000000-0000-0000-0000-000000000000	42a4cb18-13ef-4898-aab5-f25828c0d875	{"action":"login","actor_id":"93a02249-5316-49a2-9ac7-12b4c8905133","actor_username":"zuki.ak@fgvholdings.com","actor_via_sso":false,"log_type":"account","traits":{"provider":"email"}}	2025-06-15 14:38:40.445966+00	
00000000-0000-0000-0000-000000000000	3bc55d52-fb8f-42d3-94db-373714eec5e9	{"action":"user_signedup","actor_id":"fd863516-76ca-4417-8047-db3bdf0cb04e","actor_username":"alexius.n@fgvholding.socm","actor_via_sso":false,"log_type":"team","traits":{"provider":"email"}}	2025-06-15 14:38:40.537743+00	
00000000-0000-0000-0000-000000000000	68533c2c-9b9f-453a-8c43-644c8f2ebe53	{"action":"login","actor_id":"fd863516-76ca-4417-8047-db3bdf0cb04e","actor_username":"alexius.n@fgvholding.socm","actor_via_sso":false,"log_type":"account","traits":{"provider":"email"}}	2025-06-15 14:38:40.539414+00	
00000000-0000-0000-0000-000000000000	4a5bfa5f-b79e-4511-a862-59b37ed32dab	{"action":"user_signedup","actor_id":"e8eef5b6-23c8-43b6-b361-5407820aa1bd","actor_username":"andyjhall1979@gmail.com","actor_via_sso":false,"log_type":"team","traits":{"provider":"email"}}	2025-06-15 14:38:40.632989+00	
00000000-0000-0000-0000-000000000000	8de82c09-79c9-4de3-a63f-7ad4b2314477	{"action":"login","actor_id":"e8eef5b6-23c8-43b6-b361-5407820aa1bd","actor_username":"andyjhall1979@gmail.com","actor_via_sso":false,"log_type":"account","traits":{"provider":"email"}}	2025-06-15 14:38:40.634582+00	
00000000-0000-0000-0000-000000000000	85e3ee50-b77c-4dd7-8be1-888bd7b3350a	{"action":"user_signedup","actor_id":"0e4b6571-d7da-4d82-8035-b53821d50643","actor_username":"ladangdelima17@yahoo.com","actor_via_sso":false,"log_type":"team","traits":{"provider":"email"}}	2025-06-15 14:38:40.724113+00	
00000000-0000-0000-0000-000000000000	84df41dd-1635-42bb-baad-7a68db9b6fa0	{"action":"login","actor_id":"0e4b6571-d7da-4d82-8035-b53821d50643","actor_username":"ladangdelima17@yahoo.com","actor_via_sso":false,"log_type":"account","traits":{"provider":"email"}}	2025-06-15 14:38:40.72564+00	
00000000-0000-0000-0000-000000000000	5795df0b-81e5-46a2-9f24-66a3348f4034	{"action":"user_signedup","actor_id":"3daebba2-2008-456d-85ff-0f51d49e2068","actor_username":"khairulidzuan@fjgroup.com.my","actor_via_sso":false,"log_type":"team","traits":{"provider":"email"}}	2025-06-15 14:38:40.816431+00	
00000000-0000-0000-0000-000000000000	7f42acb8-abd5-4380-bad6-6f5ad25d1fad	{"action":"login","actor_id":"3daebba2-2008-456d-85ff-0f51d49e2068","actor_username":"khairulidzuan@fjgroup.com.my","actor_via_sso":false,"log_type":"account","traits":{"provider":"email"}}	2025-06-15 14:38:40.818059+00	
00000000-0000-0000-0000-000000000000	c56caa1c-3869-44db-a0cb-c9eac658916b	{"action":"user_signedup","actor_id":"79e11466-b344-4852-81cb-39ff9e45ebc0","actor_username":"mimisharida@gmail.com","actor_via_sso":false,"log_type":"team","traits":{"provider":"email"}}	2025-06-15 14:38:40.91807+00	
00000000-0000-0000-0000-000000000000	2d21429a-9876-40f4-a906-1452b52da0e2	{"action":"login","actor_id":"79e11466-b344-4852-81cb-39ff9e45ebc0","actor_username":"mimisharida@gmail.com","actor_via_sso":false,"log_type":"account","traits":{"provider":"email"}}	2025-06-15 14:38:40.919631+00	
00000000-0000-0000-0000-000000000000	2fb4b272-9500-49cd-8f60-bb3546782772	{"action":"user_signedup","actor_id":"4838f267-e471-42c2-960a-afb1bbe50dd5","actor_username":"ongtp@gtsr.com.my","actor_via_sso":false,"log_type":"team","traits":{"provider":"email"}}	2025-06-15 14:38:41.013187+00	
00000000-0000-0000-0000-000000000000	81b5688d-b2b3-4ec3-8954-4a323090416c	{"action":"login","actor_id":"4838f267-e471-42c2-960a-afb1bbe50dd5","actor_username":"ongtp@gtsr.com.my","actor_via_sso":false,"log_type":"account","traits":{"provider":"email"}}	2025-06-15 14:38:41.014642+00	
00000000-0000-0000-0000-000000000000	86fee003-d1cd-4487-b02c-9b15edd0bfb9	{"action":"user_signedup","actor_id":"4735ce34-ed6c-4b84-a258-c098689ca12f","actor_username":"wtkalpha@gmail.com","actor_via_sso":false,"log_type":"team","traits":{"provider":"email"}}	2025-06-15 14:38:41.109706+00	
00000000-0000-0000-0000-000000000000	281fc579-ce76-4336-b428-e3a02432468e	{"action":"login","actor_id":"4735ce34-ed6c-4b84-a258-c098689ca12f","actor_username":"wtkalpha@gmail.com","actor_via_sso":false,"log_type":"account","traits":{"provider":"email"}}	2025-06-15 14:38:41.111355+00	
00000000-0000-0000-0000-000000000000	c1894bd7-450f-489c-b0b0-1c7633e285b0	{"action":"user_signedup","actor_id":"0b500a7c-c000-4b0f-b19a-4cc42e3d380e","actor_username":"ruekeithjampong@gmail.com","actor_via_sso":false,"log_type":"team","traits":{"provider":"email"}}	2025-06-15 14:38:41.205026+00	
00000000-0000-0000-0000-000000000000	65f17c46-bd98-474e-a677-32dcf885dd2b	{"action":"login","actor_id":"0b500a7c-c000-4b0f-b19a-4cc42e3d380e","actor_username":"ruekeithjampong@gmail.com","actor_via_sso":false,"log_type":"account","traits":{"provider":"email"}}	2025-06-15 14:38:41.206502+00	
00000000-0000-0000-0000-000000000000	0dbe38e1-b78a-4412-99e0-6f1f8ab57202	{"action":"user_signedup","actor_id":"80c123de-90b0-4fd6-9424-1e93e57c96fb","actor_username":"bintang@bell.com.my","actor_via_sso":false,"log_type":"team","traits":{"provider":"email"}}	2025-06-15 14:38:41.299313+00	
00000000-0000-0000-0000-000000000000	ead65734-9f13-47de-9a41-f192c876edd9	{"action":"login","actor_id":"80c123de-90b0-4fd6-9424-1e93e57c96fb","actor_username":"bintang@bell.com.my","actor_via_sso":false,"log_type":"account","traits":{"provider":"email"}}	2025-06-15 14:38:41.300898+00	
00000000-0000-0000-0000-000000000000	fa9e8497-26e2-48cf-a822-e974e9c92d39	{"action":"user_signedup","actor_id":"bcc22448-661c-4e28-99a8-edb83a48195e","actor_username":"ainanajwa.sbh@gmail.com","actor_via_sso":false,"log_type":"team","traits":{"provider":"email"}}	2025-06-15 14:38:41.388925+00	
00000000-0000-0000-0000-000000000000	0fdfeda6-6250-4ec8-8224-6313f5523bee	{"action":"login","actor_id":"bcc22448-661c-4e28-99a8-edb83a48195e","actor_username":"ainanajwa.sbh@gmail.com","actor_via_sso":false,"log_type":"account","traits":{"provider":"email"}}	2025-06-15 14:38:41.390411+00	
00000000-0000-0000-0000-000000000000	30a7e156-d67e-495c-967a-13bf94711221	{"action":"user_signedup","actor_id":"77580fe9-7ac2-4fb0-9aa7-06995f768dea","actor_username":"rizal1976@gmail.com","actor_via_sso":false,"log_type":"team","traits":{"provider":"email"}}	2025-06-15 14:38:41.479607+00	
00000000-0000-0000-0000-000000000000	00600739-a351-49ac-a244-d23e7085f402	{"action":"login","actor_id":"77580fe9-7ac2-4fb0-9aa7-06995f768dea","actor_username":"rizal1976@gmail.com","actor_via_sso":false,"log_type":"account","traits":{"provider":"email"}}	2025-06-15 14:38:41.481065+00	
00000000-0000-0000-0000-000000000000	c8af0d47-3159-4022-b014-e7c54ec3aadb	{"action":"user_signedup","actor_id":"1d351dae-d3b7-476d-9c6a-c3851e6117f8","actor_username":"loureschristiansen@gmail.com","actor_via_sso":false,"log_type":"team","traits":{"provider":"email"}}	2025-06-15 14:38:41.578354+00	
00000000-0000-0000-0000-000000000000	4b2df543-78fe-44b7-84db-e96646232768	{"action":"login","actor_id":"1d351dae-d3b7-476d-9c6a-c3851e6117f8","actor_username":"loureschristiansen@gmail.com","actor_via_sso":false,"log_type":"account","traits":{"provider":"email"}}	2025-06-15 14:38:41.57996+00	
00000000-0000-0000-0000-000000000000	fd00d433-3ac2-4f6c-8117-b27ac2f5ef22	{"action":"user_signedup","actor_id":"b37636b3-8be1-4178-9cf2-8b57f5394441","actor_username":"vendettavendetta326@gmail.com","actor_via_sso":false,"log_type":"team","traits":{"provider":"email"}}	2025-06-15 14:38:41.669505+00	
00000000-0000-0000-0000-000000000000	28ade9df-0132-46a6-9c3c-46c2e5a9a503	{"action":"login","actor_id":"b37636b3-8be1-4178-9cf2-8b57f5394441","actor_username":"vendettavendetta326@gmail.com","actor_via_sso":false,"log_type":"account","traits":{"provider":"email"}}	2025-06-15 14:38:41.671043+00	
00000000-0000-0000-0000-000000000000	d9b753ec-c2f3-4a88-a45b-a7177eb38ead	{"action":"user_signedup","actor_id":"86c5fd15-a47d-44b9-94f9-864b787d7db8","actor_username":"foong9626@gmail.com","actor_via_sso":false,"log_type":"team","traits":{"provider":"email"}}	2025-06-15 14:38:41.767744+00	
00000000-0000-0000-0000-000000000000	5f68603e-cf82-4868-aca3-cdd00712e576	{"action":"login","actor_id":"86c5fd15-a47d-44b9-94f9-864b787d7db8","actor_username":"foong9626@gmail.com","actor_via_sso":false,"log_type":"account","traits":{"provider":"email"}}	2025-06-15 14:38:41.769323+00	
00000000-0000-0000-0000-000000000000	f28fc843-ec72-4609-9fd6-9034c520ca54	{"action":"user_signedup","actor_id":"26e06765-0726-4760-a956-cd6c133c8cf1","actor_username":"yakboy02@gmail.com","actor_via_sso":false,"log_type":"team","traits":{"provider":"email"}}	2025-06-15 14:38:41.868866+00	
00000000-0000-0000-0000-000000000000	f40045b2-cf94-42e8-a3c4-3555a6168f3c	{"action":"login","actor_id":"26e06765-0726-4760-a956-cd6c133c8cf1","actor_username":"yakboy02@gmail.com","actor_via_sso":false,"log_type":"account","traits":{"provider":"email"}}	2025-06-15 14:38:41.870538+00	
00000000-0000-0000-0000-000000000000	ce15d422-df4b-48cc-8c31-7eba7ccaa8e8	{"action":"user_signedup","actor_id":"9899069d-e0c6-4dec-b3cd-e4080a838f61","actor_username":"aireimail24@gmail.com","actor_via_sso":false,"log_type":"team","traits":{"provider":"email"}}	2025-06-15 14:38:41.964648+00	
00000000-0000-0000-0000-000000000000	eb61795f-a7ee-4a7a-ba74-d20da30cbc99	{"action":"login","actor_id":"9899069d-e0c6-4dec-b3cd-e4080a838f61","actor_username":"aireimail24@gmail.com","actor_via_sso":false,"log_type":"account","traits":{"provider":"email"}}	2025-06-15 14:38:41.966462+00	
00000000-0000-0000-0000-000000000000	fd4f9152-93c0-4761-b210-9df60f7b0341	{"action":"user_signedup","actor_id":"43e2d156-815e-45bc-a9c4-959ffc35a607","actor_username":"riswanrasid@gmail.com","actor_via_sso":false,"log_type":"team","traits":{"provider":"email"}}	2025-06-15 14:38:42.057819+00	
00000000-0000-0000-0000-000000000000	3b9cd45b-add0-4ecd-b422-488fc9a93e09	{"action":"login","actor_id":"43e2d156-815e-45bc-a9c4-959ffc35a607","actor_username":"riswanrasid@gmail.com","actor_via_sso":false,"log_type":"account","traits":{"provider":"email"}}	2025-06-15 14:38:42.059445+00	
00000000-0000-0000-0000-000000000000	35eac8b7-ec50-41b4-9904-49869790d6ec	{"action":"user_signedup","actor_id":"97f7ac1a-aaf7-4061-8dba-cef646b37a3b","actor_username":"mohamadmat921231@gmail.com","actor_via_sso":false,"log_type":"team","traits":{"provider":"email"}}	2025-06-15 14:38:42.154762+00	
00000000-0000-0000-0000-000000000000	c1196a51-336a-4214-90e2-544f353843ed	{"action":"login","actor_id":"97f7ac1a-aaf7-4061-8dba-cef646b37a3b","actor_username":"mohamadmat921231@gmail.com","actor_via_sso":false,"log_type":"account","traits":{"provider":"email"}}	2025-06-15 14:38:42.156316+00	
00000000-0000-0000-0000-000000000000	d430fbb3-a335-44fe-888a-90e5b8458819	{"action":"user_signedup","actor_id":"e24e82c5-482d-44c5-95e4-0dec79afeffc","actor_username":"spnrajendran@gmail.com","actor_via_sso":false,"log_type":"team","traits":{"provider":"email"}}	2025-06-15 14:38:42.24706+00	
00000000-0000-0000-0000-000000000000	1823b0bf-8eac-4452-9398-a59faca6c20a	{"action":"login","actor_id":"e24e82c5-482d-44c5-95e4-0dec79afeffc","actor_username":"spnrajendran@gmail.com","actor_via_sso":false,"log_type":"account","traits":{"provider":"email"}}	2025-06-15 14:38:42.248572+00	
00000000-0000-0000-0000-000000000000	687ed13d-26a3-4708-9076-c410cb3e1c05	{"action":"user_signedup","actor_id":"9bfb750a-2c2d-4bfc-9999-44fdabda74dd","actor_username":"kheongsc83@gmail.com","actor_via_sso":false,"log_type":"team","traits":{"provider":"email"}}	2025-06-15 14:38:42.350995+00	
00000000-0000-0000-0000-000000000000	6df7ffe8-c5c7-4e55-92ca-90f5bcc0d380	{"action":"login","actor_id":"9bfb750a-2c2d-4bfc-9999-44fdabda74dd","actor_username":"kheongsc83@gmail.com","actor_via_sso":false,"log_type":"account","traits":{"provider":"email"}}	2025-06-15 14:38:42.352585+00	
00000000-0000-0000-0000-000000000000	ff523bf2-36f3-43bd-8b8d-e21e2ddc3ff3	{"action":"user_signedup","actor_id":"fc2ca455-d9cb-44de-a313-e5f66f65a688","actor_username":"ussepudun2050@gmail.com","actor_via_sso":false,"log_type":"team","traits":{"provider":"email"}}	2025-06-15 14:38:42.446735+00	
00000000-0000-0000-0000-000000000000	7f098bc4-fcdf-41ab-be88-91fd618d0db5	{"action":"login","actor_id":"fc2ca455-d9cb-44de-a313-e5f66f65a688","actor_username":"ussepudun2050@gmail.com","actor_via_sso":false,"log_type":"account","traits":{"provider":"email"}}	2025-06-15 14:38:42.448424+00	
00000000-0000-0000-0000-000000000000	996cf3de-af98-41b9-aabb-14d1bc47c52f	{"action":"user_signedup","actor_id":"ad892dc0-1949-48b7-be5e-d63c7290e512","actor_username":"hasbollah@mspo.org.my","actor_via_sso":false,"log_type":"team","traits":{"provider":"email"}}	2025-06-15 14:38:42.542367+00	
00000000-0000-0000-0000-000000000000	2e657f3d-43d2-4b1b-a8b5-498cfcbc49ec	{"action":"login","actor_id":"ad892dc0-1949-48b7-be5e-d63c7290e512","actor_username":"hasbollah@mspo.org.my","actor_via_sso":false,"log_type":"account","traits":{"provider":"email"}}	2025-06-15 14:38:42.54379+00	
00000000-0000-0000-0000-000000000000	62ca5b43-7530-4e5f-b845-836f816d3680	{"action":"login","actor_id":"ad892dc0-1949-48b7-be5e-d63c7290e512","actor_username":"hasbollah@mspo.org.my","actor_via_sso":false,"log_type":"account","traits":{"provider":"email"}}	2025-06-15 14:41:55.690506+00	
00000000-0000-0000-0000-000000000000	aee2b356-694a-48e6-8a17-325113555f47	{"action":"logout","actor_id":"ad892dc0-1949-48b7-be5e-d63c7290e512","actor_username":"hasbollah@mspo.org.my","actor_via_sso":false,"log_type":"account"}	2025-06-15 15:01:57.841371+00	
00000000-0000-0000-0000-000000000000	2a486783-bf03-43e2-a491-26d2de6c333c	{"action":"login","actor_id":"ad892dc0-1949-48b7-be5e-d63c7290e512","actor_username":"hasbollah@mspo.org.my","actor_via_sso":false,"log_type":"account","traits":{"provider":"email"}}	2025-06-15 15:02:07.08191+00	
00000000-0000-0000-0000-000000000000	efb504f6-3e95-4ca4-8f28-a9733a6b5d44	{"action":"logout","actor_id":"ad892dc0-1949-48b7-be5e-d63c7290e512","actor_username":"hasbollah@mspo.org.my","actor_via_sso":false,"log_type":"account"}	2025-06-15 15:02:19.275173+00	
00000000-0000-0000-0000-000000000000	cd40a25a-ab79-4b41-98c3-7308492af146	{"action":"login","actor_id":"0955eea6-fdc3-48b6-beca-f30e05cfe912","actor_username":"hazwan@mspo.org.my","actor_via_sso":false,"log_type":"account","traits":{"provider":"email"}}	2025-06-15 15:02:25.456764+00	
00000000-0000-0000-0000-000000000000	a5c2ac8f-111c-4dc0-9f72-fdf1a783df2e	{"action":"logout","actor_id":"0955eea6-fdc3-48b6-beca-f30e05cfe912","actor_username":"hazwan@mspo.org.my","actor_via_sso":false,"log_type":"account"}	2025-06-15 15:02:27.93419+00	
00000000-0000-0000-0000-000000000000	c075a0e1-3a97-4512-91a4-f7b3878f91e0	{"action":"login","actor_id":"4e33cfac-f5fe-4c35-9861-84d7917606ae","actor_username":"rveerasa@hotmail.com","actor_via_sso":false,"log_type":"account","traits":{"provider":"email"}}	2025-06-15 15:06:47.149139+00	
00000000-0000-0000-0000-000000000000	44076ff9-8dcc-4301-ad32-9a6d404307d5	{"action":"logout","actor_id":"4e33cfac-f5fe-4c35-9861-84d7917606ae","actor_username":"rveerasa@hotmail.com","actor_via_sso":false,"log_type":"account"}	2025-06-15 15:23:12.071837+00	
00000000-0000-0000-0000-000000000000	9e99b2b7-b5c8-4611-abad-18491a3acabe	{"action":"login","actor_id":"ad892dc0-1949-48b7-be5e-d63c7290e512","actor_username":"hasbollah@mspo.org.my","actor_via_sso":false,"log_type":"account","traits":{"provider":"email"}}	2025-06-15 15:23:20.135769+00	
00000000-0000-0000-0000-000000000000	89f955dc-8b55-46a2-be31-0dc946319b81	{"action":"logout","actor_id":"ad892dc0-1949-48b7-be5e-d63c7290e512","actor_username":"hasbollah@mspo.org.my","actor_via_sso":false,"log_type":"account"}	2025-06-15 15:25:06.367066+00	
00000000-0000-0000-0000-000000000000	ebe761fc-69d4-4214-a6eb-d8336b38dbe3	{"action":"login","actor_id":"0955eea6-fdc3-48b6-beca-f30e05cfe912","actor_username":"hazwan@mspo.org.my","actor_via_sso":false,"log_type":"account","traits":{"provider":"email"}}	2025-06-15 15:25:11.641356+00	
00000000-0000-0000-0000-000000000000	36f14e59-82d2-4b32-a9ec-c9a3605956ae	{"action":"logout","actor_id":"0955eea6-fdc3-48b6-beca-f30e05cfe912","actor_username":"hazwan@mspo.org.my","actor_via_sso":false,"log_type":"account"}	2025-06-15 15:27:16.376356+00	
00000000-0000-0000-0000-000000000000	c9ed9c29-67a8-4d33-a9bd-e3cdf7e16657	{"action":"login","actor_id":"ad892dc0-1949-48b7-be5e-d63c7290e512","actor_username":"hasbollah@mspo.org.my","actor_via_sso":false,"log_type":"account","traits":{"provider":"email"}}	2025-06-15 15:27:22.195442+00	
00000000-0000-0000-0000-000000000000	8be9e306-b773-4bf6-a2a7-c8932a42aa05	{"action":"token_refreshed","actor_id":"ad892dc0-1949-48b7-be5e-d63c7290e512","actor_username":"hasbollah@mspo.org.my","actor_via_sso":false,"log_type":"token"}	2025-06-16 00:43:14.149119+00	
00000000-0000-0000-0000-000000000000	82a6c11e-a674-47b4-aa81-ef7f7eb9df76	{"action":"token_revoked","actor_id":"ad892dc0-1949-48b7-be5e-d63c7290e512","actor_username":"hasbollah@mspo.org.my","actor_via_sso":false,"log_type":"token"}	2025-06-16 00:43:14.149541+00	
00000000-0000-0000-0000-000000000000	d36060ea-1e99-4acc-85e7-71f2161977e7	{"action":"token_refreshed","actor_id":"ad892dc0-1949-48b7-be5e-d63c7290e512","actor_username":"hasbollah@mspo.org.my","actor_via_sso":false,"log_type":"token"}	2025-06-16 03:10:02.296047+00	
00000000-0000-0000-0000-000000000000	527b509c-3720-46da-bf9f-56d4ceccc845	{"action":"token_revoked","actor_id":"ad892dc0-1949-48b7-be5e-d63c7290e512","actor_username":"hasbollah@mspo.org.my","actor_via_sso":false,"log_type":"token"}	2025-06-16 03:10:02.296555+00	
00000000-0000-0000-0000-000000000000	5c2ff8d9-6b5b-48b8-afb4-8f8c853b0f72	{"action":"login","actor_id":"0955eea6-fdc3-48b6-beca-f30e05cfe912","actor_username":"hazwan@mspo.org.my","actor_via_sso":false,"log_type":"account","traits":{"provider":"email"}}	2025-06-16 03:12:36.857895+00	
00000000-0000-0000-0000-000000000000	5e4c0324-f2c1-43e6-a0b9-9d9023f06b18	{"action":"token_refreshed","actor_id":"0955eea6-fdc3-48b6-beca-f30e05cfe912","actor_username":"hazwan@mspo.org.my","actor_via_sso":false,"log_type":"token"}	2025-06-16 05:57:40.607635+00	
00000000-0000-0000-0000-000000000000	e594eda8-b435-4d82-946c-53cb98bee974	{"action":"token_revoked","actor_id":"0955eea6-fdc3-48b6-beca-f30e05cfe912","actor_username":"hazwan@mspo.org.my","actor_via_sso":false,"log_type":"token"}	2025-06-16 05:57:40.608017+00	
00000000-0000-0000-0000-000000000000	198adc23-6a91-4d9d-9bcd-9a62714fdbf8	{"action":"token_refreshed","actor_id":"0955eea6-fdc3-48b6-beca-f30e05cfe912","actor_username":"hazwan@mspo.org.my","actor_via_sso":false,"log_type":"token"}	2025-06-16 07:08:45.035427+00	
00000000-0000-0000-0000-000000000000	cca45eae-933f-444e-84df-951d8d144f47	{"action":"token_revoked","actor_id":"0955eea6-fdc3-48b6-beca-f30e05cfe912","actor_username":"hazwan@mspo.org.my","actor_via_sso":false,"log_type":"token"}	2025-06-16 07:08:45.035852+00	
00000000-0000-0000-0000-000000000000	6419c0b0-c688-4f9c-94aa-3dffc6ff7161	{"action":"token_refreshed","actor_id":"0955eea6-fdc3-48b6-beca-f30e05cfe912","actor_username":"hazwan@mspo.org.my","actor_via_sso":false,"log_type":"token"}	2025-06-16 08:35:29.498357+00	
00000000-0000-0000-0000-000000000000	db776144-720f-4a5d-bad1-59925efce136	{"action":"token_revoked","actor_id":"0955eea6-fdc3-48b6-beca-f30e05cfe912","actor_username":"hazwan@mspo.org.my","actor_via_sso":false,"log_type":"token"}	2025-06-16 08:35:29.49876+00	
00000000-0000-0000-0000-000000000000	1c62b833-8ead-4659-a938-57559d5e2681	{"action":"token_refreshed","actor_id":"0955eea6-fdc3-48b6-beca-f30e05cfe912","actor_username":"hazwan@mspo.org.my","actor_via_sso":false,"log_type":"token"}	2025-06-16 08:35:29.552908+00	
00000000-0000-0000-0000-000000000000	32e17106-342e-464b-8937-a257a06b3d0f	{"action":"token_refreshed","actor_id":"0955eea6-fdc3-48b6-beca-f30e05cfe912","actor_username":"hazwan@mspo.org.my","actor_via_sso":false,"log_type":"token"}	2025-06-17 01:41:50.028215+00	
00000000-0000-0000-0000-000000000000	c71964b4-ea6d-4e40-a3d0-33e0f1c7fcca	{"action":"token_revoked","actor_id":"0955eea6-fdc3-48b6-beca-f30e05cfe912","actor_username":"hazwan@mspo.org.my","actor_via_sso":false,"log_type":"token"}	2025-06-17 01:41:50.061269+00	
00000000-0000-0000-0000-000000000000	13d83d66-d364-47c6-be52-de473b89a251	{"action":"login","actor_id":"0955eea6-fdc3-48b6-beca-f30e05cfe912","actor_username":"hazwan@mspo.org.my","actor_via_sso":false,"log_type":"account","traits":{"provider":"email"}}	2025-06-17 02:15:45.233533+00	
00000000-0000-0000-0000-000000000000	44bdae6e-fb0c-4f6d-9895-91177c6e514b	{"action":"token_refreshed","actor_id":"0955eea6-fdc3-48b6-beca-f30e05cfe912","actor_username":"hazwan@mspo.org.my","actor_via_sso":false,"log_type":"token"}	2025-06-17 03:14:19.624925+00	
00000000-0000-0000-0000-000000000000	4f5f51d6-ba48-4537-b969-06916f4bab04	{"action":"token_revoked","actor_id":"0955eea6-fdc3-48b6-beca-f30e05cfe912","actor_username":"hazwan@mspo.org.my","actor_via_sso":false,"log_type":"token"}	2025-06-17 03:14:19.625387+00	
00000000-0000-0000-0000-000000000000	34576055-6e7f-46b1-b245-5da48f50e178	{"action":"token_refreshed","actor_id":"0955eea6-fdc3-48b6-beca-f30e05cfe912","actor_username":"hazwan@mspo.org.my","actor_via_sso":false,"log_type":"token"}	2025-06-17 07:11:05.351737+00	
00000000-0000-0000-0000-000000000000	c4bf380a-7700-4ebe-8553-d3232bdce984	{"action":"token_revoked","actor_id":"0955eea6-fdc3-48b6-beca-f30e05cfe912","actor_username":"hazwan@mspo.org.my","actor_via_sso":false,"log_type":"token"}	2025-06-17 07:11:05.352249+00	
00000000-0000-0000-0000-000000000000	15923802-a7bb-48ce-81e5-f30c5a68fa54	{"action":"token_refreshed","actor_id":"0955eea6-fdc3-48b6-beca-f30e05cfe912","actor_username":"hazwan@mspo.org.my","actor_via_sso":false,"log_type":"token"}	2025-06-17 07:11:08.328436+00	
00000000-0000-0000-0000-000000000000	c2638c8d-c24b-418e-9bb8-774e450fc41f	{"action":"token_revoked","actor_id":"0955eea6-fdc3-48b6-beca-f30e05cfe912","actor_username":"hazwan@mspo.org.my","actor_via_sso":false,"log_type":"token"}	2025-06-17 07:11:08.328865+00	
00000000-0000-0000-0000-000000000000	32a528dd-45e2-4766-831b-f5aadd9e1918	{"action":"token_refreshed","actor_id":"0955eea6-fdc3-48b6-beca-f30e05cfe912","actor_username":"hazwan@mspo.org.my","actor_via_sso":false,"log_type":"token"}	2025-06-17 12:44:09.665005+00	
00000000-0000-0000-0000-000000000000	6cf1546f-04e7-4be8-b983-afd295f0d74a	{"action":"token_revoked","actor_id":"0955eea6-fdc3-48b6-beca-f30e05cfe912","actor_username":"hazwan@mspo.org.my","actor_via_sso":false,"log_type":"token"}	2025-06-17 12:44:09.665424+00	
00000000-0000-0000-0000-000000000000	3e032535-177e-46d5-bbc0-b2ed8f338b45	{"action":"token_refreshed","actor_id":"0955eea6-fdc3-48b6-beca-f30e05cfe912","actor_username":"hazwan@mspo.org.my","actor_via_sso":false,"log_type":"token"}	2025-06-18 01:27:34.170247+00	
00000000-0000-0000-0000-000000000000	20820363-a025-4540-bac8-8d66dcf7544b	{"action":"token_revoked","actor_id":"0955eea6-fdc3-48b6-beca-f30e05cfe912","actor_username":"hazwan@mspo.org.my","actor_via_sso":false,"log_type":"token"}	2025-06-18 01:27:34.170724+00	
00000000-0000-0000-0000-000000000000	5bdd3baa-2558-448f-9ec7-749f1524d179	{"action":"user_signedup","actor_id":"bb194837-db77-40d9-a6fd-5e9737c5724e","actor_username":"pom_logo@yopmail.com","actor_via_sso":false,"log_type":"team","traits":{"provider":"email"}}	2025-06-18 02:09:49.671219+00	
00000000-0000-0000-0000-000000000000	d3e7620c-95d6-4589-bf5f-a5c650d5053a	{"action":"login","actor_id":"bb194837-db77-40d9-a6fd-5e9737c5724e","actor_username":"pom_logo@yopmail.com","actor_via_sso":false,"log_type":"account","traits":{"provider":"email"}}	2025-06-18 02:09:49.681931+00	
00000000-0000-0000-0000-000000000000	2dec98bd-72d3-431e-917c-9de1307be8c1	{"action":"login","actor_id":"bb194837-db77-40d9-a6fd-5e9737c5724e","actor_username":"pom_logo@yopmail.com","actor_via_sso":false,"log_type":"account","traits":{"provider":"email"}}	2025-06-18 02:12:53.843414+00	
00000000-0000-0000-0000-000000000000	a072da96-c9c4-470b-bae2-fbbf9a5c1a4a	{"action":"token_refreshed","actor_id":"bb194837-db77-40d9-a6fd-5e9737c5724e","actor_username":"pom_logo@yopmail.com","actor_via_sso":false,"log_type":"token"}	2025-06-18 03:08:09.474425+00	
00000000-0000-0000-0000-000000000000	2a59eaca-05e9-47dc-802e-fba6926f0869	{"action":"token_revoked","actor_id":"bb194837-db77-40d9-a6fd-5e9737c5724e","actor_username":"pom_logo@yopmail.com","actor_via_sso":false,"log_type":"token"}	2025-06-18 03:08:09.475036+00	
00000000-0000-0000-0000-000000000000	9f7f1751-3ff4-4a3a-b142-e98f9d9518e9	{"action":"token_refreshed","actor_id":"bb194837-db77-40d9-a6fd-5e9737c5724e","actor_username":"pom_logo@yopmail.com","actor_via_sso":false,"log_type":"token"}	2025-06-18 04:06:09.955605+00	
00000000-0000-0000-0000-000000000000	2b9e7130-4acc-4fd9-a594-2ff2d3cd6bc8	{"action":"token_revoked","actor_id":"bb194837-db77-40d9-a6fd-5e9737c5724e","actor_username":"pom_logo@yopmail.com","actor_via_sso":false,"log_type":"token"}	2025-06-18 04:06:09.95602+00	
00000000-0000-0000-0000-000000000000	a3004cf0-c34c-4fd4-b799-ce77c5554060	{"action":"token_refreshed","actor_id":"bb194837-db77-40d9-a6fd-5e9737c5724e","actor_username":"pom_logo@yopmail.com","actor_via_sso":false,"log_type":"token"}	2025-06-18 05:04:12.999442+00	
00000000-0000-0000-0000-000000000000	751ac80e-eb63-4398-bc6e-4ffea607b3b0	{"action":"token_revoked","actor_id":"bb194837-db77-40d9-a6fd-5e9737c5724e","actor_username":"pom_logo@yopmail.com","actor_via_sso":false,"log_type":"token"}	2025-06-18 05:04:12.99993+00	
00000000-0000-0000-0000-000000000000	4705bf44-a6ae-492e-a30d-028fdcb8feb7	{"action":"token_refreshed","actor_id":"bb194837-db77-40d9-a6fd-5e9737c5724e","actor_username":"pom_logo@yopmail.com","actor_via_sso":false,"log_type":"token"}	2025-06-18 06:02:15.042139+00	
00000000-0000-0000-0000-000000000000	c46b90b6-4bb6-40fd-8777-77e4905e4c09	{"action":"token_revoked","actor_id":"bb194837-db77-40d9-a6fd-5e9737c5724e","actor_username":"pom_logo@yopmail.com","actor_via_sso":false,"log_type":"token"}	2025-06-18 06:02:15.042524+00	
00000000-0000-0000-0000-000000000000	3f1b7fc5-fdd0-455d-bd4c-394d9eebfe4b	{"action":"user_modified","actor_id":"00000000-0000-0000-0000-000000000000","actor_username":"service_role","actor_via_sso":false,"log_type":"user","traits":{"user_email":"hazwan@mspo.org.my","user_id":"0955eea6-fdc3-48b6-beca-f30e05cfe912","user_phone":""}}	2025-06-18 06:25:22.068403+00	
00000000-0000-0000-0000-000000000000	5f821ce8-4435-4f22-9d33-aaa01f17cf7b	{"action":"login","actor_id":"0955eea6-fdc3-48b6-beca-f30e05cfe912","actor_username":"hazwan@mspo.org.my","actor_via_sso":false,"log_type":"account","traits":{"provider":"email"}}	2025-06-18 06:41:21.352556+00	
00000000-0000-0000-0000-000000000000	1ac63f5c-9529-4332-84c2-4460cf58f3b2	{"action":"logout","actor_id":"0955eea6-fdc3-48b6-beca-f30e05cfe912","actor_username":"hazwan@mspo.org.my","actor_via_sso":false,"log_type":"account"}	2025-06-18 06:43:49.722664+00	
00000000-0000-0000-0000-000000000000	5a8f7a35-602a-4fa4-8c99-2d11d88f9b28	{"action":"login","actor_id":"0955eea6-fdc3-48b6-beca-f30e05cfe912","actor_username":"hazwan@mspo.org.my","actor_via_sso":false,"log_type":"account","traits":{"provider":"email"}}	2025-06-18 06:45:56.999805+00	
00000000-0000-0000-0000-000000000000	a35903b2-3091-41d8-b5d2-9302e07e783e	{"action":"token_refreshed","actor_id":"bb194837-db77-40d9-a6fd-5e9737c5724e","actor_username":"pom_logo@yopmail.com","actor_via_sso":false,"log_type":"token"}	2025-06-18 07:00:15.794918+00	
00000000-0000-0000-0000-000000000000	4252e784-65a3-4460-940d-e866f02e45f9	{"action":"token_revoked","actor_id":"bb194837-db77-40d9-a6fd-5e9737c5724e","actor_username":"pom_logo@yopmail.com","actor_via_sso":false,"log_type":"token"}	2025-06-18 07:00:15.795327+00	
00000000-0000-0000-0000-000000000000	e4a00310-3b26-4c88-9f05-6ea811343356	{"action":"logout","actor_id":"0955eea6-fdc3-48b6-beca-f30e05cfe912","actor_username":"hazwan@mspo.org.my","actor_via_sso":false,"log_type":"account"}	2025-06-18 07:07:50.301785+00	
00000000-0000-0000-0000-000000000000	0d216863-7861-4d83-ba23-a529c890efcb	{"action":"login","actor_id":"0955eea6-fdc3-48b6-beca-f30e05cfe912","actor_username":"hazwan@mspo.org.my","actor_via_sso":false,"log_type":"account","traits":{"provider":"email"}}	2025-06-18 07:09:37.25238+00	
00000000-0000-0000-0000-000000000000	7ad43e41-af09-47f2-aaad-2806aa10933a	{"action":"login","actor_id":"0955eea6-fdc3-48b6-beca-f30e05cfe912","actor_username":"hazwan@mspo.org.my","actor_via_sso":false,"log_type":"account","traits":{"provider":"email"}}	2025-06-18 07:26:15.549342+00	
00000000-0000-0000-0000-000000000000	89b09d39-d290-498a-acd7-0a3442aa7952	{"action":"login","actor_id":"0955eea6-fdc3-48b6-beca-f30e05cfe912","actor_username":"hazwan@mspo.org.my","actor_via_sso":false,"log_type":"account","traits":{"provider":"email"}}	2025-06-18 07:26:31.934816+00	
00000000-0000-0000-0000-000000000000	7a022913-e646-4ca0-b808-73224ece2bb8	{"action":"login","actor_id":"0955eea6-fdc3-48b6-beca-f30e05cfe912","actor_username":"hazwan@mspo.org.my","actor_via_sso":false,"log_type":"account","traits":{"provider":"email"}}	2025-06-18 07:30:28.801053+00	
00000000-0000-0000-0000-000000000000	4450cd65-618e-4afc-a22a-b47b1115e440	{"action":"login","actor_id":"0955eea6-fdc3-48b6-beca-f30e05cfe912","actor_username":"hazwan@mspo.org.my","actor_via_sso":false,"log_type":"account","traits":{"provider":"email"}}	2025-06-18 07:30:37.372378+00	
00000000-0000-0000-0000-000000000000	10db9203-212f-48a8-a8af-3d4be1716349	{"action":"login","actor_id":"0955eea6-fdc3-48b6-beca-f30e05cfe912","actor_username":"hazwan@mspo.org.my","actor_via_sso":false,"log_type":"account","traits":{"provider":"email"}}	2025-06-18 07:30:43.51693+00	
00000000-0000-0000-0000-000000000000	56f1356f-8234-4536-bf64-b4f2f9a12d14	{"action":"user_updated_password","actor_id":"0955eea6-fdc3-48b6-beca-f30e05cfe912","actor_username":"hazwan@mspo.org.my","actor_via_sso":false,"log_type":"user"}	2025-06-18 07:30:43.696796+00	
00000000-0000-0000-0000-000000000000	da1b5a41-d6c8-4874-877b-3547c792ff8e	{"action":"user_modified","actor_id":"0955eea6-fdc3-48b6-beca-f30e05cfe912","actor_username":"hazwan@mspo.org.my","actor_via_sso":false,"log_type":"user"}	2025-06-18 07:30:43.697159+00	
00000000-0000-0000-0000-000000000000	76e79f5b-1698-4857-b399-18605f107e4a	{"action":"login","actor_id":"0955eea6-fdc3-48b6-beca-f30e05cfe912","actor_username":"hazwan@mspo.org.my","actor_via_sso":false,"log_type":"account","traits":{"provider":"email"}}	2025-06-19 07:47:09.069849+00	
00000000-0000-0000-0000-000000000000	7badb582-f368-40a9-b401-6340d3548ca7	{"action":"token_refreshed","actor_id":"0955eea6-fdc3-48b6-beca-f30e05cfe912","actor_username":"hazwan@mspo.org.my","actor_via_sso":false,"log_type":"token"}	2025-06-19 11:52:45.860499+00	
00000000-0000-0000-0000-000000000000	c919fe86-4f2f-4f02-bd12-10c262855572	{"action":"token_revoked","actor_id":"0955eea6-fdc3-48b6-beca-f30e05cfe912","actor_username":"hazwan@mspo.org.my","actor_via_sso":false,"log_type":"token"}	2025-06-19 11:52:45.861024+00	
00000000-0000-0000-0000-000000000000	127146d0-f770-4817-9bbd-fa0ba7fe7c02	{"action":"login","actor_id":"a007885a-80b3-4486-b31c-6652abca3e12","actor_username":"firdaus@mspo.org.my","actor_via_sso":false,"log_type":"account","traits":{"provider":"email"}}	2025-06-20 03:04:48.390075+00	
00000000-0000-0000-0000-000000000000	586c0bb7-6979-4569-8f73-3631cecd6b8d	{"action":"logout","actor_id":"a007885a-80b3-4486-b31c-6652abca3e12","actor_username":"firdaus@mspo.org.my","actor_via_sso":false,"log_type":"account"}	2025-06-20 03:11:35.1329+00	
00000000-0000-0000-0000-000000000000	e58cccdd-8594-4db0-a197-de369de01cec	{"action":"login","actor_id":"a007885a-80b3-4486-b31c-6652abca3e12","actor_username":"firdaus@mspo.org.my","actor_via_sso":false,"log_type":"account","traits":{"provider":"email"}}	2025-06-20 03:11:54.8834+00	
00000000-0000-0000-0000-000000000000	640cab63-34c3-4b29-bffd-6fac8bb07014	{"action":"token_refreshed","actor_id":"a007885a-80b3-4486-b31c-6652abca3e12","actor_username":"firdaus@mspo.org.my","actor_via_sso":false,"log_type":"token"}	2025-06-20 06:53:43.720716+00	
00000000-0000-0000-0000-000000000000	5189231d-bf57-4244-b425-a6e6f161d89c	{"action":"token_revoked","actor_id":"a007885a-80b3-4486-b31c-6652abca3e12","actor_username":"firdaus@mspo.org.my","actor_via_sso":false,"log_type":"token"}	2025-06-20 06:53:43.721142+00	
00000000-0000-0000-0000-000000000000	82338dd5-1cfe-4807-9a51-04e9e3dfa830	{"action":"token_refreshed","actor_id":"a007885a-80b3-4486-b31c-6652abca3e12","actor_username":"firdaus@mspo.org.my","actor_via_sso":false,"log_type":"token"}	2025-06-20 08:17:42.15286+00	
00000000-0000-0000-0000-000000000000	c0275e20-3bb1-4b04-b5e6-45ea8bd8be69	{"action":"token_revoked","actor_id":"a007885a-80b3-4486-b31c-6652abca3e12","actor_username":"firdaus@mspo.org.my","actor_via_sso":false,"log_type":"token"}	2025-06-20 08:17:42.15325+00	
00000000-0000-0000-0000-000000000000	9aba5194-6a54-4337-a435-21a41c8e82dd	{"action":"logout","actor_id":"a007885a-80b3-4486-b31c-6652abca3e12","actor_username":"firdaus@mspo.org.my","actor_via_sso":false,"log_type":"account"}	2025-06-20 08:20:27.184355+00	
00000000-0000-0000-0000-000000000000	2c514382-3d2e-490c-9f2c-40dd48751b78	{"action":"token_refreshed","actor_id":"0955eea6-fdc3-48b6-beca-f30e05cfe912","actor_username":"hazwan@mspo.org.my","actor_via_sso":false,"log_type":"token"}	2025-06-20 13:29:31.621166+00	
00000000-0000-0000-0000-000000000000	b6bce94f-526b-4dd3-8f3f-8dca2b5432f6	{"action":"token_revoked","actor_id":"0955eea6-fdc3-48b6-beca-f30e05cfe912","actor_username":"hazwan@mspo.org.my","actor_via_sso":false,"log_type":"token"}	2025-06-20 13:29:31.621569+00	
00000000-0000-0000-0000-000000000000	56befca0-a328-4f76-9b0d-4864e5fc26f0	{"action":"token_refreshed","actor_id":"0955eea6-fdc3-48b6-beca-f30e05cfe912","actor_username":"hazwan@mspo.org.my","actor_via_sso":false,"log_type":"token"}	2025-06-22 12:13:37.280654+00	
00000000-0000-0000-0000-000000000000	054db0c6-0461-47f5-ab13-35a0813694f4	{"action":"token_revoked","actor_id":"0955eea6-fdc3-48b6-beca-f30e05cfe912","actor_username":"hazwan@mspo.org.my","actor_via_sso":false,"log_type":"token"}	2025-06-22 12:13:37.281114+00	
00000000-0000-0000-0000-000000000000	b9de1687-9fd2-45d9-ac4c-e1d67e5c4cec	{"action":"login","actor_id":"0955eea6-fdc3-48b6-beca-f30e05cfe912","actor_username":"hazwan@mspo.org.my","actor_via_sso":false,"log_type":"account","traits":{"provider":"email"}}	2025-06-22 14:06:14.506443+00	
00000000-0000-0000-0000-000000000000	fffe44a5-65f4-48a5-a856-c8367f1f5328	{"action":"token_refreshed","actor_id":"0955eea6-fdc3-48b6-beca-f30e05cfe912","actor_username":"hazwan@mspo.org.my","actor_via_sso":false,"log_type":"token"}	2025-06-22 14:32:26.231291+00	
00000000-0000-0000-0000-000000000000	2da88c91-9f4e-4fad-8b71-e81e1bfb1100	{"action":"token_revoked","actor_id":"0955eea6-fdc3-48b6-beca-f30e05cfe912","actor_username":"hazwan@mspo.org.my","actor_via_sso":false,"log_type":"token"}	2025-06-22 14:32:26.231707+00	
00000000-0000-0000-0000-000000000000	0b4bc599-8679-4c1a-b552-29686adf5ff7	{"action":"logout","actor_id":"0955eea6-fdc3-48b6-beca-f30e05cfe912","actor_username":"hazwan@mspo.org.my","actor_via_sso":false,"log_type":"account"}	2025-06-22 14:32:31.428659+00	
00000000-0000-0000-0000-000000000000	7b1f1b8c-0b10-425f-ad92-86e80e617db7	{"action":"login","actor_id":"a007885a-80b3-4486-b31c-6652abca3e12","actor_username":"firdaus@mspo.org.my","actor_via_sso":false,"log_type":"account","traits":{"provider":"email"}}	2025-06-23 02:59:31.403524+00	
00000000-0000-0000-0000-000000000000	277f30c8-28ce-4797-b78a-2150058809e2	{"action":"logout","actor_id":"a007885a-80b3-4486-b31c-6652abca3e12","actor_username":"firdaus@mspo.org.my","actor_via_sso":false,"log_type":"account"}	2025-06-23 03:01:06.865393+00	
00000000-0000-0000-0000-000000000000	19a23b37-9b32-433f-90f1-c9f5a056c79a	{"action":"login","actor_id":"a007885a-80b3-4486-b31c-6652abca3e12","actor_username":"firdaus@mspo.org.my","actor_via_sso":false,"log_type":"account","traits":{"provider":"email"}}	2025-06-23 03:03:11.48986+00	
00000000-0000-0000-0000-000000000000	dc093015-8a82-4f5a-907d-56a0f91de0c9	{"action":"logout","actor_id":"a007885a-80b3-4486-b31c-6652abca3e12","actor_username":"firdaus@mspo.org.my","actor_via_sso":false,"log_type":"account"}	2025-06-23 03:04:15.580093+00	
00000000-0000-0000-0000-000000000000	31744db5-357e-4954-b995-57ce90e1b1c8	{"action":"login","actor_id":"a007885a-80b3-4486-b31c-6652abca3e12","actor_username":"firdaus@mspo.org.my","actor_via_sso":false,"log_type":"account","traits":{"provider":"email"}}	2025-06-23 03:04:37.131069+00	
00000000-0000-0000-0000-000000000000	b05bb21f-57b9-479b-a627-b1d5380d16a8	{"action":"logout","actor_id":"a007885a-80b3-4486-b31c-6652abca3e12","actor_username":"firdaus@mspo.org.my","actor_via_sso":false,"log_type":"account"}	2025-06-23 03:26:25.934357+00	
00000000-0000-0000-0000-000000000000	adba20f2-8231-4d2f-9f34-34657e04f3f0	{"action":"login","actor_id":"a007885a-80b3-4486-b31c-6652abca3e12","actor_username":"firdaus@mspo.org.my","actor_via_sso":false,"log_type":"account","traits":{"provider":"email"}}	2025-06-23 03:30:20.271305+00	
00000000-0000-0000-0000-000000000000	f736478d-2788-4a69-9801-8bdaf0d23444	{"action":"token_refreshed","actor_id":"a007885a-80b3-4486-b31c-6652abca3e12","actor_username":"firdaus@mspo.org.my","actor_via_sso":false,"log_type":"token"}	2025-06-23 05:43:29.984417+00	
00000000-0000-0000-0000-000000000000	37275c40-3374-49fd-baa3-a22deeebf388	{"action":"token_revoked","actor_id":"a007885a-80b3-4486-b31c-6652abca3e12","actor_username":"firdaus@mspo.org.my","actor_via_sso":false,"log_type":"token"}	2025-06-23 05:43:29.984844+00	
00000000-0000-0000-0000-000000000000	384919b3-b330-406a-8507-440194da6d5a	{"action":"login","actor_id":"a007885a-80b3-4486-b31c-6652abca3e12","actor_username":"firdaus@mspo.org.my","actor_via_sso":false,"log_type":"account","traits":{"provider":"email"}}	2025-06-23 05:49:16.723158+00	
00000000-0000-0000-0000-000000000000	738fa0df-10f1-468f-b24f-40150cb41f6a	{"action":"token_refreshed","actor_id":"a007885a-80b3-4486-b31c-6652abca3e12","actor_username":"firdaus@mspo.org.my","actor_via_sso":false,"log_type":"token"}	2025-06-23 07:15:50.604607+00	
00000000-0000-0000-0000-000000000000	8f61e57b-c6f2-4391-81b3-5fb62b5e1248	{"action":"token_revoked","actor_id":"a007885a-80b3-4486-b31c-6652abca3e12","actor_username":"firdaus@mspo.org.my","actor_via_sso":false,"log_type":"token"}	2025-06-23 07:15:50.60504+00	
00000000-0000-0000-0000-000000000000	bea7fcb0-93ec-4fe2-9d19-96189e1584c8	{"action":"user_signedup","actor_id":"8bc44ea0-2e33-458a-ac4d-298980c44b05","actor_username":"christabelle.winona@tsggroup.my","actor_via_sso":false,"log_type":"team","traits":{"provider":"email"}}	2025-06-23 07:40:12.639544+00	
00000000-0000-0000-0000-000000000000	837f9efd-5055-4cfa-ac72-1730be4bf835	{"action":"login","actor_id":"8bc44ea0-2e33-458a-ac4d-298980c44b05","actor_username":"christabelle.winona@tsggroup.my","actor_via_sso":false,"log_type":"account","traits":{"provider":"email"}}	2025-06-23 07:40:12.642876+00	
00000000-0000-0000-0000-000000000000	8b8b1433-2467-41b7-81c8-855a3c5589bc	{"action":"user_signedup","actor_id":"e2c36046-d53b-4a02-9eef-f85a47d6c357","actor_username":"stephen.lee@grandolie.com","actor_via_sso":false,"log_type":"team","traits":{"provider":"email"}}	2025-06-23 07:40:13.673599+00	
00000000-0000-0000-0000-000000000000	628a9309-0843-4080-bcca-ce16c922a8e7	{"action":"login","actor_id":"e2c36046-d53b-4a02-9eef-f85a47d6c357","actor_username":"stephen.lee@grandolie.com","actor_via_sso":false,"log_type":"account","traits":{"provider":"email"}}	2025-06-23 07:40:13.679025+00	
00000000-0000-0000-0000-000000000000	b1c84878-b1c5-4f1f-9a63-b04a4d821629	{"action":"user_signedup","actor_id":"c3a67ce5-0445-4f78-8259-c115bc188a26","actor_username":"tingpikhieng@gmail.com","actor_via_sso":false,"log_type":"team","traits":{"provider":"email"}}	2025-06-23 07:40:31.205286+00	
00000000-0000-0000-0000-000000000000	193d2ea7-b17a-41d7-8ad9-b24b4216eedd	{"action":"login","actor_id":"c3a67ce5-0445-4f78-8259-c115bc188a26","actor_username":"tingpikhieng@gmail.com","actor_via_sso":false,"log_type":"account","traits":{"provider":"email"}}	2025-06-23 07:40:31.207779+00	
00000000-0000-0000-0000-000000000000	dcc7ed30-9997-4fea-9831-eb6ee9a390fe	{"action":"user_repeated_signup","actor_id":"b0b2df8d-3835-4d06-a95d-d6a376b95ea1","actor_username":"adeline.stefanie.ta@gmail.com","actor_via_sso":false,"log_type":"user","traits":{"provider":"email"}}	2025-06-23 07:40:37.712074+00	
00000000-0000-0000-0000-000000000000	761ca099-d56a-4e7d-bc42-ec0f17267c4c	{"action":"user_repeated_signup","actor_id":"b0b2df8d-3835-4d06-a95d-d6a376b95ea1","actor_username":"adeline.stefanie.ta@gmail.com","actor_via_sso":false,"log_type":"user","traits":{"provider":"email"}}	2025-06-23 07:40:41.588431+00	
00000000-0000-0000-0000-000000000000	3ae3cfed-7dba-4b0b-9100-514e39aca07e	{"action":"user_signedup","actor_id":"20754c43-864b-45c9-8e9d-5f71b3dceb39","actor_username":"patriciachan@salcra.gov.my","actor_via_sso":false,"log_type":"team","traits":{"provider":"email"}}	2025-06-23 07:40:45.978558+00	
00000000-0000-0000-0000-000000000000	1e245351-c97b-4d6d-9138-61a19353c9b6	{"action":"login","actor_id":"20754c43-864b-45c9-8e9d-5f71b3dceb39","actor_username":"patriciachan@salcra.gov.my","actor_via_sso":false,"log_type":"account","traits":{"provider":"email"}}	2025-06-23 07:40:45.980579+00	
00000000-0000-0000-0000-000000000000	32ea83ce-0c50-4620-9621-4345cb11fe7f	{"action":"user_signedup","actor_id":"a1008ee6-6805-4d56-956d-0bcaad374870","actor_username":"abigail@salcra.gov.my","actor_via_sso":false,"log_type":"team","traits":{"provider":"email"}}	2025-06-23 07:40:50.631147+00	
00000000-0000-0000-0000-000000000000	36241c62-8736-4978-b025-e9ad25b5043d	{"action":"login","actor_id":"a1008ee6-6805-4d56-956d-0bcaad374870","actor_username":"abigail@salcra.gov.my","actor_via_sso":false,"log_type":"account","traits":{"provider":"email"}}	2025-06-23 07:40:50.63299+00	
00000000-0000-0000-0000-000000000000	705baeb1-6153-4c7b-a710-ce668c8750f7	{"action":"user_repeated_signup","actor_id":"b0b2df8d-3835-4d06-a95d-d6a376b95ea1","actor_username":"adeline.stefanie.ta@gmail.com","actor_via_sso":false,"log_type":"user","traits":{"provider":"email"}}	2025-06-23 07:40:55.351979+00	
00000000-0000-0000-0000-000000000000	708add9f-f185-4000-83a8-90ad03c383e4	{"action":"user_repeated_signup","actor_id":"b0b2df8d-3835-4d06-a95d-d6a376b95ea1","actor_username":"adeline.stefanie.ta@gmail.com","actor_via_sso":false,"log_type":"user","traits":{"provider":"email"}}	2025-06-23 07:41:01.920067+00	
00000000-0000-0000-0000-000000000000	ea9e2b7d-0fb6-4e2b-b58f-6162ce2a2c6e	{"action":"user_repeated_signup","actor_id":"b0b2df8d-3835-4d06-a95d-d6a376b95ea1","actor_username":"adeline.stefanie.ta@gmail.com","actor_via_sso":false,"log_type":"user","traits":{"provider":"email"}}	2025-06-23 07:41:06.879316+00	
00000000-0000-0000-0000-000000000000	83117d5e-9437-405b-83db-53e74d473155	{"action":"user_repeated_signup","actor_id":"b0b2df8d-3835-4d06-a95d-d6a376b95ea1","actor_username":"adeline.stefanie.ta@gmail.com","actor_via_sso":false,"log_type":"user","traits":{"provider":"email"}}	2025-06-23 07:41:15.762376+00	
00000000-0000-0000-0000-000000000000	66b33c9b-e5b5-4dc2-9ebd-370dcfbe858b	{"action":"token_refreshed","actor_id":"a007885a-80b3-4486-b31c-6652abca3e12","actor_username":"firdaus@mspo.org.my","actor_via_sso":false,"log_type":"token"}	2025-06-23 07:41:38.937648+00	
00000000-0000-0000-0000-000000000000	d203dc0d-a047-433d-a42f-2ab37ced7d6d	{"action":"token_revoked","actor_id":"a007885a-80b3-4486-b31c-6652abca3e12","actor_username":"firdaus@mspo.org.my","actor_via_sso":false,"log_type":"token"}	2025-06-23 07:41:38.938029+00	
00000000-0000-0000-0000-000000000000	01a18a6d-fc15-46b2-9eb6-8e3f654a393e	{"action":"user_signedup","actor_id":"fd238175-c03f-4b7a-a819-0837b802ae2c","actor_username":"davidb@salcra.gov.my","actor_via_sso":false,"log_type":"team","traits":{"provider":"email"}}	2025-06-23 07:41:53.928304+00	
00000000-0000-0000-0000-000000000000	2beb3b94-d5dc-4f8d-8bf0-c55581383c0f	{"action":"login","actor_id":"fd238175-c03f-4b7a-a819-0837b802ae2c","actor_username":"davidb@salcra.gov.my","actor_via_sso":false,"log_type":"account","traits":{"provider":"email"}}	2025-06-23 07:41:53.957058+00	
00000000-0000-0000-0000-000000000000	d36b00b0-7c5b-4aca-af39-7dc318d158ee	{"action":"user_signedup","actor_id":"5dfc121a-a553-4380-9094-d716a81b495f","actor_username":"francefcw@yahoo.com","actor_via_sso":false,"log_type":"team","traits":{"provider":"email"}}	2025-06-23 07:41:59.338676+00	
00000000-0000-0000-0000-000000000000	a11da39f-b4ed-4caa-b494-644a261fdc6a	{"action":"login","actor_id":"5dfc121a-a553-4380-9094-d716a81b495f","actor_username":"francefcw@yahoo.com","actor_via_sso":false,"log_type":"account","traits":{"provider":"email"}}	2025-06-23 07:41:59.340273+00	
00000000-0000-0000-0000-000000000000	bbd9f508-45b5-4a22-9228-c99535a752b2	{"action":"user_signedup","actor_id":"ba467302-a9dd-49f1-bb39-442fdab37dcd","actor_username":"margetha.achong@my.wilmar-intl.com","actor_via_sso":false,"log_type":"team","traits":{"provider":"email"}}	2025-06-23 07:42:01.09905+00	
00000000-0000-0000-0000-000000000000	853df2fc-d31a-460d-9ec9-36f1ad3313a3	{"action":"login","actor_id":"ba467302-a9dd-49f1-bb39-442fdab37dcd","actor_username":"margetha.achong@my.wilmar-intl.com","actor_via_sso":false,"log_type":"account","traits":{"provider":"email"}}	2025-06-23 07:42:01.102433+00	
00000000-0000-0000-0000-000000000000	6455b95f-1613-4712-8775-7029756472a9	{"action":"user_repeated_signup","actor_id":"b0b2df8d-3835-4d06-a95d-d6a376b95ea1","actor_username":"adeline.stefanie.ta@gmail.com","actor_via_sso":false,"log_type":"user","traits":{"provider":"email"}}	2025-06-23 07:42:24.225936+00	
00000000-0000-0000-0000-000000000000	803ca016-b300-492c-9bf6-551f8c162cf1	{"action":"user_signedup","actor_id":"3f695e7a-da08-4344-8d1c-60d1e4d3d772","actor_username":"josephrn@salcra.gov.my","actor_via_sso":false,"log_type":"team","traits":{"provider":"email"}}	2025-06-23 07:42:25.110221+00	
00000000-0000-0000-0000-000000000000	fd6f10a3-8eb7-46b1-80c6-d0b8894b8bb7	{"action":"login","actor_id":"3f695e7a-da08-4344-8d1c-60d1e4d3d772","actor_username":"josephrn@salcra.gov.my","actor_via_sso":false,"log_type":"account","traits":{"provider":"email"}}	2025-06-23 07:42:25.11197+00	
00000000-0000-0000-0000-000000000000	adc1f23d-82ca-4d6b-906b-af9c5c0d12c6	{"action":"login","actor_id":"5dfc121a-a553-4380-9094-d716a81b495f","actor_username":"francefcw@yahoo.com","actor_via_sso":false,"log_type":"account","traits":{"provider":"email"}}	2025-06-23 07:42:27.066964+00	
00000000-0000-0000-0000-000000000000	b21dbeb7-c4f6-47cf-9373-9e96cf1d88d3	{"action":"user_repeated_signup","actor_id":"b0b2df8d-3835-4d06-a95d-d6a376b95ea1","actor_username":"adeline.stefanie.ta@gmail.com","actor_via_sso":false,"log_type":"user","traits":{"provider":"email"}}	2025-06-23 07:42:27.346578+00	
00000000-0000-0000-0000-000000000000	182d985f-17c9-4e2f-9734-4f914df4d976	{"action":"user_signedup","actor_id":"e4f7c6ca-5cfe-411a-a814-45a13ee76fe4","actor_username":"kru@thplantations.com","actor_via_sso":false,"log_type":"team","traits":{"provider":"email"}}	2025-06-23 07:42:27.468286+00	
00000000-0000-0000-0000-000000000000	726894ea-9752-4bab-8238-1734aeccf56d	{"action":"login","actor_id":"e4f7c6ca-5cfe-411a-a814-45a13ee76fe4","actor_username":"kru@thplantations.com","actor_via_sso":false,"log_type":"account","traits":{"provider":"email"}}	2025-06-23 07:42:27.469867+00	
00000000-0000-0000-0000-000000000000	7f30eee4-7288-4d1f-8e0e-24d66f7afc20	{"action":"user_signedup","actor_id":"878637b4-5c02-462a-80e3-edd2cb4dd365","actor_username":"pairinsonjengok.86@gmail.com","actor_via_sso":false,"log_type":"team","traits":{"provider":"email"}}	2025-06-23 07:42:35.153671+00	
00000000-0000-0000-0000-000000000000	cf52e37f-3c80-4550-acd1-967c831eb28b	{"action":"login","actor_id":"878637b4-5c02-462a-80e3-edd2cb4dd365","actor_username":"pairinsonjengok.86@gmail.com","actor_via_sso":false,"log_type":"account","traits":{"provider":"email"}}	2025-06-23 07:42:35.155553+00	
00000000-0000-0000-0000-000000000000	2556124b-dae9-4d8c-809e-7c58eb55f2f2	{"action":"user_signedup","actor_id":"2186e85a-0204-40d2-ac5a-1ae7600edfa3","actor_username":"risnid@salcra.gov.my","actor_via_sso":false,"log_type":"team","traits":{"provider":"email"}}	2025-06-23 07:42:35.312888+00	
00000000-0000-0000-0000-000000000000	f47f42b6-78a4-4fac-afe7-1561be2419a8	{"action":"login","actor_id":"2186e85a-0204-40d2-ac5a-1ae7600edfa3","actor_username":"risnid@salcra.gov.my","actor_via_sso":false,"log_type":"account","traits":{"provider":"email"}}	2025-06-23 07:42:35.314564+00	
00000000-0000-0000-0000-000000000000	e004b9ce-eee6-4d6b-a674-dde24d9f25ae	{"action":"login","actor_id":"8bc44ea0-2e33-458a-ac4d-298980c44b05","actor_username":"christabelle.winona@tsggroup.my","actor_via_sso":false,"log_type":"account","traits":{"provider":"email"}}	2025-06-23 07:42:39.769154+00	
00000000-0000-0000-0000-000000000000	c5ac530f-20bf-4944-9bfb-7374f2ceaac7	{"action":"user_signedup","actor_id":"f7280a96-7703-4d4d-b2a8-9d2acc15a160","actor_username":"alicesa.ramba@keresa.com.my","actor_via_sso":false,"log_type":"team","traits":{"provider":"email"}}	2025-06-23 07:42:41.759488+00	
00000000-0000-0000-0000-000000000000	a776b91a-a649-43b4-8078-9dc7efd66bfe	{"action":"login","actor_id":"f7280a96-7703-4d4d-b2a8-9d2acc15a160","actor_username":"alicesa.ramba@keresa.com.my","actor_via_sso":false,"log_type":"account","traits":{"provider":"email"}}	2025-06-23 07:42:41.78018+00	
00000000-0000-0000-0000-000000000000	7b7b61e2-9187-4415-8481-f868fa376a6e	{"action":"user_repeated_signup","actor_id":"b0b2df8d-3835-4d06-a95d-d6a376b95ea1","actor_username":"adeline.stefanie.ta@gmail.com","actor_via_sso":false,"log_type":"user","traits":{"provider":"email"}}	2025-06-23 07:42:42.764422+00	
00000000-0000-0000-0000-000000000000	61e81041-0610-41df-b1b2-9c2bda801b39	{"action":"user_signedup","actor_id":"9e2f17ea-26c5-414b-835c-f9b42705c024","actor_username":"mohdhafizmohamadrafiq@gmail.com","actor_via_sso":false,"log_type":"team","traits":{"provider":"email"}}	2025-06-23 07:42:52.933034+00	
00000000-0000-0000-0000-000000000000	cf17bef4-51a5-4e0b-bb0a-b6c5c77a8b13	{"action":"login","actor_id":"9e2f17ea-26c5-414b-835c-f9b42705c024","actor_username":"mohdhafizmohamadrafiq@gmail.com","actor_via_sso":false,"log_type":"account","traits":{"provider":"email"}}	2025-06-23 07:42:52.934631+00	
00000000-0000-0000-0000-000000000000	8db40d51-2613-4cfa-a26c-39619270d4e0	{"action":"user_repeated_signup","actor_id":"b0b2df8d-3835-4d06-a95d-d6a376b95ea1","actor_username":"adeline.stefanie.ta@gmail.com","actor_via_sso":false,"log_type":"user","traits":{"provider":"email"}}	2025-06-23 07:42:56.763075+00	
00000000-0000-0000-0000-000000000000	d5f72e22-f7ef-487f-95d2-4491010ae883	{"action":"user_repeated_signup","actor_id":"b0b2df8d-3835-4d06-a95d-d6a376b95ea1","actor_username":"adeline.stefanie.ta@gmail.com","actor_via_sso":false,"log_type":"user","traits":{"provider":"email"}}	2025-06-23 07:42:58.891105+00	
00000000-0000-0000-0000-000000000000	9f440e70-8e4c-4067-bb8c-3e2734dabca4	{"action":"user_signedup","actor_id":"7df7ea94-16ba-4fd6-85bc-4fd0155fe284","actor_username":"soon.masranti@gmail.com","actor_via_sso":false,"log_type":"team","traits":{"provider":"email"}}	2025-06-23 07:43:02.124545+00	
00000000-0000-0000-0000-000000000000	3e8395b5-a49d-4d63-aeb0-204f68e1a848	{"action":"login","actor_id":"7df7ea94-16ba-4fd6-85bc-4fd0155fe284","actor_username":"soon.masranti@gmail.com","actor_via_sso":false,"log_type":"account","traits":{"provider":"email"}}	2025-06-23 07:43:02.126162+00	
00000000-0000-0000-0000-000000000000	c93952e3-4b1d-483d-b473-0111a6f70930	{"action":"user_signedup","actor_id":"bc9650f6-a750-4deb-98f6-636b76c60b62","actor_username":"eliana.robert@tpb.com.my","actor_via_sso":false,"log_type":"team","traits":{"provider":"email"}}	2025-06-23 07:43:10.624538+00	
00000000-0000-0000-0000-000000000000	4a07b236-0a1a-4b3c-a16c-48c5ce0f7ab1	{"action":"login","actor_id":"bc9650f6-a750-4deb-98f6-636b76c60b62","actor_username":"eliana.robert@tpb.com.my","actor_via_sso":false,"log_type":"account","traits":{"provider":"email"}}	2025-06-23 07:43:10.626733+00	
00000000-0000-0000-0000-000000000000	956133c1-5754-49af-8a1d-e70a21548750	{"action":"login","actor_id":"c3a67ce5-0445-4f78-8259-c115bc188a26","actor_username":"tingpikhieng@gmail.com","actor_via_sso":false,"log_type":"account","traits":{"provider":"email"}}	2025-06-23 07:43:19.09658+00	
00000000-0000-0000-0000-000000000000	457e6139-b974-4009-b451-30825097b5f1	{"action":"user_repeated_signup","actor_id":"b0b2df8d-3835-4d06-a95d-d6a376b95ea1","actor_username":"adeline.stefanie.ta@gmail.com","actor_via_sso":false,"log_type":"user","traits":{"provider":"email"}}	2025-06-23 07:43:21.502685+00	
00000000-0000-0000-0000-000000000000	ccdd868f-9f67-4c83-886a-ed9bea25d855	{"action":"user_signedup","actor_id":"0d12ddb0-122b-46a3-afba-c35c8640e887","actor_username":"simleongeng@yahoo.com","actor_via_sso":false,"log_type":"team","traits":{"provider":"email"}}	2025-06-23 07:43:26.702834+00	
00000000-0000-0000-0000-000000000000	61c50127-b893-4894-9d64-286ea19fb273	{"action":"login","actor_id":"0d12ddb0-122b-46a3-afba-c35c8640e887","actor_username":"simleongeng@yahoo.com","actor_via_sso":false,"log_type":"account","traits":{"provider":"email"}}	2025-06-23 07:43:26.708411+00	
00000000-0000-0000-0000-000000000000	0d1bd02e-d684-4f60-97a8-24101cc31e04	{"action":"user_signedup","actor_id":"a4051467-1969-4a0f-8657-d8f3f0ba6359","actor_username":"dienstainkemiti@gmail.com","actor_via_sso":false,"log_type":"team","traits":{"provider":"email"}}	2025-06-23 07:43:52.635601+00	
00000000-0000-0000-0000-000000000000	a42ea19f-8de2-414a-b10a-3e9bf926525f	{"action":"login","actor_id":"a4051467-1969-4a0f-8657-d8f3f0ba6359","actor_username":"dienstainkemiti@gmail.com","actor_via_sso":false,"log_type":"account","traits":{"provider":"email"}}	2025-06-23 07:43:52.637224+00	
00000000-0000-0000-0000-000000000000	f43b20f4-f5eb-4f0a-90a7-37950257642b	{"action":"user_signedup","actor_id":"0cd2be50-abf7-420e-a986-7fa5371cf6a3","actor_username":"emilia.as@tpb.com.my","actor_via_sso":false,"log_type":"team","traits":{"provider":"email"}}	2025-06-23 07:44:11.29893+00	
00000000-0000-0000-0000-000000000000	4f82c88f-3eb9-4f7c-a79a-3dcba2abea39	{"action":"login","actor_id":"0cd2be50-abf7-420e-a986-7fa5371cf6a3","actor_username":"emilia.as@tpb.com.my","actor_via_sso":false,"log_type":"account","traits":{"provider":"email"}}	2025-06-23 07:44:11.300765+00	
00000000-0000-0000-0000-000000000000	6aa24798-0c7a-4ee2-97bb-956e6538d6f6	{"action":"login","actor_id":"ba467302-a9dd-49f1-bb39-442fdab37dcd","actor_username":"margetha.achong@my.wilmar-intl.com","actor_via_sso":false,"log_type":"account","traits":{"provider":"email"}}	2025-06-23 07:44:15.552501+00	
00000000-0000-0000-0000-000000000000	9b4aad60-bb13-4dbd-87fa-a61289e7fea5	{"action":"login","actor_id":"e4f7c6ca-5cfe-411a-a814-45a13ee76fe4","actor_username":"kru@thplantations.com","actor_via_sso":false,"log_type":"account","traits":{"provider":"email"}}	2025-06-23 07:44:23.617886+00	
00000000-0000-0000-0000-000000000000	5cf5d082-debc-4341-b689-b465cfa29263	{"action":"user_repeated_signup","actor_id":"b0b2df8d-3835-4d06-a95d-d6a376b95ea1","actor_username":"adeline.stefanie.ta@gmail.com","actor_via_sso":false,"log_type":"user","traits":{"provider":"email"}}	2025-06-23 07:44:25.269133+00	
00000000-0000-0000-0000-000000000000	ae160a16-b61d-44df-86e4-5bfb11ebe06d	{"action":"user_signedup","actor_id":"ac59ee7e-0939-4e05-bf57-be9508f40d82","actor_username":"rsblundupom@rsb.com.my","actor_via_sso":false,"log_type":"team","traits":{"provider":"email"}}	2025-06-23 07:44:36.497974+00	
00000000-0000-0000-0000-000000000000	92703bb4-f24f-4dcf-83c9-677980cde4bd	{"action":"login","actor_id":"ac59ee7e-0939-4e05-bf57-be9508f40d82","actor_username":"rsblundupom@rsb.com.my","actor_via_sso":false,"log_type":"account","traits":{"provider":"email"}}	2025-06-23 07:44:36.49966+00	
00000000-0000-0000-0000-000000000000	68a473cf-df43-4d51-9025-612ae0ff196d	{"action":"login","actor_id":"878637b4-5c02-462a-80e3-edd2cb4dd365","actor_username":"pairinsonjengok.86@gmail.com","actor_via_sso":false,"log_type":"account","traits":{"provider":"email"}}	2025-06-23 07:44:40.290427+00	
00000000-0000-0000-0000-000000000000	c0e9c6d9-647e-4ba9-80b5-b5c8f08cd1d5	{"action":"user_repeated_signup","actor_id":"b0b2df8d-3835-4d06-a95d-d6a376b95ea1","actor_username":"adeline.stefanie.ta@gmail.com","actor_via_sso":false,"log_type":"user","traits":{"provider":"email"}}	2025-06-23 07:44:47.094488+00	
00000000-0000-0000-0000-000000000000	9dca048f-da20-4c51-9b0f-7e1d6e2c4b6c	{"action":"user_signedup","actor_id":"016ca48e-66c5-476c-9716-c6397ed60e69","actor_username":"raphaelmodany@gmail.com","actor_via_sso":false,"log_type":"team","traits":{"provider":"email"}}	2025-06-23 07:44:52.035516+00	
00000000-0000-0000-0000-000000000000	e936afdf-ff63-4b4b-9149-f8daa795f05a	{"action":"login","actor_id":"016ca48e-66c5-476c-9716-c6397ed60e69","actor_username":"raphaelmodany@gmail.com","actor_via_sso":false,"log_type":"account","traits":{"provider":"email"}}	2025-06-23 07:44:52.037048+00	
00000000-0000-0000-0000-000000000000	9f7c7750-8cca-4c48-ae6f-903eb161908b	{"action":"user_signedup","actor_id":"08a2cbdf-9a26-4469-9034-ed7b3f5b73e9","actor_username":"tbs.mill.admin@taann.com.my","actor_via_sso":false,"log_type":"team","traits":{"provider":"email"}}	2025-06-23 07:44:52.386824+00	
00000000-0000-0000-0000-000000000000	60995824-2ab3-4aa1-87aa-d3a727a125f6	{"action":"login","actor_id":"08a2cbdf-9a26-4469-9034-ed7b3f5b73e9","actor_username":"tbs.mill.admin@taann.com.my","actor_via_sso":false,"log_type":"account","traits":{"provider":"email"}}	2025-06-23 07:44:52.388394+00	
00000000-0000-0000-0000-000000000000	e50460a2-08c9-431f-b636-7bc52cfea926	{"action":"login","actor_id":"e2c36046-d53b-4a02-9eef-f85a47d6c357","actor_username":"stephen.lee@grandolie.com","actor_via_sso":false,"log_type":"account","traits":{"provider":"email"}}	2025-06-23 07:45:00.739395+00	
00000000-0000-0000-0000-000000000000	e5f5aaaa-eaa4-434d-b651-7e5000b87909	{"action":"user_signedup","actor_id":"ee74b89d-137d-470c-8a00-90fb5a372727","actor_username":"wifredk@salcra.gov.my","actor_via_sso":false,"log_type":"team","traits":{"provider":"email"}}	2025-06-23 07:45:13.471471+00	
00000000-0000-0000-0000-000000000000	25921159-49a3-44ed-9723-93a4a3c8cbd1	{"action":"login","actor_id":"ee74b89d-137d-470c-8a00-90fb5a372727","actor_username":"wifredk@salcra.gov.my","actor_via_sso":false,"log_type":"account","traits":{"provider":"email"}}	2025-06-23 07:45:13.47451+00	
00000000-0000-0000-0000-000000000000	210fb10f-fd8e-48f9-9d6c-299fcb5db926	{"action":"user_signedup","actor_id":"47676bae-55c6-48f5-8b6a-dc0a3af02ec4","actor_username":"diana.do@keresa.com.my","actor_via_sso":false,"log_type":"team","traits":{"provider":"email"}}	2025-06-23 07:45:26.430827+00	
00000000-0000-0000-0000-000000000000	e53daf67-69e9-4aa5-bc59-592fbc0ca493	{"action":"login","actor_id":"47676bae-55c6-48f5-8b6a-dc0a3af02ec4","actor_username":"diana.do@keresa.com.my","actor_via_sso":false,"log_type":"account","traits":{"provider":"email"}}	2025-06-23 07:45:26.433157+00	
00000000-0000-0000-0000-000000000000	6c288e4a-b7b9-4a2e-b7f7-3366de8c2e45	{"action":"user_signedup","actor_id":"1698b43a-831d-455f-bb6f-22c3097c005f","actor_username":"ndhiera82@gmail.com","actor_via_sso":false,"log_type":"team","traits":{"provider":"email"}}	2025-06-23 07:45:27.886856+00	
00000000-0000-0000-0000-000000000000	0e08e9fc-ea6d-4912-aad0-ddccb3ac3680	{"action":"login","actor_id":"1698b43a-831d-455f-bb6f-22c3097c005f","actor_username":"ndhiera82@gmail.com","actor_via_sso":false,"log_type":"account","traits":{"provider":"email"}}	2025-06-23 07:45:27.891787+00	
00000000-0000-0000-0000-000000000000	af779801-6633-4d39-82c7-9bb2ba59dca6	{"action":"user_signedup","actor_id":"3142bce6-7211-4fd1-a09f-1d17e6cf287a","actor_username":"jubaidahadam123@gmail.com","actor_via_sso":false,"log_type":"team","traits":{"provider":"email"}}	2025-06-23 07:45:30.953785+00	
00000000-0000-0000-0000-000000000000	22eec124-b9b8-47e0-9ec6-b42a8914a409	{"action":"login","actor_id":"3142bce6-7211-4fd1-a09f-1d17e6cf287a","actor_username":"jubaidahadam123@gmail.com","actor_via_sso":false,"log_type":"account","traits":{"provider":"email"}}	2025-06-23 07:45:30.955375+00	
00000000-0000-0000-0000-000000000000	8409d320-cccc-4f3f-ad9d-200a150cf6cb	{"action":"user_signedup","actor_id":"9e6b451a-3a18-4f0c-97f3-fcccefe12a55","actor_username":"norlidakeri1@gmail.com","actor_via_sso":false,"log_type":"team","traits":{"provider":"email"}}	2025-06-23 07:45:35.862344+00	
00000000-0000-0000-0000-000000000000	6639a507-3448-4ad5-8a0f-bce77d8972c7	{"action":"login","actor_id":"9e6b451a-3a18-4f0c-97f3-fcccefe12a55","actor_username":"norlidakeri1@gmail.com","actor_via_sso":false,"log_type":"account","traits":{"provider":"email"}}	2025-06-23 07:45:35.864234+00	
00000000-0000-0000-0000-000000000000	96ad15a4-91f5-4721-b400-63938873105b	{"action":"user_signedup","actor_id":"a829ccb9-78d5-4940-82f6-934352e828cd","actor_username":"lpom.samling@gmail.com","actor_via_sso":false,"log_type":"team","traits":{"provider":"email"}}	2025-06-23 07:45:50.211965+00	
00000000-0000-0000-0000-000000000000	3b833505-321d-4e20-9015-a5fce7a302f6	{"action":"login","actor_id":"a829ccb9-78d5-4940-82f6-934352e828cd","actor_username":"lpom.samling@gmail.com","actor_via_sso":false,"log_type":"account","traits":{"provider":"email"}}	2025-06-23 07:45:50.213598+00	
00000000-0000-0000-0000-000000000000	2913c168-76a4-4698-ae9d-7edcfb753865	{"action":"user_repeated_signup","actor_id":"a829ccb9-78d5-4940-82f6-934352e828cd","actor_username":"lpom.samling@gmail.com","actor_via_sso":false,"log_type":"user","traits":{"provider":"email"}}	2025-06-23 07:45:50.261108+00	
00000000-0000-0000-0000-000000000000	95b3bf9f-4d3b-445b-9da1-e432e08d0d76	{"action":"user_signedup","actor_id":"6dc3e17b-1af0-4a4b-abaf-a9830465a207","actor_username":"pelicitym@salcra.gov.my","actor_via_sso":false,"log_type":"team","traits":{"provider":"email"}}	2025-06-23 07:45:55.125145+00	
00000000-0000-0000-0000-000000000000	bc8a3841-768c-4af9-9f33-01d8fa79f5a1	{"action":"login","actor_id":"6dc3e17b-1af0-4a4b-abaf-a9830465a207","actor_username":"pelicitym@salcra.gov.my","actor_via_sso":false,"log_type":"account","traits":{"provider":"email"}}	2025-06-23 07:45:55.126857+00	
00000000-0000-0000-0000-000000000000	66cba9b2-9b83-46b3-97c1-21f0748b4f08	{"action":"user_signedup","actor_id":"4e579a51-bb42-45f1-9b79-b84928a98421","actor_username":"kaveeraaz@gmail.com","actor_via_sso":false,"log_type":"team","traits":{"provider":"email"}}	2025-06-23 07:46:01.255447+00	
00000000-0000-0000-0000-000000000000	c186a85d-f90d-43a5-b722-fc6dbddd0f66	{"action":"login","actor_id":"4e579a51-bb42-45f1-9b79-b84928a98421","actor_username":"kaveeraaz@gmail.com","actor_via_sso":false,"log_type":"account","traits":{"provider":"email"}}	2025-06-23 07:46:01.257096+00	
00000000-0000-0000-0000-000000000000	0db5ac0d-96c3-4748-976c-8a7c951b7738	{"action":"login","actor_id":"08a2cbdf-9a26-4469-9034-ed7b3f5b73e9","actor_username":"tbs.mill.admin@taann.com.my","actor_via_sso":false,"log_type":"account","traits":{"provider":"email"}}	2025-06-23 07:46:05.225449+00	
00000000-0000-0000-0000-000000000000	e1003c68-cb17-4a61-9962-84ff02d879f6	{"action":"user_signedup","actor_id":"7d693d50-00d4-4a9b-9bc0-35afebbb30d9","actor_username":"richardting@spbgroup.com.my","actor_via_sso":false,"log_type":"team","traits":{"provider":"email"}}	2025-06-23 07:46:08.167991+00	
00000000-0000-0000-0000-000000000000	431ce7ab-75cc-4413-b938-341125459fc7	{"action":"login","actor_id":"7d693d50-00d4-4a9b-9bc0-35afebbb30d9","actor_username":"richardting@spbgroup.com.my","actor_via_sso":false,"log_type":"account","traits":{"provider":"email"}}	2025-06-23 07:46:08.169586+00	
00000000-0000-0000-0000-000000000000	9ba7ec32-a27d-4b9f-8700-95edd3f2b7fb	{"action":"user_signedup","actor_id":"7f05337a-1f10-411a-8c90-ab632faaf8c2","actor_username":"manisoil.mill.admin@taann.com.my","actor_via_sso":false,"log_type":"team","traits":{"provider":"email"}}	2025-06-23 07:46:22.354213+00	
00000000-0000-0000-0000-000000000000	f3daeec7-0170-4a68-9654-f1cd59bb916e	{"action":"login","actor_id":"7f05337a-1f10-411a-8c90-ab632faaf8c2","actor_username":"manisoil.mill.admin@taann.com.my","actor_via_sso":false,"log_type":"account","traits":{"provider":"email"}}	2025-06-23 07:46:22.355725+00	
00000000-0000-0000-0000-000000000000	78650203-0a7e-46ee-b793-9614204cb15f	{"action":"user_signedup","actor_id":"7b53d13f-0338-44ff-a05d-238f8d25cad4","actor_username":"genevieve.chinhoweyiin@my.wilmar-intl.com","actor_via_sso":false,"log_type":"team","traits":{"provider":"email"}}	2025-06-23 07:46:31.430135+00	
00000000-0000-0000-0000-000000000000	82bf6cd5-58dd-43df-93c7-612108cf6dd8	{"action":"login","actor_id":"7b53d13f-0338-44ff-a05d-238f8d25cad4","actor_username":"genevieve.chinhoweyiin@my.wilmar-intl.com","actor_via_sso":false,"log_type":"account","traits":{"provider":"email"}}	2025-06-23 07:46:31.432034+00	
00000000-0000-0000-0000-000000000000	6891b490-ff97-4657-b4b7-da378836ae81	{"action":"user_signedup","actor_id":"6c383e4a-a52d-4661-8a6c-4be47b0ed340","actor_username":"eyz71@yahoo.com","actor_via_sso":false,"log_type":"team","traits":{"provider":"email"}}	2025-06-23 07:46:53.266283+00	
00000000-0000-0000-0000-000000000000	558338f4-f180-48bf-80c0-72f57c9ce5ca	{"action":"login","actor_id":"6c383e4a-a52d-4661-8a6c-4be47b0ed340","actor_username":"eyz71@yahoo.com","actor_via_sso":false,"log_type":"account","traits":{"provider":"email"}}	2025-06-23 07:46:53.269439+00	
00000000-0000-0000-0000-000000000000	6e9aa235-8b15-4ff7-8084-c35c398d5430	{"action":"login","actor_id":"9e6b451a-3a18-4f0c-97f3-fcccefe12a55","actor_username":"norlidakeri1@gmail.com","actor_via_sso":false,"log_type":"account","traits":{"provider":"email"}}	2025-06-23 07:46:58.139818+00	
00000000-0000-0000-0000-000000000000	cd419f35-824d-47e0-8741-60603864f146	{"action":"user_signedup","actor_id":"8175ff46-a82f-41f1-9650-87661f8acbb1","actor_username":"hhelina@gmail.com","actor_via_sso":false,"log_type":"team","traits":{"provider":"email"}}	2025-06-23 07:47:12.292929+00	
00000000-0000-0000-0000-000000000000	c52089d4-3fb0-451e-bbb3-d54f75def9e6	{"action":"login","actor_id":"8175ff46-a82f-41f1-9650-87661f8acbb1","actor_username":"hhelina@gmail.com","actor_via_sso":false,"log_type":"account","traits":{"provider":"email"}}	2025-06-23 07:47:12.294501+00	
00000000-0000-0000-0000-000000000000	890f7ddb-a4f6-4bf8-9ba8-03d1e1975bbb	{"action":"user_signedup","actor_id":"59874f8b-4fdf-41ce-947b-da9240a861ca","actor_username":"patriciah@salcra.gov.my","actor_via_sso":false,"log_type":"team","traits":{"provider":"email"}}	2025-06-23 07:47:12.314241+00	
00000000-0000-0000-0000-000000000000	4f62149d-e66b-4276-9a8e-4b356afeacca	{"action":"login","actor_id":"59874f8b-4fdf-41ce-947b-da9240a861ca","actor_username":"patriciah@salcra.gov.my","actor_via_sso":false,"log_type":"account","traits":{"provider":"email"}}	2025-06-23 07:47:12.315696+00	
00000000-0000-0000-0000-000000000000	30865d1f-ade7-4e10-97d5-66fdce471f16	{"action":"user_signedup","actor_id":"13889f78-4916-4d07-8c07-faf25d913216","actor_username":"uttmill.office@gmail.com","actor_via_sso":false,"log_type":"team","traits":{"provider":"email"}}	2025-06-23 07:47:32.539028+00	
00000000-0000-0000-0000-000000000000	6bd10899-38fa-45e3-a392-86c0475966ef	{"action":"login","actor_id":"13889f78-4916-4d07-8c07-faf25d913216","actor_username":"uttmill.office@gmail.com","actor_via_sso":false,"log_type":"account","traits":{"provider":"email"}}	2025-06-23 07:47:32.540704+00	
00000000-0000-0000-0000-000000000000	c8fa7473-a798-40bf-87cb-934cadb868bb	{"action":"login","actor_id":"9e2f17ea-26c5-414b-835c-f9b42705c024","actor_username":"mohdhafizmohamadrafiq@gmail.com","actor_via_sso":false,"log_type":"account","traits":{"provider":"email"}}	2025-06-23 07:47:36.220592+00	
00000000-0000-0000-0000-000000000000	5486a365-5b08-4719-8a70-aa0831d023db	{"action":"user_repeated_signup","actor_id":"b0b2df8d-3835-4d06-a95d-d6a376b95ea1","actor_username":"adeline.stefanie.ta@gmail.com","actor_via_sso":false,"log_type":"user","traits":{"provider":"email"}}	2025-06-23 07:47:45.542411+00	
00000000-0000-0000-0000-000000000000	fc08cb00-0594-4d34-9fa7-23e3f5dbde7a	{"action":"user_repeated_signup","actor_id":"b0b2df8d-3835-4d06-a95d-d6a376b95ea1","actor_username":"adeline.stefanie.ta@gmail.com","actor_via_sso":false,"log_type":"user","traits":{"provider":"email"}}	2025-06-23 07:47:47.824869+00	
00000000-0000-0000-0000-000000000000	fb20505b-30b7-4c69-8b71-ec3d7b3bd114	{"action":"user_signedup","actor_id":"9ad14374-7580-4a86-a7e7-7e1450f96333","actor_username":"bapom01@salcra.gov.my","actor_via_sso":false,"log_type":"team","traits":{"provider":"email"}}	2025-06-23 07:48:00.337508+00	
00000000-0000-0000-0000-000000000000	f6a9bc35-f42d-4dc9-8899-2fca61f93509	{"action":"login","actor_id":"9ad14374-7580-4a86-a7e7-7e1450f96333","actor_username":"bapom01@salcra.gov.my","actor_via_sso":false,"log_type":"account","traits":{"provider":"email"}}	2025-06-23 07:48:00.339313+00	
00000000-0000-0000-0000-000000000000	f85580a7-af71-43c4-b3ba-96fe21a79517	{"action":"user_repeated_signup","actor_id":"b0b2df8d-3835-4d06-a95d-d6a376b95ea1","actor_username":"adeline.stefanie.ta@gmail.com","actor_via_sso":false,"log_type":"user","traits":{"provider":"email"}}	2025-06-23 07:48:07.842854+00	
00000000-0000-0000-0000-000000000000	06d33f26-85fd-4b6b-9323-34a09907c152	{"action":"user_repeated_signup","actor_id":"9ad14374-7580-4a86-a7e7-7e1450f96333","actor_username":"bapom01@salcra.gov.my","actor_via_sso":false,"log_type":"user","traits":{"provider":"email"}}	2025-06-23 07:48:10.905007+00	
00000000-0000-0000-0000-000000000000	e31c7660-187f-4098-a267-19eef739d93d	{"action":"user_signedup","actor_id":"c31c618f-5148-41bb-802d-025b2b70965a","actor_username":"yc.lee@klkoleo.com","actor_via_sso":false,"log_type":"team","traits":{"provider":"email"}}	2025-06-23 07:48:23.003956+00	
00000000-0000-0000-0000-000000000000	d1c3fb48-a18a-4e68-a022-534f31d2fcf9	{"action":"login","actor_id":"c31c618f-5148-41bb-802d-025b2b70965a","actor_username":"yc.lee@klkoleo.com","actor_via_sso":false,"log_type":"account","traits":{"provider":"email"}}	2025-06-23 07:48:23.005587+00	
00000000-0000-0000-0000-000000000000	cbbb78a5-c1c9-4b32-957c-746f7675ad1d	{"action":"user_repeated_signup","actor_id":"9ad14374-7580-4a86-a7e7-7e1450f96333","actor_username":"bapom01@salcra.gov.my","actor_via_sso":false,"log_type":"user","traits":{"provider":"email"}}	2025-06-23 07:48:46.122168+00	
00000000-0000-0000-0000-000000000000	7b758d19-07c1-4831-9014-4e06be86ddd1	{"action":"user_repeated_signup","actor_id":"9ad14374-7580-4a86-a7e7-7e1450f96333","actor_username":"bapom01@salcra.gov.my","actor_via_sso":false,"log_type":"user","traits":{"provider":"email"}}	2025-06-23 07:49:34.08783+00	
00000000-0000-0000-0000-000000000000	8ae12862-1c8d-44d8-b0b9-821b58be9d9e	{"action":"user_repeated_signup","actor_id":"9ad14374-7580-4a86-a7e7-7e1450f96333","actor_username":"bapom01@salcra.gov.my","actor_via_sso":false,"log_type":"user","traits":{"provider":"email"}}	2025-06-23 07:49:37.163048+00	
00000000-0000-0000-0000-000000000000	5f422759-f2f3-4516-97ee-21eceb47797a	{"action":"login","actor_id":"7b53d13f-0338-44ff-a05d-238f8d25cad4","actor_username":"genevieve.chinhoweyiin@my.wilmar-intl.com","actor_via_sso":false,"log_type":"account","traits":{"provider":"email"}}	2025-06-23 07:50:11.15265+00	
00000000-0000-0000-0000-000000000000	c6f199de-b624-4723-ae9e-95c679119d51	{"action":"login","actor_id":"1698b43a-831d-455f-bb6f-22c3097c005f","actor_username":"ndhiera82@gmail.com","actor_via_sso":false,"log_type":"account","traits":{"provider":"email"}}	2025-06-23 07:50:49.589268+00	
00000000-0000-0000-0000-000000000000	405aa34d-7271-4554-89e1-7fefbe6fa7ee	{"action":"login","actor_id":"3142bce6-7211-4fd1-a09f-1d17e6cf287a","actor_username":"jubaidahadam123@gmail.com","actor_via_sso":false,"log_type":"account","traits":{"provider":"email"}}	2025-06-23 07:51:04.744609+00	
00000000-0000-0000-0000-000000000000	adf9815f-fa56-40f6-ae7b-92c24f09c833	{"action":"login","actor_id":"7f05337a-1f10-411a-8c90-ab632faaf8c2","actor_username":"manisoil.mill.admin@taann.com.my","actor_via_sso":false,"log_type":"account","traits":{"provider":"email"}}	2025-06-23 07:51:06.859547+00	
00000000-0000-0000-0000-000000000000	a86b4a02-2b5f-4cb6-8a49-6c7f2df7ece8	{"action":"user_signedup","actor_id":"a6ee5043-034b-496f-acc8-328104c06ed9","actor_username":"adstef82@gmail.com","actor_via_sso":false,"log_type":"team","traits":{"provider":"email"}}	2025-06-23 07:51:10.638836+00	
00000000-0000-0000-0000-000000000000	a8912388-55da-4d60-94d9-ea28c15792ed	{"action":"login","actor_id":"a6ee5043-034b-496f-acc8-328104c06ed9","actor_username":"adstef82@gmail.com","actor_via_sso":false,"log_type":"account","traits":{"provider":"email"}}	2025-06-23 07:51:10.640463+00	
00000000-0000-0000-0000-000000000000	f35c4730-1d4f-4477-8fd2-2bd449a9359c	{"action":"login","actor_id":"fd238175-c03f-4b7a-a819-0837b802ae2c","actor_username":"davidb@salcra.gov.my","actor_via_sso":false,"log_type":"account","traits":{"provider":"email"}}	2025-06-23 07:51:23.775934+00	
00000000-0000-0000-0000-000000000000	ec335abb-4d8d-41ef-8712-e16d58e30be2	{"action":"user_repeated_signup","actor_id":"9ad14374-7580-4a86-a7e7-7e1450f96333","actor_username":"bapom01@salcra.gov.my","actor_via_sso":false,"log_type":"user","traits":{"provider":"email"}}	2025-06-23 07:51:43.356848+00	
00000000-0000-0000-0000-000000000000	2a461b4c-0720-41d2-9e7a-ded7527bf47d	{"action":"user_repeated_signup","actor_id":"9ad14374-7580-4a86-a7e7-7e1450f96333","actor_username":"bapom01@salcra.gov.my","actor_via_sso":false,"log_type":"user","traits":{"provider":"email"}}	2025-06-23 07:51:47.229539+00	
00000000-0000-0000-0000-000000000000	9a7f502a-ba73-47ae-9ffb-c65d82ec7c18	{"action":"login","actor_id":"7df7ea94-16ba-4fd6-85bc-4fd0155fe284","actor_username":"soon.masranti@gmail.com","actor_via_sso":false,"log_type":"account","traits":{"provider":"email"}}	2025-06-23 07:52:06.715234+00	
00000000-0000-0000-0000-000000000000	615b1ce7-4bdf-4e2a-9573-e8912c24f310	{"action":"login","actor_id":"a1008ee6-6805-4d56-956d-0bcaad374870","actor_username":"abigail@salcra.gov.my","actor_via_sso":false,"log_type":"account","traits":{"provider":"email"}}	2025-06-23 07:52:48.197671+00	
00000000-0000-0000-0000-000000000000	a1263a2d-144d-4c60-8570-359c20946b42	{"action":"login","actor_id":"ac59ee7e-0939-4e05-bf57-be9508f40d82","actor_username":"rsblundupom@rsb.com.my","actor_via_sso":false,"log_type":"account","traits":{"provider":"email"}}	2025-06-23 07:52:49.604222+00	
00000000-0000-0000-0000-000000000000	879618fd-d96e-49b9-a91f-b9ece4d83a9b	{"action":"login","actor_id":"4e579a51-bb42-45f1-9b79-b84928a98421","actor_username":"kaveeraaz@gmail.com","actor_via_sso":false,"log_type":"account","traits":{"provider":"email"}}	2025-06-23 07:53:12.365409+00	
00000000-0000-0000-0000-000000000000	b44aa423-1446-49c1-b59c-6d2048de5095	{"action":"login","actor_id":"016ca48e-66c5-476c-9716-c6397ed60e69","actor_username":"raphaelmodany@gmail.com","actor_via_sso":false,"log_type":"account","traits":{"provider":"email"}}	2025-06-23 07:53:16.098642+00	
00000000-0000-0000-0000-000000000000	f032ad0d-61d4-4524-98fc-5ccb0b5d58fe	{"action":"user_repeated_signup","actor_id":"9ad14374-7580-4a86-a7e7-7e1450f96333","actor_username":"bapom01@salcra.gov.my","actor_via_sso":false,"log_type":"user","traits":{"provider":"email"}}	2025-06-23 07:53:20.028527+00	
00000000-0000-0000-0000-000000000000	57b2a8c5-2be1-48d1-90d8-ed2debeb7dac	{"action":"login","actor_id":"a829ccb9-78d5-4940-82f6-934352e828cd","actor_username":"lpom.samling@gmail.com","actor_via_sso":false,"log_type":"account","traits":{"provider":"email"}}	2025-06-23 07:53:22.946569+00	
00000000-0000-0000-0000-000000000000	50b9c8f7-4cca-4dad-af68-f35873bdfabb	{"action":"login","actor_id":"6dc3e17b-1af0-4a4b-abaf-a9830465a207","actor_username":"pelicitym@salcra.gov.my","actor_via_sso":false,"log_type":"account","traits":{"provider":"email"}}	2025-06-23 07:53:24.210262+00	
00000000-0000-0000-0000-000000000000	f0672272-3bd2-468e-bf2a-a8455fe26ff8	{"action":"user_repeated_signup","actor_id":"9ad14374-7580-4a86-a7e7-7e1450f96333","actor_username":"bapom01@salcra.gov.my","actor_via_sso":false,"log_type":"user","traits":{"provider":"email"}}	2025-06-23 07:53:30.229014+00	
00000000-0000-0000-0000-000000000000	947e8a1d-88b3-4c55-bf2e-800769973793	{"action":"user_repeated_signup","actor_id":"9ad14374-7580-4a86-a7e7-7e1450f96333","actor_username":"bapom01@salcra.gov.my","actor_via_sso":false,"log_type":"user","traits":{"provider":"email"}}	2025-06-23 07:54:06.158525+00	
00000000-0000-0000-0000-000000000000	58cd4ec0-fe55-4d4a-ae69-2bd83c241fe9	{"action":"login","actor_id":"fd238175-c03f-4b7a-a819-0837b802ae2c","actor_username":"davidb@salcra.gov.my","actor_via_sso":false,"log_type":"account","traits":{"provider":"email"}}	2025-06-23 07:54:08.535727+00	
00000000-0000-0000-0000-000000000000	8e5d6970-a522-4a2c-a308-ba3ce38bcb07	{"action":"user_repeated_signup","actor_id":"9ad14374-7580-4a86-a7e7-7e1450f96333","actor_username":"bapom01@salcra.gov.my","actor_via_sso":false,"log_type":"user","traits":{"provider":"email"}}	2025-06-23 07:54:10.60079+00	
00000000-0000-0000-0000-000000000000	b74a5fe2-7fc5-409a-93a6-6c60f0640536	{"action":"user_repeated_signup","actor_id":"9ad14374-7580-4a86-a7e7-7e1450f96333","actor_username":"bapom01@salcra.gov.my","actor_via_sso":false,"log_type":"user","traits":{"provider":"email"}}	2025-06-23 07:54:15.159581+00	
00000000-0000-0000-0000-000000000000	e3885797-7346-43ed-8114-0ae4fc72169b	{"action":"user_repeated_signup","actor_id":"9ad14374-7580-4a86-a7e7-7e1450f96333","actor_username":"bapom01@salcra.gov.my","actor_via_sso":false,"log_type":"user","traits":{"provider":"email"}}	2025-06-23 07:54:19.032026+00	
00000000-0000-0000-0000-000000000000	1743788d-70a4-4d4a-b547-1ab3e85ea66e	{"action":"login","actor_id":"59874f8b-4fdf-41ce-947b-da9240a861ca","actor_username":"patriciah@salcra.gov.my","actor_via_sso":false,"log_type":"account","traits":{"provider":"email"}}	2025-06-23 07:55:24.746861+00	
00000000-0000-0000-0000-000000000000	15df62fc-d8d1-4cd8-ae69-781f33bb86f8	{"action":"login","actor_id":"7f05337a-1f10-411a-8c90-ab632faaf8c2","actor_username":"manisoil.mill.admin@taann.com.my","actor_via_sso":false,"log_type":"account","traits":{"provider":"email"}}	2025-06-23 07:55:28.576494+00	
00000000-0000-0000-0000-000000000000	5b43fecc-f615-4683-9a6c-65f531d42e59	{"action":"login","actor_id":"fd238175-c03f-4b7a-a819-0837b802ae2c","actor_username":"davidb@salcra.gov.my","actor_via_sso":false,"log_type":"account","traits":{"provider":"email"}}	2025-06-23 07:55:39.190156+00	
00000000-0000-0000-0000-000000000000	9da09a51-5f2d-4db9-8a46-7acaa0b1ca96	{"action":"login","actor_id":"0d12ddb0-122b-46a3-afba-c35c8640e887","actor_username":"simleongeng@yahoo.com","actor_via_sso":false,"log_type":"account","traits":{"provider":"email"}}	2025-06-23 07:56:04.737239+00	
00000000-0000-0000-0000-000000000000	298274e4-31d5-4a2c-9579-84e1b00c5899	{"action":"user_signedup","actor_id":"60dea06c-f874-48fb-80ce-b71d2e65ba95","actor_username":"bpomsamling@gmail.com","actor_via_sso":false,"log_type":"team","traits":{"provider":"email"}}	2025-06-23 07:56:12.659195+00	
00000000-0000-0000-0000-000000000000	f90c7818-2def-424f-ab26-411377f313ff	{"action":"login","actor_id":"60dea06c-f874-48fb-80ce-b71d2e65ba95","actor_username":"bpomsamling@gmail.com","actor_via_sso":false,"log_type":"account","traits":{"provider":"email"}}	2025-06-23 07:56:12.66438+00	
00000000-0000-0000-0000-000000000000	f5038e97-c0fc-46be-8731-115d4beab1d3	{"action":"login","actor_id":"2186e85a-0204-40d2-ac5a-1ae7600edfa3","actor_username":"risnid@salcra.gov.my","actor_via_sso":false,"log_type":"account","traits":{"provider":"email"}}	2025-06-23 07:56:17.967085+00	
00000000-0000-0000-0000-000000000000	3a5efa4c-4703-4b26-95c8-9e0db4b56ccb	{"action":"login","actor_id":"6c383e4a-a52d-4661-8a6c-4be47b0ed340","actor_username":"eyz71@yahoo.com","actor_via_sso":false,"log_type":"account","traits":{"provider":"email"}}	2025-06-23 07:56:55.010601+00	
00000000-0000-0000-0000-000000000000	3aa69c08-7d7e-4ffb-b2a2-d13db6bf9c73	{"action":"login","actor_id":"a4051467-1969-4a0f-8657-d8f3f0ba6359","actor_username":"dienstainkemiti@gmail.com","actor_via_sso":false,"log_type":"account","traits":{"provider":"email"}}	2025-06-23 07:57:16.064497+00	
00000000-0000-0000-0000-000000000000	6b4aa443-ec57-4fc5-bdd1-5ce33400fe86	{"action":"logout","actor_id":"c3a67ce5-0445-4f78-8259-c115bc188a26","actor_username":"tingpikhieng@gmail.com","actor_via_sso":false,"log_type":"account"}	2025-06-23 07:57:36.743053+00	
00000000-0000-0000-0000-000000000000	ac0cca14-b4db-47d2-af11-3debf2e221b3	{"action":"login","actor_id":"60dea06c-f874-48fb-80ce-b71d2e65ba95","actor_username":"bpomsamling@gmail.com","actor_via_sso":false,"log_type":"account","traits":{"provider":"email"}}	2025-06-23 07:57:58.740133+00	
00000000-0000-0000-0000-000000000000	09567d82-ba14-4602-addf-f7f611b3ac54	{"action":"login","actor_id":"ee74b89d-137d-470c-8a00-90fb5a372727","actor_username":"wifredk@salcra.gov.my","actor_via_sso":false,"log_type":"account","traits":{"provider":"email"}}	2025-06-23 07:58:31.485573+00	
00000000-0000-0000-0000-000000000000	7fca2780-c64a-41b8-bc65-47e683512f0a	{"action":"login","actor_id":"47676bae-55c6-48f5-8b6a-dc0a3af02ec4","actor_username":"diana.do@keresa.com.my","actor_via_sso":false,"log_type":"account","traits":{"provider":"email"}}	2025-06-23 08:00:50.525821+00	
00000000-0000-0000-0000-000000000000	5e94cb03-2639-46ec-bfcc-e9b1e82bdb4a	{"action":"login","actor_id":"7d693d50-00d4-4a9b-9bc0-35afebbb30d9","actor_username":"richardting@spbgroup.com.my","actor_via_sso":false,"log_type":"account","traits":{"provider":"email"}}	2025-06-23 08:04:20.273127+00	
00000000-0000-0000-0000-000000000000	3d69d32c-fd45-4afe-ad2c-b6d86f0270af	{"action":"token_refreshed","actor_id":"60dea06c-f874-48fb-80ce-b71d2e65ba95","actor_username":"bpomsamling@gmail.com","actor_via_sso":false,"log_type":"token"}	2025-06-23 08:54:33.201332+00	
00000000-0000-0000-0000-000000000000	dacab1a8-7274-4aec-84bf-0d13d43bfeaa	{"action":"token_revoked","actor_id":"60dea06c-f874-48fb-80ce-b71d2e65ba95","actor_username":"bpomsamling@gmail.com","actor_via_sso":false,"log_type":"token"}	2025-06-23 08:54:33.201825+00	
00000000-0000-0000-0000-000000000000	5b70bbf1-4dbd-4161-83b6-df39e7c6d5b9	{"action":"token_refreshed","actor_id":"8bc44ea0-2e33-458a-ac4d-298980c44b05","actor_username":"christabelle.winona@tsggroup.my","actor_via_sso":false,"log_type":"token"}	2025-06-23 13:37:10.612314+00	
00000000-0000-0000-0000-000000000000	19ec8944-4601-4c7c-86bd-8c6b63cf3ec8	{"action":"token_revoked","actor_id":"8bc44ea0-2e33-458a-ac4d-298980c44b05","actor_username":"christabelle.winona@tsggroup.my","actor_via_sso":false,"log_type":"token"}	2025-06-23 13:37:10.612811+00	
00000000-0000-0000-0000-000000000000	92945228-8b0d-4e99-8c1b-6a2dd240bfb6	{"action":"token_refreshed","actor_id":"7df7ea94-16ba-4fd6-85bc-4fd0155fe284","actor_username":"soon.masranti@gmail.com","actor_via_sso":false,"log_type":"token"}	2025-06-24 00:06:54.590545+00	
00000000-0000-0000-0000-000000000000	8bac5eaa-7136-41aa-afa7-7a728727f528	{"action":"token_revoked","actor_id":"7df7ea94-16ba-4fd6-85bc-4fd0155fe284","actor_username":"soon.masranti@gmail.com","actor_via_sso":false,"log_type":"token"}	2025-06-24 00:06:54.590983+00	
00000000-0000-0000-0000-000000000000	2f1d46fd-4925-4cb8-a4e9-9e7567d21a38	{"action":"token_refreshed","actor_id":"4e579a51-bb42-45f1-9b79-b84928a98421","actor_username":"kaveeraaz@gmail.com","actor_via_sso":false,"log_type":"token"}	2025-06-24 01:15:17.520221+00	
00000000-0000-0000-0000-000000000000	d8ce70e5-8177-4cf5-843b-ce96333f9613	{"action":"token_revoked","actor_id":"4e579a51-bb42-45f1-9b79-b84928a98421","actor_username":"kaveeraaz@gmail.com","actor_via_sso":false,"log_type":"token"}	2025-06-24 01:15:17.520646+00	
00000000-0000-0000-0000-000000000000	c84b5411-e7a1-48fb-92a5-9929ca786c4f	{"action":"token_refreshed","actor_id":"7df7ea94-16ba-4fd6-85bc-4fd0155fe284","actor_username":"soon.masranti@gmail.com","actor_via_sso":false,"log_type":"token"}	2025-06-24 02:31:07.915454+00	
00000000-0000-0000-0000-000000000000	5ed5ae13-69ce-45e2-bc0b-4f64c4034f9e	{"action":"token_revoked","actor_id":"7df7ea94-16ba-4fd6-85bc-4fd0155fe284","actor_username":"soon.masranti@gmail.com","actor_via_sso":false,"log_type":"token"}	2025-06-24 02:31:07.915917+00	
00000000-0000-0000-0000-000000000000	1370d0b5-22ef-410d-afc3-7b7ac2db9cee	{"action":"token_refreshed","actor_id":"4e579a51-bb42-45f1-9b79-b84928a98421","actor_username":"kaveeraaz@gmail.com","actor_via_sso":false,"log_type":"token"}	2025-06-25 12:56:43.765549+00	
00000000-0000-0000-0000-000000000000	ca8b7198-44a3-4d1f-b497-f1edbed40055	{"action":"token_revoked","actor_id":"4e579a51-bb42-45f1-9b79-b84928a98421","actor_username":"kaveeraaz@gmail.com","actor_via_sso":false,"log_type":"token"}	2025-06-25 12:56:43.765962+00	
00000000-0000-0000-0000-000000000000	66ab44e1-d70f-4369-a90a-fcf04f7536f9	{"action":"login","actor_id":"0955eea6-fdc3-48b6-beca-f30e05cfe912","actor_username":"hazwan@mspo.org.my","actor_via_sso":false,"log_type":"account","traits":{"provider":"email"}}	2025-06-27 02:18:09.993564+00	
00000000-0000-0000-0000-000000000000	2a783c1f-8796-4a6f-b578-1433b413de0a	{"action":"logout","actor_id":"0955eea6-fdc3-48b6-beca-f30e05cfe912","actor_username":"hazwan@mspo.org.my","actor_via_sso":false,"log_type":"account"}	2025-06-27 02:18:14.402736+00	
00000000-0000-0000-0000-000000000000	d23ba74c-5fcf-4e65-82eb-ac88f582ef87	{"action":"user_signedup","actor_id":"6d810e53-112a-4eac-a882-25b1e97a42b8","actor_username":"pptz_hilirperak1@yopmail.com","actor_via_sso":false,"log_type":"team","traits":{"provider":"email"}}	2025-06-27 04:21:39.272952+00	
00000000-0000-0000-0000-000000000000	715ca9ad-624a-408b-b7c2-164c9a4e2918	{"action":"login","actor_id":"6d810e53-112a-4eac-a882-25b1e97a42b8","actor_username":"pptz_hilirperak1@yopmail.com","actor_via_sso":false,"log_type":"account","traits":{"provider":"email"}}	2025-06-27 04:21:39.274994+00	
00000000-0000-0000-0000-000000000000	e6c4029e-8f94-41ec-a1c5-b8b063b7c38d	{"action":"login","actor_id":"6d810e53-112a-4eac-a882-25b1e97a42b8","actor_username":"pptz_hilirperak1@yopmail.com","actor_via_sso":false,"log_type":"account","traits":{"provider":"email"}}	2025-06-27 04:22:56.396648+00	
00000000-0000-0000-0000-000000000000	fd902447-f497-473e-ad53-1dce4aad73fc	{"action":"login","actor_id":"6d810e53-112a-4eac-a882-25b1e97a42b8","actor_username":"pptz_hilirperak1@yopmail.com","actor_via_sso":false,"log_type":"account","traits":{"provider":"email"}}	2025-06-27 05:06:33.778584+00	
00000000-0000-0000-0000-000000000000	0201206a-1807-49e1-bb5e-f486301aeb63	{"action":"login","actor_id":"6d810e53-112a-4eac-a882-25b1e97a42b8","actor_username":"pptz_hilirperak1@yopmail.com","actor_via_sso":false,"log_type":"account","traits":{"provider":"email"}}	2025-06-27 05:10:06.542825+00	
00000000-0000-0000-0000-000000000000	213d0e2f-e4b8-473e-aa0c-5990beb9f983	{"action":"token_refreshed","actor_id":"6d810e53-112a-4eac-a882-25b1e97a42b8","actor_username":"pptz_hilirperak1@yopmail.com","actor_via_sso":false,"log_type":"token"}	2025-06-27 06:45:29.115693+00	
00000000-0000-0000-0000-000000000000	6934278d-f391-4485-9c6d-cdeacbee51fb	{"action":"token_revoked","actor_id":"6d810e53-112a-4eac-a882-25b1e97a42b8","actor_username":"pptz_hilirperak1@yopmail.com","actor_via_sso":false,"log_type":"token"}	2025-06-27 06:45:29.116112+00	
00000000-0000-0000-0000-000000000000	45033a37-ed5c-4478-b0ee-35d73e36a540	{"action":"login","actor_id":"0955eea6-fdc3-48b6-beca-f30e05cfe912","actor_username":"hazwan@mspo.org.my","actor_via_sso":false,"log_type":"account","traits":{"provider":"email"}}	2025-06-27 07:06:12.850856+00	
00000000-0000-0000-0000-000000000000	dc690990-c7ad-416e-a094-c66833b00858	{"action":"login","actor_id":"0955eea6-fdc3-48b6-beca-f30e05cfe912","actor_username":"hazwan@mspo.org.my","actor_via_sso":false,"log_type":"account","traits":{"provider":"email"}}	2025-06-27 07:21:44.688492+00	
00000000-0000-0000-0000-000000000000	c5567078-56ef-409e-878b-3a100554666a	{"action":"logout","actor_id":"0955eea6-fdc3-48b6-beca-f30e05cfe912","actor_username":"hazwan@mspo.org.my","actor_via_sso":false,"log_type":"account"}	2025-06-27 07:37:35.555668+00	
00000000-0000-0000-0000-000000000000	3184fe00-96b0-4c92-83d4-3fe8af9e3787	{"action":"login","actor_id":"6d810e53-112a-4eac-a882-25b1e97a42b8","actor_username":"pptz_hilirperak1@yopmail.com","actor_via_sso":false,"log_type":"account","traits":{"provider":"email"}}	2025-06-27 07:37:42.821944+00	
00000000-0000-0000-0000-000000000000	d0277286-1666-4003-8c95-96fb5dd3ac6f	{"action":"logout","actor_id":"6d810e53-112a-4eac-a882-25b1e97a42b8","actor_username":"pptz_hilirperak1@yopmail.com","actor_via_sso":false,"log_type":"account"}	2025-06-27 07:49:33.168252+00	
00000000-0000-0000-0000-000000000000	6fa88d6e-a829-4fc4-a4ba-03aad8fdb974	{"action":"login","actor_id":"0955eea6-fdc3-48b6-beca-f30e05cfe912","actor_username":"hazwan@mspo.org.my","actor_via_sso":false,"log_type":"account","traits":{"provider":"email"}}	2025-06-27 07:49:45.053209+00	
00000000-0000-0000-0000-000000000000	947e9681-e34c-4689-9d51-e661cd224438	{"action":"login","actor_id":"0955eea6-fdc3-48b6-beca-f30e05cfe912","actor_username":"hazwan@mspo.org.my","actor_via_sso":false,"log_type":"account","traits":{"provider":"email"}}	2025-06-27 07:51:37.259284+00	
00000000-0000-0000-0000-000000000000	52980cce-cdf4-4d30-b46c-56ceff32f8bd	{"action":"logout","actor_id":"0955eea6-fdc3-48b6-beca-f30e05cfe912","actor_username":"hazwan@mspo.org.my","actor_via_sso":false,"log_type":"account"}	2025-06-27 08:02:22.567234+00	
00000000-0000-0000-0000-000000000000	a9c96491-28a8-4690-8137-0ebabc371249	{"action":"user_signedup","actor_id":"545c44d3-4d8a-4511-8fc5-4aaf6e8de7b9","actor_username":"complainant_mspo1@yopmail.com","actor_via_sso":false,"log_type":"team","traits":{"provider":"email"}}	2025-06-27 08:03:58.309854+00	
00000000-0000-0000-0000-000000000000	5a80e092-6f01-41bf-b3ed-283775bba1a5	{"action":"login","actor_id":"545c44d3-4d8a-4511-8fc5-4aaf6e8de7b9","actor_username":"complainant_mspo1@yopmail.com","actor_via_sso":false,"log_type":"account","traits":{"provider":"email"}}	2025-06-27 08:03:58.311825+00	
00000000-0000-0000-0000-000000000000	654683df-997f-425b-937d-2a4debe63616	{"action":"login","actor_id":"545c44d3-4d8a-4511-8fc5-4aaf6e8de7b9","actor_username":"complainant_mspo1@yopmail.com","actor_via_sso":false,"log_type":"account","traits":{"provider":"email"}}	2025-06-27 08:04:55.173554+00	
00000000-0000-0000-0000-000000000000	43b91ee1-8e1f-4310-ad97-319ee6277c78	{"action":"logout","actor_id":"545c44d3-4d8a-4511-8fc5-4aaf6e8de7b9","actor_username":"complainant_mspo1@yopmail.com","actor_via_sso":false,"log_type":"account"}	2025-06-27 08:07:18.59286+00	
00000000-0000-0000-0000-000000000000	007b7600-046e-48ed-843a-5499158b924b	{"action":"user_signedup","actor_id":"f1b6d4f2-174f-4b2a-8c6c-d4531b128bfc","actor_username":"complainant_mspo2@yopmail.com","actor_via_sso":false,"log_type":"team","traits":{"provider":"email"}}	2025-06-27 08:18:52.558865+00	
00000000-0000-0000-0000-000000000000	39cc22b1-9d22-45cc-aea4-b849f9073019	{"action":"login","actor_id":"f1b6d4f2-174f-4b2a-8c6c-d4531b128bfc","actor_username":"complainant_mspo2@yopmail.com","actor_via_sso":false,"log_type":"account","traits":{"provider":"email"}}	2025-06-27 08:18:52.560935+00	
00000000-0000-0000-0000-000000000000	7974130c-0bd7-4e91-a4d3-1d712861e0d3	{"action":"user_signedup","actor_id":"1dd6c4fe-a762-41d0-a940-959280c0e92a","actor_username":"complainant_mspo3@yopmail.com","actor_via_sso":false,"log_type":"team","traits":{"provider":"email"}}	2025-06-27 08:23:21.550179+00	
00000000-0000-0000-0000-000000000000	0ff57ed1-a0ce-4bec-a533-4b9d6bf4e5d1	{"action":"login","actor_id":"1dd6c4fe-a762-41d0-a940-959280c0e92a","actor_username":"complainant_mspo3@yopmail.com","actor_via_sso":false,"log_type":"account","traits":{"provider":"email"}}	2025-06-27 08:23:21.552078+00	
00000000-0000-0000-0000-000000000000	923c2b71-6f2b-4088-96a9-bd509b58ac71	{"action":"login","actor_id":"1dd6c4fe-a762-41d0-a940-959280c0e92a","actor_username":"complainant_mspo3@yopmail.com","actor_via_sso":false,"log_type":"account","traits":{"provider":"email"}}	2025-06-27 08:23:30.639882+00	
00000000-0000-0000-0000-000000000000	51037367-ca19-4b27-a71e-77d762ff1aaf	{"action":"logout","actor_id":"1dd6c4fe-a762-41d0-a940-959280c0e92a","actor_username":"complainant_mspo3@yopmail.com","actor_via_sso":false,"log_type":"account"}	2025-06-27 08:23:46.148936+00	
00000000-0000-0000-0000-000000000000	c9c18bd1-5485-426f-aa66-dbc933cd37fe	{"action":"user_signedup","actor_id":"73bc6611-cc9d-451f-94f4-855016beb48e","actor_username":"cng_elia@yopmail.com","actor_via_sso":false,"log_type":"team","traits":{"provider":"email"}}	2025-06-27 10:54:00.411489+00	
00000000-0000-0000-0000-000000000000	85e82553-66cd-4dec-aa99-149296c3013b	{"action":"login","actor_id":"73bc6611-cc9d-451f-94f4-855016beb48e","actor_username":"cng_elia@yopmail.com","actor_via_sso":false,"log_type":"account","traits":{"provider":"email"}}	2025-06-27 10:54:00.413353+00	
00000000-0000-0000-0000-000000000000	a7e63f55-8256-4592-a34e-24c2f2d1e9a7	{"action":"login","actor_id":"73bc6611-cc9d-451f-94f4-855016beb48e","actor_username":"cng_elia@yopmail.com","actor_via_sso":false,"log_type":"account","traits":{"provider":"email"}}	2025-06-27 10:54:18.485768+00	
00000000-0000-0000-0000-000000000000	9825d0aa-2063-4c74-859f-cec179eae153	{"action":"login","actor_id":"73bc6611-cc9d-451f-94f4-855016beb48e","actor_username":"cng_elia@yopmail.com","actor_via_sso":false,"log_type":"account","traits":{"provider":"email"}}	2025-06-27 10:59:44.305395+00	
00000000-0000-0000-0000-000000000000	d444883c-0a5e-4be0-ae69-b78d09447f5a	{"action":"login","actor_id":"73bc6611-cc9d-451f-94f4-855016beb48e","actor_username":"cng_elia@yopmail.com","actor_via_sso":false,"log_type":"account","traits":{"provider":"email"}}	2025-06-27 11:26:45.672635+00	
00000000-0000-0000-0000-000000000000	849c570d-12f5-4739-9b1d-964863880461	{"action":"login","actor_id":"73bc6611-cc9d-451f-94f4-855016beb48e","actor_username":"cng_elia@yopmail.com","actor_via_sso":false,"log_type":"account","traits":{"provider":"email"}}	2025-06-27 13:54:21.148777+00	
00000000-0000-0000-0000-000000000000	45879204-8d6d-448c-9c25-8fffba8aedfe	{"action":"login","actor_id":"73bc6611-cc9d-451f-94f4-855016beb48e","actor_username":"cng_elia@yopmail.com","actor_via_sso":false,"log_type":"account","traits":{"provider":"email"}}	2025-06-27 13:56:27.465943+00	
00000000-0000-0000-0000-000000000000	6e82599e-8c23-4a84-b3a6-09218e79e3eb	{"action":"login","actor_id":"0955eea6-fdc3-48b6-beca-f30e05cfe912","actor_username":"hazwan@mspo.org.my","actor_via_sso":false,"log_type":"account","traits":{"provider":"email"}}	2025-06-27 14:20:23.543641+00	
00000000-0000-0000-0000-000000000000	7e420ce2-7e9a-4ab9-9583-4fad17d5f5d9	{"action":"login","actor_id":"0955eea6-fdc3-48b6-beca-f30e05cfe912","actor_username":"hazwan@mspo.org.my","actor_via_sso":false,"log_type":"account","traits":{"provider":"email"}}	2025-06-27 14:37:01.412198+00	
00000000-0000-0000-0000-000000000000	6d844f37-adaa-4696-9c24-70e21b575743	{"action":"login","actor_id":"73bc6611-cc9d-451f-94f4-855016beb48e","actor_username":"cng_elia@yopmail.com","actor_via_sso":false,"log_type":"account","traits":{"provider":"email"}}	2025-06-27 14:49:16.142694+00	
00000000-0000-0000-0000-000000000000	4cffe066-da1f-4360-8526-4e96cd2d5ba5	{"action":"user_signedup","actor_id":"fcc7d82b-864c-43db-9975-ff689875c391","actor_username":"adindos@yopmail.com","actor_via_sso":false,"log_type":"team","traits":{"provider":"email"}}	2025-06-29 06:57:01.837995+00	
00000000-0000-0000-0000-000000000000	9d2aaa9d-43e7-42fa-94ff-08f960099247	{"action":"login","actor_id":"fcc7d82b-864c-43db-9975-ff689875c391","actor_username":"adindos@yopmail.com","actor_via_sso":false,"log_type":"account","traits":{"provider":"email"}}	2025-06-29 06:57:01.856797+00	
00000000-0000-0000-0000-000000000000	e3b1b69d-951f-4e02-a60a-5bb71e4d2536	{"action":"login","actor_id":"fcc7d82b-864c-43db-9975-ff689875c391","actor_username":"adindos@yopmail.com","actor_via_sso":false,"log_type":"account","traits":{"provider":"email"}}	2025-06-29 06:57:20.604127+00	
00000000-0000-0000-0000-000000000000	8d2190f5-1275-4c4e-b81e-df3851baed83	{"action":"token_refreshed","actor_id":"fcc7d82b-864c-43db-9975-ff689875c391","actor_username":"adindos@yopmail.com","actor_via_sso":false,"log_type":"token"}	2025-06-29 07:55:17.020666+00	
00000000-0000-0000-0000-000000000000	491f186a-2786-48d4-be98-8ca3d13ed5c9	{"action":"token_revoked","actor_id":"fcc7d82b-864c-43db-9975-ff689875c391","actor_username":"adindos@yopmail.com","actor_via_sso":false,"log_type":"token"}	2025-06-29 07:55:17.021071+00	
00000000-0000-0000-0000-000000000000	a4fffa38-97c3-4c15-b704-c9743ba5bfbf	{"action":"token_refreshed","actor_id":"fcc7d82b-864c-43db-9975-ff689875c391","actor_username":"adindos@yopmail.com","actor_via_sso":false,"log_type":"token"}	2025-06-29 08:53:19.223457+00	
00000000-0000-0000-0000-000000000000	cef083e2-7cd1-436b-bb16-863a88a0df76	{"action":"token_revoked","actor_id":"fcc7d82b-864c-43db-9975-ff689875c391","actor_username":"adindos@yopmail.com","actor_via_sso":false,"log_type":"token"}	2025-06-29 08:53:19.223931+00	
00000000-0000-0000-0000-000000000000	4bc87445-d210-484a-a538-e00a5f0a51b6	{"action":"token_refreshed","actor_id":"fcc7d82b-864c-43db-9975-ff689875c391","actor_username":"adindos@yopmail.com","actor_via_sso":false,"log_type":"token"}	2025-06-29 09:51:22.378626+00	
00000000-0000-0000-0000-000000000000	8e19d7da-4c06-4d59-ac61-14fd4304cd50	{"action":"token_revoked","actor_id":"fcc7d82b-864c-43db-9975-ff689875c391","actor_username":"adindos@yopmail.com","actor_via_sso":false,"log_type":"token"}	2025-06-29 09:51:22.379169+00	
00000000-0000-0000-0000-000000000000	a1a19b0a-2d27-4db5-9495-714b0089798b	{"action":"token_refreshed","actor_id":"fcc7d82b-864c-43db-9975-ff689875c391","actor_username":"adindos@yopmail.com","actor_via_sso":false,"log_type":"token"}	2025-06-29 10:49:25.397489+00	
00000000-0000-0000-0000-000000000000	e1dd29e8-cb44-44a9-94e1-f7ddf027895e	{"action":"token_revoked","actor_id":"fcc7d82b-864c-43db-9975-ff689875c391","actor_username":"adindos@yopmail.com","actor_via_sso":false,"log_type":"token"}	2025-06-29 10:49:25.397916+00	
00000000-0000-0000-0000-000000000000	2f782019-41c0-4997-81f2-9de15ff3d0f2	{"action":"token_refreshed","actor_id":"fcc7d82b-864c-43db-9975-ff689875c391","actor_username":"adindos@yopmail.com","actor_via_sso":false,"log_type":"token"}	2025-06-29 11:01:05.77356+00	
00000000-0000-0000-0000-000000000000	778b78e0-47c0-43ff-8faf-b2c7a90e314d	{"action":"token_revoked","actor_id":"fcc7d82b-864c-43db-9975-ff689875c391","actor_username":"adindos@yopmail.com","actor_via_sso":false,"log_type":"token"}	2025-06-29 11:01:05.773996+00	
00000000-0000-0000-0000-000000000000	07d31cec-1ab8-4f64-89a6-2676ba5ee9f9	{"action":"token_refreshed","actor_id":"fcc7d82b-864c-43db-9975-ff689875c391","actor_username":"adindos@yopmail.com","actor_via_sso":false,"log_type":"token"}	2025-06-29 11:47:26.297436+00	
00000000-0000-0000-0000-000000000000	799678d7-38ba-4b2d-a938-a46e77c92feb	{"action":"token_revoked","actor_id":"fcc7d82b-864c-43db-9975-ff689875c391","actor_username":"adindos@yopmail.com","actor_via_sso":false,"log_type":"token"}	2025-06-29 11:47:26.297882+00	
00000000-0000-0000-0000-000000000000	de09309e-5252-4361-83fa-660681c15f13	{"action":"token_refreshed","actor_id":"fcc7d82b-864c-43db-9975-ff689875c391","actor_username":"adindos@yopmail.com","actor_via_sso":false,"log_type":"token"}	2025-06-29 12:45:27.848036+00	
00000000-0000-0000-0000-000000000000	6bb1f251-6fb8-4bbc-a093-ac07e62b15ff	{"action":"token_revoked","actor_id":"fcc7d82b-864c-43db-9975-ff689875c391","actor_username":"adindos@yopmail.com","actor_via_sso":false,"log_type":"token"}	2025-06-29 12:45:27.848456+00	
\.


--
-- Data for Name: flow_state; Type: TABLE DATA; Schema: auth; Owner: -
--

COPY auth.flow_state (id, user_id, auth_code, code_challenge_method, code_challenge, provider_type, provider_access_token, provider_refresh_token, created_at, updated_at, authentication_method, auth_code_issued_at) FROM stdin;
\.


--
-- Data for Name: identities; Type: TABLE DATA; Schema: auth; Owner: -
--

COPY auth.identities (provider_id, user_id, identity_data, provider, last_sign_in_at, created_at, updated_at, id) FROM stdin;
0a293fdd-d64a-4a9e-b46c-fad7f2175e01	0a293fdd-d64a-4a9e-b46c-fad7f2175e01	{"sub": "0a293fdd-d64a-4a9e-b46c-fad7f2175e01", "email": "marz@marzex.tech", "email_verified": false, "phone_verified": false}	email	2025-02-18 18:24:13.491065+00	2025-02-18 18:24:13.491159+00	2025-02-18 18:24:13.491159+00	f08e9a41-f831-4e14-a2cf-fbf58bfeb762
0955eea6-fdc3-48b6-beca-f30e05cfe912	0955eea6-fdc3-48b6-beca-f30e05cfe912	{"sub": "0955eea6-fdc3-48b6-beca-f30e05cfe912", "email": "hazwan@mspo.org.my", "email_verified": false, "phone_verified": false}	email	2025-06-14 18:41:49.692041+00	2025-06-14 18:41:49.692088+00	2025-06-14 18:41:49.692088+00	a13b4e75-cb92-48ed-b94f-039049521795
a007885a-80b3-4486-b31c-6652abca3e12	a007885a-80b3-4486-b31c-6652abca3e12	{"sub": "a007885a-80b3-4486-b31c-6652abca3e12", "email": "firdaus@mspo.org.my", "email_verified": false, "phone_verified": false}	email	2025-06-15 09:36:05.771579+00	2025-06-15 09:36:05.771618+00	2025-06-15 09:36:05.771618+00	77644afe-d0e2-4e81-85a3-8944b7dae795
b7592049-9546-4bd4-9bc7-33d77d747af0	b7592049-9546-4bd4-9bc7-33d77d747af0	{"sub": "b7592049-9546-4bd4-9bc7-33d77d747af0", "email": "hemanathan@airei.com.my", "email_verified": false, "phone_verified": false}	email	2025-06-15 14:38:32.834681+00	2025-06-15 14:38:32.834715+00	2025-06-15 14:38:32.834715+00	5a4bd228-6c5e-480c-ac8e-0bbee2174c78
663cd7e5-73f0-4c16-b7a8-a579107fda69	663cd7e5-73f0-4c16-b7a8-a579107fda69	{"sub": "663cd7e5-73f0-4c16-b7a8-a579107fda69", "email": "k@gmail.com", "email_verified": false, "phone_verified": false}	email	2025-06-15 14:38:32.938644+00	2025-06-15 14:38:32.938679+00	2025-06-15 14:38:32.938679+00	dda430ab-c8fc-48cb-8af6-30a7b3e467d7
081efe3b-09b5-4e34-9194-cbcb30cc77d9	081efe3b-09b5-4e34-9194-cbcb30cc77d9	{"sub": "081efe3b-09b5-4e34-9194-cbcb30cc77d9", "email": "kamarulsipi.mohd@gmail.com", "email_verified": false, "phone_verified": false}	email	2025-06-15 14:38:33.036132+00	2025-06-15 14:38:33.036176+00	2025-06-15 14:38:33.036176+00	d5173049-e36d-4e5b-aa78-54e8bba6ec2c
5de03212-53a6-465c-857b-34e113374e81	5de03212-53a6-465c-857b-34e113374e81	{"sub": "5de03212-53a6-465c-857b-34e113374e81", "email": "kamarul.sipi@airei.com.my", "email_verified": false, "phone_verified": false}	email	2025-06-15 14:38:33.130917+00	2025-06-15 14:38:33.130954+00	2025-06-15 14:38:33.130954+00	be15a121-6353-4dbd-9d99-c09105d21e06
1207343f-7e2b-4f82-88ed-7b559f837c08	1207343f-7e2b-4f82-88ed-7b559f837c08	{"sub": "1207343f-7e2b-4f82-88ed-7b559f837c08", "email": "hemanarhan@airei.com.my", "email_verified": false, "phone_verified": false}	email	2025-06-15 14:38:33.236027+00	2025-06-15 14:38:33.236064+00	2025-06-15 14:38:33.236064+00	e132158c-5747-479d-b58f-6ddf3d67e53a
884b5358-cd7d-4b03-84af-fde5a996ac76	884b5358-cd7d-4b03-84af-fde5a996ac76	{"sub": "884b5358-cd7d-4b03-84af-fde5a996ac76", "email": "s@gmail.com", "email_verified": false, "phone_verified": false}	email	2025-06-15 14:38:33.331963+00	2025-06-15 14:38:33.331999+00	2025-06-15 14:38:33.331999+00	b03e3406-a767-4f1e-b1f9-6c6301b1d488
9c533f9b-0de2-4184-8679-ac4124139717	9c533f9b-0de2-4184-8679-ac4124139717	{"sub": "9c533f9b-0de2-4184-8679-ac4124139717", "email": "kamaroyamatha@gmail.com", "email_verified": false, "phone_verified": false}	email	2025-06-15 14:38:33.428189+00	2025-06-15 14:38:33.428227+00	2025-06-15 14:38:33.428227+00	30e49684-e4a0-4cdf-abb4-a1a3f027f960
46f9cd41-b08e-4e32-81eb-bb1d3323b3b2	46f9cd41-b08e-4e32-81eb-bb1d3323b3b2	{"sub": "46f9cd41-b08e-4e32-81eb-bb1d3323b3b2", "email": "nasiha@mpocc.org.my", "email_verified": false, "phone_verified": false}	email	2025-06-15 14:38:33.532799+00	2025-06-15 14:38:33.532837+00	2025-06-15 14:38:33.532837+00	3307cb02-6931-4101-b728-c435490c60d7
4d6dc0fa-8a2f-4073-9bbd-85425124beb0	4d6dc0fa-8a2f-4073-9bbd-85425124beb0	{"sub": "4d6dc0fa-8a2f-4073-9bbd-85425124beb0", "email": "leo_gee87@yahoo.com", "email_verified": false, "phone_verified": false}	email	2025-06-15 14:38:33.644146+00	2025-06-15 14:38:33.64418+00	2025-06-15 14:38:33.64418+00	69f8d595-7182-4422-97a9-0d9c47cf7074
e81e22aa-0578-4fb2-8d0b-5665be08b8ee	e81e22aa-0578-4fb2-8d0b-5665be08b8ee	{"sub": "e81e22aa-0578-4fb2-8d0b-5665be08b8ee", "email": "janechinshuikwen@gmail.com", "email_verified": false, "phone_verified": false}	email	2025-06-15 14:38:33.746539+00	2025-06-15 14:38:33.746578+00	2025-06-15 14:38:33.746578+00	0ce64b83-c753-4927-ae47-582053a6ac70
bf3f6921-ab2d-4b8b-936f-38da5143c31d	bf3f6921-ab2d-4b8b-936f-38da5143c31d	{"sub": "bf3f6921-ab2d-4b8b-936f-38da5143c31d", "email": "rusnanit78@gmail.com", "email_verified": false, "phone_verified": false}	email	2025-06-15 14:38:33.838361+00	2025-06-15 14:38:33.838412+00	2025-06-15 14:38:33.838412+00	42972ec7-0a12-403b-b7e6-c6fa36ed675a
3d06ba74-5af0-499d-81fa-6a61febaa57d	3d06ba74-5af0-499d-81fa-6a61febaa57d	{"sub": "3d06ba74-5af0-499d-81fa-6a61febaa57d", "email": "nuramsconsultant@gmail.com", "email_verified": false, "phone_verified": false}	email	2025-06-15 14:38:33.932655+00	2025-06-15 14:38:33.932701+00	2025-06-15 14:38:33.932701+00	67b749c8-00d5-465d-8723-d2ee13655120
d0e4fb36-fb0a-4767-a333-531cbb37e035	d0e4fb36-fb0a-4767-a333-531cbb37e035	{"sub": "d0e4fb36-fb0a-4767-a333-531cbb37e035", "email": "sriganda2003@gmail.com", "email_verified": false, "phone_verified": false}	email	2025-06-15 14:38:34.026128+00	2025-06-15 14:38:34.026167+00	2025-06-15 14:38:34.026167+00	48853a55-524f-4799-a75d-1e85cb015103
cedde969-4985-499b-a05c-5325099bf7aa	cedde969-4985-499b-a05c-5325099bf7aa	{"sub": "cedde969-4985-499b-a05c-5325099bf7aa", "email": "goldenelate.pom@gmail.com", "email_verified": false, "phone_verified": false}	email	2025-06-15 14:38:34.119173+00	2025-06-15 14:38:34.119223+00	2025-06-15 14:38:34.119223+00	611a8348-b6f8-4b95-9c36-cf982989133f
13b7d6b3-42a7-40ec-b227-f1b91f791dcc	13b7d6b3-42a7-40ec-b227-f1b91f791dcc	{"sub": "13b7d6b3-42a7-40ec-b227-f1b91f791dcc", "email": "amirul@kksl.com.my", "email_verified": false, "phone_verified": false}	email	2025-06-15 14:38:34.227417+00	2025-06-15 14:38:34.227454+00	2025-06-15 14:38:34.227454+00	b699c5df-ca8a-41c6-ae93-07b07bc58836
4287988f-93ab-4a3c-9790-77473ef7f799	4287988f-93ab-4a3c-9790-77473ef7f799	{"sub": "4287988f-93ab-4a3c-9790-77473ef7f799", "email": "ephremryanalphonsus@gmail.com", "email_verified": false, "phone_verified": false}	email	2025-06-15 14:38:34.327848+00	2025-06-15 14:38:34.327887+00	2025-06-15 14:38:34.327887+00	f16b025b-1be6-471a-ba15-db1f12f92b7b
12c58e57-7eb9-4e61-a298-52c44ab6e5e2	12c58e57-7eb9-4e61-a298-52c44ab6e5e2	{"sub": "12c58e57-7eb9-4e61-a298-52c44ab6e5e2", "email": "chongchungwai@icloud.com", "email_verified": false, "phone_verified": false}	email	2025-06-15 14:38:34.419108+00	2025-06-15 14:38:34.419162+00	2025-06-15 14:38:34.419162+00	0c3501d7-1e26-4d12-9c8c-06090f777e2b
f36f7e40-f5fb-4c87-a096-a88c211d6bd2	f36f7e40-f5fb-4c87-a096-a88c211d6bd2	{"sub": "f36f7e40-f5fb-4c87-a096-a88c211d6bd2", "email": "n.hazirahismail@gmail.com", "email_verified": false, "phone_verified": false}	email	2025-06-15 14:38:34.521799+00	2025-06-15 14:38:34.521833+00	2025-06-15 14:38:34.521833+00	5b237920-948d-47a3-bfbe-60d49b8d38b1
812c46f2-6962-4df8-90c0-f5dee109c540	812c46f2-6962-4df8-90c0-f5dee109c540	{"sub": "812c46f2-6962-4df8-90c0-f5dee109c540", "email": "varmavarma186@gmail.com", "email_verified": false, "phone_verified": false}	email	2025-06-15 14:38:34.61537+00	2025-06-15 14:38:34.615423+00	2025-06-15 14:38:34.615423+00	7d48a525-134c-48e5-8938-ddaf14006456
a54f43bc-3510-4267-9c02-de241f28979b	a54f43bc-3510-4267-9c02-de241f28979b	{"sub": "a54f43bc-3510-4267-9c02-de241f28979b", "email": "foemalaysia@gmail.com", "email_verified": false, "phone_verified": false}	email	2025-06-15 14:38:34.735875+00	2025-06-15 14:38:34.735937+00	2025-06-15 14:38:34.735937+00	42e54c92-190b-4408-9598-1f4b0d9f71e8
ded6488b-469e-484e-b815-a00534d3e10f	ded6488b-469e-484e-b815-a00534d3e10f	{"sub": "ded6488b-469e-484e-b815-a00534d3e10f", "email": "ameer.h@fgvholdings.com", "email_verified": false, "phone_verified": false}	email	2025-06-15 14:38:34.837484+00	2025-06-15 14:38:34.837522+00	2025-06-15 14:38:34.837522+00	e026db0d-1844-4f6f-b479-cc073eda88fa
c0c0c1da-11f3-4065-aa98-82084870eea4	c0c0c1da-11f3-4065-aa98-82084870eea4	{"sub": "c0c0c1da-11f3-4065-aa98-82084870eea4", "email": "aldosualin@gmail.com", "email_verified": false, "phone_verified": false}	email	2025-06-15 14:38:34.931028+00	2025-06-15 14:38:34.931061+00	2025-06-15 14:38:34.931061+00	e4ec5225-240c-4390-8749-2014c25d7a1c
e0cf9d78-629a-4f0c-8c5e-d4eb659c758a	e0cf9d78-629a-4f0c-8c5e-d4eb659c758a	{"sub": "e0cf9d78-629a-4f0c-8c5e-d4eb659c758a", "email": "jamal@ggc.my", "email_verified": false, "phone_verified": false}	email	2025-06-15 14:38:35.018493+00	2025-06-15 14:38:35.018531+00	2025-06-15 14:38:35.018531+00	fc6cb33f-0cf0-4c91-8c0f-2815d84617a9
0f718b43-671c-4b6f-b906-34ee7b45b4b2	0f718b43-671c-4b6f-b906-34ee7b45b4b2	{"sub": "0f718b43-671c-4b6f-b906-34ee7b45b4b2", "email": "thilaganarthan@gmail.com", "email_verified": false, "phone_verified": false}	email	2025-06-15 14:38:35.109249+00	2025-06-15 14:38:35.109477+00	2025-06-15 14:38:35.109477+00	1aecf744-3809-49d9-ad59-17795f23075f
c3430ef8-bea7-4d77-840d-7e1847682f45	c3430ef8-bea7-4d77-840d-7e1847682f45	{"sub": "c3430ef8-bea7-4d77-840d-7e1847682f45", "email": "gmm@ioigroup.com", "email_verified": false, "phone_verified": false}	email	2025-06-15 14:38:35.204636+00	2025-06-15 14:38:35.20471+00	2025-06-15 14:38:35.20471+00	47989f34-d869-4261-94fa-0cfd4c7e9488
0dfa2c7d-310b-4a83-98f5-197421843955	0dfa2c7d-310b-4a83-98f5-197421843955	{"sub": "0dfa2c7d-310b-4a83-98f5-197421843955", "email": "wzynole@gmail.com", "email_verified": false, "phone_verified": false}	email	2025-06-15 14:38:35.305861+00	2025-06-15 14:38:35.305896+00	2025-06-15 14:38:35.305896+00	1085b6f5-e371-4c64-93fd-cf5c6a57650c
b0b2df8d-3835-4d06-a95d-d6a376b95ea1	b0b2df8d-3835-4d06-a95d-d6a376b95ea1	{"sub": "b0b2df8d-3835-4d06-a95d-d6a376b95ea1", "email": "adeline.stefanie.ta@gmail.com", "email_verified": false, "phone_verified": false}	email	2025-06-15 14:38:35.400818+00	2025-06-15 14:38:35.400852+00	2025-06-15 14:38:35.400852+00	eae5d936-02c9-4399-89dc-7d9cb763f35a
1f99b32d-2a96-4760-b450-ed45b0abe4d1	1f99b32d-2a96-4760-b450-ed45b0abe4d1	{"sub": "1f99b32d-2a96-4760-b450-ed45b0abe4d1", "email": "monalizalidom81@gmail.com", "email_verified": false, "phone_verified": false}	email	2025-06-15 14:38:35.500112+00	2025-06-15 14:38:35.500147+00	2025-06-15 14:38:35.500147+00	fef9365b-5dc2-49c5-a676-93a72f74c393
1b9260e9-b2bc-4ac3-86ed-cd13d669bd46	1b9260e9-b2bc-4ac3-86ed-cd13d669bd46	{"sub": "1b9260e9-b2bc-4ac3-86ed-cd13d669bd46", "email": "suryantiselalukecewa@gmail.com", "email_verified": false, "phone_verified": false}	email	2025-06-15 14:38:35.598819+00	2025-06-15 14:38:35.598887+00	2025-06-15 14:38:35.598887+00	06af3ccb-0714-4b8c-9b36-f685bfde0f83
457acf64-4b5a-49a5-8f67-2aa577cec7ec	457acf64-4b5a-49a5-8f67-2aa577cec7ec	{"sub": "457acf64-4b5a-49a5-8f67-2aa577cec7ec", "email": "hazirah@airei.com.my", "email_verified": false, "phone_verified": false}	email	2025-06-15 14:38:35.694673+00	2025-06-15 14:38:35.694708+00	2025-06-15 14:38:35.694708+00	8d4bac7a-98cb-4661-b6bd-44a481db3386
f22bd07e-28a0-4135-b73e-fb6629087485	f22bd07e-28a0-4135-b73e-fb6629087485	{"sub": "f22bd07e-28a0-4135-b73e-fb6629087485", "email": "suburbanpom@gmail.com", "email_verified": false, "phone_verified": false}	email	2025-06-15 14:38:35.789538+00	2025-06-15 14:38:35.78957+00	2025-06-15 14:38:35.78957+00	683e9a62-be64-4538-8328-b994e8d076c7
80708127-7fdf-4c9d-8b6f-315c374c0cf4	80708127-7fdf-4c9d-8b6f-315c374c0cf4	{"sub": "80708127-7fdf-4c9d-8b6f-315c374c0cf4", "email": "kyting@jayatiasa.net", "email_verified": false, "phone_verified": false}	email	2025-06-15 14:38:35.883879+00	2025-06-15 14:38:35.883918+00	2025-06-15 14:38:35.883918+00	46ee3997-9a10-4b4b-a1d4-5b0ee8b31053
536203a3-6335-4c60-ae6f-f852135c5419	536203a3-6335-4c60-ae6f-f852135c5419	{"sub": "536203a3-6335-4c60-ae6f-f852135c5419", "email": "amiratul.aniqah@mpob.gov.my", "email_verified": false, "phone_verified": false}	email	2025-06-15 14:38:35.987502+00	2025-06-15 14:38:35.987538+00	2025-06-15 14:38:35.987538+00	dc48fae6-942c-4044-a587-528a8df7fd4a
4da24124-a1ef-4efe-832d-a89ddfd8945a	4da24124-a1ef-4efe-832d-a89ddfd8945a	{"sub": "4da24124-a1ef-4efe-832d-a89ddfd8945a", "email": "mutuagungmalaysia@gmail.com", "email_verified": false, "phone_verified": false}	email	2025-06-15 14:38:36.083904+00	2025-06-15 14:38:36.083938+00	2025-06-15 14:38:36.083938+00	393a585c-2b34-4586-865a-b5c8cde120d1
3ce70501-e74f-4420-bc0a-3eac51f2dbe4	3ce70501-e74f-4420-bc0a-3eac51f2dbe4	{"sub": "3ce70501-e74f-4420-bc0a-3eac51f2dbe4", "email": "sadiahq@gmail.com", "email_verified": false, "phone_verified": false}	email	2025-06-15 14:38:36.177338+00	2025-06-15 14:38:36.177376+00	2025-06-15 14:38:36.177376+00	98f69dc2-6cbf-4fba-9252-229a2778aa25
d8d76d24-14d4-4e46-92ad-5907d27fe2e0	d8d76d24-14d4-4e46-92ad-5907d27fe2e0	{"sub": "d8d76d24-14d4-4e46-92ad-5907d27fe2e0", "email": "hasronnorraimi@yahoo.com", "email_verified": false, "phone_verified": false}	email	2025-06-15 14:38:36.273074+00	2025-06-15 14:38:36.273134+00	2025-06-15 14:38:36.273134+00	efd45610-df26-4f23-9598-afaa275299ca
e80a6ccf-333b-407f-ae20-ae04ee67f667	e80a6ccf-333b-407f-ae20-ae04ee67f667	{"sub": "e80a6ccf-333b-407f-ae20-ae04ee67f667", "email": "josephjanting@gmail.com", "email_verified": false, "phone_verified": false}	email	2025-06-15 14:38:36.369889+00	2025-06-15 14:38:36.369925+00	2025-06-15 14:38:36.369925+00	7ecaf8c9-b727-48a9-9706-eb58a1fe3b85
7c42038f-aa20-4f20-ba43-839d3474a560	7c42038f-aa20-4f20-ba43-839d3474a560	{"sub": "7c42038f-aa20-4f20-ba43-839d3474a560", "email": "rusdi@primulagemilang.com", "email_verified": false, "phone_verified": false}	email	2025-06-15 14:38:36.468607+00	2025-06-15 14:38:36.468651+00	2025-06-15 14:38:36.468651+00	dad9ce86-9c4a-4707-b3cd-dc121326e07d
a0b845cc-2c32-421e-9f3e-ebfe8e22cd15	a0b845cc-2c32-421e-9f3e-ebfe8e22cd15	{"sub": "a0b845cc-2c32-421e-9f3e-ebfe8e22cd15", "email": "spadmukahmill@gmail.com", "email_verified": false, "phone_verified": false}	email	2025-06-15 14:38:36.5646+00	2025-06-15 14:38:36.564648+00	2025-06-15 14:38:36.564648+00	8be6e40f-b1a6-4d69-a638-444123f7fb6e
e5871981-e66c-4c44-9183-0e8084e874c9	e5871981-e66c-4c44-9183-0e8084e874c9	{"sub": "e5871981-e66c-4c44-9183-0e8084e874c9", "email": "luangbadol@gmail.com", "email_verified": false, "phone_verified": false}	email	2025-06-15 14:38:36.667596+00	2025-06-15 14:38:36.667633+00	2025-06-15 14:38:36.667633+00	34f712c5-41e1-47a9-bd7a-bc4323644525
582f5571-b638-444b-9527-12503ce384a3	582f5571-b638-444b-9527-12503ce384a3	{"sub": "582f5571-b638-444b-9527-12503ce384a3", "email": "adninaminurrashid@gmail.com", "email_verified": false, "phone_verified": false}	email	2025-06-15 14:38:36.761138+00	2025-06-15 14:38:36.761172+00	2025-06-15 14:38:36.761172+00	3179b13b-55e4-4921-9ee4-ef3c4924cf80
05039a36-049a-47b0-9e99-6de64a44acbd	05039a36-049a-47b0-9e99-6de64a44acbd	{"sub": "05039a36-049a-47b0-9e99-6de64a44acbd", "email": "mspo2019@yahoo.com", "email_verified": false, "phone_verified": false}	email	2025-06-15 14:38:36.859095+00	2025-06-15 14:38:36.859131+00	2025-06-15 14:38:36.859131+00	c4f02a4d-2749-4a15-9f90-6d687b4cd46d
14e4c67b-bcde-4704-a97f-0dcbe1717dc5	14e4c67b-bcde-4704-a97f-0dcbe1717dc5	{"sub": "14e4c67b-bcde-4704-a97f-0dcbe1717dc5", "email": "whistlecert@gmail.com", "email_verified": false, "phone_verified": false}	email	2025-06-15 14:38:36.952684+00	2025-06-15 14:38:36.952721+00	2025-06-15 14:38:36.952721+00	92fad24b-8261-471a-856b-6af6e6e93331
4e33cfac-f5fe-4c35-9861-84d7917606ae	4e33cfac-f5fe-4c35-9861-84d7917606ae	{"sub": "4e33cfac-f5fe-4c35-9861-84d7917606ae", "email": "rveerasa@hotmail.com", "email_verified": false, "phone_verified": false}	email	2025-06-15 14:38:37.04859+00	2025-06-15 14:38:37.048629+00	2025-06-15 14:38:37.048629+00	6447efa1-4f71-455a-a994-6d05126cafdd
34e9281c-a3b1-412d-ba7e-fe29dad024c9	34e9281c-a3b1-412d-ba7e-fe29dad024c9	{"sub": "34e9281c-a3b1-412d-ba7e-fe29dad024c9", "email": "mateksadiahq@gmail.com", "email_verified": false, "phone_verified": false}	email	2025-06-15 14:38:37.138603+00	2025-06-15 14:38:37.138638+00	2025-06-15 14:38:37.138638+00	05f713d1-8f17-495d-90f4-17a77118f75f
8d6c1385-fa01-48c7-b761-4e0ebdcab162	8d6c1385-fa01-48c7-b761-4e0ebdcab162	{"sub": "8d6c1385-fa01-48c7-b761-4e0ebdcab162", "email": "hello@bliss.com", "email_verified": false, "phone_verified": false}	email	2025-06-15 14:38:37.240859+00	2025-06-15 14:38:37.240898+00	2025-06-15 14:38:37.240898+00	658462e1-bcb9-43a8-a9a6-00d32158936d
d8b08679-718a-49dc-a81d-141d5a5b048d	d8b08679-718a-49dc-a81d-141d5a5b048d	{"sub": "d8b08679-718a-49dc-a81d-141d5a5b048d", "email": "sustainabilitypr.ppom@gmail.com", "email_verified": false, "phone_verified": false}	email	2025-06-15 14:38:37.337986+00	2025-06-15 14:38:37.338025+00	2025-06-15 14:38:37.338025+00	091d1cd7-987e-4b70-831b-f6558541226c
54003f0f-9dc2-4142-a7a3-37781c6caa2f	54003f0f-9dc2-4142-a7a3-37781c6caa2f	{"sub": "54003f0f-9dc2-4142-a7a3-37781c6caa2f", "email": "muhsienbadrulisham@gmail.com", "email_verified": false, "phone_verified": false}	email	2025-06-15 14:38:37.433971+00	2025-06-15 14:38:37.434004+00	2025-06-15 14:38:37.434004+00	d5bc9465-5c9b-4dff-9b53-75c4d6a92254
0a7806d8-7b08-4629-bcfc-b5304bc684c4	0a7806d8-7b08-4629-bcfc-b5304bc684c4	{"sub": "0a7806d8-7b08-4629-bcfc-b5304bc684c4", "email": "murshidayusoff@gmail.com", "email_verified": false, "phone_verified": false}	email	2025-06-15 14:38:37.523738+00	2025-06-15 14:38:37.523773+00	2025-06-15 14:38:37.523773+00	7f71d5c3-73e5-46c5-b3b5-efd12fb9975b
2abe0ef5-50a6-4f32-bcd0-ccbb192771c5	2abe0ef5-50a6-4f32-bcd0-ccbb192771c5	{"sub": "2abe0ef5-50a6-4f32-bcd0-ccbb192771c5", "email": "chitra.loganathan@agrobank.com.my", "email_verified": false, "phone_verified": false}	email	2025-06-15 14:38:37.61941+00	2025-06-15 14:38:37.619444+00	2025-06-15 14:38:37.619444+00	920938ea-b122-417d-9722-27b69d8d3fe9
0919a2be-3b19-418f-91e8-ae8a8ffd3e48	0919a2be-3b19-418f-91e8-ae8a8ffd3e48	{"sub": "0919a2be-3b19-418f-91e8-ae8a8ffd3e48", "email": "baxteraymond@gmail.com", "email_verified": false, "phone_verified": false}	email	2025-06-15 14:38:37.727347+00	2025-06-15 14:38:37.727383+00	2025-06-15 14:38:37.727383+00	5c5a2481-79c7-47c0-938b-aed05a366235
01f2db6b-0dc0-45f1-842b-aced9d793fe6	01f2db6b-0dc0-45f1-842b-aced9d793fe6	{"sub": "01f2db6b-0dc0-45f1-842b-aced9d793fe6", "email": "nazmizain4499@yahoo.com", "email_verified": false, "phone_verified": false}	email	2025-06-15 14:38:37.819965+00	2025-06-15 14:38:37.820025+00	2025-06-15 14:38:37.820025+00	0862f2d0-74ed-4bfd-a667-7523cad81fc7
2fc4583b-c10b-423a-a6fe-a5e25b7bc801	2fc4583b-c10b-423a-a6fe-a5e25b7bc801	{"sub": "2fc4583b-c10b-423a-a6fe-a5e25b7bc801", "email": "monsokmill@gmail.com", "email_verified": false, "phone_verified": false}	email	2025-06-15 14:38:37.92315+00	2025-06-15 14:38:37.92319+00	2025-06-15 14:38:37.92319+00	3370e40c-d539-4d6c-89bf-5c2fd0e6fbb1
15f0f3a4-341a-4342-bca2-11c1d03d82a6	15f0f3a4-341a-4342-bca2-11c1d03d82a6	{"sub": "15f0f3a4-341a-4342-bca2-11c1d03d82a6", "email": "parameswaran_subramaniam@jabil.com", "email_verified": false, "phone_verified": false}	email	2025-06-15 14:38:38.026048+00	2025-06-15 14:38:38.026082+00	2025-06-15 14:38:38.026082+00	9f2f4368-cff4-4f09-b5e6-1a84b846d950
4af83a63-96e1-44ea-a7aa-749a66e5fcd7	4af83a63-96e1-44ea-a7aa-749a66e5fcd7	{"sub": "4af83a63-96e1-44ea-a7aa-749a66e5fcd7", "email": "michaeln@sarawak.gov.my", "email_verified": false, "phone_verified": false}	email	2025-06-15 14:38:38.118599+00	2025-06-15 14:38:38.118634+00	2025-06-15 14:38:38.118634+00	e903c098-7e3b-4b07-8a53-2eb0811b97d9
24f097e0-aad9-486d-887d-590379cf8f78	24f097e0-aad9-486d-887d-590379cf8f78	{"sub": "24f097e0-aad9-486d-887d-590379cf8f78", "email": "kasthuri@unitedmalacca.com.my", "email_verified": false, "phone_verified": false}	email	2025-06-15 14:38:38.214493+00	2025-06-15 14:38:38.21453+00	2025-06-15 14:38:38.21453+00	bffcdc4e-5e93-4ed2-8038-4ff9842ea012
3a62ecb7-b6c8-4883-9066-4e1a871adc12	3a62ecb7-b6c8-4883-9066-4e1a871adc12	{"sub": "3a62ecb7-b6c8-4883-9066-4e1a871adc12", "email": "test@yahoo.com", "email_verified": false, "phone_verified": false}	email	2025-06-15 14:38:38.305097+00	2025-06-15 14:38:38.305132+00	2025-06-15 14:38:38.305132+00	3ede82f5-592e-4cab-a92f-13c207933da6
bdbfe7f9-be3d-45db-9e74-0bafc00e3da8	bdbfe7f9-be3d-45db-9e74-0bafc00e3da8	{"sub": "bdbfe7f9-be3d-45db-9e74-0bafc00e3da8", "email": "rudy_patrick@ymail.com", "email_verified": false, "phone_verified": false}	email	2025-06-15 14:38:38.401589+00	2025-06-15 14:38:38.401624+00	2025-06-15 14:38:38.401624+00	95bbb4b3-563d-4300-9e34-c9164efd7165
8d17a10c-9baa-4371-be70-35eff53317e4	8d17a10c-9baa-4371-be70-35eff53317e4	{"sub": "8d17a10c-9baa-4371-be70-35eff53317e4", "email": "padil5595@gmail.com", "email_verified": false, "phone_verified": false}	email	2025-06-15 14:38:38.489569+00	2025-06-15 14:38:38.489604+00	2025-06-15 14:38:38.489604+00	57d127d3-f0d8-42c6-8584-26941bcc50b5
e8e773cd-d387-4efc-b92e-98dd804a3dd3	e8e773cd-d387-4efc-b92e-98dd804a3dd3	{"sub": "e8e773cd-d387-4efc-b92e-98dd804a3dd3", "email": "nurulsyahira336@gmail.com", "email_verified": false, "phone_verified": false}	email	2025-06-15 14:38:38.580716+00	2025-06-15 14:38:38.58075+00	2025-06-15 14:38:38.58075+00	96f833b7-8a57-48af-9a22-2531ab1fe826
e1ccea0a-ccc5-48c9-98dd-26a48399ec52	e1ccea0a-ccc5-48c9-98dd-26a48399ec52	{"sub": "e1ccea0a-ccc5-48c9-98dd-26a48399ec52", "email": "suhaidakanjisuhaida@gmail.com", "email_verified": false, "phone_verified": false}	email	2025-06-15 14:38:38.67497+00	2025-06-15 14:38:38.675003+00	2025-06-15 14:38:38.675003+00	85c52e82-83b4-49f1-b8ff-587f25668691
cc6ec44c-3285-40f9-84fd-fe38f6cac978	cc6ec44c-3285-40f9-84fd-fe38f6cac978	{"sub": "cc6ec44c-3285-40f9-84fd-fe38f6cac978", "email": "ravestan@gmail.com", "email_verified": false, "phone_verified": false}	email	2025-06-15 14:38:38.777719+00	2025-06-15 14:38:38.777755+00	2025-06-15 14:38:38.777755+00	7f844bad-f03c-45b0-a2c8-426c107cdecf
5ad2dbaf-6d13-47a0-b9d2-47b7adb86ff0	5ad2dbaf-6d13-47a0-b9d2-47b7adb86ff0	{"sub": "5ad2dbaf-6d13-47a0-b9d2-47b7adb86ff0", "email": "imj800120@gmail.com", "email_verified": false, "phone_verified": false}	email	2025-06-15 14:38:38.875086+00	2025-06-15 14:38:38.875121+00	2025-06-15 14:38:38.875121+00	752ca0a6-8d41-4367-8931-0ed31e9b2cac
7d417c53-b437-40ff-911a-8d9eef5e2977	7d417c53-b437-40ff-911a-8d9eef5e2977	{"sub": "7d417c53-b437-40ff-911a-8d9eef5e2977", "email": "tajuddinkamil@yahoo.com", "email_verified": false, "phone_verified": false}	email	2025-06-15 14:38:38.975053+00	2025-06-15 14:38:38.975089+00	2025-06-15 14:38:38.975089+00	a6976c09-1784-4959-9f2f-5768c9745335
e6dae6f9-e483-4071-923d-095f173ed23e	e6dae6f9-e483-4071-923d-095f173ed23e	{"sub": "e6dae6f9-e483-4071-923d-095f173ed23e", "email": "dylan.j.ong@gmail.com", "email_verified": false, "phone_verified": false}	email	2025-06-15 14:38:39.067673+00	2025-06-15 14:38:39.067708+00	2025-06-15 14:38:39.067708+00	0fc7bdc3-bc2b-445d-84bf-aecbf012a9de
24d8cbc0-b247-4c06-bd71-80c775c228f0	24d8cbc0-b247-4c06-bd71-80c775c228f0	{"sub": "24d8cbc0-b247-4c06-bd71-80c775c228f0", "email": "solidorient2812@gmail.com", "email_verified": false, "phone_verified": false}	email	2025-06-15 14:38:39.159821+00	2025-06-15 14:38:39.159855+00	2025-06-15 14:38:39.159855+00	f42551c4-f9ca-4602-b3e1-ee161c57f562
c03ad22a-b91d-4788-9b2e-d4e016651a9b	c03ad22a-b91d-4788-9b2e-d4e016651a9b	{"sub": "c03ad22a-b91d-4788-9b2e-d4e016651a9b", "email": "jasrsb@gmail.com", "email_verified": false, "phone_verified": false}	email	2025-06-15 14:38:39.263364+00	2025-06-15 14:38:39.263412+00	2025-06-15 14:38:39.263412+00	6ac5fc6f-f69b-427f-b043-c45b09a10209
fe48a53d-699e-4b91-9987-efdd47b9b34b	fe48a53d-699e-4b91-9987-efdd47b9b34b	{"sub": "fe48a53d-699e-4b91-9987-efdd47b9b34b", "email": "andyaw8149@gmail.com", "email_verified": false, "phone_verified": false}	email	2025-06-15 14:38:39.362795+00	2025-06-15 14:38:39.362832+00	2025-06-15 14:38:39.362832+00	9831d19d-73ba-46bd-b2b2-a058e4f9cc49
54762cd7-e15c-4dfe-b8c3-620921ec2366	54762cd7-e15c-4dfe-b8c3-620921ec2366	{"sub": "54762cd7-e15c-4dfe-b8c3-620921ec2366", "email": "rose_rmy@hotmail.com", "email_verified": false, "phone_verified": false}	email	2025-06-15 14:38:39.462323+00	2025-06-15 14:38:39.46236+00	2025-06-15 14:38:39.46236+00	2664c133-a131-47e0-8253-65376fb9bcc2
6b17a4a1-6399-4241-8bae-98ce72ffd9b8	6b17a4a1-6399-4241-8bae-98ce72ffd9b8	{"sub": "6b17a4a1-6399-4241-8bae-98ce72ffd9b8", "email": "syafiqdanial1803@hotmail.com", "email_verified": false, "phone_verified": false}	email	2025-06-15 14:38:39.56092+00	2025-06-15 14:38:39.560954+00	2025-06-15 14:38:39.560954+00	a8f23ddb-3dea-498f-bd7a-3ff9d66364a5
646b90b4-51f9-44ce-9e89-41492cb826f9	646b90b4-51f9-44ce-9e89-41492cb826f9	{"sub": "646b90b4-51f9-44ce-9e89-41492cb826f9", "email": "siing8807@gmail.com", "email_verified": false, "phone_verified": false}	email	2025-06-15 14:38:39.659561+00	2025-06-15 14:38:39.659595+00	2025-06-15 14:38:39.659595+00	5efb3d5d-2c58-4de8-b0c9-1d2974e776c5
6f88c691-03be-4853-8903-67e2bca0d234	6f88c691-03be-4853-8903-67e2bca0d234	{"sub": "6f88c691-03be-4853-8903-67e2bca0d234", "email": "kitying88@gmail.com", "email_verified": false, "phone_verified": false}	email	2025-06-15 14:38:39.76927+00	2025-06-15 14:38:39.769307+00	2025-06-15 14:38:39.769307+00	9cdc4ee6-394b-4a0d-8b4c-fbf57fe8c575
33f581a6-b5de-49d8-acdd-1166f5a55844	33f581a6-b5de-49d8-acdd-1166f5a55844	{"sub": "33f581a6-b5de-49d8-acdd-1166f5a55844", "email": "burnbakar1538@gmail.com", "email_verified": false, "phone_verified": false}	email	2025-06-15 14:38:39.869533+00	2025-06-15 14:38:39.869568+00	2025-06-15 14:38:39.869568+00	b14aa871-5643-4c58-8bb1-6cb50da0f592
a31bd0c1-174b-4922-a1b7-e60acc9b25b4	a31bd0c1-174b-4922-a1b7-e60acc9b25b4	{"sub": "a31bd0c1-174b-4922-a1b7-e60acc9b25b4", "email": "wl.young@davoslife.com", "email_verified": false, "phone_verified": false}	email	2025-06-15 14:38:39.965068+00	2025-06-15 14:38:39.965106+00	2025-06-15 14:38:39.965106+00	ecca2e35-9e8f-4678-a978-46bdba3a76ac
0492f0e6-5805-44af-aa74-4db0c77a4140	0492f0e6-5805-44af-aa74-4db0c77a4140	{"sub": "0492f0e6-5805-44af-aa74-4db0c77a4140", "email": "cbpb860009@gmail.com", "email_verified": false, "phone_verified": false}	email	2025-06-15 14:38:40.061524+00	2025-06-15 14:38:40.061557+00	2025-06-15 14:38:40.061557+00	4ee6ba78-9819-488b-b721-83da8f18d194
6a07ae1f-58b7-49a3-b140-407f7039c517	6a07ae1f-58b7-49a3-b140-407f7039c517	{"sub": "6a07ae1f-58b7-49a3-b140-407f7039c517", "email": "mages@op.shh.my", "email_verified": false, "phone_verified": false}	email	2025-06-15 14:38:40.152321+00	2025-06-15 14:38:40.152354+00	2025-06-15 14:38:40.152354+00	448a5bb4-b64a-48d2-bfba-07c94235786e
25c9e59a-dddc-4e8d-9b27-4033d9f1274a	25c9e59a-dddc-4e8d-9b27-4033d9f1274a	{"sub": "25c9e59a-dddc-4e8d-9b27-4033d9f1274a", "email": "elink.hidayat@gmail.com", "email_verified": false, "phone_verified": false}	email	2025-06-15 14:38:40.244628+00	2025-06-15 14:38:40.244697+00	2025-06-15 14:38:40.244697+00	6969dd16-6494-40ca-9a64-1da045c44f10
4120635d-c542-437d-9cea-9319b2338db0	4120635d-c542-437d-9cea-9319b2338db0	{"sub": "4120635d-c542-437d-9cea-9319b2338db0", "email": "allariff@st.gov.my", "email_verified": false, "phone_verified": false}	email	2025-06-15 14:38:40.341295+00	2025-06-15 14:38:40.341337+00	2025-06-15 14:38:40.341337+00	e41a644f-4550-45bb-8ba0-832d90da42c3
93a02249-5316-49a2-9ac7-12b4c8905133	93a02249-5316-49a2-9ac7-12b4c8905133	{"sub": "93a02249-5316-49a2-9ac7-12b4c8905133", "email": "zuki.ak@fgvholdings.com", "email_verified": false, "phone_verified": false}	email	2025-06-15 14:38:40.443002+00	2025-06-15 14:38:40.443036+00	2025-06-15 14:38:40.443036+00	02bd40d7-9e25-4cba-a3af-cdf067070eaf
fd863516-76ca-4417-8047-db3bdf0cb04e	fd863516-76ca-4417-8047-db3bdf0cb04e	{"sub": "fd863516-76ca-4417-8047-db3bdf0cb04e", "email": "alexius.n@fgvholding.socm", "email_verified": false, "phone_verified": false}	email	2025-06-15 14:38:40.536525+00	2025-06-15 14:38:40.536561+00	2025-06-15 14:38:40.536561+00	44f3da07-b811-4baf-8488-a72d2d2d76fb
e8eef5b6-23c8-43b6-b361-5407820aa1bd	e8eef5b6-23c8-43b6-b361-5407820aa1bd	{"sub": "e8eef5b6-23c8-43b6-b361-5407820aa1bd", "email": "andyjhall1979@gmail.com", "email_verified": false, "phone_verified": false}	email	2025-06-15 14:38:40.631724+00	2025-06-15 14:38:40.63176+00	2025-06-15 14:38:40.63176+00	b1425b68-26d1-4c22-9051-098d5c4f204c
0e4b6571-d7da-4d82-8035-b53821d50643	0e4b6571-d7da-4d82-8035-b53821d50643	{"sub": "0e4b6571-d7da-4d82-8035-b53821d50643", "email": "ladangdelima17@yahoo.com", "email_verified": false, "phone_verified": false}	email	2025-06-15 14:38:40.722942+00	2025-06-15 14:38:40.722977+00	2025-06-15 14:38:40.722977+00	104bb9f1-34fc-46a4-9acb-cab2ae0e6433
3daebba2-2008-456d-85ff-0f51d49e2068	3daebba2-2008-456d-85ff-0f51d49e2068	{"sub": "3daebba2-2008-456d-85ff-0f51d49e2068", "email": "khairulidzuan@fjgroup.com.my", "email_verified": false, "phone_verified": false}	email	2025-06-15 14:38:40.815204+00	2025-06-15 14:38:40.81524+00	2025-06-15 14:38:40.81524+00	b2e9f335-d596-4602-931c-4793fc8c8a76
79e11466-b344-4852-81cb-39ff9e45ebc0	79e11466-b344-4852-81cb-39ff9e45ebc0	{"sub": "79e11466-b344-4852-81cb-39ff9e45ebc0", "email": "mimisharida@gmail.com", "email_verified": false, "phone_verified": false}	email	2025-06-15 14:38:40.91664+00	2025-06-15 14:38:40.916684+00	2025-06-15 14:38:40.916684+00	1f852676-537c-492f-9dc3-a323e3f2ebe5
4838f267-e471-42c2-960a-afb1bbe50dd5	4838f267-e471-42c2-960a-afb1bbe50dd5	{"sub": "4838f267-e471-42c2-960a-afb1bbe50dd5", "email": "ongtp@gtsr.com.my", "email_verified": false, "phone_verified": false}	email	2025-06-15 14:38:41.012047+00	2025-06-15 14:38:41.012082+00	2025-06-15 14:38:41.012082+00	e5a8917d-0398-4059-9b9f-c236d4df64d3
4735ce34-ed6c-4b84-a258-c098689ca12f	4735ce34-ed6c-4b84-a258-c098689ca12f	{"sub": "4735ce34-ed6c-4b84-a258-c098689ca12f", "email": "wtkalpha@gmail.com", "email_verified": false, "phone_verified": false}	email	2025-06-15 14:38:41.107938+00	2025-06-15 14:38:41.107973+00	2025-06-15 14:38:41.107973+00	114d58e1-7616-41b2-9f8c-2d6865874ff6
0b500a7c-c000-4b0f-b19a-4cc42e3d380e	0b500a7c-c000-4b0f-b19a-4cc42e3d380e	{"sub": "0b500a7c-c000-4b0f-b19a-4cc42e3d380e", "email": "ruekeithjampong@gmail.com", "email_verified": false, "phone_verified": false}	email	2025-06-15 14:38:41.203859+00	2025-06-15 14:38:41.203896+00	2025-06-15 14:38:41.203896+00	4192f17b-6931-4668-bce0-ba18f3811f0c
80c123de-90b0-4fd6-9424-1e93e57c96fb	80c123de-90b0-4fd6-9424-1e93e57c96fb	{"sub": "80c123de-90b0-4fd6-9424-1e93e57c96fb", "email": "bintang@bell.com.my", "email_verified": false, "phone_verified": false}	email	2025-06-15 14:38:41.298133+00	2025-06-15 14:38:41.298169+00	2025-06-15 14:38:41.298169+00	5d4c6ceb-049c-4f7f-8b3a-e42e99d960ec
bcc22448-661c-4e28-99a8-edb83a48195e	bcc22448-661c-4e28-99a8-edb83a48195e	{"sub": "bcc22448-661c-4e28-99a8-edb83a48195e", "email": "ainanajwa.sbh@gmail.com", "email_verified": false, "phone_verified": false}	email	2025-06-15 14:38:41.387682+00	2025-06-15 14:38:41.387718+00	2025-06-15 14:38:41.387718+00	68c6fa3c-3ae0-4422-a6b0-77bfd9976d2a
77580fe9-7ac2-4fb0-9aa7-06995f768dea	77580fe9-7ac2-4fb0-9aa7-06995f768dea	{"sub": "77580fe9-7ac2-4fb0-9aa7-06995f768dea", "email": "rizal1976@gmail.com", "email_verified": false, "phone_verified": false}	email	2025-06-15 14:38:41.478399+00	2025-06-15 14:38:41.478434+00	2025-06-15 14:38:41.478434+00	55355c6e-dc52-4fcb-b2b3-c244790ce490
1d351dae-d3b7-476d-9c6a-c3851e6117f8	1d351dae-d3b7-476d-9c6a-c3851e6117f8	{"sub": "1d351dae-d3b7-476d-9c6a-c3851e6117f8", "email": "loureschristiansen@gmail.com", "email_verified": false, "phone_verified": false}	email	2025-06-15 14:38:41.577093+00	2025-06-15 14:38:41.577125+00	2025-06-15 14:38:41.577125+00	4ad79198-3dac-4b6e-97a6-c00b0ed6a98f
b37636b3-8be1-4178-9cf2-8b57f5394441	b37636b3-8be1-4178-9cf2-8b57f5394441	{"sub": "b37636b3-8be1-4178-9cf2-8b57f5394441", "email": "vendettavendetta326@gmail.com", "email_verified": false, "phone_verified": false}	email	2025-06-15 14:38:41.668232+00	2025-06-15 14:38:41.668265+00	2025-06-15 14:38:41.668265+00	ba28a18b-a58d-4f4f-b5c3-fc4391cbe867
86c5fd15-a47d-44b9-94f9-864b787d7db8	86c5fd15-a47d-44b9-94f9-864b787d7db8	{"sub": "86c5fd15-a47d-44b9-94f9-864b787d7db8", "email": "foong9626@gmail.com", "email_verified": false, "phone_verified": false}	email	2025-06-15 14:38:41.765953+00	2025-06-15 14:38:41.76599+00	2025-06-15 14:38:41.76599+00	8c5d7927-6e16-41c9-bdfc-b66bdd4a0de4
26e06765-0726-4760-a956-cd6c133c8cf1	26e06765-0726-4760-a956-cd6c133c8cf1	{"sub": "26e06765-0726-4760-a956-cd6c133c8cf1", "email": "yakboy02@gmail.com", "email_verified": false, "phone_verified": false}	email	2025-06-15 14:38:41.867511+00	2025-06-15 14:38:41.867545+00	2025-06-15 14:38:41.867545+00	d580973d-2aa2-45a2-bef3-75cf3dda8c62
9899069d-e0c6-4dec-b3cd-e4080a838f61	9899069d-e0c6-4dec-b3cd-e4080a838f61	{"sub": "9899069d-e0c6-4dec-b3cd-e4080a838f61", "email": "aireimail24@gmail.com", "email_verified": false, "phone_verified": false}	email	2025-06-15 14:38:41.963173+00	2025-06-15 14:38:41.963208+00	2025-06-15 14:38:41.963208+00	ed1b33c7-8459-4729-848a-994d00f019c1
43e2d156-815e-45bc-a9c4-959ffc35a607	43e2d156-815e-45bc-a9c4-959ffc35a607	{"sub": "43e2d156-815e-45bc-a9c4-959ffc35a607", "email": "riswanrasid@gmail.com", "email_verified": false, "phone_verified": false}	email	2025-06-15 14:38:42.056519+00	2025-06-15 14:38:42.056553+00	2025-06-15 14:38:42.056553+00	31beb840-cd1c-425e-a1f1-bdc3c3b9b14f
97f7ac1a-aaf7-4061-8dba-cef646b37a3b	97f7ac1a-aaf7-4061-8dba-cef646b37a3b	{"sub": "97f7ac1a-aaf7-4061-8dba-cef646b37a3b", "email": "mohamadmat921231@gmail.com", "email_verified": false, "phone_verified": false}	email	2025-06-15 14:38:42.153488+00	2025-06-15 14:38:42.153526+00	2025-06-15 14:38:42.153526+00	7c5052e8-4c34-4dec-98a4-8d6510093941
e24e82c5-482d-44c5-95e4-0dec79afeffc	e24e82c5-482d-44c5-95e4-0dec79afeffc	{"sub": "e24e82c5-482d-44c5-95e4-0dec79afeffc", "email": "spnrajendran@gmail.com", "email_verified": false, "phone_verified": false}	email	2025-06-15 14:38:42.245851+00	2025-06-15 14:38:42.245884+00	2025-06-15 14:38:42.245884+00	ff4a4319-373a-4964-b711-e45b999d405e
9bfb750a-2c2d-4bfc-9999-44fdabda74dd	9bfb750a-2c2d-4bfc-9999-44fdabda74dd	{"sub": "9bfb750a-2c2d-4bfc-9999-44fdabda74dd", "email": "kheongsc83@gmail.com", "email_verified": false, "phone_verified": false}	email	2025-06-15 14:38:42.349527+00	2025-06-15 14:38:42.349566+00	2025-06-15 14:38:42.349566+00	bba0faca-129d-4d97-a82a-5d2946a12c46
fc2ca455-d9cb-44de-a313-e5f66f65a688	fc2ca455-d9cb-44de-a313-e5f66f65a688	{"sub": "fc2ca455-d9cb-44de-a313-e5f66f65a688", "email": "ussepudun2050@gmail.com", "email_verified": false, "phone_verified": false}	email	2025-06-15 14:38:42.445455+00	2025-06-15 14:38:42.44549+00	2025-06-15 14:38:42.44549+00	605dd60a-0d90-4e7d-97bb-a13312a043b5
ad892dc0-1949-48b7-be5e-d63c7290e512	ad892dc0-1949-48b7-be5e-d63c7290e512	{"sub": "ad892dc0-1949-48b7-be5e-d63c7290e512", "email": "hasbollah@mspo.org.my", "email_verified": false, "phone_verified": false}	email	2025-06-15 14:38:42.541253+00	2025-06-15 14:38:42.541286+00	2025-06-15 14:38:42.541286+00	63aae30d-17b5-4a21-bf56-3b8f140774a7
bb194837-db77-40d9-a6fd-5e9737c5724e	bb194837-db77-40d9-a6fd-5e9737c5724e	{"sub": "bb194837-db77-40d9-a6fd-5e9737c5724e", "email": "pom_logo@yopmail.com", "email_verified": false, "phone_verified": false}	email	2025-06-18 02:09:49.663278+00	2025-06-18 02:09:49.663319+00	2025-06-18 02:09:49.663319+00	04e4c13f-5f14-4bad-aa5e-e6c2838b6443
8bc44ea0-2e33-458a-ac4d-298980c44b05	8bc44ea0-2e33-458a-ac4d-298980c44b05	{"sub": "8bc44ea0-2e33-458a-ac4d-298980c44b05", "email": "christabelle.winona@tsggroup.my", "email_verified": false, "phone_verified": false}	email	2025-06-23 07:40:12.637164+00	2025-06-23 07:40:12.637271+00	2025-06-23 07:40:12.637271+00	07a61a36-9b52-4722-a798-c7f678a5a181
e2c36046-d53b-4a02-9eef-f85a47d6c357	e2c36046-d53b-4a02-9eef-f85a47d6c357	{"sub": "e2c36046-d53b-4a02-9eef-f85a47d6c357", "email": "stephen.lee@grandolie.com", "email_verified": false, "phone_verified": false}	email	2025-06-23 07:40:13.671744+00	2025-06-23 07:40:13.671785+00	2025-06-23 07:40:13.671785+00	661f01b7-82b2-412f-88f6-9be8eb871c5d
c3a67ce5-0445-4f78-8259-c115bc188a26	c3a67ce5-0445-4f78-8259-c115bc188a26	{"sub": "c3a67ce5-0445-4f78-8259-c115bc188a26", "email": "tingpikhieng@gmail.com", "email_verified": false, "phone_verified": false}	email	2025-06-23 07:40:31.190763+00	2025-06-23 07:40:31.190801+00	2025-06-23 07:40:31.190801+00	fe880380-8666-40d2-b016-e0d24a45f145
20754c43-864b-45c9-8e9d-5f71b3dceb39	20754c43-864b-45c9-8e9d-5f71b3dceb39	{"sub": "20754c43-864b-45c9-8e9d-5f71b3dceb39", "email": "patriciachan@salcra.gov.my", "email_verified": false, "phone_verified": false}	email	2025-06-23 07:40:45.976883+00	2025-06-23 07:40:45.976918+00	2025-06-23 07:40:45.976918+00	31d15329-ef51-4289-8441-2797b45e0348
a1008ee6-6805-4d56-956d-0bcaad374870	a1008ee6-6805-4d56-956d-0bcaad374870	{"sub": "a1008ee6-6805-4d56-956d-0bcaad374870", "email": "abigail@salcra.gov.my", "email_verified": false, "phone_verified": false}	email	2025-06-23 07:40:50.629664+00	2025-06-23 07:40:50.629709+00	2025-06-23 07:40:50.629709+00	1b5bdbbe-193e-46ae-a902-6f4a11f1e9ca
fd238175-c03f-4b7a-a819-0837b802ae2c	fd238175-c03f-4b7a-a819-0837b802ae2c	{"sub": "fd238175-c03f-4b7a-a819-0837b802ae2c", "email": "davidb@salcra.gov.my", "email_verified": false, "phone_verified": false}	email	2025-06-23 07:41:53.926828+00	2025-06-23 07:41:53.92686+00	2025-06-23 07:41:53.92686+00	351cdf29-0ed1-4e63-9dca-3c86d311a01e
5dfc121a-a553-4380-9094-d716a81b495f	5dfc121a-a553-4380-9094-d716a81b495f	{"sub": "5dfc121a-a553-4380-9094-d716a81b495f", "email": "francefcw@yahoo.com", "email_verified": false, "phone_verified": false}	email	2025-06-23 07:41:59.337343+00	2025-06-23 07:41:59.337377+00	2025-06-23 07:41:59.337377+00	748f3d88-8d43-4a92-a827-879628dc9a93
ba467302-a9dd-49f1-bb39-442fdab37dcd	ba467302-a9dd-49f1-bb39-442fdab37dcd	{"sub": "ba467302-a9dd-49f1-bb39-442fdab37dcd", "email": "margetha.achong@my.wilmar-intl.com", "email_verified": false, "phone_verified": false}	email	2025-06-23 07:42:01.097611+00	2025-06-23 07:42:01.097645+00	2025-06-23 07:42:01.097645+00	4e42d504-d353-4946-9663-dd93aa343399
3f695e7a-da08-4344-8d1c-60d1e4d3d772	3f695e7a-da08-4344-8d1c-60d1e4d3d772	{"sub": "3f695e7a-da08-4344-8d1c-60d1e4d3d772", "email": "josephrn@salcra.gov.my", "email_verified": false, "phone_verified": false}	email	2025-06-23 07:42:25.108903+00	2025-06-23 07:42:25.108937+00	2025-06-23 07:42:25.108937+00	42db0852-cfb5-41f3-a68c-52c8eb0f5d75
e4f7c6ca-5cfe-411a-a814-45a13ee76fe4	e4f7c6ca-5cfe-411a-a814-45a13ee76fe4	{"sub": "e4f7c6ca-5cfe-411a-a814-45a13ee76fe4", "email": "kru@thplantations.com", "email_verified": false, "phone_verified": false}	email	2025-06-23 07:42:27.467042+00	2025-06-23 07:42:27.46708+00	2025-06-23 07:42:27.46708+00	54257696-c90a-4934-b3f4-083494a5ef8f
878637b4-5c02-462a-80e3-edd2cb4dd365	878637b4-5c02-462a-80e3-edd2cb4dd365	{"sub": "878637b4-5c02-462a-80e3-edd2cb4dd365", "email": "pairinsonjengok.86@gmail.com", "email_verified": false, "phone_verified": false}	email	2025-06-23 07:42:35.152511+00	2025-06-23 07:42:35.152547+00	2025-06-23 07:42:35.152547+00	30c3c35b-ffa2-499f-a3ba-ae002cdd8545
2186e85a-0204-40d2-ac5a-1ae7600edfa3	2186e85a-0204-40d2-ac5a-1ae7600edfa3	{"sub": "2186e85a-0204-40d2-ac5a-1ae7600edfa3", "email": "risnid@salcra.gov.my", "email_verified": false, "phone_verified": false}	email	2025-06-23 07:42:35.311608+00	2025-06-23 07:42:35.311646+00	2025-06-23 07:42:35.311646+00	b287346b-4f1b-4420-b506-968e2969536f
f7280a96-7703-4d4d-b2a8-9d2acc15a160	f7280a96-7703-4d4d-b2a8-9d2acc15a160	{"sub": "f7280a96-7703-4d4d-b2a8-9d2acc15a160", "email": "alicesa.ramba@keresa.com.my", "email_verified": false, "phone_verified": false}	email	2025-06-23 07:42:41.758319+00	2025-06-23 07:42:41.758354+00	2025-06-23 07:42:41.758354+00	604fdaac-9967-4311-8175-e6dca227e6b0
9e2f17ea-26c5-414b-835c-f9b42705c024	9e2f17ea-26c5-414b-835c-f9b42705c024	{"sub": "9e2f17ea-26c5-414b-835c-f9b42705c024", "email": "mohdhafizmohamadrafiq@gmail.com", "email_verified": false, "phone_verified": false}	email	2025-06-23 07:42:52.931775+00	2025-06-23 07:42:52.931811+00	2025-06-23 07:42:52.931811+00	b3e9b827-d3cf-4849-a95e-9a425c845f85
7df7ea94-16ba-4fd6-85bc-4fd0155fe284	7df7ea94-16ba-4fd6-85bc-4fd0155fe284	{"sub": "7df7ea94-16ba-4fd6-85bc-4fd0155fe284", "email": "soon.masranti@gmail.com", "email_verified": false, "phone_verified": false}	email	2025-06-23 07:43:02.122874+00	2025-06-23 07:43:02.122924+00	2025-06-23 07:43:02.122924+00	ab333b87-3360-4206-b28c-ae75b849f0ce
bc9650f6-a750-4deb-98f6-636b76c60b62	bc9650f6-a750-4deb-98f6-636b76c60b62	{"sub": "bc9650f6-a750-4deb-98f6-636b76c60b62", "email": "eliana.robert@tpb.com.my", "email_verified": false, "phone_verified": false}	email	2025-06-23 07:43:10.623318+00	2025-06-23 07:43:10.623354+00	2025-06-23 07:43:10.623354+00	a86406e3-6605-40bc-86ab-7069cbef3fe1
0d12ddb0-122b-46a3-afba-c35c8640e887	0d12ddb0-122b-46a3-afba-c35c8640e887	{"sub": "0d12ddb0-122b-46a3-afba-c35c8640e887", "email": "simleongeng@yahoo.com", "email_verified": false, "phone_verified": false}	email	2025-06-23 07:43:26.701484+00	2025-06-23 07:43:26.701517+00	2025-06-23 07:43:26.701517+00	1ae9625d-1d31-4f83-abdc-f6d0d64bb108
a4051467-1969-4a0f-8657-d8f3f0ba6359	a4051467-1969-4a0f-8657-d8f3f0ba6359	{"sub": "a4051467-1969-4a0f-8657-d8f3f0ba6359", "email": "dienstainkemiti@gmail.com", "email_verified": false, "phone_verified": false}	email	2025-06-23 07:43:52.634183+00	2025-06-23 07:43:52.634217+00	2025-06-23 07:43:52.634217+00	aaee457e-5748-40de-9c04-da5d02c41972
0cd2be50-abf7-420e-a986-7fa5371cf6a3	0cd2be50-abf7-420e-a986-7fa5371cf6a3	{"sub": "0cd2be50-abf7-420e-a986-7fa5371cf6a3", "email": "emilia.as@tpb.com.my", "email_verified": false, "phone_verified": false}	email	2025-06-23 07:44:11.297526+00	2025-06-23 07:44:11.297563+00	2025-06-23 07:44:11.297563+00	4efee147-1510-4bfc-b3d5-2329355d433a
ac59ee7e-0939-4e05-bf57-be9508f40d82	ac59ee7e-0939-4e05-bf57-be9508f40d82	{"sub": "ac59ee7e-0939-4e05-bf57-be9508f40d82", "email": "rsblundupom@rsb.com.my", "email_verified": false, "phone_verified": false}	email	2025-06-23 07:44:36.496521+00	2025-06-23 07:44:36.49657+00	2025-06-23 07:44:36.49657+00	c5d67d16-b016-45eb-882c-d257d0679086
016ca48e-66c5-476c-9716-c6397ed60e69	016ca48e-66c5-476c-9716-c6397ed60e69	{"sub": "016ca48e-66c5-476c-9716-c6397ed60e69", "email": "raphaelmodany@gmail.com", "email_verified": false, "phone_verified": false}	email	2025-06-23 07:44:52.034166+00	2025-06-23 07:44:52.034199+00	2025-06-23 07:44:52.034199+00	a4a1f05d-165b-4736-924d-028094183897
08a2cbdf-9a26-4469-9034-ed7b3f5b73e9	08a2cbdf-9a26-4469-9034-ed7b3f5b73e9	{"sub": "08a2cbdf-9a26-4469-9034-ed7b3f5b73e9", "email": "tbs.mill.admin@taann.com.my", "email_verified": false, "phone_verified": false}	email	2025-06-23 07:44:52.385544+00	2025-06-23 07:44:52.385579+00	2025-06-23 07:44:52.385579+00	84d7c716-5747-4a1b-b9dd-f2573160c97f
ee74b89d-137d-470c-8a00-90fb5a372727	ee74b89d-137d-470c-8a00-90fb5a372727	{"sub": "ee74b89d-137d-470c-8a00-90fb5a372727", "email": "wifredk@salcra.gov.my", "email_verified": false, "phone_verified": false}	email	2025-06-23 07:45:13.470242+00	2025-06-23 07:45:13.470289+00	2025-06-23 07:45:13.470289+00	9fc2a27a-b44a-414b-986c-0023b7ba1e39
47676bae-55c6-48f5-8b6a-dc0a3af02ec4	47676bae-55c6-48f5-8b6a-dc0a3af02ec4	{"sub": "47676bae-55c6-48f5-8b6a-dc0a3af02ec4", "email": "diana.do@keresa.com.my", "email_verified": false, "phone_verified": false}	email	2025-06-23 07:45:26.429542+00	2025-06-23 07:45:26.429605+00	2025-06-23 07:45:26.429605+00	221f4ab3-1277-4a59-91aa-aa122dc59b8b
1698b43a-831d-455f-bb6f-22c3097c005f	1698b43a-831d-455f-bb6f-22c3097c005f	{"sub": "1698b43a-831d-455f-bb6f-22c3097c005f", "email": "ndhiera82@gmail.com", "email_verified": false, "phone_verified": false}	email	2025-06-23 07:45:27.885593+00	2025-06-23 07:45:27.885631+00	2025-06-23 07:45:27.885631+00	e1d1d49b-bbcf-4e7d-9717-a427352b356c
3142bce6-7211-4fd1-a09f-1d17e6cf287a	3142bce6-7211-4fd1-a09f-1d17e6cf287a	{"sub": "3142bce6-7211-4fd1-a09f-1d17e6cf287a", "email": "jubaidahadam123@gmail.com", "email_verified": false, "phone_verified": false}	email	2025-06-23 07:45:30.952616+00	2025-06-23 07:45:30.95265+00	2025-06-23 07:45:30.95265+00	a82cad4c-3c34-41f2-a338-4fa989376682
9e6b451a-3a18-4f0c-97f3-fcccefe12a55	9e6b451a-3a18-4f0c-97f3-fcccefe12a55	{"sub": "9e6b451a-3a18-4f0c-97f3-fcccefe12a55", "email": "norlidakeri1@gmail.com", "email_verified": false, "phone_verified": false}	email	2025-06-23 07:45:35.860626+00	2025-06-23 07:45:35.860661+00	2025-06-23 07:45:35.860661+00	be70b16f-08d7-49ee-8ba6-74a1f7da4277
a829ccb9-78d5-4940-82f6-934352e828cd	a829ccb9-78d5-4940-82f6-934352e828cd	{"sub": "a829ccb9-78d5-4940-82f6-934352e828cd", "email": "lpom.samling@gmail.com", "email_verified": false, "phone_verified": false}	email	2025-06-23 07:45:50.210692+00	2025-06-23 07:45:50.210743+00	2025-06-23 07:45:50.210743+00	45ccd930-29ae-4608-9c85-27559d8eb331
6dc3e17b-1af0-4a4b-abaf-a9830465a207	6dc3e17b-1af0-4a4b-abaf-a9830465a207	{"sub": "6dc3e17b-1af0-4a4b-abaf-a9830465a207", "email": "pelicitym@salcra.gov.my", "email_verified": false, "phone_verified": false}	email	2025-06-23 07:45:55.123838+00	2025-06-23 07:45:55.123874+00	2025-06-23 07:45:55.123874+00	9ff49ae3-b845-4b24-81c9-e266aa583897
4e579a51-bb42-45f1-9b79-b84928a98421	4e579a51-bb42-45f1-9b79-b84928a98421	{"sub": "4e579a51-bb42-45f1-9b79-b84928a98421", "email": "kaveeraaz@gmail.com", "email_verified": false, "phone_verified": false}	email	2025-06-23 07:46:01.253172+00	2025-06-23 07:46:01.253207+00	2025-06-23 07:46:01.253207+00	89d7928a-84f2-4716-a4d2-dc4cccde7267
7d693d50-00d4-4a9b-9bc0-35afebbb30d9	7d693d50-00d4-4a9b-9bc0-35afebbb30d9	{"sub": "7d693d50-00d4-4a9b-9bc0-35afebbb30d9", "email": "richardting@spbgroup.com.my", "email_verified": false, "phone_verified": false}	email	2025-06-23 07:46:08.166496+00	2025-06-23 07:46:08.166534+00	2025-06-23 07:46:08.166534+00	f9488b06-65b0-4219-806f-b5406952fc24
7f05337a-1f10-411a-8c90-ab632faaf8c2	7f05337a-1f10-411a-8c90-ab632faaf8c2	{"sub": "7f05337a-1f10-411a-8c90-ab632faaf8c2", "email": "manisoil.mill.admin@taann.com.my", "email_verified": false, "phone_verified": false}	email	2025-06-23 07:46:22.352834+00	2025-06-23 07:46:22.352872+00	2025-06-23 07:46:22.352872+00	ac1c6086-7455-405f-bdf3-822dc0074a9f
7b53d13f-0338-44ff-a05d-238f8d25cad4	7b53d13f-0338-44ff-a05d-238f8d25cad4	{"sub": "7b53d13f-0338-44ff-a05d-238f8d25cad4", "email": "genevieve.chinhoweyiin@my.wilmar-intl.com", "email_verified": false, "phone_verified": false}	email	2025-06-23 07:46:31.428861+00	2025-06-23 07:46:31.428897+00	2025-06-23 07:46:31.428897+00	2d58329f-4525-452d-aa4d-2727d482ec7f
6c383e4a-a52d-4661-8a6c-4be47b0ed340	6c383e4a-a52d-4661-8a6c-4be47b0ed340	{"sub": "6c383e4a-a52d-4661-8a6c-4be47b0ed340", "email": "eyz71@yahoo.com", "email_verified": false, "phone_verified": false}	email	2025-06-23 07:46:53.265023+00	2025-06-23 07:46:53.265056+00	2025-06-23 07:46:53.265056+00	b99161a1-2f16-45da-8463-4a4121838a05
8175ff46-a82f-41f1-9650-87661f8acbb1	8175ff46-a82f-41f1-9650-87661f8acbb1	{"sub": "8175ff46-a82f-41f1-9650-87661f8acbb1", "email": "hhelina@gmail.com", "email_verified": false, "phone_verified": false}	email	2025-06-23 07:47:12.291667+00	2025-06-23 07:47:12.291703+00	2025-06-23 07:47:12.291703+00	f66ac751-8171-4100-9857-a703b4e29ec8
59874f8b-4fdf-41ce-947b-da9240a861ca	59874f8b-4fdf-41ce-947b-da9240a861ca	{"sub": "59874f8b-4fdf-41ce-947b-da9240a861ca", "email": "patriciah@salcra.gov.my", "email_verified": false, "phone_verified": false}	email	2025-06-23 07:47:12.313081+00	2025-06-23 07:47:12.313115+00	2025-06-23 07:47:12.313115+00	aeaaaf17-31e9-4575-80e0-01d78ce1375d
13889f78-4916-4d07-8c07-faf25d913216	13889f78-4916-4d07-8c07-faf25d913216	{"sub": "13889f78-4916-4d07-8c07-faf25d913216", "email": "uttmill.office@gmail.com", "email_verified": false, "phone_verified": false}	email	2025-06-23 07:47:32.537647+00	2025-06-23 07:47:32.537686+00	2025-06-23 07:47:32.537686+00	b089c577-f2b0-4d97-9ee9-713bb53dd610
9ad14374-7580-4a86-a7e7-7e1450f96333	9ad14374-7580-4a86-a7e7-7e1450f96333	{"sub": "9ad14374-7580-4a86-a7e7-7e1450f96333", "email": "bapom01@salcra.gov.my", "email_verified": false, "phone_verified": false}	email	2025-06-23 07:48:00.335708+00	2025-06-23 07:48:00.335746+00	2025-06-23 07:48:00.335746+00	1025c333-6bbf-403a-8348-a6eac8ff4112
c31c618f-5148-41bb-802d-025b2b70965a	c31c618f-5148-41bb-802d-025b2b70965a	{"sub": "c31c618f-5148-41bb-802d-025b2b70965a", "email": "yc.lee@klkoleo.com", "email_verified": false, "phone_verified": false}	email	2025-06-23 07:48:23.002561+00	2025-06-23 07:48:23.002618+00	2025-06-23 07:48:23.002618+00	b05f050e-5678-4e3a-89db-4706e86203a5
a6ee5043-034b-496f-acc8-328104c06ed9	a6ee5043-034b-496f-acc8-328104c06ed9	{"sub": "a6ee5043-034b-496f-acc8-328104c06ed9", "email": "adstef82@gmail.com", "email_verified": false, "phone_verified": false}	email	2025-06-23 07:51:10.637488+00	2025-06-23 07:51:10.637524+00	2025-06-23 07:51:10.637524+00	2dbc29f1-f7ba-43b7-b1ab-182ca3846c61
60dea06c-f874-48fb-80ce-b71d2e65ba95	60dea06c-f874-48fb-80ce-b71d2e65ba95	{"sub": "60dea06c-f874-48fb-80ce-b71d2e65ba95", "email": "bpomsamling@gmail.com", "email_verified": false, "phone_verified": false}	email	2025-06-23 07:56:12.657848+00	2025-06-23 07:56:12.657886+00	2025-06-23 07:56:12.657886+00	a8a86255-f224-4c0e-867d-edf85109fa79
6d810e53-112a-4eac-a882-25b1e97a42b8	6d810e53-112a-4eac-a882-25b1e97a42b8	{"sub": "6d810e53-112a-4eac-a882-25b1e97a42b8", "email": "pptz_hilirperak1@yopmail.com", "email_verified": false, "phone_verified": false}	email	2025-06-27 04:21:39.250752+00	2025-06-27 04:21:39.250787+00	2025-06-27 04:21:39.250787+00	5475b2b7-99c3-4e40-95e2-d52cc8cf3e9f
545c44d3-4d8a-4511-8fc5-4aaf6e8de7b9	545c44d3-4d8a-4511-8fc5-4aaf6e8de7b9	{"sub": "545c44d3-4d8a-4511-8fc5-4aaf6e8de7b9", "email": "complainant_mspo1@yopmail.com", "email_verified": false, "phone_verified": false}	email	2025-06-27 08:03:58.308622+00	2025-06-27 08:03:58.308657+00	2025-06-27 08:03:58.308657+00	859f2339-a30d-498d-a39c-ae4d40b48fc8
f1b6d4f2-174f-4b2a-8c6c-d4531b128bfc	f1b6d4f2-174f-4b2a-8c6c-d4531b128bfc	{"sub": "f1b6d4f2-174f-4b2a-8c6c-d4531b128bfc", "email": "complainant_mspo2@yopmail.com", "email_verified": false, "phone_verified": false}	email	2025-06-27 08:18:52.55713+00	2025-06-27 08:18:52.557208+00	2025-06-27 08:18:52.557208+00	d10ad3ec-9bed-4dbf-991a-edf7423ac819
1dd6c4fe-a762-41d0-a940-959280c0e92a	1dd6c4fe-a762-41d0-a940-959280c0e92a	{"sub": "1dd6c4fe-a762-41d0-a940-959280c0e92a", "email": "complainant_mspo3@yopmail.com", "email_verified": false, "phone_verified": false}	email	2025-06-27 08:23:21.54894+00	2025-06-27 08:23:21.548974+00	2025-06-27 08:23:21.548974+00	b51dd390-1844-495e-b8d5-008803b7000b
73bc6611-cc9d-451f-94f4-855016beb48e	73bc6611-cc9d-451f-94f4-855016beb48e	{"sub": "73bc6611-cc9d-451f-94f4-855016beb48e", "email": "cng_elia@yopmail.com", "email_verified": false, "phone_verified": false}	email	2025-06-27 10:54:00.410058+00	2025-06-27 10:54:00.410097+00	2025-06-27 10:54:00.410097+00	c892516b-688a-4ecd-86af-f8371b7b0651
fcc7d82b-864c-43db-9975-ff689875c391	fcc7d82b-864c-43db-9975-ff689875c391	{"sub": "fcc7d82b-864c-43db-9975-ff689875c391", "email": "adindos@yopmail.com", "email_verified": false, "phone_verified": false}	email	2025-06-29 06:57:01.826568+00	2025-06-29 06:57:01.826611+00	2025-06-29 06:57:01.826611+00	3aa07e24-ce24-418b-9088-9753bc3959f6
\.


--
-- Data for Name: instances; Type: TABLE DATA; Schema: auth; Owner: -
--

COPY auth.instances (id, uuid, raw_base_config, created_at, updated_at) FROM stdin;
\.


--
-- Data for Name: mfa_amr_claims; Type: TABLE DATA; Schema: auth; Owner: -
--

COPY auth.mfa_amr_claims (session_id, created_at, updated_at, authentication_method, id) FROM stdin;
83b47c2f-1c81-42f0-a473-f79e0deae488	2025-06-15 14:38:32.839952+00	2025-06-15 14:38:32.839952+00	password	e98418ac-c68c-4367-93be-e890f68d8951
b8f0efc1-2af4-4329-9a18-98e16d06593f	2025-06-15 14:38:32.94369+00	2025-06-15 14:38:32.94369+00	password	b26ac4b1-7c09-41d4-bd19-d06c371a1630
da54bf07-62bc-4f4e-bef4-2c35f9ab04a2	2025-06-15 14:38:33.041459+00	2025-06-15 14:38:33.041459+00	password	6764791f-8bf4-46c3-8217-47b016e33e82
27302000-b402-4473-a048-5ebc530b65a6	2025-06-15 14:38:33.135925+00	2025-06-15 14:38:33.135925+00	password	3529effa-bd7a-4c12-b8c8-1db12d707eb0
65bfee21-0587-40b5-8340-71e496997539	2025-06-15 14:38:33.240238+00	2025-06-15 14:38:33.240238+00	password	ebc1b7f1-8fa0-4617-95dd-ec36b177da55
44d35abd-9e04-4c9e-9c69-b92593c926b8	2025-06-15 14:38:33.336457+00	2025-06-15 14:38:33.336457+00	password	9101a402-950e-44a5-9155-0d55ab7f5c52
a92504a5-d43f-4cc9-a6f6-59ee8369af8e	2025-06-15 14:38:33.433048+00	2025-06-15 14:38:33.433048+00	password	60fe8ee1-854e-4ad2-a465-4d17cb3e2e23
51f76af3-6823-46f6-b804-f1cbe491204b	2025-06-15 14:38:33.538338+00	2025-06-15 14:38:33.538338+00	password	937aa173-f50e-47a4-9614-de4cc383c164
8c1f691a-decb-4f68-89b4-e6ba0d765eca	2025-06-15 14:38:33.648504+00	2025-06-15 14:38:33.648504+00	password	e3adbe6e-0490-480a-b656-ff488e12a093
a2c8bd5a-10f2-456f-89e1-e67e052b4113	2025-06-15 14:38:33.751286+00	2025-06-15 14:38:33.751286+00	password	3a170e54-9619-400d-a364-e9b80ec911a3
96fd9d01-a3d2-4362-aa6d-e4eda224348b	2025-06-15 14:38:33.842785+00	2025-06-15 14:38:33.842785+00	password	21ab6fa0-cf1c-4081-bf2e-ca234c96daf6
c1a400b4-0814-4392-b3f2-bce23b192ead	2025-06-15 14:38:33.936719+00	2025-06-15 14:38:33.936719+00	password	12b3a45a-83dc-43df-bac9-a05768f03a28
38ac2ea6-d3e8-41e2-807e-f163b21c437d	2025-06-15 14:38:34.030569+00	2025-06-15 14:38:34.030569+00	password	b2b9ec72-5701-4389-b630-d7b9c2b48ac9
5a65b824-8260-4231-a490-c0f0bd2a00bc	2025-06-15 14:38:34.124642+00	2025-06-15 14:38:34.124642+00	password	aef6dc01-2fc3-4e90-bce3-afb8dd7ddec3
c88b8dfe-4441-41f4-a445-92ced4a41e03	2025-06-15 14:38:34.231816+00	2025-06-15 14:38:34.231816+00	password	d69e1602-86d4-437e-99cc-4c2c1dc7ec49
de49b6ee-a48c-4242-bde7-39da4850955f	2025-06-15 14:38:34.332381+00	2025-06-15 14:38:34.332381+00	password	190d9875-bfcf-4e1a-803e-d3be3b9d56c6
b16d2698-90aa-487c-967f-1aecbce9abe5	2025-06-15 14:38:34.424052+00	2025-06-15 14:38:34.424052+00	password	fa178b3d-3aaa-41c4-b6f5-ede47b8faaca
f1114368-61c3-4057-a493-afa9851aac73	2025-06-15 14:38:34.526052+00	2025-06-15 14:38:34.526052+00	password	e0062507-cdd7-498c-8209-02890025bc2d
36efb45e-c22d-4080-802b-40e33db9eb83	2025-06-15 14:38:34.619792+00	2025-06-15 14:38:34.619792+00	password	1de5ad4b-0e79-4497-b78b-f9efebd3a1bf
a7c890e9-9ff0-4287-9eaa-fc2c331f464c	2025-06-15 14:38:34.741313+00	2025-06-15 14:38:34.741313+00	password	023cab79-42d4-411c-a5d9-b547e1d51219
1f4bff19-be9c-4074-aef1-c64997ff9748	2025-06-15 14:38:34.842024+00	2025-06-15 14:38:34.842024+00	password	8d2e09a6-23dc-46e0-9e43-b0ecdf4c1513
241ad45f-a1b7-407d-aa0b-30825ce26b03	2025-06-15 14:38:34.935066+00	2025-06-15 14:38:34.935066+00	password	5179f044-a1e3-44cb-921f-e5f201420cf7
1ec204ad-ec06-49bd-bdb5-c3572902d684	2025-06-15 14:38:35.022623+00	2025-06-15 14:38:35.022623+00	password	a82e257d-71e9-4f1d-8f02-e6f4278532c1
8f7e028d-4cff-4c33-833b-d87852495bf6	2025-06-15 14:38:35.114024+00	2025-06-15 14:38:35.114024+00	password	dc28dcfb-95ec-4571-aaa7-ef05e349b69e
7101c805-8560-4a73-8a42-fc9a48f598f1	2025-06-15 14:38:35.209128+00	2025-06-15 14:38:35.209128+00	password	148f58ec-184d-4624-babc-28a4ebcc3964
1579b4f9-4445-4c8c-a51d-5725da6737dc	2025-06-15 14:38:35.310479+00	2025-06-15 14:38:35.310479+00	password	8cf3d8d5-d021-4e11-8b2d-26ee72487a55
4dffda68-8d40-477d-aeb3-f66b9ebfc285	2025-06-15 14:38:35.405915+00	2025-06-15 14:38:35.405915+00	password	63e54d8f-ce3a-48a8-a9b4-9e0eea3c46d2
7f420e2e-d0c9-4311-beab-798268faf057	2025-06-15 14:38:35.504207+00	2025-06-15 14:38:35.504207+00	password	d0940cb9-9551-42d0-bd5c-dbbfd221c31d
618f0ff1-8b81-4ba5-971d-d2ce5e5bfe9f	2025-06-15 14:38:35.603745+00	2025-06-15 14:38:35.603745+00	password	b7e227e0-9c1e-4ac9-ad06-899d512c3639
aa0383f2-e106-45c4-a716-feda25a6ec83	2025-06-15 14:38:35.698853+00	2025-06-15 14:38:35.698853+00	password	b4eb1169-ace5-481e-93ba-89513ad01fc0
2fa4ac6f-3441-4e81-8543-75d0165933df	2025-06-15 14:38:35.794561+00	2025-06-15 14:38:35.794561+00	password	f40b4ad8-f72e-4947-b02e-335025227662
5e02c7d9-7a97-477b-b20c-d51ab495fc29	2025-06-15 14:38:35.888485+00	2025-06-15 14:38:35.888485+00	password	28118735-1e43-44b6-b355-f40c31a44a05
f32442c1-9fca-4c4e-a59c-a81f4f24950e	2025-06-15 14:38:35.991791+00	2025-06-15 14:38:35.991791+00	password	6981a9d6-3094-4d0c-9bb0-552e85bbb346
c539e76c-cfd8-425d-a1ba-ee449a312e22	2025-06-15 14:38:36.08826+00	2025-06-15 14:38:36.08826+00	password	3437de99-bbd6-49ff-8ddb-f81e94746433
f7632760-0abc-4f3e-b60c-afa3c672e337	2025-06-15 14:38:36.181551+00	2025-06-15 14:38:36.181551+00	password	617af62a-5d20-44a6-b84b-a3709c4012c6
f066c0fa-d577-4353-ab01-59b3810da7cb	2025-06-15 14:38:36.277686+00	2025-06-15 14:38:36.277686+00	password	1831ee3c-bb40-4d75-a174-a49b8c857478
b405dbf2-4b93-43f8-abac-bbbaae099b85	2025-06-15 14:38:36.374219+00	2025-06-15 14:38:36.374219+00	password	f6189a74-5c08-42f9-a5f5-230ede5a8df3
7f1746a9-1a74-4fdd-8a47-46f1fda37650	2025-06-15 14:38:36.474084+00	2025-06-15 14:38:36.474084+00	password	24e2dcd5-a6aa-4ea1-bc8d-55e730a40541
9a38fcef-e16a-4d0f-8cd1-469a2d2dfdb4	2025-06-15 14:38:36.568808+00	2025-06-15 14:38:36.568808+00	password	47cb0fd2-f646-4398-905e-3a6f91b616b2
84d02d90-9188-4235-88d5-fbb30c69f6a5	2025-06-15 14:38:36.671874+00	2025-06-15 14:38:36.671874+00	password	c2f6fea5-167c-478d-af06-60fcc53a5c00
aac69f4b-028c-4850-b53b-a011b81c92d6	2025-06-15 14:38:36.765171+00	2025-06-15 14:38:36.765171+00	password	454cdfcd-c619-4d7b-99cc-c8f04fb8ea8f
cd199602-9f2f-4f99-8c38-f61914e1ed2e	2025-06-15 14:38:36.863606+00	2025-06-15 14:38:36.863606+00	password	bbfe9d0c-ddcb-4844-a437-f1dcbc564f82
db551758-9e36-4b57-a30b-0357800e694a	2025-06-15 14:38:36.957093+00	2025-06-15 14:38:36.957093+00	password	d6e1602e-9814-4cb9-ba79-2bfb216801a4
5d6e9b68-1c6a-44df-a1b3-7d822eae359e	2025-06-15 14:38:37.143279+00	2025-06-15 14:38:37.143279+00	password	550ada87-2c15-4487-a078-d3c6330aec33
0e98717d-4be6-4acc-8b0d-c545fa7b8141	2025-06-15 14:38:37.245169+00	2025-06-15 14:38:37.245169+00	password	98cb2421-5c93-45cc-8f15-f9885ab78651
36812ea8-18b8-4cb5-92a5-8d2284faa17a	2025-06-15 14:38:37.342541+00	2025-06-15 14:38:37.342541+00	password	80c05bbb-0ac5-48f3-9b1e-d96b420fdb40
a52086ca-5127-4033-b677-d388d3bccff7	2025-06-15 14:38:37.438656+00	2025-06-15 14:38:37.438656+00	password	0abfe8e9-cccb-4eee-ae70-d8156c856a9d
f3968c55-bcb3-4fa3-a3ea-648aa0c9e429	2025-06-15 14:38:37.529078+00	2025-06-15 14:38:37.529078+00	password	5f475ac0-dd34-40b7-a260-f34623dd0c5e
f5e38c61-2007-4c26-aa98-34d19d81803b	2025-06-15 14:38:37.6235+00	2025-06-15 14:38:37.6235+00	password	8d499e0b-abc2-41ee-b931-c3f9da789f39
8db827ad-6a40-46dc-8b6f-681772e0dc2e	2025-06-15 14:38:37.732228+00	2025-06-15 14:38:37.732228+00	password	1b74cbc7-5aeb-4b54-b2fe-874f4a6c5d95
a965a3bd-6ed7-402a-9f3f-99d36319e393	2025-06-15 14:38:37.824468+00	2025-06-15 14:38:37.824468+00	password	67ef11f4-9b74-4a8b-a7b0-f585fc0e1453
035bd06d-0d80-4ef3-8702-ca42e35679cb	2025-06-15 14:38:37.92747+00	2025-06-15 14:38:37.92747+00	password	cf7d6fbe-4ce0-4662-b671-2f1997203e40
cd93f4ec-cb6f-4cfb-9593-3ad1be6cd4e7	2025-06-15 14:38:38.030414+00	2025-06-15 14:38:38.030414+00	password	f0906bfd-04b7-4b5e-91ab-ba1c441708e7
593788b5-9131-427f-bec4-16e09b64209c	2025-06-15 14:38:38.123041+00	2025-06-15 14:38:38.123041+00	password	bb72286f-c925-4b69-8362-5dd569e1443b
13e258e1-f285-4b64-847e-4f3c4982e6e7	2025-06-15 14:38:38.219152+00	2025-06-15 14:38:38.219152+00	password	ab15fc6d-1d1e-4e2a-866a-f1c33c516c1f
684ea30d-843d-47ad-9326-4b427ba89899	2025-06-15 14:38:38.309481+00	2025-06-15 14:38:38.309481+00	password	634f4630-00d2-4ecd-be15-ef13e29330b1
9f15da1b-8935-4800-b63d-3f89b7898dc2	2025-06-15 14:38:38.405679+00	2025-06-15 14:38:38.405679+00	password	5fafd205-1a69-4fdd-80ec-9784cc3e33c2
5591f9be-d03d-4e3f-8692-6698c7c68c4d	2025-06-15 14:38:38.493686+00	2025-06-15 14:38:38.493686+00	password	93cfd57e-b805-4cd8-b5c2-80e85bb1ae78
e338edc8-5617-48a2-9b9e-f0f7ba7d9113	2025-06-15 14:38:38.585862+00	2025-06-15 14:38:38.585862+00	password	6b284355-4ccd-4c4a-8b2a-147b16af6490
eef49338-073d-4030-9f8f-be1a4a6e0771	2025-06-15 14:38:38.679479+00	2025-06-15 14:38:38.679479+00	password	f74056fd-067d-4b63-a1cc-850e88c27bc4
86b649f9-f05c-4a06-ba60-d9757d134e7e	2025-06-15 14:38:38.781971+00	2025-06-15 14:38:38.781971+00	password	92ebf492-e48d-4160-9830-e8393b27ad28
7b6acbcb-b4cf-4547-8bb5-f25a0b563ae1	2025-06-15 14:38:38.879359+00	2025-06-15 14:38:38.879359+00	password	7671e9d8-74e3-4f08-aaa0-493e404a3017
d0dc835d-968a-401b-a586-84744806fcb3	2025-06-15 14:38:38.979292+00	2025-06-15 14:38:38.979292+00	password	cff58557-9cb8-4503-94d0-d1bd32776d6c
4dc7f2f8-79ba-410c-904f-6295e832eb84	2025-06-15 14:38:39.071969+00	2025-06-15 14:38:39.071969+00	password	a7a29525-9b17-4ea1-a716-92849dad7df9
7e855504-d59c-4456-b5e2-3c9b2fd21114	2025-06-15 14:38:39.164485+00	2025-06-15 14:38:39.164485+00	password	44effc30-9baa-4f7b-87bd-fea374653306
463af394-8030-4ff7-bc7e-74713ac8627f	2025-06-15 14:38:39.268593+00	2025-06-15 14:38:39.268593+00	password	6d941d09-d133-493a-815e-8d5887fa7be9
52f16e75-757b-4178-82c7-72b54d145d9f	2025-06-15 14:38:39.367164+00	2025-06-15 14:38:39.367164+00	password	0ff627dd-29fe-48e6-9557-b0e64ec0614a
539b81cf-d375-448b-9de7-7ef0c66c2040	2025-06-15 14:38:39.466859+00	2025-06-15 14:38:39.466859+00	password	06d0986a-73ab-40d3-866f-457b71428c98
84b67e85-4871-4b8c-809e-7a75a5d299be	2025-06-15 14:38:39.565496+00	2025-06-15 14:38:39.565496+00	password	707897c4-180d-4635-8d90-d9568cf76cbc
d348e60f-9e10-4062-aa87-f32953690ad5	2025-06-15 14:38:39.663619+00	2025-06-15 14:38:39.663619+00	password	3793ff8a-fa07-46ae-9049-74966d2e56b3
a1a6d6ca-afde-42fd-a5a6-84b5f1588867	2025-06-15 14:38:39.77418+00	2025-06-15 14:38:39.77418+00	password	57dd7958-c549-4388-9305-797bff94166c
f5cefc28-e9fd-460c-aed5-f7282ba13407	2025-06-15 14:38:39.873728+00	2025-06-15 14:38:39.873728+00	password	9c73cd02-49da-4350-8f10-f85dddcb07a3
25a0ac93-428f-4941-9a7d-001518e49980	2025-06-15 14:38:39.969435+00	2025-06-15 14:38:39.969435+00	password	5832fbd2-4958-4431-9240-573f20d27d67
2b1cfd8a-c4ba-4ac0-a8e8-17ca04e7ec6c	2025-06-15 14:38:40.066098+00	2025-06-15 14:38:40.066098+00	password	235741b2-6c11-4f38-a595-d7b6c57d0ba9
4b186324-1322-4af1-91f6-55be20d380fa	2025-06-15 14:38:40.156329+00	2025-06-15 14:38:40.156329+00	password	cb68db31-5c28-4d6a-ac58-d553ddea577b
8cf9a821-e08d-431d-8740-d297bfd1915a	2025-06-15 14:38:40.248879+00	2025-06-15 14:38:40.248879+00	password	41f30c2b-04d5-406d-8ede-796de854c443
1fce5698-97d2-4833-9902-15be57024502	2025-06-15 14:38:40.345917+00	2025-06-15 14:38:40.345917+00	password	a608875d-73e7-4077-b5ef-718199242831
09a319fd-4201-4d52-9d7c-fdbeebf5b878	2025-06-15 14:38:40.447616+00	2025-06-15 14:38:40.447616+00	password	3ee993bc-a788-4928-9335-55ac8f8bb0b2
5ebb5f73-f433-4fc1-ab06-e1fd530c3f72	2025-06-15 14:38:40.540985+00	2025-06-15 14:38:40.540985+00	password	c11e09dc-7775-4c44-abad-0e1f70953b79
ea77802f-ee85-49dc-ba21-f5a4e75653b4	2025-06-15 14:38:40.636025+00	2025-06-15 14:38:40.636025+00	password	e63c264d-35e3-4a24-a73f-ccc1b27beaaa
18cf94ec-2de1-4d82-abc7-e7dba54967d1	2025-06-15 14:38:40.727521+00	2025-06-15 14:38:40.727521+00	password	1a9b0f9f-acd8-4ac0-b0f6-d8356613e050
be1ac062-24be-4b14-9c5a-6d19878a9e71	2025-06-15 14:38:40.819515+00	2025-06-15 14:38:40.819515+00	password	22ec69dc-85b8-414c-89dc-2f319967c518
6e22abed-080f-441f-ba80-fb744a7e8025	2025-06-15 14:38:40.921191+00	2025-06-15 14:38:40.921191+00	password	f45c2388-c2f0-4b45-bf86-38020895ba38
d30b712c-5641-4e3c-9988-0c040522fd04	2025-06-15 14:38:41.016085+00	2025-06-15 14:38:41.016085+00	password	97973934-802f-49f3-97d1-321cdda5e024
69478523-79ff-4000-b7bc-79d8ab82c7fc	2025-06-15 14:38:41.112915+00	2025-06-15 14:38:41.112915+00	password	7d506a26-4042-4e71-b446-292140b1ead5
94d1578e-0289-48e3-b538-4bf6a6c6ce4e	2025-06-15 14:38:41.208031+00	2025-06-15 14:38:41.208031+00	password	4a0f8547-92c1-4f45-920d-14b4c42061f5
6266a739-fca5-4399-9347-3d4729347e29	2025-06-15 14:38:41.302295+00	2025-06-15 14:38:41.302295+00	password	9b5ac715-154b-4ae8-aa0b-5e606355d7e8
114af36d-cf3e-46dc-a7da-535f09b60748	2025-06-15 14:38:41.391971+00	2025-06-15 14:38:41.391971+00	password	0b102832-bab1-41ba-aa1d-81daae467c36
22aa14b8-646e-40ad-92ac-86aa278885f8	2025-06-15 14:38:41.482438+00	2025-06-15 14:38:41.482438+00	password	3e90b650-ddb6-41ff-b22c-0c2c10657f6b
0ffcdc7f-e6c9-4e24-8102-7cf4510edc70	2025-06-15 14:38:41.581609+00	2025-06-15 14:38:41.581609+00	password	e6ea45f4-1415-43b1-9753-95e4c5173a27
925680c5-f408-4c0e-9009-9e35924af125	2025-06-15 14:38:41.672538+00	2025-06-15 14:38:41.672538+00	password	6aae75d1-5c5b-47cc-af84-47b67fe55f57
0300ce43-82b9-4045-9776-57092df2e429	2025-06-15 14:38:41.770887+00	2025-06-15 14:38:41.770887+00	password	dda436c6-9179-41a9-ab1d-64de7f19e9d5
a5dc11fb-8af0-4bb0-aecb-cf0fc8cb4a13	2025-06-15 14:38:41.871972+00	2025-06-15 14:38:41.871972+00	password	ce6dc090-6ae6-4aef-ae65-3b134874872e
5bf22f34-8d90-4d14-997b-50683b771b7e	2025-06-15 14:38:41.968327+00	2025-06-15 14:38:41.968327+00	password	9b77cf64-cff3-49a0-a747-8fe5a7dda8f5
15bd2547-76ef-4253-94fa-c92dc3f7bf71	2025-06-15 14:38:42.060911+00	2025-06-15 14:38:42.060911+00	password	116de026-2544-463d-a835-742af5cb7e67
c048950c-e803-4a90-be73-6be0f8b7bbfa	2025-06-15 14:38:42.157829+00	2025-06-15 14:38:42.157829+00	password	4a0c05b6-84ac-44f8-80c4-da561b0b6c6b
4d46961c-6ef7-4e49-92ab-c9bb1dec1ea9	2025-06-15 14:38:42.250031+00	2025-06-15 14:38:42.250031+00	password	d175e96d-3f6e-4516-9e2e-a40cf94cc92c
3051d6ee-1f6e-4708-ac85-99af82fd3283	2025-06-15 14:38:42.354089+00	2025-06-15 14:38:42.354089+00	password	928c1de2-d72e-47dc-8458-16eb66b1c015
6a06e0cc-7286-450f-9200-90f60a83b880	2025-06-15 14:38:42.450373+00	2025-06-15 14:38:42.450373+00	password	ad174e58-03c0-49f1-a532-030bbcb7fffc
955895f1-1a1f-4ff6-82e5-1d0536cfb1e9	2025-06-15 15:27:22.197136+00	2025-06-15 15:27:22.197136+00	password	c065fbb7-21f2-4b11-8914-a8c1ddb56870
7e382f3e-b658-4f4a-9b77-58e810ca5764	2025-06-18 02:09:49.683753+00	2025-06-18 02:09:49.683753+00	password	ee461ece-5bdf-4f57-922c-d8c91d0be2dd
82401c0e-53bd-4366-b603-47f7dceab31f	2025-06-18 02:12:53.845228+00	2025-06-18 02:12:53.845228+00	password	0db418c4-976c-4bdb-92c9-faf180db24c2
efb68f12-79b0-455b-9f15-a9ab33984d1a	2025-06-23 03:30:20.273128+00	2025-06-23 03:30:20.273128+00	password	064b9dd9-a449-4cba-b9e5-1fbd0bb6b115
5058bd72-d893-4089-b8d2-4716b76417c3	2025-06-23 05:49:16.724766+00	2025-06-23 05:49:16.724766+00	password	6f3a791d-bf51-4d00-869b-a030b0452c3c
b34856b8-4794-4701-a9a8-978a002cadc5	2025-06-23 07:40:12.644442+00	2025-06-23 07:40:12.644442+00	password	285fe203-a84f-445c-a9fa-74516083bea3
0e4828de-890a-4049-a76e-6649849e1fa4	2025-06-23 07:40:13.680646+00	2025-06-23 07:40:13.680646+00	password	c4e13fc2-5027-407b-a507-ec708d71d019
1f1e156d-40d6-422f-8967-ddea884ee4be	2025-06-23 07:40:45.982327+00	2025-06-23 07:40:45.982327+00	password	e57994f3-d250-4e8d-9de2-4a4e95329d89
c9bc747b-2090-48d2-bab7-c96f0827218c	2025-06-23 07:40:50.63456+00	2025-06-23 07:40:50.63456+00	password	e55df70f-4775-48c6-9cc1-912af8a03bff
7ea6f5b5-0c06-418c-ac38-ac63530b46e3	2025-06-23 07:41:53.958779+00	2025-06-23 07:41:53.958779+00	password	f48e0eca-3e04-4c14-a7a3-935d424348aa
287974ec-b8fd-49a1-87e6-1b573907dfa2	2025-06-23 07:41:59.342171+00	2025-06-23 07:41:59.342171+00	password	87538e80-e0f1-42f9-ae76-23ece869d65a
912238d3-fec6-49a3-acf0-d36999f94957	2025-06-23 07:42:01.104097+00	2025-06-23 07:42:01.104097+00	password	4a8dd37f-ce9c-4b39-a7b2-057920d16a63
b5909235-9f82-4f30-8cd9-708ab783d880	2025-06-23 07:42:25.113531+00	2025-06-23 07:42:25.113531+00	password	b2e00387-e0f0-4b92-84ed-10a786528702
51789518-b5e5-474d-bd6a-c6d24e877d2e	2025-06-23 07:42:27.068765+00	2025-06-23 07:42:27.068765+00	password	40bb5eeb-86b2-4893-abf8-a7361e7cae82
d28d6771-8507-4f58-96ff-669dc3bb8320	2025-06-23 07:42:27.471383+00	2025-06-23 07:42:27.471383+00	password	f0e60931-9bb6-4d80-8750-daa9c85e1ef1
ea1e938d-d79a-478c-aaad-4cba83b0dbcf	2025-06-23 07:42:35.157566+00	2025-06-23 07:42:35.157566+00	password	a8f0dcc6-2492-4624-873b-bc0cc215fde6
d01dcdbd-208b-483b-93c2-28ba38ac94f2	2025-06-23 07:42:35.316089+00	2025-06-23 07:42:35.316089+00	password	37cd9973-d7c6-4d7c-bfa0-ae6bb56b47f1
aef2f822-7459-4b19-a7c5-9124cc6357ae	2025-06-23 07:42:39.770734+00	2025-06-23 07:42:39.770734+00	password	d82eed90-e56a-46cb-8077-3b553e52b542
85b48456-18f7-40e2-be9a-57a1431c8d26	2025-06-23 07:42:41.781711+00	2025-06-23 07:42:41.781711+00	password	f2e9dfb6-b707-4b82-b163-078b06d185e8
3aea7dc8-47d2-43a9-bb4b-a6eac5c42e54	2025-06-23 07:42:52.936734+00	2025-06-23 07:42:52.936734+00	password	b3a1f8e5-d6e2-4fb1-abd6-e26f014c197f
8470770d-76f1-4d73-91b7-fa82d2e2d5e1	2025-06-23 07:43:02.127776+00	2025-06-23 07:43:02.127776+00	password	f93882d4-bc8a-4a95-9608-1b2012c4fca4
ac52d839-e71a-48b1-94d0-95f13e9f1978	2025-06-23 07:43:10.628348+00	2025-06-23 07:43:10.628348+00	password	9d456306-28a5-40b6-be30-64b43fc5e362
9a069c31-d0f1-4c9a-ab91-7e1632123f66	2025-06-23 07:43:26.710083+00	2025-06-23 07:43:26.710083+00	password	1c375e87-e64c-4d99-a213-368e0b554e7a
cd5320e6-739d-44ab-9dd2-b7c9e640e981	2025-06-23 07:43:52.638967+00	2025-06-23 07:43:52.638967+00	password	a8e45140-efe4-4e1f-a713-665d02212014
86573a3f-5f86-4914-8e73-ccf9f67cc9bf	2025-06-23 07:44:11.30265+00	2025-06-23 07:44:11.30265+00	password	75afdf2d-fae2-4b5c-a623-96a789cabf29
c16000a8-d9a2-4fe9-82fb-b06158494cad	2025-06-23 07:44:15.554133+00	2025-06-23 07:44:15.554133+00	password	b6e9e92a-064a-4350-92b1-d315868708e5
f3043ad1-34c9-44f8-97cc-21b19eeff073	2025-06-23 07:44:23.619594+00	2025-06-23 07:44:23.619594+00	password	f5497077-c85b-4989-9f3d-03231f8f1672
753af9c7-5823-4641-b570-8426301bf0ec	2025-06-23 07:44:36.501255+00	2025-06-23 07:44:36.501255+00	password	7aeb522a-9bf8-4817-a593-08e2a3798157
0c7a3acd-07ff-4323-8e09-083d46383d78	2025-06-23 07:44:40.292268+00	2025-06-23 07:44:40.292268+00	password	a96f2734-b746-4524-912e-06ac1346bf0d
7f876ce2-67d5-45dc-a032-0cdfc0affd72	2025-06-23 07:44:52.038459+00	2025-06-23 07:44:52.038459+00	password	e2705c38-ff5d-4e98-ac84-7ea0ba55c2d0
bc1a409c-1b65-4ea4-a742-366b7d180437	2025-06-23 07:44:52.389888+00	2025-06-23 07:44:52.389888+00	password	59b119d4-431b-44be-89d1-6a6789c1c215
1ffd9ad7-680c-491b-9648-5eef8aacb3cc	2025-06-23 07:45:00.741006+00	2025-06-23 07:45:00.741006+00	password	c1175a61-9bd5-45e2-b6c1-88b494044119
cfe63d34-0594-4dfe-a86c-8080d0b0e8e0	2025-06-23 07:45:13.476024+00	2025-06-23 07:45:13.476024+00	password	5b8c2253-7a5f-48de-8034-b498ff9f4c52
65846dba-299a-4ee4-872c-4721fd36bab4	2025-06-23 07:45:26.434643+00	2025-06-23 07:45:26.434643+00	password	68359917-0a5e-4e3e-8d0c-78f4201d3ec1
bd4d9ea5-d462-467e-919d-306e37aa7f8c	2025-06-23 07:45:27.893355+00	2025-06-23 07:45:27.893355+00	password	515543af-9d41-45bd-b9a0-7b432dc052c3
90bf53e9-8183-411f-9959-7b1cdfd3bfa6	2025-06-23 07:45:30.956994+00	2025-06-23 07:45:30.956994+00	password	660de481-c3e7-46df-bd2b-9861e1d15d79
592fd046-4bac-4927-b7d3-17a358e89f7f	2025-06-23 07:45:35.865906+00	2025-06-23 07:45:35.865906+00	password	dc78ffa0-1776-456f-a381-74351b52419f
965d164c-dbc2-4ec4-b988-89ba41752be4	2025-06-23 07:45:50.215232+00	2025-06-23 07:45:50.215232+00	password	10501b49-f77e-44e0-b13d-daae1d226d6e
7eb85347-6fef-4d38-ae44-292432a519a8	2025-06-23 07:45:55.12882+00	2025-06-23 07:45:55.12882+00	password	131ced4c-7f48-481f-8029-0e4a37ed4921
1a90df89-1c9f-46ef-9a5b-e78659533146	2025-06-23 07:46:01.258708+00	2025-06-23 07:46:01.258708+00	password	5c7d40d7-0296-468d-bfde-e02a63bf616c
c4bd5a60-1a47-4dd0-95f1-dca299b3d1f7	2025-06-23 07:46:05.227374+00	2025-06-23 07:46:05.227374+00	password	07febd66-a522-42ea-be28-c73e38f5fad5
eec2daee-4f23-4917-a85a-5356bff36e80	2025-06-23 07:46:08.171172+00	2025-06-23 07:46:08.171172+00	password	cbaa8404-b304-47ae-a519-aefa0ace264f
d0e9f4a5-aca5-4573-9074-71a53c6f42c9	2025-06-23 07:46:22.375449+00	2025-06-23 07:46:22.375449+00	password	fa5d213b-78f0-4d25-bdeb-1e04dc667336
b3b8d5d9-5a37-40db-b7f2-87461e8aba33	2025-06-23 07:46:31.434269+00	2025-06-23 07:46:31.434269+00	password	3f8186b2-4c19-4b2c-bd5f-f08880755ae8
af811759-bcd5-4155-b8fa-f9437789acb2	2025-06-23 07:46:53.270998+00	2025-06-23 07:46:53.270998+00	password	7f103c09-c669-4e66-80d0-73538c692ac3
f2e6d99d-3e50-4869-8cdb-dcb845e5a11f	2025-06-23 07:46:58.14191+00	2025-06-23 07:46:58.14191+00	password	eebf6907-1fdb-4424-9b7e-858fe787f964
4b4f4c43-f116-4c12-a61e-ccc7efb1cc4e	2025-06-23 07:47:12.296001+00	2025-06-23 07:47:12.296001+00	password	5269093d-8eed-4bf2-9304-9670909d021a
9d128b8a-4d51-483c-9194-80ce946f3bda	2025-06-23 07:47:12.31717+00	2025-06-23 07:47:12.31717+00	password	af7d6503-4c63-41a2-914a-2d6685e2d2ea
1d935b35-044b-4905-9c9a-8aeea5d93faa	2025-06-23 07:47:32.542257+00	2025-06-23 07:47:32.542257+00	password	53fea87a-d35a-4a69-a0cf-6ab31d03ff2e
e931c2a6-23fe-4015-9bc3-6421e0410b81	2025-06-23 07:47:36.222677+00	2025-06-23 07:47:36.222677+00	password	2527ee27-d5d2-4c6a-8ac3-bcf3dfe7100a
1b9f4822-7bd3-4c91-ab54-26d320856159	2025-06-23 07:48:00.341039+00	2025-06-23 07:48:00.341039+00	password	65212797-9371-4c18-9a20-fb1c307ae384
cd689551-d304-443c-b46f-5c6d1c818cb3	2025-06-23 07:48:23.007138+00	2025-06-23 07:48:23.007138+00	password	668b4ca3-8429-445a-bc81-ada73a6e3be5
d99f8e4c-19c1-414f-a337-3c27803f3c7e	2025-06-23 07:50:11.154976+00	2025-06-23 07:50:11.154976+00	password	e0294579-bacd-4a83-8336-99e426134ce5
1532b437-1a52-417b-9e61-dbfbdc0b88d1	2025-06-23 07:50:49.591168+00	2025-06-23 07:50:49.591168+00	password	7c59aeb7-c58a-4775-ae8e-ea8e0f0a2c07
0c6a685e-91e1-42bc-9d5d-23ef862fda71	2025-06-23 07:51:04.746514+00	2025-06-23 07:51:04.746514+00	password	bb10481f-bc78-481f-b06f-f2b63bf752c4
3977c47c-a631-42f6-b3e2-362e0fa99c5b	2025-06-23 07:51:06.862174+00	2025-06-23 07:51:06.862174+00	password	fbc90954-61ab-40a8-a7ab-5efc103946af
e867c70d-26ca-4340-93de-8b4fb2263c95	2025-06-23 07:51:10.642477+00	2025-06-23 07:51:10.642477+00	password	a2c6dd4e-b3e5-4cda-bfec-38888c34ed75
34c4690d-2fc4-4af9-a091-1018463878c8	2025-06-23 07:51:23.777553+00	2025-06-23 07:51:23.777553+00	password	33ec44ea-f8e3-41bc-a374-0ee97ba534ee
778482ed-f101-471f-977f-b58f904746e4	2025-06-23 07:52:06.717562+00	2025-06-23 07:52:06.717562+00	password	da32be30-54a1-41ec-90ad-e2ba4be84ec4
bb335723-588d-41f9-b329-aa02dd719102	2025-06-23 07:52:48.199365+00	2025-06-23 07:52:48.199365+00	password	9039e16c-34c4-4394-9357-0ceaf572288f
a6b36d0d-53bf-4a0b-b8a4-74a0f75552b0	2025-06-23 07:52:49.605921+00	2025-06-23 07:52:49.605921+00	password	9dadd436-5f05-4304-ab1c-71f0907c658a
f2188aff-bf53-4f90-a44a-9ed70faf9a6b	2025-06-23 07:53:12.367089+00	2025-06-23 07:53:12.367089+00	password	2d364942-46ac-4030-bf80-5a3ecceca3a0
51f0a42e-d3f4-437b-8912-58626cbdf959	2025-06-23 07:53:16.100319+00	2025-06-23 07:53:16.100319+00	password	ec3a8c01-e45e-4bbc-86b4-1ba92513cda1
b0983811-a44f-4de2-8897-92eb94b25a9b	2025-06-23 07:53:22.94848+00	2025-06-23 07:53:22.94848+00	password	3168c1b7-07aa-4242-9341-3eaca5372067
9acca783-5aee-46cb-8b93-dad72f8ce960	2025-06-23 07:53:24.211845+00	2025-06-23 07:53:24.211845+00	password	ae65cdaa-95e0-46db-b87d-89021e230a67
d8894cde-66dc-404c-a8c3-fcb7e53db79b	2025-06-23 07:54:08.537347+00	2025-06-23 07:54:08.537347+00	password	9a4385af-caa8-465c-a550-fed68cff6546
4062b000-51fe-4ddd-bba0-e7f13308f797	2025-06-23 07:55:24.748445+00	2025-06-23 07:55:24.748445+00	password	a2a56833-61f1-41ca-8085-2ceda990969a
17850380-73d4-47ce-8526-681f8e0f4424	2025-06-23 07:55:28.578227+00	2025-06-23 07:55:28.578227+00	password	7acb23f1-31a4-434d-a63d-0f50c234f4b8
0967906a-3d96-4158-a6c5-f6e1ed8a1930	2025-06-23 07:55:39.191829+00	2025-06-23 07:55:39.191829+00	password	a426bb33-0776-4f17-a2c2-0311e40995fb
6e63b7dc-1583-4b05-812b-800255167285	2025-06-23 07:56:04.739128+00	2025-06-23 07:56:04.739128+00	password	c0526070-3ef4-4be9-b585-f4148f13897f
2cf3d60f-23b1-4297-8711-4a95a4e2c1a5	2025-06-23 07:56:12.665999+00	2025-06-23 07:56:12.665999+00	password	43f5af5c-c831-42db-a21d-b9551752bfc1
95280d85-278d-4051-b0e3-e71deafb998f	2025-06-23 07:56:17.969119+00	2025-06-23 07:56:17.969119+00	password	65a20970-3896-44c6-afcd-aa3539b255fd
4b1eb4cb-350e-4d7e-89a4-d96c442b4879	2025-06-23 07:56:55.013057+00	2025-06-23 07:56:55.013057+00	password	a6e6c185-5d13-45ff-a81c-83ec23746d77
f17ff1b3-96ba-413c-ab2f-c90695e8acbc	2025-06-23 07:57:16.066364+00	2025-06-23 07:57:16.066364+00	password	048adbd3-19bf-45f0-9012-8a63d5085ec0
faaa7831-168e-4a70-85f2-32159a10a646	2025-06-23 07:57:58.742356+00	2025-06-23 07:57:58.742356+00	password	e6239364-ad6d-4142-99b0-d6a691fe78e8
25080e68-9d78-4c9a-9839-fae09373ad2d	2025-06-23 07:58:31.487273+00	2025-06-23 07:58:31.487273+00	password	c72a79a5-4964-43ec-9aa0-732c28c5fda1
c026b23f-c0bd-4892-9378-05789447cb03	2025-06-23 08:00:50.527467+00	2025-06-23 08:00:50.527467+00	password	9e991134-8dd9-4d60-b7b2-63782856f7c3
037105e9-7093-4c7d-8b96-115dd98bee91	2025-06-23 08:04:20.275024+00	2025-06-23 08:04:20.275024+00	password	0ae1d538-9dba-4bf9-a5d4-46d1223b7fe5
3c9bdd62-beb8-47d7-aac0-4460fa17c767	2025-06-27 08:18:52.562678+00	2025-06-27 08:18:52.562678+00	password	8dad151a-cf05-4a6c-a649-8cac40018dca
581f049b-5104-45aa-a670-243866b5b1e9	2025-06-27 10:54:00.415252+00	2025-06-27 10:54:00.415252+00	password	3c06d9a2-0f42-4e47-9260-24ce9aa4d0f5
4794b543-ec8e-4ca7-bb06-316c1fe77f43	2025-06-27 10:54:18.487824+00	2025-06-27 10:54:18.487824+00	password	289f569c-e07b-443e-8d61-1817b2564719
9d384b5f-80c2-4bf8-b3b1-07b753249a73	2025-06-27 10:59:44.307065+00	2025-06-27 10:59:44.307065+00	password	a526140a-05d3-43b7-8fe2-72cfae36eade
af9c3956-3930-4d7a-b8cb-176b16e11c49	2025-06-27 11:26:45.674691+00	2025-06-27 11:26:45.674691+00	password	136b52ff-7bd4-4f97-9201-e477f6de499d
b4253a4e-0af0-4d12-8a35-af0bddfd46c9	2025-06-27 13:54:21.150594+00	2025-06-27 13:54:21.150594+00	password	915343bd-9eb8-49dd-847b-5a8a04959698
1cd8aacd-f1b6-4703-912b-a19bcd8a697d	2025-06-27 13:56:27.467699+00	2025-06-27 13:56:27.467699+00	password	c8157011-489b-4199-bf7d-3d690644a771
923cbae7-a9c3-4f99-be45-4d00ed3532f7	2025-06-27 14:20:23.545376+00	2025-06-27 14:20:23.545376+00	password	1fa28819-5219-447b-ba49-b634e6ee1c41
52aa85e0-4c4d-46b6-aaed-6c5dc94f334a	2025-06-27 14:37:01.414312+00	2025-06-27 14:37:01.414312+00	password	86b1cdb6-28a6-4c2b-8fe2-1eb430f0446b
c4ef89cc-67ff-46f8-b046-ca0a8d9010ef	2025-06-27 14:49:16.144469+00	2025-06-27 14:49:16.144469+00	password	cbe5b390-2816-40cb-a2bb-7dd5ceea21e9
34d3d3d1-900f-4c0d-9966-589784e0135a	2025-06-29 06:57:01.869656+00	2025-06-29 06:57:01.869656+00	password	a7c80613-bb6a-4d65-8ae8-2a53736b97b5
81767909-8727-49b2-840f-f1384043b150	2025-06-29 06:57:20.605917+00	2025-06-29 06:57:20.605917+00	password	c1ad0d8a-895e-4b7c-be60-53afb4dc7bfb
\.


--
-- Data for Name: mfa_challenges; Type: TABLE DATA; Schema: auth; Owner: -
--

COPY auth.mfa_challenges (id, factor_id, created_at, verified_at, ip_address, otp_code, web_authn_session_data) FROM stdin;
\.


--
-- Data for Name: mfa_factors; Type: TABLE DATA; Schema: auth; Owner: -
--

COPY auth.mfa_factors (id, user_id, friendly_name, factor_type, status, created_at, updated_at, secret, phone, last_challenged_at, web_authn_credential, web_authn_aaguid) FROM stdin;
\.


--
-- Data for Name: one_time_tokens; Type: TABLE DATA; Schema: auth; Owner: -
--

COPY auth.one_time_tokens (id, user_id, token_type, token_hash, relates_to, created_at, updated_at) FROM stdin;
\.


--
-- Data for Name: refresh_tokens; Type: TABLE DATA; Schema: auth; Owner: -
--

COPY auth.refresh_tokens (instance_id, id, token, user_id, revoked, created_at, updated_at, parent, session_id) FROM stdin;
00000000-0000-0000-0000-000000000000	368	o5WLSSJrzfiviznovEgJKg	a007885a-80b3-4486-b31c-6652abca3e12	t	2025-06-23 03:30:20.272305+00	2025-06-23 05:43:29.985337+00	\N	efb68f12-79b0-455b-9f15-a9ab33984d1a
00000000-0000-0000-0000-000000000000	369	4Syb8W1bquf_c_vaT-QExg	a007885a-80b3-4486-b31c-6652abca3e12	t	2025-06-23 05:43:29.985659+00	2025-06-23 07:15:50.605352+00	o5WLSSJrzfiviznovEgJKg	efb68f12-79b0-455b-9f15-a9ab33984d1a
00000000-0000-0000-0000-000000000000	371	rJ3KzE7SbmZi1eRE6SxX_w	a007885a-80b3-4486-b31c-6652abca3e12	f	2025-06-23 07:15:50.605601+00	2025-06-23 07:15:50.605601+00	4Syb8W1bquf_c_vaT-QExg	efb68f12-79b0-455b-9f15-a9ab33984d1a
00000000-0000-0000-0000-000000000000	372	YkSGSEyZL1OA7HESAluMmA	8bc44ea0-2e33-458a-ac4d-298980c44b05	f	2025-06-23 07:40:12.643679+00	2025-06-23 07:40:12.643679+00	\N	b34856b8-4794-4701-a9a8-978a002cadc5
00000000-0000-0000-0000-000000000000	373	mGFahqjFas12OeoueLvBRQ	e2c36046-d53b-4a02-9eef-f85a47d6c357	f	2025-06-23 07:40:13.679922+00	2025-06-23 07:40:13.679922+00	\N	0e4828de-890a-4049-a76e-6649849e1fa4
00000000-0000-0000-0000-000000000000	375	YiwhQDNHsz5ppRCQlNb_Qw	20754c43-864b-45c9-8e9d-5f71b3dceb39	f	2025-06-23 07:40:45.981502+00	2025-06-23 07:40:45.981502+00	\N	1f1e156d-40d6-422f-8967-ddea884ee4be
00000000-0000-0000-0000-000000000000	219	oXV35j_Ht9kYyL6Xar-paA	b7592049-9546-4bd4-9bc7-33d77d747af0	f	2025-06-15 14:38:32.839136+00	2025-06-15 14:38:32.839136+00	\N	83b47c2f-1c81-42f0-a473-f79e0deae488
00000000-0000-0000-0000-000000000000	220	DWdi77aVuLKXTvijzKeOAQ	663cd7e5-73f0-4c16-b7a8-a579107fda69	f	2025-06-15 14:38:32.942874+00	2025-06-15 14:38:32.942874+00	\N	b8f0efc1-2af4-4329-9a18-98e16d06593f
00000000-0000-0000-0000-000000000000	221	OHIqgCjoiSONw_sZkm3rsg	081efe3b-09b5-4e34-9194-cbcb30cc77d9	f	2025-06-15 14:38:33.040738+00	2025-06-15 14:38:33.040738+00	\N	da54bf07-62bc-4f4e-bef4-2c35f9ab04a2
00000000-0000-0000-0000-000000000000	222	bidyjkKqVzZa6TBXe6sH5A	5de03212-53a6-465c-857b-34e113374e81	f	2025-06-15 14:38:33.135194+00	2025-06-15 14:38:33.135194+00	\N	27302000-b402-4473-a048-5ebc530b65a6
00000000-0000-0000-0000-000000000000	223	zYI2ds--4Z5wbLc9jIKB6w	1207343f-7e2b-4f82-88ed-7b559f837c08	f	2025-06-15 14:38:33.239596+00	2025-06-15 14:38:33.239596+00	\N	65bfee21-0587-40b5-8340-71e496997539
00000000-0000-0000-0000-000000000000	224	TRnnQ9SlnO-RxRXQ1UY_pg	884b5358-cd7d-4b03-84af-fde5a996ac76	f	2025-06-15 14:38:33.335793+00	2025-06-15 14:38:33.335793+00	\N	44d35abd-9e04-4c9e-9c69-b92593c926b8
00000000-0000-0000-0000-000000000000	225	4S0Lz_K4FgQSH7uM7b19JA	9c533f9b-0de2-4184-8679-ac4124139717	f	2025-06-15 14:38:33.432379+00	2025-06-15 14:38:33.432379+00	\N	a92504a5-d43f-4cc9-a6f6-59ee8369af8e
00000000-0000-0000-0000-000000000000	226	OwjMJJFkACeJxXBtz5ZCSg	46f9cd41-b08e-4e32-81eb-bb1d3323b3b2	f	2025-06-15 14:38:33.537387+00	2025-06-15 14:38:33.537387+00	\N	51f76af3-6823-46f6-b804-f1cbe491204b
00000000-0000-0000-0000-000000000000	227	Fvpr6eLqaD-jQfyK6gFq2g	4d6dc0fa-8a2f-4073-9bbd-85425124beb0	f	2025-06-15 14:38:33.647838+00	2025-06-15 14:38:33.647838+00	\N	8c1f691a-decb-4f68-89b4-e6ba0d765eca
00000000-0000-0000-0000-000000000000	228	i2pskPlN1CKxhjSAdIm9nA	e81e22aa-0578-4fb2-8d0b-5665be08b8ee	f	2025-06-15 14:38:33.750592+00	2025-06-15 14:38:33.750592+00	\N	a2c8bd5a-10f2-456f-89e1-e67e052b4113
00000000-0000-0000-0000-000000000000	229	5Njk8WPApDEPXnQalxQpzQ	bf3f6921-ab2d-4b8b-936f-38da5143c31d	f	2025-06-15 14:38:33.842091+00	2025-06-15 14:38:33.842091+00	\N	96fd9d01-a3d2-4362-aa6d-e4eda224348b
00000000-0000-0000-0000-000000000000	230	juvxUmZ0Q0PhbWtsLX3FQQ	3d06ba74-5af0-499d-81fa-6a61febaa57d	f	2025-06-15 14:38:33.936+00	2025-06-15 14:38:33.936+00	\N	c1a400b4-0814-4392-b3f2-bce23b192ead
00000000-0000-0000-0000-000000000000	231	XoE90Hqt5PlDp4SsXiGO-w	d0e4fb36-fb0a-4767-a333-531cbb37e035	f	2025-06-15 14:38:34.029854+00	2025-06-15 14:38:34.029854+00	\N	38ac2ea6-d3e8-41e2-807e-f163b21c437d
00000000-0000-0000-0000-000000000000	232	nhKOByTm2s0AqDnD47WubA	cedde969-4985-499b-a05c-5325099bf7aa	f	2025-06-15 14:38:34.123856+00	2025-06-15 14:38:34.123856+00	\N	5a65b824-8260-4231-a490-c0f0bd2a00bc
00000000-0000-0000-0000-000000000000	233	ChiMgn68LMkvGq1yVHHt5A	13b7d6b3-42a7-40ec-b227-f1b91f791dcc	f	2025-06-15 14:38:34.231107+00	2025-06-15 14:38:34.231107+00	\N	c88b8dfe-4441-41f4-a445-92ced4a41e03
00000000-0000-0000-0000-000000000000	234	KLAIWJC-_i7iI6ueQRdWsA	4287988f-93ab-4a3c-9790-77473ef7f799	f	2025-06-15 14:38:34.33155+00	2025-06-15 14:38:34.33155+00	\N	de49b6ee-a48c-4242-bde7-39da4850955f
00000000-0000-0000-0000-000000000000	235	KvpMglmBzhJgTwEfWPqZjQ	12c58e57-7eb9-4e61-a298-52c44ab6e5e2	f	2025-06-15 14:38:34.423354+00	2025-06-15 14:38:34.423354+00	\N	b16d2698-90aa-487c-967f-1aecbce9abe5
00000000-0000-0000-0000-000000000000	236	f1mEhYHpQ0SOBojX-MqWzw	f36f7e40-f5fb-4c87-a096-a88c211d6bd2	f	2025-06-15 14:38:34.52535+00	2025-06-15 14:38:34.52535+00	\N	f1114368-61c3-4057-a493-afa9851aac73
00000000-0000-0000-0000-000000000000	237	pnWvvn2gY3r-FXsvl4gyWQ	812c46f2-6962-4df8-90c0-f5dee109c540	f	2025-06-15 14:38:34.619073+00	2025-06-15 14:38:34.619073+00	\N	36efb45e-c22d-4080-802b-40e33db9eb83
00000000-0000-0000-0000-000000000000	238	K5Oey2h7NL2Q111lYK6Rxw	a54f43bc-3510-4267-9c02-de241f28979b	f	2025-06-15 14:38:34.740438+00	2025-06-15 14:38:34.740438+00	\N	a7c890e9-9ff0-4287-9eaa-fc2c331f464c
00000000-0000-0000-0000-000000000000	239	4vZ1peHNPJV2TTMpotKiyQ	ded6488b-469e-484e-b815-a00534d3e10f	f	2025-06-15 14:38:34.841263+00	2025-06-15 14:38:34.841263+00	\N	1f4bff19-be9c-4074-aef1-c64997ff9748
00000000-0000-0000-0000-000000000000	240	FvmvpaZJAOrufGYGhlO4Pg	c0c0c1da-11f3-4065-aa98-82084870eea4	f	2025-06-15 14:38:34.934415+00	2025-06-15 14:38:34.934415+00	\N	241ad45f-a1b7-407d-aa0b-30825ce26b03
00000000-0000-0000-0000-000000000000	241	4YGeod2K6oedLwJxs5JNlA	e0cf9d78-629a-4f0c-8c5e-d4eb659c758a	f	2025-06-15 14:38:35.021952+00	2025-06-15 14:38:35.021952+00	\N	1ec204ad-ec06-49bd-bdb5-c3572902d684
00000000-0000-0000-0000-000000000000	242	5qjOVjeO19DRI9z0bX3YdQ	0f718b43-671c-4b6f-b906-34ee7b45b4b2	f	2025-06-15 14:38:35.113288+00	2025-06-15 14:38:35.113288+00	\N	8f7e028d-4cff-4c33-833b-d87852495bf6
00000000-0000-0000-0000-000000000000	243	Ue5WgTpaf5OiYQ1ojART_A	c3430ef8-bea7-4d77-840d-7e1847682f45	f	2025-06-15 14:38:35.208409+00	2025-06-15 14:38:35.208409+00	\N	7101c805-8560-4a73-8a42-fc9a48f598f1
00000000-0000-0000-0000-000000000000	244	dNoZbDpZxwaUqz8Om0iQ5w	0dfa2c7d-310b-4a83-98f5-197421843955	f	2025-06-15 14:38:35.309686+00	2025-06-15 14:38:35.309686+00	\N	1579b4f9-4445-4c8c-a51d-5725da6737dc
00000000-0000-0000-0000-000000000000	245	JSmcAnp0Bz7XdkFMv6uvTQ	b0b2df8d-3835-4d06-a95d-d6a376b95ea1	f	2025-06-15 14:38:35.405193+00	2025-06-15 14:38:35.405193+00	\N	4dffda68-8d40-477d-aeb3-f66b9ebfc285
00000000-0000-0000-0000-000000000000	246	3_9hfnF79rKYMfL_sCpRzA	1f99b32d-2a96-4760-b450-ed45b0abe4d1	f	2025-06-15 14:38:35.503562+00	2025-06-15 14:38:35.503562+00	\N	7f420e2e-d0c9-4311-beab-798268faf057
00000000-0000-0000-0000-000000000000	247	OpT0HcQ1ei3tgWvAnVBNHg	1b9260e9-b2bc-4ac3-86ed-cd13d669bd46	f	2025-06-15 14:38:35.602982+00	2025-06-15 14:38:35.602982+00	\N	618f0ff1-8b81-4ba5-971d-d2ce5e5bfe9f
00000000-0000-0000-0000-000000000000	248	5qHVMKA6U9VvIEORGgRaGQ	457acf64-4b5a-49a5-8f67-2aa577cec7ec	f	2025-06-15 14:38:35.6981+00	2025-06-15 14:38:35.6981+00	\N	aa0383f2-e106-45c4-a716-feda25a6ec83
00000000-0000-0000-0000-000000000000	249	ilTq8QQxBHJ6KqsmEW0MNw	f22bd07e-28a0-4135-b73e-fb6629087485	f	2025-06-15 14:38:35.793876+00	2025-06-15 14:38:35.793876+00	\N	2fa4ac6f-3441-4e81-8543-75d0165933df
00000000-0000-0000-0000-000000000000	250	Sp6NWPCXu-ABUlX-ZnkfXA	80708127-7fdf-4c9d-8b6f-315c374c0cf4	f	2025-06-15 14:38:35.887611+00	2025-06-15 14:38:35.887611+00	\N	5e02c7d9-7a97-477b-b20c-d51ab495fc29
00000000-0000-0000-0000-000000000000	251	_fLF7uoqbxHmUeTukFP-aQ	536203a3-6335-4c60-ae6f-f852135c5419	f	2025-06-15 14:38:35.991124+00	2025-06-15 14:38:35.991124+00	\N	f32442c1-9fca-4c4e-a59c-a81f4f24950e
00000000-0000-0000-0000-000000000000	252	N7w78roR1o50pFK5anwuag	4da24124-a1ef-4efe-832d-a89ddfd8945a	f	2025-06-15 14:38:36.087475+00	2025-06-15 14:38:36.087475+00	\N	c539e76c-cfd8-425d-a1ba-ee449a312e22
00000000-0000-0000-0000-000000000000	253	WWyRH-GACUZ-bXlMF1qGwQ	3ce70501-e74f-4420-bc0a-3eac51f2dbe4	f	2025-06-15 14:38:36.180774+00	2025-06-15 14:38:36.180774+00	\N	f7632760-0abc-4f3e-b60c-afa3c672e337
00000000-0000-0000-0000-000000000000	254	ZsYYXnF-fixWuC4bZHuUPg	d8d76d24-14d4-4e46-92ad-5907d27fe2e0	f	2025-06-15 14:38:36.277023+00	2025-06-15 14:38:36.277023+00	\N	f066c0fa-d577-4353-ab01-59b3810da7cb
00000000-0000-0000-0000-000000000000	255	16bZyjKdJoog6HBnWAsdXw	e80a6ccf-333b-407f-ae20-ae04ee67f667	f	2025-06-15 14:38:36.373532+00	2025-06-15 14:38:36.373532+00	\N	b405dbf2-4b93-43f8-abac-bbbaae099b85
00000000-0000-0000-0000-000000000000	256	v1BhlY74uFksWNY7qFHpSg	7c42038f-aa20-4f20-ba43-839d3474a560	f	2025-06-15 14:38:36.473308+00	2025-06-15 14:38:36.473308+00	\N	7f1746a9-1a74-4fdd-8a47-46f1fda37650
00000000-0000-0000-0000-000000000000	257	4BmYUnH_iTkaMuDm2AoxSw	a0b845cc-2c32-421e-9f3e-ebfe8e22cd15	f	2025-06-15 14:38:36.568123+00	2025-06-15 14:38:36.568123+00	\N	9a38fcef-e16a-4d0f-8cd1-469a2d2dfdb4
00000000-0000-0000-0000-000000000000	376	6Jou7_FspiVMO0Bzl-ASzA	a1008ee6-6805-4d56-956d-0bcaad374870	f	2025-06-23 07:40:50.633852+00	2025-06-23 07:40:50.633852+00	\N	c9bc747b-2090-48d2-bab7-c96f0827218c
00000000-0000-0000-0000-000000000000	370	E1u8Squanwol1KEsnZ4IuA	a007885a-80b3-4486-b31c-6652abca3e12	t	2025-06-23 05:49:16.72404+00	2025-06-23 07:41:38.938374+00	\N	5058bd72-d893-4089-b8d2-4716b76417c3
00000000-0000-0000-0000-000000000000	410	HGHIDC5B2J1jKsWaCApSPw	08a2cbdf-9a26-4469-9034-ed7b3f5b73e9	f	2025-06-23 07:46:05.226578+00	2025-06-23 07:46:05.226578+00	\N	c4bd5a60-1a47-4dd0-95f1-dca299b3d1f7
00000000-0000-0000-0000-000000000000	411	evVfK-UvyDA_AVEwvpuQcw	7d693d50-00d4-4a9b-9bc0-35afebbb30d9	f	2025-06-23 07:46:08.170421+00	2025-06-23 07:46:08.170421+00	\N	eec2daee-4f23-4917-a85a-5356bff36e80
00000000-0000-0000-0000-000000000000	412	LYr7rWogKkB2fzROC08tJw	7f05337a-1f10-411a-8c90-ab632faaf8c2	f	2025-06-23 07:46:22.37462+00	2025-06-23 07:46:22.37462+00	\N	d0e9f4a5-aca5-4573-9074-71a53c6f42c9
00000000-0000-0000-0000-000000000000	258	Bx6Ivl6CVIcGHl24nlqjWg	e5871981-e66c-4c44-9183-0e8084e874c9	f	2025-06-15 14:38:36.670981+00	2025-06-15 14:38:36.670981+00	\N	84d02d90-9188-4235-88d5-fbb30c69f6a5
00000000-0000-0000-0000-000000000000	259	idcmdK6gtIbt31Md4ScedA	582f5571-b638-444b-9527-12503ce384a3	f	2025-06-15 14:38:36.764513+00	2025-06-15 14:38:36.764513+00	\N	aac69f4b-028c-4850-b53b-a011b81c92d6
00000000-0000-0000-0000-000000000000	260	PwlgLE4DvKLLvOSwp_a4SA	05039a36-049a-47b0-9e99-6de64a44acbd	f	2025-06-15 14:38:36.86288+00	2025-06-15 14:38:36.86288+00	\N	cd199602-9f2f-4f99-8c38-f61914e1ed2e
00000000-0000-0000-0000-000000000000	261	f0548G33MlTLXh1tzC9OiA	14e4c67b-bcde-4704-a97f-0dcbe1717dc5	f	2025-06-15 14:38:36.956368+00	2025-06-15 14:38:36.956368+00	\N	db551758-9e36-4b57-a30b-0357800e694a
00000000-0000-0000-0000-000000000000	377	uG2YT1zw9Wb6X9U2cIdeRg	a007885a-80b3-4486-b31c-6652abca3e12	f	2025-06-23 07:41:38.9387+00	2025-06-23 07:41:38.9387+00	E1u8Squanwol1KEsnZ4IuA	5058bd72-d893-4089-b8d2-4716b76417c3
00000000-0000-0000-0000-000000000000	263	u8N40Xtj2cShrpSmCwuYFQ	34e9281c-a3b1-412d-ba7e-fe29dad024c9	f	2025-06-15 14:38:37.142182+00	2025-06-15 14:38:37.142182+00	\N	5d6e9b68-1c6a-44df-a1b3-7d822eae359e
00000000-0000-0000-0000-000000000000	264	s2wcqNROXdG3mFvC0hmWtA	8d6c1385-fa01-48c7-b761-4e0ebdcab162	f	2025-06-15 14:38:37.244428+00	2025-06-15 14:38:37.244428+00	\N	0e98717d-4be6-4acc-8b0d-c545fa7b8141
00000000-0000-0000-0000-000000000000	265	0KESxoq9CuJt27X-UJOIdg	d8b08679-718a-49dc-a81d-141d5a5b048d	f	2025-06-15 14:38:37.341854+00	2025-06-15 14:38:37.341854+00	\N	36812ea8-18b8-4cb5-92a5-8d2284faa17a
00000000-0000-0000-0000-000000000000	266	bcsRG2F83s2cO4o3ZJv7hg	54003f0f-9dc2-4142-a7a3-37781c6caa2f	f	2025-06-15 14:38:37.437922+00	2025-06-15 14:38:37.437922+00	\N	a52086ca-5127-4033-b677-d388d3bccff7
00000000-0000-0000-0000-000000000000	267	Dn4XYTlbjJJo8r1qj80F9w	0a7806d8-7b08-4629-bcfc-b5304bc684c4	f	2025-06-15 14:38:37.528323+00	2025-06-15 14:38:37.528323+00	\N	f3968c55-bcb3-4fa3-a3ea-648aa0c9e429
00000000-0000-0000-0000-000000000000	268	5Xz365I2jaNw-Hs48RwOoQ	2abe0ef5-50a6-4f32-bcd0-ccbb192771c5	f	2025-06-15 14:38:37.622808+00	2025-06-15 14:38:37.622808+00	\N	f5e38c61-2007-4c26-aa98-34d19d81803b
00000000-0000-0000-0000-000000000000	269	PI7yyey0djEHx0FTcK2jZg	0919a2be-3b19-418f-91e8-ae8a8ffd3e48	f	2025-06-15 14:38:37.731569+00	2025-06-15 14:38:37.731569+00	\N	8db827ad-6a40-46dc-8b6f-681772e0dc2e
00000000-0000-0000-0000-000000000000	270	Z1AxiJUk7PGK9BYtbq8Djw	01f2db6b-0dc0-45f1-842b-aced9d793fe6	f	2025-06-15 14:38:37.823799+00	2025-06-15 14:38:37.823799+00	\N	a965a3bd-6ed7-402a-9f3f-99d36319e393
00000000-0000-0000-0000-000000000000	271	888UdqMGgYzG0edzejtiQQ	2fc4583b-c10b-423a-a6fe-a5e25b7bc801	f	2025-06-15 14:38:37.926808+00	2025-06-15 14:38:37.926808+00	\N	035bd06d-0d80-4ef3-8702-ca42e35679cb
00000000-0000-0000-0000-000000000000	272	ZdMcGkuIQBfxiQjRdZflGg	15f0f3a4-341a-4342-bca2-11c1d03d82a6	f	2025-06-15 14:38:38.029692+00	2025-06-15 14:38:38.029692+00	\N	cd93f4ec-cb6f-4cfb-9593-3ad1be6cd4e7
00000000-0000-0000-0000-000000000000	273	B9_pM1IeO9pgBF6_AyCgAQ	4af83a63-96e1-44ea-a7aa-749a66e5fcd7	f	2025-06-15 14:38:38.122313+00	2025-06-15 14:38:38.122313+00	\N	593788b5-9131-427f-bec4-16e09b64209c
00000000-0000-0000-0000-000000000000	274	Xsgf0f7AGjaghwyUn1kg5g	24f097e0-aad9-486d-887d-590379cf8f78	f	2025-06-15 14:38:38.218007+00	2025-06-15 14:38:38.218007+00	\N	13e258e1-f285-4b64-847e-4f3c4982e6e7
00000000-0000-0000-0000-000000000000	275	JjgRW8N-WEtlba13hajEhQ	3a62ecb7-b6c8-4883-9066-4e1a871adc12	f	2025-06-15 14:38:38.308773+00	2025-06-15 14:38:38.308773+00	\N	684ea30d-843d-47ad-9326-4b427ba89899
00000000-0000-0000-0000-000000000000	276	dHVKZTLhC2QG4fskT8QsLg	bdbfe7f9-be3d-45db-9e74-0bafc00e3da8	f	2025-06-15 14:38:38.405019+00	2025-06-15 14:38:38.405019+00	\N	9f15da1b-8935-4800-b63d-3f89b7898dc2
00000000-0000-0000-0000-000000000000	277	9iZJn96a4XWFlHoBqitYSQ	8d17a10c-9baa-4371-be70-35eff53317e4	f	2025-06-15 14:38:38.49297+00	2025-06-15 14:38:38.49297+00	\N	5591f9be-d03d-4e3f-8692-6698c7c68c4d
00000000-0000-0000-0000-000000000000	278	B9X6DzcSI02b5yRAhw2hqg	e8e773cd-d387-4efc-b92e-98dd804a3dd3	f	2025-06-15 14:38:38.585127+00	2025-06-15 14:38:38.585127+00	\N	e338edc8-5617-48a2-9b9e-f0f7ba7d9113
00000000-0000-0000-0000-000000000000	279	PgrYQUZwH7SsenUZktdRAQ	e1ccea0a-ccc5-48c9-98dd-26a48399ec52	f	2025-06-15 14:38:38.678726+00	2025-06-15 14:38:38.678726+00	\N	eef49338-073d-4030-9f8f-be1a4a6e0771
00000000-0000-0000-0000-000000000000	280	xMy0tj7S2LrZT2QNK344aw	cc6ec44c-3285-40f9-84fd-fe38f6cac978	f	2025-06-15 14:38:38.781264+00	2025-06-15 14:38:38.781264+00	\N	86b649f9-f05c-4a06-ba60-d9757d134e7e
00000000-0000-0000-0000-000000000000	281	GVEmToFQfQwNvLTCuy-WuA	5ad2dbaf-6d13-47a0-b9d2-47b7adb86ff0	f	2025-06-15 14:38:38.878633+00	2025-06-15 14:38:38.878633+00	\N	7b6acbcb-b4cf-4547-8bb5-f25a0b563ae1
00000000-0000-0000-0000-000000000000	282	TPKoY2_K9-tNp7V-fGr-Iw	7d417c53-b437-40ff-911a-8d9eef5e2977	f	2025-06-15 14:38:38.978568+00	2025-06-15 14:38:38.978568+00	\N	d0dc835d-968a-401b-a586-84744806fcb3
00000000-0000-0000-0000-000000000000	283	NEl09V1oA6cCw8CMbPqyXQ	e6dae6f9-e483-4071-923d-095f173ed23e	f	2025-06-15 14:38:39.071257+00	2025-06-15 14:38:39.071257+00	\N	4dc7f2f8-79ba-410c-904f-6295e832eb84
00000000-0000-0000-0000-000000000000	284	2xNGJa0UlAdmwl3seiazVA	24d8cbc0-b247-4c06-bd71-80c775c228f0	f	2025-06-15 14:38:39.163755+00	2025-06-15 14:38:39.163755+00	\N	7e855504-d59c-4456-b5e2-3c9b2fd21114
00000000-0000-0000-0000-000000000000	285	bboL4mYxd8VK9a8-RnVCnQ	c03ad22a-b91d-4788-9b2e-d4e016651a9b	f	2025-06-15 14:38:39.267807+00	2025-06-15 14:38:39.267807+00	\N	463af394-8030-4ff7-bc7e-74713ac8627f
00000000-0000-0000-0000-000000000000	286	hTFo5hATJzx73crRRz0QvA	fe48a53d-699e-4b91-9987-efdd47b9b34b	f	2025-06-15 14:38:39.366365+00	2025-06-15 14:38:39.366365+00	\N	52f16e75-757b-4178-82c7-72b54d145d9f
00000000-0000-0000-0000-000000000000	287	AkIZvWxtlS8_vU_7lNXLjg	54762cd7-e15c-4dfe-b8c3-620921ec2366	f	2025-06-15 14:38:39.466128+00	2025-06-15 14:38:39.466128+00	\N	539b81cf-d375-448b-9de7-7ef0c66c2040
00000000-0000-0000-0000-000000000000	288	lzNlUa-hp4lAczrqrwv1xA	6b17a4a1-6399-4241-8bae-98ce72ffd9b8	f	2025-06-15 14:38:39.564777+00	2025-06-15 14:38:39.564777+00	\N	84b67e85-4871-4b8c-809e-7a75a5d299be
00000000-0000-0000-0000-000000000000	289	q9zvO1uLKSPN13GGHHnAGw	646b90b4-51f9-44ce-9e89-41492cb826f9	f	2025-06-15 14:38:39.662937+00	2025-06-15 14:38:39.662937+00	\N	d348e60f-9e10-4062-aa87-f32953690ad5
00000000-0000-0000-0000-000000000000	290	7iaeo-ALBMWonQbCOWZ_cg	6f88c691-03be-4853-8903-67e2bca0d234	f	2025-06-15 14:38:39.773427+00	2025-06-15 14:38:39.773427+00	\N	a1a6d6ca-afde-42fd-a5a6-84b5f1588867
00000000-0000-0000-0000-000000000000	291	fhjO4WXReLnvSg1XTrOuKA	33f581a6-b5de-49d8-acdd-1166f5a55844	f	2025-06-15 14:38:39.872976+00	2025-06-15 14:38:39.872976+00	\N	f5cefc28-e9fd-460c-aed5-f7282ba13407
00000000-0000-0000-0000-000000000000	292	BDITJzVYOMpeRWPiDwNwZA	a31bd0c1-174b-4922-a1b7-e60acc9b25b4	f	2025-06-15 14:38:39.968779+00	2025-06-15 14:38:39.968779+00	\N	25a0ac93-428f-4941-9a7d-001518e49980
00000000-0000-0000-0000-000000000000	293	n7_Ti3u4ucz7nb0I6FXsRA	0492f0e6-5805-44af-aa74-4db0c77a4140	f	2025-06-15 14:38:40.065399+00	2025-06-15 14:38:40.065399+00	\N	2b1cfd8a-c4ba-4ac0-a8e8-17ca04e7ec6c
00000000-0000-0000-0000-000000000000	294	0o83qXcTsMa-lw0qvJUd_w	6a07ae1f-58b7-49a3-b140-407f7039c517	f	2025-06-15 14:38:40.155677+00	2025-06-15 14:38:40.155677+00	\N	4b186324-1322-4af1-91f6-55be20d380fa
00000000-0000-0000-0000-000000000000	295	2FKPNYfvSnofQuUNHz07Og	25c9e59a-dddc-4e8d-9b27-4033d9f1274a	f	2025-06-15 14:38:40.248179+00	2025-06-15 14:38:40.248179+00	\N	8cf9a821-e08d-431d-8740-d297bfd1915a
00000000-0000-0000-0000-000000000000	296	rRC5NoKFpHrlNmMumsMOaw	4120635d-c542-437d-9cea-9319b2338db0	f	2025-06-15 14:38:40.345204+00	2025-06-15 14:38:40.345204+00	\N	1fce5698-97d2-4833-9902-15be57024502
00000000-0000-0000-0000-000000000000	297	ozx88M5TdZoqh-Cqjz-DuA	93a02249-5316-49a2-9ac7-12b4c8905133	f	2025-06-15 14:38:40.446917+00	2025-06-15 14:38:40.446917+00	\N	09a319fd-4201-4d52-9d7c-fdbeebf5b878
00000000-0000-0000-0000-000000000000	298	sDiIvY4fw4aBAK_dKtb1LQ	fd863516-76ca-4417-8047-db3bdf0cb04e	f	2025-06-15 14:38:40.54025+00	2025-06-15 14:38:40.54025+00	\N	5ebb5f73-f433-4fc1-ab06-e1fd530c3f72
00000000-0000-0000-0000-000000000000	299	sHYHRVbQMPBLxCrk05fdiA	e8eef5b6-23c8-43b6-b361-5407820aa1bd	f	2025-06-15 14:38:40.635339+00	2025-06-15 14:38:40.635339+00	\N	ea77802f-ee85-49dc-ba21-f5a4e75653b4
00000000-0000-0000-0000-000000000000	300	WS99yBM7vVxrMSoYEMAAuQ	0e4b6571-d7da-4d82-8035-b53821d50643	f	2025-06-15 14:38:40.726379+00	2025-06-15 14:38:40.726379+00	\N	18cf94ec-2de1-4d82-abc7-e7dba54967d1
00000000-0000-0000-0000-000000000000	301	xN-xwH4zCtO5kw1h57nSPA	3daebba2-2008-456d-85ff-0f51d49e2068	f	2025-06-15 14:38:40.818838+00	2025-06-15 14:38:40.818838+00	\N	be1ac062-24be-4b14-9c5a-6d19878a9e71
00000000-0000-0000-0000-000000000000	302	arOjqf4VSG46b9M59PT5Jg	79e11466-b344-4852-81cb-39ff9e45ebc0	f	2025-06-15 14:38:40.920409+00	2025-06-15 14:38:40.920409+00	\N	6e22abed-080f-441f-ba80-fb744a7e8025
00000000-0000-0000-0000-000000000000	303	2rkPAERSRUebI5T_ZH93IA	4838f267-e471-42c2-960a-afb1bbe50dd5	f	2025-06-15 14:38:41.015367+00	2025-06-15 14:38:41.015367+00	\N	d30b712c-5641-4e3c-9988-0c040522fd04
00000000-0000-0000-0000-000000000000	304	jgz8tZGePtPlTlkQJtI4kA	4735ce34-ed6c-4b84-a258-c098689ca12f	f	2025-06-15 14:38:41.112242+00	2025-06-15 14:38:41.112242+00	\N	69478523-79ff-4000-b7bc-79d8ab82c7fc
00000000-0000-0000-0000-000000000000	305	LOg4gHnBauzsxPWG6HEdyg	0b500a7c-c000-4b0f-b19a-4cc42e3d380e	f	2025-06-15 14:38:41.207307+00	2025-06-15 14:38:41.207307+00	\N	94d1578e-0289-48e3-b538-4bf6a6c6ce4e
00000000-0000-0000-0000-000000000000	306	B4qgRzxRcbMstX98KWeGvw	80c123de-90b0-4fd6-9424-1e93e57c96fb	f	2025-06-15 14:38:41.301627+00	2025-06-15 14:38:41.301627+00	\N	6266a739-fca5-4399-9347-3d4729347e29
00000000-0000-0000-0000-000000000000	307	msvEbch68kEnxFiaJ9cVFw	bcc22448-661c-4e28-99a8-edb83a48195e	f	2025-06-15 14:38:41.39123+00	2025-06-15 14:38:41.39123+00	\N	114af36d-cf3e-46dc-a7da-535f09b60748
00000000-0000-0000-0000-000000000000	308	2f537WQmCxohbSTEyToPhQ	77580fe9-7ac2-4fb0-9aa7-06995f768dea	f	2025-06-15 14:38:41.481787+00	2025-06-15 14:38:41.481787+00	\N	22aa14b8-646e-40ad-92ac-86aa278885f8
00000000-0000-0000-0000-000000000000	309	DetSyD4_Dnu9aqd-u4WW0w	1d351dae-d3b7-476d-9c6a-c3851e6117f8	f	2025-06-15 14:38:41.580787+00	2025-06-15 14:38:41.580787+00	\N	0ffcdc7f-e6c9-4e24-8102-7cf4510edc70
00000000-0000-0000-0000-000000000000	310	HB4VRT-dhYRNfxXzbd19-w	b37636b3-8be1-4178-9cf2-8b57f5394441	f	2025-06-15 14:38:41.671764+00	2025-06-15 14:38:41.671764+00	\N	925680c5-f408-4c0e-9009-9e35924af125
00000000-0000-0000-0000-000000000000	311	X5wpW4Jpayq52mxFR3aCsQ	86c5fd15-a47d-44b9-94f9-864b787d7db8	f	2025-06-15 14:38:41.770129+00	2025-06-15 14:38:41.770129+00	\N	0300ce43-82b9-4045-9776-57092df2e429
00000000-0000-0000-0000-000000000000	312	k2xC9oBTJ9NewKNv47LMvQ	26e06765-0726-4760-a956-cd6c133c8cf1	f	2025-06-15 14:38:41.871287+00	2025-06-15 14:38:41.871287+00	\N	a5dc11fb-8af0-4bb0-aecb-cf0fc8cb4a13
00000000-0000-0000-0000-000000000000	313	I5r6zAU1f75tTXjCtUoVZg	9899069d-e0c6-4dec-b3cd-e4080a838f61	f	2025-06-15 14:38:41.967409+00	2025-06-15 14:38:41.967409+00	\N	5bf22f34-8d90-4d14-997b-50683b771b7e
00000000-0000-0000-0000-000000000000	314	LGUkkvieWy81XPZqx1ldRQ	43e2d156-815e-45bc-a9c4-959ffc35a607	f	2025-06-15 14:38:42.060226+00	2025-06-15 14:38:42.060226+00	\N	15bd2547-76ef-4253-94fa-c92dc3f7bf71
00000000-0000-0000-0000-000000000000	315	uN1HMgJqm4UurfJ0eeGrvg	97f7ac1a-aaf7-4061-8dba-cef646b37a3b	f	2025-06-15 14:38:42.157155+00	2025-06-15 14:38:42.157155+00	\N	c048950c-e803-4a90-be73-6be0f8b7bbfa
00000000-0000-0000-0000-000000000000	316	7wiBrnrXCZr5DufVCG6k4g	e24e82c5-482d-44c5-95e4-0dec79afeffc	f	2025-06-15 14:38:42.249368+00	2025-06-15 14:38:42.249368+00	\N	4d46961c-6ef7-4e49-92ab-c9bb1dec1ea9
00000000-0000-0000-0000-000000000000	317	r9M_P7X0akrdRumVPb2bNg	9bfb750a-2c2d-4bfc-9999-44fdabda74dd	f	2025-06-15 14:38:42.353356+00	2025-06-15 14:38:42.353356+00	\N	3051d6ee-1f6e-4708-ac85-99af82fd3283
00000000-0000-0000-0000-000000000000	318	EU1JX-l0B7l4_BeLHkIANg	fc2ca455-d9cb-44de-a313-e5f66f65a688	f	2025-06-15 14:38:42.449226+00	2025-06-15 14:38:42.449226+00	\N	6a06e0cc-7286-450f-9200-90f60a83b880
00000000-0000-0000-0000-000000000000	378	91gKOlVODF3Foucat0VvYw	fd238175-c03f-4b7a-a819-0837b802ae2c	f	2025-06-23 07:41:53.958017+00	2025-06-23 07:41:53.958017+00	\N	7ea6f5b5-0c06-418c-ac38-ac63530b46e3
00000000-0000-0000-0000-000000000000	379	qKImYwrMQM8_yF8AbNyaFQ	5dfc121a-a553-4380-9094-d716a81b495f	f	2025-06-23 07:41:59.341319+00	2025-06-23 07:41:59.341319+00	\N	287974ec-b8fd-49a1-87e6-1b573907dfa2
00000000-0000-0000-0000-000000000000	380	ovYLEH-97MSeEO0UqqcSeQ	ba467302-a9dd-49f1-bb39-442fdab37dcd	f	2025-06-23 07:42:01.103353+00	2025-06-23 07:42:01.103353+00	\N	912238d3-fec6-49a3-acf0-d36999f94957
00000000-0000-0000-0000-000000000000	381	sEaCIz2kYDu-ILXtqETtYA	3f695e7a-da08-4344-8d1c-60d1e4d3d772	f	2025-06-23 07:42:25.112824+00	2025-06-23 07:42:25.112824+00	\N	b5909235-9f82-4f30-8cd9-708ab783d880
00000000-0000-0000-0000-000000000000	382	nK9gNQ6OxpdQAvs15D87rQ	5dfc121a-a553-4380-9094-d716a81b495f	f	2025-06-23 07:42:27.067991+00	2025-06-23 07:42:27.067991+00	\N	51789518-b5e5-474d-bd6a-c6d24e877d2e
00000000-0000-0000-0000-000000000000	383	D4q8xGRkHuydFOfQFdm-Eg	e4f7c6ca-5cfe-411a-a814-45a13ee76fe4	f	2025-06-23 07:42:27.470682+00	2025-06-23 07:42:27.470682+00	\N	d28d6771-8507-4f58-96ff-669dc3bb8320
00000000-0000-0000-0000-000000000000	384	PIUDgJqx6WzBkLNNSGsElg	878637b4-5c02-462a-80e3-edd2cb4dd365	f	2025-06-23 07:42:35.156395+00	2025-06-23 07:42:35.156395+00	\N	ea1e938d-d79a-478c-aaad-4cba83b0dbcf
00000000-0000-0000-0000-000000000000	385	cu8wDyAf5cqf29603yl5zQ	2186e85a-0204-40d2-ac5a-1ae7600edfa3	f	2025-06-23 07:42:35.315347+00	2025-06-23 07:42:35.315347+00	\N	d01dcdbd-208b-483b-93c2-28ba38ac94f2
00000000-0000-0000-0000-000000000000	326	stNUyrNe_Iq9zgVOYZTDsA	ad892dc0-1949-48b7-be5e-d63c7290e512	t	2025-06-15 15:27:22.196342+00	2025-06-16 00:43:14.149877+00	\N	955895f1-1a1f-4ff6-82e5-1d0536cfb1e9
00000000-0000-0000-0000-000000000000	327	hoDr0HVavqx1Ut2NqFhJcw	ad892dc0-1949-48b7-be5e-d63c7290e512	t	2025-06-16 00:43:14.150208+00	2025-06-16 03:10:02.296905+00	stNUyrNe_Iq9zgVOYZTDsA	955895f1-1a1f-4ff6-82e5-1d0536cfb1e9
00000000-0000-0000-0000-000000000000	328	dtfHr7zOD2nSiU4UAHfRlQ	ad892dc0-1949-48b7-be5e-d63c7290e512	f	2025-06-16 03:10:02.297195+00	2025-06-16 03:10:02.297195+00	hoDr0HVavqx1Ut2NqFhJcw	955895f1-1a1f-4ff6-82e5-1d0536cfb1e9
00000000-0000-0000-0000-000000000000	387	wK9B6N7Fjeu7pfFYleefgw	f7280a96-7703-4d4d-b2a8-9d2acc15a160	f	2025-06-23 07:42:41.780988+00	2025-06-23 07:42:41.780988+00	\N	85b48456-18f7-40e2-be9a-57a1431c8d26
00000000-0000-0000-0000-000000000000	388	TBs45KDAe9uTCz5XUOTE2w	9e2f17ea-26c5-414b-835c-f9b42705c024	f	2025-06-23 07:42:52.935626+00	2025-06-23 07:42:52.935626+00	\N	3aea7dc8-47d2-43a9-bb4b-a6eac5c42e54
00000000-0000-0000-0000-000000000000	389	o_z5h6A4wPC5ZlhivzyQyg	7df7ea94-16ba-4fd6-85bc-4fd0155fe284	f	2025-06-23 07:43:02.127035+00	2025-06-23 07:43:02.127035+00	\N	8470770d-76f1-4d73-91b7-fa82d2e2d5e1
00000000-0000-0000-0000-000000000000	390	2tegdoZUA6GkwC0cgDZc-Q	bc9650f6-a750-4deb-98f6-636b76c60b62	f	2025-06-23 07:43:10.627517+00	2025-06-23 07:43:10.627517+00	\N	ac52d839-e71a-48b1-94d0-95f13e9f1978
00000000-0000-0000-0000-000000000000	392	zFXUo_Jio_vbsBNMsEgU7Q	0d12ddb0-122b-46a3-afba-c35c8640e887	f	2025-06-23 07:43:26.709319+00	2025-06-23 07:43:26.709319+00	\N	9a069c31-d0f1-4c9a-ab91-7e1632123f66
00000000-0000-0000-0000-000000000000	393	Cj1_6UPWz0GgRbKqeJEgzg	a4051467-1969-4a0f-8657-d8f3f0ba6359	f	2025-06-23 07:43:52.638127+00	2025-06-23 07:43:52.638127+00	\N	cd5320e6-739d-44ab-9dd2-b7c9e640e981
00000000-0000-0000-0000-000000000000	394	XpRBdfgJekXDF9lxdPGwnA	0cd2be50-abf7-420e-a986-7fa5371cf6a3	f	2025-06-23 07:44:11.301697+00	2025-06-23 07:44:11.301697+00	\N	86573a3f-5f86-4914-8e73-ccf9f67cc9bf
00000000-0000-0000-0000-000000000000	395	fY1900hTCmZ7-g9hqIW3Yw	ba467302-a9dd-49f1-bb39-442fdab37dcd	f	2025-06-23 07:44:15.553391+00	2025-06-23 07:44:15.553391+00	\N	c16000a8-d9a2-4fe9-82fb-b06158494cad
00000000-0000-0000-0000-000000000000	396	7gjzhX-0hljm6fVIavOkcg	e4f7c6ca-5cfe-411a-a814-45a13ee76fe4	f	2025-06-23 07:44:23.618819+00	2025-06-23 07:44:23.618819+00	\N	f3043ad1-34c9-44f8-97cc-21b19eeff073
00000000-0000-0000-0000-000000000000	397	9zJyHLkIne1Ay_-9MdhfvA	ac59ee7e-0939-4e05-bf57-be9508f40d82	f	2025-06-23 07:44:36.500523+00	2025-06-23 07:44:36.500523+00	\N	753af9c7-5823-4641-b570-8426301bf0ec
00000000-0000-0000-0000-000000000000	398	VSFZAy0w1brFUAI9GNH0BQ	878637b4-5c02-462a-80e3-edd2cb4dd365	f	2025-06-23 07:44:40.291451+00	2025-06-23 07:44:40.291451+00	\N	0c7a3acd-07ff-4323-8e09-083d46383d78
00000000-0000-0000-0000-000000000000	399	f_vR3jtg_23ULqV2_5FbBw	016ca48e-66c5-476c-9716-c6397ed60e69	f	2025-06-23 07:44:52.037808+00	2025-06-23 07:44:52.037808+00	\N	7f876ce2-67d5-45dc-a032-0cdfc0affd72
00000000-0000-0000-0000-000000000000	400	de5diW2sGKvpyCuQjXi-GQ	08a2cbdf-9a26-4469-9034-ed7b3f5b73e9	f	2025-06-23 07:44:52.389143+00	2025-06-23 07:44:52.389143+00	\N	bc1a409c-1b65-4ea4-a742-366b7d180437
00000000-0000-0000-0000-000000000000	401	Ov23-kRQrFNn6gkWT0W2uw	e2c36046-d53b-4a02-9eef-f85a47d6c357	f	2025-06-23 07:45:00.740273+00	2025-06-23 07:45:00.740273+00	\N	1ffd9ad7-680c-491b-9648-5eef8aacb3cc
00000000-0000-0000-0000-000000000000	402	PC_mEgAkCnyKG44gSjmpEw	ee74b89d-137d-470c-8a00-90fb5a372727	f	2025-06-23 07:45:13.475297+00	2025-06-23 07:45:13.475297+00	\N	cfe63d34-0594-4dfe-a86c-8080d0b0e8e0
00000000-0000-0000-0000-000000000000	403	qdwlMkcqA4P5OgyZ3ei0kg	47676bae-55c6-48f5-8b6a-dc0a3af02ec4	f	2025-06-23 07:45:26.433913+00	2025-06-23 07:45:26.433913+00	\N	65846dba-299a-4ee4-872c-4721fd36bab4
00000000-0000-0000-0000-000000000000	404	usm6LMT2wWRSaB3TIvTuqQ	1698b43a-831d-455f-bb6f-22c3097c005f	f	2025-06-23 07:45:27.892623+00	2025-06-23 07:45:27.892623+00	\N	bd4d9ea5-d462-467e-919d-306e37aa7f8c
00000000-0000-0000-0000-000000000000	405	l9_WNYgBhorqk9qzQTTCaQ	3142bce6-7211-4fd1-a09f-1d17e6cf287a	f	2025-06-23 07:45:30.956254+00	2025-06-23 07:45:30.956254+00	\N	90bf53e9-8183-411f-9959-7b1cdfd3bfa6
00000000-0000-0000-0000-000000000000	406	w2lYXOL5uLuKpvrnfU-_xQ	9e6b451a-3a18-4f0c-97f3-fcccefe12a55	f	2025-06-23 07:45:35.865117+00	2025-06-23 07:45:35.865117+00	\N	592fd046-4bac-4927-b7d3-17a358e89f7f
00000000-0000-0000-0000-000000000000	407	OJKHsROx3ZBpf3uxwVLcSg	a829ccb9-78d5-4940-82f6-934352e828cd	f	2025-06-23 07:45:50.214531+00	2025-06-23 07:45:50.214531+00	\N	965d164c-dbc2-4ec4-b988-89ba41752be4
00000000-0000-0000-0000-000000000000	341	csMy6m6Y9eO-tZ8dSPO1Cg	bb194837-db77-40d9-a6fd-5e9737c5724e	f	2025-06-18 02:12:53.844444+00	2025-06-18 02:12:53.844444+00	\N	82401c0e-53bd-4366-b603-47f7dceab31f
00000000-0000-0000-0000-000000000000	340	cicdEup72AkBeHefkd-TLg	bb194837-db77-40d9-a6fd-5e9737c5724e	t	2025-06-18 02:09:49.682959+00	2025-06-18 03:08:09.475399+00	\N	7e382f3e-b658-4f4a-9b77-58e810ca5764
00000000-0000-0000-0000-000000000000	408	zw59Siy8o1hTrx7kQYCk4Q	6dc3e17b-1af0-4a4b-abaf-a9830465a207	f	2025-06-23 07:45:55.127875+00	2025-06-23 07:45:55.127875+00	\N	7eb85347-6fef-4d38-ae44-292432a519a8
00000000-0000-0000-0000-000000000000	342	l8VZH4OW2UxlKV-pqSK4lw	bb194837-db77-40d9-a6fd-5e9737c5724e	t	2025-06-18 03:08:09.475915+00	2025-06-18 04:06:09.956351+00	cicdEup72AkBeHefkd-TLg	7e382f3e-b658-4f4a-9b77-58e810ca5764
00000000-0000-0000-0000-000000000000	409	_mWKNKv3OyJ0cauhIZuyzg	4e579a51-bb42-45f1-9b79-b84928a98421	f	2025-06-23 07:46:01.257965+00	2025-06-23 07:46:01.257965+00	\N	1a90df89-1c9f-46ef-9a5b-e78659533146
00000000-0000-0000-0000-000000000000	343	5TGwlZf4at7LCeLepo8y_g	bb194837-db77-40d9-a6fd-5e9737c5724e	t	2025-06-18 04:06:09.956674+00	2025-06-18 05:04:13.000314+00	l8VZH4OW2UxlKV-pqSK4lw	7e382f3e-b658-4f4a-9b77-58e810ca5764
00000000-0000-0000-0000-000000000000	386	xQPZEj4seKsdLR5qjWfWDg	8bc44ea0-2e33-458a-ac4d-298980c44b05	t	2025-06-23 07:42:39.769976+00	2025-06-23 13:37:10.613177+00	\N	aef2f822-7459-4b19-a7c5-9124cc6357ae
00000000-0000-0000-0000-000000000000	344	5xGqH2XwARabS0sWJrX8hg	bb194837-db77-40d9-a6fd-5e9737c5724e	t	2025-06-18 05:04:13.000583+00	2025-06-18 06:02:15.042865+00	5TGwlZf4at7LCeLepo8y_g	7e382f3e-b658-4f4a-9b77-58e810ca5764
00000000-0000-0000-0000-000000000000	345	N70cYPLqd6lUe5WUjysgbg	bb194837-db77-40d9-a6fd-5e9737c5724e	t	2025-06-18 06:02:15.043152+00	2025-06-18 07:00:15.795643+00	5xGqH2XwARabS0sWJrX8hg	7e382f3e-b658-4f4a-9b77-58e810ca5764
00000000-0000-0000-0000-000000000000	348	tNG6iD53oL7cFmqdxBqLWQ	bb194837-db77-40d9-a6fd-5e9737c5724e	f	2025-06-18 07:00:15.79593+00	2025-06-18 07:00:15.79593+00	N70cYPLqd6lUe5WUjysgbg	7e382f3e-b658-4f4a-9b77-58e810ca5764
00000000-0000-0000-0000-000000000000	413	HnJUv0q44ee66Tcnvq39hg	7b53d13f-0338-44ff-a05d-238f8d25cad4	f	2025-06-23 07:46:31.432893+00	2025-06-23 07:46:31.432893+00	\N	b3b8d5d9-5a37-40db-b7f2-87461e8aba33
00000000-0000-0000-0000-000000000000	414	s86qFgEOMza42Z1qIeJVfw	6c383e4a-a52d-4661-8a6c-4be47b0ed340	f	2025-06-23 07:46:53.270252+00	2025-06-23 07:46:53.270252+00	\N	af811759-bcd5-4155-b8fa-f9437789acb2
00000000-0000-0000-0000-000000000000	415	l91mCBzBIr7B_dLmIlToFg	9e6b451a-3a18-4f0c-97f3-fcccefe12a55	f	2025-06-23 07:46:58.140971+00	2025-06-23 07:46:58.140971+00	\N	f2e6d99d-3e50-4869-8cdb-dcb845e5a11f
00000000-0000-0000-0000-000000000000	416	TvZEkKzDM9k2V26oW8X5jQ	8175ff46-a82f-41f1-9650-87661f8acbb1	f	2025-06-23 07:47:12.295273+00	2025-06-23 07:47:12.295273+00	\N	4b4f4c43-f116-4c12-a61e-ccc7efb1cc4e
00000000-0000-0000-0000-000000000000	417	EnONUAm6er7TdkxoQ2xDvw	59874f8b-4fdf-41ce-947b-da9240a861ca	f	2025-06-23 07:47:12.316443+00	2025-06-23 07:47:12.316443+00	\N	9d128b8a-4d51-483c-9194-80ce946f3bda
00000000-0000-0000-0000-000000000000	418	aCWxpc08a6gtJBNjyTWzmg	13889f78-4916-4d07-8c07-faf25d913216	f	2025-06-23 07:47:32.541513+00	2025-06-23 07:47:32.541513+00	\N	1d935b35-044b-4905-9c9a-8aeea5d93faa
00000000-0000-0000-0000-000000000000	419	vi6f4C2QqvcNt46DGkkatg	9e2f17ea-26c5-414b-835c-f9b42705c024	f	2025-06-23 07:47:36.221742+00	2025-06-23 07:47:36.221742+00	\N	e931c2a6-23fe-4015-9bc3-6421e0410b81
00000000-0000-0000-0000-000000000000	420	V-RvfhKy0eD00stqRWNGug	9ad14374-7580-4a86-a7e7-7e1450f96333	f	2025-06-23 07:48:00.340245+00	2025-06-23 07:48:00.340245+00	\N	1b9f4822-7bd3-4c91-ab54-26d320856159
00000000-0000-0000-0000-000000000000	421	b6R_a_wj3U22rTGh0QCf0A	c31c618f-5148-41bb-802d-025b2b70965a	f	2025-06-23 07:48:23.006393+00	2025-06-23 07:48:23.006393+00	\N	cd689551-d304-443c-b46f-5c6d1c818cb3
00000000-0000-0000-0000-000000000000	422	qZdDvBpufvYtm0zcY3hVqQ	7b53d13f-0338-44ff-a05d-238f8d25cad4	f	2025-06-23 07:50:11.153621+00	2025-06-23 07:50:11.153621+00	\N	d99f8e4c-19c1-414f-a337-3c27803f3c7e
00000000-0000-0000-0000-000000000000	423	dq_qmc1MAXhaGNHl7ZgZfQ	1698b43a-831d-455f-bb6f-22c3097c005f	f	2025-06-23 07:50:49.590306+00	2025-06-23 07:50:49.590306+00	\N	1532b437-1a52-417b-9e61-dbfbdc0b88d1
00000000-0000-0000-0000-000000000000	424	oqBlaOoXNW4r_YhjAV5qjg	3142bce6-7211-4fd1-a09f-1d17e6cf287a	f	2025-06-23 07:51:04.745667+00	2025-06-23 07:51:04.745667+00	\N	0c6a685e-91e1-42bc-9d5d-23ef862fda71
00000000-0000-0000-0000-000000000000	425	fN6CiYMcG_cRXzmyFJOtXQ	7f05337a-1f10-411a-8c90-ab632faaf8c2	f	2025-06-23 07:51:06.860957+00	2025-06-23 07:51:06.860957+00	\N	3977c47c-a631-42f6-b3e2-362e0fa99c5b
00000000-0000-0000-0000-000000000000	426	Rob8QIH5WOmH9-tM3AEIgw	a6ee5043-034b-496f-acc8-328104c06ed9	f	2025-06-23 07:51:10.641432+00	2025-06-23 07:51:10.641432+00	\N	e867c70d-26ca-4340-93de-8b4fb2263c95
00000000-0000-0000-0000-000000000000	427	FHFgIWXRaCmL12anNzQr1g	fd238175-c03f-4b7a-a819-0837b802ae2c	f	2025-06-23 07:51:23.776808+00	2025-06-23 07:51:23.776808+00	\N	34c4690d-2fc4-4af9-a091-1018463878c8
00000000-0000-0000-0000-000000000000	429	kMdEF2MD0SsbCKrITcTLUA	a1008ee6-6805-4d56-956d-0bcaad374870	f	2025-06-23 07:52:48.198619+00	2025-06-23 07:52:48.198619+00	\N	bb335723-588d-41f9-b329-aa02dd719102
00000000-0000-0000-0000-000000000000	430	9FlTFg_CPuvpG_5jMIqybA	ac59ee7e-0939-4e05-bf57-be9508f40d82	f	2025-06-23 07:52:49.605119+00	2025-06-23 07:52:49.605119+00	\N	a6b36d0d-53bf-4a0b-b8a4-74a0f75552b0
00000000-0000-0000-0000-000000000000	432	Sk-6LZAHyaE8IMY06jGdyg	016ca48e-66c5-476c-9716-c6397ed60e69	f	2025-06-23 07:53:16.099554+00	2025-06-23 07:53:16.099554+00	\N	51f0a42e-d3f4-437b-8912-58626cbdf959
00000000-0000-0000-0000-000000000000	433	0bHXHNev5kr1FIO2BCFshQ	a829ccb9-78d5-4940-82f6-934352e828cd	f	2025-06-23 07:53:22.947659+00	2025-06-23 07:53:22.947659+00	\N	b0983811-a44f-4de2-8897-92eb94b25a9b
00000000-0000-0000-0000-000000000000	434	BVUzMPuyTt7BTRuTFCkYMw	6dc3e17b-1af0-4a4b-abaf-a9830465a207	f	2025-06-23 07:53:24.211107+00	2025-06-23 07:53:24.211107+00	\N	9acca783-5aee-46cb-8b93-dad72f8ce960
00000000-0000-0000-0000-000000000000	435	Amhqujr-r7BXNJmii7p2FQ	fd238175-c03f-4b7a-a819-0837b802ae2c	f	2025-06-23 07:54:08.536601+00	2025-06-23 07:54:08.536601+00	\N	d8894cde-66dc-404c-a8c3-fcb7e53db79b
00000000-0000-0000-0000-000000000000	436	mtpi2TqPWJ-N1QpudldkYA	59874f8b-4fdf-41ce-947b-da9240a861ca	f	2025-06-23 07:55:24.747738+00	2025-06-23 07:55:24.747738+00	\N	4062b000-51fe-4ddd-bba0-e7f13308f797
00000000-0000-0000-0000-000000000000	437	E5zNmXEDqx6jGej52um8_Q	7f05337a-1f10-411a-8c90-ab632faaf8c2	f	2025-06-23 07:55:28.577372+00	2025-06-23 07:55:28.577372+00	\N	17850380-73d4-47ce-8526-681f8e0f4424
00000000-0000-0000-0000-000000000000	438	kO9ATjDhZplhhaDTEaJ5uw	fd238175-c03f-4b7a-a819-0837b802ae2c	f	2025-06-23 07:55:39.191023+00	2025-06-23 07:55:39.191023+00	\N	0967906a-3d96-4158-a6c5-f6e1ed8a1930
00000000-0000-0000-0000-000000000000	439	K5Bsz5vOmdPTM2BwERfN0g	0d12ddb0-122b-46a3-afba-c35c8640e887	f	2025-06-23 07:56:04.738293+00	2025-06-23 07:56:04.738293+00	\N	6e63b7dc-1583-4b05-812b-800255167285
00000000-0000-0000-0000-000000000000	441	XpV5OrLlh4BEfYrDEspZzw	2186e85a-0204-40d2-ac5a-1ae7600edfa3	f	2025-06-23 07:56:17.968173+00	2025-06-23 07:56:17.968173+00	\N	95280d85-278d-4051-b0e3-e71deafb998f
00000000-0000-0000-0000-000000000000	442	3yDPAbL6Vb0Z0VwdM1v-xw	6c383e4a-a52d-4661-8a6c-4be47b0ed340	f	2025-06-23 07:56:55.011637+00	2025-06-23 07:56:55.011637+00	\N	4b1eb4cb-350e-4d7e-89a4-d96c442b4879
00000000-0000-0000-0000-000000000000	443	1QLEHKTvLoBO6kGTmADa-w	a4051467-1969-4a0f-8657-d8f3f0ba6359	f	2025-06-23 07:57:16.065534+00	2025-06-23 07:57:16.065534+00	\N	f17ff1b3-96ba-413c-ab2f-c90695e8acbc
00000000-0000-0000-0000-000000000000	444	f6JU4Hi3Tnv6V6WUsYLtow	60dea06c-f874-48fb-80ce-b71d2e65ba95	f	2025-06-23 07:57:58.7415+00	2025-06-23 07:57:58.7415+00	\N	faaa7831-168e-4a70-85f2-32159a10a646
00000000-0000-0000-0000-000000000000	445	h0abu7ZqP4ThpqOKfmu4uw	ee74b89d-137d-470c-8a00-90fb5a372727	f	2025-06-23 07:58:31.486489+00	2025-06-23 07:58:31.486489+00	\N	25080e68-9d78-4c9a-9839-fae09373ad2d
00000000-0000-0000-0000-000000000000	446	YGknzDUbroHWUVvbofnCzw	47676bae-55c6-48f5-8b6a-dc0a3af02ec4	f	2025-06-23 08:00:50.526707+00	2025-06-23 08:00:50.526707+00	\N	c026b23f-c0bd-4892-9378-05789447cb03
00000000-0000-0000-0000-000000000000	447	4WV1PkX4bPQu6zbQwJwxBw	7d693d50-00d4-4a9b-9bc0-35afebbb30d9	f	2025-06-23 08:04:20.274177+00	2025-06-23 08:04:20.274177+00	\N	037105e9-7093-4c7d-8b96-115dd98bee91
00000000-0000-0000-0000-000000000000	440	-xIQBT2ODKwBciG5lu5_tQ	60dea06c-f874-48fb-80ce-b71d2e65ba95	t	2025-06-23 07:56:12.665201+00	2025-06-23 08:54:33.202172+00	\N	2cf3d60f-23b1-4297-8711-4a95a4e2c1a5
00000000-0000-0000-0000-000000000000	448	fIFQECwjDVQ3NuUxOraHSg	60dea06c-f874-48fb-80ce-b71d2e65ba95	f	2025-06-23 08:54:33.202485+00	2025-06-23 08:54:33.202485+00	-xIQBT2ODKwBciG5lu5_tQ	2cf3d60f-23b1-4297-8711-4a95a4e2c1a5
00000000-0000-0000-0000-000000000000	449	zYGGk4_AqiZiHAwAIym55A	8bc44ea0-2e33-458a-ac4d-298980c44b05	f	2025-06-23 13:37:10.613401+00	2025-06-23 13:37:10.613401+00	xQPZEj4seKsdLR5qjWfWDg	aef2f822-7459-4b19-a7c5-9124cc6357ae
00000000-0000-0000-0000-000000000000	428	6NRmjhWXgVvW-evvCBdeBg	7df7ea94-16ba-4fd6-85bc-4fd0155fe284	t	2025-06-23 07:52:06.716544+00	2025-06-24 00:06:54.591291+00	\N	778482ed-f101-471f-977f-b58f904746e4
00000000-0000-0000-0000-000000000000	431	PhH2ylR3pO-PmiQgMy6DBA	4e579a51-bb42-45f1-9b79-b84928a98421	t	2025-06-23 07:53:12.366288+00	2025-06-24 01:15:17.520975+00	\N	f2188aff-bf53-4f90-a44a-9ed70faf9a6b
00000000-0000-0000-0000-000000000000	450	-KEBkL5yxvy-uUs72iHo1w	7df7ea94-16ba-4fd6-85bc-4fd0155fe284	t	2025-06-24 00:06:54.591546+00	2025-06-24 02:31:07.91627+00	6NRmjhWXgVvW-evvCBdeBg	778482ed-f101-471f-977f-b58f904746e4
00000000-0000-0000-0000-000000000000	452	uLxj4wSFxur5hTkzmQn9AQ	7df7ea94-16ba-4fd6-85bc-4fd0155fe284	f	2025-06-24 02:31:07.916492+00	2025-06-24 02:31:07.916492+00	-KEBkL5yxvy-uUs72iHo1w	778482ed-f101-471f-977f-b58f904746e4
00000000-0000-0000-0000-000000000000	451	GX76e6d-Dwr5qymLJ-Gjqg	4e579a51-bb42-45f1-9b79-b84928a98421	t	2025-06-24 01:15:17.521196+00	2025-06-25 12:56:43.766297+00	PhH2ylR3pO-PmiQgMy6DBA	f2188aff-bf53-4f90-a44a-9ed70faf9a6b
00000000-0000-0000-0000-000000000000	453	C1ZfjZW7qVTHLio6klmV4w	4e579a51-bb42-45f1-9b79-b84928a98421	f	2025-06-25 12:56:43.766543+00	2025-06-25 12:56:43.766543+00	GX76e6d-Dwr5qymLJ-Gjqg	f2188aff-bf53-4f90-a44a-9ed70faf9a6b
00000000-0000-0000-0000-000000000000	467	NwUYFmyKL87cAq-zR9GBAQ	f1b6d4f2-174f-4b2a-8c6c-d4531b128bfc	f	2025-06-27 08:18:52.561874+00	2025-06-27 08:18:52.561874+00	\N	3c9bdd62-beb8-47d7-aac0-4460fa17c767
00000000-0000-0000-0000-000000000000	470	HShsyqoQexkiojFk-jJpqg	73bc6611-cc9d-451f-94f4-855016beb48e	f	2025-06-27 10:54:00.414333+00	2025-06-27 10:54:00.414333+00	\N	581f049b-5104-45aa-a670-243866b5b1e9
00000000-0000-0000-0000-000000000000	471	ivBFKTvdSc88jH6QQ8kp1Q	73bc6611-cc9d-451f-94f4-855016beb48e	f	2025-06-27 10:54:18.48683+00	2025-06-27 10:54:18.48683+00	\N	4794b543-ec8e-4ca7-bb06-316c1fe77f43
00000000-0000-0000-0000-000000000000	472	qF2l_m7YUD3xC8--GpJDdQ	73bc6611-cc9d-451f-94f4-855016beb48e	f	2025-06-27 10:59:44.306264+00	2025-06-27 10:59:44.306264+00	\N	9d384b5f-80c2-4bf8-b3b1-07b753249a73
00000000-0000-0000-0000-000000000000	473	YspQeyy4vg2ceoqcCHA0gg	73bc6611-cc9d-451f-94f4-855016beb48e	f	2025-06-27 11:26:45.673594+00	2025-06-27 11:26:45.673594+00	\N	af9c3956-3930-4d7a-b8cb-176b16e11c49
00000000-0000-0000-0000-000000000000	474	s00RnHQVBge0kn4o4QFiYA	73bc6611-cc9d-451f-94f4-855016beb48e	f	2025-06-27 13:54:21.149747+00	2025-06-27 13:54:21.149747+00	\N	b4253a4e-0af0-4d12-8a35-af0bddfd46c9
00000000-0000-0000-0000-000000000000	475	oMkN3EPGBYCOpoPTeS4_tQ	73bc6611-cc9d-451f-94f4-855016beb48e	f	2025-06-27 13:56:27.466889+00	2025-06-27 13:56:27.466889+00	\N	1cd8aacd-f1b6-4703-912b-a19bcd8a697d
00000000-0000-0000-0000-000000000000	476	k8asq_20PexOQpPhjxEw1A	0955eea6-fdc3-48b6-beca-f30e05cfe912	f	2025-06-27 14:20:23.544579+00	2025-06-27 14:20:23.544579+00	\N	923cbae7-a9c3-4f99-be45-4d00ed3532f7
00000000-0000-0000-0000-000000000000	477	y_nP6M-2GFSCjPMx0Wrdfg	0955eea6-fdc3-48b6-beca-f30e05cfe912	f	2025-06-27 14:37:01.41341+00	2025-06-27 14:37:01.41341+00	\N	52aa85e0-4c4d-46b6-aaed-6c5dc94f334a
00000000-0000-0000-0000-000000000000	478	NowiVwshCZoNP1lmRXKS1A	73bc6611-cc9d-451f-94f4-855016beb48e	f	2025-06-27 14:49:16.143654+00	2025-06-27 14:49:16.143654+00	\N	c4ef89cc-67ff-46f8-b046-ca0a8d9010ef
00000000-0000-0000-0000-000000000000	479	FbzRaFQiBKIlQBrIQLaD2A	fcc7d82b-864c-43db-9975-ff689875c391	t	2025-06-29 06:57:01.868473+00	2025-06-29 07:55:17.021401+00	\N	34d3d3d1-900f-4c0d-9966-589784e0135a
00000000-0000-0000-0000-000000000000	481	HGvjUmGsTOW4mqTO5akBfQ	fcc7d82b-864c-43db-9975-ff689875c391	t	2025-06-29 07:55:17.021626+00	2025-06-29 08:53:19.224277+00	FbzRaFQiBKIlQBrIQLaD2A	34d3d3d1-900f-4c0d-9966-589784e0135a
00000000-0000-0000-0000-000000000000	482	oozO5juIh8eokgwHMfVkeQ	fcc7d82b-864c-43db-9975-ff689875c391	t	2025-06-29 08:53:19.224501+00	2025-06-29 09:51:22.379513+00	HGvjUmGsTOW4mqTO5akBfQ	34d3d3d1-900f-4c0d-9966-589784e0135a
00000000-0000-0000-0000-000000000000	483	WcIxft7BVo9sCEmTTrU8Kg	fcc7d82b-864c-43db-9975-ff689875c391	t	2025-06-29 09:51:22.379775+00	2025-06-29 10:49:25.398291+00	oozO5juIh8eokgwHMfVkeQ	34d3d3d1-900f-4c0d-9966-589784e0135a
00000000-0000-0000-0000-000000000000	480	y12AwpbG0T3XS5LiRBA4Rw	fcc7d82b-864c-43db-9975-ff689875c391	t	2025-06-29 06:57:20.605163+00	2025-06-29 11:01:05.774343+00	\N	81767909-8727-49b2-840f-f1384043b150
00000000-0000-0000-0000-000000000000	485	I3PcslUxBSO-dDSAjhHj6A	fcc7d82b-864c-43db-9975-ff689875c391	f	2025-06-29 11:01:05.774584+00	2025-06-29 11:01:05.774584+00	y12AwpbG0T3XS5LiRBA4Rw	81767909-8727-49b2-840f-f1384043b150
00000000-0000-0000-0000-000000000000	484	Vy5HzFL2IF4q_dOlEu6GjQ	fcc7d82b-864c-43db-9975-ff689875c391	t	2025-06-29 10:49:25.398624+00	2025-06-29 11:47:26.298262+00	WcIxft7BVo9sCEmTTrU8Kg	34d3d3d1-900f-4c0d-9966-589784e0135a
00000000-0000-0000-0000-000000000000	486	TusG5TGKi_sY9wH9zTb_gA	fcc7d82b-864c-43db-9975-ff689875c391	t	2025-06-29 11:47:26.298482+00	2025-06-29 12:45:27.848813+00	Vy5HzFL2IF4q_dOlEu6GjQ	34d3d3d1-900f-4c0d-9966-589784e0135a
00000000-0000-0000-0000-000000000000	487	ZwwvKtJVIfrk-strESJqFQ	fcc7d82b-864c-43db-9975-ff689875c391	f	2025-06-29 12:45:27.849067+00	2025-06-29 12:45:27.849067+00	TusG5TGKi_sY9wH9zTb_gA	34d3d3d1-900f-4c0d-9966-589784e0135a
\.


--
-- Data for Name: saml_providers; Type: TABLE DATA; Schema: auth; Owner: -
--

COPY auth.saml_providers (id, sso_provider_id, entity_id, metadata_xml, metadata_url, attribute_mapping, created_at, updated_at, name_id_format) FROM stdin;
\.


--
-- Data for Name: saml_relay_states; Type: TABLE DATA; Schema: auth; Owner: -
--

COPY auth.saml_relay_states (id, sso_provider_id, request_id, for_email, redirect_to, created_at, updated_at, flow_state_id) FROM stdin;
\.


--
-- Data for Name: schema_migrations; Type: TABLE DATA; Schema: auth; Owner: -
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
-- Data for Name: sessions; Type: TABLE DATA; Schema: auth; Owner: -
--

COPY auth.sessions (id, user_id, created_at, updated_at, factor_id, aal, not_after, refreshed_at, user_agent, ip, tag) FROM stdin;
9f15da1b-8935-4800-b63d-3f89b7898dc2	bdbfe7f9-be3d-45db-9e74-0bafc00e3da8	2025-06-15 14:38:38.404637+00	2025-06-15 14:38:38.404637+00	\N	aal1	\N	\N	node	161.142.154.33	\N
5591f9be-d03d-4e3f-8692-6698c7c68c4d	8d17a10c-9baa-4371-be70-35eff53317e4	2025-06-15 14:38:38.492591+00	2025-06-15 14:38:38.492591+00	\N	aal1	\N	\N	node	161.142.154.33	\N
83b47c2f-1c81-42f0-a473-f79e0deae488	b7592049-9546-4bd4-9bc7-33d77d747af0	2025-06-15 14:38:32.838619+00	2025-06-15 14:38:32.838619+00	\N	aal1	\N	\N	node	161.142.154.33	\N
b8f0efc1-2af4-4329-9a18-98e16d06593f	663cd7e5-73f0-4c16-b7a8-a579107fda69	2025-06-15 14:38:32.94234+00	2025-06-15 14:38:32.94234+00	\N	aal1	\N	\N	node	161.142.154.33	\N
da54bf07-62bc-4f4e-bef4-2c35f9ab04a2	081efe3b-09b5-4e34-9194-cbcb30cc77d9	2025-06-15 14:38:33.039846+00	2025-06-15 14:38:33.039846+00	\N	aal1	\N	\N	node	161.142.154.33	\N
27302000-b402-4473-a048-5ebc530b65a6	5de03212-53a6-465c-857b-34e113374e81	2025-06-15 14:38:33.134811+00	2025-06-15 14:38:33.134811+00	\N	aal1	\N	\N	node	161.142.154.33	\N
65bfee21-0587-40b5-8340-71e496997539	1207343f-7e2b-4f82-88ed-7b559f837c08	2025-06-15 14:38:33.239219+00	2025-06-15 14:38:33.239219+00	\N	aal1	\N	\N	node	161.142.154.33	\N
44d35abd-9e04-4c9e-9c69-b92593c926b8	884b5358-cd7d-4b03-84af-fde5a996ac76	2025-06-15 14:38:33.335413+00	2025-06-15 14:38:33.335413+00	\N	aal1	\N	\N	node	161.142.154.33	\N
a92504a5-d43f-4cc9-a6f6-59ee8369af8e	9c533f9b-0de2-4184-8679-ac4124139717	2025-06-15 14:38:33.432027+00	2025-06-15 14:38:33.432027+00	\N	aal1	\N	\N	node	161.142.154.33	\N
51f76af3-6823-46f6-b804-f1cbe491204b	46f9cd41-b08e-4e32-81eb-bb1d3323b3b2	2025-06-15 14:38:33.536878+00	2025-06-15 14:38:33.536878+00	\N	aal1	\N	\N	node	161.142.154.33	\N
8c1f691a-decb-4f68-89b4-e6ba0d765eca	4d6dc0fa-8a2f-4073-9bbd-85425124beb0	2025-06-15 14:38:33.647436+00	2025-06-15 14:38:33.647436+00	\N	aal1	\N	\N	node	161.142.154.33	\N
a2c8bd5a-10f2-456f-89e1-e67e052b4113	e81e22aa-0578-4fb2-8d0b-5665be08b8ee	2025-06-15 14:38:33.750179+00	2025-06-15 14:38:33.750179+00	\N	aal1	\N	\N	node	161.142.154.33	\N
96fd9d01-a3d2-4362-aa6d-e4eda224348b	bf3f6921-ab2d-4b8b-936f-38da5143c31d	2025-06-15 14:38:33.841639+00	2025-06-15 14:38:33.841639+00	\N	aal1	\N	\N	node	161.142.154.33	\N
c1a400b4-0814-4392-b3f2-bce23b192ead	3d06ba74-5af0-499d-81fa-6a61febaa57d	2025-06-15 14:38:33.935645+00	2025-06-15 14:38:33.935645+00	\N	aal1	\N	\N	node	161.142.154.33	\N
38ac2ea6-d3e8-41e2-807e-f163b21c437d	d0e4fb36-fb0a-4767-a333-531cbb37e035	2025-06-15 14:38:34.029443+00	2025-06-15 14:38:34.029443+00	\N	aal1	\N	\N	node	161.142.154.33	\N
5a65b824-8260-4231-a490-c0f0bd2a00bc	cedde969-4985-499b-a05c-5325099bf7aa	2025-06-15 14:38:34.123366+00	2025-06-15 14:38:34.123366+00	\N	aal1	\N	\N	node	161.142.154.33	\N
c88b8dfe-4441-41f4-a445-92ced4a41e03	13b7d6b3-42a7-40ec-b227-f1b91f791dcc	2025-06-15 14:38:34.230715+00	2025-06-15 14:38:34.230715+00	\N	aal1	\N	\N	node	161.142.154.33	\N
de49b6ee-a48c-4242-bde7-39da4850955f	4287988f-93ab-4a3c-9790-77473ef7f799	2025-06-15 14:38:34.331055+00	2025-06-15 14:38:34.331055+00	\N	aal1	\N	\N	node	161.142.154.33	\N
b16d2698-90aa-487c-967f-1aecbce9abe5	12c58e57-7eb9-4e61-a298-52c44ab6e5e2	2025-06-15 14:38:34.422985+00	2025-06-15 14:38:34.422985+00	\N	aal1	\N	\N	node	161.142.154.33	\N
f1114368-61c3-4057-a493-afa9851aac73	f36f7e40-f5fb-4c87-a096-a88c211d6bd2	2025-06-15 14:38:34.524977+00	2025-06-15 14:38:34.524977+00	\N	aal1	\N	\N	node	161.142.154.33	\N
36efb45e-c22d-4080-802b-40e33db9eb83	812c46f2-6962-4df8-90c0-f5dee109c540	2025-06-15 14:38:34.618616+00	2025-06-15 14:38:34.618616+00	\N	aal1	\N	\N	node	161.142.154.33	\N
a7c890e9-9ff0-4287-9eaa-fc2c331f464c	a54f43bc-3510-4267-9c02-de241f28979b	2025-06-15 14:38:34.740066+00	2025-06-15 14:38:34.740066+00	\N	aal1	\N	\N	node	161.142.154.33	\N
1f4bff19-be9c-4074-aef1-c64997ff9748	ded6488b-469e-484e-b815-a00534d3e10f	2025-06-15 14:38:34.840905+00	2025-06-15 14:38:34.840905+00	\N	aal1	\N	\N	node	161.142.154.33	\N
241ad45f-a1b7-407d-aa0b-30825ce26b03	c0c0c1da-11f3-4065-aa98-82084870eea4	2025-06-15 14:38:34.934046+00	2025-06-15 14:38:34.934046+00	\N	aal1	\N	\N	node	161.142.154.33	\N
1ec204ad-ec06-49bd-bdb5-c3572902d684	e0cf9d78-629a-4f0c-8c5e-d4eb659c758a	2025-06-15 14:38:35.021586+00	2025-06-15 14:38:35.021586+00	\N	aal1	\N	\N	node	161.142.154.33	\N
8f7e028d-4cff-4c33-833b-d87852495bf6	0f718b43-671c-4b6f-b906-34ee7b45b4b2	2025-06-15 14:38:35.112943+00	2025-06-15 14:38:35.112943+00	\N	aal1	\N	\N	node	161.142.154.33	\N
7101c805-8560-4a73-8a42-fc9a48f598f1	c3430ef8-bea7-4d77-840d-7e1847682f45	2025-06-15 14:38:35.208038+00	2025-06-15 14:38:35.208038+00	\N	aal1	\N	\N	node	161.142.154.33	\N
1579b4f9-4445-4c8c-a51d-5725da6737dc	0dfa2c7d-310b-4a83-98f5-197421843955	2025-06-15 14:38:35.309234+00	2025-06-15 14:38:35.309234+00	\N	aal1	\N	\N	node	161.142.154.33	\N
4dffda68-8d40-477d-aeb3-f66b9ebfc285	b0b2df8d-3835-4d06-a95d-d6a376b95ea1	2025-06-15 14:38:35.404821+00	2025-06-15 14:38:35.404821+00	\N	aal1	\N	\N	node	161.142.154.33	\N
7f420e2e-d0c9-4311-beab-798268faf057	1f99b32d-2a96-4760-b450-ed45b0abe4d1	2025-06-15 14:38:35.5032+00	2025-06-15 14:38:35.5032+00	\N	aal1	\N	\N	node	161.142.154.33	\N
618f0ff1-8b81-4ba5-971d-d2ce5e5bfe9f	1b9260e9-b2bc-4ac3-86ed-cd13d669bd46	2025-06-15 14:38:35.602554+00	2025-06-15 14:38:35.602554+00	\N	aal1	\N	\N	node	161.142.154.33	\N
aa0383f2-e106-45c4-a716-feda25a6ec83	457acf64-4b5a-49a5-8f67-2aa577cec7ec	2025-06-15 14:38:35.697745+00	2025-06-15 14:38:35.697745+00	\N	aal1	\N	\N	node	161.142.154.33	\N
2fa4ac6f-3441-4e81-8543-75d0165933df	f22bd07e-28a0-4135-b73e-fb6629087485	2025-06-15 14:38:35.79336+00	2025-06-15 14:38:35.79336+00	\N	aal1	\N	\N	node	161.142.154.33	\N
5e02c7d9-7a97-477b-b20c-d51ab495fc29	80708127-7fdf-4c9d-8b6f-315c374c0cf4	2025-06-15 14:38:35.887219+00	2025-06-15 14:38:35.887219+00	\N	aal1	\N	\N	node	161.142.154.33	\N
f32442c1-9fca-4c4e-a59c-a81f4f24950e	536203a3-6335-4c60-ae6f-f852135c5419	2025-06-15 14:38:35.990761+00	2025-06-15 14:38:35.990761+00	\N	aal1	\N	\N	node	161.142.154.33	\N
c539e76c-cfd8-425d-a1ba-ee449a312e22	4da24124-a1ef-4efe-832d-a89ddfd8945a	2025-06-15 14:38:36.087044+00	2025-06-15 14:38:36.087044+00	\N	aal1	\N	\N	node	161.142.154.33	\N
f7632760-0abc-4f3e-b60c-afa3c672e337	3ce70501-e74f-4420-bc0a-3eac51f2dbe4	2025-06-15 14:38:36.180374+00	2025-06-15 14:38:36.180374+00	\N	aal1	\N	\N	node	161.142.154.33	\N
f066c0fa-d577-4353-ab01-59b3810da7cb	d8d76d24-14d4-4e46-92ad-5907d27fe2e0	2025-06-15 14:38:36.276594+00	2025-06-15 14:38:36.276594+00	\N	aal1	\N	\N	node	161.142.154.33	\N
b405dbf2-4b93-43f8-abac-bbbaae099b85	e80a6ccf-333b-407f-ae20-ae04ee67f667	2025-06-15 14:38:36.373158+00	2025-06-15 14:38:36.373158+00	\N	aal1	\N	\N	node	161.142.154.33	\N
7f1746a9-1a74-4fdd-8a47-46f1fda37650	7c42038f-aa20-4f20-ba43-839d3474a560	2025-06-15 14:38:36.472898+00	2025-06-15 14:38:36.472898+00	\N	aal1	\N	\N	node	161.142.154.33	\N
9a38fcef-e16a-4d0f-8cd1-469a2d2dfdb4	a0b845cc-2c32-421e-9f3e-ebfe8e22cd15	2025-06-15 14:38:36.567752+00	2025-06-15 14:38:36.567752+00	\N	aal1	\N	\N	node	161.142.154.33	\N
84d02d90-9188-4235-88d5-fbb30c69f6a5	e5871981-e66c-4c44-9183-0e8084e874c9	2025-06-15 14:38:36.670593+00	2025-06-15 14:38:36.670593+00	\N	aal1	\N	\N	node	161.142.154.33	\N
aac69f4b-028c-4850-b53b-a011b81c92d6	582f5571-b638-444b-9527-12503ce384a3	2025-06-15 14:38:36.764151+00	2025-06-15 14:38:36.764151+00	\N	aal1	\N	\N	node	161.142.154.33	\N
cd199602-9f2f-4f99-8c38-f61914e1ed2e	05039a36-049a-47b0-9e99-6de64a44acbd	2025-06-15 14:38:36.86247+00	2025-06-15 14:38:36.86247+00	\N	aal1	\N	\N	node	161.142.154.33	\N
db551758-9e36-4b57-a30b-0357800e694a	14e4c67b-bcde-4704-a97f-0dcbe1717dc5	2025-06-15 14:38:36.955998+00	2025-06-15 14:38:36.955998+00	\N	aal1	\N	\N	node	161.142.154.33	\N
5d6e9b68-1c6a-44df-a1b3-7d822eae359e	34e9281c-a3b1-412d-ba7e-fe29dad024c9	2025-06-15 14:38:37.141828+00	2025-06-15 14:38:37.141828+00	\N	aal1	\N	\N	node	161.142.154.33	\N
0e98717d-4be6-4acc-8b0d-c545fa7b8141	8d6c1385-fa01-48c7-b761-4e0ebdcab162	2025-06-15 14:38:37.244018+00	2025-06-15 14:38:37.244018+00	\N	aal1	\N	\N	node	161.142.154.33	\N
36812ea8-18b8-4cb5-92a5-8d2284faa17a	d8b08679-718a-49dc-a81d-141d5a5b048d	2025-06-15 14:38:37.341453+00	2025-06-15 14:38:37.341453+00	\N	aal1	\N	\N	node	161.142.154.33	\N
a52086ca-5127-4033-b677-d388d3bccff7	54003f0f-9dc2-4142-a7a3-37781c6caa2f	2025-06-15 14:38:37.43752+00	2025-06-15 14:38:37.43752+00	\N	aal1	\N	\N	node	161.142.154.33	\N
f3968c55-bcb3-4fa3-a3ea-648aa0c9e429	0a7806d8-7b08-4629-bcfc-b5304bc684c4	2025-06-15 14:38:37.52796+00	2025-06-15 14:38:37.52796+00	\N	aal1	\N	\N	node	161.142.154.33	\N
f5e38c61-2007-4c26-aa98-34d19d81803b	2abe0ef5-50a6-4f32-bcd0-ccbb192771c5	2025-06-15 14:38:37.622411+00	2025-06-15 14:38:37.622411+00	\N	aal1	\N	\N	node	161.142.154.33	\N
8db827ad-6a40-46dc-8b6f-681772e0dc2e	0919a2be-3b19-418f-91e8-ae8a8ffd3e48	2025-06-15 14:38:37.731179+00	2025-06-15 14:38:37.731179+00	\N	aal1	\N	\N	node	161.142.154.33	\N
a965a3bd-6ed7-402a-9f3f-99d36319e393	01f2db6b-0dc0-45f1-842b-aced9d793fe6	2025-06-15 14:38:37.823341+00	2025-06-15 14:38:37.823341+00	\N	aal1	\N	\N	node	161.142.154.33	\N
035bd06d-0d80-4ef3-8702-ca42e35679cb	2fc4583b-c10b-423a-a6fe-a5e25b7bc801	2025-06-15 14:38:37.926444+00	2025-06-15 14:38:37.926444+00	\N	aal1	\N	\N	node	161.142.154.33	\N
cd93f4ec-cb6f-4cfb-9593-3ad1be6cd4e7	15f0f3a4-341a-4342-bca2-11c1d03d82a6	2025-06-15 14:38:38.029294+00	2025-06-15 14:38:38.029294+00	\N	aal1	\N	\N	node	161.142.154.33	\N
593788b5-9131-427f-bec4-16e09b64209c	4af83a63-96e1-44ea-a7aa-749a66e5fcd7	2025-06-15 14:38:38.121949+00	2025-06-15 14:38:38.121949+00	\N	aal1	\N	\N	node	161.142.154.33	\N
13e258e1-f285-4b64-847e-4f3c4982e6e7	24f097e0-aad9-486d-887d-590379cf8f78	2025-06-15 14:38:38.21759+00	2025-06-15 14:38:38.21759+00	\N	aal1	\N	\N	node	161.142.154.33	\N
684ea30d-843d-47ad-9326-4b427ba89899	3a62ecb7-b6c8-4883-9066-4e1a871adc12	2025-06-15 14:38:38.308336+00	2025-06-15 14:38:38.308336+00	\N	aal1	\N	\N	node	161.142.154.33	\N
e338edc8-5617-48a2-9b9e-f0f7ba7d9113	e8e773cd-d387-4efc-b92e-98dd804a3dd3	2025-06-15 14:38:38.584724+00	2025-06-15 14:38:38.584724+00	\N	aal1	\N	\N	node	161.142.154.33	\N
eef49338-073d-4030-9f8f-be1a4a6e0771	e1ccea0a-ccc5-48c9-98dd-26a48399ec52	2025-06-15 14:38:38.678307+00	2025-06-15 14:38:38.678307+00	\N	aal1	\N	\N	node	161.142.154.33	\N
86b649f9-f05c-4a06-ba60-d9757d134e7e	cc6ec44c-3285-40f9-84fd-fe38f6cac978	2025-06-15 14:38:38.780852+00	2025-06-15 14:38:38.780852+00	\N	aal1	\N	\N	node	161.142.154.33	\N
7b6acbcb-b4cf-4547-8bb5-f25a0b563ae1	5ad2dbaf-6d13-47a0-b9d2-47b7adb86ff0	2025-06-15 14:38:38.878224+00	2025-06-15 14:38:38.878224+00	\N	aal1	\N	\N	node	161.142.154.33	\N
d0dc835d-968a-401b-a586-84744806fcb3	7d417c53-b437-40ff-911a-8d9eef5e2977	2025-06-15 14:38:38.978189+00	2025-06-15 14:38:38.978189+00	\N	aal1	\N	\N	node	161.142.154.33	\N
4dc7f2f8-79ba-410c-904f-6295e832eb84	e6dae6f9-e483-4071-923d-095f173ed23e	2025-06-15 14:38:39.07089+00	2025-06-15 14:38:39.07089+00	\N	aal1	\N	\N	node	161.142.154.33	\N
7e855504-d59c-4456-b5e2-3c9b2fd21114	24d8cbc0-b247-4c06-bd71-80c775c228f0	2025-06-15 14:38:39.163368+00	2025-06-15 14:38:39.163368+00	\N	aal1	\N	\N	node	161.142.154.33	\N
463af394-8030-4ff7-bc7e-74713ac8627f	c03ad22a-b91d-4788-9b2e-d4e016651a9b	2025-06-15 14:38:39.267161+00	2025-06-15 14:38:39.267161+00	\N	aal1	\N	\N	node	161.142.154.33	\N
52f16e75-757b-4178-82c7-72b54d145d9f	fe48a53d-699e-4b91-9987-efdd47b9b34b	2025-06-15 14:38:39.365984+00	2025-06-15 14:38:39.365984+00	\N	aal1	\N	\N	node	161.142.154.33	\N
539b81cf-d375-448b-9de7-7ef0c66c2040	54762cd7-e15c-4dfe-b8c3-620921ec2366	2025-06-15 14:38:39.465722+00	2025-06-15 14:38:39.465722+00	\N	aal1	\N	\N	node	161.142.154.33	\N
84b67e85-4871-4b8c-809e-7a75a5d299be	6b17a4a1-6399-4241-8bae-98ce72ffd9b8	2025-06-15 14:38:39.564342+00	2025-06-15 14:38:39.564342+00	\N	aal1	\N	\N	node	161.142.154.33	\N
d348e60f-9e10-4062-aa87-f32953690ad5	646b90b4-51f9-44ce-9e89-41492cb826f9	2025-06-15 14:38:39.662575+00	2025-06-15 14:38:39.662575+00	\N	aal1	\N	\N	node	161.142.154.33	\N
a1a6d6ca-afde-42fd-a5a6-84b5f1588867	6f88c691-03be-4853-8903-67e2bca0d234	2025-06-15 14:38:39.773002+00	2025-06-15 14:38:39.773002+00	\N	aal1	\N	\N	node	161.142.154.33	\N
f5cefc28-e9fd-460c-aed5-f7282ba13407	33f581a6-b5de-49d8-acdd-1166f5a55844	2025-06-15 14:38:39.872573+00	2025-06-15 14:38:39.872573+00	\N	aal1	\N	\N	node	161.142.154.33	\N
25a0ac93-428f-4941-9a7d-001518e49980	a31bd0c1-174b-4922-a1b7-e60acc9b25b4	2025-06-15 14:38:39.96837+00	2025-06-15 14:38:39.96837+00	\N	aal1	\N	\N	node	161.142.154.33	\N
2b1cfd8a-c4ba-4ac0-a8e8-17ca04e7ec6c	0492f0e6-5805-44af-aa74-4db0c77a4140	2025-06-15 14:38:40.065048+00	2025-06-15 14:38:40.065048+00	\N	aal1	\N	\N	node	161.142.154.33	\N
4b186324-1322-4af1-91f6-55be20d380fa	6a07ae1f-58b7-49a3-b140-407f7039c517	2025-06-15 14:38:40.155318+00	2025-06-15 14:38:40.155318+00	\N	aal1	\N	\N	node	161.142.154.33	\N
8cf9a821-e08d-431d-8740-d297bfd1915a	25c9e59a-dddc-4e8d-9b27-4033d9f1274a	2025-06-15 14:38:40.247793+00	2025-06-15 14:38:40.247793+00	\N	aal1	\N	\N	node	161.142.154.33	\N
1fce5698-97d2-4833-9902-15be57024502	4120635d-c542-437d-9cea-9319b2338db0	2025-06-15 14:38:40.3448+00	2025-06-15 14:38:40.3448+00	\N	aal1	\N	\N	node	161.142.154.33	\N
09a319fd-4201-4d52-9d7c-fdbeebf5b878	93a02249-5316-49a2-9ac7-12b4c8905133	2025-06-15 14:38:40.446363+00	2025-06-15 14:38:40.446363+00	\N	aal1	\N	\N	node	161.142.154.33	\N
5ebb5f73-f433-4fc1-ab06-e1fd530c3f72	fd863516-76ca-4417-8047-db3bdf0cb04e	2025-06-15 14:38:40.539868+00	2025-06-15 14:38:40.539868+00	\N	aal1	\N	\N	node	161.142.154.33	\N
ea77802f-ee85-49dc-ba21-f5a4e75653b4	e8eef5b6-23c8-43b6-b361-5407820aa1bd	2025-06-15 14:38:40.634968+00	2025-06-15 14:38:40.634968+00	\N	aal1	\N	\N	node	161.142.154.33	\N
18cf94ec-2de1-4d82-abc7-e7dba54967d1	0e4b6571-d7da-4d82-8035-b53821d50643	2025-06-15 14:38:40.726007+00	2025-06-15 14:38:40.726007+00	\N	aal1	\N	\N	node	161.142.154.33	\N
be1ac062-24be-4b14-9c5a-6d19878a9e71	3daebba2-2008-456d-85ff-0f51d49e2068	2025-06-15 14:38:40.81844+00	2025-06-15 14:38:40.81844+00	\N	aal1	\N	\N	node	161.142.154.33	\N
6e22abed-080f-441f-ba80-fb744a7e8025	79e11466-b344-4852-81cb-39ff9e45ebc0	2025-06-15 14:38:40.920007+00	2025-06-15 14:38:40.920007+00	\N	aal1	\N	\N	node	161.142.154.33	\N
d30b712c-5641-4e3c-9988-0c040522fd04	4838f267-e471-42c2-960a-afb1bbe50dd5	2025-06-15 14:38:41.014982+00	2025-06-15 14:38:41.014982+00	\N	aal1	\N	\N	node	161.142.154.33	\N
69478523-79ff-4000-b7bc-79d8ab82c7fc	4735ce34-ed6c-4b84-a258-c098689ca12f	2025-06-15 14:38:41.111796+00	2025-06-15 14:38:41.111796+00	\N	aal1	\N	\N	node	161.142.154.33	\N
94d1578e-0289-48e3-b538-4bf6a6c6ce4e	0b500a7c-c000-4b0f-b19a-4cc42e3d380e	2025-06-15 14:38:41.206914+00	2025-06-15 14:38:41.206914+00	\N	aal1	\N	\N	node	161.142.154.33	\N
6266a739-fca5-4399-9347-3d4729347e29	80c123de-90b0-4fd6-9424-1e93e57c96fb	2025-06-15 14:38:41.301255+00	2025-06-15 14:38:41.301255+00	\N	aal1	\N	\N	node	161.142.154.33	\N
114af36d-cf3e-46dc-a7da-535f09b60748	bcc22448-661c-4e28-99a8-edb83a48195e	2025-06-15 14:38:41.390807+00	2025-06-15 14:38:41.390807+00	\N	aal1	\N	\N	node	161.142.154.33	\N
22aa14b8-646e-40ad-92ac-86aa278885f8	77580fe9-7ac2-4fb0-9aa7-06995f768dea	2025-06-15 14:38:41.481415+00	2025-06-15 14:38:41.481415+00	\N	aal1	\N	\N	node	161.142.154.33	\N
0ffcdc7f-e6c9-4e24-8102-7cf4510edc70	1d351dae-d3b7-476d-9c6a-c3851e6117f8	2025-06-15 14:38:41.58031+00	2025-06-15 14:38:41.58031+00	\N	aal1	\N	\N	node	161.142.154.33	\N
925680c5-f408-4c0e-9009-9e35924af125	b37636b3-8be1-4178-9cf2-8b57f5394441	2025-06-15 14:38:41.671409+00	2025-06-15 14:38:41.671409+00	\N	aal1	\N	\N	node	161.142.154.33	\N
0300ce43-82b9-4045-9776-57092df2e429	86c5fd15-a47d-44b9-94f9-864b787d7db8	2025-06-15 14:38:41.769735+00	2025-06-15 14:38:41.769735+00	\N	aal1	\N	\N	node	161.142.154.33	\N
a5dc11fb-8af0-4bb0-aecb-cf0fc8cb4a13	26e06765-0726-4760-a956-cd6c133c8cf1	2025-06-15 14:38:41.870914+00	2025-06-15 14:38:41.870914+00	\N	aal1	\N	\N	node	161.142.154.33	\N
5bf22f34-8d90-4d14-997b-50683b771b7e	9899069d-e0c6-4dec-b3cd-e4080a838f61	2025-06-15 14:38:41.966896+00	2025-06-15 14:38:41.966896+00	\N	aal1	\N	\N	node	161.142.154.33	\N
15bd2547-76ef-4253-94fa-c92dc3f7bf71	43e2d156-815e-45bc-a9c4-959ffc35a607	2025-06-15 14:38:42.059846+00	2025-06-15 14:38:42.059846+00	\N	aal1	\N	\N	node	161.142.154.33	\N
c048950c-e803-4a90-be73-6be0f8b7bbfa	97f7ac1a-aaf7-4061-8dba-cef646b37a3b	2025-06-15 14:38:42.156774+00	2025-06-15 14:38:42.156774+00	\N	aal1	\N	\N	node	161.142.154.33	\N
4d46961c-6ef7-4e49-92ab-c9bb1dec1ea9	e24e82c5-482d-44c5-95e4-0dec79afeffc	2025-06-15 14:38:42.248974+00	2025-06-15 14:38:42.248974+00	\N	aal1	\N	\N	node	161.142.154.33	\N
3051d6ee-1f6e-4708-ac85-99af82fd3283	9bfb750a-2c2d-4bfc-9999-44fdabda74dd	2025-06-15 14:38:42.352983+00	2025-06-15 14:38:42.352983+00	\N	aal1	\N	\N	node	161.142.154.33	\N
6a06e0cc-7286-450f-9200-90f60a83b880	fc2ca455-d9cb-44de-a313-e5f66f65a688	2025-06-15 14:38:42.44884+00	2025-06-15 14:38:42.44884+00	\N	aal1	\N	\N	node	161.142.154.33	\N
955895f1-1a1f-4ff6-82e5-1d0536cfb1e9	ad892dc0-1949-48b7-be5e-d63c7290e512	2025-06-15 15:27:22.195929+00	2025-06-16 03:10:02.3258+00	\N	aal1	\N	2025-06-16 03:10:02.325728	Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/137.0.0.0 Safari/537.36	161.142.154.33	\N
7f876ce2-67d5-45dc-a032-0cdfc0affd72	016ca48e-66c5-476c-9716-c6397ed60e69	2025-06-23 07:44:52.037421+00	2025-06-23 07:44:52.037421+00	\N	aal1	\N	\N	node	185.93.166.49	\N
7e382f3e-b658-4f4a-9b77-58e810ca5764	bb194837-db77-40d9-a6fd-5e9737c5724e	2025-06-18 02:09:49.682408+00	2025-06-18 07:00:15.797084+00	\N	aal1	\N	2025-06-18 07:00:15.797033	node	185.93.166.49	\N
efb68f12-79b0-455b-9f15-a9ab33984d1a	a007885a-80b3-4486-b31c-6652abca3e12	2025-06-23 03:30:20.271873+00	2025-06-23 07:15:50.606776+00	\N	aal1	\N	2025-06-23 07:15:50.606715	Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/137.0.0.0 Safari/537.36	115.135.13.85	\N
82401c0e-53bd-4366-b603-47f7dceab31f	bb194837-db77-40d9-a6fd-5e9737c5724e	2025-06-18 02:12:53.843902+00	2025-06-18 02:12:53.843902+00	\N	aal1	\N	\N	Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/137.0.0.0 Safari/537.36	60.53.68.148	\N
b34856b8-4794-4701-a9a8-978a002cadc5	8bc44ea0-2e33-458a-ac4d-298980c44b05	2025-06-23 07:40:12.643265+00	2025-06-23 07:40:12.643265+00	\N	aal1	\N	\N	node	185.93.166.49	\N
0e4828de-890a-4049-a76e-6649849e1fa4	e2c36046-d53b-4a02-9eef-f85a47d6c357	2025-06-23 07:40:13.679482+00	2025-06-23 07:40:13.679482+00	\N	aal1	\N	\N	node	185.93.166.49	\N
1f1e156d-40d6-422f-8967-ddea884ee4be	20754c43-864b-45c9-8e9d-5f71b3dceb39	2025-06-23 07:40:45.980964+00	2025-06-23 07:40:45.980964+00	\N	aal1	\N	\N	node	185.93.166.49	\N
c9bc747b-2090-48d2-bab7-c96f0827218c	a1008ee6-6805-4d56-956d-0bcaad374870	2025-06-23 07:40:50.633405+00	2025-06-23 07:40:50.633405+00	\N	aal1	\N	\N	node	185.93.166.49	\N
5058bd72-d893-4089-b8d2-4716b76417c3	a007885a-80b3-4486-b31c-6652abca3e12	2025-06-23 05:49:16.723621+00	2025-06-23 07:41:38.939916+00	\N	aal1	\N	2025-06-23 07:41:38.939859	Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/137.0.0.0 Safari/537.36	115.135.13.45	\N
7ea6f5b5-0c06-418c-ac38-ac63530b46e3	fd238175-c03f-4b7a-a819-0837b802ae2c	2025-06-23 07:41:53.957507+00	2025-06-23 07:41:53.957507+00	\N	aal1	\N	\N	node	185.93.166.49	\N
287974ec-b8fd-49a1-87e6-1b573907dfa2	5dfc121a-a553-4380-9094-d716a81b495f	2025-06-23 07:41:59.340776+00	2025-06-23 07:41:59.340776+00	\N	aal1	\N	\N	node	185.93.166.49	\N
912238d3-fec6-49a3-acf0-d36999f94957	ba467302-a9dd-49f1-bb39-442fdab37dcd	2025-06-23 07:42:01.102896+00	2025-06-23 07:42:01.102896+00	\N	aal1	\N	\N	node	185.93.166.49	\N
b5909235-9f82-4f30-8cd9-708ab783d880	3f695e7a-da08-4344-8d1c-60d1e4d3d772	2025-06-23 07:42:25.112359+00	2025-06-23 07:42:25.112359+00	\N	aal1	\N	\N	node	185.93.166.49	\N
51789518-b5e5-474d-bd6a-c6d24e877d2e	5dfc121a-a553-4380-9094-d716a81b495f	2025-06-23 07:42:27.067541+00	2025-06-23 07:42:27.067541+00	\N	aal1	\N	\N	Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/137.0.0.0 Safari/537.36	115.135.13.45	\N
d28d6771-8507-4f58-96ff-669dc3bb8320	e4f7c6ca-5cfe-411a-a814-45a13ee76fe4	2025-06-23 07:42:27.470268+00	2025-06-23 07:42:27.470268+00	\N	aal1	\N	\N	node	185.93.166.49	\N
ea1e938d-d79a-478c-aaad-4cba83b0dbcf	878637b4-5c02-462a-80e3-edd2cb4dd365	2025-06-23 07:42:35.156014+00	2025-06-23 07:42:35.156014+00	\N	aal1	\N	\N	node	185.93.166.49	\N
d01dcdbd-208b-483b-93c2-28ba38ac94f2	2186e85a-0204-40d2-ac5a-1ae7600edfa3	2025-06-23 07:42:35.314943+00	2025-06-23 07:42:35.314943+00	\N	aal1	\N	\N	node	185.93.166.49	\N
85b48456-18f7-40e2-be9a-57a1431c8d26	f7280a96-7703-4d4d-b2a8-9d2acc15a160	2025-06-23 07:42:41.78061+00	2025-06-23 07:42:41.78061+00	\N	aal1	\N	\N	node	185.93.166.49	\N
3aea7dc8-47d2-43a9-bb4b-a6eac5c42e54	9e2f17ea-26c5-414b-835c-f9b42705c024	2025-06-23 07:42:52.935059+00	2025-06-23 07:42:52.935059+00	\N	aal1	\N	\N	node	185.93.166.49	\N
8470770d-76f1-4d73-91b7-fa82d2e2d5e1	7df7ea94-16ba-4fd6-85bc-4fd0155fe284	2025-06-23 07:43:02.126598+00	2025-06-23 07:43:02.126598+00	\N	aal1	\N	\N	node	185.93.166.49	\N
ac52d839-e71a-48b1-94d0-95f13e9f1978	bc9650f6-a750-4deb-98f6-636b76c60b62	2025-06-23 07:43:10.627133+00	2025-06-23 07:43:10.627133+00	\N	aal1	\N	\N	node	185.93.166.49	\N
9a069c31-d0f1-4c9a-ab91-7e1632123f66	0d12ddb0-122b-46a3-afba-c35c8640e887	2025-06-23 07:43:26.708888+00	2025-06-23 07:43:26.708888+00	\N	aal1	\N	\N	node	185.93.166.49	\N
cd5320e6-739d-44ab-9dd2-b7c9e640e981	a4051467-1969-4a0f-8657-d8f3f0ba6359	2025-06-23 07:43:52.637634+00	2025-06-23 07:43:52.637634+00	\N	aal1	\N	\N	node	185.93.166.49	\N
86573a3f-5f86-4914-8e73-ccf9f67cc9bf	0cd2be50-abf7-420e-a986-7fa5371cf6a3	2025-06-23 07:44:11.301196+00	2025-06-23 07:44:11.301196+00	\N	aal1	\N	\N	node	185.93.166.49	\N
c16000a8-d9a2-4fe9-82fb-b06158494cad	ba467302-a9dd-49f1-bb39-442fdab37dcd	2025-06-23 07:44:15.552922+00	2025-06-23 07:44:15.552922+00	\N	aal1	\N	\N	Mozilla/5.0 (Macintosh; Intel Mac OS X 10_15_7) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/135.0.0.0 Safari/537.36	115.135.13.45	\N
f3043ad1-34c9-44f8-97cc-21b19eeff073	e4f7c6ca-5cfe-411a-a814-45a13ee76fe4	2025-06-23 07:44:23.618307+00	2025-06-23 07:44:23.618307+00	\N	aal1	\N	\N	Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/137.0.0.0 Safari/537.36	115.135.13.45	\N
753af9c7-5823-4641-b570-8426301bf0ec	ac59ee7e-0939-4e05-bf57-be9508f40d82	2025-06-23 07:44:36.500043+00	2025-06-23 07:44:36.500043+00	\N	aal1	\N	\N	node	185.93.166.49	\N
0c7a3acd-07ff-4323-8e09-083d46383d78	878637b4-5c02-462a-80e3-edd2cb4dd365	2025-06-23 07:44:40.29095+00	2025-06-23 07:44:40.29095+00	\N	aal1	\N	\N	Mozilla/5.0 (Macintosh; Intel Mac OS X 10_15_7) AppleWebKit/605.1.15 (KHTML, like Gecko) Version/18.5 Safari/605.1.15	183.171.69.50	\N
bc1a409c-1b65-4ea4-a742-366b7d180437	08a2cbdf-9a26-4469-9034-ed7b3f5b73e9	2025-06-23 07:44:52.388778+00	2025-06-23 07:44:52.388778+00	\N	aal1	\N	\N	node	185.93.166.49	\N
1ffd9ad7-680c-491b-9648-5eef8aacb3cc	e2c36046-d53b-4a02-9eef-f85a47d6c357	2025-06-23 07:45:00.73986+00	2025-06-23 07:45:00.73986+00	\N	aal1	\N	\N	Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/137.0.0.0 Safari/537.36	115.135.13.45	\N
cfe63d34-0594-4dfe-a86c-8080d0b0e8e0	ee74b89d-137d-470c-8a00-90fb5a372727	2025-06-23 07:45:13.47492+00	2025-06-23 07:45:13.47492+00	\N	aal1	\N	\N	node	185.93.166.49	\N
65846dba-299a-4ee4-872c-4721fd36bab4	47676bae-55c6-48f5-8b6a-dc0a3af02ec4	2025-06-23 07:45:26.433524+00	2025-06-23 07:45:26.433524+00	\N	aal1	\N	\N	node	185.93.166.49	\N
bd4d9ea5-d462-467e-919d-306e37aa7f8c	1698b43a-831d-455f-bb6f-22c3097c005f	2025-06-23 07:45:27.892199+00	2025-06-23 07:45:27.892199+00	\N	aal1	\N	\N	node	185.93.166.49	\N
90bf53e9-8183-411f-9959-7b1cdfd3bfa6	3142bce6-7211-4fd1-a09f-1d17e6cf287a	2025-06-23 07:45:30.95588+00	2025-06-23 07:45:30.95588+00	\N	aal1	\N	\N	node	185.93.166.49	\N
592fd046-4bac-4927-b7d3-17a358e89f7f	9e6b451a-3a18-4f0c-97f3-fcccefe12a55	2025-06-23 07:45:35.864658+00	2025-06-23 07:45:35.864658+00	\N	aal1	\N	\N	node	185.93.166.49	\N
965d164c-dbc2-4ec4-b988-89ba41752be4	a829ccb9-78d5-4940-82f6-934352e828cd	2025-06-23 07:45:50.214074+00	2025-06-23 07:45:50.214074+00	\N	aal1	\N	\N	node	185.93.166.49	\N
7eb85347-6fef-4d38-ae44-292432a519a8	6dc3e17b-1af0-4a4b-abaf-a9830465a207	2025-06-23 07:45:55.127345+00	2025-06-23 07:45:55.127345+00	\N	aal1	\N	\N	node	185.93.166.49	\N
1a90df89-1c9f-46ef-9a5b-e78659533146	4e579a51-bb42-45f1-9b79-b84928a98421	2025-06-23 07:46:01.257501+00	2025-06-23 07:46:01.257501+00	\N	aal1	\N	\N	node	185.93.166.49	\N
c4bd5a60-1a47-4dd0-95f1-dca299b3d1f7	08a2cbdf-9a26-4469-9034-ed7b3f5b73e9	2025-06-23 07:46:05.226045+00	2025-06-23 07:46:05.226045+00	\N	aal1	\N	\N	Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/137.0.0.0 Safari/537.36	115.135.13.45	\N
eec2daee-4f23-4917-a85a-5356bff36e80	7d693d50-00d4-4a9b-9bc0-35afebbb30d9	2025-06-23 07:46:08.169972+00	2025-06-23 07:46:08.169972+00	\N	aal1	\N	\N	node	185.93.166.49	\N
aef2f822-7459-4b19-a7c5-9124cc6357ae	8bc44ea0-2e33-458a-ac4d-298980c44b05	2025-06-23 07:42:39.769589+00	2025-06-23 13:37:10.614581+00	\N	aal1	\N	2025-06-23 13:37:10.614519	Mozilla/5.0 (Macintosh; Intel Mac OS X 10_15_7) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/137.0.0.0 Safari/537.36	202.188.12.126	\N
d0e9f4a5-aca5-4573-9074-71a53c6f42c9	7f05337a-1f10-411a-8c90-ab632faaf8c2	2025-06-23 07:46:22.356089+00	2025-06-23 07:46:22.356089+00	\N	aal1	\N	\N	node	185.93.166.49	\N
b3b8d5d9-5a37-40db-b7f2-87461e8aba33	7b53d13f-0338-44ff-a05d-238f8d25cad4	2025-06-23 07:46:31.432483+00	2025-06-23 07:46:31.432483+00	\N	aal1	\N	\N	node	185.93.166.49	\N
af811759-bcd5-4155-b8fa-f9437789acb2	6c383e4a-a52d-4661-8a6c-4be47b0ed340	2025-06-23 07:46:53.269862+00	2025-06-23 07:46:53.269862+00	\N	aal1	\N	\N	node	185.93.166.49	\N
f2e6d99d-3e50-4869-8cdb-dcb845e5a11f	9e6b451a-3a18-4f0c-97f3-fcccefe12a55	2025-06-23 07:46:58.140402+00	2025-06-23 07:46:58.140402+00	\N	aal1	\N	\N	Mozilla/5.0 (X11; Linux x86_64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/137.0.0.0 Safari/537.36	183.171.101.200	\N
4b4f4c43-f116-4c12-a61e-ccc7efb1cc4e	8175ff46-a82f-41f1-9650-87661f8acbb1	2025-06-23 07:47:12.294903+00	2025-06-23 07:47:12.294903+00	\N	aal1	\N	\N	node	185.93.166.49	\N
9d128b8a-4d51-483c-9194-80ce946f3bda	59874f8b-4fdf-41ce-947b-da9240a861ca	2025-06-23 07:47:12.316072+00	2025-06-23 07:47:12.316072+00	\N	aal1	\N	\N	node	185.93.166.49	\N
1d935b35-044b-4905-9c9a-8aeea5d93faa	13889f78-4916-4d07-8c07-faf25d913216	2025-06-23 07:47:32.54109+00	2025-06-23 07:47:32.54109+00	\N	aal1	\N	\N	node	185.93.166.49	\N
e931c2a6-23fe-4015-9bc3-6421e0410b81	9e2f17ea-26c5-414b-835c-f9b42705c024	2025-06-23 07:47:36.221049+00	2025-06-23 07:47:36.221049+00	\N	aal1	\N	\N	Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/137.0.0.0 Safari/537.36	115.135.13.45	\N
1b9f4822-7bd3-4c91-ab54-26d320856159	9ad14374-7580-4a86-a7e7-7e1450f96333	2025-06-23 07:48:00.339765+00	2025-06-23 07:48:00.339765+00	\N	aal1	\N	\N	node	185.93.166.49	\N
cd689551-d304-443c-b46f-5c6d1c818cb3	c31c618f-5148-41bb-802d-025b2b70965a	2025-06-23 07:48:23.005968+00	2025-06-23 07:48:23.005968+00	\N	aal1	\N	\N	node	185.93.166.49	\N
d99f8e4c-19c1-414f-a337-3c27803f3c7e	7b53d13f-0338-44ff-a05d-238f8d25cad4	2025-06-23 07:50:11.153102+00	2025-06-23 07:50:11.153102+00	\N	aal1	\N	\N	Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/137.0.0.0 Safari/537.36	115.135.13.45	\N
1532b437-1a52-417b-9e61-dbfbdc0b88d1	1698b43a-831d-455f-bb6f-22c3097c005f	2025-06-23 07:50:49.589833+00	2025-06-23 07:50:49.589833+00	\N	aal1	\N	\N	Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/135.0.0.0 Safari/537.36	115.135.13.45	\N
0c6a685e-91e1-42bc-9d5d-23ef862fda71	3142bce6-7211-4fd1-a09f-1d17e6cf287a	2025-06-23 07:51:04.745125+00	2025-06-23 07:51:04.745125+00	\N	aal1	\N	\N	Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/137.0.0.0 Safari/537.36	115.135.13.45	\N
3977c47c-a631-42f6-b3e2-362e0fa99c5b	7f05337a-1f10-411a-8c90-ab632faaf8c2	2025-06-23 07:51:06.860297+00	2025-06-23 07:51:06.860297+00	\N	aal1	\N	\N	Mozilla/5.0 (Linux; Android 10; K) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/137.0.0.0 Mobile Safari/537.36	183.171.112.219	\N
e867c70d-26ca-4340-93de-8b4fb2263c95	a6ee5043-034b-496f-acc8-328104c06ed9	2025-06-23 07:51:10.640868+00	2025-06-23 07:51:10.640868+00	\N	aal1	\N	\N	node	185.93.166.49	\N
34c4690d-2fc4-4af9-a091-1018463878c8	fd238175-c03f-4b7a-a819-0837b802ae2c	2025-06-23 07:51:23.776378+00	2025-06-23 07:51:23.776378+00	\N	aal1	\N	\N	Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/136.0.0.0 Safari/537.36	115.135.13.45	\N
bb335723-588d-41f9-b329-aa02dd719102	a1008ee6-6805-4d56-956d-0bcaad374870	2025-06-23 07:52:48.198197+00	2025-06-23 07:52:48.198197+00	\N	aal1	\N	\N	Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/137.0.0.0 Safari/537.36	115.135.13.45	\N
a6b36d0d-53bf-4a0b-b8a4-74a0f75552b0	ac59ee7e-0939-4e05-bf57-be9508f40d82	2025-06-23 07:52:49.604706+00	2025-06-23 07:52:49.604706+00	\N	aal1	\N	\N	Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/137.0.0.0 Safari/537.36 Edg/137.0.0.0	115.135.13.45	\N
51f0a42e-d3f4-437b-8912-58626cbdf959	016ca48e-66c5-476c-9716-c6397ed60e69	2025-06-23 07:53:16.099138+00	2025-06-23 07:53:16.099138+00	\N	aal1	\N	\N	Mozilla/5.0 (Linux; Android 10; K) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/131.0.0.0 Mobile Safari/537.36	183.171.112.208	\N
b0983811-a44f-4de2-8897-92eb94b25a9b	a829ccb9-78d5-4940-82f6-934352e828cd	2025-06-23 07:53:22.947151+00	2025-06-23 07:53:22.947151+00	\N	aal1	\N	\N	Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/137.0.0.0 Safari/537.36	115.135.13.45	\N
9acca783-5aee-46cb-8b93-dad72f8ce960	6dc3e17b-1af0-4a4b-abaf-a9830465a207	2025-06-23 07:53:24.210697+00	2025-06-23 07:53:24.210697+00	\N	aal1	\N	\N	Mozilla/5.0 (Linux; Android 10; K) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/137.0.0.0 Safari/537.36	183.171.116.204	\N
d8894cde-66dc-404c-a8c3-fcb7e53db79b	fd238175-c03f-4b7a-a819-0837b802ae2c	2025-06-23 07:54:08.536161+00	2025-06-23 07:54:08.536161+00	\N	aal1	\N	\N	Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/136.0.0.0 Safari/537.36	115.135.13.45	\N
4062b000-51fe-4ddd-bba0-e7f13308f797	59874f8b-4fdf-41ce-947b-da9240a861ca	2025-06-23 07:55:24.747323+00	2025-06-23 07:55:24.747323+00	\N	aal1	\N	\N	Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/137.0.0.0 Safari/537.36 Edg/137.0.0.0	115.135.13.45	\N
17850380-73d4-47ce-8526-681f8e0f4424	7f05337a-1f10-411a-8c90-ab632faaf8c2	2025-06-23 07:55:28.576963+00	2025-06-23 07:55:28.576963+00	\N	aal1	\N	\N	Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/137.0.0.0 Safari/537.36	115.135.13.45	\N
0967906a-3d96-4158-a6c5-f6e1ed8a1930	fd238175-c03f-4b7a-a819-0837b802ae2c	2025-06-23 07:55:39.190643+00	2025-06-23 07:55:39.190643+00	\N	aal1	\N	\N	Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/136.0.0.0 Safari/537.36	115.135.13.45	\N
6e63b7dc-1583-4b05-812b-800255167285	0d12ddb0-122b-46a3-afba-c35c8640e887	2025-06-23 07:56:04.737796+00	2025-06-23 07:56:04.737796+00	\N	aal1	\N	\N	Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/137.0.0.0 Safari/537.36	115.135.13.45	\N
95280d85-278d-4051-b0e3-e71deafb998f	2186e85a-0204-40d2-ac5a-1ae7600edfa3	2025-06-23 07:56:17.967652+00	2025-06-23 07:56:17.967652+00	\N	aal1	\N	\N	Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/137.0.0.0 Safari/537.36	115.135.13.45	\N
4b1eb4cb-350e-4d7e-89a4-d96c442b4879	6c383e4a-a52d-4661-8a6c-4be47b0ed340	2025-06-23 07:56:55.011127+00	2025-06-23 07:56:55.011127+00	\N	aal1	\N	\N	Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/137.0.0.0 Safari/537.36	115.135.13.45	\N
f17ff1b3-96ba-413c-ab2f-c90695e8acbc	a4051467-1969-4a0f-8657-d8f3f0ba6359	2025-06-23 07:57:16.065096+00	2025-06-23 07:57:16.065096+00	\N	aal1	\N	\N	Mozilla/5.0 (X11; CrOS x86_64 14816.131.0) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/103.0.0.0 Safari/537.36	115.135.13.45	\N
faaa7831-168e-4a70-85f2-32159a10a646	60dea06c-f874-48fb-80ce-b71d2e65ba95	2025-06-23 07:57:58.740657+00	2025-06-23 07:57:58.740657+00	\N	aal1	\N	\N	Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/135.0.0.0 Safari/537.36	115.135.13.45	\N
25080e68-9d78-4c9a-9839-fae09373ad2d	ee74b89d-137d-470c-8a00-90fb5a372727	2025-06-23 07:58:31.486074+00	2025-06-23 07:58:31.486074+00	\N	aal1	\N	\N	Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/137.0.0.0 Safari/537.36	115.135.13.45	\N
c026b23f-c0bd-4892-9378-05789447cb03	47676bae-55c6-48f5-8b6a-dc0a3af02ec4	2025-06-23 08:00:50.526248+00	2025-06-23 08:00:50.526248+00	\N	aal1	\N	\N	Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/137.0.0.0 Safari/537.36 Edg/137.0.0.0	115.135.13.45	\N
037105e9-7093-4c7d-8b96-115dd98bee91	7d693d50-00d4-4a9b-9bc0-35afebbb30d9	2025-06-23 08:04:20.273694+00	2025-06-23 08:04:20.273694+00	\N	aal1	\N	\N	Mozilla/5.0 (Windows NT 10.0; Win64; x64; rv:139.0) Gecko/20100101 Firefox/139.0	115.135.13.45	\N
2cf3d60f-23b1-4297-8711-4a95a4e2c1a5	60dea06c-f874-48fb-80ce-b71d2e65ba95	2025-06-23 07:56:12.664794+00	2025-06-23 08:54:33.203687+00	\N	aal1	\N	2025-06-23 08:54:33.203632	node	185.93.166.49	\N
778482ed-f101-471f-977f-b58f904746e4	7df7ea94-16ba-4fd6-85bc-4fd0155fe284	2025-06-23 07:52:06.715905+00	2025-06-24 02:31:07.917712+00	\N	aal1	\N	2025-06-24 02:31:07.917657	Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/137.0.0.0 Safari/537.36	175.142.51.129	\N
f2188aff-bf53-4f90-a44a-9ed70faf9a6b	4e579a51-bb42-45f1-9b79-b84928a98421	2025-06-23 07:53:12.365833+00	2025-06-25 12:56:43.791386+00	\N	aal1	\N	2025-06-25 12:56:43.79133	Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/137.0.0.0 Safari/537.36	65.181.16.88	\N
3c9bdd62-beb8-47d7-aac0-4460fa17c767	f1b6d4f2-174f-4b2a-8c6c-d4531b128bfc	2025-06-27 08:18:52.561432+00	2025-06-27 08:18:52.561432+00	\N	aal1	\N	\N	node	161.142.154.225	\N
581f049b-5104-45aa-a670-243866b5b1e9	73bc6611-cc9d-451f-94f4-855016beb48e	2025-06-27 10:54:00.413765+00	2025-06-27 10:54:00.413765+00	\N	aal1	\N	\N	node	185.93.166.49	\N
4794b543-ec8e-4ca7-bb06-316c1fe77f43	73bc6611-cc9d-451f-94f4-855016beb48e	2025-06-27 10:54:18.486194+00	2025-06-27 10:54:18.486194+00	\N	aal1	\N	\N	Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/137.0.0.0 Safari/537.36	113.211.143.27	\N
9d384b5f-80c2-4bf8-b3b1-07b753249a73	73bc6611-cc9d-451f-94f4-855016beb48e	2025-06-27 10:59:44.305826+00	2025-06-27 10:59:44.305826+00	\N	aal1	\N	\N	Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/137.0.0.0 Safari/537.36	113.211.143.27	\N
af9c3956-3930-4d7a-b8cb-176b16e11c49	73bc6611-cc9d-451f-94f4-855016beb48e	2025-06-27 11:26:45.673116+00	2025-06-27 11:26:45.673116+00	\N	aal1	\N	\N	Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/137.0.0.0 Safari/537.36	113.211.143.27	\N
b4253a4e-0af0-4d12-8a35-af0bddfd46c9	73bc6611-cc9d-451f-94f4-855016beb48e	2025-06-27 13:54:21.149287+00	2025-06-27 13:54:21.149287+00	\N	aal1	\N	\N	Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/137.0.0.0 Safari/537.36	113.211.143.27	\N
1cd8aacd-f1b6-4703-912b-a19bcd8a697d	73bc6611-cc9d-451f-94f4-855016beb48e	2025-06-27 13:56:27.466428+00	2025-06-27 13:56:27.466428+00	\N	aal1	\N	\N	Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/137.0.0.0 Safari/537.36	113.211.143.27	\N
923cbae7-a9c3-4f99-be45-4d00ed3532f7	0955eea6-fdc3-48b6-beca-f30e05cfe912	2025-06-27 14:20:23.544133+00	2025-06-27 14:20:23.544133+00	\N	aal1	\N	\N	Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/137.0.0.0 Safari/537.36	161.142.154.225	\N
52aa85e0-4c4d-46b6-aaed-6c5dc94f334a	0955eea6-fdc3-48b6-beca-f30e05cfe912	2025-06-27 14:37:01.412793+00	2025-06-27 14:37:01.412793+00	\N	aal1	\N	\N	Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/137.0.0.0 Safari/537.36	161.142.154.225	\N
c4ef89cc-67ff-46f8-b046-ca0a8d9010ef	73bc6611-cc9d-451f-94f4-855016beb48e	2025-06-27 14:49:16.143179+00	2025-06-27 14:49:16.143179+00	\N	aal1	\N	\N	Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/137.0.0.0 Safari/537.36	113.211.143.27	\N
81767909-8727-49b2-840f-f1384043b150	fcc7d82b-864c-43db-9975-ff689875c391	2025-06-29 06:57:20.604636+00	2025-06-29 11:01:05.776022+00	\N	aal1	\N	2025-06-29 11:01:05.775964	Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/138.0.0.0 Safari/537.36	180.75.245.244	\N
34d3d3d1-900f-4c0d-9966-589784e0135a	fcc7d82b-864c-43db-9975-ff689875c391	2025-06-29 06:57:01.867814+00	2025-06-29 12:45:27.850586+00	\N	aal1	\N	2025-06-29 12:45:27.850523	node	185.93.166.49	\N
\.


--
-- Data for Name: sso_domains; Type: TABLE DATA; Schema: auth; Owner: -
--

COPY auth.sso_domains (id, sso_provider_id, domain, created_at, updated_at) FROM stdin;
\.


--
-- Data for Name: sso_providers; Type: TABLE DATA; Schema: auth; Owner: -
--

COPY auth.sso_providers (id, resource_id, created_at, updated_at) FROM stdin;
\.


--
-- Data for Name: users; Type: TABLE DATA; Schema: auth; Owner: -
--

COPY auth.users (instance_id, id, aud, role, email, encrypted_password, email_confirmed_at, invited_at, confirmation_token, confirmation_sent_at, recovery_token, recovery_sent_at, email_change_token_new, email_change, email_change_sent_at, last_sign_in_at, raw_app_meta_data, raw_user_meta_data, is_super_admin, created_at, updated_at, phone, phone_confirmed_at, phone_change, phone_change_token, phone_change_sent_at, email_change_token_current, email_change_confirm_status, banned_until, reauthentication_token, reauthentication_sent_at, is_sso_user, deleted_at, is_anonymous) FROM stdin;
00000000-0000-0000-0000-000000000000	f17d8111-cccf-4b85-afa7-ed9ad199e0ea	authenticated	authenticated	test@marzex.tech	$2a$10$e0f85tX1rDi2ItrNVzzug.CPEeE1YFgPY4eXrlLwJEk0V76RHvjBa	2025-01-23 05:32:06.52122+00	\N		\N		\N			\N	2025-01-23 07:16:40.906458+00	{"provider": "email", "providers": ["email"]}	{"sub": "f17d8111-cccf-4b85-afa7-ed9ad199e0ea", "email": "test@marzex.tech", "email_verified": true, "phone_verified": false}	\N	2025-01-23 05:32:06.518086+00	2025-01-23 07:16:40.907308+00	\N	\N			\N		0	\N		\N	f	\N	f
00000000-0000-0000-0000-000000000000	3aa665b7-a4dd-40d8-b647-82e6ce3b3e16	authenticated	authenticated	marzouq@marzex.tech	$2a$10$D/qv1uXSVxq/Bp.xv5YLY.QlUnZjFsRI07Q9Zwphaeb69/FrVncle	2025-01-19 06:50:37.25535+00	\N		\N		\N			\N	2025-02-18 08:01:42.270244+00	{"provider": "email", "providers": ["email"]}	{"sub": "3aa665b7-a4dd-40d8-b647-82e6ce3b3e16", "email": "marzouq@marzex.tech", "email_verified": true, "phone_verified": false}	\N	2025-01-19 06:50:37.253574+00	2025-02-18 08:01:42.273146+00	\N	\N			\N		0	\N		\N	f	\N	f
00000000-0000-0000-0000-000000000000	0a293fdd-d64a-4a9e-b46c-fad7f2175e01	authenticated	authenticated	marz@marzex.tech	$2a$10$5vdg/OJm.K7IJNichjPG8u//JYA/RUUevl.ILdeA6gpfHdBglT5Ny	2025-02-18 18:24:13.496471+00	\N		\N		\N			\N	2025-02-18 18:32:50.986356+00	{"provider": "email", "providers": ["email"]}	{"sub": "0a293fdd-d64a-4a9e-b46c-fad7f2175e01", "email": "marz@marzex.tech", "email_verified": true, "phone_verified": false}	\N	2025-02-18 18:24:13.475274+00	2025-02-18 18:32:50.988249+00	\N	\N			\N		0	\N		\N	f	\N	f
00000000-0000-0000-0000-000000000000	46f9cd41-b08e-4e32-81eb-bb1d3323b3b2	authenticated	authenticated	nasiha@mpocc.org.my	$2a$10$zqkdUyQk4hwyoh6Glseh.uUVWyDj8RX9uYTDl/FP0lRL8STa8A.ry	2025-06-15 14:38:33.534906+00	\N		\N		\N			\N	2025-06-15 14:38:33.536824+00	{"provider": "email", "providers": ["email"]}	{"sub": "46f9cd41-b08e-4e32-81eb-bb1d3323b3b2", "email": "nasiha@mpocc.org.my", "email_verified": true, "phone_verified": false}	\N	2025-06-15 14:38:33.531191+00	2025-06-15 14:38:33.538104+00	\N	\N			\N		0	\N		\N	f	\N	f
00000000-0000-0000-0000-000000000000	5de03212-53a6-465c-857b-34e113374e81	authenticated	authenticated	kamarul.sipi@airei.com.my	$2a$10$BY994anQnbpT1hz4g0XZiuQ3AhmcZG2a407vomeZ3XlazIIInUOte	2025-06-15 14:38:33.132797+00	\N		\N		\N			\N	2025-06-15 14:38:33.134755+00	{"provider": "email", "providers": ["email"]}	{"sub": "5de03212-53a6-465c-857b-34e113374e81", "email": "kamarul.sipi@airei.com.my", "email_verified": true, "phone_verified": false}	\N	2025-06-15 14:38:33.129272+00	2025-06-15 14:38:33.135768+00	\N	\N			\N		0	\N		\N	f	\N	f
00000000-0000-0000-0000-000000000000	b7592049-9546-4bd4-9bc7-33d77d747af0	authenticated	authenticated	hemanathan@airei.com.my	$2a$10$mldkKzv1SPp9ZGN7mIq2.O/Z5fQu68zjNinuibrT0jMMXdAwuuH1u	2025-06-15 14:38:32.836422+00	\N		\N		\N			\N	2025-06-15 14:38:32.838557+00	{"provider": "email", "providers": ["email"]}	{"sub": "b7592049-9546-4bd4-9bc7-33d77d747af0", "email": "hemanathan@airei.com.my", "email_verified": true, "phone_verified": false}	\N	2025-06-15 14:38:32.83323+00	2025-06-15 14:38:32.839779+00	\N	\N			\N		0	\N		\N	f	\N	f
00000000-0000-0000-0000-000000000000	4d6dc0fa-8a2f-4073-9bbd-85425124beb0	authenticated	authenticated	leo_gee87@yahoo.com	$2a$10$b63rTM63UwsJaf4CEOHnpu3hyovCvDr6Ssy7zKy9SKsJHdLzgkp72	2025-06-15 14:38:33.645697+00	\N		\N		\N			\N	2025-06-15 14:38:33.647365+00	{"provider": "email", "providers": ["email"]}	{"sub": "4d6dc0fa-8a2f-4073-9bbd-85425124beb0", "email": "leo_gee87@yahoo.com", "email_verified": true, "phone_verified": false}	\N	2025-06-15 14:38:33.642598+00	2025-06-15 14:38:33.648339+00	\N	\N			\N		0	\N		\N	f	\N	f
00000000-0000-0000-0000-000000000000	081efe3b-09b5-4e34-9194-cbcb30cc77d9	authenticated	authenticated	kamarulsipi.mohd@gmail.com	$2a$10$9x8N6tNpElPHrnZiYnixge1V9cc5CcAjETHW47KAKw31.ehSZ1xKi	2025-06-15 14:38:33.037846+00	\N		\N		\N			\N	2025-06-15 14:38:33.039587+00	{"provider": "email", "providers": ["email"]}	{"sub": "081efe3b-09b5-4e34-9194-cbcb30cc77d9", "email": "kamarulsipi.mohd@gmail.com", "email_verified": true, "phone_verified": false}	\N	2025-06-15 14:38:33.034642+00	2025-06-15 14:38:33.041273+00	\N	\N			\N		0	\N		\N	f	\N	f
00000000-0000-0000-0000-000000000000	884b5358-cd7d-4b03-84af-fde5a996ac76	authenticated	authenticated	s@gmail.com	$2a$10$rF75yEDOo2bnwIqOT39h.e0i8BzH2ea0NOzUxVrg7OHObfgGgeqI6	2025-06-15 14:38:33.333644+00	\N		\N		\N			\N	2025-06-15 14:38:33.335314+00	{"provider": "email", "providers": ["email"]}	{"sub": "884b5358-cd7d-4b03-84af-fde5a996ac76", "email": "s@gmail.com", "email_verified": true, "phone_verified": false}	\N	2025-06-15 14:38:33.33065+00	2025-06-15 14:38:33.336284+00	\N	\N			\N		0	\N		\N	f	\N	f
00000000-0000-0000-0000-000000000000	a007885a-80b3-4486-b31c-6652abca3e12	authenticated	authenticated	firdaus@mspo.org.my	$2a$10$q0WOJftshcZ7z12y3Hr7I.eSFzi/wUok8W1KRottAjPIY9x2FUxa6	2025-06-15 09:36:05.773477+00	\N		\N		\N			\N	2025-06-23 05:49:16.723564+00	{"provider": "email", "providers": ["email"]}	{"sub": "a007885a-80b3-4486-b31c-6652abca3e12", "email": "firdaus@mspo.org.my", "email_verified": true, "phone_verified": false}	\N	2025-06-15 09:36:05.769352+00	2025-06-23 07:41:38.93929+00	\N	\N			\N		0	\N		\N	f	\N	f
00000000-0000-0000-0000-000000000000	1207343f-7e2b-4f82-88ed-7b559f837c08	authenticated	authenticated	hemanarhan@airei.com.my	$2a$10$EifTR/CP88vaVoob3YWVIO/0DQ6EiSS/ht71Ky2wvpCagKa7NbVmS	2025-06-15 14:38:33.237594+00	\N		\N		\N			\N	2025-06-15 14:38:33.239151+00	{"provider": "email", "providers": ["email"]}	{"sub": "1207343f-7e2b-4f82-88ed-7b559f837c08", "email": "hemanarhan@airei.com.my", "email_verified": true, "phone_verified": false}	\N	2025-06-15 14:38:33.234721+00	2025-06-15 14:38:33.240086+00	\N	\N			\N		0	\N		\N	f	\N	f
00000000-0000-0000-0000-000000000000	663cd7e5-73f0-4c16-b7a8-a579107fda69	authenticated	authenticated	k@gmail.com	$2a$10$6OQG7bgjvz3OvGU.ozsASeC.H1SkILM4ovmTXXuf2gNkNSGYEl5mG	2025-06-15 14:38:32.940459+00	\N		\N		\N			\N	2025-06-15 14:38:32.942288+00	{"provider": "email", "providers": ["email"]}	{"sub": "663cd7e5-73f0-4c16-b7a8-a579107fda69", "email": "k@gmail.com", "email_verified": true, "phone_verified": false}	\N	2025-06-15 14:38:32.936763+00	2025-06-15 14:38:32.943523+00	\N	\N			\N		0	\N		\N	f	\N	f
00000000-0000-0000-0000-000000000000	9c533f9b-0de2-4184-8679-ac4124139717	authenticated	authenticated	kamaroyamatha@gmail.com	$2a$10$nxSBoZo.NI9jyPUOIlXSmOUc0zI2wacJmBchRcT2sz23hq6XCLhtG	2025-06-15 14:38:33.430164+00	\N		\N		\N			\N	2025-06-15 14:38:33.431977+00	{"provider": "email", "providers": ["email"]}	{"sub": "9c533f9b-0de2-4184-8679-ac4124139717", "email": "kamaroyamatha@gmail.com", "email_verified": true, "phone_verified": false}	\N	2025-06-15 14:38:33.426857+00	2025-06-15 14:38:33.432905+00	\N	\N			\N		0	\N		\N	f	\N	f
00000000-0000-0000-0000-000000000000	0955eea6-fdc3-48b6-beca-f30e05cfe912	authenticated	authenticated	hazwan@mspo.org.my	$2a$10$8YE/NS/abC.BAYx5Mq6WVuyMFZclmzzZ8qd1BF0358NU/mpxnmb6W	2025-06-14 18:41:49.752133+00	\N		\N		\N			\N	2025-06-27 14:37:01.412703+00	{"provider": "email", "providers": ["email"]}	{"sub": "0955eea6-fdc3-48b6-beca-f30e05cfe912", "email": "hazwan@mspo.org.my", "email_verified": true, "phone_verified": false}	\N	2025-06-14 18:41:49.601463+00	2025-06-27 14:37:01.414108+00	\N	\N			\N		0	\N		\N	f	\N	f
00000000-0000-0000-0000-000000000000	e81e22aa-0578-4fb2-8d0b-5665be08b8ee	authenticated	authenticated	janechinshuikwen@gmail.com	$2a$10$WokgCNSOvntvvi4WooUzyuyZ4KVB88WJTGTafuA7FMQauJnYrHF2W	2025-06-15 14:38:33.748236+00	\N		\N		\N			\N	2025-06-15 14:38:33.750127+00	{"provider": "email", "providers": ["email"]}	{"sub": "e81e22aa-0578-4fb2-8d0b-5665be08b8ee", "email": "janechinshuikwen@gmail.com", "email_verified": true, "phone_verified": false}	\N	2025-06-15 14:38:33.744938+00	2025-06-15 14:38:33.751126+00	\N	\N			\N		0	\N		\N	f	\N	f
00000000-0000-0000-0000-000000000000	c0c0c1da-11f3-4065-aa98-82084870eea4	authenticated	authenticated	aldosualin@gmail.com	$2a$10$9QDZ7wW30ujFSpE7xXCj.e.2Zk.6te9Q2OmKo7Np0Gz.CgzSnVYYS	2025-06-15 14:38:34.932492+00	\N		\N		\N			\N	2025-06-15 14:38:34.933997+00	{"provider": "email", "providers": ["email"]}	{"sub": "c0c0c1da-11f3-4065-aa98-82084870eea4", "email": "aldosualin@gmail.com", "email_verified": true, "phone_verified": false}	\N	2025-06-15 14:38:34.9298+00	2025-06-15 14:38:34.934928+00	\N	\N			\N		0	\N		\N	f	\N	f
00000000-0000-0000-0000-000000000000	f36f7e40-f5fb-4c87-a096-a88c211d6bd2	authenticated	authenticated	n.hazirahismail@gmail.com	$2a$10$wQcgYtffjvZABx7qjmvicOBRhaEO/iqtS.mbZ47x1/ZIOkoFEdm5m	2025-06-15 14:38:34.523357+00	\N		\N		\N			\N	2025-06-15 14:38:34.524915+00	{"provider": "email", "providers": ["email"]}	{"sub": "f36f7e40-f5fb-4c87-a096-a88c211d6bd2", "email": "n.hazirahismail@gmail.com", "email_verified": true, "phone_verified": false}	\N	2025-06-15 14:38:34.520462+00	2025-06-15 14:38:34.525887+00	\N	\N			\N		0	\N		\N	f	\N	f
00000000-0000-0000-0000-000000000000	d0e4fb36-fb0a-4767-a333-531cbb37e035	authenticated	authenticated	sriganda2003@gmail.com	$2a$10$bdI5RV5Vgxv05ZZkSQmK4.GDOx1A4RfftVaV/CJNrHUz48nzGwiU.	2025-06-15 14:38:34.027786+00	\N		\N		\N			\N	2025-06-15 14:38:34.029368+00	{"provider": "email", "providers": ["email"]}	{"sub": "d0e4fb36-fb0a-4767-a333-531cbb37e035", "email": "sriganda2003@gmail.com", "email_verified": true, "phone_verified": false}	\N	2025-06-15 14:38:34.024937+00	2025-06-15 14:38:34.030387+00	\N	\N			\N		0	\N		\N	f	\N	f
00000000-0000-0000-0000-000000000000	bf3f6921-ab2d-4b8b-936f-38da5143c31d	authenticated	authenticated	rusnanit78@gmail.com	$2a$10$aabZt58QGACEJouguIa99.fnrBOrJi2IeUMDBRjZFb6wVw97VSGCa	2025-06-15 14:38:33.840026+00	\N		\N		\N			\N	2025-06-15 14:38:33.84159+00	{"provider": "email", "providers": ["email"]}	{"sub": "bf3f6921-ab2d-4b8b-936f-38da5143c31d", "email": "rusnanit78@gmail.com", "email_verified": true, "phone_verified": false}	\N	2025-06-15 14:38:33.836655+00	2025-06-15 14:38:33.842618+00	\N	\N			\N		0	\N		\N	f	\N	f
00000000-0000-0000-0000-000000000000	13b7d6b3-42a7-40ec-b227-f1b91f791dcc	authenticated	authenticated	amirul@kksl.com.my	$2a$10$ApRnyqsKCSM5yptupBwJlu4JjWEvC7tLlVsjhpVOvJiDGDSCk.PEi	2025-06-15 14:38:34.229011+00	\N		\N		\N			\N	2025-06-15 14:38:34.230661+00	{"provider": "email", "providers": ["email"]}	{"sub": "13b7d6b3-42a7-40ec-b227-f1b91f791dcc", "email": "amirul@kksl.com.my", "email_verified": true, "phone_verified": false}	\N	2025-06-15 14:38:34.225708+00	2025-06-15 14:38:34.231656+00	\N	\N			\N		0	\N		\N	f	\N	f
00000000-0000-0000-0000-000000000000	e0cf9d78-629a-4f0c-8c5e-d4eb659c758a	authenticated	authenticated	jamal@ggc.my	$2a$10$/2Ldt93.R.wa1jf.8WwWLexbeldr4DmtK0UhxX2N9lCnzy1N7BGeC	2025-06-15 14:38:35.020046+00	\N		\N		\N			\N	2025-06-15 14:38:35.021538+00	{"provider": "email", "providers": ["email"]}	{"sub": "e0cf9d78-629a-4f0c-8c5e-d4eb659c758a", "email": "jamal@ggc.my", "email_verified": true, "phone_verified": false}	\N	2025-06-15 14:38:35.017234+00	2025-06-15 14:38:35.022462+00	\N	\N			\N		0	\N		\N	f	\N	f
00000000-0000-0000-0000-000000000000	cedde969-4985-499b-a05c-5325099bf7aa	authenticated	authenticated	goldenelate.pom@gmail.com	$2a$10$eBb.HhOE4EP20Evsb56Ry.uSAkMy9FNcvKoI5ebORjQHcCmv5Q3ry	2025-06-15 14:38:34.121639+00	\N		\N		\N			\N	2025-06-15 14:38:34.123318+00	{"provider": "email", "providers": ["email"]}	{"sub": "cedde969-4985-499b-a05c-5325099bf7aa", "email": "goldenelate.pom@gmail.com", "email_verified": true, "phone_verified": false}	\N	2025-06-15 14:38:34.117761+00	2025-06-15 14:38:34.124449+00	\N	\N			\N		0	\N		\N	f	\N	f
00000000-0000-0000-0000-000000000000	3d06ba74-5af0-499d-81fa-6a61febaa57d	authenticated	authenticated	nuramsconsultant@gmail.com	$2a$10$YBhBP1hYJsALLYioMVZCH.vxCt6KdIv6gSgdCS8H4GnQ94uS.Qzli	2025-06-15 14:38:33.934142+00	\N		\N		\N			\N	2025-06-15 14:38:33.935597+00	{"provider": "email", "providers": ["email"]}	{"sub": "3d06ba74-5af0-499d-81fa-6a61febaa57d", "email": "nuramsconsultant@gmail.com", "email_verified": true, "phone_verified": false}	\N	2025-06-15 14:38:33.931363+00	2025-06-15 14:38:33.936551+00	\N	\N			\N		0	\N		\N	f	\N	f
00000000-0000-0000-0000-000000000000	12c58e57-7eb9-4e61-a298-52c44ab6e5e2	authenticated	authenticated	chongchungwai@icloud.com	$2a$10$gLbn71ZNlQTZPQFVBbdVxOHosi5y5Ht28PI8jFGf0nWAz8C8n5t.G	2025-06-15 14:38:34.421302+00	\N		\N		\N			\N	2025-06-15 14:38:34.422937+00	{"provider": "email", "providers": ["email"]}	{"sub": "12c58e57-7eb9-4e61-a298-52c44ab6e5e2", "email": "chongchungwai@icloud.com", "email_verified": true, "phone_verified": false}	\N	2025-06-15 14:38:34.41778+00	2025-06-15 14:38:34.423906+00	\N	\N			\N		0	\N		\N	f	\N	f
00000000-0000-0000-0000-000000000000	a54f43bc-3510-4267-9c02-de241f28979b	authenticated	authenticated	foemalaysia@gmail.com	$2a$10$KUzs1suZ6mGAQD2YwwwiYuhILYryM2XQdEj0SZoGt.t2axcue5jGm	2025-06-15 14:38:34.737703+00	\N		\N		\N			\N	2025-06-15 14:38:34.740014+00	{"provider": "email", "providers": ["email"]}	{"sub": "a54f43bc-3510-4267-9c02-de241f28979b", "email": "foemalaysia@gmail.com", "email_verified": true, "phone_verified": false}	\N	2025-06-15 14:38:34.734315+00	2025-06-15 14:38:34.741141+00	\N	\N			\N		0	\N		\N	f	\N	f
00000000-0000-0000-0000-000000000000	812c46f2-6962-4df8-90c0-f5dee109c540	authenticated	authenticated	varmavarma186@gmail.com	$2a$10$eijHb3aiN5hWPc/fKWZrheZjyy8Cq.R9I/zyIx3otX9PTnzds7XnW	2025-06-15 14:38:34.616955+00	\N		\N		\N			\N	2025-06-15 14:38:34.618565+00	{"provider": "email", "providers": ["email"]}	{"sub": "812c46f2-6962-4df8-90c0-f5dee109c540", "email": "varmavarma186@gmail.com", "email_verified": true, "phone_verified": false}	\N	2025-06-15 14:38:34.614157+00	2025-06-15 14:38:34.619632+00	\N	\N			\N		0	\N		\N	f	\N	f
00000000-0000-0000-0000-000000000000	4287988f-93ab-4a3c-9790-77473ef7f799	authenticated	authenticated	ephremryanalphonsus@gmail.com	$2a$10$wXsp2udDGWn8cL88.Iec/uJ1ptjX9E7/NOlvHwppomNYnC1cCjkdG	2025-06-15 14:38:34.329496+00	\N		\N		\N			\N	2025-06-15 14:38:34.331004+00	{"provider": "email", "providers": ["email"]}	{"sub": "4287988f-93ab-4a3c-9790-77473ef7f799", "email": "ephremryanalphonsus@gmail.com", "email_verified": true, "phone_verified": false}	\N	2025-06-15 14:38:34.326292+00	2025-06-15 14:38:34.332185+00	\N	\N			\N		0	\N		\N	f	\N	f
00000000-0000-0000-0000-000000000000	ded6488b-469e-484e-b815-a00534d3e10f	authenticated	authenticated	ameer.h@fgvholdings.com	$2a$10$D1sMZHI6PpcqC2g8taUKSeI6USEAFDkd4A0tugF.FQ5o.8EI09tu2	2025-06-15 14:38:34.839052+00	\N		\N		\N			\N	2025-06-15 14:38:34.840841+00	{"provider": "email", "providers": ["email"]}	{"sub": "ded6488b-469e-484e-b815-a00534d3e10f", "email": "ameer.h@fgvholdings.com", "email_verified": true, "phone_verified": false}	\N	2025-06-15 14:38:34.836279+00	2025-06-15 14:38:34.841837+00	\N	\N			\N		0	\N		\N	f	\N	f
00000000-0000-0000-0000-000000000000	0f718b43-671c-4b6f-b906-34ee7b45b4b2	authenticated	authenticated	thilaganarthan@gmail.com	$2a$10$l62PpRu.vRS6TNSiLQxJdeeedW0CEiho4WSJgVdG3zOUk7ln982Ni	2025-06-15 14:38:35.111313+00	\N		\N		\N			\N	2025-06-15 14:38:35.112898+00	{"provider": "email", "providers": ["email"]}	{"sub": "0f718b43-671c-4b6f-b906-34ee7b45b4b2", "email": "thilaganarthan@gmail.com", "email_verified": true, "phone_verified": false}	\N	2025-06-15 14:38:35.107884+00	2025-06-15 14:38:35.113865+00	\N	\N			\N		0	\N		\N	f	\N	f
00000000-0000-0000-0000-000000000000	d8d76d24-14d4-4e46-92ad-5907d27fe2e0	authenticated	authenticated	hasronnorraimi@yahoo.com	$2a$10$PgE5FNV7oD/Ssq2KFOY0L.oU1qsQ0J0M8fHJrgx.wwLwUaha3Ps2S	2025-06-15 14:38:36.274797+00	\N		\N		\N			\N	2025-06-15 14:38:36.276537+00	{"provider": "email", "providers": ["email"]}	{"sub": "d8d76d24-14d4-4e46-92ad-5907d27fe2e0", "email": "hasronnorraimi@yahoo.com", "email_verified": true, "phone_verified": false}	\N	2025-06-15 14:38:36.271855+00	2025-06-15 14:38:36.277543+00	\N	\N			\N		0	\N		\N	f	\N	f
00000000-0000-0000-0000-000000000000	80708127-7fdf-4c9d-8b6f-315c374c0cf4	authenticated	authenticated	kyting@jayatiasa.net	$2a$10$MQdoaRo.P4cGwnCUxQJ0RObcy6zP8M99Y6b7dtIf1l1rvoDlB6Qyy	2025-06-15 14:38:35.885512+00	\N		\N		\N			\N	2025-06-15 14:38:35.887163+00	{"provider": "email", "providers": ["email"]}	{"sub": "80708127-7fdf-4c9d-8b6f-315c374c0cf4", "email": "kyting@jayatiasa.net", "email_verified": true, "phone_verified": false}	\N	2025-06-15 14:38:35.882486+00	2025-06-15 14:38:35.8883+00	\N	\N			\N		0	\N		\N	f	\N	f
00000000-0000-0000-0000-000000000000	b0b2df8d-3835-4d06-a95d-d6a376b95ea1	authenticated	authenticated	adeline.stefanie.ta@gmail.com	$2a$10$z/fSRotM1SxzfdGdL6F79OXAvuK1TgBh1st6djF0mWrm8l4czmcqa	2025-06-15 14:38:35.402453+00	\N		\N		\N			\N	2025-06-15 14:38:35.404773+00	{"provider": "email", "providers": ["email"]}	{"sub": "b0b2df8d-3835-4d06-a95d-d6a376b95ea1", "email": "adeline.stefanie.ta@gmail.com", "email_verified": true, "phone_verified": false}	\N	2025-06-15 14:38:35.399422+00	2025-06-15 14:38:35.405758+00	\N	\N			\N		0	\N		\N	f	\N	f
00000000-0000-0000-0000-000000000000	c3430ef8-bea7-4d77-840d-7e1847682f45	authenticated	authenticated	gmm@ioigroup.com	$2a$10$h/Bv4PsgKgSQcEY9WQKUE.Ax.VikbU7Sg9iRLWaRvtRvHBzrhsOUa	2025-06-15 14:38:35.206182+00	\N		\N		\N			\N	2025-06-15 14:38:35.207963+00	{"provider": "email", "providers": ["email"]}	{"sub": "c3430ef8-bea7-4d77-840d-7e1847682f45", "email": "gmm@ioigroup.com", "email_verified": true, "phone_verified": false}	\N	2025-06-15 14:38:35.203235+00	2025-06-15 14:38:35.208987+00	\N	\N			\N		0	\N		\N	f	\N	f
00000000-0000-0000-0000-000000000000	1b9260e9-b2bc-4ac3-86ed-cd13d669bd46	authenticated	authenticated	suryantiselalukecewa@gmail.com	$2a$10$/AhtTDxxxPw4A4m5jZrKYe2ecmovYhRMUp3MqFiSyf7m/K9txLlrG	2025-06-15 14:38:35.600681+00	\N		\N		\N			\N	2025-06-15 14:38:35.60246+00	{"provider": "email", "providers": ["email"]}	{"sub": "1b9260e9-b2bc-4ac3-86ed-cd13d669bd46", "email": "suryantiselalukecewa@gmail.com", "email_verified": true, "phone_verified": false}	\N	2025-06-15 14:38:35.597287+00	2025-06-15 14:38:35.603573+00	\N	\N			\N		0	\N		\N	f	\N	f
00000000-0000-0000-0000-000000000000	e80a6ccf-333b-407f-ae20-ae04ee67f667	authenticated	authenticated	josephjanting@gmail.com	$2a$10$ZF3ApMFxz9DxOXyy4xljFeEfadiqIR99tEEnj2pDdKs5mUVxWxmJC	2025-06-15 14:38:36.371517+00	\N		\N		\N			\N	2025-06-15 14:38:36.373087+00	{"provider": "email", "providers": ["email"]}	{"sub": "e80a6ccf-333b-407f-ae20-ae04ee67f667", "email": "josephjanting@gmail.com", "email_verified": true, "phone_verified": false}	\N	2025-06-15 14:38:36.368585+00	2025-06-15 14:38:36.374047+00	\N	\N			\N		0	\N		\N	f	\N	f
00000000-0000-0000-0000-000000000000	1f99b32d-2a96-4760-b450-ed45b0abe4d1	authenticated	authenticated	monalizalidom81@gmail.com	$2a$10$R2kFKe7GuKAVPMiGKltIW.lfwAiVO4n3LHwa9o1Sor8K871fYNFo6	2025-06-15 14:38:35.501595+00	\N		\N		\N			\N	2025-06-15 14:38:35.503153+00	{"provider": "email", "providers": ["email"]}	{"sub": "1f99b32d-2a96-4760-b450-ed45b0abe4d1", "email": "monalizalidom81@gmail.com", "email_verified": true, "phone_verified": false}	\N	2025-06-15 14:38:35.498868+00	2025-06-15 14:38:35.504065+00	\N	\N			\N		0	\N		\N	f	\N	f
00000000-0000-0000-0000-000000000000	0dfa2c7d-310b-4a83-98f5-197421843955	authenticated	authenticated	wzynole@gmail.com	$2a$10$MufGtnOVJR2P415TioRADuoHEY2aZezqWT/4ZdkG7zOWoTvYeBi0a	2025-06-15 14:38:35.307523+00	\N		\N		\N			\N	2025-06-15 14:38:35.309181+00	{"provider": "email", "providers": ["email"]}	{"sub": "0dfa2c7d-310b-4a83-98f5-197421843955", "email": "wzynole@gmail.com", "email_verified": true, "phone_verified": false}	\N	2025-06-15 14:38:35.304349+00	2025-06-15 14:38:35.310264+00	\N	\N			\N		0	\N		\N	f	\N	f
00000000-0000-0000-0000-000000000000	f22bd07e-28a0-4135-b73e-fb6629087485	authenticated	authenticated	suburbanpom@gmail.com	$2a$10$VsqrHm21gKMRFujPbEVU0unRCnCZQDPaEbIqcjuM7KPD00abuB4h2	2025-06-15 14:38:35.791735+00	\N		\N		\N			\N	2025-06-15 14:38:35.793297+00	{"provider": "email", "providers": ["email"]}	{"sub": "f22bd07e-28a0-4135-b73e-fb6629087485", "email": "suburbanpom@gmail.com", "email_verified": true, "phone_verified": false}	\N	2025-06-15 14:38:35.788177+00	2025-06-15 14:38:35.794396+00	\N	\N			\N		0	\N		\N	f	\N	f
00000000-0000-0000-0000-000000000000	4da24124-a1ef-4efe-832d-a89ddfd8945a	authenticated	authenticated	mutuagungmalaysia@gmail.com	$2a$10$6ijsTuFTIbH58Eh7M3/ZXO/0RzGwVfjw3tXtr90w.gJOGN4m9oLNe	2025-06-15 14:38:36.085483+00	\N		\N		\N			\N	2025-06-15 14:38:36.086983+00	{"provider": "email", "providers": ["email"]}	{"sub": "4da24124-a1ef-4efe-832d-a89ddfd8945a", "email": "mutuagungmalaysia@gmail.com", "email_verified": true, "phone_verified": false}	\N	2025-06-15 14:38:36.08252+00	2025-06-15 14:38:36.088087+00	\N	\N			\N		0	\N		\N	f	\N	f
00000000-0000-0000-0000-000000000000	536203a3-6335-4c60-ae6f-f852135c5419	authenticated	authenticated	amiratul.aniqah@mpob.gov.my	$2a$10$DXbj2JOz7ZiqH1/NvWZUwewV8AJHk1QDF3ztA1kHDAdQI1UMO4gsi	2025-06-15 14:38:35.989086+00	\N		\N		\N			\N	2025-06-15 14:38:35.990698+00	{"provider": "email", "providers": ["email"]}	{"sub": "536203a3-6335-4c60-ae6f-f852135c5419", "email": "amiratul.aniqah@mpob.gov.my", "email_verified": true, "phone_verified": false}	\N	2025-06-15 14:38:35.986081+00	2025-06-15 14:38:35.991644+00	\N	\N			\N		0	\N		\N	f	\N	f
00000000-0000-0000-0000-000000000000	457acf64-4b5a-49a5-8f67-2aa577cec7ec	authenticated	authenticated	hazirah@airei.com.my	$2a$10$IlE3Kgp6BSo/p7XQiMVD0OoagYI6ZWS0UjOGoGKFSL4hoL.GPlZo6	2025-06-15 14:38:35.696158+00	\N		\N		\N			\N	2025-06-15 14:38:35.697683+00	{"provider": "email", "providers": ["email"]}	{"sub": "457acf64-4b5a-49a5-8f67-2aa577cec7ec", "email": "hazirah@airei.com.my", "email_verified": true, "phone_verified": false}	\N	2025-06-15 14:38:35.693257+00	2025-06-15 14:38:35.698671+00	\N	\N			\N		0	\N		\N	f	\N	f
00000000-0000-0000-0000-000000000000	3ce70501-e74f-4420-bc0a-3eac51f2dbe4	authenticated	authenticated	sadiahq@gmail.com	$2a$10$2NQ9XWs/cW1oGJmvCZzj3OOUuhpBFQcRgvFmlQb2JfBuYBKNNEO2O	2025-06-15 14:38:36.178799+00	\N		\N		\N			\N	2025-06-15 14:38:36.180307+00	{"provider": "email", "providers": ["email"]}	{"sub": "3ce70501-e74f-4420-bc0a-3eac51f2dbe4", "email": "sadiahq@gmail.com", "email_verified": true, "phone_verified": false}	\N	2025-06-15 14:38:36.176128+00	2025-06-15 14:38:36.181336+00	\N	\N			\N		0	\N		\N	f	\N	f
00000000-0000-0000-0000-000000000000	7c42038f-aa20-4f20-ba43-839d3474a560	authenticated	authenticated	rusdi@primulagemilang.com	$2a$10$8fURfiWHNAk.0jobmCb1Sem4d.VRI4P6/CPAAP53eZXocWuZ6F4aq	2025-06-15 14:38:36.471006+00	\N		\N		\N			\N	2025-06-15 14:38:36.472844+00	{"provider": "email", "providers": ["email"]}	{"sub": "7c42038f-aa20-4f20-ba43-839d3474a560", "email": "rusdi@primulagemilang.com", "email_verified": true, "phone_verified": false}	\N	2025-06-15 14:38:36.467224+00	2025-06-15 14:38:36.473917+00	\N	\N			\N		0	\N		\N	f	\N	f
00000000-0000-0000-0000-000000000000	2abe0ef5-50a6-4f32-bcd0-ccbb192771c5	authenticated	authenticated	chitra.loganathan@agrobank.com.my	$2a$10$qYrjcxqrZfTHr6F3Pb/fCO4wNfW1YhlCvfLq5WTebPjTeX.tZKdse	2025-06-15 14:38:37.620873+00	\N		\N		\N			\N	2025-06-15 14:38:37.622346+00	{"provider": "email", "providers": ["email"]}	{"sub": "2abe0ef5-50a6-4f32-bcd0-ccbb192771c5", "email": "chitra.loganathan@agrobank.com.my", "email_verified": true, "phone_verified": false}	\N	2025-06-15 14:38:37.617988+00	2025-06-15 14:38:37.623343+00	\N	\N			\N		0	\N		\N	f	\N	f
00000000-0000-0000-0000-000000000000	8d6c1385-fa01-48c7-b761-4e0ebdcab162	authenticated	authenticated	hello@bliss.com	$2a$10$jWY8/0mbgjJW7uKqoPH/4eAsFCdKmcAvgYb2qCQr3imPYfmDw8hYu	2025-06-15 14:38:37.242471+00	\N		\N		\N			\N	2025-06-15 14:38:37.243943+00	{"provider": "email", "providers": ["email"]}	{"sub": "8d6c1385-fa01-48c7-b761-4e0ebdcab162", "email": "hello@bliss.com", "email_verified": true, "phone_verified": false}	\N	2025-06-15 14:38:37.239317+00	2025-06-15 14:38:37.244996+00	\N	\N			\N		0	\N		\N	f	\N	f
00000000-0000-0000-0000-000000000000	582f5571-b638-444b-9527-12503ce384a3	authenticated	authenticated	adninaminurrashid@gmail.com	$2a$10$Tar8q6HEeotLYNMs5SLLRujg/HFsahAvLk0XKkLet/DsK5Gjf7/xK	2025-06-15 14:38:36.762597+00	\N		\N		\N			\N	2025-06-15 14:38:36.764104+00	{"provider": "email", "providers": ["email"]}	{"sub": "582f5571-b638-444b-9527-12503ce384a3", "email": "adninaminurrashid@gmail.com", "email_verified": true, "phone_verified": false}	\N	2025-06-15 14:38:36.760017+00	2025-06-15 14:38:36.765018+00	\N	\N			\N		0	\N		\N	f	\N	f
00000000-0000-0000-0000-000000000000	a0b845cc-2c32-421e-9f3e-ebfe8e22cd15	authenticated	authenticated	spadmukahmill@gmail.com	$2a$10$PLwCqofYcRt02aB/IqlcF.9BHHOA42UnNl/M/aNYExYKyQwXLr/tO	2025-06-15 14:38:36.566171+00	\N		\N		\N			\N	2025-06-15 14:38:36.567693+00	{"provider": "email", "providers": ["email"]}	{"sub": "a0b845cc-2c32-421e-9f3e-ebfe8e22cd15", "email": "spadmukahmill@gmail.com", "email_verified": true, "phone_verified": false}	\N	2025-06-15 14:38:36.563066+00	2025-06-15 14:38:36.568648+00	\N	\N			\N		0	\N		\N	f	\N	f
00000000-0000-0000-0000-000000000000	14e4c67b-bcde-4704-a97f-0dcbe1717dc5	authenticated	authenticated	whistlecert@gmail.com	$2a$10$D9K/YbYe1jdX9snlipYpw.7YgU4qPdd2t7eJutt5JIo.aK28yA54u	2025-06-15 14:38:36.954255+00	\N		\N		\N			\N	2025-06-15 14:38:36.955933+00	{"provider": "email", "providers": ["email"]}	{"sub": "14e4c67b-bcde-4704-a97f-0dcbe1717dc5", "email": "whistlecert@gmail.com", "email_verified": true, "phone_verified": false}	\N	2025-06-15 14:38:36.951241+00	2025-06-15 14:38:36.956936+00	\N	\N			\N		0	\N		\N	f	\N	f
00000000-0000-0000-0000-000000000000	0919a2be-3b19-418f-91e8-ae8a8ffd3e48	authenticated	authenticated	baxteraymond@gmail.com	$2a$10$AaRwGXKz5NQ8ogHbuSmf4.iMOZfCdfHv17faNRkcSrwC5oJQkd4Eu	2025-06-15 14:38:37.729136+00	\N		\N		\N			\N	2025-06-15 14:38:37.731126+00	{"provider": "email", "providers": ["email"]}	{"sub": "0919a2be-3b19-418f-91e8-ae8a8ffd3e48", "email": "baxteraymond@gmail.com", "email_verified": true, "phone_verified": false}	\N	2025-06-15 14:38:37.725978+00	2025-06-15 14:38:37.73208+00	\N	\N			\N		0	\N		\N	f	\N	f
00000000-0000-0000-0000-000000000000	05039a36-049a-47b0-9e99-6de64a44acbd	authenticated	authenticated	mspo2019@yahoo.com	$2a$10$gvfWAPV0egt7HXWIncNFHOirE7C2PH8jGjEe8tVtmabjry4BAyAUS	2025-06-15 14:38:36.860739+00	\N		\N		\N			\N	2025-06-15 14:38:36.862415+00	{"provider": "email", "providers": ["email"]}	{"sub": "05039a36-049a-47b0-9e99-6de64a44acbd", "email": "mspo2019@yahoo.com", "email_verified": true, "phone_verified": false}	\N	2025-06-15 14:38:36.857617+00	2025-06-15 14:38:36.863435+00	\N	\N			\N		0	\N		\N	f	\N	f
00000000-0000-0000-0000-000000000000	e5871981-e66c-4c44-9183-0e8084e874c9	authenticated	authenticated	luangbadol@gmail.com	$2a$10$lY2yKofkGy8SNe8Q2svbduTZTWgnPtXdhohtX7k.O5CTDGjS.zZV6	2025-06-15 14:38:36.669078+00	\N		\N		\N			\N	2025-06-15 14:38:36.670532+00	{"provider": "email", "providers": ["email"]}	{"sub": "e5871981-e66c-4c44-9183-0e8084e874c9", "email": "luangbadol@gmail.com", "email_verified": true, "phone_verified": false}	\N	2025-06-15 14:38:36.666339+00	2025-06-15 14:38:36.671718+00	\N	\N			\N		0	\N		\N	f	\N	f
00000000-0000-0000-0000-000000000000	34e9281c-a3b1-412d-ba7e-fe29dad024c9	authenticated	authenticated	mateksadiahq@gmail.com	$2a$10$rKvKiEqLeWKmwpWErcSLWOKrHhgNojZ6TBqpu.3r.nMAhZnVlkSP6	2025-06-15 14:38:37.140097+00	\N		\N		\N			\N	2025-06-15 14:38:37.141768+00	{"provider": "email", "providers": ["email"]}	{"sub": "34e9281c-a3b1-412d-ba7e-fe29dad024c9", "email": "mateksadiahq@gmail.com", "email_verified": true, "phone_verified": false}	\N	2025-06-15 14:38:37.137214+00	2025-06-15 14:38:37.143049+00	\N	\N			\N		0	\N		\N	f	\N	f
00000000-0000-0000-0000-000000000000	d8b08679-718a-49dc-a81d-141d5a5b048d	authenticated	authenticated	sustainabilitypr.ppom@gmail.com	$2a$10$YmxHirBCrpb3b3sYNHdpAeayVNyQrCDvWy8ODjH8TI.fbX0BCfVT2	2025-06-15 14:38:37.339537+00	\N		\N		\N			\N	2025-06-15 14:38:37.341373+00	{"provider": "email", "providers": ["email"]}	{"sub": "d8b08679-718a-49dc-a81d-141d5a5b048d", "email": "sustainabilitypr.ppom@gmail.com", "email_verified": true, "phone_verified": false}	\N	2025-06-15 14:38:37.33614+00	2025-06-15 14:38:37.342358+00	\N	\N			\N		0	\N		\N	f	\N	f
00000000-0000-0000-0000-000000000000	4e33cfac-f5fe-4c35-9861-84d7917606ae	authenticated	authenticated	rveerasa@hotmail.com	$2a$10$ya/PZjX0Ib5EI2E4mX2h9emY8mV2Gw4Wh4OpahwemfiY3BNxuPwgm	2025-06-15 14:38:37.050126+00	\N		\N		\N			\N	2025-06-15 15:06:47.149629+00	{"provider": "email", "providers": ["email"]}	{"sub": "4e33cfac-f5fe-4c35-9861-84d7917606ae", "email": "rveerasa@hotmail.com", "email_verified": true, "phone_verified": false}	\N	2025-06-15 14:38:37.047209+00	2025-06-15 15:06:47.151003+00	\N	\N			\N		0	\N		\N	f	\N	f
00000000-0000-0000-0000-000000000000	54003f0f-9dc2-4142-a7a3-37781c6caa2f	authenticated	authenticated	muhsienbadrulisham@gmail.com	$2a$10$WOsBkMD07eh4woCPT10HT.hl3o47DxJkwNDc2YYPH.uwR5cJVCZzC	2025-06-15 14:38:37.435526+00	\N		\N		\N			\N	2025-06-15 14:38:37.43747+00	{"provider": "email", "providers": ["email"]}	{"sub": "54003f0f-9dc2-4142-a7a3-37781c6caa2f", "email": "muhsienbadrulisham@gmail.com", "email_verified": true, "phone_verified": false}	\N	2025-06-15 14:38:37.432654+00	2025-06-15 14:38:37.4385+00	\N	\N			\N		0	\N		\N	f	\N	f
00000000-0000-0000-0000-000000000000	0a7806d8-7b08-4629-bcfc-b5304bc684c4	authenticated	authenticated	murshidayusoff@gmail.com	$2a$10$b3TSwUsgfmv0opnbMn5xY.ytIA..N5/YmQ26PB1TRiuOQnYRA8tia	2025-06-15 14:38:37.526208+00	\N		\N		\N			\N	2025-06-15 14:38:37.527909+00	{"provider": "email", "providers": ["email"]}	{"sub": "0a7806d8-7b08-4629-bcfc-b5304bc684c4", "email": "murshidayusoff@gmail.com", "email_verified": true, "phone_verified": false}	\N	2025-06-15 14:38:37.522444+00	2025-06-15 14:38:37.528923+00	\N	\N			\N		0	\N		\N	f	\N	f
00000000-0000-0000-0000-000000000000	01f2db6b-0dc0-45f1-842b-aced9d793fe6	authenticated	authenticated	nazmizain4499@yahoo.com	$2a$10$H8evQGa5QYyWp.GkMcPob.TiKebeE88tPt.fa4wmbMlGt4hY7uYBq	2025-06-15 14:38:37.821572+00	\N		\N		\N			\N	2025-06-15 14:38:37.823291+00	{"provider": "email", "providers": ["email"]}	{"sub": "01f2db6b-0dc0-45f1-842b-aced9d793fe6", "email": "nazmizain4499@yahoo.com", "email_verified": true, "phone_verified": false}	\N	2025-06-15 14:38:37.818788+00	2025-06-15 14:38:37.824318+00	\N	\N			\N		0	\N		\N	f	\N	f
00000000-0000-0000-0000-000000000000	7d417c53-b437-40ff-911a-8d9eef5e2977	authenticated	authenticated	tajuddinkamil@yahoo.com	$2a$10$ki.YZbJmlmcN5ZYnSQ45n.w7Yat0w9CW6ITej6yMJIyaszmxnik0q	2025-06-15 14:38:38.976599+00	\N		\N		\N			\N	2025-06-15 14:38:38.978129+00	{"provider": "email", "providers": ["email"]}	{"sub": "7d417c53-b437-40ff-911a-8d9eef5e2977", "email": "tajuddinkamil@yahoo.com", "email_verified": true, "phone_verified": false}	\N	2025-06-15 14:38:38.973095+00	2025-06-15 14:38:38.979131+00	\N	\N			\N		0	\N		\N	f	\N	f
00000000-0000-0000-0000-000000000000	e8e773cd-d387-4efc-b92e-98dd804a3dd3	authenticated	authenticated	nurulsyahira336@gmail.com	$2a$10$gTG38LBjZjMmty0svYGqO.Rp1ROlGMDUsWFnzTqiWr2Y7uBqLRIgK	2025-06-15 14:38:38.582215+00	\N		\N		\N			\N	2025-06-15 14:38:38.58465+00	{"provider": "email", "providers": ["email"]}	{"sub": "e8e773cd-d387-4efc-b92e-98dd804a3dd3", "email": "nurulsyahira336@gmail.com", "email_verified": true, "phone_verified": false}	\N	2025-06-15 14:38:38.57942+00	2025-06-15 14:38:38.58567+00	\N	\N			\N		0	\N		\N	f	\N	f
00000000-0000-0000-0000-000000000000	4af83a63-96e1-44ea-a7aa-749a66e5fcd7	authenticated	authenticated	michaeln@sarawak.gov.my	$2a$10$9WaLNSpmMQuueSB06Wht4OKayzOPfCLBEeka.KcCfRFynO2EdyPMe	2025-06-15 14:38:38.120041+00	\N		\N		\N			\N	2025-06-15 14:38:38.121879+00	{"provider": "email", "providers": ["email"]}	{"sub": "4af83a63-96e1-44ea-a7aa-749a66e5fcd7", "email": "michaeln@sarawak.gov.my", "email_verified": true, "phone_verified": false}	\N	2025-06-15 14:38:38.117228+00	2025-06-15 14:38:38.122881+00	\N	\N			\N		0	\N		\N	f	\N	f
00000000-0000-0000-0000-000000000000	2fc4583b-c10b-423a-a6fe-a5e25b7bc801	authenticated	authenticated	monsokmill@gmail.com	$2a$10$2V3YY.rBIG5mUAEngyMedeRV3hjRlwPDV5yIUczNjGhkpzOBXXhsO	2025-06-15 14:38:37.924753+00	\N		\N		\N			\N	2025-06-15 14:38:37.926387+00	{"provider": "email", "providers": ["email"]}	{"sub": "2fc4583b-c10b-423a-a6fe-a5e25b7bc801", "email": "monsokmill@gmail.com", "email_verified": true, "phone_verified": false}	\N	2025-06-15 14:38:37.921805+00	2025-06-15 14:38:37.927309+00	\N	\N			\N		0	\N		\N	f	\N	f
00000000-0000-0000-0000-000000000000	3a62ecb7-b6c8-4883-9066-4e1a871adc12	authenticated	authenticated	test@yahoo.com	$2a$10$/pQc2ibAqcz/7kyvWdtYQurGLkazS2tQKXeEUrVdUVjzNM.47dbeq	2025-06-15 14:38:38.306664+00	\N		\N		\N			\N	2025-06-15 14:38:38.308276+00	{"provider": "email", "providers": ["email"]}	{"sub": "3a62ecb7-b6c8-4883-9066-4e1a871adc12", "email": "test@yahoo.com", "email_verified": true, "phone_verified": false}	\N	2025-06-15 14:38:38.303665+00	2025-06-15 14:38:38.309309+00	\N	\N			\N		0	\N		\N	f	\N	f
00000000-0000-0000-0000-000000000000	e6dae6f9-e483-4071-923d-095f173ed23e	authenticated	authenticated	dylan.j.ong@gmail.com	$2a$10$luxZ5hHP8aWPiQs.N2UMN.xhqvJDxujfrdZ01a0Oq.Mnlce9NAUM.	2025-06-15 14:38:39.069174+00	\N		\N		\N			\N	2025-06-15 14:38:39.070842+00	{"provider": "email", "providers": ["email"]}	{"sub": "e6dae6f9-e483-4071-923d-095f173ed23e", "email": "dylan.j.ong@gmail.com", "email_verified": true, "phone_verified": false}	\N	2025-06-15 14:38:39.066311+00	2025-06-15 14:38:39.071817+00	\N	\N			\N		0	\N		\N	f	\N	f
00000000-0000-0000-0000-000000000000	24f097e0-aad9-486d-887d-590379cf8f78	authenticated	authenticated	kasthuri@unitedmalacca.com.my	$2a$10$C62Tp/QZNSQkNGrCaG6wi.Sbfn3um8.59jNhEu5NGXyFdpNvzHHLm	2025-06-15 14:38:38.215979+00	\N		\N		\N			\N	2025-06-15 14:38:38.217533+00	{"provider": "email", "providers": ["email"]}	{"sub": "24f097e0-aad9-486d-887d-590379cf8f78", "email": "kasthuri@unitedmalacca.com.my", "email_verified": true, "phone_verified": false}	\N	2025-06-15 14:38:38.213165+00	2025-06-15 14:38:38.218924+00	\N	\N			\N		0	\N		\N	f	\N	f
00000000-0000-0000-0000-000000000000	15f0f3a4-341a-4342-bca2-11c1d03d82a6	authenticated	authenticated	parameswaran_subramaniam@jabil.com	$2a$10$PVsGpqldx3mfdTK9dMG1zu7tdSkTMRGFnLakddZNglV681xub37JG	2025-06-15 14:38:38.027634+00	\N		\N		\N			\N	2025-06-15 14:38:38.029235+00	{"provider": "email", "providers": ["email"]}	{"sub": "15f0f3a4-341a-4342-bca2-11c1d03d82a6", "email": "parameswaran_subramaniam@jabil.com", "email_verified": true, "phone_verified": false}	\N	2025-06-15 14:38:38.024611+00	2025-06-15 14:38:38.030252+00	\N	\N			\N		0	\N		\N	f	\N	f
00000000-0000-0000-0000-000000000000	8d17a10c-9baa-4371-be70-35eff53317e4	authenticated	authenticated	padil5595@gmail.com	$2a$10$3fMcMAEaA.mg11CPa.Ag/utnE9EnLRp4PtKLdboSLrsuX5ZKCRjje	2025-06-15 14:38:38.491027+00	\N		\N		\N			\N	2025-06-15 14:38:38.49254+00	{"provider": "email", "providers": ["email"]}	{"sub": "8d17a10c-9baa-4371-be70-35eff53317e4", "email": "padil5595@gmail.com", "email_verified": true, "phone_verified": false}	\N	2025-06-15 14:38:38.488247+00	2025-06-15 14:38:38.493522+00	\N	\N			\N		0	\N		\N	f	\N	f
00000000-0000-0000-0000-000000000000	e1ccea0a-ccc5-48c9-98dd-26a48399ec52	authenticated	authenticated	suhaidakanjisuhaida@gmail.com	$2a$10$CsBVlP5TwcvbRs/rOezn8uW9moQsFNzvlTNDlfzv0nwjSov0jOFZy	2025-06-15 14:38:38.676465+00	\N		\N		\N			\N	2025-06-15 14:38:38.678261+00	{"provider": "email", "providers": ["email"]}	{"sub": "e1ccea0a-ccc5-48c9-98dd-26a48399ec52", "email": "suhaidakanjisuhaida@gmail.com", "email_verified": true, "phone_verified": false}	\N	2025-06-15 14:38:38.673658+00	2025-06-15 14:38:38.679311+00	\N	\N			\N		0	\N		\N	f	\N	f
00000000-0000-0000-0000-000000000000	bdbfe7f9-be3d-45db-9e74-0bafc00e3da8	authenticated	authenticated	rudy_patrick@ymail.com	$2a$10$Qy/BoWxtoSbRkxJtm.BQwO/d4SJHrODIlBFpLcr3GSop5NrA347ye	2025-06-15 14:38:38.403072+00	\N		\N		\N			\N	2025-06-15 14:38:38.404577+00	{"provider": "email", "providers": ["email"]}	{"sub": "bdbfe7f9-be3d-45db-9e74-0bafc00e3da8", "email": "rudy_patrick@ymail.com", "email_verified": true, "phone_verified": false}	\N	2025-06-15 14:38:38.4002+00	2025-06-15 14:38:38.405523+00	\N	\N			\N		0	\N		\N	f	\N	f
00000000-0000-0000-0000-000000000000	cc6ec44c-3285-40f9-84fd-fe38f6cac978	authenticated	authenticated	ravestan@gmail.com	$2a$10$pktRud4uxFBasEsJgJ82mu/fSE2S4o60YanhwnGFvA/CE46AeDLcW	2025-06-15 14:38:38.77917+00	\N		\N		\N			\N	2025-06-15 14:38:38.780781+00	{"provider": "email", "providers": ["email"]}	{"sub": "cc6ec44c-3285-40f9-84fd-fe38f6cac978", "email": "ravestan@gmail.com", "email_verified": true, "phone_verified": false}	\N	2025-06-15 14:38:38.775858+00	2025-06-15 14:38:38.781815+00	\N	\N			\N		0	\N		\N	f	\N	f
00000000-0000-0000-0000-000000000000	5ad2dbaf-6d13-47a0-b9d2-47b7adb86ff0	authenticated	authenticated	imj800120@gmail.com	$2a$10$qxd.I8/4GY4fASYitFaTEuS207lnO3Fg4aOxEdPWyKDj0SXHoTRO.	2025-06-15 14:38:38.876694+00	\N		\N		\N			\N	2025-06-15 14:38:38.87817+00	{"provider": "email", "providers": ["email"]}	{"sub": "5ad2dbaf-6d13-47a0-b9d2-47b7adb86ff0", "email": "imj800120@gmail.com", "email_verified": true, "phone_verified": false}	\N	2025-06-15 14:38:38.873367+00	2025-06-15 14:38:38.879206+00	\N	\N			\N		0	\N		\N	f	\N	f
00000000-0000-0000-0000-000000000000	24d8cbc0-b247-4c06-bd71-80c775c228f0	authenticated	authenticated	solidorient2812@gmail.com	$2a$10$eUcNPyZZn8I6slmr1BFKAu.QtuJspRtfE2mhfKpkPckXXFd137S2W	2025-06-15 14:38:39.161361+00	\N		\N		\N			\N	2025-06-15 14:38:39.163299+00	{"provider": "email", "providers": ["email"]}	{"sub": "24d8cbc0-b247-4c06-bd71-80c775c228f0", "email": "solidorient2812@gmail.com", "email_verified": true, "phone_verified": false}	\N	2025-06-15 14:38:39.158497+00	2025-06-15 14:38:39.164321+00	\N	\N			\N		0	\N		\N	f	\N	f
00000000-0000-0000-0000-000000000000	4120635d-c542-437d-9cea-9319b2338db0	authenticated	authenticated	allariff@st.gov.my	$2a$10$NMFKRnWwzdXfBgNVaV7Cgeimr7d9Qks6mFx9wa9txe5wyVN1YAIxa	2025-06-15 14:38:40.343046+00	\N		\N		\N			\N	2025-06-15 14:38:40.344736+00	{"provider": "email", "providers": ["email"]}	{"sub": "4120635d-c542-437d-9cea-9319b2338db0", "email": "allariff@st.gov.my", "email_verified": true, "phone_verified": false}	\N	2025-06-15 14:38:40.339761+00	2025-06-15 14:38:40.345771+00	\N	\N			\N		0	\N		\N	f	\N	f
00000000-0000-0000-0000-000000000000	a31bd0c1-174b-4922-a1b7-e60acc9b25b4	authenticated	authenticated	wl.young@davoslife.com	$2a$10$RBOuO2mdZ2iuee5AB64.QuwRDYCnYWVQNIE5rrBDky8Au.kojsXEa	2025-06-15 14:38:39.966772+00	\N		\N		\N			\N	2025-06-15 14:38:39.9683+00	{"provider": "email", "providers": ["email"]}	{"sub": "a31bd0c1-174b-4922-a1b7-e60acc9b25b4", "email": "wl.young@davoslife.com", "email_verified": true, "phone_verified": false}	\N	2025-06-15 14:38:39.963644+00	2025-06-15 14:38:39.96927+00	\N	\N			\N		0	\N		\N	f	\N	f
00000000-0000-0000-0000-000000000000	54762cd7-e15c-4dfe-b8c3-620921ec2366	authenticated	authenticated	rose_rmy@hotmail.com	$2a$10$jsxExNOlLxOLqMj2RKYlpO9Bdf2hOtKsfTSC8HJRmNeQi7JUPP8Sm	2025-06-15 14:38:39.463902+00	\N		\N		\N			\N	2025-06-15 14:38:39.465631+00	{"provider": "email", "providers": ["email"]}	{"sub": "54762cd7-e15c-4dfe-b8c3-620921ec2366", "email": "rose_rmy@hotmail.com", "email_verified": true, "phone_verified": false}	\N	2025-06-15 14:38:39.460835+00	2025-06-15 14:38:39.466696+00	\N	\N			\N		0	\N		\N	f	\N	f
00000000-0000-0000-0000-000000000000	c03ad22a-b91d-4788-9b2e-d4e016651a9b	authenticated	authenticated	jasrsb@gmail.com	$2a$10$sz8s2NIXiu402n/tJ0SXle3kJhIUwPhwljh9XsQIDy.iD9eOJv0N.	2025-06-15 14:38:39.265012+00	\N		\N		\N			\N	2025-06-15 14:38:39.266925+00	{"provider": "email", "providers": ["email"]}	{"sub": "c03ad22a-b91d-4788-9b2e-d4e016651a9b", "email": "jasrsb@gmail.com", "email_verified": true, "phone_verified": false}	\N	2025-06-15 14:38:39.261715+00	2025-06-15 14:38:39.268397+00	\N	\N			\N		0	\N		\N	f	\N	f
00000000-0000-0000-0000-000000000000	646b90b4-51f9-44ce-9e89-41492cb826f9	authenticated	authenticated	siing8807@gmail.com	$2a$10$hf3tlffyPuQ7SzqFl2ewnOLCeTIMl822L2yh/AteqXNGodRt/TFWG	2025-06-15 14:38:39.661024+00	\N		\N		\N			\N	2025-06-15 14:38:39.662505+00	{"provider": "email", "providers": ["email"]}	{"sub": "646b90b4-51f9-44ce-9e89-41492cb826f9", "email": "siing8807@gmail.com", "email_verified": true, "phone_verified": false}	\N	2025-06-15 14:38:39.658203+00	2025-06-15 14:38:39.663449+00	\N	\N			\N		0	\N		\N	f	\N	f
00000000-0000-0000-0000-000000000000	93a02249-5316-49a2-9ac7-12b4c8905133	authenticated	authenticated	zuki.ak@fgvholdings.com	$2a$10$Q03MfjnHyKbS5sfOmiPB2.UmbduUtrsQCpwWoTGdglTXgCcj2RrwK	2025-06-15 14:38:40.444558+00	\N		\N		\N			\N	2025-06-15 14:38:40.446311+00	{"provider": "email", "providers": ["email"]}	{"sub": "93a02249-5316-49a2-9ac7-12b4c8905133", "email": "zuki.ak@fgvholdings.com", "email_verified": true, "phone_verified": false}	\N	2025-06-15 14:38:40.441328+00	2025-06-15 14:38:40.447464+00	\N	\N			\N		0	\N		\N	f	\N	f
00000000-0000-0000-0000-000000000000	6b17a4a1-6399-4241-8bae-98ce72ffd9b8	authenticated	authenticated	syafiqdanial1803@hotmail.com	$2a$10$QOSsGK9/DO6G0XplkQlRT.4wrSgNF7Id5Zgss6xKgXQHnbV6LyMOe	2025-06-15 14:38:39.56258+00	\N		\N		\N			\N	2025-06-15 14:38:39.56427+00	{"provider": "email", "providers": ["email"]}	{"sub": "6b17a4a1-6399-4241-8bae-98ce72ffd9b8", "email": "syafiqdanial1803@hotmail.com", "email_verified": true, "phone_verified": false}	\N	2025-06-15 14:38:39.55949+00	2025-06-15 14:38:39.565319+00	\N	\N			\N		0	\N		\N	f	\N	f
00000000-0000-0000-0000-000000000000	fe48a53d-699e-4b91-9987-efdd47b9b34b	authenticated	authenticated	andyaw8149@gmail.com	$2a$10$KoSTr86DHnOp4VZzRbUr3uD6RUa68Y4EvApNzI9CqzFJxJ9LyhRGa	2025-06-15 14:38:39.364324+00	\N		\N		\N			\N	2025-06-15 14:38:39.365893+00	{"provider": "email", "providers": ["email"]}	{"sub": "fe48a53d-699e-4b91-9987-efdd47b9b34b", "email": "andyaw8149@gmail.com", "email_verified": true, "phone_verified": false}	\N	2025-06-15 14:38:39.361424+00	2025-06-15 14:38:39.366969+00	\N	\N			\N		0	\N		\N	f	\N	f
00000000-0000-0000-0000-000000000000	33f581a6-b5de-49d8-acdd-1166f5a55844	authenticated	authenticated	burnbakar1538@gmail.com	$2a$10$NGGSEhmaPOP.L22mhxWzDOcJ3abWY0x/8QSdWDtL7BNQRsRNjrOdi	2025-06-15 14:38:39.871033+00	\N		\N		\N			\N	2025-06-15 14:38:39.872524+00	{"provider": "email", "providers": ["email"]}	{"sub": "33f581a6-b5de-49d8-acdd-1166f5a55844", "email": "burnbakar1538@gmail.com", "email_verified": true, "phone_verified": false}	\N	2025-06-15 14:38:39.867956+00	2025-06-15 14:38:39.873561+00	\N	\N			\N		0	\N		\N	f	\N	f
00000000-0000-0000-0000-000000000000	6a07ae1f-58b7-49a3-b140-407f7039c517	authenticated	authenticated	mages@op.shh.my	$2a$10$kSVOFUnmWYWzSUR5O.g.Q.CzdhsubJOnUQ20goC8xz3E7if9/z7V2	2025-06-15 14:38:40.15374+00	\N		\N		\N			\N	2025-06-15 14:38:40.155244+00	{"provider": "email", "providers": ["email"]}	{"sub": "6a07ae1f-58b7-49a3-b140-407f7039c517", "email": "mages@op.shh.my", "email_verified": true, "phone_verified": false}	\N	2025-06-15 14:38:40.151114+00	2025-06-15 14:38:40.156178+00	\N	\N			\N		0	\N		\N	f	\N	f
00000000-0000-0000-0000-000000000000	0492f0e6-5805-44af-aa74-4db0c77a4140	authenticated	authenticated	cbpb860009@gmail.com	$2a$10$UPciGm.94DmHHZ6M.IwV0eAhlKLlT/lxnLkWRMyasge/LgfjpK4ES	2025-06-15 14:38:40.063529+00	\N		\N		\N			\N	2025-06-15 14:38:40.064996+00	{"provider": "email", "providers": ["email"]}	{"sub": "0492f0e6-5805-44af-aa74-4db0c77a4140", "email": "cbpb860009@gmail.com", "email_verified": true, "phone_verified": false}	\N	2025-06-15 14:38:40.060305+00	2025-06-15 14:38:40.065927+00	\N	\N			\N		0	\N		\N	f	\N	f
00000000-0000-0000-0000-000000000000	6f88c691-03be-4853-8903-67e2bca0d234	authenticated	authenticated	kitying88@gmail.com	$2a$10$YrZLnoibLWr.i8Ep2sXQRuD/FQfSiGUbm7Ot28RItNqOj8sLvG7DO	2025-06-15 14:38:39.771124+00	\N		\N		\N			\N	2025-06-15 14:38:39.772927+00	{"provider": "email", "providers": ["email"]}	{"sub": "6f88c691-03be-4853-8903-67e2bca0d234", "email": "kitying88@gmail.com", "email_verified": true, "phone_verified": false}	\N	2025-06-15 14:38:39.767481+00	2025-06-15 14:38:39.774023+00	\N	\N			\N		0	\N		\N	f	\N	f
00000000-0000-0000-0000-000000000000	25c9e59a-dddc-4e8d-9b27-4033d9f1274a	authenticated	authenticated	elink.hidayat@gmail.com	$2a$10$mMc3tgYYNtnT6KbYx4/cxetvtVMNDfKpBzmkhkR56VcurLq4uq7s.	2025-06-15 14:38:40.246115+00	\N		\N		\N			\N	2025-06-15 14:38:40.247745+00	{"provider": "email", "providers": ["email"]}	{"sub": "25c9e59a-dddc-4e8d-9b27-4033d9f1274a", "email": "elink.hidayat@gmail.com", "email_verified": true, "phone_verified": false}	\N	2025-06-15 14:38:40.243208+00	2025-06-15 14:38:40.248712+00	\N	\N			\N		0	\N		\N	f	\N	f
00000000-0000-0000-0000-000000000000	fd863516-76ca-4417-8047-db3bdf0cb04e	authenticated	authenticated	alexius.n@fgvholding.socm	$2a$10$3OXm8JnMV55vqANHQ6zVr.B2AO9fH3g1OrsytT1xYd8vZ.5Yd5sW2	2025-06-15 14:38:40.538018+00	\N		\N		\N			\N	2025-06-15 14:38:40.539817+00	{"provider": "email", "providers": ["email"]}	{"sub": "fd863516-76ca-4417-8047-db3bdf0cb04e", "email": "alexius.n@fgvholding.socm", "email_verified": true, "phone_verified": false}	\N	2025-06-15 14:38:40.535244+00	2025-06-15 14:38:40.540824+00	\N	\N			\N		0	\N		\N	f	\N	f
00000000-0000-0000-0000-000000000000	b37636b3-8be1-4178-9cf2-8b57f5394441	authenticated	authenticated	vendettavendetta326@gmail.com	$2a$10$Y4IZ45FrNGCkgPcMDNO1pO31eqkvLxivK8jj1KgILDcX8NlUpZlAu	2025-06-15 14:38:41.669807+00	\N		\N		\N			\N	2025-06-15 14:38:41.671356+00	{"provider": "email", "providers": ["email"]}	{"sub": "b37636b3-8be1-4178-9cf2-8b57f5394441", "email": "vendettavendetta326@gmail.com", "email_verified": true, "phone_verified": false}	\N	2025-06-15 14:38:41.6669+00	2025-06-15 14:38:41.67236+00	\N	\N			\N		0	\N		\N	f	\N	f
00000000-0000-0000-0000-000000000000	80c123de-90b0-4fd6-9424-1e93e57c96fb	authenticated	authenticated	bintang@bell.com.my	$2a$10$2at0kqOHuvpxhQpL/CMxyeBhTe2ovTbHvLVsv4HhGgsM1WE2QHyAq	2025-06-15 14:38:41.299629+00	\N		\N		\N			\N	2025-06-15 14:38:41.301196+00	{"provider": "email", "providers": ["email"]}	{"sub": "80c123de-90b0-4fd6-9424-1e93e57c96fb", "email": "bintang@bell.com.my", "email_verified": true, "phone_verified": false}	\N	2025-06-15 14:38:41.29682+00	2025-06-15 14:38:41.302149+00	\N	\N			\N		0	\N		\N	f	\N	f
00000000-0000-0000-0000-000000000000	3daebba2-2008-456d-85ff-0f51d49e2068	authenticated	authenticated	khairulidzuan@fjgroup.com.my	$2a$10$6..EKwpkwCrSyVAOGoD8OOxptx5UhDwp/f/nbOfHiUk/wpAvTASTC	2025-06-15 14:38:40.816744+00	\N		\N		\N			\N	2025-06-15 14:38:40.818388+00	{"provider": "email", "providers": ["email"]}	{"sub": "3daebba2-2008-456d-85ff-0f51d49e2068", "email": "khairulidzuan@fjgroup.com.my", "email_verified": true, "phone_verified": false}	\N	2025-06-15 14:38:40.813712+00	2025-06-15 14:38:40.819346+00	\N	\N			\N		0	\N		\N	f	\N	f
00000000-0000-0000-0000-000000000000	e8eef5b6-23c8-43b6-b361-5407820aa1bd	authenticated	authenticated	andyjhall1979@gmail.com	$2a$10$vDuGksDPZHAziO.ajkU29.nEOYakZj1q9c8Ym5gHan9KiPzRpPMQq	2025-06-15 14:38:40.633356+00	\N		\N		\N			\N	2025-06-15 14:38:40.634909+00	{"provider": "email", "providers": ["email"]}	{"sub": "e8eef5b6-23c8-43b6-b361-5407820aa1bd", "email": "andyjhall1979@gmail.com", "email_verified": true, "phone_verified": false}	\N	2025-06-15 14:38:40.630419+00	2025-06-15 14:38:40.635871+00	\N	\N			\N		0	\N		\N	f	\N	f
00000000-0000-0000-0000-000000000000	4838f267-e471-42c2-960a-afb1bbe50dd5	authenticated	authenticated	ongtp@gtsr.com.my	$2a$10$u.2Q3ANL8/KZaQw6l7/Q8eRKZO6Pigh1.pbRQyVewm3IWHGcARUTG	2025-06-15 14:38:41.013479+00	\N		\N		\N			\N	2025-06-15 14:38:41.014935+00	{"provider": "email", "providers": ["email"]}	{"sub": "4838f267-e471-42c2-960a-afb1bbe50dd5", "email": "ongtp@gtsr.com.my", "email_verified": true, "phone_verified": false}	\N	2025-06-15 14:38:41.010585+00	2025-06-15 14:38:41.015932+00	\N	\N			\N		0	\N		\N	f	\N	f
00000000-0000-0000-0000-000000000000	86c5fd15-a47d-44b9-94f9-864b787d7db8	authenticated	authenticated	foong9626@gmail.com	$2a$10$lakZBtwk.p7/OeERmN37WeBTf8qf1poRLsX.LC.0N3URpJq09Ldlu	2025-06-15 14:38:41.768065+00	\N		\N		\N			\N	2025-06-15 14:38:41.769654+00	{"provider": "email", "providers": ["email"]}	{"sub": "86c5fd15-a47d-44b9-94f9-864b787d7db8", "email": "foong9626@gmail.com", "email_verified": true, "phone_verified": false}	\N	2025-06-15 14:38:41.764331+00	2025-06-15 14:38:41.77074+00	\N	\N			\N		0	\N		\N	f	\N	f
00000000-0000-0000-0000-000000000000	79e11466-b344-4852-81cb-39ff9e45ebc0	authenticated	authenticated	mimisharida@gmail.com	$2a$10$NffYscEcl7H04T27EGU41Ob/0hlLZXRXbLczI.vMlS9oMVArfIA2W	2025-06-15 14:38:40.918378+00	\N		\N		\N			\N	2025-06-15 14:38:40.919938+00	{"provider": "email", "providers": ["email"]}	{"sub": "79e11466-b344-4852-81cb-39ff9e45ebc0", "email": "mimisharida@gmail.com", "email_verified": true, "phone_verified": false}	\N	2025-06-15 14:38:40.915262+00	2025-06-15 14:38:40.921027+00	\N	\N			\N		0	\N		\N	f	\N	f
00000000-0000-0000-0000-000000000000	0e4b6571-d7da-4d82-8035-b53821d50643	authenticated	authenticated	ladangdelima17@yahoo.com	$2a$10$ioW0RYDWaoZmoGJQ201qPeMfGzicCrtosi/flSv6wAcksX0NzUGGy	2025-06-15 14:38:40.724397+00	\N		\N		\N			\N	2025-06-15 14:38:40.725943+00	{"provider": "email", "providers": ["email"]}	{"sub": "0e4b6571-d7da-4d82-8035-b53821d50643", "email": "ladangdelima17@yahoo.com", "email_verified": true, "phone_verified": false}	\N	2025-06-15 14:38:40.721683+00	2025-06-15 14:38:40.727064+00	\N	\N			\N		0	\N		\N	f	\N	f
00000000-0000-0000-0000-000000000000	0b500a7c-c000-4b0f-b19a-4cc42e3d380e	authenticated	authenticated	ruekeithjampong@gmail.com	$2a$10$VkSnrPBBZiZOaLudrzv/O.OkkLZHuc1Z0vsjRObmrYHw9tTnLqmPe	2025-06-15 14:38:41.205315+00	\N		\N		\N			\N	2025-06-15 14:38:41.206867+00	{"provider": "email", "providers": ["email"]}	{"sub": "0b500a7c-c000-4b0f-b19a-4cc42e3d380e", "email": "ruekeithjampong@gmail.com", "email_verified": true, "phone_verified": false}	\N	2025-06-15 14:38:41.202655+00	2025-06-15 14:38:41.207882+00	\N	\N			\N		0	\N		\N	f	\N	f
00000000-0000-0000-0000-000000000000	77580fe9-7ac2-4fb0-9aa7-06995f768dea	authenticated	authenticated	rizal1976@gmail.com	$2a$10$VaJy9.ciBZlqkp2MKIAWT.P5yKPt6UiCgdk1pKZlfXbdtcNxdK6z6	2025-06-15 14:38:41.479895+00	\N		\N		\N			\N	2025-06-15 14:38:41.481347+00	{"provider": "email", "providers": ["email"]}	{"sub": "77580fe9-7ac2-4fb0-9aa7-06995f768dea", "email": "rizal1976@gmail.com", "email_verified": true, "phone_verified": false}	\N	2025-06-15 14:38:41.477146+00	2025-06-15 14:38:41.482279+00	\N	\N			\N		0	\N		\N	f	\N	f
00000000-0000-0000-0000-000000000000	bcc22448-661c-4e28-99a8-edb83a48195e	authenticated	authenticated	ainanajwa.sbh@gmail.com	$2a$10$dqQ//1SBvr0EOfs0zaOCOeroK0T2TCX.VmNVPR1bm9t7wdSR46mU2	2025-06-15 14:38:41.38925+00	\N		\N		\N			\N	2025-06-15 14:38:41.390752+00	{"provider": "email", "providers": ["email"]}	{"sub": "bcc22448-661c-4e28-99a8-edb83a48195e", "email": "ainanajwa.sbh@gmail.com", "email_verified": true, "phone_verified": false}	\N	2025-06-15 14:38:41.386348+00	2025-06-15 14:38:41.391801+00	\N	\N			\N		0	\N		\N	f	\N	f
00000000-0000-0000-0000-000000000000	4735ce34-ed6c-4b84-a258-c098689ca12f	authenticated	authenticated	wtkalpha@gmail.com	$2a$10$GEg6NJux7GMaOndgKR57v.H25VSP.dISbbQ/TCoD5WsBEAeSBW9li	2025-06-15 14:38:41.11005+00	\N		\N		\N			\N	2025-06-15 14:38:41.111742+00	{"provider": "email", "providers": ["email"]}	{"sub": "4735ce34-ed6c-4b84-a258-c098689ca12f", "email": "wtkalpha@gmail.com", "email_verified": true, "phone_verified": false}	\N	2025-06-15 14:38:41.106585+00	2025-06-15 14:38:41.112769+00	\N	\N			\N		0	\N		\N	f	\N	f
00000000-0000-0000-0000-000000000000	1d351dae-d3b7-476d-9c6a-c3851e6117f8	authenticated	authenticated	loureschristiansen@gmail.com	$2a$10$Q8CKAmthyOUtMSk/by/c8ON07ZVdgAG0URJGVXGR0uQZrIzXKfvky	2025-06-15 14:38:41.578673+00	\N		\N		\N			\N	2025-06-15 14:38:41.58026+00	{"provider": "email", "providers": ["email"]}	{"sub": "1d351dae-d3b7-476d-9c6a-c3851e6117f8", "email": "loureschristiansen@gmail.com", "email_verified": true, "phone_verified": false}	\N	2025-06-15 14:38:41.575645+00	2025-06-15 14:38:41.581439+00	\N	\N			\N		0	\N		\N	f	\N	f
00000000-0000-0000-0000-000000000000	26e06765-0726-4760-a956-cd6c133c8cf1	authenticated	authenticated	yakboy02@gmail.com	$2a$10$iPXmKrA9FG2S6EZQWkv5peT00xFDbMvM4RidPk6cqHQQI4STFhE8e	2025-06-15 14:38:41.869201+00	\N		\N		\N			\N	2025-06-15 14:38:41.870864+00	{"provider": "email", "providers": ["email"]}	{"sub": "26e06765-0726-4760-a956-cd6c133c8cf1", "email": "yakboy02@gmail.com", "email_verified": true, "phone_verified": false}	\N	2025-06-15 14:38:41.866089+00	2025-06-15 14:38:41.871828+00	\N	\N			\N		0	\N		\N	f	\N	f
00000000-0000-0000-0000-000000000000	20754c43-864b-45c9-8e9d-5f71b3dceb39	authenticated	authenticated	patriciachan@salcra.gov.my	$2a$10$uLlIg9.J.vP21LzMJfoFNeltZq.D5w0ATZ.ITiQ.Tx85h528Y1Xbq	2025-06-23 07:40:45.978929+00	\N		\N		\N			\N	2025-06-23 07:40:45.980914+00	{"provider": "email", "providers": ["email"]}	{"sub": "20754c43-864b-45c9-8e9d-5f71b3dceb39", "email": "patriciachan@salcra.gov.my", "email_verified": true, "phone_verified": false}	\N	2025-06-23 07:40:45.974692+00	2025-06-23 07:40:45.982096+00	\N	\N			\N		0	\N		\N	f	\N	f
00000000-0000-0000-0000-000000000000	ad892dc0-1949-48b7-be5e-d63c7290e512	authenticated	authenticated	hasbollah@mspo.org.my	$2a$10$GFrQv.z1YBPrMLFmDxkSSeCvCVpf8pFwR5M21UfDwubz1KTIlQq1e	2025-06-15 14:38:42.54266+00	\N		\N		\N			\N	2025-06-15 15:27:22.195834+00	{"provider": "email", "providers": ["email"]}	{"sub": "ad892dc0-1949-48b7-be5e-d63c7290e512", "email": "hasbollah@mspo.org.my", "email_verified": true, "phone_verified": false}	\N	2025-06-15 14:38:42.540072+00	2025-06-16 03:10:02.324788+00	\N	\N			\N		0	\N		\N	f	\N	f
00000000-0000-0000-0000-000000000000	97f7ac1a-aaf7-4061-8dba-cef646b37a3b	authenticated	authenticated	mohamadmat921231@gmail.com	$2a$10$ZqPL55C/P6GMFovEqU6Bo.xLtpDueiZDF9BpW6I24xMGxtLc0e3Z6	2025-06-15 14:38:42.15506+00	\N		\N		\N			\N	2025-06-15 14:38:42.156712+00	{"provider": "email", "providers": ["email"]}	{"sub": "97f7ac1a-aaf7-4061-8dba-cef646b37a3b", "email": "mohamadmat921231@gmail.com", "email_verified": true, "phone_verified": false}	\N	2025-06-15 14:38:42.15166+00	2025-06-15 14:38:42.157673+00	\N	\N			\N		0	\N		\N	f	\N	f
00000000-0000-0000-0000-000000000000	9899069d-e0c6-4dec-b3cd-e4080a838f61	authenticated	authenticated	aireimail24@gmail.com	$2a$10$RkoZfOxKt9q0.iBx4fxaoeLPQ28Q0oRhDnDzsX7uiv45DNQkAPjUS	2025-06-15 14:38:41.965029+00	\N		\N		\N			\N	2025-06-15 14:38:41.966848+00	{"provider": "email", "providers": ["email"]}	{"sub": "9899069d-e0c6-4dec-b3cd-e4080a838f61", "email": "aireimail24@gmail.com", "email_verified": true, "phone_verified": false}	\N	2025-06-15 14:38:41.961533+00	2025-06-15 14:38:41.968101+00	\N	\N			\N		0	\N		\N	f	\N	f
00000000-0000-0000-0000-000000000000	9bfb750a-2c2d-4bfc-9999-44fdabda74dd	authenticated	authenticated	kheongsc83@gmail.com	$2a$10$ZaKP1z1/VmpJ.ljF6lutW.XlmSujvGGq4UEFRZXdMnCpi1khLscH.	2025-06-15 14:38:42.351318+00	\N		\N		\N			\N	2025-06-15 14:38:42.352932+00	{"provider": "email", "providers": ["email"]}	{"sub": "9bfb750a-2c2d-4bfc-9999-44fdabda74dd", "email": "kheongsc83@gmail.com", "email_verified": true, "phone_verified": false}	\N	2025-06-15 14:38:42.347686+00	2025-06-15 14:38:42.353932+00	\N	\N			\N		0	\N		\N	f	\N	f
00000000-0000-0000-0000-000000000000	a1008ee6-6805-4d56-956d-0bcaad374870	authenticated	authenticated	abigail@salcra.gov.my	$2a$10$1iAeRTuzJfG2.OZeBood1uMwzdUfOhNDO0/dCXUYfosqwkvpG.R0O	2025-06-23 07:40:50.631464+00	\N		\N		\N			\N	2025-06-23 07:52:48.198112+00	{"provider": "email", "providers": ["email"]}	{"sub": "a1008ee6-6805-4d56-956d-0bcaad374870", "email": "abigail@salcra.gov.my", "email_verified": true, "phone_verified": false}	\N	2025-06-23 07:40:50.628008+00	2025-06-23 07:52:48.199198+00	\N	\N			\N		0	\N		\N	f	\N	f
00000000-0000-0000-0000-000000000000	e24e82c5-482d-44c5-95e4-0dec79afeffc	authenticated	authenticated	spnrajendran@gmail.com	$2a$10$KG0UMnz7A70.k2QQHmQU2uHL/RNtlvfGEs4jx4vbc8AbNaaIOWsd2	2025-06-15 14:38:42.247339+00	\N		\N		\N			\N	2025-06-15 14:38:42.248916+00	{"provider": "email", "providers": ["email"]}	{"sub": "e24e82c5-482d-44c5-95e4-0dec79afeffc", "email": "spnrajendran@gmail.com", "email_verified": true, "phone_verified": false}	\N	2025-06-15 14:38:42.244526+00	2025-06-15 14:38:42.249877+00	\N	\N			\N		0	\N		\N	f	\N	f
00000000-0000-0000-0000-000000000000	43e2d156-815e-45bc-a9c4-959ffc35a607	authenticated	authenticated	riswanrasid@gmail.com	$2a$10$hvr4fb0/erMoSpRgXc6Bh.Hkra1t8.JYMm7RGZ59MtHimDH6KP.W.	2025-06-15 14:38:42.058171+00	\N		\N		\N			\N	2025-06-15 14:38:42.059786+00	{"provider": "email", "providers": ["email"]}	{"sub": "43e2d156-815e-45bc-a9c4-959ffc35a607", "email": "riswanrasid@gmail.com", "email_verified": true, "phone_verified": false}	\N	2025-06-15 14:38:42.055225+00	2025-06-15 14:38:42.060754+00	\N	\N			\N		0	\N		\N	f	\N	f
00000000-0000-0000-0000-000000000000	bb194837-db77-40d9-a6fd-5e9737c5724e	authenticated	authenticated	pom_logo@yopmail.com	$2a$10$yYcYUy..Z5Bz89k/WGiYfOj/Dr/FZSrYdCLA7xOTuf2tWHo7HWOte	2025-06-18 02:09:49.671567+00	\N		\N		\N			\N	2025-06-18 02:12:53.843837+00	{"provider": "email", "providers": ["email"]}	{"sub": "bb194837-db77-40d9-a6fd-5e9737c5724e", "email": "pom_logo@yopmail.com", "email_verified": true, "phone_verified": false}	\N	2025-06-18 02:09:49.609869+00	2025-06-18 07:00:15.796475+00	\N	\N			\N		0	\N		\N	f	\N	f
00000000-0000-0000-0000-000000000000	fc2ca455-d9cb-44de-a313-e5f66f65a688	authenticated	authenticated	ussepudun2050@gmail.com	$2a$10$MUnOTEHGrPxwjAhPQGK/QOnXPGPiaSRvLY2AOgHwxFb8nkctBXS0K	2025-06-15 14:38:42.447051+00	\N		\N		\N			\N	2025-06-15 14:38:42.448775+00	{"provider": "email", "providers": ["email"]}	{"sub": "fc2ca455-d9cb-44de-a313-e5f66f65a688", "email": "ussepudun2050@gmail.com", "email_verified": true, "phone_verified": false}	\N	2025-06-15 14:38:42.444166+00	2025-06-15 14:38:42.450139+00	\N	\N			\N		0	\N		\N	f	\N	f
00000000-0000-0000-0000-000000000000	8bc44ea0-2e33-458a-ac4d-298980c44b05	authenticated	authenticated	christabelle.winona@tsggroup.my	$2a$10$95Py2aOUgI43y4v9PuqOPeCd9Bf8cRZl4uv0B6nrBEqjKTR2hz9B6	2025-06-23 07:40:12.639907+00	\N		\N		\N			\N	2025-06-23 07:42:39.769539+00	{"provider": "email", "providers": ["email"]}	{"sub": "8bc44ea0-2e33-458a-ac4d-298980c44b05", "email": "christabelle.winona@tsggroup.my", "email_verified": true, "phone_verified": false}	\N	2025-06-23 07:40:12.535056+00	2025-06-23 13:37:10.613984+00	\N	\N			\N		0	\N		\N	f	\N	f
00000000-0000-0000-0000-000000000000	c3a67ce5-0445-4f78-8259-c115bc188a26	authenticated	authenticated	tingpikhieng@gmail.com	$2a$10$tIMlV.vjOBLi1mrGO8I4DerA3akYPOEAnlFPm6KQLwKGkeOx5MG1q	2025-06-23 07:40:31.20579+00	\N		\N		\N			\N	2025-06-23 07:43:19.096957+00	{"provider": "email", "providers": ["email"]}	{"sub": "c3a67ce5-0445-4f78-8259-c115bc188a26", "email": "tingpikhieng@gmail.com", "email_verified": true, "phone_verified": false}	\N	2025-06-23 07:40:31.189067+00	2025-06-23 07:43:19.09798+00	\N	\N			\N		0	\N		\N	f	\N	f
00000000-0000-0000-0000-000000000000	e2c36046-d53b-4a02-9eef-f85a47d6c357	authenticated	authenticated	stephen.lee@grandolie.com	$2a$10$.n5tkb9bV9hOr.peDR1xt.e3ouvFAdsigCSXL3dj6BQ4IBvbsHMRa	2025-06-23 07:40:13.673969+00	\N		\N		\N			\N	2025-06-23 07:45:00.739803+00	{"provider": "email", "providers": ["email"]}	{"sub": "e2c36046-d53b-4a02-9eef-f85a47d6c357", "email": "stephen.lee@grandolie.com", "email_verified": true, "phone_verified": false}	\N	2025-06-23 07:40:13.669762+00	2025-06-23 07:45:00.740831+00	\N	\N			\N		0	\N		\N	f	\N	f
00000000-0000-0000-0000-000000000000	0d12ddb0-122b-46a3-afba-c35c8640e887	authenticated	authenticated	simleongeng@yahoo.com	$2a$10$Zlv1h9QkTovkrfinUQKa2.8POxJBYk5PK/rPLCXlE9xVMVxzU0i/q	2025-06-23 07:43:26.703154+00	\N		\N		\N			\N	2025-06-23 07:56:04.737701+00	{"provider": "email", "providers": ["email"]}	{"sub": "0d12ddb0-122b-46a3-afba-c35c8640e887", "email": "simleongeng@yahoo.com", "email_verified": true, "phone_verified": false}	\N	2025-06-23 07:43:26.700104+00	2025-06-23 07:56:04.738952+00	\N	\N			\N		0	\N		\N	f	\N	f
00000000-0000-0000-0000-000000000000	3f695e7a-da08-4344-8d1c-60d1e4d3d772	authenticated	authenticated	josephrn@salcra.gov.my	$2a$10$D.cTswHKBaih4IKX.duqZ.vj0uJmEgQ2g9NYGznpnFi0zb6fnkRPa	2025-06-23 07:42:25.110547+00	\N		\N		\N			\N	2025-06-23 07:42:25.1123+00	{"provider": "email", "providers": ["email"]}	{"sub": "3f695e7a-da08-4344-8d1c-60d1e4d3d772", "email": "josephrn@salcra.gov.my", "email_verified": true, "phone_verified": false}	\N	2025-06-23 07:42:25.107499+00	2025-06-23 07:42:25.113362+00	\N	\N			\N		0	\N		\N	f	\N	f
00000000-0000-0000-0000-000000000000	5dfc121a-a553-4380-9094-d716a81b495f	authenticated	authenticated	francefcw@yahoo.com	$2a$10$bSOIn0N2QszplYQXIpCBp.//eIQwzlnOZ2nHvxXdDBCnKYbT9KSHK	2025-06-23 07:41:59.338989+00	\N		\N		\N			\N	2025-06-23 07:42:27.067436+00	{"provider": "email", "providers": ["email"]}	{"sub": "5dfc121a-a553-4380-9094-d716a81b495f", "email": "francefcw@yahoo.com", "email_verified": true, "phone_verified": false}	\N	2025-06-23 07:41:59.335707+00	2025-06-23 07:42:27.06859+00	\N	\N			\N		0	\N		\N	f	\N	f
00000000-0000-0000-0000-000000000000	0cd2be50-abf7-420e-a986-7fa5371cf6a3	authenticated	authenticated	emilia.as@tpb.com.my	$2a$10$lrkOV62GQfPIN4fzNlopIesaw1MMPtFh9vZ2Y/WPbAtyPifR32n2S	2025-06-23 07:44:11.299251+00	\N		\N		\N			\N	2025-06-23 07:44:11.301143+00	{"provider": "email", "providers": ["email"]}	{"sub": "0cd2be50-abf7-420e-a986-7fa5371cf6a3", "email": "emilia.as@tpb.com.my", "email_verified": true, "phone_verified": false}	\N	2025-06-23 07:44:11.295977+00	2025-06-23 07:44:11.302469+00	\N	\N			\N		0	\N		\N	f	\N	f
00000000-0000-0000-0000-000000000000	fd238175-c03f-4b7a-a819-0837b802ae2c	authenticated	authenticated	davidb@salcra.gov.my	$2a$10$fW653k9..fwNtZF8ZoTxYOfbxBWPPwiDVh688tsJweMs5tA013syu	2025-06-23 07:41:53.928682+00	\N		\N		\N			\N	2025-06-23 07:55:39.190584+00	{"provider": "email", "providers": ["email"]}	{"sub": "fd238175-c03f-4b7a-a819-0837b802ae2c", "email": "davidb@salcra.gov.my", "email_verified": true, "phone_verified": false}	\N	2025-06-23 07:41:53.925326+00	2025-06-23 07:55:39.191659+00	\N	\N			\N		0	\N		\N	f	\N	f
00000000-0000-0000-0000-000000000000	f7280a96-7703-4d4d-b2a8-9d2acc15a160	authenticated	authenticated	alicesa.ramba@keresa.com.my	$2a$10$eq4Hm3JcqcqFtNZQP.SkA.z9OHfxvSXma7P1MsjNMoWMW3WkpBJf2	2025-06-23 07:42:41.759788+00	\N		\N		\N			\N	2025-06-23 07:42:41.780547+00	{"provider": "email", "providers": ["email"]}	{"sub": "f7280a96-7703-4d4d-b2a8-9d2acc15a160", "email": "alicesa.ramba@keresa.com.my", "email_verified": true, "phone_verified": false}	\N	2025-06-23 07:42:41.756974+00	2025-06-23 07:42:41.781549+00	\N	\N			\N		0	\N		\N	f	\N	f
00000000-0000-0000-0000-000000000000	878637b4-5c02-462a-80e3-edd2cb4dd365	authenticated	authenticated	pairinsonjengok.86@gmail.com	$2a$10$852aWm5dYiS5IVcDDzjowOGNCJAmS7zi/VnKE3AE741UBhlehDn2O	2025-06-23 07:42:35.154006+00	\N		\N		\N			\N	2025-06-23 07:44:40.290871+00	{"provider": "email", "providers": ["email"]}	{"sub": "878637b4-5c02-462a-80e3-edd2cb4dd365", "email": "pairinsonjengok.86@gmail.com", "email_verified": true, "phone_verified": false}	\N	2025-06-23 07:42:35.151038+00	2025-06-23 07:44:40.292107+00	\N	\N			\N		0	\N		\N	f	\N	f
00000000-0000-0000-0000-000000000000	bc9650f6-a750-4deb-98f6-636b76c60b62	authenticated	authenticated	eliana.robert@tpb.com.my	$2a$10$qJqaRsI0tSTcltNnWZnvAedFvmquYVsfVT3XrGwc70/W3ZsBINdTq	2025-06-23 07:43:10.624855+00	\N		\N		\N			\N	2025-06-23 07:43:10.627078+00	{"provider": "email", "providers": ["email"]}	{"sub": "bc9650f6-a750-4deb-98f6-636b76c60b62", "email": "eliana.robert@tpb.com.my", "email_verified": true, "phone_verified": false}	\N	2025-06-23 07:43:10.622014+00	2025-06-23 07:43:10.628195+00	\N	\N			\N		0	\N		\N	f	\N	f
00000000-0000-0000-0000-000000000000	9e2f17ea-26c5-414b-835c-f9b42705c024	authenticated	authenticated	mohdhafizmohamadrafiq@gmail.com	$2a$10$2/1DH8Bl3bSE89I4ZiEeJ.sq97zWXU6heqxJoDpDohu//FfJ4P0Te	2025-06-23 07:42:52.933349+00	\N		\N		\N			\N	2025-06-23 07:47:36.220971+00	{"provider": "email", "providers": ["email"]}	{"sub": "9e2f17ea-26c5-414b-835c-f9b42705c024", "email": "mohdhafizmohamadrafiq@gmail.com", "email_verified": true, "phone_verified": false}	\N	2025-06-23 07:42:52.930373+00	2025-06-23 07:47:36.222406+00	\N	\N			\N		0	\N		\N	f	\N	f
00000000-0000-0000-0000-000000000000	2186e85a-0204-40d2-ac5a-1ae7600edfa3	authenticated	authenticated	risnid@salcra.gov.my	$2a$10$nXfH3xNhhGQzdo7emjpsXOuoJykNh5p61elrAu6c9hExRcfexZO2G	2025-06-23 07:42:35.313218+00	\N		\N		\N			\N	2025-06-23 07:56:17.967596+00	{"provider": "email", "providers": ["email"]}	{"sub": "2186e85a-0204-40d2-ac5a-1ae7600edfa3", "email": "risnid@salcra.gov.my", "email_verified": true, "phone_verified": false}	\N	2025-06-23 07:42:35.309857+00	2025-06-23 07:56:17.968908+00	\N	\N			\N		0	\N		\N	f	\N	f
00000000-0000-0000-0000-000000000000	7df7ea94-16ba-4fd6-85bc-4fd0155fe284	authenticated	authenticated	soon.masranti@gmail.com	$2a$10$7kHhRkg9E4k2ezsQ/8rFAur4Q0mnQoTEpRHgTHnRKYSwUZRHVLBQC	2025-06-23 07:43:02.124876+00	\N		\N		\N			\N	2025-06-23 07:52:06.715833+00	{"provider": "email", "providers": ["email"]}	{"sub": "7df7ea94-16ba-4fd6-85bc-4fd0155fe284", "email": "soon.masranti@gmail.com", "email_verified": true, "phone_verified": false}	\N	2025-06-23 07:43:02.120954+00	2025-06-24 02:31:07.917099+00	\N	\N			\N		0	\N		\N	f	\N	f
00000000-0000-0000-0000-000000000000	ba467302-a9dd-49f1-bb39-442fdab37dcd	authenticated	authenticated	margetha.achong@my.wilmar-intl.com	$2a$10$5z.xRGaU5VmGhXpnIEGqDO0RgXQgrSTxUEhzJvyV0TR0huDxcYV9q	2025-06-23 07:42:01.099368+00	\N		\N		\N			\N	2025-06-23 07:44:15.55287+00	{"provider": "email", "providers": ["email"]}	{"sub": "ba467302-a9dd-49f1-bb39-442fdab37dcd", "email": "margetha.achong@my.wilmar-intl.com", "email_verified": true, "phone_verified": false}	\N	2025-06-23 07:42:01.096161+00	2025-06-23 07:44:15.553975+00	\N	\N			\N		0	\N		\N	f	\N	f
00000000-0000-0000-0000-000000000000	e4f7c6ca-5cfe-411a-a814-45a13ee76fe4	authenticated	authenticated	kru@thplantations.com	$2a$10$VXFmw1EVNLPJY4axMk083eUu.VoxeQsnMJ4gI.I3jn6LrvhI9o.LW	2025-06-23 07:42:27.468576+00	\N		\N		\N			\N	2025-06-23 07:44:23.618255+00	{"provider": "email", "providers": ["email"]}	{"sub": "e4f7c6ca-5cfe-411a-a814-45a13ee76fe4", "email": "kru@thplantations.com", "email_verified": true, "phone_verified": false}	\N	2025-06-23 07:42:27.465507+00	2025-06-23 07:44:23.61941+00	\N	\N			\N		0	\N		\N	f	\N	f
00000000-0000-0000-0000-000000000000	a4051467-1969-4a0f-8657-d8f3f0ba6359	authenticated	authenticated	dienstainkemiti@gmail.com	$2a$10$.VXTghDu28bz43EHZk56GuO1NIOGesPNiWG8CJYNwmc2AP2qK1jQi	2025-06-23 07:43:52.635906+00	\N		\N		\N			\N	2025-06-23 07:57:16.06504+00	{"provider": "email", "providers": ["email"]}	{"sub": "a4051467-1969-4a0f-8657-d8f3f0ba6359", "email": "dienstainkemiti@gmail.com", "email_verified": true, "phone_verified": false}	\N	2025-06-23 07:43:52.632559+00	2025-06-23 07:57:16.066131+00	\N	\N			\N		0	\N		\N	f	\N	f
00000000-0000-0000-0000-000000000000	6dc3e17b-1af0-4a4b-abaf-a9830465a207	authenticated	authenticated	pelicitym@salcra.gov.my	$2a$10$YW8HtCbOMnVQfaH6K/RXcuG2rNaiveetOdoy9fc4hWVwkB8d6wcjy	2025-06-23 07:45:55.125452+00	\N		\N		\N			\N	2025-06-23 07:53:24.210647+00	{"provider": "email", "providers": ["email"]}	{"sub": "6dc3e17b-1af0-4a4b-abaf-a9830465a207", "email": "pelicitym@salcra.gov.my", "email_verified": true, "phone_verified": false}	\N	2025-06-23 07:45:55.122513+00	2025-06-23 07:53:24.211674+00	\N	\N			\N		0	\N		\N	f	\N	f
00000000-0000-0000-0000-000000000000	ac59ee7e-0939-4e05-bf57-be9508f40d82	authenticated	authenticated	rsblundupom@rsb.com.my	$2a$10$u96axXI3tOhFWxoyyjoBV.Vc2fWqkModBSHtpSZNsYmrPtiPtujlO	2025-06-23 07:44:36.498285+00	\N		\N		\N			\N	2025-06-23 07:52:49.60464+00	{"provider": "email", "providers": ["email"]}	{"sub": "ac59ee7e-0939-4e05-bf57-be9508f40d82", "email": "rsblundupom@rsb.com.my", "email_verified": true, "phone_verified": false}	\N	2025-06-23 07:44:36.495065+00	2025-06-23 07:52:49.605726+00	\N	\N			\N		0	\N		\N	f	\N	f
00000000-0000-0000-0000-000000000000	7f05337a-1f10-411a-8c90-ab632faaf8c2	authenticated	authenticated	manisoil.mill.admin@taann.com.my	$2a$10$tQpL52.7FU/oaadWzuyyZOPaMXFh7jvhqfpVYi8YkpJ1pntgu0cEa	2025-06-23 07:46:22.354536+00	\N		\N		\N			\N	2025-06-23 07:55:28.5769+00	{"provider": "email", "providers": ["email"]}	{"sub": "7f05337a-1f10-411a-8c90-ab632faaf8c2", "email": "manisoil.mill.admin@taann.com.my", "email_verified": true, "phone_verified": false}	\N	2025-06-23 07:46:22.351288+00	2025-06-23 07:55:28.578044+00	\N	\N			\N		0	\N		\N	f	\N	f
00000000-0000-0000-0000-000000000000	7d693d50-00d4-4a9b-9bc0-35afebbb30d9	authenticated	authenticated	richardting@spbgroup.com.my	$2a$10$Z7DDpfQmWmJ1KIdRfC02IePhMYBTuIoVmMu.FC4a4TVJJMN2h7mgm	2025-06-23 07:46:08.1683+00	\N		\N		\N			\N	2025-06-23 08:04:20.273633+00	{"provider": "email", "providers": ["email"]}	{"sub": "7d693d50-00d4-4a9b-9bc0-35afebbb30d9", "email": "richardting@spbgroup.com.my", "email_verified": true, "phone_verified": false}	\N	2025-06-23 07:46:08.165026+00	2025-06-23 08:04:20.274839+00	\N	\N			\N		0	\N		\N	f	\N	f
00000000-0000-0000-0000-000000000000	ee74b89d-137d-470c-8a00-90fb5a372727	authenticated	authenticated	wifredk@salcra.gov.my	$2a$10$YIpwz6tyA9Ny1GlEWtCw6.z05qM2e3RZ7CrdccFKqjj0XvLI5.5Sa	2025-06-23 07:45:13.47176+00	\N		\N		\N			\N	2025-06-23 07:58:31.486018+00	{"provider": "email", "providers": ["email"]}	{"sub": "ee74b89d-137d-470c-8a00-90fb5a372727", "email": "wifredk@salcra.gov.my", "email_verified": true, "phone_verified": false}	\N	2025-06-23 07:45:13.468868+00	2025-06-23 07:58:31.487104+00	\N	\N			\N		0	\N		\N	f	\N	f
00000000-0000-0000-0000-000000000000	9e6b451a-3a18-4f0c-97f3-fcccefe12a55	authenticated	authenticated	norlidakeri1@gmail.com	$2a$10$AcuqLpwjDPJUj9QvHFHhgue71IEnAC/Jdjz4OeCItu2LqeUkZDZvK	2025-06-23 07:45:35.862778+00	\N		\N		\N			\N	2025-06-23 07:46:58.140306+00	{"provider": "email", "providers": ["email"]}	{"sub": "9e6b451a-3a18-4f0c-97f3-fcccefe12a55", "email": "norlidakeri1@gmail.com", "email_verified": true, "phone_verified": false}	\N	2025-06-23 07:45:35.859059+00	2025-06-23 07:46:58.141668+00	\N	\N			\N		0	\N		\N	f	\N	f
00000000-0000-0000-0000-000000000000	016ca48e-66c5-476c-9716-c6397ed60e69	authenticated	authenticated	raphaelmodany@gmail.com	$2a$10$1JhOlLeqoViRkYRNvnQG4e0nCjeZzGZthUw8WfQD3zN8ltDp5CAJ.	2025-06-23 07:44:52.0358+00	\N		\N		\N			\N	2025-06-23 07:53:16.099077+00	{"provider": "email", "providers": ["email"]}	{"sub": "016ca48e-66c5-476c-9716-c6397ed60e69", "email": "raphaelmodany@gmail.com", "email_verified": true, "phone_verified": false}	\N	2025-06-23 07:44:52.032745+00	2025-06-23 07:53:16.100161+00	\N	\N			\N		0	\N		\N	f	\N	f
00000000-0000-0000-0000-000000000000	1698b43a-831d-455f-bb6f-22c3097c005f	authenticated	authenticated	ndhiera82@gmail.com	$2a$10$H9lqucW1BuLg2ZfOUJe8Ruvwu7p1gJzK84cQ/7FabqVJZh3hkRUsa	2025-06-23 07:45:27.887179+00	\N		\N		\N			\N	2025-06-23 07:50:49.589729+00	{"provider": "email", "providers": ["email"]}	{"sub": "1698b43a-831d-455f-bb6f-22c3097c005f", "email": "ndhiera82@gmail.com", "email_verified": true, "phone_verified": false}	\N	2025-06-23 07:45:27.883909+00	2025-06-23 07:50:49.590989+00	\N	\N			\N		0	\N		\N	f	\N	f
00000000-0000-0000-0000-000000000000	47676bae-55c6-48f5-8b6a-dc0a3af02ec4	authenticated	authenticated	diana.do@keresa.com.my	$2a$10$QyM1nKXIeSCtwd9TZbgHweRbF0UXdqkP6x34Ux0vOkV3a347sbxC6	2025-06-23 07:45:26.431567+00	\N		\N		\N			\N	2025-06-23 08:00:50.526197+00	{"provider": "email", "providers": ["email"]}	{"sub": "47676bae-55c6-48f5-8b6a-dc0a3af02ec4", "email": "diana.do@keresa.com.my", "email_verified": true, "phone_verified": false}	\N	2025-06-23 07:45:26.42791+00	2025-06-23 08:00:50.527296+00	\N	\N			\N		0	\N		\N	f	\N	f
00000000-0000-0000-0000-000000000000	4e579a51-bb42-45f1-9b79-b84928a98421	authenticated	authenticated	kaveeraaz@gmail.com	$2a$10$aS0OrGkcQrDYvZJxfV7BXuVwf2SfsVlkuMkR2o8k5UhOF80DC3YLG	2025-06-23 07:46:01.255854+00	\N		\N		\N			\N	2025-06-23 07:53:12.365783+00	{"provider": "email", "providers": ["email"]}	{"sub": "4e579a51-bb42-45f1-9b79-b84928a98421", "email": "kaveeraaz@gmail.com", "email_verified": true, "phone_verified": false}	\N	2025-06-23 07:46:01.251571+00	2025-06-25 12:56:43.790498+00	\N	\N			\N		0	\N		\N	f	\N	f
00000000-0000-0000-0000-000000000000	a829ccb9-78d5-4940-82f6-934352e828cd	authenticated	authenticated	lpom.samling@gmail.com	$2a$10$LqOZmsvXHtFtREPSPIMR0elAfXzy8jim5MaXR6/EUTPzJ7.c8j7De	2025-06-23 07:45:50.212272+00	\N		\N		\N			\N	2025-06-23 07:53:22.947065+00	{"provider": "email", "providers": ["email"]}	{"sub": "a829ccb9-78d5-4940-82f6-934352e828cd", "email": "lpom.samling@gmail.com", "email_verified": true, "phone_verified": false}	\N	2025-06-23 07:45:50.209117+00	2025-06-23 07:53:22.948298+00	\N	\N			\N		0	\N		\N	f	\N	f
00000000-0000-0000-0000-000000000000	08a2cbdf-9a26-4469-9034-ed7b3f5b73e9	authenticated	authenticated	tbs.mill.admin@taann.com.my	$2a$10$rKaqKtjbA4K2QhUOFQsHtOhTDB6pOQNFXCIYQshY1EpMKIbk5NEqK	2025-06-23 07:44:52.38714+00	\N		\N		\N			\N	2025-06-23 07:46:05.225959+00	{"provider": "email", "providers": ["email"]}	{"sub": "08a2cbdf-9a26-4469-9034-ed7b3f5b73e9", "email": "tbs.mill.admin@taann.com.my", "email_verified": true, "phone_verified": false}	\N	2025-06-23 07:44:52.384083+00	2025-06-23 07:46:05.22719+00	\N	\N			\N		0	\N		\N	f	\N	f
00000000-0000-0000-0000-000000000000	3142bce6-7211-4fd1-a09f-1d17e6cf287a	authenticated	authenticated	jubaidahadam123@gmail.com	$2a$10$9pG0H7HeHy7R3oWAihr7jOgwCMzGf8zhIXLjuGZei56X4yZeuW1lq	2025-06-23 07:45:30.95408+00	\N		\N		\N			\N	2025-06-23 07:51:04.745064+00	{"provider": "email", "providers": ["email"]}	{"sub": "3142bce6-7211-4fd1-a09f-1d17e6cf287a", "email": "jubaidahadam123@gmail.com", "email_verified": true, "phone_verified": false}	\N	2025-06-23 07:45:30.951239+00	2025-06-23 07:51:04.746332+00	\N	\N			\N		0	\N		\N	f	\N	f
00000000-0000-0000-0000-000000000000	7b53d13f-0338-44ff-a05d-238f8d25cad4	authenticated	authenticated	genevieve.chinhoweyiin@my.wilmar-intl.com	$2a$10$ZdSgDzshauNJ8SUaI/yTIeXOg0ao3iUXYmKfDUNAsbT1crretSda6	2025-06-23 07:46:31.430438+00	\N		\N		\N			\N	2025-06-23 07:50:11.153049+00	{"provider": "email", "providers": ["email"]}	{"sub": "7b53d13f-0338-44ff-a05d-238f8d25cad4", "email": "genevieve.chinhoweyiin@my.wilmar-intl.com", "email_verified": true, "phone_verified": false}	\N	2025-06-23 07:46:31.427379+00	2025-06-23 07:50:11.154613+00	\N	\N			\N		0	\N		\N	f	\N	f
00000000-0000-0000-0000-000000000000	73bc6611-cc9d-451f-94f4-855016beb48e	authenticated	authenticated	cng_elia@yopmail.com	$2a$10$6d9apyW3ymTud.ARkUR4Vuo02fpjFN9XrAEey4HscEAjvp4jzxbKG	2025-06-27 10:54:00.411812+00	\N		\N		\N			\N	2025-06-27 14:49:16.143125+00	{"provider": "email", "providers": ["email"]}	{"sub": "73bc6611-cc9d-451f-94f4-855016beb48e", "email": "cng_elia@yopmail.com", "email_verified": true, "phone_verified": false}	\N	2025-06-27 10:54:00.408486+00	2025-06-27 14:49:16.144292+00	\N	\N			\N		0	\N		\N	f	\N	f
00000000-0000-0000-0000-000000000000	6d810e53-112a-4eac-a882-25b1e97a42b8	authenticated	authenticated	pptz_hilirperak1@yopmail.com	$2a$10$1HjCophHjVd9u1RYtjO3E.NQ5Ll.b6bxuLv/IDC9AW.uD5uOC2LhK	2025-06-27 04:21:39.273331+00	\N		\N		\N			\N	2025-06-27 07:37:42.822433+00	{"provider": "email", "providers": ["email"]}	{"sub": "6d810e53-112a-4eac-a882-25b1e97a42b8", "email": "pptz_hilirperak1@yopmail.com", "email_verified": true, "phone_verified": false}	\N	2025-06-27 04:21:39.221609+00	2025-06-27 07:37:42.823535+00	\N	\N			\N		0	\N		\N	f	\N	f
00000000-0000-0000-0000-000000000000	9ad14374-7580-4a86-a7e7-7e1450f96333	authenticated	authenticated	bapom01@salcra.gov.my	$2a$10$bZD8dt1YlNBdBiWmfKw3Gux3nyr1wIvRweZzmhuG9dosX8cNN9DEu	2025-06-23 07:48:00.337872+00	\N		\N		\N			\N	2025-06-23 07:48:00.339685+00	{"provider": "email", "providers": ["email"]}	{"sub": "9ad14374-7580-4a86-a7e7-7e1450f96333", "email": "bapom01@salcra.gov.my", "email_verified": true, "phone_verified": false}	\N	2025-06-23 07:48:00.333609+00	2025-06-23 07:48:00.34088+00	\N	\N			\N		0	\N		\N	f	\N	f
00000000-0000-0000-0000-000000000000	1dd6c4fe-a762-41d0-a940-959280c0e92a	authenticated	authenticated	complainant_mspo3@yopmail.com	$2a$10$i/SXK.iEW9Paq5xSyAMM/OrTlgzKAhwQdkTDxgWeN1Cz2u8vvtIDG	2025-06-27 08:23:21.550526+00	\N		\N		\N			\N	2025-06-27 08:23:30.640296+00	{"provider": "email", "providers": ["email"]}	{"sub": "1dd6c4fe-a762-41d0-a940-959280c0e92a", "email": "complainant_mspo3@yopmail.com", "email_verified": true, "phone_verified": false}	\N	2025-06-27 08:23:21.547649+00	2025-06-27 08:23:30.641396+00	\N	\N			\N		0	\N		\N	f	\N	f
00000000-0000-0000-0000-000000000000	6c383e4a-a52d-4661-8a6c-4be47b0ed340	authenticated	authenticated	eyz71@yahoo.com	$2a$10$dbmsiNQ1krSJo7q4y1gX.eu.vXD6E/IfDvLeaT32fWt3t9f.E1Up6	2025-06-23 07:46:53.266621+00	\N		\N		\N			\N	2025-06-23 07:56:55.011076+00	{"provider": "email", "providers": ["email"]}	{"sub": "6c383e4a-a52d-4661-8a6c-4be47b0ed340", "email": "eyz71@yahoo.com", "email_verified": true, "phone_verified": false}	\N	2025-06-23 07:46:53.263625+00	2025-06-23 07:56:55.012808+00	\N	\N			\N		0	\N		\N	f	\N	f
00000000-0000-0000-0000-000000000000	13889f78-4916-4d07-8c07-faf25d913216	authenticated	authenticated	uttmill.office@gmail.com	$2a$10$c9VfXrS1yiTIjBXm1eRkK.TYs3NvL4qqXUXxSDWBdUffZWJ0LPbdG	2025-06-23 07:47:32.539341+00	\N		\N		\N			\N	2025-06-23 07:47:32.541017+00	{"provider": "email", "providers": ["email"]}	{"sub": "13889f78-4916-4d07-8c07-faf25d913216", "email": "uttmill.office@gmail.com", "email_verified": true, "phone_verified": false}	\N	2025-06-23 07:47:32.536004+00	2025-06-23 07:47:32.542105+00	\N	\N			\N		0	\N		\N	f	\N	f
00000000-0000-0000-0000-000000000000	8175ff46-a82f-41f1-9650-87661f8acbb1	authenticated	authenticated	hhelina@gmail.com	$2a$10$tBEhdo/uWI4fVPKTY9B8ouWqQxRfO7MhUgvjg327yMTYidzSoeJBO	2025-06-23 07:47:12.293215+00	\N		\N		\N			\N	2025-06-23 07:47:12.294843+00	{"provider": "email", "providers": ["email"]}	{"sub": "8175ff46-a82f-41f1-9650-87661f8acbb1", "email": "hhelina@gmail.com", "email_verified": true, "phone_verified": false}	\N	2025-06-23 07:47:12.29034+00	2025-06-23 07:47:12.295848+00	\N	\N			\N		0	\N		\N	f	\N	f
00000000-0000-0000-0000-000000000000	60dea06c-f874-48fb-80ce-b71d2e65ba95	authenticated	authenticated	bpomsamling@gmail.com	$2a$10$ltrD8DIBGIfZpYYRF.9R6OeWmeUGGpj4fZ5233173dKV7Riqi2LCi	2025-06-23 07:56:12.659499+00	\N		\N		\N			\N	2025-06-23 07:57:58.740598+00	{"provider": "email", "providers": ["email"]}	{"sub": "60dea06c-f874-48fb-80ce-b71d2e65ba95", "email": "bpomsamling@gmail.com", "email_verified": true, "phone_verified": false}	\N	2025-06-23 07:56:12.656484+00	2025-06-23 08:54:33.203068+00	\N	\N			\N		0	\N		\N	f	\N	f
00000000-0000-0000-0000-000000000000	a6ee5043-034b-496f-acc8-328104c06ed9	authenticated	authenticated	adstef82@gmail.com	$2a$10$PGAgiBC.y5Hjeg6DKDTnN.NQov/SECxfNZYZRo5NN6fXNHHnNh1ea	2025-06-23 07:51:10.639138+00	\N		\N		\N			\N	2025-06-23 07:51:10.640817+00	{"provider": "email", "providers": ["email"]}	{"sub": "a6ee5043-034b-496f-acc8-328104c06ed9", "email": "adstef82@gmail.com", "email_verified": true, "phone_verified": false}	\N	2025-06-23 07:51:10.635724+00	2025-06-23 07:51:10.642286+00	\N	\N			\N		0	\N		\N	f	\N	f
00000000-0000-0000-0000-000000000000	59874f8b-4fdf-41ce-947b-da9240a861ca	authenticated	authenticated	patriciah@salcra.gov.my	$2a$10$.9tOGc4Sd1c4FOex1ZYTA.nizA7nWClmhv6MZbMS.UBTp/WtRH4uG	2025-06-23 07:47:12.31455+00	\N		\N		\N			\N	2025-06-23 07:55:24.747272+00	{"provider": "email", "providers": ["email"]}	{"sub": "59874f8b-4fdf-41ce-947b-da9240a861ca", "email": "patriciah@salcra.gov.my", "email_verified": true, "phone_verified": false}	\N	2025-06-23 07:47:12.311944+00	2025-06-23 07:55:24.748289+00	\N	\N			\N		0	\N		\N	f	\N	f
00000000-0000-0000-0000-000000000000	c31c618f-5148-41bb-802d-025b2b70965a	authenticated	authenticated	yc.lee@klkoleo.com	$2a$10$7g1l3C0PegGzOkJkDrnqa.erWSdTraXTWhYaqVX5JhC0KV3jzY/Ju	2025-06-23 07:48:23.004327+00	\N		\N		\N			\N	2025-06-23 07:48:23.005891+00	{"provider": "email", "providers": ["email"]}	{"sub": "c31c618f-5148-41bb-802d-025b2b70965a", "email": "yc.lee@klkoleo.com", "email_verified": true, "phone_verified": false}	\N	2025-06-23 07:48:23.001147+00	2025-06-23 07:48:23.006993+00	\N	\N			\N		0	\N		\N	f	\N	f
00000000-0000-0000-0000-000000000000	545c44d3-4d8a-4511-8fc5-4aaf6e8de7b9	authenticated	authenticated	complainant_mspo1@yopmail.com	$2a$10$5zpHyEhVpT4qz5qFNJIAz.C/yl3jUgcq/UgSqfPWy.e9DVLbIjTmC	2025-06-27 08:03:58.310145+00	\N		\N		\N			\N	2025-06-27 08:04:55.17396+00	{"provider": "email", "providers": ["email"]}	{"sub": "545c44d3-4d8a-4511-8fc5-4aaf6e8de7b9", "email": "complainant_mspo1@yopmail.com", "email_verified": true, "phone_verified": false}	\N	2025-06-27 08:03:58.307121+00	2025-06-27 08:04:55.175118+00	\N	\N			\N		0	\N		\N	f	\N	f
00000000-0000-0000-0000-000000000000	f1b6d4f2-174f-4b2a-8c6c-d4531b128bfc	authenticated	authenticated	complainant_mspo2@yopmail.com	$2a$10$EeLxJtek8Y3eesJP7f89EOQ.JQZ9ltUuPsUepbfy1Bqn.Wo04Ufeq	2025-06-27 08:18:52.559255+00	\N		\N		\N			\N	2025-06-27 08:18:52.561375+00	{"provider": "email", "providers": ["email"]}	{"sub": "f1b6d4f2-174f-4b2a-8c6c-d4531b128bfc", "email": "complainant_mspo2@yopmail.com", "email_verified": true, "phone_verified": false}	\N	2025-06-27 08:18:52.555342+00	2025-06-27 08:18:52.562506+00	\N	\N			\N		0	\N		\N	f	\N	f
00000000-0000-0000-0000-000000000000	fcc7d82b-864c-43db-9975-ff689875c391	authenticated	authenticated	adindos@yopmail.com	$2a$10$iJJvEYbC3/MktEQW2OFDpOAULrd/vaVTesskngCMw7PXQf9YcB50e	2025-06-29 06:57:01.838379+00	\N		\N		\N			\N	2025-06-29 06:57:20.604578+00	{"provider": "email", "providers": ["email"]}	{"sub": "fcc7d82b-864c-43db-9975-ff689875c391", "email": "adindos@yopmail.com", "email_verified": true, "phone_verified": false}	\N	2025-06-29 06:57:01.824185+00	2025-06-29 12:45:27.849832+00	\N	\N			\N		0	\N		\N	f	\N	f
\.


--
-- Data for Name: change_password_request; Type: TABLE DATA; Schema: public; Owner: -
--

COPY public.change_password_request (change_password_request_id, uuid, new_password, user_id, used, trigger_from, expired_at, created_at) FROM stdin;
1	46c236bb-f78b-4caf-b7f3-8ccb55fe4c11	\N	0955eea6-fdc3-48b6-beca-f30e05cfe912	t	forgot_password	2025-06-19 02:55:47.266	2025-06-18 02:55:47.513095
\.


--
-- Data for Name: complaint_actions; Type: TABLE DATA; Schema: public; Owner: -
--

COPY public.complaint_actions (action_id, created_at, complaint_id, action_by, action, remarks, confidential, documents, pending_evidence, prev_complaint_id, email) FROM stdin;
1	2020-01-01 00:00:00+00	62	0	0	\N	f	\N	f	11	users.email
2	2020-01-01 00:00:00+00	64	0	0	\N	f	\N	f	12	users.email
3	2020-01-03 23:51:21+00	32	1	0	\N	f	\N	f	1	nasiha@mpocc.org.my
4	2020-01-06 00:38:03+00	32	1	1	\N	f	\N	f	1	nasiha@mpocc.org.my
5	2020-01-01 00:00:00+00	65	0	0	\N	f	\N	f	13	users.email
6	2020-01-04 10:34:15+00	65	820	1	\N	f	\N	f	13	firdaus@mpocc.org.my
7	2020-01-04 10:42:25+00	65	820	2	\N	f	\N	f	13	firdaus@mpocc.org.my
8	2020-01-04 11:02:09+00	65	820	3	\N	f	\N	f	13	firdaus@mpocc.org.my
9	2020-01-04 11:09:56+00	65	820	4	\N	f	\N	f	13	firdaus@mpocc.org.my
10	2020-01-04 11:23:58+00	35	820	0	\N	f	\N	f	2	firdaus@mpocc.org.my
11	2020-01-04 11:24:50+00	37	820	0	\N	f	\N	f	3	firdaus@mpocc.org.my
12	2020-01-04 11:31:57+00	47	1	0	\N	f	\N	f	5	nasiha@mpocc.org.my
13	2020-01-04 11:32:13+00	61	1	3	\N	f	\N	f	10	nasiha@mpocc.org.my
14	2020-01-04 11:59:03+00	61	1	3	\N	f	\N	f	10	nasiha@mpocc.org.my
15	2020-01-04 11:59:55+00	61	1	3	\N	f	\N	f	10	nasiha@mpocc.org.my
16	2020-01-04 12:03:18+00	32	1	3	\N	f	\N	f	1	nasiha@mpocc.org.my
17	2020-01-04 12:04:54+00	32	1	3	\N	f	\N	f	1	nasiha@mpocc.org.my
18	2020-01-04 12:07:30+00	32	1	3	\N	f	\N	f	1	nasiha@mpocc.org.my
19	2020-01-04 13:04:03+00	32	1	3	\N	f	\N	f	1	nasiha@mpocc.org.my
20	2020-01-04 13:05:24+00	32	1	3	\N	f	\N	f	1	nasiha@mpocc.org.my
21	2020-01-04 13:06:25+00	32	1	3	\N	f	\N	f	1	nasiha@mpocc.org.my
22	2020-01-04 13:07:44+00	32	1	3	\N	f	\N	f	1	nasiha@mpocc.org.my
23	2020-01-04 13:10:27+00	32	1	3	\N	f	\N	f	1	nasiha@mpocc.org.my
24	2020-01-04 13:32:57+00	32	1	4	\N	f	\N	f	1	nasiha@mpocc.org.my
25	2020-01-04 13:45:04+00	32	1	4	\N	f	\N	f	1	nasiha@mpocc.org.my
26	2020-01-04 13:54:36+00	32	1	4	\N	f	\N	f	1	nasiha@mpocc.org.my
27	2020-01-04 14:05:11+00	32	1	4	\N	f	\N	f	1	nasiha@mpocc.org.my
28	2020-01-01 00:00:00+00	66	0	0	\N	f	\N	f	14	users.email
29	2020-01-04 18:16:12+00	66	820	2	\N	f	\N	f	14	firdaus@mpocc.org.my
30	2020-01-04 18:22:40+00	66	820	2	\N	f	\N	f	14	firdaus@mpocc.org.my
31	2020-01-04 18:25:40+00	66	820	3	\N	f	\N	f	14	firdaus@mpocc.org.my
32	2020-01-04 18:35:55+00	66	820	4	\N	f	\N	f	14	firdaus@mpocc.org.my
33	2020-01-01 00:00:00+00	67	0	0	\N	f	\N	f	15	users.email
34	2020-01-06 13:07:51+00	67	820	2	\N	f	\N	f	15	firdaus@mpocc.org.my
35	2020-01-06 13:09:21+00	67	820	3	\N	f	\N	f	15	firdaus@mpocc.org.my
36	2020-01-01 00:00:00+00	68	0	0	\N	f	\N	f	16	users.email
37	2020-01-07 11:41:29+00	68	1	3	\N	f	\N	f	16	nasiha@mpocc.org.my
38	2020-01-07 11:42:52+00	68	1	4	\N	f	\N	f	16	nasiha@mpocc.org.my
39	2020-01-11 15:32:07+00	69	0	0	\N	f	\N	f	17	users.email
40	2020-01-11 15:37:22+00	70	0	0	\N	f	\N	f	18	users.email
41	2020-01-11 15:38:02+00	71	0	0	\N	f	\N	f	19	users.email
42	2020-01-11 15:39:22+00	72	0	0	\N	f	\N	f	20	users.email
43	2020-01-11 15:42:05+00	73	0	0	\N	f	\N	f	21	users.email
44	2020-01-11 15:49:50+00	74	0	0	\N	f	\N	f	22	users.email
45	2020-01-12 02:51:15+00	74	820	1	\N	f	\N	f	22	firdaus@mpocc.org.my
46	2020-01-12 02:51:37+00	74	820	2	\N	f	\N	f	22	firdaus@mpocc.org.my
47	2020-01-12 02:52:32+00	74	820	3	\N	f	\N	f	22	firdaus@mpocc.org.my
48	2020-01-12 02:53:32+00	74	1	4	\N	f	\N	f	22	nasiha@mpocc.org.my
49	2020-01-12 02:54:20+00	74	0	5	\N	f	\N	f	22	users.email
50	2020-01-14 15:50:55+00	75	0	0	\N	f	\N	f	23	users.email
51	2020-01-14 15:53:20+00	75	820	2	\N	f	\N	f	23	firdaus@mpocc.org.my
52	2020-01-14 15:54:04+00	75	820	3	\N	f	\N	f	23	firdaus@mpocc.org.my
53	2020-01-20 16:18:04+00	73	820	2	\N	f	\N	f	21	firdaus@mpocc.org.my
54	2020-01-24 11:09:55+00	76	0	0	\N	f	\N	f	24	users.email
55	2020-01-24 16:04:22+00	77	0	0	\N	f	\N	f	25	users.email
56	2020-01-24 16:07:11+00	77	820	2	\N	f	\N	f	25	firdaus@mpocc.org.my
57	2020-01-24 16:11:42+00	77	820	2	\N	f	\N	f	25	firdaus@mpocc.org.my
58	2020-01-24 16:12:11+00	77	820	3	\N	f	\N	f	25	firdaus@mpocc.org.my
59	2020-01-24 16:17:12+00	77	820	4	\N	f	\N	f	25	firdaus@mpocc.org.my
60	2020-01-24 16:17:25+00	77	820	7	\N	f	\N	f	25	firdaus@mpocc.org.my
61	2020-01-24 16:23:01+00	77	0	5	\N	f	\N	f	25	users.email
62	2020-01-29 02:37:26+00	78	0	0	\N	f	\N	f	26	users.email
63	2020-02-01 03:21:37+00	79	0	0	\N	f	\N	f	27	users.email
64	2020-02-09 13:41:40+00	80	0	0	\N	f	\N	f	28	users.email
65	2020-02-22 22:57:35+00	81	0	0	\N	f	\N	f	29	users.email
66	2020-02-29 03:25:03+00	82	0	0	\N	f	\N	f	30	users.email
67	2020-03-05 03:49:55+00	83	0	0	\N	f	\N	f	31	users.email
68	2020-03-12 17:01:26+00	32	0	0	\N	f	\N	f	32	users.email
69	2020-03-20 09:24:56+00	32	820	0	\N	f	\N	f	32	firdaus@mpocc.org.my
70	2020-03-20 13:06:12+00	32	820	1	\N	f	\N	f	32	firdaus@mpocc.org.my
71	2020-03-20 14:17:20+00	85	0	0	\N	f	\N	f	33	users.email
72	2020-03-20 14:19:49+00	86	0	0	\N	f	\N	f	34	users.email
73	2020-03-20 14:21:10+00	86	820	2	\N	f	\N	f	34	firdaus@mpocc.org.my
74	2020-03-20 14:22:25+00	86	820	3	\N	f	\N	f	34	firdaus@mpocc.org.my
75	2020-03-20 14:26:24+00	86	820	3	\N	f	\N	f	34	firdaus@mpocc.org.my
76	2020-03-20 14:29:15+00	86	820	4	\N	f	\N	f	34	firdaus@mpocc.org.my
77	2020-03-20 14:29:31+00	86	0	5	\N	f	\N	f	34	users.email
78	2020-03-20 14:58:00+00	35	0	0	\N	f	\N	f	35	users.email
79	2020-03-20 15:17:04+00	32	820	3	\N	f	\N	f	32	firdaus@mpocc.org.my
80	2020-03-20 15:33:02+00	88	0	0	\N	f	\N	f	36	users.email
81	2020-03-20 15:40:20+00	88	820	2	\N	f	\N	f	36	firdaus@mpocc.org.my
82	2020-03-20 15:41:15+00	88	820	3	\N	f	\N	f	36	firdaus@mpocc.org.my
83	2020-03-20 15:45:32+00	88	820	4	\N	f	\N	f	36	firdaus@mpocc.org.my
84	2020-03-20 15:46:32+00	88	0	5	\N	f	\N	f	36	users.email
85	2020-03-21 09:18:30+00	37	0	0	\N	f	\N	f	37	users.email
86	2020-03-22 18:19:57+00	90	0	0	\N	f	\N	f	38	users.email
87	2020-03-23 09:55:59+00	37	820	1	\N	f	\N	f	37	firdaus@mpocc.org.my
88	2020-03-23 09:56:16+00	37	820	0	\N	f	\N	f	37	firdaus@mpocc.org.my
89	2020-03-23 10:19:00+00	37	820	1	\N	f	\N	f	37	firdaus@mpocc.org.my
90	2020-03-23 10:19:51+00	37	820	3	\N	f	\N	f	37	firdaus@mpocc.org.my
91	2020-03-26 09:58:14+00	35	820	1	\N	f	\N	f	35	firdaus@mpocc.org.my
92	2020-03-26 09:59:44+00	35	820	3	\N	f	\N	f	35	firdaus@mpocc.org.my
93	2020-03-30 15:51:45+00	91	0	0	\N	f	\N	f	39	users.email
94	2020-03-31 08:07:05+00	92	0	0	\N	f	\N	f	40	users.email
95	2020-04-07 01:15:28+00	93	0	0	\N	f	\N	f	41	users.email
96	2020-04-07 12:05:24+00	94	0	0	\N	f	\N	f	42	users.email
97	2020-04-07 16:39:07+00	43	0	0	\N	f	\N	f	43	users.email
98	2020-04-08 11:32:08+00	98	0	0	\N	f	\N	f	44	users.email
99	2020-04-08 12:03:15+00	99	0	0	\N	f	\N	f	45	users.email
100	2020-04-08 16:01:33+00	43	820	0	\N	f	\N	f	43	firdaus@mpocc.org.my
101	2020-04-08 16:02:20+00	43	820	1	\N	f	\N	f	43	firdaus@mpocc.org.my
102	2020-04-13 20:33:59+00	100	0	0	\N	f	\N	f	46	users.email
103	2020-04-14 10:28:42+00	47	0	0	\N	f	\N	f	47	users.email
104	2020-04-16 08:34:31+00	37	3112	4	\N	f	\N	f	37	anuar@mpocc.org.my
105	2020-04-16 09:42:41+00	94	3112	4	\N	f	\N	f	42	anuar@mpocc.org.my
106	2020-04-17 13:37:19+00	47	820	0	\N	f	\N	f	47	firdaus@mpocc.org.my
107	2020-04-17 14:10:38+00	48	0	0	\N	f	\N	f	48	users.email
108	2020-04-17 14:12:01+00	48	820	0	\N	f	\N	f	48	firdaus@mpocc.org.my
109	2020-04-17 14:20:09+00	49	0	0	\N	f	\N	f	49	users.email
110	2020-04-17 17:16:47+00	43	3113	3	\N	f	\N	f	43	mhafezh@mpocc.org.my
111	2020-04-19 14:39:03+00	37	820	4	\N	f	\N	f	37	firdaus@mpocc.org.my
112	2020-04-19 14:43:38+00	32	820	3	\N	f	\N	f	32	firdaus@mpocc.org.my
113	2020-04-19 14:45:39+00	98	820	4	\N	f	\N	f	44	firdaus@mpocc.org.my
114	2020-04-19 14:45:56+00	99	820	4	\N	f	\N	f	45	firdaus@mpocc.org.my
115	2020-04-19 18:15:47+00	104	0	0	\N	f	\N	f	50	users.email
116	2020-04-20 09:59:59+00	98	0	5	\N	f	\N	f	44	users.email
117	2020-04-21 14:49:02+00	105	0	0	\N	f	\N	f	51	users.email
118	2020-04-22 11:29:35+00	49	820	0	\N	f	\N	f	49	firdaus@mpocc.org.my
119	2020-04-22 11:35:00+00	98	820	1	\N	f	\N	f	44	firdaus@mpocc.org.my
120	2020-04-22 11:35:40+00	98	820	2	\N	f	\N	f	44	firdaus@mpocc.org.my
121	2020-04-22 11:37:02+00	98	820	4	\N	f	\N	f	44	firdaus@mpocc.org.my
122	2020-04-22 11:37:36+00	98	820	5	\N	f	\N	f	44	firdaus@mpocc.org.my
123	2020-04-22 14:13:55+00	98	820	6	\N	f	\N	f	44	firdaus@mpocc.org.my
124	2020-04-22 14:14:33+00	98	820	7	\N	f	\N	f	44	firdaus@mpocc.org.my
125	2020-04-25 10:41:18+00	106	0	0	\N	f	\N	f	52	users.email
126	2020-04-27 12:36:15+00	107	0	0	\N	f	\N	f	53	users.email
127	2020-04-27 12:39:19+00	108	0	0	\N	f	\N	f	54	users.email
128	2020-04-27 13:14:09+00	55	0	0	\N	f	\N	f	55	users.email
129	2020-04-27 13:41:34+00	55	3112	0	\N	f	\N	f	55	anuar@mpocc.org.my
130	2020-04-30 15:30:43+00	56	0	0	\N	f	\N	f	56	users.email
131	2020-05-01 03:25:49+00	117	0	0	\N	f	\N	f	57	users.email
132	2020-05-02 18:41:21+00	118	0	0	\N	f	\N	f	58	users.email
133	2020-05-02 18:42:14+00	118	820	4	\N	f	\N	f	58	firdaus@mpocc.org.my
134	2020-05-02 18:45:21+00	118	820	3	\N	f	\N	f	58	firdaus@mpocc.org.my
135	2020-05-04 12:35:44+00	122	0	0	\N	f	\N	f	59	users.email
136	2020-05-04 12:40:52+00	122	820	0	\N	f	\N	f	59	firdaus@mpocc.org.my
137	2020-05-04 12:46:29+00	122	820	1	\N	f	\N	f	59	firdaus@mpocc.org.my
138	2020-05-04 12:46:57+00	122	820	2	\N	f	\N	f	59	firdaus@mpocc.org.my
139	2020-05-04 12:47:51+00	122	820	2	\N	f	\N	f	59	firdaus@mpocc.org.my
140	2020-05-04 12:50:07+00	123	0	0	\N	f	\N	f	60	users.email
141	2020-05-04 12:51:28+00	123	820	1	\N	f	\N	f	60	firdaus@mpocc.org.my
142	2020-05-05 09:41:19+00	43	3113	4	\N	f	\N	f	43	mhafezh@mpocc.org.my
143	2020-05-06 10:34:08+00	55	3112	4	\N	f	\N	f	55	anuar@mpocc.org.my
144	2020-05-06 10:38:00+00	55	3112	4	\N	f	\N	f	55	anuar@mpocc.org.my
145	2020-05-06 10:53:32+00	35	3113	3	\N	f	\N	f	35	mhafezh@mpocc.org.my
146	2020-05-06 10:55:56+00	43	3113	4	\N	f	\N	f	43	mhafezh@mpocc.org.my
147	2020-05-06 11:11:48+00	32	820	3	\N	f	\N	f	32	firdaus@mpocc.org.my
148	2020-05-06 11:13:02+00	32	820	3	\N	f	\N	f	32	firdaus@mpocc.org.my
149	2020-05-06 11:15:55+00	32	3112	3	\N	f	\N	f	32	anuar@mpocc.org.my
150	2020-05-06 11:46:33+00	56	3113	0	\N	f	\N	f	56	mhafezh@mpocc.org.my
151	2020-05-06 19:58:36+00	35	3113	4	\N	f	\N	f	35	mhafezh@mpocc.org.my
152	2020-05-12 13:21:33+00	32	3112	4	\N	f	\N	f	32	anuar@mpocc.org.my
153	2020-05-12 13:38:19+00	32	0	5	\N	f	\N	f	32	users.email
154	2020-05-15 11:39:22+00	47	820	2	\N	f	\N	f	47	firdaus@mpocc.org.my
155	2020-05-15 11:40:12+00	48	820	2	\N	f	\N	f	48	firdaus@mpocc.org.my
156	2020-05-19 09:15:09+00	49	3112	0	\N	f	\N	f	49	anuar@mpocc.org.my
157	2020-05-20 10:34:51+00	99	820	7	\N	f	\N	f	45	firdaus@mpocc.org.my
158	2020-05-20 10:36:28+00	47	820	3	\N	f	\N	f	47	firdaus@mpocc.org.my
159	2020-05-20 10:37:01+00	48	820	3	\N	f	\N	f	48	firdaus@mpocc.org.my
160	2020-05-20 10:37:22+00	49	820	3	\N	f	\N	f	49	firdaus@mpocc.org.my
161	2020-05-31 22:46:29+00	61	0	0	\N	f	\N	f	61	users.email
162	2020-06-02 14:55:20+00	48	3112	3	\N	f	\N	f	48	anuar@mpocc.org.my
163	2020-06-03 09:15:11+00	56	3113	3	\N	f	\N	f	56	mhafezh@mpocc.org.my
164	2020-06-12 15:29:24+00	62	0	0	\N	f	\N	f	62	users.email
165	2020-06-16 10:26:22+00	62	820	0	\N	f	\N	f	62	firdaus@mpocc.org.my
166	2020-06-16 10:31:35+00	62	820	2	\N	f	\N	f	62	firdaus@mpocc.org.my
167	2020-06-16 11:30:41+00	104	3112	7	\N	f	\N	f	50	anuar@mpocc.org.my
168	2020-06-16 11:30:52+00	106	3112	7	\N	f	\N	f	52	anuar@mpocc.org.my
169	2020-06-16 11:31:05+00	107	3112	7	\N	f	\N	f	53	anuar@mpocc.org.my
170	2020-06-16 11:31:17+00	108	3112	7	\N	f	\N	f	54	anuar@mpocc.org.my
171	2020-06-16 11:31:33+00	117	3112	7	\N	f	\N	f	57	anuar@mpocc.org.my
172	2020-06-16 11:31:45+00	118	3112	7	\N	f	\N	f	58	anuar@mpocc.org.my
173	2020-06-16 11:31:56+00	122	3112	7	\N	f	\N	f	59	anuar@mpocc.org.my
174	2020-06-16 11:32:04+00	123	3112	7	\N	f	\N	f	60	anuar@mpocc.org.my
175	2020-06-16 11:37:14+00	56	3113	3	\N	f	\N	f	56	mhafezh@mpocc.org.my
176	2020-06-16 14:48:34+00	55	3112	4	\N	f	\N	f	55	anuar@mpocc.org.my
177	2020-06-25 09:34:15+00	48	3112	3	\N	f	\N	f	48	anuar@mpocc.org.my
178	2020-07-02 09:03:48+00	56	3112	3	\N	f	\N	f	56	anuar@mpocc.org.my
179	2020-07-14 12:05:09+00	55	3112	4	\N	f	\N	f	55	anuar@mpocc.org.my
180	2020-08-04 13:52:33+00	126	0	0	\N	f	\N	f	63	users.email
181	2020-08-04 13:56:19+00	126	820	2	\N	f	\N	f	63	firdaus@mpocc.org.my
182	2020-08-04 15:58:12+00	126	820	1	\N	f	\N	f	63	firdaus@mpocc.org.my
183	2020-08-04 15:58:28+00	126	820	2	\N	f	\N	f	63	firdaus@mpocc.org.my
184	2020-08-05 14:12:26+00	64	0	0	\N	f	\N	f	64	users.email
185	2020-08-05 14:15:43+00	64	820	1	\N	f	\N	f	64	firdaus@mpocc.org.my
186	2020-08-05 14:16:20+00	64	820	2	\N	f	\N	f	64	firdaus@mpocc.org.my
187	2020-08-05 14:17:41+00	64	820	3	\N	f	\N	f	64	firdaus@mpocc.org.my
188	2020-08-05 14:18:04+00	64	820	4	\N	f	\N	f	64	firdaus@mpocc.org.my
189	2020-08-05 14:19:10+00	64	820	7	\N	f	\N	f	64	firdaus@mpocc.org.my
190	2020-08-13 11:09:24+00	65	0	0	\N	f	\N	f	65	users.email
191	2020-08-14 09:58:23+00	65	3112	1	\N	f	\N	f	65	anuar@mpocc.org.my
192	2020-08-16 00:40:31+00	66	0	0	\N	f	\N	f	66	users.email
193	2020-08-16 00:47:09+00	67	0	0	\N	f	\N	f	67	users.email
194	2020-08-16 00:50:51+00	68	0	0	\N	f	\N	f	68	users.email
195	2020-08-16 00:54:20+00	69	0	0	\N	f	\N	f	69	users.email
196	2020-08-16 00:56:57+00	70	0	0	\N	f	\N	f	70	users.email
197	2020-08-16 01:00:20+00	71	0	0	\N	f	\N	f	71	users.email
198	2020-08-16 01:05:25+00	72	0	0	\N	f	\N	f	72	users.email
199	2020-08-16 01:07:44+00	73	0	0	\N	f	\N	f	73	users.email
200	2020-08-16 01:09:24+00	74	0	0	\N	f	\N	f	74	users.email
201	2020-08-16 01:15:19+00	75	0	0	\N	f	\N	f	75	users.email
202	2020-08-16 01:17:23+00	76	0	0	\N	f	\N	f	76	users.email
203	2020-08-16 01:20:18+00	77	0	0	\N	f	\N	f	77	users.email
204	2020-08-16 01:22:51+00	78	0	0	\N	f	\N	f	78	users.email
205	2020-08-16 01:27:36+00	79	0	0	\N	f	\N	f	79	users.email
206	2020-08-16 01:31:53+00	80	0	0	\N	f	\N	f	80	users.email
207	2020-08-16 01:33:55+00	81	0	0	\N	f	\N	f	81	users.email
208	2020-08-16 01:36:24+00	82	0	0	\N	f	\N	f	82	users.email
209	2020-08-16 01:38:02+00	83	0	0	\N	f	\N	f	83	users.email
210	2020-08-16 01:40:51+00	84	0	0	\N	f	\N	f	84	users.email
211	2020-08-16 01:47:01+00	85	0	0	\N	f	\N	f	85	users.email
212	2020-08-16 01:48:49+00	86	0	0	\N	f	\N	f	86	users.email
213	2020-08-16 01:51:17+00	87	0	0	\N	f	\N	f	87	users.email
214	2020-08-16 01:53:03+00	88	0	0	\N	f	\N	f	88	users.email
215	2020-08-16 01:57:28+00	89	0	0	\N	f	\N	f	89	users.email
216	2020-08-17 10:05:03+00	65	3112	0	\N	f	\N	f	65	anuar@mpocc.org.my
217	2020-08-17 10:05:37+00	66	3112	0	\N	f	\N	f	66	anuar@mpocc.org.my
218	2020-08-17 10:05:52+00	67	3112	1	\N	f	\N	f	67	anuar@mpocc.org.my
219	2020-08-17 10:06:07+00	65	3112	1	\N	f	\N	f	65	anuar@mpocc.org.my
220	2020-08-17 10:06:20+00	66	3112	1	\N	f	\N	f	66	anuar@mpocc.org.my
221	2020-08-17 10:06:33+00	68	3112	1	\N	f	\N	f	68	anuar@mpocc.org.my
222	2020-08-17 10:06:45+00	69	3112	1	\N	f	\N	f	69	anuar@mpocc.org.my
223	2020-08-17 10:07:50+00	70	3112	1	\N	f	\N	f	70	anuar@mpocc.org.my
224	2020-08-17 10:08:07+00	71	3112	1	\N	f	\N	f	71	anuar@mpocc.org.my
225	2020-08-17 10:08:38+00	72	3112	1	\N	f	\N	f	72	anuar@mpocc.org.my
226	2020-08-17 10:10:55+00	73	3112	1	\N	f	\N	f	73	anuar@mpocc.org.my
227	2020-08-17 10:11:24+00	74	3112	0	\N	f	\N	f	74	anuar@mpocc.org.my
228	2020-08-17 10:11:37+00	74	3112	1	\N	f	\N	f	74	anuar@mpocc.org.my
229	2020-08-17 10:11:47+00	75	3112	1	\N	f	\N	f	75	anuar@mpocc.org.my
230	2020-08-17 10:12:02+00	76	3112	1	\N	f	\N	f	76	anuar@mpocc.org.my
231	2020-08-17 10:12:30+00	77	3112	1	\N	f	\N	f	77	anuar@mpocc.org.my
232	2020-08-17 10:12:42+00	78	3112	1	\N	f	\N	f	78	anuar@mpocc.org.my
233	2020-08-17 10:12:52+00	79	3112	1	\N	f	\N	f	79	anuar@mpocc.org.my
234	2020-08-17 10:13:03+00	80	3112	1	\N	f	\N	f	80	anuar@mpocc.org.my
235	2020-08-17 10:13:25+00	81	3112	1	\N	f	\N	f	81	anuar@mpocc.org.my
236	2020-08-17 10:13:49+00	82	3112	1	\N	f	\N	f	82	anuar@mpocc.org.my
237	2020-08-17 10:14:03+00	83	3112	1	\N	f	\N	f	83	anuar@mpocc.org.my
238	2020-08-17 10:14:31+00	84	3112	1	\N	f	\N	f	84	anuar@mpocc.org.my
239	2020-08-17 10:14:46+00	85	3112	1	\N	f	\N	f	85	anuar@mpocc.org.my
240	2020-08-17 10:14:57+00	86	3112	1	\N	f	\N	f	86	anuar@mpocc.org.my
241	2020-08-17 10:15:12+00	87	3112	2	\N	f	\N	f	87	anuar@mpocc.org.my
242	2020-08-17 10:15:26+00	87	3112	1	\N	f	\N	f	87	anuar@mpocc.org.my
243	2020-08-17 10:15:37+00	88	3112	1	\N	f	\N	f	88	anuar@mpocc.org.my
244	2020-08-17 10:15:46+00	89	3112	1	\N	f	\N	f	89	anuar@mpocc.org.my
245	2020-08-22 10:06:17+00	90	0	0	\N	f	\N	f	90	users.email
246	2020-08-26 12:08:43+00	65	3112	2	\N	f	\N	f	65	anuar@mpocc.org.my
247	2020-08-26 12:09:04+00	66	3112	2	\N	f	\N	f	66	anuar@mpocc.org.my
248	2020-08-26 12:09:37+00	67	3112	2	\N	f	\N	f	67	anuar@mpocc.org.my
249	2020-08-26 12:09:52+00	68	3112	2	\N	f	\N	f	68	anuar@mpocc.org.my
250	2020-08-26 12:10:19+00	69	3112	2	\N	f	\N	f	69	anuar@mpocc.org.my
251	2020-08-26 12:10:32+00	70	3112	2	\N	f	\N	f	70	anuar@mpocc.org.my
252	2020-08-26 12:10:46+00	71	3112	2	\N	f	\N	f	71	anuar@mpocc.org.my
253	2020-08-26 12:11:08+00	72	3112	2	\N	f	\N	f	72	anuar@mpocc.org.my
254	2020-08-26 12:11:23+00	73	3112	2	\N	f	\N	f	73	anuar@mpocc.org.my
255	2020-08-26 12:11:40+00	74	3112	2	\N	f	\N	f	74	anuar@mpocc.org.my
256	2020-08-26 12:11:49+00	75	3112	2	\N	f	\N	f	75	anuar@mpocc.org.my
257	2020-08-26 12:12:03+00	76	3112	2	\N	f	\N	f	76	anuar@mpocc.org.my
258	2020-08-26 12:12:27+00	77	3112	2	\N	f	\N	f	77	anuar@mpocc.org.my
259	2020-08-26 12:12:40+00	78	3112	2	\N	f	\N	f	78	anuar@mpocc.org.my
260	2020-08-26 12:12:54+00	79	3112	2	\N	f	\N	f	79	anuar@mpocc.org.my
261	2020-08-26 12:13:05+00	80	3112	2	\N	f	\N	f	80	anuar@mpocc.org.my
262	2020-08-26 12:13:30+00	81	3112	2	\N	f	\N	f	81	anuar@mpocc.org.my
263	2020-08-26 12:14:04+00	82	3112	2	\N	f	\N	f	82	anuar@mpocc.org.my
264	2020-08-26 12:14:14+00	83	3112	2	\N	f	\N	f	83	anuar@mpocc.org.my
265	2020-08-26 12:14:28+00	84	3112	2	\N	f	\N	f	84	anuar@mpocc.org.my
266	2020-08-26 12:14:47+00	85	3112	2	\N	f	\N	f	85	anuar@mpocc.org.my
267	2020-08-26 12:15:04+00	86	3112	2	\N	f	\N	f	86	anuar@mpocc.org.my
268	2020-08-26 12:15:18+00	87	3112	2	\N	f	\N	f	87	anuar@mpocc.org.my
269	2020-08-26 12:15:31+00	88	3112	2	\N	f	\N	f	88	anuar@mpocc.org.my
270	2020-08-26 12:15:41+00	89	3112	2	\N	f	\N	f	89	anuar@mpocc.org.my
271	2020-08-26 12:15:56+00	90	3112	2	\N	f	\N	f	90	anuar@mpocc.org.my
272	2020-08-27 14:26:16+00	91	0	0	\N	f	\N	f	91	users.email
273	2020-08-27 14:33:19+00	91	3112	1	\N	f	\N	f	91	anuar@mpocc.org.my
274	2020-08-27 15:45:00+00	91	3112	2	\N	f	\N	f	91	anuar@mpocc.org.my
275	2020-09-07 15:44:15+00	92	0	0	\N	f	\N	f	92	users.email
276	2020-09-08 10:39:52+00	92	3113	4	\N	f	\N	f	92	mhafezh@mpocc.org.my
277	2020-09-08 11:47:21+00	91	3112	4	\N	f	\N	f	91	anuar@mpocc.org.my
278	2020-09-08 11:48:29+00	65	3112	3	\N	f	\N	f	65	anuar@mpocc.org.my
279	2020-09-08 11:49:50+00	66	3112	3	\N	f	\N	f	66	anuar@mpocc.org.my
280	2020-09-08 11:49:52+00	91	820	4	\N	f	\N	f	91	firdaus@mpocc.org.my
281	2020-09-08 11:51:08+00	67	3112	3	\N	f	\N	f	67	anuar@mpocc.org.my
282	2020-09-08 11:52:04+00	68	3112	3	\N	f	\N	f	68	anuar@mpocc.org.my
283	2020-09-08 11:52:21+00	69	3112	3	\N	f	\N	f	69	anuar@mpocc.org.my
284	2020-09-08 11:52:46+00	70	3112	3	\N	f	\N	f	70	anuar@mpocc.org.my
285	2020-09-08 11:53:25+00	71	3112	3	\N	f	\N	f	71	anuar@mpocc.org.my
286	2020-09-08 11:53:44+00	72	3112	3	\N	f	\N	f	72	anuar@mpocc.org.my
287	2020-09-08 11:54:01+00	73	3112	3	\N	f	\N	f	73	anuar@mpocc.org.my
288	2020-09-08 11:54:28+00	74	3112	3	\N	f	\N	f	74	anuar@mpocc.org.my
289	2020-09-08 11:54:48+00	75	3112	3	\N	f	\N	f	75	anuar@mpocc.org.my
290	2020-09-08 11:55:42+00	76	3112	3	\N	f	\N	f	76	anuar@mpocc.org.my
291	2020-09-08 11:56:54+00	77	3112	3	\N	f	\N	f	77	anuar@mpocc.org.my
292	2020-09-08 11:57:10+00	78	3112	3	\N	f	\N	f	78	anuar@mpocc.org.my
293	2020-09-08 11:58:07+00	79	3112	3	\N	f	\N	f	79	anuar@mpocc.org.my
294	2020-09-08 11:58:23+00	80	3112	3	\N	f	\N	f	80	anuar@mpocc.org.my
295	2020-09-08 11:58:43+00	81	3112	3	\N	f	\N	f	81	anuar@mpocc.org.my
296	2020-09-08 11:59:05+00	82	3112	3	\N	f	\N	f	82	anuar@mpocc.org.my
297	2020-09-08 11:59:20+00	83	3112	3	\N	f	\N	f	83	anuar@mpocc.org.my
298	2020-09-08 11:59:34+00	84	3112	3	\N	f	\N	f	84	anuar@mpocc.org.my
299	2020-09-08 11:59:48+00	85	3112	3	\N	f	\N	f	85	anuar@mpocc.org.my
300	2020-09-08 12:00:03+00	86	3112	3	\N	f	\N	f	86	anuar@mpocc.org.my
301	2020-09-08 12:00:23+00	87	3112	3	\N	f	\N	f	87	anuar@mpocc.org.my
302	2020-09-08 12:00:42+00	88	3112	3	\N	f	\N	f	88	anuar@mpocc.org.my
303	2020-09-08 12:01:04+00	89	3112	3	\N	f	\N	f	89	anuar@mpocc.org.my
304	2020-09-10 14:37:47+00	90	3113	4	\N	f	\N	f	90	mhafezh@mpocc.org.my
305	2020-10-02 13:54:18+00	93	0	0	\N	f	\N	f	93	users.email
306	2020-10-02 14:42:13+00	93	820	1	\N	f	\N	f	93	firdaus@mpocc.org.my
307	2020-10-08 10:08:45+00	93	820	2	\N	f	\N	f	93	firdaus@mpocc.org.my
308	2020-10-20 09:14:13+00	65	820	4	\N	f	\N	f	65	firdaus@mpocc.org.my
309	2020-10-20 09:14:28+00	66	820	4	\N	f	\N	f	66	firdaus@mpocc.org.my
310	2020-10-20 09:15:17+00	67	820	4	\N	f	\N	f	67	firdaus@mpocc.org.my
311	2020-10-20 09:15:58+00	68	820	4	\N	f	\N	f	68	firdaus@mpocc.org.my
312	2020-10-20 09:16:18+00	65	0	5	\N	f	\N	f	65	users.email
313	2020-10-20 09:16:22+00	69	820	4	\N	f	\N	f	69	firdaus@mpocc.org.my
314	2020-10-20 09:16:37+00	70	820	4	\N	f	\N	f	70	firdaus@mpocc.org.my
315	2020-10-20 09:17:01+00	71	820	4	\N	f	\N	f	71	firdaus@mpocc.org.my
316	2020-10-20 09:17:10+00	72	820	4	\N	f	\N	f	72	firdaus@mpocc.org.my
317	2020-10-20 09:18:51+00	73	820	4	\N	f	\N	f	73	firdaus@mpocc.org.my
318	2020-10-20 09:19:06+00	74	820	4	\N	f	\N	f	74	firdaus@mpocc.org.my
319	2020-10-20 09:19:19+00	75	820	4	\N	f	\N	f	75	firdaus@mpocc.org.my
320	2020-10-20 09:19:30+00	76	820	4	\N	f	\N	f	76	firdaus@mpocc.org.my
321	2020-10-20 09:19:44+00	77	820	4	\N	f	\N	f	77	firdaus@mpocc.org.my
322	2020-10-20 09:19:54+00	78	820	4	\N	f	\N	f	78	firdaus@mpocc.org.my
323	2020-10-20 09:20:04+00	79	820	4	\N	f	\N	f	79	firdaus@mpocc.org.my
324	2020-10-20 09:20:13+00	80	820	4	\N	f	\N	f	80	firdaus@mpocc.org.my
325	2020-10-20 09:20:25+00	81	820	4	\N	f	\N	f	81	firdaus@mpocc.org.my
326	2020-10-20 09:21:05+00	61	820	2	\N	f	\N	f	61	firdaus@mpocc.org.my
327	2020-10-20 09:21:18+00	82	820	5	\N	f	\N	f	82	firdaus@mpocc.org.my
328	2020-10-20 09:21:30+00	82	820	4	\N	f	\N	f	82	firdaus@mpocc.org.my
329	2020-10-20 09:21:43+00	83	820	4	\N	f	\N	f	83	firdaus@mpocc.org.my
330	2020-10-20 09:21:54+00	84	820	4	\N	f	\N	f	84	firdaus@mpocc.org.my
331	2020-10-20 09:22:04+00	85	820	4	\N	f	\N	f	85	firdaus@mpocc.org.my
332	2020-10-20 09:22:15+00	86	820	4	\N	f	\N	f	86	firdaus@mpocc.org.my
333	2020-10-20 09:22:27+00	87	820	4	\N	f	\N	f	87	firdaus@mpocc.org.my
334	2020-10-20 09:22:37+00	88	820	4	\N	f	\N	f	88	firdaus@mpocc.org.my
335	2020-10-20 09:22:47+00	89	820	4	\N	f	\N	f	89	firdaus@mpocc.org.my
336	2020-10-20 09:23:01+00	90	820	4	\N	f	\N	f	90	firdaus@mpocc.org.my
337	2020-10-20 12:57:41+00	93	3113	2	\N	f	\N	f	93	mhafezh@mpocc.org.my
338	2020-10-22 10:54:33+00	56	820	7	\N	f	\N	f	56	firdaus@mpocc.org.my
339	2020-10-22 10:59:15+00	65	820	4	\N	f	\N	f	65	firdaus@mpocc.org.my
340	2020-10-22 12:09:34+00	65	820	4	\N	f	\N	f	65	firdaus@mpocc.org.my
341	2020-10-22 12:10:33+00	66	820	4	\N	f	\N	f	66	firdaus@mpocc.org.my
342	2020-10-22 12:10:48+00	67	820	4	\N	f	\N	f	67	firdaus@mpocc.org.my
343	2020-10-22 12:11:04+00	68	820	4	\N	f	\N	f	68	firdaus@mpocc.org.my
344	2020-10-22 12:11:44+00	69	820	4	\N	f	\N	f	69	firdaus@mpocc.org.my
345	2020-10-22 12:12:15+00	70	820	4	\N	f	\N	f	70	firdaus@mpocc.org.my
346	2020-10-23 05:30:35+00	71	820	4	\N	f	\N	f	71	firdaus@mpocc.org.my
347	2020-10-23 05:32:51+00	72	820	4	\N	f	\N	f	72	firdaus@mpocc.org.my
348	2020-10-23 05:34:29+00	73	820	4	\N	f	\N	f	73	firdaus@mpocc.org.my
349	2020-10-23 05:36:45+00	74	820	4	\N	f	\N	f	74	firdaus@mpocc.org.my
350	2020-10-23 05:38:13+00	75	820	4	\N	f	\N	f	75	firdaus@mpocc.org.my
351	2020-10-23 05:39:31+00	76	820	4	\N	f	\N	f	76	firdaus@mpocc.org.my
352	2020-10-23 05:41:00+00	77	820	4	\N	f	\N	f	77	firdaus@mpocc.org.my
353	2020-10-23 05:42:56+00	78	820	4	\N	f	\N	f	78	firdaus@mpocc.org.my
354	2020-10-23 05:44:21+00	79	820	4	\N	f	\N	f	79	firdaus@mpocc.org.my
355	2020-10-23 05:45:17+00	80	820	4	\N	f	\N	f	80	firdaus@mpocc.org.my
356	2020-10-23 05:48:19+00	81	820	4	\N	f	\N	f	81	firdaus@mpocc.org.my
357	2020-10-23 05:49:45+00	82	820	4	\N	f	\N	f	82	firdaus@mpocc.org.my
358	2020-10-23 05:51:08+00	83	820	4	\N	f	\N	f	83	firdaus@mpocc.org.my
359	2020-10-23 05:52:44+00	84	820	4	\N	f	\N	f	84	firdaus@mpocc.org.my
360	2020-10-23 05:54:03+00	85	820	4	\N	f	\N	f	85	firdaus@mpocc.org.my
361	2020-10-23 05:55:06+00	86	820	4	\N	f	\N	f	86	firdaus@mpocc.org.my
362	2020-10-23 05:56:36+00	87	820	4	\N	f	\N	f	87	firdaus@mpocc.org.my
363	2020-10-23 05:57:52+00	88	820	4	\N	f	\N	f	88	firdaus@mpocc.org.my
364	2020-10-23 06:02:21+00	89	820	4	\N	f	\N	f	89	firdaus@mpocc.org.my
365	2020-10-23 06:06:13+00	90	820	4	\N	f	\N	f	90	firdaus@mpocc.org.my
366	2020-10-23 06:14:56+00	92	820	4	\N	f	\N	f	92	firdaus@mpocc.org.my
367	2020-10-23 06:20:02+00	92	0	5	\N	f	\N	f	92	users.email
368	2020-11-13 09:09:27+00	93	3113	2	\N	f	\N	f	93	mhafezh@mpocc.org.my
369	2020-11-23 02:23:17+00	94	0	0	\N	f	\N	f	94	users.email
370	2020-11-23 02:29:54+00	94	820	1	\N	f	\N	f	94	firdaus@mpocc.org.my
371	2020-11-23 02:35:56+00	94	820	2	\N	f	\N	f	94	firdaus@mpocc.org.my
372	2020-11-25 08:38:59+00	35	3113	4	\N	f	\N	f	35	mhafezh@mpocc.org.my
373	2020-11-25 08:39:35+00	35	3113	4	\N	f	\N	f	35	mhafezh@mpocc.org.my
374	2020-11-25 08:40:09+00	35	3113	4	\N	f	\N	f	35	mhafezh@mpocc.org.my
375	2020-11-25 08:40:48+00	35	3113	4	\N	f	\N	f	35	mhafezh@mpocc.org.my
376	2020-11-25 08:41:29+00	35	3113	4	\N	f	\N	f	35	mhafezh@mpocc.org.my
377	2020-11-25 08:42:20+00	35	3113	4	\N	f	\N	f	35	mhafezh@mpocc.org.my
378	2020-11-25 08:43:00+00	35	3113	4	\N	f	\N	f	35	mhafezh@mpocc.org.my
379	2020-11-25 08:45:03+00	35	3113	4	\N	f	\N	f	35	mhafezh@mpocc.org.my
380	2020-11-25 08:54:16+00	35	3113	4	\N	f	\N	f	35	mhafezh@mpocc.org.my
381	2020-11-25 08:54:39+00	35	3113	4	\N	f	\N	f	35	mhafezh@mpocc.org.my
382	2020-11-25 08:55:07+00	35	3113	4	\N	f	\N	f	35	mhafezh@mpocc.org.my
383	2020-11-25 08:55:26+00	35	3113	4	\N	f	\N	f	35	mhafezh@mpocc.org.my
384	2020-11-25 08:55:50+00	35	3113	4	\N	f	\N	f	35	mhafezh@mpocc.org.my
385	2020-11-25 09:05:24+00	35	3113	4	\N	f	\N	f	35	mhafezh@mpocc.org.my
386	2020-11-26 03:12:40+00	90	3113	4	\N	f	\N	f	90	mhafezh@mpocc.org.my
387	2020-11-26 08:22:35+00	90	0	5	\N	f	\N	f	90	users.email
388	2020-12-24 06:33:46+00	158	0	0	\N	f	\N	f	95	users.email
389	2020-12-26 13:10:20+00	96	0	0	\N	f	\N	f	96	users.email
390	2020-12-29 02:54:27+00	96	820	1	\N	f	\N	f	96	firdaus@mpocc.org.my
391	2020-12-31 05:48:48+00	96	820	1	\N	f	\N	f	96	firdaus@mpocc.org.my
392	2021-01-05 06:07:55+00	160	0	0	\N	f	\N	f	97	users.email
393	2021-01-05 06:10:49+00	160	820	0	\N	f	\N	f	97	firdaus@mpocc.org.my
394	2021-01-05 06:12:11+00	160	820	1	\N	f	\N	f	97	firdaus@mpocc.org.my
395	2021-01-05 06:13:43+00	160	820	2	\N	f	\N	f	97	firdaus@mpocc.org.my
396	2021-01-05 06:17:20+00	160	820	3	\N	f	\N	f	97	firdaus@mpocc.org.my
397	2021-01-05 06:19:34+00	160	820	4	\N	f	\N	f	97	firdaus@mpocc.org.my
398	2021-01-05 11:23:35+00	160	820	2	\N	f	\N	f	97	firdaus@mpocc.org.my
399	2021-01-05 11:33:02+00	160	820	4	\N	f	\N	f	97	firdaus@mpocc.org.my
400	2021-01-05 11:56:19+00	160	820	2	\N	f	\N	f	97	firdaus@mpocc.org.my
401	2021-01-06 06:13:08+00	96	820	0	\N	f	\N	f	96	firdaus@mpocc.org.my
402	2021-01-06 06:15:26+00	160	820	1	\N	f	\N	f	97	firdaus@mpocc.org.my
403	2021-01-06 06:17:10+00	160	820	2	\N	f	\N	f	97	firdaus@mpocc.org.my
404	2021-01-06 06:20:24+00	160	820	3	\N	f	\N	f	97	firdaus@mpocc.org.my
405	2021-01-06 06:24:01+00	160	820	4	\N	f	\N	f	97	firdaus@mpocc.org.my
406	2021-01-07 03:28:45+00	64	0	5	\N	f	\N	f	64	users.email
407	2021-02-03 10:27:12+00	98	0	0	\N	f	\N	f	98	users.email
408	2021-02-08 07:45:26+00	99	0	0	\N	f	\N	f	99	users.email
409	2021-02-22 02:15:05+00	100	0	0	\N	f	\N	f	100	users.email
410	2021-02-26 03:40:06+00	99	820	1	\N	f	\N	f	99	firdaus@mpocc.org.my
411	2021-02-26 03:40:28+00	99	820	2	\N	f	\N	f	99	firdaus@mpocc.org.my
412	2021-03-02 01:30:21+00	99	12557	4	\N	f	\N	f	99	yazreen@mpocc.org.my
413	2021-03-05 23:34:41+00	101	0	0	\N	f	\N	f	101	users.email
414	2021-03-08 04:31:16+00	102	0	0	\N	f	\N	f	102	users.email
415	2021-03-09 01:12:57+00	101	820	1	\N	f	\N	f	101	firdaus@mpocc.org.my
416	2021-03-09 01:14:08+00	101	820	2	\N	f	\N	f	101	firdaus@mpocc.org.my
417	2021-03-09 01:46:08+00	100	820	1	\N	f	\N	f	100	firdaus@mpocc.org.my
418	2021-03-09 01:46:34+00	100	820	2	\N	f	\N	f	100	firdaus@mpocc.org.my
419	2021-03-09 07:33:26+00	101	820	4	\N	f	\N	f	101	firdaus@mpocc.org.my
420	2021-03-11 02:22:01+00	94	820	4	\N	f	\N	f	94	firdaus@mpocc.org.my
421	2021-03-11 02:25:51+00	94	820	4	\N	f	\N	f	94	firdaus@mpocc.org.my
422	2021-03-11 02:26:33+00	92	820	4	\N	f	\N	f	92	firdaus@mpocc.org.my
423	2021-03-11 02:36:54+00	102	820	0	\N	f	\N	f	102	firdaus@mpocc.org.my
424	2021-03-11 02:48:02+00	100	820	2	\N	f	\N	f	100	firdaus@mpocc.org.my
425	2021-03-11 02:48:19+00	100	820	2	\N	f	\N	f	100	firdaus@mpocc.org.my
426	2021-03-11 02:49:38+00	100	12557	2	\N	f	\N	f	100	yazreen@mpocc.org.my
427	2021-03-14 04:28:06+00	103	0	0	\N	f	\N	f	103	users.email
428	2021-04-29 03:48:10+00	104	0	0	\N	f	\N	f	104	users.email
429	2021-05-06 07:49:39+00	105	0	0	\N	f	\N	f	105	users.email
430	2021-05-08 00:20:54+00	106	0	0	\N	f	\N	f	106	users.email
431	2021-05-25 04:42:15+00	107	0	0	\N	f	\N	f	107	users.email
432	2021-06-01 04:49:34+00	100	12557	7	\N	f	\N	f	100	yazreen@mpocc.org.my
433	2021-06-01 04:50:07+00	102	12557	7	\N	f	\N	f	102	yazreen@mpocc.org.my
434	2021-06-01 04:51:18+00	104	12557	4	\N	f	\N	f	104	yazreen@mpocc.org.my
435	2021-07-08 03:15:17+00	108	0	0	\N	f	\N	f	108	users.email
436	2021-07-31 23:03:39+00	173	0	0	\N	f	\N	f	110	users.email
437	2021-07-31 23:09:19+00	173	820	1	\N	f	\N	f	110	firdaus@mpocc.org.my
438	2021-07-31 23:17:00+00	173	820	2	\N	f	\N	f	110	firdaus@mpocc.org.my
439	2021-07-31 23:21:03+00	173	820	3	\N	f	\N	f	110	firdaus@mpocc.org.my
440	2021-07-31 23:32:14+00	173	820	4	\N	f	\N	f	110	firdaus@mpocc.org.my
441	2021-08-02 13:38:11+00	173	0	0	\N	f	\N	f	110	users.email
442	2021-08-02 13:43:04+00	173	820	1	\N	f	\N	f	110	firdaus@mpocc.org.my
443	2021-08-02 13:45:44+00	173	820	2	\N	f	\N	f	110	firdaus@mpocc.org.my
444	2021-08-02 13:49:56+00	174	0	0	\N	f	\N	f	111	users.email
445	2021-08-02 13:53:10+00	174	820	1	\N	f	\N	f	111	firdaus@mpocc.org.my
446	2021-08-02 14:43:06+00	175	0	0	\N	f	\N	f	112	users.email
447	2021-08-02 15:17:27+00	176	0	0	\N	f	\N	f	113	users.email
448	2021-08-02 15:19:16+00	176	820	1	\N	f	\N	f	113	firdaus@mpocc.org.my
449	2021-08-02 15:21:15+00	176	820	2	\N	f	\N	f	113	firdaus@mpocc.org.my
450	2021-08-02 15:23:01+00	176	820	3	\N	f	\N	f	113	firdaus@mpocc.org.my
451	2021-08-02 15:30:29+00	176	820	4	\N	f	\N	f	113	firdaus@mpocc.org.my
452	2021-08-02 15:32:49+00	176	0	0	\N	f	\N	f	113	users.email
453	2021-08-02 15:37:51+00	176	820	1	\N	f	\N	f	113	firdaus@mpocc.org.my
454	2021-08-02 15:40:42+00	176	820	2	\N	f	\N	f	113	firdaus@mpocc.org.my
455	2021-08-02 15:42:30+00	176	820	3	\N	f	\N	f	113	firdaus@mpocc.org.my
456	2021-08-02 15:45:04+00	176	820	4	\N	f	\N	f	113	firdaus@mpocc.org.my
457	2021-08-02 15:45:39+00	176	0	7	\N	f	\N	f	113	users.email
458	2021-08-02 15:49:25+00	177	0	0	\N	f	\N	f	114	users.email
459	2021-08-02 15:53:52+00	177	820	1	\N	f	\N	f	114	firdaus@mpocc.org.my
460	2021-08-02 15:56:45+00	177	820	2	\N	f	\N	f	114	firdaus@mpocc.org.my
461	2021-08-02 16:00:18+00	177	820	3	\N	f	\N	f	114	firdaus@mpocc.org.my
462	2021-08-02 16:01:16+00	177	820	4	\N	f	\N	f	114	firdaus@mpocc.org.my
463	2021-08-02 16:03:48+00	177	0	0	\N	f	\N	f	114	users.email
464	2021-08-04 12:47:33+00	115	0	0	\N	f	\N	f	115	users.email
465	2021-08-11 09:58:27+00	115	820	1	\N	f	\N	f	115	firdaus@mpocc.org.my
466	2021-08-11 10:01:05+00	115	820	2	\N	f	\N	f	115	firdaus@mpocc.org.my
467	2021-08-11 12:40:08+00	115	820	4	\N	f	\N	f	115	firdaus@mpocc.org.my
468	2021-08-12 14:50:15+00	116	0	0	\N	f	\N	f	116	users.email
469	2021-08-20 16:32:17+00	117	0	0	\N	f	\N	f	117	users.email
470	2021-08-23 11:33:11+00	118	0	0	\N	f	\N	f	118	users.email
471	2021-08-23 11:34:43+00	118	820	1	\N	f	\N	f	118	firdaus@mpocc.org.my
472	2021-08-23 11:37:18+00	118	820	0	\N	f	\N	f	118	firdaus@mpocc.org.my
473	2021-08-23 11:37:43+00	118	820	4	\N	f	\N	f	118	firdaus@mpocc.org.my
474	2021-08-23 11:38:19+00	118	0	0	\N	f	\N	f	118	users.email
475	2021-08-23 11:41:50+00	118	820	4	\N	f	\N	f	118	firdaus@mpocc.org.my
476	2021-08-23 11:42:06+00	118	0	7	\N	f	\N	f	118	users.email
477	2021-08-26 09:51:35+00	183	0	0	\N	f	\N	f	120	users.email
478	2021-08-26 09:53:10+00	183	820	1	\N	f	\N	f	120	firdaus@mpocc.org.my
479	2021-08-26 09:53:52+00	183	820	2	\N	f	\N	f	120	firdaus@mpocc.org.my
480	2021-08-26 09:55:05+00	183	820	3	\N	f	\N	f	120	firdaus@mpocc.org.my
481	2021-08-26 09:56:23+00	183	820	4	\N	f	\N	f	120	firdaus@mpocc.org.my
482	2021-08-26 09:56:40+00	183	0	0	\N	f	\N	f	120	users.email
483	2021-08-26 09:59:31+00	183	820	1	\N	f	\N	f	120	firdaus@mpocc.org.my
484	2021-08-26 10:00:17+00	183	820	2	\N	f	\N	f	120	firdaus@mpocc.org.my
485	2021-08-26 10:00:59+00	183	820	3	\N	f	\N	f	120	firdaus@mpocc.org.my
486	2021-08-26 10:02:01+00	183	820	4	\N	f	\N	f	120	firdaus@mpocc.org.my
487	2021-08-26 10:02:13+00	183	0	7	\N	f	\N	f	120	users.email
488	2021-08-26 10:02:36+00	183	820	8	\N	f	\N	f	120	firdaus@mpocc.org.my
489	2021-08-26 15:23:49+00	184	0	0	\N	f	\N	f	121	users.email
490	2021-08-26 15:24:33+00	184	820	1	\N	f	\N	f	121	firdaus@mpocc.org.my
491	2021-08-26 15:25:40+00	184	820	2	\N	f	\N	f	121	firdaus@mpocc.org.my
492	2021-08-26 15:26:29+00	184	820	3	\N	f	\N	f	121	firdaus@mpocc.org.my
493	2021-08-26 15:27:46+00	184	820	4	\N	f	\N	f	121	firdaus@mpocc.org.my
494	2021-08-26 15:27:56+00	184	0	0	\N	f	\N	f	121	users.email
495	2021-08-26 15:31:55+00	184	820	1	\N	f	\N	f	121	firdaus@mpocc.org.my
496	2021-08-26 15:32:59+00	184	820	2	\N	f	\N	f	121	firdaus@mpocc.org.my
497	2021-08-26 15:33:44+00	184	820	3	\N	f	\N	f	121	firdaus@mpocc.org.my
498	2021-08-26 15:36:02+00	184	820	4	\N	f	\N	f	121	firdaus@mpocc.org.my
499	2021-08-26 15:36:21+00	184	0	7	\N	f	\N	f	121	users.email
500	2021-08-26 15:36:44+00	184	820	8	\N	f	\N	f	121	firdaus@mpocc.org.my
501	2021-09-01 12:22:37+00	100	12557	8	\N	f	\N	f	100	yazreen@mpocc.org.my
502	2021-09-01 12:24:10+00	102	12557	8	\N	f	\N	f	102	yazreen@mpocc.org.my
503	2021-09-30 13:02:15+00	123	0	0	\N	f	\N	f	123	users.email
504	2021-10-05 10:15:56+00	32	820	4	\N	f	\N	f	32	firdaus@mpocc.org.my
505	2021-10-05 10:20:20+00	62	820	4	\N	f	\N	f	62	firdaus@mpocc.org.my
506	2021-10-05 10:22:04+00	48	820	4	\N	f	\N	f	48	firdaus@mpocc.org.my
507	2021-10-05 10:23:39+00	47	820	4	\N	f	\N	f	47	firdaus@mpocc.org.my
508	2021-10-05 10:24:09+00	49	820	4	\N	f	\N	f	49	firdaus@mpocc.org.my
509	2021-10-05 10:27:04+00	55	820	4	\N	f	\N	f	55	firdaus@mpocc.org.my
510	2021-10-05 15:06:11+00	124	0	0	\N	f	\N	f	124	users.email
511	2021-10-06 15:33:15+00	125	0	0	\N	f	\N	f	125	users.email
512	2021-10-06 18:08:43+00	126	0	0	\N	f	\N	f	126	users.email
513	2021-10-14 12:20:20+00	127	0	0	\N	f	\N	f	127	users.email
514	2021-12-11 18:01:21+00	128	0	0	\N	f	\N	f	128	users.email
515	2021-12-14 05:57:55+00	123	820	2	\N	f	\N	f	123	firdaus@mpocc.org.my
516	2021-12-14 05:58:14+00	123	820	4	\N	f	\N	f	123	firdaus@mpocc.org.my
517	2021-12-14 06:03:08+00	108	820	8	\N	f	\N	f	108	firdaus@mpocc.org.my
518	2021-12-14 06:08:13+00	116	820	4	\N	f	\N	f	116	firdaus@mpocc.org.my
519	2021-12-14 06:08:28+00	117	820	4	\N	f	\N	f	117	firdaus@mpocc.org.my
520	2021-12-14 06:08:52+00	124	820	4	\N	f	\N	f	124	firdaus@mpocc.org.my
521	2021-12-14 06:10:03+00	106	820	4	\N	f	\N	f	106	firdaus@mpocc.org.my
522	2021-12-20 09:03:24+00	106	0	7	\N	f	\N	f	106	users.email
523	2022-01-14 10:03:18+00	93	820	4	\N	f	\N	f	93	firdaus@mpocc.org.my
524	2022-01-14 10:03:58+00	90	820	4	\N	f	\N	f	90	firdaus@mpocc.org.my
525	2022-01-14 10:05:30+00	61	820	8	\N	f	\N	f	61	firdaus@mpocc.org.my
526	2022-01-17 12:38:20+00	93	0	0	\N	f	\N	f	93	users.email
527	2022-01-18 09:17:03+00	93	0	0	\N	f	\N	f	93	users.email
528	2022-01-18 09:18:04+00	93	0	0	\N	f	\N	f	93	users.email
529	2022-01-18 09:27:36+00	93	0	0	\N	f	\N	f	93	users.email
530	2022-01-21 10:12:04+00	130	0	0	\N	f	\N	f	130	users.email
531	2022-01-27 12:25:53+00	130	820	4	\N	f	\N	f	130	firdaus@mpocc.org.my
532	2022-01-27 14:53:40+00	103	820	4	\N	f	\N	f	103	firdaus@mpocc.org.my
533	2022-01-27 14:57:55+00	103	0	0	\N	f	\N	f	103	users.email
534	2022-01-27 15:04:48+00	103	0	0	\N	f	\N	f	103	users.email
535	2022-01-27 15:06:12+00	103	0	0	\N	f	\N	f	103	users.email
536	2022-01-27 15:06:57+00	103	0	0	\N	f	\N	f	103	users.email
537	2022-01-27 15:09:14+00	103	0	0	\N	f	\N	f	103	users.email
538	2022-01-27 15:22:33+00	103	820	4	\N	f	\N	f	103	firdaus@mpocc.org.my
539	2022-01-27 15:24:33+00	103	820	4	\N	f	\N	f	103	firdaus@mpocc.org.my
540	2022-01-27 21:17:51+00	103	0	0	\N	f	\N	f	103	users.email
541	2022-01-27 21:19:05+00	103	0	0	\N	f	\N	f	103	users.email
542	2022-01-27 21:19:17+00	103	0	0	\N	f	\N	f	103	users.email
543	2022-01-28 17:16:51+00	103	0	0	\N	f	\N	f	103	users.email
544	2022-01-28 17:17:51+00	103	0	0	\N	f	\N	f	103	users.email
545	2022-01-28 17:21:02+00	103	0	0	\N	f	\N	f	103	users.email
546	2022-01-28 17:22:20+00	103	0	0	\N	f	\N	f	103	users.email
547	2022-01-28 17:22:55+00	103	0	0	\N	f	\N	f	103	users.email
548	2022-01-28 17:23:32+00	103	0	0	\N	f	\N	f	103	users.email
549	2022-01-28 17:32:39+00	131	0	0	\N	f	\N	f	131	users.email
550	2022-02-08 09:25:43+00	132	0	0	\N	f	\N	f	132	users.email
551	2022-02-10 17:32:45+00	133	0	0	\N	f	\N	f	133	users.email
552	2022-02-16 09:34:54+00	132	820	4	\N	f	\N	f	132	firdaus@mpocc.org.my
553	2022-02-17 09:18:59+00	103	820	4	\N	f	\N	f	103	firdaus@mpocc.org.my
554	2022-02-17 14:37:55+00	96	820	4	\N	f	\N	f	96	firdaus@mpocc.org.my
555	2022-02-19 06:46:32+00	96	0	0	\N	f	\N	f	96	users.email
556	2022-02-19 06:48:32+00	96	0	0	\N	f	\N	f	96	users.email
557	2022-02-26 13:12:15+00	134	0	0	\N	f	\N	f	134	users.email
558	2022-02-28 12:39:01+00	96	0	0	\N	f	\N	f	96	users.email
559	2022-03-05 16:26:25+00	135	0	0	\N	f	\N	f	135	users.email
560	2022-03-10 10:53:46+00	135	820	4	\N	f	\N	f	135	firdaus@mpocc.org.my
561	2022-03-18 16:23:37+00	136	0	0	\N	f	\N	f	136	users.email
562	2022-03-23 10:47:23+00	130	0	7	\N	f	\N	f	130	users.email
563	2022-03-23 12:09:25+00	132	0	7	\N	f	\N	f	132	users.email
564	2022-03-31 15:27:22+00	98	820	4	\N	f	\N	f	98	firdaus@mpocc.org.my
565	2022-04-14 09:00:21+00	137	0	0	\N	f	\N	f	137	users.email
566	2022-04-14 09:08:03+00	138	0	0	\N	f	\N	f	138	users.email
567	2022-04-14 13:29:54+00	139	0	0	\N	f	\N	f	139	users.email
568	2022-04-14 13:50:18+00	140	0	0	\N	f	\N	f	140	users.email
569	2022-04-15 08:13:24+00	141	0	0	\N	f	\N	f	141	users.email
570	2022-05-12 09:30:10+00	142	0	0	\N	f	\N	f	142	users.email
571	2022-05-20 14:27:29+00	143	0	0	\N	f	\N	f	143	users.email
572	2022-05-20 18:22:36+00	144	0	0	\N	f	\N	f	144	users.email
573	2022-05-24 14:18:35+00	145	0	0	\N	f	\N	f	145	users.email
574	2022-05-27 10:14:55+00	146	0	0	\N	f	\N	f	146	users.email
575	2022-05-30 12:00:17+00	147	0	0	\N	f	\N	f	147	users.email
576	2022-05-30 12:13:23+00	148	0	0	\N	f	\N	f	148	users.email
577	2022-05-30 21:13:13+00	149	0	0	\N	f	\N	f	149	users.email
578	2022-06-15 15:03:32+00	146	820	4	\N	f	\N	f	146	firdaus@mpocc.org.my
579	2022-06-15 17:09:35+00	146	0	7	\N	f	\N	f	146	users.email
580	2022-06-16 11:14:46+00	93	820	5	\N	f	\N	f	93	firdaus@mpocc.org.my
581	2022-06-16 11:34:31+00	103	820	5	\N	f	\N	f	103	firdaus@mpocc.org.my
582	2022-06-16 12:46:13+00	141	820	8	\N	f	\N	f	141	firdaus@mpocc.org.my
583	2022-06-17 09:54:35+00	134	820	4	\N	f	\N	f	134	firdaus@mpocc.org.my
584	2022-06-27 16:15:56+00	141	820	8	\N	f	\N	f	141	firdaus@mpocc.org.my
585	2022-06-29 10:20:37+00	150	0	0	\N	f	\N	f	150	users.email
586	2022-06-29 10:35:59+00	150	820	1	\N	f	\N	f	150	firdaus@mpocc.org.my
587	2022-06-29 10:36:55+00	150	820	4	\N	f	\N	f	150	firdaus@mpocc.org.my
588	2022-06-29 10:53:15+00	150	820	4	\N	f	\N	f	150	firdaus@mpocc.org.my
589	2022-06-29 10:56:10+00	150	0	7	\N	f	\N	f	150	users.email
590	2022-06-30 12:35:34+00	151	0	0	\N	f	\N	f	151	users.email
591	2022-07-04 11:17:08+00	152	0	0	\N	f	\N	f	152	users.email
592	2022-07-05 10:03:03+00	153	0	0	\N	f	\N	f	153	users.email
593	2022-07-13 16:12:05+00	152	820	4	\N	f	\N	f	152	firdaus@mpocc.org.my
594	2022-07-13 16:12:17+00	151	820	4	\N	f	\N	f	151	firdaus@mpocc.org.my
595	2022-07-13 16:14:49+00	152	0	7	\N	f	\N	f	152	users.email
596	2022-07-18 15:50:35+00	153	820	4	\N	f	\N	f	153	firdaus@mpocc.org.my
597	2022-08-19 09:39:01+00	150	820	8	\N	f	\N	f	150	firdaus@mpocc.org.my
598	2022-08-19 10:07:54+00	154	0	0	\N	f	\N	f	154	users.email
599	2022-10-14 17:06:43+00	155	0	0	\N	f	\N	f	155	users.email
600	2022-10-26 00:37:54+00	156	0	0	\N	f	\N	f	156	users.email
601	2022-11-03 10:38:32+00	157	0	0	\N	f	\N	f	157	users.email
602	2022-11-03 17:16:40+00	158	0	0	\N	f	\N	f	158	users.email
603	2022-11-04 09:58:42+00	158	820	4	\N	f	\N	f	158	firdaus@mpocc.org.my
604	2022-11-04 10:26:13+00	158	0	7	\N	f	\N	f	158	users.email
605	2022-11-14 14:28:06+00	159	0	0	\N	f	\N	f	159	users.email
606	2022-12-09 12:19:16+00	160	0	0	\N	f	\N	f	160	users.email
607	2022-12-13 10:26:03+00	154	820	4	\N	f	\N	f	154	firdaus@mpocc.org.my
608	2023-01-06 09:26:30+00	160	820	8	\N	f	\N	f	160	firdaus@mpocc.org.my
609	2023-01-10 17:14:35+00	161	0	0	\N	f	\N	f	161	users.email
610	2023-01-11 11:06:42+00	162	0	0	\N	f	\N	f	162	users.email
611	2023-02-01 10:14:35+00	163	0	0	\N	f	\N	f	163	users.email
612	2023-02-03 07:23:41+00	164	0	0	\N	f	\N	f	164	users.email
613	2023-02-03 14:24:55+00	165	0	0	\N	f	\N	f	165	users.email
614	2023-02-06 09:41:01+00	166	0	0	\N	f	\N	f	166	users.email
615	2023-02-18 10:21:56+00	167	0	0	\N	f	\N	f	167	users.email
616	2023-02-22 15:29:01+00	162	820	4	\N	f	\N	f	162	firdaus@mpocc.org.my
617	2023-02-25 09:27:58+00	168	0	0	\N	f	\N	f	168	users.email
618	2023-03-18 11:03:25+00	169	0	0	\N	f	\N	f	169	users.email
619	2023-03-24 09:19:07+00	169	820	1	\N	f	\N	f	169	firdaus@mpocc.org.my
620	2023-03-24 09:19:32+00	169	820	4	\N	f	\N	f	169	firdaus@mpocc.org.my
621	2023-04-06 10:11:04+00	137	820	8	\N	f	\N	f	137	firdaus@mpocc.org.my
622	2023-04-07 07:49:08+00	37	820	8	\N	f	\N	f	37	firdaus@mpocc.org.my
623	2023-05-04 10:16:57+00	170	0	0	\N	f	\N	f	170	users.email
624	2023-05-11 14:26:22+00	171	0	0	\N	f	\N	f	171	users.email
625	2023-05-11 14:30:13+00	172	0	0	\N	f	\N	f	172	users.email
626	2023-05-11 15:59:10+00	173	0	0	\N	f	\N	f	173	users.email
627	2023-05-11 16:01:12+00	174	0	0	\N	f	\N	f	174	users.email
628	2023-05-12 07:50:54+00	175	0	0	\N	f	\N	f	175	users.email
629	2023-05-12 17:31:35+00	176	0	0	\N	f	\N	f	176	users.email
630	2023-05-15 10:08:47+00	177	0	0	\N	f	\N	f	177	users.email
631	2023-05-16 11:27:43+00	177	820	4	\N	f	\N	f	177	firdaus@mpocc.org.my
632	2023-05-17 10:16:08+00	177	0	7	\N	f	\N	f	177	users.email
633	2023-05-23 15:11:49+00	178	0	0	\N	f	\N	f	178	users.email
634	2023-05-26 12:29:01+00	179	0	0	\N	f	\N	f	179	users.email
635	2023-06-08 09:40:07+00	179	820	4	\N	f	\N	f	179	firdaus@mpocc.org.my
636	2023-06-21 11:58:16+00	180	0	0	\N	f	\N	f	180	users.email
637	2023-07-05 10:01:12+00	180	820	4	\N	f	\N	f	180	firdaus@mpocc.org.my
638	2023-07-05 12:56:11+00	180	0	7	\N	f	\N	f	180	users.email
639	2023-08-11 18:47:12+00	181	0	0	\N	f	\N	f	181	users.email
640	2023-08-17 10:08:32+00	182	0	0	\N	f	\N	f	182	users.email
641	2023-08-17 10:28:12+00	183	0	0	\N	f	\N	f	183	users.email
642	2023-08-26 10:51:40+00	184	0	0	\N	f	\N	f	184	users.email
643	2023-09-05 16:00:14+00	185	0	0	\N	f	\N	f	185	users.email
644	2023-09-13 17:33:23+00	186	0	0	\N	f	\N	f	186	users.email
645	2023-09-14 13:53:42+00	157	820	7	\N	f	\N	f	157	firdaus@mpocc.org.my
646	2023-10-10 15:27:56+00	186	820	4	\N	f	\N	f	186	firdaus@mpocc.org.my
647	2023-10-16 10:06:23+00	178	820	4	\N	f	\N	f	178	firdaus@mpocc.org.my
648	2023-11-11 11:49:02+00	187	0	0	\N	f	\N	f	187	users.email
649	2023-11-16 08:56:39+00	187	820	4	\N	f	\N	f	187	firdaus@mpocc.org.my
650	2023-11-16 09:22:47+00	187	820	4	\N	f	\N	f	187	firdaus@mpocc.org.my
651	2023-11-19 09:48:57+00	187	0	7	\N	f	\N	f	187	users.email
652	2023-12-12 15:21:42+00	188	0	0	\N	f	\N	f	188	users.email
653	2024-01-19 14:59:36+00	189	0	0	\N	f	\N	f	189	users.email
654	2024-02-05 15:24:09+00	189	820	4	\N	f	\N	f	189	firdaus@mpocc.org.my
655	2024-02-14 08:24:29+00	190	0	0	\N	f	\N	f	190	users.email
656	2024-02-27 16:50:32+00	191	0	0	\N	f	\N	f	191	users.email
657	2024-03-09 13:04:46+00	192	0	0	\N	f	\N	f	192	users.email
658	2024-03-25 15:55:03+00	193	0	0	\N	f	\N	f	193	users.email
659	2024-03-26 09:13:56+00	193	820	4	\N	f	\N	f	193	firdaus@mpocc.org.my
660	2024-03-26 10:09:19+00	193	0	7	\N	f	\N	f	193	users.email
661	2024-04-01 09:37:25+00	192	820	4	\N	f	\N	f	192	firdaus@mpocc.org.my
662	2024-04-08 11:48:43+00	194	0	0	\N	f	\N	f	194	users.email
663	2024-05-11 08:17:36+00	195	0	0	\N	f	\N	f	195	users.email
664	2024-05-27 21:15:43+00	196	0	0	\N	f	\N	f	196	users.email
665	2024-05-29 00:05:14+00	197	0	0	\N	f	\N	f	197	users.email
666	2024-06-04 11:54:43+00	195	820	4	\N	f	\N	f	195	firdaus@mpocc.org.my
667	2024-06-04 22:12:09+00	198	0	0	\N	f	\N	f	198	users.email
668	2024-06-06 15:52:51+00	199	0	0	\N	f	\N	f	199	users.email
669	2024-06-09 23:55:47+00	200	0	0	\N	f	\N	f	200	users.email
670	2024-06-14 16:15:23+00	201	0	0	\N	f	\N	f	201	users.email
671	2024-07-12 15:52:00+00	202	0	0	\N	f	\N	f	202	users.email
672	2024-07-20 08:03:12+00	203	0	0	\N	f	\N	f	203	users.email
673	2024-08-07 10:40:14+00	194	820	4	\N	f	\N	f	194	firdaus@mpocc.org.my
674	2024-08-28 17:15:48+00	204	0	0	\N	f	\N	f	204	users.email
675	2024-08-30 15:54:53+00	204	820	4	\N	f	\N	f	204	firdaus@mpocc.org.my
676	2024-09-03 09:34:38+00	190	820	4	\N	f	\N	f	190	firdaus@mpocc.org.my
677	2024-09-03 10:45:07+00	190	0	7	\N	f	\N	f	190	users.email
678	2024-09-03 14:54:36+00	196	820	4	\N	f	\N	f	196	firdaus@mpocc.org.my
679	2024-09-03 14:54:54+00	197	820	4	\N	f	\N	f	197	firdaus@mpocc.org.my
680	2024-09-03 14:55:25+00	198	820	4	\N	f	\N	f	198	firdaus@mpocc.org.my
681	2024-09-03 14:56:23+00	200	820	4	\N	f	\N	f	200	firdaus@mpocc.org.my
682	2024-11-19 09:06:03+00	188	820	4	\N	f	\N	f	188	firdaus@mpocc.org.my
683	2024-11-19 09:19:18+00	191	820	4	\N	f	\N	f	191	firdaus@mpocc.org.my
684	2024-11-21 20:23:05+00	205	0	0	\N	f	\N	f	205	users.email
685	2024-12-03 18:25:46+00	206	0	0	\N	f	\N	f	206	users.email
686	2025-01-02 09:37:36+00	205	820	4	\N	f	\N	f	205	firdaus@mpocc.org.my
687	2025-01-02 15:52:27+00	207	0	0	\N	f	\N	f	207	users.email
688	2025-01-02 15:53:38+00	207	820	4	\N	f	\N	f	207	firdaus@mpocc.org.my
689	2025-01-02 18:12:57+00	208	0	0	\N	f	\N	f	208	users.email
690	2025-01-16 18:41:39+00	209	0	0	\N	f	\N	f	209	users.email
691	2025-01-20 11:11:56+00	206	820	4	\N	f	\N	f	206	firdaus@mpocc.org.my
692	2025-02-04 09:13:55+00	210	0	0	\N	f	\N	f	210	users.email
693	2025-02-05 21:55:08+00	211	0	0	\N	f	\N	f	211	users.email
694	2025-02-12 09:35:51+00	212	0	0	\N	f	\N	f	212	users.email
695	2025-02-19 11:36:19+00	208	820	3	\N	f	\N	f	208	firdaus@mpocc.org.my
696	2025-02-19 11:36:39+00	209	820	3	\N	f	\N	f	209	firdaus@mpocc.org.my
697	2025-02-19 11:37:29+00	210	820	3	\N	f	\N	f	210	firdaus@mpocc.org.my
698	2025-02-19 11:41:21+00	211	820	2	\N	f	\N	f	211	firdaus@mpocc.org.my
699	2025-02-19 11:41:43+00	212	820	2	\N	f	\N	f	212	firdaus@mpocc.org.my
700	2025-02-21 09:21:02+00	202	820	3	\N	f	\N	f	202	firdaus@mpocc.org.my
701	2025-05-13 02:31:45.58057+00	1	lee_gee87@yahoo.com	evidence	additional information- Test 1 additional test 1	f	{}	f	\N	\N
702	2025-05-14 03:00:00.138133+00	1	CGU	review		f	{}	f	\N	\N
703	2025-05-14 08:07:07.256607+00	1	CGU	investigation	This email is to informed you that you complaint now in the process of investigation by complaint panel	f	{}	f	\N	\N
704	2025-05-28 03:07:34.784805+00	2	nasilemak@test.com	evidence	test	f	{cdc1c9ce-d2b7-494e-8aeb-003efe634fab}	f	\N	\N
705	2025-05-28 03:07:58.369661+00	2	nasilemak@test.com	evidence	testttt	f	{}	f	\N	\N
706	2025-06-02 05:23:25.275784+00	206	CGU	 	pass to nab	f	{}	f	\N	\N
707	2025-06-02 05:23:55.302476+00	206	CGU	 	pass to sifu	f	{}	f	\N	\N
708	2025-06-02 05:24:30.631984+00	206	CGU	 	pass to sifu	f	{}	f	\N	\N
709	2025-06-02 05:26:13.655178+00	206	CGU	 	pass to syant	f	{}	f	\N	\N
710	2025-06-04 07:29:42.501651+00	3	CGU	 	test	f	{}	f	\N	\N
711	2025-06-04 07:34:51.910417+00	3	CGU	 	test	f	{}	f	\N	\N
712	2025-06-04 07:39:01.485641+00	3	CGU	acknowledged	test	f	{}	f	\N	\N
713	2025-06-04 08:56:46.493462+00	3	Hazwan	resolved		f	{}	f	\N	\N
714	2025-06-06 08:17:16.162239+00	5	CGU	acknowledged	We will proceed to investigate the case. Please attach any supporting document	f	{}	f	\N	\N
715	2025-06-09 09:29:15.882068+00	12	hazwan@mspo.org.my	evidence	mantap	f	{}	f	\N	\N
716	2025-06-09 09:33:06.302392+00	12	CGU	acknowledged	got it	f	{}	f	\N	\N
717	2025-06-09 09:34:10.837179+00	12	CGU	acknowledged		f	{}	f	\N	\N
718	2025-06-09 09:34:37.001433+00	12	CGU	investigation	test	f	{}	f	\N	\N
719	2025-06-09 09:36:28.011183+00	12	CGU	review	test	f	{}	f	\N	\N
720	2025-06-09 09:38:44.713064+00	12	CGU	pending evidence	mana buktinyaaa	f	{}	f	\N	\N
721	2025-06-09 09:45:23.980037+00	12	CGU	review	test	f	{}	f	\N	\N
722	2025-06-10 03:12:14.290757+00	1	CGU	resolved	Resolved	t	{}	f	\N	\N
723	2025-06-10 06:10:53.711538+00	22	CGU	review	Under review- complainant boleh dapat tengok tak comment ni?	f	{}	f	\N	\N
724	2025-06-10 06:12:30.080111+00	1	CGU	review	under review- complainant can view this comment?	f	{}	f	\N	\N
725	2025-06-10 06:13:04.04181+00	1	CGU	acknowledged		f	{}	f	\N	\N
726	2025-06-10 06:45:08.923184+00	1	CGU	investigation	Summary of the complaint:\n1. to focus only to issues A\n2. B \n3. C\n\nPlease used the given template	f	{}	f	\N	\N
727	2025-06-10 06:45:34.57755+00	1	CGU	acknowledged	Summary of the complaint: 1. to focus only to issues A 2. B 3. C Please used the given template	t	{}	f	\N	\N
728	2025-06-10 06:54:14.911159+00	1	CGU	review	On review	t	{}	f	\N	\N
729	2025-06-10 08:10:24.598253+00	22	CGU	acknowledged	test jer	t	{}	f	\N	\N
730	2025-06-10 08:11:10.447388+00	22	CGU	acknowledged	lagiii	t	{}	f	\N	\N
731	2025-06-10 08:39:27.370429+00	22	CGU	acknowledged		f	{}	f	\N	\N
732	2025-06-10 08:41:40.720453+00	22	CGU	acknowledged	test	f	{5202dfcb-0db9-4649-bdac-57f571d10199}	f	\N	\N
733	2025-06-10 13:40:25.671299+00	1	CGU	summary_edit	Accused: Firdaus- Test, changed to Accused: Firdaus Mencuba	f	{}	f	\N	\N
734	2025-06-10 13:43:54.980526+00	1	CGU	summary edit	Accused changed from "Firdaus Mencuba" to "Firdaus Gebu"	t	{}	f	\N	\N
735	2025-06-10 13:44:24.880603+00	1	CGU	summary edit	Summary changed from "resolved as per evidence received" to "resolved as per evidence received yaaa"	t	{}	f	\N	\N
736	2025-06-10 14:27:42.048812+00	22	CGU	acknowledged	test	f	{}	f	\N	\N
737	2025-06-10 14:28:03.884685+00	22	CGU	investigation	huhu	f	{}	f	\N	\N
738	2025-06-10 14:41:34.247202+00	22	CGU	acknowledged	huhuhuhu	f	{}	f	\N	\N
739	2025-06-10 14:59:59.332603+00	22	CGU	acknowledged	test lagii	f	{}	t	\N	\N
740	2025-06-10 15:10:14.827211+00	22	CGU	review	lagiii hehehe	t	{}	t	\N	\N
741	2025-06-10 15:10:46.33406+00	22	CGU	review	ahsdasd	t	{}	t	\N	\N
742	2025-06-10 15:30:11.495122+00	22	CGU	acknowledged	testtttt	f	{}	t	\N	\N
743	2025-06-10 15:30:30.717217+00	22	CGU	investigation	huhuhu	f	{}	f	\N	\N
744	2025-06-10 15:32:04.969003+00	22	CGU	acknowledged	heheheheh	f	{}	t	\N	\N
745	2025-06-10 15:36:57.006806+00	22	CGU	acknowledged	testttt sokmo	f	{}	f	\N	\N
746	2025-06-10 15:37:11.563853+00	22	CGU	investigation	heheheh	f	{}	t	\N	\N
747	2025-06-11 02:33:24.174103+00	36	CGU	acknowledged	here we go!	f	{2c81fbd2-afb8-476c-acb3-b5a3901446f0}	f	\N	\N
748	2025-06-11 03:55:48.772407+00	39	eliaezatul17@gmail.com	evidence	for your kind reference	f	{7a01e521-23bd-449a-a641-5cb7478d9d13}	f	\N	\N
749	2025-06-11 06:44:04.42271+00	38	CGU	acknowledged	mekya menipu. akibat dari salah pergaulan. payed memberi pengaruh buruk terhadap beliau	f	{}	f	\N	\N
750	2025-06-12 03:47:13.215166+00	38	CGU	investigation	Pls check	t	{}	f	\N	\N
751	2025-06-12 03:58:33.281306+00	38	Azim	investigation	Okay je. Hazwan tu memang.	f	{db1597dc-7b51-4180-bcab-1a3afaab2bf6}	f	\N	\N
752	2025-06-14 18:40:29.413278+00	211	CGU	summary edit	Accused changed from "Others" to "Others test"	t	{}	f	\N	\N
753	2025-06-15 00:03:54.046578+00	214	hazwan@mspo.org.my	evidence	test	f	{cbd3a071-61aa-4f7d-a6ea-7f66d4ac690d}	f	\N	\N
754	2025-06-15 08:05:19.013992+00	216	CGU	acknowledged	acknowledged	f	{}	f	\N	\N
755	2025-06-15 08:05:30.268944+00	216	CGU	acknowledged	acknowledged	f	{}	f	\N	\N
756	2025-06-15 08:09:11.643523+00	216	CGU	acknowledged	acknowledged	f	{}	f	\N	\N
757	2025-06-15 08:37:33.328383+00	216	CGU	review	under review	f	{}	f	\N	\N
758	2025-06-15 08:45:09.014945+00	216	CGU	acknowledged	ack 	f	{}	f	\N	\N
759	2025-06-15 08:50:56.789308+00	216	CGU	acknowledged	ack 	f	{}	f	\N	\N
760	2025-06-15 08:53:27.03382+00	216	CGU	acknowledged	ack 2	f	{}	f	\N	\N
761	2025-06-15 08:57:40.870972+00	216	CGU	acknowledged	test	f	{}	f	\N	\N
762	2025-06-15 08:59:56.915035+00	216	CGU	acknowledged	test ack 3	f	{}	f	\N	\N
763	2025-06-15 09:02:20.864412+00	216	CGU	acknowledged	manaa	f	{}	f	\N	\N
764	2025-06-15 09:04:36.718361+00	216	CGU	investigation	gdxg	f	{}	f	\N	\N
765	2025-06-15 09:11:19.349332+00	216	CGU	acknowledged	test	f	{}	f	\N	\N
766	2025-06-15 09:14:01.163436+00	216	CGU	acknowledged	etwea	f	{}	f	\N	\N
767	2025-06-15 09:16:03.352614+00	216	CGU	investigation	testtt	f	{}	f	\N	\N
768	2025-06-15 09:29:41.860459+00	216	CGU	investigation	test	f	{}	f	\N	\N
769	2025-06-15 09:33:00.396615+00	216	CGU	investigation	test	f	{}	f	\N	\N
770	2025-06-15 09:39:30.390568+00	216	CGU	investigation	test	f	{}	f	\N	\N
771	2025-06-15 09:42:33.757619+00	216	CGU	investigation	test	f	{}	f	\N	\N
772	2025-06-15 09:45:17.482461+00	216	CGU	investigation	test	f	{}	f	\N	\N
773	2025-06-15 09:47:16.513653+00	216	CGU	investigation	test	f	{}	f	\N	\N
774	2025-06-15 09:49:44.188831+00	216	CGU	investigation	test	f	{}	f	\N	\N
775	2025-06-16 03:12:55.384246+00	216	hazwan@mspo.org.my	evidence	evidence	f	{bf205071-3f73-49c4-a1d9-f55428fa6466}	f	\N	\N
776	2025-06-20 03:10:03.758479+00	221	CGU	review	Dear Complainant,\n\nWe are in the midst of reviewing your supporting document related to the complaint.\n	f	{}	f	\N	\N
777	2025-06-20 03:23:32.74061+00	221	CGU	review	hi complainant we found that the evidence not sufficient, please attached additional information as detail below:\n1. Map\n2.Agreement	f	{}	t	\N	\N
778	2025-06-20 03:24:49.404477+00	221	firdaus@mspo.org.my	evidence	hi MSPO Please find the additional information as requested	f	{e1d329af-dd1b-4dff-b737-cf269e1636d3}	f	\N	\N
779	2025-06-20 07:06:13.323876+00	221	CGU	resolved	Due to issues has been ratified therefore the case is closed	f	{}	f	\N	\N
780	2025-06-20 07:42:19.109778+00	221	firdaus@mspo.org.my	closed	Satisfied with outcome.	f	\N	f	\N	\N
781	2025-06-20 07:43:17.539508+00	221	CGU	resolved	Due to issues has been ratified therefore the case is closed	f	{}	f	\N	\N
782	2025-06-20 08:17:46.280116+00	221	firdaus@mspo.org.my	closed	Satisfied with outcome.	f	\N	f	\N	\N
783	2025-06-22 14:58:37.803697+00	220	CGU	acknowledged	mantap tuan	f	{}	f	\N	\N
784	2025-06-22 14:59:55.006402+00	220	CGU	acknowledged	test jer	f	{56c8a989-4564-45b4-ad46-5cef880c4bbc}	f	\N	\N
785	2025-06-23 03:24:11.224325+00	211	CGU	summary edit	Accused changed from "Others test" to "123 POM"	f	{}	f	\N	\N
786	2025-06-23 03:24:53.054695+00	211	CGU	summary edit	Summary changed from "My complaint as per attachment" to "Its related to environmental issues"	f	{}	f	\N	\N
787	2025-06-23 03:26:21.716753+00	211	CGU	summary edit	Summary changed from "Its related to environmental issues" to "Its related to environmental issues, as per evidence obtained during special audit, therefore this issues to be change from investigate to resolved"	f	{}	f	\N	\N
788	2025-06-23 07:51:25.848502+00	228	stephen.lee@grandolie.com	evidence	Please refer attachment\n	f	{cd6d9411-bc4d-4f7d-8886-5e0ad8602319}	f	\N	\N
789	2025-06-27 07:30:28.545067+00	288	CGU	acknowledged	we acknowledged this	f	{}	f	\N	\N
793	2025-06-27 11:24:38.116625+00	293	CGU	acknowledged	Okay jap ye	f	{}	f	\N	\N
794	2025-06-27 11:25:52.207138+00	293	CGU	review	Evidence needed. Please attach any supporting document	f	{}	t	\N	\N
795	2025-06-27 11:27:21.158618+00	293	cng_elia@yopmail.com	evidence	Please refere attached document	f	{c3844171-7990-4eae-a357-e87c923d6fdc}	f	\N	\N
796	2025-06-27 11:34:02.999719+00	293	CGU	investigation	Please investigate	f	{1b149802-a691-4d51-9874-c459b516f469}	f	\N	\N
797	2025-06-27 11:36:04.092162+00	293	Azim	investigation	Okay find out dah. Check pls	f	{}	f	\N	\N
798	2025-06-27 11:41:45.951077+00	292	CGU	investigation	ce tgk	f	{}	f	\N	\N
799	2025-06-27 11:42:00.21495+00	292	Azim	acknowledged	dah tgk	f	{}	f	\N	\N
800	2025-06-27 11:44:22.476849+00	292	Azim	investigation	Please close. Ni scam	f	{}	f	\N	\N
801	2025-06-27 12:24:43.909112+00	291	CGU	investigation	tahniah! anda terpilih untuk menyelesaikan masalah ini	f	{}	f	\N	\N
802	2025-06-27 12:26:05.80455+00	291	Azim	investigation	saya tak nak!	f	{}	f	\N	\N
803	2025-06-27 13:51:09.054586+00	293	CGU	investigation	Test semula	f	{}	f	\N	\N
804	2025-06-27 13:52:18.467245+00	293	Azim	investigation	Okay dah check. Memang okay	f	{}	f	\N	\N
805	2025-06-27 13:53:24.802957+00	293	CGU	resolved	Settle ya.	f	{}	f	\N	\N
806	2025-06-27 13:54:38.667529+00	293	cng_elia@yopmail.com	appealed	Saya tak bergurau	f	{}	f	\N	\N
807	2025-06-27 13:55:34.231814+00	293	CGU	resolved	Okay dah ni. Tak perlu appeal	f	{}	f	\N	\N
808	2025-06-27 13:56:35.397294+00	293	cng_elia@yopmail.com	closed	Satisfied with outcome.	f	\N	f	\N	\N
809	2025-06-27 14:18:27.38865+00	286	CGU	acknowledged	noted	f	{}	f	\N	\N
810	2025-06-27 14:19:15.89804+00	286	CGU	resolved	beliau telah berjaya dibrainwash	f	{}	f	\N	\N
811	2025-06-27 14:29:08.814101+00	287	CGU	acknowledged	terima	f	{}	f	\N	\N
812	2025-06-27 14:30:17.581353+00	287	CGU	resolved	Tanpa dakwa dakwi lagi. Benar apa dikata	f	{}	f	\N	\N
813	2025-06-27 14:35:13.905185+00	287	CGU	resolved	Saya sahkan ini semua benarrrr	f	{}	f	\N	\N
814	2025-06-27 14:37:52.074254+00	288	CGU	resolved	Saya Percaya Tuan	f	{}	f	\N	\N
815	2025-06-27 14:42:25.786356+00	294	CGU	resolved	Test	f	{}	f	\N	\N
816	2025-06-27 14:50:29.343031+00	295	CGU	acknowledged	Okay jap check	f	{}	f	\N	\N
817	2025-06-27 14:51:17.578644+00	295	CGU	resolved	we believe in him	f	{}	f	\N	\N
818	2025-06-29 11:05:57.306288+00	296	adindos@yopmail.com	evidence	Please see the evidence	f	{c26c82ac-9e1f-45a2-83b4-f904f37ba6eb}	f	\N	\N
\.


--
-- Data for Name: complaints; Type: TABLE DATA; Schema: public; Owner: -
--

COPY public.complaints (complaint_id, created_at, support_needed, confidentiality, type, description, status, documents, complainant, last_action, other_type, accused, accused_is_org, owned_by, prev_complaint_id, prev_complainant_email) FROM stdin;
296	2025-06-29 11:04:58.004181+00	["Others","Please investigate the management of ABC as they seems to violate labour law"]	t	Non-compliance to MSPO Standards	Please investigate the management of ABC as they seems to violate labour law	submitted	{}	fcc7d82b-864c-43db-9975-ff689875c391	\N	\N	ABU BAKAR	t	\N	\N	\N
32	2020-03-12 17:01:26+00		f	Quality of Audit report	Care Certification International audit report of Jeng Huat Plantations Sdn Bhd (OPMC303257) is misleading.It states and certifies 206.4602 Ha however only gives 1 GPS coordinates where there is 3 separate estates in Mukim Jelai, Mukim Kepis & Mukim Serting Ulu. The CB and CH including technical quality review process also fails to highlight there is only 1 estate map provided in said audit report. Map given is for estate in Mukim Kepis, amounting to only 12 Ha. There is a deficiency in maps amounting to 194 Ha including 2 missing coordinates for estate in Jelai and Serting Ulu. Having only 1 map in the audit report may offer misrepresentation to the reader that the estate in Kepis measures 206.4602 Ha when in fact it doesn't. MSPO and MPOCC needs to buck up on the quality of assessors and reporting as this is not just an isolated incident. Some CBs audit report available on MSPOTrace does not even contain maps (E.g. Transcert, PSV, Prima Cert, Global Gateway)	submitted	\N	\N	\N	\N		f	\N	32	kaixiang.chin@bunge.com
35	2020-03-20 14:58:00+00		f	Pemotongan gaji atas kehilangan motorsikal disebabkan kecurian	\n\nSaya ingin membuat laporan utk sebuah syarikat Tetangga Akrab sdn Bhd.\n\nAlamat\n\nLot 8712, no 6, shoplot 11, green height commercial centre,airport road, 93250 kuching sarawak.\n\n\n\nLaporan ini adalah berkaitan tentang.\n\n1. Pemotongan gaji saya sebanyak RM 3000 selama 3 bulan bermula potongan bulan mei 2019 sehingga julai 2019 atas kehilangan motosikal milik syarikat yang dicuri dihadapan rumah saya. Pemotongan dibuat tanpa notis. Untuk pengetahuan pihak tuan, report polis sudah dibuat berkaitan kehilangan tersebut, dan insurance sebanyak rm 3000 sudah juga diterima oleh pihak syarikat, namun tetap membuat pemotongan atas gaji saya.\n\n\n\n2. Gaji minimum tidak dilaksanakan oleh pihak syarikat.\n\n\n\n3. Notis dikeluarkan oleh pihak syarikat utk bekerja hari cuti umum tanpa meminta persetujuan pekerja.\n\n\n\n4. Gaji pekerja dibayar melebihi 7 hari dari selepas bulan tersebut.. Ini adalah laporan yg dibuat pada 5/9/2019 yg lepas kepada JTK namun tiada sebarang tindakan pun kepada syarikat tersebut.. Bersama ini saya lampirkan utk rujukan pihak tuan.	submitted	\N	\N	\N	\N		f	\N	35	diroz3988@gmail.com
43	2020-04-07 16:39:07+00	Translation and interpretation	f	Complaining Jaya tiasa holding working during lockdowns period 	Dear sir. During lockdowns period and we are Malaysia citizens and we should corporations with government rules and regulations. But I found a company name jaya tiasa holding, they are using soppaa permit and call back all the worker back to work( head office at sibu town- NOT AT ESTATES) and number of worker more than 100 persons. As I know , HR and Financial department should need to work cause of payday and other should stay at home avoid situations become worst ( Convid-19 Virus). But not all the worker belong to these 2 departments. In my knowledge about MSPO. Company should abide CSR and policies of MSPO. So here we hope those company has MSPO certificates no just a paper but we need to abides and helping social at this moment. Thanks	submitted	\N	\N	\N	\N		f	\N	43	anthonywki7777@gmail.com
47	2020-04-14 10:28:42+00		f	KILANG KELAPA SAWIT DI GANTUNG LESEN KERANA MENYEBABKAN PENCEMARAN DI SUNGAI TONGOD SANDAKAN, SABAH	Jabatan Alam Sekitar (JAS) Negeri Sabah telah menerima aduan dari jabtan Air Sabah dan menerusi media sosial tentang pencemaran di sungai Tongod, Sandakan, sabah pada 8 April 2020. Pasukan penyiasat JAS Negeri Sabah telah menjalankan siasatan pada 8 dan 9 April bersama pengerusi Majlis Pengurusan Komuniti Kampung (MPKK) dan kakitangan Jabatan Air Tongod. Siasatan mendapati efluen bertakung di parit ladang yang berhampiri Sungai Malagatan dalam jarak lebih kurang 100 meter hingga 200 meter dari kawasan sungai.JAS Negeri Sabah telah mengambil tindakan tegas menggantung lesen pemilik kilang kelapa sawit daripada beroperasi selama sebulan. JAS Negeri Sabah telah mengarahkan Kilang tersebut supaya melakukan pembersihan serta merta. Pihak Kilang diarahkan mempercepatkan kerja-kerja pencucian kolam pengolahan efluen supaya mematuhi sepenuhnya syarat-syarat lesen yang dikeluarkan oleh JAS di bawah Akta Kualiti Alam Sekeliling 1974 (Akta 127).	submitted	\N	\N	\N	\N		f	\N	47	anuar@mpocc.org.my
48	2020-04-17 14:10:38+00		f	MEDIA REPORTS ON OIL PALM PLANTATIONS URGED TO STOP USING CHEMICALS THAT CAN HARM ELEPHANTS	This is a complaint highlighted in the media.  Therefore, there is no complainant. The weblinks are : (https://www.bernama.com/bm/am/news.php?id=1831862)\n\n(https://www.thestar.com.my/news/nation/2020/04/14/oil-palm-plantations-urged-to-stop-using-chemicals-that-can-harm-elephants)  \n\n( https://www.theborneopost.com/2020/04/15/christina-repeats-call-for-cooperation-of-oil-palm-plantations/ ) .  MPOCC email the CB, Care Certification International, on 16 Apr 2020.	submitted	\N	\N	\N	\N		f	\N	48	sanath@mpocc.org.my
49	2020-04-17 14:20:09+00		f	Tabung Haji Plantations to Develop New Oil Palm Concession, Once Again Breaching Buyers’ NDPE Commitments	This is a complaint highlighted in the web portal (chainreactionresearch.org).  There is no complainant.  The weblink https://chainreactionresearch.com/the-chain-tabung-haji-plantations-to-develop-new-oil-palm-concession-once-again-breaching-buyers-ndpe-commitments/ was published on 9 Apr 2020.  As a follow up, we wrote to Tabung Haji on 10 Apr 2020.	submitted	\N	\N	\N	\N		f	\N	49	sanath@mpocc.org.my
55	2020-04-27 13:14:09+00		f	Land dispute and security clearance	My neighbour Kwantas have been harvesting my crops despite showing evidence that the piece of land in question belongs to us( with demarcation and land survey ). I report to them last month On the 6th of March via WhatsApp to their person in charge of the issue but last week when the restriction was lifted in kinabatangan, they went harvest my crops again so I got frustrated and emotional when I went to their office. So far they didn’t response to my grievance that’s why I get angry at them. Since then they block my way to my plantation and don’t give me security clearance. I’m now standing at their gate trying to solve the problem. I have essential items and goods to deliver to my workers... theres no other entrance to my estate but have to go through their gate. I hope you can assist me to solve this issue and start an investigation on your part. Regards	submitted	\N	\N	\N	\N		f	\N	55	dominique.sor@gmail.com
56	2020-04-30 15:30:43+00	Translation and interpretation	f	Complaint against the Certificate of Quality Avenue Sdn Bhd Oil Palm Plantation	This complaint is about destruction of water catchment area of Tatau District by the Quality Avenue Sdn Bhd,  and also the lost of Native Customary Land of Sungai Sap Community.  The plantation was very much effect the quality of water supply for Tatau community and as well as the junggle within the Tatau Water Catchment Area that was gazzetted on years of 2001.  The oil palm plantation was encroaching into the Native Customary Right(NCR) Land as well as the Tatau Water Catchment Area. 	submitted	\N	\N	\N	\N		f	\N	56	luangbafol@gmail.com
61	2020-05-31 22:46:29+00		f	MENUTUP KES PUKUL PEKERJA OLEH KAKITANGAN LADANG TABUNG TENTERA TERENGGANU	A letter date 24 Mar 2020 from En. Raja Mohamad Faiz Aminnudin bin Raja Badli, (worker) addressed to Bousted Plantations Bhd was copied to MPOCC, received by post on 28 May 2020.  See attached letter. 	submitted	\N	\N	\N	\N		f	\N	61	sanath@mpocc.org.my
62	2020-06-12 15:29:24+00		f	DOE suspends palm oil mill's permit for polluting river	12 June 2020\n\n\n\nTO: BSI Services (M) Sdn Bhd\n\nSuite 29.01, Level 29,\n\nThe Gardens North Tower\n\nMid Valley City Lingkaran Syed Putra\n\n59200 Kuala Lumpur.\n\nTel: 03-9212 9638\n\nFax: 03-9212 9639\n\n\n\nDear Sir/Madam,\n\n\n\nGood day to you.\n\n\n\nI wish to bring your attention to the Bernama news portal  (https://bernama.com/en/general/news.php?id=1849654 ) dated 9 June 2020 that the Environment and Water Ministry through the Department of Environment (DOE) has suspended the operating permit of a palm oil mill for allegedly causing pollution near Kluang, Johor.  \n\n\n\nRelated to the above serious matter, we have been formally informed by DOE Kluang on the details of the Palm Oil Mill is as below:\n\n\n\nPamol Plantation Sdn Bhd\n\nKilang Kelapa Sawit Pamol\n\n8 1/2 Miles, Jalan Mersing\n\n86000 Kluang, Johor.\n\n\n\nFrom our record your CB had issued the MSPO MS2530-4:2013 certificate No: MSPO 700801 on 31 Dec 2018 (attached).\n\n\n\nKindly report to us soonest possible, on the proactive action steps and mitigation measures taken by your organisation, in accordance with your internal procedures and the requirements of Standards Malaysia, with regards to MSPO certification.	submitted	\N	\N	\N	\N		f	\N	62	sanath@mpocc.org.my
75	2020-08-16 01:15:19+00		f	Others	We have obtained our MSPO certification part 3 on 06th November 2019 and we have submitted our claim by hand to MPOCC staff on 18th March 2020 at NIOSH bangi. We have emailed Mr Tan on 20th July 2020 to request for the status of the claim, but Mr Tan inform us that our application still in queue to be process due to large volume of application and the closure of MPOCC office due to MCO. Our management has queried on delay of the claim and we as sustainability officer unable to explain to our management since we dont't know the progress of the claim and it's hard for us to convince our management to continue doing the surveillance audit. So, we would like to suggest if MPOCC can create any system for the companies to monitor on the progress of the claim. We hope that MPOCC can revert on this matter as soon as possible. Thanks.	submitted	\N	e81e22aa-0578-4fb2-8d0b-5665be08b8ee	\N	\N		f	\N	75	janechinshuikwen@gmail.com
76	2020-08-16 01:17:23+00		f	Others	We have obtained our MSPO certification part 3 on 06th November 2019 and we have submitted our claim by hand to MPOCC staff on 18th March 2020 at NIOSH bangi. We have emailed Mr Tan on 20th July 2020 to request for the status of the claim, but Mr Tan inform us that our application still in queue to be process due to large volume of application and the closure of MPOCC office due to MCO. Our management has queried on delay of the claim and we as sustainability officer unable to explain to our management since we dont't know the progress of the claim and it's hard for us to convince our management to continue doing the surveillance audit. So, we would like to suggest if MPOCC can create any system for the companies to monitor on the progress of the claim. We hope that MPOCC can revert on this matter as soon as possible. Thanks.	submitted	\N	bf3f6921-ab2d-4b8b-936f-38da5143c31d	\N	\N		f	\N	76	rusnanit78@gmail.com
77	2020-08-16 01:20:18+00		f	Others	We have obtained our MSPO certification part 3 on 20th December 2019 and we have submitted our claim by hand to MPOCC staff on 18th March 2020 at NIOSH bangi. We have emailed Mr Tan on 20th July 2020 to request for the status of the claim, but Mr Tan inform us that our application still in queue to be process due to large volume of application and the closure of MPOCC office due to MCO. Our management has queried on delay of the claim and we as sustainability officer unable to explain to our management since we dont't know the progress of the claim and it's hard for us to convince our management to continue doing the surveillance audit. So, we would like to suggest if MPOCC can create any system for the companies to monitor on the progress of the claim. We hope that MPOCC can revert on this matter as soon as possible. Thanks.	submitted	\N	3d06ba74-5af0-499d-81fa-6a61febaa57d	\N	\N		f	\N	77	nuramsconsultant@gmail.com
78	2020-08-16 01:22:51+00		f	Others	We have obtained our MSPO certification part 3 on 31st December 2019 and we have submitted our claim by hand to MPOCC staff on 18th March 2020 at NIOSH bangi. We have emailed Mr Tan on 20th July 2020 to request for the status of the claim, but Mr Tan inform us that our application still in queue to be process due to large volume of application and the closure of MPOCC office due to MCO. Our management has queried on delay of the claim and we as sustainability officer unable to explain to our management since we dont't know the progress of the claim and it's hard for us to convince our management to continue doing the surveillance audit. So, we would like to suggest if MPOCC can create any system for the companies to monitor on the progress of the claim. We hope that MPOCC can revert on this matter as soon as possible. Thanks.	submitted	\N	e81e22aa-0578-4fb2-8d0b-5665be08b8ee	\N	\N		f	\N	78	janechinshuikwen@gmail.com
79	2020-08-16 01:27:36+00		f	Others	We have obtained our MSPO certification part 3 on 20th December 2019 and we have submitted our claim by hand to MPOCC staff on 18th March 2020 at NIOSH bangi. We have emailed Mr Tan on 20th July 2020 to request for the status of the claim, but Mr Tan inform us that our application still in queue to be process due to large volume of application and the closure of MPOCC office due to MCO. Our management has queried on delay of the claim and we as sustainability officer unable to explain to our management since we dont't know the progress of the claim and it's hard for us to convince our management to continue doing the surveillance audit. So, we would like to suggest if MPOCC can create any system for the companies to monitor on the progress of the claim. We hope that MPOCC can revert on this matter as soon as possible. Thanks.	submitted	\N	bf3f6921-ab2d-4b8b-936f-38da5143c31d	\N	\N		f	\N	79	rusnanit78@gmail.com
69	2020-08-16 00:54:20+00		f	Others	We have obtained our MSPO certification part 3 on 21st June 2019 and we have submitted our claim by hand to MPOCC staff on 18th March 2020 at NIOSH bangi. We have emailed Mr Tan on 20th July 2020 to request for the status of the claim, but Mr Tan inform us that our application still in queue to be process due to large volume of application and the closure of MPOCC office due to MCO. Our management has queried on delay of the claim and we as sustainability officer unable to explain to our management since we dont't know the progress of the claim and it's hard for us to convince our management to continue doing the surveillance audit. So, we would like to suggest if MPOCC can create any system for the companies to monitor on the progress of the claim. We hope that MPOCC can revert on this matter as soon as possible. Thanks.	submitted	\N	e81e22aa-0578-4fb2-8d0b-5665be08b8ee	\N	\N		f	\N	69	janechinshuikwen@gmail.com
80	2020-08-16 01:31:53+00		f	Others	We have obtained our MSPO certification part 3 on 06th December 2019 and we have submitted our claim by hand to MPOCC staff on 18th March 2020 at NIOSH bangi. We have emailed Mr Tan on 20th July 2020 to request for the status of the claim, but Mr Tan inform us that our application still in queue to be process due to large volume of application and the closure of MPOCC office due to MCO. Our management has queried on delay of the claim and we as sustainability officer unable to explain to our management since we dont't know the progress of the claim and it's hard for us to convince our management to continue doing the surveillance audit. So, we would like to suggest if MPOCC can create any system for the companies to monitor on the progress of the claim. We hope that MPOCC can revert on this matter as soon as possible. Thanks.	submitted	\N	3d06ba74-5af0-499d-81fa-6a61febaa57d	\N	\N		f	\N	80	nuramsconsultant@gmail.com
81	2020-08-16 01:33:55+00		f	Others	We have obtained our MSPO certification part 3 on 06th December 2019 and we have submitted our claim by hand to MPOCC staff on 18th March 2020 at NIOSH bangi. We have emailed Mr Tan on 20th July 2020 to request for the status of the claim, but Mr Tan inform us that our application still in queue to be process due to large volume of application and the closure of MPOCC office due to MCO. Our management has queried on delay of the claim and we as sustainability officer unable to explain to our management since we dont't know the progress of the claim and it's hard for us to convince our management to continue doing the surveillance audit. So, we would like to suggest if MPOCC can create any system for the companies to monitor on the progress of the claim. We hope that MPOCC can revert on this matter as soon as possible. Thanks.	submitted	\N	e81e22aa-0578-4fb2-8d0b-5665be08b8ee	\N	\N		f	\N	81	janechinshuikwen@gmail.com
82	2020-08-16 01:36:24+00		f	Others	We have obtained our MSPO certification part 3 on 03rd February 2020 and we have submitted our claim by hand to MPOCC staff on 18th March 2020 at NIOSH bangi. We have emailed Mr Tan on 20th July 2020 to request for the status of the claim, but Mr Tan inform us that our application still in queue to be process due to large volume of application and the closure of MPOCC office due to MCO. Our management has queried on delay of the claim and we as sustainability officer unable to explain to our management since we dont't know the progress of the claim and it's hard for us to convince our management to continue doing the surveillance audit. So, we would like to suggest if MPOCC can create any system for the companies to monitor on the progress of the claim. We hope that MPOCC can revert on this matter as soon as possible. Thanks.	submitted	\N	bf3f6921-ab2d-4b8b-936f-38da5143c31d	\N	\N		f	\N	82	rusnanit78@gmail.com
83	2020-08-16 01:38:02+00		f	Others	We have obtained our MSPO certification part 3 on 20th December 2019 and we have submitted our claim by hand to MPOCC staff on 18th March 2020 at NIOSH bangi. We have emailed Mr Tan on 20th July 2020 to request for the status of the claim, but Mr Tan inform us that our application still in queue to be process due to large volume of application and the closure of MPOCC office due to MCO. Our management has queried on delay of the claim and we as sustainability officer unable to explain to our management since we dont't know the progress of the claim and it's hard for us to convince our management to continue doing the surveillance audit. So, we would like to suggest if MPOCC can create any system for the companies to monitor on the progress of the claim. We hope that MPOCC can revert on this matter as soon as possible. Thanks.	submitted	\N	3d06ba74-5af0-499d-81fa-6a61febaa57d	\N	\N		f	\N	83	nuramsconsultant@gmail.com
84	2020-08-16 01:40:51+00		f	Others	We have obtained our MSPO certification part 3 on 03rd February 2020 and we have submitted our claim by hand to MPOCC staff on 18th March 2020 at NIOSH bangi. We have emailed Mr Tan on 20th July 2020 to request for the status of the claim, but Mr Tan inform us that our application still in queue to be process due to large volume of application and the closure of MPOCC office due to MCO. Our management has queried on delay of the claim and we as sustainability officer unable to explain to our management since we dont't know the progress of the claim and it's hard for us to convince our management to continue doing the surveillance audit. So, we would like to suggest if MPOCC can create any system for the companies to monitor on the progress of the claim. We hope that MPOCC can revert on this matter as soon as possible. Thanks.	submitted	\N	e81e22aa-0578-4fb2-8d0b-5665be08b8ee	\N	\N		f	\N	84	janechinshuikwen@gmail.com
85	2020-08-16 01:47:01+00		f	Others	We have obtained our MSPO certification part 3 on 11th February 2019 and we have submitted our claim by hand to MPOCC staff on 18th March 2020 at NIOSH bangi. We have emailed Mr Tan on 20th July 2020 to request for the status of the claim, but Mr Tan inform us that our application still in queue to be process due to large volume of application and the closure of MPOCC office due to MCO. Our management has queried on delay of the claim and we as sustainability officer unable to explain to our management since we dont't know the progress of the claim and it’s hard for us to convince our management to continue doing the surveillance audit. So, we would like to suggest if MPOCC can create any system for the companies to monitor on the progress of the claim. We hope that MPOCC can revert on this matter as soon as possible. Thanks.	submitted	\N	bf3f6921-ab2d-4b8b-936f-38da5143c31d	\N	\N		f	\N	85	rusnanit78@gmail.com
103	2021-03-14 04:28:06+00		f	Non-compliance to MSPO Certification Scheme	Dear Sir, I would like to lodge a complaint  against the General Manager of Keresa Plantations Sdn Bhd who have abused me  ie. physical and verbal violence. This incident had caused mental stress and affected my physical health ie.  bleeding gums and jaws. Non-Compliance to 4.4.5. Criterion 5 : Employment conditions - violence at workplace Further details are in the attachments. Thank you.	submitted	\N	0f718b43-671c-4b6f-b906-34ee7b45b4b2	\N	\N		f	\N	103	thilaganarthan@gmail.com
86	2020-08-16 01:48:49+00		f	Others	We have obtained our MSPO certification part 3 on 10th February 2020 and we have submitted our claim by hand to MPOCC staff on 18th March 2020 at NIOSH bangi. We have emailed Mr Tan on 20th July 2020 to request for the status of the claim, but Mr Tan inform us that our application still in queue to be process due to large volume of application and the closure of MPOCC office due to MCO. Our management has queried on delay of the claim and we as sustainability officer unable to explain to our management since we dont't know the progress of the claim and it’s hard for us to convince our management to continue doing the surveillance audit. So, we would like to suggest if MPOCC can create any system for the companies to monitor on the progress of the claim. We hope that MPOCC can revert on this matter as soon as possible. Thanks.	submitted	\N	3d06ba74-5af0-499d-81fa-6a61febaa57d	\N	\N		f	\N	86	nuramsconsultant@gmail.com
127	2021-10-14 12:20:20+00	Translation and interpretation	f	Non-compliance to MSPO Certification Scheme	The secretariat.\n\nMalaysian Sustainable Palm Oil(MSPO)\n\n\n\nPekara: Komplain/laporan rasmi melaui Malaysian Suatainable Palm Oil/MPOC\n\n(Grievance dispute Mechanism )\n\n\n\nPihak yang di lapor:\n\n\n\n1. LCDA HOLDING SDN BHD . Company No.182028 . Alamat Level 4.8 &amp;12 Wisma satok.\n\nJalan Satok.93400 Kuching Sarawak.\n\n2. WINSOME Pelita (PANTU) Sdn Bhd. Company No. 681469-H. Lot 7052,jalan Sekamah,93330\n\nKuching Sarawak.\n\n\n\nPihak yang membuat laporan yang memawakil semoa tuan tanah hak Adat (NCR) dari dan\n\nberalamat Kampung Tekuyong A Sri Aman Sarawak:\n\n1.  (Ex-Tuai Rumah) Masa anak Nangkai\n\n2. Raymond anak John lalong\n\n3. Amat Anak Jilong\n\n4. Adimen basit anak Christhoper.\n\n\n\nSejarah simulasi pencerobohan tanah Adat di kampung Tekuyong. Sri aman\n\nSarawak.\n\nPada tahun 2006 ministrial order Gazette L.N 79/2006 kawasan pantu subdistrict tremasuk wilayah\n\nkampung Tekuyung telah di wartakan oleh kerajaan sarawak melalui LCDA ( juga di sebut Pelita\n\nHolding) untuk penanaman kelapa sawit. Untuk pengatahuan pihak MSPO dan MPOC semenjak\n\ndari awal lagi pihak penduduk kampung Tekuyong A telah membantah dan tidak bersetuju kawasan\n\ntanah Adat di masukkan dalam project tersebut dan di minta kawasan Tekuyong di keluarkan dari\n\nproject tersebut.\n\nNamun pada tahun 2005 pihak kompani pertama yang terlibat ia itu Tertangga Akrab telah\n\nmenceruboh masuk ke kawasan wilayah kami secara tampa izin dan kebenaran pihak tuan Tanah\n\nNCR. Pihak kami telah mengalami kerugian besar dan hilang harta benda tanaman traditional dan\n\nkawasan pekuburan nenek moyang kami telah di ranap tampa perduli rayun pihak setempat. Pihak\n\nyang berkuasa dan bertenaga juga menguna gangster upahan untuk menentang pihak kami yang\n\nmempertahan harta benda. Pihak polis juga di guna untuk menangap pihak kami yang\n\nmempertahan harta benda. Modus operandi dari pihak LCDA telah menguna nama orang orang luar\n\nyang tidak menpunyi hak di kawasan kampung Tekuyong untuk menuntut tanah yang kepunyi\n\npenduduk kampung Tekuyong. Walau pun tututan tindis ini telah di selesai di mahkamah bumputra\n\ntatapi pihak LCDA tidak memperdulikan keputusan dari pihak mahkamah bumipitra.\n\nPada tahun 2005 walau pun amat berat untuk di usaha ,pihak kami telah membinta bantuan pihak\n\npajabat peguam untuk menuntut keadilan. Abapila mahkamah tinggi telah memberi kemenang\n\nkepada pihak kami maka LCDA dan pihak compani terus lagi membuat rayuan dan menambah\n\nkompani yang baru ia itu KIM LONG sdn bhd kepada mahkamah rayuan dan seterusnya kepada\n\nmahkamah perkesatuan. Untuk pengatahuan pihak MSPO dan MPOC pihak kerajaan melalui LCDA\n\nsering akan menguna atau perpindah company yang baru untuk menekan pikah komuniti tanah\n\nAdat. Dan untuk pengatahuan pihak MSPO dan MPOC baru baru ini pihak LCDA telah menguna\n\nWINSOME Pelita Sdn Bhd untuk menceroboh tanah Adat kami di kampong Tekuyong A.\n\nUntuk pengatahuan pihak mspo dan Mpoc tanah adat yang di tuntut oleh pihak LCDA dan\n\nWINSOME Pelita adalah tanah Adat yang di usaha oleh penduduk sendiri dengan penanam kelapa\n\nsawit dan mempunyi pensijilan sah dari pihak MPOB.\n\n\n\nPihak kami merayu dan mengesorkan kepada MSPO dan MPOC supaya pensijilan yang di berikan /anugrah kepada pihak LCDA dan WINSOME pelita di batal kan sampai penyelesai di capai.\n\nUntuk rujukan pihak MSPO dan MPOC pihak LCDA dan WINSOME PELITA anatar lain talah\n\nmelangari principle 3 mspo standard.\n\n1. Telah melanggar tartatertip sustainable operational standard menguna undang undang untuk\n\nmenekan prinsip keadilan( law shall not threaten customary rights)\n\n2.Secara sengaja Tidak mempertikan FPIC( free prior inform consent)\n\n\n\nPihak kami akan membekal dokumen dokumen yang di perlukan semasa perundingan jika ada.\n\nPihak kami boleh di hubungi melalui.\n\n\n\n1. Raymong anak John Lalong tel; 0197138220\n\n2. Masa Anak nangkai Tel. 0164267677.	submitted	\N	3ce70501-e74f-4420-bc0a-3eac51f2dbe4	\N	\N		f	\N	127	sadiahq@gmail.com
128	2021-12-11 18:01:21+00	Translation and interpretation	f	Others	Agreement issue	submitted	\N	d8d76d24-14d4-4e46-92ad-5907d27fe2e0	\N	\N		f	\N	128	hasronnorraimi@yahoo.com
87	2020-08-16 01:51:17+00		f	Others	We have obtained our MSPO certification part 3 on 14th March 2020 and we have submitted our claim by hand to MPOCC staff on 18th March 2020 at NIOSH bangi. We have emailed Mr Tan on 20th July 2020 to request for the status of the claim, but Mr Tan inform us that our application still in queue to be process due to large volume of application and the closure of MPOCC office due to MCO. Our management has queried on delay of the claim and we as sustainability officer unable to explain to our management since we dont't know the progress of the claim and it’s hard for us to convince our management to continue doing the surveillance audit. So, we would like to suggest if MPOCC can create any system for the companies to monitor on the progress of the claim. We hope that MPOCC can revert on this matter as soon as possible. Thanks.	submitted	\N	bf3f6921-ab2d-4b8b-936f-38da5143c31d	\N	\N		f	\N	87	rusnanit78@gmail.com
88	2020-08-16 01:53:03+00		f	Others	We have obtained our MSPO certification part 3 on 28th February 2020 and we have submitted our claim by hand to MPOCC staff on 18th March 2020 at NIOSH bangi. We have emailed Mr Tan on 20th July 2020 to request for the status of the claim, but Mr Tan inform us that our application still in queue to be process due to large volume of application and the closure of MPOCC office due to MCO. Our management has queried on delay of the claim and we as sustainability officer unable to explain to our management since we dont't know the progress of the claim and it’s hard for us to convince our management to continue doing the surveillance audit. So, we would like to suggest if MPOCC can create any system for the companies to monitor on the progress of the claim. We hope that MPOCC can revert on this matter as soon as possible. Thanks.	submitted	\N	3d06ba74-5af0-499d-81fa-6a61febaa57d	\N	\N		f	\N	88	nuramsconsultant@gmail.com
89	2020-08-16 01:57:28+00		f	Others	We have obtained our MSPO certification part 3 on 21st February 2020 and we have submitted our claim by hand to MPOCC staff on 18th March 2020 at NIOSH bangi. We have emailed Mr Tan on 20th July 2020 to request for the status of the claim, but Mr Tan inform us that our application still in queue to be process due to large volume of application and the closure of MPOCC office due to MCO. Our management has queried on delay of the claim and we as sustainability officer unable to explain to our management since we dont't know the progress of the claim and it’s hard for us to convince our management to continue doing the surveillance audit. So, we would like to suggest if MPOCC can create any system for the companies to monitor on the progress of the claim. We hope that MPOCC can revert on this matter as soon as possible. Thanks.	submitted	\N	e81e22aa-0578-4fb2-8d0b-5665be08b8ee	\N	\N		f	\N	89	janechinshuikwen@gmail.com
92	2020-09-07 15:44:15+00		f	Others	The Palm Oil Mill Monthly Declaration can't be tally with mill MSPO inventory records since some of our FFB supplier have been certified with MSPO Part 3, but not available/updated in the MSPO Trace system. We need to declare as non certified FFB supplier to fulfill the FFB Supplier Template provided. The quantity of certified and non certified FFB received are not tally with our records. The 3 estates (Gan Kim Siat, Lion Landscaping Sdn Bhd & PKEINPk Sdn Bhd) at the bottom of FFB Supplier Template attached have been certified with MSPO Part 3 but not available in the MSPO Trace system. Is there any solution to solve this problem. Thank you. 	submitted	\N	13b7d6b3-42a7-40ec-b227-f1b91f791dcc	\N	\N		f	\N	92	amirul@kksl.com.my
129	2022-01-07 14:54:17+00		f	NST Letters : Help palm oil growers regarding US, EU standards January 6, 2022 @ 4:19pm	LETTERS: I refer to the article, Palm oil industry has much to do on human rights compliance (NST, De 21, 2021). In the case of Malaysia, the human rights issues are related to forced labour and decent work.\n\nAs a grower, I used to assume that once my oil palm plantation has been certified to the Malaysian Standard for sustainable palm oil, i.e., MS 2530, my plantation has successfully addressed all the forced labour issues and all other sustainability requirements.\n\nBut, my joy was short-lived when a major buyer from the European Union conducted a sustainability audit on my company's estates and mill. The auditors issued a number of non-compliances, which in their opinion were major ones.\n\nI argued with them that this was not a requirement of the MS 2530, but that made the matter worse. Sad to say, my company lost the business of the major buyer.\n\nLater, I had an excellent opportunity to update my knowledge on palm oil sustainability when I listened to a talk organised by the University of Nottingham Malaysia.\n\nIt was entitled, "Gaps in Audit Standards related to Forced Labour and Decent work in the oil palm and manufacturing industry in Malaysia".\n\nThe Malaysian speaker explained in simple terms what constitutes forced labour and decent work. I admired his "hands-on" experience in sustainability-related issues.\n\nHe was also well-versed in international sustainability standards, which were not addressed in the Malaysian Standard.\n\nThis talk provided an excellent platform to apprehend, grasp and understand what constituted forced labour and decent work when the speaker presented on how a sustainability standard for oil palm plantation and mills should look like.\n\nThe salient points I learnt from the talk were:\n\n1. Sustainability standards focus on workers because they are weak, vulnerable, do not know their rights, and unprotected that the agent or employer can exploit them;\n\n2. Companies must be committed to uphold the human rights of workers, and to treat them with dignity and respect as understood by the international community;\n\n3. Companies must ensure that working conditions in the palm oil supply chain are safe and that business operations are environmentally responsible and conducted ethically; and,\n\n4. Companies need to go beyond legal compliance.\n\nMore interesting was the answer to the poll question posted at the end of the talk. The question was "Is there any auditable standard available to the Malaysian palm oil industry that addresses all Forced Labour and Decent Work-related issues in a simple, clear, unambiguous and concise manner?"\n\nMore than two-thirds of the attendees answered "No". Based on the talk, I checked the draft Malaysian standards for sustainable palm oil available at https://upc.mpc.gov.my/csp/sys/bi/%25cspapp.bi.work.nc.custom.regulation... .\n\nIt is true that the forced labour and decent work and other sustainability requirements are not stated in a detailed format and clear manner. To me, it seems that standards are written to fulfil key performance indicators rather than address sustainability issues facing the palm oil industry.\n\nThe ministries of Plantation Industries and Commodities, International Trade and Industry, Malaysian Palm Oil Board and growers must proactively ensure that the Malaysian Standards address the sustainability requirements in detail.\n\nEspecially those regarding forced labour and decent work, so that the growers can understand and implement these requirements, while making it easier to conduct audits.\n\nIf there is any non-compliance, growers can take opportunity to address the weakness they have rather than obtaining Malaysian Sustainable Palm Oil certification and believing that the plantation meets sustainability requirements, while palm oil products are barred at US ports and the sustainability of our palm oil is been questioned by EU, non-governmental agencies, consumers, and others.\n\n\n\nDRA\n\nKuala Lumpur	submitted	\N	\N	\N	\N		f	\N	129	
93	2020-10-02 13:54:18+00		f	Non-compliance to MSPO Certification Scheme	Assisting Mr. Ganie Anak Assan IC:570127135813, HP: +6013-8270786, Address: No. 25, Lot 461, Phase II Taman Tiara, Jalan Brayun. 95000 Sri Aman, Sarawak on his complaints on encroachments of his NCR land in Selanjan, Sri Aman, Sarawak. Locality map and all relevant documents are attached for your reference.	submitted	\N	4287988f-93ab-4a3c-9790-77473ef7f799	\N	\N		f	\N	93	ephremryanalphonsus@gmail.com
96	2020-12-26 13:10:20+00		f	Non-compliance of national laws and regulations	All small holders are suffering to suppy FFB to factory,cause goverment allocated road been blocked(build up toll gate) by a non responsible Estate(ladang melintang maju sdn bhd)we need your assistance to solve this problem as soon as possible by contacting us.	submitted	\N	812c46f2-6962-4df8-90c0-f5dee109c540	\N	\N		f	\N	96	varmavarma186@gmail.com
70	2020-08-16 00:56:57+00		f	Others	We have obtained our MSPO certification part 3 on 01st October 2019 and we have submitted our claim by hand to MPOCC staff on 18th March 2020 at NIOSH bangi. We have emailed Mr Tan on 20th July 2020 to request for the status of the claim, but Mr Tan inform us that our application still in queue to be process due to large volume of application and the closure of MPOCC office due to MCO. Our management has queried on delay of the claim and we as sustainability officer unable to explain to our management since we dont't know the progress of the claim and it's hard for us to convince our management to continue doing the surveillance audit. So, we would like to suggest if MPOCC can create any system for the companies to monitor on the progress of the claim. We hope that MPOCC can revert on this matter as soon as possible. Thanks.	submitted	\N	bf3f6921-ab2d-4b8b-936f-38da5143c31d	\N	\N		f	\N	70	rusnanit78@gmail.com
98	2021-02-03 10:27:12+00	Translation and interpretation	f	Others	This digital submission is made at the request of MPOCC, following the submission of our letter and a bulk of documents in December 2020. It pertains to the complaints that we have received from six groups of indigenous communities in Marudi and Batu Niah, Sarawak in recent years, on the past and possible future violations of their native customary rights (NCR) by oil palm plantation projects. Please refer to our cover letter for further details. The communities involved are: (1) Rumah Manjan and Rumah Nanta, Sungai Malikat, Marudi; (2) Rumah Beliang, Logan Tasan, Marudi; (3) Rumah Labang Jamu, Nanga Seridan, Baram;  (4) Persatuan Iban Marudi (which concerns a larger area where several longhouses may be affected, including 1 and 2); (5) Persatuan Penduduk Sungai Buri, Bakong, Baram; (6) Persatuan Penduduk Rumah Lachi, Sungai Sebatuk, Batu Niah.  For email communications, kindly write to three addresses: foemalaysia@gmail.com, jokjevong@gmail.com and shaffincre@gmail.com. Thank you.	submitted	\N	a54f43bc-3510-4267-9c02-de241f28979b	\N	\N		f	\N	98	foemalaysia@gmail.com
99	2021-02-08 07:45:26+00		f	Others	We can't add one of our FFB supplier in our supplier list because they did not appear in certified supplier registration. The supplier is Koperasi Bina Bersama Kampong Gajah Perak Berhad. We need to add the supplier in our FFB supplier list for FFB monthly declaration. I attach the supporting document for your reference. Thank you.	submitted	\N	13b7d6b3-42a7-40ec-b227-f1b91f791dcc	\N	\N		f	\N	99	amirul@kksl.com.my
100	2021-02-22 02:15:05+00		f	Non-compliance to MSPO Certification Scheme	Tuan,\n\n\n\nMOHON KHIDMAT NASIHAT DAN PEMAKLUMAN ISU PENSIJILAN MSPO FGV KOMPLEKS SERTING\n\n\n\nAdalah dimaklumkan bahawa Kompleks Serting yang terdiri daripada Kilang Sawit FGVPI Serting dan empat (4) ladang sawit FGVPM telah disijilkan dengan pensijilan MSPO part 4 dan MSPO part 3 pada 14 Ogos.2018 dan telah berjaya di audit ASA 1 pada tahun berikutnya. Pensijilan MSPO bagi kompleks ini dijalankan oleh Badan Pensijilan Mutuagung Lestari (Malaysia) yang telah dilantik oleh FGV melalui kontrak yang telah ditandatangani untuk menjalankan pensijilan MSPO Kompleks Serting sehingga ASA 4. \n\n\n\nNamun begitu, Mutuagung Lestari (Malaysia) yang sepatutnya menjalankan audit ASA 2 bagi kompleks ini telah gagal melaksanakannya sehingga tarikh surat ini dikeluarkan. Pada awalnya pihak FGV memberi kelonggaran disebabkan oleh PKP dan isu Covid 19 yang sedang menular. Pihak FGV juga telah beberapa kali membuat susulan dangan badan pensijilan tersebut, di mana susulan yang terakhir dibuat melalui email bertarikh 8 Januari 2021 dan pihak kami memberi tempoh yang munasabah sehingga penghujung Januari 2021 untuk pihak Mutuagung Lestari (Malaysia) melaksanakan Audit ASA 2. \n\n\n\nWalau bagaimanapun, maklumbalas hanya diterima oleh pihak FGV pada 3 Februari 2021 yang menyatakan bahawa Mutuagung Lestari (Malaysia) tidak dapat melaksanakan audit MSPO pada masa ini kerana perlu menyelesaikan masalah dalaman dengan Mutuagung Lestari (Indonesia). Makumbalas tersebut juga menyatakan bahawa pihak FGV tidak boleh membuat proses pemindahan sijil kepada Badan Pensijilan lain.\n\n\n\nSuhubungan dengan itu, pihak FGV memohon khidmat nasihat daripada pihak MPOCC selaku pemilik skim pensijilan MSPO untuk cadangan langkah-langkah atau tindakan terbaik yang boleh diambil bagi meneruskan Pensijilan MSPO Kompleks Serting. Bersama-sama ini disertakan surat maklumbalas daripada Mutuagung Lestari (Malaysia) untuk rujukan dan tindakan lanjut pihak Tuan.\n\n\n\nSegala bantuan dan khidmat nasihat dari pihak Tuan amatlah di hargai.\n\n\n\nSekian terima kasih.\n\n	submitted	\N	ded6488b-469e-484e-b815-a00534d3e10f	\N	\N		f	\N	100	ameer.h@fgvholdings.com
102	2021-03-08 04:31:16+00		f	Non-compliance to MSPO Certification Scheme	On 22/02/2021, GGC as accepting CB has contacted issuing CB for FGV Tenggaroh and Serting Hilir (Mutuagung Lestari (M) Sdn Bhd to initiate the pre-transfer process (evidence attached) as per IAF:MD2 Transfer of Accredited Certification of Management Systems. However, GGC not received proper feedback and cooperation to this process from Mutuagung Lestari (M) Sdn Bhd. Based on GGC internal review and FGVPM information, there is no reason for Mutuagung Malaysia to hold and delayed the transfer process since all obligation has been fulfilled by FGVPM.	submitted	\N	e0cf9d78-629a-4f0c-8c5e-d4eb659c758a	\N	\N		f	\N	102	jamal@ggc.my
105	2021-05-06 07:49:39+00		f	Others	This is a complaint letter on the objections to the entry of Muzana Plantation JV Sdn. Bhd. PL Lot 327 Puyut Land District by Persatuan Melayu Marudi. The Malay community in Marudi found out that part of the territory of customary land (NCR) in the region of Lot 1200 PL Puyut Land District in 2010, was affected by the grant of a license palm plantation project development from Rimbunan Sawit Sdn Bhd to Muzana Plantation JV Sdn Bhd without their acknowledgment. Hence, they are adamant to try and make sure that their ancestral lands would not be taken over by irresponsible companies for their future generation's sake. 	submitted	\N	0dfa2c7d-310b-4a83-98f5-197421843955	\N	\N		f	\N	105	wzynole@gmail.com
106	2021-05-08 00:20:54+00		f	Others	HI, I AM FROM TETANGGA AKRAB SDN BHD WOULD LIKE TO LODGE A COMPLAIN REGARDING ON MSPO TRACE SUBMISSION. WE TRIED TO UPLOAD OUR MSPO TRACE SINCE YESTERDAY 7TH MAY 2021 BUT FAILED. OUR INTERNET CONNECTION WAS FINE. IS THERE ANY OTHER WAYS FOR US TO SUBMIT OUR MSPO TRACE? KINDLY FEEDBACK AS SOON AS POSSIBLE. ENCLOSED IS THE EVIDENCE THAT THE SERVER CANNOT UPLOAD POUR SUBMISSION. THANKS AND BEST DAY. 	submitted	\N	b0b2df8d-3835-4d06-a95d-d6a376b95ea1	\N	\N		f	\N	106	adeline.stefanie.ta@gmail.com
107	2021-05-25 04:42:15+00		f	Others	LADANG SAWIT YANG DIUSAHAKAN TELAH DIMUSNAHKAN OLEH PIHAK SYARIKAT DIBAWAH SYARIKAT PUSAKA CAPITAL. POKOK SAWIT YANG DITANAM SEJAK TAHUN 2017 DAN MEMPUNYAI 150 POKOK. PUNCA PENDAPATAN AMAT TERJEJAS. MOHON PIHAK MPSO MEMBUAT PANTAUAN DAN TINDAKAN DENGAN SEGERA.	submitted	\N	1f99b32d-2a96-4760-b450-ed45b0abe4d1	\N	\N		f	\N	107	monalizalidom81@gmail.com
116	2021-08-12 14:50:15+00		f	MSPO Trace	When I wish to make announcemnt for CPO & PK deliveries in July (after the maintenance was done). It seems like there is a limit of only 1 upload per month is allowed. The problem with 4 of our CPO Mill is, one mill wish to make correction after successful upload so they canceled the announcement then when they watnt to upload again there is a error message saying upload has been done already. Another mill after upload CPO to 1 buyer, unable to upload PK to the same buyer or any other buyer. Is there any other ways to make announcement manually?	submitted	\N	80708127-7fdf-4c9d-8b6f-315c374c0cf4	\N	\N		f	\N	116	kyting@jayatiasa.net
115	2021-08-04 12:47:33+00		f	Others	I can't submit monthly declaration for june and july. it's keep loading like in the picture that I attached.	submitted	\N	f22bd07e-28a0-4135-b73e-fb6629087485	\N	\N		f	\N	115	suburbanpom@gmail.com
124	2021-10-05 15:06:11+00		f	MSPO Trace	Unable to register certified smallholder (SUPPLIER NAME: RODY TADLE) in MSPO Trace. Seem that the supplier is not yet in the supplier list database. Attached herewith are the supplier's MSPO Certificate for ur kind perusal.	submitted	\N	cedde969-4985-499b-a05c-5325099bf7aa	\N	\N		f	\N	124	goldenelate.pom@gmail.com
125	2021-10-06 15:33:15+00		f	Others	False Claims by MPOCC\n\na) Whilst MPOCC had failed to remove all 10 FGV certificates issued by MALM against the MSPO requirements, FGV has continued to make public that it has achieved 100% MSPO certification for all its operations;\n\nb) MPOCC’s conduct to publicly disseminate misleading information to unsuspecting stakeholders is improper and is further fortified by MPOCC’s actions to maintain the FGV certificates on its website instead of adhering to the technical requirements governing the MSPO scheme;\n\nc) The claims made by MPOCC is clearly untrue based on MPOCC’s own published records and bias against all other MSPO certificate holders and to downstream buyers of MSPO certified products sold by FGV.	submitted	\N	4da24124-a1ef-4efe-832d-a89ddfd8945a	\N	\N		f	\N	125	mutuagungmalaysia@gmail.com
126	2021-10-06 18:08:43+00		f	Others	False Claims by FGV \n\n\n\na)\tAs provisioned under the MSPOCS01 Procedure Clause 7.12, a certified entity is required to complete the annual surveillance assessment within 12 months of the certificate expiration date by an accredited certification body;\n\n\n\nb)\tTake note that based on the MPOCC website, there are no records of FGV completing the annual surveillance assessments in 2021 for any of the certified operations listed in our letter dated 09.09.2021.  As of todate, the published reports by MPOCC only reflect assessments that were conducted in 2019;\n\n\n\nc)\tIn addition, whilst MPOCC had failed to remove the said 10 FGV certificates against the MSPO requirements, FGV has continued to make public that it has achieved 100% MSPO certification for all its operations;\n\n\n\nd)\tFGV’s conduct to disseminate misleading information to unsuspecting stakeholders is improper and is further fortified by MPOCC’s actions to maintain the FGV certificates on its website instead of adhering to the technical requirements governing the MSPO scheme.  Such matters are within DSM’s knowledge given DSM’s own Complaints Panel had rejected MALM’s suspension appeal on similar grounds;\n\n\n\ne)\tIn any event, the claims made by FGV is clearly untrue and bias against all other MSPO certificate holders and to downstream buyers of MSPO certified products sold by FGV.	submitted	\N	4da24124-a1ef-4efe-832d-a89ddfd8945a	\N	\N		f	\N	126	mutuagungmalaysia@gmail.com
131	2022-01-28 17:32:39+00		f	Non-compliance of national laws and regulations	No action taken by the company against Kamala Kumaran  a/ l Ayyaru and Mustamin bin Suhaili for their misconduct. 	submitted	\N	0f718b43-671c-4b6f-b906-34ee7b45b4b2	\N	\N		f	\N	131	thilaganarthan@gmail.com
132	2022-02-08 09:25:43+00		f	Others	Our December 2021 monthly report posting In the system, the date captured by the system as Jan 2022 report, please help to rectify this error, so that we can post  Jan 2022 monthly report.	submitted	\N	12c58e57-7eb9-4e61-a298-52c44ab6e5e2	\N	\N		f	\N	132	chongchungwai@icloud.com
151	2022-06-30 12:35:34+00		f	MSPO Trace	There is no "Download All" tab at Smallholders List website.  Need to access all list of company under Certified Independent Smallholders. The information will be used to produce report for bank.	submitted	\N	0a7806d8-7b08-4629-bcfc-b5304bc684c4	\N	\N		f	\N	151	murshidayusoff@gmail.com
133	2022-02-10 17:32:45+00		f	Non-compliance to MSPO Certification Scheme	PENCEROBOHAN TANAH ADAT (NCR) OLEH SYARIKAT GRAND OLIE SDN BHD DAN REAL HOLISTIC SDN BHD DI SG. URONG BAKONG, MIRI, SARAWAK ATAU PENCEROBOHAN TANAH ADAT OLEH SYARIKAT LADANG SAWIT. Sila rujuk lampiran. Untuk Peta asal Tanah Adat sila rujuk Map Lama Sungai Urong.pdf. Untuk makluman Tuan Kawasan penempatan rumah panjang kami sudah masuk PL kompeni sawit juga. Pada masa akan datang kami akan melalui krisis yang amat besar dalam hal tanah adat ini kerana kompeni ladang sawit ini. Saya sendiri pernah menghadiri mesyuarat bersama Pengarah Urusan Real Holistic Sdn Bhd pada tahun 31 Jan 2013, jam 11.30 pagi di Pejabat Daerah Marudi, Baram. Semasa mesyuarat saya sendiri membantah dengan TIDAK BERSETUJU tanah kami masuk PL kompeni. Namun akhirnya kami di tipu. Walaupun semasa mesyuarat Pegawai Land & Survey datang mesyuarat. Saya mewakili penduduk Rumah Panjang daripada Tuai Rumah Selema Janting memohon agar isu tanah adat kami ini di beri perhatian. Sebelum ini kami yang membantah akan pencerobohan tanah adat NCR ini di bawah jagaan Tuai Rumah Linggi. Sejak kes tanah ini kami telah di pulaukan oleh Tuai Rumah Linggi dan akhirnya kami sudah menubuhkan JKKK sendiri dan akhirnya sudah melantik Tuai Rumah sendiri (Sila rujuk Minit mesyuarat) dengan sokongan YB Datu Dr. Penguang. YB banyak membantu kami dalam hal isu tanah adat ini juga. Untuk pengetahuan kami sudah membawa isu tanah adat ini kepada YAB Ketua Menteri Sarawak dan akhirnya sudah ada perhatian oleh MANRED. Namun syarikat ladang ini masih mengganggu kami malah makin teruk sekali.	submitted	\N	e80a6ccf-333b-407f-ae20-ae04ee67f667	\N	\N		f	\N	133	josephjanting@gmail.com
134	2022-02-26 13:12:15+00		f	Others	Non compliance on auditor MSPO. Not competence already become audit. Less experience work less than 5 year still can be auditor. The auditor name Ahmad Farris bin Nazmi Asna. Currently work work with DQS before this as freelance with PCi .	submitted	\N	7c42038f-aa20-4f20-ba43-839d3474a560	\N	\N		f	\N	134	rusdi@primulagemilang.com
139	2022-04-14 13:29:54+00		f	Others	Tuan\n\n\n\nSaya ingin memajukan aduan rasmi berkenaan beberapa tindakan yang dilakukan oleh Pihak Badan Persijilan Rephro Cerification Sdn Bhd. \n\n\n\n1.\tMenawarkan khidmat consultancy dan pengauditan kepada pelanggan. ( Rujuk bukti perbualan pelanggan dan Samsul Suhatman – Sales & Marketing Executive Rehpro Certification Sdn bhd -  hantaran whatsapp dan voice note ) \n\nSaya mendapat maklumat pihak ini sedang aktif menawarkan khidmat consultancy dan pengauditan kepada pelanggan mereka. Perkara ini telah belaku lama dan saya mendapat tahu antara pelanggan yang di berikan khidmat consultancy dan pengauditan adalah TP Resources Sdn Bhd. Alasan mereka menggunakan company yang berbeza iaitu Rephro Scientific Sdn Bhd untuk CHRA yang terdapat element recomendation dan juga khidmat perundingan  , saya rasa tidak patut diterima memandangkan ia dimiliki oleh Pemilik yang sama ( Sila Rujuk Sijil SSM yang disertakan ), malah apabila mereka merasakan perbuatan mereka semakin dihidu , mereka cuba menggunakan Eko Green Solution ( Syarikat ini tiada dalam data SSM ) untuk khidmat consultancy dan pengauditan ( Berdasarkan hantaran whatsapp) . Ini  saya dapati  bertentangan dengan keperluan yang dinyatakan didalam ISO IEC 1702. \n\n\n\nClause 5.2.5  - The Certification Body and any part of the same legal entity  and ANY ENTITY under the organizational control of the certification ( See 9.5.1.2) shall not offer or provide management system consultancy . This also applies to that part of government identified as the certification body \n\n\n\n9.5.1.2 (b) Majority participation by the certification body on the board of director another identity. \n\n\n\n5.2.7 Where a client has received management systems consultancy form a body that has relationship with a certification body, this is significant threat to impartiality. A recognized mitigation of this threat is that the certification body shall not certify management system for a minimum of two years following the end of the consultancy \n\n\n\nMalah tindakan mereka memasarkan perkhidmatan consultancy dan pengauditan adalah tidak selaras dengan \n\n\n\nClause 5.2.9 The certification body activity shall no be marketed or offered as linked with the activities of organization that provides management consultancy. The certification body shall take action to correct inappropriate links or statement by any consultancy organization stating or implying that certification would be simpler, easier, faster, or less expensive if the certification body were used. A certification body shall not imply that the certification would be simpler easier, faster , or less expensive if a specified consultancy organization were used \n\n\n\n2.\tPenawaran khidmat pengauditan kepada pelanggan yang tidak menepati keperluan Malaysia Sustainable Palm Oil Certification Scheme Clause 6.4\n\nBedasarkan Quotation dari Pihak Rephro bertarikh 23/3/2022 kepada Regal Establishment Sdn Bhd, Pihak CB menawarkan perkhidmatan pengauditan menggunakan format Group Certification dengan menggabungkan 7 estate ( 4 lokasi di Sabah dan 3 disemenanjung ) . Site No 1 hingga 4 yang dinyatakan didalam quotation adalah lokasi di semenanjung manakala site 5 hingga 7 berada di sabah. Ini bertentangan dengan   clause 6.4 MSPOCS01 . Bagaimana pun saya tidak dapat memastikan samada pelanggan bersetuju dengan tawaran tersebut. ( Rujuk lampiran Quotation No MSPO/2021/35 Date 23/3/2022. \n\n\n\nSelain itu,walaupun saya mendapat makklumat tidak dapat disahkan melibatkan pengaturan keputusan audit dan sebagainya , namun kesukaran mendapatkan bukti dan tiada akses kepada pelanggan terlibat menyebabkan perkara ini tidak dapat dikenalpasti. Oleh itu saya berharap sekiranyan terdapat penyiasatan rasmi oleh pihak tuan, diharap perkara ini juga diambil perhatian. \n\n\n\nSaya amat berharap penyiasatan penuh dijalankan kerana sekiranya dibiarkan , ini akan menjadikan contoh oleh pihak lain menggunakan situasi yang sama sekaligus menjejaskan kredibiliti Persijilan MSPO. \n\nBukti2 lain tidak dapat dilampirkan dan perlu menggunakan platform lain kerana format dan saiz data. \n\nSekian Terima Kasih \n\n\n\nAdnin Aminurrashid Bin Zilah \n\n	submitted	\N	582f5571-b638-444b-9527-12503ce384a3	\N	\N		f	\N	139	adninaminurrashid@gmail.com
122	2021-09-10 16:18:28+00		f	test by airei	TEST BY AIREI	submitted	\N	\N	\N	\N		f	\N	122	
108	2021-07-08 03:15:17+00		f	Others	Test test test test	submitted	\N	1b9260e9-b2bc-4ac3-86ed-cd13d669bd46	\N	\N		f	\N	108	suryantiselalukecewa@gmail.com
94	2020-11-23 02:23:17+00		f	Others	I am unable to Register MSPO trace using my SCCS certificate No : DMC MSPO SCCS 04, please help	submitted	\N	12c58e57-7eb9-4e61-a298-52c44ab6e5e2	\N	\N		f	\N	94	chongchungwai@icloud.com
118	2021-08-23 11:33:11+00		f	Non-compliance to MSPO Certification Scheme	test test test test	submitted	\N	4d6dc0fa-8a2f-4073-9bbd-85425124beb0	\N	\N		f	\N	118	leo_gee87@yahoo.com
137	2022-04-14 09:00:21+00		f	Others	test test test test test	submitted	\N	4d6dc0fa-8a2f-4073-9bbd-85425124beb0	\N	\N		f	\N	137	leo_gee87@yahoo.com
130	2022-01-21 10:12:04+00		f	Others	A) We are unable to modify the MSPO Certificate no for Our FFB suppliers From SGS cert.no to DIMA cert No. B) does the Update of Certificate No affect the Previous records ? C) there is no edit button the action Column at the Supplier list screen in MSPO trace system, how do we amend the MSPO Certificate No ?	submitted	\N	12c58e57-7eb9-4e61-a298-52c44ab6e5e2	\N	\N		f	\N	130	chongchungwai@icloud.com
140	2022-04-14 13:50:18+00		f	Others	 I would like to lodge a formal complaint regarding the non compliance  to MSPO Certification Scheme currently practice by Ecco Certified\n\n\n\nBased on the review conducted on their Linkedin  Auditor Ecco Certified Profile for  MUHAMAD NAZRAN NAZARNO  - Link  https://www.linkedin.com/in/nazran/ and  Mr Amirul Arif - Link https://www.linkedin.com/in/amirul-arif-1a0845202/ ,  I found that Mr Nazran just completed his degree in 2017 while Mr Amirul Arif just completed his degree in 2018 . Mr Nazran has only had total working experience 2 year  6 month , while Mr Amirul only has working experience in oil palm sector 1 year 1 Month. The working experience for both auditor was not inline with the requirement stated in Table 1 OPMC 1 which require the auditor to have at least 7 years of work experience in oil palm sector. Refer to attachment - copy of the public summary report for company  - Tay Plantation Sdn Bhd audited by both auditors on 20th January 2021 in the chapter - Audit team auditor profile, Mr Nazran has acknowledged that he only has 2 years of working experience in oil palm sector.  \n\n\n\nkindly need your attention on this matter.  Thank you. \n\n\n\nKindly maintain the confidentiality of my identity.	submitted	\N	05039a36-049a-47b0-9e99-6de64a44acbd	\N	\N		f	\N	140	mspo2019@yahoo.com
142	2022-05-12 09:30:10+00	Translation and interpretation	f	Others	This digital submission is made at the request of MPOCC. It follows the first printed submission of our letter and a bulk of printed documents in December 2020; the first digital submission in February 2021 on this website; and more recent email and telephone communications in April 2022. It pertains to the complaints that we have received from six groups of indigenous communities in Marudi and Batu Niah, Sarawak in recent years, on the past and possible future violations of their native customary rights (NCR) by oil palm plantation projects. Please refer to our cover letter dated April 28, 2022 for further details. The communities involved are: (1) Rumah Manjan and Rumah Nanta, Sungai Malikat, Marudi; (2) Rumah Beliang, Logan Tasan, Marudi; (3) Rumah Labang Jamu, Nanga Seridan, Baram; (4) Persatuan Iban Marudi (which concerns a larger area where several longhouses may be affected, including 1 and 2); (5) Persatuan Penduduk Sungai Buri, Bakong, Baram; (6) Persatuan Penduduk Rumah Lachi, Sungai Sebatuk, Batu Niah. 48 supporting documents are also uploaded for these six complaints to provide more detailed information for each case. For further communications, we can be reached through these three email addresses; foemalaysia@gmail.com, jokjevong@gmail.com and shaffincre@gmail.com; or through telephone lines +60 85 756 973 (Sarawak office) or +60 13 686 7509 (Jok Jau Evong). Thank you.	submitted	\N	a54f43bc-3510-4267-9c02-de241f28979b	\N	\N		f	\N	142	foemalaysia@gmail.com
149	2022-05-30 21:13:13+00		f	Non-compliance of national laws and regulations	Dear Sir/Madam, \n\nRe : Grievance against Sawira Sdn Bhd \n\nI was hired by Sawira Sdn Bhd as General Manager on the 8th Feb 2021 with two years duration contract basis. \n\nSince January 2022, I had felt that the management had been ignoring me and the head office started directly dealing with my Estate Managers. \n\nAround this time, or in December 2022, the company staff had joined the union AMESU and I had brought the matter to the management via an email to the Group HR Manager which had no reply at all. Following which, I had in January 2022 submitted a staff salary revision scale in accordance to industrial standards range to the company and again I did not receive any reply from Group HR Manager who had later resigned in Feb 2022. Subsequent to this since March 2022, I am now being placed in cold storage, at Common Ground Office, Mont Kiara, Kuala Lumpur and I am made to only write company SOPs. I believe the joining of the staff with the Union could be a reason why I am being treated by the company unfairly though they have denied it. \n\nI had been instructed by my immediate superior that my managers no longer will report to me and I am not allowed to speak to anyone including suppliers, vendors, etc related to Sawira Sdn Bhd or its operational management. I am being told that I cannot even leave the Common Ground Office at Mont Kiara, Kuala Lumpur without prior permission including not allowed to go or visit the plantation estates unless otherwise instructed so.  \n\nI have written three letters to the company questioning the company’s action and reason (attached herewith). First letter dated 6th April 2022, they replied saying due to my health reason and that it's for my own good they decided so. To this I must say, they are merely making-up this as an excuse to me as I have no serious health concerns for the company to do so. I have replied denying that I have any health issues as so claimed by the company and no doctors had given me any unfit to work status. \n\nOn my second letter again sent on the April 2022 dated 15th April 2022, the company HR replied that on their record I am still the General Manager of Sawira Sdn Bhd and that the task of writing the SOPs is linked at their digitalization program that the company is undertaking. Following which, I had replied again (third letter dated 6th May 2022), stating that, I am willing to do a full medical checkup if the company had any concerns on my health and that otherwise, if I am considered the General Manager of Sawira, I should be allowed to return back to my company’s resident house at Ladang Sawira Utara at Muadzam Shah, Pahang and that all my authorities and powers as General Manager should be reinstated as normal. I am yet to receive a reply from the company and hence I am reporting this to MSPO as my grievance against the company for their unfair treatment given to me. \n\nI am feeling that the company is deliberately forcing me to resign by humiliating me and ignoring me making me feel unwanted or required.  \n\nI am placed in KL office at Co-shared office sitting at the Lobby (though after my first complain they did try to give another isolated open space sitting arrangement that is totally improper for a company GM) and only made to write SOPs and to-date since I am here, I am not even being called for any meetings or discussion. I am also been denied attending meetings representing the company with AMESU and any email response/reply from the company on AMESU matter is hidden from me, and including all company operational matters are directly communicated to the Estate Managers and staff without my knowledge. \n\nTrust that MSPO will look into my grievance and will stop this unfair treatment to myself and also ensure that the company look into the staff salary revision and their welfare as per AMESU and industrial practices.  \n\nLastly, as a point to note, MSPO should also investigate the company on foreign workers matters particularly the Bangladesh workers on why many had run away or returned back to their home country recently. This can have a serious consequence on our image of palm oil industry and Malaysia at large if it comes out later in the open. I am stating this matter here, as I have no part or role whatsoever to any ill treatment of foreign workers at Sawira Sdn Bhd should the matter comes out or be expose during the coming MSPO audit. As the General Manager, I have been denied the power to investigate, resolve or act on the matter accordingly at that time.  \n\nThank you  \n\nRavindran Veerasamy \n\nHp: 0125575446 \n\n\n\np/s : (i) Evidences on abuse done to Bangladesh workers for further investigation available.\n\n         (ii) The grievance complaint was also submitted on the MSPO Trace webpage on the 20th May 2022 but did not receive any login password or acknowledgement from the webpage system. \n\n	submitted	\N	4e33cfac-f5fe-4c35-9861-84d7917606ae	\N	\N		f	\N	149	rveerasa@hotmail.com
150	2022-06-29 10:20:37+00		f	Non-compliance to MSPO Certification Scheme	Ladang C&G membuang sisa bahan buangan terjadual ke dalam Sg. Trace.	submitted	\N	54003f0f-9dc2-4142-a7a3-37781c6caa2f	\N	\N		f	\N	150	muhsienbadrulisham@gmail.com
152	2022-07-04 11:17:08+00		f	Others	Hi, im Head of Portfolio Reporting, Credit Risk Management of Agrobank. My team is currently assigned to prepare climate risk reports. We are facing difficulties to download all the small holder's listing from your website because there is no button/tab to click to download all which i find available under OPMC certified list & SCCS certified list. We require one off download to save time saving each page into excel and map with the Bank's customer database. Appreciate your assistance on this matter and do advice us should you require an official request letter from our CEO or CRO.	submitted	\N	2abe0ef5-50a6-4f32-bcd0-ccbb192771c5	\N	\N		f	\N	152	chitra.loganathan@agrobank.com.my
153	2022-07-05 10:03:03+00	Translation and interpretation	f	Others	Subject: MSPO Status Delayed\n\n\n\nDear Sir,\n\n\n\nIn conjunction with the above subject, as for the information of MPOCC, oil palm plantations and palm oil mill under Tee Teh Sdn Bhd were audited for 2nd Annual Surveillance by Global Gateway Certification Sdn Bhd last year on 07-09 December 2021.\n\n\n\nAs a client with MSPO certification, we are very concerned about the delayed status in MSPO Trace. According to our CB, the delayed status was due to the report still under review by MPOCC.\n\n\n\nHence, we seek your kind assistance in the above matter. Thank you.	submitted	\N	0919a2be-3b19-418f-91e8-ae8a8ffd3e48	\N	\N		f	\N	153	baxteraymond@gmail.com
123	2021-09-30 13:02:15+00		f	Others	Kegagalan pengeluaran sijil SPOC oleh SIRIM dalam tempoh masa yang ditetapkan yang mana secara tidak langsung mengganggu proses pensijilan pekebun-pekebun kecil yang terlibat. Akibat daripada kegagalan pihak SIRIM dalam mengeluarkan sijil dalam tempoh masa yang sepatutnya menyukarkan pihak kami dalam melaporkan status pensijilan pekebun kecil persendirian kepada pihak kementerian. Senarai SPOC yang terlibat seperti dilampirkan.	submitted	\N	536203a3-6335-4c60-ae6f-f852135c5419	\N	\N		f	\N	123	amiratul.aniqah@mpob.gov.my
136	2022-03-18 16:23:37+00	Translation and interpretation	f	Others	Non compliance principle three and free prior information consent	submitted	\N	e5871981-e66c-4c44-9183-0e8084e874c9	\N	\N		f	\N	136	luangbadol@gmail.com
143	2022-05-20 14:27:29+00		f	Non-compliance of national laws and regulations	Dear Sir/Madam,\n\nRe : Grievance against Sawira Sdn Bhd\n\nI was hired by Sawira Sdn Bhd as General Manager on the 8th Feb 2021 with two years duration contract basis.\n\nSince January 2022, I had felt that the management had been ignoring me and the head office started directly dealing with my Estate Managers.\n\nAround this time, or in December 2021, the company staff had joined the union AMESU and I had brought the matter to the management via an email to the Group HR Manager which had no reply at all. Following which, I had in January 2022 submitted a staff salary revision scale in accordance to industrial standards range to the company and again I did not receive any reply from Group HR Manager who had later resigned in Feb 2022. Subsequent to this since March 2022, I am now being placed in cold storage, at HQ Office at Common Ground Office, Mont Kiara, Kuala Lumpur and I am made to only write company SOPs. I believe the joining of the staff with the Union could be a reason why I am being treated by the company unfairly though they have denied it.\n\nI had been instructed by my immediate superior that my managers no longer will report to me and I am not allowed to speak to anyone including suppliers, vendors, etc related to Sawira Sdn Bhd or its operational management. I am being told that I cannot even leave the Common Ground Office at Mont Kiara, Kuala Lumpur without prior permission including not allowed to go or visit the plantation estates unless otherwise instructed so. \n\nI have written three letters to the company questioning the company’s action and reason (attached herewith). First letter dated 6th April 2022, they replied saying due to my health reason and that its for my own good they decided so. To this I must say, they are merely making-up this as an excuse to me as I have no serious health concerns for the company to do so. I have replied denying that I have any health issues as so claimed by the company and no doctors had given me any unfit to work status.\n\nOn my second letter again sent on the April 2022 dated 15th April 2022, the company HR replied that on their record I am still the General Manager of Sawira Sdn Bhd and that the task of writing the SOPs is linked at their digitalization program that the company is undertaking. Following which, I had replied again (third letter dated 6th May 2022), stating that, I am willing to do a full medical check up if the company had any concerns on my health and that otherwise, if I am considered the General Manager of Sawira, I should be allowed to return back to my company’s resident house at Ladang Sawira Utara at Muadzam Shah, Pahang and that all my authorities and powers as General Manager should be reinstated as normal. I am yet to receive a reply from the company and hence I am reporting this to MSPO as my grievance against the company for their unfair treatment given to me.\n\nI am feeling that the company is deliberately forcing me to resign by humiliating me and ignoring me making me feel unwanted or required. \n\nI am placed in KL office at Co-shared office sitting at the Lobby (though after my  complain they did try to give another isolated open space sitting arrangement that is totally improper for a company GM) and only made to write SOPs and to-date since I am here, I am not even being called for any meetings or discussion. I am also been denied attending meetings representing the company with AMESU and any email response/reply from the company on AMESU matter is hidden from me, and including all company operational matters are directly communicated to the Estate Managers and staff without my knowledge.\n\nTrust that MSPO will look into my grievance and will stop this unfair treatment to myself and also ensure that the company look into the staff salary revision and their welfare as per AMESU and industrial practices. \n\nLastly, as a point to note, MSPO should also investigate the company on foreign workers matters particularly the Bangladesh workers on why many had run away or returned back to their home country recently. This can have a serious consequence on our image of palm oil industry and Malaysia at large if it comes out later in the open. I am stating this matter here, as I have no part or role whatsoever to any ill treatment of foreign workers at Sawira Sdn Bhd should the matter comes out or be expose during the coming MSPO audit. As the General Manager, I have been denied the power to investigate, resolve or act on matter accordingly at that time. \n\nThank you \n\nRavindran Veerasamy\n\nHp: 0125575446\n\n	submitted	\N	4e33cfac-f5fe-4c35-9861-84d7917606ae	\N	\N		f	\N	143	rveerasa@hotmail.com
154	2022-08-19 10:07:54+00		f	Non-compliance to MSPO Certification Scheme	Assalamualaikum Tuan\n\nSy Nazmi Zain, Setiausaha Jawatankuasa Bertindak Kg Sg Kerawai-Selat Manggis-Kg Merdeka Teluk Intan\n\n\n\nAduan berkaitan Estet Batang Padang MHC Plantation Sdn Bhd.\n\n\n\nISU \n\n1. Berkaitan jalan ladang yang menghubungkan kg merdeka.penduduk sudah banyak kali membuat aduan kepada pihak estet untuk meninggikan had palang yg di buat oleh estet agar kenderaan kereta dapat lalu keluar masuk.namun tidak di endahkan pihak estet atas alasan banyak berlaku kecurian buah kelapa sawit estet\n\n2. 1 lagi laluan estet juga telah di korek kecilkan dan hanya untuk laluan motosikal sahaja boleh di lalui.juga pihak estet memberikan alasan yg sama.\n\n3. Atas faktor kecemasan dan keselamatan penduduk kg merdeka sekiranya berlaku perkara tidak di ingini seperti sakit teruk yg memerlukan di bawa segera ke hospital,ianya akan menjadi masalah kerana jalan tidak boleh di lalui oleh kereta apatah lagi ambulan.kalau hendak melalui jalan tersebut terpaksa maklum kepada pondok pengawal dan pihak pengawal akan buka gate.ini akan menyukarkan dan melambatkan proses untuk menyelamat sekiranya berlaku kecemasan.\n\n4. Penduduk Kg Selat Manggis sering kali di landa banjir..sekiranya berlaku banjir jalan utama ke kg tersebut tidak dapat di lalui dan jalan alternatif ialah jalan estet.malangnya jalan tersebut juga di pasang pagar dan terbaru jalan tersebut di korek kecilkan hanya laluan motorsikal sahaja yg boleh di gunakan.sekiranya ini terus berlarutan dan berlaku lagi musibah banjir,maka penduduk kg tersebut terkepung tidak boleh keluar .\n\n5. Pihak estet mengenakan bayaran rm45 1lori tidak kira berapa muatan kepada penduduk kampung yg menggunakan jalan estet untuk membawa keluar hasil kelapa sawit.ini seolah² British menjajah tanah melayu.hasil bumi anak jati kampung yang lahir di sini di kenakan seolah² cukai oleh pihak estet.perkara ini telah lama berlarutan.\n\n6  Pihak jawatankuasa bertindak sudah 2 kali menghantar surat kepada pihak pengurusan estet supaya perkara ini dapat di selesaikan di meja rundingan namun pihak estet hanya berani bersemuka dengan menghantar penolong pengurus untuk berjumpa dengan tiada jalan penyelesaian.pihak manager estet langsung tidak mahu berjumpa apatah lagi mahu mendengar masalah penduduk kampung.\n\n\n\nDi harap pihak Tuan dapat membantu memberikan khidmat nasihat kepada kami juga kepada pihak estet agar win win situation dapat di capai.\n\n\n\nTerima kasih Tuan	submitted	\N	01f2db6b-0dc0-45f1-842b-aced9d793fe6	\N	\N		f	\N	154	nazmizain4499@yahoo.com
158	2022-11-03 17:16:40+00		f	MSPO Trace	FFB delivery data for Sept 2022 was wrongly keyed in. I could not delete the submission and would like help from MPOCC to delete the data submitted so that I can key in the correct data. Attached is the correct data	submitted	\N	24f097e0-aad9-486d-887d-590379cf8f78	\N	\N		f	\N	158	kasthuri@unitedmalacca.com.my
161	2023-01-10 17:14:35+00	Translation and interpretation	f	Non-compliance to MSPO Certification Scheme	1. Kampung Tudan Ujung Daun villager is not given any compensation starting from 2013 until now by the palm oil company (WTK, Rimbunan Hijau and Woodman). \n\n\n\n2. During signing the Agreement Black and white between palm company and villager on 2011, the villagers is not allowed to review the contract contents. (Suspicious act by the company).\n\n3. The usage of (NCR/PULAU GALAU & PEMAKAI MENUA) by palm oil company no compensation is given to the villagers since 2013 until now.\n\n4. The usage of villagers land perimeters is not according to the agreement. (Plantation is very near to the long house area)\n\n5. No land space/capacity for The villagers to build a new Long house due to palm oil plantation area is too compact around the villagers land.\n\n6. Agreed bussines such as canteen/groceries stores at the palm area is not given to the villager. (Company promise to give the Bussiness opportunity to the villagers.)\n\n7. Job opportunity is not given to the villagers.\n\n8. This case document already submitted to lawyer but villager haven't proceed to file a lawsuit.	submitted	\N	bdbfe7f9-be3d-45db-9e74-0bafc00e3da8	\N	\N		f	\N	161	rudy_patrick@ymail.com
162	2023-01-11 11:06:42+00		f	Others	Complaint on Rate of Freelance auditor.\n\n\n\nHope MPOCC can monitor and control the price ceiling and price floor for the freelance auditor. Lately, PSV Certification has reduced tremendously to a minimum of RM400/day (Co-auditor) without any discussion earlier.  As freelancers, that price was not acceptable because we are also bearing the cost of EPF, SOCSO, Takaful/insurance & meals on our own. Looking forward to the MSPO 2.0 requirement and the competency of the auditor is higher up and it was not parallel with the rate made by the CB. We are taking care of workers' welfare in the estates and mills, but we forgot to ensure the person who carries out the job is paid equally. Hope MPOCC can look into this matter. I am not appointing PSV only but also the other CBs for further enhancement purposes. Please contact me anytime for further explanation. Thank you.	submitted	\N	8d17a10c-9baa-4371-be70-35eff53317e4	\N	\N		f	\N	162	padil5595@gmail.com
186	2023-09-13 17:33:23+00		f	Others	untuk nombor siri sijil MSPO di ladang, kami ingin menukar CB adakah no siri akan berubah atau kekal?. No siri MSPO akan digunakan untuk urusan surat menyurat untuk urusan ke kilang dan sebagainya. Kami mencadangkan pihak MPOCC selaraskan semua versi no siri antara CB untuk membantu meningkatkan kualiti pengurusan.	submitted	\N	0e4b6571-d7da-4d82-8035-b53821d50643	\N	\N		f	\N	186	ladangdelima17@yahoo.com
66	2020-08-16 00:40:31+00		f	Others	We have obtain our MSPO certification part 3 on 30th May 2019 and we have submitted our claim by hand to MPOCC staff on 18th March 2020 at NIOSH bangi. We have emailed Mr Tan on 20th July 2020 to request for the status of the claim, but Mr Tan inform us that our application still in queue to be process due to large volume of application and the closure of MPOCC office due to MCO. Our management has queried on delay of the claim and we as sustainability officer unable to explain to our management since we dont't know the progress of the claim and its hard for us to convince our management to continue doing the surveillance audit. So, we would like to suggest if MPOCC can create any system for the companies to monitor on the progress of the claim. We hope that MPOCC can revert on this matter as soon as possible. Thanks.	submitted	\N	e81e22aa-0578-4fb2-8d0b-5665be08b8ee	\N	\N		f	\N	66	janechinshuikwen@gmail.com
163	2023-02-01 10:14:35+00	Translation and interpretation	f	Non-compliance to MSPO Certification Scheme	1) Violation of the agreement between Tabung Haji Ladang Enggang and villagers . \n\n-As per the reports of 26/05/2016 attached said, Tabung Haji PH,Ladang Enggang cut down all the plants that the villagers have been working for without consent and start planting the palm oil in their land . \n\n\n\n-  Around 2009 , Tabung Haji PH agreed to pay a compensation to villagers regarding the NCR Land that they had used. But they have not given any compensation until 2023. \n\n\n\n2) The office staff of Tabung Haji PH, Ladang Enggang is not cooperative and friendly .\n\n-During last year, the villagers wanted to discuss about the land compensation to their manager but they refused and told the villagers to go back and until  today , they have not taken an action any furthur regarding the issue .\n\n\n\n3) The Community of KPG BELADIN wants their NCR LAND to be returned to rightful owner . \n\n-As the issue is not given any attention , the community wants their NCR land to be returned .	submitted	\N	e8e773cd-d387-4efc-b92e-98dd804a3dd3	\N	\N		f	\N	163	nurulsyahira336@gmail.com
164	2023-02-03 07:23:41+00	Translation and interpretation	f	Others	Encroaching on indigenous land by planting palm oil on peatland. In March 2022. The villagers and I saw the land bulldozers encroaching on the native area without talking to the natives. besides that, our farm was also invaded and the old grave of our village was destroyed. The encroachment of this peatland causes fires and the destruction of orchards affected by dry marshland. The party that encroached on our land is the PASFA company. We request that the PASFA company immediately stop the cultivation of palm oil on our traditional heritage land, thank you	submitted	\N	e1ccea0a-ccc5-48c9-98dd-26a48399ec52	\N	\N		f	\N	164	suhaidakanjisuhaida@gmail.com
156	2022-10-26 00:37:54+00		f	Others	SLAVERY TREATMENT  Jendarata Estate 36009, Teluk Intan, Perak Darul Ridzuan                                                                                                                                                                   \n\n                                                                                                                                                                        I would like to make an official complaint about what happened to my daughter Thaarshaliny who worked in Jendarata Estate 36009, Teluk Intan, Perak Darul Ridzuan.  The management was forced to give their resignation. Here is the summary and refer to the attachment accordingly.\n\n\n\nNote: I wrote an email to Dato Carl Bek Nielsen for a face-to-face meeting up but he decline. ( Attached is my last email to Dato Carl. File name: Reply Dato Carl.pdf\n\n1) File name: Bully case in Jendarata Estate.pdf (attached)\n\n2) File name: 1st email to Dato Carl (attached)\n\n3) File name: Dato Carl's Respond (attached)\n\n4) File name: Director Edward Rajkumar (attached) - forcing my daughter to do resignation. Director Edward chased my daughter Thaarshaliny when she came near to tell him about the incident. Slavery treatment (witnessed by Soornarayanan Subramaniam (Senior Hospital Assistant working in Jendarata Estate (my daughter's supervisor)\n\n5) File name: DI 29.09.2022 - Conducted by HR Manager Mathews. The DI investigation is biased. HR Manager still asked my daughter to agree that she lost the documents (insufficient care) even though there is no proof (No CCTV installed in the working place). Sasikala has admitted all the accusations, but no stern action is taken against her \n\n6) File Name: Mathews- DI email.pdf - The DI was not done properly. Thaarshaliny supervisor and working colleagues not investigated the incident. It is truly biased to Sasikalah A/P Kathirasen.  Nanda Kumar A/L Veeramohan (Senior Assistant Manager)  was not even called for the domestic inquiry (DI). \n\n\n\n7) File name: Resignation Letter_Thaarshaliny - My daughter has no choice but to resign from her current position due to bullied, INHUMANE TREATMENT, public shaming, BREACH OF PRIVACY, NOT treated with dignity and respect. She was treated like a new era of slavery. \n\n    \n\n SLAVERY PRACTICES IN JENDARATA ESTATE (UNITED PLANTATION)\n\na) The directors and the manager talk very rudely to the staff. Treating the workers like a slave. In my daughter's case, Director Edward chased my daughter Thaarshaliny when she came near to tell him about the incident and told her "dont't come near me, go far and talk to him" (treating her like an animal). Witnessed by Thaarshaliny's Supervisor, SoorNarayanan Subramaniam (Senior Hospital Assistant)\n\nb) Not letting the parents enter and visit the estate even in an emergency case. My daughter needs to write a letter to the Management (Priya's clerk ) forced to give the letter to her if the parents want to visit. During my daughter's interview session, the interviewer, HR Manager Mathews, and Jeevan Dharma Balan mentioned that the parents can come and stay with you anytime. \n\nc) Cannot plant any trees above 6 feet in your house compound. This was not documented in any of the United Plantation SOP. Even my daughter's papaya tree which was only 3 feet was asked to remove by Nanda Kumar A/L Veeramohan & Sasikalah A/P Kathiresen \n\nd)Asking people to come to work late at night 9 PM and early morning 6 AM. (Actual working hour is 8 PM - 5 PM as per the offer letter). Sasikalah A/P Kathiresen  did this to my daughter \n\ne) No proper drinking water has been supplied in the staff quarters given (no test water report has been shown). Please take the sample water from MH 02/02, where my daughter leaves, and send it to the test lab. The water is contaminated with bacteria. The staff need to walk very far to take the drinking water \n\ne) No people can go out after 10 PM to town to get any emergency items. The main gate will be closed. Not been mentioned in the work contract.\n\nf) Security guards at the main gate of Jendarata Estate act like a policeman, there is one Sarjan having a gun bringing the gun near to me when I am talking to the Security guard in charge, Balakrishnan, and threatening by bringing the gun towards me by saying we have our own rules in Jendarata and why are you questioning us. I just wanted to do some clarification about why not allowing parents to enter the estate and why we need to write an official letter\n\ng)No overtime is paid to my daughter even though she worked additional hours bringing the patient to the hospital.  Sometimes she returned to her quarters at 8.30 PM after bringing the patient to Government Hospital in Teluk Intan.\n\nh) When the staff purchase any hardware like cabinets, TV, Fridges, or washing machine, the staff must write a letter to the management to get the purchased item entered inside the estate. Cannot get the needy items immediately. In my daughter's case, I went and bought the TV, Fridge, and washing machine on one of the Saturdays, and the person to deliver these items cannot come inside even though my daughter call the person in charge Nanda Kumar A/L Veeramohan (Senior Assistant Manager). Nanda Kumar scolded my daughter and told "Ay stupid, dont't you know today is Saturday and you are not allowed to bring any bought items inside. Write a letter first about why you dont't have any common sense." \n\nI) In Division 1's grocery,' shops do not have sufficient household things. Workers need to order and wait for a long time.\n\n\n\n    Below snapshot is the code of conduct of the United plantation. It is clearly stated that bad faith allegation may result in disciplinary actions. Why Sasikalah A/P Kathirasen and Nanda Kumar A/L Veeramohan (Senior Assistant Manager) was not taken any disciplinary action and why the management forcing my daughter to resign?\n\n\n\n\n\n\n\n\n\nPlease do a drastic investigation by sending your people to the Jendarata Estate, 36009, Teluk Intan, Perak, Malaysia. \n\n\n\nGuys,\n\n\n\n       I am very serious about getting justice for my daughter's case as she was forced to resign from her position by Director Edward Rajkumar.                                                                                                Sasikala and Nanda Kumar (backup by HR Manager Methew and Director Edward Rajkumar) planning to bring in the former Radiograper Thirunna and get rid of my daughter through bullying and slavery treatment\n\n\n\nI have already escalated this matter to  International Labour Office (ILO), Geneva, and going to publish it in a local newspaper. Please look into this matter seriously as this is against human rights!	submitted	\N	af60092b-2d06-411f-8353-dacf3da797d3	\N	\N		f	\N	156	Parameswaran_Subramaniam@jabil.com
71	2020-08-16 01:00:20+00		f	Others	We have obtained our MSPO certification part 3 on 01st October 2019 and we have submitted our claim by hand to MPOCC staff on 18th March 2020 at NIOSH bangi. We have emailed Mr Tan on 20th July 2020 to request for the status of the claim, but Mr Tan inform us that our application still in queue to be process due to large volume of application and the closure of MPOCC office due to MCO. Our management has queried on delay of the claim and we as sustainability officer unable to explain to our management since we dont't know the progress of the claim and it's hard for us to convince our management to continue doing the surveillance audit. So, we would like to suggest if MPOCC can create any system for the companies to monitor on the progress of the claim. We hope that MPOCC can revert on this matter as soon as possible. Thanks.	submitted	\N	3d06ba74-5af0-499d-81fa-6a61febaa57d	\N	\N		f	\N	71	nuramsconsultant@gmail.com
187	2023-11-11 11:49:02+00		f	MSPO Trace	To whom it may concern, I found that some of our existing Supplier and Buyer registration have missing since MSPO Trace system updated. Our previous record on MSPO Sales Announcement also have lost and need to be key in again. Kindly please look into it and assist us on how to retrieved the previous data again. You may refer to the attached file. Thank you.	submitted	\N	3daebba2-2008-456d-85ff-0f51d49e2068	\N	\N		f	\N	187	khairulidzuan@fjgroup.com.my
165	2023-02-03 14:24:55+00		f	Non-compliance to MSPO Certification Scheme	This complaint was raised for EAST WEST HORIZON PLANTATION BERHAD, DALIT LAUT. The detail of complaint was as per stated in the standard. However, there were complaints raised not related to the indicator but still it did not comply with the standard (another indicator).\n\n\n\n4.2.1.4 Indicator 4: The organisation shall provide information requested by relevant stakeholders\n\nand management documents shall be publicly available, except those limited by commercial\n\nconfidentiality or disclosure that could result in negative environmental or social outcomes. Information\n\nand documents shall be in appropriate languages and forms.\n\n\n\nComplaint: The management did not include all the relevant stakeholders during stakeholder consultation, the minutes of the meeting were not publicly available upon request. The plantation area was established at the area that classified as "communal land" thus the owner was the member of local community and being developed by appointed company. However, not all the participants were consulted during the stakeholder consultation and the community representative appointed by the company did not deliver the outcome of the consultation. This creates inaccurate information for the participants and results in dissatisfaction in regards with the payment of the dividen. The participant was also not aware of the complaint and grievance procedure of the company, this was also related to the payment of the dividen. Also, our contract with the company was not delivered to all the participants, it was only kept by the representative that being appointed by the company. During mspo external audit, we were not informed by the company or there is no notification regarding their stakeholder consultation. The company name is also different in the sites where it is called "Perintis Jati" and not "EAST WEST HORIZON PLANTATION BERHAD", this also creates confusion among the landowners. There were several disputes regarding the dividen payment, and no proper resolution was conducted. 	submitted	\N	cc6ec44c-3285-40f9-84fd-fe38f6cac978	\N	\N		f	\N	165	ravestan@gmail.com
167	2023-02-18 10:21:56+00		f	Non-compliance to MSPO Certification Scheme	To Whom May Concern,\n\n\n\nDear Sir/Madam,\n\n\n\nComplaints under type of;\n\n\n\n1. Non-compliance to MSPO Certification Scheme\n\n2. Non-compliance of national laws and regulations\n\n\n\n3. Non- compliance as vendor wrongdoing (OCP Supplier to KKS KOK FOH) with respect to;\n\n    - acts or omissions which are deemed to be against the interest of the Company, laws, regulations or        public policies.\n\n    - breaches of Group Policies and Code of Business Conduct (COBC)\n\n\n\nComplaints Details:\n\nWe urged the MSPO body to conduct an investigation on above mentioned complaints type on following basis;\n\n\n\nOn last 3.02.2023 at 1.30am the Immigration Department conducted raid operation at Ladang Cheong Wing Chan, Batu 4 1/2, Jalan Rompin, 72109 Bahau, Negeri Sembilan and arrested 38 illegal Indonesian nationals which hired by the estate management under contractors for harvesting works. The immigration department issued notice to the estate manager for sheltering and employing undocumented migrants. According to the Section 56(1)(d) of the Immigration Act 1959/63 and Section 55B of the same Act those found guilty of sheltering or employing undocumented migrants can be fined up to RM50,000. In addition to the fines, offenders can also be sentenced to prison or given six strokes of the cane if convicted.\n\n\n\nSince 2019 up-to present the estate management fully operating by using illegal immigrant workers which against the MSPO as per;   \n\n\n\n4.3 Compliance to Legal Requirements\n\n\n\n    Fail to adhere and meet the compliance of Legal requirements.\n\n\n\n4.4.1 Social Impact procedure\n\n\n\nFail to cover social impact on factors such as other community values, resulting from changes in     improvement of transport/communication/ influx of migrant labour force and forced or compulsory labour.\n\n\n\n4.6 Best Practice\n\nThe estate management and assigned contractors failed to adhere the MSPO certification scheme.\n\n\n\nEnclosed herewith the supporting documents for the complaints for your further action. We hoping the MSPO will take meaningful and timely action to the company involved. This not only calls into question the MSPO's commitment to address environmental and social problems, but also how credible the certification system is in addressing the continued problems in the palm oil industry.\n\n\n\nThank you.	submitted	\N	7d417c53-b437-40ff-911a-8d9eef5e2977	\N	\N		f	\N	167	tajuddinkamil@yahoo.com
171	2023-05-11 14:26:22+00	Translation and interpretation	f	Non-compliance to MSPO Certification Scheme	I worked as building artisan since 1 February 2023 with Keck Seng (Malaysia) Berhad on Estate office renovation. I have an agreement on price for office renovation work with General Manager (Mr Vincent Hee Vui Yong) in which mutually agreed. However, employer representative from factory management in Keck Seng (Malaysia) Berhad Mr Chua Teck Ngin that was temporarily overseeing estate operation when Mr Vincent Hee is not presence, he amended my salary without me agreeing. The amendment was done by Administrative Manager standby Soh Yoke Kam and admin staff Zailalahwati Binti Omar @ Yusof. I would like to complain Mr Chua Teck Ngin, Soh Yoke Kam and Zailalawati binti Omar @ Yusof because they amended my salary without me agreeing and did not pay me in full amount for April 2023 in which the work has been completed by end of April 2023. \n\nFurthermore, I was instructed by Assistant Manager Mohamad Syafik bin Saharuddin (950731-05-5561) to work on public holiday (Hari Raya) for 12 hours as Security Officer due to inadequate manpower during Hari Raya. I noticed I did not received pay for working during public holiday and overtime. \n\nI was not given a copy of my work agreement.	submitted	\N	fe48a53d-699e-4b91-9987-efdd47b9b34b	\N	\N		f	\N	171	andyaw8149@gmail.com
72	2020-08-16 01:05:25+00		f	Others	We have obtained our MSPO certification part 3 on 01st October 2019 and we have submitted our claim by hand to MPOCC staff on 18th March 2020 at NIOSH bangi. We have emailed Mr Tan on 20th July 2020 to request for the status of the claim, but Mr Tan inform us that our application still in queue to be process due to large volume of application and the closure of MPOCC office due to MCO. Our management has queried on delay of the claim and we as sustainability officer unable to explain to our management since we dont't know the progress of the claim and it's hard for us to convince our management to continue doing the surveillance audit. So, we would like to suggest if MPOCC can create any system for the companies to monitor on the progress of the claim. We hope that MPOCC can revert on this matter as soon as possible. Thanks.	submitted	\N	e81e22aa-0578-4fb2-8d0b-5665be08b8ee	\N	\N		f	\N	72	janechinshuikwen@gmail.com
185	2023-09-05 16:00:14+00		f	Non-compliance to MSPO Certification Scheme	As sent via email \n\n\n\nAndy Hall\n\nMigrant Worker Rights Specialist \n\n+977 (0) 9823486634 (Phone/WhatsApp)\n\nAndyjhall1979@gmail.com (Email)\n\n@atomicalandy (Twitter)\n\nBlog: https://andyjhall.org\n\n\n\n\n\n---------- Forwarded message ---------\n\nFrom: Andy Hall <andyjhall1979@gmail.com>\n\nDate: Tue, 5 Sep 2023 at 12:12\n\nSubject: (Request for MPOCC investigation) Fwd: Request for urgent investigation into unlawful Felda Management Sdn Bhd’s foreign worker recruitment practices\n\nTo: <complaints@mpocc.org.my>\n\nCc: <info@mpocc.org.my>\n\n\n\n\n\nTo: MPOCC\n\n\n\nRequesting your urgent investigation into the below complaint against \n\nFelda Plantation Management Sdn Bhd, as certified by the MSPO.\n\n\n\nI have submitted the complaint to government authorities today also. \n\n\n\nThanks. Kind Regards, Andy Hall \n\n\n\nAndy Hall\n\nMigrant Worker Rights Specialist \n\n+977 (0) 9823486634 (Phone/WhatsApp)\n\nAndyjhall1979@gmail.com (Email)\n\n@atomicalandy (Twitter)\n\nBlog: https://andyjhall.org\n\n\n\n\n\n---------- Forwarded message ---------\n\nFrom: Andy Hall <andyjhall1979@gmail.com>\n\nDate: Tue, 5 Sep 2023 at 11:55\n\nSubject: Request for urgent investigation into unlawful Felda Management Sdn Bhd’s foreign worker recruitment practices \n\nTo: Asri Ab Rahman <asri_a@mohr.gov.my>, <Khusairi@sprm.gov.my>, Mohd. Asri Abd. Wahab <masri@mohr.gov.my>, <jules@sprm.gov.my>, <jim.atipsom@imi.gov.my>, <mapo_tip@moha.gov.my>, <jtksm@mohr.gov.my>, Bahagian D3 JSJ Bukit Aman <atip_d3jsj@rmp.gov.my>, CC: Syuhaida bt Abdul Wahab Zen - SUB(NSO MAPO) <syuhaida@moha.gov.my>, atipsom tf <atipsom.tf@moha.gov.my>, <rhymie@mohr.gov.my>, <fadillah@kpk.gov.my>, <wafi@kpk.gov.my>, <normi.hassan@kpk.gov.my>, <roshiela.rasip@kpk.gov.my>, <misiah@kpk.gov.my>\n\nCc: CBP FORCED LABOR WRO <cbpforcedlaborwro@cbp.dhs.gov>, <BarnesL@state.gov>, FORCED LABOR <ForcedLabor@cbp.dhs.gov>, Joseph D'Cruz <jdcruz@rspo.org>\n\n\n\n\n\nTo: Minister, Ministry of Human Resources   \n\n\n\nTo: Minister, Ministry of Plantation and Commodities\n\n\n\nTo: Malaysian Anti Corruption Commission \n\n\n\nTo: related officials at Ministry of Home Affairs  \n\n\n\nCc: US Embassy, Malaysia \n\n\n\nCc: US Customs and Border Protection, USA  \n\n\n\nTo: RSPO\n\n\n\nColleagues, hope you are well. \n\n\n\nAs attached and below email correspondence, there has been no response forthcoming from Felda Plantation Management Sdn Bhd on the below complaint. \n\n\n\nAs a result of this non response as per my requested timeline from the company, I would hereby request your related government Ministries and agencies to conduct an urgent investigation into Felda Plantation Management Sdn Bhd’s alleged unlawful and unethical foreign worker recruitment practices. In particular, I consider such investigation should look into the alleged use of unlicensed Malaysian companies to conduct recruitment activities, without a JTKSM recruitment license category C, in serious breach of the 1981 Private Employment Agencies Act (Act 246 attached)\n\n\n\nI am concerned of the related governance and corruption implications of these practices also, and attach an example of Ideal Outsource Management Sdn Bhd as one alleged example of illegality and corruption. \n\n\n\nThanks for your urgent and independent investigation into\n\nthese most concerning allegations. \n\n\n\nKindest Regards, Andy Hall \n\n\n\nAndy Hall\n\nMigrant Worker Rights Specialist \n\n+977 (0) 9823486634 (Phone/WhatsApp)\n\nAndyjhall1979@gmail.com (Email)\n\n@atomicalandy (Twitter)\n\nBlog: https://andyjhall.org/\n\n\n\nOn 31 Aug 2023, at 10:46, Andy Hall <andyjhall1979@gmail.com> wrote:\n\n\n\n?Colleagues at FGV/Felda, hope you are well. \n\n\n\nSo could I please kindly\n\nfollow up with Felda on my below emails, sent 6 days ago. I would respectfully request a response from FGV and Felda by the CLOSE OF BUSINESS tomorrow (Friday 1st September), as I think one working week is sufficient to provide a response given the seriousness of the issues here. \n\n\n\nThanks for your continued and engagement and cooperation on these most sensitive of legal and ethical issues facing the company and it’s operations at this time. \n\n\n\nKindest Regards, Andy Hall\n\n\n\nAndy Hall\n\nMigrant Worker Rights Specialist \n\n+977 (0) 9823486634 (Phone/WhatsApp)\n\nAndyjhall1979@gmail.com (Email)\n\n@atomicalandy (Twitter)\n\nBlog: https://andyjhall.org/\n\n\n\n\n\n---------- Forwarded message ---------\n\nFrom: Andy Hall <andyjhall1979@gmail.com>\n\nDate: Fri, 25 Aug 2023 at 21:47\n\nSubject: Re: URGENT Worker complaint - Felda/FGV\n\nTo: Ismail Samingin (FELDA) <ismail.s@felda.net.my>, <jtksm@mohr.gov.my>\n\nCc: Ameer Izyanif Bin Hamzah (FGVHB) <ameer.h@fgvholdings.com>, Anthonius Sani (FGVPMSB) <anthonius.s@fgvholdings.com>, Bahagian D3 JSJ Bukit Aman <atip_d3jsj@rmp.gov.my>, CC: Syuhaida bt Abdul Wahab Zen - SUB(NSO MAPO) <syuhaida@moha.gov.my>, Citra Hartati <citra.hartati@rspo.org>, Ian Spaulding <ispaulding@elevatelimited.com>, Izham Mustaffa (FELDA) <izham.m@felda.net.my>, Jeff Bond <jeff.bond@elevatelimited.com>, Joseph D'Cruz <jdcruz@rspo.org>, MAD ZAIDI MOHD KARLI (MPIC) <zaidi@mpic.gov.my>, NURUL HUDA BINTI MOHD ZAINUDIN <nurul@mpic.gov.my>, Nawin Santikarn <nawin.santikarn@elevatelimited.com>, Nurul Hasanah bt. Ahamed Hassain Malim (FGVHB) <hasanah.ahm@fgvholdings.com>, Savitri Restrepo <savitri.restrepo@elevatelimited.com>, Spaulding, Ian <ian.spaulding@lrqa.com>, Wan Kasim Bin Wan Kadir (FGVHB) <wankasim.wk@fgvholdings.com>, Zofia Lawrence <zofia.lawrence@elevatelimited.com>, atipsom tf <atipsom.tf@moha.gov.my>, <azie@mpoc.org.my>,  \n\n<azreen.asnan@feldaglobal.com>, <bel@mpoc.org.my>, <jim.atipsom@imi.gov.my>, <soochin.io@rspo.org>, <wbmaster@mpoc.org.my>\n\n\n\n\n\nIsmail, as below email, I did some further checks, maybe some misunderstanding my side, but I cannot find on the Malaysian government online portal/register most of your Malaysian manpower agencies recruiting workers from Nepal, see online register at  https://jtksm.mohr.gov.my/ms/perkhidmatan/agensi-pekerjaan-swasta/senarai-agensi-pekerjaan-swasta\n\n\n\nAt first glance, it seems many of your Malaysian recruitment agencies are irregular registered Malaysian companies without Malaysian government license or approval (License C) to recruit foreign workers for Malaysian employers. Perhaps  outsourcing companies actually? \n\n\n\nWould welcome clarification here, I highlighted the agencies here below that don’t appear in the Malaysia government licensed manpower agency list but are in FGV/Felda’s list as currently Malaysian agencies. \n\n\n\n\n\nOnly AGENSI PEKERJAAN are allowed to recruit foreign workers, and then only then they possess a license C status, as I understand it. Do correct me if I am wrong here. \n\n\n\nKindest Regards, Andy \n\n\n\nOn 25 Aug 2023, at 17:15, Andy Hall <andyjhall1979@gmail.com> wrote:\n\n\n\n?\n\nIsmail, thanks in responding for FELDA Plantation Management Sdn Bhd here. \n\n\n\nI will ask colleagues to follow up in more detail with workers concerned and revert back asap with additional responses in relation to statements of fact made by FELDA here. \n\n\n\nA few stark and basic observations on the migrant worker recruitment issue response statements from Felda however, initially from my side. \n\n\n\nIn my experience, it doesn’t matter much what amount of money companies such as FELDA pay to your Malaysian manpower agencies. Malaysian manpower agencies frequently double or triple dip. \n\n\n\nWhat this means actually is that these Malaysian manpower agencies too often take money for recruitment costs from employers, from source country agents AND from workers. \n\n\n\nMalaysian agencies are too often vehicles for corruption. And often these same Malaysian agencies also have to pay significant amounts of money to company HR staff. Indeed, it’s general practice that Malaysian agencies have to pay bribes and kickbacks to Malaysian companies personnel to even secure the worker demand letters in the first place. \n\n\n\nThat said, of course it’s important that companies such as FELDA do open tenders for Malaysian agents and do map and cover all costs of recruitment, including potentially hidden costs, to ensure workers do not pay for jobs. \n\n\n\nI note also that the payment to Nepali agencies here is 400RM per worker. The 2018 MoU between Malaysia and Nepal mandates, as I understand it, a minimum 50% of  minimum wage monthly salary that should be paid to a Nepali agent. That is currently 750RM. \n\n\n\nWhat matters here in this area of social and legal compliance actually, in my\n\nhumble opinion and based on my experience, is whether companies such as FELDA monitor or not how much of the money your management and company actually pays to Malaysian agencies in recruitment fees and costs actually ends up with the Nepali (or source country) agencies. Usually in my basic experience this is very little, or even nothing at all. \n\n\n\nDo FELDA actually monitor banking transactions between Malaysian agents and source country agencies? \n\n\n\nUsually the Nepali (or source country) agencies have to pay Malaysian agencies larger kickbacks or bribes to secure worker demands from them, which they then recoup alongside their own profit margin (and those costs of subagent) from migrant workers themselves. To put it simply…. Often Nepali (or source country) agencies pay Malaysian agencies money, and not the other way around. Hence the need for careful monitoring. \n\n\n\nWhat matters here actually, in my humble opinion, is not what costs FELDA cover but how FELDA monitors your Malaysian agencies to ensure their ethical business practices. \n\n\n\nIn my experience it is hard for any company in Malaysia (and often in Thailand too) to effectively monitor Malaysian manpower agencies in practice. This is why I strongly advocate for larger companies to bring recruitment functions in house and hence do away completely with the need to use unreliable Malaysian agencies for recruitment related activities or functions.\n\n\n\nSubagents are also strictly illegal in Nepal, recruitment illegality of this kind should not be condoned or accepted by FELDA or your Malaysian agencies, or by related companies and agents. \n\n\n\nCan I also check, are all the Malaysian agencies you list in your Appendix response licensed with a Category C recruitment license under the Private Employment Agencies Act 1981? \n\n\n\nA category C license is required to source foreign workers for an end user employer in Malaysia, whilst outsource hire companies have been illegal for some time in Malaysia, I understand. \n\n\n\nAs always, I stand ready to support and advise companies such as FGV and FELDA, and other RSPO members generally, in adopting ethical recruitment practices that go beyond words (policies) towards genuine practice (implementation) in a way that promotes sustainable business practices for end user employers and manpower agencies whilst also respecting and promoting workers rights not to have to pay for their work. \n\n\n\nI consider FELDA and FGV still have a long way to go in this regard, but appreciate your response and continued efforts here. \n\n\n\nWishing you a pleasant weekend. \n\n\n\nKindest Regards, Andy Hall \n\n\n\nOn Fri, 25 Aug 2023 at 15:43, Ismail Samingin (FELDA) <ismail.s@felda.net.my> wrote:\n\nDear Andy,\n\n\n\n \n\n\n\nWith regards to your email, please find enclosed the respond from FELDA Plantation Management Sdn Bhd for your information.\n\n\n\n \n\n\n\nregards\n\n\n\n \n\n\n\nFrom: Andy Hall <andyjhall1979@gmail.com> \n\nSent: Wednesday, August 16, 2023 8:53 AM\n\nTo: Nurul Hasanah bt. Ahamed Hassain Malim (FGVHB) <hasanah.ahm@fgvholdings.com>\n\nCc: Ameer Izyanif Bin Hamzah (FGVHB) <ameer.h@fgvholdings.com>; Anthonius Sani (FGVPMSB) <anthonius.s@fgvholdings.com>; Bahagian D3 JSJ Bukit Aman <atip_d3jsj@rmp.gov.my>; CC: Syuhaida bt Abdul Wahab Zen - SUB(NSO MAPO) <syuhaida@moha.gov.my>; Citra Hartati <citra.hartati@rspo.org>; Dato’ Amir Hamdan Yusof <amir.hy@felda.net.my>; Djaka Riksanto <djaka.riksanto@rspo.org>; Ian Spaulding <ispaulding@elevatelimited.com>; Izham Mustaffa (FELDA) <izham.m@felda.net.my>; Jeff Bond <jeff.bond@elevatelimited.com>; Joseph D'Cruz <jdcruz@rspo.org>; MAD ZAIDI MOHD KARLI (MPIC) <zaidi@mpic.gov.my>; NURUL HUDA BINTI MOHD ZAINUDIN <nurul@mpic.gov.my>; Savitri Restrepo <savitri.restrepo@elevatelimited.com>; Wan Kasim Bin Wan Kadir (FGVHB) <wankasim.wk@fgvholdings.com>; Zuraida Kamaruddin <zuraida.kamaruddin@gmail.com>; atipsom tf <atipsom.tf@moha.gov.my>; azie@mpoc.org.my; azreen.asnan@feldaglobal.com; bel@mpoc.org.my; Ismail Samingin (FELDA) <ismail.s@felda.net.my>; jim.atipsom@imi.gov.my; jtksm@mohr.gov.my; kamini.v@rspo.org; salleh.a@felda.net.my; shazlee@mpic.gov.my; wbmaster@mpoc.org.my\n\nSubject: Re: URGENT Worker complaint - Felda/FGV\n\n\n\n \n\n\n\nHi all, hope all is well. \n\n\n\n \n\n\n\nAm following up again over one month on for a response to this complaint attached sent in early July. I will be sending these allegations and the non response onto related international related enforcement bodies if there is no response by the end of the week. It’s unacceptable in my opinion to recieve no response. \n\n\n\n \n\n\n\nRSPO, could we get a response here too from your side? \n\n\n\n \n\n\n\nThanks. Kind Regards, Andy \n\n\n\n \n\n\n\nOn Wed, 26 Jul 2023 at 16:50, Andy Hall <andyjhall1979@gmail.com> wrote:\n\n\n\nColleagues, please note there has been zero response to this email since 10th July.  Thanks. Regards, Andy Hall \n\n\n\n \n\n\n\n? From: Andy Hall <andyjhall1979@gmail.com>\n\n\n\nDate: 10 July 2023 at 15:07:47 BST\n\n\n\nTo: "Nurul Hasanah bt. Ahamed Hassain Malim (FGVHB)" <hasanah.ahm@fgvholdings.com>\n\n\n\nCc: "Ameer Izyanif Bin Hamzah (FGVHB)" <ameer.h@fgvholdings.com>, "Anthonius Sani (FGVPMSB)" <anthonius.s@fgvholdings.com>, Bahagian D3 JSJ Bukit Aman <atip_d3jsj@rmp.gov.my>, "CC: Syuhaida bt Abdul Wahab Zen - SUB(NSO MAPO)" <syuhaida@moha.gov.my>, Citra Hartati <citra.hartati@rspo.org>, Dato’ Amir Hamdan Yusof <amir.hy@felda.net.my>, Djaka Riksanto <djaka.riksanto@rspo.org>, Ian Spaulding <ispaulding@elevatelimited.com>, "Izham Bin Mustaffa (FELDA)" <izham.m@felda.net.my>, Jeff Bond <jeff.bond@elevatelimited.com>, Joseph D'Cruz <jdcruz@rspo.org>, "MAD ZAIDI MOHD KARLI (MPIC)" <zaidi@mpic.gov.my>, NURUL HUDA BINTI MOHD ZAINUDIN <nurul@mpic.gov.my>, Savitri Restrepo <savitri.restrepo@elevatelimited.com>, "Wan Kasim Bin Wan Kadir (FGVHB)" <wankasim.wk@fgvholdings.com>, Zuraida Kamaruddin <zuraida.kamaruddin@gmail.com>, atipsom tf <atipsom.tf@moha.gov.my>, azie@mpoc.org.my, azreen.asnan@feldaglobal.com, bel@mpoc.org.my, ismail.s@felda.net.my, jim.atipsom@imi.gov.my, jtksm@mohr.gov.my,\n\n\n\n \n\n\n\n \n\n\n\nkamini.v@rspo.org, salleh.a@felda.net.my, shazlee@mpic.gov.my, wbmaster@mpoc.org.my\n\n\n\nSubject: URGENT Worker complaint - Felda/FGV\n\n\n\n \n\n\n\nColleagues, please find attached Felda plantations worker complaint regarding to strike, indicators of forced labour and other alleged rights abuses. Would appreciate FGV/Felda’s urgent investigation and response here. Thanks. Regards, Andy Hall\n\n\n\n \n\n\n\n--\n\n\n\nAndy Hall\n\nMigrant Worker Rights Specialist \n\n+977 (0) 9823486634 (Phone/WhatsApp)\n\nAndyjhall1979@gmail.com (Email)\n\n@atomicalandy (Twitter)\n\nBlog: www.andyjhall.wordpress.com\n\n\n\n \n\n\n\n--\n\n\n\nAndy Hall\n\nMigrant Worker Rights Specialist \n\n+977 (0) 9823486634 (Phone/WhatsApp)\n\nAndyjhall1979@gmail.com (Email)\n\n@atomicalandy (Twitter)\n\nBlog: https://andyjhall.org\n\n\n\n-- \n\nAndy Hall\n\nMigrant Worker Rights Specialist \n\n+977 (0) 9823486634 (Phone/WhatsApp)\n\nAndyjhall1979@gmail.com (Email)\n\n@atomicalandy (Twitter)\n\nBlog: https://andyjhall.org\n\n	submitted	\N	e8eef5b6-23c8-43b6-b361-5407820aa1bd	\N	\N		f	\N	185	andyjhall1979@gmail.com
172	2023-05-11 14:30:13+00		f	Non-compliance to MSPO Certification Scheme	I worked as building artisan since 1 February 2023 with Keck Seng (Malaysia) Berhad on Estate office renovation. I have an agreement on price for office renovation work with General Manager (Mr Vincent Hee Vui Yong) in which mutually agreed. However, employer representative from factory management in Keck Seng (Malaysia) Berhad Mr Chua Teck Ngin that was temporarily overseeing estate operation when Mr Vincent Hee is not presence, he amended my salary without me agreeing. The amendment was done by Administrative Manager standby Soh Yoke Kam and admin staff Zailalahwati Binti Omar @ Yusof. I would like to complain Mr Chua Teck Ngin, Soh Yoke Kam and Zailalawati binti Omar @ Yusof because they amended my salary without me agreeing and did not pay me in full amount for April 2023 in which the work has been completed by end of April 2023. \n\nFurthermore, I was not given a copy of my work agreement.	submitted	\N	54762cd7-e15c-4dfe-b8c3-620921ec2366	\N	\N		f	\N	172	rose_rmy@hotmail.com
173	2023-05-11 15:59:10+00	Translation and interpretation	f	Non-compliance to MSPO Certification Scheme	I worked as building artisan since 1 February 2023 with Keck Seng (Malaysia) Berhad on Estate office renovation. I have an agreement on price for office renovation work with General Manager (Mr Vincent Hee Vui Yong) in which mutually agreed. However, employer representative from factory management in Keck Seng (Malaysia) Berhad Mr Chua Teck Ngin that was temporarily overseeing estate operation when Mr Vincent Hee is not presence, he amended my salary without me agreeing. The amendment was done by Administrative Manager standby Soh Yoke Kam and admin staff Zailalahwati Binti Omar @ Yusof. I would like to complain Mr Chua Teck Ngin, Soh Yoke Kam and Zailalawati binti Omar @ Yusof because they amended my salary without me agreeing and did not pay me in full amount for April 2023 in which the work has been completed by end of April 2023.	submitted	\N	6b17a4a1-6399-4241-8bae-98ce72ffd9b8	\N	\N		f	\N	173	syafiqdanial1803@hotmail.com
157	2022-11-03 10:38:32+00		f	Non-compliance to MSPO Certification Scheme	Aduan pencerobohan ataupun penerokaan oleh Green Jaya Resources Sdn Bhd , sebauh estate ( MPOB lesen 616232002000) di Kawasan Hutan Simpan Similajau Bintulu Sarawak	submitted	\N	4af83a63-96e1-44ea-a7aa-749a66e5fcd7	\N	\N		f	\N	157	michaeln@sarawak.gov.my
159	2022-11-14 14:28:06+00		f	Others	Test test test test test	submitted	\N	3a62ecb7-b6c8-4883-9066-4e1a871adc12	\N	\N		f	\N	159	test@yahoo.com
174	2023-05-11 16:01:12+00	Translation and interpretation	f	Non-compliance to MSPO Certification Scheme	I worked as building artisan since 1 February 2023 with Keck Seng (Malaysia) Berhad on Estate office renovation. I have an agreement on price for office renovation work with General Manager (Mr Vincent Hee Vui Yong) in which mutually agreed. However, employer representative from factory management in Keck Seng (Malaysia) Berhad Mr Chua Teck Ngin that was temporarily overseeing estate operation when Mr Vincent Hee is not presence, he amended my salary without me agreeing. The amendment was done by Administrative Manager standby Soh Yoke Kam and admin staff Zailalahwati Binti Omar @ Yusof. I would like to complain Mr Chua Teck Ngin, Soh Yoke Kam and Zailalawati binti Omar @ Yusof because they amended my salary without me agreeing and did not pay me in full amount for April 2023 in which the work has been completed by end of April 2023. \n\nFurthermore, I was instructed by Assistant Manager Mohamad Syafik bin Saharuddin (950731-05-5561) to work on public holiday (Hari Raya) for 12 hours as Security Officer due to inadequate manpower during Hari Raya. I noticed I did not received pay for working during public holiday and overtime. \n\nI was not given a copy of my work agreement.	submitted	\N	646b90b4-51f9-44ce-9e89-41492cb826f9	\N	\N		f	\N	174	siing8807@gmail.com
175	2023-05-12 07:50:54+00		f	Non-compliance to MSPO Certification Scheme	I prepared documents for payroll of our building artisan and submit to Factory Management Mr Chua Teck Ngin whom at that point of time temporarily overseeing Estate operation for his signature. Before hand, estate management had an written agreement with building artisan which mutually agreed on the work to be done and pricing. However, Mr Chua Teck Ngin refused to release the payment to these building artisan and stated that they had basic salary. I explained to him that the work has been done and we need to pay them for the work done in April 2023. He still insisted and instructed me to amend their payroll which later on I refused to do so because it is against Employment Act 1955. He then instructed Administrative Manager standby Ms Soh Yoke Kam (at that point of time, she was no longer in charge payroll) to amend the payroll and assisted by Zailalawati (admin staff). They amended the payroll during my absence and it was a public holiday. Mr Chua Teck Ngin threatened me of not following his instruction and requested me just follow his instructions. Ms Soh Yoke Kam turned off CCTV in the office during my absence especially CCTV that is facing armoury room. It is against Akta Agensi Persendirian 1971. I feel very uneasy on their attitude and action.	submitted	\N	6f88c691-03be-4853-8903-67e2bca0d234	\N	\N		f	\N	175	kitying88@gmail.com
73	2020-08-16 01:07:44+00		f	Others	We have obtained our MSPO certification part 3 on 01st October 2019 and we have submitted our claim by hand to MPOCC staff on 18th March 2020 at NIOSH bangi. We have emailed Mr Tan on 20th July 2020 to request for the status of the claim, but Mr Tan inform us that our application still in queue to be process due to large volume of application and the closure of MPOCC office due to MCO. Our management has queried on delay of the claim and we as sustainability officer unable to explain to our management since we dont't know the progress of the claim and it's hard for us to convince our management to continue doing the surveillance audit. So, we would like to suggest if MPOCC can create any system for the companies to monitor on the progress of the claim. We hope that MPOCC can revert on this matter as soon as possible. Thanks.	submitted	\N	bf3f6921-ab2d-4b8b-936f-38da5143c31d	\N	\N		f	\N	73	rusnanit78@gmail.com
177	2023-05-15 10:08:47+00		f	MSPO Trace	Our company info is not found in the MSPO Trace SCCS certified list. Logged into Davos Life Science Sdn. Bhd. account but found other company info was registered inside. Kindly refer to the enclosed supporting document for better understanding.	submitted	\N	a31bd0c1-174b-4922-a1b7-e60acc9b25b4	\N	\N		f	\N	177	wl.young@davoslife.com
176	2023-05-12 17:31:35+00		f	Non-compliance to MSPO Certification Scheme	I worked as building artisan since 1 February 2023 with Keck Seng (Malaysia) Berhad on Estate office renovation. I have an agreement on price for office renovation work with General Manager (Mr Vincent Hee Vui Yong) in which mutually agreed. However, employer representative from factory management in Keck Seng (Malaysia) Berhad Mr Chua Teck Ngin that was temporarily overseeing estate operation when Mr Vincent Hee is not presence, he amended my salary without me agreeing. The amendment was done by Administrative Manager standby Soh Yoke Kam and admin staff Zailalahwati Binti Omar @ Yusof. I would like to complain Mr Chua Teck Ngin, Soh Yoke Kam and Zailalawati binti Omar @ Yusof because they amended my salary without me agreeing and did not pay me in full amount for April 2023 in which the work has been completed by end of April 2023.	submitted	\N	33f581a6-b5de-49d8-acdd-1166f5a55844	\N	\N		f	\N	176	burnbakar1538@gmail.com
182	2023-08-17 10:08:32+00		f	Non-compliance of national laws and regulations	RSPO requirement for land development	submitted	\N	93a02249-5316-49a2-9ac7-12b4c8905133	\N	\N		f	\N	182	zuki.ak@fgvholdings.com
183	2023-08-17 10:28:12+00		f	Non-compliance to MSPO Certification Scheme	In 2019, Cahaya Ikhtiar supplied FFB to our mill. But, after receiving an alert from our buyer (Proter & Gamble), we chose to stop sourcing because they cannot provide EIA for their land development. The attachment is not related to our complaint but shows the company's image.	submitted	\N	93a02249-5316-49a2-9ac7-12b4c8905133	\N	\N		f	\N	183	zuki.ak@fgvholdings.com
184	2023-08-26 10:51:40+00		f	MSPO Trace	DATA SUPPLIER TIDAK BOLEH DIEDIT	submitted	\N	fd863516-76ca-4417-8047-db3bdf0cb04e	\N	\N		f	\N	184	alexius.n@fgvholding.socm
188	2023-12-12 15:21:42+00		f	Others	Assalamualaikum dan selamat petang. Saya mewakili Bahagian Penilaian dan Pengurusan Harta MDGM ingin menanyakan soalan dan memohon pandangan atau pendapat daripada pihak tuan berkenaan dengan permasaalahan yang akan kami ajukan ini. Untuk makluman tuan, Majlis Daerah Gua Musang telah mengenakan cukai taksiran kepada tanah pertanian ladang yang dibangunkan dalam Kawasan Majlis Daerah Gua Musang. Berhubung dengan perkara ini, ada beberapa lot ladang yang telah dikenakan cukai taksiran dan mempunyai tunggakan yang masih belum diselesaikan. Kami di pihak MDGM telah membuat pelbagai perkara untuk menyelesaikan perkara ini. Namun masih belum berjaya. Oleh yang demikian, kami memohon pandangan daripada pihak tuan, jika ada jalan-jalan yang boleh dilalui bagi membantu pihak kami menyelesaikan permasalahan ini contohnya (pemilik ladang yang ingin menyambung lesen MPOB hendaklah mendapat kelulusan MDGM- tiada tunggakan cukai taksiran) atau mana-mana kaedah yang dirasakan patut. Untuk makluman tuan,  hasil daripada pungutan cukai taksiran akan digunakan untuk membangun kawasan bandar seperti selian lampu jalan, perkhidmatan taman rekreasi, lanskap dan lain-lain bagi kegunaan awam.---	submitted	\N	79e11466-b344-4852-81cb-39ff9e45ebc0	\N	\N		f	\N	188	mimisharida@gmail.com
166	2023-02-06 09:41:01+00		f	Others	hanaya sekadar bertanya,kenapa MSPO hanya ada dua bahasa sahaja iaitu english dan manadarin,sedangkan aplikasi ini dibuat untuk penduduk malaysia yang mengutamakan bahasa melayu atau bahasa malaysia,adakah semua pekebun kecil ini penduduknya adalah daripada penduduk americatau britain atau juga china,harap DIUBAH APLIKASI INI KERANA KITA ADALAH MALAYSIAN BUKAN CHINESE ATAU BRITAIN ATAU ENGLISH...	submitted	\N	5ad2dbaf-6d13-47a0-b9d2-47b7adb86ff0	\N	\N		f	\N	166	imj800120@gmail.com
191	2024-02-27 16:50:32+00		f	Non-compliance to MSPO Certification Scheme	Date: February 27, 2024\n\n\n\nI am writing to express my concern and request the postponement of the approval process for the Malaysian Palm Oil Board (MPOB) license pending further review of the applicants listed in the attached name list. This request is prompted by significant issues regarding the land where palm oil cultivation is taking place.\n\n\n\nFor your information, the parcels of land are classified as Native Communal Reserve (NCR) land under Section 6 of the Land Code, implying that all parcels of land within the Native Communal Reserve (NCR) rightfully belong to the community.\n\n\n\nAdditionally, it is crucial to note that individual surveys to ascertain rightful ownership of the land have not been finalized. The area is currently embroiled in a dispute, and the matter has been referred to the Office of Sub District Officer in Engkilili, Sri Aman for further instructions regarding the genuine ownership of the land.\n\n\n\nGiven the unresolved dispute over land ownership and the absence of finalized surveys, it would be premature to proceed with the approval of the MPOB license. Such action without clarification and resolution of land ownership issues could lead to potential legal complications and conflicts in the future.\n\n\n\nTherefore, I respectfully urge MPOCC to exercise caution by suspending the approval of the MPOB license until the land ownership disputes are conclusively resolved. This approach aligns with the principles of responsible and sustainable palm oil production, ensuring that all stakeholders' rights and interests are adequately protected.\n\n\n\nThank you for considering my concerns. I trust that MPOCC will address these issues in the best interest of all parties involved.\n\n\n\nFor your reference, I have attached the following documents:\n\n\n\n1\tThe Sarawak Government Gazette.\n\n2\tA Police report from one of the landowners.\n\n3\tA Letter of complaint to the Land and Survey Department, Sri Aman regarding encroachment into her land by one of the MPOB License applicants.\n\n4\tList of palm oil planters applying for the MPOB License from the communal area.\n\n\n\nYours sincerely,\n\n\n\nTR. Ruekeith Jampong\n\nHP 0165785755\n\nEmail: ruekeithjampong@gmail.com \n\n	submitted	\N	0b500a7c-c000-4b0f-b19a-4cc42e3d380e	\N	\N		f	\N	191	ruekeithjampong@gmail.com
65	2020-08-13 11:09:24+00		f	Others	We have successfully obtain our MSPO certification for Part 3 in September 2019 and we have submitted our claim to MPOCC by December 2019. However, until to date we have not receive any updates or payment claim from MPOCC. Moreover, our management always mentioned that the other estate has not obtain the MSPO certification but still operate until today without any problem. So, due to this two matters, our management has asked the sustainability officers to rethink on not doing the surveillance audit this year. We hope that we can have a proper response about this matter as soon as possible so that we as the sustainability officers can convince our management to continue the MSPO certification to comply the regulation. 	submitted	\N	e81e22aa-0578-4fb2-8d0b-5665be08b8ee	\N	\N		f	\N	65	janechinshuikwen@gmail.com
74	2020-08-16 01:09:24+00		f	Others	We have obtained our MSPO certification part 3 on 20th September 2019 and we have submitted our claim by hand to MPOCC staff on 18th March 2020 at NIOSH bangi. We have emailed Mr Tan on 20th July 2020 to request for the status of the claim, but Mr Tan inform us that our application still in queue to be process due to large volume of application and the closure of MPOCC office due to MCO. Our management has queried on delay of the claim and we as sustainability officer unable to explain to our management since we dont't know the progress of the claim and it's hard for us to convince our management to continue doing the surveillance audit. So, we would like to suggest if MPOCC can create any system for the companies to monitor on the progress of the claim. We hope that MPOCC can revert on this matter as soon as possible. Thanks.	submitted	\N	3d06ba74-5af0-499d-81fa-6a61febaa57d	\N	\N		f	\N	74	nuramsconsultant@gmail.com
147	2022-05-30 12:00:17+00		f	Non-compliance of national laws and regulations	Dear Sir/Madam,\n\nRe : Grievance against Sawira Sdn Bhd\n\nI was hired by Sawira Sdn Bhd as General Manager on the 8th Feb 2021 with two years duration contract basis.\n\nSince January 2022, I had felt that the management had been ignoring me and the head office started directly dealing with my Estate Managers.\n\nAround this time, or in December 2022, the company staff had joined the union AMESU and I had brought the matter to the management via an email to the Group HR Manager which had no reply at all. Following which, I had in January 2022 submitted a staff salary revision scale in accordance to industrial standards range to the company and again I did not receive any reply from Group HR Manager who had later resigned in Feb 2022. Subsequent to this since March 2022, I am now being placed in cold storage, at Common Ground Office, Mont Kiara, Kuala Lumpur and I am made to only write company SOPs. I believe the joining of the staff with the Union could be a reason why I am being treated by the company unfairly though they have denied it.\n\nI had been instructed by my immediate superior that my managers no longer will report to me and I am not allowed to speak to anyone including suppliers, vendors, etc related to Sawira Sdn Bhd or its operational management. I am being told that I cannot even leave the Common Ground Office at Mont Kiara, Kuala Lumpur without prior permission including not allowed to go or visit the plantation estates unless otherwise instructed so. \n\nI have written three letters to the company questioning the company’s action and reason (attached herewith). First letter dated 6th April 2022, they replied saying due to my health reason and that its for my own good they decided so. To this I must say, they are merely making-up this as an excuse to me as I have no serious health concerns for the company to do so. I have replied denying that I have any health issues as so claimed by the company and no doctors had given me any unfit to work status.\n\nOn my second letter again sent on the April 2022 dated 15th April 2022, the company HR replied that on their record I am still the General Manager of Sawira Sdn Bhd and that the task of writing the SOPs is linked at their digitalization program that the company is undertaking. Following which, I had replied again (third letter dated 6th May 2022), stating that, I am willing to do a full medical check up if the company had any concerns on my health and that otherwise, if I am considered the General Manager of Sawira, I should be allowed to return back to my company’s resident house at Ladang Sawira Utara at Muadzam Shah, Pahang and that all my authorities and powers as General Manager should be reinstated as normal. I am yet to receive a reply from the company and hence I am reporting this to MSPO as my grievance against the company for their unfair treatment given to me.\n\nI am feeling that the company is deliberately forcing me to resign by humiliating me and ignoring me making me feel unwanted or required. \n\nI am placed in KL office at Co-shared office sitting at the Lobby (though after my first complain they did try to give another isolated open space sitting arrangement that is totally improper for a company GM) and only made to write SOPs and to-date since I am here, I am not even being called for any meetings or discussion. I am also been denied attending meetings representing the company with AMESU and any email response/reply from the company on AMESU matter is hidden from me, and including all company operational matters are directly communicated to the Estate Managers and staff without my knowledge.\n\nTrust that MSPO will look into my grievance and will stop this unfair treatment to myself and also ensure that the company look into the staff salary revision and their welfare as per AMESU and industrial practices. \n\nLastly, as a point to note, MSPO should also investigate the company on foreign workers matters particularly the Bangladesh workers on why many had run away or returned back to their home country recently. This can have a serious consequence on our image of palm oil industry and Malaysia at large if it comes out later in the open. I am stating this matter here, as I have no part or role whatsoever to any ill treatment of foreign workers at Sawira Sdn Bhd should the matter comes out or be expose during the coming MSPO audit. As the General Manager, I have been denied the power to investigate, resolve or act on the matter accordingly at that time. \n\nThank you \n\nRavindran Veerasamy\n\nHp: 0125575446\n\n \n\n	submitted	\N	4e33cfac-f5fe-4c35-9861-84d7917606ae	\N	\N		f	\N	147	rveerasa@hotmail.com
205	2024-11-21 20:23:05+00		f	MSPO Trace	Complaints checking	submitted	\N	9899069d-e0c6-4dec-b3cd-e4080a838f61	\N	\N		f	\N	205	aireimail24@gmail.com
195	2024-05-11 08:17:36+00		f	MSPO Trace	Cannot filter out the MSPO Trace for smallholders. The MSPO trace for smallholders is not responding when trying to filter out the states and when using the search bar.	submitted	\N	bcc22448-661c-4e28-99a8-edb83a48195e	\N	\N		f	\N	195	ainanajwa.sbh@gmail.com
67	2020-08-16 00:47:09+00		f	Others	We have obtained our MSPO certification part 3 on 31st May 2019 and we have submitted our claim by hand to MPOCC staff on 18th March 2020 at NIOSH bangi. We have emailed Mr Tan on 20th July 2020 to request for the status of the claim, but Mr Tan inform us that our application still in queue to be process due to large volume of application and the closure of MPOCC office due to MCO. Our management has queried on delay of the claim and we as sustainability officer unable to explain to our management since we dont't know the progress of the claim and it's hard for us to convince our management to continue doing the surveillance audit. So, we would like to suggest if MPOCC can create any system for the companies to monitor on the progress of the claim. We hope that MPOCC can revert on this matter as soon as possible. Thanks.	submitted	\N	bf3f6921-ab2d-4b8b-936f-38da5143c31d	\N	\N		f	\N	67	rusnanit78@gmail.com
68	2020-08-16 00:50:51+00		f	Others	We have obtained our MSPO certification part 3 on 31st May 2019 and we have submitted our claim by hand to MPOCC staff on 18th March 2020 at NIOSH bangi. We have emailed Mr Tan on 20th July 2020 to request for the status of the claim, but Mr Tan inform us that our application still in queue to be process due to large volume of application and the closure of MPOCC office due to MCO. Our management has queried on delay of the claim and we as sustainability officer unable to explain to our management since we dont't know the progress of the claim and it's hard for us to convince our management to continue doing the surveillance audit. So, we would like to suggest if MPOCC can create any system for the companies to monitor on the progress of the claim. We hope that MPOCC can revert on this matter as soon as possible. Thanks.	submitted	\N	3d06ba74-5af0-499d-81fa-6a61febaa57d	\N	\N		f	\N	68	nuramsconsultant@gmail.com
206	2024-12-03 18:25:46+00		f	Non-compliance of national laws and regulations	ADUAN RISWAN RASID (18 NOVEMBER 2024)_GOLDEN AGRO PLANTATION	 	\N	b39a982d-4071-461c-b83d-d1d1293bd3bb	709	\N		f	45	206	Riswanrasid@gmail.com
101	2021-03-05 23:34:41+00		f	Others	Good day. I have tried to upload the  monthly FFB declaration since 2/3/2021 but until today, I still cannot upload the FFB data. I thought the internet line might not working then i tried other internet option which is quite fast (during that time I can download a bigger size file using the line) but did not worked. Previously, I do not have any of these problem. Thank you.	submitted	\N	c0c0c1da-11f3-4065-aa98-82084870eea4	\N	\N		f	\N	101	aldosualin@gmail.com
90	2020-08-22 10:06:17+00		f	Others	HI ADMIN, I CANT REGISTER SOME ESTATES WHICH ALREADY MSPO CERTIFIED IN THE IT PLATFORM. FOR AN EXAMPLE, COMPANY NAME : UNITED GANDA PLANTATION SDN BHD ARE CERTIFIED ESTATE BUT I CANT REGISTER AT CERTIFIED ENTITY. 	submitted	\N	d0e4fb36-fb0a-4767-a333-531cbb37e035	\N	\N		f	\N	90	sriganda2003@gmail.com
91	2020-08-27 14:26:16+00		f	Others	Unable to update certification status on MSPO Trace platform (please refer to attachment)	submitted	\N	cedde969-4985-499b-a05c-5325099bf7aa	\N	\N		f	\N	91	goldenelate.pom@gmail.com
117	2021-08-20 16:32:17+00		f	MSPO Trace	Unable to upload single line item CPO / PK dispatch using templete. In the event there is only 1 trip of barge serving 1 contract to 1 buyer, there is an error message unable to upload templete file with single line item.	submitted	\N	80708127-7fdf-4c9d-8b6f-315c374c0cf4	\N	\N		f	\N	117	kyting@jayatiasa.net
138	2022-04-14 09:08:03+00		f	Others	test test test test	submitted	\N	4d6dc0fa-8a2f-4073-9bbd-85425124beb0	\N	\N		f	\N	138	leo_gee87@yahoo.com
144	2022-05-20 18:22:36+00	Translation and interpretation	f	Others	Sarananas Enterprise SDN. BHD company trespassing and carrying out large-scale oil palm cultivation activities on Bumiputera Customary Rights Land (NCR) of the Melanau Community and the Iban Community from Sungai Ilas, Batang Igan. Sibu.	submitted	\N	34e9281c-a3b1-412d-ba7e-fe29dad024c9	\N	\N		f	\N	144	mateksadiahq@gmail.com
145	2022-05-24 14:18:35+00		f	Non-compliance of national laws and regulations	test test test test test test test test test test test test test	submitted	\N	8d6c1385-fa01-48c7-b761-4e0ebdcab162	\N	\N		f	\N	145	hello@bliss.com
146	2022-05-27 10:14:55+00		f	MSPO Trace	We had case where we cant identify different supplier for the same name. The supplier company got several collecting centre and had different MPOB license with different location , but shared the same entiti name. so when we tried to register non certified supplier with different mpob number, unfortunately we cant register the name because it was already registered. 	submitted	\N	d8b08679-718a-49dc-a81d-141d5a5b048d	\N	\N		f	\N	146	sustainabilitypr.ppom@gmail.com
148	2022-05-30 12:13:23+00		f	Non-compliance of national laws and regulations	Dear Sir/Madam,\n\nRe : Grievance against Sawira Sdn Bhd\n\nI was hired by Sawira Sdn Bhd as General Manager on the 8th Feb 2021 with two years duration contract basis.\n\nSince January 2022, I had felt that the management had been ignoring me and the head office started directly dealing with my Estate Managers.\n\nAround this time, or in December 2022, the company staff had joined the union AMESU and I had brought the matter to the management via an email to the Group HR Manager which had no reply at all. Following which, I had in January 2022 submitted a staff salary revision scale in accordance to industrial standards range to the company and again I did not receive any reply from Group HR Manager who had later resigned in Feb 2022. Subsequent to this since March 2022, I am now being placed in cold storage, at Common Ground Office, Mont Kiara, Kuala Lumpur and I am made to only write company SOPs. I believe the joining of the staff with the Union could be a reason why I am being treated by the company unfairly though they have denied it.\n\nI had been instructed by my immediate superior that my managers no longer will report to me and I am not allowed to speak to anyone including suppliers, vendors, etc related to Sawira Sdn Bhd or its operational management. I am being told that I cannot even leave the Common Ground Office at Mont Kiara, Kuala Lumpur without prior permission including not allowed to go or visit the plantation estates unless otherwise instructed so. \n\nI have written three letters to the company questioning the company’s action and reason (attached herewith). First letter dated 6th April 2022, they replied saying due to my health reason and that its for my own good they decided so. To this I must say, they are merely making-up this as an excuse to me as I have no serious health concerns for the company to do so. I have replied denying that I have any health issues as so claimed by the company and no doctors had given me any unfit to work status.\n\nOn my second letter again sent on the April 2022 dated 15th April 2022, the company HR replied that on their record I am still the General Manager of Sawira Sdn Bhd and that the task of writing the SOPs is linked at their digitalization program that the company is undertaking. Following which, I had replied again (third letter dated 6th May 2022), stating that, I am willing to do a full medical check up if the company had any concerns on my health and that otherwise, if I am considered the General Manager of Sawira, I should be allowed to return back to my company’s resident house at Ladang Sawira Utara at Muadzam Shah, Pahang and that all my authorities and powers as General Manager should be reinstated as normal. I am yet to receive a reply from the company and hence I am reporting this to MSPO as my grievance against the company for their unfair treatment given to me.\n\nI am feeling that the company is deliberately forcing me to resign by humiliating me and ignoring me making me feel unwanted or required. \n\nI am placed in KL office at Co-shared office sitting at the Lobby (though after my first complain they did try to give another isolated open space sitting arrangement that is totally improper for a company GM) and only made to write SOPs and to-date since I am here, I am not even being called for any meetings or discussion. I am also been denied attending meetings representing the company with AMESU and any email response/reply from the company on AMESU matter is hidden from me, and including all company operational matters are directly communicated to the Estate Managers and staff without my knowledge.\n\nTrust that MSPO will look into my grievance and will stop this unfair treatment to myself and also ensure that the company look into the staff salary revision and their welfare as per AMESU and industrial practices. \n\nLastly, as a point to note, MSPO should also investigate the company on foreign workers matters particularly the Bangladesh workers on why many had run away or returned back to their home country recently. This can have a serious consequence on our image of palm oil industry and Malaysia at large if it comes out later in the open. I am stating this matter here, as I have no part or role whatsoever to any ill treatment of foreign workers at Sawira Sdn Bhd should the matter comes out or be expose during the coming MSPO audit. As the General Manager, I have been denied the power to investigate, resolve or act on the matter accordingly at that time. \n\nThank you \n\nRavindran Veerasamy\n\nHp: 0125575446\n\n \n\nEvidences on foreign  workers abuse available via photo and videos for further investigation	submitted	\N	4e33cfac-f5fe-4c35-9861-84d7917606ae	\N	\N		f	\N	148	rveerasa@hotmail.com
160	2022-12-09 12:19:16+00	Translation and interpretation	f	Non-compliance to MSPO Certification Scheme	Non compliance to principal 3 MSPO standard	submitted	\N	bdbfe7f9-be3d-45db-9e74-0bafc00e3da8	\N	\N		f	\N	160	rudy_patrick@ymail.com
169	2023-03-18 11:03:25+00		f	MSPO Trace	ALWAYS LOG OUT BY ITSELF, AFTER THAT can't LOG IN AGAIN, HAVE TO USE ANOTHER CHROME TO LOG IN, PLEASE FIX IT, TROUBLESOME	submitted	\N	24d8cbc0-b247-4c06-bd71-80c775c228f0	\N	\N		f	\N	169	solidorient2812@gmail.com
170	2023-05-04 10:16:57+00	Translation and interpretation	f	Others	LAPORAN PENCEROBOHAN TANAH SIMPANAN JALAN LAMA SANDAKAN KAMPUNG KITAGAS BATU 27 SANDAKAN	submitted	\N	c03ad22a-b91d-4788-9b2e-d4e016651a9b	\N	\N		f	\N	170	jasrsb@gmail.com
178	2023-05-23 15:11:49+00		f	Others	I would like to know status subsidiary MSPO Certificate of Chin Bee Plantations Berhad 	submitted	\N	0492f0e6-5805-44af-aa74-4db0c77a4140	\N	\N		f	\N	178	cbpb860009@gmail.com
179	2023-05-26 12:29:01+00		f	Others	I HAVE PROBLEM WITH LOGIN INTO MSPO TRACE, PLEASE HELP ME ON THIS MATTER. EVERYTIME I TRY TO LOGIN THE ERROR SHOW SUSPENDED FOR 5 MINUTES BECAUSE OF TOO MANY ATTEMP. THIS SHOW EVEN ONLY 1 TIME TRYING TO LOGIN.	submitted	\N	6a07ae1f-58b7-49a3-b140-407f7039c517	\N	\N		f	\N	179	mages@op.shh.my
181	2023-08-11 18:47:12+00		f	Non-compliance of national laws and regulations	tidak patuh dengan Akta bekalan elektrik 1990 dan peraturan-peraturan 1994.	submitted	\N	4120635d-c542-437d-9cea-9319b2338db0	\N	\N		f	\N	181	allariff@st.gov.my
37	2020-03-21 09:18:30+00	Translation and interpretation	f	Not in the list of MSPO & SCCS Trace	With respect to the above, please be informed that Tee Teh Palm Oil Mill [Pahang Region] has been awarded the MSPO Part 4 and MSPO SCCS certificates on 30/12/2019 under the accredited certification company, Global Gateway Certification Sdn Bhd on 11/11 / 2019 - 15/11/2019 led by En. Muhammad Syafiq B. Abd Razak. Attached herewith is the proof of MSPO Part 4 and MSPO SCCS certificates that has been awarded to us by the certification company. Thank you for your kind attention.	submitted	\N	0919a2be-3b19-418f-91e8-ae8a8ffd3e48	\N	\N		f	\N	37	baxteraymond@gmail.com
64	2020-08-05 14:12:26+00	Translation and interpretation	f	Others	testing testing testing testing testing	submitted	\N	4d6dc0fa-8a2f-4073-9bbd-85425124beb0	\N	\N		f	\N	64	leo_gee87@yahoo.com
192	2024-03-09 13:04:46+00		f	MSPO Trace	Kilang Kelapa Sawit kami telah menerima pembekal buah (Estate Luar) yang memiliki 5 entiti ; 4 entiti yang mempunyai Pensijilan MSPO dan 1 entiti yang tidak memiliki Pensijilan MSPO. Entiti yang tidak memiliki Pensijilan MSPO ini merupakan syarikat yang baru sahaja bertukar pengurusan dan ianya masih dalam proses pertukaran nama. Pembekal buah tersebut telah memberikan lesen MPOB yang baharu. Pihak kami ingin mendaftarkan entiti tersebut di dalam NON-CERTIFIED. Namun, MPOB lesen tersebut di bawah nama entiti yang telah memiliki Pensijilan MSPO. Hal ini menyukarkan kami untuk menghantar laporan MSPO Trace. Pihak kami telah mengajukan laporan melalui e-mel (info@mpocc.org.my, info@mspotrace.org.my, dan emu@mpocc.or)	submitted	\N	cedde969-4985-499b-a05c-5325099bf7aa	\N	\N		f	\N	192	goldenelate.pom@gmail.com
196	2024-05-27 21:15:43+00		f	Non-compliance to MSPO Certification Scheme	I have been as a freelancer MSPO audtor at CARE CERTIFICATION INTERNATIONAL since 2019 and lasted until May 2024.\n\n\n\nHowever, I didn't receive documented contract employment for my work since 2020. I have contacted CCI top management regarding this issue, however, no response. \n\n\n\nNow, my job at CCI have been discontinued suddenly this month. Since I have no documented evidence to show and protect my rights as a freelancers. I have lost my income in an instant.\n\n\n\nTo make it worse, All other freelancers also dont't have any sorts of documented evidence employment. Ifear the worst for them in the future. \n\n\n\nPlease investigate this case. \n\n\n\nThank you \n\n\n\n	submitted	\N	77580fe9-7ac2-4fb0-9aa7-06995f768dea	\N	\N		f	\N	196	rizal1976@gmail.com
104	2021-04-29 03:48:10+00	Translation and interpretation	f	Non-compliance to MSPO Certification Scheme	Based on latest MSPO supply chain certificate by BSI Services Sdn Bhd, the latest MSPO SCCS certificate number is MSPO 727219, however the certificate number registered number is MSPO IT platform which is MSCC-005-88. We need your assist to change certificate number to MSPO 727219	submitted	\N	c3430ef8-bea7-4d77-840d-7e1847682f45	\N	\N		f	\N	104	gmm@ioigroup.com
141	2022-04-15 08:13:24+00		f	Others	I fill this in this form as requested by u, I have email to CEO MPOCC in January 2022	submitted	\N	14e4c67b-bcde-4704-a97f-0dcbe1717dc5	\N	\N		f	\N	141	whistlecert@gmail.com
168	2023-02-25 09:27:58+00		f	Non-compliance to MSPO Certification Scheme	Detected open burning in PKNP’s Ladang Tembeling in Pahang.	submitted	\N	e6dae6f9-e483-4071-923d-095f173ed23e	\N	\N		f	\N	168	dylan.j.ong@gmail.com
180	2023-06-21 11:58:16+00	Translation and interpretation	f	Non-compliance to MSPO Certification Scheme	Lamp\t:\t\t\t\t\t\t\t    Lubuk Gaung, 21 Juni 2023\n\nHal\t: Pengaduan\n\n\n\nKepada YTH\t\t\t\t\t                 \n\nMSPO\n\nDI\n\n    Tempat\n\nBeriring salam dan do’a semoga Bapak/Ibu dalam keadaan sehat wal afiat dalam menjalankan aktifitas sehari-hari dan senantiasa dilindungi oleh Tuhan YME. Amin.\n\nMengingat, Lingkungan hidup adalah kesatuan ruang dengan semua benda, daya, keadaan dan mahluk hidup, termasuk manusia dan perilakunya, yang mempengaruhi alam itu sendiri, keberlangsungan hidup, dan kesejahteraan manusia serta mahluk hidup lain. Bahwa lingkungan hidup yang baik dan sehat merupakan hak asasi setiap warga Negara Indonesia sebagaimana diamanatkan dalam Pasal 28H UUD RI Tahun 1945. Bahwa pembangunan ekonomi nasional sebagaimana diamanatkan oleh Undang-undang Dasar Negara Republik Indonesia Tahun 1945 diselenggarakan berdasarkan prinsip pembangunan berkelanjutan dan berwawasan lingkungan.\n\n\n\nHak atas lingkungan hidup yang baik dan sehat telah dilindungi dalam Konstitusi Undang-Undang Negara Republik Indonesia Tahun 1945.  Setelah amandemen, ketentuannya dirumuskan dalam Pasal 28H ayat (1) yang menegaskan:\n\n”setiap orang berhak hidup sejahtera lahir dan batin, bertempat tinggal dan mendapatkan lingkungan hidup yang baik dan sehat serta berhak memperoleh pelayanan kesehatan”.\n\nMemberitahukan kepada Bapak/Ibu bahwa PLTU Batubara PT. Sari Dumai Sejati (Apical Group) suara bisingnya, debunya, baunya sangat menganggu dan meresahkan kami, itu sudah berlangsung lama dan kami sudah mengadukan hal tersebut kepada pihak terkait yaitu PT. Sari Dumai Sejati (Apical Group) dan Dinas Lingkungan Hidup tapi tidak ada repon dan iktikad baik dari perusahaan untuk mencarikan solusi permanen bagi warga terdampak PLTU Batubara tersebut.\n\nMengingat Apical Group yang tergabung dari beberapa perusahaan dalam menjalankan beberapa perusahaannya sangat merugikan dan mengancam kehidupan di darat laut dan udara baik itu manusia, hewan dan tumbuh-tumbuhan pada saat ini dan yang akan datang. PT. Sari Dumai Sejati (Apical Group) merupakan kawasan Objek Vital Nasional berdekatan dengan lingkungan penduduk dalam aktivitasnya sangat menganggu dan meresahan warga sekitar terutama yang berdekatan dengan kawasan industri.\n\nSeharusnya pembangunan perusahaan berwawasan lingkungan berkelanjutan dan memikirkan dampak negatif dari pembangunan PLTU Batubara, memberikan rasa aman, tentram dan damai bukan sebaliknya. PLTU Batubara dibangun terlalu dekat dekat dengan pemukiman selalu menimbulkan masalah.\n\nKami sebagai warga meminta keadilan untuk hidup sehat, tenang, aman dan damai. Tolong kembalikan kehidupan kami seperti sebelum PLTU Batubara tersebut ada. kami tidak berhadap di relokasi / atau di beli tanah kami oleh perusahaan atau pihak lain seperti apa yang di isukan perusahaan bahwa kami melakukan aksi damai menolak pencemaran lingkungan hanya semata ingin menjual tanah. Kami hanya ingin hidup sehat, tenang, aman, damai, terbebas dari gangguan PLTU Batubara.\n\nKami berharap perusahaan memegang prinsif dengan Tujuan Pembangunan Berkelanjutan Sustainable Development Goals (SDGs) adalah 17 tujuan global dengan 169 capaian yang terukur dan tenggat yang telah ditentukan oleh PBB sebagai agenda dunia pembangunan untuk perdamaian dan kemakmuran manusia dan planet bumi sekarang dan masa depan.\n\nOleh sebab itu kami sebagai warga masyarakat yang terkena dampak langsung berharap agar Bapak/Ibu bisa memberikan solusi agar perusahaan tidak meresahkan warga masyarakat yang berdekatan dengan perusahaan.\n\nDemikian Surat Pengaduan ini saya buat agar dapat dipergunakan sebagaimana mestinya dan besar harapan atas bantuannya.\n\n\n\n\n\n\n\n\n\n\n\nH I D A Y A T\n\n\n\n	submitted	\N	25c9e59a-dddc-4e8d-9b27-4033d9f1274a	\N	\N		f	\N	180	elink.hidayat@gmail.com
193	2024-03-25 15:55:03+00		f	MSPO Trace	Tidak dapat log in sistem. Kami telah cuba untuk log in banyak kali, tetap sama. Kami juga telah cuba 'forget password' tapi juga gagal untuk log in.	submitted	\N	2fc4583b-c10b-423a-a6fe-a5e25b7bc801	\N	\N		f	\N	193	monsokmill@gmail.com
194	2024-04-08 11:48:43+00		f	MSPO Trace	CANNOT REGISTER NON-MSPO FOR MY DILLER ( B.P. SENGKUANG PLANTATION SDN BHD, MPOB LICENSE NO. 579993001000). ALREADY KEY IN THE MPOB LICENSE BUT THE STATUS SHOW NOT VALID.	submitted	\N	80c123de-90b0-4fd6-9424-1e93e57c96fb	\N	\N		f	\N	194	bintang@bell.com.my
135	2022-03-05 16:26:25+00		f	MSPO Trace	Saya tak boleh click button Confirm utk submit Monthly Declaration	submitted	\N	a0b845cc-2c32-421e-9f3e-ebfe8e22cd15	\N	\N		f	\N	135	spadmukahmill@gmail.com
202	2024-07-12 15:52:00+00		f	Others	Ladang Kok foh tanam bahan buangan dlm kawasan ladang	submitted	\N	b37636b3-8be1-4178-9cf2-8b57f5394441	\N	\N		f	\N	202	vendettavendetta326@gmail.com
207	2025-01-02 15:52:27+00		f	MSPO Trace	Testing for Compliance Functionality	submitted	\N	9899069d-e0c6-4dec-b3cd-e4080a838f61	\N	\N		f	\N	207	aireimail24@gmail.com
210	2025-02-04 09:13:55+00		f	Others	Investigation Request Regarding the Palm Oil Plantation Organizations &amp; Competency of Auditor \n\nOrganization Name and Address: FIRST BINARY PLANTATION (869696-M)\n\nNo.36, 3rd Floor, Jalan Keranji, 96000 Sibu, Sarawak\n\nEstate Address/Location: Lot 3, Stungkor Land District, Lundu, Sarawak\n\nAudit Reference Standards: MS2530-3\n\nCertification Body: DIMA\n\nIt has been found that the MSPO certification granted to the organization as mentioned above is inappropriate. This is because the organization does not meet the mandatory criteria outlined for MSPO certification compliance. Awarding the certification has provided the organization, especially the upper management, with greater opportunities to exploit and neglect the lower workers, particularly foreign workers. This is because the certification was granted despite the organization failing to comply with or meet the mandatory criteria required for certification.\n\nBelow are examples of the neglect and exploitation carried out by this organization:\n\n1. Exploitation and Neglect in Terms of Worker Benefits (Accommodation, Safety):\n\nThe workers' accommodation does not meet the minimum requirements set by the Workers' Housing Act. Workers are not provided with adequate personal safety equipment.\n\n2. Exploitation and Neglect in Terms of Foreign Worker Salaries:\n\nWorkers are not paid in cash. Their salaries are kept by the management and are only given to the workers when they return to their home country.\n\n3. Exploitation and Neglect of Social Responsibility to the Surrounding Community:\n\nThe organization neglects its social responsibility toward the local community.\n\n4. Exploitation and Neglect of Compliance with Environmental Protection Requirements:\n\nThe most notable issue is the lack of efforts to establish a &quot;Buffer Zone,&quot; which is a mandatory environmental compliance requirement.\n\n5. Neglect of Other Mandatory Compliance Requirements:\n\nThe organization has continuously failed to meet other basic mandatory compliance standards and has shown no consistent effort to make improvements.\n\nThe organization has also violated the core principles of MSPO, which are the 3 P's (Profit, People, Planet). The organization is solely focused on &quot;Profit,&quot; deliberately neglecting &quot;People&quot; and &quot;Planet.&quot;\n\nTherefore, it is requested that the relevant authorities review this report and immediately conduct an investigation into this organization and the parties involved in the certification process. This is due to concerns that the certification body and the auditors may also lack competence in this matter. It is unjust to those organizations that have worked diligently and invested significant resources to obtain the certification, but due to the greed of certain organizations and auditors, this leads to dissatisfaction among those who are genuinely following the proper procedures.\n\nIf this situation continues or becomes public, it is believed that it will have a significant negative impact on the credibility of the certification bodies and auditors involved. Specifically, MSPO may also face backlash, damaging its public image. Thank you.	submitted	\N	9bfb750a-2c2d-4bfc-9999-44fdabda74dd	\N	\N		f	\N	210	kheongsc83@gmail.com
200	2024-06-09 23:55:47+00		f	Non-compliance of national laws and regulations	To whom it may concern, I would like to inform you that I have conducted several MSPO Audit for Care Certification International for the past few months. I have conducted the audit and completed the reports as required. I have submitted the invoice to CCI for my job claim. However, after almost more than one month, I didn't receive any payment. My payment terms are 30 days. Someone at CCI has informed me that the company doesn't want to pay me for my work. The pending payment amount is around 10,000 ringgit. This issue has disturbed my financial situation. Attached herewith is the relevant invoice combined for your reference (Invoices 344, 345, and 346). Please advice. Thank you.	submitted	\N	77580fe9-7ac2-4fb0-9aa7-06995f768dea	\N	\N		f	\N	200	rizal1976@gmail.com
203	2024-07-20 08:03:12+00		f	Non-compliance to MSPO Certification Scheme	By way of background, we, Mukah Kilang Kelapa Sawit Sdn. Bhd. had diverted our FFBs to Sarawak Plantation Agriculture Development Sdn. Bhd. (hereinafter referred to as SPAD) during mill’s breakdown and the FFBs diversion was from 22/05/2024 to 25/05/2024. \n\n\n\nOn 15/06/2024, we wrote to SPAD to express our grievance regarding the arbitrary OER deduction of 1.25% by SPAD. However, as of our official complaint to MSPO on 20/07/2024, SPAD has failed to provide any meaningful written response despite our follow-ups on 21/06/2024, 02/07/2024, and 12/07/2024.\n\n\n\nWe understand that SPAD might want to argue that the OER deduction was made in accordance with MPOB’s guideline. However, we wish to bring your attention to Clause 4.1.3 of Manual Penggredan Buah Kelapa Sawit MPOB which read “Asing dan keluarkan semua Tandan Muda dan Tandan Peram daripada konsainan dan pulangkan kepada pembekal”.\n\nBased on SPAD’s grading form, there were Tandan Muda in all of our consignments, but none of the purported Tandan Muda were returned to us. This is because the parties have a mutual understanding that FFBs found to be of poor quality and not acceptable by SPAD would be returned to us upon completion of grading instead of deducting the pre-determined OER.\n\nAs such, we wish to bring to your attention that SPAD has failed to comply with the following indicators under Malaysian Sustainable Palm Oil (MSPO) 2530:2013\n\n4.6.3.1 \tPricing mechanisms for the products and other services shall be documented and effectively implemented. \n\n\n\n4.6.3.2 \tAll contracts shall be fair, legal and transparent and agreed payments shall be made in a timely manner.	submitted	\N	86c5fd15-a47d-44b9-94f9-864b787d7db8	\N	\N		f	\N	203	foong9626@gmail.com
197	2024-05-29 00:05:14+00		f	Non-compliance to MSPO Certification Scheme	To whom it may concern:.\n\nI hereby would like to make a report. \n\nCare Certification International (CCI) has conducted several MSPO audits using auditor personnel who are not qualified as MSPO auditors.\n\nOne of the auditors, Nurul Afnie, has conducted several MSPO Audit versions of MS 2530-3:2013 MSPO Part 3. \n\nHowever, she didn't attend any MSPO Auditor course (MPOCC-endorsed) prior to the audit. \n\n\n\nI have verbally voicing out this issue to CCI management, but there has been no response. \n\n\n\nI hereby attach a sample of the audit documents for your kind perusal. \n\n\n\nThank you.\n\n	submitted	\N	77580fe9-7ac2-4fb0-9aa7-06995f768dea	\N	\N		f	\N	197	rizal1976@gmail.com
155	2022-10-14 17:06:43+00		f	MSPO Trace	Berkenaan pendaftaran pembekal iaitu : Sen Heng Plantation Sdn Bhd, pembekal ini adalah 'certified'. Walaubagaimanapun, nama pembekal itu tiada dalam carian 'MSPO Certified Supplier'. Mohon tindakan lanjut daripada pihak tuan/puan. Terima kasih.	submitted	\N	2fc4583b-c10b-423a-a6fe-a5e25b7bc801	\N	\N		f	\N	155	monsokmill@gmail.com
189	2024-01-19 14:59:36+00		f	Others	MSPO SCCS certificate validity. Kindly justify the validity of a certificate which effective date & recertification date is not stated. Can palm oil mill sell CPO/kernel to the certificate holder if the buyer do not hold a valid MSPO SCCS certificate?	submitted	\N	4838f267-e471-42c2-960a-afb1bbe50dd5	\N	\N		f	\N	189	ongtp@gtsr.com.my
190	2024-02-14 08:24:29+00		f	MSPO Trace	Good morning, regarding to the attached file, it shows that section C cannot appear anything that I have key in to the system even though I already upload the template. So that, after I click Button Finish there are also nothing save in system. So that i hope your site can help me to settle the problem.TQ	submitted	\N	4735ce34-ed6c-4b84-a258-c098689ca12f	\N	\N		f	\N	190	wtkalpha@gmail.com
199	2024-06-06 15:52:51+00		f	Non-compliance of national laws and regulations	Complaint regarding the failure of local oil palm company/developer to comply with MSPO standard, practices and good ethics.	submitted	\N	1d351dae-d3b7-476d-9c6a-c3851e6117f8	\N	\N		f	\N	199	loureschristiansen@gmail.com
201	2024-06-14 16:15:23+00		f	Others	Non-compliance to MSPO Certification Scheme (Principal 3 & Principal 4 - HVC). Non-compliance of cultural regulations	submitted	\N	e5871981-e66c-4c44-9183-0e8084e874c9	\N	\N		f	\N	201	luangbadol@gmail.com
209	2025-01-16 18:41:39+00	Translation and interpretation	f	Others	Dear Sir/ Madam, \n\nI, Rajendran A/L Subramanian (651110-08-5551) would like to complaint regarding the wrongly positioned &amp; constructed ditch (Parit) which falls on my land Plot No: 13208. This ditch (Parit) is supposed to be constructed on the given Reserved space (Simpanan Jalan). But the reserved space (Simpanan Jalan) already utilized for their oil palm plantation and there is no access road for my land Plot No: 13206-13208. This problem is caused by the owner of Plot No: 10471 (Maju Melintang Estate). \n\nFor your kind information, I have already discussed with the General Manager of Maju Melintang Estate Mr. Kagenthiran regarding the issue above. But no any positive actions were taken so far.\n\nPlease find the attached PELAN PINTA UKUR KELILING/PERIMETER for your reference.\n\nI hope for a favorable reply &amp; action from you as soon as possible. Please do not hesitate to contact me if required any further information or for discussion. \n\n\n\nThank you,\n\nMr.Rajendran,\n\nPhone number: 0195706090.	submitted	\N	e24e82c5-482d-44c5-95e4-0dec79afeffc	\N	\N		f	\N	209	spnrajendran@gmail.com
212	2025-02-12 09:35:51+00		f	Non-compliance to MSPO Certification Scheme	We received the matters from Nestle Malaysia as per email dated 7.2.2025 and email replied to them on 12.2.2025	submitted	\N	ad892dc0-1949-48b7-be5e-d63c7290e512	\N	\N		f	\N	212	hasbollah@mspo.org.my
198	2024-06-04 22:12:09+00		f	Non-compliance to MSPO Certification Scheme	Dear Sir. I would like to make a  report. I hereby would like to inform you that Care Certification International didn't conduct several MSPO audit according to MSPO OPMC requirements, where the audit was conducted without sufficient Mandays as required. Among the audited client involved are,  1) MSPO Part3 SAV4 - OIB Properties Group: 2 person per days for site more than 100 hectares 2) MSPO Part 3 MAV- Felda Gugusan Bukit Sagu: Only Two auditors per site for estate sized more than 500 hectares. 3) MAV MSPO Part 3 - FELDA Gugusan Serting Hilir: 3 auditors for each site that is more than 500 hectares. To make it worse, One of the auditors team (Nurul Afnie) in OIB Properties Group and FELDA Gugusan Serting Hilir are not competent to conduct OPMC 2013. She didn't attended MSPO 2013 Auditor course, but also calculated int the mandays. I have raise my concern to CCI management regarding this issue, but not response. This issue does not limited to only this 3 sites but in many occasions. Attached herewith one audit sample report for your kind perusal. Thank you.	submitted	\N	77580fe9-7ac2-4fb0-9aa7-06995f768dea	\N	\N		f	\N	198	rizal1976@gmail.com
204	2024-08-28 17:15:48+00		f	Non-compliance of national laws and regulations	To obtain a MSPO certificate do I need a legal document such as land title or land under Section 18 of Sarawak Land Code; or customary tenure (communal forest) or use rights (as stated in the land gazettment).	submitted	\N	26e06765-0726-4760-a956-cd6c133c8cf1	\N	\N		f	\N	204	yakboy02@gmail.com
208	2025-01-02 18:12:57+00	Translation and interpretation	f	Non-compliance to MSPO Certification Scheme	it was found that the farm planted scheduled waste materials and poisoned the HCV area.	submitted	\N	97f7ac1a-aaf7-4061-8dba-cef646b37a3b	\N	\N		f	\N	208	mohamadmat921231@gmail.com
211	2025-02-05 21:55:08+00		f	Others	My complaint as per attachment	submitted	\N	fc2ca455-d9cb-44de-a313-e5f66f65a688	\N	\N		f	\N	211	ussepudun2050@gmail.com
\.


--
-- Data for Name: summary; Type: TABLE DATA; Schema: public; Owner: -
--

COPY public.summary (id, created_at, hide, accused, complaint_id, complaint_date, summary, prev_complaint_id) FROM stdin;
4	2023-08-11 18:47:12+00	t	Non-compliance of national laws and regulations	181	2023-08-11	tidak patuh dengan Akta bekalan elektrik 1990 dan peraturan-peraturan 1994.	181
12	2025-02-12 09:35:51+00	t	Non-compliance to MSPO Certification Scheme	212	2025-02-12	We received the matters from Nestle Malaysia as per email dated 7.2.2025 and email replied to them on 12.2.2025	212
9	2024-11-21 20:23:05+00	t	MSPO Trace	205	2024-11-21	Complaints checking	205
5	2023-08-26 10:51:40+00	t	MSPO Trace	184	2023-08-26	DATA SUPPLIER TIDAK BOLEH DIEDIT	184
131	2023-08-17 10:28:12+00	t	Non-compliance to MSPO Certification Scheme	183	2023-08-17	In 2019, Cahaya Ikhtiar supplied FFB to our mill. But, after receiving an alert from our buyer (Proter & Gamble), we chose to stop sourcing because they cannot provide EIA for their land development. The attachment is not related to our complaint but shows the company's image.	183
8	2024-06-14 16:15:23+00	t	Others	201	2024-06-14	Non-compliance to MSPO Certification Scheme (Principal 3 & Principal 4 - HVC). Non-compliance of cultural regulations	201
3	2023-06-21 11:58:16+00	t	Non-compliance to MSPO Certification Scheme	180	2023-06-21	Lamp\t:\t\t\t\t\t\t\t    Lubuk Gaung, 21 Juni 2023\n\nHal\t: Pengaduan\n\n\n\nKepada YTH\t\t\t\t\t                 \n\nMSPO\n\nDI\n\n    Tempat\n\nBeriring salam dan do’a semoga Bapak/Ibu dalam keadaan sehat wal afiat dalam menjalankan aktifitas sehari-hari dan senantiasa dilindungi oleh Tuhan YME. Amin.\n\nMengingat, Lingkungan hidup adalah kesatuan ruang dengan semua benda, daya, keadaan dan mahluk hidup, termasuk manusia dan perilakunya, yang mempengaruhi alam itu sendiri, keberlangsungan hidup, dan kesejahteraan manusia serta mahluk hidup lain. Bahwa lingkungan hidup yang baik dan sehat merupakan hak asasi setiap warga Negara Indonesia sebagaimana diamanatkan dalam Pasal 28H UUD RI Tahun 1945. Bahwa pembangunan ekonomi nasional sebagaimana diamanatkan oleh Undang-undang Dasar Negara Republik Indonesia Tahun 1945 diselenggarakan berdasarkan prinsip pembangunan berkelanjutan dan berwawasan lingkungan.\n\n\n\nHak atas lingkungan hidup yang baik dan sehat telah dilindungi dalam Konstitusi Undang-Undang Negara Republik Indonesia Tahun 1945.  Setelah amandemen, ketentuannya dirumuskan dalam Pasal 28H ayat (1) yang menegaskan:\n\n”setiap orang berhak hidup sejahtera lahir dan batin, bertempat tinggal dan mendapatkan lingkungan hidup yang baik dan sehat serta berhak memperoleh pelayanan kesehatan”.\n\nMemberitahukan kepada Bapak/Ibu bahwa PLTU Batubara PT. Sari Dumai Sejati (Apical Group) suara bisingnya, debunya, baunya sangat menganggu dan meresahkan kami, itu sudah berlangsung lama dan kami sudah mengadukan hal tersebut kepada pihak terkait yaitu PT. Sari Dumai Sejati (Apical Group) dan Dinas Lingkungan Hidup tapi tidak ada repon dan iktikad baik dari perusahaan untuk mencarikan solusi permanen bagi warga terdampak PLTU Batubara tersebut.\n\nMengingat Apical Group yang tergabung dari beberapa perusahaan dalam menjalankan beberapa perusahaannya sangat merugikan dan mengancam kehidupan di darat laut dan udara baik itu manusia, hewan dan tumbuh-tumbuhan pada saat ini dan yang akan datang. PT. Sari Dumai Sejati (Apical Group) merupakan kawasan Objek Vital Nasional berdekatan dengan lingkungan penduduk dalam aktivitasnya sangat menganggu dan meresahan warga sekitar terutama yang berdekatan dengan kawasan industri.\n\nSeharusnya pembangunan perusahaan berwawasan lingkungan berkelanjutan dan memikirkan dampak negatif dari pembangunan PLTU Batubara, memberikan rasa aman, tentram dan damai bukan sebaliknya. PLTU Batubara dibangun terlalu dekat dekat dengan pemukiman selalu menimbulkan masalah.\n\nKami sebagai warga meminta keadilan untuk hidup sehat, tenang, aman dan damai. Tolong kembalikan kehidupan kami seperti sebelum PLTU Batubara tersebut ada. kami tidak berhadap di relokasi / atau di beli tanah kami oleh perusahaan atau pihak lain seperti apa yang di isukan perusahaan bahwa kami melakukan aksi damai menolak pencemaran lingkungan hanya semata ingin menjual tanah. Kami hanya ingin hidup sehat, tenang, aman, damai, terbebas dari gangguan PLTU Batubara.\n\nKami berharap perusahaan memegang prinsif dengan Tujuan Pembangunan Berkelanjutan Sustainable Development Goals (SDGs) adalah 17 tujuan global dengan 169 capaian yang terukur dan tenggat yang telah ditentukan oleh PBB sebagai agenda dunia pembangunan untuk perdamaian dan kemakmuran manusia dan planet bumi sekarang dan masa depan.\n\nOleh sebab itu kami sebagai warga masyarakat yang terkena dampak langsung berharap agar Bapak/Ibu bisa memberikan solusi agar perusahaan tidak meresahkan warga masyarakat yang berdekatan dengan perusahaan.\n\nDemikian Surat Pengaduan ini saya buat agar dapat dipergunakan sebagaimana mestinya dan besar harapan atas bantuannya.\n\n\n\n\n\n\n\n\n\n\n\nH I D A Y A T\n\n\n\n	180
7	2024-06-06 15:52:51+00	t	Non-compliance of national laws and regulations	199	2024-06-06	Complaint regarding the failure of local oil palm company/developer to comply with MSPO standard, practices and good ethics.	199
6	2024-05-29 00:05:14+00	t	Non-compliance to MSPO Certification Scheme	197	2024-05-29	To whom it may concern:.\n\nI hereby would like to make a report. \n\nCare Certification International (CCI) has conducted several MSPO audits using auditor personnel who are not qualified as MSPO auditors.\n\nOne of the auditors, Nurul Afnie, has conducted several MSPO Audit versions of MS 2530-3:2013 MSPO Part 3. \n\nHowever, she didn't attend any MSPO Auditor course (MPOCC-endorsed) prior to the audit. \n\n\n\nI have verbally voicing out this issue to CCI management, but there has been no response. \n\n\n\nI hereby attach a sample of the audit documents for your kind perusal. \n\n\n\nThank you.\n\n	197
2	2021-07-08 03:15:17+00	t	Others	108	2021-07-08	Test test test test	108
1	2020-08-27 14:26:16+00	t	Others	91	2020-08-27	Unable to update certification status on MSPO Trace platform (please refer to attachment)	91
58	2020-08-22 10:06:17+00	t	Others	90	2020-08-22	HI ADMIN, I CANT REGISTER SOME ESTATES WHICH ALREADY MSPO CERTIFIED IN THE IT PLATFORM. FOR AN EXAMPLE, COMPANY NAME : UNITED GANDA PLANTATION SDN BHD ARE CERTIFIED ESTATE BUT I CANT REGISTER AT CERTIFIED ENTITY. 	90
15	2020-03-21 09:18:30+00	t	Not in the list of MSPO & SCCS Trace	37	2020-03-21	With respect to the above, please be informed that Tee Teh Palm Oil Mill [Pahang Region] has been awarded the MSPO Part 4 and MSPO SCCS certificates on 30/12/2019 under the accredited certification company, Global Gateway Certification Sdn Bhd on 11/11 / 2019 - 15/11/2019 led by En. Muhammad Syafiq B. Abd Razak. Attached herewith is the proof of MSPO Part 4 and MSPO SCCS certificates that has been awarded to us by the certification company. Thank you for your kind attention.	37
14	2020-03-20 14:58:00+00	t	Pemotongan gaji atas kehilangan motorsikal disebabkan kecurian	35	2020-03-20	\n\nSaya ingin membuat laporan utk sebuah syarikat Tetangga Akrab sdn Bhd.\n\nAlamat\n\nLot 8712, no 6, shoplot 11, green height commercial centre,airport road, 93250 kuching sarawak.\n\n\n\nLaporan ini adalah berkaitan tentang.\n\n1. Pemotongan gaji saya sebanyak RM 3000 selama 3 bulan bermula potongan bulan mei 2019 sehingga julai 2019 atas kehilangan motosikal milik syarikat yang dicuri dihadapan rumah saya. Pemotongan dibuat tanpa notis. Untuk pengetahuan pihak tuan, report polis sudah dibuat berkaitan kehilangan tersebut, dan insurance sebanyak rm 3000 sudah juga diterima oleh pihak syarikat, namun tetap membuat pemotongan atas gaji saya.\n\n\n\n2. Gaji minimum tidak dilaksanakan oleh pihak syarikat.\n\n\n\n3. Notis dikeluarkan oleh pihak syarikat utk bekerja hari cuti umum tanpa meminta persetujuan pekerja.\n\n\n\n4. Gaji pekerja dibayar melebihi 7 hari dari selepas bulan tersebut.. Ini adalah laporan yg dibuat pada 5/9/2019 yg lepas kepada JTK namun tiada sebarang tindakan pun kepada syarikat tersebut.. Bersama ini saya lampirkan utk rujukan pihak tuan.	35
13	2020-03-12 17:01:26+00	t	Quality of Audit report	32	2020-03-12	Care Certification International audit report of Jeng Huat Plantations Sdn Bhd (OPMC303257) is misleading.It states and certifies 206.4602 Ha however only gives 1 GPS coordinates where there is 3 separate estates in Mukim Jelai, Mukim Kepis & Mukim Serting Ulu. The CB and CH including technical quality review process also fails to highlight there is only 1 estate map provided in said audit report. Map given is for estate in Mukim Kepis, amounting to only 12 Ha. There is a deficiency in maps amounting to 194 Ha including 2 missing coordinates for estate in Jelai and Serting Ulu. Having only 1 map in the audit report may offer misrepresentation to the reader that the estate in Kepis measures 206.4602 Ha when in fact it doesn't. MSPO and MPOCC needs to buck up on the quality of assessors and reporting as this is not just an isolated incident. Some CBs audit report available on MSPOTrace does not even contain maps (E.g. Transcert, PSV, Prima Cert, Global Gateway)	32
11	2025-02-05 21:55:08+00	t	123 POM	211	2025-02-05	Its related to environmental issues, as per evidence obtained during special audit, therefore this issues to be change from investigate to resolved	211
132	2023-09-05 16:00:14+00	t	Non-compliance to MSPO Certification Scheme	185	2023-09-05	As sent via email \n\n\n\nAndy Hall\n\nMigrant Worker Rights Specialist \n\n+977 (0) 9823486634 (Phone/WhatsApp)\n\nAndyjhall1979@gmail.com (Email)\n\n@atomicalandy (Twitter)\n\nBlog: https://andyjhall.org\n\n\n\n\n\n---------- Forwarded message ---------\n\nFrom: Andy Hall <andyjhall1979@gmail.com>\n\nDate: Tue, 5 Sep 2023 at 12:12\n\nSubject: (Request for MPOCC investigation) Fwd: Request for urgent investigation into unlawful Felda Management Sdn Bhd’s foreign worker recruitment practices\n\nTo: <complaints@mpocc.org.my>\n\nCc: <info@mpocc.org.my>\n\n\n\n\n\nTo: MPOCC\n\n\n\nRequesting your urgent investigation into the below complaint against \n\nFelda Plantation Management Sdn Bhd, as certified by the MSPO.\n\n\n\nI have submitted the complaint to government authorities today also. \n\n\n\nThanks. Kind Regards, Andy Hall \n\n\n\nAndy Hall\n\nMigrant Worker Rights Specialist \n\n+977 (0) 9823486634 (Phone/WhatsApp)\n\nAndyjhall1979@gmail.com (Email)\n\n@atomicalandy (Twitter)\n\nBlog: https://andyjhall.org\n\n\n\n\n\n---------- Forwarded message ---------\n\nFrom: Andy Hall <andyjhall1979@gmail.com>\n\nDate: Tue, 5 Sep 2023 at 11:55\n\nSubject: Request for urgent investigation into unlawful Felda Management Sdn Bhd’s foreign worker recruitment practices \n\nTo: Asri Ab Rahman <asri_a@mohr.gov.my>, <Khusairi@sprm.gov.my>, Mohd. Asri Abd. Wahab <masri@mohr.gov.my>, <jules@sprm.gov.my>, <jim.atipsom@imi.gov.my>, <mapo_tip@moha.gov.my>, <jtksm@mohr.gov.my>, Bahagian D3 JSJ Bukit Aman <atip_d3jsj@rmp.gov.my>, CC: Syuhaida bt Abdul Wahab Zen - SUB(NSO MAPO) <syuhaida@moha.gov.my>, atipsom tf <atipsom.tf@moha.gov.my>, <rhymie@mohr.gov.my>, <fadillah@kpk.gov.my>, <wafi@kpk.gov.my>, <normi.hassan@kpk.gov.my>, <roshiela.rasip@kpk.gov.my>, <misiah@kpk.gov.my>\n\nCc: CBP FORCED LABOR WRO <cbpforcedlaborwro@cbp.dhs.gov>, <BarnesL@state.gov>, FORCED LABOR <ForcedLabor@cbp.dhs.gov>, Joseph D'Cruz <jdcruz@rspo.org>\n\n\n\n\n\nTo: Minister, Ministry of Human Resources   \n\n\n\nTo: Minister, Ministry of Plantation and Commodities\n\n\n\nTo: Malaysian Anti Corruption Commission \n\n\n\nTo: related officials at Ministry of Home Affairs  \n\n\n\nCc: US Embassy, Malaysia \n\n\n\nCc: US Customs and Border Protection, USA  \n\n\n\nTo: RSPO\n\n\n\nColleagues, hope you are well. \n\n\n\nAs attached and below email correspondence, there has been no response forthcoming from Felda Plantation Management Sdn Bhd on the below complaint. \n\n\n\nAs a result of this non response as per my requested timeline from the company, I would hereby request your related government Ministries and agencies to conduct an urgent investigation into Felda Plantation Management Sdn Bhd’s alleged unlawful and unethical foreign worker recruitment practices. In particular, I consider such investigation should look into the alleged use of unlicensed Malaysian companies to conduct recruitment activities, without a JTKSM recruitment license category C, in serious breach of the 1981 Private Employment Agencies Act (Act 246 attached)\n\n\n\nI am concerned of the related governance and corruption implications of these practices also, and attach an example of Ideal Outsource Management Sdn Bhd as one alleged example of illegality and corruption. \n\n\n\nThanks for your urgent and independent investigation into\n\nthese most concerning allegations. \n\n\n\nKindest Regards, Andy Hall \n\n\n\nAndy Hall\n\nMigrant Worker Rights Specialist \n\n+977 (0) 9823486634 (Phone/WhatsApp)\n\nAndyjhall1979@gmail.com (Email)\n\n@atomicalandy (Twitter)\n\nBlog: https://andyjhall.org/\n\n\n\nOn 31 Aug 2023, at 10:46, Andy Hall <andyjhall1979@gmail.com> wrote:\n\n\n\n?Colleagues at FGV/Felda, hope you are well. \n\n\n\nSo could I please kindly\n\nfollow up with Felda on my below emails, sent 6 days ago. I would respectfully request a response from FGV and Felda by the CLOSE OF BUSINESS tomorrow (Friday 1st September), as I think one working week is sufficient to provide a response given the seriousness of the issues here. \n\n\n\nThanks for your continued and engagement and cooperation on these most sensitive of legal and ethical issues facing the company and it's operations at this time. \n\n\n\nKindest Regards, Andy Hall\n\n\n\nAndy Hall\n\nMigrant Worker Rights Specialist \n\n+977 (0) 9823486634 (Phone/WhatsApp)\n\nAndyjhall1979@gmail.com (Email)\n\n@atomicalandy (Twitter)\n\nBlog: https://andyjhall.org/\n\n\n\n\n\n---------- Forwarded message ---------\n\nFrom: Andy Hall <andyjhall1979@gmail.com>\n\nDate: Fri, 25 Aug 2023 at 21:47\n\nSubject: Re: URGENT Worker complaint - Felda/FGV\n\nTo: Ismail Samingin (FELDA) <ismail.s@felda.net.my>, <jtksm@mohr.gov.my>\n\nCc: Ameer Izyanif Bin Hamzah (FGVHB) <ameer.h@fgvholdings.com>, Anthonius Sani (FGVPMSB) <anthonius.s@fgvholdings.com>, Bahagian D3 JSJ Bukit Aman <atip_d3jsj@rmp.gov.my>, CC: Syuhaida bt Abdul Wahab Zen - SUB(NSO MAPO) <syuhaida@moha.gov.my>, Citra Hartati <citra.hartati@rspo.org>, Ian Spaulding <ispaulding@elevatelimited.com>, Izham Mustaffa (FELDA) <izham.m@felda.net.my>, Jeff Bond <jeff.bond@elevatelimited.com>, Joseph D'Cruz <jdcruz@rspo.org>, MAD ZAIDI MOHD KARLI (MPIC) <zaidi@mpic.gov.my>, NURUL HUDA BINTI MOHD ZAINUDIN <nurul@mpic.gov.my>, Nawin Santikarn <nawin.santikarn@elevatelimited.com>, Nurul Hasanah bt. Ahamed Hassain Malim (FGVHB) <hasanah.ahm@fgvholdings.com>, Savitri Restrepo <savitri.restrepo@elevatelimited.com>, Spaulding, Ian <ian.spaulding@lrqa.com>, Wan Kasim Bin Wan Kadir (FGVHB) <wankasim.wk@fgvholdings.com>, Zofia Lawrence <zofia.lawrence@elevatelimited.com>, atipsom tf <atipsom.tf@moha.gov.my>, <azie@mpoc.org.my>,  \n\n<azreen.asnan@feldaglobal.com>, <bel@mpoc.org.my>, <jim.atipsom@imi.gov.my>, <soochin.io@rspo.org>, <wbmaster@mpoc.org.my>\n\n\n\n\n\nIsmail, as below email, I did some further checks, maybe some misunderstanding my side, but I cannot find on the Malaysian government online portal/register most of your Malaysian manpower agencies recruiting workers from Nepal, see online register at  https://jtksm.mohr.gov.my/ms/perkhidmatan/agensi-pekerjaan-swasta/senarai-agensi-pekerjaan-swasta\n\n\n\nAt first glance, it seems many of your Malaysian recruitment agencies are irregular registered Malaysian companies without Malaysian government license or approval (License C) to recruit foreign workers for Malaysian employers. Perhaps  outsourcing companies actually? \n\n\n\nWould welcome clarification here, I highlighted the agencies here below that don’t appear in the Malaysia government licensed manpower agency list but are in FGV/Felda’s list as currently Malaysian agencies. \n\n\n\n\n\nOnly AGENSI PEKERJAAN are allowed to recruit foreign workers, and then only then they possess a license C status, as I understand it. Do correct me if I am wrong here. \n\n\n\nKindest Regards, Andy \n\n\n\nOn 25 Aug 2023, at 17:15, Andy Hall <andyjhall1979@gmail.com> wrote:\n\n\n\n?\n\nIsmail, thanks in responding for FELDA Plantation Management Sdn Bhd here. \n\n\n\nI will ask colleagues to follow up in more detail with workers concerned and revert back asap with additional responses in relation to statements of fact made by FELDA here. \n\n\n\nA few stark and basic observations on the migrant worker recruitment issue response statements from Felda however, initially from my side. \n\n\n\nIn my experience, it doesn’t matter much what amount of money companies such as FELDA pay to your Malaysian manpower agencies. Malaysian manpower agencies frequently double or triple dip. \n\n\n\nWhat this means actually is that these Malaysian manpower agencies too often take money for recruitment costs from employers, from source country agents AND from workers. \n\n\n\nMalaysian agencies are too often vehicles for corruption. And often these same Malaysian agencies also have to pay significant amounts of money to company HR staff. Indeed, it's general practice that Malaysian agencies have to pay bribes and kickbacks to Malaysian companies personnel to even secure the worker demand letters in the first place. \n\n\n\nThat said, of course it's important that companies such as FELDA do open tenders for Malaysian agents and do map and cover all costs of recruitment, including potentially hidden costs, to ensure workers do not pay for jobs. \n\n\n\nI note also that the payment to Nepali agencies here is 400RM per worker. The 2018 MoU between Malaysia and Nepal mandates, as I understand it, a minimum 50% of  minimum wage monthly salary that should be paid to a Nepali agent. That is currently 750RM. \n\n\n\nWhat matters here in this area of social and legal compliance actually, in my\n\nhumble opinion and based on my experience, is whether companies such as FELDA monitor or not how much of the money your management and company actually pays to Malaysian agencies in recruitment fees and costs actually ends up with the Nepali (or source country) agencies. Usually in my basic experience this is very little, or even nothing at all. \n\n\n\nDo FELDA actually monitor banking transactions between Malaysian agents and source country agencies? \n\n\n\nUsually the Nepali (or source country) agencies have to pay Malaysian agencies larger kickbacks or bribes to secure worker demands from them, which they then recoup alongside their own profit margin (and those costs of subagent) from migrant workers themselves. To put it simply…. Often Nepali (or source country) agencies pay Malaysian agencies money, and not the other way around. Hence the need for careful monitoring. \n\n\n\nWhat matters here actually, in my humble opinion, is not what costs FELDA cover but how FELDA monitors your Malaysian agencies to ensure their ethical business practices. \n\n\n\nIn my experience it is hard for any company in Malaysia (and often in Thailand too) to effectively monitor Malaysian manpower agencies in practice. This is why I strongly advocate for larger companies to bring recruitment functions in house and hence do away completely with the need to use unreliable Malaysian agencies for recruitment related activities or functions.\n\n\n\nSubagents are also strictly illegal in Nepal, recruitment illegality of this kind should not be condoned or accepted by FELDA or your Malaysian agencies, or by related companies and agents. \n\n\n\nCan I also check, are all the Malaysian agencies you list in your Appendix response licensed with a Category C recruitment license under the Private Employment Agencies Act 1981? \n\n\n\nA category C license is required to source foreign workers for an end user employer in Malaysia, whilst outsource hire companies have been illegal for some time in Malaysia, I understand. \n\n\n\nAs always, I stand ready to support and advise companies such as FGV and FELDA, and other RSPO members generally, in adopting ethical recruitment practices that go beyond words (policies) towards genuine practice (implementation) in a way that promotes sustainable business practices for end user employers and manpower agencies whilst also respecting and promoting workers rights not to have to pay for their work. \n\n\n\nI consider FELDA and FGV still have a long way to go in this regard, but appreciate your response and continued efforts here. \n\n\n\nWishing you a pleasant weekend. \n\n\n\nKindest Regards, Andy Hall \n\n\n\nOn Fri, 25 Aug 2023 at 15:43, Ismail Samingin (FELDA) <ismail.s@felda.net.my> wrote:\n\nDear Andy,\n\n\n\n \n\n\n\nWith regards to your email, please find enclosed the respond from FELDA Plantation Management Sdn Bhd for your information.\n\n\n\n \n\n\n\nregards\n\n\n\n \n\n\n\nFrom: Andy Hall <andyjhall1979@gmail.com> \n\nSent: Wednesday, August 16, 2023 8:53 AM\n\nTo: Nurul Hasanah bt. Ahamed Hassain Malim (FGVHB) <hasanah.ahm@fgvholdings.com>\n\nCc: Ameer Izyanif Bin Hamzah (FGVHB) <ameer.h@fgvholdings.com>; Anthonius Sani (FGVPMSB) <anthonius.s@fgvholdings.com>; Bahagian D3 JSJ Bukit Aman <atip_d3jsj@rmp.gov.my>; CC: Syuhaida bt Abdul Wahab Zen - SUB(NSO MAPO) <syuhaida@moha.gov.my>; Citra Hartati <citra.hartati@rspo.org>; Dato’ Amir Hamdan Yusof <amir.hy@felda.net.my>; Djaka Riksanto <djaka.riksanto@rspo.org>; Ian Spaulding <ispaulding@elevatelimited.com>; Izham Mustaffa (FELDA) <izham.m@felda.net.my>; Jeff Bond <jeff.bond@elevatelimited.com>; Joseph D'Cruz <jdcruz@rspo.org>; MAD ZAIDI MOHD KARLI (MPIC) <zaidi@mpic.gov.my>; NURUL HUDA BINTI MOHD ZAINUDIN <nurul@mpic.gov.my>; Savitri Restrepo <savitri.restrepo@elevatelimited.com>; Wan Kasim Bin Wan Kadir (FGVHB) <wankasim.wk@fgvholdings.com>; Zuraida Kamaruddin <zuraida.kamaruddin@gmail.com>; atipsom tf <atipsom.tf@moha.gov.my>; azie@mpoc.org.my; azreen.asnan@feldaglobal.com; bel@mpoc.org.my; Ismail Samingin (FELDA) <ismail.s@felda.net.my>; jim.atipsom@imi.gov.my; jtksm@mohr.gov.my; kamini.v@rspo.org; salleh.a@felda.net.my; shazlee@mpic.gov.my; wbmaster@mpoc.org.my\n\nSubject: Re: URGENT Worker complaint - Felda/FGV\n\n\n\n \n\n\n\nHi all, hope all is well. \n\n\n\n \n\n\n\nAm following up again over one month on for a response to this complaint attached sent in early July. I will be sending these allegations and the non response onto related international related enforcement bodies if there is no response by the end of the week. it's unacceptable in my opinion to recieve no response. \n\n\n\n \n\n\n\nRSPO, could we get a response here too from your side? \n\n\n\n \n\n\n\nThanks. Kind Regards, Andy \n\n\n\n \n\n\n\nOn Wed, 26 Jul 2023 at 16:50, Andy Hall <andyjhall1979@gmail.com> wrote:\n\n\n\nColleagues, please note there has been zero response to this email since 10th July.  Thanks. Regards, Andy Hall \n\n\n\n \n\n\n\n? From: Andy Hall <andyjhall1979@gmail.com>\n\n\n\nDate: 10 July 2023 at 15:07:47 BST\n\n\n\nTo: "Nurul Hasanah bt. Ahamed Hassain Malim (FGVHB)" <hasanah.ahm@fgvholdings.com>\n\n\n\nCc: "Ameer Izyanif Bin Hamzah (FGVHB)" <ameer.h@fgvholdings.com>, "Anthonius Sani (FGVPMSB)" <anthonius.s@fgvholdings.com>, Bahagian D3 JSJ Bukit Aman <atip_d3jsj@rmp.gov.my>, "CC: Syuhaida bt Abdul Wahab Zen - SUB(NSO MAPO)" <syuhaida@moha.gov.my>, Citra Hartati <citra.hartati@rspo.org>, Dato’ Amir Hamdan Yusof <amir.hy@felda.net.my>, Djaka Riksanto <djaka.riksanto@rspo.org>, Ian Spaulding <ispaulding@elevatelimited.com>, "Izham Bin Mustaffa (FELDA)" <izham.m@felda.net.my>, Jeff Bond <jeff.bond@elevatelimited.com>, Joseph D'Cruz <jdcruz@rspo.org>, "MAD ZAIDI MOHD KARLI (MPIC)" <zaidi@mpic.gov.my>, NURUL HUDA BINTI MOHD ZAINUDIN <nurul@mpic.gov.my>, Savitri Restrepo <savitri.restrepo@elevatelimited.com>, "Wan Kasim Bin Wan Kadir (FGVHB)" <wankasim.wk@fgvholdings.com>, Zuraida Kamaruddin <zuraida.kamaruddin@gmail.com>, atipsom tf <atipsom.tf@moha.gov.my>, azie@mpoc.org.my, azreen.asnan@feldaglobal.com, bel@mpoc.org.my, ismail.s@felda.net.my, jim.atipsom@imi.gov.my, jtksm@mohr.gov.my,\n\n\n\n \n\n\n\n \n\n\n\nkamini.v@rspo.org, salleh.a@felda.net.my, shazlee@mpic.gov.my, wbmaster@mpoc.org.my\n\n\n\nSubject: URGENT Worker complaint - Felda/FGV\n\n\n\n \n\n\n\nColleagues, please find attached Felda plantations worker complaint regarding to strike, indicators of forced labour and other alleged rights abuses. Would appreciate FGV/Felda’s urgent investigation and response here. Thanks. Regards, Andy Hall\n\n\n\n \n\n\n\n--\n\n\n\nAndy Hall\n\nMigrant Worker Rights Specialist \n\n+977 (0) 9823486634 (Phone/WhatsApp)\n\nAndyjhall1979@gmail.com (Email)\n\n@atomicalandy (Twitter)\n\nBlog: www.andyjhall.wordpress.com\n\n\n\n \n\n\n\n--\n\n\n\nAndy Hall\n\nMigrant Worker Rights Specialist \n\n+977 (0) 9823486634 (Phone/WhatsApp)\n\nAndyjhall1979@gmail.com (Email)\n\n@atomicalandy (Twitter)\n\nBlog: https://andyjhall.org\n\n\n\n-- \n\nAndy Hall\n\nMigrant Worker Rights Specialist \n\n+977 (0) 9823486634 (Phone/WhatsApp)\n\nAndyjhall1979@gmail.com (Email)\n\n@atomicalandy (Twitter)\n\nBlog: https://andyjhall.org\n\n	185
23	2022-04-14 13:29:54+00	t	Others	139	2022-04-14	Tuan\n\n\n\nSaya ingin memajukan aduan rasmi berkenaan beberapa tindakan yang dilakukan oleh Pihak Badan Persijilan Rephro Cerification Sdn Bhd. \n\n\n\n1.\tMenawarkan khidmat consultancy dan pengauditan kepada pelanggan. ( Rujuk bukti perbualan pelanggan dan Samsul Suhatman – Sales & Marketing Executive Rehpro Certification Sdn bhd -  hantaran whatsapp dan voice note ) \n\nSaya mendapat maklumat pihak ini sedang aktif menawarkan khidmat consultancy dan pengauditan kepada pelanggan mereka. Perkara ini telah belaku lama dan saya mendapat tahu antara pelanggan yang di berikan khidmat consultancy dan pengauditan adalah TP Resources Sdn Bhd. Alasan mereka menggunakan company yang berbeza iaitu Rephro Scientific Sdn Bhd untuk CHRA yang terdapat element recomendation dan juga khidmat perundingan  , saya rasa tidak patut diterima memandangkan ia dimiliki oleh Pemilik yang sama ( Sila Rujuk Sijil SSM yang disertakan ), malah apabila mereka merasakan perbuatan mereka semakin dihidu , mereka cuba menggunakan Eko Green Solution ( Syarikat ini tiada dalam data SSM ) untuk khidmat consultancy dan pengauditan ( Berdasarkan hantaran whatsapp) . Ini  saya dapati  bertentangan dengan keperluan yang dinyatakan didalam ISO IEC 1702. \n\n\n\nClause 5.2.5  - The Certification Body and any part of the same legal entity  and ANY ENTITY under the organizational control of the certification ( See 9.5.1.2) shall not offer or provide management system consultancy . This also applies to that part of government identified as the certification body \n\n\n\n9.5.1.2 (b) Majority participation by the certification body on the board of director another identity. \n\n\n\n5.2.7 Where a client has received management systems consultancy form a body that has relationship with a certification body, this is significant threat to impartiality. A recognized mitigation of this threat is that the certification body shall not certify management system for a minimum of two years following the end of the consultancy \n\n\n\nMalah tindakan mereka memasarkan perkhidmatan consultancy dan pengauditan adalah tidak selaras dengan \n\n\n\nClause 5.2.9 The certification body activity shall no be marketed or offered as linked with the activities of organization that provides management consultancy. The certification body shall take action to correct inappropriate links or statement by any consultancy organization stating or implying that certification would be simpler, easier, faster, or less expensive if the certification body were used. A certification body shall not imply that the certification would be simpler easier, faster , or less expensive if a specified consultancy organization were used \n\n\n\n2.\tPenawaran khidmat pengauditan kepada pelanggan yang tidak menepati keperluan Malaysia Sustainable Palm Oil Certification Scheme Clause 6.4\n\nBedasarkan Quotation dari Pihak Rephro bertarikh 23/3/2022 kepada Regal Establishment Sdn Bhd, Pihak CB menawarkan perkhidmatan pengauditan menggunakan format Group Certification dengan menggabungkan 7 estate ( 4 lokasi di Sabah dan 3 disemenanjung ) . Site No 1 hingga 4 yang dinyatakan didalam quotation adalah lokasi di semenanjung manakala site 5 hingga 7 berada di sabah. Ini bertentangan dengan   clause 6.4 MSPOCS01 . Bagaimana pun saya tidak dapat memastikan samada pelanggan bersetuju dengan tawaran tersebut. ( Rujuk lampiran Quotation No MSPO/2021/35 Date 23/3/2022. \n\n\n\nSelain itu,walaupun saya mendapat makklumat tidak dapat disahkan melibatkan pengaturan keputusan audit dan sebagainya , namun kesukaran mendapatkan bukti dan tiada akses kepada pelanggan terlibat menyebabkan perkara ini tidak dapat dikenalpasti. Oleh itu saya berharap sekiranyan terdapat penyiasatan rasmi oleh pihak tuan, diharap perkara ini juga diambil perhatian. \n\n\n\nSaya amat berharap penyiasatan penuh dijalankan kerana sekiranya dibiarkan , ini akan menjadikan contoh oleh pihak lain menggunakan situasi yang sama sekaligus menjejaskan kredibiliti Persijilan MSPO. \n\nBukti2 lain tidak dapat dilampirkan dan perlu menggunakan platform lain kerana format dan saiz data. \n\nSekian Terima Kasih \n\n\n\nAdnin Aminurrashid Bin Zilah \n\n	139
26	2020-08-05 14:12:26+00	t	Others	64	2020-08-05	testing testing testing testing testing	64
22	2020-05-31 22:46:29+00	t	MENUTUP KES PUKUL PEKERJA OLEH KAKITANGAN LADANG TABUNG TENTERA TERENGGANU	61	2020-05-31	A letter date 24 Mar 2020 from En. Raja Mohamad Faiz Aminnudin bin Raja Badli, (worker) addressed to Bousted Plantations Bhd was copied to MPOCC, received by post on 28 May 2020.  See attached letter. 	61
21	2020-04-30 15:30:43+00	t	Complaint against the Certificate of Quality Avenue Sdn Bhd Oil Palm Plantation	56	2020-04-30	This complaint is about destruction of water catchment area of Tatau District by the Quality Avenue Sdn Bhd,  and also the lost of Native Customary Land of Sungai Sap Community.  The plantation was very much effect the quality of water supply for Tatau community and as well as the junggle within the Tatau Water Catchment Area that was gazzetted on years of 2001.  The oil palm plantation was encroaching into the Native Customary Right(NCR) Land as well as the Tatau Water Catchment Area. 	56
20	2020-04-27 13:14:09+00	t	Land dispute and security clearance	55	2020-04-27	My neighbour Kwantas have been harvesting my crops despite showing evidence that the piece of land in question belongs to us( with demarcation and land survey ). I report to them last month On the 6th of March via WhatsApp to their person in charge of the issue but last week when the restriction was lifted in kinabatangan, they went harvest my crops again so I got frustrated and emotional when I went to their office. So far they didn’t response to my grievance that’s why I get angry at them. Since then they block my way to my plantation and don’t give me security clearance. I’m now standing at their gate trying to solve the problem. I have essential items and goods to deliver to my workers... theres no other entrance to my estate but have to go through their gate. I hope you can assist me to solve this issue and start an investigation on your part. Regards	55
19	2020-04-17 14:20:09+00	t	Tabung Haji Plantations to Develop New Oil Palm Concession, Once Again Breaching Buyers’ NDPE Commitments	49	2020-04-17	This is a complaint highlighted in the web portal (chainreactionresearch.org).  There is no complainant.  The weblink https://chainreactionresearch.com/the-chain-tabung-haji-plantations-to-develop-new-oil-palm-concession-once-again-breaching-buyers-ndpe-commitments/ was published on 9 Apr 2020.  As a follow up, we wrote to Tabung Haji on 10 Apr 2020.	49
18	2020-04-17 14:10:38+00	t	MEDIA REPORTS ON OIL PALM PLANTATIONS URGED TO STOP USING CHEMICALS THAT CAN HARM ELEPHANTS	48	2020-04-17	This is a complaint highlighted in the media.  Therefore, there is no complainant. The weblinks are : (https://www.bernama.com/bm/am/news.php?id=1831862)\n\n(https://www.thestar.com.my/news/nation/2020/04/14/oil-palm-plantations-urged-to-stop-using-chemicals-that-can-harm-elephants)  \n\n( https://www.theborneopost.com/2020/04/15/christina-repeats-call-for-cooperation-of-oil-palm-plantations/ ) .  MPOCC email the CB, Care Certification International, on 16 Apr 2020.	48
17	2020-04-14 10:28:42+00	t	KILANG KELAPA SAWIT DI GANTUNG LESEN KERANA MENYEBABKAN PENCEMARAN DI SUNGAI TONGOD SANDAKAN, SABAH	47	2020-04-14	Jabatan Alam Sekitar (JAS) Negeri Sabah telah menerima aduan dari jabtan Air Sabah dan menerusi media sosial tentang pencemaran di sungai Tongod, Sandakan, sabah pada 8 April 2020. Pasukan penyiasat JAS Negeri Sabah telah menjalankan siasatan pada 8 dan 9 April bersama pengerusi Majlis Pengurusan Komuniti Kampung (MPKK) dan kakitangan Jabatan Air Tongod. Siasatan mendapati efluen bertakung di parit ladang yang berhampiri Sungai Malagatan dalam jarak lebih kurang 100 meter hingga 200 meter dari kawasan sungai.JAS Negeri Sabah telah mengambil tindakan tegas menggantung lesen pemilik kilang kelapa sawit daripada beroperasi selama sebulan. JAS Negeri Sabah telah mengarahkan Kilang tersebut supaya melakukan pembersihan serta merta. Pihak Kilang diarahkan mempercepatkan kerja-kerja pencucian kolam pengolahan efluen supaya mematuhi sepenuhnya syarat-syarat lesen yang dikeluarkan oleh JAS di bawah Akta Kualiti Alam Sekeliling 1974 (Akta 127).	47
16	2020-04-07 16:39:07+00	t	Complaining Jaya tiasa holding working during lockdowns period 	43	2020-04-07	Dear sir. During lockdowns period and we are Malaysia citizens and we should corporations with government rules and regulations. But I found a company name jaya tiasa holding, they are using soppaa permit and call back all the worker back to work( head office at sibu town- NOT AT ESTATES) and number of worker more than 100 persons. As I know , HR and Financial department should need to work cause of payday and other should stay at home avoid situations become worst ( Convid-19 Virus). But not all the worker belong to these 2 departments. In my knowledge about MSPO. Company should abide CSR and policies of MSPO. So here we hope those company has MSPO certificates no just a paper but we need to abides and helping social at this moment. Thanks	43
36	2020-08-16 01:05:25+00	t	Others	72	2020-08-16	We have obtained our MSPO certification part 3 on 01st October 2019 and we have submitted our claim by hand to MPOCC staff on 18th March 2020 at NIOSH bangi. We have emailed Mr Tan on 20th July 2020 to request for the status of the claim, but Mr Tan inform us that our application still in queue to be process due to large volume of application and the closure of MPOCC office due to MCO. Our management has queried on delay of the claim and we as sustainability officer unable to explain to our management since we don't know the progress of the claim and it's hard for us to convince our management to continue doing the surveillance audit. So, we would like to suggest if MPOCC can create any system for the companies to monitor on the progress of the claim. We hope that MPOCC can revert on this matter as soon as possible. Thanks.	72
31	2020-08-16 00:54:20+00	t	Others	69	2020-08-16	We have obtained our MSPO certification part 3 on 21st June 2019 and we have submitted our claim by hand to MPOCC staff on 18th March 2020 at NIOSH bangi. We have emailed Mr Tan on 20th July 2020 to request for the status of the claim, but Mr Tan inform us that our application still in queue to be process due to large volume of application and the closure of MPOCC office due to MCO. Our management has queried on delay of the claim and we as sustainability officer unable to explain to our management since we don't know the progress of the claim and it's hard for us to convince our management to continue doing the surveillance audit. So, we would like to suggest if MPOCC can create any system for the companies to monitor on the progress of the claim. We hope that MPOCC can revert on this matter as soon as possible. Thanks.	69
30	2020-08-16 00:50:51+00	t	Others	68	2020-08-16	We have obtained our MSPO certification part 3 on 31st May 2019 and we have submitted our claim by hand to MPOCC staff on 18th March 2020 at NIOSH bangi. We have emailed Mr Tan on 20th July 2020 to request for the status of the claim, but Mr Tan inform us that our application still in queue to be process due to large volume of application and the closure of MPOCC office due to MCO. Our management has queried on delay of the claim and we as sustainability officer unable to explain to our management since we don't know the progress of the claim and it's hard for us to convince our management to continue doing the surveillance audit. So, we would like to suggest if MPOCC can create any system for the companies to monitor on the progress of the claim. We hope that MPOCC can revert on this matter as soon as possible. Thanks.	68
29	2020-08-16 00:47:09+00	t	Others	67	2020-08-16	We have obtained our MSPO certification part 3 on 31st May 2019 and we have submitted our claim by hand to MPOCC staff on 18th March 2020 at NIOSH bangi. We have emailed Mr Tan on 20th July 2020 to request for the status of the claim, but Mr Tan inform us that our application still in queue to be process due to large volume of application and the closure of MPOCC office due to MCO. Our management has queried on delay of the claim and we as sustainability officer unable to explain to our management since we don't know the progress of the claim and it's hard for us to convince our management to continue doing the surveillance audit. So, we would like to suggest if MPOCC can create any system for the companies to monitor on the progress of the claim. We hope that MPOCC can revert on this matter as soon as possible. Thanks.	67
28	2020-08-16 00:40:31+00	t	Others	66	2020-08-16	We have obtain our MSPO certification part 3 on 30th May 2019 and we have submitted our claim by hand to MPOCC staff on 18th March 2020 at NIOSH bangi. We have emailed Mr Tan on 20th July 2020 to request for the status of the claim, but Mr Tan inform us that our application still in queue to be process due to large volume of application and the closure of MPOCC office due to MCO. Our management has queried on delay of the claim and we as sustainability officer unable to explain to our management since we don't know the progress of the claim and its hard for us to convince our management to continue doing the surveillance audit. So, we would like to suggest if MPOCC can create any system for the companies to monitor on the progress of the claim. We hope that MPOCC can revert on this matter as soon as possible. Thanks.	66
44	2021-04-29 03:48:10+00	t	Non-compliance to MSPO Certification Scheme	104	2021-04-29	Based on latest MSPO supply chain certificate by BSI Services Sdn Bhd, the latest MSPO SCCS certificate number is MSPO 727219, however the certificate number registered number is MSPO IT platform which is MSCC-005-88. We need your assist to change certificate number to MSPO 727219	104
46	2020-08-16 01:31:53+00	t	Others	80	2020-08-16	We have obtained our MSPO certification part 3 on 06th December 2019 and we have submitted our claim by hand to MPOCC staff on 18th March 2020 at NIOSH bangi. We have emailed Mr Tan on 20th July 2020 to request for the status of the claim, but Mr Tan inform us that our application still in queue to be process due to large volume of application and the closure of MPOCC office due to MCO. Our management has queried on delay of the claim and we as sustainability officer unable to explain to our management since we don't know the progress of the claim and it's hard for us to convince our management to continue doing the surveillance audit. So, we would like to suggest if MPOCC can create any system for the companies to monitor on the progress of the claim. We hope that MPOCC can revert on this matter as soon as possible. Thanks.	80
43	2020-08-16 01:27:36+00	t	Others	79	2020-08-16	We have obtained our MSPO certification part 3 on 20th December 2019 and we have submitted our claim by hand to MPOCC staff on 18th March 2020 at NIOSH bangi. We have emailed Mr Tan on 20th July 2020 to request for the status of the claim, but Mr Tan inform us that our application still in queue to be process due to large volume of application and the closure of MPOCC office due to MCO. Our management has queried on delay of the claim and we as sustainability officer unable to explain to our management since we don't know the progress of the claim and it's hard for us to convince our management to continue doing the surveillance audit. So, we would like to suggest if MPOCC can create any system for the companies to monitor on the progress of the claim. We hope that MPOCC can revert on this matter as soon as possible. Thanks.	79
42	2020-08-16 01:22:51+00	t	Others	78	2020-08-16	We have obtained our MSPO certification part 3 on 31st December 2019 and we have submitted our claim by hand to MPOCC staff on 18th March 2020 at NIOSH bangi. We have emailed Mr Tan on 20th July 2020 to request for the status of the claim, but Mr Tan inform us that our application still in queue to be process due to large volume of application and the closure of MPOCC office due to MCO. Our management has queried on delay of the claim and we as sustainability officer unable to explain to our management since we don't know the progress of the claim and it's hard for us to convince our management to continue doing the surveillance audit. So, we would like to suggest if MPOCC can create any system for the companies to monitor on the progress of the claim. We hope that MPOCC can revert on this matter as soon as possible. Thanks.	78
41	2020-08-16 01:20:18+00	t	Others	77	2020-08-16	We have obtained our MSPO certification part 3 on 20th December 2019 and we have submitted our claim by hand to MPOCC staff on 18th March 2020 at NIOSH bangi. We have emailed Mr Tan on 20th July 2020 to request for the status of the claim, but Mr Tan inform us that our application still in queue to be process due to large volume of application and the closure of MPOCC office due to MCO. Our management has queried on delay of the claim and we as sustainability officer unable to explain to our management since we don't know the progress of the claim and it's hard for us to convince our management to continue doing the surveillance audit. So, we would like to suggest if MPOCC can create any system for the companies to monitor on the progress of the claim. We hope that MPOCC can revert on this matter as soon as possible. Thanks.	77
40	2020-08-16 01:17:23+00	t	Others	76	2020-08-16	We have obtained our MSPO certification part 3 on 06th November 2019 and we have submitted our claim by hand to MPOCC staff on 18th March 2020 at NIOSH bangi. We have emailed Mr Tan on 20th July 2020 to request for the status of the claim, but Mr Tan inform us that our application still in queue to be process due to large volume of application and the closure of MPOCC office due to MCO. Our management has queried on delay of the claim and we as sustainability officer unable to explain to our management since we don't know the progress of the claim and it's hard for us to convince our management to continue doing the surveillance audit. So, we would like to suggest if MPOCC can create any system for the companies to monitor on the progress of the claim. We hope that MPOCC can revert on this matter as soon as possible. Thanks.	76
39	2020-08-16 01:15:19+00	t	Others	75	2020-08-16	We have obtained our MSPO certification part 3 on 06th November 2019 and we have submitted our claim by hand to MPOCC staff on 18th March 2020 at NIOSH bangi. We have emailed Mr Tan on 20th July 2020 to request for the status of the claim, but Mr Tan inform us that our application still in queue to be process due to large volume of application and the closure of MPOCC office due to MCO. Our management has queried on delay of the claim and we as sustainability officer unable to explain to our management since we don't know the progress of the claim and it's hard for us to convince our management to continue doing the surveillance audit. So, we would like to suggest if MPOCC can create any system for the companies to monitor on the progress of the claim. We hope that MPOCC can revert on this matter as soon as possible. Thanks.	75
38	2020-08-16 01:09:24+00	t	Others	74	2020-08-16	We have obtained our MSPO certification part 3 on 20th September 2019 and we have submitted our claim by hand to MPOCC staff on 18th March 2020 at NIOSH bangi. We have emailed Mr Tan on 20th July 2020 to request for the status of the claim, but Mr Tan inform us that our application still in queue to be process due to large volume of application and the closure of MPOCC office due to MCO. Our management has queried on delay of the claim and we as sustainability officer unable to explain to our management since we don't know the progress of the claim and it's hard for us to convince our management to continue doing the surveillance audit. So, we would like to suggest if MPOCC can create any system for the companies to monitor on the progress of the claim. We hope that MPOCC can revert on this matter as soon as possible. Thanks.	74
56	2020-08-16 01:53:03+00	t	Others	88	2020-08-16	We have obtained our MSPO certification part 3 on 28th February 2020 and we have submitted our claim by hand to MPOCC staff on 18th March 2020 at NIOSH bangi. We have emailed Mr Tan on 20th July 2020 to request for the status of the claim, but Mr Tan inform us that our application still in queue to be process due to large volume of application and the closure of MPOCC office due to MCO. Our management has queried on delay of the claim and we as sustainability officer unable to explain to our management since we don't know the progress of the claim and it's hard for us to convince our management to continue doing the surveillance audit. So, we would like to suggest if MPOCC can create any system for the companies to monitor on the progress of the claim. We hope that MPOCC can revert on this matter as soon as possible. Thanks.	88
52	2020-08-16 01:48:49+00	t	Others	86	2020-08-16	We have obtained our MSPO certification part 3 on 10th February 2020 and we have submitted our claim by hand to MPOCC staff on 18th March 2020 at NIOSH bangi. We have emailed Mr Tan on 20th July 2020 to request for the status of the claim, but Mr Tan inform us that our application still in queue to be process due to large volume of application and the closure of MPOCC office due to MCO. Our management has queried on delay of the claim and we as sustainability officer unable to explain to our management since we don't know the progress of the claim and it's hard for us to convince our management to continue doing the surveillance audit. So, we would like to suggest if MPOCC can create any system for the companies to monitor on the progress of the claim. We hope that MPOCC can revert on this matter as soon as possible. Thanks.	86
51	2020-08-16 01:47:01+00	t	Others	85	2020-08-16	We have obtained our MSPO certification part 3 on 11th February 2019 and we have submitted our claim by hand to MPOCC staff on 18th March 2020 at NIOSH bangi. We have emailed Mr Tan on 20th July 2020 to request for the status of the claim, but Mr Tan inform us that our application still in queue to be process due to large volume of application and the closure of MPOCC office due to MCO. Our management has queried on delay of the claim and we as sustainability officer unable to explain to our management since we don't know the progress of the claim and it's hard for us to convince our management to continue doing the surveillance audit. So, we would like to suggest if MPOCC can create any system for the companies to monitor on the progress of the claim. We hope that MPOCC can revert on this matter as soon as possible. Thanks.	85
49	2020-08-16 01:38:02+00	t	Others	83	2020-08-16	We have obtained our MSPO certification part 3 on 20th December 2019 and we have submitted our claim by hand to MPOCC staff on 18th March 2020 at NIOSH bangi. We have emailed Mr Tan on 20th July 2020 to request for the status of the claim, but Mr Tan inform us that our application still in queue to be process due to large volume of application and the closure of MPOCC office due to MCO. Our management has queried on delay of the claim and we as sustainability officer unable to explain to our management since we don't know the progress of the claim and it's hard for us to convince our management to continue doing the surveillance audit. So, we would like to suggest if MPOCC can create any system for the companies to monitor on the progress of the claim. We hope that MPOCC can revert on this matter as soon as possible. Thanks.	83
48	2020-08-16 01:36:24+00	t	Others	82	2020-08-16	We have obtained our MSPO certification part 3 on 03rd February 2020 and we have submitted our claim by hand to MPOCC staff on 18th March 2020 at NIOSH bangi. We have emailed Mr Tan on 20th July 2020 to request for the status of the claim, but Mr Tan inform us that our application still in queue to be process due to large volume of application and the closure of MPOCC office due to MCO. Our management has queried on delay of the claim and we as sustainability officer unable to explain to our management since we don't know the progress of the claim and it's hard for us to convince our management to continue doing the surveillance audit. So, we would like to suggest if MPOCC can create any system for the companies to monitor on the progress of the claim. We hope that MPOCC can revert on this matter as soon as possible. Thanks.	82
69	2022-04-14 09:08:03+00	t	Others	138	2022-04-14	test test test test	138
68	2022-04-14 09:00:21+00	t	Others	137	2022-04-14	test test test test test	137
75	2021-09-10 16:18:28+00	t	test by airei	122	2021-09-10	TEST BY AIREI	122
74	2021-08-23 11:33:11+00	t	Non-compliance to MSPO Certification Scheme	118	2021-08-23	test test test test	118
73	2021-08-20 16:32:17+00	t	MSPO Trace	117	2021-08-20	Unable to upload single line item CPO / PK dispatch using templete. In the event there is only 1 trip of barge serving 1 contract to 1 buyer, there is an error message unable to upload templete file with single line item.	117
71	2021-08-04 12:47:33+00	t	Others	115	2021-08-04	I can't submit monthly declaration for june and july. it's keep loading like in the picture that I attached.	115
70	2021-05-25 04:42:15+00	t	Others	107	2021-05-25	LADANG SAWIT YANG DIUSAHAKAN TELAH DIMUSNAHKAN OLEH PIHAK SYARIKAT DIBAWAH SYARIKAT PUSAKA CAPITAL. POKOK SAWIT YANG DITANAM SEJAK TAHUN 2017 DAN MEMPUNYAI 150 POKOK. PUNCA PENDAPATAN AMAT TERJEJAS. MOHON PIHAK MPSO MEMBUAT PANTAUAN DAN TINDAKAN DENGAN SEGERA.	107
67	2021-03-08 04:31:16+00	t	Non-compliance to MSPO Certification Scheme	102	2021-03-08	On 22/02/2021, GGC as accepting CB has contacted issuing CB for FGV Tenggaroh and Serting Hilir (Mutuagung Lestari (M) Sdn Bhd to initiate the pre-transfer process (evidence attached) as per IAF:MD2 Transfer of Accredited Certification of Management Systems. However, GGC not received proper feedback and cooperation to this process from Mutuagung Lestari (M) Sdn Bhd. Based on GGC internal review and FGVPM information, there is no reason for Mutuagung Malaysia to hold and delayed the transfer process since all obligation has been fulfilled by FGVPM.	102
66	2021-03-05 23:34:41+00	t	Others	101	2021-03-05	Good day. I have tried to upload the  monthly FFB declaration since 2/3/2021 but until today, I still cannot upload the FFB data. I thought the internet line might not working then i tried other internet option which is quite fast (during that time I can download a bigger size file using the line) but did not worked. Previously, I do not have any of these problem. Thank you.	101
64	2021-02-08 07:45:26+00	t	Others	99	2021-02-08	We can't add one of our FFB supplier in our supplier list because they did not appear in certified supplier registration. The supplier is Koperasi Bina Bersama Kampong Gajah Perak Berhad. We need to add the supplier in our FFB supplier list for FFB monthly declaration. I attach the supporting document for your reference. Thank you.	99
63	2021-02-03 10:27:12+00	t	Others	98	2021-02-03	This digital submission is made at the request of MPOCC, following the submission of our letter and a bulk of documents in December 2020. It pertains to the complaints that we have received from six groups of indigenous communities in Marudi and Batu Niah, Sarawak in recent years, on the past and possible future violations of their native customary rights (NCR) by oil palm plantation projects. Please refer to our cover letter for further details. The communities involved are: (1) Rumah Manjan and Rumah Nanta, Sungai Malikat, Marudi; (2) Rumah Beliang, Logan Tasan, Marudi; (3) Rumah Labang Jamu, Nanga Seridan, Baram;  (4) Persatuan Iban Marudi (which concerns a larger area where several longhouses may be affected, including 1 and 2); (5) Persatuan Penduduk Sungai Buri, Bakong, Baram; (6) Persatuan Penduduk Rumah Lachi, Sungai Sebatuk, Batu Niah.  For email communications, kindly write to three addresses: foemalaysia@gmail.com, jokjevong@gmail.com and shaffincre@gmail.com. Thank you.	98
62	2020-12-26 13:10:20+00	t	Non-compliance of national laws and regulations	96	2020-12-26	All small holders are suffering to suppy FFB to factory,cause goverment allocated road been blocked(build up toll gate) by a non responsible Estate(ladang melintang maju sdn bhd)we need your assistance to solve this problem as soon as possible by contacting us.	96
61	2020-11-23 02:23:17+00	t	Others	94	2020-11-23	I am unable to Register MSPO trace using my SCCS certificate No : DMC MSPO SCCS 04, please help	94
60	2020-10-02 13:54:18+00	t	Non-compliance to MSPO Certification Scheme	93	2020-10-02	Assisting Mr. Ganie Anak Assan IC:570127135813, HP: +6013-8270786, Address: No. 25, Lot 461, Phase II Taman Tiara, Jalan Brayun. 95000 Sri Aman, Sarawak on his complaints on encroachments of his NCR land in Selanjan, Sri Aman, Sarawak. Locality map and all relevant documents are attached for your reference.	93
59	2020-09-07 15:44:15+00	t	Others	92	2020-09-07	The Palm Oil Mill Monthly Declaration can't be tally with mill MSPO inventory records since some of our FFB supplier have been certified with MSPO Part 3, but not available/updated in the MSPO Trace system. We need to declare as non certified FFB supplier to fulfill the FFB Supplier Template provided. The quantity of certified and non certified FFB received are not tally with our records. The 3 estates (Gan Kim Siat, Lion Landscaping Sdn Bhd & PKEINPk Sdn Bhd) at the bottom of FFB Supplier Template attached have been certified with MSPO Part 3 but not available in the MSPO Trace system. Is there any solution to solve this problem. Thank you. 	92
111	2022-12-09 12:19:16+00	t	Non-compliance to MSPO Certification Scheme	160	2022-12-09	Non compliance to principal 3 MSPO standard	160
110	2022-11-14 14:28:06+00	t	Others	159	2022-11-14	Test test test test test	159
109	2022-11-03 17:16:40+00	t	MSPO Trace	158	2022-11-03	FFB delivery data for Sept 2022 was wrongly keyed in. I could not delete the submission and would like help from MPOCC to delete the data submitted so that I can key in the correct data. Attached is the correct data	158
108	2022-11-03 10:38:32+00	t	Non-compliance to MSPO Certification Scheme	157	2022-11-03	Aduan pencerobohan ataupun penerokaan oleh Green Jaya Resources Sdn Bhd , sebauh estate ( MPOB lesen 616232002000) di Kawasan Hutan Simpan Similajau Bintulu Sarawak	157
86	2022-07-05 10:03:03+00	t	Others	153	2022-07-05	Subject: MSPO Status Delayed\n\n\n\nDear Sir,\n\n\n\nIn conjunction with the above subject, as for the information of MPOCC, oil palm plantations and palm oil mill under Tee Teh Sdn Bhd were audited for 2nd Annual Surveillance by Global Gateway Certification Sdn Bhd last year on 07-09 December 2021.\n\n\n\nAs a client with MSPO certification, we are very concerned about the delayed status in MSPO Trace. According to our CB, the delayed status was due to the report still under review by MPOCC.\n\n\n\nHence, we seek your kind assistance in the above matter. Thank you.	153
90	2022-03-05 16:26:25+00	t	MSPO Trace	135	2022-03-05	Saya tak boleh click button Confirm utk submit Monthly Declaration	135
89	2022-02-26 13:12:15+00	t	Others	134	2022-02-26	Non compliance on auditor MSPO. Not competence already become audit. Less experience work less than 5 year still can be auditor. The auditor name Ahmad Farris bin Nazmi Asna. Currently work work with DQS before this as freelance with PCi .	134
85	2022-02-08 09:25:43+00	t	Others	132	2022-02-08	Our December 2021 monthly report posting In the system, the date captured by the system as Jan 2022 report, please help to rectify this error, so that we can post  Jan 2022 monthly report.	132
84	2022-01-28 17:32:39+00	t	Non-compliance of national laws and regulations	131	2022-01-28	No action taken by the company against Kamala Kumaran  a/ l Ayyaru and Mustamin bin Suhaili for their misconduct. 	131
83	2022-01-21 10:12:04+00	t	Others	130	2022-01-21	A) We are unable to modify the MSPO Certificate no for Our FFB suppliers From SGS cert.no to DIMA cert No. B) does the Update of Certificate No affect the Previous records ? C) there is no edit button the action Column at the Supplier list screen in MSPO trace system, how do we amend the MSPO Certificate No ?	130
82	2022-01-07 14:54:17+00	t	NST Letters : Help palm oil growers regarding US, EU standards January 6, 2022 @ 4:19pm	129	2022-01-07	LETTERS: I refer to the article, Palm oil industry has much to do on human rights compliance (NST, De 21, 2021). In the case of Malaysia, the human rights issues are related to forced labour and decent work.\n\nAs a grower, I used to assume that once my oil palm plantation has been certified to the Malaysian Standard for sustainable palm oil, i.e., MS 2530, my plantation has successfully addressed all the forced labour issues and all other sustainability requirements.\n\nBut, my joy was short-lived when a major buyer from the European Union conducted a sustainability audit on my company's estates and mill. The auditors issued a number of non-compliances, which in their opinion were major ones.\n\nI argued with them that this was not a requirement of the MS 2530, but that made the matter worse. Sad to say, my company lost the business of the major buyer.\n\nLater, I had an excellent opportunity to update my knowledge on palm oil sustainability when I listened to a talk organised by the University of Nottingham Malaysia.\n\nIt was entitled, "Gaps in Audit Standards related to Forced Labour and Decent work in the oil palm and manufacturing industry in Malaysia".\n\nThe Malaysian speaker explained in simple terms what constitutes forced labour and decent work. I admired his "hands-on" experience in sustainability-related issues.\n\nHe was also well-versed in international sustainability standards, which were not addressed in the Malaysian Standard.\n\nThis talk provided an excellent platform to apprehend, grasp and understand what constituted forced labour and decent work when the speaker presented on how a sustainability standard for oil palm plantation and mills should look like.\n\nThe salient points I learnt from the talk were:\n\n1. Sustainability standards focus on workers because they are weak, vulnerable, do not know their rights, and unprotected that the agent or employer can exploit them;\n\n2. Companies must be committed to uphold the human rights of workers, and to treat them with dignity and respect as understood by the international community;\n\n3. Companies must ensure that working conditions in the palm oil supply chain are safe and that business operations are environmentally responsible and conducted ethically; and,\n\n4. Companies need to go beyond legal compliance.\n\nMore interesting was the answer to the poll question posted at the end of the talk. The question was "Is there any auditable standard available to the Malaysian palm oil industry that addresses all Forced Labour and Decent Work-related issues in a simple, clear, unambiguous and concise manner?"\n\nMore than two-thirds of the attendees answered "No". Based on the talk, I checked the draft Malaysian standards for sustainable palm oil available at https://upc.mpc.gov.my/csp/sys/bi/%25cspapp.bi.work.nc.custom.regulation... .\n\nIt is true that the forced labour and decent work and other sustainability requirements are not stated in a detailed format and clear manner. To me, it seems that standards are written to fulfil key performance indicators rather than address sustainability issues facing the palm oil industry.\n\nThe ministries of Plantation Industries and Commodities, International Trade and Industry, Malaysian Palm Oil Board and growers must proactively ensure that the Malaysian Standards address the sustainability requirements in detail.\n\nEspecially those regarding forced labour and decent work, so that the growers can understand and implement these requirements, while making it easier to conduct audits.\n\nIf there is any non-compliance, growers can take opportunity to address the weakness they have rather than obtaining Malaysian Sustainable Palm Oil certification and believing that the plantation meets sustainability requirements, while palm oil products are barred at US ports and the sustainability of our palm oil is been questioned by EU, non-governmental agencies, consumers, and others.\n\n\n\nDRA\n\nKuala Lumpur	129
81	2021-12-11 18:01:21+00	t	Others	128	2021-12-11	Agreement issue	128
80	2021-10-14 12:20:20+00	t	Non-compliance to MSPO Certification Scheme	127	2021-10-14	The secretariat.\n\nMalaysian Sustainable Palm Oil(MSPO)\n\n\n\nPekara: Komplain/laporan rasmi melaui Malaysian Suatainable Palm Oil/MPOC\n\n(Grievance dispute Mechanism )\n\n\n\nPihak yang di lapor:\n\n\n\n1. LCDA HOLDING SDN BHD . Company No.182028 . Alamat Level 4.8 &amp;12 Wisma satok.\n\nJalan Satok.93400 Kuching Sarawak.\n\n2. WINSOME Pelita (PANTU) Sdn Bhd. Company No. 681469-H. Lot 7052,jalan Sekamah,93330\n\nKuching Sarawak.\n\n\n\nPihak yang membuat laporan yang memawakil semoa tuan tanah hak Adat (NCR) dari dan\n\nberalamat Kampung Tekuyong A Sri Aman Sarawak:\n\n1.  (Ex-Tuai Rumah) Masa anak Nangkai\n\n2. Raymond anak John lalong\n\n3. Amat Anak Jilong\n\n4. Adimen basit anak Christhoper.\n\n\n\nSejarah simulasi pencerobohan tanah Adat di kampung Tekuyong. Sri aman\n\nSarawak.\n\nPada tahun 2006 ministrial order Gazette L.N 79/2006 kawasan pantu subdistrict tremasuk wilayah\n\nkampung Tekuyung telah di wartakan oleh kerajaan sarawak melalui LCDA ( juga di sebut Pelita\n\nHolding) untuk penanaman kelapa sawit. Untuk pengatahuan pihak MSPO dan MPOC semenjak\n\ndari awal lagi pihak penduduk kampung Tekuyong A telah membantah dan tidak bersetuju kawasan\n\ntanah Adat di masukkan dalam project tersebut dan di minta kawasan Tekuyong di keluarkan dari\n\nproject tersebut.\n\nNamun pada tahun 2005 pihak kompani pertama yang terlibat ia itu Tertangga Akrab telah\n\nmenceruboh masuk ke kawasan wilayah kami secara tampa izin dan kebenaran pihak tuan Tanah\n\nNCR. Pihak kami telah mengalami kerugian besar dan hilang harta benda tanaman traditional dan\n\nkawasan pekuburan nenek moyang kami telah di ranap tampa perduli rayun pihak setempat. Pihak\n\nyang berkuasa dan bertenaga juga menguna gangster upahan untuk menentang pihak kami yang\n\nmempertahan harta benda. Pihak polis juga di guna untuk menangap pihak kami yang\n\nmempertahan harta benda. Modus operandi dari pihak LCDA telah menguna nama orang orang luar\n\nyang tidak menpunyi hak di kawasan kampung Tekuyong untuk menuntut tanah yang kepunyi\n\npenduduk kampung Tekuyong. Walau pun tututan tindis ini telah di selesai di mahkamah bumputra\n\ntatapi pihak LCDA tidak memperdulikan keputusan dari pihak mahkamah bumipitra.\n\nPada tahun 2005 walau pun amat berat untuk di usaha ,pihak kami telah membinta bantuan pihak\n\npajabat peguam untuk menuntut keadilan. Abapila mahkamah tinggi telah memberi kemenang\n\nkepada pihak kami maka LCDA dan pihak compani terus lagi membuat rayuan dan menambah\n\nkompani yang baru ia itu KIM LONG sdn bhd kepada mahkamah rayuan dan seterusnya kepada\n\nmahkamah perkesatuan. Untuk pengatahuan pihak MSPO dan MPOC pihak kerajaan melalui LCDA\n\nsering akan menguna atau perpindah company yang baru untuk menekan pikah komuniti tanah\n\nAdat. Dan untuk pengatahuan pihak MSPO dan MPOC baru baru ini pihak LCDA telah menguna\n\nWINSOME Pelita Sdn Bhd untuk menceroboh tanah Adat kami di kampong Tekuyong A.\n\nUntuk pengatahuan pihak mspo dan Mpoc tanah adat yang di tuntut oleh pihak LCDA dan\n\nWINSOME Pelita adalah tanah Adat yang di usaha oleh penduduk sendiri dengan penanam kelapa\n\nsawit dan mempunyi pensijilan sah dari pihak MPOB.\n\n\n\nPihak kami merayu dan mengesorkan kepada MSPO dan MPOC supaya pensijilan yang di berikan /anugrah kepada pihak LCDA dan WINSOME pelita di batal kan sampai penyelesai di capai.\n\nUntuk rujukan pihak MSPO dan MPOC pihak LCDA dan WINSOME PELITA anatar lain talah\n\nmelangari principle 3 mspo standard.\n\n1. Telah melanggar tartatertip sustainable operational standard menguna undang undang untuk\n\nmenekan prinsip keadilan( law shall not threaten customary rights)\n\n2.Secara sengaja Tidak mempertikan FPIC( free prior inform consent)\n\n\n\nPihak kami akan membekal dokumen dokumen yang di perlukan semasa perundingan jika ada.\n\nPihak kami boleh di hubungi melalui.\n\n\n\n1. Raymong anak John Lalong tel; 0197138220\n\n2. Masa Anak nangkai Tel. 0164267677.	127
78	2021-10-06 15:33:15+00	t	Others	125	2021-10-06	False Claims by MPOCC\n\na) Whilst MPOCC had failed to remove all 10 FGV certificates issued by MALM against the MSPO requirements, FGV has continued to make public that it has achieved 100% MSPO certification for all its operations;\n\nb) MPOCC’s conduct to publicly disseminate misleading information to unsuspecting stakeholders is improper and is further fortified by MPOCC’s actions to maintain the FGV certificates on its website instead of adhering to the technical requirements governing the MSPO scheme;\n\nc) The claims made by MPOCC is clearly untrue based on MPOCC’s own published records and bias against all other MSPO certificate holders and to downstream buyers of MSPO certified products sold by FGV.	125
107	2022-10-26 00:37:54+00	t	Others	156	2022-10-26	SLAVERY TREATMENT  Jendarata Estate 36009, Teluk Intan, Perak Darul Ridzuan                                                                                                                                                                   \n\n                                                                                                                                                                        I would like to make an official complaint about what happened to my daughter Thaarshaliny who worked in Jendarata Estate 36009, Teluk Intan, Perak Darul Ridzuan.  The management was forced to give their resignation. Here is the summary and refer to the attachment accordingly.\n\n\n\nNote: I wrote an email to Dato Carl Bek Nielsen for a face-to-face meeting up but he decline. ( Attached is my last email to Dato Carl. File name: Reply Dato Carl.pdf\n\n1) File name: Bully case in Jendarata Estate.pdf (attached)\n\n2) File name: 1st email to Dato Carl (attached)\n\n3) File name: Dato Carl's Respond (attached)\n\n4) File name: Director Edward Rajkumar (attached) - forcing my daughter to do resignation. Director Edward chased my daughter Thaarshaliny when she came near to tell him about the incident. Slavery treatment (witnessed by Soornarayanan Subramaniam (Senior Hospital Assistant working in Jendarata Estate (my daughter's supervisor)\n\n5) File name: DI 29.09.2022 - Conducted by HR Manager Mathews. The DI investigation is biased. HR Manager still asked my daughter to agree that she lost the documents (insufficient care) even though there is no proof (No CCTV installed in the working place). Sasikala has admitted all the accusations, but no stern action is taken against her \n\n6) File Name: Mathews- DI email.pdf - The DI was not done properly. Thaarshaliny supervisor and working colleagues not investigated the incident. It is truly biased to Sasikalah A/P Kathirasen.  Nanda Kumar A/L Veeramohan (Senior Assistant Manager)  was not even called for the domestic inquiry (DI). \n\n\n\n7) File name: Resignation Letter_Thaarshaliny - My daughter has no choice but to resign from her current position due to bullied, INHUMANE TREATMENT, public shaming, BREACH OF PRIVACY, NOT treated with dignity and respect. She was treated like a new era of slavery. \n\n    \n\n SLAVERY PRACTICES IN JENDARATA ESTATE (UNITED PLANTATION)\n\na) The directors and the manager talk very rudely to the staff. Treating the workers like a slave. In my daughter's case, Director Edward chased my daughter Thaarshaliny when she came near to tell him about the incident and told her "don't come near me, go far and talk to him" (treating her like an animal). Witnessed by Thaarshaliny's Supervisor, SoorNarayanan Subramaniam (Senior Hospital Assistant)\n\nb) Not letting the parents enter and visit the estate even in an emergency case. My daughter needs to write a letter to the Management (Priya's clerk ) forced to give the letter to her if the parents want to visit. During my daughter's interview session, the interviewer, HR Manager Mathews, and Jeevan Dharma Balan mentioned that the parents can come and stay with you anytime. \n\nc) Cannot plant any trees above 6 feet in your house compound. This was not documented in any of the United Plantation SOP. Even my daughter's papaya tree which was only 3 feet was asked to remove by Nanda Kumar A/L Veeramohan & Sasikalah A/P Kathiresen \n\nd)Asking people to come to work late at night 9 PM and early morning 6 AM. (Actual working hour is 8 PM - 5 PM as per the offer letter). Sasikalah A/P Kathiresen  did this to my daughter \n\ne) No proper drinking water has been supplied in the staff quarters given (no test water report has been shown). Please take the sample water from MH 02/02, where my daughter leaves, and send it to the test lab. The water is contaminated with bacteria. The staff need to walk very far to take the drinking water \n\ne) No people can go out after 10 PM to town to get any emergency items. The main gate will be closed. Not been mentioned in the work contract.\n\nf) Security guards at the main gate of Jendarata Estate act like a policeman, there is one Sarjan having a gun bringing the gun near to me when I am talking to the Security guard in charge, Balakrishnan, and threatening by bringing the gun towards me by saying we have our own rules in Jendarata and why are you questioning us. I just wanted to do some clarification about why not allowing parents to enter the estate and why we need to write an official letter\n\ng)No overtime is paid to my daughter even though she worked additional hours bringing the patient to the hospital.  Sometimes she returned to her quarters at 8.30 PM after bringing the patient to Government Hospital in Teluk Intan.\n\nh) When the staff purchase any hardware like cabinets, TV, Fridges, or washing machine, the staff must write a letter to the management to get the purchased item entered inside the estate. Cannot get the needy items immediately. In my daughter's case, I went and bought the TV, Fridge, and washing machine on one of the Saturdays, and the person to deliver these items cannot come inside even though my daughter call the person in charge Nanda Kumar A/L Veeramohan (Senior Assistant Manager). Nanda Kumar scolded my daughter and told "Ay stupid, don't you know today is Saturday and you are not allowed to bring any bought items inside. Write a letter first about why you don't have any common sense." \n\nI) In Division 1's grocery,' shops do not have sufficient household things. Workers need to order and wait for a long time.\n\n\n\n    Below snapshot is the code of conduct of the United plantation. It is clearly stated that bad faith allegation may result in disciplinary actions. Why Sasikalah A/P Kathirasen and Nanda Kumar A/L Veeramohan (Senior Assistant Manager) was not taken any disciplinary action and why the management forcing my daughter to resign?\n\n\n\n\n\n\n\n\n\nPlease do a drastic investigation by sending your people to the Jendarata Estate, 36009, Teluk Intan, Perak, Malaysia. \n\n\n\nGuys,\n\n\n\n       I am very serious about getting justice for my daughter's case as she was forced to resign from her position by Director Edward Rajkumar.                                                                                                Sasikala and Nanda Kumar (backup by HR Manager Methew and Director Edward Rajkumar) planning to bring in the former Radiograper Thirunna and get rid of my daughter through bullying and slavery treatment\n\n\n\nI have already escalated this matter to  International Labour Office (ILO), Geneva, and going to publish it in a local newspaper. Please look into this matter seriously as this is against human rights!	156
106	2022-10-14 17:06:43+00	t	MSPO Trace	155	2022-10-14	Berkenaan pendaftaran pembekal iaitu : Sen Heng Plantation Sdn Bhd, pembekal ini adalah 'certified'. Walaubagaimanapun, nama pembekal itu tiada dalam carian 'MSPO Certified Supplier'. Mohon tindakan lanjut daripada pihak tuan/puan. Terima kasih.	155
103	2022-07-04 11:17:08+00	t	Others	152	2022-07-04	Hi, im Head of Portfolio Reporting, Credit Risk Management of Agrobank. My team is currently assigned to prepare climate risk reports. We are facing difficulties to download all the small holder's listing from your website because there is no button/tab to click to download all which i find available under OPMC certified list & SCCS certified list. We require one off download to save time saving each page into excel and map with the Bank's customer database. Appreciate your assistance on this matter and do advice us should you require an official request letter from our CEO or CRO.	152
102	2022-06-30 12:35:34+00	t	MSPO Trace	151	2022-06-30	There is no "Download All" tab at Smallholders List website.  Need to access all list of company under Certified Independent Smallholders. The information will be used to produce report for bank.	151
101	2022-06-29 10:20:37+00	t	Non-compliance to MSPO Certification Scheme	150	2022-06-29	Ladang C&G membuang sisa bahan buangan terjadual ke dalam Sg. Trace.	150
100	2022-05-30 21:13:13+00	t	Non-compliance of national laws and regulations	149	2022-05-30	Dear Sir/Madam, \n\nRe : Grievance against Sawira Sdn Bhd \n\nI was hired by Sawira Sdn Bhd as General Manager on the 8th Feb 2021 with two years duration contract basis. \n\nSince January 2022, I had felt that the management had been ignoring me and the head office started directly dealing with my Estate Managers. \n\nAround this time, or in December 2022, the company staff had joined the union AMESU and I had brought the matter to the management via an email to the Group HR Manager which had no reply at all. Following which, I had in January 2022 submitted a staff salary revision scale in accordance to industrial standards range to the company and again I did not receive any reply from Group HR Manager who had later resigned in Feb 2022. Subsequent to this since March 2022, I am now being placed in cold storage, at Common Ground Office, Mont Kiara, Kuala Lumpur and I am made to only write company SOPs. I believe the joining of the staff with the Union could be a reason why I am being treated by the company unfairly though they have denied it. \n\nI had been instructed by my immediate superior that my managers no longer will report to me and I am not allowed to speak to anyone including suppliers, vendors, etc related to Sawira Sdn Bhd or its operational management. I am being told that I cannot even leave the Common Ground Office at Mont Kiara, Kuala Lumpur without prior permission including not allowed to go or visit the plantation estates unless otherwise instructed so.  \n\nI have written three letters to the company questioning the company’s action and reason (attached herewith). First letter dated 6th April 2022, they replied saying due to my health reason and that it's for my own good they decided so. To this I must say, they are merely making-up this as an excuse to me as I have no serious health concerns for the company to do so. I have replied denying that I have any health issues as so claimed by the company and no doctors had given me any unfit to work status. \n\nOn my second letter again sent on the April 2022 dated 15th April 2022, the company HR replied that on their record I am still the General Manager of Sawira Sdn Bhd and that the task of writing the SOPs is linked at their digitalization program that the company is undertaking. Following which, I had replied again (third letter dated 6th May 2022), stating that, I am willing to do a full medical checkup if the company had any concerns on my health and that otherwise, if I am considered the General Manager of Sawira, I should be allowed to return back to my company’s resident house at Ladang Sawira Utara at Muadzam Shah, Pahang and that all my authorities and powers as General Manager should be reinstated as normal. I am yet to receive a reply from the company and hence I am reporting this to MSPO as my grievance against the company for their unfair treatment given to me. \n\nI am feeling that the company is deliberately forcing me to resign by humiliating me and ignoring me making me feel unwanted or required.  \n\nI am placed in KL office at Co-shared office sitting at the Lobby (though after my first complain they did try to give another isolated open space sitting arrangement that is totally improper for a company GM) and only made to write SOPs and to-date since I am here, I am not even being called for any meetings or discussion. I am also been denied attending meetings representing the company with AMESU and any email response/reply from the company on AMESU matter is hidden from me, and including all company operational matters are directly communicated to the Estate Managers and staff without my knowledge. \n\nTrust that MSPO will look into my grievance and will stop this unfair treatment to myself and also ensure that the company look into the staff salary revision and their welfare as per AMESU and industrial practices.  \n\nLastly, as a point to note, MSPO should also investigate the company on foreign workers matters particularly the Bangladesh workers on why many had run away or returned back to their home country recently. This can have a serious consequence on our image of palm oil industry and Malaysia at large if it comes out later in the open. I am stating this matter here, as I have no part or role whatsoever to any ill treatment of foreign workers at Sawira Sdn Bhd should the matter comes out or be expose during the coming MSPO audit. As the General Manager, I have been denied the power to investigate, resolve or act on the matter accordingly at that time.  \n\nThank you  \n\nRavindran Veerasamy \n\nHp: 0125575446 \n\n\n\np/s : (i) Evidences on abuse done to Bangladesh workers for further investigation available.\n\n         (ii) The grievance complaint was also submitted on the MSPO Trace webpage on the 20th May 2022 but did not receive any login password or acknowledgement from the webpage system. \n\n	149
98	2022-05-30 12:00:17+00	t	Non-compliance of national laws and regulations	147	2022-05-30	Dear Sir/Madam,\n\nRe : Grievance against Sawira Sdn Bhd\n\nI was hired by Sawira Sdn Bhd as General Manager on the 8th Feb 2021 with two years duration contract basis.\n\nSince January 2022, I had felt that the management had been ignoring me and the head office started directly dealing with my Estate Managers.\n\nAround this time, or in December 2022, the company staff had joined the union AMESU and I had brought the matter to the management via an email to the Group HR Manager which had no reply at all. Following which, I had in January 2022 submitted a staff salary revision scale in accordance to industrial standards range to the company and again I did not receive any reply from Group HR Manager who had later resigned in Feb 2022. Subsequent to this since March 2022, I am now being placed in cold storage, at Common Ground Office, Mont Kiara, Kuala Lumpur and I am made to only write company SOPs. I believe the joining of the staff with the Union could be a reason why I am being treated by the company unfairly though they have denied it.\n\nI had been instructed by my immediate superior that my managers no longer will report to me and I am not allowed to speak to anyone including suppliers, vendors, etc related to Sawira Sdn Bhd or its operational management. I am being told that I cannot even leave the Common Ground Office at Mont Kiara, Kuala Lumpur without prior permission including not allowed to go or visit the plantation estates unless otherwise instructed so. \n\nI have written three letters to the company questioning the company’s action and reason (attached herewith). First letter dated 6th April 2022, they replied saying due to my health reason and that its for my own good they decided so. To this I must say, they are merely making-up this as an excuse to me as I have no serious health concerns for the company to do so. I have replied denying that I have any health issues as so claimed by the company and no doctors had given me any unfit to work status.\n\nOn my second letter again sent on the April 2022 dated 15th April 2022, the company HR replied that on their record I am still the General Manager of Sawira Sdn Bhd and that the task of writing the SOPs is linked at their digitalization program that the company is undertaking. Following which, I had replied again (third letter dated 6th May 2022), stating that, I am willing to do a full medical check up if the company had any concerns on my health and that otherwise, if I am considered the General Manager of Sawira, I should be allowed to return back to my company’s resident house at Ladang Sawira Utara at Muadzam Shah, Pahang and that all my authorities and powers as General Manager should be reinstated as normal. I am yet to receive a reply from the company and hence I am reporting this to MSPO as my grievance against the company for their unfair treatment given to me.\n\nI am feeling that the company is deliberately forcing me to resign by humiliating me and ignoring me making me feel unwanted or required. \n\nI am placed in KL office at Co-shared office sitting at the Lobby (though after my first complain they did try to give another isolated open space sitting arrangement that is totally improper for a company GM) and only made to write SOPs and to-date since I am here, I am not even being called for any meetings or discussion. I am also been denied attending meetings representing the company with AMESU and any email response/reply from the company on AMESU matter is hidden from me, and including all company operational matters are directly communicated to the Estate Managers and staff without my knowledge.\n\nTrust that MSPO will look into my grievance and will stop this unfair treatment to myself and also ensure that the company look into the staff salary revision and their welfare as per AMESU and industrial practices. \n\nLastly, as a point to note, MSPO should also investigate the company on foreign workers matters particularly the Bangladesh workers on why many had run away or returned back to their home country recently. This can have a serious consequence on our image of palm oil industry and Malaysia at large if it comes out later in the open. I am stating this matter here, as I have no part or role whatsoever to any ill treatment of foreign workers at Sawira Sdn Bhd should the matter comes out or be expose during the coming MSPO audit. As the General Manager, I have been denied the power to investigate, resolve or act on the matter accordingly at that time. \n\nThank you \n\nRavindran Veerasamy\n\nHp: 0125575446\n\n \n\n	147
97	2022-05-27 10:14:55+00	t	MSPO Trace	146	2022-05-27	We had case where we cant identify different supplier for the same name. The supplier company got several collecting centre and had different MPOB license with different location , but shared the same entiti name. so when we tried to register non certified supplier with different mpob number, unfortunately we cant register the name because it was already registered. 	146
96	2022-05-24 14:18:35+00	t	Non-compliance of national laws and regulations	145	2022-05-24	test test test test test test test test test test test test test	145
95	2022-05-20 18:22:36+00	t	Others	144	2022-05-20	Sarananas Enterprise SDN. BHD company trespassing and carrying out large-scale oil palm cultivation activities on Bumiputera Customary Rights Land (NCR) of the Melanau Community and the Iban Community from Sungai Ilas, Batang Igan. Sibu.	144
94	2022-05-20 14:27:29+00	t	Non-compliance of national laws and regulations	143	2022-05-20	Dear Sir/Madam,\n\nRe : Grievance against Sawira Sdn Bhd\n\nI was hired by Sawira Sdn Bhd as General Manager on the 8th Feb 2021 with two years duration contract basis.\n\nSince January 2022, I had felt that the management had been ignoring me and the head office started directly dealing with my Estate Managers.\n\nAround this time, or in December 2021, the company staff had joined the union AMESU and I had brought the matter to the management via an email to the Group HR Manager which had no reply at all. Following which, I had in January 2022 submitted a staff salary revision scale in accordance to industrial standards range to the company and again I did not receive any reply from Group HR Manager who had later resigned in Feb 2022. Subsequent to this since March 2022, I am now being placed in cold storage, at HQ Office at Common Ground Office, Mont Kiara, Kuala Lumpur and I am made to only write company SOPs. I believe the joining of the staff with the Union could be a reason why I am being treated by the company unfairly though they have denied it.\n\nI had been instructed by my immediate superior that my managers no longer will report to me and I am not allowed to speak to anyone including suppliers, vendors, etc related to Sawira Sdn Bhd or its operational management. I am being told that I cannot even leave the Common Ground Office at Mont Kiara, Kuala Lumpur without prior permission including not allowed to go or visit the plantation estates unless otherwise instructed so. \n\nI have written three letters to the company questioning the company’s action and reason (attached herewith). First letter dated 6th April 2022, they replied saying due to my health reason and that its for my own good they decided so. To this I must say, they are merely making-up this as an excuse to me as I have no serious health concerns for the company to do so. I have replied denying that I have any health issues as so claimed by the company and no doctors had given me any unfit to work status.\n\nOn my second letter again sent on the April 2022 dated 15th April 2022, the company HR replied that on their record I am still the General Manager of Sawira Sdn Bhd and that the task of writing the SOPs is linked at their digitalization program that the company is undertaking. Following which, I had replied again (third letter dated 6th May 2022), stating that, I am willing to do a full medical check up if the company had any concerns on my health and that otherwise, if I am considered the General Manager of Sawira, I should be allowed to return back to my company’s resident house at Ladang Sawira Utara at Muadzam Shah, Pahang and that all my authorities and powers as General Manager should be reinstated as normal. I am yet to receive a reply from the company and hence I am reporting this to MSPO as my grievance against the company for their unfair treatment given to me.\n\nI am feeling that the company is deliberately forcing me to resign by humiliating me and ignoring me making me feel unwanted or required. \n\nI am placed in KL office at Co-shared office sitting at the Lobby (though after my  complain they did try to give another isolated open space sitting arrangement that is totally improper for a company GM) and only made to write SOPs and to-date since I am here, I am not even being called for any meetings or discussion. I am also been denied attending meetings representing the company with AMESU and any email response/reply from the company on AMESU matter is hidden from me, and including all company operational matters are directly communicated to the Estate Managers and staff without my knowledge.\n\nTrust that MSPO will look into my grievance and will stop this unfair treatment to myself and also ensure that the company look into the staff salary revision and their welfare as per AMESU and industrial practices. \n\nLastly, as a point to note, MSPO should also investigate the company on foreign workers matters particularly the Bangladesh workers on why many had run away or returned back to their home country recently. This can have a serious consequence on our image of palm oil industry and Malaysia at large if it comes out later in the open. I am stating this matter here, as I have no part or role whatsoever to any ill treatment of foreign workers at Sawira Sdn Bhd should the matter comes out or be expose during the coming MSPO audit. As the General Manager, I have been denied the power to investigate, resolve or act on matter accordingly at that time. \n\nThank you \n\nRavindran Veerasamy\n\nHp: 0125575446\n\n	143
92	2022-04-15 08:13:24+00	t	Others	141	2022-04-15	I fill this in this form as requested by u, I have email to CEO MPOCC in January 2022	141
91	2022-04-14 13:50:18+00	t	Others	140	2022-04-14	 I would like to lodge a formal complaint regarding the non compliance  to MSPO Certification Scheme currently practice by Ecco Certified\n\n\n\nBased on the review conducted on their Linkedin  Auditor Ecco Certified Profile for  MUHAMAD NAZRAN NAZARNO  - Link  https://www.linkedin.com/in/nazran/ and  Mr Amirul Arif - Link https://www.linkedin.com/in/amirul-arif-1a0845202/ ,  I found that Mr Nazran just completed his degree in 2017 while Mr Amirul Arif just completed his degree in 2018 . Mr Nazran has only had total working experience 2 year  6 month , while Mr Amirul only has working experience in oil palm sector 1 year 1 Month. The working experience for both auditor was not inline with the requirement stated in Table 1 OPMC 1 which require the auditor to have at least 7 years of work experience in oil palm sector. Refer to attachment - copy of the public summary report for company  - Tay Plantation Sdn Bhd audited by both auditors on 20th January 2021 in the chapter - Audit team auditor profile, Mr Nazran has acknowledged that he only has 2 years of working experience in oil palm sector.  \n\n\n\nkindly need your attention on this matter.  Thank you. \n\n\n\nKindly maintain the confidentiality of my identity.	140
99	2022-05-30 12:13:23+00	t	Non-compliance of national laws and regulations	148	2022-05-30	Dear Sir/Madam,\n\nRe : Grievance against Sawira Sdn Bhd\n\nI was hired by Sawira Sdn Bhd as General Manager on the 8th Feb 2021 with two years duration contract basis.\n\nSince January 2022, I had felt that the management had been ignoring me and the head office started directly dealing with my Estate Managers.\n\nAround this time, or in December 2022, the company staff had joined the union AMESU and I had brought the matter to the management via an email to the Group HR Manager which had no reply at all. Following which, I had in January 2022 submitted a staff salary revision scale in accordance to industrial standards range to the company and again I did not receive any reply from Group HR Manager who had later resigned in Feb 2022. Subsequent to this since March 2022, I am now being placed in cold storage, at Common Ground Office, Mont Kiara, Kuala Lumpur and I am made to only write company SOPs. I believe the joining of the staff with the Union could be a reason why I am being treated by the company unfairly though they have denied it.\n\nI had been instructed by my immediate superior that my managers no longer will report to me and I am not allowed to speak to anyone including suppliers, vendors, etc related to Sawira Sdn Bhd or its operational management. I am being told that I cannot even leave the Common Ground Office at Mont Kiara, Kuala Lumpur without prior permission including not allowed to go or visit the plantation estates unless otherwise instructed so. \n\nI have written three letters to the company questioning the company’s action and reason (attached herewith). First letter dated 6th April 2022, they replied saying due to my health reason and that its for my own good they decided so. To this I must say, they are merely making-up this as an excuse to me as I have no serious health concerns for the company to do so. I have replied denying that I have any health issues as so claimed by the company and no doctors had given me any unfit to work status.\n\nOn my second letter again sent on the April 2022 dated 15th April 2022, the company HR replied that on their record I am still the General Manager of Sawira Sdn Bhd and that the task of writing the SOPs is linked at their digitalization program that the company is undertaking. Following which, I had replied again (third letter dated 6th May 2022), stating that, I am willing to do a full medical check up if the company had any concerns on my health and that otherwise, if I am considered the General Manager of Sawira, I should be allowed to return back to my company’s resident house at Ladang Sawira Utara at Muadzam Shah, Pahang and that all my authorities and powers as General Manager should be reinstated as normal. I am yet to receive a reply from the company and hence I am reporting this to MSPO as my grievance against the company for their unfair treatment given to me.\n\nI am feeling that the company is deliberately forcing me to resign by humiliating me and ignoring me making me feel unwanted or required. \n\nI am placed in KL office at Co-shared office sitting at the Lobby (though after my first complain they did try to give another isolated open space sitting arrangement that is totally improper for a company GM) and only made to write SOPs and to-date since I am here, I am not even being called for any meetings or discussion. I am also been denied attending meetings representing the company with AMESU and any email response/reply from the company on AMESU matter is hidden from me, and including all company operational matters are directly communicated to the Estate Managers and staff without my knowledge.\n\nTrust that MSPO will look into my grievance and will stop this unfair treatment to myself and also ensure that the company look into the staff salary revision and their welfare as per AMESU and industrial practices. \n\nLastly, as a point to note, MSPO should also investigate the company on foreign workers matters particularly the Bangladesh workers on why many had run away or returned back to their home country recently. This can have a serious consequence on our image of palm oil industry and Malaysia at large if it comes out later in the open. I am stating this matter here, as I have no part or role whatsoever to any ill treatment of foreign workers at Sawira Sdn Bhd should the matter comes out or be expose during the coming MSPO audit. As the General Manager, I have been denied the power to investigate, resolve or act on the matter accordingly at that time. \n\nThank you \n\nRavindran Veerasamy\n\nHp: 0125575446\n\n \n\nEvidences on foreign  workers abuse available via photo and videos for further investigation	148
117	2023-05-12 07:50:54+00	t	Non-compliance to MSPO Certification Scheme	175	2023-05-12	I prepared documents for payroll of our building artisan and submit to Factory Management Mr Chua Teck Ngin whom at that point of time temporarily overseeing Estate operation for his signature. Before hand, estate management had an written agreement with building artisan which mutually agreed on the work to be done and pricing. However, Mr Chua Teck Ngin refused to release the payment to these building artisan and stated that they had basic salary. I explained to him that the work has been done and we need to pay them for the work done in April 2023. He still insisted and instructed me to amend their payroll which later on I refused to do so because it is against Employment Act 1955. He then instructed Administrative Manager standby Ms Soh Yoke Kam (at that point of time, she was no longer in charge payroll) to amend the payroll and assisted by Zailalawati (admin staff). They amended the payroll during my absence and it was a public holiday. Mr Chua Teck Ngin threatened me of not following his instruction and requested me just follow his instructions. Ms Soh Yoke Kam turned off CCTV in the office during my absence especially CCTV that is facing armoury room. It is against Akta Agensi Persendirian 1971. I feel very uneasy on their attitude and action.	175
116	2023-02-03 14:24:55+00	t	Non-compliance to MSPO Certification Scheme	165	2023-02-03	This complaint was raised for EAST WEST HORIZON PLANTATION BERHAD, DALIT LAUT. The detail of complaint was as per stated in the standard. However, there were complaints raised not related to the indicator but still it did not comply with the standard (another indicator).\n\n\n\n4.2.1.4 Indicator 4: The organisation shall provide information requested by relevant stakeholders\n\nand management documents shall be publicly available, except those limited by commercial\n\nconfidentiality or disclosure that could result in negative environmental or social outcomes. Information\n\nand documents shall be in appropriate languages and forms.\n\n\n\nComplaint: The management did not include all the relevant stakeholders during stakeholder consultation, the minutes of the meeting were not publicly available upon request. The plantation area was established at the area that classified as "communal land" thus the owner was the member of local community and being developed by appointed company. However, not all the participants were consulted during the stakeholder consultation and the community representative appointed by the company did not deliver the outcome of the consultation. This creates inaccurate information for the participants and results in dissatisfaction in regards with the payment of the dividen. The participant was also not aware of the complaint and grievance procedure of the company, this was also related to the payment of the dividen. Also, our contract with the company was not delivered to all the participants, it was only kept by the representative that being appointed by the company. During mspo external audit, we were not informed by the company or there is no notification regarding their stakeholder consultation. The company name is also different in the sites where it is called "Perintis Jati" and not "EAST WEST HORIZON PLANTATION BERHAD", this also creates confusion among the landowners. There were several disputes regarding the dividen payment, and no proper resolution was conducted. 	165
115	2023-02-03 07:23:41+00	t	Others	164	2023-02-03	Encroaching on indigenous land by planting palm oil on peatland. In March 2022. The villagers and I saw the land bulldozers encroaching on the native area without talking to the natives. besides that, our farm was also invaded and the old grave of our village was destroyed. The encroachment of this peatland causes fires and the destruction of orchards affected by dry marshland. The party that encroached on our land is the PASFA company. We request that the PASFA company immediately stop the cultivation of palm oil on our traditional heritage land, thank you	164
113	2023-01-11 11:06:42+00	t	Others	162	2023-01-11	Complaint on Rate of Freelance auditor.\n\n\n\nHope MPOCC can monitor and control the price ceiling and price floor for the freelance auditor. Lately, PSV Certification has reduced tremendously to a minimum of RM400/day (Co-auditor) without any discussion earlier.  As freelancers, that price was not acceptable because we are also bearing the cost of EPF, SOCSO, Takaful/insurance & meals on our own. Looking forward to the MSPO 2.0 requirement and the competency of the auditor is higher up and it was not parallel with the rate made by the CB. We are taking care of workers' welfare in the estates and mills, but we forgot to ensure the person who carries out the job is paid equally. Hope MPOCC can look into this matter. I am not appointing PSV only but also the other CBs for further enhancement purposes. Please contact me anytime for further explanation. Thank you.	162
112	2023-01-10 17:14:35+00	t	Non-compliance to MSPO Certification Scheme	161	2023-01-10	1. Kampung Tudan Ujung Daun villager is not given any compensation starting from 2013 until now by the palm oil company (WTK, Rimbunan Hijau and Woodman). \n\n\n\n2. During signing the Agreement Black and white between palm company and villager on 2011, the villagers is not allowed to review the contract contents. (Suspicious act by the company).\n\n3. The usage of (NCR/PULAU GALAU & PEMAKAI MENUA) by palm oil company no compensation is given to the villagers since 2013 until now.\n\n4. The usage of villagers land perimeters is not according to the agreement. (Plantation is very near to the long house area)\n\n5. No land space/capacity for The villagers to build a new Long house due to palm oil plantation area is too compact around the villagers land.\n\n6. Agreed bussines such as canteen/groceries stores at the palm area is not given to the villager. (Company promise to give the Bussiness opportunity to the villagers.)\n\n7. Job opportunity is not given to the villagers.\n\n8. This case document already submitted to lawyer but villager haven't proceed to file a lawsuit.	161
130	2023-08-17 10:08:32+00	t	Non-compliance of national laws and regulations	182	2023-08-17	RSPO requirement for land development	182
125	2023-05-11 15:59:10+00	t	Non-compliance to MSPO Certification Scheme	173	2023-05-11	I worked as building artisan since 1 February 2023 with Keck Seng (Malaysia) Berhad on Estate office renovation. I have an agreement on price for office renovation work with General Manager (Mr Vincent Hee Vui Yong) in which mutually agreed. However, employer representative from factory management in Keck Seng (Malaysia) Berhad Mr Chua Teck Ngin that was temporarily overseeing estate operation when Mr Vincent Hee is not presence, he amended my salary without me agreeing. The amendment was done by Administrative Manager standby Soh Yoke Kam and admin staff Zailalahwati Binti Omar @ Yusof. I would like to complain Mr Chua Teck Ngin, Soh Yoke Kam and Zailalawati binti Omar @ Yusof because they amended my salary without me agreeing and did not pay me in full amount for April 2023 in which the work has been completed by end of April 2023.	173
124	2023-05-11 14:30:13+00	t	Non-compliance to MSPO Certification Scheme	172	2023-05-11	I worked as building artisan since 1 February 2023 with Keck Seng (Malaysia) Berhad on Estate office renovation. I have an agreement on price for office renovation work with General Manager (Mr Vincent Hee Vui Yong) in which mutually agreed. However, employer representative from factory management in Keck Seng (Malaysia) Berhad Mr Chua Teck Ngin that was temporarily overseeing estate operation when Mr Vincent Hee is not presence, he amended my salary without me agreeing. The amendment was done by Administrative Manager standby Soh Yoke Kam and admin staff Zailalahwati Binti Omar @ Yusof. I would like to complain Mr Chua Teck Ngin, Soh Yoke Kam and Zailalawati binti Omar @ Yusof because they amended my salary without me agreeing and did not pay me in full amount for April 2023 in which the work has been completed by end of April 2023. \n\nFurthermore, I was not given a copy of my work agreement.	172
123	2023-05-11 14:26:22+00	t	Non-compliance to MSPO Certification Scheme	171	2023-05-11	I worked as building artisan since 1 February 2023 with Keck Seng (Malaysia) Berhad on Estate office renovation. I have an agreement on price for office renovation work with General Manager (Mr Vincent Hee Vui Yong) in which mutually agreed. However, employer representative from factory management in Keck Seng (Malaysia) Berhad Mr Chua Teck Ngin that was temporarily overseeing estate operation when Mr Vincent Hee is not presence, he amended my salary without me agreeing. The amendment was done by Administrative Manager standby Soh Yoke Kam and admin staff Zailalahwati Binti Omar @ Yusof. I would like to complain Mr Chua Teck Ngin, Soh Yoke Kam and Zailalawati binti Omar @ Yusof because they amended my salary without me agreeing and did not pay me in full amount for April 2023 in which the work has been completed by end of April 2023. \n\nFurthermore, I was instructed by Assistant Manager Mohamad Syafik bin Saharuddin (950731-05-5561) to work on public holiday (Hari Raya) for 12 hours as Security Officer due to inadequate manpower during Hari Raya. I noticed I did not received pay for working during public holiday and overtime. \n\nI was not given a copy of my work agreement.	171
122	2023-05-04 10:16:57+00	t	Others	170	2023-05-04	LAPORAN PENCEROBOHAN TANAH SIMPANAN JALAN LAMA SANDAKAN KAMPUNG KITAGAS BATU 27 SANDAKAN	170
121	2023-03-18 11:03:25+00	t	MSPO Trace	169	2023-03-18	ALWAYS LOG OUT BY ITSELF, AFTER THAT CAN'T LOG IN AGAIN, HAVE TO USE ANOTHER CHROME TO LOG IN, PLEASE FIX IT, TROUBLESOME	169
120	2023-02-25 09:27:58+00	t	Non-compliance to MSPO Certification Scheme	168	2023-02-25	Detected open burning in PKNP’s Ladang Tembeling in Pahang.	168
119	2023-02-18 10:21:56+00	t	Non-compliance to MSPO Certification Scheme	167	2023-02-18	To Whom May Concern,\n\n\n\nDear Sir/Madam,\n\n\n\nComplaints under type of;\n\n\n\n1. Non-compliance to MSPO Certification Scheme\n\n2. Non-compliance of national laws and regulations\n\n\n\n3. Non- compliance as vendor wrongdoing (OCP Supplier to KKS KOK FOH) with respect to;\n\n    - acts or omissions which are deemed to be against the interest of the Company, laws, regulations or        public policies.\n\n    - breaches of Group Policies and Code of Business Conduct (COBC)\n\n\n\nComplaints Details:\n\nWe urged the MSPO body to conduct an investigation on above mentioned complaints type on following basis;\n\n\n\nOn last 3.02.2023 at 1.30am the Immigration Department conducted raid operation at Ladang Cheong Wing Chan, Batu 4 1/2, Jalan Rompin, 72109 Bahau, Negeri Sembilan and arrested 38 illegal Indonesian nationals which hired by the estate management under contractors for harvesting works. The immigration department issued notice to the estate manager for sheltering and employing undocumented migrants. According to the Section 56(1)(d) of the Immigration Act 1959/63 and Section 55B of the same Act those found guilty of sheltering or employing undocumented migrants can be fined up to RM50,000. In addition to the fines, offenders can also be sentenced to prison or given six strokes of the cane if convicted.\n\n\n\nSince 2019 up-to present the estate management fully operating by using illegal immigrant workers which against the MSPO as per;   \n\n\n\n4.3 Compliance to Legal Requirements\n\n\n\n    Fail to adhere and meet the compliance of Legal requirements.\n\n\n\n4.4.1 Social Impact procedure\n\n\n\nFail to cover social impact on factors such as other community values, resulting from changes in     improvement of transport/communication/ influx of migrant labour force and forced or compulsory labour.\n\n\n\n4.6 Best Practice\n\nThe estate management and assigned contractors failed to adhere the MSPO certification scheme.\n\n\n\nEnclosed herewith the supporting documents for the complaints for your further action. We hoping the MSPO will take meaningful and timely action to the company involved. This not only calls into question the MSPO's commitment to address environmental and social problems, but also how credible the certification system is in addressing the continued problems in the palm oil industry.\n\n\n\nThank you.	167
143	2024-07-12 15:52:00+00	t	Others	202	2024-07-12	Ladang Kok foh tanam bahan buangan dlm kawasan ladang	202
140	2024-04-08 11:48:43+00	t	MSPO Trace	194	2024-04-08	CANNOT REGISTER NON-MSPO FOR MY DILLER ( B.P. SENGKUANG PLANTATION SDN BHD, MPOB LICENSE NO. 579993001000). ALREADY KEY IN THE MPOB LICENSE BUT THE STATUS SHOW NOT VALID.	194
142	2024-06-09 23:55:47+00	t	Non-compliance of national laws and regulations	200	2024-06-09	To whom it may concern, I would like to inform you that I have conducted several MSPO Audit for Care Certification International for the past few months. I have conducted the audit and completed the reports as required. I have submitted the invoice to CCI for my job claim. However, after almost more than one month, I didn't receive any payment. My payment terms are 30 days. Someone at CCI has informed me that the company doesn't want to pay me for my work. The pending payment amount is around 10,000 ringgit. This issue has disturbed my financial situation. Attached herewith is the relevant invoice combined for your reference (Invoices 344, 345, and 346). Please advice. Thank you.	200
139	2024-03-25 15:55:03+00	t	MSPO Trace	193	2024-03-25	Tidak dapat log in sistem. Kami telah cuba untuk log in banyak kali, tetap sama. Kami juga telah cuba 'forget password' tapi juga gagal untuk log in.	193
126	2024-03-09 13:04:46+00	t	MSPO Trace	192	2024-03-09	Kilang Kelapa Sawit kami telah menerima pembekal buah (Estate Luar) yang memiliki 5 entiti ; 4 entiti yang mempunyai Pensijilan MSPO dan 1 entiti yang tidak memiliki Pensijilan MSPO. Entiti yang tidak memiliki Pensijilan MSPO ini merupakan syarikat yang baru sahaja bertukar pengurusan dan ianya masih dalam proses pertukaran nama. Pembekal buah tersebut telah memberikan lesen MPOB yang baharu. Pihak kami ingin mendaftarkan entiti tersebut di dalam NON-CERTIFIED. Namun, MPOB lesen tersebut di bawah nama entiti yang telah memiliki Pensijilan MSPO. Hal ini menyukarkan kami untuk menghantar laporan MSPO Trace. Pihak kami telah mengajukan laporan melalui e-mel (info@mpocc.org.my, info@mspotrace.org.my, dan emu@mpocc.or)	192
137	2024-02-14 08:24:29+00	t	MSPO Trace	190	2024-02-14	Good morning, regarding to the attached file, it shows that section C cannot appear anything that I have key in to the system even though I already upload the template. So that, after I click Button Finish there are also nothing save in system. So that i hope your site can help me to settle the problem.TQ	190
136	2024-01-19 14:59:36+00	t	Others	189	2024-01-19	MSPO SCCS certificate validity. Kindly justify the validity of a certificate which effective date & recertification date is not stated. Can palm oil mill sell CPO/kernel to the certificate holder if the buyer do not hold a valid MSPO SCCS certificate?	189
135	2023-12-12 15:21:42+00	t	Others	188	2023-12-12	Assalamualaikum dan selamat petang. Saya mewakili Bahagian Penilaian dan Pengurusan Harta MDGM ingin menanyakan soalan dan memohon pandangan atau pendapat daripada pihak tuan berkenaan dengan permasaalahan yang akan kami ajukan ini. Untuk makluman tuan, Majlis Daerah Gua Musang telah mengenakan cukai taksiran kepada tanah pertanian ladang yang dibangunkan dalam Kawasan Majlis Daerah Gua Musang. Berhubung dengan perkara ini, ada beberapa lot ladang yang telah dikenakan cukai taksiran dan mempunyai tunggakan yang masih belum diselesaikan. Kami di pihak MDGM telah membuat pelbagai perkara untuk menyelesaikan perkara ini. Namun masih belum berjaya. Oleh yang demikian, kami memohon pandangan daripada pihak tuan, jika ada jalan-jalan yang boleh dilalui bagi membantu pihak kami menyelesaikan permasalahan ini contohnya (pemilik ladang yang ingin menyambung lesen MPOB hendaklah mendapat kelulusan MDGM- tiada tunggakan cukai taksiran) atau mana-mana kaedah yang dirasakan patut. Untuk makluman tuan,  hasil daripada pungutan cukai taksiran akan digunakan untuk membangun kawasan bandar seperti selian lampu jalan, perkhidmatan taman rekreasi, lanskap dan lain-lain bagi kegunaan awam.---	188
134	2023-11-11 11:49:02+00	t	MSPO Trace	187	2023-11-11	To whom it may concern, I found that some of our existing Supplier and Buyer registration have missing since MSPO Trace system updated. Our previous record on MSPO Sales Announcement also have lost and need to be key in again. Kindly please look into it and assist us on how to retrieved the previous data again. You may refer to the attached file. Thank you.	187
133	2023-09-13 17:33:23+00	t	Others	186	2023-09-13	untuk nombor siri sijil MSPO di ladang, kami ingin menukar CB adakah no siri akan berubah atau kekal?. No siri MSPO akan digunakan untuk urusan surat menyurat untuk urusan ke kilang dan sebagainya. Kami mencadangkan pihak MPOCC selaraskan semua versi no siri antara CB untuk membantu meningkatkan kualiti pengurusan.	186
47	2020-08-16 01:33:55+00	t	Others	81	2020-08-16	We have obtained our MSPO certification part 3 on 06th December 2019 and we have submitted our claim by hand to MPOCC staff on 18th March 2020 at NIOSH bangi. We have emailed Mr Tan on 20th July 2020 to request for the status of the claim, but Mr Tan inform us that our application still in queue to be process due to large volume of application and the closure of MPOCC office due to MCO. Our management has queried on delay of the claim and we as sustainability officer unable to explain to our management since we don't know the progress of the claim and it's hard for us to convince our management to continue doing the surveillance audit. So, we would like to suggest if MPOCC can create any system for the companies to monitor on the progress of the claim. We hope that MPOCC can revert on this matter as soon as possible. Thanks.	81
37	2020-08-16 01:07:44+00	t	Others	73	2020-08-16	We have obtained our MSPO certification part 3 on 01st October 2019 and we have submitted our claim by hand to MPOCC staff on 18th March 2020 at NIOSH bangi. We have emailed Mr Tan on 20th July 2020 to request for the status of the claim, but Mr Tan inform us that our application still in queue to be process due to large volume of application and the closure of MPOCC office due to MCO. Our management has queried on delay of the claim and we as sustainability officer unable to explain to our management since we don't know the progress of the claim and it's hard for us to convince our management to continue doing the surveillance audit. So, we would like to suggest if MPOCC can create any system for the companies to monitor on the progress of the claim. We hope that MPOCC can revert on this matter as soon as possible. Thanks.	73
10	2025-02-04 09:13:55+00	t	Others	210	2025-02-04	Investigation Request Regarding the Palm Oil Plantation Organizations &amp; Competency of Auditor \n\nOrganization Name and Address: FIRST BINARY PLANTATION (869696-M)\n\nNo.36, 3rd Floor, Jalan Keranji, 96000 Sibu, Sarawak\n\nEstate Address/Location: Lot 3, Stungkor Land District, Lundu, Sarawak\n\nAudit Reference Standards: MS2530-3\n\nCertification Body: DIMA\n\nIt has been found that the MSPO certification granted to the organization as mentioned above is inappropriate. This is because the organization does not meet the mandatory criteria outlined for MSPO certification compliance. Awarding the certification has provided the organization, especially the upper management, with greater opportunities to exploit and neglect the lower workers, particularly foreign workers. This is because the certification was granted despite the organization failing to comply with or meet the mandatory criteria required for certification.\n\nBelow are examples of the neglect and exploitation carried out by this organization:\n\n1. Exploitation and Neglect in Terms of Worker Benefits (Accommodation, Safety):\n\nThe workers' accommodation does not meet the minimum requirements set by the Workers' Housing Act. Workers are not provided with adequate personal safety equipment.\n\n2. Exploitation and Neglect in Terms of Foreign Worker Salaries:\n\nWorkers are not paid in cash. Their salaries are kept by the management and are only given to the workers when they return to their home country.\n\n3. Exploitation and Neglect of Social Responsibility to the Surrounding Community:\n\nThe organization neglects its social responsibility toward the local community.\n\n4. Exploitation and Neglect of Compliance with Environmental Protection Requirements:\n\nThe most notable issue is the lack of efforts to establish a &quot;Buffer Zone,&quot; which is a mandatory environmental compliance requirement.\n\n5. Neglect of Other Mandatory Compliance Requirements:\n\nThe organization has continuously failed to meet other basic mandatory compliance standards and has shown no consistent effort to make improvements.\n\nThe organization has also violated the core principles of MSPO, which are the 3 P's (Profit, People, Planet). The organization is solely focused on &quot;Profit,&quot; deliberately neglecting &quot;People&quot; and &quot;Planet.&quot;\n\nTherefore, it is requested that the relevant authorities review this report and immediately conduct an investigation into this organization and the parties involved in the certification process. This is due to concerns that the certification body and the auditors may also lack competence in this matter. It is unjust to those organizations that have worked diligently and invested significant resources to obtain the certification, but due to the greed of certain organizations and auditors, this leads to dissatisfaction among those who are genuinely following the proper procedures.\n\nIf this situation continues or becomes public, it is believed that it will have a significant negative impact on the credibility of the certification bodies and auditors involved. Specifically, MSPO may also face backlash, damaging its public image. Thank you.	210
144	2024-07-20 08:03:12+00	t	Non-compliance to MSPO Certification Scheme	203	2024-07-20	By way of background, we, Mukah Kilang Kelapa Sawit Sdn. Bhd. had diverted our FFBs to Sarawak Plantation Agriculture Development Sdn. Bhd. (hereinafter referred to as SPAD) during mill’s breakdown and the FFBs diversion was from 22/05/2024 to 25/05/2024. \n\n\n\nOn 15/06/2024, we wrote to SPAD to express our grievance regarding the arbitrary OER deduction of 1.25% by SPAD. However, as of our official complaint to MSPO on 20/07/2024, SPAD has failed to provide any meaningful written response despite our follow-ups on 21/06/2024, 02/07/2024, and 12/07/2024.\n\n\n\nWe understand that SPAD might want to argue that the OER deduction was made in accordance with MPOB’s guideline. However, we wish to bring your attention to Clause 4.1.3 of Manual Penggredan Buah Kelapa Sawit MPOB which read “Asing dan keluarkan semua Tandan Muda dan Tandan Peram daripada konsainan dan pulangkan kepada pembekal”.\n\nBased on SPAD’s grading form, there were Tandan Muda in all of our consignments, but none of the purported Tandan Muda were returned to us. This is because the parties have a mutual understanding that FFBs found to be of poor quality and not acceptable by SPAD would be returned to us upon completion of grading instead of deducting the pre-determined OER.\n\nAs such, we wish to bring to your attention that SPAD has failed to comply with the following indicators under Malaysian Sustainable Palm Oil (MSPO) 2530:2013\n\n4.6.3.1 \tPricing mechanisms for the products and other services shall be documented and effectively implemented. \n\n\n\n4.6.3.2 \tAll contracts shall be fair, legal and transparent and agreed payments shall be made in a timely manner.	203
145	2024-08-28 17:15:48+00	t	Non-compliance of national laws and regulations	204	2024-08-28	To obtain a MSPO certificate do I need a legal document such as land title or land under Section 18 of Sarawak Land Code; or customary tenure (communal forest) or use rights (as stated in the land gazettment).	204
149	2025-01-16 18:41:39+00	t	Others	209	2025-01-16	Dear Sir/ Madam, \n\nI, Rajendran A/L Subramanian (651110-08-5551) would like to complaint regarding the wrongly positioned &amp; constructed ditch (Parit) which falls on my land Plot No: 13208. This ditch (Parit) is supposed to be constructed on the given Reserved space (Simpanan Jalan). But the reserved space (Simpanan Jalan) already utilized for their oil palm plantation and there is no access road for my land Plot No: 13206-13208. This problem is caused by the owner of Plot No: 10471 (Maju Melintang Estate). \n\nFor your kind information, I have already discussed with the General Manager of Maju Melintang Estate Mr. Kagenthiran regarding the issue above. But no any positive actions were taken so far.\n\nPlease find the attached PELAN PINTA UKUR KELILING/PERIMETER for your reference.\n\nI hope for a favorable reply &amp; action from you as soon as possible. Please do not hesitate to contact me if required any further information or for discussion. \n\n\n\nThank you,\n\nMr.Rajendran,\n\nPhone number: 0195706090.	209
148	2025-01-02 18:12:57+00	t	Non-compliance to MSPO Certification Scheme	208	2025-01-02	it was found that the farm planted scheduled waste materials and poisoned the HCV area.	208
147	2025-01-02 15:52:27+00	t	MSPO Trace	207	2025-01-02	Testing for Compliance Functionality	207
146	2024-12-03 18:25:46+00	t	Non-compliance of national laws and regulations	206	2024-12-03	ADUAN RISWAN RASID (18 NOVEMBER 2024)_GOLDEN AGRO PLANTATION	206
141	2024-06-04 22:12:09+00	t	Non-compliance to MSPO Certification Scheme	198	2024-06-04	Dear Sir. I would like to make a  report. I hereby would like to inform you that Care Certification International didn't conduct several MSPO audit according to MSPO OPMC requirements, where the audit was conducted without sufficient Mandays as required. Among the audited client involved are,  1) MSPO Part3 SAV4 - OIB Properties Group: 2 person per days for site more than 100 hectares 2) MSPO Part 3 MAV- Felda Gugusan Bukit Sagu: Only Two auditors per site for estate sized more than 500 hectares. 3) MAV MSPO Part 3 - FELDA Gugusan Serting Hilir: 3 auditors for each site that is more than 500 hectares. To make it worse, One of the auditors team (Nurul Afnie) in OIB Properties Group and FELDA Gugusan Serting Hilir are not competent to conduct OPMC 2013. She didn't attended MSPO 2013 Auditor course, but also calculated int the mandays. I have raise my concern to CCI management regarding this issue, but not response. This issue does not limited to only this 3 sites but in many occasions. Attached herewith one audit sample report for your kind perusal. Thank you.	198
87	2024-05-27 21:15:43+00	t	Non-compliance to MSPO Certification Scheme	196	2024-05-27	I have been as a freelancer MSPO audtor at CARE CERTIFICATION INTERNATIONAL since 2019 and lasted until May 2024.\n\n\n\nHowever, I didn't receive documented contract employment for my work since 2020. I have contacted CCI top management regarding this issue, however, no response. \n\n\n\nNow, my job at CCI have been discontinued suddenly this month. Since I have no documented evidence to show and protect my rights as a freelancers. I have lost my income in an instant.\n\n\n\nTo make it worse, All other freelancers also don't have any sorts of documented evidence employment. Ifear the worst for them in the future. \n\n\n\nPlease investigate this case. \n\n\n\nThank you \n\n\n\n	196
34	2024-05-11 08:17:36+00	t	MSPO Trace	195	2024-05-11	Cannot filter out the MSPO Trace for smallholders. The MSPO trace for smallholders is not responding when trying to filter out the states and when using the search bar.	195
138	2024-02-27 16:50:32+00	t	Non-compliance to MSPO Certification Scheme	191	2024-02-27	Date: February 27, 2024\n\n\n\nI am writing to express my concern and request the postponement of the approval process for the Malaysian Palm Oil Board (MPOB) license pending further review of the applicants listed in the attached name list. This request is prompted by significant issues regarding the land where palm oil cultivation is taking place.\n\n\n\nFor your information, the parcels of land are classified as Native Communal Reserve (NCR) land under Section 6 of the Land Code, implying that all parcels of land within the Native Communal Reserve (NCR) rightfully belong to the community.\n\n\n\nAdditionally, it is crucial to note that individual surveys to ascertain rightful ownership of the land have not been finalized. The area is currently embroiled in a dispute, and the matter has been referred to the Office of Sub District Officer in Engkilili, Sri Aman for further instructions regarding the genuine ownership of the land.\n\n\n\nGiven the unresolved dispute over land ownership and the absence of finalized surveys, it would be premature to proceed with the approval of the MPOB license. Such action without clarification and resolution of land ownership issues could lead to potential legal complications and conflicts in the future.\n\n\n\nTherefore, I respectfully urge MPOCC to exercise caution by suspending the approval of the MPOB license until the land ownership disputes are conclusively resolved. This approach aligns with the principles of responsible and sustainable palm oil production, ensuring that all stakeholders' rights and interests are adequately protected.\n\n\n\nThank you for considering my concerns. I trust that MPOCC will address these issues in the best interest of all parties involved.\n\n\n\nFor your reference, I have attached the following documents:\n\n\n\n1\tThe Sarawak Government Gazette.\n\n2\tA Police report from one of the landowners.\n\n3\tA Letter of complaint to the Land and Survey Department, Sri Aman regarding encroachment into her land by one of the MPOB License applicants.\n\n4\tList of palm oil planters applying for the MPOB License from the communal area.\n\n\n\nYours sincerely,\n\n\n\nTR. Ruekeith Jampong\n\nHP 0165785755\n\nEmail: ruekeithjampong@gmail.com	191
118	2023-05-26 12:29:01+00	t	Others	179	2023-05-26	I HAVE PROBLEM WITH LOGIN INTO MSPO TRACE, PLEASE HELP ME ON THIS MATTER. EVERYTIME I TRY TO LOGIN THE ERROR SHOW SUSPENDED FOR 5 MINUTES BECAUSE OF TOO MANY ATTEMP. THIS SHOW EVEN ONLY 1 TIME TRYING TO LOGIN.	179
24	2023-05-23 15:11:49+00	t	Others	178	2023-05-23	I would like to know status subsidiary MSPO Certificate of Chin Bee Plantations Berhad 	178
129	2023-05-15 10:08:47+00	t	MSPO Trace	177	2023-05-15	Our company info is not found in the MSPO Trace SCCS certified list. Logged into Davos Life Science Sdn. Bhd. account but found other company info was registered inside. Kindly refer to the enclosed supporting document for better understanding.	177
128	2023-05-12 17:31:35+00	t	Non-compliance to MSPO Certification Scheme	176	2023-05-12	I worked as building artisan since 1 February 2023 with Keck Seng (Malaysia) Berhad on Estate office renovation. I have an agreement on price for office renovation work with General Manager (Mr Vincent Hee Vui Yong) in which mutually agreed. However, employer representative from factory management in Keck Seng (Malaysia) Berhad Mr Chua Teck Ngin that was temporarily overseeing estate operation when Mr Vincent Hee is not presence, he amended my salary without me agreeing. The amendment was done by Administrative Manager standby Soh Yoke Kam and admin staff Zailalahwati Binti Omar @ Yusof. I would like to complain Mr Chua Teck Ngin, Soh Yoke Kam and Zailalawati binti Omar @ Yusof because they amended my salary without me agreeing and did not pay me in full amount for April 2023 in which the work has been completed by end of April 2023.	176
127	2023-05-11 16:01:12+00	t	Non-compliance to MSPO Certification Scheme	174	2023-05-11	I worked as building artisan since 1 February 2023 with Keck Seng (Malaysia) Berhad on Estate office renovation. I have an agreement on price for office renovation work with General Manager (Mr Vincent Hee Vui Yong) in which mutually agreed. However, employer representative from factory management in Keck Seng (Malaysia) Berhad Mr Chua Teck Ngin that was temporarily overseeing estate operation when Mr Vincent Hee is not presence, he amended my salary without me agreeing. The amendment was done by Administrative Manager standby Soh Yoke Kam and admin staff Zailalahwati Binti Omar @ Yusof. I would like to complain Mr Chua Teck Ngin, Soh Yoke Kam and Zailalawati binti Omar @ Yusof because they amended my salary without me agreeing and did not pay me in full amount for April 2023 in which the work has been completed by end of April 2023. \n\nFurthermore, I was instructed by Assistant Manager Mohamad Syafik bin Saharuddin (950731-05-5561) to work on public holiday (Hari Raya) for 12 hours as Security Officer due to inadequate manpower during Hari Raya. I noticed I did not received pay for working during public holiday and overtime. \n\nI was not given a copy of my work agreement.	174
104	2023-02-06 09:41:01+00	t	Others	166	2023-02-06	hanaya sekadar bertanya,kenapa MSPO hanya ada dua bahasa sahaja iaitu english dan manadarin,sedangkan aplikasi ini dibuat untuk penduduk malaysia yang mengutamakan bahasa melayu atau bahasa malaysia,adakah semua pekebun kecil ini penduduknya adalah daripada penduduk americatau britain atau juga china,harap DIUBAH APLIKASI INI KERANA KITA ADALAH MALAYSIAN BUKAN CHINESE ATAU BRITAIN ATAU ENGLISH...	166
114	2023-02-01 10:14:35+00	t	Non-compliance to MSPO Certification Scheme	163	2023-02-01	1) Violation of the agreement between Tabung Haji Ladang Enggang and villagers . \n\n-As per the reports of 26/05/2016 attached said, Tabung Haji PH,Ladang Enggang cut down all the plants that the villagers have been working for without consent and start planting the palm oil in their land . \n\n\n\n-  Around 2009 , Tabung Haji PH agreed to pay a compensation to villagers regarding the NCR Land that they had used. But they have not given any compensation until 2023. \n\n\n\n2) The office staff of Tabung Haji PH, Ladang Enggang is not cooperative and friendly .\n\n-During last year, the villagers wanted to discuss about the land compensation to their manager but they refused and told the villagers to go back and until  today , they have not taken an action any furthur regarding the issue .\n\n\n\n3) The Community of KPG BELADIN wants their NCR LAND to be returned to rightful owner . \n\n-As the issue is not given any attention , the community wants their NCR land to be returned .	163
105	2022-08-19 10:07:54+00	t	Non-compliance to MSPO Certification Scheme	154	2022-08-19	Assalamualaikum Tuan\n\nSy Nazmi Zain, Setiausaha Jawatankuasa Bertindak Kg Sg Kerawai-Selat Manggis-Kg Merdeka Teluk Intan\n\n\n\nAduan berkaitan Estet Batang Padang MHC Plantation Sdn Bhd.\n\n\n\nISU \n\n1. Berkaitan jalan ladang yang menghubungkan kg merdeka.penduduk sudah banyak kali membuat aduan kepada pihak estet untuk meninggikan had palang yg di buat oleh estet agar kenderaan kereta dapat lalu keluar masuk.namun tidak di endahkan pihak estet atas alasan banyak berlaku kecurian buah kelapa sawit estet\n\n2. 1 lagi laluan estet juga telah di korek kecilkan dan hanya untuk laluan motosikal sahaja boleh di lalui.juga pihak estet memberikan alasan yg sama.\n\n3. Atas faktor kecemasan dan keselamatan penduduk kg merdeka sekiranya berlaku perkara tidak di ingini seperti sakit teruk yg memerlukan di bawa segera ke hospital,ianya akan menjadi masalah kerana jalan tidak boleh di lalui oleh kereta apatah lagi ambulan.kalau hendak melalui jalan tersebut terpaksa maklum kepada pondok pengawal dan pihak pengawal akan buka gate.ini akan menyukarkan dan melambatkan proses untuk menyelamat sekiranya berlaku kecemasan.\n\n4. Penduduk Kg Selat Manggis sering kali di landa banjir..sekiranya berlaku banjir jalan utama ke kg tersebut tidak dapat di lalui dan jalan alternatif ialah jalan estet.malangnya jalan tersebut juga di pasang pagar dan terbaru jalan tersebut di korek kecilkan hanya laluan motorsikal sahaja yg boleh di gunakan.sekiranya ini terus berlarutan dan berlaku lagi musibah banjir,maka penduduk kg tersebut terkepung tidak boleh keluar .\n\n5. Pihak estet mengenakan bayaran rm45 1lori tidak kira berapa muatan kepada penduduk kampung yg menggunakan jalan estet untuk membawa keluar hasil kelapa sawit.ini seolah² British menjajah tanah melayu.hasil bumi anak jati kampung yang lahir di sini di kenakan seolah² cukai oleh pihak estet.perkara ini telah lama berlarutan.\n\n6  Pihak jawatankuasa bertindak sudah 2 kali menghantar surat kepada pihak pengurusan estet supaya perkara ini dapat di selesaikan di meja rundingan namun pihak estet hanya berani bersemuka dengan menghantar penolong pengurus untuk berjumpa dengan tiada jalan penyelesaian.pihak manager estet langsung tidak mahu berjumpa apatah lagi mahu mendengar masalah penduduk kampung.\n\n\n\nDi harap pihak Tuan dapat membantu memberikan khidmat nasihat kepada kami juga kepada pihak estet agar win win situation dapat di capai.\n\n\n\nTerima kasih Tuan	154
93	2022-05-12 09:30:10+00	t	Others	142	2022-05-12	This digital submission is made at the request of MPOCC. It follows the first printed submission of our letter and a bulk of printed documents in December 2020; the first digital submission in February 2021 on this website; and more recent email and telephone communications in April 2022. It pertains to the complaints that we have received from six groups of indigenous communities in Marudi and Batu Niah, Sarawak in recent years, on the past and possible future violations of their native customary rights (NCR) by oil palm plantation projects. Please refer to our cover letter dated April 28, 2022 for further details. The communities involved are: (1) Rumah Manjan and Rumah Nanta, Sungai Malikat, Marudi; (2) Rumah Beliang, Logan Tasan, Marudi; (3) Rumah Labang Jamu, Nanga Seridan, Baram; (4) Persatuan Iban Marudi (which concerns a larger area where several longhouses may be affected, including 1 and 2); (5) Persatuan Penduduk Sungai Buri, Bakong, Baram; (6) Persatuan Penduduk Rumah Lachi, Sungai Sebatuk, Batu Niah. 48 supporting documents are also uploaded for these six complaints to provide more detailed information for each case. For further communications, we can be reached through these three email addresses; foemalaysia@gmail.com, jokjevong@gmail.com and shaffincre@gmail.com; or through telephone lines +60 85 756 973 (Sarawak office) or +60 13 686 7509 (Jok Jau Evong). Thank you.	142
55	2022-03-18 16:23:37+00	t	Others	136	2022-03-18	Non compliance principle three and free prior information consent	136
79	2021-10-06 18:08:43+00	t	Others	126	2021-10-06	False Claims by FGV \n\n\n\na)\tAs provisioned under the MSPOCS01 Procedure Clause 7.12, a certified entity is required to complete the annual surveillance assessment within 12 months of the certificate expiration date by an accredited certification body;\n\n\n\nb)\tTake note that based on the MPOCC website, there are no records of FGV completing the annual surveillance assessments in 2021 for any of the certified operations listed in our letter dated 09.09.2021.  As of todate, the published reports by MPOCC only reflect assessments that were conducted in 2019;\n\n\n\nc)\tIn addition, whilst MPOCC had failed to remove the said 10 FGV certificates against the MSPO requirements, FGV has continued to make public that it has achieved 100% MSPO certification for all its operations;\n\n\n\nd)\tFGV’s conduct to disseminate misleading information to unsuspecting stakeholders is improper and is further fortified by MPOCC’s actions to maintain the FGV certificates on its website instead of adhering to the technical requirements governing the MSPO scheme.  Such matters are within DSM’s knowledge given DSM’s own Complaints Panel had rejected MALM’s suspension appeal on similar grounds;\n\n\n\ne)\tIn any event, the claims made by FGV is clearly untrue and bias against all other MSPO certificate holders and to downstream buyers of MSPO certified products sold by FGV.	126
76	2021-09-30 13:02:15+00	t	Others	123	2021-09-30	Kegagalan pengeluaran sijil SPOC oleh SIRIM dalam tempoh masa yang ditetapkan yang mana secara tidak langsung mengganggu proses pensijilan pekebun-pekebun kecil yang terlibat. Akibat daripada kegagalan pihak SIRIM dalam mengeluarkan sijil dalam tempoh masa yang sepatutnya menyukarkan pihak kami dalam melaporkan status pensijilan pekebun kecil persendirian kepada pihak kementerian. Senarai SPOC yang terlibat seperti dilampirkan.	123
54	2021-05-06 07:49:39+00	t	Others	105	2021-05-06	This is a complaint letter on the objections to the entry of Muzana Plantation JV Sdn. Bhd. PL Lot 327 Puyut Land District by Persatuan Melayu Marudi. The Malay community in Marudi found out that part of the territory of customary land (NCR) in the region of Lot 1200 PL Puyut Land District in 2010, was affected by the grant of a license palm plantation project development from Rimbunan Sawit Sdn Bhd to Muzana Plantation JV Sdn Bhd without their acknowledgment. Hence, they are adamant to try and make sure that their ancestral lands would not be taken over by irresponsible companies for their future generation's sake. 	105
88	2022-02-10 17:32:45+00	t	Non-compliance to MSPO Certification Scheme	133	2022-02-10	PENCEROBOHAN TANAH ADAT (NCR) OLEH SYARIKAT GRAND OLIE SDN BHD DAN REAL HOLISTIC SDN BHD DI SG. URONG BAKONG, MIRI, SARAWAK ATAU PENCEROBOHAN TANAH ADAT OLEH SYARIKAT LADANG SAWIT. Sila rujuk lampiran. Untuk Peta asal Tanah Adat sila rujuk Map Lama Sungai Urong.pdf. Untuk makluman Tuan Kawasan penempatan rumah panjang kami sudah masuk PL kompeni sawit juga. Pada masa akan datang kami akan melalui krisis yang amat besar dalam hal tanah adat ini kerana kompeni ladang sawit ini. Saya sendiri pernah menghadiri mesyuarat bersama Pengarah Urusan Real Holistic Sdn Bhd pada tahun 31 Jan 2013, jam 11.30 pagi di Pejabat Daerah Marudi, Baram. Semasa mesyuarat saya sendiri membantah dengan TIDAK BERSETUJU tanah kami masuk PL kompeni. Namun akhirnya kami di tipu. Walaupun semasa mesyuarat Pegawai Land & Survey datang mesyuarat. Saya mewakili penduduk Rumah Panjang daripada Tuai Rumah Selema Janting memohon agar isu tanah adat kami ini di beri perhatian. Sebelum ini kami yang membantah akan pencerobohan tanah adat NCR ini di bawah jagaan Tuai Rumah Linggi. Sejak kes tanah ini kami telah di pulaukan oleh Tuai Rumah Linggi dan akhirnya kami sudah menubuhkan JKKK sendiri dan akhirnya sudah melantik Tuai Rumah sendiri (Sila rujuk Minit mesyuarat) dengan sokongan YB Datu Dr. Penguang. YB banyak membantu kami dalam hal isu tanah adat ini juga. Untuk pengetahuan kami sudah membawa isu tanah adat ini kepada YAB Ketua Menteri Sarawak dan akhirnya sudah ada perhatian oleh MANRED. Namun syarikat ladang ini masih mengganggu kami malah makin teruk sekali.	133
77	2021-10-05 15:06:11+00	t	MSPO Trace	124	2021-10-05	Unable to register certified smallholder (SUPPLIER NAME: RODY TADLE) in MSPO Trace. Seem that the supplier is not yet in the supplier list database. Attached herewith are the supplier's MSPO Certificate for ur kind perusal.	124
72	2021-08-12 14:50:15+00	t	MSPO Trace	116	2021-08-12	When I wish to make announcemnt for CPO & PK deliveries in July (after the maintenance was done). It seems like there is a limit of only 1 upload per month is allowed. The problem with 4 of our CPO Mill is, one mill wish to make correction after successful upload so they canceled the announcement then when they watnt to upload again there is a error message saying upload has been done already. Another mill after upload CPO to 1 buyer, unable to upload PK to the same buyer or any other buyer. Is there any other ways to make announcement manually?	116
45	2021-05-08 00:20:54+00	t	Others	106	2021-05-08	HI, I AM FROM TETANGGA AKRAB SDN BHD WOULD LIKE TO LODGE A COMPLAIN REGARDING ON MSPO TRACE SUBMISSION. WE TRIED TO UPLOAD OUR MSPO TRACE SINCE YESTERDAY 7TH MAY 2021 BUT FAILED. OUR INTERNET CONNECTION WAS FINE. IS THERE ANY OTHER WAYS FOR US TO SUBMIT OUR MSPO TRACE? KINDLY FEEDBACK AS SOON AS POSSIBLE. ENCLOSED IS THE EVIDENCE THAT THE SERVER CANNOT UPLOAD POUR SUBMISSION. THANKS AND BEST DAY. 	106
35	2021-03-14 04:28:06+00	t	Non-compliance to MSPO Certification Scheme	103	2021-03-14	Dear Sir, I would like to lodge a complaint  against the General Manager of Keresa Plantations Sdn Bhd who have abused me  ie. physical and verbal violence. This incident had caused mental stress and affected my physical health ie.  bleeding gums and jaws. Non-Compliance to 4.4.5. Criterion 5 : Employment conditions - violence at workplace Further details are in the attachments. Thank you.	103
65	2021-02-22 02:15:05+00	t	Non-compliance to MSPO Certification Scheme	100	2021-02-22	Tuan,\n\n\n\nMOHON KHIDMAT NASIHAT DAN PEMAKLUMAN ISU PENSIJILAN MSPO FGV KOMPLEKS SERTING\n\n\n\nAdalah dimaklumkan bahawa Kompleks Serting yang terdiri daripada Kilang Sawit FGVPI Serting dan empat (4) ladang sawit FGVPM telah disijilkan dengan pensijilan MSPO part 4 dan MSPO part 3 pada 14 Ogos.2018 dan telah berjaya di audit ASA 1 pada tahun berikutnya. Pensijilan MSPO bagi kompleks ini dijalankan oleh Badan Pensijilan Mutuagung Lestari (Malaysia) yang telah dilantik oleh FGV melalui kontrak yang telah ditandatangani untuk menjalankan pensijilan MSPO Kompleks Serting sehingga ASA 4. \n\n\n\nNamun begitu, Mutuagung Lestari (Malaysia) yang sepatutnya menjalankan audit ASA 2 bagi kompleks ini telah gagal melaksanakannya sehingga tarikh surat ini dikeluarkan. Pada awalnya pihak FGV memberi kelonggaran disebabkan oleh PKP dan isu Covid 19 yang sedang menular. Pihak FGV juga telah beberapa kali membuat susulan dangan badan pensijilan tersebut, di mana susulan yang terakhir dibuat melalui email bertarikh 8 Januari 2021 dan pihak kami memberi tempoh yang munasabah sehingga penghujung Januari 2021 untuk pihak Mutuagung Lestari (Malaysia) melaksanakan Audit ASA 2. \n\n\n\nWalau bagaimanapun, maklumbalas hanya diterima oleh pihak FGV pada 3 Februari 2021 yang menyatakan bahawa Mutuagung Lestari (Malaysia) tidak dapat melaksanakan audit MSPO pada masa ini kerana perlu menyelesaikan masalah dalaman dengan Mutuagung Lestari (Indonesia). Makumbalas tersebut juga menyatakan bahawa pihak FGV tidak boleh membuat proses pemindahan sijil kepada Badan Pensijilan lain.\n\n\n\nSuhubungan dengan itu, pihak FGV memohon khidmat nasihat daripada pihak MPOCC selaku pemilik skim pensijilan MSPO untuk cadangan langkah-langkah atau tindakan terbaik yang boleh diambil bagi meneruskan Pensijilan MSPO Kompleks Serting. Bersama-sama ini disertakan surat maklumbalas daripada Mutuagung Lestari (Malaysia) untuk rujukan dan tindakan lanjut pihak Tuan.\n\n\n\nSegala bantuan dan khidmat nasihat dari pihak Tuan amatlah di hargai.\n\n\n\nSekian terima kasih.\n\n	100
57	2020-08-16 01:57:28+00	t	Others	89	2020-08-16	We have obtained our MSPO certification part 3 on 21st February 2020 and we have submitted our claim by hand to MPOCC staff on 18th March 2020 at NIOSH bangi. We have emailed Mr Tan on 20th July 2020 to request for the status of the claim, but Mr Tan inform us that our application still in queue to be process due to large volume of application and the closure of MPOCC office due to MCO. Our management has queried on delay of the claim and we as sustainability officer unable to explain to our management since we don't know the progress of the claim and it's hard for us to convince our management to continue doing the surveillance audit. So, we would like to suggest if MPOCC can create any system for the companies to monitor on the progress of the claim. We hope that MPOCC can revert on this matter as soon as possible. Thanks.	89
53	2020-08-16 01:51:17+00	t	Others	87	2020-08-16	We have obtained our MSPO certification part 3 on 14th March 2020 and we have submitted our claim by hand to MPOCC staff on 18th March 2020 at NIOSH bangi. We have emailed Mr Tan on 20th July 2020 to request for the status of the claim, but Mr Tan inform us that our application still in queue to be process due to large volume of application and the closure of MPOCC office due to MCO. Our management has queried on delay of the claim and we as sustainability officer unable to explain to our management since we don't know the progress of the claim and it's hard for us to convince our management to continue doing the surveillance audit. So, we would like to suggest if MPOCC can create any system for the companies to monitor on the progress of the claim. We hope that MPOCC can revert on this matter as soon as possible. Thanks.	87
50	2020-08-16 01:40:51+00	t	Others	84	2020-08-16	We have obtained our MSPO certification part 3 on 03rd February 2020 and we have submitted our claim by hand to MPOCC staff on 18th March 2020 at NIOSH bangi. We have emailed Mr Tan on 20th July 2020 to request for the status of the claim, but Mr Tan inform us that our application still in queue to be process due to large volume of application and the closure of MPOCC office due to MCO. Our management has queried on delay of the claim and we as sustainability officer unable to explain to our management since we don't know the progress of the claim and it's hard for us to convince our management to continue doing the surveillance audit. So, we would like to suggest if MPOCC can create any system for the companies to monitor on the progress of the claim. We hope that MPOCC can revert on this matter as soon as possible. Thanks.	84
27	2020-08-13 11:09:24+00	t	Others	65	2020-08-13	We have successfully obtain our MSPO certification for Part 3 in September 2019 and we have submitted our claim to MPOCC by December 2019. However, until to date we have not receive any updates or payment claim from MPOCC. Moreover, our management always mentioned that the other estate has not obtain the MSPO certification but still operate until today without any problem. So, due to this two matters, our management has asked the sustainability officers to rethink on not doing the surveillance audit this year. We hope that we can have a proper response about this matter as soon as possible so that we as the sustainability officers can convince our management to continue the MSPO certification to comply the regulation. 	65
25	2020-06-12 15:29:24+00	t	DOE suspends palm oil mill's permit for polluting river	62	2020-06-12	12 June 2020\n\n\n\nTO: BSI Services (M) Sdn Bhd\n\nSuite 29.01, Level 29,\n\nThe Gardens North Tower\n\nMid Valley City Lingkaran Syed Putra\n\n59200 Kuala Lumpur.\n\nTel: 03-9212 9638\n\nFax: 03-9212 9639\n\n\n\nDear Sir/Madam,\n\n\n\nGood day to you.\n\n\n\nI wish to bring your attention to the Bernama news portal  (https://bernama.com/en/general/news.php?id=1849654 ) dated 9 June 2020 that the Environment and Water Ministry through the Department of Environment (DOE) has suspended the operating permit of a palm oil mill for allegedly causing pollution near Kluang, Johor.  \n\n\n\nRelated to the above serious matter, we have been formally informed by DOE Kluang on the details of the Palm Oil Mill is as below:\n\n\n\nPamol Plantation Sdn Bhd\n\nKilang Kelapa Sawit Pamol\n\n8 1/2 Miles, Jalan Mersing\n\n86000 Kluang, Johor.\n\n\n\nFrom our record your CB had issued the MSPO MS2530-4:2013 certificate No: MSPO 700801 on 31 Dec 2018 (attached).\n\n\n\nKindly report to us soonest possible, on the proactive action steps and mitigation measures taken by your organisation, in accordance with your internal procedures and the requirements of Standards Malaysia, with regards to MSPO certification.	62
33	2020-08-16 01:00:20+00	t	Others	71	2020-08-16	We have obtained our MSPO certification part 3 on 01st October 2019 and we have submitted our claim by hand to MPOCC staff on 18th March 2020 at NIOSH bangi. We have emailed Mr Tan on 20th July 2020 to request for the status of the claim, but Mr Tan inform us that our application still in queue to be process due to large volume of application and the closure of MPOCC office due to MCO. Our management has queried on delay of the claim and we as sustainability officer unable to explain to our management since we don't know the progress of the claim and it's hard for us to convince our management to continue doing the surveillance audit. So, we would like to suggest if MPOCC can create any system for the companies to monitor on the progress of the claim. We hope that MPOCC can revert on this matter as soon as possible. Thanks.	71
32	2020-08-16 00:56:57+00	t	Others	70	2020-08-16	We have obtained our MSPO certification part 3 on 01st October 2019 and we have submitted our claim by hand to MPOCC staff on 18th March 2020 at NIOSH bangi. We have emailed Mr Tan on 20th July 2020 to request for the status of the claim, but Mr Tan inform us that our application still in queue to be process due to large volume of application and the closure of MPOCC office due to MCO. Our management has queried on delay of the claim and we as sustainability officer unable to explain to our management since we don't know the progress of the claim and it's hard for us to convince our management to continue doing the surveillance audit. So, we would like to suggest if MPOCC can create any system for the companies to monitor on the progress of the claim. We hope that MPOCC can revert on this matter as soon as possible. Thanks.	70
\.


--
-- Data for Name: user; Type: TABLE DATA; Schema: public; Owner: -
--

COPY public."user" (id, created_at, user_id, organization, phone, address, postcode, state, country, name, email, prev_pwd) FROM stdin;
119	2025-06-18 02:09:49.709953+00	bb194837-db77-40d9-a6fd-5e9737c5724e		0111615151	Taman Markonah	34000	Terengganu	Malaysia	\N	pom_logo@yopmail.com	\N
160	2025-06-27 04:21:39.298042+00	6d810e53-112a-4eac-a882-25b1e97a42b8		01111249279	Taman Setia Jaya	46000	Selangor	Malaysia	\N	pptz_hilirperak1@yopmail.com	\N
163	2025-06-27 08:23:21.586081+00	1dd6c4fe-a762-41d0-a940-959280c0e92a		123456789	test	43000	Selangor	Malaysia	\N	complainant_mspo3@yopmail.com	\N
1	2020-06-17 19:43:35+00	b7592049-9546-4bd4-9bc7-33d77d747af0	org test login	\N	\N	\N	\N	\N	test login	hemanathan@airei.com.my	u74q3SXt
2	2020-06-19 10:46:39+00	663cd7e5-73f0-4c16-b7a8-a579107fda69	Ely	\N	\N	\N	\N	\N	Ely	k@gmail.com	ti1yLyvb
3	2020-06-19 11:04:24+00	081efe3b-09b5-4e34-9194-cbcb30cc77d9	SVS	\N	\N	\N	\N	\N	Julfikar	kamarulsipi.mohd@gmail.com	obGHpSdU
4	2020-06-19 11:20:57+00	5de03212-53a6-465c-857b-34e113374e81	Royal	\N	\N	\N	\N	\N	Royal	kamarul.sipi@airei.com.my	aRCyBFsw
5	2020-06-22 15:10:02+00	1207343f-7e2b-4f82-88ed-7b559f837c08	org chk	\N	\N	\N	\N	\N	fin test	hemanarhan@airei.com.my	aEnTOvdh
6	2020-06-22 22:07:41+00	884b5358-cd7d-4b03-84af-fde5a996ac76	wwwwwwwwww	\N	\N	\N	\N	\N	wwwwwwwwwwwwww	s@gmail.com	pX2hfEwE
7	2020-07-20 12:50:30+00	9c533f9b-0de2-4184-8679-ac4124139717	AAAA TEST SDN BHD	\N	\N	\N	\N	\N	Julia	kamaroyamatha@gmail.com	JqTvLkiC
8	2020-07-23 11:05:09+00	46f9cd41-b08e-4e32-81eb-bb1d3323b3b2	sasa	\N	\N	\N	\N	\N	sasa	nasiha@mpocc.org.my	wnkO4pAb
9	2020-08-05 14:12:26+00	4d6dc0fa-8a2f-4073-9bbd-85425124beb0	MPOCC	\N	\N	\N	\N	\N	MPOCC	leo_gee87@yahoo.com	CiF84ums
10	2020-08-13 11:09:24+00	e81e22aa-0578-4fb2-8d0b-5665be08b8ee	Kemeling Sdn Bhd	\N	\N	\N	\N	\N	Jane Chin Shui Kwen	janechinshuikwen@gmail.com	lEZ53dPO
75	2023-05-23 15:11:49+00	0492f0e6-5805-44af-aa74-4db0c77a4140	CHIN BEE PLANTATIONS BERHAD	\N	\N	\N	\N	\N	VISUVAM SUBRAMANIAM	cbpb860009@gmail.com	XSQvQjst
76	2023-05-26 12:29:01+00	6a07ae1f-58b7-49a3-b140-407f7039c517	SHH OIL MILL SB	\N	\N	\N	\N	\N	Ms Mages	mages@op.shh.my	F6dqFc4W
77	2023-06-21 11:58:16+00	25c9e59a-dddc-4e8d-9b27-4033d9f1274a	individu warga masyarakat	\N	\N	\N	\N	\N	hidayat	elink.hidayat@gmail.com	c43PJuIL
78	2023-08-11 18:47:12+00	4120635d-c542-437d-9cea-9319b2338db0	Suruhanjaya Tenaga Sandakan	\N	\N	\N	\N	\N	Che wan mohd allariff	allariff@st.gov.my	8Hevs66U
79	2023-08-17 10:08:32+00	93a02249-5316-49a2-9ac7-12b4c8905133	FGV Holdings Berhad	\N	\N	\N	\N	\N	Muhamad Zuki bin Abdul Kadir	zuki.ak@fgvholdings.com	bTdsKo7F
80	2023-08-26 10:51:40+00	fd863516-76ca-4417-8047-db3bdf0cb04e	FGV PALM INDUSTIRES SDN BHD	\N	\N	\N	\N	\N	ROY ALEXIUS NAIN	alexius.n@fgvholding.socm	MK2IhcI6
81	2023-09-05 16:00:14+00	e8eef5b6-23c8-43b6-b361-5407820aa1bd	Independent 	\N	\N	\N	\N	\N	Andy Hall	andyjhall1979@gmail.com	coCeWCnI
82	2023-09-13 17:33:23+00	0e4b6571-d7da-4d82-8035-b53821d50643	RANGKAIAN DELIMA PLANTATION	\N	\N	\N	\N	\N	AMMAR AIMAN BIN ABD NASIR	ladangdelima17@yahoo.com	uGkGP9ks
83	2023-11-11 11:49:02+00	3daebba2-2008-456d-85ff-0f51d49e2068	FELCRA JAYAPUTRA SDN BHD	\N	\N	\N	\N	\N	KHAIRUL IDZUAN BIN MOHAMAD SAHIDI	khairulidzuan@fjgroup.com.my	Iwo0LElr
84	2023-12-12 15:21:42+00	79e11466-b344-4852-81cb-39ff9e45ebc0	MAJLIS DAERAH GUA MUSANG	\N	\N	\N	\N	\N	NURMIMI SHARIDA	mimisharida@gmail.com	03GT5GHd
85	2024-01-19 14:59:36+00	4838f267-e471-42c2-960a-afb1bbe50dd5	Gan Teng Siew Realty Sdn Bhd	\N	\N	\N	\N	\N	Ong Thean Poh	ongtp@gtsr.com.my	Huy98abl
86	2024-02-14 08:24:29+00	4735ce34-ed6c-4b84-a258-c098689ca12f	WTK ALPHA SDN BHD	\N	\N	\N	\N	\N	Norasmara Bte Mohd. Anwar	wtkalpha@gmail.com	h0c16iW1
87	2024-02-27 16:50:32+00	0b500a7c-c000-4b0f-b19a-4cc42e3d380e	Sarawak Dayak Iban Association (SADIA)	\N	\N	\N	\N	\N	RUEKEITH @ RUKIT ANAK JAMPONG	ruekeithjampong@gmail.com	p9czxHVF
88	2024-04-08 11:48:43+00	80c123de-90b0-4fd6-9424-1e93e57c96fb		\N	\N	\N	\N	\N	MUHAMAD AMIRUDDIN ASARI	bintang@bell.com.my	18BTm611
89	2024-05-11 08:17:36+00	bcc22448-661c-4e28-99a8-edb83a48195e		\N	\N	\N	\N	\N	Nurul Aina Najwa Shahar	ainanajwa.sbh@gmail.com	ma1fpcy5
90	2024-05-27 21:15:43+00	77580fe9-7ac2-4fb0-9aa7-06995f768dea	Self Employed	\N	\N	\N	\N	\N	Rizal Ahmad Nazim	rizal1976@gmail.com	PzzLaJHD
91	2024-06-06 15:52:51+00	1d351dae-d3b7-476d-9c6a-c3851e6117f8	KAMPUNG MERAKAI RESIDENT	\N	\N	\N	\N	\N	LOURES CHRISTIANSEN ANAK TULIS	loureschristiansen@gmail.com	S5t5RT8J
92	2024-07-12 15:52:00+00	b37636b3-8be1-4178-9cf2-8b57f5394441	SD GUTHRIE	\N	\N	\N	\N	\N	Vendetta 	vendettavendetta326@gmail.com	frhlt5KX
93	2024-07-20 08:03:12+00	86c5fd15-a47d-44b9-94f9-864b787d7db8	MUKAH KILANG KELAPA SAWIT SDN. BHD.	\N	\N	\N	\N	\N	LING FOONG FOONG	foong9626@gmail.com	LSySrQhA
94	2024-08-28 17:15:49+00	26e06765-0726-4760-a956-cd6c133c8cf1		\N	\N	\N	\N	\N	Othman Ahmad	yakboy02@gmail.com	Sy8XdwGV
95	2024-11-21 20:23:05+00	9899069d-e0c6-4dec-b3cd-e4080a838f61		\N	\N	\N	\N	\N	Nandhu	aireimail24@gmail.com	bMUrGl5W
96	2024-12-03 18:25:46+00	43e2d156-815e-45bc-a9c4-959ffc35a607		\N	\N	\N	\N	\N	Riswan rasid	riswanrasid@gmail.com	dWqaCdf4
97	2025-01-02 18:12:57+00	97f7ac1a-aaf7-4061-8dba-cef646b37a3b		\N	\N	\N	\N	\N	Mohamad safwan bin miskam 	mohamadmat921231@gmail.com	LcbOTGyh
98	2025-01-16 18:41:39+00	e24e82c5-482d-44c5-95e4-0dec79afeffc		\N	\N	\N	\N	\N	Rajendran Subramanian	spnrajendran@gmail.com	cke06TaZ
99	2025-02-04 09:13:55+00	9bfb750a-2c2d-4bfc-9999-44fdabda74dd		\N	\N	\N	\N	\N	Kheong Sia Chiew 	kheongsc83@gmail.com	Vdaar6cj
100	2025-02-05 21:55:08+00	fc2ca455-d9cb-44de-a313-e5f66f65a688	Village	\N	\N	\N	\N	\N	Umpang Anak Sabang 	ussepudun2050@gmail.com	pjXJtRe6
101	2025-02-12 09:35:51+00	ad892dc0-1949-48b7-be5e-d63c7290e512	on behalf of Nestle Malaysia	\N	\N	\N	\N	\N	Mohd Hasbollah Suparyono	hasbollah@mspo.org.my	myH0HRA2
11	2020-08-16 00:47:09+00	bf3f6921-ab2d-4b8b-936f-38da5143c31d	Yap Siong & Associates Plantation Sdn Bhd	\N	\N	\N	\N	\N	Rusnani Tahang	rusnanit78@gmail.com	QXNShsJe
118	2025-06-15 09:36:05.799448+00	a007885a-80b3-4486-b31c-6652abca3e12	mspo	0123456789	SEKSYEN 7	40000	SELANGOR	Malaysia	\N	firdaus@mspo.org.my	\N
12	2020-08-16 00:50:51+00	3d06ba74-5af0-499d-81fa-6a61febaa57d	Global Eternity Sdn Bhd	\N	\N	\N	\N	\N	Jane Chin Shui Kwen	nuramsconsultant@gmail.com	Zk4dJ93x
13	2020-08-22 10:06:17+00	d0e4fb36-fb0a-4767-a333-531cbb37e035	SRI GANDA OIL MILL SDN BHD 	\N	\N	\N	\N	\N	GHAJENDRA NAYIDU	sriganda2003@gmail.com	dgGpB0ui
14	2020-08-27 14:26:16+00	cedde969-4985-499b-a05c-5325099bf7aa	Golden Elate Palm Oil Mill	\N	\N	\N	\N	\N	M.S Suresh	goldenelate.pom@gmail.com	qvUlbzY9
15	2020-09-07 15:44:15+00	13b7d6b3-42a7-40ec-b227-f1b91f791dcc	Kilang Kelapa Sawit Lekir Sdn. Bhd.	\N	\N	\N	\N	\N	Mohd Amirul Bin Safari	amirul@kksl.com.my	GGx7DNE6
16	2020-10-02 13:54:18+00	4287988f-93ab-4a3c-9790-77473ef7f799	2E^S Consultancy	\N	\N	\N	\N	\N	Ephrem Ryan Anak Alphonsus	ephremryanalphonsus@gmail.com	Gsi5q2oO
17	2020-11-23 10:23:17+00	12c58e57-7eb9-4e61-a298-52c44ab6e5e2	Gayanis Palm Oil Mill	\N	\N	\N	\N	\N	Henry Chong Chung Wai	chongchungwai@icloud.com	GCLycfOH
18	2020-12-24 14:33:46+00	f36f7e40-f5fb-4c87-a096-a88c211d6bd2	Salmah Test	\N	\N	\N	\N	\N	Salmah Zaini	n.hazirahismail@gmail.com	jtsmoFki
19	2020-12-26 21:10:20+00	812c46f2-6962-4df8-90c0-f5dee109c540	Palm oil plantation(small holder)	\N	\N	\N	\N	\N	Eradakrishnan A/L Muthusamy	varmavarma186@gmail.com	eKk5P3ma
20	2021-02-03 18:27:12+00	a54f43bc-3510-4267-9c02-de241f28979b	Sahabat Alam Malaysia (SAM)	\N	\N	\N	\N	\N	Jok Jau Evong	foemalaysia@gmail.com	bQS2XfnE
21	2021-02-22 10:15:05+00	ded6488b-469e-484e-b815-a00534d3e10f	FGV HOLDINGS BERHAD	\N	\N	\N	\N	\N	AMEER IZYANIF BIN HAMZAH	ameer.h@fgvholdings.com	4r2THyFp
22	2021-03-06 07:34:41+00	c0c0c1da-11f3-4065-aa98-82084870eea4	Tung Hup Palm Oil Mill	\N	\N	\N	\N	\N	Waldo Sualin	aldosualin@gmail.com	Qf4hQ0ta
23	2021-03-08 12:31:16+00	e0cf9d78-629a-4f0c-8c5e-d4eb659c758a	Global Gateway Certifications Sdn Bhd	\N	\N	\N	\N	\N	Muhd Jamalul Arif	jamal@ggc.my	IaKgOR7K
24	2021-03-14 12:28:06+00	0f718b43-671c-4b6f-b906-34ee7b45b4b2	Keresa  Plantations Sdn Bhd	\N	\N	\N	\N	\N	Thilaganathan a/l Karunagaran	thilaganarthan@gmail.com	CQx8qSwr
25	2021-04-29 11:48:10+00	c3430ef8-bea7-4d77-840d-7e1847682f45	DYNAMIC PLANTATIONS BERHAD, GOMALI PALM OIL MILL	\N	\N	\N	\N	\N	MUHAMAD HAZMIL BIN KUSIN	gmm@ioigroup.com	9gpidcXH
26	2021-05-06 15:49:39+00	0dfa2c7d-310b-4a83-98f5-197421843955	Persatuan Melayu Marudi	\N	\N	\N	\N	\N	Zainal Bin Wasli	wzynole@gmail.com	T4JU1jN5
27	2021-05-08 08:20:54+00	b0b2df8d-3835-4d06-a95d-d6a376b95ea1	TETANGGA AKRAB SDN BHD	\N	\N	\N	\N	\N	ADELINE STEFANIE ANAK KICHIN	adeline.stefanie.ta@gmail.com	t0ByAkuG
28	2021-05-25 12:42:15+00	1f99b32d-2a96-4760-b450-ed45b0abe4d1	PEKEBUN SAWIT	\N	\N	\N	\N	\N	MONA LIZA ANAK LIDOM	monalizalidom81@gmail.com	ufDGPXJG
29	2021-07-08 11:15:17+00	1b9260e9-b2bc-4ac3-86ed-cd13d669bd46	Test	\N	\N	\N	\N	\N	Test	suryantiselalukecewa@gmail.com	4pi2mY1L
30	2021-07-31 23:03:39+00	457acf64-4b5a-49a5-8f67-2aa577cec7ec	TEST EXTERNAL COMPLAINT BY AIREI 31.7.2021	\N	\N	\N	\N	\N	Hazirah AIREI	hazirah@airei.com.my	AnKgOTOO
31	2021-08-04 12:47:33+00	f22bd07e-28a0-4135-b73e-fb6629087485	Suburban Properties Sdn Bhd Palm Oil Mill	\N	\N	\N	\N	\N	Nurul Azlin	suburbanpom@gmail.com	KrRMkOOf
32	2021-08-12 14:50:15+00	80708127-7fdf-4c9d-8b6f-315c374c0cf4	Jaya Tiasa Holdings Sdn Bhd	\N	\N	\N	\N	\N	Ting Kee Yong	kyting@jayatiasa.net	fN6BL1rO
33	2021-09-30 13:02:15+00	536203a3-6335-4c60-ae6f-f852135c5419	Lembaga Minyak Sawit Malaysia (MPOB)	\N	\N	\N	\N	\N	Amiratul Azzuwana Aniqah Abdul Rahman	amiratul.aniqah@mpob.gov.my	YEZFDSrq
34	2021-10-06 15:33:15+00	4da24124-a1ef-4efe-832d-a89ddfd8945a	MUTUAGUNG LESTARI MALAYSIA SDN BHD	\N	\N	\N	\N	\N	HARI NAVEEN CHRISTOPHER	mutuagungmalaysia@gmail.com	RvUpK8oG
35	2021-10-14 12:20:20+00	3ce70501-e74f-4420-bc0a-3eac51f2dbe4	Komuniti /Penduduk Hak Tanah Adat ,Kampung Tekuyong A. Sri Aman. bagagian ke Dua (2) Sarawak. 	\N	\N	\N	\N	\N	1. Masa Anak nangkai, 2. Raymond Anak John lalong.	sadiahq@gmail.com	uV1sdTWf
36	2021-12-11 18:01:21+00	d8d76d24-14d4-4e46-92ad-5907d27fe2e0	Hasron Norraimi Bin Hashim	\N	\N	\N	\N	\N	Hasron Norraimi Bin Hashim	hasronnorraimi@yahoo.com	aTSpj8dY
37	2022-02-10 17:32:45+00	e80a6ccf-333b-407f-ae20-ae04ee67f667	JKKK SUNGAI URONG BAROH, BAKONG	\N	\N	\N	\N	\N	JOSEPH ANAK JANTING	josephjanting@gmail.com	18P6NEnd
38	2022-02-26 13:12:15+00	7c42038f-aa20-4f20-ba43-839d3474a560	primula gemilang sdn bhd	\N	\N	\N	\N	\N	rusdi bin mohd noor	rusdi@primulagemilang.com	hI1tGhaW
39	2022-03-05 16:26:25+00	a0b845cc-2c32-421e-9f3e-ebfe8e22cd15	SARAWAK PLANTATION AGRICULTURE DEVELOPMENT SDN BHD	\N	\N	\N	\N	\N	DAYANGKU EFFANADILLA BINTI AWG ZAINI	spadmukahmill@gmail.com	QxQbzyB0
40	2022-03-18 16:23:37+00	e5871981-e66c-4c44-9183-0e8084e874c9	JKKK RMH NYANAU	\N	\N	\N	\N	\N	Badol Ak Luang	luangbadol@gmail.com	JMdXKhT2
41	2022-04-14 13:29:54+00	582f5571-b638-444b-9527-12503ce384a3	freelance consultant	\N	\N	\N	\N	\N	ADNIN AMINURRASHID ZILAH	adninaminurrashid@gmail.com	4x2Duuqn
42	2022-04-14 13:50:18+00	05039a36-049a-47b0-9e99-6de64a44acbd	Activis	\N	\N	\N	\N	\N	Aireen 	mspo2019@yahoo.com	j8VVymvp
43	2022-04-15 08:13:24+00	14e4c67b-bcde-4704-a97f-0dcbe1717dc5	Whistle blower	\N	\N	\N	\N	\N	Whistle Cert	whistlecert@gmail.com	ItsyEGO0
44	2022-05-20 14:27:29+00	4e33cfac-f5fe-4c35-9861-84d7917606ae	Sawira Sdn Bhd	\N	\N	\N	\N	\N	Ravindran Veerasamy	rveerasa@hotmail.com	641Lo05n
45	2022-05-20 18:22:36+00	34e9281c-a3b1-412d-ba7e-fe29dad024c9	Jawatan Kuasa Bertindak Tanah Adat Kebuaw & Sg. Ilas	\N	\N	\N	\N	\N	Sumen Bin Gasan	mateksadiahq@gmail.com	IsYwN6cl
46	2022-05-24 14:18:35+00	8d6c1385-fa01-48c7-b761-4e0ebdcab162	c	\N	\N	\N	\N	\N	x	hello@bliss.com	yoTT41A0
47	2022-05-27 10:14:55+00	d8b08679-718a-49dc-a81d-141d5a5b048d	Pandewan Palm Oil Mill	\N	\N	\N	\N	\N	Nor az zahra binti Kiffli	sustainabilitypr.ppom@gmail.com	Ifm3NoJr
48	2022-06-29 10:20:37+00	54003f0f-9dc2-4142-a7a3-37781c6caa2f	FAM	\N	\N	\N	\N	\N	Muhsien	muhsienbadrulisham@gmail.com	luY5KkYw
49	2022-06-30 12:35:34+00	0a7806d8-7b08-4629-bcfc-b5304bc684c4	Agrobank	\N	\N	\N	\N	\N	Murshida Binti Mohd Yusoff	murshidayusoff@gmail.com	humCH6ui
50	2022-07-04 11:17:08+00	2abe0ef5-50a6-4f32-bcd0-ccbb192771c5	Agrobank HQ	\N	\N	\N	\N	\N	Chitra Thevi a/p Loganathan	chitra.loganathan@agrobank.com.my	dpepHRa4
51	2022-07-05 10:03:03+00	0919a2be-3b19-418f-91e8-ae8a8ffd3e48	Tee Teh Sdn Bhd	\N	\N	\N	\N	\N	Baxter Raymond Kisil	baxteraymond@gmail.com	kXAB3X8A
52	2022-08-19 10:07:54+00	01f2db6b-0dc0-45f1-842b-aced9d793fe6	JAWATANKUASA BERTINDAK KG SG KERAWAI-KG SELAT MANGGIS-KG MERDEKA	\N	\N	\N	\N	\N	JAWATANKUASA BERTINDAK KG SG KERAWAI-KG SELAT MANG	nazmizain4499@yahoo.com	YSGU7uRM
53	2022-10-14 17:06:43+00	2fc4583b-c10b-423a-a6fe-a5e25b7bc801	Monsok Palm Oil Mill Sdn. Bhd.	\N	\N	\N	\N	\N	Lo Tse San	monsokmill@gmail.com	mhXhal1C
54	2022-10-26 00:37:54+00	15f0f3a4-341a-4342-bca2-11c1d03d82a6		\N	\N	\N	\N	\N	Parameswaran	parameswaran_subramaniam@jabil.com	sXzT6RAh
55	2022-11-03 10:38:32+00	4af83a63-96e1-44ea-a7aa-749a66e5fcd7	Jabatan Hutan Sarawak	\N	\N	\N	\N	\N	Michael Anak Ngelai	michaeln@sarawak.gov.my	WvEqLhf8
56	2022-11-03 17:16:40+00	24f097e0-aad9-486d-887d-590379cf8f78	United Malacca Berhad	\N	\N	\N	\N	\N	Kasthuri Redi Satheraman	kasthuri@unitedmalacca.com.my	8JqhXIHU
57	2022-11-14 14:28:06+00	3a62ecb7-b6c8-4883-9066-4e1a871adc12		\N	\N	\N	\N	\N	Test	test@yahoo.com	bFJKhFWN
74	2023-05-15 10:08:47+00	a31bd0c1-174b-4922-a1b7-e60acc9b25b4	Davos Life Science Sdn. Bhd.	\N	\N	\N	\N	\N	Young Wan Lok	wl.young@davoslife.com	gFvFG7Im
102	2025-05-09 10:04:44.054978+00	e27f24ba-f28c-453c-b39f-2258c0f3ed98		0123423123	test	43000	Selangor	Malaysia	\N	\N	\N
103	2025-05-12 23:30:26.760713+00	05b72cdd-7080-497b-ba40-ed18f80aa63b		01121091656	mspo	40000	selangor	malaysia	\N	\N	\N
104	2025-05-15 02:04:40.677323+00	c49d077e-7c06-4224-b5bd-87d86da841c2		01234567890	test	43000	Selangor	Malaysia	Tukang Report Mat Pot	testemail@emspo.org.my	\N
105	2025-05-19 01:18:18.27934+00	eddf4bf6-1c95-46db-b8b7-82d2ef6b734b		0123456789	Jalan Delima 1	43000	Selangor	Malaysia	\N	\N	\N
106	2025-06-06 02:52:16.805477+00	78bc93c6-2195-4bc4-b386-5fb3c4186a78		011-11111123	Taman Mentiga	45000	Selangor	Malaysia	\N	\N	\N
107	2025-06-06 03:34:24.492357+00	f83bfb42-55a0-49a3-9d88-1293ec4c096e		0111615151	Taman Maharajalelas	41300	Selangor	Malaysia	\N	\N	\N
108	2025-06-06 03:37:34.358442+00	b6794357-ff2f-4388-8f92-42ef87c7476f		0130123212	Taman Idris	42000	Selangor	Malaysia	\N	\N	\N
120	2025-06-23 07:40:12.654034+00	8bc44ea0-2e33-458a-ac4d-298980c44b05		01133815782	Level 9, Titanium Tower, Lot 1, Brighton Square, Jalan Song	93350	Sarawak	Malaysia	\N	christabelle.winona@tsggroup.my	\N
117	2025-06-14 18:41:49.972691+00	0955eea6-fdc3-48b6-beca-f30e05cfe912		0123423123	test	43000	Selangor	Malaysia	\N	hazwan@mspo.org.my	\N
121	2025-06-23 07:40:13.687662+00	e2c36046-d53b-4a02-9eef-f85a47d6c357		0168939501	No. 263, Lorong 6/1, Taman Hui Sing	93350	Sarawak	Malaysia	\N	stephen.lee@grandolie.com	\N
123	2025-06-23 07:40:45.989204+00	20754c43-864b-45c9-8e9d-5f71b3dceb39		01668312705	Kota Samarahan	94300	Sarawak	Malaysia	\N	patriciachan@salcra.gov.my	\N
125	2025-06-23 07:41:53.968501+00	fd238175-c03f-4b7a-a819-0837b802ae2c		0148767794	Saratok	94300	sarawak	malaysia	\N	davidb@salcra.gov.my	\N
126	2025-06-23 07:41:59.350153+00	5dfc121a-a553-4380-9094-d716a81b495f		0148861070	RUMAH LAI BUKIT AMBUN	96400	SARAWAK	MALAYSIA	\N	francefcw@yahoo.com	\N
127	2025-06-23 07:42:01.110436+00	ba467302-a9dd-49f1-bb39-442fdab37dcd	Kuching Palm Oil Industries Sdn Bhd	0138299392	131, Spring Ville Garden, Jalan Tun Hussein Onn	97000	Sarawak	Malaysia	\N	margetha.achong@my.wilmar-intl.com	\N
128	2025-06-23 07:42:25.12021+00	3f695e7a-da08-4344-8d1c-60d1e4d3d772	Bau Palm Oil Mill Sdn Bhd	0138494330	Bau Palm Oil Mill Sdn Bhd KM 25, Jalan Bau-Lundu,94007 Bau, Sarawak	94007	sarawak	Malaysia	\N	josephrn@salcra.gov.my	\N
130	2025-06-23 07:42:35.166034+00	878637b4-5c02-462a-80e3-edd2cb4dd365		0148842156	No 632,lorong 10, Taman Desa Wira, Jalan Batu kawa	93250	Kuching	Sarawak	\N	pairinsonjengok.86@gmail.com	\N
134	2025-06-23 07:43:02.136568+00	7df7ea94-16ba-4fd6-85bc-4fd0155fe284	Masranti Plantation Sdn Bhd (Masranti Palm Oil Mill)	0146859987	Wisma Harn Len 7 Storey Office, No.18, Lot 1634, Section 64, KTLD, Jalan Mendu 5	93450	Kuching	Malaysia	\N	soon.masranti@gmail.com	\N
135	2025-06-23 07:43:10.637654+00	bc9650f6-a750-4deb-98f6-636b76c60b62	Tradewind Plantation Berhad	0145881654	KAMPUNG SUNGAI KUT MUARA DALAT 96300,DALAT SARAWAK	96300	Sarawak	Malaysia	\N	eliana.robert@tpb.com.my	\N
136	2025-06-23 07:43:26.717949+00	0d12ddb0-122b-46a3-afba-c35c8640e887		0135769286	Kampung Sungai Engkabang A	94700	serian	sarawak	\N	simleongeng@yahoo.com	\N
138	2025-06-23 07:44:11.310026+00	0cd2be50-abf7-420e-a986-7fa5371cf6a3	Tradewinds Plantation Berhad	0132047231	No 238 Taman Suria 1	94300	Sarawak 	Malaysia 	\N	emilia.as@tpb.com.my	\N
139	2025-06-23 07:44:36.511265+00	ac59ee7e-0939-4e05-bf57-be9508f40d82	RSB Lundu Palm Oil Mill Sdn Bhd	0168797100	Lot 306, Block 4, Stungkor Land 	94500	Sarawak	Malaysia	\N	rsblundupom@rsb.com.my	\N
140	2025-06-23 07:44:52.044621+00	016ca48e-66c5-476c-9716-c6397ed60e69	Igan oil mill	0199860283	Igan oil mill	96200	Mukah	Sarawak	\N	raphaelmodany@gmail.com	\N
141	2025-06-23 07:44:52.397687+00	08a2cbdf-9a26-4469-9034-ed7b3f5b73e9	TBS OIL MILL SDN BHD	0199501303	LOT 535, BLOCK 10, SARE LAND DISTRICT	96100	SARIKEI	SARAWAK	\N	tbs.mill.admin@taann.com.my	\N
146	2025-06-23 07:45:35.872583+00	9e6b451a-3a18-4f0c-97f3-fcccefe12a55		5608624	KAMPUNG PANTONG MELAYU	94800	simunjan	sarawak	\N	norlidakeri1@gmail.com	\N
147	2025-06-23 07:45:50.222649+00	a829ccb9-78d5-4940-82f6-934352e828cd	Lana Palm Oil Mill	+60 17-863 1863	111	97900	Sarawak	Malaysia	\N	lpom.samling@gmail.com	\N
148	2025-06-23 07:45:55.136417+00	6dc3e17b-1af0-4a4b-abaf-a9830465a207		0145885794	KAMPUNG TONG NIBONG	94700	SARAWAK	MALAYSIA	\N	pelicitym@salcra.gov.my	\N
149	2025-06-23 07:46:01.266975+00	4e579a51-bb42-45f1-9b79-b84928a98421	JPOM	0128044879	TIMOR ENTERPRISES SDN BHD (JPOM) C/O SAMLING PLYWOOD BINTULU LOT376, BLOCK 38 KEMANA INDUSTRIAL ESTATE	97000	Sarawak	Malaysia	\N	kaveeraaz@gmail.com	\N
151	2025-06-23 07:46:22.381838+00	7f05337a-1f10-411a-8c90-ab632faaf8c2	Manis Oil Sdn Bhd	0135654938	Manis Palm Oil Mill,Lot 5 Block 15 Assan Land District	96000	Sarawak	Sibu	\N	manisoil.mill.admin@taann.com.my	\N
152	2025-06-23 07:46:31.440809+00	7b53d13f-0338-44ff-a05d-238f8d25cad4	kpoi	012345678	kuching	93050	sarawak	malaysia	\N	genevieve.chinhoweyiin@my.wilmar-intl.com	\N
153	2025-06-23 07:46:53.279223+00	6c383e4a-a52d-4661-8a6c-4be47b0ed340		0135657114	55, kuching	93400	sarawak	malaysia	\N	eyz71@yahoo.com	\N
154	2025-06-23 07:47:12.302128+00	8175ff46-a82f-41f1-9650-87661f8acbb1		0109682505	kampung remun	94700	serian	sarawak	\N	hhelina@gmail.com	\N
156	2025-06-23 07:47:32.552498+00	13889f78-4916-4d07-8c07-faf25d913216	United Teamtrade Sdn Bhd (UTT Palm Oil Mill)	0198269890	No. 88, Pusat  Pedada,  Jalan  Pedada,Sibu	9600	Sarawak	Malaysia	\N	uttmill.office@gmail.com	\N
157	2025-06-23 07:48:23.017839+00	c31c618f-5148-41bb-802d-025b2b70965a		0176086018	Lot 130738, Jalan Sungai Pinang 4/1/KS11,Taman Perindustrian Pulau Indah, Pulau Indah	42920	Selangor	Malaysia	\N	yc.lee@klkoleo.com	\N
158	2025-06-23 07:51:10.650693+00	a6ee5043-034b-496f-acc8-328104c06ed9	tetangga akrab sdn bhd	0138389016	kuching	93250	sarawak	malaysia	\N	adstef82@gmail.com	\N
161	2025-06-27 08:03:58.346145+00	545c44d3-4d8a-4511-8fc5-4aaf6e8de7b9		0123456789	test	43231	Kelantan	Malaysia	\N	complainant_mspo1@yopmail.com	\N
164	2025-06-27 10:54:00.444897+00	73bc6611-cc9d-451f-94f4-855016beb48e		011223451	Taman Indera Mahkota	21300	Terengganu	Malaysia	\N	cng_elia@yopmail.com	\N
122	2025-06-23 07:40:31.219188+00	c3a67ce5-0445-4f78-8259-c115bc188a26	GAP Oil Mill SDN BHD	0198182551	5D, Lorong 10 Jalan Lada	96000	Sarawak	Malaysia	\N	tingpikhieng@gmail.com	\N
124	2025-06-23 07:40:50.640078+00	a1008ee6-6805-4d56-956d-0bcaad374870		0138001558	29, taman Kwong thiong	93250	sarawak	Malaysia	\N	abigail@salcra.gov.my	\N
129	2025-06-23 07:42:27.47689+00	e4f7c6ca-5cfe-411a-a814-45a13ee76fe4	THP SARIBAS SDN BHD	0175083534	THP SARIBAS SDN BHD, BLOCK 3, LOT NO. 44 & 45, SABLOR LAND DISTRICT	94950	SARAWAK	PUSA	\N	kru@thplantations.com	\N
131	2025-06-23 07:42:35.321272+00	2186e85a-0204-40d2-ac5a-1ae7600edfa3	salcra	0138435343	Serian Palm Oil Mill Sdn Bhd	94700	sarawak	malaysia	\N	risnid@salcra.gov.my	\N
132	2025-06-23 07:42:41.788938+00	f7280a96-7703-4d4d-b2a8-9d2acc15a160		0124129917	D8 BDA LOW KUARTERS, JALAN SULTAN ISKANDAR	97000	SARAWAK	Malaysia	\N	alicesa.ramba@keresa.com.my	\N
133	2025-06-23 07:42:52.962848+00	9e2f17ea-26c5-414b-835c-f9b42705c024	Sepakau Palm Oil Mill	0109665427	No 359 Lorong 12 Fasa 4A Unigarden	94300	Kota Samarahan	Sarawak	\N	mohdhafizmohamadrafiq@gmail.com	\N
137	2025-06-23 07:43:52.646627+00	a4051467-1969-4a0f-8657-d8f3f0ba6359		0165287371	kilang sawit loagan bunut	98300	sarawak	malaysia	\N	dienstainkemiti@gmail.com	\N
142	2025-06-23 07:45:13.485897+00	ee74b89d-137d-470c-8a00-90fb5a372727	SALCRA	0198877653	Lubok Antu Palm Oil Mill 2	95900	Sarawak	Malaysia	\N	wifredk@salcra.gov.my	\N
143	2025-06-23 07:45:26.446072+00	47676bae-55c6-48f5-8b6a-dc0a3af02ec4	Keresa Mill Sdn. Bhd.	01125152737	Lb1, Box A66, Bintulu	97000	Sarawak	Malaysia	\N	diana.do@keresa.com.my	\N
144	2025-06-23 07:45:27.899134+00	1698b43a-831d-455f-bb6f-22c3097c005f	rh pom sdn. bhd	0198242017	lot 21	96300	sarawak	mukah	\N	ndhiera82@gmail.com	\N
145	2025-06-23 07:45:30.962612+00	3142bce6-7211-4fd1-a09f-1d17e6cf287a		0198645063	No 3 Kampung Melayu	95900	Lubok Antu	Sarawak	\N	jubaidahadam123@gmail.com	\N
150	2025-06-23 07:46:09.208604+00	7d693d50-00d4-4a9b-9bc0-35afebbb30d9		0145876127	lot 61 block 8 sikat land district 	96000	sarawak	malaysia	\N	richardting@spbgroup.com.my	\N
155	2025-06-23 07:47:12.322915+00	59874f8b-4fdf-41ce-947b-da9240a861ca	SALCRA	0199369389	Kampung Mayang Kawan,	84760	Serian	Malaysia	\N	patriciah@salcra.gov.my	\N
159	2025-06-23 07:56:12.673643+00	60dea06c-f874-48fb-80ce-b71d2e65ba95		1234	1234	97010	SARAWAK	MALAYSIA	\N	bpomsamling@gmail.com	\N
162	2025-06-27 08:18:52.613022+00	f1b6d4f2-174f-4b2a-8c6c-d4531b128bfc		0123423123	test	43000	Selangor	Malaysia	\N	complainant_mspo2@yopmail.com	\N
165	2025-06-29 06:57:01.906946+00	fcc7d82b-864c-43db-9975-ff689875c391		0133622791	Taman A	42900	Perak	Malaysia	\N	adindos@yopmail.com	\N
58	2022-12-09 12:19:16+00	bdbfe7f9-be3d-45db-9e74-0bafc00e3da8	KAMPUNG SUNGAI TUDAN UJUNG DAUN	\N	\N	\N	\N	\N	RUDY AK PATRICK KUNSIL 	rudy_patrick@ymail.com	6Ge3Q9wy
59	2023-01-11 11:06:42+00	8d17a10c-9baa-4371-be70-35eff53317e4	Freelance Auditor	\N	\N	\N	\N	\N	Mohamad Padil Mat Saman	padil5595@gmail.com	cy1cx2G0
60	2023-02-01 10:14:35+00	e8e773cd-d387-4efc-b92e-98dd804a3dd3	KOMUNITI KPG BELADIN	\N	\N	\N	\N	\N	DRIS BIN NEN	nurulsyahira336@gmail.com	KjGyFXqb
61	2023-02-03 07:23:41+00	e1ccea0a-ccc5-48c9-98dd-26a48399ec52		\N	\N	\N	\N	\N	MAN A/L PUTEH	suhaidakanjisuhaida@gmail.com	B4x40NEd
62	2023-02-03 14:24:55+00	cc6ec44c-3285-40f9-84fd-fe38f6cac978	NA	\N	\N	\N	\N	\N	Jenupilni Raupil	ravestan@gmail.com	D0YRw7mK
63	2023-02-06 09:41:01+00	5ad2dbaf-6d13-47a0-b9d2-47b7adb86ff0		\N	\N	\N	\N	\N	imran mat jasim	imj800120@gmail.com	yJtdSOsk
64	2023-02-18 10:21:56+00	7d417c53-b437-40ff-911a-8d9eef5e2977	CHEONG WING CHAN SDN BHD	\N	\N	\N	\N	\N	TAJUDDIN KAMIL	tajuddinkamil@yahoo.com	2yDAfXc0
65	2023-02-25 09:27:58+00	e6dae6f9-e483-4071-923d-095f173ed23e	NBS	\N	\N	\N	\N	\N	Dylan Jefri Ong	dylan.j.ong@gmail.com	PwmLOe2G
66	2023-03-18 11:03:25+00	24d8cbc0-b247-4c06-bd71-80c775c228f0	SOLID ORIENT HOLDINGS SDN BHD	\N	\N	\N	\N	\N	SOLID ORIENT HOLDINGS SDN BHD	solidorient2812@gmail.com	mPujtIOd
67	2023-05-04 10:16:57+00	c03ad22a-b91d-4788-9b2e-d4e016651a9b	PJKKK KG. KITAGAS SANDAKAN	\N	\N	\N	\N	\N	DAUNAH BINTI SURAT	jasrsb@gmail.com	D1Okvjsy
68	2023-05-11 14:26:22+00	fe48a53d-699e-4b91-9987-efdd47b9b34b		\N	\N	\N	\N	\N	Aw Chen Siang	andyaw8149@gmail.com	uZKC15uY
69	2023-05-11 14:30:13+00	54762cd7-e15c-4dfe-b8c3-620921ec2366		\N	\N	\N	\N	\N	Rosemary Chung Chui Niu	rose_rmy@hotmail.com	yKvbgTNE
70	2023-05-11 15:59:10+00	6b17a4a1-6399-4241-8bae-98ce72ffd9b8		\N	\N	\N	\N	\N	Syafia Danial	syafiqdanial1803@hotmail.com	9tf87TQG
71	2023-05-11 16:01:12+00	646b90b4-51f9-44ce-9e89-41492cb826f9		\N	\N	\N	\N	\N	Ting Ting Siing	siing8807@gmail.com	jEPepGxk
72	2023-05-12 07:50:54+00	6f88c691-03be-4853-8903-67e2bca0d234		\N	\N	\N	\N	\N	Wong Kit Ying	kitying88@gmail.com	4E8F5Auu
73	2023-05-12 17:31:35+00	33f581a6-b5de-49d8-acdd-1166f5a55844		\N	\N	\N	\N	\N	Muhamad Abu Bakar bin Ahmad	burnbakar1538@gmail.com	FlnGgwpu
\.


--
-- Name: refresh_tokens_id_seq; Type: SEQUENCE SET; Schema: auth; Owner: -
--

SELECT pg_catalog.setval('auth.refresh_tokens_id_seq', 487, true);


--
-- Name: change_password_request_change_password_request_id_seq; Type: SEQUENCE SET; Schema: public; Owner: -
--

SELECT pg_catalog.setval('public.change_password_request_change_password_request_id_seq', 1, true);


--
-- Name: complaint_actions_id_seq; Type: SEQUENCE SET; Schema: public; Owner: -
--

SELECT pg_catalog.setval('public.complaint_actions_id_seq', 821, true);


--
-- Name: complaints_complaint_id_seq; Type: SEQUENCE SET; Schema: public; Owner: -
--

SELECT pg_catalog.setval('public.complaints_complaint_id_seq', 296, true);


--
-- Name: summary_id_seq; Type: SEQUENCE SET; Schema: public; Owner: -
--

SELECT pg_catalog.setval('public.summary_id_seq', 159, true);


--
-- Name: user_id_seq; Type: SEQUENCE SET; Schema: public; Owner: -
--

SELECT pg_catalog.setval('public.user_id_seq', 165, true);


--
-- Name: mfa_amr_claims amr_id_pk; Type: CONSTRAINT; Schema: auth; Owner: -
--

ALTER TABLE ONLY auth.mfa_amr_claims
    ADD CONSTRAINT amr_id_pk PRIMARY KEY (id);


--
-- Name: audit_log_entries audit_log_entries_pkey; Type: CONSTRAINT; Schema: auth; Owner: -
--

ALTER TABLE ONLY auth.audit_log_entries
    ADD CONSTRAINT audit_log_entries_pkey PRIMARY KEY (id);


--
-- Name: flow_state flow_state_pkey; Type: CONSTRAINT; Schema: auth; Owner: -
--

ALTER TABLE ONLY auth.flow_state
    ADD CONSTRAINT flow_state_pkey PRIMARY KEY (id);


--
-- Name: identities identities_pkey; Type: CONSTRAINT; Schema: auth; Owner: -
--

ALTER TABLE ONLY auth.identities
    ADD CONSTRAINT identities_pkey PRIMARY KEY (id);


--
-- Name: identities identities_provider_id_provider_unique; Type: CONSTRAINT; Schema: auth; Owner: -
--

ALTER TABLE ONLY auth.identities
    ADD CONSTRAINT identities_provider_id_provider_unique UNIQUE (provider_id, provider);


--
-- Name: instances instances_pkey; Type: CONSTRAINT; Schema: auth; Owner: -
--

ALTER TABLE ONLY auth.instances
    ADD CONSTRAINT instances_pkey PRIMARY KEY (id);


--
-- Name: mfa_amr_claims mfa_amr_claims_session_id_authentication_method_pkey; Type: CONSTRAINT; Schema: auth; Owner: -
--

ALTER TABLE ONLY auth.mfa_amr_claims
    ADD CONSTRAINT mfa_amr_claims_session_id_authentication_method_pkey UNIQUE (session_id, authentication_method);


--
-- Name: mfa_challenges mfa_challenges_pkey; Type: CONSTRAINT; Schema: auth; Owner: -
--

ALTER TABLE ONLY auth.mfa_challenges
    ADD CONSTRAINT mfa_challenges_pkey PRIMARY KEY (id);


--
-- Name: mfa_factors mfa_factors_last_challenged_at_key; Type: CONSTRAINT; Schema: auth; Owner: -
--

ALTER TABLE ONLY auth.mfa_factors
    ADD CONSTRAINT mfa_factors_last_challenged_at_key UNIQUE (last_challenged_at);


--
-- Name: mfa_factors mfa_factors_pkey; Type: CONSTRAINT; Schema: auth; Owner: -
--

ALTER TABLE ONLY auth.mfa_factors
    ADD CONSTRAINT mfa_factors_pkey PRIMARY KEY (id);


--
-- Name: one_time_tokens one_time_tokens_pkey; Type: CONSTRAINT; Schema: auth; Owner: -
--

ALTER TABLE ONLY auth.one_time_tokens
    ADD CONSTRAINT one_time_tokens_pkey PRIMARY KEY (id);


--
-- Name: refresh_tokens refresh_tokens_pkey; Type: CONSTRAINT; Schema: auth; Owner: -
--

ALTER TABLE ONLY auth.refresh_tokens
    ADD CONSTRAINT refresh_tokens_pkey PRIMARY KEY (id);


--
-- Name: refresh_tokens refresh_tokens_token_unique; Type: CONSTRAINT; Schema: auth; Owner: -
--

ALTER TABLE ONLY auth.refresh_tokens
    ADD CONSTRAINT refresh_tokens_token_unique UNIQUE (token);


--
-- Name: saml_providers saml_providers_entity_id_key; Type: CONSTRAINT; Schema: auth; Owner: -
--

ALTER TABLE ONLY auth.saml_providers
    ADD CONSTRAINT saml_providers_entity_id_key UNIQUE (entity_id);


--
-- Name: saml_providers saml_providers_pkey; Type: CONSTRAINT; Schema: auth; Owner: -
--

ALTER TABLE ONLY auth.saml_providers
    ADD CONSTRAINT saml_providers_pkey PRIMARY KEY (id);


--
-- Name: saml_relay_states saml_relay_states_pkey; Type: CONSTRAINT; Schema: auth; Owner: -
--

ALTER TABLE ONLY auth.saml_relay_states
    ADD CONSTRAINT saml_relay_states_pkey PRIMARY KEY (id);


--
-- Name: schema_migrations schema_migrations_pkey; Type: CONSTRAINT; Schema: auth; Owner: -
--

ALTER TABLE ONLY auth.schema_migrations
    ADD CONSTRAINT schema_migrations_pkey PRIMARY KEY (version);


--
-- Name: sessions sessions_pkey; Type: CONSTRAINT; Schema: auth; Owner: -
--

ALTER TABLE ONLY auth.sessions
    ADD CONSTRAINT sessions_pkey PRIMARY KEY (id);


--
-- Name: sso_domains sso_domains_pkey; Type: CONSTRAINT; Schema: auth; Owner: -
--

ALTER TABLE ONLY auth.sso_domains
    ADD CONSTRAINT sso_domains_pkey PRIMARY KEY (id);


--
-- Name: sso_providers sso_providers_pkey; Type: CONSTRAINT; Schema: auth; Owner: -
--

ALTER TABLE ONLY auth.sso_providers
    ADD CONSTRAINT sso_providers_pkey PRIMARY KEY (id);


--
-- Name: users users_phone_key; Type: CONSTRAINT; Schema: auth; Owner: -
--

ALTER TABLE ONLY auth.users
    ADD CONSTRAINT users_phone_key UNIQUE (phone);


--
-- Name: users users_pkey; Type: CONSTRAINT; Schema: auth; Owner: -
--

ALTER TABLE ONLY auth.users
    ADD CONSTRAINT users_pkey PRIMARY KEY (id);


--
-- Name: change_password_request change_password_request_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.change_password_request
    ADD CONSTRAINT change_password_request_pkey PRIMARY KEY (change_password_request_id);


--
-- Name: complaint_actions complaint_actions_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.complaint_actions
    ADD CONSTRAINT complaint_actions_pkey PRIMARY KEY (action_id);


--
-- Name: complaints complaints_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.complaints
    ADD CONSTRAINT complaints_pkey PRIMARY KEY (complaint_id);


--
-- Name: summary summary_complaint_id_key; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.summary
    ADD CONSTRAINT summary_complaint_id_key UNIQUE (complaint_id);


--
-- Name: summary summary_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.summary
    ADD CONSTRAINT summary_pkey PRIMARY KEY (id);


--
-- Name: user user_id_key; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public."user"
    ADD CONSTRAINT user_id_key UNIQUE (id);


--
-- Name: user user_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public."user"
    ADD CONSTRAINT user_pkey PRIMARY KEY (id, user_id);


--
-- Name: user user_user_id_key; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public."user"
    ADD CONSTRAINT user_user_id_key UNIQUE (user_id);


--
-- Name: audit_logs_instance_id_idx; Type: INDEX; Schema: auth; Owner: -
--

CREATE INDEX audit_logs_instance_id_idx ON auth.audit_log_entries USING btree (instance_id);


--
-- Name: confirmation_token_idx; Type: INDEX; Schema: auth; Owner: -
--

CREATE UNIQUE INDEX confirmation_token_idx ON auth.users USING btree (confirmation_token) WHERE ((confirmation_token)::text !~ '^[0-9 ]*$'::text);


--
-- Name: email_change_token_current_idx; Type: INDEX; Schema: auth; Owner: -
--

CREATE UNIQUE INDEX email_change_token_current_idx ON auth.users USING btree (email_change_token_current) WHERE ((email_change_token_current)::text !~ '^[0-9 ]*$'::text);


--
-- Name: email_change_token_new_idx; Type: INDEX; Schema: auth; Owner: -
--

CREATE UNIQUE INDEX email_change_token_new_idx ON auth.users USING btree (email_change_token_new) WHERE ((email_change_token_new)::text !~ '^[0-9 ]*$'::text);


--
-- Name: factor_id_created_at_idx; Type: INDEX; Schema: auth; Owner: -
--

CREATE INDEX factor_id_created_at_idx ON auth.mfa_factors USING btree (user_id, created_at);


--
-- Name: flow_state_created_at_idx; Type: INDEX; Schema: auth; Owner: -
--

CREATE INDEX flow_state_created_at_idx ON auth.flow_state USING btree (created_at DESC);


--
-- Name: identities_email_idx; Type: INDEX; Schema: auth; Owner: -
--

CREATE INDEX identities_email_idx ON auth.identities USING btree (email text_pattern_ops);


--
-- Name: INDEX identities_email_idx; Type: COMMENT; Schema: auth; Owner: -
--

COMMENT ON INDEX auth.identities_email_idx IS 'Auth: Ensures indexed queries on the email column';


--
-- Name: identities_user_id_idx; Type: INDEX; Schema: auth; Owner: -
--

CREATE INDEX identities_user_id_idx ON auth.identities USING btree (user_id);


--
-- Name: idx_auth_code; Type: INDEX; Schema: auth; Owner: -
--

CREATE INDEX idx_auth_code ON auth.flow_state USING btree (auth_code);


--
-- Name: idx_user_id_auth_method; Type: INDEX; Schema: auth; Owner: -
--

CREATE INDEX idx_user_id_auth_method ON auth.flow_state USING btree (user_id, authentication_method);


--
-- Name: mfa_challenge_created_at_idx; Type: INDEX; Schema: auth; Owner: -
--

CREATE INDEX mfa_challenge_created_at_idx ON auth.mfa_challenges USING btree (created_at DESC);


--
-- Name: mfa_factors_user_friendly_name_unique; Type: INDEX; Schema: auth; Owner: -
--

CREATE UNIQUE INDEX mfa_factors_user_friendly_name_unique ON auth.mfa_factors USING btree (friendly_name, user_id) WHERE (TRIM(BOTH FROM friendly_name) <> ''::text);


--
-- Name: mfa_factors_user_id_idx; Type: INDEX; Schema: auth; Owner: -
--

CREATE INDEX mfa_factors_user_id_idx ON auth.mfa_factors USING btree (user_id);


--
-- Name: one_time_tokens_relates_to_hash_idx; Type: INDEX; Schema: auth; Owner: -
--

CREATE INDEX one_time_tokens_relates_to_hash_idx ON auth.one_time_tokens USING hash (relates_to);


--
-- Name: one_time_tokens_token_hash_hash_idx; Type: INDEX; Schema: auth; Owner: -
--

CREATE INDEX one_time_tokens_token_hash_hash_idx ON auth.one_time_tokens USING hash (token_hash);


--
-- Name: one_time_tokens_user_id_token_type_key; Type: INDEX; Schema: auth; Owner: -
--

CREATE UNIQUE INDEX one_time_tokens_user_id_token_type_key ON auth.one_time_tokens USING btree (user_id, token_type);


--
-- Name: reauthentication_token_idx; Type: INDEX; Schema: auth; Owner: -
--

CREATE UNIQUE INDEX reauthentication_token_idx ON auth.users USING btree (reauthentication_token) WHERE ((reauthentication_token)::text !~ '^[0-9 ]*$'::text);


--
-- Name: recovery_token_idx; Type: INDEX; Schema: auth; Owner: -
--

CREATE UNIQUE INDEX recovery_token_idx ON auth.users USING btree (recovery_token) WHERE ((recovery_token)::text !~ '^[0-9 ]*$'::text);


--
-- Name: refresh_tokens_instance_id_idx; Type: INDEX; Schema: auth; Owner: -
--

CREATE INDEX refresh_tokens_instance_id_idx ON auth.refresh_tokens USING btree (instance_id);


--
-- Name: refresh_tokens_instance_id_user_id_idx; Type: INDEX; Schema: auth; Owner: -
--

CREATE INDEX refresh_tokens_instance_id_user_id_idx ON auth.refresh_tokens USING btree (instance_id, user_id);


--
-- Name: refresh_tokens_parent_idx; Type: INDEX; Schema: auth; Owner: -
--

CREATE INDEX refresh_tokens_parent_idx ON auth.refresh_tokens USING btree (parent);


--
-- Name: refresh_tokens_session_id_revoked_idx; Type: INDEX; Schema: auth; Owner: -
--

CREATE INDEX refresh_tokens_session_id_revoked_idx ON auth.refresh_tokens USING btree (session_id, revoked);


--
-- Name: refresh_tokens_updated_at_idx; Type: INDEX; Schema: auth; Owner: -
--

CREATE INDEX refresh_tokens_updated_at_idx ON auth.refresh_tokens USING btree (updated_at DESC);


--
-- Name: saml_providers_sso_provider_id_idx; Type: INDEX; Schema: auth; Owner: -
--

CREATE INDEX saml_providers_sso_provider_id_idx ON auth.saml_providers USING btree (sso_provider_id);


--
-- Name: saml_relay_states_created_at_idx; Type: INDEX; Schema: auth; Owner: -
--

CREATE INDEX saml_relay_states_created_at_idx ON auth.saml_relay_states USING btree (created_at DESC);


--
-- Name: saml_relay_states_for_email_idx; Type: INDEX; Schema: auth; Owner: -
--

CREATE INDEX saml_relay_states_for_email_idx ON auth.saml_relay_states USING btree (for_email);


--
-- Name: saml_relay_states_sso_provider_id_idx; Type: INDEX; Schema: auth; Owner: -
--

CREATE INDEX saml_relay_states_sso_provider_id_idx ON auth.saml_relay_states USING btree (sso_provider_id);


--
-- Name: sessions_not_after_idx; Type: INDEX; Schema: auth; Owner: -
--

CREATE INDEX sessions_not_after_idx ON auth.sessions USING btree (not_after DESC);


--
-- Name: sessions_user_id_idx; Type: INDEX; Schema: auth; Owner: -
--

CREATE INDEX sessions_user_id_idx ON auth.sessions USING btree (user_id);


--
-- Name: sso_domains_domain_idx; Type: INDEX; Schema: auth; Owner: -
--

CREATE UNIQUE INDEX sso_domains_domain_idx ON auth.sso_domains USING btree (lower(domain));


--
-- Name: sso_domains_sso_provider_id_idx; Type: INDEX; Schema: auth; Owner: -
--

CREATE INDEX sso_domains_sso_provider_id_idx ON auth.sso_domains USING btree (sso_provider_id);


--
-- Name: sso_providers_resource_id_idx; Type: INDEX; Schema: auth; Owner: -
--

CREATE UNIQUE INDEX sso_providers_resource_id_idx ON auth.sso_providers USING btree (lower(resource_id));


--
-- Name: unique_phone_factor_per_user; Type: INDEX; Schema: auth; Owner: -
--

CREATE UNIQUE INDEX unique_phone_factor_per_user ON auth.mfa_factors USING btree (user_id, phone);


--
-- Name: user_id_created_at_idx; Type: INDEX; Schema: auth; Owner: -
--

CREATE INDEX user_id_created_at_idx ON auth.sessions USING btree (user_id, created_at);


--
-- Name: users_email_partial_key; Type: INDEX; Schema: auth; Owner: -
--

CREATE UNIQUE INDEX users_email_partial_key ON auth.users USING btree (email) WHERE (is_sso_user = false);


--
-- Name: INDEX users_email_partial_key; Type: COMMENT; Schema: auth; Owner: -
--

COMMENT ON INDEX auth.users_email_partial_key IS 'Auth: A partial unique index that applies only when is_sso_user is false';


--
-- Name: users_instance_id_email_idx; Type: INDEX; Schema: auth; Owner: -
--

CREATE INDEX users_instance_id_email_idx ON auth.users USING btree (instance_id, lower((email)::text));


--
-- Name: users_instance_id_idx; Type: INDEX; Schema: auth; Owner: -
--

CREATE INDEX users_instance_id_idx ON auth.users USING btree (instance_id);


--
-- Name: users_is_anonymous_idx; Type: INDEX; Schema: auth; Owner: -
--

CREATE INDEX users_is_anonymous_idx ON auth.users USING btree (is_anonymous);


--
-- Name: identities identities_user_id_fkey; Type: FK CONSTRAINT; Schema: auth; Owner: -
--

ALTER TABLE ONLY auth.identities
    ADD CONSTRAINT identities_user_id_fkey FOREIGN KEY (user_id) REFERENCES auth.users(id) ON DELETE CASCADE;


--
-- Name: mfa_amr_claims mfa_amr_claims_session_id_fkey; Type: FK CONSTRAINT; Schema: auth; Owner: -
--

ALTER TABLE ONLY auth.mfa_amr_claims
    ADD CONSTRAINT mfa_amr_claims_session_id_fkey FOREIGN KEY (session_id) REFERENCES auth.sessions(id) ON DELETE CASCADE;


--
-- Name: mfa_challenges mfa_challenges_auth_factor_id_fkey; Type: FK CONSTRAINT; Schema: auth; Owner: -
--

ALTER TABLE ONLY auth.mfa_challenges
    ADD CONSTRAINT mfa_challenges_auth_factor_id_fkey FOREIGN KEY (factor_id) REFERENCES auth.mfa_factors(id) ON DELETE CASCADE;


--
-- Name: mfa_factors mfa_factors_user_id_fkey; Type: FK CONSTRAINT; Schema: auth; Owner: -
--

ALTER TABLE ONLY auth.mfa_factors
    ADD CONSTRAINT mfa_factors_user_id_fkey FOREIGN KEY (user_id) REFERENCES auth.users(id) ON DELETE CASCADE;


--
-- Name: one_time_tokens one_time_tokens_user_id_fkey; Type: FK CONSTRAINT; Schema: auth; Owner: -
--

ALTER TABLE ONLY auth.one_time_tokens
    ADD CONSTRAINT one_time_tokens_user_id_fkey FOREIGN KEY (user_id) REFERENCES auth.users(id) ON DELETE CASCADE;


--
-- Name: refresh_tokens refresh_tokens_session_id_fkey; Type: FK CONSTRAINT; Schema: auth; Owner: -
--

ALTER TABLE ONLY auth.refresh_tokens
    ADD CONSTRAINT refresh_tokens_session_id_fkey FOREIGN KEY (session_id) REFERENCES auth.sessions(id) ON DELETE CASCADE;


--
-- Name: saml_providers saml_providers_sso_provider_id_fkey; Type: FK CONSTRAINT; Schema: auth; Owner: -
--

ALTER TABLE ONLY auth.saml_providers
    ADD CONSTRAINT saml_providers_sso_provider_id_fkey FOREIGN KEY (sso_provider_id) REFERENCES auth.sso_providers(id) ON DELETE CASCADE;


--
-- Name: saml_relay_states saml_relay_states_flow_state_id_fkey; Type: FK CONSTRAINT; Schema: auth; Owner: -
--

ALTER TABLE ONLY auth.saml_relay_states
    ADD CONSTRAINT saml_relay_states_flow_state_id_fkey FOREIGN KEY (flow_state_id) REFERENCES auth.flow_state(id) ON DELETE CASCADE;


--
-- Name: saml_relay_states saml_relay_states_sso_provider_id_fkey; Type: FK CONSTRAINT; Schema: auth; Owner: -
--

ALTER TABLE ONLY auth.saml_relay_states
    ADD CONSTRAINT saml_relay_states_sso_provider_id_fkey FOREIGN KEY (sso_provider_id) REFERENCES auth.sso_providers(id) ON DELETE CASCADE;


--
-- Name: sessions sessions_user_id_fkey; Type: FK CONSTRAINT; Schema: auth; Owner: -
--

ALTER TABLE ONLY auth.sessions
    ADD CONSTRAINT sessions_user_id_fkey FOREIGN KEY (user_id) REFERENCES auth.users(id) ON DELETE CASCADE;


--
-- Name: sso_domains sso_domains_sso_provider_id_fkey; Type: FK CONSTRAINT; Schema: auth; Owner: -
--

ALTER TABLE ONLY auth.sso_domains
    ADD CONSTRAINT sso_domains_sso_provider_id_fkey FOREIGN KEY (sso_provider_id) REFERENCES auth.sso_providers(id) ON DELETE CASCADE;


--
-- Name: complaints complaints_last_action_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.complaints
    ADD CONSTRAINT complaints_last_action_fkey FOREIGN KEY (last_action) REFERENCES public.complaint_actions(action_id);


--
-- Name: summary summary_complaint_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.summary
    ADD CONSTRAINT summary_complaint_id_fkey FOREIGN KEY (complaint_id) REFERENCES public.complaints(complaint_id);


--
-- Name: audit_log_entries; Type: ROW SECURITY; Schema: auth; Owner: -
--

ALTER TABLE auth.audit_log_entries ENABLE ROW LEVEL SECURITY;

--
-- Name: flow_state; Type: ROW SECURITY; Schema: auth; Owner: -
--

ALTER TABLE auth.flow_state ENABLE ROW LEVEL SECURITY;

--
-- Name: identities; Type: ROW SECURITY; Schema: auth; Owner: -
--

ALTER TABLE auth.identities ENABLE ROW LEVEL SECURITY;

--
-- Name: instances; Type: ROW SECURITY; Schema: auth; Owner: -
--

ALTER TABLE auth.instances ENABLE ROW LEVEL SECURITY;

--
-- Name: mfa_amr_claims; Type: ROW SECURITY; Schema: auth; Owner: -
--

ALTER TABLE auth.mfa_amr_claims ENABLE ROW LEVEL SECURITY;

--
-- Name: mfa_challenges; Type: ROW SECURITY; Schema: auth; Owner: -
--

ALTER TABLE auth.mfa_challenges ENABLE ROW LEVEL SECURITY;

--
-- Name: mfa_factors; Type: ROW SECURITY; Schema: auth; Owner: -
--

ALTER TABLE auth.mfa_factors ENABLE ROW LEVEL SECURITY;

--
-- Name: one_time_tokens; Type: ROW SECURITY; Schema: auth; Owner: -
--

ALTER TABLE auth.one_time_tokens ENABLE ROW LEVEL SECURITY;

--
-- Name: refresh_tokens; Type: ROW SECURITY; Schema: auth; Owner: -
--

ALTER TABLE auth.refresh_tokens ENABLE ROW LEVEL SECURITY;

--
-- Name: saml_providers; Type: ROW SECURITY; Schema: auth; Owner: -
--

ALTER TABLE auth.saml_providers ENABLE ROW LEVEL SECURITY;

--
-- Name: saml_relay_states; Type: ROW SECURITY; Schema: auth; Owner: -
--

ALTER TABLE auth.saml_relay_states ENABLE ROW LEVEL SECURITY;

--
-- Name: schema_migrations; Type: ROW SECURITY; Schema: auth; Owner: -
--

ALTER TABLE auth.schema_migrations ENABLE ROW LEVEL SECURITY;

--
-- Name: sessions; Type: ROW SECURITY; Schema: auth; Owner: -
--

ALTER TABLE auth.sessions ENABLE ROW LEVEL SECURITY;

--
-- Name: sso_domains; Type: ROW SECURITY; Schema: auth; Owner: -
--

ALTER TABLE auth.sso_domains ENABLE ROW LEVEL SECURITY;

--
-- Name: sso_providers; Type: ROW SECURITY; Schema: auth; Owner: -
--

ALTER TABLE auth.sso_providers ENABLE ROW LEVEL SECURITY;

--
-- Name: users; Type: ROW SECURITY; Schema: auth; Owner: -
--

ALTER TABLE auth.users ENABLE ROW LEVEL SECURITY;

--
-- Name: complaint_actions Disable updates for closed; Type: POLICY; Schema: public; Owner: -
--

CREATE POLICY "Disable updates for closed" ON public.complaint_actions FOR INSERT TO authenticated WITH CHECK ((EXISTS ( SELECT 1
   FROM public.complaints
  WHERE ((complaints.complaint_id = complaint_actions.complaint_id) AND (complaints.complainant = auth.uid()) AND (NOT complaint_actions.confidential) AND (complaints.status <> ALL (ARRAY['closed'::text])) AND (complaint_actions.action = ANY (ARRAY['evidence'::text, 'appealed'::text, 'closed'::text]))))));


--
-- Name: complaints Enable insert for users based on user_id; Type: POLICY; Schema: public; Owner: -
--

CREATE POLICY "Enable insert for users based on user_id" ON public.complaints FOR INSERT WITH CHECK ((( SELECT auth.uid() AS uid) = complainant));


--
-- Name: user Enable insert for users based on user_id; Type: POLICY; Schema: public; Owner: -
--

CREATE POLICY "Enable insert for users based on user_id" ON public."user" FOR INSERT WITH CHECK ((( SELECT auth.uid() AS uid) = user_id));


--
-- Name: complaints Enable users to view their own data only; Type: POLICY; Schema: public; Owner: -
--

CREATE POLICY "Enable users to view their own data only" ON public.complaints FOR SELECT TO authenticated USING ((( SELECT auth.uid() AS uid) = complainant));


--
-- Name: complaint_actions Select only allowed; Type: POLICY; Schema: public; Owner: -
--

CREATE POLICY "Select only allowed" ON public.complaint_actions FOR SELECT TO authenticated USING ((EXISTS ( SELECT 1
   FROM public.complaints
  WHERE ((complaints.complaint_id = complaint_actions.complaint_id) AND (complaints.complainant = auth.uid()) AND (NOT complaint_actions.confidential)))));


--
-- Name: complaint_actions; Type: ROW SECURITY; Schema: public; Owner: -
--

ALTER TABLE public.complaint_actions ENABLE ROW LEVEL SECURITY;

--
-- Name: complaints; Type: ROW SECURITY; Schema: public; Owner: -
--

ALTER TABLE public.complaints ENABLE ROW LEVEL SECURITY;

--
-- Name: summary get all summaries; Type: POLICY; Schema: public; Owner: -
--

CREATE POLICY "get all summaries" ON public.summary FOR SELECT TO authenticated, anon USING ((hide = false));


--
-- Name: summary; Type: ROW SECURITY; Schema: public; Owner: -
--

ALTER TABLE public.summary ENABLE ROW LEVEL SECURITY;

--
-- Name: user; Type: ROW SECURITY; Schema: public; Owner: -
--

ALTER TABLE public."user" ENABLE ROW LEVEL SECURITY;

--
-- PostgreSQL database dump complete
--

