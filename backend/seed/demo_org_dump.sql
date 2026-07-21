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
    task_id uuid,
    uploaded_by_id uuid NOT NULL,
    file_path character varying(500) NOT NULL,
    original_filename character varying(300) NOT NULL,
    content_type character varying(150) NOT NULL,
    size_bytes integer NOT NULL,
    id uuid NOT NULL,
    created_at timestamp with time zone DEFAULT now() NOT NULL,
    updated_at timestamp with time zone DEFAULT now() NOT NULL,
    finance_entry_id uuid,
    CONSTRAINT ck_attachment_exactly_one_parent CHECK ((((task_id IS NOT NULL) AND (finance_entry_id IS NULL)) OR ((task_id IS NULL) AND (finance_entry_id IS NOT NULL))))
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
-- Name: calendar_event_categories; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.calendar_event_categories (
    id uuid NOT NULL,
    created_at timestamp with time zone NOT NULL,
    updated_at timestamp with time zone NOT NULL,
    organization_id uuid NOT NULL,
    name character varying(120) NOT NULL,
    color character varying(20) DEFAULT '#64748b'::character varying NOT NULL,
    is_system boolean DEFAULT false NOT NULL
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
    all_day boolean DEFAULT false NOT NULL,
    category_id uuid
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
4bab4df5-ec35-4c17-9618-ea4f752847a7	2026-07-21 18:09:05.468077+00	2026-07-21 18:09:05.468077+00	09100000001	$2b$12$CjP6BcoyQWzTpJQrNhsTNukIZxw2wBuE1h98diKNpTB1K5jroQvz2
676321b4-002c-469c-8745-ae0d49e8d362	2026-07-21 18:09:05.468077+00	2026-07-21 18:09:05.468077+00	09111000000	$2b$12$EPvMroRBt2qV5qVozkojkuGYVwMC/9B2Lcnq4e5wBIh8lgFa10I86
6666fb55-09e9-46c5-99cb-24d40a088f01	2026-07-21 18:09:05.468077+00	2026-07-21 18:09:05.468077+00	09111000011	$2b$12$vlgcINtJmZxxYBsolw9/iuGZtEJ5Y7FmE0ApvYA5GmnE1rODyQpGK
b0eb763c-1885-47b6-8830-2b395e87024c	2026-07-21 18:09:05.468077+00	2026-07-21 18:09:05.468077+00	09111000012	$2b$12$8PpTtTRjooggdfJu6gerS.385nVmKeS6ZQPEn/jBUP/mj80g0kCKa
45ec130f-f756-4802-9a44-9acb5af20d25	2026-07-21 18:09:05.468077+00	2026-07-21 18:09:05.468077+00	09111000013	$2b$12$zOEZfxTqcsVWQEd72WYpfu2aBd53rMnyRG.EcZ32.ZloDYyBYwE0.
843d0e99-1656-432f-a302-159b197a81b3	2026-07-21 18:09:05.468077+00	2026-07-21 18:09:05.468077+00	09111000014	$2b$12$Ji6D3dQios7.cJLZhbSTL.YBR53t4ZWfit61IAguMkkvQkefUjZsm
58b12847-e009-4552-99d4-ec4cc07b9d4b	2026-07-21 18:09:05.468077+00	2026-07-21 18:09:05.468077+00	09111000015	$2b$12$SPtvKJN.nEMM4gQm8iWB4u8GFEPADAPPxe0yWScs5.9dfr3pK8nV2
3e838814-2937-4c43-92f4-5f36d1d859b3	2026-07-21 18:09:05.468077+00	2026-07-21 18:09:05.468077+00	09111000016	$2b$12$p/m6LW7L1gmjmq3BEgFkReRyMxlkP7BhqW1w3lEJtUZg.i0SUxQLG
2af29398-2df5-4280-838c-769c387ce926	2026-07-21 18:09:05.468077+00	2026-07-21 18:09:05.468077+00	09121000100	$2b$12$8/rxet5oWcMMfRLhlJzHrusL3DSpDrr/489Wsn5KBdznHedi.0OyW
cd26d968-a7fb-4d62-b1a5-588e24b3bb5a	2026-07-21 18:09:05.468077+00	2026-07-21 18:09:05.468077+00	09121000111	$2b$12$ke86n6PBG5KmVrSO2K2bpO1iGcyYSy6t/tcplPZJa9nk0cU3OHLd2
03916a9b-f265-486c-83cd-4b080fd6d577	2026-07-21 18:09:05.468077+00	2026-07-21 18:09:05.468077+00	09121000112	$2b$12$eCPH7IjIb8Ys/FEFwbtIrub6X8V1IxxB/CTa0yBTwLvWaZ7nLBBWm
cbc0b2dd-dd01-4b5d-b3ce-7f83f9241d60	2026-07-21 18:09:05.468077+00	2026-07-21 18:09:05.468077+00	09121000113	$2b$12$81BMlz/8TIkjLM.eY5Zv2.aURAYqYKK8Lx6hrXEe0SI0xcoCLD0/a
82f62316-49a4-4ac4-bb16-6dfcdb7ec62b	2026-07-21 18:09:05.468077+00	2026-07-21 18:09:05.468077+00	09121000114	$2b$12$jbTU/F8e6qxeSogDFZZovetKuCgJceJ7NKI3RAMDjgcDrbw.ymO6a
8103cda8-d62d-4031-b4fb-85a00961c87d	2026-07-21 18:09:05.468077+00	2026-07-21 18:09:05.468077+00	09121000115	$2b$12$8IIilb97QB/MJ8lGNV6U8.clWsCKk4wdEl33L9XbCFeq63kBqtqVm
abfb435b-ffc6-415b-8a9e-cd4d18615174	2026-07-21 18:09:05.468077+00	2026-07-21 18:09:05.468077+00	09121000116	$2b$12$DBi/f.bRnZpevM6FoKpp8eGLsyfsHkA74CZuQevzJv6zoCSsk35Hi
c1b7bc1c-08b7-4bc0-a066-025328ce69ca	2026-07-21 18:09:05.468077+00	2026-07-21 18:09:05.468077+00	09131000200	$2b$12$dheomclqt5AyeaEaULdf2eagCh29qRLiFX/O6.LZsdBtCrtl14U92
f1ec4959-c927-4f70-a387-43fc1dba386d	2026-07-21 18:09:05.468077+00	2026-07-21 18:09:05.468077+00	09131000211	$2b$12$/TuxUsvoQzc3ZcHM6upixui6FLzt.bfAHYZ9.46.y1YowrHCS1/2m
2a3180b2-c971-4536-b009-28594105288e	2026-07-21 18:09:05.468077+00	2026-07-21 18:09:05.468077+00	09131000212	$2b$12$u49TqLgOTbn5UnYE1yJTl.FT8w67NB/lmxzBPC8.okLJ5CAzttEnC
c1b228ad-8ad7-4400-8fe2-050098d53255	2026-07-21 18:09:05.468077+00	2026-07-21 18:09:05.468077+00	09131000213	$2b$12$/fMgupSY2je1xMtJgWs5ZOYYkqCSY/P3Ib3TS9QGKYkUgYbe92vA2
d3efba31-2c55-4c00-bb44-d33e7d9a4a4e	2026-07-21 18:09:05.468077+00	2026-07-21 18:09:05.468077+00	09131000214	$2b$12$EVSEBWJmNbjab57ZMgwgserXrcaBzLgodZdNB0iXkoePNM3fTyXPC
956634d4-53ce-4fc2-9a50-45fcc44f53bc	2026-07-21 18:09:05.468077+00	2026-07-21 18:09:05.468077+00	09131000215	$2b$12$sVz/sMM/wsCUNSKEBOkAWetA.YAPa8AHglZsmFK2J.nMJo3dywNcm
190af3ee-3f6a-4418-8ce1-aec073075bc9	2026-07-21 18:09:05.468077+00	2026-07-21 18:09:05.468077+00	09131000216	$2b$12$VI42LFxqo0dV2jYpRAafyeMtejPJw11jFb1xka9MBKpqTf3pqJ12C
\.


--
-- Data for Name: alembic_version; Type: TABLE DATA; Schema: public; Owner: -
--

COPY public.alembic_version (version_num) FROM stdin;
e4f7a1c3d6b8
\.


--
-- Data for Name: attachments; Type: TABLE DATA; Schema: public; Owner: -
--

COPY public.attachments (organization_id, task_id, uploaded_by_id, file_path, original_filename, content_type, size_bytes, id, created_at, updated_at, finance_entry_id) FROM stdin;
2f01124a-87cc-42c0-aff1-ff0045070c4d	\N	e11e2d19-e7e3-4137-b206-b39a072b4754	attachments/2f01124a-87cc-42c0-aff1-ff0045070c4d/65b4c5f4-145e-41fd-b17a-578676ca6443-p5_01_finance_table.png	p5_01_finance_table.png	image/png	133070	7e1ef3e0-7950-4802-953c-ae8b2097bd25	2026-07-21 18:10:59.726391+00	2026-07-21 18:10:59.726391+00	6d6d4074-659e-4e7e-a974-3a945481c46f
\.


--
-- Data for Name: audit_logs; Type: TABLE DATA; Schema: public; Owner: -
--

COPY public.audit_logs (created_at, organization_id, actor_user_id, action, entity_type, entity_id, extra_metadata, id) FROM stdin;
2026-07-21 18:10:54.286471+00	2f01124a-87cc-42c0-aff1-ff0045070c4d	e11e2d19-e7e3-4137-b206-b39a072b4754	user.login	user	e11e2d19-e7e3-4137-b206-b39a072b4754	{}	b0575de8-dc34-465a-b7b3-8362454364f8
2026-07-21 18:10:57.366697+00	2f01124a-87cc-42c0-aff1-ff0045070c4d	e11e2d19-e7e3-4137-b206-b39a072b4754	finance.create	finance_entry	6d6d4074-659e-4e7e-a974-3a945481c46f	{"title": "Playwright Test Entry"}	fe9bf94a-94ee-43eb-b8f5-f8e7d1715468
\.


--
-- Data for Name: calendar_event_categories; Type: TABLE DATA; Schema: public; Owner: -
--

COPY public.calendar_event_categories (id, created_at, updated_at, organization_id, name, color, is_system) FROM stdin;
\.


--
-- Data for Name: calendar_events; Type: TABLE DATA; Schema: public; Owner: -
--

COPY public.calendar_events (id, created_at, updated_at, organization_id, created_by_id, project_id, user_id, title, description, event_type, start_at, end_at, all_day, category_id) FROM stdin;
3ad10f1e-58a0-4f2f-9c59-223ee0b9e2a7	2026-07-21 18:09:05.468077+00	2026-07-21 18:09:05.468077+00	2f01124a-87cc-42c0-aff1-ff0045070c4d	10b934e7-80e6-41d0-9140-f56d92d614ae	76b9e3d7-02ce-47a0-b44b-1226b51aaa87	\N	جلسهٔ برنامه‌ریزی اسپرینت	\N	meeting	2026-06-20 10:00:00+00	2026-06-20 11:00:00+00	f	\N
77abea2c-7226-478e-aea6-e241106dfef1	2026-07-21 18:09:05.468077+00	2026-07-21 18:09:05.468077+00	2f01124a-87cc-42c0-aff1-ff0045070c4d	dfe22c83-6863-413d-97b7-1eb9b52dec02	70dba40f-b476-4927-8513-6f659d761416	\N	یادآوری ارسال گزارش	\N	reminder	2026-06-17 00:00:00+00	2026-06-17 01:00:00+00	t	\N
86b3b876-4f5e-42e6-a07f-322c44f55bc1	2026-07-21 18:09:05.468077+00	2026-07-21 18:09:05.468077+00	2f01124a-87cc-42c0-aff1-ff0045070c4d	10b934e7-80e6-41d0-9140-f56d92d614ae	76b9e3d7-02ce-47a0-b44b-1226b51aaa87	\N	جلسهٔ برنامه‌ریزی اسپرینت	\N	meeting	2026-06-27 10:00:00+00	2026-06-27 11:00:00+00	f	\N
8697b197-20f4-4245-a7f9-4017d557f67b	2026-07-21 18:09:05.468077+00	2026-07-21 18:09:05.468077+00	2f01124a-87cc-42c0-aff1-ff0045070c4d	dfe22c83-6863-413d-97b7-1eb9b52dec02	a1110f20-cd7e-4120-bc78-d446d13a5468	\N	یادآوری پیگیری مشتری	\N	reminder	2026-06-23 00:00:00+00	2026-06-23 01:00:00+00	t	\N
154e6743-0286-47d4-ab61-035fdf842af3	2026-07-21 18:09:05.468077+00	2026-07-21 18:09:05.468077+00	2f01124a-87cc-42c0-aff1-ff0045070c4d	10b934e7-80e6-41d0-9140-f56d92d614ae	a1110f20-cd7e-4120-bc78-d446d13a5468	\N	جلسهٔ هماهنگی هفتگی	\N	meeting	2026-07-04 10:00:00+00	2026-07-04 11:00:00+00	f	\N
55fad1c9-99c0-4e2d-a844-3f9a642d90d3	2026-07-21 18:09:05.468077+00	2026-07-21 18:09:05.468077+00	2f01124a-87cc-42c0-aff1-ff0045070c4d	de5c1d0c-3ca8-4c75-8525-abcfac9d0651	76b9e3d7-02ce-47a0-b44b-1226b51aaa87	\N	یادآوری پیگیری مشتری	\N	reminder	2026-07-03 00:00:00+00	2026-07-03 01:00:00+00	t	\N
afc4c528-3375-4c9b-9f3d-15c0f9d9f8f8	2026-07-21 18:09:05.468077+00	2026-07-21 18:09:05.468077+00	2f01124a-87cc-42c0-aff1-ff0045070c4d	10b934e7-80e6-41d0-9140-f56d92d614ae	70dba40f-b476-4927-8513-6f659d761416	\N	جلسهٔ برنامه‌ریزی اسپرینت	\N	meeting	2026-07-09 10:00:00+00	2026-07-09 11:00:00+00	f	\N
3d657dbd-1025-40a0-81d5-5383ba8c3b58	2026-07-21 18:09:05.468077+00	2026-07-21 18:09:05.468077+00	2f01124a-87cc-42c0-aff1-ff0045070c4d	1c04dd92-4377-490c-934c-38244ec68419	ded132eb-db08-429a-81c1-f1a31e3d80fb	\N	یادآوری ارسال گزارش	\N	reminder	2026-07-12 00:00:00+00	2026-07-12 01:00:00+00	t	\N
3fde72a0-6ab9-4c2d-915f-042d67923737	2026-07-21 18:09:05.468077+00	2026-07-21 18:09:05.468077+00	2f01124a-87cc-42c0-aff1-ff0045070c4d	10b934e7-80e6-41d0-9140-f56d92d614ae	ded132eb-db08-429a-81c1-f1a31e3d80fb	\N	جلسهٔ هماهنگی هفتگی	\N	meeting	2026-07-15 10:00:00+00	2026-07-15 11:00:00+00	f	\N
4ff748e0-9d5e-42eb-a626-8d241940b939	2026-07-21 18:09:05.468077+00	2026-07-21 18:09:05.468077+00	2f01124a-87cc-42c0-aff1-ff0045070c4d	dfe22c83-6863-413d-97b7-1eb9b52dec02	ded132eb-db08-429a-81c1-f1a31e3d80fb	\N	یادآوری ارسال گزارش	\N	reminder	2026-07-20 00:00:00+00	2026-07-20 01:00:00+00	t	\N
25148f5a-1065-4a5a-81fa-cc873d311e63	2026-07-21 18:09:05.468077+00	2026-07-21 18:09:05.468077+00	2f01124a-87cc-42c0-aff1-ff0045070c4d	10b934e7-80e6-41d0-9140-f56d92d614ae	76b9e3d7-02ce-47a0-b44b-1226b51aaa87	\N	جلسهٔ برنامه‌ریزی اسپرینت	\N	meeting	2026-07-23 10:00:00+00	2026-07-23 11:00:00+00	f	\N
0cd087ef-29f0-4dbf-bb77-a4c95fdf8865	2026-07-21 18:09:05.468077+00	2026-07-21 18:09:05.468077+00	2f01124a-87cc-42c0-aff1-ff0045070c4d	f7d585ca-9137-4691-8979-1d8553a71ed8	b1c434b9-f0de-4a84-9df9-97cdceffaccf	\N	یادآوری پیگیری مشتری	\N	reminder	2026-07-27 00:00:00+00	2026-07-27 01:00:00+00	t	\N
8a339fd7-f510-4be6-a2d5-d7300364eacb	2026-07-21 18:09:05.468077+00	2026-07-21 18:09:05.468077+00	2f01124a-87cc-42c0-aff1-ff0045070c4d	10b934e7-80e6-41d0-9140-f56d92d614ae	70dba40f-b476-4927-8513-6f659d761416	\N	جلسهٔ بررسی پیشرفت پروژه	\N	meeting	2026-07-31 10:00:00+00	2026-07-31 11:00:00+00	f	\N
2975edda-9aaa-44f0-a6dd-16958ffc55fd	2026-07-21 18:09:05.468077+00	2026-07-21 18:09:05.468077+00	2f01124a-87cc-42c0-aff1-ff0045070c4d	4e4c6e76-84d5-464d-957c-75ff3e9a2f8a	76b9e3d7-02ce-47a0-b44b-1226b51aaa87	\N	یادآوری پیگیری مشتری	\N	reminder	2026-08-03 00:00:00+00	2026-08-03 01:00:00+00	t	\N
f5b744f8-21ca-41b2-86d6-6fc0d689afc8	2026-07-21 18:09:05.468077+00	2026-07-21 18:09:05.468077+00	2f01124a-87cc-42c0-aff1-ff0045070c4d	10b934e7-80e6-41d0-9140-f56d92d614ae	70dba40f-b476-4927-8513-6f659d761416	\N	جلسهٔ برنامه‌ریزی اسپرینت	\N	meeting	2026-08-04 10:00:00+00	2026-08-04 11:00:00+00	f	\N
810cba85-0cc7-4996-aa8e-6c7b1e1b82dc	2026-07-21 18:09:05.468077+00	2026-07-21 18:09:05.468077+00	2f01124a-87cc-42c0-aff1-ff0045070c4d	1c04dd92-4377-490c-934c-38244ec68419	b1c434b9-f0de-4a84-9df9-97cdceffaccf	\N	یادآوری ارسال گزارش	\N	reminder	2026-08-05 00:00:00+00	2026-08-05 01:00:00+00	t	\N
9df7bdb6-ab03-4447-b89c-59c2fc979d28	2026-07-21 18:09:05.468077+00	2026-07-21 18:09:05.468077+00	2f01124a-87cc-42c0-aff1-ff0045070c4d	10b934e7-80e6-41d0-9140-f56d92d614ae	ded132eb-db08-429a-81c1-f1a31e3d80fb	\N	جلسهٔ مرور با مدیریت	\N	meeting	2026-08-13 10:00:00+00	2026-08-13 11:00:00+00	f	\N
1bbea9b4-e228-43c1-83b0-c10ff14d86d8	2026-07-21 18:09:05.468077+00	2026-07-21 18:09:05.468077+00	2f01124a-87cc-42c0-aff1-ff0045070c4d	dfe22c83-6863-413d-97b7-1eb9b52dec02	70dba40f-b476-4927-8513-6f659d761416	\N	یادآوری تمدید قرارداد	\N	reminder	2026-08-17 00:00:00+00	2026-08-17 01:00:00+00	t	\N
c2df8d19-ca96-4feb-af01-f302fb4de6f2	2026-07-21 18:09:05.468077+00	2026-07-21 18:09:05.468077+00	2f01124a-87cc-42c0-aff1-ff0045070c4d	42df4646-393a-4de3-83d6-df4785b690c6	865b2901-75dd-4a80-bdb3-bb9cd38f1b68	\N	جلسهٔ برنامه‌ریزی اسپرینت	\N	meeting	2026-06-17 10:00:00+00	2026-06-17 11:00:00+00	f	\N
75cfabd6-0c2b-44b2-9c28-ef0f2d384073	2026-07-21 18:09:05.468077+00	2026-07-21 18:09:05.468077+00	2f01124a-87cc-42c0-aff1-ff0045070c4d	3683aa32-1561-4f36-90bf-d6402b4a66d8	865b2901-75dd-4a80-bdb3-bb9cd38f1b68	\N	یادآوری تمدید قرارداد	\N	reminder	2026-06-19 00:00:00+00	2026-06-19 01:00:00+00	t	\N
be0a1640-77d9-4b60-8d87-976c88fdf80f	2026-07-21 18:09:05.468077+00	2026-07-21 18:09:05.468077+00	2f01124a-87cc-42c0-aff1-ff0045070c4d	42df4646-393a-4de3-83d6-df4785b690c6	b439b371-fa49-40be-b62a-cf771b88bb1b	\N	جلسهٔ برنامه‌ریزی اسپرینت	\N	meeting	2026-06-23 10:00:00+00	2026-06-23 11:00:00+00	f	\N
7d1b30ff-71d2-4b12-984e-25504781d573	2026-07-21 18:09:05.468077+00	2026-07-21 18:09:05.468077+00	2f01124a-87cc-42c0-aff1-ff0045070c4d	2d6d452d-4915-4793-bf0b-ad7d43798e6f	7ccce913-5c45-45ec-a44c-1c50c45bb193	\N	یادآوری ارسال گزارش	\N	reminder	2026-06-26 00:00:00+00	2026-06-26 01:00:00+00	t	\N
b237ed93-6f57-4af7-a75c-04c0199d0757	2026-07-21 18:09:05.468077+00	2026-07-21 18:09:05.468077+00	2f01124a-87cc-42c0-aff1-ff0045070c4d	42df4646-393a-4de3-83d6-df4785b690c6	865b2901-75dd-4a80-bdb3-bb9cd38f1b68	\N	جلسهٔ هماهنگی هفتگی	\N	meeting	2026-07-01 10:00:00+00	2026-07-01 11:00:00+00	f	\N
89f7f8eb-7c76-4b8e-a214-4e887d8402b5	2026-07-21 18:09:05.468077+00	2026-07-21 18:09:05.468077+00	2f01124a-87cc-42c0-aff1-ff0045070c4d	b4d6dda1-b07b-48aa-b440-b2cbfe40ac0f	189350e0-cc86-486f-a699-53771a8307c9	\N	یادآوری تمدید قرارداد	\N	reminder	2026-07-03 00:00:00+00	2026-07-03 01:00:00+00	t	\N
a0ec8816-33b6-46d4-9cdb-8d8c8022ff7e	2026-07-21 18:09:05.468077+00	2026-07-21 18:09:05.468077+00	2f01124a-87cc-42c0-aff1-ff0045070c4d	42df4646-393a-4de3-83d6-df4785b690c6	865b2901-75dd-4a80-bdb3-bb9cd38f1b68	\N	جلسهٔ برنامه‌ریزی اسپرینت	\N	meeting	2026-07-10 10:00:00+00	2026-07-10 11:00:00+00	f	\N
e957e2ff-8740-49e0-8da5-7c9436211c50	2026-07-21 18:09:05.468077+00	2026-07-21 18:09:05.468077+00	2f01124a-87cc-42c0-aff1-ff0045070c4d	72cdbbe8-b0fe-43f0-ab1a-f11f02a63e1f	189350e0-cc86-486f-a699-53771a8307c9	\N	یادآوری تمدید قرارداد	\N	reminder	2026-07-11 00:00:00+00	2026-07-11 01:00:00+00	t	\N
38ff6dec-7204-444e-b806-1fe88befa2ac	2026-07-21 18:09:05.468077+00	2026-07-21 18:09:05.468077+00	2f01124a-87cc-42c0-aff1-ff0045070c4d	42df4646-393a-4de3-83d6-df4785b690c6	189350e0-cc86-486f-a699-53771a8307c9	\N	جلسهٔ هماهنگی هفتگی	\N	meeting	2026-07-15 10:00:00+00	2026-07-15 11:00:00+00	f	\N
175322dd-f72b-4ae5-8991-2e3ee42efdc0	2026-07-21 18:09:05.468077+00	2026-07-21 18:09:05.468077+00	2f01124a-87cc-42c0-aff1-ff0045070c4d	72cdbbe8-b0fe-43f0-ab1a-f11f02a63e1f	fe2692d0-5164-4138-b8f5-5f7e8a8e7580	\N	یادآوری ارسال گزارش	\N	reminder	2026-07-16 00:00:00+00	2026-07-16 01:00:00+00	t	\N
fd813e46-c538-486d-9d88-60858079a29f	2026-07-21 18:09:05.468077+00	2026-07-21 18:09:05.468077+00	2f01124a-87cc-42c0-aff1-ff0045070c4d	42df4646-393a-4de3-83d6-df4785b690c6	189350e0-cc86-486f-a699-53771a8307c9	\N	جلسهٔ مرور با مدیریت	\N	meeting	2026-07-21 10:00:00+00	2026-07-21 11:00:00+00	f	\N
b01d268a-3fb2-413f-a363-d6e9b430cb0e	2026-07-21 18:09:05.468077+00	2026-07-21 18:09:05.468077+00	2f01124a-87cc-42c0-aff1-ff0045070c4d	02b5f471-cd3d-47ff-85ad-d22286b9e4b1	865b2901-75dd-4a80-bdb3-bb9cd38f1b68	\N	یادآوری ارسال گزارش	\N	reminder	2026-07-25 00:00:00+00	2026-07-25 01:00:00+00	t	\N
35bad969-ffe0-4efc-b9b0-209d282f219e	2026-07-21 18:09:05.468077+00	2026-07-21 18:09:05.468077+00	2f01124a-87cc-42c0-aff1-ff0045070c4d	42df4646-393a-4de3-83d6-df4785b690c6	fe2692d0-5164-4138-b8f5-5f7e8a8e7580	\N	جلسهٔ بررسی پیشرفت پروژه	\N	meeting	2026-07-28 10:00:00+00	2026-07-28 11:00:00+00	f	\N
0e5c889f-caa5-4117-a035-68fa32d6046c	2026-07-21 18:09:05.468077+00	2026-07-21 18:09:05.468077+00	2f01124a-87cc-42c0-aff1-ff0045070c4d	2d6d452d-4915-4793-bf0b-ad7d43798e6f	189350e0-cc86-486f-a699-53771a8307c9	\N	یادآوری پیگیری مشتری	\N	reminder	2026-08-02 00:00:00+00	2026-08-02 01:00:00+00	t	\N
4de164ad-0e34-469a-9211-4309a9ef74f6	2026-07-21 18:09:05.468077+00	2026-07-21 18:09:05.468077+00	2f01124a-87cc-42c0-aff1-ff0045070c4d	42df4646-393a-4de3-83d6-df4785b690c6	b439b371-fa49-40be-b62a-cf771b88bb1b	\N	جلسهٔ مرور با مدیریت	\N	meeting	2026-08-05 10:00:00+00	2026-08-05 11:00:00+00	f	\N
f2ce97f6-c92f-4a8f-9570-ee2c9bf14633	2026-07-21 18:09:05.468077+00	2026-07-21 18:09:05.468077+00	2f01124a-87cc-42c0-aff1-ff0045070c4d	2d6d452d-4915-4793-bf0b-ad7d43798e6f	fe2692d0-5164-4138-b8f5-5f7e8a8e7580	\N	یادآوری ارسال گزارش	\N	reminder	2026-08-06 00:00:00+00	2026-08-06 01:00:00+00	t	\N
b4e681e5-fab9-4cad-880c-6ec117413e95	2026-07-21 18:09:05.468077+00	2026-07-21 18:09:05.468077+00	2f01124a-87cc-42c0-aff1-ff0045070c4d	42df4646-393a-4de3-83d6-df4785b690c6	865b2901-75dd-4a80-bdb3-bb9cd38f1b68	\N	جلسهٔ برنامه‌ریزی اسپرینت	\N	meeting	2026-08-13 10:00:00+00	2026-08-13 11:00:00+00	f	\N
1c3bde97-ee53-42df-bc0f-7dcf79b707dd	2026-07-21 18:09:05.468077+00	2026-07-21 18:09:05.468077+00	2f01124a-87cc-42c0-aff1-ff0045070c4d	92a3b31d-254e-440b-8bbe-d18db13d73cd	189350e0-cc86-486f-a699-53771a8307c9	\N	یادآوری پیگیری مشتری	\N	reminder	2026-08-15 00:00:00+00	2026-08-15 01:00:00+00	t	\N
633c61d1-6419-407f-89f6-ff216df5c0a8	2026-07-21 18:09:05.468077+00	2026-07-21 18:09:05.468077+00	2f01124a-87cc-42c0-aff1-ff0045070c4d	c873d894-cb10-4d12-a1dd-f989a1851641	f84f219e-7c01-44ff-bc62-1ee898da0737	\N	جلسهٔ هماهنگی هفتگی	\N	meeting	2026-06-20 10:00:00+00	2026-06-20 11:00:00+00	f	\N
c3743335-e578-462f-a506-f0aee4458a26	2026-07-21 18:09:05.468077+00	2026-07-21 18:09:05.468077+00	2f01124a-87cc-42c0-aff1-ff0045070c4d	00a2a3bf-94c3-4ef6-a94b-bfb72866c1cd	714a6340-704b-4e08-8b30-4d9baafcb45c	\N	یادآوری ارسال گزارش	\N	reminder	2026-06-19 00:00:00+00	2026-06-19 01:00:00+00	t	\N
a9277106-1592-45d6-a4cc-33c763b95cc5	2026-07-21 18:09:05.468077+00	2026-07-21 18:09:05.468077+00	2f01124a-87cc-42c0-aff1-ff0045070c4d	c873d894-cb10-4d12-a1dd-f989a1851641	714a6340-704b-4e08-8b30-4d9baafcb45c	\N	جلسهٔ مرور با مدیریت	\N	meeting	2026-06-25 10:00:00+00	2026-06-25 11:00:00+00	f	\N
355151fd-ebf1-4940-9b29-f3f86d6d4ac1	2026-07-21 18:09:05.468077+00	2026-07-21 18:09:05.468077+00	2f01124a-87cc-42c0-aff1-ff0045070c4d	47bf13da-40a8-4016-b601-d596b7a29a50	0901f3f3-057f-4aae-bf11-9639f3ee3dd4	\N	یادآوری تمدید قرارداد	\N	reminder	2026-06-29 00:00:00+00	2026-06-29 01:00:00+00	t	\N
e9430fda-a958-4a46-89fd-8ee78426034b	2026-07-21 18:09:05.468077+00	2026-07-21 18:09:05.468077+00	2f01124a-87cc-42c0-aff1-ff0045070c4d	c873d894-cb10-4d12-a1dd-f989a1851641	4ceaa4b3-563d-4465-b395-a62490d00060	\N	جلسهٔ برنامه‌ریزی اسپرینت	\N	meeting	2026-07-02 10:00:00+00	2026-07-02 11:00:00+00	f	\N
6d5f8b8b-6511-4837-81ce-fea5c9d2c071	2026-07-21 18:09:05.468077+00	2026-07-21 18:09:05.468077+00	2f01124a-87cc-42c0-aff1-ff0045070c4d	eafb37ce-9111-4c51-91b5-dac320a98501	f84f219e-7c01-44ff-bc62-1ee898da0737	\N	یادآوری تمدید قرارداد	\N	reminder	2026-07-02 00:00:00+00	2026-07-02 01:00:00+00	t	\N
d75c49e4-baa1-43b7-9b9d-f02c45d82b4d	2026-07-21 18:09:05.468077+00	2026-07-21 18:09:05.468077+00	2f01124a-87cc-42c0-aff1-ff0045070c4d	c873d894-cb10-4d12-a1dd-f989a1851641	4ceaa4b3-563d-4465-b395-a62490d00060	\N	جلسهٔ مرور با مدیریت	\N	meeting	2026-07-07 10:00:00+00	2026-07-07 11:00:00+00	f	\N
4eb7d883-53b0-424c-ab81-70aa7cc71d7e	2026-07-21 18:09:05.468077+00	2026-07-21 18:09:05.468077+00	2f01124a-87cc-42c0-aff1-ff0045070c4d	fe42788d-ef87-41ef-8255-9e64e697d040	f84f219e-7c01-44ff-bc62-1ee898da0737	\N	یادآوری ارسال گزارش	\N	reminder	2026-07-07 00:00:00+00	2026-07-07 01:00:00+00	t	\N
532af11f-bf2b-4366-9c2d-a11dfbd0db15	2026-07-21 18:09:05.468077+00	2026-07-21 18:09:05.468077+00	2f01124a-87cc-42c0-aff1-ff0045070c4d	c873d894-cb10-4d12-a1dd-f989a1851641	f84f219e-7c01-44ff-bc62-1ee898da0737	\N	جلسهٔ بررسی پیشرفت پروژه	\N	meeting	2026-07-18 10:00:00+00	2026-07-18 11:00:00+00	f	\N
e0c14057-8448-434d-8b7e-bccd9a42f0d8	2026-07-21 18:09:05.468077+00	2026-07-21 18:09:05.468077+00	2f01124a-87cc-42c0-aff1-ff0045070c4d	fe42788d-ef87-41ef-8255-9e64e697d040	4ceaa4b3-563d-4465-b395-a62490d00060	\N	یادآوری تمدید قرارداد	\N	reminder	2026-07-20 00:00:00+00	2026-07-20 01:00:00+00	t	\N
838ed61e-be2a-4a10-9a9f-a70d9e6113c3	2026-07-21 18:09:05.468077+00	2026-07-21 18:09:05.468077+00	2f01124a-87cc-42c0-aff1-ff0045070c4d	c873d894-cb10-4d12-a1dd-f989a1851641	f84f219e-7c01-44ff-bc62-1ee898da0737	\N	جلسهٔ مرور با مدیریت	\N	meeting	2026-07-24 10:00:00+00	2026-07-24 11:00:00+00	f	\N
fcd42baa-afd3-472c-8409-ec6c1db4346e	2026-07-21 18:09:05.468077+00	2026-07-21 18:09:05.468077+00	2f01124a-87cc-42c0-aff1-ff0045070c4d	ae9392d2-7669-44be-a429-889e449b3eb1	f84f219e-7c01-44ff-bc62-1ee898da0737	\N	یادآوری تمدید قرارداد	\N	reminder	2026-07-21 00:00:00+00	2026-07-21 01:00:00+00	t	\N
2300ff8f-827a-4259-b21d-5ee1a5811e52	2026-07-21 18:09:05.468077+00	2026-07-21 18:09:05.468077+00	2f01124a-87cc-42c0-aff1-ff0045070c4d	c873d894-cb10-4d12-a1dd-f989a1851641	9af7d195-e857-469f-8432-97a00100cd49	\N	جلسهٔ بررسی پیشرفت پروژه	\N	meeting	2026-07-29 10:00:00+00	2026-07-29 11:00:00+00	f	\N
ba3d8087-34f9-450e-83b6-d1d0e9380d7f	2026-07-21 18:09:05.468077+00	2026-07-21 18:09:05.468077+00	2f01124a-87cc-42c0-aff1-ff0045070c4d	fe42788d-ef87-41ef-8255-9e64e697d040	9af7d195-e857-469f-8432-97a00100cd49	\N	یادآوری پیگیری مشتری	\N	reminder	2026-08-02 00:00:00+00	2026-08-02 01:00:00+00	t	\N
ffed4a8f-f560-4833-a5dc-f74690704b51	2026-07-21 18:09:05.468077+00	2026-07-21 18:09:05.468077+00	2f01124a-87cc-42c0-aff1-ff0045070c4d	c873d894-cb10-4d12-a1dd-f989a1851641	f84f219e-7c01-44ff-bc62-1ee898da0737	\N	جلسهٔ مرور با مدیریت	\N	meeting	2026-08-08 10:00:00+00	2026-08-08 11:00:00+00	f	\N
23cc5b9a-ecf2-4041-a9c8-18f2a36c3ee6	2026-07-21 18:09:05.468077+00	2026-07-21 18:09:05.468077+00	2f01124a-87cc-42c0-aff1-ff0045070c4d	00a2a3bf-94c3-4ef6-a94b-bfb72866c1cd	0901f3f3-057f-4aae-bf11-9639f3ee3dd4	\N	یادآوری ارسال گزارش	\N	reminder	2026-08-10 00:00:00+00	2026-08-10 01:00:00+00	t	\N
80e6e02e-619d-4ce0-9e78-706fccafbe08	2026-07-21 18:09:05.468077+00	2026-07-21 18:09:05.468077+00	2f01124a-87cc-42c0-aff1-ff0045070c4d	c873d894-cb10-4d12-a1dd-f989a1851641	4ceaa4b3-563d-4465-b395-a62490d00060	\N	جلسهٔ برنامه‌ریزی اسپرینت	\N	meeting	2026-08-12 10:00:00+00	2026-08-12 11:00:00+00	f	\N
a90ee599-b67c-43c0-a5e2-499b705f04e3	2026-07-21 18:09:05.468077+00	2026-07-21 18:09:05.468077+00	2f01124a-87cc-42c0-aff1-ff0045070c4d	47bf13da-40a8-4016-b601-d596b7a29a50	4ceaa4b3-563d-4465-b395-a62490d00060	\N	یادآوری پیگیری مشتری	\N	reminder	2026-08-13 00:00:00+00	2026-08-13 01:00:00+00	t	\N
b9dc3ac1-5b4e-4f61-9a79-729e24cbf41d	2026-07-21 18:09:05.468077+00	2026-07-21 18:09:05.468077+00	2f01124a-87cc-42c0-aff1-ff0045070c4d	e11e2d19-e7e3-4137-b206-b39a072b4754	\N	\N	تعطیلی رسمی	\N	holiday	2026-06-18 00:00:00+00	2026-06-18 01:00:00+00	t	\N
8ef6bea2-220e-4667-8129-0f6d35f46b39	2026-07-21 18:09:05.468077+00	2026-07-21 18:09:05.468077+00	2f01124a-87cc-42c0-aff1-ff0045070c4d	e11e2d19-e7e3-4137-b206-b39a072b4754	\N	\N	تعطیلی رسمی	\N	holiday	2026-07-16 00:00:00+00	2026-07-16 01:00:00+00	t	\N
c59a4479-148c-4461-b330-a32582a50ec2	2026-07-21 18:09:05.468077+00	2026-07-21 18:09:05.468077+00	2f01124a-87cc-42c0-aff1-ff0045070c4d	e11e2d19-e7e3-4137-b206-b39a072b4754	\N	\N	تعطیلی رسمی	\N	holiday	2026-08-13 00:00:00+00	2026-08-13 01:00:00+00	t	\N
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
e3355f3d-d5ec-4e16-8805-35ff7603f11b	2026-07-21 18:09:05.468077+00	2026-07-21 18:09:05.468077+00	2f01124a-87cc-42c0-aff1-ff0045070c4d	10b934e7-80e6-41d0-9140-f56d92d614ae	1367fc65-98ba-476a-8cdb-8c2bc8411c3b	project_manager
e00877cd-abd7-4d23-90cb-ebc2fff72127	2026-07-21 18:09:05.468077+00	2026-07-21 18:09:05.468077+00	2f01124a-87cc-42c0-aff1-ff0045070c4d	1c04dd92-4377-490c-934c-38244ec68419	1367fc65-98ba-476a-8cdb-8c2bc8411c3b	employee
9a87082c-8272-4d59-9b3b-90b096241a10	2026-07-21 18:09:05.468077+00	2026-07-21 18:09:05.468077+00	2f01124a-87cc-42c0-aff1-ff0045070c4d	4e4c6e76-84d5-464d-957c-75ff3e9a2f8a	1367fc65-98ba-476a-8cdb-8c2bc8411c3b	employee
245022f6-9758-4f39-89b1-67bfc631c215	2026-07-21 18:09:05.468077+00	2026-07-21 18:09:05.468077+00	2f01124a-87cc-42c0-aff1-ff0045070c4d	0aa2e3a9-85b6-420a-aeeb-62f6f7061c6c	1367fc65-98ba-476a-8cdb-8c2bc8411c3b	employee
9ae6ebe0-4ebc-4d76-8096-345d4d3e341f	2026-07-21 18:09:05.468077+00	2026-07-21 18:09:05.468077+00	2f01124a-87cc-42c0-aff1-ff0045070c4d	de5c1d0c-3ca8-4c75-8525-abcfac9d0651	1367fc65-98ba-476a-8cdb-8c2bc8411c3b	employee
b2b51ef9-d470-44c5-b7fa-bdec7cc5b372	2026-07-21 18:09:05.468077+00	2026-07-21 18:09:05.468077+00	2f01124a-87cc-42c0-aff1-ff0045070c4d	dfe22c83-6863-413d-97b7-1eb9b52dec02	1367fc65-98ba-476a-8cdb-8c2bc8411c3b	employee
19a67adb-76e1-4cbd-8edb-3931327f525d	2026-07-21 18:09:05.468077+00	2026-07-21 18:09:05.468077+00	2f01124a-87cc-42c0-aff1-ff0045070c4d	f7d585ca-9137-4691-8979-1d8553a71ed8	1367fc65-98ba-476a-8cdb-8c2bc8411c3b	employee
6507ea9a-de5d-4aee-b70c-d31434e5d72d	2026-07-21 18:09:05.468077+00	2026-07-21 18:09:05.468077+00	2f01124a-87cc-42c0-aff1-ff0045070c4d	42df4646-393a-4de3-83d6-df4785b690c6	6b7d47ac-33b3-4bb6-95f6-4e48329d1ce2	project_manager
856a5c9d-2f48-4b72-9a59-706b4dcf3d07	2026-07-21 18:09:05.468077+00	2026-07-21 18:09:05.468077+00	2f01124a-87cc-42c0-aff1-ff0045070c4d	92a3b31d-254e-440b-8bbe-d18db13d73cd	6b7d47ac-33b3-4bb6-95f6-4e48329d1ce2	employee
826757a8-7c75-44e9-b9e7-443a4a93adc5	2026-07-21 18:09:05.468077+00	2026-07-21 18:09:05.468077+00	2f01124a-87cc-42c0-aff1-ff0045070c4d	2d6d452d-4915-4793-bf0b-ad7d43798e6f	6b7d47ac-33b3-4bb6-95f6-4e48329d1ce2	employee
d15268bf-8b92-45a9-8fb7-51c6f57caa73	2026-07-21 18:09:05.468077+00	2026-07-21 18:09:05.468077+00	2f01124a-87cc-42c0-aff1-ff0045070c4d	02b5f471-cd3d-47ff-85ad-d22286b9e4b1	6b7d47ac-33b3-4bb6-95f6-4e48329d1ce2	employee
dfa936f0-ff0f-4553-9ea1-640162e234de	2026-07-21 18:09:05.468077+00	2026-07-21 18:09:05.468077+00	2f01124a-87cc-42c0-aff1-ff0045070c4d	3683aa32-1561-4f36-90bf-d6402b4a66d8	6b7d47ac-33b3-4bb6-95f6-4e48329d1ce2	employee
37babe45-7c3b-46c1-8523-902c798140d4	2026-07-21 18:09:05.468077+00	2026-07-21 18:09:05.468077+00	2f01124a-87cc-42c0-aff1-ff0045070c4d	72cdbbe8-b0fe-43f0-ab1a-f11f02a63e1f	6b7d47ac-33b3-4bb6-95f6-4e48329d1ce2	employee
0df05746-3e2d-4201-8ff9-ee28906e5b9f	2026-07-21 18:09:05.468077+00	2026-07-21 18:09:05.468077+00	2f01124a-87cc-42c0-aff1-ff0045070c4d	b4d6dda1-b07b-48aa-b440-b2cbfe40ac0f	6b7d47ac-33b3-4bb6-95f6-4e48329d1ce2	employee
e7b87456-ec50-4e84-ac69-85b317b07a35	2026-07-21 18:09:05.468077+00	2026-07-21 18:09:05.468077+00	2f01124a-87cc-42c0-aff1-ff0045070c4d	c873d894-cb10-4d12-a1dd-f989a1851641	f3a99830-2232-4cb4-9b54-f0b9f85d54b1	project_manager
9e57af4b-a963-46ed-ac03-bdbcbf5ed2cd	2026-07-21 18:09:05.468077+00	2026-07-21 18:09:05.468077+00	2f01124a-87cc-42c0-aff1-ff0045070c4d	00a2a3bf-94c3-4ef6-a94b-bfb72866c1cd	f3a99830-2232-4cb4-9b54-f0b9f85d54b1	employee
cfb2a99d-7098-410e-a06f-24681f0d3017	2026-07-21 18:09:05.468077+00	2026-07-21 18:09:05.468077+00	2f01124a-87cc-42c0-aff1-ff0045070c4d	9d19d89f-4c3d-4d3d-baf1-a4e8898f6a75	f3a99830-2232-4cb4-9b54-f0b9f85d54b1	employee
fbbee25f-71b2-464b-a3b6-bead606bea69	2026-07-21 18:09:05.468077+00	2026-07-21 18:09:05.468077+00	2f01124a-87cc-42c0-aff1-ff0045070c4d	fe42788d-ef87-41ef-8255-9e64e697d040	f3a99830-2232-4cb4-9b54-f0b9f85d54b1	employee
b7fa5d59-2001-462d-b9a9-77c0e8ff8d0a	2026-07-21 18:09:05.468077+00	2026-07-21 18:09:05.468077+00	2f01124a-87cc-42c0-aff1-ff0045070c4d	ae9392d2-7669-44be-a429-889e449b3eb1	f3a99830-2232-4cb4-9b54-f0b9f85d54b1	employee
1d1682fd-10a3-40ad-9915-3d739a420baa	2026-07-21 18:09:05.468077+00	2026-07-21 18:09:05.468077+00	2f01124a-87cc-42c0-aff1-ff0045070c4d	eafb37ce-9111-4c51-91b5-dac320a98501	f3a99830-2232-4cb4-9b54-f0b9f85d54b1	employee
cf320cd9-d6d9-4128-86b8-795d59024f57	2026-07-21 18:09:05.468077+00	2026-07-21 18:09:05.468077+00	2f01124a-87cc-42c0-aff1-ff0045070c4d	47bf13da-40a8-4016-b601-d596b7a29a50	f3a99830-2232-4cb4-9b54-f0b9f85d54b1	employee
1c54ce68-6343-4fa4-8910-4911eb82745e	2026-07-21 18:09:05.468077+00	2026-07-21 18:09:05.468077+00	2f01124a-87cc-42c0-aff1-ff0045070c4d	c873d894-cb10-4d12-a1dd-f989a1851641	1367fc65-98ba-476a-8cdb-8c2bc8411c3b	employee
f0ee2fd5-bac6-4f55-83aa-798a338a0a60	2026-07-21 18:09:05.468077+00	2026-07-21 18:09:05.468077+00	2f01124a-87cc-42c0-aff1-ff0045070c4d	1c04dd92-4377-490c-934c-38244ec68419	6b7d47ac-33b3-4bb6-95f6-4e48329d1ce2	employee
\.


--
-- Data for Name: departments; Type: TABLE DATA; Schema: public; Owner: -
--

COPY public.departments (id, created_at, updated_at, organization_id, name) FROM stdin;
1367fc65-98ba-476a-8cdb-8c2bc8411c3b	2026-07-21 18:09:05.468077+00	2026-07-21 18:09:05.468077+00	2f01124a-87cc-42c0-aff1-ff0045070c4d	مهندسی و فنی
6b7d47ac-33b3-4bb6-95f6-4e48329d1ce2	2026-07-21 18:09:05.468077+00	2026-07-21 18:09:05.468077+00	2f01124a-87cc-42c0-aff1-ff0045070c4d	حسابداری و مالی
f3a99830-2232-4cb4-9b54-f0b9f85d54b1	2026-07-21 18:09:05.468077+00	2026-07-21 18:09:05.468077+00	2f01124a-87cc-42c0-aff1-ff0045070c4d	منابع انسانی
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
1fdd4a4a-ef21-4920-9669-41a21188a9b7	2026-07-21 18:10:55.64753+00	2026-07-21 18:10:55.64753+00	2f01124a-87cc-42c0-aff1-ff0045070c4d	income	درآمد پروژه	#10b981	t
c4e35171-fcc2-408d-b2d2-072661aa5c2b	2026-07-21 18:10:55.64753+00	2026-07-21 18:10:55.64753+00	2f01124a-87cc-42c0-aff1-ff0045070c4d	income	خدمات و مشاوره	#0ea5e9	t
3d88c969-c28f-40f4-afd7-11d67c8587ab	2026-07-21 18:10:55.64753+00	2026-07-21 18:10:55.64753+00	2f01124a-87cc-42c0-aff1-ff0045070c4d	income	سایر درآمدها	#8b5cf6	t
9c7e8cf9-b610-4874-9b50-a2f9ba1743d8	2026-07-21 18:10:55.64753+00	2026-07-21 18:10:55.64753+00	2f01124a-87cc-42c0-aff1-ff0045070c4d	expense	حقوق و دستمزد	#f43f5e	t
de281261-3055-4b2d-800a-b11a592fe390	2026-07-21 18:10:55.64753+00	2026-07-21 18:10:55.64753+00	2f01124a-87cc-42c0-aff1-ff0045070c4d	expense	خورد و خوراک	#f59e0b	t
501897d9-d32f-43f1-8abe-9d17302396c9	2026-07-21 18:10:55.64753+00	2026-07-21 18:10:55.64753+00	2f01124a-87cc-42c0-aff1-ff0045070c4d	expense	اجاره و قبوض	#ef4444	t
2fd8de95-e5bc-4d07-91d0-fa53dd211af3	2026-07-21 18:10:55.64753+00	2026-07-21 18:10:55.64753+00	2f01124a-87cc-42c0-aff1-ff0045070c4d	expense	حمل‌ونقل	#f97316	t
1c16c576-01f2-4a2e-bf7a-56374ae4c680	2026-07-21 18:10:55.64753+00	2026-07-21 18:10:55.64753+00	2f01124a-87cc-42c0-aff1-ff0045070c4d	expense	سایر هزینه‌ها	#64748b	t
\.


--
-- Data for Name: finance_entries; Type: TABLE DATA; Schema: public; Owner: -
--

COPY public.finance_entries (id, created_at, updated_at, organization_id, category_id, project_id, recorded_by_id, entry_type, document_date, amount, title, description, document_number, counterparty) FROM stdin;
6d6d4074-659e-4e7e-a974-3a945481c46f	2026-07-21 18:10:57.366697+00	2026-07-21 18:10:57.366697+00	2f01124a-87cc-42c0-aff1-ff0045070c4d	501897d9-d32f-43f1-8abe-9d17302396c9	\N	e11e2d19-e7e3-4137-b206-b39a072b4754	expense	2026-07-21	1234567.00	Playwright Test Entry	\N	\N	\N
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
شرکت نمونهٔ آزمایشی	demo-org-5ba3a0a4	t	2f01124a-87cc-42c0-aff1-ff0045070c4d	2026-07-21 18:09:05.468077+00	2026-07-21 18:09:05.468077+00
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
76b9e3d7-02ce-47a0-b44b-1226b51aaa87	10b934e7-80e6-41d0-9140-f56d92d614ae	322bab57-c024-4e1a-af7c-82eabfae068a	2026-07-21 18:09:05.468077+00	2026-07-21 18:09:05.468077+00
76b9e3d7-02ce-47a0-b44b-1226b51aaa87	f7d585ca-9137-4691-8979-1d8553a71ed8	2f59d852-60d1-4b71-96f7-79ea2a814ce0	2026-07-21 18:09:05.468077+00	2026-07-21 18:09:05.468077+00
76b9e3d7-02ce-47a0-b44b-1226b51aaa87	1c04dd92-4377-490c-934c-38244ec68419	ea430476-2638-4d01-83a3-5eb6bf2f98c7	2026-07-21 18:09:05.468077+00	2026-07-21 18:09:05.468077+00
76b9e3d7-02ce-47a0-b44b-1226b51aaa87	dfe22c83-6863-413d-97b7-1eb9b52dec02	9ef31cd8-78aa-4e36-b25a-fb5df9c0af76	2026-07-21 18:09:05.468077+00	2026-07-21 18:09:05.468077+00
b1c434b9-f0de-4a84-9df9-97cdceffaccf	10b934e7-80e6-41d0-9140-f56d92d614ae	3f52a0ac-7e29-41df-a0fb-5e39d07f123b	2026-07-21 18:09:05.468077+00	2026-07-21 18:09:05.468077+00
b1c434b9-f0de-4a84-9df9-97cdceffaccf	4e4c6e76-84d5-464d-957c-75ff3e9a2f8a	1b03de30-dd15-474f-9b96-ebd441ba6413	2026-07-21 18:09:05.468077+00	2026-07-21 18:09:05.468077+00
b1c434b9-f0de-4a84-9df9-97cdceffaccf	f7d585ca-9137-4691-8979-1d8553a71ed8	30fa737a-961f-4295-8f61-64d8b0238f6b	2026-07-21 18:09:05.468077+00	2026-07-21 18:09:05.468077+00
b1c434b9-f0de-4a84-9df9-97cdceffaccf	1c04dd92-4377-490c-934c-38244ec68419	4d967426-ca3b-4d52-9e57-93ef83cbb295	2026-07-21 18:09:05.468077+00	2026-07-21 18:09:05.468077+00
ded132eb-db08-429a-81c1-f1a31e3d80fb	10b934e7-80e6-41d0-9140-f56d92d614ae	37a41568-5527-485d-816e-a665e30b8c76	2026-07-21 18:09:05.468077+00	2026-07-21 18:09:05.468077+00
ded132eb-db08-429a-81c1-f1a31e3d80fb	dfe22c83-6863-413d-97b7-1eb9b52dec02	3933a183-13e5-433e-9f37-3401334c9479	2026-07-21 18:09:05.468077+00	2026-07-21 18:09:05.468077+00
ded132eb-db08-429a-81c1-f1a31e3d80fb	de5c1d0c-3ca8-4c75-8525-abcfac9d0651	c353b42f-99be-48a4-83f2-8459e74a1832	2026-07-21 18:09:05.468077+00	2026-07-21 18:09:05.468077+00
ded132eb-db08-429a-81c1-f1a31e3d80fb	1c04dd92-4377-490c-934c-38244ec68419	8ebc8b0b-0dca-490e-8a8a-e4e5f72363ff	2026-07-21 18:09:05.468077+00	2026-07-21 18:09:05.468077+00
70dba40f-b476-4927-8513-6f659d761416	10b934e7-80e6-41d0-9140-f56d92d614ae	a552e074-c14b-4f63-8d77-ae3faee66a68	2026-07-21 18:09:05.468077+00	2026-07-21 18:09:05.468077+00
70dba40f-b476-4927-8513-6f659d761416	4e4c6e76-84d5-464d-957c-75ff3e9a2f8a	0f944cc8-09e0-47fc-b831-40af3ceee8eb	2026-07-21 18:09:05.468077+00	2026-07-21 18:09:05.468077+00
70dba40f-b476-4927-8513-6f659d761416	f7d585ca-9137-4691-8979-1d8553a71ed8	4ef46548-02c6-4144-996e-3162935460fc	2026-07-21 18:09:05.468077+00	2026-07-21 18:09:05.468077+00
70dba40f-b476-4927-8513-6f659d761416	1c04dd92-4377-490c-934c-38244ec68419	04d0d77b-8e56-4e75-b180-5d2c679d36e8	2026-07-21 18:09:05.468077+00	2026-07-21 18:09:05.468077+00
a1110f20-cd7e-4120-bc78-d446d13a5468	10b934e7-80e6-41d0-9140-f56d92d614ae	3ca7fff0-5831-4978-9d38-ac085b3dfedc	2026-07-21 18:09:05.468077+00	2026-07-21 18:09:05.468077+00
a1110f20-cd7e-4120-bc78-d446d13a5468	f7d585ca-9137-4691-8979-1d8553a71ed8	06767a17-f852-402a-a387-20e71c1f15de	2026-07-21 18:09:05.468077+00	2026-07-21 18:09:05.468077+00
a1110f20-cd7e-4120-bc78-d446d13a5468	dfe22c83-6863-413d-97b7-1eb9b52dec02	ec9838cd-9011-4012-9711-3096a41ae2ae	2026-07-21 18:09:05.468077+00	2026-07-21 18:09:05.468077+00
a1110f20-cd7e-4120-bc78-d446d13a5468	de5c1d0c-3ca8-4c75-8525-abcfac9d0651	625cb876-80a4-4bc7-8bd0-b688a5782f51	2026-07-21 18:09:05.468077+00	2026-07-21 18:09:05.468077+00
b439b371-fa49-40be-b62a-cf771b88bb1b	42df4646-393a-4de3-83d6-df4785b690c6	de959420-34be-4afd-883c-fb0a7301ab1f	2026-07-21 18:09:05.468077+00	2026-07-21 18:09:05.468077+00
b439b371-fa49-40be-b62a-cf771b88bb1b	92a3b31d-254e-440b-8bbe-d18db13d73cd	b8e1e209-b976-4c01-b308-d49732c9795b	2026-07-21 18:09:05.468077+00	2026-07-21 18:09:05.468077+00
b439b371-fa49-40be-b62a-cf771b88bb1b	2d6d452d-4915-4793-bf0b-ad7d43798e6f	4f2376f6-1a16-4641-8d41-86765a1512c6	2026-07-21 18:09:05.468077+00	2026-07-21 18:09:05.468077+00
b439b371-fa49-40be-b62a-cf771b88bb1b	02b5f471-cd3d-47ff-85ad-d22286b9e4b1	ae089e3b-d4ff-4e46-b654-80a1e4af1caa	2026-07-21 18:09:05.468077+00	2026-07-21 18:09:05.468077+00
fe2692d0-5164-4138-b8f5-5f7e8a8e7580	42df4646-393a-4de3-83d6-df4785b690c6	f2532c78-d11a-49d6-af83-04177de73f21	2026-07-21 18:09:05.468077+00	2026-07-21 18:09:05.468077+00
fe2692d0-5164-4138-b8f5-5f7e8a8e7580	92a3b31d-254e-440b-8bbe-d18db13d73cd	1e5cf9a0-e3af-4631-a978-fb0f2b18f31c	2026-07-21 18:09:05.468077+00	2026-07-21 18:09:05.468077+00
fe2692d0-5164-4138-b8f5-5f7e8a8e7580	02b5f471-cd3d-47ff-85ad-d22286b9e4b1	bcc49aa5-3d94-4fbc-9d62-4c1813014017	2026-07-21 18:09:05.468077+00	2026-07-21 18:09:05.468077+00
fe2692d0-5164-4138-b8f5-5f7e8a8e7580	72cdbbe8-b0fe-43f0-ab1a-f11f02a63e1f	ea65d801-e9f4-4272-95dc-602fe34f621a	2026-07-21 18:09:05.468077+00	2026-07-21 18:09:05.468077+00
189350e0-cc86-486f-a699-53771a8307c9	42df4646-393a-4de3-83d6-df4785b690c6	ab9a46fd-501c-40be-b005-69af19861ce2	2026-07-21 18:09:05.468077+00	2026-07-21 18:09:05.468077+00
189350e0-cc86-486f-a699-53771a8307c9	02b5f471-cd3d-47ff-85ad-d22286b9e4b1	bfc26cc6-9b32-4041-ba14-fdc3e8698004	2026-07-21 18:09:05.468077+00	2026-07-21 18:09:05.468077+00
189350e0-cc86-486f-a699-53771a8307c9	3683aa32-1561-4f36-90bf-d6402b4a66d8	41f2affa-1d5c-45e8-8af1-f4e1290ec928	2026-07-21 18:09:05.468077+00	2026-07-21 18:09:05.468077+00
189350e0-cc86-486f-a699-53771a8307c9	72cdbbe8-b0fe-43f0-ab1a-f11f02a63e1f	befae822-7e6a-43ec-af54-4fd534e621a6	2026-07-21 18:09:05.468077+00	2026-07-21 18:09:05.468077+00
7ccce913-5c45-45ec-a44c-1c50c45bb193	42df4646-393a-4de3-83d6-df4785b690c6	eb5bc1f4-69c7-468d-a9e2-6081214ae49b	2026-07-21 18:09:05.468077+00	2026-07-21 18:09:05.468077+00
7ccce913-5c45-45ec-a44c-1c50c45bb193	02b5f471-cd3d-47ff-85ad-d22286b9e4b1	9f8e5432-3a45-483e-bb44-19c5c2e1b634	2026-07-21 18:09:05.468077+00	2026-07-21 18:09:05.468077+00
7ccce913-5c45-45ec-a44c-1c50c45bb193	2d6d452d-4915-4793-bf0b-ad7d43798e6f	cd38656a-5af0-4757-b63b-d238d833829e	2026-07-21 18:09:05.468077+00	2026-07-21 18:09:05.468077+00
7ccce913-5c45-45ec-a44c-1c50c45bb193	3683aa32-1561-4f36-90bf-d6402b4a66d8	c098ad38-c520-428f-b437-7f8304eeb749	2026-07-21 18:09:05.468077+00	2026-07-21 18:09:05.468077+00
865b2901-75dd-4a80-bdb3-bb9cd38f1b68	42df4646-393a-4de3-83d6-df4785b690c6	329eb721-edfd-4aa6-a754-2c771f5a9a7d	2026-07-21 18:09:05.468077+00	2026-07-21 18:09:05.468077+00
865b2901-75dd-4a80-bdb3-bb9cd38f1b68	72cdbbe8-b0fe-43f0-ab1a-f11f02a63e1f	0a23a5be-fdca-45f6-9914-d7b49a17a921	2026-07-21 18:09:05.468077+00	2026-07-21 18:09:05.468077+00
865b2901-75dd-4a80-bdb3-bb9cd38f1b68	02b5f471-cd3d-47ff-85ad-d22286b9e4b1	249c059f-3d32-4939-b3e6-604efbdbbb82	2026-07-21 18:09:05.468077+00	2026-07-21 18:09:05.468077+00
865b2901-75dd-4a80-bdb3-bb9cd38f1b68	92a3b31d-254e-440b-8bbe-d18db13d73cd	9cc8566d-52de-4cf7-8b9b-7108b002210a	2026-07-21 18:09:05.468077+00	2026-07-21 18:09:05.468077+00
0901f3f3-057f-4aae-bf11-9639f3ee3dd4	c873d894-cb10-4d12-a1dd-f989a1851641	e422c58c-175a-4024-a83f-209336a390eb	2026-07-21 18:09:05.468077+00	2026-07-21 18:09:05.468077+00
0901f3f3-057f-4aae-bf11-9639f3ee3dd4	eafb37ce-9111-4c51-91b5-dac320a98501	af1293a4-8376-42ff-a81d-9e073a5835f0	2026-07-21 18:09:05.468077+00	2026-07-21 18:09:05.468077+00
0901f3f3-057f-4aae-bf11-9639f3ee3dd4	9d19d89f-4c3d-4d3d-baf1-a4e8898f6a75	4a6cc0ad-c433-47fa-8387-2df38c08d2de	2026-07-21 18:09:05.468077+00	2026-07-21 18:09:05.468077+00
0901f3f3-057f-4aae-bf11-9639f3ee3dd4	47bf13da-40a8-4016-b601-d596b7a29a50	dd1da790-f530-47dd-8afc-90e8912b5787	2026-07-21 18:09:05.468077+00	2026-07-21 18:09:05.468077+00
714a6340-704b-4e08-8b30-4d9baafcb45c	c873d894-cb10-4d12-a1dd-f989a1851641	2b68337e-a11a-41c7-9c16-fb59655cdb9a	2026-07-21 18:09:05.468077+00	2026-07-21 18:09:05.468077+00
714a6340-704b-4e08-8b30-4d9baafcb45c	fe42788d-ef87-41ef-8255-9e64e697d040	89148bc4-5f7a-4668-8ded-1a34af799b24	2026-07-21 18:09:05.468077+00	2026-07-21 18:09:05.468077+00
714a6340-704b-4e08-8b30-4d9baafcb45c	9d19d89f-4c3d-4d3d-baf1-a4e8898f6a75	bce70532-1622-4501-bd17-87c8c3cd874f	2026-07-21 18:09:05.468077+00	2026-07-21 18:09:05.468077+00
714a6340-704b-4e08-8b30-4d9baafcb45c	ae9392d2-7669-44be-a429-889e449b3eb1	378387b8-ee3d-421f-a579-44574a2e555a	2026-07-21 18:09:05.468077+00	2026-07-21 18:09:05.468077+00
4ceaa4b3-563d-4465-b395-a62490d00060	c873d894-cb10-4d12-a1dd-f989a1851641	6e1cacfc-4a4f-4a58-b4ff-4ee0875d41f5	2026-07-21 18:09:05.468077+00	2026-07-21 18:09:05.468077+00
4ceaa4b3-563d-4465-b395-a62490d00060	00a2a3bf-94c3-4ef6-a94b-bfb72866c1cd	996f4ec0-b4d7-4e0d-a4dd-ab9bfb530329	2026-07-21 18:09:05.468077+00	2026-07-21 18:09:05.468077+00
4ceaa4b3-563d-4465-b395-a62490d00060	9d19d89f-4c3d-4d3d-baf1-a4e8898f6a75	9a3d25c5-74d9-40e6-a8d1-3308a388f111	2026-07-21 18:09:05.468077+00	2026-07-21 18:09:05.468077+00
4ceaa4b3-563d-4465-b395-a62490d00060	eafb37ce-9111-4c51-91b5-dac320a98501	8ec72bec-9937-48a8-a636-9689fda889c7	2026-07-21 18:09:05.468077+00	2026-07-21 18:09:05.468077+00
9af7d195-e857-469f-8432-97a00100cd49	c873d894-cb10-4d12-a1dd-f989a1851641	97afb444-c04e-40e4-9a00-5c912944efe9	2026-07-21 18:09:05.468077+00	2026-07-21 18:09:05.468077+00
9af7d195-e857-469f-8432-97a00100cd49	ae9392d2-7669-44be-a429-889e449b3eb1	05811da0-ac5a-47c9-b447-597167512341	2026-07-21 18:09:05.468077+00	2026-07-21 18:09:05.468077+00
9af7d195-e857-469f-8432-97a00100cd49	00a2a3bf-94c3-4ef6-a94b-bfb72866c1cd	5820d8ae-fbc7-42aa-8a4d-d8b30e468abd	2026-07-21 18:09:05.468077+00	2026-07-21 18:09:05.468077+00
9af7d195-e857-469f-8432-97a00100cd49	fe42788d-ef87-41ef-8255-9e64e697d040	3975d956-b212-47bf-8ed1-8a9947710bcd	2026-07-21 18:09:05.468077+00	2026-07-21 18:09:05.468077+00
f84f219e-7c01-44ff-bc62-1ee898da0737	c873d894-cb10-4d12-a1dd-f989a1851641	6d784e1c-0c35-4a59-8e2a-640f5635ed9c	2026-07-21 18:09:05.468077+00	2026-07-21 18:09:05.468077+00
f84f219e-7c01-44ff-bc62-1ee898da0737	9d19d89f-4c3d-4d3d-baf1-a4e8898f6a75	173c1706-e904-418f-b3a2-ad7a6e727fe8	2026-07-21 18:09:05.468077+00	2026-07-21 18:09:05.468077+00
f84f219e-7c01-44ff-bc62-1ee898da0737	fe42788d-ef87-41ef-8255-9e64e697d040	f348fce5-ab27-44fe-8483-10ffd7b2f4c0	2026-07-21 18:09:05.468077+00	2026-07-21 18:09:05.468077+00
f84f219e-7c01-44ff-bc62-1ee898da0737	47bf13da-40a8-4016-b601-d596b7a29a50	f00557b0-5315-46a1-a77d-fc4a17b814bb	2026-07-21 18:09:05.468077+00	2026-07-21 18:09:05.468077+00
\.


--
-- Data for Name: projects; Type: TABLE DATA; Schema: public; Owner: -
--

COPY public.projects (organization_id, name, description, start_date, end_date, status, created_by_id, id, created_at, updated_at, manager_id, department_id) FROM stdin;
2f01124a-87cc-42c0-aff1-ff0045070c4d	بازطراحی وب‌سایت شرکتی	پروژهٔ مهندسی و فنی شماره 1	2026-06-01	2026-08-16	active	e11e2d19-e7e3-4137-b206-b39a072b4754	76b9e3d7-02ce-47a0-b44b-1226b51aaa87	2026-07-21 18:09:05.468077+00	2026-07-21 18:09:05.468077+00	10b934e7-80e6-41d0-9140-f56d92d614ae	1367fc65-98ba-476a-8cdb-8c2bc8411c3b
2f01124a-87cc-42c0-aff1-ff0045070c4d	توسعهٔ اپلیکیشن موبایل فروش	پروژهٔ مهندسی و فنی شماره 2	2026-04-28	2026-06-23	active	e11e2d19-e7e3-4137-b206-b39a072b4754	b1c434b9-f0de-4a84-9df9-97cdceffaccf	2026-07-21 18:09:05.468077+00	2026-07-21 18:09:05.468077+00	10b934e7-80e6-41d0-9140-f56d92d614ae	1367fc65-98ba-476a-8cdb-8c2bc8411c3b
2f01124a-87cc-42c0-aff1-ff0045070c4d	مهاجرت زیرساخت به ابر	پروژهٔ مهندسی و فنی شماره 3	2026-07-03	2026-08-28	active	e11e2d19-e7e3-4137-b206-b39a072b4754	ded132eb-db08-429a-81c1-f1a31e3d80fb	2026-07-21 18:09:05.468077+00	2026-07-21 18:09:05.468077+00	10b934e7-80e6-41d0-9140-f56d92d614ae	1367fc65-98ba-476a-8cdb-8c2bc8411c3b
2f01124a-87cc-42c0-aff1-ff0045070c4d	پیاده‌سازی سامانهٔ مانیتورینگ	پروژهٔ مهندسی و فنی شماره 4	2026-04-26	2026-07-05	active	e11e2d19-e7e3-4137-b206-b39a072b4754	70dba40f-b476-4927-8513-6f659d761416	2026-07-21 18:09:05.468077+00	2026-07-21 18:09:05.468077+00	10b934e7-80e6-41d0-9140-f56d92d614ae	1367fc65-98ba-476a-8cdb-8c2bc8411c3b
2f01124a-87cc-42c0-aff1-ff0045070c4d	بهبود عملکرد پایگاه‌داده	پروژهٔ مهندسی و فنی شماره 5	2026-06-08	2026-09-18	active	e11e2d19-e7e3-4137-b206-b39a072b4754	a1110f20-cd7e-4120-bc78-d446d13a5468	2026-07-21 18:09:05.468077+00	2026-07-21 18:09:05.468077+00	10b934e7-80e6-41d0-9140-f56d92d614ae	1367fc65-98ba-476a-8cdb-8c2bc8411c3b
2f01124a-87cc-42c0-aff1-ff0045070c4d	بستن حساب‌های مالی سال	پروژهٔ حسابداری و مالی شماره 1	2026-05-22	2026-10-13	active	e11e2d19-e7e3-4137-b206-b39a072b4754	b439b371-fa49-40be-b62a-cf771b88bb1b	2026-07-21 18:09:05.468077+00	2026-07-21 18:09:05.468077+00	42df4646-393a-4de3-83d6-df4785b690c6	6b7d47ac-33b3-4bb6-95f6-4e48329d1ce2
2f01124a-87cc-42c0-aff1-ff0045070c4d	پیاده‌سازی سامانهٔ فاکتور الکترونیک	پروژهٔ حسابداری و مالی شماره 2	2026-06-21	2026-11-15	active	e11e2d19-e7e3-4137-b206-b39a072b4754	fe2692d0-5164-4138-b8f5-5f7e8a8e7580	2026-07-21 18:09:05.468077+00	2026-07-21 18:09:05.468077+00	42df4646-393a-4de3-83d6-df4785b690c6	6b7d47ac-33b3-4bb6-95f6-4e48329d1ce2
2f01124a-87cc-42c0-aff1-ff0045070c4d	ممیزی مالی سه‌ماههٔ دوم	پروژهٔ حسابداری و مالی شماره 3	2026-05-11	2026-08-13	active	e11e2d19-e7e3-4137-b206-b39a072b4754	189350e0-cc86-486f-a699-53771a8307c9	2026-07-21 18:09:05.468077+00	2026-07-21 18:09:05.468077+00	42df4646-393a-4de3-83d6-df4785b690c6	6b7d47ac-33b3-4bb6-95f6-4e48329d1ce2
2f01124a-87cc-42c0-aff1-ff0045070c4d	تدوین بودجهٔ سال آینده	پروژهٔ حسابداری و مالی شماره 4	2026-05-04	2026-08-04	active	e11e2d19-e7e3-4137-b206-b39a072b4754	7ccce913-5c45-45ec-a44c-1c50c45bb193	2026-07-21 18:09:05.468077+00	2026-07-21 18:09:05.468077+00	42df4646-393a-4de3-83d6-df4785b690c6	6b7d47ac-33b3-4bb6-95f6-4e48329d1ce2
2f01124a-87cc-42c0-aff1-ff0045070c4d	مدیریت مطالبات و بدهی‌ها	پروژهٔ حسابداری و مالی شماره 5	2026-05-13	2026-07-07	active	e11e2d19-e7e3-4137-b206-b39a072b4754	865b2901-75dd-4a80-bdb3-bb9cd38f1b68	2026-07-21 18:09:05.468077+00	2026-07-21 18:09:05.468077+00	42df4646-393a-4de3-83d6-df4785b690c6	6b7d47ac-33b3-4bb6-95f6-4e48329d1ce2
2f01124a-87cc-42c0-aff1-ff0045070c4d	برگزاری دورهٔ آموزشی کارکنان	پروژهٔ منابع انسانی شماره 1	2026-05-04	2026-08-26	active	e11e2d19-e7e3-4137-b206-b39a072b4754	0901f3f3-057f-4aae-bf11-9639f3ee3dd4	2026-07-21 18:09:05.468077+00	2026-07-21 18:09:05.468077+00	c873d894-cb10-4d12-a1dd-f989a1851641	f3a99830-2232-4cb4-9b54-f0b9f85d54b1
2f01124a-87cc-42c0-aff1-ff0045070c4d	بازطراحی فرایند جذب و استخدام	پروژهٔ منابع انسانی شماره 2	2026-07-02	2026-08-27	active	e11e2d19-e7e3-4137-b206-b39a072b4754	714a6340-704b-4e08-8b30-4d9baafcb45c	2026-07-21 18:09:05.468077+00	2026-07-21 18:09:05.468077+00	c873d894-cb10-4d12-a1dd-f989a1851641	f3a99830-2232-4cb4-9b54-f0b9f85d54b1
2f01124a-87cc-42c0-aff1-ff0045070c4d	ارزیابی عملکرد سالانهٔ کارکنان	پروژهٔ منابع انسانی شماره 3	2026-07-04	2026-10-24	active	e11e2d19-e7e3-4137-b206-b39a072b4754	4ceaa4b3-563d-4465-b395-a62490d00060	2026-07-21 18:09:05.468077+00	2026-07-21 18:09:05.468077+00	c873d894-cb10-4d12-a1dd-f989a1851641	f3a99830-2232-4cb4-9b54-f0b9f85d54b1
2f01124a-87cc-42c0-aff1-ff0045070c4d	طراحی برنامهٔ رفاهی کارکنان	پروژهٔ منابع انسانی شماره 4	2026-04-19	2026-06-28	active	e11e2d19-e7e3-4137-b206-b39a072b4754	9af7d195-e857-469f-8432-97a00100cd49	2026-07-21 18:09:05.468077+00	2026-07-21 18:09:05.468077+00	c873d894-cb10-4d12-a1dd-f989a1851641	f3a99830-2232-4cb4-9b54-f0b9f85d54b1
2f01124a-87cc-42c0-aff1-ff0045070c4d	پیاده‌سازی سامانهٔ حضور و غیاب	پروژهٔ منابع انسانی شماره 5	2026-05-26	2026-07-17	active	e11e2d19-e7e3-4137-b206-b39a072b4754	f84f219e-7c01-44ff-bc62-1ee898da0737	2026-07-21 18:09:05.468077+00	2026-07-21 18:09:05.468077+00	c873d894-cb10-4d12-a1dd-f989a1851641	f3a99830-2232-4cb4-9b54-f0b9f85d54b1
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
2f01124a-87cc-42c0-aff1-ff0045070c4d	76b9e3d7-02ce-47a0-b44b-1226b51aaa87	\N	de5c1d0c-3ca8-4c75-8525-abcfac9d0651	10b934e7-80e6-41d0-9140-f56d92d614ae	رفع مشکل ناسازگاری مرورگر #1	\N	low	2026-08-08	d1b1ebba-cfa9-4b3c-ae5c-bf43282aaedc	2026-07-21 18:09:05.468077+00	2026-07-21 18:09:05.468077+00	in_progress	\N	54	14.90	2026-08-06	medium
2f01124a-87cc-42c0-aff1-ff0045070c4d	76b9e3d7-02ce-47a0-b44b-1226b51aaa87	\N	1c04dd92-4377-490c-934c-38244ec68419	10b934e7-80e6-41d0-9140-f56d92d614ae	پیاده‌سازی صفحهٔ ورود جدید #2	\N	low	2026-08-15	e2bcaf1f-b740-43bd-9419-dcbb02e084b9	2026-07-21 18:09:05.468077+00	2026-07-21 18:09:05.468077+00	in_progress	\N	48	5.70	2026-08-03	medium
2f01124a-87cc-42c0-aff1-ff0045070c4d	76b9e3d7-02ce-47a0-b44b-1226b51aaa87	\N	f7d585ca-9137-4691-8979-1d8553a71ed8	10b934e7-80e6-41d0-9140-f56d92d614ae	رفع مشکل ناسازگاری مرورگر #3	\N	low	2026-08-03	2a24cbb5-3133-485b-be41-4a98899232bd	2026-07-21 18:09:05.468077+00	2026-07-21 18:09:05.468077+00	in_progress	\N	58	22.40	2026-07-24	medium
2f01124a-87cc-42c0-aff1-ff0045070c4d	76b9e3d7-02ce-47a0-b44b-1226b51aaa87	\N	0aa2e3a9-85b6-420a-aeeb-62f6f7061c6c	10b934e7-80e6-41d0-9140-f56d92d614ae	بازنویسی ماژول اعلان‌ها #4	\N	high	2026-08-01	95fb449e-beb8-4626-a3c5-8eab0a5851b6	2026-07-21 18:09:05.468077+00	2026-07-21 18:09:05.468077+00	todo	\N	79	35.60	2026-07-21	medium
2f01124a-87cc-42c0-aff1-ff0045070c4d	76b9e3d7-02ce-47a0-b44b-1226b51aaa87	\N	4e4c6e76-84d5-464d-957c-75ff3e9a2f8a	10b934e7-80e6-41d0-9140-f56d92d614ae	تنظیم پایپ‌لاین CI/CD #5	\N	low	2026-06-23	98717e46-4139-4b31-933d-cafc2c1aafbe	2026-07-21 18:09:05.468077+00	2026-07-21 18:09:05.468077+00	completed	approved	100	31.40	2026-06-20	medium
2f01124a-87cc-42c0-aff1-ff0045070c4d	76b9e3d7-02ce-47a0-b44b-1226b51aaa87	\N	10b934e7-80e6-41d0-9140-f56d92d614ae	10b934e7-80e6-41d0-9140-f56d92d614ae	پیاده‌سازی احراز هویت دومرحله‌ای #6	\N	medium	2026-08-15	1c14d9da-8383-4040-bca3-a1f44c88fa6c	2026-07-21 18:09:05.468077+00	2026-07-21 18:09:05.468077+00	in_progress	\N	58	26.20	2026-08-10	medium
2f01124a-87cc-42c0-aff1-ff0045070c4d	76b9e3d7-02ce-47a0-b44b-1226b51aaa87	\N	4e4c6e76-84d5-464d-957c-75ff3e9a2f8a	10b934e7-80e6-41d0-9140-f56d92d614ae	افزودن تست واحد برای سرویس کاربران #7	\N	high	2026-07-22	cfd26939-c7c8-44d2-97e4-8b8e8bc65bfb	2026-07-21 18:09:05.468077+00	2026-07-21 18:09:05.468077+00	todo	\N	34	28.70	2026-07-09	medium
2f01124a-87cc-42c0-aff1-ff0045070c4d	76b9e3d7-02ce-47a0-b44b-1226b51aaa87	\N	dfe22c83-6863-413d-97b7-1eb9b52dec02	10b934e7-80e6-41d0-9140-f56d92d614ae	به‌روزرسانی کتابخانه‌های وابسته #8	\N	high	2026-08-02	27a443ff-7664-4e4c-8940-a091314af277	2026-07-21 18:09:05.468077+00	2026-07-21 18:09:05.468077+00	completed	approved	100	11.30	2026-07-26	medium
2f01124a-87cc-42c0-aff1-ff0045070c4d	76b9e3d7-02ce-47a0-b44b-1226b51aaa87	\N	0aa2e3a9-85b6-420a-aeeb-62f6f7061c6c	10b934e7-80e6-41d0-9140-f56d92d614ae	افزودن تست واحد برای سرویس کاربران #9	\N	high	2026-07-22	ba701b08-bb12-4c36-a0bf-5edbfe3eaa00	2026-07-21 18:09:05.468077+00	2026-07-21 18:09:05.468077+00	in_progress	\N	41	34.00	2026-07-03	medium
2f01124a-87cc-42c0-aff1-ff0045070c4d	76b9e3d7-02ce-47a0-b44b-1226b51aaa87	\N	f7d585ca-9137-4691-8979-1d8553a71ed8	10b934e7-80e6-41d0-9140-f56d92d614ae	رفع مشکل ناسازگاری مرورگر #10	\N	medium	2026-07-03	e237b0df-583b-42e3-b4b5-6ccb804911b7	2026-07-21 18:09:05.468077+00	2026-07-21 18:09:05.468077+00	todo	\N	51	12.20	2026-06-30	medium
2f01124a-87cc-42c0-aff1-ff0045070c4d	76b9e3d7-02ce-47a0-b44b-1226b51aaa87	\N	1c04dd92-4377-490c-934c-38244ec68419	10b934e7-80e6-41d0-9140-f56d92d614ae	تنظیم پایپ‌لاین CI/CD #11	\N	medium	2026-07-14	d523f5bd-9554-49ed-a39e-f40f4055e9f8	2026-07-21 18:09:05.468077+00	2026-07-21 18:09:05.468077+00	completed	pending	100	17.00	2026-07-06	medium
2f01124a-87cc-42c0-aff1-ff0045070c4d	76b9e3d7-02ce-47a0-b44b-1226b51aaa87	\N	dfe22c83-6863-413d-97b7-1eb9b52dec02	10b934e7-80e6-41d0-9140-f56d92d614ae	نوشتن مستندات فنی API #12	\N	high	2026-07-03	f7835816-383f-4d5b-bd80-a64954fef7f6	2026-07-21 18:09:05.468077+00	2026-07-21 18:09:05.468077+00	completed	approved	100	22.50	2026-06-24	medium
2f01124a-87cc-42c0-aff1-ff0045070c4d	76b9e3d7-02ce-47a0-b44b-1226b51aaa87	\N	dfe22c83-6863-413d-97b7-1eb9b52dec02	10b934e7-80e6-41d0-9140-f56d92d614ae	رفع مشکل کندی بارگذاری صفحه #13	\N	low	2026-08-06	a1029593-638b-45fe-b60d-65aba9477bea	2026-07-21 18:09:05.468077+00	2026-07-21 18:09:05.468077+00	completed	approved	100	39.90	2026-07-23	medium
2f01124a-87cc-42c0-aff1-ff0045070c4d	76b9e3d7-02ce-47a0-b44b-1226b51aaa87	\N	1c04dd92-4377-490c-934c-38244ec68419	10b934e7-80e6-41d0-9140-f56d92d614ae	بازنویسی ماژول اعلان‌ها #14	\N	low	2026-08-06	a40a55a6-8890-42ba-b09b-5982044bca6f	2026-07-21 18:09:05.468077+00	2026-07-21 18:09:05.468077+00	completed	approved	100	7.80	2026-08-03	medium
2f01124a-87cc-42c0-aff1-ff0045070c4d	76b9e3d7-02ce-47a0-b44b-1226b51aaa87	\N	1c04dd92-4377-490c-934c-38244ec68419	10b934e7-80e6-41d0-9140-f56d92d614ae	پیاده‌سازی احراز هویت دومرحله‌ای #15	\N	high	2026-07-04	a5e4a2ee-f5ea-4d32-817b-0d43a9ab79e5	2026-07-21 18:09:05.468077+00	2026-07-21 18:09:05.468077+00	completed	approved	100	39.90	2026-06-20	medium
2f01124a-87cc-42c0-aff1-ff0045070c4d	76b9e3d7-02ce-47a0-b44b-1226b51aaa87	\N	de5c1d0c-3ca8-4c75-8525-abcfac9d0651	10b934e7-80e6-41d0-9140-f56d92d614ae	تنظیم پایپ‌لاین CI/CD #16	\N	high	2026-07-23	193beec1-e45a-4908-9524-f6693a4453ef	2026-07-21 18:09:05.468077+00	2026-07-21 18:09:05.468077+00	in_progress	\N	14	27.90	2026-07-21	medium
2f01124a-87cc-42c0-aff1-ff0045070c4d	76b9e3d7-02ce-47a0-b44b-1226b51aaa87	\N	de5c1d0c-3ca8-4c75-8525-abcfac9d0651	10b934e7-80e6-41d0-9140-f56d92d614ae	پیاده‌سازی صفحهٔ ورود جدید #17	\N	medium	2026-07-15	376f9ed3-827e-45ed-a5ad-d0f1914e1d00	2026-07-21 18:09:05.468077+00	2026-07-21 18:09:05.468077+00	archived	\N	55	8.00	2026-07-03	medium
2f01124a-87cc-42c0-aff1-ff0045070c4d	76b9e3d7-02ce-47a0-b44b-1226b51aaa87	\N	10b934e7-80e6-41d0-9140-f56d92d614ae	10b934e7-80e6-41d0-9140-f56d92d614ae	به‌روزرسانی کتابخانه‌های وابسته #18	\N	low	2026-08-21	9634bc54-80f3-48fa-a08d-f01b776c6bc0	2026-07-21 18:09:05.468077+00	2026-07-21 18:09:05.468077+00	archived	\N	64	36.70	2026-08-11	medium
2f01124a-87cc-42c0-aff1-ff0045070c4d	b1c434b9-f0de-4a84-9df9-97cdceffaccf	\N	f7d585ca-9137-4691-8979-1d8553a71ed8	10b934e7-80e6-41d0-9140-f56d92d614ae	پیاده‌سازی صفحهٔ داشبورد مدیریتی #19	\N	low	2026-08-13	bf9a4fe9-52cc-43eb-83b3-cbba6dcef891	2026-07-21 18:09:05.468077+00	2026-07-21 18:09:05.468077+00	completed	approved	100	7.80	2026-07-26	medium
2f01124a-87cc-42c0-aff1-ff0045070c4d	b1c434b9-f0de-4a84-9df9-97cdceffaccf	\N	f7d585ca-9137-4691-8979-1d8553a71ed8	10b934e7-80e6-41d0-9140-f56d92d614ae	افزودن قابلیت جست‌وجوی پیشرفته #20	\N	low	2026-08-07	ce35d602-c33d-432b-b79b-78ee90a5bffd	2026-07-21 18:09:05.468077+00	2026-07-21 18:09:05.468077+00	todo	\N	76	14.30	2026-07-20	medium
2f01124a-87cc-42c0-aff1-ff0045070c4d	b1c434b9-f0de-4a84-9df9-97cdceffaccf	\N	10b934e7-80e6-41d0-9140-f56d92d614ae	10b934e7-80e6-41d0-9140-f56d92d614ae	افزودن قابلیت جست‌وجوی پیشرفته #21	\N	medium	2026-08-27	04df804a-038d-4bc8-92fc-bf8ffcb6eac0	2026-07-21 18:09:05.468077+00	2026-07-21 18:09:05.468077+00	todo	\N	30	4.20	2026-08-14	medium
2f01124a-87cc-42c0-aff1-ff0045070c4d	b1c434b9-f0de-4a84-9df9-97cdceffaccf	\N	de5c1d0c-3ca8-4c75-8525-abcfac9d0651	10b934e7-80e6-41d0-9140-f56d92d614ae	بازنویسی ماژول اعلان‌ها #22	\N	low	2026-07-08	a82c375f-7a51-4578-8ccc-ce7e2b67aa55	2026-07-21 18:09:05.468077+00	2026-07-21 18:09:05.468077+00	todo	\N	68	31.10	2026-06-21	medium
2f01124a-87cc-42c0-aff1-ff0045070c4d	b1c434b9-f0de-4a84-9df9-97cdceffaccf	\N	1c04dd92-4377-490c-934c-38244ec68419	10b934e7-80e6-41d0-9140-f56d92d614ae	طراحی API نسخهٔ دوم #23	\N	high	2026-07-28	299066b5-19d2-4965-b65e-39e74174a939	2026-07-21 18:09:05.468077+00	2026-07-21 18:09:05.468077+00	completed	approved	100	35.20	2026-07-21	medium
2f01124a-87cc-42c0-aff1-ff0045070c4d	b1c434b9-f0de-4a84-9df9-97cdceffaccf	\N	0aa2e3a9-85b6-420a-aeeb-62f6f7061c6c	10b934e7-80e6-41d0-9140-f56d92d614ae	رفع مشکل ناسازگاری مرورگر #24	\N	high	2026-09-02	e613c28f-b932-44d5-b5ad-938e77d55bfc	2026-07-21 18:09:05.468077+00	2026-07-21 18:09:05.468077+00	in_progress	\N	25	29.10	2026-08-14	medium
2f01124a-87cc-42c0-aff1-ff0045070c4d	b1c434b9-f0de-4a84-9df9-97cdceffaccf	\N	0aa2e3a9-85b6-420a-aeeb-62f6f7061c6c	10b934e7-80e6-41d0-9140-f56d92d614ae	بررسی و رفع آسیب‌پذیری امنیتی #25	\N	low	2026-08-01	9f6a2f55-6c3b-4a86-ada0-aa8950d23fd6	2026-07-21 18:09:05.468077+00	2026-07-21 18:09:05.468077+00	completed	pending	100	11.40	2026-07-14	medium
2f01124a-87cc-42c0-aff1-ff0045070c4d	b1c434b9-f0de-4a84-9df9-97cdceffaccf	\N	10b934e7-80e6-41d0-9140-f56d92d614ae	10b934e7-80e6-41d0-9140-f56d92d614ae	به‌روزرسانی کتابخانه‌های وابسته #26	\N	low	2026-07-07	95f905ef-a29f-4038-9ff4-35148aa51a9b	2026-07-21 18:09:05.468077+00	2026-07-21 18:09:05.468077+00	in_progress	\N	75	10.40	2026-06-17	medium
2f01124a-87cc-42c0-aff1-ff0045070c4d	b1c434b9-f0de-4a84-9df9-97cdceffaccf	\N	10b934e7-80e6-41d0-9140-f56d92d614ae	10b934e7-80e6-41d0-9140-f56d92d614ae	افزودن تست واحد برای سرویس کاربران #27	\N	low	2026-07-29	ef2eb54b-439d-4b3a-87ef-775fca206242	2026-07-21 18:09:05.468077+00	2026-07-21 18:09:05.468077+00	archived	\N	4	34.70	2026-07-26	medium
2f01124a-87cc-42c0-aff1-ff0045070c4d	b1c434b9-f0de-4a84-9df9-97cdceffaccf	\N	10b934e7-80e6-41d0-9140-f56d92d614ae	10b934e7-80e6-41d0-9140-f56d92d614ae	افزودن تست واحد برای سرویس کاربران #28	\N	high	2026-08-14	363ab848-bd12-4ddb-8a40-993a72b21f80	2026-07-21 18:09:05.468077+00	2026-07-21 18:09:05.468077+00	completed	approved	100	7.00	2026-07-28	medium
2f01124a-87cc-42c0-aff1-ff0045070c4d	b1c434b9-f0de-4a84-9df9-97cdceffaccf	\N	de5c1d0c-3ca8-4c75-8525-abcfac9d0651	10b934e7-80e6-41d0-9140-f56d92d614ae	رفع مشکل ناسازگاری مرورگر #29	\N	medium	2026-08-22	80f4279c-4962-4a24-b033-bb806f298fdd	2026-07-21 18:09:05.468077+00	2026-07-21 18:09:05.468077+00	completed	approved	100	9.20	2026-08-05	medium
2f01124a-87cc-42c0-aff1-ff0045070c4d	b1c434b9-f0de-4a84-9df9-97cdceffaccf	\N	10b934e7-80e6-41d0-9140-f56d92d614ae	10b934e7-80e6-41d0-9140-f56d92d614ae	بررسی و رفع آسیب‌پذیری امنیتی #30	\N	high	2026-07-28	cb566c53-c7e0-40b7-ad35-79a17d76d3a3	2026-07-21 18:09:05.468077+00	2026-07-21 18:09:05.468077+00	completed	approved	100	4.10	2026-07-13	medium
2f01124a-87cc-42c0-aff1-ff0045070c4d	b1c434b9-f0de-4a84-9df9-97cdceffaccf	\N	dfe22c83-6863-413d-97b7-1eb9b52dec02	10b934e7-80e6-41d0-9140-f56d92d614ae	رفع مشکل ناسازگاری مرورگر #31	\N	low	2026-07-23	159b99bf-9b12-4eab-9f60-212fb5cb1b17	2026-07-21 18:09:05.468077+00	2026-07-21 18:09:05.468077+00	completed	approved	100	11.40	2026-07-11	medium
2f01124a-87cc-42c0-aff1-ff0045070c4d	b1c434b9-f0de-4a84-9df9-97cdceffaccf	\N	1c04dd92-4377-490c-934c-38244ec68419	10b934e7-80e6-41d0-9140-f56d92d614ae	طراحی API نسخهٔ دوم #32	\N	medium	2026-07-20	a4c56237-4928-4229-b39f-e66e22a0948c	2026-07-21 18:09:05.468077+00	2026-07-21 18:09:05.468077+00	completed	approved	100	11.50	2026-07-13	medium
2f01124a-87cc-42c0-aff1-ff0045070c4d	b1c434b9-f0de-4a84-9df9-97cdceffaccf	\N	10b934e7-80e6-41d0-9140-f56d92d614ae	10b934e7-80e6-41d0-9140-f56d92d614ae	پیاده‌سازی صفحهٔ ورود جدید #33	\N	low	2026-08-28	d0eaf4fe-63c9-4db7-9008-ea111da82324	2026-07-21 18:09:05.468077+00	2026-07-21 18:09:05.468077+00	completed	pending	100	26.80	2026-08-09	medium
2f01124a-87cc-42c0-aff1-ff0045070c4d	b1c434b9-f0de-4a84-9df9-97cdceffaccf	\N	de5c1d0c-3ca8-4c75-8525-abcfac9d0651	10b934e7-80e6-41d0-9140-f56d92d614ae	بهینه‌سازی کوئری‌های گزارش‌گیری #34	\N	medium	2026-06-30	a55725d0-85da-4188-8905-70443c69dab4	2026-07-21 18:09:05.468077+00	2026-07-21 18:09:05.468077+00	todo	\N	62	20.30	2026-06-21	medium
2f01124a-87cc-42c0-aff1-ff0045070c4d	b1c434b9-f0de-4a84-9df9-97cdceffaccf	\N	f7d585ca-9137-4691-8979-1d8553a71ed8	10b934e7-80e6-41d0-9140-f56d92d614ae	بهینه‌سازی کوئری‌های گزارش‌گیری #35	\N	medium	2026-08-15	1fb55dc6-b67c-46e0-b25e-818a9b2b4cdf	2026-07-21 18:09:05.468077+00	2026-07-21 18:09:05.468077+00	in_progress	\N	0	39.40	2026-08-12	medium
2f01124a-87cc-42c0-aff1-ff0045070c4d	b1c434b9-f0de-4a84-9df9-97cdceffaccf	\N	4e4c6e76-84d5-464d-957c-75ff3e9a2f8a	10b934e7-80e6-41d0-9140-f56d92d614ae	تنظیم پایپ‌لاین CI/CD #36	\N	high	2026-08-18	b31b3e4c-dac0-4487-85a5-2b1511599a8d	2026-07-21 18:09:05.468077+00	2026-07-21 18:09:05.468077+00	completed	approved	100	20.50	2026-07-30	medium
2f01124a-87cc-42c0-aff1-ff0045070c4d	ded132eb-db08-429a-81c1-f1a31e3d80fb	\N	1c04dd92-4377-490c-934c-38244ec68419	10b934e7-80e6-41d0-9140-f56d92d614ae	پیاده‌سازی صفحهٔ داشبورد مدیریتی #37	\N	high	2026-07-02	0954b5a9-fdc0-41a9-b214-029139a2aa35	2026-07-21 18:09:05.468077+00	2026-07-21 18:09:05.468077+00	in_progress	\N	69	4.30	2026-06-29	medium
2f01124a-87cc-42c0-aff1-ff0045070c4d	ded132eb-db08-429a-81c1-f1a31e3d80fb	\N	4e4c6e76-84d5-464d-957c-75ff3e9a2f8a	10b934e7-80e6-41d0-9140-f56d92d614ae	بررسی و رفع آسیب‌پذیری امنیتی #38	\N	high	2026-07-09	f2c81ee5-3ce5-40f1-8abf-3ea33dfd00f6	2026-07-21 18:09:05.468077+00	2026-07-21 18:09:05.468077+00	todo	\N	67	8.00	2026-06-19	medium
2f01124a-87cc-42c0-aff1-ff0045070c4d	ded132eb-db08-429a-81c1-f1a31e3d80fb	\N	de5c1d0c-3ca8-4c75-8525-abcfac9d0651	10b934e7-80e6-41d0-9140-f56d92d614ae	پیاده‌سازی صفحهٔ ورود جدید #39	\N	high	2026-08-16	5d3f6dca-195c-4147-ae8a-3ef145ec667c	2026-07-21 18:09:05.468077+00	2026-07-21 18:09:05.468077+00	todo	\N	8	27.70	2026-08-09	medium
2f01124a-87cc-42c0-aff1-ff0045070c4d	ded132eb-db08-429a-81c1-f1a31e3d80fb	\N	1c04dd92-4377-490c-934c-38244ec68419	10b934e7-80e6-41d0-9140-f56d92d614ae	افزودن تست واحد برای سرویس کاربران #40	\N	high	2026-07-13	828cc768-f382-45b8-84b7-b7b4b0f9638e	2026-07-21 18:09:05.468077+00	2026-07-21 18:09:05.468077+00	in_progress	\N	76	3.50	2026-06-23	medium
2f01124a-87cc-42c0-aff1-ff0045070c4d	ded132eb-db08-429a-81c1-f1a31e3d80fb	\N	10b934e7-80e6-41d0-9140-f56d92d614ae	10b934e7-80e6-41d0-9140-f56d92d614ae	پیاده‌سازی صفحهٔ داشبورد مدیریتی #41	\N	high	2026-08-17	10cdce85-5d76-420d-beba-e36c98ace7ef	2026-07-21 18:09:05.468077+00	2026-07-21 18:09:05.468077+00	in_progress	\N	40	37.50	2026-07-28	medium
2f01124a-87cc-42c0-aff1-ff0045070c4d	ded132eb-db08-429a-81c1-f1a31e3d80fb	\N	1c04dd92-4377-490c-934c-38244ec68419	10b934e7-80e6-41d0-9140-f56d92d614ae	پیاده‌سازی احراز هویت دومرحله‌ای #42	\N	low	2026-07-11	4b583741-8e68-425e-ba9b-c7df43795306	2026-07-21 18:09:05.468077+00	2026-07-21 18:09:05.468077+00	completed	pending	100	27.50	2026-07-01	medium
2f01124a-87cc-42c0-aff1-ff0045070c4d	ded132eb-db08-429a-81c1-f1a31e3d80fb	\N	4e4c6e76-84d5-464d-957c-75ff3e9a2f8a	10b934e7-80e6-41d0-9140-f56d92d614ae	رفع باگ در ماژول پرداخت #43	\N	medium	2026-08-07	d0806521-9c88-4084-82c9-03d77ad8d46b	2026-07-21 18:09:05.468077+00	2026-07-21 18:09:05.468077+00	completed	approved	100	25.60	2026-08-03	medium
2f01124a-87cc-42c0-aff1-ff0045070c4d	ded132eb-db08-429a-81c1-f1a31e3d80fb	\N	de5c1d0c-3ca8-4c75-8525-abcfac9d0651	10b934e7-80e6-41d0-9140-f56d92d614ae	افزودن تست واحد برای سرویس کاربران #44	\N	high	2026-07-09	2b5cc7e9-1e89-4c83-93ea-7ecf8e9612e6	2026-07-21 18:09:05.468077+00	2026-07-21 18:09:05.468077+00	todo	\N	33	7.00	2026-06-20	medium
2f01124a-87cc-42c0-aff1-ff0045070c4d	ded132eb-db08-429a-81c1-f1a31e3d80fb	\N	4e4c6e76-84d5-464d-957c-75ff3e9a2f8a	10b934e7-80e6-41d0-9140-f56d92d614ae	رفع مشکل کندی بارگذاری صفحه #45	\N	medium	2026-08-20	35b5d08c-2d7e-4fb3-8e3c-b33004993241	2026-07-21 18:09:05.468077+00	2026-07-21 18:09:05.468077+00	todo	\N	20	18.70	2026-08-11	medium
2f01124a-87cc-42c0-aff1-ff0045070c4d	ded132eb-db08-429a-81c1-f1a31e3d80fb	\N	de5c1d0c-3ca8-4c75-8525-abcfac9d0651	10b934e7-80e6-41d0-9140-f56d92d614ae	رفع مشکل ناسازگاری مرورگر #46	\N	high	2026-07-26	09237027-2865-43fc-ba06-76668696b85c	2026-07-21 18:09:05.468077+00	2026-07-21 18:09:05.468077+00	archived	\N	67	2.30	2026-07-05	medium
2f01124a-87cc-42c0-aff1-ff0045070c4d	ded132eb-db08-429a-81c1-f1a31e3d80fb	\N	f7d585ca-9137-4691-8979-1d8553a71ed8	10b934e7-80e6-41d0-9140-f56d92d614ae	افزودن قابلیت جست‌وجوی پیشرفته #47	\N	low	2026-08-02	829588b6-3727-4729-ba2b-e80db248ccc9	2026-07-21 18:09:05.468077+00	2026-07-21 18:09:05.468077+00	completed	approved	100	12.00	2026-07-28	medium
2f01124a-87cc-42c0-aff1-ff0045070c4d	ded132eb-db08-429a-81c1-f1a31e3d80fb	\N	10b934e7-80e6-41d0-9140-f56d92d614ae	10b934e7-80e6-41d0-9140-f56d92d614ae	طراحی API نسخهٔ دوم #48	\N	medium	2026-07-27	589a14d9-e716-47e9-9334-d8b59d177565	2026-07-21 18:09:05.468077+00	2026-07-21 18:09:05.468077+00	archived	\N	77	10.00	2026-07-21	medium
2f01124a-87cc-42c0-aff1-ff0045070c4d	ded132eb-db08-429a-81c1-f1a31e3d80fb	\N	4e4c6e76-84d5-464d-957c-75ff3e9a2f8a	10b934e7-80e6-41d0-9140-f56d92d614ae	به‌روزرسانی کتابخانه‌های وابسته #49	\N	medium	2026-08-08	704ebfc4-1bd5-45dc-8576-06f0ff2cd593	2026-07-21 18:09:05.468077+00	2026-07-21 18:09:05.468077+00	in_progress	\N	32	36.40	2026-07-29	medium
2f01124a-87cc-42c0-aff1-ff0045070c4d	ded132eb-db08-429a-81c1-f1a31e3d80fb	\N	f7d585ca-9137-4691-8979-1d8553a71ed8	10b934e7-80e6-41d0-9140-f56d92d614ae	بازنویسی ماژول اعلان‌ها #50	\N	medium	2026-07-06	21667cff-763b-4b5d-a4a7-1e9d89b912f6	2026-07-21 18:09:05.468077+00	2026-07-21 18:09:05.468077+00	todo	\N	5	2.10	2026-06-21	medium
2f01124a-87cc-42c0-aff1-ff0045070c4d	ded132eb-db08-429a-81c1-f1a31e3d80fb	\N	f7d585ca-9137-4691-8979-1d8553a71ed8	10b934e7-80e6-41d0-9140-f56d92d614ae	بهینه‌سازی کوئری‌های گزارش‌گیری #51	\N	high	2026-08-05	99d5425d-b1d0-4130-894d-ce03969221bb	2026-07-21 18:09:05.468077+00	2026-07-21 18:09:05.468077+00	todo	\N	56	23.00	2026-07-26	medium
2f01124a-87cc-42c0-aff1-ff0045070c4d	ded132eb-db08-429a-81c1-f1a31e3d80fb	\N	0aa2e3a9-85b6-420a-aeeb-62f6f7061c6c	10b934e7-80e6-41d0-9140-f56d92d614ae	به‌روزرسانی کتابخانه‌های وابسته #52	\N	low	2026-06-26	13545e89-cd6a-4d33-a79c-8c0d6e9a8690	2026-07-21 18:09:05.468077+00	2026-07-21 18:09:05.468077+00	completed	approved	100	33.70	2026-06-20	medium
2f01124a-87cc-42c0-aff1-ff0045070c4d	ded132eb-db08-429a-81c1-f1a31e3d80fb	\N	de5c1d0c-3ca8-4c75-8525-abcfac9d0651	10b934e7-80e6-41d0-9140-f56d92d614ae	طراحی API نسخهٔ دوم #53	\N	medium	2026-06-27	861a5d8c-8532-4da9-aba0-f6e76d092a01	2026-07-21 18:09:05.468077+00	2026-07-21 18:09:05.468077+00	completed	approved	100	36.20	2026-06-24	medium
2f01124a-87cc-42c0-aff1-ff0045070c4d	ded132eb-db08-429a-81c1-f1a31e3d80fb	\N	f7d585ca-9137-4691-8979-1d8553a71ed8	10b934e7-80e6-41d0-9140-f56d92d614ae	افزودن تست واحد برای سرویس کاربران #54	\N	high	2026-08-25	fa6460be-1db0-49f7-b01a-10f27a988f92	2026-07-21 18:09:05.468077+00	2026-07-21 18:09:05.468077+00	todo	\N	31	27.30	2026-08-12	medium
2f01124a-87cc-42c0-aff1-ff0045070c4d	70dba40f-b476-4927-8513-6f659d761416	\N	4e4c6e76-84d5-464d-957c-75ff3e9a2f8a	10b934e7-80e6-41d0-9140-f56d92d614ae	پیاده‌سازی صفحهٔ داشبورد مدیریتی #55	\N	high	2026-08-05	4d754fa9-cfee-4aa9-a6c7-43e0523b7eb4	2026-07-21 18:09:05.468077+00	2026-07-21 18:09:05.468077+00	archived	\N	19	37.20	2026-07-21	medium
2f01124a-87cc-42c0-aff1-ff0045070c4d	70dba40f-b476-4927-8513-6f659d761416	\N	1c04dd92-4377-490c-934c-38244ec68419	10b934e7-80e6-41d0-9140-f56d92d614ae	افزودن قابلیت جست‌وجوی پیشرفته #56	\N	medium	2026-08-13	4a587ccb-6f6a-45be-8888-dbf1fdd4b241	2026-07-21 18:09:05.468077+00	2026-07-21 18:09:05.468077+00	todo	\N	3	8.80	2026-08-06	medium
2f01124a-87cc-42c0-aff1-ff0045070c4d	70dba40f-b476-4927-8513-6f659d761416	\N	4e4c6e76-84d5-464d-957c-75ff3e9a2f8a	10b934e7-80e6-41d0-9140-f56d92d614ae	طراحی API نسخهٔ دوم #57	\N	low	2026-08-15	7be70dd6-f60a-416b-93d5-7d4b710d1076	2026-07-21 18:09:05.468077+00	2026-07-21 18:09:05.468077+00	in_progress	\N	13	16.50	2026-08-06	medium
2f01124a-87cc-42c0-aff1-ff0045070c4d	70dba40f-b476-4927-8513-6f659d761416	\N	10b934e7-80e6-41d0-9140-f56d92d614ae	10b934e7-80e6-41d0-9140-f56d92d614ae	رفع مشکل کندی بارگذاری صفحه #58	\N	medium	2026-08-23	6e1925d8-60d1-4dc1-8e50-6f4da0a7db4a	2026-07-21 18:09:05.468077+00	2026-07-21 18:09:05.468077+00	completed	approved	100	33.20	2026-08-07	medium
2f01124a-87cc-42c0-aff1-ff0045070c4d	70dba40f-b476-4927-8513-6f659d761416	\N	f7d585ca-9137-4691-8979-1d8553a71ed8	10b934e7-80e6-41d0-9140-f56d92d614ae	تنظیم پایپ‌لاین CI/CD #59	\N	low	2026-07-02	7433ea2b-ade9-4c67-8994-b210612332eb	2026-07-21 18:09:05.468077+00	2026-07-21 18:09:05.468077+00	in_progress	\N	51	14.50	2026-06-30	medium
2f01124a-87cc-42c0-aff1-ff0045070c4d	70dba40f-b476-4927-8513-6f659d761416	\N	f7d585ca-9137-4691-8979-1d8553a71ed8	10b934e7-80e6-41d0-9140-f56d92d614ae	رفع مشکل کندی بارگذاری صفحه #60	\N	high	2026-08-14	5478f6df-0d18-40c7-9c98-e2538c246f2f	2026-07-21 18:09:05.468077+00	2026-07-21 18:09:05.468077+00	todo	\N	65	17.20	2026-08-04	medium
2f01124a-87cc-42c0-aff1-ff0045070c4d	70dba40f-b476-4927-8513-6f659d761416	\N	f7d585ca-9137-4691-8979-1d8553a71ed8	10b934e7-80e6-41d0-9140-f56d92d614ae	افزودن قابلیت جست‌وجوی پیشرفته #61	\N	medium	2026-06-22	adcbf00e-da05-4444-8a2f-a1f6732c1aa1	2026-07-21 18:09:05.468077+00	2026-07-21 18:09:05.468077+00	completed	approved	100	8.80	2026-06-17	medium
2f01124a-87cc-42c0-aff1-ff0045070c4d	70dba40f-b476-4927-8513-6f659d761416	\N	4e4c6e76-84d5-464d-957c-75ff3e9a2f8a	10b934e7-80e6-41d0-9140-f56d92d614ae	پیاده‌سازی احراز هویت دومرحله‌ای #62	\N	medium	2026-07-13	4cdd5550-4761-4fd4-b67b-7e77d5e3dc02	2026-07-21 18:09:05.468077+00	2026-07-21 18:09:05.468077+00	todo	\N	40	18.60	2026-06-22	medium
2f01124a-87cc-42c0-aff1-ff0045070c4d	70dba40f-b476-4927-8513-6f659d761416	\N	de5c1d0c-3ca8-4c75-8525-abcfac9d0651	10b934e7-80e6-41d0-9140-f56d92d614ae	افزودن تست واحد برای سرویس کاربران #63	\N	medium	2026-07-30	f54bc413-cf74-4ac2-86ec-805f4c26a3eb	2026-07-21 18:09:05.468077+00	2026-07-21 18:09:05.468077+00	todo	\N	5	28.90	2026-07-10	medium
2f01124a-87cc-42c0-aff1-ff0045070c4d	70dba40f-b476-4927-8513-6f659d761416	\N	10b934e7-80e6-41d0-9140-f56d92d614ae	10b934e7-80e6-41d0-9140-f56d92d614ae	رفع مشکل کندی بارگذاری صفحه #64	\N	medium	2026-07-28	aa8d6c68-84a2-4deb-a404-7973171fc10c	2026-07-21 18:09:05.468077+00	2026-07-21 18:09:05.468077+00	completed	rejected	100	4.70	2026-07-20	medium
2f01124a-87cc-42c0-aff1-ff0045070c4d	70dba40f-b476-4927-8513-6f659d761416	\N	dfe22c83-6863-413d-97b7-1eb9b52dec02	10b934e7-80e6-41d0-9140-f56d92d614ae	تنظیم پایپ‌لاین CI/CD #65	\N	low	2026-08-06	e1b7574c-65d2-4bea-ad4b-93dbc9e6e4ce	2026-07-21 18:09:05.468077+00	2026-07-21 18:09:05.468077+00	in_progress	\N	38	21.30	2026-07-25	medium
2f01124a-87cc-42c0-aff1-ff0045070c4d	70dba40f-b476-4927-8513-6f659d761416	\N	dfe22c83-6863-413d-97b7-1eb9b52dec02	10b934e7-80e6-41d0-9140-f56d92d614ae	نوشتن مستندات فنی API #66	\N	medium	2026-07-20	2d3acd4a-d503-45ef-8898-7939db3207e0	2026-07-21 18:09:05.468077+00	2026-07-21 18:09:05.468077+00	in_progress	\N	70	6.80	2026-07-06	medium
2f01124a-87cc-42c0-aff1-ff0045070c4d	70dba40f-b476-4927-8513-6f659d761416	\N	0aa2e3a9-85b6-420a-aeeb-62f6f7061c6c	10b934e7-80e6-41d0-9140-f56d92d614ae	پیاده‌سازی صفحهٔ داشبورد مدیریتی #67	\N	high	2026-08-05	69329ea7-6d7e-4f39-8638-bbac94d51c59	2026-07-21 18:09:05.468077+00	2026-07-21 18:09:05.468077+00	completed	rejected	100	13.40	2026-07-29	medium
2f01124a-87cc-42c0-aff1-ff0045070c4d	70dba40f-b476-4927-8513-6f659d761416	\N	de5c1d0c-3ca8-4c75-8525-abcfac9d0651	10b934e7-80e6-41d0-9140-f56d92d614ae	افزودن تست واحد برای سرویس کاربران #68	\N	medium	2026-07-16	7669d2a4-7ffa-4fae-ac55-b54c564bc0d4	2026-07-21 18:09:05.468077+00	2026-07-21 18:09:05.468077+00	todo	\N	74	25.10	2026-07-05	medium
2f01124a-87cc-42c0-aff1-ff0045070c4d	70dba40f-b476-4927-8513-6f659d761416	\N	4e4c6e76-84d5-464d-957c-75ff3e9a2f8a	10b934e7-80e6-41d0-9140-f56d92d614ae	به‌روزرسانی کتابخانه‌های وابسته #69	\N	medium	2026-08-06	1b5faa26-1703-40e7-9fd9-dac691c1021b	2026-07-21 18:09:05.468077+00	2026-07-21 18:09:05.468077+00	completed	approved	100	32.20	2026-07-29	medium
2f01124a-87cc-42c0-aff1-ff0045070c4d	70dba40f-b476-4927-8513-6f659d761416	\N	f7d585ca-9137-4691-8979-1d8553a71ed8	10b934e7-80e6-41d0-9140-f56d92d614ae	طراحی API نسخهٔ دوم #70	\N	high	2026-06-30	25a91789-dbfa-420c-84e9-b5ff8803ad55	2026-07-21 18:09:05.468077+00	2026-07-21 18:09:05.468077+00	archived	\N	79	14.70	2026-06-26	medium
2f01124a-87cc-42c0-aff1-ff0045070c4d	70dba40f-b476-4927-8513-6f659d761416	\N	f7d585ca-9137-4691-8979-1d8553a71ed8	10b934e7-80e6-41d0-9140-f56d92d614ae	افزودن تست واحد برای سرویس کاربران #71	\N	low	2026-07-12	2566f5aa-3854-4f71-a7df-af6bc7618727	2026-07-21 18:09:05.468077+00	2026-07-21 18:09:05.468077+00	archived	\N	18	2.90	2026-07-01	medium
2f01124a-87cc-42c0-aff1-ff0045070c4d	70dba40f-b476-4927-8513-6f659d761416	\N	1c04dd92-4377-490c-934c-38244ec68419	10b934e7-80e6-41d0-9140-f56d92d614ae	بررسی و رفع آسیب‌پذیری امنیتی #72	\N	medium	2026-08-08	e0be053f-cce4-4b79-9775-2deaf220d935	2026-07-21 18:09:05.468077+00	2026-07-21 18:09:05.468077+00	completed	pending	100	35.70	2026-08-04	medium
2f01124a-87cc-42c0-aff1-ff0045070c4d	a1110f20-cd7e-4120-bc78-d446d13a5468	\N	de5c1d0c-3ca8-4c75-8525-abcfac9d0651	10b934e7-80e6-41d0-9140-f56d92d614ae	بررسی و رفع آسیب‌پذیری امنیتی #73	\N	medium	2026-08-14	51454dce-f4ba-4029-8acd-7724ddb986b5	2026-07-21 18:09:05.468077+00	2026-07-21 18:09:05.468077+00	todo	\N	31	7.60	2026-07-31	medium
2f01124a-87cc-42c0-aff1-ff0045070c4d	a1110f20-cd7e-4120-bc78-d446d13a5468	\N	dfe22c83-6863-413d-97b7-1eb9b52dec02	10b934e7-80e6-41d0-9140-f56d92d614ae	رفع مشکل ناسازگاری مرورگر #74	\N	medium	2026-08-17	5336dc17-a705-4688-9ef7-fec29306493b	2026-07-21 18:09:05.468077+00	2026-07-21 18:09:05.468077+00	todo	\N	28	8.70	2026-08-12	medium
2f01124a-87cc-42c0-aff1-ff0045070c4d	a1110f20-cd7e-4120-bc78-d446d13a5468	\N	dfe22c83-6863-413d-97b7-1eb9b52dec02	10b934e7-80e6-41d0-9140-f56d92d614ae	افزودن قابلیت جست‌وجوی پیشرفته #75	\N	low	2026-07-30	0b8e72bc-18e8-4bde-b1ad-726765bb55cf	2026-07-21 18:09:05.468077+00	2026-07-21 18:09:05.468077+00	completed	approved	100	19.30	2026-07-21	medium
2f01124a-87cc-42c0-aff1-ff0045070c4d	a1110f20-cd7e-4120-bc78-d446d13a5468	\N	f7d585ca-9137-4691-8979-1d8553a71ed8	10b934e7-80e6-41d0-9140-f56d92d614ae	رفع مشکل کندی بارگذاری صفحه #76	\N	medium	2026-08-11	b606de04-2549-4678-b8c9-41e69b3b1d02	2026-07-21 18:09:05.468077+00	2026-07-21 18:09:05.468077+00	completed	pending	100	25.30	2026-07-21	medium
2f01124a-87cc-42c0-aff1-ff0045070c4d	a1110f20-cd7e-4120-bc78-d446d13a5468	\N	dfe22c83-6863-413d-97b7-1eb9b52dec02	10b934e7-80e6-41d0-9140-f56d92d614ae	بررسی و رفع آسیب‌پذیری امنیتی #77	\N	low	2026-09-01	06d2bf9d-3a10-46d3-ba9b-a73089df2da0	2026-07-21 18:09:05.468077+00	2026-07-21 18:09:05.468077+00	completed	approved	100	30.30	2026-08-13	medium
2f01124a-87cc-42c0-aff1-ff0045070c4d	a1110f20-cd7e-4120-bc78-d446d13a5468	\N	0aa2e3a9-85b6-420a-aeeb-62f6f7061c6c	10b934e7-80e6-41d0-9140-f56d92d614ae	رفع مشکل ناسازگاری مرورگر #78	\N	high	2026-07-11	7af1624b-a09a-43a2-98ce-60b18c33cdd0	2026-07-21 18:09:05.468077+00	2026-07-21 18:09:05.468077+00	completed	approved	100	20.40	2026-07-01	medium
2f01124a-87cc-42c0-aff1-ff0045070c4d	a1110f20-cd7e-4120-bc78-d446d13a5468	\N	1c04dd92-4377-490c-934c-38244ec68419	10b934e7-80e6-41d0-9140-f56d92d614ae	نوشتن مستندات فنی API #79	\N	medium	2026-07-18	8750b0b6-ac9a-4abd-890a-6f3412f49c85	2026-07-21 18:09:05.468077+00	2026-07-21 18:09:05.468077+00	in_progress	\N	30	12.30	2026-07-14	medium
2f01124a-87cc-42c0-aff1-ff0045070c4d	a1110f20-cd7e-4120-bc78-d446d13a5468	\N	4e4c6e76-84d5-464d-957c-75ff3e9a2f8a	10b934e7-80e6-41d0-9140-f56d92d614ae	پیاده‌سازی احراز هویت دومرحله‌ای #80	\N	high	2026-07-04	f4fd781e-0654-49b2-bc8f-ecf5756c1b63	2026-07-21 18:09:05.468077+00	2026-07-21 18:09:05.468077+00	completed	approved	100	7.80	2026-06-25	medium
2f01124a-87cc-42c0-aff1-ff0045070c4d	a1110f20-cd7e-4120-bc78-d446d13a5468	\N	1c04dd92-4377-490c-934c-38244ec68419	10b934e7-80e6-41d0-9140-f56d92d614ae	رفع مشکل کندی بارگذاری صفحه #81	\N	high	2026-07-27	df9934fa-26dc-42ba-9e6c-f14026e5d66b	2026-07-21 18:09:05.468077+00	2026-07-21 18:09:05.468077+00	todo	\N	59	17.80	2026-07-12	medium
2f01124a-87cc-42c0-aff1-ff0045070c4d	a1110f20-cd7e-4120-bc78-d446d13a5468	\N	1c04dd92-4377-490c-934c-38244ec68419	10b934e7-80e6-41d0-9140-f56d92d614ae	نوشتن مستندات فنی API #82	\N	low	2026-07-30	11d06158-ff2e-4e6f-9165-8cb11f78873a	2026-07-21 18:09:05.468077+00	2026-07-21 18:09:05.468077+00	in_progress	\N	73	16.50	2026-07-10	medium
2f01124a-87cc-42c0-aff1-ff0045070c4d	a1110f20-cd7e-4120-bc78-d446d13a5468	\N	10b934e7-80e6-41d0-9140-f56d92d614ae	10b934e7-80e6-41d0-9140-f56d92d614ae	بازنویسی ماژول اعلان‌ها #83	\N	medium	2026-07-19	621f4d9d-4abb-4bb5-9ad0-84e3b160e31f	2026-07-21 18:09:05.468077+00	2026-07-21 18:09:05.468077+00	in_progress	\N	68	30.40	2026-07-05	medium
2f01124a-87cc-42c0-aff1-ff0045070c4d	a1110f20-cd7e-4120-bc78-d446d13a5468	\N	de5c1d0c-3ca8-4c75-8525-abcfac9d0651	10b934e7-80e6-41d0-9140-f56d92d614ae	طراحی API نسخهٔ دوم #84	\N	medium	2026-07-26	3285cece-bb4d-413d-a42f-c255462d08f9	2026-07-21 18:09:05.468077+00	2026-07-21 18:09:05.468077+00	completed	pending	100	20.50	2026-07-17	medium
2f01124a-87cc-42c0-aff1-ff0045070c4d	a1110f20-cd7e-4120-bc78-d446d13a5468	\N	0aa2e3a9-85b6-420a-aeeb-62f6f7061c6c	10b934e7-80e6-41d0-9140-f56d92d614ae	نوشتن مستندات فنی API #85	\N	low	2026-08-11	b80d768b-f20f-4ce5-ace9-8bf410de2225	2026-07-21 18:09:05.468077+00	2026-07-21 18:09:05.468077+00	in_progress	\N	59	36.90	2026-07-28	medium
2f01124a-87cc-42c0-aff1-ff0045070c4d	a1110f20-cd7e-4120-bc78-d446d13a5468	\N	de5c1d0c-3ca8-4c75-8525-abcfac9d0651	10b934e7-80e6-41d0-9140-f56d92d614ae	پیاده‌سازی صفحهٔ داشبورد مدیریتی #86	\N	high	2026-07-31	1c94f370-25b5-4fd4-95df-6b0e66e04b9b	2026-07-21 18:09:05.468077+00	2026-07-21 18:09:05.468077+00	completed	approved	100	3.00	2026-07-11	medium
2f01124a-87cc-42c0-aff1-ff0045070c4d	a1110f20-cd7e-4120-bc78-d446d13a5468	\N	dfe22c83-6863-413d-97b7-1eb9b52dec02	10b934e7-80e6-41d0-9140-f56d92d614ae	بهینه‌سازی کوئری‌های گزارش‌گیری #87	\N	low	2026-07-10	4c70de38-b81d-4601-8799-26afc3154bda	2026-07-21 18:09:05.468077+00	2026-07-21 18:09:05.468077+00	in_progress	\N	33	16.40	2026-06-24	medium
2f01124a-87cc-42c0-aff1-ff0045070c4d	a1110f20-cd7e-4120-bc78-d446d13a5468	\N	1c04dd92-4377-490c-934c-38244ec68419	10b934e7-80e6-41d0-9140-f56d92d614ae	طراحی API نسخهٔ دوم #88	\N	medium	2026-08-17	e795d8c4-ba3b-48c2-99fb-24a6d6ed7bf5	2026-07-21 18:09:05.468077+00	2026-07-21 18:09:05.468077+00	completed	approved	100	11.60	2026-08-03	medium
2f01124a-87cc-42c0-aff1-ff0045070c4d	a1110f20-cd7e-4120-bc78-d446d13a5468	\N	10b934e7-80e6-41d0-9140-f56d92d614ae	10b934e7-80e6-41d0-9140-f56d92d614ae	رفع مشکل کندی بارگذاری صفحه #89	\N	low	2026-07-23	063a7b6b-c455-4f53-8b4d-34f9ed154d5a	2026-07-21 18:09:05.468077+00	2026-07-21 18:09:05.468077+00	completed	approved	100	26.70	2026-07-20	medium
2f01124a-87cc-42c0-aff1-ff0045070c4d	a1110f20-cd7e-4120-bc78-d446d13a5468	\N	f7d585ca-9137-4691-8979-1d8553a71ed8	10b934e7-80e6-41d0-9140-f56d92d614ae	افزودن تست واحد برای سرویس کاربران #90	\N	low	2026-06-26	3c3c3302-bf62-4955-8546-c4ae76272277	2026-07-21 18:09:05.468077+00	2026-07-21 18:09:05.468077+00	completed	approved	100	25.60	2026-06-17	medium
2f01124a-87cc-42c0-aff1-ff0045070c4d	\N	\N	1c04dd92-4377-490c-934c-38244ec68419	1c04dd92-4377-490c-934c-38244ec68419	پیاده‌سازی صفحهٔ داشبورد مدیریتی #91	\N	low	2026-07-21	4e66c2d8-8917-4bb8-a97f-67aba6a7c7b6	2026-07-21 18:09:05.468077+00	2026-07-21 18:09:05.468077+00	todo	\N	59	28.60	2026-07-16	medium
2f01124a-87cc-42c0-aff1-ff0045070c4d	\N	\N	f7d585ca-9137-4691-8979-1d8553a71ed8	f7d585ca-9137-4691-8979-1d8553a71ed8	پیاده‌سازی صفحهٔ داشبورد مدیریتی #92	\N	high	2026-07-17	26ad66d2-4994-48be-9195-0fa6d98caa28	2026-07-21 18:09:05.468077+00	2026-07-21 18:09:05.468077+00	in_progress	\N	14	31.60	2026-06-26	medium
2f01124a-87cc-42c0-aff1-ff0045070c4d	\N	\N	1c04dd92-4377-490c-934c-38244ec68419	1c04dd92-4377-490c-934c-38244ec68419	رفع باگ در ماژول پرداخت #93	\N	medium	2026-07-12	01b9d1f3-e89c-4b26-8c50-d99280df3e1a	2026-07-21 18:09:05.468077+00	2026-07-21 18:09:05.468077+00	in_progress	\N	73	27.70	2026-06-22	medium
2f01124a-87cc-42c0-aff1-ff0045070c4d	\N	\N	0aa2e3a9-85b6-420a-aeeb-62f6f7061c6c	0aa2e3a9-85b6-420a-aeeb-62f6f7061c6c	پیاده‌سازی صفحهٔ ورود جدید #94	\N	high	2026-08-23	4e327e4d-1d33-480d-8dab-b356820fcf19	2026-07-21 18:09:05.468077+00	2026-07-21 18:09:05.468077+00	in_progress	\N	80	11.20	2026-08-15	medium
2f01124a-87cc-42c0-aff1-ff0045070c4d	\N	\N	dfe22c83-6863-413d-97b7-1eb9b52dec02	dfe22c83-6863-413d-97b7-1eb9b52dec02	رفع مشکل ناسازگاری مرورگر #95	\N	low	2026-07-26	fc7d58af-f533-41f4-ace9-0ba24c01efa2	2026-07-21 18:09:05.468077+00	2026-07-21 18:09:05.468077+00	archived	\N	72	31.70	2026-07-05	medium
2f01124a-87cc-42c0-aff1-ff0045070c4d	\N	\N	4e4c6e76-84d5-464d-957c-75ff3e9a2f8a	4e4c6e76-84d5-464d-957c-75ff3e9a2f8a	به‌روزرسانی کتابخانه‌های وابسته #96	\N	high	2026-07-13	9bf2689a-04a6-4c3f-a2ae-e0f2ef5be038	2026-07-21 18:09:05.468077+00	2026-07-21 18:09:05.468077+00	completed	approved	100	15.00	2026-07-09	medium
2f01124a-87cc-42c0-aff1-ff0045070c4d	\N	\N	f7d585ca-9137-4691-8979-1d8553a71ed8	f7d585ca-9137-4691-8979-1d8553a71ed8	پیاده‌سازی صفحهٔ ورود جدید #97	\N	medium	2026-08-24	4a717f05-6fd5-4958-9dec-48c65b302420	2026-07-21 18:09:05.468077+00	2026-07-21 18:09:05.468077+00	in_progress	\N	46	26.20	2026-08-07	medium
2f01124a-87cc-42c0-aff1-ff0045070c4d	\N	\N	f7d585ca-9137-4691-8979-1d8553a71ed8	f7d585ca-9137-4691-8979-1d8553a71ed8	نوشتن مستندات فنی API #98	\N	high	2026-07-20	6fe76512-cf7b-44bb-9fbd-089883e18058	2026-07-21 18:09:05.468077+00	2026-07-21 18:09:05.468077+00	completed	pending	100	38.70	2026-07-13	medium
2f01124a-87cc-42c0-aff1-ff0045070c4d	\N	\N	4e4c6e76-84d5-464d-957c-75ff3e9a2f8a	4e4c6e76-84d5-464d-957c-75ff3e9a2f8a	بررسی و رفع آسیب‌پذیری امنیتی #99	\N	medium	2026-08-06	e93a19b6-dcfe-4cf0-a02a-2ba60b02245e	2026-07-21 18:09:05.468077+00	2026-07-21 18:09:05.468077+00	completed	pending	100	33.40	2026-07-20	medium
2f01124a-87cc-42c0-aff1-ff0045070c4d	\N	\N	de5c1d0c-3ca8-4c75-8525-abcfac9d0651	de5c1d0c-3ca8-4c75-8525-abcfac9d0651	بازنویسی ماژول اعلان‌ها #100	\N	low	2026-07-15	c2788d8c-9e4b-413a-952f-807d0cb84e36	2026-07-21 18:09:05.468077+00	2026-07-21 18:09:05.468077+00	in_progress	\N	35	35.50	2026-07-06	medium
2f01124a-87cc-42c0-aff1-ff0045070c4d	\N	\N	1c04dd92-4377-490c-934c-38244ec68419	1c04dd92-4377-490c-934c-38244ec68419	پیاده‌سازی صفحهٔ داشبورد مدیریتی #101	\N	high	2026-08-04	6ff1b4b7-e479-4bde-9c37-0c3f7275fe7e	2026-07-21 18:09:05.468077+00	2026-07-21 18:09:05.468077+00	archived	\N	48	14.80	2026-07-15	medium
2f01124a-87cc-42c0-aff1-ff0045070c4d	\N	\N	0aa2e3a9-85b6-420a-aeeb-62f6f7061c6c	0aa2e3a9-85b6-420a-aeeb-62f6f7061c6c	افزودن تست واحد برای سرویس کاربران #102	\N	medium	2026-07-14	57ff3f0b-8465-446c-aa62-eb1cbe85292d	2026-07-21 18:09:05.468077+00	2026-07-21 18:09:05.468077+00	in_progress	\N	33	14.90	2026-06-27	medium
2f01124a-87cc-42c0-aff1-ff0045070c4d	\N	\N	de5c1d0c-3ca8-4c75-8525-abcfac9d0651	de5c1d0c-3ca8-4c75-8525-abcfac9d0651	به‌روزرسانی کتابخانه‌های وابسته #103	\N	low	2026-07-23	f3020bec-d78b-41ff-a98a-7a165b65732f	2026-07-21 18:09:05.468077+00	2026-07-21 18:09:05.468077+00	completed	pending	100	5.30	2026-07-21	medium
2f01124a-87cc-42c0-aff1-ff0045070c4d	\N	\N	dfe22c83-6863-413d-97b7-1eb9b52dec02	dfe22c83-6863-413d-97b7-1eb9b52dec02	رفع مشکل ناسازگاری مرورگر #104	\N	low	2026-08-05	6fe89ba9-de96-44ba-87e6-c8072e8f45eb	2026-07-21 18:09:05.468077+00	2026-07-21 18:09:05.468077+00	in_progress	\N	60	26.50	2026-07-17	medium
2f01124a-87cc-42c0-aff1-ff0045070c4d	\N	\N	0aa2e3a9-85b6-420a-aeeb-62f6f7061c6c	0aa2e3a9-85b6-420a-aeeb-62f6f7061c6c	افزودن تست واحد برای سرویس کاربران #105	\N	medium	2026-07-02	89916d94-d3b7-40a9-bd7d-1248f10b137c	2026-07-21 18:09:05.468077+00	2026-07-21 18:09:05.468077+00	completed	pending	100	28.30	2026-06-21	medium
2f01124a-87cc-42c0-aff1-ff0045070c4d	b439b371-fa49-40be-b62a-cf771b88bb1b	\N	02b5f471-cd3d-47ff-85ad-d22286b9e4b1	42df4646-393a-4de3-83d6-df4785b690c6	پیگیری مطالبات معوق مشتریان #1	\N	medium	2026-07-16	ab564e1f-f9ae-421c-9777-6567a0a58495	2026-07-21 18:09:05.468077+00	2026-07-21 18:09:05.468077+00	completed	rejected	100	5.90	2026-06-27	medium
2f01124a-87cc-42c0-aff1-ff0045070c4d	b439b371-fa49-40be-b62a-cf771b88bb1b	\N	2d6d452d-4915-4793-bf0b-ad7d43798e6f	42df4646-393a-4de3-83d6-df4785b690c6	تهیهٔ گزارش جریان نقدی #2	\N	medium	2026-08-04	8fca2c8d-e245-49dc-b0c1-02401f625b0a	2026-07-21 18:09:05.468077+00	2026-07-21 18:09:05.468077+00	completed	approved	100	8.30	2026-07-14	medium
2f01124a-87cc-42c0-aff1-ff0045070c4d	b439b371-fa49-40be-b62a-cf771b88bb1b	\N	02b5f471-cd3d-47ff-85ad-d22286b9e4b1	42df4646-393a-4de3-83d6-df4785b690c6	تهیهٔ گزارش جریان نقدی #3	\N	medium	2026-07-17	a0b70e37-acbc-4662-b47f-bd934043a210	2026-07-21 18:09:05.468077+00	2026-07-21 18:09:05.468077+00	in_progress	\N	78	39.90	2026-07-14	medium
2f01124a-87cc-42c0-aff1-ff0045070c4d	b439b371-fa49-40be-b62a-cf771b88bb1b	\N	2d6d452d-4915-4793-bf0b-ad7d43798e6f	42df4646-393a-4de3-83d6-df4785b690c6	تهیهٔ گزارش سود و زیان ماهانه #4	\N	high	2026-08-18	dd433bd6-1f28-4c06-b11f-3a39f86f83b6	2026-07-21 18:09:05.468077+00	2026-07-21 18:09:05.468077+00	completed	rejected	100	26.20	2026-08-15	medium
2f01124a-87cc-42c0-aff1-ff0045070c4d	b439b371-fa49-40be-b62a-cf771b88bb1b	\N	2d6d452d-4915-4793-bf0b-ad7d43798e6f	42df4646-393a-4de3-83d6-df4785b690c6	بررسی و تأیید صورت‌حساب‌های خرید #5	\N	low	2026-08-05	2afccc25-b9c3-463f-8103-3684c9e61a41	2026-07-21 18:09:05.468077+00	2026-07-21 18:09:05.468077+00	completed	pending	100	34.20	2026-07-29	medium
2f01124a-87cc-42c0-aff1-ff0045070c4d	b439b371-fa49-40be-b62a-cf771b88bb1b	\N	72cdbbe8-b0fe-43f0-ab1a-f11f02a63e1f	42df4646-393a-4de3-83d6-df4785b690c6	بررسی و تسویهٔ کارت اعتباری شرکت #6	\N	high	2026-06-29	4c63b0bd-f470-448f-8586-db7e6f796d76	2026-07-21 18:09:05.468077+00	2026-07-21 18:09:05.468077+00	completed	approved	100	15.90	2026-06-20	medium
2f01124a-87cc-42c0-aff1-ff0045070c4d	b439b371-fa49-40be-b62a-cf771b88bb1b	\N	02b5f471-cd3d-47ff-85ad-d22286b9e4b1	42df4646-393a-4de3-83d6-df4785b690c6	تهیهٔ گزارش مالیاتی فصلی #7	\N	medium	2026-07-11	c18378d6-9771-4ff6-bdbb-85a4e9f55c2d	2026-07-21 18:09:05.468077+00	2026-07-21 18:09:05.468077+00	completed	approved	100	18.90	2026-06-25	medium
2f01124a-87cc-42c0-aff1-ff0045070c4d	b439b371-fa49-40be-b62a-cf771b88bb1b	\N	42df4646-393a-4de3-83d6-df4785b690c6	42df4646-393a-4de3-83d6-df4785b690c6	تهیهٔ گزارش مالیاتی فصلی #8	\N	high	2026-07-23	248e4d32-9962-4bb7-acee-d37cc3ca4368	2026-07-21 18:09:05.468077+00	2026-07-21 18:09:05.468077+00	completed	approved	100	12.60	2026-07-09	medium
2f01124a-87cc-42c0-aff1-ff0045070c4d	b439b371-fa49-40be-b62a-cf771b88bb1b	\N	42df4646-393a-4de3-83d6-df4785b690c6	42df4646-393a-4de3-83d6-df4785b690c6	به‌روزرسانی جدول حقوق و دستمزد #9	\N	high	2026-08-09	88175c95-11b5-4066-82e6-5b9099cc5578	2026-07-21 18:09:05.468077+00	2026-07-21 18:09:05.468077+00	todo	\N	49	36.70	2026-08-02	medium
2f01124a-87cc-42c0-aff1-ff0045070c4d	b439b371-fa49-40be-b62a-cf771b88bb1b	\N	42df4646-393a-4de3-83d6-df4785b690c6	42df4646-393a-4de3-83d6-df4785b690c6	تهیهٔ گزارش جریان نقدی #10	\N	medium	2026-08-14	b5e7c1ec-7809-49d8-a6ae-32bcf02c3ef5	2026-07-21 18:09:05.468077+00	2026-07-21 18:09:05.468077+00	in_progress	\N	27	39.90	2026-08-04	medium
2f01124a-87cc-42c0-aff1-ff0045070c4d	b439b371-fa49-40be-b62a-cf771b88bb1b	\N	2d6d452d-4915-4793-bf0b-ad7d43798e6f	42df4646-393a-4de3-83d6-df4785b690c6	تهیهٔ گزارش سود و زیان ماهانه #11	\N	low	2026-07-25	e560f767-0748-4748-9314-05221d1d4bed	2026-07-21 18:09:05.468077+00	2026-07-21 18:09:05.468077+00	completed	rejected	100	34.40	2026-07-17	medium
2f01124a-87cc-42c0-aff1-ff0045070c4d	b439b371-fa49-40be-b62a-cf771b88bb1b	\N	02b5f471-cd3d-47ff-85ad-d22286b9e4b1	42df4646-393a-4de3-83d6-df4785b690c6	تهیهٔ گزارش سود و زیان ماهانه #12	\N	high	2026-08-28	a92ea78c-41a0-47e6-9940-40aefa032a7a	2026-07-21 18:09:05.468077+00	2026-07-21 18:09:05.468077+00	todo	\N	40	27.40	2026-08-12	medium
2f01124a-87cc-42c0-aff1-ff0045070c4d	b439b371-fa49-40be-b62a-cf771b88bb1b	\N	72cdbbe8-b0fe-43f0-ab1a-f11f02a63e1f	42df4646-393a-4de3-83d6-df4785b690c6	پیگیری مطالبات معوق مشتریان #13	\N	medium	2026-08-09	a9258ed2-a7f8-4ab9-ab4b-c2d9bf96c46b	2026-07-21 18:09:05.468077+00	2026-07-21 18:09:05.468077+00	todo	\N	20	29.00	2026-07-21	medium
2f01124a-87cc-42c0-aff1-ff0045070c4d	b439b371-fa49-40be-b62a-cf771b88bb1b	\N	72cdbbe8-b0fe-43f0-ab1a-f11f02a63e1f	42df4646-393a-4de3-83d6-df4785b690c6	ثبت اسناد حسابداری هفتگی #14	\N	low	2026-07-27	6b51ff8d-d8d3-479a-a8b8-fa8bff1a8433	2026-07-21 18:09:05.468077+00	2026-07-21 18:09:05.468077+00	completed	approved	100	39.40	2026-07-09	medium
2f01124a-87cc-42c0-aff1-ff0045070c4d	b439b371-fa49-40be-b62a-cf771b88bb1b	\N	b4d6dda1-b07b-48aa-b440-b2cbfe40ac0f	42df4646-393a-4de3-83d6-df4785b690c6	بررسی و تأیید صورت‌حساب‌های خرید #15	\N	medium	2026-07-18	fe25451e-d059-4ea4-b5fa-374eec282784	2026-07-21 18:09:05.468077+00	2026-07-21 18:09:05.468077+00	todo	\N	70	23.70	2026-07-01	medium
2f01124a-87cc-42c0-aff1-ff0045070c4d	b439b371-fa49-40be-b62a-cf771b88bb1b	\N	02b5f471-cd3d-47ff-85ad-d22286b9e4b1	42df4646-393a-4de3-83d6-df4785b690c6	تهیهٔ گزارش سود و زیان ماهانه #16	\N	medium	2026-08-15	b9444eca-b3d9-4a3b-9322-7db9d1c5815f	2026-07-21 18:09:05.468077+00	2026-07-21 18:09:05.468077+00	completed	approved	100	17.10	2026-08-11	medium
2f01124a-87cc-42c0-aff1-ff0045070c4d	b439b371-fa49-40be-b62a-cf771b88bb1b	\N	72cdbbe8-b0fe-43f0-ab1a-f11f02a63e1f	42df4646-393a-4de3-83d6-df4785b690c6	بررسی فاکتورهای فروش صادرشده #17	\N	medium	2026-08-03	ed30d0c0-eb62-486b-a9f4-456b52be9336	2026-07-21 18:09:05.468077+00	2026-07-21 18:09:05.468077+00	archived	\N	73	4.80	2026-07-16	medium
2f01124a-87cc-42c0-aff1-ff0045070c4d	b439b371-fa49-40be-b62a-cf771b88bb1b	\N	2d6d452d-4915-4793-bf0b-ad7d43798e6f	42df4646-393a-4de3-83d6-df4785b690c6	تهیهٔ گزارش مالیاتی فصلی #18	\N	low	2026-08-02	f342a9f5-f41f-4e5c-97bf-67131b8cca72	2026-07-21 18:09:05.468077+00	2026-07-21 18:09:05.468077+00	completed	approved	100	35.40	2026-07-15	medium
2f01124a-87cc-42c0-aff1-ff0045070c4d	fe2692d0-5164-4138-b8f5-5f7e8a8e7580	\N	b4d6dda1-b07b-48aa-b440-b2cbfe40ac0f	42df4646-393a-4de3-83d6-df4785b690c6	بررسی فاکتورهای فروش صادرشده #19	\N	high	2026-07-03	5c507580-510d-4065-9754-ccb3e786917e	2026-07-21 18:09:05.468077+00	2026-07-21 18:09:05.468077+00	completed	pending	100	36.60	2026-06-27	medium
2f01124a-87cc-42c0-aff1-ff0045070c4d	fe2692d0-5164-4138-b8f5-5f7e8a8e7580	\N	42df4646-393a-4de3-83d6-df4785b690c6	42df4646-393a-4de3-83d6-df4785b690c6	پیگیری مطالبات معوق مشتریان #20	\N	low	2026-07-25	03829c79-9d26-47ff-8075-2f75ee1bbd97	2026-07-21 18:09:05.468077+00	2026-07-21 18:09:05.468077+00	todo	\N	20	14.30	2026-07-19	medium
2f01124a-87cc-42c0-aff1-ff0045070c4d	fe2692d0-5164-4138-b8f5-5f7e8a8e7580	\N	72cdbbe8-b0fe-43f0-ab1a-f11f02a63e1f	42df4646-393a-4de3-83d6-df4785b690c6	بررسی قراردادهای مالی جدید #21	\N	medium	2026-07-26	757f40c0-63c7-49ee-b8b0-8b777a7e3638	2026-07-21 18:09:05.468077+00	2026-07-21 18:09:05.468077+00	in_progress	\N	10	11.50	2026-07-08	medium
2f01124a-87cc-42c0-aff1-ff0045070c4d	fe2692d0-5164-4138-b8f5-5f7e8a8e7580	\N	72cdbbe8-b0fe-43f0-ab1a-f11f02a63e1f	42df4646-393a-4de3-83d6-df4785b690c6	بررسی صورت وضعیت پیمانکاران #22	\N	high	2026-08-06	6d410ac1-7c0d-4746-a8a0-f9dbb9d19b36	2026-07-21 18:09:05.468077+00	2026-07-21 18:09:05.468077+00	completed	approved	100	5.60	2026-07-26	medium
2f01124a-87cc-42c0-aff1-ff0045070c4d	fe2692d0-5164-4138-b8f5-5f7e8a8e7580	\N	72cdbbe8-b0fe-43f0-ab1a-f11f02a63e1f	42df4646-393a-4de3-83d6-df4785b690c6	مغایرت‌گیری حساب‌های بانکی #23	\N	low	2026-08-12	96f35680-ea13-4269-9815-3dd9d76979d3	2026-07-21 18:09:05.468077+00	2026-07-21 18:09:05.468077+00	todo	\N	79	29.40	2026-07-23	medium
2f01124a-87cc-42c0-aff1-ff0045070c4d	fe2692d0-5164-4138-b8f5-5f7e8a8e7580	\N	3683aa32-1561-4f36-90bf-d6402b4a66d8	42df4646-393a-4de3-83d6-df4785b690c6	بررسی و تأیید صورت‌حساب‌های خرید #24	\N	low	2026-08-28	7d1890fa-0a12-4aff-ae71-47ac05ecefce	2026-07-21 18:09:05.468077+00	2026-07-21 18:09:05.468077+00	in_progress	\N	10	3.70	2026-08-08	medium
2f01124a-87cc-42c0-aff1-ff0045070c4d	fe2692d0-5164-4138-b8f5-5f7e8a8e7580	\N	72cdbbe8-b0fe-43f0-ab1a-f11f02a63e1f	42df4646-393a-4de3-83d6-df4785b690c6	تطبیق موجودی انبار با حساب‌ها #25	\N	low	2026-08-01	4a9be453-a818-4c92-b1ac-6c8a2cdf34ef	2026-07-21 18:09:05.468077+00	2026-07-21 18:09:05.468077+00	archived	\N	73	17.80	2026-07-22	medium
2f01124a-87cc-42c0-aff1-ff0045070c4d	fe2692d0-5164-4138-b8f5-5f7e8a8e7580	\N	72cdbbe8-b0fe-43f0-ab1a-f11f02a63e1f	42df4646-393a-4de3-83d6-df4785b690c6	پیگیری مطالبات معوق مشتریان #26	\N	high	2026-08-05	c7977079-063e-47a8-88a4-879ba722dff3	2026-07-21 18:09:05.468077+00	2026-07-21 18:09:05.468077+00	todo	\N	38	20.40	2026-07-17	medium
2f01124a-87cc-42c0-aff1-ff0045070c4d	fe2692d0-5164-4138-b8f5-5f7e8a8e7580	\N	b4d6dda1-b07b-48aa-b440-b2cbfe40ac0f	42df4646-393a-4de3-83d6-df4785b690c6	تهیهٔ گزارش جریان نقدی #27	\N	low	2026-07-19	1347e55f-6e7a-4935-b0e7-5728c05a7399	2026-07-21 18:09:05.468077+00	2026-07-21 18:09:05.468077+00	completed	approved	100	8.00	2026-07-15	medium
2f01124a-87cc-42c0-aff1-ff0045070c4d	fe2692d0-5164-4138-b8f5-5f7e8a8e7580	\N	02b5f471-cd3d-47ff-85ad-d22286b9e4b1	42df4646-393a-4de3-83d6-df4785b690c6	مغایرت‌گیری حساب‌های بانکی #28	\N	medium	2026-07-28	07be99db-33e1-435a-ab8b-8374a3a9b72c	2026-07-21 18:09:05.468077+00	2026-07-21 18:09:05.468077+00	completed	approved	100	34.70	2026-07-07	medium
2f01124a-87cc-42c0-aff1-ff0045070c4d	fe2692d0-5164-4138-b8f5-5f7e8a8e7580	\N	2d6d452d-4915-4793-bf0b-ad7d43798e6f	42df4646-393a-4de3-83d6-df4785b690c6	بررسی فاکتورهای فروش صادرشده #29	\N	low	2026-08-23	fc3e9424-6f73-409b-a89e-e772d5a0be16	2026-07-21 18:09:05.468077+00	2026-07-21 18:09:05.468077+00	archived	\N	47	21.60	2026-08-10	medium
2f01124a-87cc-42c0-aff1-ff0045070c4d	fe2692d0-5164-4138-b8f5-5f7e8a8e7580	\N	42df4646-393a-4de3-83d6-df4785b690c6	42df4646-393a-4de3-83d6-df4785b690c6	تهیهٔ گزارش سود و زیان ماهانه #30	\N	medium	2026-07-17	a1b9a996-02f6-4627-b576-1c87bf0906c1	2026-07-21 18:09:05.468077+00	2026-07-21 18:09:05.468077+00	in_progress	\N	57	11.40	2026-07-01	medium
2f01124a-87cc-42c0-aff1-ff0045070c4d	fe2692d0-5164-4138-b8f5-5f7e8a8e7580	\N	42df4646-393a-4de3-83d6-df4785b690c6	42df4646-393a-4de3-83d6-df4785b690c6	پیگیری بیمهٔ کارکنان #31	\N	high	2026-07-18	3304ef9b-383b-4827-8849-347e2339621a	2026-07-21 18:09:05.468077+00	2026-07-21 18:09:05.468077+00	todo	\N	53	11.40	2026-07-04	medium
2f01124a-87cc-42c0-aff1-ff0045070c4d	fe2692d0-5164-4138-b8f5-5f7e8a8e7580	\N	b4d6dda1-b07b-48aa-b440-b2cbfe40ac0f	42df4646-393a-4de3-83d6-df4785b690c6	بررسی قراردادهای مالی جدید #32	\N	high	2026-08-19	79424fa1-1b7f-4b77-84fe-daea3a492b66	2026-07-21 18:09:05.468077+00	2026-07-21 18:09:05.468077+00	todo	\N	40	9.20	2026-08-07	medium
2f01124a-87cc-42c0-aff1-ff0045070c4d	fe2692d0-5164-4138-b8f5-5f7e8a8e7580	\N	92a3b31d-254e-440b-8bbe-d18db13d73cd	42df4646-393a-4de3-83d6-df4785b690c6	بررسی قراردادهای مالی جدید #33	\N	medium	2026-08-01	92b6c40a-1608-4cbc-9c82-f03fb16032a5	2026-07-21 18:09:05.468077+00	2026-07-21 18:09:05.468077+00	completed	rejected	100	20.90	2026-07-15	medium
2f01124a-87cc-42c0-aff1-ff0045070c4d	fe2692d0-5164-4138-b8f5-5f7e8a8e7580	\N	42df4646-393a-4de3-83d6-df4785b690c6	42df4646-393a-4de3-83d6-df4785b690c6	ثبت اسناد حسابداری هفتگی #34	\N	low	2026-08-03	3ed34084-dd2e-4e40-890b-43347bb82368	2026-07-21 18:09:05.468077+00	2026-07-21 18:09:05.468077+00	in_progress	\N	74	15.40	2026-07-18	medium
2f01124a-87cc-42c0-aff1-ff0045070c4d	fe2692d0-5164-4138-b8f5-5f7e8a8e7580	\N	42df4646-393a-4de3-83d6-df4785b690c6	42df4646-393a-4de3-83d6-df4785b690c6	بررسی قراردادهای مالی جدید #35	\N	high	2026-08-07	d097332f-f215-4cd3-95f5-bda99022d2ed	2026-07-21 18:09:05.468077+00	2026-07-21 18:09:05.468077+00	in_progress	\N	60	12.90	2026-07-17	medium
2f01124a-87cc-42c0-aff1-ff0045070c4d	fe2692d0-5164-4138-b8f5-5f7e8a8e7580	\N	42df4646-393a-4de3-83d6-df4785b690c6	42df4646-393a-4de3-83d6-df4785b690c6	بررسی قراردادهای مالی جدید #36	\N	medium	2026-07-19	4ea0c7f0-bc6c-443b-abc6-b0795822ce24	2026-07-21 18:09:05.468077+00	2026-07-21 18:09:05.468077+00	todo	\N	46	31.00	2026-07-13	medium
2f01124a-87cc-42c0-aff1-ff0045070c4d	189350e0-cc86-486f-a699-53771a8307c9	\N	2d6d452d-4915-4793-bf0b-ad7d43798e6f	42df4646-393a-4de3-83d6-df4785b690c6	بررسی صورت وضعیت پیمانکاران #37	\N	high	2026-07-14	6279cd93-962b-4bdd-b709-25ede61bd8e7	2026-07-21 18:09:05.468077+00	2026-07-21 18:09:05.468077+00	todo	\N	24	15.80	2026-07-11	medium
2f01124a-87cc-42c0-aff1-ff0045070c4d	189350e0-cc86-486f-a699-53771a8307c9	\N	2d6d452d-4915-4793-bf0b-ad7d43798e6f	42df4646-393a-4de3-83d6-df4785b690c6	به‌روزرسانی جدول حقوق و دستمزد #38	\N	high	2026-07-28	baeb5906-66b7-4499-97fd-a988c1152650	2026-07-21 18:09:05.468077+00	2026-07-21 18:09:05.468077+00	todo	\N	35	33.40	2026-07-10	medium
2f01124a-87cc-42c0-aff1-ff0045070c4d	189350e0-cc86-486f-a699-53771a8307c9	\N	3683aa32-1561-4f36-90bf-d6402b4a66d8	42df4646-393a-4de3-83d6-df4785b690c6	بررسی فاکتورهای فروش صادرشده #39	\N	medium	2026-06-29	dbb0d5e2-eb82-4900-b4a4-e82797a4aa29	2026-07-21 18:09:05.468077+00	2026-07-21 18:09:05.468077+00	completed	pending	100	32.20	2026-06-24	medium
2f01124a-87cc-42c0-aff1-ff0045070c4d	189350e0-cc86-486f-a699-53771a8307c9	\N	2d6d452d-4915-4793-bf0b-ad7d43798e6f	42df4646-393a-4de3-83d6-df4785b690c6	ثبت اسناد حسابداری هفتگی #40	\N	high	2026-08-09	b1eff962-70dd-47f4-a0b0-cca5ce06aff7	2026-07-21 18:09:05.468077+00	2026-07-21 18:09:05.468077+00	completed	rejected	100	21.30	2026-08-03	medium
2f01124a-87cc-42c0-aff1-ff0045070c4d	189350e0-cc86-486f-a699-53771a8307c9	\N	3683aa32-1561-4f36-90bf-d6402b4a66d8	42df4646-393a-4de3-83d6-df4785b690c6	مغایرت‌گیری حساب‌های بانکی #41	\N	high	2026-06-21	cb015031-0624-454c-a196-93e058620da8	2026-07-21 18:09:05.468077+00	2026-07-21 18:09:05.468077+00	todo	\N	42	32.60	2026-06-18	medium
2f01124a-87cc-42c0-aff1-ff0045070c4d	189350e0-cc86-486f-a699-53771a8307c9	\N	3683aa32-1561-4f36-90bf-d6402b4a66d8	42df4646-393a-4de3-83d6-df4785b690c6	مغایرت‌گیری حساب‌های بانکی #42	\N	medium	2026-08-30	ca1b05be-2aba-407d-b182-d53d642015a4	2026-07-21 18:09:05.468077+00	2026-07-21 18:09:05.468077+00	completed	approved	100	37.40	2026-08-12	medium
2f01124a-87cc-42c0-aff1-ff0045070c4d	189350e0-cc86-486f-a699-53771a8307c9	\N	2d6d452d-4915-4793-bf0b-ad7d43798e6f	42df4646-393a-4de3-83d6-df4785b690c6	تهیهٔ گزارش جریان نقدی #43	\N	medium	2026-08-01	47f60589-5f42-4e2a-b3b8-8a07d793ed65	2026-07-21 18:09:05.468077+00	2026-07-21 18:09:05.468077+00	todo	\N	75	14.80	2026-07-11	medium
2f01124a-87cc-42c0-aff1-ff0045070c4d	189350e0-cc86-486f-a699-53771a8307c9	\N	b4d6dda1-b07b-48aa-b440-b2cbfe40ac0f	42df4646-393a-4de3-83d6-df4785b690c6	پیگیری مطالبات معوق مشتریان #44	\N	medium	2026-08-20	0d324add-4779-49ec-8546-1a2349d27bf9	2026-07-21 18:09:05.468077+00	2026-07-21 18:09:05.468077+00	completed	approved	100	33.00	2026-07-31	medium
2f01124a-87cc-42c0-aff1-ff0045070c4d	189350e0-cc86-486f-a699-53771a8307c9	\N	2d6d452d-4915-4793-bf0b-ad7d43798e6f	42df4646-393a-4de3-83d6-df4785b690c6	بررسی فاکتورهای فروش صادرشده #45	\N	high	2026-08-03	1fd8f914-2e3d-49ac-8f99-1fe835b47517	2026-07-21 18:09:05.468077+00	2026-07-21 18:09:05.468077+00	in_progress	\N	39	32.30	2026-07-29	medium
2f01124a-87cc-42c0-aff1-ff0045070c4d	189350e0-cc86-486f-a699-53771a8307c9	\N	72cdbbe8-b0fe-43f0-ab1a-f11f02a63e1f	42df4646-393a-4de3-83d6-df4785b690c6	پیگیری مطالبات معوق مشتریان #46	\N	high	2026-08-10	fa489af0-3f23-4ced-92cc-bce78e608f8e	2026-07-21 18:09:05.468077+00	2026-07-21 18:09:05.468077+00	completed	pending	100	31.80	2026-07-24	medium
2f01124a-87cc-42c0-aff1-ff0045070c4d	189350e0-cc86-486f-a699-53771a8307c9	\N	b4d6dda1-b07b-48aa-b440-b2cbfe40ac0f	42df4646-393a-4de3-83d6-df4785b690c6	بررسی صورت وضعیت پیمانکاران #47	\N	medium	2026-08-04	3ec832dd-9c04-48c2-a975-338ac5a9c144	2026-07-21 18:09:05.468077+00	2026-07-21 18:09:05.468077+00	completed	approved	100	8.50	2026-08-01	medium
2f01124a-87cc-42c0-aff1-ff0045070c4d	189350e0-cc86-486f-a699-53771a8307c9	\N	72cdbbe8-b0fe-43f0-ab1a-f11f02a63e1f	42df4646-393a-4de3-83d6-df4785b690c6	مغایرت‌گیری حساب‌های بانکی #48	\N	high	2026-08-08	c6bddffd-d179-4663-96ee-43c85ee7259c	2026-07-21 18:09:05.468077+00	2026-07-21 18:09:05.468077+00	archived	\N	31	3.20	2026-07-25	medium
2f01124a-87cc-42c0-aff1-ff0045070c4d	189350e0-cc86-486f-a699-53771a8307c9	\N	72cdbbe8-b0fe-43f0-ab1a-f11f02a63e1f	42df4646-393a-4de3-83d6-df4785b690c6	به‌روزرسانی جدول حقوق و دستمزد #49	\N	medium	2026-06-30	ad098819-0f08-4144-a032-e8dda6222fbf	2026-07-21 18:09:05.468077+00	2026-07-21 18:09:05.468077+00	todo	\N	53	7.80	2026-06-28	medium
2f01124a-87cc-42c0-aff1-ff0045070c4d	189350e0-cc86-486f-a699-53771a8307c9	\N	72cdbbe8-b0fe-43f0-ab1a-f11f02a63e1f	42df4646-393a-4de3-83d6-df4785b690c6	بررسی و تسویهٔ کارت اعتباری شرکت #50	\N	high	2026-07-30	2a77d79c-a797-4d87-a2c0-d9d3e50967da	2026-07-21 18:09:05.468077+00	2026-07-21 18:09:05.468077+00	in_progress	\N	60	35.20	2026-07-12	medium
2f01124a-87cc-42c0-aff1-ff0045070c4d	189350e0-cc86-486f-a699-53771a8307c9	\N	72cdbbe8-b0fe-43f0-ab1a-f11f02a63e1f	42df4646-393a-4de3-83d6-df4785b690c6	تهیهٔ پیش‌نویس بودجهٔ واحد #51	\N	low	2026-06-25	e8b153b2-7a9f-4983-b37f-b637279ac701	2026-07-21 18:09:05.468077+00	2026-07-21 18:09:05.468077+00	archived	\N	71	14.40	2026-06-19	medium
2f01124a-87cc-42c0-aff1-ff0045070c4d	189350e0-cc86-486f-a699-53771a8307c9	\N	72cdbbe8-b0fe-43f0-ab1a-f11f02a63e1f	42df4646-393a-4de3-83d6-df4785b690c6	به‌روزرسانی جدول حقوق و دستمزد #52	\N	high	2026-07-13	95944a52-0c08-4018-8c67-8d195e845182	2026-07-21 18:09:05.468077+00	2026-07-21 18:09:05.468077+00	completed	approved	100	15.00	2026-07-06	medium
2f01124a-87cc-42c0-aff1-ff0045070c4d	189350e0-cc86-486f-a699-53771a8307c9	\N	2d6d452d-4915-4793-bf0b-ad7d43798e6f	42df4646-393a-4de3-83d6-df4785b690c6	بررسی صورت وضعیت پیمانکاران #53	\N	medium	2026-08-11	779200aa-0362-483d-8534-18684332028f	2026-07-21 18:09:05.468077+00	2026-07-21 18:09:05.468077+00	completed	pending	100	9.30	2026-08-01	medium
2f01124a-87cc-42c0-aff1-ff0045070c4d	189350e0-cc86-486f-a699-53771a8307c9	\N	92a3b31d-254e-440b-8bbe-d18db13d73cd	42df4646-393a-4de3-83d6-df4785b690c6	ثبت اسناد حسابداری هفتگی #54	\N	medium	2026-08-01	3c547e90-c308-4261-911a-8999264d0699	2026-07-21 18:09:05.468077+00	2026-07-21 18:09:05.468077+00	in_progress	\N	36	28.80	2026-07-21	medium
2f01124a-87cc-42c0-aff1-ff0045070c4d	7ccce913-5c45-45ec-a44c-1c50c45bb193	\N	72cdbbe8-b0fe-43f0-ab1a-f11f02a63e1f	42df4646-393a-4de3-83d6-df4785b690c6	به‌روزرسانی جدول حقوق و دستمزد #55	\N	medium	2026-07-29	779570eb-34ae-4236-920a-a27eac4e8107	2026-07-21 18:09:05.468077+00	2026-07-21 18:09:05.468077+00	archived	\N	71	37.50	2026-07-17	medium
2f01124a-87cc-42c0-aff1-ff0045070c4d	7ccce913-5c45-45ec-a44c-1c50c45bb193	\N	b4d6dda1-b07b-48aa-b440-b2cbfe40ac0f	42df4646-393a-4de3-83d6-df4785b690c6	تهیهٔ گزارش سود و زیان ماهانه #56	\N	high	2026-07-14	0fe152b5-3f1d-43d3-82c1-6c8843cfd321	2026-07-21 18:09:05.468077+00	2026-07-21 18:09:05.468077+00	archived	\N	69	16.40	2026-07-03	medium
2f01124a-87cc-42c0-aff1-ff0045070c4d	7ccce913-5c45-45ec-a44c-1c50c45bb193	\N	02b5f471-cd3d-47ff-85ad-d22286b9e4b1	42df4646-393a-4de3-83d6-df4785b690c6	پیگیری مطالبات معوق مشتریان #57	\N	low	2026-08-10	04dd62a5-fd91-4931-b161-9659c8d811b7	2026-07-21 18:09:05.468077+00	2026-07-21 18:09:05.468077+00	in_progress	\N	36	38.30	2026-08-04	medium
2f01124a-87cc-42c0-aff1-ff0045070c4d	7ccce913-5c45-45ec-a44c-1c50c45bb193	\N	42df4646-393a-4de3-83d6-df4785b690c6	42df4646-393a-4de3-83d6-df4785b690c6	تطبیق موجودی انبار با حساب‌ها #58	\N	medium	2026-08-30	89b3ce6d-fa8f-4ced-8256-204f8b553ad4	2026-07-21 18:09:05.468077+00	2026-07-21 18:09:05.468077+00	in_progress	\N	61	10.10	2026-08-14	medium
2f01124a-87cc-42c0-aff1-ff0045070c4d	7ccce913-5c45-45ec-a44c-1c50c45bb193	\N	b4d6dda1-b07b-48aa-b440-b2cbfe40ac0f	42df4646-393a-4de3-83d6-df4785b690c6	مغایرت‌گیری حساب‌های بانکی #59	\N	low	2026-07-31	4d6912ef-d2d7-4d29-a1c1-391a6a979c51	2026-07-21 18:09:05.468077+00	2026-07-21 18:09:05.468077+00	completed	approved	100	25.40	2026-07-21	medium
2f01124a-87cc-42c0-aff1-ff0045070c4d	7ccce913-5c45-45ec-a44c-1c50c45bb193	\N	3683aa32-1561-4f36-90bf-d6402b4a66d8	42df4646-393a-4de3-83d6-df4785b690c6	تطبیق موجودی انبار با حساب‌ها #60	\N	high	2026-07-04	5e93df2a-2c21-4ab4-81f2-66af9de99468	2026-07-21 18:09:05.468077+00	2026-07-21 18:09:05.468077+00	in_progress	\N	28	26.20	2026-07-01	medium
2f01124a-87cc-42c0-aff1-ff0045070c4d	7ccce913-5c45-45ec-a44c-1c50c45bb193	\N	42df4646-393a-4de3-83d6-df4785b690c6	42df4646-393a-4de3-83d6-df4785b690c6	تهیهٔ گزارش جریان نقدی #61	\N	medium	2026-07-24	ae55b67e-f9bf-41e8-a65a-32adce3df0d4	2026-07-21 18:09:05.468077+00	2026-07-21 18:09:05.468077+00	todo	\N	12	27.90	2026-07-12	medium
2f01124a-87cc-42c0-aff1-ff0045070c4d	7ccce913-5c45-45ec-a44c-1c50c45bb193	\N	92a3b31d-254e-440b-8bbe-d18db13d73cd	42df4646-393a-4de3-83d6-df4785b690c6	بررسی فاکتورهای فروش صادرشده #62	\N	high	2026-07-28	d72b322c-d11c-42fd-a56f-f9aebe14c903	2026-07-21 18:09:05.468077+00	2026-07-21 18:09:05.468077+00	todo	\N	60	20.10	2026-07-21	medium
2f01124a-87cc-42c0-aff1-ff0045070c4d	7ccce913-5c45-45ec-a44c-1c50c45bb193	\N	92a3b31d-254e-440b-8bbe-d18db13d73cd	42df4646-393a-4de3-83d6-df4785b690c6	پیگیری مطالبات معوق مشتریان #63	\N	high	2026-07-16	d43082c7-665d-45d9-8491-4810a695e30d	2026-07-21 18:09:05.468077+00	2026-07-21 18:09:05.468077+00	archived	\N	7	36.50	2026-07-04	medium
2f01124a-87cc-42c0-aff1-ff0045070c4d	7ccce913-5c45-45ec-a44c-1c50c45bb193	\N	42df4646-393a-4de3-83d6-df4785b690c6	42df4646-393a-4de3-83d6-df4785b690c6	بررسی قراردادهای مالی جدید #64	\N	low	2026-07-23	c9b7eea8-c601-4115-9517-8583a9ada716	2026-07-21 18:09:05.468077+00	2026-07-21 18:09:05.468077+00	completed	approved	100	17.90	2026-07-20	medium
2f01124a-87cc-42c0-aff1-ff0045070c4d	7ccce913-5c45-45ec-a44c-1c50c45bb193	\N	b4d6dda1-b07b-48aa-b440-b2cbfe40ac0f	42df4646-393a-4de3-83d6-df4785b690c6	پیگیری بیمهٔ کارکنان #65	\N	medium	2026-08-17	632bcd1f-1a63-4e67-bc48-368d1d42d669	2026-07-21 18:09:05.468077+00	2026-07-21 18:09:05.468077+00	todo	\N	63	9.10	2026-08-14	medium
2f01124a-87cc-42c0-aff1-ff0045070c4d	7ccce913-5c45-45ec-a44c-1c50c45bb193	\N	72cdbbe8-b0fe-43f0-ab1a-f11f02a63e1f	42df4646-393a-4de3-83d6-df4785b690c6	بررسی و تأیید صورت‌حساب‌های خرید #66	\N	medium	2026-08-14	3dc40829-24e3-4e65-9ca8-0e1bfdadf466	2026-07-21 18:09:05.468077+00	2026-07-21 18:09:05.468077+00	in_progress	\N	72	24.90	2026-08-11	medium
2f01124a-87cc-42c0-aff1-ff0045070c4d	7ccce913-5c45-45ec-a44c-1c50c45bb193	\N	2d6d452d-4915-4793-bf0b-ad7d43798e6f	42df4646-393a-4de3-83d6-df4785b690c6	تهیهٔ پیش‌نویس بودجهٔ واحد #67	\N	medium	2026-08-03	85cca325-85bd-49e7-a591-addafa45399b	2026-07-21 18:09:05.468077+00	2026-07-21 18:09:05.468077+00	in_progress	\N	17	34.30	2026-07-15	medium
2f01124a-87cc-42c0-aff1-ff0045070c4d	7ccce913-5c45-45ec-a44c-1c50c45bb193	\N	02b5f471-cd3d-47ff-85ad-d22286b9e4b1	42df4646-393a-4de3-83d6-df4785b690c6	تهیهٔ گزارش مالیاتی فصلی #68	\N	low	2026-07-03	9651f85e-a3ba-4d55-a592-e590f8a98d07	2026-07-21 18:09:05.468077+00	2026-07-21 18:09:05.468077+00	in_progress	\N	58	26.60	2026-06-28	medium
2f01124a-87cc-42c0-aff1-ff0045070c4d	7ccce913-5c45-45ec-a44c-1c50c45bb193	\N	72cdbbe8-b0fe-43f0-ab1a-f11f02a63e1f	42df4646-393a-4de3-83d6-df4785b690c6	بررسی و تسویهٔ کارت اعتباری شرکت #69	\N	medium	2026-06-28	f4a5eae0-c948-493b-be90-0d8d621cb524	2026-07-21 18:09:05.468077+00	2026-07-21 18:09:05.468077+00	todo	\N	72	27.60	2026-06-16	medium
2f01124a-87cc-42c0-aff1-ff0045070c4d	7ccce913-5c45-45ec-a44c-1c50c45bb193	\N	92a3b31d-254e-440b-8bbe-d18db13d73cd	42df4646-393a-4de3-83d6-df4785b690c6	پیگیری بیمهٔ کارکنان #70	\N	medium	2026-08-08	e8ad2ec3-e393-4d61-8082-4c3ce9417369	2026-07-21 18:09:05.468077+00	2026-07-21 18:09:05.468077+00	todo	\N	65	14.50	2026-07-25	medium
2f01124a-87cc-42c0-aff1-ff0045070c4d	7ccce913-5c45-45ec-a44c-1c50c45bb193	\N	02b5f471-cd3d-47ff-85ad-d22286b9e4b1	42df4646-393a-4de3-83d6-df4785b690c6	تهیهٔ گزارش مالیاتی فصلی #71	\N	low	2026-07-11	d6e35365-3e3d-401c-a71f-56dc4e473dff	2026-07-21 18:09:05.468077+00	2026-07-21 18:09:05.468077+00	completed	approved	100	2.30	2026-06-24	medium
2f01124a-87cc-42c0-aff1-ff0045070c4d	7ccce913-5c45-45ec-a44c-1c50c45bb193	\N	02b5f471-cd3d-47ff-85ad-d22286b9e4b1	42df4646-393a-4de3-83d6-df4785b690c6	تهیهٔ گزارش مالیاتی فصلی #72	\N	medium	2026-07-24	9558aa9c-e1d1-4ab6-bf6d-a6d8445fe844	2026-07-21 18:09:05.468077+00	2026-07-21 18:09:05.468077+00	in_progress	\N	74	29.50	2026-07-14	medium
2f01124a-87cc-42c0-aff1-ff0045070c4d	865b2901-75dd-4a80-bdb3-bb9cd38f1b68	\N	42df4646-393a-4de3-83d6-df4785b690c6	42df4646-393a-4de3-83d6-df4785b690c6	تهیهٔ گزارش جریان نقدی #73	\N	low	2026-08-09	1cadd9e1-078e-46f8-910b-d70726e8df71	2026-07-21 18:09:05.468077+00	2026-07-21 18:09:05.468077+00	in_progress	\N	7	27.40	2026-07-27	medium
2f01124a-87cc-42c0-aff1-ff0045070c4d	865b2901-75dd-4a80-bdb3-bb9cd38f1b68	\N	02b5f471-cd3d-47ff-85ad-d22286b9e4b1	42df4646-393a-4de3-83d6-df4785b690c6	تطبیق موجودی انبار با حساب‌ها #74	\N	high	2026-07-10	d4e703a0-eb3a-4430-885b-4cbe136c6c2a	2026-07-21 18:09:05.468077+00	2026-07-21 18:09:05.468077+00	in_progress	\N	39	28.20	2026-06-26	medium
2f01124a-87cc-42c0-aff1-ff0045070c4d	865b2901-75dd-4a80-bdb3-bb9cd38f1b68	\N	72cdbbe8-b0fe-43f0-ab1a-f11f02a63e1f	42df4646-393a-4de3-83d6-df4785b690c6	ثبت اسناد حسابداری هفتگی #75	\N	low	2026-07-30	523ca685-dae6-4854-8eb9-7cd4f8e5354c	2026-07-21 18:09:05.468077+00	2026-07-21 18:09:05.468077+00	in_progress	\N	17	20.20	2026-07-09	medium
2f01124a-87cc-42c0-aff1-ff0045070c4d	865b2901-75dd-4a80-bdb3-bb9cd38f1b68	\N	02b5f471-cd3d-47ff-85ad-d22286b9e4b1	42df4646-393a-4de3-83d6-df4785b690c6	بررسی فاکتورهای فروش صادرشده #76	\N	high	2026-08-06	66966a99-0790-4142-a68f-68eddd1ae9f1	2026-07-21 18:09:05.468077+00	2026-07-21 18:09:05.468077+00	archived	\N	70	36.70	2026-07-24	medium
2f01124a-87cc-42c0-aff1-ff0045070c4d	865b2901-75dd-4a80-bdb3-bb9cd38f1b68	\N	b4d6dda1-b07b-48aa-b440-b2cbfe40ac0f	42df4646-393a-4de3-83d6-df4785b690c6	بررسی و تسویهٔ کارت اعتباری شرکت #77	\N	low	2026-08-15	137ebbff-92cf-488b-adbf-5fb819ba5e73	2026-07-21 18:09:05.468077+00	2026-07-21 18:09:05.468077+00	completed	pending	100	27.90	2026-08-07	medium
2f01124a-87cc-42c0-aff1-ff0045070c4d	865b2901-75dd-4a80-bdb3-bb9cd38f1b68	\N	3683aa32-1561-4f36-90bf-d6402b4a66d8	42df4646-393a-4de3-83d6-df4785b690c6	تهیهٔ پیش‌نویس بودجهٔ واحد #78	\N	high	2026-08-04	d3151b80-6a2c-4bc8-bb47-fd2a419ef281	2026-07-21 18:09:05.468077+00	2026-07-21 18:09:05.468077+00	todo	\N	46	5.00	2026-07-19	medium
2f01124a-87cc-42c0-aff1-ff0045070c4d	865b2901-75dd-4a80-bdb3-bb9cd38f1b68	\N	3683aa32-1561-4f36-90bf-d6402b4a66d8	42df4646-393a-4de3-83d6-df4785b690c6	بررسی قراردادهای مالی جدید #79	\N	high	2026-07-08	81b07d9d-99a9-4f0b-817c-e54509d48159	2026-07-21 18:09:05.468077+00	2026-07-21 18:09:05.468077+00	todo	\N	25	23.80	2026-06-19	medium
2f01124a-87cc-42c0-aff1-ff0045070c4d	865b2901-75dd-4a80-bdb3-bb9cd38f1b68	\N	92a3b31d-254e-440b-8bbe-d18db13d73cd	42df4646-393a-4de3-83d6-df4785b690c6	به‌روزرسانی جدول حقوق و دستمزد #80	\N	low	2026-07-24	4e348b68-9809-4f80-bc95-c21705091395	2026-07-21 18:09:05.468077+00	2026-07-21 18:09:05.468077+00	todo	\N	26	29.20	2026-07-06	medium
2f01124a-87cc-42c0-aff1-ff0045070c4d	865b2901-75dd-4a80-bdb3-bb9cd38f1b68	\N	02b5f471-cd3d-47ff-85ad-d22286b9e4b1	42df4646-393a-4de3-83d6-df4785b690c6	به‌روزرسانی جدول حقوق و دستمزد #81	\N	low	2026-08-30	55f906e3-73ce-4159-9627-caebbf3c40e5	2026-07-21 18:09:05.468077+00	2026-07-21 18:09:05.468077+00	todo	\N	58	7.00	2026-08-12	medium
2f01124a-87cc-42c0-aff1-ff0045070c4d	865b2901-75dd-4a80-bdb3-bb9cd38f1b68	\N	02b5f471-cd3d-47ff-85ad-d22286b9e4b1	42df4646-393a-4de3-83d6-df4785b690c6	تطبیق موجودی انبار با حساب‌ها #82	\N	medium	2026-08-06	8d31ee61-c6b4-45f7-ba80-238b97f9f7bd	2026-07-21 18:09:05.468077+00	2026-07-21 18:09:05.468077+00	completed	approved	100	29.50	2026-07-21	medium
2f01124a-87cc-42c0-aff1-ff0045070c4d	865b2901-75dd-4a80-bdb3-bb9cd38f1b68	\N	02b5f471-cd3d-47ff-85ad-d22286b9e4b1	42df4646-393a-4de3-83d6-df4785b690c6	تهیهٔ گزارش جریان نقدی #83	\N	low	2026-08-09	deb113e5-8157-495a-8aaf-1547e650aefd	2026-07-21 18:09:05.468077+00	2026-07-21 18:09:05.468077+00	in_progress	\N	74	4.80	2026-08-07	medium
2f01124a-87cc-42c0-aff1-ff0045070c4d	865b2901-75dd-4a80-bdb3-bb9cd38f1b68	\N	02b5f471-cd3d-47ff-85ad-d22286b9e4b1	42df4646-393a-4de3-83d6-df4785b690c6	تهیهٔ پیش‌نویس بودجهٔ واحد #84	\N	low	2026-08-03	ee4ec177-df68-418f-a0ca-c75b0eadb0ba	2026-07-21 18:09:05.468077+00	2026-07-21 18:09:05.468077+00	in_progress	\N	8	39.50	2026-07-30	medium
2f01124a-87cc-42c0-aff1-ff0045070c4d	865b2901-75dd-4a80-bdb3-bb9cd38f1b68	\N	02b5f471-cd3d-47ff-85ad-d22286b9e4b1	42df4646-393a-4de3-83d6-df4785b690c6	مغایرت‌گیری حساب‌های بانکی #85	\N	low	2026-07-19	6e72eb72-32f1-4347-b884-62fc77dcfce0	2026-07-21 18:09:05.468077+00	2026-07-21 18:09:05.468077+00	todo	\N	53	16.20	2026-07-04	medium
2f01124a-87cc-42c0-aff1-ff0045070c4d	865b2901-75dd-4a80-bdb3-bb9cd38f1b68	\N	02b5f471-cd3d-47ff-85ad-d22286b9e4b1	42df4646-393a-4de3-83d6-df4785b690c6	بررسی فاکتورهای فروش صادرشده #86	\N	low	2026-08-27	7df9f4bf-befb-48ed-a9fa-214ca8ca6dde	2026-07-21 18:09:05.468077+00	2026-07-21 18:09:05.468077+00	completed	pending	100	27.90	2026-08-13	medium
2f01124a-87cc-42c0-aff1-ff0045070c4d	865b2901-75dd-4a80-bdb3-bb9cd38f1b68	\N	72cdbbe8-b0fe-43f0-ab1a-f11f02a63e1f	42df4646-393a-4de3-83d6-df4785b690c6	تهیهٔ گزارش سود و زیان ماهانه #87	\N	low	2026-08-23	383a88ac-b988-4f1e-8fdd-79f8814da87c	2026-07-21 18:09:05.468077+00	2026-07-21 18:09:05.468077+00	completed	approved	100	39.70	2026-08-10	medium
2f01124a-87cc-42c0-aff1-ff0045070c4d	865b2901-75dd-4a80-bdb3-bb9cd38f1b68	\N	02b5f471-cd3d-47ff-85ad-d22286b9e4b1	42df4646-393a-4de3-83d6-df4785b690c6	بررسی و تسویهٔ کارت اعتباری شرکت #88	\N	low	2026-07-02	a8ecb6ce-b8bc-41e6-b36c-e939587ffc5a	2026-07-21 18:09:05.468077+00	2026-07-21 18:09:05.468077+00	completed	approved	100	39.20	2026-06-30	medium
2f01124a-87cc-42c0-aff1-ff0045070c4d	865b2901-75dd-4a80-bdb3-bb9cd38f1b68	\N	02b5f471-cd3d-47ff-85ad-d22286b9e4b1	42df4646-393a-4de3-83d6-df4785b690c6	بررسی فاکتورهای فروش صادرشده #89	\N	low	2026-08-01	da65fa70-e469-4e04-8099-cc60c7353136	2026-07-21 18:09:05.468077+00	2026-07-21 18:09:05.468077+00	completed	pending	100	11.40	2026-07-13	medium
2f01124a-87cc-42c0-aff1-ff0045070c4d	865b2901-75dd-4a80-bdb3-bb9cd38f1b68	\N	2d6d452d-4915-4793-bf0b-ad7d43798e6f	42df4646-393a-4de3-83d6-df4785b690c6	بررسی قراردادهای مالی جدید #90	\N	high	2026-07-11	43a98cab-f9c5-4895-ae78-c37652c2555c	2026-07-21 18:09:05.468077+00	2026-07-21 18:09:05.468077+00	todo	\N	14	3.20	2026-07-03	medium
2f01124a-87cc-42c0-aff1-ff0045070c4d	\N	\N	72cdbbe8-b0fe-43f0-ab1a-f11f02a63e1f	72cdbbe8-b0fe-43f0-ab1a-f11f02a63e1f	ثبت اسناد حسابداری هفتگی #91	\N	low	2026-07-27	cb64afb5-5e06-428f-9011-916ebc0c0b1b	2026-07-21 18:09:05.468077+00	2026-07-21 18:09:05.468077+00	in_progress	\N	8	5.80	2026-07-25	medium
2f01124a-87cc-42c0-aff1-ff0045070c4d	\N	\N	42df4646-393a-4de3-83d6-df4785b690c6	42df4646-393a-4de3-83d6-df4785b690c6	ثبت اسناد حسابداری هفتگی #92	\N	high	2026-08-03	9b7bcf60-6b23-461c-9127-6d8540ad43cf	2026-07-21 18:09:05.468077+00	2026-07-21 18:09:05.468077+00	completed	approved	100	3.70	2026-07-31	medium
2f01124a-87cc-42c0-aff1-ff0045070c4d	\N	\N	02b5f471-cd3d-47ff-85ad-d22286b9e4b1	02b5f471-cd3d-47ff-85ad-d22286b9e4b1	بررسی و تسویهٔ کارت اعتباری شرکت #93	\N	low	2026-07-28	70ea89a0-7413-41cd-bdb6-e611bde53501	2026-07-21 18:09:05.468077+00	2026-07-21 18:09:05.468077+00	in_progress	\N	17	21.10	2026-07-20	medium
2f01124a-87cc-42c0-aff1-ff0045070c4d	\N	\N	2d6d452d-4915-4793-bf0b-ad7d43798e6f	2d6d452d-4915-4793-bf0b-ad7d43798e6f	تهیهٔ گزارش مالیاتی فصلی #94	\N	high	2026-08-27	89d9b3b2-2ed3-4714-b966-c97d97f4177e	2026-07-21 18:09:05.468077+00	2026-07-21 18:09:05.468077+00	in_progress	\N	76	31.40	2026-08-07	medium
2f01124a-87cc-42c0-aff1-ff0045070c4d	\N	\N	b4d6dda1-b07b-48aa-b440-b2cbfe40ac0f	b4d6dda1-b07b-48aa-b440-b2cbfe40ac0f	بررسی قراردادهای مالی جدید #95	\N	low	2026-07-12	74b26e14-f3a0-40e6-ab6c-bec1020bfe24	2026-07-21 18:09:05.468077+00	2026-07-21 18:09:05.468077+00	in_progress	\N	66	10.40	2026-07-01	medium
2f01124a-87cc-42c0-aff1-ff0045070c4d	\N	\N	2d6d452d-4915-4793-bf0b-ad7d43798e6f	2d6d452d-4915-4793-bf0b-ad7d43798e6f	بررسی صورت وضعیت پیمانکاران #96	\N	high	2026-07-08	cc885f19-3811-4c7a-964c-0406fd00b998	2026-07-21 18:09:05.468077+00	2026-07-21 18:09:05.468077+00	in_progress	\N	22	25.80	2026-06-19	medium
2f01124a-87cc-42c0-aff1-ff0045070c4d	\N	\N	02b5f471-cd3d-47ff-85ad-d22286b9e4b1	02b5f471-cd3d-47ff-85ad-d22286b9e4b1	بررسی و تسویهٔ کارت اعتباری شرکت #97	\N	high	2026-07-22	511a015a-ce89-4d9a-a79e-2dabb8007116	2026-07-21 18:09:05.468077+00	2026-07-21 18:09:05.468077+00	completed	approved	100	14.10	2026-07-08	medium
2f01124a-87cc-42c0-aff1-ff0045070c4d	\N	\N	02b5f471-cd3d-47ff-85ad-d22286b9e4b1	02b5f471-cd3d-47ff-85ad-d22286b9e4b1	بررسی فاکتورهای فروش صادرشده #98	\N	low	2026-07-06	33dd2852-7d50-40af-92f5-b025f0daad63	2026-07-21 18:09:05.468077+00	2026-07-21 18:09:05.468077+00	in_progress	\N	68	20.00	2026-06-25	medium
2f01124a-87cc-42c0-aff1-ff0045070c4d	\N	\N	b4d6dda1-b07b-48aa-b440-b2cbfe40ac0f	b4d6dda1-b07b-48aa-b440-b2cbfe40ac0f	بررسی و تسویهٔ کارت اعتباری شرکت #99	\N	medium	2026-07-11	ad5f018d-8a54-4e50-b298-5ecdcc04087c	2026-07-21 18:09:05.468077+00	2026-07-21 18:09:05.468077+00	in_progress	\N	7	23.40	2026-07-05	medium
2f01124a-87cc-42c0-aff1-ff0045070c4d	\N	\N	02b5f471-cd3d-47ff-85ad-d22286b9e4b1	02b5f471-cd3d-47ff-85ad-d22286b9e4b1	پیگیری مطالبات معوق مشتریان #100	\N	low	2026-07-19	4ffd77df-cb23-4521-bf92-82d47d6e91ae	2026-07-21 18:09:05.468077+00	2026-07-21 18:09:05.468077+00	completed	approved	100	14.50	2026-07-10	medium
2f01124a-87cc-42c0-aff1-ff0045070c4d	\N	\N	42df4646-393a-4de3-83d6-df4785b690c6	42df4646-393a-4de3-83d6-df4785b690c6	تهیهٔ گزارش جریان نقدی #101	\N	low	2026-07-10	9d205cef-9b4b-4d81-95d2-b8e198751286	2026-07-21 18:09:05.468077+00	2026-07-21 18:09:05.468077+00	completed	pending	100	4.00	2026-06-21	medium
2f01124a-87cc-42c0-aff1-ff0045070c4d	\N	\N	02b5f471-cd3d-47ff-85ad-d22286b9e4b1	02b5f471-cd3d-47ff-85ad-d22286b9e4b1	ثبت اسناد حسابداری هفتگی #102	\N	high	2026-06-22	7df5dce7-4e09-4a2e-8692-e24034783354	2026-07-21 18:09:05.468077+00	2026-07-21 18:09:05.468077+00	completed	pending	100	29.50	2026-06-18	medium
2f01124a-87cc-42c0-aff1-ff0045070c4d	\N	\N	3683aa32-1561-4f36-90bf-d6402b4a66d8	3683aa32-1561-4f36-90bf-d6402b4a66d8	پیگیری بیمهٔ کارکنان #103	\N	medium	2026-07-24	da734440-ef57-4d4c-a95b-36a7c6c91389	2026-07-21 18:09:05.468077+00	2026-07-21 18:09:05.468077+00	in_progress	\N	38	38.40	2026-07-16	medium
2f01124a-87cc-42c0-aff1-ff0045070c4d	\N	\N	42df4646-393a-4de3-83d6-df4785b690c6	42df4646-393a-4de3-83d6-df4785b690c6	تهیهٔ گزارش جریان نقدی #104	\N	low	2026-08-22	c0058059-00a2-4469-8044-eb027c094706	2026-07-21 18:09:05.468077+00	2026-07-21 18:09:05.468077+00	in_progress	\N	61	36.70	2026-08-14	medium
2f01124a-87cc-42c0-aff1-ff0045070c4d	\N	\N	72cdbbe8-b0fe-43f0-ab1a-f11f02a63e1f	72cdbbe8-b0fe-43f0-ab1a-f11f02a63e1f	تهیهٔ پیش‌نویس بودجهٔ واحد #105	\N	medium	2026-07-20	877c6194-e4c1-480d-8d82-b24ca9993c25	2026-07-21 18:09:05.468077+00	2026-07-21 18:09:05.468077+00	completed	pending	100	31.50	2026-07-11	medium
2f01124a-87cc-42c0-aff1-ff0045070c4d	0901f3f3-057f-4aae-bf11-9639f3ee3dd4	\N	c873d894-cb10-4d12-a1dd-f989a1851641	c873d894-cb10-4d12-a1dd-f989a1851641	برگزاری نظرسنجی رضایت شغلی #1	\N	low	2026-07-29	f89101d7-0911-43dd-88ae-e47c142443a8	2026-07-21 18:09:05.468077+00	2026-07-21 18:09:05.468077+00	todo	\N	67	34.70	2026-07-23	medium
2f01124a-87cc-42c0-aff1-ff0045070c4d	0901f3f3-057f-4aae-bf11-9639f3ee3dd4	\N	c873d894-cb10-4d12-a1dd-f989a1851641	c873d894-cb10-4d12-a1dd-f989a1851641	تدوین برنامهٔ آموزشی سال آینده #2	\N	low	2026-08-14	ec2e7f1a-b316-428f-97f1-22bc8d50b93b	2026-07-21 18:09:05.468077+00	2026-07-21 18:09:05.468077+00	in_progress	\N	43	13.50	2026-07-31	medium
2f01124a-87cc-42c0-aff1-ff0045070c4d	0901f3f3-057f-4aae-bf11-9639f3ee3dd4	\N	00a2a3bf-94c3-4ef6-a94b-bfb72866c1cd	c873d894-cb10-4d12-a1dd-f989a1851641	برگزاری نظرسنجی رضایت شغلی #3	\N	high	2026-08-16	b391c3a5-ee7b-471d-a43f-382d4c3effbb	2026-07-21 18:09:05.468077+00	2026-07-21 18:09:05.468077+00	todo	\N	62	26.70	2026-08-01	medium
2f01124a-87cc-42c0-aff1-ff0045070c4d	0901f3f3-057f-4aae-bf11-9639f3ee3dd4	\N	00a2a3bf-94c3-4ef6-a94b-bfb72866c1cd	c873d894-cb10-4d12-a1dd-f989a1851641	برگزاری نظرسنجی رضایت شغلی #4	\N	medium	2026-08-11	b850b192-b6d8-4264-9f27-dfeacb7e56cd	2026-07-21 18:09:05.468077+00	2026-07-21 18:09:05.468077+00	archived	\N	28	27.30	2026-07-21	medium
2f01124a-87cc-42c0-aff1-ff0045070c4d	0901f3f3-057f-4aae-bf11-9639f3ee3dd4	\N	47bf13da-40a8-4016-b601-d596b7a29a50	c873d894-cb10-4d12-a1dd-f989a1851641	به‌روزرسانی پروندهٔ پرسنلی #5	\N	high	2026-07-21	4505b98b-7b49-423a-82ec-8614ac6ff88f	2026-07-21 18:09:05.468077+00	2026-07-21 18:09:05.468077+00	todo	\N	37	6.80	2026-07-10	medium
2f01124a-87cc-42c0-aff1-ff0045070c4d	0901f3f3-057f-4aae-bf11-9639f3ee3dd4	\N	eafb37ce-9111-4c51-91b5-dac320a98501	c873d894-cb10-4d12-a1dd-f989a1851641	تهیهٔ فرم ارزیابی سه‌ماهه #6	\N	high	2026-09-04	45295578-1a71-47f9-876e-045f8ff89e82	2026-07-21 18:09:05.468077+00	2026-07-21 18:09:05.468077+00	todo	\N	4	8.90	2026-08-15	medium
2f01124a-87cc-42c0-aff1-ff0045070c4d	0901f3f3-057f-4aae-bf11-9639f3ee3dd4	\N	9d19d89f-4c3d-4d3d-baf1-a4e8898f6a75	c873d894-cb10-4d12-a1dd-f989a1851641	بررسی درخواست ترفیع کارکنان #7	\N	medium	2026-07-27	ce9b5818-ce57-444b-ba8e-e0f0be400eef	2026-07-21 18:09:05.468077+00	2026-07-21 18:09:05.468077+00	completed	approved	100	7.30	2026-07-22	medium
2f01124a-87cc-42c0-aff1-ff0045070c4d	0901f3f3-057f-4aae-bf11-9639f3ee3dd4	\N	eafb37ce-9111-4c51-91b5-dac320a98501	c873d894-cb10-4d12-a1dd-f989a1851641	پیگیری درخواست‌های رفاهی کارکنان #8	\N	low	2026-07-14	8908ed77-ae47-42b0-8745-88e327300916	2026-07-21 18:09:05.468077+00	2026-07-21 18:09:05.468077+00	todo	\N	11	33.20	2026-07-01	medium
2f01124a-87cc-42c0-aff1-ff0045070c4d	0901f3f3-057f-4aae-bf11-9639f3ee3dd4	\N	eafb37ce-9111-4c51-91b5-dac320a98501	c873d894-cb10-4d12-a1dd-f989a1851641	بررسی رزومه‌های متقاضیان شغلی #9	\N	medium	2026-07-23	95e30330-d97b-4152-86b7-986b8a209102	2026-07-21 18:09:05.468077+00	2026-07-21 18:09:05.468077+00	completed	pending	100	10.00	2026-07-07	medium
2f01124a-87cc-42c0-aff1-ff0045070c4d	0901f3f3-057f-4aae-bf11-9639f3ee3dd4	\N	eafb37ce-9111-4c51-91b5-dac320a98501	c873d894-cb10-4d12-a1dd-f989a1851641	برگزاری نظرسنجی رضایت شغلی #10	\N	low	2026-07-18	1a4fb5b5-5f70-4f87-a8d7-1e5104107479	2026-07-21 18:09:05.468077+00	2026-07-21 18:09:05.468077+00	todo	\N	0	3.80	2026-07-08	medium
2f01124a-87cc-42c0-aff1-ff0045070c4d	0901f3f3-057f-4aae-bf11-9639f3ee3dd4	\N	fe42788d-ef87-41ef-8255-9e64e697d040	c873d894-cb10-4d12-a1dd-f989a1851641	بررسی درخواست ترفیع کارکنان #11	\N	medium	2026-07-19	a919556e-210a-44f8-8f54-89302186915f	2026-07-21 18:09:05.468077+00	2026-07-21 18:09:05.468077+00	archived	\N	63	35.50	2026-07-12	medium
2f01124a-87cc-42c0-aff1-ff0045070c4d	0901f3f3-057f-4aae-bf11-9639f3ee3dd4	\N	9d19d89f-4c3d-4d3d-baf1-a4e8898f6a75	c873d894-cb10-4d12-a1dd-f989a1851641	برگزاری نظرسنجی رضایت شغلی #12	\N	high	2026-08-25	fd51ed90-e9b9-4430-b02c-2e4212cef587	2026-07-21 18:09:05.468077+00	2026-07-21 18:09:05.468077+00	completed	approved	100	26.70	2026-08-08	medium
2f01124a-87cc-42c0-aff1-ff0045070c4d	0901f3f3-057f-4aae-bf11-9639f3ee3dd4	\N	eafb37ce-9111-4c51-91b5-dac320a98501	c873d894-cb10-4d12-a1dd-f989a1851641	برنامه‌ریزی مصاحبهٔ استخدامی #13	\N	low	2026-07-12	6da9a18f-44df-4f4d-a84a-a4a9da8d99ab	2026-07-21 18:09:05.468077+00	2026-07-21 18:09:05.468077+00	in_progress	\N	37	2.80	2026-06-26	medium
2f01124a-87cc-42c0-aff1-ff0045070c4d	0901f3f3-057f-4aae-bf11-9639f3ee3dd4	\N	9d19d89f-4c3d-4d3d-baf1-a4e8898f6a75	c873d894-cb10-4d12-a1dd-f989a1851641	تهیهٔ گزارش ارزیابی عملکرد #14	\N	medium	2026-07-02	e07fbb45-e688-4870-ab48-65f6110bd51c	2026-07-21 18:09:05.468077+00	2026-07-21 18:09:05.468077+00	todo	\N	20	29.80	2026-06-20	medium
2f01124a-87cc-42c0-aff1-ff0045070c4d	0901f3f3-057f-4aae-bf11-9639f3ee3dd4	\N	ae9392d2-7669-44be-a429-889e449b3eb1	c873d894-cb10-4d12-a1dd-f989a1851641	تدوین برنامهٔ آموزشی سال آینده #15	\N	medium	2026-07-28	1c3f670b-6d7c-4af4-9602-72e2abbe39a9	2026-07-21 18:09:05.468077+00	2026-07-21 18:09:05.468077+00	todo	\N	3	18.40	2026-07-07	medium
2f01124a-87cc-42c0-aff1-ff0045070c4d	0901f3f3-057f-4aae-bf11-9639f3ee3dd4	\N	eafb37ce-9111-4c51-91b5-dac320a98501	c873d894-cb10-4d12-a1dd-f989a1851641	تهیهٔ گزارش ارزیابی عملکرد #16	\N	low	2026-08-08	d8019dbd-c55d-4905-a147-1b04a113413e	2026-07-21 18:09:05.468077+00	2026-07-21 18:09:05.468077+00	todo	\N	12	14.60	2026-07-24	medium
2f01124a-87cc-42c0-aff1-ff0045070c4d	0901f3f3-057f-4aae-bf11-9639f3ee3dd4	\N	00a2a3bf-94c3-4ef6-a94b-bfb72866c1cd	c873d894-cb10-4d12-a1dd-f989a1851641	به‌روزرسانی پروندهٔ پرسنلی #17	\N	high	2026-08-18	cc52b7d2-6475-47d6-87f2-ea48d7f808b1	2026-07-21 18:09:05.468077+00	2026-07-21 18:09:05.468077+00	in_progress	\N	69	12.10	2026-07-30	medium
2f01124a-87cc-42c0-aff1-ff0045070c4d	0901f3f3-057f-4aae-bf11-9639f3ee3dd4	\N	9d19d89f-4c3d-4d3d-baf1-a4e8898f6a75	c873d894-cb10-4d12-a1dd-f989a1851641	بررسی رزومه‌های متقاضیان شغلی #18	\N	medium	2026-07-06	ee88e535-72e7-4e1b-a356-d8a44c15ffd4	2026-07-21 18:09:05.468077+00	2026-07-21 18:09:05.468077+00	in_progress	\N	73	22.90	2026-07-01	medium
2f01124a-87cc-42c0-aff1-ff0045070c4d	714a6340-704b-4e08-8b30-4d9baafcb45c	\N	fe42788d-ef87-41ef-8255-9e64e697d040	c873d894-cb10-4d12-a1dd-f989a1851641	بررسی رزومه‌های متقاضیان شغلی #19	\N	medium	2026-07-02	a6c19219-d176-4184-9291-12f5ca8362a9	2026-07-21 18:09:05.468077+00	2026-07-21 18:09:05.468077+00	todo	\N	11	13.20	2026-06-19	medium
2f01124a-87cc-42c0-aff1-ff0045070c4d	714a6340-704b-4e08-8b30-4d9baafcb45c	\N	eafb37ce-9111-4c51-91b5-dac320a98501	c873d894-cb10-4d12-a1dd-f989a1851641	بررسی رزومه‌های متقاضیان شغلی #20	\N	low	2026-07-03	c6ee9a42-39a3-498f-b15b-e3fb91cf5848	2026-07-21 18:09:05.468077+00	2026-07-21 18:09:05.468077+00	completed	pending	100	8.50	2026-06-28	medium
2f01124a-87cc-42c0-aff1-ff0045070c4d	714a6340-704b-4e08-8b30-4d9baafcb45c	\N	9d19d89f-4c3d-4d3d-baf1-a4e8898f6a75	c873d894-cb10-4d12-a1dd-f989a1851641	به‌روزرسانی آیین‌نامهٔ داخلی شرکت #21	\N	medium	2026-07-21	f2d784fd-3a8b-4194-9403-2036dedb2ce8	2026-07-21 18:09:05.468077+00	2026-07-21 18:09:05.468077+00	todo	\N	60	20.60	2026-07-16	medium
2f01124a-87cc-42c0-aff1-ff0045070c4d	714a6340-704b-4e08-8b30-4d9baafcb45c	\N	eafb37ce-9111-4c51-91b5-dac320a98501	c873d894-cb10-4d12-a1dd-f989a1851641	تهیهٔ فرم ارزیابی سه‌ماهه #22	\N	low	2026-07-10	841e47b7-c437-4bfe-b01c-64dccc205269	2026-07-21 18:09:05.468077+00	2026-07-21 18:09:05.468077+00	in_progress	\N	47	35.60	2026-06-21	medium
2f01124a-87cc-42c0-aff1-ff0045070c4d	714a6340-704b-4e08-8b30-4d9baafcb45c	\N	9d19d89f-4c3d-4d3d-baf1-a4e8898f6a75	c873d894-cb10-4d12-a1dd-f989a1851641	به‌روزرسانی آیین‌نامهٔ داخلی شرکت #23	\N	medium	2026-07-17	86dd8dea-3acf-4ffa-bef8-bc6dabe296c6	2026-07-21 18:09:05.468077+00	2026-07-21 18:09:05.468077+00	todo	\N	59	12.00	2026-07-14	medium
2f01124a-87cc-42c0-aff1-ff0045070c4d	714a6340-704b-4e08-8b30-4d9baafcb45c	\N	47bf13da-40a8-4016-b601-d596b7a29a50	c873d894-cb10-4d12-a1dd-f989a1851641	تهیهٔ گزارش ارزیابی عملکرد #24	\N	high	2026-07-25	48394b83-46f8-4451-bd4c-1d86ca712286	2026-07-21 18:09:05.468077+00	2026-07-21 18:09:05.468077+00	in_progress	\N	12	5.30	2026-07-22	medium
2f01124a-87cc-42c0-aff1-ff0045070c4d	714a6340-704b-4e08-8b30-4d9baafcb45c	\N	9d19d89f-4c3d-4d3d-baf1-a4e8898f6a75	c873d894-cb10-4d12-a1dd-f989a1851641	برگزاری جلسهٔ آموزش کارکنان جدید #25	\N	high	2026-08-23	b4b5d1c4-60d2-43c9-be43-3b46bc5d1ba8	2026-07-21 18:09:05.468077+00	2026-07-21 18:09:05.468077+00	completed	approved	100	4.30	2026-08-03	medium
2f01124a-87cc-42c0-aff1-ff0045070c4d	714a6340-704b-4e08-8b30-4d9baafcb45c	\N	fe42788d-ef87-41ef-8255-9e64e697d040	c873d894-cb10-4d12-a1dd-f989a1851641	تدوین برنامهٔ آموزشی سال آینده #26	\N	low	2026-08-06	4ec0e47c-9054-40f7-a79f-48923ea626e3	2026-07-21 18:09:05.468077+00	2026-07-21 18:09:05.468077+00	completed	approved	100	20.10	2026-07-20	medium
2f01124a-87cc-42c0-aff1-ff0045070c4d	714a6340-704b-4e08-8b30-4d9baafcb45c	\N	c873d894-cb10-4d12-a1dd-f989a1851641	c873d894-cb10-4d12-a1dd-f989a1851641	بررسی و تمدید قراردادهای پرسنلی #27	\N	high	2026-08-15	b7c81712-58af-48e4-9fbd-f5f404bdc5b1	2026-07-21 18:09:05.468077+00	2026-07-21 18:09:05.468077+00	in_progress	\N	66	32.40	2026-08-12	medium
2f01124a-87cc-42c0-aff1-ff0045070c4d	714a6340-704b-4e08-8b30-4d9baafcb45c	\N	eafb37ce-9111-4c51-91b5-dac320a98501	c873d894-cb10-4d12-a1dd-f989a1851641	تهیهٔ گزارش ارزیابی عملکرد #28	\N	low	2026-08-31	a566047d-fe8e-4f59-9d9a-145193539922	2026-07-21 18:09:05.468077+00	2026-07-21 18:09:05.468077+00	completed	approved	100	38.90	2026-08-15	medium
2f01124a-87cc-42c0-aff1-ff0045070c4d	714a6340-704b-4e08-8b30-4d9baafcb45c	\N	47bf13da-40a8-4016-b601-d596b7a29a50	c873d894-cb10-4d12-a1dd-f989a1851641	تهیهٔ فرم ارزیابی سه‌ماهه #29	\N	low	2026-06-27	02e18014-07ab-4a10-9d5f-5b23abe69183	2026-07-21 18:09:05.468077+00	2026-07-21 18:09:05.468077+00	todo	\N	55	9.70	2026-06-24	medium
2f01124a-87cc-42c0-aff1-ff0045070c4d	714a6340-704b-4e08-8b30-4d9baafcb45c	\N	47bf13da-40a8-4016-b601-d596b7a29a50	c873d894-cb10-4d12-a1dd-f989a1851641	پیگیری درخواست‌های رفاهی کارکنان #30	\N	high	2026-08-03	ea2e0768-1997-4398-be4d-3d4df2df9633	2026-07-21 18:09:05.468077+00	2026-07-21 18:09:05.468077+00	completed	approved	100	36.70	2026-07-24	medium
2f01124a-87cc-42c0-aff1-ff0045070c4d	714a6340-704b-4e08-8b30-4d9baafcb45c	\N	c873d894-cb10-4d12-a1dd-f989a1851641	c873d894-cb10-4d12-a1dd-f989a1851641	تهیهٔ فرم ارزیابی سه‌ماهه #31	\N	high	2026-07-29	2bd504ba-41e2-4128-9225-41a65d52f1ef	2026-07-21 18:09:05.468077+00	2026-07-21 18:09:05.468077+00	todo	\N	41	34.60	2026-07-10	medium
2f01124a-87cc-42c0-aff1-ff0045070c4d	714a6340-704b-4e08-8b30-4d9baafcb45c	\N	ae9392d2-7669-44be-a429-889e449b3eb1	c873d894-cb10-4d12-a1dd-f989a1851641	تدوین برنامهٔ آموزشی سال آینده #32	\N	high	2026-07-07	7d6ff1ad-18a8-4940-a918-a0af6cffebcf	2026-07-21 18:09:05.468077+00	2026-07-21 18:09:05.468077+00	completed	rejected	100	31.70	2026-06-16	medium
2f01124a-87cc-42c0-aff1-ff0045070c4d	714a6340-704b-4e08-8b30-4d9baafcb45c	\N	c873d894-cb10-4d12-a1dd-f989a1851641	c873d894-cb10-4d12-a1dd-f989a1851641	تدوین برنامهٔ آموزشی سال آینده #33	\N	high	2026-07-01	0283082f-3a5c-462c-ad41-2f308b5fadec	2026-07-21 18:09:05.468077+00	2026-07-21 18:09:05.468077+00	in_progress	\N	74	30.80	2026-06-25	medium
2f01124a-87cc-42c0-aff1-ff0045070c4d	714a6340-704b-4e08-8b30-4d9baafcb45c	\N	c873d894-cb10-4d12-a1dd-f989a1851641	c873d894-cb10-4d12-a1dd-f989a1851641	برگزاری نظرسنجی رضایت شغلی #34	\N	medium	2026-07-27	f7537538-73fb-4866-82aa-3bfe5893bdf2	2026-07-21 18:09:05.468077+00	2026-07-21 18:09:05.468077+00	todo	\N	68	35.40	2026-07-22	medium
2f01124a-87cc-42c0-aff1-ff0045070c4d	714a6340-704b-4e08-8b30-4d9baafcb45c	\N	fe42788d-ef87-41ef-8255-9e64e697d040	c873d894-cb10-4d12-a1dd-f989a1851641	تدوین برنامهٔ آموزشی سال آینده #35	\N	high	2026-07-27	922b4b1b-1432-4507-92e3-5f4e0f83033f	2026-07-21 18:09:05.468077+00	2026-07-21 18:09:05.468077+00	in_progress	\N	60	3.40	2026-07-10	medium
2f01124a-87cc-42c0-aff1-ff0045070c4d	714a6340-704b-4e08-8b30-4d9baafcb45c	\N	9d19d89f-4c3d-4d3d-baf1-a4e8898f6a75	c873d894-cb10-4d12-a1dd-f989a1851641	تدوین برنامهٔ آموزشی سال آینده #36	\N	high	2026-07-16	87be796f-2f89-4a96-9e4f-db1eacb49eb9	2026-07-21 18:09:05.468077+00	2026-07-21 18:09:05.468077+00	in_progress	\N	51	3.50	2026-06-25	medium
2f01124a-87cc-42c0-aff1-ff0045070c4d	4ceaa4b3-563d-4465-b395-a62490d00060	\N	9d19d89f-4c3d-4d3d-baf1-a4e8898f6a75	c873d894-cb10-4d12-a1dd-f989a1851641	بررسی درخواست ترفیع کارکنان #37	\N	medium	2026-08-19	68bd9a3a-84ff-477f-b0e4-ff67b3840f97	2026-07-21 18:09:05.468077+00	2026-07-21 18:09:05.468077+00	completed	approved	100	36.10	2026-08-02	medium
2f01124a-87cc-42c0-aff1-ff0045070c4d	4ceaa4b3-563d-4465-b395-a62490d00060	\N	c873d894-cb10-4d12-a1dd-f989a1851641	c873d894-cb10-4d12-a1dd-f989a1851641	به‌روزرسانی آیین‌نامهٔ داخلی شرکت #38	\N	medium	2026-08-18	a86d0eb8-c92f-4e6a-8bd4-e72bbcc277fd	2026-07-21 18:09:05.468077+00	2026-07-21 18:09:05.468077+00	in_progress	\N	62	34.60	2026-08-07	medium
2f01124a-87cc-42c0-aff1-ff0045070c4d	4ceaa4b3-563d-4465-b395-a62490d00060	\N	eafb37ce-9111-4c51-91b5-dac320a98501	c873d894-cb10-4d12-a1dd-f989a1851641	تهیهٔ گزارش ارزیابی عملکرد #39	\N	medium	2026-08-19	2af8aa3e-7614-468b-9324-830f49f601e7	2026-07-21 18:09:05.468077+00	2026-07-21 18:09:05.468077+00	todo	\N	56	31.40	2026-08-10	medium
2f01124a-87cc-42c0-aff1-ff0045070c4d	4ceaa4b3-563d-4465-b395-a62490d00060	\N	9d19d89f-4c3d-4d3d-baf1-a4e8898f6a75	c873d894-cb10-4d12-a1dd-f989a1851641	تدوین برنامهٔ آموزشی سال آینده #40	\N	high	2026-08-16	62cc763a-f9d0-4d35-af04-ebeb88a4381d	2026-07-21 18:09:05.468077+00	2026-07-21 18:09:05.468077+00	in_progress	\N	11	9.10	2026-08-01	medium
2f01124a-87cc-42c0-aff1-ff0045070c4d	4ceaa4b3-563d-4465-b395-a62490d00060	\N	00a2a3bf-94c3-4ef6-a94b-bfb72866c1cd	c873d894-cb10-4d12-a1dd-f989a1851641	برگزاری نظرسنجی رضایت شغلی #41	\N	high	2026-08-19	d7ac0009-d8b7-4e1e-b510-9fd3293200fb	2026-07-21 18:09:05.468077+00	2026-07-21 18:09:05.468077+00	in_progress	\N	47	33.20	2026-08-02	medium
2f01124a-87cc-42c0-aff1-ff0045070c4d	4ceaa4b3-563d-4465-b395-a62490d00060	\N	ae9392d2-7669-44be-a429-889e449b3eb1	c873d894-cb10-4d12-a1dd-f989a1851641	به‌روزرسانی پروندهٔ پرسنلی #42	\N	high	2026-07-01	37515256-efbf-4fd0-ad26-b0fea36b4bec	2026-07-21 18:09:05.468077+00	2026-07-21 18:09:05.468077+00	todo	\N	51	7.20	2026-06-20	medium
2f01124a-87cc-42c0-aff1-ff0045070c4d	4ceaa4b3-563d-4465-b395-a62490d00060	\N	47bf13da-40a8-4016-b601-d596b7a29a50	c873d894-cb10-4d12-a1dd-f989a1851641	برگزاری جلسهٔ آموزش کارکنان جدید #43	\N	low	2026-06-24	13555bd2-9129-4fd3-827a-fac91d5cd82e	2026-07-21 18:09:05.468077+00	2026-07-21 18:09:05.468077+00	completed	pending	100	33.80	2026-06-17	medium
2f01124a-87cc-42c0-aff1-ff0045070c4d	4ceaa4b3-563d-4465-b395-a62490d00060	\N	00a2a3bf-94c3-4ef6-a94b-bfb72866c1cd	c873d894-cb10-4d12-a1dd-f989a1851641	بررسی درخواست ترفیع کارکنان #44	\N	medium	2026-07-18	abe794b8-3d9f-4038-ba04-17c1afca457e	2026-07-21 18:09:05.468077+00	2026-07-21 18:09:05.468077+00	todo	\N	25	12.40	2026-07-15	medium
2f01124a-87cc-42c0-aff1-ff0045070c4d	4ceaa4b3-563d-4465-b395-a62490d00060	\N	47bf13da-40a8-4016-b601-d596b7a29a50	c873d894-cb10-4d12-a1dd-f989a1851641	پیگیری مرخصی و مأموریت کارکنان #45	\N	low	2026-07-31	5b7005e9-e790-4f14-8208-75fad254a4d3	2026-07-21 18:09:05.468077+00	2026-07-21 18:09:05.468077+00	completed	approved	100	11.20	2026-07-26	medium
2f01124a-87cc-42c0-aff1-ff0045070c4d	4ceaa4b3-563d-4465-b395-a62490d00060	\N	fe42788d-ef87-41ef-8255-9e64e697d040	c873d894-cb10-4d12-a1dd-f989a1851641	تدوین برنامهٔ آموزشی سال آینده #46	\N	high	2026-08-27	e2578e49-7df6-4fe8-aaca-f584207c933d	2026-07-21 18:09:05.468077+00	2026-07-21 18:09:05.468077+00	completed	approved	100	15.30	2026-08-10	medium
2f01124a-87cc-42c0-aff1-ff0045070c4d	4ceaa4b3-563d-4465-b395-a62490d00060	\N	00a2a3bf-94c3-4ef6-a94b-bfb72866c1cd	c873d894-cb10-4d12-a1dd-f989a1851641	به‌روزرسانی آیین‌نامهٔ داخلی شرکت #47	\N	low	2026-08-06	738811ca-d209-4317-ba61-71d8c4982638	2026-07-21 18:09:05.468077+00	2026-07-21 18:09:05.468077+00	in_progress	\N	49	3.90	2026-08-02	medium
2f01124a-87cc-42c0-aff1-ff0045070c4d	4ceaa4b3-563d-4465-b395-a62490d00060	\N	47bf13da-40a8-4016-b601-d596b7a29a50	c873d894-cb10-4d12-a1dd-f989a1851641	پیگیری مرخصی و مأموریت کارکنان #48	\N	low	2026-07-08	44536812-0089-4587-80e0-7163e2463207	2026-07-21 18:09:05.468077+00	2026-07-21 18:09:05.468077+00	completed	pending	100	27.80	2026-06-29	medium
2f01124a-87cc-42c0-aff1-ff0045070c4d	4ceaa4b3-563d-4465-b395-a62490d00060	\N	9d19d89f-4c3d-4d3d-baf1-a4e8898f6a75	c873d894-cb10-4d12-a1dd-f989a1851641	برنامه‌ریزی رویداد تیم‌سازی #49	\N	low	2026-06-19	9a441833-5276-45be-85c8-3743a63d67b3	2026-07-21 18:09:05.468077+00	2026-07-21 18:09:05.468077+00	completed	approved	100	26.60	2026-06-17	medium
2f01124a-87cc-42c0-aff1-ff0045070c4d	4ceaa4b3-563d-4465-b395-a62490d00060	\N	ae9392d2-7669-44be-a429-889e449b3eb1	c873d894-cb10-4d12-a1dd-f989a1851641	تدوین برنامهٔ آموزشی سال آینده #50	\N	medium	2026-07-10	576c52a0-b53b-40c6-8972-4a0c0d2d0a27	2026-07-21 18:09:05.468077+00	2026-07-21 18:09:05.468077+00	todo	\N	35	18.10	2026-06-30	medium
2f01124a-87cc-42c0-aff1-ff0045070c4d	4ceaa4b3-563d-4465-b395-a62490d00060	\N	fe42788d-ef87-41ef-8255-9e64e697d040	c873d894-cb10-4d12-a1dd-f989a1851641	برگزاری جلسهٔ آموزش کارکنان جدید #51	\N	medium	2026-07-25	773878b0-523d-4242-8593-da562d55fabd	2026-07-21 18:09:05.468077+00	2026-07-21 18:09:05.468077+00	in_progress	\N	38	27.70	2026-07-15	medium
2f01124a-87cc-42c0-aff1-ff0045070c4d	4ceaa4b3-563d-4465-b395-a62490d00060	\N	47bf13da-40a8-4016-b601-d596b7a29a50	c873d894-cb10-4d12-a1dd-f989a1851641	بررسی و تمدید قراردادهای پرسنلی #52	\N	high	2026-06-24	0cb7a975-21b7-4bf1-a056-c7dfc2ebaed8	2026-07-21 18:09:05.468077+00	2026-07-21 18:09:05.468077+00	completed	approved	100	38.70	2026-06-22	medium
2f01124a-87cc-42c0-aff1-ff0045070c4d	4ceaa4b3-563d-4465-b395-a62490d00060	\N	47bf13da-40a8-4016-b601-d596b7a29a50	c873d894-cb10-4d12-a1dd-f989a1851641	تدوین برنامهٔ آموزشی سال آینده #53	\N	medium	2026-08-11	4f4eddba-c4af-40a0-9cfa-4d2c1ba8bf98	2026-07-21 18:09:05.468077+00	2026-07-21 18:09:05.468077+00	in_progress	\N	38	28.00	2026-07-21	medium
2f01124a-87cc-42c0-aff1-ff0045070c4d	4ceaa4b3-563d-4465-b395-a62490d00060	\N	fe42788d-ef87-41ef-8255-9e64e697d040	c873d894-cb10-4d12-a1dd-f989a1851641	پیگیری مرخصی و مأموریت کارکنان #54	\N	medium	2026-07-17	6960abcf-44de-4ed9-89fa-17ef1172f5ba	2026-07-21 18:09:05.468077+00	2026-07-21 18:09:05.468077+00	todo	\N	35	11.90	2026-07-07	medium
2f01124a-87cc-42c0-aff1-ff0045070c4d	9af7d195-e857-469f-8432-97a00100cd49	\N	eafb37ce-9111-4c51-91b5-dac320a98501	c873d894-cb10-4d12-a1dd-f989a1851641	برگزاری نظرسنجی رضایت شغلی #55	\N	low	2026-07-13	5df649d3-ae5e-4583-9b04-a794d7d29654	2026-07-21 18:09:05.468077+00	2026-07-21 18:09:05.468077+00	completed	approved	100	36.20	2026-06-25	medium
2f01124a-87cc-42c0-aff1-ff0045070c4d	9af7d195-e857-469f-8432-97a00100cd49	\N	47bf13da-40a8-4016-b601-d596b7a29a50	c873d894-cb10-4d12-a1dd-f989a1851641	به‌روزرسانی پروندهٔ پرسنلی #56	\N	low	2026-07-12	71277fd6-8b84-4bac-8718-63fa65061396	2026-07-21 18:09:05.468077+00	2026-07-21 18:09:05.468077+00	completed	approved	100	26.90	2026-07-06	medium
2f01124a-87cc-42c0-aff1-ff0045070c4d	9af7d195-e857-469f-8432-97a00100cd49	\N	9d19d89f-4c3d-4d3d-baf1-a4e8898f6a75	c873d894-cb10-4d12-a1dd-f989a1851641	تهیهٔ فرم ارزیابی سه‌ماهه #57	\N	medium	2026-08-28	147bc3ff-3727-48a1-8c40-270ce7dacbe0	2026-07-21 18:09:05.468077+00	2026-07-21 18:09:05.468077+00	in_progress	\N	4	24.20	2026-08-13	medium
2f01124a-87cc-42c0-aff1-ff0045070c4d	9af7d195-e857-469f-8432-97a00100cd49	\N	ae9392d2-7669-44be-a429-889e449b3eb1	c873d894-cb10-4d12-a1dd-f989a1851641	پیگیری مرخصی و مأموریت کارکنان #58	\N	high	2026-07-16	9653d821-db16-4cad-88c6-385e4b439999	2026-07-21 18:09:05.468077+00	2026-07-21 18:09:05.468077+00	todo	\N	60	36.40	2026-07-07	medium
2f01124a-87cc-42c0-aff1-ff0045070c4d	9af7d195-e857-469f-8432-97a00100cd49	\N	eafb37ce-9111-4c51-91b5-dac320a98501	c873d894-cb10-4d12-a1dd-f989a1851641	تهیهٔ گزارش غیبت و تأخیر #59	\N	low	2026-07-29	85d21eaa-0cf7-4417-9ebc-5b851e40b956	2026-07-21 18:09:05.468077+00	2026-07-21 18:09:05.468077+00	in_progress	\N	71	8.90	2026-07-18	medium
2f01124a-87cc-42c0-aff1-ff0045070c4d	9af7d195-e857-469f-8432-97a00100cd49	\N	c873d894-cb10-4d12-a1dd-f989a1851641	c873d894-cb10-4d12-a1dd-f989a1851641	برگزاری نظرسنجی رضایت شغلی #60	\N	low	2026-07-21	5456cbe4-5161-4a42-b720-294d552929aa	2026-07-21 18:09:05.468077+00	2026-07-21 18:09:05.468077+00	completed	approved	100	38.00	2026-07-02	medium
2f01124a-87cc-42c0-aff1-ff0045070c4d	9af7d195-e857-469f-8432-97a00100cd49	\N	9d19d89f-4c3d-4d3d-baf1-a4e8898f6a75	c873d894-cb10-4d12-a1dd-f989a1851641	به‌روزرسانی پروندهٔ پرسنلی #61	\N	medium	2026-07-17	a9cd71a7-c643-4d4c-8e4e-baaa8248792a	2026-07-21 18:09:05.468077+00	2026-07-21 18:09:05.468077+00	completed	approved	100	18.00	2026-07-08	medium
2f01124a-87cc-42c0-aff1-ff0045070c4d	9af7d195-e857-469f-8432-97a00100cd49	\N	9d19d89f-4c3d-4d3d-baf1-a4e8898f6a75	c873d894-cb10-4d12-a1dd-f989a1851641	به‌روزرسانی آیین‌نامهٔ داخلی شرکت #62	\N	medium	2026-07-22	f3998b4f-4cc5-46c5-b918-f8d53d0c3a10	2026-07-21 18:09:05.468077+00	2026-07-21 18:09:05.468077+00	in_progress	\N	15	19.90	2026-07-02	medium
2f01124a-87cc-42c0-aff1-ff0045070c4d	9af7d195-e857-469f-8432-97a00100cd49	\N	47bf13da-40a8-4016-b601-d596b7a29a50	c873d894-cb10-4d12-a1dd-f989a1851641	برنامه‌ریزی مصاحبهٔ استخدامی #63	\N	medium	2026-09-05	f523823c-bc60-48c2-9362-127348657d63	2026-07-21 18:09:05.468077+00	2026-07-21 18:09:05.468077+00	completed	approved	100	35.80	2026-08-15	medium
2f01124a-87cc-42c0-aff1-ff0045070c4d	9af7d195-e857-469f-8432-97a00100cd49	\N	ae9392d2-7669-44be-a429-889e449b3eb1	c873d894-cb10-4d12-a1dd-f989a1851641	بررسی و تمدید قراردادهای پرسنلی #64	\N	medium	2026-08-24	ec1b092b-5256-48af-999c-3b9496513c33	2026-07-21 18:09:05.468077+00	2026-07-21 18:09:05.468077+00	todo	\N	52	4.10	2026-08-10	medium
2f01124a-87cc-42c0-aff1-ff0045070c4d	9af7d195-e857-469f-8432-97a00100cd49	\N	47bf13da-40a8-4016-b601-d596b7a29a50	c873d894-cb10-4d12-a1dd-f989a1851641	پیگیری درخواست‌های رفاهی کارکنان #65	\N	medium	2026-07-02	f72b01d0-caf8-4d30-9d3c-f5ddb123738b	2026-07-21 18:09:05.468077+00	2026-07-21 18:09:05.468077+00	todo	\N	72	35.90	2026-06-24	medium
2f01124a-87cc-42c0-aff1-ff0045070c4d	9af7d195-e857-469f-8432-97a00100cd49	\N	fe42788d-ef87-41ef-8255-9e64e697d040	c873d894-cb10-4d12-a1dd-f989a1851641	برگزاری نظرسنجی رضایت شغلی #66	\N	low	2026-07-13	41b550a7-e67f-4d72-afe0-d1d5be9b30ae	2026-07-21 18:09:05.468077+00	2026-07-21 18:09:05.468077+00	todo	\N	62	14.60	2026-07-06	medium
2f01124a-87cc-42c0-aff1-ff0045070c4d	9af7d195-e857-469f-8432-97a00100cd49	\N	00a2a3bf-94c3-4ef6-a94b-bfb72866c1cd	c873d894-cb10-4d12-a1dd-f989a1851641	بررسی رزومه‌های متقاضیان شغلی #67	\N	medium	2026-07-29	0bffbf7d-5eea-4907-9751-7ae4ecda760f	2026-07-21 18:09:05.468077+00	2026-07-21 18:09:05.468077+00	in_progress	\N	35	10.00	2026-07-26	medium
2f01124a-87cc-42c0-aff1-ff0045070c4d	9af7d195-e857-469f-8432-97a00100cd49	\N	47bf13da-40a8-4016-b601-d596b7a29a50	c873d894-cb10-4d12-a1dd-f989a1851641	برنامه‌ریزی رویداد تیم‌سازی #68	\N	low	2026-07-29	37a989b6-1229-458a-8a8e-6867c1955b15	2026-07-21 18:09:05.468077+00	2026-07-21 18:09:05.468077+00	todo	\N	16	25.40	2026-07-22	medium
2f01124a-87cc-42c0-aff1-ff0045070c4d	9af7d195-e857-469f-8432-97a00100cd49	\N	eafb37ce-9111-4c51-91b5-dac320a98501	c873d894-cb10-4d12-a1dd-f989a1851641	برنامه‌ریزی رویداد تیم‌سازی #69	\N	medium	2026-07-26	1a54dc83-0080-459e-bdba-e21fcb905880	2026-07-21 18:09:05.468077+00	2026-07-21 18:09:05.468077+00	in_progress	\N	0	3.40	2026-07-11	medium
2f01124a-87cc-42c0-aff1-ff0045070c4d	9af7d195-e857-469f-8432-97a00100cd49	\N	00a2a3bf-94c3-4ef6-a94b-bfb72866c1cd	c873d894-cb10-4d12-a1dd-f989a1851641	بررسی درخواست ترفیع کارکنان #70	\N	medium	2026-07-11	a9678a6b-54e9-4e8b-bb7a-239f78928c84	2026-07-21 18:09:05.468077+00	2026-07-21 18:09:05.468077+00	archived	\N	67	9.20	2026-07-09	medium
2f01124a-87cc-42c0-aff1-ff0045070c4d	9af7d195-e857-469f-8432-97a00100cd49	\N	eafb37ce-9111-4c51-91b5-dac320a98501	c873d894-cb10-4d12-a1dd-f989a1851641	برگزاری جلسهٔ آموزش کارکنان جدید #71	\N	high	2026-08-04	e8780ede-b928-4b0e-a434-2ca5796acca7	2026-07-21 18:09:05.468077+00	2026-07-21 18:09:05.468077+00	todo	\N	44	13.90	2026-07-26	medium
2f01124a-87cc-42c0-aff1-ff0045070c4d	9af7d195-e857-469f-8432-97a00100cd49	\N	c873d894-cb10-4d12-a1dd-f989a1851641	c873d894-cb10-4d12-a1dd-f989a1851641	به‌روزرسانی آیین‌نامهٔ داخلی شرکت #72	\N	low	2026-08-07	bfa73f7b-0c09-4a88-a342-63cb0a58e019	2026-07-21 18:09:05.468077+00	2026-07-21 18:09:05.468077+00	in_progress	\N	8	33.30	2026-07-18	medium
2f01124a-87cc-42c0-aff1-ff0045070c4d	f84f219e-7c01-44ff-bc62-1ee898da0737	\N	9d19d89f-4c3d-4d3d-baf1-a4e8898f6a75	c873d894-cb10-4d12-a1dd-f989a1851641	تدوین برنامهٔ آموزشی سال آینده #73	\N	high	2026-08-02	b36489b5-8b56-42f1-b318-532221164062	2026-07-21 18:09:05.468077+00	2026-07-21 18:09:05.468077+00	in_progress	\N	43	18.50	2026-07-15	medium
2f01124a-87cc-42c0-aff1-ff0045070c4d	f84f219e-7c01-44ff-bc62-1ee898da0737	\N	eafb37ce-9111-4c51-91b5-dac320a98501	c873d894-cb10-4d12-a1dd-f989a1851641	پیگیری درخواست‌های رفاهی کارکنان #74	\N	low	2026-07-24	79060e10-6cf4-4f2e-8cca-10bbbb806d3f	2026-07-21 18:09:05.468077+00	2026-07-21 18:09:05.468077+00	todo	\N	21	38.00	2026-07-07	medium
2f01124a-87cc-42c0-aff1-ff0045070c4d	f84f219e-7c01-44ff-bc62-1ee898da0737	\N	47bf13da-40a8-4016-b601-d596b7a29a50	c873d894-cb10-4d12-a1dd-f989a1851641	برگزاری جلسهٔ آموزش کارکنان جدید #75	\N	high	2026-06-26	dbd559dc-2bf5-417e-a82b-40c5ca1ed6be	2026-07-21 18:09:05.468077+00	2026-07-21 18:09:05.468077+00	in_progress	\N	16	10.00	2026-06-17	medium
2f01124a-87cc-42c0-aff1-ff0045070c4d	f84f219e-7c01-44ff-bc62-1ee898da0737	\N	c873d894-cb10-4d12-a1dd-f989a1851641	c873d894-cb10-4d12-a1dd-f989a1851641	به‌روزرسانی پروندهٔ پرسنلی #76	\N	high	2026-07-06	f5ac80d7-556d-47a6-aca7-668a9d06ae23	2026-07-21 18:09:05.468077+00	2026-07-21 18:09:05.468077+00	completed	approved	100	32.10	2026-06-23	medium
2f01124a-87cc-42c0-aff1-ff0045070c4d	f84f219e-7c01-44ff-bc62-1ee898da0737	\N	fe42788d-ef87-41ef-8255-9e64e697d040	c873d894-cb10-4d12-a1dd-f989a1851641	بررسی رزومه‌های متقاضیان شغلی #77	\N	high	2026-08-10	7f60bd0f-ff37-4aa0-9d21-a21680b52dc3	2026-07-21 18:09:05.468077+00	2026-07-21 18:09:05.468077+00	completed	approved	100	39.80	2026-07-20	medium
2f01124a-87cc-42c0-aff1-ff0045070c4d	f84f219e-7c01-44ff-bc62-1ee898da0737	\N	eafb37ce-9111-4c51-91b5-dac320a98501	c873d894-cb10-4d12-a1dd-f989a1851641	بررسی رزومه‌های متقاضیان شغلی #78	\N	high	2026-07-29	db4c7906-a3fb-4f46-9e14-7fa103b3d353	2026-07-21 18:09:05.468077+00	2026-07-21 18:09:05.468077+00	todo	\N	14	17.80	2026-07-27	medium
2f01124a-87cc-42c0-aff1-ff0045070c4d	f84f219e-7c01-44ff-bc62-1ee898da0737	\N	fe42788d-ef87-41ef-8255-9e64e697d040	c873d894-cb10-4d12-a1dd-f989a1851641	برنامه‌ریزی رویداد تیم‌سازی #79	\N	high	2026-07-31	9c082687-7f78-447b-a5fc-20bcf9119490	2026-07-21 18:09:05.468077+00	2026-07-21 18:09:05.468077+00	todo	\N	19	9.80	2026-07-21	medium
2f01124a-87cc-42c0-aff1-ff0045070c4d	f84f219e-7c01-44ff-bc62-1ee898da0737	\N	eafb37ce-9111-4c51-91b5-dac320a98501	c873d894-cb10-4d12-a1dd-f989a1851641	پیگیری مرخصی و مأموریت کارکنان #80	\N	high	2026-07-17	d5e7f03e-2512-447d-9df8-37aeb6fe39ae	2026-07-21 18:09:05.468077+00	2026-07-21 18:09:05.468077+00	completed	approved	100	12.30	2026-07-12	medium
2f01124a-87cc-42c0-aff1-ff0045070c4d	f84f219e-7c01-44ff-bc62-1ee898da0737	\N	ae9392d2-7669-44be-a429-889e449b3eb1	c873d894-cb10-4d12-a1dd-f989a1851641	بررسی و تمدید قراردادهای پرسنلی #81	\N	high	2026-08-13	20edcadc-569e-4e74-95f8-20bb8c131e63	2026-07-21 18:09:05.468077+00	2026-07-21 18:09:05.468077+00	completed	approved	100	25.50	2026-08-08	medium
2f01124a-87cc-42c0-aff1-ff0045070c4d	f84f219e-7c01-44ff-bc62-1ee898da0737	\N	9d19d89f-4c3d-4d3d-baf1-a4e8898f6a75	c873d894-cb10-4d12-a1dd-f989a1851641	برنامه‌ریزی رویداد تیم‌سازی #82	\N	low	2026-08-10	b5e12bcb-9390-4656-bd94-fef0cf0d20bb	2026-07-21 18:09:05.468077+00	2026-07-21 18:09:05.468077+00	todo	\N	77	9.60	2026-08-05	medium
2f01124a-87cc-42c0-aff1-ff0045070c4d	f84f219e-7c01-44ff-bc62-1ee898da0737	\N	9d19d89f-4c3d-4d3d-baf1-a4e8898f6a75	c873d894-cb10-4d12-a1dd-f989a1851641	به‌روزرسانی آیین‌نامهٔ داخلی شرکت #83	\N	low	2026-07-23	1fd7a47f-b32e-47f7-a086-2d15e2dcca02	2026-07-21 18:09:05.468077+00	2026-07-21 18:09:05.468077+00	completed	rejected	100	3.50	2026-07-08	medium
2f01124a-87cc-42c0-aff1-ff0045070c4d	f84f219e-7c01-44ff-bc62-1ee898da0737	\N	fe42788d-ef87-41ef-8255-9e64e697d040	c873d894-cb10-4d12-a1dd-f989a1851641	پیگیری درخواست‌های رفاهی کارکنان #84	\N	low	2026-08-16	98710ca3-abde-4dd5-b0f4-152a3444ed01	2026-07-21 18:09:05.468077+00	2026-07-21 18:09:05.468077+00	in_progress	\N	0	2.50	2026-07-30	medium
2f01124a-87cc-42c0-aff1-ff0045070c4d	f84f219e-7c01-44ff-bc62-1ee898da0737	\N	c873d894-cb10-4d12-a1dd-f989a1851641	c873d894-cb10-4d12-a1dd-f989a1851641	پیگیری مرخصی و مأموریت کارکنان #85	\N	medium	2026-08-28	97ad44c7-dd21-44b8-ad99-76961a5fe972	2026-07-21 18:09:05.468077+00	2026-07-21 18:09:05.468077+00	todo	\N	19	38.10	2026-08-08	medium
2f01124a-87cc-42c0-aff1-ff0045070c4d	f84f219e-7c01-44ff-bc62-1ee898da0737	\N	47bf13da-40a8-4016-b601-d596b7a29a50	c873d894-cb10-4d12-a1dd-f989a1851641	بررسی درخواست ترفیع کارکنان #86	\N	medium	2026-08-06	af425a38-1f24-41d5-aa1e-0eb6f3a07ae3	2026-07-21 18:09:05.468077+00	2026-07-21 18:09:05.468077+00	completed	approved	100	26.50	2026-08-01	medium
2f01124a-87cc-42c0-aff1-ff0045070c4d	f84f219e-7c01-44ff-bc62-1ee898da0737	\N	fe42788d-ef87-41ef-8255-9e64e697d040	c873d894-cb10-4d12-a1dd-f989a1851641	بررسی رزومه‌های متقاضیان شغلی #87	\N	low	2026-07-18	b7125778-6ffe-44dd-9564-a4ee010d0730	2026-07-21 18:09:05.468077+00	2026-07-21 18:09:05.468077+00	in_progress	\N	22	35.20	2026-07-02	medium
2f01124a-87cc-42c0-aff1-ff0045070c4d	f84f219e-7c01-44ff-bc62-1ee898da0737	\N	47bf13da-40a8-4016-b601-d596b7a29a50	c873d894-cb10-4d12-a1dd-f989a1851641	تهیهٔ فرم ارزیابی سه‌ماهه #88	\N	high	2026-07-21	1b9aecc9-64cc-4f9f-a8a3-19a2d9072568	2026-07-21 18:09:05.468077+00	2026-07-21 18:09:05.468077+00	in_progress	\N	14	5.60	2026-07-09	medium
2f01124a-87cc-42c0-aff1-ff0045070c4d	f84f219e-7c01-44ff-bc62-1ee898da0737	\N	47bf13da-40a8-4016-b601-d596b7a29a50	c873d894-cb10-4d12-a1dd-f989a1851641	پیگیری مرخصی و مأموریت کارکنان #89	\N	high	2026-06-22	9aae65b2-5ce3-4fb4-8c27-606e5e04f2eb	2026-07-21 18:09:05.468077+00	2026-07-21 18:09:05.468077+00	todo	\N	21	14.50	2026-06-16	medium
2f01124a-87cc-42c0-aff1-ff0045070c4d	f84f219e-7c01-44ff-bc62-1ee898da0737	\N	fe42788d-ef87-41ef-8255-9e64e697d040	c873d894-cb10-4d12-a1dd-f989a1851641	پیگیری درخواست‌های رفاهی کارکنان #90	\N	medium	2026-08-05	347243f0-55d2-4d3d-90c5-94c3e145d9b6	2026-07-21 18:09:05.468077+00	2026-07-21 18:09:05.468077+00	completed	approved	100	8.90	2026-08-01	medium
2f01124a-87cc-42c0-aff1-ff0045070c4d	\N	\N	fe42788d-ef87-41ef-8255-9e64e697d040	fe42788d-ef87-41ef-8255-9e64e697d040	تهیهٔ گزارش غیبت و تأخیر #91	\N	medium	2026-07-25	d478c990-a538-495d-b0ce-56d3f2722cd4	2026-07-21 18:09:05.468077+00	2026-07-21 18:09:05.468077+00	in_progress	\N	61	32.40	2026-07-15	medium
2f01124a-87cc-42c0-aff1-ff0045070c4d	\N	\N	eafb37ce-9111-4c51-91b5-dac320a98501	eafb37ce-9111-4c51-91b5-dac320a98501	به‌روزرسانی پروندهٔ پرسنلی #92	\N	high	2026-06-29	1b4e95a8-739a-41ef-b345-36f49bc28c30	2026-07-21 18:09:05.468077+00	2026-07-21 18:09:05.468077+00	todo	\N	7	39.30	2026-06-23	medium
2f01124a-87cc-42c0-aff1-ff0045070c4d	\N	\N	47bf13da-40a8-4016-b601-d596b7a29a50	47bf13da-40a8-4016-b601-d596b7a29a50	بررسی درخواست ترفیع کارکنان #93	\N	high	2026-07-07	86cd7871-6062-4920-b4e8-36664446869d	2026-07-21 18:09:05.468077+00	2026-07-21 18:09:05.468077+00	todo	\N	61	32.50	2026-06-22	medium
2f01124a-87cc-42c0-aff1-ff0045070c4d	\N	\N	eafb37ce-9111-4c51-91b5-dac320a98501	eafb37ce-9111-4c51-91b5-dac320a98501	تدوین برنامهٔ آموزشی سال آینده #94	\N	low	2026-07-23	24818788-4386-42a8-ba69-a38153fed81e	2026-07-21 18:09:05.468077+00	2026-07-21 18:09:05.468077+00	completed	approved	100	34.80	2026-07-10	medium
2f01124a-87cc-42c0-aff1-ff0045070c4d	\N	\N	47bf13da-40a8-4016-b601-d596b7a29a50	47bf13da-40a8-4016-b601-d596b7a29a50	برنامه‌ریزی رویداد تیم‌سازی #95	\N	medium	2026-08-18	3dc16af2-b476-4795-94c7-821f31653dcc	2026-07-21 18:09:05.468077+00	2026-07-21 18:09:05.468077+00	archived	\N	14	35.70	2026-08-12	medium
2f01124a-87cc-42c0-aff1-ff0045070c4d	\N	\N	fe42788d-ef87-41ef-8255-9e64e697d040	fe42788d-ef87-41ef-8255-9e64e697d040	پیگیری مرخصی و مأموریت کارکنان #96	\N	medium	2026-06-30	16e7bd05-fba4-44b7-bf5c-b2a3141f44ae	2026-07-21 18:09:05.468077+00	2026-07-21 18:09:05.468077+00	todo	\N	1	28.80	2026-06-20	medium
2f01124a-87cc-42c0-aff1-ff0045070c4d	\N	\N	eafb37ce-9111-4c51-91b5-dac320a98501	eafb37ce-9111-4c51-91b5-dac320a98501	برگزاری جلسهٔ آموزش کارکنان جدید #97	\N	high	2026-08-11	0416a8b8-7ac8-483e-ae48-623a257f761f	2026-07-21 18:09:05.468077+00	2026-07-21 18:09:05.468077+00	completed	pending	100	35.20	2026-07-22	medium
2f01124a-87cc-42c0-aff1-ff0045070c4d	\N	\N	ae9392d2-7669-44be-a429-889e449b3eb1	ae9392d2-7669-44be-a429-889e449b3eb1	تهیهٔ فرم ارزیابی سه‌ماهه #98	\N	high	2026-07-30	552feeb5-f722-4a8b-b4c7-d3795dd4018b	2026-07-21 18:09:05.468077+00	2026-07-21 18:09:05.468077+00	completed	pending	100	29.60	2026-07-25	medium
2f01124a-87cc-42c0-aff1-ff0045070c4d	\N	\N	fe42788d-ef87-41ef-8255-9e64e697d040	fe42788d-ef87-41ef-8255-9e64e697d040	تهیهٔ گزارش ارزیابی عملکرد #99	\N	high	2026-08-11	f619f637-6818-4f3c-98b0-fce861d705d4	2026-07-21 18:09:05.468077+00	2026-07-21 18:09:05.468077+00	in_progress	\N	78	4.10	2026-07-28	medium
2f01124a-87cc-42c0-aff1-ff0045070c4d	\N	\N	eafb37ce-9111-4c51-91b5-dac320a98501	eafb37ce-9111-4c51-91b5-dac320a98501	تهیهٔ گزارش غیبت و تأخیر #100	\N	medium	2026-08-04	69eda6ef-101a-456c-8540-8e92c8484eb5	2026-07-21 18:09:05.468077+00	2026-07-21 18:09:05.468077+00	todo	\N	21	4.80	2026-07-18	medium
2f01124a-87cc-42c0-aff1-ff0045070c4d	\N	\N	fe42788d-ef87-41ef-8255-9e64e697d040	fe42788d-ef87-41ef-8255-9e64e697d040	به‌روزرسانی آیین‌نامهٔ داخلی شرکت #101	\N	low	2026-07-13	cbbf2535-b14c-4cc7-a81b-de2a8b0c11fc	2026-07-21 18:09:05.468077+00	2026-07-21 18:09:05.468077+00	in_progress	\N	64	10.50	2026-07-01	medium
2f01124a-87cc-42c0-aff1-ff0045070c4d	\N	\N	eafb37ce-9111-4c51-91b5-dac320a98501	eafb37ce-9111-4c51-91b5-dac320a98501	برنامه‌ریزی مصاحبهٔ استخدامی #102	\N	medium	2026-07-20	18c88872-c854-4646-a67f-25090f66690c	2026-07-21 18:09:05.468077+00	2026-07-21 18:09:05.468077+00	in_progress	\N	56	32.40	2026-07-11	medium
2f01124a-87cc-42c0-aff1-ff0045070c4d	\N	\N	fe42788d-ef87-41ef-8255-9e64e697d040	fe42788d-ef87-41ef-8255-9e64e697d040	برنامه‌ریزی رویداد تیم‌سازی #103	\N	medium	2026-08-26	926c927b-a5c6-4d0d-9d36-c41d07961292	2026-07-21 18:09:05.468077+00	2026-07-21 18:09:05.468077+00	todo	\N	15	39.30	2026-08-09	medium
2f01124a-87cc-42c0-aff1-ff0045070c4d	\N	\N	eafb37ce-9111-4c51-91b5-dac320a98501	eafb37ce-9111-4c51-91b5-dac320a98501	بررسی رزومه‌های متقاضیان شغلی #104	\N	high	2026-07-26	05024a00-31e5-4882-97a1-af53298ea36f	2026-07-21 18:09:05.468077+00	2026-07-21 18:09:05.468077+00	completed	approved	100	22.90	2026-07-11	medium
2f01124a-87cc-42c0-aff1-ff0045070c4d	\N	\N	47bf13da-40a8-4016-b601-d596b7a29a50	47bf13da-40a8-4016-b601-d596b7a29a50	تدوین برنامهٔ آموزشی سال آینده #105	\N	high	2026-08-26	45a532c3-1f6e-44d3-9ac2-dd58b8c9f36a	2026-07-21 18:09:05.468077+00	2026-07-21 18:09:05.468077+00	todo	\N	38	35.80	2026-08-05	medium
\.


--
-- Data for Name: users; Type: TABLE DATA; Schema: public; Owner: -
--

COPY public.users (organization_id, full_name, role, is_active, id, created_at, updated_at, department_id, account_id) FROM stdin;
2f01124a-87cc-42c0-aff1-ff0045070c4d	مدیر سازمان	org_admin	t	e11e2d19-e7e3-4137-b206-b39a072b4754	2026-07-21 18:09:05.468077+00	2026-07-21 18:09:05.468077+00	1367fc65-98ba-476a-8cdb-8c2bc8411c3b	4bab4df5-ec35-4c17-9618-ea4f752847a7
2f01124a-87cc-42c0-aff1-ff0045070c4d	مدیر پروژه مهندسی و فنی	project_manager	t	10b934e7-80e6-41d0-9140-f56d92d614ae	2026-07-21 18:09:05.468077+00	2026-07-21 18:09:05.468077+00	1367fc65-98ba-476a-8cdb-8c2bc8411c3b	676321b4-002c-469c-8745-ae0d49e8d362
2f01124a-87cc-42c0-aff1-ff0045070c4d	کارمند 1 مهندسی و فنی	employee	t	1c04dd92-4377-490c-934c-38244ec68419	2026-07-21 18:09:05.468077+00	2026-07-21 18:09:05.468077+00	1367fc65-98ba-476a-8cdb-8c2bc8411c3b	6666fb55-09e9-46c5-99cb-24d40a088f01
2f01124a-87cc-42c0-aff1-ff0045070c4d	کارمند 2 مهندسی و فنی	employee	t	4e4c6e76-84d5-464d-957c-75ff3e9a2f8a	2026-07-21 18:09:05.468077+00	2026-07-21 18:09:05.468077+00	1367fc65-98ba-476a-8cdb-8c2bc8411c3b	b0eb763c-1885-47b6-8830-2b395e87024c
2f01124a-87cc-42c0-aff1-ff0045070c4d	کارمند 3 مهندسی و فنی	employee	t	0aa2e3a9-85b6-420a-aeeb-62f6f7061c6c	2026-07-21 18:09:05.468077+00	2026-07-21 18:09:05.468077+00	1367fc65-98ba-476a-8cdb-8c2bc8411c3b	45ec130f-f756-4802-9a44-9acb5af20d25
2f01124a-87cc-42c0-aff1-ff0045070c4d	کارمند 4 مهندسی و فنی	employee	t	de5c1d0c-3ca8-4c75-8525-abcfac9d0651	2026-07-21 18:09:05.468077+00	2026-07-21 18:09:05.468077+00	1367fc65-98ba-476a-8cdb-8c2bc8411c3b	843d0e99-1656-432f-a302-159b197a81b3
2f01124a-87cc-42c0-aff1-ff0045070c4d	کارمند 5 مهندسی و فنی	employee	t	dfe22c83-6863-413d-97b7-1eb9b52dec02	2026-07-21 18:09:05.468077+00	2026-07-21 18:09:05.468077+00	1367fc65-98ba-476a-8cdb-8c2bc8411c3b	58b12847-e009-4552-99d4-ec4cc07b9d4b
2f01124a-87cc-42c0-aff1-ff0045070c4d	کارمند 6 مهندسی و فنی	employee	t	f7d585ca-9137-4691-8979-1d8553a71ed8	2026-07-21 18:09:05.468077+00	2026-07-21 18:09:05.468077+00	1367fc65-98ba-476a-8cdb-8c2bc8411c3b	3e838814-2937-4c43-92f4-5f36d1d859b3
2f01124a-87cc-42c0-aff1-ff0045070c4d	مدیر پروژه حسابداری و مالی	project_manager	t	42df4646-393a-4de3-83d6-df4785b690c6	2026-07-21 18:09:05.468077+00	2026-07-21 18:09:05.468077+00	6b7d47ac-33b3-4bb6-95f6-4e48329d1ce2	2af29398-2df5-4280-838c-769c387ce926
2f01124a-87cc-42c0-aff1-ff0045070c4d	کارمند 1 حسابداری و مالی	employee	t	92a3b31d-254e-440b-8bbe-d18db13d73cd	2026-07-21 18:09:05.468077+00	2026-07-21 18:09:05.468077+00	6b7d47ac-33b3-4bb6-95f6-4e48329d1ce2	cd26d968-a7fb-4d62-b1a5-588e24b3bb5a
2f01124a-87cc-42c0-aff1-ff0045070c4d	کارمند 2 حسابداری و مالی	employee	t	2d6d452d-4915-4793-bf0b-ad7d43798e6f	2026-07-21 18:09:05.468077+00	2026-07-21 18:09:05.468077+00	6b7d47ac-33b3-4bb6-95f6-4e48329d1ce2	03916a9b-f265-486c-83cd-4b080fd6d577
2f01124a-87cc-42c0-aff1-ff0045070c4d	کارمند 3 حسابداری و مالی	employee	t	02b5f471-cd3d-47ff-85ad-d22286b9e4b1	2026-07-21 18:09:05.468077+00	2026-07-21 18:09:05.468077+00	6b7d47ac-33b3-4bb6-95f6-4e48329d1ce2	cbc0b2dd-dd01-4b5d-b3ce-7f83f9241d60
2f01124a-87cc-42c0-aff1-ff0045070c4d	کارمند 4 حسابداری و مالی	employee	t	3683aa32-1561-4f36-90bf-d6402b4a66d8	2026-07-21 18:09:05.468077+00	2026-07-21 18:09:05.468077+00	6b7d47ac-33b3-4bb6-95f6-4e48329d1ce2	82f62316-49a4-4ac4-bb16-6dfcdb7ec62b
2f01124a-87cc-42c0-aff1-ff0045070c4d	کارمند 5 حسابداری و مالی	employee	t	72cdbbe8-b0fe-43f0-ab1a-f11f02a63e1f	2026-07-21 18:09:05.468077+00	2026-07-21 18:09:05.468077+00	6b7d47ac-33b3-4bb6-95f6-4e48329d1ce2	8103cda8-d62d-4031-b4fb-85a00961c87d
2f01124a-87cc-42c0-aff1-ff0045070c4d	کارمند 6 حسابداری و مالی	employee	t	b4d6dda1-b07b-48aa-b440-b2cbfe40ac0f	2026-07-21 18:09:05.468077+00	2026-07-21 18:09:05.468077+00	6b7d47ac-33b3-4bb6-95f6-4e48329d1ce2	abfb435b-ffc6-415b-8a9e-cd4d18615174
2f01124a-87cc-42c0-aff1-ff0045070c4d	مدیر پروژه منابع انسانی	project_manager	t	c873d894-cb10-4d12-a1dd-f989a1851641	2026-07-21 18:09:05.468077+00	2026-07-21 18:09:05.468077+00	f3a99830-2232-4cb4-9b54-f0b9f85d54b1	c1b7bc1c-08b7-4bc0-a066-025328ce69ca
2f01124a-87cc-42c0-aff1-ff0045070c4d	کارمند 1 منابع انسانی	employee	t	00a2a3bf-94c3-4ef6-a94b-bfb72866c1cd	2026-07-21 18:09:05.468077+00	2026-07-21 18:09:05.468077+00	f3a99830-2232-4cb4-9b54-f0b9f85d54b1	f1ec4959-c927-4f70-a387-43fc1dba386d
2f01124a-87cc-42c0-aff1-ff0045070c4d	کارمند 2 منابع انسانی	employee	t	9d19d89f-4c3d-4d3d-baf1-a4e8898f6a75	2026-07-21 18:09:05.468077+00	2026-07-21 18:09:05.468077+00	f3a99830-2232-4cb4-9b54-f0b9f85d54b1	2a3180b2-c971-4536-b009-28594105288e
2f01124a-87cc-42c0-aff1-ff0045070c4d	کارمند 3 منابع انسانی	employee	t	fe42788d-ef87-41ef-8255-9e64e697d040	2026-07-21 18:09:05.468077+00	2026-07-21 18:09:05.468077+00	f3a99830-2232-4cb4-9b54-f0b9f85d54b1	c1b228ad-8ad7-4400-8fe2-050098d53255
2f01124a-87cc-42c0-aff1-ff0045070c4d	کارمند 4 منابع انسانی	employee	t	ae9392d2-7669-44be-a429-889e449b3eb1	2026-07-21 18:09:05.468077+00	2026-07-21 18:09:05.468077+00	f3a99830-2232-4cb4-9b54-f0b9f85d54b1	d3efba31-2c55-4c00-bb44-d33e7d9a4a4e
2f01124a-87cc-42c0-aff1-ff0045070c4d	کارمند 5 منابع انسانی	employee	t	eafb37ce-9111-4c51-91b5-dac320a98501	2026-07-21 18:09:05.468077+00	2026-07-21 18:09:05.468077+00	f3a99830-2232-4cb4-9b54-f0b9f85d54b1	956634d4-53ce-4fc2-9a50-45fcc44f53bc
2f01124a-87cc-42c0-aff1-ff0045070c4d	کارمند 6 منابع انسانی	employee	t	47bf13da-40a8-4016-b601-d596b7a29a50	2026-07-21 18:09:05.468077+00	2026-07-21 18:09:05.468077+00	f3a99830-2232-4cb4-9b54-f0b9f85d54b1	190af3ee-3f6a-4418-8ce1-aec073075bc9
\.


--
-- Data for Name: worklogs; Type: TABLE DATA; Schema: public; Owner: -
--

COPY public.worklogs (organization_id, task_id, user_id, activity_description, time_spent_minutes, progress_percent, log_date, status, reviewed_by_id, review_comment, id, created_at, updated_at) FROM stdin;
2f01124a-87cc-42c0-aff1-ff0045070c4d	d1b1ebba-cfa9-4b3c-ae5c-bf43282aaedc	de5c1d0c-3ca8-4c75-8525-abcfac9d0651	مستندسازی و نهایی‌سازی	118	33	2026-07-16	approved	10b934e7-80e6-41d0-9140-f56d92d614ae	\N	00793acb-deb0-40fb-a9db-b909ec1feec5	2026-07-21 18:09:05.468077+00	2026-07-21 18:09:05.468077+00
2f01124a-87cc-42c0-aff1-ff0045070c4d	d1b1ebba-cfa9-4b3c-ae5c-bf43282aaedc	de5c1d0c-3ca8-4c75-8525-abcfac9d0651	تست و اطمینان از عملکرد صحیح	99	58	2026-07-16	approved	10b934e7-80e6-41d0-9140-f56d92d614ae	\N	63bea14c-120a-4cb3-9daa-654c9ca8ee4d	2026-07-21 18:09:05.468077+00	2026-07-21 18:09:05.468077+00
2f01124a-87cc-42c0-aff1-ff0045070c4d	d1b1ebba-cfa9-4b3c-ae5c-bf43282aaedc	de5c1d0c-3ca8-4c75-8525-abcfac9d0651	پیاده‌سازی بخش اصلی	110	69	2026-07-16	approved	10b934e7-80e6-41d0-9140-f56d92d614ae	\N	78a84cfc-b99d-4621-af9d-2eed39550598	2026-07-21 18:09:05.468077+00	2026-07-21 18:09:05.468077+00
2f01124a-87cc-42c0-aff1-ff0045070c4d	e2bcaf1f-b740-43bd-9419-dcbb02e084b9	1c04dd92-4377-490c-934c-38244ec68419	تست و اطمینان از عملکرد صحیح	100	38	2026-07-16	approved	10b934e7-80e6-41d0-9140-f56d92d614ae	\N	738cef24-8399-4621-bcae-a5e0990c6f27	2026-07-21 18:09:05.468077+00	2026-07-21 18:09:05.468077+00
2f01124a-87cc-42c0-aff1-ff0045070c4d	e2bcaf1f-b740-43bd-9419-dcbb02e084b9	1c04dd92-4377-490c-934c-38244ec68419	پیاده‌سازی بخش اصلی	105	54	2026-07-16	submitted	\N	\N	f87a7017-7b7c-4934-a7a7-9394f1356e37	2026-07-21 18:09:05.468077+00	2026-07-21 18:09:05.468077+00
2f01124a-87cc-42c0-aff1-ff0045070c4d	2a24cbb5-3133-485b-be41-4a98899232bd	f7d585ca-9137-4691-8979-1d8553a71ed8	مستندسازی و نهایی‌سازی	62	28	2026-07-16	approved	10b934e7-80e6-41d0-9140-f56d92d614ae	\N	144a8699-45a5-4d4d-b420-5f829875faa0	2026-07-21 18:09:05.468077+00	2026-07-21 18:09:05.468077+00
2f01124a-87cc-42c0-aff1-ff0045070c4d	2a24cbb5-3133-485b-be41-4a98899232bd	f7d585ca-9137-4691-8979-1d8553a71ed8	مستندسازی و نهایی‌سازی	104	48	2026-07-16	submitted	\N	\N	d01bdcde-ac45-4b97-81a1-2b04be2fca48	2026-07-21 18:09:05.468077+00	2026-07-21 18:09:05.468077+00
2f01124a-87cc-42c0-aff1-ff0045070c4d	2a24cbb5-3133-485b-be41-4a98899232bd	f7d585ca-9137-4691-8979-1d8553a71ed8	پیشرفت اولیه و بررسی نیازمندی‌ها	176	87	2026-07-16	approved	10b934e7-80e6-41d0-9140-f56d92d614ae	\N	226db4d5-f7b6-44cb-84c3-eee361c3d9bb	2026-07-21 18:09:05.468077+00	2026-07-21 18:09:05.468077+00
2f01124a-87cc-42c0-aff1-ff0045070c4d	98717e46-4139-4b31-933d-cafc2c1aafbe	4e4c6e76-84d5-464d-957c-75ff3e9a2f8a	تست و اطمینان از عملکرد صحیح	117	25	2026-06-20	approved	10b934e7-80e6-41d0-9140-f56d92d614ae	\N	5bbb1c76-f614-4445-a272-cd4fd5f095d2	2026-07-21 18:09:05.468077+00	2026-07-21 18:09:05.468077+00
2f01124a-87cc-42c0-aff1-ff0045070c4d	98717e46-4139-4b31-933d-cafc2c1aafbe	4e4c6e76-84d5-464d-957c-75ff3e9a2f8a	رفع اشکالات و بازبینی	152	46	2026-06-21	approved	10b934e7-80e6-41d0-9140-f56d92d614ae	\N	449a90e5-4c76-4c95-839c-f4bb5cdca0ff	2026-07-21 18:09:05.468077+00	2026-07-21 18:09:05.468077+00
2f01124a-87cc-42c0-aff1-ff0045070c4d	98717e46-4139-4b31-933d-cafc2c1aafbe	4e4c6e76-84d5-464d-957c-75ff3e9a2f8a	تست و اطمینان از عملکرد صحیح	155	66	2026-06-22	approved	10b934e7-80e6-41d0-9140-f56d92d614ae	\N	7f9699a4-6dbb-46b8-96ed-2a48935870b5	2026-07-21 18:09:05.468077+00	2026-07-21 18:09:05.468077+00
2f01124a-87cc-42c0-aff1-ff0045070c4d	98717e46-4139-4b31-933d-cafc2c1aafbe	4e4c6e76-84d5-464d-957c-75ff3e9a2f8a	پیاده‌سازی بخش اصلی	68	100	2026-06-23	approved	10b934e7-80e6-41d0-9140-f56d92d614ae	\N	078676f3-ebf4-4c8c-9dea-8feccaca2031	2026-07-21 18:09:05.468077+00	2026-07-21 18:09:05.468077+00
2f01124a-87cc-42c0-aff1-ff0045070c4d	1c14d9da-8383-4040-bca3-a1f44c88fa6c	10b934e7-80e6-41d0-9140-f56d92d614ae	پیشرفت اولیه و بررسی نیازمندی‌ها	172	33	2026-07-16	submitted	\N	\N	1a6c154e-532e-4ead-8667-3488251f665f	2026-07-21 18:09:05.468077+00	2026-07-21 18:09:05.468077+00
2f01124a-87cc-42c0-aff1-ff0045070c4d	1c14d9da-8383-4040-bca3-a1f44c88fa6c	10b934e7-80e6-41d0-9140-f56d92d614ae	تست و اطمینان از عملکرد صحیح	145	68	2026-07-16	submitted	\N	\N	0f3d5f02-48ad-428f-bd92-63831f3cf982	2026-07-21 18:09:05.468077+00	2026-07-21 18:09:05.468077+00
2f01124a-87cc-42c0-aff1-ff0045070c4d	1c14d9da-8383-4040-bca3-a1f44c88fa6c	10b934e7-80e6-41d0-9140-f56d92d614ae	تست و اطمینان از عملکرد صحیح	108	100	2026-07-16	submitted	\N	\N	9290fc2b-86c4-46ab-877b-6cb23d20f4bf	2026-07-21 18:09:05.468077+00	2026-07-21 18:09:05.468077+00
2f01124a-87cc-42c0-aff1-ff0045070c4d	27a443ff-7664-4e4c-8940-a091314af277	dfe22c83-6863-413d-97b7-1eb9b52dec02	پیاده‌سازی بخش اصلی	190	26	2026-07-16	approved	10b934e7-80e6-41d0-9140-f56d92d614ae	\N	cdb454df-0284-4921-94e7-92a0f8b9ef22	2026-07-21 18:09:05.468077+00	2026-07-21 18:09:05.468077+00
2f01124a-87cc-42c0-aff1-ff0045070c4d	ba701b08-bb12-4c36-a0bf-5edbfe3eaa00	0aa2e3a9-85b6-420a-aeeb-62f6f7061c6c	پیاده‌سازی بخش اصلی	171	22	2026-07-03	approved	10b934e7-80e6-41d0-9140-f56d92d614ae	\N	957ae392-7c67-4756-933f-31ffd768820b	2026-07-21 18:09:05.468077+00	2026-07-21 18:09:05.468077+00
2f01124a-87cc-42c0-aff1-ff0045070c4d	ba701b08-bb12-4c36-a0bf-5edbfe3eaa00	0aa2e3a9-85b6-420a-aeeb-62f6f7061c6c	تست و اطمینان از عملکرد صحیح	206	78	2026-07-05	approved	10b934e7-80e6-41d0-9140-f56d92d614ae	\N	7d637a42-07ac-4665-9352-6261f7aec7de	2026-07-21 18:09:05.468077+00	2026-07-21 18:09:05.468077+00
2f01124a-87cc-42c0-aff1-ff0045070c4d	ba701b08-bb12-4c36-a0bf-5edbfe3eaa00	0aa2e3a9-85b6-420a-aeeb-62f6f7061c6c	پیاده‌سازی بخش اصلی	103	87	2026-07-11	approved	10b934e7-80e6-41d0-9140-f56d92d614ae	\N	4fb45cad-b20b-4d21-8d64-c826e27be1a3	2026-07-21 18:09:05.468077+00	2026-07-21 18:09:05.468077+00
2f01124a-87cc-42c0-aff1-ff0045070c4d	d523f5bd-9554-49ed-a39e-f40f4055e9f8	1c04dd92-4377-490c-934c-38244ec68419	پیاده‌سازی بخش اصلی	97	40	2026-07-06	approved	10b934e7-80e6-41d0-9140-f56d92d614ae	\N	22b99053-cad5-4de4-9734-e2234643bdf3	2026-07-21 18:09:05.468077+00	2026-07-21 18:09:05.468077+00
2f01124a-87cc-42c0-aff1-ff0045070c4d	d523f5bd-9554-49ed-a39e-f40f4055e9f8	1c04dd92-4377-490c-934c-38244ec68419	تست و اطمینان از عملکرد صحیح	59	74	2026-07-08	approved	10b934e7-80e6-41d0-9140-f56d92d614ae	\N	041ca25b-1a83-4fd9-9a1f-9943a3783313	2026-07-21 18:09:05.468077+00	2026-07-21 18:09:05.468077+00
2f01124a-87cc-42c0-aff1-ff0045070c4d	d523f5bd-9554-49ed-a39e-f40f4055e9f8	1c04dd92-4377-490c-934c-38244ec68419	پیاده‌سازی بخش اصلی	98	72	2026-07-10	approved	10b934e7-80e6-41d0-9140-f56d92d614ae	\N	be31ea6a-0a4b-429c-bba0-dd3eee20aa35	2026-07-21 18:09:05.468077+00	2026-07-21 18:09:05.468077+00
2f01124a-87cc-42c0-aff1-ff0045070c4d	d523f5bd-9554-49ed-a39e-f40f4055e9f8	1c04dd92-4377-490c-934c-38244ec68419	پیشرفت اولیه و بررسی نیازمندی‌ها	72	100	2026-07-09	approved	10b934e7-80e6-41d0-9140-f56d92d614ae	\N	6640eaa5-a25f-4146-9196-0e948486fba6	2026-07-21 18:09:05.468077+00	2026-07-21 18:09:05.468077+00
2f01124a-87cc-42c0-aff1-ff0045070c4d	f7835816-383f-4d5b-bd80-a64954fef7f6	dfe22c83-6863-413d-97b7-1eb9b52dec02	پیشرفت اولیه و بررسی نیازمندی‌ها	149	29	2026-06-24	approved	10b934e7-80e6-41d0-9140-f56d92d614ae	\N	37a34a23-e4b4-481a-a27b-dcbc9ec59cc7	2026-07-21 18:09:05.468077+00	2026-07-21 18:09:05.468077+00
2f01124a-87cc-42c0-aff1-ff0045070c4d	f7835816-383f-4d5b-bd80-a64954fef7f6	dfe22c83-6863-413d-97b7-1eb9b52dec02	رفع اشکالات و بازبینی	158	74	2026-06-28	approved	10b934e7-80e6-41d0-9140-f56d92d614ae	\N	c2683895-4672-42d7-87a1-b27ec95eec65	2026-07-21 18:09:05.468077+00	2026-07-21 18:09:05.468077+00
2f01124a-87cc-42c0-aff1-ff0045070c4d	f7835816-383f-4d5b-bd80-a64954fef7f6	dfe22c83-6863-413d-97b7-1eb9b52dec02	تست و اطمینان از عملکرد صحیح	50	100	2026-07-02	approved	10b934e7-80e6-41d0-9140-f56d92d614ae	\N	ea810cba-9d0a-403a-8d11-107ba527d79c	2026-07-21 18:09:05.468077+00	2026-07-21 18:09:05.468077+00
2f01124a-87cc-42c0-aff1-ff0045070c4d	a1029593-638b-45fe-b60d-65aba9477bea	dfe22c83-6863-413d-97b7-1eb9b52dec02	رفع اشکالات و بازبینی	184	28	2026-07-16	approved	10b934e7-80e6-41d0-9140-f56d92d614ae	\N	7b4e4c8a-8819-4cac-b5e5-a29e68b56bfd	2026-07-21 18:09:05.468077+00	2026-07-21 18:09:05.468077+00
2f01124a-87cc-42c0-aff1-ff0045070c4d	a40a55a6-8890-42ba-b09b-5982044bca6f	1c04dd92-4377-490c-934c-38244ec68419	پیاده‌سازی بخش اصلی	202	38	2026-07-16	approved	10b934e7-80e6-41d0-9140-f56d92d614ae	\N	8f576c5f-cdc1-4c02-9f3c-d6216cc97d04	2026-07-21 18:09:05.468077+00	2026-07-21 18:09:05.468077+00
2f01124a-87cc-42c0-aff1-ff0045070c4d	a5e4a2ee-f5ea-4d32-817b-0d43a9ab79e5	1c04dd92-4377-490c-934c-38244ec68419	مستندسازی و نهایی‌سازی	40	25	2026-06-20	approved	10b934e7-80e6-41d0-9140-f56d92d614ae	\N	9420e891-246d-4f0d-ae9a-bc6ce7304b73	2026-07-21 18:09:05.468077+00	2026-07-21 18:09:05.468077+00
2f01124a-87cc-42c0-aff1-ff0045070c4d	193beec1-e45a-4908-9524-f6693a4453ef	de5c1d0c-3ca8-4c75-8525-abcfac9d0651	پیاده‌سازی بخش اصلی	179	33	2026-07-16	submitted	\N	\N	92cdf11e-782d-40ea-8f0b-0523c933f027	2026-07-21 18:09:05.468077+00	2026-07-21 18:09:05.468077+00
2f01124a-87cc-42c0-aff1-ff0045070c4d	193beec1-e45a-4908-9524-f6693a4453ef	de5c1d0c-3ca8-4c75-8525-abcfac9d0651	تست و اطمینان از عملکرد صحیح	119	66	2026-07-16	submitted	\N	\N	8e38a1bb-b687-4039-b315-02a764b18ed4	2026-07-21 18:09:05.468077+00	2026-07-21 18:09:05.468077+00
2f01124a-87cc-42c0-aff1-ff0045070c4d	193beec1-e45a-4908-9524-f6693a4453ef	de5c1d0c-3ca8-4c75-8525-abcfac9d0651	پیشرفت اولیه و بررسی نیازمندی‌ها	71	90	2026-07-16	approved	10b934e7-80e6-41d0-9140-f56d92d614ae	\N	c100edeb-14ca-42eb-8563-04ef783743d5	2026-07-21 18:09:05.468077+00	2026-07-21 18:09:05.468077+00
2f01124a-87cc-42c0-aff1-ff0045070c4d	193beec1-e45a-4908-9524-f6693a4453ef	de5c1d0c-3ca8-4c75-8525-abcfac9d0651	رفع اشکالات و بازبینی	199	100	2026-07-16	approved	10b934e7-80e6-41d0-9140-f56d92d614ae	\N	e54fadc6-1a62-46f8-bf0b-eb5f720c5530	2026-07-21 18:09:05.468077+00	2026-07-21 18:09:05.468077+00
2f01124a-87cc-42c0-aff1-ff0045070c4d	376f9ed3-827e-45ed-a5ad-d0f1914e1d00	de5c1d0c-3ca8-4c75-8525-abcfac9d0651	پیشرفت اولیه و بررسی نیازمندی‌ها	110	28	2026-07-03	approved	10b934e7-80e6-41d0-9140-f56d92d614ae	\N	907c393f-4e06-4ae3-a006-0c1769b4f322	2026-07-21 18:09:05.468077+00	2026-07-21 18:09:05.468077+00
2f01124a-87cc-42c0-aff1-ff0045070c4d	9634bc54-80f3-48fa-a08d-f01b776c6bc0	10b934e7-80e6-41d0-9140-f56d92d614ae	تست و اطمینان از عملکرد صحیح	161	20	2026-07-16	approved	10b934e7-80e6-41d0-9140-f56d92d614ae	\N	ff4a23f5-c903-4c4e-b864-cba5fd3ad3e9	2026-07-21 18:09:05.468077+00	2026-07-21 18:09:05.468077+00
2f01124a-87cc-42c0-aff1-ff0045070c4d	9634bc54-80f3-48fa-a08d-f01b776c6bc0	10b934e7-80e6-41d0-9140-f56d92d614ae	تست و اطمینان از عملکرد صحیح	43	52	2026-07-16	approved	10b934e7-80e6-41d0-9140-f56d92d614ae	\N	8bdff3ee-7af7-40a6-b02a-018f421a0df4	2026-07-21 18:09:05.468077+00	2026-07-21 18:09:05.468077+00
2f01124a-87cc-42c0-aff1-ff0045070c4d	9634bc54-80f3-48fa-a08d-f01b776c6bc0	10b934e7-80e6-41d0-9140-f56d92d614ae	مستندسازی و نهایی‌سازی	223	100	2026-07-16	approved	10b934e7-80e6-41d0-9140-f56d92d614ae	\N	2f25729b-6f03-4bce-a6b3-417cf9e9bcad	2026-07-21 18:09:05.468077+00	2026-07-21 18:09:05.468077+00
2f01124a-87cc-42c0-aff1-ff0045070c4d	bf9a4fe9-52cc-43eb-83b3-cbba6dcef891	f7d585ca-9137-4691-8979-1d8553a71ed8	پیاده‌سازی بخش اصلی	98	37	2026-07-16	approved	10b934e7-80e6-41d0-9140-f56d92d614ae	\N	c39b4ac8-8175-4b9f-94fd-a734bc89ebb4	2026-07-21 18:09:05.468077+00	2026-07-21 18:09:05.468077+00
2f01124a-87cc-42c0-aff1-ff0045070c4d	bf9a4fe9-52cc-43eb-83b3-cbba6dcef891	f7d585ca-9137-4691-8979-1d8553a71ed8	رفع اشکالات و بازبینی	142	70	2026-07-16	approved	10b934e7-80e6-41d0-9140-f56d92d614ae	\N	24080c11-a325-437b-951b-c0d2eba0b3a2	2026-07-21 18:09:05.468077+00	2026-07-21 18:09:05.468077+00
2f01124a-87cc-42c0-aff1-ff0045070c4d	bf9a4fe9-52cc-43eb-83b3-cbba6dcef891	f7d585ca-9137-4691-8979-1d8553a71ed8	پیشرفت اولیه و بررسی نیازمندی‌ها	191	100	2026-07-16	approved	10b934e7-80e6-41d0-9140-f56d92d614ae	\N	0f3b106a-186b-493a-b1a9-f979fc243036	2026-07-21 18:09:05.468077+00	2026-07-21 18:09:05.468077+00
2f01124a-87cc-42c0-aff1-ff0045070c4d	bf9a4fe9-52cc-43eb-83b3-cbba6dcef891	f7d585ca-9137-4691-8979-1d8553a71ed8	پیاده‌سازی بخش اصلی	109	100	2026-07-16	approved	10b934e7-80e6-41d0-9140-f56d92d614ae	\N	9b0e4bcf-5e30-45df-b6a4-3909824183d9	2026-07-21 18:09:05.468077+00	2026-07-21 18:09:05.468077+00
2f01124a-87cc-42c0-aff1-ff0045070c4d	299066b5-19d2-4965-b65e-39e74174a939	1c04dd92-4377-490c-934c-38244ec68419	پیشرفت اولیه و بررسی نیازمندی‌ها	87	23	2026-07-16	approved	10b934e7-80e6-41d0-9140-f56d92d614ae	\N	f0d60e27-a81d-407f-afd3-1cd8f5f57349	2026-07-21 18:09:05.468077+00	2026-07-21 18:09:05.468077+00
2f01124a-87cc-42c0-aff1-ff0045070c4d	e613c28f-b932-44d5-b5ad-938e77d55bfc	0aa2e3a9-85b6-420a-aeeb-62f6f7061c6c	پیاده‌سازی بخش اصلی	157	29	2026-07-16	approved	10b934e7-80e6-41d0-9140-f56d92d614ae	\N	3c506c01-62e4-4b4b-9ab3-04bdb35da634	2026-07-21 18:09:05.468077+00	2026-07-21 18:09:05.468077+00
2f01124a-87cc-42c0-aff1-ff0045070c4d	e613c28f-b932-44d5-b5ad-938e77d55bfc	0aa2e3a9-85b6-420a-aeeb-62f6f7061c6c	تست و اطمینان از عملکرد صحیح	150	54	2026-07-16	approved	10b934e7-80e6-41d0-9140-f56d92d614ae	\N	e04971a3-bbd3-4e74-9aff-e958534ef22d	2026-07-21 18:09:05.468077+00	2026-07-21 18:09:05.468077+00
2f01124a-87cc-42c0-aff1-ff0045070c4d	e613c28f-b932-44d5-b5ad-938e77d55bfc	0aa2e3a9-85b6-420a-aeeb-62f6f7061c6c	تست و اطمینان از عملکرد صحیح	78	100	2026-07-16	approved	10b934e7-80e6-41d0-9140-f56d92d614ae	\N	effd5186-dea0-4f6d-afc9-7d35eda1ce68	2026-07-21 18:09:05.468077+00	2026-07-21 18:09:05.468077+00
2f01124a-87cc-42c0-aff1-ff0045070c4d	e613c28f-b932-44d5-b5ad-938e77d55bfc	0aa2e3a9-85b6-420a-aeeb-62f6f7061c6c	رفع اشکالات و بازبینی	227	100	2026-07-16	submitted	\N	\N	9d02c4b5-f1fd-4000-82e9-dc38a3bdbfcc	2026-07-21 18:09:05.468077+00	2026-07-21 18:09:05.468077+00
2f01124a-87cc-42c0-aff1-ff0045070c4d	9f6a2f55-6c3b-4a86-ada0-aa8950d23fd6	0aa2e3a9-85b6-420a-aeeb-62f6f7061c6c	پیشرفت اولیه و بررسی نیازمندی‌ها	102	29	2026-07-14	approved	10b934e7-80e6-41d0-9140-f56d92d614ae	\N	a9d7272e-fe2f-47e3-9647-e28a7b6d2a8e	2026-07-21 18:09:05.468077+00	2026-07-21 18:09:05.468077+00
2f01124a-87cc-42c0-aff1-ff0045070c4d	9f6a2f55-6c3b-4a86-ada0-aa8950d23fd6	0aa2e3a9-85b6-420a-aeeb-62f6f7061c6c	پیاده‌سازی بخش اصلی	144	74	2026-07-16	approved	10b934e7-80e6-41d0-9140-f56d92d614ae	\N	5f01c079-ee90-499f-8740-288c992e8256	2026-07-21 18:09:05.468077+00	2026-07-21 18:09:05.468077+00
2f01124a-87cc-42c0-aff1-ff0045070c4d	9f6a2f55-6c3b-4a86-ada0-aa8950d23fd6	0aa2e3a9-85b6-420a-aeeb-62f6f7061c6c	رفع اشکالات و بازبینی	115	100	2026-07-16	approved	10b934e7-80e6-41d0-9140-f56d92d614ae	\N	1abf03d1-e9a7-4277-b8e8-abe12353f825	2026-07-21 18:09:05.468077+00	2026-07-21 18:09:05.468077+00
2f01124a-87cc-42c0-aff1-ff0045070c4d	95f905ef-a29f-4038-9ff4-35148aa51a9b	10b934e7-80e6-41d0-9140-f56d92d614ae	پیاده‌سازی بخش اصلی	208	27	2026-06-17	submitted	\N	\N	8bc7ac86-bbb1-4477-b187-a44ea38991be	2026-07-21 18:09:05.468077+00	2026-07-21 18:09:05.468077+00
2f01124a-87cc-42c0-aff1-ff0045070c4d	95f905ef-a29f-4038-9ff4-35148aa51a9b	10b934e7-80e6-41d0-9140-f56d92d614ae	تست و اطمینان از عملکرد صحیح	41	60	2026-06-21	approved	10b934e7-80e6-41d0-9140-f56d92d614ae	\N	e617762d-33bf-44c4-bfd4-4cff8d98a5f3	2026-07-21 18:09:05.468077+00	2026-07-21 18:09:05.468077+00
2f01124a-87cc-42c0-aff1-ff0045070c4d	95f905ef-a29f-4038-9ff4-35148aa51a9b	10b934e7-80e6-41d0-9140-f56d92d614ae	تست و اطمینان از عملکرد صحیح	128	100	2026-06-25	submitted	\N	\N	9d0529f8-dbee-45bf-8f39-5b4e6245b504	2026-07-21 18:09:05.468077+00	2026-07-21 18:09:05.468077+00
2f01124a-87cc-42c0-aff1-ff0045070c4d	95f905ef-a29f-4038-9ff4-35148aa51a9b	10b934e7-80e6-41d0-9140-f56d92d614ae	پیشرفت اولیه و بررسی نیازمندی‌ها	62	100	2026-06-23	approved	10b934e7-80e6-41d0-9140-f56d92d614ae	\N	9524fe13-7d8b-49f3-9726-f08f637085ae	2026-07-21 18:09:05.468077+00	2026-07-21 18:09:05.468077+00
2f01124a-87cc-42c0-aff1-ff0045070c4d	ef2eb54b-439d-4b3a-87ef-775fca206242	10b934e7-80e6-41d0-9140-f56d92d614ae	تست و اطمینان از عملکرد صحیح	55	36	2026-07-16	approved	10b934e7-80e6-41d0-9140-f56d92d614ae	\N	4e991d5f-51df-448d-954d-22565e79d0da	2026-07-21 18:09:05.468077+00	2026-07-21 18:09:05.468077+00
2f01124a-87cc-42c0-aff1-ff0045070c4d	ef2eb54b-439d-4b3a-87ef-775fca206242	10b934e7-80e6-41d0-9140-f56d92d614ae	پیشرفت اولیه و بررسی نیازمندی‌ها	214	48	2026-07-16	approved	10b934e7-80e6-41d0-9140-f56d92d614ae	\N	37605384-05f5-461c-80f9-34543a808302	2026-07-21 18:09:05.468077+00	2026-07-21 18:09:05.468077+00
2f01124a-87cc-42c0-aff1-ff0045070c4d	ef2eb54b-439d-4b3a-87ef-775fca206242	10b934e7-80e6-41d0-9140-f56d92d614ae	پیاده‌سازی بخش اصلی	49	100	2026-07-16	approved	10b934e7-80e6-41d0-9140-f56d92d614ae	\N	32f66448-3c10-4b1f-9abc-98c492fd16ce	2026-07-21 18:09:05.468077+00	2026-07-21 18:09:05.468077+00
2f01124a-87cc-42c0-aff1-ff0045070c4d	363ab848-bd12-4ddb-8a40-993a72b21f80	10b934e7-80e6-41d0-9140-f56d92d614ae	مستندسازی و نهایی‌سازی	207	32	2026-07-16	approved	10b934e7-80e6-41d0-9140-f56d92d614ae	\N	6e696a9e-7e94-4f07-aade-7ab6647a794e	2026-07-21 18:09:05.468077+00	2026-07-21 18:09:05.468077+00
2f01124a-87cc-42c0-aff1-ff0045070c4d	363ab848-bd12-4ddb-8a40-993a72b21f80	10b934e7-80e6-41d0-9140-f56d92d614ae	رفع اشکالات و بازبینی	202	74	2026-07-16	approved	10b934e7-80e6-41d0-9140-f56d92d614ae	\N	6ecf16a3-7d0b-4d9f-b204-03aa5fb838f8	2026-07-21 18:09:05.468077+00	2026-07-21 18:09:05.468077+00
2f01124a-87cc-42c0-aff1-ff0045070c4d	363ab848-bd12-4ddb-8a40-993a72b21f80	10b934e7-80e6-41d0-9140-f56d92d614ae	رفع اشکالات و بازبینی	190	100	2026-07-16	approved	10b934e7-80e6-41d0-9140-f56d92d614ae	\N	2ab39a50-e9cc-42f2-9bcd-b5e1ac77eb60	2026-07-21 18:09:05.468077+00	2026-07-21 18:09:05.468077+00
2f01124a-87cc-42c0-aff1-ff0045070c4d	80f4279c-4962-4a24-b033-bb806f298fdd	de5c1d0c-3ca8-4c75-8525-abcfac9d0651	پیاده‌سازی بخش اصلی	191	29	2026-07-16	approved	10b934e7-80e6-41d0-9140-f56d92d614ae	\N	10f3e6fd-44c7-4927-9ddf-671b925ec722	2026-07-21 18:09:05.468077+00	2026-07-21 18:09:05.468077+00
2f01124a-87cc-42c0-aff1-ff0045070c4d	cb566c53-c7e0-40b7-ad35-79a17d76d3a3	10b934e7-80e6-41d0-9140-f56d92d614ae	تست و اطمینان از عملکرد صحیح	55	40	2026-07-13	approved	10b934e7-80e6-41d0-9140-f56d92d614ae	\N	382847dc-adb9-49a6-935c-f402fc4a33dd	2026-07-21 18:09:05.468077+00	2026-07-21 18:09:05.468077+00
2f01124a-87cc-42c0-aff1-ff0045070c4d	cb566c53-c7e0-40b7-ad35-79a17d76d3a3	10b934e7-80e6-41d0-9140-f56d92d614ae	تست و اطمینان از عملکرد صحیح	72	58	2026-07-14	approved	10b934e7-80e6-41d0-9140-f56d92d614ae	\N	4ccab1c1-2d0e-468f-b17f-72b716597df4	2026-07-21 18:09:05.468077+00	2026-07-21 18:09:05.468077+00
2f01124a-87cc-42c0-aff1-ff0045070c4d	159b99bf-9b12-4eab-9f60-212fb5cb1b17	dfe22c83-6863-413d-97b7-1eb9b52dec02	رفع اشکالات و بازبینی	233	21	2026-07-11	approved	10b934e7-80e6-41d0-9140-f56d92d614ae	\N	501d0a1a-065d-448c-b82b-0a401aac8499	2026-07-21 18:09:05.468077+00	2026-07-21 18:09:05.468077+00
2f01124a-87cc-42c0-aff1-ff0045070c4d	a4c56237-4928-4229-b39f-e66e22a0948c	1c04dd92-4377-490c-934c-38244ec68419	رفع اشکالات و بازبینی	140	24	2026-07-13	approved	10b934e7-80e6-41d0-9140-f56d92d614ae	\N	52ae0ee7-88e4-4bfb-86ff-70b611e9ca1c	2026-07-21 18:09:05.468077+00	2026-07-21 18:09:05.468077+00
2f01124a-87cc-42c0-aff1-ff0045070c4d	a4c56237-4928-4229-b39f-e66e22a0948c	1c04dd92-4377-490c-934c-38244ec68419	مستندسازی و نهایی‌سازی	135	76	2026-07-15	approved	10b934e7-80e6-41d0-9140-f56d92d614ae	\N	c7495306-42df-42f4-83c3-b1bdf30a7344	2026-07-21 18:09:05.468077+00	2026-07-21 18:09:05.468077+00
2f01124a-87cc-42c0-aff1-ff0045070c4d	a4c56237-4928-4229-b39f-e66e22a0948c	1c04dd92-4377-490c-934c-38244ec68419	پیاده‌سازی بخش اصلی	74	66	2026-07-16	approved	10b934e7-80e6-41d0-9140-f56d92d614ae	\N	f1af1b3c-2632-4fb6-829d-bea51db5b18e	2026-07-21 18:09:05.468077+00	2026-07-21 18:09:05.468077+00
2f01124a-87cc-42c0-aff1-ff0045070c4d	d0eaf4fe-63c9-4db7-9008-ea111da82324	10b934e7-80e6-41d0-9140-f56d92d614ae	تست و اطمینان از عملکرد صحیح	179	24	2026-07-16	approved	10b934e7-80e6-41d0-9140-f56d92d614ae	\N	cc0424bd-79a5-4890-b6b0-d1dc3012452f	2026-07-21 18:09:05.468077+00	2026-07-21 18:09:05.468077+00
2f01124a-87cc-42c0-aff1-ff0045070c4d	d0eaf4fe-63c9-4db7-9008-ea111da82324	10b934e7-80e6-41d0-9140-f56d92d614ae	تست و اطمینان از عملکرد صحیح	193	56	2026-07-16	approved	10b934e7-80e6-41d0-9140-f56d92d614ae	\N	26d9d054-108c-4d1d-aa4d-fab51fd1d33e	2026-07-21 18:09:05.468077+00	2026-07-21 18:09:05.468077+00
2f01124a-87cc-42c0-aff1-ff0045070c4d	d0eaf4fe-63c9-4db7-9008-ea111da82324	10b934e7-80e6-41d0-9140-f56d92d614ae	رفع اشکالات و بازبینی	200	60	2026-07-16	approved	10b934e7-80e6-41d0-9140-f56d92d614ae	\N	bc785d65-744f-41a9-a7c8-0e6b1887a1b4	2026-07-21 18:09:05.468077+00	2026-07-21 18:09:05.468077+00
2f01124a-87cc-42c0-aff1-ff0045070c4d	d0eaf4fe-63c9-4db7-9008-ea111da82324	10b934e7-80e6-41d0-9140-f56d92d614ae	رفع اشکالات و بازبینی	203	100	2026-07-16	approved	10b934e7-80e6-41d0-9140-f56d92d614ae	\N	15e86a45-5d92-45a8-88ae-cd0f544b9b57	2026-07-21 18:09:05.468077+00	2026-07-21 18:09:05.468077+00
2f01124a-87cc-42c0-aff1-ff0045070c4d	1fb55dc6-b67c-46e0-b25e-818a9b2b4cdf	f7d585ca-9137-4691-8979-1d8553a71ed8	رفع اشکالات و بازبینی	180	29	2026-07-16	approved	10b934e7-80e6-41d0-9140-f56d92d614ae	\N	728e9575-e267-46cc-b52e-3426ee56a94d	2026-07-21 18:09:05.468077+00	2026-07-21 18:09:05.468077+00
2f01124a-87cc-42c0-aff1-ff0045070c4d	1fb55dc6-b67c-46e0-b25e-818a9b2b4cdf	f7d585ca-9137-4691-8979-1d8553a71ed8	تست و اطمینان از عملکرد صحیح	107	52	2026-07-16	approved	10b934e7-80e6-41d0-9140-f56d92d614ae	\N	68208f60-63a3-49d2-9fd9-6cf7f88a3735	2026-07-21 18:09:05.468077+00	2026-07-21 18:09:05.468077+00
2f01124a-87cc-42c0-aff1-ff0045070c4d	b31b3e4c-dac0-4487-85a5-2b1511599a8d	4e4c6e76-84d5-464d-957c-75ff3e9a2f8a	پیشرفت اولیه و بررسی نیازمندی‌ها	90	32	2026-07-16	approved	10b934e7-80e6-41d0-9140-f56d92d614ae	\N	2703471c-9e02-462e-bde9-1fd13ddce4d7	2026-07-21 18:09:05.468077+00	2026-07-21 18:09:05.468077+00
2f01124a-87cc-42c0-aff1-ff0045070c4d	b31b3e4c-dac0-4487-85a5-2b1511599a8d	4e4c6e76-84d5-464d-957c-75ff3e9a2f8a	مستندسازی و نهایی‌سازی	105	58	2026-07-16	approved	10b934e7-80e6-41d0-9140-f56d92d614ae	\N	4d95f91a-f1cf-480d-b001-8715379f1984	2026-07-21 18:09:05.468077+00	2026-07-21 18:09:05.468077+00
2f01124a-87cc-42c0-aff1-ff0045070c4d	b31b3e4c-dac0-4487-85a5-2b1511599a8d	4e4c6e76-84d5-464d-957c-75ff3e9a2f8a	تست و اطمینان از عملکرد صحیح	100	60	2026-07-16	approved	10b934e7-80e6-41d0-9140-f56d92d614ae	\N	8ff3686b-7fef-4dfb-a5f4-f6ef63528179	2026-07-21 18:09:05.468077+00	2026-07-21 18:09:05.468077+00
2f01124a-87cc-42c0-aff1-ff0045070c4d	b31b3e4c-dac0-4487-85a5-2b1511599a8d	4e4c6e76-84d5-464d-957c-75ff3e9a2f8a	مستندسازی و نهایی‌سازی	220	100	2026-07-16	approved	10b934e7-80e6-41d0-9140-f56d92d614ae	\N	7c04c2b0-84b7-41d8-8cbb-6702b49310be	2026-07-21 18:09:05.468077+00	2026-07-21 18:09:05.468077+00
2f01124a-87cc-42c0-aff1-ff0045070c4d	0954b5a9-fdc0-41a9-b214-029139a2aa35	1c04dd92-4377-490c-934c-38244ec68419	رفع اشکالات و بازبینی	86	40	2026-06-29	approved	10b934e7-80e6-41d0-9140-f56d92d614ae	\N	8c8bde8c-abcd-42ba-907c-8802163ce55b	2026-07-21 18:09:05.468077+00	2026-07-21 18:09:05.468077+00
2f01124a-87cc-42c0-aff1-ff0045070c4d	0954b5a9-fdc0-41a9-b214-029139a2aa35	1c04dd92-4377-490c-934c-38244ec68419	پیاده‌سازی بخش اصلی	190	46	2026-07-01	approved	10b934e7-80e6-41d0-9140-f56d92d614ae	\N	df6f93e1-95c4-4553-84d3-01c470618086	2026-07-21 18:09:05.468077+00	2026-07-21 18:09:05.468077+00
2f01124a-87cc-42c0-aff1-ff0045070c4d	0954b5a9-fdc0-41a9-b214-029139a2aa35	1c04dd92-4377-490c-934c-38244ec68419	تست و اطمینان از عملکرد صحیح	38	100	2026-07-01	approved	10b934e7-80e6-41d0-9140-f56d92d614ae	\N	ac81d37a-2e27-40b7-bc78-6bbb38b85e19	2026-07-21 18:09:05.468077+00	2026-07-21 18:09:05.468077+00
2f01124a-87cc-42c0-aff1-ff0045070c4d	828cc768-f382-45b8-84b7-b7b4b0f9638e	1c04dd92-4377-490c-934c-38244ec68419	رفع اشکالات و بازبینی	113	33	2026-06-23	approved	10b934e7-80e6-41d0-9140-f56d92d614ae	\N	0114f036-76f5-4cab-b81a-dfc6df6899af	2026-07-21 18:09:05.468077+00	2026-07-21 18:09:05.468077+00
2f01124a-87cc-42c0-aff1-ff0045070c4d	828cc768-f382-45b8-84b7-b7b4b0f9638e	1c04dd92-4377-490c-934c-38244ec68419	مستندسازی و نهایی‌سازی	123	72	2026-06-25	approved	10b934e7-80e6-41d0-9140-f56d92d614ae	\N	dfa62623-40f5-45c2-96a8-9514dba8039e	2026-07-21 18:09:05.468077+00	2026-07-21 18:09:05.468077+00
2f01124a-87cc-42c0-aff1-ff0045070c4d	828cc768-f382-45b8-84b7-b7b4b0f9638e	1c04dd92-4377-490c-934c-38244ec68419	رفع اشکالات و بازبینی	153	87	2026-06-29	submitted	\N	\N	889c2176-0661-44a8-affa-d80c9c91c3aa	2026-07-21 18:09:05.468077+00	2026-07-21 18:09:05.468077+00
2f01124a-87cc-42c0-aff1-ff0045070c4d	10cdce85-5d76-420d-beba-e36c98ace7ef	10b934e7-80e6-41d0-9140-f56d92d614ae	پیشرفت اولیه و بررسی نیازمندی‌ها	66	27	2026-07-16	approved	10b934e7-80e6-41d0-9140-f56d92d614ae	\N	0d064eba-ad3e-4c12-8bef-76b74c13477a	2026-07-21 18:09:05.468077+00	2026-07-21 18:09:05.468077+00
2f01124a-87cc-42c0-aff1-ff0045070c4d	10cdce85-5d76-420d-beba-e36c98ace7ef	10b934e7-80e6-41d0-9140-f56d92d614ae	مستندسازی و نهایی‌سازی	123	44	2026-07-16	submitted	\N	\N	dc33f50d-eda8-4596-8a1b-8088dab7255a	2026-07-21 18:09:05.468077+00	2026-07-21 18:09:05.468077+00
2f01124a-87cc-42c0-aff1-ff0045070c4d	10cdce85-5d76-420d-beba-e36c98ace7ef	10b934e7-80e6-41d0-9140-f56d92d614ae	مستندسازی و نهایی‌سازی	61	100	2026-07-16	approved	10b934e7-80e6-41d0-9140-f56d92d614ae	\N	390f3833-fb8d-42bf-8e53-4c1cca735b14	2026-07-21 18:09:05.468077+00	2026-07-21 18:09:05.468077+00
2f01124a-87cc-42c0-aff1-ff0045070c4d	4b583741-8e68-425e-ba9b-c7df43795306	1c04dd92-4377-490c-934c-38244ec68419	مستندسازی و نهایی‌سازی	127	40	2026-07-01	approved	10b934e7-80e6-41d0-9140-f56d92d614ae	\N	d16b2cde-178f-4d23-a631-4a1e425334f0	2026-07-21 18:09:05.468077+00	2026-07-21 18:09:05.468077+00
2f01124a-87cc-42c0-aff1-ff0045070c4d	4b583741-8e68-425e-ba9b-c7df43795306	1c04dd92-4377-490c-934c-38244ec68419	پیشرفت اولیه و بررسی نیازمندی‌ها	202	54	2026-07-04	approved	10b934e7-80e6-41d0-9140-f56d92d614ae	\N	f750509e-dd62-4b1e-b764-cd9167b3d0bb	2026-07-21 18:09:05.468077+00	2026-07-21 18:09:05.468077+00
2f01124a-87cc-42c0-aff1-ff0045070c4d	4b583741-8e68-425e-ba9b-c7df43795306	1c04dd92-4377-490c-934c-38244ec68419	پیشرفت اولیه و بررسی نیازمندی‌ها	188	100	2026-07-09	approved	10b934e7-80e6-41d0-9140-f56d92d614ae	\N	a5bf1240-840a-4c11-b87c-7c6063a76466	2026-07-21 18:09:05.468077+00	2026-07-21 18:09:05.468077+00
2f01124a-87cc-42c0-aff1-ff0045070c4d	d0806521-9c88-4084-82c9-03d77ad8d46b	4e4c6e76-84d5-464d-957c-75ff3e9a2f8a	پیشرفت اولیه و بررسی نیازمندی‌ها	192	34	2026-07-16	approved	10b934e7-80e6-41d0-9140-f56d92d614ae	\N	7e1fb43c-94b1-46d3-ace0-c6a20e281b90	2026-07-21 18:09:05.468077+00	2026-07-21 18:09:05.468077+00
2f01124a-87cc-42c0-aff1-ff0045070c4d	d0806521-9c88-4084-82c9-03d77ad8d46b	4e4c6e76-84d5-464d-957c-75ff3e9a2f8a	تست و اطمینان از عملکرد صحیح	59	48	2026-07-16	approved	10b934e7-80e6-41d0-9140-f56d92d614ae	\N	4117b8a1-290a-42f5-974d-932a0ec48f80	2026-07-21 18:09:05.468077+00	2026-07-21 18:09:05.468077+00
2f01124a-87cc-42c0-aff1-ff0045070c4d	d0806521-9c88-4084-82c9-03d77ad8d46b	4e4c6e76-84d5-464d-957c-75ff3e9a2f8a	پیشرفت اولیه و بررسی نیازمندی‌ها	107	100	2026-07-16	approved	10b934e7-80e6-41d0-9140-f56d92d614ae	\N	acdb7f41-0fe7-4709-a838-57c1f716e695	2026-07-21 18:09:05.468077+00	2026-07-21 18:09:05.468077+00
2f01124a-87cc-42c0-aff1-ff0045070c4d	09237027-2865-43fc-ba06-76668696b85c	de5c1d0c-3ca8-4c75-8525-abcfac9d0651	پیاده‌سازی بخش اصلی	167	24	2026-07-05	approved	10b934e7-80e6-41d0-9140-f56d92d614ae	\N	10316818-24c3-4f3b-805f-493ec85313eb	2026-07-21 18:09:05.468077+00	2026-07-21 18:09:05.468077+00
2f01124a-87cc-42c0-aff1-ff0045070c4d	829588b6-3727-4729-ba2b-e80db248ccc9	f7d585ca-9137-4691-8979-1d8553a71ed8	رفع اشکالات و بازبینی	201	37	2026-07-16	approved	10b934e7-80e6-41d0-9140-f56d92d614ae	\N	d40f66bf-09b2-482d-a79c-0ad49601f008	2026-07-21 18:09:05.468077+00	2026-07-21 18:09:05.468077+00
2f01124a-87cc-42c0-aff1-ff0045070c4d	829588b6-3727-4729-ba2b-e80db248ccc9	f7d585ca-9137-4691-8979-1d8553a71ed8	مستندسازی و نهایی‌سازی	220	48	2026-07-16	approved	10b934e7-80e6-41d0-9140-f56d92d614ae	\N	5944358a-d756-45a7-a184-5eeff8cc0d29	2026-07-21 18:09:05.468077+00	2026-07-21 18:09:05.468077+00
2f01124a-87cc-42c0-aff1-ff0045070c4d	829588b6-3727-4729-ba2b-e80db248ccc9	f7d585ca-9137-4691-8979-1d8553a71ed8	پیشرفت اولیه و بررسی نیازمندی‌ها	155	100	2026-07-16	approved	10b934e7-80e6-41d0-9140-f56d92d614ae	\N	84b81478-d732-4431-8f2f-4ceba47f637f	2026-07-21 18:09:05.468077+00	2026-07-21 18:09:05.468077+00
2f01124a-87cc-42c0-aff1-ff0045070c4d	829588b6-3727-4729-ba2b-e80db248ccc9	f7d585ca-9137-4691-8979-1d8553a71ed8	رفع اشکالات و بازبینی	38	100	2026-07-16	approved	10b934e7-80e6-41d0-9140-f56d92d614ae	\N	a93a4932-324a-44f1-bed3-8716b3f4e7c1	2026-07-21 18:09:05.468077+00	2026-07-21 18:09:05.468077+00
2f01124a-87cc-42c0-aff1-ff0045070c4d	589a14d9-e716-47e9-9334-d8b59d177565	10b934e7-80e6-41d0-9140-f56d92d614ae	تست و اطمینان از عملکرد صحیح	90	31	2026-07-16	approved	10b934e7-80e6-41d0-9140-f56d92d614ae	\N	efb83952-7784-4fd4-bab8-1a98b2907985	2026-07-21 18:09:05.468077+00	2026-07-21 18:09:05.468077+00
2f01124a-87cc-42c0-aff1-ff0045070c4d	589a14d9-e716-47e9-9334-d8b59d177565	10b934e7-80e6-41d0-9140-f56d92d614ae	رفع اشکالات و بازبینی	169	80	2026-07-16	approved	10b934e7-80e6-41d0-9140-f56d92d614ae	\N	9a084b49-d775-4d16-8c56-7070b9deace0	2026-07-21 18:09:05.468077+00	2026-07-21 18:09:05.468077+00
2f01124a-87cc-42c0-aff1-ff0045070c4d	704ebfc4-1bd5-45dc-8576-06f0ff2cd593	4e4c6e76-84d5-464d-957c-75ff3e9a2f8a	پیاده‌سازی بخش اصلی	61	34	2026-07-16	approved	10b934e7-80e6-41d0-9140-f56d92d614ae	\N	7983949e-150a-4d8d-9e74-c81204561218	2026-07-21 18:09:05.468077+00	2026-07-21 18:09:05.468077+00
2f01124a-87cc-42c0-aff1-ff0045070c4d	704ebfc4-1bd5-45dc-8576-06f0ff2cd593	4e4c6e76-84d5-464d-957c-75ff3e9a2f8a	مستندسازی و نهایی‌سازی	35	42	2026-07-16	approved	10b934e7-80e6-41d0-9140-f56d92d614ae	\N	28da7bb8-718e-459c-b6c4-7aff57cd6295	2026-07-21 18:09:05.468077+00	2026-07-21 18:09:05.468077+00
2f01124a-87cc-42c0-aff1-ff0045070c4d	704ebfc4-1bd5-45dc-8576-06f0ff2cd593	4e4c6e76-84d5-464d-957c-75ff3e9a2f8a	پیاده‌سازی بخش اصلی	231	100	2026-07-16	approved	10b934e7-80e6-41d0-9140-f56d92d614ae	\N	afdaf145-aa92-4ba6-a57e-6e11d1fa0792	2026-07-21 18:09:05.468077+00	2026-07-21 18:09:05.468077+00
2f01124a-87cc-42c0-aff1-ff0045070c4d	13545e89-cd6a-4d33-a79c-8c0d6e9a8690	0aa2e3a9-85b6-420a-aeeb-62f6f7061c6c	مستندسازی و نهایی‌سازی	83	38	2026-06-20	approved	10b934e7-80e6-41d0-9140-f56d92d614ae	\N	5c6f0642-ff98-4984-b4a3-57c239267f6c	2026-07-21 18:09:05.468077+00	2026-07-21 18:09:05.468077+00
2f01124a-87cc-42c0-aff1-ff0045070c4d	13545e89-cd6a-4d33-a79c-8c0d6e9a8690	0aa2e3a9-85b6-420a-aeeb-62f6f7061c6c	پیاده‌سازی بخش اصلی	114	48	2026-06-22	approved	10b934e7-80e6-41d0-9140-f56d92d614ae	\N	89761fc4-1ec4-44f6-998e-c522cfbd45c0	2026-07-21 18:09:05.468077+00	2026-07-21 18:09:05.468077+00
2f01124a-87cc-42c0-aff1-ff0045070c4d	861a5d8c-8532-4da9-aba0-f6e76d092a01	de5c1d0c-3ca8-4c75-8525-abcfac9d0651	پیاده‌سازی بخش اصلی	63	37	2026-06-24	approved	10b934e7-80e6-41d0-9140-f56d92d614ae	\N	4cbae313-c598-4487-ac79-8dd649ab9c4b	2026-07-21 18:09:05.468077+00	2026-07-21 18:09:05.468077+00
2f01124a-87cc-42c0-aff1-ff0045070c4d	4d754fa9-cfee-4aa9-a6c7-43e0523b7eb4	4e4c6e76-84d5-464d-957c-75ff3e9a2f8a	پیشرفت اولیه و بررسی نیازمندی‌ها	199	20	2026-07-16	approved	10b934e7-80e6-41d0-9140-f56d92d614ae	\N	54e8cc35-ff14-4b32-bda0-0bf057a47c92	2026-07-21 18:09:05.468077+00	2026-07-21 18:09:05.468077+00
2f01124a-87cc-42c0-aff1-ff0045070c4d	4d754fa9-cfee-4aa9-a6c7-43e0523b7eb4	4e4c6e76-84d5-464d-957c-75ff3e9a2f8a	پیشرفت اولیه و بررسی نیازمندی‌ها	121	54	2026-07-16	approved	10b934e7-80e6-41d0-9140-f56d92d614ae	\N	91d3dc78-9a13-449a-8195-f90c197808ed	2026-07-21 18:09:05.468077+00	2026-07-21 18:09:05.468077+00
2f01124a-87cc-42c0-aff1-ff0045070c4d	4d754fa9-cfee-4aa9-a6c7-43e0523b7eb4	4e4c6e76-84d5-464d-957c-75ff3e9a2f8a	پیشرفت اولیه و بررسی نیازمندی‌ها	74	84	2026-07-16	approved	10b934e7-80e6-41d0-9140-f56d92d614ae	\N	93274323-133b-4c0d-b6ca-24d388385cfb	2026-07-21 18:09:05.468077+00	2026-07-21 18:09:05.468077+00
2f01124a-87cc-42c0-aff1-ff0045070c4d	7be70dd6-f60a-416b-93d5-7d4b710d1076	4e4c6e76-84d5-464d-957c-75ff3e9a2f8a	مستندسازی و نهایی‌سازی	59	22	2026-07-16	submitted	\N	\N	115b9a44-f023-4040-a49c-01dcaa7506ca	2026-07-21 18:09:05.468077+00	2026-07-21 18:09:05.468077+00
2f01124a-87cc-42c0-aff1-ff0045070c4d	6e1925d8-60d1-4dc1-8e50-6f4da0a7db4a	10b934e7-80e6-41d0-9140-f56d92d614ae	رفع اشکالات و بازبینی	161	38	2026-07-16	approved	10b934e7-80e6-41d0-9140-f56d92d614ae	\N	78cefc9b-96d5-4f40-b16f-536e0ca69451	2026-07-21 18:09:05.468077+00	2026-07-21 18:09:05.468077+00
2f01124a-87cc-42c0-aff1-ff0045070c4d	6e1925d8-60d1-4dc1-8e50-6f4da0a7db4a	10b934e7-80e6-41d0-9140-f56d92d614ae	تست و اطمینان از عملکرد صحیح	158	54	2026-07-16	approved	10b934e7-80e6-41d0-9140-f56d92d614ae	\N	2157e32f-47a2-44b9-8f7e-15906d56505a	2026-07-21 18:09:05.468077+00	2026-07-21 18:09:05.468077+00
2f01124a-87cc-42c0-aff1-ff0045070c4d	6e1925d8-60d1-4dc1-8e50-6f4da0a7db4a	10b934e7-80e6-41d0-9140-f56d92d614ae	مستندسازی و نهایی‌سازی	107	100	2026-07-16	approved	10b934e7-80e6-41d0-9140-f56d92d614ae	\N	1764a35d-99db-4c73-b0b2-6a987903105e	2026-07-21 18:09:05.468077+00	2026-07-21 18:09:05.468077+00
2f01124a-87cc-42c0-aff1-ff0045070c4d	6e1925d8-60d1-4dc1-8e50-6f4da0a7db4a	10b934e7-80e6-41d0-9140-f56d92d614ae	پیشرفت اولیه و بررسی نیازمندی‌ها	152	100	2026-07-16	approved	10b934e7-80e6-41d0-9140-f56d92d614ae	\N	62b89a9b-4e21-4fc2-81ec-d0740cb40130	2026-07-21 18:09:05.468077+00	2026-07-21 18:09:05.468077+00
2f01124a-87cc-42c0-aff1-ff0045070c4d	7433ea2b-ade9-4c67-8994-b210612332eb	f7d585ca-9137-4691-8979-1d8553a71ed8	تست و اطمینان از عملکرد صحیح	48	22	2026-06-30	approved	10b934e7-80e6-41d0-9140-f56d92d614ae	\N	cce399be-88c6-46e9-b264-81679702988a	2026-07-21 18:09:05.468077+00	2026-07-21 18:09:05.468077+00
2f01124a-87cc-42c0-aff1-ff0045070c4d	7433ea2b-ade9-4c67-8994-b210612332eb	f7d585ca-9137-4691-8979-1d8553a71ed8	پیشرفت اولیه و بررسی نیازمندی‌ها	62	56	2026-07-03	approved	10b934e7-80e6-41d0-9140-f56d92d614ae	\N	a2cd1514-cbf6-4377-9463-9bfaba9bad91	2026-07-21 18:09:05.468077+00	2026-07-21 18:09:05.468077+00
2f01124a-87cc-42c0-aff1-ff0045070c4d	7433ea2b-ade9-4c67-8994-b210612332eb	f7d585ca-9137-4691-8979-1d8553a71ed8	مستندسازی و نهایی‌سازی	165	87	2026-07-06	approved	10b934e7-80e6-41d0-9140-f56d92d614ae	\N	776fd1cd-bc35-419f-8663-719fb998f4e0	2026-07-21 18:09:05.468077+00	2026-07-21 18:09:05.468077+00
2f01124a-87cc-42c0-aff1-ff0045070c4d	7433ea2b-ade9-4c67-8994-b210612332eb	f7d585ca-9137-4691-8979-1d8553a71ed8	تست و اطمینان از عملکرد صحیح	55	92	2026-07-12	approved	10b934e7-80e6-41d0-9140-f56d92d614ae	\N	31b4b3e2-2711-4462-87a6-c372151de92b	2026-07-21 18:09:05.468077+00	2026-07-21 18:09:05.468077+00
2f01124a-87cc-42c0-aff1-ff0045070c4d	adcbf00e-da05-4444-8a2f-a1f6732c1aa1	f7d585ca-9137-4691-8979-1d8553a71ed8	تست و اطمینان از عملکرد صحیح	88	33	2026-06-17	approved	10b934e7-80e6-41d0-9140-f56d92d614ae	\N	b3cff8c4-0ab7-4f49-ac6e-02c292e3bec1	2026-07-21 18:09:05.468077+00	2026-07-21 18:09:05.468077+00
2f01124a-87cc-42c0-aff1-ff0045070c4d	adcbf00e-da05-4444-8a2f-a1f6732c1aa1	f7d585ca-9137-4691-8979-1d8553a71ed8	تست و اطمینان از عملکرد صحیح	132	66	2026-06-20	approved	10b934e7-80e6-41d0-9140-f56d92d614ae	\N	7f6c4f12-2e92-487a-a83d-ef20b6352301	2026-07-21 18:09:05.468077+00	2026-07-21 18:09:05.468077+00
2f01124a-87cc-42c0-aff1-ff0045070c4d	aa8d6c68-84a2-4deb-a404-7973171fc10c	10b934e7-80e6-41d0-9140-f56d92d614ae	تست و اطمینان از عملکرد صحیح	110	28	2026-07-16	approved	10b934e7-80e6-41d0-9140-f56d92d614ae	\N	ac3120a2-e5c5-4fa7-85b7-62ea6e6cc351	2026-07-21 18:09:05.468077+00	2026-07-21 18:09:05.468077+00
2f01124a-87cc-42c0-aff1-ff0045070c4d	e1b7574c-65d2-4bea-ad4b-93dbc9e6e4ce	dfe22c83-6863-413d-97b7-1eb9b52dec02	تست و اطمینان از عملکرد صحیح	47	22	2026-07-16	approved	10b934e7-80e6-41d0-9140-f56d92d614ae	\N	ce9fb2c5-316f-4b9b-bae7-d1305265d9fa	2026-07-21 18:09:05.468077+00	2026-07-21 18:09:05.468077+00
2f01124a-87cc-42c0-aff1-ff0045070c4d	e1b7574c-65d2-4bea-ad4b-93dbc9e6e4ce	dfe22c83-6863-413d-97b7-1eb9b52dec02	پیشرفت اولیه و بررسی نیازمندی‌ها	220	62	2026-07-16	approved	10b934e7-80e6-41d0-9140-f56d92d614ae	\N	d93a485b-20df-4b57-bd79-917056e4d652	2026-07-21 18:09:05.468077+00	2026-07-21 18:09:05.468077+00
2f01124a-87cc-42c0-aff1-ff0045070c4d	e1b7574c-65d2-4bea-ad4b-93dbc9e6e4ce	dfe22c83-6863-413d-97b7-1eb9b52dec02	مستندسازی و نهایی‌سازی	173	100	2026-07-16	approved	10b934e7-80e6-41d0-9140-f56d92d614ae	\N	0e42dba3-8765-410d-9489-6015e69041b9	2026-07-21 18:09:05.468077+00	2026-07-21 18:09:05.468077+00
2f01124a-87cc-42c0-aff1-ff0045070c4d	2d3acd4a-d503-45ef-8898-7939db3207e0	dfe22c83-6863-413d-97b7-1eb9b52dec02	تست و اطمینان از عملکرد صحیح	214	21	2026-07-06	approved	10b934e7-80e6-41d0-9140-f56d92d614ae	\N	50488f6e-7cf4-4280-aaf1-82acf49f5f78	2026-07-21 18:09:05.468077+00	2026-07-21 18:09:05.468077+00
2f01124a-87cc-42c0-aff1-ff0045070c4d	2d3acd4a-d503-45ef-8898-7939db3207e0	dfe22c83-6863-413d-97b7-1eb9b52dec02	رفع اشکالات و بازبینی	56	76	2026-07-09	approved	10b934e7-80e6-41d0-9140-f56d92d614ae	\N	79338962-155c-47d7-9bd2-cacda44a32c0	2026-07-21 18:09:05.468077+00	2026-07-21 18:09:05.468077+00
2f01124a-87cc-42c0-aff1-ff0045070c4d	2d3acd4a-d503-45ef-8898-7939db3207e0	dfe22c83-6863-413d-97b7-1eb9b52dec02	تست و اطمینان از عملکرد صحیح	87	69	2026-07-10	approved	10b934e7-80e6-41d0-9140-f56d92d614ae	\N	f9344335-c8f5-4084-a8de-ce87fa6e46f2	2026-07-21 18:09:05.468077+00	2026-07-21 18:09:05.468077+00
2f01124a-87cc-42c0-aff1-ff0045070c4d	69329ea7-6d7e-4f39-8638-bbac94d51c59	0aa2e3a9-85b6-420a-aeeb-62f6f7061c6c	پیشرفت اولیه و بررسی نیازمندی‌ها	225	28	2026-07-16	approved	10b934e7-80e6-41d0-9140-f56d92d614ae	\N	da9c25c9-ce54-4e3e-809e-ed9bb8ef16ed	2026-07-21 18:09:05.468077+00	2026-07-21 18:09:05.468077+00
2f01124a-87cc-42c0-aff1-ff0045070c4d	69329ea7-6d7e-4f39-8638-bbac94d51c59	0aa2e3a9-85b6-420a-aeeb-62f6f7061c6c	تست و اطمینان از عملکرد صحیح	173	78	2026-07-16	approved	10b934e7-80e6-41d0-9140-f56d92d614ae	\N	c01d3c58-0112-4d60-a1b1-9045dcd3bca0	2026-07-21 18:09:05.468077+00	2026-07-21 18:09:05.468077+00
2f01124a-87cc-42c0-aff1-ff0045070c4d	69329ea7-6d7e-4f39-8638-bbac94d51c59	0aa2e3a9-85b6-420a-aeeb-62f6f7061c6c	مستندسازی و نهایی‌سازی	198	84	2026-07-16	approved	10b934e7-80e6-41d0-9140-f56d92d614ae	\N	4713ad55-5231-4c35-b861-b339b7e815c1	2026-07-21 18:09:05.468077+00	2026-07-21 18:09:05.468077+00
2f01124a-87cc-42c0-aff1-ff0045070c4d	1b5faa26-1703-40e7-9fd9-dac691c1021b	4e4c6e76-84d5-464d-957c-75ff3e9a2f8a	رفع اشکالات و بازبینی	209	29	2026-07-16	approved	10b934e7-80e6-41d0-9140-f56d92d614ae	\N	680ec9fb-fa96-4b7f-ad7c-d051a650c36e	2026-07-21 18:09:05.468077+00	2026-07-21 18:09:05.468077+00
2f01124a-87cc-42c0-aff1-ff0045070c4d	25a91789-dbfa-420c-84e9-b5ff8803ad55	f7d585ca-9137-4691-8979-1d8553a71ed8	پیشرفت اولیه و بررسی نیازمندی‌ها	76	24	2026-06-26	approved	10b934e7-80e6-41d0-9140-f56d92d614ae	\N	f97a3717-b8f0-4b4e-b4d1-cd1cf0ba1d36	2026-07-21 18:09:05.468077+00	2026-07-21 18:09:05.468077+00
2f01124a-87cc-42c0-aff1-ff0045070c4d	25a91789-dbfa-420c-84e9-b5ff8803ad55	f7d585ca-9137-4691-8979-1d8553a71ed8	پیشرفت اولیه و بررسی نیازمندی‌ها	66	80	2026-06-30	approved	10b934e7-80e6-41d0-9140-f56d92d614ae	\N	a2db625c-bf54-4cdd-bbae-7e61726e9f9b	2026-07-21 18:09:05.468077+00	2026-07-21 18:09:05.468077+00
2f01124a-87cc-42c0-aff1-ff0045070c4d	25a91789-dbfa-420c-84e9-b5ff8803ad55	f7d585ca-9137-4691-8979-1d8553a71ed8	پیشرفت اولیه و بررسی نیازمندی‌ها	221	100	2026-06-28	approved	10b934e7-80e6-41d0-9140-f56d92d614ae	\N	e543ec35-2b04-432e-bee8-aa3a7546d001	2026-07-21 18:09:05.468077+00	2026-07-21 18:09:05.468077+00
2f01124a-87cc-42c0-aff1-ff0045070c4d	2566f5aa-3854-4f71-a7df-af6bc7618727	f7d585ca-9137-4691-8979-1d8553a71ed8	تست و اطمینان از عملکرد صحیح	146	30	2026-07-01	approved	10b934e7-80e6-41d0-9140-f56d92d614ae	\N	ce54796a-a01c-4851-830c-97fc37f134ef	2026-07-21 18:09:05.468077+00	2026-07-21 18:09:05.468077+00
2f01124a-87cc-42c0-aff1-ff0045070c4d	2566f5aa-3854-4f71-a7df-af6bc7618727	f7d585ca-9137-4691-8979-1d8553a71ed8	رفع اشکالات و بازبینی	109	60	2026-07-03	approved	10b934e7-80e6-41d0-9140-f56d92d614ae	\N	b1e3030e-b281-446f-a0be-09371bf96f96	2026-07-21 18:09:05.468077+00	2026-07-21 18:09:05.468077+00
2f01124a-87cc-42c0-aff1-ff0045070c4d	e0be053f-cce4-4b79-9775-2deaf220d935	1c04dd92-4377-490c-934c-38244ec68419	پیاده‌سازی بخش اصلی	70	39	2026-07-16	approved	10b934e7-80e6-41d0-9140-f56d92d614ae	\N	10e04954-a574-469a-9a9a-531ae2b1b939	2026-07-21 18:09:05.468077+00	2026-07-21 18:09:05.468077+00
2f01124a-87cc-42c0-aff1-ff0045070c4d	0b8e72bc-18e8-4bde-b1ad-726765bb55cf	dfe22c83-6863-413d-97b7-1eb9b52dec02	رفع اشکالات و بازبینی	143	33	2026-07-16	approved	10b934e7-80e6-41d0-9140-f56d92d614ae	\N	ecd0c276-2eea-4cfb-981a-99608075f1fe	2026-07-21 18:09:05.468077+00	2026-07-21 18:09:05.468077+00
2f01124a-87cc-42c0-aff1-ff0045070c4d	b606de04-2549-4678-b8c9-41e69b3b1d02	f7d585ca-9137-4691-8979-1d8553a71ed8	تست و اطمینان از عملکرد صحیح	99	26	2026-07-16	approved	10b934e7-80e6-41d0-9140-f56d92d614ae	\N	c4986b01-4cd7-45c0-ace6-1eba24bf81e0	2026-07-21 18:09:05.468077+00	2026-07-21 18:09:05.468077+00
2f01124a-87cc-42c0-aff1-ff0045070c4d	b606de04-2549-4678-b8c9-41e69b3b1d02	f7d585ca-9137-4691-8979-1d8553a71ed8	رفع اشکالات و بازبینی	140	46	2026-07-16	approved	10b934e7-80e6-41d0-9140-f56d92d614ae	\N	8a1cf19e-2b52-4a94-98a8-dbbb13ec4907	2026-07-21 18:09:05.468077+00	2026-07-21 18:09:05.468077+00
2f01124a-87cc-42c0-aff1-ff0045070c4d	b606de04-2549-4678-b8c9-41e69b3b1d02	f7d585ca-9137-4691-8979-1d8553a71ed8	مستندسازی و نهایی‌سازی	154	100	2026-07-16	approved	10b934e7-80e6-41d0-9140-f56d92d614ae	\N	57b51822-3cd3-4f78-80f2-13693b758ab1	2026-07-21 18:09:05.468077+00	2026-07-21 18:09:05.468077+00
2f01124a-87cc-42c0-aff1-ff0045070c4d	b606de04-2549-4678-b8c9-41e69b3b1d02	f7d585ca-9137-4691-8979-1d8553a71ed8	پیشرفت اولیه و بررسی نیازمندی‌ها	86	100	2026-07-16	approved	10b934e7-80e6-41d0-9140-f56d92d614ae	\N	89904183-dd6f-4cc6-aacf-784082bb6c2a	2026-07-21 18:09:05.468077+00	2026-07-21 18:09:05.468077+00
2f01124a-87cc-42c0-aff1-ff0045070c4d	06d2bf9d-3a10-46d3-ba9b-a73089df2da0	dfe22c83-6863-413d-97b7-1eb9b52dec02	پیاده‌سازی بخش اصلی	107	26	2026-07-16	approved	10b934e7-80e6-41d0-9140-f56d92d614ae	\N	03a08e3e-ab3d-4198-9b74-297a2204f563	2026-07-21 18:09:05.468077+00	2026-07-21 18:09:05.468077+00
2f01124a-87cc-42c0-aff1-ff0045070c4d	7af1624b-a09a-43a2-98ce-60b18c33cdd0	0aa2e3a9-85b6-420a-aeeb-62f6f7061c6c	رفع اشکالات و بازبینی	113	23	2026-07-01	approved	10b934e7-80e6-41d0-9140-f56d92d614ae	\N	ce9ee5f9-602d-48dd-8f8c-3b703fb7ff7b	2026-07-21 18:09:05.468077+00	2026-07-21 18:09:05.468077+00
2f01124a-87cc-42c0-aff1-ff0045070c4d	7af1624b-a09a-43a2-98ce-60b18c33cdd0	0aa2e3a9-85b6-420a-aeeb-62f6f7061c6c	تست و اطمینان از عملکرد صحیح	221	66	2026-07-02	approved	10b934e7-80e6-41d0-9140-f56d92d614ae	\N	e41335d2-e920-4711-ad6c-2bca11dab0d9	2026-07-21 18:09:05.468077+00	2026-07-21 18:09:05.468077+00
2f01124a-87cc-42c0-aff1-ff0045070c4d	8750b0b6-ac9a-4abd-890a-6f3412f49c85	1c04dd92-4377-490c-934c-38244ec68419	پیاده‌سازی بخش اصلی	158	37	2026-07-14	approved	10b934e7-80e6-41d0-9140-f56d92d614ae	\N	847350e6-9907-4721-8441-0dd2b69d08dd	2026-07-21 18:09:05.468077+00	2026-07-21 18:09:05.468077+00
2f01124a-87cc-42c0-aff1-ff0045070c4d	8750b0b6-ac9a-4abd-890a-6f3412f49c85	1c04dd92-4377-490c-934c-38244ec68419	پیشرفت اولیه و بررسی نیازمندی‌ها	141	40	2026-07-16	approved	10b934e7-80e6-41d0-9140-f56d92d614ae	\N	f6beda29-4325-4713-bedf-54768ee6d50a	2026-07-21 18:09:05.468077+00	2026-07-21 18:09:05.468077+00
2f01124a-87cc-42c0-aff1-ff0045070c4d	f4fd781e-0654-49b2-bc8f-ecf5756c1b63	4e4c6e76-84d5-464d-957c-75ff3e9a2f8a	رفع اشکالات و بازبینی	177	33	2026-06-25	approved	10b934e7-80e6-41d0-9140-f56d92d614ae	\N	1a27c70f-7424-431a-a719-f924e26c8890	2026-07-21 18:09:05.468077+00	2026-07-21 18:09:05.468077+00
2f01124a-87cc-42c0-aff1-ff0045070c4d	f4fd781e-0654-49b2-bc8f-ecf5756c1b63	4e4c6e76-84d5-464d-957c-75ff3e9a2f8a	تست و اطمینان از عملکرد صحیح	104	46	2026-06-29	approved	10b934e7-80e6-41d0-9140-f56d92d614ae	\N	7658fe73-6666-451d-9c83-4b284f10136c	2026-07-21 18:09:05.468077+00	2026-07-21 18:09:05.468077+00
2f01124a-87cc-42c0-aff1-ff0045070c4d	f4fd781e-0654-49b2-bc8f-ecf5756c1b63	4e4c6e76-84d5-464d-957c-75ff3e9a2f8a	پیشرفت اولیه و بررسی نیازمندی‌ها	113	75	2026-07-03	approved	10b934e7-80e6-41d0-9140-f56d92d614ae	\N	99df7bde-ec27-4dab-a950-179ba37cbc51	2026-07-21 18:09:05.468077+00	2026-07-21 18:09:05.468077+00
2f01124a-87cc-42c0-aff1-ff0045070c4d	f4fd781e-0654-49b2-bc8f-ecf5756c1b63	4e4c6e76-84d5-464d-957c-75ff3e9a2f8a	رفع اشکالات و بازبینی	52	100	2026-07-07	approved	10b934e7-80e6-41d0-9140-f56d92d614ae	\N	8d9c04bf-522f-4ffc-88d8-4e61b1d3d168	2026-07-21 18:09:05.468077+00	2026-07-21 18:09:05.468077+00
2f01124a-87cc-42c0-aff1-ff0045070c4d	11d06158-ff2e-4e6f-9165-8cb11f78873a	1c04dd92-4377-490c-934c-38244ec68419	تست و اطمینان از عملکرد صحیح	164	22	2026-07-10	approved	10b934e7-80e6-41d0-9140-f56d92d614ae	\N	09ae5d15-2d2b-44b4-9cf4-031d3cfd2a27	2026-07-21 18:09:05.468077+00	2026-07-21 18:09:05.468077+00
2f01124a-87cc-42c0-aff1-ff0045070c4d	621f4d9d-4abb-4bb5-9ad0-84e3b160e31f	10b934e7-80e6-41d0-9140-f56d92d614ae	پیاده‌سازی بخش اصلی	115	25	2026-07-05	submitted	\N	\N	27b9d764-b2bb-482c-bafd-50db7de1e40e	2026-07-21 18:09:05.468077+00	2026-07-21 18:09:05.468077+00
2f01124a-87cc-42c0-aff1-ff0045070c4d	621f4d9d-4abb-4bb5-9ad0-84e3b160e31f	10b934e7-80e6-41d0-9140-f56d92d614ae	پیشرفت اولیه و بررسی نیازمندی‌ها	165	72	2026-07-06	approved	10b934e7-80e6-41d0-9140-f56d92d614ae	\N	e3bf970a-2bb5-432f-8af1-217634597bc9	2026-07-21 18:09:05.468077+00	2026-07-21 18:09:05.468077+00
2f01124a-87cc-42c0-aff1-ff0045070c4d	621f4d9d-4abb-4bb5-9ad0-84e3b160e31f	10b934e7-80e6-41d0-9140-f56d92d614ae	رفع اشکالات و بازبینی	119	100	2026-07-09	submitted	\N	\N	5f54e7c2-df9a-465f-a3d6-e47865fe72d5	2026-07-21 18:09:05.468077+00	2026-07-21 18:09:05.468077+00
2f01124a-87cc-42c0-aff1-ff0045070c4d	621f4d9d-4abb-4bb5-9ad0-84e3b160e31f	10b934e7-80e6-41d0-9140-f56d92d614ae	پیاده‌سازی بخش اصلی	95	100	2026-07-11	approved	10b934e7-80e6-41d0-9140-f56d92d614ae	\N	cf2530d6-a7a1-4c9a-8095-02766ed43dcd	2026-07-21 18:09:05.468077+00	2026-07-21 18:09:05.468077+00
2f01124a-87cc-42c0-aff1-ff0045070c4d	3285cece-bb4d-413d-a42f-c255462d08f9	de5c1d0c-3ca8-4c75-8525-abcfac9d0651	پیشرفت اولیه و بررسی نیازمندی‌ها	75	40	2026-07-16	approved	10b934e7-80e6-41d0-9140-f56d92d614ae	\N	6a865e8c-f5c3-40ce-85bf-3e930af7fd8a	2026-07-21 18:09:05.468077+00	2026-07-21 18:09:05.468077+00
2f01124a-87cc-42c0-aff1-ff0045070c4d	3285cece-bb4d-413d-a42f-c255462d08f9	de5c1d0c-3ca8-4c75-8525-abcfac9d0651	تست و اطمینان از عملکرد صحیح	223	76	2026-07-16	approved	10b934e7-80e6-41d0-9140-f56d92d614ae	\N	ddd9fb32-c77d-4aec-b3cc-6b8ce4f67450	2026-07-21 18:09:05.468077+00	2026-07-21 18:09:05.468077+00
2f01124a-87cc-42c0-aff1-ff0045070c4d	b80d768b-f20f-4ce5-ace9-8bf410de2225	0aa2e3a9-85b6-420a-aeeb-62f6f7061c6c	رفع اشکالات و بازبینی	68	34	2026-07-16	submitted	\N	\N	6a8e4340-da11-413d-ba66-062b9de863fe	2026-07-21 18:09:05.468077+00	2026-07-21 18:09:05.468077+00
2f01124a-87cc-42c0-aff1-ff0045070c4d	b80d768b-f20f-4ce5-ace9-8bf410de2225	0aa2e3a9-85b6-420a-aeeb-62f6f7061c6c	رفع اشکالات و بازبینی	233	56	2026-07-16	approved	10b934e7-80e6-41d0-9140-f56d92d614ae	\N	977229ba-2baa-42c4-bdb1-998d4884b69b	2026-07-21 18:09:05.468077+00	2026-07-21 18:09:05.468077+00
2f01124a-87cc-42c0-aff1-ff0045070c4d	b80d768b-f20f-4ce5-ace9-8bf410de2225	0aa2e3a9-85b6-420a-aeeb-62f6f7061c6c	پیشرفت اولیه و بررسی نیازمندی‌ها	109	100	2026-07-16	approved	10b934e7-80e6-41d0-9140-f56d92d614ae	\N	2bb633fb-08f5-4df2-b7e8-97c572a802c1	2026-07-21 18:09:05.468077+00	2026-07-21 18:09:05.468077+00
2f01124a-87cc-42c0-aff1-ff0045070c4d	b80d768b-f20f-4ce5-ace9-8bf410de2225	0aa2e3a9-85b6-420a-aeeb-62f6f7061c6c	رفع اشکالات و بازبینی	103	88	2026-07-16	approved	10b934e7-80e6-41d0-9140-f56d92d614ae	\N	a337a335-304c-4fb0-b3e4-e964f3ca6058	2026-07-21 18:09:05.468077+00	2026-07-21 18:09:05.468077+00
2f01124a-87cc-42c0-aff1-ff0045070c4d	1c94f370-25b5-4fd4-95df-6b0e66e04b9b	de5c1d0c-3ca8-4c75-8525-abcfac9d0651	تست و اطمینان از عملکرد صحیح	178	37	2026-07-11	approved	10b934e7-80e6-41d0-9140-f56d92d614ae	\N	eab184e9-8792-40f3-9aa3-2c5ab0fc8520	2026-07-21 18:09:05.468077+00	2026-07-21 18:09:05.468077+00
2f01124a-87cc-42c0-aff1-ff0045070c4d	4c70de38-b81d-4601-8799-26afc3154bda	dfe22c83-6863-413d-97b7-1eb9b52dec02	مستندسازی و نهایی‌سازی	196	26	2026-06-24	submitted	\N	\N	4b052cbd-1017-4e27-80fa-3e68c16baf2e	2026-07-21 18:09:05.468077+00	2026-07-21 18:09:05.468077+00
2f01124a-87cc-42c0-aff1-ff0045070c4d	e795d8c4-ba3b-48c2-99fb-24a6d6ed7bf5	1c04dd92-4377-490c-934c-38244ec68419	مستندسازی و نهایی‌سازی	68	21	2026-07-16	approved	10b934e7-80e6-41d0-9140-f56d92d614ae	\N	5610190c-0221-410f-8e8e-0f8356a669db	2026-07-21 18:09:05.468077+00	2026-07-21 18:09:05.468077+00
2f01124a-87cc-42c0-aff1-ff0045070c4d	e795d8c4-ba3b-48c2-99fb-24a6d6ed7bf5	1c04dd92-4377-490c-934c-38244ec68419	پیشرفت اولیه و بررسی نیازمندی‌ها	237	60	2026-07-16	approved	10b934e7-80e6-41d0-9140-f56d92d614ae	\N	92d4b2d4-7028-4593-ba1d-10c0d1c7199f	2026-07-21 18:09:05.468077+00	2026-07-21 18:09:05.468077+00
2f01124a-87cc-42c0-aff1-ff0045070c4d	e795d8c4-ba3b-48c2-99fb-24a6d6ed7bf5	1c04dd92-4377-490c-934c-38244ec68419	مستندسازی و نهایی‌سازی	195	75	2026-07-16	approved	10b934e7-80e6-41d0-9140-f56d92d614ae	\N	3a7aa7db-4f4f-4267-885c-52d9a0e4e095	2026-07-21 18:09:05.468077+00	2026-07-21 18:09:05.468077+00
2f01124a-87cc-42c0-aff1-ff0045070c4d	063a7b6b-c455-4f53-8b4d-34f9ed154d5a	10b934e7-80e6-41d0-9140-f56d92d614ae	تست و اطمینان از عملکرد صحیح	142	36	2026-07-16	approved	10b934e7-80e6-41d0-9140-f56d92d614ae	\N	dc967d19-3ade-4f27-a662-a3b4caccfe07	2026-07-21 18:09:05.468077+00	2026-07-21 18:09:05.468077+00
2f01124a-87cc-42c0-aff1-ff0045070c4d	3c3c3302-bf62-4955-8546-c4ae76272277	f7d585ca-9137-4691-8979-1d8553a71ed8	رفع اشکالات و بازبینی	102	32	2026-06-17	approved	10b934e7-80e6-41d0-9140-f56d92d614ae	\N	13262363-e8cd-450c-bda3-d1efc7420730	2026-07-21 18:09:05.468077+00	2026-07-21 18:09:05.468077+00
2f01124a-87cc-42c0-aff1-ff0045070c4d	3c3c3302-bf62-4955-8546-c4ae76272277	f7d585ca-9137-4691-8979-1d8553a71ed8	رفع اشکالات و بازبینی	203	78	2026-06-21	approved	10b934e7-80e6-41d0-9140-f56d92d614ae	\N	e1539462-144b-4f62-9ed9-719c1763d9c3	2026-07-21 18:09:05.468077+00	2026-07-21 18:09:05.468077+00
2f01124a-87cc-42c0-aff1-ff0045070c4d	26ad66d2-4994-48be-9195-0fa6d98caa28	f7d585ca-9137-4691-8979-1d8553a71ed8	پیشرفت اولیه و بررسی نیازمندی‌ها	172	32	2026-06-26	approved	10b934e7-80e6-41d0-9140-f56d92d614ae	\N	ea91029b-4ab3-4200-9037-ed244458ee85	2026-07-21 18:09:05.468077+00	2026-07-21 18:09:05.468077+00
2f01124a-87cc-42c0-aff1-ff0045070c4d	01b9d1f3-e89c-4b26-8c50-d99280df3e1a	1c04dd92-4377-490c-934c-38244ec68419	مستندسازی و نهایی‌سازی	68	30	2026-06-22	submitted	\N	\N	eb3bef90-582c-4028-8cc1-eb5866e2d431	2026-07-21 18:09:05.468077+00	2026-07-21 18:09:05.468077+00
2f01124a-87cc-42c0-aff1-ff0045070c4d	01b9d1f3-e89c-4b26-8c50-d99280df3e1a	1c04dd92-4377-490c-934c-38244ec68419	پیاده‌سازی بخش اصلی	119	58	2026-06-23	approved	10b934e7-80e6-41d0-9140-f56d92d614ae	\N	99072191-0c2a-4234-802d-2c3129e84464	2026-07-21 18:09:05.468077+00	2026-07-21 18:09:05.468077+00
2f01124a-87cc-42c0-aff1-ff0045070c4d	01b9d1f3-e89c-4b26-8c50-d99280df3e1a	1c04dd92-4377-490c-934c-38244ec68419	پیشرفت اولیه و بررسی نیازمندی‌ها	109	100	2026-06-30	approved	10b934e7-80e6-41d0-9140-f56d92d614ae	\N	22f4949e-7aa0-4388-926b-cf2a7517f48b	2026-07-21 18:09:05.468077+00	2026-07-21 18:09:05.468077+00
2f01124a-87cc-42c0-aff1-ff0045070c4d	4e327e4d-1d33-480d-8dab-b356820fcf19	0aa2e3a9-85b6-420a-aeeb-62f6f7061c6c	مستندسازی و نهایی‌سازی	53	40	2026-07-16	submitted	\N	\N	84ed2009-201f-4a11-8ff4-432cd65ffcc7	2026-07-21 18:09:05.468077+00	2026-07-21 18:09:05.468077+00
2f01124a-87cc-42c0-aff1-ff0045070c4d	4e327e4d-1d33-480d-8dab-b356820fcf19	0aa2e3a9-85b6-420a-aeeb-62f6f7061c6c	پیشرفت اولیه و بررسی نیازمندی‌ها	122	58	2026-07-16	approved	10b934e7-80e6-41d0-9140-f56d92d614ae	\N	8c8f30c6-addc-4828-8d38-d8d4e9539842	2026-07-21 18:09:05.468077+00	2026-07-21 18:09:05.468077+00
2f01124a-87cc-42c0-aff1-ff0045070c4d	4e327e4d-1d33-480d-8dab-b356820fcf19	0aa2e3a9-85b6-420a-aeeb-62f6f7061c6c	رفع اشکالات و بازبینی	226	100	2026-07-16	submitted	\N	\N	3d01e224-f79e-4a22-aed3-8eb1dc3bab45	2026-07-21 18:09:05.468077+00	2026-07-21 18:09:05.468077+00
2f01124a-87cc-42c0-aff1-ff0045070c4d	4e327e4d-1d33-480d-8dab-b356820fcf19	0aa2e3a9-85b6-420a-aeeb-62f6f7061c6c	پیاده‌سازی بخش اصلی	69	88	2026-07-16	approved	10b934e7-80e6-41d0-9140-f56d92d614ae	\N	62fa6575-7992-4cca-bf79-f638ddb757c5	2026-07-21 18:09:05.468077+00	2026-07-21 18:09:05.468077+00
2f01124a-87cc-42c0-aff1-ff0045070c4d	fc7d58af-f533-41f4-ace9-0ba24c01efa2	dfe22c83-6863-413d-97b7-1eb9b52dec02	مستندسازی و نهایی‌سازی	227	37	2026-07-05	approved	10b934e7-80e6-41d0-9140-f56d92d614ae	\N	b8b55903-ea85-4e6f-ad7f-f49929654ccb	2026-07-21 18:09:05.468077+00	2026-07-21 18:09:05.468077+00
2f01124a-87cc-42c0-aff1-ff0045070c4d	fc7d58af-f533-41f4-ace9-0ba24c01efa2	dfe22c83-6863-413d-97b7-1eb9b52dec02	رفع اشکالات و بازبینی	226	78	2026-07-06	approved	10b934e7-80e6-41d0-9140-f56d92d614ae	\N	b273c191-5662-4d99-93a9-66eee1479a51	2026-07-21 18:09:05.468077+00	2026-07-21 18:09:05.468077+00
2f01124a-87cc-42c0-aff1-ff0045070c4d	fc7d58af-f533-41f4-ace9-0ba24c01efa2	dfe22c83-6863-413d-97b7-1eb9b52dec02	مستندسازی و نهایی‌سازی	126	72	2026-07-09	approved	10b934e7-80e6-41d0-9140-f56d92d614ae	\N	280ae173-c0ab-4eb3-b994-9f97c72e668e	2026-07-21 18:09:05.468077+00	2026-07-21 18:09:05.468077+00
2f01124a-87cc-42c0-aff1-ff0045070c4d	9bf2689a-04a6-4c3f-a2ae-e0f2ef5be038	4e4c6e76-84d5-464d-957c-75ff3e9a2f8a	مستندسازی و نهایی‌سازی	237	25	2026-07-09	approved	10b934e7-80e6-41d0-9140-f56d92d614ae	\N	105aa41d-3b17-4348-a54b-e3193abfda6a	2026-07-21 18:09:05.468077+00	2026-07-21 18:09:05.468077+00
2f01124a-87cc-42c0-aff1-ff0045070c4d	9bf2689a-04a6-4c3f-a2ae-e0f2ef5be038	4e4c6e76-84d5-464d-957c-75ff3e9a2f8a	پیشرفت اولیه و بررسی نیازمندی‌ها	135	62	2026-07-13	approved	10b934e7-80e6-41d0-9140-f56d92d614ae	\N	f2cac544-6306-4d27-a516-cd7d143d14dd	2026-07-21 18:09:05.468077+00	2026-07-21 18:09:05.468077+00
2f01124a-87cc-42c0-aff1-ff0045070c4d	4a717f05-6fd5-4958-9dec-48c65b302420	f7d585ca-9137-4691-8979-1d8553a71ed8	تست و اطمینان از عملکرد صحیح	89	37	2026-07-16	approved	10b934e7-80e6-41d0-9140-f56d92d614ae	\N	7be38e72-5b9a-49e0-85b8-caaf3f0cf4bd	2026-07-21 18:09:05.468077+00	2026-07-21 18:09:05.468077+00
2f01124a-87cc-42c0-aff1-ff0045070c4d	4a717f05-6fd5-4958-9dec-48c65b302420	f7d585ca-9137-4691-8979-1d8553a71ed8	تست و اطمینان از عملکرد صحیح	79	62	2026-07-16	approved	10b934e7-80e6-41d0-9140-f56d92d614ae	\N	59625e60-8fbc-49a1-87ff-71d2029c6667	2026-07-21 18:09:05.468077+00	2026-07-21 18:09:05.468077+00
2f01124a-87cc-42c0-aff1-ff0045070c4d	6fe76512-cf7b-44bb-9fbd-089883e18058	f7d585ca-9137-4691-8979-1d8553a71ed8	رفع اشکالات و بازبینی	229	32	2026-07-13	approved	10b934e7-80e6-41d0-9140-f56d92d614ae	\N	b053d855-52bc-4d7e-9af6-3882d340b443	2026-07-21 18:09:05.468077+00	2026-07-21 18:09:05.468077+00
2f01124a-87cc-42c0-aff1-ff0045070c4d	6fe76512-cf7b-44bb-9fbd-089883e18058	f7d585ca-9137-4691-8979-1d8553a71ed8	پیاده‌سازی بخش اصلی	239	52	2026-07-16	approved	10b934e7-80e6-41d0-9140-f56d92d614ae	\N	e0e82e66-93eb-405f-aad4-d051cacc994e	2026-07-21 18:09:05.468077+00	2026-07-21 18:09:05.468077+00
2f01124a-87cc-42c0-aff1-ff0045070c4d	6fe76512-cf7b-44bb-9fbd-089883e18058	f7d585ca-9137-4691-8979-1d8553a71ed8	رفع اشکالات و بازبینی	43	100	2026-07-16	approved	10b934e7-80e6-41d0-9140-f56d92d614ae	\N	40a60dc3-4bf3-4f08-8ec5-29b00d9e4039	2026-07-21 18:09:05.468077+00	2026-07-21 18:09:05.468077+00
2f01124a-87cc-42c0-aff1-ff0045070c4d	6fe76512-cf7b-44bb-9fbd-089883e18058	f7d585ca-9137-4691-8979-1d8553a71ed8	رفع اشکالات و بازبینی	171	92	2026-07-16	approved	10b934e7-80e6-41d0-9140-f56d92d614ae	\N	d9072578-6b07-4a6b-b09c-6d12d218f2cb	2026-07-21 18:09:05.468077+00	2026-07-21 18:09:05.468077+00
2f01124a-87cc-42c0-aff1-ff0045070c4d	e93a19b6-dcfe-4cf0-a02a-2ba60b02245e	4e4c6e76-84d5-464d-957c-75ff3e9a2f8a	پیشرفت اولیه و بررسی نیازمندی‌ها	225	25	2026-07-16	approved	10b934e7-80e6-41d0-9140-f56d92d614ae	\N	fe86f2fa-ab79-49f7-ae7b-2a06f42ae106	2026-07-21 18:09:05.468077+00	2026-07-21 18:09:05.468077+00
2f01124a-87cc-42c0-aff1-ff0045070c4d	c2788d8c-9e4b-413a-952f-807d0cb84e36	de5c1d0c-3ca8-4c75-8525-abcfac9d0651	پیاده‌سازی بخش اصلی	141	22	2026-07-06	submitted	\N	\N	c0bf4bb2-eb26-41da-9edb-5f2491b4354b	2026-07-21 18:09:05.468077+00	2026-07-21 18:09:05.468077+00
2f01124a-87cc-42c0-aff1-ff0045070c4d	c2788d8c-9e4b-413a-952f-807d0cb84e36	de5c1d0c-3ca8-4c75-8525-abcfac9d0651	رفع اشکالات و بازبینی	36	66	2026-07-08	submitted	\N	\N	d40b07a9-079c-4194-be84-5d5943276581	2026-07-21 18:09:05.468077+00	2026-07-21 18:09:05.468077+00
2f01124a-87cc-42c0-aff1-ff0045070c4d	c2788d8c-9e4b-413a-952f-807d0cb84e36	de5c1d0c-3ca8-4c75-8525-abcfac9d0651	رفع اشکالات و بازبینی	90	96	2026-07-08	approved	10b934e7-80e6-41d0-9140-f56d92d614ae	\N	78bfcbef-a4a5-43a1-8fef-d68a721c1acd	2026-07-21 18:09:05.468077+00	2026-07-21 18:09:05.468077+00
2f01124a-87cc-42c0-aff1-ff0045070c4d	6ff1b4b7-e479-4bde-9c37-0c3f7275fe7e	1c04dd92-4377-490c-934c-38244ec68419	پیاده‌سازی بخش اصلی	37	30	2026-07-15	approved	10b934e7-80e6-41d0-9140-f56d92d614ae	\N	75ca7d12-99e2-4239-b388-8f73d027abe7	2026-07-21 18:09:05.468077+00	2026-07-21 18:09:05.468077+00
2f01124a-87cc-42c0-aff1-ff0045070c4d	57ff3f0b-8465-446c-aa62-eb1cbe85292d	0aa2e3a9-85b6-420a-aeeb-62f6f7061c6c	پیاده‌سازی بخش اصلی	39	29	2026-06-27	submitted	\N	\N	495bfff6-66b5-4ed3-802c-79358c07fa6c	2026-07-21 18:09:05.468077+00	2026-07-21 18:09:05.468077+00
2f01124a-87cc-42c0-aff1-ff0045070c4d	f3020bec-d78b-41ff-a98a-7a165b65732f	de5c1d0c-3ca8-4c75-8525-abcfac9d0651	تست و اطمینان از عملکرد صحیح	144	39	2026-07-16	approved	10b934e7-80e6-41d0-9140-f56d92d614ae	\N	3ae1e1a5-00d3-4387-b5ba-75d5367cd25b	2026-07-21 18:09:05.468077+00	2026-07-21 18:09:05.468077+00
2f01124a-87cc-42c0-aff1-ff0045070c4d	f3020bec-d78b-41ff-a98a-7a165b65732f	de5c1d0c-3ca8-4c75-8525-abcfac9d0651	پیشرفت اولیه و بررسی نیازمندی‌ها	34	56	2026-07-16	approved	10b934e7-80e6-41d0-9140-f56d92d614ae	\N	0150e4ee-6fd3-429c-a618-1d0b9ceb128c	2026-07-21 18:09:05.468077+00	2026-07-21 18:09:05.468077+00
2f01124a-87cc-42c0-aff1-ff0045070c4d	f3020bec-d78b-41ff-a98a-7a165b65732f	de5c1d0c-3ca8-4c75-8525-abcfac9d0651	پیاده‌سازی بخش اصلی	170	100	2026-07-16	approved	10b934e7-80e6-41d0-9140-f56d92d614ae	\N	97269183-9a09-490a-aeea-b22a36d8d29f	2026-07-21 18:09:05.468077+00	2026-07-21 18:09:05.468077+00
2f01124a-87cc-42c0-aff1-ff0045070c4d	f3020bec-d78b-41ff-a98a-7a165b65732f	de5c1d0c-3ca8-4c75-8525-abcfac9d0651	پیشرفت اولیه و بررسی نیازمندی‌ها	228	100	2026-07-16	approved	10b934e7-80e6-41d0-9140-f56d92d614ae	\N	780c1775-492a-4b97-a6ad-1b03992387ad	2026-07-21 18:09:05.468077+00	2026-07-21 18:09:05.468077+00
2f01124a-87cc-42c0-aff1-ff0045070c4d	6fe89ba9-de96-44ba-87e6-c8072e8f45eb	dfe22c83-6863-413d-97b7-1eb9b52dec02	پیاده‌سازی بخش اصلی	137	40	2026-07-16	approved	10b934e7-80e6-41d0-9140-f56d92d614ae	\N	2d7b177f-66f4-41ce-9a9c-519041b555fb	2026-07-21 18:09:05.468077+00	2026-07-21 18:09:05.468077+00
2f01124a-87cc-42c0-aff1-ff0045070c4d	6fe89ba9-de96-44ba-87e6-c8072e8f45eb	dfe22c83-6863-413d-97b7-1eb9b52dec02	تست و اطمینان از عملکرد صحیح	182	74	2026-07-16	approved	10b934e7-80e6-41d0-9140-f56d92d614ae	\N	00187e10-d4b0-4051-9bf4-e85318652e5e	2026-07-21 18:09:05.468077+00	2026-07-21 18:09:05.468077+00
2f01124a-87cc-42c0-aff1-ff0045070c4d	89916d94-d3b7-40a9-bd7d-1248f10b137c	0aa2e3a9-85b6-420a-aeeb-62f6f7061c6c	پیاده‌سازی بخش اصلی	104	33	2026-06-21	approved	10b934e7-80e6-41d0-9140-f56d92d614ae	\N	99c7cdc2-f4a4-404b-a6b1-6c1ba7bdf247	2026-07-21 18:09:05.468077+00	2026-07-21 18:09:05.468077+00
2f01124a-87cc-42c0-aff1-ff0045070c4d	ab564e1f-f9ae-421c-9777-6567a0a58495	02b5f471-cd3d-47ff-85ad-d22286b9e4b1	مستندسازی و نهایی‌سازی	196	31	2026-06-27	approved	42df4646-393a-4de3-83d6-df4785b690c6	\N	26a660d7-acf2-4b9f-b146-30bfc3670a8a	2026-07-21 18:09:05.468077+00	2026-07-21 18:09:05.468077+00
2f01124a-87cc-42c0-aff1-ff0045070c4d	ab564e1f-f9ae-421c-9777-6567a0a58495	02b5f471-cd3d-47ff-85ad-d22286b9e4b1	رفع اشکالات و بازبینی	122	72	2026-06-30	approved	42df4646-393a-4de3-83d6-df4785b690c6	\N	d0ed67a4-a09b-4b37-a2c8-6e7101bcccc9	2026-07-21 18:09:05.468077+00	2026-07-21 18:09:05.468077+00
2f01124a-87cc-42c0-aff1-ff0045070c4d	ab564e1f-f9ae-421c-9777-6567a0a58495	02b5f471-cd3d-47ff-85ad-d22286b9e4b1	تست و اطمینان از عملکرد صحیح	55	100	2026-07-05	approved	42df4646-393a-4de3-83d6-df4785b690c6	\N	a28ba6aa-94f8-40a0-ae4c-ec2e34c5cfe2	2026-07-21 18:09:05.468077+00	2026-07-21 18:09:05.468077+00
2f01124a-87cc-42c0-aff1-ff0045070c4d	ab564e1f-f9ae-421c-9777-6567a0a58495	02b5f471-cd3d-47ff-85ad-d22286b9e4b1	پیاده‌سازی بخش اصلی	124	100	2026-07-06	approved	42df4646-393a-4de3-83d6-df4785b690c6	\N	c8849c6c-d558-42f8-97ad-c05e9f5022dd	2026-07-21 18:09:05.468077+00	2026-07-21 18:09:05.468077+00
2f01124a-87cc-42c0-aff1-ff0045070c4d	8fca2c8d-e245-49dc-b0c1-02401f625b0a	2d6d452d-4915-4793-bf0b-ad7d43798e6f	مستندسازی و نهایی‌سازی	86	24	2026-07-14	approved	42df4646-393a-4de3-83d6-df4785b690c6	\N	6f392480-903b-4ddd-9c41-1a749ed7ef52	2026-07-21 18:09:05.468077+00	2026-07-21 18:09:05.468077+00
2f01124a-87cc-42c0-aff1-ff0045070c4d	8fca2c8d-e245-49dc-b0c1-02401f625b0a	2d6d452d-4915-4793-bf0b-ad7d43798e6f	رفع اشکالات و بازبینی	171	76	2026-07-15	approved	42df4646-393a-4de3-83d6-df4785b690c6	\N	e4458b67-c857-41ac-93a0-8453e1330b43	2026-07-21 18:09:05.468077+00	2026-07-21 18:09:05.468077+00
2f01124a-87cc-42c0-aff1-ff0045070c4d	8fca2c8d-e245-49dc-b0c1-02401f625b0a	2d6d452d-4915-4793-bf0b-ad7d43798e6f	رفع اشکالات و بازبینی	69	78	2026-07-16	approved	42df4646-393a-4de3-83d6-df4785b690c6	\N	2b9f2985-2876-4250-8ec5-ab963881799a	2026-07-21 18:09:05.468077+00	2026-07-21 18:09:05.468077+00
2f01124a-87cc-42c0-aff1-ff0045070c4d	8fca2c8d-e245-49dc-b0c1-02401f625b0a	2d6d452d-4915-4793-bf0b-ad7d43798e6f	پیاده‌سازی بخش اصلی	127	100	2026-07-16	approved	42df4646-393a-4de3-83d6-df4785b690c6	\N	5ae46b17-277a-4bb5-84ee-ec6d949152bc	2026-07-21 18:09:05.468077+00	2026-07-21 18:09:05.468077+00
2f01124a-87cc-42c0-aff1-ff0045070c4d	a0b70e37-acbc-4662-b47f-bd934043a210	02b5f471-cd3d-47ff-85ad-d22286b9e4b1	رفع اشکالات و بازبینی	95	35	2026-07-14	approved	42df4646-393a-4de3-83d6-df4785b690c6	\N	0a5bce29-20f9-4144-8237-ebde857521df	2026-07-21 18:09:05.468077+00	2026-07-21 18:09:05.468077+00
2f01124a-87cc-42c0-aff1-ff0045070c4d	a0b70e37-acbc-4662-b47f-bd934043a210	02b5f471-cd3d-47ff-85ad-d22286b9e4b1	رفع اشکالات و بازبینی	73	48	2026-07-16	approved	42df4646-393a-4de3-83d6-df4785b690c6	\N	db4651e2-1c85-4b96-b924-d81f162f4b5c	2026-07-21 18:09:05.468077+00	2026-07-21 18:09:05.468077+00
2f01124a-87cc-42c0-aff1-ff0045070c4d	dd433bd6-1f28-4c06-b11f-3a39f86f83b6	2d6d452d-4915-4793-bf0b-ad7d43798e6f	مستندسازی و نهایی‌سازی	194	21	2026-07-16	approved	42df4646-393a-4de3-83d6-df4785b690c6	\N	c220380d-db3b-4dec-8370-15aaaf3b189a	2026-07-21 18:09:05.468077+00	2026-07-21 18:09:05.468077+00
2f01124a-87cc-42c0-aff1-ff0045070c4d	dd433bd6-1f28-4c06-b11f-3a39f86f83b6	2d6d452d-4915-4793-bf0b-ad7d43798e6f	پیشرفت اولیه و بررسی نیازمندی‌ها	239	42	2026-07-16	approved	42df4646-393a-4de3-83d6-df4785b690c6	\N	12a35d2b-b9b5-4c5b-8e96-c6e7c23357d9	2026-07-21 18:09:05.468077+00	2026-07-21 18:09:05.468077+00
2f01124a-87cc-42c0-aff1-ff0045070c4d	dd433bd6-1f28-4c06-b11f-3a39f86f83b6	2d6d452d-4915-4793-bf0b-ad7d43798e6f	تست و اطمینان از عملکرد صحیح	65	100	2026-07-16	approved	42df4646-393a-4de3-83d6-df4785b690c6	\N	6c9204d3-b58a-4920-8070-be816971633b	2026-07-21 18:09:05.468077+00	2026-07-21 18:09:05.468077+00
2f01124a-87cc-42c0-aff1-ff0045070c4d	dd433bd6-1f28-4c06-b11f-3a39f86f83b6	2d6d452d-4915-4793-bf0b-ad7d43798e6f	پیشرفت اولیه و بررسی نیازمندی‌ها	211	96	2026-07-16	approved	42df4646-393a-4de3-83d6-df4785b690c6	\N	92eac5e4-45bf-457a-b4d3-6eb2c59aac17	2026-07-21 18:09:05.468077+00	2026-07-21 18:09:05.468077+00
2f01124a-87cc-42c0-aff1-ff0045070c4d	2afccc25-b9c3-463f-8103-3684c9e61a41	2d6d452d-4915-4793-bf0b-ad7d43798e6f	مستندسازی و نهایی‌سازی	146	31	2026-07-16	approved	42df4646-393a-4de3-83d6-df4785b690c6	\N	28c398af-d6ee-403a-9741-a2b8e71325a1	2026-07-21 18:09:05.468077+00	2026-07-21 18:09:05.468077+00
2f01124a-87cc-42c0-aff1-ff0045070c4d	4c63b0bd-f470-448f-8586-db7e6f796d76	72cdbbe8-b0fe-43f0-ab1a-f11f02a63e1f	تست و اطمینان از عملکرد صحیح	34	20	2026-06-20	approved	42df4646-393a-4de3-83d6-df4785b690c6	\N	6487cd77-9586-449a-b800-b6eed2f9ab6b	2026-07-21 18:09:05.468077+00	2026-07-21 18:09:05.468077+00
2f01124a-87cc-42c0-aff1-ff0045070c4d	c18378d6-9771-4ff6-bdbb-85a4e9f55c2d	02b5f471-cd3d-47ff-85ad-d22286b9e4b1	پیشرفت اولیه و بررسی نیازمندی‌ها	165	28	2026-06-25	approved	42df4646-393a-4de3-83d6-df4785b690c6	\N	bb48b91c-5619-457a-9b09-c99051136183	2026-07-21 18:09:05.468077+00	2026-07-21 18:09:05.468077+00
2f01124a-87cc-42c0-aff1-ff0045070c4d	c18378d6-9771-4ff6-bdbb-85a4e9f55c2d	02b5f471-cd3d-47ff-85ad-d22286b9e4b1	پیشرفت اولیه و بررسی نیازمندی‌ها	158	66	2026-06-28	approved	42df4646-393a-4de3-83d6-df4785b690c6	\N	73140dd8-7843-4633-b90d-7481e914e8db	2026-07-21 18:09:05.468077+00	2026-07-21 18:09:05.468077+00
2f01124a-87cc-42c0-aff1-ff0045070c4d	c18378d6-9771-4ff6-bdbb-85a4e9f55c2d	02b5f471-cd3d-47ff-85ad-d22286b9e4b1	پیشرفت اولیه و بررسی نیازمندی‌ها	54	100	2026-06-29	approved	42df4646-393a-4de3-83d6-df4785b690c6	\N	b1401655-b480-46b7-87a5-5873c2bc171b	2026-07-21 18:09:05.468077+00	2026-07-21 18:09:05.468077+00
2f01124a-87cc-42c0-aff1-ff0045070c4d	c18378d6-9771-4ff6-bdbb-85a4e9f55c2d	02b5f471-cd3d-47ff-85ad-d22286b9e4b1	پیاده‌سازی بخش اصلی	79	100	2026-07-01	approved	42df4646-393a-4de3-83d6-df4785b690c6	\N	06ad90e1-5e33-4320-aac5-a09a720897fc	2026-07-21 18:09:05.468077+00	2026-07-21 18:09:05.468077+00
2f01124a-87cc-42c0-aff1-ff0045070c4d	248e4d32-9962-4bb7-acee-d37cc3ca4368	42df4646-393a-4de3-83d6-df4785b690c6	رفع اشکالات و بازبینی	233	32	2026-07-09	approved	42df4646-393a-4de3-83d6-df4785b690c6	\N	079ddf65-2b6e-4b3a-a129-a3df1f00e8df	2026-07-21 18:09:05.468077+00	2026-07-21 18:09:05.468077+00
2f01124a-87cc-42c0-aff1-ff0045070c4d	248e4d32-9962-4bb7-acee-d37cc3ca4368	42df4646-393a-4de3-83d6-df4785b690c6	رفع اشکالات و بازبینی	133	68	2026-07-10	approved	42df4646-393a-4de3-83d6-df4785b690c6	\N	02829094-4f9d-48fc-a947-61251647b1e3	2026-07-21 18:09:05.468077+00	2026-07-21 18:09:05.468077+00
2f01124a-87cc-42c0-aff1-ff0045070c4d	248e4d32-9962-4bb7-acee-d37cc3ca4368	42df4646-393a-4de3-83d6-df4785b690c6	پیاده‌سازی بخش اصلی	106	66	2026-07-13	approved	42df4646-393a-4de3-83d6-df4785b690c6	\N	32c12a14-8841-402b-ba55-492f1d9948eb	2026-07-21 18:09:05.468077+00	2026-07-21 18:09:05.468077+00
2f01124a-87cc-42c0-aff1-ff0045070c4d	b5e7c1ec-7809-49d8-a6ae-32bcf02c3ef5	42df4646-393a-4de3-83d6-df4785b690c6	تست و اطمینان از عملکرد صحیح	171	35	2026-07-16	approved	42df4646-393a-4de3-83d6-df4785b690c6	\N	1a54511d-45b9-4c0b-af5f-92fdcf8f4907	2026-07-21 18:09:05.468077+00	2026-07-21 18:09:05.468077+00
2f01124a-87cc-42c0-aff1-ff0045070c4d	e560f767-0748-4748-9314-05221d1d4bed	2d6d452d-4915-4793-bf0b-ad7d43798e6f	پیاده‌سازی بخش اصلی	51	35	2026-07-16	approved	42df4646-393a-4de3-83d6-df4785b690c6	\N	e9bc9e25-c9f6-4e64-9c0b-ea8d92992cdb	2026-07-21 18:09:05.468077+00	2026-07-21 18:09:05.468077+00
2f01124a-87cc-42c0-aff1-ff0045070c4d	6b51ff8d-d8d3-479a-a8b8-fa8bff1a8433	72cdbbe8-b0fe-43f0-ab1a-f11f02a63e1f	مستندسازی و نهایی‌سازی	54	36	2026-07-09	approved	42df4646-393a-4de3-83d6-df4785b690c6	\N	14dcb2d1-8c4d-4340-a0ab-028cd92fe242	2026-07-21 18:09:05.468077+00	2026-07-21 18:09:05.468077+00
2f01124a-87cc-42c0-aff1-ff0045070c4d	6b51ff8d-d8d3-479a-a8b8-fa8bff1a8433	72cdbbe8-b0fe-43f0-ab1a-f11f02a63e1f	پیاده‌سازی بخش اصلی	84	76	2026-07-10	approved	42df4646-393a-4de3-83d6-df4785b690c6	\N	6bc29e97-b2ae-4467-a345-e521eed94045	2026-07-21 18:09:05.468077+00	2026-07-21 18:09:05.468077+00
2f01124a-87cc-42c0-aff1-ff0045070c4d	6b51ff8d-d8d3-479a-a8b8-fa8bff1a8433	72cdbbe8-b0fe-43f0-ab1a-f11f02a63e1f	رفع اشکالات و بازبینی	41	66	2026-07-16	approved	42df4646-393a-4de3-83d6-df4785b690c6	\N	b02d93f8-3101-4568-b7a8-d642fdeb0ea4	2026-07-21 18:09:05.468077+00	2026-07-21 18:09:05.468077+00
2f01124a-87cc-42c0-aff1-ff0045070c4d	6b51ff8d-d8d3-479a-a8b8-fa8bff1a8433	72cdbbe8-b0fe-43f0-ab1a-f11f02a63e1f	مستندسازی و نهایی‌سازی	174	84	2026-07-16	approved	42df4646-393a-4de3-83d6-df4785b690c6	\N	40d4ae25-ee93-4ee7-a81e-227f86178f8d	2026-07-21 18:09:05.468077+00	2026-07-21 18:09:05.468077+00
2f01124a-87cc-42c0-aff1-ff0045070c4d	b9444eca-b3d9-4a3b-9322-7db9d1c5815f	02b5f471-cd3d-47ff-85ad-d22286b9e4b1	پیشرفت اولیه و بررسی نیازمندی‌ها	83	38	2026-07-16	approved	42df4646-393a-4de3-83d6-df4785b690c6	\N	ef616199-c745-479c-868a-1ba806c737b1	2026-07-21 18:09:05.468077+00	2026-07-21 18:09:05.468077+00
2f01124a-87cc-42c0-aff1-ff0045070c4d	b9444eca-b3d9-4a3b-9322-7db9d1c5815f	02b5f471-cd3d-47ff-85ad-d22286b9e4b1	تست و اطمینان از عملکرد صحیح	49	58	2026-07-16	approved	42df4646-393a-4de3-83d6-df4785b690c6	\N	950b10c0-e044-484a-9ebf-e2cfbec31563	2026-07-21 18:09:05.468077+00	2026-07-21 18:09:05.468077+00
2f01124a-87cc-42c0-aff1-ff0045070c4d	ed30d0c0-eb62-486b-a9f4-456b52be9336	72cdbbe8-b0fe-43f0-ab1a-f11f02a63e1f	مستندسازی و نهایی‌سازی	129	37	2026-07-16	approved	42df4646-393a-4de3-83d6-df4785b690c6	\N	bd50950d-3658-494d-be87-04f7204634be	2026-07-21 18:09:05.468077+00	2026-07-21 18:09:05.468077+00
2f01124a-87cc-42c0-aff1-ff0045070c4d	ed30d0c0-eb62-486b-a9f4-456b52be9336	72cdbbe8-b0fe-43f0-ab1a-f11f02a63e1f	تست و اطمینان از عملکرد صحیح	223	48	2026-07-16	approved	42df4646-393a-4de3-83d6-df4785b690c6	\N	ceb8ea2f-4990-4055-b830-c7ba6aa0a6a3	2026-07-21 18:09:05.468077+00	2026-07-21 18:09:05.468077+00
2f01124a-87cc-42c0-aff1-ff0045070c4d	f342a9f5-f41f-4e5c-97bf-67131b8cca72	2d6d452d-4915-4793-bf0b-ad7d43798e6f	پیشرفت اولیه و بررسی نیازمندی‌ها	55	33	2026-07-15	approved	42df4646-393a-4de3-83d6-df4785b690c6	\N	1a913362-dc2e-4efb-b235-3bc22f9bc31b	2026-07-21 18:09:05.468077+00	2026-07-21 18:09:05.468077+00
2f01124a-87cc-42c0-aff1-ff0045070c4d	5c507580-510d-4065-9754-ccb3e786917e	b4d6dda1-b07b-48aa-b440-b2cbfe40ac0f	رفع اشکالات و بازبینی	184	39	2026-06-27	approved	42df4646-393a-4de3-83d6-df4785b690c6	\N	0aae6829-8e44-4f6a-a9b4-f2a4cf1bacde	2026-07-21 18:09:05.468077+00	2026-07-21 18:09:05.468077+00
2f01124a-87cc-42c0-aff1-ff0045070c4d	5c507580-510d-4065-9754-ccb3e786917e	b4d6dda1-b07b-48aa-b440-b2cbfe40ac0f	رفع اشکالات و بازبینی	37	80	2026-07-01	approved	42df4646-393a-4de3-83d6-df4785b690c6	\N	c7d1d109-77e0-41cf-ae94-c5ced39fea83	2026-07-21 18:09:05.468077+00	2026-07-21 18:09:05.468077+00
2f01124a-87cc-42c0-aff1-ff0045070c4d	757f40c0-63c7-49ee-b8b0-8b777a7e3638	72cdbbe8-b0fe-43f0-ab1a-f11f02a63e1f	رفع اشکالات و بازبینی	171	32	2026-07-08	approved	42df4646-393a-4de3-83d6-df4785b690c6	\N	c3311954-695e-49d3-adae-856dca922dc0	2026-07-21 18:09:05.468077+00	2026-07-21 18:09:05.468077+00
2f01124a-87cc-42c0-aff1-ff0045070c4d	757f40c0-63c7-49ee-b8b0-8b777a7e3638	72cdbbe8-b0fe-43f0-ab1a-f11f02a63e1f	مستندسازی و نهایی‌سازی	199	64	2026-07-12	approved	42df4646-393a-4de3-83d6-df4785b690c6	\N	21c8556f-f157-47b9-aaa5-e31e599f8ca2	2026-07-21 18:09:05.468077+00	2026-07-21 18:09:05.468077+00
2f01124a-87cc-42c0-aff1-ff0045070c4d	757f40c0-63c7-49ee-b8b0-8b777a7e3638	72cdbbe8-b0fe-43f0-ab1a-f11f02a63e1f	رفع اشکالات و بازبینی	234	81	2026-07-10	submitted	\N	\N	946e4a7a-579e-4193-8e6a-b17ef41be962	2026-07-21 18:09:05.468077+00	2026-07-21 18:09:05.468077+00
2f01124a-87cc-42c0-aff1-ff0045070c4d	6d410ac1-7c0d-4746-a8a0-f9dbb9d19b36	72cdbbe8-b0fe-43f0-ab1a-f11f02a63e1f	رفع اشکالات و بازبینی	69	32	2026-07-16	approved	42df4646-393a-4de3-83d6-df4785b690c6	\N	8a569a5e-2790-49b8-8e8b-277274123517	2026-07-21 18:09:05.468077+00	2026-07-21 18:09:05.468077+00
2f01124a-87cc-42c0-aff1-ff0045070c4d	7d1890fa-0a12-4aff-ae71-47ac05ecefce	3683aa32-1561-4f36-90bf-d6402b4a66d8	پیشرفت اولیه و بررسی نیازمندی‌ها	53	20	2026-07-16	approved	42df4646-393a-4de3-83d6-df4785b690c6	\N	7b0ce9da-5322-4ade-8ef1-c84e22f54670	2026-07-21 18:09:05.468077+00	2026-07-21 18:09:05.468077+00
2f01124a-87cc-42c0-aff1-ff0045070c4d	7d1890fa-0a12-4aff-ae71-47ac05ecefce	3683aa32-1561-4f36-90bf-d6402b4a66d8	رفع اشکالات و بازبینی	56	48	2026-07-16	approved	42df4646-393a-4de3-83d6-df4785b690c6	\N	09fccedf-451d-40a9-97d4-8340c4765173	2026-07-21 18:09:05.468077+00	2026-07-21 18:09:05.468077+00
2f01124a-87cc-42c0-aff1-ff0045070c4d	4a9be453-a818-4c92-b1ac-6c8a2cdf34ef	72cdbbe8-b0fe-43f0-ab1a-f11f02a63e1f	تست و اطمینان از عملکرد صحیح	144	37	2026-07-16	approved	42df4646-393a-4de3-83d6-df4785b690c6	\N	16bdf65d-0f61-4484-b823-afaf9580a58e	2026-07-21 18:09:05.468077+00	2026-07-21 18:09:05.468077+00
2f01124a-87cc-42c0-aff1-ff0045070c4d	1347e55f-6e7a-4935-b0e7-5728c05a7399	b4d6dda1-b07b-48aa-b440-b2cbfe40ac0f	پیشرفت اولیه و بررسی نیازمندی‌ها	52	31	2026-07-15	approved	42df4646-393a-4de3-83d6-df4785b690c6	\N	f68b0a0c-03f1-44eb-ba29-0c6305d1d700	2026-07-21 18:09:05.468077+00	2026-07-21 18:09:05.468077+00
2f01124a-87cc-42c0-aff1-ff0045070c4d	1347e55f-6e7a-4935-b0e7-5728c05a7399	b4d6dda1-b07b-48aa-b440-b2cbfe40ac0f	مستندسازی و نهایی‌سازی	183	60	2026-07-16	approved	42df4646-393a-4de3-83d6-df4785b690c6	\N	c149f1bb-53a5-43c4-8573-a92d9777333c	2026-07-21 18:09:05.468077+00	2026-07-21 18:09:05.468077+00
2f01124a-87cc-42c0-aff1-ff0045070c4d	1347e55f-6e7a-4935-b0e7-5728c05a7399	b4d6dda1-b07b-48aa-b440-b2cbfe40ac0f	پیشرفت اولیه و بررسی نیازمندی‌ها	104	99	2026-07-16	approved	42df4646-393a-4de3-83d6-df4785b690c6	\N	481c5e67-f222-4742-a4a2-052ab9bbb5cc	2026-07-21 18:09:05.468077+00	2026-07-21 18:09:05.468077+00
2f01124a-87cc-42c0-aff1-ff0045070c4d	1347e55f-6e7a-4935-b0e7-5728c05a7399	b4d6dda1-b07b-48aa-b440-b2cbfe40ac0f	پیشرفت اولیه و بررسی نیازمندی‌ها	215	100	2026-07-16	approved	42df4646-393a-4de3-83d6-df4785b690c6	\N	289b7bf5-dc1d-4e9b-8d75-20e2571802e5	2026-07-21 18:09:05.468077+00	2026-07-21 18:09:05.468077+00
2f01124a-87cc-42c0-aff1-ff0045070c4d	07be99db-33e1-435a-ab8b-8374a3a9b72c	02b5f471-cd3d-47ff-85ad-d22286b9e4b1	تست و اطمینان از عملکرد صحیح	73	24	2026-07-07	approved	42df4646-393a-4de3-83d6-df4785b690c6	\N	98fc47fe-b7eb-480c-b0d7-2c8a6f39d9bd	2026-07-21 18:09:05.468077+00	2026-07-21 18:09:05.468077+00
2f01124a-87cc-42c0-aff1-ff0045070c4d	07be99db-33e1-435a-ab8b-8374a3a9b72c	02b5f471-cd3d-47ff-85ad-d22286b9e4b1	رفع اشکالات و بازبینی	98	70	2026-07-10	approved	42df4646-393a-4de3-83d6-df4785b690c6	\N	1d884691-8e5a-43ac-9294-d4afc7434a21	2026-07-21 18:09:05.468077+00	2026-07-21 18:09:05.468077+00
2f01124a-87cc-42c0-aff1-ff0045070c4d	fc3e9424-6f73-409b-a89e-e772d5a0be16	2d6d452d-4915-4793-bf0b-ad7d43798e6f	پیاده‌سازی بخش اصلی	141	28	2026-07-16	approved	42df4646-393a-4de3-83d6-df4785b690c6	\N	bd5c9a7c-c6df-418a-9fb9-e772960a0b91	2026-07-21 18:09:05.468077+00	2026-07-21 18:09:05.468077+00
2f01124a-87cc-42c0-aff1-ff0045070c4d	fc3e9424-6f73-409b-a89e-e772d5a0be16	2d6d452d-4915-4793-bf0b-ad7d43798e6f	رفع اشکالات و بازبینی	153	44	2026-07-16	approved	42df4646-393a-4de3-83d6-df4785b690c6	\N	0e7118f0-92f8-4335-af34-5dae2778e239	2026-07-21 18:09:05.468077+00	2026-07-21 18:09:05.468077+00
2f01124a-87cc-42c0-aff1-ff0045070c4d	a1b9a996-02f6-4627-b576-1c87bf0906c1	42df4646-393a-4de3-83d6-df4785b690c6	تست و اطمینان از عملکرد صحیح	182	39	2026-07-01	submitted	\N	\N	adcf324e-a7be-4461-a36e-53aa372ef16d	2026-07-21 18:09:05.468077+00	2026-07-21 18:09:05.468077+00
2f01124a-87cc-42c0-aff1-ff0045070c4d	a1b9a996-02f6-4627-b576-1c87bf0906c1	42df4646-393a-4de3-83d6-df4785b690c6	پیاده‌سازی بخش اصلی	107	40	2026-07-03	approved	42df4646-393a-4de3-83d6-df4785b690c6	\N	d60f772a-380f-4f42-b908-dbd6a20cc5e7	2026-07-21 18:09:05.468077+00	2026-07-21 18:09:05.468077+00
2f01124a-87cc-42c0-aff1-ff0045070c4d	a1b9a996-02f6-4627-b576-1c87bf0906c1	42df4646-393a-4de3-83d6-df4785b690c6	مستندسازی و نهایی‌سازی	127	90	2026-07-09	approved	42df4646-393a-4de3-83d6-df4785b690c6	\N	899054d9-f65e-4474-b433-0150042e4baa	2026-07-21 18:09:05.468077+00	2026-07-21 18:09:05.468077+00
2f01124a-87cc-42c0-aff1-ff0045070c4d	92b6c40a-1608-4cbc-9c82-f03fb16032a5	92a3b31d-254e-440b-8bbe-d18db13d73cd	تست و اطمینان از عملکرد صحیح	238	40	2026-07-15	approved	42df4646-393a-4de3-83d6-df4785b690c6	\N	18849721-4f6e-47fd-981a-ac9a39db086b	2026-07-21 18:09:05.468077+00	2026-07-21 18:09:05.468077+00
2f01124a-87cc-42c0-aff1-ff0045070c4d	92b6c40a-1608-4cbc-9c82-f03fb16032a5	92a3b31d-254e-440b-8bbe-d18db13d73cd	رفع اشکالات و بازبینی	112	78	2026-07-16	approved	42df4646-393a-4de3-83d6-df4785b690c6	\N	37b34995-21d3-4648-acd7-c65480e6e401	2026-07-21 18:09:05.468077+00	2026-07-21 18:09:05.468077+00
2f01124a-87cc-42c0-aff1-ff0045070c4d	92b6c40a-1608-4cbc-9c82-f03fb16032a5	92a3b31d-254e-440b-8bbe-d18db13d73cd	تست و اطمینان از عملکرد صحیح	110	75	2026-07-16	approved	42df4646-393a-4de3-83d6-df4785b690c6	\N	bf726a7a-6c53-4abc-ac15-0c0c6fea4783	2026-07-21 18:09:05.468077+00	2026-07-21 18:09:05.468077+00
2f01124a-87cc-42c0-aff1-ff0045070c4d	92b6c40a-1608-4cbc-9c82-f03fb16032a5	92a3b31d-254e-440b-8bbe-d18db13d73cd	رفع اشکالات و بازبینی	104	100	2026-07-16	approved	42df4646-393a-4de3-83d6-df4785b690c6	\N	a730b108-ecf5-4192-adb3-f778773ced40	2026-07-21 18:09:05.468077+00	2026-07-21 18:09:05.468077+00
2f01124a-87cc-42c0-aff1-ff0045070c4d	3ed34084-dd2e-4e40-890b-43347bb82368	42df4646-393a-4de3-83d6-df4785b690c6	رفع اشکالات و بازبینی	239	32	2026-07-16	approved	42df4646-393a-4de3-83d6-df4785b690c6	\N	3661c2aa-2abb-4626-9e49-53d6c28d6498	2026-07-21 18:09:05.468077+00	2026-07-21 18:09:05.468077+00
2f01124a-87cc-42c0-aff1-ff0045070c4d	3ed34084-dd2e-4e40-890b-43347bb82368	42df4646-393a-4de3-83d6-df4785b690c6	مستندسازی و نهایی‌سازی	81	76	2026-07-16	approved	42df4646-393a-4de3-83d6-df4785b690c6	\N	db7da5c4-1d2e-4b5d-92d1-d4511bc05157	2026-07-21 18:09:05.468077+00	2026-07-21 18:09:05.468077+00
2f01124a-87cc-42c0-aff1-ff0045070c4d	3ed34084-dd2e-4e40-890b-43347bb82368	42df4646-393a-4de3-83d6-df4785b690c6	مستندسازی و نهایی‌سازی	36	100	2026-07-16	approved	42df4646-393a-4de3-83d6-df4785b690c6	\N	8bb9176f-e09f-4b84-b228-8e9e74351dc4	2026-07-21 18:09:05.468077+00	2026-07-21 18:09:05.468077+00
2f01124a-87cc-42c0-aff1-ff0045070c4d	3ed34084-dd2e-4e40-890b-43347bb82368	42df4646-393a-4de3-83d6-df4785b690c6	رفع اشکالات و بازبینی	207	88	2026-07-16	approved	42df4646-393a-4de3-83d6-df4785b690c6	\N	d66e308d-62da-460b-bd74-a4c3306808c3	2026-07-21 18:09:05.468077+00	2026-07-21 18:09:05.468077+00
2f01124a-87cc-42c0-aff1-ff0045070c4d	d097332f-f215-4cd3-95f5-bda99022d2ed	42df4646-393a-4de3-83d6-df4785b690c6	رفع اشکالات و بازبینی	91	28	2026-07-16	approved	42df4646-393a-4de3-83d6-df4785b690c6	\N	c4b1ac42-586f-4c4b-889c-3bff180e398f	2026-07-21 18:09:05.468077+00	2026-07-21 18:09:05.468077+00
2f01124a-87cc-42c0-aff1-ff0045070c4d	d097332f-f215-4cd3-95f5-bda99022d2ed	42df4646-393a-4de3-83d6-df4785b690c6	تست و اطمینان از عملکرد صحیح	48	68	2026-07-16	submitted	\N	\N	e9d83960-8f38-4a82-959d-268e4665facb	2026-07-21 18:09:05.468077+00	2026-07-21 18:09:05.468077+00
2f01124a-87cc-42c0-aff1-ff0045070c4d	d097332f-f215-4cd3-95f5-bda99022d2ed	42df4646-393a-4de3-83d6-df4785b690c6	مستندسازی و نهایی‌سازی	159	99	2026-07-16	approved	42df4646-393a-4de3-83d6-df4785b690c6	\N	4712aae5-6cff-4392-aa4a-573378d43db6	2026-07-21 18:09:05.468077+00	2026-07-21 18:09:05.468077+00
2f01124a-87cc-42c0-aff1-ff0045070c4d	d097332f-f215-4cd3-95f5-bda99022d2ed	42df4646-393a-4de3-83d6-df4785b690c6	رفع اشکالات و بازبینی	209	100	2026-07-16	submitted	\N	\N	35f24b1d-d68d-4d0b-8887-e68daeba7dd9	2026-07-21 18:09:05.468077+00	2026-07-21 18:09:05.468077+00
2f01124a-87cc-42c0-aff1-ff0045070c4d	dbb0d5e2-eb82-4900-b4a4-e82797a4aa29	3683aa32-1561-4f36-90bf-d6402b4a66d8	پیاده‌سازی بخش اصلی	198	31	2026-06-24	approved	42df4646-393a-4de3-83d6-df4785b690c6	\N	7ac05dbb-7f69-4815-b030-303a8644450d	2026-07-21 18:09:05.468077+00	2026-07-21 18:09:05.468077+00
2f01124a-87cc-42c0-aff1-ff0045070c4d	b1eff962-70dd-47f4-a0b0-cca5ce06aff7	2d6d452d-4915-4793-bf0b-ad7d43798e6f	مستندسازی و نهایی‌سازی	195	40	2026-07-16	approved	42df4646-393a-4de3-83d6-df4785b690c6	\N	0dc475d1-7055-4fa9-a67d-97954198b531	2026-07-21 18:09:05.468077+00	2026-07-21 18:09:05.468077+00
2f01124a-87cc-42c0-aff1-ff0045070c4d	b1eff962-70dd-47f4-a0b0-cca5ce06aff7	2d6d452d-4915-4793-bf0b-ad7d43798e6f	رفع اشکالات و بازبینی	233	66	2026-07-16	approved	42df4646-393a-4de3-83d6-df4785b690c6	\N	bf2efd6f-e1da-4ca1-9700-255d86549c08	2026-07-21 18:09:05.468077+00	2026-07-21 18:09:05.468077+00
2f01124a-87cc-42c0-aff1-ff0045070c4d	ca1b05be-2aba-407d-b182-d53d642015a4	3683aa32-1561-4f36-90bf-d6402b4a66d8	پیشرفت اولیه و بررسی نیازمندی‌ها	96	27	2026-07-16	approved	42df4646-393a-4de3-83d6-df4785b690c6	\N	793ec5db-b76a-476b-9db0-21a679e3b3f6	2026-07-21 18:09:05.468077+00	2026-07-21 18:09:05.468077+00
2f01124a-87cc-42c0-aff1-ff0045070c4d	0d324add-4779-49ec-8546-1a2349d27bf9	b4d6dda1-b07b-48aa-b440-b2cbfe40ac0f	رفع اشکالات و بازبینی	130	34	2026-07-16	approved	42df4646-393a-4de3-83d6-df4785b690c6	\N	a94600f6-b537-49f2-b065-f8d64f14daf7	2026-07-21 18:09:05.468077+00	2026-07-21 18:09:05.468077+00
2f01124a-87cc-42c0-aff1-ff0045070c4d	0d324add-4779-49ec-8546-1a2349d27bf9	b4d6dda1-b07b-48aa-b440-b2cbfe40ac0f	رفع اشکالات و بازبینی	36	70	2026-07-16	approved	42df4646-393a-4de3-83d6-df4785b690c6	\N	18d7a4af-a05c-41ee-b17d-8a64ac328fe6	2026-07-21 18:09:05.468077+00	2026-07-21 18:09:05.468077+00
2f01124a-87cc-42c0-aff1-ff0045070c4d	1fd8f914-2e3d-49ac-8f99-1fe835b47517	2d6d452d-4915-4793-bf0b-ad7d43798e6f	پیشرفت اولیه و بررسی نیازمندی‌ها	59	24	2026-07-16	approved	42df4646-393a-4de3-83d6-df4785b690c6	\N	d2225eae-e945-44cc-b03b-fe9cae399708	2026-07-21 18:09:05.468077+00	2026-07-21 18:09:05.468077+00
2f01124a-87cc-42c0-aff1-ff0045070c4d	fa489af0-3f23-4ced-92cc-bce78e608f8e	72cdbbe8-b0fe-43f0-ab1a-f11f02a63e1f	رفع اشکالات و بازبینی	146	26	2026-07-16	approved	42df4646-393a-4de3-83d6-df4785b690c6	\N	c52bd809-694f-42cf-9f52-743187b5b3f0	2026-07-21 18:09:05.468077+00	2026-07-21 18:09:05.468077+00
2f01124a-87cc-42c0-aff1-ff0045070c4d	fa489af0-3f23-4ced-92cc-bce78e608f8e	72cdbbe8-b0fe-43f0-ab1a-f11f02a63e1f	رفع اشکالات و بازبینی	151	46	2026-07-16	approved	42df4646-393a-4de3-83d6-df4785b690c6	\N	bbd8304c-2508-4f05-9e3f-5b37b65bf6d5	2026-07-21 18:09:05.468077+00	2026-07-21 18:09:05.468077+00
2f01124a-87cc-42c0-aff1-ff0045070c4d	fa489af0-3f23-4ced-92cc-bce78e608f8e	72cdbbe8-b0fe-43f0-ab1a-f11f02a63e1f	تست و اطمینان از عملکرد صحیح	111	66	2026-07-16	approved	42df4646-393a-4de3-83d6-df4785b690c6	\N	87d474b2-827d-41aa-b28a-3d639391cacb	2026-07-21 18:09:05.468077+00	2026-07-21 18:09:05.468077+00
2f01124a-87cc-42c0-aff1-ff0045070c4d	3ec832dd-9c04-48c2-a975-338ac5a9c144	b4d6dda1-b07b-48aa-b440-b2cbfe40ac0f	پیشرفت اولیه و بررسی نیازمندی‌ها	35	30	2026-07-16	approved	42df4646-393a-4de3-83d6-df4785b690c6	\N	4bad7755-4335-4985-8f13-3bd7f2cc89dd	2026-07-21 18:09:05.468077+00	2026-07-21 18:09:05.468077+00
2f01124a-87cc-42c0-aff1-ff0045070c4d	3ec832dd-9c04-48c2-a975-338ac5a9c144	b4d6dda1-b07b-48aa-b440-b2cbfe40ac0f	پیاده‌سازی بخش اصلی	219	54	2026-07-16	approved	42df4646-393a-4de3-83d6-df4785b690c6	\N	c2de35e1-c57a-4b66-8cda-d89d634c854d	2026-07-21 18:09:05.468077+00	2026-07-21 18:09:05.468077+00
2f01124a-87cc-42c0-aff1-ff0045070c4d	3ec832dd-9c04-48c2-a975-338ac5a9c144	b4d6dda1-b07b-48aa-b440-b2cbfe40ac0f	مستندسازی و نهایی‌سازی	70	90	2026-07-16	approved	42df4646-393a-4de3-83d6-df4785b690c6	\N	dcea9f05-6ef0-4255-aecd-86dd76c5cd60	2026-07-21 18:09:05.468077+00	2026-07-21 18:09:05.468077+00
2f01124a-87cc-42c0-aff1-ff0045070c4d	c6bddffd-d179-4663-96ee-43c85ee7259c	72cdbbe8-b0fe-43f0-ab1a-f11f02a63e1f	پیاده‌سازی بخش اصلی	234	32	2026-07-16	approved	42df4646-393a-4de3-83d6-df4785b690c6	\N	3225cfb1-fa57-40fa-8999-85d6e54a85fa	2026-07-21 18:09:05.468077+00	2026-07-21 18:09:05.468077+00
2f01124a-87cc-42c0-aff1-ff0045070c4d	c6bddffd-d179-4663-96ee-43c85ee7259c	72cdbbe8-b0fe-43f0-ab1a-f11f02a63e1f	پیاده‌سازی بخش اصلی	193	66	2026-07-16	approved	42df4646-393a-4de3-83d6-df4785b690c6	\N	be60c626-64dd-4cc5-a166-467b18029c1a	2026-07-21 18:09:05.468077+00	2026-07-21 18:09:05.468077+00
2f01124a-87cc-42c0-aff1-ff0045070c4d	c6bddffd-d179-4663-96ee-43c85ee7259c	72cdbbe8-b0fe-43f0-ab1a-f11f02a63e1f	پیشرفت اولیه و بررسی نیازمندی‌ها	218	100	2026-07-16	approved	42df4646-393a-4de3-83d6-df4785b690c6	\N	1d97e17f-cb9a-4fbb-87c5-263177375b02	2026-07-21 18:09:05.468077+00	2026-07-21 18:09:05.468077+00
2f01124a-87cc-42c0-aff1-ff0045070c4d	c6bddffd-d179-4663-96ee-43c85ee7259c	72cdbbe8-b0fe-43f0-ab1a-f11f02a63e1f	تست و اطمینان از عملکرد صحیح	181	100	2026-07-16	approved	42df4646-393a-4de3-83d6-df4785b690c6	\N	5a8985e7-33f5-4624-83c6-f8b6fcedb37f	2026-07-21 18:09:05.468077+00	2026-07-21 18:09:05.468077+00
2f01124a-87cc-42c0-aff1-ff0045070c4d	2a77d79c-a797-4d87-a2c0-d9d3e50967da	72cdbbe8-b0fe-43f0-ab1a-f11f02a63e1f	پیاده‌سازی بخش اصلی	101	22	2026-07-12	submitted	\N	\N	00a3d8a5-8833-4086-9126-5b192f98a417	2026-07-21 18:09:05.468077+00	2026-07-21 18:09:05.468077+00
2f01124a-87cc-42c0-aff1-ff0045070c4d	2a77d79c-a797-4d87-a2c0-d9d3e50967da	72cdbbe8-b0fe-43f0-ab1a-f11f02a63e1f	مستندسازی و نهایی‌سازی	77	62	2026-07-13	submitted	\N	\N	ad24a0a3-8a69-4d7a-a706-6f13061cceca	2026-07-21 18:09:05.468077+00	2026-07-21 18:09:05.468077+00
2f01124a-87cc-42c0-aff1-ff0045070c4d	2a77d79c-a797-4d87-a2c0-d9d3e50967da	72cdbbe8-b0fe-43f0-ab1a-f11f02a63e1f	پیشرفت اولیه و بررسی نیازمندی‌ها	97	100	2026-07-16	approved	42df4646-393a-4de3-83d6-df4785b690c6	\N	9b726d92-5901-4426-97cd-b394c6357590	2026-07-21 18:09:05.468077+00	2026-07-21 18:09:05.468077+00
2f01124a-87cc-42c0-aff1-ff0045070c4d	2a77d79c-a797-4d87-a2c0-d9d3e50967da	72cdbbe8-b0fe-43f0-ab1a-f11f02a63e1f	مستندسازی و نهایی‌سازی	130	100	2026-07-16	approved	42df4646-393a-4de3-83d6-df4785b690c6	\N	b0236f19-d412-46c7-bbf3-f8df27a51535	2026-07-21 18:09:05.468077+00	2026-07-21 18:09:05.468077+00
2f01124a-87cc-42c0-aff1-ff0045070c4d	e8b153b2-7a9f-4983-b37f-b637279ac701	72cdbbe8-b0fe-43f0-ab1a-f11f02a63e1f	رفع اشکالات و بازبینی	147	39	2026-06-19	approved	42df4646-393a-4de3-83d6-df4785b690c6	\N	971b9d5c-1f21-4799-bace-1ad0d9d85d56	2026-07-21 18:09:05.468077+00	2026-07-21 18:09:05.468077+00
2f01124a-87cc-42c0-aff1-ff0045070c4d	95944a52-0c08-4018-8c67-8d195e845182	72cdbbe8-b0fe-43f0-ab1a-f11f02a63e1f	مستندسازی و نهایی‌سازی	181	22	2026-07-06	approved	42df4646-393a-4de3-83d6-df4785b690c6	\N	73ceb0b5-25a7-4ab9-add2-08b1ca8e04bc	2026-07-21 18:09:05.468077+00	2026-07-21 18:09:05.468077+00
2f01124a-87cc-42c0-aff1-ff0045070c4d	95944a52-0c08-4018-8c67-8d195e845182	72cdbbe8-b0fe-43f0-ab1a-f11f02a63e1f	رفع اشکالات و بازبینی	60	54	2026-07-08	approved	42df4646-393a-4de3-83d6-df4785b690c6	\N	d550a059-a178-492b-bca5-d640c649457c	2026-07-21 18:09:05.468077+00	2026-07-21 18:09:05.468077+00
2f01124a-87cc-42c0-aff1-ff0045070c4d	779200aa-0362-483d-8534-18684332028f	2d6d452d-4915-4793-bf0b-ad7d43798e6f	پیاده‌سازی بخش اصلی	125	24	2026-07-16	approved	42df4646-393a-4de3-83d6-df4785b690c6	\N	715dacf2-decf-4cca-a2b4-f90efe826045	2026-07-21 18:09:05.468077+00	2026-07-21 18:09:05.468077+00
2f01124a-87cc-42c0-aff1-ff0045070c4d	779200aa-0362-483d-8534-18684332028f	2d6d452d-4915-4793-bf0b-ad7d43798e6f	تست و اطمینان از عملکرد صحیح	182	48	2026-07-16	approved	42df4646-393a-4de3-83d6-df4785b690c6	\N	0b541e99-356c-469a-b3fe-ebc6f4f4a4e2	2026-07-21 18:09:05.468077+00	2026-07-21 18:09:05.468077+00
2f01124a-87cc-42c0-aff1-ff0045070c4d	779200aa-0362-483d-8534-18684332028f	2d6d452d-4915-4793-bf0b-ad7d43798e6f	تست و اطمینان از عملکرد صحیح	77	100	2026-07-16	approved	42df4646-393a-4de3-83d6-df4785b690c6	\N	07ba6990-c6f7-4998-8c5a-01f133366caf	2026-07-21 18:09:05.468077+00	2026-07-21 18:09:05.468077+00
2f01124a-87cc-42c0-aff1-ff0045070c4d	3c547e90-c308-4261-911a-8999264d0699	92a3b31d-254e-440b-8bbe-d18db13d73cd	پیاده‌سازی بخش اصلی	77	30	2026-07-16	approved	42df4646-393a-4de3-83d6-df4785b690c6	\N	5919fda2-1bd0-4fcb-b50a-a8f57a56ced3	2026-07-21 18:09:05.468077+00	2026-07-21 18:09:05.468077+00
2f01124a-87cc-42c0-aff1-ff0045070c4d	3c547e90-c308-4261-911a-8999264d0699	92a3b31d-254e-440b-8bbe-d18db13d73cd	رفع اشکالات و بازبینی	32	70	2026-07-16	approved	42df4646-393a-4de3-83d6-df4785b690c6	\N	054ff989-1338-45d6-b321-6521c91cd9e9	2026-07-21 18:09:05.468077+00	2026-07-21 18:09:05.468077+00
2f01124a-87cc-42c0-aff1-ff0045070c4d	779570eb-34ae-4236-920a-a27eac4e8107	72cdbbe8-b0fe-43f0-ab1a-f11f02a63e1f	تست و اطمینان از عملکرد صحیح	173	36	2026-07-16	approved	42df4646-393a-4de3-83d6-df4785b690c6	\N	df3bb074-c969-43e1-8b66-39c0a57cf645	2026-07-21 18:09:05.468077+00	2026-07-21 18:09:05.468077+00
2f01124a-87cc-42c0-aff1-ff0045070c4d	779570eb-34ae-4236-920a-a27eac4e8107	72cdbbe8-b0fe-43f0-ab1a-f11f02a63e1f	تست و اطمینان از عملکرد صحیح	205	70	2026-07-16	approved	42df4646-393a-4de3-83d6-df4785b690c6	\N	f4254e5d-989c-4591-80f6-9130ea4b6784	2026-07-21 18:09:05.468077+00	2026-07-21 18:09:05.468077+00
2f01124a-87cc-42c0-aff1-ff0045070c4d	0fe152b5-3f1d-43d3-82c1-6c8843cfd321	b4d6dda1-b07b-48aa-b440-b2cbfe40ac0f	تست و اطمینان از عملکرد صحیح	72	22	2026-07-03	approved	42df4646-393a-4de3-83d6-df4785b690c6	\N	8bcc5a3b-99da-40bd-9d8d-4191323f77ea	2026-07-21 18:09:05.468077+00	2026-07-21 18:09:05.468077+00
2f01124a-87cc-42c0-aff1-ff0045070c4d	0fe152b5-3f1d-43d3-82c1-6c8843cfd321	b4d6dda1-b07b-48aa-b440-b2cbfe40ac0f	پیاده‌سازی بخش اصلی	104	42	2026-07-04	approved	42df4646-393a-4de3-83d6-df4785b690c6	\N	76fad9c1-dd8a-4864-95a2-0c3fdf5f34fc	2026-07-21 18:09:05.468077+00	2026-07-21 18:09:05.468077+00
2f01124a-87cc-42c0-aff1-ff0045070c4d	0fe152b5-3f1d-43d3-82c1-6c8843cfd321	b4d6dda1-b07b-48aa-b440-b2cbfe40ac0f	پیاده‌سازی بخش اصلی	167	87	2026-07-09	approved	42df4646-393a-4de3-83d6-df4785b690c6	\N	82b38a54-8eb1-4d25-a573-ada19aded50c	2026-07-21 18:09:05.468077+00	2026-07-21 18:09:05.468077+00
2f01124a-87cc-42c0-aff1-ff0045070c4d	0fe152b5-3f1d-43d3-82c1-6c8843cfd321	b4d6dda1-b07b-48aa-b440-b2cbfe40ac0f	تست و اطمینان از عملکرد صحیح	174	100	2026-07-09	approved	42df4646-393a-4de3-83d6-df4785b690c6	\N	9df4de9a-b467-4968-8151-4505909e5a54	2026-07-21 18:09:05.468077+00	2026-07-21 18:09:05.468077+00
2f01124a-87cc-42c0-aff1-ff0045070c4d	04dd62a5-fd91-4931-b161-9659c8d811b7	02b5f471-cd3d-47ff-85ad-d22286b9e4b1	مستندسازی و نهایی‌سازی	240	31	2026-07-16	approved	42df4646-393a-4de3-83d6-df4785b690c6	\N	d35a6d90-8590-498e-ad7f-5e2f40a9af30	2026-07-21 18:09:05.468077+00	2026-07-21 18:09:05.468077+00
2f01124a-87cc-42c0-aff1-ff0045070c4d	89b3ce6d-fa8f-4ced-8256-204f8b553ad4	42df4646-393a-4de3-83d6-df4785b690c6	تست و اطمینان از عملکرد صحیح	56	40	2026-07-16	approved	42df4646-393a-4de3-83d6-df4785b690c6	\N	e055850b-a994-4631-a499-8f9574062678	2026-07-21 18:09:05.468077+00	2026-07-21 18:09:05.468077+00
2f01124a-87cc-42c0-aff1-ff0045070c4d	4d6912ef-d2d7-4d29-a1c1-391a6a979c51	b4d6dda1-b07b-48aa-b440-b2cbfe40ac0f	پیشرفت اولیه و بررسی نیازمندی‌ها	145	28	2026-07-16	approved	42df4646-393a-4de3-83d6-df4785b690c6	\N	1ca7e4fe-f57d-4314-8b0d-d7d3e124b546	2026-07-21 18:09:05.468077+00	2026-07-21 18:09:05.468077+00
2f01124a-87cc-42c0-aff1-ff0045070c4d	4d6912ef-d2d7-4d29-a1c1-391a6a979c51	b4d6dda1-b07b-48aa-b440-b2cbfe40ac0f	پیشرفت اولیه و بررسی نیازمندی‌ها	142	46	2026-07-16	approved	42df4646-393a-4de3-83d6-df4785b690c6	\N	cd6498c4-dc66-4f98-a59e-9649296123da	2026-07-21 18:09:05.468077+00	2026-07-21 18:09:05.468077+00
2f01124a-87cc-42c0-aff1-ff0045070c4d	5e93df2a-2c21-4ab4-81f2-66af9de99468	3683aa32-1561-4f36-90bf-d6402b4a66d8	مستندسازی و نهایی‌سازی	206	31	2026-07-01	submitted	\N	\N	d1117e9e-105d-4e5c-8957-c18abafc329b	2026-07-21 18:09:05.468077+00	2026-07-21 18:09:05.468077+00
2f01124a-87cc-42c0-aff1-ff0045070c4d	5e93df2a-2c21-4ab4-81f2-66af9de99468	3683aa32-1561-4f36-90bf-d6402b4a66d8	پیاده‌سازی بخش اصلی	230	52	2026-07-05	approved	42df4646-393a-4de3-83d6-df4785b690c6	\N	c5b1b04b-0820-413f-a455-06c7a89fb042	2026-07-21 18:09:05.468077+00	2026-07-21 18:09:05.468077+00
2f01124a-87cc-42c0-aff1-ff0045070c4d	d43082c7-665d-45d9-8491-4810a695e30d	92a3b31d-254e-440b-8bbe-d18db13d73cd	مستندسازی و نهایی‌سازی	119	37	2026-07-04	approved	42df4646-393a-4de3-83d6-df4785b690c6	\N	10366539-1d0b-4a52-b7ce-63924f31eb27	2026-07-21 18:09:05.468077+00	2026-07-21 18:09:05.468077+00
2f01124a-87cc-42c0-aff1-ff0045070c4d	d43082c7-665d-45d9-8491-4810a695e30d	92a3b31d-254e-440b-8bbe-d18db13d73cd	مستندسازی و نهایی‌سازی	167	50	2026-07-07	approved	42df4646-393a-4de3-83d6-df4785b690c6	\N	199f4fbd-f6fd-44de-ad98-6def4b8ed0c5	2026-07-21 18:09:05.468077+00	2026-07-21 18:09:05.468077+00
2f01124a-87cc-42c0-aff1-ff0045070c4d	c9b7eea8-c601-4115-9517-8583a9ada716	42df4646-393a-4de3-83d6-df4785b690c6	رفع اشکالات و بازبینی	176	28	2026-07-16	approved	42df4646-393a-4de3-83d6-df4785b690c6	\N	5b06c8ef-f885-4d4e-85b9-39359747a08e	2026-07-21 18:09:05.468077+00	2026-07-21 18:09:05.468077+00
2f01124a-87cc-42c0-aff1-ff0045070c4d	c9b7eea8-c601-4115-9517-8583a9ada716	42df4646-393a-4de3-83d6-df4785b690c6	پیاده‌سازی بخش اصلی	222	66	2026-07-16	approved	42df4646-393a-4de3-83d6-df4785b690c6	\N	d9aebcc2-fa3c-4ca5-a8b3-4ebbbda46350	2026-07-21 18:09:05.468077+00	2026-07-21 18:09:05.468077+00
2f01124a-87cc-42c0-aff1-ff0045070c4d	c9b7eea8-c601-4115-9517-8583a9ada716	42df4646-393a-4de3-83d6-df4785b690c6	رفع اشکالات و بازبینی	197	72	2026-07-16	approved	42df4646-393a-4de3-83d6-df4785b690c6	\N	d0c14478-c7ee-43a9-b161-e2c952709346	2026-07-21 18:09:05.468077+00	2026-07-21 18:09:05.468077+00
2f01124a-87cc-42c0-aff1-ff0045070c4d	3dc40829-24e3-4e65-9ca8-0e1bfdadf466	72cdbbe8-b0fe-43f0-ab1a-f11f02a63e1f	رفع اشکالات و بازبینی	93	32	2026-07-16	approved	42df4646-393a-4de3-83d6-df4785b690c6	\N	d39efc58-aa1d-4e71-8a40-e3de65ed34cb	2026-07-21 18:09:05.468077+00	2026-07-21 18:09:05.468077+00
2f01124a-87cc-42c0-aff1-ff0045070c4d	3dc40829-24e3-4e65-9ca8-0e1bfdadf466	72cdbbe8-b0fe-43f0-ab1a-f11f02a63e1f	رفع اشکالات و بازبینی	190	66	2026-07-16	approved	42df4646-393a-4de3-83d6-df4785b690c6	\N	3c556566-6ee4-4dbb-a39f-24ffbe45bb6d	2026-07-21 18:09:05.468077+00	2026-07-21 18:09:05.468077+00
2f01124a-87cc-42c0-aff1-ff0045070c4d	85cca325-85bd-49e7-a591-addafa45399b	2d6d452d-4915-4793-bf0b-ad7d43798e6f	پیشرفت اولیه و بررسی نیازمندی‌ها	133	36	2026-07-15	approved	42df4646-393a-4de3-83d6-df4785b690c6	\N	0a14b14a-8cb4-4fc5-9ec4-24a4f45b0d40	2026-07-21 18:09:05.468077+00	2026-07-21 18:09:05.468077+00
2f01124a-87cc-42c0-aff1-ff0045070c4d	85cca325-85bd-49e7-a591-addafa45399b	2d6d452d-4915-4793-bf0b-ad7d43798e6f	رفع اشکالات و بازبینی	146	70	2026-07-16	approved	42df4646-393a-4de3-83d6-df4785b690c6	\N	6b050f85-8bfc-43c3-be4e-f14f51fbebb3	2026-07-21 18:09:05.468077+00	2026-07-21 18:09:05.468077+00
2f01124a-87cc-42c0-aff1-ff0045070c4d	85cca325-85bd-49e7-a591-addafa45399b	2d6d452d-4915-4793-bf0b-ad7d43798e6f	پیشرفت اولیه و بررسی نیازمندی‌ها	217	100	2026-07-16	approved	42df4646-393a-4de3-83d6-df4785b690c6	\N	1a4b975a-2e03-4dc6-b487-b4bf2783d539	2026-07-21 18:09:05.468077+00	2026-07-21 18:09:05.468077+00
2f01124a-87cc-42c0-aff1-ff0045070c4d	85cca325-85bd-49e7-a591-addafa45399b	2d6d452d-4915-4793-bf0b-ad7d43798e6f	مستندسازی و نهایی‌سازی	131	100	2026-07-16	submitted	\N	\N	04ce82a5-d8aa-4c84-836e-a2ffa79872dc	2026-07-21 18:09:05.468077+00	2026-07-21 18:09:05.468077+00
2f01124a-87cc-42c0-aff1-ff0045070c4d	9651f85e-a3ba-4d55-a592-e590f8a98d07	02b5f471-cd3d-47ff-85ad-d22286b9e4b1	رفع اشکالات و بازبینی	102	30	2026-06-28	approved	42df4646-393a-4de3-83d6-df4785b690c6	\N	38de3182-3e39-4afe-9367-a9c891921e97	2026-07-21 18:09:05.468077+00	2026-07-21 18:09:05.468077+00
2f01124a-87cc-42c0-aff1-ff0045070c4d	9651f85e-a3ba-4d55-a592-e590f8a98d07	02b5f471-cd3d-47ff-85ad-d22286b9e4b1	تست و اطمینان از عملکرد صحیح	231	60	2026-06-30	approved	42df4646-393a-4de3-83d6-df4785b690c6	\N	038b4f82-2aa5-4bf7-8aeb-51437a70afca	2026-07-21 18:09:05.468077+00	2026-07-21 18:09:05.468077+00
2f01124a-87cc-42c0-aff1-ff0045070c4d	9651f85e-a3ba-4d55-a592-e590f8a98d07	02b5f471-cd3d-47ff-85ad-d22286b9e4b1	تست و اطمینان از عملکرد صحیح	34	69	2026-06-30	approved	42df4646-393a-4de3-83d6-df4785b690c6	\N	528012ac-c97f-4467-99a4-14a8edb57ed2	2026-07-21 18:09:05.468077+00	2026-07-21 18:09:05.468077+00
2f01124a-87cc-42c0-aff1-ff0045070c4d	9651f85e-a3ba-4d55-a592-e590f8a98d07	02b5f471-cd3d-47ff-85ad-d22286b9e4b1	پیشرفت اولیه و بررسی نیازمندی‌ها	139	100	2026-07-04	approved	42df4646-393a-4de3-83d6-df4785b690c6	\N	a94636ae-a2de-44ce-86cb-8dce118fac3e	2026-07-21 18:09:05.468077+00	2026-07-21 18:09:05.468077+00
2f01124a-87cc-42c0-aff1-ff0045070c4d	d6e35365-3e3d-401c-a71f-56dc4e473dff	02b5f471-cd3d-47ff-85ad-d22286b9e4b1	پیاده‌سازی بخش اصلی	100	22	2026-06-24	approved	42df4646-393a-4de3-83d6-df4785b690c6	\N	5968d763-2776-475e-8245-1a3c447356e4	2026-07-21 18:09:05.468077+00	2026-07-21 18:09:05.468077+00
2f01124a-87cc-42c0-aff1-ff0045070c4d	d6e35365-3e3d-401c-a71f-56dc4e473dff	02b5f471-cd3d-47ff-85ad-d22286b9e4b1	رفع اشکالات و بازبینی	51	62	2026-06-27	approved	42df4646-393a-4de3-83d6-df4785b690c6	\N	a8842cdd-98f3-4dbf-ae4c-3a4bcb562b7a	2026-07-21 18:09:05.468077+00	2026-07-21 18:09:05.468077+00
2f01124a-87cc-42c0-aff1-ff0045070c4d	9558aa9c-e1d1-4ab6-bf6d-a6d8445fe844	02b5f471-cd3d-47ff-85ad-d22286b9e4b1	رفع اشکالات و بازبینی	215	27	2026-07-14	approved	42df4646-393a-4de3-83d6-df4785b690c6	\N	a7264d99-32ba-43d9-b4c7-08e9ec502225	2026-07-21 18:09:05.468077+00	2026-07-21 18:09:05.468077+00
2f01124a-87cc-42c0-aff1-ff0045070c4d	9558aa9c-e1d1-4ab6-bf6d-a6d8445fe844	02b5f471-cd3d-47ff-85ad-d22286b9e4b1	پیشرفت اولیه و بررسی نیازمندی‌ها	30	52	2026-07-16	approved	42df4646-393a-4de3-83d6-df4785b690c6	\N	8bc6280e-dd23-4aab-939b-49cff6d3e165	2026-07-21 18:09:05.468077+00	2026-07-21 18:09:05.468077+00
2f01124a-87cc-42c0-aff1-ff0045070c4d	1cadd9e1-078e-46f8-910b-d70726e8df71	42df4646-393a-4de3-83d6-df4785b690c6	پیاده‌سازی بخش اصلی	162	34	2026-07-16	approved	42df4646-393a-4de3-83d6-df4785b690c6	\N	c0c77da6-478e-471f-bbe0-68cfb5216aac	2026-07-21 18:09:05.468077+00	2026-07-21 18:09:05.468077+00
2f01124a-87cc-42c0-aff1-ff0045070c4d	1cadd9e1-078e-46f8-910b-d70726e8df71	42df4646-393a-4de3-83d6-df4785b690c6	رفع اشکالات و بازبینی	239	46	2026-07-16	approved	42df4646-393a-4de3-83d6-df4785b690c6	\N	c4d05335-45f3-45c3-86fc-3ce73e53248d	2026-07-21 18:09:05.468077+00	2026-07-21 18:09:05.468077+00
2f01124a-87cc-42c0-aff1-ff0045070c4d	1cadd9e1-078e-46f8-910b-d70726e8df71	42df4646-393a-4de3-83d6-df4785b690c6	تست و اطمینان از عملکرد صحیح	48	81	2026-07-16	approved	42df4646-393a-4de3-83d6-df4785b690c6	\N	857b6692-6321-4291-909f-e544e11ba7cb	2026-07-21 18:09:05.468077+00	2026-07-21 18:09:05.468077+00
2f01124a-87cc-42c0-aff1-ff0045070c4d	1cadd9e1-078e-46f8-910b-d70726e8df71	42df4646-393a-4de3-83d6-df4785b690c6	پیشرفت اولیه و بررسی نیازمندی‌ها	56	100	2026-07-16	approved	42df4646-393a-4de3-83d6-df4785b690c6	\N	f2f3c667-a6ca-47db-8998-0c21edd49eaf	2026-07-21 18:09:05.468077+00	2026-07-21 18:09:05.468077+00
2f01124a-87cc-42c0-aff1-ff0045070c4d	d4e703a0-eb3a-4430-885b-4cbe136c6c2a	02b5f471-cd3d-47ff-85ad-d22286b9e4b1	پیاده‌سازی بخش اصلی	194	24	2026-06-26	approved	42df4646-393a-4de3-83d6-df4785b690c6	\N	e92a579a-6e2f-488b-be36-d12cfa0ee1ba	2026-07-21 18:09:05.468077+00	2026-07-21 18:09:05.468077+00
2f01124a-87cc-42c0-aff1-ff0045070c4d	d4e703a0-eb3a-4430-885b-4cbe136c6c2a	02b5f471-cd3d-47ff-85ad-d22286b9e4b1	پیشرفت اولیه و بررسی نیازمندی‌ها	186	80	2026-06-27	approved	42df4646-393a-4de3-83d6-df4785b690c6	\N	63028954-055d-4636-8ac0-48aaf8235b0d	2026-07-21 18:09:05.468077+00	2026-07-21 18:09:05.468077+00
2f01124a-87cc-42c0-aff1-ff0045070c4d	d4e703a0-eb3a-4430-885b-4cbe136c6c2a	02b5f471-cd3d-47ff-85ad-d22286b9e4b1	پیاده‌سازی بخش اصلی	190	72	2026-06-30	approved	42df4646-393a-4de3-83d6-df4785b690c6	\N	d3574306-d65b-4bc9-995d-570d5973900f	2026-07-21 18:09:05.468077+00	2026-07-21 18:09:05.468077+00
2f01124a-87cc-42c0-aff1-ff0045070c4d	523ca685-dae6-4854-8eb9-7cd4f8e5354c	72cdbbe8-b0fe-43f0-ab1a-f11f02a63e1f	پیشرفت اولیه و بررسی نیازمندی‌ها	55	24	2026-07-09	submitted	\N	\N	b3b3b02f-6251-4a30-b02c-3dd9f6e52cbb	2026-07-21 18:09:05.468077+00	2026-07-21 18:09:05.468077+00
2f01124a-87cc-42c0-aff1-ff0045070c4d	523ca685-dae6-4854-8eb9-7cd4f8e5354c	72cdbbe8-b0fe-43f0-ab1a-f11f02a63e1f	تست و اطمینان از عملکرد صحیح	119	66	2026-07-10	approved	42df4646-393a-4de3-83d6-df4785b690c6	\N	677fa867-b943-42f0-9f35-f212a8c11deb	2026-07-21 18:09:05.468077+00	2026-07-21 18:09:05.468077+00
2f01124a-87cc-42c0-aff1-ff0045070c4d	523ca685-dae6-4854-8eb9-7cd4f8e5354c	72cdbbe8-b0fe-43f0-ab1a-f11f02a63e1f	پیاده‌سازی بخش اصلی	100	100	2026-07-15	submitted	\N	\N	b285cbef-f238-4ca7-84e0-18f8f96967d9	2026-07-21 18:09:05.468077+00	2026-07-21 18:09:05.468077+00
2f01124a-87cc-42c0-aff1-ff0045070c4d	523ca685-dae6-4854-8eb9-7cd4f8e5354c	72cdbbe8-b0fe-43f0-ab1a-f11f02a63e1f	مستندسازی و نهایی‌سازی	183	100	2026-07-12	approved	42df4646-393a-4de3-83d6-df4785b690c6	\N	781387e3-fe2b-48cf-b7e0-3a28185c89ee	2026-07-21 18:09:05.468077+00	2026-07-21 18:09:05.468077+00
2f01124a-87cc-42c0-aff1-ff0045070c4d	66966a99-0790-4142-a68f-68eddd1ae9f1	02b5f471-cd3d-47ff-85ad-d22286b9e4b1	رفع اشکالات و بازبینی	82	36	2026-07-16	approved	42df4646-393a-4de3-83d6-df4785b690c6	\N	f1ef91cd-8712-4f39-b676-50f0da014a36	2026-07-21 18:09:05.468077+00	2026-07-21 18:09:05.468077+00
2f01124a-87cc-42c0-aff1-ff0045070c4d	66966a99-0790-4142-a68f-68eddd1ae9f1	02b5f471-cd3d-47ff-85ad-d22286b9e4b1	تست و اطمینان از عملکرد صحیح	105	80	2026-07-16	approved	42df4646-393a-4de3-83d6-df4785b690c6	\N	03012684-4f52-4ae0-9ce5-5cd41c8a0cf9	2026-07-21 18:09:05.468077+00	2026-07-21 18:09:05.468077+00
2f01124a-87cc-42c0-aff1-ff0045070c4d	66966a99-0790-4142-a68f-68eddd1ae9f1	02b5f471-cd3d-47ff-85ad-d22286b9e4b1	پیاده‌سازی بخش اصلی	156	96	2026-07-16	approved	42df4646-393a-4de3-83d6-df4785b690c6	\N	88a85cf0-db0a-45cb-9914-3f3d34e0d843	2026-07-21 18:09:05.468077+00	2026-07-21 18:09:05.468077+00
2f01124a-87cc-42c0-aff1-ff0045070c4d	137ebbff-92cf-488b-adbf-5fb819ba5e73	b4d6dda1-b07b-48aa-b440-b2cbfe40ac0f	تست و اطمینان از عملکرد صحیح	193	39	2026-07-16	approved	42df4646-393a-4de3-83d6-df4785b690c6	\N	1e911210-74b4-4135-b651-beb68b6b4aa0	2026-07-21 18:09:05.468077+00	2026-07-21 18:09:05.468077+00
2f01124a-87cc-42c0-aff1-ff0045070c4d	8d31ee61-c6b4-45f7-ba80-238b97f9f7bd	02b5f471-cd3d-47ff-85ad-d22286b9e4b1	رفع اشکالات و بازبینی	111	24	2026-07-16	approved	42df4646-393a-4de3-83d6-df4785b690c6	\N	25a2f718-b3b4-4e59-ac62-f4be5d05b7c6	2026-07-21 18:09:05.468077+00	2026-07-21 18:09:05.468077+00
2f01124a-87cc-42c0-aff1-ff0045070c4d	deb113e5-8157-495a-8aaf-1547e650aefd	02b5f471-cd3d-47ff-85ad-d22286b9e4b1	پیاده‌سازی بخش اصلی	225	35	2026-07-16	approved	42df4646-393a-4de3-83d6-df4785b690c6	\N	4af9f73a-3a1c-4cb4-b650-5dbd44c7a127	2026-07-21 18:09:05.468077+00	2026-07-21 18:09:05.468077+00
2f01124a-87cc-42c0-aff1-ff0045070c4d	deb113e5-8157-495a-8aaf-1547e650aefd	02b5f471-cd3d-47ff-85ad-d22286b9e4b1	پیشرفت اولیه و بررسی نیازمندی‌ها	33	56	2026-07-16	approved	42df4646-393a-4de3-83d6-df4785b690c6	\N	327f1aad-e437-43b4-b628-9f7208f3ec2c	2026-07-21 18:09:05.468077+00	2026-07-21 18:09:05.468077+00
2f01124a-87cc-42c0-aff1-ff0045070c4d	deb113e5-8157-495a-8aaf-1547e650aefd	02b5f471-cd3d-47ff-85ad-d22286b9e4b1	پیشرفت اولیه و بررسی نیازمندی‌ها	232	96	2026-07-16	approved	42df4646-393a-4de3-83d6-df4785b690c6	\N	a92fa79e-cf71-41a7-a646-e88e9fdee296	2026-07-21 18:09:05.468077+00	2026-07-21 18:09:05.468077+00
2f01124a-87cc-42c0-aff1-ff0045070c4d	deb113e5-8157-495a-8aaf-1547e650aefd	02b5f471-cd3d-47ff-85ad-d22286b9e4b1	مستندسازی و نهایی‌سازی	226	100	2026-07-16	approved	42df4646-393a-4de3-83d6-df4785b690c6	\N	b2e346a0-0950-476c-9d17-14aaee557825	2026-07-21 18:09:05.468077+00	2026-07-21 18:09:05.468077+00
2f01124a-87cc-42c0-aff1-ff0045070c4d	ee4ec177-df68-418f-a0ca-c75b0eadb0ba	02b5f471-cd3d-47ff-85ad-d22286b9e4b1	مستندسازی و نهایی‌سازی	167	39	2026-07-16	approved	42df4646-393a-4de3-83d6-df4785b690c6	\N	3891abd7-04c5-4b64-a440-94e903c8d707	2026-07-21 18:09:05.468077+00	2026-07-21 18:09:05.468077+00
2f01124a-87cc-42c0-aff1-ff0045070c4d	ee4ec177-df68-418f-a0ca-c75b0eadb0ba	02b5f471-cd3d-47ff-85ad-d22286b9e4b1	رفع اشکالات و بازبینی	50	72	2026-07-16	approved	42df4646-393a-4de3-83d6-df4785b690c6	\N	604c4a4f-39e8-490b-bf3d-ab2979bb92e6	2026-07-21 18:09:05.468077+00	2026-07-21 18:09:05.468077+00
2f01124a-87cc-42c0-aff1-ff0045070c4d	ee4ec177-df68-418f-a0ca-c75b0eadb0ba	02b5f471-cd3d-47ff-85ad-d22286b9e4b1	پیاده‌سازی بخش اصلی	167	90	2026-07-16	submitted	\N	\N	559afaba-f801-433f-8347-d138a447c8f5	2026-07-21 18:09:05.468077+00	2026-07-21 18:09:05.468077+00
2f01124a-87cc-42c0-aff1-ff0045070c4d	ee4ec177-df68-418f-a0ca-c75b0eadb0ba	02b5f471-cd3d-47ff-85ad-d22286b9e4b1	پیشرفت اولیه و بررسی نیازمندی‌ها	109	100	2026-07-16	approved	42df4646-393a-4de3-83d6-df4785b690c6	\N	fd65a06e-328c-4f66-936f-ca9ed555404f	2026-07-21 18:09:05.468077+00	2026-07-21 18:09:05.468077+00
2f01124a-87cc-42c0-aff1-ff0045070c4d	7df9f4bf-befb-48ed-a9fa-214ca8ca6dde	02b5f471-cd3d-47ff-85ad-d22286b9e4b1	پیاده‌سازی بخش اصلی	52	33	2026-07-16	approved	42df4646-393a-4de3-83d6-df4785b690c6	\N	8c20d385-9957-4e30-9245-d2783dab7d52	2026-07-21 18:09:05.468077+00	2026-07-21 18:09:05.468077+00
2f01124a-87cc-42c0-aff1-ff0045070c4d	7df9f4bf-befb-48ed-a9fa-214ca8ca6dde	02b5f471-cd3d-47ff-85ad-d22286b9e4b1	تست و اطمینان از عملکرد صحیح	186	78	2026-07-16	approved	42df4646-393a-4de3-83d6-df4785b690c6	\N	a34e9c9b-76b1-4245-8a31-bf2b046a4edb	2026-07-21 18:09:05.468077+00	2026-07-21 18:09:05.468077+00
2f01124a-87cc-42c0-aff1-ff0045070c4d	383a88ac-b988-4f1e-8fdd-79f8814da87c	72cdbbe8-b0fe-43f0-ab1a-f11f02a63e1f	پیاده‌سازی بخش اصلی	60	20	2026-07-16	approved	42df4646-393a-4de3-83d6-df4785b690c6	\N	3bac7d71-66bb-4682-9980-e69a451fb673	2026-07-21 18:09:05.468077+00	2026-07-21 18:09:05.468077+00
2f01124a-87cc-42c0-aff1-ff0045070c4d	a8ecb6ce-b8bc-41e6-b36c-e939587ffc5a	02b5f471-cd3d-47ff-85ad-d22286b9e4b1	پیاده‌سازی بخش اصلی	157	31	2026-06-30	approved	42df4646-393a-4de3-83d6-df4785b690c6	\N	c38a3613-2378-4feb-bdc1-8757470ecbe2	2026-07-21 18:09:05.468077+00	2026-07-21 18:09:05.468077+00
2f01124a-87cc-42c0-aff1-ff0045070c4d	a8ecb6ce-b8bc-41e6-b36c-e939587ffc5a	02b5f471-cd3d-47ff-85ad-d22286b9e4b1	پیاده‌سازی بخش اصلی	125	48	2026-07-03	approved	42df4646-393a-4de3-83d6-df4785b690c6	\N	ee43566b-bc29-47f8-ad8c-0e2a15cf8fd5	2026-07-21 18:09:05.468077+00	2026-07-21 18:09:05.468077+00
2f01124a-87cc-42c0-aff1-ff0045070c4d	da65fa70-e469-4e04-8099-cc60c7353136	02b5f471-cd3d-47ff-85ad-d22286b9e4b1	پیشرفت اولیه و بررسی نیازمندی‌ها	115	33	2026-07-13	approved	42df4646-393a-4de3-83d6-df4785b690c6	\N	66c7037f-1129-4572-a9b6-faada33f1f8f	2026-07-21 18:09:05.468077+00	2026-07-21 18:09:05.468077+00
2f01124a-87cc-42c0-aff1-ff0045070c4d	da65fa70-e469-4e04-8099-cc60c7353136	02b5f471-cd3d-47ff-85ad-d22286b9e4b1	مستندسازی و نهایی‌سازی	46	56	2026-07-16	approved	42df4646-393a-4de3-83d6-df4785b690c6	\N	14864852-d14f-4495-a2cb-69193b027af3	2026-07-21 18:09:05.468077+00	2026-07-21 18:09:05.468077+00
2f01124a-87cc-42c0-aff1-ff0045070c4d	da65fa70-e469-4e04-8099-cc60c7353136	02b5f471-cd3d-47ff-85ad-d22286b9e4b1	تست و اطمینان از عملکرد صحیح	146	100	2026-07-15	approved	42df4646-393a-4de3-83d6-df4785b690c6	\N	24a07973-b9fa-49fe-a7b6-4c0f291fcc9a	2026-07-21 18:09:05.468077+00	2026-07-21 18:09:05.468077+00
2f01124a-87cc-42c0-aff1-ff0045070c4d	cb64afb5-5e06-428f-9011-916ebc0c0b1b	72cdbbe8-b0fe-43f0-ab1a-f11f02a63e1f	مستندسازی و نهایی‌سازی	72	31	2026-07-16	approved	42df4646-393a-4de3-83d6-df4785b690c6	\N	e021b0ce-1f44-4959-af3b-ba7c7f1f1b7e	2026-07-21 18:09:05.468077+00	2026-07-21 18:09:05.468077+00
2f01124a-87cc-42c0-aff1-ff0045070c4d	cb64afb5-5e06-428f-9011-916ebc0c0b1b	72cdbbe8-b0fe-43f0-ab1a-f11f02a63e1f	پیشرفت اولیه و بررسی نیازمندی‌ها	176	46	2026-07-16	approved	42df4646-393a-4de3-83d6-df4785b690c6	\N	b97d69e4-f6c0-4ad7-b52d-b430a72a745f	2026-07-21 18:09:05.468077+00	2026-07-21 18:09:05.468077+00
2f01124a-87cc-42c0-aff1-ff0045070c4d	cb64afb5-5e06-428f-9011-916ebc0c0b1b	72cdbbe8-b0fe-43f0-ab1a-f11f02a63e1f	پیشرفت اولیه و بررسی نیازمندی‌ها	41	60	2026-07-16	submitted	\N	\N	b1ccdbf0-688a-46c6-9d39-e5cbc52edb95	2026-07-21 18:09:05.468077+00	2026-07-21 18:09:05.468077+00
2f01124a-87cc-42c0-aff1-ff0045070c4d	9b7bcf60-6b23-461c-9127-6d8540ad43cf	42df4646-393a-4de3-83d6-df4785b690c6	تست و اطمینان از عملکرد صحیح	123	32	2026-07-16	approved	42df4646-393a-4de3-83d6-df4785b690c6	\N	82cb1b5d-9c51-41c6-b8b1-79c449e0c2eb	2026-07-21 18:09:05.468077+00	2026-07-21 18:09:05.468077+00
2f01124a-87cc-42c0-aff1-ff0045070c4d	9b7bcf60-6b23-461c-9127-6d8540ad43cf	42df4646-393a-4de3-83d6-df4785b690c6	پیاده‌سازی بخش اصلی	39	74	2026-07-16	approved	42df4646-393a-4de3-83d6-df4785b690c6	\N	75c28f83-3b39-4dab-8f3a-1497f51cf3f3	2026-07-21 18:09:05.468077+00	2026-07-21 18:09:05.468077+00
2f01124a-87cc-42c0-aff1-ff0045070c4d	70ea89a0-7413-41cd-bdb6-e611bde53501	02b5f471-cd3d-47ff-85ad-d22286b9e4b1	تست و اطمینان از عملکرد صحیح	214	30	2026-07-16	approved	42df4646-393a-4de3-83d6-df4785b690c6	\N	eff9ec98-e0c6-4698-987e-682fa5d8ef0f	2026-07-21 18:09:05.468077+00	2026-07-21 18:09:05.468077+00
2f01124a-87cc-42c0-aff1-ff0045070c4d	70ea89a0-7413-41cd-bdb6-e611bde53501	02b5f471-cd3d-47ff-85ad-d22286b9e4b1	مستندسازی و نهایی‌سازی	125	46	2026-07-16	submitted	\N	\N	9b1902c9-d852-4a16-8622-c733c16d3a00	2026-07-21 18:09:05.468077+00	2026-07-21 18:09:05.468077+00
2f01124a-87cc-42c0-aff1-ff0045070c4d	70ea89a0-7413-41cd-bdb6-e611bde53501	02b5f471-cd3d-47ff-85ad-d22286b9e4b1	مستندسازی و نهایی‌سازی	41	96	2026-07-16	approved	42df4646-393a-4de3-83d6-df4785b690c6	\N	a07bed2d-f60f-4a77-93a8-b0ecdc5a0706	2026-07-21 18:09:05.468077+00	2026-07-21 18:09:05.468077+00
2f01124a-87cc-42c0-aff1-ff0045070c4d	70ea89a0-7413-41cd-bdb6-e611bde53501	02b5f471-cd3d-47ff-85ad-d22286b9e4b1	رفع اشکالات و بازبینی	228	100	2026-07-16	submitted	\N	\N	34543698-3f22-4057-9825-dafe7572d170	2026-07-21 18:09:05.468077+00	2026-07-21 18:09:05.468077+00
2f01124a-87cc-42c0-aff1-ff0045070c4d	89d9b3b2-2ed3-4714-b966-c97d97f4177e	2d6d452d-4915-4793-bf0b-ad7d43798e6f	پیشرفت اولیه و بررسی نیازمندی‌ها	124	26	2026-07-16	approved	42df4646-393a-4de3-83d6-df4785b690c6	\N	aada26c8-26b8-47ec-bc51-25044667fbba	2026-07-21 18:09:05.468077+00	2026-07-21 18:09:05.468077+00
2f01124a-87cc-42c0-aff1-ff0045070c4d	89d9b3b2-2ed3-4714-b966-c97d97f4177e	2d6d452d-4915-4793-bf0b-ad7d43798e6f	رفع اشکالات و بازبینی	219	78	2026-07-16	approved	42df4646-393a-4de3-83d6-df4785b690c6	\N	63d1f5be-ec33-4a7e-9b6f-f4a47f05142a	2026-07-21 18:09:05.468077+00	2026-07-21 18:09:05.468077+00
2f01124a-87cc-42c0-aff1-ff0045070c4d	89d9b3b2-2ed3-4714-b966-c97d97f4177e	2d6d452d-4915-4793-bf0b-ad7d43798e6f	مستندسازی و نهایی‌سازی	156	78	2026-07-16	approved	42df4646-393a-4de3-83d6-df4785b690c6	\N	a526909e-abaf-4643-9415-9d5a85b5ecb6	2026-07-21 18:09:05.468077+00	2026-07-21 18:09:05.468077+00
2f01124a-87cc-42c0-aff1-ff0045070c4d	74b26e14-f3a0-40e6-ab6c-bec1020bfe24	b4d6dda1-b07b-48aa-b440-b2cbfe40ac0f	تست و اطمینان از عملکرد صحیح	36	27	2026-07-01	approved	42df4646-393a-4de3-83d6-df4785b690c6	\N	868fca14-c065-42cb-9f92-8c0753776713	2026-07-21 18:09:05.468077+00	2026-07-21 18:09:05.468077+00
2f01124a-87cc-42c0-aff1-ff0045070c4d	74b26e14-f3a0-40e6-ab6c-bec1020bfe24	b4d6dda1-b07b-48aa-b440-b2cbfe40ac0f	پیشرفت اولیه و بررسی نیازمندی‌ها	115	40	2026-07-04	approved	42df4646-393a-4de3-83d6-df4785b690c6	\N	ab9cba6d-b4fc-4e71-8b6e-8718ab316509	2026-07-21 18:09:05.468077+00	2026-07-21 18:09:05.468077+00
2f01124a-87cc-42c0-aff1-ff0045070c4d	cc885f19-3811-4c7a-964c-0406fd00b998	2d6d452d-4915-4793-bf0b-ad7d43798e6f	مستندسازی و نهایی‌سازی	90	33	2026-06-19	approved	42df4646-393a-4de3-83d6-df4785b690c6	\N	8c824ae8-fa7a-44b8-ba60-637b0245d9c8	2026-07-21 18:09:05.468077+00	2026-07-21 18:09:05.468077+00
2f01124a-87cc-42c0-aff1-ff0045070c4d	cc885f19-3811-4c7a-964c-0406fd00b998	2d6d452d-4915-4793-bf0b-ad7d43798e6f	پیاده‌سازی بخش اصلی	212	56	2026-06-23	submitted	\N	\N	9b62eb03-8dc2-4896-8e04-1236a0555ccc	2026-07-21 18:09:05.468077+00	2026-07-21 18:09:05.468077+00
2f01124a-87cc-42c0-aff1-ff0045070c4d	cc885f19-3811-4c7a-964c-0406fd00b998	2d6d452d-4915-4793-bf0b-ad7d43798e6f	پیاده‌سازی بخش اصلی	163	99	2026-06-21	approved	42df4646-393a-4de3-83d6-df4785b690c6	\N	bd9ba4fa-0266-4c71-a153-63a018f59b17	2026-07-21 18:09:05.468077+00	2026-07-21 18:09:05.468077+00
2f01124a-87cc-42c0-aff1-ff0045070c4d	cc885f19-3811-4c7a-964c-0406fd00b998	2d6d452d-4915-4793-bf0b-ad7d43798e6f	پیشرفت اولیه و بررسی نیازمندی‌ها	178	92	2026-06-28	approved	42df4646-393a-4de3-83d6-df4785b690c6	\N	b845dfc8-3ae4-4f83-a113-05a4a18b4d18	2026-07-21 18:09:05.468077+00	2026-07-21 18:09:05.468077+00
2f01124a-87cc-42c0-aff1-ff0045070c4d	511a015a-ce89-4d9a-a79e-2dabb8007116	02b5f471-cd3d-47ff-85ad-d22286b9e4b1	پیشرفت اولیه و بررسی نیازمندی‌ها	181	38	2026-07-08	approved	42df4646-393a-4de3-83d6-df4785b690c6	\N	5d3ca072-d2a8-4d5c-96c9-5d59f88a0f75	2026-07-21 18:09:05.468077+00	2026-07-21 18:09:05.468077+00
2f01124a-87cc-42c0-aff1-ff0045070c4d	511a015a-ce89-4d9a-a79e-2dabb8007116	02b5f471-cd3d-47ff-85ad-d22286b9e4b1	تست و اطمینان از عملکرد صحیح	199	48	2026-07-09	approved	42df4646-393a-4de3-83d6-df4785b690c6	\N	f202d356-91d8-46dd-9c58-721eb9e7414a	2026-07-21 18:09:05.468077+00	2026-07-21 18:09:05.468077+00
2f01124a-87cc-42c0-aff1-ff0045070c4d	33dd2852-7d50-40af-92f5-b025f0daad63	02b5f471-cd3d-47ff-85ad-d22286b9e4b1	رفع اشکالات و بازبینی	235	32	2026-06-25	approved	42df4646-393a-4de3-83d6-df4785b690c6	\N	bbd512a7-6192-4481-a074-13d266867c61	2026-07-21 18:09:05.468077+00	2026-07-21 18:09:05.468077+00
2f01124a-87cc-42c0-aff1-ff0045070c4d	33dd2852-7d50-40af-92f5-b025f0daad63	02b5f471-cd3d-47ff-85ad-d22286b9e4b1	رفع اشکالات و بازبینی	89	44	2026-06-28	approved	42df4646-393a-4de3-83d6-df4785b690c6	\N	a2861886-2b86-4ef6-8e7d-df05df653510	2026-07-21 18:09:05.468077+00	2026-07-21 18:09:05.468077+00
2f01124a-87cc-42c0-aff1-ff0045070c4d	ad5f018d-8a54-4e50-b298-5ecdcc04087c	b4d6dda1-b07b-48aa-b440-b2cbfe40ac0f	مستندسازی و نهایی‌سازی	57	24	2026-07-05	submitted	\N	\N	c50cbcea-182e-49e0-8d1a-b97947630708	2026-07-21 18:09:05.468077+00	2026-07-21 18:09:05.468077+00
2f01124a-87cc-42c0-aff1-ff0045070c4d	ad5f018d-8a54-4e50-b298-5ecdcc04087c	b4d6dda1-b07b-48aa-b440-b2cbfe40ac0f	تست و اطمینان از عملکرد صحیح	110	66	2026-07-06	approved	42df4646-393a-4de3-83d6-df4785b690c6	\N	6a522782-b995-4fe4-b4b9-206fff0560df	2026-07-21 18:09:05.468077+00	2026-07-21 18:09:05.468077+00
2f01124a-87cc-42c0-aff1-ff0045070c4d	4ffd77df-cb23-4521-bf92-82d47d6e91ae	02b5f471-cd3d-47ff-85ad-d22286b9e4b1	پیاده‌سازی بخش اصلی	145	29	2026-07-10	approved	42df4646-393a-4de3-83d6-df4785b690c6	\N	ddb8a1bc-8b7c-4813-bc86-a8c9d17a6e8a	2026-07-21 18:09:05.468077+00	2026-07-21 18:09:05.468077+00
2f01124a-87cc-42c0-aff1-ff0045070c4d	9d205cef-9b4b-4d81-95d2-b8e198751286	42df4646-393a-4de3-83d6-df4785b690c6	پیشرفت اولیه و بررسی نیازمندی‌ها	53	25	2026-06-21	approved	42df4646-393a-4de3-83d6-df4785b690c6	\N	30d4bef0-2ff4-4b9c-9298-8d98d692a293	2026-07-21 18:09:05.468077+00	2026-07-21 18:09:05.468077+00
2f01124a-87cc-42c0-aff1-ff0045070c4d	9d205cef-9b4b-4d81-95d2-b8e198751286	42df4646-393a-4de3-83d6-df4785b690c6	مستندسازی و نهایی‌سازی	40	52	2026-06-24	approved	42df4646-393a-4de3-83d6-df4785b690c6	\N	232abe1a-f6f5-4c6f-a607-6b90901deb42	2026-07-21 18:09:05.468077+00	2026-07-21 18:09:05.468077+00
2f01124a-87cc-42c0-aff1-ff0045070c4d	9d205cef-9b4b-4d81-95d2-b8e198751286	42df4646-393a-4de3-83d6-df4785b690c6	پیاده‌سازی بخش اصلی	53	81	2026-06-27	approved	42df4646-393a-4de3-83d6-df4785b690c6	\N	e7e00f90-0ddf-4817-b73e-c0834ee17f9c	2026-07-21 18:09:05.468077+00	2026-07-21 18:09:05.468077+00
2f01124a-87cc-42c0-aff1-ff0045070c4d	9d205cef-9b4b-4d81-95d2-b8e198751286	42df4646-393a-4de3-83d6-df4785b690c6	تست و اطمینان از عملکرد صحیح	161	84	2026-06-30	approved	42df4646-393a-4de3-83d6-df4785b690c6	\N	db4e06b1-f94e-4ab5-a261-06772a383e20	2026-07-21 18:09:05.468077+00	2026-07-21 18:09:05.468077+00
2f01124a-87cc-42c0-aff1-ff0045070c4d	7df5dce7-4e09-4a2e-8692-e24034783354	02b5f471-cd3d-47ff-85ad-d22286b9e4b1	پیاده‌سازی بخش اصلی	37	32	2026-06-18	approved	42df4646-393a-4de3-83d6-df4785b690c6	\N	4ffad977-634c-4602-b853-682b679e94b2	2026-07-21 18:09:05.468077+00	2026-07-21 18:09:05.468077+00
2f01124a-87cc-42c0-aff1-ff0045070c4d	7df5dce7-4e09-4a2e-8692-e24034783354	02b5f471-cd3d-47ff-85ad-d22286b9e4b1	مستندسازی و نهایی‌سازی	221	74	2026-06-22	approved	42df4646-393a-4de3-83d6-df4785b690c6	\N	a48660f5-0440-4067-85a5-db3ef214618e	2026-07-21 18:09:05.468077+00	2026-07-21 18:09:05.468077+00
2f01124a-87cc-42c0-aff1-ff0045070c4d	7df5dce7-4e09-4a2e-8692-e24034783354	02b5f471-cd3d-47ff-85ad-d22286b9e4b1	پیشرفت اولیه و بررسی نیازمندی‌ها	148	69	2026-06-22	approved	42df4646-393a-4de3-83d6-df4785b690c6	\N	30f57c89-b4b2-4cf0-ba81-01aade54e50f	2026-07-21 18:09:05.468077+00	2026-07-21 18:09:05.468077+00
2f01124a-87cc-42c0-aff1-ff0045070c4d	da734440-ef57-4d4c-a95b-36a7c6c91389	3683aa32-1561-4f36-90bf-d6402b4a66d8	پیاده‌سازی بخش اصلی	63	26	2026-07-16	approved	42df4646-393a-4de3-83d6-df4785b690c6	\N	8c2e493d-0563-4188-b785-1a48329c2c9c	2026-07-21 18:09:05.468077+00	2026-07-21 18:09:05.468077+00
2f01124a-87cc-42c0-aff1-ff0045070c4d	da734440-ef57-4d4c-a95b-36a7c6c91389	3683aa32-1561-4f36-90bf-d6402b4a66d8	پیشرفت اولیه و بررسی نیازمندی‌ها	179	76	2026-07-16	approved	42df4646-393a-4de3-83d6-df4785b690c6	\N	00e8464d-7c06-487f-8370-a7f59b99a9f3	2026-07-21 18:09:05.468077+00	2026-07-21 18:09:05.468077+00
2f01124a-87cc-42c0-aff1-ff0045070c4d	c0058059-00a2-4469-8044-eb027c094706	42df4646-393a-4de3-83d6-df4785b690c6	پیشرفت اولیه و بررسی نیازمندی‌ها	80	40	2026-07-16	approved	42df4646-393a-4de3-83d6-df4785b690c6	\N	0c2fa2e1-b107-4886-9049-e35335ccf3da	2026-07-21 18:09:05.468077+00	2026-07-21 18:09:05.468077+00
2f01124a-87cc-42c0-aff1-ff0045070c4d	c0058059-00a2-4469-8044-eb027c094706	42df4646-393a-4de3-83d6-df4785b690c6	پیشرفت اولیه و بررسی نیازمندی‌ها	237	60	2026-07-16	submitted	\N	\N	801b7525-e4b2-4190-b08a-e1b0d38010bd	2026-07-21 18:09:05.468077+00	2026-07-21 18:09:05.468077+00
2f01124a-87cc-42c0-aff1-ff0045070c4d	c0058059-00a2-4469-8044-eb027c094706	42df4646-393a-4de3-83d6-df4785b690c6	تست و اطمینان از عملکرد صحیح	42	75	2026-07-16	approved	42df4646-393a-4de3-83d6-df4785b690c6	\N	df7c547f-fd79-4335-8bfa-f5de184e3859	2026-07-21 18:09:05.468077+00	2026-07-21 18:09:05.468077+00
2f01124a-87cc-42c0-aff1-ff0045070c4d	877c6194-e4c1-480d-8d82-b24ca9993c25	72cdbbe8-b0fe-43f0-ab1a-f11f02a63e1f	تست و اطمینان از عملکرد صحیح	37	32	2026-07-11	approved	42df4646-393a-4de3-83d6-df4785b690c6	\N	20159b6e-dee1-4ccb-a636-87d9441eee70	2026-07-21 18:09:05.468077+00	2026-07-21 18:09:05.468077+00
2f01124a-87cc-42c0-aff1-ff0045070c4d	877c6194-e4c1-480d-8d82-b24ca9993c25	72cdbbe8-b0fe-43f0-ab1a-f11f02a63e1f	پیاده‌سازی بخش اصلی	120	52	2026-07-15	approved	42df4646-393a-4de3-83d6-df4785b690c6	\N	9d51926d-ef03-4a2a-983c-24a146e23bd3	2026-07-21 18:09:05.468077+00	2026-07-21 18:09:05.468077+00
2f01124a-87cc-42c0-aff1-ff0045070c4d	877c6194-e4c1-480d-8d82-b24ca9993c25	72cdbbe8-b0fe-43f0-ab1a-f11f02a63e1f	رفع اشکالات و بازبینی	101	100	2026-07-15	approved	42df4646-393a-4de3-83d6-df4785b690c6	\N	92a5ef65-4080-4f85-89e8-f9b7447ff823	2026-07-21 18:09:05.468077+00	2026-07-21 18:09:05.468077+00
2f01124a-87cc-42c0-aff1-ff0045070c4d	877c6194-e4c1-480d-8d82-b24ca9993c25	72cdbbe8-b0fe-43f0-ab1a-f11f02a63e1f	پیشرفت اولیه و بررسی نیازمندی‌ها	187	100	2026-07-16	approved	42df4646-393a-4de3-83d6-df4785b690c6	\N	530956db-7b47-484c-af2b-6027338333e0	2026-07-21 18:09:05.468077+00	2026-07-21 18:09:05.468077+00
2f01124a-87cc-42c0-aff1-ff0045070c4d	ec2e7f1a-b316-428f-97f1-22bc8d50b93b	c873d894-cb10-4d12-a1dd-f989a1851641	رفع اشکالات و بازبینی	43	27	2026-07-16	submitted	\N	\N	2df93703-50be-4a99-ba56-636ba7028eca	2026-07-21 18:09:05.468077+00	2026-07-21 18:09:05.468077+00
2f01124a-87cc-42c0-aff1-ff0045070c4d	ec2e7f1a-b316-428f-97f1-22bc8d50b93b	c873d894-cb10-4d12-a1dd-f989a1851641	مستندسازی و نهایی‌سازی	183	70	2026-07-16	approved	c873d894-cb10-4d12-a1dd-f989a1851641	\N	def851cf-2d5e-4c6b-8fba-4aef1113c970	2026-07-21 18:09:05.468077+00	2026-07-21 18:09:05.468077+00
2f01124a-87cc-42c0-aff1-ff0045070c4d	b850b192-b6d8-4264-9f27-dfeacb7e56cd	00a2a3bf-94c3-4ef6-a94b-bfb72866c1cd	پیشرفت اولیه و بررسی نیازمندی‌ها	54	27	2026-07-16	approved	c873d894-cb10-4d12-a1dd-f989a1851641	\N	322df072-0deb-4b96-a120-65c2bc576423	2026-07-21 18:09:05.468077+00	2026-07-21 18:09:05.468077+00
2f01124a-87cc-42c0-aff1-ff0045070c4d	b850b192-b6d8-4264-9f27-dfeacb7e56cd	00a2a3bf-94c3-4ef6-a94b-bfb72866c1cd	رفع اشکالات و بازبینی	120	80	2026-07-16	approved	c873d894-cb10-4d12-a1dd-f989a1851641	\N	42308359-d656-404c-acb6-76c12a2b2b8d	2026-07-21 18:09:05.468077+00	2026-07-21 18:09:05.468077+00
2f01124a-87cc-42c0-aff1-ff0045070c4d	b850b192-b6d8-4264-9f27-dfeacb7e56cd	00a2a3bf-94c3-4ef6-a94b-bfb72866c1cd	مستندسازی و نهایی‌سازی	163	93	2026-07-16	approved	c873d894-cb10-4d12-a1dd-f989a1851641	\N	a68d32ca-74b4-41f5-8ee0-b8d53a7ca9ce	2026-07-21 18:09:05.468077+00	2026-07-21 18:09:05.468077+00
2f01124a-87cc-42c0-aff1-ff0045070c4d	ce9b5818-ce57-444b-ba8e-e0f0be400eef	9d19d89f-4c3d-4d3d-baf1-a4e8898f6a75	پیاده‌سازی بخش اصلی	156	24	2026-07-16	approved	c873d894-cb10-4d12-a1dd-f989a1851641	\N	4ed7d18a-05fb-4f68-95e4-87ff202d0df5	2026-07-21 18:09:05.468077+00	2026-07-21 18:09:05.468077+00
2f01124a-87cc-42c0-aff1-ff0045070c4d	95e30330-d97b-4152-86b7-986b8a209102	eafb37ce-9111-4c51-91b5-dac320a98501	رفع اشکالات و بازبینی	186	26	2026-07-07	approved	c873d894-cb10-4d12-a1dd-f989a1851641	\N	c5f5ae3c-3f0e-416c-a6be-f22ca92ee947	2026-07-21 18:09:05.468077+00	2026-07-21 18:09:05.468077+00
2f01124a-87cc-42c0-aff1-ff0045070c4d	95e30330-d97b-4152-86b7-986b8a209102	eafb37ce-9111-4c51-91b5-dac320a98501	پیشرفت اولیه و بررسی نیازمندی‌ها	130	52	2026-07-09	approved	c873d894-cb10-4d12-a1dd-f989a1851641	\N	262d0fd8-c622-4a73-9e27-e86e320f0fc8	2026-07-21 18:09:05.468077+00	2026-07-21 18:09:05.468077+00
2f01124a-87cc-42c0-aff1-ff0045070c4d	95e30330-d97b-4152-86b7-986b8a209102	eafb37ce-9111-4c51-91b5-dac320a98501	پیاده‌سازی بخش اصلی	213	90	2026-07-15	approved	c873d894-cb10-4d12-a1dd-f989a1851641	\N	55a9d8cc-fbab-47ad-b256-9aad25d9fcae	2026-07-21 18:09:05.468077+00	2026-07-21 18:09:05.468077+00
2f01124a-87cc-42c0-aff1-ff0045070c4d	95e30330-d97b-4152-86b7-986b8a209102	eafb37ce-9111-4c51-91b5-dac320a98501	تست و اطمینان از عملکرد صحیح	41	100	2026-07-10	approved	c873d894-cb10-4d12-a1dd-f989a1851641	\N	979d8ac6-fbe4-4bcc-a4a5-0707a5b820f5	2026-07-21 18:09:05.468077+00	2026-07-21 18:09:05.468077+00
2f01124a-87cc-42c0-aff1-ff0045070c4d	a919556e-210a-44f8-8f54-89302186915f	fe42788d-ef87-41ef-8255-9e64e697d040	تست و اطمینان از عملکرد صحیح	198	38	2026-07-12	approved	c873d894-cb10-4d12-a1dd-f989a1851641	\N	2913f40b-ab30-43d1-87c6-4d68b43176c1	2026-07-21 18:09:05.468077+00	2026-07-21 18:09:05.468077+00
2f01124a-87cc-42c0-aff1-ff0045070c4d	fd51ed90-e9b9-4430-b02c-2e4212cef587	9d19d89f-4c3d-4d3d-baf1-a4e8898f6a75	پیشرفت اولیه و بررسی نیازمندی‌ها	165	21	2026-07-16	approved	c873d894-cb10-4d12-a1dd-f989a1851641	\N	87ae7ecf-4d45-4c39-951b-a61048174f81	2026-07-21 18:09:05.468077+00	2026-07-21 18:09:05.468077+00
2f01124a-87cc-42c0-aff1-ff0045070c4d	fd51ed90-e9b9-4430-b02c-2e4212cef587	9d19d89f-4c3d-4d3d-baf1-a4e8898f6a75	مستندسازی و نهایی‌سازی	153	72	2026-07-16	approved	c873d894-cb10-4d12-a1dd-f989a1851641	\N	cd54794d-de0d-4f7f-bee3-12589716f6a4	2026-07-21 18:09:05.468077+00	2026-07-21 18:09:05.468077+00
2f01124a-87cc-42c0-aff1-ff0045070c4d	6da9a18f-44df-4f4d-a84a-a4a9da8d99ab	eafb37ce-9111-4c51-91b5-dac320a98501	پیاده‌سازی بخش اصلی	56	32	2026-06-26	submitted	\N	\N	39b137e1-4c1b-45be-a224-cec432d42ff8	2026-07-21 18:09:05.468077+00	2026-07-21 18:09:05.468077+00
2f01124a-87cc-42c0-aff1-ff0045070c4d	6da9a18f-44df-4f4d-a84a-a4a9da8d99ab	eafb37ce-9111-4c51-91b5-dac320a98501	تست و اطمینان از عملکرد صحیح	137	78	2026-06-29	approved	c873d894-cb10-4d12-a1dd-f989a1851641	\N	d29c0999-ba01-4971-872a-a0061d344389	2026-07-21 18:09:05.468077+00	2026-07-21 18:09:05.468077+00
2f01124a-87cc-42c0-aff1-ff0045070c4d	cc52b7d2-6475-47d6-87f2-ea48d7f808b1	00a2a3bf-94c3-4ef6-a94b-bfb72866c1cd	رفع اشکالات و بازبینی	105	34	2026-07-16	approved	c873d894-cb10-4d12-a1dd-f989a1851641	\N	bf56596c-8887-44e1-9497-a2c28ddb4383	2026-07-21 18:09:05.468077+00	2026-07-21 18:09:05.468077+00
2f01124a-87cc-42c0-aff1-ff0045070c4d	cc52b7d2-6475-47d6-87f2-ea48d7f808b1	00a2a3bf-94c3-4ef6-a94b-bfb72866c1cd	مستندسازی و نهایی‌سازی	209	72	2026-07-16	approved	c873d894-cb10-4d12-a1dd-f989a1851641	\N	7ea608e9-1fdf-4474-a1f8-db50b3b162ad	2026-07-21 18:09:05.468077+00	2026-07-21 18:09:05.468077+00
2f01124a-87cc-42c0-aff1-ff0045070c4d	ee88e535-72e7-4e1b-a356-d8a44c15ffd4	9d19d89f-4c3d-4d3d-baf1-a4e8898f6a75	مستندسازی و نهایی‌سازی	191	26	2026-07-01	submitted	\N	\N	4edb0489-a7de-4275-a1e8-dd4bb6597799	2026-07-21 18:09:05.468077+00	2026-07-21 18:09:05.468077+00
2f01124a-87cc-42c0-aff1-ff0045070c4d	ee88e535-72e7-4e1b-a356-d8a44c15ffd4	9d19d89f-4c3d-4d3d-baf1-a4e8898f6a75	رفع اشکالات و بازبینی	205	62	2026-07-03	approved	c873d894-cb10-4d12-a1dd-f989a1851641	\N	4d46d039-d83a-4936-b9ad-fc877ac107f5	2026-07-21 18:09:05.468077+00	2026-07-21 18:09:05.468077+00
2f01124a-87cc-42c0-aff1-ff0045070c4d	ee88e535-72e7-4e1b-a356-d8a44c15ffd4	9d19d89f-4c3d-4d3d-baf1-a4e8898f6a75	پیاده‌سازی بخش اصلی	158	100	2026-07-05	submitted	\N	\N	f9112129-9516-45a5-afdc-1ca0d4cd570f	2026-07-21 18:09:05.468077+00	2026-07-21 18:09:05.468077+00
2f01124a-87cc-42c0-aff1-ff0045070c4d	c6ee9a42-39a3-498f-b15b-e3fb91cf5848	eafb37ce-9111-4c51-91b5-dac320a98501	رفع اشکالات و بازبینی	173	35	2026-06-28	approved	c873d894-cb10-4d12-a1dd-f989a1851641	\N	47ee13ad-2326-4abc-9728-f198dfe5143b	2026-07-21 18:09:05.468077+00	2026-07-21 18:09:05.468077+00
2f01124a-87cc-42c0-aff1-ff0045070c4d	c6ee9a42-39a3-498f-b15b-e3fb91cf5848	eafb37ce-9111-4c51-91b5-dac320a98501	مستندسازی و نهایی‌سازی	103	66	2026-07-02	approved	c873d894-cb10-4d12-a1dd-f989a1851641	\N	a7f90c5b-fc6e-4b66-ab03-a441d069fce9	2026-07-21 18:09:05.468077+00	2026-07-21 18:09:05.468077+00
2f01124a-87cc-42c0-aff1-ff0045070c4d	c6ee9a42-39a3-498f-b15b-e3fb91cf5848	eafb37ce-9111-4c51-91b5-dac320a98501	مستندسازی و نهایی‌سازی	57	60	2026-06-30	approved	c873d894-cb10-4d12-a1dd-f989a1851641	\N	e3a782f7-1697-4408-8ef4-02f81d63e5da	2026-07-21 18:09:05.468077+00	2026-07-21 18:09:05.468077+00
2f01124a-87cc-42c0-aff1-ff0045070c4d	841e47b7-c437-4bfe-b01c-64dccc205269	eafb37ce-9111-4c51-91b5-dac320a98501	پیشرفت اولیه و بررسی نیازمندی‌ها	81	28	2026-06-21	approved	c873d894-cb10-4d12-a1dd-f989a1851641	\N	dadef6ca-9476-4bd8-aa75-6b57713c299c	2026-07-21 18:09:05.468077+00	2026-07-21 18:09:05.468077+00
2f01124a-87cc-42c0-aff1-ff0045070c4d	841e47b7-c437-4bfe-b01c-64dccc205269	eafb37ce-9111-4c51-91b5-dac320a98501	رفع اشکالات و بازبینی	67	42	2026-06-23	submitted	\N	\N	e6e75801-a1be-4c67-b08f-9ad29ac92fee	2026-07-21 18:09:05.468077+00	2026-07-21 18:09:05.468077+00
2f01124a-87cc-42c0-aff1-ff0045070c4d	841e47b7-c437-4bfe-b01c-64dccc205269	eafb37ce-9111-4c51-91b5-dac320a98501	مستندسازی و نهایی‌سازی	38	93	2026-06-27	approved	c873d894-cb10-4d12-a1dd-f989a1851641	\N	d08a337a-8eae-43a5-95e8-66cdf1e80153	2026-07-21 18:09:05.468077+00	2026-07-21 18:09:05.468077+00
2f01124a-87cc-42c0-aff1-ff0045070c4d	841e47b7-c437-4bfe-b01c-64dccc205269	eafb37ce-9111-4c51-91b5-dac320a98501	مستندسازی و نهایی‌سازی	87	100	2026-07-03	approved	c873d894-cb10-4d12-a1dd-f989a1851641	\N	7478ae51-a3ea-4932-9caf-c7c4973ad26b	2026-07-21 18:09:05.468077+00	2026-07-21 18:09:05.468077+00
2f01124a-87cc-42c0-aff1-ff0045070c4d	48394b83-46f8-4451-bd4c-1d86ca712286	47bf13da-40a8-4016-b601-d596b7a29a50	رفع اشکالات و بازبینی	207	21	2026-07-16	approved	c873d894-cb10-4d12-a1dd-f989a1851641	\N	1c0ca5e4-760f-4a13-88ed-7ca2d47aee51	2026-07-21 18:09:05.468077+00	2026-07-21 18:09:05.468077+00
2f01124a-87cc-42c0-aff1-ff0045070c4d	48394b83-46f8-4451-bd4c-1d86ca712286	47bf13da-40a8-4016-b601-d596b7a29a50	رفع اشکالات و بازبینی	171	42	2026-07-16	approved	c873d894-cb10-4d12-a1dd-f989a1851641	\N	3149544e-6d93-4a41-aa08-12d989c700c3	2026-07-21 18:09:05.468077+00	2026-07-21 18:09:05.468077+00
2f01124a-87cc-42c0-aff1-ff0045070c4d	48394b83-46f8-4451-bd4c-1d86ca712286	47bf13da-40a8-4016-b601-d596b7a29a50	پیاده‌سازی بخش اصلی	188	100	2026-07-16	submitted	\N	\N	86846401-3274-487b-82be-1d268751e27c	2026-07-21 18:09:05.468077+00	2026-07-21 18:09:05.468077+00
2f01124a-87cc-42c0-aff1-ff0045070c4d	48394b83-46f8-4451-bd4c-1d86ca712286	47bf13da-40a8-4016-b601-d596b7a29a50	رفع اشکالات و بازبینی	223	100	2026-07-16	submitted	\N	\N	271e688e-3015-494c-b67d-22d54a167aa5	2026-07-21 18:09:05.468077+00	2026-07-21 18:09:05.468077+00
2f01124a-87cc-42c0-aff1-ff0045070c4d	b4b5d1c4-60d2-43c9-be43-3b46bc5d1ba8	9d19d89f-4c3d-4d3d-baf1-a4e8898f6a75	رفع اشکالات و بازبینی	144	25	2026-07-16	approved	c873d894-cb10-4d12-a1dd-f989a1851641	\N	f79add85-f6a9-47a3-896d-4d3eb2d5c5d5	2026-07-21 18:09:05.468077+00	2026-07-21 18:09:05.468077+00
2f01124a-87cc-42c0-aff1-ff0045070c4d	b4b5d1c4-60d2-43c9-be43-3b46bc5d1ba8	9d19d89f-4c3d-4d3d-baf1-a4e8898f6a75	پیاده‌سازی بخش اصلی	74	72	2026-07-16	approved	c873d894-cb10-4d12-a1dd-f989a1851641	\N	f4db22fa-8aad-43e0-8e5c-f56ab8449229	2026-07-21 18:09:05.468077+00	2026-07-21 18:09:05.468077+00
2f01124a-87cc-42c0-aff1-ff0045070c4d	4ec0e47c-9054-40f7-a79f-48923ea626e3	fe42788d-ef87-41ef-8255-9e64e697d040	پیشرفت اولیه و بررسی نیازمندی‌ها	139	28	2026-07-16	approved	c873d894-cb10-4d12-a1dd-f989a1851641	\N	c91cdc07-9c5d-49a2-8e6f-69fff84e652d	2026-07-21 18:09:05.468077+00	2026-07-21 18:09:05.468077+00
2f01124a-87cc-42c0-aff1-ff0045070c4d	b7c81712-58af-48e4-9fbd-f5f404bdc5b1	c873d894-cb10-4d12-a1dd-f989a1851641	رفع اشکالات و بازبینی	31	30	2026-07-16	approved	c873d894-cb10-4d12-a1dd-f989a1851641	\N	bb12b75c-cfa1-46a5-a53a-a6255f5081dc	2026-07-21 18:09:05.468077+00	2026-07-21 18:09:05.468077+00
2f01124a-87cc-42c0-aff1-ff0045070c4d	b7c81712-58af-48e4-9fbd-f5f404bdc5b1	c873d894-cb10-4d12-a1dd-f989a1851641	پیاده‌سازی بخش اصلی	40	48	2026-07-16	submitted	\N	\N	a0d77aec-893f-434f-8a76-a19ce5bbc3f3	2026-07-21 18:09:05.468077+00	2026-07-21 18:09:05.468077+00
2f01124a-87cc-42c0-aff1-ff0045070c4d	b7c81712-58af-48e4-9fbd-f5f404bdc5b1	c873d894-cb10-4d12-a1dd-f989a1851641	مستندسازی و نهایی‌سازی	199	87	2026-07-16	approved	c873d894-cb10-4d12-a1dd-f989a1851641	\N	99fd970e-d567-4359-93e8-b60c2de9a823	2026-07-21 18:09:05.468077+00	2026-07-21 18:09:05.468077+00
2f01124a-87cc-42c0-aff1-ff0045070c4d	a566047d-fe8e-4f59-9d9a-145193539922	eafb37ce-9111-4c51-91b5-dac320a98501	پیشرفت اولیه و بررسی نیازمندی‌ها	230	30	2026-07-16	approved	c873d894-cb10-4d12-a1dd-f989a1851641	\N	9bacc5c2-96fc-40f5-a73e-39c31afe9486	2026-07-21 18:09:05.468077+00	2026-07-21 18:09:05.468077+00
2f01124a-87cc-42c0-aff1-ff0045070c4d	a566047d-fe8e-4f59-9d9a-145193539922	eafb37ce-9111-4c51-91b5-dac320a98501	پیاده‌سازی بخش اصلی	163	44	2026-07-16	approved	c873d894-cb10-4d12-a1dd-f989a1851641	\N	cde267b0-0dee-4d0b-a4aa-4f7f29ca3b48	2026-07-21 18:09:05.468077+00	2026-07-21 18:09:05.468077+00
2f01124a-87cc-42c0-aff1-ff0045070c4d	a566047d-fe8e-4f59-9d9a-145193539922	eafb37ce-9111-4c51-91b5-dac320a98501	تست و اطمینان از عملکرد صحیح	169	100	2026-07-16	approved	c873d894-cb10-4d12-a1dd-f989a1851641	\N	04e3c035-0bf3-450c-b5ed-b69873e8cec7	2026-07-21 18:09:05.468077+00	2026-07-21 18:09:05.468077+00
2f01124a-87cc-42c0-aff1-ff0045070c4d	a566047d-fe8e-4f59-9d9a-145193539922	eafb37ce-9111-4c51-91b5-dac320a98501	پیشرفت اولیه و بررسی نیازمندی‌ها	119	100	2026-07-16	approved	c873d894-cb10-4d12-a1dd-f989a1851641	\N	576cb660-7b0c-4c2a-98e7-c844303bb89d	2026-07-21 18:09:05.468077+00	2026-07-21 18:09:05.468077+00
2f01124a-87cc-42c0-aff1-ff0045070c4d	ea2e0768-1997-4398-be4d-3d4df2df9633	47bf13da-40a8-4016-b601-d596b7a29a50	رفع اشکالات و بازبینی	122	29	2026-07-16	approved	c873d894-cb10-4d12-a1dd-f989a1851641	\N	cb616f1b-8d9e-4ffc-900e-26b9dbb15df5	2026-07-21 18:09:05.468077+00	2026-07-21 18:09:05.468077+00
2f01124a-87cc-42c0-aff1-ff0045070c4d	ea2e0768-1997-4398-be4d-3d4df2df9633	47bf13da-40a8-4016-b601-d596b7a29a50	مستندسازی و نهایی‌سازی	165	70	2026-07-16	approved	c873d894-cb10-4d12-a1dd-f989a1851641	\N	bf233491-110f-4935-a5bd-d6eb2e62d4b5	2026-07-21 18:09:05.468077+00	2026-07-21 18:09:05.468077+00
2f01124a-87cc-42c0-aff1-ff0045070c4d	7d6ff1ad-18a8-4940-a918-a0af6cffebcf	ae9392d2-7669-44be-a429-889e449b3eb1	رفع اشکالات و بازبینی	144	27	2026-06-16	approved	c873d894-cb10-4d12-a1dd-f989a1851641	\N	b20dfae7-cbac-4e8e-956d-78fe0a69dae5	2026-07-21 18:09:05.468077+00	2026-07-21 18:09:05.468077+00
2f01124a-87cc-42c0-aff1-ff0045070c4d	0283082f-3a5c-462c-ad41-2f308b5fadec	c873d894-cb10-4d12-a1dd-f989a1851641	رفع اشکالات و بازبینی	127	23	2026-06-25	approved	c873d894-cb10-4d12-a1dd-f989a1851641	\N	c9247627-c5e4-4ee7-bf78-460e9850ef2a	2026-07-21 18:09:05.468077+00	2026-07-21 18:09:05.468077+00
2f01124a-87cc-42c0-aff1-ff0045070c4d	0283082f-3a5c-462c-ad41-2f308b5fadec	c873d894-cb10-4d12-a1dd-f989a1851641	رفع اشکالات و بازبینی	36	72	2026-06-29	approved	c873d894-cb10-4d12-a1dd-f989a1851641	\N	762381a2-b462-4cbb-b888-028d4993e6be	2026-07-21 18:09:05.468077+00	2026-07-21 18:09:05.468077+00
2f01124a-87cc-42c0-aff1-ff0045070c4d	922b4b1b-1432-4507-92e3-5f4e0f83033f	fe42788d-ef87-41ef-8255-9e64e697d040	رفع اشکالات و بازبینی	196	26	2026-07-10	approved	c873d894-cb10-4d12-a1dd-f989a1851641	\N	bd9ab3f3-65c9-4657-9723-a9f3dabbfdff	2026-07-21 18:09:05.468077+00	2026-07-21 18:09:05.468077+00
2f01124a-87cc-42c0-aff1-ff0045070c4d	922b4b1b-1432-4507-92e3-5f4e0f83033f	fe42788d-ef87-41ef-8255-9e64e697d040	پیشرفت اولیه و بررسی نیازمندی‌ها	72	74	2026-07-13	approved	c873d894-cb10-4d12-a1dd-f989a1851641	\N	2805a9e4-1794-44b8-a109-4123a4889413	2026-07-21 18:09:05.468077+00	2026-07-21 18:09:05.468077+00
2f01124a-87cc-42c0-aff1-ff0045070c4d	922b4b1b-1432-4507-92e3-5f4e0f83033f	fe42788d-ef87-41ef-8255-9e64e697d040	پیاده‌سازی بخش اصلی	201	100	2026-07-12	approved	c873d894-cb10-4d12-a1dd-f989a1851641	\N	7c9fa0cc-a77a-49e3-871b-907c03588034	2026-07-21 18:09:05.468077+00	2026-07-21 18:09:05.468077+00
2f01124a-87cc-42c0-aff1-ff0045070c4d	87be796f-2f89-4a96-9e4f-db1eacb49eb9	9d19d89f-4c3d-4d3d-baf1-a4e8898f6a75	پیاده‌سازی بخش اصلی	167	33	2026-06-25	submitted	\N	\N	a12482a1-7166-4715-9df9-55881e5c13c4	2026-07-21 18:09:05.468077+00	2026-07-21 18:09:05.468077+00
2f01124a-87cc-42c0-aff1-ff0045070c4d	87be796f-2f89-4a96-9e4f-db1eacb49eb9	9d19d89f-4c3d-4d3d-baf1-a4e8898f6a75	پیاده‌سازی بخش اصلی	36	68	2026-06-26	submitted	\N	\N	bc4cca21-1849-4a65-8aa6-bc1b70816e44	2026-07-21 18:09:05.468077+00	2026-07-21 18:09:05.468077+00
2f01124a-87cc-42c0-aff1-ff0045070c4d	68bd9a3a-84ff-477f-b0e4-ff67b3840f97	9d19d89f-4c3d-4d3d-baf1-a4e8898f6a75	پیشرفت اولیه و بررسی نیازمندی‌ها	48	21	2026-07-16	approved	c873d894-cb10-4d12-a1dd-f989a1851641	\N	48e9712a-e390-41a6-ab07-5c66314b469e	2026-07-21 18:09:05.468077+00	2026-07-21 18:09:05.468077+00
2f01124a-87cc-42c0-aff1-ff0045070c4d	68bd9a3a-84ff-477f-b0e4-ff67b3840f97	9d19d89f-4c3d-4d3d-baf1-a4e8898f6a75	رفع اشکالات و بازبینی	172	44	2026-07-16	approved	c873d894-cb10-4d12-a1dd-f989a1851641	\N	fa2fc44d-77f4-4779-afa2-87c367ab80cc	2026-07-21 18:09:05.468077+00	2026-07-21 18:09:05.468077+00
2f01124a-87cc-42c0-aff1-ff0045070c4d	68bd9a3a-84ff-477f-b0e4-ff67b3840f97	9d19d89f-4c3d-4d3d-baf1-a4e8898f6a75	رفع اشکالات و بازبینی	134	96	2026-07-16	approved	c873d894-cb10-4d12-a1dd-f989a1851641	\N	90fc8d37-7737-4e5b-b6bc-bc6dc2180f69	2026-07-21 18:09:05.468077+00	2026-07-21 18:09:05.468077+00
2f01124a-87cc-42c0-aff1-ff0045070c4d	a86d0eb8-c92f-4e6a-8bd4-e72bbcc277fd	c873d894-cb10-4d12-a1dd-f989a1851641	پیشرفت اولیه و بررسی نیازمندی‌ها	129	23	2026-07-16	approved	c873d894-cb10-4d12-a1dd-f989a1851641	\N	af96a88d-e1e6-45b7-aee2-83f52c306a3f	2026-07-21 18:09:05.468077+00	2026-07-21 18:09:05.468077+00
2f01124a-87cc-42c0-aff1-ff0045070c4d	a86d0eb8-c92f-4e6a-8bd4-e72bbcc277fd	c873d894-cb10-4d12-a1dd-f989a1851641	مستندسازی و نهایی‌سازی	46	76	2026-07-16	approved	c873d894-cb10-4d12-a1dd-f989a1851641	\N	d292920c-46a4-42fa-8fb4-d331261e56f1	2026-07-21 18:09:05.468077+00	2026-07-21 18:09:05.468077+00
2f01124a-87cc-42c0-aff1-ff0045070c4d	a86d0eb8-c92f-4e6a-8bd4-e72bbcc277fd	c873d894-cb10-4d12-a1dd-f989a1851641	پیشرفت اولیه و بررسی نیازمندی‌ها	121	100	2026-07-16	submitted	\N	\N	05cb66d0-3a57-40fd-9332-d9edeecd10c0	2026-07-21 18:09:05.468077+00	2026-07-21 18:09:05.468077+00
2f01124a-87cc-42c0-aff1-ff0045070c4d	a86d0eb8-c92f-4e6a-8bd4-e72bbcc277fd	c873d894-cb10-4d12-a1dd-f989a1851641	رفع اشکالات و بازبینی	185	88	2026-07-16	approved	c873d894-cb10-4d12-a1dd-f989a1851641	\N	8e126d18-6e37-4a73-ad7b-0db13f65c883	2026-07-21 18:09:05.468077+00	2026-07-21 18:09:05.468077+00
2f01124a-87cc-42c0-aff1-ff0045070c4d	62cc763a-f9d0-4d35-af04-ebeb88a4381d	9d19d89f-4c3d-4d3d-baf1-a4e8898f6a75	پیشرفت اولیه و بررسی نیازمندی‌ها	151	25	2026-07-16	approved	c873d894-cb10-4d12-a1dd-f989a1851641	\N	6becd806-3083-4387-8c32-23a962671d58	2026-07-21 18:09:05.468077+00	2026-07-21 18:09:05.468077+00
2f01124a-87cc-42c0-aff1-ff0045070c4d	62cc763a-f9d0-4d35-af04-ebeb88a4381d	9d19d89f-4c3d-4d3d-baf1-a4e8898f6a75	تست و اطمینان از عملکرد صحیح	233	74	2026-07-16	approved	c873d894-cb10-4d12-a1dd-f989a1851641	\N	a48f0269-cdb2-4dcb-991f-7c7bed3647ab	2026-07-21 18:09:05.468077+00	2026-07-21 18:09:05.468077+00
2f01124a-87cc-42c0-aff1-ff0045070c4d	62cc763a-f9d0-4d35-af04-ebeb88a4381d	9d19d89f-4c3d-4d3d-baf1-a4e8898f6a75	پیاده‌سازی بخش اصلی	106	100	2026-07-16	submitted	\N	\N	aa86f417-ea83-4d6b-a53b-c5177514d684	2026-07-21 18:09:05.468077+00	2026-07-21 18:09:05.468077+00
2f01124a-87cc-42c0-aff1-ff0045070c4d	d7ac0009-d8b7-4e1e-b510-9fd3293200fb	00a2a3bf-94c3-4ef6-a94b-bfb72866c1cd	مستندسازی و نهایی‌سازی	66	23	2026-07-16	approved	c873d894-cb10-4d12-a1dd-f989a1851641	\N	8ea7a065-d5ea-46b7-899b-4323f62b9c1d	2026-07-21 18:09:05.468077+00	2026-07-21 18:09:05.468077+00
2f01124a-87cc-42c0-aff1-ff0045070c4d	d7ac0009-d8b7-4e1e-b510-9fd3293200fb	00a2a3bf-94c3-4ef6-a94b-bfb72866c1cd	مستندسازی و نهایی‌سازی	130	74	2026-07-16	approved	c873d894-cb10-4d12-a1dd-f989a1851641	\N	6f8f1189-592d-4ff6-84ed-69143a08a5ba	2026-07-21 18:09:05.468077+00	2026-07-21 18:09:05.468077+00
2f01124a-87cc-42c0-aff1-ff0045070c4d	d7ac0009-d8b7-4e1e-b510-9fd3293200fb	00a2a3bf-94c3-4ef6-a94b-bfb72866c1cd	رفع اشکالات و بازبینی	84	99	2026-07-16	approved	c873d894-cb10-4d12-a1dd-f989a1851641	\N	46c64422-275e-44b9-a7b0-33769cda5b37	2026-07-21 18:09:05.468077+00	2026-07-21 18:09:05.468077+00
2f01124a-87cc-42c0-aff1-ff0045070c4d	13555bd2-9129-4fd3-827a-fac91d5cd82e	47bf13da-40a8-4016-b601-d596b7a29a50	پیاده‌سازی بخش اصلی	86	39	2026-06-17	approved	c873d894-cb10-4d12-a1dd-f989a1851641	\N	216b854b-9eb6-46f6-a3dd-90d16d6d0946	2026-07-21 18:09:05.468077+00	2026-07-21 18:09:05.468077+00
2f01124a-87cc-42c0-aff1-ff0045070c4d	13555bd2-9129-4fd3-827a-fac91d5cd82e	47bf13da-40a8-4016-b601-d596b7a29a50	پیاده‌سازی بخش اصلی	59	50	2026-06-20	approved	c873d894-cb10-4d12-a1dd-f989a1851641	\N	b97567a5-61fb-4988-a05e-8e8863c19b09	2026-07-21 18:09:05.468077+00	2026-07-21 18:09:05.468077+00
2f01124a-87cc-42c0-aff1-ff0045070c4d	5b7005e9-e790-4f14-8208-75fad254a4d3	47bf13da-40a8-4016-b601-d596b7a29a50	مستندسازی و نهایی‌سازی	48	29	2026-07-16	approved	c873d894-cb10-4d12-a1dd-f989a1851641	\N	2c34d622-0009-4327-b676-73ab86110eda	2026-07-21 18:09:05.468077+00	2026-07-21 18:09:05.468077+00
2f01124a-87cc-42c0-aff1-ff0045070c4d	e2578e49-7df6-4fe8-aaca-f584207c933d	fe42788d-ef87-41ef-8255-9e64e697d040	پیشرفت اولیه و بررسی نیازمندی‌ها	80	38	2026-07-16	approved	c873d894-cb10-4d12-a1dd-f989a1851641	\N	775b3a65-407a-4033-a810-467900394325	2026-07-21 18:09:05.468077+00	2026-07-21 18:09:05.468077+00
2f01124a-87cc-42c0-aff1-ff0045070c4d	738811ca-d209-4317-ba61-71d8c4982638	00a2a3bf-94c3-4ef6-a94b-bfb72866c1cd	پیاده‌سازی بخش اصلی	55	29	2026-07-16	approved	c873d894-cb10-4d12-a1dd-f989a1851641	\N	e5db5694-0a40-45de-960d-f523ec2f90cc	2026-07-21 18:09:05.468077+00	2026-07-21 18:09:05.468077+00
2f01124a-87cc-42c0-aff1-ff0045070c4d	738811ca-d209-4317-ba61-71d8c4982638	00a2a3bf-94c3-4ef6-a94b-bfb72866c1cd	رفع اشکالات و بازبینی	154	68	2026-07-16	submitted	\N	\N	7a9c585f-3ccb-4798-94e7-e65ff99e5ec3	2026-07-21 18:09:05.468077+00	2026-07-21 18:09:05.468077+00
2f01124a-87cc-42c0-aff1-ff0045070c4d	738811ca-d209-4317-ba61-71d8c4982638	00a2a3bf-94c3-4ef6-a94b-bfb72866c1cd	رفع اشکالات و بازبینی	207	100	2026-07-16	approved	c873d894-cb10-4d12-a1dd-f989a1851641	\N	349f9a7a-2e38-43b9-a07e-528e9fbda981	2026-07-21 18:09:05.468077+00	2026-07-21 18:09:05.468077+00
2f01124a-87cc-42c0-aff1-ff0045070c4d	738811ca-d209-4317-ba61-71d8c4982638	00a2a3bf-94c3-4ef6-a94b-bfb72866c1cd	رفع اشکالات و بازبینی	236	100	2026-07-16	approved	c873d894-cb10-4d12-a1dd-f989a1851641	\N	98efdbdc-689c-49a5-94b0-04ff94a8fe99	2026-07-21 18:09:05.468077+00	2026-07-21 18:09:05.468077+00
2f01124a-87cc-42c0-aff1-ff0045070c4d	44536812-0089-4587-80e0-7163e2463207	47bf13da-40a8-4016-b601-d596b7a29a50	پیشرفت اولیه و بررسی نیازمندی‌ها	110	27	2026-06-29	approved	c873d894-cb10-4d12-a1dd-f989a1851641	\N	5b0c9c4e-cfeb-4df5-9f45-de73d3997566	2026-07-21 18:09:05.468077+00	2026-07-21 18:09:05.468077+00
2f01124a-87cc-42c0-aff1-ff0045070c4d	44536812-0089-4587-80e0-7163e2463207	47bf13da-40a8-4016-b601-d596b7a29a50	تست و اطمینان از عملکرد صحیح	100	62	2026-07-01	approved	c873d894-cb10-4d12-a1dd-f989a1851641	\N	326393f7-81c1-499a-95df-84298575c784	2026-07-21 18:09:05.468077+00	2026-07-21 18:09:05.468077+00
2f01124a-87cc-42c0-aff1-ff0045070c4d	44536812-0089-4587-80e0-7163e2463207	47bf13da-40a8-4016-b601-d596b7a29a50	رفع اشکالات و بازبینی	152	100	2026-07-03	approved	c873d894-cb10-4d12-a1dd-f989a1851641	\N	cdd06602-8bbc-456e-8770-2809c834c54f	2026-07-21 18:09:05.468077+00	2026-07-21 18:09:05.468077+00
2f01124a-87cc-42c0-aff1-ff0045070c4d	44536812-0089-4587-80e0-7163e2463207	47bf13da-40a8-4016-b601-d596b7a29a50	رفع اشکالات و بازبینی	228	100	2026-07-11	approved	c873d894-cb10-4d12-a1dd-f989a1851641	\N	6f865f31-cbe6-4e55-b81b-345228a9c9e4	2026-07-21 18:09:05.468077+00	2026-07-21 18:09:05.468077+00
2f01124a-87cc-42c0-aff1-ff0045070c4d	9a441833-5276-45be-85c8-3743a63d67b3	9d19d89f-4c3d-4d3d-baf1-a4e8898f6a75	پیاده‌سازی بخش اصلی	195	39	2026-06-17	approved	c873d894-cb10-4d12-a1dd-f989a1851641	\N	6f2b0acc-e974-4a3e-8a0c-e8cd2cd857bf	2026-07-21 18:09:05.468077+00	2026-07-21 18:09:05.468077+00
2f01124a-87cc-42c0-aff1-ff0045070c4d	9a441833-5276-45be-85c8-3743a63d67b3	9d19d89f-4c3d-4d3d-baf1-a4e8898f6a75	رفع اشکالات و بازبینی	65	74	2026-06-18	approved	c873d894-cb10-4d12-a1dd-f989a1851641	\N	7acc7a9c-2009-495c-962b-c9d07d3fac3a	2026-07-21 18:09:05.468077+00	2026-07-21 18:09:05.468077+00
2f01124a-87cc-42c0-aff1-ff0045070c4d	9a441833-5276-45be-85c8-3743a63d67b3	9d19d89f-4c3d-4d3d-baf1-a4e8898f6a75	رفع اشکالات و بازبینی	217	100	2026-06-21	approved	c873d894-cb10-4d12-a1dd-f989a1851641	\N	544bd5a8-c81a-4703-90d5-ec075b9a12e9	2026-07-21 18:09:05.468077+00	2026-07-21 18:09:05.468077+00
2f01124a-87cc-42c0-aff1-ff0045070c4d	9a441833-5276-45be-85c8-3743a63d67b3	9d19d89f-4c3d-4d3d-baf1-a4e8898f6a75	پیشرفت اولیه و بررسی نیازمندی‌ها	34	100	2026-06-20	approved	c873d894-cb10-4d12-a1dd-f989a1851641	\N	04a340fb-4f60-4372-877e-5514354d56f9	2026-07-21 18:09:05.468077+00	2026-07-21 18:09:05.468077+00
2f01124a-87cc-42c0-aff1-ff0045070c4d	773878b0-523d-4242-8593-da562d55fabd	fe42788d-ef87-41ef-8255-9e64e697d040	پیاده‌سازی بخش اصلی	39	37	2026-07-15	submitted	\N	\N	d8e00321-21c4-463b-81bd-d7777c41c170	2026-07-21 18:09:05.468077+00	2026-07-21 18:09:05.468077+00
2f01124a-87cc-42c0-aff1-ff0045070c4d	0cb7a975-21b7-4bf1-a056-c7dfc2ebaed8	47bf13da-40a8-4016-b601-d596b7a29a50	پیاده‌سازی بخش اصلی	123	32	2026-06-22	approved	c873d894-cb10-4d12-a1dd-f989a1851641	\N	13984d05-cb6c-4cc4-9741-413026f4a966	2026-07-21 18:09:05.468077+00	2026-07-21 18:09:05.468077+00
2f01124a-87cc-42c0-aff1-ff0045070c4d	0cb7a975-21b7-4bf1-a056-c7dfc2ebaed8	47bf13da-40a8-4016-b601-d596b7a29a50	مستندسازی و نهایی‌سازی	217	58	2026-06-24	approved	c873d894-cb10-4d12-a1dd-f989a1851641	\N	b687db5d-7eba-42c1-b9c8-eac38279f50a	2026-07-21 18:09:05.468077+00	2026-07-21 18:09:05.468077+00
2f01124a-87cc-42c0-aff1-ff0045070c4d	0cb7a975-21b7-4bf1-a056-c7dfc2ebaed8	47bf13da-40a8-4016-b601-d596b7a29a50	تست و اطمینان از عملکرد صحیح	158	100	2026-06-26	approved	c873d894-cb10-4d12-a1dd-f989a1851641	\N	16fc03f1-6ff4-49a6-b6f4-49e08eb1a286	2026-07-21 18:09:05.468077+00	2026-07-21 18:09:05.468077+00
2f01124a-87cc-42c0-aff1-ff0045070c4d	4f4eddba-c4af-40a0-9cfa-4d2c1ba8bf98	47bf13da-40a8-4016-b601-d596b7a29a50	پیشرفت اولیه و بررسی نیازمندی‌ها	199	27	2026-07-16	approved	c873d894-cb10-4d12-a1dd-f989a1851641	\N	7ee28589-4ac8-46db-98ee-64fe83817915	2026-07-21 18:09:05.468077+00	2026-07-21 18:09:05.468077+00
2f01124a-87cc-42c0-aff1-ff0045070c4d	5df649d3-ae5e-4583-9b04-a794d7d29654	eafb37ce-9111-4c51-91b5-dac320a98501	تست و اطمینان از عملکرد صحیح	70	25	2026-06-25	approved	c873d894-cb10-4d12-a1dd-f989a1851641	\N	204d4151-b4d4-4e8e-94a6-ad8b8ee10ee1	2026-07-21 18:09:05.468077+00	2026-07-21 18:09:05.468077+00
2f01124a-87cc-42c0-aff1-ff0045070c4d	5df649d3-ae5e-4583-9b04-a794d7d29654	eafb37ce-9111-4c51-91b5-dac320a98501	تست و اطمینان از عملکرد صحیح	121	42	2026-06-27	approved	c873d894-cb10-4d12-a1dd-f989a1851641	\N	5075831f-92b5-4527-b5e0-f9b3e97aab24	2026-07-21 18:09:05.468077+00	2026-07-21 18:09:05.468077+00
2f01124a-87cc-42c0-aff1-ff0045070c4d	71277fd6-8b84-4bac-8718-63fa65061396	47bf13da-40a8-4016-b601-d596b7a29a50	پیاده‌سازی بخش اصلی	46	28	2026-07-06	approved	c873d894-cb10-4d12-a1dd-f989a1851641	\N	fa527f09-13bb-4a2c-a1c5-fb3dc376880f	2026-07-21 18:09:05.468077+00	2026-07-21 18:09:05.468077+00
2f01124a-87cc-42c0-aff1-ff0045070c4d	71277fd6-8b84-4bac-8718-63fa65061396	47bf13da-40a8-4016-b601-d596b7a29a50	پیاده‌سازی بخش اصلی	40	52	2026-07-09	approved	c873d894-cb10-4d12-a1dd-f989a1851641	\N	14aee5ee-ccff-46bf-9579-96a9d518c3f7	2026-07-21 18:09:05.468077+00	2026-07-21 18:09:05.468077+00
2f01124a-87cc-42c0-aff1-ff0045070c4d	147bc3ff-3727-48a1-8c40-270ce7dacbe0	9d19d89f-4c3d-4d3d-baf1-a4e8898f6a75	تست و اطمینان از عملکرد صحیح	41	21	2026-07-16	approved	c873d894-cb10-4d12-a1dd-f989a1851641	\N	a861949f-3abc-4d0b-a3e2-528f016ca619	2026-07-21 18:09:05.468077+00	2026-07-21 18:09:05.468077+00
2f01124a-87cc-42c0-aff1-ff0045070c4d	147bc3ff-3727-48a1-8c40-270ce7dacbe0	9d19d89f-4c3d-4d3d-baf1-a4e8898f6a75	مستندسازی و نهایی‌سازی	192	56	2026-07-16	approved	c873d894-cb10-4d12-a1dd-f989a1851641	\N	81750bd3-213e-4877-8d46-655369967a07	2026-07-21 18:09:05.468077+00	2026-07-21 18:09:05.468077+00
2f01124a-87cc-42c0-aff1-ff0045070c4d	147bc3ff-3727-48a1-8c40-270ce7dacbe0	9d19d89f-4c3d-4d3d-baf1-a4e8898f6a75	مستندسازی و نهایی‌سازی	74	96	2026-07-16	approved	c873d894-cb10-4d12-a1dd-f989a1851641	\N	8b0dbcf6-6f65-4cea-b49a-eba7ef598580	2026-07-21 18:09:05.468077+00	2026-07-21 18:09:05.468077+00
2f01124a-87cc-42c0-aff1-ff0045070c4d	85d21eaa-0cf7-4417-9ebc-5b851e40b956	eafb37ce-9111-4c51-91b5-dac320a98501	پیشرفت اولیه و بررسی نیازمندی‌ها	162	28	2026-07-16	approved	c873d894-cb10-4d12-a1dd-f989a1851641	\N	f5230493-5448-49fe-b30b-01e7f440b392	2026-07-21 18:09:05.468077+00	2026-07-21 18:09:05.468077+00
2f01124a-87cc-42c0-aff1-ff0045070c4d	85d21eaa-0cf7-4417-9ebc-5b851e40b956	eafb37ce-9111-4c51-91b5-dac320a98501	پیاده‌سازی بخش اصلی	162	64	2026-07-16	submitted	\N	\N	9770d97b-b04d-4180-bfe1-740c7aab5741	2026-07-21 18:09:05.468077+00	2026-07-21 18:09:05.468077+00
2f01124a-87cc-42c0-aff1-ff0045070c4d	85d21eaa-0cf7-4417-9ebc-5b851e40b956	eafb37ce-9111-4c51-91b5-dac320a98501	رفع اشکالات و بازبینی	154	100	2026-07-16	submitted	\N	\N	e22162d0-f24d-4cb2-8adb-252f9df14003	2026-07-21 18:09:05.468077+00	2026-07-21 18:09:05.468077+00
2f01124a-87cc-42c0-aff1-ff0045070c4d	85d21eaa-0cf7-4417-9ebc-5b851e40b956	eafb37ce-9111-4c51-91b5-dac320a98501	پیاده‌سازی بخش اصلی	142	100	2026-07-16	approved	c873d894-cb10-4d12-a1dd-f989a1851641	\N	fa59d251-851e-473e-9781-97dc074168cc	2026-07-21 18:09:05.468077+00	2026-07-21 18:09:05.468077+00
2f01124a-87cc-42c0-aff1-ff0045070c4d	5456cbe4-5161-4a42-b720-294d552929aa	c873d894-cb10-4d12-a1dd-f989a1851641	مستندسازی و نهایی‌سازی	194	28	2026-07-02	approved	c873d894-cb10-4d12-a1dd-f989a1851641	\N	6c00f202-6d95-4b9e-b5a5-2167c0c39821	2026-07-21 18:09:05.468077+00	2026-07-21 18:09:05.468077+00
2f01124a-87cc-42c0-aff1-ff0045070c4d	5456cbe4-5161-4a42-b720-294d552929aa	c873d894-cb10-4d12-a1dd-f989a1851641	پیاده‌سازی بخش اصلی	77	50	2026-07-04	approved	c873d894-cb10-4d12-a1dd-f989a1851641	\N	7ab60366-78b8-4030-8b78-1d63f0e89558	2026-07-21 18:09:05.468077+00	2026-07-21 18:09:05.468077+00
2f01124a-87cc-42c0-aff1-ff0045070c4d	a9cd71a7-c643-4d4c-8e4e-baaa8248792a	9d19d89f-4c3d-4d3d-baf1-a4e8898f6a75	پیاده‌سازی بخش اصلی	136	30	2026-07-08	approved	c873d894-cb10-4d12-a1dd-f989a1851641	\N	2e17882a-ca44-46e8-adda-924ad09aa313	2026-07-21 18:09:05.468077+00	2026-07-21 18:09:05.468077+00
2f01124a-87cc-42c0-aff1-ff0045070c4d	a9cd71a7-c643-4d4c-8e4e-baaa8248792a	9d19d89f-4c3d-4d3d-baf1-a4e8898f6a75	تست و اطمینان از عملکرد صحیح	202	70	2026-07-09	approved	c873d894-cb10-4d12-a1dd-f989a1851641	\N	6bacafae-6ff0-4cd0-9125-2ec0ff9cde16	2026-07-21 18:09:05.468077+00	2026-07-21 18:09:05.468077+00
2f01124a-87cc-42c0-aff1-ff0045070c4d	a9cd71a7-c643-4d4c-8e4e-baaa8248792a	9d19d89f-4c3d-4d3d-baf1-a4e8898f6a75	پیاده‌سازی بخش اصلی	181	75	2026-07-16	approved	c873d894-cb10-4d12-a1dd-f989a1851641	\N	b0133329-74a7-44ca-ba92-6bc3b1ef584b	2026-07-21 18:09:05.468077+00	2026-07-21 18:09:05.468077+00
2f01124a-87cc-42c0-aff1-ff0045070c4d	f3998b4f-4cc5-46c5-b918-f8d53d0c3a10	9d19d89f-4c3d-4d3d-baf1-a4e8898f6a75	پیاده‌سازی بخش اصلی	176	38	2026-07-02	approved	c873d894-cb10-4d12-a1dd-f989a1851641	\N	a59372f6-c1ef-4bd8-ac5c-ad993f23df03	2026-07-21 18:09:05.468077+00	2026-07-21 18:09:05.468077+00
2f01124a-87cc-42c0-aff1-ff0045070c4d	f3998b4f-4cc5-46c5-b918-f8d53d0c3a10	9d19d89f-4c3d-4d3d-baf1-a4e8898f6a75	مستندسازی و نهایی‌سازی	40	76	2026-07-04	approved	c873d894-cb10-4d12-a1dd-f989a1851641	\N	779f9396-727e-4f9c-8892-46ab4dc66653	2026-07-21 18:09:05.468077+00	2026-07-21 18:09:05.468077+00
2f01124a-87cc-42c0-aff1-ff0045070c4d	f3998b4f-4cc5-46c5-b918-f8d53d0c3a10	9d19d89f-4c3d-4d3d-baf1-a4e8898f6a75	رفع اشکالات و بازبینی	76	100	2026-07-06	approved	c873d894-cb10-4d12-a1dd-f989a1851641	\N	0ded01a4-be5c-4ca4-bc5a-693f903266e0	2026-07-21 18:09:05.468077+00	2026-07-21 18:09:05.468077+00
2f01124a-87cc-42c0-aff1-ff0045070c4d	f3998b4f-4cc5-46c5-b918-f8d53d0c3a10	9d19d89f-4c3d-4d3d-baf1-a4e8898f6a75	مستندسازی و نهایی‌سازی	193	80	2026-07-14	approved	c873d894-cb10-4d12-a1dd-f989a1851641	\N	2e95d9e2-9081-4fb9-92e3-d0f360f98e80	2026-07-21 18:09:05.468077+00	2026-07-21 18:09:05.468077+00
2f01124a-87cc-42c0-aff1-ff0045070c4d	f523823c-bc60-48c2-9362-127348657d63	47bf13da-40a8-4016-b601-d596b7a29a50	پیاده‌سازی بخش اصلی	144	39	2026-07-16	approved	c873d894-cb10-4d12-a1dd-f989a1851641	\N	3b0f2cb6-4098-4f4e-a26f-e18d7ed4acc0	2026-07-21 18:09:05.468077+00	2026-07-21 18:09:05.468077+00
2f01124a-87cc-42c0-aff1-ff0045070c4d	f523823c-bc60-48c2-9362-127348657d63	47bf13da-40a8-4016-b601-d596b7a29a50	تست و اطمینان از عملکرد صحیح	73	54	2026-07-16	approved	c873d894-cb10-4d12-a1dd-f989a1851641	\N	73d7abf8-a90d-45fd-8f38-443f5aad2fd7	2026-07-21 18:09:05.468077+00	2026-07-21 18:09:05.468077+00
2f01124a-87cc-42c0-aff1-ff0045070c4d	f523823c-bc60-48c2-9362-127348657d63	47bf13da-40a8-4016-b601-d596b7a29a50	مستندسازی و نهایی‌سازی	66	100	2026-07-16	approved	c873d894-cb10-4d12-a1dd-f989a1851641	\N	74f7c43f-f24b-40f8-a1f5-abc3b16d686b	2026-07-21 18:09:05.468077+00	2026-07-21 18:09:05.468077+00
2f01124a-87cc-42c0-aff1-ff0045070c4d	0bffbf7d-5eea-4907-9751-7ae4ecda760f	00a2a3bf-94c3-4ef6-a94b-bfb72866c1cd	رفع اشکالات و بازبینی	146	39	2026-07-16	approved	c873d894-cb10-4d12-a1dd-f989a1851641	\N	0809525a-3dff-494b-804e-f9725d4fd48c	2026-07-21 18:09:05.468077+00	2026-07-21 18:09:05.468077+00
2f01124a-87cc-42c0-aff1-ff0045070c4d	0bffbf7d-5eea-4907-9751-7ae4ecda760f	00a2a3bf-94c3-4ef6-a94b-bfb72866c1cd	تست و اطمینان از عملکرد صحیح	63	46	2026-07-16	approved	c873d894-cb10-4d12-a1dd-f989a1851641	\N	aee6396a-d2ac-49d8-98af-49e8bfe71b2c	2026-07-21 18:09:05.468077+00	2026-07-21 18:09:05.468077+00
2f01124a-87cc-42c0-aff1-ff0045070c4d	1a54dc83-0080-459e-bdba-e21fcb905880	eafb37ce-9111-4c51-91b5-dac320a98501	مستندسازی و نهایی‌سازی	205	33	2026-07-11	approved	c873d894-cb10-4d12-a1dd-f989a1851641	\N	ad8f5b83-56a0-45df-bd76-f4701047534f	2026-07-21 18:09:05.468077+00	2026-07-21 18:09:05.468077+00
2f01124a-87cc-42c0-aff1-ff0045070c4d	a9678a6b-54e9-4e8b-bb7a-239f78928c84	00a2a3bf-94c3-4ef6-a94b-bfb72866c1cd	پیاده‌سازی بخش اصلی	151	39	2026-07-09	approved	c873d894-cb10-4d12-a1dd-f989a1851641	\N	aa27c36a-2f6e-4432-9f1d-bdc92f2b855d	2026-07-21 18:09:05.468077+00	2026-07-21 18:09:05.468077+00
2f01124a-87cc-42c0-aff1-ff0045070c4d	a9678a6b-54e9-4e8b-bb7a-239f78928c84	00a2a3bf-94c3-4ef6-a94b-bfb72866c1cd	مستندسازی و نهایی‌سازی	158	46	2026-07-10	approved	c873d894-cb10-4d12-a1dd-f989a1851641	\N	9c912b84-e0db-4707-a92c-325c98a122c6	2026-07-21 18:09:05.468077+00	2026-07-21 18:09:05.468077+00
2f01124a-87cc-42c0-aff1-ff0045070c4d	bfa73f7b-0c09-4a88-a342-63cb0a58e019	c873d894-cb10-4d12-a1dd-f989a1851641	مستندسازی و نهایی‌سازی	168	20	2026-07-16	approved	c873d894-cb10-4d12-a1dd-f989a1851641	\N	75be31be-4d75-4995-bdaa-f23c2c6166d7	2026-07-21 18:09:05.468077+00	2026-07-21 18:09:05.468077+00
2f01124a-87cc-42c0-aff1-ff0045070c4d	b36489b5-8b56-42f1-b318-532221164062	9d19d89f-4c3d-4d3d-baf1-a4e8898f6a75	پیشرفت اولیه و بررسی نیازمندی‌ها	208	36	2026-07-15	approved	c873d894-cb10-4d12-a1dd-f989a1851641	\N	6bf6d622-3aa9-4ab9-af92-847f903ab9b0	2026-07-21 18:09:05.468077+00	2026-07-21 18:09:05.468077+00
2f01124a-87cc-42c0-aff1-ff0045070c4d	b36489b5-8b56-42f1-b318-532221164062	9d19d89f-4c3d-4d3d-baf1-a4e8898f6a75	تست و اطمینان از عملکرد صحیح	232	64	2026-07-16	approved	c873d894-cb10-4d12-a1dd-f989a1851641	\N	97c6b625-a2d2-476f-b218-ced4d8586ef0	2026-07-21 18:09:05.468077+00	2026-07-21 18:09:05.468077+00
2f01124a-87cc-42c0-aff1-ff0045070c4d	b36489b5-8b56-42f1-b318-532221164062	9d19d89f-4c3d-4d3d-baf1-a4e8898f6a75	مستندسازی و نهایی‌سازی	55	99	2026-07-16	approved	c873d894-cb10-4d12-a1dd-f989a1851641	\N	83378715-1fc2-4cba-9658-2128974504c2	2026-07-21 18:09:05.468077+00	2026-07-21 18:09:05.468077+00
2f01124a-87cc-42c0-aff1-ff0045070c4d	b36489b5-8b56-42f1-b318-532221164062	9d19d89f-4c3d-4d3d-baf1-a4e8898f6a75	پیاده‌سازی بخش اصلی	51	100	2026-07-16	approved	c873d894-cb10-4d12-a1dd-f989a1851641	\N	4c25dd49-8028-4d16-b485-c5d832858ee2	2026-07-21 18:09:05.468077+00	2026-07-21 18:09:05.468077+00
2f01124a-87cc-42c0-aff1-ff0045070c4d	dbd559dc-2bf5-417e-a82b-40c5ca1ed6be	47bf13da-40a8-4016-b601-d596b7a29a50	پیشرفت اولیه و بررسی نیازمندی‌ها	177	36	2026-06-17	approved	c873d894-cb10-4d12-a1dd-f989a1851641	\N	9381250d-faaa-49c8-bd88-640a764b7c67	2026-07-21 18:09:05.468077+00	2026-07-21 18:09:05.468077+00
2f01124a-87cc-42c0-aff1-ff0045070c4d	dbd559dc-2bf5-417e-a82b-40c5ca1ed6be	47bf13da-40a8-4016-b601-d596b7a29a50	تست و اطمینان از عملکرد صحیح	197	52	2026-06-18	approved	c873d894-cb10-4d12-a1dd-f989a1851641	\N	168edd50-0255-40a5-a38a-ceff9704c6da	2026-07-21 18:09:05.468077+00	2026-07-21 18:09:05.468077+00
2f01124a-87cc-42c0-aff1-ff0045070c4d	dbd559dc-2bf5-417e-a82b-40c5ca1ed6be	47bf13da-40a8-4016-b601-d596b7a29a50	پیشرفت اولیه و بررسی نیازمندی‌ها	69	99	2026-06-23	approved	c873d894-cb10-4d12-a1dd-f989a1851641	\N	16ae9197-7dcc-4f4f-8aef-054a421ba5f0	2026-07-21 18:09:05.468077+00	2026-07-21 18:09:05.468077+00
2f01124a-87cc-42c0-aff1-ff0045070c4d	dbd559dc-2bf5-417e-a82b-40c5ca1ed6be	47bf13da-40a8-4016-b601-d596b7a29a50	مستندسازی و نهایی‌سازی	138	100	2026-06-26	approved	c873d894-cb10-4d12-a1dd-f989a1851641	\N	4ad82b7c-7d67-4725-bea1-ae7d1b23bac7	2026-07-21 18:09:05.468077+00	2026-07-21 18:09:05.468077+00
2f01124a-87cc-42c0-aff1-ff0045070c4d	f5ac80d7-556d-47a6-aca7-668a9d06ae23	c873d894-cb10-4d12-a1dd-f989a1851641	تست و اطمینان از عملکرد صحیح	223	26	2026-06-23	approved	c873d894-cb10-4d12-a1dd-f989a1851641	\N	69d94ded-076f-48b2-8f69-c35d6d19cabf	2026-07-21 18:09:05.468077+00	2026-07-21 18:09:05.468077+00
2f01124a-87cc-42c0-aff1-ff0045070c4d	f5ac80d7-556d-47a6-aca7-668a9d06ae23	c873d894-cb10-4d12-a1dd-f989a1851641	مستندسازی و نهایی‌سازی	230	74	2026-06-27	approved	c873d894-cb10-4d12-a1dd-f989a1851641	\N	2452aa02-14d7-445f-9c4f-da73fb9d91ba	2026-07-21 18:09:05.468077+00	2026-07-21 18:09:05.468077+00
2f01124a-87cc-42c0-aff1-ff0045070c4d	f5ac80d7-556d-47a6-aca7-668a9d06ae23	c873d894-cb10-4d12-a1dd-f989a1851641	پیاده‌سازی بخش اصلی	124	100	2026-07-01	approved	c873d894-cb10-4d12-a1dd-f989a1851641	\N	fa2e010e-98bf-4a8e-8b62-ba053058ef2c	2026-07-21 18:09:05.468077+00	2026-07-21 18:09:05.468077+00
2f01124a-87cc-42c0-aff1-ff0045070c4d	7f60bd0f-ff37-4aa0-9d21-a21680b52dc3	fe42788d-ef87-41ef-8255-9e64e697d040	رفع اشکالات و بازبینی	177	31	2026-07-16	approved	c873d894-cb10-4d12-a1dd-f989a1851641	\N	30b18a57-278e-4690-b152-a34809ac285d	2026-07-21 18:09:05.468077+00	2026-07-21 18:09:05.468077+00
2f01124a-87cc-42c0-aff1-ff0045070c4d	7f60bd0f-ff37-4aa0-9d21-a21680b52dc3	fe42788d-ef87-41ef-8255-9e64e697d040	پیاده‌سازی بخش اصلی	198	46	2026-07-16	approved	c873d894-cb10-4d12-a1dd-f989a1851641	\N	52bb0c7d-e43b-4665-a301-f6f218fda279	2026-07-21 18:09:05.468077+00	2026-07-21 18:09:05.468077+00
2f01124a-87cc-42c0-aff1-ff0045070c4d	7f60bd0f-ff37-4aa0-9d21-a21680b52dc3	fe42788d-ef87-41ef-8255-9e64e697d040	تست و اطمینان از عملکرد صحیح	230	75	2026-07-16	approved	c873d894-cb10-4d12-a1dd-f989a1851641	\N	3b86b3e6-17cc-45f5-a0fc-644a39dab855	2026-07-21 18:09:05.468077+00	2026-07-21 18:09:05.468077+00
2f01124a-87cc-42c0-aff1-ff0045070c4d	7f60bd0f-ff37-4aa0-9d21-a21680b52dc3	fe42788d-ef87-41ef-8255-9e64e697d040	پیاده‌سازی بخش اصلی	160	100	2026-07-16	approved	c873d894-cb10-4d12-a1dd-f989a1851641	\N	75d64c7e-e1fa-4b0c-881d-04e144658dc1	2026-07-21 18:09:05.468077+00	2026-07-21 18:09:05.468077+00
2f01124a-87cc-42c0-aff1-ff0045070c4d	d5e7f03e-2512-447d-9df8-37aeb6fe39ae	eafb37ce-9111-4c51-91b5-dac320a98501	پیاده‌سازی بخش اصلی	129	40	2026-07-12	approved	c873d894-cb10-4d12-a1dd-f989a1851641	\N	be4fbe1e-c487-416c-8e19-e99d206424f9	2026-07-21 18:09:05.468077+00	2026-07-21 18:09:05.468077+00
2f01124a-87cc-42c0-aff1-ff0045070c4d	d5e7f03e-2512-447d-9df8-37aeb6fe39ae	eafb37ce-9111-4c51-91b5-dac320a98501	پیشرفت اولیه و بررسی نیازمندی‌ها	240	48	2026-07-13	approved	c873d894-cb10-4d12-a1dd-f989a1851641	\N	a1461b20-3387-4b3d-ae03-5e35cbfad2ce	2026-07-21 18:09:05.468077+00	2026-07-21 18:09:05.468077+00
2f01124a-87cc-42c0-aff1-ff0045070c4d	d5e7f03e-2512-447d-9df8-37aeb6fe39ae	eafb37ce-9111-4c51-91b5-dac320a98501	مستندسازی و نهایی‌سازی	141	66	2026-07-16	approved	c873d894-cb10-4d12-a1dd-f989a1851641	\N	958d5d56-d632-4e7f-9bf9-2dd5e015852a	2026-07-21 18:09:05.468077+00	2026-07-21 18:09:05.468077+00
2f01124a-87cc-42c0-aff1-ff0045070c4d	20edcadc-569e-4e74-95f8-20bb8c131e63	ae9392d2-7669-44be-a429-889e449b3eb1	پیاده‌سازی بخش اصلی	124	22	2026-07-16	approved	c873d894-cb10-4d12-a1dd-f989a1851641	\N	194d0738-ef71-464e-b4d4-74b3dafc22e3	2026-07-21 18:09:05.468077+00	2026-07-21 18:09:05.468077+00
2f01124a-87cc-42c0-aff1-ff0045070c4d	1fd7a47f-b32e-47f7-a086-2d15e2dcca02	9d19d89f-4c3d-4d3d-baf1-a4e8898f6a75	تست و اطمینان از عملکرد صحیح	187	40	2026-07-08	approved	c873d894-cb10-4d12-a1dd-f989a1851641	\N	efa1d16f-d80b-442e-af5e-a9f6268fcdc7	2026-07-21 18:09:05.468077+00	2026-07-21 18:09:05.468077+00
2f01124a-87cc-42c0-aff1-ff0045070c4d	98710ca3-abde-4dd5-b0f4-152a3444ed01	fe42788d-ef87-41ef-8255-9e64e697d040	پیاده‌سازی بخش اصلی	193	35	2026-07-16	submitted	\N	\N	fd8daa01-af95-494a-9be6-16dd75a741f3	2026-07-21 18:09:05.468077+00	2026-07-21 18:09:05.468077+00
2f01124a-87cc-42c0-aff1-ff0045070c4d	98710ca3-abde-4dd5-b0f4-152a3444ed01	fe42788d-ef87-41ef-8255-9e64e697d040	مستندسازی و نهایی‌سازی	103	52	2026-07-16	approved	c873d894-cb10-4d12-a1dd-f989a1851641	\N	917c60f5-549b-482b-8afd-0b3aeed7633f	2026-07-21 18:09:05.468077+00	2026-07-21 18:09:05.468077+00
2f01124a-87cc-42c0-aff1-ff0045070c4d	98710ca3-abde-4dd5-b0f4-152a3444ed01	fe42788d-ef87-41ef-8255-9e64e697d040	مستندسازی و نهایی‌سازی	162	81	2026-07-16	submitted	\N	\N	233df33b-9678-4afe-b59f-c7f8ecb81ef4	2026-07-21 18:09:05.468077+00	2026-07-21 18:09:05.468077+00
2f01124a-87cc-42c0-aff1-ff0045070c4d	af425a38-1f24-41d5-aa1e-0eb6f3a07ae3	47bf13da-40a8-4016-b601-d596b7a29a50	رفع اشکالات و بازبینی	91	40	2026-07-16	approved	c873d894-cb10-4d12-a1dd-f989a1851641	\N	e0c4cf3b-6ad9-4e1a-992a-2beed2b254c3	2026-07-21 18:09:05.468077+00	2026-07-21 18:09:05.468077+00
2f01124a-87cc-42c0-aff1-ff0045070c4d	af425a38-1f24-41d5-aa1e-0eb6f3a07ae3	47bf13da-40a8-4016-b601-d596b7a29a50	پیاده‌سازی بخش اصلی	52	56	2026-07-16	approved	c873d894-cb10-4d12-a1dd-f989a1851641	\N	9ab67ae2-2537-490d-b705-25e92bda55f9	2026-07-21 18:09:05.468077+00	2026-07-21 18:09:05.468077+00
2f01124a-87cc-42c0-aff1-ff0045070c4d	b7125778-6ffe-44dd-9564-a4ee010d0730	fe42788d-ef87-41ef-8255-9e64e697d040	تست و اطمینان از عملکرد صحیح	180	26	2026-07-02	approved	c873d894-cb10-4d12-a1dd-f989a1851641	\N	eb869090-0b02-4556-9691-7408dff764c6	2026-07-21 18:09:05.468077+00	2026-07-21 18:09:05.468077+00
2f01124a-87cc-42c0-aff1-ff0045070c4d	b7125778-6ffe-44dd-9564-a4ee010d0730	fe42788d-ef87-41ef-8255-9e64e697d040	پیشرفت اولیه و بررسی نیازمندی‌ها	53	74	2026-07-03	submitted	\N	\N	0e84a44d-6bef-44f9-9136-f95ea2696a09	2026-07-21 18:09:05.468077+00	2026-07-21 18:09:05.468077+00
2f01124a-87cc-42c0-aff1-ff0045070c4d	b7125778-6ffe-44dd-9564-a4ee010d0730	fe42788d-ef87-41ef-8255-9e64e697d040	مستندسازی و نهایی‌سازی	179	93	2026-07-08	submitted	\N	\N	62c10086-03bd-4f6f-99ad-678e1ea724d4	2026-07-21 18:09:05.468077+00	2026-07-21 18:09:05.468077+00
2f01124a-87cc-42c0-aff1-ff0045070c4d	b7125778-6ffe-44dd-9564-a4ee010d0730	fe42788d-ef87-41ef-8255-9e64e697d040	رفع اشکالات و بازبینی	87	100	2026-07-11	submitted	\N	\N	448113df-94a9-40f3-bf9b-816fd7e4d779	2026-07-21 18:09:05.468077+00	2026-07-21 18:09:05.468077+00
2f01124a-87cc-42c0-aff1-ff0045070c4d	1b9aecc9-64cc-4f9f-a8a3-19a2d9072568	47bf13da-40a8-4016-b601-d596b7a29a50	مستندسازی و نهایی‌سازی	31	28	2026-07-09	submitted	\N	\N	5949b57b-2196-4f96-8ab1-86578f707067	2026-07-21 18:09:05.468077+00	2026-07-21 18:09:05.468077+00
2f01124a-87cc-42c0-aff1-ff0045070c4d	1b9aecc9-64cc-4f9f-a8a3-19a2d9072568	47bf13da-40a8-4016-b601-d596b7a29a50	پیشرفت اولیه و بررسی نیازمندی‌ها	173	44	2026-07-11	approved	c873d894-cb10-4d12-a1dd-f989a1851641	\N	96a3406a-8350-468a-bd0f-ea012e71d9e8	2026-07-21 18:09:05.468077+00	2026-07-21 18:09:05.468077+00
2f01124a-87cc-42c0-aff1-ff0045070c4d	347243f0-55d2-4d3d-90c5-94c3e145d9b6	fe42788d-ef87-41ef-8255-9e64e697d040	پیشرفت اولیه و بررسی نیازمندی‌ها	235	36	2026-07-16	approved	c873d894-cb10-4d12-a1dd-f989a1851641	\N	6fa54d0e-1d27-4316-84f7-e29655c9712b	2026-07-21 18:09:05.468077+00	2026-07-21 18:09:05.468077+00
2f01124a-87cc-42c0-aff1-ff0045070c4d	347243f0-55d2-4d3d-90c5-94c3e145d9b6	fe42788d-ef87-41ef-8255-9e64e697d040	مستندسازی و نهایی‌سازی	238	76	2026-07-16	approved	c873d894-cb10-4d12-a1dd-f989a1851641	\N	f3f6d821-fc70-40e6-95d0-18d8ac4cc77a	2026-07-21 18:09:05.468077+00	2026-07-21 18:09:05.468077+00
2f01124a-87cc-42c0-aff1-ff0045070c4d	347243f0-55d2-4d3d-90c5-94c3e145d9b6	fe42788d-ef87-41ef-8255-9e64e697d040	تست و اطمینان از عملکرد صحیح	126	100	2026-07-16	approved	c873d894-cb10-4d12-a1dd-f989a1851641	\N	b028cc4a-e14e-408b-9807-69c661bb4747	2026-07-21 18:09:05.468077+00	2026-07-21 18:09:05.468077+00
2f01124a-87cc-42c0-aff1-ff0045070c4d	d478c990-a538-495d-b0ce-56d3f2722cd4	fe42788d-ef87-41ef-8255-9e64e697d040	تست و اطمینان از عملکرد صحیح	204	34	2026-07-15	submitted	\N	\N	11b9d0e3-7bd9-47b5-9dce-042c2838eb8a	2026-07-21 18:09:05.468077+00	2026-07-21 18:09:05.468077+00
2f01124a-87cc-42c0-aff1-ff0045070c4d	d478c990-a538-495d-b0ce-56d3f2722cd4	fe42788d-ef87-41ef-8255-9e64e697d040	رفع اشکالات و بازبینی	47	64	2026-07-16	approved	c873d894-cb10-4d12-a1dd-f989a1851641	\N	2b2b99e6-4e5b-49af-be84-0f101c2d0ea2	2026-07-21 18:09:05.468077+00	2026-07-21 18:09:05.468077+00
2f01124a-87cc-42c0-aff1-ff0045070c4d	d478c990-a538-495d-b0ce-56d3f2722cd4	fe42788d-ef87-41ef-8255-9e64e697d040	پیاده‌سازی بخش اصلی	234	90	2026-07-16	approved	c873d894-cb10-4d12-a1dd-f989a1851641	\N	a4e4a10b-056f-4ac3-a01f-8daa3f18b3c4	2026-07-21 18:09:05.468077+00	2026-07-21 18:09:05.468077+00
2f01124a-87cc-42c0-aff1-ff0045070c4d	d478c990-a538-495d-b0ce-56d3f2722cd4	fe42788d-ef87-41ef-8255-9e64e697d040	مستندسازی و نهایی‌سازی	167	80	2026-07-16	submitted	\N	\N	265fe612-efb5-4398-8647-d17d0821fa94	2026-07-21 18:09:05.468077+00	2026-07-21 18:09:05.468077+00
2f01124a-87cc-42c0-aff1-ff0045070c4d	24818788-4386-42a8-ba69-a38153fed81e	eafb37ce-9111-4c51-91b5-dac320a98501	رفع اشکالات و بازبینی	53	32	2026-07-10	approved	c873d894-cb10-4d12-a1dd-f989a1851641	\N	77b9f3c7-3382-4751-a868-5b4e50a1c40c	2026-07-21 18:09:05.468077+00	2026-07-21 18:09:05.468077+00
2f01124a-87cc-42c0-aff1-ff0045070c4d	24818788-4386-42a8-ba69-a38153fed81e	eafb37ce-9111-4c51-91b5-dac320a98501	پیشرفت اولیه و بررسی نیازمندی‌ها	171	50	2026-07-13	approved	c873d894-cb10-4d12-a1dd-f989a1851641	\N	a8c906e3-1d61-413c-bcef-a6ac38fd546b	2026-07-21 18:09:05.468077+00	2026-07-21 18:09:05.468077+00
2f01124a-87cc-42c0-aff1-ff0045070c4d	24818788-4386-42a8-ba69-a38153fed81e	eafb37ce-9111-4c51-91b5-dac320a98501	رفع اشکالات و بازبینی	120	78	2026-07-16	approved	c873d894-cb10-4d12-a1dd-f989a1851641	\N	f9b039a4-4442-47fb-83c5-680dad9457c7	2026-07-21 18:09:05.468077+00	2026-07-21 18:09:05.468077+00
2f01124a-87cc-42c0-aff1-ff0045070c4d	3dc16af2-b476-4795-94c7-821f31653dcc	47bf13da-40a8-4016-b601-d596b7a29a50	پیاده‌سازی بخش اصلی	157	26	2026-07-16	approved	c873d894-cb10-4d12-a1dd-f989a1851641	\N	beba72b0-849a-4898-acc5-dd828bed83d0	2026-07-21 18:09:05.468077+00	2026-07-21 18:09:05.468077+00
2f01124a-87cc-42c0-aff1-ff0045070c4d	3dc16af2-b476-4795-94c7-821f31653dcc	47bf13da-40a8-4016-b601-d596b7a29a50	پیاده‌سازی بخش اصلی	97	52	2026-07-16	approved	c873d894-cb10-4d12-a1dd-f989a1851641	\N	a19ae3d2-0167-479c-93e1-8534dbb18a90	2026-07-21 18:09:05.468077+00	2026-07-21 18:09:05.468077+00
2f01124a-87cc-42c0-aff1-ff0045070c4d	3dc16af2-b476-4795-94c7-821f31653dcc	47bf13da-40a8-4016-b601-d596b7a29a50	پیاده‌سازی بخش اصلی	93	100	2026-07-16	approved	c873d894-cb10-4d12-a1dd-f989a1851641	\N	926132e6-d697-45a9-a5a1-143b6e71d5d2	2026-07-21 18:09:05.468077+00	2026-07-21 18:09:05.468077+00
2f01124a-87cc-42c0-aff1-ff0045070c4d	0416a8b8-7ac8-483e-ae48-623a257f761f	eafb37ce-9111-4c51-91b5-dac320a98501	پیشرفت اولیه و بررسی نیازمندی‌ها	60	22	2026-07-16	approved	c873d894-cb10-4d12-a1dd-f989a1851641	\N	44e6e22d-7b01-48ba-9aec-9bde8bba88fa	2026-07-21 18:09:05.468077+00	2026-07-21 18:09:05.468077+00
2f01124a-87cc-42c0-aff1-ff0045070c4d	0416a8b8-7ac8-483e-ae48-623a257f761f	eafb37ce-9111-4c51-91b5-dac320a98501	مستندسازی و نهایی‌سازی	31	74	2026-07-16	approved	c873d894-cb10-4d12-a1dd-f989a1851641	\N	75a969e6-d70b-468c-884a-ae666959b0c1	2026-07-21 18:09:05.468077+00	2026-07-21 18:09:05.468077+00
2f01124a-87cc-42c0-aff1-ff0045070c4d	0416a8b8-7ac8-483e-ae48-623a257f761f	eafb37ce-9111-4c51-91b5-dac320a98501	تست و اطمینان از عملکرد صحیح	125	100	2026-07-16	approved	c873d894-cb10-4d12-a1dd-f989a1851641	\N	3046b37c-2f85-4a0e-acc6-7a0e911c7580	2026-07-21 18:09:05.468077+00	2026-07-21 18:09:05.468077+00
2f01124a-87cc-42c0-aff1-ff0045070c4d	552feeb5-f722-4a8b-b4c7-d3795dd4018b	ae9392d2-7669-44be-a429-889e449b3eb1	مستندسازی و نهایی‌سازی	100	35	2026-07-16	approved	c873d894-cb10-4d12-a1dd-f989a1851641	\N	d42ee2d9-a1da-4c77-b3a6-274e5f1b6c95	2026-07-21 18:09:05.468077+00	2026-07-21 18:09:05.468077+00
2f01124a-87cc-42c0-aff1-ff0045070c4d	552feeb5-f722-4a8b-b4c7-d3795dd4018b	ae9392d2-7669-44be-a429-889e449b3eb1	مستندسازی و نهایی‌سازی	101	64	2026-07-16	approved	c873d894-cb10-4d12-a1dd-f989a1851641	\N	b89fa02b-0943-446d-b6d0-bf857c7ede38	2026-07-21 18:09:05.468077+00	2026-07-21 18:09:05.468077+00
2f01124a-87cc-42c0-aff1-ff0045070c4d	552feeb5-f722-4a8b-b4c7-d3795dd4018b	ae9392d2-7669-44be-a429-889e449b3eb1	مستندسازی و نهایی‌سازی	62	63	2026-07-16	approved	c873d894-cb10-4d12-a1dd-f989a1851641	\N	dd49962a-60e6-4d04-8b69-8d5b98e8f488	2026-07-21 18:09:05.468077+00	2026-07-21 18:09:05.468077+00
2f01124a-87cc-42c0-aff1-ff0045070c4d	f619f637-6818-4f3c-98b0-fce861d705d4	fe42788d-ef87-41ef-8255-9e64e697d040	پیشرفت اولیه و بررسی نیازمندی‌ها	158	31	2026-07-16	submitted	\N	\N	b9ea639d-7454-4239-af17-83398186b4fd	2026-07-21 18:09:05.468077+00	2026-07-21 18:09:05.468077+00
2f01124a-87cc-42c0-aff1-ff0045070c4d	f619f637-6818-4f3c-98b0-fce861d705d4	fe42788d-ef87-41ef-8255-9e64e697d040	پیاده‌سازی بخش اصلی	147	46	2026-07-16	submitted	\N	\N	037b1fee-5931-4090-89a5-27ba51e13460	2026-07-21 18:09:05.468077+00	2026-07-21 18:09:05.468077+00
2f01124a-87cc-42c0-aff1-ff0045070c4d	f619f637-6818-4f3c-98b0-fce861d705d4	fe42788d-ef87-41ef-8255-9e64e697d040	پیشرفت اولیه و بررسی نیازمندی‌ها	33	78	2026-07-16	approved	c873d894-cb10-4d12-a1dd-f989a1851641	\N	49f8d8f4-29d9-46dc-90c4-8db4be757271	2026-07-21 18:09:05.468077+00	2026-07-21 18:09:05.468077+00
2f01124a-87cc-42c0-aff1-ff0045070c4d	f619f637-6818-4f3c-98b0-fce861d705d4	fe42788d-ef87-41ef-8255-9e64e697d040	رفع اشکالات و بازبینی	122	100	2026-07-16	approved	c873d894-cb10-4d12-a1dd-f989a1851641	\N	e4d0c9cd-63cd-4f1a-819c-54924caa4302	2026-07-21 18:09:05.468077+00	2026-07-21 18:09:05.468077+00
2f01124a-87cc-42c0-aff1-ff0045070c4d	cbbf2535-b14c-4cc7-a81b-de2a8b0c11fc	fe42788d-ef87-41ef-8255-9e64e697d040	پیاده‌سازی بخش اصلی	98	35	2026-07-01	approved	c873d894-cb10-4d12-a1dd-f989a1851641	\N	c136a127-4ba6-4b12-81bc-e3347ceb668a	2026-07-21 18:09:05.468077+00	2026-07-21 18:09:05.468077+00
2f01124a-87cc-42c0-aff1-ff0045070c4d	cbbf2535-b14c-4cc7-a81b-de2a8b0c11fc	fe42788d-ef87-41ef-8255-9e64e697d040	تست و اطمینان از عملکرد صحیح	138	52	2026-07-04	approved	c873d894-cb10-4d12-a1dd-f989a1851641	\N	e481e240-514e-4eeb-89ed-8986d68067f6	2026-07-21 18:09:05.468077+00	2026-07-21 18:09:05.468077+00
2f01124a-87cc-42c0-aff1-ff0045070c4d	cbbf2535-b14c-4cc7-a81b-de2a8b0c11fc	fe42788d-ef87-41ef-8255-9e64e697d040	رفع اشکالات و بازبینی	123	96	2026-07-09	submitted	\N	\N	84e612f1-3d77-41dd-ba55-ea1d6b785dd2	2026-07-21 18:09:05.468077+00	2026-07-21 18:09:05.468077+00
2f01124a-87cc-42c0-aff1-ff0045070c4d	18c88872-c854-4646-a67f-25090f66690c	eafb37ce-9111-4c51-91b5-dac320a98501	پیاده‌سازی بخش اصلی	177	27	2026-07-11	approved	c873d894-cb10-4d12-a1dd-f989a1851641	\N	04adb61d-4a87-4c5a-9356-2146e314f2fc	2026-07-21 18:09:05.468077+00	2026-07-21 18:09:05.468077+00
2f01124a-87cc-42c0-aff1-ff0045070c4d	18c88872-c854-4646-a67f-25090f66690c	eafb37ce-9111-4c51-91b5-dac320a98501	پیاده‌سازی بخش اصلی	172	66	2026-07-12	submitted	\N	\N	c3252d8d-62f3-4f54-aa21-79e213bfb007	2026-07-21 18:09:05.468077+00	2026-07-21 18:09:05.468077+00
2f01124a-87cc-42c0-aff1-ff0045070c4d	18c88872-c854-4646-a67f-25090f66690c	eafb37ce-9111-4c51-91b5-dac320a98501	پیاده‌سازی بخش اصلی	151	60	2026-07-16	approved	c873d894-cb10-4d12-a1dd-f989a1851641	\N	493f8a42-baf7-404f-a854-c8092ee82471	2026-07-21 18:09:05.468077+00	2026-07-21 18:09:05.468077+00
2f01124a-87cc-42c0-aff1-ff0045070c4d	05024a00-31e5-4882-97a1-af53298ea36f	eafb37ce-9111-4c51-91b5-dac320a98501	تست و اطمینان از عملکرد صحیح	64	40	2026-07-11	approved	c873d894-cb10-4d12-a1dd-f989a1851641	\N	d7cfa0b2-92ab-4213-9a60-4a7aea370741	2026-07-21 18:09:05.468077+00	2026-07-21 18:09:05.468077+00
2f01124a-87cc-42c0-aff1-ff0045070c4d	05024a00-31e5-4882-97a1-af53298ea36f	eafb37ce-9111-4c51-91b5-dac320a98501	تست و اطمینان از عملکرد صحیح	106	56	2026-07-14	approved	c873d894-cb10-4d12-a1dd-f989a1851641	\N	c90b16e6-c47b-45a7-9c4f-9d2b889c2a47	2026-07-21 18:09:05.468077+00	2026-07-21 18:09:05.468077+00
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
-- Name: calendar_event_categories calendar_event_categories_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.calendar_event_categories
    ADD CONSTRAINT calendar_event_categories_pkey PRIMARY KEY (id);


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
-- Name: calendar_event_categories uq_calendar_event_category_org_name; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.calendar_event_categories
    ADD CONSTRAINT uq_calendar_event_category_org_name UNIQUE (organization_id, name);


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
-- Name: ix_attachments_finance_entry_id; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX ix_attachments_finance_entry_id ON public.attachments USING btree (finance_entry_id);


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
-- Name: ix_calendar_event_categories_organization_id; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX ix_calendar_event_categories_organization_id ON public.calendar_event_categories USING btree (organization_id);


--
-- Name: ix_calendar_events_category_id; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX ix_calendar_events_category_id ON public.calendar_events USING btree (category_id);


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
-- Name: calendar_event_categories calendar_event_categories_organization_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.calendar_event_categories
    ADD CONSTRAINT calendar_event_categories_organization_id_fkey FOREIGN KEY (organization_id) REFERENCES public.organizations(id) ON DELETE CASCADE;


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
-- Name: attachments fk_attachments_finance_entry_id_finance_entries; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.attachments
    ADD CONSTRAINT fk_attachments_finance_entry_id_finance_entries FOREIGN KEY (finance_entry_id) REFERENCES public.finance_entries(id);


--
-- Name: calendar_events fk_calendar_events_category_id_calendar_event_categories; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.calendar_events
    ADD CONSTRAINT fk_calendar_events_category_id_calendar_event_categories FOREIGN KEY (category_id) REFERENCES public.calendar_event_categories(id);


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


