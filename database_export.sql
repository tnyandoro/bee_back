--
-- PostgreSQL database dump
--

-- Dumped from database version 16.9 (Ubuntu 16.9-0ubuntu0.24.04.1)
-- Dumped by pg_dump version 16.9 (Ubuntu 16.9-0ubuntu0.24.04.1)

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
-- Name: active_storage_attachments; Type: TABLE; Schema: public; Owner: tendai
--

CREATE TABLE public.active_storage_attachments (
    id bigint NOT NULL,
    name character varying NOT NULL,
    record_type character varying NOT NULL,
    record_id bigint NOT NULL,
    blob_id bigint NOT NULL,
    created_at timestamp(6) without time zone NOT NULL
);


ALTER TABLE public.active_storage_attachments OWNER TO tendai;

--
-- Name: active_storage_attachments_id_seq; Type: SEQUENCE; Schema: public; Owner: tendai
--

CREATE SEQUENCE public.active_storage_attachments_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER SEQUENCE public.active_storage_attachments_id_seq OWNER TO tendai;

--
-- Name: active_storage_attachments_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: tendai
--

ALTER SEQUENCE public.active_storage_attachments_id_seq OWNED BY public.active_storage_attachments.id;


--
-- Name: active_storage_blobs; Type: TABLE; Schema: public; Owner: tendai
--

CREATE TABLE public.active_storage_blobs (
    id bigint NOT NULL,
    key character varying NOT NULL,
    filename character varying NOT NULL,
    content_type character varying,
    metadata text,
    service_name character varying NOT NULL,
    byte_size bigint NOT NULL,
    checksum character varying,
    created_at timestamp(6) without time zone NOT NULL
);


ALTER TABLE public.active_storage_blobs OWNER TO tendai;

--
-- Name: active_storage_blobs_id_seq; Type: SEQUENCE; Schema: public; Owner: tendai
--

CREATE SEQUENCE public.active_storage_blobs_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER SEQUENCE public.active_storage_blobs_id_seq OWNER TO tendai;

--
-- Name: active_storage_blobs_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: tendai
--

ALTER SEQUENCE public.active_storage_blobs_id_seq OWNED BY public.active_storage_blobs.id;


--
-- Name: active_storage_variant_records; Type: TABLE; Schema: public; Owner: tendai
--

CREATE TABLE public.active_storage_variant_records (
    id bigint NOT NULL,
    blob_id bigint NOT NULL,
    variation_digest character varying NOT NULL
);


ALTER TABLE public.active_storage_variant_records OWNER TO tendai;

--
-- Name: active_storage_variant_records_id_seq; Type: SEQUENCE; Schema: public; Owner: tendai
--

CREATE SEQUENCE public.active_storage_variant_records_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER SEQUENCE public.active_storage_variant_records_id_seq OWNER TO tendai;

--
-- Name: active_storage_variant_records_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: tendai
--

ALTER SEQUENCE public.active_storage_variant_records_id_seq OWNED BY public.active_storage_variant_records.id;


--
-- Name: ar_internal_metadata; Type: TABLE; Schema: public; Owner: tendai
--

CREATE TABLE public.ar_internal_metadata (
    key character varying NOT NULL,
    value character varying,
    created_at timestamp(6) without time zone NOT NULL,
    updated_at timestamp(6) without time zone NOT NULL
);


ALTER TABLE public.ar_internal_metadata OWNER TO tendai;

--
-- Name: business_hours; Type: TABLE; Schema: public; Owner: tendai
--

CREATE TABLE public.business_hours (
    id bigint NOT NULL,
    organization_id bigint NOT NULL,
    day_of_week integer NOT NULL,
    start_time time without time zone NOT NULL,
    end_time time without time zone NOT NULL,
    created_at timestamp(6) without time zone NOT NULL,
    updated_at timestamp(6) without time zone NOT NULL,
    active boolean DEFAULT true NOT NULL
);


ALTER TABLE public.business_hours OWNER TO tendai;

--
-- Name: business_hours_id_seq; Type: SEQUENCE; Schema: public; Owner: tendai
--

CREATE SEQUENCE public.business_hours_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER SEQUENCE public.business_hours_id_seq OWNER TO tendai;

--
-- Name: business_hours_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: tendai
--

ALTER SEQUENCE public.business_hours_id_seq OWNED BY public.business_hours.id;


--
-- Name: comments; Type: TABLE; Schema: public; Owner: tendai
--

CREATE TABLE public.comments (
    id bigint NOT NULL,
    content character varying,
    user_id bigint NOT NULL,
    ticket_id bigint NOT NULL,
    created_at timestamp(6) without time zone NOT NULL,
    updated_at timestamp(6) without time zone NOT NULL
);


ALTER TABLE public.comments OWNER TO tendai;

--
-- Name: comments_id_seq; Type: SEQUENCE; Schema: public; Owner: tendai
--

CREATE SEQUENCE public.comments_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER SEQUENCE public.comments_id_seq OWNER TO tendai;

--
-- Name: comments_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: tendai
--

ALTER SEQUENCE public.comments_id_seq OWNED BY public.comments.id;


--
-- Name: departments; Type: TABLE; Schema: public; Owner: tendai
--

CREATE TABLE public.departments (
    id bigint NOT NULL,
    name character varying NOT NULL,
    organization_id bigint NOT NULL,
    created_at timestamp(6) without time zone NOT NULL,
    updated_at timestamp(6) without time zone NOT NULL
);


ALTER TABLE public.departments OWNER TO tendai;

--
-- Name: departments_id_seq; Type: SEQUENCE; Schema: public; Owner: tendai
--

CREATE SEQUENCE public.departments_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER SEQUENCE public.departments_id_seq OWNER TO tendai;

--
-- Name: departments_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: tendai
--

ALTER SEQUENCE public.departments_id_seq OWNED BY public.departments.id;


--
-- Name: knowledgebase_entries; Type: TABLE; Schema: public; Owner: tendai
--

CREATE TABLE public.knowledgebase_entries (
    id bigint NOT NULL,
    organization_id bigint NOT NULL,
    issue character varying,
    description text,
    troubleshooting_steps text,
    assigned_group character varying,
    resolution_steps text,
    created_at timestamp(6) without time zone NOT NULL,
    updated_at timestamp(6) without time zone NOT NULL
);


ALTER TABLE public.knowledgebase_entries OWNER TO tendai;

--
-- Name: knowledgebase_entries_id_seq; Type: SEQUENCE; Schema: public; Owner: tendai
--

CREATE SEQUENCE public.knowledgebase_entries_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER SEQUENCE public.knowledgebase_entries_id_seq OWNER TO tendai;

--
-- Name: knowledgebase_entries_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: tendai
--

ALTER SEQUENCE public.knowledgebase_entries_id_seq OWNED BY public.knowledgebase_entries.id;


--
-- Name: notifications; Type: TABLE; Schema: public; Owner: tendai
--

CREATE TABLE public.notifications (
    id bigint NOT NULL,
    user_id bigint NOT NULL,
    organization_id bigint NOT NULL,
    message character varying,
    read boolean DEFAULT false,
    created_at timestamp(6) without time zone NOT NULL,
    updated_at timestamp(6) without time zone NOT NULL,
    notifiable_id bigint,
    notifiable_type character varying
);


ALTER TABLE public.notifications OWNER TO tendai;

--
-- Name: notifications_id_seq; Type: SEQUENCE; Schema: public; Owner: tendai
--

CREATE SEQUENCE public.notifications_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER SEQUENCE public.notifications_id_seq OWNER TO tendai;

--
-- Name: notifications_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: tendai
--

ALTER SEQUENCE public.notifications_id_seq OWNED BY public.notifications.id;


--
-- Name: organizations; Type: TABLE; Schema: public; Owner: tendai
--

CREATE TABLE public.organizations (
    id bigint NOT NULL,
    name character varying,
    address character varying,
    email character varying,
    web_address character varying,
    subdomain character varying,
    phone_number character varying,
    created_at timestamp(6) without time zone NOT NULL,
    updated_at timestamp(6) without time zone NOT NULL,
    logo_url character varying,
    uuid uuid
);


ALTER TABLE public.organizations OWNER TO tendai;

--
-- Name: organizations_id_seq; Type: SEQUENCE; Schema: public; Owner: tendai
--

CREATE SEQUENCE public.organizations_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER SEQUENCE public.organizations_id_seq OWNER TO tendai;

--
-- Name: organizations_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: tendai
--

ALTER SEQUENCE public.organizations_id_seq OWNED BY public.organizations.id;


--
-- Name: problems; Type: TABLE; Schema: public; Owner: tendai
--

CREATE TABLE public.problems (
    id bigint NOT NULL,
    description text,
    ticket_id bigint NOT NULL,
    created_at timestamp(6) without time zone NOT NULL,
    updated_at timestamp(6) without time zone NOT NULL,
    user_id bigint NOT NULL,
    organization_id bigint NOT NULL,
    creator_id integer,
    team_id integer,
    related_incident_id integer
);


ALTER TABLE public.problems OWNER TO tendai;

--
-- Name: problems_id_seq; Type: SEQUENCE; Schema: public; Owner: tendai
--

CREATE SEQUENCE public.problems_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER SEQUENCE public.problems_id_seq OWNER TO tendai;

--
-- Name: problems_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: tendai
--

ALTER SEQUENCE public.problems_id_seq OWNED BY public.problems.id;


--
-- Name: schema_migrations; Type: TABLE; Schema: public; Owner: tendai
--

CREATE TABLE public.schema_migrations (
    version character varying NOT NULL
);


ALTER TABLE public.schema_migrations OWNER TO tendai;

--
-- Name: settings; Type: TABLE; Schema: public; Owner: tendai
--

CREATE TABLE public.settings (
    id bigint NOT NULL,
    organization_id bigint NOT NULL,
    key character varying,
    value jsonb,
    created_at timestamp(6) without time zone NOT NULL,
    updated_at timestamp(6) without time zone NOT NULL
);


ALTER TABLE public.settings OWNER TO tendai;

--
-- Name: settings_id_seq; Type: SEQUENCE; Schema: public; Owner: tendai
--

CREATE SEQUENCE public.settings_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER SEQUENCE public.settings_id_seq OWNER TO tendai;

--
-- Name: settings_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: tendai
--

ALTER SEQUENCE public.settings_id_seq OWNED BY public.settings.id;


--
-- Name: sla_policies; Type: TABLE; Schema: public; Owner: tendai
--

CREATE TABLE public.sla_policies (
    id bigint NOT NULL,
    organization_id bigint NOT NULL,
    priority integer,
    response_time integer,
    resolution_time integer,
    created_at timestamp(6) without time zone NOT NULL,
    updated_at timestamp(6) without time zone NOT NULL,
    description text
);


ALTER TABLE public.sla_policies OWNER TO tendai;

--
-- Name: sla_policies_id_seq; Type: SEQUENCE; Schema: public; Owner: tendai
--

CREATE SEQUENCE public.sla_policies_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER SEQUENCE public.sla_policies_id_seq OWNER TO tendai;

--
-- Name: sla_policies_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: tendai
--

ALTER SEQUENCE public.sla_policies_id_seq OWNED BY public.sla_policies.id;


--
-- Name: teams; Type: TABLE; Schema: public; Owner: tendai
--

CREATE TABLE public.teams (
    id bigint NOT NULL,
    name character varying,
    organization_id bigint NOT NULL,
    created_at timestamp(6) without time zone NOT NULL,
    updated_at timestamp(6) without time zone NOT NULL,
    deactivated_at timestamp(6) without time zone
);


ALTER TABLE public.teams OWNER TO tendai;

--
-- Name: teams_id_seq; Type: SEQUENCE; Schema: public; Owner: tendai
--

CREATE SEQUENCE public.teams_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER SEQUENCE public.teams_id_seq OWNER TO tendai;

--
-- Name: teams_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: tendai
--

ALTER SEQUENCE public.teams_id_seq OWNED BY public.teams.id;


--
-- Name: tickets; Type: TABLE; Schema: public; Owner: tendai
--

CREATE TABLE public.tickets (
    id bigint NOT NULL,
    title character varying,
    description text,
    priority integer,
    organization_id bigint NOT NULL,
    created_at timestamp(6) without time zone NOT NULL,
    updated_at timestamp(6) without time zone NOT NULL,
    ticket_number character varying NOT NULL,
    ticket_type character varying NOT NULL,
    assignee_id bigint,
    team_id bigint NOT NULL,
    requester_id bigint,
    reported_at timestamp(6) without time zone NOT NULL,
    category character varying NOT NULL,
    caller_name character varying NOT NULL,
    caller_surname character varying NOT NULL,
    caller_email character varying NOT NULL,
    caller_phone character varying NOT NULL,
    customer character varying NOT NULL,
    source character varying NOT NULL,
    status integer DEFAULT 6 NOT NULL,
    creator_id bigint,
    response_due_at timestamp(6) without time zone,
    resolution_due_at timestamp(6) without time zone,
    escalation_level integer DEFAULT 0,
    sla_breached boolean DEFAULT false,
    sla_policy_id bigint,
    urgency integer DEFAULT 0 NOT NULL,
    impact integer DEFAULT 0 NOT NULL,
    calculated_priority integer,
    resolved_at timestamp(6) without time zone,
    resolution_note text,
    user_id bigint,
    some_field character varying,
    reason character varying,
    resolution_method character varying,
    cause_code character varying,
    resolution_details text,
    end_customer character varying,
    support_center character varying,
    total_kilometer character varying,
    department_id bigint,
    breaching_sla boolean DEFAULT false
);


ALTER TABLE public.tickets OWNER TO tendai;

--
-- Name: tickets_id_seq; Type: SEQUENCE; Schema: public; Owner: tendai
--

CREATE SEQUENCE public.tickets_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER SEQUENCE public.tickets_id_seq OWNER TO tendai;

--
-- Name: tickets_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: tendai
--

ALTER SEQUENCE public.tickets_id_seq OWNED BY public.tickets.id;


--
-- Name: tickets_inc_organization_1_seq; Type: SEQUENCE; Schema: public; Owner: tendai
--

CREATE SEQUENCE public.tickets_inc_organization_1_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER SEQUENCE public.tickets_inc_organization_1_seq OWNER TO tendai;

--
-- Name: tickets_inc_organization_2_seq; Type: SEQUENCE; Schema: public; Owner: tendai
--

CREATE SEQUENCE public.tickets_inc_organization_2_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER SEQUENCE public.tickets_inc_organization_2_seq OWNER TO tendai;

--
-- Name: tickets_prb_organization_1_seq; Type: SEQUENCE; Schema: public; Owner: tendai
--

CREATE SEQUENCE public.tickets_prb_organization_1_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER SEQUENCE public.tickets_prb_organization_1_seq OWNER TO tendai;

--
-- Name: tickets_prb_organization_2_seq; Type: SEQUENCE; Schema: public; Owner: tendai
--

CREATE SEQUENCE public.tickets_prb_organization_2_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER SEQUENCE public.tickets_prb_organization_2_seq OWNER TO tendai;

--
-- Name: tickets_req_organization_1_seq; Type: SEQUENCE; Schema: public; Owner: tendai
--

CREATE SEQUENCE public.tickets_req_organization_1_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER SEQUENCE public.tickets_req_organization_1_seq OWNER TO tendai;

--
-- Name: tickets_req_organization_2_seq; Type: SEQUENCE; Schema: public; Owner: tendai
--

CREATE SEQUENCE public.tickets_req_organization_2_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER SEQUENCE public.tickets_req_organization_2_seq OWNER TO tendai;

--
-- Name: users; Type: TABLE; Schema: public; Owner: tendai
--

CREATE TABLE public.users (
    id bigint NOT NULL,
    name character varying NOT NULL,
    email character varying NOT NULL,
    password_digest character varying,
    role integer DEFAULT 0 NOT NULL,
    organization_id bigint NOT NULL,
    created_at timestamp(6) without time zone NOT NULL,
    updated_at timestamp(6) without time zone NOT NULL,
    "position" character varying,
    team_id bigint,
    auth_token character varying,
    username character varying NOT NULL,
    phone_number character varying,
    receive_email_notifications boolean DEFAULT true NOT NULL,
    reset_password_sent_at timestamp(6) without time zone,
    department_id bigint,
    reset_password_token character varying(64),
    new_reset_password_token character varying(128),
    last_name character varying,
    refresh_token character varying,
    refresh_token_expires_at timestamp(6) without time zone,
    uuid uuid,
    token_expires_at timestamp(6) without time zone
);


ALTER TABLE public.users OWNER TO tendai;

--
-- Name: users_id_seq; Type: SEQUENCE; Schema: public; Owner: tendai
--

CREATE SEQUENCE public.users_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER SEQUENCE public.users_id_seq OWNER TO tendai;

--
-- Name: users_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: tendai
--

ALTER SEQUENCE public.users_id_seq OWNED BY public.users.id;


--
-- Name: versions; Type: TABLE; Schema: public; Owner: tendai
--

CREATE TABLE public.versions (
    id bigint NOT NULL,
    whodunnit character varying,
    created_at timestamp(6) without time zone,
    item_id bigint NOT NULL,
    item_type character varying NOT NULL,
    event character varying NOT NULL,
    object text
);


ALTER TABLE public.versions OWNER TO tendai;

--
-- Name: versions_id_seq; Type: SEQUENCE; Schema: public; Owner: tendai
--

CREATE SEQUENCE public.versions_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER SEQUENCE public.versions_id_seq OWNER TO tendai;

--
-- Name: versions_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: tendai
--

ALTER SEQUENCE public.versions_id_seq OWNED BY public.versions.id;


--
-- Name: active_storage_attachments id; Type: DEFAULT; Schema: public; Owner: tendai
--

ALTER TABLE ONLY public.active_storage_attachments ALTER COLUMN id SET DEFAULT nextval('public.active_storage_attachments_id_seq'::regclass);


--
-- Name: active_storage_blobs id; Type: DEFAULT; Schema: public; Owner: tendai
--

ALTER TABLE ONLY public.active_storage_blobs ALTER COLUMN id SET DEFAULT nextval('public.active_storage_blobs_id_seq'::regclass);


--
-- Name: active_storage_variant_records id; Type: DEFAULT; Schema: public; Owner: tendai
--

ALTER TABLE ONLY public.active_storage_variant_records ALTER COLUMN id SET DEFAULT nextval('public.active_storage_variant_records_id_seq'::regclass);


--
-- Name: business_hours id; Type: DEFAULT; Schema: public; Owner: tendai
--

ALTER TABLE ONLY public.business_hours ALTER COLUMN id SET DEFAULT nextval('public.business_hours_id_seq'::regclass);


--
-- Name: comments id; Type: DEFAULT; Schema: public; Owner: tendai
--

ALTER TABLE ONLY public.comments ALTER COLUMN id SET DEFAULT nextval('public.comments_id_seq'::regclass);


--
-- Name: departments id; Type: DEFAULT; Schema: public; Owner: tendai
--

ALTER TABLE ONLY public.departments ALTER COLUMN id SET DEFAULT nextval('public.departments_id_seq'::regclass);


--
-- Name: knowledgebase_entries id; Type: DEFAULT; Schema: public; Owner: tendai
--

ALTER TABLE ONLY public.knowledgebase_entries ALTER COLUMN id SET DEFAULT nextval('public.knowledgebase_entries_id_seq'::regclass);


--
-- Name: notifications id; Type: DEFAULT; Schema: public; Owner: tendai
--

ALTER TABLE ONLY public.notifications ALTER COLUMN id SET DEFAULT nextval('public.notifications_id_seq'::regclass);


--
-- Name: organizations id; Type: DEFAULT; Schema: public; Owner: tendai
--

ALTER TABLE ONLY public.organizations ALTER COLUMN id SET DEFAULT nextval('public.organizations_id_seq'::regclass);


--
-- Name: problems id; Type: DEFAULT; Schema: public; Owner: tendai
--

ALTER TABLE ONLY public.problems ALTER COLUMN id SET DEFAULT nextval('public.problems_id_seq'::regclass);


--
-- Name: settings id; Type: DEFAULT; Schema: public; Owner: tendai
--

ALTER TABLE ONLY public.settings ALTER COLUMN id SET DEFAULT nextval('public.settings_id_seq'::regclass);


--
-- Name: sla_policies id; Type: DEFAULT; Schema: public; Owner: tendai
--

ALTER TABLE ONLY public.sla_policies ALTER COLUMN id SET DEFAULT nextval('public.sla_policies_id_seq'::regclass);


--
-- Name: teams id; Type: DEFAULT; Schema: public; Owner: tendai
--

ALTER TABLE ONLY public.teams ALTER COLUMN id SET DEFAULT nextval('public.teams_id_seq'::regclass);


--
-- Name: tickets id; Type: DEFAULT; Schema: public; Owner: tendai
--

ALTER TABLE ONLY public.tickets ALTER COLUMN id SET DEFAULT nextval('public.tickets_id_seq'::regclass);


--
-- Name: users id; Type: DEFAULT; Schema: public; Owner: tendai
--

ALTER TABLE ONLY public.users ALTER COLUMN id SET DEFAULT nextval('public.users_id_seq'::regclass);


--
-- Name: versions id; Type: DEFAULT; Schema: public; Owner: tendai
--

ALTER TABLE ONLY public.versions ALTER COLUMN id SET DEFAULT nextval('public.versions_id_seq'::regclass);


--
-- Data for Name: active_storage_attachments; Type: TABLE DATA; Schema: public; Owner: tendai
--

COPY public.active_storage_attachments (id, name, record_type, record_id, blob_id, created_at) FROM stdin;
2	attachment	Ticket	43	2	2025-08-30 08:29:40.114579
4	attachment	Ticket	44	4	2025-08-30 11:18:03.482734
6	attachment	Ticket	45	6	2025-08-30 12:55:16.032434
8	attachment	Ticket	46	8	2025-08-30 13:03:42.631416
10	attachment	Ticket	47	10	2025-08-30 13:15:22.802053
12	attachment	Ticket	48	12	2025-08-30 13:24:31.136158
13	attachment	Ticket	49	13	2025-08-30 14:03:55.733311
14	attachment	Ticket	50	14	2025-08-30 14:11:08.308866
16	attachment	Ticket	51	16	2025-08-30 14:26:18.160098
18	attachment	Ticket	52	18	2025-08-30 14:50:04.072709
20	attachment	Ticket	53	20	2025-08-31 09:14:10.837368
22	attachment	Ticket	54	22	2025-08-31 11:48:45.913898
\.


--
-- Data for Name: active_storage_blobs; Type: TABLE DATA; Schema: public; Owner: tendai
--

COPY public.active_storage_blobs (id, key, filename, content_type, metadata, service_name, byte_size, checksum, created_at) FROM stdin;
2	x922wyzmhhhhozu6p98flpq639yq	test_pdf.pdf	application/pdf	{"identified":true,"analyzed":true}	development	30205	whmtRR+PouEeHuzcI8sUYA==	2025-08-30 08:29:40.10687
4	h73ph28tgc47esmtqz424ir07ek1	test_pdf.pdf	application/pdf	{"identified":true,"analyzed":true}	development	30205	whmtRR+PouEeHuzcI8sUYA==	2025-08-30 11:18:03.477521
6	nl87dh9fqrl424hkjfzte5g2j7ul	test_pdf.pdf	application/pdf	{"identified":true,"analyzed":true}	development	30205	whmtRR+PouEeHuzcI8sUYA==	2025-08-30 12:55:16.024186
22	g2qhuus1be7uu5lx1ed4rq7urvcy	test.pdf	application/pdf	{"identified":true,"analyzed":true}	development	30205	whmtRR+PouEeHuzcI8sUYA==	2025-08-31 11:48:45.869495
8	sefsuvqhxdr60pijdyodd7n4eqsp	test_pdf.pdf	application/pdf	{"identified":true,"analyzed":true}	development	30205	whmtRR+PouEeHuzcI8sUYA==	2025-08-30 13:03:42.621842
10	4y9okeqq2udwgcby5n4vuglu1ehe	test_pdf.pdf	application/pdf	{"identified":true,"analyzed":true}	development	30205	whmtRR+PouEeHuzcI8sUYA==	2025-08-30 13:15:22.792272
12	xmbykplb8uirnitxeedsjq1btxfk	test_pdf.pdf	application/pdf	{"identified":true,"analyzed":true}	development	30205	whmtRR+PouEeHuzcI8sUYA==	2025-08-30 13:24:31.130222
13	bx8ei7kd4cfw3c5vykukapem7mb8	test_pdf.pdf	application/pdf	{"identified":true,"analyzed":true}	development	30205	whmtRR+PouEeHuzcI8sUYA==	2025-08-30 14:03:55.724723
14	jxaef38juh63h6sc0cfyuc8u2ggq	test_pdf.pdf	application/pdf	{"identified":true,"analyzed":true}	development	30205	whmtRR+PouEeHuzcI8sUYA==	2025-08-30 14:11:08.302433
16	4ip5g0hlfuz47dfaoybtdxczyi37	test_pdf.pdf	application/pdf	{"identified":true,"analyzed":true}	development	30205	whmtRR+PouEeHuzcI8sUYA==	2025-08-30 14:26:18.15134
18	tz1p9snngrpxzntlyivh2qqgnsgq	test_pdf.pdf	application/pdf	{"identified":true,"analyzed":true}	development	30205	whmtRR+PouEeHuzcI8sUYA==	2025-08-30 14:50:04.067719
20	4joeh1jqbm0dqh7prs47ao3rbmp0	test.pdf	application/pdf	{"identified":true,"analyzed":true}	development	30205	whmtRR+PouEeHuzcI8sUYA==	2025-08-31 09:14:10.831955
\.


--
-- Data for Name: active_storage_variant_records; Type: TABLE DATA; Schema: public; Owner: tendai
--

COPY public.active_storage_variant_records (id, blob_id, variation_digest) FROM stdin;
\.


--
-- Data for Name: ar_internal_metadata; Type: TABLE DATA; Schema: public; Owner: tendai
--

COPY public.ar_internal_metadata (key, value, created_at, updated_at) FROM stdin;
environment	development	2025-07-25 10:52:52.436379	2025-07-25 10:52:52.436384
schema_sha1	e02ec8a0236a15e0b183bdf1a2d14dcbb62056de	2025-07-25 10:52:52.459037	2025-07-25 10:52:52.45904
\.


--
-- Data for Name: business_hours; Type: TABLE DATA; Schema: public; Owner: tendai
--

COPY public.business_hours (id, organization_id, day_of_week, start_time, end_time, created_at, updated_at, active) FROM stdin;
1	2	1	06:00:00	15:00:00	2025-08-28 20:26:17.446553	2025-08-28 20:26:17.446553	t
2	2	2	06:00:00	15:00:00	2025-08-28 20:26:17.468479	2025-08-28 20:26:17.468479	t
3	2	3	06:00:00	15:00:00	2025-08-28 20:26:17.481476	2025-08-28 20:26:17.481476	t
4	2	4	06:00:00	15:00:00	2025-08-28 20:26:17.494245	2025-08-28 20:26:17.494245	t
5	2	5	06:00:00	15:00:00	2025-08-28 20:26:17.505725	2025-08-28 20:26:17.505725	t
\.


--
-- Data for Name: comments; Type: TABLE DATA; Schema: public; Owner: tendai
--

