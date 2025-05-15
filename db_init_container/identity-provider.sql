--
-- PostgreSQL database dump
--

-- Dumped from database version 16.8 (Ubuntu 16.8-0ubuntu0.24.04.1)
-- Dumped by pg_dump version 16.8 (Ubuntu 16.8-0ubuntu0.24.04.1)

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

SET default_tablespace = '';

SET default_table_access_method = heap;

--
-- Name: applications; Type: TABLE; Schema: public; Owner: identityprovider
--

CREATE TABLE public.applications (
    id bigint NOT NULL,
    owner_id bigint NOT NULL,
    name character varying(255) NOT NULL,
    client_id character varying(255) NOT NULL,
    added_at timestamp without time zone NOT NULL
);


ALTER TABLE public.applications OWNER TO identityprovider;

--
-- Name: databasechangelog; Type: TABLE; Schema: public; Owner: identityprovider
--

CREATE TABLE public.databasechangelog (
    id character varying(255) NOT NULL,
    author character varying(255) NOT NULL,
    filename character varying(255) NOT NULL,
    dateexecuted timestamp without time zone NOT NULL,
    orderexecuted integer NOT NULL,
    exectype character varying(10) NOT NULL,
    md5sum character varying(35),
    description character varying(255),
    comments character varying(255),
    tag character varying(255),
    liquibase character varying(20),
    contexts character varying(255),
    labels character varying(255),
    deployment_id character varying(10)
);


ALTER TABLE public.databasechangelog OWNER TO identityprovider;

--
-- Name: databasechangeloglock; Type: TABLE; Schema: public; Owner: identityprovider
--

CREATE TABLE public.databasechangeloglock (
    id integer NOT NULL,
    locked boolean NOT NULL,
    lockgranted timestamp without time zone,
    lockedby character varying(255)
);


ALTER TABLE public.databasechangeloglock OWNER TO identityprovider;

--
-- Name: hibernate_sequence; Type: SEQUENCE; Schema: public; Owner: identityprovider
--

CREATE SEQUENCE public.hibernate_sequence
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER SEQUENCE public.hibernate_sequence OWNER TO identityprovider;

--
-- Name: oauth2_authorization; Type: TABLE; Schema: public; Owner: identityprovider
--

CREATE TABLE public.oauth2_authorization (
    id character varying(100) NOT NULL,
    registered_client_id character varying(100) NOT NULL,
    principal_name character varying(255) NOT NULL,
    authorization_grant_type character varying(100) NOT NULL,
    authorized_scopes character varying(1000),
    attributes text,
    state character varying(500),
    authorization_code_value text,
    authorization_code_issued_at timestamp without time zone,
    authorization_code_expires_at timestamp without time zone,
    authorization_code_metadata text,
    access_token_value text,
    access_token_issued_at timestamp without time zone,
    access_token_expires_at timestamp without time zone,
    access_token_metadata text,
    access_token_type character varying(100),
    access_token_scopes character varying(1000),
    oidc_id_token_value text,
    oidc_id_token_issued_at timestamp without time zone,
    oidc_id_token_expires_at timestamp without time zone,
    oidc_id_token_metadata text,
    oidc_id_token_claims character varying(2000),
    refresh_token_value text,
    refresh_token_issued_at timestamp without time zone,
    refresh_token_expires_at timestamp without time zone,
    refresh_token_metadata text,
    user_code_value text,
    user_code_issued_at timestamp without time zone,
    user_code_expires_at timestamp without time zone,
    user_code_metadata text,
    device_code_value text,
    device_code_issued_at timestamp without time zone,
    device_code_expires_at timestamp without time zone,
    device_code_metadata text
);


ALTER TABLE public.oauth2_authorization OWNER TO identityprovider;

--
-- Name: oauth2_client; Type: TABLE; Schema: public; Owner: identityprovider
--

CREATE TABLE public.oauth2_client (
    id character varying(100) NOT NULL,
    client_id character varying(100) NOT NULL,
    client_id_issued_at timestamp without time zone,
    client_secret character varying(255),
    client_secret_expires_at timestamp without time zone,
    client_name character varying(255),
    client_authentication_methods character varying(1000),
    authorization_grant_types character varying(1000),
    redirect_uris character varying(1000),
    post_logout_redirect_uris character varying(1000),
    scopes character varying(1000),
    client_settings character varying(2000),
    token_settings character varying(2000)
);


ALTER TABLE public.oauth2_client OWNER TO identityprovider;

--
-- Name: userroles; Type: TABLE; Schema: public; Owner: identityprovider
--

CREATE TABLE public.userroles (
    id bigint NOT NULL,
    user_id bigint NOT NULL,
    member_id character varying(767) NOT NULL,
    role character varying(255) NOT NULL,
    given_at timestamp without time zone NOT NULL
);


ALTER TABLE public.userroles OWNER TO identityprovider;

--
-- Name: users; Type: TABLE; Schema: public; Owner: identityprovider
--

