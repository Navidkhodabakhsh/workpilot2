--
-- PostgreSQL database dump
--


-- Dumped from database version 16.13 (Ubuntu 16.13-0ubuntu0.24.04.1)
-- Dumped by pg_dump version 16.13 (Ubuntu 16.13-0ubuntu0.24.04.1)

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
-- Name: approvalstatus; Type: TYPE; Schema: public; Owner: -
--

CREATE TYPE public.approvalstatus AS ENUM (
    'pending',
    'approved',
    'rejected'
);


--
-- Name: calendareventtype; Type: TYPE; Schema: public; Owner: -
--

CREATE TYPE public.calendareventtype AS ENUM (
    'meeting',
    'leave',
    'holiday',
    'reminder'
);


--
-- Name: exportfiletype; Type: TYPE; Schema: public; Owner: -
--

CREATE TYPE public.exportfiletype AS ENUM (
    'excel',
    'pdf',
    'csv'
);


--
-- Name: exportjobstatus; Type: TYPE; Schema: public; Owner: -
--

CREATE TYPE public.exportjobstatus AS ENUM (
    'pending',
    'processing',
    'done',
    'failed'
);


--
-- Name: financeentrytype; Type: TYPE; Schema: public; Owner: -
--

CREATE TYPE public.financeentrytype AS ENUM (
    'income',
    'expense'
);


--
-- Name: notificationtype; Type: TYPE; Schema: public; Owner: -
--

CREATE TYPE public.notificationtype AS ENUM (
    'task_created',
    'deadline_approaching',
    'report_submitted',
    'report_reviewed',
    'comment_added',
    'event_reminder',
    'leave_reviewed'
);


--
-- Name: otppurpose; Type: TYPE; Schema: public; Owner: -
--

CREATE TYPE public.otppurpose AS ENUM (
    'login',
    'password_reset'
);


--
-- Name: projectstatus; Type: TYPE; Schema: public; Owner: -
--

CREATE TYPE public.projectstatus AS ENUM (
    'active',
    'completed',
    'archived'
);


--
-- Name: taskpriority; Type: TYPE; Schema: public; Owner: -
--

CREATE TYPE public.taskpriority AS ENUM (
    'low',
    'medium',
    'high'
);


--
-- Name: taskstatus; Type: TYPE; Schema: public; Owner: -
--

CREATE TYPE public.taskstatus AS ENUM (
    'todo',
    'in_progress',
    'completed',
    'archived'
);


--
-- Name: taskvalue; Type: TYPE; Schema: public; Owner: -
--

CREATE TYPE public.taskvalue AS ENUM (
    'low',
    'medium',
    'high'
);


--
-- Name: userrole; Type: TYPE; Schema: public; Owner: -
--

CREATE TYPE public.userrole AS ENUM (
    'platform_admin',
    'org_admin',
    'project_manager',
    'employee'
);


--
-- Name: worklogstatus; Type: TYPE; Schema: public; Owner: -
--

CREATE TYPE public.worklogstatus AS ENUM (
    'draft',
    'submitted',
    'approved',
    'rejected'
);


SET default_tablespace = '';

SET default_table_access_method = heap;

--
-- Name: accounts; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.accounts (
    id uuid NOT NULL,
    created_at timestamp with time zone DEFAULT now(),
    updated_at timestamp with time zone DEFAULT now(),
    phone_number character varying(32) NOT NULL,
    hashed_password character varying(255)
);


--
-- Name: alembic_version; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.alembic_version (
    version_num character varying(32) NOT NULL
);


--
-- Name: attachments; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.attachments (
    organization_id uuid NOT NULL,
    task_id uuid NOT NULL,
    uploaded_by_id uuid NOT NULL,
    file_path character varying(500) NOT NULL,
    original_filename character varying(300) NOT NULL,
    content_type character varying(150) NOT NULL,
    size_bytes integer NOT NULL,
    id uuid NOT NULL,
    created_at timestamp with time zone DEFAULT now() NOT NULL,
    updated_at timestamp with time zone DEFAULT now() NOT NULL
);


--
-- Name: audit_logs; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.audit_logs (
    created_at timestamp with time zone DEFAULT now() NOT NULL,
    organization_id uuid,
    actor_user_id uuid,
    action character varying(100) NOT NULL,
    entity_type character varying(100) NOT NULL,
    entity_id character varying(100) NOT NULL,
    extra_metadata jsonb NOT NULL,
    id uuid NOT NULL
);


--
-- Name: calendar_events; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.calendar_events (
    id uuid NOT NULL,
    created_at timestamp with time zone DEFAULT now(),
    updated_at timestamp with time zone DEFAULT now(),
    organization_id uuid NOT NULL,
    created_by_id uuid NOT NULL,
    project_id uuid,
    user_id uuid,
    title character varying(300) NOT NULL,
    description text,
    event_type public.calendareventtype NOT NULL,
    start_at timestamp with time zone NOT NULL,
    end_at timestamp with time zone NOT NULL,
    all_day boolean DEFAULT false NOT NULL
);


--
-- Name: comments; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.comments (
    organization_id uuid NOT NULL,
    task_id uuid NOT NULL,
    author_id uuid NOT NULL,
    body text NOT NULL,
    id uuid NOT NULL,
    created_at timestamp with time zone DEFAULT now() NOT NULL,
    updated_at timestamp with time zone DEFAULT now() NOT NULL
);


--
-- Name: department_memberships; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.department_memberships (
    id uuid NOT NULL,
    created_at timestamp with time zone DEFAULT now(),
    updated_at timestamp with time zone DEFAULT now(),
    organization_id uuid NOT NULL,
    user_id uuid NOT NULL,
    department_id uuid NOT NULL,
    role public.userrole NOT NULL
);


--
-- Name: departments; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.departments (
    id uuid NOT NULL,
    created_at timestamp with time zone DEFAULT now(),
    updated_at timestamp with time zone DEFAULT now(),
    organization_id uuid NOT NULL,
    name character varying(200) NOT NULL
);


--
-- Name: export_jobs; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.export_jobs (
    organization_id uuid NOT NULL,
    requested_by_id uuid NOT NULL,
    export_type public.exportfiletype NOT NULL,
    filters jsonb NOT NULL,
    status public.exportjobstatus NOT NULL,
    file_path character varying(500),
    error_message text,
    completed_at timestamp with time zone,
    id uuid NOT NULL,
    created_at timestamp with time zone DEFAULT now() NOT NULL,
    updated_at timestamp with time zone DEFAULT now() NOT NULL
);


--
-- Name: finance_categories; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.finance_categories (
    id uuid NOT NULL,
    created_at timestamp with time zone DEFAULT now(),
    updated_at timestamp with time zone DEFAULT now(),
    organization_id uuid NOT NULL,
    entry_type public.financeentrytype NOT NULL,
    name character varying(120) NOT NULL,
    color character varying(20) DEFAULT '#64748b'::character varying NOT NULL,
    is_system boolean DEFAULT false NOT NULL
);


--
-- Name: finance_entries; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.finance_entries (
    id uuid NOT NULL,
    created_at timestamp with time zone DEFAULT now(),
    updated_at timestamp with time zone DEFAULT now(),
    organization_id uuid NOT NULL,
    category_id uuid NOT NULL,
    project_id uuid,
    recorded_by_id uuid NOT NULL,
    entry_type public.financeentrytype NOT NULL,
    document_date date NOT NULL,
    amount numeric(16,2) NOT NULL,
    title character varying(240) NOT NULL,
    description text,
    document_number character varying(100),
    counterparty character varying(200)
);


--
-- Name: leave_requests; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.leave_requests (
    id uuid NOT NULL,
    created_at timestamp with time zone DEFAULT now(),
    updated_at timestamp with time zone DEFAULT now(),
    organization_id uuid NOT NULL,
    user_id uuid NOT NULL,
    start_date date NOT NULL,
    end_date date NOT NULL,
    reason text,
    status public.approvalstatus DEFAULT 'pending'::public.approvalstatus NOT NULL,
    reviewed_by_id uuid,
    review_comment text
);


--
-- Name: notifications; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.notifications (
    organization_id uuid NOT NULL,
    user_id uuid NOT NULL,
    type public.notificationtype NOT NULL,
    payload jsonb NOT NULL,
    is_read boolean NOT NULL,
    id uuid NOT NULL,
    created_at timestamp with time zone DEFAULT now() NOT NULL,
    updated_at timestamp with time zone DEFAULT now() NOT NULL
);


--
-- Name: organizations; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.organizations (
    name character varying(200) NOT NULL,
    slug character varying(100) NOT NULL,
    is_active boolean NOT NULL,
    id uuid NOT NULL,
    created_at timestamp with time zone DEFAULT now() NOT NULL,
    updated_at timestamp with time zone DEFAULT now() NOT NULL
);


--
-- Name: otp_codes; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.otp_codes (
    id uuid NOT NULL,
    created_at timestamp with time zone DEFAULT now(),
    updated_at timestamp with time zone DEFAULT now(),
    phone_number character varying(32) NOT NULL,
    code_hash character varying(255) NOT NULL,
    purpose public.otppurpose NOT NULL,
    expires_at timestamp with time zone NOT NULL,
    consumed_at timestamp with time zone,
    attempt_count integer DEFAULT 0 NOT NULL
);


--
-- Name: payments; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.payments (
    id uuid NOT NULL,
    created_at timestamp with time zone DEFAULT now(),
    updated_at timestamp with time zone DEFAULT now(),
    organization_id uuid NOT NULL,
    project_id uuid NOT NULL,
    recorded_by_id uuid NOT NULL,
    payment_date date NOT NULL,
    description text NOT NULL,
    amount numeric(12,2) NOT NULL
);


--
-- Name: project_members; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.project_members (
    project_id uuid NOT NULL,
    user_id uuid NOT NULL,
    id uuid NOT NULL,
    created_at timestamp with time zone DEFAULT now() NOT NULL,
    updated_at timestamp with time zone DEFAULT now() NOT NULL
);


--
-- Name: projects; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.projects (
    organization_id uuid NOT NULL,
    name character varying(200) NOT NULL,
    description text,
    start_date date,
    end_date date,
    status public.projectstatus NOT NULL,
    created_by_id uuid NOT NULL,
    id uuid NOT NULL,
    created_at timestamp with time zone DEFAULT now() NOT NULL,
    updated_at timestamp with time zone DEFAULT now() NOT NULL,
    manager_id uuid,
    cooperation_start_date date,
    department_id uuid
);


--
-- Name: task_activity_logs; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.task_activity_logs (
    id uuid NOT NULL,
    created_at timestamp with time zone DEFAULT now(),
    organization_id uuid NOT NULL,
    task_id uuid NOT NULL,
    actor_user_id uuid,
    action character varying(100) NOT NULL,
    extra_metadata jsonb DEFAULT '{}'::jsonb NOT NULL
);


--
-- Name: task_dependencies; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.task_dependencies (
    task_id uuid NOT NULL,
    depends_on_task_id uuid NOT NULL,
    id uuid NOT NULL,
    created_at timestamp with time zone DEFAULT now() NOT NULL,
    updated_at timestamp with time zone DEFAULT now() NOT NULL
);


--
-- Name: tasks; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.tasks (
    organization_id uuid NOT NULL,
    project_id uuid,
    parent_task_id uuid,
    assignee_id uuid,
    created_by_id uuid NOT NULL,
    title character varying(300) NOT NULL,
    description text,
    priority public.taskpriority NOT NULL,
    deadline date,
    id uuid NOT NULL,
    created_at timestamp with time zone DEFAULT now() NOT NULL,
    updated_at timestamp with time zone DEFAULT now() NOT NULL,
    status public.taskstatus NOT NULL,
    approval_status public.approvalstatus,
    progress_percent integer NOT NULL,
    estimated_hours numeric(6,2),
    start_date date,
    value public.taskvalue NOT NULL
);


--
-- Name: users; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.users (
    organization_id uuid,
    full_name character varying(200) NOT NULL,
    role public.userrole NOT NULL,
    is_active boolean NOT NULL,
    id uuid NOT NULL,
    created_at timestamp with time zone DEFAULT now() NOT NULL,
    updated_at timestamp with time zone DEFAULT now() NOT NULL,
    department_id uuid,
    account_id uuid NOT NULL
);


--
-- Name: worklogs; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.worklogs (
    organization_id uuid NOT NULL,
    task_id uuid NOT NULL,
    user_id uuid NOT NULL,
    activity_description text NOT NULL,
    time_spent_minutes integer NOT NULL,
    progress_percent integer NOT NULL,
    log_date date NOT NULL,
    status public.worklogstatus NOT NULL,
    reviewed_by_id uuid,
    review_comment text,
    id uuid NOT NULL,
    created_at timestamp with time zone DEFAULT now() NOT NULL,
    updated_at timestamp with time zone DEFAULT now() NOT NULL
);


--
-- Data for Name: accounts; Type: TABLE DATA; Schema: public; Owner: -
--

COPY public.accounts (id, created_at, updated_at, phone_number, hashed_password) FROM stdin;
d2d1d359-d54d-4c4f-81f7-68692c0ac617	2026-07-21 11:45:44.744086+00	2026-07-21 11:45:44.744086+00	09100000001	$2b$12$4oIVPOXDbSzRuPoJNmHy9eLKqEaplBXw6ARen.HbmLkg1wK75gDCO
28ce99d9-f0f4-4f0b-9f08-271d736d3238	2026-07-21 11:45:44.744086+00	2026-07-21 11:45:44.744086+00	09111000000	$2b$12$KdXzMbQd3JrohUaVJXtw5OEyhsh9LwF/JmY.8fpzTJef0pnr1IDLW
0835f22f-7f06-4ff0-a44c-60a03817ac42	2026-07-21 11:45:44.744086+00	2026-07-21 11:45:44.744086+00	09111000011	$2b$12$AmD5OnvRCcwerwBrfkNWwO8Er2YC8FSM95dlpKpxTu99rsP66ONhy
e0388199-a1f9-4865-98a0-318a5c0814c6	2026-07-21 11:45:44.744086+00	2026-07-21 11:45:44.744086+00	09111000012	$2b$12$IGUE3Wr/ilKQ8VyIV2zC3.8Aqu9laGZDkYV.47QiVqwWAnlf1csFG
5abdd53f-cae2-40ce-8775-7c26313b362e	2026-07-21 11:45:44.744086+00	2026-07-21 11:45:44.744086+00	09111000013	$2b$12$5quaD1EDme6hHq0sIA4HXeL4j5lxtC5cdx2HaeaL13dQXX0feQ8K2
60837bcd-2067-4e4e-a8f6-b1ac46cfdff6	2026-07-21 11:45:44.744086+00	2026-07-21 11:45:44.744086+00	09111000014	$2b$12$kp14s9L8syvaH/HPl2/iPOM05g.g2wqUrdk/1LfwHfIJrHhQuTM/O
1cbd2818-d4c1-4e07-a205-98cc0ab3edeb	2026-07-21 11:45:44.744086+00	2026-07-21 11:45:44.744086+00	09111000015	$2b$12$ydP4CGVp30vvRPGcwzwfYeD8ktdR2MOXDKVrMSCMVf6IBoKMjqWya
63ac3a42-2b2c-4f61-b6ba-b634920787d8	2026-07-21 11:45:44.744086+00	2026-07-21 11:45:44.744086+00	09111000016	$2b$12$YK8LRh0zPjOOAtg.WRHSlO8yaCEExZa4RhPrzH/89AQ2MXC0tFE9m
bbcca2fb-79d4-40d8-ac62-559486b294fe	2026-07-21 11:45:44.744086+00	2026-07-21 11:45:44.744086+00	09121000100	$2b$12$3Uo2X1jj4aW.x4t9boidHeG4pzlGdFoIa7eNzRk5MYMLix4fayhR.
3511590f-4196-4535-96f2-c5f86e47d720	2026-07-21 11:45:44.744086+00	2026-07-21 11:45:44.744086+00	09121000111	$2b$12$OLfTwuwsk6PBMd9zrruZl.T/xl2HhaYqQ.5PQ/P0cB3.puKKO6d/e
951d852e-1ca6-4021-b5ba-5525037a7103	2026-07-21 11:45:44.744086+00	2026-07-21 11:45:44.744086+00	09121000112	$2b$12$CE5K05o8Scxi1XkQwgD6wOIu9IH7O/R9ixc1fvP9ywKqhxagw6Dv6
04c396df-2266-44cc-b38a-50df600117fa	2026-07-21 11:45:44.744086+00	2026-07-21 11:45:44.744086+00	09121000113	$2b$12$GBiGwTo9ayk/KoeHd6wcY.YITJnBs3eVy1i0iPGbPCDhk92Whjbte
9ace887f-69e3-4086-bea6-8bc576104975	2026-07-21 11:45:44.744086+00	2026-07-21 11:45:44.744086+00	09121000114	$2b$12$auMDnC47XEq.itP0honmn.fF3qpRaqDcLHpT7Zp5tm8zSZfm91yNO
62a38266-f1d6-4fc5-872c-8d39f2233901	2026-07-21 11:45:44.744086+00	2026-07-21 11:45:44.744086+00	09121000115	$2b$12$FkyIUWSaKD6NFfJIboYrYupYeAm/kDIhAr/wZPi/Rr1N1uZpW5fTW
2512cf12-bc58-495e-9375-02ff73b754d9	2026-07-21 11:45:44.744086+00	2026-07-21 11:45:44.744086+00	09121000116	$2b$12$VH/fIzJRNpxEFPljOvvPPuRJbu.wOZQx0HTwRTs0ZRDf0CRg/0CVy
45fd4ec3-df52-41d5-8c6f-3f0b185db95e	2026-07-21 11:45:44.744086+00	2026-07-21 11:45:44.744086+00	09131000200	$2b$12$xwZuX9rxKnMZ4nERobfIOO4l25qw9UeNimH46XY/B4Yu.TnZLKR4e
16fab593-4268-468e-bf19-c0c4eabb17d5	2026-07-21 11:45:44.744086+00	2026-07-21 11:45:44.744086+00	09131000211	$2b$12$N9.kFygIZfNgsBF2I/Mel..ORJA1Plhdl00er5xLz6HIa0y2zet9.
0c4f97af-83ed-4bb6-b816-90fb051d7c10	2026-07-21 11:45:44.744086+00	2026-07-21 11:45:44.744086+00	09131000212	$2b$12$XjVznhf3FiIpJd09DQQ2T.8cG1CcuczeY1rdF73m6.LlVEs4miX.2
0b10a3eb-c399-40c2-a421-c3d22118275d	2026-07-21 11:45:44.744086+00	2026-07-21 11:45:44.744086+00	09131000213	$2b$12$GY2liPhabQzehbUpCxUE2.p2pBTtSjXTX8A8tX.KLPNE6lXi0i0py
e2e1d229-5269-4b48-bfd4-0c667cf24256	2026-07-21 11:45:44.744086+00	2026-07-21 11:45:44.744086+00	09131000214	$2b$12$DQU0XUA/pty/9jrpHvyzsOLY6r6.wXliXEDNICh798JyxYLIUJIue
798703a9-a65f-49cc-b5d5-dac8b9828836	2026-07-21 11:45:44.744086+00	2026-07-21 11:45:44.744086+00	09131000215	$2b$12$wUgaF1t/6XNnnQSXKqNltuyp2Ja1zIAsjcvhpt2PffCEOhC10JYua
9bb0502e-b421-4799-a47d-1ce02453ed96	2026-07-21 11:45:44.744086+00	2026-07-21 11:45:44.744086+00	09131000216	$2b$12$U5zZlcTNt9PGM50z.xSHgOJeUh3EgS35jDn199dREiPomb8Z2BsVu
\.


--
-- Data for Name: alembic_version; Type: TABLE DATA; Schema: public; Owner: -
--

COPY public.alembic_version (version_num) FROM stdin;
b1c4d7e9f2a3
\.


--
-- Data for Name: attachments; Type: TABLE DATA; Schema: public; Owner: -
--

COPY public.attachments (organization_id, task_id, uploaded_by_id, file_path, original_filename, content_type, size_bytes, id, created_at, updated_at) FROM stdin;
\.


--
-- Data for Name: audit_logs; Type: TABLE DATA; Schema: public; Owner: -
--

COPY public.audit_logs (created_at, organization_id, actor_user_id, action, entity_type, entity_id, extra_metadata, id) FROM stdin;
\.


--
-- Data for Name: calendar_events; Type: TABLE DATA; Schema: public; Owner: -
--

COPY public.calendar_events (id, created_at, updated_at, organization_id, created_by_id, project_id, user_id, title, description, event_type, start_at, end_at, all_day) FROM stdin;
cbebc673-5f19-4041-b3f1-5a8ddb6e8e19	2026-07-21 11:45:44.744086+00	2026-07-21 11:45:44.744086+00	582b48ec-cec0-4e4b-a7d4-cbfd51751f0f	09bab356-ca7d-4f2b-a863-5ec4bcad25ca	f431af97-a16d-4da2-ab34-ee747a30a78b	\N	جلسهٔ برنامه‌ریزی اسپرینت	\N	meeting	2026-06-20 10:00:00+00	2026-06-20 11:00:00+00	f
bc834a1f-f5d5-4c1c-8710-b35799a77aca	2026-07-21 11:45:44.744086+00	2026-07-21 11:45:44.744086+00	582b48ec-cec0-4e4b-a7d4-cbfd51751f0f	de505605-7889-4573-8969-c65f885903c4	4ae634b0-668f-465b-b3b9-c407a58a5308	\N	یادآوری ارسال گزارش	\N	reminder	2026-06-17 00:00:00+00	2026-06-17 01:00:00+00	t
88c58195-5b37-4694-abe3-12e08137f0c5	2026-07-21 11:45:44.744086+00	2026-07-21 11:45:44.744086+00	582b48ec-cec0-4e4b-a7d4-cbfd51751f0f	09bab356-ca7d-4f2b-a863-5ec4bcad25ca	f431af97-a16d-4da2-ab34-ee747a30a78b	\N	جلسهٔ برنامه‌ریزی اسپرینت	\N	meeting	2026-06-27 10:00:00+00	2026-06-27 11:00:00+00	f
9e565b95-865f-4f3d-b57c-856d88093b3e	2026-07-21 11:45:44.744086+00	2026-07-21 11:45:44.744086+00	582b48ec-cec0-4e4b-a7d4-cbfd51751f0f	de505605-7889-4573-8969-c65f885903c4	24b11371-bc5f-4ae3-aee6-5c0dd9dac5cb	\N	یادآوری پیگیری مشتری	\N	reminder	2026-06-23 00:00:00+00	2026-06-23 01:00:00+00	t
d2290cfa-b70a-45e7-a4b1-cb9e6cbbad71	2026-07-21 11:45:44.744086+00	2026-07-21 11:45:44.744086+00	582b48ec-cec0-4e4b-a7d4-cbfd51751f0f	09bab356-ca7d-4f2b-a863-5ec4bcad25ca	24b11371-bc5f-4ae3-aee6-5c0dd9dac5cb	\N	جلسهٔ هماهنگی هفتگی	\N	meeting	2026-07-04 10:00:00+00	2026-07-04 11:00:00+00	f
b63c204c-625a-4365-9023-8d7db01b9e2a	2026-07-21 11:45:44.744086+00	2026-07-21 11:45:44.744086+00	582b48ec-cec0-4e4b-a7d4-cbfd51751f0f	2ea22145-8b4c-4e52-84fb-acb66c94b186	f431af97-a16d-4da2-ab34-ee747a30a78b	\N	یادآوری پیگیری مشتری	\N	reminder	2026-07-03 00:00:00+00	2026-07-03 01:00:00+00	t
a07f625e-eb64-49f0-94d0-5c17d0b62e5f	2026-07-21 11:45:44.744086+00	2026-07-21 11:45:44.744086+00	582b48ec-cec0-4e4b-a7d4-cbfd51751f0f	09bab356-ca7d-4f2b-a863-5ec4bcad25ca	4ae634b0-668f-465b-b3b9-c407a58a5308	\N	جلسهٔ برنامه‌ریزی اسپرینت	\N	meeting	2026-07-09 10:00:00+00	2026-07-09 11:00:00+00	f
acb01092-ef5f-400b-a867-378fb377d553	2026-07-21 11:45:44.744086+00	2026-07-21 11:45:44.744086+00	582b48ec-cec0-4e4b-a7d4-cbfd51751f0f	e6f6d74c-28cb-4ed3-98b6-6b15a7e57e23	74790992-d995-41fe-b5c9-fffeaf17f5cd	\N	یادآوری ارسال گزارش	\N	reminder	2026-07-12 00:00:00+00	2026-07-12 01:00:00+00	t
fe2466ed-940f-43f4-b9b5-7a31d7318b7e	2026-07-21 11:45:44.744086+00	2026-07-21 11:45:44.744086+00	582b48ec-cec0-4e4b-a7d4-cbfd51751f0f	09bab356-ca7d-4f2b-a863-5ec4bcad25ca	74790992-d995-41fe-b5c9-fffeaf17f5cd	\N	جلسهٔ هماهنگی هفتگی	\N	meeting	2026-07-15 10:00:00+00	2026-07-15 11:00:00+00	f
1aada256-c2a8-4c4d-ac3b-9c66a4bbac42	2026-07-21 11:45:44.744086+00	2026-07-21 11:45:44.744086+00	582b48ec-cec0-4e4b-a7d4-cbfd51751f0f	de505605-7889-4573-8969-c65f885903c4	74790992-d995-41fe-b5c9-fffeaf17f5cd	\N	یادآوری ارسال گزارش	\N	reminder	2026-07-20 00:00:00+00	2026-07-20 01:00:00+00	t
4701d9b3-103b-4ca2-ae6f-ee97fe4b6e85	2026-07-21 11:45:44.744086+00	2026-07-21 11:45:44.744086+00	582b48ec-cec0-4e4b-a7d4-cbfd51751f0f	09bab356-ca7d-4f2b-a863-5ec4bcad25ca	f431af97-a16d-4da2-ab34-ee747a30a78b	\N	جلسهٔ برنامه‌ریزی اسپرینت	\N	meeting	2026-07-23 10:00:00+00	2026-07-23 11:00:00+00	f
6ff16615-e766-4988-b955-0c927bdb68d7	2026-07-21 11:45:44.744086+00	2026-07-21 11:45:44.744086+00	582b48ec-cec0-4e4b-a7d4-cbfd51751f0f	9bee1760-d3cf-42e2-80de-a78b2be8c965	57f6bd9c-475a-424c-af79-6a12be955b40	\N	یادآوری پیگیری مشتری	\N	reminder	2026-07-27 00:00:00+00	2026-07-27 01:00:00+00	t
9d27c2b6-0357-4fb1-988c-f07e2362d88d	2026-07-21 11:45:44.744086+00	2026-07-21 11:45:44.744086+00	582b48ec-cec0-4e4b-a7d4-cbfd51751f0f	09bab356-ca7d-4f2b-a863-5ec4bcad25ca	4ae634b0-668f-465b-b3b9-c407a58a5308	\N	جلسهٔ بررسی پیشرفت پروژه	\N	meeting	2026-07-31 10:00:00+00	2026-07-31 11:00:00+00	f
accd2de8-4765-4edb-9fa7-ac9136d9ff32	2026-07-21 11:45:44.744086+00	2026-07-21 11:45:44.744086+00	582b48ec-cec0-4e4b-a7d4-cbfd51751f0f	0885409c-d2f4-4296-88c0-d8ac1df6a7e5	f431af97-a16d-4da2-ab34-ee747a30a78b	\N	یادآوری پیگیری مشتری	\N	reminder	2026-08-03 00:00:00+00	2026-08-03 01:00:00+00	t
cc628459-14c8-4f8e-ac95-cff5f9948ed1	2026-07-21 11:45:44.744086+00	2026-07-21 11:45:44.744086+00	582b48ec-cec0-4e4b-a7d4-cbfd51751f0f	09bab356-ca7d-4f2b-a863-5ec4bcad25ca	4ae634b0-668f-465b-b3b9-c407a58a5308	\N	جلسهٔ برنامه‌ریزی اسپرینت	\N	meeting	2026-08-04 10:00:00+00	2026-08-04 11:00:00+00	f
4ca3d314-d839-4e14-9f4e-a361be6d783f	2026-07-21 11:45:44.744086+00	2026-07-21 11:45:44.744086+00	582b48ec-cec0-4e4b-a7d4-cbfd51751f0f	e6f6d74c-28cb-4ed3-98b6-6b15a7e57e23	57f6bd9c-475a-424c-af79-6a12be955b40	\N	یادآوری ارسال گزارش	\N	reminder	2026-08-05 00:00:00+00	2026-08-05 01:00:00+00	t
18e0d95c-6491-412d-8ffb-a71f69c83e9a	2026-07-21 11:45:44.744086+00	2026-07-21 11:45:44.744086+00	582b48ec-cec0-4e4b-a7d4-cbfd51751f0f	09bab356-ca7d-4f2b-a863-5ec4bcad25ca	74790992-d995-41fe-b5c9-fffeaf17f5cd	\N	جلسهٔ مرور با مدیریت	\N	meeting	2026-08-13 10:00:00+00	2026-08-13 11:00:00+00	f
48580481-a63e-4af9-9095-a21aa059a063	2026-07-21 11:45:44.744086+00	2026-07-21 11:45:44.744086+00	582b48ec-cec0-4e4b-a7d4-cbfd51751f0f	de505605-7889-4573-8969-c65f885903c4	4ae634b0-668f-465b-b3b9-c407a58a5308	\N	یادآوری تمدید قرارداد	\N	reminder	2026-08-17 00:00:00+00	2026-08-17 01:00:00+00	t
61618814-c7e0-478f-a24c-e081081eb1cc	2026-07-21 11:45:44.744086+00	2026-07-21 11:45:44.744086+00	582b48ec-cec0-4e4b-a7d4-cbfd51751f0f	98fba7cd-606b-4e45-957c-f63d3a809e84	46dc887e-e603-4c2d-a2d7-4ccc3e411953	\N	جلسهٔ برنامه‌ریزی اسپرینت	\N	meeting	2026-06-17 10:00:00+00	2026-06-17 11:00:00+00	f
8fd68ea9-a51b-451d-a36c-c465af13b146	2026-07-21 11:45:44.744086+00	2026-07-21 11:45:44.744086+00	582b48ec-cec0-4e4b-a7d4-cbfd51751f0f	60845684-b03a-492a-9937-f8529e7ba409	46dc887e-e603-4c2d-a2d7-4ccc3e411953	\N	یادآوری تمدید قرارداد	\N	reminder	2026-06-19 00:00:00+00	2026-06-19 01:00:00+00	t
7decc8dc-6283-4fa8-b797-5ada758f11aa	2026-07-21 11:45:44.744086+00	2026-07-21 11:45:44.744086+00	582b48ec-cec0-4e4b-a7d4-cbfd51751f0f	98fba7cd-606b-4e45-957c-f63d3a809e84	5bcf571d-8fc5-4f23-86c2-bda550998000	\N	جلسهٔ برنامه‌ریزی اسپرینت	\N	meeting	2026-06-23 10:00:00+00	2026-06-23 11:00:00+00	f
15d3d78b-f317-4d87-9bb9-990092966b43	2026-07-21 11:45:44.744086+00	2026-07-21 11:45:44.744086+00	582b48ec-cec0-4e4b-a7d4-cbfd51751f0f	e84eaed7-50c6-4212-9f29-cad60bbee457	ad0ecc0e-1dd7-4885-9f2c-fe84502e3653	\N	یادآوری ارسال گزارش	\N	reminder	2026-06-26 00:00:00+00	2026-06-26 01:00:00+00	t
bacd404e-2cfe-476d-8c4d-7fc51c803771	2026-07-21 11:45:44.744086+00	2026-07-21 11:45:44.744086+00	582b48ec-cec0-4e4b-a7d4-cbfd51751f0f	98fba7cd-606b-4e45-957c-f63d3a809e84	46dc887e-e603-4c2d-a2d7-4ccc3e411953	\N	جلسهٔ هماهنگی هفتگی	\N	meeting	2026-07-01 10:00:00+00	2026-07-01 11:00:00+00	f
8f8d46c4-0c80-4558-970f-9bdc1b167926	2026-07-21 11:45:44.744086+00	2026-07-21 11:45:44.744086+00	582b48ec-cec0-4e4b-a7d4-cbfd51751f0f	85751a1a-b02d-4121-aff6-407cd2f6ebd7	30cf629e-4a36-40a9-9107-ae3dc5cf6578	\N	یادآوری تمدید قرارداد	\N	reminder	2026-07-03 00:00:00+00	2026-07-03 01:00:00+00	t
fd8bcc65-e84c-4a8a-8546-b684168fb06e	2026-07-21 11:45:44.744086+00	2026-07-21 11:45:44.744086+00	582b48ec-cec0-4e4b-a7d4-cbfd51751f0f	98fba7cd-606b-4e45-957c-f63d3a809e84	46dc887e-e603-4c2d-a2d7-4ccc3e411953	\N	جلسهٔ برنامه‌ریزی اسپرینت	\N	meeting	2026-07-10 10:00:00+00	2026-07-10 11:00:00+00	f
3d173309-61dd-41b5-8c02-d3527da80097	2026-07-21 11:45:44.744086+00	2026-07-21 11:45:44.744086+00	582b48ec-cec0-4e4b-a7d4-cbfd51751f0f	2e6fa9ea-43da-47ab-a8a8-e2e58360f575	30cf629e-4a36-40a9-9107-ae3dc5cf6578	\N	یادآوری تمدید قرارداد	\N	reminder	2026-07-11 00:00:00+00	2026-07-11 01:00:00+00	t
cb25521c-b7ec-4192-bb55-5b93672cbf3b	2026-07-21 11:45:44.744086+00	2026-07-21 11:45:44.744086+00	582b48ec-cec0-4e4b-a7d4-cbfd51751f0f	98fba7cd-606b-4e45-957c-f63d3a809e84	30cf629e-4a36-40a9-9107-ae3dc5cf6578	\N	جلسهٔ هماهنگی هفتگی	\N	meeting	2026-07-15 10:00:00+00	2026-07-15 11:00:00+00	f
df943d90-c767-45df-8b67-56053be7e093	2026-07-21 11:45:44.744086+00	2026-07-21 11:45:44.744086+00	582b48ec-cec0-4e4b-a7d4-cbfd51751f0f	2e6fa9ea-43da-47ab-a8a8-e2e58360f575	03032cdb-7a72-4f37-9d58-8b79b5b86638	\N	یادآوری ارسال گزارش	\N	reminder	2026-07-16 00:00:00+00	2026-07-16 01:00:00+00	t
361f30fe-584a-470a-95e1-0af8b7dd1d94	2026-07-21 11:45:44.744086+00	2026-07-21 11:45:44.744086+00	582b48ec-cec0-4e4b-a7d4-cbfd51751f0f	98fba7cd-606b-4e45-957c-f63d3a809e84	30cf629e-4a36-40a9-9107-ae3dc5cf6578	\N	جلسهٔ مرور با مدیریت	\N	meeting	2026-07-21 10:00:00+00	2026-07-21 11:00:00+00	f
722cb49d-13a2-42dd-9905-5b5876d7e808	2026-07-21 11:45:44.744086+00	2026-07-21 11:45:44.744086+00	582b48ec-cec0-4e4b-a7d4-cbfd51751f0f	c057add9-a37a-4d8b-adb3-be28effacb81	46dc887e-e603-4c2d-a2d7-4ccc3e411953	\N	یادآوری ارسال گزارش	\N	reminder	2026-07-25 00:00:00+00	2026-07-25 01:00:00+00	t
4a21e72b-fb18-4b1d-a34d-a2f2bed55fa0	2026-07-21 11:45:44.744086+00	2026-07-21 11:45:44.744086+00	582b48ec-cec0-4e4b-a7d4-cbfd51751f0f	98fba7cd-606b-4e45-957c-f63d3a809e84	03032cdb-7a72-4f37-9d58-8b79b5b86638	\N	جلسهٔ بررسی پیشرفت پروژه	\N	meeting	2026-07-28 10:00:00+00	2026-07-28 11:00:00+00	f
6215e875-a6f4-4d1d-8572-965094a7579f	2026-07-21 11:45:44.744086+00	2026-07-21 11:45:44.744086+00	582b48ec-cec0-4e4b-a7d4-cbfd51751f0f	e84eaed7-50c6-4212-9f29-cad60bbee457	30cf629e-4a36-40a9-9107-ae3dc5cf6578	\N	یادآوری پیگیری مشتری	\N	reminder	2026-08-02 00:00:00+00	2026-08-02 01:00:00+00	t
37ae6f5e-1068-4666-8e00-071317be3e9c	2026-07-21 11:45:44.744086+00	2026-07-21 11:45:44.744086+00	582b48ec-cec0-4e4b-a7d4-cbfd51751f0f	98fba7cd-606b-4e45-957c-f63d3a809e84	5bcf571d-8fc5-4f23-86c2-bda550998000	\N	جلسهٔ مرور با مدیریت	\N	meeting	2026-08-05 10:00:00+00	2026-08-05 11:00:00+00	f
7bd1e310-dd4f-4f9e-8904-5b79af57b3bb	2026-07-21 11:45:44.744086+00	2026-07-21 11:45:44.744086+00	582b48ec-cec0-4e4b-a7d4-cbfd51751f0f	e84eaed7-50c6-4212-9f29-cad60bbee457	03032cdb-7a72-4f37-9d58-8b79b5b86638	\N	یادآوری ارسال گزارش	\N	reminder	2026-08-06 00:00:00+00	2026-08-06 01:00:00+00	t
52504ddd-3674-4f9f-a4cc-f987c2bdb251	2026-07-21 11:45:44.744086+00	2026-07-21 11:45:44.744086+00	582b48ec-cec0-4e4b-a7d4-cbfd51751f0f	98fba7cd-606b-4e45-957c-f63d3a809e84	46dc887e-e603-4c2d-a2d7-4ccc3e411953	\N	جلسهٔ برنامه‌ریزی اسپرینت	\N	meeting	2026-08-13 10:00:00+00	2026-08-13 11:00:00+00	f
80798b6d-c066-4b93-a3b8-c54ee79e41f2	2026-07-21 11:45:44.744086+00	2026-07-21 11:45:44.744086+00	582b48ec-cec0-4e4b-a7d4-cbfd51751f0f	76c11995-60dc-42d9-9a92-6dc9daa80ce9	30cf629e-4a36-40a9-9107-ae3dc5cf6578	\N	یادآوری پیگیری مشتری	\N	reminder	2026-08-15 00:00:00+00	2026-08-15 01:00:00+00	t
208ae0d1-93d4-4a6a-9426-fbd88ff19454	2026-07-21 11:45:44.744086+00	2026-07-21 11:45:44.744086+00	582b48ec-cec0-4e4b-a7d4-cbfd51751f0f	2b35422d-f7be-4135-8473-be7d9e83ec3d	0767a39d-9ae9-4f98-9da5-55777e3c8055	\N	جلسهٔ هماهنگی هفتگی	\N	meeting	2026-06-20 10:00:00+00	2026-06-20 11:00:00+00	f
011a04b4-2471-4bae-aee2-3ca4c8958c2a	2026-07-21 11:45:44.744086+00	2026-07-21 11:45:44.744086+00	582b48ec-cec0-4e4b-a7d4-cbfd51751f0f	b4e312c2-6dc5-4616-97c7-1b9251f4ef87	c6e8997e-a96f-44b6-bd28-cf0816eacee2	\N	یادآوری ارسال گزارش	\N	reminder	2026-06-19 00:00:00+00	2026-06-19 01:00:00+00	t
e5bbf150-fa9a-4fff-976c-eadcc3480da8	2026-07-21 11:45:44.744086+00	2026-07-21 11:45:44.744086+00	582b48ec-cec0-4e4b-a7d4-cbfd51751f0f	2b35422d-f7be-4135-8473-be7d9e83ec3d	c6e8997e-a96f-44b6-bd28-cf0816eacee2	\N	جلسهٔ مرور با مدیریت	\N	meeting	2026-06-25 10:00:00+00	2026-06-25 11:00:00+00	f
1a84ab5b-975b-4373-a7aa-4c6a883fc585	2026-07-21 11:45:44.744086+00	2026-07-21 11:45:44.744086+00	582b48ec-cec0-4e4b-a7d4-cbfd51751f0f	02d643cd-bc19-4efb-9d1a-c3e6d5675d66	627346d8-7181-440e-876c-c8fb6bfbda15	\N	یادآوری تمدید قرارداد	\N	reminder	2026-06-29 00:00:00+00	2026-06-29 01:00:00+00	t
4d5d4dab-f63f-415a-a301-9258507aa1b7	2026-07-21 11:45:44.744086+00	2026-07-21 11:45:44.744086+00	582b48ec-cec0-4e4b-a7d4-cbfd51751f0f	2b35422d-f7be-4135-8473-be7d9e83ec3d	c4da833a-95aa-494c-b901-06b176ddb369	\N	جلسهٔ برنامه‌ریزی اسپرینت	\N	meeting	2026-07-02 10:00:00+00	2026-07-02 11:00:00+00	f
d8ab502a-a6fb-42c1-80bd-5cb8a7aa1377	2026-07-21 11:45:44.744086+00	2026-07-21 11:45:44.744086+00	582b48ec-cec0-4e4b-a7d4-cbfd51751f0f	e139f154-0fb4-4ebf-b8b8-b6f5a29afeaf	0767a39d-9ae9-4f98-9da5-55777e3c8055	\N	یادآوری تمدید قرارداد	\N	reminder	2026-07-02 00:00:00+00	2026-07-02 01:00:00+00	t
66835287-0515-48bb-bf7b-ba33eedde8c2	2026-07-21 11:45:44.744086+00	2026-07-21 11:45:44.744086+00	582b48ec-cec0-4e4b-a7d4-cbfd51751f0f	2b35422d-f7be-4135-8473-be7d9e83ec3d	c4da833a-95aa-494c-b901-06b176ddb369	\N	جلسهٔ مرور با مدیریت	\N	meeting	2026-07-07 10:00:00+00	2026-07-07 11:00:00+00	f
e788886d-3188-4abd-9b02-e1175b5a41db	2026-07-21 11:45:44.744086+00	2026-07-21 11:45:44.744086+00	582b48ec-cec0-4e4b-a7d4-cbfd51751f0f	77b8df83-b4f0-4924-9ef8-25216fe271af	0767a39d-9ae9-4f98-9da5-55777e3c8055	\N	یادآوری ارسال گزارش	\N	reminder	2026-07-07 00:00:00+00	2026-07-07 01:00:00+00	t
44d0637e-23e0-4d50-81bb-3dcf732f9901	2026-07-21 11:45:44.744086+00	2026-07-21 11:45:44.744086+00	582b48ec-cec0-4e4b-a7d4-cbfd51751f0f	2b35422d-f7be-4135-8473-be7d9e83ec3d	0767a39d-9ae9-4f98-9da5-55777e3c8055	\N	جلسهٔ بررسی پیشرفت پروژه	\N	meeting	2026-07-18 10:00:00+00	2026-07-18 11:00:00+00	f
274e830b-124d-4c1f-8ffc-1fab4f2b1b43	2026-07-21 11:45:44.744086+00	2026-07-21 11:45:44.744086+00	582b48ec-cec0-4e4b-a7d4-cbfd51751f0f	77b8df83-b4f0-4924-9ef8-25216fe271af	c4da833a-95aa-494c-b901-06b176ddb369	\N	یادآوری تمدید قرارداد	\N	reminder	2026-07-20 00:00:00+00	2026-07-20 01:00:00+00	t
b31172dd-87e0-4a46-a358-368ae2f7a0cf	2026-07-21 11:45:44.744086+00	2026-07-21 11:45:44.744086+00	582b48ec-cec0-4e4b-a7d4-cbfd51751f0f	2b35422d-f7be-4135-8473-be7d9e83ec3d	0767a39d-9ae9-4f98-9da5-55777e3c8055	\N	جلسهٔ مرور با مدیریت	\N	meeting	2026-07-24 10:00:00+00	2026-07-24 11:00:00+00	f
323691d0-7742-44f8-89b1-16783560b37d	2026-07-21 11:45:44.744086+00	2026-07-21 11:45:44.744086+00	582b48ec-cec0-4e4b-a7d4-cbfd51751f0f	c3bd6208-d89c-402a-90fe-6f00c4219566	0767a39d-9ae9-4f98-9da5-55777e3c8055	\N	یادآوری تمدید قرارداد	\N	reminder	2026-07-21 00:00:00+00	2026-07-21 01:00:00+00	t
f26b0ea4-c6d5-4e37-be23-22dbe706b088	2026-07-21 11:45:44.744086+00	2026-07-21 11:45:44.744086+00	582b48ec-cec0-4e4b-a7d4-cbfd51751f0f	2b35422d-f7be-4135-8473-be7d9e83ec3d	ffc01140-775e-4436-af23-83d1b513e6a1	\N	جلسهٔ بررسی پیشرفت پروژه	\N	meeting	2026-07-29 10:00:00+00	2026-07-29 11:00:00+00	f
10ed9bed-db4e-48d4-bd13-e22e85e55e71	2026-07-21 11:45:44.744086+00	2026-07-21 11:45:44.744086+00	582b48ec-cec0-4e4b-a7d4-cbfd51751f0f	77b8df83-b4f0-4924-9ef8-25216fe271af	ffc01140-775e-4436-af23-83d1b513e6a1	\N	یادآوری پیگیری مشتری	\N	reminder	2026-08-02 00:00:00+00	2026-08-02 01:00:00+00	t
956cd513-1d10-4298-8a20-7feb0ea231dd	2026-07-21 11:45:44.744086+00	2026-07-21 11:45:44.744086+00	582b48ec-cec0-4e4b-a7d4-cbfd51751f0f	2b35422d-f7be-4135-8473-be7d9e83ec3d	0767a39d-9ae9-4f98-9da5-55777e3c8055	\N	جلسهٔ مرور با مدیریت	\N	meeting	2026-08-08 10:00:00+00	2026-08-08 11:00:00+00	f
c55db6aa-ec94-493d-bdbb-472ab7278344	2026-07-21 11:45:44.744086+00	2026-07-21 11:45:44.744086+00	582b48ec-cec0-4e4b-a7d4-cbfd51751f0f	b4e312c2-6dc5-4616-97c7-1b9251f4ef87	627346d8-7181-440e-876c-c8fb6bfbda15	\N	یادآوری ارسال گزارش	\N	reminder	2026-08-10 00:00:00+00	2026-08-10 01:00:00+00	t
1feeb94d-9081-4892-9b43-0014f03b74e5	2026-07-21 11:45:44.744086+00	2026-07-21 11:45:44.744086+00	582b48ec-cec0-4e4b-a7d4-cbfd51751f0f	2b35422d-f7be-4135-8473-be7d9e83ec3d	c4da833a-95aa-494c-b901-06b176ddb369	\N	جلسهٔ برنامه‌ریزی اسپرینت	\N	meeting	2026-08-12 10:00:00+00	2026-08-12 11:00:00+00	f
fcd8d985-e44b-4efb-9559-9cbda02b4a1b	2026-07-21 11:45:44.744086+00	2026-07-21 11:45:44.744086+00	582b48ec-cec0-4e4b-a7d4-cbfd51751f0f	02d643cd-bc19-4efb-9d1a-c3e6d5675d66	c4da833a-95aa-494c-b901-06b176ddb369	\N	یادآوری پیگیری مشتری	\N	reminder	2026-08-13 00:00:00+00	2026-08-13 01:00:00+00	t
0c602f72-b2c6-47da-bf94-4dda4cae9253	2026-07-21 11:45:44.744086+00	2026-07-21 11:45:44.744086+00	582b48ec-cec0-4e4b-a7d4-cbfd51751f0f	4ba9028a-0a6d-4c87-aaa0-7e21616e1897	\N	\N	تعطیلی رسمی	\N	holiday	2026-06-18 00:00:00+00	2026-06-18 01:00:00+00	t
5717b1ee-c893-4e4c-bd46-1da6b50e1bf6	2026-07-21 11:45:44.744086+00	2026-07-21 11:45:44.744086+00	582b48ec-cec0-4e4b-a7d4-cbfd51751f0f	4ba9028a-0a6d-4c87-aaa0-7e21616e1897	\N	\N	تعطیلی رسمی	\N	holiday	2026-07-16 00:00:00+00	2026-07-16 01:00:00+00	t
3b549549-1d82-46e0-9756-57b0cc5f0fc0	2026-07-21 11:45:44.744086+00	2026-07-21 11:45:44.744086+00	582b48ec-cec0-4e4b-a7d4-cbfd51751f0f	4ba9028a-0a6d-4c87-aaa0-7e21616e1897	\N	\N	تعطیلی رسمی	\N	holiday	2026-08-13 00:00:00+00	2026-08-13 01:00:00+00	t
\.


--
-- Data for Name: comments; Type: TABLE DATA; Schema: public; Owner: -
--

COPY public.comments (organization_id, task_id, author_id, body, id, created_at, updated_at) FROM stdin;
\.


--
-- Data for Name: department_memberships; Type: TABLE DATA; Schema: public; Owner: -
--

COPY public.department_memberships (id, created_at, updated_at, organization_id, user_id, department_id, role) FROM stdin;
89dea0ea-7311-4b37-8b29-de53ec22c05d	2026-07-21 11:45:44.744086+00	2026-07-21 11:45:44.744086+00	582b48ec-cec0-4e4b-a7d4-cbfd51751f0f	09bab356-ca7d-4f2b-a863-5ec4bcad25ca	a37a316c-77ba-4e34-b6e6-af2ff812b379	project_manager
5cce8acb-0c37-494b-bf11-7d39ac8843d2	2026-07-21 11:45:44.744086+00	2026-07-21 11:45:44.744086+00	582b48ec-cec0-4e4b-a7d4-cbfd51751f0f	e6f6d74c-28cb-4ed3-98b6-6b15a7e57e23	a37a316c-77ba-4e34-b6e6-af2ff812b379	employee
518cc21a-319a-4c3a-b344-c2374c17108f	2026-07-21 11:45:44.744086+00	2026-07-21 11:45:44.744086+00	582b48ec-cec0-4e4b-a7d4-cbfd51751f0f	0885409c-d2f4-4296-88c0-d8ac1df6a7e5	a37a316c-77ba-4e34-b6e6-af2ff812b379	employee
6597df49-1b63-472a-a6bf-e1bd459da690	2026-07-21 11:45:44.744086+00	2026-07-21 11:45:44.744086+00	582b48ec-cec0-4e4b-a7d4-cbfd51751f0f	28996900-cff9-4923-bdf4-33c0c602bda7	a37a316c-77ba-4e34-b6e6-af2ff812b379	employee
9637a163-0ca3-4898-a0b7-c66aff439436	2026-07-21 11:45:44.744086+00	2026-07-21 11:45:44.744086+00	582b48ec-cec0-4e4b-a7d4-cbfd51751f0f	2ea22145-8b4c-4e52-84fb-acb66c94b186	a37a316c-77ba-4e34-b6e6-af2ff812b379	employee
d97a8143-a50d-4164-ab1d-bc1b15dedebc	2026-07-21 11:45:44.744086+00	2026-07-21 11:45:44.744086+00	582b48ec-cec0-4e4b-a7d4-cbfd51751f0f	de505605-7889-4573-8969-c65f885903c4	a37a316c-77ba-4e34-b6e6-af2ff812b379	employee
30969a70-836c-478d-b096-3bb2ccf4d23e	2026-07-21 11:45:44.744086+00	2026-07-21 11:45:44.744086+00	582b48ec-cec0-4e4b-a7d4-cbfd51751f0f	9bee1760-d3cf-42e2-80de-a78b2be8c965	a37a316c-77ba-4e34-b6e6-af2ff812b379	employee
5aff6cc6-05c8-4358-b810-ac506ae8a864	2026-07-21 11:45:44.744086+00	2026-07-21 11:45:44.744086+00	582b48ec-cec0-4e4b-a7d4-cbfd51751f0f	98fba7cd-606b-4e45-957c-f63d3a809e84	cf10ec33-fb1d-4251-b68c-255aa3470fde	project_manager
e4893138-39a2-4d65-b8db-912f68fab787	2026-07-21 11:45:44.744086+00	2026-07-21 11:45:44.744086+00	582b48ec-cec0-4e4b-a7d4-cbfd51751f0f	76c11995-60dc-42d9-9a92-6dc9daa80ce9	cf10ec33-fb1d-4251-b68c-255aa3470fde	employee
5b4bca44-7b2c-4880-8381-d59da795cbd8	2026-07-21 11:45:44.744086+00	2026-07-21 11:45:44.744086+00	582b48ec-cec0-4e4b-a7d4-cbfd51751f0f	e84eaed7-50c6-4212-9f29-cad60bbee457	cf10ec33-fb1d-4251-b68c-255aa3470fde	employee
f99fde61-9c17-4d11-a0b1-c9b33e6a6b8d	2026-07-21 11:45:44.744086+00	2026-07-21 11:45:44.744086+00	582b48ec-cec0-4e4b-a7d4-cbfd51751f0f	c057add9-a37a-4d8b-adb3-be28effacb81	cf10ec33-fb1d-4251-b68c-255aa3470fde	employee
6c9c56e6-9105-4262-bc2e-e0872b39428d	2026-07-21 11:45:44.744086+00	2026-07-21 11:45:44.744086+00	582b48ec-cec0-4e4b-a7d4-cbfd51751f0f	60845684-b03a-492a-9937-f8529e7ba409	cf10ec33-fb1d-4251-b68c-255aa3470fde	employee
20bf5f24-30dc-4bef-8fbb-a92dcaa87a04	2026-07-21 11:45:44.744086+00	2026-07-21 11:45:44.744086+00	582b48ec-cec0-4e4b-a7d4-cbfd51751f0f	2e6fa9ea-43da-47ab-a8a8-e2e58360f575	cf10ec33-fb1d-4251-b68c-255aa3470fde	employee
ad57273b-9b13-4933-b094-2918a6963700	2026-07-21 11:45:44.744086+00	2026-07-21 11:45:44.744086+00	582b48ec-cec0-4e4b-a7d4-cbfd51751f0f	85751a1a-b02d-4121-aff6-407cd2f6ebd7	cf10ec33-fb1d-4251-b68c-255aa3470fde	employee
2edda819-ed99-4475-989f-5469895c668b	2026-07-21 11:45:44.744086+00	2026-07-21 11:45:44.744086+00	582b48ec-cec0-4e4b-a7d4-cbfd51751f0f	2b35422d-f7be-4135-8473-be7d9e83ec3d	fbc0e416-765b-415a-82a5-f0ad851343b2	project_manager
d137ca1d-4ee9-4e87-8c06-da85ebed7880	2026-07-21 11:45:44.744086+00	2026-07-21 11:45:44.744086+00	582b48ec-cec0-4e4b-a7d4-cbfd51751f0f	b4e312c2-6dc5-4616-97c7-1b9251f4ef87	fbc0e416-765b-415a-82a5-f0ad851343b2	employee
1e7faef3-5aa4-442b-b591-c7063f086a7b	2026-07-21 11:45:44.744086+00	2026-07-21 11:45:44.744086+00	582b48ec-cec0-4e4b-a7d4-cbfd51751f0f	984c1d49-02d8-4d53-8ce0-f8709fafb190	fbc0e416-765b-415a-82a5-f0ad851343b2	employee
21e7b85c-11db-40b1-9544-7fa180ecf7ec	2026-07-21 11:45:44.744086+00	2026-07-21 11:45:44.744086+00	582b48ec-cec0-4e4b-a7d4-cbfd51751f0f	77b8df83-b4f0-4924-9ef8-25216fe271af	fbc0e416-765b-415a-82a5-f0ad851343b2	employee
fc34c7e0-92b6-41a7-b68f-ec98a207cd37	2026-07-21 11:45:44.744086+00	2026-07-21 11:45:44.744086+00	582b48ec-cec0-4e4b-a7d4-cbfd51751f0f	c3bd6208-d89c-402a-90fe-6f00c4219566	fbc0e416-765b-415a-82a5-f0ad851343b2	employee
7908cfab-adc9-45f1-a8ee-daaea0fa44da	2026-07-21 11:45:44.744086+00	2026-07-21 11:45:44.744086+00	582b48ec-cec0-4e4b-a7d4-cbfd51751f0f	e139f154-0fb4-4ebf-b8b8-b6f5a29afeaf	fbc0e416-765b-415a-82a5-f0ad851343b2	employee
49ce866a-ecaf-4201-87f6-94340bbb6445	2026-07-21 11:45:44.744086+00	2026-07-21 11:45:44.744086+00	582b48ec-cec0-4e4b-a7d4-cbfd51751f0f	02d643cd-bc19-4efb-9d1a-c3e6d5675d66	fbc0e416-765b-415a-82a5-f0ad851343b2	employee
68fee31d-e490-44b2-9a4a-35f6838793a8	2026-07-21 11:45:44.744086+00	2026-07-21 11:45:44.744086+00	582b48ec-cec0-4e4b-a7d4-cbfd51751f0f	2b35422d-f7be-4135-8473-be7d9e83ec3d	a37a316c-77ba-4e34-b6e6-af2ff812b379	employee
5123971f-9498-4cef-9271-209212e0d8a5	2026-07-21 11:45:44.744086+00	2026-07-21 11:45:44.744086+00	582b48ec-cec0-4e4b-a7d4-cbfd51751f0f	e6f6d74c-28cb-4ed3-98b6-6b15a7e57e23	cf10ec33-fb1d-4251-b68c-255aa3470fde	employee
\.


--
-- Data for Name: departments; Type: TABLE DATA; Schema: public; Owner: -
--

COPY public.departments (id, created_at, updated_at, organization_id, name) FROM stdin;
a37a316c-77ba-4e34-b6e6-af2ff812b379	2026-07-21 11:45:44.744086+00	2026-07-21 11:45:44.744086+00	582b48ec-cec0-4e4b-a7d4-cbfd51751f0f	مهندسی و فنی
cf10ec33-fb1d-4251-b68c-255aa3470fde	2026-07-21 11:45:44.744086+00	2026-07-21 11:45:44.744086+00	582b48ec-cec0-4e4b-a7d4-cbfd51751f0f	حسابداری و مالی
fbc0e416-765b-415a-82a5-f0ad851343b2	2026-07-21 11:45:44.744086+00	2026-07-21 11:45:44.744086+00	582b48ec-cec0-4e4b-a7d4-cbfd51751f0f	منابع انسانی
\.


--
-- Data for Name: export_jobs; Type: TABLE DATA; Schema: public; Owner: -
--

COPY public.export_jobs (organization_id, requested_by_id, export_type, filters, status, file_path, error_message, completed_at, id, created_at, updated_at) FROM stdin;
\.


--
-- Data for Name: finance_categories; Type: TABLE DATA; Schema: public; Owner: -
--

COPY public.finance_categories (id, created_at, updated_at, organization_id, entry_type, name, color, is_system) FROM stdin;
\.


--
-- Data for Name: finance_entries; Type: TABLE DATA; Schema: public; Owner: -
--

COPY public.finance_entries (id, created_at, updated_at, organization_id, category_id, project_id, recorded_by_id, entry_type, document_date, amount, title, description, document_number, counterparty) FROM stdin;
\.


--
-- Data for Name: leave_requests; Type: TABLE DATA; Schema: public; Owner: -
--

COPY public.leave_requests (id, created_at, updated_at, organization_id, user_id, start_date, end_date, reason, status, reviewed_by_id, review_comment) FROM stdin;
\.


--
-- Data for Name: notifications; Type: TABLE DATA; Schema: public; Owner: -
--

COPY public.notifications (organization_id, user_id, type, payload, is_read, id, created_at, updated_at) FROM stdin;
\.


--
-- Data for Name: organizations; Type: TABLE DATA; Schema: public; Owner: -
--

COPY public.organizations (name, slug, is_active, id, created_at, updated_at) FROM stdin;
شرکت نمونهٔ آزمایشی	demo-org-c46b6f75	t	582b48ec-cec0-4e4b-a7d4-cbfd51751f0f	2026-07-21 11:45:44.744086+00	2026-07-21 11:45:44.744086+00
\.


--
-- Data for Name: otp_codes; Type: TABLE DATA; Schema: public; Owner: -
--

COPY public.otp_codes (id, created_at, updated_at, phone_number, code_hash, purpose, expires_at, consumed_at, attempt_count) FROM stdin;
\.


--
-- Data for Name: payments; Type: TABLE DATA; Schema: public; Owner: -
--

COPY public.payments (id, created_at, updated_at, organization_id, project_id, recorded_by_id, payment_date, description, amount) FROM stdin;
\.


--
-- Data for Name: project_members; Type: TABLE DATA; Schema: public; Owner: -
--

COPY public.project_members (project_id, user_id, id, created_at, updated_at) FROM stdin;
f431af97-a16d-4da2-ab34-ee747a30a78b	09bab356-ca7d-4f2b-a863-5ec4bcad25ca	5751b83c-76a6-41b2-9456-311adac7d14e	2026-07-21 11:45:44.744086+00	2026-07-21 11:45:44.744086+00
f431af97-a16d-4da2-ab34-ee747a30a78b	9bee1760-d3cf-42e2-80de-a78b2be8c965	160655b7-4b36-434e-bdb9-aaa73e988bc3	2026-07-21 11:45:44.744086+00	2026-07-21 11:45:44.744086+00
f431af97-a16d-4da2-ab34-ee747a30a78b	e6f6d74c-28cb-4ed3-98b6-6b15a7e57e23	3fef9867-db07-4a8b-9f29-a1e940f71d59	2026-07-21 11:45:44.744086+00	2026-07-21 11:45:44.744086+00
f431af97-a16d-4da2-ab34-ee747a30a78b	de505605-7889-4573-8969-c65f885903c4	95d4f5c8-5efd-4b5f-8362-d77864c093e9	2026-07-21 11:45:44.744086+00	2026-07-21 11:45:44.744086+00
57f6bd9c-475a-424c-af79-6a12be955b40	09bab356-ca7d-4f2b-a863-5ec4bcad25ca	f82d8a08-afe4-4658-ac8c-0e154184dc85	2026-07-21 11:45:44.744086+00	2026-07-21 11:45:44.744086+00
57f6bd9c-475a-424c-af79-6a12be955b40	0885409c-d2f4-4296-88c0-d8ac1df6a7e5	2197abc0-623a-4ad6-a753-5bfc5f327b4a	2026-07-21 11:45:44.744086+00	2026-07-21 11:45:44.744086+00
57f6bd9c-475a-424c-af79-6a12be955b40	9bee1760-d3cf-42e2-80de-a78b2be8c965	e0eddc73-ef71-4315-b03f-6d1c201300d3	2026-07-21 11:45:44.744086+00	2026-07-21 11:45:44.744086+00
57f6bd9c-475a-424c-af79-6a12be955b40	e6f6d74c-28cb-4ed3-98b6-6b15a7e57e23	86369091-61f5-4134-9614-fcf040da9ba0	2026-07-21 11:45:44.744086+00	2026-07-21 11:45:44.744086+00
74790992-d995-41fe-b5c9-fffeaf17f5cd	09bab356-ca7d-4f2b-a863-5ec4bcad25ca	c2955d50-4f7c-450b-be69-f57c7794f9f7	2026-07-21 11:45:44.744086+00	2026-07-21 11:45:44.744086+00
74790992-d995-41fe-b5c9-fffeaf17f5cd	de505605-7889-4573-8969-c65f885903c4	1bd5001a-c5da-4190-b306-f43acc51eab6	2026-07-21 11:45:44.744086+00	2026-07-21 11:45:44.744086+00
74790992-d995-41fe-b5c9-fffeaf17f5cd	2ea22145-8b4c-4e52-84fb-acb66c94b186	7e109292-51f2-4c97-8074-e355cca6098f	2026-07-21 11:45:44.744086+00	2026-07-21 11:45:44.744086+00
74790992-d995-41fe-b5c9-fffeaf17f5cd	e6f6d74c-28cb-4ed3-98b6-6b15a7e57e23	3c6d589f-19d9-4139-884e-df1942461852	2026-07-21 11:45:44.744086+00	2026-07-21 11:45:44.744086+00
4ae634b0-668f-465b-b3b9-c407a58a5308	09bab356-ca7d-4f2b-a863-5ec4bcad25ca	89e452cd-23fc-4430-8e13-cbc91ecfe6f4	2026-07-21 11:45:44.744086+00	2026-07-21 11:45:44.744086+00
4ae634b0-668f-465b-b3b9-c407a58a5308	0885409c-d2f4-4296-88c0-d8ac1df6a7e5	914c4416-b045-4a6d-ae75-02b23fb88297	2026-07-21 11:45:44.744086+00	2026-07-21 11:45:44.744086+00
4ae634b0-668f-465b-b3b9-c407a58a5308	9bee1760-d3cf-42e2-80de-a78b2be8c965	f31539d9-d854-47a9-b016-82a5a7da9e6f	2026-07-21 11:45:44.744086+00	2026-07-21 11:45:44.744086+00
4ae634b0-668f-465b-b3b9-c407a58a5308	e6f6d74c-28cb-4ed3-98b6-6b15a7e57e23	b37abc52-986d-49e8-9928-d467c8187e14	2026-07-21 11:45:44.744086+00	2026-07-21 11:45:44.744086+00
24b11371-bc5f-4ae3-aee6-5c0dd9dac5cb	09bab356-ca7d-4f2b-a863-5ec4bcad25ca	1d69e5c2-918c-46b6-a3e6-65a65e33df1e	2026-07-21 11:45:44.744086+00	2026-07-21 11:45:44.744086+00
24b11371-bc5f-4ae3-aee6-5c0dd9dac5cb	9bee1760-d3cf-42e2-80de-a78b2be8c965	9010068e-3bf4-47bb-8acc-74386c9292fc	2026-07-21 11:45:44.744086+00	2026-07-21 11:45:44.744086+00
24b11371-bc5f-4ae3-aee6-5c0dd9dac5cb	de505605-7889-4573-8969-c65f885903c4	5f1e3f59-eb5c-4edb-aa26-912b260b90d8	2026-07-21 11:45:44.744086+00	2026-07-21 11:45:44.744086+00
24b11371-bc5f-4ae3-aee6-5c0dd9dac5cb	2ea22145-8b4c-4e52-84fb-acb66c94b186	c2f5f52e-bdda-472d-97b0-5708df668ec0	2026-07-21 11:45:44.744086+00	2026-07-21 11:45:44.744086+00
5bcf571d-8fc5-4f23-86c2-bda550998000	98fba7cd-606b-4e45-957c-f63d3a809e84	3fa70702-c92e-4412-bed7-467296a79484	2026-07-21 11:45:44.744086+00	2026-07-21 11:45:44.744086+00
5bcf571d-8fc5-4f23-86c2-bda550998000	76c11995-60dc-42d9-9a92-6dc9daa80ce9	b9fe21c1-1795-4eaf-82f6-90edfccf62fa	2026-07-21 11:45:44.744086+00	2026-07-21 11:45:44.744086+00
5bcf571d-8fc5-4f23-86c2-bda550998000	e84eaed7-50c6-4212-9f29-cad60bbee457	30380911-63fb-436c-b99b-e8e79eb3e0e8	2026-07-21 11:45:44.744086+00	2026-07-21 11:45:44.744086+00
5bcf571d-8fc5-4f23-86c2-bda550998000	c057add9-a37a-4d8b-adb3-be28effacb81	b41b3537-03f9-4630-a17f-52870698ab34	2026-07-21 11:45:44.744086+00	2026-07-21 11:45:44.744086+00
03032cdb-7a72-4f37-9d58-8b79b5b86638	98fba7cd-606b-4e45-957c-f63d3a809e84	38e11fdc-c99d-4f5d-b597-d207af0375d8	2026-07-21 11:45:44.744086+00	2026-07-21 11:45:44.744086+00
03032cdb-7a72-4f37-9d58-8b79b5b86638	76c11995-60dc-42d9-9a92-6dc9daa80ce9	6b90083d-52c7-4479-9567-eb7f8ff6fd1a	2026-07-21 11:45:44.744086+00	2026-07-21 11:45:44.744086+00
03032cdb-7a72-4f37-9d58-8b79b5b86638	c057add9-a37a-4d8b-adb3-be28effacb81	7ad3677f-bee0-48a6-bb4e-ce7d9c509d3e	2026-07-21 11:45:44.744086+00	2026-07-21 11:45:44.744086+00
03032cdb-7a72-4f37-9d58-8b79b5b86638	2e6fa9ea-43da-47ab-a8a8-e2e58360f575	0fd836b5-0706-42c2-a646-ad44ab9c9dd7	2026-07-21 11:45:44.744086+00	2026-07-21 11:45:44.744086+00
30cf629e-4a36-40a9-9107-ae3dc5cf6578	98fba7cd-606b-4e45-957c-f63d3a809e84	2a321952-5b60-461e-ac8a-6549504bf35f	2026-07-21 11:45:44.744086+00	2026-07-21 11:45:44.744086+00
30cf629e-4a36-40a9-9107-ae3dc5cf6578	c057add9-a37a-4d8b-adb3-be28effacb81	2a551728-736b-4ed0-a866-aa67e0d3fb6a	2026-07-21 11:45:44.744086+00	2026-07-21 11:45:44.744086+00
30cf629e-4a36-40a9-9107-ae3dc5cf6578	60845684-b03a-492a-9937-f8529e7ba409	10f1d616-aa1c-4d4f-b145-28228bd5e67b	2026-07-21 11:45:44.744086+00	2026-07-21 11:45:44.744086+00
30cf629e-4a36-40a9-9107-ae3dc5cf6578	2e6fa9ea-43da-47ab-a8a8-e2e58360f575	be789564-a7f0-4554-b835-749d1fe25fe2	2026-07-21 11:45:44.744086+00	2026-07-21 11:45:44.744086+00
ad0ecc0e-1dd7-4885-9f2c-fe84502e3653	98fba7cd-606b-4e45-957c-f63d3a809e84	c8814b35-f11b-4fb1-94f8-8e3615b1a28c	2026-07-21 11:45:44.744086+00	2026-07-21 11:45:44.744086+00
ad0ecc0e-1dd7-4885-9f2c-fe84502e3653	c057add9-a37a-4d8b-adb3-be28effacb81	3595396f-da18-40b5-b570-69580503e124	2026-07-21 11:45:44.744086+00	2026-07-21 11:45:44.744086+00
ad0ecc0e-1dd7-4885-9f2c-fe84502e3653	e84eaed7-50c6-4212-9f29-cad60bbee457	7d27130b-4231-4857-a365-75363d96105f	2026-07-21 11:45:44.744086+00	2026-07-21 11:45:44.744086+00
ad0ecc0e-1dd7-4885-9f2c-fe84502e3653	60845684-b03a-492a-9937-f8529e7ba409	30f72ce8-1d64-4800-8036-16e9649c4f18	2026-07-21 11:45:44.744086+00	2026-07-21 11:45:44.744086+00
46dc887e-e603-4c2d-a2d7-4ccc3e411953	98fba7cd-606b-4e45-957c-f63d3a809e84	e22f229a-fe67-4ee8-b0b3-c58331e11f51	2026-07-21 11:45:44.744086+00	2026-07-21 11:45:44.744086+00
46dc887e-e603-4c2d-a2d7-4ccc3e411953	2e6fa9ea-43da-47ab-a8a8-e2e58360f575	880cdc16-bdb7-47ee-978d-36ddef120c40	2026-07-21 11:45:44.744086+00	2026-07-21 11:45:44.744086+00
46dc887e-e603-4c2d-a2d7-4ccc3e411953	c057add9-a37a-4d8b-adb3-be28effacb81	8054a0ad-9405-4fbd-961b-0081d9d0a0af	2026-07-21 11:45:44.744086+00	2026-07-21 11:45:44.744086+00
46dc887e-e603-4c2d-a2d7-4ccc3e411953	76c11995-60dc-42d9-9a92-6dc9daa80ce9	1abbde3a-26bb-436d-86ff-342a040a2e92	2026-07-21 11:45:44.744086+00	2026-07-21 11:45:44.744086+00
627346d8-7181-440e-876c-c8fb6bfbda15	2b35422d-f7be-4135-8473-be7d9e83ec3d	6bca111e-e0b9-429a-a671-a749eded85bb	2026-07-21 11:45:44.744086+00	2026-07-21 11:45:44.744086+00
627346d8-7181-440e-876c-c8fb6bfbda15	e139f154-0fb4-4ebf-b8b8-b6f5a29afeaf	2f7b92f8-d736-46c3-bfe4-97448a0e9285	2026-07-21 11:45:44.744086+00	2026-07-21 11:45:44.744086+00
627346d8-7181-440e-876c-c8fb6bfbda15	984c1d49-02d8-4d53-8ce0-f8709fafb190	92c2beb3-7903-479c-b315-85ac7d38bae3	2026-07-21 11:45:44.744086+00	2026-07-21 11:45:44.744086+00
627346d8-7181-440e-876c-c8fb6bfbda15	02d643cd-bc19-4efb-9d1a-c3e6d5675d66	9ea138ef-107c-47fd-84fd-777b6822373f	2026-07-21 11:45:44.744086+00	2026-07-21 11:45:44.744086+00
c6e8997e-a96f-44b6-bd28-cf0816eacee2	2b35422d-f7be-4135-8473-be7d9e83ec3d	929a92db-6483-42d1-aacb-e54a2a4403cb	2026-07-21 11:45:44.744086+00	2026-07-21 11:45:44.744086+00
c6e8997e-a96f-44b6-bd28-cf0816eacee2	77b8df83-b4f0-4924-9ef8-25216fe271af	75c66247-7d73-4b7a-93c4-feed1d07ad9e	2026-07-21 11:45:44.744086+00	2026-07-21 11:45:44.744086+00
c6e8997e-a96f-44b6-bd28-cf0816eacee2	984c1d49-02d8-4d53-8ce0-f8709fafb190	b61130bb-4d58-4a1b-a616-e7c5292b86c0	2026-07-21 11:45:44.744086+00	2026-07-21 11:45:44.744086+00
c6e8997e-a96f-44b6-bd28-cf0816eacee2	c3bd6208-d89c-402a-90fe-6f00c4219566	7e97cef3-3d65-49a3-b1a0-232d7aecebb5	2026-07-21 11:45:44.744086+00	2026-07-21 11:45:44.744086+00
c4da833a-95aa-494c-b901-06b176ddb369	2b35422d-f7be-4135-8473-be7d9e83ec3d	1b0b6c9c-8f22-4c4e-b281-31a51ee4a7d5	2026-07-21 11:45:44.744086+00	2026-07-21 11:45:44.744086+00
c4da833a-95aa-494c-b901-06b176ddb369	b4e312c2-6dc5-4616-97c7-1b9251f4ef87	8aa6a0ac-e821-4e0e-8591-ed41d4edcb9e	2026-07-21 11:45:44.744086+00	2026-07-21 11:45:44.744086+00
c4da833a-95aa-494c-b901-06b176ddb369	984c1d49-02d8-4d53-8ce0-f8709fafb190	bccefe64-3049-4661-8b89-5b4459ce7fc7	2026-07-21 11:45:44.744086+00	2026-07-21 11:45:44.744086+00
c4da833a-95aa-494c-b901-06b176ddb369	e139f154-0fb4-4ebf-b8b8-b6f5a29afeaf	3cecb3a4-f9cf-42c3-9592-db4e28c2e53b	2026-07-21 11:45:44.744086+00	2026-07-21 11:45:44.744086+00
ffc01140-775e-4436-af23-83d1b513e6a1	2b35422d-f7be-4135-8473-be7d9e83ec3d	81d06e74-2939-48bb-bd9b-fa85e44eab2f	2026-07-21 11:45:44.744086+00	2026-07-21 11:45:44.744086+00
ffc01140-775e-4436-af23-83d1b513e6a1	c3bd6208-d89c-402a-90fe-6f00c4219566	f60192e0-6264-4514-a2bb-ca162b08f945	2026-07-21 11:45:44.744086+00	2026-07-21 11:45:44.744086+00
ffc01140-775e-4436-af23-83d1b513e6a1	b4e312c2-6dc5-4616-97c7-1b9251f4ef87	0af54faf-9cf8-41c3-ab4f-966524e33450	2026-07-21 11:45:44.744086+00	2026-07-21 11:45:44.744086+00
ffc01140-775e-4436-af23-83d1b513e6a1	77b8df83-b4f0-4924-9ef8-25216fe271af	819c2bba-8a51-462b-aed6-0718af80c2a1	2026-07-21 11:45:44.744086+00	2026-07-21 11:45:44.744086+00
0767a39d-9ae9-4f98-9da5-55777e3c8055	2b35422d-f7be-4135-8473-be7d9e83ec3d	aaa36857-d681-4fb1-b75b-393823a7ecd3	2026-07-21 11:45:44.744086+00	2026-07-21 11:45:44.744086+00
0767a39d-9ae9-4f98-9da5-55777e3c8055	984c1d49-02d8-4d53-8ce0-f8709fafb190	1b113ccc-b57e-49c0-907f-716df7bffa16	2026-07-21 11:45:44.744086+00	2026-07-21 11:45:44.744086+00
0767a39d-9ae9-4f98-9da5-55777e3c8055	77b8df83-b4f0-4924-9ef8-25216fe271af	a5645c53-58ba-4df3-9d7b-2b624a910eb7	2026-07-21 11:45:44.744086+00	2026-07-21 11:45:44.744086+00
0767a39d-9ae9-4f98-9da5-55777e3c8055	02d643cd-bc19-4efb-9d1a-c3e6d5675d66	98028aad-214e-46cb-8d35-5cbaf1e2af4d	2026-07-21 11:45:44.744086+00	2026-07-21 11:45:44.744086+00
\.


--
-- Data for Name: projects; Type: TABLE DATA; Schema: public; Owner: -
--

COPY public.projects (organization_id, name, description, start_date, end_date, status, created_by_id, id, created_at, updated_at, manager_id, cooperation_start_date, department_id) FROM stdin;
582b48ec-cec0-4e4b-a7d4-cbfd51751f0f	بازطراحی وب‌سایت شرکتی	پروژهٔ مهندسی و فنی شماره 1	2026-06-01	2026-08-16	active	4ba9028a-0a6d-4c87-aaa0-7e21616e1897	f431af97-a16d-4da2-ab34-ee747a30a78b	2026-07-21 11:45:44.744086+00	2026-07-21 11:45:44.744086+00	09bab356-ca7d-4f2b-a863-5ec4bcad25ca	2026-06-01	a37a316c-77ba-4e34-b6e6-af2ff812b379
582b48ec-cec0-4e4b-a7d4-cbfd51751f0f	توسعهٔ اپلیکیشن موبایل فروش	پروژهٔ مهندسی و فنی شماره 2	2026-04-28	2026-06-23	active	4ba9028a-0a6d-4c87-aaa0-7e21616e1897	57f6bd9c-475a-424c-af79-6a12be955b40	2026-07-21 11:45:44.744086+00	2026-07-21 11:45:44.744086+00	09bab356-ca7d-4f2b-a863-5ec4bcad25ca	2026-04-28	a37a316c-77ba-4e34-b6e6-af2ff812b379
582b48ec-cec0-4e4b-a7d4-cbfd51751f0f	مهاجرت زیرساخت به ابر	پروژهٔ مهندسی و فنی شماره 3	2026-07-03	2026-08-28	active	4ba9028a-0a6d-4c87-aaa0-7e21616e1897	74790992-d995-41fe-b5c9-fffeaf17f5cd	2026-07-21 11:45:44.744086+00	2026-07-21 11:45:44.744086+00	09bab356-ca7d-4f2b-a863-5ec4bcad25ca	2026-07-03	a37a316c-77ba-4e34-b6e6-af2ff812b379
582b48ec-cec0-4e4b-a7d4-cbfd51751f0f	پیاده‌سازی سامانهٔ مانیتورینگ	پروژهٔ مهندسی و فنی شماره 4	2026-04-26	2026-07-05	active	4ba9028a-0a6d-4c87-aaa0-7e21616e1897	4ae634b0-668f-465b-b3b9-c407a58a5308	2026-07-21 11:45:44.744086+00	2026-07-21 11:45:44.744086+00	09bab356-ca7d-4f2b-a863-5ec4bcad25ca	2026-04-26	a37a316c-77ba-4e34-b6e6-af2ff812b379
582b48ec-cec0-4e4b-a7d4-cbfd51751f0f	بهبود عملکرد پایگاه‌داده	پروژهٔ مهندسی و فنی شماره 5	2026-06-08	2026-09-18	active	4ba9028a-0a6d-4c87-aaa0-7e21616e1897	24b11371-bc5f-4ae3-aee6-5c0dd9dac5cb	2026-07-21 11:45:44.744086+00	2026-07-21 11:45:44.744086+00	09bab356-ca7d-4f2b-a863-5ec4bcad25ca	2026-06-08	a37a316c-77ba-4e34-b6e6-af2ff812b379
582b48ec-cec0-4e4b-a7d4-cbfd51751f0f	بستن حساب‌های مالی سال	پروژهٔ حسابداری و مالی شماره 1	2026-05-22	2026-10-13	active	4ba9028a-0a6d-4c87-aaa0-7e21616e1897	5bcf571d-8fc5-4f23-86c2-bda550998000	2026-07-21 11:45:44.744086+00	2026-07-21 11:45:44.744086+00	98fba7cd-606b-4e45-957c-f63d3a809e84	2026-05-22	cf10ec33-fb1d-4251-b68c-255aa3470fde
582b48ec-cec0-4e4b-a7d4-cbfd51751f0f	پیاده‌سازی سامانهٔ فاکتور الکترونیک	پروژهٔ حسابداری و مالی شماره 2	2026-06-21	2026-11-15	active	4ba9028a-0a6d-4c87-aaa0-7e21616e1897	03032cdb-7a72-4f37-9d58-8b79b5b86638	2026-07-21 11:45:44.744086+00	2026-07-21 11:45:44.744086+00	98fba7cd-606b-4e45-957c-f63d3a809e84	2026-06-21	cf10ec33-fb1d-4251-b68c-255aa3470fde
582b48ec-cec0-4e4b-a7d4-cbfd51751f0f	ممیزی مالی سه‌ماههٔ دوم	پروژهٔ حسابداری و مالی شماره 3	2026-05-11	2026-08-13	active	4ba9028a-0a6d-4c87-aaa0-7e21616e1897	30cf629e-4a36-40a9-9107-ae3dc5cf6578	2026-07-21 11:45:44.744086+00	2026-07-21 11:45:44.744086+00	98fba7cd-606b-4e45-957c-f63d3a809e84	2026-05-11	cf10ec33-fb1d-4251-b68c-255aa3470fde
582b48ec-cec0-4e4b-a7d4-cbfd51751f0f	تدوین بودجهٔ سال آینده	پروژهٔ حسابداری و مالی شماره 4	2026-05-04	2026-08-04	active	4ba9028a-0a6d-4c87-aaa0-7e21616e1897	ad0ecc0e-1dd7-4885-9f2c-fe84502e3653	2026-07-21 11:45:44.744086+00	2026-07-21 11:45:44.744086+00	98fba7cd-606b-4e45-957c-f63d3a809e84	2026-05-04	cf10ec33-fb1d-4251-b68c-255aa3470fde
582b48ec-cec0-4e4b-a7d4-cbfd51751f0f	مدیریت مطالبات و بدهی‌ها	پروژهٔ حسابداری و مالی شماره 5	2026-05-13	2026-07-07	active	4ba9028a-0a6d-4c87-aaa0-7e21616e1897	46dc887e-e603-4c2d-a2d7-4ccc3e411953	2026-07-21 11:45:44.744086+00	2026-07-21 11:45:44.744086+00	98fba7cd-606b-4e45-957c-f63d3a809e84	2026-05-13	cf10ec33-fb1d-4251-b68c-255aa3470fde
582b48ec-cec0-4e4b-a7d4-cbfd51751f0f	برگزاری دورهٔ آموزشی کارکنان	پروژهٔ منابع انسانی شماره 1	2026-05-04	2026-08-26	active	4ba9028a-0a6d-4c87-aaa0-7e21616e1897	627346d8-7181-440e-876c-c8fb6bfbda15	2026-07-21 11:45:44.744086+00	2026-07-21 11:45:44.744086+00	2b35422d-f7be-4135-8473-be7d9e83ec3d	2026-05-04	fbc0e416-765b-415a-82a5-f0ad851343b2
582b48ec-cec0-4e4b-a7d4-cbfd51751f0f	بازطراحی فرایند جذب و استخدام	پروژهٔ منابع انسانی شماره 2	2026-07-02	2026-08-27	active	4ba9028a-0a6d-4c87-aaa0-7e21616e1897	c6e8997e-a96f-44b6-bd28-cf0816eacee2	2026-07-21 11:45:44.744086+00	2026-07-21 11:45:44.744086+00	2b35422d-f7be-4135-8473-be7d9e83ec3d	2026-07-02	fbc0e416-765b-415a-82a5-f0ad851343b2
582b48ec-cec0-4e4b-a7d4-cbfd51751f0f	ارزیابی عملکرد سالانهٔ کارکنان	پروژهٔ منابع انسانی شماره 3	2026-07-04	2026-10-24	active	4ba9028a-0a6d-4c87-aaa0-7e21616e1897	c4da833a-95aa-494c-b901-06b176ddb369	2026-07-21 11:45:44.744086+00	2026-07-21 11:45:44.744086+00	2b35422d-f7be-4135-8473-be7d9e83ec3d	2026-07-04	fbc0e416-765b-415a-82a5-f0ad851343b2
582b48ec-cec0-4e4b-a7d4-cbfd51751f0f	طراحی برنامهٔ رفاهی کارکنان	پروژهٔ منابع انسانی شماره 4	2026-04-19	2026-06-28	active	4ba9028a-0a6d-4c87-aaa0-7e21616e1897	ffc01140-775e-4436-af23-83d1b513e6a1	2026-07-21 11:45:44.744086+00	2026-07-21 11:45:44.744086+00	2b35422d-f7be-4135-8473-be7d9e83ec3d	2026-04-19	fbc0e416-765b-415a-82a5-f0ad851343b2
582b48ec-cec0-4e4b-a7d4-cbfd51751f0f	پیاده‌سازی سامانهٔ حضور و غیاب	پروژهٔ منابع انسانی شماره 5	2026-05-26	2026-07-17	active	4ba9028a-0a6d-4c87-aaa0-7e21616e1897	0767a39d-9ae9-4f98-9da5-55777e3c8055	2026-07-21 11:45:44.744086+00	2026-07-21 11:45:44.744086+00	2b35422d-f7be-4135-8473-be7d9e83ec3d	2026-05-26	fbc0e416-765b-415a-82a5-f0ad851343b2
\.


--
-- Data for Name: task_activity_logs; Type: TABLE DATA; Schema: public; Owner: -
--

COPY public.task_activity_logs (id, created_at, organization_id, task_id, actor_user_id, action, extra_metadata) FROM stdin;
\.


--
-- Data for Name: task_dependencies; Type: TABLE DATA; Schema: public; Owner: -
--

COPY public.task_dependencies (task_id, depends_on_task_id, id, created_at, updated_at) FROM stdin;
\.


--
-- Data for Name: tasks; Type: TABLE DATA; Schema: public; Owner: -
--

COPY public.tasks (organization_id, project_id, parent_task_id, assignee_id, created_by_id, title, description, priority, deadline, id, created_at, updated_at, status, approval_status, progress_percent, estimated_hours, start_date, value) FROM stdin;
582b48ec-cec0-4e4b-a7d4-cbfd51751f0f	f431af97-a16d-4da2-ab34-ee747a30a78b	\N	2ea22145-8b4c-4e52-84fb-acb66c94b186	09bab356-ca7d-4f2b-a863-5ec4bcad25ca	رفع مشکل ناسازگاری مرورگر #1	\N	low	2026-08-08	89facc01-1a6b-4795-b067-9542811622f7	2026-07-21 11:45:44.744086+00	2026-07-21 11:45:44.744086+00	in_progress	\N	54	14.90	2026-08-06	medium
582b48ec-cec0-4e4b-a7d4-cbfd51751f0f	f431af97-a16d-4da2-ab34-ee747a30a78b	\N	e6f6d74c-28cb-4ed3-98b6-6b15a7e57e23	09bab356-ca7d-4f2b-a863-5ec4bcad25ca	پیاده‌سازی صفحهٔ ورود جدید #2	\N	low	2026-08-15	45e476f3-2ff2-4d5f-9a8f-e42f151075d6	2026-07-21 11:45:44.744086+00	2026-07-21 11:45:44.744086+00	in_progress	\N	48	5.70	2026-08-03	medium
582b48ec-cec0-4e4b-a7d4-cbfd51751f0f	f431af97-a16d-4da2-ab34-ee747a30a78b	\N	9bee1760-d3cf-42e2-80de-a78b2be8c965	09bab356-ca7d-4f2b-a863-5ec4bcad25ca	رفع مشکل ناسازگاری مرورگر #3	\N	low	2026-08-03	0eaac504-3fea-4295-8932-23891014da29	2026-07-21 11:45:44.744086+00	2026-07-21 11:45:44.744086+00	in_progress	\N	58	22.40	2026-07-24	medium
582b48ec-cec0-4e4b-a7d4-cbfd51751f0f	f431af97-a16d-4da2-ab34-ee747a30a78b	\N	28996900-cff9-4923-bdf4-33c0c602bda7	09bab356-ca7d-4f2b-a863-5ec4bcad25ca	بازنویسی ماژول اعلان‌ها #4	\N	high	2026-08-01	3c9345a8-53b9-40be-b01d-b3ae972bc058	2026-07-21 11:45:44.744086+00	2026-07-21 11:45:44.744086+00	todo	\N	79	35.60	2026-07-21	medium
582b48ec-cec0-4e4b-a7d4-cbfd51751f0f	f431af97-a16d-4da2-ab34-ee747a30a78b	\N	0885409c-d2f4-4296-88c0-d8ac1df6a7e5	09bab356-ca7d-4f2b-a863-5ec4bcad25ca	تنظیم پایپ‌لاین CI/CD #5	\N	low	2026-06-23	de963c61-0f29-44f0-832b-299281c93b8e	2026-07-21 11:45:44.744086+00	2026-07-21 11:45:44.744086+00	completed	approved	100	31.40	2026-06-20	medium
582b48ec-cec0-4e4b-a7d4-cbfd51751f0f	f431af97-a16d-4da2-ab34-ee747a30a78b	\N	09bab356-ca7d-4f2b-a863-5ec4bcad25ca	09bab356-ca7d-4f2b-a863-5ec4bcad25ca	پیاده‌سازی احراز هویت دومرحله‌ای #6	\N	medium	2026-08-15	751f3611-30e2-4cef-beff-236296ec6aee	2026-07-21 11:45:44.744086+00	2026-07-21 11:45:44.744086+00	in_progress	\N	58	26.20	2026-08-10	medium
582b48ec-cec0-4e4b-a7d4-cbfd51751f0f	f431af97-a16d-4da2-ab34-ee747a30a78b	\N	0885409c-d2f4-4296-88c0-d8ac1df6a7e5	09bab356-ca7d-4f2b-a863-5ec4bcad25ca	افزودن تست واحد برای سرویس کاربران #7	\N	high	2026-07-22	7fe9d38b-fe46-42d4-8101-a99a94675567	2026-07-21 11:45:44.744086+00	2026-07-21 11:45:44.744086+00	todo	\N	34	28.70	2026-07-09	medium
582b48ec-cec0-4e4b-a7d4-cbfd51751f0f	f431af97-a16d-4da2-ab34-ee747a30a78b	\N	de505605-7889-4573-8969-c65f885903c4	09bab356-ca7d-4f2b-a863-5ec4bcad25ca	به‌روزرسانی کتابخانه‌های وابسته #8	\N	high	2026-08-02	2a63d37b-4adb-47bf-8f3a-38c80fe7e01d	2026-07-21 11:45:44.744086+00	2026-07-21 11:45:44.744086+00	completed	approved	100	11.30	2026-07-26	medium
582b48ec-cec0-4e4b-a7d4-cbfd51751f0f	f431af97-a16d-4da2-ab34-ee747a30a78b	\N	28996900-cff9-4923-bdf4-33c0c602bda7	09bab356-ca7d-4f2b-a863-5ec4bcad25ca	افزودن تست واحد برای سرویس کاربران #9	\N	high	2026-07-22	fc5ee494-d6e3-4893-a066-ce7f46c902bd	2026-07-21 11:45:44.744086+00	2026-07-21 11:45:44.744086+00	in_progress	\N	41	34.00	2026-07-03	medium
582b48ec-cec0-4e4b-a7d4-cbfd51751f0f	f431af97-a16d-4da2-ab34-ee747a30a78b	\N	9bee1760-d3cf-42e2-80de-a78b2be8c965	09bab356-ca7d-4f2b-a863-5ec4bcad25ca	رفع مشکل ناسازگاری مرورگر #10	\N	medium	2026-07-03	5fd2dc23-ee21-4a6a-86a7-1125f9db335b	2026-07-21 11:45:44.744086+00	2026-07-21 11:45:44.744086+00	todo	\N	51	12.20	2026-06-30	medium
582b48ec-cec0-4e4b-a7d4-cbfd51751f0f	f431af97-a16d-4da2-ab34-ee747a30a78b	\N	e6f6d74c-28cb-4ed3-98b6-6b15a7e57e23	09bab356-ca7d-4f2b-a863-5ec4bcad25ca	تنظیم پایپ‌لاین CI/CD #11	\N	medium	2026-07-14	56b3bd80-b324-4b80-8bd3-754b4053daca	2026-07-21 11:45:44.744086+00	2026-07-21 11:45:44.744086+00	completed	pending	100	17.00	2026-07-06	medium
582b48ec-cec0-4e4b-a7d4-cbfd51751f0f	f431af97-a16d-4da2-ab34-ee747a30a78b	\N	de505605-7889-4573-8969-c65f885903c4	09bab356-ca7d-4f2b-a863-5ec4bcad25ca	نوشتن مستندات فنی API #12	\N	high	2026-07-03	19770ef2-249c-499c-91cd-b8d9c9335130	2026-07-21 11:45:44.744086+00	2026-07-21 11:45:44.744086+00	completed	approved	100	22.50	2026-06-24	medium
582b48ec-cec0-4e4b-a7d4-cbfd51751f0f	f431af97-a16d-4da2-ab34-ee747a30a78b	\N	de505605-7889-4573-8969-c65f885903c4	09bab356-ca7d-4f2b-a863-5ec4bcad25ca	رفع مشکل کندی بارگذاری صفحه #13	\N	low	2026-08-06	277cdf04-6d7c-484a-9891-68d6f9099ad6	2026-07-21 11:45:44.744086+00	2026-07-21 11:45:44.744086+00	completed	approved	100	39.90	2026-07-23	medium
582b48ec-cec0-4e4b-a7d4-cbfd51751f0f	f431af97-a16d-4da2-ab34-ee747a30a78b	\N	e6f6d74c-28cb-4ed3-98b6-6b15a7e57e23	09bab356-ca7d-4f2b-a863-5ec4bcad25ca	بازنویسی ماژول اعلان‌ها #14	\N	low	2026-08-06	ccde4e50-a8f7-4e96-a612-c4c2d0fa43e7	2026-07-21 11:45:44.744086+00	2026-07-21 11:45:44.744086+00	completed	approved	100	7.80	2026-08-03	medium
582b48ec-cec0-4e4b-a7d4-cbfd51751f0f	f431af97-a16d-4da2-ab34-ee747a30a78b	\N	e6f6d74c-28cb-4ed3-98b6-6b15a7e57e23	09bab356-ca7d-4f2b-a863-5ec4bcad25ca	پیاده‌سازی احراز هویت دومرحله‌ای #15	\N	high	2026-07-04	645d22cb-0bf0-4f46-a52c-c07e5a397fec	2026-07-21 11:45:44.744086+00	2026-07-21 11:45:44.744086+00	completed	approved	100	39.90	2026-06-20	medium
582b48ec-cec0-4e4b-a7d4-cbfd51751f0f	f431af97-a16d-4da2-ab34-ee747a30a78b	\N	2ea22145-8b4c-4e52-84fb-acb66c94b186	09bab356-ca7d-4f2b-a863-5ec4bcad25ca	تنظیم پایپ‌لاین CI/CD #16	\N	high	2026-07-23	b4b76783-0815-4f2b-a838-6de2bf969814	2026-07-21 11:45:44.744086+00	2026-07-21 11:45:44.744086+00	in_progress	\N	14	27.90	2026-07-21	medium
582b48ec-cec0-4e4b-a7d4-cbfd51751f0f	f431af97-a16d-4da2-ab34-ee747a30a78b	\N	2ea22145-8b4c-4e52-84fb-acb66c94b186	09bab356-ca7d-4f2b-a863-5ec4bcad25ca	پیاده‌سازی صفحهٔ ورود جدید #17	\N	medium	2026-07-15	c6451582-e82d-4670-81ee-694d8f4c0a1b	2026-07-21 11:45:44.744086+00	2026-07-21 11:45:44.744086+00	archived	\N	55	8.00	2026-07-03	medium
582b48ec-cec0-4e4b-a7d4-cbfd51751f0f	f431af97-a16d-4da2-ab34-ee747a30a78b	\N	09bab356-ca7d-4f2b-a863-5ec4bcad25ca	09bab356-ca7d-4f2b-a863-5ec4bcad25ca	به‌روزرسانی کتابخانه‌های وابسته #18	\N	low	2026-08-21	283aebdb-c7c5-4f2e-8a1d-99b2a2d834ec	2026-07-21 11:45:44.744086+00	2026-07-21 11:45:44.744086+00	archived	\N	64	36.70	2026-08-11	medium
582b48ec-cec0-4e4b-a7d4-cbfd51751f0f	57f6bd9c-475a-424c-af79-6a12be955b40	\N	9bee1760-d3cf-42e2-80de-a78b2be8c965	09bab356-ca7d-4f2b-a863-5ec4bcad25ca	پیاده‌سازی صفحهٔ داشبورد مدیریتی #19	\N	low	2026-08-13	9f7f9177-2361-4b5b-b67c-c081230681ab	2026-07-21 11:45:44.744086+00	2026-07-21 11:45:44.744086+00	completed	approved	100	7.80	2026-07-26	medium
582b48ec-cec0-4e4b-a7d4-cbfd51751f0f	57f6bd9c-475a-424c-af79-6a12be955b40	\N	9bee1760-d3cf-42e2-80de-a78b2be8c965	09bab356-ca7d-4f2b-a863-5ec4bcad25ca	افزودن قابلیت جست‌وجوی پیشرفته #20	\N	low	2026-08-07	982b90d5-ad86-4bf4-801f-0eb518c8292c	2026-07-21 11:45:44.744086+00	2026-07-21 11:45:44.744086+00	todo	\N	76	14.30	2026-07-20	medium
582b48ec-cec0-4e4b-a7d4-cbfd51751f0f	57f6bd9c-475a-424c-af79-6a12be955b40	\N	09bab356-ca7d-4f2b-a863-5ec4bcad25ca	09bab356-ca7d-4f2b-a863-5ec4bcad25ca	افزودن قابلیت جست‌وجوی پیشرفته #21	\N	medium	2026-08-27	e168f437-d115-47e7-897c-1248c3f16dd3	2026-07-21 11:45:44.744086+00	2026-07-21 11:45:44.744086+00	todo	\N	30	4.20	2026-08-14	medium
582b48ec-cec0-4e4b-a7d4-cbfd51751f0f	57f6bd9c-475a-424c-af79-6a12be955b40	\N	2ea22145-8b4c-4e52-84fb-acb66c94b186	09bab356-ca7d-4f2b-a863-5ec4bcad25ca	بازنویسی ماژول اعلان‌ها #22	\N	low	2026-07-08	ebcb085e-b3fc-4240-a60b-d61abd8bffa0	2026-07-21 11:45:44.744086+00	2026-07-21 11:45:44.744086+00	todo	\N	68	31.10	2026-06-21	medium
582b48ec-cec0-4e4b-a7d4-cbfd51751f0f	57f6bd9c-475a-424c-af79-6a12be955b40	\N	e6f6d74c-28cb-4ed3-98b6-6b15a7e57e23	09bab356-ca7d-4f2b-a863-5ec4bcad25ca	طراحی API نسخهٔ دوم #23	\N	high	2026-07-28	b2fb7128-ace3-4367-8d30-8ce55edb660e	2026-07-21 11:45:44.744086+00	2026-07-21 11:45:44.744086+00	completed	approved	100	35.20	2026-07-21	medium
582b48ec-cec0-4e4b-a7d4-cbfd51751f0f	57f6bd9c-475a-424c-af79-6a12be955b40	\N	28996900-cff9-4923-bdf4-33c0c602bda7	09bab356-ca7d-4f2b-a863-5ec4bcad25ca	رفع مشکل ناسازگاری مرورگر #24	\N	high	2026-09-02	5e6cfd59-67ea-40f7-b670-e8d0f3b3793e	2026-07-21 11:45:44.744086+00	2026-07-21 11:45:44.744086+00	in_progress	\N	25	29.10	2026-08-14	medium
582b48ec-cec0-4e4b-a7d4-cbfd51751f0f	57f6bd9c-475a-424c-af79-6a12be955b40	\N	28996900-cff9-4923-bdf4-33c0c602bda7	09bab356-ca7d-4f2b-a863-5ec4bcad25ca	بررسی و رفع آسیب‌پذیری امنیتی #25	\N	low	2026-08-01	d9390e2e-da2a-4ecf-9c3e-4f564a940ea4	2026-07-21 11:45:44.744086+00	2026-07-21 11:45:44.744086+00	completed	pending	100	11.40	2026-07-14	medium
582b48ec-cec0-4e4b-a7d4-cbfd51751f0f	57f6bd9c-475a-424c-af79-6a12be955b40	\N	09bab356-ca7d-4f2b-a863-5ec4bcad25ca	09bab356-ca7d-4f2b-a863-5ec4bcad25ca	به‌روزرسانی کتابخانه‌های وابسته #26	\N	low	2026-07-07	81d31027-d700-4a4d-9add-7fa1a2aaf879	2026-07-21 11:45:44.744086+00	2026-07-21 11:45:44.744086+00	in_progress	\N	75	10.40	2026-06-17	medium
582b48ec-cec0-4e4b-a7d4-cbfd51751f0f	57f6bd9c-475a-424c-af79-6a12be955b40	\N	09bab356-ca7d-4f2b-a863-5ec4bcad25ca	09bab356-ca7d-4f2b-a863-5ec4bcad25ca	افزودن تست واحد برای سرویس کاربران #27	\N	low	2026-07-29	e5b1cc9d-2d23-4c68-aff6-c98712d1c055	2026-07-21 11:45:44.744086+00	2026-07-21 11:45:44.744086+00	archived	\N	4	34.70	2026-07-26	medium
582b48ec-cec0-4e4b-a7d4-cbfd51751f0f	57f6bd9c-475a-424c-af79-6a12be955b40	\N	09bab356-ca7d-4f2b-a863-5ec4bcad25ca	09bab356-ca7d-4f2b-a863-5ec4bcad25ca	افزودن تست واحد برای سرویس کاربران #28	\N	high	2026-08-14	11d3443b-2a4a-44d8-a961-27fa543dc046	2026-07-21 11:45:44.744086+00	2026-07-21 11:45:44.744086+00	completed	approved	100	7.00	2026-07-28	medium
582b48ec-cec0-4e4b-a7d4-cbfd51751f0f	57f6bd9c-475a-424c-af79-6a12be955b40	\N	2ea22145-8b4c-4e52-84fb-acb66c94b186	09bab356-ca7d-4f2b-a863-5ec4bcad25ca	رفع مشکل ناسازگاری مرورگر #29	\N	medium	2026-08-22	d3d54802-a6af-4486-9a5f-87b4a438e2d8	2026-07-21 11:45:44.744086+00	2026-07-21 11:45:44.744086+00	completed	approved	100	9.20	2026-08-05	medium
582b48ec-cec0-4e4b-a7d4-cbfd51751f0f	57f6bd9c-475a-424c-af79-6a12be955b40	\N	09bab356-ca7d-4f2b-a863-5ec4bcad25ca	09bab356-ca7d-4f2b-a863-5ec4bcad25ca	بررسی و رفع آسیب‌پذیری امنیتی #30	\N	high	2026-07-28	3f52edb5-b21c-4bc7-be04-9bec0c15832c	2026-07-21 11:45:44.744086+00	2026-07-21 11:45:44.744086+00	completed	approved	100	4.10	2026-07-13	medium
582b48ec-cec0-4e4b-a7d4-cbfd51751f0f	57f6bd9c-475a-424c-af79-6a12be955b40	\N	de505605-7889-4573-8969-c65f885903c4	09bab356-ca7d-4f2b-a863-5ec4bcad25ca	رفع مشکل ناسازگاری مرورگر #31	\N	low	2026-07-23	9c00f60a-68e5-4e5d-8c9c-77ed950aa788	2026-07-21 11:45:44.744086+00	2026-07-21 11:45:44.744086+00	completed	approved	100	11.40	2026-07-11	medium
582b48ec-cec0-4e4b-a7d4-cbfd51751f0f	57f6bd9c-475a-424c-af79-6a12be955b40	\N	e6f6d74c-28cb-4ed3-98b6-6b15a7e57e23	09bab356-ca7d-4f2b-a863-5ec4bcad25ca	طراحی API نسخهٔ دوم #32	\N	medium	2026-07-20	b426e3c3-edf9-4912-9916-bb70f2048791	2026-07-21 11:45:44.744086+00	2026-07-21 11:45:44.744086+00	completed	approved	100	11.50	2026-07-13	medium
582b48ec-cec0-4e4b-a7d4-cbfd51751f0f	57f6bd9c-475a-424c-af79-6a12be955b40	\N	09bab356-ca7d-4f2b-a863-5ec4bcad25ca	09bab356-ca7d-4f2b-a863-5ec4bcad25ca	پیاده‌سازی صفحهٔ ورود جدید #33	\N	low	2026-08-28	03592919-9dad-4261-bfe2-8fb533b72dbc	2026-07-21 11:45:44.744086+00	2026-07-21 11:45:44.744086+00	completed	pending	100	26.80	2026-08-09	medium
582b48ec-cec0-4e4b-a7d4-cbfd51751f0f	57f6bd9c-475a-424c-af79-6a12be955b40	\N	2ea22145-8b4c-4e52-84fb-acb66c94b186	09bab356-ca7d-4f2b-a863-5ec4bcad25ca	بهینه‌سازی کوئری‌های گزارش‌گیری #34	\N	medium	2026-06-30	c2b0e9a7-d441-4fd6-b67d-0ed456c6dcd5	2026-07-21 11:45:44.744086+00	2026-07-21 11:45:44.744086+00	todo	\N	62	20.30	2026-06-21	medium
582b48ec-cec0-4e4b-a7d4-cbfd51751f0f	57f6bd9c-475a-424c-af79-6a12be955b40	\N	9bee1760-d3cf-42e2-80de-a78b2be8c965	09bab356-ca7d-4f2b-a863-5ec4bcad25ca	بهینه‌سازی کوئری‌های گزارش‌گیری #35	\N	medium	2026-08-15	05c9ebc1-a752-43b6-a9f8-b5cc683790b1	2026-07-21 11:45:44.744086+00	2026-07-21 11:45:44.744086+00	in_progress	\N	0	39.40	2026-08-12	medium
582b48ec-cec0-4e4b-a7d4-cbfd51751f0f	57f6bd9c-475a-424c-af79-6a12be955b40	\N	0885409c-d2f4-4296-88c0-d8ac1df6a7e5	09bab356-ca7d-4f2b-a863-5ec4bcad25ca	تنظیم پایپ‌لاین CI/CD #36	\N	high	2026-08-18	468b9a94-5841-4f14-90d1-a3d61e36b24c	2026-07-21 11:45:44.744086+00	2026-07-21 11:45:44.744086+00	completed	approved	100	20.50	2026-07-30	medium
582b48ec-cec0-4e4b-a7d4-cbfd51751f0f	74790992-d995-41fe-b5c9-fffeaf17f5cd	\N	e6f6d74c-28cb-4ed3-98b6-6b15a7e57e23	09bab356-ca7d-4f2b-a863-5ec4bcad25ca	پیاده‌سازی صفحهٔ داشبورد مدیریتی #37	\N	high	2026-07-02	5cdf5576-aba3-4aec-9f47-3d9fb6639fc8	2026-07-21 11:45:44.744086+00	2026-07-21 11:45:44.744086+00	in_progress	\N	69	4.30	2026-06-29	medium
582b48ec-cec0-4e4b-a7d4-cbfd51751f0f	74790992-d995-41fe-b5c9-fffeaf17f5cd	\N	0885409c-d2f4-4296-88c0-d8ac1df6a7e5	09bab356-ca7d-4f2b-a863-5ec4bcad25ca	بررسی و رفع آسیب‌پذیری امنیتی #38	\N	high	2026-07-09	d26d85e1-017f-48fd-a4c7-6df0b132348e	2026-07-21 11:45:44.744086+00	2026-07-21 11:45:44.744086+00	todo	\N	67	8.00	2026-06-19	medium
582b48ec-cec0-4e4b-a7d4-cbfd51751f0f	74790992-d995-41fe-b5c9-fffeaf17f5cd	\N	2ea22145-8b4c-4e52-84fb-acb66c94b186	09bab356-ca7d-4f2b-a863-5ec4bcad25ca	پیاده‌سازی صفحهٔ ورود جدید #39	\N	high	2026-08-16	8077c527-5fe9-455e-8acd-c8314cde77d0	2026-07-21 11:45:44.744086+00	2026-07-21 11:45:44.744086+00	todo	\N	8	27.70	2026-08-09	medium
582b48ec-cec0-4e4b-a7d4-cbfd51751f0f	74790992-d995-41fe-b5c9-fffeaf17f5cd	\N	e6f6d74c-28cb-4ed3-98b6-6b15a7e57e23	09bab356-ca7d-4f2b-a863-5ec4bcad25ca	افزودن تست واحد برای سرویس کاربران #40	\N	high	2026-07-13	d4b7c0fd-dfe1-4ebb-8bc9-c5a2c950869c	2026-07-21 11:45:44.744086+00	2026-07-21 11:45:44.744086+00	in_progress	\N	76	3.50	2026-06-23	medium
582b48ec-cec0-4e4b-a7d4-cbfd51751f0f	74790992-d995-41fe-b5c9-fffeaf17f5cd	\N	09bab356-ca7d-4f2b-a863-5ec4bcad25ca	09bab356-ca7d-4f2b-a863-5ec4bcad25ca	پیاده‌سازی صفحهٔ داشبورد مدیریتی #41	\N	high	2026-08-17	512a1264-ef04-49cb-8690-0cbcaa7bc0fe	2026-07-21 11:45:44.744086+00	2026-07-21 11:45:44.744086+00	in_progress	\N	40	37.50	2026-07-28	medium
582b48ec-cec0-4e4b-a7d4-cbfd51751f0f	74790992-d995-41fe-b5c9-fffeaf17f5cd	\N	e6f6d74c-28cb-4ed3-98b6-6b15a7e57e23	09bab356-ca7d-4f2b-a863-5ec4bcad25ca	پیاده‌سازی احراز هویت دومرحله‌ای #42	\N	low	2026-07-11	af66944f-bb48-4d46-a5c1-eb8c8fc92fa8	2026-07-21 11:45:44.744086+00	2026-07-21 11:45:44.744086+00	completed	pending	100	27.50	2026-07-01	medium
582b48ec-cec0-4e4b-a7d4-cbfd51751f0f	74790992-d995-41fe-b5c9-fffeaf17f5cd	\N	0885409c-d2f4-4296-88c0-d8ac1df6a7e5	09bab356-ca7d-4f2b-a863-5ec4bcad25ca	رفع باگ در ماژول پرداخت #43	\N	medium	2026-08-07	a549013b-72a7-4bda-8421-6fa1e35b1bfa	2026-07-21 11:45:44.744086+00	2026-07-21 11:45:44.744086+00	completed	approved	100	25.60	2026-08-03	medium
582b48ec-cec0-4e4b-a7d4-cbfd51751f0f	74790992-d995-41fe-b5c9-fffeaf17f5cd	\N	2ea22145-8b4c-4e52-84fb-acb66c94b186	09bab356-ca7d-4f2b-a863-5ec4bcad25ca	افزودن تست واحد برای سرویس کاربران #44	\N	high	2026-07-09	bf9c21ae-2c56-47e4-8591-1ff7a96699eb	2026-07-21 11:45:44.744086+00	2026-07-21 11:45:44.744086+00	todo	\N	33	7.00	2026-06-20	medium
582b48ec-cec0-4e4b-a7d4-cbfd51751f0f	74790992-d995-41fe-b5c9-fffeaf17f5cd	\N	0885409c-d2f4-4296-88c0-d8ac1df6a7e5	09bab356-ca7d-4f2b-a863-5ec4bcad25ca	رفع مشکل کندی بارگذاری صفحه #45	\N	medium	2026-08-20	a027d89c-2474-4a31-858e-3f78222e6bfd	2026-07-21 11:45:44.744086+00	2026-07-21 11:45:44.744086+00	todo	\N	20	18.70	2026-08-11	medium
582b48ec-cec0-4e4b-a7d4-cbfd51751f0f	74790992-d995-41fe-b5c9-fffeaf17f5cd	\N	2ea22145-8b4c-4e52-84fb-acb66c94b186	09bab356-ca7d-4f2b-a863-5ec4bcad25ca	رفع مشکل ناسازگاری مرورگر #46	\N	high	2026-07-26	e9cc45b0-b047-42b4-9568-d5f885949b47	2026-07-21 11:45:44.744086+00	2026-07-21 11:45:44.744086+00	archived	\N	67	2.30	2026-07-05	medium
582b48ec-cec0-4e4b-a7d4-cbfd51751f0f	74790992-d995-41fe-b5c9-fffeaf17f5cd	\N	9bee1760-d3cf-42e2-80de-a78b2be8c965	09bab356-ca7d-4f2b-a863-5ec4bcad25ca	افزودن قابلیت جست‌وجوی پیشرفته #47	\N	low	2026-08-02	15608f39-ede1-4501-b5b6-7f6687356c0f	2026-07-21 11:45:44.744086+00	2026-07-21 11:45:44.744086+00	completed	approved	100	12.00	2026-07-28	medium
582b48ec-cec0-4e4b-a7d4-cbfd51751f0f	74790992-d995-41fe-b5c9-fffeaf17f5cd	\N	09bab356-ca7d-4f2b-a863-5ec4bcad25ca	09bab356-ca7d-4f2b-a863-5ec4bcad25ca	طراحی API نسخهٔ دوم #48	\N	medium	2026-07-27	0e60b1a7-c954-40fc-8556-ea732a4d5a8b	2026-07-21 11:45:44.744086+00	2026-07-21 11:45:44.744086+00	archived	\N	77	10.00	2026-07-21	medium
582b48ec-cec0-4e4b-a7d4-cbfd51751f0f	74790992-d995-41fe-b5c9-fffeaf17f5cd	\N	0885409c-d2f4-4296-88c0-d8ac1df6a7e5	09bab356-ca7d-4f2b-a863-5ec4bcad25ca	به‌روزرسانی کتابخانه‌های وابسته #49	\N	medium	2026-08-08	7b9835a7-6465-47ba-9347-a41c4991609d	2026-07-21 11:45:44.744086+00	2026-07-21 11:45:44.744086+00	in_progress	\N	32	36.40	2026-07-29	medium
582b48ec-cec0-4e4b-a7d4-cbfd51751f0f	74790992-d995-41fe-b5c9-fffeaf17f5cd	\N	9bee1760-d3cf-42e2-80de-a78b2be8c965	09bab356-ca7d-4f2b-a863-5ec4bcad25ca	بازنویسی ماژول اعلان‌ها #50	\N	medium	2026-07-06	35304574-46ad-4faa-877b-193b16ff9323	2026-07-21 11:45:44.744086+00	2026-07-21 11:45:44.744086+00	todo	\N	5	2.10	2026-06-21	medium
582b48ec-cec0-4e4b-a7d4-cbfd51751f0f	74790992-d995-41fe-b5c9-fffeaf17f5cd	\N	9bee1760-d3cf-42e2-80de-a78b2be8c965	09bab356-ca7d-4f2b-a863-5ec4bcad25ca	بهینه‌سازی کوئری‌های گزارش‌گیری #51	\N	high	2026-08-05	433ba205-3f13-455c-987e-377995147e44	2026-07-21 11:45:44.744086+00	2026-07-21 11:45:44.744086+00	todo	\N	56	23.00	2026-07-26	medium
582b48ec-cec0-4e4b-a7d4-cbfd51751f0f	74790992-d995-41fe-b5c9-fffeaf17f5cd	\N	28996900-cff9-4923-bdf4-33c0c602bda7	09bab356-ca7d-4f2b-a863-5ec4bcad25ca	به‌روزرسانی کتابخانه‌های وابسته #52	\N	low	2026-06-26	ac1723be-bec8-4f21-807a-31f55a9f1820	2026-07-21 11:45:44.744086+00	2026-07-21 11:45:44.744086+00	completed	approved	100	33.70	2026-06-20	medium
582b48ec-cec0-4e4b-a7d4-cbfd51751f0f	74790992-d995-41fe-b5c9-fffeaf17f5cd	\N	2ea22145-8b4c-4e52-84fb-acb66c94b186	09bab356-ca7d-4f2b-a863-5ec4bcad25ca	طراحی API نسخهٔ دوم #53	\N	medium	2026-06-27	d6a4eaa2-2448-4681-bcb1-b6196f8e96af	2026-07-21 11:45:44.744086+00	2026-07-21 11:45:44.744086+00	completed	approved	100	36.20	2026-06-24	medium
582b48ec-cec0-4e4b-a7d4-cbfd51751f0f	74790992-d995-41fe-b5c9-fffeaf17f5cd	\N	9bee1760-d3cf-42e2-80de-a78b2be8c965	09bab356-ca7d-4f2b-a863-5ec4bcad25ca	افزودن تست واحد برای سرویس کاربران #54	\N	high	2026-08-25	be70b63a-ba1b-4ed9-a141-75d9980b53bd	2026-07-21 11:45:44.744086+00	2026-07-21 11:45:44.744086+00	todo	\N	31	27.30	2026-08-12	medium
582b48ec-cec0-4e4b-a7d4-cbfd51751f0f	4ae634b0-668f-465b-b3b9-c407a58a5308	\N	0885409c-d2f4-4296-88c0-d8ac1df6a7e5	09bab356-ca7d-4f2b-a863-5ec4bcad25ca	پیاده‌سازی صفحهٔ داشبورد مدیریتی #55	\N	high	2026-08-05	11943d22-7b3b-45ac-9db1-cc7391944889	2026-07-21 11:45:44.744086+00	2026-07-21 11:45:44.744086+00	archived	\N	19	37.20	2026-07-21	medium
582b48ec-cec0-4e4b-a7d4-cbfd51751f0f	4ae634b0-668f-465b-b3b9-c407a58a5308	\N	e6f6d74c-28cb-4ed3-98b6-6b15a7e57e23	09bab356-ca7d-4f2b-a863-5ec4bcad25ca	افزودن قابلیت جست‌وجوی پیشرفته #56	\N	medium	2026-08-13	2266c76d-4ffb-40fb-9ca2-2d5161cf60ad	2026-07-21 11:45:44.744086+00	2026-07-21 11:45:44.744086+00	todo	\N	3	8.80	2026-08-06	medium
582b48ec-cec0-4e4b-a7d4-cbfd51751f0f	4ae634b0-668f-465b-b3b9-c407a58a5308	\N	0885409c-d2f4-4296-88c0-d8ac1df6a7e5	09bab356-ca7d-4f2b-a863-5ec4bcad25ca	طراحی API نسخهٔ دوم #57	\N	low	2026-08-15	5c4e6bb4-401c-4f4b-b161-e3271f41a041	2026-07-21 11:45:44.744086+00	2026-07-21 11:45:44.744086+00	in_progress	\N	13	16.50	2026-08-06	medium
582b48ec-cec0-4e4b-a7d4-cbfd51751f0f	4ae634b0-668f-465b-b3b9-c407a58a5308	\N	09bab356-ca7d-4f2b-a863-5ec4bcad25ca	09bab356-ca7d-4f2b-a863-5ec4bcad25ca	رفع مشکل کندی بارگذاری صفحه #58	\N	medium	2026-08-23	2b9fec3d-0687-467e-a7c8-7dd69d89d705	2026-07-21 11:45:44.744086+00	2026-07-21 11:45:44.744086+00	completed	approved	100	33.20	2026-08-07	medium
582b48ec-cec0-4e4b-a7d4-cbfd51751f0f	4ae634b0-668f-465b-b3b9-c407a58a5308	\N	9bee1760-d3cf-42e2-80de-a78b2be8c965	09bab356-ca7d-4f2b-a863-5ec4bcad25ca	تنظیم پایپ‌لاین CI/CD #59	\N	low	2026-07-02	f5941fc2-3770-42f6-80f0-0a58d1e91dc0	2026-07-21 11:45:44.744086+00	2026-07-21 11:45:44.744086+00	in_progress	\N	51	14.50	2026-06-30	medium
582b48ec-cec0-4e4b-a7d4-cbfd51751f0f	4ae634b0-668f-465b-b3b9-c407a58a5308	\N	9bee1760-d3cf-42e2-80de-a78b2be8c965	09bab356-ca7d-4f2b-a863-5ec4bcad25ca	رفع مشکل کندی بارگذاری صفحه #60	\N	high	2026-08-14	6c843879-eb11-4db0-8509-0f500be714dc	2026-07-21 11:45:44.744086+00	2026-07-21 11:45:44.744086+00	todo	\N	65	17.20	2026-08-04	medium
582b48ec-cec0-4e4b-a7d4-cbfd51751f0f	4ae634b0-668f-465b-b3b9-c407a58a5308	\N	9bee1760-d3cf-42e2-80de-a78b2be8c965	09bab356-ca7d-4f2b-a863-5ec4bcad25ca	افزودن قابلیت جست‌وجوی پیشرفته #61	\N	medium	2026-06-22	554fa731-54a8-4afd-96ee-f52efc73ea5b	2026-07-21 11:45:44.744086+00	2026-07-21 11:45:44.744086+00	completed	approved	100	8.80	2026-06-17	medium
582b48ec-cec0-4e4b-a7d4-cbfd51751f0f	4ae634b0-668f-465b-b3b9-c407a58a5308	\N	0885409c-d2f4-4296-88c0-d8ac1df6a7e5	09bab356-ca7d-4f2b-a863-5ec4bcad25ca	پیاده‌سازی احراز هویت دومرحله‌ای #62	\N	medium	2026-07-13	f3a50ac3-4142-4bb0-a5ed-a3feecbb11e9	2026-07-21 11:45:44.744086+00	2026-07-21 11:45:44.744086+00	todo	\N	40	18.60	2026-06-22	medium
582b48ec-cec0-4e4b-a7d4-cbfd51751f0f	4ae634b0-668f-465b-b3b9-c407a58a5308	\N	2ea22145-8b4c-4e52-84fb-acb66c94b186	09bab356-ca7d-4f2b-a863-5ec4bcad25ca	افزودن تست واحد برای سرویس کاربران #63	\N	medium	2026-07-30	ae7873f8-db25-4125-9ed3-91f7865bd4b9	2026-07-21 11:45:44.744086+00	2026-07-21 11:45:44.744086+00	todo	\N	5	28.90	2026-07-10	medium
582b48ec-cec0-4e4b-a7d4-cbfd51751f0f	4ae634b0-668f-465b-b3b9-c407a58a5308	\N	09bab356-ca7d-4f2b-a863-5ec4bcad25ca	09bab356-ca7d-4f2b-a863-5ec4bcad25ca	رفع مشکل کندی بارگذاری صفحه #64	\N	medium	2026-07-28	0c5817fd-c1bd-4fb2-b37b-dc671fef5696	2026-07-21 11:45:44.744086+00	2026-07-21 11:45:44.744086+00	completed	rejected	100	4.70	2026-07-20	medium
582b48ec-cec0-4e4b-a7d4-cbfd51751f0f	4ae634b0-668f-465b-b3b9-c407a58a5308	\N	de505605-7889-4573-8969-c65f885903c4	09bab356-ca7d-4f2b-a863-5ec4bcad25ca	تنظیم پایپ‌لاین CI/CD #65	\N	low	2026-08-06	dea5dbf0-b0e7-4ac6-9635-18a68e3c2acd	2026-07-21 11:45:44.744086+00	2026-07-21 11:45:44.744086+00	in_progress	\N	38	21.30	2026-07-25	medium
582b48ec-cec0-4e4b-a7d4-cbfd51751f0f	4ae634b0-668f-465b-b3b9-c407a58a5308	\N	de505605-7889-4573-8969-c65f885903c4	09bab356-ca7d-4f2b-a863-5ec4bcad25ca	نوشتن مستندات فنی API #66	\N	medium	2026-07-20	438a6150-39db-4479-a38f-7022b9423818	2026-07-21 11:45:44.744086+00	2026-07-21 11:45:44.744086+00	in_progress	\N	70	6.80	2026-07-06	medium
582b48ec-cec0-4e4b-a7d4-cbfd51751f0f	4ae634b0-668f-465b-b3b9-c407a58a5308	\N	28996900-cff9-4923-bdf4-33c0c602bda7	09bab356-ca7d-4f2b-a863-5ec4bcad25ca	پیاده‌سازی صفحهٔ داشبورد مدیریتی #67	\N	high	2026-08-05	527bdd1b-e6c2-464e-879f-0aedf1f81486	2026-07-21 11:45:44.744086+00	2026-07-21 11:45:44.744086+00	completed	rejected	100	13.40	2026-07-29	medium
582b48ec-cec0-4e4b-a7d4-cbfd51751f0f	4ae634b0-668f-465b-b3b9-c407a58a5308	\N	2ea22145-8b4c-4e52-84fb-acb66c94b186	09bab356-ca7d-4f2b-a863-5ec4bcad25ca	افزودن تست واحد برای سرویس کاربران #68	\N	medium	2026-07-16	2cdb2d50-dfe2-45ad-b2d0-484e1d197e4b	2026-07-21 11:45:44.744086+00	2026-07-21 11:45:44.744086+00	todo	\N	74	25.10	2026-07-05	medium
582b48ec-cec0-4e4b-a7d4-cbfd51751f0f	4ae634b0-668f-465b-b3b9-c407a58a5308	\N	0885409c-d2f4-4296-88c0-d8ac1df6a7e5	09bab356-ca7d-4f2b-a863-5ec4bcad25ca	به‌روزرسانی کتابخانه‌های وابسته #69	\N	medium	2026-08-06	4ee0c10d-3680-4dd6-b8b1-24f622561994	2026-07-21 11:45:44.744086+00	2026-07-21 11:45:44.744086+00	completed	approved	100	32.20	2026-07-29	medium
582b48ec-cec0-4e4b-a7d4-cbfd51751f0f	4ae634b0-668f-465b-b3b9-c407a58a5308	\N	9bee1760-d3cf-42e2-80de-a78b2be8c965	09bab356-ca7d-4f2b-a863-5ec4bcad25ca	طراحی API نسخهٔ دوم #70	\N	high	2026-06-30	8f70d979-f4d1-4a7b-b0cb-6e3b39705c13	2026-07-21 11:45:44.744086+00	2026-07-21 11:45:44.744086+00	archived	\N	79	14.70	2026-06-26	medium
582b48ec-cec0-4e4b-a7d4-cbfd51751f0f	4ae634b0-668f-465b-b3b9-c407a58a5308	\N	9bee1760-d3cf-42e2-80de-a78b2be8c965	09bab356-ca7d-4f2b-a863-5ec4bcad25ca	افزودن تست واحد برای سرویس کاربران #71	\N	low	2026-07-12	e3aedbc0-1d3b-47c7-8091-14e9dbe70ca1	2026-07-21 11:45:44.744086+00	2026-07-21 11:45:44.744086+00	archived	\N	18	2.90	2026-07-01	medium
582b48ec-cec0-4e4b-a7d4-cbfd51751f0f	4ae634b0-668f-465b-b3b9-c407a58a5308	\N	e6f6d74c-28cb-4ed3-98b6-6b15a7e57e23	09bab356-ca7d-4f2b-a863-5ec4bcad25ca	بررسی و رفع آسیب‌پذیری امنیتی #72	\N	medium	2026-08-08	de3530d2-2cda-42e4-a6e0-8c4df62f9ce5	2026-07-21 11:45:44.744086+00	2026-07-21 11:45:44.744086+00	completed	pending	100	35.70	2026-08-04	medium
582b48ec-cec0-4e4b-a7d4-cbfd51751f0f	24b11371-bc5f-4ae3-aee6-5c0dd9dac5cb	\N	2ea22145-8b4c-4e52-84fb-acb66c94b186	09bab356-ca7d-4f2b-a863-5ec4bcad25ca	بررسی و رفع آسیب‌پذیری امنیتی #73	\N	medium	2026-08-14	3505e5e5-eac8-4757-9ddf-a728f1bc5609	2026-07-21 11:45:44.744086+00	2026-07-21 11:45:44.744086+00	todo	\N	31	7.60	2026-07-31	medium
582b48ec-cec0-4e4b-a7d4-cbfd51751f0f	24b11371-bc5f-4ae3-aee6-5c0dd9dac5cb	\N	de505605-7889-4573-8969-c65f885903c4	09bab356-ca7d-4f2b-a863-5ec4bcad25ca	رفع مشکل ناسازگاری مرورگر #74	\N	medium	2026-08-17	8de41087-d659-43f3-baf9-d4557ab821ae	2026-07-21 11:45:44.744086+00	2026-07-21 11:45:44.744086+00	todo	\N	28	8.70	2026-08-12	medium
582b48ec-cec0-4e4b-a7d4-cbfd51751f0f	24b11371-bc5f-4ae3-aee6-5c0dd9dac5cb	\N	de505605-7889-4573-8969-c65f885903c4	09bab356-ca7d-4f2b-a863-5ec4bcad25ca	افزودن قابلیت جست‌وجوی پیشرفته #75	\N	low	2026-07-30	79fae991-f882-4638-a066-ff360e4e94ec	2026-07-21 11:45:44.744086+00	2026-07-21 11:45:44.744086+00	completed	approved	100	19.30	2026-07-21	medium
582b48ec-cec0-4e4b-a7d4-cbfd51751f0f	24b11371-bc5f-4ae3-aee6-5c0dd9dac5cb	\N	9bee1760-d3cf-42e2-80de-a78b2be8c965	09bab356-ca7d-4f2b-a863-5ec4bcad25ca	رفع مشکل کندی بارگذاری صفحه #76	\N	medium	2026-08-11	bd705de2-3fd1-4206-97e2-e77fcc17b8e3	2026-07-21 11:45:44.744086+00	2026-07-21 11:45:44.744086+00	completed	pending	100	25.30	2026-07-21	medium
582b48ec-cec0-4e4b-a7d4-cbfd51751f0f	24b11371-bc5f-4ae3-aee6-5c0dd9dac5cb	\N	de505605-7889-4573-8969-c65f885903c4	09bab356-ca7d-4f2b-a863-5ec4bcad25ca	بررسی و رفع آسیب‌پذیری امنیتی #77	\N	low	2026-09-01	7b4c1a5a-56b2-49fa-971c-c2f53e68ea40	2026-07-21 11:45:44.744086+00	2026-07-21 11:45:44.744086+00	completed	approved	100	30.30	2026-08-13	medium
582b48ec-cec0-4e4b-a7d4-cbfd51751f0f	24b11371-bc5f-4ae3-aee6-5c0dd9dac5cb	\N	28996900-cff9-4923-bdf4-33c0c602bda7	09bab356-ca7d-4f2b-a863-5ec4bcad25ca	رفع مشکل ناسازگاری مرورگر #78	\N	high	2026-07-11	5888b69a-2aea-440c-a82a-e770abe12d88	2026-07-21 11:45:44.744086+00	2026-07-21 11:45:44.744086+00	completed	approved	100	20.40	2026-07-01	medium
582b48ec-cec0-4e4b-a7d4-cbfd51751f0f	24b11371-bc5f-4ae3-aee6-5c0dd9dac5cb	\N	e6f6d74c-28cb-4ed3-98b6-6b15a7e57e23	09bab356-ca7d-4f2b-a863-5ec4bcad25ca	نوشتن مستندات فنی API #79	\N	medium	2026-07-18	733fa9d2-3a56-4f1d-8b54-079a72599183	2026-07-21 11:45:44.744086+00	2026-07-21 11:45:44.744086+00	in_progress	\N	30	12.30	2026-07-14	medium
582b48ec-cec0-4e4b-a7d4-cbfd51751f0f	24b11371-bc5f-4ae3-aee6-5c0dd9dac5cb	\N	0885409c-d2f4-4296-88c0-d8ac1df6a7e5	09bab356-ca7d-4f2b-a863-5ec4bcad25ca	پیاده‌سازی احراز هویت دومرحله‌ای #80	\N	high	2026-07-04	586bcc75-0f3d-4d94-b5e5-8944b98a0778	2026-07-21 11:45:44.744086+00	2026-07-21 11:45:44.744086+00	completed	approved	100	7.80	2026-06-25	medium
582b48ec-cec0-4e4b-a7d4-cbfd51751f0f	24b11371-bc5f-4ae3-aee6-5c0dd9dac5cb	\N	e6f6d74c-28cb-4ed3-98b6-6b15a7e57e23	09bab356-ca7d-4f2b-a863-5ec4bcad25ca	رفع مشکل کندی بارگذاری صفحه #81	\N	high	2026-07-27	a66c2e9f-86c3-42de-9606-977cd98b6884	2026-07-21 11:45:44.744086+00	2026-07-21 11:45:44.744086+00	todo	\N	59	17.80	2026-07-12	medium
582b48ec-cec0-4e4b-a7d4-cbfd51751f0f	24b11371-bc5f-4ae3-aee6-5c0dd9dac5cb	\N	e6f6d74c-28cb-4ed3-98b6-6b15a7e57e23	09bab356-ca7d-4f2b-a863-5ec4bcad25ca	نوشتن مستندات فنی API #82	\N	low	2026-07-30	d584c370-26e7-4c48-b0bf-03152944a1ee	2026-07-21 11:45:44.744086+00	2026-07-21 11:45:44.744086+00	in_progress	\N	73	16.50	2026-07-10	medium
582b48ec-cec0-4e4b-a7d4-cbfd51751f0f	24b11371-bc5f-4ae3-aee6-5c0dd9dac5cb	\N	09bab356-ca7d-4f2b-a863-5ec4bcad25ca	09bab356-ca7d-4f2b-a863-5ec4bcad25ca	بازنویسی ماژول اعلان‌ها #83	\N	medium	2026-07-19	1736bb3a-5e8a-4960-9d70-55ec4f4a7470	2026-07-21 11:45:44.744086+00	2026-07-21 11:45:44.744086+00	in_progress	\N	68	30.40	2026-07-05	medium
582b48ec-cec0-4e4b-a7d4-cbfd51751f0f	24b11371-bc5f-4ae3-aee6-5c0dd9dac5cb	\N	2ea22145-8b4c-4e52-84fb-acb66c94b186	09bab356-ca7d-4f2b-a863-5ec4bcad25ca	طراحی API نسخهٔ دوم #84	\N	medium	2026-07-26	f9bb2ca6-f4b7-4973-92c6-496253562fc8	2026-07-21 11:45:44.744086+00	2026-07-21 11:45:44.744086+00	completed	pending	100	20.50	2026-07-17	medium
582b48ec-cec0-4e4b-a7d4-cbfd51751f0f	24b11371-bc5f-4ae3-aee6-5c0dd9dac5cb	\N	28996900-cff9-4923-bdf4-33c0c602bda7	09bab356-ca7d-4f2b-a863-5ec4bcad25ca	نوشتن مستندات فنی API #85	\N	low	2026-08-11	8e6ab736-f37c-46a6-b434-3cc33a3b825d	2026-07-21 11:45:44.744086+00	2026-07-21 11:45:44.744086+00	in_progress	\N	59	36.90	2026-07-28	medium
582b48ec-cec0-4e4b-a7d4-cbfd51751f0f	24b11371-bc5f-4ae3-aee6-5c0dd9dac5cb	\N	2ea22145-8b4c-4e52-84fb-acb66c94b186	09bab356-ca7d-4f2b-a863-5ec4bcad25ca	پیاده‌سازی صفحهٔ داشبورد مدیریتی #86	\N	high	2026-07-31	dc376b85-1ee7-4d9e-8410-34a02787b84b	2026-07-21 11:45:44.744086+00	2026-07-21 11:45:44.744086+00	completed	approved	100	3.00	2026-07-11	medium
582b48ec-cec0-4e4b-a7d4-cbfd51751f0f	24b11371-bc5f-4ae3-aee6-5c0dd9dac5cb	\N	de505605-7889-4573-8969-c65f885903c4	09bab356-ca7d-4f2b-a863-5ec4bcad25ca	بهینه‌سازی کوئری‌های گزارش‌گیری #87	\N	low	2026-07-10	e5e5b7f7-7859-4bae-af3d-8e9434d3a244	2026-07-21 11:45:44.744086+00	2026-07-21 11:45:44.744086+00	in_progress	\N	33	16.40	2026-06-24	medium
582b48ec-cec0-4e4b-a7d4-cbfd51751f0f	24b11371-bc5f-4ae3-aee6-5c0dd9dac5cb	\N	e6f6d74c-28cb-4ed3-98b6-6b15a7e57e23	09bab356-ca7d-4f2b-a863-5ec4bcad25ca	طراحی API نسخهٔ دوم #88	\N	medium	2026-08-17	e45e2321-d97f-4868-b177-9f403858c163	2026-07-21 11:45:44.744086+00	2026-07-21 11:45:44.744086+00	completed	approved	100	11.60	2026-08-03	medium
582b48ec-cec0-4e4b-a7d4-cbfd51751f0f	24b11371-bc5f-4ae3-aee6-5c0dd9dac5cb	\N	09bab356-ca7d-4f2b-a863-5ec4bcad25ca	09bab356-ca7d-4f2b-a863-5ec4bcad25ca	رفع مشکل کندی بارگذاری صفحه #89	\N	low	2026-07-23	9a775f7a-61d1-4619-99d5-24aaecce3f94	2026-07-21 11:45:44.744086+00	2026-07-21 11:45:44.744086+00	completed	approved	100	26.70	2026-07-20	medium
582b48ec-cec0-4e4b-a7d4-cbfd51751f0f	24b11371-bc5f-4ae3-aee6-5c0dd9dac5cb	\N	9bee1760-d3cf-42e2-80de-a78b2be8c965	09bab356-ca7d-4f2b-a863-5ec4bcad25ca	افزودن تست واحد برای سرویس کاربران #90	\N	low	2026-06-26	be79ffe1-9356-49a1-8573-2744cae71335	2026-07-21 11:45:44.744086+00	2026-07-21 11:45:44.744086+00	completed	approved	100	25.60	2026-06-17	medium
582b48ec-cec0-4e4b-a7d4-cbfd51751f0f	\N	\N	e6f6d74c-28cb-4ed3-98b6-6b15a7e57e23	e6f6d74c-28cb-4ed3-98b6-6b15a7e57e23	پیاده‌سازی صفحهٔ داشبورد مدیریتی #91	\N	low	2026-07-21	e619ab5b-b4ee-4bdd-bc4f-7a026d58a719	2026-07-21 11:45:44.744086+00	2026-07-21 11:45:44.744086+00	todo	\N	59	28.60	2026-07-16	medium
582b48ec-cec0-4e4b-a7d4-cbfd51751f0f	\N	\N	9bee1760-d3cf-42e2-80de-a78b2be8c965	9bee1760-d3cf-42e2-80de-a78b2be8c965	پیاده‌سازی صفحهٔ داشبورد مدیریتی #92	\N	high	2026-07-17	6cb4915d-1176-479f-aa27-b6ef2fe11d29	2026-07-21 11:45:44.744086+00	2026-07-21 11:45:44.744086+00	in_progress	\N	14	31.60	2026-06-26	medium
582b48ec-cec0-4e4b-a7d4-cbfd51751f0f	\N	\N	e6f6d74c-28cb-4ed3-98b6-6b15a7e57e23	e6f6d74c-28cb-4ed3-98b6-6b15a7e57e23	رفع باگ در ماژول پرداخت #93	\N	medium	2026-07-12	79d9ae81-2bd1-4c83-b197-7e7f8412fa58	2026-07-21 11:45:44.744086+00	2026-07-21 11:45:44.744086+00	in_progress	\N	73	27.70	2026-06-22	medium
582b48ec-cec0-4e4b-a7d4-cbfd51751f0f	\N	\N	28996900-cff9-4923-bdf4-33c0c602bda7	28996900-cff9-4923-bdf4-33c0c602bda7	پیاده‌سازی صفحهٔ ورود جدید #94	\N	high	2026-08-23	9c670ed9-0342-4761-ac04-49c21e6478f5	2026-07-21 11:45:44.744086+00	2026-07-21 11:45:44.744086+00	in_progress	\N	80	11.20	2026-08-15	medium
582b48ec-cec0-4e4b-a7d4-cbfd51751f0f	\N	\N	de505605-7889-4573-8969-c65f885903c4	de505605-7889-4573-8969-c65f885903c4	رفع مشکل ناسازگاری مرورگر #95	\N	low	2026-07-26	c62d4bdb-8d76-427b-8a50-c7b2bccaac60	2026-07-21 11:45:44.744086+00	2026-07-21 11:45:44.744086+00	archived	\N	72	31.70	2026-07-05	medium
582b48ec-cec0-4e4b-a7d4-cbfd51751f0f	\N	\N	0885409c-d2f4-4296-88c0-d8ac1df6a7e5	0885409c-d2f4-4296-88c0-d8ac1df6a7e5	به‌روزرسانی کتابخانه‌های وابسته #96	\N	high	2026-07-13	8d479ebe-45dc-491f-98a1-cb9da25fc66f	2026-07-21 11:45:44.744086+00	2026-07-21 11:45:44.744086+00	completed	approved	100	15.00	2026-07-09	medium
582b48ec-cec0-4e4b-a7d4-cbfd51751f0f	\N	\N	9bee1760-d3cf-42e2-80de-a78b2be8c965	9bee1760-d3cf-42e2-80de-a78b2be8c965	پیاده‌سازی صفحهٔ ورود جدید #97	\N	medium	2026-08-24	9830afb0-f520-45ad-af71-36ae4c9fbb77	2026-07-21 11:45:44.744086+00	2026-07-21 11:45:44.744086+00	in_progress	\N	46	26.20	2026-08-07	medium
582b48ec-cec0-4e4b-a7d4-cbfd51751f0f	\N	\N	9bee1760-d3cf-42e2-80de-a78b2be8c965	9bee1760-d3cf-42e2-80de-a78b2be8c965	نوشتن مستندات فنی API #98	\N	high	2026-07-20	2c282114-40cf-4f87-9b84-a12693ac37ed	2026-07-21 11:45:44.744086+00	2026-07-21 11:45:44.744086+00	completed	pending	100	38.70	2026-07-13	medium
582b48ec-cec0-4e4b-a7d4-cbfd51751f0f	\N	\N	0885409c-d2f4-4296-88c0-d8ac1df6a7e5	0885409c-d2f4-4296-88c0-d8ac1df6a7e5	بررسی و رفع آسیب‌پذیری امنیتی #99	\N	medium	2026-08-06	429f18d8-af01-4734-b60d-1405d697d3d2	2026-07-21 11:45:44.744086+00	2026-07-21 11:45:44.744086+00	completed	pending	100	33.40	2026-07-20	medium
582b48ec-cec0-4e4b-a7d4-cbfd51751f0f	\N	\N	2ea22145-8b4c-4e52-84fb-acb66c94b186	2ea22145-8b4c-4e52-84fb-acb66c94b186	بازنویسی ماژول اعلان‌ها #100	\N	low	2026-07-15	412e4e1e-f80d-4d20-a70b-5cd8abc9257c	2026-07-21 11:45:44.744086+00	2026-07-21 11:45:44.744086+00	in_progress	\N	35	35.50	2026-07-06	medium
582b48ec-cec0-4e4b-a7d4-cbfd51751f0f	\N	\N	e6f6d74c-28cb-4ed3-98b6-6b15a7e57e23	e6f6d74c-28cb-4ed3-98b6-6b15a7e57e23	پیاده‌سازی صفحهٔ داشبورد مدیریتی #101	\N	high	2026-08-04	45d4dffc-f44e-473d-9904-90c616c624ad	2026-07-21 11:45:44.744086+00	2026-07-21 11:45:44.744086+00	archived	\N	48	14.80	2026-07-15	medium
582b48ec-cec0-4e4b-a7d4-cbfd51751f0f	\N	\N	28996900-cff9-4923-bdf4-33c0c602bda7	28996900-cff9-4923-bdf4-33c0c602bda7	افزودن تست واحد برای سرویس کاربران #102	\N	medium	2026-07-14	9b67833f-b0b0-40ea-8fb1-200db862900a	2026-07-21 11:45:44.744086+00	2026-07-21 11:45:44.744086+00	in_progress	\N	33	14.90	2026-06-27	medium
582b48ec-cec0-4e4b-a7d4-cbfd51751f0f	\N	\N	2ea22145-8b4c-4e52-84fb-acb66c94b186	2ea22145-8b4c-4e52-84fb-acb66c94b186	به‌روزرسانی کتابخانه‌های وابسته #103	\N	low	2026-07-23	22eb1d73-0f2f-4f61-80f2-33968e93881c	2026-07-21 11:45:44.744086+00	2026-07-21 11:45:44.744086+00	completed	pending	100	5.30	2026-07-21	medium
582b48ec-cec0-4e4b-a7d4-cbfd51751f0f	\N	\N	de505605-7889-4573-8969-c65f885903c4	de505605-7889-4573-8969-c65f885903c4	رفع مشکل ناسازگاری مرورگر #104	\N	low	2026-08-05	75434502-454b-418a-8ee7-9a1619b79632	2026-07-21 11:45:44.744086+00	2026-07-21 11:45:44.744086+00	in_progress	\N	60	26.50	2026-07-17	medium
582b48ec-cec0-4e4b-a7d4-cbfd51751f0f	\N	\N	28996900-cff9-4923-bdf4-33c0c602bda7	28996900-cff9-4923-bdf4-33c0c602bda7	افزودن تست واحد برای سرویس کاربران #105	\N	medium	2026-07-02	74c47866-22a5-4b9b-8666-fcd83ec3f07f	2026-07-21 11:45:44.744086+00	2026-07-21 11:45:44.744086+00	completed	pending	100	28.30	2026-06-21	medium
582b48ec-cec0-4e4b-a7d4-cbfd51751f0f	5bcf571d-8fc5-4f23-86c2-bda550998000	\N	c057add9-a37a-4d8b-adb3-be28effacb81	98fba7cd-606b-4e45-957c-f63d3a809e84	پیگیری مطالبات معوق مشتریان #1	\N	medium	2026-07-16	7b882b49-ba77-46a5-9e86-a5714bd9040e	2026-07-21 11:45:44.744086+00	2026-07-21 11:45:44.744086+00	completed	rejected	100	5.90	2026-06-27	medium
582b48ec-cec0-4e4b-a7d4-cbfd51751f0f	5bcf571d-8fc5-4f23-86c2-bda550998000	\N	e84eaed7-50c6-4212-9f29-cad60bbee457	98fba7cd-606b-4e45-957c-f63d3a809e84	تهیهٔ گزارش جریان نقدی #2	\N	medium	2026-08-04	6c39f7b2-ac26-47ef-90bf-2cc61797846a	2026-07-21 11:45:44.744086+00	2026-07-21 11:45:44.744086+00	completed	approved	100	8.30	2026-07-14	medium
582b48ec-cec0-4e4b-a7d4-cbfd51751f0f	5bcf571d-8fc5-4f23-86c2-bda550998000	\N	c057add9-a37a-4d8b-adb3-be28effacb81	98fba7cd-606b-4e45-957c-f63d3a809e84	تهیهٔ گزارش جریان نقدی #3	\N	medium	2026-07-17	45010937-cc56-4b8a-b8a8-813aa9f5a672	2026-07-21 11:45:44.744086+00	2026-07-21 11:45:44.744086+00	in_progress	\N	78	39.90	2026-07-14	medium
582b48ec-cec0-4e4b-a7d4-cbfd51751f0f	5bcf571d-8fc5-4f23-86c2-bda550998000	\N	e84eaed7-50c6-4212-9f29-cad60bbee457	98fba7cd-606b-4e45-957c-f63d3a809e84	تهیهٔ گزارش سود و زیان ماهانه #4	\N	high	2026-08-18	c8deb7f5-e162-4b2f-b722-886f03f232f8	2026-07-21 11:45:44.744086+00	2026-07-21 11:45:44.744086+00	completed	rejected	100	26.20	2026-08-15	medium
582b48ec-cec0-4e4b-a7d4-cbfd51751f0f	5bcf571d-8fc5-4f23-86c2-bda550998000	\N	e84eaed7-50c6-4212-9f29-cad60bbee457	98fba7cd-606b-4e45-957c-f63d3a809e84	بررسی و تأیید صورت‌حساب‌های خرید #5	\N	low	2026-08-05	c350f564-ce92-47cc-80ed-632299e350af	2026-07-21 11:45:44.744086+00	2026-07-21 11:45:44.744086+00	completed	pending	100	34.20	2026-07-29	medium
582b48ec-cec0-4e4b-a7d4-cbfd51751f0f	5bcf571d-8fc5-4f23-86c2-bda550998000	\N	2e6fa9ea-43da-47ab-a8a8-e2e58360f575	98fba7cd-606b-4e45-957c-f63d3a809e84	بررسی و تسویهٔ کارت اعتباری شرکت #6	\N	high	2026-06-29	bccb8cf3-2079-4a84-bbb2-3abc24d2d645	2026-07-21 11:45:44.744086+00	2026-07-21 11:45:44.744086+00	completed	approved	100	15.90	2026-06-20	medium
582b48ec-cec0-4e4b-a7d4-cbfd51751f0f	5bcf571d-8fc5-4f23-86c2-bda550998000	\N	c057add9-a37a-4d8b-adb3-be28effacb81	98fba7cd-606b-4e45-957c-f63d3a809e84	تهیهٔ گزارش مالیاتی فصلی #7	\N	medium	2026-07-11	94f807cd-41a1-4142-8be8-e4a93b353292	2026-07-21 11:45:44.744086+00	2026-07-21 11:45:44.744086+00	completed	approved	100	18.90	2026-06-25	medium
582b48ec-cec0-4e4b-a7d4-cbfd51751f0f	5bcf571d-8fc5-4f23-86c2-bda550998000	\N	98fba7cd-606b-4e45-957c-f63d3a809e84	98fba7cd-606b-4e45-957c-f63d3a809e84	تهیهٔ گزارش مالیاتی فصلی #8	\N	high	2026-07-23	3942bcea-060f-48d8-b6e5-77bbe167cf9e	2026-07-21 11:45:44.744086+00	2026-07-21 11:45:44.744086+00	completed	approved	100	12.60	2026-07-09	medium
582b48ec-cec0-4e4b-a7d4-cbfd51751f0f	5bcf571d-8fc5-4f23-86c2-bda550998000	\N	98fba7cd-606b-4e45-957c-f63d3a809e84	98fba7cd-606b-4e45-957c-f63d3a809e84	به‌روزرسانی جدول حقوق و دستمزد #9	\N	high	2026-08-09	5cb69b6b-88ef-472b-9b94-b4340dc7de9e	2026-07-21 11:45:44.744086+00	2026-07-21 11:45:44.744086+00	todo	\N	49	36.70	2026-08-02	medium
582b48ec-cec0-4e4b-a7d4-cbfd51751f0f	5bcf571d-8fc5-4f23-86c2-bda550998000	\N	98fba7cd-606b-4e45-957c-f63d3a809e84	98fba7cd-606b-4e45-957c-f63d3a809e84	تهیهٔ گزارش جریان نقدی #10	\N	medium	2026-08-14	8056b766-45c1-4659-9191-e8d5ee24b7d9	2026-07-21 11:45:44.744086+00	2026-07-21 11:45:44.744086+00	in_progress	\N	27	39.90	2026-08-04	medium
582b48ec-cec0-4e4b-a7d4-cbfd51751f0f	5bcf571d-8fc5-4f23-86c2-bda550998000	\N	e84eaed7-50c6-4212-9f29-cad60bbee457	98fba7cd-606b-4e45-957c-f63d3a809e84	تهیهٔ گزارش سود و زیان ماهانه #11	\N	low	2026-07-25	54014097-0aff-4ae2-9553-4e076b21b100	2026-07-21 11:45:44.744086+00	2026-07-21 11:45:44.744086+00	completed	rejected	100	34.40	2026-07-17	medium
582b48ec-cec0-4e4b-a7d4-cbfd51751f0f	5bcf571d-8fc5-4f23-86c2-bda550998000	\N	c057add9-a37a-4d8b-adb3-be28effacb81	98fba7cd-606b-4e45-957c-f63d3a809e84	تهیهٔ گزارش سود و زیان ماهانه #12	\N	high	2026-08-28	f60b2286-d72f-434e-b606-e1593ab804b2	2026-07-21 11:45:44.744086+00	2026-07-21 11:45:44.744086+00	todo	\N	40	27.40	2026-08-12	medium
582b48ec-cec0-4e4b-a7d4-cbfd51751f0f	5bcf571d-8fc5-4f23-86c2-bda550998000	\N	2e6fa9ea-43da-47ab-a8a8-e2e58360f575	98fba7cd-606b-4e45-957c-f63d3a809e84	پیگیری مطالبات معوق مشتریان #13	\N	medium	2026-08-09	5288ec51-4b31-4018-b6c0-efc131c30956	2026-07-21 11:45:44.744086+00	2026-07-21 11:45:44.744086+00	todo	\N	20	29.00	2026-07-21	medium
582b48ec-cec0-4e4b-a7d4-cbfd51751f0f	5bcf571d-8fc5-4f23-86c2-bda550998000	\N	2e6fa9ea-43da-47ab-a8a8-e2e58360f575	98fba7cd-606b-4e45-957c-f63d3a809e84	ثبت اسناد حسابداری هفتگی #14	\N	low	2026-07-27	78a1bc08-c6f0-462d-8cd4-8066b3290bd0	2026-07-21 11:45:44.744086+00	2026-07-21 11:45:44.744086+00	completed	approved	100	39.40	2026-07-09	medium
582b48ec-cec0-4e4b-a7d4-cbfd51751f0f	5bcf571d-8fc5-4f23-86c2-bda550998000	\N	85751a1a-b02d-4121-aff6-407cd2f6ebd7	98fba7cd-606b-4e45-957c-f63d3a809e84	بررسی و تأیید صورت‌حساب‌های خرید #15	\N	medium	2026-07-18	2b8ff214-a046-4ad0-ac10-91d1293649f2	2026-07-21 11:45:44.744086+00	2026-07-21 11:45:44.744086+00	todo	\N	70	23.70	2026-07-01	medium
582b48ec-cec0-4e4b-a7d4-cbfd51751f0f	5bcf571d-8fc5-4f23-86c2-bda550998000	\N	c057add9-a37a-4d8b-adb3-be28effacb81	98fba7cd-606b-4e45-957c-f63d3a809e84	تهیهٔ گزارش سود و زیان ماهانه #16	\N	medium	2026-08-15	2932ff48-2462-4b60-95a5-f4974596a72d	2026-07-21 11:45:44.744086+00	2026-07-21 11:45:44.744086+00	completed	approved	100	17.10	2026-08-11	medium
582b48ec-cec0-4e4b-a7d4-cbfd51751f0f	5bcf571d-8fc5-4f23-86c2-bda550998000	\N	2e6fa9ea-43da-47ab-a8a8-e2e58360f575	98fba7cd-606b-4e45-957c-f63d3a809e84	بررسی فاکتورهای فروش صادرشده #17	\N	medium	2026-08-03	a6dd7fc0-a2dc-4c7b-b6f6-f49f2840fcc8	2026-07-21 11:45:44.744086+00	2026-07-21 11:45:44.744086+00	archived	\N	73	4.80	2026-07-16	medium
582b48ec-cec0-4e4b-a7d4-cbfd51751f0f	5bcf571d-8fc5-4f23-86c2-bda550998000	\N	e84eaed7-50c6-4212-9f29-cad60bbee457	98fba7cd-606b-4e45-957c-f63d3a809e84	تهیهٔ گزارش مالیاتی فصلی #18	\N	low	2026-08-02	4a1eb704-6aa7-4880-94dc-970545f4d415	2026-07-21 11:45:44.744086+00	2026-07-21 11:45:44.744086+00	completed	approved	100	35.40	2026-07-15	medium
582b48ec-cec0-4e4b-a7d4-cbfd51751f0f	03032cdb-7a72-4f37-9d58-8b79b5b86638	\N	85751a1a-b02d-4121-aff6-407cd2f6ebd7	98fba7cd-606b-4e45-957c-f63d3a809e84	بررسی فاکتورهای فروش صادرشده #19	\N	high	2026-07-03	22f99812-3d8e-4842-9cd6-eb44b4895f7e	2026-07-21 11:45:44.744086+00	2026-07-21 11:45:44.744086+00	completed	pending	100	36.60	2026-06-27	medium
582b48ec-cec0-4e4b-a7d4-cbfd51751f0f	03032cdb-7a72-4f37-9d58-8b79b5b86638	\N	98fba7cd-606b-4e45-957c-f63d3a809e84	98fba7cd-606b-4e45-957c-f63d3a809e84	پیگیری مطالبات معوق مشتریان #20	\N	low	2026-07-25	8a3ad806-edd9-4e8d-b757-be97122fd965	2026-07-21 11:45:44.744086+00	2026-07-21 11:45:44.744086+00	todo	\N	20	14.30	2026-07-19	medium
582b48ec-cec0-4e4b-a7d4-cbfd51751f0f	03032cdb-7a72-4f37-9d58-8b79b5b86638	\N	2e6fa9ea-43da-47ab-a8a8-e2e58360f575	98fba7cd-606b-4e45-957c-f63d3a809e84	بررسی قراردادهای مالی جدید #21	\N	medium	2026-07-26	c010b04a-34e6-4a80-9aa6-2e4294afea9e	2026-07-21 11:45:44.744086+00	2026-07-21 11:45:44.744086+00	in_progress	\N	10	11.50	2026-07-08	medium
582b48ec-cec0-4e4b-a7d4-cbfd51751f0f	03032cdb-7a72-4f37-9d58-8b79b5b86638	\N	2e6fa9ea-43da-47ab-a8a8-e2e58360f575	98fba7cd-606b-4e45-957c-f63d3a809e84	بررسی صورت وضعیت پیمانکاران #22	\N	high	2026-08-06	7dde5f75-0842-4802-b3fb-07983e99ffb9	2026-07-21 11:45:44.744086+00	2026-07-21 11:45:44.744086+00	completed	approved	100	5.60	2026-07-26	medium
582b48ec-cec0-4e4b-a7d4-cbfd51751f0f	03032cdb-7a72-4f37-9d58-8b79b5b86638	\N	2e6fa9ea-43da-47ab-a8a8-e2e58360f575	98fba7cd-606b-4e45-957c-f63d3a809e84	مغایرت‌گیری حساب‌های بانکی #23	\N	low	2026-08-12	98561a6f-9385-42d5-8127-a5f3db42a3c7	2026-07-21 11:45:44.744086+00	2026-07-21 11:45:44.744086+00	todo	\N	79	29.40	2026-07-23	medium
582b48ec-cec0-4e4b-a7d4-cbfd51751f0f	03032cdb-7a72-4f37-9d58-8b79b5b86638	\N	60845684-b03a-492a-9937-f8529e7ba409	98fba7cd-606b-4e45-957c-f63d3a809e84	بررسی و تأیید صورت‌حساب‌های خرید #24	\N	low	2026-08-28	b6fb3afc-ffef-4be9-a0ea-ccaad12627ee	2026-07-21 11:45:44.744086+00	2026-07-21 11:45:44.744086+00	in_progress	\N	10	3.70	2026-08-08	medium
582b48ec-cec0-4e4b-a7d4-cbfd51751f0f	03032cdb-7a72-4f37-9d58-8b79b5b86638	\N	2e6fa9ea-43da-47ab-a8a8-e2e58360f575	98fba7cd-606b-4e45-957c-f63d3a809e84	تطبیق موجودی انبار با حساب‌ها #25	\N	low	2026-08-01	ce8458ee-aa52-4282-b0d7-73b7c00c80da	2026-07-21 11:45:44.744086+00	2026-07-21 11:45:44.744086+00	archived	\N	73	17.80	2026-07-22	medium
582b48ec-cec0-4e4b-a7d4-cbfd51751f0f	03032cdb-7a72-4f37-9d58-8b79b5b86638	\N	2e6fa9ea-43da-47ab-a8a8-e2e58360f575	98fba7cd-606b-4e45-957c-f63d3a809e84	پیگیری مطالبات معوق مشتریان #26	\N	high	2026-08-05	e55a0665-e738-4fff-a6bf-edf409137c53	2026-07-21 11:45:44.744086+00	2026-07-21 11:45:44.744086+00	todo	\N	38	20.40	2026-07-17	medium
582b48ec-cec0-4e4b-a7d4-cbfd51751f0f	03032cdb-7a72-4f37-9d58-8b79b5b86638	\N	85751a1a-b02d-4121-aff6-407cd2f6ebd7	98fba7cd-606b-4e45-957c-f63d3a809e84	تهیهٔ گزارش جریان نقدی #27	\N	low	2026-07-19	23a57a1d-05a8-4e9a-a494-b1ed0a7a45cd	2026-07-21 11:45:44.744086+00	2026-07-21 11:45:44.744086+00	completed	approved	100	8.00	2026-07-15	medium
582b48ec-cec0-4e4b-a7d4-cbfd51751f0f	03032cdb-7a72-4f37-9d58-8b79b5b86638	\N	c057add9-a37a-4d8b-adb3-be28effacb81	98fba7cd-606b-4e45-957c-f63d3a809e84	مغایرت‌گیری حساب‌های بانکی #28	\N	medium	2026-07-28	efd42a51-af7b-420a-a2e3-e14737ec0442	2026-07-21 11:45:44.744086+00	2026-07-21 11:45:44.744086+00	completed	approved	100	34.70	2026-07-07	medium
582b48ec-cec0-4e4b-a7d4-cbfd51751f0f	03032cdb-7a72-4f37-9d58-8b79b5b86638	\N	e84eaed7-50c6-4212-9f29-cad60bbee457	98fba7cd-606b-4e45-957c-f63d3a809e84	بررسی فاکتورهای فروش صادرشده #29	\N	low	2026-08-23	7cb086d1-e0a4-41e0-8706-9b7890272faa	2026-07-21 11:45:44.744086+00	2026-07-21 11:45:44.744086+00	archived	\N	47	21.60	2026-08-10	medium
582b48ec-cec0-4e4b-a7d4-cbfd51751f0f	03032cdb-7a72-4f37-9d58-8b79b5b86638	\N	98fba7cd-606b-4e45-957c-f63d3a809e84	98fba7cd-606b-4e45-957c-f63d3a809e84	تهیهٔ گزارش سود و زیان ماهانه #30	\N	medium	2026-07-17	1ec2aefb-b0b3-45ba-bbfd-62ffad9cafe6	2026-07-21 11:45:44.744086+00	2026-07-21 11:45:44.744086+00	in_progress	\N	57	11.40	2026-07-01	medium
582b48ec-cec0-4e4b-a7d4-cbfd51751f0f	03032cdb-7a72-4f37-9d58-8b79b5b86638	\N	98fba7cd-606b-4e45-957c-f63d3a809e84	98fba7cd-606b-4e45-957c-f63d3a809e84	پیگیری بیمهٔ کارکنان #31	\N	high	2026-07-18	63aaee16-bc91-4a93-8a53-23b5e9debf58	2026-07-21 11:45:44.744086+00	2026-07-21 11:45:44.744086+00	todo	\N	53	11.40	2026-07-04	medium
582b48ec-cec0-4e4b-a7d4-cbfd51751f0f	03032cdb-7a72-4f37-9d58-8b79b5b86638	\N	85751a1a-b02d-4121-aff6-407cd2f6ebd7	98fba7cd-606b-4e45-957c-f63d3a809e84	بررسی قراردادهای مالی جدید #32	\N	high	2026-08-19	acc33941-292d-4025-8b2f-cd529786f692	2026-07-21 11:45:44.744086+00	2026-07-21 11:45:44.744086+00	todo	\N	40	9.20	2026-08-07	medium
582b48ec-cec0-4e4b-a7d4-cbfd51751f0f	03032cdb-7a72-4f37-9d58-8b79b5b86638	\N	76c11995-60dc-42d9-9a92-6dc9daa80ce9	98fba7cd-606b-4e45-957c-f63d3a809e84	بررسی قراردادهای مالی جدید #33	\N	medium	2026-08-01	13f3b26b-1879-471c-bfff-aade440357c6	2026-07-21 11:45:44.744086+00	2026-07-21 11:45:44.744086+00	completed	rejected	100	20.90	2026-07-15	medium
582b48ec-cec0-4e4b-a7d4-cbfd51751f0f	03032cdb-7a72-4f37-9d58-8b79b5b86638	\N	98fba7cd-606b-4e45-957c-f63d3a809e84	98fba7cd-606b-4e45-957c-f63d3a809e84	ثبت اسناد حسابداری هفتگی #34	\N	low	2026-08-03	e7208c77-0fae-488a-9f30-ca645861eb0f	2026-07-21 11:45:44.744086+00	2026-07-21 11:45:44.744086+00	in_progress	\N	74	15.40	2026-07-18	medium
582b48ec-cec0-4e4b-a7d4-cbfd51751f0f	03032cdb-7a72-4f37-9d58-8b79b5b86638	\N	98fba7cd-606b-4e45-957c-f63d3a809e84	98fba7cd-606b-4e45-957c-f63d3a809e84	بررسی قراردادهای مالی جدید #35	\N	high	2026-08-07	a00ec283-789f-4af3-8e68-d6ae50c0f36d	2026-07-21 11:45:44.744086+00	2026-07-21 11:45:44.744086+00	in_progress	\N	60	12.90	2026-07-17	medium
582b48ec-cec0-4e4b-a7d4-cbfd51751f0f	03032cdb-7a72-4f37-9d58-8b79b5b86638	\N	98fba7cd-606b-4e45-957c-f63d3a809e84	98fba7cd-606b-4e45-957c-f63d3a809e84	بررسی قراردادهای مالی جدید #36	\N	medium	2026-07-19	93078153-bb32-4c50-9d38-8f4d24946ae5	2026-07-21 11:45:44.744086+00	2026-07-21 11:45:44.744086+00	todo	\N	46	31.00	2026-07-13	medium
582b48ec-cec0-4e4b-a7d4-cbfd51751f0f	30cf629e-4a36-40a9-9107-ae3dc5cf6578	\N	e84eaed7-50c6-4212-9f29-cad60bbee457	98fba7cd-606b-4e45-957c-f63d3a809e84	بررسی صورت وضعیت پیمانکاران #37	\N	high	2026-07-14	bde70fd7-6406-4a1f-9428-cd8d35c68c06	2026-07-21 11:45:44.744086+00	2026-07-21 11:45:44.744086+00	todo	\N	24	15.80	2026-07-11	medium
582b48ec-cec0-4e4b-a7d4-cbfd51751f0f	30cf629e-4a36-40a9-9107-ae3dc5cf6578	\N	e84eaed7-50c6-4212-9f29-cad60bbee457	98fba7cd-606b-4e45-957c-f63d3a809e84	به‌روزرسانی جدول حقوق و دستمزد #38	\N	high	2026-07-28	5b477218-7e02-4e46-bb06-72cf3a9233cf	2026-07-21 11:45:44.744086+00	2026-07-21 11:45:44.744086+00	todo	\N	35	33.40	2026-07-10	medium
582b48ec-cec0-4e4b-a7d4-cbfd51751f0f	30cf629e-4a36-40a9-9107-ae3dc5cf6578	\N	60845684-b03a-492a-9937-f8529e7ba409	98fba7cd-606b-4e45-957c-f63d3a809e84	بررسی فاکتورهای فروش صادرشده #39	\N	medium	2026-06-29	4454a24a-64ec-4af3-923d-82eaf0a443c9	2026-07-21 11:45:44.744086+00	2026-07-21 11:45:44.744086+00	completed	pending	100	32.20	2026-06-24	medium
582b48ec-cec0-4e4b-a7d4-cbfd51751f0f	30cf629e-4a36-40a9-9107-ae3dc5cf6578	\N	e84eaed7-50c6-4212-9f29-cad60bbee457	98fba7cd-606b-4e45-957c-f63d3a809e84	ثبت اسناد حسابداری هفتگی #40	\N	high	2026-08-09	460c6c7a-e99c-4d64-8741-4bbc11dd5944	2026-07-21 11:45:44.744086+00	2026-07-21 11:45:44.744086+00	completed	rejected	100	21.30	2026-08-03	medium
582b48ec-cec0-4e4b-a7d4-cbfd51751f0f	30cf629e-4a36-40a9-9107-ae3dc5cf6578	\N	60845684-b03a-492a-9937-f8529e7ba409	98fba7cd-606b-4e45-957c-f63d3a809e84	مغایرت‌گیری حساب‌های بانکی #41	\N	high	2026-06-21	39d1ddd5-bf61-4610-87ad-075fcced6540	2026-07-21 11:45:44.744086+00	2026-07-21 11:45:44.744086+00	todo	\N	42	32.60	2026-06-18	medium
582b48ec-cec0-4e4b-a7d4-cbfd51751f0f	30cf629e-4a36-40a9-9107-ae3dc5cf6578	\N	60845684-b03a-492a-9937-f8529e7ba409	98fba7cd-606b-4e45-957c-f63d3a809e84	مغایرت‌گیری حساب‌های بانکی #42	\N	medium	2026-08-30	1841ee83-56ec-4134-9428-0e8628059a10	2026-07-21 11:45:44.744086+00	2026-07-21 11:45:44.744086+00	completed	approved	100	37.40	2026-08-12	medium
582b48ec-cec0-4e4b-a7d4-cbfd51751f0f	30cf629e-4a36-40a9-9107-ae3dc5cf6578	\N	e84eaed7-50c6-4212-9f29-cad60bbee457	98fba7cd-606b-4e45-957c-f63d3a809e84	تهیهٔ گزارش جریان نقدی #43	\N	medium	2026-08-01	22b502b6-7bdd-4760-b470-1097ffafb279	2026-07-21 11:45:44.744086+00	2026-07-21 11:45:44.744086+00	todo	\N	75	14.80	2026-07-11	medium
582b48ec-cec0-4e4b-a7d4-cbfd51751f0f	30cf629e-4a36-40a9-9107-ae3dc5cf6578	\N	85751a1a-b02d-4121-aff6-407cd2f6ebd7	98fba7cd-606b-4e45-957c-f63d3a809e84	پیگیری مطالبات معوق مشتریان #44	\N	medium	2026-08-20	beafa52d-0513-4d6a-b9ca-eb5b650e92a2	2026-07-21 11:45:44.744086+00	2026-07-21 11:45:44.744086+00	completed	approved	100	33.00	2026-07-31	medium
582b48ec-cec0-4e4b-a7d4-cbfd51751f0f	30cf629e-4a36-40a9-9107-ae3dc5cf6578	\N	e84eaed7-50c6-4212-9f29-cad60bbee457	98fba7cd-606b-4e45-957c-f63d3a809e84	بررسی فاکتورهای فروش صادرشده #45	\N	high	2026-08-03	c829b7a8-ed11-401b-8359-3b27c5ccc22b	2026-07-21 11:45:44.744086+00	2026-07-21 11:45:44.744086+00	in_progress	\N	39	32.30	2026-07-29	medium
582b48ec-cec0-4e4b-a7d4-cbfd51751f0f	30cf629e-4a36-40a9-9107-ae3dc5cf6578	\N	2e6fa9ea-43da-47ab-a8a8-e2e58360f575	98fba7cd-606b-4e45-957c-f63d3a809e84	پیگیری مطالبات معوق مشتریان #46	\N	high	2026-08-10	4e306c1c-aac7-470f-a859-1e1296846a28	2026-07-21 11:45:44.744086+00	2026-07-21 11:45:44.744086+00	completed	pending	100	31.80	2026-07-24	medium
582b48ec-cec0-4e4b-a7d4-cbfd51751f0f	30cf629e-4a36-40a9-9107-ae3dc5cf6578	\N	85751a1a-b02d-4121-aff6-407cd2f6ebd7	98fba7cd-606b-4e45-957c-f63d3a809e84	بررسی صورت وضعیت پیمانکاران #47	\N	medium	2026-08-04	129c6ffb-324f-4445-a611-6ff9e0dfdc9c	2026-07-21 11:45:44.744086+00	2026-07-21 11:45:44.744086+00	completed	approved	100	8.50	2026-08-01	medium
582b48ec-cec0-4e4b-a7d4-cbfd51751f0f	30cf629e-4a36-40a9-9107-ae3dc5cf6578	\N	2e6fa9ea-43da-47ab-a8a8-e2e58360f575	98fba7cd-606b-4e45-957c-f63d3a809e84	مغایرت‌گیری حساب‌های بانکی #48	\N	high	2026-08-08	69811bc7-8527-4c75-a5e1-0997542a22e9	2026-07-21 11:45:44.744086+00	2026-07-21 11:45:44.744086+00	archived	\N	31	3.20	2026-07-25	medium
582b48ec-cec0-4e4b-a7d4-cbfd51751f0f	30cf629e-4a36-40a9-9107-ae3dc5cf6578	\N	2e6fa9ea-43da-47ab-a8a8-e2e58360f575	98fba7cd-606b-4e45-957c-f63d3a809e84	به‌روزرسانی جدول حقوق و دستمزد #49	\N	medium	2026-06-30	fc459c9d-0c4f-438a-ac75-c0b214dd3fc9	2026-07-21 11:45:44.744086+00	2026-07-21 11:45:44.744086+00	todo	\N	53	7.80	2026-06-28	medium
582b48ec-cec0-4e4b-a7d4-cbfd51751f0f	30cf629e-4a36-40a9-9107-ae3dc5cf6578	\N	2e6fa9ea-43da-47ab-a8a8-e2e58360f575	98fba7cd-606b-4e45-957c-f63d3a809e84	بررسی و تسویهٔ کارت اعتباری شرکت #50	\N	high	2026-07-30	15a336b4-a631-41c9-a621-16e8590c82ed	2026-07-21 11:45:44.744086+00	2026-07-21 11:45:44.744086+00	in_progress	\N	60	35.20	2026-07-12	medium
582b48ec-cec0-4e4b-a7d4-cbfd51751f0f	30cf629e-4a36-40a9-9107-ae3dc5cf6578	\N	2e6fa9ea-43da-47ab-a8a8-e2e58360f575	98fba7cd-606b-4e45-957c-f63d3a809e84	تهیهٔ پیش‌نویس بودجهٔ واحد #51	\N	low	2026-06-25	c56ef05a-0a0a-4b59-be0d-4d3560b3c304	2026-07-21 11:45:44.744086+00	2026-07-21 11:45:44.744086+00	archived	\N	71	14.40	2026-06-19	medium
582b48ec-cec0-4e4b-a7d4-cbfd51751f0f	30cf629e-4a36-40a9-9107-ae3dc5cf6578	\N	2e6fa9ea-43da-47ab-a8a8-e2e58360f575	98fba7cd-606b-4e45-957c-f63d3a809e84	به‌روزرسانی جدول حقوق و دستمزد #52	\N	high	2026-07-13	fece6319-751a-4b3f-b354-1b7d3733d503	2026-07-21 11:45:44.744086+00	2026-07-21 11:45:44.744086+00	completed	approved	100	15.00	2026-07-06	medium
582b48ec-cec0-4e4b-a7d4-cbfd51751f0f	30cf629e-4a36-40a9-9107-ae3dc5cf6578	\N	e84eaed7-50c6-4212-9f29-cad60bbee457	98fba7cd-606b-4e45-957c-f63d3a809e84	بررسی صورت وضعیت پیمانکاران #53	\N	medium	2026-08-11	18d8d890-4ed4-41cb-b6cf-5b9308a4f95f	2026-07-21 11:45:44.744086+00	2026-07-21 11:45:44.744086+00	completed	pending	100	9.30	2026-08-01	medium
582b48ec-cec0-4e4b-a7d4-cbfd51751f0f	30cf629e-4a36-40a9-9107-ae3dc5cf6578	\N	76c11995-60dc-42d9-9a92-6dc9daa80ce9	98fba7cd-606b-4e45-957c-f63d3a809e84	ثبت اسناد حسابداری هفتگی #54	\N	medium	2026-08-01	5abbdcd7-05f2-464d-bd3e-0cb6f405d1a0	2026-07-21 11:45:44.744086+00	2026-07-21 11:45:44.744086+00	in_progress	\N	36	28.80	2026-07-21	medium
582b48ec-cec0-4e4b-a7d4-cbfd51751f0f	ad0ecc0e-1dd7-4885-9f2c-fe84502e3653	\N	2e6fa9ea-43da-47ab-a8a8-e2e58360f575	98fba7cd-606b-4e45-957c-f63d3a809e84	به‌روزرسانی جدول حقوق و دستمزد #55	\N	medium	2026-07-29	d78f57ee-04d1-4a8f-bf33-c0c5f18087f7	2026-07-21 11:45:44.744086+00	2026-07-21 11:45:44.744086+00	archived	\N	71	37.50	2026-07-17	medium
582b48ec-cec0-4e4b-a7d4-cbfd51751f0f	ad0ecc0e-1dd7-4885-9f2c-fe84502e3653	\N	85751a1a-b02d-4121-aff6-407cd2f6ebd7	98fba7cd-606b-4e45-957c-f63d3a809e84	تهیهٔ گزارش سود و زیان ماهانه #56	\N	high	2026-07-14	978e80ae-810d-40b4-afba-79f9c796f856	2026-07-21 11:45:44.744086+00	2026-07-21 11:45:44.744086+00	archived	\N	69	16.40	2026-07-03	medium
582b48ec-cec0-4e4b-a7d4-cbfd51751f0f	ad0ecc0e-1dd7-4885-9f2c-fe84502e3653	\N	c057add9-a37a-4d8b-adb3-be28effacb81	98fba7cd-606b-4e45-957c-f63d3a809e84	پیگیری مطالبات معوق مشتریان #57	\N	low	2026-08-10	ca92c38d-7fbe-4d8d-9614-4661a9875f3d	2026-07-21 11:45:44.744086+00	2026-07-21 11:45:44.744086+00	in_progress	\N	36	38.30	2026-08-04	medium
582b48ec-cec0-4e4b-a7d4-cbfd51751f0f	ad0ecc0e-1dd7-4885-9f2c-fe84502e3653	\N	98fba7cd-606b-4e45-957c-f63d3a809e84	98fba7cd-606b-4e45-957c-f63d3a809e84	تطبیق موجودی انبار با حساب‌ها #58	\N	medium	2026-08-30	c5681ee5-ba89-46c3-933f-9fa95a7a0ef1	2026-07-21 11:45:44.744086+00	2026-07-21 11:45:44.744086+00	in_progress	\N	61	10.10	2026-08-14	medium
582b48ec-cec0-4e4b-a7d4-cbfd51751f0f	ad0ecc0e-1dd7-4885-9f2c-fe84502e3653	\N	85751a1a-b02d-4121-aff6-407cd2f6ebd7	98fba7cd-606b-4e45-957c-f63d3a809e84	مغایرت‌گیری حساب‌های بانکی #59	\N	low	2026-07-31	21189cc8-f645-4822-a44d-c234451bf2a5	2026-07-21 11:45:44.744086+00	2026-07-21 11:45:44.744086+00	completed	approved	100	25.40	2026-07-21	medium
582b48ec-cec0-4e4b-a7d4-cbfd51751f0f	ad0ecc0e-1dd7-4885-9f2c-fe84502e3653	\N	60845684-b03a-492a-9937-f8529e7ba409	98fba7cd-606b-4e45-957c-f63d3a809e84	تطبیق موجودی انبار با حساب‌ها #60	\N	high	2026-07-04	8502304e-5c15-4d44-8c96-fe60bde748b5	2026-07-21 11:45:44.744086+00	2026-07-21 11:45:44.744086+00	in_progress	\N	28	26.20	2026-07-01	medium
582b48ec-cec0-4e4b-a7d4-cbfd51751f0f	ad0ecc0e-1dd7-4885-9f2c-fe84502e3653	\N	98fba7cd-606b-4e45-957c-f63d3a809e84	98fba7cd-606b-4e45-957c-f63d3a809e84	تهیهٔ گزارش جریان نقدی #61	\N	medium	2026-07-24	813377d8-51c4-4b3b-828a-96417439e642	2026-07-21 11:45:44.744086+00	2026-07-21 11:45:44.744086+00	todo	\N	12	27.90	2026-07-12	medium
582b48ec-cec0-4e4b-a7d4-cbfd51751f0f	ad0ecc0e-1dd7-4885-9f2c-fe84502e3653	\N	76c11995-60dc-42d9-9a92-6dc9daa80ce9	98fba7cd-606b-4e45-957c-f63d3a809e84	بررسی فاکتورهای فروش صادرشده #62	\N	high	2026-07-28	598406cb-5802-40e8-a31e-3f84d1ae89a8	2026-07-21 11:45:44.744086+00	2026-07-21 11:45:44.744086+00	todo	\N	60	20.10	2026-07-21	medium
582b48ec-cec0-4e4b-a7d4-cbfd51751f0f	ad0ecc0e-1dd7-4885-9f2c-fe84502e3653	\N	76c11995-60dc-42d9-9a92-6dc9daa80ce9	98fba7cd-606b-4e45-957c-f63d3a809e84	پیگیری مطالبات معوق مشتریان #63	\N	high	2026-07-16	a8fff62c-f697-4c1d-8aa9-0caf91f8a228	2026-07-21 11:45:44.744086+00	2026-07-21 11:45:44.744086+00	archived	\N	7	36.50	2026-07-04	medium
582b48ec-cec0-4e4b-a7d4-cbfd51751f0f	ad0ecc0e-1dd7-4885-9f2c-fe84502e3653	\N	98fba7cd-606b-4e45-957c-f63d3a809e84	98fba7cd-606b-4e45-957c-f63d3a809e84	بررسی قراردادهای مالی جدید #64	\N	low	2026-07-23	0872a447-e774-420d-8e50-64f99345c256	2026-07-21 11:45:44.744086+00	2026-07-21 11:45:44.744086+00	completed	approved	100	17.90	2026-07-20	medium
582b48ec-cec0-4e4b-a7d4-cbfd51751f0f	ad0ecc0e-1dd7-4885-9f2c-fe84502e3653	\N	85751a1a-b02d-4121-aff6-407cd2f6ebd7	98fba7cd-606b-4e45-957c-f63d3a809e84	پیگیری بیمهٔ کارکنان #65	\N	medium	2026-08-17	8372641f-10bc-40c4-b1df-5ee01b06efc4	2026-07-21 11:45:44.744086+00	2026-07-21 11:45:44.744086+00	todo	\N	63	9.10	2026-08-14	medium
582b48ec-cec0-4e4b-a7d4-cbfd51751f0f	ad0ecc0e-1dd7-4885-9f2c-fe84502e3653	\N	2e6fa9ea-43da-47ab-a8a8-e2e58360f575	98fba7cd-606b-4e45-957c-f63d3a809e84	بررسی و تأیید صورت‌حساب‌های خرید #66	\N	medium	2026-08-14	2bf0069a-2347-4a89-8b50-4ecaedac7fbe	2026-07-21 11:45:44.744086+00	2026-07-21 11:45:44.744086+00	in_progress	\N	72	24.90	2026-08-11	medium
582b48ec-cec0-4e4b-a7d4-cbfd51751f0f	ad0ecc0e-1dd7-4885-9f2c-fe84502e3653	\N	e84eaed7-50c6-4212-9f29-cad60bbee457	98fba7cd-606b-4e45-957c-f63d3a809e84	تهیهٔ پیش‌نویس بودجهٔ واحد #67	\N	medium	2026-08-03	9d7cfc2d-5923-4c22-b8e1-5117d6a35292	2026-07-21 11:45:44.744086+00	2026-07-21 11:45:44.744086+00	in_progress	\N	17	34.30	2026-07-15	medium
582b48ec-cec0-4e4b-a7d4-cbfd51751f0f	ad0ecc0e-1dd7-4885-9f2c-fe84502e3653	\N	c057add9-a37a-4d8b-adb3-be28effacb81	98fba7cd-606b-4e45-957c-f63d3a809e84	تهیهٔ گزارش مالیاتی فصلی #68	\N	low	2026-07-03	750058e4-de91-46da-9f83-e6b251f69c4d	2026-07-21 11:45:44.744086+00	2026-07-21 11:45:44.744086+00	in_progress	\N	58	26.60	2026-06-28	medium
582b48ec-cec0-4e4b-a7d4-cbfd51751f0f	ad0ecc0e-1dd7-4885-9f2c-fe84502e3653	\N	2e6fa9ea-43da-47ab-a8a8-e2e58360f575	98fba7cd-606b-4e45-957c-f63d3a809e84	بررسی و تسویهٔ کارت اعتباری شرکت #69	\N	medium	2026-06-28	2241c71c-05ad-4c98-8dc1-fface4e11fae	2026-07-21 11:45:44.744086+00	2026-07-21 11:45:44.744086+00	todo	\N	72	27.60	2026-06-16	medium
582b48ec-cec0-4e4b-a7d4-cbfd51751f0f	ad0ecc0e-1dd7-4885-9f2c-fe84502e3653	\N	76c11995-60dc-42d9-9a92-6dc9daa80ce9	98fba7cd-606b-4e45-957c-f63d3a809e84	پیگیری بیمهٔ کارکنان #70	\N	medium	2026-08-08	e8d45f00-1a46-4482-927b-ea780c2afa1e	2026-07-21 11:45:44.744086+00	2026-07-21 11:45:44.744086+00	todo	\N	65	14.50	2026-07-25	medium
582b48ec-cec0-4e4b-a7d4-cbfd51751f0f	ad0ecc0e-1dd7-4885-9f2c-fe84502e3653	\N	c057add9-a37a-4d8b-adb3-be28effacb81	98fba7cd-606b-4e45-957c-f63d3a809e84	تهیهٔ گزارش مالیاتی فصلی #71	\N	low	2026-07-11	45b140bf-d1b9-4b13-8b3b-b8b4a9a2cc85	2026-07-21 11:45:44.744086+00	2026-07-21 11:45:44.744086+00	completed	approved	100	2.30	2026-06-24	medium
582b48ec-cec0-4e4b-a7d4-cbfd51751f0f	ad0ecc0e-1dd7-4885-9f2c-fe84502e3653	\N	c057add9-a37a-4d8b-adb3-be28effacb81	98fba7cd-606b-4e45-957c-f63d3a809e84	تهیهٔ گزارش مالیاتی فصلی #72	\N	medium	2026-07-24	9087219e-b7a1-456d-911d-eae1f854a840	2026-07-21 11:45:44.744086+00	2026-07-21 11:45:44.744086+00	in_progress	\N	74	29.50	2026-07-14	medium
582b48ec-cec0-4e4b-a7d4-cbfd51751f0f	46dc887e-e603-4c2d-a2d7-4ccc3e411953	\N	98fba7cd-606b-4e45-957c-f63d3a809e84	98fba7cd-606b-4e45-957c-f63d3a809e84	تهیهٔ گزارش جریان نقدی #73	\N	low	2026-08-09	e68a5f05-78df-47e7-8061-223465c2ddd2	2026-07-21 11:45:44.744086+00	2026-07-21 11:45:44.744086+00	in_progress	\N	7	27.40	2026-07-27	medium
582b48ec-cec0-4e4b-a7d4-cbfd51751f0f	46dc887e-e603-4c2d-a2d7-4ccc3e411953	\N	c057add9-a37a-4d8b-adb3-be28effacb81	98fba7cd-606b-4e45-957c-f63d3a809e84	تطبیق موجودی انبار با حساب‌ها #74	\N	high	2026-07-10	3bc3769d-3053-4b2c-960e-8318e6df9b80	2026-07-21 11:45:44.744086+00	2026-07-21 11:45:44.744086+00	in_progress	\N	39	28.20	2026-06-26	medium
582b48ec-cec0-4e4b-a7d4-cbfd51751f0f	46dc887e-e603-4c2d-a2d7-4ccc3e411953	\N	2e6fa9ea-43da-47ab-a8a8-e2e58360f575	98fba7cd-606b-4e45-957c-f63d3a809e84	ثبت اسناد حسابداری هفتگی #75	\N	low	2026-07-30	a38912a4-973b-4bc4-b406-74661be2199b	2026-07-21 11:45:44.744086+00	2026-07-21 11:45:44.744086+00	in_progress	\N	17	20.20	2026-07-09	medium
582b48ec-cec0-4e4b-a7d4-cbfd51751f0f	46dc887e-e603-4c2d-a2d7-4ccc3e411953	\N	c057add9-a37a-4d8b-adb3-be28effacb81	98fba7cd-606b-4e45-957c-f63d3a809e84	بررسی فاکتورهای فروش صادرشده #76	\N	high	2026-08-06	5e72d9a5-b141-4369-97e1-d7150ddab76c	2026-07-21 11:45:44.744086+00	2026-07-21 11:45:44.744086+00	archived	\N	70	36.70	2026-07-24	medium
582b48ec-cec0-4e4b-a7d4-cbfd51751f0f	46dc887e-e603-4c2d-a2d7-4ccc3e411953	\N	85751a1a-b02d-4121-aff6-407cd2f6ebd7	98fba7cd-606b-4e45-957c-f63d3a809e84	بررسی و تسویهٔ کارت اعتباری شرکت #77	\N	low	2026-08-15	26ad54bf-3f82-42fe-8142-c824dc9c27c8	2026-07-21 11:45:44.744086+00	2026-07-21 11:45:44.744086+00	completed	pending	100	27.90	2026-08-07	medium
582b48ec-cec0-4e4b-a7d4-cbfd51751f0f	46dc887e-e603-4c2d-a2d7-4ccc3e411953	\N	60845684-b03a-492a-9937-f8529e7ba409	98fba7cd-606b-4e45-957c-f63d3a809e84	تهیهٔ پیش‌نویس بودجهٔ واحد #78	\N	high	2026-08-04	5de10f21-b8d4-440e-8e37-fc479c162455	2026-07-21 11:45:44.744086+00	2026-07-21 11:45:44.744086+00	todo	\N	46	5.00	2026-07-19	medium
582b48ec-cec0-4e4b-a7d4-cbfd51751f0f	46dc887e-e603-4c2d-a2d7-4ccc3e411953	\N	60845684-b03a-492a-9937-f8529e7ba409	98fba7cd-606b-4e45-957c-f63d3a809e84	بررسی قراردادهای مالی جدید #79	\N	high	2026-07-08	d6b49b23-0420-4614-8b02-000142b9c2c7	2026-07-21 11:45:44.744086+00	2026-07-21 11:45:44.744086+00	todo	\N	25	23.80	2026-06-19	medium
582b48ec-cec0-4e4b-a7d4-cbfd51751f0f	46dc887e-e603-4c2d-a2d7-4ccc3e411953	\N	76c11995-60dc-42d9-9a92-6dc9daa80ce9	98fba7cd-606b-4e45-957c-f63d3a809e84	به‌روزرسانی جدول حقوق و دستمزد #80	\N	low	2026-07-24	d54cc842-cd97-49c6-9446-a7de65a805e0	2026-07-21 11:45:44.744086+00	2026-07-21 11:45:44.744086+00	todo	\N	26	29.20	2026-07-06	medium
582b48ec-cec0-4e4b-a7d4-cbfd51751f0f	46dc887e-e603-4c2d-a2d7-4ccc3e411953	\N	c057add9-a37a-4d8b-adb3-be28effacb81	98fba7cd-606b-4e45-957c-f63d3a809e84	به‌روزرسانی جدول حقوق و دستمزد #81	\N	low	2026-08-30	51399876-c71a-448f-a7c2-a150229b2b89	2026-07-21 11:45:44.744086+00	2026-07-21 11:45:44.744086+00	todo	\N	58	7.00	2026-08-12	medium
582b48ec-cec0-4e4b-a7d4-cbfd51751f0f	46dc887e-e603-4c2d-a2d7-4ccc3e411953	\N	c057add9-a37a-4d8b-adb3-be28effacb81	98fba7cd-606b-4e45-957c-f63d3a809e84	تطبیق موجودی انبار با حساب‌ها #82	\N	medium	2026-08-06	e0e5ff26-6932-43c9-9fb6-e722fdfa6756	2026-07-21 11:45:44.744086+00	2026-07-21 11:45:44.744086+00	completed	approved	100	29.50	2026-07-21	medium
582b48ec-cec0-4e4b-a7d4-cbfd51751f0f	46dc887e-e603-4c2d-a2d7-4ccc3e411953	\N	c057add9-a37a-4d8b-adb3-be28effacb81	98fba7cd-606b-4e45-957c-f63d3a809e84	تهیهٔ گزارش جریان نقدی #83	\N	low	2026-08-09	de620bc6-eada-43bf-8d61-d69aadfd050b	2026-07-21 11:45:44.744086+00	2026-07-21 11:45:44.744086+00	in_progress	\N	74	4.80	2026-08-07	medium
582b48ec-cec0-4e4b-a7d4-cbfd51751f0f	46dc887e-e603-4c2d-a2d7-4ccc3e411953	\N	c057add9-a37a-4d8b-adb3-be28effacb81	98fba7cd-606b-4e45-957c-f63d3a809e84	تهیهٔ پیش‌نویس بودجهٔ واحد #84	\N	low	2026-08-03	d2ad5688-9570-42b1-8422-306e1f4b0e5d	2026-07-21 11:45:44.744086+00	2026-07-21 11:45:44.744086+00	in_progress	\N	8	39.50	2026-07-30	medium
582b48ec-cec0-4e4b-a7d4-cbfd51751f0f	46dc887e-e603-4c2d-a2d7-4ccc3e411953	\N	c057add9-a37a-4d8b-adb3-be28effacb81	98fba7cd-606b-4e45-957c-f63d3a809e84	مغایرت‌گیری حساب‌های بانکی #85	\N	low	2026-07-19	0611aefb-7260-411c-9490-4f7189f48ba2	2026-07-21 11:45:44.744086+00	2026-07-21 11:45:44.744086+00	todo	\N	53	16.20	2026-07-04	medium
582b48ec-cec0-4e4b-a7d4-cbfd51751f0f	46dc887e-e603-4c2d-a2d7-4ccc3e411953	\N	c057add9-a37a-4d8b-adb3-be28effacb81	98fba7cd-606b-4e45-957c-f63d3a809e84	بررسی فاکتورهای فروش صادرشده #86	\N	low	2026-08-27	1dd61182-531a-4d89-9aed-2af2fb41f43c	2026-07-21 11:45:44.744086+00	2026-07-21 11:45:44.744086+00	completed	pending	100	27.90	2026-08-13	medium
582b48ec-cec0-4e4b-a7d4-cbfd51751f0f	46dc887e-e603-4c2d-a2d7-4ccc3e411953	\N	2e6fa9ea-43da-47ab-a8a8-e2e58360f575	98fba7cd-606b-4e45-957c-f63d3a809e84	تهیهٔ گزارش سود و زیان ماهانه #87	\N	low	2026-08-23	5ccc52e8-e663-4180-81fb-59cf62143084	2026-07-21 11:45:44.744086+00	2026-07-21 11:45:44.744086+00	completed	approved	100	39.70	2026-08-10	medium
582b48ec-cec0-4e4b-a7d4-cbfd51751f0f	46dc887e-e603-4c2d-a2d7-4ccc3e411953	\N	c057add9-a37a-4d8b-adb3-be28effacb81	98fba7cd-606b-4e45-957c-f63d3a809e84	بررسی و تسویهٔ کارت اعتباری شرکت #88	\N	low	2026-07-02	5995ceb0-d72e-4f47-b886-5f376a015fd2	2026-07-21 11:45:44.744086+00	2026-07-21 11:45:44.744086+00	completed	approved	100	39.20	2026-06-30	medium
582b48ec-cec0-4e4b-a7d4-cbfd51751f0f	46dc887e-e603-4c2d-a2d7-4ccc3e411953	\N	c057add9-a37a-4d8b-adb3-be28effacb81	98fba7cd-606b-4e45-957c-f63d3a809e84	بررسی فاکتورهای فروش صادرشده #89	\N	low	2026-08-01	6daff139-b2d3-4e68-9c50-18576a236b5f	2026-07-21 11:45:44.744086+00	2026-07-21 11:45:44.744086+00	completed	pending	100	11.40	2026-07-13	medium
582b48ec-cec0-4e4b-a7d4-cbfd51751f0f	46dc887e-e603-4c2d-a2d7-4ccc3e411953	\N	e84eaed7-50c6-4212-9f29-cad60bbee457	98fba7cd-606b-4e45-957c-f63d3a809e84	بررسی قراردادهای مالی جدید #90	\N	high	2026-07-11	876a45f0-df84-4853-9602-b3e2a010e749	2026-07-21 11:45:44.744086+00	2026-07-21 11:45:44.744086+00	todo	\N	14	3.20	2026-07-03	medium
582b48ec-cec0-4e4b-a7d4-cbfd51751f0f	\N	\N	2e6fa9ea-43da-47ab-a8a8-e2e58360f575	2e6fa9ea-43da-47ab-a8a8-e2e58360f575	ثبت اسناد حسابداری هفتگی #91	\N	low	2026-07-27	23c71d9e-d7f1-46ec-ae08-512ce342a31f	2026-07-21 11:45:44.744086+00	2026-07-21 11:45:44.744086+00	in_progress	\N	8	5.80	2026-07-25	medium
582b48ec-cec0-4e4b-a7d4-cbfd51751f0f	\N	\N	98fba7cd-606b-4e45-957c-f63d3a809e84	98fba7cd-606b-4e45-957c-f63d3a809e84	ثبت اسناد حسابداری هفتگی #92	\N	high	2026-08-03	9c85fcdd-b06e-431d-bfb1-8505ad54e365	2026-07-21 11:45:44.744086+00	2026-07-21 11:45:44.744086+00	completed	approved	100	3.70	2026-07-31	medium
582b48ec-cec0-4e4b-a7d4-cbfd51751f0f	\N	\N	c057add9-a37a-4d8b-adb3-be28effacb81	c057add9-a37a-4d8b-adb3-be28effacb81	بررسی و تسویهٔ کارت اعتباری شرکت #93	\N	low	2026-07-28	498e9498-be0c-4a92-b6a8-5a8e17ced6d3	2026-07-21 11:45:44.744086+00	2026-07-21 11:45:44.744086+00	in_progress	\N	17	21.10	2026-07-20	medium
582b48ec-cec0-4e4b-a7d4-cbfd51751f0f	\N	\N	e84eaed7-50c6-4212-9f29-cad60bbee457	e84eaed7-50c6-4212-9f29-cad60bbee457	تهیهٔ گزارش مالیاتی فصلی #94	\N	high	2026-08-27	54ca2f59-bc89-4d1f-ba8d-2eedb61809c8	2026-07-21 11:45:44.744086+00	2026-07-21 11:45:44.744086+00	in_progress	\N	76	31.40	2026-08-07	medium
582b48ec-cec0-4e4b-a7d4-cbfd51751f0f	\N	\N	85751a1a-b02d-4121-aff6-407cd2f6ebd7	85751a1a-b02d-4121-aff6-407cd2f6ebd7	بررسی قراردادهای مالی جدید #95	\N	low	2026-07-12	c0ca9aac-ace7-47b4-bc46-08ba42a9d679	2026-07-21 11:45:44.744086+00	2026-07-21 11:45:44.744086+00	in_progress	\N	66	10.40	2026-07-01	medium
582b48ec-cec0-4e4b-a7d4-cbfd51751f0f	\N	\N	e84eaed7-50c6-4212-9f29-cad60bbee457	e84eaed7-50c6-4212-9f29-cad60bbee457	بررسی صورت وضعیت پیمانکاران #96	\N	high	2026-07-08	05a1b549-5510-4f9d-8ac6-ecf23d52d84c	2026-07-21 11:45:44.744086+00	2026-07-21 11:45:44.744086+00	in_progress	\N	22	25.80	2026-06-19	medium
582b48ec-cec0-4e4b-a7d4-cbfd51751f0f	\N	\N	c057add9-a37a-4d8b-adb3-be28effacb81	c057add9-a37a-4d8b-adb3-be28effacb81	بررسی و تسویهٔ کارت اعتباری شرکت #97	\N	high	2026-07-22	81e5d14d-9922-4af2-bbca-ea1cc5cf28ef	2026-07-21 11:45:44.744086+00	2026-07-21 11:45:44.744086+00	completed	approved	100	14.10	2026-07-08	medium
582b48ec-cec0-4e4b-a7d4-cbfd51751f0f	\N	\N	c057add9-a37a-4d8b-adb3-be28effacb81	c057add9-a37a-4d8b-adb3-be28effacb81	بررسی فاکتورهای فروش صادرشده #98	\N	low	2026-07-06	c12b6653-fa30-4159-b704-bb3bc00b030c	2026-07-21 11:45:44.744086+00	2026-07-21 11:45:44.744086+00	in_progress	\N	68	20.00	2026-06-25	medium
582b48ec-cec0-4e4b-a7d4-cbfd51751f0f	\N	\N	85751a1a-b02d-4121-aff6-407cd2f6ebd7	85751a1a-b02d-4121-aff6-407cd2f6ebd7	بررسی و تسویهٔ کارت اعتباری شرکت #99	\N	medium	2026-07-11	6795ba06-0a28-4f37-979d-7e47ae68e273	2026-07-21 11:45:44.744086+00	2026-07-21 11:45:44.744086+00	in_progress	\N	7	23.40	2026-07-05	medium
582b48ec-cec0-4e4b-a7d4-cbfd51751f0f	\N	\N	c057add9-a37a-4d8b-adb3-be28effacb81	c057add9-a37a-4d8b-adb3-be28effacb81	پیگیری مطالبات معوق مشتریان #100	\N	low	2026-07-19	569aab13-a5a0-4904-9fb9-629aa81d5db6	2026-07-21 11:45:44.744086+00	2026-07-21 11:45:44.744086+00	completed	approved	100	14.50	2026-07-10	medium
582b48ec-cec0-4e4b-a7d4-cbfd51751f0f	\N	\N	98fba7cd-606b-4e45-957c-f63d3a809e84	98fba7cd-606b-4e45-957c-f63d3a809e84	تهیهٔ گزارش جریان نقدی #101	\N	low	2026-07-10	2c40fd55-8911-4174-b006-1f6b4c8e5f65	2026-07-21 11:45:44.744086+00	2026-07-21 11:45:44.744086+00	completed	pending	100	4.00	2026-06-21	medium
582b48ec-cec0-4e4b-a7d4-cbfd51751f0f	\N	\N	c057add9-a37a-4d8b-adb3-be28effacb81	c057add9-a37a-4d8b-adb3-be28effacb81	ثبت اسناد حسابداری هفتگی #102	\N	high	2026-06-22	b89e6196-a201-4b26-8206-cf77b5be7b89	2026-07-21 11:45:44.744086+00	2026-07-21 11:45:44.744086+00	completed	pending	100	29.50	2026-06-18	medium
582b48ec-cec0-4e4b-a7d4-cbfd51751f0f	\N	\N	60845684-b03a-492a-9937-f8529e7ba409	60845684-b03a-492a-9937-f8529e7ba409	پیگیری بیمهٔ کارکنان #103	\N	medium	2026-07-24	5fc25f8f-26b0-4b08-96c7-94d64b9c6445	2026-07-21 11:45:44.744086+00	2026-07-21 11:45:44.744086+00	in_progress	\N	38	38.40	2026-07-16	medium
582b48ec-cec0-4e4b-a7d4-cbfd51751f0f	\N	\N	98fba7cd-606b-4e45-957c-f63d3a809e84	98fba7cd-606b-4e45-957c-f63d3a809e84	تهیهٔ گزارش جریان نقدی #104	\N	low	2026-08-22	992226fe-7278-48cf-8c72-06ef25027114	2026-07-21 11:45:44.744086+00	2026-07-21 11:45:44.744086+00	in_progress	\N	61	36.70	2026-08-14	medium
582b48ec-cec0-4e4b-a7d4-cbfd51751f0f	\N	\N	2e6fa9ea-43da-47ab-a8a8-e2e58360f575	2e6fa9ea-43da-47ab-a8a8-e2e58360f575	تهیهٔ پیش‌نویس بودجهٔ واحد #105	\N	medium	2026-07-20	5e196c09-dc3b-4c57-bee7-cae2ba35a692	2026-07-21 11:45:44.744086+00	2026-07-21 11:45:44.744086+00	completed	pending	100	31.50	2026-07-11	medium
582b48ec-cec0-4e4b-a7d4-cbfd51751f0f	627346d8-7181-440e-876c-c8fb6bfbda15	\N	2b35422d-f7be-4135-8473-be7d9e83ec3d	2b35422d-f7be-4135-8473-be7d9e83ec3d	برگزاری نظرسنجی رضایت شغلی #1	\N	low	2026-07-29	f6dc3c2d-b9a3-4b1b-a113-58129804e839	2026-07-21 11:45:44.744086+00	2026-07-21 11:45:44.744086+00	todo	\N	67	34.70	2026-07-23	medium
582b48ec-cec0-4e4b-a7d4-cbfd51751f0f	627346d8-7181-440e-876c-c8fb6bfbda15	\N	2b35422d-f7be-4135-8473-be7d9e83ec3d	2b35422d-f7be-4135-8473-be7d9e83ec3d	تدوین برنامهٔ آموزشی سال آینده #2	\N	low	2026-08-14	54024904-5cae-4196-81f4-90b26b1ebd5d	2026-07-21 11:45:44.744086+00	2026-07-21 11:45:44.744086+00	in_progress	\N	43	13.50	2026-07-31	medium
582b48ec-cec0-4e4b-a7d4-cbfd51751f0f	627346d8-7181-440e-876c-c8fb6bfbda15	\N	b4e312c2-6dc5-4616-97c7-1b9251f4ef87	2b35422d-f7be-4135-8473-be7d9e83ec3d	برگزاری نظرسنجی رضایت شغلی #3	\N	high	2026-08-16	8d4cd2cd-ac8a-4db4-bceb-141ed8d36b26	2026-07-21 11:45:44.744086+00	2026-07-21 11:45:44.744086+00	todo	\N	62	26.70	2026-08-01	medium
582b48ec-cec0-4e4b-a7d4-cbfd51751f0f	627346d8-7181-440e-876c-c8fb6bfbda15	\N	b4e312c2-6dc5-4616-97c7-1b9251f4ef87	2b35422d-f7be-4135-8473-be7d9e83ec3d	برگزاری نظرسنجی رضایت شغلی #4	\N	medium	2026-08-11	16b86c04-80f9-4785-a928-3cf0b2e2823f	2026-07-21 11:45:44.744086+00	2026-07-21 11:45:44.744086+00	archived	\N	28	27.30	2026-07-21	medium
582b48ec-cec0-4e4b-a7d4-cbfd51751f0f	627346d8-7181-440e-876c-c8fb6bfbda15	\N	02d643cd-bc19-4efb-9d1a-c3e6d5675d66	2b35422d-f7be-4135-8473-be7d9e83ec3d	به‌روزرسانی پروندهٔ پرسنلی #5	\N	high	2026-07-21	fffc0113-5f07-4b57-bfff-1fc56e55c60f	2026-07-21 11:45:44.744086+00	2026-07-21 11:45:44.744086+00	todo	\N	37	6.80	2026-07-10	medium
582b48ec-cec0-4e4b-a7d4-cbfd51751f0f	627346d8-7181-440e-876c-c8fb6bfbda15	\N	e139f154-0fb4-4ebf-b8b8-b6f5a29afeaf	2b35422d-f7be-4135-8473-be7d9e83ec3d	تهیهٔ فرم ارزیابی سه‌ماهه #6	\N	high	2026-09-04	00364fd7-7895-4677-849f-75a5f34d7a8b	2026-07-21 11:45:44.744086+00	2026-07-21 11:45:44.744086+00	todo	\N	4	8.90	2026-08-15	medium
582b48ec-cec0-4e4b-a7d4-cbfd51751f0f	627346d8-7181-440e-876c-c8fb6bfbda15	\N	984c1d49-02d8-4d53-8ce0-f8709fafb190	2b35422d-f7be-4135-8473-be7d9e83ec3d	بررسی درخواست ترفیع کارکنان #7	\N	medium	2026-07-27	37932347-2584-4b44-b306-f539739f112f	2026-07-21 11:45:44.744086+00	2026-07-21 11:45:44.744086+00	completed	approved	100	7.30	2026-07-22	medium
582b48ec-cec0-4e4b-a7d4-cbfd51751f0f	627346d8-7181-440e-876c-c8fb6bfbda15	\N	e139f154-0fb4-4ebf-b8b8-b6f5a29afeaf	2b35422d-f7be-4135-8473-be7d9e83ec3d	پیگیری درخواست‌های رفاهی کارکنان #8	\N	low	2026-07-14	6ebd8c46-1ecf-4171-a9db-74ee5acc9e66	2026-07-21 11:45:44.744086+00	2026-07-21 11:45:44.744086+00	todo	\N	11	33.20	2026-07-01	medium
582b48ec-cec0-4e4b-a7d4-cbfd51751f0f	627346d8-7181-440e-876c-c8fb6bfbda15	\N	e139f154-0fb4-4ebf-b8b8-b6f5a29afeaf	2b35422d-f7be-4135-8473-be7d9e83ec3d	بررسی رزومه‌های متقاضیان شغلی #9	\N	medium	2026-07-23	51fc32bd-7406-4349-a821-92092f34097a	2026-07-21 11:45:44.744086+00	2026-07-21 11:45:44.744086+00	completed	pending	100	10.00	2026-07-07	medium
582b48ec-cec0-4e4b-a7d4-cbfd51751f0f	627346d8-7181-440e-876c-c8fb6bfbda15	\N	e139f154-0fb4-4ebf-b8b8-b6f5a29afeaf	2b35422d-f7be-4135-8473-be7d9e83ec3d	برگزاری نظرسنجی رضایت شغلی #10	\N	low	2026-07-18	d0399be9-f9e5-45b2-82bc-83e65d844e40	2026-07-21 11:45:44.744086+00	2026-07-21 11:45:44.744086+00	todo	\N	0	3.80	2026-07-08	medium
582b48ec-cec0-4e4b-a7d4-cbfd51751f0f	627346d8-7181-440e-876c-c8fb6bfbda15	\N	77b8df83-b4f0-4924-9ef8-25216fe271af	2b35422d-f7be-4135-8473-be7d9e83ec3d	بررسی درخواست ترفیع کارکنان #11	\N	medium	2026-07-19	d75fe838-1e2c-40de-9508-d72d8961e8b5	2026-07-21 11:45:44.744086+00	2026-07-21 11:45:44.744086+00	archived	\N	63	35.50	2026-07-12	medium
582b48ec-cec0-4e4b-a7d4-cbfd51751f0f	627346d8-7181-440e-876c-c8fb6bfbda15	\N	984c1d49-02d8-4d53-8ce0-f8709fafb190	2b35422d-f7be-4135-8473-be7d9e83ec3d	برگزاری نظرسنجی رضایت شغلی #12	\N	high	2026-08-25	78023139-668b-4f4e-be1e-119fd54638b4	2026-07-21 11:45:44.744086+00	2026-07-21 11:45:44.744086+00	completed	approved	100	26.70	2026-08-08	medium
582b48ec-cec0-4e4b-a7d4-cbfd51751f0f	627346d8-7181-440e-876c-c8fb6bfbda15	\N	e139f154-0fb4-4ebf-b8b8-b6f5a29afeaf	2b35422d-f7be-4135-8473-be7d9e83ec3d	برنامه‌ریزی مصاحبهٔ استخدامی #13	\N	low	2026-07-12	7d258429-2606-4579-8131-8ac1497471c2	2026-07-21 11:45:44.744086+00	2026-07-21 11:45:44.744086+00	in_progress	\N	37	2.80	2026-06-26	medium
582b48ec-cec0-4e4b-a7d4-cbfd51751f0f	627346d8-7181-440e-876c-c8fb6bfbda15	\N	984c1d49-02d8-4d53-8ce0-f8709fafb190	2b35422d-f7be-4135-8473-be7d9e83ec3d	تهیهٔ گزارش ارزیابی عملکرد #14	\N	medium	2026-07-02	6e7cad91-8654-4421-99b7-9a21af3d719a	2026-07-21 11:45:44.744086+00	2026-07-21 11:45:44.744086+00	todo	\N	20	29.80	2026-06-20	medium
582b48ec-cec0-4e4b-a7d4-cbfd51751f0f	627346d8-7181-440e-876c-c8fb6bfbda15	\N	c3bd6208-d89c-402a-90fe-6f00c4219566	2b35422d-f7be-4135-8473-be7d9e83ec3d	تدوین برنامهٔ آموزشی سال آینده #15	\N	medium	2026-07-28	ccf75a17-e710-485f-b7fc-5cb29fd62a99	2026-07-21 11:45:44.744086+00	2026-07-21 11:45:44.744086+00	todo	\N	3	18.40	2026-07-07	medium
582b48ec-cec0-4e4b-a7d4-cbfd51751f0f	627346d8-7181-440e-876c-c8fb6bfbda15	\N	e139f154-0fb4-4ebf-b8b8-b6f5a29afeaf	2b35422d-f7be-4135-8473-be7d9e83ec3d	تهیهٔ گزارش ارزیابی عملکرد #16	\N	low	2026-08-08	838a8ca1-831a-476f-86e7-0f421f318ccb	2026-07-21 11:45:44.744086+00	2026-07-21 11:45:44.744086+00	todo	\N	12	14.60	2026-07-24	medium
582b48ec-cec0-4e4b-a7d4-cbfd51751f0f	627346d8-7181-440e-876c-c8fb6bfbda15	\N	b4e312c2-6dc5-4616-97c7-1b9251f4ef87	2b35422d-f7be-4135-8473-be7d9e83ec3d	به‌روزرسانی پروندهٔ پرسنلی #17	\N	high	2026-08-18	076005e3-2045-4028-91fb-e75a2d44898b	2026-07-21 11:45:44.744086+00	2026-07-21 11:45:44.744086+00	in_progress	\N	69	12.10	2026-07-30	medium
582b48ec-cec0-4e4b-a7d4-cbfd51751f0f	627346d8-7181-440e-876c-c8fb6bfbda15	\N	984c1d49-02d8-4d53-8ce0-f8709fafb190	2b35422d-f7be-4135-8473-be7d9e83ec3d	بررسی رزومه‌های متقاضیان شغلی #18	\N	medium	2026-07-06	f9c0e78e-a333-46c1-a5a8-4ed642c64b70	2026-07-21 11:45:44.744086+00	2026-07-21 11:45:44.744086+00	in_progress	\N	73	22.90	2026-07-01	medium
582b48ec-cec0-4e4b-a7d4-cbfd51751f0f	c6e8997e-a96f-44b6-bd28-cf0816eacee2	\N	77b8df83-b4f0-4924-9ef8-25216fe271af	2b35422d-f7be-4135-8473-be7d9e83ec3d	بررسی رزومه‌های متقاضیان شغلی #19	\N	medium	2026-07-02	53bc9f05-3b25-422f-9133-cbfd99204334	2026-07-21 11:45:44.744086+00	2026-07-21 11:45:44.744086+00	todo	\N	11	13.20	2026-06-19	medium
582b48ec-cec0-4e4b-a7d4-cbfd51751f0f	c6e8997e-a96f-44b6-bd28-cf0816eacee2	\N	e139f154-0fb4-4ebf-b8b8-b6f5a29afeaf	2b35422d-f7be-4135-8473-be7d9e83ec3d	بررسی رزومه‌های متقاضیان شغلی #20	\N	low	2026-07-03	03a4ef6c-1bf6-447e-bc6c-0f13fafac44c	2026-07-21 11:45:44.744086+00	2026-07-21 11:45:44.744086+00	completed	pending	100	8.50	2026-06-28	medium
582b48ec-cec0-4e4b-a7d4-cbfd51751f0f	c6e8997e-a96f-44b6-bd28-cf0816eacee2	\N	984c1d49-02d8-4d53-8ce0-f8709fafb190	2b35422d-f7be-4135-8473-be7d9e83ec3d	به‌روزرسانی آیین‌نامهٔ داخلی شرکت #21	\N	medium	2026-07-21	e02cfa10-31e1-4495-9e77-f251b38722b1	2026-07-21 11:45:44.744086+00	2026-07-21 11:45:44.744086+00	todo	\N	60	20.60	2026-07-16	medium
582b48ec-cec0-4e4b-a7d4-cbfd51751f0f	c6e8997e-a96f-44b6-bd28-cf0816eacee2	\N	e139f154-0fb4-4ebf-b8b8-b6f5a29afeaf	2b35422d-f7be-4135-8473-be7d9e83ec3d	تهیهٔ فرم ارزیابی سه‌ماهه #22	\N	low	2026-07-10	07261e1f-7c6c-474b-a9bf-f17bb9975bde	2026-07-21 11:45:44.744086+00	2026-07-21 11:45:44.744086+00	in_progress	\N	47	35.60	2026-06-21	medium
582b48ec-cec0-4e4b-a7d4-cbfd51751f0f	c6e8997e-a96f-44b6-bd28-cf0816eacee2	\N	984c1d49-02d8-4d53-8ce0-f8709fafb190	2b35422d-f7be-4135-8473-be7d9e83ec3d	به‌روزرسانی آیین‌نامهٔ داخلی شرکت #23	\N	medium	2026-07-17	51626a35-34c7-4b7a-bff7-bf6e87806d7e	2026-07-21 11:45:44.744086+00	2026-07-21 11:45:44.744086+00	todo	\N	59	12.00	2026-07-14	medium
582b48ec-cec0-4e4b-a7d4-cbfd51751f0f	c6e8997e-a96f-44b6-bd28-cf0816eacee2	\N	02d643cd-bc19-4efb-9d1a-c3e6d5675d66	2b35422d-f7be-4135-8473-be7d9e83ec3d	تهیهٔ گزارش ارزیابی عملکرد #24	\N	high	2026-07-25	b3230bf2-ce42-491a-9f70-171afe328485	2026-07-21 11:45:44.744086+00	2026-07-21 11:45:44.744086+00	in_progress	\N	12	5.30	2026-07-22	medium
582b48ec-cec0-4e4b-a7d4-cbfd51751f0f	c6e8997e-a96f-44b6-bd28-cf0816eacee2	\N	984c1d49-02d8-4d53-8ce0-f8709fafb190	2b35422d-f7be-4135-8473-be7d9e83ec3d	برگزاری جلسهٔ آموزش کارکنان جدید #25	\N	high	2026-08-23	7f400ec8-aa07-4bfa-906b-9f555d955112	2026-07-21 11:45:44.744086+00	2026-07-21 11:45:44.744086+00	completed	approved	100	4.30	2026-08-03	medium
582b48ec-cec0-4e4b-a7d4-cbfd51751f0f	c6e8997e-a96f-44b6-bd28-cf0816eacee2	\N	77b8df83-b4f0-4924-9ef8-25216fe271af	2b35422d-f7be-4135-8473-be7d9e83ec3d	تدوین برنامهٔ آموزشی سال آینده #26	\N	low	2026-08-06	6a6b4390-a15b-4fff-8782-8d5736a3a562	2026-07-21 11:45:44.744086+00	2026-07-21 11:45:44.744086+00	completed	approved	100	20.10	2026-07-20	medium
582b48ec-cec0-4e4b-a7d4-cbfd51751f0f	c6e8997e-a96f-44b6-bd28-cf0816eacee2	\N	2b35422d-f7be-4135-8473-be7d9e83ec3d	2b35422d-f7be-4135-8473-be7d9e83ec3d	بررسی و تمدید قراردادهای پرسنلی #27	\N	high	2026-08-15	7a92a414-061b-4f7f-9670-64f74ec5b99f	2026-07-21 11:45:44.744086+00	2026-07-21 11:45:44.744086+00	in_progress	\N	66	32.40	2026-08-12	medium
582b48ec-cec0-4e4b-a7d4-cbfd51751f0f	c6e8997e-a96f-44b6-bd28-cf0816eacee2	\N	e139f154-0fb4-4ebf-b8b8-b6f5a29afeaf	2b35422d-f7be-4135-8473-be7d9e83ec3d	تهیهٔ گزارش ارزیابی عملکرد #28	\N	low	2026-08-31	1afbbb8e-f544-4ad8-8d93-a7ba461fb060	2026-07-21 11:45:44.744086+00	2026-07-21 11:45:44.744086+00	completed	approved	100	38.90	2026-08-15	medium
582b48ec-cec0-4e4b-a7d4-cbfd51751f0f	c6e8997e-a96f-44b6-bd28-cf0816eacee2	\N	02d643cd-bc19-4efb-9d1a-c3e6d5675d66	2b35422d-f7be-4135-8473-be7d9e83ec3d	تهیهٔ فرم ارزیابی سه‌ماهه #29	\N	low	2026-06-27	4060a7d5-0f1a-4945-abfa-8ab00e6bb24c	2026-07-21 11:45:44.744086+00	2026-07-21 11:45:44.744086+00	todo	\N	55	9.70	2026-06-24	medium
582b48ec-cec0-4e4b-a7d4-cbfd51751f0f	c6e8997e-a96f-44b6-bd28-cf0816eacee2	\N	02d643cd-bc19-4efb-9d1a-c3e6d5675d66	2b35422d-f7be-4135-8473-be7d9e83ec3d	پیگیری درخواست‌های رفاهی کارکنان #30	\N	high	2026-08-03	1b610d2a-7dfe-428f-8813-2ab47f7bf0a7	2026-07-21 11:45:44.744086+00	2026-07-21 11:45:44.744086+00	completed	approved	100	36.70	2026-07-24	medium
582b48ec-cec0-4e4b-a7d4-cbfd51751f0f	c6e8997e-a96f-44b6-bd28-cf0816eacee2	\N	2b35422d-f7be-4135-8473-be7d9e83ec3d	2b35422d-f7be-4135-8473-be7d9e83ec3d	تهیهٔ فرم ارزیابی سه‌ماهه #31	\N	high	2026-07-29	edd15ebb-7af9-42a3-a2e6-a00461e09c06	2026-07-21 11:45:44.744086+00	2026-07-21 11:45:44.744086+00	todo	\N	41	34.60	2026-07-10	medium
582b48ec-cec0-4e4b-a7d4-cbfd51751f0f	c6e8997e-a96f-44b6-bd28-cf0816eacee2	\N	c3bd6208-d89c-402a-90fe-6f00c4219566	2b35422d-f7be-4135-8473-be7d9e83ec3d	تدوین برنامهٔ آموزشی سال آینده #32	\N	high	2026-07-07	5d389730-f190-4aff-97fb-82b7202288ac	2026-07-21 11:45:44.744086+00	2026-07-21 11:45:44.744086+00	completed	rejected	100	31.70	2026-06-16	medium
582b48ec-cec0-4e4b-a7d4-cbfd51751f0f	c6e8997e-a96f-44b6-bd28-cf0816eacee2	\N	2b35422d-f7be-4135-8473-be7d9e83ec3d	2b35422d-f7be-4135-8473-be7d9e83ec3d	تدوین برنامهٔ آموزشی سال آینده #33	\N	high	2026-07-01	d389f9b0-345b-44d4-a2ed-a544c60f42d1	2026-07-21 11:45:44.744086+00	2026-07-21 11:45:44.744086+00	in_progress	\N	74	30.80	2026-06-25	medium
582b48ec-cec0-4e4b-a7d4-cbfd51751f0f	c6e8997e-a96f-44b6-bd28-cf0816eacee2	\N	2b35422d-f7be-4135-8473-be7d9e83ec3d	2b35422d-f7be-4135-8473-be7d9e83ec3d	برگزاری نظرسنجی رضایت شغلی #34	\N	medium	2026-07-27	753208ad-02e1-4842-9d80-186bcfe2c4d4	2026-07-21 11:45:44.744086+00	2026-07-21 11:45:44.744086+00	todo	\N	68	35.40	2026-07-22	medium
582b48ec-cec0-4e4b-a7d4-cbfd51751f0f	c6e8997e-a96f-44b6-bd28-cf0816eacee2	\N	77b8df83-b4f0-4924-9ef8-25216fe271af	2b35422d-f7be-4135-8473-be7d9e83ec3d	تدوین برنامهٔ آموزشی سال آینده #35	\N	high	2026-07-27	0c1eb44a-2802-4c0e-b6c1-5d5661379db9	2026-07-21 11:45:44.744086+00	2026-07-21 11:45:44.744086+00	in_progress	\N	60	3.40	2026-07-10	medium
582b48ec-cec0-4e4b-a7d4-cbfd51751f0f	c6e8997e-a96f-44b6-bd28-cf0816eacee2	\N	984c1d49-02d8-4d53-8ce0-f8709fafb190	2b35422d-f7be-4135-8473-be7d9e83ec3d	تدوین برنامهٔ آموزشی سال آینده #36	\N	high	2026-07-16	16db9c03-be47-4349-8723-888161d55e09	2026-07-21 11:45:44.744086+00	2026-07-21 11:45:44.744086+00	in_progress	\N	51	3.50	2026-06-25	medium
582b48ec-cec0-4e4b-a7d4-cbfd51751f0f	c4da833a-95aa-494c-b901-06b176ddb369	\N	984c1d49-02d8-4d53-8ce0-f8709fafb190	2b35422d-f7be-4135-8473-be7d9e83ec3d	بررسی درخواست ترفیع کارکنان #37	\N	medium	2026-08-19	00bbadee-3e78-410a-8169-fb1490ccf25d	2026-07-21 11:45:44.744086+00	2026-07-21 11:45:44.744086+00	completed	approved	100	36.10	2026-08-02	medium
582b48ec-cec0-4e4b-a7d4-cbfd51751f0f	c4da833a-95aa-494c-b901-06b176ddb369	\N	2b35422d-f7be-4135-8473-be7d9e83ec3d	2b35422d-f7be-4135-8473-be7d9e83ec3d	به‌روزرسانی آیین‌نامهٔ داخلی شرکت #38	\N	medium	2026-08-18	d4e6d829-e289-4c32-97fd-44b8fc2f62eb	2026-07-21 11:45:44.744086+00	2026-07-21 11:45:44.744086+00	in_progress	\N	62	34.60	2026-08-07	medium
582b48ec-cec0-4e4b-a7d4-cbfd51751f0f	c4da833a-95aa-494c-b901-06b176ddb369	\N	e139f154-0fb4-4ebf-b8b8-b6f5a29afeaf	2b35422d-f7be-4135-8473-be7d9e83ec3d	تهیهٔ گزارش ارزیابی عملکرد #39	\N	medium	2026-08-19	fc803bd6-b0fc-48cc-a55d-a75e3c0bcead	2026-07-21 11:45:44.744086+00	2026-07-21 11:45:44.744086+00	todo	\N	56	31.40	2026-08-10	medium
582b48ec-cec0-4e4b-a7d4-cbfd51751f0f	c4da833a-95aa-494c-b901-06b176ddb369	\N	984c1d49-02d8-4d53-8ce0-f8709fafb190	2b35422d-f7be-4135-8473-be7d9e83ec3d	تدوین برنامهٔ آموزشی سال آینده #40	\N	high	2026-08-16	19eaa098-bc71-4813-9d87-6217e51e3af7	2026-07-21 11:45:44.744086+00	2026-07-21 11:45:44.744086+00	in_progress	\N	11	9.10	2026-08-01	medium
582b48ec-cec0-4e4b-a7d4-cbfd51751f0f	c4da833a-95aa-494c-b901-06b176ddb369	\N	b4e312c2-6dc5-4616-97c7-1b9251f4ef87	2b35422d-f7be-4135-8473-be7d9e83ec3d	برگزاری نظرسنجی رضایت شغلی #41	\N	high	2026-08-19	1e192ee6-9f49-47c3-a524-0563e0f663ad	2026-07-21 11:45:44.744086+00	2026-07-21 11:45:44.744086+00	in_progress	\N	47	33.20	2026-08-02	medium
582b48ec-cec0-4e4b-a7d4-cbfd51751f0f	c4da833a-95aa-494c-b901-06b176ddb369	\N	c3bd6208-d89c-402a-90fe-6f00c4219566	2b35422d-f7be-4135-8473-be7d9e83ec3d	به‌روزرسانی پروندهٔ پرسنلی #42	\N	high	2026-07-01	b2864bcb-98d1-4347-88c0-f4a4b2df87e4	2026-07-21 11:45:44.744086+00	2026-07-21 11:45:44.744086+00	todo	\N	51	7.20	2026-06-20	medium
582b48ec-cec0-4e4b-a7d4-cbfd51751f0f	c4da833a-95aa-494c-b901-06b176ddb369	\N	02d643cd-bc19-4efb-9d1a-c3e6d5675d66	2b35422d-f7be-4135-8473-be7d9e83ec3d	برگزاری جلسهٔ آموزش کارکنان جدید #43	\N	low	2026-06-24	08f9ced2-8891-4b96-bc5a-dc4ef044d7d0	2026-07-21 11:45:44.744086+00	2026-07-21 11:45:44.744086+00	completed	pending	100	33.80	2026-06-17	medium
582b48ec-cec0-4e4b-a7d4-cbfd51751f0f	c4da833a-95aa-494c-b901-06b176ddb369	\N	b4e312c2-6dc5-4616-97c7-1b9251f4ef87	2b35422d-f7be-4135-8473-be7d9e83ec3d	بررسی درخواست ترفیع کارکنان #44	\N	medium	2026-07-18	4800903e-2855-4066-9423-225e0ee4c29d	2026-07-21 11:45:44.744086+00	2026-07-21 11:45:44.744086+00	todo	\N	25	12.40	2026-07-15	medium
582b48ec-cec0-4e4b-a7d4-cbfd51751f0f	c4da833a-95aa-494c-b901-06b176ddb369	\N	02d643cd-bc19-4efb-9d1a-c3e6d5675d66	2b35422d-f7be-4135-8473-be7d9e83ec3d	پیگیری مرخصی و مأموریت کارکنان #45	\N	low	2026-07-31	79998774-9174-4813-8c5e-262388ce3872	2026-07-21 11:45:44.744086+00	2026-07-21 11:45:44.744086+00	completed	approved	100	11.20	2026-07-26	medium
582b48ec-cec0-4e4b-a7d4-cbfd51751f0f	c4da833a-95aa-494c-b901-06b176ddb369	\N	77b8df83-b4f0-4924-9ef8-25216fe271af	2b35422d-f7be-4135-8473-be7d9e83ec3d	تدوین برنامهٔ آموزشی سال آینده #46	\N	high	2026-08-27	9c1d261a-9015-4768-93a5-4c40b9691bfe	2026-07-21 11:45:44.744086+00	2026-07-21 11:45:44.744086+00	completed	approved	100	15.30	2026-08-10	medium
582b48ec-cec0-4e4b-a7d4-cbfd51751f0f	c4da833a-95aa-494c-b901-06b176ddb369	\N	b4e312c2-6dc5-4616-97c7-1b9251f4ef87	2b35422d-f7be-4135-8473-be7d9e83ec3d	به‌روزرسانی آیین‌نامهٔ داخلی شرکت #47	\N	low	2026-08-06	9817621a-0b86-4eba-bdf9-c05fd69f599c	2026-07-21 11:45:44.744086+00	2026-07-21 11:45:44.744086+00	in_progress	\N	49	3.90	2026-08-02	medium
582b48ec-cec0-4e4b-a7d4-cbfd51751f0f	c4da833a-95aa-494c-b901-06b176ddb369	\N	02d643cd-bc19-4efb-9d1a-c3e6d5675d66	2b35422d-f7be-4135-8473-be7d9e83ec3d	پیگیری مرخصی و مأموریت کارکنان #48	\N	low	2026-07-08	4ff84820-2710-4cc9-a9a5-e69eadfb4498	2026-07-21 11:45:44.744086+00	2026-07-21 11:45:44.744086+00	completed	pending	100	27.80	2026-06-29	medium
582b48ec-cec0-4e4b-a7d4-cbfd51751f0f	c4da833a-95aa-494c-b901-06b176ddb369	\N	984c1d49-02d8-4d53-8ce0-f8709fafb190	2b35422d-f7be-4135-8473-be7d9e83ec3d	برنامه‌ریزی رویداد تیم‌سازی #49	\N	low	2026-06-19	5f6fa171-82f3-4b9f-9504-1980f716b6a8	2026-07-21 11:45:44.744086+00	2026-07-21 11:45:44.744086+00	completed	approved	100	26.60	2026-06-17	medium
582b48ec-cec0-4e4b-a7d4-cbfd51751f0f	c4da833a-95aa-494c-b901-06b176ddb369	\N	c3bd6208-d89c-402a-90fe-6f00c4219566	2b35422d-f7be-4135-8473-be7d9e83ec3d	تدوین برنامهٔ آموزشی سال آینده #50	\N	medium	2026-07-10	9ecee9f0-d316-4c40-a8d6-f515038d4568	2026-07-21 11:45:44.744086+00	2026-07-21 11:45:44.744086+00	todo	\N	35	18.10	2026-06-30	medium
582b48ec-cec0-4e4b-a7d4-cbfd51751f0f	c4da833a-95aa-494c-b901-06b176ddb369	\N	77b8df83-b4f0-4924-9ef8-25216fe271af	2b35422d-f7be-4135-8473-be7d9e83ec3d	برگزاری جلسهٔ آموزش کارکنان جدید #51	\N	medium	2026-07-25	7777dc96-da1c-4593-8fa9-d8b833ee6dcc	2026-07-21 11:45:44.744086+00	2026-07-21 11:45:44.744086+00	in_progress	\N	38	27.70	2026-07-15	medium
582b48ec-cec0-4e4b-a7d4-cbfd51751f0f	c4da833a-95aa-494c-b901-06b176ddb369	\N	02d643cd-bc19-4efb-9d1a-c3e6d5675d66	2b35422d-f7be-4135-8473-be7d9e83ec3d	بررسی و تمدید قراردادهای پرسنلی #52	\N	high	2026-06-24	14fc2bd7-a977-4a9a-9b26-59dd13aca47a	2026-07-21 11:45:44.744086+00	2026-07-21 11:45:44.744086+00	completed	approved	100	38.70	2026-06-22	medium
582b48ec-cec0-4e4b-a7d4-cbfd51751f0f	c4da833a-95aa-494c-b901-06b176ddb369	\N	02d643cd-bc19-4efb-9d1a-c3e6d5675d66	2b35422d-f7be-4135-8473-be7d9e83ec3d	تدوین برنامهٔ آموزشی سال آینده #53	\N	medium	2026-08-11	bcc7d5fc-9095-4f08-abca-9be7cc9a6ff6	2026-07-21 11:45:44.744086+00	2026-07-21 11:45:44.744086+00	in_progress	\N	38	28.00	2026-07-21	medium
582b48ec-cec0-4e4b-a7d4-cbfd51751f0f	c4da833a-95aa-494c-b901-06b176ddb369	\N	77b8df83-b4f0-4924-9ef8-25216fe271af	2b35422d-f7be-4135-8473-be7d9e83ec3d	پیگیری مرخصی و مأموریت کارکنان #54	\N	medium	2026-07-17	a3a52e58-eb85-40fc-ad7e-95728b2e64b8	2026-07-21 11:45:44.744086+00	2026-07-21 11:45:44.744086+00	todo	\N	35	11.90	2026-07-07	medium
582b48ec-cec0-4e4b-a7d4-cbfd51751f0f	ffc01140-775e-4436-af23-83d1b513e6a1	\N	e139f154-0fb4-4ebf-b8b8-b6f5a29afeaf	2b35422d-f7be-4135-8473-be7d9e83ec3d	برگزاری نظرسنجی رضایت شغلی #55	\N	low	2026-07-13	0d855ffd-d783-46a2-9935-ced506b65ae5	2026-07-21 11:45:44.744086+00	2026-07-21 11:45:44.744086+00	completed	approved	100	36.20	2026-06-25	medium
582b48ec-cec0-4e4b-a7d4-cbfd51751f0f	ffc01140-775e-4436-af23-83d1b513e6a1	\N	02d643cd-bc19-4efb-9d1a-c3e6d5675d66	2b35422d-f7be-4135-8473-be7d9e83ec3d	به‌روزرسانی پروندهٔ پرسنلی #56	\N	low	2026-07-12	75962ffc-85f8-4f51-a8cc-302c359211b6	2026-07-21 11:45:44.744086+00	2026-07-21 11:45:44.744086+00	completed	approved	100	26.90	2026-07-06	medium
582b48ec-cec0-4e4b-a7d4-cbfd51751f0f	ffc01140-775e-4436-af23-83d1b513e6a1	\N	984c1d49-02d8-4d53-8ce0-f8709fafb190	2b35422d-f7be-4135-8473-be7d9e83ec3d	تهیهٔ فرم ارزیابی سه‌ماهه #57	\N	medium	2026-08-28	778ed431-cef7-4288-aa57-d49d6b894e37	2026-07-21 11:45:44.744086+00	2026-07-21 11:45:44.744086+00	in_progress	\N	4	24.20	2026-08-13	medium
582b48ec-cec0-4e4b-a7d4-cbfd51751f0f	ffc01140-775e-4436-af23-83d1b513e6a1	\N	c3bd6208-d89c-402a-90fe-6f00c4219566	2b35422d-f7be-4135-8473-be7d9e83ec3d	پیگیری مرخصی و مأموریت کارکنان #58	\N	high	2026-07-16	697bff0e-25e6-44f5-a719-6fcc0de0e067	2026-07-21 11:45:44.744086+00	2026-07-21 11:45:44.744086+00	todo	\N	60	36.40	2026-07-07	medium
582b48ec-cec0-4e4b-a7d4-cbfd51751f0f	ffc01140-775e-4436-af23-83d1b513e6a1	\N	e139f154-0fb4-4ebf-b8b8-b6f5a29afeaf	2b35422d-f7be-4135-8473-be7d9e83ec3d	تهیهٔ گزارش غیبت و تأخیر #59	\N	low	2026-07-29	71b000e1-ab7a-4db5-9c6c-47b9b63d4755	2026-07-21 11:45:44.744086+00	2026-07-21 11:45:44.744086+00	in_progress	\N	71	8.90	2026-07-18	medium
582b48ec-cec0-4e4b-a7d4-cbfd51751f0f	ffc01140-775e-4436-af23-83d1b513e6a1	\N	2b35422d-f7be-4135-8473-be7d9e83ec3d	2b35422d-f7be-4135-8473-be7d9e83ec3d	برگزاری نظرسنجی رضایت شغلی #60	\N	low	2026-07-21	fecf3244-f8ca-4968-8781-b3cbd1ade40a	2026-07-21 11:45:44.744086+00	2026-07-21 11:45:44.744086+00	completed	approved	100	38.00	2026-07-02	medium
582b48ec-cec0-4e4b-a7d4-cbfd51751f0f	ffc01140-775e-4436-af23-83d1b513e6a1	\N	984c1d49-02d8-4d53-8ce0-f8709fafb190	2b35422d-f7be-4135-8473-be7d9e83ec3d	به‌روزرسانی پروندهٔ پرسنلی #61	\N	medium	2026-07-17	fcd39443-d143-409c-b374-aac23c0efb5e	2026-07-21 11:45:44.744086+00	2026-07-21 11:45:44.744086+00	completed	approved	100	18.00	2026-07-08	medium
582b48ec-cec0-4e4b-a7d4-cbfd51751f0f	ffc01140-775e-4436-af23-83d1b513e6a1	\N	984c1d49-02d8-4d53-8ce0-f8709fafb190	2b35422d-f7be-4135-8473-be7d9e83ec3d	به‌روزرسانی آیین‌نامهٔ داخلی شرکت #62	\N	medium	2026-07-22	d6c23c76-21d9-4e9d-968c-6bfef099238c	2026-07-21 11:45:44.744086+00	2026-07-21 11:45:44.744086+00	in_progress	\N	15	19.90	2026-07-02	medium
582b48ec-cec0-4e4b-a7d4-cbfd51751f0f	ffc01140-775e-4436-af23-83d1b513e6a1	\N	02d643cd-bc19-4efb-9d1a-c3e6d5675d66	2b35422d-f7be-4135-8473-be7d9e83ec3d	برنامه‌ریزی مصاحبهٔ استخدامی #63	\N	medium	2026-09-05	cd1dfff5-b50a-4f88-903c-d875b110058e	2026-07-21 11:45:44.744086+00	2026-07-21 11:45:44.744086+00	completed	approved	100	35.80	2026-08-15	medium
582b48ec-cec0-4e4b-a7d4-cbfd51751f0f	ffc01140-775e-4436-af23-83d1b513e6a1	\N	c3bd6208-d89c-402a-90fe-6f00c4219566	2b35422d-f7be-4135-8473-be7d9e83ec3d	بررسی و تمدید قراردادهای پرسنلی #64	\N	medium	2026-08-24	a95b2be6-249e-484e-9fd0-90bae3021e9b	2026-07-21 11:45:44.744086+00	2026-07-21 11:45:44.744086+00	todo	\N	52	4.10	2026-08-10	medium
582b48ec-cec0-4e4b-a7d4-cbfd51751f0f	ffc01140-775e-4436-af23-83d1b513e6a1	\N	02d643cd-bc19-4efb-9d1a-c3e6d5675d66	2b35422d-f7be-4135-8473-be7d9e83ec3d	پیگیری درخواست‌های رفاهی کارکنان #65	\N	medium	2026-07-02	8beed594-17a6-46d0-9fd8-a2d7dafe492c	2026-07-21 11:45:44.744086+00	2026-07-21 11:45:44.744086+00	todo	\N	72	35.90	2026-06-24	medium
582b48ec-cec0-4e4b-a7d4-cbfd51751f0f	ffc01140-775e-4436-af23-83d1b513e6a1	\N	77b8df83-b4f0-4924-9ef8-25216fe271af	2b35422d-f7be-4135-8473-be7d9e83ec3d	برگزاری نظرسنجی رضایت شغلی #66	\N	low	2026-07-13	cd670ef4-d8ab-4fde-977b-3c59c85ba95e	2026-07-21 11:45:44.744086+00	2026-07-21 11:45:44.744086+00	todo	\N	62	14.60	2026-07-06	medium
582b48ec-cec0-4e4b-a7d4-cbfd51751f0f	ffc01140-775e-4436-af23-83d1b513e6a1	\N	b4e312c2-6dc5-4616-97c7-1b9251f4ef87	2b35422d-f7be-4135-8473-be7d9e83ec3d	بررسی رزومه‌های متقاضیان شغلی #67	\N	medium	2026-07-29	58c6297f-0f04-46c0-8d33-ce4e57d958ab	2026-07-21 11:45:44.744086+00	2026-07-21 11:45:44.744086+00	in_progress	\N	35	10.00	2026-07-26	medium
582b48ec-cec0-4e4b-a7d4-cbfd51751f0f	ffc01140-775e-4436-af23-83d1b513e6a1	\N	02d643cd-bc19-4efb-9d1a-c3e6d5675d66	2b35422d-f7be-4135-8473-be7d9e83ec3d	برنامه‌ریزی رویداد تیم‌سازی #68	\N	low	2026-07-29	2c27ee54-562a-41ff-9de7-0c14b152ee11	2026-07-21 11:45:44.744086+00	2026-07-21 11:45:44.744086+00	todo	\N	16	25.40	2026-07-22	medium
582b48ec-cec0-4e4b-a7d4-cbfd51751f0f	ffc01140-775e-4436-af23-83d1b513e6a1	\N	e139f154-0fb4-4ebf-b8b8-b6f5a29afeaf	2b35422d-f7be-4135-8473-be7d9e83ec3d	برنامه‌ریزی رویداد تیم‌سازی #69	\N	medium	2026-07-26	0c2b3fa0-2ccb-439b-86c7-d59e55325513	2026-07-21 11:45:44.744086+00	2026-07-21 11:45:44.744086+00	in_progress	\N	0	3.40	2026-07-11	medium
582b48ec-cec0-4e4b-a7d4-cbfd51751f0f	ffc01140-775e-4436-af23-83d1b513e6a1	\N	b4e312c2-6dc5-4616-97c7-1b9251f4ef87	2b35422d-f7be-4135-8473-be7d9e83ec3d	بررسی درخواست ترفیع کارکنان #70	\N	medium	2026-07-11	480d75ee-0278-4670-97bb-44828ed6ea2e	2026-07-21 11:45:44.744086+00	2026-07-21 11:45:44.744086+00	archived	\N	67	9.20	2026-07-09	medium
582b48ec-cec0-4e4b-a7d4-cbfd51751f0f	ffc01140-775e-4436-af23-83d1b513e6a1	\N	e139f154-0fb4-4ebf-b8b8-b6f5a29afeaf	2b35422d-f7be-4135-8473-be7d9e83ec3d	برگزاری جلسهٔ آموزش کارکنان جدید #71	\N	high	2026-08-04	193858a3-0bfa-4f46-a1bc-d00db7e1822a	2026-07-21 11:45:44.744086+00	2026-07-21 11:45:44.744086+00	todo	\N	44	13.90	2026-07-26	medium
582b48ec-cec0-4e4b-a7d4-cbfd51751f0f	ffc01140-775e-4436-af23-83d1b513e6a1	\N	2b35422d-f7be-4135-8473-be7d9e83ec3d	2b35422d-f7be-4135-8473-be7d9e83ec3d	به‌روزرسانی آیین‌نامهٔ داخلی شرکت #72	\N	low	2026-08-07	87000aba-7321-447b-8ef5-1ce6d11d1bd0	2026-07-21 11:45:44.744086+00	2026-07-21 11:45:44.744086+00	in_progress	\N	8	33.30	2026-07-18	medium
582b48ec-cec0-4e4b-a7d4-cbfd51751f0f	0767a39d-9ae9-4f98-9da5-55777e3c8055	\N	984c1d49-02d8-4d53-8ce0-f8709fafb190	2b35422d-f7be-4135-8473-be7d9e83ec3d	تدوین برنامهٔ آموزشی سال آینده #73	\N	high	2026-08-02	dc3c948f-6beb-49ad-99da-6106a59e6e31	2026-07-21 11:45:44.744086+00	2026-07-21 11:45:44.744086+00	in_progress	\N	43	18.50	2026-07-15	medium
582b48ec-cec0-4e4b-a7d4-cbfd51751f0f	0767a39d-9ae9-4f98-9da5-55777e3c8055	\N	e139f154-0fb4-4ebf-b8b8-b6f5a29afeaf	2b35422d-f7be-4135-8473-be7d9e83ec3d	پیگیری درخواست‌های رفاهی کارکنان #74	\N	low	2026-07-24	8cc95bbf-0bce-4b66-84a4-7b8eadaf8ad4	2026-07-21 11:45:44.744086+00	2026-07-21 11:45:44.744086+00	todo	\N	21	38.00	2026-07-07	medium
582b48ec-cec0-4e4b-a7d4-cbfd51751f0f	0767a39d-9ae9-4f98-9da5-55777e3c8055	\N	02d643cd-bc19-4efb-9d1a-c3e6d5675d66	2b35422d-f7be-4135-8473-be7d9e83ec3d	برگزاری جلسهٔ آموزش کارکنان جدید #75	\N	high	2026-06-26	02105178-a665-4acd-acf8-0a0047b52e9d	2026-07-21 11:45:44.744086+00	2026-07-21 11:45:44.744086+00	in_progress	\N	16	10.00	2026-06-17	medium
582b48ec-cec0-4e4b-a7d4-cbfd51751f0f	0767a39d-9ae9-4f98-9da5-55777e3c8055	\N	2b35422d-f7be-4135-8473-be7d9e83ec3d	2b35422d-f7be-4135-8473-be7d9e83ec3d	به‌روزرسانی پروندهٔ پرسنلی #76	\N	high	2026-07-06	8e9dcb75-9234-4e25-b7d0-703f353affe2	2026-07-21 11:45:44.744086+00	2026-07-21 11:45:44.744086+00	completed	approved	100	32.10	2026-06-23	medium
582b48ec-cec0-4e4b-a7d4-cbfd51751f0f	0767a39d-9ae9-4f98-9da5-55777e3c8055	\N	77b8df83-b4f0-4924-9ef8-25216fe271af	2b35422d-f7be-4135-8473-be7d9e83ec3d	بررسی رزومه‌های متقاضیان شغلی #77	\N	high	2026-08-10	3aa6674e-7012-484b-8028-7fe78796132d	2026-07-21 11:45:44.744086+00	2026-07-21 11:45:44.744086+00	completed	approved	100	39.80	2026-07-20	medium
582b48ec-cec0-4e4b-a7d4-cbfd51751f0f	0767a39d-9ae9-4f98-9da5-55777e3c8055	\N	e139f154-0fb4-4ebf-b8b8-b6f5a29afeaf	2b35422d-f7be-4135-8473-be7d9e83ec3d	بررسی رزومه‌های متقاضیان شغلی #78	\N	high	2026-07-29	3aca1ea2-def0-4982-82a3-3ce3060f12e5	2026-07-21 11:45:44.744086+00	2026-07-21 11:45:44.744086+00	todo	\N	14	17.80	2026-07-27	medium
582b48ec-cec0-4e4b-a7d4-cbfd51751f0f	0767a39d-9ae9-4f98-9da5-55777e3c8055	\N	77b8df83-b4f0-4924-9ef8-25216fe271af	2b35422d-f7be-4135-8473-be7d9e83ec3d	برنامه‌ریزی رویداد تیم‌سازی #79	\N	high	2026-07-31	32307ca4-1ca1-47e8-8858-abd6395fd7b9	2026-07-21 11:45:44.744086+00	2026-07-21 11:45:44.744086+00	todo	\N	19	9.80	2026-07-21	medium
582b48ec-cec0-4e4b-a7d4-cbfd51751f0f	0767a39d-9ae9-4f98-9da5-55777e3c8055	\N	e139f154-0fb4-4ebf-b8b8-b6f5a29afeaf	2b35422d-f7be-4135-8473-be7d9e83ec3d	پیگیری مرخصی و مأموریت کارکنان #80	\N	high	2026-07-17	f5b8bde6-21ae-40c7-a1d0-84c454656220	2026-07-21 11:45:44.744086+00	2026-07-21 11:45:44.744086+00	completed	approved	100	12.30	2026-07-12	medium
582b48ec-cec0-4e4b-a7d4-cbfd51751f0f	0767a39d-9ae9-4f98-9da5-55777e3c8055	\N	c3bd6208-d89c-402a-90fe-6f00c4219566	2b35422d-f7be-4135-8473-be7d9e83ec3d	بررسی و تمدید قراردادهای پرسنلی #81	\N	high	2026-08-13	cd5f045a-0b31-462b-8632-67ce6dea4060	2026-07-21 11:45:44.744086+00	2026-07-21 11:45:44.744086+00	completed	approved	100	25.50	2026-08-08	medium
582b48ec-cec0-4e4b-a7d4-cbfd51751f0f	0767a39d-9ae9-4f98-9da5-55777e3c8055	\N	984c1d49-02d8-4d53-8ce0-f8709fafb190	2b35422d-f7be-4135-8473-be7d9e83ec3d	برنامه‌ریزی رویداد تیم‌سازی #82	\N	low	2026-08-10	b73aa91d-fe6c-43a4-abae-2850e7cda4e0	2026-07-21 11:45:44.744086+00	2026-07-21 11:45:44.744086+00	todo	\N	77	9.60	2026-08-05	medium
582b48ec-cec0-4e4b-a7d4-cbfd51751f0f	0767a39d-9ae9-4f98-9da5-55777e3c8055	\N	984c1d49-02d8-4d53-8ce0-f8709fafb190	2b35422d-f7be-4135-8473-be7d9e83ec3d	به‌روزرسانی آیین‌نامهٔ داخلی شرکت #83	\N	low	2026-07-23	25fa6843-207b-4904-8936-481bd911c069	2026-07-21 11:45:44.744086+00	2026-07-21 11:45:44.744086+00	completed	rejected	100	3.50	2026-07-08	medium
582b48ec-cec0-4e4b-a7d4-cbfd51751f0f	0767a39d-9ae9-4f98-9da5-55777e3c8055	\N	77b8df83-b4f0-4924-9ef8-25216fe271af	2b35422d-f7be-4135-8473-be7d9e83ec3d	پیگیری درخواست‌های رفاهی کارکنان #84	\N	low	2026-08-16	71fe240f-d4ef-4b2e-bd53-33084f0230be	2026-07-21 11:45:44.744086+00	2026-07-21 11:45:44.744086+00	in_progress	\N	0	2.50	2026-07-30	medium
582b48ec-cec0-4e4b-a7d4-cbfd51751f0f	0767a39d-9ae9-4f98-9da5-55777e3c8055	\N	2b35422d-f7be-4135-8473-be7d9e83ec3d	2b35422d-f7be-4135-8473-be7d9e83ec3d	پیگیری مرخصی و مأموریت کارکنان #85	\N	medium	2026-08-28	33bd9cd6-1c8f-40f5-9f90-58491a691cf6	2026-07-21 11:45:44.744086+00	2026-07-21 11:45:44.744086+00	todo	\N	19	38.10	2026-08-08	medium
582b48ec-cec0-4e4b-a7d4-cbfd51751f0f	0767a39d-9ae9-4f98-9da5-55777e3c8055	\N	02d643cd-bc19-4efb-9d1a-c3e6d5675d66	2b35422d-f7be-4135-8473-be7d9e83ec3d	بررسی درخواست ترفیع کارکنان #86	\N	medium	2026-08-06	370a6261-eb59-4386-a1ab-70ba76f36cec	2026-07-21 11:45:44.744086+00	2026-07-21 11:45:44.744086+00	completed	approved	100	26.50	2026-08-01	medium
582b48ec-cec0-4e4b-a7d4-cbfd51751f0f	0767a39d-9ae9-4f98-9da5-55777e3c8055	\N	77b8df83-b4f0-4924-9ef8-25216fe271af	2b35422d-f7be-4135-8473-be7d9e83ec3d	بررسی رزومه‌های متقاضیان شغلی #87	\N	low	2026-07-18	12743a7c-a5e0-46da-90c3-8c5dc58ac120	2026-07-21 11:45:44.744086+00	2026-07-21 11:45:44.744086+00	in_progress	\N	22	35.20	2026-07-02	medium
582b48ec-cec0-4e4b-a7d4-cbfd51751f0f	0767a39d-9ae9-4f98-9da5-55777e3c8055	\N	02d643cd-bc19-4efb-9d1a-c3e6d5675d66	2b35422d-f7be-4135-8473-be7d9e83ec3d	تهیهٔ فرم ارزیابی سه‌ماهه #88	\N	high	2026-07-21	e3e29e20-ec9f-432e-b227-f6e81d3f5122	2026-07-21 11:45:44.744086+00	2026-07-21 11:45:44.744086+00	in_progress	\N	14	5.60	2026-07-09	medium
582b48ec-cec0-4e4b-a7d4-cbfd51751f0f	0767a39d-9ae9-4f98-9da5-55777e3c8055	\N	02d643cd-bc19-4efb-9d1a-c3e6d5675d66	2b35422d-f7be-4135-8473-be7d9e83ec3d	پیگیری مرخصی و مأموریت کارکنان #89	\N	high	2026-06-22	e5ef6fb3-857b-4786-8b76-cb36470d4faf	2026-07-21 11:45:44.744086+00	2026-07-21 11:45:44.744086+00	todo	\N	21	14.50	2026-06-16	medium
582b48ec-cec0-4e4b-a7d4-cbfd51751f0f	0767a39d-9ae9-4f98-9da5-55777e3c8055	\N	77b8df83-b4f0-4924-9ef8-25216fe271af	2b35422d-f7be-4135-8473-be7d9e83ec3d	پیگیری درخواست‌های رفاهی کارکنان #90	\N	medium	2026-08-05	a7877bf3-3773-47a7-b309-0edb1f13b3c1	2026-07-21 11:45:44.744086+00	2026-07-21 11:45:44.744086+00	completed	approved	100	8.90	2026-08-01	medium
582b48ec-cec0-4e4b-a7d4-cbfd51751f0f	\N	\N	77b8df83-b4f0-4924-9ef8-25216fe271af	77b8df83-b4f0-4924-9ef8-25216fe271af	تهیهٔ گزارش غیبت و تأخیر #91	\N	medium	2026-07-25	0e7d6325-7217-4ed8-9559-7a66dd8c53c1	2026-07-21 11:45:44.744086+00	2026-07-21 11:45:44.744086+00	in_progress	\N	61	32.40	2026-07-15	medium
582b48ec-cec0-4e4b-a7d4-cbfd51751f0f	\N	\N	e139f154-0fb4-4ebf-b8b8-b6f5a29afeaf	e139f154-0fb4-4ebf-b8b8-b6f5a29afeaf	به‌روزرسانی پروندهٔ پرسنلی #92	\N	high	2026-06-29	398bd521-6b66-440f-8502-df9c3609b47a	2026-07-21 11:45:44.744086+00	2026-07-21 11:45:44.744086+00	todo	\N	7	39.30	2026-06-23	medium
582b48ec-cec0-4e4b-a7d4-cbfd51751f0f	\N	\N	02d643cd-bc19-4efb-9d1a-c3e6d5675d66	02d643cd-bc19-4efb-9d1a-c3e6d5675d66	بررسی درخواست ترفیع کارکنان #93	\N	high	2026-07-07	29cc7825-e865-4912-b481-a3f373e9d118	2026-07-21 11:45:44.744086+00	2026-07-21 11:45:44.744086+00	todo	\N	61	32.50	2026-06-22	medium
582b48ec-cec0-4e4b-a7d4-cbfd51751f0f	\N	\N	e139f154-0fb4-4ebf-b8b8-b6f5a29afeaf	e139f154-0fb4-4ebf-b8b8-b6f5a29afeaf	تدوین برنامهٔ آموزشی سال آینده #94	\N	low	2026-07-23	71a062f0-f06a-4b2c-af58-996699107438	2026-07-21 11:45:44.744086+00	2026-07-21 11:45:44.744086+00	completed	approved	100	34.80	2026-07-10	medium
582b48ec-cec0-4e4b-a7d4-cbfd51751f0f	\N	\N	02d643cd-bc19-4efb-9d1a-c3e6d5675d66	02d643cd-bc19-4efb-9d1a-c3e6d5675d66	برنامه‌ریزی رویداد تیم‌سازی #95	\N	medium	2026-08-18	9cb43a97-5909-4e90-acd7-3c199137c2aa	2026-07-21 11:45:44.744086+00	2026-07-21 11:45:44.744086+00	archived	\N	14	35.70	2026-08-12	medium
582b48ec-cec0-4e4b-a7d4-cbfd51751f0f	\N	\N	77b8df83-b4f0-4924-9ef8-25216fe271af	77b8df83-b4f0-4924-9ef8-25216fe271af	پیگیری مرخصی و مأموریت کارکنان #96	\N	medium	2026-06-30	f62b2bff-3161-4ace-852f-3a7550ddaba2	2026-07-21 11:45:44.744086+00	2026-07-21 11:45:44.744086+00	todo	\N	1	28.80	2026-06-20	medium
582b48ec-cec0-4e4b-a7d4-cbfd51751f0f	\N	\N	e139f154-0fb4-4ebf-b8b8-b6f5a29afeaf	e139f154-0fb4-4ebf-b8b8-b6f5a29afeaf	برگزاری جلسهٔ آموزش کارکنان جدید #97	\N	high	2026-08-11	48a69577-600e-4d40-b27a-9528e5b23127	2026-07-21 11:45:44.744086+00	2026-07-21 11:45:44.744086+00	completed	pending	100	35.20	2026-07-22	medium
582b48ec-cec0-4e4b-a7d4-cbfd51751f0f	\N	\N	c3bd6208-d89c-402a-90fe-6f00c4219566	c3bd6208-d89c-402a-90fe-6f00c4219566	تهیهٔ فرم ارزیابی سه‌ماهه #98	\N	high	2026-07-30	a0fa56a9-c059-4f20-b87a-240a5721bda5	2026-07-21 11:45:44.744086+00	2026-07-21 11:45:44.744086+00	completed	pending	100	29.60	2026-07-25	medium
582b48ec-cec0-4e4b-a7d4-cbfd51751f0f	\N	\N	77b8df83-b4f0-4924-9ef8-25216fe271af	77b8df83-b4f0-4924-9ef8-25216fe271af	تهیهٔ گزارش ارزیابی عملکرد #99	\N	high	2026-08-11	e04581c6-ce00-4357-b7c0-588e3eccd5ef	2026-07-21 11:45:44.744086+00	2026-07-21 11:45:44.744086+00	in_progress	\N	78	4.10	2026-07-28	medium
582b48ec-cec0-4e4b-a7d4-cbfd51751f0f	\N	\N	e139f154-0fb4-4ebf-b8b8-b6f5a29afeaf	e139f154-0fb4-4ebf-b8b8-b6f5a29afeaf	تهیهٔ گزارش غیبت و تأخیر #100	\N	medium	2026-08-04	046d5581-f022-40c9-9205-97a3cf36f394	2026-07-21 11:45:44.744086+00	2026-07-21 11:45:44.744086+00	todo	\N	21	4.80	2026-07-18	medium
582b48ec-cec0-4e4b-a7d4-cbfd51751f0f	\N	\N	77b8df83-b4f0-4924-9ef8-25216fe271af	77b8df83-b4f0-4924-9ef8-25216fe271af	به‌روزرسانی آیین‌نامهٔ داخلی شرکت #101	\N	low	2026-07-13	a8204544-e055-4c33-958b-097626790241	2026-07-21 11:45:44.744086+00	2026-07-21 11:45:44.744086+00	in_progress	\N	64	10.50	2026-07-01	medium
582b48ec-cec0-4e4b-a7d4-cbfd51751f0f	\N	\N	e139f154-0fb4-4ebf-b8b8-b6f5a29afeaf	e139f154-0fb4-4ebf-b8b8-b6f5a29afeaf	برنامه‌ریزی مصاحبهٔ استخدامی #102	\N	medium	2026-07-20	63136f49-5d2f-4d66-819f-dd7f9bf24e98	2026-07-21 11:45:44.744086+00	2026-07-21 11:45:44.744086+00	in_progress	\N	56	32.40	2026-07-11	medium
582b48ec-cec0-4e4b-a7d4-cbfd51751f0f	\N	\N	77b8df83-b4f0-4924-9ef8-25216fe271af	77b8df83-b4f0-4924-9ef8-25216fe271af	برنامه‌ریزی رویداد تیم‌سازی #103	\N	medium	2026-08-26	494861d2-8131-4b52-9404-2f9879d740eb	2026-07-21 11:45:44.744086+00	2026-07-21 11:45:44.744086+00	todo	\N	15	39.30	2026-08-09	medium
582b48ec-cec0-4e4b-a7d4-cbfd51751f0f	\N	\N	e139f154-0fb4-4ebf-b8b8-b6f5a29afeaf	e139f154-0fb4-4ebf-b8b8-b6f5a29afeaf	بررسی رزومه‌های متقاضیان شغلی #104	\N	high	2026-07-26	c621aa56-fbf7-4f0d-a21d-9b2acc90d395	2026-07-21 11:45:44.744086+00	2026-07-21 11:45:44.744086+00	completed	approved	100	22.90	2026-07-11	medium
582b48ec-cec0-4e4b-a7d4-cbfd51751f0f	\N	\N	02d643cd-bc19-4efb-9d1a-c3e6d5675d66	02d643cd-bc19-4efb-9d1a-c3e6d5675d66	تدوین برنامهٔ آموزشی سال آینده #105	\N	high	2026-08-26	d4e5903e-38e4-4cbd-894c-7361ee649fb7	2026-07-21 11:45:44.744086+00	2026-07-21 11:45:44.744086+00	todo	\N	38	35.80	2026-08-05	medium
\.


--
-- Data for Name: users; Type: TABLE DATA; Schema: public; Owner: -
--

COPY public.users (organization_id, full_name, role, is_active, id, created_at, updated_at, department_id, account_id) FROM stdin;
582b48ec-cec0-4e4b-a7d4-cbfd51751f0f	مدیر سازمان	org_admin	t	4ba9028a-0a6d-4c87-aaa0-7e21616e1897	2026-07-21 11:45:44.744086+00	2026-07-21 11:45:44.744086+00	a37a316c-77ba-4e34-b6e6-af2ff812b379	d2d1d359-d54d-4c4f-81f7-68692c0ac617
582b48ec-cec0-4e4b-a7d4-cbfd51751f0f	مدیر پروژه مهندسی و فنی	project_manager	t	09bab356-ca7d-4f2b-a863-5ec4bcad25ca	2026-07-21 11:45:44.744086+00	2026-07-21 11:45:44.744086+00	a37a316c-77ba-4e34-b6e6-af2ff812b379	28ce99d9-f0f4-4f0b-9f08-271d736d3238
582b48ec-cec0-4e4b-a7d4-cbfd51751f0f	کارمند 1 مهندسی و فنی	employee	t	e6f6d74c-28cb-4ed3-98b6-6b15a7e57e23	2026-07-21 11:45:44.744086+00	2026-07-21 11:45:44.744086+00	a37a316c-77ba-4e34-b6e6-af2ff812b379	0835f22f-7f06-4ff0-a44c-60a03817ac42
582b48ec-cec0-4e4b-a7d4-cbfd51751f0f	کارمند 2 مهندسی و فنی	employee	t	0885409c-d2f4-4296-88c0-d8ac1df6a7e5	2026-07-21 11:45:44.744086+00	2026-07-21 11:45:44.744086+00	a37a316c-77ba-4e34-b6e6-af2ff812b379	e0388199-a1f9-4865-98a0-318a5c0814c6
582b48ec-cec0-4e4b-a7d4-cbfd51751f0f	کارمند 3 مهندسی و فنی	employee	t	28996900-cff9-4923-bdf4-33c0c602bda7	2026-07-21 11:45:44.744086+00	2026-07-21 11:45:44.744086+00	a37a316c-77ba-4e34-b6e6-af2ff812b379	5abdd53f-cae2-40ce-8775-7c26313b362e
582b48ec-cec0-4e4b-a7d4-cbfd51751f0f	کارمند 4 مهندسی و فنی	employee	t	2ea22145-8b4c-4e52-84fb-acb66c94b186	2026-07-21 11:45:44.744086+00	2026-07-21 11:45:44.744086+00	a37a316c-77ba-4e34-b6e6-af2ff812b379	60837bcd-2067-4e4e-a8f6-b1ac46cfdff6
582b48ec-cec0-4e4b-a7d4-cbfd51751f0f	کارمند 5 مهندسی و فنی	employee	t	de505605-7889-4573-8969-c65f885903c4	2026-07-21 11:45:44.744086+00	2026-07-21 11:45:44.744086+00	a37a316c-77ba-4e34-b6e6-af2ff812b379	1cbd2818-d4c1-4e07-a205-98cc0ab3edeb
582b48ec-cec0-4e4b-a7d4-cbfd51751f0f	کارمند 6 مهندسی و فنی	employee	t	9bee1760-d3cf-42e2-80de-a78b2be8c965	2026-07-21 11:45:44.744086+00	2026-07-21 11:45:44.744086+00	a37a316c-77ba-4e34-b6e6-af2ff812b379	63ac3a42-2b2c-4f61-b6ba-b634920787d8
582b48ec-cec0-4e4b-a7d4-cbfd51751f0f	مدیر پروژه حسابداری و مالی	project_manager	t	98fba7cd-606b-4e45-957c-f63d3a809e84	2026-07-21 11:45:44.744086+00	2026-07-21 11:45:44.744086+00	cf10ec33-fb1d-4251-b68c-255aa3470fde	bbcca2fb-79d4-40d8-ac62-559486b294fe
582b48ec-cec0-4e4b-a7d4-cbfd51751f0f	کارمند 1 حسابداری و مالی	employee	t	76c11995-60dc-42d9-9a92-6dc9daa80ce9	2026-07-21 11:45:44.744086+00	2026-07-21 11:45:44.744086+00	cf10ec33-fb1d-4251-b68c-255aa3470fde	3511590f-4196-4535-96f2-c5f86e47d720
582b48ec-cec0-4e4b-a7d4-cbfd51751f0f	کارمند 2 حسابداری و مالی	employee	t	e84eaed7-50c6-4212-9f29-cad60bbee457	2026-07-21 11:45:44.744086+00	2026-07-21 11:45:44.744086+00	cf10ec33-fb1d-4251-b68c-255aa3470fde	951d852e-1ca6-4021-b5ba-5525037a7103
582b48ec-cec0-4e4b-a7d4-cbfd51751f0f	کارمند 3 حسابداری و مالی	employee	t	c057add9-a37a-4d8b-adb3-be28effacb81	2026-07-21 11:45:44.744086+00	2026-07-21 11:45:44.744086+00	cf10ec33-fb1d-4251-b68c-255aa3470fde	04c396df-2266-44cc-b38a-50df600117fa
582b48ec-cec0-4e4b-a7d4-cbfd51751f0f	کارمند 4 حسابداری و مالی	employee	t	60845684-b03a-492a-9937-f8529e7ba409	2026-07-21 11:45:44.744086+00	2026-07-21 11:45:44.744086+00	cf10ec33-fb1d-4251-b68c-255aa3470fde	9ace887f-69e3-4086-bea6-8bc576104975
582b48ec-cec0-4e4b-a7d4-cbfd51751f0f	کارمند 5 حسابداری و مالی	employee	t	2e6fa9ea-43da-47ab-a8a8-e2e58360f575	2026-07-21 11:45:44.744086+00	2026-07-21 11:45:44.744086+00	cf10ec33-fb1d-4251-b68c-255aa3470fde	62a38266-f1d6-4fc5-872c-8d39f2233901
582b48ec-cec0-4e4b-a7d4-cbfd51751f0f	کارمند 6 حسابداری و مالی	employee	t	85751a1a-b02d-4121-aff6-407cd2f6ebd7	2026-07-21 11:45:44.744086+00	2026-07-21 11:45:44.744086+00	cf10ec33-fb1d-4251-b68c-255aa3470fde	2512cf12-bc58-495e-9375-02ff73b754d9
582b48ec-cec0-4e4b-a7d4-cbfd51751f0f	مدیر پروژه منابع انسانی	project_manager	t	2b35422d-f7be-4135-8473-be7d9e83ec3d	2026-07-21 11:45:44.744086+00	2026-07-21 11:45:44.744086+00	fbc0e416-765b-415a-82a5-f0ad851343b2	45fd4ec3-df52-41d5-8c6f-3f0b185db95e
582b48ec-cec0-4e4b-a7d4-cbfd51751f0f	کارمند 1 منابع انسانی	employee	t	b4e312c2-6dc5-4616-97c7-1b9251f4ef87	2026-07-21 11:45:44.744086+00	2026-07-21 11:45:44.744086+00	fbc0e416-765b-415a-82a5-f0ad851343b2	16fab593-4268-468e-bf19-c0c4eabb17d5
582b48ec-cec0-4e4b-a7d4-cbfd51751f0f	کارمند 2 منابع انسانی	employee	t	984c1d49-02d8-4d53-8ce0-f8709fafb190	2026-07-21 11:45:44.744086+00	2026-07-21 11:45:44.744086+00	fbc0e416-765b-415a-82a5-f0ad851343b2	0c4f97af-83ed-4bb6-b816-90fb051d7c10
582b48ec-cec0-4e4b-a7d4-cbfd51751f0f	کارمند 3 منابع انسانی	employee	t	77b8df83-b4f0-4924-9ef8-25216fe271af	2026-07-21 11:45:44.744086+00	2026-07-21 11:45:44.744086+00	fbc0e416-765b-415a-82a5-f0ad851343b2	0b10a3eb-c399-40c2-a421-c3d22118275d
582b48ec-cec0-4e4b-a7d4-cbfd51751f0f	کارمند 4 منابع انسانی	employee	t	c3bd6208-d89c-402a-90fe-6f00c4219566	2026-07-21 11:45:44.744086+00	2026-07-21 11:45:44.744086+00	fbc0e416-765b-415a-82a5-f0ad851343b2	e2e1d229-5269-4b48-bfd4-0c667cf24256
582b48ec-cec0-4e4b-a7d4-cbfd51751f0f	کارمند 5 منابع انسانی	employee	t	e139f154-0fb4-4ebf-b8b8-b6f5a29afeaf	2026-07-21 11:45:44.744086+00	2026-07-21 11:45:44.744086+00	fbc0e416-765b-415a-82a5-f0ad851343b2	798703a9-a65f-49cc-b5d5-dac8b9828836
582b48ec-cec0-4e4b-a7d4-cbfd51751f0f	کارمند 6 منابع انسانی	employee	t	02d643cd-bc19-4efb-9d1a-c3e6d5675d66	2026-07-21 11:45:44.744086+00	2026-07-21 11:45:44.744086+00	fbc0e416-765b-415a-82a5-f0ad851343b2	9bb0502e-b421-4799-a47d-1ce02453ed96
\.


--
-- Data for Name: worklogs; Type: TABLE DATA; Schema: public; Owner: -
--

COPY public.worklogs (organization_id, task_id, user_id, activity_description, time_spent_minutes, progress_percent, log_date, status, reviewed_by_id, review_comment, id, created_at, updated_at) FROM stdin;
582b48ec-cec0-4e4b-a7d4-cbfd51751f0f	89facc01-1a6b-4795-b067-9542811622f7	2ea22145-8b4c-4e52-84fb-acb66c94b186	مستندسازی و نهایی‌سازی	118	33	2026-07-16	approved	09bab356-ca7d-4f2b-a863-5ec4bcad25ca	\N	10414c2f-6ad7-4ec5-9243-ad47f9ce8455	2026-07-21 11:45:44.744086+00	2026-07-21 11:45:44.744086+00
582b48ec-cec0-4e4b-a7d4-cbfd51751f0f	89facc01-1a6b-4795-b067-9542811622f7	2ea22145-8b4c-4e52-84fb-acb66c94b186	تست و اطمینان از عملکرد صحیح	99	58	2026-07-16	approved	09bab356-ca7d-4f2b-a863-5ec4bcad25ca	\N	e26bfd0b-6008-433b-adb4-a43bcd6744a8	2026-07-21 11:45:44.744086+00	2026-07-21 11:45:44.744086+00
582b48ec-cec0-4e4b-a7d4-cbfd51751f0f	89facc01-1a6b-4795-b067-9542811622f7	2ea22145-8b4c-4e52-84fb-acb66c94b186	پیاده‌سازی بخش اصلی	110	69	2026-07-16	approved	09bab356-ca7d-4f2b-a863-5ec4bcad25ca	\N	033e5a9e-5b9d-4131-8bac-b91894892e5c	2026-07-21 11:45:44.744086+00	2026-07-21 11:45:44.744086+00
582b48ec-cec0-4e4b-a7d4-cbfd51751f0f	45e476f3-2ff2-4d5f-9a8f-e42f151075d6	e6f6d74c-28cb-4ed3-98b6-6b15a7e57e23	تست و اطمینان از عملکرد صحیح	100	38	2026-07-16	approved	09bab356-ca7d-4f2b-a863-5ec4bcad25ca	\N	7f69fa94-4d00-4f9a-ad96-8c99308da285	2026-07-21 11:45:44.744086+00	2026-07-21 11:45:44.744086+00
582b48ec-cec0-4e4b-a7d4-cbfd51751f0f	45e476f3-2ff2-4d5f-9a8f-e42f151075d6	e6f6d74c-28cb-4ed3-98b6-6b15a7e57e23	پیاده‌سازی بخش اصلی	105	54	2026-07-16	submitted	\N	\N	12e81959-7071-4802-952d-cc97fa90626f	2026-07-21 11:45:44.744086+00	2026-07-21 11:45:44.744086+00
582b48ec-cec0-4e4b-a7d4-cbfd51751f0f	0eaac504-3fea-4295-8932-23891014da29	9bee1760-d3cf-42e2-80de-a78b2be8c965	مستندسازی و نهایی‌سازی	62	28	2026-07-16	approved	09bab356-ca7d-4f2b-a863-5ec4bcad25ca	\N	1d5acd16-25f8-4799-9fef-871a9efbb1c0	2026-07-21 11:45:44.744086+00	2026-07-21 11:45:44.744086+00
582b48ec-cec0-4e4b-a7d4-cbfd51751f0f	0eaac504-3fea-4295-8932-23891014da29	9bee1760-d3cf-42e2-80de-a78b2be8c965	مستندسازی و نهایی‌سازی	104	48	2026-07-16	submitted	\N	\N	baa8c345-7f05-445e-8113-80fa77a63ea8	2026-07-21 11:45:44.744086+00	2026-07-21 11:45:44.744086+00
582b48ec-cec0-4e4b-a7d4-cbfd51751f0f	0eaac504-3fea-4295-8932-23891014da29	9bee1760-d3cf-42e2-80de-a78b2be8c965	پیشرفت اولیه و بررسی نیازمندی‌ها	176	87	2026-07-16	approved	09bab356-ca7d-4f2b-a863-5ec4bcad25ca	\N	111333f6-6691-41d5-98a1-22e0edbfb3a2	2026-07-21 11:45:44.744086+00	2026-07-21 11:45:44.744086+00
582b48ec-cec0-4e4b-a7d4-cbfd51751f0f	de963c61-0f29-44f0-832b-299281c93b8e	0885409c-d2f4-4296-88c0-d8ac1df6a7e5	تست و اطمینان از عملکرد صحیح	117	25	2026-06-20	approved	09bab356-ca7d-4f2b-a863-5ec4bcad25ca	\N	a1e9e91a-4379-4905-b58b-e0cdc673ad47	2026-07-21 11:45:44.744086+00	2026-07-21 11:45:44.744086+00
582b48ec-cec0-4e4b-a7d4-cbfd51751f0f	de963c61-0f29-44f0-832b-299281c93b8e	0885409c-d2f4-4296-88c0-d8ac1df6a7e5	رفع اشکالات و بازبینی	152	46	2026-06-21	approved	09bab356-ca7d-4f2b-a863-5ec4bcad25ca	\N	f15aa517-68b0-492a-af4e-e73be54c7e42	2026-07-21 11:45:44.744086+00	2026-07-21 11:45:44.744086+00
582b48ec-cec0-4e4b-a7d4-cbfd51751f0f	de963c61-0f29-44f0-832b-299281c93b8e	0885409c-d2f4-4296-88c0-d8ac1df6a7e5	تست و اطمینان از عملکرد صحیح	155	66	2026-06-22	approved	09bab356-ca7d-4f2b-a863-5ec4bcad25ca	\N	5097e29f-5200-4c13-8d3d-fc40940f5d50	2026-07-21 11:45:44.744086+00	2026-07-21 11:45:44.744086+00
582b48ec-cec0-4e4b-a7d4-cbfd51751f0f	de963c61-0f29-44f0-832b-299281c93b8e	0885409c-d2f4-4296-88c0-d8ac1df6a7e5	پیاده‌سازی بخش اصلی	68	100	2026-06-23	approved	09bab356-ca7d-4f2b-a863-5ec4bcad25ca	\N	411bbb4d-9702-44f3-84cb-d0d5fb47f5f6	2026-07-21 11:45:44.744086+00	2026-07-21 11:45:44.744086+00
582b48ec-cec0-4e4b-a7d4-cbfd51751f0f	751f3611-30e2-4cef-beff-236296ec6aee	09bab356-ca7d-4f2b-a863-5ec4bcad25ca	پیشرفت اولیه و بررسی نیازمندی‌ها	172	33	2026-07-16	submitted	\N	\N	058ba5aa-adf0-4cf3-91b1-1ea826478047	2026-07-21 11:45:44.744086+00	2026-07-21 11:45:44.744086+00
582b48ec-cec0-4e4b-a7d4-cbfd51751f0f	751f3611-30e2-4cef-beff-236296ec6aee	09bab356-ca7d-4f2b-a863-5ec4bcad25ca	تست و اطمینان از عملکرد صحیح	145	68	2026-07-16	submitted	\N	\N	79ae98b9-5d3a-4320-a521-d822ee0f81cc	2026-07-21 11:45:44.744086+00	2026-07-21 11:45:44.744086+00
582b48ec-cec0-4e4b-a7d4-cbfd51751f0f	751f3611-30e2-4cef-beff-236296ec6aee	09bab356-ca7d-4f2b-a863-5ec4bcad25ca	تست و اطمینان از عملکرد صحیح	108	100	2026-07-16	submitted	\N	\N	f8baa091-b3b3-49d9-86e5-bd18d81c30bf	2026-07-21 11:45:44.744086+00	2026-07-21 11:45:44.744086+00
582b48ec-cec0-4e4b-a7d4-cbfd51751f0f	2a63d37b-4adb-47bf-8f3a-38c80fe7e01d	de505605-7889-4573-8969-c65f885903c4	پیاده‌سازی بخش اصلی	190	26	2026-07-16	approved	09bab356-ca7d-4f2b-a863-5ec4bcad25ca	\N	46183c9a-bcb8-445d-94cc-6c72fe4d6762	2026-07-21 11:45:44.744086+00	2026-07-21 11:45:44.744086+00
582b48ec-cec0-4e4b-a7d4-cbfd51751f0f	fc5ee494-d6e3-4893-a066-ce7f46c902bd	28996900-cff9-4923-bdf4-33c0c602bda7	پیاده‌سازی بخش اصلی	171	22	2026-07-03	approved	09bab356-ca7d-4f2b-a863-5ec4bcad25ca	\N	77fb158a-f4a4-4199-8bed-328c26c3a305	2026-07-21 11:45:44.744086+00	2026-07-21 11:45:44.744086+00
582b48ec-cec0-4e4b-a7d4-cbfd51751f0f	fc5ee494-d6e3-4893-a066-ce7f46c902bd	28996900-cff9-4923-bdf4-33c0c602bda7	تست و اطمینان از عملکرد صحیح	206	78	2026-07-05	approved	09bab356-ca7d-4f2b-a863-5ec4bcad25ca	\N	8f7549dd-91ef-4830-8721-30f3d06410cd	2026-07-21 11:45:44.744086+00	2026-07-21 11:45:44.744086+00
582b48ec-cec0-4e4b-a7d4-cbfd51751f0f	fc5ee494-d6e3-4893-a066-ce7f46c902bd	28996900-cff9-4923-bdf4-33c0c602bda7	پیاده‌سازی بخش اصلی	103	87	2026-07-11	approved	09bab356-ca7d-4f2b-a863-5ec4bcad25ca	\N	32617e50-7046-4eb2-a79e-69b41a85c947	2026-07-21 11:45:44.744086+00	2026-07-21 11:45:44.744086+00
582b48ec-cec0-4e4b-a7d4-cbfd51751f0f	56b3bd80-b324-4b80-8bd3-754b4053daca	e6f6d74c-28cb-4ed3-98b6-6b15a7e57e23	پیاده‌سازی بخش اصلی	97	40	2026-07-06	approved	09bab356-ca7d-4f2b-a863-5ec4bcad25ca	\N	4a2378c3-9f27-4a7d-9ea4-b4392efecbc3	2026-07-21 11:45:44.744086+00	2026-07-21 11:45:44.744086+00
582b48ec-cec0-4e4b-a7d4-cbfd51751f0f	56b3bd80-b324-4b80-8bd3-754b4053daca	e6f6d74c-28cb-4ed3-98b6-6b15a7e57e23	تست و اطمینان از عملکرد صحیح	59	74	2026-07-08	approved	09bab356-ca7d-4f2b-a863-5ec4bcad25ca	\N	8b9263ed-0e8a-49c6-b88c-af0f8e0dd6b7	2026-07-21 11:45:44.744086+00	2026-07-21 11:45:44.744086+00
582b48ec-cec0-4e4b-a7d4-cbfd51751f0f	56b3bd80-b324-4b80-8bd3-754b4053daca	e6f6d74c-28cb-4ed3-98b6-6b15a7e57e23	پیاده‌سازی بخش اصلی	98	72	2026-07-10	approved	09bab356-ca7d-4f2b-a863-5ec4bcad25ca	\N	fe02b8fe-3c9b-4c6c-9a7b-511c88b0e322	2026-07-21 11:45:44.744086+00	2026-07-21 11:45:44.744086+00
582b48ec-cec0-4e4b-a7d4-cbfd51751f0f	56b3bd80-b324-4b80-8bd3-754b4053daca	e6f6d74c-28cb-4ed3-98b6-6b15a7e57e23	پیشرفت اولیه و بررسی نیازمندی‌ها	72	100	2026-07-09	approved	09bab356-ca7d-4f2b-a863-5ec4bcad25ca	\N	3645026c-5c36-43c2-902e-6ffebc18f924	2026-07-21 11:45:44.744086+00	2026-07-21 11:45:44.744086+00
582b48ec-cec0-4e4b-a7d4-cbfd51751f0f	19770ef2-249c-499c-91cd-b8d9c9335130	de505605-7889-4573-8969-c65f885903c4	پیشرفت اولیه و بررسی نیازمندی‌ها	149	29	2026-06-24	approved	09bab356-ca7d-4f2b-a863-5ec4bcad25ca	\N	72647957-9a12-4176-ba0c-9e240230e885	2026-07-21 11:45:44.744086+00	2026-07-21 11:45:44.744086+00
582b48ec-cec0-4e4b-a7d4-cbfd51751f0f	19770ef2-249c-499c-91cd-b8d9c9335130	de505605-7889-4573-8969-c65f885903c4	رفع اشکالات و بازبینی	158	74	2026-06-28	approved	09bab356-ca7d-4f2b-a863-5ec4bcad25ca	\N	b6c122a8-4882-426b-a2d9-fa92e5e5ca29	2026-07-21 11:45:44.744086+00	2026-07-21 11:45:44.744086+00
582b48ec-cec0-4e4b-a7d4-cbfd51751f0f	19770ef2-249c-499c-91cd-b8d9c9335130	de505605-7889-4573-8969-c65f885903c4	تست و اطمینان از عملکرد صحیح	50	100	2026-07-02	approved	09bab356-ca7d-4f2b-a863-5ec4bcad25ca	\N	e964de42-889f-4987-a6fe-6ad1bf357fbe	2026-07-21 11:45:44.744086+00	2026-07-21 11:45:44.744086+00
582b48ec-cec0-4e4b-a7d4-cbfd51751f0f	277cdf04-6d7c-484a-9891-68d6f9099ad6	de505605-7889-4573-8969-c65f885903c4	رفع اشکالات و بازبینی	184	28	2026-07-16	approved	09bab356-ca7d-4f2b-a863-5ec4bcad25ca	\N	bf07c59f-1dc8-4440-aff6-41341bb21aae	2026-07-21 11:45:44.744086+00	2026-07-21 11:45:44.744086+00
582b48ec-cec0-4e4b-a7d4-cbfd51751f0f	ccde4e50-a8f7-4e96-a612-c4c2d0fa43e7	e6f6d74c-28cb-4ed3-98b6-6b15a7e57e23	پیاده‌سازی بخش اصلی	202	38	2026-07-16	approved	09bab356-ca7d-4f2b-a863-5ec4bcad25ca	\N	8c9eebd9-5480-4f94-bac0-6afa40a8439a	2026-07-21 11:45:44.744086+00	2026-07-21 11:45:44.744086+00
582b48ec-cec0-4e4b-a7d4-cbfd51751f0f	645d22cb-0bf0-4f46-a52c-c07e5a397fec	e6f6d74c-28cb-4ed3-98b6-6b15a7e57e23	مستندسازی و نهایی‌سازی	40	25	2026-06-20	approved	09bab356-ca7d-4f2b-a863-5ec4bcad25ca	\N	19c3b494-1f8f-4aaf-bfd5-08479cc2fabd	2026-07-21 11:45:44.744086+00	2026-07-21 11:45:44.744086+00
582b48ec-cec0-4e4b-a7d4-cbfd51751f0f	b4b76783-0815-4f2b-a838-6de2bf969814	2ea22145-8b4c-4e52-84fb-acb66c94b186	پیاده‌سازی بخش اصلی	179	33	2026-07-16	submitted	\N	\N	392aab3f-5386-4c86-9138-a60a798e7bc7	2026-07-21 11:45:44.744086+00	2026-07-21 11:45:44.744086+00
582b48ec-cec0-4e4b-a7d4-cbfd51751f0f	b4b76783-0815-4f2b-a838-6de2bf969814	2ea22145-8b4c-4e52-84fb-acb66c94b186	تست و اطمینان از عملکرد صحیح	119	66	2026-07-16	submitted	\N	\N	b18c4d39-965f-4d31-a0f1-b2cb52e86890	2026-07-21 11:45:44.744086+00	2026-07-21 11:45:44.744086+00
582b48ec-cec0-4e4b-a7d4-cbfd51751f0f	b4b76783-0815-4f2b-a838-6de2bf969814	2ea22145-8b4c-4e52-84fb-acb66c94b186	پیشرفت اولیه و بررسی نیازمندی‌ها	71	90	2026-07-16	approved	09bab356-ca7d-4f2b-a863-5ec4bcad25ca	\N	8838bd61-204a-4570-85d9-7b759ce247e5	2026-07-21 11:45:44.744086+00	2026-07-21 11:45:44.744086+00
582b48ec-cec0-4e4b-a7d4-cbfd51751f0f	b4b76783-0815-4f2b-a838-6de2bf969814	2ea22145-8b4c-4e52-84fb-acb66c94b186	رفع اشکالات و بازبینی	199	100	2026-07-16	approved	09bab356-ca7d-4f2b-a863-5ec4bcad25ca	\N	90232f33-ba65-4077-b4ab-4d24d1111908	2026-07-21 11:45:44.744086+00	2026-07-21 11:45:44.744086+00
582b48ec-cec0-4e4b-a7d4-cbfd51751f0f	c6451582-e82d-4670-81ee-694d8f4c0a1b	2ea22145-8b4c-4e52-84fb-acb66c94b186	پیشرفت اولیه و بررسی نیازمندی‌ها	110	28	2026-07-03	approved	09bab356-ca7d-4f2b-a863-5ec4bcad25ca	\N	3572d194-ea1d-4b79-a6d8-7f8fe330892f	2026-07-21 11:45:44.744086+00	2026-07-21 11:45:44.744086+00
582b48ec-cec0-4e4b-a7d4-cbfd51751f0f	283aebdb-c7c5-4f2e-8a1d-99b2a2d834ec	09bab356-ca7d-4f2b-a863-5ec4bcad25ca	تست و اطمینان از عملکرد صحیح	161	20	2026-07-16	approved	09bab356-ca7d-4f2b-a863-5ec4bcad25ca	\N	cd5875f1-82c0-42db-8f52-80c1b4dffd24	2026-07-21 11:45:44.744086+00	2026-07-21 11:45:44.744086+00
582b48ec-cec0-4e4b-a7d4-cbfd51751f0f	283aebdb-c7c5-4f2e-8a1d-99b2a2d834ec	09bab356-ca7d-4f2b-a863-5ec4bcad25ca	تست و اطمینان از عملکرد صحیح	43	52	2026-07-16	approved	09bab356-ca7d-4f2b-a863-5ec4bcad25ca	\N	e823cd61-ac55-4f9e-bc2a-31c92fe25b19	2026-07-21 11:45:44.744086+00	2026-07-21 11:45:44.744086+00
582b48ec-cec0-4e4b-a7d4-cbfd51751f0f	283aebdb-c7c5-4f2e-8a1d-99b2a2d834ec	09bab356-ca7d-4f2b-a863-5ec4bcad25ca	مستندسازی و نهایی‌سازی	223	100	2026-07-16	approved	09bab356-ca7d-4f2b-a863-5ec4bcad25ca	\N	9903aa8e-2eb0-444c-b091-18f80b949b2d	2026-07-21 11:45:44.744086+00	2026-07-21 11:45:44.744086+00
582b48ec-cec0-4e4b-a7d4-cbfd51751f0f	9f7f9177-2361-4b5b-b67c-c081230681ab	9bee1760-d3cf-42e2-80de-a78b2be8c965	پیاده‌سازی بخش اصلی	98	37	2026-07-16	approved	09bab356-ca7d-4f2b-a863-5ec4bcad25ca	\N	8148bfa9-cff6-4180-b8b5-a66a81e0957b	2026-07-21 11:45:44.744086+00	2026-07-21 11:45:44.744086+00
582b48ec-cec0-4e4b-a7d4-cbfd51751f0f	9f7f9177-2361-4b5b-b67c-c081230681ab	9bee1760-d3cf-42e2-80de-a78b2be8c965	رفع اشکالات و بازبینی	142	70	2026-07-16	approved	09bab356-ca7d-4f2b-a863-5ec4bcad25ca	\N	f9b84009-db82-4247-a020-91847bae2705	2026-07-21 11:45:44.744086+00	2026-07-21 11:45:44.744086+00
582b48ec-cec0-4e4b-a7d4-cbfd51751f0f	9f7f9177-2361-4b5b-b67c-c081230681ab	9bee1760-d3cf-42e2-80de-a78b2be8c965	پیشرفت اولیه و بررسی نیازمندی‌ها	191	100	2026-07-16	approved	09bab356-ca7d-4f2b-a863-5ec4bcad25ca	\N	ddf22375-f3d4-4d46-b0f0-f626c1fde752	2026-07-21 11:45:44.744086+00	2026-07-21 11:45:44.744086+00
582b48ec-cec0-4e4b-a7d4-cbfd51751f0f	9f7f9177-2361-4b5b-b67c-c081230681ab	9bee1760-d3cf-42e2-80de-a78b2be8c965	پیاده‌سازی بخش اصلی	109	100	2026-07-16	approved	09bab356-ca7d-4f2b-a863-5ec4bcad25ca	\N	12b7589c-d379-4ff5-8aaf-7b0795f2b7d0	2026-07-21 11:45:44.744086+00	2026-07-21 11:45:44.744086+00
582b48ec-cec0-4e4b-a7d4-cbfd51751f0f	b2fb7128-ace3-4367-8d30-8ce55edb660e	e6f6d74c-28cb-4ed3-98b6-6b15a7e57e23	پیشرفت اولیه و بررسی نیازمندی‌ها	87	23	2026-07-16	approved	09bab356-ca7d-4f2b-a863-5ec4bcad25ca	\N	7ecac3f1-4b51-4563-bbcb-bdfca4ee29fb	2026-07-21 11:45:44.744086+00	2026-07-21 11:45:44.744086+00
582b48ec-cec0-4e4b-a7d4-cbfd51751f0f	5e6cfd59-67ea-40f7-b670-e8d0f3b3793e	28996900-cff9-4923-bdf4-33c0c602bda7	پیاده‌سازی بخش اصلی	157	29	2026-07-16	approved	09bab356-ca7d-4f2b-a863-5ec4bcad25ca	\N	a86260ab-b7fd-463f-8b3f-b15f61b74822	2026-07-21 11:45:44.744086+00	2026-07-21 11:45:44.744086+00
582b48ec-cec0-4e4b-a7d4-cbfd51751f0f	5e6cfd59-67ea-40f7-b670-e8d0f3b3793e	28996900-cff9-4923-bdf4-33c0c602bda7	تست و اطمینان از عملکرد صحیح	150	54	2026-07-16	approved	09bab356-ca7d-4f2b-a863-5ec4bcad25ca	\N	b9799842-d79c-4acc-97ea-1ffa7c3e6a34	2026-07-21 11:45:44.744086+00	2026-07-21 11:45:44.744086+00
582b48ec-cec0-4e4b-a7d4-cbfd51751f0f	5e6cfd59-67ea-40f7-b670-e8d0f3b3793e	28996900-cff9-4923-bdf4-33c0c602bda7	تست و اطمینان از عملکرد صحیح	78	100	2026-07-16	approved	09bab356-ca7d-4f2b-a863-5ec4bcad25ca	\N	c4df5f8a-7f65-43c2-bfa3-47682341923e	2026-07-21 11:45:44.744086+00	2026-07-21 11:45:44.744086+00
582b48ec-cec0-4e4b-a7d4-cbfd51751f0f	5e6cfd59-67ea-40f7-b670-e8d0f3b3793e	28996900-cff9-4923-bdf4-33c0c602bda7	رفع اشکالات و بازبینی	227	100	2026-07-16	submitted	\N	\N	b439c119-a1a8-403b-ae22-3d0cea20d94a	2026-07-21 11:45:44.744086+00	2026-07-21 11:45:44.744086+00
582b48ec-cec0-4e4b-a7d4-cbfd51751f0f	d9390e2e-da2a-4ecf-9c3e-4f564a940ea4	28996900-cff9-4923-bdf4-33c0c602bda7	پیشرفت اولیه و بررسی نیازمندی‌ها	102	29	2026-07-14	approved	09bab356-ca7d-4f2b-a863-5ec4bcad25ca	\N	0ac6befe-e6be-4eb4-935f-e51b084b0b3f	2026-07-21 11:45:44.744086+00	2026-07-21 11:45:44.744086+00
582b48ec-cec0-4e4b-a7d4-cbfd51751f0f	d9390e2e-da2a-4ecf-9c3e-4f564a940ea4	28996900-cff9-4923-bdf4-33c0c602bda7	پیاده‌سازی بخش اصلی	144	74	2026-07-16	approved	09bab356-ca7d-4f2b-a863-5ec4bcad25ca	\N	58baa36d-816b-4828-bfb8-27b33eab3e92	2026-07-21 11:45:44.744086+00	2026-07-21 11:45:44.744086+00
582b48ec-cec0-4e4b-a7d4-cbfd51751f0f	d9390e2e-da2a-4ecf-9c3e-4f564a940ea4	28996900-cff9-4923-bdf4-33c0c602bda7	رفع اشکالات و بازبینی	115	100	2026-07-16	approved	09bab356-ca7d-4f2b-a863-5ec4bcad25ca	\N	ac0cbba0-6072-451f-ab7c-9e0c0c6c8b14	2026-07-21 11:45:44.744086+00	2026-07-21 11:45:44.744086+00
582b48ec-cec0-4e4b-a7d4-cbfd51751f0f	81d31027-d700-4a4d-9add-7fa1a2aaf879	09bab356-ca7d-4f2b-a863-5ec4bcad25ca	پیاده‌سازی بخش اصلی	208	27	2026-06-17	submitted	\N	\N	f621c82a-e498-439d-87ca-7ea4d2b0280c	2026-07-21 11:45:44.744086+00	2026-07-21 11:45:44.744086+00
582b48ec-cec0-4e4b-a7d4-cbfd51751f0f	81d31027-d700-4a4d-9add-7fa1a2aaf879	09bab356-ca7d-4f2b-a863-5ec4bcad25ca	تست و اطمینان از عملکرد صحیح	41	60	2026-06-21	approved	09bab356-ca7d-4f2b-a863-5ec4bcad25ca	\N	091333d1-52aa-42c3-9730-a158f9bd3bcf	2026-07-21 11:45:44.744086+00	2026-07-21 11:45:44.744086+00
582b48ec-cec0-4e4b-a7d4-cbfd51751f0f	81d31027-d700-4a4d-9add-7fa1a2aaf879	09bab356-ca7d-4f2b-a863-5ec4bcad25ca	تست و اطمینان از عملکرد صحیح	128	100	2026-06-25	submitted	\N	\N	ebcf91e6-851c-4f5c-97c8-4982859daf73	2026-07-21 11:45:44.744086+00	2026-07-21 11:45:44.744086+00
582b48ec-cec0-4e4b-a7d4-cbfd51751f0f	81d31027-d700-4a4d-9add-7fa1a2aaf879	09bab356-ca7d-4f2b-a863-5ec4bcad25ca	پیشرفت اولیه و بررسی نیازمندی‌ها	62	100	2026-06-23	approved	09bab356-ca7d-4f2b-a863-5ec4bcad25ca	\N	cc52d913-0561-4f87-a186-ca71ff5ac8f6	2026-07-21 11:45:44.744086+00	2026-07-21 11:45:44.744086+00
582b48ec-cec0-4e4b-a7d4-cbfd51751f0f	e5b1cc9d-2d23-4c68-aff6-c98712d1c055	09bab356-ca7d-4f2b-a863-5ec4bcad25ca	تست و اطمینان از عملکرد صحیح	55	36	2026-07-16	approved	09bab356-ca7d-4f2b-a863-5ec4bcad25ca	\N	ecd0d6b8-65b8-4018-94ed-3587ccf4cb95	2026-07-21 11:45:44.744086+00	2026-07-21 11:45:44.744086+00
582b48ec-cec0-4e4b-a7d4-cbfd51751f0f	e5b1cc9d-2d23-4c68-aff6-c98712d1c055	09bab356-ca7d-4f2b-a863-5ec4bcad25ca	پیشرفت اولیه و بررسی نیازمندی‌ها	214	48	2026-07-16	approved	09bab356-ca7d-4f2b-a863-5ec4bcad25ca	\N	ac818d37-c074-47c9-879c-03ab4711bf72	2026-07-21 11:45:44.744086+00	2026-07-21 11:45:44.744086+00
582b48ec-cec0-4e4b-a7d4-cbfd51751f0f	e5b1cc9d-2d23-4c68-aff6-c98712d1c055	09bab356-ca7d-4f2b-a863-5ec4bcad25ca	پیاده‌سازی بخش اصلی	49	100	2026-07-16	approved	09bab356-ca7d-4f2b-a863-5ec4bcad25ca	\N	109ffa15-5125-4609-8313-a0e9701dc66f	2026-07-21 11:45:44.744086+00	2026-07-21 11:45:44.744086+00
582b48ec-cec0-4e4b-a7d4-cbfd51751f0f	11d3443b-2a4a-44d8-a961-27fa543dc046	09bab356-ca7d-4f2b-a863-5ec4bcad25ca	مستندسازی و نهایی‌سازی	207	32	2026-07-16	approved	09bab356-ca7d-4f2b-a863-5ec4bcad25ca	\N	6e87e4e1-366c-441d-8604-6d1094700907	2026-07-21 11:45:44.744086+00	2026-07-21 11:45:44.744086+00
582b48ec-cec0-4e4b-a7d4-cbfd51751f0f	11d3443b-2a4a-44d8-a961-27fa543dc046	09bab356-ca7d-4f2b-a863-5ec4bcad25ca	رفع اشکالات و بازبینی	202	74	2026-07-16	approved	09bab356-ca7d-4f2b-a863-5ec4bcad25ca	\N	551708f7-589f-4b2a-977e-3ad343dc863b	2026-07-21 11:45:44.744086+00	2026-07-21 11:45:44.744086+00
582b48ec-cec0-4e4b-a7d4-cbfd51751f0f	11d3443b-2a4a-44d8-a961-27fa543dc046	09bab356-ca7d-4f2b-a863-5ec4bcad25ca	رفع اشکالات و بازبینی	190	100	2026-07-16	approved	09bab356-ca7d-4f2b-a863-5ec4bcad25ca	\N	e4f1a09f-9562-4741-bbb9-30b81d5c38fb	2026-07-21 11:45:44.744086+00	2026-07-21 11:45:44.744086+00
582b48ec-cec0-4e4b-a7d4-cbfd51751f0f	d3d54802-a6af-4486-9a5f-87b4a438e2d8	2ea22145-8b4c-4e52-84fb-acb66c94b186	پیاده‌سازی بخش اصلی	191	29	2026-07-16	approved	09bab356-ca7d-4f2b-a863-5ec4bcad25ca	\N	2e43ce74-6a9a-42f6-a689-ffc7f9808b61	2026-07-21 11:45:44.744086+00	2026-07-21 11:45:44.744086+00
582b48ec-cec0-4e4b-a7d4-cbfd51751f0f	3f52edb5-b21c-4bc7-be04-9bec0c15832c	09bab356-ca7d-4f2b-a863-5ec4bcad25ca	تست و اطمینان از عملکرد صحیح	55	40	2026-07-13	approved	09bab356-ca7d-4f2b-a863-5ec4bcad25ca	\N	711e76d1-60ff-4d93-9596-70daacde6b70	2026-07-21 11:45:44.744086+00	2026-07-21 11:45:44.744086+00
582b48ec-cec0-4e4b-a7d4-cbfd51751f0f	3f52edb5-b21c-4bc7-be04-9bec0c15832c	09bab356-ca7d-4f2b-a863-5ec4bcad25ca	تست و اطمینان از عملکرد صحیح	72	58	2026-07-14	approved	09bab356-ca7d-4f2b-a863-5ec4bcad25ca	\N	95de9662-56b1-4907-ad92-46cb35223ea3	2026-07-21 11:45:44.744086+00	2026-07-21 11:45:44.744086+00
582b48ec-cec0-4e4b-a7d4-cbfd51751f0f	9c00f60a-68e5-4e5d-8c9c-77ed950aa788	de505605-7889-4573-8969-c65f885903c4	رفع اشکالات و بازبینی	233	21	2026-07-11	approved	09bab356-ca7d-4f2b-a863-5ec4bcad25ca	\N	9afe29c0-becb-4076-879b-8aa9b733c30f	2026-07-21 11:45:44.744086+00	2026-07-21 11:45:44.744086+00
582b48ec-cec0-4e4b-a7d4-cbfd51751f0f	b426e3c3-edf9-4912-9916-bb70f2048791	e6f6d74c-28cb-4ed3-98b6-6b15a7e57e23	رفع اشکالات و بازبینی	140	24	2026-07-13	approved	09bab356-ca7d-4f2b-a863-5ec4bcad25ca	\N	e7b4b610-072a-409e-a9f6-49ca4ee1f231	2026-07-21 11:45:44.744086+00	2026-07-21 11:45:44.744086+00
582b48ec-cec0-4e4b-a7d4-cbfd51751f0f	b426e3c3-edf9-4912-9916-bb70f2048791	e6f6d74c-28cb-4ed3-98b6-6b15a7e57e23	مستندسازی و نهایی‌سازی	135	76	2026-07-15	approved	09bab356-ca7d-4f2b-a863-5ec4bcad25ca	\N	023b8599-ac50-49e7-ae94-f2d09f5f0d83	2026-07-21 11:45:44.744086+00	2026-07-21 11:45:44.744086+00
582b48ec-cec0-4e4b-a7d4-cbfd51751f0f	b426e3c3-edf9-4912-9916-bb70f2048791	e6f6d74c-28cb-4ed3-98b6-6b15a7e57e23	پیاده‌سازی بخش اصلی	74	66	2026-07-16	approved	09bab356-ca7d-4f2b-a863-5ec4bcad25ca	\N	04b1b76f-cbbe-4931-8716-01cf3aafbcf8	2026-07-21 11:45:44.744086+00	2026-07-21 11:45:44.744086+00
582b48ec-cec0-4e4b-a7d4-cbfd51751f0f	03592919-9dad-4261-bfe2-8fb533b72dbc	09bab356-ca7d-4f2b-a863-5ec4bcad25ca	تست و اطمینان از عملکرد صحیح	179	24	2026-07-16	approved	09bab356-ca7d-4f2b-a863-5ec4bcad25ca	\N	e7557e7b-b42f-4381-9a9e-da33ab93ec8c	2026-07-21 11:45:44.744086+00	2026-07-21 11:45:44.744086+00
582b48ec-cec0-4e4b-a7d4-cbfd51751f0f	03592919-9dad-4261-bfe2-8fb533b72dbc	09bab356-ca7d-4f2b-a863-5ec4bcad25ca	تست و اطمینان از عملکرد صحیح	193	56	2026-07-16	approved	09bab356-ca7d-4f2b-a863-5ec4bcad25ca	\N	f9355812-a5f1-4a68-96a9-805bce84e982	2026-07-21 11:45:44.744086+00	2026-07-21 11:45:44.744086+00
582b48ec-cec0-4e4b-a7d4-cbfd51751f0f	03592919-9dad-4261-bfe2-8fb533b72dbc	09bab356-ca7d-4f2b-a863-5ec4bcad25ca	رفع اشکالات و بازبینی	200	60	2026-07-16	approved	09bab356-ca7d-4f2b-a863-5ec4bcad25ca	\N	b52ebfdb-ee74-4cd1-887b-96e62d9be4fd	2026-07-21 11:45:44.744086+00	2026-07-21 11:45:44.744086+00
582b48ec-cec0-4e4b-a7d4-cbfd51751f0f	03592919-9dad-4261-bfe2-8fb533b72dbc	09bab356-ca7d-4f2b-a863-5ec4bcad25ca	رفع اشکالات و بازبینی	203	100	2026-07-16	approved	09bab356-ca7d-4f2b-a863-5ec4bcad25ca	\N	96ef1961-a1dc-4fea-9e90-a7d00ac7454c	2026-07-21 11:45:44.744086+00	2026-07-21 11:45:44.744086+00
582b48ec-cec0-4e4b-a7d4-cbfd51751f0f	05c9ebc1-a752-43b6-a9f8-b5cc683790b1	9bee1760-d3cf-42e2-80de-a78b2be8c965	رفع اشکالات و بازبینی	180	29	2026-07-16	approved	09bab356-ca7d-4f2b-a863-5ec4bcad25ca	\N	849c2594-b658-4058-8b7a-f273a67c6c4f	2026-07-21 11:45:44.744086+00	2026-07-21 11:45:44.744086+00
582b48ec-cec0-4e4b-a7d4-cbfd51751f0f	05c9ebc1-a752-43b6-a9f8-b5cc683790b1	9bee1760-d3cf-42e2-80de-a78b2be8c965	تست و اطمینان از عملکرد صحیح	107	52	2026-07-16	approved	09bab356-ca7d-4f2b-a863-5ec4bcad25ca	\N	e6db90ae-7db5-4b85-86e1-fb0c09e6866d	2026-07-21 11:45:44.744086+00	2026-07-21 11:45:44.744086+00
582b48ec-cec0-4e4b-a7d4-cbfd51751f0f	468b9a94-5841-4f14-90d1-a3d61e36b24c	0885409c-d2f4-4296-88c0-d8ac1df6a7e5	پیشرفت اولیه و بررسی نیازمندی‌ها	90	32	2026-07-16	approved	09bab356-ca7d-4f2b-a863-5ec4bcad25ca	\N	a97b7910-ef00-4a48-8a37-343c0ee996bc	2026-07-21 11:45:44.744086+00	2026-07-21 11:45:44.744086+00
582b48ec-cec0-4e4b-a7d4-cbfd51751f0f	468b9a94-5841-4f14-90d1-a3d61e36b24c	0885409c-d2f4-4296-88c0-d8ac1df6a7e5	مستندسازی و نهایی‌سازی	105	58	2026-07-16	approved	09bab356-ca7d-4f2b-a863-5ec4bcad25ca	\N	6d007556-f8ca-48c2-9fcd-934222749061	2026-07-21 11:45:44.744086+00	2026-07-21 11:45:44.744086+00
582b48ec-cec0-4e4b-a7d4-cbfd51751f0f	468b9a94-5841-4f14-90d1-a3d61e36b24c	0885409c-d2f4-4296-88c0-d8ac1df6a7e5	تست و اطمینان از عملکرد صحیح	100	60	2026-07-16	approved	09bab356-ca7d-4f2b-a863-5ec4bcad25ca	\N	98ec7b86-6bc1-4967-8073-2f3fe172d357	2026-07-21 11:45:44.744086+00	2026-07-21 11:45:44.744086+00
582b48ec-cec0-4e4b-a7d4-cbfd51751f0f	468b9a94-5841-4f14-90d1-a3d61e36b24c	0885409c-d2f4-4296-88c0-d8ac1df6a7e5	مستندسازی و نهایی‌سازی	220	100	2026-07-16	approved	09bab356-ca7d-4f2b-a863-5ec4bcad25ca	\N	0ca7c7a6-8e48-444a-b7e7-412d6843bca1	2026-07-21 11:45:44.744086+00	2026-07-21 11:45:44.744086+00
582b48ec-cec0-4e4b-a7d4-cbfd51751f0f	5cdf5576-aba3-4aec-9f47-3d9fb6639fc8	e6f6d74c-28cb-4ed3-98b6-6b15a7e57e23	رفع اشکالات و بازبینی	86	40	2026-06-29	approved	09bab356-ca7d-4f2b-a863-5ec4bcad25ca	\N	a8dc5b09-24c7-426a-b132-7cba9a70218a	2026-07-21 11:45:44.744086+00	2026-07-21 11:45:44.744086+00
582b48ec-cec0-4e4b-a7d4-cbfd51751f0f	5cdf5576-aba3-4aec-9f47-3d9fb6639fc8	e6f6d74c-28cb-4ed3-98b6-6b15a7e57e23	پیاده‌سازی بخش اصلی	190	46	2026-07-01	approved	09bab356-ca7d-4f2b-a863-5ec4bcad25ca	\N	fffbd17b-cea0-4207-928d-88d019e6c38d	2026-07-21 11:45:44.744086+00	2026-07-21 11:45:44.744086+00
582b48ec-cec0-4e4b-a7d4-cbfd51751f0f	5cdf5576-aba3-4aec-9f47-3d9fb6639fc8	e6f6d74c-28cb-4ed3-98b6-6b15a7e57e23	تست و اطمینان از عملکرد صحیح	38	100	2026-07-01	approved	09bab356-ca7d-4f2b-a863-5ec4bcad25ca	\N	faf546ce-293e-4a12-a2f8-e07f160e323b	2026-07-21 11:45:44.744086+00	2026-07-21 11:45:44.744086+00
582b48ec-cec0-4e4b-a7d4-cbfd51751f0f	d4b7c0fd-dfe1-4ebb-8bc9-c5a2c950869c	e6f6d74c-28cb-4ed3-98b6-6b15a7e57e23	رفع اشکالات و بازبینی	113	33	2026-06-23	approved	09bab356-ca7d-4f2b-a863-5ec4bcad25ca	\N	7b1eccc4-7d4d-446b-87de-29c6e413580a	2026-07-21 11:45:44.744086+00	2026-07-21 11:45:44.744086+00
582b48ec-cec0-4e4b-a7d4-cbfd51751f0f	d4b7c0fd-dfe1-4ebb-8bc9-c5a2c950869c	e6f6d74c-28cb-4ed3-98b6-6b15a7e57e23	مستندسازی و نهایی‌سازی	123	72	2026-06-25	approved	09bab356-ca7d-4f2b-a863-5ec4bcad25ca	\N	b4dea3e4-96d5-412f-b138-3b0ae3c7103e	2026-07-21 11:45:44.744086+00	2026-07-21 11:45:44.744086+00
582b48ec-cec0-4e4b-a7d4-cbfd51751f0f	d4b7c0fd-dfe1-4ebb-8bc9-c5a2c950869c	e6f6d74c-28cb-4ed3-98b6-6b15a7e57e23	رفع اشکالات و بازبینی	153	87	2026-06-29	submitted	\N	\N	86aca1cc-66d5-49f9-a4d5-d6106635f1bd	2026-07-21 11:45:44.744086+00	2026-07-21 11:45:44.744086+00
582b48ec-cec0-4e4b-a7d4-cbfd51751f0f	512a1264-ef04-49cb-8690-0cbcaa7bc0fe	09bab356-ca7d-4f2b-a863-5ec4bcad25ca	پیشرفت اولیه و بررسی نیازمندی‌ها	66	27	2026-07-16	approved	09bab356-ca7d-4f2b-a863-5ec4bcad25ca	\N	c0f3efde-3719-4410-8fa6-75502790fd77	2026-07-21 11:45:44.744086+00	2026-07-21 11:45:44.744086+00
582b48ec-cec0-4e4b-a7d4-cbfd51751f0f	512a1264-ef04-49cb-8690-0cbcaa7bc0fe	09bab356-ca7d-4f2b-a863-5ec4bcad25ca	مستندسازی و نهایی‌سازی	123	44	2026-07-16	submitted	\N	\N	a22324ba-1599-4ac1-8ee6-541db742c805	2026-07-21 11:45:44.744086+00	2026-07-21 11:45:44.744086+00
582b48ec-cec0-4e4b-a7d4-cbfd51751f0f	512a1264-ef04-49cb-8690-0cbcaa7bc0fe	09bab356-ca7d-4f2b-a863-5ec4bcad25ca	مستندسازی و نهایی‌سازی	61	100	2026-07-16	approved	09bab356-ca7d-4f2b-a863-5ec4bcad25ca	\N	e43d4155-134b-4479-8e03-5a28bd97dd0e	2026-07-21 11:45:44.744086+00	2026-07-21 11:45:44.744086+00
582b48ec-cec0-4e4b-a7d4-cbfd51751f0f	af66944f-bb48-4d46-a5c1-eb8c8fc92fa8	e6f6d74c-28cb-4ed3-98b6-6b15a7e57e23	مستندسازی و نهایی‌سازی	127	40	2026-07-01	approved	09bab356-ca7d-4f2b-a863-5ec4bcad25ca	\N	e236987f-9868-45b9-b2ba-f8e6fcc1fa09	2026-07-21 11:45:44.744086+00	2026-07-21 11:45:44.744086+00
582b48ec-cec0-4e4b-a7d4-cbfd51751f0f	af66944f-bb48-4d46-a5c1-eb8c8fc92fa8	e6f6d74c-28cb-4ed3-98b6-6b15a7e57e23	پیشرفت اولیه و بررسی نیازمندی‌ها	202	54	2026-07-04	approved	09bab356-ca7d-4f2b-a863-5ec4bcad25ca	\N	7253fe9f-e38a-47ae-9800-86b1b2a5f6b8	2026-07-21 11:45:44.744086+00	2026-07-21 11:45:44.744086+00
582b48ec-cec0-4e4b-a7d4-cbfd51751f0f	af66944f-bb48-4d46-a5c1-eb8c8fc92fa8	e6f6d74c-28cb-4ed3-98b6-6b15a7e57e23	پیشرفت اولیه و بررسی نیازمندی‌ها	188	100	2026-07-09	approved	09bab356-ca7d-4f2b-a863-5ec4bcad25ca	\N	98cfe3ec-7295-43f3-a373-3e51a4db30b5	2026-07-21 11:45:44.744086+00	2026-07-21 11:45:44.744086+00
582b48ec-cec0-4e4b-a7d4-cbfd51751f0f	a549013b-72a7-4bda-8421-6fa1e35b1bfa	0885409c-d2f4-4296-88c0-d8ac1df6a7e5	پیشرفت اولیه و بررسی نیازمندی‌ها	192	34	2026-07-16	approved	09bab356-ca7d-4f2b-a863-5ec4bcad25ca	\N	a180da12-019c-4d9d-b72a-83933c597cb5	2026-07-21 11:45:44.744086+00	2026-07-21 11:45:44.744086+00
582b48ec-cec0-4e4b-a7d4-cbfd51751f0f	a549013b-72a7-4bda-8421-6fa1e35b1bfa	0885409c-d2f4-4296-88c0-d8ac1df6a7e5	تست و اطمینان از عملکرد صحیح	59	48	2026-07-16	approved	09bab356-ca7d-4f2b-a863-5ec4bcad25ca	\N	14c67eb9-fe83-4ef1-93f7-2b3688c56222	2026-07-21 11:45:44.744086+00	2026-07-21 11:45:44.744086+00
582b48ec-cec0-4e4b-a7d4-cbfd51751f0f	a549013b-72a7-4bda-8421-6fa1e35b1bfa	0885409c-d2f4-4296-88c0-d8ac1df6a7e5	پیشرفت اولیه و بررسی نیازمندی‌ها	107	100	2026-07-16	approved	09bab356-ca7d-4f2b-a863-5ec4bcad25ca	\N	b367cf45-7ebf-4bf3-8743-7169faf29d22	2026-07-21 11:45:44.744086+00	2026-07-21 11:45:44.744086+00
582b48ec-cec0-4e4b-a7d4-cbfd51751f0f	e9cc45b0-b047-42b4-9568-d5f885949b47	2ea22145-8b4c-4e52-84fb-acb66c94b186	پیاده‌سازی بخش اصلی	167	24	2026-07-05	approved	09bab356-ca7d-4f2b-a863-5ec4bcad25ca	\N	86f9d254-4278-4c67-a98a-9d1f9958bf5a	2026-07-21 11:45:44.744086+00	2026-07-21 11:45:44.744086+00
582b48ec-cec0-4e4b-a7d4-cbfd51751f0f	15608f39-ede1-4501-b5b6-7f6687356c0f	9bee1760-d3cf-42e2-80de-a78b2be8c965	رفع اشکالات و بازبینی	201	37	2026-07-16	approved	09bab356-ca7d-4f2b-a863-5ec4bcad25ca	\N	2ea4c4fe-f32f-4bb7-8ea7-21b88e325a2a	2026-07-21 11:45:44.744086+00	2026-07-21 11:45:44.744086+00
582b48ec-cec0-4e4b-a7d4-cbfd51751f0f	15608f39-ede1-4501-b5b6-7f6687356c0f	9bee1760-d3cf-42e2-80de-a78b2be8c965	مستندسازی و نهایی‌سازی	220	48	2026-07-16	approved	09bab356-ca7d-4f2b-a863-5ec4bcad25ca	\N	335a6bea-b2b8-4e16-928a-3db339b94485	2026-07-21 11:45:44.744086+00	2026-07-21 11:45:44.744086+00
582b48ec-cec0-4e4b-a7d4-cbfd51751f0f	15608f39-ede1-4501-b5b6-7f6687356c0f	9bee1760-d3cf-42e2-80de-a78b2be8c965	پیشرفت اولیه و بررسی نیازمندی‌ها	155	100	2026-07-16	approved	09bab356-ca7d-4f2b-a863-5ec4bcad25ca	\N	35efb80d-0d33-4814-b049-66d97ba1feee	2026-07-21 11:45:44.744086+00	2026-07-21 11:45:44.744086+00
582b48ec-cec0-4e4b-a7d4-cbfd51751f0f	15608f39-ede1-4501-b5b6-7f6687356c0f	9bee1760-d3cf-42e2-80de-a78b2be8c965	رفع اشکالات و بازبینی	38	100	2026-07-16	approved	09bab356-ca7d-4f2b-a863-5ec4bcad25ca	\N	b7d0a699-93f3-489b-8b96-9662aed9988d	2026-07-21 11:45:44.744086+00	2026-07-21 11:45:44.744086+00
582b48ec-cec0-4e4b-a7d4-cbfd51751f0f	0e60b1a7-c954-40fc-8556-ea732a4d5a8b	09bab356-ca7d-4f2b-a863-5ec4bcad25ca	تست و اطمینان از عملکرد صحیح	90	31	2026-07-16	approved	09bab356-ca7d-4f2b-a863-5ec4bcad25ca	\N	92970313-bc10-4a43-910d-b4c0c8d29af0	2026-07-21 11:45:44.744086+00	2026-07-21 11:45:44.744086+00
582b48ec-cec0-4e4b-a7d4-cbfd51751f0f	0e60b1a7-c954-40fc-8556-ea732a4d5a8b	09bab356-ca7d-4f2b-a863-5ec4bcad25ca	رفع اشکالات و بازبینی	169	80	2026-07-16	approved	09bab356-ca7d-4f2b-a863-5ec4bcad25ca	\N	eb6695b8-a26f-4189-acd5-b1313f8cd59c	2026-07-21 11:45:44.744086+00	2026-07-21 11:45:44.744086+00
582b48ec-cec0-4e4b-a7d4-cbfd51751f0f	7b9835a7-6465-47ba-9347-a41c4991609d	0885409c-d2f4-4296-88c0-d8ac1df6a7e5	پیاده‌سازی بخش اصلی	61	34	2026-07-16	approved	09bab356-ca7d-4f2b-a863-5ec4bcad25ca	\N	ace802d9-7be5-467e-bb6b-8fc2765183ad	2026-07-21 11:45:44.744086+00	2026-07-21 11:45:44.744086+00
582b48ec-cec0-4e4b-a7d4-cbfd51751f0f	7b9835a7-6465-47ba-9347-a41c4991609d	0885409c-d2f4-4296-88c0-d8ac1df6a7e5	مستندسازی و نهایی‌سازی	35	42	2026-07-16	approved	09bab356-ca7d-4f2b-a863-5ec4bcad25ca	\N	f2f593d3-3db0-432a-b51b-bec76bd6682a	2026-07-21 11:45:44.744086+00	2026-07-21 11:45:44.744086+00
582b48ec-cec0-4e4b-a7d4-cbfd51751f0f	7b9835a7-6465-47ba-9347-a41c4991609d	0885409c-d2f4-4296-88c0-d8ac1df6a7e5	پیاده‌سازی بخش اصلی	231	100	2026-07-16	approved	09bab356-ca7d-4f2b-a863-5ec4bcad25ca	\N	ebfd1b83-9c0c-40ff-b89e-de797c06f5fe	2026-07-21 11:45:44.744086+00	2026-07-21 11:45:44.744086+00
582b48ec-cec0-4e4b-a7d4-cbfd51751f0f	ac1723be-bec8-4f21-807a-31f55a9f1820	28996900-cff9-4923-bdf4-33c0c602bda7	مستندسازی و نهایی‌سازی	83	38	2026-06-20	approved	09bab356-ca7d-4f2b-a863-5ec4bcad25ca	\N	0f69d436-6f43-4730-8278-ca1c362aa920	2026-07-21 11:45:44.744086+00	2026-07-21 11:45:44.744086+00
582b48ec-cec0-4e4b-a7d4-cbfd51751f0f	ac1723be-bec8-4f21-807a-31f55a9f1820	28996900-cff9-4923-bdf4-33c0c602bda7	پیاده‌سازی بخش اصلی	114	48	2026-06-22	approved	09bab356-ca7d-4f2b-a863-5ec4bcad25ca	\N	b13c8419-c9d5-40c0-a693-e232e1d7d4fd	2026-07-21 11:45:44.744086+00	2026-07-21 11:45:44.744086+00
582b48ec-cec0-4e4b-a7d4-cbfd51751f0f	d6a4eaa2-2448-4681-bcb1-b6196f8e96af	2ea22145-8b4c-4e52-84fb-acb66c94b186	پیاده‌سازی بخش اصلی	63	37	2026-06-24	approved	09bab356-ca7d-4f2b-a863-5ec4bcad25ca	\N	943a697e-06f0-4948-a7d0-cff1d53b5f2a	2026-07-21 11:45:44.744086+00	2026-07-21 11:45:44.744086+00
582b48ec-cec0-4e4b-a7d4-cbfd51751f0f	11943d22-7b3b-45ac-9db1-cc7391944889	0885409c-d2f4-4296-88c0-d8ac1df6a7e5	پیشرفت اولیه و بررسی نیازمندی‌ها	199	20	2026-07-16	approved	09bab356-ca7d-4f2b-a863-5ec4bcad25ca	\N	102fd455-2bb4-454b-8baa-f1ebb0df6e71	2026-07-21 11:45:44.744086+00	2026-07-21 11:45:44.744086+00
582b48ec-cec0-4e4b-a7d4-cbfd51751f0f	11943d22-7b3b-45ac-9db1-cc7391944889	0885409c-d2f4-4296-88c0-d8ac1df6a7e5	پیشرفت اولیه و بررسی نیازمندی‌ها	121	54	2026-07-16	approved	09bab356-ca7d-4f2b-a863-5ec4bcad25ca	\N	2dd90349-6921-4a96-b533-c0207d2636f0	2026-07-21 11:45:44.744086+00	2026-07-21 11:45:44.744086+00
582b48ec-cec0-4e4b-a7d4-cbfd51751f0f	11943d22-7b3b-45ac-9db1-cc7391944889	0885409c-d2f4-4296-88c0-d8ac1df6a7e5	پیشرفت اولیه و بررسی نیازمندی‌ها	74	84	2026-07-16	approved	09bab356-ca7d-4f2b-a863-5ec4bcad25ca	\N	83b38e77-041e-4673-8235-56f75f5284bb	2026-07-21 11:45:44.744086+00	2026-07-21 11:45:44.744086+00
582b48ec-cec0-4e4b-a7d4-cbfd51751f0f	5c4e6bb4-401c-4f4b-b161-e3271f41a041	0885409c-d2f4-4296-88c0-d8ac1df6a7e5	مستندسازی و نهایی‌سازی	59	22	2026-07-16	submitted	\N	\N	40eeb1c0-7039-4611-8355-d8df94976645	2026-07-21 11:45:44.744086+00	2026-07-21 11:45:44.744086+00
582b48ec-cec0-4e4b-a7d4-cbfd51751f0f	2b9fec3d-0687-467e-a7c8-7dd69d89d705	09bab356-ca7d-4f2b-a863-5ec4bcad25ca	رفع اشکالات و بازبینی	161	38	2026-07-16	approved	09bab356-ca7d-4f2b-a863-5ec4bcad25ca	\N	952d7535-f3c3-4dfc-9c7f-b1271938b442	2026-07-21 11:45:44.744086+00	2026-07-21 11:45:44.744086+00
582b48ec-cec0-4e4b-a7d4-cbfd51751f0f	2b9fec3d-0687-467e-a7c8-7dd69d89d705	09bab356-ca7d-4f2b-a863-5ec4bcad25ca	تست و اطمینان از عملکرد صحیح	158	54	2026-07-16	approved	09bab356-ca7d-4f2b-a863-5ec4bcad25ca	\N	e7e573ab-2c4f-4466-972e-d8fb6620118b	2026-07-21 11:45:44.744086+00	2026-07-21 11:45:44.744086+00
582b48ec-cec0-4e4b-a7d4-cbfd51751f0f	2b9fec3d-0687-467e-a7c8-7dd69d89d705	09bab356-ca7d-4f2b-a863-5ec4bcad25ca	مستندسازی و نهایی‌سازی	107	100	2026-07-16	approved	09bab356-ca7d-4f2b-a863-5ec4bcad25ca	\N	5058ecd4-09ba-4c3e-9d5a-e487c986e638	2026-07-21 11:45:44.744086+00	2026-07-21 11:45:44.744086+00
582b48ec-cec0-4e4b-a7d4-cbfd51751f0f	2b9fec3d-0687-467e-a7c8-7dd69d89d705	09bab356-ca7d-4f2b-a863-5ec4bcad25ca	پیشرفت اولیه و بررسی نیازمندی‌ها	152	100	2026-07-16	approved	09bab356-ca7d-4f2b-a863-5ec4bcad25ca	\N	9179bcf1-d2c3-44d4-ae1a-527d7cdfaebf	2026-07-21 11:45:44.744086+00	2026-07-21 11:45:44.744086+00
582b48ec-cec0-4e4b-a7d4-cbfd51751f0f	f5941fc2-3770-42f6-80f0-0a58d1e91dc0	9bee1760-d3cf-42e2-80de-a78b2be8c965	تست و اطمینان از عملکرد صحیح	48	22	2026-06-30	approved	09bab356-ca7d-4f2b-a863-5ec4bcad25ca	\N	07e2a935-7fad-4a5a-9b88-09a813b7cb9e	2026-07-21 11:45:44.744086+00	2026-07-21 11:45:44.744086+00
582b48ec-cec0-4e4b-a7d4-cbfd51751f0f	f5941fc2-3770-42f6-80f0-0a58d1e91dc0	9bee1760-d3cf-42e2-80de-a78b2be8c965	پیشرفت اولیه و بررسی نیازمندی‌ها	62	56	2026-07-03	approved	09bab356-ca7d-4f2b-a863-5ec4bcad25ca	\N	39af1019-42c5-4276-8b22-ac2c1bde86b9	2026-07-21 11:45:44.744086+00	2026-07-21 11:45:44.744086+00
582b48ec-cec0-4e4b-a7d4-cbfd51751f0f	f5941fc2-3770-42f6-80f0-0a58d1e91dc0	9bee1760-d3cf-42e2-80de-a78b2be8c965	مستندسازی و نهایی‌سازی	165	87	2026-07-06	approved	09bab356-ca7d-4f2b-a863-5ec4bcad25ca	\N	9b2d9ebb-0a7a-4105-b09c-4249e9d2cac9	2026-07-21 11:45:44.744086+00	2026-07-21 11:45:44.744086+00
582b48ec-cec0-4e4b-a7d4-cbfd51751f0f	f5941fc2-3770-42f6-80f0-0a58d1e91dc0	9bee1760-d3cf-42e2-80de-a78b2be8c965	تست و اطمینان از عملکرد صحیح	55	92	2026-07-12	approved	09bab356-ca7d-4f2b-a863-5ec4bcad25ca	\N	60fe5694-e0d6-450e-8fd7-46ffd48aa9b4	2026-07-21 11:45:44.744086+00	2026-07-21 11:45:44.744086+00
582b48ec-cec0-4e4b-a7d4-cbfd51751f0f	554fa731-54a8-4afd-96ee-f52efc73ea5b	9bee1760-d3cf-42e2-80de-a78b2be8c965	تست و اطمینان از عملکرد صحیح	88	33	2026-06-17	approved	09bab356-ca7d-4f2b-a863-5ec4bcad25ca	\N	28135d9b-1741-4eca-848f-c90656a2659f	2026-07-21 11:45:44.744086+00	2026-07-21 11:45:44.744086+00
582b48ec-cec0-4e4b-a7d4-cbfd51751f0f	554fa731-54a8-4afd-96ee-f52efc73ea5b	9bee1760-d3cf-42e2-80de-a78b2be8c965	تست و اطمینان از عملکرد صحیح	132	66	2026-06-20	approved	09bab356-ca7d-4f2b-a863-5ec4bcad25ca	\N	9ea6ca4a-cbf7-41f9-8fe5-c8f00a412566	2026-07-21 11:45:44.744086+00	2026-07-21 11:45:44.744086+00
582b48ec-cec0-4e4b-a7d4-cbfd51751f0f	0c5817fd-c1bd-4fb2-b37b-dc671fef5696	09bab356-ca7d-4f2b-a863-5ec4bcad25ca	تست و اطمینان از عملکرد صحیح	110	28	2026-07-16	approved	09bab356-ca7d-4f2b-a863-5ec4bcad25ca	\N	0d1ffcb9-dc36-4e3b-94ab-0d414e521812	2026-07-21 11:45:44.744086+00	2026-07-21 11:45:44.744086+00
582b48ec-cec0-4e4b-a7d4-cbfd51751f0f	dea5dbf0-b0e7-4ac6-9635-18a68e3c2acd	de505605-7889-4573-8969-c65f885903c4	تست و اطمینان از عملکرد صحیح	47	22	2026-07-16	approved	09bab356-ca7d-4f2b-a863-5ec4bcad25ca	\N	458630eb-5ee7-46e6-b3df-1642a858ee53	2026-07-21 11:45:44.744086+00	2026-07-21 11:45:44.744086+00
582b48ec-cec0-4e4b-a7d4-cbfd51751f0f	dea5dbf0-b0e7-4ac6-9635-18a68e3c2acd	de505605-7889-4573-8969-c65f885903c4	پیشرفت اولیه و بررسی نیازمندی‌ها	220	62	2026-07-16	approved	09bab356-ca7d-4f2b-a863-5ec4bcad25ca	\N	62c6830b-199f-419f-95fc-09b3823b1cd3	2026-07-21 11:45:44.744086+00	2026-07-21 11:45:44.744086+00
582b48ec-cec0-4e4b-a7d4-cbfd51751f0f	dea5dbf0-b0e7-4ac6-9635-18a68e3c2acd	de505605-7889-4573-8969-c65f885903c4	مستندسازی و نهایی‌سازی	173	100	2026-07-16	approved	09bab356-ca7d-4f2b-a863-5ec4bcad25ca	\N	fe914f85-8c39-4ac7-88ba-515b2ebb7421	2026-07-21 11:45:44.744086+00	2026-07-21 11:45:44.744086+00
582b48ec-cec0-4e4b-a7d4-cbfd51751f0f	438a6150-39db-4479-a38f-7022b9423818	de505605-7889-4573-8969-c65f885903c4	تست و اطمینان از عملکرد صحیح	214	21	2026-07-06	approved	09bab356-ca7d-4f2b-a863-5ec4bcad25ca	\N	18d73eb2-744d-495a-b26c-441bd78b3392	2026-07-21 11:45:44.744086+00	2026-07-21 11:45:44.744086+00
582b48ec-cec0-4e4b-a7d4-cbfd51751f0f	438a6150-39db-4479-a38f-7022b9423818	de505605-7889-4573-8969-c65f885903c4	رفع اشکالات و بازبینی	56	76	2026-07-09	approved	09bab356-ca7d-4f2b-a863-5ec4bcad25ca	\N	ee1b7834-137b-42f5-9434-35e5007de39b	2026-07-21 11:45:44.744086+00	2026-07-21 11:45:44.744086+00
582b48ec-cec0-4e4b-a7d4-cbfd51751f0f	438a6150-39db-4479-a38f-7022b9423818	de505605-7889-4573-8969-c65f885903c4	تست و اطمینان از عملکرد صحیح	87	69	2026-07-10	approved	09bab356-ca7d-4f2b-a863-5ec4bcad25ca	\N	b5ad05e8-36f0-4e00-b8c7-f1f2e70703eb	2026-07-21 11:45:44.744086+00	2026-07-21 11:45:44.744086+00
582b48ec-cec0-4e4b-a7d4-cbfd51751f0f	527bdd1b-e6c2-464e-879f-0aedf1f81486	28996900-cff9-4923-bdf4-33c0c602bda7	پیشرفت اولیه و بررسی نیازمندی‌ها	225	28	2026-07-16	approved	09bab356-ca7d-4f2b-a863-5ec4bcad25ca	\N	4a08d2a9-1eca-42dd-9e57-1a3967e74950	2026-07-21 11:45:44.744086+00	2026-07-21 11:45:44.744086+00
582b48ec-cec0-4e4b-a7d4-cbfd51751f0f	527bdd1b-e6c2-464e-879f-0aedf1f81486	28996900-cff9-4923-bdf4-33c0c602bda7	تست و اطمینان از عملکرد صحیح	173	78	2026-07-16	approved	09bab356-ca7d-4f2b-a863-5ec4bcad25ca	\N	5d4676d2-a68c-489f-83fa-5f8778a589df	2026-07-21 11:45:44.744086+00	2026-07-21 11:45:44.744086+00
582b48ec-cec0-4e4b-a7d4-cbfd51751f0f	527bdd1b-e6c2-464e-879f-0aedf1f81486	28996900-cff9-4923-bdf4-33c0c602bda7	مستندسازی و نهایی‌سازی	198	84	2026-07-16	approved	09bab356-ca7d-4f2b-a863-5ec4bcad25ca	\N	3c037f5a-f8ce-44cb-8270-a9bdaa1c2146	2026-07-21 11:45:44.744086+00	2026-07-21 11:45:44.744086+00
582b48ec-cec0-4e4b-a7d4-cbfd51751f0f	4ee0c10d-3680-4dd6-b8b1-24f622561994	0885409c-d2f4-4296-88c0-d8ac1df6a7e5	رفع اشکالات و بازبینی	209	29	2026-07-16	approved	09bab356-ca7d-4f2b-a863-5ec4bcad25ca	\N	863c0a98-4e5f-4753-8249-bbf2b935de6d	2026-07-21 11:45:44.744086+00	2026-07-21 11:45:44.744086+00
582b48ec-cec0-4e4b-a7d4-cbfd51751f0f	8f70d979-f4d1-4a7b-b0cb-6e3b39705c13	9bee1760-d3cf-42e2-80de-a78b2be8c965	پیشرفت اولیه و بررسی نیازمندی‌ها	76	24	2026-06-26	approved	09bab356-ca7d-4f2b-a863-5ec4bcad25ca	\N	17abdf72-6197-45e1-9862-6832abd46469	2026-07-21 11:45:44.744086+00	2026-07-21 11:45:44.744086+00
582b48ec-cec0-4e4b-a7d4-cbfd51751f0f	8f70d979-f4d1-4a7b-b0cb-6e3b39705c13	9bee1760-d3cf-42e2-80de-a78b2be8c965	پیشرفت اولیه و بررسی نیازمندی‌ها	66	80	2026-06-30	approved	09bab356-ca7d-4f2b-a863-5ec4bcad25ca	\N	a9c5b70d-08ba-49a4-aa95-2ffda65299c6	2026-07-21 11:45:44.744086+00	2026-07-21 11:45:44.744086+00
582b48ec-cec0-4e4b-a7d4-cbfd51751f0f	8f70d979-f4d1-4a7b-b0cb-6e3b39705c13	9bee1760-d3cf-42e2-80de-a78b2be8c965	پیشرفت اولیه و بررسی نیازمندی‌ها	221	100	2026-06-28	approved	09bab356-ca7d-4f2b-a863-5ec4bcad25ca	\N	d9f4d578-ccbd-4a6d-9cc9-980aa49253ca	2026-07-21 11:45:44.744086+00	2026-07-21 11:45:44.744086+00
582b48ec-cec0-4e4b-a7d4-cbfd51751f0f	e3aedbc0-1d3b-47c7-8091-14e9dbe70ca1	9bee1760-d3cf-42e2-80de-a78b2be8c965	تست و اطمینان از عملکرد صحیح	146	30	2026-07-01	approved	09bab356-ca7d-4f2b-a863-5ec4bcad25ca	\N	187ae572-e7f8-41dc-8804-7c4b596763e9	2026-07-21 11:45:44.744086+00	2026-07-21 11:45:44.744086+00
582b48ec-cec0-4e4b-a7d4-cbfd51751f0f	e3aedbc0-1d3b-47c7-8091-14e9dbe70ca1	9bee1760-d3cf-42e2-80de-a78b2be8c965	رفع اشکالات و بازبینی	109	60	2026-07-03	approved	09bab356-ca7d-4f2b-a863-5ec4bcad25ca	\N	e9c9cbc7-d1b7-4f2d-b1b2-a11a27f2f82d	2026-07-21 11:45:44.744086+00	2026-07-21 11:45:44.744086+00
582b48ec-cec0-4e4b-a7d4-cbfd51751f0f	de3530d2-2cda-42e4-a6e0-8c4df62f9ce5	e6f6d74c-28cb-4ed3-98b6-6b15a7e57e23	پیاده‌سازی بخش اصلی	70	39	2026-07-16	approved	09bab356-ca7d-4f2b-a863-5ec4bcad25ca	\N	67f50813-e442-4d85-b141-d47cec6b5d82	2026-07-21 11:45:44.744086+00	2026-07-21 11:45:44.744086+00
582b48ec-cec0-4e4b-a7d4-cbfd51751f0f	79fae991-f882-4638-a066-ff360e4e94ec	de505605-7889-4573-8969-c65f885903c4	رفع اشکالات و بازبینی	143	33	2026-07-16	approved	09bab356-ca7d-4f2b-a863-5ec4bcad25ca	\N	1c39b592-920e-4d82-81bd-f8babb2b918f	2026-07-21 11:45:44.744086+00	2026-07-21 11:45:44.744086+00
582b48ec-cec0-4e4b-a7d4-cbfd51751f0f	bd705de2-3fd1-4206-97e2-e77fcc17b8e3	9bee1760-d3cf-42e2-80de-a78b2be8c965	تست و اطمینان از عملکرد صحیح	99	26	2026-07-16	approved	09bab356-ca7d-4f2b-a863-5ec4bcad25ca	\N	bbf9d310-6eed-4d68-bb1b-b722f95975a0	2026-07-21 11:45:44.744086+00	2026-07-21 11:45:44.744086+00
582b48ec-cec0-4e4b-a7d4-cbfd51751f0f	bd705de2-3fd1-4206-97e2-e77fcc17b8e3	9bee1760-d3cf-42e2-80de-a78b2be8c965	رفع اشکالات و بازبینی	140	46	2026-07-16	approved	09bab356-ca7d-4f2b-a863-5ec4bcad25ca	\N	f80bbc20-e8b2-49df-b84a-c415c03d39a0	2026-07-21 11:45:44.744086+00	2026-07-21 11:45:44.744086+00
582b48ec-cec0-4e4b-a7d4-cbfd51751f0f	bd705de2-3fd1-4206-97e2-e77fcc17b8e3	9bee1760-d3cf-42e2-80de-a78b2be8c965	مستندسازی و نهایی‌سازی	154	100	2026-07-16	approved	09bab356-ca7d-4f2b-a863-5ec4bcad25ca	\N	231f8d27-ade1-438b-ab55-707ecb8aa999	2026-07-21 11:45:44.744086+00	2026-07-21 11:45:44.744086+00
582b48ec-cec0-4e4b-a7d4-cbfd51751f0f	bd705de2-3fd1-4206-97e2-e77fcc17b8e3	9bee1760-d3cf-42e2-80de-a78b2be8c965	پیشرفت اولیه و بررسی نیازمندی‌ها	86	100	2026-07-16	approved	09bab356-ca7d-4f2b-a863-5ec4bcad25ca	\N	590abfd2-e211-4003-a5f5-28e905d63e7e	2026-07-21 11:45:44.744086+00	2026-07-21 11:45:44.744086+00
582b48ec-cec0-4e4b-a7d4-cbfd51751f0f	7b4c1a5a-56b2-49fa-971c-c2f53e68ea40	de505605-7889-4573-8969-c65f885903c4	پیاده‌سازی بخش اصلی	107	26	2026-07-16	approved	09bab356-ca7d-4f2b-a863-5ec4bcad25ca	\N	2d65a49a-8e01-4dc6-85e4-eae213b5b251	2026-07-21 11:45:44.744086+00	2026-07-21 11:45:44.744086+00
582b48ec-cec0-4e4b-a7d4-cbfd51751f0f	5888b69a-2aea-440c-a82a-e770abe12d88	28996900-cff9-4923-bdf4-33c0c602bda7	رفع اشکالات و بازبینی	113	23	2026-07-01	approved	09bab356-ca7d-4f2b-a863-5ec4bcad25ca	\N	e5e78fd8-afc4-4eea-905e-e26328da9f7f	2026-07-21 11:45:44.744086+00	2026-07-21 11:45:44.744086+00
582b48ec-cec0-4e4b-a7d4-cbfd51751f0f	5888b69a-2aea-440c-a82a-e770abe12d88	28996900-cff9-4923-bdf4-33c0c602bda7	تست و اطمینان از عملکرد صحیح	221	66	2026-07-02	approved	09bab356-ca7d-4f2b-a863-5ec4bcad25ca	\N	7e7cb690-c10e-4abe-877f-b0e8dee0a8ad	2026-07-21 11:45:44.744086+00	2026-07-21 11:45:44.744086+00
582b48ec-cec0-4e4b-a7d4-cbfd51751f0f	733fa9d2-3a56-4f1d-8b54-079a72599183	e6f6d74c-28cb-4ed3-98b6-6b15a7e57e23	پیاده‌سازی بخش اصلی	158	37	2026-07-14	approved	09bab356-ca7d-4f2b-a863-5ec4bcad25ca	\N	d3a0a623-4615-4309-b278-5db93429476d	2026-07-21 11:45:44.744086+00	2026-07-21 11:45:44.744086+00
582b48ec-cec0-4e4b-a7d4-cbfd51751f0f	733fa9d2-3a56-4f1d-8b54-079a72599183	e6f6d74c-28cb-4ed3-98b6-6b15a7e57e23	پیشرفت اولیه و بررسی نیازمندی‌ها	141	40	2026-07-16	approved	09bab356-ca7d-4f2b-a863-5ec4bcad25ca	\N	cc7c85d9-286d-4d84-8d11-e576c6339c46	2026-07-21 11:45:44.744086+00	2026-07-21 11:45:44.744086+00
582b48ec-cec0-4e4b-a7d4-cbfd51751f0f	586bcc75-0f3d-4d94-b5e5-8944b98a0778	0885409c-d2f4-4296-88c0-d8ac1df6a7e5	رفع اشکالات و بازبینی	177	33	2026-06-25	approved	09bab356-ca7d-4f2b-a863-5ec4bcad25ca	\N	e167a93b-25d1-4780-b94d-a39e526d85c8	2026-07-21 11:45:44.744086+00	2026-07-21 11:45:44.744086+00
582b48ec-cec0-4e4b-a7d4-cbfd51751f0f	586bcc75-0f3d-4d94-b5e5-8944b98a0778	0885409c-d2f4-4296-88c0-d8ac1df6a7e5	تست و اطمینان از عملکرد صحیح	104	46	2026-06-29	approved	09bab356-ca7d-4f2b-a863-5ec4bcad25ca	\N	3e911377-fc94-4558-abe9-161405ecd04f	2026-07-21 11:45:44.744086+00	2026-07-21 11:45:44.744086+00
582b48ec-cec0-4e4b-a7d4-cbfd51751f0f	586bcc75-0f3d-4d94-b5e5-8944b98a0778	0885409c-d2f4-4296-88c0-d8ac1df6a7e5	پیشرفت اولیه و بررسی نیازمندی‌ها	113	75	2026-07-03	approved	09bab356-ca7d-4f2b-a863-5ec4bcad25ca	\N	0e6afd63-20d0-41fb-9cb5-78d7d4b28469	2026-07-21 11:45:44.744086+00	2026-07-21 11:45:44.744086+00
582b48ec-cec0-4e4b-a7d4-cbfd51751f0f	586bcc75-0f3d-4d94-b5e5-8944b98a0778	0885409c-d2f4-4296-88c0-d8ac1df6a7e5	رفع اشکالات و بازبینی	52	100	2026-07-07	approved	09bab356-ca7d-4f2b-a863-5ec4bcad25ca	\N	6679e9ea-092d-4df7-a419-03246f40e656	2026-07-21 11:45:44.744086+00	2026-07-21 11:45:44.744086+00
582b48ec-cec0-4e4b-a7d4-cbfd51751f0f	d584c370-26e7-4c48-b0bf-03152944a1ee	e6f6d74c-28cb-4ed3-98b6-6b15a7e57e23	تست و اطمینان از عملکرد صحیح	164	22	2026-07-10	approved	09bab356-ca7d-4f2b-a863-5ec4bcad25ca	\N	0610ea09-c0e0-4522-aadf-ad10469b8e4b	2026-07-21 11:45:44.744086+00	2026-07-21 11:45:44.744086+00
582b48ec-cec0-4e4b-a7d4-cbfd51751f0f	1736bb3a-5e8a-4960-9d70-55ec4f4a7470	09bab356-ca7d-4f2b-a863-5ec4bcad25ca	پیاده‌سازی بخش اصلی	115	25	2026-07-05	submitted	\N	\N	04241755-22b0-4196-9419-aba647d4b843	2026-07-21 11:45:44.744086+00	2026-07-21 11:45:44.744086+00
582b48ec-cec0-4e4b-a7d4-cbfd51751f0f	1736bb3a-5e8a-4960-9d70-55ec4f4a7470	09bab356-ca7d-4f2b-a863-5ec4bcad25ca	پیشرفت اولیه و بررسی نیازمندی‌ها	165	72	2026-07-06	approved	09bab356-ca7d-4f2b-a863-5ec4bcad25ca	\N	78757cac-eee2-4fdf-b7cd-ac5d8d56a666	2026-07-21 11:45:44.744086+00	2026-07-21 11:45:44.744086+00
582b48ec-cec0-4e4b-a7d4-cbfd51751f0f	1736bb3a-5e8a-4960-9d70-55ec4f4a7470	09bab356-ca7d-4f2b-a863-5ec4bcad25ca	رفع اشکالات و بازبینی	119	100	2026-07-09	submitted	\N	\N	4da77c91-f8db-4ce4-9f82-29365a600b42	2026-07-21 11:45:44.744086+00	2026-07-21 11:45:44.744086+00
582b48ec-cec0-4e4b-a7d4-cbfd51751f0f	1736bb3a-5e8a-4960-9d70-55ec4f4a7470	09bab356-ca7d-4f2b-a863-5ec4bcad25ca	پیاده‌سازی بخش اصلی	95	100	2026-07-11	approved	09bab356-ca7d-4f2b-a863-5ec4bcad25ca	\N	0686d1b0-58a1-4428-b320-3fb85c2b96ba	2026-07-21 11:45:44.744086+00	2026-07-21 11:45:44.744086+00
582b48ec-cec0-4e4b-a7d4-cbfd51751f0f	f9bb2ca6-f4b7-4973-92c6-496253562fc8	2ea22145-8b4c-4e52-84fb-acb66c94b186	پیشرفت اولیه و بررسی نیازمندی‌ها	75	40	2026-07-16	approved	09bab356-ca7d-4f2b-a863-5ec4bcad25ca	\N	7cdb5e26-d030-4877-bcd2-36f9ad9d9c14	2026-07-21 11:45:44.744086+00	2026-07-21 11:45:44.744086+00
582b48ec-cec0-4e4b-a7d4-cbfd51751f0f	f9bb2ca6-f4b7-4973-92c6-496253562fc8	2ea22145-8b4c-4e52-84fb-acb66c94b186	تست و اطمینان از عملکرد صحیح	223	76	2026-07-16	approved	09bab356-ca7d-4f2b-a863-5ec4bcad25ca	\N	fdd6b63b-5a6d-42a9-b775-acad80786215	2026-07-21 11:45:44.744086+00	2026-07-21 11:45:44.744086+00
582b48ec-cec0-4e4b-a7d4-cbfd51751f0f	8e6ab736-f37c-46a6-b434-3cc33a3b825d	28996900-cff9-4923-bdf4-33c0c602bda7	رفع اشکالات و بازبینی	68	34	2026-07-16	submitted	\N	\N	0ada0441-9426-4d57-8767-3291c82f3b3f	2026-07-21 11:45:44.744086+00	2026-07-21 11:45:44.744086+00
582b48ec-cec0-4e4b-a7d4-cbfd51751f0f	8e6ab736-f37c-46a6-b434-3cc33a3b825d	28996900-cff9-4923-bdf4-33c0c602bda7	رفع اشکالات و بازبینی	233	56	2026-07-16	approved	09bab356-ca7d-4f2b-a863-5ec4bcad25ca	\N	27cb324e-2e8c-4bd2-b342-96b48ec1bfac	2026-07-21 11:45:44.744086+00	2026-07-21 11:45:44.744086+00
582b48ec-cec0-4e4b-a7d4-cbfd51751f0f	8e6ab736-f37c-46a6-b434-3cc33a3b825d	28996900-cff9-4923-bdf4-33c0c602bda7	پیشرفت اولیه و بررسی نیازمندی‌ها	109	100	2026-07-16	approved	09bab356-ca7d-4f2b-a863-5ec4bcad25ca	\N	f6347b8d-1edf-4754-b777-a9ac0931ed9b	2026-07-21 11:45:44.744086+00	2026-07-21 11:45:44.744086+00
582b48ec-cec0-4e4b-a7d4-cbfd51751f0f	8e6ab736-f37c-46a6-b434-3cc33a3b825d	28996900-cff9-4923-bdf4-33c0c602bda7	رفع اشکالات و بازبینی	103	88	2026-07-16	approved	09bab356-ca7d-4f2b-a863-5ec4bcad25ca	\N	0c099a56-ccb6-43ff-861a-65951166a456	2026-07-21 11:45:44.744086+00	2026-07-21 11:45:44.744086+00
582b48ec-cec0-4e4b-a7d4-cbfd51751f0f	dc376b85-1ee7-4d9e-8410-34a02787b84b	2ea22145-8b4c-4e52-84fb-acb66c94b186	تست و اطمینان از عملکرد صحیح	178	37	2026-07-11	approved	09bab356-ca7d-4f2b-a863-5ec4bcad25ca	\N	b445d632-29da-4bb8-90ba-585a6f489174	2026-07-21 11:45:44.744086+00	2026-07-21 11:45:44.744086+00
582b48ec-cec0-4e4b-a7d4-cbfd51751f0f	e5e5b7f7-7859-4bae-af3d-8e9434d3a244	de505605-7889-4573-8969-c65f885903c4	مستندسازی و نهایی‌سازی	196	26	2026-06-24	submitted	\N	\N	48d04a35-47c3-45c7-8908-c91e1f108283	2026-07-21 11:45:44.744086+00	2026-07-21 11:45:44.744086+00
582b48ec-cec0-4e4b-a7d4-cbfd51751f0f	e45e2321-d97f-4868-b177-9f403858c163	e6f6d74c-28cb-4ed3-98b6-6b15a7e57e23	مستندسازی و نهایی‌سازی	68	21	2026-07-16	approved	09bab356-ca7d-4f2b-a863-5ec4bcad25ca	\N	ddded617-0462-40c6-bd2c-5d61c07bd7ea	2026-07-21 11:45:44.744086+00	2026-07-21 11:45:44.744086+00
582b48ec-cec0-4e4b-a7d4-cbfd51751f0f	e45e2321-d97f-4868-b177-9f403858c163	e6f6d74c-28cb-4ed3-98b6-6b15a7e57e23	پیشرفت اولیه و بررسی نیازمندی‌ها	237	60	2026-07-16	approved	09bab356-ca7d-4f2b-a863-5ec4bcad25ca	\N	e7727337-fe8b-4508-9e88-cc1c63780142	2026-07-21 11:45:44.744086+00	2026-07-21 11:45:44.744086+00
582b48ec-cec0-4e4b-a7d4-cbfd51751f0f	e45e2321-d97f-4868-b177-9f403858c163	e6f6d74c-28cb-4ed3-98b6-6b15a7e57e23	مستندسازی و نهایی‌سازی	195	75	2026-07-16	approved	09bab356-ca7d-4f2b-a863-5ec4bcad25ca	\N	631446b3-2f93-4e90-b1ad-c42fae08e890	2026-07-21 11:45:44.744086+00	2026-07-21 11:45:44.744086+00
582b48ec-cec0-4e4b-a7d4-cbfd51751f0f	9a775f7a-61d1-4619-99d5-24aaecce3f94	09bab356-ca7d-4f2b-a863-5ec4bcad25ca	تست و اطمینان از عملکرد صحیح	142	36	2026-07-16	approved	09bab356-ca7d-4f2b-a863-5ec4bcad25ca	\N	69da7934-36f3-4340-b7da-1fd3a008115c	2026-07-21 11:45:44.744086+00	2026-07-21 11:45:44.744086+00
582b48ec-cec0-4e4b-a7d4-cbfd51751f0f	be79ffe1-9356-49a1-8573-2744cae71335	9bee1760-d3cf-42e2-80de-a78b2be8c965	رفع اشکالات و بازبینی	102	32	2026-06-17	approved	09bab356-ca7d-4f2b-a863-5ec4bcad25ca	\N	05fbdcf7-8e8a-43a3-81ca-a1147e5c3904	2026-07-21 11:45:44.744086+00	2026-07-21 11:45:44.744086+00
582b48ec-cec0-4e4b-a7d4-cbfd51751f0f	be79ffe1-9356-49a1-8573-2744cae71335	9bee1760-d3cf-42e2-80de-a78b2be8c965	رفع اشکالات و بازبینی	203	78	2026-06-21	approved	09bab356-ca7d-4f2b-a863-5ec4bcad25ca	\N	6a4c0b7d-5522-4616-bcfa-4b4c7efd2134	2026-07-21 11:45:44.744086+00	2026-07-21 11:45:44.744086+00
582b48ec-cec0-4e4b-a7d4-cbfd51751f0f	6cb4915d-1176-479f-aa27-b6ef2fe11d29	9bee1760-d3cf-42e2-80de-a78b2be8c965	پیشرفت اولیه و بررسی نیازمندی‌ها	172	32	2026-06-26	approved	09bab356-ca7d-4f2b-a863-5ec4bcad25ca	\N	1ffe5593-81bd-474c-a587-11470e3c606c	2026-07-21 11:45:44.744086+00	2026-07-21 11:45:44.744086+00
582b48ec-cec0-4e4b-a7d4-cbfd51751f0f	79d9ae81-2bd1-4c83-b197-7e7f8412fa58	e6f6d74c-28cb-4ed3-98b6-6b15a7e57e23	مستندسازی و نهایی‌سازی	68	30	2026-06-22	submitted	\N	\N	f3d1cb65-a5f0-4acf-a86d-ee67abbbc15d	2026-07-21 11:45:44.744086+00	2026-07-21 11:45:44.744086+00
582b48ec-cec0-4e4b-a7d4-cbfd51751f0f	79d9ae81-2bd1-4c83-b197-7e7f8412fa58	e6f6d74c-28cb-4ed3-98b6-6b15a7e57e23	پیاده‌سازی بخش اصلی	119	58	2026-06-23	approved	09bab356-ca7d-4f2b-a863-5ec4bcad25ca	\N	1ccc3e57-8d61-4dab-8364-10b4f7e31b59	2026-07-21 11:45:44.744086+00	2026-07-21 11:45:44.744086+00
582b48ec-cec0-4e4b-a7d4-cbfd51751f0f	79d9ae81-2bd1-4c83-b197-7e7f8412fa58	e6f6d74c-28cb-4ed3-98b6-6b15a7e57e23	پیشرفت اولیه و بررسی نیازمندی‌ها	109	100	2026-06-30	approved	09bab356-ca7d-4f2b-a863-5ec4bcad25ca	\N	80610596-72a0-4d76-b4cd-1860c0ce9898	2026-07-21 11:45:44.744086+00	2026-07-21 11:45:44.744086+00
582b48ec-cec0-4e4b-a7d4-cbfd51751f0f	9c670ed9-0342-4761-ac04-49c21e6478f5	28996900-cff9-4923-bdf4-33c0c602bda7	مستندسازی و نهایی‌سازی	53	40	2026-07-16	submitted	\N	\N	de6ebe97-4ab2-4e88-a1a9-605be90b26c2	2026-07-21 11:45:44.744086+00	2026-07-21 11:45:44.744086+00
582b48ec-cec0-4e4b-a7d4-cbfd51751f0f	9c670ed9-0342-4761-ac04-49c21e6478f5	28996900-cff9-4923-bdf4-33c0c602bda7	پیشرفت اولیه و بررسی نیازمندی‌ها	122	58	2026-07-16	approved	09bab356-ca7d-4f2b-a863-5ec4bcad25ca	\N	5a1ebf89-cae0-4fbf-9d0c-c09de5b69d3d	2026-07-21 11:45:44.744086+00	2026-07-21 11:45:44.744086+00
582b48ec-cec0-4e4b-a7d4-cbfd51751f0f	9c670ed9-0342-4761-ac04-49c21e6478f5	28996900-cff9-4923-bdf4-33c0c602bda7	رفع اشکالات و بازبینی	226	100	2026-07-16	submitted	\N	\N	bdb550d6-6b18-4e39-bd18-9a101c7ac0ad	2026-07-21 11:45:44.744086+00	2026-07-21 11:45:44.744086+00
582b48ec-cec0-4e4b-a7d4-cbfd51751f0f	9c670ed9-0342-4761-ac04-49c21e6478f5	28996900-cff9-4923-bdf4-33c0c602bda7	پیاده‌سازی بخش اصلی	69	88	2026-07-16	approved	09bab356-ca7d-4f2b-a863-5ec4bcad25ca	\N	c8c89a26-b0ad-4eee-a98b-7dcb1f30fe75	2026-07-21 11:45:44.744086+00	2026-07-21 11:45:44.744086+00
582b48ec-cec0-4e4b-a7d4-cbfd51751f0f	c62d4bdb-8d76-427b-8a50-c7b2bccaac60	de505605-7889-4573-8969-c65f885903c4	مستندسازی و نهایی‌سازی	227	37	2026-07-05	approved	09bab356-ca7d-4f2b-a863-5ec4bcad25ca	\N	b6c679ee-aafe-4a8b-96c1-67f862d43f4d	2026-07-21 11:45:44.744086+00	2026-07-21 11:45:44.744086+00
582b48ec-cec0-4e4b-a7d4-cbfd51751f0f	c62d4bdb-8d76-427b-8a50-c7b2bccaac60	de505605-7889-4573-8969-c65f885903c4	رفع اشکالات و بازبینی	226	78	2026-07-06	approved	09bab356-ca7d-4f2b-a863-5ec4bcad25ca	\N	21e46ab4-b5e0-49d4-9ebf-b407c9ee1104	2026-07-21 11:45:44.744086+00	2026-07-21 11:45:44.744086+00
582b48ec-cec0-4e4b-a7d4-cbfd51751f0f	c62d4bdb-8d76-427b-8a50-c7b2bccaac60	de505605-7889-4573-8969-c65f885903c4	مستندسازی و نهایی‌سازی	126	72	2026-07-09	approved	09bab356-ca7d-4f2b-a863-5ec4bcad25ca	\N	5d6265cb-a4a1-41df-9a75-47f1588cae90	2026-07-21 11:45:44.744086+00	2026-07-21 11:45:44.744086+00
582b48ec-cec0-4e4b-a7d4-cbfd51751f0f	8d479ebe-45dc-491f-98a1-cb9da25fc66f	0885409c-d2f4-4296-88c0-d8ac1df6a7e5	مستندسازی و نهایی‌سازی	237	25	2026-07-09	approved	09bab356-ca7d-4f2b-a863-5ec4bcad25ca	\N	2e67b6c9-398a-4382-b4b7-011f6dcb1151	2026-07-21 11:45:44.744086+00	2026-07-21 11:45:44.744086+00
582b48ec-cec0-4e4b-a7d4-cbfd51751f0f	8d479ebe-45dc-491f-98a1-cb9da25fc66f	0885409c-d2f4-4296-88c0-d8ac1df6a7e5	پیشرفت اولیه و بررسی نیازمندی‌ها	135	62	2026-07-13	approved	09bab356-ca7d-4f2b-a863-5ec4bcad25ca	\N	abf14b48-25df-4878-9a4a-3eb27b2328e1	2026-07-21 11:45:44.744086+00	2026-07-21 11:45:44.744086+00
582b48ec-cec0-4e4b-a7d4-cbfd51751f0f	9830afb0-f520-45ad-af71-36ae4c9fbb77	9bee1760-d3cf-42e2-80de-a78b2be8c965	تست و اطمینان از عملکرد صحیح	89	37	2026-07-16	approved	09bab356-ca7d-4f2b-a863-5ec4bcad25ca	\N	9fc260d8-b78d-455e-a852-22fda2798071	2026-07-21 11:45:44.744086+00	2026-07-21 11:45:44.744086+00
582b48ec-cec0-4e4b-a7d4-cbfd51751f0f	9830afb0-f520-45ad-af71-36ae4c9fbb77	9bee1760-d3cf-42e2-80de-a78b2be8c965	تست و اطمینان از عملکرد صحیح	79	62	2026-07-16	approved	09bab356-ca7d-4f2b-a863-5ec4bcad25ca	\N	bac3d788-269a-434c-9de0-6249352067eb	2026-07-21 11:45:44.744086+00	2026-07-21 11:45:44.744086+00
582b48ec-cec0-4e4b-a7d4-cbfd51751f0f	2c282114-40cf-4f87-9b84-a12693ac37ed	9bee1760-d3cf-42e2-80de-a78b2be8c965	رفع اشکالات و بازبینی	229	32	2026-07-13	approved	09bab356-ca7d-4f2b-a863-5ec4bcad25ca	\N	fb67ca3e-86fd-4b9c-873e-04e4a744d954	2026-07-21 11:45:44.744086+00	2026-07-21 11:45:44.744086+00
582b48ec-cec0-4e4b-a7d4-cbfd51751f0f	2c282114-40cf-4f87-9b84-a12693ac37ed	9bee1760-d3cf-42e2-80de-a78b2be8c965	پیاده‌سازی بخش اصلی	239	52	2026-07-16	approved	09bab356-ca7d-4f2b-a863-5ec4bcad25ca	\N	67b9759b-195f-498b-966a-f7dd5d1e329a	2026-07-21 11:45:44.744086+00	2026-07-21 11:45:44.744086+00
582b48ec-cec0-4e4b-a7d4-cbfd51751f0f	2c282114-40cf-4f87-9b84-a12693ac37ed	9bee1760-d3cf-42e2-80de-a78b2be8c965	رفع اشکالات و بازبینی	43	100	2026-07-16	approved	09bab356-ca7d-4f2b-a863-5ec4bcad25ca	\N	b47e5947-57a4-4d88-b7a5-f9ff9de898e9	2026-07-21 11:45:44.744086+00	2026-07-21 11:45:44.744086+00
582b48ec-cec0-4e4b-a7d4-cbfd51751f0f	2c282114-40cf-4f87-9b84-a12693ac37ed	9bee1760-d3cf-42e2-80de-a78b2be8c965	رفع اشکالات و بازبینی	171	92	2026-07-16	approved	09bab356-ca7d-4f2b-a863-5ec4bcad25ca	\N	6f746f59-795d-4115-bd52-735c83bfe21a	2026-07-21 11:45:44.744086+00	2026-07-21 11:45:44.744086+00
582b48ec-cec0-4e4b-a7d4-cbfd51751f0f	429f18d8-af01-4734-b60d-1405d697d3d2	0885409c-d2f4-4296-88c0-d8ac1df6a7e5	پیشرفت اولیه و بررسی نیازمندی‌ها	225	25	2026-07-16	approved	09bab356-ca7d-4f2b-a863-5ec4bcad25ca	\N	101469a4-0f9f-4d07-a002-54f9af5ba181	2026-07-21 11:45:44.744086+00	2026-07-21 11:45:44.744086+00
582b48ec-cec0-4e4b-a7d4-cbfd51751f0f	412e4e1e-f80d-4d20-a70b-5cd8abc9257c	2ea22145-8b4c-4e52-84fb-acb66c94b186	پیاده‌سازی بخش اصلی	141	22	2026-07-06	submitted	\N	\N	665fabb3-ba74-4efa-ab36-3327dac6ba5e	2026-07-21 11:45:44.744086+00	2026-07-21 11:45:44.744086+00
582b48ec-cec0-4e4b-a7d4-cbfd51751f0f	412e4e1e-f80d-4d20-a70b-5cd8abc9257c	2ea22145-8b4c-4e52-84fb-acb66c94b186	رفع اشکالات و بازبینی	36	66	2026-07-08	submitted	\N	\N	2b00e140-b3f2-408d-b580-a423df9fdef3	2026-07-21 11:45:44.744086+00	2026-07-21 11:45:44.744086+00
582b48ec-cec0-4e4b-a7d4-cbfd51751f0f	412e4e1e-f80d-4d20-a70b-5cd8abc9257c	2ea22145-8b4c-4e52-84fb-acb66c94b186	رفع اشکالات و بازبینی	90	96	2026-07-08	approved	09bab356-ca7d-4f2b-a863-5ec4bcad25ca	\N	f7e63f68-030b-44d2-ab66-491a74151243	2026-07-21 11:45:44.744086+00	2026-07-21 11:45:44.744086+00
582b48ec-cec0-4e4b-a7d4-cbfd51751f0f	45d4dffc-f44e-473d-9904-90c616c624ad	e6f6d74c-28cb-4ed3-98b6-6b15a7e57e23	پیاده‌سازی بخش اصلی	37	30	2026-07-15	approved	09bab356-ca7d-4f2b-a863-5ec4bcad25ca	\N	c8988781-cfc7-42ce-9b4c-b0e6dc8b748a	2026-07-21 11:45:44.744086+00	2026-07-21 11:45:44.744086+00
582b48ec-cec0-4e4b-a7d4-cbfd51751f0f	9b67833f-b0b0-40ea-8fb1-200db862900a	28996900-cff9-4923-bdf4-33c0c602bda7	پیاده‌سازی بخش اصلی	39	29	2026-06-27	submitted	\N	\N	55eb416b-eca6-46c1-90e8-cc71a64cc170	2026-07-21 11:45:44.744086+00	2026-07-21 11:45:44.744086+00
582b48ec-cec0-4e4b-a7d4-cbfd51751f0f	22eb1d73-0f2f-4f61-80f2-33968e93881c	2ea22145-8b4c-4e52-84fb-acb66c94b186	تست و اطمینان از عملکرد صحیح	144	39	2026-07-16	approved	09bab356-ca7d-4f2b-a863-5ec4bcad25ca	\N	fd1d827a-f66e-41b6-b49a-88b9f3b57d33	2026-07-21 11:45:44.744086+00	2026-07-21 11:45:44.744086+00
582b48ec-cec0-4e4b-a7d4-cbfd51751f0f	22eb1d73-0f2f-4f61-80f2-33968e93881c	2ea22145-8b4c-4e52-84fb-acb66c94b186	پیشرفت اولیه و بررسی نیازمندی‌ها	34	56	2026-07-16	approved	09bab356-ca7d-4f2b-a863-5ec4bcad25ca	\N	44bf4ca4-59f5-4e67-8cad-9d8191be1205	2026-07-21 11:45:44.744086+00	2026-07-21 11:45:44.744086+00
582b48ec-cec0-4e4b-a7d4-cbfd51751f0f	22eb1d73-0f2f-4f61-80f2-33968e93881c	2ea22145-8b4c-4e52-84fb-acb66c94b186	پیاده‌سازی بخش اصلی	170	100	2026-07-16	approved	09bab356-ca7d-4f2b-a863-5ec4bcad25ca	\N	8f6e5759-7500-4e49-a73f-936151400018	2026-07-21 11:45:44.744086+00	2026-07-21 11:45:44.744086+00
582b48ec-cec0-4e4b-a7d4-cbfd51751f0f	22eb1d73-0f2f-4f61-80f2-33968e93881c	2ea22145-8b4c-4e52-84fb-acb66c94b186	پیشرفت اولیه و بررسی نیازمندی‌ها	228	100	2026-07-16	approved	09bab356-ca7d-4f2b-a863-5ec4bcad25ca	\N	2a3520d3-c5bd-4b50-8f5c-8f068fdf6fa1	2026-07-21 11:45:44.744086+00	2026-07-21 11:45:44.744086+00
582b48ec-cec0-4e4b-a7d4-cbfd51751f0f	75434502-454b-418a-8ee7-9a1619b79632	de505605-7889-4573-8969-c65f885903c4	پیاده‌سازی بخش اصلی	137	40	2026-07-16	approved	09bab356-ca7d-4f2b-a863-5ec4bcad25ca	\N	e0ec5abe-721a-44fc-a7fd-c437f213f7ae	2026-07-21 11:45:44.744086+00	2026-07-21 11:45:44.744086+00
582b48ec-cec0-4e4b-a7d4-cbfd51751f0f	75434502-454b-418a-8ee7-9a1619b79632	de505605-7889-4573-8969-c65f885903c4	تست و اطمینان از عملکرد صحیح	182	74	2026-07-16	approved	09bab356-ca7d-4f2b-a863-5ec4bcad25ca	\N	a9e495c5-f468-47f7-91b0-438e989855fd	2026-07-21 11:45:44.744086+00	2026-07-21 11:45:44.744086+00
582b48ec-cec0-4e4b-a7d4-cbfd51751f0f	74c47866-22a5-4b9b-8666-fcd83ec3f07f	28996900-cff9-4923-bdf4-33c0c602bda7	پیاده‌سازی بخش اصلی	104	33	2026-06-21	approved	09bab356-ca7d-4f2b-a863-5ec4bcad25ca	\N	26af338d-f1b2-4e88-8743-b60a3492cad1	2026-07-21 11:45:44.744086+00	2026-07-21 11:45:44.744086+00
582b48ec-cec0-4e4b-a7d4-cbfd51751f0f	7b882b49-ba77-46a5-9e86-a5714bd9040e	c057add9-a37a-4d8b-adb3-be28effacb81	مستندسازی و نهایی‌سازی	196	31	2026-06-27	approved	98fba7cd-606b-4e45-957c-f63d3a809e84	\N	3f8d1daf-cfa3-429c-b689-82725046d130	2026-07-21 11:45:44.744086+00	2026-07-21 11:45:44.744086+00
582b48ec-cec0-4e4b-a7d4-cbfd51751f0f	7b882b49-ba77-46a5-9e86-a5714bd9040e	c057add9-a37a-4d8b-adb3-be28effacb81	رفع اشکالات و بازبینی	122	72	2026-06-30	approved	98fba7cd-606b-4e45-957c-f63d3a809e84	\N	bef3544e-7c5d-4a27-a079-48338f3ad085	2026-07-21 11:45:44.744086+00	2026-07-21 11:45:44.744086+00
582b48ec-cec0-4e4b-a7d4-cbfd51751f0f	7b882b49-ba77-46a5-9e86-a5714bd9040e	c057add9-a37a-4d8b-adb3-be28effacb81	تست و اطمینان از عملکرد صحیح	55	100	2026-07-05	approved	98fba7cd-606b-4e45-957c-f63d3a809e84	\N	c18bc1ce-290a-45c6-93fe-0867f7d074fc	2026-07-21 11:45:44.744086+00	2026-07-21 11:45:44.744086+00
582b48ec-cec0-4e4b-a7d4-cbfd51751f0f	7b882b49-ba77-46a5-9e86-a5714bd9040e	c057add9-a37a-4d8b-adb3-be28effacb81	پیاده‌سازی بخش اصلی	124	100	2026-07-06	approved	98fba7cd-606b-4e45-957c-f63d3a809e84	\N	7c6f4424-424f-44e1-8401-66bc54fc6140	2026-07-21 11:45:44.744086+00	2026-07-21 11:45:44.744086+00
582b48ec-cec0-4e4b-a7d4-cbfd51751f0f	6c39f7b2-ac26-47ef-90bf-2cc61797846a	e84eaed7-50c6-4212-9f29-cad60bbee457	مستندسازی و نهایی‌سازی	86	24	2026-07-14	approved	98fba7cd-606b-4e45-957c-f63d3a809e84	\N	590be399-bd2e-4d22-8434-84d3ed55a3af	2026-07-21 11:45:44.744086+00	2026-07-21 11:45:44.744086+00
582b48ec-cec0-4e4b-a7d4-cbfd51751f0f	6c39f7b2-ac26-47ef-90bf-2cc61797846a	e84eaed7-50c6-4212-9f29-cad60bbee457	رفع اشکالات و بازبینی	171	76	2026-07-15	approved	98fba7cd-606b-4e45-957c-f63d3a809e84	\N	143f0bad-e072-4dc8-9709-89bb05a30165	2026-07-21 11:45:44.744086+00	2026-07-21 11:45:44.744086+00
582b48ec-cec0-4e4b-a7d4-cbfd51751f0f	6c39f7b2-ac26-47ef-90bf-2cc61797846a	e84eaed7-50c6-4212-9f29-cad60bbee457	رفع اشکالات و بازبینی	69	78	2026-07-16	approved	98fba7cd-606b-4e45-957c-f63d3a809e84	\N	37111597-bd75-4945-9dd2-937d5e117a36	2026-07-21 11:45:44.744086+00	2026-07-21 11:45:44.744086+00
582b48ec-cec0-4e4b-a7d4-cbfd51751f0f	6c39f7b2-ac26-47ef-90bf-2cc61797846a	e84eaed7-50c6-4212-9f29-cad60bbee457	پیاده‌سازی بخش اصلی	127	100	2026-07-16	approved	98fba7cd-606b-4e45-957c-f63d3a809e84	\N	6341789f-2490-4297-a29a-7e6dca796747	2026-07-21 11:45:44.744086+00	2026-07-21 11:45:44.744086+00
582b48ec-cec0-4e4b-a7d4-cbfd51751f0f	45010937-cc56-4b8a-b8a8-813aa9f5a672	c057add9-a37a-4d8b-adb3-be28effacb81	رفع اشکالات و بازبینی	95	35	2026-07-14	approved	98fba7cd-606b-4e45-957c-f63d3a809e84	\N	d97f941a-f3d8-49f1-9e58-34cd662ad3c8	2026-07-21 11:45:44.744086+00	2026-07-21 11:45:44.744086+00
582b48ec-cec0-4e4b-a7d4-cbfd51751f0f	45010937-cc56-4b8a-b8a8-813aa9f5a672	c057add9-a37a-4d8b-adb3-be28effacb81	رفع اشکالات و بازبینی	73	48	2026-07-16	approved	98fba7cd-606b-4e45-957c-f63d3a809e84	\N	ceac8407-eb0a-43df-ae74-7b0cccca03fa	2026-07-21 11:45:44.744086+00	2026-07-21 11:45:44.744086+00
582b48ec-cec0-4e4b-a7d4-cbfd51751f0f	c8deb7f5-e162-4b2f-b722-886f03f232f8	e84eaed7-50c6-4212-9f29-cad60bbee457	مستندسازی و نهایی‌سازی	194	21	2026-07-16	approved	98fba7cd-606b-4e45-957c-f63d3a809e84	\N	8f26040f-6328-45c7-ba35-a03af2c59fe6	2026-07-21 11:45:44.744086+00	2026-07-21 11:45:44.744086+00
582b48ec-cec0-4e4b-a7d4-cbfd51751f0f	c8deb7f5-e162-4b2f-b722-886f03f232f8	e84eaed7-50c6-4212-9f29-cad60bbee457	پیشرفت اولیه و بررسی نیازمندی‌ها	239	42	2026-07-16	approved	98fba7cd-606b-4e45-957c-f63d3a809e84	\N	36cc1ecd-694c-4b1e-9b59-c40e966ca312	2026-07-21 11:45:44.744086+00	2026-07-21 11:45:44.744086+00
582b48ec-cec0-4e4b-a7d4-cbfd51751f0f	c8deb7f5-e162-4b2f-b722-886f03f232f8	e84eaed7-50c6-4212-9f29-cad60bbee457	تست و اطمینان از عملکرد صحیح	65	100	2026-07-16	approved	98fba7cd-606b-4e45-957c-f63d3a809e84	\N	8fac09a3-440a-46b3-9c99-992aa5cfe666	2026-07-21 11:45:44.744086+00	2026-07-21 11:45:44.744086+00
582b48ec-cec0-4e4b-a7d4-cbfd51751f0f	c8deb7f5-e162-4b2f-b722-886f03f232f8	e84eaed7-50c6-4212-9f29-cad60bbee457	پیشرفت اولیه و بررسی نیازمندی‌ها	211	96	2026-07-16	approved	98fba7cd-606b-4e45-957c-f63d3a809e84	\N	19d74bfc-dbaa-40f0-8dc9-188cd8d23642	2026-07-21 11:45:44.744086+00	2026-07-21 11:45:44.744086+00
582b48ec-cec0-4e4b-a7d4-cbfd51751f0f	c350f564-ce92-47cc-80ed-632299e350af	e84eaed7-50c6-4212-9f29-cad60bbee457	مستندسازی و نهایی‌سازی	146	31	2026-07-16	approved	98fba7cd-606b-4e45-957c-f63d3a809e84	\N	15e34fb0-955a-4a35-9a3f-34bd961d56f0	2026-07-21 11:45:44.744086+00	2026-07-21 11:45:44.744086+00
582b48ec-cec0-4e4b-a7d4-cbfd51751f0f	bccb8cf3-2079-4a84-bbb2-3abc24d2d645	2e6fa9ea-43da-47ab-a8a8-e2e58360f575	تست و اطمینان از عملکرد صحیح	34	20	2026-06-20	approved	98fba7cd-606b-4e45-957c-f63d3a809e84	\N	9d72c7b4-bd43-4517-8a97-ac51a4fda47c	2026-07-21 11:45:44.744086+00	2026-07-21 11:45:44.744086+00
582b48ec-cec0-4e4b-a7d4-cbfd51751f0f	94f807cd-41a1-4142-8be8-e4a93b353292	c057add9-a37a-4d8b-adb3-be28effacb81	پیشرفت اولیه و بررسی نیازمندی‌ها	165	28	2026-06-25	approved	98fba7cd-606b-4e45-957c-f63d3a809e84	\N	6d003f28-cd11-4a7c-b63d-035e0c13f815	2026-07-21 11:45:44.744086+00	2026-07-21 11:45:44.744086+00
582b48ec-cec0-4e4b-a7d4-cbfd51751f0f	94f807cd-41a1-4142-8be8-e4a93b353292	c057add9-a37a-4d8b-adb3-be28effacb81	پیشرفت اولیه و بررسی نیازمندی‌ها	158	66	2026-06-28	approved	98fba7cd-606b-4e45-957c-f63d3a809e84	\N	7b75d09e-5d8d-4b8e-a9ea-aae1631b4660	2026-07-21 11:45:44.744086+00	2026-07-21 11:45:44.744086+00
582b48ec-cec0-4e4b-a7d4-cbfd51751f0f	94f807cd-41a1-4142-8be8-e4a93b353292	c057add9-a37a-4d8b-adb3-be28effacb81	پیشرفت اولیه و بررسی نیازمندی‌ها	54	100	2026-06-29	approved	98fba7cd-606b-4e45-957c-f63d3a809e84	\N	fe477c27-842a-436d-97b4-0bf56262a8c7	2026-07-21 11:45:44.744086+00	2026-07-21 11:45:44.744086+00
582b48ec-cec0-4e4b-a7d4-cbfd51751f0f	94f807cd-41a1-4142-8be8-e4a93b353292	c057add9-a37a-4d8b-adb3-be28effacb81	پیاده‌سازی بخش اصلی	79	100	2026-07-01	approved	98fba7cd-606b-4e45-957c-f63d3a809e84	\N	9615f586-f475-4d4e-ab4e-c249f8d64521	2026-07-21 11:45:44.744086+00	2026-07-21 11:45:44.744086+00
582b48ec-cec0-4e4b-a7d4-cbfd51751f0f	3942bcea-060f-48d8-b6e5-77bbe167cf9e	98fba7cd-606b-4e45-957c-f63d3a809e84	رفع اشکالات و بازبینی	233	32	2026-07-09	approved	98fba7cd-606b-4e45-957c-f63d3a809e84	\N	d6add8e7-880c-4fbd-a3c8-f2cfb568f6fd	2026-07-21 11:45:44.744086+00	2026-07-21 11:45:44.744086+00
582b48ec-cec0-4e4b-a7d4-cbfd51751f0f	3942bcea-060f-48d8-b6e5-77bbe167cf9e	98fba7cd-606b-4e45-957c-f63d3a809e84	رفع اشکالات و بازبینی	133	68	2026-07-10	approved	98fba7cd-606b-4e45-957c-f63d3a809e84	\N	0f4919d6-7b26-433c-bddf-d03974aafd6a	2026-07-21 11:45:44.744086+00	2026-07-21 11:45:44.744086+00
582b48ec-cec0-4e4b-a7d4-cbfd51751f0f	3942bcea-060f-48d8-b6e5-77bbe167cf9e	98fba7cd-606b-4e45-957c-f63d3a809e84	پیاده‌سازی بخش اصلی	106	66	2026-07-13	approved	98fba7cd-606b-4e45-957c-f63d3a809e84	\N	f333e392-7d1e-4745-9317-96cd13ee2896	2026-07-21 11:45:44.744086+00	2026-07-21 11:45:44.744086+00
582b48ec-cec0-4e4b-a7d4-cbfd51751f0f	8056b766-45c1-4659-9191-e8d5ee24b7d9	98fba7cd-606b-4e45-957c-f63d3a809e84	تست و اطمینان از عملکرد صحیح	171	35	2026-07-16	approved	98fba7cd-606b-4e45-957c-f63d3a809e84	\N	d923039b-780f-4c5b-b69e-e25c1b7b46a9	2026-07-21 11:45:44.744086+00	2026-07-21 11:45:44.744086+00
582b48ec-cec0-4e4b-a7d4-cbfd51751f0f	54014097-0aff-4ae2-9553-4e076b21b100	e84eaed7-50c6-4212-9f29-cad60bbee457	پیاده‌سازی بخش اصلی	51	35	2026-07-16	approved	98fba7cd-606b-4e45-957c-f63d3a809e84	\N	8b3cd400-59c4-45cb-bebc-ba801cf4d2cf	2026-07-21 11:45:44.744086+00	2026-07-21 11:45:44.744086+00
582b48ec-cec0-4e4b-a7d4-cbfd51751f0f	78a1bc08-c6f0-462d-8cd4-8066b3290bd0	2e6fa9ea-43da-47ab-a8a8-e2e58360f575	مستندسازی و نهایی‌سازی	54	36	2026-07-09	approved	98fba7cd-606b-4e45-957c-f63d3a809e84	\N	bc7e86b7-ce2b-4997-8768-35d35dd8d4c8	2026-07-21 11:45:44.744086+00	2026-07-21 11:45:44.744086+00
582b48ec-cec0-4e4b-a7d4-cbfd51751f0f	78a1bc08-c6f0-462d-8cd4-8066b3290bd0	2e6fa9ea-43da-47ab-a8a8-e2e58360f575	پیاده‌سازی بخش اصلی	84	76	2026-07-10	approved	98fba7cd-606b-4e45-957c-f63d3a809e84	\N	f2d0f1fd-041d-4cdf-95d1-094f34815dd8	2026-07-21 11:45:44.744086+00	2026-07-21 11:45:44.744086+00
582b48ec-cec0-4e4b-a7d4-cbfd51751f0f	78a1bc08-c6f0-462d-8cd4-8066b3290bd0	2e6fa9ea-43da-47ab-a8a8-e2e58360f575	رفع اشکالات و بازبینی	41	66	2026-07-16	approved	98fba7cd-606b-4e45-957c-f63d3a809e84	\N	8286427f-26d4-422a-869d-17f702a4325c	2026-07-21 11:45:44.744086+00	2026-07-21 11:45:44.744086+00
582b48ec-cec0-4e4b-a7d4-cbfd51751f0f	78a1bc08-c6f0-462d-8cd4-8066b3290bd0	2e6fa9ea-43da-47ab-a8a8-e2e58360f575	مستندسازی و نهایی‌سازی	174	84	2026-07-16	approved	98fba7cd-606b-4e45-957c-f63d3a809e84	\N	a08f6f92-794e-4ca8-8c05-9dc583b7bc9d	2026-07-21 11:45:44.744086+00	2026-07-21 11:45:44.744086+00
582b48ec-cec0-4e4b-a7d4-cbfd51751f0f	2932ff48-2462-4b60-95a5-f4974596a72d	c057add9-a37a-4d8b-adb3-be28effacb81	پیشرفت اولیه و بررسی نیازمندی‌ها	83	38	2026-07-16	approved	98fba7cd-606b-4e45-957c-f63d3a809e84	\N	c36760e9-a248-46b4-8f85-55acf59296e2	2026-07-21 11:45:44.744086+00	2026-07-21 11:45:44.744086+00
582b48ec-cec0-4e4b-a7d4-cbfd51751f0f	2932ff48-2462-4b60-95a5-f4974596a72d	c057add9-a37a-4d8b-adb3-be28effacb81	تست و اطمینان از عملکرد صحیح	49	58	2026-07-16	approved	98fba7cd-606b-4e45-957c-f63d3a809e84	\N	cc888679-8ff8-4515-83d9-961d8aef0ae4	2026-07-21 11:45:44.744086+00	2026-07-21 11:45:44.744086+00
582b48ec-cec0-4e4b-a7d4-cbfd51751f0f	a6dd7fc0-a2dc-4c7b-b6f6-f49f2840fcc8	2e6fa9ea-43da-47ab-a8a8-e2e58360f575	مستندسازی و نهایی‌سازی	129	37	2026-07-16	approved	98fba7cd-606b-4e45-957c-f63d3a809e84	\N	7c2e1d9f-e86d-4b74-8c4d-9c62edb1353b	2026-07-21 11:45:44.744086+00	2026-07-21 11:45:44.744086+00
582b48ec-cec0-4e4b-a7d4-cbfd51751f0f	a6dd7fc0-a2dc-4c7b-b6f6-f49f2840fcc8	2e6fa9ea-43da-47ab-a8a8-e2e58360f575	تست و اطمینان از عملکرد صحیح	223	48	2026-07-16	approved	98fba7cd-606b-4e45-957c-f63d3a809e84	\N	990e86f9-5618-45d8-a21f-1c36f1b92cae	2026-07-21 11:45:44.744086+00	2026-07-21 11:45:44.744086+00
582b48ec-cec0-4e4b-a7d4-cbfd51751f0f	4a1eb704-6aa7-4880-94dc-970545f4d415	e84eaed7-50c6-4212-9f29-cad60bbee457	پیشرفت اولیه و بررسی نیازمندی‌ها	55	33	2026-07-15	approved	98fba7cd-606b-4e45-957c-f63d3a809e84	\N	90e6bd0b-4ee9-4fbc-8ce2-887aad2056d9	2026-07-21 11:45:44.744086+00	2026-07-21 11:45:44.744086+00
582b48ec-cec0-4e4b-a7d4-cbfd51751f0f	22f99812-3d8e-4842-9cd6-eb44b4895f7e	85751a1a-b02d-4121-aff6-407cd2f6ebd7	رفع اشکالات و بازبینی	184	39	2026-06-27	approved	98fba7cd-606b-4e45-957c-f63d3a809e84	\N	5ce55688-583d-42d5-bed3-bd49c1d898c5	2026-07-21 11:45:44.744086+00	2026-07-21 11:45:44.744086+00
582b48ec-cec0-4e4b-a7d4-cbfd51751f0f	22f99812-3d8e-4842-9cd6-eb44b4895f7e	85751a1a-b02d-4121-aff6-407cd2f6ebd7	رفع اشکالات و بازبینی	37	80	2026-07-01	approved	98fba7cd-606b-4e45-957c-f63d3a809e84	\N	bbeb253f-3a39-469b-b10e-d5d80418849f	2026-07-21 11:45:44.744086+00	2026-07-21 11:45:44.744086+00
582b48ec-cec0-4e4b-a7d4-cbfd51751f0f	c010b04a-34e6-4a80-9aa6-2e4294afea9e	2e6fa9ea-43da-47ab-a8a8-e2e58360f575	رفع اشکالات و بازبینی	171	32	2026-07-08	approved	98fba7cd-606b-4e45-957c-f63d3a809e84	\N	1a84ba3c-41fc-4b47-8f9c-4b7b9d9174a4	2026-07-21 11:45:44.744086+00	2026-07-21 11:45:44.744086+00
582b48ec-cec0-4e4b-a7d4-cbfd51751f0f	c010b04a-34e6-4a80-9aa6-2e4294afea9e	2e6fa9ea-43da-47ab-a8a8-e2e58360f575	مستندسازی و نهایی‌سازی	199	64	2026-07-12	approved	98fba7cd-606b-4e45-957c-f63d3a809e84	\N	2311cc74-ca41-4142-af42-06ae945444d4	2026-07-21 11:45:44.744086+00	2026-07-21 11:45:44.744086+00
582b48ec-cec0-4e4b-a7d4-cbfd51751f0f	c010b04a-34e6-4a80-9aa6-2e4294afea9e	2e6fa9ea-43da-47ab-a8a8-e2e58360f575	رفع اشکالات و بازبینی	234	81	2026-07-10	submitted	\N	\N	d6da604e-bcfe-49e2-bafe-a48d9ea4accc	2026-07-21 11:45:44.744086+00	2026-07-21 11:45:44.744086+00
582b48ec-cec0-4e4b-a7d4-cbfd51751f0f	7dde5f75-0842-4802-b3fb-07983e99ffb9	2e6fa9ea-43da-47ab-a8a8-e2e58360f575	رفع اشکالات و بازبینی	69	32	2026-07-16	approved	98fba7cd-606b-4e45-957c-f63d3a809e84	\N	83a8ca28-5689-4154-a865-b20dfb5160ae	2026-07-21 11:45:44.744086+00	2026-07-21 11:45:44.744086+00
582b48ec-cec0-4e4b-a7d4-cbfd51751f0f	b6fb3afc-ffef-4be9-a0ea-ccaad12627ee	60845684-b03a-492a-9937-f8529e7ba409	پیشرفت اولیه و بررسی نیازمندی‌ها	53	20	2026-07-16	approved	98fba7cd-606b-4e45-957c-f63d3a809e84	\N	14795b44-b784-4297-b3ca-95bd472be0b0	2026-07-21 11:45:44.744086+00	2026-07-21 11:45:44.744086+00
582b48ec-cec0-4e4b-a7d4-cbfd51751f0f	b6fb3afc-ffef-4be9-a0ea-ccaad12627ee	60845684-b03a-492a-9937-f8529e7ba409	رفع اشکالات و بازبینی	56	48	2026-07-16	approved	98fba7cd-606b-4e45-957c-f63d3a809e84	\N	58d5b212-0a68-44c6-95c5-e085cec23d4a	2026-07-21 11:45:44.744086+00	2026-07-21 11:45:44.744086+00
582b48ec-cec0-4e4b-a7d4-cbfd51751f0f	ce8458ee-aa52-4282-b0d7-73b7c00c80da	2e6fa9ea-43da-47ab-a8a8-e2e58360f575	تست و اطمینان از عملکرد صحیح	144	37	2026-07-16	approved	98fba7cd-606b-4e45-957c-f63d3a809e84	\N	bb040630-d610-4eb3-99a5-5553bbc8089b	2026-07-21 11:45:44.744086+00	2026-07-21 11:45:44.744086+00
582b48ec-cec0-4e4b-a7d4-cbfd51751f0f	23a57a1d-05a8-4e9a-a494-b1ed0a7a45cd	85751a1a-b02d-4121-aff6-407cd2f6ebd7	پیشرفت اولیه و بررسی نیازمندی‌ها	52	31	2026-07-15	approved	98fba7cd-606b-4e45-957c-f63d3a809e84	\N	ceeeaf10-d947-467e-a346-a8d8be4f0b7b	2026-07-21 11:45:44.744086+00	2026-07-21 11:45:44.744086+00
582b48ec-cec0-4e4b-a7d4-cbfd51751f0f	23a57a1d-05a8-4e9a-a494-b1ed0a7a45cd	85751a1a-b02d-4121-aff6-407cd2f6ebd7	مستندسازی و نهایی‌سازی	183	60	2026-07-16	approved	98fba7cd-606b-4e45-957c-f63d3a809e84	\N	59a9eaf1-4233-4caf-a211-2c91d973c942	2026-07-21 11:45:44.744086+00	2026-07-21 11:45:44.744086+00
582b48ec-cec0-4e4b-a7d4-cbfd51751f0f	23a57a1d-05a8-4e9a-a494-b1ed0a7a45cd	85751a1a-b02d-4121-aff6-407cd2f6ebd7	پیشرفت اولیه و بررسی نیازمندی‌ها	104	99	2026-07-16	approved	98fba7cd-606b-4e45-957c-f63d3a809e84	\N	f25572d0-6cf2-4a6e-a805-4f1ab9a8c83b	2026-07-21 11:45:44.744086+00	2026-07-21 11:45:44.744086+00
582b48ec-cec0-4e4b-a7d4-cbfd51751f0f	23a57a1d-05a8-4e9a-a494-b1ed0a7a45cd	85751a1a-b02d-4121-aff6-407cd2f6ebd7	پیشرفت اولیه و بررسی نیازمندی‌ها	215	100	2026-07-16	approved	98fba7cd-606b-4e45-957c-f63d3a809e84	\N	4018394c-b929-4bd0-a8f7-367588c0f53f	2026-07-21 11:45:44.744086+00	2026-07-21 11:45:44.744086+00
582b48ec-cec0-4e4b-a7d4-cbfd51751f0f	efd42a51-af7b-420a-a2e3-e14737ec0442	c057add9-a37a-4d8b-adb3-be28effacb81	تست و اطمینان از عملکرد صحیح	73	24	2026-07-07	approved	98fba7cd-606b-4e45-957c-f63d3a809e84	\N	b61d6915-93c4-4915-878d-b0b17387c4d6	2026-07-21 11:45:44.744086+00	2026-07-21 11:45:44.744086+00
582b48ec-cec0-4e4b-a7d4-cbfd51751f0f	efd42a51-af7b-420a-a2e3-e14737ec0442	c057add9-a37a-4d8b-adb3-be28effacb81	رفع اشکالات و بازبینی	98	70	2026-07-10	approved	98fba7cd-606b-4e45-957c-f63d3a809e84	\N	5fccf22c-26c3-4009-b121-936f388c116c	2026-07-21 11:45:44.744086+00	2026-07-21 11:45:44.744086+00
582b48ec-cec0-4e4b-a7d4-cbfd51751f0f	7cb086d1-e0a4-41e0-8706-9b7890272faa	e84eaed7-50c6-4212-9f29-cad60bbee457	پیاده‌سازی بخش اصلی	141	28	2026-07-16	approved	98fba7cd-606b-4e45-957c-f63d3a809e84	\N	5f2dd54f-f202-49da-b693-30eb2e47816e	2026-07-21 11:45:44.744086+00	2026-07-21 11:45:44.744086+00
582b48ec-cec0-4e4b-a7d4-cbfd51751f0f	7cb086d1-e0a4-41e0-8706-9b7890272faa	e84eaed7-50c6-4212-9f29-cad60bbee457	رفع اشکالات و بازبینی	153	44	2026-07-16	approved	98fba7cd-606b-4e45-957c-f63d3a809e84	\N	ab925701-4177-4959-9c7a-05a01a80ed46	2026-07-21 11:45:44.744086+00	2026-07-21 11:45:44.744086+00
582b48ec-cec0-4e4b-a7d4-cbfd51751f0f	1ec2aefb-b0b3-45ba-bbfd-62ffad9cafe6	98fba7cd-606b-4e45-957c-f63d3a809e84	تست و اطمینان از عملکرد صحیح	182	39	2026-07-01	submitted	\N	\N	dd65f0d9-7b50-46a7-931f-08759a3b7f8e	2026-07-21 11:45:44.744086+00	2026-07-21 11:45:44.744086+00
582b48ec-cec0-4e4b-a7d4-cbfd51751f0f	1ec2aefb-b0b3-45ba-bbfd-62ffad9cafe6	98fba7cd-606b-4e45-957c-f63d3a809e84	پیاده‌سازی بخش اصلی	107	40	2026-07-03	approved	98fba7cd-606b-4e45-957c-f63d3a809e84	\N	cb0dc9b4-8187-402d-accd-253c4462b735	2026-07-21 11:45:44.744086+00	2026-07-21 11:45:44.744086+00
582b48ec-cec0-4e4b-a7d4-cbfd51751f0f	1ec2aefb-b0b3-45ba-bbfd-62ffad9cafe6	98fba7cd-606b-4e45-957c-f63d3a809e84	مستندسازی و نهایی‌سازی	127	90	2026-07-09	approved	98fba7cd-606b-4e45-957c-f63d3a809e84	\N	29387a5b-855e-453c-8cdb-5a162c82c746	2026-07-21 11:45:44.744086+00	2026-07-21 11:45:44.744086+00
582b48ec-cec0-4e4b-a7d4-cbfd51751f0f	13f3b26b-1879-471c-bfff-aade440357c6	76c11995-60dc-42d9-9a92-6dc9daa80ce9	تست و اطمینان از عملکرد صحیح	238	40	2026-07-15	approved	98fba7cd-606b-4e45-957c-f63d3a809e84	\N	8baadd04-df53-43c3-ad83-4dc4d71bbbc2	2026-07-21 11:45:44.744086+00	2026-07-21 11:45:44.744086+00
582b48ec-cec0-4e4b-a7d4-cbfd51751f0f	13f3b26b-1879-471c-bfff-aade440357c6	76c11995-60dc-42d9-9a92-6dc9daa80ce9	رفع اشکالات و بازبینی	112	78	2026-07-16	approved	98fba7cd-606b-4e45-957c-f63d3a809e84	\N	7b18ca2f-304b-41ec-b2b9-14cd5972004d	2026-07-21 11:45:44.744086+00	2026-07-21 11:45:44.744086+00
582b48ec-cec0-4e4b-a7d4-cbfd51751f0f	13f3b26b-1879-471c-bfff-aade440357c6	76c11995-60dc-42d9-9a92-6dc9daa80ce9	تست و اطمینان از عملکرد صحیح	110	75	2026-07-16	approved	98fba7cd-606b-4e45-957c-f63d3a809e84	\N	788a2bfc-7f73-4830-966e-8c581d4482dc	2026-07-21 11:45:44.744086+00	2026-07-21 11:45:44.744086+00
582b48ec-cec0-4e4b-a7d4-cbfd51751f0f	13f3b26b-1879-471c-bfff-aade440357c6	76c11995-60dc-42d9-9a92-6dc9daa80ce9	رفع اشکالات و بازبینی	104	100	2026-07-16	approved	98fba7cd-606b-4e45-957c-f63d3a809e84	\N	14b8f2d2-a8f0-47e5-9e66-5b60452509a8	2026-07-21 11:45:44.744086+00	2026-07-21 11:45:44.744086+00
582b48ec-cec0-4e4b-a7d4-cbfd51751f0f	e7208c77-0fae-488a-9f30-ca645861eb0f	98fba7cd-606b-4e45-957c-f63d3a809e84	رفع اشکالات و بازبینی	239	32	2026-07-16	approved	98fba7cd-606b-4e45-957c-f63d3a809e84	\N	ca0bec77-06e4-4d51-a3de-707e711f00a9	2026-07-21 11:45:44.744086+00	2026-07-21 11:45:44.744086+00
582b48ec-cec0-4e4b-a7d4-cbfd51751f0f	e7208c77-0fae-488a-9f30-ca645861eb0f	98fba7cd-606b-4e45-957c-f63d3a809e84	مستندسازی و نهایی‌سازی	81	76	2026-07-16	approved	98fba7cd-606b-4e45-957c-f63d3a809e84	\N	cad42bd9-5d92-4de4-aa2f-804c2743cc0a	2026-07-21 11:45:44.744086+00	2026-07-21 11:45:44.744086+00
582b48ec-cec0-4e4b-a7d4-cbfd51751f0f	e7208c77-0fae-488a-9f30-ca645861eb0f	98fba7cd-606b-4e45-957c-f63d3a809e84	مستندسازی و نهایی‌سازی	36	100	2026-07-16	approved	98fba7cd-606b-4e45-957c-f63d3a809e84	\N	ce91044e-3fee-40db-b9fd-6c39134e9256	2026-07-21 11:45:44.744086+00	2026-07-21 11:45:44.744086+00
582b48ec-cec0-4e4b-a7d4-cbfd51751f0f	e7208c77-0fae-488a-9f30-ca645861eb0f	98fba7cd-606b-4e45-957c-f63d3a809e84	رفع اشکالات و بازبینی	207	88	2026-07-16	approved	98fba7cd-606b-4e45-957c-f63d3a809e84	\N	2b59fcda-9c65-40d2-aadd-8ffcd9378342	2026-07-21 11:45:44.744086+00	2026-07-21 11:45:44.744086+00
582b48ec-cec0-4e4b-a7d4-cbfd51751f0f	a00ec283-789f-4af3-8e68-d6ae50c0f36d	98fba7cd-606b-4e45-957c-f63d3a809e84	رفع اشکالات و بازبینی	91	28	2026-07-16	approved	98fba7cd-606b-4e45-957c-f63d3a809e84	\N	48bfd8aa-7c98-4efa-bb9e-5b1a21a10159	2026-07-21 11:45:44.744086+00	2026-07-21 11:45:44.744086+00
582b48ec-cec0-4e4b-a7d4-cbfd51751f0f	a00ec283-789f-4af3-8e68-d6ae50c0f36d	98fba7cd-606b-4e45-957c-f63d3a809e84	تست و اطمینان از عملکرد صحیح	48	68	2026-07-16	submitted	\N	\N	5d41d549-8618-4de4-a025-3a591304c978	2026-07-21 11:45:44.744086+00	2026-07-21 11:45:44.744086+00
582b48ec-cec0-4e4b-a7d4-cbfd51751f0f	a00ec283-789f-4af3-8e68-d6ae50c0f36d	98fba7cd-606b-4e45-957c-f63d3a809e84	مستندسازی و نهایی‌سازی	159	99	2026-07-16	approved	98fba7cd-606b-4e45-957c-f63d3a809e84	\N	ce1c825c-1918-4df4-8290-ea46ac2ff1a1	2026-07-21 11:45:44.744086+00	2026-07-21 11:45:44.744086+00
582b48ec-cec0-4e4b-a7d4-cbfd51751f0f	a00ec283-789f-4af3-8e68-d6ae50c0f36d	98fba7cd-606b-4e45-957c-f63d3a809e84	رفع اشکالات و بازبینی	209	100	2026-07-16	submitted	\N	\N	c0dce372-6cc5-4046-83f6-8c8a1f769e70	2026-07-21 11:45:44.744086+00	2026-07-21 11:45:44.744086+00
582b48ec-cec0-4e4b-a7d4-cbfd51751f0f	4454a24a-64ec-4af3-923d-82eaf0a443c9	60845684-b03a-492a-9937-f8529e7ba409	پیاده‌سازی بخش اصلی	198	31	2026-06-24	approved	98fba7cd-606b-4e45-957c-f63d3a809e84	\N	e662ae94-0ee4-497a-bff4-ba75e7b561c8	2026-07-21 11:45:44.744086+00	2026-07-21 11:45:44.744086+00
582b48ec-cec0-4e4b-a7d4-cbfd51751f0f	460c6c7a-e99c-4d64-8741-4bbc11dd5944	e84eaed7-50c6-4212-9f29-cad60bbee457	مستندسازی و نهایی‌سازی	195	40	2026-07-16	approved	98fba7cd-606b-4e45-957c-f63d3a809e84	\N	54198db4-1a48-4eae-8024-0bf5844d1380	2026-07-21 11:45:44.744086+00	2026-07-21 11:45:44.744086+00
582b48ec-cec0-4e4b-a7d4-cbfd51751f0f	460c6c7a-e99c-4d64-8741-4bbc11dd5944	e84eaed7-50c6-4212-9f29-cad60bbee457	رفع اشکالات و بازبینی	233	66	2026-07-16	approved	98fba7cd-606b-4e45-957c-f63d3a809e84	\N	9bc8756f-e05c-4495-9d27-22e688c505ab	2026-07-21 11:45:44.744086+00	2026-07-21 11:45:44.744086+00
582b48ec-cec0-4e4b-a7d4-cbfd51751f0f	1841ee83-56ec-4134-9428-0e8628059a10	60845684-b03a-492a-9937-f8529e7ba409	پیشرفت اولیه و بررسی نیازمندی‌ها	96	27	2026-07-16	approved	98fba7cd-606b-4e45-957c-f63d3a809e84	\N	cbb46c29-2a1d-4fe3-ad2f-a8820573c592	2026-07-21 11:45:44.744086+00	2026-07-21 11:45:44.744086+00
582b48ec-cec0-4e4b-a7d4-cbfd51751f0f	beafa52d-0513-4d6a-b9ca-eb5b650e92a2	85751a1a-b02d-4121-aff6-407cd2f6ebd7	رفع اشکالات و بازبینی	130	34	2026-07-16	approved	98fba7cd-606b-4e45-957c-f63d3a809e84	\N	0bd1c10a-3a5c-4279-95ac-0a8b4d37c3b2	2026-07-21 11:45:44.744086+00	2026-07-21 11:45:44.744086+00
582b48ec-cec0-4e4b-a7d4-cbfd51751f0f	beafa52d-0513-4d6a-b9ca-eb5b650e92a2	85751a1a-b02d-4121-aff6-407cd2f6ebd7	رفع اشکالات و بازبینی	36	70	2026-07-16	approved	98fba7cd-606b-4e45-957c-f63d3a809e84	\N	43f8d35c-daf8-4384-926c-bfd26a412e65	2026-07-21 11:45:44.744086+00	2026-07-21 11:45:44.744086+00
582b48ec-cec0-4e4b-a7d4-cbfd51751f0f	c829b7a8-ed11-401b-8359-3b27c5ccc22b	e84eaed7-50c6-4212-9f29-cad60bbee457	پیشرفت اولیه و بررسی نیازمندی‌ها	59	24	2026-07-16	approved	98fba7cd-606b-4e45-957c-f63d3a809e84	\N	9ef19ce4-488a-4525-b265-54c4c40ee507	2026-07-21 11:45:44.744086+00	2026-07-21 11:45:44.744086+00
582b48ec-cec0-4e4b-a7d4-cbfd51751f0f	4e306c1c-aac7-470f-a859-1e1296846a28	2e6fa9ea-43da-47ab-a8a8-e2e58360f575	رفع اشکالات و بازبینی	146	26	2026-07-16	approved	98fba7cd-606b-4e45-957c-f63d3a809e84	\N	7d08966c-0a16-49d7-a54b-25c98090c6b6	2026-07-21 11:45:44.744086+00	2026-07-21 11:45:44.744086+00
582b48ec-cec0-4e4b-a7d4-cbfd51751f0f	4e306c1c-aac7-470f-a859-1e1296846a28	2e6fa9ea-43da-47ab-a8a8-e2e58360f575	رفع اشکالات و بازبینی	151	46	2026-07-16	approved	98fba7cd-606b-4e45-957c-f63d3a809e84	\N	3e515595-9a92-4fc7-9c18-f35025733aa9	2026-07-21 11:45:44.744086+00	2026-07-21 11:45:44.744086+00
582b48ec-cec0-4e4b-a7d4-cbfd51751f0f	4e306c1c-aac7-470f-a859-1e1296846a28	2e6fa9ea-43da-47ab-a8a8-e2e58360f575	تست و اطمینان از عملکرد صحیح	111	66	2026-07-16	approved	98fba7cd-606b-4e45-957c-f63d3a809e84	\N	df2f2b00-fd9d-4be3-8476-db877ef031b3	2026-07-21 11:45:44.744086+00	2026-07-21 11:45:44.744086+00
582b48ec-cec0-4e4b-a7d4-cbfd51751f0f	129c6ffb-324f-4445-a611-6ff9e0dfdc9c	85751a1a-b02d-4121-aff6-407cd2f6ebd7	پیشرفت اولیه و بررسی نیازمندی‌ها	35	30	2026-07-16	approved	98fba7cd-606b-4e45-957c-f63d3a809e84	\N	074c37c2-85c0-44bd-b941-187465a1b8cd	2026-07-21 11:45:44.744086+00	2026-07-21 11:45:44.744086+00
582b48ec-cec0-4e4b-a7d4-cbfd51751f0f	129c6ffb-324f-4445-a611-6ff9e0dfdc9c	85751a1a-b02d-4121-aff6-407cd2f6ebd7	پیاده‌سازی بخش اصلی	219	54	2026-07-16	approved	98fba7cd-606b-4e45-957c-f63d3a809e84	\N	d34b1a4f-d51d-49dd-8894-b95cf1b3c8e5	2026-07-21 11:45:44.744086+00	2026-07-21 11:45:44.744086+00
582b48ec-cec0-4e4b-a7d4-cbfd51751f0f	129c6ffb-324f-4445-a611-6ff9e0dfdc9c	85751a1a-b02d-4121-aff6-407cd2f6ebd7	مستندسازی و نهایی‌سازی	70	90	2026-07-16	approved	98fba7cd-606b-4e45-957c-f63d3a809e84	\N	cd8afce3-ff85-4793-ba4c-9462c254fc0c	2026-07-21 11:45:44.744086+00	2026-07-21 11:45:44.744086+00
582b48ec-cec0-4e4b-a7d4-cbfd51751f0f	69811bc7-8527-4c75-a5e1-0997542a22e9	2e6fa9ea-43da-47ab-a8a8-e2e58360f575	پیاده‌سازی بخش اصلی	234	32	2026-07-16	approved	98fba7cd-606b-4e45-957c-f63d3a809e84	\N	a144937a-031a-4f89-9a41-292e49eb781b	2026-07-21 11:45:44.744086+00	2026-07-21 11:45:44.744086+00
582b48ec-cec0-4e4b-a7d4-cbfd51751f0f	69811bc7-8527-4c75-a5e1-0997542a22e9	2e6fa9ea-43da-47ab-a8a8-e2e58360f575	پیاده‌سازی بخش اصلی	193	66	2026-07-16	approved	98fba7cd-606b-4e45-957c-f63d3a809e84	\N	8b560c42-aa9c-4b7b-9a1b-cf5a6dbec9b1	2026-07-21 11:45:44.744086+00	2026-07-21 11:45:44.744086+00
582b48ec-cec0-4e4b-a7d4-cbfd51751f0f	69811bc7-8527-4c75-a5e1-0997542a22e9	2e6fa9ea-43da-47ab-a8a8-e2e58360f575	پیشرفت اولیه و بررسی نیازمندی‌ها	218	100	2026-07-16	approved	98fba7cd-606b-4e45-957c-f63d3a809e84	\N	ed5d81be-8a94-4d9b-8be3-1b2a783609c7	2026-07-21 11:45:44.744086+00	2026-07-21 11:45:44.744086+00
582b48ec-cec0-4e4b-a7d4-cbfd51751f0f	69811bc7-8527-4c75-a5e1-0997542a22e9	2e6fa9ea-43da-47ab-a8a8-e2e58360f575	تست و اطمینان از عملکرد صحیح	181	100	2026-07-16	approved	98fba7cd-606b-4e45-957c-f63d3a809e84	\N	9bcd1d4e-99d4-45ce-9b5d-9052efb824d8	2026-07-21 11:45:44.744086+00	2026-07-21 11:45:44.744086+00
582b48ec-cec0-4e4b-a7d4-cbfd51751f0f	15a336b4-a631-41c9-a621-16e8590c82ed	2e6fa9ea-43da-47ab-a8a8-e2e58360f575	پیاده‌سازی بخش اصلی	101	22	2026-07-12	submitted	\N	\N	2931ba4d-bb0f-47ac-8715-571b3651676f	2026-07-21 11:45:44.744086+00	2026-07-21 11:45:44.744086+00
582b48ec-cec0-4e4b-a7d4-cbfd51751f0f	15a336b4-a631-41c9-a621-16e8590c82ed	2e6fa9ea-43da-47ab-a8a8-e2e58360f575	مستندسازی و نهایی‌سازی	77	62	2026-07-13	submitted	\N	\N	cb53e30c-ea2b-4247-aeab-ced12c63d983	2026-07-21 11:45:44.744086+00	2026-07-21 11:45:44.744086+00
582b48ec-cec0-4e4b-a7d4-cbfd51751f0f	15a336b4-a631-41c9-a621-16e8590c82ed	2e6fa9ea-43da-47ab-a8a8-e2e58360f575	پیشرفت اولیه و بررسی نیازمندی‌ها	97	100	2026-07-16	approved	98fba7cd-606b-4e45-957c-f63d3a809e84	\N	e4564ff3-189a-4440-adf7-9fc03dc2a357	2026-07-21 11:45:44.744086+00	2026-07-21 11:45:44.744086+00
582b48ec-cec0-4e4b-a7d4-cbfd51751f0f	15a336b4-a631-41c9-a621-16e8590c82ed	2e6fa9ea-43da-47ab-a8a8-e2e58360f575	مستندسازی و نهایی‌سازی	130	100	2026-07-16	approved	98fba7cd-606b-4e45-957c-f63d3a809e84	\N	10b9c355-9fc4-4640-b2ef-5e16493be16c	2026-07-21 11:45:44.744086+00	2026-07-21 11:45:44.744086+00
582b48ec-cec0-4e4b-a7d4-cbfd51751f0f	c56ef05a-0a0a-4b59-be0d-4d3560b3c304	2e6fa9ea-43da-47ab-a8a8-e2e58360f575	رفع اشکالات و بازبینی	147	39	2026-06-19	approved	98fba7cd-606b-4e45-957c-f63d3a809e84	\N	450df8a0-eb82-402e-bfd2-f1beeba7d274	2026-07-21 11:45:44.744086+00	2026-07-21 11:45:44.744086+00
582b48ec-cec0-4e4b-a7d4-cbfd51751f0f	fece6319-751a-4b3f-b354-1b7d3733d503	2e6fa9ea-43da-47ab-a8a8-e2e58360f575	مستندسازی و نهایی‌سازی	181	22	2026-07-06	approved	98fba7cd-606b-4e45-957c-f63d3a809e84	\N	5730801b-00a6-43fa-8df0-25092910e303	2026-07-21 11:45:44.744086+00	2026-07-21 11:45:44.744086+00
582b48ec-cec0-4e4b-a7d4-cbfd51751f0f	fece6319-751a-4b3f-b354-1b7d3733d503	2e6fa9ea-43da-47ab-a8a8-e2e58360f575	رفع اشکالات و بازبینی	60	54	2026-07-08	approved	98fba7cd-606b-4e45-957c-f63d3a809e84	\N	eb3b2294-0956-4a3a-a9ee-385daf83fd3c	2026-07-21 11:45:44.744086+00	2026-07-21 11:45:44.744086+00
582b48ec-cec0-4e4b-a7d4-cbfd51751f0f	18d8d890-4ed4-41cb-b6cf-5b9308a4f95f	e84eaed7-50c6-4212-9f29-cad60bbee457	پیاده‌سازی بخش اصلی	125	24	2026-07-16	approved	98fba7cd-606b-4e45-957c-f63d3a809e84	\N	419d481e-6ed3-46ba-839f-b9644c5d8395	2026-07-21 11:45:44.744086+00	2026-07-21 11:45:44.744086+00
582b48ec-cec0-4e4b-a7d4-cbfd51751f0f	18d8d890-4ed4-41cb-b6cf-5b9308a4f95f	e84eaed7-50c6-4212-9f29-cad60bbee457	تست و اطمینان از عملکرد صحیح	182	48	2026-07-16	approved	98fba7cd-606b-4e45-957c-f63d3a809e84	\N	1dfc67b9-1926-4694-86a9-b4518d620a87	2026-07-21 11:45:44.744086+00	2026-07-21 11:45:44.744086+00
582b48ec-cec0-4e4b-a7d4-cbfd51751f0f	18d8d890-4ed4-41cb-b6cf-5b9308a4f95f	e84eaed7-50c6-4212-9f29-cad60bbee457	تست و اطمینان از عملکرد صحیح	77	100	2026-07-16	approved	98fba7cd-606b-4e45-957c-f63d3a809e84	\N	d0780314-543d-4c3b-ac8f-921ae3469d73	2026-07-21 11:45:44.744086+00	2026-07-21 11:45:44.744086+00
582b48ec-cec0-4e4b-a7d4-cbfd51751f0f	5abbdcd7-05f2-464d-bd3e-0cb6f405d1a0	76c11995-60dc-42d9-9a92-6dc9daa80ce9	پیاده‌سازی بخش اصلی	77	30	2026-07-16	approved	98fba7cd-606b-4e45-957c-f63d3a809e84	\N	1580a9c1-1135-49fb-ba93-659e2898901c	2026-07-21 11:45:44.744086+00	2026-07-21 11:45:44.744086+00
582b48ec-cec0-4e4b-a7d4-cbfd51751f0f	5abbdcd7-05f2-464d-bd3e-0cb6f405d1a0	76c11995-60dc-42d9-9a92-6dc9daa80ce9	رفع اشکالات و بازبینی	32	70	2026-07-16	approved	98fba7cd-606b-4e45-957c-f63d3a809e84	\N	ac28ff7d-298c-4d43-96d8-c71276ac89a1	2026-07-21 11:45:44.744086+00	2026-07-21 11:45:44.744086+00
582b48ec-cec0-4e4b-a7d4-cbfd51751f0f	d78f57ee-04d1-4a8f-bf33-c0c5f18087f7	2e6fa9ea-43da-47ab-a8a8-e2e58360f575	تست و اطمینان از عملکرد صحیح	173	36	2026-07-16	approved	98fba7cd-606b-4e45-957c-f63d3a809e84	\N	fbe1f234-c8d4-432c-b3c0-107e9e813882	2026-07-21 11:45:44.744086+00	2026-07-21 11:45:44.744086+00
582b48ec-cec0-4e4b-a7d4-cbfd51751f0f	d78f57ee-04d1-4a8f-bf33-c0c5f18087f7	2e6fa9ea-43da-47ab-a8a8-e2e58360f575	تست و اطمینان از عملکرد صحیح	205	70	2026-07-16	approved	98fba7cd-606b-4e45-957c-f63d3a809e84	\N	97570d42-7da6-4d0b-a2a6-9c7911c6d330	2026-07-21 11:45:44.744086+00	2026-07-21 11:45:44.744086+00
582b48ec-cec0-4e4b-a7d4-cbfd51751f0f	978e80ae-810d-40b4-afba-79f9c796f856	85751a1a-b02d-4121-aff6-407cd2f6ebd7	تست و اطمینان از عملکرد صحیح	72	22	2026-07-03	approved	98fba7cd-606b-4e45-957c-f63d3a809e84	\N	a7b00be6-f245-4b6a-8351-febfb835412d	2026-07-21 11:45:44.744086+00	2026-07-21 11:45:44.744086+00
582b48ec-cec0-4e4b-a7d4-cbfd51751f0f	978e80ae-810d-40b4-afba-79f9c796f856	85751a1a-b02d-4121-aff6-407cd2f6ebd7	پیاده‌سازی بخش اصلی	104	42	2026-07-04	approved	98fba7cd-606b-4e45-957c-f63d3a809e84	\N	60473e5f-6f39-43aa-ab25-e385c5901270	2026-07-21 11:45:44.744086+00	2026-07-21 11:45:44.744086+00
582b48ec-cec0-4e4b-a7d4-cbfd51751f0f	978e80ae-810d-40b4-afba-79f9c796f856	85751a1a-b02d-4121-aff6-407cd2f6ebd7	پیاده‌سازی بخش اصلی	167	87	2026-07-09	approved	98fba7cd-606b-4e45-957c-f63d3a809e84	\N	db596d95-47ca-423d-815f-8c287c2252f4	2026-07-21 11:45:44.744086+00	2026-07-21 11:45:44.744086+00
582b48ec-cec0-4e4b-a7d4-cbfd51751f0f	978e80ae-810d-40b4-afba-79f9c796f856	85751a1a-b02d-4121-aff6-407cd2f6ebd7	تست و اطمینان از عملکرد صحیح	174	100	2026-07-09	approved	98fba7cd-606b-4e45-957c-f63d3a809e84	\N	a6ff0a04-0f47-4842-8d3a-c5f7b141de84	2026-07-21 11:45:44.744086+00	2026-07-21 11:45:44.744086+00
582b48ec-cec0-4e4b-a7d4-cbfd51751f0f	ca92c38d-7fbe-4d8d-9614-4661a9875f3d	c057add9-a37a-4d8b-adb3-be28effacb81	مستندسازی و نهایی‌سازی	240	31	2026-07-16	approved	98fba7cd-606b-4e45-957c-f63d3a809e84	\N	464a3c87-d6a5-441b-b674-8e26392bb1ec	2026-07-21 11:45:44.744086+00	2026-07-21 11:45:44.744086+00
582b48ec-cec0-4e4b-a7d4-cbfd51751f0f	c5681ee5-ba89-46c3-933f-9fa95a7a0ef1	98fba7cd-606b-4e45-957c-f63d3a809e84	تست و اطمینان از عملکرد صحیح	56	40	2026-07-16	approved	98fba7cd-606b-4e45-957c-f63d3a809e84	\N	da984ef5-0af4-404e-bcdf-f23b9c668fc9	2026-07-21 11:45:44.744086+00	2026-07-21 11:45:44.744086+00
582b48ec-cec0-4e4b-a7d4-cbfd51751f0f	21189cc8-f645-4822-a44d-c234451bf2a5	85751a1a-b02d-4121-aff6-407cd2f6ebd7	پیشرفت اولیه و بررسی نیازمندی‌ها	145	28	2026-07-16	approved	98fba7cd-606b-4e45-957c-f63d3a809e84	\N	e042058a-3b40-48e1-8677-50a7bdbb45d8	2026-07-21 11:45:44.744086+00	2026-07-21 11:45:44.744086+00
582b48ec-cec0-4e4b-a7d4-cbfd51751f0f	21189cc8-f645-4822-a44d-c234451bf2a5	85751a1a-b02d-4121-aff6-407cd2f6ebd7	پیشرفت اولیه و بررسی نیازمندی‌ها	142	46	2026-07-16	approved	98fba7cd-606b-4e45-957c-f63d3a809e84	\N	ea31f91c-1377-4cb2-8df7-5956d029ebbd	2026-07-21 11:45:44.744086+00	2026-07-21 11:45:44.744086+00
582b48ec-cec0-4e4b-a7d4-cbfd51751f0f	8502304e-5c15-4d44-8c96-fe60bde748b5	60845684-b03a-492a-9937-f8529e7ba409	مستندسازی و نهایی‌سازی	206	31	2026-07-01	submitted	\N	\N	6e05ef25-a40e-471f-8cdd-ad1194cda30d	2026-07-21 11:45:44.744086+00	2026-07-21 11:45:44.744086+00
582b48ec-cec0-4e4b-a7d4-cbfd51751f0f	8502304e-5c15-4d44-8c96-fe60bde748b5	60845684-b03a-492a-9937-f8529e7ba409	پیاده‌سازی بخش اصلی	230	52	2026-07-05	approved	98fba7cd-606b-4e45-957c-f63d3a809e84	\N	eae4bda9-2686-4d50-abfb-58960b1eb7d9	2026-07-21 11:45:44.744086+00	2026-07-21 11:45:44.744086+00
582b48ec-cec0-4e4b-a7d4-cbfd51751f0f	a8fff62c-f697-4c1d-8aa9-0caf91f8a228	76c11995-60dc-42d9-9a92-6dc9daa80ce9	مستندسازی و نهایی‌سازی	119	37	2026-07-04	approved	98fba7cd-606b-4e45-957c-f63d3a809e84	\N	3e2589f2-9d3e-4232-a7c4-c1846c81daad	2026-07-21 11:45:44.744086+00	2026-07-21 11:45:44.744086+00
582b48ec-cec0-4e4b-a7d4-cbfd51751f0f	a8fff62c-f697-4c1d-8aa9-0caf91f8a228	76c11995-60dc-42d9-9a92-6dc9daa80ce9	مستندسازی و نهایی‌سازی	167	50	2026-07-07	approved	98fba7cd-606b-4e45-957c-f63d3a809e84	\N	51d49dc5-4998-4f59-ac0d-2aaa1467e173	2026-07-21 11:45:44.744086+00	2026-07-21 11:45:44.744086+00
582b48ec-cec0-4e4b-a7d4-cbfd51751f0f	0872a447-e774-420d-8e50-64f99345c256	98fba7cd-606b-4e45-957c-f63d3a809e84	رفع اشکالات و بازبینی	176	28	2026-07-16	approved	98fba7cd-606b-4e45-957c-f63d3a809e84	\N	0b85af6f-c3d1-41c1-9227-e95610c2ab6e	2026-07-21 11:45:44.744086+00	2026-07-21 11:45:44.744086+00
582b48ec-cec0-4e4b-a7d4-cbfd51751f0f	0872a447-e774-420d-8e50-64f99345c256	98fba7cd-606b-4e45-957c-f63d3a809e84	پیاده‌سازی بخش اصلی	222	66	2026-07-16	approved	98fba7cd-606b-4e45-957c-f63d3a809e84	\N	f3bba680-f530-4bb7-9611-30488c02ca4d	2026-07-21 11:45:44.744086+00	2026-07-21 11:45:44.744086+00
582b48ec-cec0-4e4b-a7d4-cbfd51751f0f	0872a447-e774-420d-8e50-64f99345c256	98fba7cd-606b-4e45-957c-f63d3a809e84	رفع اشکالات و بازبینی	197	72	2026-07-16	approved	98fba7cd-606b-4e45-957c-f63d3a809e84	\N	64e97999-1a47-4903-8619-4455c78a2799	2026-07-21 11:45:44.744086+00	2026-07-21 11:45:44.744086+00
582b48ec-cec0-4e4b-a7d4-cbfd51751f0f	2bf0069a-2347-4a89-8b50-4ecaedac7fbe	2e6fa9ea-43da-47ab-a8a8-e2e58360f575	رفع اشکالات و بازبینی	93	32	2026-07-16	approved	98fba7cd-606b-4e45-957c-f63d3a809e84	\N	677a1ad1-9cd3-45a7-b0bc-b02f27c0e424	2026-07-21 11:45:44.744086+00	2026-07-21 11:45:44.744086+00
582b48ec-cec0-4e4b-a7d4-cbfd51751f0f	2bf0069a-2347-4a89-8b50-4ecaedac7fbe	2e6fa9ea-43da-47ab-a8a8-e2e58360f575	رفع اشکالات و بازبینی	190	66	2026-07-16	approved	98fba7cd-606b-4e45-957c-f63d3a809e84	\N	adbec512-400e-4dc6-88aa-a720bdd72c11	2026-07-21 11:45:44.744086+00	2026-07-21 11:45:44.744086+00
582b48ec-cec0-4e4b-a7d4-cbfd51751f0f	9d7cfc2d-5923-4c22-b8e1-5117d6a35292	e84eaed7-50c6-4212-9f29-cad60bbee457	پیشرفت اولیه و بررسی نیازمندی‌ها	133	36	2026-07-15	approved	98fba7cd-606b-4e45-957c-f63d3a809e84	\N	2c0f51b4-2b69-4784-8dd5-e4b359b8a1a7	2026-07-21 11:45:44.744086+00	2026-07-21 11:45:44.744086+00
582b48ec-cec0-4e4b-a7d4-cbfd51751f0f	9d7cfc2d-5923-4c22-b8e1-5117d6a35292	e84eaed7-50c6-4212-9f29-cad60bbee457	رفع اشکالات و بازبینی	146	70	2026-07-16	approved	98fba7cd-606b-4e45-957c-f63d3a809e84	\N	fe117a86-76da-4187-b70b-942d06cbee8e	2026-07-21 11:45:44.744086+00	2026-07-21 11:45:44.744086+00
582b48ec-cec0-4e4b-a7d4-cbfd51751f0f	9d7cfc2d-5923-4c22-b8e1-5117d6a35292	e84eaed7-50c6-4212-9f29-cad60bbee457	پیشرفت اولیه و بررسی نیازمندی‌ها	217	100	2026-07-16	approved	98fba7cd-606b-4e45-957c-f63d3a809e84	\N	94f929c2-cac4-416f-bf0f-c42614b9f488	2026-07-21 11:45:44.744086+00	2026-07-21 11:45:44.744086+00
582b48ec-cec0-4e4b-a7d4-cbfd51751f0f	9d7cfc2d-5923-4c22-b8e1-5117d6a35292	e84eaed7-50c6-4212-9f29-cad60bbee457	مستندسازی و نهایی‌سازی	131	100	2026-07-16	submitted	\N	\N	e79ea976-c54b-468b-b17d-962f7d5e2563	2026-07-21 11:45:44.744086+00	2026-07-21 11:45:44.744086+00
582b48ec-cec0-4e4b-a7d4-cbfd51751f0f	750058e4-de91-46da-9f83-e6b251f69c4d	c057add9-a37a-4d8b-adb3-be28effacb81	رفع اشکالات و بازبینی	102	30	2026-06-28	approved	98fba7cd-606b-4e45-957c-f63d3a809e84	\N	8325c5e4-3c24-4f76-8a05-cc244bb3199a	2026-07-21 11:45:44.744086+00	2026-07-21 11:45:44.744086+00
582b48ec-cec0-4e4b-a7d4-cbfd51751f0f	750058e4-de91-46da-9f83-e6b251f69c4d	c057add9-a37a-4d8b-adb3-be28effacb81	تست و اطمینان از عملکرد صحیح	231	60	2026-06-30	approved	98fba7cd-606b-4e45-957c-f63d3a809e84	\N	e26d1539-b4ad-4f80-b20c-7092d6b13cbf	2026-07-21 11:45:44.744086+00	2026-07-21 11:45:44.744086+00
582b48ec-cec0-4e4b-a7d4-cbfd51751f0f	750058e4-de91-46da-9f83-e6b251f69c4d	c057add9-a37a-4d8b-adb3-be28effacb81	تست و اطمینان از عملکرد صحیح	34	69	2026-06-30	approved	98fba7cd-606b-4e45-957c-f63d3a809e84	\N	2b0f27b0-2b77-49f3-99cd-675e98549714	2026-07-21 11:45:44.744086+00	2026-07-21 11:45:44.744086+00
582b48ec-cec0-4e4b-a7d4-cbfd51751f0f	750058e4-de91-46da-9f83-e6b251f69c4d	c057add9-a37a-4d8b-adb3-be28effacb81	پیشرفت اولیه و بررسی نیازمندی‌ها	139	100	2026-07-04	approved	98fba7cd-606b-4e45-957c-f63d3a809e84	\N	c3e23a02-b9c1-4f39-83b7-094d7d4e3a0b	2026-07-21 11:45:44.744086+00	2026-07-21 11:45:44.744086+00
582b48ec-cec0-4e4b-a7d4-cbfd51751f0f	45b140bf-d1b9-4b13-8b3b-b8b4a9a2cc85	c057add9-a37a-4d8b-adb3-be28effacb81	پیاده‌سازی بخش اصلی	100	22	2026-06-24	approved	98fba7cd-606b-4e45-957c-f63d3a809e84	\N	a0ea1127-4f74-455b-989e-5a64a6b2a807	2026-07-21 11:45:44.744086+00	2026-07-21 11:45:44.744086+00
582b48ec-cec0-4e4b-a7d4-cbfd51751f0f	45b140bf-d1b9-4b13-8b3b-b8b4a9a2cc85	c057add9-a37a-4d8b-adb3-be28effacb81	رفع اشکالات و بازبینی	51	62	2026-06-27	approved	98fba7cd-606b-4e45-957c-f63d3a809e84	\N	9a9eaa9e-6d45-48f9-9aa8-829d47efbc9e	2026-07-21 11:45:44.744086+00	2026-07-21 11:45:44.744086+00
582b48ec-cec0-4e4b-a7d4-cbfd51751f0f	9087219e-b7a1-456d-911d-eae1f854a840	c057add9-a37a-4d8b-adb3-be28effacb81	رفع اشکالات و بازبینی	215	27	2026-07-14	approved	98fba7cd-606b-4e45-957c-f63d3a809e84	\N	ef30988c-47fc-490d-a7a8-523cdfab4b92	2026-07-21 11:45:44.744086+00	2026-07-21 11:45:44.744086+00
582b48ec-cec0-4e4b-a7d4-cbfd51751f0f	9087219e-b7a1-456d-911d-eae1f854a840	c057add9-a37a-4d8b-adb3-be28effacb81	پیشرفت اولیه و بررسی نیازمندی‌ها	30	52	2026-07-16	approved	98fba7cd-606b-4e45-957c-f63d3a809e84	\N	c02b3109-ab93-4aab-bb78-f2b70d81633c	2026-07-21 11:45:44.744086+00	2026-07-21 11:45:44.744086+00
582b48ec-cec0-4e4b-a7d4-cbfd51751f0f	e68a5f05-78df-47e7-8061-223465c2ddd2	98fba7cd-606b-4e45-957c-f63d3a809e84	پیاده‌سازی بخش اصلی	162	34	2026-07-16	approved	98fba7cd-606b-4e45-957c-f63d3a809e84	\N	0160ab81-756b-4282-9639-82053ff99ca0	2026-07-21 11:45:44.744086+00	2026-07-21 11:45:44.744086+00
582b48ec-cec0-4e4b-a7d4-cbfd51751f0f	e68a5f05-78df-47e7-8061-223465c2ddd2	98fba7cd-606b-4e45-957c-f63d3a809e84	رفع اشکالات و بازبینی	239	46	2026-07-16	approved	98fba7cd-606b-4e45-957c-f63d3a809e84	\N	f50b1d6a-5211-434f-afe7-0c7562176df4	2026-07-21 11:45:44.744086+00	2026-07-21 11:45:44.744086+00
582b48ec-cec0-4e4b-a7d4-cbfd51751f0f	e68a5f05-78df-47e7-8061-223465c2ddd2	98fba7cd-606b-4e45-957c-f63d3a809e84	تست و اطمینان از عملکرد صحیح	48	81	2026-07-16	approved	98fba7cd-606b-4e45-957c-f63d3a809e84	\N	e0aea52f-5ae2-48bb-bb67-4f6a73ddec2e	2026-07-21 11:45:44.744086+00	2026-07-21 11:45:44.744086+00
582b48ec-cec0-4e4b-a7d4-cbfd51751f0f	e68a5f05-78df-47e7-8061-223465c2ddd2	98fba7cd-606b-4e45-957c-f63d3a809e84	پیشرفت اولیه و بررسی نیازمندی‌ها	56	100	2026-07-16	approved	98fba7cd-606b-4e45-957c-f63d3a809e84	\N	d343e87e-eb42-48b3-a39b-5a7d701ae1a1	2026-07-21 11:45:44.744086+00	2026-07-21 11:45:44.744086+00
582b48ec-cec0-4e4b-a7d4-cbfd51751f0f	3bc3769d-3053-4b2c-960e-8318e6df9b80	c057add9-a37a-4d8b-adb3-be28effacb81	پیاده‌سازی بخش اصلی	194	24	2026-06-26	approved	98fba7cd-606b-4e45-957c-f63d3a809e84	\N	b3d09b57-a5d7-43b7-836f-2a0aa5f05c02	2026-07-21 11:45:44.744086+00	2026-07-21 11:45:44.744086+00
582b48ec-cec0-4e4b-a7d4-cbfd51751f0f	3bc3769d-3053-4b2c-960e-8318e6df9b80	c057add9-a37a-4d8b-adb3-be28effacb81	پیشرفت اولیه و بررسی نیازمندی‌ها	186	80	2026-06-27	approved	98fba7cd-606b-4e45-957c-f63d3a809e84	\N	912a71ec-2b26-4570-8fb8-8d4866cd79d7	2026-07-21 11:45:44.744086+00	2026-07-21 11:45:44.744086+00
582b48ec-cec0-4e4b-a7d4-cbfd51751f0f	3bc3769d-3053-4b2c-960e-8318e6df9b80	c057add9-a37a-4d8b-adb3-be28effacb81	پیاده‌سازی بخش اصلی	190	72	2026-06-30	approved	98fba7cd-606b-4e45-957c-f63d3a809e84	\N	f5333c56-8a0d-4a8d-a108-d8132e8eff4f	2026-07-21 11:45:44.744086+00	2026-07-21 11:45:44.744086+00
582b48ec-cec0-4e4b-a7d4-cbfd51751f0f	a38912a4-973b-4bc4-b406-74661be2199b	2e6fa9ea-43da-47ab-a8a8-e2e58360f575	پیشرفت اولیه و بررسی نیازمندی‌ها	55	24	2026-07-09	submitted	\N	\N	b5c91fa7-b742-4bfc-bc31-46e60e005f67	2026-07-21 11:45:44.744086+00	2026-07-21 11:45:44.744086+00
582b48ec-cec0-4e4b-a7d4-cbfd51751f0f	a38912a4-973b-4bc4-b406-74661be2199b	2e6fa9ea-43da-47ab-a8a8-e2e58360f575	تست و اطمینان از عملکرد صحیح	119	66	2026-07-10	approved	98fba7cd-606b-4e45-957c-f63d3a809e84	\N	339c0c35-60ed-469d-b3f3-b183bbf52781	2026-07-21 11:45:44.744086+00	2026-07-21 11:45:44.744086+00
582b48ec-cec0-4e4b-a7d4-cbfd51751f0f	a38912a4-973b-4bc4-b406-74661be2199b	2e6fa9ea-43da-47ab-a8a8-e2e58360f575	پیاده‌سازی بخش اصلی	100	100	2026-07-15	submitted	\N	\N	8fe8a57f-f5ea-4245-98fc-2a41078de084	2026-07-21 11:45:44.744086+00	2026-07-21 11:45:44.744086+00
582b48ec-cec0-4e4b-a7d4-cbfd51751f0f	a38912a4-973b-4bc4-b406-74661be2199b	2e6fa9ea-43da-47ab-a8a8-e2e58360f575	مستندسازی و نهایی‌سازی	183	100	2026-07-12	approved	98fba7cd-606b-4e45-957c-f63d3a809e84	\N	9e7fe8e7-93a8-4914-9cc1-f5c2d10407f0	2026-07-21 11:45:44.744086+00	2026-07-21 11:45:44.744086+00
582b48ec-cec0-4e4b-a7d4-cbfd51751f0f	5e72d9a5-b141-4369-97e1-d7150ddab76c	c057add9-a37a-4d8b-adb3-be28effacb81	رفع اشکالات و بازبینی	82	36	2026-07-16	approved	98fba7cd-606b-4e45-957c-f63d3a809e84	\N	3a76bd8b-c1a9-42ef-9ebb-1b9d9a5c61db	2026-07-21 11:45:44.744086+00	2026-07-21 11:45:44.744086+00
582b48ec-cec0-4e4b-a7d4-cbfd51751f0f	5e72d9a5-b141-4369-97e1-d7150ddab76c	c057add9-a37a-4d8b-adb3-be28effacb81	تست و اطمینان از عملکرد صحیح	105	80	2026-07-16	approved	98fba7cd-606b-4e45-957c-f63d3a809e84	\N	1d4cad80-4652-4d40-bc15-bd500574f189	2026-07-21 11:45:44.744086+00	2026-07-21 11:45:44.744086+00
582b48ec-cec0-4e4b-a7d4-cbfd51751f0f	5e72d9a5-b141-4369-97e1-d7150ddab76c	c057add9-a37a-4d8b-adb3-be28effacb81	پیاده‌سازی بخش اصلی	156	96	2026-07-16	approved	98fba7cd-606b-4e45-957c-f63d3a809e84	\N	4a2473e1-38bc-4d37-a493-37a0908e8181	2026-07-21 11:45:44.744086+00	2026-07-21 11:45:44.744086+00
582b48ec-cec0-4e4b-a7d4-cbfd51751f0f	26ad54bf-3f82-42fe-8142-c824dc9c27c8	85751a1a-b02d-4121-aff6-407cd2f6ebd7	تست و اطمینان از عملکرد صحیح	193	39	2026-07-16	approved	98fba7cd-606b-4e45-957c-f63d3a809e84	\N	51d076cd-a938-43e2-95a7-8128cd2b191b	2026-07-21 11:45:44.744086+00	2026-07-21 11:45:44.744086+00
582b48ec-cec0-4e4b-a7d4-cbfd51751f0f	e0e5ff26-6932-43c9-9fb6-e722fdfa6756	c057add9-a37a-4d8b-adb3-be28effacb81	رفع اشکالات و بازبینی	111	24	2026-07-16	approved	98fba7cd-606b-4e45-957c-f63d3a809e84	\N	7e3054fb-997a-41d1-9fcd-d8009f769c97	2026-07-21 11:45:44.744086+00	2026-07-21 11:45:44.744086+00
582b48ec-cec0-4e4b-a7d4-cbfd51751f0f	de620bc6-eada-43bf-8d61-d69aadfd050b	c057add9-a37a-4d8b-adb3-be28effacb81	پیاده‌سازی بخش اصلی	225	35	2026-07-16	approved	98fba7cd-606b-4e45-957c-f63d3a809e84	\N	8bfd4e26-555a-4363-936f-d04a9a638e3e	2026-07-21 11:45:44.744086+00	2026-07-21 11:45:44.744086+00
582b48ec-cec0-4e4b-a7d4-cbfd51751f0f	de620bc6-eada-43bf-8d61-d69aadfd050b	c057add9-a37a-4d8b-adb3-be28effacb81	پیشرفت اولیه و بررسی نیازمندی‌ها	33	56	2026-07-16	approved	98fba7cd-606b-4e45-957c-f63d3a809e84	\N	d27e1524-09c1-4522-a1ec-80b620f83968	2026-07-21 11:45:44.744086+00	2026-07-21 11:45:44.744086+00
582b48ec-cec0-4e4b-a7d4-cbfd51751f0f	de620bc6-eada-43bf-8d61-d69aadfd050b	c057add9-a37a-4d8b-adb3-be28effacb81	پیشرفت اولیه و بررسی نیازمندی‌ها	232	96	2026-07-16	approved	98fba7cd-606b-4e45-957c-f63d3a809e84	\N	37dbcee5-2e5c-4a28-a472-add57a6969e2	2026-07-21 11:45:44.744086+00	2026-07-21 11:45:44.744086+00
582b48ec-cec0-4e4b-a7d4-cbfd51751f0f	de620bc6-eada-43bf-8d61-d69aadfd050b	c057add9-a37a-4d8b-adb3-be28effacb81	مستندسازی و نهایی‌سازی	226	100	2026-07-16	approved	98fba7cd-606b-4e45-957c-f63d3a809e84	\N	cb752037-d1d5-4c09-9f0d-97aa29731ea6	2026-07-21 11:45:44.744086+00	2026-07-21 11:45:44.744086+00
582b48ec-cec0-4e4b-a7d4-cbfd51751f0f	d2ad5688-9570-42b1-8422-306e1f4b0e5d	c057add9-a37a-4d8b-adb3-be28effacb81	مستندسازی و نهایی‌سازی	167	39	2026-07-16	approved	98fba7cd-606b-4e45-957c-f63d3a809e84	\N	ef24fb2b-edb9-4428-b736-5f8cbd6aac45	2026-07-21 11:45:44.744086+00	2026-07-21 11:45:44.744086+00
582b48ec-cec0-4e4b-a7d4-cbfd51751f0f	d2ad5688-9570-42b1-8422-306e1f4b0e5d	c057add9-a37a-4d8b-adb3-be28effacb81	رفع اشکالات و بازبینی	50	72	2026-07-16	approved	98fba7cd-606b-4e45-957c-f63d3a809e84	\N	19363f40-d556-412e-ba98-130cb5432b06	2026-07-21 11:45:44.744086+00	2026-07-21 11:45:44.744086+00
582b48ec-cec0-4e4b-a7d4-cbfd51751f0f	d2ad5688-9570-42b1-8422-306e1f4b0e5d	c057add9-a37a-4d8b-adb3-be28effacb81	پیاده‌سازی بخش اصلی	167	90	2026-07-16	submitted	\N	\N	69c962bb-fc5c-4054-830e-c373b445d0b6	2026-07-21 11:45:44.744086+00	2026-07-21 11:45:44.744086+00
582b48ec-cec0-4e4b-a7d4-cbfd51751f0f	d2ad5688-9570-42b1-8422-306e1f4b0e5d	c057add9-a37a-4d8b-adb3-be28effacb81	پیشرفت اولیه و بررسی نیازمندی‌ها	109	100	2026-07-16	approved	98fba7cd-606b-4e45-957c-f63d3a809e84	\N	663f276c-655a-412e-9d34-3beb508799f1	2026-07-21 11:45:44.744086+00	2026-07-21 11:45:44.744086+00
582b48ec-cec0-4e4b-a7d4-cbfd51751f0f	1dd61182-531a-4d89-9aed-2af2fb41f43c	c057add9-a37a-4d8b-adb3-be28effacb81	پیاده‌سازی بخش اصلی	52	33	2026-07-16	approved	98fba7cd-606b-4e45-957c-f63d3a809e84	\N	d1a217ef-7813-41af-bc1d-4247397b7f8d	2026-07-21 11:45:44.744086+00	2026-07-21 11:45:44.744086+00
582b48ec-cec0-4e4b-a7d4-cbfd51751f0f	1dd61182-531a-4d89-9aed-2af2fb41f43c	c057add9-a37a-4d8b-adb3-be28effacb81	تست و اطمینان از عملکرد صحیح	186	78	2026-07-16	approved	98fba7cd-606b-4e45-957c-f63d3a809e84	\N	be3ca8b3-9fbc-44ae-950d-bc1bd2dd8483	2026-07-21 11:45:44.744086+00	2026-07-21 11:45:44.744086+00
582b48ec-cec0-4e4b-a7d4-cbfd51751f0f	5ccc52e8-e663-4180-81fb-59cf62143084	2e6fa9ea-43da-47ab-a8a8-e2e58360f575	پیاده‌سازی بخش اصلی	60	20	2026-07-16	approved	98fba7cd-606b-4e45-957c-f63d3a809e84	\N	c7721f08-513a-4632-a6a4-3ebfff5c461a	2026-07-21 11:45:44.744086+00	2026-07-21 11:45:44.744086+00
582b48ec-cec0-4e4b-a7d4-cbfd51751f0f	5995ceb0-d72e-4f47-b886-5f376a015fd2	c057add9-a37a-4d8b-adb3-be28effacb81	پیاده‌سازی بخش اصلی	157	31	2026-06-30	approved	98fba7cd-606b-4e45-957c-f63d3a809e84	\N	ae10ffee-86c8-4198-8a9e-86f335150ef8	2026-07-21 11:45:44.744086+00	2026-07-21 11:45:44.744086+00
582b48ec-cec0-4e4b-a7d4-cbfd51751f0f	5995ceb0-d72e-4f47-b886-5f376a015fd2	c057add9-a37a-4d8b-adb3-be28effacb81	پیاده‌سازی بخش اصلی	125	48	2026-07-03	approved	98fba7cd-606b-4e45-957c-f63d3a809e84	\N	7d50369c-3184-461a-a993-a5d6878afe3b	2026-07-21 11:45:44.744086+00	2026-07-21 11:45:44.744086+00
582b48ec-cec0-4e4b-a7d4-cbfd51751f0f	6daff139-b2d3-4e68-9c50-18576a236b5f	c057add9-a37a-4d8b-adb3-be28effacb81	پیشرفت اولیه و بررسی نیازمندی‌ها	115	33	2026-07-13	approved	98fba7cd-606b-4e45-957c-f63d3a809e84	\N	69e5da3e-e290-436e-907a-bd631771ffe9	2026-07-21 11:45:44.744086+00	2026-07-21 11:45:44.744086+00
582b48ec-cec0-4e4b-a7d4-cbfd51751f0f	6daff139-b2d3-4e68-9c50-18576a236b5f	c057add9-a37a-4d8b-adb3-be28effacb81	مستندسازی و نهایی‌سازی	46	56	2026-07-16	approved	98fba7cd-606b-4e45-957c-f63d3a809e84	\N	f40058cc-67ea-43ca-b5cc-49669d7bcf19	2026-07-21 11:45:44.744086+00	2026-07-21 11:45:44.744086+00
582b48ec-cec0-4e4b-a7d4-cbfd51751f0f	6daff139-b2d3-4e68-9c50-18576a236b5f	c057add9-a37a-4d8b-adb3-be28effacb81	تست و اطمینان از عملکرد صحیح	146	100	2026-07-15	approved	98fba7cd-606b-4e45-957c-f63d3a809e84	\N	f9cac131-2390-440a-ab0b-b2c22fe51d98	2026-07-21 11:45:44.744086+00	2026-07-21 11:45:44.744086+00
582b48ec-cec0-4e4b-a7d4-cbfd51751f0f	23c71d9e-d7f1-46ec-ae08-512ce342a31f	2e6fa9ea-43da-47ab-a8a8-e2e58360f575	مستندسازی و نهایی‌سازی	72	31	2026-07-16	approved	98fba7cd-606b-4e45-957c-f63d3a809e84	\N	497960e4-f603-45a0-a58b-d5a9d19093de	2026-07-21 11:45:44.744086+00	2026-07-21 11:45:44.744086+00
582b48ec-cec0-4e4b-a7d4-cbfd51751f0f	23c71d9e-d7f1-46ec-ae08-512ce342a31f	2e6fa9ea-43da-47ab-a8a8-e2e58360f575	پیشرفت اولیه و بررسی نیازمندی‌ها	176	46	2026-07-16	approved	98fba7cd-606b-4e45-957c-f63d3a809e84	\N	6cc1ac93-1472-45cb-8751-fb73c2102b72	2026-07-21 11:45:44.744086+00	2026-07-21 11:45:44.744086+00
582b48ec-cec0-4e4b-a7d4-cbfd51751f0f	23c71d9e-d7f1-46ec-ae08-512ce342a31f	2e6fa9ea-43da-47ab-a8a8-e2e58360f575	پیشرفت اولیه و بررسی نیازمندی‌ها	41	60	2026-07-16	submitted	\N	\N	4d390e11-fa73-4046-b386-2561317fd46d	2026-07-21 11:45:44.744086+00	2026-07-21 11:45:44.744086+00
582b48ec-cec0-4e4b-a7d4-cbfd51751f0f	9c85fcdd-b06e-431d-bfb1-8505ad54e365	98fba7cd-606b-4e45-957c-f63d3a809e84	تست و اطمینان از عملکرد صحیح	123	32	2026-07-16	approved	98fba7cd-606b-4e45-957c-f63d3a809e84	\N	1eca187c-bb2d-45e9-899b-d114eeb61567	2026-07-21 11:45:44.744086+00	2026-07-21 11:45:44.744086+00
582b48ec-cec0-4e4b-a7d4-cbfd51751f0f	9c85fcdd-b06e-431d-bfb1-8505ad54e365	98fba7cd-606b-4e45-957c-f63d3a809e84	پیاده‌سازی بخش اصلی	39	74	2026-07-16	approved	98fba7cd-606b-4e45-957c-f63d3a809e84	\N	a96e6485-7f3e-415f-bfde-c19720cdf330	2026-07-21 11:45:44.744086+00	2026-07-21 11:45:44.744086+00
582b48ec-cec0-4e4b-a7d4-cbfd51751f0f	498e9498-be0c-4a92-b6a8-5a8e17ced6d3	c057add9-a37a-4d8b-adb3-be28effacb81	تست و اطمینان از عملکرد صحیح	214	30	2026-07-16	approved	98fba7cd-606b-4e45-957c-f63d3a809e84	\N	31fd98a0-420d-4de3-9fa1-8b8be15e3648	2026-07-21 11:45:44.744086+00	2026-07-21 11:45:44.744086+00
582b48ec-cec0-4e4b-a7d4-cbfd51751f0f	498e9498-be0c-4a92-b6a8-5a8e17ced6d3	c057add9-a37a-4d8b-adb3-be28effacb81	مستندسازی و نهایی‌سازی	125	46	2026-07-16	submitted	\N	\N	1ed57b00-440a-4a48-9e84-4ebf8df80921	2026-07-21 11:45:44.744086+00	2026-07-21 11:45:44.744086+00
582b48ec-cec0-4e4b-a7d4-cbfd51751f0f	498e9498-be0c-4a92-b6a8-5a8e17ced6d3	c057add9-a37a-4d8b-adb3-be28effacb81	مستندسازی و نهایی‌سازی	41	96	2026-07-16	approved	98fba7cd-606b-4e45-957c-f63d3a809e84	\N	b8c35261-aebc-4d2d-b68b-2b8cd2812f68	2026-07-21 11:45:44.744086+00	2026-07-21 11:45:44.744086+00
582b48ec-cec0-4e4b-a7d4-cbfd51751f0f	498e9498-be0c-4a92-b6a8-5a8e17ced6d3	c057add9-a37a-4d8b-adb3-be28effacb81	رفع اشکالات و بازبینی	228	100	2026-07-16	submitted	\N	\N	c16776b5-8b6e-4e17-b9d3-dda6c1cd6ba4	2026-07-21 11:45:44.744086+00	2026-07-21 11:45:44.744086+00
582b48ec-cec0-4e4b-a7d4-cbfd51751f0f	54ca2f59-bc89-4d1f-ba8d-2eedb61809c8	e84eaed7-50c6-4212-9f29-cad60bbee457	پیشرفت اولیه و بررسی نیازمندی‌ها	124	26	2026-07-16	approved	98fba7cd-606b-4e45-957c-f63d3a809e84	\N	7ff3b52f-7eba-4f85-9059-d7efa17be0a2	2026-07-21 11:45:44.744086+00	2026-07-21 11:45:44.744086+00
582b48ec-cec0-4e4b-a7d4-cbfd51751f0f	54ca2f59-bc89-4d1f-ba8d-2eedb61809c8	e84eaed7-50c6-4212-9f29-cad60bbee457	رفع اشکالات و بازبینی	219	78	2026-07-16	approved	98fba7cd-606b-4e45-957c-f63d3a809e84	\N	1ce50ee0-b3b3-4a60-90c3-147da9b9788b	2026-07-21 11:45:44.744086+00	2026-07-21 11:45:44.744086+00
582b48ec-cec0-4e4b-a7d4-cbfd51751f0f	54ca2f59-bc89-4d1f-ba8d-2eedb61809c8	e84eaed7-50c6-4212-9f29-cad60bbee457	مستندسازی و نهایی‌سازی	156	78	2026-07-16	approved	98fba7cd-606b-4e45-957c-f63d3a809e84	\N	d381db09-b0cb-4c81-bbd0-73818e9836c2	2026-07-21 11:45:44.744086+00	2026-07-21 11:45:44.744086+00
582b48ec-cec0-4e4b-a7d4-cbfd51751f0f	c0ca9aac-ace7-47b4-bc46-08ba42a9d679	85751a1a-b02d-4121-aff6-407cd2f6ebd7	تست و اطمینان از عملکرد صحیح	36	27	2026-07-01	approved	98fba7cd-606b-4e45-957c-f63d3a809e84	\N	7b6c3bd7-0451-4bd1-888d-ec48d9729aa4	2026-07-21 11:45:44.744086+00	2026-07-21 11:45:44.744086+00
582b48ec-cec0-4e4b-a7d4-cbfd51751f0f	c0ca9aac-ace7-47b4-bc46-08ba42a9d679	85751a1a-b02d-4121-aff6-407cd2f6ebd7	پیشرفت اولیه و بررسی نیازمندی‌ها	115	40	2026-07-04	approved	98fba7cd-606b-4e45-957c-f63d3a809e84	\N	491231de-2a51-444b-90ed-c60531a14df2	2026-07-21 11:45:44.744086+00	2026-07-21 11:45:44.744086+00
582b48ec-cec0-4e4b-a7d4-cbfd51751f0f	05a1b549-5510-4f9d-8ac6-ecf23d52d84c	e84eaed7-50c6-4212-9f29-cad60bbee457	مستندسازی و نهایی‌سازی	90	33	2026-06-19	approved	98fba7cd-606b-4e45-957c-f63d3a809e84	\N	b244287d-be10-4eb0-8968-a46833d56d33	2026-07-21 11:45:44.744086+00	2026-07-21 11:45:44.744086+00
582b48ec-cec0-4e4b-a7d4-cbfd51751f0f	05a1b549-5510-4f9d-8ac6-ecf23d52d84c	e84eaed7-50c6-4212-9f29-cad60bbee457	پیاده‌سازی بخش اصلی	212	56	2026-06-23	submitted	\N	\N	a19d3789-fbb9-459d-9b99-e593943e385d	2026-07-21 11:45:44.744086+00	2026-07-21 11:45:44.744086+00
582b48ec-cec0-4e4b-a7d4-cbfd51751f0f	05a1b549-5510-4f9d-8ac6-ecf23d52d84c	e84eaed7-50c6-4212-9f29-cad60bbee457	پیاده‌سازی بخش اصلی	163	99	2026-06-21	approved	98fba7cd-606b-4e45-957c-f63d3a809e84	\N	47b0ca7c-ec18-4f9c-9a39-5ff7964cbad6	2026-07-21 11:45:44.744086+00	2026-07-21 11:45:44.744086+00
582b48ec-cec0-4e4b-a7d4-cbfd51751f0f	05a1b549-5510-4f9d-8ac6-ecf23d52d84c	e84eaed7-50c6-4212-9f29-cad60bbee457	پیشرفت اولیه و بررسی نیازمندی‌ها	178	92	2026-06-28	approved	98fba7cd-606b-4e45-957c-f63d3a809e84	\N	11c2b354-b9ba-4fd8-8b82-4818aef602f2	2026-07-21 11:45:44.744086+00	2026-07-21 11:45:44.744086+00
582b48ec-cec0-4e4b-a7d4-cbfd51751f0f	81e5d14d-9922-4af2-bbca-ea1cc5cf28ef	c057add9-a37a-4d8b-adb3-be28effacb81	پیشرفت اولیه و بررسی نیازمندی‌ها	181	38	2026-07-08	approved	98fba7cd-606b-4e45-957c-f63d3a809e84	\N	e48b1af7-5e5d-46a1-884d-8d8e6921c9ab	2026-07-21 11:45:44.744086+00	2026-07-21 11:45:44.744086+00
582b48ec-cec0-4e4b-a7d4-cbfd51751f0f	81e5d14d-9922-4af2-bbca-ea1cc5cf28ef	c057add9-a37a-4d8b-adb3-be28effacb81	تست و اطمینان از عملکرد صحیح	199	48	2026-07-09	approved	98fba7cd-606b-4e45-957c-f63d3a809e84	\N	7ff9104d-fd18-49a8-b4f7-382041fbe216	2026-07-21 11:45:44.744086+00	2026-07-21 11:45:44.744086+00
582b48ec-cec0-4e4b-a7d4-cbfd51751f0f	c12b6653-fa30-4159-b704-bb3bc00b030c	c057add9-a37a-4d8b-adb3-be28effacb81	رفع اشکالات و بازبینی	235	32	2026-06-25	approved	98fba7cd-606b-4e45-957c-f63d3a809e84	\N	9b766156-781a-4031-8710-fb18107ad181	2026-07-21 11:45:44.744086+00	2026-07-21 11:45:44.744086+00
582b48ec-cec0-4e4b-a7d4-cbfd51751f0f	c12b6653-fa30-4159-b704-bb3bc00b030c	c057add9-a37a-4d8b-adb3-be28effacb81	رفع اشکالات و بازبینی	89	44	2026-06-28	approved	98fba7cd-606b-4e45-957c-f63d3a809e84	\N	ff84055e-a960-469b-a356-761658d23fcc	2026-07-21 11:45:44.744086+00	2026-07-21 11:45:44.744086+00
582b48ec-cec0-4e4b-a7d4-cbfd51751f0f	6795ba06-0a28-4f37-979d-7e47ae68e273	85751a1a-b02d-4121-aff6-407cd2f6ebd7	مستندسازی و نهایی‌سازی	57	24	2026-07-05	submitted	\N	\N	405b5f93-46a7-465a-8481-cd96673f0516	2026-07-21 11:45:44.744086+00	2026-07-21 11:45:44.744086+00
582b48ec-cec0-4e4b-a7d4-cbfd51751f0f	6795ba06-0a28-4f37-979d-7e47ae68e273	85751a1a-b02d-4121-aff6-407cd2f6ebd7	تست و اطمینان از عملکرد صحیح	110	66	2026-07-06	approved	98fba7cd-606b-4e45-957c-f63d3a809e84	\N	2f11078e-3549-43f5-be09-9dc05adbcd64	2026-07-21 11:45:44.744086+00	2026-07-21 11:45:44.744086+00
582b48ec-cec0-4e4b-a7d4-cbfd51751f0f	569aab13-a5a0-4904-9fb9-629aa81d5db6	c057add9-a37a-4d8b-adb3-be28effacb81	پیاده‌سازی بخش اصلی	145	29	2026-07-10	approved	98fba7cd-606b-4e45-957c-f63d3a809e84	\N	504b72d1-3c5b-4802-be20-8e972dd7eaba	2026-07-21 11:45:44.744086+00	2026-07-21 11:45:44.744086+00
582b48ec-cec0-4e4b-a7d4-cbfd51751f0f	2c40fd55-8911-4174-b006-1f6b4c8e5f65	98fba7cd-606b-4e45-957c-f63d3a809e84	پیشرفت اولیه و بررسی نیازمندی‌ها	53	25	2026-06-21	approved	98fba7cd-606b-4e45-957c-f63d3a809e84	\N	cd02fe00-51d3-4ab7-b60b-06813c7266c2	2026-07-21 11:45:44.744086+00	2026-07-21 11:45:44.744086+00
582b48ec-cec0-4e4b-a7d4-cbfd51751f0f	2c40fd55-8911-4174-b006-1f6b4c8e5f65	98fba7cd-606b-4e45-957c-f63d3a809e84	مستندسازی و نهایی‌سازی	40	52	2026-06-24	approved	98fba7cd-606b-4e45-957c-f63d3a809e84	\N	2e044b00-942d-4b23-bb70-b161336e6ee0	2026-07-21 11:45:44.744086+00	2026-07-21 11:45:44.744086+00
582b48ec-cec0-4e4b-a7d4-cbfd51751f0f	2c40fd55-8911-4174-b006-1f6b4c8e5f65	98fba7cd-606b-4e45-957c-f63d3a809e84	پیاده‌سازی بخش اصلی	53	81	2026-06-27	approved	98fba7cd-606b-4e45-957c-f63d3a809e84	\N	799a461b-cb05-44ca-a97c-e9f35465e4c5	2026-07-21 11:45:44.744086+00	2026-07-21 11:45:44.744086+00
582b48ec-cec0-4e4b-a7d4-cbfd51751f0f	2c40fd55-8911-4174-b006-1f6b4c8e5f65	98fba7cd-606b-4e45-957c-f63d3a809e84	تست و اطمینان از عملکرد صحیح	161	84	2026-06-30	approved	98fba7cd-606b-4e45-957c-f63d3a809e84	\N	07fa2bab-9220-4a5b-9250-064a8e96193f	2026-07-21 11:45:44.744086+00	2026-07-21 11:45:44.744086+00
582b48ec-cec0-4e4b-a7d4-cbfd51751f0f	b89e6196-a201-4b26-8206-cf77b5be7b89	c057add9-a37a-4d8b-adb3-be28effacb81	پیاده‌سازی بخش اصلی	37	32	2026-06-18	approved	98fba7cd-606b-4e45-957c-f63d3a809e84	\N	438396ab-9dda-4cb7-977f-c3d19a57c7c5	2026-07-21 11:45:44.744086+00	2026-07-21 11:45:44.744086+00
582b48ec-cec0-4e4b-a7d4-cbfd51751f0f	b89e6196-a201-4b26-8206-cf77b5be7b89	c057add9-a37a-4d8b-adb3-be28effacb81	مستندسازی و نهایی‌سازی	221	74	2026-06-22	approved	98fba7cd-606b-4e45-957c-f63d3a809e84	\N	153203b6-e5a2-4365-9a9c-e6e14bc7837c	2026-07-21 11:45:44.744086+00	2026-07-21 11:45:44.744086+00
582b48ec-cec0-4e4b-a7d4-cbfd51751f0f	b89e6196-a201-4b26-8206-cf77b5be7b89	c057add9-a37a-4d8b-adb3-be28effacb81	پیشرفت اولیه و بررسی نیازمندی‌ها	148	69	2026-06-22	approved	98fba7cd-606b-4e45-957c-f63d3a809e84	\N	f9c9f050-985d-4770-985a-b128b9aead00	2026-07-21 11:45:44.744086+00	2026-07-21 11:45:44.744086+00
582b48ec-cec0-4e4b-a7d4-cbfd51751f0f	5fc25f8f-26b0-4b08-96c7-94d64b9c6445	60845684-b03a-492a-9937-f8529e7ba409	پیاده‌سازی بخش اصلی	63	26	2026-07-16	approved	98fba7cd-606b-4e45-957c-f63d3a809e84	\N	1f1917c5-8da4-42e8-8508-2503f6f9184c	2026-07-21 11:45:44.744086+00	2026-07-21 11:45:44.744086+00
582b48ec-cec0-4e4b-a7d4-cbfd51751f0f	5fc25f8f-26b0-4b08-96c7-94d64b9c6445	60845684-b03a-492a-9937-f8529e7ba409	پیشرفت اولیه و بررسی نیازمندی‌ها	179	76	2026-07-16	approved	98fba7cd-606b-4e45-957c-f63d3a809e84	\N	6282381e-c2d9-4dda-83df-18606f17a8c6	2026-07-21 11:45:44.744086+00	2026-07-21 11:45:44.744086+00
582b48ec-cec0-4e4b-a7d4-cbfd51751f0f	992226fe-7278-48cf-8c72-06ef25027114	98fba7cd-606b-4e45-957c-f63d3a809e84	پیشرفت اولیه و بررسی نیازمندی‌ها	80	40	2026-07-16	approved	98fba7cd-606b-4e45-957c-f63d3a809e84	\N	e22cbf82-992e-407c-a25b-6864a8fbfbfe	2026-07-21 11:45:44.744086+00	2026-07-21 11:45:44.744086+00
582b48ec-cec0-4e4b-a7d4-cbfd51751f0f	992226fe-7278-48cf-8c72-06ef25027114	98fba7cd-606b-4e45-957c-f63d3a809e84	پیشرفت اولیه و بررسی نیازمندی‌ها	237	60	2026-07-16	submitted	\N	\N	73424710-4aed-4377-813a-64ecc0e5a14d	2026-07-21 11:45:44.744086+00	2026-07-21 11:45:44.744086+00
582b48ec-cec0-4e4b-a7d4-cbfd51751f0f	992226fe-7278-48cf-8c72-06ef25027114	98fba7cd-606b-4e45-957c-f63d3a809e84	تست و اطمینان از عملکرد صحیح	42	75	2026-07-16	approved	98fba7cd-606b-4e45-957c-f63d3a809e84	\N	46c5a68d-3392-43a5-b500-70de49b80f9d	2026-07-21 11:45:44.744086+00	2026-07-21 11:45:44.744086+00
582b48ec-cec0-4e4b-a7d4-cbfd51751f0f	5e196c09-dc3b-4c57-bee7-cae2ba35a692	2e6fa9ea-43da-47ab-a8a8-e2e58360f575	تست و اطمینان از عملکرد صحیح	37	32	2026-07-11	approved	98fba7cd-606b-4e45-957c-f63d3a809e84	\N	e0686858-80a7-4bee-9d3b-5e514f58ff3b	2026-07-21 11:45:44.744086+00	2026-07-21 11:45:44.744086+00
582b48ec-cec0-4e4b-a7d4-cbfd51751f0f	5e196c09-dc3b-4c57-bee7-cae2ba35a692	2e6fa9ea-43da-47ab-a8a8-e2e58360f575	پیاده‌سازی بخش اصلی	120	52	2026-07-15	approved	98fba7cd-606b-4e45-957c-f63d3a809e84	\N	8bebc94c-1133-436f-a67d-aeb8c84913fb	2026-07-21 11:45:44.744086+00	2026-07-21 11:45:44.744086+00
582b48ec-cec0-4e4b-a7d4-cbfd51751f0f	5e196c09-dc3b-4c57-bee7-cae2ba35a692	2e6fa9ea-43da-47ab-a8a8-e2e58360f575	رفع اشکالات و بازبینی	101	100	2026-07-15	approved	98fba7cd-606b-4e45-957c-f63d3a809e84	\N	5766f46a-6c0e-4346-947f-eb0b447a673c	2026-07-21 11:45:44.744086+00	2026-07-21 11:45:44.744086+00
582b48ec-cec0-4e4b-a7d4-cbfd51751f0f	5e196c09-dc3b-4c57-bee7-cae2ba35a692	2e6fa9ea-43da-47ab-a8a8-e2e58360f575	پیشرفت اولیه و بررسی نیازمندی‌ها	187	100	2026-07-16	approved	98fba7cd-606b-4e45-957c-f63d3a809e84	\N	9f81c1ea-b378-4032-bfde-e3d2f77ef36f	2026-07-21 11:45:44.744086+00	2026-07-21 11:45:44.744086+00
582b48ec-cec0-4e4b-a7d4-cbfd51751f0f	54024904-5cae-4196-81f4-90b26b1ebd5d	2b35422d-f7be-4135-8473-be7d9e83ec3d	رفع اشکالات و بازبینی	43	27	2026-07-16	submitted	\N	\N	a7759185-5222-4bfe-82ba-1089bc440215	2026-07-21 11:45:44.744086+00	2026-07-21 11:45:44.744086+00
582b48ec-cec0-4e4b-a7d4-cbfd51751f0f	54024904-5cae-4196-81f4-90b26b1ebd5d	2b35422d-f7be-4135-8473-be7d9e83ec3d	مستندسازی و نهایی‌سازی	183	70	2026-07-16	approved	2b35422d-f7be-4135-8473-be7d9e83ec3d	\N	2b6ad8ed-23ac-4970-a95c-def5db708b63	2026-07-21 11:45:44.744086+00	2026-07-21 11:45:44.744086+00
582b48ec-cec0-4e4b-a7d4-cbfd51751f0f	16b86c04-80f9-4785-a928-3cf0b2e2823f	b4e312c2-6dc5-4616-97c7-1b9251f4ef87	پیشرفت اولیه و بررسی نیازمندی‌ها	54	27	2026-07-16	approved	2b35422d-f7be-4135-8473-be7d9e83ec3d	\N	193da583-5bae-4e9f-b31d-4d7454ac8eb8	2026-07-21 11:45:44.744086+00	2026-07-21 11:45:44.744086+00
582b48ec-cec0-4e4b-a7d4-cbfd51751f0f	16b86c04-80f9-4785-a928-3cf0b2e2823f	b4e312c2-6dc5-4616-97c7-1b9251f4ef87	رفع اشکالات و بازبینی	120	80	2026-07-16	approved	2b35422d-f7be-4135-8473-be7d9e83ec3d	\N	8a82ed7f-6296-446c-8d61-e8dca4c30ba2	2026-07-21 11:45:44.744086+00	2026-07-21 11:45:44.744086+00
582b48ec-cec0-4e4b-a7d4-cbfd51751f0f	16b86c04-80f9-4785-a928-3cf0b2e2823f	b4e312c2-6dc5-4616-97c7-1b9251f4ef87	مستندسازی و نهایی‌سازی	163	93	2026-07-16	approved	2b35422d-f7be-4135-8473-be7d9e83ec3d	\N	47541c4c-c717-4b7d-8a91-ab9462a7dc2e	2026-07-21 11:45:44.744086+00	2026-07-21 11:45:44.744086+00
582b48ec-cec0-4e4b-a7d4-cbfd51751f0f	37932347-2584-4b44-b306-f539739f112f	984c1d49-02d8-4d53-8ce0-f8709fafb190	پیاده‌سازی بخش اصلی	156	24	2026-07-16	approved	2b35422d-f7be-4135-8473-be7d9e83ec3d	\N	3484bd73-22e8-42ed-b290-ad570abf8ab6	2026-07-21 11:45:44.744086+00	2026-07-21 11:45:44.744086+00
582b48ec-cec0-4e4b-a7d4-cbfd51751f0f	51fc32bd-7406-4349-a821-92092f34097a	e139f154-0fb4-4ebf-b8b8-b6f5a29afeaf	رفع اشکالات و بازبینی	186	26	2026-07-07	approved	2b35422d-f7be-4135-8473-be7d9e83ec3d	\N	075400cd-c0ef-41b5-ae33-214f7bf2f976	2026-07-21 11:45:44.744086+00	2026-07-21 11:45:44.744086+00
582b48ec-cec0-4e4b-a7d4-cbfd51751f0f	51fc32bd-7406-4349-a821-92092f34097a	e139f154-0fb4-4ebf-b8b8-b6f5a29afeaf	پیشرفت اولیه و بررسی نیازمندی‌ها	130	52	2026-07-09	approved	2b35422d-f7be-4135-8473-be7d9e83ec3d	\N	5148c61e-9fb3-4715-a445-87630965138d	2026-07-21 11:45:44.744086+00	2026-07-21 11:45:44.744086+00
582b48ec-cec0-4e4b-a7d4-cbfd51751f0f	51fc32bd-7406-4349-a821-92092f34097a	e139f154-0fb4-4ebf-b8b8-b6f5a29afeaf	پیاده‌سازی بخش اصلی	213	90	2026-07-15	approved	2b35422d-f7be-4135-8473-be7d9e83ec3d	\N	756617b1-6841-4adb-ad14-2e9872060b63	2026-07-21 11:45:44.744086+00	2026-07-21 11:45:44.744086+00
582b48ec-cec0-4e4b-a7d4-cbfd51751f0f	51fc32bd-7406-4349-a821-92092f34097a	e139f154-0fb4-4ebf-b8b8-b6f5a29afeaf	تست و اطمینان از عملکرد صحیح	41	100	2026-07-10	approved	2b35422d-f7be-4135-8473-be7d9e83ec3d	\N	b7fc6a9c-ce21-473e-8eef-de2955f2f4d8	2026-07-21 11:45:44.744086+00	2026-07-21 11:45:44.744086+00
582b48ec-cec0-4e4b-a7d4-cbfd51751f0f	d75fe838-1e2c-40de-9508-d72d8961e8b5	77b8df83-b4f0-4924-9ef8-25216fe271af	تست و اطمینان از عملکرد صحیح	198	38	2026-07-12	approved	2b35422d-f7be-4135-8473-be7d9e83ec3d	\N	6f4133b1-352b-4b3c-ae4b-3e6104ac79bc	2026-07-21 11:45:44.744086+00	2026-07-21 11:45:44.744086+00
582b48ec-cec0-4e4b-a7d4-cbfd51751f0f	78023139-668b-4f4e-be1e-119fd54638b4	984c1d49-02d8-4d53-8ce0-f8709fafb190	پیشرفت اولیه و بررسی نیازمندی‌ها	165	21	2026-07-16	approved	2b35422d-f7be-4135-8473-be7d9e83ec3d	\N	18465156-7c13-4792-9b3d-d6ad915fb532	2026-07-21 11:45:44.744086+00	2026-07-21 11:45:44.744086+00
582b48ec-cec0-4e4b-a7d4-cbfd51751f0f	78023139-668b-4f4e-be1e-119fd54638b4	984c1d49-02d8-4d53-8ce0-f8709fafb190	مستندسازی و نهایی‌سازی	153	72	2026-07-16	approved	2b35422d-f7be-4135-8473-be7d9e83ec3d	\N	cfbed38f-3aa2-4a86-a103-e3e752237632	2026-07-21 11:45:44.744086+00	2026-07-21 11:45:44.744086+00
582b48ec-cec0-4e4b-a7d4-cbfd51751f0f	7d258429-2606-4579-8131-8ac1497471c2	e139f154-0fb4-4ebf-b8b8-b6f5a29afeaf	پیاده‌سازی بخش اصلی	56	32	2026-06-26	submitted	\N	\N	9ce76419-c0ee-43f6-ad79-cf5398174f73	2026-07-21 11:45:44.744086+00	2026-07-21 11:45:44.744086+00
582b48ec-cec0-4e4b-a7d4-cbfd51751f0f	7d258429-2606-4579-8131-8ac1497471c2	e139f154-0fb4-4ebf-b8b8-b6f5a29afeaf	تست و اطمینان از عملکرد صحیح	137	78	2026-06-29	approved	2b35422d-f7be-4135-8473-be7d9e83ec3d	\N	d20c259f-4db9-4266-b00d-82efd2be96ff	2026-07-21 11:45:44.744086+00	2026-07-21 11:45:44.744086+00
582b48ec-cec0-4e4b-a7d4-cbfd51751f0f	076005e3-2045-4028-91fb-e75a2d44898b	b4e312c2-6dc5-4616-97c7-1b9251f4ef87	رفع اشکالات و بازبینی	105	34	2026-07-16	approved	2b35422d-f7be-4135-8473-be7d9e83ec3d	\N	8c109a05-51cb-43d1-b95a-7586a4352452	2026-07-21 11:45:44.744086+00	2026-07-21 11:45:44.744086+00
582b48ec-cec0-4e4b-a7d4-cbfd51751f0f	076005e3-2045-4028-91fb-e75a2d44898b	b4e312c2-6dc5-4616-97c7-1b9251f4ef87	مستندسازی و نهایی‌سازی	209	72	2026-07-16	approved	2b35422d-f7be-4135-8473-be7d9e83ec3d	\N	efa210cb-bcf0-4a8c-b1ff-5017ab4f3259	2026-07-21 11:45:44.744086+00	2026-07-21 11:45:44.744086+00
582b48ec-cec0-4e4b-a7d4-cbfd51751f0f	f9c0e78e-a333-46c1-a5a8-4ed642c64b70	984c1d49-02d8-4d53-8ce0-f8709fafb190	مستندسازی و نهایی‌سازی	191	26	2026-07-01	submitted	\N	\N	309aee73-cc46-4a11-b41d-4ff9b5301243	2026-07-21 11:45:44.744086+00	2026-07-21 11:45:44.744086+00
582b48ec-cec0-4e4b-a7d4-cbfd51751f0f	f9c0e78e-a333-46c1-a5a8-4ed642c64b70	984c1d49-02d8-4d53-8ce0-f8709fafb190	رفع اشکالات و بازبینی	205	62	2026-07-03	approved	2b35422d-f7be-4135-8473-be7d9e83ec3d	\N	b88761c6-4450-41d0-8687-534c3aa13a97	2026-07-21 11:45:44.744086+00	2026-07-21 11:45:44.744086+00
582b48ec-cec0-4e4b-a7d4-cbfd51751f0f	f9c0e78e-a333-46c1-a5a8-4ed642c64b70	984c1d49-02d8-4d53-8ce0-f8709fafb190	پیاده‌سازی بخش اصلی	158	100	2026-07-05	submitted	\N	\N	3cb45f24-95b1-4611-985f-6e7d3b17bb2b	2026-07-21 11:45:44.744086+00	2026-07-21 11:45:44.744086+00
582b48ec-cec0-4e4b-a7d4-cbfd51751f0f	03a4ef6c-1bf6-447e-bc6c-0f13fafac44c	e139f154-0fb4-4ebf-b8b8-b6f5a29afeaf	رفع اشکالات و بازبینی	173	35	2026-06-28	approved	2b35422d-f7be-4135-8473-be7d9e83ec3d	\N	df49178b-c77c-44e8-883f-71e8b8a9a6ec	2026-07-21 11:45:44.744086+00	2026-07-21 11:45:44.744086+00
582b48ec-cec0-4e4b-a7d4-cbfd51751f0f	03a4ef6c-1bf6-447e-bc6c-0f13fafac44c	e139f154-0fb4-4ebf-b8b8-b6f5a29afeaf	مستندسازی و نهایی‌سازی	103	66	2026-07-02	approved	2b35422d-f7be-4135-8473-be7d9e83ec3d	\N	2735d1ac-9204-47f8-a47c-93b5e289ded1	2026-07-21 11:45:44.744086+00	2026-07-21 11:45:44.744086+00
582b48ec-cec0-4e4b-a7d4-cbfd51751f0f	03a4ef6c-1bf6-447e-bc6c-0f13fafac44c	e139f154-0fb4-4ebf-b8b8-b6f5a29afeaf	مستندسازی و نهایی‌سازی	57	60	2026-06-30	approved	2b35422d-f7be-4135-8473-be7d9e83ec3d	\N	1f1d06c0-87d8-4b45-882c-8d700c296e7f	2026-07-21 11:45:44.744086+00	2026-07-21 11:45:44.744086+00
582b48ec-cec0-4e4b-a7d4-cbfd51751f0f	07261e1f-7c6c-474b-a9bf-f17bb9975bde	e139f154-0fb4-4ebf-b8b8-b6f5a29afeaf	پیشرفت اولیه و بررسی نیازمندی‌ها	81	28	2026-06-21	approved	2b35422d-f7be-4135-8473-be7d9e83ec3d	\N	9a69cfc3-6bf3-406b-8c06-d064c782b71f	2026-07-21 11:45:44.744086+00	2026-07-21 11:45:44.744086+00
582b48ec-cec0-4e4b-a7d4-cbfd51751f0f	07261e1f-7c6c-474b-a9bf-f17bb9975bde	e139f154-0fb4-4ebf-b8b8-b6f5a29afeaf	رفع اشکالات و بازبینی	67	42	2026-06-23	submitted	\N	\N	6b92d3e7-4630-447a-9cb0-308f7f5412ce	2026-07-21 11:45:44.744086+00	2026-07-21 11:45:44.744086+00
582b48ec-cec0-4e4b-a7d4-cbfd51751f0f	07261e1f-7c6c-474b-a9bf-f17bb9975bde	e139f154-0fb4-4ebf-b8b8-b6f5a29afeaf	مستندسازی و نهایی‌سازی	38	93	2026-06-27	approved	2b35422d-f7be-4135-8473-be7d9e83ec3d	\N	24931456-e3d2-4487-81f7-c4f43068e86d	2026-07-21 11:45:44.744086+00	2026-07-21 11:45:44.744086+00
582b48ec-cec0-4e4b-a7d4-cbfd51751f0f	07261e1f-7c6c-474b-a9bf-f17bb9975bde	e139f154-0fb4-4ebf-b8b8-b6f5a29afeaf	مستندسازی و نهایی‌سازی	87	100	2026-07-03	approved	2b35422d-f7be-4135-8473-be7d9e83ec3d	\N	84478b74-a6fc-4590-9a54-cd932c347650	2026-07-21 11:45:44.744086+00	2026-07-21 11:45:44.744086+00
582b48ec-cec0-4e4b-a7d4-cbfd51751f0f	b3230bf2-ce42-491a-9f70-171afe328485	02d643cd-bc19-4efb-9d1a-c3e6d5675d66	رفع اشکالات و بازبینی	207	21	2026-07-16	approved	2b35422d-f7be-4135-8473-be7d9e83ec3d	\N	e6754a55-4438-405a-bc59-8fb798f5a272	2026-07-21 11:45:44.744086+00	2026-07-21 11:45:44.744086+00
582b48ec-cec0-4e4b-a7d4-cbfd51751f0f	b3230bf2-ce42-491a-9f70-171afe328485	02d643cd-bc19-4efb-9d1a-c3e6d5675d66	رفع اشکالات و بازبینی	171	42	2026-07-16	approved	2b35422d-f7be-4135-8473-be7d9e83ec3d	\N	f52d16fc-863f-433a-8bb6-4b6aad5c055f	2026-07-21 11:45:44.744086+00	2026-07-21 11:45:44.744086+00
582b48ec-cec0-4e4b-a7d4-cbfd51751f0f	b3230bf2-ce42-491a-9f70-171afe328485	02d643cd-bc19-4efb-9d1a-c3e6d5675d66	پیاده‌سازی بخش اصلی	188	100	2026-07-16	submitted	\N	\N	bf768074-f21b-44b4-90de-d23f881902e2	2026-07-21 11:45:44.744086+00	2026-07-21 11:45:44.744086+00
582b48ec-cec0-4e4b-a7d4-cbfd51751f0f	b3230bf2-ce42-491a-9f70-171afe328485	02d643cd-bc19-4efb-9d1a-c3e6d5675d66	رفع اشکالات و بازبینی	223	100	2026-07-16	submitted	\N	\N	8b5ebedf-3843-46ae-8e00-28f4269e0fbd	2026-07-21 11:45:44.744086+00	2026-07-21 11:45:44.744086+00
582b48ec-cec0-4e4b-a7d4-cbfd51751f0f	7f400ec8-aa07-4bfa-906b-9f555d955112	984c1d49-02d8-4d53-8ce0-f8709fafb190	رفع اشکالات و بازبینی	144	25	2026-07-16	approved	2b35422d-f7be-4135-8473-be7d9e83ec3d	\N	d9e7a00c-c6cc-4a54-a94c-febfe82beb13	2026-07-21 11:45:44.744086+00	2026-07-21 11:45:44.744086+00
582b48ec-cec0-4e4b-a7d4-cbfd51751f0f	7f400ec8-aa07-4bfa-906b-9f555d955112	984c1d49-02d8-4d53-8ce0-f8709fafb190	پیاده‌سازی بخش اصلی	74	72	2026-07-16	approved	2b35422d-f7be-4135-8473-be7d9e83ec3d	\N	ad77facb-b639-41ec-8fd1-66ae7c052d2c	2026-07-21 11:45:44.744086+00	2026-07-21 11:45:44.744086+00
582b48ec-cec0-4e4b-a7d4-cbfd51751f0f	6a6b4390-a15b-4fff-8782-8d5736a3a562	77b8df83-b4f0-4924-9ef8-25216fe271af	پیشرفت اولیه و بررسی نیازمندی‌ها	139	28	2026-07-16	approved	2b35422d-f7be-4135-8473-be7d9e83ec3d	\N	0d0398a0-e03d-4c1f-8cc8-b3d057a8b642	2026-07-21 11:45:44.744086+00	2026-07-21 11:45:44.744086+00
582b48ec-cec0-4e4b-a7d4-cbfd51751f0f	7a92a414-061b-4f7f-9670-64f74ec5b99f	2b35422d-f7be-4135-8473-be7d9e83ec3d	رفع اشکالات و بازبینی	31	30	2026-07-16	approved	2b35422d-f7be-4135-8473-be7d9e83ec3d	\N	a1c6ee39-4063-486e-941b-6a0087678b46	2026-07-21 11:45:44.744086+00	2026-07-21 11:45:44.744086+00
582b48ec-cec0-4e4b-a7d4-cbfd51751f0f	7a92a414-061b-4f7f-9670-64f74ec5b99f	2b35422d-f7be-4135-8473-be7d9e83ec3d	پیاده‌سازی بخش اصلی	40	48	2026-07-16	submitted	\N	\N	a58d7a43-a503-46a8-a362-3f49246658a2	2026-07-21 11:45:44.744086+00	2026-07-21 11:45:44.744086+00
582b48ec-cec0-4e4b-a7d4-cbfd51751f0f	7a92a414-061b-4f7f-9670-64f74ec5b99f	2b35422d-f7be-4135-8473-be7d9e83ec3d	مستندسازی و نهایی‌سازی	199	87	2026-07-16	approved	2b35422d-f7be-4135-8473-be7d9e83ec3d	\N	5ad51e4a-b925-4442-ad28-f200c093eafb	2026-07-21 11:45:44.744086+00	2026-07-21 11:45:44.744086+00
582b48ec-cec0-4e4b-a7d4-cbfd51751f0f	1afbbb8e-f544-4ad8-8d93-a7ba461fb060	e139f154-0fb4-4ebf-b8b8-b6f5a29afeaf	پیشرفت اولیه و بررسی نیازمندی‌ها	230	30	2026-07-16	approved	2b35422d-f7be-4135-8473-be7d9e83ec3d	\N	0f7207a9-3bfd-4122-9a65-661001e79f60	2026-07-21 11:45:44.744086+00	2026-07-21 11:45:44.744086+00
582b48ec-cec0-4e4b-a7d4-cbfd51751f0f	1afbbb8e-f544-4ad8-8d93-a7ba461fb060	e139f154-0fb4-4ebf-b8b8-b6f5a29afeaf	پیاده‌سازی بخش اصلی	163	44	2026-07-16	approved	2b35422d-f7be-4135-8473-be7d9e83ec3d	\N	2eb78a8f-8e67-4f67-8e47-9176bd57f52f	2026-07-21 11:45:44.744086+00	2026-07-21 11:45:44.744086+00
582b48ec-cec0-4e4b-a7d4-cbfd51751f0f	1afbbb8e-f544-4ad8-8d93-a7ba461fb060	e139f154-0fb4-4ebf-b8b8-b6f5a29afeaf	تست و اطمینان از عملکرد صحیح	169	100	2026-07-16	approved	2b35422d-f7be-4135-8473-be7d9e83ec3d	\N	6091cc14-dd8a-49a5-bca8-2fa4bb78400b	2026-07-21 11:45:44.744086+00	2026-07-21 11:45:44.744086+00
582b48ec-cec0-4e4b-a7d4-cbfd51751f0f	1afbbb8e-f544-4ad8-8d93-a7ba461fb060	e139f154-0fb4-4ebf-b8b8-b6f5a29afeaf	پیشرفت اولیه و بررسی نیازمندی‌ها	119	100	2026-07-16	approved	2b35422d-f7be-4135-8473-be7d9e83ec3d	\N	e361587d-9427-4cd3-b099-733aad42868b	2026-07-21 11:45:44.744086+00	2026-07-21 11:45:44.744086+00
582b48ec-cec0-4e4b-a7d4-cbfd51751f0f	1b610d2a-7dfe-428f-8813-2ab47f7bf0a7	02d643cd-bc19-4efb-9d1a-c3e6d5675d66	رفع اشکالات و بازبینی	122	29	2026-07-16	approved	2b35422d-f7be-4135-8473-be7d9e83ec3d	\N	d4caf4ba-d715-45b6-8601-28cc90bea5ce	2026-07-21 11:45:44.744086+00	2026-07-21 11:45:44.744086+00
582b48ec-cec0-4e4b-a7d4-cbfd51751f0f	1b610d2a-7dfe-428f-8813-2ab47f7bf0a7	02d643cd-bc19-4efb-9d1a-c3e6d5675d66	مستندسازی و نهایی‌سازی	165	70	2026-07-16	approved	2b35422d-f7be-4135-8473-be7d9e83ec3d	\N	318f97a3-46a5-4f75-8b17-66844f356dbc	2026-07-21 11:45:44.744086+00	2026-07-21 11:45:44.744086+00
582b48ec-cec0-4e4b-a7d4-cbfd51751f0f	5d389730-f190-4aff-97fb-82b7202288ac	c3bd6208-d89c-402a-90fe-6f00c4219566	رفع اشکالات و بازبینی	144	27	2026-06-16	approved	2b35422d-f7be-4135-8473-be7d9e83ec3d	\N	b2f3f546-aa47-4946-93ea-192f35e71a8c	2026-07-21 11:45:44.744086+00	2026-07-21 11:45:44.744086+00
582b48ec-cec0-4e4b-a7d4-cbfd51751f0f	d389f9b0-345b-44d4-a2ed-a544c60f42d1	2b35422d-f7be-4135-8473-be7d9e83ec3d	رفع اشکالات و بازبینی	127	23	2026-06-25	approved	2b35422d-f7be-4135-8473-be7d9e83ec3d	\N	d16649e3-ef4f-40e3-bbe5-7133c8be539c	2026-07-21 11:45:44.744086+00	2026-07-21 11:45:44.744086+00
582b48ec-cec0-4e4b-a7d4-cbfd51751f0f	d389f9b0-345b-44d4-a2ed-a544c60f42d1	2b35422d-f7be-4135-8473-be7d9e83ec3d	رفع اشکالات و بازبینی	36	72	2026-06-29	approved	2b35422d-f7be-4135-8473-be7d9e83ec3d	\N	7bbcbd74-c9d5-4126-b774-7ec5d13815e5	2026-07-21 11:45:44.744086+00	2026-07-21 11:45:44.744086+00
582b48ec-cec0-4e4b-a7d4-cbfd51751f0f	0c1eb44a-2802-4c0e-b6c1-5d5661379db9	77b8df83-b4f0-4924-9ef8-25216fe271af	رفع اشکالات و بازبینی	196	26	2026-07-10	approved	2b35422d-f7be-4135-8473-be7d9e83ec3d	\N	f2ee27f9-2117-45a3-acac-1ea421bd1fbb	2026-07-21 11:45:44.744086+00	2026-07-21 11:45:44.744086+00
582b48ec-cec0-4e4b-a7d4-cbfd51751f0f	0c1eb44a-2802-4c0e-b6c1-5d5661379db9	77b8df83-b4f0-4924-9ef8-25216fe271af	پیشرفت اولیه و بررسی نیازمندی‌ها	72	74	2026-07-13	approved	2b35422d-f7be-4135-8473-be7d9e83ec3d	\N	9cbda626-ce7b-4955-baf3-d11e8602ddaa	2026-07-21 11:45:44.744086+00	2026-07-21 11:45:44.744086+00
582b48ec-cec0-4e4b-a7d4-cbfd51751f0f	0c1eb44a-2802-4c0e-b6c1-5d5661379db9	77b8df83-b4f0-4924-9ef8-25216fe271af	پیاده‌سازی بخش اصلی	201	100	2026-07-12	approved	2b35422d-f7be-4135-8473-be7d9e83ec3d	\N	86dd9166-a967-4839-9821-8170f502d367	2026-07-21 11:45:44.744086+00	2026-07-21 11:45:44.744086+00
582b48ec-cec0-4e4b-a7d4-cbfd51751f0f	16db9c03-be47-4349-8723-888161d55e09	984c1d49-02d8-4d53-8ce0-f8709fafb190	پیاده‌سازی بخش اصلی	167	33	2026-06-25	submitted	\N	\N	0e7f5c78-86ed-4def-8ef4-240574cd0e5a	2026-07-21 11:45:44.744086+00	2026-07-21 11:45:44.744086+00
582b48ec-cec0-4e4b-a7d4-cbfd51751f0f	16db9c03-be47-4349-8723-888161d55e09	984c1d49-02d8-4d53-8ce0-f8709fafb190	پیاده‌سازی بخش اصلی	36	68	2026-06-26	submitted	\N	\N	efc63974-c920-4afb-8c19-cc9a817f3a5b	2026-07-21 11:45:44.744086+00	2026-07-21 11:45:44.744086+00
582b48ec-cec0-4e4b-a7d4-cbfd51751f0f	00bbadee-3e78-410a-8169-fb1490ccf25d	984c1d49-02d8-4d53-8ce0-f8709fafb190	پیشرفت اولیه و بررسی نیازمندی‌ها	48	21	2026-07-16	approved	2b35422d-f7be-4135-8473-be7d9e83ec3d	\N	fd34b29a-9071-4bed-9825-626d3e5015ce	2026-07-21 11:45:44.744086+00	2026-07-21 11:45:44.744086+00
582b48ec-cec0-4e4b-a7d4-cbfd51751f0f	00bbadee-3e78-410a-8169-fb1490ccf25d	984c1d49-02d8-4d53-8ce0-f8709fafb190	رفع اشکالات و بازبینی	172	44	2026-07-16	approved	2b35422d-f7be-4135-8473-be7d9e83ec3d	\N	9924bf26-e875-43f2-9bc7-d39da9732bcb	2026-07-21 11:45:44.744086+00	2026-07-21 11:45:44.744086+00
582b48ec-cec0-4e4b-a7d4-cbfd51751f0f	00bbadee-3e78-410a-8169-fb1490ccf25d	984c1d49-02d8-4d53-8ce0-f8709fafb190	رفع اشکالات و بازبینی	134	96	2026-07-16	approved	2b35422d-f7be-4135-8473-be7d9e83ec3d	\N	e6dd00a4-eef8-48bd-b38c-fbcf9fede929	2026-07-21 11:45:44.744086+00	2026-07-21 11:45:44.744086+00
582b48ec-cec0-4e4b-a7d4-cbfd51751f0f	d4e6d829-e289-4c32-97fd-44b8fc2f62eb	2b35422d-f7be-4135-8473-be7d9e83ec3d	پیشرفت اولیه و بررسی نیازمندی‌ها	129	23	2026-07-16	approved	2b35422d-f7be-4135-8473-be7d9e83ec3d	\N	44e49c4f-994a-4eef-ab3c-4080e9e618ac	2026-07-21 11:45:44.744086+00	2026-07-21 11:45:44.744086+00
582b48ec-cec0-4e4b-a7d4-cbfd51751f0f	d4e6d829-e289-4c32-97fd-44b8fc2f62eb	2b35422d-f7be-4135-8473-be7d9e83ec3d	مستندسازی و نهایی‌سازی	46	76	2026-07-16	approved	2b35422d-f7be-4135-8473-be7d9e83ec3d	\N	4d4f85bb-dcaa-4021-9e34-eb472dcd8cfd	2026-07-21 11:45:44.744086+00	2026-07-21 11:45:44.744086+00
582b48ec-cec0-4e4b-a7d4-cbfd51751f0f	d4e6d829-e289-4c32-97fd-44b8fc2f62eb	2b35422d-f7be-4135-8473-be7d9e83ec3d	پیشرفت اولیه و بررسی نیازمندی‌ها	121	100	2026-07-16	submitted	\N	\N	6d5547f9-deea-4a14-8d0b-093436e9bd13	2026-07-21 11:45:44.744086+00	2026-07-21 11:45:44.744086+00
582b48ec-cec0-4e4b-a7d4-cbfd51751f0f	d4e6d829-e289-4c32-97fd-44b8fc2f62eb	2b35422d-f7be-4135-8473-be7d9e83ec3d	رفع اشکالات و بازبینی	185	88	2026-07-16	approved	2b35422d-f7be-4135-8473-be7d9e83ec3d	\N	4fac9f5a-bcbb-4b57-94de-0deca2541a6c	2026-07-21 11:45:44.744086+00	2026-07-21 11:45:44.744086+00
582b48ec-cec0-4e4b-a7d4-cbfd51751f0f	19eaa098-bc71-4813-9d87-6217e51e3af7	984c1d49-02d8-4d53-8ce0-f8709fafb190	پیشرفت اولیه و بررسی نیازمندی‌ها	151	25	2026-07-16	approved	2b35422d-f7be-4135-8473-be7d9e83ec3d	\N	0d644cce-9893-4349-abbd-e3d209e3268d	2026-07-21 11:45:44.744086+00	2026-07-21 11:45:44.744086+00
582b48ec-cec0-4e4b-a7d4-cbfd51751f0f	19eaa098-bc71-4813-9d87-6217e51e3af7	984c1d49-02d8-4d53-8ce0-f8709fafb190	تست و اطمینان از عملکرد صحیح	233	74	2026-07-16	approved	2b35422d-f7be-4135-8473-be7d9e83ec3d	\N	ff0c1ae6-9287-4c23-9782-7758e379e14e	2026-07-21 11:45:44.744086+00	2026-07-21 11:45:44.744086+00
582b48ec-cec0-4e4b-a7d4-cbfd51751f0f	19eaa098-bc71-4813-9d87-6217e51e3af7	984c1d49-02d8-4d53-8ce0-f8709fafb190	پیاده‌سازی بخش اصلی	106	100	2026-07-16	submitted	\N	\N	92f14b0d-8eab-4722-93a1-bae2d5ca52bb	2026-07-21 11:45:44.744086+00	2026-07-21 11:45:44.744086+00
582b48ec-cec0-4e4b-a7d4-cbfd51751f0f	1e192ee6-9f49-47c3-a524-0563e0f663ad	b4e312c2-6dc5-4616-97c7-1b9251f4ef87	مستندسازی و نهایی‌سازی	66	23	2026-07-16	approved	2b35422d-f7be-4135-8473-be7d9e83ec3d	\N	898f6d4d-a233-4add-8d52-8f20db3301a1	2026-07-21 11:45:44.744086+00	2026-07-21 11:45:44.744086+00
582b48ec-cec0-4e4b-a7d4-cbfd51751f0f	1e192ee6-9f49-47c3-a524-0563e0f663ad	b4e312c2-6dc5-4616-97c7-1b9251f4ef87	مستندسازی و نهایی‌سازی	130	74	2026-07-16	approved	2b35422d-f7be-4135-8473-be7d9e83ec3d	\N	349dcb63-b01e-4f3d-82dd-4337b4b7e6e6	2026-07-21 11:45:44.744086+00	2026-07-21 11:45:44.744086+00
582b48ec-cec0-4e4b-a7d4-cbfd51751f0f	1e192ee6-9f49-47c3-a524-0563e0f663ad	b4e312c2-6dc5-4616-97c7-1b9251f4ef87	رفع اشکالات و بازبینی	84	99	2026-07-16	approved	2b35422d-f7be-4135-8473-be7d9e83ec3d	\N	29ff7157-5a5c-4119-95d3-d15dc205afef	2026-07-21 11:45:44.744086+00	2026-07-21 11:45:44.744086+00
582b48ec-cec0-4e4b-a7d4-cbfd51751f0f	08f9ced2-8891-4b96-bc5a-dc4ef044d7d0	02d643cd-bc19-4efb-9d1a-c3e6d5675d66	پیاده‌سازی بخش اصلی	86	39	2026-06-17	approved	2b35422d-f7be-4135-8473-be7d9e83ec3d	\N	431a3528-f0c9-4849-bd92-3543d0452137	2026-07-21 11:45:44.744086+00	2026-07-21 11:45:44.744086+00
582b48ec-cec0-4e4b-a7d4-cbfd51751f0f	08f9ced2-8891-4b96-bc5a-dc4ef044d7d0	02d643cd-bc19-4efb-9d1a-c3e6d5675d66	پیاده‌سازی بخش اصلی	59	50	2026-06-20	approved	2b35422d-f7be-4135-8473-be7d9e83ec3d	\N	9bc3e256-8a02-48f0-8433-b1932f13cf1e	2026-07-21 11:45:44.744086+00	2026-07-21 11:45:44.744086+00
582b48ec-cec0-4e4b-a7d4-cbfd51751f0f	79998774-9174-4813-8c5e-262388ce3872	02d643cd-bc19-4efb-9d1a-c3e6d5675d66	مستندسازی و نهایی‌سازی	48	29	2026-07-16	approved	2b35422d-f7be-4135-8473-be7d9e83ec3d	\N	02847a40-5168-45b6-9ce0-e90a48fb27f3	2026-07-21 11:45:44.744086+00	2026-07-21 11:45:44.744086+00
582b48ec-cec0-4e4b-a7d4-cbfd51751f0f	9c1d261a-9015-4768-93a5-4c40b9691bfe	77b8df83-b4f0-4924-9ef8-25216fe271af	پیشرفت اولیه و بررسی نیازمندی‌ها	80	38	2026-07-16	approved	2b35422d-f7be-4135-8473-be7d9e83ec3d	\N	b991f544-2262-4d0a-ba18-7ef99277f12c	2026-07-21 11:45:44.744086+00	2026-07-21 11:45:44.744086+00
582b48ec-cec0-4e4b-a7d4-cbfd51751f0f	9817621a-0b86-4eba-bdf9-c05fd69f599c	b4e312c2-6dc5-4616-97c7-1b9251f4ef87	پیاده‌سازی بخش اصلی	55	29	2026-07-16	approved	2b35422d-f7be-4135-8473-be7d9e83ec3d	\N	3dd9e482-81a7-4174-bb6c-f6d8032d46bd	2026-07-21 11:45:44.744086+00	2026-07-21 11:45:44.744086+00
582b48ec-cec0-4e4b-a7d4-cbfd51751f0f	9817621a-0b86-4eba-bdf9-c05fd69f599c	b4e312c2-6dc5-4616-97c7-1b9251f4ef87	رفع اشکالات و بازبینی	154	68	2026-07-16	submitted	\N	\N	d4a8f4c5-a281-4591-b66d-1dd7742e7149	2026-07-21 11:45:44.744086+00	2026-07-21 11:45:44.744086+00
582b48ec-cec0-4e4b-a7d4-cbfd51751f0f	9817621a-0b86-4eba-bdf9-c05fd69f599c	b4e312c2-6dc5-4616-97c7-1b9251f4ef87	رفع اشکالات و بازبینی	207	100	2026-07-16	approved	2b35422d-f7be-4135-8473-be7d9e83ec3d	\N	793559d7-faa1-4d6e-b8cc-b5189c4908ab	2026-07-21 11:45:44.744086+00	2026-07-21 11:45:44.744086+00
582b48ec-cec0-4e4b-a7d4-cbfd51751f0f	9817621a-0b86-4eba-bdf9-c05fd69f599c	b4e312c2-6dc5-4616-97c7-1b9251f4ef87	رفع اشکالات و بازبینی	236	100	2026-07-16	approved	2b35422d-f7be-4135-8473-be7d9e83ec3d	\N	381e141e-fa89-4ea6-862e-268e8b815b99	2026-07-21 11:45:44.744086+00	2026-07-21 11:45:44.744086+00
582b48ec-cec0-4e4b-a7d4-cbfd51751f0f	4ff84820-2710-4cc9-a9a5-e69eadfb4498	02d643cd-bc19-4efb-9d1a-c3e6d5675d66	پیشرفت اولیه و بررسی نیازمندی‌ها	110	27	2026-06-29	approved	2b35422d-f7be-4135-8473-be7d9e83ec3d	\N	ffb656fd-28b2-4155-9894-ff17791b7ebd	2026-07-21 11:45:44.744086+00	2026-07-21 11:45:44.744086+00
582b48ec-cec0-4e4b-a7d4-cbfd51751f0f	4ff84820-2710-4cc9-a9a5-e69eadfb4498	02d643cd-bc19-4efb-9d1a-c3e6d5675d66	تست و اطمینان از عملکرد صحیح	100	62	2026-07-01	approved	2b35422d-f7be-4135-8473-be7d9e83ec3d	\N	63b97cce-5ec1-41e8-85b8-df232f03348b	2026-07-21 11:45:44.744086+00	2026-07-21 11:45:44.744086+00
582b48ec-cec0-4e4b-a7d4-cbfd51751f0f	4ff84820-2710-4cc9-a9a5-e69eadfb4498	02d643cd-bc19-4efb-9d1a-c3e6d5675d66	رفع اشکالات و بازبینی	152	100	2026-07-03	approved	2b35422d-f7be-4135-8473-be7d9e83ec3d	\N	dcd6c344-8f3f-4b3f-b888-e891483e80a6	2026-07-21 11:45:44.744086+00	2026-07-21 11:45:44.744086+00
582b48ec-cec0-4e4b-a7d4-cbfd51751f0f	4ff84820-2710-4cc9-a9a5-e69eadfb4498	02d643cd-bc19-4efb-9d1a-c3e6d5675d66	رفع اشکالات و بازبینی	228	100	2026-07-11	approved	2b35422d-f7be-4135-8473-be7d9e83ec3d	\N	8b028212-5b61-453a-8fa8-bf448004c7d8	2026-07-21 11:45:44.744086+00	2026-07-21 11:45:44.744086+00
582b48ec-cec0-4e4b-a7d4-cbfd51751f0f	5f6fa171-82f3-4b9f-9504-1980f716b6a8	984c1d49-02d8-4d53-8ce0-f8709fafb190	پیاده‌سازی بخش اصلی	195	39	2026-06-17	approved	2b35422d-f7be-4135-8473-be7d9e83ec3d	\N	4e409e96-8654-478e-be3f-57a4ede2fb12	2026-07-21 11:45:44.744086+00	2026-07-21 11:45:44.744086+00
582b48ec-cec0-4e4b-a7d4-cbfd51751f0f	5f6fa171-82f3-4b9f-9504-1980f716b6a8	984c1d49-02d8-4d53-8ce0-f8709fafb190	رفع اشکالات و بازبینی	65	74	2026-06-18	approved	2b35422d-f7be-4135-8473-be7d9e83ec3d	\N	19950d52-d7a8-421a-b7f1-1831dfaef8d6	2026-07-21 11:45:44.744086+00	2026-07-21 11:45:44.744086+00
582b48ec-cec0-4e4b-a7d4-cbfd51751f0f	5f6fa171-82f3-4b9f-9504-1980f716b6a8	984c1d49-02d8-4d53-8ce0-f8709fafb190	رفع اشکالات و بازبینی	217	100	2026-06-21	approved	2b35422d-f7be-4135-8473-be7d9e83ec3d	\N	bd48ebd2-6cdc-4237-8cd9-a8e31ef18d01	2026-07-21 11:45:44.744086+00	2026-07-21 11:45:44.744086+00
582b48ec-cec0-4e4b-a7d4-cbfd51751f0f	5f6fa171-82f3-4b9f-9504-1980f716b6a8	984c1d49-02d8-4d53-8ce0-f8709fafb190	پیشرفت اولیه و بررسی نیازمندی‌ها	34	100	2026-06-20	approved	2b35422d-f7be-4135-8473-be7d9e83ec3d	\N	1c028f03-09cd-4e8f-a619-2278cc690c06	2026-07-21 11:45:44.744086+00	2026-07-21 11:45:44.744086+00
582b48ec-cec0-4e4b-a7d4-cbfd51751f0f	7777dc96-da1c-4593-8fa9-d8b833ee6dcc	77b8df83-b4f0-4924-9ef8-25216fe271af	پیاده‌سازی بخش اصلی	39	37	2026-07-15	submitted	\N	\N	c6cfbebc-0391-4cc6-8c6a-63eb13172135	2026-07-21 11:45:44.744086+00	2026-07-21 11:45:44.744086+00
582b48ec-cec0-4e4b-a7d4-cbfd51751f0f	14fc2bd7-a977-4a9a-9b26-59dd13aca47a	02d643cd-bc19-4efb-9d1a-c3e6d5675d66	پیاده‌سازی بخش اصلی	123	32	2026-06-22	approved	2b35422d-f7be-4135-8473-be7d9e83ec3d	\N	3b157419-4216-4495-b678-19b134008552	2026-07-21 11:45:44.744086+00	2026-07-21 11:45:44.744086+00
582b48ec-cec0-4e4b-a7d4-cbfd51751f0f	14fc2bd7-a977-4a9a-9b26-59dd13aca47a	02d643cd-bc19-4efb-9d1a-c3e6d5675d66	مستندسازی و نهایی‌سازی	217	58	2026-06-24	approved	2b35422d-f7be-4135-8473-be7d9e83ec3d	\N	4f80210e-3fe6-40d1-9fae-72cae9d2736b	2026-07-21 11:45:44.744086+00	2026-07-21 11:45:44.744086+00
582b48ec-cec0-4e4b-a7d4-cbfd51751f0f	14fc2bd7-a977-4a9a-9b26-59dd13aca47a	02d643cd-bc19-4efb-9d1a-c3e6d5675d66	تست و اطمینان از عملکرد صحیح	158	100	2026-06-26	approved	2b35422d-f7be-4135-8473-be7d9e83ec3d	\N	cf134497-2dbe-4ec5-8214-9ab82b8baaac	2026-07-21 11:45:44.744086+00	2026-07-21 11:45:44.744086+00
582b48ec-cec0-4e4b-a7d4-cbfd51751f0f	bcc7d5fc-9095-4f08-abca-9be7cc9a6ff6	02d643cd-bc19-4efb-9d1a-c3e6d5675d66	پیشرفت اولیه و بررسی نیازمندی‌ها	199	27	2026-07-16	approved	2b35422d-f7be-4135-8473-be7d9e83ec3d	\N	628a5660-adc5-4298-9c58-522b881f7a19	2026-07-21 11:45:44.744086+00	2026-07-21 11:45:44.744086+00
582b48ec-cec0-4e4b-a7d4-cbfd51751f0f	0d855ffd-d783-46a2-9935-ced506b65ae5	e139f154-0fb4-4ebf-b8b8-b6f5a29afeaf	تست و اطمینان از عملکرد صحیح	70	25	2026-06-25	approved	2b35422d-f7be-4135-8473-be7d9e83ec3d	\N	d3379b29-2cb1-4a21-906d-16939fdd9e31	2026-07-21 11:45:44.744086+00	2026-07-21 11:45:44.744086+00
582b48ec-cec0-4e4b-a7d4-cbfd51751f0f	0d855ffd-d783-46a2-9935-ced506b65ae5	e139f154-0fb4-4ebf-b8b8-b6f5a29afeaf	تست و اطمینان از عملکرد صحیح	121	42	2026-06-27	approved	2b35422d-f7be-4135-8473-be7d9e83ec3d	\N	7b88fd88-8958-4392-9eb1-7c0dd3f0786f	2026-07-21 11:45:44.744086+00	2026-07-21 11:45:44.744086+00
582b48ec-cec0-4e4b-a7d4-cbfd51751f0f	75962ffc-85f8-4f51-a8cc-302c359211b6	02d643cd-bc19-4efb-9d1a-c3e6d5675d66	پیاده‌سازی بخش اصلی	46	28	2026-07-06	approved	2b35422d-f7be-4135-8473-be7d9e83ec3d	\N	e43cc634-17c0-4f56-8c75-92aec81dbb1a	2026-07-21 11:45:44.744086+00	2026-07-21 11:45:44.744086+00
582b48ec-cec0-4e4b-a7d4-cbfd51751f0f	75962ffc-85f8-4f51-a8cc-302c359211b6	02d643cd-bc19-4efb-9d1a-c3e6d5675d66	پیاده‌سازی بخش اصلی	40	52	2026-07-09	approved	2b35422d-f7be-4135-8473-be7d9e83ec3d	\N	78b5c07d-9710-42bb-b7bf-5207862a01ef	2026-07-21 11:45:44.744086+00	2026-07-21 11:45:44.744086+00
582b48ec-cec0-4e4b-a7d4-cbfd51751f0f	778ed431-cef7-4288-aa57-d49d6b894e37	984c1d49-02d8-4d53-8ce0-f8709fafb190	تست و اطمینان از عملکرد صحیح	41	21	2026-07-16	approved	2b35422d-f7be-4135-8473-be7d9e83ec3d	\N	5a74745a-d035-4d93-ad57-7dbe3647dd37	2026-07-21 11:45:44.744086+00	2026-07-21 11:45:44.744086+00
582b48ec-cec0-4e4b-a7d4-cbfd51751f0f	778ed431-cef7-4288-aa57-d49d6b894e37	984c1d49-02d8-4d53-8ce0-f8709fafb190	مستندسازی و نهایی‌سازی	192	56	2026-07-16	approved	2b35422d-f7be-4135-8473-be7d9e83ec3d	\N	bd85128e-763b-4f34-ba75-41342d9fe7d4	2026-07-21 11:45:44.744086+00	2026-07-21 11:45:44.744086+00
582b48ec-cec0-4e4b-a7d4-cbfd51751f0f	778ed431-cef7-4288-aa57-d49d6b894e37	984c1d49-02d8-4d53-8ce0-f8709fafb190	مستندسازی و نهایی‌سازی	74	96	2026-07-16	approved	2b35422d-f7be-4135-8473-be7d9e83ec3d	\N	58343c45-da16-4563-a82f-68c0efa37b32	2026-07-21 11:45:44.744086+00	2026-07-21 11:45:44.744086+00
582b48ec-cec0-4e4b-a7d4-cbfd51751f0f	71b000e1-ab7a-4db5-9c6c-47b9b63d4755	e139f154-0fb4-4ebf-b8b8-b6f5a29afeaf	پیشرفت اولیه و بررسی نیازمندی‌ها	162	28	2026-07-16	approved	2b35422d-f7be-4135-8473-be7d9e83ec3d	\N	d48ca20a-2264-4e22-ae2c-d17d055e4ec1	2026-07-21 11:45:44.744086+00	2026-07-21 11:45:44.744086+00
582b48ec-cec0-4e4b-a7d4-cbfd51751f0f	71b000e1-ab7a-4db5-9c6c-47b9b63d4755	e139f154-0fb4-4ebf-b8b8-b6f5a29afeaf	پیاده‌سازی بخش اصلی	162	64	2026-07-16	submitted	\N	\N	73817b30-c051-484d-8b20-9ba2113ed02e	2026-07-21 11:45:44.744086+00	2026-07-21 11:45:44.744086+00
582b48ec-cec0-4e4b-a7d4-cbfd51751f0f	71b000e1-ab7a-4db5-9c6c-47b9b63d4755	e139f154-0fb4-4ebf-b8b8-b6f5a29afeaf	رفع اشکالات و بازبینی	154	100	2026-07-16	submitted	\N	\N	d75a6d07-bbf8-4deb-bc16-b39fd1231b6f	2026-07-21 11:45:44.744086+00	2026-07-21 11:45:44.744086+00
582b48ec-cec0-4e4b-a7d4-cbfd51751f0f	71b000e1-ab7a-4db5-9c6c-47b9b63d4755	e139f154-0fb4-4ebf-b8b8-b6f5a29afeaf	پیاده‌سازی بخش اصلی	142	100	2026-07-16	approved	2b35422d-f7be-4135-8473-be7d9e83ec3d	\N	30e214b5-214c-49cf-a595-b7a4a8a7b74a	2026-07-21 11:45:44.744086+00	2026-07-21 11:45:44.744086+00
582b48ec-cec0-4e4b-a7d4-cbfd51751f0f	fecf3244-f8ca-4968-8781-b3cbd1ade40a	2b35422d-f7be-4135-8473-be7d9e83ec3d	مستندسازی و نهایی‌سازی	194	28	2026-07-02	approved	2b35422d-f7be-4135-8473-be7d9e83ec3d	\N	f450aee2-86c9-4511-aa1f-7c849ad4c912	2026-07-21 11:45:44.744086+00	2026-07-21 11:45:44.744086+00
582b48ec-cec0-4e4b-a7d4-cbfd51751f0f	fecf3244-f8ca-4968-8781-b3cbd1ade40a	2b35422d-f7be-4135-8473-be7d9e83ec3d	پیاده‌سازی بخش اصلی	77	50	2026-07-04	approved	2b35422d-f7be-4135-8473-be7d9e83ec3d	\N	87cb8df5-9a0f-45af-a57a-003cd4022951	2026-07-21 11:45:44.744086+00	2026-07-21 11:45:44.744086+00
582b48ec-cec0-4e4b-a7d4-cbfd51751f0f	fcd39443-d143-409c-b374-aac23c0efb5e	984c1d49-02d8-4d53-8ce0-f8709fafb190	پیاده‌سازی بخش اصلی	136	30	2026-07-08	approved	2b35422d-f7be-4135-8473-be7d9e83ec3d	\N	21bf44b5-8ea2-43b8-bb0e-24361750300c	2026-07-21 11:45:44.744086+00	2026-07-21 11:45:44.744086+00
582b48ec-cec0-4e4b-a7d4-cbfd51751f0f	fcd39443-d143-409c-b374-aac23c0efb5e	984c1d49-02d8-4d53-8ce0-f8709fafb190	تست و اطمینان از عملکرد صحیح	202	70	2026-07-09	approved	2b35422d-f7be-4135-8473-be7d9e83ec3d	\N	f7be6e4b-e8b2-4259-8f03-3f478084669f	2026-07-21 11:45:44.744086+00	2026-07-21 11:45:44.744086+00
582b48ec-cec0-4e4b-a7d4-cbfd51751f0f	fcd39443-d143-409c-b374-aac23c0efb5e	984c1d49-02d8-4d53-8ce0-f8709fafb190	پیاده‌سازی بخش اصلی	181	75	2026-07-16	approved	2b35422d-f7be-4135-8473-be7d9e83ec3d	\N	8f8c451b-c2b5-43a5-83f1-ce03066cbc0d	2026-07-21 11:45:44.744086+00	2026-07-21 11:45:44.744086+00
582b48ec-cec0-4e4b-a7d4-cbfd51751f0f	d6c23c76-21d9-4e9d-968c-6bfef099238c	984c1d49-02d8-4d53-8ce0-f8709fafb190	پیاده‌سازی بخش اصلی	176	38	2026-07-02	approved	2b35422d-f7be-4135-8473-be7d9e83ec3d	\N	bd807ada-79f5-4d43-86c2-958efed76890	2026-07-21 11:45:44.744086+00	2026-07-21 11:45:44.744086+00
582b48ec-cec0-4e4b-a7d4-cbfd51751f0f	d6c23c76-21d9-4e9d-968c-6bfef099238c	984c1d49-02d8-4d53-8ce0-f8709fafb190	مستندسازی و نهایی‌سازی	40	76	2026-07-04	approved	2b35422d-f7be-4135-8473-be7d9e83ec3d	\N	1e75f352-1784-453b-a86d-e846b0c5f465	2026-07-21 11:45:44.744086+00	2026-07-21 11:45:44.744086+00
582b48ec-cec0-4e4b-a7d4-cbfd51751f0f	d6c23c76-21d9-4e9d-968c-6bfef099238c	984c1d49-02d8-4d53-8ce0-f8709fafb190	رفع اشکالات و بازبینی	76	100	2026-07-06	approved	2b35422d-f7be-4135-8473-be7d9e83ec3d	\N	055c9e8f-64c0-4bb3-9004-d6638d58b11b	2026-07-21 11:45:44.744086+00	2026-07-21 11:45:44.744086+00
582b48ec-cec0-4e4b-a7d4-cbfd51751f0f	d6c23c76-21d9-4e9d-968c-6bfef099238c	984c1d49-02d8-4d53-8ce0-f8709fafb190	مستندسازی و نهایی‌سازی	193	80	2026-07-14	approved	2b35422d-f7be-4135-8473-be7d9e83ec3d	\N	95421944-03b7-498c-a0da-dffc2408b0e5	2026-07-21 11:45:44.744086+00	2026-07-21 11:45:44.744086+00
582b48ec-cec0-4e4b-a7d4-cbfd51751f0f	cd1dfff5-b50a-4f88-903c-d875b110058e	02d643cd-bc19-4efb-9d1a-c3e6d5675d66	پیاده‌سازی بخش اصلی	144	39	2026-07-16	approved	2b35422d-f7be-4135-8473-be7d9e83ec3d	\N	0bfd2142-d17b-4056-b307-416ee27bc75a	2026-07-21 11:45:44.744086+00	2026-07-21 11:45:44.744086+00
582b48ec-cec0-4e4b-a7d4-cbfd51751f0f	cd1dfff5-b50a-4f88-903c-d875b110058e	02d643cd-bc19-4efb-9d1a-c3e6d5675d66	تست و اطمینان از عملکرد صحیح	73	54	2026-07-16	approved	2b35422d-f7be-4135-8473-be7d9e83ec3d	\N	1b75f7e0-7b38-46ce-bea8-969fee71e5a7	2026-07-21 11:45:44.744086+00	2026-07-21 11:45:44.744086+00
582b48ec-cec0-4e4b-a7d4-cbfd51751f0f	cd1dfff5-b50a-4f88-903c-d875b110058e	02d643cd-bc19-4efb-9d1a-c3e6d5675d66	مستندسازی و نهایی‌سازی	66	100	2026-07-16	approved	2b35422d-f7be-4135-8473-be7d9e83ec3d	\N	9435a7fe-f46e-44e1-92bb-0a65d2f10e13	2026-07-21 11:45:44.744086+00	2026-07-21 11:45:44.744086+00
582b48ec-cec0-4e4b-a7d4-cbfd51751f0f	58c6297f-0f04-46c0-8d33-ce4e57d958ab	b4e312c2-6dc5-4616-97c7-1b9251f4ef87	رفع اشکالات و بازبینی	146	39	2026-07-16	approved	2b35422d-f7be-4135-8473-be7d9e83ec3d	\N	151897e0-1cc7-4d2e-815f-973109cf0541	2026-07-21 11:45:44.744086+00	2026-07-21 11:45:44.744086+00
582b48ec-cec0-4e4b-a7d4-cbfd51751f0f	58c6297f-0f04-46c0-8d33-ce4e57d958ab	b4e312c2-6dc5-4616-97c7-1b9251f4ef87	تست و اطمینان از عملکرد صحیح	63	46	2026-07-16	approved	2b35422d-f7be-4135-8473-be7d9e83ec3d	\N	8f8e80af-ac4b-40dc-87b2-923d0e19e05b	2026-07-21 11:45:44.744086+00	2026-07-21 11:45:44.744086+00
582b48ec-cec0-4e4b-a7d4-cbfd51751f0f	0c2b3fa0-2ccb-439b-86c7-d59e55325513	e139f154-0fb4-4ebf-b8b8-b6f5a29afeaf	مستندسازی و نهایی‌سازی	205	33	2026-07-11	approved	2b35422d-f7be-4135-8473-be7d9e83ec3d	\N	182540f6-a9e5-41fd-bd11-8fe5c5a2a7f5	2026-07-21 11:45:44.744086+00	2026-07-21 11:45:44.744086+00
582b48ec-cec0-4e4b-a7d4-cbfd51751f0f	480d75ee-0278-4670-97bb-44828ed6ea2e	b4e312c2-6dc5-4616-97c7-1b9251f4ef87	پیاده‌سازی بخش اصلی	151	39	2026-07-09	approved	2b35422d-f7be-4135-8473-be7d9e83ec3d	\N	8656d911-a2ec-48cf-813f-76c7e7dc8ad0	2026-07-21 11:45:44.744086+00	2026-07-21 11:45:44.744086+00
582b48ec-cec0-4e4b-a7d4-cbfd51751f0f	480d75ee-0278-4670-97bb-44828ed6ea2e	b4e312c2-6dc5-4616-97c7-1b9251f4ef87	مستندسازی و نهایی‌سازی	158	46	2026-07-10	approved	2b35422d-f7be-4135-8473-be7d9e83ec3d	\N	c2a1853e-5cdf-4f70-ae9f-365a29770349	2026-07-21 11:45:44.744086+00	2026-07-21 11:45:44.744086+00
582b48ec-cec0-4e4b-a7d4-cbfd51751f0f	87000aba-7321-447b-8ef5-1ce6d11d1bd0	2b35422d-f7be-4135-8473-be7d9e83ec3d	مستندسازی و نهایی‌سازی	168	20	2026-07-16	approved	2b35422d-f7be-4135-8473-be7d9e83ec3d	\N	f459854f-9a83-4f2b-be8d-e9ef123f4f78	2026-07-21 11:45:44.744086+00	2026-07-21 11:45:44.744086+00
582b48ec-cec0-4e4b-a7d4-cbfd51751f0f	dc3c948f-6beb-49ad-99da-6106a59e6e31	984c1d49-02d8-4d53-8ce0-f8709fafb190	پیشرفت اولیه و بررسی نیازمندی‌ها	208	36	2026-07-15	approved	2b35422d-f7be-4135-8473-be7d9e83ec3d	\N	2177bb38-74fe-4439-9a31-b5aabbe5d1f7	2026-07-21 11:45:44.744086+00	2026-07-21 11:45:44.744086+00
582b48ec-cec0-4e4b-a7d4-cbfd51751f0f	dc3c948f-6beb-49ad-99da-6106a59e6e31	984c1d49-02d8-4d53-8ce0-f8709fafb190	تست و اطمینان از عملکرد صحیح	232	64	2026-07-16	approved	2b35422d-f7be-4135-8473-be7d9e83ec3d	\N	25834238-e1ec-4658-9fff-6727cf6c0cc8	2026-07-21 11:45:44.744086+00	2026-07-21 11:45:44.744086+00
582b48ec-cec0-4e4b-a7d4-cbfd51751f0f	dc3c948f-6beb-49ad-99da-6106a59e6e31	984c1d49-02d8-4d53-8ce0-f8709fafb190	مستندسازی و نهایی‌سازی	55	99	2026-07-16	approved	2b35422d-f7be-4135-8473-be7d9e83ec3d	\N	8aee8622-6008-41b8-8ab4-1cb700944fc9	2026-07-21 11:45:44.744086+00	2026-07-21 11:45:44.744086+00
582b48ec-cec0-4e4b-a7d4-cbfd51751f0f	dc3c948f-6beb-49ad-99da-6106a59e6e31	984c1d49-02d8-4d53-8ce0-f8709fafb190	پیاده‌سازی بخش اصلی	51	100	2026-07-16	approved	2b35422d-f7be-4135-8473-be7d9e83ec3d	\N	28abd6dd-378f-4a17-ac61-be142609fcd2	2026-07-21 11:45:44.744086+00	2026-07-21 11:45:44.744086+00
582b48ec-cec0-4e4b-a7d4-cbfd51751f0f	02105178-a665-4acd-acf8-0a0047b52e9d	02d643cd-bc19-4efb-9d1a-c3e6d5675d66	پیشرفت اولیه و بررسی نیازمندی‌ها	177	36	2026-06-17	approved	2b35422d-f7be-4135-8473-be7d9e83ec3d	\N	75c78ce0-6671-4847-92ff-62886a7ffaa2	2026-07-21 11:45:44.744086+00	2026-07-21 11:45:44.744086+00
582b48ec-cec0-4e4b-a7d4-cbfd51751f0f	02105178-a665-4acd-acf8-0a0047b52e9d	02d643cd-bc19-4efb-9d1a-c3e6d5675d66	تست و اطمینان از عملکرد صحیح	197	52	2026-06-18	approved	2b35422d-f7be-4135-8473-be7d9e83ec3d	\N	c90a990f-339c-41f0-94a1-bc68ac34a2b4	2026-07-21 11:45:44.744086+00	2026-07-21 11:45:44.744086+00
582b48ec-cec0-4e4b-a7d4-cbfd51751f0f	02105178-a665-4acd-acf8-0a0047b52e9d	02d643cd-bc19-4efb-9d1a-c3e6d5675d66	پیشرفت اولیه و بررسی نیازمندی‌ها	69	99	2026-06-23	approved	2b35422d-f7be-4135-8473-be7d9e83ec3d	\N	e60ebbf2-b512-407f-ab26-ab736d919799	2026-07-21 11:45:44.744086+00	2026-07-21 11:45:44.744086+00
582b48ec-cec0-4e4b-a7d4-cbfd51751f0f	02105178-a665-4acd-acf8-0a0047b52e9d	02d643cd-bc19-4efb-9d1a-c3e6d5675d66	مستندسازی و نهایی‌سازی	138	100	2026-06-26	approved	2b35422d-f7be-4135-8473-be7d9e83ec3d	\N	262e20da-e23f-4be1-bf30-c4054f6641ab	2026-07-21 11:45:44.744086+00	2026-07-21 11:45:44.744086+00
582b48ec-cec0-4e4b-a7d4-cbfd51751f0f	8e9dcb75-9234-4e25-b7d0-703f353affe2	2b35422d-f7be-4135-8473-be7d9e83ec3d	تست و اطمینان از عملکرد صحیح	223	26	2026-06-23	approved	2b35422d-f7be-4135-8473-be7d9e83ec3d	\N	0ffaf091-f788-4c79-aea5-b74aa90dce32	2026-07-21 11:45:44.744086+00	2026-07-21 11:45:44.744086+00
582b48ec-cec0-4e4b-a7d4-cbfd51751f0f	8e9dcb75-9234-4e25-b7d0-703f353affe2	2b35422d-f7be-4135-8473-be7d9e83ec3d	مستندسازی و نهایی‌سازی	230	74	2026-06-27	approved	2b35422d-f7be-4135-8473-be7d9e83ec3d	\N	1dfd088e-a406-4db2-af9b-db7506e83cc1	2026-07-21 11:45:44.744086+00	2026-07-21 11:45:44.744086+00
582b48ec-cec0-4e4b-a7d4-cbfd51751f0f	8e9dcb75-9234-4e25-b7d0-703f353affe2	2b35422d-f7be-4135-8473-be7d9e83ec3d	پیاده‌سازی بخش اصلی	124	100	2026-07-01	approved	2b35422d-f7be-4135-8473-be7d9e83ec3d	\N	91cbbd73-0ec2-4f1a-bcff-df66a57271d6	2026-07-21 11:45:44.744086+00	2026-07-21 11:45:44.744086+00
582b48ec-cec0-4e4b-a7d4-cbfd51751f0f	3aa6674e-7012-484b-8028-7fe78796132d	77b8df83-b4f0-4924-9ef8-25216fe271af	رفع اشکالات و بازبینی	177	31	2026-07-16	approved	2b35422d-f7be-4135-8473-be7d9e83ec3d	\N	edaad815-7a32-4d7e-824f-3006cea3901f	2026-07-21 11:45:44.744086+00	2026-07-21 11:45:44.744086+00
582b48ec-cec0-4e4b-a7d4-cbfd51751f0f	3aa6674e-7012-484b-8028-7fe78796132d	77b8df83-b4f0-4924-9ef8-25216fe271af	پیاده‌سازی بخش اصلی	198	46	2026-07-16	approved	2b35422d-f7be-4135-8473-be7d9e83ec3d	\N	13333d55-1baf-4fa4-8579-a14f92d1307a	2026-07-21 11:45:44.744086+00	2026-07-21 11:45:44.744086+00
582b48ec-cec0-4e4b-a7d4-cbfd51751f0f	3aa6674e-7012-484b-8028-7fe78796132d	77b8df83-b4f0-4924-9ef8-25216fe271af	تست و اطمینان از عملکرد صحیح	230	75	2026-07-16	approved	2b35422d-f7be-4135-8473-be7d9e83ec3d	\N	f7ff3d66-eb4d-4489-bd44-6abb18de54e4	2026-07-21 11:45:44.744086+00	2026-07-21 11:45:44.744086+00
582b48ec-cec0-4e4b-a7d4-cbfd51751f0f	3aa6674e-7012-484b-8028-7fe78796132d	77b8df83-b4f0-4924-9ef8-25216fe271af	پیاده‌سازی بخش اصلی	160	100	2026-07-16	approved	2b35422d-f7be-4135-8473-be7d9e83ec3d	\N	f046ce70-2392-41e6-a57f-329c5e6a957f	2026-07-21 11:45:44.744086+00	2026-07-21 11:45:44.744086+00
582b48ec-cec0-4e4b-a7d4-cbfd51751f0f	f5b8bde6-21ae-40c7-a1d0-84c454656220	e139f154-0fb4-4ebf-b8b8-b6f5a29afeaf	پیاده‌سازی بخش اصلی	129	40	2026-07-12	approved	2b35422d-f7be-4135-8473-be7d9e83ec3d	\N	e408c14a-373a-41d0-830a-5babf25d35c1	2026-07-21 11:45:44.744086+00	2026-07-21 11:45:44.744086+00
582b48ec-cec0-4e4b-a7d4-cbfd51751f0f	f5b8bde6-21ae-40c7-a1d0-84c454656220	e139f154-0fb4-4ebf-b8b8-b6f5a29afeaf	پیشرفت اولیه و بررسی نیازمندی‌ها	240	48	2026-07-13	approved	2b35422d-f7be-4135-8473-be7d9e83ec3d	\N	d0a48d18-1b6c-436c-9089-d80248937f35	2026-07-21 11:45:44.744086+00	2026-07-21 11:45:44.744086+00
582b48ec-cec0-4e4b-a7d4-cbfd51751f0f	f5b8bde6-21ae-40c7-a1d0-84c454656220	e139f154-0fb4-4ebf-b8b8-b6f5a29afeaf	مستندسازی و نهایی‌سازی	141	66	2026-07-16	approved	2b35422d-f7be-4135-8473-be7d9e83ec3d	\N	05ef1d7f-9b67-4b40-ad94-2c592757a7cd	2026-07-21 11:45:44.744086+00	2026-07-21 11:45:44.744086+00
582b48ec-cec0-4e4b-a7d4-cbfd51751f0f	cd5f045a-0b31-462b-8632-67ce6dea4060	c3bd6208-d89c-402a-90fe-6f00c4219566	پیاده‌سازی بخش اصلی	124	22	2026-07-16	approved	2b35422d-f7be-4135-8473-be7d9e83ec3d	\N	cba7591a-80c1-40ef-ab33-4100ea548906	2026-07-21 11:45:44.744086+00	2026-07-21 11:45:44.744086+00
582b48ec-cec0-4e4b-a7d4-cbfd51751f0f	25fa6843-207b-4904-8936-481bd911c069	984c1d49-02d8-4d53-8ce0-f8709fafb190	تست و اطمینان از عملکرد صحیح	187	40	2026-07-08	approved	2b35422d-f7be-4135-8473-be7d9e83ec3d	\N	6e9342eb-bc22-4cbb-a70e-c173ea5f7a02	2026-07-21 11:45:44.744086+00	2026-07-21 11:45:44.744086+00
582b48ec-cec0-4e4b-a7d4-cbfd51751f0f	71fe240f-d4ef-4b2e-bd53-33084f0230be	77b8df83-b4f0-4924-9ef8-25216fe271af	پیاده‌سازی بخش اصلی	193	35	2026-07-16	submitted	\N	\N	8132bb39-24e3-4675-9df3-f7cd5d89c188	2026-07-21 11:45:44.744086+00	2026-07-21 11:45:44.744086+00
582b48ec-cec0-4e4b-a7d4-cbfd51751f0f	71fe240f-d4ef-4b2e-bd53-33084f0230be	77b8df83-b4f0-4924-9ef8-25216fe271af	مستندسازی و نهایی‌سازی	103	52	2026-07-16	approved	2b35422d-f7be-4135-8473-be7d9e83ec3d	\N	2032ead4-7954-424d-8fe1-97056d34b7ee	2026-07-21 11:45:44.744086+00	2026-07-21 11:45:44.744086+00
582b48ec-cec0-4e4b-a7d4-cbfd51751f0f	71fe240f-d4ef-4b2e-bd53-33084f0230be	77b8df83-b4f0-4924-9ef8-25216fe271af	مستندسازی و نهایی‌سازی	162	81	2026-07-16	submitted	\N	\N	ad39c8ca-97fb-49f2-9ec1-e0ca17c34f15	2026-07-21 11:45:44.744086+00	2026-07-21 11:45:44.744086+00
582b48ec-cec0-4e4b-a7d4-cbfd51751f0f	370a6261-eb59-4386-a1ab-70ba76f36cec	02d643cd-bc19-4efb-9d1a-c3e6d5675d66	رفع اشکالات و بازبینی	91	40	2026-07-16	approved	2b35422d-f7be-4135-8473-be7d9e83ec3d	\N	3b452364-5db6-4f41-ba45-ee61a924f5bd	2026-07-21 11:45:44.744086+00	2026-07-21 11:45:44.744086+00
582b48ec-cec0-4e4b-a7d4-cbfd51751f0f	370a6261-eb59-4386-a1ab-70ba76f36cec	02d643cd-bc19-4efb-9d1a-c3e6d5675d66	پیاده‌سازی بخش اصلی	52	56	2026-07-16	approved	2b35422d-f7be-4135-8473-be7d9e83ec3d	\N	e4712cba-5209-4a2c-a5d0-dea286c3e90d	2026-07-21 11:45:44.744086+00	2026-07-21 11:45:44.744086+00
582b48ec-cec0-4e4b-a7d4-cbfd51751f0f	12743a7c-a5e0-46da-90c3-8c5dc58ac120	77b8df83-b4f0-4924-9ef8-25216fe271af	تست و اطمینان از عملکرد صحیح	180	26	2026-07-02	approved	2b35422d-f7be-4135-8473-be7d9e83ec3d	\N	c1482159-0f63-4d00-89dd-2893f535c13f	2026-07-21 11:45:44.744086+00	2026-07-21 11:45:44.744086+00
582b48ec-cec0-4e4b-a7d4-cbfd51751f0f	12743a7c-a5e0-46da-90c3-8c5dc58ac120	77b8df83-b4f0-4924-9ef8-25216fe271af	پیشرفت اولیه و بررسی نیازمندی‌ها	53	74	2026-07-03	submitted	\N	\N	42800d98-435a-4722-b5c9-2dd1577b018f	2026-07-21 11:45:44.744086+00	2026-07-21 11:45:44.744086+00
582b48ec-cec0-4e4b-a7d4-cbfd51751f0f	12743a7c-a5e0-46da-90c3-8c5dc58ac120	77b8df83-b4f0-4924-9ef8-25216fe271af	مستندسازی و نهایی‌سازی	179	93	2026-07-08	submitted	\N	\N	fc8aebcc-7d8a-40a3-b314-558e844110a6	2026-07-21 11:45:44.744086+00	2026-07-21 11:45:44.744086+00
582b48ec-cec0-4e4b-a7d4-cbfd51751f0f	12743a7c-a5e0-46da-90c3-8c5dc58ac120	77b8df83-b4f0-4924-9ef8-25216fe271af	رفع اشکالات و بازبینی	87	100	2026-07-11	submitted	\N	\N	37062fb8-a589-41ff-9f22-ee9a3c5924bb	2026-07-21 11:45:44.744086+00	2026-07-21 11:45:44.744086+00
582b48ec-cec0-4e4b-a7d4-cbfd51751f0f	e3e29e20-ec9f-432e-b227-f6e81d3f5122	02d643cd-bc19-4efb-9d1a-c3e6d5675d66	مستندسازی و نهایی‌سازی	31	28	2026-07-09	submitted	\N	\N	b47a2c42-7368-4a1a-898c-e39c5521b7d9	2026-07-21 11:45:44.744086+00	2026-07-21 11:45:44.744086+00
582b48ec-cec0-4e4b-a7d4-cbfd51751f0f	e3e29e20-ec9f-432e-b227-f6e81d3f5122	02d643cd-bc19-4efb-9d1a-c3e6d5675d66	پیشرفت اولیه و بررسی نیازمندی‌ها	173	44	2026-07-11	approved	2b35422d-f7be-4135-8473-be7d9e83ec3d	\N	93f8ed7b-aff2-4b27-be9e-25431c8bfbc1	2026-07-21 11:45:44.744086+00	2026-07-21 11:45:44.744086+00
582b48ec-cec0-4e4b-a7d4-cbfd51751f0f	a7877bf3-3773-47a7-b309-0edb1f13b3c1	77b8df83-b4f0-4924-9ef8-25216fe271af	پیشرفت اولیه و بررسی نیازمندی‌ها	235	36	2026-07-16	approved	2b35422d-f7be-4135-8473-be7d9e83ec3d	\N	71a37df1-580b-42b2-9fcb-28bba9d265a8	2026-07-21 11:45:44.744086+00	2026-07-21 11:45:44.744086+00
582b48ec-cec0-4e4b-a7d4-cbfd51751f0f	a7877bf3-3773-47a7-b309-0edb1f13b3c1	77b8df83-b4f0-4924-9ef8-25216fe271af	مستندسازی و نهایی‌سازی	238	76	2026-07-16	approved	2b35422d-f7be-4135-8473-be7d9e83ec3d	\N	c35ed129-87e6-4fd6-b1a5-f4dcf60b76ab	2026-07-21 11:45:44.744086+00	2026-07-21 11:45:44.744086+00
582b48ec-cec0-4e4b-a7d4-cbfd51751f0f	a7877bf3-3773-47a7-b309-0edb1f13b3c1	77b8df83-b4f0-4924-9ef8-25216fe271af	تست و اطمینان از عملکرد صحیح	126	100	2026-07-16	approved	2b35422d-f7be-4135-8473-be7d9e83ec3d	\N	b1c58550-1fb3-4ea0-9c08-3336356a13a9	2026-07-21 11:45:44.744086+00	2026-07-21 11:45:44.744086+00
582b48ec-cec0-4e4b-a7d4-cbfd51751f0f	0e7d6325-7217-4ed8-9559-7a66dd8c53c1	77b8df83-b4f0-4924-9ef8-25216fe271af	تست و اطمینان از عملکرد صحیح	204	34	2026-07-15	submitted	\N	\N	557bae0f-5aa4-48c6-aeef-620694d55a15	2026-07-21 11:45:44.744086+00	2026-07-21 11:45:44.744086+00
582b48ec-cec0-4e4b-a7d4-cbfd51751f0f	0e7d6325-7217-4ed8-9559-7a66dd8c53c1	77b8df83-b4f0-4924-9ef8-25216fe271af	رفع اشکالات و بازبینی	47	64	2026-07-16	approved	2b35422d-f7be-4135-8473-be7d9e83ec3d	\N	c1fee737-eaf0-4298-80a1-03421c593feb	2026-07-21 11:45:44.744086+00	2026-07-21 11:45:44.744086+00
582b48ec-cec0-4e4b-a7d4-cbfd51751f0f	0e7d6325-7217-4ed8-9559-7a66dd8c53c1	77b8df83-b4f0-4924-9ef8-25216fe271af	پیاده‌سازی بخش اصلی	234	90	2026-07-16	approved	2b35422d-f7be-4135-8473-be7d9e83ec3d	\N	4b3d50df-4dcc-49e7-9b34-888218f8cfeb	2026-07-21 11:45:44.744086+00	2026-07-21 11:45:44.744086+00
582b48ec-cec0-4e4b-a7d4-cbfd51751f0f	0e7d6325-7217-4ed8-9559-7a66dd8c53c1	77b8df83-b4f0-4924-9ef8-25216fe271af	مستندسازی و نهایی‌سازی	167	80	2026-07-16	submitted	\N	\N	413874b6-90cd-43f6-ab19-c7e5c3977d2f	2026-07-21 11:45:44.744086+00	2026-07-21 11:45:44.744086+00
582b48ec-cec0-4e4b-a7d4-cbfd51751f0f	71a062f0-f06a-4b2c-af58-996699107438	e139f154-0fb4-4ebf-b8b8-b6f5a29afeaf	رفع اشکالات و بازبینی	53	32	2026-07-10	approved	2b35422d-f7be-4135-8473-be7d9e83ec3d	\N	c09cc6a5-7f8f-472e-b9e0-511d75768225	2026-07-21 11:45:44.744086+00	2026-07-21 11:45:44.744086+00
582b48ec-cec0-4e4b-a7d4-cbfd51751f0f	71a062f0-f06a-4b2c-af58-996699107438	e139f154-0fb4-4ebf-b8b8-b6f5a29afeaf	پیشرفت اولیه و بررسی نیازمندی‌ها	171	50	2026-07-13	approved	2b35422d-f7be-4135-8473-be7d9e83ec3d	\N	5aaed1ea-c6c0-42ba-88d4-e72c3bb99e9f	2026-07-21 11:45:44.744086+00	2026-07-21 11:45:44.744086+00
582b48ec-cec0-4e4b-a7d4-cbfd51751f0f	71a062f0-f06a-4b2c-af58-996699107438	e139f154-0fb4-4ebf-b8b8-b6f5a29afeaf	رفع اشکالات و بازبینی	120	78	2026-07-16	approved	2b35422d-f7be-4135-8473-be7d9e83ec3d	\N	dfc829b3-fdb2-4976-acad-162498c460e5	2026-07-21 11:45:44.744086+00	2026-07-21 11:45:44.744086+00
582b48ec-cec0-4e4b-a7d4-cbfd51751f0f	9cb43a97-5909-4e90-acd7-3c199137c2aa	02d643cd-bc19-4efb-9d1a-c3e6d5675d66	پیاده‌سازی بخش اصلی	157	26	2026-07-16	approved	2b35422d-f7be-4135-8473-be7d9e83ec3d	\N	3c3a0559-aeb1-43f7-815b-f2489a0410b7	2026-07-21 11:45:44.744086+00	2026-07-21 11:45:44.744086+00
582b48ec-cec0-4e4b-a7d4-cbfd51751f0f	9cb43a97-5909-4e90-acd7-3c199137c2aa	02d643cd-bc19-4efb-9d1a-c3e6d5675d66	پیاده‌سازی بخش اصلی	97	52	2026-07-16	approved	2b35422d-f7be-4135-8473-be7d9e83ec3d	\N	262ae143-8119-48be-88fd-3b4644c2271a	2026-07-21 11:45:44.744086+00	2026-07-21 11:45:44.744086+00
582b48ec-cec0-4e4b-a7d4-cbfd51751f0f	9cb43a97-5909-4e90-acd7-3c199137c2aa	02d643cd-bc19-4efb-9d1a-c3e6d5675d66	پیاده‌سازی بخش اصلی	93	100	2026-07-16	approved	2b35422d-f7be-4135-8473-be7d9e83ec3d	\N	f38e0362-0b5b-48ab-8ee8-22e53421064b	2026-07-21 11:45:44.744086+00	2026-07-21 11:45:44.744086+00
582b48ec-cec0-4e4b-a7d4-cbfd51751f0f	48a69577-600e-4d40-b27a-9528e5b23127	e139f154-0fb4-4ebf-b8b8-b6f5a29afeaf	پیشرفت اولیه و بررسی نیازمندی‌ها	60	22	2026-07-16	approved	2b35422d-f7be-4135-8473-be7d9e83ec3d	\N	6332a2e1-6f2b-4952-8ad2-cc1680f8d034	2026-07-21 11:45:44.744086+00	2026-07-21 11:45:44.744086+00
582b48ec-cec0-4e4b-a7d4-cbfd51751f0f	48a69577-600e-4d40-b27a-9528e5b23127	e139f154-0fb4-4ebf-b8b8-b6f5a29afeaf	مستندسازی و نهایی‌سازی	31	74	2026-07-16	approved	2b35422d-f7be-4135-8473-be7d9e83ec3d	\N	c03c3f6d-b054-49ed-aacf-64b36d4e3026	2026-07-21 11:45:44.744086+00	2026-07-21 11:45:44.744086+00
582b48ec-cec0-4e4b-a7d4-cbfd51751f0f	48a69577-600e-4d40-b27a-9528e5b23127	e139f154-0fb4-4ebf-b8b8-b6f5a29afeaf	تست و اطمینان از عملکرد صحیح	125	100	2026-07-16	approved	2b35422d-f7be-4135-8473-be7d9e83ec3d	\N	0fc4a586-5f0a-4481-81f3-b3893b963bce	2026-07-21 11:45:44.744086+00	2026-07-21 11:45:44.744086+00
582b48ec-cec0-4e4b-a7d4-cbfd51751f0f	a0fa56a9-c059-4f20-b87a-240a5721bda5	c3bd6208-d89c-402a-90fe-6f00c4219566	مستندسازی و نهایی‌سازی	100	35	2026-07-16	approved	2b35422d-f7be-4135-8473-be7d9e83ec3d	\N	69c920ac-5e81-4911-a022-f7e3afd579ca	2026-07-21 11:45:44.744086+00	2026-07-21 11:45:44.744086+00
582b48ec-cec0-4e4b-a7d4-cbfd51751f0f	a0fa56a9-c059-4f20-b87a-240a5721bda5	c3bd6208-d89c-402a-90fe-6f00c4219566	مستندسازی و نهایی‌سازی	101	64	2026-07-16	approved	2b35422d-f7be-4135-8473-be7d9e83ec3d	\N	6a21f8ab-aece-4a6f-8380-2d44cf71ec9d	2026-07-21 11:45:44.744086+00	2026-07-21 11:45:44.744086+00
582b48ec-cec0-4e4b-a7d4-cbfd51751f0f	a0fa56a9-c059-4f20-b87a-240a5721bda5	c3bd6208-d89c-402a-90fe-6f00c4219566	مستندسازی و نهایی‌سازی	62	63	2026-07-16	approved	2b35422d-f7be-4135-8473-be7d9e83ec3d	\N	20ec130e-85ec-4274-8ca9-84af683e827d	2026-07-21 11:45:44.744086+00	2026-07-21 11:45:44.744086+00
582b48ec-cec0-4e4b-a7d4-cbfd51751f0f	e04581c6-ce00-4357-b7c0-588e3eccd5ef	77b8df83-b4f0-4924-9ef8-25216fe271af	پیشرفت اولیه و بررسی نیازمندی‌ها	158	31	2026-07-16	submitted	\N	\N	236790f3-db64-499b-98ef-7f768c7a4fd7	2026-07-21 11:45:44.744086+00	2026-07-21 11:45:44.744086+00
582b48ec-cec0-4e4b-a7d4-cbfd51751f0f	e04581c6-ce00-4357-b7c0-588e3eccd5ef	77b8df83-b4f0-4924-9ef8-25216fe271af	پیاده‌سازی بخش اصلی	147	46	2026-07-16	submitted	\N	\N	a62315bc-cd3b-4b9b-a87e-435302355d95	2026-07-21 11:45:44.744086+00	2026-07-21 11:45:44.744086+00
582b48ec-cec0-4e4b-a7d4-cbfd51751f0f	e04581c6-ce00-4357-b7c0-588e3eccd5ef	77b8df83-b4f0-4924-9ef8-25216fe271af	پیشرفت اولیه و بررسی نیازمندی‌ها	33	78	2026-07-16	approved	2b35422d-f7be-4135-8473-be7d9e83ec3d	\N	348c0570-cef5-4279-9a3f-1415d3aa09ef	2026-07-21 11:45:44.744086+00	2026-07-21 11:45:44.744086+00
582b48ec-cec0-4e4b-a7d4-cbfd51751f0f	e04581c6-ce00-4357-b7c0-588e3eccd5ef	77b8df83-b4f0-4924-9ef8-25216fe271af	رفع اشکالات و بازبینی	122	100	2026-07-16	approved	2b35422d-f7be-4135-8473-be7d9e83ec3d	\N	7b51cfb0-66a6-4c8a-9b4c-7d255fe3a6f3	2026-07-21 11:45:44.744086+00	2026-07-21 11:45:44.744086+00
582b48ec-cec0-4e4b-a7d4-cbfd51751f0f	a8204544-e055-4c33-958b-097626790241	77b8df83-b4f0-4924-9ef8-25216fe271af	پیاده‌سازی بخش اصلی	98	35	2026-07-01	approved	2b35422d-f7be-4135-8473-be7d9e83ec3d	\N	726720d7-e0bc-4185-934b-3e73beb9aeb5	2026-07-21 11:45:44.744086+00	2026-07-21 11:45:44.744086+00
582b48ec-cec0-4e4b-a7d4-cbfd51751f0f	a8204544-e055-4c33-958b-097626790241	77b8df83-b4f0-4924-9ef8-25216fe271af	تست و اطمینان از عملکرد صحیح	138	52	2026-07-04	approved	2b35422d-f7be-4135-8473-be7d9e83ec3d	\N	f51dfef5-787d-4e50-856f-4ba6f8a7b004	2026-07-21 11:45:44.744086+00	2026-07-21 11:45:44.744086+00
582b48ec-cec0-4e4b-a7d4-cbfd51751f0f	a8204544-e055-4c33-958b-097626790241	77b8df83-b4f0-4924-9ef8-25216fe271af	رفع اشکالات و بازبینی	123	96	2026-07-09	submitted	\N	\N	7f6f4aa0-8ef8-478b-949c-0567c60c890f	2026-07-21 11:45:44.744086+00	2026-07-21 11:45:44.744086+00
582b48ec-cec0-4e4b-a7d4-cbfd51751f0f	63136f49-5d2f-4d66-819f-dd7f9bf24e98	e139f154-0fb4-4ebf-b8b8-b6f5a29afeaf	پیاده‌سازی بخش اصلی	177	27	2026-07-11	approved	2b35422d-f7be-4135-8473-be7d9e83ec3d	\N	7692ab54-3b72-4546-ba37-ef8d2ce5f97f	2026-07-21 11:45:44.744086+00	2026-07-21 11:45:44.744086+00
582b48ec-cec0-4e4b-a7d4-cbfd51751f0f	63136f49-5d2f-4d66-819f-dd7f9bf24e98	e139f154-0fb4-4ebf-b8b8-b6f5a29afeaf	پیاده‌سازی بخش اصلی	172	66	2026-07-12	submitted	\N	\N	18989516-382f-44e6-b35a-da80f9091dc0	2026-07-21 11:45:44.744086+00	2026-07-21 11:45:44.744086+00
582b48ec-cec0-4e4b-a7d4-cbfd51751f0f	63136f49-5d2f-4d66-819f-dd7f9bf24e98	e139f154-0fb4-4ebf-b8b8-b6f5a29afeaf	پیاده‌سازی بخش اصلی	151	60	2026-07-16	approved	2b35422d-f7be-4135-8473-be7d9e83ec3d	\N	f690ef53-875d-4220-af24-518da14ab6c5	2026-07-21 11:45:44.744086+00	2026-07-21 11:45:44.744086+00
582b48ec-cec0-4e4b-a7d4-cbfd51751f0f	c621aa56-fbf7-4f0d-a21d-9b2acc90d395	e139f154-0fb4-4ebf-b8b8-b6f5a29afeaf	تست و اطمینان از عملکرد صحیح	64	40	2026-07-11	approved	2b35422d-f7be-4135-8473-be7d9e83ec3d	\N	10a7b825-9db3-43ab-a848-efc69552c238	2026-07-21 11:45:44.744086+00	2026-07-21 11:45:44.744086+00
582b48ec-cec0-4e4b-a7d4-cbfd51751f0f	c621aa56-fbf7-4f0d-a21d-9b2acc90d395	e139f154-0fb4-4ebf-b8b8-b6f5a29afeaf	تست و اطمینان از عملکرد صحیح	106	56	2026-07-14	approved	2b35422d-f7be-4135-8473-be7d9e83ec3d	\N	b57f692a-6333-4abd-9ed7-0d183e0ff3a0	2026-07-21 11:45:44.744086+00	2026-07-21 11:45:44.744086+00
\.


--
-- Name: accounts accounts_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.accounts
    ADD CONSTRAINT accounts_pkey PRIMARY KEY (id);


--
-- Name: alembic_version alembic_version_pkc; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.alembic_version
    ADD CONSTRAINT alembic_version_pkc PRIMARY KEY (version_num);


--
-- Name: attachments attachments_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.attachments
    ADD CONSTRAINT attachments_pkey PRIMARY KEY (id);


--
-- Name: audit_logs audit_logs_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.audit_logs
    ADD CONSTRAINT audit_logs_pkey PRIMARY KEY (id);


--
-- Name: calendar_events calendar_events_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.calendar_events
    ADD CONSTRAINT calendar_events_pkey PRIMARY KEY (id);


--
-- Name: comments comments_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.comments
    ADD CONSTRAINT comments_pkey PRIMARY KEY (id);


--
-- Name: department_memberships department_memberships_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.department_memberships
    ADD CONSTRAINT department_memberships_pkey PRIMARY KEY (id);


--
-- Name: departments departments_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.departments
    ADD CONSTRAINT departments_pkey PRIMARY KEY (id);


--
-- Name: export_jobs export_jobs_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.export_jobs
    ADD CONSTRAINT export_jobs_pkey PRIMARY KEY (id);


--
-- Name: finance_categories finance_categories_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.finance_categories
    ADD CONSTRAINT finance_categories_pkey PRIMARY KEY (id);


--
-- Name: finance_entries finance_entries_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.finance_entries
    ADD CONSTRAINT finance_entries_pkey PRIMARY KEY (id);


--
-- Name: leave_requests leave_requests_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.leave_requests
    ADD CONSTRAINT leave_requests_pkey PRIMARY KEY (id);


--
-- Name: notifications notifications_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.notifications
    ADD CONSTRAINT notifications_pkey PRIMARY KEY (id);


--
-- Name: organizations organizations_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.organizations
    ADD CONSTRAINT organizations_pkey PRIMARY KEY (id);


--
-- Name: otp_codes otp_codes_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.otp_codes
    ADD CONSTRAINT otp_codes_pkey PRIMARY KEY (id);


--
-- Name: payments payments_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.payments
    ADD CONSTRAINT payments_pkey PRIMARY KEY (id);


--
-- Name: project_members project_members_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.project_members
    ADD CONSTRAINT project_members_pkey PRIMARY KEY (id);


--
-- Name: projects projects_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.projects
    ADD CONSTRAINT projects_pkey PRIMARY KEY (id);


--
-- Name: task_activity_logs task_activity_logs_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.task_activity_logs
    ADD CONSTRAINT task_activity_logs_pkey PRIMARY KEY (id);


--
-- Name: task_dependencies task_dependencies_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.task_dependencies
    ADD CONSTRAINT task_dependencies_pkey PRIMARY KEY (id);


--
-- Name: tasks tasks_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.tasks
    ADD CONSTRAINT tasks_pkey PRIMARY KEY (id);


--
-- Name: department_memberships uq_department_membership_user_department; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.department_memberships
    ADD CONSTRAINT uq_department_membership_user_department UNIQUE (user_id, department_id);


--
-- Name: finance_categories uq_finance_category_org_type_name; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.finance_categories
    ADD CONSTRAINT uq_finance_category_org_type_name UNIQUE (organization_id, entry_type, name);


--
-- Name: users uq_user_account_organization; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.users
    ADD CONSTRAINT uq_user_account_organization UNIQUE (account_id, organization_id);


--
-- Name: users users_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.users
    ADD CONSTRAINT users_pkey PRIMARY KEY (id);


--
-- Name: worklogs worklogs_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.worklogs
    ADD CONSTRAINT worklogs_pkey PRIMARY KEY (id);


--
-- Name: ix_accounts_phone_number; Type: INDEX; Schema: public; Owner: -
--

CREATE UNIQUE INDEX ix_accounts_phone_number ON public.accounts USING btree (phone_number);


--
-- Name: ix_attachments_organization_id; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX ix_attachments_organization_id ON public.attachments USING btree (organization_id);


--
-- Name: ix_attachments_task_id; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX ix_attachments_task_id ON public.attachments USING btree (task_id);


--
-- Name: ix_audit_logs_organization_id; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX ix_audit_logs_organization_id ON public.audit_logs USING btree (organization_id);


--
-- Name: ix_calendar_events_organization_id; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX ix_calendar_events_organization_id ON public.calendar_events USING btree (organization_id);


--
-- Name: ix_calendar_events_project_id; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX ix_calendar_events_project_id ON public.calendar_events USING btree (project_id);


--
-- Name: ix_calendar_events_start_at; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX ix_calendar_events_start_at ON public.calendar_events USING btree (start_at);


--
-- Name: ix_calendar_events_user_id; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX ix_calendar_events_user_id ON public.calendar_events USING btree (user_id);


--
-- Name: ix_comments_organization_id; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX ix_comments_organization_id ON public.comments USING btree (organization_id);


--
-- Name: ix_comments_task_id; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX ix_comments_task_id ON public.comments USING btree (task_id);


--
-- Name: ix_department_memberships_department_id; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX ix_department_memberships_department_id ON public.department_memberships USING btree (department_id);


--
-- Name: ix_department_memberships_organization_id; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX ix_department_memberships_organization_id ON public.department_memberships USING btree (organization_id);


--
-- Name: ix_department_memberships_user_id; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX ix_department_memberships_user_id ON public.department_memberships USING btree (user_id);


--
-- Name: ix_departments_organization_id; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX ix_departments_organization_id ON public.departments USING btree (organization_id);


--
-- Name: ix_export_jobs_organization_id; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX ix_export_jobs_organization_id ON public.export_jobs USING btree (organization_id);


--
-- Name: ix_finance_categories_entry_type; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX ix_finance_categories_entry_type ON public.finance_categories USING btree (entry_type);


--
-- Name: ix_finance_categories_organization_id; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX ix_finance_categories_organization_id ON public.finance_categories USING btree (organization_id);


--
-- Name: ix_finance_entries_category_id; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX ix_finance_entries_category_id ON public.finance_entries USING btree (category_id);


--
-- Name: ix_finance_entries_document_date; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX ix_finance_entries_document_date ON public.finance_entries USING btree (document_date);


--
-- Name: ix_finance_entries_entry_type; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX ix_finance_entries_entry_type ON public.finance_entries USING btree (entry_type);


--
-- Name: ix_finance_entries_organization_id; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX ix_finance_entries_organization_id ON public.finance_entries USING btree (organization_id);


--
-- Name: ix_finance_entries_project_id; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX ix_finance_entries_project_id ON public.finance_entries USING btree (project_id);


--
-- Name: ix_leave_requests_organization_id; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX ix_leave_requests_organization_id ON public.leave_requests USING btree (organization_id);


--
-- Name: ix_leave_requests_user_id; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX ix_leave_requests_user_id ON public.leave_requests USING btree (user_id);


--
-- Name: ix_notifications_organization_id; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX ix_notifications_organization_id ON public.notifications USING btree (organization_id);


--
-- Name: ix_notifications_user_id; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX ix_notifications_user_id ON public.notifications USING btree (user_id);


--
-- Name: ix_organizations_slug; Type: INDEX; Schema: public; Owner: -
--

CREATE UNIQUE INDEX ix_organizations_slug ON public.organizations USING btree (slug);


--
-- Name: ix_otp_codes_phone_number; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX ix_otp_codes_phone_number ON public.otp_codes USING btree (phone_number);


--
-- Name: ix_payments_organization_id; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX ix_payments_organization_id ON public.payments USING btree (organization_id);


--
-- Name: ix_payments_project_id; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX ix_payments_project_id ON public.payments USING btree (project_id);


--
-- Name: ix_project_members_project_id; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX ix_project_members_project_id ON public.project_members USING btree (project_id);


--
-- Name: ix_project_members_user_id; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX ix_project_members_user_id ON public.project_members USING btree (user_id);


--
-- Name: ix_projects_organization_id; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX ix_projects_organization_id ON public.projects USING btree (organization_id);


--
-- Name: ix_task_activity_logs_organization_id; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX ix_task_activity_logs_organization_id ON public.task_activity_logs USING btree (organization_id);


--
-- Name: ix_task_activity_logs_task_id; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX ix_task_activity_logs_task_id ON public.task_activity_logs USING btree (task_id);


--
-- Name: ix_task_dependencies_depends_on_task_id; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX ix_task_dependencies_depends_on_task_id ON public.task_dependencies USING btree (depends_on_task_id);


--
-- Name: ix_task_dependencies_task_id; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX ix_task_dependencies_task_id ON public.task_dependencies USING btree (task_id);


--
-- Name: ix_tasks_assignee_id; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX ix_tasks_assignee_id ON public.tasks USING btree (assignee_id);


--
-- Name: ix_tasks_organization_id; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX ix_tasks_organization_id ON public.tasks USING btree (organization_id);


--
-- Name: ix_tasks_parent_task_id; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX ix_tasks_parent_task_id ON public.tasks USING btree (parent_task_id);


--
-- Name: ix_tasks_project_id; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX ix_tasks_project_id ON public.tasks USING btree (project_id);


--
-- Name: ix_users_account_id; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX ix_users_account_id ON public.users USING btree (account_id);


--
-- Name: ix_users_organization_id; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX ix_users_organization_id ON public.users USING btree (organization_id);


--
-- Name: ix_worklogs_organization_id; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX ix_worklogs_organization_id ON public.worklogs USING btree (organization_id);


--
-- Name: ix_worklogs_task_id; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX ix_worklogs_task_id ON public.worklogs USING btree (task_id);


--
-- Name: ix_worklogs_user_id; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX ix_worklogs_user_id ON public.worklogs USING btree (user_id);


--
-- Name: attachments attachments_organization_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.attachments
    ADD CONSTRAINT attachments_organization_id_fkey FOREIGN KEY (organization_id) REFERENCES public.organizations(id);


--
-- Name: attachments attachments_task_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.attachments
    ADD CONSTRAINT attachments_task_id_fkey FOREIGN KEY (task_id) REFERENCES public.tasks(id);


--
-- Name: attachments attachments_uploaded_by_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.attachments
    ADD CONSTRAINT attachments_uploaded_by_id_fkey FOREIGN KEY (uploaded_by_id) REFERENCES public.users(id);


--
-- Name: audit_logs audit_logs_actor_user_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.audit_logs
    ADD CONSTRAINT audit_logs_actor_user_id_fkey FOREIGN KEY (actor_user_id) REFERENCES public.users(id);


--
-- Name: audit_logs audit_logs_organization_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.audit_logs
    ADD CONSTRAINT audit_logs_organization_id_fkey FOREIGN KEY (organization_id) REFERENCES public.organizations(id);


--
-- Name: calendar_events calendar_events_created_by_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.calendar_events
    ADD CONSTRAINT calendar_events_created_by_id_fkey FOREIGN KEY (created_by_id) REFERENCES public.users(id);


--
-- Name: calendar_events calendar_events_organization_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.calendar_events
    ADD CONSTRAINT calendar_events_organization_id_fkey FOREIGN KEY (organization_id) REFERENCES public.organizations(id);


--
-- Name: calendar_events calendar_events_project_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.calendar_events
    ADD CONSTRAINT calendar_events_project_id_fkey FOREIGN KEY (project_id) REFERENCES public.projects(id);


--
-- Name: calendar_events calendar_events_user_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.calendar_events
    ADD CONSTRAINT calendar_events_user_id_fkey FOREIGN KEY (user_id) REFERENCES public.users(id);


--
-- Name: comments comments_author_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.comments
    ADD CONSTRAINT comments_author_id_fkey FOREIGN KEY (author_id) REFERENCES public.users(id);


--
-- Name: comments comments_organization_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.comments
    ADD CONSTRAINT comments_organization_id_fkey FOREIGN KEY (organization_id) REFERENCES public.organizations(id);


--
-- Name: comments comments_task_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.comments
    ADD CONSTRAINT comments_task_id_fkey FOREIGN KEY (task_id) REFERENCES public.tasks(id);


--
-- Name: department_memberships department_memberships_department_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.department_memberships
    ADD CONSTRAINT department_memberships_department_id_fkey FOREIGN KEY (department_id) REFERENCES public.departments(id) ON DELETE CASCADE;


--
-- Name: department_memberships department_memberships_organization_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.department_memberships
    ADD CONSTRAINT department_memberships_organization_id_fkey FOREIGN KEY (organization_id) REFERENCES public.organizations(id);


--
-- Name: department_memberships department_memberships_user_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.department_memberships
    ADD CONSTRAINT department_memberships_user_id_fkey FOREIGN KEY (user_id) REFERENCES public.users(id) ON DELETE CASCADE;


--
-- Name: departments departments_organization_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.departments
    ADD CONSTRAINT departments_organization_id_fkey FOREIGN KEY (organization_id) REFERENCES public.organizations(id);


--
-- Name: export_jobs export_jobs_organization_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.export_jobs
    ADD CONSTRAINT export_jobs_organization_id_fkey FOREIGN KEY (organization_id) REFERENCES public.organizations(id);


--
-- Name: export_jobs export_jobs_requested_by_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.export_jobs
    ADD CONSTRAINT export_jobs_requested_by_id_fkey FOREIGN KEY (requested_by_id) REFERENCES public.users(id);


--
-- Name: finance_categories finance_categories_organization_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.finance_categories
    ADD CONSTRAINT finance_categories_organization_id_fkey FOREIGN KEY (organization_id) REFERENCES public.organizations(id) ON DELETE CASCADE;


--
-- Name: finance_entries finance_entries_category_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.finance_entries
    ADD CONSTRAINT finance_entries_category_id_fkey FOREIGN KEY (category_id) REFERENCES public.finance_categories(id);


--
-- Name: finance_entries finance_entries_organization_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.finance_entries
    ADD CONSTRAINT finance_entries_organization_id_fkey FOREIGN KEY (organization_id) REFERENCES public.organizations(id) ON DELETE CASCADE;


--
-- Name: finance_entries finance_entries_project_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.finance_entries
    ADD CONSTRAINT finance_entries_project_id_fkey FOREIGN KEY (project_id) REFERENCES public.projects(id);


--
-- Name: finance_entries finance_entries_recorded_by_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.finance_entries
    ADD CONSTRAINT finance_entries_recorded_by_id_fkey FOREIGN KEY (recorded_by_id) REFERENCES public.users(id);


--
-- Name: projects fk_projects_department_id_departments; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.projects
    ADD CONSTRAINT fk_projects_department_id_departments FOREIGN KEY (department_id) REFERENCES public.departments(id) ON DELETE SET NULL;


--
-- Name: projects fk_projects_manager_id_users; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.projects
    ADD CONSTRAINT fk_projects_manager_id_users FOREIGN KEY (manager_id) REFERENCES public.users(id) ON DELETE SET NULL;


--
-- Name: users fk_users_account_id_accounts; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.users
    ADD CONSTRAINT fk_users_account_id_accounts FOREIGN KEY (account_id) REFERENCES public.accounts(id);


--
-- Name: users fk_users_department_id_departments; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.users
    ADD CONSTRAINT fk_users_department_id_departments FOREIGN KEY (department_id) REFERENCES public.departments(id) ON DELETE SET NULL;


--
-- Name: leave_requests leave_requests_organization_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.leave_requests
    ADD CONSTRAINT leave_requests_organization_id_fkey FOREIGN KEY (organization_id) REFERENCES public.organizations(id);


--
-- Name: leave_requests leave_requests_reviewed_by_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.leave_requests
    ADD CONSTRAINT leave_requests_reviewed_by_id_fkey FOREIGN KEY (reviewed_by_id) REFERENCES public.users(id) ON DELETE SET NULL;


--
-- Name: leave_requests leave_requests_user_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.leave_requests
    ADD CONSTRAINT leave_requests_user_id_fkey FOREIGN KEY (user_id) REFERENCES public.users(id);


--
-- Name: notifications notifications_organization_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.notifications
    ADD CONSTRAINT notifications_organization_id_fkey FOREIGN KEY (organization_id) REFERENCES public.organizations(id);


--
-- Name: notifications notifications_user_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.notifications
    ADD CONSTRAINT notifications_user_id_fkey FOREIGN KEY (user_id) REFERENCES public.users(id);


--
-- Name: payments payments_organization_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.payments
    ADD CONSTRAINT payments_organization_id_fkey FOREIGN KEY (organization_id) REFERENCES public.organizations(id);


--
-- Name: payments payments_project_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.payments
    ADD CONSTRAINT payments_project_id_fkey FOREIGN KEY (project_id) REFERENCES public.projects(id);


--
-- Name: payments payments_recorded_by_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.payments
    ADD CONSTRAINT payments_recorded_by_id_fkey FOREIGN KEY (recorded_by_id) REFERENCES public.users(id);


--
-- Name: project_members project_members_project_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.project_members
    ADD CONSTRAINT project_members_project_id_fkey FOREIGN KEY (project_id) REFERENCES public.projects(id);


--
-- Name: project_members project_members_user_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.project_members
    ADD CONSTRAINT project_members_user_id_fkey FOREIGN KEY (user_id) REFERENCES public.users(id);


--
-- Name: projects projects_created_by_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.projects
    ADD CONSTRAINT projects_created_by_id_fkey FOREIGN KEY (created_by_id) REFERENCES public.users(id);


--
-- Name: projects projects_organization_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.projects
    ADD CONSTRAINT projects_organization_id_fkey FOREIGN KEY (organization_id) REFERENCES public.organizations(id);


--
-- Name: task_activity_logs task_activity_logs_actor_user_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.task_activity_logs
    ADD CONSTRAINT task_activity_logs_actor_user_id_fkey FOREIGN KEY (actor_user_id) REFERENCES public.users(id);


--
-- Name: task_activity_logs task_activity_logs_organization_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.task_activity_logs
    ADD CONSTRAINT task_activity_logs_organization_id_fkey FOREIGN KEY (organization_id) REFERENCES public.organizations(id);


--
-- Name: task_activity_logs task_activity_logs_task_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.task_activity_logs
    ADD CONSTRAINT task_activity_logs_task_id_fkey FOREIGN KEY (task_id) REFERENCES public.tasks(id);


--
-- Name: task_dependencies task_dependencies_depends_on_task_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.task_dependencies
    ADD CONSTRAINT task_dependencies_depends_on_task_id_fkey FOREIGN KEY (depends_on_task_id) REFERENCES public.tasks(id);


--
-- Name: task_dependencies task_dependencies_task_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.task_dependencies
    ADD CONSTRAINT task_dependencies_task_id_fkey FOREIGN KEY (task_id) REFERENCES public.tasks(id);


--
-- Name: tasks tasks_assignee_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.tasks
    ADD CONSTRAINT tasks_assignee_id_fkey FOREIGN KEY (assignee_id) REFERENCES public.users(id);


--
-- Name: tasks tasks_created_by_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.tasks
    ADD CONSTRAINT tasks_created_by_id_fkey FOREIGN KEY (created_by_id) REFERENCES public.users(id);


--
-- Name: tasks tasks_organization_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.tasks
    ADD CONSTRAINT tasks_organization_id_fkey FOREIGN KEY (organization_id) REFERENCES public.organizations(id);


--
-- Name: tasks tasks_parent_task_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.tasks
    ADD CONSTRAINT tasks_parent_task_id_fkey FOREIGN KEY (parent_task_id) REFERENCES public.tasks(id);


--
-- Name: tasks tasks_project_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.tasks
    ADD CONSTRAINT tasks_project_id_fkey FOREIGN KEY (project_id) REFERENCES public.projects(id);


--
-- Name: users users_organization_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.users
    ADD CONSTRAINT users_organization_id_fkey FOREIGN KEY (organization_id) REFERENCES public.organizations(id);


--
-- Name: worklogs worklogs_organization_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.worklogs
    ADD CONSTRAINT worklogs_organization_id_fkey FOREIGN KEY (organization_id) REFERENCES public.organizations(id);


--
-- Name: worklogs worklogs_reviewed_by_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.worklogs
    ADD CONSTRAINT worklogs_reviewed_by_id_fkey FOREIGN KEY (reviewed_by_id) REFERENCES public.users(id);


--
-- Name: worklogs worklogs_task_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.worklogs
    ADD CONSTRAINT worklogs_task_id_fkey FOREIGN KEY (task_id) REFERENCES public.tasks(id);


--
-- Name: worklogs worklogs_user_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.worklogs
    ADD CONSTRAINT worklogs_user_id_fkey FOREIGN KEY (user_id) REFERENCES public.users(id);


--
-- PostgreSQL database dump complete
--