COPY public.comments (id, content, user_id, ticket_id, created_at, updated_at) FROM stdin;
33	Ticket created by Tendai	10	34	2025-08-29 10:30:23.900012	2025-08-29 10:30:23.900012
34	Ticket created by Tendai	10	35	2025-08-29 10:44:03.008281	2025-08-29 10:44:03.008281
35	Ticket created by Tendai	10	36	2025-08-29 10:51:08.825028	2025-08-29 10:51:08.825028
36	Ticket created by Vibha	7	37	2025-08-29 11:17:16.585177	2025-08-29 11:17:16.585177
37	Ticket created by Vibha	7	38	2025-08-29 11:28:52.094963	2025-08-29 11:28:52.094963
38	Ticket created by Vibha	7	39	2025-08-29 11:36:10.889967	2025-08-29 11:36:10.889967
39	Ticket created by Tendai	10	40	2025-08-29 15:38:11.43827	2025-08-29 15:38:11.43827
40	Ticket created by Tendai	10	41	2025-08-29 15:41:07.38588	2025-08-29 15:41:07.38588
41	Ticket resolved: Its sorted	4	40	2025-08-29 15:43:11.787837	2025-08-29 15:43:11.787837
42	Ticket created by Tendai	10	42	2025-08-30 06:42:11.329545	2025-08-30 06:42:11.329545
43	Ticket resolved: Resolved 	4	42	2025-08-30 06:43:37.334353	2025-08-30 06:43:37.334353
44	Ticket created by Tendai	10	43	2025-08-30 08:29:41.616267	2025-08-30 08:29:41.616267
45	Ticket created by Tendai	10	44	2025-08-30 11:18:04.356359	2025-08-30 11:18:04.356359
46	Ticket has been assigned but its showing unassigned which is wrong	10	44	2025-08-30 12:31:18.571126	2025-08-30 12:31:18.571126
47	Ticket created by Tendai	10	45	2025-08-30 12:55:16.762056	2025-08-30 12:55:16.762056
48	Ticket created by Tendai	10	46	2025-08-30 13:03:43.379089	2025-08-30 13:03:43.379089
49	Ticket created by Tendai	10	47	2025-08-30 13:15:23.444444	2025-08-30 13:15:23.444444
50	Ticket created by Tendai	10	48	2025-08-30 13:24:31.70017	2025-08-30 13:24:31.70017
51	Ticket created by Tendai	10	51	2025-08-30 14:26:18.791532	2025-08-30 14:26:18.791532
52	Ticket created by Tendai	10	52	2025-08-30 14:50:05.414179	2025-08-30 14:50:05.414179
53	Ticket created by Tendai	10	53	2025-08-31 09:14:11.813723	2025-08-31 09:14:11.813723
54	Ticket created by Tendai	10	54	2025-08-31 11:48:46.613508	2025-08-31 11:48:46.613508
\.


--
-- Data for Name: departments; Type: TABLE DATA; Schema: public; Owner: tendai
--

COPY public.departments (id, name, organization_id, created_at, updated_at) FROM stdin;
\.


--
-- Data for Name: knowledgebase_entries; Type: TABLE DATA; Schema: public; Owner: tendai
--

COPY public.knowledgebase_entries (id, organization_id, issue, description, troubleshooting_steps, assigned_group, resolution_steps, created_at, updated_at) FROM stdin;
\.


--
-- Data for Name: notifications; Type: TABLE DATA; Schema: public; Owner: tendai
--

COPY public.notifications (id, user_id, organization_id, message, read, created_at, updated_at, notifiable_id, notifiable_type) FROM stdin;
54	10	2	New ticket created: We can create tickets and send mail (INCQXBFGI5P)	f	2025-08-29 10:30:23.975383	2025-08-29 10:30:23.975383	34	Ticket
55	7	2	You have been assigned a new ticket: We can create tickets and send mail (INCQXBFGI5P)	f	2025-08-29 10:30:24.544052	2025-08-29 10:30:24.544052	34	Ticket
56	10	2	New ticket created: Admin assigning tickets (INCOYXYKTCW)	f	2025-08-29 10:44:03.125354	2025-08-29 10:44:03.125354	35	Ticket
57	12	2	You have been assigned a new ticket: Admin assigning tickets (INCOYXYKTCW)	f	2025-08-29 10:44:03.457613	2025-08-29 10:44:03.457613	35	Ticket
58	10	2	New ticket created: Tracking Tickets (INCUUSVC0Z0)	f	2025-08-29 10:51:08.919057	2025-08-29 10:51:08.919057	36	Ticket
59	12	2	You have been assigned a new ticket: Tracking Tickets (INCUUSVC0Z0)	f	2025-08-29 10:51:09.416503	2025-08-29 10:51:09.416503	36	Ticket
60	7	2	New ticket created: Testing tickets (INCEUOP0O5W)	f	2025-08-29 11:17:16.650911	2025-08-29 11:17:16.650911	37	Ticket
61	10	2	You have been assigned a new ticket: Testing tickets (INCEUOP0O5W)	f	2025-08-29 11:17:17.213479	2025-08-29 11:17:17.213479	37	Ticket
62	7	2	New ticket created: OTP is Failing (INC14TNK8LI)	f	2025-08-29 11:28:52.150511	2025-08-29 11:28:52.150511	38	Ticket
63	5	2	You have been assigned a new ticket: OTP is Failing (INC14TNK8LI)	f	2025-08-29 11:28:52.21448	2025-08-29 11:28:52.21448	38	Ticket
64	7	2	New ticket created: Admin assigning tickets (INCSDNKMX0N)	f	2025-08-29 11:36:10.913204	2025-08-29 11:36:10.913204	39	Ticket
65	11	2	You have been assigned a new ticket: Admin assigning tickets (INCSDNKMX0N)	f	2025-08-29 11:36:10.983188	2025-08-29 11:36:10.983188	39	Ticket
66	10	2	New ticket created: I need some help (INCZYC673PV)	f	2025-08-29 15:38:11.593394	2025-08-29 15:38:11.593394	40	Ticket
67	4	2	You have been assigned a new ticket: I need some help (INCZYC673PV)	f	2025-08-29 15:38:12.965021	2025-08-29 15:38:12.965021	40	Ticket
68	10	2	New ticket created: Ticket without an assignee (INCL75KA45P)	f	2025-08-29 15:41:07.414601	2025-08-29 15:41:07.414601	41	Ticket
69	10	2	New ticket created: Soft Deletions (INCXR7T8KWC)	f	2025-08-30 06:42:11.726736	2025-08-30 06:42:11.726736	42	Ticket
70	10	2	You have been assigned a new ticket: Soft Deletions (INCXR7T8KWC)	f	2025-08-30 06:42:12.919289	2025-08-30 06:42:12.919289	42	Ticket
71	10	2	New ticket created: Adding an attachment (INCJMBZCQBP)	f	2025-08-30 08:29:41.794747	2025-08-30 08:29:41.794747	43	Ticket
72	10	2	New ticket created: Testing more attachments (INCOV4RFU4M)	f	2025-08-30 11:18:04.69334	2025-08-30 11:18:04.69334	44	Ticket
73	10	2	You have been assigned a new ticket: Testing more attachments (INCOV4RFU4M)	f	2025-08-30 11:18:04.829726	2025-08-30 11:18:04.829726	44	Ticket
74	10	2	New ticket created: Attaching a pdf  (INC9OOEJ4RV)	f	2025-08-30 12:55:17.082283	2025-08-30 12:55:17.082283	45	Ticket
75	10	2	You have been assigned a new ticket: Attaching a pdf  (INC9OOEJ4RV)	f	2025-08-30 12:55:17.204925	2025-08-30 12:55:17.204925	45	Ticket
76	10	2	New ticket created: add attachments to ticket (INCGEK7K5K2)	f	2025-08-30 13:03:43.729316	2025-08-30 13:03:43.729316	46	Ticket
77	10	2	You have been assigned a new ticket: add attachments to ticket (INCGEK7K5K2)	f	2025-08-30 13:03:43.91661	2025-08-30 13:03:43.91661	46	Ticket
78	10	2	New ticket created: Attaching a pdf to a ticket (INCHK3YOCO5)	f	2025-08-30 13:15:23.634907	2025-08-30 13:15:23.634907	47	Ticket
79	10	2	You have been assigned a new ticket: Attaching a pdf to a ticket (INCHK3YOCO5)	f	2025-08-30 13:15:23.7881	2025-08-30 13:15:23.7881	47	Ticket
80	10	2	New ticket created: Attachments pdf (INCQ7CPHL1J)	f	2025-08-30 13:24:32.010441	2025-08-30 13:24:32.010441	48	Ticket
81	10	2	You have been assigned a new ticket: Attachments pdf (INCQ7CPHL1J)	f	2025-08-30 13:24:32.188515	2025-08-30 13:24:32.188515	48	Ticket
82	10	2	New ticket created: creating a ticket with an attachment (INCSUM5F4E0)	f	2025-08-30 14:26:19.099582	2025-08-30 14:26:19.099582	51	Ticket
83	4	2	You have been assigned a new ticket: creating a ticket with an attachment (INCSUM5F4E0)	f	2025-08-30 14:26:19.255179	2025-08-30 14:26:19.255179	51	Ticket
84	10	2	New ticket created: test ticket numbering  (INC0001)	f	2025-08-30 14:50:05.503537	2025-08-30 14:50:05.503537	52	Ticket
85	4	2	You have been assigned a new ticket: test ticket numbering  (INC0001)	f	2025-08-30 14:50:05.563699	2025-08-30 14:50:05.563699	52	Ticket
86	10	2	New ticket created: Fixing proper numbering (INC0002)	f	2025-08-31 09:14:12.42589	2025-08-31 09:14:12.42589	53	Ticket
87	10	2	You have been assigned a new ticket: Fixing proper numbering (INC0002)	f	2025-08-31 09:14:12.597113	2025-08-31 09:14:12.597113	53	Ticket
88	10	2	New ticket created: Changing categories (CIPC_INC0001)	f	2025-08-31 11:48:47.155169	2025-08-31 11:48:47.155169	54	Ticket
89	10	2	You have been assigned a new ticket: Changing categories (CIPC_INC0001)	f	2025-08-31 11:48:47.334986	2025-08-31 11:48:47.334986	54	Ticket
\.


--
-- Data for Name: organizations; Type: TABLE DATA; Schema: public; Owner: tendai
--

COPY public.organizations (id, name, address, email, web_address, subdomain, phone_number, created_at, updated_at, logo_url, uuid) FROM stdin;
1	GreenSoft Solutions	123 Tech Lane, Innovation City	contact@greensoft.com	https://greensoft.com	greensoft-solutions	555-123-4567	2025-07-25 10:52:53.772264	2025-07-25 10:52:53.772264	\N	\N
2	bluesoft	13 Pineview estate	tendai@bluesoft.com	www.bluesoft.co.za	bluesoft	0110192653	2025-07-25 11:01:12.961507	2025-07-25 11:01:12.961507	\N	\N
\.


--
-- Data for Name: problems; Type: TABLE DATA; Schema: public; Owner: tendai
--

COPY public.problems (id, description, ticket_id, created_at, updated_at, user_id, organization_id, creator_id, team_id, related_incident_id) FROM stdin;
\.


--
-- Data for Name: schema_migrations; Type: TABLE DATA; Schema: public; Owner: tendai
--

COPY public.schema_migrations (version) FROM stdin;
20250705094926
20250704153515
20250701052630
20250630100148
20250619122026
20250617105143
20250613093408
20250613062441
20250613055052
20250613053903
20250613053451
20250613053249
20250613051239
20250612134713
20250612132653
20250612132528
20250612100112
20250612075222
20250612072752
20250524141902
20250515084250
20250514105819
20250514104625
20250514103843
20250514101403
20250512125147
20250510215624
20250509053918
20250509010101
20250508101031
20250501100455
20250501095528
20250430082504
20250325190223
20250318131803
20250731175927
20250804050339
20250814050450
20250816105144
20250818081651
20250818081724
20250818201245
20250828201507
20250830055739
\.


--
-- Data for Name: settings; Type: TABLE DATA; Schema: public; Owner: tendai
--

COPY public.settings (id, organization_id, key, value, created_at, updated_at) FROM stdin;
\.


--
-- Data for Name: sla_policies; Type: TABLE DATA; Schema: public; Owner: tendai
--

COPY public.sla_policies (id, organization_id, priority, response_time, resolution_time, created_at, updated_at, description) FROM stdin;
1	2	3	120	240	2025-08-28 20:26:17.638251	2025-08-28 20:26:17.638251	Critical priority tickets - 2 hour response SLA
2	2	2	240	480	2025-08-28 20:26:17.651107	2025-08-28 20:26:17.651107	High priority tickets
3	2	1	480	1440	2025-08-28 20:26:17.66053	2025-08-28 20:26:17.66053	Medium priority tickets
4	2	0	1440	4320	2025-08-28 20:26:17.66981	2025-08-28 20:26:17.66981	Low priority tickets
\.


--
-- Data for Name: teams; Type: TABLE DATA; Schema: public; Owner: tendai
--

COPY public.teams (id, name, organization_id, created_at, updated_at, deactivated_at) FROM stdin;
4	Align	2	2025-08-28 08:27:02.293491	2025-08-28 08:27:02.293491	\N
5	QuickDraw	2	2025-08-29 10:00:49.055802	2025-08-29 10:00:49.055802	\N
6	Trackers	2	2025-08-29 10:42:51.153044	2025-08-29 10:42:51.153044	\N
\.


--
-- Data for Name: tickets; Type: TABLE DATA; Schema: public; Owner: tendai
--

COPY public.tickets (id, title, description, priority, organization_id, created_at, updated_at, ticket_number, ticket_type, assignee_id, team_id, requester_id, reported_at, category, caller_name, caller_surname, caller_email, caller_phone, customer, source, status, creator_id, response_due_at, resolution_due_at, escalation_level, sla_breached, sla_policy_id, urgency, impact, calculated_priority, resolved_at, resolution_note, user_id, some_field, reason, resolution_method, cause_code, resolution_details, end_customer, support_center, total_kilometer, department_id, breaching_sla) FROM stdin;
34	We can create tickets and send mail	We can create tickets and send a notification to the assignee	3	2	2025-08-29 10:30:23.14373	2025-08-29 10:30:23.725887	INCQXBFGI5P	Incident	7	4	10	2025-08-29 10:29:00	Technical	Tendai	Mike	tendain@greensoftsolutions.net	0742591362	GSS	Web	1	10	2025-09-03 07:29:00	2025-09-10 10:29:00	0	f	4	2	2	3	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	f
35	Admin assigning tickets	Testing our ticket creation	3	2	2025-08-29 10:44:02.241659	2025-08-29 10:44:02.797455	INCOYXYKTCW	Incident	12	6	10	2025-08-29 10:43:00	Technical	Tendai	Monroe	tendain@greensoftsolutions.net	0742591362	GSS	Web	1	10	2025-09-03 07:43:00	2025-09-10 10:43:00	0	f	4	2	2	3	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	f
36	Tracking Tickets	We want to see if all can see the tickets 	3	2	2025-08-29 10:51:07.861615	2025-08-29 10:51:08.535867	INCUUSVC0Z0	Incident	12	6	10	2025-08-29 10:50:00	Technical	Tendai	Muttom	tendain@greensoftsolutions.net	0742591362	Mpumalanga	Web	1	10	2025-09-03 07:50:00	2025-09-10 10:50:00	0	f	4	2	2	3	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	f
37	Testing tickets	test test test 	1	2	2025-08-29 11:17:15.932333	2025-08-29 11:17:16.377451	INCEUOP0O5W	Incident	10	6	7	2025-08-29 11:16:00	Technical	Vibha	m	vibham@greensoftsolutions.net	0100355568	Johannesburg	Web	1	7	2025-09-03 08:16:00	2025-09-10 11:16:00	0	f	4	1	1	1	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	f
38	OTP is Failing	We are unable to receive my opt when trying to update my company registration	3	2	2025-08-29 11:28:51.449202	2025-08-29 11:28:51.804044	INC14TNK8LI	Incident	5	6	7	2025-08-29 11:25:00	Technical	Trudie	mk	vibham@greensoftsolutions.net	0100355568	GSS HQ	Web	1	7	2025-09-03 08:25:00	2025-09-10 11:25:00	0	f	4	2	2	3	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	f
39	Admin assigning tickets	My Login details are not working 	1	2	2025-08-29 11:36:10.44791	2025-08-29 11:36:10.675159	INCSDNKMX0N	Incident	11	6	7	2025-08-29 11:33:00	Technical	Dilip	Monroe	rajava.manoja@gmail.com	0100355568	GSS	Web	1	7	2025-09-03 08:33:00	2025-09-10 11:33:00	0	f	4	1	1	1	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	f
41	Ticket without an assignee	We want to reassign this ticket	1	2	2025-08-29 15:41:06.956722	2025-08-29 15:41:07.180871	INCL75KA45P	Incident	\N	4	10	2025-08-29 15:39:00	Technical	Tendai	Monroe	tendain@greensoftsolutions.net	0742591362	Gss	Web	0	10	2025-09-03 12:00:00	2025-09-10 15:00:00	0	f	4	1	1	1	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	f
40	I need some help	We need help with registering our intellectual property	3	2	2025-08-29 15:38:09.444063	2025-08-29 15:43:11.767585	INCZYC673PV	Incident	4	6	10	2025-08-29 15:33:00	Technical	Bob	Uncle	bobuncle@example.com	0742591362	GSShq	Web	5	10	2025-09-03 12:00:00	2025-09-10 15:00:00	0	f	4	2	2	3	2025-08-29 15:43:11.734349	Its sorted	\N	\N	Its sorted	web	0000	Its sorted	Juliet			\N	f
42	Soft Deletions	Lets fix deletion for teams 	3	2	2025-08-30 06:42:09.388244	2025-08-30 06:43:37.305445	INCXR7T8KWC	Incident	10	6	10	2025-08-30 06:40:00	Technical	Tendai	Dohwe	tendain@greensoftsolutions.net	0742591362	HQGSS	Web	5	10	2025-09-03 12:00:00	2025-09-10 15:00:00	0	f	4	2	2	3	2025-08-30 06:43:37.257616	Resolved 	\N	\N	0000	web	0000	Resolved 	Juliet			\N	f
49	Attachment PDF 3	We are testing to see if we can attach a pdf to a created ticket	3	2	2025-08-30 14:03:55.250951	2025-08-30 14:03:55.92368	INCV9GUPCOA	Incident	10	6	10	2025-08-30 14:00:00	Other	Tendai	Tindo	tendain@greensoftsolutions.net	0742591362	Juskskei	Web	1	10	2025-09-03 12:00:00	2025-09-10 15:00:00	0	f	4	2	2	3	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	f
45	Attaching a pdf 	We are testing to see if we can attach a pdf to a created ticket	1	2	2025-08-30 12:55:14.868416	2025-08-30 12:55:16.228725	INC9OOEJ4RV	Incident	10	6	10	2025-08-30 12:53:00	Technical	Sharmaine	Dillian	tendain@greensoftsolutions.net	0742591362	Midrand	Web	1	10	2025-09-03 12:00:00	2025-09-10 15:00:00	0	f	4	1	1	1	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	f
43	Adding an attachment	We need to test an attachment	2	2	2025-08-30 08:29:38.351232	2025-08-30 08:29:41.230205	INCJMBZCQBP	Incident	\N	6	10	2025-08-30 08:23:00	Technical	Test	Tendai	tendain@greensoftsolutions.net	0742591362	Midrand	Web	0	10	2025-09-03 12:00:00	2025-09-10 15:00:00	0	f	4	1	2	2	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	f
44	Testing more attachments	Let test the attachments	3	2	2025-08-30 11:18:02.332823	2025-08-30 11:18:03.726323	INCOV4RFU4M	Incident	10	6	10	2025-08-30 11:16:00	Other	Courtney	Gabriella	tendain@greensoftsolutions.net	0742591362	GSS hed	Web	1	10	2025-09-03 12:00:00	2025-09-10 15:00:00	0	f	4	2	2	3	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	f
48	Attachments pdf	Reference site about Lorem Ipsum, giving information on its origins, as well as a random Lipsum generator.	3	2	2025-08-30 13:24:30.161317	2025-08-30 13:24:31.290286	INCQ7CPHL1J	Incident	10	6	10	2025-08-30 13:23:00	Technical	Denzel	Kairo	tendain@greensoftsolutions.net	0742591362	Johannesburg	Web	1	10	2025-09-03 12:00:00	2025-09-10 15:00:00	0	f	4	2	2	3	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	f
46	add attachments to ticket	Let test the attachments	3	2	2025-08-30 13:03:41.358819	2025-08-30 13:03:42.79222	INCGEK7K5K2	Incident	10	6	10	2025-08-30 13:02:00	Technical	Sharon	Saymore	tendain@greensoftsolutions.net	0742591362	GSS hed	Web	1	10	2025-09-03 12:00:00	2025-09-10 15:00:00	0	f	4	2	2	3	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	f
51	creating a ticket with an attachment	We need to create a ticket with an attachment	1	2	2025-08-30 14:26:16.722435	2025-08-30 14:26:18.334987	INCSUM5F4E0	Incident	4	5	10	2025-08-30 14:24:00	Technical	Minky	Robbins	tendain@greensoftsolutions.net	0742591362	Johannesburg	Web	1	10	2025-09-03 12:00:00	2025-09-10 15:00:00	0	f	4	1	1	1	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	f
50	Attaching a pdf to ticket	Allow tickets to have an attachment	2	2	2025-08-30 14:11:07.759217	2025-08-30 14:11:08.422033	INCNLIHTL84	Incident	10	6	10	2025-08-30 14:10:00	Technical	Tendai	Tindo	tendain@greensoftsolutions.net	0742591362	Juskskei	Web	1	10	2025-09-03 12:00:00	2025-09-10 15:00:00	0	f	4	1	2	2	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	f
52	test ticket numbering 	We have changed the ticket sequencing  to make more 	1	2	2025-08-30 14:50:03.476348	2025-08-30 18:01:08.371583	INC0001	Incident	\N	4	10	2025-08-30 14:47:00	Technical	Tendai	Tindo	tendain@greensoftsolutions.net	0742591362	Juskskei	Web	1	10	2025-09-03 12:00:00	2025-09-10 15:00:00	0	f	4	1	1	1	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	f
47	Attaching a pdf to a ticket	Let update the ticket and add a pdf attachment	2	2	2025-08-30 13:15:21.908975	2025-08-30 18:22:42.110934	INCHK3YOCO5	Incident	7	5	10	2025-08-30 13:13:00	Technical	Tendai	Tindo	tendain@greensoftsolutions.net	0742591362	Juskskei	Web	1	10	2025-09-03 12:00:00	2025-09-10 15:00:00	0	f	4	1	2	2	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	f
53	Fixing proper numbering	We want to fix the proper numbering of the ticketing system	1	2	2025-08-31 09:14:09.281347	2025-08-31 09:14:11.008659	INC0002	Incident	10	6	10	2025-08-31 09:12:00	Technical	Taya	Clever	tendain@greensoftsolutions.net	0742591362	Jusk	Web	1	10	2025-09-03 12:00:00	2025-09-10 15:00:00	0	f	4	1	1	1	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	f
54	Changing categories	Lets fix	3	2	2025-08-31 11:48:44.404539	2025-08-31 11:48:46.119143	CIPC_INC0001	Incident	10	6	10	2025-08-31 11:36:00	Query	Charity	Mkoba	charitynk@gmail.com	0742591362	Johannesburg	Web	1	10	2025-09-03 12:00:00	2025-09-10 15:00:00	0	f	4	2	2	3	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	f
\.


--
-- Data for Name: users; Type: TABLE DATA; Schema: public; Owner: tendai
--

COPY public.users (id, name, email, password_digest, role, organization_id, created_at, updated_at, "position", team_id, auth_token, username, phone_number, receive_email_notifications, reset_password_sent_at, department_id, reset_password_token, new_reset_password_token, last_name, refresh_token, refresh_token_expires_at, uuid, token_expires_at) FROM stdin;
12	Imbu	imbuk@greensoftsolutions.net	$2a$12$uB4Y93PSaoBfK/wtWuUaMOL6kpLRLv/ghFTENx3W7/IbGu/mFEqqq	14	2	2025-08-29 09:59:31.491126	2025-08-29 09:59:31.491126	Manager	\N	f76c61e87a2ce3aa95085175a637d345b7690665	imbuK@greensoftsolutions.net	064 326 9373	t	\N	\N	\N	\N	Kinzamba	\N	\N	\N	\N
3	Charity	charitynk@gmail.com	$2a$12$m.TbN5d77962wdteAgGUu.fjsHp0HC7rS2Qd1TlBBpYs68I/Cug9C	1	2	2025-08-24 20:00:00.83128	2025-08-24 20:00:00.83128	Agent	6	e44e456e5f204bc02f97a884d2be20da60069a6b	charity@bluesoft.com	6355788282	t	\N	\N	\N	\N	Musa	\N	\N	\N	\N
2	Willow	willowpine@gmail.com	$2a$12$PqEiR7pMdBcmO4oLX1AxouhGJrFr1ObcUVMtXkRFbhQwymFs9BuI6	1	2	2025-08-24 19:50:45.230773	2025-08-24 19:50:45.230773	MD	6	cb90ce1422da1c66cca3d1cf4b38fb95c1209cee	timike@bluesoft.com	064 187 2534	t	\N	\N	\N	\N	Pine	\N	\N	\N	\N
5	Manoja	manojar@greensoftsolutions.net	$2a$12$CDBpn6joOsHF3.2Av7k/NeD.6v8EnxwVN/Yn1TNbGP9kt43R/u65q	14	2	2025-08-26 07:05:29.989286	2025-08-26 07:05:29.989286	Director	6	ddb8666edf85a55fd6266a11112b7176e45da609	manojar@greensoftsolutions.net	0615284794	t	\N	\N	\N	\N	Rajavarapu	\N	\N	\N	\N
10	Tendai	tendain@greensoftsolutions.net	$2a$12$VbttC.SwIRqpWibCP1bWv.wAo/e1/wEXsBokTBTdg4aKER5FpB2WK	14	2	2025-08-29 09:09:23.801465	2025-08-29 09:09:23.801465	Developer	6	151a6f622e6aa6437ad4ed479a2e630809f5765b	tendai@cipc.com	0742591362	t	\N	\N	\N	\N	Nyandoro	\N	\N	\N	\N
8	Alvin	tendai@radical.co.zw	$2a$12$M0M75CRoLzJGopZwCPUTOuP7viTmx81IjJbIfG1JvjQiHWlFgzBt6	1	2	2025-08-28 09:05:07.885083	2025-08-28 09:05:07.885083	Director	\N	b0fe972757609b7a16fd30c4fe2e6a827c4771ea	tendai@radical.co.zw	0630190641	t	\N	\N	\N	\N	Chipmunk	\N	\N	\N	\N
9	Timothy	timb@hotmail.com	$2a$12$N4MsIYbATTt6n.iGACFziOdvd9RAloLrAu26ukbJ9TbSIliRSZoiO	1	2	2025-08-28 09:15:59.418085	2025-08-28 09:15:59.418085	Developer	\N	28e314dd610ba1858a36c77c7d6643a7150cbce4	timb@hotmail.com	0100355568	t	\N	\N	\N	\N	bryan	\N	\N	\N	\N
11	Dilip	dilipk@greensoftsolutions.net	$2a$12$1vv6WfBGThex3PbodmvC6O1NdzybTuUHy2DZT75I5Hd9FFq15xJve	1	2	2025-08-29 09:57:48.7083	2025-08-29 09:57:48.7083	Developer	6	3e02e50949a26c95bf397e06fc9f393b63dd4dd1	dilipk@greensoftsolutions.net	011 092 3627	t	\N	\N	\N	\N	Kadi	\N	\N	\N	\N
6	Momo	tendaic.nyandoro@gmail.com	$2a$12$bqX.msIwNjirJoJfWQQ5Gu9ZzAiAGgmbjBZOSBZdVcxJBgy0SNpum	14	2	2025-08-27 12:14:42.016144	2025-08-27 12:14:42.016144	Director	5	6a830a15e0b0b8ec1914d4b4d3f4fd93a30446f5	tendai1@hotmail.com	0630190641	t	\N	\N	\N	\N	Nkhoma	\N	\N	\N	\N
7	Vibha	vibham@greensoftsolutions.net	$2a$12$6T8/vSmY.mWlxkaiY5hnYeE2r4hDMR/Of1QNgbmD/E1Ep95dwvvt6	13	2	2025-08-28 08:25:11.943744	2025-08-28 08:25:11.943744	Developer	5	1b976f44a37b8f05a276f11661142fa6eee12140	vibhaM@greensoftsolutions.net	0100355568	t	\N	\N	\N	\N	Mangrulkar	\N	\N	\N	\N
4	Robby	tnyandoro@gmail.com	$2a$12$NXyg6qvmrUE/oUnRhqK6yuZ6FhYizC9v.CRk.J//Kt1V9jnJTNU6i	1	2	2025-08-25 09:52:48.159768	2025-08-25 09:52:48.159768	Agent	5	f87bde2696e8167e61b969461740251dbb153854	tnyandoro@gmail.com	0742591362	t	\N	\N	\N	\N	Mcclane	\N	\N	\N	\N
\.