CREATE TABLE public.users (
    id bigint NOT NULL,
    username character varying(255) NOT NULL,
    password character varying(255) NOT NULL,
    added_at timestamp without time zone NOT NULL,
    updated_at timestamp without time zone NOT NULL,
    locked_at timestamp without time zone,
    blocked boolean DEFAULT false NOT NULL,
    password_change_required boolean NOT NULL,
    failed_login_attempts integer NOT NULL
);


ALTER TABLE public.users OWNER TO identityprovider;

--
-- Data for Name: applications; Type: TABLE DATA; Schema: public; Owner: identityprovider
--

COPY public.applications (id, owner_id, name, client_id, added_at) FROM stdin;
\.


--
-- Data for Name: databasechangelog; Type: TABLE DATA; Schema: public; Owner: identityprovider
--

COPY public.databasechangelog (id, author, filename, dateexecuted, orderexecuted, exectype, md5sum, description, comments, tag, liquibase, contexts, labels, deployment_id) FROM stdin;
0-initial	cyber	identity-provider/0-initial.xml	2025-05-10 15:49:10.976675	1	EXECUTED	9:f4ed31593b71ab4dddf7d873e923d339	createTable tableName=USERS; createTable tableName=USERROLES; addPrimaryKey constraintName=USERSPK, tableName=USERS; addPrimaryKey constraintName=USERROLESPK, tableName=USERROLES; addForeignKeyConstraint baseTableName=USERROLES, constraintName=FK_...		\N	4.29.2	\N	\N	6892150837
\.


--
-- Data for Name: databasechangeloglock; Type: TABLE DATA; Schema: public; Owner: identityprovider
--

COPY public.databasechangeloglock (id, locked, lockgranted, lockedby) FROM stdin;
1	f	\N	\N
\.


--
-- Data for Name: oauth2_authorization; Type: TABLE DATA; Schema: public; Owner: identityprovider
--

COPY public.oauth2_authorization (id, registered_client_id, principal_name, authorization_grant_type, authorized_scopes, attributes, state, authorization_code_value, authorization_code_issued_at, authorization_code_expires_at, authorization_code_metadata, access_token_value, access_token_issued_at, access_token_expires_at, access_token_metadata, access_token_type, access_token_scopes, oidc_id_token_value, oidc_id_token_issued_at, oidc_id_token_expires_at, oidc_id_token_metadata, oidc_id_token_claims, refresh_token_value, refresh_token_issued_at, refresh_token_expires_at, refresh_token_metadata, user_code_value, user_code_issued_at, user_code_expires_at, user_code_metadata, device_code_value, device_code_issued_at, device_code_expires_at, device_code_metadata) FROM stdin;
\.


--
-- Data for Name: oauth2_client; Type: TABLE DATA; Schema: public; Owner: identityprovider
--

COPY public.oauth2_client (id, client_id, client_id_issued_at, client_secret, client_secret_expires_at, client_name, client_authentication_methods, authorization_grant_types, redirect_uris, post_logout_redirect_uris, scopes, client_settings, token_settings) FROM stdin;
adb322f5-d325-4604-8692-d7dbb0dd37f2	uxp-ss-ui	\N	\N	\N	adb322f5-d325-4604-8692-d7dbb0dd37f2	none	refresh_token,authorization_code	https://48259ae4ff4a:4000/verifier-api/v1/swagger-ui/oauth2-redirect.html,https://48259ae4ff4a:4000/api/v1/swagger-ui/oauth2-redirect.html,https://172.17.0.2:4000,https://172.17.0.2:4000/api/v1/swagger-ui/oauth2-redirect.html,https://172.17.0.2:4000/verifier-api/v1/swagger-ui/oauth2-redirect.html,https://48259ae4ff4a:4000,https://48259ae4ff4a:4000/auth-api/v1/swagger-ui/oauth2-redirect.html,https://172.17.0.2:4000/auth-api/v1/swagger-ui/oauth2-redirect.html		openid,uxp_roles	{"@class":"java.util.Collections$UnmodifiableMap","settings.client.require-proof-key":true,"settings.client.require-authorization-consent":false}	{"@class":"java.util.Collections$UnmodifiableMap","settings.token.reuse-refresh-tokens":false,"settings.token.x509-certificate-bound-access-tokens":false,"settings.token.id-token-signature-algorithm":["org.springframework.security.oauth2.jose.jws.SignatureAlgorithm","RS256"],"settings.token.access-token-time-to-live":["java.time.Duration","PT3H"],"settings.token.access-token-format":{"@class":"org.springframework.security.oauth2.server.authorization.settings.OAuth2TokenFormat","value":"reference"},"settings.token.refresh-token-time-to-live":["java.time.Duration","PT1H"],"settings.token.authorization-code-time-to-live":["java.time.Duration","PT5M"],"settings.token.device-code-time-to-live":["java.time.Duration","PT5M"]}
55ce0102-2356-41e3-ab64-1bd4a01b13ce	bc91rmrwdgwbqazrbl5ci4rvb4zyscvy	\N	$2a$10$YC8nxMMKBvmynOIaHUc3ZOIpbQT7LBbqZEpkrEpeaz4CV6w5r5goy	\N	55ce0102-2356-41e3-ab64-1bd4a01b13ce	client_secret_basic	client_credentials				{"@class":"java.util.Collections$UnmodifiableMap","settings.client.require-proof-key":false,"settings.client.require-authorization-consent":false}	{"@class":"java.util.Collections$UnmodifiableMap","settings.token.reuse-refresh-tokens":true,"settings.token.x509-certificate-bound-access-tokens":false,"settings.token.id-token-signature-algorithm":["org.springframework.security.oauth2.jose.jws.SignatureAlgorithm","RS256"],"settings.token.access-token-time-to-live":["java.time.Duration","PT5M"],"settings.token.access-token-format":{"@class":"org.springframework.security.oauth2.server.authorization.settings.OAuth2TokenFormat","value":"self-contained"},"settings.token.refresh-token-time-to-live":["java.time.Duration","PT1H"],"settings.token.authorization-code-time-to-live":["java.time.Duration","PT5M"],"settings.token.device-code-time-to-live":["java.time.Duration","PT5M"]}
\.


