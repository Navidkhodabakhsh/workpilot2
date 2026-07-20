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
    start_date date
);


--
-- Name: users; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.users (
    organization_id uuid,
    email character varying(255) NOT NULL,
    hashed_password character varying(255),
    full_name character varying(200) NOT NULL,
    role public.userrole NOT NULL,
    is_active boolean NOT NULL,
    id uuid NOT NULL,
    created_at timestamp with time zone DEFAULT now() NOT NULL,
    updated_at timestamp with time zone DEFAULT now() NOT NULL,
    phone_number character varying(32),
    department_id uuid
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
-- Data for Name: alembic_version; Type: TABLE DATA; Schema: public; Owner: -
--

COPY public.alembic_version (version_num) FROM stdin;
60291deba722
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
2026-07-20 05:56:31.647699+00	d36d9bdb-efba-436c-9ad9-e7c217d45a60	e68f76ed-4722-4f18-86a3-19ae2667e80e	user.login	user	e68f76ed-4722-4f18-86a3-19ae2667e80e	{}	d0b37f58-53cd-467f-bc23-cdaadc446c44
2026-07-20 05:56:38.551172+00	d36d9bdb-efba-436c-9ad9-e7c217d45a60	5ab53cd1-327d-42d7-9816-c02eb65d5cb3	user.login	user	5ab53cd1-327d-42d7-9816-c02eb65d5cb3	{}	b4f48911-fc9d-49f6-b807-b198840b4cd4
\.


--
-- Data for Name: calendar_events; Type: TABLE DATA; Schema: public; Owner: -
--

COPY public.calendar_events (id, created_at, updated_at, organization_id, created_by_id, project_id, user_id, title, description, event_type, start_at, end_at, all_day) FROM stdin;
6c36929e-7c11-40b7-a238-644291fa585c	2026-07-20 05:56:06.688354+00	2026-07-20 05:56:06.688354+00	d36d9bdb-efba-436c-9ad9-e7c217d45a60	64378bf8-6f34-4dc5-81da-b1fb196a7c3e	54a81aba-6b86-446b-b381-d27a998f3661	\N	جلسهٔ بررسی پیشرفت پروژه	\N	meeting	2026-06-19 10:00:00+00	2026-06-19 11:00:00+00	f
0f57bd24-5ba8-4339-a8f8-577d7abbcac7	2026-07-20 05:56:06.688354+00	2026-07-20 05:56:06.688354+00	d36d9bdb-efba-436c-9ad9-e7c217d45a60	af4e23f3-f961-4eaa-9e20-dbae4f1bbe85	54a81aba-6b86-446b-b381-d27a998f3661	\N	یادآوری تمدید قرارداد	\N	reminder	2026-06-21 00:00:00+00	2026-06-21 01:00:00+00	t
ced9e38a-3416-45df-8c76-2b735b2fa1e7	2026-07-20 05:56:06.688354+00	2026-07-20 05:56:06.688354+00	d36d9bdb-efba-436c-9ad9-e7c217d45a60	e68f76ed-4722-4f18-86a3-19ae2667e80e	\N	\N	تعطیلی رسمی	\N	holiday	2026-06-18 00:00:00+00	2026-06-18 01:00:00+00	t
4afb03f6-4d83-4c2e-b19f-c90cbb575630	2026-07-20 05:56:06.688354+00	2026-07-20 05:56:06.688354+00	d36d9bdb-efba-436c-9ad9-e7c217d45a60	64378bf8-6f34-4dc5-81da-b1fb196a7c3e	4eab00a7-3204-4ae2-b34b-2100b716f70e	\N	جلسهٔ بررسی پیشرفت پروژه	\N	meeting	2026-06-25 10:00:00+00	2026-06-25 11:00:00+00	f
a62ebefc-9bb2-4840-a0c3-8f21cd054c57	2026-07-20 05:56:06.688354+00	2026-07-20 05:56:06.688354+00	d36d9bdb-efba-436c-9ad9-e7c217d45a60	7dd528cd-1bd4-4597-8589-c145df25c0fb	edc20b03-557b-46d8-a124-3a6551c417d6	\N	یادآوری تمدید قرارداد	\N	reminder	2026-06-26 00:00:00+00	2026-06-26 01:00:00+00	t
342d3ead-3549-43b1-9a6c-f7651e83e917	2026-07-20 05:56:06.688354+00	2026-07-20 05:56:06.688354+00	d36d9bdb-efba-436c-9ad9-e7c217d45a60	64378bf8-6f34-4dc5-81da-b1fb196a7c3e	380bb58e-0753-4ff8-b9ef-41c46d00d6fa	\N	جلسهٔ مرور با مدیریت	\N	meeting	2026-07-02 10:00:00+00	2026-07-02 11:00:00+00	f
c159f76f-c88b-4877-8b8d-0246a7ecaf93	2026-07-20 05:56:06.688354+00	2026-07-20 05:56:06.688354+00	d36d9bdb-efba-436c-9ad9-e7c217d45a60	0ca1e1af-afc9-498c-bb79-6bb3bc65d3fb	b29ad29b-5190-433a-8aba-751eac914f36	\N	یادآوری تمدید قرارداد	\N	reminder	2026-07-04 00:00:00+00	2026-07-04 01:00:00+00	t
1c0c9b0e-4f1f-4f2b-b3d9-bc1f10981c51	2026-07-20 05:56:06.688354+00	2026-07-20 05:56:06.688354+00	d36d9bdb-efba-436c-9ad9-e7c217d45a60	64378bf8-6f34-4dc5-81da-b1fb196a7c3e	380bb58e-0753-4ff8-b9ef-41c46d00d6fa	\N	جلسهٔ برنامه‌ریزی اسپرینت	\N	meeting	2026-07-09 10:00:00+00	2026-07-09 11:00:00+00	f
c455087a-9f7f-435f-aa4f-ef8bfb1fb209	2026-07-20 05:56:06.688354+00	2026-07-20 05:56:06.688354+00	d36d9bdb-efba-436c-9ad9-e7c217d45a60	af4e23f3-f961-4eaa-9e20-dbae4f1bbe85	b29ad29b-5190-433a-8aba-751eac914f36	\N	یادآوری تمدید قرارداد	\N	reminder	2026-07-12 00:00:00+00	2026-07-12 01:00:00+00	t
98e2fb33-6a16-4cc0-9570-62367434d04e	2026-07-20 05:56:06.688354+00	2026-07-20 05:56:06.688354+00	d36d9bdb-efba-436c-9ad9-e7c217d45a60	64378bf8-6f34-4dc5-81da-b1fb196a7c3e	b29ad29b-5190-433a-8aba-751eac914f36	\N	جلسهٔ هماهنگی هفتگی	\N	meeting	2026-07-15 10:00:00+00	2026-07-15 11:00:00+00	f
d2b9f965-2c66-4cee-b860-d27a9890b971	2026-07-20 05:56:06.688354+00	2026-07-20 05:56:06.688354+00	d36d9bdb-efba-436c-9ad9-e7c217d45a60	e63e7670-494e-4f3e-ba10-facf27823c40	b29ad29b-5190-433a-8aba-751eac914f36	\N	یادآوری ارسال گزارش	\N	reminder	2026-07-19 00:00:00+00	2026-07-19 01:00:00+00	t
c1affe5a-0237-4756-a1ed-9ebfcb028923	2026-07-20 05:56:06.688354+00	2026-07-20 05:56:06.688354+00	d36d9bdb-efba-436c-9ad9-e7c217d45a60	e68f76ed-4722-4f18-86a3-19ae2667e80e	\N	\N	تعطیلی رسمی	\N	holiday	2026-07-16 00:00:00+00	2026-07-16 01:00:00+00	t
5851360e-8c4f-4096-b48c-1e334b3ecd18	2026-07-20 05:56:06.688354+00	2026-07-20 05:56:06.688354+00	d36d9bdb-efba-436c-9ad9-e7c217d45a60	64378bf8-6f34-4dc5-81da-b1fb196a7c3e	edc20b03-557b-46d8-a124-3a6551c417d6	\N	جلسهٔ مرور با مدیریت	\N	meeting	2026-07-22 10:00:00+00	2026-07-22 11:00:00+00	f
001e39b5-675e-40e3-a716-b4a07a1917d9	2026-07-20 05:56:06.688354+00	2026-07-20 05:56:06.688354+00	d36d9bdb-efba-436c-9ad9-e7c217d45a60	7dd528cd-1bd4-4597-8589-c145df25c0fb	380bb58e-0753-4ff8-b9ef-41c46d00d6fa	\N	یادآوری پیگیری مشتری	\N	reminder	2026-07-23 00:00:00+00	2026-07-23 01:00:00+00	t
f5f5a2c1-d0f2-4883-982a-58c87e184f82	2026-07-20 05:56:06.688354+00	2026-07-20 05:56:06.688354+00	d36d9bdb-efba-436c-9ad9-e7c217d45a60	64378bf8-6f34-4dc5-81da-b1fb196a7c3e	380bb58e-0753-4ff8-b9ef-41c46d00d6fa	\N	جلسهٔ هماهنگی هفتگی	\N	meeting	2026-07-30 10:00:00+00	2026-07-30 11:00:00+00	f
55985fbf-76f0-470b-a55b-c84450b7b4ff	2026-07-20 05:56:06.688354+00	2026-07-20 05:56:06.688354+00	d36d9bdb-efba-436c-9ad9-e7c217d45a60	e63e7670-494e-4f3e-ba10-facf27823c40	b29ad29b-5190-433a-8aba-751eac914f36	\N	یادآوری ارسال گزارش	\N	reminder	2026-08-03 00:00:00+00	2026-08-03 01:00:00+00	t
e83b3fb4-b86f-4a13-9438-5063e1b36a31	2026-07-20 05:56:06.688354+00	2026-07-20 05:56:06.688354+00	d36d9bdb-efba-436c-9ad9-e7c217d45a60	64378bf8-6f34-4dc5-81da-b1fb196a7c3e	b29ad29b-5190-433a-8aba-751eac914f36	\N	جلسهٔ برنامه‌ریزی اسپرینت	\N	meeting	2026-08-05 10:00:00+00	2026-08-05 11:00:00+00	f
5f10da15-7248-4ced-ab47-888637cfa530	2026-07-20 05:56:06.688354+00	2026-07-20 05:56:06.688354+00	d36d9bdb-efba-436c-9ad9-e7c217d45a60	7dd528cd-1bd4-4597-8589-c145df25c0fb	380bb58e-0753-4ff8-b9ef-41c46d00d6fa	\N	یادآوری ارسال گزارش	\N	reminder	2026-08-04 00:00:00+00	2026-08-04 01:00:00+00	t
6b31fbc0-9b17-4be3-8084-bf2beb1fe543	2026-07-20 05:56:06.688354+00	2026-07-20 05:56:06.688354+00	d36d9bdb-efba-436c-9ad9-e7c217d45a60	64378bf8-6f34-4dc5-81da-b1fb196a7c3e	b29ad29b-5190-433a-8aba-751eac914f36	\N	جلسهٔ هماهنگی هفتگی	\N	meeting	2026-08-11 10:00:00+00	2026-08-11 11:00:00+00	f
9276a16f-8e54-4319-8186-23590049994a	2026-07-20 05:56:06.688354+00	2026-07-20 05:56:06.688354+00	d36d9bdb-efba-436c-9ad9-e7c217d45a60	91b406bb-3239-4e75-bc39-05289ba5787a	edc20b03-557b-46d8-a124-3a6551c417d6	\N	یادآوری پیگیری مشتری	\N	reminder	2026-08-15 00:00:00+00	2026-08-15 01:00:00+00	t
54565233-9605-4451-9317-d5926a40fed0	2026-07-20 05:56:06.688354+00	2026-07-20 05:56:06.688354+00	d36d9bdb-efba-436c-9ad9-e7c217d45a60	e68f76ed-4722-4f18-86a3-19ae2667e80e	\N	\N	تعطیلی رسمی	\N	holiday	2026-08-13 00:00:00+00	2026-08-13 01:00:00+00	t
dedfb066-d6a6-45de-8535-36d269630d4b	2026-07-20 05:56:06.688354+00	2026-07-20 05:56:06.688354+00	d36d9bdb-efba-436c-9ad9-e7c217d45a60	0e06be7f-9df4-4e66-a58e-9eba6f026584	ea464407-6559-4634-b535-cc49f7939b7e	\N	جلسهٔ مرور با مدیریت	\N	meeting	2026-06-20 10:00:00+00	2026-06-20 11:00:00+00	f
b534ec20-9b4e-4aec-8515-02e078a4e21a	2026-07-20 05:56:06.688354+00	2026-07-20 05:56:06.688354+00	d36d9bdb-efba-436c-9ad9-e7c217d45a60	77fe864d-692a-4798-9e36-b464ad1c9e1c	f72202f7-5c82-44e7-9482-6ac4f392d5d3	\N	یادآوری پیگیری مشتری	\N	reminder	2026-06-19 00:00:00+00	2026-06-19 01:00:00+00	t
c348ffc7-0cfe-41a8-87a6-d569f8a45c6b	2026-07-20 05:56:06.688354+00	2026-07-20 05:56:06.688354+00	d36d9bdb-efba-436c-9ad9-e7c217d45a60	e68f76ed-4722-4f18-86a3-19ae2667e80e	\N	\N	تعطیلی رسمی	\N	holiday	2026-06-18 00:00:00+00	2026-06-18 01:00:00+00	t
fb2a6a30-6e5d-4810-8a42-a91c72a571d9	2026-07-20 05:56:06.688354+00	2026-07-20 05:56:06.688354+00	d36d9bdb-efba-436c-9ad9-e7c217d45a60	0e06be7f-9df4-4e66-a58e-9eba6f026584	8284e4d9-0201-4c88-ad0e-dc4326260101	\N	جلسهٔ بررسی پیشرفت پروژه	\N	meeting	2026-06-27 10:00:00+00	2026-06-27 11:00:00+00	f
4a5c4e65-110c-4890-9537-c5bd34060947	2026-07-20 05:56:06.688354+00	2026-07-20 05:56:06.688354+00	d36d9bdb-efba-436c-9ad9-e7c217d45a60	77fe864d-692a-4798-9e36-b464ad1c9e1c	8284e4d9-0201-4c88-ad0e-dc4326260101	\N	یادآوری پیگیری مشتری	\N	reminder	2026-06-25 00:00:00+00	2026-06-25 01:00:00+00	t
c293ad71-6354-413f-a605-12092257e634	2026-07-20 05:56:06.688354+00	2026-07-20 05:56:06.688354+00	d36d9bdb-efba-436c-9ad9-e7c217d45a60	0e06be7f-9df4-4e66-a58e-9eba6f026584	64870cfe-8d3d-4d23-a611-14a97a14b215	\N	جلسهٔ مرور با مدیریت	\N	meeting	2026-06-30 10:00:00+00	2026-06-30 11:00:00+00	f
6a39a1f4-6f24-4159-821e-649bb78933b2	2026-07-20 05:56:06.688354+00	2026-07-20 05:56:06.688354+00	d36d9bdb-efba-436c-9ad9-e7c217d45a60	fbfe2b53-dcf1-4ee4-acf0-7c1a3cace4db	ea464407-6559-4634-b535-cc49f7939b7e	\N	یادآوری پیگیری مشتری	\N	reminder	2026-06-30 00:00:00+00	2026-06-30 01:00:00+00	t
73b5e827-2b7d-44ca-961c-b8a08cf13739	2026-07-20 05:56:06.688354+00	2026-07-20 05:56:06.688354+00	d36d9bdb-efba-436c-9ad9-e7c217d45a60	0e06be7f-9df4-4e66-a58e-9eba6f026584	64870cfe-8d3d-4d23-a611-14a97a14b215	\N	جلسهٔ بررسی پیشرفت پروژه	\N	meeting	2026-07-07 10:00:00+00	2026-07-07 11:00:00+00	f
9c29e827-c144-4172-8af5-c46368cf995c	2026-07-20 05:56:06.688354+00	2026-07-20 05:56:06.688354+00	d36d9bdb-efba-436c-9ad9-e7c217d45a60	30621a70-ecd1-4c9b-a6c0-5b071dab4d1c	8284e4d9-0201-4c88-ad0e-dc4326260101	\N	یادآوری پیگیری مشتری	\N	reminder	2026-07-12 00:00:00+00	2026-07-12 01:00:00+00	t
d96b576c-f3bd-436c-8561-26dbf60a9a9e	2026-07-20 05:56:06.688354+00	2026-07-20 05:56:06.688354+00	d36d9bdb-efba-436c-9ad9-e7c217d45a60	0e06be7f-9df4-4e66-a58e-9eba6f026584	f72202f7-5c82-44e7-9482-6ac4f392d5d3	\N	جلسهٔ بررسی پیشرفت پروژه	\N	meeting	2026-07-18 10:00:00+00	2026-07-18 11:00:00+00	f
16741dc3-bf1a-47de-869a-cb9992eaf6b9	2026-07-20 05:56:06.688354+00	2026-07-20 05:56:06.688354+00	d36d9bdb-efba-436c-9ad9-e7c217d45a60	fbfe2b53-dcf1-4ee4-acf0-7c1a3cace4db	c771aebe-c485-465a-b898-a8ef09df6f98	\N	یادآوری تمدید قرارداد	\N	reminder	2026-07-16 00:00:00+00	2026-07-16 01:00:00+00	t
3293c9c2-4ba0-4530-97af-b32960035a5a	2026-07-20 05:56:06.688354+00	2026-07-20 05:56:06.688354+00	d36d9bdb-efba-436c-9ad9-e7c217d45a60	e68f76ed-4722-4f18-86a3-19ae2667e80e	\N	\N	تعطیلی رسمی	\N	holiday	2026-07-16 00:00:00+00	2026-07-16 01:00:00+00	t
b627983c-d30b-40d4-b19b-8ac225cae0b2	2026-07-20 05:56:06.688354+00	2026-07-20 05:56:06.688354+00	d36d9bdb-efba-436c-9ad9-e7c217d45a60	0e06be7f-9df4-4e66-a58e-9eba6f026584	c771aebe-c485-465a-b898-a8ef09df6f98	\N	جلسهٔ هماهنگی هفتگی	\N	meeting	2026-07-25 10:00:00+00	2026-07-25 11:00:00+00	f
b60f8008-6824-4277-abf4-bf3b84ead0d7	2026-07-20 05:56:06.688354+00	2026-07-20 05:56:06.688354+00	d36d9bdb-efba-436c-9ad9-e7c217d45a60	7653733b-3526-47fd-8fa2-b6c120729ad7	c771aebe-c485-465a-b898-a8ef09df6f98	\N	یادآوری ارسال گزارش	\N	reminder	2026-07-27 00:00:00+00	2026-07-27 01:00:00+00	t
4817b0ca-d54b-4fb9-b9ca-305ecbaeff17	2026-07-20 05:56:06.688354+00	2026-07-20 05:56:06.688354+00	d36d9bdb-efba-436c-9ad9-e7c217d45a60	0e06be7f-9df4-4e66-a58e-9eba6f026584	c771aebe-c485-465a-b898-a8ef09df6f98	\N	جلسهٔ مرور با مدیریت	\N	meeting	2026-07-28 10:00:00+00	2026-07-28 11:00:00+00	f
db4383e7-5504-4a8f-bf14-12831d9d6e5f	2026-07-20 05:56:06.688354+00	2026-07-20 05:56:06.688354+00	d36d9bdb-efba-436c-9ad9-e7c217d45a60	fbfe2b53-dcf1-4ee4-acf0-7c1a3cace4db	f72202f7-5c82-44e7-9482-6ac4f392d5d3	\N	یادآوری ارسال گزارش	\N	reminder	2026-07-30 00:00:00+00	2026-07-30 01:00:00+00	t
0b1b7fde-f5b2-41f6-843e-1a90eab7499a	2026-07-20 05:56:06.688354+00	2026-07-20 05:56:06.688354+00	d36d9bdb-efba-436c-9ad9-e7c217d45a60	0e06be7f-9df4-4e66-a58e-9eba6f026584	c771aebe-c485-465a-b898-a8ef09df6f98	\N	جلسهٔ بررسی پیشرفت پروژه	\N	meeting	2026-08-04 10:00:00+00	2026-08-04 11:00:00+00	f
29a6611a-b715-4091-a46b-ae1b5f1f3c41	2026-07-20 05:56:06.688354+00	2026-07-20 05:56:06.688354+00	d36d9bdb-efba-436c-9ad9-e7c217d45a60	fbfe2b53-dcf1-4ee4-acf0-7c1a3cace4db	8284e4d9-0201-4c88-ad0e-dc4326260101	\N	یادآوری ارسال گزارش	\N	reminder	2026-08-06 00:00:00+00	2026-08-06 01:00:00+00	t
4ad059d7-c23e-433f-8e50-ddc07ab09721	2026-07-20 05:56:06.688354+00	2026-07-20 05:56:06.688354+00	d36d9bdb-efba-436c-9ad9-e7c217d45a60	0e06be7f-9df4-4e66-a58e-9eba6f026584	f72202f7-5c82-44e7-9482-6ac4f392d5d3	\N	جلسهٔ برنامه‌ریزی اسپرینت	\N	meeting	2026-08-11 10:00:00+00	2026-08-11 11:00:00+00	f
352a7c7c-911b-4473-aa48-da98f0cc2991	2026-07-20 05:56:06.688354+00	2026-07-20 05:56:06.688354+00	d36d9bdb-efba-436c-9ad9-e7c217d45a60	30621a70-ecd1-4c9b-a6c0-5b071dab4d1c	c771aebe-c485-465a-b898-a8ef09df6f98	\N	یادآوری ارسال گزارش	\N	reminder	2026-08-15 00:00:00+00	2026-08-15 01:00:00+00	t
5bd941c6-a67e-4c8e-b087-413926a2523d	2026-07-20 05:56:06.688354+00	2026-07-20 05:56:06.688354+00	d36d9bdb-efba-436c-9ad9-e7c217d45a60	e68f76ed-4722-4f18-86a3-19ae2667e80e	\N	\N	تعطیلی رسمی	\N	holiday	2026-08-13 00:00:00+00	2026-08-13 01:00:00+00	t
78657a12-6c3b-4e0f-bafb-7dd1b4daecb0	2026-07-20 05:56:06.688354+00	2026-07-20 05:56:06.688354+00	d36d9bdb-efba-436c-9ad9-e7c217d45a60	86adf704-3f12-404e-a458-aa2e0259864a	b5def797-6aa4-4191-afb3-8cca2c39a9e9	\N	جلسهٔ مرور با مدیریت	\N	meeting	2026-06-16 10:00:00+00	2026-06-16 11:00:00+00	f
e09bb84d-31e9-49e7-b39c-01e0e2e15bd8	2026-07-20 05:56:06.688354+00	2026-07-20 05:56:06.688354+00	d36d9bdb-efba-436c-9ad9-e7c217d45a60	3e9d418d-c94e-4859-8756-2203f7d7c329	b6279820-0573-42e9-9a92-593efb4b8d77	\N	یادآوری ارسال گزارش	\N	reminder	2026-06-20 00:00:00+00	2026-06-20 01:00:00+00	t
fbd5dd1b-88a8-4a8d-a075-0a5276668b6b	2026-07-20 05:56:06.688354+00	2026-07-20 05:56:06.688354+00	d36d9bdb-efba-436c-9ad9-e7c217d45a60	e68f76ed-4722-4f18-86a3-19ae2667e80e	\N	\N	تعطیلی رسمی	\N	holiday	2026-06-18 00:00:00+00	2026-06-18 01:00:00+00	t
fe41d0b7-fee4-4ddd-bdfa-c184414b73df	2026-07-20 05:56:06.688354+00	2026-07-20 05:56:06.688354+00	d36d9bdb-efba-436c-9ad9-e7c217d45a60	86adf704-3f12-404e-a458-aa2e0259864a	9a60974f-3827-445d-b461-fbafefac8047	\N	جلسهٔ بررسی پیشرفت پروژه	\N	meeting	2026-06-27 10:00:00+00	2026-06-27 11:00:00+00	f
75ba49cd-9def-4f43-8e19-516fe694748e	2026-07-20 05:56:06.688354+00	2026-07-20 05:56:06.688354+00	d36d9bdb-efba-436c-9ad9-e7c217d45a60	7be892eb-4087-4511-8e0a-5bac8a046af2	24168387-911b-4ecd-b6e3-d36517c7f745	\N	یادآوری ارسال گزارش	\N	reminder	2026-06-27 00:00:00+00	2026-06-27 01:00:00+00	t
a4fd35ad-403c-490c-a0f3-215eba54c2ec	2026-07-20 05:56:06.688354+00	2026-07-20 05:56:06.688354+00	d36d9bdb-efba-436c-9ad9-e7c217d45a60	86adf704-3f12-404e-a458-aa2e0259864a	b6279820-0573-42e9-9a92-593efb4b8d77	\N	جلسهٔ مرور با مدیریت	\N	meeting	2026-07-04 10:00:00+00	2026-07-04 11:00:00+00	f
af6eb137-71fa-4dcf-9533-f0e5007eabcc	2026-07-20 05:56:06.688354+00	2026-07-20 05:56:06.688354+00	d36d9bdb-efba-436c-9ad9-e7c217d45a60	3e9d418d-c94e-4859-8756-2203f7d7c329	24168387-911b-4ecd-b6e3-d36517c7f745	\N	یادآوری پیگیری مشتری	\N	reminder	2026-06-30 00:00:00+00	2026-06-30 01:00:00+00	t
25d89294-9fd9-4f3c-9774-60be39ba5739	2026-07-20 05:56:06.688354+00	2026-07-20 05:56:06.688354+00	d36d9bdb-efba-436c-9ad9-e7c217d45a60	86adf704-3f12-404e-a458-aa2e0259864a	b5def797-6aa4-4191-afb3-8cca2c39a9e9	\N	جلسهٔ هماهنگی هفتگی	\N	meeting	2026-07-10 10:00:00+00	2026-07-10 11:00:00+00	f
7c252787-741c-4584-8f2a-5748bad660bb	2026-07-20 05:56:06.688354+00	2026-07-20 05:56:06.688354+00	d36d9bdb-efba-436c-9ad9-e7c217d45a60	5f98deeb-64ad-4c21-a955-cc484130bfa2	9a60974f-3827-445d-b461-fbafefac8047	\N	یادآوری تمدید قرارداد	\N	reminder	2026-07-11 00:00:00+00	2026-07-11 01:00:00+00	t
274d4300-3668-48e3-b995-9b99ceeec278	2026-07-20 05:56:06.688354+00	2026-07-20 05:56:06.688354+00	d36d9bdb-efba-436c-9ad9-e7c217d45a60	86adf704-3f12-404e-a458-aa2e0259864a	24168387-911b-4ecd-b6e3-d36517c7f745	\N	جلسهٔ مرور با مدیریت	\N	meeting	2026-07-18 10:00:00+00	2026-07-18 11:00:00+00	f
e49f5ee8-d576-41ba-adae-35f6d8631e58	2026-07-20 05:56:06.688354+00	2026-07-20 05:56:06.688354+00	d36d9bdb-efba-436c-9ad9-e7c217d45a60	7be892eb-4087-4511-8e0a-5bac8a046af2	9a60974f-3827-445d-b461-fbafefac8047	\N	یادآوری پیگیری مشتری	\N	reminder	2026-07-17 00:00:00+00	2026-07-17 01:00:00+00	t
2b85d3cc-b006-4957-b830-fa907e9560ce	2026-07-20 05:56:06.688354+00	2026-07-20 05:56:06.688354+00	d36d9bdb-efba-436c-9ad9-e7c217d45a60	e68f76ed-4722-4f18-86a3-19ae2667e80e	\N	\N	تعطیلی رسمی	\N	holiday	2026-07-16 00:00:00+00	2026-07-16 01:00:00+00	t
7016fb74-d37e-4453-9f06-68df531201ca	2026-07-20 05:56:06.688354+00	2026-07-20 05:56:06.688354+00	d36d9bdb-efba-436c-9ad9-e7c217d45a60	86adf704-3f12-404e-a458-aa2e0259864a	b6279820-0573-42e9-9a92-593efb4b8d77	\N	جلسهٔ مرور با مدیریت	\N	meeting	2026-07-21 10:00:00+00	2026-07-21 11:00:00+00	f
74a16669-4e54-4f80-95b3-118ee9768809	2026-07-20 05:56:06.688354+00	2026-07-20 05:56:06.688354+00	d36d9bdb-efba-436c-9ad9-e7c217d45a60	28392456-2fc2-4f59-a145-fff7d356370c	24168387-911b-4ecd-b6e3-d36517c7f745	\N	یادآوری پیگیری مشتری	\N	reminder	2026-07-23 00:00:00+00	2026-07-23 01:00:00+00	t
9684fd42-5766-400d-b996-ac51c488addf	2026-07-20 05:56:06.688354+00	2026-07-20 05:56:06.688354+00	d36d9bdb-efba-436c-9ad9-e7c217d45a60	86adf704-3f12-404e-a458-aa2e0259864a	9a60974f-3827-445d-b461-fbafefac8047	\N	جلسهٔ مرور با مدیریت	\N	meeting	2026-07-28 10:00:00+00	2026-07-28 11:00:00+00	f
fc959bcd-1dc9-4986-bb97-0f862d3aa963	2026-07-20 05:56:06.688354+00	2026-07-20 05:56:06.688354+00	d36d9bdb-efba-436c-9ad9-e7c217d45a60	3e9d418d-c94e-4859-8756-2203f7d7c329	9a60974f-3827-445d-b461-fbafefac8047	\N	یادآوری پیگیری مشتری	\N	reminder	2026-07-30 00:00:00+00	2026-07-30 01:00:00+00	t
1e72f88a-7c9d-4a17-9f30-628f428d4907	2026-07-20 05:56:06.688354+00	2026-07-20 05:56:06.688354+00	d36d9bdb-efba-436c-9ad9-e7c217d45a60	86adf704-3f12-404e-a458-aa2e0259864a	9a60974f-3827-445d-b461-fbafefac8047	\N	جلسهٔ مرور با مدیریت	\N	meeting	2026-08-04 10:00:00+00	2026-08-04 11:00:00+00	f
ac89cdd1-575d-463f-9c57-a8942d972901	2026-07-20 05:56:06.688354+00	2026-07-20 05:56:06.688354+00	d36d9bdb-efba-436c-9ad9-e7c217d45a60	e6d6e516-bc90-467f-a35a-3c169219865e	be059dae-45fe-4d45-84fe-6b4eafa8e856	\N	یادآوری ارسال گزارش	\N	reminder	2026-08-04 00:00:00+00	2026-08-04 01:00:00+00	t
b6291c34-c192-40d5-8453-8ac8d513bdd0	2026-07-20 05:56:06.688354+00	2026-07-20 05:56:06.688354+00	d36d9bdb-efba-436c-9ad9-e7c217d45a60	86adf704-3f12-404e-a458-aa2e0259864a	24168387-911b-4ecd-b6e3-d36517c7f745	\N	جلسهٔ برنامه‌ریزی اسپرینت	\N	meeting	2026-08-14 10:00:00+00	2026-08-14 11:00:00+00	f
a2debe25-b3ea-4652-b253-0420c8de4d07	2026-07-20 05:56:06.688354+00	2026-07-20 05:56:06.688354+00	d36d9bdb-efba-436c-9ad9-e7c217d45a60	5f98deeb-64ad-4c21-a955-cc484130bfa2	be059dae-45fe-4d45-84fe-6b4eafa8e856	\N	یادآوری تمدید قرارداد	\N	reminder	2026-08-14 00:00:00+00	2026-08-14 01:00:00+00	t
283f777c-1577-4397-a66b-f70a4cba633f	2026-07-20 05:56:06.688354+00	2026-07-20 05:56:06.688354+00	d36d9bdb-efba-436c-9ad9-e7c217d45a60	e68f76ed-4722-4f18-86a3-19ae2667e80e	\N	\N	تعطیلی رسمی	\N	holiday	2026-08-13 00:00:00+00	2026-08-13 01:00:00+00	t
\.


--
-- Data for Name: comments; Type: TABLE DATA; Schema: public; Owner: -
--

COPY public.comments (organization_id, task_id, author_id, body, id, created_at, updated_at) FROM stdin;
\.


--
-- Data for Name: departments; Type: TABLE DATA; Schema: public; Owner: -
--

COPY public.departments (id, created_at, updated_at, organization_id, name) FROM stdin;
04f9e67c-d38e-4088-930a-5507f8cce896	2026-07-20 05:56:06.688354+00	2026-07-20 05:56:06.688354+00	d36d9bdb-efba-436c-9ad9-e7c217d45a60	مهندسی و فنی
7772c657-8cbb-47d4-a5cd-59293e48f79f	2026-07-20 05:56:06.688354+00	2026-07-20 05:56:06.688354+00	d36d9bdb-efba-436c-9ad9-e7c217d45a60	حسابداری و مالی
34acf832-d975-4448-818c-dc2106e9da5f	2026-07-20 05:56:06.688354+00	2026-07-20 05:56:06.688354+00	d36d9bdb-efba-436c-9ad9-e7c217d45a60	منابع انسانی
\.


--
-- Data for Name: export_jobs; Type: TABLE DATA; Schema: public; Owner: -
--

COPY public.export_jobs (organization_id, requested_by_id, export_type, filters, status, file_path, error_message, completed_at, id, created_at, updated_at) FROM stdin;
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
شرکت نمونهٔ آزمایشی	demo-org-6b682625	t	d36d9bdb-efba-436c-9ad9-e7c217d45a60	2026-07-20 05:56:06.688354+00	2026-07-20 05:56:06.688354+00
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
4eab00a7-3204-4ae2-b34b-2100b716f70e	64378bf8-6f34-4dc5-81da-b1fb196a7c3e	b8b7c581-425a-4f74-a4fb-798afdb52f3b	2026-07-20 05:56:06.688354+00	2026-07-20 05:56:06.688354+00
4eab00a7-3204-4ae2-b34b-2100b716f70e	7dd528cd-1bd4-4597-8589-c145df25c0fb	09b904d8-8ac2-470b-a792-6cc9334430c2	2026-07-20 05:56:06.688354+00	2026-07-20 05:56:06.688354+00
4eab00a7-3204-4ae2-b34b-2100b716f70e	5ab53cd1-327d-42d7-9816-c02eb65d5cb3	5350153e-b974-44df-8512-e48cf6f27ec0	2026-07-20 05:56:06.688354+00	2026-07-20 05:56:06.688354+00
4eab00a7-3204-4ae2-b34b-2100b716f70e	0ca1e1af-afc9-498c-bb79-6bb3bc65d3fb	89ad77e6-27c6-4321-80ec-8ebd01f258db	2026-07-20 05:56:06.688354+00	2026-07-20 05:56:06.688354+00
edc20b03-557b-46d8-a124-3a6551c417d6	64378bf8-6f34-4dc5-81da-b1fb196a7c3e	9c974a28-4897-4f00-97b3-fb7a8e874fac	2026-07-20 05:56:06.688354+00	2026-07-20 05:56:06.688354+00
edc20b03-557b-46d8-a124-3a6551c417d6	7dd528cd-1bd4-4597-8589-c145df25c0fb	4530e983-e6d3-467a-8987-d737ede0c001	2026-07-20 05:56:06.688354+00	2026-07-20 05:56:06.688354+00
edc20b03-557b-46d8-a124-3a6551c417d6	91b406bb-3239-4e75-bc39-05289ba5787a	c9604f0b-bcca-4660-9004-2d68e0c5f9ca	2026-07-20 05:56:06.688354+00	2026-07-20 05:56:06.688354+00
edc20b03-557b-46d8-a124-3a6551c417d6	e63e7670-494e-4f3e-ba10-facf27823c40	b2a0283c-75ba-4335-86e8-515d09428910	2026-07-20 05:56:06.688354+00	2026-07-20 05:56:06.688354+00
b29ad29b-5190-433a-8aba-751eac914f36	64378bf8-6f34-4dc5-81da-b1fb196a7c3e	ac42cc81-003f-4b97-aae6-b0711b4e49ea	2026-07-20 05:56:06.688354+00	2026-07-20 05:56:06.688354+00
b29ad29b-5190-433a-8aba-751eac914f36	e63e7670-494e-4f3e-ba10-facf27823c40	e8b8a625-8221-411a-a722-ad23afb06b22	2026-07-20 05:56:06.688354+00	2026-07-20 05:56:06.688354+00
b29ad29b-5190-433a-8aba-751eac914f36	7dd528cd-1bd4-4597-8589-c145df25c0fb	563cd53c-1da5-49db-be31-b4fa9f02a8a1	2026-07-20 05:56:06.688354+00	2026-07-20 05:56:06.688354+00
b29ad29b-5190-433a-8aba-751eac914f36	5ab53cd1-327d-42d7-9816-c02eb65d5cb3	e881e6f6-3f98-4a37-9fc9-77263496d072	2026-07-20 05:56:06.688354+00	2026-07-20 05:56:06.688354+00
54a81aba-6b86-446b-b381-d27a998f3661	64378bf8-6f34-4dc5-81da-b1fb196a7c3e	599bd7d7-2c70-4f71-8ad8-71381b7b8aad	2026-07-20 05:56:06.688354+00	2026-07-20 05:56:06.688354+00
54a81aba-6b86-446b-b381-d27a998f3661	7dd528cd-1bd4-4597-8589-c145df25c0fb	487c2b55-e4ed-4b3a-9e96-701ca5c20a26	2026-07-20 05:56:06.688354+00	2026-07-20 05:56:06.688354+00
54a81aba-6b86-446b-b381-d27a998f3661	0ca1e1af-afc9-498c-bb79-6bb3bc65d3fb	7e6d078c-e570-4318-b077-df5f7fd13ea0	2026-07-20 05:56:06.688354+00	2026-07-20 05:56:06.688354+00
54a81aba-6b86-446b-b381-d27a998f3661	5ab53cd1-327d-42d7-9816-c02eb65d5cb3	fabbc796-9a15-442d-8676-e4697d2d0cd3	2026-07-20 05:56:06.688354+00	2026-07-20 05:56:06.688354+00
380bb58e-0753-4ff8-b9ef-41c46d00d6fa	64378bf8-6f34-4dc5-81da-b1fb196a7c3e	de25404e-4488-4457-ba68-22fe8ba85cd3	2026-07-20 05:56:06.688354+00	2026-07-20 05:56:06.688354+00
380bb58e-0753-4ff8-b9ef-41c46d00d6fa	0ca1e1af-afc9-498c-bb79-6bb3bc65d3fb	6212c378-ddc4-4d7c-bd8e-2ab67813df1b	2026-07-20 05:56:06.688354+00	2026-07-20 05:56:06.688354+00
380bb58e-0753-4ff8-b9ef-41c46d00d6fa	af4e23f3-f961-4eaa-9e20-dbae4f1bbe85	676644d8-c1de-405e-aad8-da18d29bea9b	2026-07-20 05:56:06.688354+00	2026-07-20 05:56:06.688354+00
380bb58e-0753-4ff8-b9ef-41c46d00d6fa	5ab53cd1-327d-42d7-9816-c02eb65d5cb3	56f41f92-66b1-43ac-bc58-a815cfdbe26e	2026-07-20 05:56:06.688354+00	2026-07-20 05:56:06.688354+00
ea464407-6559-4634-b535-cc49f7939b7e	0e06be7f-9df4-4e66-a58e-9eba6f026584	824cbf22-cc48-45be-b0b1-587523e87a9c	2026-07-20 05:56:06.688354+00	2026-07-20 05:56:06.688354+00
ea464407-6559-4634-b535-cc49f7939b7e	455d9757-37bc-4fe6-8025-e1efb66d8672	a5cec657-d145-40f8-8f38-439e3db64b05	2026-07-20 05:56:06.688354+00	2026-07-20 05:56:06.688354+00
ea464407-6559-4634-b535-cc49f7939b7e	7653733b-3526-47fd-8fa2-b6c120729ad7	4fa21aa6-1ee3-4d82-aa6b-ecd362f69578	2026-07-20 05:56:06.688354+00	2026-07-20 05:56:06.688354+00
ea464407-6559-4634-b535-cc49f7939b7e	fbfe2b53-dcf1-4ee4-acf0-7c1a3cace4db	8b64c6ca-1060-4467-bf1c-01a9033a38ea	2026-07-20 05:56:06.688354+00	2026-07-20 05:56:06.688354+00
64870cfe-8d3d-4d23-a611-14a97a14b215	0e06be7f-9df4-4e66-a58e-9eba6f026584	91808c3b-6d3c-443e-8e5a-92c67ba4e038	2026-07-20 05:56:06.688354+00	2026-07-20 05:56:06.688354+00
64870cfe-8d3d-4d23-a611-14a97a14b215	30621a70-ecd1-4c9b-a6c0-5b071dab4d1c	990fb577-3142-40ef-8e8c-3faf9f9e922d	2026-07-20 05:56:06.688354+00	2026-07-20 05:56:06.688354+00
64870cfe-8d3d-4d23-a611-14a97a14b215	7653733b-3526-47fd-8fa2-b6c120729ad7	1422ef75-00e0-4f56-84a4-50fef0ea782f	2026-07-20 05:56:06.688354+00	2026-07-20 05:56:06.688354+00
64870cfe-8d3d-4d23-a611-14a97a14b215	77fe864d-692a-4798-9e36-b464ad1c9e1c	5d5b16a1-1319-46b0-891f-a2c09b956f57	2026-07-20 05:56:06.688354+00	2026-07-20 05:56:06.688354+00
c771aebe-c485-465a-b898-a8ef09df6f98	0e06be7f-9df4-4e66-a58e-9eba6f026584	c9eda838-0dba-4507-8c64-bddbad81f4bc	2026-07-20 05:56:06.688354+00	2026-07-20 05:56:06.688354+00
c771aebe-c485-465a-b898-a8ef09df6f98	fbfe2b53-dcf1-4ee4-acf0-7c1a3cace4db	c5455cf8-896c-4053-aa72-b7e413577246	2026-07-20 05:56:06.688354+00	2026-07-20 05:56:06.688354+00
c771aebe-c485-465a-b898-a8ef09df6f98	f892958c-2fb8-40b3-ba0e-5c62223aef14	d3ea437a-92ac-4bca-b359-4925dcb4513c	2026-07-20 05:56:06.688354+00	2026-07-20 05:56:06.688354+00
c771aebe-c485-465a-b898-a8ef09df6f98	455d9757-37bc-4fe6-8025-e1efb66d8672	441b9621-260f-436a-8cc3-9e05a3ce4fa3	2026-07-20 05:56:06.688354+00	2026-07-20 05:56:06.688354+00
8284e4d9-0201-4c88-ad0e-dc4326260101	0e06be7f-9df4-4e66-a58e-9eba6f026584	bf40f9e2-ad92-49d6-820c-14127bfca46e	2026-07-20 05:56:06.688354+00	2026-07-20 05:56:06.688354+00
8284e4d9-0201-4c88-ad0e-dc4326260101	fbfe2b53-dcf1-4ee4-acf0-7c1a3cace4db	2f3d4363-7bd7-4d74-9e46-3937c6effe65	2026-07-20 05:56:06.688354+00	2026-07-20 05:56:06.688354+00
8284e4d9-0201-4c88-ad0e-dc4326260101	30621a70-ecd1-4c9b-a6c0-5b071dab4d1c	ffa177df-fbf1-4ffa-9e4c-e0f6b459a6be	2026-07-20 05:56:06.688354+00	2026-07-20 05:56:06.688354+00
8284e4d9-0201-4c88-ad0e-dc4326260101	455d9757-37bc-4fe6-8025-e1efb66d8672	04aebbc8-e3d4-4997-b8e3-865e97197f41	2026-07-20 05:56:06.688354+00	2026-07-20 05:56:06.688354+00
f72202f7-5c82-44e7-9482-6ac4f392d5d3	0e06be7f-9df4-4e66-a58e-9eba6f026584	44295c88-decd-42a8-9c34-13b6259c3597	2026-07-20 05:56:06.688354+00	2026-07-20 05:56:06.688354+00
f72202f7-5c82-44e7-9482-6ac4f392d5d3	455d9757-37bc-4fe6-8025-e1efb66d8672	1f80817d-642e-40ea-adf5-de16d6f76224	2026-07-20 05:56:06.688354+00	2026-07-20 05:56:06.688354+00
f72202f7-5c82-44e7-9482-6ac4f392d5d3	30621a70-ecd1-4c9b-a6c0-5b071dab4d1c	24e7665c-c6c9-4c5b-a7e7-e7dd344ae780	2026-07-20 05:56:06.688354+00	2026-07-20 05:56:06.688354+00
f72202f7-5c82-44e7-9482-6ac4f392d5d3	77fe864d-692a-4798-9e36-b464ad1c9e1c	3fc778f6-544a-4b5c-9300-49692c4d9ce3	2026-07-20 05:56:06.688354+00	2026-07-20 05:56:06.688354+00
9a60974f-3827-445d-b461-fbafefac8047	86adf704-3f12-404e-a458-aa2e0259864a	c76ca2fc-4c73-4e2d-935f-4447c1ecec33	2026-07-20 05:56:06.688354+00	2026-07-20 05:56:06.688354+00
9a60974f-3827-445d-b461-fbafefac8047	3e9d418d-c94e-4859-8756-2203f7d7c329	6696dc93-7642-4d11-bf86-ea4659d9b1a5	2026-07-20 05:56:06.688354+00	2026-07-20 05:56:06.688354+00
9a60974f-3827-445d-b461-fbafefac8047	5f98deeb-64ad-4c21-a955-cc484130bfa2	db96cad8-39d2-48a7-bec4-397bc3a66a26	2026-07-20 05:56:06.688354+00	2026-07-20 05:56:06.688354+00
9a60974f-3827-445d-b461-fbafefac8047	e6d6e516-bc90-467f-a35a-3c169219865e	5064aeac-896a-45ed-a271-b36fac65af9d	2026-07-20 05:56:06.688354+00	2026-07-20 05:56:06.688354+00
24168387-911b-4ecd-b6e3-d36517c7f745	86adf704-3f12-404e-a458-aa2e0259864a	d2e08dd0-f2c3-43d4-9475-a9aab65cb901	2026-07-20 05:56:06.688354+00	2026-07-20 05:56:06.688354+00
24168387-911b-4ecd-b6e3-d36517c7f745	28392456-2fc2-4f59-a145-fff7d356370c	cfd7d64b-953c-41b8-a0fe-39233fc8581e	2026-07-20 05:56:06.688354+00	2026-07-20 05:56:06.688354+00
24168387-911b-4ecd-b6e3-d36517c7f745	e6d6e516-bc90-467f-a35a-3c169219865e	028d4604-5fea-46ae-a157-8f18e97cfac9	2026-07-20 05:56:06.688354+00	2026-07-20 05:56:06.688354+00
24168387-911b-4ecd-b6e3-d36517c7f745	7be892eb-4087-4511-8e0a-5bac8a046af2	d64d4ce0-4958-46c5-be84-3c73d93e563c	2026-07-20 05:56:06.688354+00	2026-07-20 05:56:06.688354+00
b6279820-0573-42e9-9a92-593efb4b8d77	86adf704-3f12-404e-a458-aa2e0259864a	fbea1f20-ca2d-4420-b479-f0900a5ac4d0	2026-07-20 05:56:06.688354+00	2026-07-20 05:56:06.688354+00
b6279820-0573-42e9-9a92-593efb4b8d77	5f17f47c-48cd-4442-9a0b-48558bc649ce	91d96bdc-f9e9-4318-9646-348e7e42ec5c	2026-07-20 05:56:06.688354+00	2026-07-20 05:56:06.688354+00
b6279820-0573-42e9-9a92-593efb4b8d77	3e9d418d-c94e-4859-8756-2203f7d7c329	5bc4285a-353a-431d-af44-2f9a097b7e80	2026-07-20 05:56:06.688354+00	2026-07-20 05:56:06.688354+00
b6279820-0573-42e9-9a92-593efb4b8d77	e6d6e516-bc90-467f-a35a-3c169219865e	34c5861a-4947-40fe-a4ad-40df3eb22200	2026-07-20 05:56:06.688354+00	2026-07-20 05:56:06.688354+00
be059dae-45fe-4d45-84fe-6b4eafa8e856	86adf704-3f12-404e-a458-aa2e0259864a	e4e5ff51-4e50-4036-b355-5d189bfbdd31	2026-07-20 05:56:06.688354+00	2026-07-20 05:56:06.688354+00
be059dae-45fe-4d45-84fe-6b4eafa8e856	5f98deeb-64ad-4c21-a955-cc484130bfa2	42892f31-4ea2-4999-bf7f-78c0d5b38449	2026-07-20 05:56:06.688354+00	2026-07-20 05:56:06.688354+00
be059dae-45fe-4d45-84fe-6b4eafa8e856	5f17f47c-48cd-4442-9a0b-48558bc649ce	8626eb19-4776-4480-9d22-d27e76a44178	2026-07-20 05:56:06.688354+00	2026-07-20 05:56:06.688354+00
be059dae-45fe-4d45-84fe-6b4eafa8e856	7be892eb-4087-4511-8e0a-5bac8a046af2	ac2c1511-fe64-44ca-8f5d-257d76c04d7e	2026-07-20 05:56:06.688354+00	2026-07-20 05:56:06.688354+00
b5def797-6aa4-4191-afb3-8cca2c39a9e9	86adf704-3f12-404e-a458-aa2e0259864a	a358ab61-36d6-426b-b667-4d5dd60ce058	2026-07-20 05:56:06.688354+00	2026-07-20 05:56:06.688354+00
b5def797-6aa4-4191-afb3-8cca2c39a9e9	5f17f47c-48cd-4442-9a0b-48558bc649ce	01af79d5-0cdb-4f44-8104-90853618b4a2	2026-07-20 05:56:06.688354+00	2026-07-20 05:56:06.688354+00
b5def797-6aa4-4191-afb3-8cca2c39a9e9	3e9d418d-c94e-4859-8756-2203f7d7c329	d216dbca-43cd-439f-8486-89034575a5c8	2026-07-20 05:56:06.688354+00	2026-07-20 05:56:06.688354+00
b5def797-6aa4-4191-afb3-8cca2c39a9e9	28392456-2fc2-4f59-a145-fff7d356370c	40ce2a66-0581-47fb-9552-26418d573fb2	2026-07-20 05:56:06.688354+00	2026-07-20 05:56:06.688354+00
\.


--
-- Data for Name: projects; Type: TABLE DATA; Schema: public; Owner: -
--

COPY public.projects (organization_id, name, description, start_date, end_date, status, created_by_id, id, created_at, updated_at, manager_id, cooperation_start_date, department_id) FROM stdin;
d36d9bdb-efba-436c-9ad9-e7c217d45a60	بازطراحی وب‌سایت شرکتی	پروژهٔ مهندسی و فنی شماره 1	2026-06-16	2026-10-14	active	e68f76ed-4722-4f18-86a3-19ae2667e80e	4eab00a7-3204-4ae2-b34b-2100b716f70e	2026-07-20 05:56:06.688354+00	2026-07-20 05:56:06.688354+00	64378bf8-6f34-4dc5-81da-b1fb196a7c3e	2026-06-16	04f9e67c-d38e-4088-930a-5507f8cce896
d36d9bdb-efba-436c-9ad9-e7c217d45a60	توسعهٔ اپلیکیشن موبایل فروش	پروژهٔ مهندسی و فنی شماره 2	2026-06-16	2026-10-14	active	e68f76ed-4722-4f18-86a3-19ae2667e80e	edc20b03-557b-46d8-a124-3a6551c417d6	2026-07-20 05:56:06.688354+00	2026-07-20 05:56:06.688354+00	64378bf8-6f34-4dc5-81da-b1fb196a7c3e	2026-06-16	04f9e67c-d38e-4088-930a-5507f8cce896
d36d9bdb-efba-436c-9ad9-e7c217d45a60	مهاجرت زیرساخت به ابر	پروژهٔ مهندسی و فنی شماره 3	2026-06-16	2026-10-14	active	e68f76ed-4722-4f18-86a3-19ae2667e80e	b29ad29b-5190-433a-8aba-751eac914f36	2026-07-20 05:56:06.688354+00	2026-07-20 05:56:06.688354+00	64378bf8-6f34-4dc5-81da-b1fb196a7c3e	2026-06-16	04f9e67c-d38e-4088-930a-5507f8cce896
d36d9bdb-efba-436c-9ad9-e7c217d45a60	پیاده‌سازی سامانهٔ مانیتورینگ	پروژهٔ مهندسی و فنی شماره 4	2026-06-16	2026-10-14	active	e68f76ed-4722-4f18-86a3-19ae2667e80e	54a81aba-6b86-446b-b381-d27a998f3661	2026-07-20 05:56:06.688354+00	2026-07-20 05:56:06.688354+00	64378bf8-6f34-4dc5-81da-b1fb196a7c3e	2026-06-16	04f9e67c-d38e-4088-930a-5507f8cce896
d36d9bdb-efba-436c-9ad9-e7c217d45a60	بهبود عملکرد پایگاه‌داده	پروژهٔ مهندسی و فنی شماره 5	2026-06-16	2026-10-14	active	e68f76ed-4722-4f18-86a3-19ae2667e80e	380bb58e-0753-4ff8-b9ef-41c46d00d6fa	2026-07-20 05:56:06.688354+00	2026-07-20 05:56:06.688354+00	64378bf8-6f34-4dc5-81da-b1fb196a7c3e	2026-06-16	04f9e67c-d38e-4088-930a-5507f8cce896
d36d9bdb-efba-436c-9ad9-e7c217d45a60	بستن حساب‌های مالی سال	پروژهٔ حسابداری و مالی شماره 1	2026-06-16	2026-10-14	active	e68f76ed-4722-4f18-86a3-19ae2667e80e	ea464407-6559-4634-b535-cc49f7939b7e	2026-07-20 05:56:06.688354+00	2026-07-20 05:56:06.688354+00	0e06be7f-9df4-4e66-a58e-9eba6f026584	2026-06-16	7772c657-8cbb-47d4-a5cd-59293e48f79f
d36d9bdb-efba-436c-9ad9-e7c217d45a60	پیاده‌سازی سامانهٔ فاکتور الکترونیک	پروژهٔ حسابداری و مالی شماره 2	2026-06-16	2026-10-14	active	e68f76ed-4722-4f18-86a3-19ae2667e80e	64870cfe-8d3d-4d23-a611-14a97a14b215	2026-07-20 05:56:06.688354+00	2026-07-20 05:56:06.688354+00	0e06be7f-9df4-4e66-a58e-9eba6f026584	2026-06-16	7772c657-8cbb-47d4-a5cd-59293e48f79f
d36d9bdb-efba-436c-9ad9-e7c217d45a60	ممیزی مالی سه‌ماههٔ دوم	پروژهٔ حسابداری و مالی شماره 3	2026-06-16	2026-10-14	active	e68f76ed-4722-4f18-86a3-19ae2667e80e	c771aebe-c485-465a-b898-a8ef09df6f98	2026-07-20 05:56:06.688354+00	2026-07-20 05:56:06.688354+00	0e06be7f-9df4-4e66-a58e-9eba6f026584	2026-06-16	7772c657-8cbb-47d4-a5cd-59293e48f79f
d36d9bdb-efba-436c-9ad9-e7c217d45a60	تدوین بودجهٔ سال آینده	پروژهٔ حسابداری و مالی شماره 4	2026-06-16	2026-10-14	active	e68f76ed-4722-4f18-86a3-19ae2667e80e	8284e4d9-0201-4c88-ad0e-dc4326260101	2026-07-20 05:56:06.688354+00	2026-07-20 05:56:06.688354+00	0e06be7f-9df4-4e66-a58e-9eba6f026584	2026-06-16	7772c657-8cbb-47d4-a5cd-59293e48f79f
d36d9bdb-efba-436c-9ad9-e7c217d45a60	مدیریت مطالبات و بدهی‌ها	پروژهٔ حسابداری و مالی شماره 5	2026-06-16	2026-10-14	active	e68f76ed-4722-4f18-86a3-19ae2667e80e	f72202f7-5c82-44e7-9482-6ac4f392d5d3	2026-07-20 05:56:06.688354+00	2026-07-20 05:56:06.688354+00	0e06be7f-9df4-4e66-a58e-9eba6f026584	2026-06-16	7772c657-8cbb-47d4-a5cd-59293e48f79f
d36d9bdb-efba-436c-9ad9-e7c217d45a60	برگزاری دورهٔ آموزشی کارکنان	پروژهٔ منابع انسانی شماره 1	2026-06-16	2026-10-14	active	e68f76ed-4722-4f18-86a3-19ae2667e80e	9a60974f-3827-445d-b461-fbafefac8047	2026-07-20 05:56:06.688354+00	2026-07-20 05:56:06.688354+00	86adf704-3f12-404e-a458-aa2e0259864a	2026-06-16	34acf832-d975-4448-818c-dc2106e9da5f
d36d9bdb-efba-436c-9ad9-e7c217d45a60	بازطراحی فرایند جذب و استخدام	پروژهٔ منابع انسانی شماره 2	2026-06-16	2026-10-14	active	e68f76ed-4722-4f18-86a3-19ae2667e80e	24168387-911b-4ecd-b6e3-d36517c7f745	2026-07-20 05:56:06.688354+00	2026-07-20 05:56:06.688354+00	86adf704-3f12-404e-a458-aa2e0259864a	2026-06-16	34acf832-d975-4448-818c-dc2106e9da5f
d36d9bdb-efba-436c-9ad9-e7c217d45a60	ارزیابی عملکرد سالانهٔ کارکنان	پروژهٔ منابع انسانی شماره 3	2026-06-16	2026-10-14	active	e68f76ed-4722-4f18-86a3-19ae2667e80e	b6279820-0573-42e9-9a92-593efb4b8d77	2026-07-20 05:56:06.688354+00	2026-07-20 05:56:06.688354+00	86adf704-3f12-404e-a458-aa2e0259864a	2026-06-16	34acf832-d975-4448-818c-dc2106e9da5f
d36d9bdb-efba-436c-9ad9-e7c217d45a60	طراحی برنامهٔ رفاهی کارکنان	پروژهٔ منابع انسانی شماره 4	2026-06-16	2026-10-14	active	e68f76ed-4722-4f18-86a3-19ae2667e80e	be059dae-45fe-4d45-84fe-6b4eafa8e856	2026-07-20 05:56:06.688354+00	2026-07-20 05:56:06.688354+00	86adf704-3f12-404e-a458-aa2e0259864a	2026-06-16	34acf832-d975-4448-818c-dc2106e9da5f
d36d9bdb-efba-436c-9ad9-e7c217d45a60	پیاده‌سازی سامانهٔ حضور و غیاب	پروژهٔ منابع انسانی شماره 5	2026-06-16	2026-10-14	active	e68f76ed-4722-4f18-86a3-19ae2667e80e	b5def797-6aa4-4191-afb3-8cca2c39a9e9	2026-07-20 05:56:06.688354+00	2026-07-20 05:56:06.688354+00	86adf704-3f12-404e-a458-aa2e0259864a	2026-06-16	34acf832-d975-4448-818c-dc2106e9da5f
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

COPY public.tasks (organization_id, project_id, parent_task_id, assignee_id, created_by_id, title, description, priority, deadline, id, created_at, updated_at, status, approval_status, progress_percent, estimated_hours, start_date) FROM stdin;
d36d9bdb-efba-436c-9ad9-e7c217d45a60	4eab00a7-3204-4ae2-b34b-2100b716f70e	\N	64378bf8-6f34-4dc5-81da-b1fb196a7c3e	64378bf8-6f34-4dc5-81da-b1fb196a7c3e	به‌روزرسانی کتابخانه‌های وابسته #1	\N	high	2026-07-08	ea8d467b-e845-411b-9e41-4a673160ce4a	2026-07-20 05:56:06.688354+00	2026-07-20 05:56:06.688354+00	todo	\N	3	23.30	2026-06-29
d36d9bdb-efba-436c-9ad9-e7c217d45a60	4eab00a7-3204-4ae2-b34b-2100b716f70e	\N	0ca1e1af-afc9-498c-bb79-6bb3bc65d3fb	64378bf8-6f34-4dc5-81da-b1fb196a7c3e	بررسی و رفع آسیب‌پذیری امنیتی #2	\N	high	2026-07-21	2d883db3-8145-4d7b-90b8-3bfa264251e3	2026-07-20 05:56:06.688354+00	2026-07-20 05:56:06.688354+00	completed	pending	100	12.60	2026-07-12
d36d9bdb-efba-436c-9ad9-e7c217d45a60	4eab00a7-3204-4ae2-b34b-2100b716f70e	\N	7dd528cd-1bd4-4597-8589-c145df25c0fb	64378bf8-6f34-4dc5-81da-b1fb196a7c3e	نوشتن مستندات فنی API #3	\N	medium	2026-08-10	811e1543-cca9-40e2-8e11-959e6ebc36a2	2026-07-20 05:56:06.688354+00	2026-07-20 05:56:06.688354+00	todo	\N	43	12.60	2026-08-03
d36d9bdb-efba-436c-9ad9-e7c217d45a60	4eab00a7-3204-4ae2-b34b-2100b716f70e	\N	5ab53cd1-327d-42d7-9816-c02eb65d5cb3	64378bf8-6f34-4dc5-81da-b1fb196a7c3e	پیاده‌سازی صفحهٔ ورود جدید #4	\N	medium	2026-07-12	57437eb5-72b8-42d0-bf69-a74edbc5c976	2026-07-20 05:56:06.688354+00	2026-07-20 05:56:06.688354+00	archived	\N	12	15.60	2026-07-07
d36d9bdb-efba-436c-9ad9-e7c217d45a60	4eab00a7-3204-4ae2-b34b-2100b716f70e	\N	e63e7670-494e-4f3e-ba10-facf27823c40	64378bf8-6f34-4dc5-81da-b1fb196a7c3e	به‌روزرسانی کتابخانه‌های وابسته #5	\N	low	2026-07-04	89ae7477-4894-4401-aed9-382b0934c0fa	2026-07-20 05:56:06.688354+00	2026-07-20 05:56:06.688354+00	completed	approved	100	39.00	2026-06-18
d36d9bdb-efba-436c-9ad9-e7c217d45a60	4eab00a7-3204-4ae2-b34b-2100b716f70e	\N	91b406bb-3239-4e75-bc39-05289ba5787a	64378bf8-6f34-4dc5-81da-b1fb196a7c3e	بازنویسی ماژول اعلان‌ها #6	\N	high	2026-08-01	ef607db9-141e-4320-a877-245e87f3d2da	2026-07-20 05:56:06.688354+00	2026-07-20 05:56:06.688354+00	todo	\N	79	35.60	2026-07-21
d36d9bdb-efba-436c-9ad9-e7c217d45a60	4eab00a7-3204-4ae2-b34b-2100b716f70e	\N	e63e7670-494e-4f3e-ba10-facf27823c40	64378bf8-6f34-4dc5-81da-b1fb196a7c3e	تنظیم پایپ‌لاین CI/CD #7	\N	low	2026-06-23	3bdece19-1cf5-40fe-81cf-3376ac65da58	2026-07-20 05:56:06.688354+00	2026-07-20 05:56:06.688354+00	completed	approved	100	31.40	2026-06-20
d36d9bdb-efba-436c-9ad9-e7c217d45a60	4eab00a7-3204-4ae2-b34b-2100b716f70e	\N	64378bf8-6f34-4dc5-81da-b1fb196a7c3e	64378bf8-6f34-4dc5-81da-b1fb196a7c3e	پیاده‌سازی احراز هویت دومرحله‌ای #8	\N	medium	2026-08-15	96969420-4ff9-4383-b8ff-814d7e0a21c7	2026-07-20 05:56:06.688354+00	2026-07-20 05:56:06.688354+00	in_progress	\N	58	26.20	2026-08-10
d36d9bdb-efba-436c-9ad9-e7c217d45a60	4eab00a7-3204-4ae2-b34b-2100b716f70e	\N	e63e7670-494e-4f3e-ba10-facf27823c40	64378bf8-6f34-4dc5-81da-b1fb196a7c3e	افزودن تست واحد برای سرویس کاربران #9	\N	high	2026-07-22	7d59ee7d-a74d-4752-8905-1b456789b03e	2026-07-20 05:56:06.688354+00	2026-07-20 05:56:06.688354+00	todo	\N	34	28.70	2026-07-09
d36d9bdb-efba-436c-9ad9-e7c217d45a60	4eab00a7-3204-4ae2-b34b-2100b716f70e	\N	0ca1e1af-afc9-498c-bb79-6bb3bc65d3fb	64378bf8-6f34-4dc5-81da-b1fb196a7c3e	به‌روزرسانی کتابخانه‌های وابسته #10	\N	high	2026-08-02	61f476ff-a005-47a5-a20b-f0a5a6d1c245	2026-07-20 05:56:06.688354+00	2026-07-20 05:56:06.688354+00	completed	approved	100	11.30	2026-07-26
d36d9bdb-efba-436c-9ad9-e7c217d45a60	4eab00a7-3204-4ae2-b34b-2100b716f70e	\N	91b406bb-3239-4e75-bc39-05289ba5787a	64378bf8-6f34-4dc5-81da-b1fb196a7c3e	افزودن تست واحد برای سرویس کاربران #11	\N	high	2026-07-22	8205d990-e951-4f2a-a1d7-ae239f6afb32	2026-07-20 05:56:06.688354+00	2026-07-20 05:56:06.688354+00	in_progress	\N	41	34.00	2026-07-03
d36d9bdb-efba-436c-9ad9-e7c217d45a60	4eab00a7-3204-4ae2-b34b-2100b716f70e	\N	7dd528cd-1bd4-4597-8589-c145df25c0fb	64378bf8-6f34-4dc5-81da-b1fb196a7c3e	رفع مشکل ناسازگاری مرورگر #12	\N	medium	2026-07-03	a1fa30de-5f98-4837-98ce-0ce08bf4bd37	2026-07-20 05:56:06.688354+00	2026-07-20 05:56:06.688354+00	todo	\N	51	12.20	2026-06-30
d36d9bdb-efba-436c-9ad9-e7c217d45a60	4eab00a7-3204-4ae2-b34b-2100b716f70e	\N	5ab53cd1-327d-42d7-9816-c02eb65d5cb3	64378bf8-6f34-4dc5-81da-b1fb196a7c3e	تنظیم پایپ‌لاین CI/CD #13	\N	medium	2026-07-14	15d826ec-8046-4d9b-936d-cf11c89c3393	2026-07-20 05:56:06.688354+00	2026-07-20 05:56:06.688354+00	completed	pending	100	17.00	2026-07-06
d36d9bdb-efba-436c-9ad9-e7c217d45a60	4eab00a7-3204-4ae2-b34b-2100b716f70e	\N	0ca1e1af-afc9-498c-bb79-6bb3bc65d3fb	64378bf8-6f34-4dc5-81da-b1fb196a7c3e	نوشتن مستندات فنی API #14	\N	high	2026-07-03	54e34542-7990-4409-be67-a2c170f52980	2026-07-20 05:56:06.688354+00	2026-07-20 05:56:06.688354+00	completed	approved	100	22.50	2026-06-24
d36d9bdb-efba-436c-9ad9-e7c217d45a60	4eab00a7-3204-4ae2-b34b-2100b716f70e	\N	0ca1e1af-afc9-498c-bb79-6bb3bc65d3fb	64378bf8-6f34-4dc5-81da-b1fb196a7c3e	رفع مشکل کندی بارگذاری صفحه #15	\N	low	2026-08-06	0959d618-ea54-462b-a690-9252427575af	2026-07-20 05:56:06.688354+00	2026-07-20 05:56:06.688354+00	completed	approved	100	39.90	2026-07-23
d36d9bdb-efba-436c-9ad9-e7c217d45a60	4eab00a7-3204-4ae2-b34b-2100b716f70e	\N	5ab53cd1-327d-42d7-9816-c02eb65d5cb3	64378bf8-6f34-4dc5-81da-b1fb196a7c3e	بازنویسی ماژول اعلان‌ها #16	\N	low	2026-08-06	9e78ad64-74de-475d-a410-0e9aa2dbe8b1	2026-07-20 05:56:06.688354+00	2026-07-20 05:56:06.688354+00	completed	approved	100	7.80	2026-08-03
d36d9bdb-efba-436c-9ad9-e7c217d45a60	4eab00a7-3204-4ae2-b34b-2100b716f70e	\N	5ab53cd1-327d-42d7-9816-c02eb65d5cb3	64378bf8-6f34-4dc5-81da-b1fb196a7c3e	پیاده‌سازی احراز هویت دومرحله‌ای #17	\N	high	2026-07-04	cd07d5e4-2379-4062-863f-e5d458935133	2026-07-20 05:56:06.688354+00	2026-07-20 05:56:06.688354+00	completed	approved	100	39.90	2026-06-20
d36d9bdb-efba-436c-9ad9-e7c217d45a60	4eab00a7-3204-4ae2-b34b-2100b716f70e	\N	af4e23f3-f961-4eaa-9e20-dbae4f1bbe85	64378bf8-6f34-4dc5-81da-b1fb196a7c3e	تنظیم پایپ‌لاین CI/CD #18	\N	high	2026-07-23	9736eed2-0716-47a7-be6c-16596929b86f	2026-07-20 05:56:06.688354+00	2026-07-20 05:56:06.688354+00	in_progress	\N	14	27.90	2026-07-21
d36d9bdb-efba-436c-9ad9-e7c217d45a60	edc20b03-557b-46d8-a124-3a6551c417d6	\N	af4e23f3-f961-4eaa-9e20-dbae4f1bbe85	64378bf8-6f34-4dc5-81da-b1fb196a7c3e	پیاده‌سازی صفحهٔ ورود جدید #19	\N	medium	2026-07-15	02aee0df-3421-48ad-8355-85e525336cd9	2026-07-20 05:56:06.688354+00	2026-07-20 05:56:06.688354+00	archived	\N	55	8.00	2026-07-03
d36d9bdb-efba-436c-9ad9-e7c217d45a60	edc20b03-557b-46d8-a124-3a6551c417d6	\N	64378bf8-6f34-4dc5-81da-b1fb196a7c3e	64378bf8-6f34-4dc5-81da-b1fb196a7c3e	به‌روزرسانی کتابخانه‌های وابسته #20	\N	low	2026-08-21	2f58b49e-2d9e-4e6c-ac8f-ab55f1b279a2	2026-07-20 05:56:06.688354+00	2026-07-20 05:56:06.688354+00	archived	\N	64	36.70	2026-08-11
d36d9bdb-efba-436c-9ad9-e7c217d45a60	edc20b03-557b-46d8-a124-3a6551c417d6	\N	7dd528cd-1bd4-4597-8589-c145df25c0fb	64378bf8-6f34-4dc5-81da-b1fb196a7c3e	پیاده‌سازی صفحهٔ داشبورد مدیریتی #21	\N	low	2026-08-13	326cb599-706d-48ab-afd6-bb7ff7d9f899	2026-07-20 05:56:06.688354+00	2026-07-20 05:56:06.688354+00	completed	approved	100	7.80	2026-07-26
d36d9bdb-efba-436c-9ad9-e7c217d45a60	edc20b03-557b-46d8-a124-3a6551c417d6	\N	7dd528cd-1bd4-4597-8589-c145df25c0fb	64378bf8-6f34-4dc5-81da-b1fb196a7c3e	افزودن قابلیت جست‌وجوی پیشرفته #22	\N	low	2026-08-07	31a365dc-76af-43a3-b763-dedf21e89ed4	2026-07-20 05:56:06.688354+00	2026-07-20 05:56:06.688354+00	todo	\N	76	14.30	2026-07-20
d36d9bdb-efba-436c-9ad9-e7c217d45a60	edc20b03-557b-46d8-a124-3a6551c417d6	\N	64378bf8-6f34-4dc5-81da-b1fb196a7c3e	64378bf8-6f34-4dc5-81da-b1fb196a7c3e	افزودن قابلیت جست‌وجوی پیشرفته #23	\N	medium	2026-08-27	bd6ab867-edb6-418a-b682-ef4fa7ec3b17	2026-07-20 05:56:06.688354+00	2026-07-20 05:56:06.688354+00	todo	\N	30	4.20	2026-08-14
d36d9bdb-efba-436c-9ad9-e7c217d45a60	edc20b03-557b-46d8-a124-3a6551c417d6	\N	af4e23f3-f961-4eaa-9e20-dbae4f1bbe85	64378bf8-6f34-4dc5-81da-b1fb196a7c3e	بازنویسی ماژول اعلان‌ها #24	\N	low	2026-07-08	4974cde0-62eb-472e-b179-45766abf86cd	2026-07-20 05:56:06.688354+00	2026-07-20 05:56:06.688354+00	todo	\N	68	31.10	2026-06-21
d36d9bdb-efba-436c-9ad9-e7c217d45a60	edc20b03-557b-46d8-a124-3a6551c417d6	\N	5ab53cd1-327d-42d7-9816-c02eb65d5cb3	64378bf8-6f34-4dc5-81da-b1fb196a7c3e	طراحی API نسخهٔ دوم #25	\N	high	2026-07-28	ca5156dd-409e-41e7-b01e-fce1fcb9c5c7	2026-07-20 05:56:06.688354+00	2026-07-20 05:56:06.688354+00	completed	approved	100	35.20	2026-07-21
d36d9bdb-efba-436c-9ad9-e7c217d45a60	edc20b03-557b-46d8-a124-3a6551c417d6	\N	91b406bb-3239-4e75-bc39-05289ba5787a	64378bf8-6f34-4dc5-81da-b1fb196a7c3e	رفع مشکل ناسازگاری مرورگر #26	\N	high	2026-09-02	8b97963f-5645-46bf-8fea-56a7d9a133d6	2026-07-20 05:56:06.688354+00	2026-07-20 05:56:06.688354+00	in_progress	\N	25	29.10	2026-08-14
d36d9bdb-efba-436c-9ad9-e7c217d45a60	edc20b03-557b-46d8-a124-3a6551c417d6	\N	91b406bb-3239-4e75-bc39-05289ba5787a	64378bf8-6f34-4dc5-81da-b1fb196a7c3e	بررسی و رفع آسیب‌پذیری امنیتی #27	\N	low	2026-08-01	a3936e6f-d34d-478b-8041-386139a5a687	2026-07-20 05:56:06.688354+00	2026-07-20 05:56:06.688354+00	completed	pending	100	11.40	2026-07-14
d36d9bdb-efba-436c-9ad9-e7c217d45a60	edc20b03-557b-46d8-a124-3a6551c417d6	\N	64378bf8-6f34-4dc5-81da-b1fb196a7c3e	64378bf8-6f34-4dc5-81da-b1fb196a7c3e	به‌روزرسانی کتابخانه‌های وابسته #28	\N	low	2026-07-07	97115d73-dedc-4f03-be86-0247a51b3db9	2026-07-20 05:56:06.688354+00	2026-07-20 05:56:06.688354+00	in_progress	\N	75	10.40	2026-06-17
d36d9bdb-efba-436c-9ad9-e7c217d45a60	edc20b03-557b-46d8-a124-3a6551c417d6	\N	64378bf8-6f34-4dc5-81da-b1fb196a7c3e	64378bf8-6f34-4dc5-81da-b1fb196a7c3e	افزودن تست واحد برای سرویس کاربران #29	\N	low	2026-07-29	6c222734-173e-4f7b-be60-48ebe02740cc	2026-07-20 05:56:06.688354+00	2026-07-20 05:56:06.688354+00	archived	\N	4	34.70	2026-07-26
d36d9bdb-efba-436c-9ad9-e7c217d45a60	edc20b03-557b-46d8-a124-3a6551c417d6	\N	64378bf8-6f34-4dc5-81da-b1fb196a7c3e	64378bf8-6f34-4dc5-81da-b1fb196a7c3e	افزودن تست واحد برای سرویس کاربران #30	\N	high	2026-08-14	1ffe4e58-6f91-42a0-accb-1d6831a5b935	2026-07-20 05:56:06.688354+00	2026-07-20 05:56:06.688354+00	completed	approved	100	7.00	2026-07-28
d36d9bdb-efba-436c-9ad9-e7c217d45a60	edc20b03-557b-46d8-a124-3a6551c417d6	\N	af4e23f3-f961-4eaa-9e20-dbae4f1bbe85	64378bf8-6f34-4dc5-81da-b1fb196a7c3e	رفع مشکل ناسازگاری مرورگر #31	\N	medium	2026-08-22	b4c0b53b-3c32-49de-bd15-78a43143578a	2026-07-20 05:56:06.688354+00	2026-07-20 05:56:06.688354+00	completed	approved	100	9.20	2026-08-05
d36d9bdb-efba-436c-9ad9-e7c217d45a60	edc20b03-557b-46d8-a124-3a6551c417d6	\N	64378bf8-6f34-4dc5-81da-b1fb196a7c3e	64378bf8-6f34-4dc5-81da-b1fb196a7c3e	بررسی و رفع آسیب‌پذیری امنیتی #32	\N	high	2026-07-28	60e262f6-ae68-4d40-8953-7220b83bd638	2026-07-20 05:56:06.688354+00	2026-07-20 05:56:06.688354+00	completed	approved	100	4.10	2026-07-13
d36d9bdb-efba-436c-9ad9-e7c217d45a60	edc20b03-557b-46d8-a124-3a6551c417d6	\N	0ca1e1af-afc9-498c-bb79-6bb3bc65d3fb	64378bf8-6f34-4dc5-81da-b1fb196a7c3e	رفع مشکل ناسازگاری مرورگر #33	\N	low	2026-07-23	c3cdea31-255e-484f-b9e4-86a068417c10	2026-07-20 05:56:06.688354+00	2026-07-20 05:56:06.688354+00	completed	approved	100	11.40	2026-07-11
d36d9bdb-efba-436c-9ad9-e7c217d45a60	edc20b03-557b-46d8-a124-3a6551c417d6	\N	5ab53cd1-327d-42d7-9816-c02eb65d5cb3	64378bf8-6f34-4dc5-81da-b1fb196a7c3e	طراحی API نسخهٔ دوم #34	\N	medium	2026-07-20	954ec3f9-3185-4656-92b2-f1a12db8fde8	2026-07-20 05:56:06.688354+00	2026-07-20 05:56:06.688354+00	completed	approved	100	11.50	2026-07-13
d36d9bdb-efba-436c-9ad9-e7c217d45a60	edc20b03-557b-46d8-a124-3a6551c417d6	\N	64378bf8-6f34-4dc5-81da-b1fb196a7c3e	64378bf8-6f34-4dc5-81da-b1fb196a7c3e	پیاده‌سازی صفحهٔ ورود جدید #35	\N	low	2026-08-28	71efdfd0-cbb2-4f12-80f4-176286d5062b	2026-07-20 05:56:06.688354+00	2026-07-20 05:56:06.688354+00	completed	pending	100	26.80	2026-08-09
d36d9bdb-efba-436c-9ad9-e7c217d45a60	edc20b03-557b-46d8-a124-3a6551c417d6	\N	af4e23f3-f961-4eaa-9e20-dbae4f1bbe85	64378bf8-6f34-4dc5-81da-b1fb196a7c3e	بهینه‌سازی کوئری‌های گزارش‌گیری #36	\N	medium	2026-06-30	dd87b9fb-a616-4bc4-bee9-34deb2c37fbc	2026-07-20 05:56:06.688354+00	2026-07-20 05:56:06.688354+00	todo	\N	62	20.30	2026-06-21
d36d9bdb-efba-436c-9ad9-e7c217d45a60	b29ad29b-5190-433a-8aba-751eac914f36	\N	7dd528cd-1bd4-4597-8589-c145df25c0fb	64378bf8-6f34-4dc5-81da-b1fb196a7c3e	بهینه‌سازی کوئری‌های گزارش‌گیری #37	\N	medium	2026-08-15	a221bfb2-168a-4c95-8626-0fc188256aae	2026-07-20 05:56:06.688354+00	2026-07-20 05:56:06.688354+00	in_progress	\N	0	39.40	2026-08-12
d36d9bdb-efba-436c-9ad9-e7c217d45a60	b29ad29b-5190-433a-8aba-751eac914f36	\N	e63e7670-494e-4f3e-ba10-facf27823c40	64378bf8-6f34-4dc5-81da-b1fb196a7c3e	تنظیم پایپ‌لاین CI/CD #38	\N	high	2026-08-18	6cdcd710-15d0-456b-8d89-f99a182d3f7b	2026-07-20 05:56:06.688354+00	2026-07-20 05:56:06.688354+00	completed	approved	100	20.50	2026-07-30
d36d9bdb-efba-436c-9ad9-e7c217d45a60	b29ad29b-5190-433a-8aba-751eac914f36	\N	5ab53cd1-327d-42d7-9816-c02eb65d5cb3	64378bf8-6f34-4dc5-81da-b1fb196a7c3e	پیاده‌سازی صفحهٔ داشبورد مدیریتی #39	\N	high	2026-07-02	8415a1e9-8112-41a8-900b-451be31a179b	2026-07-20 05:56:06.688354+00	2026-07-20 05:56:06.688354+00	in_progress	\N	69	4.30	2026-06-29
d36d9bdb-efba-436c-9ad9-e7c217d45a60	b29ad29b-5190-433a-8aba-751eac914f36	\N	e63e7670-494e-4f3e-ba10-facf27823c40	64378bf8-6f34-4dc5-81da-b1fb196a7c3e	بررسی و رفع آسیب‌پذیری امنیتی #40	\N	high	2026-07-09	9fab991f-74c6-4123-9739-fca67bbabf92	2026-07-20 05:56:06.688354+00	2026-07-20 05:56:06.688354+00	todo	\N	67	8.00	2026-06-19
d36d9bdb-efba-436c-9ad9-e7c217d45a60	b29ad29b-5190-433a-8aba-751eac914f36	\N	af4e23f3-f961-4eaa-9e20-dbae4f1bbe85	64378bf8-6f34-4dc5-81da-b1fb196a7c3e	پیاده‌سازی صفحهٔ ورود جدید #41	\N	high	2026-08-16	b1d444cf-be0b-4890-ae9b-c85fd8588556	2026-07-20 05:56:06.688354+00	2026-07-20 05:56:06.688354+00	todo	\N	8	27.70	2026-08-09
d36d9bdb-efba-436c-9ad9-e7c217d45a60	b29ad29b-5190-433a-8aba-751eac914f36	\N	5ab53cd1-327d-42d7-9816-c02eb65d5cb3	64378bf8-6f34-4dc5-81da-b1fb196a7c3e	افزودن تست واحد برای سرویس کاربران #42	\N	high	2026-07-13	308e5ede-eeff-4040-9d3d-4795f7b18d72	2026-07-20 05:56:06.688354+00	2026-07-20 05:56:06.688354+00	in_progress	\N	76	3.50	2026-06-23
d36d9bdb-efba-436c-9ad9-e7c217d45a60	b29ad29b-5190-433a-8aba-751eac914f36	\N	64378bf8-6f34-4dc5-81da-b1fb196a7c3e	64378bf8-6f34-4dc5-81da-b1fb196a7c3e	پیاده‌سازی صفحهٔ داشبورد مدیریتی #43	\N	high	2026-08-17	2425f436-df43-41d0-9dbf-19b03f14ea02	2026-07-20 05:56:06.688354+00	2026-07-20 05:56:06.688354+00	in_progress	\N	40	37.50	2026-07-28
d36d9bdb-efba-436c-9ad9-e7c217d45a60	b29ad29b-5190-433a-8aba-751eac914f36	\N	5ab53cd1-327d-42d7-9816-c02eb65d5cb3	64378bf8-6f34-4dc5-81da-b1fb196a7c3e	پیاده‌سازی احراز هویت دومرحله‌ای #44	\N	low	2026-07-11	618b16c0-1101-496c-8575-7484305ec332	2026-07-20 05:56:06.688354+00	2026-07-20 05:56:06.688354+00	completed	pending	100	27.50	2026-07-01
d36d9bdb-efba-436c-9ad9-e7c217d45a60	b29ad29b-5190-433a-8aba-751eac914f36	\N	e63e7670-494e-4f3e-ba10-facf27823c40	64378bf8-6f34-4dc5-81da-b1fb196a7c3e	رفع باگ در ماژول پرداخت #45	\N	medium	2026-08-07	0993396a-57b0-4f9a-a5e9-8ab5fff500ee	2026-07-20 05:56:06.688354+00	2026-07-20 05:56:06.688354+00	completed	approved	100	25.60	2026-08-03
d36d9bdb-efba-436c-9ad9-e7c217d45a60	b29ad29b-5190-433a-8aba-751eac914f36	\N	af4e23f3-f961-4eaa-9e20-dbae4f1bbe85	64378bf8-6f34-4dc5-81da-b1fb196a7c3e	افزودن تست واحد برای سرویس کاربران #46	\N	high	2026-07-09	546f6a56-c4a1-481f-b457-2003e49ae5ea	2026-07-20 05:56:06.688354+00	2026-07-20 05:56:06.688354+00	todo	\N	33	7.00	2026-06-20
d36d9bdb-efba-436c-9ad9-e7c217d45a60	b29ad29b-5190-433a-8aba-751eac914f36	\N	e63e7670-494e-4f3e-ba10-facf27823c40	64378bf8-6f34-4dc5-81da-b1fb196a7c3e	رفع مشکل کندی بارگذاری صفحه #47	\N	medium	2026-08-20	6535aca5-64a7-447c-a46c-a0f0789e64ef	2026-07-20 05:56:06.688354+00	2026-07-20 05:56:06.688354+00	todo	\N	20	18.70	2026-08-11
d36d9bdb-efba-436c-9ad9-e7c217d45a60	b29ad29b-5190-433a-8aba-751eac914f36	\N	af4e23f3-f961-4eaa-9e20-dbae4f1bbe85	64378bf8-6f34-4dc5-81da-b1fb196a7c3e	رفع مشکل ناسازگاری مرورگر #48	\N	high	2026-07-26	f8d7911e-e7e1-45c7-aabf-c6aab8d083ad	2026-07-20 05:56:06.688354+00	2026-07-20 05:56:06.688354+00	archived	\N	67	2.30	2026-07-05
d36d9bdb-efba-436c-9ad9-e7c217d45a60	b29ad29b-5190-433a-8aba-751eac914f36	\N	7dd528cd-1bd4-4597-8589-c145df25c0fb	64378bf8-6f34-4dc5-81da-b1fb196a7c3e	افزودن قابلیت جست‌وجوی پیشرفته #49	\N	low	2026-08-02	09b115b5-4316-4fa6-90f1-d78c61fa4503	2026-07-20 05:56:06.688354+00	2026-07-20 05:56:06.688354+00	completed	approved	100	12.00	2026-07-28
d36d9bdb-efba-436c-9ad9-e7c217d45a60	b29ad29b-5190-433a-8aba-751eac914f36	\N	64378bf8-6f34-4dc5-81da-b1fb196a7c3e	64378bf8-6f34-4dc5-81da-b1fb196a7c3e	طراحی API نسخهٔ دوم #50	\N	medium	2026-07-27	619b3f84-279a-4650-abe8-a9f4eb4e8a92	2026-07-20 05:56:06.688354+00	2026-07-20 05:56:06.688354+00	archived	\N	77	10.00	2026-07-21
d36d9bdb-efba-436c-9ad9-e7c217d45a60	b29ad29b-5190-433a-8aba-751eac914f36	\N	e63e7670-494e-4f3e-ba10-facf27823c40	64378bf8-6f34-4dc5-81da-b1fb196a7c3e	به‌روزرسانی کتابخانه‌های وابسته #51	\N	medium	2026-08-08	dd16af52-9829-4404-bf6c-38754fd65b49	2026-07-20 05:56:06.688354+00	2026-07-20 05:56:06.688354+00	in_progress	\N	32	36.40	2026-07-29
d36d9bdb-efba-436c-9ad9-e7c217d45a60	b29ad29b-5190-433a-8aba-751eac914f36	\N	7dd528cd-1bd4-4597-8589-c145df25c0fb	64378bf8-6f34-4dc5-81da-b1fb196a7c3e	بازنویسی ماژول اعلان‌ها #52	\N	medium	2026-07-06	bd260681-250b-43e1-ba7d-72bc18388b12	2026-07-20 05:56:06.688354+00	2026-07-20 05:56:06.688354+00	todo	\N	5	2.10	2026-06-21
d36d9bdb-efba-436c-9ad9-e7c217d45a60	b29ad29b-5190-433a-8aba-751eac914f36	\N	7dd528cd-1bd4-4597-8589-c145df25c0fb	64378bf8-6f34-4dc5-81da-b1fb196a7c3e	بهینه‌سازی کوئری‌های گزارش‌گیری #53	\N	high	2026-08-05	642c8c7c-952a-4895-92f4-7bfa09216c78	2026-07-20 05:56:06.688354+00	2026-07-20 05:56:06.688354+00	todo	\N	56	23.00	2026-07-26
d36d9bdb-efba-436c-9ad9-e7c217d45a60	b29ad29b-5190-433a-8aba-751eac914f36	\N	91b406bb-3239-4e75-bc39-05289ba5787a	64378bf8-6f34-4dc5-81da-b1fb196a7c3e	به‌روزرسانی کتابخانه‌های وابسته #54	\N	low	2026-06-26	bfaae234-46bf-4619-906e-9ce519d62c1c	2026-07-20 05:56:06.688354+00	2026-07-20 05:56:06.688354+00	completed	approved	100	33.70	2026-06-20
d36d9bdb-efba-436c-9ad9-e7c217d45a60	54a81aba-6b86-446b-b381-d27a998f3661	\N	af4e23f3-f961-4eaa-9e20-dbae4f1bbe85	64378bf8-6f34-4dc5-81da-b1fb196a7c3e	طراحی API نسخهٔ دوم #55	\N	medium	2026-06-27	081c43c9-ceb9-435f-bebc-9cd57b9fcfc4	2026-07-20 05:56:06.688354+00	2026-07-20 05:56:06.688354+00	completed	approved	100	36.20	2026-06-24
d36d9bdb-efba-436c-9ad9-e7c217d45a60	54a81aba-6b86-446b-b381-d27a998f3661	\N	7dd528cd-1bd4-4597-8589-c145df25c0fb	64378bf8-6f34-4dc5-81da-b1fb196a7c3e	افزودن تست واحد برای سرویس کاربران #56	\N	high	2026-08-25	9a0ff6a5-a589-4193-9ade-9a2a7be4587d	2026-07-20 05:56:06.688354+00	2026-07-20 05:56:06.688354+00	todo	\N	31	27.30	2026-08-12
d36d9bdb-efba-436c-9ad9-e7c217d45a60	54a81aba-6b86-446b-b381-d27a998f3661	\N	e63e7670-494e-4f3e-ba10-facf27823c40	64378bf8-6f34-4dc5-81da-b1fb196a7c3e	پیاده‌سازی صفحهٔ داشبورد مدیریتی #57	\N	high	2026-08-05	1b2e7ad9-8b46-485e-a3f9-b29e38e7c9ef	2026-07-20 05:56:06.688354+00	2026-07-20 05:56:06.688354+00	archived	\N	19	37.20	2026-07-21
d36d9bdb-efba-436c-9ad9-e7c217d45a60	54a81aba-6b86-446b-b381-d27a998f3661	\N	5ab53cd1-327d-42d7-9816-c02eb65d5cb3	64378bf8-6f34-4dc5-81da-b1fb196a7c3e	افزودن قابلیت جست‌وجوی پیشرفته #58	\N	medium	2026-08-13	45eb0866-efd3-44f7-8fc1-c1456d5a1495	2026-07-20 05:56:06.688354+00	2026-07-20 05:56:06.688354+00	todo	\N	3	8.80	2026-08-06
d36d9bdb-efba-436c-9ad9-e7c217d45a60	54a81aba-6b86-446b-b381-d27a998f3661	\N	e63e7670-494e-4f3e-ba10-facf27823c40	64378bf8-6f34-4dc5-81da-b1fb196a7c3e	طراحی API نسخهٔ دوم #59	\N	low	2026-08-15	e113d339-e68d-4443-b7f7-22186fd83426	2026-07-20 05:56:06.688354+00	2026-07-20 05:56:06.688354+00	in_progress	\N	13	16.50	2026-08-06
d36d9bdb-efba-436c-9ad9-e7c217d45a60	54a81aba-6b86-446b-b381-d27a998f3661	\N	64378bf8-6f34-4dc5-81da-b1fb196a7c3e	64378bf8-6f34-4dc5-81da-b1fb196a7c3e	رفع مشکل کندی بارگذاری صفحه #60	\N	medium	2026-08-23	27c91b57-5b16-44f7-9dbd-e46bd7ae1fef	2026-07-20 05:56:06.688354+00	2026-07-20 05:56:06.688354+00	completed	approved	100	33.20	2026-08-07
d36d9bdb-efba-436c-9ad9-e7c217d45a60	54a81aba-6b86-446b-b381-d27a998f3661	\N	7dd528cd-1bd4-4597-8589-c145df25c0fb	64378bf8-6f34-4dc5-81da-b1fb196a7c3e	تنظیم پایپ‌لاین CI/CD #61	\N	low	2026-07-02	338ea956-f33b-4ac7-aa0e-4f32a21c18fd	2026-07-20 05:56:06.688354+00	2026-07-20 05:56:06.688354+00	in_progress	\N	51	14.50	2026-06-30
d36d9bdb-efba-436c-9ad9-e7c217d45a60	54a81aba-6b86-446b-b381-d27a998f3661	\N	7dd528cd-1bd4-4597-8589-c145df25c0fb	64378bf8-6f34-4dc5-81da-b1fb196a7c3e	رفع مشکل کندی بارگذاری صفحه #62	\N	high	2026-08-14	019e92f7-612e-427c-8596-135e32968782	2026-07-20 05:56:06.688354+00	2026-07-20 05:56:06.688354+00	todo	\N	65	17.20	2026-08-04
d36d9bdb-efba-436c-9ad9-e7c217d45a60	54a81aba-6b86-446b-b381-d27a998f3661	\N	7dd528cd-1bd4-4597-8589-c145df25c0fb	64378bf8-6f34-4dc5-81da-b1fb196a7c3e	افزودن قابلیت جست‌وجوی پیشرفته #63	\N	medium	2026-06-22	feaeacdb-e4fa-4643-ad00-2dc6beed93f2	2026-07-20 05:56:06.688354+00	2026-07-20 05:56:06.688354+00	completed	approved	100	8.80	2026-06-17
d36d9bdb-efba-436c-9ad9-e7c217d45a60	54a81aba-6b86-446b-b381-d27a998f3661	\N	e63e7670-494e-4f3e-ba10-facf27823c40	64378bf8-6f34-4dc5-81da-b1fb196a7c3e	پیاده‌سازی احراز هویت دومرحله‌ای #64	\N	medium	2026-07-13	20ced081-fbb3-4efd-9d50-df3811d799f7	2026-07-20 05:56:06.688354+00	2026-07-20 05:56:06.688354+00	todo	\N	40	18.60	2026-06-22
d36d9bdb-efba-436c-9ad9-e7c217d45a60	54a81aba-6b86-446b-b381-d27a998f3661	\N	af4e23f3-f961-4eaa-9e20-dbae4f1bbe85	64378bf8-6f34-4dc5-81da-b1fb196a7c3e	افزودن تست واحد برای سرویس کاربران #65	\N	medium	2026-07-30	f2e2f1ef-dfbe-4eaa-b08b-6325f425aa1c	2026-07-20 05:56:06.688354+00	2026-07-20 05:56:06.688354+00	todo	\N	5	28.90	2026-07-10
d36d9bdb-efba-436c-9ad9-e7c217d45a60	54a81aba-6b86-446b-b381-d27a998f3661	\N	64378bf8-6f34-4dc5-81da-b1fb196a7c3e	64378bf8-6f34-4dc5-81da-b1fb196a7c3e	رفع مشکل کندی بارگذاری صفحه #66	\N	medium	2026-07-28	dc10d0c5-7ac2-443d-8bc8-71a610eddbcf	2026-07-20 05:56:06.688354+00	2026-07-20 05:56:06.688354+00	completed	rejected	100	4.70	2026-07-20
d36d9bdb-efba-436c-9ad9-e7c217d45a60	54a81aba-6b86-446b-b381-d27a998f3661	\N	0ca1e1af-afc9-498c-bb79-6bb3bc65d3fb	64378bf8-6f34-4dc5-81da-b1fb196a7c3e	تنظیم پایپ‌لاین CI/CD #67	\N	low	2026-08-06	d9a8562c-c4e9-41d7-8652-bef0f8b650cc	2026-07-20 05:56:06.688354+00	2026-07-20 05:56:06.688354+00	in_progress	\N	38	21.30	2026-07-25
d36d9bdb-efba-436c-9ad9-e7c217d45a60	54a81aba-6b86-446b-b381-d27a998f3661	\N	0ca1e1af-afc9-498c-bb79-6bb3bc65d3fb	64378bf8-6f34-4dc5-81da-b1fb196a7c3e	نوشتن مستندات فنی API #68	\N	medium	2026-07-20	06d4306a-91ad-40fd-9b1f-b91aff05b041	2026-07-20 05:56:06.688354+00	2026-07-20 05:56:06.688354+00	in_progress	\N	70	6.80	2026-07-06
d36d9bdb-efba-436c-9ad9-e7c217d45a60	54a81aba-6b86-446b-b381-d27a998f3661	\N	91b406bb-3239-4e75-bc39-05289ba5787a	64378bf8-6f34-4dc5-81da-b1fb196a7c3e	پیاده‌سازی صفحهٔ داشبورد مدیریتی #69	\N	high	2026-08-05	75cd2e8a-3e44-4ab8-86d7-95819c6072d0	2026-07-20 05:56:06.688354+00	2026-07-20 05:56:06.688354+00	completed	rejected	100	13.40	2026-07-29
d36d9bdb-efba-436c-9ad9-e7c217d45a60	54a81aba-6b86-446b-b381-d27a998f3661	\N	af4e23f3-f961-4eaa-9e20-dbae4f1bbe85	64378bf8-6f34-4dc5-81da-b1fb196a7c3e	افزودن تست واحد برای سرویس کاربران #70	\N	medium	2026-07-16	a7257f84-72f9-4995-966a-f6f68da02c27	2026-07-20 05:56:06.688354+00	2026-07-20 05:56:06.688354+00	todo	\N	74	25.10	2026-07-05
d36d9bdb-efba-436c-9ad9-e7c217d45a60	54a81aba-6b86-446b-b381-d27a998f3661	\N	e63e7670-494e-4f3e-ba10-facf27823c40	64378bf8-6f34-4dc5-81da-b1fb196a7c3e	به‌روزرسانی کتابخانه‌های وابسته #71	\N	medium	2026-08-06	2f8d5b34-078d-468c-a8e4-b666f856f278	2026-07-20 05:56:06.688354+00	2026-07-20 05:56:06.688354+00	completed	approved	100	32.20	2026-07-29
d36d9bdb-efba-436c-9ad9-e7c217d45a60	54a81aba-6b86-446b-b381-d27a998f3661	\N	7dd528cd-1bd4-4597-8589-c145df25c0fb	64378bf8-6f34-4dc5-81da-b1fb196a7c3e	طراحی API نسخهٔ دوم #72	\N	high	2026-06-30	cd9127f2-8414-429f-a4b4-79a2cebeeec1	2026-07-20 05:56:06.688354+00	2026-07-20 05:56:06.688354+00	archived	\N	79	14.70	2026-06-26
d36d9bdb-efba-436c-9ad9-e7c217d45a60	380bb58e-0753-4ff8-b9ef-41c46d00d6fa	\N	7dd528cd-1bd4-4597-8589-c145df25c0fb	64378bf8-6f34-4dc5-81da-b1fb196a7c3e	افزودن تست واحد برای سرویس کاربران #73	\N	low	2026-07-12	9d86c98f-176e-4e5a-a9bc-9e05d8c9f249	2026-07-20 05:56:06.688354+00	2026-07-20 05:56:06.688354+00	archived	\N	18	2.90	2026-07-01
d36d9bdb-efba-436c-9ad9-e7c217d45a60	380bb58e-0753-4ff8-b9ef-41c46d00d6fa	\N	5ab53cd1-327d-42d7-9816-c02eb65d5cb3	64378bf8-6f34-4dc5-81da-b1fb196a7c3e	بررسی و رفع آسیب‌پذیری امنیتی #74	\N	medium	2026-08-08	18b6be60-53b6-4ef0-a789-4ddb9e27f9b6	2026-07-20 05:56:06.688354+00	2026-07-20 05:56:06.688354+00	completed	pending	100	35.70	2026-08-04
d36d9bdb-efba-436c-9ad9-e7c217d45a60	380bb58e-0753-4ff8-b9ef-41c46d00d6fa	\N	af4e23f3-f961-4eaa-9e20-dbae4f1bbe85	64378bf8-6f34-4dc5-81da-b1fb196a7c3e	بررسی و رفع آسیب‌پذیری امنیتی #75	\N	medium	2026-08-14	3dfe981d-35c7-406e-91c4-0b6309ebe47c	2026-07-20 05:56:06.688354+00	2026-07-20 05:56:06.688354+00	todo	\N	31	7.60	2026-07-31
d36d9bdb-efba-436c-9ad9-e7c217d45a60	380bb58e-0753-4ff8-b9ef-41c46d00d6fa	\N	0ca1e1af-afc9-498c-bb79-6bb3bc65d3fb	64378bf8-6f34-4dc5-81da-b1fb196a7c3e	رفع مشکل ناسازگاری مرورگر #76	\N	medium	2026-08-17	a72be042-1e25-4852-8954-20193aec9b58	2026-07-20 05:56:06.688354+00	2026-07-20 05:56:06.688354+00	todo	\N	28	8.70	2026-08-12
d36d9bdb-efba-436c-9ad9-e7c217d45a60	380bb58e-0753-4ff8-b9ef-41c46d00d6fa	\N	0ca1e1af-afc9-498c-bb79-6bb3bc65d3fb	64378bf8-6f34-4dc5-81da-b1fb196a7c3e	افزودن قابلیت جست‌وجوی پیشرفته #77	\N	low	2026-07-30	af055c89-59fe-452e-b66a-1e4c1e313c59	2026-07-20 05:56:06.688354+00	2026-07-20 05:56:06.688354+00	completed	approved	100	19.30	2026-07-21
d36d9bdb-efba-436c-9ad9-e7c217d45a60	380bb58e-0753-4ff8-b9ef-41c46d00d6fa	\N	7dd528cd-1bd4-4597-8589-c145df25c0fb	64378bf8-6f34-4dc5-81da-b1fb196a7c3e	رفع مشکل کندی بارگذاری صفحه #78	\N	medium	2026-08-11	6061455d-f7df-469b-82fb-5133089b4425	2026-07-20 05:56:06.688354+00	2026-07-20 05:56:06.688354+00	completed	pending	100	25.30	2026-07-21
d36d9bdb-efba-436c-9ad9-e7c217d45a60	380bb58e-0753-4ff8-b9ef-41c46d00d6fa	\N	0ca1e1af-afc9-498c-bb79-6bb3bc65d3fb	64378bf8-6f34-4dc5-81da-b1fb196a7c3e	بررسی و رفع آسیب‌پذیری امنیتی #79	\N	low	2026-09-01	5f6f2e12-c6bc-42fd-88e0-7aa9bb1085d8	2026-07-20 05:56:06.688354+00	2026-07-20 05:56:06.688354+00	completed	approved	100	30.30	2026-08-13
d36d9bdb-efba-436c-9ad9-e7c217d45a60	380bb58e-0753-4ff8-b9ef-41c46d00d6fa	\N	91b406bb-3239-4e75-bc39-05289ba5787a	64378bf8-6f34-4dc5-81da-b1fb196a7c3e	رفع مشکل ناسازگاری مرورگر #80	\N	high	2026-07-11	45afdd05-4144-4d59-a34b-93dfc9b40528	2026-07-20 05:56:06.688354+00	2026-07-20 05:56:06.688354+00	completed	approved	100	20.40	2026-07-01
d36d9bdb-efba-436c-9ad9-e7c217d45a60	380bb58e-0753-4ff8-b9ef-41c46d00d6fa	\N	5ab53cd1-327d-42d7-9816-c02eb65d5cb3	64378bf8-6f34-4dc5-81da-b1fb196a7c3e	نوشتن مستندات فنی API #81	\N	medium	2026-07-18	1622ae88-cbed-4d14-b227-76e2d637a7f3	2026-07-20 05:56:06.688354+00	2026-07-20 05:56:06.688354+00	in_progress	\N	30	12.30	2026-07-14
d36d9bdb-efba-436c-9ad9-e7c217d45a60	380bb58e-0753-4ff8-b9ef-41c46d00d6fa	\N	e63e7670-494e-4f3e-ba10-facf27823c40	64378bf8-6f34-4dc5-81da-b1fb196a7c3e	پیاده‌سازی احراز هویت دومرحله‌ای #82	\N	high	2026-07-04	2cc8c49e-2293-4fcf-8537-9918b1fe735e	2026-07-20 05:56:06.688354+00	2026-07-20 05:56:06.688354+00	completed	approved	100	7.80	2026-06-25
d36d9bdb-efba-436c-9ad9-e7c217d45a60	380bb58e-0753-4ff8-b9ef-41c46d00d6fa	\N	5ab53cd1-327d-42d7-9816-c02eb65d5cb3	64378bf8-6f34-4dc5-81da-b1fb196a7c3e	رفع مشکل کندی بارگذاری صفحه #83	\N	high	2026-07-27	1ff5e6f3-b302-4639-8018-be23e92bf56f	2026-07-20 05:56:06.688354+00	2026-07-20 05:56:06.688354+00	todo	\N	59	17.80	2026-07-12
d36d9bdb-efba-436c-9ad9-e7c217d45a60	380bb58e-0753-4ff8-b9ef-41c46d00d6fa	\N	5ab53cd1-327d-42d7-9816-c02eb65d5cb3	64378bf8-6f34-4dc5-81da-b1fb196a7c3e	نوشتن مستندات فنی API #84	\N	low	2026-07-30	2429c088-7783-40a2-abe5-a8e5964ff826	2026-07-20 05:56:06.688354+00	2026-07-20 05:56:06.688354+00	in_progress	\N	73	16.50	2026-07-10
d36d9bdb-efba-436c-9ad9-e7c217d45a60	380bb58e-0753-4ff8-b9ef-41c46d00d6fa	\N	64378bf8-6f34-4dc5-81da-b1fb196a7c3e	64378bf8-6f34-4dc5-81da-b1fb196a7c3e	بازنویسی ماژول اعلان‌ها #85	\N	medium	2026-07-19	3b5a0a31-ba02-4acb-8581-de3c473e2a81	2026-07-20 05:56:06.688354+00	2026-07-20 05:56:06.688354+00	in_progress	\N	68	30.40	2026-07-05
d36d9bdb-efba-436c-9ad9-e7c217d45a60	380bb58e-0753-4ff8-b9ef-41c46d00d6fa	\N	af4e23f3-f961-4eaa-9e20-dbae4f1bbe85	64378bf8-6f34-4dc5-81da-b1fb196a7c3e	طراحی API نسخهٔ دوم #86	\N	medium	2026-07-26	cfe5f44b-3a3d-4051-9610-32fd100ae443	2026-07-20 05:56:06.688354+00	2026-07-20 05:56:06.688354+00	completed	pending	100	20.50	2026-07-17
d36d9bdb-efba-436c-9ad9-e7c217d45a60	380bb58e-0753-4ff8-b9ef-41c46d00d6fa	\N	91b406bb-3239-4e75-bc39-05289ba5787a	64378bf8-6f34-4dc5-81da-b1fb196a7c3e	نوشتن مستندات فنی API #87	\N	low	2026-08-11	8612889f-97ad-4f0d-ad9e-6d880e268f10	2026-07-20 05:56:06.688354+00	2026-07-20 05:56:06.688354+00	in_progress	\N	59	36.90	2026-07-28
d36d9bdb-efba-436c-9ad9-e7c217d45a60	380bb58e-0753-4ff8-b9ef-41c46d00d6fa	\N	af4e23f3-f961-4eaa-9e20-dbae4f1bbe85	64378bf8-6f34-4dc5-81da-b1fb196a7c3e	پیاده‌سازی صفحهٔ داشبورد مدیریتی #88	\N	high	2026-07-31	20f485e3-9f07-4e24-b528-796166c28c80	2026-07-20 05:56:06.688354+00	2026-07-20 05:56:06.688354+00	completed	approved	100	3.00	2026-07-11
d36d9bdb-efba-436c-9ad9-e7c217d45a60	380bb58e-0753-4ff8-b9ef-41c46d00d6fa	\N	0ca1e1af-afc9-498c-bb79-6bb3bc65d3fb	64378bf8-6f34-4dc5-81da-b1fb196a7c3e	بهینه‌سازی کوئری‌های گزارش‌گیری #89	\N	low	2026-07-10	b9144b46-8b4a-4e5e-8e45-19779d1bbe33	2026-07-20 05:56:06.688354+00	2026-07-20 05:56:06.688354+00	in_progress	\N	33	16.40	2026-06-24
d36d9bdb-efba-436c-9ad9-e7c217d45a60	380bb58e-0753-4ff8-b9ef-41c46d00d6fa	\N	5ab53cd1-327d-42d7-9816-c02eb65d5cb3	64378bf8-6f34-4dc5-81da-b1fb196a7c3e	طراحی API نسخهٔ دوم #90	\N	medium	2026-08-17	41bd33f0-1ff7-4e65-8ee6-025c36658643	2026-07-20 05:56:06.688354+00	2026-07-20 05:56:06.688354+00	completed	approved	100	11.60	2026-08-03
d36d9bdb-efba-436c-9ad9-e7c217d45a60	\N	\N	64378bf8-6f34-4dc5-81da-b1fb196a7c3e	64378bf8-6f34-4dc5-81da-b1fb196a7c3e	رفع مشکل کندی بارگذاری صفحه #91	\N	low	2026-07-23	83d23935-4abd-4db4-b901-ca6e4a99306b	2026-07-20 05:56:06.688354+00	2026-07-20 05:56:06.688354+00	completed	approved	100	26.70	2026-07-20
d36d9bdb-efba-436c-9ad9-e7c217d45a60	\N	\N	7dd528cd-1bd4-4597-8589-c145df25c0fb	7dd528cd-1bd4-4597-8589-c145df25c0fb	افزودن تست واحد برای سرویس کاربران #92	\N	low	2026-06-26	b69e1ff6-ad82-4c68-8685-05d89ad7a56b	2026-07-20 05:56:06.688354+00	2026-07-20 05:56:06.688354+00	completed	approved	100	25.60	2026-06-17
d36d9bdb-efba-436c-9ad9-e7c217d45a60	\N	\N	5ab53cd1-327d-42d7-9816-c02eb65d5cb3	5ab53cd1-327d-42d7-9816-c02eb65d5cb3	پیاده‌سازی صفحهٔ داشبورد مدیریتی #93	\N	low	2026-07-21	4e0c8d00-d1f0-4a62-b16d-a11825e867b0	2026-07-20 05:56:06.688354+00	2026-07-20 05:56:06.688354+00	todo	\N	59	28.60	2026-07-16
d36d9bdb-efba-436c-9ad9-e7c217d45a60	\N	\N	7dd528cd-1bd4-4597-8589-c145df25c0fb	7dd528cd-1bd4-4597-8589-c145df25c0fb	پیاده‌سازی صفحهٔ داشبورد مدیریتی #94	\N	high	2026-07-17	aa54ff12-9c42-4f89-a895-9c278310fcec	2026-07-20 05:56:06.688354+00	2026-07-20 05:56:06.688354+00	in_progress	\N	14	31.60	2026-06-26
d36d9bdb-efba-436c-9ad9-e7c217d45a60	\N	\N	5ab53cd1-327d-42d7-9816-c02eb65d5cb3	5ab53cd1-327d-42d7-9816-c02eb65d5cb3	رفع باگ در ماژول پرداخت #95	\N	medium	2026-07-12	b75dfc68-8415-47bb-970a-ead14318c57d	2026-07-20 05:56:06.688354+00	2026-07-20 05:56:06.688354+00	in_progress	\N	73	27.70	2026-06-22
d36d9bdb-efba-436c-9ad9-e7c217d45a60	\N	\N	91b406bb-3239-4e75-bc39-05289ba5787a	91b406bb-3239-4e75-bc39-05289ba5787a	پیاده‌سازی صفحهٔ ورود جدید #96	\N	high	2026-08-23	a44d927f-f045-4e5e-80e8-19948883717a	2026-07-20 05:56:06.688354+00	2026-07-20 05:56:06.688354+00	in_progress	\N	80	11.20	2026-08-15
d36d9bdb-efba-436c-9ad9-e7c217d45a60	\N	\N	0ca1e1af-afc9-498c-bb79-6bb3bc65d3fb	0ca1e1af-afc9-498c-bb79-6bb3bc65d3fb	رفع مشکل ناسازگاری مرورگر #97	\N	low	2026-07-26	2ac5cdad-cf04-4cbc-b53a-1039252a4915	2026-07-20 05:56:06.688354+00	2026-07-20 05:56:06.688354+00	archived	\N	72	31.70	2026-07-05
d36d9bdb-efba-436c-9ad9-e7c217d45a60	\N	\N	e63e7670-494e-4f3e-ba10-facf27823c40	e63e7670-494e-4f3e-ba10-facf27823c40	به‌روزرسانی کتابخانه‌های وابسته #98	\N	high	2026-07-13	cb3054e3-4743-4472-a1a5-6e97b9e4e1da	2026-07-20 05:56:06.688354+00	2026-07-20 05:56:06.688354+00	completed	approved	100	15.00	2026-07-09
d36d9bdb-efba-436c-9ad9-e7c217d45a60	\N	\N	7dd528cd-1bd4-4597-8589-c145df25c0fb	7dd528cd-1bd4-4597-8589-c145df25c0fb	پیاده‌سازی صفحهٔ ورود جدید #99	\N	medium	2026-08-24	058b625c-23da-47c7-9447-b1227a69dba5	2026-07-20 05:56:06.688354+00	2026-07-20 05:56:06.688354+00	in_progress	\N	46	26.20	2026-08-07
d36d9bdb-efba-436c-9ad9-e7c217d45a60	\N	\N	7dd528cd-1bd4-4597-8589-c145df25c0fb	7dd528cd-1bd4-4597-8589-c145df25c0fb	نوشتن مستندات فنی API #100	\N	high	2026-07-20	dd4265a8-9d02-422b-8be9-c727c8583c55	2026-07-20 05:56:06.688354+00	2026-07-20 05:56:06.688354+00	completed	pending	100	38.70	2026-07-13
d36d9bdb-efba-436c-9ad9-e7c217d45a60	\N	\N	e63e7670-494e-4f3e-ba10-facf27823c40	e63e7670-494e-4f3e-ba10-facf27823c40	بررسی و رفع آسیب‌پذیری امنیتی #101	\N	medium	2026-08-06	3554be46-8fdc-4c27-b4c4-82255f41022b	2026-07-20 05:56:06.688354+00	2026-07-20 05:56:06.688354+00	completed	pending	100	33.40	2026-07-20
d36d9bdb-efba-436c-9ad9-e7c217d45a60	\N	\N	af4e23f3-f961-4eaa-9e20-dbae4f1bbe85	af4e23f3-f961-4eaa-9e20-dbae4f1bbe85	بازنویسی ماژول اعلان‌ها #102	\N	low	2026-07-15	ca736d01-3740-49a1-a2e8-2c7c24a08ea2	2026-07-20 05:56:06.688354+00	2026-07-20 05:56:06.688354+00	in_progress	\N	35	35.50	2026-07-06
d36d9bdb-efba-436c-9ad9-e7c217d45a60	\N	\N	5ab53cd1-327d-42d7-9816-c02eb65d5cb3	5ab53cd1-327d-42d7-9816-c02eb65d5cb3	پیاده‌سازی صفحهٔ داشبورد مدیریتی #103	\N	high	2026-08-04	4c9c4c1b-e285-4038-ba75-a71b7cdf7f37	2026-07-20 05:56:06.688354+00	2026-07-20 05:56:06.688354+00	archived	\N	48	14.80	2026-07-15
d36d9bdb-efba-436c-9ad9-e7c217d45a60	\N	\N	91b406bb-3239-4e75-bc39-05289ba5787a	91b406bb-3239-4e75-bc39-05289ba5787a	افزودن تست واحد برای سرویس کاربران #104	\N	medium	2026-07-14	b8fbb122-5d48-4654-84bc-6447498b2cbc	2026-07-20 05:56:06.688354+00	2026-07-20 05:56:06.688354+00	in_progress	\N	33	14.90	2026-06-27
d36d9bdb-efba-436c-9ad9-e7c217d45a60	\N	\N	af4e23f3-f961-4eaa-9e20-dbae4f1bbe85	af4e23f3-f961-4eaa-9e20-dbae4f1bbe85	به‌روزرسانی کتابخانه‌های وابسته #105	\N	low	2026-07-23	53c65f04-051e-40e7-9b56-950f87794178	2026-07-20 05:56:06.688354+00	2026-07-20 05:56:06.688354+00	completed	pending	100	5.30	2026-07-21
d36d9bdb-efba-436c-9ad9-e7c217d45a60	ea464407-6559-4634-b535-cc49f7939b7e	\N	0e06be7f-9df4-4e66-a58e-9eba6f026584	0e06be7f-9df4-4e66-a58e-9eba6f026584	مغایرت‌گیری حساب‌های بانکی #1	\N	high	2026-06-25	7c74ca45-3dde-4fd9-8291-6c896499ef8b	2026-07-20 05:56:06.688354+00	2026-07-20 05:56:06.688354+00	completed	pending	100	38.10	2026-06-19
d36d9bdb-efba-436c-9ad9-e7c217d45a60	ea464407-6559-4634-b535-cc49f7939b7e	\N	0e06be7f-9df4-4e66-a58e-9eba6f026584	0e06be7f-9df4-4e66-a58e-9eba6f026584	بررسی و تسویهٔ کارت اعتباری شرکت #2	\N	medium	2026-07-12	f4663084-82c6-4227-a2a5-a5aa8b2bb1c8	2026-07-20 05:56:06.688354+00	2026-07-20 05:56:06.688354+00	in_progress	\N	77	24.70	2026-06-23
d36d9bdb-efba-436c-9ad9-e7c217d45a60	ea464407-6559-4634-b535-cc49f7939b7e	\N	30621a70-ecd1-4c9b-a6c0-5b071dab4d1c	0e06be7f-9df4-4e66-a58e-9eba6f026584	بررسی فاکتورهای فروش صادرشده #3	\N	medium	2026-08-22	f9628dd9-63fe-43da-8fc3-ae7a0eb8f8af	2026-07-20 05:56:06.688354+00	2026-07-20 05:56:06.688354+00	in_progress	\N	56	13.30	2026-08-04
d36d9bdb-efba-436c-9ad9-e7c217d45a60	ea464407-6559-4634-b535-cc49f7939b7e	\N	30621a70-ecd1-4c9b-a6c0-5b071dab4d1c	0e06be7f-9df4-4e66-a58e-9eba6f026584	بررسی صورت وضعیت پیمانکاران #4	\N	low	2026-07-25	a5fced46-94ef-43ac-be42-bf945e414ad7	2026-07-20 05:56:06.688354+00	2026-07-20 05:56:06.688354+00	in_progress	\N	78	38.50	2026-07-05
d36d9bdb-efba-436c-9ad9-e7c217d45a60	ea464407-6559-4634-b535-cc49f7939b7e	\N	0e06be7f-9df4-4e66-a58e-9eba6f026584	0e06be7f-9df4-4e66-a58e-9eba6f026584	پیگیری مطالبات معوق مشتریان #5	\N	high	2026-07-07	54dd3647-05b9-48f6-8b94-e5e440c96c1e	2026-07-20 05:56:06.688354+00	2026-07-20 05:56:06.688354+00	archived	\N	10	8.00	2026-06-29
d36d9bdb-efba-436c-9ad9-e7c217d45a60	ea464407-6559-4634-b535-cc49f7939b7e	\N	455d9757-37bc-4fe6-8025-e1efb66d8672	0e06be7f-9df4-4e66-a58e-9eba6f026584	به‌روزرسانی جدول حقوق و دستمزد #6	\N	high	2026-07-01	f710d556-4daa-4c92-9372-1447f0485222	2026-07-20 05:56:06.688354+00	2026-07-20 05:56:06.688354+00	completed	approved	100	24.60	2026-06-16
d36d9bdb-efba-436c-9ad9-e7c217d45a60	ea464407-6559-4634-b535-cc49f7939b7e	\N	f892958c-2fb8-40b3-ba0e-5c62223aef14	0e06be7f-9df4-4e66-a58e-9eba6f026584	تهیهٔ گزارش جریان نقدی #7	\N	medium	2026-07-11	2db64313-3461-400a-88a0-7bb0e2581d06	2026-07-20 05:56:06.688354+00	2026-07-20 05:56:06.688354+00	todo	\N	58	4.70	2026-06-30
d36d9bdb-efba-436c-9ad9-e7c217d45a60	ea464407-6559-4634-b535-cc49f7939b7e	\N	455d9757-37bc-4fe6-8025-e1efb66d8672	0e06be7f-9df4-4e66-a58e-9eba6f026584	تطبیق موجودی انبار با حساب‌ها #8	\N	low	2026-08-25	4c709e07-cff1-4245-8a12-1009e446c496	2026-07-20 05:56:06.688354+00	2026-07-20 05:56:06.688354+00	in_progress	\N	54	6.40	2026-08-05
d36d9bdb-efba-436c-9ad9-e7c217d45a60	ea464407-6559-4634-b535-cc49f7939b7e	\N	455d9757-37bc-4fe6-8025-e1efb66d8672	0e06be7f-9df4-4e66-a58e-9eba6f026584	تهیهٔ گزارش سود و زیان ماهانه #9	\N	low	2026-07-09	80aefb34-0a9f-41ab-805a-e239fa250606	2026-07-20 05:56:06.688354+00	2026-07-20 05:56:06.688354+00	completed	approved	100	8.30	2026-07-03
d36d9bdb-efba-436c-9ad9-e7c217d45a60	ea464407-6559-4634-b535-cc49f7939b7e	\N	f892958c-2fb8-40b3-ba0e-5c62223aef14	0e06be7f-9df4-4e66-a58e-9eba6f026584	به‌روزرسانی جدول حقوق و دستمزد #10	\N	low	2026-08-02	c7748da1-4d0e-4a06-828a-0e9089aab871	2026-07-20 05:56:06.688354+00	2026-07-20 05:56:06.688354+00	completed	pending	100	19.80	2026-07-22
d36d9bdb-efba-436c-9ad9-e7c217d45a60	ea464407-6559-4634-b535-cc49f7939b7e	\N	f892958c-2fb8-40b3-ba0e-5c62223aef14	0e06be7f-9df4-4e66-a58e-9eba6f026584	تهیهٔ پیش‌نویس بودجهٔ واحد #11	\N	medium	2026-07-21	af5abe26-316a-4697-b6e7-db782e2105bd	2026-07-20 05:56:06.688354+00	2026-07-20 05:56:06.688354+00	completed	approved	100	18.60	2026-07-03
d36d9bdb-efba-436c-9ad9-e7c217d45a60	ea464407-6559-4634-b535-cc49f7939b7e	\N	30621a70-ecd1-4c9b-a6c0-5b071dab4d1c	0e06be7f-9df4-4e66-a58e-9eba6f026584	تهیهٔ گزارش جریان نقدی #12	\N	medium	2026-08-26	5a97e91a-775d-4606-9304-d4c4cfeb9d63	2026-07-20 05:56:06.688354+00	2026-07-20 05:56:06.688354+00	todo	\N	77	11.50	2026-08-11
d36d9bdb-efba-436c-9ad9-e7c217d45a60	ea464407-6559-4634-b535-cc49f7939b7e	\N	0e06be7f-9df4-4e66-a58e-9eba6f026584	0e06be7f-9df4-4e66-a58e-9eba6f026584	بررسی صورت وضعیت پیمانکاران #13	\N	low	2026-08-18	3ce6057d-d9ce-40e8-8673-662b3da931dc	2026-07-20 05:56:06.688354+00	2026-07-20 05:56:06.688354+00	in_progress	\N	34	23.90	2026-07-29
d36d9bdb-efba-436c-9ad9-e7c217d45a60	ea464407-6559-4634-b535-cc49f7939b7e	\N	7653733b-3526-47fd-8fa2-b6c120729ad7	0e06be7f-9df4-4e66-a58e-9eba6f026584	تهیهٔ پیش‌نویس بودجهٔ واحد #14	\N	high	2026-07-14	41ab897c-3de1-4afc-b355-c88f23a3eb5d	2026-07-20 05:56:06.688354+00	2026-07-20 05:56:06.688354+00	archived	\N	56	36.80	2026-06-27
d36d9bdb-efba-436c-9ad9-e7c217d45a60	ea464407-6559-4634-b535-cc49f7939b7e	\N	455d9757-37bc-4fe6-8025-e1efb66d8672	0e06be7f-9df4-4e66-a58e-9eba6f026584	تهیهٔ گزارش سود و زیان ماهانه #15	\N	medium	2026-08-24	a71b7cb4-19a8-4add-b962-b29b94824d3e	2026-07-20 05:56:06.688354+00	2026-07-20 05:56:06.688354+00	completed	approved	100	15.20	2026-08-07
d36d9bdb-efba-436c-9ad9-e7c217d45a60	ea464407-6559-4634-b535-cc49f7939b7e	\N	f892958c-2fb8-40b3-ba0e-5c62223aef14	0e06be7f-9df4-4e66-a58e-9eba6f026584	پیگیری بیمهٔ کارکنان #16	\N	low	2026-08-02	5de9e957-4000-45c1-b147-bf050d3c4ec1	2026-07-20 05:56:06.688354+00	2026-07-20 05:56:06.688354+00	in_progress	\N	42	17.60	2026-07-28
d36d9bdb-efba-436c-9ad9-e7c217d45a60	ea464407-6559-4634-b535-cc49f7939b7e	\N	fbfe2b53-dcf1-4ee4-acf0-7c1a3cace4db	0e06be7f-9df4-4e66-a58e-9eba6f026584	پیگیری بیمهٔ کارکنان #17	\N	high	2026-08-11	78c1532f-3d9a-40b4-a6f3-fb56d7647396	2026-07-20 05:56:06.688354+00	2026-07-20 05:56:06.688354+00	in_progress	\N	4	19.30	2026-07-28
d36d9bdb-efba-436c-9ad9-e7c217d45a60	ea464407-6559-4634-b535-cc49f7939b7e	\N	f892958c-2fb8-40b3-ba0e-5c62223aef14	0e06be7f-9df4-4e66-a58e-9eba6f026584	بررسی و تسویهٔ کارت اعتباری شرکت #18	\N	medium	2026-07-11	462024fd-71a6-47d0-94f7-5b312544928b	2026-07-20 05:56:06.688354+00	2026-07-20 05:56:06.688354+00	in_progress	\N	65	33.30	2026-07-06
d36d9bdb-efba-436c-9ad9-e7c217d45a60	64870cfe-8d3d-4d23-a611-14a97a14b215	\N	0e06be7f-9df4-4e66-a58e-9eba6f026584	0e06be7f-9df4-4e66-a58e-9eba6f026584	بررسی و تأیید صورت‌حساب‌های خرید #19	\N	low	2026-07-30	059b6a6d-47d8-456e-815f-adade6edd3a3	2026-07-20 05:56:06.688354+00	2026-07-20 05:56:06.688354+00	completed	pending	100	21.70	2026-07-15
d36d9bdb-efba-436c-9ad9-e7c217d45a60	64870cfe-8d3d-4d23-a611-14a97a14b215	\N	30621a70-ecd1-4c9b-a6c0-5b071dab4d1c	0e06be7f-9df4-4e66-a58e-9eba6f026584	بررسی و تسویهٔ کارت اعتباری شرکت #20	\N	low	2026-08-02	27fa494e-aae4-4db0-bb8b-c3d4f6ef222f	2026-07-20 05:56:06.688354+00	2026-07-20 05:56:06.688354+00	archived	\N	26	12.10	2026-07-17
d36d9bdb-efba-436c-9ad9-e7c217d45a60	64870cfe-8d3d-4d23-a611-14a97a14b215	\N	455d9757-37bc-4fe6-8025-e1efb66d8672	0e06be7f-9df4-4e66-a58e-9eba6f026584	تهیهٔ گزارش سود و زیان ماهانه #21	\N	low	2026-07-31	c00e6855-1184-48f2-b0b7-68de74eddd49	2026-07-20 05:56:06.688354+00	2026-07-20 05:56:06.688354+00	in_progress	\N	80	25.10	2026-07-14
d36d9bdb-efba-436c-9ad9-e7c217d45a60	64870cfe-8d3d-4d23-a611-14a97a14b215	\N	455d9757-37bc-4fe6-8025-e1efb66d8672	0e06be7f-9df4-4e66-a58e-9eba6f026584	تهیهٔ پیش‌نویس بودجهٔ واحد #22	\N	low	2026-07-07	31672770-e30b-4c2e-941d-c1b40cce75d6	2026-07-20 05:56:06.688354+00	2026-07-20 05:56:06.688354+00	archived	\N	70	17.50	2026-06-26
d36d9bdb-efba-436c-9ad9-e7c217d45a60	64870cfe-8d3d-4d23-a611-14a97a14b215	\N	455d9757-37bc-4fe6-8025-e1efb66d8672	0e06be7f-9df4-4e66-a58e-9eba6f026584	تطبیق موجودی انبار با حساب‌ها #23	\N	low	2026-07-20	7cadc4bd-fb34-4e93-974b-9f00cbf3418b	2026-07-20 05:56:06.688354+00	2026-07-20 05:56:06.688354+00	todo	\N	63	37.40	2026-07-15
d36d9bdb-efba-436c-9ad9-e7c217d45a60	64870cfe-8d3d-4d23-a611-14a97a14b215	\N	f892958c-2fb8-40b3-ba0e-5c62223aef14	0e06be7f-9df4-4e66-a58e-9eba6f026584	به‌روزرسانی جدول حقوق و دستمزد #24	\N	low	2026-07-29	9054a35b-17e8-49d7-a4a2-74c68a7ce0cc	2026-07-20 05:56:06.688354+00	2026-07-20 05:56:06.688354+00	completed	pending	100	19.40	2026-07-12
d36d9bdb-efba-436c-9ad9-e7c217d45a60	64870cfe-8d3d-4d23-a611-14a97a14b215	\N	455d9757-37bc-4fe6-8025-e1efb66d8672	0e06be7f-9df4-4e66-a58e-9eba6f026584	تهیهٔ پیش‌نویس بودجهٔ واحد #25	\N	high	2026-07-19	e9712317-fc3c-4386-9264-b120ab779457	2026-07-20 05:56:06.688354+00	2026-07-20 05:56:06.688354+00	in_progress	\N	17	34.80	2026-06-28
d36d9bdb-efba-436c-9ad9-e7c217d45a60	64870cfe-8d3d-4d23-a611-14a97a14b215	\N	f892958c-2fb8-40b3-ba0e-5c62223aef14	0e06be7f-9df4-4e66-a58e-9eba6f026584	تهیهٔ گزارش مالیاتی فصلی #26	\N	high	2026-08-20	00abc496-9932-47cb-ad21-2794c1b207a8	2026-07-20 05:56:06.688354+00	2026-07-20 05:56:06.688354+00	archived	\N	34	33.20	2026-08-05
d36d9bdb-efba-436c-9ad9-e7c217d45a60	64870cfe-8d3d-4d23-a611-14a97a14b215	\N	f892958c-2fb8-40b3-ba0e-5c62223aef14	0e06be7f-9df4-4e66-a58e-9eba6f026584	بررسی صورت وضعیت پیمانکاران #27	\N	high	2026-07-25	cfbdcdf4-ae97-4aa9-b022-004b48673fe0	2026-07-20 05:56:06.688354+00	2026-07-20 05:56:06.688354+00	archived	\N	62	34.90	2026-07-05
d36d9bdb-efba-436c-9ad9-e7c217d45a60	64870cfe-8d3d-4d23-a611-14a97a14b215	\N	fbfe2b53-dcf1-4ee4-acf0-7c1a3cace4db	0e06be7f-9df4-4e66-a58e-9eba6f026584	بررسی و تسویهٔ کارت اعتباری شرکت #28	\N	high	2026-07-26	d82739a3-42a0-44bc-a8fd-b6697969e370	2026-07-20 05:56:06.688354+00	2026-07-20 05:56:06.688354+00	completed	approved	100	16.30	2026-07-07
d36d9bdb-efba-436c-9ad9-e7c217d45a60	64870cfe-8d3d-4d23-a611-14a97a14b215	\N	f892958c-2fb8-40b3-ba0e-5c62223aef14	0e06be7f-9df4-4e66-a58e-9eba6f026584	بررسی صورت وضعیت پیمانکاران #29	\N	medium	2026-08-08	f65c0e7e-2c0e-41db-8790-da83a71095f2	2026-07-20 05:56:06.688354+00	2026-07-20 05:56:06.688354+00	todo	\N	29	34.50	2026-07-30
d36d9bdb-efba-436c-9ad9-e7c217d45a60	64870cfe-8d3d-4d23-a611-14a97a14b215	\N	fbfe2b53-dcf1-4ee4-acf0-7c1a3cace4db	0e06be7f-9df4-4e66-a58e-9eba6f026584	تهیهٔ گزارش جریان نقدی #30	\N	medium	2026-07-23	ca1a1fbc-923e-46ea-ac44-b18ffefa1ffc	2026-07-20 05:56:06.688354+00	2026-07-20 05:56:06.688354+00	todo	\N	49	39.60	2026-07-06
d36d9bdb-efba-436c-9ad9-e7c217d45a60	64870cfe-8d3d-4d23-a611-14a97a14b215	\N	7653733b-3526-47fd-8fa2-b6c120729ad7	0e06be7f-9df4-4e66-a58e-9eba6f026584	مغایرت‌گیری حساب‌های بانکی #31	\N	high	2026-07-20	bcba1442-5f49-4543-890b-007e48037204	2026-07-20 05:56:06.688354+00	2026-07-20 05:56:06.688354+00	completed	rejected	100	38.70	2026-07-17
d36d9bdb-efba-436c-9ad9-e7c217d45a60	64870cfe-8d3d-4d23-a611-14a97a14b215	\N	f892958c-2fb8-40b3-ba0e-5c62223aef14	0e06be7f-9df4-4e66-a58e-9eba6f026584	تهیهٔ گزارش سود و زیان ماهانه #32	\N	high	2026-08-26	c24774ed-9642-447c-a0e5-ba554146c9ef	2026-07-20 05:56:06.688354+00	2026-07-20 05:56:06.688354+00	todo	\N	58	2.60	2026-08-10
d36d9bdb-efba-436c-9ad9-e7c217d45a60	64870cfe-8d3d-4d23-a611-14a97a14b215	\N	455d9757-37bc-4fe6-8025-e1efb66d8672	0e06be7f-9df4-4e66-a58e-9eba6f026584	تهیهٔ گزارش سود و زیان ماهانه #33	\N	medium	2026-08-16	3294ed98-ddb4-4eac-8582-81462b2268e5	2026-07-20 05:56:06.688354+00	2026-07-20 05:56:06.688354+00	in_progress	\N	33	14.90	2026-08-10
d36d9bdb-efba-436c-9ad9-e7c217d45a60	64870cfe-8d3d-4d23-a611-14a97a14b215	\N	77fe864d-692a-4798-9e36-b464ad1c9e1c	0e06be7f-9df4-4e66-a58e-9eba6f026584	پیگیری بیمهٔ کارکنان #34	\N	medium	2026-07-31	dd6c1974-a913-463c-8fba-2d58636cc59c	2026-07-20 05:56:06.688354+00	2026-07-20 05:56:06.688354+00	in_progress	\N	68	16.40	2026-07-27
d36d9bdb-efba-436c-9ad9-e7c217d45a60	64870cfe-8d3d-4d23-a611-14a97a14b215	\N	f892958c-2fb8-40b3-ba0e-5c62223aef14	0e06be7f-9df4-4e66-a58e-9eba6f026584	پیگیری بیمهٔ کارکنان #35	\N	high	2026-08-20	9008f2a4-01ac-445d-933e-5c25daab0ab4	2026-07-20 05:56:06.688354+00	2026-07-20 05:56:06.688354+00	completed	pending	100	3.40	2026-08-03
d36d9bdb-efba-436c-9ad9-e7c217d45a60	64870cfe-8d3d-4d23-a611-14a97a14b215	\N	0e06be7f-9df4-4e66-a58e-9eba6f026584	0e06be7f-9df4-4e66-a58e-9eba6f026584	ثبت اسناد حسابداری هفتگی #36	\N	high	2026-08-06	213a27fb-fd68-44e8-8a32-fe26ea168831	2026-07-20 05:56:06.688354+00	2026-07-20 05:56:06.688354+00	in_progress	\N	11	18.50	2026-07-26
d36d9bdb-efba-436c-9ad9-e7c217d45a60	c771aebe-c485-465a-b898-a8ef09df6f98	\N	0e06be7f-9df4-4e66-a58e-9eba6f026584	0e06be7f-9df4-4e66-a58e-9eba6f026584	به‌روزرسانی جدول حقوق و دستمزد #37	\N	low	2026-07-31	cc8ccd4e-7775-472a-bbea-fec302c2e140	2026-07-20 05:56:06.688354+00	2026-07-20 05:56:06.688354+00	archived	\N	38	36.30	2026-07-26
d36d9bdb-efba-436c-9ad9-e7c217d45a60	c771aebe-c485-465a-b898-a8ef09df6f98	\N	0e06be7f-9df4-4e66-a58e-9eba6f026584	0e06be7f-9df4-4e66-a58e-9eba6f026584	پیگیری مطالبات معوق مشتریان #38	\N	medium	2026-08-08	3d099518-3dd9-4ebf-ac75-1d24f515c473	2026-07-20 05:56:06.688354+00	2026-07-20 05:56:06.688354+00	in_progress	\N	47	18.40	2026-08-05
d36d9bdb-efba-436c-9ad9-e7c217d45a60	c771aebe-c485-465a-b898-a8ef09df6f98	\N	455d9757-37bc-4fe6-8025-e1efb66d8672	0e06be7f-9df4-4e66-a58e-9eba6f026584	مغایرت‌گیری حساب‌های بانکی #39	\N	low	2026-08-05	e0737fed-3cb9-4f0e-bbe9-e6a9b419a6ca	2026-07-20 05:56:06.688354+00	2026-07-20 05:56:06.688354+00	completed	approved	100	5.00	2026-07-29
d36d9bdb-efba-436c-9ad9-e7c217d45a60	c771aebe-c485-465a-b898-a8ef09df6f98	\N	7653733b-3526-47fd-8fa2-b6c120729ad7	0e06be7f-9df4-4e66-a58e-9eba6f026584	به‌روزرسانی جدول حقوق و دستمزد #40	\N	high	2026-08-03	567f5219-ea4a-429c-bb5d-9aca64df1b1a	2026-07-20 05:56:06.688354+00	2026-07-20 05:56:06.688354+00	in_progress	\N	18	10.80	2026-07-25
d36d9bdb-efba-436c-9ad9-e7c217d45a60	c771aebe-c485-465a-b898-a8ef09df6f98	\N	77fe864d-692a-4798-9e36-b464ad1c9e1c	0e06be7f-9df4-4e66-a58e-9eba6f026584	تطبیق موجودی انبار با حساب‌ها #41	\N	low	2026-07-25	81e4ce16-5d13-4905-a1f5-f1eff972108a	2026-07-20 05:56:06.688354+00	2026-07-20 05:56:06.688354+00	in_progress	\N	59	36.20	2026-07-15
d36d9bdb-efba-436c-9ad9-e7c217d45a60	c771aebe-c485-465a-b898-a8ef09df6f98	\N	77fe864d-692a-4798-9e36-b464ad1c9e1c	0e06be7f-9df4-4e66-a58e-9eba6f026584	بررسی صورت وضعیت پیمانکاران #42	\N	medium	2026-07-27	6505aa2c-9edd-47f1-bc42-ccfc7e7a2161	2026-07-20 05:56:06.688354+00	2026-07-20 05:56:06.688354+00	completed	approved	100	26.30	2026-07-14
d36d9bdb-efba-436c-9ad9-e7c217d45a60	c771aebe-c485-465a-b898-a8ef09df6f98	\N	fbfe2b53-dcf1-4ee4-acf0-7c1a3cace4db	0e06be7f-9df4-4e66-a58e-9eba6f026584	ثبت اسناد حسابداری هفتگی #43	\N	medium	2026-08-20	ce85a521-a61f-44e1-95cd-0afaabcec317	2026-07-20 05:56:06.688354+00	2026-07-20 05:56:06.688354+00	completed	approved	100	34.40	2026-08-09
d36d9bdb-efba-436c-9ad9-e7c217d45a60	c771aebe-c485-465a-b898-a8ef09df6f98	\N	0e06be7f-9df4-4e66-a58e-9eba6f026584	0e06be7f-9df4-4e66-a58e-9eba6f026584	تهیهٔ گزارش مالیاتی فصلی #44	\N	high	2026-07-30	9c4c2ece-1255-4170-bb99-99476fecbb95	2026-07-20 05:56:06.688354+00	2026-07-20 05:56:06.688354+00	in_progress	\N	37	39.70	2026-07-10
d36d9bdb-efba-436c-9ad9-e7c217d45a60	c771aebe-c485-465a-b898-a8ef09df6f98	\N	f892958c-2fb8-40b3-ba0e-5c62223aef14	0e06be7f-9df4-4e66-a58e-9eba6f026584	پیگیری مطالبات معوق مشتریان #45	\N	low	2026-08-22	4455606d-26c6-4b59-9818-61cc84218f37	2026-07-20 05:56:06.688354+00	2026-07-20 05:56:06.688354+00	todo	\N	72	34.90	2026-08-08
d36d9bdb-efba-436c-9ad9-e7c217d45a60	c771aebe-c485-465a-b898-a8ef09df6f98	\N	7653733b-3526-47fd-8fa2-b6c120729ad7	0e06be7f-9df4-4e66-a58e-9eba6f026584	تهیهٔ گزارش جریان نقدی #46	\N	medium	2026-07-10	e3c85ead-d2d1-4d60-b3c4-f6aae8bf9bf1	2026-07-20 05:56:06.688354+00	2026-07-20 05:56:06.688354+00	archived	\N	36	31.50	2026-06-19
d36d9bdb-efba-436c-9ad9-e7c217d45a60	c771aebe-c485-465a-b898-a8ef09df6f98	\N	455d9757-37bc-4fe6-8025-e1efb66d8672	0e06be7f-9df4-4e66-a58e-9eba6f026584	بررسی صورت وضعیت پیمانکاران #47	\N	medium	2026-07-08	c151a581-9988-45aa-b93f-4d17bbee2720	2026-07-20 05:56:06.688354+00	2026-07-20 05:56:06.688354+00	completed	pending	100	27.80	2026-06-30
d36d9bdb-efba-436c-9ad9-e7c217d45a60	c771aebe-c485-465a-b898-a8ef09df6f98	\N	77fe864d-692a-4798-9e36-b464ad1c9e1c	0e06be7f-9df4-4e66-a58e-9eba6f026584	تطبیق موجودی انبار با حساب‌ها #48	\N	low	2026-08-03	ccc30d82-5f09-4542-bf56-63c4888ce631	2026-07-20 05:56:06.688354+00	2026-07-20 05:56:06.688354+00	archived	\N	80	26.60	2026-07-28
d36d9bdb-efba-436c-9ad9-e7c217d45a60	c771aebe-c485-465a-b898-a8ef09df6f98	\N	f892958c-2fb8-40b3-ba0e-5c62223aef14	0e06be7f-9df4-4e66-a58e-9eba6f026584	تهیهٔ گزارش سود و زیان ماهانه #49	\N	medium	2026-07-15	0bdbc40b-1398-4577-b2e3-62f58bd936ee	2026-07-20 05:56:06.688354+00	2026-07-20 05:56:06.688354+00	completed	approved	100	14.40	2026-07-09
d36d9bdb-efba-436c-9ad9-e7c217d45a60	c771aebe-c485-465a-b898-a8ef09df6f98	\N	fbfe2b53-dcf1-4ee4-acf0-7c1a3cace4db	0e06be7f-9df4-4e66-a58e-9eba6f026584	بررسی و تسویهٔ کارت اعتباری شرکت #50	\N	high	2026-07-04	cd811bf1-2c0c-4018-9a48-dbaab437a721	2026-07-20 05:56:06.688354+00	2026-07-20 05:56:06.688354+00	todo	\N	46	22.20	2026-06-28
d36d9bdb-efba-436c-9ad9-e7c217d45a60	c771aebe-c485-465a-b898-a8ef09df6f98	\N	f892958c-2fb8-40b3-ba0e-5c62223aef14	0e06be7f-9df4-4e66-a58e-9eba6f026584	بررسی و تسویهٔ کارت اعتباری شرکت #51	\N	medium	2026-07-19	ed087d70-4b71-4c3a-8808-34d569fab64d	2026-07-20 05:56:06.688354+00	2026-07-20 05:56:06.688354+00	todo	\N	43	32.60	2026-07-02
d36d9bdb-efba-436c-9ad9-e7c217d45a60	c771aebe-c485-465a-b898-a8ef09df6f98	\N	fbfe2b53-dcf1-4ee4-acf0-7c1a3cace4db	0e06be7f-9df4-4e66-a58e-9eba6f026584	پیگیری بیمهٔ کارکنان #52	\N	high	2026-07-04	6c34543b-1f39-4581-bfbf-9ef7719a1c07	2026-07-20 05:56:06.688354+00	2026-07-20 05:56:06.688354+00	todo	\N	50	38.80	2026-06-25
d36d9bdb-efba-436c-9ad9-e7c217d45a60	c771aebe-c485-465a-b898-a8ef09df6f98	\N	7653733b-3526-47fd-8fa2-b6c120729ad7	0e06be7f-9df4-4e66-a58e-9eba6f026584	بررسی و تأیید صورت‌حساب‌های خرید #53	\N	medium	2026-08-19	3dcf709e-4cb7-44b3-ad2a-309bba2028e5	2026-07-20 05:56:06.688354+00	2026-07-20 05:56:06.688354+00	completed	approved	100	22.40	2026-08-05
d36d9bdb-efba-436c-9ad9-e7c217d45a60	c771aebe-c485-465a-b898-a8ef09df6f98	\N	fbfe2b53-dcf1-4ee4-acf0-7c1a3cace4db	0e06be7f-9df4-4e66-a58e-9eba6f026584	بررسی صورت وضعیت پیمانکاران #54	\N	medium	2026-08-08	981ab417-e207-4a14-b587-0b725436c76e	2026-07-20 05:56:06.688354+00	2026-07-20 05:56:06.688354+00	in_progress	\N	47	6.10	2026-07-29
d36d9bdb-efba-436c-9ad9-e7c217d45a60	8284e4d9-0201-4c88-ad0e-dc4326260101	\N	455d9757-37bc-4fe6-8025-e1efb66d8672	0e06be7f-9df4-4e66-a58e-9eba6f026584	تهیهٔ گزارش مالیاتی فصلی #55	\N	high	2026-08-30	fe3f1eff-4ec6-4ce1-b41d-054fc1f780a6	2026-07-20 05:56:06.688354+00	2026-07-20 05:56:06.688354+00	completed	approved	100	10.40	2026-08-11
d36d9bdb-efba-436c-9ad9-e7c217d45a60	8284e4d9-0201-4c88-ad0e-dc4326260101	\N	0e06be7f-9df4-4e66-a58e-9eba6f026584	0e06be7f-9df4-4e66-a58e-9eba6f026584	تطبیق موجودی انبار با حساب‌ها #56	\N	medium	2026-08-24	7e6b00de-9e30-42b0-a111-6fd460583904	2026-07-20 05:56:06.688354+00	2026-07-20 05:56:06.688354+00	completed	pending	100	6.40	2026-08-13
d36d9bdb-efba-436c-9ad9-e7c217d45a60	8284e4d9-0201-4c88-ad0e-dc4326260101	\N	0e06be7f-9df4-4e66-a58e-9eba6f026584	0e06be7f-9df4-4e66-a58e-9eba6f026584	تهیهٔ گزارش سود و زیان ماهانه #57	\N	low	2026-07-22	8c65755f-d439-4b36-bac6-7deba044b8f6	2026-07-20 05:56:06.688354+00	2026-07-20 05:56:06.688354+00	todo	\N	30	35.70	2026-07-05
d36d9bdb-efba-436c-9ad9-e7c217d45a60	8284e4d9-0201-4c88-ad0e-dc4326260101	\N	455d9757-37bc-4fe6-8025-e1efb66d8672	0e06be7f-9df4-4e66-a58e-9eba6f026584	تطبیق موجودی انبار با حساب‌ها #58	\N	high	2026-07-28	bbdcedfe-1259-4d64-b22b-d1bdc3e305ca	2026-07-20 05:56:06.688354+00	2026-07-20 05:56:06.688354+00	in_progress	\N	69	17.90	2026-07-15
d36d9bdb-efba-436c-9ad9-e7c217d45a60	8284e4d9-0201-4c88-ad0e-dc4326260101	\N	77fe864d-692a-4798-9e36-b464ad1c9e1c	0e06be7f-9df4-4e66-a58e-9eba6f026584	تطبیق موجودی انبار با حساب‌ها #59	\N	low	2026-07-10	37becc5a-b373-4597-b2f4-b5a113cc4e82	2026-07-20 05:56:06.688354+00	2026-07-20 05:56:06.688354+00	archived	\N	62	25.40	2026-06-25
d36d9bdb-efba-436c-9ad9-e7c217d45a60	8284e4d9-0201-4c88-ad0e-dc4326260101	\N	f892958c-2fb8-40b3-ba0e-5c62223aef14	0e06be7f-9df4-4e66-a58e-9eba6f026584	ثبت اسناد حسابداری هفتگی #60	\N	medium	2026-08-12	f0f755c0-a5a3-4c35-b433-727de1432e7c	2026-07-20 05:56:06.688354+00	2026-07-20 05:56:06.688354+00	todo	\N	56	38.10	2026-07-30
d36d9bdb-efba-436c-9ad9-e7c217d45a60	8284e4d9-0201-4c88-ad0e-dc4326260101	\N	7653733b-3526-47fd-8fa2-b6c120729ad7	0e06be7f-9df4-4e66-a58e-9eba6f026584	تهیهٔ پیش‌نویس بودجهٔ واحد #61	\N	high	2026-07-05	83c1a609-ee7d-42a3-a1ba-28003920a1bb	2026-07-20 05:56:06.688354+00	2026-07-20 05:56:06.688354+00	in_progress	\N	45	4.30	2026-06-22
d36d9bdb-efba-436c-9ad9-e7c217d45a60	8284e4d9-0201-4c88-ad0e-dc4326260101	\N	f892958c-2fb8-40b3-ba0e-5c62223aef14	0e06be7f-9df4-4e66-a58e-9eba6f026584	تهیهٔ گزارش سود و زیان ماهانه #62	\N	high	2026-07-09	69bd342c-3536-42b9-962c-f4acde711420	2026-07-20 05:56:06.688354+00	2026-07-20 05:56:06.688354+00	todo	\N	27	26.40	2026-06-23
d36d9bdb-efba-436c-9ad9-e7c217d45a60	8284e4d9-0201-4c88-ad0e-dc4326260101	\N	30621a70-ecd1-4c9b-a6c0-5b071dab4d1c	0e06be7f-9df4-4e66-a58e-9eba6f026584	ثبت اسناد حسابداری هفتگی #63	\N	low	2026-07-01	1ac9af2a-6672-4681-83fc-81ecf4eced0a	2026-07-20 05:56:06.688354+00	2026-07-20 05:56:06.688354+00	todo	\N	72	9.80	2026-06-19
d36d9bdb-efba-436c-9ad9-e7c217d45a60	8284e4d9-0201-4c88-ad0e-dc4326260101	\N	7653733b-3526-47fd-8fa2-b6c120729ad7	0e06be7f-9df4-4e66-a58e-9eba6f026584	بررسی صورت وضعیت پیمانکاران #64	\N	low	2026-07-29	6effe8d8-b50d-4be1-b124-ac05a0715ff6	2026-07-20 05:56:06.688354+00	2026-07-20 05:56:06.688354+00	archived	\N	29	14.50	2026-07-21
d36d9bdb-efba-436c-9ad9-e7c217d45a60	8284e4d9-0201-4c88-ad0e-dc4326260101	\N	455d9757-37bc-4fe6-8025-e1efb66d8672	0e06be7f-9df4-4e66-a58e-9eba6f026584	مغایرت‌گیری حساب‌های بانکی #65	\N	high	2026-08-15	d2c92f0d-02d9-4532-8c9b-25a82f0e74fb	2026-07-20 05:56:06.688354+00	2026-07-20 05:56:06.688354+00	completed	approved	100	11.50	2026-08-09
d36d9bdb-efba-436c-9ad9-e7c217d45a60	8284e4d9-0201-4c88-ad0e-dc4326260101	\N	455d9757-37bc-4fe6-8025-e1efb66d8672	0e06be7f-9df4-4e66-a58e-9eba6f026584	مغایرت‌گیری حساب‌های بانکی #66	\N	low	2026-07-30	39f7df40-29f0-4746-ae88-9234eee97eaa	2026-07-20 05:56:06.688354+00	2026-07-20 05:56:06.688354+00	todo	\N	45	32.00	2026-07-28
d36d9bdb-efba-436c-9ad9-e7c217d45a60	8284e4d9-0201-4c88-ad0e-dc4326260101	\N	455d9757-37bc-4fe6-8025-e1efb66d8672	0e06be7f-9df4-4e66-a58e-9eba6f026584	بررسی و تأیید صورت‌حساب‌های خرید #67	\N	low	2026-07-07	838e4a03-ad7c-4fb0-b1db-9cdc4e8ba4e5	2026-07-20 05:56:06.688354+00	2026-07-20 05:56:06.688354+00	completed	approved	100	30.20	2026-06-27
d36d9bdb-efba-436c-9ad9-e7c217d45a60	8284e4d9-0201-4c88-ad0e-dc4326260101	\N	30621a70-ecd1-4c9b-a6c0-5b071dab4d1c	0e06be7f-9df4-4e66-a58e-9eba6f026584	به‌روزرسانی جدول حقوق و دستمزد #68	\N	medium	2026-08-06	5f7b7a6f-1dcc-4bdb-89da-53f1f8160eb3	2026-07-20 05:56:06.688354+00	2026-07-20 05:56:06.688354+00	todo	\N	46	21.50	2026-08-02
d36d9bdb-efba-436c-9ad9-e7c217d45a60	8284e4d9-0201-4c88-ad0e-dc4326260101	\N	0e06be7f-9df4-4e66-a58e-9eba6f026584	0e06be7f-9df4-4e66-a58e-9eba6f026584	بررسی و تأیید صورت‌حساب‌های خرید #69	\N	high	2026-09-05	4fa34d13-9992-4448-ac66-bab65bc88222	2026-07-20 05:56:06.688354+00	2026-07-20 05:56:06.688354+00	completed	approved	100	31.80	2026-08-15
d36d9bdb-efba-436c-9ad9-e7c217d45a60	8284e4d9-0201-4c88-ad0e-dc4326260101	\N	7653733b-3526-47fd-8fa2-b6c120729ad7	0e06be7f-9df4-4e66-a58e-9eba6f026584	بررسی و تأیید صورت‌حساب‌های خرید #70	\N	medium	2026-07-17	82459ea2-ff93-499f-9f29-f7e1bd67d874	2026-07-20 05:56:06.688354+00	2026-07-20 05:56:06.688354+00	completed	approved	100	34.20	2026-07-15
d36d9bdb-efba-436c-9ad9-e7c217d45a60	8284e4d9-0201-4c88-ad0e-dc4326260101	\N	fbfe2b53-dcf1-4ee4-acf0-7c1a3cace4db	0e06be7f-9df4-4e66-a58e-9eba6f026584	تهیهٔ گزارش سود و زیان ماهانه #71	\N	low	2026-08-16	e7e14e5b-0f98-452a-8d35-70e162470dad	2026-07-20 05:56:06.688354+00	2026-07-20 05:56:06.688354+00	completed	approved	100	14.20	2026-07-31
d36d9bdb-efba-436c-9ad9-e7c217d45a60	8284e4d9-0201-4c88-ad0e-dc4326260101	\N	455d9757-37bc-4fe6-8025-e1efb66d8672	0e06be7f-9df4-4e66-a58e-9eba6f026584	بررسی صورت وضعیت پیمانکاران #72	\N	high	2026-07-04	7d74a778-a89f-4402-8e55-0441477b00f7	2026-07-20 05:56:06.688354+00	2026-07-20 05:56:06.688354+00	todo	\N	74	22.80	2026-06-24
d36d9bdb-efba-436c-9ad9-e7c217d45a60	f72202f7-5c82-44e7-9482-6ac4f392d5d3	\N	f892958c-2fb8-40b3-ba0e-5c62223aef14	0e06be7f-9df4-4e66-a58e-9eba6f026584	پیگیری مطالبات معوق مشتریان #73	\N	medium	2026-08-11	fc2388b2-f088-486d-a41c-d0feed33ab1f	2026-07-20 05:56:06.688354+00	2026-07-20 05:56:06.688354+00	in_progress	\N	64	25.00	2026-07-24
d36d9bdb-efba-436c-9ad9-e7c217d45a60	f72202f7-5c82-44e7-9482-6ac4f392d5d3	\N	0e06be7f-9df4-4e66-a58e-9eba6f026584	0e06be7f-9df4-4e66-a58e-9eba6f026584	تهیهٔ گزارش جریان نقدی #74	\N	low	2026-08-15	9ba3d90b-869d-4b75-b536-30ba51f25b2b	2026-07-20 05:56:06.688354+00	2026-07-20 05:56:06.688354+00	completed	approved	100	18.30	2026-07-27
d36d9bdb-efba-436c-9ad9-e7c217d45a60	f72202f7-5c82-44e7-9482-6ac4f392d5d3	\N	455d9757-37bc-4fe6-8025-e1efb66d8672	0e06be7f-9df4-4e66-a58e-9eba6f026584	بررسی فاکتورهای فروش صادرشده #75	\N	medium	2026-07-23	7b9746a8-19c8-4d00-82cf-ee710cbe5b9d	2026-07-20 05:56:06.688354+00	2026-07-20 05:56:06.688354+00	in_progress	\N	12	13.90	2026-07-07
d36d9bdb-efba-436c-9ad9-e7c217d45a60	f72202f7-5c82-44e7-9482-6ac4f392d5d3	\N	f892958c-2fb8-40b3-ba0e-5c62223aef14	0e06be7f-9df4-4e66-a58e-9eba6f026584	تهیهٔ گزارش سود و زیان ماهانه #76	\N	low	2026-07-12	48455f9d-3783-4dad-a43d-a57e1b6f42e5	2026-07-20 05:56:06.688354+00	2026-07-20 05:56:06.688354+00	completed	approved	100	33.60	2026-06-25
d36d9bdb-efba-436c-9ad9-e7c217d45a60	f72202f7-5c82-44e7-9482-6ac4f392d5d3	\N	0e06be7f-9df4-4e66-a58e-9eba6f026584	0e06be7f-9df4-4e66-a58e-9eba6f026584	بررسی و تسویهٔ کارت اعتباری شرکت #77	\N	low	2026-08-15	e738a164-1d48-4fbf-8873-ecc971a9721d	2026-07-20 05:56:06.688354+00	2026-07-20 05:56:06.688354+00	completed	approved	100	23.10	2026-08-02
d36d9bdb-efba-436c-9ad9-e7c217d45a60	f72202f7-5c82-44e7-9482-6ac4f392d5d3	\N	30621a70-ecd1-4c9b-a6c0-5b071dab4d1c	0e06be7f-9df4-4e66-a58e-9eba6f026584	بررسی فاکتورهای فروش صادرشده #78	\N	medium	2026-08-02	1a7d62ab-55ce-44f1-b9b7-018a4bf91b12	2026-07-20 05:56:06.688354+00	2026-07-20 05:56:06.688354+00	completed	approved	100	35.20	2026-07-28
d36d9bdb-efba-436c-9ad9-e7c217d45a60	f72202f7-5c82-44e7-9482-6ac4f392d5d3	\N	7653733b-3526-47fd-8fa2-b6c120729ad7	0e06be7f-9df4-4e66-a58e-9eba6f026584	پیگیری مطالبات معوق مشتریان #79	\N	high	2026-08-13	05c9215d-9970-4040-993b-c1db5dfbd15c	2026-07-20 05:56:06.688354+00	2026-07-20 05:56:06.688354+00	in_progress	\N	39	15.40	2026-08-10
d36d9bdb-efba-436c-9ad9-e7c217d45a60	f72202f7-5c82-44e7-9482-6ac4f392d5d3	\N	30621a70-ecd1-4c9b-a6c0-5b071dab4d1c	0e06be7f-9df4-4e66-a58e-9eba6f026584	ثبت اسناد حسابداری هفتگی #80	\N	low	2026-08-14	64cbac83-66f7-4360-b718-ccfb65a832a9	2026-07-20 05:56:06.688354+00	2026-07-20 05:56:06.688354+00	completed	approved	100	15.30	2026-07-28
d36d9bdb-efba-436c-9ad9-e7c217d45a60	f72202f7-5c82-44e7-9482-6ac4f392d5d3	\N	30621a70-ecd1-4c9b-a6c0-5b071dab4d1c	0e06be7f-9df4-4e66-a58e-9eba6f026584	بررسی صورت وضعیت پیمانکاران #81	\N	low	2026-07-03	e70fa87c-63c5-4a82-aaab-53d3e99c4f93	2026-07-20 05:56:06.688354+00	2026-07-20 05:56:06.688354+00	in_progress	\N	54	34.10	2026-06-23
d36d9bdb-efba-436c-9ad9-e7c217d45a60	f72202f7-5c82-44e7-9482-6ac4f392d5d3	\N	7653733b-3526-47fd-8fa2-b6c120729ad7	0e06be7f-9df4-4e66-a58e-9eba6f026584	بررسی و تأیید صورت‌حساب‌های خرید #82	\N	high	2026-08-15	fa5298b8-7c19-496c-b904-ed3bcbaf14ff	2026-07-20 05:56:06.688354+00	2026-07-20 05:56:06.688354+00	completed	pending	100	37.30	2026-07-27
d36d9bdb-efba-436c-9ad9-e7c217d45a60	f72202f7-5c82-44e7-9482-6ac4f392d5d3	\N	7653733b-3526-47fd-8fa2-b6c120729ad7	0e06be7f-9df4-4e66-a58e-9eba6f026584	تهیهٔ گزارش جریان نقدی #83	\N	medium	2026-07-07	7ee97ac1-fc7b-49f7-b9e1-146b8d5faa7e	2026-07-20 05:56:06.688354+00	2026-07-20 05:56:06.688354+00	completed	approved	100	37.00	2026-06-27
d36d9bdb-efba-436c-9ad9-e7c217d45a60	f72202f7-5c82-44e7-9482-6ac4f392d5d3	\N	f892958c-2fb8-40b3-ba0e-5c62223aef14	0e06be7f-9df4-4e66-a58e-9eba6f026584	بررسی صورت وضعیت پیمانکاران #84	\N	high	2026-07-03	d634d621-0a71-4d26-a754-7688fbbed41b	2026-07-20 05:56:06.688354+00	2026-07-20 05:56:06.688354+00	todo	\N	51	4.60	2026-06-27
d36d9bdb-efba-436c-9ad9-e7c217d45a60	f72202f7-5c82-44e7-9482-6ac4f392d5d3	\N	77fe864d-692a-4798-9e36-b464ad1c9e1c	0e06be7f-9df4-4e66-a58e-9eba6f026584	ثبت اسناد حسابداری هفتگی #85	\N	medium	2026-07-09	a9f5b863-711f-4823-a8f8-a298289b2e10	2026-07-20 05:56:06.688354+00	2026-07-20 05:56:06.688354+00	completed	rejected	100	18.00	2026-06-21
d36d9bdb-efba-436c-9ad9-e7c217d45a60	f72202f7-5c82-44e7-9482-6ac4f392d5d3	\N	f892958c-2fb8-40b3-ba0e-5c62223aef14	0e06be7f-9df4-4e66-a58e-9eba6f026584	تهیهٔ گزارش جریان نقدی #86	\N	medium	2026-07-20	59ed71b4-9058-4384-8a7a-9cb7e7dd9780	2026-07-20 05:56:06.688354+00	2026-07-20 05:56:06.688354+00	todo	\N	72	24.70	2026-07-09
d36d9bdb-efba-436c-9ad9-e7c217d45a60	f72202f7-5c82-44e7-9482-6ac4f392d5d3	\N	0e06be7f-9df4-4e66-a58e-9eba6f026584	0e06be7f-9df4-4e66-a58e-9eba6f026584	بررسی و تأیید صورت‌حساب‌های خرید #87	\N	high	2026-07-17	763d6762-907e-465a-8c14-555f1f16a630	2026-07-20 05:56:06.688354+00	2026-07-20 05:56:06.688354+00	todo	\N	10	12.30	2026-06-26
d36d9bdb-efba-436c-9ad9-e7c217d45a60	f72202f7-5c82-44e7-9482-6ac4f392d5d3	\N	77fe864d-692a-4798-9e36-b464ad1c9e1c	0e06be7f-9df4-4e66-a58e-9eba6f026584	به‌روزرسانی جدول حقوق و دستمزد #88	\N	medium	2026-08-07	cfd02b00-b27e-4bfb-91bb-0d0052e016fb	2026-07-20 05:56:06.688354+00	2026-07-20 05:56:06.688354+00	in_progress	\N	34	10.20	2026-07-17
d36d9bdb-efba-436c-9ad9-e7c217d45a60	f72202f7-5c82-44e7-9482-6ac4f392d5d3	\N	30621a70-ecd1-4c9b-a6c0-5b071dab4d1c	0e06be7f-9df4-4e66-a58e-9eba6f026584	تهیهٔ گزارش سود و زیان ماهانه #89	\N	medium	2026-07-23	a072a9df-394a-426d-9199-80cf3d4c3a16	2026-07-20 05:56:06.688354+00	2026-07-20 05:56:06.688354+00	todo	\N	75	20.50	2026-07-08
d36d9bdb-efba-436c-9ad9-e7c217d45a60	f72202f7-5c82-44e7-9482-6ac4f392d5d3	\N	77fe864d-692a-4798-9e36-b464ad1c9e1c	0e06be7f-9df4-4e66-a58e-9eba6f026584	بررسی فاکتورهای فروش صادرشده #90	\N	high	2026-06-27	af8b6d41-1fb4-4ec2-88db-4bb5a7013f3f	2026-07-20 05:56:06.688354+00	2026-07-20 05:56:06.688354+00	in_progress	\N	7	2.30	2026-06-18
d36d9bdb-efba-436c-9ad9-e7c217d45a60	\N	\N	f892958c-2fb8-40b3-ba0e-5c62223aef14	f892958c-2fb8-40b3-ba0e-5c62223aef14	بررسی و تسویهٔ کارت اعتباری شرکت #91	\N	medium	2026-08-10	55c6f7ad-259c-4f7a-b8ac-9cb0b4b1ac7c	2026-07-20 05:56:06.688354+00	2026-07-20 05:56:06.688354+00	in_progress	\N	37	14.50	2026-08-04
d36d9bdb-efba-436c-9ad9-e7c217d45a60	\N	\N	0e06be7f-9df4-4e66-a58e-9eba6f026584	0e06be7f-9df4-4e66-a58e-9eba6f026584	بررسی فاکتورهای فروش صادرشده #92	\N	high	2026-07-03	3c68fec4-ba2e-435a-ba14-2b88d54b28ed	2026-07-20 05:56:06.688354+00	2026-07-20 05:56:06.688354+00	completed	pending	100	28.70	2026-06-27
d36d9bdb-efba-436c-9ad9-e7c217d45a60	\N	\N	30621a70-ecd1-4c9b-a6c0-5b071dab4d1c	30621a70-ecd1-4c9b-a6c0-5b071dab4d1c	تهیهٔ گزارش سود و زیان ماهانه #93	\N	medium	2026-08-19	f9b52b1c-22c9-4213-b921-158de318adeb	2026-07-20 05:56:06.688354+00	2026-07-20 05:56:06.688354+00	completed	pending	100	34.70	2026-08-06
d36d9bdb-efba-436c-9ad9-e7c217d45a60	\N	\N	0e06be7f-9df4-4e66-a58e-9eba6f026584	0e06be7f-9df4-4e66-a58e-9eba6f026584	پیگیری بیمهٔ کارکنان #94	\N	medium	2026-08-17	f4bedcab-05be-4161-84dc-0375b47bc12b	2026-07-20 05:56:06.688354+00	2026-07-20 05:56:06.688354+00	completed	approved	100	23.90	2026-08-13
d36d9bdb-efba-436c-9ad9-e7c217d45a60	\N	\N	30621a70-ecd1-4c9b-a6c0-5b071dab4d1c	30621a70-ecd1-4c9b-a6c0-5b071dab4d1c	پیگیری مطالبات معوق مشتریان #95	\N	low	2026-08-15	a83601e4-bb33-457f-b1e3-eb863728619f	2026-07-20 05:56:06.688354+00	2026-07-20 05:56:06.688354+00	in_progress	\N	51	2.80	2026-07-31
d36d9bdb-efba-436c-9ad9-e7c217d45a60	\N	\N	f892958c-2fb8-40b3-ba0e-5c62223aef14	f892958c-2fb8-40b3-ba0e-5c62223aef14	به‌روزرسانی جدول حقوق و دستمزد #96	\N	high	2026-08-27	c74d4258-c9a2-4d0e-bf44-c7c720903d24	2026-07-20 05:56:06.688354+00	2026-07-20 05:56:06.688354+00	todo	\N	46	5.30	2026-08-06
d36d9bdb-efba-436c-9ad9-e7c217d45a60	\N	\N	7653733b-3526-47fd-8fa2-b6c120729ad7	7653733b-3526-47fd-8fa2-b6c120729ad7	بررسی صورت وضعیت پیمانکاران #97	\N	medium	2026-07-16	bff8865a-e396-49d3-a940-a998fb162a9d	2026-07-20 05:56:06.688354+00	2026-07-20 05:56:06.688354+00	todo	\N	67	5.00	2026-07-01
d36d9bdb-efba-436c-9ad9-e7c217d45a60	\N	\N	7653733b-3526-47fd-8fa2-b6c120729ad7	7653733b-3526-47fd-8fa2-b6c120729ad7	ثبت اسناد حسابداری هفتگی #98	\N	medium	2026-08-14	33284ffd-e5d7-4f31-ba9f-2e0781f89936	2026-07-20 05:56:06.688354+00	2026-07-20 05:56:06.688354+00	in_progress	\N	21	4.90	2026-08-02
d36d9bdb-efba-436c-9ad9-e7c217d45a60	\N	\N	77fe864d-692a-4798-9e36-b464ad1c9e1c	77fe864d-692a-4798-9e36-b464ad1c9e1c	ثبت اسناد حسابداری هفتگی #99	\N	medium	2026-08-06	d69f4ceb-360f-4087-b5af-b4a773a8db8d	2026-07-20 05:56:06.688354+00	2026-07-20 05:56:06.688354+00	todo	\N	44	29.60	2026-07-19
d36d9bdb-efba-436c-9ad9-e7c217d45a60	\N	\N	7653733b-3526-47fd-8fa2-b6c120729ad7	7653733b-3526-47fd-8fa2-b6c120729ad7	مغایرت‌گیری حساب‌های بانکی #100	\N	medium	2026-07-06	1b03afc5-70d6-4295-8890-8bf1793ca8dd	2026-07-20 05:56:06.688354+00	2026-07-20 05:56:06.688354+00	completed	pending	100	9.50	2026-07-01
d36d9bdb-efba-436c-9ad9-e7c217d45a60	\N	\N	30621a70-ecd1-4c9b-a6c0-5b071dab4d1c	30621a70-ecd1-4c9b-a6c0-5b071dab4d1c	مغایرت‌گیری حساب‌های بانکی #101	\N	high	2026-08-07	646d5607-29af-4248-8ede-ec8c3723e07b	2026-07-20 05:56:06.688354+00	2026-07-20 05:56:06.688354+00	todo	\N	63	19.60	2026-08-03
d36d9bdb-efba-436c-9ad9-e7c217d45a60	\N	\N	30621a70-ecd1-4c9b-a6c0-5b071dab4d1c	30621a70-ecd1-4c9b-a6c0-5b071dab4d1c	تطبیق موجودی انبار با حساب‌ها #102	\N	high	2026-08-08	ee46c877-67a1-433e-8e92-0a37dafa1370	2026-07-20 05:56:06.688354+00	2026-07-20 05:56:06.688354+00	archived	\N	79	14.30	2026-07-23
d36d9bdb-efba-436c-9ad9-e7c217d45a60	\N	\N	77fe864d-692a-4798-9e36-b464ad1c9e1c	77fe864d-692a-4798-9e36-b464ad1c9e1c	تهیهٔ گزارش سود و زیان ماهانه #103	\N	medium	2026-07-11	5e58d5c6-c1ac-45ab-872c-c8476cb480fb	2026-07-20 05:56:06.688354+00	2026-07-20 05:56:06.688354+00	in_progress	\N	56	26.00	2026-06-25
d36d9bdb-efba-436c-9ad9-e7c217d45a60	\N	\N	7653733b-3526-47fd-8fa2-b6c120729ad7	7653733b-3526-47fd-8fa2-b6c120729ad7	تهیهٔ گزارش مالیاتی فصلی #104	\N	high	2026-07-26	de628d8c-e874-464b-9eab-3a69bdfee166	2026-07-20 05:56:06.688354+00	2026-07-20 05:56:06.688354+00	in_progress	\N	9	13.80	2026-07-23
d36d9bdb-efba-436c-9ad9-e7c217d45a60	\N	\N	fbfe2b53-dcf1-4ee4-acf0-7c1a3cace4db	fbfe2b53-dcf1-4ee4-acf0-7c1a3cace4db	پیگیری بیمهٔ کارکنان #105	\N	medium	2026-07-02	3204228f-73a9-404c-825f-3a115035c732	2026-07-20 05:56:06.688354+00	2026-07-20 05:56:06.688354+00	todo	\N	9	26.50	2026-06-19
d36d9bdb-efba-436c-9ad9-e7c217d45a60	9a60974f-3827-445d-b461-fbafefac8047	\N	5f17f47c-48cd-4442-9a0b-48558bc649ce	86adf704-3f12-404e-a458-aa2e0259864a	تهیهٔ گزارش غیبت و تأخیر #1	\N	high	2026-08-06	c7dbb0df-f1ed-42f7-95d2-5bdda00a8a32	2026-07-20 05:56:06.688354+00	2026-07-20 05:56:06.688354+00	todo	\N	67	3.40	2026-07-18
d36d9bdb-efba-436c-9ad9-e7c217d45a60	9a60974f-3827-445d-b461-fbafefac8047	\N	5f17f47c-48cd-4442-9a0b-48558bc649ce	86adf704-3f12-404e-a458-aa2e0259864a	تدوین برنامهٔ آموزشی سال آینده #2	\N	medium	2026-07-31	ce218a7d-0797-4bc6-a471-944e9d9a2bfb	2026-07-20 05:56:06.688354+00	2026-07-20 05:56:06.688354+00	archived	\N	19	8.20	2026-07-25
d36d9bdb-efba-436c-9ad9-e7c217d45a60	9a60974f-3827-445d-b461-fbafefac8047	\N	3e9d418d-c94e-4859-8756-2203f7d7c329	86adf704-3f12-404e-a458-aa2e0259864a	به‌روزرسانی پروندهٔ پرسنلی #3	\N	medium	2026-08-13	2ee99ce2-5f45-4b95-9386-da436d6f12d1	2026-07-20 05:56:06.688354+00	2026-07-20 05:56:06.688354+00	completed	pending	100	3.70	2026-08-06
d36d9bdb-efba-436c-9ad9-e7c217d45a60	9a60974f-3827-445d-b461-fbafefac8047	\N	5f17f47c-48cd-4442-9a0b-48558bc649ce	86adf704-3f12-404e-a458-aa2e0259864a	به‌روزرسانی آیین‌نامهٔ داخلی شرکت #4	\N	high	2026-08-04	a34d26b0-9189-48bb-bcaa-3834d96f8280	2026-07-20 05:56:06.688354+00	2026-07-20 05:56:06.688354+00	completed	pending	100	31.80	2026-07-14
d36d9bdb-efba-436c-9ad9-e7c217d45a60	9a60974f-3827-445d-b461-fbafefac8047	\N	28392456-2fc2-4f59-a145-fff7d356370c	86adf704-3f12-404e-a458-aa2e0259864a	بررسی درخواست ترفیع کارکنان #5	\N	low	2026-08-23	953d4867-ce6a-4d64-8265-266b9c02ba64	2026-07-20 05:56:06.688354+00	2026-07-20 05:56:06.688354+00	completed	approved	100	16.00	2026-08-06
d36d9bdb-efba-436c-9ad9-e7c217d45a60	9a60974f-3827-445d-b461-fbafefac8047	\N	5f98deeb-64ad-4c21-a955-cc484130bfa2	86adf704-3f12-404e-a458-aa2e0259864a	بررسی و تمدید قراردادهای پرسنلی #6	\N	high	2026-07-18	d843c53b-4837-4b32-b8b7-b6c6fa56dda2	2026-07-20 05:56:06.688354+00	2026-07-20 05:56:06.688354+00	completed	approved	100	17.90	2026-07-04
d36d9bdb-efba-436c-9ad9-e7c217d45a60	9a60974f-3827-445d-b461-fbafefac8047	\N	28392456-2fc2-4f59-a145-fff7d356370c	86adf704-3f12-404e-a458-aa2e0259864a	تهیهٔ گزارش ارزیابی عملکرد #7	\N	medium	2026-08-27	7982d74f-7ef0-4682-88ff-d94fd8a632b6	2026-07-20 05:56:06.688354+00	2026-07-20 05:56:06.688354+00	in_progress	\N	6	26.40	2026-08-06
d36d9bdb-efba-436c-9ad9-e7c217d45a60	9a60974f-3827-445d-b461-fbafefac8047	\N	3e9d418d-c94e-4859-8756-2203f7d7c329	86adf704-3f12-404e-a458-aa2e0259864a	به‌روزرسانی پروندهٔ پرسنلی #8	\N	high	2026-07-26	419c9226-4df1-4123-b199-a46b96af2625	2026-07-20 05:56:06.688354+00	2026-07-20 05:56:06.688354+00	in_progress	\N	15	12.80	2026-07-21
d36d9bdb-efba-436c-9ad9-e7c217d45a60	9a60974f-3827-445d-b461-fbafefac8047	\N	3e9d418d-c94e-4859-8756-2203f7d7c329	86adf704-3f12-404e-a458-aa2e0259864a	بررسی درخواست ترفیع کارکنان #9	\N	high	2026-07-19	01938415-21af-45d6-a4f6-95d649b84b3a	2026-07-20 05:56:06.688354+00	2026-07-20 05:56:06.688354+00	todo	\N	18	33.60	2026-07-03
d36d9bdb-efba-436c-9ad9-e7c217d45a60	9a60974f-3827-445d-b461-fbafefac8047	\N	86adf704-3f12-404e-a458-aa2e0259864a	86adf704-3f12-404e-a458-aa2e0259864a	بررسی درخواست ترفیع کارکنان #10	\N	medium	2026-08-23	18a249c2-7030-4068-a596-389c71ad50b5	2026-07-20 05:56:06.688354+00	2026-07-20 05:56:06.688354+00	in_progress	\N	3	17.80	2026-08-07
d36d9bdb-efba-436c-9ad9-e7c217d45a60	9a60974f-3827-445d-b461-fbafefac8047	\N	e6d6e516-bc90-467f-a35a-3c169219865e	86adf704-3f12-404e-a458-aa2e0259864a	پیگیری درخواست‌های رفاهی کارکنان #11	\N	low	2026-07-14	4d3444ac-c668-461e-8794-7456c3bf231f	2026-07-20 05:56:06.688354+00	2026-07-20 05:56:06.688354+00	completed	approved	100	3.10	2026-07-10
d36d9bdb-efba-436c-9ad9-e7c217d45a60	9a60974f-3827-445d-b461-fbafefac8047	\N	86adf704-3f12-404e-a458-aa2e0259864a	86adf704-3f12-404e-a458-aa2e0259864a	برگزاری نظرسنجی رضایت شغلی #12	\N	low	2026-08-08	8220d79c-1b6a-4ef4-a386-e73fd494271d	2026-07-20 05:56:06.688354+00	2026-07-20 05:56:06.688354+00	archived	\N	17	3.50	2026-07-27
d36d9bdb-efba-436c-9ad9-e7c217d45a60	9a60974f-3827-445d-b461-fbafefac8047	\N	3e9d418d-c94e-4859-8756-2203f7d7c329	86adf704-3f12-404e-a458-aa2e0259864a	برنامه‌ریزی رویداد تیم‌سازی #13	\N	high	2026-07-11	3b4c8b61-faca-4060-a13d-c8cb45acfef8	2026-07-20 05:56:06.688354+00	2026-07-20 05:56:06.688354+00	completed	pending	100	2.20	2026-06-24
d36d9bdb-efba-436c-9ad9-e7c217d45a60	9a60974f-3827-445d-b461-fbafefac8047	\N	86adf704-3f12-404e-a458-aa2e0259864a	86adf704-3f12-404e-a458-aa2e0259864a	تهیهٔ گزارش غیبت و تأخیر #14	\N	low	2026-07-10	ebbcc6c5-966f-4c16-aa45-9c0ebcdf90b0	2026-07-20 05:56:06.688354+00	2026-07-20 05:56:06.688354+00	todo	\N	70	37.70	2026-07-02
d36d9bdb-efba-436c-9ad9-e7c217d45a60	9a60974f-3827-445d-b461-fbafefac8047	\N	5f98deeb-64ad-4c21-a955-cc484130bfa2	86adf704-3f12-404e-a458-aa2e0259864a	برگزاری جلسهٔ آموزش کارکنان جدید #15	\N	medium	2026-08-15	5dbb7365-7902-4128-a87c-d190f2cfc423	2026-07-20 05:56:06.688354+00	2026-07-20 05:56:06.688354+00	completed	approved	100	6.60	2026-08-04
d36d9bdb-efba-436c-9ad9-e7c217d45a60	9a60974f-3827-445d-b461-fbafefac8047	\N	28392456-2fc2-4f59-a145-fff7d356370c	86adf704-3f12-404e-a458-aa2e0259864a	برنامه‌ریزی رویداد تیم‌سازی #16	\N	low	2026-08-16	61bd50a3-1773-4b28-ab6b-3ea463113c66	2026-07-20 05:56:06.688354+00	2026-07-20 05:56:06.688354+00	in_progress	\N	14	33.80	2026-07-26
d36d9bdb-efba-436c-9ad9-e7c217d45a60	9a60974f-3827-445d-b461-fbafefac8047	\N	e6d6e516-bc90-467f-a35a-3c169219865e	86adf704-3f12-404e-a458-aa2e0259864a	تدوین برنامهٔ آموزشی سال آینده #17	\N	low	2026-08-13	ae94d668-6fa6-4dd5-a8c1-e3ed190bccea	2026-07-20 05:56:06.688354+00	2026-07-20 05:56:06.688354+00	completed	approved	100	29.30	2026-07-26
d36d9bdb-efba-436c-9ad9-e7c217d45a60	9a60974f-3827-445d-b461-fbafefac8047	\N	5f17f47c-48cd-4442-9a0b-48558bc649ce	86adf704-3f12-404e-a458-aa2e0259864a	پیگیری درخواست‌های رفاهی کارکنان #18	\N	low	2026-07-07	04debb3d-1cd3-4996-853b-bf65b602f11d	2026-07-20 05:56:06.688354+00	2026-07-20 05:56:06.688354+00	in_progress	\N	73	17.80	2026-06-16
d36d9bdb-efba-436c-9ad9-e7c217d45a60	24168387-911b-4ecd-b6e3-d36517c7f745	\N	7be892eb-4087-4511-8e0a-5bac8a046af2	86adf704-3f12-404e-a458-aa2e0259864a	بررسی و تمدید قراردادهای پرسنلی #19	\N	high	2026-07-13	7b2859a1-4734-4a1f-95b0-4291efd700b9	2026-07-20 05:56:06.688354+00	2026-07-20 05:56:06.688354+00	completed	approved	100	21.30	2026-07-09
d36d9bdb-efba-436c-9ad9-e7c217d45a60	24168387-911b-4ecd-b6e3-d36517c7f745	\N	5f98deeb-64ad-4c21-a955-cc484130bfa2	86adf704-3f12-404e-a458-aa2e0259864a	بررسی رزومه‌های متقاضیان شغلی #20	\N	high	2026-08-27	85c918f1-2e16-43da-93ab-0df227c8e1d9	2026-07-20 05:56:06.688354+00	2026-07-20 05:56:06.688354+00	completed	approved	100	16.70	2026-08-10
d36d9bdb-efba-436c-9ad9-e7c217d45a60	24168387-911b-4ecd-b6e3-d36517c7f745	\N	5f17f47c-48cd-4442-9a0b-48558bc649ce	86adf704-3f12-404e-a458-aa2e0259864a	پیگیری درخواست‌های رفاهی کارکنان #21	\N	low	2026-08-04	503b07e5-cef4-4eb7-8045-9800e32c9d05	2026-07-20 05:56:06.688354+00	2026-07-20 05:56:06.688354+00	in_progress	\N	44	11.20	2026-08-02
d36d9bdb-efba-436c-9ad9-e7c217d45a60	24168387-911b-4ecd-b6e3-d36517c7f745	\N	7be892eb-4087-4511-8e0a-5bac8a046af2	86adf704-3f12-404e-a458-aa2e0259864a	تهیهٔ گزارش ارزیابی عملکرد #22	\N	low	2026-08-04	3a952608-b20c-49a6-9070-e9587cefba63	2026-07-20 05:56:06.688354+00	2026-07-20 05:56:06.688354+00	completed	approved	100	15.40	2026-07-23
d36d9bdb-efba-436c-9ad9-e7c217d45a60	24168387-911b-4ecd-b6e3-d36517c7f745	\N	5f17f47c-48cd-4442-9a0b-48558bc649ce	86adf704-3f12-404e-a458-aa2e0259864a	به‌روزرسانی پروندهٔ پرسنلی #23	\N	medium	2026-08-20	387b64c6-e8e2-4ff6-b9bf-8af195b596b5	2026-07-20 05:56:06.688354+00	2026-07-20 05:56:06.688354+00	completed	approved	100	26.00	2026-08-04
d36d9bdb-efba-436c-9ad9-e7c217d45a60	24168387-911b-4ecd-b6e3-d36517c7f745	\N	3e9d418d-c94e-4859-8756-2203f7d7c329	86adf704-3f12-404e-a458-aa2e0259864a	بررسی رزومه‌های متقاضیان شغلی #24	\N	medium	2026-07-06	4fecf31c-ce44-495a-baef-59051e3fe3c8	2026-07-20 05:56:06.688354+00	2026-07-20 05:56:06.688354+00	todo	\N	25	3.70	2026-06-20
d36d9bdb-efba-436c-9ad9-e7c217d45a60	24168387-911b-4ecd-b6e3-d36517c7f745	\N	28392456-2fc2-4f59-a145-fff7d356370c	86adf704-3f12-404e-a458-aa2e0259864a	بررسی و تمدید قراردادهای پرسنلی #25	\N	medium	2026-07-17	e3c2663d-dae5-4034-9e67-8cbb78c7efed	2026-07-20 05:56:06.688354+00	2026-07-20 05:56:06.688354+00	todo	\N	69	20.00	2026-07-06
d36d9bdb-efba-436c-9ad9-e7c217d45a60	24168387-911b-4ecd-b6e3-d36517c7f745	\N	86adf704-3f12-404e-a458-aa2e0259864a	86adf704-3f12-404e-a458-aa2e0259864a	به‌روزرسانی آیین‌نامهٔ داخلی شرکت #26	\N	medium	2026-08-04	d3cac23c-2be7-4831-8a78-22bc8030461b	2026-07-20 05:56:06.688354+00	2026-07-20 05:56:06.688354+00	archived	\N	6	34.90	2026-07-27
d36d9bdb-efba-436c-9ad9-e7c217d45a60	24168387-911b-4ecd-b6e3-d36517c7f745	\N	5f17f47c-48cd-4442-9a0b-48558bc649ce	86adf704-3f12-404e-a458-aa2e0259864a	تهیهٔ فرم ارزیابی سه‌ماهه #27	\N	medium	2026-07-06	63a8206d-6aaa-475b-8023-e92d3621712f	2026-07-20 05:56:06.688354+00	2026-07-20 05:56:06.688354+00	in_progress	\N	56	36.00	2026-06-23
d36d9bdb-efba-436c-9ad9-e7c217d45a60	24168387-911b-4ecd-b6e3-d36517c7f745	\N	e6d6e516-bc90-467f-a35a-3c169219865e	86adf704-3f12-404e-a458-aa2e0259864a	به‌روزرسانی پروندهٔ پرسنلی #28	\N	medium	2026-07-14	c2ccfea5-9bdf-41ac-abfb-c3c480b33919	2026-07-20 05:56:06.688354+00	2026-07-20 05:56:06.688354+00	in_progress	\N	47	37.10	2026-06-27
d36d9bdb-efba-436c-9ad9-e7c217d45a60	24168387-911b-4ecd-b6e3-d36517c7f745	\N	5f98deeb-64ad-4c21-a955-cc484130bfa2	86adf704-3f12-404e-a458-aa2e0259864a	به‌روزرسانی پروندهٔ پرسنلی #29	\N	medium	2026-08-10	8d866567-4e8f-4c5c-809d-f1d5fbd60f15	2026-07-20 05:56:06.688354+00	2026-07-20 05:56:06.688354+00	in_progress	\N	10	18.40	2026-08-06
d36d9bdb-efba-436c-9ad9-e7c217d45a60	24168387-911b-4ecd-b6e3-d36517c7f745	\N	3e9d418d-c94e-4859-8756-2203f7d7c329	86adf704-3f12-404e-a458-aa2e0259864a	پیگیری درخواست‌های رفاهی کارکنان #30	\N	low	2026-07-31	a50b10dc-7f2c-46d8-9dc7-9ce3bcdd9aec	2026-07-20 05:56:06.688354+00	2026-07-20 05:56:06.688354+00	todo	\N	10	14.50	2026-07-20
d36d9bdb-efba-436c-9ad9-e7c217d45a60	24168387-911b-4ecd-b6e3-d36517c7f745	\N	5f17f47c-48cd-4442-9a0b-48558bc649ce	86adf704-3f12-404e-a458-aa2e0259864a	به‌روزرسانی پروندهٔ پرسنلی #31	\N	medium	2026-08-04	bedcc83c-d0ae-425d-8e73-e7c9ff6681c8	2026-07-20 05:56:06.688354+00	2026-07-20 05:56:06.688354+00	in_progress	\N	21	28.20	2026-07-14
d36d9bdb-efba-436c-9ad9-e7c217d45a60	24168387-911b-4ecd-b6e3-d36517c7f745	\N	5f17f47c-48cd-4442-9a0b-48558bc649ce	86adf704-3f12-404e-a458-aa2e0259864a	تدوین برنامهٔ آموزشی سال آینده #32	\N	medium	2026-08-23	e41df6ae-ce8b-438e-8375-e25731ed6bad	2026-07-20 05:56:06.688354+00	2026-07-20 05:56:06.688354+00	completed	approved	100	12.40	2026-08-10
d36d9bdb-efba-436c-9ad9-e7c217d45a60	24168387-911b-4ecd-b6e3-d36517c7f745	\N	3e9d418d-c94e-4859-8756-2203f7d7c329	86adf704-3f12-404e-a458-aa2e0259864a	پیگیری درخواست‌های رفاهی کارکنان #33	\N	high	2026-07-04	aa17f531-e09c-4482-b3df-f54b6f704fab	2026-07-20 05:56:06.688354+00	2026-07-20 05:56:06.688354+00	todo	\N	20	38.20	2026-06-20
d36d9bdb-efba-436c-9ad9-e7c217d45a60	24168387-911b-4ecd-b6e3-d36517c7f745	\N	28392456-2fc2-4f59-a145-fff7d356370c	86adf704-3f12-404e-a458-aa2e0259864a	تهیهٔ گزارش ارزیابی عملکرد #34	\N	low	2026-07-17	2bcc2f50-c7fe-40fa-a4e0-ae55af227f2e	2026-07-20 05:56:06.688354+00	2026-07-20 05:56:06.688354+00	completed	pending	100	11.00	2026-07-14
d36d9bdb-efba-436c-9ad9-e7c217d45a60	24168387-911b-4ecd-b6e3-d36517c7f745	\N	7be892eb-4087-4511-8e0a-5bac8a046af2	86adf704-3f12-404e-a458-aa2e0259864a	تدوین برنامهٔ آموزشی سال آینده #35	\N	low	2026-07-23	1ecff37e-5e68-4b4a-9de8-ef7ff57b7a8c	2026-07-20 05:56:06.688354+00	2026-07-20 05:56:06.688354+00	in_progress	\N	77	7.80	2026-07-09
d36d9bdb-efba-436c-9ad9-e7c217d45a60	24168387-911b-4ecd-b6e3-d36517c7f745	\N	e6d6e516-bc90-467f-a35a-3c169219865e	86adf704-3f12-404e-a458-aa2e0259864a	برگزاری نظرسنجی رضایت شغلی #36	\N	low	2026-07-25	94a90de1-13c7-431f-a4d6-d83379992001	2026-07-20 05:56:06.688354+00	2026-07-20 05:56:06.688354+00	in_progress	\N	73	7.20	2026-07-09
d36d9bdb-efba-436c-9ad9-e7c217d45a60	b6279820-0573-42e9-9a92-593efb4b8d77	\N	5f17f47c-48cd-4442-9a0b-48558bc649ce	86adf704-3f12-404e-a458-aa2e0259864a	برگزاری جلسهٔ آموزش کارکنان جدید #37	\N	low	2026-07-16	fb4d276f-624a-4ee0-b90e-d2ae5c1c9ab1	2026-07-20 05:56:06.688354+00	2026-07-20 05:56:06.688354+00	in_progress	\N	3	30.00	2026-07-06
d36d9bdb-efba-436c-9ad9-e7c217d45a60	b6279820-0573-42e9-9a92-593efb4b8d77	\N	e6d6e516-bc90-467f-a35a-3c169219865e	86adf704-3f12-404e-a458-aa2e0259864a	به‌روزرسانی آیین‌نامهٔ داخلی شرکت #38	\N	medium	2026-07-26	2f333065-eb4a-4b4c-85f9-5f292ea4d9ed	2026-07-20 05:56:06.688354+00	2026-07-20 05:56:06.688354+00	completed	approved	100	28.80	2026-07-21
d36d9bdb-efba-436c-9ad9-e7c217d45a60	b6279820-0573-42e9-9a92-593efb4b8d77	\N	28392456-2fc2-4f59-a145-fff7d356370c	86adf704-3f12-404e-a458-aa2e0259864a	برگزاری جلسهٔ آموزش کارکنان جدید #39	\N	low	2026-08-30	1e162f96-593b-4222-b1c6-4db688e7879e	2026-07-20 05:56:06.688354+00	2026-07-20 05:56:06.688354+00	completed	approved	100	7.20	2026-08-13
d36d9bdb-efba-436c-9ad9-e7c217d45a60	b6279820-0573-42e9-9a92-593efb4b8d77	\N	86adf704-3f12-404e-a458-aa2e0259864a	86adf704-3f12-404e-a458-aa2e0259864a	برنامه‌ریزی مصاحبهٔ استخدامی #40	\N	high	2026-08-16	d9263dd9-f8bb-4186-bee3-f76cb444a8b7	2026-07-20 05:56:06.688354+00	2026-07-20 05:56:06.688354+00	completed	approved	100	38.80	2026-07-31
d36d9bdb-efba-436c-9ad9-e7c217d45a60	b6279820-0573-42e9-9a92-593efb4b8d77	\N	5f17f47c-48cd-4442-9a0b-48558bc649ce	86adf704-3f12-404e-a458-aa2e0259864a	بررسی و تمدید قراردادهای پرسنلی #41	\N	medium	2026-07-09	19993062-8c6d-4301-a96a-9641d89bef9f	2026-07-20 05:56:06.688354+00	2026-07-20 05:56:06.688354+00	completed	approved	100	35.90	2026-06-20
d36d9bdb-efba-436c-9ad9-e7c217d45a60	b6279820-0573-42e9-9a92-593efb4b8d77	\N	3e9d418d-c94e-4859-8756-2203f7d7c329	86adf704-3f12-404e-a458-aa2e0259864a	برگزاری نظرسنجی رضایت شغلی #42	\N	medium	2026-08-07	99d5d4a3-c87a-4d07-a756-43fa34b9a805	2026-07-20 05:56:06.688354+00	2026-07-20 05:56:06.688354+00	todo	\N	65	10.50	2026-07-31
d36d9bdb-efba-436c-9ad9-e7c217d45a60	b6279820-0573-42e9-9a92-593efb4b8d77	\N	28392456-2fc2-4f59-a145-fff7d356370c	86adf704-3f12-404e-a458-aa2e0259864a	بررسی رزومه‌های متقاضیان شغلی #43	\N	medium	2026-07-18	a15665ec-3a4c-4daa-926f-7bf8b422414e	2026-07-20 05:56:06.688354+00	2026-07-20 05:56:06.688354+00	todo	\N	70	23.70	2026-07-01
d36d9bdb-efba-436c-9ad9-e7c217d45a60	b6279820-0573-42e9-9a92-593efb4b8d77	\N	e6d6e516-bc90-467f-a35a-3c169219865e	86adf704-3f12-404e-a458-aa2e0259864a	برنامه‌ریزی مصاحبهٔ استخدامی #44	\N	medium	2026-08-15	bf91a459-0263-44fd-8f8c-17f0ee23fa19	2026-07-20 05:56:06.688354+00	2026-07-20 05:56:06.688354+00	completed	approved	100	17.10	2026-08-11
d36d9bdb-efba-436c-9ad9-e7c217d45a60	b6279820-0573-42e9-9a92-593efb4b8d77	\N	7be892eb-4087-4511-8e0a-5bac8a046af2	86adf704-3f12-404e-a458-aa2e0259864a	تهیهٔ فرم ارزیابی سه‌ماهه #45	\N	medium	2026-08-03	f042c1a1-3664-4860-9629-ece0a5a1c340	2026-07-20 05:56:06.688354+00	2026-07-20 05:56:06.688354+00	archived	\N	73	4.80	2026-07-16
d36d9bdb-efba-436c-9ad9-e7c217d45a60	b6279820-0573-42e9-9a92-593efb4b8d77	\N	5f17f47c-48cd-4442-9a0b-48558bc649ce	86adf704-3f12-404e-a458-aa2e0259864a	پیگیری درخواست‌های رفاهی کارکنان #46	\N	low	2026-08-02	53e712ec-cd80-4b1f-a5df-bfe1538c84d5	2026-07-20 05:56:06.688354+00	2026-07-20 05:56:06.688354+00	completed	approved	100	35.40	2026-07-15
d36d9bdb-efba-436c-9ad9-e7c217d45a60	b6279820-0573-42e9-9a92-593efb4b8d77	\N	3e9d418d-c94e-4859-8756-2203f7d7c329	86adf704-3f12-404e-a458-aa2e0259864a	تهیهٔ فرم ارزیابی سه‌ماهه #47	\N	high	2026-07-03	57d0d078-f8d6-49c9-a71f-bce4d919476c	2026-07-20 05:56:06.688354+00	2026-07-20 05:56:06.688354+00	completed	pending	100	36.60	2026-06-27
d36d9bdb-efba-436c-9ad9-e7c217d45a60	b6279820-0573-42e9-9a92-593efb4b8d77	\N	86adf704-3f12-404e-a458-aa2e0259864a	86adf704-3f12-404e-a458-aa2e0259864a	به‌روزرسانی آیین‌نامهٔ داخلی شرکت #48	\N	low	2026-07-25	8ae5e704-49df-4ab7-a632-e858bb0b54bf	2026-07-20 05:56:06.688354+00	2026-07-20 05:56:06.688354+00	todo	\N	20	14.30	2026-07-19
d36d9bdb-efba-436c-9ad9-e7c217d45a60	b6279820-0573-42e9-9a92-593efb4b8d77	\N	7be892eb-4087-4511-8e0a-5bac8a046af2	86adf704-3f12-404e-a458-aa2e0259864a	بررسی درخواست ترفیع کارکنان #49	\N	medium	2026-07-26	8ed0699f-35c0-495d-ba9f-a57974dac501	2026-07-20 05:56:06.688354+00	2026-07-20 05:56:06.688354+00	in_progress	\N	10	11.50	2026-07-08
d36d9bdb-efba-436c-9ad9-e7c217d45a60	b6279820-0573-42e9-9a92-593efb4b8d77	\N	7be892eb-4087-4511-8e0a-5bac8a046af2	86adf704-3f12-404e-a458-aa2e0259864a	تدوین برنامهٔ آموزشی سال آینده #50	\N	high	2026-08-06	79645774-dac2-430f-8dff-04957f26347f	2026-07-20 05:56:06.688354+00	2026-07-20 05:56:06.688354+00	completed	approved	100	5.60	2026-07-26
d36d9bdb-efba-436c-9ad9-e7c217d45a60	b6279820-0573-42e9-9a92-593efb4b8d77	\N	7be892eb-4087-4511-8e0a-5bac8a046af2	86adf704-3f12-404e-a458-aa2e0259864a	تهیهٔ گزارش ارزیابی عملکرد #51	\N	low	2026-08-12	90889ece-a602-4a5e-9509-dbd507200ad1	2026-07-20 05:56:06.688354+00	2026-07-20 05:56:06.688354+00	todo	\N	79	29.40	2026-07-23
d36d9bdb-efba-436c-9ad9-e7c217d45a60	b6279820-0573-42e9-9a92-593efb4b8d77	\N	5f98deeb-64ad-4c21-a955-cc484130bfa2	86adf704-3f12-404e-a458-aa2e0259864a	بررسی رزومه‌های متقاضیان شغلی #52	\N	low	2026-08-28	df53ea8a-500e-4f7f-be90-7b65092d5122	2026-07-20 05:56:06.688354+00	2026-07-20 05:56:06.688354+00	in_progress	\N	10	3.70	2026-08-08
d36d9bdb-efba-436c-9ad9-e7c217d45a60	b6279820-0573-42e9-9a92-593efb4b8d77	\N	7be892eb-4087-4511-8e0a-5bac8a046af2	86adf704-3f12-404e-a458-aa2e0259864a	پیگیری مرخصی و مأموریت کارکنان #53	\N	low	2026-08-01	e4dc9f07-c9ad-4d22-966a-4e0f63d0a55a	2026-07-20 05:56:06.688354+00	2026-07-20 05:56:06.688354+00	archived	\N	73	17.80	2026-07-22
d36d9bdb-efba-436c-9ad9-e7c217d45a60	b6279820-0573-42e9-9a92-593efb4b8d77	\N	7be892eb-4087-4511-8e0a-5bac8a046af2	86adf704-3f12-404e-a458-aa2e0259864a	به‌روزرسانی آیین‌نامهٔ داخلی شرکت #54	\N	high	2026-08-05	56b075de-86e2-4e8b-a5f3-d051aa5c341e	2026-07-20 05:56:06.688354+00	2026-07-20 05:56:06.688354+00	todo	\N	38	20.40	2026-07-17
d36d9bdb-efba-436c-9ad9-e7c217d45a60	be059dae-45fe-4d45-84fe-6b4eafa8e856	\N	3e9d418d-c94e-4859-8756-2203f7d7c329	86adf704-3f12-404e-a458-aa2e0259864a	به‌روزرسانی پروندهٔ پرسنلی #55	\N	low	2026-07-19	68d65a9d-86d1-46ab-b797-979545597a36	2026-07-20 05:56:06.688354+00	2026-07-20 05:56:06.688354+00	completed	approved	100	8.00	2026-07-15
d36d9bdb-efba-436c-9ad9-e7c217d45a60	be059dae-45fe-4d45-84fe-6b4eafa8e856	\N	e6d6e516-bc90-467f-a35a-3c169219865e	86adf704-3f12-404e-a458-aa2e0259864a	تهیهٔ گزارش ارزیابی عملکرد #56	\N	medium	2026-07-28	1b317971-6f75-4482-9987-cfe1bcea2ef1	2026-07-20 05:56:06.688354+00	2026-07-20 05:56:06.688354+00	completed	approved	100	34.70	2026-07-07
d36d9bdb-efba-436c-9ad9-e7c217d45a60	be059dae-45fe-4d45-84fe-6b4eafa8e856	\N	5f17f47c-48cd-4442-9a0b-48558bc649ce	86adf704-3f12-404e-a458-aa2e0259864a	تهیهٔ فرم ارزیابی سه‌ماهه #57	\N	low	2026-08-23	7f0e7b12-dbb5-479b-ab9d-7ecd16a4fefb	2026-07-20 05:56:06.688354+00	2026-07-20 05:56:06.688354+00	archived	\N	47	21.60	2026-08-10
d36d9bdb-efba-436c-9ad9-e7c217d45a60	be059dae-45fe-4d45-84fe-6b4eafa8e856	\N	86adf704-3f12-404e-a458-aa2e0259864a	86adf704-3f12-404e-a458-aa2e0259864a	برنامه‌ریزی مصاحبهٔ استخدامی #58	\N	medium	2026-07-17	6f2ad5b3-8461-4d1c-8367-bdb9ea151f0e	2026-07-20 05:56:06.688354+00	2026-07-20 05:56:06.688354+00	in_progress	\N	57	11.40	2026-07-01
d36d9bdb-efba-436c-9ad9-e7c217d45a60	be059dae-45fe-4d45-84fe-6b4eafa8e856	\N	86adf704-3f12-404e-a458-aa2e0259864a	86adf704-3f12-404e-a458-aa2e0259864a	تهیهٔ گزارش غیبت و تأخیر #59	\N	high	2026-07-18	323adcb5-a99e-4dff-8c38-2f8d4095fa69	2026-07-20 05:56:06.688354+00	2026-07-20 05:56:06.688354+00	todo	\N	53	11.40	2026-07-04
d36d9bdb-efba-436c-9ad9-e7c217d45a60	be059dae-45fe-4d45-84fe-6b4eafa8e856	\N	3e9d418d-c94e-4859-8756-2203f7d7c329	86adf704-3f12-404e-a458-aa2e0259864a	بررسی درخواست ترفیع کارکنان #60	\N	high	2026-08-19	2262c143-cb41-4e26-8228-cda542c58858	2026-07-20 05:56:06.688354+00	2026-07-20 05:56:06.688354+00	todo	\N	40	9.20	2026-08-07
d36d9bdb-efba-436c-9ad9-e7c217d45a60	be059dae-45fe-4d45-84fe-6b4eafa8e856	\N	28392456-2fc2-4f59-a145-fff7d356370c	86adf704-3f12-404e-a458-aa2e0259864a	بررسی درخواست ترفیع کارکنان #61	\N	medium	2026-08-01	01290aa9-c80b-4b6d-b4e3-e6def1aff80d	2026-07-20 05:56:06.688354+00	2026-07-20 05:56:06.688354+00	completed	rejected	100	20.90	2026-07-15
d36d9bdb-efba-436c-9ad9-e7c217d45a60	be059dae-45fe-4d45-84fe-6b4eafa8e856	\N	86adf704-3f12-404e-a458-aa2e0259864a	86adf704-3f12-404e-a458-aa2e0259864a	برگزاری جلسهٔ آموزش کارکنان جدید #62	\N	low	2026-08-03	40b196a4-9c8a-4a3e-ac9c-4f1ecc7c10ef	2026-07-20 05:56:06.688354+00	2026-07-20 05:56:06.688354+00	in_progress	\N	74	15.40	2026-07-18
d36d9bdb-efba-436c-9ad9-e7c217d45a60	be059dae-45fe-4d45-84fe-6b4eafa8e856	\N	86adf704-3f12-404e-a458-aa2e0259864a	86adf704-3f12-404e-a458-aa2e0259864a	بررسی درخواست ترفیع کارکنان #63	\N	high	2026-08-07	199841f9-a52e-475b-90c1-abbc277e7874	2026-07-20 05:56:06.688354+00	2026-07-20 05:56:06.688354+00	in_progress	\N	60	12.90	2026-07-17
d36d9bdb-efba-436c-9ad9-e7c217d45a60	be059dae-45fe-4d45-84fe-6b4eafa8e856	\N	86adf704-3f12-404e-a458-aa2e0259864a	86adf704-3f12-404e-a458-aa2e0259864a	بررسی درخواست ترفیع کارکنان #64	\N	medium	2026-07-19	93ca3fef-8669-4bed-a767-a8def7d3389c	2026-07-20 05:56:06.688354+00	2026-07-20 05:56:06.688354+00	todo	\N	46	31.00	2026-07-13
d36d9bdb-efba-436c-9ad9-e7c217d45a60	be059dae-45fe-4d45-84fe-6b4eafa8e856	\N	5f17f47c-48cd-4442-9a0b-48558bc649ce	86adf704-3f12-404e-a458-aa2e0259864a	تدوین برنامهٔ آموزشی سال آینده #65	\N	high	2026-07-14	b34b068f-6ee5-4712-8aa6-560c57910e27	2026-07-20 05:56:06.688354+00	2026-07-20 05:56:06.688354+00	todo	\N	24	15.80	2026-07-11
d36d9bdb-efba-436c-9ad9-e7c217d45a60	be059dae-45fe-4d45-84fe-6b4eafa8e856	\N	5f17f47c-48cd-4442-9a0b-48558bc649ce	86adf704-3f12-404e-a458-aa2e0259864a	برنامه‌ریزی رویداد تیم‌سازی #66	\N	high	2026-07-28	892d19e1-03ca-49a3-82ad-8fa87b60fa6c	2026-07-20 05:56:06.688354+00	2026-07-20 05:56:06.688354+00	todo	\N	35	33.40	2026-07-10
d36d9bdb-efba-436c-9ad9-e7c217d45a60	be059dae-45fe-4d45-84fe-6b4eafa8e856	\N	5f98deeb-64ad-4c21-a955-cc484130bfa2	86adf704-3f12-404e-a458-aa2e0259864a	تهیهٔ فرم ارزیابی سه‌ماهه #67	\N	medium	2026-06-29	0c7a3159-5c5d-4071-bb12-c56a89881540	2026-07-20 05:56:06.688354+00	2026-07-20 05:56:06.688354+00	completed	pending	100	32.20	2026-06-24
d36d9bdb-efba-436c-9ad9-e7c217d45a60	be059dae-45fe-4d45-84fe-6b4eafa8e856	\N	5f17f47c-48cd-4442-9a0b-48558bc649ce	86adf704-3f12-404e-a458-aa2e0259864a	برگزاری جلسهٔ آموزش کارکنان جدید #68	\N	high	2026-08-09	8e04fa56-04f7-43b7-a19b-64e649f7ba5f	2026-07-20 05:56:06.688354+00	2026-07-20 05:56:06.688354+00	completed	rejected	100	21.30	2026-08-03
d36d9bdb-efba-436c-9ad9-e7c217d45a60	be059dae-45fe-4d45-84fe-6b4eafa8e856	\N	5f98deeb-64ad-4c21-a955-cc484130bfa2	86adf704-3f12-404e-a458-aa2e0259864a	تهیهٔ گزارش ارزیابی عملکرد #69	\N	high	2026-06-21	9a33949a-5ca8-4624-b87b-8277f34f440f	2026-07-20 05:56:06.688354+00	2026-07-20 05:56:06.688354+00	todo	\N	42	32.60	2026-06-18
d36d9bdb-efba-436c-9ad9-e7c217d45a60	be059dae-45fe-4d45-84fe-6b4eafa8e856	\N	5f98deeb-64ad-4c21-a955-cc484130bfa2	86adf704-3f12-404e-a458-aa2e0259864a	تهیهٔ گزارش ارزیابی عملکرد #70	\N	medium	2026-08-30	6a822a97-829c-4337-9486-5dff4b0f16f1	2026-07-20 05:56:06.688354+00	2026-07-20 05:56:06.688354+00	completed	approved	100	37.40	2026-08-12
d36d9bdb-efba-436c-9ad9-e7c217d45a60	be059dae-45fe-4d45-84fe-6b4eafa8e856	\N	5f17f47c-48cd-4442-9a0b-48558bc649ce	86adf704-3f12-404e-a458-aa2e0259864a	به‌روزرسانی پروندهٔ پرسنلی #71	\N	medium	2026-08-01	30a4deb4-2fb9-4ea1-9934-edcf0949f9a2	2026-07-20 05:56:06.688354+00	2026-07-20 05:56:06.688354+00	todo	\N	75	14.80	2026-07-11
d36d9bdb-efba-436c-9ad9-e7c217d45a60	be059dae-45fe-4d45-84fe-6b4eafa8e856	\N	3e9d418d-c94e-4859-8756-2203f7d7c329	86adf704-3f12-404e-a458-aa2e0259864a	به‌روزرسانی آیین‌نامهٔ داخلی شرکت #72	\N	medium	2026-08-20	4d9afa99-91bc-4465-8434-50176a6b4c23	2026-07-20 05:56:06.688354+00	2026-07-20 05:56:06.688354+00	completed	approved	100	33.00	2026-07-31
d36d9bdb-efba-436c-9ad9-e7c217d45a60	b5def797-6aa4-4191-afb3-8cca2c39a9e9	\N	5f17f47c-48cd-4442-9a0b-48558bc649ce	86adf704-3f12-404e-a458-aa2e0259864a	تهیهٔ فرم ارزیابی سه‌ماهه #73	\N	high	2026-08-03	a3ff8ecf-eb61-48bd-8c87-4de06938b86d	2026-07-20 05:56:06.688354+00	2026-07-20 05:56:06.688354+00	in_progress	\N	39	32.30	2026-07-29
d36d9bdb-efba-436c-9ad9-e7c217d45a60	b5def797-6aa4-4191-afb3-8cca2c39a9e9	\N	7be892eb-4087-4511-8e0a-5bac8a046af2	86adf704-3f12-404e-a458-aa2e0259864a	به‌روزرسانی آیین‌نامهٔ داخلی شرکت #74	\N	high	2026-08-10	411548e5-c3a4-4a80-8f51-23366a9143ff	2026-07-20 05:56:06.688354+00	2026-07-20 05:56:06.688354+00	completed	pending	100	31.80	2026-07-24
d36d9bdb-efba-436c-9ad9-e7c217d45a60	b5def797-6aa4-4191-afb3-8cca2c39a9e9	\N	3e9d418d-c94e-4859-8756-2203f7d7c329	86adf704-3f12-404e-a458-aa2e0259864a	تدوین برنامهٔ آموزشی سال آینده #75	\N	medium	2026-08-04	9af60909-af0d-4607-892e-acede0cf84ef	2026-07-20 05:56:06.688354+00	2026-07-20 05:56:06.688354+00	completed	approved	100	8.50	2026-08-01
d36d9bdb-efba-436c-9ad9-e7c217d45a60	b5def797-6aa4-4191-afb3-8cca2c39a9e9	\N	7be892eb-4087-4511-8e0a-5bac8a046af2	86adf704-3f12-404e-a458-aa2e0259864a	تهیهٔ گزارش ارزیابی عملکرد #76	\N	high	2026-08-08	949c3a40-c1aa-45ed-8eba-5c0a92807c47	2026-07-20 05:56:06.688354+00	2026-07-20 05:56:06.688354+00	archived	\N	31	3.20	2026-07-25
d36d9bdb-efba-436c-9ad9-e7c217d45a60	b5def797-6aa4-4191-afb3-8cca2c39a9e9	\N	7be892eb-4087-4511-8e0a-5bac8a046af2	86adf704-3f12-404e-a458-aa2e0259864a	برنامه‌ریزی رویداد تیم‌سازی #77	\N	medium	2026-06-30	e9ffab69-23c9-4e83-958a-2623d1e0592f	2026-07-20 05:56:06.688354+00	2026-07-20 05:56:06.688354+00	todo	\N	53	7.80	2026-06-28
d36d9bdb-efba-436c-9ad9-e7c217d45a60	b5def797-6aa4-4191-afb3-8cca2c39a9e9	\N	7be892eb-4087-4511-8e0a-5bac8a046af2	86adf704-3f12-404e-a458-aa2e0259864a	برگزاری نظرسنجی رضایت شغلی #78	\N	high	2026-07-30	2ed2010b-2b7f-4fc5-9c99-8472c48c7223	2026-07-20 05:56:06.688354+00	2026-07-20 05:56:06.688354+00	in_progress	\N	60	35.20	2026-07-12
d36d9bdb-efba-436c-9ad9-e7c217d45a60	b5def797-6aa4-4191-afb3-8cca2c39a9e9	\N	7be892eb-4087-4511-8e0a-5bac8a046af2	86adf704-3f12-404e-a458-aa2e0259864a	بررسی و تمدید قراردادهای پرسنلی #79	\N	low	2026-06-25	28d90810-1e7c-454c-b1b3-d8291e616fd1	2026-07-20 05:56:06.688354+00	2026-07-20 05:56:06.688354+00	archived	\N	71	14.40	2026-06-19
d36d9bdb-efba-436c-9ad9-e7c217d45a60	b5def797-6aa4-4191-afb3-8cca2c39a9e9	\N	7be892eb-4087-4511-8e0a-5bac8a046af2	86adf704-3f12-404e-a458-aa2e0259864a	برنامه‌ریزی رویداد تیم‌سازی #80	\N	high	2026-07-13	b731ec74-8b55-492c-94f3-2af21d0bb995	2026-07-20 05:56:06.688354+00	2026-07-20 05:56:06.688354+00	completed	approved	100	15.00	2026-07-06
d36d9bdb-efba-436c-9ad9-e7c217d45a60	b5def797-6aa4-4191-afb3-8cca2c39a9e9	\N	5f17f47c-48cd-4442-9a0b-48558bc649ce	86adf704-3f12-404e-a458-aa2e0259864a	تدوین برنامهٔ آموزشی سال آینده #81	\N	medium	2026-08-11	0b1d7735-2138-4066-bd06-d199ecc6285e	2026-07-20 05:56:06.688354+00	2026-07-20 05:56:06.688354+00	completed	pending	100	9.30	2026-08-01
d36d9bdb-efba-436c-9ad9-e7c217d45a60	b5def797-6aa4-4191-afb3-8cca2c39a9e9	\N	28392456-2fc2-4f59-a145-fff7d356370c	86adf704-3f12-404e-a458-aa2e0259864a	برگزاری جلسهٔ آموزش کارکنان جدید #82	\N	medium	2026-08-01	bbaedeca-4f55-4d0e-a91e-4d039c7424d7	2026-07-20 05:56:06.688354+00	2026-07-20 05:56:06.688354+00	in_progress	\N	36	28.80	2026-07-21
d36d9bdb-efba-436c-9ad9-e7c217d45a60	b5def797-6aa4-4191-afb3-8cca2c39a9e9	\N	7be892eb-4087-4511-8e0a-5bac8a046af2	86adf704-3f12-404e-a458-aa2e0259864a	برنامه‌ریزی رویداد تیم‌سازی #83	\N	medium	2026-07-29	1b8b46ee-9925-42e4-ad68-b4f79552284f	2026-07-20 05:56:06.688354+00	2026-07-20 05:56:06.688354+00	archived	\N	71	37.50	2026-07-17
d36d9bdb-efba-436c-9ad9-e7c217d45a60	b5def797-6aa4-4191-afb3-8cca2c39a9e9	\N	3e9d418d-c94e-4859-8756-2203f7d7c329	86adf704-3f12-404e-a458-aa2e0259864a	برنامه‌ریزی مصاحبهٔ استخدامی #84	\N	high	2026-07-14	48b9e02f-661c-408a-b268-7eb5285b6c69	2026-07-20 05:56:06.688354+00	2026-07-20 05:56:06.688354+00	archived	\N	69	16.40	2026-07-03
d36d9bdb-efba-436c-9ad9-e7c217d45a60	b5def797-6aa4-4191-afb3-8cca2c39a9e9	\N	e6d6e516-bc90-467f-a35a-3c169219865e	86adf704-3f12-404e-a458-aa2e0259864a	به‌روزرسانی آیین‌نامهٔ داخلی شرکت #85	\N	low	2026-08-10	3c21774f-ec9e-4aba-a79f-b8a44572d026	2026-07-20 05:56:06.688354+00	2026-07-20 05:56:06.688354+00	in_progress	\N	36	38.30	2026-08-04
d36d9bdb-efba-436c-9ad9-e7c217d45a60	b5def797-6aa4-4191-afb3-8cca2c39a9e9	\N	86adf704-3f12-404e-a458-aa2e0259864a	86adf704-3f12-404e-a458-aa2e0259864a	پیگیری مرخصی و مأموریت کارکنان #86	\N	medium	2026-08-30	34275604-8bf1-43b3-9141-f543d9695bfe	2026-07-20 05:56:06.688354+00	2026-07-20 05:56:06.688354+00	in_progress	\N	61	10.10	2026-08-14
d36d9bdb-efba-436c-9ad9-e7c217d45a60	b5def797-6aa4-4191-afb3-8cca2c39a9e9	\N	3e9d418d-c94e-4859-8756-2203f7d7c329	86adf704-3f12-404e-a458-aa2e0259864a	تهیهٔ گزارش ارزیابی عملکرد #87	\N	low	2026-07-31	09c2f9c3-7d31-47a3-bd23-4d74673b5cca	2026-07-20 05:56:06.688354+00	2026-07-20 05:56:06.688354+00	completed	approved	100	25.40	2026-07-21
d36d9bdb-efba-436c-9ad9-e7c217d45a60	b5def797-6aa4-4191-afb3-8cca2c39a9e9	\N	5f98deeb-64ad-4c21-a955-cc484130bfa2	86adf704-3f12-404e-a458-aa2e0259864a	پیگیری مرخصی و مأموریت کارکنان #88	\N	high	2026-07-04	a45056a2-0502-4708-b891-656a5f27f862	2026-07-20 05:56:06.688354+00	2026-07-20 05:56:06.688354+00	in_progress	\N	28	26.20	2026-07-01
d36d9bdb-efba-436c-9ad9-e7c217d45a60	b5def797-6aa4-4191-afb3-8cca2c39a9e9	\N	86adf704-3f12-404e-a458-aa2e0259864a	86adf704-3f12-404e-a458-aa2e0259864a	به‌روزرسانی پروندهٔ پرسنلی #89	\N	medium	2026-07-24	a30ef846-a127-45f5-b652-426f3059a363	2026-07-20 05:56:06.688354+00	2026-07-20 05:56:06.688354+00	todo	\N	12	27.90	2026-07-12
d36d9bdb-efba-436c-9ad9-e7c217d45a60	b5def797-6aa4-4191-afb3-8cca2c39a9e9	\N	28392456-2fc2-4f59-a145-fff7d356370c	86adf704-3f12-404e-a458-aa2e0259864a	تهیهٔ فرم ارزیابی سه‌ماهه #90	\N	high	2026-07-28	0a346400-4040-4cae-a99f-166176e589db	2026-07-20 05:56:06.688354+00	2026-07-20 05:56:06.688354+00	todo	\N	60	20.10	2026-07-21
d36d9bdb-efba-436c-9ad9-e7c217d45a60	\N	\N	28392456-2fc2-4f59-a145-fff7d356370c	28392456-2fc2-4f59-a145-fff7d356370c	به‌روزرسانی آیین‌نامهٔ داخلی شرکت #91	\N	high	2026-07-16	a33c4f62-f031-4578-afcb-6f67485311d2	2026-07-20 05:56:06.688354+00	2026-07-20 05:56:06.688354+00	archived	\N	7	36.50	2026-07-04
d36d9bdb-efba-436c-9ad9-e7c217d45a60	\N	\N	86adf704-3f12-404e-a458-aa2e0259864a	86adf704-3f12-404e-a458-aa2e0259864a	بررسی درخواست ترفیع کارکنان #92	\N	low	2026-07-23	4ea14f8f-7591-4ab8-921c-bebab4a0d6f0	2026-07-20 05:56:06.688354+00	2026-07-20 05:56:06.688354+00	completed	approved	100	17.90	2026-07-20
d36d9bdb-efba-436c-9ad9-e7c217d45a60	\N	\N	3e9d418d-c94e-4859-8756-2203f7d7c329	3e9d418d-c94e-4859-8756-2203f7d7c329	تهیهٔ گزارش غیبت و تأخیر #93	\N	medium	2026-08-17	38aec366-7d40-4516-8689-6dbd46c4eab2	2026-07-20 05:56:06.688354+00	2026-07-20 05:56:06.688354+00	todo	\N	63	9.10	2026-08-14
d36d9bdb-efba-436c-9ad9-e7c217d45a60	\N	\N	7be892eb-4087-4511-8e0a-5bac8a046af2	7be892eb-4087-4511-8e0a-5bac8a046af2	بررسی رزومه‌های متقاضیان شغلی #94	\N	medium	2026-08-14	f5edf46d-d71a-4813-9f1b-1b4d7181d5b5	2026-07-20 05:56:06.688354+00	2026-07-20 05:56:06.688354+00	in_progress	\N	72	24.90	2026-08-11
d36d9bdb-efba-436c-9ad9-e7c217d45a60	\N	\N	5f17f47c-48cd-4442-9a0b-48558bc649ce	5f17f47c-48cd-4442-9a0b-48558bc649ce	بررسی و تمدید قراردادهای پرسنلی #95	\N	medium	2026-08-03	747ea60d-7c62-4ab0-8e57-426c4dc8e8de	2026-07-20 05:56:06.688354+00	2026-07-20 05:56:06.688354+00	in_progress	\N	17	34.30	2026-07-15
d36d9bdb-efba-436c-9ad9-e7c217d45a60	\N	\N	e6d6e516-bc90-467f-a35a-3c169219865e	e6d6e516-bc90-467f-a35a-3c169219865e	پیگیری درخواست‌های رفاهی کارکنان #96	\N	low	2026-07-03	89cc628e-c50b-49b5-b2f8-e993209f9e81	2026-07-20 05:56:06.688354+00	2026-07-20 05:56:06.688354+00	in_progress	\N	58	26.60	2026-06-28
d36d9bdb-efba-436c-9ad9-e7c217d45a60	\N	\N	7be892eb-4087-4511-8e0a-5bac8a046af2	7be892eb-4087-4511-8e0a-5bac8a046af2	برگزاری نظرسنجی رضایت شغلی #97	\N	medium	2026-06-28	326f3713-2309-4ca4-8c78-906f8458f489	2026-07-20 05:56:06.688354+00	2026-07-20 05:56:06.688354+00	todo	\N	72	27.60	2026-06-16
d36d9bdb-efba-436c-9ad9-e7c217d45a60	\N	\N	28392456-2fc2-4f59-a145-fff7d356370c	28392456-2fc2-4f59-a145-fff7d356370c	تهیهٔ گزارش غیبت و تأخیر #98	\N	medium	2026-08-08	69dcc6b6-190f-4d5b-adf2-beb4404d6091	2026-07-20 05:56:06.688354+00	2026-07-20 05:56:06.688354+00	todo	\N	65	14.50	2026-07-25
d36d9bdb-efba-436c-9ad9-e7c217d45a60	\N	\N	e6d6e516-bc90-467f-a35a-3c169219865e	e6d6e516-bc90-467f-a35a-3c169219865e	پیگیری درخواست‌های رفاهی کارکنان #99	\N	low	2026-07-11	e0d6f9b1-d77f-4379-a2e4-65b0c6e588a3	2026-07-20 05:56:06.688354+00	2026-07-20 05:56:06.688354+00	completed	approved	100	2.30	2026-06-24
d36d9bdb-efba-436c-9ad9-e7c217d45a60	\N	\N	e6d6e516-bc90-467f-a35a-3c169219865e	e6d6e516-bc90-467f-a35a-3c169219865e	پیگیری درخواست‌های رفاهی کارکنان #100	\N	medium	2026-07-24	d92eb0d6-3d0a-46f9-9982-0b77064876fb	2026-07-20 05:56:06.688354+00	2026-07-20 05:56:06.688354+00	in_progress	\N	74	29.50	2026-07-14
d36d9bdb-efba-436c-9ad9-e7c217d45a60	\N	\N	86adf704-3f12-404e-a458-aa2e0259864a	86adf704-3f12-404e-a458-aa2e0259864a	به‌روزرسانی پروندهٔ پرسنلی #101	\N	low	2026-08-09	46634bb5-0468-48b9-966f-4df02fc4cf84	2026-07-20 05:56:06.688354+00	2026-07-20 05:56:06.688354+00	in_progress	\N	7	27.40	2026-07-27
d36d9bdb-efba-436c-9ad9-e7c217d45a60	\N	\N	e6d6e516-bc90-467f-a35a-3c169219865e	e6d6e516-bc90-467f-a35a-3c169219865e	پیگیری مرخصی و مأموریت کارکنان #102	\N	high	2026-07-10	62d71796-786e-4960-a197-d438b530fe97	2026-07-20 05:56:06.688354+00	2026-07-20 05:56:06.688354+00	in_progress	\N	39	28.20	2026-06-26
d36d9bdb-efba-436c-9ad9-e7c217d45a60	\N	\N	7be892eb-4087-4511-8e0a-5bac8a046af2	7be892eb-4087-4511-8e0a-5bac8a046af2	برگزاری جلسهٔ آموزش کارکنان جدید #103	\N	low	2026-07-30	529e3ce5-50ab-46bf-b9dc-4fb2f270f1da	2026-07-20 05:56:06.688354+00	2026-07-20 05:56:06.688354+00	in_progress	\N	17	20.20	2026-07-09
d36d9bdb-efba-436c-9ad9-e7c217d45a60	\N	\N	e6d6e516-bc90-467f-a35a-3c169219865e	e6d6e516-bc90-467f-a35a-3c169219865e	تهیهٔ فرم ارزیابی سه‌ماهه #104	\N	high	2026-08-06	c16941ea-e98b-4be7-aa96-7896222bd3f4	2026-07-20 05:56:06.688354+00	2026-07-20 05:56:06.688354+00	archived	\N	70	36.70	2026-07-24
d36d9bdb-efba-436c-9ad9-e7c217d45a60	\N	\N	3e9d418d-c94e-4859-8756-2203f7d7c329	3e9d418d-c94e-4859-8756-2203f7d7c329	برگزاری نظرسنجی رضایت شغلی #105	\N	low	2026-08-15	4a8a7a0b-4395-430d-b3bf-ebe61b4a8af8	2026-07-20 05:56:06.688354+00	2026-07-20 05:56:06.688354+00	completed	pending	100	27.90	2026-08-07
\.


--
-- Data for Name: users; Type: TABLE DATA; Schema: public; Owner: -
--

COPY public.users (organization_id, email, hashed_password, full_name, role, is_active, id, created_at, updated_at, phone_number, department_id) FROM stdin;
d36d9bdb-efba-436c-9ad9-e7c217d45a60	admin@test.local	$2b$12$HVPaKFtDZchXX/9hqtMM.utUWI4PF5XYOQagRa5433KPiXtfo9il2	مدیر سازمان	org_admin	t	e68f76ed-4722-4f18-86a3-19ae2667e80e	2026-07-20 05:56:06.688354+00	2026-07-20 05:56:06.688354+00	09100000001	04f9e67c-d38e-4088-930a-5507f8cce896
d36d9bdb-efba-436c-9ad9-e7c217d45a60	eng.manager@test.local	$2b$12$yVLDwpDNEl0H3TegcBJ3huBYaG4Ss.FEMKy17TzpxKihDkLUshyQa	مدیر پروژه مهندسی و فنی	project_manager	t	64378bf8-6f34-4dc5-81da-b1fb196a7c3e	2026-07-20 05:56:06.688354+00	2026-07-20 05:56:06.688354+00	09111000000	04f9e67c-d38e-4088-930a-5507f8cce896
d36d9bdb-efba-436c-9ad9-e7c217d45a60	eng.emp1@test.local	$2b$12$/ptulJvI638Py1wpT7jm1OWDpkv/kGc63jctNOWEwUUwgtssU9zF.	کارمند 1 مهندسی و فنی	employee	t	5ab53cd1-327d-42d7-9816-c02eb65d5cb3	2026-07-20 05:56:06.688354+00	2026-07-20 05:56:06.688354+00	09111000011	04f9e67c-d38e-4088-930a-5507f8cce896
d36d9bdb-efba-436c-9ad9-e7c217d45a60	eng.emp2@test.local	$2b$12$hucVKEZEKsVztLLz76qcgeEvyxKNgF..TtumfFNAzQpnDjtmWYnfa	کارمند 2 مهندسی و فنی	employee	t	e63e7670-494e-4f3e-ba10-facf27823c40	2026-07-20 05:56:06.688354+00	2026-07-20 05:56:06.688354+00	09111000012	04f9e67c-d38e-4088-930a-5507f8cce896
d36d9bdb-efba-436c-9ad9-e7c217d45a60	eng.emp3@test.local	$2b$12$4m19lh8FAMENYSHqC4yzJetdkszPnIDRtrmII45Cl8ASoe8HaslPG	کارمند 3 مهندسی و فنی	employee	t	91b406bb-3239-4e75-bc39-05289ba5787a	2026-07-20 05:56:06.688354+00	2026-07-20 05:56:06.688354+00	09111000013	04f9e67c-d38e-4088-930a-5507f8cce896
d36d9bdb-efba-436c-9ad9-e7c217d45a60	eng.emp4@test.local	$2b$12$UImuDKfncPYouf4ObOMD9OTKJhJm7nt.rX2nNyR4qxF6U1u6djDQK	کارمند 4 مهندسی و فنی	employee	t	af4e23f3-f961-4eaa-9e20-dbae4f1bbe85	2026-07-20 05:56:06.688354+00	2026-07-20 05:56:06.688354+00	09111000014	04f9e67c-d38e-4088-930a-5507f8cce896
d36d9bdb-efba-436c-9ad9-e7c217d45a60	eng.emp5@test.local	$2b$12$7SAR7Wm18VQAfFsqhM8VpOuQZRRK82jBQG2iBTUpKKlSt/rRxBCKq	کارمند 5 مهندسی و فنی	employee	t	0ca1e1af-afc9-498c-bb79-6bb3bc65d3fb	2026-07-20 05:56:06.688354+00	2026-07-20 05:56:06.688354+00	09111000015	04f9e67c-d38e-4088-930a-5507f8cce896
d36d9bdb-efba-436c-9ad9-e7c217d45a60	eng.emp6@test.local	$2b$12$MMVhhgO61fwL1GysvGD5Ye07TldywWDDZJss.tgd351F79PQg8ce2	کارمند 6 مهندسی و فنی	employee	t	7dd528cd-1bd4-4597-8589-c145df25c0fb	2026-07-20 05:56:06.688354+00	2026-07-20 05:56:06.688354+00	09111000016	04f9e67c-d38e-4088-930a-5507f8cce896
d36d9bdb-efba-436c-9ad9-e7c217d45a60	fin.manager@test.local	$2b$12$Z76fc95g1WefTjYWXdgPLe44HZVOw28ta0/AXKbhTi86fUnGU6WrC	مدیر پروژه حسابداری و مالی	project_manager	t	0e06be7f-9df4-4e66-a58e-9eba6f026584	2026-07-20 05:56:06.688354+00	2026-07-20 05:56:06.688354+00	09121000100	7772c657-8cbb-47d4-a5cd-59293e48f79f
d36d9bdb-efba-436c-9ad9-e7c217d45a60	fin.emp1@test.local	$2b$12$87ZFitK5KPQx22/6oSRA0eep2ZqzMb/.1.NHrmt4pUmpCPjWTs09O	کارمند 1 حسابداری و مالی	employee	t	455d9757-37bc-4fe6-8025-e1efb66d8672	2026-07-20 05:56:06.688354+00	2026-07-20 05:56:06.688354+00	09121000111	7772c657-8cbb-47d4-a5cd-59293e48f79f
d36d9bdb-efba-436c-9ad9-e7c217d45a60	fin.emp2@test.local	$2b$12$xMKymol1qdBVS7wYVXxFd.b/jCvC6X437aDFHw.AGIaDg8AOfOrca	کارمند 2 حسابداری و مالی	employee	t	f892958c-2fb8-40b3-ba0e-5c62223aef14	2026-07-20 05:56:06.688354+00	2026-07-20 05:56:06.688354+00	09121000112	7772c657-8cbb-47d4-a5cd-59293e48f79f
d36d9bdb-efba-436c-9ad9-e7c217d45a60	fin.emp3@test.local	$2b$12$h/Hj6an8ia8lc8e0zq6uPuhLBpEd6vjev7zSvpJTcKoh7mm6zlgDu	کارمند 3 حسابداری و مالی	employee	t	fbfe2b53-dcf1-4ee4-acf0-7c1a3cace4db	2026-07-20 05:56:06.688354+00	2026-07-20 05:56:06.688354+00	09121000113	7772c657-8cbb-47d4-a5cd-59293e48f79f
d36d9bdb-efba-436c-9ad9-e7c217d45a60	fin.emp4@test.local	$2b$12$YQ/ST8q8SuDNuM1c4RNdReGEai1m6lseS9/YEpUslPTuX/r7aNiti	کارمند 4 حسابداری و مالی	employee	t	30621a70-ecd1-4c9b-a6c0-5b071dab4d1c	2026-07-20 05:56:06.688354+00	2026-07-20 05:56:06.688354+00	09121000114	7772c657-8cbb-47d4-a5cd-59293e48f79f
d36d9bdb-efba-436c-9ad9-e7c217d45a60	fin.emp5@test.local	$2b$12$N/9c1EyOkt4Wz7PfytS2Le2ij3sgThD3UlBdfA6cGNanduHCJQQ.i	کارمند 5 حسابداری و مالی	employee	t	77fe864d-692a-4798-9e36-b464ad1c9e1c	2026-07-20 05:56:06.688354+00	2026-07-20 05:56:06.688354+00	09121000115	7772c657-8cbb-47d4-a5cd-59293e48f79f
d36d9bdb-efba-436c-9ad9-e7c217d45a60	fin.emp6@test.local	$2b$12$KVsWw4xNBfL.ni4aB3QRD.u2TXQZagFToaNlvHbIRpL4oHkCmLXzS	کارمند 6 حسابداری و مالی	employee	t	7653733b-3526-47fd-8fa2-b6c120729ad7	2026-07-20 05:56:06.688354+00	2026-07-20 05:56:06.688354+00	09121000116	7772c657-8cbb-47d4-a5cd-59293e48f79f
d36d9bdb-efba-436c-9ad9-e7c217d45a60	hr.manager@test.local	$2b$12$dKpicbWGLycg6tqk24qj1uAgwv3997A/5R0kl66u32LpCj7sw/Ybu	مدیر پروژه منابع انسانی	project_manager	t	86adf704-3f12-404e-a458-aa2e0259864a	2026-07-20 05:56:06.688354+00	2026-07-20 05:56:06.688354+00	09131000200	34acf832-d975-4448-818c-dc2106e9da5f
d36d9bdb-efba-436c-9ad9-e7c217d45a60	hr.emp1@test.local	$2b$12$/lyRop0W20l2TNn9.SR7dOqwuSD1rGC1Ui2MBecvcneNhMWJUQdfO	کارمند 1 منابع انسانی	employee	t	28392456-2fc2-4f59-a145-fff7d356370c	2026-07-20 05:56:06.688354+00	2026-07-20 05:56:06.688354+00	09131000211	34acf832-d975-4448-818c-dc2106e9da5f
d36d9bdb-efba-436c-9ad9-e7c217d45a60	hr.emp2@test.local	$2b$12$K4NHBxv0sMd7P/dkaT4Q5u7dzz0fTVk9UV6uuo1oOiOok2N76dEA6	کارمند 2 منابع انسانی	employee	t	5f17f47c-48cd-4442-9a0b-48558bc649ce	2026-07-20 05:56:06.688354+00	2026-07-20 05:56:06.688354+00	09131000212	34acf832-d975-4448-818c-dc2106e9da5f
d36d9bdb-efba-436c-9ad9-e7c217d45a60	hr.emp3@test.local	$2b$12$Ny.V32fZTUlOSVOThyp17eFBO/kHCRA7HPiolFpVptCuvFSlhTQW6	کارمند 3 منابع انسانی	employee	t	e6d6e516-bc90-467f-a35a-3c169219865e	2026-07-20 05:56:06.688354+00	2026-07-20 05:56:06.688354+00	09131000213	34acf832-d975-4448-818c-dc2106e9da5f
d36d9bdb-efba-436c-9ad9-e7c217d45a60	hr.emp4@test.local	$2b$12$bzdCnNH8QQQxxektjyJA0.SqFcWNZhpKQRu7svYLzTA.eQ66ImqZK	کارمند 4 منابع انسانی	employee	t	5f98deeb-64ad-4c21-a955-cc484130bfa2	2026-07-20 05:56:06.688354+00	2026-07-20 05:56:06.688354+00	09131000214	34acf832-d975-4448-818c-dc2106e9da5f
d36d9bdb-efba-436c-9ad9-e7c217d45a60	hr.emp5@test.local	$2b$12$7WoRxxhO5/kkCk5c4C8LferiZoktYHMQZqBLo3xwGPKe96mubb7B2	کارمند 5 منابع انسانی	employee	t	7be892eb-4087-4511-8e0a-5bac8a046af2	2026-07-20 05:56:06.688354+00	2026-07-20 05:56:06.688354+00	09131000215	34acf832-d975-4448-818c-dc2106e9da5f
d36d9bdb-efba-436c-9ad9-e7c217d45a60	hr.emp6@test.local	$2b$12$N6PFjUgAhq.6GKAAIRRh1OtPngGp70k.v9zj4UNpVJ4WsdmzSSPXG	کارمند 6 منابع انسانی	employee	t	3e9d418d-c94e-4859-8756-2203f7d7c329	2026-07-20 05:56:06.688354+00	2026-07-20 05:56:06.688354+00	09131000216	34acf832-d975-4448-818c-dc2106e9da5f
\.


--
-- Data for Name: worklogs; Type: TABLE DATA; Schema: public; Owner: -
--

COPY public.worklogs (organization_id, task_id, user_id, activity_description, time_spent_minutes, progress_percent, log_date, status, reviewed_by_id, review_comment, id, created_at, updated_at) FROM stdin;
\.


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
-- Name: ix_departments_organization_id; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX ix_departments_organization_id ON public.departments USING btree (organization_id);


--
-- Name: ix_export_jobs_organization_id; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX ix_export_jobs_organization_id ON public.export_jobs USING btree (organization_id);


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
-- Name: ix_users_email; Type: INDEX; Schema: public; Owner: -
--

CREATE UNIQUE INDEX ix_users_email ON public.users USING btree (email);


--
-- Name: ix_users_organization_id; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX ix_users_organization_id ON public.users USING btree (organization_id);


--
-- Name: ix_users_phone_number; Type: INDEX; Schema: public; Owner: -
--

CREATE UNIQUE INDEX ix_users_phone_number ON public.users USING btree (phone_number);


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


