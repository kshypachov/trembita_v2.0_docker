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
-- Name: databasechangelog; Type: TABLE; Schema: public; Owner: opmonitor_admin
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


ALTER TABLE public.databasechangelog OWNER TO opmonitor_admin;

--
-- Name: databasechangeloglock; Type: TABLE; Schema: public; Owner: opmonitor_admin
--

CREATE TABLE public.databasechangeloglock (
    id integer NOT NULL,
    locked boolean NOT NULL,
    lockgranted timestamp without time zone,
    lockedby character varying(255)
);


ALTER TABLE public.databasechangeloglock OWNER TO opmonitor_admin;

--
-- Name: hibernate_sequence; Type: SEQUENCE; Schema: public; Owner: opmonitor_admin
--

CREATE SEQUENCE public.hibernate_sequence
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER SEQUENCE public.hibernate_sequence OWNER TO opmonitor_admin;

--
-- Name: operational_data; Type: TABLE; Schema: public; Owner: opmonitor_admin
--

CREATE TABLE public.operational_data (
    id bigint NOT NULL,
    monitoring_data_ts bigint NOT NULL,
    security_server_internal_ip character varying(255) NOT NULL,
    security_server_type character varying(255) NOT NULL,
    request_in_ts bigint NOT NULL,
    request_out_ts bigint,
    response_in_ts bigint,
    response_out_ts bigint NOT NULL,
    client_xroad_instance character varying(255),
    client_member_class character varying(255),
    client_member_code character varying(255),
    client_subsystem_code character varying(255),
    service_xroad_instance character varying(255),
    service_member_class character varying(255),
    service_member_code character varying(255),
    service_subsystem_code character varying(255),
    service_code character varying(255),
    service_version character varying(255),
    message_id character varying(255),
    message_user_id character varying(255),
    message_issue character varying(255),
    message_protocol_version character varying(255),
    client_security_server_address character varying(255),
    service_security_server_address character varying(255),
    request_soap_size bigint,
    request_mime_size bigint,
    request_attachment_count integer,
    response_soap_size bigint,
    response_mime_size bigint,
    response_attachment_count integer,
    succeeded boolean NOT NULL,
    soap_fault_code character varying(255),
    soap_fault_string character varying(2048),
    transaction_id character varying(255),
    request_type character varying(255)
);


ALTER TABLE public.operational_data OWNER TO opmonitor_admin;

--
-- Data for Name: databasechangelog; Type: TABLE DATA; Schema: public; Owner: opmonitor_admin
--

COPY public.databasechangelog (id, author, filename, dateexecuted, orderexecuted, exectype, md5sum, description, comments, tag, liquibase, contexts, labels, deployment_id) FROM stdin;
0-initial	UNKNOWN	op-monitor/0-initial.xml	2025-05-10 15:49:16.124044	1	EXECUTED	9:06483a9739002419f48ca9caf1585328	createSequence sequenceName=hibernate_sequence; createTable tableName=operational_data; addPrimaryKey constraintName=operational_data_pkey, tableName=operational_data; createIndex indexName=idx_monitoring_data_ts, tableName=operational_data		\N	4.29.2	\N	\N	6892156044
1-transaction-id	cyber	op-monitor/1-transaction-id.xml	2025-05-10 15:49:16.136385	2	EXECUTED	9:6b6d1ce777aedd557e076d1e101a3bce	addColumn tableName=operational_data		\N	4.29.2	\N	\N	6892156044
2-request-type	cyber	op-monitor/2-request-type.xml	2025-05-10 15:49:16.143282	3	EXECUTED	9:e934f5db39db96a9b0c5217e43b6c21d	addColumn tableName=operational_data		\N	4.29.2	\N	\N	6892156044
\.


--
-- Data for Name: databasechangeloglock; Type: TABLE DATA; Schema: public; Owner: opmonitor_admin
--

COPY public.databasechangeloglock (id, locked, lockgranted, lockedby) FROM stdin;
1	f	\N	\N
\.


--
-- Data for Name: operational_data; Type: TABLE DATA; Schema: public; Owner: opmonitor_admin
--

COPY public.operational_data (id, monitoring_data_ts, security_server_internal_ip, security_server_type, request_in_ts, request_out_ts, response_in_ts, response_out_ts, client_xroad_instance, client_member_class, client_member_code, client_subsystem_code, service_xroad_instance, service_member_class, service_member_code, service_subsystem_code, service_code, service_version, message_id, message_user_id, message_issue, message_protocol_version, client_security_server_address, service_security_server_address, request_soap_size, request_mime_size, request_attachment_count, response_soap_size, response_mime_size, response_attachment_count, succeeded, soap_fault_code, soap_fault_string, transaction_id, request_type) FROM stdin;
\.


--
-- Name: hibernate_sequence; Type: SEQUENCE SET; Schema: public; Owner: opmonitor_admin
--

SELECT pg_catalog.setval('public.hibernate_sequence', 1, false);


--
-- Name: databasechangeloglock databasechangeloglock_pkey; Type: CONSTRAINT; Schema: public; Owner: opmonitor_admin
--

ALTER TABLE ONLY public.databasechangeloglock
    ADD CONSTRAINT databasechangeloglock_pkey PRIMARY KEY (id);


--
-- Name: operational_data operational_data_pkey; Type: CONSTRAINT; Schema: public; Owner: opmonitor_admin
--

ALTER TABLE ONLY public.operational_data
    ADD CONSTRAINT operational_data_pkey PRIMARY KEY (id);


--
-- Name: idx_monitoring_data_ts; Type: INDEX; Schema: public; Owner: opmonitor_admin
--

CREATE INDEX idx_monitoring_data_ts ON public.operational_data USING btree (monitoring_data_ts);


--
-- Name: SCHEMA public; Type: ACL; Schema: -; Owner: pg_database_owner
--

GRANT USAGE ON SCHEMA public TO opmonitor;


--
-- Name: TABLE databasechangelog; Type: ACL; Schema: public; Owner: opmonitor_admin
--

GRANT SELECT,INSERT,DELETE,UPDATE ON TABLE public.databasechangelog TO opmonitor;


--
-- Name: TABLE databasechangeloglock; Type: ACL; Schema: public; Owner: opmonitor_admin
--

GRANT SELECT,INSERT,DELETE,UPDATE ON TABLE public.databasechangeloglock TO opmonitor;


--
-- Name: SEQUENCE hibernate_sequence; Type: ACL; Schema: public; Owner: opmonitor_admin
--

GRANT ALL ON SEQUENCE public.hibernate_sequence TO opmonitor;


--
-- Name: TABLE operational_data; Type: ACL; Schema: public; Owner: opmonitor_admin
--

GRANT SELECT,INSERT,DELETE,UPDATE ON TABLE public.operational_data TO opmonitor;


--
-- PostgreSQL database dump complete
--