--
-- Data for Name: userroles; Type: TABLE DATA; Schema: public; Owner: identityprovider
--

COPY public.userroles (id, user_id, member_id, role, given_at) FROM stdin;
2	1	ALL_MEMBERS	SERVER_ADMIN	2025-05-10 15:49:11.570328
3	1	ALL_MEMBERS	SERVICE_MANAGER	2025-05-10 15:49:11.57199
4	1	ALL_MEMBERS	KEY_MANAGER	2025-05-10 15:49:11.572471
\.


--
-- Data for Name: users; Type: TABLE DATA; Schema: public; Owner: identityprovider
--

COPY public.users (id, username, password, added_at, updated_at, locked_at, blocked, password_change_required, failed_login_attempts) FROM stdin;
1	uxpadmin	$2a$10$wheTtylHF79zU4.MI6F1tuyyCm5Pyw7AMUbR..oKmRCAeq0rY2sze	2025-05-10 15:49:11.567987	2025-05-10 15:49:11.567987	\N	f	f	0
\.


--
-- Name: hibernate_sequence; Type: SEQUENCE SET; Schema: public; Owner: identityprovider
--

SELECT pg_catalog.setval('public.hibernate_sequence', 33, true);


--
-- Name: applications application_pk; Type: CONSTRAINT; Schema: public; Owner: identityprovider
--

ALTER TABLE ONLY public.applications
    ADD CONSTRAINT application_pk PRIMARY KEY (id);


--
-- Name: databasechangeloglock databasechangeloglock_pkey; Type: CONSTRAINT; Schema: public; Owner: identityprovider
--

ALTER TABLE ONLY public.databasechangeloglock
    ADD CONSTRAINT databasechangeloglock_pkey PRIMARY KEY (id);


--
-- Name: oauth2_authorization oauth2_authorization_pk; Type: CONSTRAINT; Schema: public; Owner: identityprovider
--

ALTER TABLE ONLY public.oauth2_authorization
    ADD CONSTRAINT oauth2_authorization_pk PRIMARY KEY (id);


--
-- Name: oauth2_client oauth2_client_pk; Type: CONSTRAINT; Schema: public; Owner: identityprovider
--

ALTER TABLE ONLY public.oauth2_client
    ADD CONSTRAINT oauth2_client_pk PRIMARY KEY (id);


--
-- Name: userroles userrolespk; Type: CONSTRAINT; Schema: public; Owner: identityprovider
--

ALTER TABLE ONLY public.userroles
    ADD CONSTRAINT userrolespk PRIMARY KEY (id);


--
-- Name: users users_username_key; Type: CONSTRAINT; Schema: public; Owner: identityprovider
--

ALTER TABLE ONLY public.users
    ADD CONSTRAINT users_username_key UNIQUE (username);


--
-- Name: users userspk; Type: CONSTRAINT; Schema: public; Owner: identityprovider
--

ALTER TABLE ONLY public.users
    ADD CONSTRAINT userspk PRIMARY KEY (id);


--
-- Name: applications fk_application_owner; Type: FK CONSTRAINT; Schema: public; Owner: identityprovider
--

ALTER TABLE ONLY public.applications
    ADD CONSTRAINT fk_application_owner FOREIGN KEY (owner_id) REFERENCES public.users(id);


--
-- Name: userroles fk_userrole_user; Type: FK CONSTRAINT; Schema: public; Owner: identityprovider
--

ALTER TABLE ONLY public.userroles
    ADD CONSTRAINT fk_userrole_user FOREIGN KEY (user_id) REFERENCES public.users(id);


--
-- PostgreSQL database dump complete
--