--
-- Data for Name: versions; Type: TABLE DATA; Schema: public; Owner: tendai
--

COPY public.versions (id, whodunnit, created_at, item_id, item_type, event, object) FROM stdin;
1	\N	2025-08-25 07:10:06.99354	1	Ticket	create	\N
2	\N	2025-08-25 07:12:40.035615	2	Ticket	create	\N
3	\N	2025-08-25 07:44:06.215067	3	Ticket	create	\N
4	\N	2025-08-25 10:07:00.064074	4	Ticket	create	\N
5	\N	2025-08-25 10:25:35.632586	5	Ticket	create	\N
6	\N	2025-08-25 10:28:42.811702	6	Ticket	create	\N
10	\N	2025-08-25 11:09:33.450337	10	Ticket	create	\N
11	\N	2025-08-25 11:34:43.744899	11	Ticket	create	\N
12	\N	2025-08-25 12:20:50.187525	12	Ticket	create	\N
14	\N	2025-08-25 12:50:33.165255	14	Ticket	create	\N
15	\N	2025-08-25 12:53:53.897294	15	Ticket	create	\N
21	\N	2025-08-25 14:15:54.249982	21	Ticket	create	\N
22	\N	2025-08-25 15:02:21.120892	22	Ticket	create	\N
23	\N	2025-08-26 06:53:06.061034	23	Ticket	create	\N
24	\N	2025-08-26 07:12:45.912538	24	Ticket	create	\N
25	\N	2025-08-26 08:54:43.971314	24	Ticket	update	---\norganization_id: 2\nstatus: 1\nresolution_note:\nreason:\nresolution_method:\ncause_code:\nresolution_details:\nend_customer:\nsupport_center:\ntotal_kilometer:\nresolved_at:\npriority: 0\ncreator_id: 1\nrequester_id: 1\nticket_number: INCPXIJIJG5\ncalculated_priority: 3\nid: 24\ntitle: 'Testing if mailer is working '\ndescription: 'The ticket is to fix our mailer to see if its working '\ncreated_at: 2025-08-26 07:12:45.912538000 Z\nupdated_at: 2025-08-26 07:12:45.912538000 Z\nticket_type: Incident\nassignee_id: 5\nteam_id: 3\nreported_at: 2025-08-26 07:11:00.000000000 Z\ncategory: Technical\ncaller_name: Tendai\ncaller_surname: Nyandoro\ncaller_email: manojar@greensoftsolutions.net\ncaller_phone: 064 197 6745\ncustomer: GSS HQ\nsource: Web\nresponse_due_at:\nresolution_due_at:\nescalation_level: 0\nsla_breached: false\nsla_policy_id:\nurgency: 2\nimpact: 2\nsome_field:\ndepartment_id:\nbreaching_sla: false\n
26	\N	2025-08-26 10:56:21.916086	25	Ticket	create	\N
27	\N	2025-08-26 11:53:35.63388	25	Ticket	update	---\norganization_id: 2\nstatus: 1\nresolution_note:\nreason:\nresolution_method:\ncause_code:\nresolution_details:\nend_customer:\nsupport_center:\ntotal_kilometer:\nresolved_at:\npriority: 0\ncreator_id: 1\nrequester_id: 1\nticket_number: INCEE91Y6EH\ncalculated_priority: 1\nid: 25\ntitle: Test email sent\ndescription: Test test\ncreated_at: 2025-08-26 10:56:21.916086000 Z\nupdated_at: 2025-08-26 10:56:21.916086000 Z\nticket_type: Incident\nassignee_id: 4\nteam_id: 3\nreported_at: 2025-08-26 10:55:00.000000000 Z\ncategory: Technical\ncaller_name: Torry\ncaller_surname: Charlie\ncaller_email: tnyandoro@gmail.com\ncaller_phone: 063 0190641\ncustomer: LQ\nsource: Web\nresponse_due_at:\nresolution_due_at:\nescalation_level: 0\nsla_breached: false\nsla_policy_id:\nurgency: 1\nimpact: 1\nsome_field:\ndepartment_id:\nbreaching_sla: false\n
28	\N	2025-08-28 08:28:46.225714	26	Ticket	create	\N
29	\N	2025-08-28 08:31:46.770527	27	Ticket	create	\N
30	\N	2025-08-28 09:24:48.869675	28	Ticket	create	\N
31	\N	2025-08-28 09:29:24.704189	28	Ticket	update	---\norganization_id: 2\nstatus: 1\nresolution_note:\nreason:\nresolution_method:\ncause_code:\nresolution_details:\nend_customer:\nsupport_center:\ntotal_kilometer:\nresolved_at:\npriority: 0\ncreator_id: 1\nrequester_id: 1\nticket_number: INCOM6R3O8N\ncalculated_priority: 1\nid: 28\ntitle: Check Ticket\ndescription: is this working\ncreated_at: 2025-08-28 09:24:48.869675000 Z\nupdated_at: 2025-08-28 09:24:48.869675000 Z\nticket_type: Incident\nassignee_id: 7\nteam_id: 4\nreported_at: 2025-08-28 09:23:00.000000000 Z\ncategory: Technical\ncaller_name: Becker\ncaller_surname: Brooks\ncaller_email: vibham@greensoftsolutions.net\ncaller_phone: 063 0190873\ncustomer: GSS\nsource: Web\nresponse_due_at:\nresolution_due_at:\nescalation_level: 0\nsla_breached: false\nsla_policy_id:\nurgency: 1\nimpact: 1\nsome_field:\ndepartment_id:\nbreaching_sla: false\n
32	\N	2025-08-28 09:50:04.997157	27	Ticket	update	---\norganization_id: 2\nstatus: 1\nresolution_note:\nreason:\nresolution_method:\ncause_code:\nresolution_details:\nend_customer:\nsupport_center:\ntotal_kilometer:\nresolved_at:\npriority: 0\ncreator_id: 1\nrequester_id: 1\nticket_number: INCGXM0ZD4R\ncalculated_priority: 1\nid: 27\ntitle: 'Testing if mailer is working '\ndescription: 'This mail is been sent '\ncreated_at: 2025-08-28 08:31:46.770527000 Z\nupdated_at: 2025-08-28 08:31:46.770527000 Z\nticket_type: Incident\nassignee_id: 4\nteam_id: 4\nreported_at: 2025-08-28 08:30:00.000000000 Z\ncategory: Technical\ncaller_name: Becker\ncaller_surname: Nyandoro\ncaller_email: tnyandoro@gmail.com\ncaller_phone: 011 564 7632\ncustomer: GSS HQ\nsource: Web\nresponse_due_at:\nresolution_due_at:\nescalation_level: 0\nsla_breached: false\nsla_policy_id:\nurgency: 1\nimpact: 1\nsome_field:\ndepartment_id:\nbreaching_sla: false\n
33	\N	2025-08-28 10:01:39.962687	26	Ticket	update	---\norganization_id: 2\nstatus: 1\nresolution_note:\nreason:\nresolution_method:\ncause_code:\nresolution_details:\nend_customer:\nsupport_center:\ntotal_kilometer:\nresolved_at:\npriority: 0\ncreator_id: 1\nrequester_id: 1\nticket_number: INCF674YPSH\ncalculated_priority: 3\nid: 26\ntitle: Lets test sending email from the app\ndescription: 'We want to make sure the app is now sending emails from our app then\n  deploy to cloud '\ncreated_at: 2025-08-28 08:28:46.225714000 Z\nupdated_at: 2025-08-28 08:28:46.225714000 Z\nticket_type: Incident\nassignee_id: 7\nteam_id: 4\nreported_at: 2025-08-28 08:27:00.000000000 Z\ncategory: Technical\ncaller_name: Tindo\ncaller_surname: Man\ncaller_email: vibham@greensoftsolutions.net\ncaller_phone: 063 0190873\ncustomer: GSS\nsource: Web\nresponse_due_at:\nresolution_due_at:\nescalation_level: 0\nsla_breached: false\nsla_policy_id:\nurgency: 2\nimpact: 2\nsome_field:\ndepartment_id:\nbreaching_sla: false\n
34	\N	2025-08-28 11:33:31.148008	29	Ticket	create	\N
35	\N	2025-08-28 11:34:14.143413	29	Ticket	update	---\norganization_id: 2\nstatus: 1\nresolution_note:\nreason:\nresolution_method:\ncause_code:\nresolution_details:\nend_customer:\nsupport_center:\ntotal_kilometer:\nresolved_at:\npriority: 0\ncreator_id: 1\nrequester_id: 1\nticket_number: INCSBL7799V\ncalculated_priority: 2\nid: 29\ntitle: Lets test sending email from the app\ndescription: test test\ncreated_at: 2025-08-28 11:33:31.148008000 Z\nupdated_at: 2025-08-28 11:33:31.148008000 Z\nticket_type: Incident\nassignee_id: 4\nteam_id: 4\nreported_at: 2025-08-28 11:32:00.000000000 Z\ncategory: Technical\ncaller_name: Becker\ncaller_surname: Man\ncaller_email: tendai@bluesoft.com\ncaller_phone: 063 0190873\ncustomer: GSS\nsource: Web\nresponse_due_at:\nresolution_due_at:\nescalation_level: 0\nsla_breached: false\nsla_policy_id:\nurgency: 1\nimpact: 2\nsome_field:\ndepartment_id:\nbreaching_sla: false\n
36	\N	2025-08-28 21:01:18.72471	30	Ticket	create	\N
72	\N	2025-08-29 10:44:02.241659	35	Ticket	create	\N
37	\N	2025-08-28 21:01:19.769428	30	Ticket	update	---\nid: 30\ntitle: Mailing Test\ndescription: Mailing test\npriority: 0\norganization_id: 2\ncreated_at: 2025-08-28 21:01:18.724710000 Z\nupdated_at: 2025-08-28 21:01:18.724710000 Z\nticket_number: INC6BFQUAG8\nticket_type: Incident\nassignee_id: 4\nteam_id: 4\nrequester_id: 1\nreported_at: 2025-08-28 20:59:00.000000000 Z\ncategory: Technical\ncaller_name: Becker\ncaller_surname: Morris\ncaller_email: tnyandoro@gmail.com\ncaller_phone: 011 564 7632\ncustomer: GSS HQ\nsource: Web\nstatus: 1\ncreator_id: 1\nresponse_due_at:\nresolution_due_at:\nescalation_level: 0\nsla_breached: false\nsla_policy_id:\nurgency: 2\nimpact: 2\ncalculated_priority: 3\nresolved_at:\nresolution_note:\nsome_field:\nreason:\nresolution_method:\ncause_code:\nresolution_details:\nend_customer:\nsupport_center:\ntotal_kilometer:\ndepartment_id:\nbreaching_sla: false\n
38	\N	2025-08-29 09:43:07.175779	31	Ticket	create	\N
39	\N	2025-08-29 09:43:08.358309	31	Ticket	update	---\nid: 31\ntitle: Give Admin Permissions to more users\ndescription: 'We have given more permissions to system users '\npriority: 0\norganization_id: 2\ncreated_at: 2025-08-29 09:43:07.175779000 Z\nupdated_at: 2025-08-29 09:43:07.175779000 Z\nticket_number: REQ057HNEEU\nticket_type: Request\nassignee_id: 5\nteam_id: 3\nrequester_id: 10\nreported_at: 2025-08-29 09:41:00.000000000 Z\ncategory: Technical\ncaller_name: Tendai\ncaller_surname: Nyandoro\ncaller_email: tendain@greensoftsolutions.net\ncaller_phone: '0742591362'\ncustomer: GSS\nsource: Web\nstatus: 1\ncreator_id: 10\nresponse_due_at:\nresolution_due_at:\nescalation_level: 0\nsla_breached: false\nsla_policy_id:\nurgency: 2\nimpact: 2\ncalculated_priority: 3\nresolved_at:\nresolution_note:\nsome_field:\nreason:\nresolution_method:\ncause_code:\nresolution_details:\nend_customer:\nsupport_center:\ntotal_kilometer:\ndepartment_id:\nbreaching_sla: false\n
40	\N	2025-08-29 09:44:58.781165	32	Ticket	create	\N
41	\N	2025-08-29 09:44:59.072425	32	Ticket	update	---\nid: 32\ntitle: Let add more permissions\ndescription: 'We want to see if we can now create more tickets:'\npriority: 0\norganization_id: 2\ncreated_at: 2025-08-29 09:44:58.781165000 Z\nupdated_at: 2025-08-29 09:44:58.781165000 Z\nticket_number: PRBPLMBD5XG\nticket_type: Problem\nassignee_id: 4\nteam_id: 4\nrequester_id: 10\nreported_at: 2025-08-29 09:43:00.000000000 Z\ncategory: Technical\ncaller_name: Tendai\ncaller_surname: Pine\ncaller_email: tendain@greensoftsolutions.net\ncaller_phone: '0742591362'\ncustomer: GSS\nsource: Web\nstatus: 1\ncreator_id: 10\nresponse_due_at:\nresolution_due_at:\nescalation_level: 0\nsla_breached: false\nsla_policy_id:\nurgency: 2\nimpact: 2\ncalculated_priority: 3\nresolved_at:\nresolution_note:\nsome_field:\nreason:\nresolution_method:\ncause_code:\nresolution_details:\nend_customer:\nsupport_center:\ntotal_kilometer:\ndepartment_id:\nbreaching_sla: false\n
42	\N	2025-08-29 09:52:56.936655	31	Ticket	update	---\norganization_id: 2\nstatus: 1\nresolution_note:\nreason:\nresolution_method:\ncause_code:\nresolution_details:\nend_customer:\nsupport_center:\ntotal_kilometer:\nresolved_at:\npriority: 3\ncreator_id: 10\nrequester_id: 10\nticket_number: REQ057HNEEU\ncalculated_priority: 3\nid: 31\ntitle: Give Admin Permissions to more users\ndescription: 'We have given more permissions to system users '\ncreated_at: 2025-08-29 09:43:07.175779000 Z\nupdated_at: 2025-08-29 09:43:08.358309000 Z\nticket_type: Request\nassignee_id: 5\nteam_id: 3\nreported_at: 2025-08-29 09:41:00.000000000 Z\ncategory: Technical\ncaller_name: Tendai\ncaller_surname: Nyandoro\ncaller_email: tendain@greensoftsolutions.net\ncaller_phone: '0742591362'\ncustomer: GSS\nsource: Web\nresponse_due_at: 2025-09-03 06:41:00.000000000 Z\nresolution_due_at: 2025-09-10 09:41:00.000000000 Z\nescalation_level: 0\nsla_breached: false\nsla_policy_id: 4\nurgency: 2\nimpact: 2\nsome_field:\ndepartment_id:\nbreaching_sla: false\n
43	\N	2025-08-29 10:02:05.979817	33	Ticket	create	\N
44	\N	2025-08-29 10:02:06.305589	33	Ticket	update	---\nid: 33\ntitle: Admin assigning tickets\ndescription: 'Lets check to see if this is now working '\npriority: 0\norganization_id: 2\ncreated_at: 2025-08-29 10:02:05.979817000 Z\nupdated_at: 2025-08-29 10:02:05.979817000 Z\nticket_number: INC68SLXGRK\nticket_type: Incident\nassignee_id:\nteam_id: 5\nrequester_id: 12\nreported_at: 2025-08-29 10:00:00.000000000 Z\ncategory: Technical\ncaller_name: Trudy\ncaller_surname: Monroe\ncaller_email: imbuk@greensoftsolutions.net\ncaller_phone: 064 326 9373\ncustomer: GSS\nsource: Web\nstatus: 0\ncreator_id: 12\nresponse_due_at:\nresolution_due_at:\nescalation_level: 0\nsla_breached: false\nsla_policy_id:\nurgency: 2\nimpact: 2\ncalculated_priority: 3\nresolved_at:\nresolution_note:\nsome_field:\nreason:\nresolution_method:\ncause_code:\nresolution_details:\nend_customer:\nsupport_center:\ntotal_kilometer:\ndepartment_id:\nbreaching_sla: false\n
45	\N	2025-08-29 10:03:54.87515	33	Ticket	update	---\norganization_id: 2\nstatus: 0\nresolution_note:\nreason:\nresolution_method:\ncause_code:\nresolution_details:\nend_customer:\nsupport_center:\ntotal_kilometer:\nresolved_at:\npriority: 3\ncreator_id: 12\nrequester_id: 12\nticket_number: INC68SLXGRK\ncalculated_priority: 3\nid: 33\ntitle: Admin assigning tickets\ndescription: 'Lets check to see if this is now working '\ncreated_at: 2025-08-29 10:02:05.979817000 Z\nupdated_at: 2025-08-29 10:02:06.305589000 Z\nticket_type: Incident\nassignee_id:\nteam_id: 5\nreported_at: 2025-08-29 10:00:00.000000000 Z\ncategory: Technical\ncaller_name: Trudy\ncaller_surname: Monroe\ncaller_email: imbuk@greensoftsolutions.net\ncaller_phone: 064 326 9373\ncustomer: GSS\nsource: Web\nresponse_due_at: 2025-09-03 07:00:00.000000000 Z\nresolution_due_at: 2025-09-10 10:00:00.000000000 Z\nescalation_level: 0\nsla_breached: false\nsla_policy_id: 4\nurgency: 2\nimpact: 2\nsome_field:\ndepartment_id:\nbreaching_sla: false\n
46	\N	2025-08-29 10:16:52.016484	26	Ticket	destroy	---\nid: 26\ntitle: Lets test sending email from the app\ndescription: 'We want to make sure the app is now sending emails from our app then\n  deploy to cloud '\npriority: 3\norganization_id: 2\ncreated_at: 2025-08-28 08:28:46.225714000 Z\nupdated_at: 2025-08-28 10:01:39.962687000 Z\nticket_number: INCF674YPSH\nticket_type: Incident\nassignee_id: 7\nteam_id: 4\nrequester_id:\nreported_at: 2025-08-28 08:27:00.000000000 Z\ncategory: Technical\ncaller_name: Tindo\ncaller_surname: Man\ncaller_email: vibham@greensoftsolutions.net\ncaller_phone: 063 0190873\ncustomer: GSS\nsource: Web\nstatus: 5\ncreator_id:\nresponse_due_at:\nresolution_due_at:\nescalation_level: 0\nsla_breached: false\nsla_policy_id:\nurgency: 2\nimpact: 2\ncalculated_priority: 3\nresolved_at: 2025-08-28 10:01:39.917401000 Z\nresolution_note: |-\n  Neque porro quisquam est qui dolorem ipsum quia dolor sit amet, consectetur, adipisci velit..."\n  "There is no one who loves pain itself, who seeks after it and wants to have it, simply because it is pain..\nsome_field:\nreason: Neque porro quisquam est qui dolorem ipsum quia dolor sit amet, consectetur,\n  adipisci velit..." "There is no one who loves pain itself, who seeks after it and\n  wants to have it, simply because it is pain..\nresolution_method: Neque porro quisquam est qui dolorem ipsum quia dolor sit amet,\n  consectetur, adipisci velit..." "There is no one who loves pain itself, who seeks\n  after it and wants to have it, simply because it is pain..\ncause_code: Neque porro quisquam est qui dolorem ipsum quia dolor sit amet, consectetur,\n  adipisci velit..." "There is no one who loves pain itself, who seeks after it and\n  wants to have it, simply because it is pain..\nresolution_details: |-\n  Neque porro quisquam est qui dolorem ipsum quia dolor sit amet, consectetur, adipisci velit..."\n  "There is no one who loves pain itself, who seeks after it and wants to have it, simply because it is pain..\nend_customer: betty\nsupport_center: ''\ntotal_kilometer: ''\ndepartment_id:\nbreaching_sla: false\n
47	\N	2025-08-29 10:16:52.428017	30	Ticket	destroy	---\nid: 30\ntitle: Mailing Test\ndescription: Mailing test\npriority: 3\norganization_id: 2\ncreated_at: 2025-08-28 21:01:18.724710000 Z\nupdated_at: 2025-08-28 21:01:19.769428000 Z\nticket_number: INC6BFQUAG8\nticket_type: Incident\nassignee_id: 4\nteam_id: 4\nrequester_id:\nreported_at: 2025-08-28 20:59:00.000000000 Z\ncategory: Technical\ncaller_name: Becker\ncaller_surname: Morris\ncaller_email: tnyandoro@gmail.com\ncaller_phone: 011 564 7632\ncustomer: GSS HQ\nsource: Web\nstatus: 1\ncreator_id:\nresponse_due_at: 2025-09-02 12:00:00.000000000 Z\nresolution_due_at: 2025-09-09 15:00:00.000000000 Z\nescalation_level: 0\nsla_breached: false\nsla_policy_id: 4\nurgency: 2\nimpact: 2\ncalculated_priority: 3\nresolved_at:\nresolution_note:\nsome_field:\nreason:\nresolution_method:\ncause_code:\nresolution_details:\nend_customer:\nsupport_center:\ntotal_kilometer:\ndepartment_id:\nbreaching_sla: false\n
48	\N	2025-08-29 10:16:52.478787	6	Ticket	destroy	---\nid: 6\ntitle: Setting up mailer and test\ndescription: 'Testing our mailer '\npriority: 0\norganization_id: 2\ncreated_at: 2025-08-25 10:28:42.811702000 Z\nupdated_at: 2025-08-25 10:28:42.811702000 Z\nticket_number: INCT3933W3M\nticket_type: Incident\nassignee_id: 4\nteam_id: 2\nrequester_id:\nreported_at: 2025-08-25 10:27:00.000000000 Z\ncategory: Technical\ncaller_name: Timmy\ncaller_surname: Simpson\ncaller_email: tnyandoro@gmail.com\ncaller_phone: 072 136 2389\ncustomer: Midrand\nsource: Web\nstatus: 1\ncreator_id:\nresponse_due_at:\nresolution_due_at:\nescalation_level: 0\nsla_breached: false\nsla_policy_id:\nurgency: 2\nimpact: 1\ncalculated_priority: 2\nresolved_at:\nresolution_note:\nsome_field:\nreason:\nresolution_method:\ncause_code:\nresolution_details:\nend_customer:\nsupport_center:\ntotal_kilometer:\ndepartment_id:\nbreaching_sla: false\n
49	\N	2025-08-29 10:16:52.529891	1	Ticket	destroy	---\nid: 1\ntitle: Create a reolve modal\ndescription: Lets fix the ticket creation with cors set\npriority: 0\norganization_id: 2\ncreated_at: 2025-08-25 07:10:06.993540000 Z\nupdated_at: 2025-08-25 07:10:06.993540000 Z\nticket_number: INCZ81KA96S\nticket_type: Incident\nassignee_id: 2\nteam_id: 1\nrequester_id:\nreported_at: 2025-08-25 07:08:00.000000000 Z\ncategory: Technical\ncaller_name: Sharon\ncaller_surname: Nkhoma\ncaller_email: tendai@bluesoft.com\ncaller_phone: '0610180826'\ncustomer: Capetown\nsource: Web\nstatus: 1\ncreator_id:\nresponse_due_at:\nresolution_due_at:\nescalation_level: 0\nsla_breached: false\nsla_policy_id:\nurgency: 1\nimpact: 1\ncalculated_priority: 1\nresolved_at:\nresolution_note:\nsome_field:\nreason:\nresolution_method:\ncause_code:\nresolution_details:\nend_customer:\nsupport_center:\ntotal_kilometer:\ndepartment_id:\nbreaching_sla: false\n
50	\N	2025-08-29 10:16:52.596552	2	Ticket	destroy	---\nid: 2\ntitle: Create a ticket with Cors settings\ndescription: 'Have fixed CORS we want to create a ticket with these settings '\npriority: 0\norganization_id: 2\ncreated_at: 2025-08-25 07:12:40.035615000 Z\nupdated_at: 2025-08-25 07:12:40.035615000 Z\nticket_number: INC3G2W0XLW\nticket_type: Incident\nassignee_id: 3\nteam_id: 1\nrequester_id:\nreported_at: 2025-08-25 07:10:00.000000000 Z\ncategory: Technical\ncaller_name: Linda\ncaller_surname: Kurewa\ncaller_email: tendai@bluesoft.com\ncaller_phone: 063 019 0641\ncustomer: GSS HQ\nsource: Web\nstatus: 1\ncreator_id:\nresponse_due_at:\nresolution_due_at:\nescalation_level: 0\nsla_breached: false\nsla_policy_id:\nurgency: 1\nimpact: 1\ncalculated_priority: 1\nresolved_at:\nresolution_note:\nsome_field:\nreason:\nresolution_method:\ncause_code:\nresolution_details:\nend_customer:\nsupport_center:\ntotal_kilometer:\ndepartment_id:\nbreaching_sla: false\n
51	\N	2025-08-29 10:16:52.709143	14	Ticket	destroy	---\nid: 14\ntitle: testing mail sent\ndescription: 'testing email senting '\npriority: 0\norganization_id: 2\ncreated_at: 2025-08-25 12:50:33.165255000 Z\nupdated_at: 2025-08-25 12:50:33.165255000 Z\nticket_number: INCEWEOTGBH\nticket_type: Incident\nassignee_id: 4\nteam_id: 2\nrequester_id:\nreported_at: 2025-08-25 12:49:00.000000000 Z\ncategory: Technical\ncaller_name: saul\ncaller_surname: Kent\ncaller_email: tendai1@hotmail.com\ncaller_phone: 072 136 2389\ncustomer: GSS\nsource: Web\nstatus: 1\ncreator_id:\nresponse_due_at:\nresolution_due_at:\nescalation_level: 0\nsla_breached: false\nsla_policy_id:\nurgency: 1\nimpact: 2\ncalculated_priority: 2\nresolved_at:\nresolution_note:\nsome_field:\nreason:\nresolution_method:\ncause_code:\nresolution_details:\nend_customer:\nsupport_center:\ntotal_kilometer:\ndepartment_id:\nbreaching_sla: false\n
52	\N	2025-08-29 10:16:52.763481	27	Ticket	destroy	---\nid: 27\ntitle: 'Testing if mailer is working '\ndescription: 'This mail is been sent '\npriority: 1\norganization_id: 2\ncreated_at: 2025-08-28 08:31:46.770527000 Z\nupdated_at: 2025-08-28 09:50:04.997157000 Z\nticket_number: INCGXM0ZD4R\nticket_type: Incident\nassignee_id: 4\nteam_id: 4\nrequester_id:\nreported_at: 2025-08-28 08:30:00.000000000 Z\ncategory: Technical\ncaller_name: Becker\ncaller_surname: Nyandoro\ncaller_email: tnyandoro@gmail.com\ncaller_phone: 011 564 7632\ncustomer: GSS HQ\nsource: Web\nstatus: 5\ncreator_id:\nresponse_due_at:\nresolution_due_at:\nescalation_level: 0\nsla_breached: false\nsla_policy_id:\nurgency: 1\nimpact: 1\ncalculated_priority: 1\nresolved_at: 2025-08-28 09:50:04.930616000 Z\nresolution_note: |-\n  Neque porro quisquam est qui dolorem ipsum quia dolor sit amet, consectetur, adipisci velit..."\n  "There is no one who loves pain itself, who seeks after it and wants to have it, simply because it is pain..\nsome_field:\nreason: Neque porro quisquam est qui dolorem ipsum quia dolor sit amet, consectetur,\n  adipisci velit..." "There is no one who loves pain itself, who seeks after it and\n  wants to have it, simply because it is pain..\nresolution_method: 'Fixed the render_success call: Removed the third argument (:created)\n  that was causing the "wrong number of arguments" error.'\ncause_code: '00000'\nresolution_details: |-\n  Neque porro quisquam est qui dolorem ipsum quia dolor sit amet, consectetur, adipisci velit..."\n  "There is no one who loves pain itself, who seeks after it and wants to have it, simply because it is pain..\nend_customer: John\nsupport_center: ''\ntotal_kilometer: ''\ndepartment_id:\nbreaching_sla: false\n
53	\N	2025-08-29 10:16:52.818414	3	Ticket	destroy	---\nid: 3\ntitle: Create with the correct time stamp\ndescription: 'We need to create a ticket with the correct time stamp '\npriority: 0\norganization_id: 2\ncreated_at: 2025-08-25 07:44:06.215067000 Z\nupdated_at: 2025-08-25 07:44:06.215067000 Z\nticket_number: INCGGAE4LXR\nticket_type: Incident\nassignee_id: 2\nteam_id: 1\nrequester_id:\nreported_at: 2025-08-25 07:42:00.000000000 Z\ncategory: Technical\ncaller_name: Tendai\ncaller_surname: Mvuma\ncaller_email: tendai1@hotmail.com\ncaller_phone: 072 136 2389\ncustomer: Midrand\nsource: Web\nstatus: 1\ncreator_id:\nresponse_due_at:\nresolution_due_at:\nescalation_level: 0\nsla_breached: false\nsla_policy_id:\nurgency: 1\nimpact: 2\ncalculated_priority: 2\nresolved_at:\nresolution_note:\nsome_field:\nreason:\nresolution_method:\ncause_code:\nresolution_details:\nend_customer:\nsupport_center:\ntotal_kilometer:\ndepartment_id:\nbreaching_sla: false\n
54	\N	2025-08-29 10:16:52.869987	22	Ticket	destroy	---\nid: 22\ntitle: Mailer Test\ndescription: 'Sending a mailer '\npriority: 0\norganization_id: 2\ncreated_at: 2025-08-25 15:02:21.120892000 Z\nupdated_at: 2025-08-25 15:02:21.120892000 Z\nticket_number: INC4P1QO406\nticket_type: Incident\nassignee_id: 4\nteam_id: 2\nrequester_id:\nreported_at: 2025-08-25 15:01:00.000000000 Z\ncategory: Technical\ncaller_name: Simba\ncaller_surname: Mutangadura\ncaller_email: tnyandoro@gmail.com\ncaller_phone: '074291362'\ncustomer: GSS HQ\nsource: Web\nstatus: 1\ncreator_id:\nresponse_due_at:\nresolution_due_at:\nescalation_level: 0\nsla_breached: false\nsla_policy_id:\nurgency: 2\nimpact: 1\ncalculated_priority: 2\nresolved_at:\nresolution_note:\nsome_field:\nreason:\nresolution_method:\ncause_code:\nresolution_details:\nend_customer:\nsupport_center:\ntotal_kilometer:\ndepartment_id:\nbreaching_sla: false\n
55	\N	2025-08-29 10:16:52.914273	23	Ticket	destroy	---\nid: 23\ntitle: Testing Email\ndescription: 'Welcome  to Gsolve '\npriority: 0\norganization_id: 2\ncreated_at: 2025-08-26 06:53:06.061034000 Z\nupdated_at: 2025-08-26 06:53:06.061034000 Z\nticket_number: INCVYX83VKQ\nticket_type: Incident\nassignee_id: 4\nteam_id: 2\nrequester_id:\nreported_at: 2025-08-26 06:50:00.000000000 Z\ncategory: Technical\ncaller_name: Cherry\ncaller_surname: Suavanna\ncaller_email: tnyandoro@gmail.com\ncaller_phone: '087 362 2134'\ncustomer: Jukskei\nsource: Web\nstatus: 1\ncreator_id:\nresponse_due_at:\nresolution_due_at:\nescalation_level: 0\nsla_breached: false\nsla_policy_id:\nurgency: 1\nimpact: 2\ncalculated_priority: 2\nresolved_at:\nresolution_note:\nsome_field:\nreason:\nresolution_method:\ncause_code:\nresolution_details:\nend_customer:\nsupport_center:\ntotal_kilometer:\ndepartment_id:\nbreaching_sla: false\n
56	\N	2025-08-29 10:16:52.966427	31	Ticket	destroy	---\nid: 31\ntitle: Give Admin Permissions to more users\ndescription: 'We have given more permissions to system users '\npriority: 3\norganization_id: 2\ncreated_at: 2025-08-29 09:43:07.175779000 Z\nupdated_at: 2025-08-29 09:52:56.936655000 Z\nticket_number: REQ057HNEEU\nticket_type: Request\nassignee_id: 5\nteam_id: 3\nrequester_id: 10\nreported_at: 2025-08-29 09:41:00.000000000 Z\ncategory: Technical\ncaller_name: Tendai\ncaller_surname: Nyandoro\ncaller_email: tendain@greensoftsolutions.net\ncaller_phone: '0742591362'\ncustomer: GSS\nsource: Web\nstatus: 5\ncreator_id: 10\nresponse_due_at: 2025-09-03 06:41:00.000000000 Z\nresolution_due_at: 2025-09-10 09:41:00.000000000 Z\nescalation_level: 0\nsla_breached: false\nsla_policy_id: 4\nurgency: 2\nimpact: 2\ncalculated_priority: 3\nresolved_at: 2025-08-29 09:52:56.825891000 Z\nresolution_note: test\nsome_field:\nreason: test\nresolution_method: test\ncause_code: '000000'\nresolution_details: test\nend_customer: Logan\nsupport_center: ''\ntotal_kilometer: ''\ndepartment_id:\nbreaching_sla: false\n
57	\N	2025-08-29 10:16:53.025644	5	Ticket	destroy	---\nid: 5\ntitle: Setting up mailer\ndescription: 'Lets test email sending '\npriority: 0\norganization_id: 2\ncreated_at: 2025-08-25 10:25:35.632586000 Z\nupdated_at: 2025-08-25 10:25:35.632586000 Z\nticket_number: INCL99G4LIC\nticket_type: Incident\nassignee_id: 4\nteam_id: 2\nrequester_id:\nreported_at: 2025-08-25 10:24:00.000000000 Z\ncategory: Billing\ncaller_name: ydneT\ncaller_surname: Mouel\ncaller_email: tnyandoro@gmail.com\ncaller_phone: 072 136 2389\ncustomer: Midrand\nsource: Web\nstatus: 1\ncreator_id:\nresponse_due_at:\nresolution_due_at:\nescalation_level: 0\nsla_breached: false\nsla_policy_id:\nurgency: 2\nimpact: 2\ncalculated_priority: 3\nresolved_at:\nresolution_note:\nsome_field:\nreason:\nresolution_method:\ncause_code:\nresolution_details:\nend_customer:\nsupport_center:\ntotal_kilometer:\ndepartment_id:\nbreaching_sla: false\n
58	\N	2025-08-29 10:16:53.071958	33	Ticket	destroy	---\nid: 33\ntitle: Admin assigning tickets\ndescription: 'Lets check to see if this is now working '\npriority: 3\norganization_id: 2\ncreated_at: 2025-08-29 10:02:05.979817000 Z\nupdated_at: 2025-08-29 10:03:54.875150000 Z\nticket_number: INC68SLXGRK\nticket_type: Incident\nassignee_id:\nteam_id: 5\nrequester_id: 12\nreported_at: 2025-08-29 10:00:00.000000000 Z\ncategory: Technical\ncaller_name: Trudy\ncaller_surname: Monroe\ncaller_email: imbuk@greensoftsolutions.net\ncaller_phone: 064 326 9373\ncustomer: GSS\nsource: Web\nstatus: 5\ncreator_id: 12\nresponse_due_at: 2025-09-03 07:00:00.000000000 Z\nresolution_due_at: 2025-09-10 10:00:00.000000000 Z\nescalation_level: 0\nsla_breached: false\nsla_policy_id: 4\nurgency: 2\nimpact: 2\ncalculated_priority: 3\nresolved_at: 2025-08-29 10:03:54.747703000 Z\nresolution_note: test\nsome_field:\nreason: test\nresolution_method: web\ncause_code: '00000'\nresolution_details: test\nend_customer: Mirriam\nsupport_center: ''\ntotal_kilometer: ''\ndepartment_id:\nbreaching_sla: false\n
59	\N	2025-08-29 10:16:53.136699	10	Ticket	destroy	---\nid: 10\ntitle: Mailer\ndescription: Testing mailer\npriority: 0\norganization_id: 2\ncreated_at: 2025-08-25 11:09:33.450337000 Z\nupdated_at: 2025-08-25 11:09:33.450337000 Z\nticket_number: INC5IIH5S4B\nticket_type: Incident\nassignee_id: 4\nteam_id: 2\nrequester_id:\nreported_at: 2025-08-25 11:06:00.000000000 Z\ncategory: Technical\ncaller_name: Martha\ncaller_surname: Kent\ncaller_email: tnyandoro@gmail.com\ncaller_phone: 063 019 0641\ncustomer: GSS HQ\nsource: Web\nstatus: 1\ncreator_id:\nresponse_due_at:\nresolution_due_at:\nescalation_level: 0\nsla_breached: false\nsla_policy_id:\nurgency: 1\nimpact: 2\ncalculated_priority: 2\nresolved_at:\nresolution_note:\nsome_field:\nreason:\nresolution_method:\ncause_code:\nresolution_details:\nend_customer:\nsupport_center:\ntotal_kilometer:\ndepartment_id:\nbreaching_sla: false\n
60	\N	2025-08-29 10:16:53.206504	11	Ticket	destroy	---\nid: 11\ntitle: testing mail sent\ndescription: 'we are testing to see if our email will send '\npriority: 0\norganization_id: 2\ncreated_at: 2025-08-25 11:34:43.744899000 Z\nupdated_at: 2025-08-25 11:34:43.744899000 Z\nticket_number: INC67NJXE7L\nticket_type: Incident\nassignee_id: 4\nteam_id: 2\nrequester_id:\nreported_at: 2025-08-25 11:32:00.000000000 Z\ncategory: Technical\ncaller_name: Blessings\ncaller_surname: Matore\ncaller_email: tnyandoro@gmail.com\ncaller_phone: '0724519631'\ncustomer: GSS\nsource: Web\nstatus: 1\ncreator_id:\nresponse_due_at:\nresolution_due_at:\nescalation_level: 0\nsla_breached: false\nsla_policy_id:\nurgency: 1\nimpact: 2\ncalculated_priority: 2\nresolved_at:\nresolution_note:\nsome_field:\nreason:\nresolution_method:\ncause_code:\nresolution_details:\nend_customer:\nsupport_center:\ntotal_kilometer:\ndepartment_id:\nbreaching_sla: false\n
61	\N	2025-08-29 10:16:53.26093	25	Ticket	destroy	---\nid: 25\ntitle: Test email sent\ndescription: Test test\npriority: 1\norganization_id: 2\ncreated_at: 2025-08-26 10:56:21.916086000 Z\nupdated_at: 2025-08-26 11:53:35.633880000 Z\nticket_number: INCEE91Y6EH\nticket_type: Incident\nassignee_id: 4\nteam_id: 3\nrequester_id:\nreported_at: 2025-08-26 10:55:00.000000000 Z\ncategory: Technical\ncaller_name: Torry\ncaller_surname: Charlie\ncaller_email: tnyandoro@gmail.com\ncaller_phone: 063 0190641\ncustomer: LQ\nsource: Web\nstatus: 5\ncreator_id:\nresponse_due_at:\nresolution_due_at:\nescalation_level: 0\nsla_breached: false\nsla_policy_id:\nurgency: 1\nimpact: 1\ncalculated_priority: 1\nresolved_at: 2025-08-26 11:53:35.590336000 Z\nresolution_note: test\nsome_field:\nreason: ''\nresolution_method: ''\ncause_code: ''\nresolution_details: ''\nend_customer: ''\nsupport_center: ''\ntotal_kilometer: ''\ndepartment_id:\nbreaching_sla: false\n
62	\N	2025-08-29 10:16:53.305608	4	Ticket	destroy	---\nid: 4\ntitle: Testing mailers\ndescription: This ticket ha been create to test mailers\npriority: 0\norganization_id: 2\ncreated_at: 2025-08-25 10:07:00.064074000 Z\nupdated_at: 2025-08-25 10:07:00.064074000 Z\nticket_number: INCY05QRGDC\nticket_type: Incident\nassignee_id: 4\nteam_id: 2\nrequester_id:\nreported_at: 2025-08-25 10:05:00.000000000 Z\ncategory: Technical\ncaller_name: Becker\ncaller_surname: Courtney\ncaller_email: tnyandoro@gmail.com\ncaller_phone: 072 136 2389\ncustomer: Midrand\nsource: Web\nstatus: 1\ncreator_id:\nresponse_due_at:\nresolution_due_at:\nescalation_level: 0\nsla_breached: false\nsla_policy_id:\nurgency: 1\nimpact: 2\ncalculated_priority: 2\nresolved_at:\nresolution_note:\nsome_field:\nreason:\nresolution_method:\ncause_code:\nresolution_details:\nend_customer:\nsupport_center:\ntotal_kilometer:\ndepartment_id:\nbreaching_sla: false\n
63	\N	2025-08-29 10:16:53.348819	24	Ticket	destroy	---\nid: 24\ntitle: 'Testing if mailer is working '\ndescription: 'The ticket is to fix our mailer to see if its working '\npriority: 0\norganization_id: 2\ncreated_at: 2025-08-26 07:12:45.912538000 Z\nupdated_at: 2025-08-26 08:54:43.971314000 Z\nticket_number: INCPXIJIJG5\nticket_type: Incident\nassignee_id: 5\nteam_id: 3\nrequester_id:\nreported_at: 2025-08-26 07:11:00.000000000 Z\ncategory: Technical\ncaller_name: Tendai\ncaller_surname: Nyandoro\ncaller_email: manojar@greensoftsolutions.net\ncaller_phone: 064 197 6745\ncustomer: GSS HQ\nsource: Web\nstatus: 5\ncreator_id:\nresponse_due_at:\nresolution_due_at:\nescalation_level: 0\nsla_breached: false\nsla_policy_id:\nurgency: 2\nimpact: 2\ncalculated_priority: 3\nresolved_at: 2025-08-26 08:54:43.889700000 Z\nresolution_note: test\nsome_field:\nreason: test\nresolution_method: test\ncause_code: test\nresolution_details: test\nend_customer: test\nsupport_center: test\ntotal_kilometer: ''\ndepartment_id:\nbreaching_sla: false\n
64	\N	2025-08-29 10:16:53.395139	28	Ticket	destroy	---\nid: 28\ntitle: Check Ticket\ndescription: is this working\npriority: 1\norganization_id: 2\ncreated_at: 2025-08-28 09:24:48.869675000 Z\nupdated_at: 2025-08-28 09:29:24.704189000 Z\nticket_number: INCOM6R3O8N\nticket_type: Incident\nassignee_id: 7\nteam_id: 4\nrequester_id:\nreported_at: 2025-08-28 09:23:00.000000000 Z\ncategory: Technical\ncaller_name: Becker\ncaller_surname: Brooks\ncaller_email: vibham@greensoftsolutions.net\ncaller_phone: 063 0190873\ncustomer: GSS\nsource: Web\nstatus: 5\ncreator_id:\nresponse_due_at:\nresolution_due_at:\nescalation_level: 0\nsla_breached: false\nsla_policy_id:\nurgency: 1\nimpact: 1\ncalculated_priority: 1\nresolved_at: 2025-08-28 09:29:24.653044000 Z\nresolution_note: |-\n  Neque porro quisquam est qui dolorem ipsum quia dolor sit amet, consectetur, adipisci velit..."\n  "There is no one who loves pain itself, who seeks after it and wants to have it, simply because it is pain..\nsome_field:\nreason: Neque porro quisquam est qui dolorem ipsum quia dolor sit amet, consectetur,\n  adipisci velit..." "There is no one who loves pain itself, who seeks after it and\n  wants to have it, simply because it is pain..\nresolution_method: Neque porro quisquam est qui dolorem ipsum quia dolor sit amet,\n  consectetur, adipisci velit..." "There is no one who loves pain itself, who seeks\n  after it and wants to have it, simply because it is pain..\ncause_code: '00000'\nresolution_details: |-\n  Neque porro quisquam est qui dolorem ipsum quia dolor sit amet, consectetur, adipisci velit..."\n  "There is no one who loves pain itself, who seeks after it and wants to have it, simply because it is pain..\nend_customer: Mike\nsupport_center: ''\ntotal_kilometer: ''\ndepartment_id:\nbreaching_sla: false\n
65	\N	2025-08-29 10:16:53.439899	21	Ticket	destroy	---\nid: 21\ntitle: Test email sent\ndescription: 'Send email to '\npriority: 0\norganization_id: 2\ncreated_at: 2025-08-25 14:15:54.249982000 Z\nupdated_at: 2025-08-25 14:15:54.249982000 Z\nticket_number: INCYEL4Z9TU\nticket_type: Incident\nassignee_id:\nteam_id: 2\nrequester_id:\nreported_at: 2025-08-25 14:15:00.000000000 Z\ncategory: Technical\ncaller_name: Becker\ncaller_surname: Boots\ncaller_email: tendai1@hotmail.com\ncaller_phone: '0630190641'\ncustomer: LQ\nsource: Web\nstatus: 0\ncreator_id:\nresponse_due_at:\nresolution_due_at:\nescalation_level: 0\nsla_breached: false\nsla_policy_id:\nurgency: 1\nimpact: 1\ncalculated_priority: 1\nresolved_at:\nresolution_note:\nsome_field:\nreason:\nresolution_method:\ncause_code:\nresolution_details:\nend_customer:\nsupport_center:\ntotal_kilometer:\ndepartment_id:\nbreaching_sla: false\n
66	\N	2025-08-29 10:16:53.483045	12	Ticket	destroy	---\nid: 12\ntitle: Test email sent\ndescription: We need to send email to assignee\npriority: 0\norganization_id: 2\ncreated_at: 2025-08-25 12:20:50.187525000 Z\nupdated_at: 2025-08-25 12:20:50.187525000 Z\nticket_number: INCO3V7D5YK\nticket_type: Incident\nassignee_id: 4\nteam_id: 2\nrequester_id:\nreported_at: 2025-08-25 12:19:00.000000000 Z\ncategory: Technical\ncaller_name: Llyod\ncaller_surname: Napata\ncaller_email: tnyandoro@gmail.com\ncaller_phone: '0630190641'\ncustomer: LQ\nsource: Web\nstatus: 1\ncreator_id:\nresponse_due_at:\nresolution_due_at:\nescalation_level: 0\nsla_breached: false\nsla_policy_id:\nurgency: 1\nimpact: 2\ncalculated_priority: 2\nresolved_at:\nresolution_note:\nsome_field:\nreason:\nresolution_method:\ncause_code:\nresolution_details:\nend_customer:\nsupport_center:\ntotal_kilometer:\ndepartment_id:\nbreaching_sla: false\n
67	\N	2025-08-29 10:16:53.556942	15	Ticket	destroy	---\nid: 15\ntitle: Test email sent\ndescription: test test\npriority: 0\norganization_id: 2\ncreated_at: 2025-08-25 12:53:53.897294000 Z\nupdated_at: 2025-08-25 12:53:53.897294000 Z\nticket_number: INC7XVYZ0QU\nticket_type: Incident\nassignee_id: 4\nteam_id: 2\nrequester_id:\nreported_at: 2025-08-25 12:53:00.000000000 Z\ncategory: Technical\ncaller_name: Becker\ncaller_surname: Tindo\ncaller_email: tendai1@hotmail.com\ncaller_phone: '0630190641'\ncustomer: LQ\nsource: Web\nstatus: 1\ncreator_id:\nresponse_due_at:\nresolution_due_at:\nescalation_level: 0\nsla_breached: false\nsla_policy_id:\nurgency: 1\nimpact: 1\ncalculated_priority: 1\nresolved_at:\nresolution_note:\nsome_field:\nreason:\nresolution_method:\ncause_code:\nresolution_details:\nend_customer:\nsupport_center:\ntotal_kilometer:\ndepartment_id:\nbreaching_sla: false\n
68	\N	2025-08-29 10:16:53.622173	29	Ticket	destroy	---\nid: 29\ntitle: Lets test sending email from the app\ndescription: test test\npriority: 2\norganization_id: 2\ncreated_at: 2025-08-28 11:33:31.148008000 Z\nupdated_at: 2025-08-28 11:34:14.143413000 Z\nticket_number: INCSBL7799V\nticket_type: Incident\nassignee_id: 4\nteam_id: 4\nrequester_id:\nreported_at: 2025-08-28 11:32:00.000000000 Z\ncategory: Technical\ncaller_name: Becker\ncaller_surname: Man\ncaller_email: tendai@bluesoft.com\ncaller_phone: 063 0190873\ncustomer: GSS\nsource: Web\nstatus: 5\ncreator_id:\nresponse_due_at:\nresolution_due_at:\nescalation_level: 0\nsla_breached: false\nsla_policy_id:\nurgency: 1\nimpact: 2\ncalculated_priority: 2\nresolved_at: 2025-08-28 11:34:14.097217000 Z\nresolution_note: |-\n  development:\n    adapter: async\n\n  test:\n    adapter: test\nsome_field:\nreason: Neque porro quisquam est qui dolorem ipsum quia dolor sit amet, consectetur,\n  adipisci velit..." "There is no one who loves pain itself, who seeks after it and\n  wants to have it, simply because it is pain..\nresolution_method: Neque porro quisquam est qui dolorem ipsum quia dolor sit amet,\n  consectetur, adipisci velit..." "There is no one who loves pain itself, who seeks\n  after it and wants to have it, simply because it is pain..\ncause_code: Neque porro quisquam est qui dolorem ipsum quia dolor sit amet, consectetur,\n  adipisci velit..." "There is no one who loves pain itself, who seeks after it and\n  wants to have it, simply because it is pain..\nresolution_details: |-\n  development:\n    adapter: async\n\n  test:\n    adapter: test\nend_customer: betty\nsupport_center: ''\ntotal_kilometer: ''\ndepartment_id:\nbreaching_sla: false\n
69	\N	2025-08-29 10:16:53.666329	32	Ticket	destroy	---\nid: 32\ntitle: Let add more permissions\ndescription: 'We want to see if we can now create more tickets:'\npriority: 3\norganization_id: 2\ncreated_at: 2025-08-29 09:44:58.781165000 Z\nupdated_at: 2025-08-29 09:44:59.072425000 Z\nticket_number: PRBPLMBD5XG\nticket_type: Problem\nassignee_id: 4\nteam_id: 4\nrequester_id: 10\nreported_at: 2025-08-29 09:43:00.000000000 Z\ncategory: Technical\ncaller_name: Tendai\ncaller_surname: Pine\ncaller_email: tendain@greensoftsolutions.net\ncaller_phone: '0742591362'\ncustomer: GSS\nsource: Web\nstatus: 1\ncreator_id: 10\nresponse_due_at: 2025-09-03 06:43:00.000000000 Z\nresolution_due_at: 2025-09-10 09:43:00.000000000 Z\nescalation_level: 0\nsla_breached: false\nsla_policy_id: 4\nurgency: 2\nimpact: 2\ncalculated_priority: 3\nresolved_at:\nresolution_note:\nsome_field:\nreason:\nresolution_method:\ncause_code:\nresolution_details:\nend_customer:\nsupport_center:\ntotal_kilometer:\ndepartment_id:\nbreaching_sla: false\n
70	\N	2025-08-29 10:30:23.14373	34	Ticket	create	\N
71	\N	2025-08-29 10:30:23.725887	34	Ticket	update	---\nid: 34\ntitle: We can create tickets and send mail\ndescription: We can create tickets and send a notification to the assignee\npriority: 0\norganization_id: 2\ncreated_at: 2025-08-29 10:30:23.143730000 Z\nupdated_at: 2025-08-29 10:30:23.143730000 Z\nticket_number: INCQXBFGI5P\nticket_type: Incident\nassignee_id: 7\nteam_id: 4\nrequester_id: 10\nreported_at: 2025-08-29 10:29:00.000000000 Z\ncategory: Technical\ncaller_name: Tendai\ncaller_surname: Mike\ncaller_email: tendain@greensoftsolutions.net\ncaller_phone: '0742591362'\ncustomer: GSS\nsource: Web\nstatus: 1\ncreator_id: 10\nresponse_due_at:\nresolution_due_at:\nescalation_level: 0\nsla_breached: false\nsla_policy_id:\nurgency: 2\nimpact: 2\ncalculated_priority: 3\nresolved_at:\nresolution_note:\nsome_field:\nreason:\nresolution_method:\ncause_code:\nresolution_details:\nend_customer:\nsupport_center:\ntotal_kilometer:\ndepartment_id:\nbreaching_sla: false\n
73	\N	2025-08-29 10:44:02.797455	35	Ticket	update	---\nid: 35\ntitle: Admin assigning tickets\ndescription: Testing our ticket creation\npriority: 0\norganization_id: 2\ncreated_at: 2025-08-29 10:44:02.241659000 Z\nupdated_at: 2025-08-29 10:44:02.241659000 Z\nticket_number: INCOYXYKTCW\nticket_type: Incident\nassignee_id: 12\nteam_id: 6\nrequester_id: 10\nreported_at: 2025-08-29 10:43:00.000000000 Z\ncategory: Technical\ncaller_name: Tendai\ncaller_surname: Monroe\ncaller_email: tendain@greensoftsolutions.net\ncaller_phone: '0742591362'\ncustomer: GSS\nsource: Web\nstatus: 1\ncreator_id: 10\nresponse_due_at:\nresolution_due_at:\nescalation_level: 0\nsla_breached: false\nsla_policy_id:\nurgency: 2\nimpact: 2\ncalculated_priority: 3\nresolved_at:\nresolution_note:\nsome_field:\nreason:\nresolution_method:\ncause_code:\nresolution_details:\nend_customer:\nsupport_center:\ntotal_kilometer:\ndepartment_id:\nbreaching_sla: false\n
74	\N	2025-08-29 10:51:07.861615	36	Ticket	create	\N
75	\N	2025-08-29 10:51:08.535867	36	Ticket	update	---\nid: 36\ntitle: Tracking Tickets\ndescription: 'We want to see if all can see the tickets '\npriority: 0\norganization_id: 2\ncreated_at: 2025-08-29 10:51:07.861615000 Z\nupdated_at: 2025-08-29 10:51:07.861615000 Z\nticket_number: INCUUSVC0Z0\nticket_type: Incident\nassignee_id: 12\nteam_id: 6\nrequester_id: 10\nreported_at: 2025-08-29 10:50:00.000000000 Z\ncategory: Technical\ncaller_name: Tendai\ncaller_surname: Muttom\ncaller_email: tendain@greensoftsolutions.net\ncaller_phone: '0742591362'\ncustomer: Mpumalanga\nsource: Web\nstatus: 1\ncreator_id: 10\nresponse_due_at:\nresolution_due_at:\nescalation_level: 0\nsla_breached: false\nsla_policy_id:\nurgency: 2\nimpact: 2\ncalculated_priority: 3\nresolved_at:\nresolution_note:\nsome_field:\nreason:\nresolution_method:\ncause_code:\nresolution_details:\nend_customer:\nsupport_center:\ntotal_kilometer:\ndepartment_id:\nbreaching_sla: false\n
76	\N	2025-08-29 11:17:15.932333	37	Ticket	create	\N
77	\N	2025-08-29 11:17:16.377451	37	Ticket	update	---\nid: 37\ntitle: Testing tickets\ndescription: 'test test test '\npriority: 0\norganization_id: 2\ncreated_at: 2025-08-29 11:17:15.932333000 Z\nupdated_at: 2025-08-29 11:17:15.932333000 Z\nticket_number: INCEUOP0O5W\nticket_type: Incident\nassignee_id: 10\nteam_id: 6\nrequester_id: 7\nreported_at: 2025-08-29 11:16:00.000000000 Z\ncategory: Technical\ncaller_name: Vibha\ncaller_surname: m\ncaller_email: vibham@greensoftsolutions.net\ncaller_phone: '0100355568'\ncustomer: Johannesburg\nsource: Web\nstatus: 1\ncreator_id: 7\nresponse_due_at:\nresolution_due_at:\nescalation_level: 0\nsla_breached: false\nsla_policy_id:\nurgency: 1\nimpact: 1\ncalculated_priority: 1\nresolved_at:\nresolution_note:\nsome_field:\nreason:\nresolution_method:\ncause_code:\nresolution_details:\nend_customer:\nsupport_center:\ntotal_kilometer:\ndepartment_id:\nbreaching_sla: false\n
78	\N	2025-08-29 11:28:51.449202	38	Ticket	create	\N
79	\N	2025-08-29 11:28:51.804044	38	Ticket	update	---\nid: 38\ntitle: OTP is Failing\ndescription: We are unable to receive my opt when trying to update my company registration\npriority: 0\norganization_id: 2\ncreated_at: 2025-08-29 11:28:51.449202000 Z\nupdated_at: 2025-08-29 11:28:51.449202000 Z\nticket_number: INC14TNK8LI\nticket_type: Incident\nassignee_id: 5\nteam_id: 6\nrequester_id: 7\nreported_at: 2025-08-29 11:25:00.000000000 Z\ncategory: Technical\ncaller_name: Trudie\ncaller_surname: mk\ncaller_email: vibham@greensoftsolutions.net\ncaller_phone: '0100355568'\ncustomer: GSS HQ\nsource: Web\nstatus: 1\ncreator_id: 7\nresponse_due_at:\nresolution_due_at:\nescalation_level: 0\nsla_breached: false\nsla_policy_id:\nurgency: 2\nimpact: 2\ncalculated_priority: 3\nresolved_at:\nresolution_note:\nsome_field:\nreason:\nresolution_method:\ncause_code:\nresolution_details:\nend_customer:\nsupport_center:\ntotal_kilometer:\ndepartment_id:\nbreaching_sla: false\n
80	\N	2025-08-29 11:36:10.44791	39	Ticket	create	\N
81	\N	2025-08-29 11:36:10.675159	39	Ticket	update	---\nid: 39\ntitle: Admin assigning tickets\ndescription: 'My Login details are not working '\npriority: 0\norganization_id: 2\ncreated_at: 2025-08-29 11:36:10.447910000 Z\nupdated_at: 2025-08-29 11:36:10.447910000 Z\nticket_number: INCSDNKMX0N\nticket_type: Incident\nassignee_id: 11\nteam_id: 6\nrequester_id: 7\nreported_at: 2025-08-29 11:33:00.000000000 Z\ncategory: Technical\ncaller_name: Dilip\ncaller_surname: Monroe\ncaller_email: rajava.manoja@gmail.com\ncaller_phone: '0100355568'\ncustomer: GSS\nsource: Web\nstatus: 1\ncreator_id: 7\nresponse_due_at:\nresolution_due_at:\nescalation_level: 0\nsla_breached: false\nsla_policy_id:\nurgency: 1\nimpact: 1\ncalculated_priority: 1\nresolved_at:\nresolution_note:\nsome_field:\nreason:\nresolution_method:\ncause_code:\nresolution_details:\nend_customer:\nsupport_center:\ntotal_kilometer:\ndepartment_id:\nbreaching_sla: false\n
82	\N	2025-08-29 15:38:09.444063	40	Ticket	create	\N
83	\N	2025-08-29 15:38:11.01672	40	Ticket	update	---\nid: 40\ntitle: I need some help\ndescription: We need help with registering our intellectual property\npriority: 0\norganization_id: 2\ncreated_at: 2025-08-29 15:38:09.444063000 Z\nupdated_at: 2025-08-29 15:38:09.444063000 Z\nticket_number: INCZYC673PV\nticket_type: Incident\nassignee_id: 4\nteam_id: 6\nrequester_id: 10\nreported_at: 2025-08-29 15:33:00.000000000 Z\ncategory: Technical\ncaller_name: Bob\ncaller_surname: Uncle\ncaller_email: bobuncle@example.com\ncaller_phone: '0742591362'\ncustomer: GSShq\nsource: Web\nstatus: 1\ncreator_id: 10\nresponse_due_at:\nresolution_due_at:\nescalation_level: 0\nsla_breached: false\nsla_policy_id:\nurgency: 2\nimpact: 2\ncalculated_priority: 3\nresolved_at:\nresolution_note:\nsome_field:\nreason:\nresolution_method:\ncause_code:\nresolution_details:\nend_customer:\nsupport_center:\ntotal_kilometer:\ndepartment_id:\nbreaching_sla: false\n
84	\N	2025-08-29 15:41:06.956722	41	Ticket	create	\N
85	\N	2025-08-29 15:41:07.180871	41	Ticket	update	---\nid: 41\ntitle: Ticket without an assignee\ndescription: We want to reassign this ticket\npriority: 0\norganization_id: 2\ncreated_at: 2025-08-29 15:41:06.956722000 Z\nupdated_at: 2025-08-29 15:41:06.956722000 Z\nticket_number: INCL75KA45P\nticket_type: Incident\nassignee_id:\nteam_id: 4\nrequester_id: 10\nreported_at: 2025-08-29 15:39:00.000000000 Z\ncategory: Technical\ncaller_name: Tendai\ncaller_surname: Monroe\ncaller_email: tendain@greensoftsolutions.net\ncaller_phone: '0742591362'\ncustomer: Gss\nsource: Web\nstatus: 0\ncreator_id: 10\nresponse_due_at:\nresolution_due_at:\nescalation_level: 0\nsla_breached: false\nsla_policy_id:\nurgency: 1\nimpact: 1\ncalculated_priority: 1\nresolved_at:\nresolution_note:\nsome_field:\nreason:\nresolution_method:\ncause_code:\nresolution_details:\nend_customer:\nsupport_center:\ntotal_kilometer:\ndepartment_id:\nbreaching_sla: false\n
86	\N	2025-08-29 15:43:11.767585	40	Ticket	update	---\norganization_id: 2\nstatus: 1\nresolution_note:\nreason:\nresolution_method:\ncause_code:\nresolution_details:\nend_customer:\nsupport_center:\ntotal_kilometer:\nresolved_at:\npriority: 3\ncreator_id: 10\nrequester_id: 10\nticket_number: INCZYC673PV\ncalculated_priority: 3\nid: 40\ntitle: I need some help\ndescription: We need help with registering our intellectual property\ncreated_at: 2025-08-29 15:38:09.444063000 Z\nupdated_at: 2025-08-29 15:38:11.016720000 Z\nticket_type: Incident\nassignee_id: 4\nteam_id: 6\nreported_at: 2025-08-29 15:33:00.000000000 Z\ncategory: Technical\ncaller_name: Bob\ncaller_surname: Uncle\ncaller_email: bobuncle@example.com\ncaller_phone: '0742591362'\ncustomer: GSShq\nsource: Web\nresponse_due_at: 2025-09-03 12:00:00.000000000 Z\nresolution_due_at: 2025-09-10 15:00:00.000000000 Z\nescalation_level: 0\nsla_breached: false\nsla_policy_id: 4\nurgency: 2\nimpact: 2\nsome_field:\ndepartment_id:\nbreaching_sla: false\n
87	\N	2025-08-30 06:42:09.388244	42	Ticket	create	\N
88	\N	2025-08-30 06:42:10.705397	42	Ticket	update	---\nid: 42\ntitle: Soft Deletions\ndescription: 'Lets fix deletion for teams '\npriority: 0\norganization_id: 2\ncreated_at: 2025-08-30 06:42:09.388244000 Z\nupdated_at: 2025-08-30 06:42:09.388244000 Z\nticket_number: INCXR7T8KWC\nticket_type: Incident\nassignee_id: 10\nteam_id: 6\nrequester_id: 10\nreported_at: 2025-08-30 06:40:00.000000000 Z\ncategory: Technical\ncaller_name: Tendai\ncaller_surname: Dohwe\ncaller_email: tendain@greensoftsolutions.net\ncaller_phone: '0742591362'\ncustomer: HQGSS\nsource: Web\nstatus: 1\ncreator_id: 10\nresponse_due_at:\nresolution_due_at:\nescalation_level: 0\nsla_breached: false\nsla_policy_id:\nurgency: 2\nimpact: 2\ncalculated_priority: 3\nresolved_at:\nresolution_note:\nsome_field:\nreason:\nresolution_method:\ncause_code:\nresolution_details:\nend_customer:\nsupport_center:\ntotal_kilometer:\ndepartment_id:\nbreaching_sla: false\n
89	\N	2025-08-30 06:43:37.305445	42	Ticket	update	---\norganization_id: 2\nstatus: 1\nresolution_note:\nreason:\nresolution_method:\ncause_code:\nresolution_details:\nend_customer:\nsupport_center:\ntotal_kilometer:\nresolved_at:\npriority: 3\ncreator_id: 10\nrequester_id: 10\nticket_number: INCXR7T8KWC\ncalculated_priority: 3\nid: 42\ntitle: Soft Deletions\ndescription: 'Lets fix deletion for teams '\ncreated_at: 2025-08-30 06:42:09.388244000 Z\nupdated_at: 2025-08-30 06:42:10.705397000 Z\nticket_type: Incident\nassignee_id: 10\nteam_id: 6\nreported_at: 2025-08-30 06:40:00.000000000 Z\ncategory: Technical\ncaller_name: Tendai\ncaller_surname: Dohwe\ncaller_email: tendain@greensoftsolutions.net\ncaller_phone: '0742591362'\ncustomer: HQGSS\nsource: Web\nresponse_due_at: 2025-09-03 12:00:00.000000000 Z\nresolution_due_at: 2025-09-10 15:00:00.000000000 Z\nescalation_level: 0\nsla_breached: false\nsla_policy_id: 4\nurgency: 2\nimpact: 2\nsome_field:\ndepartment_id:\nbreaching_sla: false\n
90	\N	2025-08-30 08:29:38.351232	43	Ticket	create	\N
91	\N	2025-08-30 08:29:38.97988	43	Ticket	update	---\nid: 43\ntitle: Adding an attachment\ndescription: We need to test an attachment\npriority: 0\norganization_id: 2\ncreated_at: 2025-08-30 08:29:38.351232000 Z\nupdated_at: 2025-08-30 08:29:38.351232000 Z\nticket_number: INCJMBZCQBP\nticket_type: Incident\nassignee_id:\nteam_id: 6\nrequester_id: 10\nreported_at: 2025-08-30 08:23:00.000000000 Z\ncategory: Technical\ncaller_name: Test\ncaller_surname: Tendai\ncaller_email: tendain@greensoftsolutions.net\ncaller_phone: '0742591362'\ncustomer: Midrand\nsource: Web\nstatus: 0\ncreator_id: 10\nresponse_due_at:\nresolution_due_at:\nescalation_level: 0\nsla_breached: false\nsla_policy_id:\nurgency: 1\nimpact: 2\ncalculated_priority: 2\nresolved_at:\nresolution_note:\nsome_field:\nreason:\nresolution_method:\ncause_code:\nresolution_details:\nend_customer:\nsupport_center:\ntotal_kilometer:\ndepartment_id:\nbreaching_sla: false\n
92	\N	2025-08-30 08:29:39.475775	43	Ticket	update	---\nid: 43\ntitle: Adding an attachment\ndescription: We need to test an attachment\npriority: 2\norganization_id: 2\ncreated_at: 2025-08-30 08:29:38.351232000 Z\nupdated_at: 2025-08-30 08:29:39.475775000 Z\nticket_number: INCJMBZCQBP\nticket_type: Incident\nassignee_id:\nteam_id: 6\nrequester_id: 10\nreported_at: 2025-08-30 08:23:00.000000000 Z\ncategory: Technical\ncaller_name: Test\ncaller_surname: Tendai\ncaller_email: tendain@greensoftsolutions.net\ncaller_phone: '0742591362'\ncustomer: Midrand\nsource: Web\nstatus: 0\ncreator_id: 10\nresponse_due_at: 2025-09-03 12:00:00.000000000 Z\nresolution_due_at: 2025-09-10 15:00:00.000000000 Z\nescalation_level: 0\nsla_breached: false\nsla_policy_id: 4\nurgency: 1\nimpact: 2\ncalculated_priority: 2\nresolved_at:\nresolution_note:\nsome_field:\nreason:\nresolution_method:\ncause_code:\nresolution_details:\nend_customer:\nsupport_center:\ntotal_kilometer:\ndepartment_id:\nbreaching_sla: false\n
93	\N	2025-08-30 08:29:39.636278	43	Ticket	update	---\nid: 43\ntitle: Adding an attachment\ndescription: We need to test an attachment\npriority: 2\norganization_id: 2\ncreated_at: 2025-08-30 08:29:38.351232000 Z\nupdated_at: 2025-08-30 08:29:39.636278000 Z\nticket_number: INCJMBZCQBP\nticket_type: Incident\nassignee_id:\nteam_id: 6\nrequester_id: 10\nreported_at: 2025-08-30 08:23:00.000000000 Z\ncategory: Technical\ncaller_name: Test\ncaller_surname: Tendai\ncaller_email: tendain@greensoftsolutions.net\ncaller_phone: '0742591362'\ncustomer: Midrand\nsource: Web\nstatus: 0\ncreator_id: 10\nresponse_due_at: 2025-09-03 12:00:00.000000000 Z\nresolution_due_at: 2025-09-10 15:00:00.000000000 Z\nescalation_level: 0\nsla_breached: false\nsla_policy_id: 4\nurgency: 1\nimpact: 2\ncalculated_priority: 2\nresolved_at:\nresolution_note:\nsome_field:\nreason:\nresolution_method:\ncause_code:\nresolution_details:\nend_customer:\nsupport_center:\ntotal_kilometer:\ndepartment_id:\nbreaching_sla: false\n
94	\N	2025-08-30 08:29:40.12202	43	Ticket	update	---\nid: 43\ntitle: Adding an attachment\ndescription: We need to test an attachment\npriority: 2\norganization_id: 2\ncreated_at: 2025-08-30 08:29:38.351232000 Z\nupdated_at: 2025-08-30 08:29:40.122020000 Z\nticket_number: INCJMBZCQBP\nticket_type: Incident\nassignee_id:\nteam_id: 6\nrequester_id: 10\nreported_at: 2025-08-30 08:23:00.000000000 Z\ncategory: Technical\ncaller_name: Test\ncaller_surname: Tendai\ncaller_email: tendain@greensoftsolutions.net\ncaller_phone: '0742591362'\ncustomer: Midrand\nsource: Web\nstatus: 0\ncreator_id: 10\nresponse_due_at: 2025-09-03 12:00:00.000000000 Z\nresolution_due_at: 2025-09-10 15:00:00.000000000 Z\nescalation_level: 0\nsla_breached: false\nsla_policy_id: 4\nurgency: 1\nimpact: 2\ncalculated_priority: 2\nresolved_at:\nresolution_note:\nsome_field:\nreason:\nresolution_method:\ncause_code:\nresolution_details:\nend_customer:\nsupport_center:\ntotal_kilometer:\ndepartment_id:\nbreaching_sla: false\n
95	\N	2025-08-30 08:29:41.230205	43	Ticket	update	---\nid: 43\ntitle: Adding an attachment\ndescription: We need to test an attachment\npriority: 2\norganization_id: 2\ncreated_at: 2025-08-30 08:29:38.351232000 Z\nupdated_at: 2025-08-30 08:29:41.230205000 Z\nticket_number: INCJMBZCQBP\nticket_type: Incident\nassignee_id:\nteam_id: 6\nrequester_id: 10\nreported_at: 2025-08-30 08:23:00.000000000 Z\ncategory: Technical\ncaller_name: Test\ncaller_surname: Tendai\ncaller_email: tendain@greensoftsolutions.net\ncaller_phone: '0742591362'\ncustomer: Midrand\nsource: Web\nstatus: 0\ncreator_id: 10\nresponse_due_at: 2025-09-03 12:00:00.000000000 Z\nresolution_due_at: 2025-09-10 15:00:00.000000000 Z\nescalation_level: 0\nsla_breached: false\nsla_policy_id: 4\nurgency: 1\nimpact: 2\ncalculated_priority: 2\nresolved_at:\nresolution_note:\nsome_field:\nreason:\nresolution_method:\ncause_code:\nresolution_details:\nend_customer:\nsupport_center:\ntotal_kilometer:\ndepartment_id:\nbreaching_sla: false\n
96	\N	2025-08-30 11:18:02.332823	44	Ticket	create	\N
97	\N	2025-08-30 11:18:03.013814	44	Ticket	update	---\nid: 44\ntitle: Testing more attachments\ndescription: Let test the attachments\npriority: 0\norganization_id: 2\ncreated_at: 2025-08-30 11:18:02.332823000 Z\nupdated_at: 2025-08-30 11:18:02.332823000 Z\nticket_number: INCOV4RFU4M\nticket_type: Incident\nassignee_id: 10\nteam_id: 6\nrequester_id: 10\nreported_at: 2025-08-30 11:16:00.000000000 Z\ncategory: Other\ncaller_name: Courtney\ncaller_surname: Gabriella\ncaller_email: tendain@greensoftsolutions.net\ncaller_phone: '0742591362'\ncustomer: GSS hed\nsource: Web\nstatus: 1\ncreator_id: 10\nresponse_due_at:\nresolution_due_at:\nescalation_level: 0\nsla_breached: false\nsla_policy_id:\nurgency: 2\nimpact: 2\ncalculated_priority: 3\nresolved_at:\nresolution_note:\nsome_field:\nreason:\nresolution_method:\ncause_code:\nresolution_details:\nend_customer:\nsupport_center:\ntotal_kilometer:\ndepartment_id:\nbreaching_sla: false\n
98	\N	2025-08-30 11:18:03.147194	44	Ticket	update	---\nid: 44\ntitle: Testing more attachments\ndescription: Let test the attachments\npriority: 3\norganization_id: 2\ncreated_at: 2025-08-30 11:18:02.332823000 Z\nupdated_at: 2025-08-30 11:18:03.147194000 Z\nticket_number: INCOV4RFU4M\nticket_type: Incident\nassignee_id: 10\nteam_id: 6\nrequester_id: 10\nreported_at: 2025-08-30 11:16:00.000000000 Z\ncategory: Other\ncaller_name: Courtney\ncaller_surname: Gabriella\ncaller_email: tendain@greensoftsolutions.net\ncaller_phone: '0742591362'\ncustomer: GSS hed\nsource: Web\nstatus: 1\ncreator_id: 10\nresponse_due_at: 2025-09-03 12:00:00.000000000 Z\nresolution_due_at: 2025-09-10 15:00:00.000000000 Z\nescalation_level: 0\nsla_breached: false\nsla_policy_id: 4\nurgency: 2\nimpact: 2\ncalculated_priority: 3\nresolved_at:\nresolution_note:\nsome_field:\nreason:\nresolution_method:\ncause_code:\nresolution_details:\nend_customer:\nsupport_center:\ntotal_kilometer:\ndepartment_id:\nbreaching_sla: false\n
99	\N	2025-08-30 11:18:03.25392	44	Ticket	update	---\nid: 44\ntitle: Testing more attachments\ndescription: Let test the attachments\npriority: 3\norganization_id: 2\ncreated_at: 2025-08-30 11:18:02.332823000 Z\nupdated_at: 2025-08-30 11:18:03.253920000 Z\nticket_number: INCOV4RFU4M\nticket_type: Incident\nassignee_id: 10\nteam_id: 6\nrequester_id: 10\nreported_at: 2025-08-30 11:16:00.000000000 Z\ncategory: Other\ncaller_name: Courtney\ncaller_surname: Gabriella\ncaller_email: tendain@greensoftsolutions.net\ncaller_phone: '0742591362'\ncustomer: GSS hed\nsource: Web\nstatus: 1\ncreator_id: 10\nresponse_due_at: 2025-09-03 12:00:00.000000000 Z\nresolution_due_at: 2025-09-10 15:00:00.000000000 Z\nescalation_level: 0\nsla_breached: false\nsla_policy_id: 4\nurgency: 2\nimpact: 2\ncalculated_priority: 3\nresolved_at:\nresolution_note:\nsome_field:\nreason:\nresolution_method:\ncause_code:\nresolution_details:\nend_customer:\nsupport_center:\ntotal_kilometer:\ndepartment_id:\nbreaching_sla: false\n
100	\N	2025-08-30 11:18:03.487524	44	Ticket	update	---\nid: 44\ntitle: Testing more attachments\ndescription: Let test the attachments\npriority: 3\norganization_id: 2\ncreated_at: 2025-08-30 11:18:02.332823000 Z\nupdated_at: 2025-08-30 11:18:03.487524000 Z\nticket_number: INCOV4RFU4M\nticket_type: Incident\nassignee_id: 10\nteam_id: 6\nrequester_id: 10\nreported_at: 2025-08-30 11:16:00.000000000 Z\ncategory: Other\ncaller_name: Courtney\ncaller_surname: Gabriella\ncaller_email: tendain@greensoftsolutions.net\ncaller_phone: '0742591362'\ncustomer: GSS hed\nsource: Web\nstatus: 1\ncreator_id: 10\nresponse_due_at: 2025-09-03 12:00:00.000000000 Z\nresolution_due_at: 2025-09-10 15:00:00.000000000 Z\nescalation_level: 0\nsla_breached: false\nsla_policy_id: 4\nurgency: 2\nimpact: 2\ncalculated_priority: 3\nresolved_at:\nresolution_note:\nsome_field:\nreason:\nresolution_method:\ncause_code:\nresolution_details:\nend_customer:\nsupport_center:\ntotal_kilometer:\ndepartment_id:\nbreaching_sla: false\n
101	\N	2025-08-30 11:18:03.726323	44	Ticket	update	---\nid: 44\ntitle: Testing more attachments\ndescription: Let test the attachments\npriority: 3\norganization_id: 2\ncreated_at: 2025-08-30 11:18:02.332823000 Z\nupdated_at: 2025-08-30 11:18:03.726323000 Z\nticket_number: INCOV4RFU4M\nticket_type: Incident\nassignee_id: 10\nteam_id: 6\nrequester_id: 10\nreported_at: 2025-08-30 11:16:00.000000000 Z\ncategory: Other\ncaller_name: Courtney\ncaller_surname: Gabriella\ncaller_email: tendain@greensoftsolutions.net\ncaller_phone: '0742591362'\ncustomer: GSS hed\nsource: Web\nstatus: 1\ncreator_id: 10\nresponse_due_at: 2025-09-03 12:00:00.000000000 Z\nresolution_due_at: 2025-09-10 15:00:00.000000000 Z\nescalation_level: 0\nsla_breached: false\nsla_policy_id: 4\nurgency: 2\nimpact: 2\ncalculated_priority: 3\nresolved_at:\nresolution_note:\nsome_field:\nreason:\nresolution_method:\ncause_code:\nresolution_details:\nend_customer:\nsupport_center:\ntotal_kilometer:\ndepartment_id:\nbreaching_sla: false\n
102	\N	2025-08-30 12:55:14.868416	45	Ticket	create	\N
103	\N	2025-08-30 12:55:15.479337	45	Ticket	update	---\nid: 45\ntitle: 'Attaching a pdf '\ndescription: We are testing to see if we can attach a pdf to a created ticket\npriority: 0\norganization_id: 2\ncreated_at: 2025-08-30 12:55:14.868416000 Z\nupdated_at: 2025-08-30 12:55:14.868416000 Z\nticket_number: INC9OOEJ4RV\nticket_type: Incident\nassignee_id: 10\nteam_id: 6\nrequester_id: 10\nreported_at: 2025-08-30 12:53:00.000000000 Z\ncategory: Technical\ncaller_name: Sharmaine\ncaller_surname: Dillian\ncaller_email: tendain@greensoftsolutions.net\ncaller_phone: '0742591362'\ncustomer: Midrand\nsource: Web\nstatus: 1\ncreator_id: 10\nresponse_due_at:\nresolution_due_at:\nescalation_level: 0\nsla_breached: false\nsla_policy_id:\nurgency: 1\nimpact: 1\ncalculated_priority: 1\nresolved_at:\nresolution_note:\nsome_field:\nreason:\nresolution_method:\ncause_code:\nresolution_details:\nend_customer:\nsupport_center:\ntotal_kilometer:\ndepartment_id:\nbreaching_sla: false\n
104	\N	2025-08-30 12:55:15.543952	45	Ticket	update	---\nid: 45\ntitle: 'Attaching a pdf '\ndescription: We are testing to see if we can attach a pdf to a created ticket\npriority: 1\norganization_id: 2\ncreated_at: 2025-08-30 12:55:14.868416000 Z\nupdated_at: 2025-08-30 12:55:15.543952000 Z\nticket_number: INC9OOEJ4RV\nticket_type: Incident\nassignee_id: 10\nteam_id: 6\nrequester_id: 10\nreported_at: 2025-08-30 12:53:00.000000000 Z\ncategory: Technical\ncaller_name: Sharmaine\ncaller_surname: Dillian\ncaller_email: tendain@greensoftsolutions.net\ncaller_phone: '0742591362'\ncustomer: Midrand\nsource: Web\nstatus: 1\ncreator_id: 10\nresponse_due_at: 2025-09-03 12:00:00.000000000 Z\nresolution_due_at: 2025-09-10 15:00:00.000000000 Z\nescalation_level: 0\nsla_breached: false\nsla_policy_id: 4\nurgency: 1\nimpact: 1\ncalculated_priority: 1\nresolved_at:\nresolution_note:\nsome_field:\nreason:\nresolution_method:\ncause_code:\nresolution_details:\nend_customer:\nsupport_center:\ntotal_kilometer:\ndepartment_id:\nbreaching_sla: false\n
105	\N	2025-08-30 12:55:15.652033	45	Ticket	update	---\nid: 45\ntitle: 'Attaching a pdf '\ndescription: We are testing to see if we can attach a pdf to a created ticket\npriority: 1\norganization_id: 2\ncreated_at: 2025-08-30 12:55:14.868416000 Z\nupdated_at: 2025-08-30 12:55:15.652033000 Z\nticket_number: INC9OOEJ4RV\nticket_type: Incident\nassignee_id: 10\nteam_id: 6\nrequester_id: 10\nreported_at: 2025-08-30 12:53:00.000000000 Z\ncategory: Technical\ncaller_name: Sharmaine\ncaller_surname: Dillian\ncaller_email: tendain@greensoftsolutions.net\ncaller_phone: '0742591362'\ncustomer: Midrand\nsource: Web\nstatus: 1\ncreator_id: 10\nresponse_due_at: 2025-09-03 12:00:00.000000000 Z\nresolution_due_at: 2025-09-10 15:00:00.000000000 Z\nescalation_level: 0\nsla_breached: false\nsla_policy_id: 4\nurgency: 1\nimpact: 1\ncalculated_priority: 1\nresolved_at:\nresolution_note:\nsome_field:\nreason:\nresolution_method:\ncause_code:\nresolution_details:\nend_customer:\nsupport_center:\ntotal_kilometer:\ndepartment_id:\nbreaching_sla: false\n
106	\N	2025-08-30 12:55:16.040094	45	Ticket	update	---\nid: 45\ntitle: 'Attaching a pdf '\ndescription: We are testing to see if we can attach a pdf to a created ticket\npriority: 1\norganization_id: 2\ncreated_at: 2025-08-30 12:55:14.868416000 Z\nupdated_at: 2025-08-30 12:55:16.040094000 Z\nticket_number: INC9OOEJ4RV\nticket_type: Incident\nassignee_id: 10\nteam_id: 6\nrequester_id: 10\nreported_at: 2025-08-30 12:53:00.000000000 Z\ncategory: Technical\ncaller_name: Sharmaine\ncaller_surname: Dillian\ncaller_email: tendain@greensoftsolutions.net\ncaller_phone: '0742591362'\ncustomer: Midrand\nsource: Web\nstatus: 1\ncreator_id: 10\nresponse_due_at: 2025-09-03 12:00:00.000000000 Z\nresolution_due_at: 2025-09-10 15:00:00.000000000 Z\nescalation_level: 0\nsla_breached: false\nsla_policy_id: 4\nurgency: 1\nimpact: 1\ncalculated_priority: 1\nresolved_at:\nresolution_note:\nsome_field:\nreason:\nresolution_method:\ncause_code:\nresolution_details:\nend_customer:\nsupport_center:\ntotal_kilometer:\ndepartment_id:\nbreaching_sla: false\n
107	\N	2025-08-30 12:55:16.228725	45	Ticket	update	---\nid: 45\ntitle: 'Attaching a pdf '\ndescription: We are testing to see if we can attach a pdf to a created ticket\npriority: 1\norganization_id: 2\ncreated_at: 2025-08-30 12:55:14.868416000 Z\nupdated_at: 2025-08-30 12:55:16.228725000 Z\nticket_number: INC9OOEJ4RV\nticket_type: Incident\nassignee_id: 10\nteam_id: 6\nrequester_id: 10\nreported_at: 2025-08-30 12:53:00.000000000 Z\ncategory: Technical\ncaller_name: Sharmaine\ncaller_surname: Dillian\ncaller_email: tendain@greensoftsolutions.net\ncaller_phone: '0742591362'\ncustomer: Midrand\nsource: Web\nstatus: 1\ncreator_id: 10\nresponse_due_at: 2025-09-03 12:00:00.000000000 Z\nresolution_due_at: 2025-09-10 15:00:00.000000000 Z\nescalation_level: 0\nsla_breached: false\nsla_policy_id: 4\nurgency: 1\nimpact: 1\ncalculated_priority: 1\nresolved_at:\nresolution_note:\nsome_field:\nreason:\nresolution_method:\ncause_code:\nresolution_details:\nend_customer:\nsupport_center:\ntotal_kilometer:\ndepartment_id:\nbreaching_sla: false\n
108	\N	2025-08-30 13:03:41.358819	46	Ticket	create	\N
109	\N	2025-08-30 13:03:42.100302	46	Ticket	update	---\nid: 46\ntitle: add attachments to ticket\ndescription: Let test the attachments\npriority: 0\norganization_id: 2\ncreated_at: 2025-08-30 13:03:41.358819000 Z\nupdated_at: 2025-08-30 13:03:41.358819000 Z\nticket_number: INCGEK7K5K2\nticket_type: Incident\nassignee_id: 10\nteam_id: 6\nrequester_id: 10\nreported_at: 2025-08-30 13:02:00.000000000 Z\ncategory: Technical\ncaller_name: Sharon\ncaller_surname: Saymore\ncaller_email: tendain@greensoftsolutions.net\ncaller_phone: '0742591362'\ncustomer: GSS hed\nsource: Web\nstatus: 1\ncreator_id: 10\nresponse_due_at:\nresolution_due_at:\nescalation_level: 0\nsla_breached: false\nsla_policy_id:\nurgency: 2\nimpact: 2\ncalculated_priority: 3\nresolved_at:\nresolution_note:\nsome_field:\nreason:\nresolution_method:\ncause_code:\nresolution_details:\nend_customer:\nsupport_center:\ntotal_kilometer:\ndepartment_id:\nbreaching_sla: false\n
110	\N	2025-08-30 13:03:42.167145	46	Ticket	update	---\nid: 46\ntitle: add attachments to ticket\ndescription: Let test the attachments\npriority: 3\norganization_id: 2\ncreated_at: 2025-08-30 13:03:41.358819000 Z\nupdated_at: 2025-08-30 13:03:42.167145000 Z\nticket_number: INCGEK7K5K2\nticket_type: Incident\nassignee_id: 10\nteam_id: 6\nrequester_id: 10\nreported_at: 2025-08-30 13:02:00.000000000 Z\ncategory: Technical\ncaller_name: Sharon\ncaller_surname: Saymore\ncaller_email: tendain@greensoftsolutions.net\ncaller_phone: '0742591362'\ncustomer: GSS hed\nsource: Web\nstatus: 1\ncreator_id: 10\nresponse_due_at: 2025-09-03 12:00:00.000000000 Z\nresolution_due_at: 2025-09-10 15:00:00.000000000 Z\nescalation_level: 0\nsla_breached: false\nsla_policy_id: 4\nurgency: 2\nimpact: 2\ncalculated_priority: 3\nresolved_at:\nresolution_note:\nsome_field:\nreason:\nresolution_method:\ncause_code:\nresolution_details:\nend_customer:\nsupport_center:\ntotal_kilometer:\ndepartment_id:\nbreaching_sla: false\n
111	\N	2025-08-30 13:03:42.281246	46	Ticket	update	---\nid: 46\ntitle: add attachments to ticket\ndescription: Let test the attachments\npriority: 3\norganization_id: 2\ncreated_at: 2025-08-30 13:03:41.358819000 Z\nupdated_at: 2025-08-30 13:03:42.281246000 Z\nticket_number: INCGEK7K5K2\nticket_type: Incident\nassignee_id: 10\nteam_id: 6\nrequester_id: 10\nreported_at: 2025-08-30 13:02:00.000000000 Z\ncategory: Technical\ncaller_name: Sharon\ncaller_surname: Saymore\ncaller_email: tendain@greensoftsolutions.net\ncaller_phone: '0742591362'\ncustomer: GSS hed\nsource: Web\nstatus: 1\ncreator_id: 10\nresponse_due_at: 2025-09-03 12:00:00.000000000 Z\nresolution_due_at: 2025-09-10 15:00:00.000000000 Z\nescalation_level: 0\nsla_breached: false\nsla_policy_id: 4\nurgency: 2\nimpact: 2\ncalculated_priority: 3\nresolved_at:\nresolution_note:\nsome_field:\nreason:\nresolution_method:\ncause_code:\nresolution_details:\nend_customer:\nsupport_center:\ntotal_kilometer:\ndepartment_id:\nbreaching_sla: false\n
112	\N	2025-08-30 13:03:42.639053	46	Ticket	update	---\nid: 46\ntitle: add attachments to ticket\ndescription: Let test the attachments\npriority: 3\norganization_id: 2\ncreated_at: 2025-08-30 13:03:41.358819000 Z\nupdated_at: 2025-08-30 13:03:42.639053000 Z\nticket_number: INCGEK7K5K2\nticket_type: Incident\nassignee_id: 10\nteam_id: 6\nrequester_id: 10\nreported_at: 2025-08-30 13:02:00.000000000 Z\ncategory: Technical\ncaller_name: Sharon\ncaller_surname: Saymore\ncaller_email: tendain@greensoftsolutions.net\ncaller_phone: '0742591362'\ncustomer: GSS hed\nsource: Web\nstatus: 1\ncreator_id: 10\nresponse_due_at: 2025-09-03 12:00:00.000000000 Z\nresolution_due_at: 2025-09-10 15:00:00.000000000 Z\nescalation_level: 0\nsla_breached: false\nsla_policy_id: 4\nurgency: 2\nimpact: 2\ncalculated_priority: 3\nresolved_at:\nresolution_note:\nsome_field:\nreason:\nresolution_method:\ncause_code:\nresolution_details:\nend_customer:\nsupport_center:\ntotal_kilometer:\ndepartment_id:\nbreaching_sla: false\n
113	\N	2025-08-30 13:03:42.79222	46	Ticket	update	---\nid: 46\ntitle: add attachments to ticket\ndescription: Let test the attachments\npriority: 3\norganization_id: 2\ncreated_at: 2025-08-30 13:03:41.358819000 Z\nupdated_at: 2025-08-30 13:03:42.792220000 Z\nticket_number: INCGEK7K5K2\nticket_type: Incident\nassignee_id: 10\nteam_id: 6\nrequester_id: 10\nreported_at: 2025-08-30 13:02:00.000000000 Z\ncategory: Technical\ncaller_name: Sharon\ncaller_surname: Saymore\ncaller_email: tendain@greensoftsolutions.net\ncaller_phone: '0742591362'\ncustomer: GSS hed\nsource: Web\nstatus: 1\ncreator_id: 10\nresponse_due_at: 2025-09-03 12:00:00.000000000 Z\nresolution_due_at: 2025-09-10 15:00:00.000000000 Z\nescalation_level: 0\nsla_breached: false\nsla_policy_id: 4\nurgency: 2\nimpact: 2\ncalculated_priority: 3\nresolved_at:\nresolution_note:\nsome_field:\nreason:\nresolution_method:\ncause_code:\nresolution_details:\nend_customer:\nsupport_center:\ntotal_kilometer:\ndepartment_id:\nbreaching_sla: false\n
114	\N	2025-08-30 13:15:21.908975	47	Ticket	create	\N
115	\N	2025-08-30 13:15:22.380603	47	Ticket	update	---\nid: 47\ntitle: Attaching a pdf to a ticket\ndescription: Let update the ticket and add a pdf attachment\npriority: 0\norganization_id: 2\ncreated_at: 2025-08-30 13:15:21.908975000 Z\nupdated_at: 2025-08-30 13:15:21.908975000 Z\nticket_number: INCHK3YOCO5\nticket_type: Incident\nassignee_id: 10\nteam_id: 6\nrequester_id: 10\nreported_at: 2025-08-30 13:13:00.000000000 Z\ncategory: Technical\ncaller_name: Tendai\ncaller_surname: Tindo\ncaller_email: tendain@greensoftsolutions.net\ncaller_phone: '0742591362'\ncustomer: Juskskei\nsource: Web\nstatus: 1\ncreator_id: 10\nresponse_due_at:\nresolution_due_at:\nescalation_level: 0\nsla_breached: false\nsla_policy_id:\nurgency: 1\nimpact: 2\ncalculated_priority: 2\nresolved_at:\nresolution_note:\nsome_field:\nreason:\nresolution_method:\ncause_code:\nresolution_details:\nend_customer:\nsupport_center:\ntotal_kilometer:\ndepartment_id:\nbreaching_sla: false\n
116	\N	2025-08-30 13:15:22.417233	47	Ticket	update	---\nid: 47\ntitle: Attaching a pdf to a ticket\ndescription: Let update the ticket and add a pdf attachment\npriority: 2\norganization_id: 2\ncreated_at: 2025-08-30 13:15:21.908975000 Z\nupdated_at: 2025-08-30 13:15:22.417233000 Z\nticket_number: INCHK3YOCO5\nticket_type: Incident\nassignee_id: 10\nteam_id: 6\nrequester_id: 10\nreported_at: 2025-08-30 13:13:00.000000000 Z\ncategory: Technical\ncaller_name: Tendai\ncaller_surname: Tindo\ncaller_email: tendain@greensoftsolutions.net\ncaller_phone: '0742591362'\ncustomer: Juskskei\nsource: Web\nstatus: 1\ncreator_id: 10\nresponse_due_at: 2025-09-03 12:00:00.000000000 Z\nresolution_due_at: 2025-09-10 15:00:00.000000000 Z\nescalation_level: 0\nsla_breached: false\nsla_policy_id: 4\nurgency: 1\nimpact: 2\ncalculated_priority: 2\nresolved_at:\nresolution_note:\nsome_field:\nreason:\nresolution_method:\ncause_code:\nresolution_details:\nend_customer:\nsupport_center:\ntotal_kilometer:\ndepartment_id:\nbreaching_sla: false\n
117	\N	2025-08-30 13:15:22.501685	47	Ticket	update	---\nid: 47\ntitle: Attaching a pdf to a ticket\ndescription: Let update the ticket and add a pdf attachment\npriority: 2\norganization_id: 2\ncreated_at: 2025-08-30 13:15:21.908975000 Z\nupdated_at: 2025-08-30 13:15:22.501685000 Z\nticket_number: INCHK3YOCO5\nticket_type: Incident\nassignee_id: 10\nteam_id: 6\nrequester_id: 10\nreported_at: 2025-08-30 13:13:00.000000000 Z\ncategory: Technical\ncaller_name: Tendai\ncaller_surname: Tindo\ncaller_email: tendain@greensoftsolutions.net\ncaller_phone: '0742591362'\ncustomer: Juskskei\nsource: Web\nstatus: 1\ncreator_id: 10\nresponse_due_at: 2025-09-03 12:00:00.000000000 Z\nresolution_due_at: 2025-09-10 15:00:00.000000000 Z\nescalation_level: 0\nsla_breached: false\nsla_policy_id: 4\nurgency: 1\nimpact: 2\ncalculated_priority: 2\nresolved_at:\nresolution_note:\nsome_field:\nreason:\nresolution_method:\ncause_code:\nresolution_details:\nend_customer:\nsupport_center:\ntotal_kilometer:\ndepartment_id:\nbreaching_sla: false\n
118	\N	2025-08-30 13:15:22.809231	47	Ticket	update	---\nid: 47\ntitle: Attaching a pdf to a ticket\ndescription: Let update the ticket and add a pdf attachment\npriority: 2\norganization_id: 2\ncreated_at: 2025-08-30 13:15:21.908975000 Z\nupdated_at: 2025-08-30 13:15:22.809231000 Z\nticket_number: INCHK3YOCO5\nticket_type: Incident\nassignee_id: 10\nteam_id: 6\nrequester_id: 10\nreported_at: 2025-08-30 13:13:00.000000000 Z\ncategory: Technical\ncaller_name: Tendai\ncaller_surname: Tindo\ncaller_email: tendain@greensoftsolutions.net\ncaller_phone: '0742591362'\ncustomer: Juskskei\nsource: Web\nstatus: 1\ncreator_id: 10\nresponse_due_at: 2025-09-03 12:00:00.000000000 Z\nresolution_due_at: 2025-09-10 15:00:00.000000000 Z\nescalation_level: 0\nsla_breached: false\nsla_policy_id: 4\nurgency: 1\nimpact: 2\ncalculated_priority: 2\nresolved_at:\nresolution_note:\nsome_field:\nreason:\nresolution_method:\ncause_code:\nresolution_details:\nend_customer:\nsupport_center:\ntotal_kilometer:\ndepartment_id:\nbreaching_sla: false\n
119	\N	2025-08-30 13:15:22.961838	47	Ticket	update	---\nid: 47\ntitle: Attaching a pdf to a ticket\ndescription: Let update the ticket and add a pdf attachment\npriority: 2\norganization_id: 2\ncreated_at: 2025-08-30 13:15:21.908975000 Z\nupdated_at: 2025-08-30 13:15:22.961838000 Z\nticket_number: INCHK3YOCO5\nticket_type: Incident\nassignee_id: 10\nteam_id: 6\nrequester_id: 10\nreported_at: 2025-08-30 13:13:00.000000000 Z\ncategory: Technical\ncaller_name: Tendai\ncaller_surname: Tindo\ncaller_email: tendain@greensoftsolutions.net\ncaller_phone: '0742591362'\ncustomer: Juskskei\nsource: Web\nstatus: 1\ncreator_id: 10\nresponse_due_at: 2025-09-03 12:00:00.000000000 Z\nresolution_due_at: 2025-09-10 15:00:00.000000000 Z\nescalation_level: 0\nsla_breached: false\nsla_policy_id: 4\nurgency: 1\nimpact: 2\ncalculated_priority: 2\nresolved_at:\nresolution_note:\nsome_field:\nreason:\nresolution_method:\ncause_code:\nresolution_details:\nend_customer:\nsupport_center:\ntotal_kilometer:\ndepartment_id:\nbreaching_sla: false\n
120	\N	2025-08-30 13:24:30.161317	48	Ticket	create	\N
121	\N	2025-08-30 13:24:30.725222	48	Ticket	update	---\nid: 48\ntitle: Attachments pdf\ndescription: Reference site about Lorem Ipsum, giving information on its origins,\n  as well as a random Lipsum generator.\npriority: 0\norganization_id: 2\ncreated_at: 2025-08-30 13:24:30.161317000 Z\nupdated_at: 2025-08-30 13:24:30.161317000 Z\nticket_number: INCQ7CPHL1J\nticket_type: Incident\nassignee_id: 10\nteam_id: 6\nrequester_id: 10\nreported_at: 2025-08-30 13:23:00.000000000 Z\ncategory: Technical\ncaller_name: Denzel\ncaller_surname: Kairo\ncaller_email: tendain@greensoftsolutions.net\ncaller_phone: '0742591362'\ncustomer: Johannesburg\nsource: Web\nstatus: 1\ncreator_id: 10\nresponse_due_at:\nresolution_due_at:\nescalation_level: 0\nsla_breached: false\nsla_policy_id:\nurgency: 2\nimpact: 2\ncalculated_priority: 3\nresolved_at:\nresolution_note:\nsome_field:\nreason:\nresolution_method:\ncause_code:\nresolution_details:\nend_customer:\nsupport_center:\ntotal_kilometer:\ndepartment_id:\nbreaching_sla: false\n
122	\N	2025-08-30 13:24:30.803995	48	Ticket	update	---\nid: 48\ntitle: Attachments pdf\ndescription: Reference site about Lorem Ipsum, giving information on its origins,\n  as well as a random Lipsum generator.\npriority: 3\norganization_id: 2\ncreated_at: 2025-08-30 13:24:30.161317000 Z\nupdated_at: 2025-08-30 13:24:30.803995000 Z\nticket_number: INCQ7CPHL1J\nticket_type: Incident\nassignee_id: 10\nteam_id: 6\nrequester_id: 10\nreported_at: 2025-08-30 13:23:00.000000000 Z\ncategory: Technical\ncaller_name: Denzel\ncaller_surname: Kairo\ncaller_email: tendain@greensoftsolutions.net\ncaller_phone: '0742591362'\ncustomer: Johannesburg\nsource: Web\nstatus: 1\ncreator_id: 10\nresponse_due_at: 2025-09-03 12:00:00.000000000 Z\nresolution_due_at: 2025-09-10 15:00:00.000000000 Z\nescalation_level: 0\nsla_breached: false\nsla_policy_id: 4\nurgency: 2\nimpact: 2\ncalculated_priority: 3\nresolved_at:\nresolution_note:\nsome_field:\nreason:\nresolution_method:\ncause_code:\nresolution_details:\nend_customer:\nsupport_center:\ntotal_kilometer:\ndepartment_id:\nbreaching_sla: false\n
123	\N	2025-08-30 13:24:30.902713	48	Ticket	update	---\nid: 48\ntitle: Attachments pdf\ndescription: Reference site about Lorem Ipsum, giving information on its origins,\n  as well as a random Lipsum generator.\npriority: 3\norganization_id: 2\ncreated_at: 2025-08-30 13:24:30.161317000 Z\nupdated_at: 2025-08-30 13:24:30.902713000 Z\nticket_number: INCQ7CPHL1J\nticket_type: Incident\nassignee_id: 10\nteam_id: 6\nrequester_id: 10\nreported_at: 2025-08-30 13:23:00.000000000 Z\ncategory: Technical\ncaller_name: Denzel\ncaller_surname: Kairo\ncaller_email: tendain@greensoftsolutions.net\ncaller_phone: '0742591362'\ncustomer: Johannesburg\nsource: Web\nstatus: 1\ncreator_id: 10\nresponse_due_at: 2025-09-03 12:00:00.000000000 Z\nresolution_due_at: 2025-09-10 15:00:00.000000000 Z\nescalation_level: 0\nsla_breached: false\nsla_policy_id: 4\nurgency: 2\nimpact: 2\ncalculated_priority: 3\nresolved_at:\nresolution_note:\nsome_field:\nreason:\nresolution_method:\ncause_code:\nresolution_details:\nend_customer:\nsupport_center:\ntotal_kilometer:\ndepartment_id:\nbreaching_sla: false\n
124	\N	2025-08-30 13:24:31.142114	48	Ticket	update	---\nid: 48\ntitle: Attachments pdf\ndescription: Reference site about Lorem Ipsum, giving information on its origins,\n  as well as a random Lipsum generator.\npriority: 3\norganization_id: 2\ncreated_at: 2025-08-30 13:24:30.161317000 Z\nupdated_at: 2025-08-30 13:24:31.142114000 Z\nticket_number: INCQ7CPHL1J\nticket_type: Incident\nassignee_id: 10\nteam_id: 6\nrequester_id: 10\nreported_at: 2025-08-30 13:23:00.000000000 Z\ncategory: Technical\ncaller_name: Denzel\ncaller_surname: Kairo\ncaller_email: tendain@greensoftsolutions.net\ncaller_phone: '0742591362'\ncustomer: Johannesburg\nsource: Web\nstatus: 1\ncreator_id: 10\nresponse_due_at: 2025-09-03 12:00:00.000000000 Z\nresolution_due_at: 2025-09-10 15:00:00.000000000 Z\nescalation_level: 0\nsla_breached: false\nsla_policy_id: 4\nurgency: 2\nimpact: 2\ncalculated_priority: 3\nresolved_at:\nresolution_note:\nsome_field:\nreason:\nresolution_method:\ncause_code:\nresolution_details:\nend_customer:\nsupport_center:\ntotal_kilometer:\ndepartment_id:\nbreaching_sla: false\n
125	\N	2025-08-30 13:24:31.290286	48	Ticket	update	---\nid: 48\ntitle: Attachments pdf\ndescription: Reference site about Lorem Ipsum, giving information on its origins,\n  as well as a random Lipsum generator.\npriority: 3\norganization_id: 2\ncreated_at: 2025-08-30 13:24:30.161317000 Z\nupdated_at: 2025-08-30 13:24:31.290286000 Z\nticket_number: INCQ7CPHL1J\nticket_type: Incident\nassignee_id: 10\nteam_id: 6\nrequester_id: 10\nreported_at: 2025-08-30 13:23:00.000000000 Z\ncategory: Technical\ncaller_name: Denzel\ncaller_surname: Kairo\ncaller_email: tendain@greensoftsolutions.net\ncaller_phone: '0742591362'\ncustomer: Johannesburg\nsource: Web\nstatus: 1\ncreator_id: 10\nresponse_due_at: 2025-09-03 12:00:00.000000000 Z\nresolution_due_at: 2025-09-10 15:00:00.000000000 Z\nescalation_level: 0\nsla_breached: false\nsla_policy_id: 4\nurgency: 2\nimpact: 2\ncalculated_priority: 3\nresolved_at:\nresolution_note:\nsome_field:\nreason:\nresolution_method:\ncause_code:\nresolution_details:\nend_customer:\nsupport_center:\ntotal_kilometer:\ndepartment_id:\nbreaching_sla: false\n
126	\N	2025-08-30 14:03:55.250951	49	Ticket	create	\N
127	\N	2025-08-30 14:03:55.702697	49	Ticket	update	---\nid: 49\ntitle: Attachment PDF 3\ndescription: We are testing to see if we can attach a pdf to a created ticket\npriority: 0\norganization_id: 2\ncreated_at: 2025-08-30 14:03:55.250951000 Z\nupdated_at: 2025-08-30 14:03:55.250951000 Z\nticket_number: INCV9GUPCOA\nticket_type: Incident\nassignee_id: 10\nteam_id: 6\nrequester_id: 10\nreported_at: 2025-08-30 14:00:00.000000000 Z\ncategory: Other\ncaller_name: Tendai\ncaller_surname: Tindo\ncaller_email: tendain@greensoftsolutions.net\ncaller_phone: '0742591362'\ncustomer: Juskskei\nsource: Web\nstatus: 1\ncreator_id: 10\nresponse_due_at:\nresolution_due_at:\nescalation_level: 0\nsla_breached: false\nsla_policy_id:\nurgency: 2\nimpact: 2\ncalculated_priority: 3\nresolved_at:\nresolution_note:\nsome_field:\nreason:\nresolution_method:\ncause_code:\nresolution_details:\nend_customer:\nsupport_center:\ntotal_kilometer:\ndepartment_id:\nbreaching_sla: false\n
128	\N	2025-08-30 14:03:55.740665	49	Ticket	update	---\nid: 49\ntitle: Attachment PDF 3\ndescription: We are testing to see if we can attach a pdf to a created ticket\npriority: 3\norganization_id: 2\ncreated_at: 2025-08-30 14:03:55.250951000 Z\nupdated_at: 2025-08-30 14:03:55.740665000 Z\nticket_number: INCV9GUPCOA\nticket_type: Incident\nassignee_id: 10\nteam_id: 6\nrequester_id: 10\nreported_at: 2025-08-30 14:00:00.000000000 Z\ncategory: Other\ncaller_name: Tendai\ncaller_surname: Tindo\ncaller_email: tendain@greensoftsolutions.net\ncaller_phone: '0742591362'\ncustomer: Juskskei\nsource: Web\nstatus: 1\ncreator_id: 10\nresponse_due_at: 2025-09-03 12:00:00.000000000 Z\nresolution_due_at: 2025-09-10 15:00:00.000000000 Z\nescalation_level: 0\nsla_breached: false\nsla_policy_id: 4\nurgency: 2\nimpact: 2\ncalculated_priority: 3\nresolved_at:\nresolution_note:\nsome_field:\nreason:\nresolution_method:\ncause_code:\nresolution_details:\nend_customer:\nsupport_center:\ntotal_kilometer:\ndepartment_id:\nbreaching_sla: false\n
129	\N	2025-08-30 14:03:55.92368	49	Ticket	update	---\nid: 49\ntitle: Attachment PDF 3\ndescription: We are testing to see if we can attach a pdf to a created ticket\npriority: 3\norganization_id: 2\ncreated_at: 2025-08-30 14:03:55.250951000 Z\nupdated_at: 2025-08-30 14:03:55.923680000 Z\nticket_number: INCV9GUPCOA\nticket_type: Incident\nassignee_id: 10\nteam_id: 6\nrequester_id: 10\nreported_at: 2025-08-30 14:00:00.000000000 Z\ncategory: Other\ncaller_name: Tendai\ncaller_surname: Tindo\ncaller_email: tendain@greensoftsolutions.net\ncaller_phone: '0742591362'\ncustomer: Juskskei\nsource: Web\nstatus: 1\ncreator_id: 10\nresponse_due_at: 2025-09-03 12:00:00.000000000 Z\nresolution_due_at: 2025-09-10 15:00:00.000000000 Z\nescalation_level: 0\nsla_breached: false\nsla_policy_id: 4\nurgency: 2\nimpact: 2\ncalculated_priority: 3\nresolved_at:\nresolution_note:\nsome_field:\nreason:\nresolution_method:\ncause_code:\nresolution_details:\nend_customer:\nsupport_center:\ntotal_kilometer:\ndepartment_id:\nbreaching_sla: false\n
130	\N	2025-08-30 14:11:07.759217	50	Ticket	create	\N
131	\N	2025-08-30 14:11:08.229217	50	Ticket	update	---\nid: 50\ntitle: Attaching a pdf to ticket\ndescription: Allow tickets to have an attachment\npriority: 0\norganization_id: 2\ncreated_at: 2025-08-30 14:11:07.759217000 Z\nupdated_at: 2025-08-30 14:11:07.759217000 Z\nticket_number: INCNLIHTL84\nticket_type: Incident\nassignee_id: 10\nteam_id: 6\nrequester_id: 10\nreported_at: 2025-08-30 14:10:00.000000000 Z\ncategory: Technical\ncaller_name: Tendai\ncaller_surname: Tindo\ncaller_email: tendain@greensoftsolutions.net\ncaller_phone: '0742591362'\ncustomer: Juskskei\nsource: Web\nstatus: 1\ncreator_id: 10\nresponse_due_at:\nresolution_due_at:\nescalation_level: 0\nsla_breached: false\nsla_policy_id:\nurgency: 1\nimpact: 2\ncalculated_priority: 2\nresolved_at:\nresolution_note:\nsome_field:\nreason:\nresolution_method:\ncause_code:\nresolution_details:\nend_customer:\nsupport_center:\ntotal_kilometer:\ndepartment_id:\nbreaching_sla: false\n
132	\N	2025-08-30 14:11:08.317214	50	Ticket	update	---\nid: 50\ntitle: Attaching a pdf to ticket\ndescription: Allow tickets to have an attachment\npriority: 2\norganization_id: 2\ncreated_at: 2025-08-30 14:11:07.759217000 Z\nupdated_at: 2025-08-30 14:11:08.317214000 Z\nticket_number: INCNLIHTL84\nticket_type: Incident\nassignee_id: 10\nteam_id: 6\nrequester_id: 10\nreported_at: 2025-08-30 14:10:00.000000000 Z\ncategory: Technical\ncaller_name: Tendai\ncaller_surname: Tindo\ncaller_email: tendain@greensoftsolutions.net\ncaller_phone: '0742591362'\ncustomer: Juskskei\nsource: Web\nstatus: 1\ncreator_id: 10\nresponse_due_at: 2025-09-03 12:00:00.000000000 Z\nresolution_due_at: 2025-09-10 15:00:00.000000000 Z\nescalation_level: 0\nsla_breached: false\nsla_policy_id: 4\nurgency: 1\nimpact: 2\ncalculated_priority: 2\nresolved_at:\nresolution_note:\nsome_field:\nreason:\nresolution_method:\ncause_code:\nresolution_details:\nend_customer:\nsupport_center:\ntotal_kilometer:\ndepartment_id:\nbreaching_sla: false\n
133	\N	2025-08-30 14:11:08.422033	50	Ticket	update	---\nid: 50\ntitle: Attaching a pdf to ticket\ndescription: Allow tickets to have an attachment\npriority: 2\norganization_id: 2\ncreated_at: 2025-08-30 14:11:07.759217000 Z\nupdated_at: 2025-08-30 14:11:08.422033000 Z\nticket_number: INCNLIHTL84\nticket_type: Incident\nassignee_id: 10\nteam_id: 6\nrequester_id: 10\nreported_at: 2025-08-30 14:10:00.000000000 Z\ncategory: Technical\ncaller_name: Tendai\ncaller_surname: Tindo\ncaller_email: tendain@greensoftsolutions.net\ncaller_phone: '0742591362'\ncustomer: Juskskei\nsource: Web\nstatus: 1\ncreator_id: 10\nresponse_due_at: 2025-09-03 12:00:00.000000000 Z\nresolution_due_at: 2025-09-10 15:00:00.000000000 Z\nescalation_level: 0\nsla_breached: false\nsla_policy_id: 4\nurgency: 1\nimpact: 2\ncalculated_priority: 2\nresolved_at:\nresolution_note:\nsome_field:\nreason:\nresolution_method:\ncause_code:\nresolution_details:\nend_customer:\nsupport_center:\ntotal_kilometer:\ndepartment_id:\nbreaching_sla: false\n
134	\N	2025-08-30 14:26:16.722435	51	Ticket	create	\N
135	\N	2025-08-30 14:26:17.485918	51	Ticket	update	---\nid: 51\ntitle: creating a ticket with an attachment\ndescription: We need to create a ticket with an attachment\npriority: 0\norganization_id: 2\ncreated_at: 2025-08-30 14:26:16.722435000 Z\nupdated_at: 2025-08-30 14:26:16.722435000 Z\nticket_number: INCSUM5F4E0\nticket_type: Incident\nassignee_id: 4\nteam_id: 5\nrequester_id: 10\nreported_at: 2025-08-30 14:24:00.000000000 Z\ncategory: Technical\ncaller_name: Minky\ncaller_surname: Robbins\ncaller_email: tendain@greensoftsolutions.net\ncaller_phone: '0742591362'\ncustomer: Johannesburg\nsource: Web\nstatus: 1\ncreator_id: 10\nresponse_due_at:\nresolution_due_at:\nescalation_level: 0\nsla_breached: false\nsla_policy_id:\nurgency: 1\nimpact: 1\ncalculated_priority: 1\nresolved_at:\nresolution_note:\nsome_field:\nreason:\nresolution_method:\ncause_code:\nresolution_details:\nend_customer:\nsupport_center:\ntotal_kilometer:\ndepartment_id:\nbreaching_sla: false\n
136	\N	2025-08-30 14:26:17.583274	51	Ticket	update	---\nid: 51\ntitle: creating a ticket with an attachment\ndescription: We need to create a ticket with an attachment\npriority: 1\norganization_id: 2\ncreated_at: 2025-08-30 14:26:16.722435000 Z\nupdated_at: 2025-08-30 14:26:17.583274000 Z\nticket_number: INCSUM5F4E0\nticket_type: Incident\nassignee_id: 4\nteam_id: 5\nrequester_id: 10\nreported_at: 2025-08-30 14:24:00.000000000 Z\ncategory: Technical\ncaller_name: Minky\ncaller_surname: Robbins\ncaller_email: tendain@greensoftsolutions.net\ncaller_phone: '0742591362'\ncustomer: Johannesburg\nsource: Web\nstatus: 1\ncreator_id: 10\nresponse_due_at: 2025-09-03 12:00:00.000000000 Z\nresolution_due_at: 2025-09-10 15:00:00.000000000 Z\nescalation_level: 0\nsla_breached: false\nsla_policy_id: 4\nurgency: 1\nimpact: 1\ncalculated_priority: 1\nresolved_at:\nresolution_note:\nsome_field:\nreason:\nresolution_method:\ncause_code:\nresolution_details:\nend_customer:\nsupport_center:\ntotal_kilometer:\ndepartment_id:\nbreaching_sla: false\n
137	\N	2025-08-30 14:26:17.684518	51	Ticket	update	---\nid: 51\ntitle: creating a ticket with an attachment\ndescription: We need to create a ticket with an attachment\npriority: 1\norganization_id: 2\ncreated_at: 2025-08-30 14:26:16.722435000 Z\nupdated_at: 2025-08-30 14:26:17.684518000 Z\nticket_number: INCSUM5F4E0\nticket_type: Incident\nassignee_id: 4\nteam_id: 5\nrequester_id: 10\nreported_at: 2025-08-30 14:24:00.000000000 Z\ncategory: Technical\ncaller_name: Minky\ncaller_surname: Robbins\ncaller_email: tendain@greensoftsolutions.net\ncaller_phone: '0742591362'\ncustomer: Johannesburg\nsource: Web\nstatus: 1\ncreator_id: 10\nresponse_due_at: 2025-09-03 12:00:00.000000000 Z\nresolution_due_at: 2025-09-10 15:00:00.000000000 Z\nescalation_level: 0\nsla_breached: false\nsla_policy_id: 4\nurgency: 1\nimpact: 1\ncalculated_priority: 1\nresolved_at:\nresolution_note:\nsome_field:\nreason:\nresolution_method:\ncause_code:\nresolution_details:\nend_customer:\nsupport_center:\ntotal_kilometer:\ndepartment_id:\nbreaching_sla: false\n
138	\N	2025-08-30 14:26:18.168808	51	Ticket	update	---\nid: 51\ntitle: creating a ticket with an attachment\ndescription: We need to create a ticket with an attachment\npriority: 1\norganization_id: 2\ncreated_at: 2025-08-30 14:26:16.722435000 Z\nupdated_at: 2025-08-30 14:26:18.168808000 Z\nticket_number: INCSUM5F4E0\nticket_type: Incident\nassignee_id: 4\nteam_id: 5\nrequester_id: 10\nreported_at: 2025-08-30 14:24:00.000000000 Z\ncategory: Technical\ncaller_name: Minky\ncaller_surname: Robbins\ncaller_email: tendain@greensoftsolutions.net\ncaller_phone: '0742591362'\ncustomer: Johannesburg\nsource: Web\nstatus: 1\ncreator_id: 10\nresponse_due_at: 2025-09-03 12:00:00.000000000 Z\nresolution_due_at: 2025-09-10 15:00:00.000000000 Z\nescalation_level: 0\nsla_breached: false\nsla_policy_id: 4\nurgency: 1\nimpact: 1\ncalculated_priority: 1\nresolved_at:\nresolution_note:\nsome_field:\nreason:\nresolution_method:\ncause_code:\nresolution_details:\nend_customer:\nsupport_center:\ntotal_kilometer:\ndepartment_id:\nbreaching_sla: false\n
139	\N	2025-08-30 14:26:18.334987	51	Ticket	update	---\nid: 51\ntitle: creating a ticket with an attachment\ndescription: We need to create a ticket with an attachment\npriority: 1\norganization_id: 2\ncreated_at: 2025-08-30 14:26:16.722435000 Z\nupdated_at: 2025-08-30 14:26:18.334987000 Z\nticket_number: INCSUM5F4E0\nticket_type: Incident\nassignee_id: 4\nteam_id: 5\nrequester_id: 10\nreported_at: 2025-08-30 14:24:00.000000000 Z\ncategory: Technical\ncaller_name: Minky\ncaller_surname: Robbins\ncaller_email: tendain@greensoftsolutions.net\ncaller_phone: '0742591362'\ncustomer: Johannesburg\nsource: Web\nstatus: 1\ncreator_id: 10\nresponse_due_at: 2025-09-03 12:00:00.000000000 Z\nresolution_due_at: 2025-09-10 15:00:00.000000000 Z\nescalation_level: 0\nsla_breached: false\nsla_policy_id: 4\nurgency: 1\nimpact: 1\ncalculated_priority: 1\nresolved_at:\nresolution_note:\nsome_field:\nreason:\nresolution_method:\ncause_code:\nresolution_details:\nend_customer:\nsupport_center:\ntotal_kilometer:\ndepartment_id:\nbreaching_sla: false\n
140	\N	2025-08-30 14:50:03.476348	52	Ticket	create	\N
141	\N	2025-08-30 14:50:03.811425	52	Ticket	update	---\nid: 52\ntitle: 'test ticket numbering '\ndescription: 'We have changed the ticket sequencing  to make more '\npriority: 0\norganization_id: 2\ncreated_at: 2025-08-30 14:50:03.476348000 Z\nupdated_at: 2025-08-30 14:50:03.476348000 Z\nticket_number: INC0001\nticket_type: Incident\nassignee_id: 4\nteam_id: 5\nrequester_id: 10\nreported_at: 2025-08-30 14:47:00.000000000 Z\ncategory: Technical\ncaller_name: Tendai\ncaller_surname: Tindo\ncaller_email: tendain@greensoftsolutions.net\ncaller_phone: '0742591362'\ncustomer: Juskskei\nsource: Web\nstatus: 1\ncreator_id: 10\nresponse_due_at:\nresolution_due_at:\nescalation_level: 0\nsla_breached: false\nsla_policy_id:\nurgency: 1\nimpact: 1\ncalculated_priority: 1\nresolved_at:\nresolution_note:\nsome_field:\nreason:\nresolution_method:\ncause_code:\nresolution_details:\nend_customer:\nsupport_center:\ntotal_kilometer:\ndepartment_id:\nbreaching_sla: false\n
142	\N	2025-08-30 14:50:03.883076	52	Ticket	update	---\nid: 52\ntitle: 'test ticket numbering '\ndescription: 'We have changed the ticket sequencing  to make more '\npriority: 1\norganization_id: 2\ncreated_at: 2025-08-30 14:50:03.476348000 Z\nupdated_at: 2025-08-30 14:50:03.883076000 Z\nticket_number: INC0001\nticket_type: Incident\nassignee_id: 4\nteam_id: 5\nrequester_id: 10\nreported_at: 2025-08-30 14:47:00.000000000 Z\ncategory: Technical\ncaller_name: Tendai\ncaller_surname: Tindo\ncaller_email: tendain@greensoftsolutions.net\ncaller_phone: '0742591362'\ncustomer: Juskskei\nsource: Web\nstatus: 1\ncreator_id: 10\nresponse_due_at: 2025-09-03 12:00:00.000000000 Z\nresolution_due_at: 2025-09-10 15:00:00.000000000 Z\nescalation_level: 0\nsla_breached: false\nsla_policy_id: 4\nurgency: 1\nimpact: 1\ncalculated_priority: 1\nresolved_at:\nresolution_note:\nsome_field:\nreason:\nresolution_method:\ncause_code:\nresolution_details:\nend_customer:\nsupport_center:\ntotal_kilometer:\ndepartment_id:\nbreaching_sla: false\n
143	\N	2025-08-30 14:50:03.998893	52	Ticket	update	---\nid: 52\ntitle: 'test ticket numbering '\ndescription: 'We have changed the ticket sequencing  to make more '\npriority: 1\norganization_id: 2\ncreated_at: 2025-08-30 14:50:03.476348000 Z\nupdated_at: 2025-08-30 14:50:03.998893000 Z\nticket_number: INC0001\nticket_type: Incident\nassignee_id: 4\nteam_id: 5\nrequester_id: 10\nreported_at: 2025-08-30 14:47:00.000000000 Z\ncategory: Technical\ncaller_name: Tendai\ncaller_surname: Tindo\ncaller_email: tendain@greensoftsolutions.net\ncaller_phone: '0742591362'\ncustomer: Juskskei\nsource: Web\nstatus: 1\ncreator_id: 10\nresponse_due_at: 2025-09-03 12:00:00.000000000 Z\nresolution_due_at: 2025-09-10 15:00:00.000000000 Z\nescalation_level: 0\nsla_breached: false\nsla_policy_id: 4\nurgency: 1\nimpact: 1\ncalculated_priority: 1\nresolved_at:\nresolution_note:\nsome_field:\nreason:\nresolution_method:\ncause_code:\nresolution_details:\nend_customer:\nsupport_center:\ntotal_kilometer:\ndepartment_id:\nbreaching_sla: false\n
144	\N	2025-08-30 14:50:04.077807	52	Ticket	update	---\nid: 52\ntitle: 'test ticket numbering '\ndescription: 'We have changed the ticket sequencing  to make more '\npriority: 1\norganization_id: 2\ncreated_at: 2025-08-30 14:50:03.476348000 Z\nupdated_at: 2025-08-30 14:50:04.077807000 Z\nticket_number: INC0001\nticket_type: Incident\nassignee_id: 4\nteam_id: 5\nrequester_id: 10\nreported_at: 2025-08-30 14:47:00.000000000 Z\ncategory: Technical\ncaller_name: Tendai\ncaller_surname: Tindo\ncaller_email: tendain@greensoftsolutions.net\ncaller_phone: '0742591362'\ncustomer: Juskskei\nsource: Web\nstatus: 1\ncreator_id: 10\nresponse_due_at: 2025-09-03 12:00:00.000000000 Z\nresolution_due_at: 2025-09-10 15:00:00.000000000 Z\nescalation_level: 0\nsla_breached: false\nsla_policy_id: 4\nurgency: 1\nimpact: 1\ncalculated_priority: 1\nresolved_at:\nresolution_note:\nsome_field:\nreason:\nresolution_method:\ncause_code:\nresolution_details:\nend_customer:\nsupport_center:\ntotal_kilometer:\ndepartment_id:\nbreaching_sla: false\n
145	\N	2025-08-30 14:50:04.181822	52	Ticket	update	---\nid: 52\ntitle: 'test ticket numbering '\ndescription: 'We have changed the ticket sequencing  to make more '\npriority: 1\norganization_id: 2\ncreated_at: 2025-08-30 14:50:03.476348000 Z\nupdated_at: 2025-08-30 14:50:04.181822000 Z\nticket_number: INC0001\nticket_type: Incident\nassignee_id: 4\nteam_id: 5\nrequester_id: 10\nreported_at: 2025-08-30 14:47:00.000000000 Z\ncategory: Technical\ncaller_name: Tendai\ncaller_surname: Tindo\ncaller_email: tendain@greensoftsolutions.net\ncaller_phone: '0742591362'\ncustomer: Juskskei\nsource: Web\nstatus: 1\ncreator_id: 10\nresponse_due_at: 2025-09-03 12:00:00.000000000 Z\nresolution_due_at: 2025-09-10 15:00:00.000000000 Z\nescalation_level: 0\nsla_breached: false\nsla_policy_id: 4\nurgency: 1\nimpact: 1\ncalculated_priority: 1\nresolved_at:\nresolution_note:\nsome_field:\nreason:\nresolution_method:\ncause_code:\nresolution_details:\nend_customer:\nsupport_center:\ntotal_kilometer:\ndepartment_id:\nbreaching_sla: false\n
146	\N	2025-08-30 18:01:08.371583	52	Ticket	update	---\norganization_id: 2\nteam_id: 5\nassignee_id: 4\npriority: 1\ncreator_id: 10\nrequester_id: 10\nticket_number: INC0001\ncalculated_priority: 1\nid: 52\ntitle: 'test ticket numbering '\ndescription: 'We have changed the ticket sequencing  to make more '\ncreated_at: 2025-08-30 14:50:03.476348000 Z\nupdated_at: 2025-08-30 14:50:04.181822000 Z\nticket_type: Incident\nreported_at: 2025-08-30 14:47:00.000000000 Z\ncategory: Technical\ncaller_name: Tendai\ncaller_surname: Tindo\ncaller_email: tendain@greensoftsolutions.net\ncaller_phone: '0742591362'\ncustomer: Juskskei\nsource: Web\nstatus: 1\nresponse_due_at: 2025-09-03 12:00:00.000000000 Z\nresolution_due_at: 2025-09-10 15:00:00.000000000 Z\nescalation_level: 0\nsla_breached: false\nsla_policy_id: 4\nurgency: 1\nimpact: 1\nresolved_at:\nresolution_note:\nsome_field:\nreason:\nresolution_method:\ncause_code:\nresolution_details:\nend_customer:\nsupport_center:\ntotal_kilometer:\ndepartment_id:\nbreaching_sla: false\n
147	\N	2025-08-30 18:22:42.110934	47	Ticket	update	---\norganization_id: 2\nteam_id: 6\nassignee_id: 10\nstatus: 1\npriority: 2\ncreator_id: 10\nrequester_id: 10\nticket_number: INCHK3YOCO5\ncalculated_priority: 2\nid: 47\ntitle: Attaching a pdf to a ticket\ndescription: Let update the ticket and add a pdf attachment\ncreated_at: 2025-08-30 13:15:21.908975000 Z\nupdated_at: 2025-08-30 13:15:22.961838000 Z\nticket_type: Incident\nreported_at: 2025-08-30 13:13:00.000000000 Z\ncategory: Technical\ncaller_name: Tendai\ncaller_surname: Tindo\ncaller_email: tendain@greensoftsolutions.net\ncaller_phone: '0742591362'\ncustomer: Juskskei\nsource: Web\nresponse_due_at: 2025-09-03 12:00:00.000000000 Z\nresolution_due_at: 2025-09-10 15:00:00.000000000 Z\nescalation_level: 0\nsla_breached: false\nsla_policy_id: 4\nurgency: 1\nimpact: 2\nresolved_at:\nresolution_note:\nsome_field:\nreason:\nresolution_method:\ncause_code:\nresolution_details:\nend_customer:\nsupport_center:\ntotal_kilometer:\ndepartment_id:\nbreaching_sla: false\n
148	\N	2025-08-31 09:14:09.281347	53	Ticket	create	\N
149	\N	2025-08-31 09:14:10.338793	53	Ticket	update	---\nid: 53\ntitle: Fixing proper numbering\ndescription: We want to fix the proper numbering of the ticketing system\npriority: 0\norganization_id: 2\ncreated_at: 2025-08-31 09:14:09.281347000 Z\nupdated_at: 2025-08-31 09:14:09.281347000 Z\nticket_number: INC0002\nticket_type: Incident\nassignee_id: 10\nteam_id: 6\nrequester_id: 10\nreported_at: 2025-08-31 09:12:00.000000000 Z\ncategory: Technical\ncaller_name: Taya\ncaller_surname: Clever\ncaller_email: tendain@greensoftsolutions.net\ncaller_phone: '0742591362'\ncustomer: Jusk\nsource: Web\nstatus: 1\ncreator_id: 10\nresponse_due_at:\nresolution_due_at:\nescalation_level: 0\nsla_breached: false\nsla_policy_id:\nurgency: 1\nimpact: 1\ncalculated_priority: 1\nresolved_at:\nresolution_note:\nsome_field:\nreason:\nresolution_method:\ncause_code:\nresolution_details:\nend_customer:\nsupport_center:\ntotal_kilometer:\ndepartment_id:\nbreaching_sla: false\n
150	\N	2025-08-31 09:14:10.460009	53	Ticket	update	---\nid: 53\ntitle: Fixing proper numbering\ndescription: We want to fix the proper numbering of the ticketing system\npriority: 1\norganization_id: 2\ncreated_at: 2025-08-31 09:14:09.281347000 Z\nupdated_at: 2025-08-31 09:14:10.460009000 Z\nticket_number: INC0002\nticket_type: Incident\nassignee_id: 10\nteam_id: 6\nrequester_id: 10\nreported_at: 2025-08-31 09:12:00.000000000 Z\ncategory: Technical\ncaller_name: Taya\ncaller_surname: Clever\ncaller_email: tendain@greensoftsolutions.net\ncaller_phone: '0742591362'\ncustomer: Jusk\nsource: Web\nstatus: 1\ncreator_id: 10\nresponse_due_at: 2025-09-03 12:00:00.000000000 Z\nresolution_due_at: 2025-09-10 15:00:00.000000000 Z\nescalation_level: 0\nsla_breached: false\nsla_policy_id: 4\nurgency: 1\nimpact: 1\ncalculated_priority: 1\nresolved_at:\nresolution_note:\nsome_field:\nreason:\nresolution_method:\ncause_code:\nresolution_details:\nend_customer:\nsupport_center:\ntotal_kilometer:\ndepartment_id:\nbreaching_sla: false\n
151	\N	2025-08-31 09:14:10.59187	53	Ticket	update	---\nid: 53\ntitle: Fixing proper numbering\ndescription: We want to fix the proper numbering of the ticketing system\npriority: 1\norganization_id: 2\ncreated_at: 2025-08-31 09:14:09.281347000 Z\nupdated_at: 2025-08-31 09:14:10.591870000 Z\nticket_number: INC0002\nticket_type: Incident\nassignee_id: 10\nteam_id: 6\nrequester_id: 10\nreported_at: 2025-08-31 09:12:00.000000000 Z\ncategory: Technical\ncaller_name: Taya\ncaller_surname: Clever\ncaller_email: tendain@greensoftsolutions.net\ncaller_phone: '0742591362'\ncustomer: Jusk\nsource: Web\nstatus: 1\ncreator_id: 10\nresponse_due_at: 2025-09-03 12:00:00.000000000 Z\nresolution_due_at: 2025-09-10 15:00:00.000000000 Z\nescalation_level: 0\nsla_breached: false\nsla_policy_id: 4\nurgency: 1\nimpact: 1\ncalculated_priority: 1\nresolved_at:\nresolution_note:\nsome_field:\nreason:\nresolution_method:\ncause_code:\nresolution_details:\nend_customer:\nsupport_center:\ntotal_kilometer:\ndepartment_id:\nbreaching_sla: false\n
152	\N	2025-08-31 09:14:10.842869	53	Ticket	update	---\nid: 53\ntitle: Fixing proper numbering\ndescription: We want to fix the proper numbering of the ticketing system\npriority: 1\norganization_id: 2\ncreated_at: 2025-08-31 09:14:09.281347000 Z\nupdated_at: 2025-08-31 09:14:10.842869000 Z\nticket_number: INC0002\nticket_type: Incident\nassignee_id: 10\nteam_id: 6\nrequester_id: 10\nreported_at: 2025-08-31 09:12:00.000000000 Z\ncategory: Technical\ncaller_name: Taya\ncaller_surname: Clever\ncaller_email: tendain@greensoftsolutions.net\ncaller_phone: '0742591362'\ncustomer: Jusk\nsource: Web\nstatus: 1\ncreator_id: 10\nresponse_due_at: 2025-09-03 12:00:00.000000000 Z\nresolution_due_at: 2025-09-10 15:00:00.000000000 Z\nescalation_level: 0\nsla_breached: false\nsla_policy_id: 4\nurgency: 1\nimpact: 1\ncalculated_priority: 1\nresolved_at:\nresolution_note:\nsome_field:\nreason:\nresolution_method:\ncause_code:\nresolution_details:\nend_customer:\nsupport_center:\ntotal_kilometer:\ndepartment_id:\nbreaching_sla: false\n
153	\N	2025-08-31 09:14:11.008659	53	Ticket	update	---\nid: 53\ntitle: Fixing proper numbering\ndescription: We want to fix the proper numbering of the ticketing system\npriority: 1\norganization_id: 2\ncreated_at: 2025-08-31 09:14:09.281347000 Z\nupdated_at: 2025-08-31 09:14:11.008659000 Z\nticket_number: INC0002\nticket_type: Incident\nassignee_id: 10\nteam_id: 6\nrequester_id: 10\nreported_at: 2025-08-31 09:12:00.000000000 Z\ncategory: Technical\ncaller_name: Taya\ncaller_surname: Clever\ncaller_email: tendain@greensoftsolutions.net\ncaller_phone: '0742591362'\ncustomer: Jusk\nsource: Web\nstatus: 1\ncreator_id: 10\nresponse_due_at: 2025-09-03 12:00:00.000000000 Z\nresolution_due_at: 2025-09-10 15:00:00.000000000 Z\nescalation_level: 0\nsla_breached: false\nsla_policy_id: 4\nurgency: 1\nimpact: 1\ncalculated_priority: 1\nresolved_at:\nresolution_note:\nsome_field:\nreason:\nresolution_method:\ncause_code:\nresolution_details:\nend_customer:\nsupport_center:\ntotal_kilometer:\ndepartment_id:\nbreaching_sla: false\n
154	\N	2025-08-31 11:48:44.404539	54	Ticket	create	\N
155	\N	2025-08-31 11:48:45.283619	54	Ticket	update	---\nid: 54\ntitle: Changing categories\ndescription: Lets fix\npriority: 0\norganization_id: 2\ncreated_at: 2025-08-31 11:48:44.404539000 Z\nupdated_at: 2025-08-31 11:48:44.404539000 Z\nticket_number: CIPC_INC0001\nticket_type: Incident\nassignee_id: 10\nteam_id: 6\nrequester_id: 10\nreported_at: 2025-08-31 11:36:00.000000000 Z\ncategory: Query\ncaller_name: Charity\ncaller_surname: Mkoba\ncaller_email: charitynk@gmail.com\ncaller_phone: '0742591362'\ncustomer: Johannesburg\nsource: Web\nstatus: 1\ncreator_id: 10\nresponse_due_at:\nresolution_due_at:\nescalation_level: 0\nsla_breached: false\nsla_policy_id:\nurgency: 2\nimpact: 2\ncalculated_priority: 3\nresolved_at:\nresolution_note:\nsome_field:\nreason:\nresolution_method:\ncause_code:\nresolution_details:\nend_customer:\nsupport_center:\ntotal_kilometer:\ndepartment_id:\nbreaching_sla: false\n
156	\N	2025-08-31 11:48:45.422539	54	Ticket	update	---\nid: 54\ntitle: Changing categories\ndescription: Lets fix\npriority: 3\norganization_id: 2\ncreated_at: 2025-08-31 11:48:44.404539000 Z\nupdated_at: 2025-08-31 11:48:45.422539000 Z\nticket_number: CIPC_INC0001\nticket_type: Incident\nassignee_id: 10\nteam_id: 6\nrequester_id: 10\nreported_at: 2025-08-31 11:36:00.000000000 Z\ncategory: Query\ncaller_name: Charity\ncaller_surname: Mkoba\ncaller_email: charitynk@gmail.com\ncaller_phone: '0742591362'\ncustomer: Johannesburg\nsource: Web\nstatus: 1\ncreator_id: 10\nresponse_due_at: 2025-09-03 12:00:00.000000000 Z\nresolution_due_at: 2025-09-10 15:00:00.000000000 Z\nescalation_level: 0\nsla_breached: false\nsla_policy_id: 4\nurgency: 2\nimpact: 2\ncalculated_priority: 3\nresolved_at:\nresolution_note:\nsome_field:\nreason:\nresolution_method:\ncause_code:\nresolution_details:\nend_customer:\nsupport_center:\ntotal_kilometer:\ndepartment_id:\nbreaching_sla: false\n
157	\N	2025-08-31 11:48:45.569516	54	Ticket	update	---\nid: 54\ntitle: Changing categories\ndescription: Lets fix\npriority: 3\norganization_id: 2\ncreated_at: 2025-08-31 11:48:44.404539000 Z\nupdated_at: 2025-08-31 11:48:45.569516000 Z\nticket_number: CIPC_INC0001\nticket_type: Incident\nassignee_id: 10\nteam_id: 6\nrequester_id: 10\nreported_at: 2025-08-31 11:36:00.000000000 Z\ncategory: Query\ncaller_name: Charity\ncaller_surname: Mkoba\ncaller_email: charitynk@gmail.com\ncaller_phone: '0742591362'\ncustomer: Johannesburg\nsource: Web\nstatus: 1\ncreator_id: 10\nresponse_due_at: 2025-09-03 12:00:00.000000000 Z\nresolution_due_at: 2025-09-10 15:00:00.000000000 Z\nescalation_level: 0\nsla_breached: false\nsla_policy_id: 4\nurgency: 2\nimpact: 2\ncalculated_priority: 3\nresolved_at:\nresolution_note:\nsome_field:\nreason:\nresolution_method:\ncause_code:\nresolution_details:\nend_customer:\nsupport_center:\ntotal_kilometer:\ndepartment_id:\nbreaching_sla: false\n
158	\N	2025-08-31 11:48:45.934343	54	Ticket	update	---\nid: 54\ntitle: Changing categories\ndescription: Lets fix\npriority: 3\norganization_id: 2\ncreated_at: 2025-08-31 11:48:44.404539000 Z\nupdated_at: 2025-08-31 11:48:45.934343000 Z\nticket_number: CIPC_INC0001\nticket_type: Incident\nassignee_id: 10\nteam_id: 6\nrequester_id: 10\nreported_at: 2025-08-31 11:36:00.000000000 Z\ncategory: Query\ncaller_name: Charity\ncaller_surname: Mkoba\ncaller_email: charitynk@gmail.com\ncaller_phone: '0742591362'\ncustomer: Johannesburg\nsource: Web\nstatus: 1\ncreator_id: 10\nresponse_due_at: 2025-09-03 12:00:00.000000000 Z\nresolution_due_at: 2025-09-10 15:00:00.000000000 Z\nescalation_level: 0\nsla_breached: false\nsla_policy_id: 4\nurgency: 2\nimpact: 2\ncalculated_priority: 3\nresolved_at:\nresolution_note:\nsome_field:\nreason:\nresolution_method:\ncause_code:\nresolution_details:\nend_customer:\nsupport_center:\ntotal_kilometer:\ndepartment_id:\nbreaching_sla: false\n
159	\N	2025-08-31 11:48:46.119143	54	Ticket	update	---\nid: 54\ntitle: Changing categories\ndescription: Lets fix\npriority: 3\norganization_id: 2\ncreated_at: 2025-08-31 11:48:44.404539000 Z\nupdated_at: 2025-08-31 11:48:46.119143000 Z\nticket_number: CIPC_INC0001\nticket_type: Incident\nassignee_id: 10\nteam_id: 6\nrequester_id: 10\nreported_at: 2025-08-31 11:36:00.000000000 Z\ncategory: Query\ncaller_name: Charity\ncaller_surname: Mkoba\ncaller_email: charitynk@gmail.com\ncaller_phone: '0742591362'\ncustomer: Johannesburg\nsource: Web\nstatus: 1\ncreator_id: 10\nresponse_due_at: 2025-09-03 12:00:00.000000000 Z\nresolution_due_at: 2025-09-10 15:00:00.000000000 Z\nescalation_level: 0\nsla_breached: false\nsla_policy_id: 4\nurgency: 2\nimpact: 2\ncalculated_priority: 3\nresolved_at:\nresolution_note:\nsome_field:\nreason:\nresolution_method:\ncause_code:\nresolution_details:\nend_customer:\nsupport_center:\ntotal_kilometer:\ndepartment_id:\nbreaching_sla: false\n
\.


