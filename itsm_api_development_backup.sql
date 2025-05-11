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
    updated_at timestamp(6) without time zone NOT NULL
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
    updated_at timestamp(6) without time zone NOT NULL
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
    team_id integer
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
-- Name: sla_policies; Type: TABLE; Schema: public; Owner: tendai
--

CREATE TABLE public.sla_policies (
    id bigint NOT NULL,
    organization_id bigint NOT NULL,
    priority integer,
    response_time integer,
    resolution_time integer,
    created_at timestamp(6) without time zone NOT NULL,
    updated_at timestamp(6) without time zone NOT NULL
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
    updated_at timestamp(6) without time zone NOT NULL
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
    some_field character varying
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
-- Name: users; Type: TABLE; Schema: public; Owner: tendai
--

CREATE TABLE public.users (
    id bigint NOT NULL,
    name character varying,
    email character varying,
    password_digest character varying,
    role integer,
    organization_id bigint NOT NULL,
    created_at timestamp(6) without time zone NOT NULL,
    updated_at timestamp(6) without time zone NOT NULL,
    department character varying,
    "position" character varying,
    team_id bigint,
    auth_token character varying,
    username character varying,
    phone_number character varying,
    receive_email_notifications boolean DEFAULT true NOT NULL
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
-- Name: business_hours id; Type: DEFAULT; Schema: public; Owner: tendai
--

ALTER TABLE ONLY public.business_hours ALTER COLUMN id SET DEFAULT nextval('public.business_hours_id_seq'::regclass);


--
-- Name: comments id; Type: DEFAULT; Schema: public; Owner: tendai
--

ALTER TABLE ONLY public.comments ALTER COLUMN id SET DEFAULT nextval('public.comments_id_seq'::regclass);


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
-- Data for Name: ar_internal_metadata; Type: TABLE DATA; Schema: public; Owner: tendai
--

COPY public.ar_internal_metadata (key, value, created_at, updated_at) FROM stdin;
environment	development	2025-05-09 08:50:44.650255	2025-05-09 08:50:44.65026
schema_sha1	4bab0b743d099cf7886ce6559fc8ef104ba5ab80	2025-05-09 08:50:44.682071	2025-05-09 08:50:44.682074
\.


--
-- Data for Name: business_hours; Type: TABLE DATA; Schema: public; Owner: tendai
--

COPY public.business_hours (id, organization_id, day_of_week, start_time, end_time, created_at, updated_at) FROM stdin;
1	1	1	09:00:00	17:00:00	2025-05-09 08:51:28.204593	2025-05-09 08:51:28.204593
2	1	2	09:00:00	17:00:00	2025-05-09 08:51:28.221225	2025-05-09 08:51:28.221225
3	1	3	09:00:00	17:00:00	2025-05-09 08:51:28.252964	2025-05-09 08:51:28.252964
4	1	4	09:00:00	17:00:00	2025-05-09 08:51:28.267023	2025-05-09 08:51:28.267023
5	1	5	09:00:00	17:00:00	2025-05-09 08:51:28.282971	2025-05-09 08:51:28.282971
\.


--
-- Data for Name: comments; Type: TABLE DATA; Schema: public; Owner: tendai
--

COPY public.comments (id, content, user_id, ticket_id, created_at, updated_at) FROM stdin;
\.


--
-- Data for Name: notifications; Type: TABLE DATA; Schema: public; Owner: tendai
--

COPY public.notifications (id, user_id, organization_id, message, read, created_at, updated_at, notifiable_id, notifiable_type) FROM stdin;
1	1	1	You've been added to the team: IT Support	f	2025-05-09 08:51:28.022808	2025-05-09 08:51:28.022808	\N	\N
2	2	1	You've been added to the team: IT Support	f	2025-05-09 08:51:28.061172	2025-05-09 08:51:28.061172	\N	\N
3	3	1	You've been added to the team: IT Support	f	2025-05-09 08:51:28.075155	2025-05-09 08:51:28.075155	\N	\N
4	4	1	You've been added to the team: IT Support	f	2025-05-09 08:51:28.090441	2025-05-09 08:51:28.090441	\N	\N
5	1	1	New ticket created: Email Client Not Working (INCCT7OFBSS)	f	2025-05-09 08:51:28.36753	2025-05-09 08:51:28.36753	1	Ticket
6	1	1	New ticket created: VPN Connection Issues (INC615RS1U8)	f	2025-05-09 08:51:28.426149	2025-05-09 08:51:28.426149	2	Ticket
7	1	1	New ticket created: New Employee Setup (REQBRBXOKUX)	f	2025-05-09 08:51:28.46888	2025-05-09 08:51:28.46888	3	Ticket
8	2	1	You have been assigned a new ticket: Email Client Not Working (INCCT7OFBSS)	f	2025-05-09 08:51:28.490954	2025-05-09 08:51:28.490954	1	Ticket
9	3	1	You have been assigned a new ticket: VPN Connection Issues (INC615RS1U8)	f	2025-05-09 08:51:28.507963	2025-05-09 08:51:28.507963	2	Ticket
10	4	1	You have been assigned a new ticket: New Employee Setup (REQBRBXOKUX)	f	2025-05-09 08:51:28.523643	2025-05-09 08:51:28.523643	3	Ticket
\.


--
-- Data for Name: organizations; Type: TABLE DATA; Schema: public; Owner: tendai
--

COPY public.organizations (id, name, address, email, web_address, subdomain, phone_number, created_at, updated_at) FROM stdin;
1	GreenSoft Solutions	123 Tech Lane, Innovation City	contact@greensoft.com	https://greensoft.com	greensoft-solutions	555-123-4567	2025-05-09 08:51:26.60323	2025-05-09 08:51:26.60323
\.


--
-- Data for Name: problems; Type: TABLE DATA; Schema: public; Owner: tendai
--

COPY public.problems (id, description, ticket_id, created_at, updated_at, user_id, organization_id, creator_id, team_id) FROM stdin;
\.


--
-- Data for Name: schema_migrations; Type: TABLE DATA; Schema: public; Owner: tendai
--

COPY public.schema_migrations (version) FROM stdin;
20250509053918
20250509010101
20250508101031
20250501100455
20250501095528
20250430082504
20250325190223
20250318131803
\.


--
-- Data for Name: sla_policies; Type: TABLE DATA; Schema: public; Owner: tendai
--

COPY public.sla_policies (id, organization_id, priority, response_time, resolution_time, created_at, updated_at) FROM stdin;
1	1	1	60	480	2025-05-09 08:51:28.158989	2025-05-09 08:51:28.158989
\.


--
-- Data for Name: teams; Type: TABLE DATA; Schema: public; Owner: tendai
--

COPY public.teams (id, name, organization_id, created_at, updated_at) FROM stdin;
1	IT Support	1	2025-05-09 08:51:27.938882	2025-05-09 08:51:27.938882
2	Fixers	1	2025-05-09 09:10:02.412226	2025-05-09 09:10:02.412226
\.


--
-- Data for Name: tickets; Type: TABLE DATA; Schema: public; Owner: tendai
--

COPY public.tickets (id, title, description, priority, organization_id, created_at, updated_at, ticket_number, ticket_type, assignee_id, team_id, requester_id, reported_at, category, caller_name, caller_surname, caller_email, caller_phone, customer, source, status, creator_id, response_due_at, resolution_due_at, escalation_level, sla_breached, sla_policy_id, urgency, impact, calculated_priority, resolved_at, resolution_note, user_id, some_field) FROM stdin;
1	Email Client Not Working	User reports email client crashing on launch.	1	1	2025-05-09 08:51:28.325719	2025-05-09 08:51:28.325719	INCCT7OFBSS	Incident	2	1	1	2025-05-09 06:51:28.290494	Software	Jane	Smith	jane.smith@greensoft.com	555-987-6543	Internal IT	Email	1	1	2025-05-09 07:51:28.290494	2025-05-09 14:51:28.290494	0	t	1	1	1	1	\N	\N	\N	\N
2	VPN Connection Issues	User cannot connect to VPN from home office.	2	1	2025-05-09 08:51:28.404109	2025-05-09 08:51:28.404109	INC615RS1U8	Incident	3	1	1	2025-05-09 07:51:28.290594	Software	John	Doe	john.doe@greensoft.com	555-123-4567	Internal IT	Phone	1	1	2025-05-09 08:51:28.290594	2025-05-09 15:51:28.290594	0	t	1	2	1	2	\N	\N	\N	\N
3	New Employee Setup	Setup workstation and accounts for new hire.	0	1	2025-05-09 08:51:28.449938	2025-05-09 08:51:28.449938	REQBRBXOKUX	Request	4	1	1	2025-05-09 08:21:28.290604	Software	HR	Manager	hr@greensoft.com	555-456-7890	HR	Email	1	1	2025-05-09 09:21:28.290604	2025-05-09 16:21:28.290604	0	f	1	0	0	0	\N	\N	\N	\N
\.


--
-- Data for Name: users; Type: TABLE DATA; Schema: public; Owner: tendai
--

COPY public.users (id, name, email, password_digest, role, organization_id, created_at, updated_at, department, "position", team_id, auth_token, username, phone_number, receive_email_notifications) FROM stdin;
5	Admin	admin@greensoft.com	$2a$12$u8OITPJucdwHWLwqpx/NtO/4EUuXn7cIn3tMyZDH.dCKJgMBE3RwC	0	1	2025-05-09 08:51:27.91814	2025-05-09 08:51:27.91814	\N	\N	\N	admin_token_123	\N	\N	t
1	IT Manager	it.manager@greensoft.com	$2a$12$5HAsctKAQ2sxeyGQ39xJFeHdoHH9RteAtegfrNbhfkkXXU4iDv2XK	2	1	2025-05-09 08:51:27.039259	2025-05-09 08:51:27.986729	\N	\N	1	itmanager_token_456	\N	\N	t
2	Support Tech	support.tech@greensoft.com	$2a$12$.hGTpAyiOPtf4opeEDKskuXzNMVCGqqb8sa5CnzmaP70PnODVNxMC	3	1	2025-05-09 08:51:27.27026	2025-05-09 08:51:28.054979	\N	\N	1	supporttech_token_789	\N	\N	t
3	Network Tech	network@greensoft.com	$2a$12$HUcYgE820N3cxbkcIXupNO.6OuXEKD4nLclUriV5NcFzGvK33ZznC	3	1	2025-05-09 08:51:27.486125	2025-05-09 08:51:28.070451	\N	\N	1	networktech_token_012	\N	\N	t
4	Helpdesk	helpdesk@greensoft.com	$2a$12$HOGcT7KyRg/U8BA2f4IdHO3Tri0XE53zyo/L34gBYwy/Rq86Qj5uG	3	1	2025-05-09 08:51:27.704028	2025-05-09 08:51:28.085841	\N	\N	1	helpdesk_token_345	\N	\N	t
6	Tendai Nyandoro	tendain@greensoftsolutions.net	$2a$12$3SLqE1hKldiWsOGIdHI06.yUDFooRQ3C24o8xLxMsK0QwUSlY1PUy	3	1	2025-05-09 09:08:05.048882	2025-05-09 09:08:05.048882	Software	Full Stack Dev	2	b17ae5351ff763ea87dc826402f266b8a8003b8f	Tendai	0742591362	t
7	Imbu Kinzamba	imbuk@greensoftsolutions.net	$2a$12$gZWgvXkS6GAJmNZsf5rKAOtQrOeEBit3q5bCX1iU9hijoEjTpJ3PK	3	1	2025-05-09 09:09:05.700708	2025-05-09 09:09:05.700708	Service	Service Desk	2	564e639e4b8d7b5e4a6a079b433fb660d037aac6	Herve	+27 63 019 0641	t
8	Vibha Mangrulkar	vibham@greensoftsolutions.net	$2a$12$5Nun515YHbgnahumtnr6ueQa/a2GysNmPxURR3VAHsMyLxXWwBlhO	3	1	2025-05-09 09:09:47.090162	2025-05-09 09:09:47.090162	Software	Mobile	2	35240e5401b101d608db574a5ac60d0c712aff2b	Vibha	+27613872472	t
\.


--
-- Name: business_hours_id_seq; Type: SEQUENCE SET; Schema: public; Owner: tendai
--

SELECT pg_catalog.setval('public.business_hours_id_seq', 5, true);


--
-- Name: comments_id_seq; Type: SEQUENCE SET; Schema: public; Owner: tendai
--

SELECT pg_catalog.setval('public.comments_id_seq', 1, false);


--
-- Name: notifications_id_seq; Type: SEQUENCE SET; Schema: public; Owner: tendai
--

SELECT pg_catalog.setval('public.notifications_id_seq', 10, true);


--
-- Name: organizations_id_seq; Type: SEQUENCE SET; Schema: public; Owner: tendai
--

SELECT pg_catalog.setval('public.organizations_id_seq', 1, true);


--
-- Name: problems_id_seq; Type: SEQUENCE SET; Schema: public; Owner: tendai
--

SELECT pg_catalog.setval('public.problems_id_seq', 1, false);


--
-- Name: sla_policies_id_seq; Type: SEQUENCE SET; Schema: public; Owner: tendai
--

SELECT pg_catalog.setval('public.sla_policies_id_seq', 1, true);


--
-- Name: teams_id_seq; Type: SEQUENCE SET; Schema: public; Owner: tendai
--

SELECT pg_catalog.setval('public.teams_id_seq', 2, true);


--
-- Name: tickets_id_seq; Type: SEQUENCE SET; Schema: public; Owner: tendai
--

SELECT pg_catalog.setval('public.tickets_id_seq', 3, true);


--
-- Name: users_id_seq; Type: SEQUENCE SET; Schema: public; Owner: tendai
--

SELECT pg_catalog.setval('public.users_id_seq', 8, true);


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
-- Name: index_sla_policies_on_organization_id; Type: INDEX; Schema: public; Owner: tendai
--

CREATE INDEX index_sla_policies_on_organization_id ON public.sla_policies USING btree (organization_id);


--
-- Name: index_tickets_on_creator_id; Type: INDEX; Schema: public; Owner: tendai
--

CREATE INDEX index_tickets_on_creator_id ON public.tickets USING btree (creator_id);


--
-- Name: index_tickets_on_organization_id; Type: INDEX; Schema: public; Owner: tendai
--

CREATE INDEX index_tickets_on_organization_id ON public.tickets USING btree (organization_id);


--
-- Name: index_tickets_on_sla_policy_id; Type: INDEX; Schema: public; Owner: tendai
--

CREATE INDEX index_tickets_on_sla_policy_id ON public.tickets USING btree (sla_policy_id);


--
-- Name: index_tickets_on_ticket_number; Type: INDEX; Schema: public; Owner: tendai
--

CREATE UNIQUE INDEX index_tickets_on_ticket_number ON public.tickets USING btree (ticket_number);


--
-- Name: index_users_on_email; Type: INDEX; Schema: public; Owner: tendai
--

CREATE UNIQUE INDEX index_users_on_email ON public.users USING btree (email);


--
-- Name: index_users_on_organization_id; Type: INDEX; Schema: public; Owner: tendai
--

CREATE INDEX index_users_on_organization_id ON public.users USING btree (organization_id);


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
-- PostgreSQL database dump complete
--