--
-- Name: active_storage_attachments_id_seq; Type: SEQUENCE SET; Schema: public; Owner: tendai
--

SELECT pg_catalog.setval('public.active_storage_attachments_id_seq', 22, true);


--
-- Name: active_storage_blobs_id_seq; Type: SEQUENCE SET; Schema: public; Owner: tendai
--

SELECT pg_catalog.setval('public.active_storage_blobs_id_seq', 22, true);


--
-- Name: active_storage_variant_records_id_seq; Type: SEQUENCE SET; Schema: public; Owner: tendai
--

SELECT pg_catalog.setval('public.active_storage_variant_records_id_seq', 1, false);


--
-- Name: business_hours_id_seq; Type: SEQUENCE SET; Schema: public; Owner: tendai
--

SELECT pg_catalog.setval('public.business_hours_id_seq', 5, true);


--
-- Name: comments_id_seq; Type: SEQUENCE SET; Schema: public; Owner: tendai
--

SELECT pg_catalog.setval('public.comments_id_seq', 54, true);


--
-- Name: departments_id_seq; Type: SEQUENCE SET; Schema: public; Owner: tendai
--

SELECT pg_catalog.setval('public.departments_id_seq', 1, false);


--
-- Name: knowledgebase_entries_id_seq; Type: SEQUENCE SET; Schema: public; Owner: tendai
--

SELECT pg_catalog.setval('public.knowledgebase_entries_id_seq', 1, false);


--
-- Name: notifications_id_seq; Type: SEQUENCE SET; Schema: public; Owner: tendai
--

SELECT pg_catalog.setval('public.notifications_id_seq', 89, true);


--
-- Name: organizations_id_seq; Type: SEQUENCE SET; Schema: public; Owner: tendai
--

SELECT pg_catalog.setval('public.organizations_id_seq', 2, true);


--
-- Name: problems_id_seq; Type: SEQUENCE SET; Schema: public; Owner: tendai
--

SELECT pg_catalog.setval('public.problems_id_seq', 1, false);


--
-- Name: settings_id_seq; Type: SEQUENCE SET; Schema: public; Owner: tendai
--

SELECT pg_catalog.setval('public.settings_id_seq', 1, false);


--
-- Name: sla_policies_id_seq; Type: SEQUENCE SET; Schema: public; Owner: tendai
--

SELECT pg_catalog.setval('public.sla_policies_id_seq', 4, true);


--
-- Name: teams_id_seq; Type: SEQUENCE SET; Schema: public; Owner: tendai
--

SELECT pg_catalog.setval('public.teams_id_seq', 6, true);


--
-- Name: tickets_id_seq; Type: SEQUENCE SET; Schema: public; Owner: tendai
--

SELECT pg_catalog.setval('public.tickets_id_seq', 54, true);


--
-- Name: tickets_inc_organization_1_seq; Type: SEQUENCE SET; Schema: public; Owner: tendai
--

SELECT pg_catalog.setval('public.tickets_inc_organization_1_seq', 3, true);


--
-- Name: tickets_inc_organization_2_seq; Type: SEQUENCE SET; Schema: public; Owner: tendai
--

SELECT pg_catalog.setval('public.tickets_inc_organization_2_seq', 1, false);


--
-- Name: tickets_prb_organization_1_seq; Type: SEQUENCE SET; Schema: public; Owner: tendai
--

SELECT pg_catalog.setval('public.tickets_prb_organization_1_seq', 1, true);


--
-- Name: tickets_prb_organization_2_seq; Type: SEQUENCE SET; Schema: public; Owner: tendai
--

SELECT pg_catalog.setval('public.tickets_prb_organization_2_seq', 1, false);


--
-- Name: tickets_req_organization_1_seq; Type: SEQUENCE SET; Schema: public; Owner: tendai
--

SELECT pg_catalog.setval('public.tickets_req_organization_1_seq', 1, true);


--
-- Name: tickets_req_organization_2_seq; Type: SEQUENCE SET; Schema: public; Owner: tendai
--

SELECT pg_catalog.setval('public.tickets_req_organization_2_seq', 1, false);


--
-- Name: users_id_seq; Type: SEQUENCE SET; Schema: public; Owner: tendai
--

SELECT pg_catalog.setval('public.users_id_seq', 12, true);


--
-- Name: versions_id_seq; Type: SEQUENCE SET; Schema: public; Owner: tendai
--

SELECT pg_catalog.setval('public.versions_id_seq', 159, true);


--
-- Name: active_storage_attachments active_storage_attachments_pkey; Type: CONSTRAINT; Schema: public; Owner: tendai
--

ALTER TABLE ONLY public.active_storage_attachments
    ADD CONSTRAINT active_storage_attachments_pkey PRIMARY KEY (id);


--
-- Name: active_storage_blobs active_storage_blobs_pkey; Type: CONSTRAINT; Schema: public; Owner: tendai
--

ALTER TABLE ONLY public.active_storage_blobs
    ADD CONSTRAINT active_storage_blobs_pkey PRIMARY KEY (id);


--
-- Name: active_storage_variant_records active_storage_variant_records_pkey; Type: CONSTRAINT; Schema: public; Owner: tendai
--

ALTER TABLE ONLY public.active_storage_variant_records
    ADD CONSTRAINT active_storage_variant_records_pkey PRIMARY KEY (id);


--
-- Name: ar_internal_metadata ar_internal_metadata_pkey; Type: CONSTRAINT; Schema: public; Owner: tendai
--

ALTER TABLE ONLY public.ar_internal_metadata
    ADD CONSTRAINT ar_internal_metadata_pkey PRIMARY KEY (key);


--
-- Name: business_hours business_hours_pkey; Type: CONSTRAINT; Schema: public; Owner: tendai
--

ALTER TABLE ONLY public.business_hours
    ADD CONSTRAINT business_hours_pkey PRIMARY KEY (id);


--
-- Name: comments comments_pkey; Type: CONSTRAINT; Schema: public; Owner: tendai
--

ALTER TABLE ONLY public.comments
    ADD CONSTRAINT comments_pkey PRIMARY KEY (id);


--
-- Name: departments departments_pkey; Type: CONSTRAINT; Schema: public; Owner: tendai
--

ALTER TABLE ONLY public.departments
    ADD CONSTRAINT departments_pkey PRIMARY KEY (id);


--
-- Name: knowledgebase_entries knowledgebase_entries_pkey; Type: CONSTRAINT; Schema: public; Owner: tendai
--

ALTER TABLE ONLY public.knowledgebase_entries
    ADD CONSTRAINT knowledgebase_entries_pkey PRIMARY KEY (id);


--
-- Name: notifications notifications_pkey; Type: CONSTRAINT; Schema: public; Owner: tendai
--

ALTER TABLE ONLY public.notifications
    ADD CONSTRAINT notifications_pkey PRIMARY KEY (id);


--
-- Name: organizations organizations_pkey; Type: CONSTRAINT; Schema: public; Owner: tendai
--

ALTER TABLE ONLY public.organizations
    ADD CONSTRAINT organizations_pkey PRIMARY KEY (id);


--
-- Name: problems problems_pkey; Type: CONSTRAINT; Schema: public; Owner: tendai
--

ALTER TABLE ONLY public.problems
    ADD CONSTRAINT problems_pkey PRIMARY KEY (id);


--
-- Name: schema_migrations schema_migrations_pkey; Type: CONSTRAINT; Schema: public; Owner: tendai
--

ALTER TABLE ONLY public.schema_migrations
    ADD CONSTRAINT schema_migrations_pkey PRIMARY KEY (version);


--
-- Name: settings settings_pkey; Type: CONSTRAINT; Schema: public; Owner: tendai
--

ALTER TABLE ONLY public.settings
    ADD CONSTRAINT settings_pkey PRIMARY KEY (id);


--
-- Name: sla_policies sla_policies_pkey; Type: CONSTRAINT; Schema: public; Owner: tendai
--

ALTER TABLE ONLY public.sla_policies
    ADD CONSTRAINT sla_policies_pkey PRIMARY KEY (id);


--
-- Name: teams teams_pkey; Type: CONSTRAINT; Schema: public; Owner: tendai
--

ALTER TABLE ONLY public.teams
    ADD CONSTRAINT teams_pkey PRIMARY KEY (id);


--
-- Name: tickets tickets_pkey; Type: CONSTRAINT; Schema: public; Owner: tendai
--

ALTER TABLE ONLY public.tickets
    ADD CONSTRAINT tickets_pkey PRIMARY KEY (id);


--
-- Name: users users_pkey; Type: CONSTRAINT; Schema: public; Owner: tendai
--

ALTER TABLE ONLY public.users
    ADD CONSTRAINT users_pkey PRIMARY KEY (id);


--
-- Name: versions versions_pkey; Type: CONSTRAINT; Schema: public; Owner: tendai
--

ALTER TABLE ONLY public.versions
    ADD CONSTRAINT versions_pkey PRIMARY KEY (id);


--
-- Name: index_active_storage_attachments_on_blob_id; Type: INDEX; Schema: public; Owner: tendai
--

CREATE INDEX index_active_storage_attachments_on_blob_id ON public.active_storage_attachments USING btree (blob_id);


--
-- Name: index_active_storage_attachments_uniqueness; Type: INDEX; Schema: public; Owner: tendai
--

CREATE UNIQUE INDEX index_active_storage_attachments_uniqueness ON public.active_storage_attachments USING btree (record_type, record_id, name, blob_id);


--
-- Name: index_active_storage_blobs_on_key; Type: INDEX; Schema: public; Owner: tendai
--

CREATE UNIQUE INDEX index_active_storage_blobs_on_key ON public.active_storage_blobs USING btree (key);


--
-- Name: index_active_storage_variant_records_uniqueness; Type: INDEX; Schema: public; Owner: tendai
--

CREATE UNIQUE INDEX index_active_storage_variant_records_uniqueness ON public.active_storage_variant_records USING btree (blob_id, variation_digest);


--
-- Name: index_business_hours_on_organization_id; Type: INDEX; Schema: public; Owner: tendai
--

CREATE INDEX index_business_hours_on_organization_id ON public.business_hours USING btree (organization_id);


--
-- Name: index_business_hours_on_organization_id_and_day_of_week; Type: INDEX; Schema: public; Owner: tendai
--

CREATE UNIQUE INDEX index_business_hours_on_organization_id_and_day_of_week ON public.business_hours USING btree (organization_id, day_of_week);


--
-- Name: index_comments_on_ticket_id; Type: INDEX; Schema: public; Owner: tendai
--

CREATE INDEX index_comments_on_ticket_id ON public.comments USING btree (ticket_id);


--
-- Name: index_comments_on_user_id; Type: INDEX; Schema: public; Owner: tendai
--

CREATE INDEX index_comments_on_user_id ON public.comments USING btree (user_id);


--
-- Name: index_departments_on_org_id_and_name; Type: INDEX; Schema: public; Owner: tendai
--

CREATE UNIQUE INDEX index_departments_on_org_id_and_name ON public.departments USING btree (organization_id, name);


--
-- Name: index_departments_on_organization_id; Type: INDEX; Schema: public; Owner: tendai
--

CREATE INDEX index_departments_on_organization_id ON public.departments USING btree (organization_id);


--
-- Name: index_knowledgebase_entries_on_organization_id; Type: INDEX; Schema: public; Owner: tendai
--

CREATE INDEX index_knowledgebase_entries_on_organization_id ON public.knowledgebase_entries USING btree (organization_id);


--
-- Name: index_notifications_on_notifiable_id_and_type; Type: INDEX; Schema: public; Owner: tendai
--

CREATE INDEX index_notifications_on_notifiable_id_and_type ON public.notifications USING btree (notifiable_id, notifiable_type);


--
-- Name: index_notifications_on_organization_id; Type: INDEX; Schema: public; Owner: tendai
--

CREATE INDEX index_notifications_on_organization_id ON public.notifications USING btree (organization_id);


--
-- Name: index_notifications_on_user_id; Type: INDEX; Schema: public; Owner: tendai
--

CREATE INDEX index_notifications_on_user_id ON public.notifications USING btree (user_id);


--
-- Name: index_organizations_on_subdomain; Type: INDEX; Schema: public; Owner: tendai
--

CREATE UNIQUE INDEX index_organizations_on_subdomain ON public.organizations USING btree (subdomain);


--
-- Name: index_problems_on_ticket_id; Type: INDEX; Schema: public; Owner: tendai
--

CREATE INDEX index_problems_on_ticket_id ON public.problems USING btree (ticket_id);


--
-- Name: index_problems_on_user_id; Type: INDEX; Schema: public; Owner: tendai
--

CREATE INDEX index_problems_on_user_id ON public.problems USING btree (user_id);


--
-- Name: index_settings_on_organization_id; Type: INDEX; Schema: public; Owner: tendai
--

CREATE INDEX index_settings_on_organization_id ON public.settings USING btree (organization_id);


--
-- Name: index_sla_policies_on_org_id_and_priority; Type: INDEX; Schema: public; Owner: tendai
--

CREATE UNIQUE INDEX index_sla_policies_on_org_id_and_priority ON public.sla_policies USING btree (organization_id, priority);


--
-- Name: index_sla_policies_on_organization_id; Type: INDEX; Schema: public; Owner: tendai
--

CREATE INDEX index_sla_policies_on_organization_id ON public.sla_policies USING btree (organization_id);


--
-- Name: index_tickets_on_assignee_id; Type: INDEX; Schema: public; Owner: tendai
--

CREATE INDEX index_tickets_on_assignee_id ON public.tickets USING btree (assignee_id);


--
-- Name: index_tickets_on_breaching_sla; Type: INDEX; Schema: public; Owner: tendai
--

CREATE INDEX index_tickets_on_breaching_sla ON public.tickets USING btree (breaching_sla);


--
-- Name: index_tickets_on_creator_id; Type: INDEX; Schema: public; Owner: tendai
--

CREATE INDEX index_tickets_on_creator_id ON public.tickets USING btree (creator_id);


--
-- Name: index_tickets_on_department_id; Type: INDEX; Schema: public; Owner: tendai
--

CREATE INDEX index_tickets_on_department_id ON public.tickets USING btree (department_id);


--
-- Name: index_tickets_on_impact; Type: INDEX; Schema: public; Owner: tendai
--

CREATE INDEX index_tickets_on_impact ON public.tickets USING btree (impact);


--
-- Name: index_tickets_on_org_id_and_sla_breached; Type: INDEX; Schema: public; Owner: tendai
--

CREATE INDEX index_tickets_on_org_id_and_sla_breached ON public.tickets USING btree (organization_id, sla_breached);


--
-- Name: index_tickets_on_organization_id; Type: INDEX; Schema: public; Owner: tendai
--

CREATE INDEX index_tickets_on_organization_id ON public.tickets USING btree (organization_id);


--
-- Name: index_tickets_on_priority; Type: INDEX; Schema: public; Owner: tendai
--

CREATE INDEX index_tickets_on_priority ON public.tickets USING btree (priority);


--
-- Name: index_tickets_on_resolution_due_at; Type: INDEX; Schema: public; Owner: tendai
--

CREATE INDEX index_tickets_on_resolution_due_at ON public.tickets USING btree (resolution_due_at);


--
-- Name: index_tickets_on_response_due_at; Type: INDEX; Schema: public; Owner: tendai
--

CREATE INDEX index_tickets_on_response_due_at ON public.tickets USING btree (response_due_at);


--
-- Name: index_tickets_on_sla_breached; Type: INDEX; Schema: public; Owner: tendai
--

CREATE INDEX index_tickets_on_sla_breached ON public.tickets USING btree (sla_breached);


--
-- Name: index_tickets_on_sla_policy_id; Type: INDEX; Schema: public; Owner: tendai
--

CREATE INDEX index_tickets_on_sla_policy_id ON public.tickets USING btree (sla_policy_id);


--
-- Name: index_tickets_on_status; Type: INDEX; Schema: public; Owner: tendai
--

CREATE INDEX index_tickets_on_status ON public.tickets USING btree (status);


--
-- Name: index_tickets_on_team_id; Type: INDEX; Schema: public; Owner: tendai
--

CREATE INDEX index_tickets_on_team_id ON public.tickets USING btree (team_id);


--
-- Name: index_tickets_on_ticket_number; Type: INDEX; Schema: public; Owner: tendai
--

CREATE UNIQUE INDEX index_tickets_on_ticket_number ON public.tickets USING btree (ticket_number);


--
-- Name: index_tickets_on_urgency; Type: INDEX; Schema: public; Owner: tendai
--

CREATE INDEX index_tickets_on_urgency ON public.tickets USING btree (urgency);


--
-- Name: index_users_on_department_id; Type: INDEX; Schema: public; Owner: tendai
--

CREATE INDEX index_users_on_department_id ON public.users USING btree (department_id);


--
-- Name: index_users_on_email; Type: INDEX; Schema: public; Owner: tendai
--

CREATE UNIQUE INDEX index_users_on_email ON public.users USING btree (email);


--
-- Name: index_users_on_new_reset_password_token; Type: INDEX; Schema: public; Owner: tendai
--

CREATE UNIQUE INDEX index_users_on_new_reset_password_token ON public.users USING btree (new_reset_password_token);


--
-- Name: index_users_on_organization_id; Type: INDEX; Schema: public; Owner: tendai
--

CREATE INDEX index_users_on_organization_id ON public.users USING btree (organization_id);


--
-- Name: index_users_on_reset_password_sent_at_when_token_present; Type: INDEX; Schema: public; Owner: tendai
--

CREATE INDEX index_users_on_reset_password_sent_at_when_token_present ON public.users USING btree (reset_password_sent_at) WHERE (reset_password_token IS NOT NULL);


--
-- Name: index_users_on_reset_password_token; Type: INDEX; Schema: public; Owner: tendai
--

CREATE UNIQUE INDEX index_users_on_reset_password_token ON public.users USING btree (reset_password_token);


--
-- Name: index_users_on_username_and_organization_id; Type: INDEX; Schema: public; Owner: tendai
--

CREATE UNIQUE INDEX index_users_on_username_and_organization_id ON public.users USING btree (username, organization_id);


--
-- Name: index_versions_on_item_type_and_item_id; Type: INDEX; Schema: public; Owner: tendai
--

CREATE INDEX index_versions_on_item_type_and_item_id ON public.versions USING btree (item_type, item_id);


--
-- Name: comments fk_rails_03de2dc08c; Type: FK CONSTRAINT; Schema: public; Owner: tendai
--

ALTER TABLE ONLY public.comments
    ADD CONSTRAINT fk_rails_03de2dc08c FOREIGN KEY (user_id) REFERENCES public.users(id);


--
-- Name: tickets fk_rails_043f0bb452; Type: FK CONSTRAINT; Schema: public; Owner: tendai
--

ALTER TABLE ONLY public.tickets
    ADD CONSTRAINT fk_rails_043f0bb452 FOREIGN KEY (team_id) REFERENCES public.teams(id);


--
-- Name: problems fk_rails_14805000ad; Type: FK CONSTRAINT; Schema: public; Owner: tendai
--

ALTER TABLE ONLY public.problems
    ADD CONSTRAINT fk_rails_14805000ad FOREIGN KEY (ticket_id) REFERENCES public.tickets(id);


--
-- Name: settings fk_rails_1576d28a24; Type: FK CONSTRAINT; Schema: public; Owner: tendai
--

ALTER TABLE ONLY public.settings
    ADD CONSTRAINT fk_rails_1576d28a24 FOREIGN KEY (organization_id) REFERENCES public.organizations(id);


--
-- Name: tickets fk_rails_1655950f2c; Type: FK CONSTRAINT; Schema: public; Owner: tendai
--

ALTER TABLE ONLY public.tickets
    ADD CONSTRAINT fk_rails_1655950f2c FOREIGN KEY (department_id) REFERENCES public.departments(id);


--
-- Name: knowledgebase_entries fk_rails_169afdd79b; Type: FK CONSTRAINT; Schema: public; Owner: tendai
--

ALTER TABLE ONLY public.knowledgebase_entries
    ADD CONSTRAINT fk_rails_169afdd79b FOREIGN KEY (organization_id) REFERENCES public.organizations(id);


--
-- Name: business_hours fk_rails_35acd7f354; Type: FK CONSTRAINT; Schema: public; Owner: tendai
--

ALTER TABLE ONLY public.business_hours
    ADD CONSTRAINT fk_rails_35acd7f354 FOREIGN KEY (organization_id) REFERENCES public.organizations(id);


--
-- Name: notifications fk_rails_394d9847aa; Type: FK CONSTRAINT; Schema: public; Owner: tendai
--

ALTER TABLE ONLY public.notifications
    ADD CONSTRAINT fk_rails_394d9847aa FOREIGN KEY (organization_id) REFERENCES public.organizations(id);


--
-- Name: tickets fk_rails_538a036fb9; Type: FK CONSTRAINT; Schema: public; Owner: tendai
--

ALTER TABLE ONLY public.tickets
    ADD CONSTRAINT fk_rails_538a036fb9 FOREIGN KEY (user_id) REFERENCES public.users(id);


--
-- Name: sla_policies fk_rails_7f66676233; Type: FK CONSTRAINT; Schema: public; Owner: tendai
--

ALTER TABLE ONLY public.sla_policies
    ADD CONSTRAINT fk_rails_7f66676233 FOREIGN KEY (organization_id) REFERENCES public.organizations(id);


--
-- Name: tickets fk_rails_8f99a28577; Type: FK CONSTRAINT; Schema: public; Owner: tendai
--

ALTER TABLE ONLY public.tickets
    ADD CONSTRAINT fk_rails_8f99a28577 FOREIGN KEY (sla_policy_id) REFERENCES public.sla_policies(id);


--
-- Name: tickets fk_rails_93ed706a38; Type: FK CONSTRAINT; Schema: public; Owner: tendai
--

ALTER TABLE ONLY public.tickets
    ADD CONSTRAINT fk_rails_93ed706a38 FOREIGN KEY (requester_id) REFERENCES public.users(id);


--
-- Name: departments fk_rails_94440b0e8f; Type: FK CONSTRAINT; Schema: public; Owner: tendai
--

ALTER TABLE ONLY public.departments
    ADD CONSTRAINT fk_rails_94440b0e8f FOREIGN KEY (organization_id) REFERENCES public.organizations(id);


--
-- Name: active_storage_variant_records fk_rails_993965df05; Type: FK CONSTRAINT; Schema: public; Owner: tendai
--

ALTER TABLE ONLY public.active_storage_variant_records
    ADD CONSTRAINT fk_rails_993965df05 FOREIGN KEY (blob_id) REFERENCES public.active_storage_blobs(id);


--
-- Name: notifications fk_rails_b080fb4855; Type: FK CONSTRAINT; Schema: public; Owner: tendai
--

ALTER TABLE ONLY public.notifications
    ADD CONSTRAINT fk_rails_b080fb4855 FOREIGN KEY (user_id) REFERENCES public.users(id);


--
-- Name: problems fk_rails_b0b42588cb; Type: FK CONSTRAINT; Schema: public; Owner: tendai
--

ALTER TABLE ONLY public.problems
    ADD CONSTRAINT fk_rails_b0b42588cb FOREIGN KEY (user_id) REFERENCES public.users(id);


--
-- Name: users fk_rails_b2bbf87303; Type: FK CONSTRAINT; Schema: public; Owner: tendai
--

ALTER TABLE ONLY public.users
    ADD CONSTRAINT fk_rails_b2bbf87303 FOREIGN KEY (team_id) REFERENCES public.teams(id);


--
-- Name: tickets fk_rails_b62b455ecb; Type: FK CONSTRAINT; Schema: public; Owner: tendai
--

ALTER TABLE ONLY public.tickets
    ADD CONSTRAINT fk_rails_b62b455ecb FOREIGN KEY (organization_id) REFERENCES public.organizations(id);


--
-- Name: active_storage_attachments fk_rails_c3b3935057; Type: FK CONSTRAINT; Schema: public; Owner: tendai
--

ALTER TABLE ONLY public.active_storage_attachments
    ADD CONSTRAINT fk_rails_c3b3935057 FOREIGN KEY (blob_id) REFERENCES public.active_storage_blobs(id);


--
-- Name: users fk_rails_d7b9ff90af; Type: FK CONSTRAINT; Schema: public; Owner: tendai
--

ALTER TABLE ONLY public.users
    ADD CONSTRAINT fk_rails_d7b9ff90af FOREIGN KEY (organization_id) REFERENCES public.organizations(id);


--
-- Name: comments fk_rails_e013b60ecb; Type: FK CONSTRAINT; Schema: public; Owner: tendai
--

ALTER TABLE ONLY public.comments
    ADD CONSTRAINT fk_rails_e013b60ecb FOREIGN KEY (ticket_id) REFERENCES public.tickets(id);


--
-- Name: tickets fk_rails_ea25a37fb1; Type: FK CONSTRAINT; Schema: public; Owner: tendai
--

ALTER TABLE ONLY public.tickets
    ADD CONSTRAINT fk_rails_ea25a37fb1 FOREIGN KEY (assignee_id) REFERENCES public.users(id);


--
-- Name: teams fk_rails_f07f0bd66d; Type: FK CONSTRAINT; Schema: public; Owner: tendai
--

ALTER TABLE ONLY public.teams
    ADD CONSTRAINT fk_rails_f07f0bd66d FOREIGN KEY (organization_id) REFERENCES public.organizations(id);


--
-- Name: users fk_rails_f29bf9cdf2; Type: FK CONSTRAINT; Schema: public; Owner: tendai
--

ALTER TABLE ONLY public.users
    ADD CONSTRAINT fk_rails_f29bf9cdf2 FOREIGN KEY (department_id) REFERENCES public.departments(id);


--
-- PostgreSQL database dump complete
--

