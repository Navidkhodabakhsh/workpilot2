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
6b99afe0a3a4
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
c7d6d007-2a6a-4fe1-9e1d-3e3ccdb6cc9c	2026-07-20 11:11:03.957452+00	2026-07-20 11:11:03.957452+00	4dcc3819-424c-4d09-9482-91ed2d9d19ab	58d048c0-3e97-449e-bb15-1a8b9a558017	a7b0ee8a-3b5c-4d31-9ca7-20bc15933213	\N	جلسهٔ مرور با مدیریت	\N	meeting	2026-06-19 10:00:00+00	2026-06-19 11:00:00+00	f
40a25335-93ae-4a24-944c-b296c5def42e	2026-07-20 11:11:03.957452+00	2026-07-20 11:11:03.957452+00	4dcc3819-424c-4d09-9482-91ed2d9d19ab	8e57ec64-12f7-4c1b-809e-977233cf374f	214b156f-50e6-48ca-9d63-554205decf98	\N	یادآوری پیگیری مشتری	\N	reminder	2026-06-16 00:00:00+00	2026-06-16 01:00:00+00	t
fd991361-d685-4b2b-907b-6b71d2d6fe55	2026-07-20 11:11:03.957452+00	2026-07-20 11:11:03.957452+00	4dcc3819-424c-4d09-9482-91ed2d9d19ab	58d048c0-3e97-449e-bb15-1a8b9a558017	4d9d9007-cc28-40b2-824e-fb736a37db5d	\N	جلسهٔ بررسی پیشرفت پروژه	\N	meeting	2026-06-23 10:00:00+00	2026-06-23 11:00:00+00	f
a6813bc1-5e69-47a6-8026-609c6d97605e	2026-07-20 11:11:03.957452+00	2026-07-20 11:11:03.957452+00	4dcc3819-424c-4d09-9482-91ed2d9d19ab	f389ffea-b5f1-4132-9c04-337ebb4ab8fd	f8562903-2445-41dd-8533-332858c954d2	\N	یادآوری تمدید قرارداد	\N	reminder	2026-06-28 00:00:00+00	2026-06-28 01:00:00+00	t
5898bc30-d528-43d7-95e1-b4a61ed45389	2026-07-20 11:11:03.957452+00	2026-07-20 11:11:03.957452+00	4dcc3819-424c-4d09-9482-91ed2d9d19ab	58d048c0-3e97-449e-bb15-1a8b9a558017	af7dff5d-2ae0-42f4-8cf7-3b62e42f61b7	\N	جلسهٔ برنامه‌ریزی اسپرینت	\N	meeting	2026-07-04 10:00:00+00	2026-07-04 11:00:00+00	f
95a0b28f-e77f-4827-994a-980673a5f5bb	2026-07-20 11:11:03.957452+00	2026-07-20 11:11:03.957452+00	4dcc3819-424c-4d09-9482-91ed2d9d19ab	9e42561d-3de1-44eb-b7ec-5207ea857b8e	214b156f-50e6-48ca-9d63-554205decf98	\N	یادآوری ارسال گزارش	\N	reminder	2026-07-01 00:00:00+00	2026-07-01 01:00:00+00	t
5283d36d-3272-4017-aabc-f362200829d0	2026-07-20 11:11:03.957452+00	2026-07-20 11:11:03.957452+00	4dcc3819-424c-4d09-9482-91ed2d9d19ab	58d048c0-3e97-449e-bb15-1a8b9a558017	af7dff5d-2ae0-42f4-8cf7-3b62e42f61b7	\N	جلسهٔ برنامه‌ریزی اسپرینت	\N	meeting	2026-07-11 10:00:00+00	2026-07-11 11:00:00+00	f
a8d892fe-332e-4401-8791-38bb5eaea6b1	2026-07-20 11:11:03.957452+00	2026-07-20 11:11:03.957452+00	4dcc3819-424c-4d09-9482-91ed2d9d19ab	9e42561d-3de1-44eb-b7ec-5207ea857b8e	4d9d9007-cc28-40b2-824e-fb736a37db5d	\N	یادآوری پیگیری مشتری	\N	reminder	2026-07-07 00:00:00+00	2026-07-07 01:00:00+00	t
1bc19d96-121a-49d5-814d-688fa1bcd637	2026-07-20 11:11:03.957452+00	2026-07-20 11:11:03.957452+00	4dcc3819-424c-4d09-9482-91ed2d9d19ab	58d048c0-3e97-449e-bb15-1a8b9a558017	4d9d9007-cc28-40b2-824e-fb736a37db5d	\N	جلسهٔ هماهنگی هفتگی	\N	meeting	2026-07-18 10:00:00+00	2026-07-18 11:00:00+00	f
8ea5c0f8-fae3-4261-9e40-cb13dbb8dbaf	2026-07-20 11:11:03.957452+00	2026-07-20 11:11:03.957452+00	4dcc3819-424c-4d09-9482-91ed2d9d19ab	4116e390-3789-4721-9e7b-133ebb2764c7	af7dff5d-2ae0-42f4-8cf7-3b62e42f61b7	\N	یادآوری پیگیری مشتری	\N	reminder	2026-07-17 00:00:00+00	2026-07-17 01:00:00+00	t
f10cbaa1-3dbd-4b8e-913f-5ac169ed54ca	2026-07-20 11:11:03.957452+00	2026-07-20 11:11:03.957452+00	4dcc3819-424c-4d09-9482-91ed2d9d19ab	58d048c0-3e97-449e-bb15-1a8b9a558017	214b156f-50e6-48ca-9d63-554205decf98	\N	جلسهٔ برنامه‌ریزی اسپرینت	\N	meeting	2026-07-23 10:00:00+00	2026-07-23 11:00:00+00	f
a46a3f1e-d61b-40ee-9556-1870e2e6ca06	2026-07-20 11:11:03.957452+00	2026-07-20 11:11:03.957452+00	4dcc3819-424c-4d09-9482-91ed2d9d19ab	8e57ec64-12f7-4c1b-809e-977233cf374f	f8562903-2445-41dd-8533-332858c954d2	\N	یادآوری ارسال گزارش	\N	reminder	2026-07-26 00:00:00+00	2026-07-26 01:00:00+00	t
fbca0bfc-ac52-47b9-b2a7-a5bc0d58777d	2026-07-20 11:11:03.957452+00	2026-07-20 11:11:03.957452+00	4dcc3819-424c-4d09-9482-91ed2d9d19ab	58d048c0-3e97-449e-bb15-1a8b9a558017	f8562903-2445-41dd-8533-332858c954d2	\N	جلسهٔ هماهنگی هفتگی	\N	meeting	2026-07-29 10:00:00+00	2026-07-29 11:00:00+00	f
286b7239-13e9-4047-9ae0-76d7f0b31332	2026-07-20 11:11:03.957452+00	2026-07-20 11:11:03.957452+00	4dcc3819-424c-4d09-9482-91ed2d9d19ab	9e42561d-3de1-44eb-b7ec-5207ea857b8e	f8562903-2445-41dd-8533-332858c954d2	\N	یادآوری ارسال گزارش	\N	reminder	2026-08-03 00:00:00+00	2026-08-03 01:00:00+00	t
808f3ebf-3751-4ece-af40-469b3327bd14	2026-07-20 11:11:03.957452+00	2026-07-20 11:11:03.957452+00	4dcc3819-424c-4d09-9482-91ed2d9d19ab	58d048c0-3e97-449e-bb15-1a8b9a558017	af7dff5d-2ae0-42f4-8cf7-3b62e42f61b7	\N	جلسهٔ برنامه‌ریزی اسپرینت	\N	meeting	2026-08-06 10:00:00+00	2026-08-06 11:00:00+00	f
bd64114f-f82a-479d-96c7-29a39e4e3e02	2026-07-20 11:11:03.957452+00	2026-07-20 11:11:03.957452+00	4dcc3819-424c-4d09-9482-91ed2d9d19ab	4e1eb7bb-aea1-4b26-aa51-fef3ea6cbab8	a7b0ee8a-3b5c-4d31-9ca7-20bc15933213	\N	یادآوری پیگیری مشتری	\N	reminder	2026-08-10 00:00:00+00	2026-08-10 01:00:00+00	t
83cf78d7-8c59-4721-a9ef-033fe1f93236	2026-07-20 11:11:03.957452+00	2026-07-20 11:11:03.957452+00	4dcc3819-424c-4d09-9482-91ed2d9d19ab	58d048c0-3e97-449e-bb15-1a8b9a558017	214b156f-50e6-48ca-9d63-554205decf98	\N	جلسهٔ بررسی پیشرفت پروژه	\N	meeting	2026-08-14 10:00:00+00	2026-08-14 11:00:00+00	f
1e59236f-ead1-4697-b099-03a9943ae2ed	2026-07-20 11:11:03.957452+00	2026-07-20 11:11:03.957452+00	4dcc3819-424c-4d09-9482-91ed2d9d19ab	f389ffea-b5f1-4132-9c04-337ebb4ab8fd	af7dff5d-2ae0-42f4-8cf7-3b62e42f61b7	\N	یادآوری پیگیری مشتری	\N	reminder	2026-08-17 00:00:00+00	2026-08-17 01:00:00+00	t
8915497d-e803-4522-b08a-840acfc6ecf4	2026-07-20 11:11:03.957452+00	2026-07-20 11:11:03.957452+00	4dcc3819-424c-4d09-9482-91ed2d9d19ab	5e03da3d-4fd1-4305-91ec-8a61bd1f28ee	b960ff6a-9895-4681-8b20-e5984d2fa534	\N	جلسهٔ هماهنگی هفتگی	\N	meeting	2026-06-16 10:00:00+00	2026-06-16 11:00:00+00	f
b2aca5f2-024f-4cbf-b20a-228bb477cb31	2026-07-20 11:11:03.957452+00	2026-07-20 11:11:03.957452+00	4dcc3819-424c-4d09-9482-91ed2d9d19ab	5742bab4-624b-41df-aff7-c3517eed7f4c	b960ff6a-9895-4681-8b20-e5984d2fa534	\N	یادآوری ارسال گزارش	\N	reminder	2026-06-16 00:00:00+00	2026-06-16 01:00:00+00	t
ddded516-266b-4562-a7a3-93e4f07ea1b8	2026-07-20 11:11:03.957452+00	2026-07-20 11:11:03.957452+00	4dcc3819-424c-4d09-9482-91ed2d9d19ab	5e03da3d-4fd1-4305-91ec-8a61bd1f28ee	c7e23915-2f99-4ff8-9ca8-cda5dcdba7c9	\N	جلسهٔ هماهنگی هفتگی	\N	meeting	2026-06-25 10:00:00+00	2026-06-25 11:00:00+00	f
8b75d1ad-4c71-4997-990e-fbaa826ccead	2026-07-20 11:11:03.957452+00	2026-07-20 11:11:03.957452+00	4dcc3819-424c-4d09-9482-91ed2d9d19ab	8e78a4d9-50d5-40e6-bcd8-fd3f57c31286	a09ff0f0-43e2-48d8-8bf6-67e0e31e0def	\N	یادآوری ارسال گزارش	\N	reminder	2026-06-27 00:00:00+00	2026-06-27 01:00:00+00	t
6cf9c997-d789-410a-8041-e33e79c0408d	2026-07-20 11:11:03.957452+00	2026-07-20 11:11:03.957452+00	4dcc3819-424c-4d09-9482-91ed2d9d19ab	5e03da3d-4fd1-4305-91ec-8a61bd1f28ee	47a3c135-ac0c-4015-a4f1-c962c169c55b	\N	جلسهٔ بررسی پیشرفت پروژه	\N	meeting	2026-06-30 10:00:00+00	2026-06-30 11:00:00+00	f
11ba96ed-55c3-4641-8e08-33c1c78292cd	2026-07-20 11:11:03.957452+00	2026-07-20 11:11:03.957452+00	4dcc3819-424c-4d09-9482-91ed2d9d19ab	7a6ee833-86b5-4c74-a2b1-845608f4fbab	b960ff6a-9895-4681-8b20-e5984d2fa534	\N	یادآوری ارسال گزارش	\N	reminder	2026-07-05 00:00:00+00	2026-07-05 01:00:00+00	t
4e10fd68-68e0-4d0c-8970-5a64a47e1b41	2026-07-20 11:11:03.957452+00	2026-07-20 11:11:03.957452+00	4dcc3819-424c-4d09-9482-91ed2d9d19ab	5e03da3d-4fd1-4305-91ec-8a61bd1f28ee	a09ff0f0-43e2-48d8-8bf6-67e0e31e0def	\N	جلسهٔ هماهنگی هفتگی	\N	meeting	2026-07-07 10:00:00+00	2026-07-07 11:00:00+00	f
2bc4d465-3a44-43f6-b528-a38abdcf59b5	2026-07-20 11:11:03.957452+00	2026-07-20 11:11:03.957452+00	4dcc3819-424c-4d09-9482-91ed2d9d19ab	24baa76f-b9d0-4a8f-b28d-605d780d066a	b960ff6a-9895-4681-8b20-e5984d2fa534	\N	یادآوری پیگیری مشتری	\N	reminder	2026-07-10 00:00:00+00	2026-07-10 01:00:00+00	t
002569a0-7880-4e38-8fdd-1497c9d7acf8	2026-07-20 11:11:03.957452+00	2026-07-20 11:11:03.957452+00	4dcc3819-424c-4d09-9482-91ed2d9d19ab	5e03da3d-4fd1-4305-91ec-8a61bd1f28ee	c7e23915-2f99-4ff8-9ca8-cda5dcdba7c9	\N	جلسهٔ مرور با مدیریت	\N	meeting	2026-07-17 10:00:00+00	2026-07-17 11:00:00+00	f
1d65339c-d53a-42e5-982a-a64f1d8f89df	2026-07-20 11:11:03.957452+00	2026-07-20 11:11:03.957452+00	4dcc3819-424c-4d09-9482-91ed2d9d19ab	7a6ee833-86b5-4c74-a2b1-845608f4fbab	c7e23915-2f99-4ff8-9ca8-cda5dcdba7c9	\N	یادآوری ارسال گزارش	\N	reminder	2026-07-14 00:00:00+00	2026-07-14 01:00:00+00	t
433b3ac8-aa1f-41ea-9c4f-f8e830816bd4	2026-07-20 11:11:03.957452+00	2026-07-20 11:11:03.957452+00	4dcc3819-424c-4d09-9482-91ed2d9d19ab	5e03da3d-4fd1-4305-91ec-8a61bd1f28ee	a09ff0f0-43e2-48d8-8bf6-67e0e31e0def	\N	جلسهٔ بررسی پیشرفت پروژه	\N	meeting	2026-07-22 10:00:00+00	2026-07-22 11:00:00+00	f
b21f43d4-e467-4a21-9427-00179e5a438f	2026-07-20 11:11:03.957452+00	2026-07-20 11:11:03.957452+00	4dcc3819-424c-4d09-9482-91ed2d9d19ab	8d97ee0b-e8f3-4aec-ab48-db76ef6ede39	c7e23915-2f99-4ff8-9ca8-cda5dcdba7c9	\N	یادآوری ارسال گزارش	\N	reminder	2026-07-23 00:00:00+00	2026-07-23 01:00:00+00	t
86e62fb1-f573-469d-b0d2-4d6bb3c20501	2026-07-20 11:11:03.957452+00	2026-07-20 11:11:03.957452+00	4dcc3819-424c-4d09-9482-91ed2d9d19ab	5e03da3d-4fd1-4305-91ec-8a61bd1f28ee	47a3c135-ac0c-4015-a4f1-c962c169c55b	\N	جلسهٔ بررسی پیشرفت پروژه	\N	meeting	2026-08-01 10:00:00+00	2026-08-01 11:00:00+00	f
6a8d9c0a-7336-43e1-9be6-85cbf2bd887f	2026-07-20 11:11:03.957452+00	2026-07-20 11:11:03.957452+00	4dcc3819-424c-4d09-9482-91ed2d9d19ab	8d97ee0b-e8f3-4aec-ab48-db76ef6ede39	c7e23915-2f99-4ff8-9ca8-cda5dcdba7c9	\N	یادآوری تمدید قرارداد	\N	reminder	2026-08-02 00:00:00+00	2026-08-02 01:00:00+00	t
3c1686a3-0562-41e2-89ef-0256737c4d2d	2026-07-20 11:11:03.957452+00	2026-07-20 11:11:03.957452+00	4dcc3819-424c-4d09-9482-91ed2d9d19ab	5e03da3d-4fd1-4305-91ec-8a61bd1f28ee	1fac07d5-b0a4-40b0-8f99-1e6da7ef8ac7	\N	جلسهٔ هماهنگی هفتگی	\N	meeting	2026-08-07 10:00:00+00	2026-08-07 11:00:00+00	f
642a4b71-4946-4040-933e-2990311d8049	2026-07-20 11:11:03.957452+00	2026-07-20 11:11:03.957452+00	4dcc3819-424c-4d09-9482-91ed2d9d19ab	8d97ee0b-e8f3-4aec-ab48-db76ef6ede39	c7e23915-2f99-4ff8-9ca8-cda5dcdba7c9	\N	یادآوری ارسال گزارش	\N	reminder	2026-08-04 00:00:00+00	2026-08-04 01:00:00+00	t
717e0cce-6f60-4c3a-a398-01005c6d782f	2026-07-20 11:11:03.957452+00	2026-07-20 11:11:03.957452+00	4dcc3819-424c-4d09-9482-91ed2d9d19ab	5e03da3d-4fd1-4305-91ec-8a61bd1f28ee	c7e23915-2f99-4ff8-9ca8-cda5dcdba7c9	\N	جلسهٔ بررسی پیشرفت پروژه	\N	meeting	2026-08-12 10:00:00+00	2026-08-12 11:00:00+00	f
fd9bd5f6-0244-4f77-aaa1-68b121d02ebd	2026-07-20 11:11:03.957452+00	2026-07-20 11:11:03.957452+00	4dcc3819-424c-4d09-9482-91ed2d9d19ab	8e78a4d9-50d5-40e6-bcd8-fd3f57c31286	47a3c135-ac0c-4015-a4f1-c962c169c55b	\N	یادآوری تمدید قرارداد	\N	reminder	2026-08-16 00:00:00+00	2026-08-16 01:00:00+00	t
1b3569d4-7597-4aee-b341-06e16804b73d	2026-07-20 11:11:03.957452+00	2026-07-20 11:11:03.957452+00	4dcc3819-424c-4d09-9482-91ed2d9d19ab	ac9072e5-ff0f-4d63-880d-330ba7a1645e	f9fdf4eb-972d-4c59-9e96-24e6388d7053	\N	جلسهٔ بررسی پیشرفت پروژه	\N	meeting	2026-06-20 10:00:00+00	2026-06-20 11:00:00+00	f
ff6ca1e1-167c-4f9a-bf98-bcc72ffe693f	2026-07-20 11:11:03.957452+00	2026-07-20 11:11:03.957452+00	4dcc3819-424c-4d09-9482-91ed2d9d19ab	3a5bbe57-a350-4aac-a8a7-02d037f0c644	c6aa009d-ea9c-495f-a286-0555a1051213	\N	یادآوری تمدید قرارداد	\N	reminder	2026-06-20 00:00:00+00	2026-06-20 01:00:00+00	t
a1017855-a321-475e-91d9-cd3b0c23ea98	2026-07-20 11:11:03.957452+00	2026-07-20 11:11:03.957452+00	4dcc3819-424c-4d09-9482-91ed2d9d19ab	ac9072e5-ff0f-4d63-880d-330ba7a1645e	5d8c9706-dd1f-4e2c-9412-df9ea8285c7a	\N	جلسهٔ بررسی پیشرفت پروژه	\N	meeting	2026-06-23 10:00:00+00	2026-06-23 11:00:00+00	f
31d11c17-28aa-43a3-b610-c76c9b80b6a3	2026-07-20 11:11:03.957452+00	2026-07-20 11:11:03.957452+00	4dcc3819-424c-4d09-9482-91ed2d9d19ab	ea1e6921-d2aa-44c0-978b-ff36b7d9fff2	061a037c-86e9-4699-a76d-8a1b0c7c4bc2	\N	یادآوری تمدید قرارداد	\N	reminder	2026-06-23 00:00:00+00	2026-06-23 01:00:00+00	t
39ee97a1-a03c-41a8-a2ff-1fb86b1cde6b	2026-07-20 11:11:03.957452+00	2026-07-20 11:11:03.957452+00	4dcc3819-424c-4d09-9482-91ed2d9d19ab	ac9072e5-ff0f-4d63-880d-330ba7a1645e	061a037c-86e9-4699-a76d-8a1b0c7c4bc2	\N	جلسهٔ بررسی پیشرفت پروژه	\N	meeting	2026-07-03 10:00:00+00	2026-07-03 11:00:00+00	f
b89f148b-51c2-4b31-8bfc-b3219a1f19b0	2026-07-20 11:11:03.957452+00	2026-07-20 11:11:03.957452+00	4dcc3819-424c-4d09-9482-91ed2d9d19ab	fbd6cd8f-ebe9-40af-a413-fa64b9419d5a	c6aa009d-ea9c-495f-a286-0555a1051213	\N	یادآوری ارسال گزارش	\N	reminder	2026-07-04 00:00:00+00	2026-07-04 01:00:00+00	t
fbf0852e-25e3-4ed3-b4f1-9150024ff605	2026-07-20 11:11:03.957452+00	2026-07-20 11:11:03.957452+00	4dcc3819-424c-4d09-9482-91ed2d9d19ab	ac9072e5-ff0f-4d63-880d-330ba7a1645e	f9fdf4eb-972d-4c59-9e96-24e6388d7053	\N	جلسهٔ برنامه‌ریزی اسپرینت	\N	meeting	2026-07-09 10:00:00+00	2026-07-09 11:00:00+00	f
785562be-c5d2-442c-a228-63c0d7bd8bf0	2026-07-20 11:11:03.957452+00	2026-07-20 11:11:03.957452+00	4dcc3819-424c-4d09-9482-91ed2d9d19ab	ea1e6921-d2aa-44c0-978b-ff36b7d9fff2	5d8c9706-dd1f-4e2c-9412-df9ea8285c7a	\N	یادآوری پیگیری مشتری	\N	reminder	2026-07-09 00:00:00+00	2026-07-09 01:00:00+00	t
c994575c-0459-41d8-b779-740702764ca6	2026-07-20 11:11:03.957452+00	2026-07-20 11:11:03.957452+00	4dcc3819-424c-4d09-9482-91ed2d9d19ab	ac9072e5-ff0f-4d63-880d-330ba7a1645e	5d8c9706-dd1f-4e2c-9412-df9ea8285c7a	\N	جلسهٔ مرور با مدیریت	\N	meeting	2026-07-17 10:00:00+00	2026-07-17 11:00:00+00	f
a2e985ab-6d7f-4e1b-a040-4f6cc27aa2c4	2026-07-20 11:11:03.957452+00	2026-07-20 11:11:03.957452+00	4dcc3819-424c-4d09-9482-91ed2d9d19ab	fbd6cd8f-ebe9-40af-a413-fa64b9419d5a	bad8216b-b2f3-4ddb-acca-b5ab203499fc	\N	یادآوری ارسال گزارش	\N	reminder	2026-07-18 00:00:00+00	2026-07-18 01:00:00+00	t
03dd9229-f24f-489a-89f1-60e6f2b6b410	2026-07-20 11:11:03.957452+00	2026-07-20 11:11:03.957452+00	4dcc3819-424c-4d09-9482-91ed2d9d19ab	ac9072e5-ff0f-4d63-880d-330ba7a1645e	061a037c-86e9-4699-a76d-8a1b0c7c4bc2	\N	جلسهٔ هماهنگی هفتگی	\N	meeting	2026-07-25 10:00:00+00	2026-07-25 11:00:00+00	f
69fc6823-82a2-493b-b66b-e75c01fd8536	2026-07-20 11:11:03.957452+00	2026-07-20 11:11:03.957452+00	4dcc3819-424c-4d09-9482-91ed2d9d19ab	fbd6cd8f-ebe9-40af-a413-fa64b9419d5a	f9fdf4eb-972d-4c59-9e96-24e6388d7053	\N	یادآوری تمدید قرارداد	\N	reminder	2026-07-25 00:00:00+00	2026-07-25 01:00:00+00	t
f241ae5a-aa72-49d2-bbb5-f61bc700da11	2026-07-20 11:11:03.957452+00	2026-07-20 11:11:03.957452+00	4dcc3819-424c-4d09-9482-91ed2d9d19ab	ac9072e5-ff0f-4d63-880d-330ba7a1645e	bad8216b-b2f3-4ddb-acca-b5ab203499fc	\N	جلسهٔ برنامه‌ریزی اسپرینت	\N	meeting	2026-07-28 10:00:00+00	2026-07-28 11:00:00+00	f
dc932a7b-7424-46b4-9d9c-8cf857a5cd00	2026-07-20 11:11:03.957452+00	2026-07-20 11:11:03.957452+00	4dcc3819-424c-4d09-9482-91ed2d9d19ab	0631f64d-7a8f-4a1f-b13c-6e22248209c5	bad8216b-b2f3-4ddb-acca-b5ab203499fc	\N	یادآوری پیگیری مشتری	\N	reminder	2026-08-01 00:00:00+00	2026-08-01 01:00:00+00	t
2c4e03e5-593a-4c57-9bc2-2aa64541f9b8	2026-07-20 11:11:03.957452+00	2026-07-20 11:11:03.957452+00	4dcc3819-424c-4d09-9482-91ed2d9d19ab	ac9072e5-ff0f-4d63-880d-330ba7a1645e	061a037c-86e9-4699-a76d-8a1b0c7c4bc2	\N	جلسهٔ مرور با مدیریت	\N	meeting	2026-08-07 10:00:00+00	2026-08-07 11:00:00+00	f
937ce57f-64fd-4b62-9ced-cff772631da8	2026-07-20 11:11:03.957452+00	2026-07-20 11:11:03.957452+00	4dcc3819-424c-4d09-9482-91ed2d9d19ab	3a5bbe57-a350-4aac-a8a7-02d037f0c644	bad8216b-b2f3-4ddb-acca-b5ab203499fc	\N	یادآوری تمدید قرارداد	\N	reminder	2026-08-10 00:00:00+00	2026-08-10 01:00:00+00	t
d7d127f1-eb63-431c-91db-86d2c5460ffd	2026-07-20 11:11:03.957452+00	2026-07-20 11:11:03.957452+00	4dcc3819-424c-4d09-9482-91ed2d9d19ab	ac9072e5-ff0f-4d63-880d-330ba7a1645e	061a037c-86e9-4699-a76d-8a1b0c7c4bc2	\N	جلسهٔ هماهنگی هفتگی	\N	meeting	2026-08-15 10:00:00+00	2026-08-15 11:00:00+00	f
9c8e7ea9-ba3a-4d95-892b-e8129bd32678	2026-07-20 11:11:03.957452+00	2026-07-20 11:11:03.957452+00	4dcc3819-424c-4d09-9482-91ed2d9d19ab	fbd6cd8f-ebe9-40af-a413-fa64b9419d5a	bad8216b-b2f3-4ddb-acca-b5ab203499fc	\N	یادآوری ارسال گزارش	\N	reminder	2026-08-14 00:00:00+00	2026-08-14 01:00:00+00	t
0998a895-09dc-4654-aa3f-ec00cb7a5665	2026-07-20 11:11:03.957452+00	2026-07-20 11:11:03.957452+00	4dcc3819-424c-4d09-9482-91ed2d9d19ab	40816eb2-f7d3-4e42-8512-c8262568d134	\N	\N	تعطیلی رسمی	\N	holiday	2026-06-18 00:00:00+00	2026-06-18 01:00:00+00	t
cf670dcc-8a74-4ea3-ac01-543b74951247	2026-07-20 11:11:03.957452+00	2026-07-20 11:11:03.957452+00	4dcc3819-424c-4d09-9482-91ed2d9d19ab	40816eb2-f7d3-4e42-8512-c8262568d134	\N	\N	تعطیلی رسمی	\N	holiday	2026-07-16 00:00:00+00	2026-07-16 01:00:00+00	t
596cec28-0872-43fe-add3-edbcc8cfa16b	2026-07-20 11:11:03.957452+00	2026-07-20 11:11:03.957452+00	4dcc3819-424c-4d09-9482-91ed2d9d19ab	40816eb2-f7d3-4e42-8512-c8262568d134	\N	\N	تعطیلی رسمی	\N	holiday	2026-08-13 00:00:00+00	2026-08-13 01:00:00+00	t
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
ae0fdec6-11fb-43da-8ecb-420223b3caad	2026-07-20 11:11:03.957452+00	2026-07-20 11:11:03.957452+00	4dcc3819-424c-4d09-9482-91ed2d9d19ab	58d048c0-3e97-449e-bb15-1a8b9a558017	4cb2d1d1-fa04-4416-b8c8-6716f76f5dea	project_manager
709871ee-ceca-4b81-a0a6-e958b79370bc	2026-07-20 11:11:03.957452+00	2026-07-20 11:11:03.957452+00	4dcc3819-424c-4d09-9482-91ed2d9d19ab	8e57ec64-12f7-4c1b-809e-977233cf374f	4cb2d1d1-fa04-4416-b8c8-6716f76f5dea	employee
f46c84b4-fff2-42a5-b3fa-d02ceff7597a	2026-07-20 11:11:03.957452+00	2026-07-20 11:11:03.957452+00	4dcc3819-424c-4d09-9482-91ed2d9d19ab	f389ffea-b5f1-4132-9c04-337ebb4ab8fd	4cb2d1d1-fa04-4416-b8c8-6716f76f5dea	employee
0a91abda-a5c4-4ff5-ba0f-98b6308885cc	2026-07-20 11:11:03.957452+00	2026-07-20 11:11:03.957452+00	4dcc3819-424c-4d09-9482-91ed2d9d19ab	3e5a2e9c-b250-4896-900f-d75ee290635f	4cb2d1d1-fa04-4416-b8c8-6716f76f5dea	employee
544c2498-ef1e-45cd-bded-8efded004dad	2026-07-20 11:11:03.957452+00	2026-07-20 11:11:03.957452+00	4dcc3819-424c-4d09-9482-91ed2d9d19ab	4116e390-3789-4721-9e7b-133ebb2764c7	4cb2d1d1-fa04-4416-b8c8-6716f76f5dea	employee
212ea308-d8ce-481e-b205-9951746777d5	2026-07-20 11:11:03.957452+00	2026-07-20 11:11:03.957452+00	4dcc3819-424c-4d09-9482-91ed2d9d19ab	9e42561d-3de1-44eb-b7ec-5207ea857b8e	4cb2d1d1-fa04-4416-b8c8-6716f76f5dea	employee
2cc33dd0-dc14-442e-98dc-551339ff721e	2026-07-20 11:11:03.957452+00	2026-07-20 11:11:03.957452+00	4dcc3819-424c-4d09-9482-91ed2d9d19ab	4e1eb7bb-aea1-4b26-aa51-fef3ea6cbab8	4cb2d1d1-fa04-4416-b8c8-6716f76f5dea	employee
93030be2-10c8-4c4e-98b7-3116b5260cbe	2026-07-20 11:11:03.957452+00	2026-07-20 11:11:03.957452+00	4dcc3819-424c-4d09-9482-91ed2d9d19ab	5e03da3d-4fd1-4305-91ec-8a61bd1f28ee	89c94224-912c-4c54-a2fb-de5b87a40e1b	project_manager
8305bc89-305b-414e-a6c6-4adf5fb6264e	2026-07-20 11:11:03.957452+00	2026-07-20 11:11:03.957452+00	4dcc3819-424c-4d09-9482-91ed2d9d19ab	24baa76f-b9d0-4a8f-b28d-605d780d066a	89c94224-912c-4c54-a2fb-de5b87a40e1b	employee
f418331d-7618-4d4d-866c-8bdc8b211d1f	2026-07-20 11:11:03.957452+00	2026-07-20 11:11:03.957452+00	4dcc3819-424c-4d09-9482-91ed2d9d19ab	5742bab4-624b-41df-aff7-c3517eed7f4c	89c94224-912c-4c54-a2fb-de5b87a40e1b	employee
8634906b-f7e9-4f87-a483-8a2e27feaaa2	2026-07-20 11:11:03.957452+00	2026-07-20 11:11:03.957452+00	4dcc3819-424c-4d09-9482-91ed2d9d19ab	8d97ee0b-e8f3-4aec-ab48-db76ef6ede39	89c94224-912c-4c54-a2fb-de5b87a40e1b	employee
e8a42fbe-80a8-4290-843f-c15113c9d710	2026-07-20 11:11:03.957452+00	2026-07-20 11:11:03.957452+00	4dcc3819-424c-4d09-9482-91ed2d9d19ab	7a6ee833-86b5-4c74-a2b1-845608f4fbab	89c94224-912c-4c54-a2fb-de5b87a40e1b	employee
81e5fe23-e2a9-4b5c-a1b8-29a71e9ada2d	2026-07-20 11:11:03.957452+00	2026-07-20 11:11:03.957452+00	4dcc3819-424c-4d09-9482-91ed2d9d19ab	8e78a4d9-50d5-40e6-bcd8-fd3f57c31286	89c94224-912c-4c54-a2fb-de5b87a40e1b	employee
5f46ba35-93e2-4719-87a3-c4df6bf20749	2026-07-20 11:11:03.957452+00	2026-07-20 11:11:03.957452+00	4dcc3819-424c-4d09-9482-91ed2d9d19ab	d7465638-ca92-4b34-b9b1-b1ab5012de48	89c94224-912c-4c54-a2fb-de5b87a40e1b	employee
d9b24f17-f367-4391-97d8-edc9d377d54b	2026-07-20 11:11:03.957452+00	2026-07-20 11:11:03.957452+00	4dcc3819-424c-4d09-9482-91ed2d9d19ab	ac9072e5-ff0f-4d63-880d-330ba7a1645e	4c930d15-6ec3-4e03-85ea-4b2ee2dc0a0d	project_manager
aa726a4d-b94e-4fcf-859b-c38d31dec35a	2026-07-20 11:11:03.957452+00	2026-07-20 11:11:03.957452+00	4dcc3819-424c-4d09-9482-91ed2d9d19ab	fbd6cd8f-ebe9-40af-a413-fa64b9419d5a	4c930d15-6ec3-4e03-85ea-4b2ee2dc0a0d	employee
7b637e14-567c-4056-bb3b-350b6263f1d3	2026-07-20 11:11:03.957452+00	2026-07-20 11:11:03.957452+00	4dcc3819-424c-4d09-9482-91ed2d9d19ab	3a5bbe57-a350-4aac-a8a7-02d037f0c644	4c930d15-6ec3-4e03-85ea-4b2ee2dc0a0d	employee
50c31c07-4b3f-42b9-a994-f17ec6a7b47b	2026-07-20 11:11:03.957452+00	2026-07-20 11:11:03.957452+00	4dcc3819-424c-4d09-9482-91ed2d9d19ab	ea1e6921-d2aa-44c0-978b-ff36b7d9fff2	4c930d15-6ec3-4e03-85ea-4b2ee2dc0a0d	employee
eabee4d0-81d6-4dbd-acdd-46c0492e91ae	2026-07-20 11:11:03.957452+00	2026-07-20 11:11:03.957452+00	4dcc3819-424c-4d09-9482-91ed2d9d19ab	57aede22-e4a3-452e-8ade-22917514d015	4c930d15-6ec3-4e03-85ea-4b2ee2dc0a0d	employee
57c2b725-a82a-4db0-81dc-f9f0d88c33c3	2026-07-20 11:11:03.957452+00	2026-07-20 11:11:03.957452+00	4dcc3819-424c-4d09-9482-91ed2d9d19ab	0631f64d-7a8f-4a1f-b13c-6e22248209c5	4c930d15-6ec3-4e03-85ea-4b2ee2dc0a0d	employee
73111fec-0d44-439f-acbf-de2e9480698e	2026-07-20 11:11:03.957452+00	2026-07-20 11:11:03.957452+00	4dcc3819-424c-4d09-9482-91ed2d9d19ab	c159ec20-f52f-44c6-a62b-b5579693a2e2	4c930d15-6ec3-4e03-85ea-4b2ee2dc0a0d	employee
78db8064-a8a4-4fa4-bdea-639a008b6930	2026-07-20 11:11:03.957452+00	2026-07-20 11:11:03.957452+00	4dcc3819-424c-4d09-9482-91ed2d9d19ab	ac9072e5-ff0f-4d63-880d-330ba7a1645e	4cb2d1d1-fa04-4416-b8c8-6716f76f5dea	employee
a628e908-62b4-4a6c-9e05-8bcd0ad897c4	2026-07-20 11:11:03.957452+00	2026-07-20 11:11:03.957452+00	4dcc3819-424c-4d09-9482-91ed2d9d19ab	8e57ec64-12f7-4c1b-809e-977233cf374f	89c94224-912c-4c54-a2fb-de5b87a40e1b	employee
\.


--
-- Data for Name: departments; Type: TABLE DATA; Schema: public; Owner: -
--

COPY public.departments (id, created_at, updated_at, organization_id, name) FROM stdin;
4cb2d1d1-fa04-4416-b8c8-6716f76f5dea	2026-07-20 11:11:03.957452+00	2026-07-20 11:11:03.957452+00	4dcc3819-424c-4d09-9482-91ed2d9d19ab	مهندسی و فنی
89c94224-912c-4c54-a2fb-de5b87a40e1b	2026-07-20 11:11:03.957452+00	2026-07-20 11:11:03.957452+00	4dcc3819-424c-4d09-9482-91ed2d9d19ab	حسابداری و مالی
4c930d15-6ec3-4e03-85ea-4b2ee2dc0a0d	2026-07-20 11:11:03.957452+00	2026-07-20 11:11:03.957452+00	4dcc3819-424c-4d09-9482-91ed2d9d19ab	منابع انسانی
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
شرکت نمونهٔ آزمایشی	demo-org-23895ca3	t	4dcc3819-424c-4d09-9482-91ed2d9d19ab	2026-07-20 11:11:03.957452+00	2026-07-20 11:11:03.957452+00
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
af7dff5d-2ae0-42f4-8cf7-3b62e42f61b7	58d048c0-3e97-449e-bb15-1a8b9a558017	be6bf2a7-a893-4bfd-8ed7-5a306d8fd6da	2026-07-20 11:11:03.957452+00	2026-07-20 11:11:03.957452+00
af7dff5d-2ae0-42f4-8cf7-3b62e42f61b7	4e1eb7bb-aea1-4b26-aa51-fef3ea6cbab8	dc4b69c7-6a03-45ad-81fa-6092d4e64de9	2026-07-20 11:11:03.957452+00	2026-07-20 11:11:03.957452+00
af7dff5d-2ae0-42f4-8cf7-3b62e42f61b7	8e57ec64-12f7-4c1b-809e-977233cf374f	e1a9b80c-c18f-4535-a1a3-2886e1155124	2026-07-20 11:11:03.957452+00	2026-07-20 11:11:03.957452+00
af7dff5d-2ae0-42f4-8cf7-3b62e42f61b7	9e42561d-3de1-44eb-b7ec-5207ea857b8e	b17056ed-6d68-4688-a9c6-53ccc6e67cc6	2026-07-20 11:11:03.957452+00	2026-07-20 11:11:03.957452+00
a7b0ee8a-3b5c-4d31-9ca7-20bc15933213	58d048c0-3e97-449e-bb15-1a8b9a558017	032cc730-c4cd-4707-a02a-720299c33707	2026-07-20 11:11:03.957452+00	2026-07-20 11:11:03.957452+00
a7b0ee8a-3b5c-4d31-9ca7-20bc15933213	4e1eb7bb-aea1-4b26-aa51-fef3ea6cbab8	40cf2deb-d0c1-4b45-a720-4447eed3ba15	2026-07-20 11:11:03.957452+00	2026-07-20 11:11:03.957452+00
a7b0ee8a-3b5c-4d31-9ca7-20bc15933213	3e5a2e9c-b250-4896-900f-d75ee290635f	031350d7-7612-41ce-abb0-f4f1203c17d7	2026-07-20 11:11:03.957452+00	2026-07-20 11:11:03.957452+00
a7b0ee8a-3b5c-4d31-9ca7-20bc15933213	f389ffea-b5f1-4132-9c04-337ebb4ab8fd	bedce3bc-9c64-4258-858c-821090e923ef	2026-07-20 11:11:03.957452+00	2026-07-20 11:11:03.957452+00
f8562903-2445-41dd-8533-332858c954d2	58d048c0-3e97-449e-bb15-1a8b9a558017	80c39d50-6e9e-4a95-aeb4-3a244786ec4b	2026-07-20 11:11:03.957452+00	2026-07-20 11:11:03.957452+00
f8562903-2445-41dd-8533-332858c954d2	f389ffea-b5f1-4132-9c04-337ebb4ab8fd	2fa28bab-fd18-4aa2-943e-0b4cf9aee07e	2026-07-20 11:11:03.957452+00	2026-07-20 11:11:03.957452+00
f8562903-2445-41dd-8533-332858c954d2	4e1eb7bb-aea1-4b26-aa51-fef3ea6cbab8	220a5a92-a919-4f81-b85e-6f1c6806bf9f	2026-07-20 11:11:03.957452+00	2026-07-20 11:11:03.957452+00
f8562903-2445-41dd-8533-332858c954d2	8e57ec64-12f7-4c1b-809e-977233cf374f	4712e921-024a-4d78-92d6-88fe4db0ff6a	2026-07-20 11:11:03.957452+00	2026-07-20 11:11:03.957452+00
214b156f-50e6-48ca-9d63-554205decf98	58d048c0-3e97-449e-bb15-1a8b9a558017	ce4be256-721a-4612-8504-8d17f8c192ab	2026-07-20 11:11:03.957452+00	2026-07-20 11:11:03.957452+00
214b156f-50e6-48ca-9d63-554205decf98	4e1eb7bb-aea1-4b26-aa51-fef3ea6cbab8	213daa30-26c1-418a-aa40-a7ceb314a0d3	2026-07-20 11:11:03.957452+00	2026-07-20 11:11:03.957452+00
214b156f-50e6-48ca-9d63-554205decf98	9e42561d-3de1-44eb-b7ec-5207ea857b8e	86d6753e-d1d8-4cab-a1da-ddc9ec86757c	2026-07-20 11:11:03.957452+00	2026-07-20 11:11:03.957452+00
214b156f-50e6-48ca-9d63-554205decf98	8e57ec64-12f7-4c1b-809e-977233cf374f	9b05e2ab-9d2e-4c63-bc53-353741c1079f	2026-07-20 11:11:03.957452+00	2026-07-20 11:11:03.957452+00
4d9d9007-cc28-40b2-824e-fb736a37db5d	58d048c0-3e97-449e-bb15-1a8b9a558017	bcf9df1b-5f45-43ad-96b2-a7e6dadcf0af	2026-07-20 11:11:03.957452+00	2026-07-20 11:11:03.957452+00
4d9d9007-cc28-40b2-824e-fb736a37db5d	9e42561d-3de1-44eb-b7ec-5207ea857b8e	f4e445ef-7c82-4c50-b880-6e908d06fcf8	2026-07-20 11:11:03.957452+00	2026-07-20 11:11:03.957452+00
4d9d9007-cc28-40b2-824e-fb736a37db5d	4116e390-3789-4721-9e7b-133ebb2764c7	2ee80852-5062-4eef-a6e2-d088896a5498	2026-07-20 11:11:03.957452+00	2026-07-20 11:11:03.957452+00
4d9d9007-cc28-40b2-824e-fb736a37db5d	8e57ec64-12f7-4c1b-809e-977233cf374f	e491d430-2772-4bdb-87ef-7827732826a6	2026-07-20 11:11:03.957452+00	2026-07-20 11:11:03.957452+00
47a3c135-ac0c-4015-a4f1-c962c169c55b	5e03da3d-4fd1-4305-91ec-8a61bd1f28ee	5d16bc56-6173-4d41-8310-9ca249af12ae	2026-07-20 11:11:03.957452+00	2026-07-20 11:11:03.957452+00
47a3c135-ac0c-4015-a4f1-c962c169c55b	7a6ee833-86b5-4c74-a2b1-845608f4fbab	8314005e-397a-4412-886c-8d1256209e71	2026-07-20 11:11:03.957452+00	2026-07-20 11:11:03.957452+00
47a3c135-ac0c-4015-a4f1-c962c169c55b	24baa76f-b9d0-4a8f-b28d-605d780d066a	d50fc98e-db2b-4690-a654-69c0595de6a2	2026-07-20 11:11:03.957452+00	2026-07-20 11:11:03.957452+00
47a3c135-ac0c-4015-a4f1-c962c169c55b	8d97ee0b-e8f3-4aec-ab48-db76ef6ede39	4c308c56-69a2-44d1-bc63-ee59b2c55b97	2026-07-20 11:11:03.957452+00	2026-07-20 11:11:03.957452+00
b960ff6a-9895-4681-8b20-e5984d2fa534	5e03da3d-4fd1-4305-91ec-8a61bd1f28ee	0127efca-8a06-4abd-8761-479ecb17428d	2026-07-20 11:11:03.957452+00	2026-07-20 11:11:03.957452+00
b960ff6a-9895-4681-8b20-e5984d2fa534	5742bab4-624b-41df-aff7-c3517eed7f4c	9f3134f4-f11c-46fe-8063-d6eba30b390b	2026-07-20 11:11:03.957452+00	2026-07-20 11:11:03.957452+00
b960ff6a-9895-4681-8b20-e5984d2fa534	24baa76f-b9d0-4a8f-b28d-605d780d066a	344a4f21-289d-46fb-b64c-054521e6b0ed	2026-07-20 11:11:03.957452+00	2026-07-20 11:11:03.957452+00
b960ff6a-9895-4681-8b20-e5984d2fa534	d7465638-ca92-4b34-b9b1-b1ab5012de48	67701f50-47b8-4849-8850-957b0169468a	2026-07-20 11:11:03.957452+00	2026-07-20 11:11:03.957452+00
a09ff0f0-43e2-48d8-8bf6-67e0e31e0def	5e03da3d-4fd1-4305-91ec-8a61bd1f28ee	1df8796f-a9b8-4874-ba3c-5fab00839935	2026-07-20 11:11:03.957452+00	2026-07-20 11:11:03.957452+00
a09ff0f0-43e2-48d8-8bf6-67e0e31e0def	24baa76f-b9d0-4a8f-b28d-605d780d066a	f6513f9d-15ab-4b10-9f13-13ee85643131	2026-07-20 11:11:03.957452+00	2026-07-20 11:11:03.957452+00
a09ff0f0-43e2-48d8-8bf6-67e0e31e0def	8d97ee0b-e8f3-4aec-ab48-db76ef6ede39	5fd1b194-1d76-41cf-8198-4d997319d4cc	2026-07-20 11:11:03.957452+00	2026-07-20 11:11:03.957452+00
a09ff0f0-43e2-48d8-8bf6-67e0e31e0def	8e78a4d9-50d5-40e6-bcd8-fd3f57c31286	c9623f50-6409-4b7c-9e79-7e9676833856	2026-07-20 11:11:03.957452+00	2026-07-20 11:11:03.957452+00
c7e23915-2f99-4ff8-9ca8-cda5dcdba7c9	5e03da3d-4fd1-4305-91ec-8a61bd1f28ee	375f4e61-7e39-4c94-b1a9-5498a4ea2f97	2026-07-20 11:11:03.957452+00	2026-07-20 11:11:03.957452+00
c7e23915-2f99-4ff8-9ca8-cda5dcdba7c9	8e78a4d9-50d5-40e6-bcd8-fd3f57c31286	d98dbabb-800e-45e8-a59f-20d653c0d962	2026-07-20 11:11:03.957452+00	2026-07-20 11:11:03.957452+00
c7e23915-2f99-4ff8-9ca8-cda5dcdba7c9	7a6ee833-86b5-4c74-a2b1-845608f4fbab	20718e11-9976-453d-8197-4e73e64d7838	2026-07-20 11:11:03.957452+00	2026-07-20 11:11:03.957452+00
c7e23915-2f99-4ff8-9ca8-cda5dcdba7c9	d7465638-ca92-4b34-b9b1-b1ab5012de48	641e7544-870c-4dda-8242-330f9f176acb	2026-07-20 11:11:03.957452+00	2026-07-20 11:11:03.957452+00
1fac07d5-b0a4-40b0-8f99-1e6da7ef8ac7	5e03da3d-4fd1-4305-91ec-8a61bd1f28ee	d263cc6c-2cfd-43c9-87cf-ae4cfa5a3a8c	2026-07-20 11:11:03.957452+00	2026-07-20 11:11:03.957452+00
1fac07d5-b0a4-40b0-8f99-1e6da7ef8ac7	8d97ee0b-e8f3-4aec-ab48-db76ef6ede39	08aa52f2-8485-45f4-9b7b-7e78ec75b129	2026-07-20 11:11:03.957452+00	2026-07-20 11:11:03.957452+00
1fac07d5-b0a4-40b0-8f99-1e6da7ef8ac7	24baa76f-b9d0-4a8f-b28d-605d780d066a	c9608131-d804-46ab-8015-da6f8535cfca	2026-07-20 11:11:03.957452+00	2026-07-20 11:11:03.957452+00
1fac07d5-b0a4-40b0-8f99-1e6da7ef8ac7	5742bab4-624b-41df-aff7-c3517eed7f4c	74661057-f6d6-4a7f-807c-faf35ef7c3ba	2026-07-20 11:11:03.957452+00	2026-07-20 11:11:03.957452+00
c6aa009d-ea9c-495f-a286-0555a1051213	ac9072e5-ff0f-4d63-880d-330ba7a1645e	25f761f2-52ae-4871-997d-dbc7aae523aa	2026-07-20 11:11:03.957452+00	2026-07-20 11:11:03.957452+00
c6aa009d-ea9c-495f-a286-0555a1051213	c159ec20-f52f-44c6-a62b-b5579693a2e2	8aa1327f-833b-48fe-9a9e-c58912fcbc72	2026-07-20 11:11:03.957452+00	2026-07-20 11:11:03.957452+00
c6aa009d-ea9c-495f-a286-0555a1051213	ea1e6921-d2aa-44c0-978b-ff36b7d9fff2	bc8a234f-2bd3-4b86-bc0e-85fa8254ae9e	2026-07-20 11:11:03.957452+00	2026-07-20 11:11:03.957452+00
c6aa009d-ea9c-495f-a286-0555a1051213	57aede22-e4a3-452e-8ade-22917514d015	2f96a628-8385-4c98-840f-140476838e31	2026-07-20 11:11:03.957452+00	2026-07-20 11:11:03.957452+00
5d8c9706-dd1f-4e2c-9412-df9ea8285c7a	ac9072e5-ff0f-4d63-880d-330ba7a1645e	d880ec28-22b1-476a-9033-9656606e8531	2026-07-20 11:11:03.957452+00	2026-07-20 11:11:03.957452+00
5d8c9706-dd1f-4e2c-9412-df9ea8285c7a	0631f64d-7a8f-4a1f-b13c-6e22248209c5	dbcc5a1d-5cdf-4464-b9b6-8624c370c99c	2026-07-20 11:11:03.957452+00	2026-07-20 11:11:03.957452+00
5d8c9706-dd1f-4e2c-9412-df9ea8285c7a	57aede22-e4a3-452e-8ade-22917514d015	63b078cb-0aec-4b80-b6fa-b8acbe089091	2026-07-20 11:11:03.957452+00	2026-07-20 11:11:03.957452+00
5d8c9706-dd1f-4e2c-9412-df9ea8285c7a	ea1e6921-d2aa-44c0-978b-ff36b7d9fff2	56a9ba94-55ff-4b14-a28c-c9183b0e8a33	2026-07-20 11:11:03.957452+00	2026-07-20 11:11:03.957452+00
bad8216b-b2f3-4ddb-acca-b5ab203499fc	ac9072e5-ff0f-4d63-880d-330ba7a1645e	22638195-4773-4857-a223-077a59e47b8f	2026-07-20 11:11:03.957452+00	2026-07-20 11:11:03.957452+00
bad8216b-b2f3-4ddb-acca-b5ab203499fc	0631f64d-7a8f-4a1f-b13c-6e22248209c5	10560f16-5aee-444d-aa22-ba1add827a07	2026-07-20 11:11:03.957452+00	2026-07-20 11:11:03.957452+00
bad8216b-b2f3-4ddb-acca-b5ab203499fc	c159ec20-f52f-44c6-a62b-b5579693a2e2	9b798bd9-2e98-414a-84c5-d5a6288ad8e1	2026-07-20 11:11:03.957452+00	2026-07-20 11:11:03.957452+00
bad8216b-b2f3-4ddb-acca-b5ab203499fc	ea1e6921-d2aa-44c0-978b-ff36b7d9fff2	6814de79-316c-4bbe-a115-b7fae69b5a8a	2026-07-20 11:11:03.957452+00	2026-07-20 11:11:03.957452+00
061a037c-86e9-4699-a76d-8a1b0c7c4bc2	ac9072e5-ff0f-4d63-880d-330ba7a1645e	de61fcb0-a1dc-4dfe-954c-24177d4e0c92	2026-07-20 11:11:03.957452+00	2026-07-20 11:11:03.957452+00
061a037c-86e9-4699-a76d-8a1b0c7c4bc2	57aede22-e4a3-452e-8ade-22917514d015	31520b5e-307e-4128-b8ec-f14488445e5d	2026-07-20 11:11:03.957452+00	2026-07-20 11:11:03.957452+00
061a037c-86e9-4699-a76d-8a1b0c7c4bc2	ea1e6921-d2aa-44c0-978b-ff36b7d9fff2	03ccce71-29da-4315-94ad-dc12918bbf8c	2026-07-20 11:11:03.957452+00	2026-07-20 11:11:03.957452+00
061a037c-86e9-4699-a76d-8a1b0c7c4bc2	3a5bbe57-a350-4aac-a8a7-02d037f0c644	096856a4-f0f6-42b9-8303-ae5897a14317	2026-07-20 11:11:03.957452+00	2026-07-20 11:11:03.957452+00
f9fdf4eb-972d-4c59-9e96-24e6388d7053	ac9072e5-ff0f-4d63-880d-330ba7a1645e	1b66750d-7b87-492f-984f-fc2daf6adfde	2026-07-20 11:11:03.957452+00	2026-07-20 11:11:03.957452+00
f9fdf4eb-972d-4c59-9e96-24e6388d7053	fbd6cd8f-ebe9-40af-a413-fa64b9419d5a	d04db114-8e22-48e7-b19c-85de7f051168	2026-07-20 11:11:03.957452+00	2026-07-20 11:11:03.957452+00
f9fdf4eb-972d-4c59-9e96-24e6388d7053	ea1e6921-d2aa-44c0-978b-ff36b7d9fff2	3c4cec1b-4f70-4982-84b1-69eceaebb48e	2026-07-20 11:11:03.957452+00	2026-07-20 11:11:03.957452+00
f9fdf4eb-972d-4c59-9e96-24e6388d7053	3a5bbe57-a350-4aac-a8a7-02d037f0c644	949fc15c-de97-4065-867e-ff4d7e361e73	2026-07-20 11:11:03.957452+00	2026-07-20 11:11:03.957452+00
\.


--
-- Data for Name: projects; Type: TABLE DATA; Schema: public; Owner: -
--

COPY public.projects (organization_id, name, description, start_date, end_date, status, created_by_id, id, created_at, updated_at, manager_id, cooperation_start_date, department_id) FROM stdin;
4dcc3819-424c-4d09-9482-91ed2d9d19ab	بازطراحی وب‌سایت شرکتی	پروژهٔ مهندسی و فنی شماره 1	2026-06-16	2026-10-14	active	40816eb2-f7d3-4e42-8512-c8262568d134	af7dff5d-2ae0-42f4-8cf7-3b62e42f61b7	2026-07-20 11:11:03.957452+00	2026-07-20 11:11:03.957452+00	58d048c0-3e97-449e-bb15-1a8b9a558017	2026-06-16	4cb2d1d1-fa04-4416-b8c8-6716f76f5dea
4dcc3819-424c-4d09-9482-91ed2d9d19ab	توسعهٔ اپلیکیشن موبایل فروش	پروژهٔ مهندسی و فنی شماره 2	2026-06-16	2026-10-14	active	40816eb2-f7d3-4e42-8512-c8262568d134	a7b0ee8a-3b5c-4d31-9ca7-20bc15933213	2026-07-20 11:11:03.957452+00	2026-07-20 11:11:03.957452+00	58d048c0-3e97-449e-bb15-1a8b9a558017	2026-06-16	4cb2d1d1-fa04-4416-b8c8-6716f76f5dea
4dcc3819-424c-4d09-9482-91ed2d9d19ab	مهاجرت زیرساخت به ابر	پروژهٔ مهندسی و فنی شماره 3	2026-06-16	2026-10-14	active	40816eb2-f7d3-4e42-8512-c8262568d134	f8562903-2445-41dd-8533-332858c954d2	2026-07-20 11:11:03.957452+00	2026-07-20 11:11:03.957452+00	58d048c0-3e97-449e-bb15-1a8b9a558017	2026-06-16	4cb2d1d1-fa04-4416-b8c8-6716f76f5dea
4dcc3819-424c-4d09-9482-91ed2d9d19ab	پیاده‌سازی سامانهٔ مانیتورینگ	پروژهٔ مهندسی و فنی شماره 4	2026-06-16	2026-10-14	active	40816eb2-f7d3-4e42-8512-c8262568d134	214b156f-50e6-48ca-9d63-554205decf98	2026-07-20 11:11:03.957452+00	2026-07-20 11:11:03.957452+00	58d048c0-3e97-449e-bb15-1a8b9a558017	2026-06-16	4cb2d1d1-fa04-4416-b8c8-6716f76f5dea
4dcc3819-424c-4d09-9482-91ed2d9d19ab	بهبود عملکرد پایگاه‌داده	پروژهٔ مهندسی و فنی شماره 5	2026-06-16	2026-10-14	active	40816eb2-f7d3-4e42-8512-c8262568d134	4d9d9007-cc28-40b2-824e-fb736a37db5d	2026-07-20 11:11:03.957452+00	2026-07-20 11:11:03.957452+00	58d048c0-3e97-449e-bb15-1a8b9a558017	2026-06-16	4cb2d1d1-fa04-4416-b8c8-6716f76f5dea
4dcc3819-424c-4d09-9482-91ed2d9d19ab	بستن حساب‌های مالی سال	پروژهٔ حسابداری و مالی شماره 1	2026-06-16	2026-10-14	active	40816eb2-f7d3-4e42-8512-c8262568d134	47a3c135-ac0c-4015-a4f1-c962c169c55b	2026-07-20 11:11:03.957452+00	2026-07-20 11:11:03.957452+00	5e03da3d-4fd1-4305-91ec-8a61bd1f28ee	2026-06-16	89c94224-912c-4c54-a2fb-de5b87a40e1b
4dcc3819-424c-4d09-9482-91ed2d9d19ab	پیاده‌سازی سامانهٔ فاکتور الکترونیک	پروژهٔ حسابداری و مالی شماره 2	2026-06-16	2026-10-14	active	40816eb2-f7d3-4e42-8512-c8262568d134	b960ff6a-9895-4681-8b20-e5984d2fa534	2026-07-20 11:11:03.957452+00	2026-07-20 11:11:03.957452+00	5e03da3d-4fd1-4305-91ec-8a61bd1f28ee	2026-06-16	89c94224-912c-4c54-a2fb-de5b87a40e1b
4dcc3819-424c-4d09-9482-91ed2d9d19ab	ممیزی مالی سه‌ماههٔ دوم	پروژهٔ حسابداری و مالی شماره 3	2026-06-16	2026-10-14	active	40816eb2-f7d3-4e42-8512-c8262568d134	a09ff0f0-43e2-48d8-8bf6-67e0e31e0def	2026-07-20 11:11:03.957452+00	2026-07-20 11:11:03.957452+00	5e03da3d-4fd1-4305-91ec-8a61bd1f28ee	2026-06-16	89c94224-912c-4c54-a2fb-de5b87a40e1b
4dcc3819-424c-4d09-9482-91ed2d9d19ab	تدوین بودجهٔ سال آینده	پروژهٔ حسابداری و مالی شماره 4	2026-06-16	2026-10-14	active	40816eb2-f7d3-4e42-8512-c8262568d134	c7e23915-2f99-4ff8-9ca8-cda5dcdba7c9	2026-07-20 11:11:03.957452+00	2026-07-20 11:11:03.957452+00	5e03da3d-4fd1-4305-91ec-8a61bd1f28ee	2026-06-16	89c94224-912c-4c54-a2fb-de5b87a40e1b
4dcc3819-424c-4d09-9482-91ed2d9d19ab	مدیریت مطالبات و بدهی‌ها	پروژهٔ حسابداری و مالی شماره 5	2026-06-16	2026-10-14	active	40816eb2-f7d3-4e42-8512-c8262568d134	1fac07d5-b0a4-40b0-8f99-1e6da7ef8ac7	2026-07-20 11:11:03.957452+00	2026-07-20 11:11:03.957452+00	5e03da3d-4fd1-4305-91ec-8a61bd1f28ee	2026-06-16	89c94224-912c-4c54-a2fb-de5b87a40e1b
4dcc3819-424c-4d09-9482-91ed2d9d19ab	برگزاری دورهٔ آموزشی کارکنان	پروژهٔ منابع انسانی شماره 1	2026-06-16	2026-10-14	active	40816eb2-f7d3-4e42-8512-c8262568d134	c6aa009d-ea9c-495f-a286-0555a1051213	2026-07-20 11:11:03.957452+00	2026-07-20 11:11:03.957452+00	ac9072e5-ff0f-4d63-880d-330ba7a1645e	2026-06-16	4c930d15-6ec3-4e03-85ea-4b2ee2dc0a0d
4dcc3819-424c-4d09-9482-91ed2d9d19ab	بازطراحی فرایند جذب و استخدام	پروژهٔ منابع انسانی شماره 2	2026-06-16	2026-10-14	active	40816eb2-f7d3-4e42-8512-c8262568d134	5d8c9706-dd1f-4e2c-9412-df9ea8285c7a	2026-07-20 11:11:03.957452+00	2026-07-20 11:11:03.957452+00	ac9072e5-ff0f-4d63-880d-330ba7a1645e	2026-06-16	4c930d15-6ec3-4e03-85ea-4b2ee2dc0a0d
4dcc3819-424c-4d09-9482-91ed2d9d19ab	ارزیابی عملکرد سالانهٔ کارکنان	پروژهٔ منابع انسانی شماره 3	2026-06-16	2026-10-14	active	40816eb2-f7d3-4e42-8512-c8262568d134	bad8216b-b2f3-4ddb-acca-b5ab203499fc	2026-07-20 11:11:03.957452+00	2026-07-20 11:11:03.957452+00	ac9072e5-ff0f-4d63-880d-330ba7a1645e	2026-06-16	4c930d15-6ec3-4e03-85ea-4b2ee2dc0a0d
4dcc3819-424c-4d09-9482-91ed2d9d19ab	طراحی برنامهٔ رفاهی کارکنان	پروژهٔ منابع انسانی شماره 4	2026-06-16	2026-10-14	active	40816eb2-f7d3-4e42-8512-c8262568d134	061a037c-86e9-4699-a76d-8a1b0c7c4bc2	2026-07-20 11:11:03.957452+00	2026-07-20 11:11:03.957452+00	ac9072e5-ff0f-4d63-880d-330ba7a1645e	2026-06-16	4c930d15-6ec3-4e03-85ea-4b2ee2dc0a0d
4dcc3819-424c-4d09-9482-91ed2d9d19ab	پیاده‌سازی سامانهٔ حضور و غیاب	پروژهٔ منابع انسانی شماره 5	2026-06-16	2026-10-14	active	40816eb2-f7d3-4e42-8512-c8262568d134	f9fdf4eb-972d-4c59-9e96-24e6388d7053	2026-07-20 11:11:03.957452+00	2026-07-20 11:11:03.957452+00	ac9072e5-ff0f-4d63-880d-330ba7a1645e	2026-06-16	4c930d15-6ec3-4e03-85ea-4b2ee2dc0a0d
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
4dcc3819-424c-4d09-9482-91ed2d9d19ab	af7dff5d-2ae0-42f4-8cf7-3b62e42f61b7	\N	58d048c0-3e97-449e-bb15-1a8b9a558017	58d048c0-3e97-449e-bb15-1a8b9a558017	به‌روزرسانی کتابخانه‌های وابسته #1	\N	high	2026-07-08	fefd2be4-af15-451c-9d81-bb1654ed30bd	2026-07-20 11:11:03.957452+00	2026-07-20 11:11:03.957452+00	todo	\N	3	23.30	2026-06-29
4dcc3819-424c-4d09-9482-91ed2d9d19ab	af7dff5d-2ae0-42f4-8cf7-3b62e42f61b7	\N	9e42561d-3de1-44eb-b7ec-5207ea857b8e	58d048c0-3e97-449e-bb15-1a8b9a558017	بررسی و رفع آسیب‌پذیری امنیتی #2	\N	high	2026-07-21	75287830-e95a-4f23-8779-c4fbc0d4b25d	2026-07-20 11:11:03.957452+00	2026-07-20 11:11:03.957452+00	completed	pending	100	12.60	2026-07-12
4dcc3819-424c-4d09-9482-91ed2d9d19ab	af7dff5d-2ae0-42f4-8cf7-3b62e42f61b7	\N	4e1eb7bb-aea1-4b26-aa51-fef3ea6cbab8	58d048c0-3e97-449e-bb15-1a8b9a558017	نوشتن مستندات فنی API #3	\N	medium	2026-08-10	d39039d1-378d-4567-954b-931d09fcc535	2026-07-20 11:11:03.957452+00	2026-07-20 11:11:03.957452+00	todo	\N	43	12.60	2026-08-03
4dcc3819-424c-4d09-9482-91ed2d9d19ab	af7dff5d-2ae0-42f4-8cf7-3b62e42f61b7	\N	8e57ec64-12f7-4c1b-809e-977233cf374f	58d048c0-3e97-449e-bb15-1a8b9a558017	پیاده‌سازی صفحهٔ ورود جدید #4	\N	medium	2026-07-12	f425b816-5140-4031-90e9-956972efd68d	2026-07-20 11:11:03.957452+00	2026-07-20 11:11:03.957452+00	archived	\N	12	15.60	2026-07-07
4dcc3819-424c-4d09-9482-91ed2d9d19ab	af7dff5d-2ae0-42f4-8cf7-3b62e42f61b7	\N	f389ffea-b5f1-4132-9c04-337ebb4ab8fd	58d048c0-3e97-449e-bb15-1a8b9a558017	به‌روزرسانی کتابخانه‌های وابسته #5	\N	low	2026-07-04	ae1d960a-c0be-48f8-bd3b-02e397f2ca68	2026-07-20 11:11:03.957452+00	2026-07-20 11:11:03.957452+00	completed	approved	100	39.00	2026-06-18
4dcc3819-424c-4d09-9482-91ed2d9d19ab	af7dff5d-2ae0-42f4-8cf7-3b62e42f61b7	\N	3e5a2e9c-b250-4896-900f-d75ee290635f	58d048c0-3e97-449e-bb15-1a8b9a558017	بازنویسی ماژول اعلان‌ها #6	\N	high	2026-08-01	1b2f5948-e8b7-4d09-b4d1-45633a948d4c	2026-07-20 11:11:03.957452+00	2026-07-20 11:11:03.957452+00	todo	\N	79	35.60	2026-07-21
4dcc3819-424c-4d09-9482-91ed2d9d19ab	af7dff5d-2ae0-42f4-8cf7-3b62e42f61b7	\N	f389ffea-b5f1-4132-9c04-337ebb4ab8fd	58d048c0-3e97-449e-bb15-1a8b9a558017	تنظیم پایپ‌لاین CI/CD #7	\N	low	2026-06-23	a123e7a2-b918-4314-aef8-7bff7cbcbcb0	2026-07-20 11:11:03.957452+00	2026-07-20 11:11:03.957452+00	completed	approved	100	31.40	2026-06-20
4dcc3819-424c-4d09-9482-91ed2d9d19ab	af7dff5d-2ae0-42f4-8cf7-3b62e42f61b7	\N	58d048c0-3e97-449e-bb15-1a8b9a558017	58d048c0-3e97-449e-bb15-1a8b9a558017	پیاده‌سازی احراز هویت دومرحله‌ای #8	\N	medium	2026-08-15	1addc8df-d363-466d-b3ec-9cd188bcaa44	2026-07-20 11:11:03.957452+00	2026-07-20 11:11:03.957452+00	in_progress	\N	58	26.20	2026-08-10
4dcc3819-424c-4d09-9482-91ed2d9d19ab	af7dff5d-2ae0-42f4-8cf7-3b62e42f61b7	\N	f389ffea-b5f1-4132-9c04-337ebb4ab8fd	58d048c0-3e97-449e-bb15-1a8b9a558017	افزودن تست واحد برای سرویس کاربران #9	\N	high	2026-07-22	acc48e5e-4b95-48ff-bac7-ba08e2277736	2026-07-20 11:11:03.957452+00	2026-07-20 11:11:03.957452+00	todo	\N	34	28.70	2026-07-09
4dcc3819-424c-4d09-9482-91ed2d9d19ab	af7dff5d-2ae0-42f4-8cf7-3b62e42f61b7	\N	9e42561d-3de1-44eb-b7ec-5207ea857b8e	58d048c0-3e97-449e-bb15-1a8b9a558017	به‌روزرسانی کتابخانه‌های وابسته #10	\N	high	2026-08-02	50a686df-1e7e-4509-8226-e8e79da5dc17	2026-07-20 11:11:03.957452+00	2026-07-20 11:11:03.957452+00	completed	approved	100	11.30	2026-07-26
4dcc3819-424c-4d09-9482-91ed2d9d19ab	af7dff5d-2ae0-42f4-8cf7-3b62e42f61b7	\N	3e5a2e9c-b250-4896-900f-d75ee290635f	58d048c0-3e97-449e-bb15-1a8b9a558017	افزودن تست واحد برای سرویس کاربران #11	\N	high	2026-07-22	c6be38b2-78a7-4fe5-b9ca-799baac55158	2026-07-20 11:11:03.957452+00	2026-07-20 11:11:03.957452+00	in_progress	\N	41	34.00	2026-07-03
4dcc3819-424c-4d09-9482-91ed2d9d19ab	af7dff5d-2ae0-42f4-8cf7-3b62e42f61b7	\N	4e1eb7bb-aea1-4b26-aa51-fef3ea6cbab8	58d048c0-3e97-449e-bb15-1a8b9a558017	رفع مشکل ناسازگاری مرورگر #12	\N	medium	2026-07-03	e0a306e4-ab81-4fa5-a247-f624da1364c7	2026-07-20 11:11:03.957452+00	2026-07-20 11:11:03.957452+00	todo	\N	51	12.20	2026-06-30
4dcc3819-424c-4d09-9482-91ed2d9d19ab	af7dff5d-2ae0-42f4-8cf7-3b62e42f61b7	\N	8e57ec64-12f7-4c1b-809e-977233cf374f	58d048c0-3e97-449e-bb15-1a8b9a558017	تنظیم پایپ‌لاین CI/CD #13	\N	medium	2026-07-14	2dc6badc-a8bc-46c0-b3a8-acbdc572c646	2026-07-20 11:11:03.957452+00	2026-07-20 11:11:03.957452+00	completed	pending	100	17.00	2026-07-06
4dcc3819-424c-4d09-9482-91ed2d9d19ab	af7dff5d-2ae0-42f4-8cf7-3b62e42f61b7	\N	9e42561d-3de1-44eb-b7ec-5207ea857b8e	58d048c0-3e97-449e-bb15-1a8b9a558017	نوشتن مستندات فنی API #14	\N	high	2026-07-03	f57202f5-2a31-401f-ba1b-42ce7c371921	2026-07-20 11:11:03.957452+00	2026-07-20 11:11:03.957452+00	completed	approved	100	22.50	2026-06-24
4dcc3819-424c-4d09-9482-91ed2d9d19ab	af7dff5d-2ae0-42f4-8cf7-3b62e42f61b7	\N	9e42561d-3de1-44eb-b7ec-5207ea857b8e	58d048c0-3e97-449e-bb15-1a8b9a558017	رفع مشکل کندی بارگذاری صفحه #15	\N	low	2026-08-06	fc350058-2378-4ace-930d-823970423200	2026-07-20 11:11:03.957452+00	2026-07-20 11:11:03.957452+00	completed	approved	100	39.90	2026-07-23
4dcc3819-424c-4d09-9482-91ed2d9d19ab	af7dff5d-2ae0-42f4-8cf7-3b62e42f61b7	\N	8e57ec64-12f7-4c1b-809e-977233cf374f	58d048c0-3e97-449e-bb15-1a8b9a558017	بازنویسی ماژول اعلان‌ها #16	\N	low	2026-08-06	57f8c7f2-9eeb-4e1b-be13-98ff6c108c6b	2026-07-20 11:11:03.957452+00	2026-07-20 11:11:03.957452+00	completed	approved	100	7.80	2026-08-03
4dcc3819-424c-4d09-9482-91ed2d9d19ab	af7dff5d-2ae0-42f4-8cf7-3b62e42f61b7	\N	8e57ec64-12f7-4c1b-809e-977233cf374f	58d048c0-3e97-449e-bb15-1a8b9a558017	پیاده‌سازی احراز هویت دومرحله‌ای #17	\N	high	2026-07-04	59e92799-52a8-44ae-a776-c8cdc1db1e74	2026-07-20 11:11:03.957452+00	2026-07-20 11:11:03.957452+00	completed	approved	100	39.90	2026-06-20
4dcc3819-424c-4d09-9482-91ed2d9d19ab	af7dff5d-2ae0-42f4-8cf7-3b62e42f61b7	\N	4116e390-3789-4721-9e7b-133ebb2764c7	58d048c0-3e97-449e-bb15-1a8b9a558017	تنظیم پایپ‌لاین CI/CD #18	\N	high	2026-07-23	8b5830c7-9bf7-49b9-af03-a8c5e5196084	2026-07-20 11:11:03.957452+00	2026-07-20 11:11:03.957452+00	in_progress	\N	14	27.90	2026-07-21
4dcc3819-424c-4d09-9482-91ed2d9d19ab	a7b0ee8a-3b5c-4d31-9ca7-20bc15933213	\N	4116e390-3789-4721-9e7b-133ebb2764c7	58d048c0-3e97-449e-bb15-1a8b9a558017	پیاده‌سازی صفحهٔ ورود جدید #19	\N	medium	2026-07-15	5dafb62a-80b8-4ff7-8927-b560625412b4	2026-07-20 11:11:03.957452+00	2026-07-20 11:11:03.957452+00	archived	\N	55	8.00	2026-07-03
4dcc3819-424c-4d09-9482-91ed2d9d19ab	a7b0ee8a-3b5c-4d31-9ca7-20bc15933213	\N	58d048c0-3e97-449e-bb15-1a8b9a558017	58d048c0-3e97-449e-bb15-1a8b9a558017	به‌روزرسانی کتابخانه‌های وابسته #20	\N	low	2026-08-21	97cfaad3-d9a6-46c1-9f4e-0061e766df3a	2026-07-20 11:11:03.957452+00	2026-07-20 11:11:03.957452+00	archived	\N	64	36.70	2026-08-11
4dcc3819-424c-4d09-9482-91ed2d9d19ab	a7b0ee8a-3b5c-4d31-9ca7-20bc15933213	\N	4e1eb7bb-aea1-4b26-aa51-fef3ea6cbab8	58d048c0-3e97-449e-bb15-1a8b9a558017	پیاده‌سازی صفحهٔ داشبورد مدیریتی #21	\N	low	2026-08-13	ea81226c-2b1a-410b-8c61-d2967cfcaf74	2026-07-20 11:11:03.957452+00	2026-07-20 11:11:03.957452+00	completed	approved	100	7.80	2026-07-26
4dcc3819-424c-4d09-9482-91ed2d9d19ab	a7b0ee8a-3b5c-4d31-9ca7-20bc15933213	\N	4e1eb7bb-aea1-4b26-aa51-fef3ea6cbab8	58d048c0-3e97-449e-bb15-1a8b9a558017	افزودن قابلیت جست‌وجوی پیشرفته #22	\N	low	2026-08-07	61241b5f-3730-456b-aaf9-813a4fdc0db1	2026-07-20 11:11:03.957452+00	2026-07-20 11:11:03.957452+00	todo	\N	76	14.30	2026-07-20
4dcc3819-424c-4d09-9482-91ed2d9d19ab	a7b0ee8a-3b5c-4d31-9ca7-20bc15933213	\N	58d048c0-3e97-449e-bb15-1a8b9a558017	58d048c0-3e97-449e-bb15-1a8b9a558017	افزودن قابلیت جست‌وجوی پیشرفته #23	\N	medium	2026-08-27	3192a8e6-fbd9-43cd-9664-564268deff91	2026-07-20 11:11:03.957452+00	2026-07-20 11:11:03.957452+00	todo	\N	30	4.20	2026-08-14
4dcc3819-424c-4d09-9482-91ed2d9d19ab	a7b0ee8a-3b5c-4d31-9ca7-20bc15933213	\N	4116e390-3789-4721-9e7b-133ebb2764c7	58d048c0-3e97-449e-bb15-1a8b9a558017	بازنویسی ماژول اعلان‌ها #24	\N	low	2026-07-08	99b3786e-797b-488c-83c3-da025ec7d956	2026-07-20 11:11:03.957452+00	2026-07-20 11:11:03.957452+00	todo	\N	68	31.10	2026-06-21
4dcc3819-424c-4d09-9482-91ed2d9d19ab	a7b0ee8a-3b5c-4d31-9ca7-20bc15933213	\N	8e57ec64-12f7-4c1b-809e-977233cf374f	58d048c0-3e97-449e-bb15-1a8b9a558017	طراحی API نسخهٔ دوم #25	\N	high	2026-07-28	cac7c36f-e1fd-4045-9937-bb37612cfd91	2026-07-20 11:11:03.957452+00	2026-07-20 11:11:03.957452+00	completed	approved	100	35.20	2026-07-21
4dcc3819-424c-4d09-9482-91ed2d9d19ab	a7b0ee8a-3b5c-4d31-9ca7-20bc15933213	\N	3e5a2e9c-b250-4896-900f-d75ee290635f	58d048c0-3e97-449e-bb15-1a8b9a558017	رفع مشکل ناسازگاری مرورگر #26	\N	high	2026-09-02	0129765a-e817-43e8-a653-f56884c429e1	2026-07-20 11:11:03.957452+00	2026-07-20 11:11:03.957452+00	in_progress	\N	25	29.10	2026-08-14
4dcc3819-424c-4d09-9482-91ed2d9d19ab	a7b0ee8a-3b5c-4d31-9ca7-20bc15933213	\N	3e5a2e9c-b250-4896-900f-d75ee290635f	58d048c0-3e97-449e-bb15-1a8b9a558017	بررسی و رفع آسیب‌پذیری امنیتی #27	\N	low	2026-08-01	d7a9162d-6c7b-4450-a01c-84e0262b330b	2026-07-20 11:11:03.957452+00	2026-07-20 11:11:03.957452+00	completed	pending	100	11.40	2026-07-14
4dcc3819-424c-4d09-9482-91ed2d9d19ab	a7b0ee8a-3b5c-4d31-9ca7-20bc15933213	\N	58d048c0-3e97-449e-bb15-1a8b9a558017	58d048c0-3e97-449e-bb15-1a8b9a558017	به‌روزرسانی کتابخانه‌های وابسته #28	\N	low	2026-07-07	35151880-5a5e-40f1-a957-f4c515b6834b	2026-07-20 11:11:03.957452+00	2026-07-20 11:11:03.957452+00	in_progress	\N	75	10.40	2026-06-17
4dcc3819-424c-4d09-9482-91ed2d9d19ab	a7b0ee8a-3b5c-4d31-9ca7-20bc15933213	\N	58d048c0-3e97-449e-bb15-1a8b9a558017	58d048c0-3e97-449e-bb15-1a8b9a558017	افزودن تست واحد برای سرویس کاربران #29	\N	low	2026-07-29	9ca27493-db59-4397-91ca-d1d57484a60e	2026-07-20 11:11:03.957452+00	2026-07-20 11:11:03.957452+00	archived	\N	4	34.70	2026-07-26
4dcc3819-424c-4d09-9482-91ed2d9d19ab	a7b0ee8a-3b5c-4d31-9ca7-20bc15933213	\N	58d048c0-3e97-449e-bb15-1a8b9a558017	58d048c0-3e97-449e-bb15-1a8b9a558017	افزودن تست واحد برای سرویس کاربران #30	\N	high	2026-08-14	5a008113-8447-4d0a-bf4a-43d4011ee71d	2026-07-20 11:11:03.957452+00	2026-07-20 11:11:03.957452+00	completed	approved	100	7.00	2026-07-28
4dcc3819-424c-4d09-9482-91ed2d9d19ab	a7b0ee8a-3b5c-4d31-9ca7-20bc15933213	\N	4116e390-3789-4721-9e7b-133ebb2764c7	58d048c0-3e97-449e-bb15-1a8b9a558017	رفع مشکل ناسازگاری مرورگر #31	\N	medium	2026-08-22	37acbeb8-d1b4-4e22-a226-d17ca4f0458f	2026-07-20 11:11:03.957452+00	2026-07-20 11:11:03.957452+00	completed	approved	100	9.20	2026-08-05
4dcc3819-424c-4d09-9482-91ed2d9d19ab	a7b0ee8a-3b5c-4d31-9ca7-20bc15933213	\N	58d048c0-3e97-449e-bb15-1a8b9a558017	58d048c0-3e97-449e-bb15-1a8b9a558017	بررسی و رفع آسیب‌پذیری امنیتی #32	\N	high	2026-07-28	e24374b6-ee9b-4e34-8afe-e83aff8b5581	2026-07-20 11:11:03.957452+00	2026-07-20 11:11:03.957452+00	completed	approved	100	4.10	2026-07-13
4dcc3819-424c-4d09-9482-91ed2d9d19ab	a7b0ee8a-3b5c-4d31-9ca7-20bc15933213	\N	9e42561d-3de1-44eb-b7ec-5207ea857b8e	58d048c0-3e97-449e-bb15-1a8b9a558017	رفع مشکل ناسازگاری مرورگر #33	\N	low	2026-07-23	692d2bf1-3b56-4bbf-8e10-ba1bd6dcf4b6	2026-07-20 11:11:03.957452+00	2026-07-20 11:11:03.957452+00	completed	approved	100	11.40	2026-07-11
4dcc3819-424c-4d09-9482-91ed2d9d19ab	a7b0ee8a-3b5c-4d31-9ca7-20bc15933213	\N	8e57ec64-12f7-4c1b-809e-977233cf374f	58d048c0-3e97-449e-bb15-1a8b9a558017	طراحی API نسخهٔ دوم #34	\N	medium	2026-07-20	71e0a004-a882-4ae4-b81f-8f48e17b2bcf	2026-07-20 11:11:03.957452+00	2026-07-20 11:11:03.957452+00	completed	approved	100	11.50	2026-07-13
4dcc3819-424c-4d09-9482-91ed2d9d19ab	a7b0ee8a-3b5c-4d31-9ca7-20bc15933213	\N	58d048c0-3e97-449e-bb15-1a8b9a558017	58d048c0-3e97-449e-bb15-1a8b9a558017	پیاده‌سازی صفحهٔ ورود جدید #35	\N	low	2026-08-28	5274a160-9bf7-4824-a061-23ed0f12f615	2026-07-20 11:11:03.957452+00	2026-07-20 11:11:03.957452+00	completed	pending	100	26.80	2026-08-09
4dcc3819-424c-4d09-9482-91ed2d9d19ab	a7b0ee8a-3b5c-4d31-9ca7-20bc15933213	\N	4116e390-3789-4721-9e7b-133ebb2764c7	58d048c0-3e97-449e-bb15-1a8b9a558017	بهینه‌سازی کوئری‌های گزارش‌گیری #36	\N	medium	2026-06-30	35d2439e-231e-4cf7-82a9-87fb116cbc32	2026-07-20 11:11:03.957452+00	2026-07-20 11:11:03.957452+00	todo	\N	62	20.30	2026-06-21
4dcc3819-424c-4d09-9482-91ed2d9d19ab	f8562903-2445-41dd-8533-332858c954d2	\N	4e1eb7bb-aea1-4b26-aa51-fef3ea6cbab8	58d048c0-3e97-449e-bb15-1a8b9a558017	بهینه‌سازی کوئری‌های گزارش‌گیری #37	\N	medium	2026-08-15	93fe81c2-68bb-46f3-9274-93491573de13	2026-07-20 11:11:03.957452+00	2026-07-20 11:11:03.957452+00	in_progress	\N	0	39.40	2026-08-12
4dcc3819-424c-4d09-9482-91ed2d9d19ab	f8562903-2445-41dd-8533-332858c954d2	\N	f389ffea-b5f1-4132-9c04-337ebb4ab8fd	58d048c0-3e97-449e-bb15-1a8b9a558017	تنظیم پایپ‌لاین CI/CD #38	\N	high	2026-08-18	6aedf77d-44b8-4745-abaf-fc77f5b4155b	2026-07-20 11:11:03.957452+00	2026-07-20 11:11:03.957452+00	completed	approved	100	20.50	2026-07-30
4dcc3819-424c-4d09-9482-91ed2d9d19ab	f8562903-2445-41dd-8533-332858c954d2	\N	8e57ec64-12f7-4c1b-809e-977233cf374f	58d048c0-3e97-449e-bb15-1a8b9a558017	پیاده‌سازی صفحهٔ داشبورد مدیریتی #39	\N	high	2026-07-02	79c532ae-b46f-4ec8-89b0-b45af48514f2	2026-07-20 11:11:03.957452+00	2026-07-20 11:11:03.957452+00	in_progress	\N	69	4.30	2026-06-29
4dcc3819-424c-4d09-9482-91ed2d9d19ab	f8562903-2445-41dd-8533-332858c954d2	\N	f389ffea-b5f1-4132-9c04-337ebb4ab8fd	58d048c0-3e97-449e-bb15-1a8b9a558017	بررسی و رفع آسیب‌پذیری امنیتی #40	\N	high	2026-07-09	95402b76-c482-4444-8b15-a4ff9e6a41e1	2026-07-20 11:11:03.957452+00	2026-07-20 11:11:03.957452+00	todo	\N	67	8.00	2026-06-19
4dcc3819-424c-4d09-9482-91ed2d9d19ab	f8562903-2445-41dd-8533-332858c954d2	\N	4116e390-3789-4721-9e7b-133ebb2764c7	58d048c0-3e97-449e-bb15-1a8b9a558017	پیاده‌سازی صفحهٔ ورود جدید #41	\N	high	2026-08-16	a8f38616-ac94-4a1d-a3a0-b1a2ef2a3e7d	2026-07-20 11:11:03.957452+00	2026-07-20 11:11:03.957452+00	todo	\N	8	27.70	2026-08-09
4dcc3819-424c-4d09-9482-91ed2d9d19ab	f8562903-2445-41dd-8533-332858c954d2	\N	8e57ec64-12f7-4c1b-809e-977233cf374f	58d048c0-3e97-449e-bb15-1a8b9a558017	افزودن تست واحد برای سرویس کاربران #42	\N	high	2026-07-13	cf04a502-0db8-4fea-b14f-6d48810d632f	2026-07-20 11:11:03.957452+00	2026-07-20 11:11:03.957452+00	in_progress	\N	76	3.50	2026-06-23
4dcc3819-424c-4d09-9482-91ed2d9d19ab	f8562903-2445-41dd-8533-332858c954d2	\N	58d048c0-3e97-449e-bb15-1a8b9a558017	58d048c0-3e97-449e-bb15-1a8b9a558017	پیاده‌سازی صفحهٔ داشبورد مدیریتی #43	\N	high	2026-08-17	e4c69e65-fac1-4819-8bd9-5585535508c6	2026-07-20 11:11:03.957452+00	2026-07-20 11:11:03.957452+00	in_progress	\N	40	37.50	2026-07-28
4dcc3819-424c-4d09-9482-91ed2d9d19ab	f8562903-2445-41dd-8533-332858c954d2	\N	8e57ec64-12f7-4c1b-809e-977233cf374f	58d048c0-3e97-449e-bb15-1a8b9a558017	پیاده‌سازی احراز هویت دومرحله‌ای #44	\N	low	2026-07-11	be5506bc-05d0-4d2e-8f0c-eaa26b58cfa5	2026-07-20 11:11:03.957452+00	2026-07-20 11:11:03.957452+00	completed	pending	100	27.50	2026-07-01
4dcc3819-424c-4d09-9482-91ed2d9d19ab	f8562903-2445-41dd-8533-332858c954d2	\N	f389ffea-b5f1-4132-9c04-337ebb4ab8fd	58d048c0-3e97-449e-bb15-1a8b9a558017	رفع باگ در ماژول پرداخت #45	\N	medium	2026-08-07	c37b9e1d-4359-4a59-a306-3261b2c416d6	2026-07-20 11:11:03.957452+00	2026-07-20 11:11:03.957452+00	completed	approved	100	25.60	2026-08-03
4dcc3819-424c-4d09-9482-91ed2d9d19ab	f8562903-2445-41dd-8533-332858c954d2	\N	4116e390-3789-4721-9e7b-133ebb2764c7	58d048c0-3e97-449e-bb15-1a8b9a558017	افزودن تست واحد برای سرویس کاربران #46	\N	high	2026-07-09	d7e28420-1fb9-42f4-8002-11add16d0d3e	2026-07-20 11:11:03.957452+00	2026-07-20 11:11:03.957452+00	todo	\N	33	7.00	2026-06-20
4dcc3819-424c-4d09-9482-91ed2d9d19ab	f8562903-2445-41dd-8533-332858c954d2	\N	f389ffea-b5f1-4132-9c04-337ebb4ab8fd	58d048c0-3e97-449e-bb15-1a8b9a558017	رفع مشکل کندی بارگذاری صفحه #47	\N	medium	2026-08-20	6768ace5-db82-4391-8eb3-90a56aa7d6cd	2026-07-20 11:11:03.957452+00	2026-07-20 11:11:03.957452+00	todo	\N	20	18.70	2026-08-11
4dcc3819-424c-4d09-9482-91ed2d9d19ab	f8562903-2445-41dd-8533-332858c954d2	\N	4116e390-3789-4721-9e7b-133ebb2764c7	58d048c0-3e97-449e-bb15-1a8b9a558017	رفع مشکل ناسازگاری مرورگر #48	\N	high	2026-07-26	0ded1f25-51d4-41a4-ac67-17d6caed20af	2026-07-20 11:11:03.957452+00	2026-07-20 11:11:03.957452+00	archived	\N	67	2.30	2026-07-05
4dcc3819-424c-4d09-9482-91ed2d9d19ab	f8562903-2445-41dd-8533-332858c954d2	\N	4e1eb7bb-aea1-4b26-aa51-fef3ea6cbab8	58d048c0-3e97-449e-bb15-1a8b9a558017	افزودن قابلیت جست‌وجوی پیشرفته #49	\N	low	2026-08-02	83b3cd1c-265f-425e-a5a4-8b6a8a6292c1	2026-07-20 11:11:03.957452+00	2026-07-20 11:11:03.957452+00	completed	approved	100	12.00	2026-07-28
4dcc3819-424c-4d09-9482-91ed2d9d19ab	f8562903-2445-41dd-8533-332858c954d2	\N	58d048c0-3e97-449e-bb15-1a8b9a558017	58d048c0-3e97-449e-bb15-1a8b9a558017	طراحی API نسخهٔ دوم #50	\N	medium	2026-07-27	d12218a5-0ea4-4da5-8c56-0c90c2b3e1c9	2026-07-20 11:11:03.957452+00	2026-07-20 11:11:03.957452+00	archived	\N	77	10.00	2026-07-21
4dcc3819-424c-4d09-9482-91ed2d9d19ab	f8562903-2445-41dd-8533-332858c954d2	\N	f389ffea-b5f1-4132-9c04-337ebb4ab8fd	58d048c0-3e97-449e-bb15-1a8b9a558017	به‌روزرسانی کتابخانه‌های وابسته #51	\N	medium	2026-08-08	ec81e733-41e1-42f0-ada8-f4cebc1d0f84	2026-07-20 11:11:03.957452+00	2026-07-20 11:11:03.957452+00	in_progress	\N	32	36.40	2026-07-29
4dcc3819-424c-4d09-9482-91ed2d9d19ab	f8562903-2445-41dd-8533-332858c954d2	\N	4e1eb7bb-aea1-4b26-aa51-fef3ea6cbab8	58d048c0-3e97-449e-bb15-1a8b9a558017	بازنویسی ماژول اعلان‌ها #52	\N	medium	2026-07-06	24d24ae1-f087-4a56-b32c-039e830ed55b	2026-07-20 11:11:03.957452+00	2026-07-20 11:11:03.957452+00	todo	\N	5	2.10	2026-06-21
4dcc3819-424c-4d09-9482-91ed2d9d19ab	f8562903-2445-41dd-8533-332858c954d2	\N	4e1eb7bb-aea1-4b26-aa51-fef3ea6cbab8	58d048c0-3e97-449e-bb15-1a8b9a558017	بهینه‌سازی کوئری‌های گزارش‌گیری #53	\N	high	2026-08-05	b9a81bf0-8a91-4fcc-b387-114579330a4d	2026-07-20 11:11:03.957452+00	2026-07-20 11:11:03.957452+00	todo	\N	56	23.00	2026-07-26
4dcc3819-424c-4d09-9482-91ed2d9d19ab	f8562903-2445-41dd-8533-332858c954d2	\N	3e5a2e9c-b250-4896-900f-d75ee290635f	58d048c0-3e97-449e-bb15-1a8b9a558017	به‌روزرسانی کتابخانه‌های وابسته #54	\N	low	2026-06-26	ff5d59a9-5277-4b7e-9145-24366772bbcb	2026-07-20 11:11:03.957452+00	2026-07-20 11:11:03.957452+00	completed	approved	100	33.70	2026-06-20
4dcc3819-424c-4d09-9482-91ed2d9d19ab	214b156f-50e6-48ca-9d63-554205decf98	\N	4116e390-3789-4721-9e7b-133ebb2764c7	58d048c0-3e97-449e-bb15-1a8b9a558017	طراحی API نسخهٔ دوم #55	\N	medium	2026-06-27	5f439b6e-ca55-4e47-940d-e4445b7cd907	2026-07-20 11:11:03.957452+00	2026-07-20 11:11:03.957452+00	completed	approved	100	36.20	2026-06-24
4dcc3819-424c-4d09-9482-91ed2d9d19ab	214b156f-50e6-48ca-9d63-554205decf98	\N	4e1eb7bb-aea1-4b26-aa51-fef3ea6cbab8	58d048c0-3e97-449e-bb15-1a8b9a558017	افزودن تست واحد برای سرویس کاربران #56	\N	high	2026-08-25	80199940-d404-420d-af80-f5187e69541b	2026-07-20 11:11:03.957452+00	2026-07-20 11:11:03.957452+00	todo	\N	31	27.30	2026-08-12
4dcc3819-424c-4d09-9482-91ed2d9d19ab	214b156f-50e6-48ca-9d63-554205decf98	\N	f389ffea-b5f1-4132-9c04-337ebb4ab8fd	58d048c0-3e97-449e-bb15-1a8b9a558017	پیاده‌سازی صفحهٔ داشبورد مدیریتی #57	\N	high	2026-08-05	6ce4f48b-e6a2-44a9-8b08-7fcda5aff47e	2026-07-20 11:11:03.957452+00	2026-07-20 11:11:03.957452+00	archived	\N	19	37.20	2026-07-21
4dcc3819-424c-4d09-9482-91ed2d9d19ab	214b156f-50e6-48ca-9d63-554205decf98	\N	8e57ec64-12f7-4c1b-809e-977233cf374f	58d048c0-3e97-449e-bb15-1a8b9a558017	افزودن قابلیت جست‌وجوی پیشرفته #58	\N	medium	2026-08-13	99d5d096-3f37-490e-b83e-c78c0168f03d	2026-07-20 11:11:03.957452+00	2026-07-20 11:11:03.957452+00	todo	\N	3	8.80	2026-08-06
4dcc3819-424c-4d09-9482-91ed2d9d19ab	214b156f-50e6-48ca-9d63-554205decf98	\N	f389ffea-b5f1-4132-9c04-337ebb4ab8fd	58d048c0-3e97-449e-bb15-1a8b9a558017	طراحی API نسخهٔ دوم #59	\N	low	2026-08-15	0d1597b7-a56f-4790-bce9-2656a3b77ef9	2026-07-20 11:11:03.957452+00	2026-07-20 11:11:03.957452+00	in_progress	\N	13	16.50	2026-08-06
4dcc3819-424c-4d09-9482-91ed2d9d19ab	214b156f-50e6-48ca-9d63-554205decf98	\N	58d048c0-3e97-449e-bb15-1a8b9a558017	58d048c0-3e97-449e-bb15-1a8b9a558017	رفع مشکل کندی بارگذاری صفحه #60	\N	medium	2026-08-23	414ebf0c-90f2-40c0-a4dc-d85dbca9851b	2026-07-20 11:11:03.957452+00	2026-07-20 11:11:03.957452+00	completed	approved	100	33.20	2026-08-07
4dcc3819-424c-4d09-9482-91ed2d9d19ab	214b156f-50e6-48ca-9d63-554205decf98	\N	4e1eb7bb-aea1-4b26-aa51-fef3ea6cbab8	58d048c0-3e97-449e-bb15-1a8b9a558017	تنظیم پایپ‌لاین CI/CD #61	\N	low	2026-07-02	20f513d2-eb38-4f39-9bdf-7b2f8fe69264	2026-07-20 11:11:03.957452+00	2026-07-20 11:11:03.957452+00	in_progress	\N	51	14.50	2026-06-30
4dcc3819-424c-4d09-9482-91ed2d9d19ab	214b156f-50e6-48ca-9d63-554205decf98	\N	4e1eb7bb-aea1-4b26-aa51-fef3ea6cbab8	58d048c0-3e97-449e-bb15-1a8b9a558017	رفع مشکل کندی بارگذاری صفحه #62	\N	high	2026-08-14	1e87ca6b-643c-497c-b7f1-dca0e1d50492	2026-07-20 11:11:03.957452+00	2026-07-20 11:11:03.957452+00	todo	\N	65	17.20	2026-08-04
4dcc3819-424c-4d09-9482-91ed2d9d19ab	214b156f-50e6-48ca-9d63-554205decf98	\N	4e1eb7bb-aea1-4b26-aa51-fef3ea6cbab8	58d048c0-3e97-449e-bb15-1a8b9a558017	افزودن قابلیت جست‌وجوی پیشرفته #63	\N	medium	2026-06-22	f2a29250-9347-4db0-b5c4-c3681dd78778	2026-07-20 11:11:03.957452+00	2026-07-20 11:11:03.957452+00	completed	approved	100	8.80	2026-06-17
4dcc3819-424c-4d09-9482-91ed2d9d19ab	214b156f-50e6-48ca-9d63-554205decf98	\N	f389ffea-b5f1-4132-9c04-337ebb4ab8fd	58d048c0-3e97-449e-bb15-1a8b9a558017	پیاده‌سازی احراز هویت دومرحله‌ای #64	\N	medium	2026-07-13	f9695abb-a891-4c06-b612-09b4cbe7a1b9	2026-07-20 11:11:03.957452+00	2026-07-20 11:11:03.957452+00	todo	\N	40	18.60	2026-06-22
4dcc3819-424c-4d09-9482-91ed2d9d19ab	214b156f-50e6-48ca-9d63-554205decf98	\N	4116e390-3789-4721-9e7b-133ebb2764c7	58d048c0-3e97-449e-bb15-1a8b9a558017	افزودن تست واحد برای سرویس کاربران #65	\N	medium	2026-07-30	ddfa78be-9e11-4bb1-84c7-11db7d4fe457	2026-07-20 11:11:03.957452+00	2026-07-20 11:11:03.957452+00	todo	\N	5	28.90	2026-07-10
4dcc3819-424c-4d09-9482-91ed2d9d19ab	214b156f-50e6-48ca-9d63-554205decf98	\N	58d048c0-3e97-449e-bb15-1a8b9a558017	58d048c0-3e97-449e-bb15-1a8b9a558017	رفع مشکل کندی بارگذاری صفحه #66	\N	medium	2026-07-28	ad787218-bf1f-42b7-b988-4f20fe979b93	2026-07-20 11:11:03.957452+00	2026-07-20 11:11:03.957452+00	completed	rejected	100	4.70	2026-07-20
4dcc3819-424c-4d09-9482-91ed2d9d19ab	214b156f-50e6-48ca-9d63-554205decf98	\N	9e42561d-3de1-44eb-b7ec-5207ea857b8e	58d048c0-3e97-449e-bb15-1a8b9a558017	تنظیم پایپ‌لاین CI/CD #67	\N	low	2026-08-06	a4e9ffd5-5b27-486f-8b95-691e1c20d507	2026-07-20 11:11:03.957452+00	2026-07-20 11:11:03.957452+00	in_progress	\N	38	21.30	2026-07-25
4dcc3819-424c-4d09-9482-91ed2d9d19ab	214b156f-50e6-48ca-9d63-554205decf98	\N	9e42561d-3de1-44eb-b7ec-5207ea857b8e	58d048c0-3e97-449e-bb15-1a8b9a558017	نوشتن مستندات فنی API #68	\N	medium	2026-07-20	0b73e38e-9439-43c6-8d29-aa6b9d66e233	2026-07-20 11:11:03.957452+00	2026-07-20 11:11:03.957452+00	in_progress	\N	70	6.80	2026-07-06
4dcc3819-424c-4d09-9482-91ed2d9d19ab	214b156f-50e6-48ca-9d63-554205decf98	\N	3e5a2e9c-b250-4896-900f-d75ee290635f	58d048c0-3e97-449e-bb15-1a8b9a558017	پیاده‌سازی صفحهٔ داشبورد مدیریتی #69	\N	high	2026-08-05	80971038-4c3c-4f6a-966b-8f4cbd9b3188	2026-07-20 11:11:03.957452+00	2026-07-20 11:11:03.957452+00	completed	rejected	100	13.40	2026-07-29
4dcc3819-424c-4d09-9482-91ed2d9d19ab	214b156f-50e6-48ca-9d63-554205decf98	\N	4116e390-3789-4721-9e7b-133ebb2764c7	58d048c0-3e97-449e-bb15-1a8b9a558017	افزودن تست واحد برای سرویس کاربران #70	\N	medium	2026-07-16	a23e7819-5e91-4755-9cb2-535bf3ef67c0	2026-07-20 11:11:03.957452+00	2026-07-20 11:11:03.957452+00	todo	\N	74	25.10	2026-07-05
4dcc3819-424c-4d09-9482-91ed2d9d19ab	214b156f-50e6-48ca-9d63-554205decf98	\N	f389ffea-b5f1-4132-9c04-337ebb4ab8fd	58d048c0-3e97-449e-bb15-1a8b9a558017	به‌روزرسانی کتابخانه‌های وابسته #71	\N	medium	2026-08-06	dd2ff5b7-7aa5-48bd-b02b-902b7177ea2c	2026-07-20 11:11:03.957452+00	2026-07-20 11:11:03.957452+00	completed	approved	100	32.20	2026-07-29
4dcc3819-424c-4d09-9482-91ed2d9d19ab	214b156f-50e6-48ca-9d63-554205decf98	\N	4e1eb7bb-aea1-4b26-aa51-fef3ea6cbab8	58d048c0-3e97-449e-bb15-1a8b9a558017	طراحی API نسخهٔ دوم #72	\N	high	2026-06-30	6954f2dd-0251-4bf5-806c-647dfee4c2a3	2026-07-20 11:11:03.957452+00	2026-07-20 11:11:03.957452+00	archived	\N	79	14.70	2026-06-26
4dcc3819-424c-4d09-9482-91ed2d9d19ab	4d9d9007-cc28-40b2-824e-fb736a37db5d	\N	4e1eb7bb-aea1-4b26-aa51-fef3ea6cbab8	58d048c0-3e97-449e-bb15-1a8b9a558017	افزودن تست واحد برای سرویس کاربران #73	\N	low	2026-07-12	0c4959e2-b421-4279-948e-2f045486b756	2026-07-20 11:11:03.957452+00	2026-07-20 11:11:03.957452+00	archived	\N	18	2.90	2026-07-01
4dcc3819-424c-4d09-9482-91ed2d9d19ab	4d9d9007-cc28-40b2-824e-fb736a37db5d	\N	8e57ec64-12f7-4c1b-809e-977233cf374f	58d048c0-3e97-449e-bb15-1a8b9a558017	بررسی و رفع آسیب‌پذیری امنیتی #74	\N	medium	2026-08-08	855d2285-59ca-47b2-9407-c0409145ce50	2026-07-20 11:11:03.957452+00	2026-07-20 11:11:03.957452+00	completed	pending	100	35.70	2026-08-04
4dcc3819-424c-4d09-9482-91ed2d9d19ab	4d9d9007-cc28-40b2-824e-fb736a37db5d	\N	4116e390-3789-4721-9e7b-133ebb2764c7	58d048c0-3e97-449e-bb15-1a8b9a558017	بررسی و رفع آسیب‌پذیری امنیتی #75	\N	medium	2026-08-14	163bde10-0c51-4e26-ad57-bb2b36c92ac2	2026-07-20 11:11:03.957452+00	2026-07-20 11:11:03.957452+00	todo	\N	31	7.60	2026-07-31
4dcc3819-424c-4d09-9482-91ed2d9d19ab	4d9d9007-cc28-40b2-824e-fb736a37db5d	\N	9e42561d-3de1-44eb-b7ec-5207ea857b8e	58d048c0-3e97-449e-bb15-1a8b9a558017	رفع مشکل ناسازگاری مرورگر #76	\N	medium	2026-08-17	1b51a2c7-6085-495b-bf94-53ba1aa36c3f	2026-07-20 11:11:03.957452+00	2026-07-20 11:11:03.957452+00	todo	\N	28	8.70	2026-08-12
4dcc3819-424c-4d09-9482-91ed2d9d19ab	4d9d9007-cc28-40b2-824e-fb736a37db5d	\N	9e42561d-3de1-44eb-b7ec-5207ea857b8e	58d048c0-3e97-449e-bb15-1a8b9a558017	افزودن قابلیت جست‌وجوی پیشرفته #77	\N	low	2026-07-30	15538d48-77b6-40ca-b42f-ad1c0f3e658f	2026-07-20 11:11:03.957452+00	2026-07-20 11:11:03.957452+00	completed	approved	100	19.30	2026-07-21
4dcc3819-424c-4d09-9482-91ed2d9d19ab	4d9d9007-cc28-40b2-824e-fb736a37db5d	\N	4e1eb7bb-aea1-4b26-aa51-fef3ea6cbab8	58d048c0-3e97-449e-bb15-1a8b9a558017	رفع مشکل کندی بارگذاری صفحه #78	\N	medium	2026-08-11	9699666d-497d-49a1-965d-a3e801fe3e34	2026-07-20 11:11:03.957452+00	2026-07-20 11:11:03.957452+00	completed	pending	100	25.30	2026-07-21
4dcc3819-424c-4d09-9482-91ed2d9d19ab	4d9d9007-cc28-40b2-824e-fb736a37db5d	\N	9e42561d-3de1-44eb-b7ec-5207ea857b8e	58d048c0-3e97-449e-bb15-1a8b9a558017	بررسی و رفع آسیب‌پذیری امنیتی #79	\N	low	2026-09-01	1765fe65-38a3-4319-84cb-0a304a7bcf4a	2026-07-20 11:11:03.957452+00	2026-07-20 11:11:03.957452+00	completed	approved	100	30.30	2026-08-13
4dcc3819-424c-4d09-9482-91ed2d9d19ab	4d9d9007-cc28-40b2-824e-fb736a37db5d	\N	3e5a2e9c-b250-4896-900f-d75ee290635f	58d048c0-3e97-449e-bb15-1a8b9a558017	رفع مشکل ناسازگاری مرورگر #80	\N	high	2026-07-11	3b8065cd-483f-45e3-99e2-084c54f653c3	2026-07-20 11:11:03.957452+00	2026-07-20 11:11:03.957452+00	completed	approved	100	20.40	2026-07-01
4dcc3819-424c-4d09-9482-91ed2d9d19ab	4d9d9007-cc28-40b2-824e-fb736a37db5d	\N	8e57ec64-12f7-4c1b-809e-977233cf374f	58d048c0-3e97-449e-bb15-1a8b9a558017	نوشتن مستندات فنی API #81	\N	medium	2026-07-18	0b8db4ab-811f-4ab6-b1c7-e71bb53bd559	2026-07-20 11:11:03.957452+00	2026-07-20 11:11:03.957452+00	in_progress	\N	30	12.30	2026-07-14
4dcc3819-424c-4d09-9482-91ed2d9d19ab	4d9d9007-cc28-40b2-824e-fb736a37db5d	\N	f389ffea-b5f1-4132-9c04-337ebb4ab8fd	58d048c0-3e97-449e-bb15-1a8b9a558017	پیاده‌سازی احراز هویت دومرحله‌ای #82	\N	high	2026-07-04	56694b66-b299-4d6c-9f06-5074c2a9c9c5	2026-07-20 11:11:03.957452+00	2026-07-20 11:11:03.957452+00	completed	approved	100	7.80	2026-06-25
4dcc3819-424c-4d09-9482-91ed2d9d19ab	4d9d9007-cc28-40b2-824e-fb736a37db5d	\N	8e57ec64-12f7-4c1b-809e-977233cf374f	58d048c0-3e97-449e-bb15-1a8b9a558017	رفع مشکل کندی بارگذاری صفحه #83	\N	high	2026-07-27	1192afc3-16d2-4c56-8889-e2146b6f9460	2026-07-20 11:11:03.957452+00	2026-07-20 11:11:03.957452+00	todo	\N	59	17.80	2026-07-12
4dcc3819-424c-4d09-9482-91ed2d9d19ab	4d9d9007-cc28-40b2-824e-fb736a37db5d	\N	8e57ec64-12f7-4c1b-809e-977233cf374f	58d048c0-3e97-449e-bb15-1a8b9a558017	نوشتن مستندات فنی API #84	\N	low	2026-07-30	d0d410b3-9bdc-498e-836b-dd7dc503463b	2026-07-20 11:11:03.957452+00	2026-07-20 11:11:03.957452+00	in_progress	\N	73	16.50	2026-07-10
4dcc3819-424c-4d09-9482-91ed2d9d19ab	4d9d9007-cc28-40b2-824e-fb736a37db5d	\N	58d048c0-3e97-449e-bb15-1a8b9a558017	58d048c0-3e97-449e-bb15-1a8b9a558017	بازنویسی ماژول اعلان‌ها #85	\N	medium	2026-07-19	a96a176d-19be-4ccf-a41e-a8f0ea9c2415	2026-07-20 11:11:03.957452+00	2026-07-20 11:11:03.957452+00	in_progress	\N	68	30.40	2026-07-05
4dcc3819-424c-4d09-9482-91ed2d9d19ab	4d9d9007-cc28-40b2-824e-fb736a37db5d	\N	4116e390-3789-4721-9e7b-133ebb2764c7	58d048c0-3e97-449e-bb15-1a8b9a558017	طراحی API نسخهٔ دوم #86	\N	medium	2026-07-26	d1e307f4-2aba-46ec-a922-ebc3f6a0972e	2026-07-20 11:11:03.957452+00	2026-07-20 11:11:03.957452+00	completed	pending	100	20.50	2026-07-17
4dcc3819-424c-4d09-9482-91ed2d9d19ab	4d9d9007-cc28-40b2-824e-fb736a37db5d	\N	3e5a2e9c-b250-4896-900f-d75ee290635f	58d048c0-3e97-449e-bb15-1a8b9a558017	نوشتن مستندات فنی API #87	\N	low	2026-08-11	98f6a260-5501-43a6-9420-5fe004f8382f	2026-07-20 11:11:03.957452+00	2026-07-20 11:11:03.957452+00	in_progress	\N	59	36.90	2026-07-28
4dcc3819-424c-4d09-9482-91ed2d9d19ab	4d9d9007-cc28-40b2-824e-fb736a37db5d	\N	4116e390-3789-4721-9e7b-133ebb2764c7	58d048c0-3e97-449e-bb15-1a8b9a558017	پیاده‌سازی صفحهٔ داشبورد مدیریتی #88	\N	high	2026-07-31	51b5543a-f91a-4a79-9d5e-ee9f8d59b2ac	2026-07-20 11:11:03.957452+00	2026-07-20 11:11:03.957452+00	completed	approved	100	3.00	2026-07-11
4dcc3819-424c-4d09-9482-91ed2d9d19ab	4d9d9007-cc28-40b2-824e-fb736a37db5d	\N	9e42561d-3de1-44eb-b7ec-5207ea857b8e	58d048c0-3e97-449e-bb15-1a8b9a558017	بهینه‌سازی کوئری‌های گزارش‌گیری #89	\N	low	2026-07-10	1b5eb279-8948-469a-9ade-ab09eb96c59f	2026-07-20 11:11:03.957452+00	2026-07-20 11:11:03.957452+00	in_progress	\N	33	16.40	2026-06-24
4dcc3819-424c-4d09-9482-91ed2d9d19ab	4d9d9007-cc28-40b2-824e-fb736a37db5d	\N	8e57ec64-12f7-4c1b-809e-977233cf374f	58d048c0-3e97-449e-bb15-1a8b9a558017	طراحی API نسخهٔ دوم #90	\N	medium	2026-08-17	41844556-16e8-421e-b0dd-d479ce333c01	2026-07-20 11:11:03.957452+00	2026-07-20 11:11:03.957452+00	completed	approved	100	11.60	2026-08-03
4dcc3819-424c-4d09-9482-91ed2d9d19ab	\N	\N	58d048c0-3e97-449e-bb15-1a8b9a558017	58d048c0-3e97-449e-bb15-1a8b9a558017	رفع مشکل کندی بارگذاری صفحه #91	\N	low	2026-07-23	03f22f85-a10c-431b-800b-956d97662ed4	2026-07-20 11:11:03.957452+00	2026-07-20 11:11:03.957452+00	completed	approved	100	26.70	2026-07-20
4dcc3819-424c-4d09-9482-91ed2d9d19ab	\N	\N	4e1eb7bb-aea1-4b26-aa51-fef3ea6cbab8	4e1eb7bb-aea1-4b26-aa51-fef3ea6cbab8	افزودن تست واحد برای سرویس کاربران #92	\N	low	2026-06-26	c3d67987-9825-46de-92ba-83f93768e76f	2026-07-20 11:11:03.957452+00	2026-07-20 11:11:03.957452+00	completed	approved	100	25.60	2026-06-17
4dcc3819-424c-4d09-9482-91ed2d9d19ab	\N	\N	8e57ec64-12f7-4c1b-809e-977233cf374f	8e57ec64-12f7-4c1b-809e-977233cf374f	پیاده‌سازی صفحهٔ داشبورد مدیریتی #93	\N	low	2026-07-21	89e2ec38-78b9-4ebf-b09e-094e39072451	2026-07-20 11:11:03.957452+00	2026-07-20 11:11:03.957452+00	todo	\N	59	28.60	2026-07-16
4dcc3819-424c-4d09-9482-91ed2d9d19ab	\N	\N	4e1eb7bb-aea1-4b26-aa51-fef3ea6cbab8	4e1eb7bb-aea1-4b26-aa51-fef3ea6cbab8	پیاده‌سازی صفحهٔ داشبورد مدیریتی #94	\N	high	2026-07-17	2c550f66-5a3b-4135-9fe8-ac0d81b6cc98	2026-07-20 11:11:03.957452+00	2026-07-20 11:11:03.957452+00	in_progress	\N	14	31.60	2026-06-26
4dcc3819-424c-4d09-9482-91ed2d9d19ab	\N	\N	8e57ec64-12f7-4c1b-809e-977233cf374f	8e57ec64-12f7-4c1b-809e-977233cf374f	رفع باگ در ماژول پرداخت #95	\N	medium	2026-07-12	e30aa10a-829a-4795-8592-d6db33b4c807	2026-07-20 11:11:03.957452+00	2026-07-20 11:11:03.957452+00	in_progress	\N	73	27.70	2026-06-22
4dcc3819-424c-4d09-9482-91ed2d9d19ab	\N	\N	3e5a2e9c-b250-4896-900f-d75ee290635f	3e5a2e9c-b250-4896-900f-d75ee290635f	پیاده‌سازی صفحهٔ ورود جدید #96	\N	high	2026-08-23	7b4e1236-081c-476d-a492-7be52cd39761	2026-07-20 11:11:03.957452+00	2026-07-20 11:11:03.957452+00	in_progress	\N	80	11.20	2026-08-15
4dcc3819-424c-4d09-9482-91ed2d9d19ab	\N	\N	9e42561d-3de1-44eb-b7ec-5207ea857b8e	9e42561d-3de1-44eb-b7ec-5207ea857b8e	رفع مشکل ناسازگاری مرورگر #97	\N	low	2026-07-26	98e40777-9073-4b40-9006-6134c8fde7f0	2026-07-20 11:11:03.957452+00	2026-07-20 11:11:03.957452+00	archived	\N	72	31.70	2026-07-05
4dcc3819-424c-4d09-9482-91ed2d9d19ab	\N	\N	f389ffea-b5f1-4132-9c04-337ebb4ab8fd	f389ffea-b5f1-4132-9c04-337ebb4ab8fd	به‌روزرسانی کتابخانه‌های وابسته #98	\N	high	2026-07-13	49c5ec8a-ed77-4dee-93ed-b29a0296fa1d	2026-07-20 11:11:03.957452+00	2026-07-20 11:11:03.957452+00	completed	approved	100	15.00	2026-07-09
4dcc3819-424c-4d09-9482-91ed2d9d19ab	\N	\N	4e1eb7bb-aea1-4b26-aa51-fef3ea6cbab8	4e1eb7bb-aea1-4b26-aa51-fef3ea6cbab8	پیاده‌سازی صفحهٔ ورود جدید #99	\N	medium	2026-08-24	454ec199-92d1-4ed3-afd6-72b65613f24a	2026-07-20 11:11:03.957452+00	2026-07-20 11:11:03.957452+00	in_progress	\N	46	26.20	2026-08-07
4dcc3819-424c-4d09-9482-91ed2d9d19ab	\N	\N	4e1eb7bb-aea1-4b26-aa51-fef3ea6cbab8	4e1eb7bb-aea1-4b26-aa51-fef3ea6cbab8	نوشتن مستندات فنی API #100	\N	high	2026-07-20	c6bdf432-d244-492d-8d81-83bd786fd648	2026-07-20 11:11:03.957452+00	2026-07-20 11:11:03.957452+00	completed	pending	100	38.70	2026-07-13
4dcc3819-424c-4d09-9482-91ed2d9d19ab	\N	\N	f389ffea-b5f1-4132-9c04-337ebb4ab8fd	f389ffea-b5f1-4132-9c04-337ebb4ab8fd	بررسی و رفع آسیب‌پذیری امنیتی #101	\N	medium	2026-08-06	fd4afb56-0db1-4b7b-b9ed-58ffc447b05e	2026-07-20 11:11:03.957452+00	2026-07-20 11:11:03.957452+00	completed	pending	100	33.40	2026-07-20
4dcc3819-424c-4d09-9482-91ed2d9d19ab	\N	\N	4116e390-3789-4721-9e7b-133ebb2764c7	4116e390-3789-4721-9e7b-133ebb2764c7	بازنویسی ماژول اعلان‌ها #102	\N	low	2026-07-15	79da9908-b132-4564-8ae4-c0e1d5975bad	2026-07-20 11:11:03.957452+00	2026-07-20 11:11:03.957452+00	in_progress	\N	35	35.50	2026-07-06
4dcc3819-424c-4d09-9482-91ed2d9d19ab	\N	\N	8e57ec64-12f7-4c1b-809e-977233cf374f	8e57ec64-12f7-4c1b-809e-977233cf374f	پیاده‌سازی صفحهٔ داشبورد مدیریتی #103	\N	high	2026-08-04	a345604f-149e-40a0-9986-fec8f163a165	2026-07-20 11:11:03.957452+00	2026-07-20 11:11:03.957452+00	archived	\N	48	14.80	2026-07-15
4dcc3819-424c-4d09-9482-91ed2d9d19ab	\N	\N	3e5a2e9c-b250-4896-900f-d75ee290635f	3e5a2e9c-b250-4896-900f-d75ee290635f	افزودن تست واحد برای سرویس کاربران #104	\N	medium	2026-07-14	dac4cdff-7502-4321-8aaa-490cc0edc9c4	2026-07-20 11:11:03.957452+00	2026-07-20 11:11:03.957452+00	in_progress	\N	33	14.90	2026-06-27
4dcc3819-424c-4d09-9482-91ed2d9d19ab	\N	\N	4116e390-3789-4721-9e7b-133ebb2764c7	4116e390-3789-4721-9e7b-133ebb2764c7	به‌روزرسانی کتابخانه‌های وابسته #105	\N	low	2026-07-23	b0a43c5a-f449-4ee6-aeee-cbe2c09d6dee	2026-07-20 11:11:03.957452+00	2026-07-20 11:11:03.957452+00	completed	pending	100	5.30	2026-07-21
4dcc3819-424c-4d09-9482-91ed2d9d19ab	47a3c135-ac0c-4015-a4f1-c962c169c55b	\N	5742bab4-624b-41df-aff7-c3517eed7f4c	5e03da3d-4fd1-4305-91ec-8a61bd1f28ee	پیگیری بیمهٔ کارکنان #1	\N	high	2026-08-13	8ef2345a-0678-4890-902c-646543f64def	2026-07-20 11:11:03.957452+00	2026-07-20 11:11:03.957452+00	in_progress	\N	42	12.40	2026-08-10
4dcc3819-424c-4d09-9482-91ed2d9d19ab	47a3c135-ac0c-4015-a4f1-c962c169c55b	\N	d7465638-ca92-4b34-b9b1-b1ab5012de48	5e03da3d-4fd1-4305-91ec-8a61bd1f28ee	تهیهٔ گزارش جریان نقدی #2	\N	medium	2026-07-27	a60512a6-dde5-455c-a1e8-e1f0e2ffc9d1	2026-07-20 11:11:03.957452+00	2026-07-20 11:11:03.957452+00	in_progress	\N	49	14.90	2026-07-13
4dcc3819-424c-4d09-9482-91ed2d9d19ab	47a3c135-ac0c-4015-a4f1-c962c169c55b	\N	24baa76f-b9d0-4a8f-b28d-605d780d066a	5e03da3d-4fd1-4305-91ec-8a61bd1f28ee	پیگیری مطالبات معوق مشتریان #3	\N	low	2026-07-27	2c3ed8a1-74f1-46ef-9367-2ccff0d29774	2026-07-20 11:11:03.957452+00	2026-07-20 11:11:03.957452+00	completed	pending	100	29.60	2026-07-09
4dcc3819-424c-4d09-9482-91ed2d9d19ab	47a3c135-ac0c-4015-a4f1-c962c169c55b	\N	5e03da3d-4fd1-4305-91ec-8a61bd1f28ee	5e03da3d-4fd1-4305-91ec-8a61bd1f28ee	تهیهٔ پیش‌نویس بودجهٔ واحد #4	\N	medium	2026-08-14	5b6eaf97-2d21-40ba-92f0-4ece740c2f33	2026-07-20 11:11:03.957452+00	2026-07-20 11:11:03.957452+00	completed	pending	100	14.20	2026-08-07
4dcc3819-424c-4d09-9482-91ed2d9d19ab	47a3c135-ac0c-4015-a4f1-c962c169c55b	\N	5e03da3d-4fd1-4305-91ec-8a61bd1f28ee	5e03da3d-4fd1-4305-91ec-8a61bd1f28ee	پیگیری مطالبات معوق مشتریان #5	\N	medium	2026-08-08	a6a64efd-3c9a-4ef7-9fc9-a8ee6c45291c	2026-07-20 11:11:03.957452+00	2026-07-20 11:11:03.957452+00	in_progress	\N	77	29.30	2026-07-28
4dcc3819-424c-4d09-9482-91ed2d9d19ab	47a3c135-ac0c-4015-a4f1-c962c169c55b	\N	24baa76f-b9d0-4a8f-b28d-605d780d066a	5e03da3d-4fd1-4305-91ec-8a61bd1f28ee	تهیهٔ گزارش جریان نقدی #6	\N	medium	2026-07-17	374052cc-557f-47d5-af6c-38c510f484c3	2026-07-20 11:11:03.957452+00	2026-07-20 11:11:03.957452+00	completed	approved	100	25.40	2026-07-14
4dcc3819-424c-4d09-9482-91ed2d9d19ab	47a3c135-ac0c-4015-a4f1-c962c169c55b	\N	8d97ee0b-e8f3-4aec-ab48-db76ef6ede39	5e03da3d-4fd1-4305-91ec-8a61bd1f28ee	تهیهٔ گزارش سود و زیان ماهانه #7	\N	high	2026-07-29	f4986501-dbb0-48b2-bbcf-2138979d2750	2026-07-20 11:11:03.957452+00	2026-07-20 11:11:03.957452+00	in_progress	\N	51	15.80	2026-07-26
4dcc3819-424c-4d09-9482-91ed2d9d19ab	47a3c135-ac0c-4015-a4f1-c962c169c55b	\N	d7465638-ca92-4b34-b9b1-b1ab5012de48	5e03da3d-4fd1-4305-91ec-8a61bd1f28ee	بررسی و تأیید صورت‌حساب‌های خرید #8	\N	low	2026-08-05	0291ddd2-9393-4f9b-80d8-73030877a22f	2026-07-20 11:11:03.957452+00	2026-07-20 11:11:03.957452+00	archived	\N	77	27.80	2026-07-29
4dcc3819-424c-4d09-9482-91ed2d9d19ab	47a3c135-ac0c-4015-a4f1-c962c169c55b	\N	8d97ee0b-e8f3-4aec-ab48-db76ef6ede39	5e03da3d-4fd1-4305-91ec-8a61bd1f28ee	ثبت اسناد حسابداری هفتگی #9	\N	high	2026-06-28	2e0b68b8-950c-4d16-940f-f565d114a515	2026-07-20 11:11:03.957452+00	2026-07-20 11:11:03.957452+00	todo	\N	46	15.80	2026-06-24
4dcc3819-424c-4d09-9482-91ed2d9d19ab	47a3c135-ac0c-4015-a4f1-c962c169c55b	\N	7a6ee833-86b5-4c74-a2b1-845608f4fbab	5e03da3d-4fd1-4305-91ec-8a61bd1f28ee	تطبیق موجودی انبار با حساب‌ها #10	\N	medium	2026-07-30	f38a2778-0a3b-46fd-b659-44a94071a278	2026-07-20 11:11:03.957452+00	2026-07-20 11:11:03.957452+00	todo	\N	47	16.10	2026-07-24
4dcc3819-424c-4d09-9482-91ed2d9d19ab	47a3c135-ac0c-4015-a4f1-c962c169c55b	\N	d7465638-ca92-4b34-b9b1-b1ab5012de48	5e03da3d-4fd1-4305-91ec-8a61bd1f28ee	تهیهٔ پیش‌نویس بودجهٔ واحد #11	\N	medium	2026-07-28	fa91054c-ae8e-4cd3-a874-f982b3e311b5	2026-07-20 11:11:03.957452+00	2026-07-20 11:11:03.957452+00	todo	\N	50	13.90	2026-07-22
4dcc3819-424c-4d09-9482-91ed2d9d19ab	47a3c135-ac0c-4015-a4f1-c962c169c55b	\N	5742bab4-624b-41df-aff7-c3517eed7f4c	5e03da3d-4fd1-4305-91ec-8a61bd1f28ee	تهیهٔ گزارش جریان نقدی #12	\N	low	2026-06-25	62a933f4-b7dd-4c44-9e60-ab32c94aaf91	2026-07-20 11:11:03.957452+00	2026-07-20 11:11:03.957452+00	in_progress	\N	63	21.70	2026-06-23
4dcc3819-424c-4d09-9482-91ed2d9d19ab	47a3c135-ac0c-4015-a4f1-c962c169c55b	\N	7a6ee833-86b5-4c74-a2b1-845608f4fbab	5e03da3d-4fd1-4305-91ec-8a61bd1f28ee	تهیهٔ گزارش جریان نقدی #13	\N	medium	2026-07-12	0bc10e76-060d-4058-8ee8-9d353ef644b3	2026-07-20 11:11:03.957452+00	2026-07-20 11:11:03.957452+00	todo	\N	27	39.90	2026-07-02
4dcc3819-424c-4d09-9482-91ed2d9d19ab	47a3c135-ac0c-4015-a4f1-c962c169c55b	\N	5742bab4-624b-41df-aff7-c3517eed7f4c	5e03da3d-4fd1-4305-91ec-8a61bd1f28ee	تهیهٔ گزارش سود و زیان ماهانه #14	\N	low	2026-07-25	07e8d1d2-7b8b-47d8-9e11-c3ee334e1772	2026-07-20 11:11:03.957452+00	2026-07-20 11:11:03.957452+00	completed	rejected	100	34.40	2026-07-17
4dcc3819-424c-4d09-9482-91ed2d9d19ab	47a3c135-ac0c-4015-a4f1-c962c169c55b	\N	8d97ee0b-e8f3-4aec-ab48-db76ef6ede39	5e03da3d-4fd1-4305-91ec-8a61bd1f28ee	تهیهٔ گزارش سود و زیان ماهانه #15	\N	high	2026-08-28	bf3d9d70-8050-4aba-a324-a0e636e7651e	2026-07-20 11:11:03.957452+00	2026-07-20 11:11:03.957452+00	todo	\N	40	27.40	2026-08-12
4dcc3819-424c-4d09-9482-91ed2d9d19ab	47a3c135-ac0c-4015-a4f1-c962c169c55b	\N	8e78a4d9-50d5-40e6-bcd8-fd3f57c31286	5e03da3d-4fd1-4305-91ec-8a61bd1f28ee	پیگیری مطالبات معوق مشتریان #16	\N	medium	2026-08-09	7a0b213b-573f-42a5-830f-476094541b5c	2026-07-20 11:11:03.957452+00	2026-07-20 11:11:03.957452+00	todo	\N	20	29.00	2026-07-21
4dcc3819-424c-4d09-9482-91ed2d9d19ab	47a3c135-ac0c-4015-a4f1-c962c169c55b	\N	8e78a4d9-50d5-40e6-bcd8-fd3f57c31286	5e03da3d-4fd1-4305-91ec-8a61bd1f28ee	ثبت اسناد حسابداری هفتگی #17	\N	low	2026-07-27	b1edd6ea-7be8-45ab-8b20-37f7fdebcff2	2026-07-20 11:11:03.957452+00	2026-07-20 11:11:03.957452+00	completed	approved	100	39.40	2026-07-09
4dcc3819-424c-4d09-9482-91ed2d9d19ab	47a3c135-ac0c-4015-a4f1-c962c169c55b	\N	d7465638-ca92-4b34-b9b1-b1ab5012de48	5e03da3d-4fd1-4305-91ec-8a61bd1f28ee	بررسی و تأیید صورت‌حساب‌های خرید #18	\N	medium	2026-07-18	d9785eeb-3cbb-476c-a7ae-a2bdf7655bd2	2026-07-20 11:11:03.957452+00	2026-07-20 11:11:03.957452+00	todo	\N	70	23.70	2026-07-01
4dcc3819-424c-4d09-9482-91ed2d9d19ab	b960ff6a-9895-4681-8b20-e5984d2fa534	\N	8d97ee0b-e8f3-4aec-ab48-db76ef6ede39	5e03da3d-4fd1-4305-91ec-8a61bd1f28ee	تهیهٔ گزارش سود و زیان ماهانه #19	\N	medium	2026-08-15	d4e743cc-35ea-48ce-9e9e-d3629e9a37df	2026-07-20 11:11:03.957452+00	2026-07-20 11:11:03.957452+00	completed	approved	100	17.10	2026-08-11
4dcc3819-424c-4d09-9482-91ed2d9d19ab	b960ff6a-9895-4681-8b20-e5984d2fa534	\N	8e78a4d9-50d5-40e6-bcd8-fd3f57c31286	5e03da3d-4fd1-4305-91ec-8a61bd1f28ee	بررسی فاکتورهای فروش صادرشده #20	\N	medium	2026-08-03	70f473dc-0908-467a-8a59-0d88b0971675	2026-07-20 11:11:03.957452+00	2026-07-20 11:11:03.957452+00	archived	\N	73	4.80	2026-07-16
4dcc3819-424c-4d09-9482-91ed2d9d19ab	b960ff6a-9895-4681-8b20-e5984d2fa534	\N	5742bab4-624b-41df-aff7-c3517eed7f4c	5e03da3d-4fd1-4305-91ec-8a61bd1f28ee	تهیهٔ گزارش مالیاتی فصلی #21	\N	low	2026-08-02	cd89eb97-d966-4565-8fcc-5707bbade6fc	2026-07-20 11:11:03.957452+00	2026-07-20 11:11:03.957452+00	completed	approved	100	35.40	2026-07-15
4dcc3819-424c-4d09-9482-91ed2d9d19ab	b960ff6a-9895-4681-8b20-e5984d2fa534	\N	d7465638-ca92-4b34-b9b1-b1ab5012de48	5e03da3d-4fd1-4305-91ec-8a61bd1f28ee	بررسی فاکتورهای فروش صادرشده #22	\N	high	2026-07-03	dba59333-ca37-492a-9547-9a935f28ef0d	2026-07-20 11:11:03.957452+00	2026-07-20 11:11:03.957452+00	completed	pending	100	36.60	2026-06-27
4dcc3819-424c-4d09-9482-91ed2d9d19ab	b960ff6a-9895-4681-8b20-e5984d2fa534	\N	5e03da3d-4fd1-4305-91ec-8a61bd1f28ee	5e03da3d-4fd1-4305-91ec-8a61bd1f28ee	پیگیری مطالبات معوق مشتریان #23	\N	low	2026-07-25	e53a1348-ae3d-49b9-94c7-c6938d69b886	2026-07-20 11:11:03.957452+00	2026-07-20 11:11:03.957452+00	todo	\N	20	14.30	2026-07-19
4dcc3819-424c-4d09-9482-91ed2d9d19ab	b960ff6a-9895-4681-8b20-e5984d2fa534	\N	8e78a4d9-50d5-40e6-bcd8-fd3f57c31286	5e03da3d-4fd1-4305-91ec-8a61bd1f28ee	بررسی قراردادهای مالی جدید #24	\N	medium	2026-07-26	f8c77226-493c-4694-8982-c6c5da6aef3b	2026-07-20 11:11:03.957452+00	2026-07-20 11:11:03.957452+00	in_progress	\N	10	11.50	2026-07-08
4dcc3819-424c-4d09-9482-91ed2d9d19ab	b960ff6a-9895-4681-8b20-e5984d2fa534	\N	8e78a4d9-50d5-40e6-bcd8-fd3f57c31286	5e03da3d-4fd1-4305-91ec-8a61bd1f28ee	بررسی صورت وضعیت پیمانکاران #25	\N	high	2026-08-06	98c10ee5-f50a-4459-b1ce-0d226e2b0ff0	2026-07-20 11:11:03.957452+00	2026-07-20 11:11:03.957452+00	completed	approved	100	5.60	2026-07-26
4dcc3819-424c-4d09-9482-91ed2d9d19ab	b960ff6a-9895-4681-8b20-e5984d2fa534	\N	8e78a4d9-50d5-40e6-bcd8-fd3f57c31286	5e03da3d-4fd1-4305-91ec-8a61bd1f28ee	مغایرت‌گیری حساب‌های بانکی #26	\N	low	2026-08-12	522938aa-359a-4c26-99f9-360499acab7c	2026-07-20 11:11:03.957452+00	2026-07-20 11:11:03.957452+00	todo	\N	79	29.40	2026-07-23
4dcc3819-424c-4d09-9482-91ed2d9d19ab	b960ff6a-9895-4681-8b20-e5984d2fa534	\N	7a6ee833-86b5-4c74-a2b1-845608f4fbab	5e03da3d-4fd1-4305-91ec-8a61bd1f28ee	بررسی و تأیید صورت‌حساب‌های خرید #27	\N	low	2026-08-28	36029507-d055-45ed-83e5-f59dff649d4d	2026-07-20 11:11:03.957452+00	2026-07-20 11:11:03.957452+00	in_progress	\N	10	3.70	2026-08-08
4dcc3819-424c-4d09-9482-91ed2d9d19ab	b960ff6a-9895-4681-8b20-e5984d2fa534	\N	8e78a4d9-50d5-40e6-bcd8-fd3f57c31286	5e03da3d-4fd1-4305-91ec-8a61bd1f28ee	تطبیق موجودی انبار با حساب‌ها #28	\N	low	2026-08-01	5b535b8c-2967-4fa2-8204-a75271c08871	2026-07-20 11:11:03.957452+00	2026-07-20 11:11:03.957452+00	archived	\N	73	17.80	2026-07-22
4dcc3819-424c-4d09-9482-91ed2d9d19ab	b960ff6a-9895-4681-8b20-e5984d2fa534	\N	8e78a4d9-50d5-40e6-bcd8-fd3f57c31286	5e03da3d-4fd1-4305-91ec-8a61bd1f28ee	پیگیری مطالبات معوق مشتریان #29	\N	high	2026-08-05	5425d929-4398-44bc-abbc-f860b9734ad5	2026-07-20 11:11:03.957452+00	2026-07-20 11:11:03.957452+00	todo	\N	38	20.40	2026-07-17
4dcc3819-424c-4d09-9482-91ed2d9d19ab	b960ff6a-9895-4681-8b20-e5984d2fa534	\N	d7465638-ca92-4b34-b9b1-b1ab5012de48	5e03da3d-4fd1-4305-91ec-8a61bd1f28ee	تهیهٔ گزارش جریان نقدی #30	\N	low	2026-07-19	0197f7a2-c941-4f2d-93d2-9103cfe3e234	2026-07-20 11:11:03.957452+00	2026-07-20 11:11:03.957452+00	completed	approved	100	8.00	2026-07-15
4dcc3819-424c-4d09-9482-91ed2d9d19ab	b960ff6a-9895-4681-8b20-e5984d2fa534	\N	8d97ee0b-e8f3-4aec-ab48-db76ef6ede39	5e03da3d-4fd1-4305-91ec-8a61bd1f28ee	مغایرت‌گیری حساب‌های بانکی #31	\N	medium	2026-07-28	20311053-75e7-4622-9938-c6e6eaa3129d	2026-07-20 11:11:03.957452+00	2026-07-20 11:11:03.957452+00	completed	approved	100	34.70	2026-07-07
4dcc3819-424c-4d09-9482-91ed2d9d19ab	b960ff6a-9895-4681-8b20-e5984d2fa534	\N	5742bab4-624b-41df-aff7-c3517eed7f4c	5e03da3d-4fd1-4305-91ec-8a61bd1f28ee	بررسی فاکتورهای فروش صادرشده #32	\N	low	2026-08-23	90e29895-8f1a-49bf-b6c5-cd0af8d17aa5	2026-07-20 11:11:03.957452+00	2026-07-20 11:11:03.957452+00	archived	\N	47	21.60	2026-08-10
4dcc3819-424c-4d09-9482-91ed2d9d19ab	b960ff6a-9895-4681-8b20-e5984d2fa534	\N	5e03da3d-4fd1-4305-91ec-8a61bd1f28ee	5e03da3d-4fd1-4305-91ec-8a61bd1f28ee	تهیهٔ گزارش سود و زیان ماهانه #33	\N	medium	2026-07-17	1fc5d2bd-36e5-4480-a94b-21e0534edf23	2026-07-20 11:11:03.957452+00	2026-07-20 11:11:03.957452+00	in_progress	\N	57	11.40	2026-07-01
4dcc3819-424c-4d09-9482-91ed2d9d19ab	b960ff6a-9895-4681-8b20-e5984d2fa534	\N	5e03da3d-4fd1-4305-91ec-8a61bd1f28ee	5e03da3d-4fd1-4305-91ec-8a61bd1f28ee	پیگیری بیمهٔ کارکنان #34	\N	high	2026-07-18	96e3fc33-c92f-46ae-8983-09990941a14b	2026-07-20 11:11:03.957452+00	2026-07-20 11:11:03.957452+00	todo	\N	53	11.40	2026-07-04
4dcc3819-424c-4d09-9482-91ed2d9d19ab	b960ff6a-9895-4681-8b20-e5984d2fa534	\N	d7465638-ca92-4b34-b9b1-b1ab5012de48	5e03da3d-4fd1-4305-91ec-8a61bd1f28ee	بررسی قراردادهای مالی جدید #35	\N	high	2026-08-19	a1134b3b-bd99-4826-81d1-f2b9adcc77c5	2026-07-20 11:11:03.957452+00	2026-07-20 11:11:03.957452+00	todo	\N	40	9.20	2026-08-07
4dcc3819-424c-4d09-9482-91ed2d9d19ab	b960ff6a-9895-4681-8b20-e5984d2fa534	\N	24baa76f-b9d0-4a8f-b28d-605d780d066a	5e03da3d-4fd1-4305-91ec-8a61bd1f28ee	بررسی قراردادهای مالی جدید #36	\N	medium	2026-08-01	fb9d7cdf-6a0e-4d1a-a615-3db27c23daee	2026-07-20 11:11:03.957452+00	2026-07-20 11:11:03.957452+00	completed	rejected	100	20.90	2026-07-15
4dcc3819-424c-4d09-9482-91ed2d9d19ab	a09ff0f0-43e2-48d8-8bf6-67e0e31e0def	\N	5e03da3d-4fd1-4305-91ec-8a61bd1f28ee	5e03da3d-4fd1-4305-91ec-8a61bd1f28ee	ثبت اسناد حسابداری هفتگی #37	\N	low	2026-08-03	3474c7a6-df57-4bc4-9f5f-14a21299c785	2026-07-20 11:11:03.957452+00	2026-07-20 11:11:03.957452+00	in_progress	\N	74	15.40	2026-07-18
4dcc3819-424c-4d09-9482-91ed2d9d19ab	a09ff0f0-43e2-48d8-8bf6-67e0e31e0def	\N	5e03da3d-4fd1-4305-91ec-8a61bd1f28ee	5e03da3d-4fd1-4305-91ec-8a61bd1f28ee	بررسی قراردادهای مالی جدید #38	\N	high	2026-08-07	985811df-d3de-4c8e-8f22-91899134d2d9	2026-07-20 11:11:03.957452+00	2026-07-20 11:11:03.957452+00	in_progress	\N	60	12.90	2026-07-17
4dcc3819-424c-4d09-9482-91ed2d9d19ab	a09ff0f0-43e2-48d8-8bf6-67e0e31e0def	\N	5e03da3d-4fd1-4305-91ec-8a61bd1f28ee	5e03da3d-4fd1-4305-91ec-8a61bd1f28ee	بررسی قراردادهای مالی جدید #39	\N	medium	2026-07-19	fb4079d9-b6d1-4a2e-90c2-d7a94b21b154	2026-07-20 11:11:03.957452+00	2026-07-20 11:11:03.957452+00	todo	\N	46	31.00	2026-07-13
4dcc3819-424c-4d09-9482-91ed2d9d19ab	a09ff0f0-43e2-48d8-8bf6-67e0e31e0def	\N	5742bab4-624b-41df-aff7-c3517eed7f4c	5e03da3d-4fd1-4305-91ec-8a61bd1f28ee	بررسی صورت وضعیت پیمانکاران #40	\N	high	2026-07-14	0de4c63a-2443-4b05-8551-429a075beb41	2026-07-20 11:11:03.957452+00	2026-07-20 11:11:03.957452+00	todo	\N	24	15.80	2026-07-11
4dcc3819-424c-4d09-9482-91ed2d9d19ab	a09ff0f0-43e2-48d8-8bf6-67e0e31e0def	\N	5742bab4-624b-41df-aff7-c3517eed7f4c	5e03da3d-4fd1-4305-91ec-8a61bd1f28ee	به‌روزرسانی جدول حقوق و دستمزد #41	\N	high	2026-07-28	c63991b9-32bb-4288-ac36-70b894a253c9	2026-07-20 11:11:03.957452+00	2026-07-20 11:11:03.957452+00	todo	\N	35	33.40	2026-07-10
4dcc3819-424c-4d09-9482-91ed2d9d19ab	a09ff0f0-43e2-48d8-8bf6-67e0e31e0def	\N	7a6ee833-86b5-4c74-a2b1-845608f4fbab	5e03da3d-4fd1-4305-91ec-8a61bd1f28ee	بررسی فاکتورهای فروش صادرشده #42	\N	medium	2026-06-29	502d45a5-3de5-4569-8dfb-b9325bba8205	2026-07-20 11:11:03.957452+00	2026-07-20 11:11:03.957452+00	completed	pending	100	32.20	2026-06-24
4dcc3819-424c-4d09-9482-91ed2d9d19ab	a09ff0f0-43e2-48d8-8bf6-67e0e31e0def	\N	5742bab4-624b-41df-aff7-c3517eed7f4c	5e03da3d-4fd1-4305-91ec-8a61bd1f28ee	ثبت اسناد حسابداری هفتگی #43	\N	high	2026-08-09	ee75a05f-48bc-4fee-87d8-605085e4e531	2026-07-20 11:11:03.957452+00	2026-07-20 11:11:03.957452+00	completed	rejected	100	21.30	2026-08-03
4dcc3819-424c-4d09-9482-91ed2d9d19ab	a09ff0f0-43e2-48d8-8bf6-67e0e31e0def	\N	7a6ee833-86b5-4c74-a2b1-845608f4fbab	5e03da3d-4fd1-4305-91ec-8a61bd1f28ee	مغایرت‌گیری حساب‌های بانکی #44	\N	high	2026-06-21	bc4dc70a-6b9e-4c4e-b200-cc96dfa58824	2026-07-20 11:11:03.957452+00	2026-07-20 11:11:03.957452+00	todo	\N	42	32.60	2026-06-18
4dcc3819-424c-4d09-9482-91ed2d9d19ab	a09ff0f0-43e2-48d8-8bf6-67e0e31e0def	\N	7a6ee833-86b5-4c74-a2b1-845608f4fbab	5e03da3d-4fd1-4305-91ec-8a61bd1f28ee	مغایرت‌گیری حساب‌های بانکی #45	\N	medium	2026-08-30	9c8365ea-a6f5-4967-9efa-62c3cc789129	2026-07-20 11:11:03.957452+00	2026-07-20 11:11:03.957452+00	completed	approved	100	37.40	2026-08-12
4dcc3819-424c-4d09-9482-91ed2d9d19ab	a09ff0f0-43e2-48d8-8bf6-67e0e31e0def	\N	5742bab4-624b-41df-aff7-c3517eed7f4c	5e03da3d-4fd1-4305-91ec-8a61bd1f28ee	تهیهٔ گزارش جریان نقدی #46	\N	medium	2026-08-01	5a73469d-36a9-4c8a-9e0e-d1702edde976	2026-07-20 11:11:03.957452+00	2026-07-20 11:11:03.957452+00	todo	\N	75	14.80	2026-07-11
4dcc3819-424c-4d09-9482-91ed2d9d19ab	a09ff0f0-43e2-48d8-8bf6-67e0e31e0def	\N	d7465638-ca92-4b34-b9b1-b1ab5012de48	5e03da3d-4fd1-4305-91ec-8a61bd1f28ee	پیگیری مطالبات معوق مشتریان #47	\N	medium	2026-08-20	14cf657f-c4ec-45a7-8179-2eec35031e1e	2026-07-20 11:11:03.957452+00	2026-07-20 11:11:03.957452+00	completed	approved	100	33.00	2026-07-31
4dcc3819-424c-4d09-9482-91ed2d9d19ab	a09ff0f0-43e2-48d8-8bf6-67e0e31e0def	\N	5742bab4-624b-41df-aff7-c3517eed7f4c	5e03da3d-4fd1-4305-91ec-8a61bd1f28ee	بررسی فاکتورهای فروش صادرشده #48	\N	high	2026-08-03	7cf51bc5-f86c-4ecd-8ab9-76eb1a650460	2026-07-20 11:11:03.957452+00	2026-07-20 11:11:03.957452+00	in_progress	\N	39	32.30	2026-07-29
4dcc3819-424c-4d09-9482-91ed2d9d19ab	a09ff0f0-43e2-48d8-8bf6-67e0e31e0def	\N	8e78a4d9-50d5-40e6-bcd8-fd3f57c31286	5e03da3d-4fd1-4305-91ec-8a61bd1f28ee	پیگیری مطالبات معوق مشتریان #49	\N	high	2026-08-10	39532a48-a60d-45ec-893c-9bd85f10f3b4	2026-07-20 11:11:03.957452+00	2026-07-20 11:11:03.957452+00	completed	pending	100	31.80	2026-07-24
4dcc3819-424c-4d09-9482-91ed2d9d19ab	a09ff0f0-43e2-48d8-8bf6-67e0e31e0def	\N	d7465638-ca92-4b34-b9b1-b1ab5012de48	5e03da3d-4fd1-4305-91ec-8a61bd1f28ee	بررسی صورت وضعیت پیمانکاران #50	\N	medium	2026-08-04	45c7f6ce-389e-4404-a127-0926df5c2060	2026-07-20 11:11:03.957452+00	2026-07-20 11:11:03.957452+00	completed	approved	100	8.50	2026-08-01
4dcc3819-424c-4d09-9482-91ed2d9d19ab	a09ff0f0-43e2-48d8-8bf6-67e0e31e0def	\N	8e78a4d9-50d5-40e6-bcd8-fd3f57c31286	5e03da3d-4fd1-4305-91ec-8a61bd1f28ee	مغایرت‌گیری حساب‌های بانکی #51	\N	high	2026-08-08	b4d0c2a1-e9b1-47d1-82f9-1602732af21f	2026-07-20 11:11:03.957452+00	2026-07-20 11:11:03.957452+00	archived	\N	31	3.20	2026-07-25
4dcc3819-424c-4d09-9482-91ed2d9d19ab	a09ff0f0-43e2-48d8-8bf6-67e0e31e0def	\N	8e78a4d9-50d5-40e6-bcd8-fd3f57c31286	5e03da3d-4fd1-4305-91ec-8a61bd1f28ee	به‌روزرسانی جدول حقوق و دستمزد #52	\N	medium	2026-06-30	a91fe8f8-0f52-4686-8e47-36f4ed715c28	2026-07-20 11:11:03.957452+00	2026-07-20 11:11:03.957452+00	todo	\N	53	7.80	2026-06-28
4dcc3819-424c-4d09-9482-91ed2d9d19ab	a09ff0f0-43e2-48d8-8bf6-67e0e31e0def	\N	8e78a4d9-50d5-40e6-bcd8-fd3f57c31286	5e03da3d-4fd1-4305-91ec-8a61bd1f28ee	بررسی و تسویهٔ کارت اعتباری شرکت #53	\N	high	2026-07-30	a24b4602-80e6-4cc5-8cc0-ab9782007316	2026-07-20 11:11:03.957452+00	2026-07-20 11:11:03.957452+00	in_progress	\N	60	35.20	2026-07-12
4dcc3819-424c-4d09-9482-91ed2d9d19ab	a09ff0f0-43e2-48d8-8bf6-67e0e31e0def	\N	8e78a4d9-50d5-40e6-bcd8-fd3f57c31286	5e03da3d-4fd1-4305-91ec-8a61bd1f28ee	تهیهٔ پیش‌نویس بودجهٔ واحد #54	\N	low	2026-06-25	4ccf0c27-e251-4528-b213-62cc91f70c44	2026-07-20 11:11:03.957452+00	2026-07-20 11:11:03.957452+00	archived	\N	71	14.40	2026-06-19
4dcc3819-424c-4d09-9482-91ed2d9d19ab	c7e23915-2f99-4ff8-9ca8-cda5dcdba7c9	\N	8e78a4d9-50d5-40e6-bcd8-fd3f57c31286	5e03da3d-4fd1-4305-91ec-8a61bd1f28ee	به‌روزرسانی جدول حقوق و دستمزد #55	\N	high	2026-07-13	8ecac59b-e856-482c-ab18-aa8dbc6c349f	2026-07-20 11:11:03.957452+00	2026-07-20 11:11:03.957452+00	completed	approved	100	15.00	2026-07-06
4dcc3819-424c-4d09-9482-91ed2d9d19ab	c7e23915-2f99-4ff8-9ca8-cda5dcdba7c9	\N	5742bab4-624b-41df-aff7-c3517eed7f4c	5e03da3d-4fd1-4305-91ec-8a61bd1f28ee	بررسی صورت وضعیت پیمانکاران #56	\N	medium	2026-08-11	f618a21b-040e-40e4-83d1-bc37cb69d7ff	2026-07-20 11:11:03.957452+00	2026-07-20 11:11:03.957452+00	completed	pending	100	9.30	2026-08-01
4dcc3819-424c-4d09-9482-91ed2d9d19ab	c7e23915-2f99-4ff8-9ca8-cda5dcdba7c9	\N	24baa76f-b9d0-4a8f-b28d-605d780d066a	5e03da3d-4fd1-4305-91ec-8a61bd1f28ee	ثبت اسناد حسابداری هفتگی #57	\N	medium	2026-08-01	84c1c504-0816-41f8-a2c4-1a9cf4205bd2	2026-07-20 11:11:03.957452+00	2026-07-20 11:11:03.957452+00	in_progress	\N	36	28.80	2026-07-21
4dcc3819-424c-4d09-9482-91ed2d9d19ab	c7e23915-2f99-4ff8-9ca8-cda5dcdba7c9	\N	8e78a4d9-50d5-40e6-bcd8-fd3f57c31286	5e03da3d-4fd1-4305-91ec-8a61bd1f28ee	به‌روزرسانی جدول حقوق و دستمزد #58	\N	medium	2026-07-29	81233d55-4d20-4b83-b997-4c1a2455c079	2026-07-20 11:11:03.957452+00	2026-07-20 11:11:03.957452+00	archived	\N	71	37.50	2026-07-17
4dcc3819-424c-4d09-9482-91ed2d9d19ab	c7e23915-2f99-4ff8-9ca8-cda5dcdba7c9	\N	d7465638-ca92-4b34-b9b1-b1ab5012de48	5e03da3d-4fd1-4305-91ec-8a61bd1f28ee	تهیهٔ گزارش سود و زیان ماهانه #59	\N	high	2026-07-14	c0ccf45a-9635-47c3-94c9-8132e681d85c	2026-07-20 11:11:03.957452+00	2026-07-20 11:11:03.957452+00	archived	\N	69	16.40	2026-07-03
4dcc3819-424c-4d09-9482-91ed2d9d19ab	c7e23915-2f99-4ff8-9ca8-cda5dcdba7c9	\N	8d97ee0b-e8f3-4aec-ab48-db76ef6ede39	5e03da3d-4fd1-4305-91ec-8a61bd1f28ee	پیگیری مطالبات معوق مشتریان #60	\N	low	2026-08-10	f972eb63-88f5-4e72-82d0-19fb5d7f512d	2026-07-20 11:11:03.957452+00	2026-07-20 11:11:03.957452+00	in_progress	\N	36	38.30	2026-08-04
4dcc3819-424c-4d09-9482-91ed2d9d19ab	c7e23915-2f99-4ff8-9ca8-cda5dcdba7c9	\N	5e03da3d-4fd1-4305-91ec-8a61bd1f28ee	5e03da3d-4fd1-4305-91ec-8a61bd1f28ee	تطبیق موجودی انبار با حساب‌ها #61	\N	medium	2026-08-30	1ccc5bc0-88ad-4f93-8ce6-c2a2add8da09	2026-07-20 11:11:03.957452+00	2026-07-20 11:11:03.957452+00	in_progress	\N	61	10.10	2026-08-14
4dcc3819-424c-4d09-9482-91ed2d9d19ab	c7e23915-2f99-4ff8-9ca8-cda5dcdba7c9	\N	d7465638-ca92-4b34-b9b1-b1ab5012de48	5e03da3d-4fd1-4305-91ec-8a61bd1f28ee	مغایرت‌گیری حساب‌های بانکی #62	\N	low	2026-07-31	9b476c5e-1b89-4a88-b459-599ad713f63b	2026-07-20 11:11:03.957452+00	2026-07-20 11:11:03.957452+00	completed	approved	100	25.40	2026-07-21
4dcc3819-424c-4d09-9482-91ed2d9d19ab	c7e23915-2f99-4ff8-9ca8-cda5dcdba7c9	\N	7a6ee833-86b5-4c74-a2b1-845608f4fbab	5e03da3d-4fd1-4305-91ec-8a61bd1f28ee	تطبیق موجودی انبار با حساب‌ها #63	\N	high	2026-07-04	f2a0899b-55f0-4fb0-9830-096260fc2d92	2026-07-20 11:11:03.957452+00	2026-07-20 11:11:03.957452+00	in_progress	\N	28	26.20	2026-07-01
4dcc3819-424c-4d09-9482-91ed2d9d19ab	c7e23915-2f99-4ff8-9ca8-cda5dcdba7c9	\N	5e03da3d-4fd1-4305-91ec-8a61bd1f28ee	5e03da3d-4fd1-4305-91ec-8a61bd1f28ee	تهیهٔ گزارش جریان نقدی #64	\N	medium	2026-07-24	8b2df0fa-3c0c-462d-b15b-6875e970f072	2026-07-20 11:11:03.957452+00	2026-07-20 11:11:03.957452+00	todo	\N	12	27.90	2026-07-12
4dcc3819-424c-4d09-9482-91ed2d9d19ab	c7e23915-2f99-4ff8-9ca8-cda5dcdba7c9	\N	24baa76f-b9d0-4a8f-b28d-605d780d066a	5e03da3d-4fd1-4305-91ec-8a61bd1f28ee	بررسی فاکتورهای فروش صادرشده #65	\N	high	2026-07-28	9a0fbf18-1018-4180-bdd3-75cd1145a62a	2026-07-20 11:11:03.957452+00	2026-07-20 11:11:03.957452+00	todo	\N	60	20.10	2026-07-21
4dcc3819-424c-4d09-9482-91ed2d9d19ab	c7e23915-2f99-4ff8-9ca8-cda5dcdba7c9	\N	24baa76f-b9d0-4a8f-b28d-605d780d066a	5e03da3d-4fd1-4305-91ec-8a61bd1f28ee	پیگیری مطالبات معوق مشتریان #66	\N	high	2026-07-16	f90e2741-210c-40e2-aede-790faaea9b24	2026-07-20 11:11:03.957452+00	2026-07-20 11:11:03.957452+00	archived	\N	7	36.50	2026-07-04
4dcc3819-424c-4d09-9482-91ed2d9d19ab	c7e23915-2f99-4ff8-9ca8-cda5dcdba7c9	\N	5e03da3d-4fd1-4305-91ec-8a61bd1f28ee	5e03da3d-4fd1-4305-91ec-8a61bd1f28ee	بررسی قراردادهای مالی جدید #67	\N	low	2026-07-23	468d97af-7737-49ac-b733-68b6101746f3	2026-07-20 11:11:03.957452+00	2026-07-20 11:11:03.957452+00	completed	approved	100	17.90	2026-07-20
4dcc3819-424c-4d09-9482-91ed2d9d19ab	c7e23915-2f99-4ff8-9ca8-cda5dcdba7c9	\N	d7465638-ca92-4b34-b9b1-b1ab5012de48	5e03da3d-4fd1-4305-91ec-8a61bd1f28ee	پیگیری بیمهٔ کارکنان #68	\N	medium	2026-08-17	05f79e39-0ef8-4c8d-bb4d-c3dc60cce526	2026-07-20 11:11:03.957452+00	2026-07-20 11:11:03.957452+00	todo	\N	63	9.10	2026-08-14
4dcc3819-424c-4d09-9482-91ed2d9d19ab	c7e23915-2f99-4ff8-9ca8-cda5dcdba7c9	\N	8e78a4d9-50d5-40e6-bcd8-fd3f57c31286	5e03da3d-4fd1-4305-91ec-8a61bd1f28ee	بررسی و تأیید صورت‌حساب‌های خرید #69	\N	medium	2026-08-14	6b321cbc-33f7-486b-95ca-f7c5305c3565	2026-07-20 11:11:03.957452+00	2026-07-20 11:11:03.957452+00	in_progress	\N	72	24.90	2026-08-11
4dcc3819-424c-4d09-9482-91ed2d9d19ab	c7e23915-2f99-4ff8-9ca8-cda5dcdba7c9	\N	5742bab4-624b-41df-aff7-c3517eed7f4c	5e03da3d-4fd1-4305-91ec-8a61bd1f28ee	تهیهٔ پیش‌نویس بودجهٔ واحد #70	\N	medium	2026-08-03	0c3007ea-4bc9-4402-ba37-ccce7ea2efb9	2026-07-20 11:11:03.957452+00	2026-07-20 11:11:03.957452+00	in_progress	\N	17	34.30	2026-07-15
4dcc3819-424c-4d09-9482-91ed2d9d19ab	c7e23915-2f99-4ff8-9ca8-cda5dcdba7c9	\N	8d97ee0b-e8f3-4aec-ab48-db76ef6ede39	5e03da3d-4fd1-4305-91ec-8a61bd1f28ee	تهیهٔ گزارش مالیاتی فصلی #71	\N	low	2026-07-03	422f7bda-91c9-41a1-be58-28f33faaf382	2026-07-20 11:11:03.957452+00	2026-07-20 11:11:03.957452+00	in_progress	\N	58	26.60	2026-06-28
4dcc3819-424c-4d09-9482-91ed2d9d19ab	c7e23915-2f99-4ff8-9ca8-cda5dcdba7c9	\N	8e78a4d9-50d5-40e6-bcd8-fd3f57c31286	5e03da3d-4fd1-4305-91ec-8a61bd1f28ee	بررسی و تسویهٔ کارت اعتباری شرکت #72	\N	medium	2026-06-28	e94aa760-3e85-434f-ad30-f37ec085f5e4	2026-07-20 11:11:03.957452+00	2026-07-20 11:11:03.957452+00	todo	\N	72	27.60	2026-06-16
4dcc3819-424c-4d09-9482-91ed2d9d19ab	1fac07d5-b0a4-40b0-8f99-1e6da7ef8ac7	\N	24baa76f-b9d0-4a8f-b28d-605d780d066a	5e03da3d-4fd1-4305-91ec-8a61bd1f28ee	پیگیری بیمهٔ کارکنان #73	\N	medium	2026-08-08	4e5333d2-204e-4543-8997-7e223401a5bb	2026-07-20 11:11:03.957452+00	2026-07-20 11:11:03.957452+00	todo	\N	65	14.50	2026-07-25
4dcc3819-424c-4d09-9482-91ed2d9d19ab	1fac07d5-b0a4-40b0-8f99-1e6da7ef8ac7	\N	8d97ee0b-e8f3-4aec-ab48-db76ef6ede39	5e03da3d-4fd1-4305-91ec-8a61bd1f28ee	تهیهٔ گزارش مالیاتی فصلی #74	\N	low	2026-07-11	1bb9cae8-aa87-4058-9813-d8bd51ac56e2	2026-07-20 11:11:03.957452+00	2026-07-20 11:11:03.957452+00	completed	approved	100	2.30	2026-06-24
4dcc3819-424c-4d09-9482-91ed2d9d19ab	1fac07d5-b0a4-40b0-8f99-1e6da7ef8ac7	\N	8d97ee0b-e8f3-4aec-ab48-db76ef6ede39	5e03da3d-4fd1-4305-91ec-8a61bd1f28ee	تهیهٔ گزارش مالیاتی فصلی #75	\N	medium	2026-07-24	d8e8bcf6-a2b8-4982-a1ff-77ea63047b8e	2026-07-20 11:11:03.957452+00	2026-07-20 11:11:03.957452+00	in_progress	\N	74	29.50	2026-07-14
4dcc3819-424c-4d09-9482-91ed2d9d19ab	1fac07d5-b0a4-40b0-8f99-1e6da7ef8ac7	\N	5e03da3d-4fd1-4305-91ec-8a61bd1f28ee	5e03da3d-4fd1-4305-91ec-8a61bd1f28ee	تهیهٔ گزارش جریان نقدی #76	\N	low	2026-08-09	1c58fb56-c774-4c00-836b-01035c47935f	2026-07-20 11:11:03.957452+00	2026-07-20 11:11:03.957452+00	in_progress	\N	7	27.40	2026-07-27
4dcc3819-424c-4d09-9482-91ed2d9d19ab	1fac07d5-b0a4-40b0-8f99-1e6da7ef8ac7	\N	8d97ee0b-e8f3-4aec-ab48-db76ef6ede39	5e03da3d-4fd1-4305-91ec-8a61bd1f28ee	تطبیق موجودی انبار با حساب‌ها #77	\N	high	2026-07-10	8d035bf7-8a51-4fb8-b1b9-ef9322697682	2026-07-20 11:11:03.957452+00	2026-07-20 11:11:03.957452+00	in_progress	\N	39	28.20	2026-06-26
4dcc3819-424c-4d09-9482-91ed2d9d19ab	1fac07d5-b0a4-40b0-8f99-1e6da7ef8ac7	\N	8e78a4d9-50d5-40e6-bcd8-fd3f57c31286	5e03da3d-4fd1-4305-91ec-8a61bd1f28ee	ثبت اسناد حسابداری هفتگی #78	\N	low	2026-07-30	32048e87-dac4-4257-bea7-39a362f61f7e	2026-07-20 11:11:03.957452+00	2026-07-20 11:11:03.957452+00	in_progress	\N	17	20.20	2026-07-09
4dcc3819-424c-4d09-9482-91ed2d9d19ab	1fac07d5-b0a4-40b0-8f99-1e6da7ef8ac7	\N	8d97ee0b-e8f3-4aec-ab48-db76ef6ede39	5e03da3d-4fd1-4305-91ec-8a61bd1f28ee	بررسی فاکتورهای فروش صادرشده #79	\N	high	2026-08-06	bb2a52bc-183a-4634-99a1-47e0dd61da95	2026-07-20 11:11:03.957452+00	2026-07-20 11:11:03.957452+00	archived	\N	70	36.70	2026-07-24
4dcc3819-424c-4d09-9482-91ed2d9d19ab	1fac07d5-b0a4-40b0-8f99-1e6da7ef8ac7	\N	d7465638-ca92-4b34-b9b1-b1ab5012de48	5e03da3d-4fd1-4305-91ec-8a61bd1f28ee	بررسی و تسویهٔ کارت اعتباری شرکت #80	\N	low	2026-08-15	a8738110-a033-43d8-95b1-99f040fe8749	2026-07-20 11:11:03.957452+00	2026-07-20 11:11:03.957452+00	completed	pending	100	27.90	2026-08-07
4dcc3819-424c-4d09-9482-91ed2d9d19ab	1fac07d5-b0a4-40b0-8f99-1e6da7ef8ac7	\N	7a6ee833-86b5-4c74-a2b1-845608f4fbab	5e03da3d-4fd1-4305-91ec-8a61bd1f28ee	تهیهٔ پیش‌نویس بودجهٔ واحد #81	\N	high	2026-08-04	ce460ba3-76ab-468c-85d3-1e1fff11a1db	2026-07-20 11:11:03.957452+00	2026-07-20 11:11:03.957452+00	todo	\N	46	5.00	2026-07-19
4dcc3819-424c-4d09-9482-91ed2d9d19ab	1fac07d5-b0a4-40b0-8f99-1e6da7ef8ac7	\N	7a6ee833-86b5-4c74-a2b1-845608f4fbab	5e03da3d-4fd1-4305-91ec-8a61bd1f28ee	بررسی قراردادهای مالی جدید #82	\N	high	2026-07-08	5b691177-2a87-4179-8092-51fc24cffc1a	2026-07-20 11:11:03.957452+00	2026-07-20 11:11:03.957452+00	todo	\N	25	23.80	2026-06-19
4dcc3819-424c-4d09-9482-91ed2d9d19ab	1fac07d5-b0a4-40b0-8f99-1e6da7ef8ac7	\N	24baa76f-b9d0-4a8f-b28d-605d780d066a	5e03da3d-4fd1-4305-91ec-8a61bd1f28ee	به‌روزرسانی جدول حقوق و دستمزد #83	\N	low	2026-07-24	9ecbe18e-4216-4bbe-953f-e8a36bf645c9	2026-07-20 11:11:03.957452+00	2026-07-20 11:11:03.957452+00	todo	\N	26	29.20	2026-07-06
4dcc3819-424c-4d09-9482-91ed2d9d19ab	1fac07d5-b0a4-40b0-8f99-1e6da7ef8ac7	\N	8d97ee0b-e8f3-4aec-ab48-db76ef6ede39	5e03da3d-4fd1-4305-91ec-8a61bd1f28ee	به‌روزرسانی جدول حقوق و دستمزد #84	\N	low	2026-08-30	e972b509-dad5-408b-992b-6e83053a95ec	2026-07-20 11:11:03.957452+00	2026-07-20 11:11:03.957452+00	todo	\N	58	7.00	2026-08-12
4dcc3819-424c-4d09-9482-91ed2d9d19ab	1fac07d5-b0a4-40b0-8f99-1e6da7ef8ac7	\N	8d97ee0b-e8f3-4aec-ab48-db76ef6ede39	5e03da3d-4fd1-4305-91ec-8a61bd1f28ee	تطبیق موجودی انبار با حساب‌ها #85	\N	medium	2026-08-06	002e1376-5644-42de-aa57-11d60d218c14	2026-07-20 11:11:03.957452+00	2026-07-20 11:11:03.957452+00	completed	approved	100	29.50	2026-07-21
4dcc3819-424c-4d09-9482-91ed2d9d19ab	1fac07d5-b0a4-40b0-8f99-1e6da7ef8ac7	\N	8d97ee0b-e8f3-4aec-ab48-db76ef6ede39	5e03da3d-4fd1-4305-91ec-8a61bd1f28ee	تهیهٔ گزارش جریان نقدی #86	\N	low	2026-08-09	da049353-ea9f-4832-9c21-3407450ef12b	2026-07-20 11:11:03.957452+00	2026-07-20 11:11:03.957452+00	in_progress	\N	74	4.80	2026-08-07
4dcc3819-424c-4d09-9482-91ed2d9d19ab	1fac07d5-b0a4-40b0-8f99-1e6da7ef8ac7	\N	8d97ee0b-e8f3-4aec-ab48-db76ef6ede39	5e03da3d-4fd1-4305-91ec-8a61bd1f28ee	تهیهٔ پیش‌نویس بودجهٔ واحد #87	\N	low	2026-08-03	aac55eb9-cd4f-4d1b-9c14-fa62ba1acb71	2026-07-20 11:11:03.957452+00	2026-07-20 11:11:03.957452+00	in_progress	\N	8	39.50	2026-07-30
4dcc3819-424c-4d09-9482-91ed2d9d19ab	1fac07d5-b0a4-40b0-8f99-1e6da7ef8ac7	\N	8d97ee0b-e8f3-4aec-ab48-db76ef6ede39	5e03da3d-4fd1-4305-91ec-8a61bd1f28ee	مغایرت‌گیری حساب‌های بانکی #88	\N	low	2026-07-19	a599fd88-eb24-4135-8616-aff0aafe8e81	2026-07-20 11:11:03.957452+00	2026-07-20 11:11:03.957452+00	todo	\N	53	16.20	2026-07-04
4dcc3819-424c-4d09-9482-91ed2d9d19ab	1fac07d5-b0a4-40b0-8f99-1e6da7ef8ac7	\N	8d97ee0b-e8f3-4aec-ab48-db76ef6ede39	5e03da3d-4fd1-4305-91ec-8a61bd1f28ee	بررسی فاکتورهای فروش صادرشده #89	\N	low	2026-08-27	f35abd35-e113-481d-bcf6-3b360e723041	2026-07-20 11:11:03.957452+00	2026-07-20 11:11:03.957452+00	completed	pending	100	27.90	2026-08-13
4dcc3819-424c-4d09-9482-91ed2d9d19ab	1fac07d5-b0a4-40b0-8f99-1e6da7ef8ac7	\N	8e78a4d9-50d5-40e6-bcd8-fd3f57c31286	5e03da3d-4fd1-4305-91ec-8a61bd1f28ee	تهیهٔ گزارش سود و زیان ماهانه #90	\N	low	2026-08-23	4e56b431-b4ec-4e0c-8a8a-bf814aee9852	2026-07-20 11:11:03.957452+00	2026-07-20 11:11:03.957452+00	completed	approved	100	39.70	2026-08-10
4dcc3819-424c-4d09-9482-91ed2d9d19ab	\N	\N	8d97ee0b-e8f3-4aec-ab48-db76ef6ede39	8d97ee0b-e8f3-4aec-ab48-db76ef6ede39	بررسی و تسویهٔ کارت اعتباری شرکت #91	\N	low	2026-07-02	78161dda-0f25-49c1-b5e7-e315cd66d482	2026-07-20 11:11:03.957452+00	2026-07-20 11:11:03.957452+00	completed	approved	100	39.20	2026-06-30
4dcc3819-424c-4d09-9482-91ed2d9d19ab	\N	\N	8d97ee0b-e8f3-4aec-ab48-db76ef6ede39	8d97ee0b-e8f3-4aec-ab48-db76ef6ede39	بررسی فاکتورهای فروش صادرشده #92	\N	low	2026-08-01	08107ef8-3088-40df-9750-115bea410ddb	2026-07-20 11:11:03.957452+00	2026-07-20 11:11:03.957452+00	completed	pending	100	11.40	2026-07-13
4dcc3819-424c-4d09-9482-91ed2d9d19ab	\N	\N	5742bab4-624b-41df-aff7-c3517eed7f4c	5742bab4-624b-41df-aff7-c3517eed7f4c	بررسی قراردادهای مالی جدید #93	\N	high	2026-07-11	9b53ba78-00ad-4e69-b5d7-ec4f598e5e1e	2026-07-20 11:11:03.957452+00	2026-07-20 11:11:03.957452+00	todo	\N	14	3.20	2026-07-03
4dcc3819-424c-4d09-9482-91ed2d9d19ab	\N	\N	8e78a4d9-50d5-40e6-bcd8-fd3f57c31286	8e78a4d9-50d5-40e6-bcd8-fd3f57c31286	ثبت اسناد حسابداری هفتگی #94	\N	low	2026-07-27	b5cd86bf-8b06-4a38-966a-89a7536d5485	2026-07-20 11:11:03.957452+00	2026-07-20 11:11:03.957452+00	in_progress	\N	8	5.80	2026-07-25
4dcc3819-424c-4d09-9482-91ed2d9d19ab	\N	\N	5e03da3d-4fd1-4305-91ec-8a61bd1f28ee	5e03da3d-4fd1-4305-91ec-8a61bd1f28ee	ثبت اسناد حسابداری هفتگی #95	\N	high	2026-08-03	3e497368-61d8-4838-82ad-d10c4bcd75e8	2026-07-20 11:11:03.957452+00	2026-07-20 11:11:03.957452+00	completed	approved	100	3.70	2026-07-31
4dcc3819-424c-4d09-9482-91ed2d9d19ab	\N	\N	8d97ee0b-e8f3-4aec-ab48-db76ef6ede39	8d97ee0b-e8f3-4aec-ab48-db76ef6ede39	بررسی و تسویهٔ کارت اعتباری شرکت #96	\N	low	2026-07-28	0f524f5c-2d75-4e77-927b-907ccb607477	2026-07-20 11:11:03.957452+00	2026-07-20 11:11:03.957452+00	in_progress	\N	17	21.10	2026-07-20
4dcc3819-424c-4d09-9482-91ed2d9d19ab	\N	\N	5742bab4-624b-41df-aff7-c3517eed7f4c	5742bab4-624b-41df-aff7-c3517eed7f4c	تهیهٔ گزارش مالیاتی فصلی #97	\N	high	2026-08-27	47d11ffe-6f2f-4da2-9307-5197b012afa1	2026-07-20 11:11:03.957452+00	2026-07-20 11:11:03.957452+00	in_progress	\N	76	31.40	2026-08-07
4dcc3819-424c-4d09-9482-91ed2d9d19ab	\N	\N	d7465638-ca92-4b34-b9b1-b1ab5012de48	d7465638-ca92-4b34-b9b1-b1ab5012de48	بررسی قراردادهای مالی جدید #98	\N	low	2026-07-12	32089428-166a-4b7d-b5a9-16ced1d56764	2026-07-20 11:11:03.957452+00	2026-07-20 11:11:03.957452+00	in_progress	\N	66	10.40	2026-07-01
4dcc3819-424c-4d09-9482-91ed2d9d19ab	\N	\N	5742bab4-624b-41df-aff7-c3517eed7f4c	5742bab4-624b-41df-aff7-c3517eed7f4c	بررسی صورت وضعیت پیمانکاران #99	\N	high	2026-07-08	ad0fe2b1-2301-4f13-bb56-b72beb6bb74d	2026-07-20 11:11:03.957452+00	2026-07-20 11:11:03.957452+00	in_progress	\N	22	25.80	2026-06-19
4dcc3819-424c-4d09-9482-91ed2d9d19ab	\N	\N	8d97ee0b-e8f3-4aec-ab48-db76ef6ede39	8d97ee0b-e8f3-4aec-ab48-db76ef6ede39	بررسی و تسویهٔ کارت اعتباری شرکت #100	\N	high	2026-07-22	e1357c02-515d-4114-bf8c-d26b3d415118	2026-07-20 11:11:03.957452+00	2026-07-20 11:11:03.957452+00	completed	approved	100	14.10	2026-07-08
4dcc3819-424c-4d09-9482-91ed2d9d19ab	\N	\N	8d97ee0b-e8f3-4aec-ab48-db76ef6ede39	8d97ee0b-e8f3-4aec-ab48-db76ef6ede39	بررسی فاکتورهای فروش صادرشده #101	\N	low	2026-07-06	edaafe66-d145-4e82-9d93-464ec0a29b16	2026-07-20 11:11:03.957452+00	2026-07-20 11:11:03.957452+00	in_progress	\N	68	20.00	2026-06-25
4dcc3819-424c-4d09-9482-91ed2d9d19ab	\N	\N	d7465638-ca92-4b34-b9b1-b1ab5012de48	d7465638-ca92-4b34-b9b1-b1ab5012de48	بررسی و تسویهٔ کارت اعتباری شرکت #102	\N	medium	2026-07-11	66be4112-872d-4153-ab36-6aaeb7f84b75	2026-07-20 11:11:03.957452+00	2026-07-20 11:11:03.957452+00	in_progress	\N	7	23.40	2026-07-05
4dcc3819-424c-4d09-9482-91ed2d9d19ab	\N	\N	8d97ee0b-e8f3-4aec-ab48-db76ef6ede39	8d97ee0b-e8f3-4aec-ab48-db76ef6ede39	پیگیری مطالبات معوق مشتریان #103	\N	low	2026-07-19	cd08d129-70d3-4594-aeca-50691b1df1df	2026-07-20 11:11:03.957452+00	2026-07-20 11:11:03.957452+00	completed	approved	100	14.50	2026-07-10
4dcc3819-424c-4d09-9482-91ed2d9d19ab	\N	\N	5e03da3d-4fd1-4305-91ec-8a61bd1f28ee	5e03da3d-4fd1-4305-91ec-8a61bd1f28ee	تهیهٔ گزارش جریان نقدی #104	\N	low	2026-07-10	a3212536-ffa5-4dd1-a817-b72c5a8e2456	2026-07-20 11:11:03.957452+00	2026-07-20 11:11:03.957452+00	completed	pending	100	4.00	2026-06-21
4dcc3819-424c-4d09-9482-91ed2d9d19ab	\N	\N	8d97ee0b-e8f3-4aec-ab48-db76ef6ede39	8d97ee0b-e8f3-4aec-ab48-db76ef6ede39	ثبت اسناد حسابداری هفتگی #105	\N	high	2026-06-22	a0a80d7a-067f-469d-a990-b1e19b9aa3f0	2026-07-20 11:11:03.957452+00	2026-07-20 11:11:03.957452+00	completed	pending	100	29.50	2026-06-18
4dcc3819-424c-4d09-9482-91ed2d9d19ab	c6aa009d-ea9c-495f-a286-0555a1051213	\N	ac9072e5-ff0f-4d63-880d-330ba7a1645e	ac9072e5-ff0f-4d63-880d-330ba7a1645e	برگزاری نظرسنجی رضایت شغلی #1	\N	medium	2026-07-06	66d185ef-851a-44da-b7a7-19376684942f	2026-07-20 11:11:03.957452+00	2026-07-20 11:11:03.957452+00	archived	\N	67	15.60	2026-07-03
4dcc3819-424c-4d09-9482-91ed2d9d19ab	c6aa009d-ea9c-495f-a286-0555a1051213	\N	57aede22-e4a3-452e-8ade-22917514d015	ac9072e5-ff0f-4d63-880d-330ba7a1645e	برگزاری جلسهٔ آموزش کارکنان جدید #2	\N	high	2026-07-01	bf1de8e4-a319-4cc4-af33-540f6144774a	2026-07-20 11:11:03.957452+00	2026-07-20 11:11:03.957452+00	in_progress	\N	30	12.10	2026-06-26
4dcc3819-424c-4d09-9482-91ed2d9d19ab	c6aa009d-ea9c-495f-a286-0555a1051213	\N	c159ec20-f52f-44c6-a62b-b5579693a2e2	ac9072e5-ff0f-4d63-880d-330ba7a1645e	تدوین برنامهٔ آموزشی سال آینده #3	\N	medium	2026-06-28	5b91116c-e916-40ca-9323-e40a6c06ef94	2026-07-20 11:11:03.957452+00	2026-07-20 11:11:03.957452+00	archived	\N	45	37.50	2026-06-19
4dcc3819-424c-4d09-9482-91ed2d9d19ab	c6aa009d-ea9c-495f-a286-0555a1051213	\N	c159ec20-f52f-44c6-a62b-b5579693a2e2	ac9072e5-ff0f-4d63-880d-330ba7a1645e	تدوین برنامهٔ آموزشی سال آینده #4	\N	medium	2026-07-06	7c71090a-c7b8-4c03-b76f-33c02ee9e026	2026-07-20 11:11:03.957452+00	2026-07-20 11:11:03.957452+00	todo	\N	45	36.70	2026-06-27
4dcc3819-424c-4d09-9482-91ed2d9d19ab	c6aa009d-ea9c-495f-a286-0555a1051213	\N	ac9072e5-ff0f-4d63-880d-330ba7a1645e	ac9072e5-ff0f-4d63-880d-330ba7a1645e	تدوین برنامهٔ آموزشی سال آینده #5	\N	high	2026-08-12	1f4fa995-80be-421a-b446-1f21363212a6	2026-07-20 11:11:03.957452+00	2026-07-20 11:11:03.957452+00	archived	\N	18	23.40	2026-07-30
4dcc3819-424c-4d09-9482-91ed2d9d19ab	c6aa009d-ea9c-495f-a286-0555a1051213	\N	fbd6cd8f-ebe9-40af-a413-fa64b9419d5a	ac9072e5-ff0f-4d63-880d-330ba7a1645e	بررسی رزومه‌های متقاضیان شغلی #6	\N	low	2026-07-14	ada5bc47-ada1-4e3c-90b5-f95c4d5f1ebe	2026-07-20 11:11:03.957452+00	2026-07-20 11:11:03.957452+00	completed	approved	100	4.10	2026-06-27
4dcc3819-424c-4d09-9482-91ed2d9d19ab	c6aa009d-ea9c-495f-a286-0555a1051213	\N	57aede22-e4a3-452e-8ade-22917514d015	ac9072e5-ff0f-4d63-880d-330ba7a1645e	برنامه‌ریزی رویداد تیم‌سازی #7	\N	low	2026-07-05	bbe8141f-bd61-4095-aa93-b606ec028347	2026-07-20 11:11:03.957452+00	2026-07-20 11:11:03.957452+00	in_progress	\N	42	36.90	2026-06-17
4dcc3819-424c-4d09-9482-91ed2d9d19ab	c6aa009d-ea9c-495f-a286-0555a1051213	\N	fbd6cd8f-ebe9-40af-a413-fa64b9419d5a	ac9072e5-ff0f-4d63-880d-330ba7a1645e	بررسی درخواست ترفیع کارکنان #8	\N	medium	2026-07-14	edd0a333-93d9-47ec-8501-9dd7b5b1d88d	2026-07-20 11:11:03.957452+00	2026-07-20 11:11:03.957452+00	todo	\N	7	2.80	2026-07-07
4dcc3819-424c-4d09-9482-91ed2d9d19ab	c6aa009d-ea9c-495f-a286-0555a1051213	\N	57aede22-e4a3-452e-8ade-22917514d015	ac9072e5-ff0f-4d63-880d-330ba7a1645e	برگزاری نظرسنجی رضایت شغلی #9	\N	low	2026-08-19	758c2dba-201c-490c-8498-c2773e9eb9a7	2026-07-20 11:11:03.957452+00	2026-07-20 11:11:03.957452+00	archived	\N	67	34.70	2026-08-13
4dcc3819-424c-4d09-9482-91ed2d9d19ab	c6aa009d-ea9c-495f-a286-0555a1051213	\N	ac9072e5-ff0f-4d63-880d-330ba7a1645e	ac9072e5-ff0f-4d63-880d-330ba7a1645e	تدوین برنامهٔ آموزشی سال آینده #10	\N	low	2026-08-14	9f6418bd-3017-4450-b120-86cffe58920d	2026-07-20 11:11:03.957452+00	2026-07-20 11:11:03.957452+00	in_progress	\N	43	13.50	2026-07-31
4dcc3819-424c-4d09-9482-91ed2d9d19ab	c6aa009d-ea9c-495f-a286-0555a1051213	\N	fbd6cd8f-ebe9-40af-a413-fa64b9419d5a	ac9072e5-ff0f-4d63-880d-330ba7a1645e	برگزاری نظرسنجی رضایت شغلی #11	\N	high	2026-08-16	87074ca7-1c32-4d96-8fa1-f2aac2437b0d	2026-07-20 11:11:03.957452+00	2026-07-20 11:11:03.957452+00	todo	\N	62	26.70	2026-08-01
4dcc3819-424c-4d09-9482-91ed2d9d19ab	c6aa009d-ea9c-495f-a286-0555a1051213	\N	fbd6cd8f-ebe9-40af-a413-fa64b9419d5a	ac9072e5-ff0f-4d63-880d-330ba7a1645e	برگزاری نظرسنجی رضایت شغلی #12	\N	medium	2026-08-11	04080bbf-afa2-4665-b1f6-4ef5532f3854	2026-07-20 11:11:03.957452+00	2026-07-20 11:11:03.957452+00	archived	\N	28	27.30	2026-07-21
4dcc3819-424c-4d09-9482-91ed2d9d19ab	c6aa009d-ea9c-495f-a286-0555a1051213	\N	c159ec20-f52f-44c6-a62b-b5579693a2e2	ac9072e5-ff0f-4d63-880d-330ba7a1645e	به‌روزرسانی پروندهٔ پرسنلی #13	\N	high	2026-07-21	e9dd05f7-e8c1-4f05-8990-7099bed8b969	2026-07-20 11:11:03.957452+00	2026-07-20 11:11:03.957452+00	todo	\N	37	6.80	2026-07-10
4dcc3819-424c-4d09-9482-91ed2d9d19ab	c6aa009d-ea9c-495f-a286-0555a1051213	\N	0631f64d-7a8f-4a1f-b13c-6e22248209c5	ac9072e5-ff0f-4d63-880d-330ba7a1645e	تهیهٔ فرم ارزیابی سه‌ماهه #14	\N	high	2026-09-04	6cd8b6fa-6fb7-4dda-875e-ed2196492b0f	2026-07-20 11:11:03.957452+00	2026-07-20 11:11:03.957452+00	todo	\N	4	8.90	2026-08-15
4dcc3819-424c-4d09-9482-91ed2d9d19ab	c6aa009d-ea9c-495f-a286-0555a1051213	\N	3a5bbe57-a350-4aac-a8a7-02d037f0c644	ac9072e5-ff0f-4d63-880d-330ba7a1645e	بررسی درخواست ترفیع کارکنان #15	\N	medium	2026-07-27	c7ba8056-10fd-48ac-a5d6-aae54c756e52	2026-07-20 11:11:03.957452+00	2026-07-20 11:11:03.957452+00	completed	approved	100	7.30	2026-07-22
4dcc3819-424c-4d09-9482-91ed2d9d19ab	c6aa009d-ea9c-495f-a286-0555a1051213	\N	0631f64d-7a8f-4a1f-b13c-6e22248209c5	ac9072e5-ff0f-4d63-880d-330ba7a1645e	پیگیری درخواست‌های رفاهی کارکنان #16	\N	low	2026-07-14	19135289-5d51-4d67-95c9-3997387e5a56	2026-07-20 11:11:03.957452+00	2026-07-20 11:11:03.957452+00	todo	\N	11	33.20	2026-07-01
4dcc3819-424c-4d09-9482-91ed2d9d19ab	c6aa009d-ea9c-495f-a286-0555a1051213	\N	0631f64d-7a8f-4a1f-b13c-6e22248209c5	ac9072e5-ff0f-4d63-880d-330ba7a1645e	بررسی رزومه‌های متقاضیان شغلی #17	\N	medium	2026-07-23	88f14489-e39a-4611-bc6f-a0d4a00bee59	2026-07-20 11:11:03.957452+00	2026-07-20 11:11:03.957452+00	completed	pending	100	10.00	2026-07-07
4dcc3819-424c-4d09-9482-91ed2d9d19ab	c6aa009d-ea9c-495f-a286-0555a1051213	\N	0631f64d-7a8f-4a1f-b13c-6e22248209c5	ac9072e5-ff0f-4d63-880d-330ba7a1645e	برگزاری نظرسنجی رضایت شغلی #18	\N	low	2026-07-18	276b1c72-08a4-41ac-8f50-b71bb5f1e98d	2026-07-20 11:11:03.957452+00	2026-07-20 11:11:03.957452+00	todo	\N	0	3.80	2026-07-08
4dcc3819-424c-4d09-9482-91ed2d9d19ab	5d8c9706-dd1f-4e2c-9412-df9ea8285c7a	\N	ea1e6921-d2aa-44c0-978b-ff36b7d9fff2	ac9072e5-ff0f-4d63-880d-330ba7a1645e	بررسی درخواست ترفیع کارکنان #19	\N	medium	2026-07-19	a1d02e76-699e-4979-9169-c6df9a537f5a	2026-07-20 11:11:03.957452+00	2026-07-20 11:11:03.957452+00	archived	\N	63	35.50	2026-07-12
4dcc3819-424c-4d09-9482-91ed2d9d19ab	5d8c9706-dd1f-4e2c-9412-df9ea8285c7a	\N	3a5bbe57-a350-4aac-a8a7-02d037f0c644	ac9072e5-ff0f-4d63-880d-330ba7a1645e	برگزاری نظرسنجی رضایت شغلی #20	\N	high	2026-08-25	02fc6d47-21c2-489e-932c-91d7fce51c32	2026-07-20 11:11:03.957452+00	2026-07-20 11:11:03.957452+00	completed	approved	100	26.70	2026-08-08
4dcc3819-424c-4d09-9482-91ed2d9d19ab	5d8c9706-dd1f-4e2c-9412-df9ea8285c7a	\N	0631f64d-7a8f-4a1f-b13c-6e22248209c5	ac9072e5-ff0f-4d63-880d-330ba7a1645e	برنامه‌ریزی مصاحبهٔ استخدامی #21	\N	low	2026-07-12	98ccb7b4-5730-4ad6-8578-245eed7f8e13	2026-07-20 11:11:03.957452+00	2026-07-20 11:11:03.957452+00	in_progress	\N	37	2.80	2026-06-26
4dcc3819-424c-4d09-9482-91ed2d9d19ab	5d8c9706-dd1f-4e2c-9412-df9ea8285c7a	\N	3a5bbe57-a350-4aac-a8a7-02d037f0c644	ac9072e5-ff0f-4d63-880d-330ba7a1645e	تهیهٔ گزارش ارزیابی عملکرد #22	\N	medium	2026-07-02	247a1ec1-7c5f-4114-891e-164cdca6a9be	2026-07-20 11:11:03.957452+00	2026-07-20 11:11:03.957452+00	todo	\N	20	29.80	2026-06-20
4dcc3819-424c-4d09-9482-91ed2d9d19ab	5d8c9706-dd1f-4e2c-9412-df9ea8285c7a	\N	57aede22-e4a3-452e-8ade-22917514d015	ac9072e5-ff0f-4d63-880d-330ba7a1645e	تدوین برنامهٔ آموزشی سال آینده #23	\N	medium	2026-07-28	4678b6ac-e80b-4f47-b8a3-4dcbc0bb15c9	2026-07-20 11:11:03.957452+00	2026-07-20 11:11:03.957452+00	todo	\N	3	18.40	2026-07-07
4dcc3819-424c-4d09-9482-91ed2d9d19ab	5d8c9706-dd1f-4e2c-9412-df9ea8285c7a	\N	0631f64d-7a8f-4a1f-b13c-6e22248209c5	ac9072e5-ff0f-4d63-880d-330ba7a1645e	تهیهٔ گزارش ارزیابی عملکرد #24	\N	low	2026-08-08	19fbcd34-a2a0-4b8e-ab8f-5c18504eb581	2026-07-20 11:11:03.957452+00	2026-07-20 11:11:03.957452+00	todo	\N	12	14.60	2026-07-24
4dcc3819-424c-4d09-9482-91ed2d9d19ab	5d8c9706-dd1f-4e2c-9412-df9ea8285c7a	\N	fbd6cd8f-ebe9-40af-a413-fa64b9419d5a	ac9072e5-ff0f-4d63-880d-330ba7a1645e	به‌روزرسانی پروندهٔ پرسنلی #25	\N	high	2026-08-18	612ed3ab-0667-4243-8bfa-111545ed4876	2026-07-20 11:11:03.957452+00	2026-07-20 11:11:03.957452+00	in_progress	\N	69	12.10	2026-07-30
4dcc3819-424c-4d09-9482-91ed2d9d19ab	5d8c9706-dd1f-4e2c-9412-df9ea8285c7a	\N	3a5bbe57-a350-4aac-a8a7-02d037f0c644	ac9072e5-ff0f-4d63-880d-330ba7a1645e	بررسی رزومه‌های متقاضیان شغلی #26	\N	medium	2026-07-06	f91d4279-5084-4981-adce-ec6a76b161f5	2026-07-20 11:11:03.957452+00	2026-07-20 11:11:03.957452+00	in_progress	\N	73	22.90	2026-07-01
4dcc3819-424c-4d09-9482-91ed2d9d19ab	5d8c9706-dd1f-4e2c-9412-df9ea8285c7a	\N	ea1e6921-d2aa-44c0-978b-ff36b7d9fff2	ac9072e5-ff0f-4d63-880d-330ba7a1645e	بررسی رزومه‌های متقاضیان شغلی #27	\N	medium	2026-07-02	b7cb8d66-0ab1-4708-b761-2b12d11a019f	2026-07-20 11:11:03.957452+00	2026-07-20 11:11:03.957452+00	todo	\N	11	13.20	2026-06-19
4dcc3819-424c-4d09-9482-91ed2d9d19ab	5d8c9706-dd1f-4e2c-9412-df9ea8285c7a	\N	0631f64d-7a8f-4a1f-b13c-6e22248209c5	ac9072e5-ff0f-4d63-880d-330ba7a1645e	بررسی رزومه‌های متقاضیان شغلی #28	\N	low	2026-07-03	f2d3e5a7-898d-467a-86fd-c42a811b5361	2026-07-20 11:11:03.957452+00	2026-07-20 11:11:03.957452+00	completed	pending	100	8.50	2026-06-28
4dcc3819-424c-4d09-9482-91ed2d9d19ab	5d8c9706-dd1f-4e2c-9412-df9ea8285c7a	\N	3a5bbe57-a350-4aac-a8a7-02d037f0c644	ac9072e5-ff0f-4d63-880d-330ba7a1645e	به‌روزرسانی آیین‌نامهٔ داخلی شرکت #29	\N	medium	2026-07-21	5ffe1a27-3e0b-4136-ab45-923b051c20dc	2026-07-20 11:11:03.957452+00	2026-07-20 11:11:03.957452+00	todo	\N	60	20.60	2026-07-16
4dcc3819-424c-4d09-9482-91ed2d9d19ab	5d8c9706-dd1f-4e2c-9412-df9ea8285c7a	\N	0631f64d-7a8f-4a1f-b13c-6e22248209c5	ac9072e5-ff0f-4d63-880d-330ba7a1645e	تهیهٔ فرم ارزیابی سه‌ماهه #30	\N	low	2026-07-10	604e1e64-73d0-47c8-a9e4-8f51455664c4	2026-07-20 11:11:03.957452+00	2026-07-20 11:11:03.957452+00	in_progress	\N	47	35.60	2026-06-21
4dcc3819-424c-4d09-9482-91ed2d9d19ab	5d8c9706-dd1f-4e2c-9412-df9ea8285c7a	\N	3a5bbe57-a350-4aac-a8a7-02d037f0c644	ac9072e5-ff0f-4d63-880d-330ba7a1645e	به‌روزرسانی آیین‌نامهٔ داخلی شرکت #31	\N	medium	2026-07-17	90fa1ebc-208c-495c-ae27-f1cabdf3dabd	2026-07-20 11:11:03.957452+00	2026-07-20 11:11:03.957452+00	todo	\N	59	12.00	2026-07-14
4dcc3819-424c-4d09-9482-91ed2d9d19ab	5d8c9706-dd1f-4e2c-9412-df9ea8285c7a	\N	c159ec20-f52f-44c6-a62b-b5579693a2e2	ac9072e5-ff0f-4d63-880d-330ba7a1645e	تهیهٔ گزارش ارزیابی عملکرد #32	\N	high	2026-07-25	ab9073a5-4bc4-40f9-b809-d128a84a7730	2026-07-20 11:11:03.957452+00	2026-07-20 11:11:03.957452+00	in_progress	\N	12	5.30	2026-07-22
4dcc3819-424c-4d09-9482-91ed2d9d19ab	5d8c9706-dd1f-4e2c-9412-df9ea8285c7a	\N	3a5bbe57-a350-4aac-a8a7-02d037f0c644	ac9072e5-ff0f-4d63-880d-330ba7a1645e	برگزاری جلسهٔ آموزش کارکنان جدید #33	\N	high	2026-08-23	e68b9d53-ca29-4398-83fe-dc50cc6fa175	2026-07-20 11:11:03.957452+00	2026-07-20 11:11:03.957452+00	completed	approved	100	4.30	2026-08-03
4dcc3819-424c-4d09-9482-91ed2d9d19ab	5d8c9706-dd1f-4e2c-9412-df9ea8285c7a	\N	ea1e6921-d2aa-44c0-978b-ff36b7d9fff2	ac9072e5-ff0f-4d63-880d-330ba7a1645e	تدوین برنامهٔ آموزشی سال آینده #34	\N	low	2026-08-06	558b6559-0d60-4de4-8180-18fe5cb16b9d	2026-07-20 11:11:03.957452+00	2026-07-20 11:11:03.957452+00	completed	approved	100	20.10	2026-07-20
4dcc3819-424c-4d09-9482-91ed2d9d19ab	5d8c9706-dd1f-4e2c-9412-df9ea8285c7a	\N	ac9072e5-ff0f-4d63-880d-330ba7a1645e	ac9072e5-ff0f-4d63-880d-330ba7a1645e	بررسی و تمدید قراردادهای پرسنلی #35	\N	high	2026-08-15	aca7b0f7-213f-4634-b7f4-5286a01ef0ac	2026-07-20 11:11:03.957452+00	2026-07-20 11:11:03.957452+00	in_progress	\N	66	32.40	2026-08-12
4dcc3819-424c-4d09-9482-91ed2d9d19ab	5d8c9706-dd1f-4e2c-9412-df9ea8285c7a	\N	0631f64d-7a8f-4a1f-b13c-6e22248209c5	ac9072e5-ff0f-4d63-880d-330ba7a1645e	تهیهٔ گزارش ارزیابی عملکرد #36	\N	low	2026-08-31	9775b733-5ba9-4d65-9a83-a9ba5664b3ad	2026-07-20 11:11:03.957452+00	2026-07-20 11:11:03.957452+00	completed	approved	100	38.90	2026-08-15
4dcc3819-424c-4d09-9482-91ed2d9d19ab	bad8216b-b2f3-4ddb-acca-b5ab203499fc	\N	c159ec20-f52f-44c6-a62b-b5579693a2e2	ac9072e5-ff0f-4d63-880d-330ba7a1645e	تهیهٔ فرم ارزیابی سه‌ماهه #37	\N	low	2026-06-27	87a2bb5c-138c-47db-8709-087090e86d2f	2026-07-20 11:11:03.957452+00	2026-07-20 11:11:03.957452+00	todo	\N	55	9.70	2026-06-24
4dcc3819-424c-4d09-9482-91ed2d9d19ab	bad8216b-b2f3-4ddb-acca-b5ab203499fc	\N	c159ec20-f52f-44c6-a62b-b5579693a2e2	ac9072e5-ff0f-4d63-880d-330ba7a1645e	پیگیری درخواست‌های رفاهی کارکنان #38	\N	high	2026-08-03	3e57c0db-9163-4a73-9dde-2b382784d631	2026-07-20 11:11:03.957452+00	2026-07-20 11:11:03.957452+00	completed	approved	100	36.70	2026-07-24
4dcc3819-424c-4d09-9482-91ed2d9d19ab	bad8216b-b2f3-4ddb-acca-b5ab203499fc	\N	ac9072e5-ff0f-4d63-880d-330ba7a1645e	ac9072e5-ff0f-4d63-880d-330ba7a1645e	تهیهٔ فرم ارزیابی سه‌ماهه #39	\N	high	2026-07-29	797f3cf7-4b8d-43f5-b20b-f80109fda113	2026-07-20 11:11:03.957452+00	2026-07-20 11:11:03.957452+00	todo	\N	41	34.60	2026-07-10
4dcc3819-424c-4d09-9482-91ed2d9d19ab	bad8216b-b2f3-4ddb-acca-b5ab203499fc	\N	57aede22-e4a3-452e-8ade-22917514d015	ac9072e5-ff0f-4d63-880d-330ba7a1645e	تدوین برنامهٔ آموزشی سال آینده #40	\N	high	2026-07-07	d635c179-154f-486d-ab80-ed8844a9f8ab	2026-07-20 11:11:03.957452+00	2026-07-20 11:11:03.957452+00	completed	rejected	100	31.70	2026-06-16
4dcc3819-424c-4d09-9482-91ed2d9d19ab	bad8216b-b2f3-4ddb-acca-b5ab203499fc	\N	ac9072e5-ff0f-4d63-880d-330ba7a1645e	ac9072e5-ff0f-4d63-880d-330ba7a1645e	تدوین برنامهٔ آموزشی سال آینده #41	\N	high	2026-07-01	c3b77227-5c45-410b-a673-5b2635992d41	2026-07-20 11:11:03.957452+00	2026-07-20 11:11:03.957452+00	in_progress	\N	74	30.80	2026-06-25
4dcc3819-424c-4d09-9482-91ed2d9d19ab	bad8216b-b2f3-4ddb-acca-b5ab203499fc	\N	ac9072e5-ff0f-4d63-880d-330ba7a1645e	ac9072e5-ff0f-4d63-880d-330ba7a1645e	برگزاری نظرسنجی رضایت شغلی #42	\N	medium	2026-07-27	3da8b985-feff-4c68-b610-43301f9ad6ab	2026-07-20 11:11:03.957452+00	2026-07-20 11:11:03.957452+00	todo	\N	68	35.40	2026-07-22
4dcc3819-424c-4d09-9482-91ed2d9d19ab	bad8216b-b2f3-4ddb-acca-b5ab203499fc	\N	ea1e6921-d2aa-44c0-978b-ff36b7d9fff2	ac9072e5-ff0f-4d63-880d-330ba7a1645e	تدوین برنامهٔ آموزشی سال آینده #43	\N	high	2026-07-27	c65d64f4-c318-48f1-9cbe-d7df69aafd50	2026-07-20 11:11:03.957452+00	2026-07-20 11:11:03.957452+00	in_progress	\N	60	3.40	2026-07-10
4dcc3819-424c-4d09-9482-91ed2d9d19ab	bad8216b-b2f3-4ddb-acca-b5ab203499fc	\N	3a5bbe57-a350-4aac-a8a7-02d037f0c644	ac9072e5-ff0f-4d63-880d-330ba7a1645e	تدوین برنامهٔ آموزشی سال آینده #44	\N	high	2026-07-16	9af6a4c8-cff7-4ae5-982a-d0a84e4b4fd0	2026-07-20 11:11:03.957452+00	2026-07-20 11:11:03.957452+00	in_progress	\N	51	3.50	2026-06-25
4dcc3819-424c-4d09-9482-91ed2d9d19ab	bad8216b-b2f3-4ddb-acca-b5ab203499fc	\N	3a5bbe57-a350-4aac-a8a7-02d037f0c644	ac9072e5-ff0f-4d63-880d-330ba7a1645e	بررسی درخواست ترفیع کارکنان #45	\N	medium	2026-08-19	852e6f39-de5f-460f-a9c4-fdc825b216ce	2026-07-20 11:11:03.957452+00	2026-07-20 11:11:03.957452+00	completed	approved	100	36.10	2026-08-02
4dcc3819-424c-4d09-9482-91ed2d9d19ab	bad8216b-b2f3-4ddb-acca-b5ab203499fc	\N	ac9072e5-ff0f-4d63-880d-330ba7a1645e	ac9072e5-ff0f-4d63-880d-330ba7a1645e	به‌روزرسانی آیین‌نامهٔ داخلی شرکت #46	\N	medium	2026-08-18	18d8e9bb-96f1-4aa7-b07f-2dbccfdcd384	2026-07-20 11:11:03.957452+00	2026-07-20 11:11:03.957452+00	in_progress	\N	62	34.60	2026-08-07
4dcc3819-424c-4d09-9482-91ed2d9d19ab	bad8216b-b2f3-4ddb-acca-b5ab203499fc	\N	0631f64d-7a8f-4a1f-b13c-6e22248209c5	ac9072e5-ff0f-4d63-880d-330ba7a1645e	تهیهٔ گزارش ارزیابی عملکرد #47	\N	medium	2026-08-19	3eb4218d-daed-49f9-94aa-e67768511c91	2026-07-20 11:11:03.957452+00	2026-07-20 11:11:03.957452+00	todo	\N	56	31.40	2026-08-10
4dcc3819-424c-4d09-9482-91ed2d9d19ab	bad8216b-b2f3-4ddb-acca-b5ab203499fc	\N	3a5bbe57-a350-4aac-a8a7-02d037f0c644	ac9072e5-ff0f-4d63-880d-330ba7a1645e	تدوین برنامهٔ آموزشی سال آینده #48	\N	high	2026-08-16	9b840f37-8825-4e84-9e11-1c08d0d51ee9	2026-07-20 11:11:03.957452+00	2026-07-20 11:11:03.957452+00	in_progress	\N	11	9.10	2026-08-01
4dcc3819-424c-4d09-9482-91ed2d9d19ab	bad8216b-b2f3-4ddb-acca-b5ab203499fc	\N	fbd6cd8f-ebe9-40af-a413-fa64b9419d5a	ac9072e5-ff0f-4d63-880d-330ba7a1645e	برگزاری نظرسنجی رضایت شغلی #49	\N	high	2026-08-19	99bb9ae6-ac6a-4e70-9dd0-a32e04caa315	2026-07-20 11:11:03.957452+00	2026-07-20 11:11:03.957452+00	in_progress	\N	47	33.20	2026-08-02
4dcc3819-424c-4d09-9482-91ed2d9d19ab	bad8216b-b2f3-4ddb-acca-b5ab203499fc	\N	57aede22-e4a3-452e-8ade-22917514d015	ac9072e5-ff0f-4d63-880d-330ba7a1645e	به‌روزرسانی پروندهٔ پرسنلی #50	\N	high	2026-07-01	e72bd0d3-cf87-4bd3-b3ff-92ba778259e2	2026-07-20 11:11:03.957452+00	2026-07-20 11:11:03.957452+00	todo	\N	51	7.20	2026-06-20
4dcc3819-424c-4d09-9482-91ed2d9d19ab	bad8216b-b2f3-4ddb-acca-b5ab203499fc	\N	c159ec20-f52f-44c6-a62b-b5579693a2e2	ac9072e5-ff0f-4d63-880d-330ba7a1645e	برگزاری جلسهٔ آموزش کارکنان جدید #51	\N	low	2026-06-24	840e8321-8226-4743-bb2b-cf1b89ca7d26	2026-07-20 11:11:03.957452+00	2026-07-20 11:11:03.957452+00	completed	pending	100	33.80	2026-06-17
4dcc3819-424c-4d09-9482-91ed2d9d19ab	bad8216b-b2f3-4ddb-acca-b5ab203499fc	\N	fbd6cd8f-ebe9-40af-a413-fa64b9419d5a	ac9072e5-ff0f-4d63-880d-330ba7a1645e	بررسی درخواست ترفیع کارکنان #52	\N	medium	2026-07-18	b38b7f10-4f3a-4057-9ddf-c7b1388e279a	2026-07-20 11:11:03.957452+00	2026-07-20 11:11:03.957452+00	todo	\N	25	12.40	2026-07-15
4dcc3819-424c-4d09-9482-91ed2d9d19ab	bad8216b-b2f3-4ddb-acca-b5ab203499fc	\N	c159ec20-f52f-44c6-a62b-b5579693a2e2	ac9072e5-ff0f-4d63-880d-330ba7a1645e	پیگیری مرخصی و مأموریت کارکنان #53	\N	low	2026-07-31	d43c535d-a946-476d-ab11-ddc95ae1840d	2026-07-20 11:11:03.957452+00	2026-07-20 11:11:03.957452+00	completed	approved	100	11.20	2026-07-26
4dcc3819-424c-4d09-9482-91ed2d9d19ab	bad8216b-b2f3-4ddb-acca-b5ab203499fc	\N	ea1e6921-d2aa-44c0-978b-ff36b7d9fff2	ac9072e5-ff0f-4d63-880d-330ba7a1645e	تدوین برنامهٔ آموزشی سال آینده #54	\N	high	2026-08-27	f34068c7-ce0a-43a5-be82-7e5a79480fcd	2026-07-20 11:11:03.957452+00	2026-07-20 11:11:03.957452+00	completed	approved	100	15.30	2026-08-10
4dcc3819-424c-4d09-9482-91ed2d9d19ab	061a037c-86e9-4699-a76d-8a1b0c7c4bc2	\N	fbd6cd8f-ebe9-40af-a413-fa64b9419d5a	ac9072e5-ff0f-4d63-880d-330ba7a1645e	به‌روزرسانی آیین‌نامهٔ داخلی شرکت #55	\N	low	2026-08-06	d76b1069-1aec-4c5e-ba32-a5569d21a951	2026-07-20 11:11:03.957452+00	2026-07-20 11:11:03.957452+00	in_progress	\N	49	3.90	2026-08-02
4dcc3819-424c-4d09-9482-91ed2d9d19ab	061a037c-86e9-4699-a76d-8a1b0c7c4bc2	\N	c159ec20-f52f-44c6-a62b-b5579693a2e2	ac9072e5-ff0f-4d63-880d-330ba7a1645e	پیگیری مرخصی و مأموریت کارکنان #56	\N	low	2026-07-08	8857ea02-d6c2-4b60-bbb9-ed2e21f8edb4	2026-07-20 11:11:03.957452+00	2026-07-20 11:11:03.957452+00	completed	pending	100	27.80	2026-06-29
4dcc3819-424c-4d09-9482-91ed2d9d19ab	061a037c-86e9-4699-a76d-8a1b0c7c4bc2	\N	3a5bbe57-a350-4aac-a8a7-02d037f0c644	ac9072e5-ff0f-4d63-880d-330ba7a1645e	برنامه‌ریزی رویداد تیم‌سازی #57	\N	low	2026-06-19	bf65a4ae-6724-49ad-bc25-24a4d4ced8b2	2026-07-20 11:11:03.957452+00	2026-07-20 11:11:03.957452+00	completed	approved	100	26.60	2026-06-17
4dcc3819-424c-4d09-9482-91ed2d9d19ab	061a037c-86e9-4699-a76d-8a1b0c7c4bc2	\N	57aede22-e4a3-452e-8ade-22917514d015	ac9072e5-ff0f-4d63-880d-330ba7a1645e	تدوین برنامهٔ آموزشی سال آینده #58	\N	medium	2026-07-10	55d13840-f3d7-4518-beae-62d4d2a533e9	2026-07-20 11:11:03.957452+00	2026-07-20 11:11:03.957452+00	todo	\N	35	18.10	2026-06-30
4dcc3819-424c-4d09-9482-91ed2d9d19ab	061a037c-86e9-4699-a76d-8a1b0c7c4bc2	\N	ea1e6921-d2aa-44c0-978b-ff36b7d9fff2	ac9072e5-ff0f-4d63-880d-330ba7a1645e	برگزاری جلسهٔ آموزش کارکنان جدید #59	\N	medium	2026-07-25	f2f01099-76c0-481b-9cd2-0a26a448b0b8	2026-07-20 11:11:03.957452+00	2026-07-20 11:11:03.957452+00	in_progress	\N	38	27.70	2026-07-15
4dcc3819-424c-4d09-9482-91ed2d9d19ab	061a037c-86e9-4699-a76d-8a1b0c7c4bc2	\N	c159ec20-f52f-44c6-a62b-b5579693a2e2	ac9072e5-ff0f-4d63-880d-330ba7a1645e	بررسی و تمدید قراردادهای پرسنلی #60	\N	high	2026-06-24	8829350e-47b9-4a12-b7cb-0a567cf6edbe	2026-07-20 11:11:03.957452+00	2026-07-20 11:11:03.957452+00	completed	approved	100	38.70	2026-06-22
4dcc3819-424c-4d09-9482-91ed2d9d19ab	061a037c-86e9-4699-a76d-8a1b0c7c4bc2	\N	c159ec20-f52f-44c6-a62b-b5579693a2e2	ac9072e5-ff0f-4d63-880d-330ba7a1645e	تدوین برنامهٔ آموزشی سال آینده #61	\N	medium	2026-08-11	994f4477-7960-42fa-b5c2-363f4f51e217	2026-07-20 11:11:03.957452+00	2026-07-20 11:11:03.957452+00	in_progress	\N	38	28.00	2026-07-21
4dcc3819-424c-4d09-9482-91ed2d9d19ab	061a037c-86e9-4699-a76d-8a1b0c7c4bc2	\N	ea1e6921-d2aa-44c0-978b-ff36b7d9fff2	ac9072e5-ff0f-4d63-880d-330ba7a1645e	پیگیری مرخصی و مأموریت کارکنان #62	\N	medium	2026-07-17	2ca0b363-def5-4cad-abba-12e8ac4dd621	2026-07-20 11:11:03.957452+00	2026-07-20 11:11:03.957452+00	todo	\N	35	11.90	2026-07-07
4dcc3819-424c-4d09-9482-91ed2d9d19ab	061a037c-86e9-4699-a76d-8a1b0c7c4bc2	\N	0631f64d-7a8f-4a1f-b13c-6e22248209c5	ac9072e5-ff0f-4d63-880d-330ba7a1645e	برگزاری نظرسنجی رضایت شغلی #63	\N	low	2026-07-13	d75153f8-36c0-41d6-80cb-e3d0f40173a2	2026-07-20 11:11:03.957452+00	2026-07-20 11:11:03.957452+00	completed	approved	100	36.20	2026-06-25
4dcc3819-424c-4d09-9482-91ed2d9d19ab	061a037c-86e9-4699-a76d-8a1b0c7c4bc2	\N	c159ec20-f52f-44c6-a62b-b5579693a2e2	ac9072e5-ff0f-4d63-880d-330ba7a1645e	به‌روزرسانی پروندهٔ پرسنلی #64	\N	low	2026-07-12	ba50d725-d9cc-4488-a7cd-01276e08b1af	2026-07-20 11:11:03.957452+00	2026-07-20 11:11:03.957452+00	completed	approved	100	26.90	2026-07-06
4dcc3819-424c-4d09-9482-91ed2d9d19ab	061a037c-86e9-4699-a76d-8a1b0c7c4bc2	\N	3a5bbe57-a350-4aac-a8a7-02d037f0c644	ac9072e5-ff0f-4d63-880d-330ba7a1645e	تهیهٔ فرم ارزیابی سه‌ماهه #65	\N	medium	2026-08-28	54a1e824-9a2a-4b96-a866-82e4b4a3b4b3	2026-07-20 11:11:03.957452+00	2026-07-20 11:11:03.957452+00	in_progress	\N	4	24.20	2026-08-13
4dcc3819-424c-4d09-9482-91ed2d9d19ab	061a037c-86e9-4699-a76d-8a1b0c7c4bc2	\N	57aede22-e4a3-452e-8ade-22917514d015	ac9072e5-ff0f-4d63-880d-330ba7a1645e	پیگیری مرخصی و مأموریت کارکنان #66	\N	high	2026-07-16	2393b3cc-7394-4c1a-8061-9797be8eca14	2026-07-20 11:11:03.957452+00	2026-07-20 11:11:03.957452+00	todo	\N	60	36.40	2026-07-07
4dcc3819-424c-4d09-9482-91ed2d9d19ab	061a037c-86e9-4699-a76d-8a1b0c7c4bc2	\N	0631f64d-7a8f-4a1f-b13c-6e22248209c5	ac9072e5-ff0f-4d63-880d-330ba7a1645e	تهیهٔ گزارش غیبت و تأخیر #67	\N	low	2026-07-29	2c401f6e-dfcb-4003-aac4-678cbc110498	2026-07-20 11:11:03.957452+00	2026-07-20 11:11:03.957452+00	in_progress	\N	71	8.90	2026-07-18
4dcc3819-424c-4d09-9482-91ed2d9d19ab	061a037c-86e9-4699-a76d-8a1b0c7c4bc2	\N	ac9072e5-ff0f-4d63-880d-330ba7a1645e	ac9072e5-ff0f-4d63-880d-330ba7a1645e	برگزاری نظرسنجی رضایت شغلی #68	\N	low	2026-07-21	5582939c-a8c6-4202-9495-bb3cc76314a6	2026-07-20 11:11:03.957452+00	2026-07-20 11:11:03.957452+00	completed	approved	100	38.00	2026-07-02
4dcc3819-424c-4d09-9482-91ed2d9d19ab	061a037c-86e9-4699-a76d-8a1b0c7c4bc2	\N	3a5bbe57-a350-4aac-a8a7-02d037f0c644	ac9072e5-ff0f-4d63-880d-330ba7a1645e	به‌روزرسانی پروندهٔ پرسنلی #69	\N	medium	2026-07-17	82172cb4-11e3-462b-b07d-0dda985427a3	2026-07-20 11:11:03.957452+00	2026-07-20 11:11:03.957452+00	completed	approved	100	18.00	2026-07-08
4dcc3819-424c-4d09-9482-91ed2d9d19ab	061a037c-86e9-4699-a76d-8a1b0c7c4bc2	\N	3a5bbe57-a350-4aac-a8a7-02d037f0c644	ac9072e5-ff0f-4d63-880d-330ba7a1645e	به‌روزرسانی آیین‌نامهٔ داخلی شرکت #70	\N	medium	2026-07-22	96f673fc-9332-48ac-b2e9-9a50d8a40f8b	2026-07-20 11:11:03.957452+00	2026-07-20 11:11:03.957452+00	in_progress	\N	15	19.90	2026-07-02
4dcc3819-424c-4d09-9482-91ed2d9d19ab	061a037c-86e9-4699-a76d-8a1b0c7c4bc2	\N	c159ec20-f52f-44c6-a62b-b5579693a2e2	ac9072e5-ff0f-4d63-880d-330ba7a1645e	برنامه‌ریزی مصاحبهٔ استخدامی #71	\N	medium	2026-09-05	a96e0cdc-0846-49e1-95ab-2eef23819a93	2026-07-20 11:11:03.957452+00	2026-07-20 11:11:03.957452+00	completed	approved	100	35.80	2026-08-15
4dcc3819-424c-4d09-9482-91ed2d9d19ab	061a037c-86e9-4699-a76d-8a1b0c7c4bc2	\N	57aede22-e4a3-452e-8ade-22917514d015	ac9072e5-ff0f-4d63-880d-330ba7a1645e	بررسی و تمدید قراردادهای پرسنلی #72	\N	medium	2026-08-24	62c67720-5de4-403f-92e4-70d01a4ba14e	2026-07-20 11:11:03.957452+00	2026-07-20 11:11:03.957452+00	todo	\N	52	4.10	2026-08-10
4dcc3819-424c-4d09-9482-91ed2d9d19ab	f9fdf4eb-972d-4c59-9e96-24e6388d7053	\N	c159ec20-f52f-44c6-a62b-b5579693a2e2	ac9072e5-ff0f-4d63-880d-330ba7a1645e	پیگیری درخواست‌های رفاهی کارکنان #73	\N	medium	2026-07-02	a6957df9-b817-4636-b300-6cba0620ca9c	2026-07-20 11:11:03.957452+00	2026-07-20 11:11:03.957452+00	todo	\N	72	35.90	2026-06-24
4dcc3819-424c-4d09-9482-91ed2d9d19ab	f9fdf4eb-972d-4c59-9e96-24e6388d7053	\N	ea1e6921-d2aa-44c0-978b-ff36b7d9fff2	ac9072e5-ff0f-4d63-880d-330ba7a1645e	برگزاری نظرسنجی رضایت شغلی #74	\N	low	2026-07-13	5b241ac9-ab10-4c01-a2ec-c800272e4515	2026-07-20 11:11:03.957452+00	2026-07-20 11:11:03.957452+00	todo	\N	62	14.60	2026-07-06
4dcc3819-424c-4d09-9482-91ed2d9d19ab	f9fdf4eb-972d-4c59-9e96-24e6388d7053	\N	fbd6cd8f-ebe9-40af-a413-fa64b9419d5a	ac9072e5-ff0f-4d63-880d-330ba7a1645e	بررسی رزومه‌های متقاضیان شغلی #75	\N	medium	2026-07-29	9994f419-8039-4aea-8c70-dc26f1de02d8	2026-07-20 11:11:03.957452+00	2026-07-20 11:11:03.957452+00	in_progress	\N	35	10.00	2026-07-26
4dcc3819-424c-4d09-9482-91ed2d9d19ab	f9fdf4eb-972d-4c59-9e96-24e6388d7053	\N	c159ec20-f52f-44c6-a62b-b5579693a2e2	ac9072e5-ff0f-4d63-880d-330ba7a1645e	برنامه‌ریزی رویداد تیم‌سازی #76	\N	low	2026-07-29	067d2f30-930d-49d7-b6a9-22a045baba68	2026-07-20 11:11:03.957452+00	2026-07-20 11:11:03.957452+00	todo	\N	16	25.40	2026-07-22
4dcc3819-424c-4d09-9482-91ed2d9d19ab	f9fdf4eb-972d-4c59-9e96-24e6388d7053	\N	0631f64d-7a8f-4a1f-b13c-6e22248209c5	ac9072e5-ff0f-4d63-880d-330ba7a1645e	برنامه‌ریزی رویداد تیم‌سازی #77	\N	medium	2026-07-26	5092ef86-2ad5-4fa4-b89b-2bfea7f42408	2026-07-20 11:11:03.957452+00	2026-07-20 11:11:03.957452+00	in_progress	\N	0	3.40	2026-07-11
4dcc3819-424c-4d09-9482-91ed2d9d19ab	f9fdf4eb-972d-4c59-9e96-24e6388d7053	\N	fbd6cd8f-ebe9-40af-a413-fa64b9419d5a	ac9072e5-ff0f-4d63-880d-330ba7a1645e	بررسی درخواست ترفیع کارکنان #78	\N	medium	2026-07-11	f89a00e0-c6ea-44dd-8ea9-bb22af97189a	2026-07-20 11:11:03.957452+00	2026-07-20 11:11:03.957452+00	archived	\N	67	9.20	2026-07-09
4dcc3819-424c-4d09-9482-91ed2d9d19ab	f9fdf4eb-972d-4c59-9e96-24e6388d7053	\N	0631f64d-7a8f-4a1f-b13c-6e22248209c5	ac9072e5-ff0f-4d63-880d-330ba7a1645e	برگزاری جلسهٔ آموزش کارکنان جدید #79	\N	high	2026-08-04	23921ddd-9951-4e20-ab33-754285ae5565	2026-07-20 11:11:03.957452+00	2026-07-20 11:11:03.957452+00	todo	\N	44	13.90	2026-07-26
4dcc3819-424c-4d09-9482-91ed2d9d19ab	f9fdf4eb-972d-4c59-9e96-24e6388d7053	\N	ac9072e5-ff0f-4d63-880d-330ba7a1645e	ac9072e5-ff0f-4d63-880d-330ba7a1645e	به‌روزرسانی آیین‌نامهٔ داخلی شرکت #80	\N	low	2026-08-07	d0145a8f-d8a0-4aea-889e-176b83d30096	2026-07-20 11:11:03.957452+00	2026-07-20 11:11:03.957452+00	in_progress	\N	8	33.30	2026-07-18
4dcc3819-424c-4d09-9482-91ed2d9d19ab	f9fdf4eb-972d-4c59-9e96-24e6388d7053	\N	3a5bbe57-a350-4aac-a8a7-02d037f0c644	ac9072e5-ff0f-4d63-880d-330ba7a1645e	تدوین برنامهٔ آموزشی سال آینده #81	\N	high	2026-08-02	5bea899f-f875-4671-8458-fec124ca740f	2026-07-20 11:11:03.957452+00	2026-07-20 11:11:03.957452+00	in_progress	\N	43	18.50	2026-07-15
4dcc3819-424c-4d09-9482-91ed2d9d19ab	f9fdf4eb-972d-4c59-9e96-24e6388d7053	\N	0631f64d-7a8f-4a1f-b13c-6e22248209c5	ac9072e5-ff0f-4d63-880d-330ba7a1645e	پیگیری درخواست‌های رفاهی کارکنان #82	\N	low	2026-07-24	8f627fdd-8bc4-4cd9-a18f-a928df4addac	2026-07-20 11:11:03.957452+00	2026-07-20 11:11:03.957452+00	todo	\N	21	38.00	2026-07-07
4dcc3819-424c-4d09-9482-91ed2d9d19ab	f9fdf4eb-972d-4c59-9e96-24e6388d7053	\N	c159ec20-f52f-44c6-a62b-b5579693a2e2	ac9072e5-ff0f-4d63-880d-330ba7a1645e	برگزاری جلسهٔ آموزش کارکنان جدید #83	\N	high	2026-06-26	382836eb-0786-41c4-82e9-a9c9c3537285	2026-07-20 11:11:03.957452+00	2026-07-20 11:11:03.957452+00	in_progress	\N	16	10.00	2026-06-17
4dcc3819-424c-4d09-9482-91ed2d9d19ab	f9fdf4eb-972d-4c59-9e96-24e6388d7053	\N	ac9072e5-ff0f-4d63-880d-330ba7a1645e	ac9072e5-ff0f-4d63-880d-330ba7a1645e	به‌روزرسانی پروندهٔ پرسنلی #84	\N	high	2026-07-06	cc5adbd1-fc26-4771-8b92-5ae77770353e	2026-07-20 11:11:03.957452+00	2026-07-20 11:11:03.957452+00	completed	approved	100	32.10	2026-06-23
4dcc3819-424c-4d09-9482-91ed2d9d19ab	f9fdf4eb-972d-4c59-9e96-24e6388d7053	\N	ea1e6921-d2aa-44c0-978b-ff36b7d9fff2	ac9072e5-ff0f-4d63-880d-330ba7a1645e	بررسی رزومه‌های متقاضیان شغلی #85	\N	high	2026-08-10	3194b873-443a-4437-b347-de8bd7446fbb	2026-07-20 11:11:03.957452+00	2026-07-20 11:11:03.957452+00	completed	approved	100	39.80	2026-07-20
4dcc3819-424c-4d09-9482-91ed2d9d19ab	f9fdf4eb-972d-4c59-9e96-24e6388d7053	\N	0631f64d-7a8f-4a1f-b13c-6e22248209c5	ac9072e5-ff0f-4d63-880d-330ba7a1645e	بررسی رزومه‌های متقاضیان شغلی #86	\N	high	2026-07-29	d74ce5f4-faed-4aa3-98e3-10cfdfd859f2	2026-07-20 11:11:03.957452+00	2026-07-20 11:11:03.957452+00	todo	\N	14	17.80	2026-07-27
4dcc3819-424c-4d09-9482-91ed2d9d19ab	f9fdf4eb-972d-4c59-9e96-24e6388d7053	\N	ea1e6921-d2aa-44c0-978b-ff36b7d9fff2	ac9072e5-ff0f-4d63-880d-330ba7a1645e	برنامه‌ریزی رویداد تیم‌سازی #87	\N	high	2026-07-31	9848fcbe-3153-4f5b-bfc2-0e7d311fdf1b	2026-07-20 11:11:03.957452+00	2026-07-20 11:11:03.957452+00	todo	\N	19	9.80	2026-07-21
4dcc3819-424c-4d09-9482-91ed2d9d19ab	f9fdf4eb-972d-4c59-9e96-24e6388d7053	\N	0631f64d-7a8f-4a1f-b13c-6e22248209c5	ac9072e5-ff0f-4d63-880d-330ba7a1645e	پیگیری مرخصی و مأموریت کارکنان #88	\N	high	2026-07-17	dc7cd50f-f2ec-417b-bbc1-5c84caaad9da	2026-07-20 11:11:03.957452+00	2026-07-20 11:11:03.957452+00	completed	approved	100	12.30	2026-07-12
4dcc3819-424c-4d09-9482-91ed2d9d19ab	f9fdf4eb-972d-4c59-9e96-24e6388d7053	\N	57aede22-e4a3-452e-8ade-22917514d015	ac9072e5-ff0f-4d63-880d-330ba7a1645e	بررسی و تمدید قراردادهای پرسنلی #89	\N	high	2026-08-13	be739564-4c45-414d-8e4b-3877515faddb	2026-07-20 11:11:03.957452+00	2026-07-20 11:11:03.957452+00	completed	approved	100	25.50	2026-08-08
4dcc3819-424c-4d09-9482-91ed2d9d19ab	f9fdf4eb-972d-4c59-9e96-24e6388d7053	\N	3a5bbe57-a350-4aac-a8a7-02d037f0c644	ac9072e5-ff0f-4d63-880d-330ba7a1645e	برنامه‌ریزی رویداد تیم‌سازی #90	\N	low	2026-08-10	265b216a-7113-4af7-9590-97ae2f543feb	2026-07-20 11:11:03.957452+00	2026-07-20 11:11:03.957452+00	todo	\N	77	9.60	2026-08-05
4dcc3819-424c-4d09-9482-91ed2d9d19ab	\N	\N	3a5bbe57-a350-4aac-a8a7-02d037f0c644	3a5bbe57-a350-4aac-a8a7-02d037f0c644	به‌روزرسانی آیین‌نامهٔ داخلی شرکت #91	\N	low	2026-07-23	20a3a982-0de8-4a08-b43f-03086897e8ae	2026-07-20 11:11:03.957452+00	2026-07-20 11:11:03.957452+00	completed	rejected	100	3.50	2026-07-08
4dcc3819-424c-4d09-9482-91ed2d9d19ab	\N	\N	ea1e6921-d2aa-44c0-978b-ff36b7d9fff2	ea1e6921-d2aa-44c0-978b-ff36b7d9fff2	پیگیری درخواست‌های رفاهی کارکنان #92	\N	low	2026-08-16	106de1b8-0b17-4ac5-955f-fd50b81883a5	2026-07-20 11:11:03.957452+00	2026-07-20 11:11:03.957452+00	in_progress	\N	0	2.50	2026-07-30
4dcc3819-424c-4d09-9482-91ed2d9d19ab	\N	\N	ac9072e5-ff0f-4d63-880d-330ba7a1645e	ac9072e5-ff0f-4d63-880d-330ba7a1645e	پیگیری مرخصی و مأموریت کارکنان #93	\N	medium	2026-08-28	9a32818e-b45b-442a-b837-cbf1010d0f4b	2026-07-20 11:11:03.957452+00	2026-07-20 11:11:03.957452+00	todo	\N	19	38.10	2026-08-08
4dcc3819-424c-4d09-9482-91ed2d9d19ab	\N	\N	c159ec20-f52f-44c6-a62b-b5579693a2e2	c159ec20-f52f-44c6-a62b-b5579693a2e2	بررسی درخواست ترفیع کارکنان #94	\N	medium	2026-08-06	3db5ea5c-e5b2-4b13-863d-009b3c9f4e3d	2026-07-20 11:11:03.957452+00	2026-07-20 11:11:03.957452+00	completed	approved	100	26.50	2026-08-01
4dcc3819-424c-4d09-9482-91ed2d9d19ab	\N	\N	ea1e6921-d2aa-44c0-978b-ff36b7d9fff2	ea1e6921-d2aa-44c0-978b-ff36b7d9fff2	بررسی رزومه‌های متقاضیان شغلی #95	\N	low	2026-07-18	591e1251-7e5c-4053-9055-1e7d9c9da7ed	2026-07-20 11:11:03.957452+00	2026-07-20 11:11:03.957452+00	in_progress	\N	22	35.20	2026-07-02
4dcc3819-424c-4d09-9482-91ed2d9d19ab	\N	\N	c159ec20-f52f-44c6-a62b-b5579693a2e2	c159ec20-f52f-44c6-a62b-b5579693a2e2	تهیهٔ فرم ارزیابی سه‌ماهه #96	\N	high	2026-07-21	08516d02-0f69-4278-a6c1-b8b7ea81882e	2026-07-20 11:11:03.957452+00	2026-07-20 11:11:03.957452+00	in_progress	\N	14	5.60	2026-07-09
4dcc3819-424c-4d09-9482-91ed2d9d19ab	\N	\N	c159ec20-f52f-44c6-a62b-b5579693a2e2	c159ec20-f52f-44c6-a62b-b5579693a2e2	پیگیری مرخصی و مأموریت کارکنان #97	\N	high	2026-06-22	be26e5c8-b270-423c-8459-8c38c35ea779	2026-07-20 11:11:03.957452+00	2026-07-20 11:11:03.957452+00	todo	\N	21	14.50	2026-06-16
4dcc3819-424c-4d09-9482-91ed2d9d19ab	\N	\N	ea1e6921-d2aa-44c0-978b-ff36b7d9fff2	ea1e6921-d2aa-44c0-978b-ff36b7d9fff2	پیگیری درخواست‌های رفاهی کارکنان #98	\N	medium	2026-08-05	4c26af3f-32f7-4ef2-bd23-29b230be4e52	2026-07-20 11:11:03.957452+00	2026-07-20 11:11:03.957452+00	completed	approved	100	8.90	2026-08-01
4dcc3819-424c-4d09-9482-91ed2d9d19ab	\N	\N	ea1e6921-d2aa-44c0-978b-ff36b7d9fff2	ea1e6921-d2aa-44c0-978b-ff36b7d9fff2	تهیهٔ گزارش غیبت و تأخیر #99	\N	medium	2026-07-25	07b79ded-0be0-4e1b-bed9-2a803be46ca0	2026-07-20 11:11:03.957452+00	2026-07-20 11:11:03.957452+00	in_progress	\N	61	32.40	2026-07-15
4dcc3819-424c-4d09-9482-91ed2d9d19ab	\N	\N	0631f64d-7a8f-4a1f-b13c-6e22248209c5	0631f64d-7a8f-4a1f-b13c-6e22248209c5	به‌روزرسانی پروندهٔ پرسنلی #100	\N	high	2026-06-29	c14238d9-1d05-4258-b81e-633cf3b64179	2026-07-20 11:11:03.957452+00	2026-07-20 11:11:03.957452+00	todo	\N	7	39.30	2026-06-23
4dcc3819-424c-4d09-9482-91ed2d9d19ab	\N	\N	c159ec20-f52f-44c6-a62b-b5579693a2e2	c159ec20-f52f-44c6-a62b-b5579693a2e2	بررسی درخواست ترفیع کارکنان #101	\N	high	2026-07-07	38b712b6-fc04-4443-92ff-45c725d89c54	2026-07-20 11:11:03.957452+00	2026-07-20 11:11:03.957452+00	todo	\N	61	32.50	2026-06-22
4dcc3819-424c-4d09-9482-91ed2d9d19ab	\N	\N	0631f64d-7a8f-4a1f-b13c-6e22248209c5	0631f64d-7a8f-4a1f-b13c-6e22248209c5	تدوین برنامهٔ آموزشی سال آینده #102	\N	low	2026-07-23	a5ca0270-2799-4d4e-b606-bc9f0a084ca6	2026-07-20 11:11:03.957452+00	2026-07-20 11:11:03.957452+00	completed	approved	100	34.80	2026-07-10
4dcc3819-424c-4d09-9482-91ed2d9d19ab	\N	\N	c159ec20-f52f-44c6-a62b-b5579693a2e2	c159ec20-f52f-44c6-a62b-b5579693a2e2	برنامه‌ریزی رویداد تیم‌سازی #103	\N	medium	2026-08-18	9233ea01-b721-4bd8-bfa6-4fbc5c06e581	2026-07-20 11:11:03.957452+00	2026-07-20 11:11:03.957452+00	archived	\N	14	35.70	2026-08-12
4dcc3819-424c-4d09-9482-91ed2d9d19ab	\N	\N	ea1e6921-d2aa-44c0-978b-ff36b7d9fff2	ea1e6921-d2aa-44c0-978b-ff36b7d9fff2	پیگیری مرخصی و مأموریت کارکنان #104	\N	medium	2026-06-30	bb82de44-8680-4ea5-8b39-d551567207a3	2026-07-20 11:11:03.957452+00	2026-07-20 11:11:03.957452+00	todo	\N	1	28.80	2026-06-20
4dcc3819-424c-4d09-9482-91ed2d9d19ab	\N	\N	0631f64d-7a8f-4a1f-b13c-6e22248209c5	0631f64d-7a8f-4a1f-b13c-6e22248209c5	برگزاری جلسهٔ آموزش کارکنان جدید #105	\N	high	2026-08-11	ed11b037-b9ce-41ee-9de5-059d401bbe68	2026-07-20 11:11:03.957452+00	2026-07-20 11:11:03.957452+00	completed	pending	100	35.20	2026-07-22
\.


--
-- Data for Name: users; Type: TABLE DATA; Schema: public; Owner: -
--

COPY public.users (organization_id, email, hashed_password, full_name, role, is_active, id, created_at, updated_at, phone_number, department_id) FROM stdin;
4dcc3819-424c-4d09-9482-91ed2d9d19ab	admin@test.local	$2b$12$hXY.e8XuYs87lf2AdrAgDO4sf4A6iNPKkChZJLDns6kdtPaNzdFva	مدیر سازمان	org_admin	t	40816eb2-f7d3-4e42-8512-c8262568d134	2026-07-20 11:11:03.957452+00	2026-07-20 11:11:03.957452+00	09100000001	4cb2d1d1-fa04-4416-b8c8-6716f76f5dea
4dcc3819-424c-4d09-9482-91ed2d9d19ab	eng.manager@test.local	$2b$12$tw5njjympywIHxo1ULEyzu71Z7/LX/fm93R8oyu08Q0ejnrwHLsfa	مدیر پروژه مهندسی و فنی	project_manager	t	58d048c0-3e97-449e-bb15-1a8b9a558017	2026-07-20 11:11:03.957452+00	2026-07-20 11:11:03.957452+00	09111000000	4cb2d1d1-fa04-4416-b8c8-6716f76f5dea
4dcc3819-424c-4d09-9482-91ed2d9d19ab	eng.emp1@test.local	$2b$12$x20xdbzu0oYLPeY5lMwPeeh20CMkrOsdArEf3ugM/zdvn2wJKO8i.	کارمند 1 مهندسی و فنی	employee	t	8e57ec64-12f7-4c1b-809e-977233cf374f	2026-07-20 11:11:03.957452+00	2026-07-20 11:11:03.957452+00	09111000011	4cb2d1d1-fa04-4416-b8c8-6716f76f5dea
4dcc3819-424c-4d09-9482-91ed2d9d19ab	eng.emp2@test.local	$2b$12$fzjwRvWzGLIZ7YZqNF7G8enJ.asM1hKqPXVeTurxD8kcU9s/xhEB6	کارمند 2 مهندسی و فنی	employee	t	f389ffea-b5f1-4132-9c04-337ebb4ab8fd	2026-07-20 11:11:03.957452+00	2026-07-20 11:11:03.957452+00	09111000012	4cb2d1d1-fa04-4416-b8c8-6716f76f5dea
4dcc3819-424c-4d09-9482-91ed2d9d19ab	eng.emp3@test.local	$2b$12$9jYuOrtVx63Ium6Cul5VHe2Zjv6KUzxJITEE1f1b0NjSW4PeaePWe	کارمند 3 مهندسی و فنی	employee	t	3e5a2e9c-b250-4896-900f-d75ee290635f	2026-07-20 11:11:03.957452+00	2026-07-20 11:11:03.957452+00	09111000013	4cb2d1d1-fa04-4416-b8c8-6716f76f5dea
4dcc3819-424c-4d09-9482-91ed2d9d19ab	eng.emp4@test.local	$2b$12$6Zk2aUS8BQjYkxIj.UWhiOFYi9z.5qBWWQpuwKynZkwEJr5/F06f.	کارمند 4 مهندسی و فنی	employee	t	4116e390-3789-4721-9e7b-133ebb2764c7	2026-07-20 11:11:03.957452+00	2026-07-20 11:11:03.957452+00	09111000014	4cb2d1d1-fa04-4416-b8c8-6716f76f5dea
4dcc3819-424c-4d09-9482-91ed2d9d19ab	eng.emp5@test.local	$2b$12$cj97bO6//Ojwl2cRQPxeCOX2f3ofvo/yiDSacPYPhXFTL5JKCZDKa	کارمند 5 مهندسی و فنی	employee	t	9e42561d-3de1-44eb-b7ec-5207ea857b8e	2026-07-20 11:11:03.957452+00	2026-07-20 11:11:03.957452+00	09111000015	4cb2d1d1-fa04-4416-b8c8-6716f76f5dea
4dcc3819-424c-4d09-9482-91ed2d9d19ab	eng.emp6@test.local	$2b$12$1geAv7pCL6soSJLFvxFTuueYWj/UU7p81RV0dJqYNtxr04b/z4CTK	کارمند 6 مهندسی و فنی	employee	t	4e1eb7bb-aea1-4b26-aa51-fef3ea6cbab8	2026-07-20 11:11:03.957452+00	2026-07-20 11:11:03.957452+00	09111000016	4cb2d1d1-fa04-4416-b8c8-6716f76f5dea
4dcc3819-424c-4d09-9482-91ed2d9d19ab	fin.manager@test.local	$2b$12$01MYQtvIBXmS/36kjEpTKuBDD160MsygWIxmzXSk5RP0OMalkHtV.	مدیر پروژه حسابداری و مالی	project_manager	t	5e03da3d-4fd1-4305-91ec-8a61bd1f28ee	2026-07-20 11:11:03.957452+00	2026-07-20 11:11:03.957452+00	09121000100	89c94224-912c-4c54-a2fb-de5b87a40e1b
4dcc3819-424c-4d09-9482-91ed2d9d19ab	fin.emp1@test.local	$2b$12$HsZ33yoHd96mjlAoTxDuPO4YxE35wvbGjgrALYbwoHZWw4/1kRz3m	کارمند 1 حسابداری و مالی	employee	t	24baa76f-b9d0-4a8f-b28d-605d780d066a	2026-07-20 11:11:03.957452+00	2026-07-20 11:11:03.957452+00	09121000111	89c94224-912c-4c54-a2fb-de5b87a40e1b
4dcc3819-424c-4d09-9482-91ed2d9d19ab	fin.emp2@test.local	$2b$12$oYSUysNIb4ytPZJ4yANkiuZGzGXkS1UODDmOYsbNIn1vSw8tTHrLq	کارمند 2 حسابداری و مالی	employee	t	5742bab4-624b-41df-aff7-c3517eed7f4c	2026-07-20 11:11:03.957452+00	2026-07-20 11:11:03.957452+00	09121000112	89c94224-912c-4c54-a2fb-de5b87a40e1b
4dcc3819-424c-4d09-9482-91ed2d9d19ab	fin.emp3@test.local	$2b$12$t69SZTpTTKtAGBhc14x5g.x/GMIU5YOxWi2tC37Y1jqgbItg3KyH2	کارمند 3 حسابداری و مالی	employee	t	8d97ee0b-e8f3-4aec-ab48-db76ef6ede39	2026-07-20 11:11:03.957452+00	2026-07-20 11:11:03.957452+00	09121000113	89c94224-912c-4c54-a2fb-de5b87a40e1b
4dcc3819-424c-4d09-9482-91ed2d9d19ab	fin.emp4@test.local	$2b$12$7Xa69FvPzD6L7cMf7JibyuLqQLH6JpYA.gN/ZCYIiYmDTAUAsRF/y	کارمند 4 حسابداری و مالی	employee	t	7a6ee833-86b5-4c74-a2b1-845608f4fbab	2026-07-20 11:11:03.957452+00	2026-07-20 11:11:03.957452+00	09121000114	89c94224-912c-4c54-a2fb-de5b87a40e1b
4dcc3819-424c-4d09-9482-91ed2d9d19ab	fin.emp5@test.local	$2b$12$nsjm9plLyzOZ10HYez84I.9t6HA3nPZcT2AuBNxIRmIeE2R1cNEcC	کارمند 5 حسابداری و مالی	employee	t	8e78a4d9-50d5-40e6-bcd8-fd3f57c31286	2026-07-20 11:11:03.957452+00	2026-07-20 11:11:03.957452+00	09121000115	89c94224-912c-4c54-a2fb-de5b87a40e1b
4dcc3819-424c-4d09-9482-91ed2d9d19ab	fin.emp6@test.local	$2b$12$xZqhG0pKlF0Bco7Y.czFWugHwnKgT5b14FLLnn9PiYLlILZTNa1iS	کارمند 6 حسابداری و مالی	employee	t	d7465638-ca92-4b34-b9b1-b1ab5012de48	2026-07-20 11:11:03.957452+00	2026-07-20 11:11:03.957452+00	09121000116	89c94224-912c-4c54-a2fb-de5b87a40e1b
4dcc3819-424c-4d09-9482-91ed2d9d19ab	hr.manager@test.local	$2b$12$hi8vW/BRCPGCcmM1nU3GBeZNv6tmLeyC/xEsq1FUmQ7yV5Yhw/hSu	مدیر پروژه منابع انسانی	project_manager	t	ac9072e5-ff0f-4d63-880d-330ba7a1645e	2026-07-20 11:11:03.957452+00	2026-07-20 11:11:03.957452+00	09131000200	4c930d15-6ec3-4e03-85ea-4b2ee2dc0a0d
4dcc3819-424c-4d09-9482-91ed2d9d19ab	hr.emp1@test.local	$2b$12$xwV6tK2vvdBZNIuCA3EZvOHQna0DQ1tZSFQhNuZ9YBl98pSBsviCO	کارمند 1 منابع انسانی	employee	t	fbd6cd8f-ebe9-40af-a413-fa64b9419d5a	2026-07-20 11:11:03.957452+00	2026-07-20 11:11:03.957452+00	09131000211	4c930d15-6ec3-4e03-85ea-4b2ee2dc0a0d
4dcc3819-424c-4d09-9482-91ed2d9d19ab	hr.emp2@test.local	$2b$12$s0jzwIbC/hpMJElHmKgQzOw7j39tg0VkTQO4su9empu0IMAtAYMqe	کارمند 2 منابع انسانی	employee	t	3a5bbe57-a350-4aac-a8a7-02d037f0c644	2026-07-20 11:11:03.957452+00	2026-07-20 11:11:03.957452+00	09131000212	4c930d15-6ec3-4e03-85ea-4b2ee2dc0a0d
4dcc3819-424c-4d09-9482-91ed2d9d19ab	hr.emp3@test.local	$2b$12$ZRFtIRYKGa1YawpWygvRJO1SoscIe/nMMcGhRhaVDWgoR../vzc0O	کارمند 3 منابع انسانی	employee	t	ea1e6921-d2aa-44c0-978b-ff36b7d9fff2	2026-07-20 11:11:03.957452+00	2026-07-20 11:11:03.957452+00	09131000213	4c930d15-6ec3-4e03-85ea-4b2ee2dc0a0d
4dcc3819-424c-4d09-9482-91ed2d9d19ab	hr.emp4@test.local	$2b$12$ozamyWl8/MmLNNNeQsX9/eRhYXQD1PLuLKF7mucSReHXzjC3jXM/a	کارمند 4 منابع انسانی	employee	t	57aede22-e4a3-452e-8ade-22917514d015	2026-07-20 11:11:03.957452+00	2026-07-20 11:11:03.957452+00	09131000214	4c930d15-6ec3-4e03-85ea-4b2ee2dc0a0d
4dcc3819-424c-4d09-9482-91ed2d9d19ab	hr.emp5@test.local	$2b$12$Hx.ImLCTEPj9PA2JERj87uqe3XuKxBMB0ZDsv3PsOyAt5NJGLp6kq	کارمند 5 منابع انسانی	employee	t	0631f64d-7a8f-4a1f-b13c-6e22248209c5	2026-07-20 11:11:03.957452+00	2026-07-20 11:11:03.957452+00	09131000215	4c930d15-6ec3-4e03-85ea-4b2ee2dc0a0d
4dcc3819-424c-4d09-9482-91ed2d9d19ab	hr.emp6@test.local	$2b$12$MObavBjIQcgd9zOUnEfI9epLeTrxO1/tOhzsQ1oLyFLBZjdCytibS	کارمند 6 منابع انسانی	employee	t	c159ec20-f52f-44c6-a62b-b5579693a2e2	2026-07-20 11:11:03.957452+00	2026-07-20 11:11:03.957452+00	09131000216	4c930d15-6ec3-4e03-85ea-4b2ee2dc0a0d
\.


--
-- Data for Name: worklogs; Type: TABLE DATA; Schema: public; Owner: -
--

COPY public.worklogs (organization_id, task_id, user_id, activity_description, time_spent_minutes, progress_percent, log_date, status, reviewed_by_id, review_comment, id, created_at, updated_at) FROM stdin;
4dcc3819-424c-4d09-9482-91ed2d9d19ab	75287830-e95a-4f23-8779-c4fbc0d4b25d	9e42561d-3de1-44eb-b7ec-5207ea857b8e	مستندسازی و نهایی‌سازی	224	27	2026-07-12	approved	58d048c0-3e97-449e-bb15-1a8b9a558017	\N	4e8678e5-7ba7-42e5-885b-971d0250405f	2026-07-20 11:11:03.957452+00	2026-07-20 11:11:03.957452+00
4dcc3819-424c-4d09-9482-91ed2d9d19ab	75287830-e95a-4f23-8779-c4fbc0d4b25d	9e42561d-3de1-44eb-b7ec-5207ea857b8e	تست و اطمینان از عملکرد صحیح	144	40	2026-07-16	approved	58d048c0-3e97-449e-bb15-1a8b9a558017	\N	812e9dc4-afb6-4ab3-b99c-0018f2aca971	2026-07-20 11:11:03.957452+00	2026-07-20 11:11:03.957452+00
4dcc3819-424c-4d09-9482-91ed2d9d19ab	75287830-e95a-4f23-8779-c4fbc0d4b25d	9e42561d-3de1-44eb-b7ec-5207ea857b8e	رفع اشکالات و بازبینی	86	96	2026-07-14	approved	58d048c0-3e97-449e-bb15-1a8b9a558017	\N	2d646c66-c650-4ee0-a329-95d30051f146	2026-07-20 11:11:03.957452+00	2026-07-20 11:11:03.957452+00
4dcc3819-424c-4d09-9482-91ed2d9d19ab	75287830-e95a-4f23-8779-c4fbc0d4b25d	9e42561d-3de1-44eb-b7ec-5207ea857b8e	رفع اشکالات و بازبینی	199	100	2026-07-16	approved	58d048c0-3e97-449e-bb15-1a8b9a558017	\N	17e4c880-dd5c-4bfc-aadb-974f4be9efed	2026-07-20 11:11:03.957452+00	2026-07-20 11:11:03.957452+00
4dcc3819-424c-4d09-9482-91ed2d9d19ab	f425b816-5140-4031-90e9-956972efd68d	8e57ec64-12f7-4c1b-809e-977233cf374f	مستندسازی و نهایی‌سازی	165	31	2026-07-07	approved	58d048c0-3e97-449e-bb15-1a8b9a558017	\N	eab149ea-f6d9-4c1c-8fdf-0650b2d9bc30	2026-07-20 11:11:03.957452+00	2026-07-20 11:11:03.957452+00
4dcc3819-424c-4d09-9482-91ed2d9d19ab	f425b816-5140-4031-90e9-956972efd68d	8e57ec64-12f7-4c1b-809e-977233cf374f	مستندسازی و نهایی‌سازی	114	62	2026-07-11	approved	58d048c0-3e97-449e-bb15-1a8b9a558017	\N	0dc3eb18-ab42-4735-ba52-fb428bbbf687	2026-07-20 11:11:03.957452+00	2026-07-20 11:11:03.957452+00
4dcc3819-424c-4d09-9482-91ed2d9d19ab	f425b816-5140-4031-90e9-956972efd68d	8e57ec64-12f7-4c1b-809e-977233cf374f	رفع اشکالات و بازبینی	108	84	2026-07-15	approved	58d048c0-3e97-449e-bb15-1a8b9a558017	\N	247505db-d9c1-443d-9bc3-f832312a8a16	2026-07-20 11:11:03.957452+00	2026-07-20 11:11:03.957452+00
4dcc3819-424c-4d09-9482-91ed2d9d19ab	ae1d960a-c0be-48f8-bd3b-02e397f2ca68	f389ffea-b5f1-4132-9c04-337ebb4ab8fd	پیاده‌سازی بخش اصلی	110	23	2026-06-18	approved	58d048c0-3e97-449e-bb15-1a8b9a558017	\N	5a3810e7-30cc-4a11-b3a5-a850cf91e996	2026-07-20 11:11:03.957452+00	2026-07-20 11:11:03.957452+00
4dcc3819-424c-4d09-9482-91ed2d9d19ab	ae1d960a-c0be-48f8-bd3b-02e397f2ca68	f389ffea-b5f1-4132-9c04-337ebb4ab8fd	پیاده‌سازی بخش اصلی	85	70	2026-06-20	approved	58d048c0-3e97-449e-bb15-1a8b9a558017	\N	48f45004-2e22-496e-804e-b44dcf9c23c1	2026-07-20 11:11:03.957452+00	2026-07-20 11:11:03.957452+00
4dcc3819-424c-4d09-9482-91ed2d9d19ab	a123e7a2-b918-4314-aef8-7bff7cbcbcb0	f389ffea-b5f1-4132-9c04-337ebb4ab8fd	پیشرفت اولیه و بررسی نیازمندی‌ها	79	29	2026-06-20	approved	58d048c0-3e97-449e-bb15-1a8b9a558017	\N	ccf2d2ee-17dd-4cd4-bf74-81bf6fc82bf6	2026-07-20 11:11:03.957452+00	2026-07-20 11:11:03.957452+00
4dcc3819-424c-4d09-9482-91ed2d9d19ab	a123e7a2-b918-4314-aef8-7bff7cbcbcb0	f389ffea-b5f1-4132-9c04-337ebb4ab8fd	رفع اشکالات و بازبینی	75	58	2026-06-22	approved	58d048c0-3e97-449e-bb15-1a8b9a558017	\N	2afcd29e-90f0-45c1-abca-64eda7e04bf5	2026-07-20 11:11:03.957452+00	2026-07-20 11:11:03.957452+00
4dcc3819-424c-4d09-9482-91ed2d9d19ab	a123e7a2-b918-4314-aef8-7bff7cbcbcb0	f389ffea-b5f1-4132-9c04-337ebb4ab8fd	مستندسازی و نهایی‌سازی	62	84	2026-06-22	approved	58d048c0-3e97-449e-bb15-1a8b9a558017	\N	9da48e23-eb14-4d9b-aeff-ab6124cbbe0a	2026-07-20 11:11:03.957452+00	2026-07-20 11:11:03.957452+00
4dcc3819-424c-4d09-9482-91ed2d9d19ab	1addc8df-d363-466d-b3ec-9cd188bcaa44	58d048c0-3e97-449e-bb15-1a8b9a558017	پیاده‌سازی بخش اصلی	193	35	2026-07-16	approved	58d048c0-3e97-449e-bb15-1a8b9a558017	\N	0f35eda9-0d52-4a99-b316-5c472eff48b4	2026-07-20 11:11:03.957452+00	2026-07-20 11:11:03.957452+00
4dcc3819-424c-4d09-9482-91ed2d9d19ab	50a686df-1e7e-4509-8226-e8e79da5dc17	9e42561d-3de1-44eb-b7ec-5207ea857b8e	مستندسازی و نهایی‌سازی	102	35	2026-07-16	approved	58d048c0-3e97-449e-bb15-1a8b9a558017	\N	0c1e090e-22d0-4d89-a309-273b6c66b09a	2026-07-20 11:11:03.957452+00	2026-07-20 11:11:03.957452+00
4dcc3819-424c-4d09-9482-91ed2d9d19ab	c6be38b2-78a7-4fe5-b9ca-799baac55158	3e5a2e9c-b250-4896-900f-d75ee290635f	پیشرفت اولیه و بررسی نیازمندی‌ها	94	35	2026-07-03	approved	58d048c0-3e97-449e-bb15-1a8b9a558017	\N	be0689ed-0b01-45a4-9ab4-464d64536e0a	2026-07-20 11:11:03.957452+00	2026-07-20 11:11:03.957452+00
4dcc3819-424c-4d09-9482-91ed2d9d19ab	c6be38b2-78a7-4fe5-b9ca-799baac55158	3e5a2e9c-b250-4896-900f-d75ee290635f	تست و اطمینان از عملکرد صحیح	155	44	2026-07-04	submitted	\N	\N	41a74b90-94f6-41bb-8cea-1ea6739dfd9c	2026-07-20 11:11:03.957452+00	2026-07-20 11:11:03.957452+00
4dcc3819-424c-4d09-9482-91ed2d9d19ab	c6be38b2-78a7-4fe5-b9ca-799baac55158	3e5a2e9c-b250-4896-900f-d75ee290635f	مستندسازی و نهایی‌سازی	107	66	2026-07-05	approved	58d048c0-3e97-449e-bb15-1a8b9a558017	\N	8a501dee-182c-4a69-9968-603274346ff0	2026-07-20 11:11:03.957452+00	2026-07-20 11:11:03.957452+00
4dcc3819-424c-4d09-9482-91ed2d9d19ab	c6be38b2-78a7-4fe5-b9ca-799baac55158	3e5a2e9c-b250-4896-900f-d75ee290635f	تست و اطمینان از عملکرد صحیح	185	100	2026-07-09	approved	58d048c0-3e97-449e-bb15-1a8b9a558017	\N	91d6a802-de45-4d9b-b03b-a41ac8b50f68	2026-07-20 11:11:03.957452+00	2026-07-20 11:11:03.957452+00
4dcc3819-424c-4d09-9482-91ed2d9d19ab	2dc6badc-a8bc-46c0-b3a8-acbdc572c646	8e57ec64-12f7-4c1b-809e-977233cf374f	تست و اطمینان از عملکرد صحیح	143	29	2026-07-06	approved	58d048c0-3e97-449e-bb15-1a8b9a558017	\N	2f46d889-5e1f-432f-a648-ebdb5b51b662	2026-07-20 11:11:03.957452+00	2026-07-20 11:11:03.957452+00
4dcc3819-424c-4d09-9482-91ed2d9d19ab	2dc6badc-a8bc-46c0-b3a8-acbdc572c646	8e57ec64-12f7-4c1b-809e-977233cf374f	رفع اشکالات و بازبینی	175	78	2026-07-10	approved	58d048c0-3e97-449e-bb15-1a8b9a558017	\N	6cd7f5c9-a867-40cf-a499-5fc3f1786391	2026-07-20 11:11:03.957452+00	2026-07-20 11:11:03.957452+00
4dcc3819-424c-4d09-9482-91ed2d9d19ab	f57202f5-2a31-401f-ba1b-42ce7c371921	9e42561d-3de1-44eb-b7ec-5207ea857b8e	پیاده‌سازی بخش اصلی	190	26	2026-06-24	approved	58d048c0-3e97-449e-bb15-1a8b9a558017	\N	97e40fd1-a593-4379-b4bf-c406d571c0d0	2026-07-20 11:11:03.957452+00	2026-07-20 11:11:03.957452+00
4dcc3819-424c-4d09-9482-91ed2d9d19ab	fc350058-2378-4ace-930d-823970423200	9e42561d-3de1-44eb-b7ec-5207ea857b8e	پیاده‌سازی بخش اصلی	91	25	2026-07-16	approved	58d048c0-3e97-449e-bb15-1a8b9a558017	\N	c988f717-ff8e-49bc-9207-e9b8adbab02f	2026-07-20 11:11:03.957452+00	2026-07-20 11:11:03.957452+00
4dcc3819-424c-4d09-9482-91ed2d9d19ab	fc350058-2378-4ace-930d-823970423200	9e42561d-3de1-44eb-b7ec-5207ea857b8e	پیاده‌سازی بخش اصلی	30	66	2026-07-16	approved	58d048c0-3e97-449e-bb15-1a8b9a558017	\N	0c817cdb-1b27-401f-8f82-2a96aa5b1247	2026-07-20 11:11:03.957452+00	2026-07-20 11:11:03.957452+00
4dcc3819-424c-4d09-9482-91ed2d9d19ab	fc350058-2378-4ace-930d-823970423200	9e42561d-3de1-44eb-b7ec-5207ea857b8e	مستندسازی و نهایی‌سازی	150	87	2026-07-16	approved	58d048c0-3e97-449e-bb15-1a8b9a558017	\N	f86af030-5ee0-4b4f-aefe-e1bda37ee48f	2026-07-20 11:11:03.957452+00	2026-07-20 11:11:03.957452+00
4dcc3819-424c-4d09-9482-91ed2d9d19ab	57f8c7f2-9eeb-4e1b-be13-98ff6c108c6b	8e57ec64-12f7-4c1b-809e-977233cf374f	رفع اشکالات و بازبینی	210	29	2026-07-16	approved	58d048c0-3e97-449e-bb15-1a8b9a558017	\N	1dc013a4-2944-47e9-bcaf-6c56468b16ae	2026-07-20 11:11:03.957452+00	2026-07-20 11:11:03.957452+00
4dcc3819-424c-4d09-9482-91ed2d9d19ab	59e92799-52a8-44ae-a776-c8cdc1db1e74	8e57ec64-12f7-4c1b-809e-977233cf374f	پیاده‌سازی بخش اصلی	97	40	2026-06-20	approved	58d048c0-3e97-449e-bb15-1a8b9a558017	\N	393ab486-ecb5-4ef7-901b-e4c0f14c6cf8	2026-07-20 11:11:03.957452+00	2026-07-20 11:11:03.957452+00
4dcc3819-424c-4d09-9482-91ed2d9d19ab	59e92799-52a8-44ae-a776-c8cdc1db1e74	8e57ec64-12f7-4c1b-809e-977233cf374f	تست و اطمینان از عملکرد صحیح	59	74	2026-06-22	approved	58d048c0-3e97-449e-bb15-1a8b9a558017	\N	2858a623-690d-41bb-b349-439d5d26802c	2026-07-20 11:11:03.957452+00	2026-07-20 11:11:03.957452+00
4dcc3819-424c-4d09-9482-91ed2d9d19ab	59e92799-52a8-44ae-a776-c8cdc1db1e74	8e57ec64-12f7-4c1b-809e-977233cf374f	پیاده‌سازی بخش اصلی	98	72	2026-06-24	approved	58d048c0-3e97-449e-bb15-1a8b9a558017	\N	a272e19f-02b0-4ed9-a491-a739b6eb9e99	2026-07-20 11:11:03.957452+00	2026-07-20 11:11:03.957452+00
4dcc3819-424c-4d09-9482-91ed2d9d19ab	59e92799-52a8-44ae-a776-c8cdc1db1e74	8e57ec64-12f7-4c1b-809e-977233cf374f	پیشرفت اولیه و بررسی نیازمندی‌ها	72	100	2026-06-23	approved	58d048c0-3e97-449e-bb15-1a8b9a558017	\N	ba43ace6-8ce0-4a53-9547-b36774b83343	2026-07-20 11:11:03.957452+00	2026-07-20 11:11:03.957452+00
4dcc3819-424c-4d09-9482-91ed2d9d19ab	8b5830c7-9bf7-49b9-af03-a8c5e5196084	4116e390-3789-4721-9e7b-133ebb2764c7	رفع اشکالات و بازبینی	209	32	2026-07-16	approved	58d048c0-3e97-449e-bb15-1a8b9a558017	\N	c262fb9b-9f14-43fa-a25d-01636e4c1890	2026-07-20 11:11:03.957452+00	2026-07-20 11:11:03.957452+00
4dcc3819-424c-4d09-9482-91ed2d9d19ab	8b5830c7-9bf7-49b9-af03-a8c5e5196084	4116e390-3789-4721-9e7b-133ebb2764c7	تست و اطمینان از عملکرد صحیح	142	44	2026-07-16	approved	58d048c0-3e97-449e-bb15-1a8b9a558017	\N	19e395e9-7d1a-4736-aae4-67bc76e80d9f	2026-07-20 11:11:03.957452+00	2026-07-20 11:11:03.957452+00
4dcc3819-424c-4d09-9482-91ed2d9d19ab	8b5830c7-9bf7-49b9-af03-a8c5e5196084	4116e390-3789-4721-9e7b-133ebb2764c7	رفع اشکالات و بازبینی	184	84	2026-07-16	submitted	\N	\N	35ff71eb-2fc8-48e3-ab4e-a4756a6f4722	2026-07-20 11:11:03.957452+00	2026-07-20 11:11:03.957452+00
4dcc3819-424c-4d09-9482-91ed2d9d19ab	5dafb62a-80b8-4ff7-8927-b560625412b4	4116e390-3789-4721-9e7b-133ebb2764c7	پیاده‌سازی بخش اصلی	202	38	2026-07-03	approved	58d048c0-3e97-449e-bb15-1a8b9a558017	\N	d0a31707-877c-4043-ba76-21443d97533f	2026-07-20 11:11:03.957452+00	2026-07-20 11:11:03.957452+00
4dcc3819-424c-4d09-9482-91ed2d9d19ab	97cfaad3-d9a6-46c1-9f4e-0061e766df3a	58d048c0-3e97-449e-bb15-1a8b9a558017	مستندسازی و نهایی‌سازی	40	25	2026-07-16	approved	58d048c0-3e97-449e-bb15-1a8b9a558017	\N	395d83c5-2ced-461b-b67d-e0a1599d5ae5	2026-07-20 11:11:03.957452+00	2026-07-20 11:11:03.957452+00
4dcc3819-424c-4d09-9482-91ed2d9d19ab	ea81226c-2b1a-410b-8c61-d2967cfcaf74	4e1eb7bb-aea1-4b26-aa51-fef3ea6cbab8	رفع اشکالات و بازبینی	76	38	2026-07-16	approved	58d048c0-3e97-449e-bb15-1a8b9a558017	\N	48eddb7f-e0b7-4622-b244-2cd441228957	2026-07-20 11:11:03.957452+00	2026-07-20 11:11:03.957452+00
4dcc3819-424c-4d09-9482-91ed2d9d19ab	ea81226c-2b1a-410b-8c61-d2967cfcaf74	4e1eb7bb-aea1-4b26-aa51-fef3ea6cbab8	تست و اطمینان از عملکرد صحیح	53	70	2026-07-16	approved	58d048c0-3e97-449e-bb15-1a8b9a558017	\N	acad928f-8321-4349-aaaa-256e324c0432	2026-07-20 11:11:03.957452+00	2026-07-20 11:11:03.957452+00
4dcc3819-424c-4d09-9482-91ed2d9d19ab	ea81226c-2b1a-410b-8c61-d2967cfcaf74	4e1eb7bb-aea1-4b26-aa51-fef3ea6cbab8	تست و اطمینان از عملکرد صحیح	115	90	2026-07-16	approved	58d048c0-3e97-449e-bb15-1a8b9a558017	\N	653016fd-51cc-4086-bb79-528da9aad7d5	2026-07-20 11:11:03.957452+00	2026-07-20 11:11:03.957452+00
4dcc3819-424c-4d09-9482-91ed2d9d19ab	ea81226c-2b1a-410b-8c61-d2967cfcaf74	4e1eb7bb-aea1-4b26-aa51-fef3ea6cbab8	پیاده‌سازی بخش اصلی	114	100	2026-07-16	approved	58d048c0-3e97-449e-bb15-1a8b9a558017	\N	63943dbf-5428-495a-a829-f17dabfb1235	2026-07-20 11:11:03.957452+00	2026-07-20 11:11:03.957452+00
4dcc3819-424c-4d09-9482-91ed2d9d19ab	cac7c36f-e1fd-4045-9937-bb37612cfd91	8e57ec64-12f7-4c1b-809e-977233cf374f	تست و اطمینان از عملکرد صحیح	238	37	2026-07-16	approved	58d048c0-3e97-449e-bb15-1a8b9a558017	\N	2db33e56-7594-4d9c-87c8-ea8c253e0648	2026-07-20 11:11:03.957452+00	2026-07-20 11:11:03.957452+00
4dcc3819-424c-4d09-9482-91ed2d9d19ab	cac7c36f-e1fd-4045-9937-bb37612cfd91	8e57ec64-12f7-4c1b-809e-977233cf374f	تست و اطمینان از عملکرد صحیح	52	60	2026-07-16	approved	58d048c0-3e97-449e-bb15-1a8b9a558017	\N	673733fd-b9ef-4344-8ce8-49c2db21ad69	2026-07-20 11:11:03.957452+00	2026-07-20 11:11:03.957452+00
4dcc3819-424c-4d09-9482-91ed2d9d19ab	cac7c36f-e1fd-4045-9937-bb37612cfd91	8e57ec64-12f7-4c1b-809e-977233cf374f	رفع اشکالات و بازبینی	59	96	2026-07-16	approved	58d048c0-3e97-449e-bb15-1a8b9a558017	\N	2f1ce969-b9fe-4ad1-b38e-392d9feafec3	2026-07-20 11:11:03.957452+00	2026-07-20 11:11:03.957452+00
4dcc3819-424c-4d09-9482-91ed2d9d19ab	cac7c36f-e1fd-4045-9937-bb37612cfd91	8e57ec64-12f7-4c1b-809e-977233cf374f	مستندسازی و نهایی‌سازی	148	100	2026-07-16	approved	58d048c0-3e97-449e-bb15-1a8b9a558017	\N	7d192d1c-2995-41de-948a-0a8f3d6eb0c3	2026-07-20 11:11:03.957452+00	2026-07-20 11:11:03.957452+00
4dcc3819-424c-4d09-9482-91ed2d9d19ab	0129765a-e817-43e8-a653-f56884c429e1	3e5a2e9c-b250-4896-900f-d75ee290635f	مستندسازی و نهایی‌سازی	223	35	2026-07-16	approved	58d048c0-3e97-449e-bb15-1a8b9a558017	\N	fa625363-d6d4-48f6-880e-3ed0da1cf68d	2026-07-20 11:11:03.957452+00	2026-07-20 11:11:03.957452+00
4dcc3819-424c-4d09-9482-91ed2d9d19ab	d7a9162d-6c7b-4450-a01c-84e0262b330b	3e5a2e9c-b250-4896-900f-d75ee290635f	پیاده‌سازی بخش اصلی	98	37	2026-07-14	approved	58d048c0-3e97-449e-bb15-1a8b9a558017	\N	ec48bc27-7565-4348-89a3-cb04ec9782ab	2026-07-20 11:11:03.957452+00	2026-07-20 11:11:03.957452+00
4dcc3819-424c-4d09-9482-91ed2d9d19ab	d7a9162d-6c7b-4450-a01c-84e0262b330b	3e5a2e9c-b250-4896-900f-d75ee290635f	رفع اشکالات و بازبینی	142	70	2026-07-16	approved	58d048c0-3e97-449e-bb15-1a8b9a558017	\N	c7f7f174-c67b-458c-a7bb-afd5467c4d9f	2026-07-20 11:11:03.957452+00	2026-07-20 11:11:03.957452+00
4dcc3819-424c-4d09-9482-91ed2d9d19ab	d7a9162d-6c7b-4450-a01c-84e0262b330b	3e5a2e9c-b250-4896-900f-d75ee290635f	پیشرفت اولیه و بررسی نیازمندی‌ها	191	100	2026-07-16	approved	58d048c0-3e97-449e-bb15-1a8b9a558017	\N	c43172a5-409a-49e7-98fc-1def136f2864	2026-07-20 11:11:03.957452+00	2026-07-20 11:11:03.957452+00
4dcc3819-424c-4d09-9482-91ed2d9d19ab	d7a9162d-6c7b-4450-a01c-84e0262b330b	3e5a2e9c-b250-4896-900f-d75ee290635f	پیاده‌سازی بخش اصلی	109	100	2026-07-16	approved	58d048c0-3e97-449e-bb15-1a8b9a558017	\N	91a09f32-41c0-4b90-902c-c06ae18b98d2	2026-07-20 11:11:03.957452+00	2026-07-20 11:11:03.957452+00
4dcc3819-424c-4d09-9482-91ed2d9d19ab	35151880-5a5e-40f1-a957-f4c515b6834b	58d048c0-3e97-449e-bb15-1a8b9a558017	پیشرفت اولیه و بررسی نیازمندی‌ها	148	23	2026-06-17	approved	58d048c0-3e97-449e-bb15-1a8b9a558017	\N	4369d437-9f86-4ae3-ac5d-b7a2da979423	2026-07-20 11:11:03.957452+00	2026-07-20 11:11:03.957452+00
4dcc3819-424c-4d09-9482-91ed2d9d19ab	9ca27493-db59-4397-91ca-d1d57484a60e	58d048c0-3e97-449e-bb15-1a8b9a558017	رفع اشکالات و بازبینی	160	28	2026-07-16	approved	58d048c0-3e97-449e-bb15-1a8b9a558017	\N	f8eac6b0-3d83-49b1-9ba7-aa09ef16bfdc	2026-07-20 11:11:03.957452+00	2026-07-20 11:11:03.957452+00
4dcc3819-424c-4d09-9482-91ed2d9d19ab	9ca27493-db59-4397-91ca-d1d57484a60e	58d048c0-3e97-449e-bb15-1a8b9a558017	تست و اطمینان از عملکرد صحیح	150	54	2026-07-16	approved	58d048c0-3e97-449e-bb15-1a8b9a558017	\N	9c7b9ad6-6e17-49ca-a55a-4659f8044edc	2026-07-20 11:11:03.957452+00	2026-07-20 11:11:03.957452+00
4dcc3819-424c-4d09-9482-91ed2d9d19ab	5a008113-8447-4d0a-bf4a-43d4011ee71d	58d048c0-3e97-449e-bb15-1a8b9a558017	تست و اطمینان از عملکرد صحیح	78	39	2026-07-16	approved	58d048c0-3e97-449e-bb15-1a8b9a558017	\N	1659b3e1-7fb9-40b1-9830-e760e38e5605	2026-07-20 11:11:03.957452+00	2026-07-20 11:11:03.957452+00
4dcc3819-424c-4d09-9482-91ed2d9d19ab	5a008113-8447-4d0a-bf4a-43d4011ee71d	58d048c0-3e97-449e-bb15-1a8b9a558017	پیشرفت اولیه و بررسی نیازمندی‌ها	100	66	2026-07-16	approved	58d048c0-3e97-449e-bb15-1a8b9a558017	\N	166bb9f3-9bde-4369-beb7-6bcfef089772	2026-07-20 11:11:03.957452+00	2026-07-20 11:11:03.957452+00
4dcc3819-424c-4d09-9482-91ed2d9d19ab	5a008113-8447-4d0a-bf4a-43d4011ee71d	58d048c0-3e97-449e-bb15-1a8b9a558017	مستندسازی و نهایی‌سازی	98	60	2026-07-16	approved	58d048c0-3e97-449e-bb15-1a8b9a558017	\N	ac3c4054-9966-408f-bfe0-55f5247def3e	2026-07-20 11:11:03.957452+00	2026-07-20 11:11:03.957452+00
4dcc3819-424c-4d09-9482-91ed2d9d19ab	5a008113-8447-4d0a-bf4a-43d4011ee71d	58d048c0-3e97-449e-bb15-1a8b9a558017	رفع اشکالات و بازبینی	180	100	2026-07-16	approved	58d048c0-3e97-449e-bb15-1a8b9a558017	\N	4d3b70c4-e3c5-464b-87a5-110cc9991e40	2026-07-20 11:11:03.957452+00	2026-07-20 11:11:03.957452+00
4dcc3819-424c-4d09-9482-91ed2d9d19ab	37acbeb8-d1b4-4e22-a226-d17ca4f0458f	4116e390-3789-4721-9e7b-133ebb2764c7	تست و اطمینان از عملکرد صحیح	167	35	2026-07-16	approved	58d048c0-3e97-449e-bb15-1a8b9a558017	\N	5df3dc79-8fcd-40de-ac12-f55b85b67ef3	2026-07-20 11:11:03.957452+00	2026-07-20 11:11:03.957452+00
4dcc3819-424c-4d09-9482-91ed2d9d19ab	37acbeb8-d1b4-4e22-a226-d17ca4f0458f	4116e390-3789-4721-9e7b-133ebb2764c7	رفع اشکالات و بازبینی	171	74	2026-07-16	approved	58d048c0-3e97-449e-bb15-1a8b9a558017	\N	3da4acc0-fe7d-446c-919d-af76b6265c01	2026-07-20 11:11:03.957452+00	2026-07-20 11:11:03.957452+00
4dcc3819-424c-4d09-9482-91ed2d9d19ab	37acbeb8-d1b4-4e22-a226-d17ca4f0458f	4116e390-3789-4721-9e7b-133ebb2764c7	تست و اطمینان از عملکرد صحیح	112	78	2026-07-16	approved	58d048c0-3e97-449e-bb15-1a8b9a558017	\N	6c83c38d-a097-4f54-a108-d0299bb53203	2026-07-20 11:11:03.957452+00	2026-07-20 11:11:03.957452+00
4dcc3819-424c-4d09-9482-91ed2d9d19ab	37acbeb8-d1b4-4e22-a226-d17ca4f0458f	4116e390-3789-4721-9e7b-133ebb2764c7	مستندسازی و نهایی‌سازی	128	100	2026-07-16	approved	58d048c0-3e97-449e-bb15-1a8b9a558017	\N	a76ab75d-6d90-4a72-a908-8633c7aef328	2026-07-20 11:11:03.957452+00	2026-07-20 11:11:03.957452+00
4dcc3819-424c-4d09-9482-91ed2d9d19ab	e24374b6-ee9b-4e34-8afe-e83aff8b5581	58d048c0-3e97-449e-bb15-1a8b9a558017	رفع اشکالات و بازبینی	220	35	2026-07-13	approved	58d048c0-3e97-449e-bb15-1a8b9a558017	\N	20862078-d762-4103-b26f-63d535ef5baa	2026-07-20 11:11:03.957452+00	2026-07-20 11:11:03.957452+00
4dcc3819-424c-4d09-9482-91ed2d9d19ab	e24374b6-ee9b-4e34-8afe-e83aff8b5581	58d048c0-3e97-449e-bb15-1a8b9a558017	تست و اطمینان از عملکرد صحیح	199	80	2026-07-16	approved	58d048c0-3e97-449e-bb15-1a8b9a558017	\N	caf3e038-6b03-4be1-85dd-f927d23baba1	2026-07-20 11:11:03.957452+00	2026-07-20 11:11:03.957452+00
4dcc3819-424c-4d09-9482-91ed2d9d19ab	e24374b6-ee9b-4e34-8afe-e83aff8b5581	58d048c0-3e97-449e-bb15-1a8b9a558017	تست و اطمینان از عملکرد صحیح	39	72	2026-07-16	approved	58d048c0-3e97-449e-bb15-1a8b9a558017	\N	1f1e0461-8bf2-4bb3-bc94-15317e1dfddb	2026-07-20 11:11:03.957452+00	2026-07-20 11:11:03.957452+00
4dcc3819-424c-4d09-9482-91ed2d9d19ab	e24374b6-ee9b-4e34-8afe-e83aff8b5581	58d048c0-3e97-449e-bb15-1a8b9a558017	پیشرفت اولیه و بررسی نیازمندی‌ها	142	92	2026-07-16	approved	58d048c0-3e97-449e-bb15-1a8b9a558017	\N	a9e1c054-eeb8-4cfc-9f5f-8bb66e7b2c95	2026-07-20 11:11:03.957452+00	2026-07-20 11:11:03.957452+00
4dcc3819-424c-4d09-9482-91ed2d9d19ab	692d2bf1-3b56-4bbf-8e10-ba1bd6dcf4b6	9e42561d-3de1-44eb-b7ec-5207ea857b8e	پیاده‌سازی بخش اصلی	134	40	2026-07-11	approved	58d048c0-3e97-449e-bb15-1a8b9a558017	\N	f6091274-462c-4a11-b562-25d1d043e7dc	2026-07-20 11:11:03.957452+00	2026-07-20 11:11:03.957452+00
4dcc3819-424c-4d09-9482-91ed2d9d19ab	692d2bf1-3b56-4bbf-8e10-ba1bd6dcf4b6	9e42561d-3de1-44eb-b7ec-5207ea857b8e	پیشرفت اولیه و بررسی نیازمندی‌ها	150	56	2026-07-13	approved	58d048c0-3e97-449e-bb15-1a8b9a558017	\N	82c628c8-fa82-4c53-9cbf-0a3cdb6b4a70	2026-07-20 11:11:03.957452+00	2026-07-20 11:11:03.957452+00
4dcc3819-424c-4d09-9482-91ed2d9d19ab	692d2bf1-3b56-4bbf-8e10-ba1bd6dcf4b6	9e42561d-3de1-44eb-b7ec-5207ea857b8e	مستندسازی و نهایی‌سازی	207	96	2026-07-16	approved	58d048c0-3e97-449e-bb15-1a8b9a558017	\N	7784f6c4-eb81-470d-83b6-23e37325caa4	2026-07-20 11:11:03.957452+00	2026-07-20 11:11:03.957452+00
4dcc3819-424c-4d09-9482-91ed2d9d19ab	692d2bf1-3b56-4bbf-8e10-ba1bd6dcf4b6	9e42561d-3de1-44eb-b7ec-5207ea857b8e	رفع اشکالات و بازبینی	202	100	2026-07-14	approved	58d048c0-3e97-449e-bb15-1a8b9a558017	\N	76dcf2ec-6b47-440c-8aea-3a163bd736ae	2026-07-20 11:11:03.957452+00	2026-07-20 11:11:03.957452+00
4dcc3819-424c-4d09-9482-91ed2d9d19ab	71e0a004-a882-4ae4-b81f-8f48e17b2bcf	8e57ec64-12f7-4c1b-809e-977233cf374f	تست و اطمینان از عملکرد صحیح	168	21	2026-07-13	approved	58d048c0-3e97-449e-bb15-1a8b9a558017	\N	b9c77a8d-067c-43eb-b04b-11612269cf39	2026-07-20 11:11:03.957452+00	2026-07-20 11:11:03.957452+00
4dcc3819-424c-4d09-9482-91ed2d9d19ab	71e0a004-a882-4ae4-b81f-8f48e17b2bcf	8e57ec64-12f7-4c1b-809e-977233cf374f	پیاده‌سازی بخش اصلی	191	58	2026-07-14	approved	58d048c0-3e97-449e-bb15-1a8b9a558017	\N	0dc9eb18-410a-4997-aaa1-69c8759ad2af	2026-07-20 11:11:03.957452+00	2026-07-20 11:11:03.957452+00
4dcc3819-424c-4d09-9482-91ed2d9d19ab	71e0a004-a882-4ae4-b81f-8f48e17b2bcf	8e57ec64-12f7-4c1b-809e-977233cf374f	پیشرفت اولیه و بررسی نیازمندی‌ها	141	69	2026-07-16	approved	58d048c0-3e97-449e-bb15-1a8b9a558017	\N	28ced784-0444-4501-9ae1-b39a46e5ed31	2026-07-20 11:11:03.957452+00	2026-07-20 11:11:03.957452+00
4dcc3819-424c-4d09-9482-91ed2d9d19ab	71e0a004-a882-4ae4-b81f-8f48e17b2bcf	8e57ec64-12f7-4c1b-809e-977233cf374f	تست و اطمینان از عملکرد صحیح	72	100	2026-07-16	approved	58d048c0-3e97-449e-bb15-1a8b9a558017	\N	181a2ec5-1ef2-4bdf-8f2a-c514c23d4f79	2026-07-20 11:11:03.957452+00	2026-07-20 11:11:03.957452+00
4dcc3819-424c-4d09-9482-91ed2d9d19ab	5274a160-9bf7-4824-a061-23ed0f12f615	58d048c0-3e97-449e-bb15-1a8b9a558017	رفع اشکالات و بازبینی	233	21	2026-07-16	approved	58d048c0-3e97-449e-bb15-1a8b9a558017	\N	58b1305e-3e6c-46dd-9aa8-f2ef20baecd3	2026-07-20 11:11:03.957452+00	2026-07-20 11:11:03.957452+00
4dcc3819-424c-4d09-9482-91ed2d9d19ab	93fe81c2-68bb-46f3-9274-93491573de13	4e1eb7bb-aea1-4b26-aa51-fef3ea6cbab8	پیاده‌سازی بخش اصلی	92	36	2026-07-16	approved	58d048c0-3e97-449e-bb15-1a8b9a558017	\N	49ca58fb-961c-4497-a426-808ab46b2b7a	2026-07-20 11:11:03.957452+00	2026-07-20 11:11:03.957452+00
4dcc3819-424c-4d09-9482-91ed2d9d19ab	93fe81c2-68bb-46f3-9274-93491573de13	4e1eb7bb-aea1-4b26-aa51-fef3ea6cbab8	پیاده‌سازی بخش اصلی	73	50	2026-07-16	approved	58d048c0-3e97-449e-bb15-1a8b9a558017	\N	e270ec7c-87c0-4a43-b1d8-8da097679308	2026-07-20 11:11:03.957452+00	2026-07-20 11:11:03.957452+00
4dcc3819-424c-4d09-9482-91ed2d9d19ab	93fe81c2-68bb-46f3-9274-93491573de13	4e1eb7bb-aea1-4b26-aa51-fef3ea6cbab8	تست و اطمینان از عملکرد صحیح	188	81	2026-07-16	approved	58d048c0-3e97-449e-bb15-1a8b9a558017	\N	dd19c594-d858-4d98-8532-c3d8e7151f4a	2026-07-20 11:11:03.957452+00	2026-07-20 11:11:03.957452+00
4dcc3819-424c-4d09-9482-91ed2d9d19ab	6aedf77d-44b8-4745-abaf-fc77f5b4155b	f389ffea-b5f1-4132-9c04-337ebb4ab8fd	پیاده‌سازی بخش اصلی	148	40	2026-07-16	approved	58d048c0-3e97-449e-bb15-1a8b9a558017	\N	56afef4f-b519-416d-a9e5-55aba59d7d77	2026-07-20 11:11:03.957452+00	2026-07-20 11:11:03.957452+00
4dcc3819-424c-4d09-9482-91ed2d9d19ab	6aedf77d-44b8-4745-abaf-fc77f5b4155b	f389ffea-b5f1-4132-9c04-337ebb4ab8fd	تست و اطمینان از عملکرد صحیح	95	40	2026-07-16	approved	58d048c0-3e97-449e-bb15-1a8b9a558017	\N	57747af7-c259-47fb-8d2a-842d63b1b89e	2026-07-20 11:11:03.957452+00	2026-07-20 11:11:03.957452+00
4dcc3819-424c-4d09-9482-91ed2d9d19ab	6aedf77d-44b8-4745-abaf-fc77f5b4155b	f389ffea-b5f1-4132-9c04-337ebb4ab8fd	رفع اشکالات و بازبینی	203	100	2026-07-16	approved	58d048c0-3e97-449e-bb15-1a8b9a558017	\N	6b0c0520-4abc-42ef-b9eb-cedc9204cb43	2026-07-20 11:11:03.957452+00	2026-07-20 11:11:03.957452+00
4dcc3819-424c-4d09-9482-91ed2d9d19ab	6aedf77d-44b8-4745-abaf-fc77f5b4155b	f389ffea-b5f1-4132-9c04-337ebb4ab8fd	پیشرفت اولیه و بررسی نیازمندی‌ها	143	100	2026-07-16	approved	58d048c0-3e97-449e-bb15-1a8b9a558017	\N	f8fcb4d2-207d-4cac-8c8f-7b2c68620eb3	2026-07-20 11:11:03.957452+00	2026-07-20 11:11:03.957452+00
4dcc3819-424c-4d09-9482-91ed2d9d19ab	79c532ae-b46f-4ec8-89b0-b45af48514f2	8e57ec64-12f7-4c1b-809e-977233cf374f	تست و اطمینان از عملکرد صحیح	107	26	2026-06-29	approved	58d048c0-3e97-449e-bb15-1a8b9a558017	\N	a24ce6cc-b24c-4579-9488-fd1ffe88cc7e	2026-07-20 11:11:03.957452+00	2026-07-20 11:11:03.957452+00
4dcc3819-424c-4d09-9482-91ed2d9d19ab	79c532ae-b46f-4ec8-89b0-b45af48514f2	8e57ec64-12f7-4c1b-809e-977233cf374f	پیشرفت اولیه و بررسی نیازمندی‌ها	90	64	2026-07-03	submitted	\N	\N	0e8ced86-1292-43e2-a430-a2fffd676b07	2026-07-20 11:11:03.957452+00	2026-07-20 11:11:03.957452+00
4dcc3819-424c-4d09-9482-91ed2d9d19ab	79c532ae-b46f-4ec8-89b0-b45af48514f2	8e57ec64-12f7-4c1b-809e-977233cf374f	رفع اشکالات و بازبینی	35	96	2026-07-05	approved	58d048c0-3e97-449e-bb15-1a8b9a558017	\N	2b393e12-7dee-4288-b0a5-517ab0233c79	2026-07-20 11:11:03.957452+00	2026-07-20 11:11:03.957452+00
4dcc3819-424c-4d09-9482-91ed2d9d19ab	cf04a502-0db8-4fea-b14f-6d48810d632f	8e57ec64-12f7-4c1b-809e-977233cf374f	پیشرفت اولیه و بررسی نیازمندی‌ها	185	35	2026-06-23	approved	58d048c0-3e97-449e-bb15-1a8b9a558017	\N	01191204-71ed-4e90-9c22-ad270cb05cec	2026-07-20 11:11:03.957452+00	2026-07-20 11:11:03.957452+00
4dcc3819-424c-4d09-9482-91ed2d9d19ab	cf04a502-0db8-4fea-b14f-6d48810d632f	8e57ec64-12f7-4c1b-809e-977233cf374f	پیاده‌سازی بخش اصلی	185	62	2026-06-26	submitted	\N	\N	747d4e14-1aaf-4531-8530-e9f7fe233cb5	2026-07-20 11:11:03.957452+00	2026-07-20 11:11:03.957452+00
4dcc3819-424c-4d09-9482-91ed2d9d19ab	cf04a502-0db8-4fea-b14f-6d48810d632f	8e57ec64-12f7-4c1b-809e-977233cf374f	مستندسازی و نهایی‌سازی	94	72	2026-06-27	approved	58d048c0-3e97-449e-bb15-1a8b9a558017	\N	21397473-6675-4c0c-8074-fe96d69448c0	2026-07-20 11:11:03.957452+00	2026-07-20 11:11:03.957452+00
4dcc3819-424c-4d09-9482-91ed2d9d19ab	e4c69e65-fac1-4819-8bd9-5585535508c6	58d048c0-3e97-449e-bb15-1a8b9a558017	تست و اطمینان از عملکرد صحیح	38	38	2026-07-16	approved	58d048c0-3e97-449e-bb15-1a8b9a558017	\N	940df009-8cea-4c48-95da-9f0fb018af27	2026-07-20 11:11:03.957452+00	2026-07-20 11:11:03.957452+00
4dcc3819-424c-4d09-9482-91ed2d9d19ab	be5506bc-05d0-4d2e-8f0c-eaa26b58cfa5	8e57ec64-12f7-4c1b-809e-977233cf374f	پیشرفت اولیه و بررسی نیازمندی‌ها	105	30	2026-07-01	approved	58d048c0-3e97-449e-bb15-1a8b9a558017	\N	9539ea4e-7144-4c64-aeac-da75f6b0a59e	2026-07-20 11:11:03.957452+00	2026-07-20 11:11:03.957452+00
4dcc3819-424c-4d09-9482-91ed2d9d19ab	be5506bc-05d0-4d2e-8f0c-eaa26b58cfa5	8e57ec64-12f7-4c1b-809e-977233cf374f	پیاده‌سازی بخش اصلی	81	48	2026-07-05	approved	58d048c0-3e97-449e-bb15-1a8b9a558017	\N	e76c5198-7f9c-4084-a4dd-4cacec5e38f7	2026-07-20 11:11:03.957452+00	2026-07-20 11:11:03.957452+00
4dcc3819-424c-4d09-9482-91ed2d9d19ab	be5506bc-05d0-4d2e-8f0c-eaa26b58cfa5	8e57ec64-12f7-4c1b-809e-977233cf374f	مستندسازی و نهایی‌سازی	158	84	2026-07-07	approved	58d048c0-3e97-449e-bb15-1a8b9a558017	\N	7ce85f64-3abb-48c2-bcf5-c84d837279ec	2026-07-20 11:11:03.957452+00	2026-07-20 11:11:03.957452+00
4dcc3819-424c-4d09-9482-91ed2d9d19ab	c37b9e1d-4359-4a59-a306-3261b2c416d6	f389ffea-b5f1-4132-9c04-337ebb4ab8fd	تست و اطمینان از عملکرد صحیح	236	29	2026-07-16	approved	58d048c0-3e97-449e-bb15-1a8b9a558017	\N	42e10178-c746-4b88-a3be-6425e9c54c7c	2026-07-20 11:11:03.957452+00	2026-07-20 11:11:03.957452+00
4dcc3819-424c-4d09-9482-91ed2d9d19ab	c37b9e1d-4359-4a59-a306-3261b2c416d6	f389ffea-b5f1-4132-9c04-337ebb4ab8fd	پیشرفت اولیه و بررسی نیازمندی‌ها	149	44	2026-07-16	approved	58d048c0-3e97-449e-bb15-1a8b9a558017	\N	95500650-81d1-4852-aaef-5a65a53c17df	2026-07-20 11:11:03.957452+00	2026-07-20 11:11:03.957452+00
4dcc3819-424c-4d09-9482-91ed2d9d19ab	0ded1f25-51d4-41a4-ac67-17d6caed20af	4116e390-3789-4721-9e7b-133ebb2764c7	تست و اطمینان از عملکرد صحیح	235	37	2026-07-05	approved	58d048c0-3e97-449e-bb15-1a8b9a558017	\N	446ba3f7-44ee-4aad-84df-ae20044e016b	2026-07-20 11:11:03.957452+00	2026-07-20 11:11:03.957452+00
4dcc3819-424c-4d09-9482-91ed2d9d19ab	0ded1f25-51d4-41a4-ac67-17d6caed20af	4116e390-3789-4721-9e7b-133ebb2764c7	پیشرفت اولیه و بررسی نیازمندی‌ها	232	64	2026-07-08	approved	58d048c0-3e97-449e-bb15-1a8b9a558017	\N	8ade5b82-d5cc-4161-a234-f2f9c93dbcea	2026-07-20 11:11:03.957452+00	2026-07-20 11:11:03.957452+00
4dcc3819-424c-4d09-9482-91ed2d9d19ab	83b3cd1c-265f-425e-a5a4-8b6a8a6292c1	4e1eb7bb-aea1-4b26-aa51-fef3ea6cbab8	مستندسازی و نهایی‌سازی	61	34	2026-07-16	approved	58d048c0-3e97-449e-bb15-1a8b9a558017	\N	14500082-2506-4606-91d6-12f203c782ae	2026-07-20 11:11:03.957452+00	2026-07-20 11:11:03.957452+00
4dcc3819-424c-4d09-9482-91ed2d9d19ab	d12218a5-0ea4-4da5-8c56-0c90c2b3e1c9	58d048c0-3e97-449e-bb15-1a8b9a558017	مستندسازی و نهایی‌سازی	127	40	2026-07-16	approved	58d048c0-3e97-449e-bb15-1a8b9a558017	\N	5dfd4dfa-1716-40b1-9622-8edb9aff9c47	2026-07-20 11:11:03.957452+00	2026-07-20 11:11:03.957452+00
4dcc3819-424c-4d09-9482-91ed2d9d19ab	d12218a5-0ea4-4da5-8c56-0c90c2b3e1c9	58d048c0-3e97-449e-bb15-1a8b9a558017	پیشرفت اولیه و بررسی نیازمندی‌ها	202	54	2026-07-16	approved	58d048c0-3e97-449e-bb15-1a8b9a558017	\N	d5aaa68d-b627-4417-a926-21fbfde4fe6d	2026-07-20 11:11:03.957452+00	2026-07-20 11:11:03.957452+00
4dcc3819-424c-4d09-9482-91ed2d9d19ab	d12218a5-0ea4-4da5-8c56-0c90c2b3e1c9	58d048c0-3e97-449e-bb15-1a8b9a558017	پیشرفت اولیه و بررسی نیازمندی‌ها	188	100	2026-07-16	approved	58d048c0-3e97-449e-bb15-1a8b9a558017	\N	a29bffbf-f9dc-4845-b05d-7c5aaeddbc3b	2026-07-20 11:11:03.957452+00	2026-07-20 11:11:03.957452+00
4dcc3819-424c-4d09-9482-91ed2d9d19ab	ec81e733-41e1-42f0-ada8-f4cebc1d0f84	f389ffea-b5f1-4132-9c04-337ebb4ab8fd	تست و اطمینان از عملکرد صحیح	209	29	2026-07-16	approved	58d048c0-3e97-449e-bb15-1a8b9a558017	\N	9720e2b6-45ae-4539-9d5a-2937685d8736	2026-07-20 11:11:03.957452+00	2026-07-20 11:11:03.957452+00
4dcc3819-424c-4d09-9482-91ed2d9d19ab	ec81e733-41e1-42f0-ada8-f4cebc1d0f84	f389ffea-b5f1-4132-9c04-337ebb4ab8fd	پیشرفت اولیه و بررسی نیازمندی‌ها	39	58	2026-07-16	approved	58d048c0-3e97-449e-bb15-1a8b9a558017	\N	245a6246-82ec-4796-8bad-a30388fd8f14	2026-07-20 11:11:03.957452+00	2026-07-20 11:11:03.957452+00
4dcc3819-424c-4d09-9482-91ed2d9d19ab	ec81e733-41e1-42f0-ada8-f4cebc1d0f84	f389ffea-b5f1-4132-9c04-337ebb4ab8fd	پیاده‌سازی بخش اصلی	167	72	2026-07-16	approved	58d048c0-3e97-449e-bb15-1a8b9a558017	\N	f22594bf-b375-40ad-9279-68a81977b0b3	2026-07-20 11:11:03.957452+00	2026-07-20 11:11:03.957452+00
4dcc3819-424c-4d09-9482-91ed2d9d19ab	ff5d59a9-5277-4b7e-9145-24366772bbcb	3e5a2e9c-b250-4896-900f-d75ee290635f	رفع اشکالات و بازبینی	201	37	2026-06-20	approved	58d048c0-3e97-449e-bb15-1a8b9a558017	\N	f4b39091-bdd1-4b74-9948-5675f0d47e50	2026-07-20 11:11:03.957452+00	2026-07-20 11:11:03.957452+00
4dcc3819-424c-4d09-9482-91ed2d9d19ab	ff5d59a9-5277-4b7e-9145-24366772bbcb	3e5a2e9c-b250-4896-900f-d75ee290635f	مستندسازی و نهایی‌سازی	220	48	2026-06-24	approved	58d048c0-3e97-449e-bb15-1a8b9a558017	\N	f968363d-25bb-44c0-b39e-8ca6feb868b2	2026-07-20 11:11:03.957452+00	2026-07-20 11:11:03.957452+00
4dcc3819-424c-4d09-9482-91ed2d9d19ab	ff5d59a9-5277-4b7e-9145-24366772bbcb	3e5a2e9c-b250-4896-900f-d75ee290635f	پیشرفت اولیه و بررسی نیازمندی‌ها	155	100	2026-06-28	approved	58d048c0-3e97-449e-bb15-1a8b9a558017	\N	8f1e49e5-2f7e-4c20-8882-69e9d136a9c1	2026-07-20 11:11:03.957452+00	2026-07-20 11:11:03.957452+00
4dcc3819-424c-4d09-9482-91ed2d9d19ab	ff5d59a9-5277-4b7e-9145-24366772bbcb	3e5a2e9c-b250-4896-900f-d75ee290635f	رفع اشکالات و بازبینی	38	100	2026-07-02	approved	58d048c0-3e97-449e-bb15-1a8b9a558017	\N	04c75214-6c13-428e-9446-d0dce981af75	2026-07-20 11:11:03.957452+00	2026-07-20 11:11:03.957452+00
4dcc3819-424c-4d09-9482-91ed2d9d19ab	5f439b6e-ca55-4e47-940d-e4445b7cd907	4116e390-3789-4721-9e7b-133ebb2764c7	تست و اطمینان از عملکرد صحیح	90	31	2026-06-24	approved	58d048c0-3e97-449e-bb15-1a8b9a558017	\N	cc82a51b-4f49-48fe-88f6-4a04fd8f3a52	2026-07-20 11:11:03.957452+00	2026-07-20 11:11:03.957452+00
4dcc3819-424c-4d09-9482-91ed2d9d19ab	5f439b6e-ca55-4e47-940d-e4445b7cd907	4116e390-3789-4721-9e7b-133ebb2764c7	رفع اشکالات و بازبینی	169	80	2026-06-25	approved	58d048c0-3e97-449e-bb15-1a8b9a558017	\N	04815064-28d7-41e7-a29c-ec02c658c645	2026-07-20 11:11:03.957452+00	2026-07-20 11:11:03.957452+00
4dcc3819-424c-4d09-9482-91ed2d9d19ab	6ce4f48b-e6a2-44a9-8b08-7fcda5aff47e	f389ffea-b5f1-4132-9c04-337ebb4ab8fd	تست و اطمینان از عملکرد صحیح	100	26	2026-07-16	approved	58d048c0-3e97-449e-bb15-1a8b9a558017	\N	0ea8303a-1f2d-4c2c-b72f-ab279e1bd73d	2026-07-20 11:11:03.957452+00	2026-07-20 11:11:03.957452+00
4dcc3819-424c-4d09-9482-91ed2d9d19ab	6ce4f48b-e6a2-44a9-8b08-7fcda5aff47e	f389ffea-b5f1-4132-9c04-337ebb4ab8fd	تست و اطمینان از عملکرد صحیح	53	52	2026-07-16	approved	58d048c0-3e97-449e-bb15-1a8b9a558017	\N	8b1a7a31-e366-40da-854f-638d85b592c7	2026-07-20 11:11:03.957452+00	2026-07-20 11:11:03.957452+00
4dcc3819-424c-4d09-9482-91ed2d9d19ab	6ce4f48b-e6a2-44a9-8b08-7fcda5aff47e	f389ffea-b5f1-4132-9c04-337ebb4ab8fd	پیشرفت اولیه و بررسی نیازمندی‌ها	231	90	2026-07-16	approved	58d048c0-3e97-449e-bb15-1a8b9a558017	\N	2f48df25-1c4c-4fa1-a654-a33a59aa712a	2026-07-20 11:11:03.957452+00	2026-07-20 11:11:03.957452+00
4dcc3819-424c-4d09-9482-91ed2d9d19ab	0d1597b7-a56f-4790-bce9-2656a3b77ef9	f389ffea-b5f1-4132-9c04-337ebb4ab8fd	پیاده‌سازی بخش اصلی	47	37	2026-07-16	submitted	\N	\N	e111d4ba-a33f-433c-897f-0ab14e8a6649	2026-07-20 11:11:03.957452+00	2026-07-20 11:11:03.957452+00
4dcc3819-424c-4d09-9482-91ed2d9d19ab	0d1597b7-a56f-4790-bce9-2656a3b77ef9	f389ffea-b5f1-4132-9c04-337ebb4ab8fd	پیاده‌سازی بخش اصلی	114	48	2026-07-16	approved	58d048c0-3e97-449e-bb15-1a8b9a558017	\N	2f3be17d-aad8-41cc-9c32-433c04699d15	2026-07-20 11:11:03.957452+00	2026-07-20 11:11:03.957452+00
4dcc3819-424c-4d09-9482-91ed2d9d19ab	414ebf0c-90f2-40c0-a4dc-d85dbca9851b	58d048c0-3e97-449e-bb15-1a8b9a558017	پیاده‌سازی بخش اصلی	63	37	2026-07-16	approved	58d048c0-3e97-449e-bb15-1a8b9a558017	\N	517ee6c6-202c-4335-bdff-35e89bc83aad	2026-07-20 11:11:03.957452+00	2026-07-20 11:11:03.957452+00
4dcc3819-424c-4d09-9482-91ed2d9d19ab	20f513d2-eb38-4f39-9bdf-7b2f8fe69264	4e1eb7bb-aea1-4b26-aa51-fef3ea6cbab8	پیشرفت اولیه و بررسی نیازمندی‌ها	63	20	2026-06-30	approved	58d048c0-3e97-449e-bb15-1a8b9a558017	\N	dcbd0762-b269-4cbb-9094-eda7d65695d0	2026-07-20 11:11:03.957452+00	2026-07-20 11:11:03.957452+00
4dcc3819-424c-4d09-9482-91ed2d9d19ab	20f513d2-eb38-4f39-9bdf-7b2f8fe69264	4e1eb7bb-aea1-4b26-aa51-fef3ea6cbab8	پیاده‌سازی بخش اصلی	180	60	2026-07-03	submitted	\N	\N	fc47dc38-2485-4b24-9bf4-e3f6b9f01f54	2026-07-20 11:11:03.957452+00	2026-07-20 11:11:03.957452+00
4dcc3819-424c-4d09-9482-91ed2d9d19ab	20f513d2-eb38-4f39-9bdf-7b2f8fe69264	4e1eb7bb-aea1-4b26-aa51-fef3ea6cbab8	پیشرفت اولیه و بررسی نیازمندی‌ها	62	99	2026-07-02	approved	58d048c0-3e97-449e-bb15-1a8b9a558017	\N	5d9db607-ee53-4035-b33e-92104f85e297	2026-07-20 11:11:03.957452+00	2026-07-20 11:11:03.957452+00
4dcc3819-424c-4d09-9482-91ed2d9d19ab	f2a29250-9347-4db0-b5c4-c3681dd78778	4e1eb7bb-aea1-4b26-aa51-fef3ea6cbab8	تست و اطمینان از عملکرد صحیح	144	31	2026-06-17	approved	58d048c0-3e97-449e-bb15-1a8b9a558017	\N	70503bf6-bcdc-43a1-8c31-ce275d6844f6	2026-07-20 11:11:03.957452+00	2026-07-20 11:11:03.957452+00
4dcc3819-424c-4d09-9482-91ed2d9d19ab	ad787218-bf1f-42b7-b988-4f20fe979b93	58d048c0-3e97-449e-bb15-1a8b9a558017	مستندسازی و نهایی‌سازی	86	39	2026-07-16	approved	58d048c0-3e97-449e-bb15-1a8b9a558017	\N	0950dea3-b079-4dd3-b2d9-44de5f036b40	2026-07-20 11:11:03.957452+00	2026-07-20 11:11:03.957452+00
4dcc3819-424c-4d09-9482-91ed2d9d19ab	a4e9ffd5-5b27-486f-8b95-691e1c20d507	9e42561d-3de1-44eb-b7ec-5207ea857b8e	پیشرفت اولیه و بررسی نیازمندی‌ها	45	35	2026-07-16	approved	58d048c0-3e97-449e-bb15-1a8b9a558017	\N	32792011-bd74-40d1-8904-ab3ca151e54b	2026-07-20 11:11:03.957452+00	2026-07-20 11:11:03.957452+00
4dcc3819-424c-4d09-9482-91ed2d9d19ab	0b73e38e-9439-43c6-8d29-aa6b9d66e233	9e42561d-3de1-44eb-b7ec-5207ea857b8e	تست و اطمینان از عملکرد صحیح	212	34	2026-07-06	approved	58d048c0-3e97-449e-bb15-1a8b9a558017	\N	fa7daeaa-0ae0-4b23-99fa-f2928de843ab	2026-07-20 11:11:03.957452+00	2026-07-20 11:11:03.957452+00
4dcc3819-424c-4d09-9482-91ed2d9d19ab	0b73e38e-9439-43c6-8d29-aa6b9d66e233	9e42561d-3de1-44eb-b7ec-5207ea857b8e	رفع اشکالات و بازبینی	185	48	2026-07-07	submitted	\N	\N	4b1709a3-92e1-4ad0-bd51-421a163f7bfb	2026-07-20 11:11:03.957452+00	2026-07-20 11:11:03.957452+00
4dcc3819-424c-4d09-9482-91ed2d9d19ab	0b73e38e-9439-43c6-8d29-aa6b9d66e233	9e42561d-3de1-44eb-b7ec-5207ea857b8e	مستندسازی و نهایی‌سازی	192	100	2026-07-08	approved	58d048c0-3e97-449e-bb15-1a8b9a558017	\N	6f82b9b0-5ed8-4933-b580-0781891301ce	2026-07-20 11:11:03.957452+00	2026-07-20 11:11:03.957452+00
4dcc3819-424c-4d09-9482-91ed2d9d19ab	0b73e38e-9439-43c6-8d29-aa6b9d66e233	9e42561d-3de1-44eb-b7ec-5207ea857b8e	مستندسازی و نهایی‌سازی	165	100	2026-07-15	approved	58d048c0-3e97-449e-bb15-1a8b9a558017	\N	b0eebf20-2c52-4b9c-b895-2546258fd4f7	2026-07-20 11:11:03.957452+00	2026-07-20 11:11:03.957452+00
4dcc3819-424c-4d09-9482-91ed2d9d19ab	80971038-4c3c-4f6a-966b-8f4cbd9b3188	3e5a2e9c-b250-4896-900f-d75ee290635f	پیشرفت اولیه و بررسی نیازمندی‌ها	233	23	2026-07-16	approved	58d048c0-3e97-449e-bb15-1a8b9a558017	\N	96d53cf8-509e-45b8-b872-115196df1d14	2026-07-20 11:11:03.957452+00	2026-07-20 11:11:03.957452+00
4dcc3819-424c-4d09-9482-91ed2d9d19ab	80971038-4c3c-4f6a-966b-8f4cbd9b3188	3e5a2e9c-b250-4896-900f-d75ee290635f	تست و اطمینان از عملکرد صحیح	145	54	2026-07-16	approved	58d048c0-3e97-449e-bb15-1a8b9a558017	\N	733decc4-8bf3-46c2-87b4-ea0d683ce76c	2026-07-20 11:11:03.957452+00	2026-07-20 11:11:03.957452+00
4dcc3819-424c-4d09-9482-91ed2d9d19ab	80971038-4c3c-4f6a-966b-8f4cbd9b3188	3e5a2e9c-b250-4896-900f-d75ee290635f	رفع اشکالات و بازبینی	146	96	2026-07-16	approved	58d048c0-3e97-449e-bb15-1a8b9a558017	\N	618f71ab-9192-47da-8766-a23f63d857ce	2026-07-20 11:11:03.957452+00	2026-07-20 11:11:03.957452+00
4dcc3819-424c-4d09-9482-91ed2d9d19ab	80971038-4c3c-4f6a-966b-8f4cbd9b3188	3e5a2e9c-b250-4896-900f-d75ee290635f	پیشرفت اولیه و بررسی نیازمندی‌ها	110	100	2026-07-16	approved	58d048c0-3e97-449e-bb15-1a8b9a558017	\N	c91fa422-2d62-4fe9-983b-cd7079002553	2026-07-20 11:11:03.957452+00	2026-07-20 11:11:03.957452+00
4dcc3819-424c-4d09-9482-91ed2d9d19ab	dd2ff5b7-7aa5-48bd-b02b-902b7177ea2c	f389ffea-b5f1-4132-9c04-337ebb4ab8fd	رفع اشکالات و بازبینی	69	35	2026-07-16	approved	58d048c0-3e97-449e-bb15-1a8b9a558017	\N	eaa95604-09c4-4283-91d8-bbc47ebcfdc8	2026-07-20 11:11:03.957452+00	2026-07-20 11:11:03.957452+00
4dcc3819-424c-4d09-9482-91ed2d9d19ab	dd2ff5b7-7aa5-48bd-b02b-902b7177ea2c	f389ffea-b5f1-4132-9c04-337ebb4ab8fd	پیشرفت اولیه و بررسی نیازمندی‌ها	51	44	2026-07-16	approved	58d048c0-3e97-449e-bb15-1a8b9a558017	\N	77473159-1556-4faa-bf89-fff47405f69d	2026-07-20 11:11:03.957452+00	2026-07-20 11:11:03.957452+00
4dcc3819-424c-4d09-9482-91ed2d9d19ab	dd2ff5b7-7aa5-48bd-b02b-902b7177ea2c	f389ffea-b5f1-4132-9c04-337ebb4ab8fd	پیشرفت اولیه و بررسی نیازمندی‌ها	220	93	2026-07-16	approved	58d048c0-3e97-449e-bb15-1a8b9a558017	\N	d84f0fde-a9ec-4614-9fb4-2e591d4a2ebf	2026-07-20 11:11:03.957452+00	2026-07-20 11:11:03.957452+00
4dcc3819-424c-4d09-9482-91ed2d9d19ab	6954f2dd-0251-4bf5-806c-647dfee4c2a3	4e1eb7bb-aea1-4b26-aa51-fef3ea6cbab8	مستندسازی و نهایی‌سازی	173	37	2026-06-26	approved	58d048c0-3e97-449e-bb15-1a8b9a558017	\N	0bc1a19a-c43f-4be2-926a-80a9c0c3a50f	2026-07-20 11:11:03.957452+00	2026-07-20 11:11:03.957452+00
4dcc3819-424c-4d09-9482-91ed2d9d19ab	6954f2dd-0251-4bf5-806c-647dfee4c2a3	4e1eb7bb-aea1-4b26-aa51-fef3ea6cbab8	پیشرفت اولیه و بررسی نیازمندی‌ها	135	62	2026-06-29	approved	58d048c0-3e97-449e-bb15-1a8b9a558017	\N	1616f2ce-9cb3-431a-a0c4-d7d492042fee	2026-07-20 11:11:03.957452+00	2026-07-20 11:11:03.957452+00
4dcc3819-424c-4d09-9482-91ed2d9d19ab	0c4959e2-b421-4279-948e-2f045486b756	4e1eb7bb-aea1-4b26-aa51-fef3ea6cbab8	رفع اشکالات و بازبینی	183	29	2026-07-01	approved	58d048c0-3e97-449e-bb15-1a8b9a558017	\N	12301210-9fa2-42fa-973f-084feae5cc44	2026-07-20 11:11:03.957452+00	2026-07-20 11:11:03.957452+00
4dcc3819-424c-4d09-9482-91ed2d9d19ab	0c4959e2-b421-4279-948e-2f045486b756	4e1eb7bb-aea1-4b26-aa51-fef3ea6cbab8	پیشرفت اولیه و بررسی نیازمندی‌ها	177	72	2026-07-04	approved	58d048c0-3e97-449e-bb15-1a8b9a558017	\N	f82c62e1-02f6-4a11-b85c-e97a777f3a69	2026-07-20 11:11:03.957452+00	2026-07-20 11:11:03.957452+00
4dcc3819-424c-4d09-9482-91ed2d9d19ab	0c4959e2-b421-4279-948e-2f045486b756	4e1eb7bb-aea1-4b26-aa51-fef3ea6cbab8	پیاده‌سازی بخش اصلی	198	100	2026-07-05	approved	58d048c0-3e97-449e-bb15-1a8b9a558017	\N	8d8b8300-7b83-4280-8a4b-c29e0cfb51e1	2026-07-20 11:11:03.957452+00	2026-07-20 11:11:03.957452+00
4dcc3819-424c-4d09-9482-91ed2d9d19ab	0c4959e2-b421-4279-948e-2f045486b756	4e1eb7bb-aea1-4b26-aa51-fef3ea6cbab8	پیشرفت اولیه و بررسی نیازمندی‌ها	119	100	2026-07-07	approved	58d048c0-3e97-449e-bb15-1a8b9a558017	\N	2556b743-2d7c-4ae1-9965-9a026af31d64	2026-07-20 11:11:03.957452+00	2026-07-20 11:11:03.957452+00
4dcc3819-424c-4d09-9482-91ed2d9d19ab	855d2285-59ca-47b2-9407-c0409145ce50	8e57ec64-12f7-4c1b-809e-977233cf374f	رفع اشکالات و بازبینی	176	27	2026-07-16	approved	58d048c0-3e97-449e-bb15-1a8b9a558017	\N	f9bda241-1067-4726-87c4-b47554d1e211	2026-07-20 11:11:03.957452+00	2026-07-20 11:11:03.957452+00
4dcc3819-424c-4d09-9482-91ed2d9d19ab	855d2285-59ca-47b2-9407-c0409145ce50	8e57ec64-12f7-4c1b-809e-977233cf374f	مستندسازی و نهایی‌سازی	226	78	2026-07-16	approved	58d048c0-3e97-449e-bb15-1a8b9a558017	\N	9238aa4f-4d52-4cc9-9623-24bdc602d1a8	2026-07-20 11:11:03.957452+00	2026-07-20 11:11:03.957452+00
4dcc3819-424c-4d09-9482-91ed2d9d19ab	855d2285-59ca-47b2-9407-c0409145ce50	8e57ec64-12f7-4c1b-809e-977233cf374f	مستندسازی و نهایی‌سازی	198	84	2026-07-16	approved	58d048c0-3e97-449e-bb15-1a8b9a558017	\N	c3a6595d-7c0a-4865-af57-9300502b1a65	2026-07-20 11:11:03.957452+00	2026-07-20 11:11:03.957452+00
4dcc3819-424c-4d09-9482-91ed2d9d19ab	15538d48-77b6-40ca-b42f-ad1c0f3e658f	9e42561d-3de1-44eb-b7ec-5207ea857b8e	رفع اشکالات و بازبینی	209	29	2026-07-16	approved	58d048c0-3e97-449e-bb15-1a8b9a558017	\N	62a7247d-855b-481b-9c24-09090b8bd6c5	2026-07-20 11:11:03.957452+00	2026-07-20 11:11:03.957452+00
4dcc3819-424c-4d09-9482-91ed2d9d19ab	9699666d-497d-49a1-965d-a3e801fe3e34	4e1eb7bb-aea1-4b26-aa51-fef3ea6cbab8	پیشرفت اولیه و بررسی نیازمندی‌ها	76	24	2026-07-16	approved	58d048c0-3e97-449e-bb15-1a8b9a558017	\N	a15f5815-3a77-4351-8b7a-1a8be542d3c7	2026-07-20 11:11:03.957452+00	2026-07-20 11:11:03.957452+00
4dcc3819-424c-4d09-9482-91ed2d9d19ab	9699666d-497d-49a1-965d-a3e801fe3e34	4e1eb7bb-aea1-4b26-aa51-fef3ea6cbab8	پیشرفت اولیه و بررسی نیازمندی‌ها	66	80	2026-07-16	approved	58d048c0-3e97-449e-bb15-1a8b9a558017	\N	3909bb2c-53a2-4a7a-9ea0-7b3d69fac472	2026-07-20 11:11:03.957452+00	2026-07-20 11:11:03.957452+00
4dcc3819-424c-4d09-9482-91ed2d9d19ab	9699666d-497d-49a1-965d-a3e801fe3e34	4e1eb7bb-aea1-4b26-aa51-fef3ea6cbab8	پیشرفت اولیه و بررسی نیازمندی‌ها	221	100	2026-07-16	approved	58d048c0-3e97-449e-bb15-1a8b9a558017	\N	ca94be2c-59f1-414a-a974-02dace74607a	2026-07-20 11:11:03.957452+00	2026-07-20 11:11:03.957452+00
4dcc3819-424c-4d09-9482-91ed2d9d19ab	1765fe65-38a3-4319-84cb-0a304a7bcf4a	9e42561d-3de1-44eb-b7ec-5207ea857b8e	تست و اطمینان از عملکرد صحیح	146	30	2026-07-16	approved	58d048c0-3e97-449e-bb15-1a8b9a558017	\N	0e02a21f-2f93-4b68-9331-f80c150628cc	2026-07-20 11:11:03.957452+00	2026-07-20 11:11:03.957452+00
4dcc3819-424c-4d09-9482-91ed2d9d19ab	1765fe65-38a3-4319-84cb-0a304a7bcf4a	9e42561d-3de1-44eb-b7ec-5207ea857b8e	رفع اشکالات و بازبینی	109	60	2026-07-16	approved	58d048c0-3e97-449e-bb15-1a8b9a558017	\N	34b63c78-e74a-4f3d-a293-4aa2fbb0e93e	2026-07-20 11:11:03.957452+00	2026-07-20 11:11:03.957452+00
4dcc3819-424c-4d09-9482-91ed2d9d19ab	3b8065cd-483f-45e3-99e2-084c54f653c3	3e5a2e9c-b250-4896-900f-d75ee290635f	پیاده‌سازی بخش اصلی	70	39	2026-07-01	approved	58d048c0-3e97-449e-bb15-1a8b9a558017	\N	42b8760f-d4cd-4112-88f5-22d1d93a00a6	2026-07-20 11:11:03.957452+00	2026-07-20 11:11:03.957452+00
4dcc3819-424c-4d09-9482-91ed2d9d19ab	0b8db4ab-811f-4ab6-b1c7-e71bb53bd559	8e57ec64-12f7-4c1b-809e-977233cf374f	تست و اطمینان از عملکرد صحیح	154	39	2026-07-14	approved	58d048c0-3e97-449e-bb15-1a8b9a558017	\N	428072e9-7280-469b-a090-03d8a9901423	2026-07-20 11:11:03.957452+00	2026-07-20 11:11:03.957452+00
4dcc3819-424c-4d09-9482-91ed2d9d19ab	56694b66-b299-4d6c-9f06-5074c2a9c9c5	f389ffea-b5f1-4132-9c04-337ebb4ab8fd	رفع اشکالات و بازبینی	85	36	2026-06-25	approved	58d048c0-3e97-449e-bb15-1a8b9a558017	\N	a9abce6c-015b-4925-b798-c5638367e905	2026-07-20 11:11:03.957452+00	2026-07-20 11:11:03.957452+00
4dcc3819-424c-4d09-9482-91ed2d9d19ab	56694b66-b299-4d6c-9f06-5074c2a9c9c5	f389ffea-b5f1-4132-9c04-337ebb4ab8fd	رفع اشکالات و بازبینی	140	46	2026-06-26	approved	58d048c0-3e97-449e-bb15-1a8b9a558017	\N	26321501-08fb-4abb-a862-d07259ef44b5	2026-07-20 11:11:03.957452+00	2026-07-20 11:11:03.957452+00
4dcc3819-424c-4d09-9482-91ed2d9d19ab	56694b66-b299-4d6c-9f06-5074c2a9c9c5	f389ffea-b5f1-4132-9c04-337ebb4ab8fd	مستندسازی و نهایی‌سازی	154	100	2026-07-01	approved	58d048c0-3e97-449e-bb15-1a8b9a558017	\N	8d569733-5621-4d83-b3a6-0bc234379291	2026-07-20 11:11:03.957452+00	2026-07-20 11:11:03.957452+00
4dcc3819-424c-4d09-9482-91ed2d9d19ab	56694b66-b299-4d6c-9f06-5074c2a9c9c5	f389ffea-b5f1-4132-9c04-337ebb4ab8fd	پیشرفت اولیه و بررسی نیازمندی‌ها	86	100	2026-07-04	approved	58d048c0-3e97-449e-bb15-1a8b9a558017	\N	9f887f9e-e9ac-42de-8009-d8f5156938d6	2026-07-20 11:11:03.957452+00	2026-07-20 11:11:03.957452+00
4dcc3819-424c-4d09-9482-91ed2d9d19ab	d0d410b3-9bdc-498e-836b-dd7dc503463b	8e57ec64-12f7-4c1b-809e-977233cf374f	پیاده‌سازی بخش اصلی	226	24	2026-07-10	approved	58d048c0-3e97-449e-bb15-1a8b9a558017	\N	b9c5728f-839c-4976-b420-6ef17699f5af	2026-07-20 11:11:03.957452+00	2026-07-20 11:11:03.957452+00
4dcc3819-424c-4d09-9482-91ed2d9d19ab	a96a176d-19be-4ccf-a41e-a8f0ea9c2415	58d048c0-3e97-449e-bb15-1a8b9a558017	پیشرفت اولیه و بررسی نیازمندی‌ها	157	33	2026-07-05	approved	58d048c0-3e97-449e-bb15-1a8b9a558017	\N	7e103e53-5a15-4560-9e81-038256547909	2026-07-20 11:11:03.957452+00	2026-07-20 11:11:03.957452+00
4dcc3819-424c-4d09-9482-91ed2d9d19ab	a96a176d-19be-4ccf-a41e-a8f0ea9c2415	58d048c0-3e97-449e-bb15-1a8b9a558017	مستندسازی و نهایی‌سازی	210	54	2026-07-07	approved	58d048c0-3e97-449e-bb15-1a8b9a558017	\N	26446d08-763c-44a6-a54b-27b6950af4f3	2026-07-20 11:11:03.957452+00	2026-07-20 11:11:03.957452+00
4dcc3819-424c-4d09-9482-91ed2d9d19ab	a96a176d-19be-4ccf-a41e-a8f0ea9c2415	58d048c0-3e97-449e-bb15-1a8b9a558017	پیشرفت اولیه و بررسی نیازمندی‌ها	141	60	2026-07-11	approved	58d048c0-3e97-449e-bb15-1a8b9a558017	\N	fd8bc24c-d688-4224-bca0-43ad79c893f9	2026-07-20 11:11:03.957452+00	2026-07-20 11:11:03.957452+00
4dcc3819-424c-4d09-9482-91ed2d9d19ab	d1e307f4-2aba-46ec-a922-ebc3f6a0972e	4116e390-3789-4721-9e7b-133ebb2764c7	رفع اشکالات و بازبینی	177	33	2026-07-16	approved	58d048c0-3e97-449e-bb15-1a8b9a558017	\N	476102c0-0bca-486b-8f34-78310ae50e6a	2026-07-20 11:11:03.957452+00	2026-07-20 11:11:03.957452+00
4dcc3819-424c-4d09-9482-91ed2d9d19ab	d1e307f4-2aba-46ec-a922-ebc3f6a0972e	4116e390-3789-4721-9e7b-133ebb2764c7	تست و اطمینان از عملکرد صحیح	104	46	2026-07-16	approved	58d048c0-3e97-449e-bb15-1a8b9a558017	\N	03570bcc-19fb-4f92-9310-f780c23af3e3	2026-07-20 11:11:03.957452+00	2026-07-20 11:11:03.957452+00
4dcc3819-424c-4d09-9482-91ed2d9d19ab	d1e307f4-2aba-46ec-a922-ebc3f6a0972e	4116e390-3789-4721-9e7b-133ebb2764c7	پیشرفت اولیه و بررسی نیازمندی‌ها	113	75	2026-07-16	approved	58d048c0-3e97-449e-bb15-1a8b9a558017	\N	1e9b4518-6f02-4fa6-ab07-b27c3637a34e	2026-07-20 11:11:03.957452+00	2026-07-20 11:11:03.957452+00
4dcc3819-424c-4d09-9482-91ed2d9d19ab	d1e307f4-2aba-46ec-a922-ebc3f6a0972e	4116e390-3789-4721-9e7b-133ebb2764c7	رفع اشکالات و بازبینی	52	100	2026-07-16	approved	58d048c0-3e97-449e-bb15-1a8b9a558017	\N	4d34c166-e95b-4e0e-a0da-fad429f056c3	2026-07-20 11:11:03.957452+00	2026-07-20 11:11:03.957452+00
4dcc3819-424c-4d09-9482-91ed2d9d19ab	98f6a260-5501-43a6-9420-5fe004f8382f	3e5a2e9c-b250-4896-900f-d75ee290635f	تست و اطمینان از عملکرد صحیح	164	22	2026-07-16	approved	58d048c0-3e97-449e-bb15-1a8b9a558017	\N	613d1182-58ed-4193-8a33-f58e91ffd7fe	2026-07-20 11:11:03.957452+00	2026-07-20 11:11:03.957452+00
4dcc3819-424c-4d09-9482-91ed2d9d19ab	51b5543a-f91a-4a79-9d5e-ee9f8d59b2ac	4116e390-3789-4721-9e7b-133ebb2764c7	رفع اشکالات و بازبینی	86	30	2026-07-11	approved	58d048c0-3e97-449e-bb15-1a8b9a558017	\N	cbd69b1b-f04e-48ff-aa67-60718f70e7b1	2026-07-20 11:11:03.957452+00	2026-07-20 11:11:03.957452+00
4dcc3819-424c-4d09-9482-91ed2d9d19ab	51b5543a-f91a-4a79-9d5e-ee9f8d59b2ac	4116e390-3789-4721-9e7b-133ebb2764c7	پیشرفت اولیه و بررسی نیازمندی‌ها	160	80	2026-07-13	approved	58d048c0-3e97-449e-bb15-1a8b9a558017	\N	9271c702-339f-4770-93fa-595086accb50	2026-07-20 11:11:03.957452+00	2026-07-20 11:11:03.957452+00
4dcc3819-424c-4d09-9482-91ed2d9d19ab	51b5543a-f91a-4a79-9d5e-ee9f8d59b2ac	4116e390-3789-4721-9e7b-133ebb2764c7	مستندسازی و نهایی‌سازی	160	78	2026-07-13	approved	58d048c0-3e97-449e-bb15-1a8b9a558017	\N	82cefea4-5d50-4570-876e-e3d5703ced1f	2026-07-20 11:11:03.957452+00	2026-07-20 11:11:03.957452+00
4dcc3819-424c-4d09-9482-91ed2d9d19ab	51b5543a-f91a-4a79-9d5e-ee9f8d59b2ac	4116e390-3789-4721-9e7b-133ebb2764c7	رفع اشکالات و بازبینی	216	100	2026-07-16	approved	58d048c0-3e97-449e-bb15-1a8b9a558017	\N	8ce6966a-9a8e-459e-be30-bb719d0712de	2026-07-20 11:11:03.957452+00	2026-07-20 11:11:03.957452+00
4dcc3819-424c-4d09-9482-91ed2d9d19ab	1b5eb279-8948-469a-9ade-ab09eb96c59f	9e42561d-3de1-44eb-b7ec-5207ea857b8e	رفع اشکالات و بازبینی	80	25	2026-06-24	approved	58d048c0-3e97-449e-bb15-1a8b9a558017	\N	59b321d4-efba-4029-aed8-0b049af47411	2026-07-20 11:11:03.957452+00	2026-07-20 11:11:03.957452+00
4dcc3819-424c-4d09-9482-91ed2d9d19ab	1b5eb279-8948-469a-9ade-ab09eb96c59f	9e42561d-3de1-44eb-b7ec-5207ea857b8e	پیشرفت اولیه و بررسی نیازمندی‌ها	75	80	2026-06-26	submitted	\N	\N	36acf1c2-ed6a-4ecc-89b6-bd247192a021	2026-07-20 11:11:03.957452+00	2026-07-20 11:11:03.957452+00
4dcc3819-424c-4d09-9482-91ed2d9d19ab	41844556-16e8-421e-b0dd-d479ce333c01	8e57ec64-12f7-4c1b-809e-977233cf374f	مستندسازی و نهایی‌سازی	224	38	2026-07-16	approved	58d048c0-3e97-449e-bb15-1a8b9a558017	\N	e2c9993f-f022-4cb0-8b2b-00b6661feda7	2026-07-20 11:11:03.957452+00	2026-07-20 11:11:03.957452+00
4dcc3819-424c-4d09-9482-91ed2d9d19ab	41844556-16e8-421e-b0dd-d479ce333c01	8e57ec64-12f7-4c1b-809e-977233cf374f	مستندسازی و نهایی‌سازی	194	80	2026-07-16	approved	58d048c0-3e97-449e-bb15-1a8b9a558017	\N	b8241deb-a1bb-4b04-935a-2febd76746c7	2026-07-20 11:11:03.957452+00	2026-07-20 11:11:03.957452+00
4dcc3819-424c-4d09-9482-91ed2d9d19ab	41844556-16e8-421e-b0dd-d479ce333c01	8e57ec64-12f7-4c1b-809e-977233cf374f	رفع اشکالات و بازبینی	68	100	2026-07-16	approved	58d048c0-3e97-449e-bb15-1a8b9a558017	\N	6dfbb6b9-73cb-4666-99c7-96898bbccb4c	2026-07-20 11:11:03.957452+00	2026-07-20 11:11:03.957452+00
4dcc3819-424c-4d09-9482-91ed2d9d19ab	41844556-16e8-421e-b0dd-d479ce333c01	8e57ec64-12f7-4c1b-809e-977233cf374f	تست و اطمینان از عملکرد صحیح	143	100	2026-07-16	approved	58d048c0-3e97-449e-bb15-1a8b9a558017	\N	88ecbd61-55a6-4077-a0f6-6df6a7736a81	2026-07-20 11:11:03.957452+00	2026-07-20 11:11:03.957452+00
4dcc3819-424c-4d09-9482-91ed2d9d19ab	03f22f85-a10c-431b-800b-956d97662ed4	58d048c0-3e97-449e-bb15-1a8b9a558017	مستندسازی و نهایی‌سازی	44	31	2026-07-16	approved	58d048c0-3e97-449e-bb15-1a8b9a558017	\N	e76d58d5-0950-4278-a3e2-a106a6ad5100	2026-07-20 11:11:03.957452+00	2026-07-20 11:11:03.957452+00
4dcc3819-424c-4d09-9482-91ed2d9d19ab	03f22f85-a10c-431b-800b-956d97662ed4	58d048c0-3e97-449e-bb15-1a8b9a558017	رفع اشکالات و بازبینی	148	68	2026-07-16	approved	58d048c0-3e97-449e-bb15-1a8b9a558017	\N	dd708bd5-26f2-457e-9e60-794e60555cdc	2026-07-20 11:11:03.957452+00	2026-07-20 11:11:03.957452+00
4dcc3819-424c-4d09-9482-91ed2d9d19ab	03f22f85-a10c-431b-800b-956d97662ed4	58d048c0-3e97-449e-bb15-1a8b9a558017	پیشرفت اولیه و بررسی نیازمندی‌ها	124	87	2026-07-16	approved	58d048c0-3e97-449e-bb15-1a8b9a558017	\N	89d027f8-59b2-418d-a0af-20d562b3d0e2	2026-07-20 11:11:03.957452+00	2026-07-20 11:11:03.957452+00
4dcc3819-424c-4d09-9482-91ed2d9d19ab	c3d67987-9825-46de-92ba-83f93768e76f	4e1eb7bb-aea1-4b26-aa51-fef3ea6cbab8	مستندسازی و نهایی‌سازی	182	36	2026-06-17	approved	58d048c0-3e97-449e-bb15-1a8b9a558017	\N	0d2c34a0-a83a-4ba0-b795-719d93eb0181	2026-07-20 11:11:03.957452+00	2026-07-20 11:11:03.957452+00
4dcc3819-424c-4d09-9482-91ed2d9d19ab	2c550f66-5a3b-4135-9fe8-ac0d81b6cc98	4e1eb7bb-aea1-4b26-aa51-fef3ea6cbab8	پیشرفت اولیه و بررسی نیازمندی‌ها	145	38	2026-06-26	approved	58d048c0-3e97-449e-bb15-1a8b9a558017	\N	a2335c01-1c13-4cb5-a2f2-f6023e54073a	2026-07-20 11:11:03.957452+00	2026-07-20 11:11:03.957452+00
4dcc3819-424c-4d09-9482-91ed2d9d19ab	2c550f66-5a3b-4135-9fe8-ac0d81b6cc98	4e1eb7bb-aea1-4b26-aa51-fef3ea6cbab8	تست و اطمینان از عملکرد صحیح	158	48	2026-06-28	approved	58d048c0-3e97-449e-bb15-1a8b9a558017	\N	2ac4b634-ea7b-4a42-802f-0cda58993ddb	2026-07-20 11:11:03.957452+00	2026-07-20 11:11:03.957452+00
4dcc3819-424c-4d09-9482-91ed2d9d19ab	2c550f66-5a3b-4135-9fe8-ac0d81b6cc98	4e1eb7bb-aea1-4b26-aa51-fef3ea6cbab8	رفع اشکالات و بازبینی	212	66	2026-06-28	approved	58d048c0-3e97-449e-bb15-1a8b9a558017	\N	b472b336-aec9-48bc-8e47-7728028db0d9	2026-07-20 11:11:03.957452+00	2026-07-20 11:11:03.957452+00
4dcc3819-424c-4d09-9482-91ed2d9d19ab	2c550f66-5a3b-4135-9fe8-ac0d81b6cc98	4e1eb7bb-aea1-4b26-aa51-fef3ea6cbab8	تست و اطمینان از عملکرد صحیح	142	100	2026-07-02	approved	58d048c0-3e97-449e-bb15-1a8b9a558017	\N	6d14ba9b-5609-4da0-86d1-577c60efac20	2026-07-20 11:11:03.957452+00	2026-07-20 11:11:03.957452+00
4dcc3819-424c-4d09-9482-91ed2d9d19ab	e30aa10a-829a-4795-8592-d6db33b4c807	8e57ec64-12f7-4c1b-809e-977233cf374f	رفع اشکالات و بازبینی	129	33	2026-06-22	approved	58d048c0-3e97-449e-bb15-1a8b9a558017	\N	b20f99ac-cd3d-43f1-81cb-e1760436e021	2026-07-20 11:11:03.957452+00	2026-07-20 11:11:03.957452+00
4dcc3819-424c-4d09-9482-91ed2d9d19ab	e30aa10a-829a-4795-8592-d6db33b4c807	8e57ec64-12f7-4c1b-809e-977233cf374f	پیشرفت اولیه و بررسی نیازمندی‌ها	232	80	2026-06-25	approved	58d048c0-3e97-449e-bb15-1a8b9a558017	\N	02e4b488-e3f5-45f2-ac10-1bf47ad63a9f	2026-07-20 11:11:03.957452+00	2026-07-20 11:11:03.957452+00
4dcc3819-424c-4d09-9482-91ed2d9d19ab	7b4e1236-081c-476d-a492-7be52cd39761	3e5a2e9c-b250-4896-900f-d75ee290635f	مستندسازی و نهایی‌سازی	203	32	2026-07-16	approved	58d048c0-3e97-449e-bb15-1a8b9a558017	\N	383b8129-b00d-497a-960e-6cbc39bc9fc5	2026-07-20 11:11:03.957452+00	2026-07-20 11:11:03.957452+00
4dcc3819-424c-4d09-9482-91ed2d9d19ab	7b4e1236-081c-476d-a492-7be52cd39761	3e5a2e9c-b250-4896-900f-d75ee290635f	مستندسازی و نهایی‌سازی	68	60	2026-07-16	approved	58d048c0-3e97-449e-bb15-1a8b9a558017	\N	a8e543ea-0991-4036-b089-8ed16d42f741	2026-07-20 11:11:03.957452+00	2026-07-20 11:11:03.957452+00
4dcc3819-424c-4d09-9482-91ed2d9d19ab	7b4e1236-081c-476d-a492-7be52cd39761	3e5a2e9c-b250-4896-900f-d75ee290635f	پیاده‌سازی بخش اصلی	119	87	2026-07-16	approved	58d048c0-3e97-449e-bb15-1a8b9a558017	\N	a2a07db1-8fa0-4cc1-a79d-e1af32cebeec	2026-07-20 11:11:03.957452+00	2026-07-20 11:11:03.957452+00
4dcc3819-424c-4d09-9482-91ed2d9d19ab	98e40777-9073-4b40-9006-6134c8fde7f0	9e42561d-3de1-44eb-b7ec-5207ea857b8e	مستندسازی و نهایی‌سازی	211	22	2026-07-05	approved	58d048c0-3e97-449e-bb15-1a8b9a558017	\N	3727f071-b348-4b2c-9b69-1f0cfbdaa7eb	2026-07-20 11:11:03.957452+00	2026-07-20 11:11:03.957452+00
4dcc3819-424c-4d09-9482-91ed2d9d19ab	98e40777-9073-4b40-9006-6134c8fde7f0	9e42561d-3de1-44eb-b7ec-5207ea857b8e	مستندسازی و نهایی‌سازی	126	80	2026-07-08	approved	58d048c0-3e97-449e-bb15-1a8b9a558017	\N	6a696a70-bbbb-4cb6-974b-eda4af68f780	2026-07-20 11:11:03.957452+00	2026-07-20 11:11:03.957452+00
4dcc3819-424c-4d09-9482-91ed2d9d19ab	98e40777-9073-4b40-9006-6134c8fde7f0	9e42561d-3de1-44eb-b7ec-5207ea857b8e	پیاده‌سازی بخش اصلی	201	100	2026-07-11	approved	58d048c0-3e97-449e-bb15-1a8b9a558017	\N	b45fa2da-72f3-4606-a1f7-40c4012a3847	2026-07-20 11:11:03.957452+00	2026-07-20 11:11:03.957452+00
4dcc3819-424c-4d09-9482-91ed2d9d19ab	98e40777-9073-4b40-9006-6134c8fde7f0	9e42561d-3de1-44eb-b7ec-5207ea857b8e	تست و اطمینان از عملکرد صحیح	160	100	2026-07-08	approved	58d048c0-3e97-449e-bb15-1a8b9a558017	\N	970a4bd8-8bb0-4b71-844e-d6ce1a188ff6	2026-07-20 11:11:03.957452+00	2026-07-20 11:11:03.957452+00
4dcc3819-424c-4d09-9482-91ed2d9d19ab	49c5ec8a-ed77-4dee-93ed-b29a0296fa1d	f389ffea-b5f1-4132-9c04-337ebb4ab8fd	رفع اشکالات و بازبینی	76	26	2026-07-09	approved	58d048c0-3e97-449e-bb15-1a8b9a558017	\N	63fd05c9-1f81-4dc9-a17c-0978fdfd134c	2026-07-20 11:11:03.957452+00	2026-07-20 11:11:03.957452+00
4dcc3819-424c-4d09-9482-91ed2d9d19ab	454ec199-92d1-4ed3-afd6-72b65613f24a	4e1eb7bb-aea1-4b26-aa51-fef3ea6cbab8	پیاده‌سازی بخش اصلی	69	22	2026-07-16	approved	58d048c0-3e97-449e-bb15-1a8b9a558017	\N	90027c49-5067-49b9-9079-235bab63c55b	2026-07-20 11:11:03.957452+00	2026-07-20 11:11:03.957452+00
4dcc3819-424c-4d09-9482-91ed2d9d19ab	454ec199-92d1-4ed3-afd6-72b65613f24a	4e1eb7bb-aea1-4b26-aa51-fef3ea6cbab8	پیشرفت اولیه و بررسی نیازمندی‌ها	159	74	2026-07-16	submitted	\N	\N	2335580d-265e-46de-b098-790ff1fe74f5	2026-07-20 11:11:03.957452+00	2026-07-20 11:11:03.957452+00
4dcc3819-424c-4d09-9482-91ed2d9d19ab	454ec199-92d1-4ed3-afd6-72b65613f24a	4e1eb7bb-aea1-4b26-aa51-fef3ea6cbab8	مستندسازی و نهایی‌سازی	63	100	2026-07-16	approved	58d048c0-3e97-449e-bb15-1a8b9a558017	\N	f1d983d9-b896-483d-8672-df95d01182d0	2026-07-20 11:11:03.957452+00	2026-07-20 11:11:03.957452+00
4dcc3819-424c-4d09-9482-91ed2d9d19ab	c6bdf432-d244-492d-8d81-83bd786fd648	4e1eb7bb-aea1-4b26-aa51-fef3ea6cbab8	پیاده‌سازی بخش اصلی	76	39	2026-07-13	approved	58d048c0-3e97-449e-bb15-1a8b9a558017	\N	22484d1f-2a4d-4235-b97a-a7cc6b244232	2026-07-20 11:11:03.957452+00	2026-07-20 11:11:03.957452+00
4dcc3819-424c-4d09-9482-91ed2d9d19ab	c6bdf432-d244-492d-8d81-83bd786fd648	4e1eb7bb-aea1-4b26-aa51-fef3ea6cbab8	تست و اطمینان از عملکرد صحیح	41	66	2026-07-15	approved	58d048c0-3e97-449e-bb15-1a8b9a558017	\N	0ab53f31-08d3-4dfc-bd30-95e9c237b9b0	2026-07-20 11:11:03.957452+00	2026-07-20 11:11:03.957452+00
4dcc3819-424c-4d09-9482-91ed2d9d19ab	c6bdf432-d244-492d-8d81-83bd786fd648	4e1eb7bb-aea1-4b26-aa51-fef3ea6cbab8	پیاده‌سازی بخش اصلی	143	100	2026-07-16	approved	58d048c0-3e97-449e-bb15-1a8b9a558017	\N	a2197579-362e-442b-9d78-8d0eca4e5217	2026-07-20 11:11:03.957452+00	2026-07-20 11:11:03.957452+00
4dcc3819-424c-4d09-9482-91ed2d9d19ab	c6bdf432-d244-492d-8d81-83bd786fd648	4e1eb7bb-aea1-4b26-aa51-fef3ea6cbab8	تست و اطمینان از عملکرد صحیح	89	100	2026-07-16	approved	58d048c0-3e97-449e-bb15-1a8b9a558017	\N	4fda4576-9d75-47c2-a78f-0fd5b9e1a022	2026-07-20 11:11:03.957452+00	2026-07-20 11:11:03.957452+00
4dcc3819-424c-4d09-9482-91ed2d9d19ab	fd4afb56-0db1-4b7b-b9ed-58ffc447b05e	f389ffea-b5f1-4132-9c04-337ebb4ab8fd	تست و اطمینان از عملکرد صحیح	79	31	2026-07-16	approved	58d048c0-3e97-449e-bb15-1a8b9a558017	\N	37e1a324-6ef5-4357-8ef6-89bb7a884e1f	2026-07-20 11:11:03.957452+00	2026-07-20 11:11:03.957452+00
4dcc3819-424c-4d09-9482-91ed2d9d19ab	fd4afb56-0db1-4b7b-b9ed-58ffc447b05e	f389ffea-b5f1-4132-9c04-337ebb4ab8fd	تست و اطمینان از عملکرد صحیح	226	58	2026-07-16	approved	58d048c0-3e97-449e-bb15-1a8b9a558017	\N	ed0c5389-2271-4bda-96ed-c02cc2961482	2026-07-20 11:11:03.957452+00	2026-07-20 11:11:03.957452+00
4dcc3819-424c-4d09-9482-91ed2d9d19ab	79da9908-b132-4564-8ae4-c0e1d5975bad	4116e390-3789-4721-9e7b-133ebb2764c7	پیاده‌سازی بخش اصلی	235	39	2026-07-06	submitted	\N	\N	b004356b-d236-47fd-beaa-40a7cb23f1ba	2026-07-20 11:11:03.957452+00	2026-07-20 11:11:03.957452+00
4dcc3819-424c-4d09-9482-91ed2d9d19ab	79da9908-b132-4564-8ae4-c0e1d5975bad	4116e390-3789-4721-9e7b-133ebb2764c7	پیشرفت اولیه و بررسی نیازمندی‌ها	194	70	2026-07-08	submitted	\N	\N	9f75a8cb-1656-434e-a7b8-7b5f96b129cb	2026-07-20 11:11:03.957452+00	2026-07-20 11:11:03.957452+00
4dcc3819-424c-4d09-9482-91ed2d9d19ab	79da9908-b132-4564-8ae4-c0e1d5975bad	4116e390-3789-4721-9e7b-133ebb2764c7	پیشرفت اولیه و بررسی نیازمندی‌ها	212	100	2026-07-12	approved	58d048c0-3e97-449e-bb15-1a8b9a558017	\N	03cb3433-e508-41c4-b6bd-af38a2e96164	2026-07-20 11:11:03.957452+00	2026-07-20 11:11:03.957452+00
4dcc3819-424c-4d09-9482-91ed2d9d19ab	79da9908-b132-4564-8ae4-c0e1d5975bad	4116e390-3789-4721-9e7b-133ebb2764c7	پیاده‌سازی بخش اصلی	99	100	2026-07-09	approved	58d048c0-3e97-449e-bb15-1a8b9a558017	\N	79ea1554-8326-4e6d-8f77-cbc9a5e3fbb4	2026-07-20 11:11:03.957452+00	2026-07-20 11:11:03.957452+00
4dcc3819-424c-4d09-9482-91ed2d9d19ab	a345604f-149e-40a0-9986-fec8f163a165	8e57ec64-12f7-4c1b-809e-977233cf374f	پیشرفت اولیه و بررسی نیازمندی‌ها	86	34	2026-07-15	approved	58d048c0-3e97-449e-bb15-1a8b9a558017	\N	c11d4f23-ed51-4cb7-888f-4324ed6fefae	2026-07-20 11:11:03.957452+00	2026-07-20 11:11:03.957452+00
4dcc3819-424c-4d09-9482-91ed2d9d19ab	a345604f-149e-40a0-9986-fec8f163a165	8e57ec64-12f7-4c1b-809e-977233cf374f	پیشرفت اولیه و بررسی نیازمندی‌ها	136	42	2026-07-16	approved	58d048c0-3e97-449e-bb15-1a8b9a558017	\N	f52d3c05-3ddc-4df9-bde6-0bd8c787fc68	2026-07-20 11:11:03.957452+00	2026-07-20 11:11:03.957452+00
4dcc3819-424c-4d09-9482-91ed2d9d19ab	dac4cdff-7502-4321-8aaa-490cc0edc9c4	3e5a2e9c-b250-4896-900f-d75ee290635f	پیشرفت اولیه و بررسی نیازمندی‌ها	125	27	2026-06-27	approved	58d048c0-3e97-449e-bb15-1a8b9a558017	\N	cbbac8a6-ed88-4997-bffa-244c27239004	2026-07-20 11:11:03.957452+00	2026-07-20 11:11:03.957452+00
4dcc3819-424c-4d09-9482-91ed2d9d19ab	dac4cdff-7502-4321-8aaa-490cc0edc9c4	3e5a2e9c-b250-4896-900f-d75ee290635f	پیشرفت اولیه و بررسی نیازمندی‌ها	212	80	2026-06-28	approved	58d048c0-3e97-449e-bb15-1a8b9a558017	\N	6ecdc218-bb7b-422d-b117-a491a663cf52	2026-07-20 11:11:03.957452+00	2026-07-20 11:11:03.957452+00
4dcc3819-424c-4d09-9482-91ed2d9d19ab	dac4cdff-7502-4321-8aaa-490cc0edc9c4	3e5a2e9c-b250-4896-900f-d75ee290635f	پیاده‌سازی بخش اصلی	39	87	2026-07-03	submitted	\N	\N	118d5b71-d199-445a-b727-5e75fc2cce24	2026-07-20 11:11:03.957452+00	2026-07-20 11:11:03.957452+00
4dcc3819-424c-4d09-9482-91ed2d9d19ab	dac4cdff-7502-4321-8aaa-490cc0edc9c4	3e5a2e9c-b250-4896-900f-d75ee290635f	پیاده‌سازی بخش اصلی	224	100	2026-07-09	approved	58d048c0-3e97-449e-bb15-1a8b9a558017	\N	b6db9647-5cd6-4861-8530-892bbb9b5940	2026-07-20 11:11:03.957452+00	2026-07-20 11:11:03.957452+00
4dcc3819-424c-4d09-9482-91ed2d9d19ab	b0a43c5a-f449-4ee6-aeee-cbe2c09d6dee	4116e390-3789-4721-9e7b-133ebb2764c7	پیشرفت اولیه و بررسی نیازمندی‌ها	34	28	2026-07-16	approved	58d048c0-3e97-449e-bb15-1a8b9a558017	\N	f6d177f5-9dbc-447f-9d6b-3dfd6994171c	2026-07-20 11:11:03.957452+00	2026-07-20 11:11:03.957452+00
4dcc3819-424c-4d09-9482-91ed2d9d19ab	b0a43c5a-f449-4ee6-aeee-cbe2c09d6dee	4116e390-3789-4721-9e7b-133ebb2764c7	پیاده‌سازی بخش اصلی	170	78	2026-07-16	approved	58d048c0-3e97-449e-bb15-1a8b9a558017	\N	bbfd84e3-d637-46ed-9910-91c006faf93d	2026-07-20 11:11:03.957452+00	2026-07-20 11:11:03.957452+00
4dcc3819-424c-4d09-9482-91ed2d9d19ab	b0a43c5a-f449-4ee6-aeee-cbe2c09d6dee	4116e390-3789-4721-9e7b-133ebb2764c7	پیشرفت اولیه و بررسی نیازمندی‌ها	228	87	2026-07-16	approved	58d048c0-3e97-449e-bb15-1a8b9a558017	\N	0864fe66-072d-4e31-9287-9588ff0f7c5e	2026-07-20 11:11:03.957452+00	2026-07-20 11:11:03.957452+00
4dcc3819-424c-4d09-9482-91ed2d9d19ab	b0a43c5a-f449-4ee6-aeee-cbe2c09d6dee	4116e390-3789-4721-9e7b-133ebb2764c7	رفع اشکالات و بازبینی	61	84	2026-07-16	approved	58d048c0-3e97-449e-bb15-1a8b9a558017	\N	0d1caa21-741a-4188-b79c-1631885fc748	2026-07-20 11:11:03.957452+00	2026-07-20 11:11:03.957452+00
4dcc3819-424c-4d09-9482-91ed2d9d19ab	8ef2345a-0678-4890-902c-646543f64def	5742bab4-624b-41df-aff7-c3517eed7f4c	رفع اشکالات و بازبینی	107	20	2026-07-16	approved	5e03da3d-4fd1-4305-91ec-8a61bd1f28ee	\N	da578556-94d1-43bc-aeea-a740e82136c3	2026-07-20 11:11:03.957452+00	2026-07-20 11:11:03.957452+00
4dcc3819-424c-4d09-9482-91ed2d9d19ab	8ef2345a-0678-4890-902c-646543f64def	5742bab4-624b-41df-aff7-c3517eed7f4c	پیشرفت اولیه و بررسی نیازمندی‌ها	221	70	2026-07-16	submitted	\N	\N	aa2e9f03-1379-481e-a42a-f4ec8a998ec5	2026-07-20 11:11:03.957452+00	2026-07-20 11:11:03.957452+00
4dcc3819-424c-4d09-9482-91ed2d9d19ab	a60512a6-dde5-455c-a1e8-e1f0e2ffc9d1	d7465638-ca92-4b34-b9b1-b1ab5012de48	پیاده‌سازی بخش اصلی	171	30	2026-07-13	approved	5e03da3d-4fd1-4305-91ec-8a61bd1f28ee	\N	5da612bf-07d0-4567-aea7-f3e47634273c	2026-07-20 11:11:03.957452+00	2026-07-20 11:11:03.957452+00
4dcc3819-424c-4d09-9482-91ed2d9d19ab	a60512a6-dde5-455c-a1e8-e1f0e2ffc9d1	d7465638-ca92-4b34-b9b1-b1ab5012de48	مستندسازی و نهایی‌سازی	196	62	2026-07-16	approved	5e03da3d-4fd1-4305-91ec-8a61bd1f28ee	\N	add37414-b7e2-4627-94b6-cc96edbafbd1	2026-07-20 11:11:03.957452+00	2026-07-20 11:11:03.957452+00
4dcc3819-424c-4d09-9482-91ed2d9d19ab	2c3ed8a1-74f1-46ef-9367-2ccff0d29774	24baa76f-b9d0-4a8f-b28d-605d780d066a	رفع اشکالات و بازبینی	161	35	2026-07-09	approved	5e03da3d-4fd1-4305-91ec-8a61bd1f28ee	\N	23d9d4a6-9611-47e3-ba78-fd85de3443bd	2026-07-20 11:11:03.957452+00	2026-07-20 11:11:03.957452+00
4dcc3819-424c-4d09-9482-91ed2d9d19ab	2c3ed8a1-74f1-46ef-9367-2ccff0d29774	24baa76f-b9d0-4a8f-b28d-605d780d066a	پیشرفت اولیه و بررسی نیازمندی‌ها	235	70	2026-07-13	approved	5e03da3d-4fd1-4305-91ec-8a61bd1f28ee	\N	a1922f54-b963-45a1-bd1a-ba9a146d2821	2026-07-20 11:11:03.957452+00	2026-07-20 11:11:03.957452+00
4dcc3819-424c-4d09-9482-91ed2d9d19ab	2c3ed8a1-74f1-46ef-9367-2ccff0d29774	24baa76f-b9d0-4a8f-b28d-605d780d066a	پیاده‌سازی بخش اصلی	124	90	2026-07-15	approved	5e03da3d-4fd1-4305-91ec-8a61bd1f28ee	\N	77b29346-05b1-47b1-959d-ae134f285abc	2026-07-20 11:11:03.957452+00	2026-07-20 11:11:03.957452+00
4dcc3819-424c-4d09-9482-91ed2d9d19ab	5b6eaf97-2d21-40ba-92f0-4ece740c2f33	5e03da3d-4fd1-4305-91ec-8a61bd1f28ee	مستندسازی و نهایی‌سازی	86	24	2026-07-16	approved	5e03da3d-4fd1-4305-91ec-8a61bd1f28ee	\N	eea7767e-d1e6-4095-aea0-8cda3a55e209	2026-07-20 11:11:03.957452+00	2026-07-20 11:11:03.957452+00
4dcc3819-424c-4d09-9482-91ed2d9d19ab	5b6eaf97-2d21-40ba-92f0-4ece740c2f33	5e03da3d-4fd1-4305-91ec-8a61bd1f28ee	رفع اشکالات و بازبینی	171	76	2026-07-16	approved	5e03da3d-4fd1-4305-91ec-8a61bd1f28ee	\N	adb0e101-11ee-4b80-bae3-598d40c0d16d	2026-07-20 11:11:03.957452+00	2026-07-20 11:11:03.957452+00
4dcc3819-424c-4d09-9482-91ed2d9d19ab	5b6eaf97-2d21-40ba-92f0-4ece740c2f33	5e03da3d-4fd1-4305-91ec-8a61bd1f28ee	رفع اشکالات و بازبینی	69	78	2026-07-16	approved	5e03da3d-4fd1-4305-91ec-8a61bd1f28ee	\N	56af5350-5212-46dc-ba02-05e44b31b000	2026-07-20 11:11:03.957452+00	2026-07-20 11:11:03.957452+00
4dcc3819-424c-4d09-9482-91ed2d9d19ab	5b6eaf97-2d21-40ba-92f0-4ece740c2f33	5e03da3d-4fd1-4305-91ec-8a61bd1f28ee	پیاده‌سازی بخش اصلی	127	100	2026-07-16	approved	5e03da3d-4fd1-4305-91ec-8a61bd1f28ee	\N	ace54ec6-7d8c-4593-875c-02f73628dc6a	2026-07-20 11:11:03.957452+00	2026-07-20 11:11:03.957452+00
4dcc3819-424c-4d09-9482-91ed2d9d19ab	a6a64efd-3c9a-4ef7-9fc9-a8ee6c45291c	5e03da3d-4fd1-4305-91ec-8a61bd1f28ee	رفع اشکالات و بازبینی	95	35	2026-07-16	approved	5e03da3d-4fd1-4305-91ec-8a61bd1f28ee	\N	6314a3b3-9d0d-4bda-98f7-12a1056bf20c	2026-07-20 11:11:03.957452+00	2026-07-20 11:11:03.957452+00
4dcc3819-424c-4d09-9482-91ed2d9d19ab	a6a64efd-3c9a-4ef7-9fc9-a8ee6c45291c	5e03da3d-4fd1-4305-91ec-8a61bd1f28ee	رفع اشکالات و بازبینی	73	48	2026-07-16	approved	5e03da3d-4fd1-4305-91ec-8a61bd1f28ee	\N	6c71692f-ff47-4d4a-9ffa-31aad0da0907	2026-07-20 11:11:03.957452+00	2026-07-20 11:11:03.957452+00
4dcc3819-424c-4d09-9482-91ed2d9d19ab	374052cc-557f-47d5-af6c-38c510f484c3	24baa76f-b9d0-4a8f-b28d-605d780d066a	مستندسازی و نهایی‌سازی	194	21	2026-07-14	approved	5e03da3d-4fd1-4305-91ec-8a61bd1f28ee	\N	d5d991eb-9e79-4c2c-a3da-30397a76b395	2026-07-20 11:11:03.957452+00	2026-07-20 11:11:03.957452+00
4dcc3819-424c-4d09-9482-91ed2d9d19ab	374052cc-557f-47d5-af6c-38c510f484c3	24baa76f-b9d0-4a8f-b28d-605d780d066a	پیشرفت اولیه و بررسی نیازمندی‌ها	239	42	2026-07-15	approved	5e03da3d-4fd1-4305-91ec-8a61bd1f28ee	\N	fce58f6b-7807-452b-97ee-f3c9acc47326	2026-07-20 11:11:03.957452+00	2026-07-20 11:11:03.957452+00
4dcc3819-424c-4d09-9482-91ed2d9d19ab	374052cc-557f-47d5-af6c-38c510f484c3	24baa76f-b9d0-4a8f-b28d-605d780d066a	تست و اطمینان از عملکرد صحیح	65	100	2026-07-16	approved	5e03da3d-4fd1-4305-91ec-8a61bd1f28ee	\N	c5c092fd-b446-42b4-8b88-dea9db4305c1	2026-07-20 11:11:03.957452+00	2026-07-20 11:11:03.957452+00
4dcc3819-424c-4d09-9482-91ed2d9d19ab	374052cc-557f-47d5-af6c-38c510f484c3	24baa76f-b9d0-4a8f-b28d-605d780d066a	پیشرفت اولیه و بررسی نیازمندی‌ها	211	96	2026-07-16	approved	5e03da3d-4fd1-4305-91ec-8a61bd1f28ee	\N	6ae4eb20-cd68-43be-a780-89ba8fa1ddc8	2026-07-20 11:11:03.957452+00	2026-07-20 11:11:03.957452+00
4dcc3819-424c-4d09-9482-91ed2d9d19ab	f4986501-dbb0-48b2-bbcf-2138979d2750	8d97ee0b-e8f3-4aec-ab48-db76ef6ede39	رفع اشکالات و بازبینی	45	39	2026-07-16	approved	5e03da3d-4fd1-4305-91ec-8a61bd1f28ee	\N	7208cbf3-4b03-41a2-a17c-8e02bca847e7	2026-07-20 11:11:03.957452+00	2026-07-20 11:11:03.957452+00
4dcc3819-424c-4d09-9482-91ed2d9d19ab	0291ddd2-9393-4f9b-80d8-73030877a22f	d7465638-ca92-4b34-b9b1-b1ab5012de48	پیشرفت اولیه و بررسی نیازمندی‌ها	31	37	2026-07-16	approved	5e03da3d-4fd1-4305-91ec-8a61bd1f28ee	\N	843bf392-b515-4914-bf71-9552bfa4818b	2026-07-20 11:11:03.957452+00	2026-07-20 11:11:03.957452+00
4dcc3819-424c-4d09-9482-91ed2d9d19ab	0291ddd2-9393-4f9b-80d8-73030877a22f	d7465638-ca92-4b34-b9b1-b1ab5012de48	پیشرفت اولیه و بررسی نیازمندی‌ها	34	72	2026-07-16	approved	5e03da3d-4fd1-4305-91ec-8a61bd1f28ee	\N	e6a80aeb-8ce4-473a-8356-f1f8fabf65b5	2026-07-20 11:11:03.957452+00	2026-07-20 11:11:03.957452+00
4dcc3819-424c-4d09-9482-91ed2d9d19ab	0291ddd2-9393-4f9b-80d8-73030877a22f	d7465638-ca92-4b34-b9b1-b1ab5012de48	مستندسازی و نهایی‌سازی	103	60	2026-07-16	approved	5e03da3d-4fd1-4305-91ec-8a61bd1f28ee	\N	fc1d3272-c93e-4690-94d1-d75ef4dee363	2026-07-20 11:11:03.957452+00	2026-07-20 11:11:03.957452+00
4dcc3819-424c-4d09-9482-91ed2d9d19ab	0291ddd2-9393-4f9b-80d8-73030877a22f	d7465638-ca92-4b34-b9b1-b1ab5012de48	پیاده‌سازی بخش اصلی	57	92	2026-07-16	approved	5e03da3d-4fd1-4305-91ec-8a61bd1f28ee	\N	851b7e21-49aa-4673-afeb-2a29da00c22f	2026-07-20 11:11:03.957452+00	2026-07-20 11:11:03.957452+00
4dcc3819-424c-4d09-9482-91ed2d9d19ab	62a933f4-b7dd-4c44-9e60-ab32c94aaf91	5742bab4-624b-41df-aff7-c3517eed7f4c	مستندسازی و نهایی‌سازی	94	31	2026-06-23	approved	5e03da3d-4fd1-4305-91ec-8a61bd1f28ee	\N	f9bbec25-4da1-4e54-8a4e-b6b35d474ed7	2026-07-20 11:11:03.957452+00	2026-07-20 11:11:03.957452+00
4dcc3819-424c-4d09-9482-91ed2d9d19ab	62a933f4-b7dd-4c44-9e60-ab32c94aaf91	5742bab4-624b-41df-aff7-c3517eed7f4c	پیشرفت اولیه و بررسی نیازمندی‌ها	125	64	2026-06-26	submitted	\N	\N	76613fd3-2bdf-4910-9bfa-22b8bfa78c46	2026-07-20 11:11:03.957452+00	2026-07-20 11:11:03.957452+00
4dcc3819-424c-4d09-9482-91ed2d9d19ab	07e8d1d2-7b8b-47d8-9e11-c3ee334e1772	5742bab4-624b-41df-aff7-c3517eed7f4c	پیاده‌سازی بخش اصلی	106	22	2026-07-16	approved	5e03da3d-4fd1-4305-91ec-8a61bd1f28ee	\N	c1f01994-b51b-46f3-b4a5-b20db7fbacfe	2026-07-20 11:11:03.957452+00	2026-07-20 11:11:03.957452+00
4dcc3819-424c-4d09-9482-91ed2d9d19ab	07e8d1d2-7b8b-47d8-9e11-c3ee334e1772	5742bab4-624b-41df-aff7-c3517eed7f4c	پیشرفت اولیه و بررسی نیازمندی‌ها	133	64	2026-07-16	approved	5e03da3d-4fd1-4305-91ec-8a61bd1f28ee	\N	1e55c75b-a0d9-444c-9499-efa52e257c93	2026-07-20 11:11:03.957452+00	2026-07-20 11:11:03.957452+00
4dcc3819-424c-4d09-9482-91ed2d9d19ab	07e8d1d2-7b8b-47d8-9e11-c3ee334e1772	5742bab4-624b-41df-aff7-c3517eed7f4c	مستندسازی و نهایی‌سازی	151	63	2026-07-16	approved	5e03da3d-4fd1-4305-91ec-8a61bd1f28ee	\N	f17892f1-343a-4106-9ae8-a168d5a3ac4a	2026-07-20 11:11:03.957452+00	2026-07-20 11:11:03.957452+00
4dcc3819-424c-4d09-9482-91ed2d9d19ab	07e8d1d2-7b8b-47d8-9e11-c3ee334e1772	5742bab4-624b-41df-aff7-c3517eed7f4c	پیاده‌سازی بخش اصلی	51	100	2026-07-16	approved	5e03da3d-4fd1-4305-91ec-8a61bd1f28ee	\N	eaffdc0c-aa0e-4bf1-a37c-1a7302f8975a	2026-07-20 11:11:03.957452+00	2026-07-20 11:11:03.957452+00
4dcc3819-424c-4d09-9482-91ed2d9d19ab	b1edd6ea-7be8-45ab-8b20-37f7fdebcff2	8e78a4d9-50d5-40e6-bcd8-fd3f57c31286	مستندسازی و نهایی‌سازی	54	36	2026-07-09	approved	5e03da3d-4fd1-4305-91ec-8a61bd1f28ee	\N	afa8b4dd-3c5c-4c7a-a783-149e1920f3ad	2026-07-20 11:11:03.957452+00	2026-07-20 11:11:03.957452+00
4dcc3819-424c-4d09-9482-91ed2d9d19ab	b1edd6ea-7be8-45ab-8b20-37f7fdebcff2	8e78a4d9-50d5-40e6-bcd8-fd3f57c31286	پیاده‌سازی بخش اصلی	84	76	2026-07-10	approved	5e03da3d-4fd1-4305-91ec-8a61bd1f28ee	\N	d40aa07e-29f2-484e-ae43-481766187162	2026-07-20 11:11:03.957452+00	2026-07-20 11:11:03.957452+00
4dcc3819-424c-4d09-9482-91ed2d9d19ab	b1edd6ea-7be8-45ab-8b20-37f7fdebcff2	8e78a4d9-50d5-40e6-bcd8-fd3f57c31286	رفع اشکالات و بازبینی	41	66	2026-07-16	approved	5e03da3d-4fd1-4305-91ec-8a61bd1f28ee	\N	120bef15-aad9-4610-93e9-1913aa8b49f5	2026-07-20 11:11:03.957452+00	2026-07-20 11:11:03.957452+00
4dcc3819-424c-4d09-9482-91ed2d9d19ab	b1edd6ea-7be8-45ab-8b20-37f7fdebcff2	8e78a4d9-50d5-40e6-bcd8-fd3f57c31286	مستندسازی و نهایی‌سازی	174	84	2026-07-16	approved	5e03da3d-4fd1-4305-91ec-8a61bd1f28ee	\N	a59bad82-883a-4da9-887f-862b3dad6deb	2026-07-20 11:11:03.957452+00	2026-07-20 11:11:03.957452+00
4dcc3819-424c-4d09-9482-91ed2d9d19ab	d4e743cc-35ea-48ce-9e9e-d3629e9a37df	8d97ee0b-e8f3-4aec-ab48-db76ef6ede39	پیشرفت اولیه و بررسی نیازمندی‌ها	83	38	2026-07-16	approved	5e03da3d-4fd1-4305-91ec-8a61bd1f28ee	\N	b5bf3203-17a7-4912-ad67-362b068566f9	2026-07-20 11:11:03.957452+00	2026-07-20 11:11:03.957452+00
4dcc3819-424c-4d09-9482-91ed2d9d19ab	d4e743cc-35ea-48ce-9e9e-d3629e9a37df	8d97ee0b-e8f3-4aec-ab48-db76ef6ede39	تست و اطمینان از عملکرد صحیح	49	58	2026-07-16	approved	5e03da3d-4fd1-4305-91ec-8a61bd1f28ee	\N	704ab94c-2882-410b-bfbd-fcdbabc2edf0	2026-07-20 11:11:03.957452+00	2026-07-20 11:11:03.957452+00
4dcc3819-424c-4d09-9482-91ed2d9d19ab	70f473dc-0908-467a-8a59-0d88b0971675	8e78a4d9-50d5-40e6-bcd8-fd3f57c31286	مستندسازی و نهایی‌سازی	129	37	2026-07-16	approved	5e03da3d-4fd1-4305-91ec-8a61bd1f28ee	\N	dcf79600-49e2-4e3f-8f2f-58ca4fd512f8	2026-07-20 11:11:03.957452+00	2026-07-20 11:11:03.957452+00
4dcc3819-424c-4d09-9482-91ed2d9d19ab	70f473dc-0908-467a-8a59-0d88b0971675	8e78a4d9-50d5-40e6-bcd8-fd3f57c31286	تست و اطمینان از عملکرد صحیح	223	48	2026-07-16	approved	5e03da3d-4fd1-4305-91ec-8a61bd1f28ee	\N	e027e3e6-2984-42a8-9a98-c42438ab4271	2026-07-20 11:11:03.957452+00	2026-07-20 11:11:03.957452+00
4dcc3819-424c-4d09-9482-91ed2d9d19ab	cd89eb97-d966-4565-8fcc-5707bbade6fc	5742bab4-624b-41df-aff7-c3517eed7f4c	پیشرفت اولیه و بررسی نیازمندی‌ها	55	33	2026-07-15	approved	5e03da3d-4fd1-4305-91ec-8a61bd1f28ee	\N	7a3bcc4b-f825-4514-b1f6-6f83e4075543	2026-07-20 11:11:03.957452+00	2026-07-20 11:11:03.957452+00
4dcc3819-424c-4d09-9482-91ed2d9d19ab	dba59333-ca37-492a-9547-9a935f28ef0d	d7465638-ca92-4b34-b9b1-b1ab5012de48	رفع اشکالات و بازبینی	184	39	2026-06-27	approved	5e03da3d-4fd1-4305-91ec-8a61bd1f28ee	\N	b48ef0b6-fa70-476d-8492-5a3605848786	2026-07-20 11:11:03.957452+00	2026-07-20 11:11:03.957452+00
4dcc3819-424c-4d09-9482-91ed2d9d19ab	dba59333-ca37-492a-9547-9a935f28ef0d	d7465638-ca92-4b34-b9b1-b1ab5012de48	رفع اشکالات و بازبینی	37	80	2026-07-01	approved	5e03da3d-4fd1-4305-91ec-8a61bd1f28ee	\N	567e1c9b-e9ca-448a-a8ef-170ea5314d92	2026-07-20 11:11:03.957452+00	2026-07-20 11:11:03.957452+00
4dcc3819-424c-4d09-9482-91ed2d9d19ab	f8c77226-493c-4694-8982-c6c5da6aef3b	8e78a4d9-50d5-40e6-bcd8-fd3f57c31286	رفع اشکالات و بازبینی	171	32	2026-07-08	approved	5e03da3d-4fd1-4305-91ec-8a61bd1f28ee	\N	2c7b1c5d-c62f-4e63-a98e-adeecc79d48a	2026-07-20 11:11:03.957452+00	2026-07-20 11:11:03.957452+00
4dcc3819-424c-4d09-9482-91ed2d9d19ab	f8c77226-493c-4694-8982-c6c5da6aef3b	8e78a4d9-50d5-40e6-bcd8-fd3f57c31286	مستندسازی و نهایی‌سازی	199	64	2026-07-12	approved	5e03da3d-4fd1-4305-91ec-8a61bd1f28ee	\N	ebde33ec-dfc5-4c6b-9c28-203045045da0	2026-07-20 11:11:03.957452+00	2026-07-20 11:11:03.957452+00
4dcc3819-424c-4d09-9482-91ed2d9d19ab	f8c77226-493c-4694-8982-c6c5da6aef3b	8e78a4d9-50d5-40e6-bcd8-fd3f57c31286	رفع اشکالات و بازبینی	234	81	2026-07-10	submitted	\N	\N	4afa6181-0768-4128-9a92-59d5deba6a76	2026-07-20 11:11:03.957452+00	2026-07-20 11:11:03.957452+00
4dcc3819-424c-4d09-9482-91ed2d9d19ab	98c10ee5-f50a-4459-b1ce-0d226e2b0ff0	8e78a4d9-50d5-40e6-bcd8-fd3f57c31286	رفع اشکالات و بازبینی	69	32	2026-07-16	approved	5e03da3d-4fd1-4305-91ec-8a61bd1f28ee	\N	9d0bac81-61ca-4382-a166-8ecd7d6c7d59	2026-07-20 11:11:03.957452+00	2026-07-20 11:11:03.957452+00
4dcc3819-424c-4d09-9482-91ed2d9d19ab	36029507-d055-45ed-83e5-f59dff649d4d	7a6ee833-86b5-4c74-a2b1-845608f4fbab	پیشرفت اولیه و بررسی نیازمندی‌ها	53	20	2026-07-16	approved	5e03da3d-4fd1-4305-91ec-8a61bd1f28ee	\N	2305c18d-a93e-4c01-a00c-d38e4895b1af	2026-07-20 11:11:03.957452+00	2026-07-20 11:11:03.957452+00
4dcc3819-424c-4d09-9482-91ed2d9d19ab	36029507-d055-45ed-83e5-f59dff649d4d	7a6ee833-86b5-4c74-a2b1-845608f4fbab	رفع اشکالات و بازبینی	56	48	2026-07-16	approved	5e03da3d-4fd1-4305-91ec-8a61bd1f28ee	\N	bfd0b207-0642-4d2a-9cd7-93e77a133fa5	2026-07-20 11:11:03.957452+00	2026-07-20 11:11:03.957452+00
4dcc3819-424c-4d09-9482-91ed2d9d19ab	5b535b8c-2967-4fa2-8204-a75271c08871	8e78a4d9-50d5-40e6-bcd8-fd3f57c31286	تست و اطمینان از عملکرد صحیح	144	37	2026-07-16	approved	5e03da3d-4fd1-4305-91ec-8a61bd1f28ee	\N	bc00380e-885e-4882-a5e3-89666c7b00ba	2026-07-20 11:11:03.957452+00	2026-07-20 11:11:03.957452+00
4dcc3819-424c-4d09-9482-91ed2d9d19ab	0197f7a2-c941-4f2d-93d2-9103cfe3e234	d7465638-ca92-4b34-b9b1-b1ab5012de48	پیشرفت اولیه و بررسی نیازمندی‌ها	52	31	2026-07-15	approved	5e03da3d-4fd1-4305-91ec-8a61bd1f28ee	\N	497e5044-7ec4-4804-b7a8-769ecaa396c4	2026-07-20 11:11:03.957452+00	2026-07-20 11:11:03.957452+00
4dcc3819-424c-4d09-9482-91ed2d9d19ab	0197f7a2-c941-4f2d-93d2-9103cfe3e234	d7465638-ca92-4b34-b9b1-b1ab5012de48	مستندسازی و نهایی‌سازی	183	60	2026-07-16	approved	5e03da3d-4fd1-4305-91ec-8a61bd1f28ee	\N	98b6ee31-2372-48c0-a241-e39d198403aa	2026-07-20 11:11:03.957452+00	2026-07-20 11:11:03.957452+00
4dcc3819-424c-4d09-9482-91ed2d9d19ab	0197f7a2-c941-4f2d-93d2-9103cfe3e234	d7465638-ca92-4b34-b9b1-b1ab5012de48	پیشرفت اولیه و بررسی نیازمندی‌ها	104	99	2026-07-16	approved	5e03da3d-4fd1-4305-91ec-8a61bd1f28ee	\N	b85ac672-9206-4329-9d1a-6b3dc8cba6f6	2026-07-20 11:11:03.957452+00	2026-07-20 11:11:03.957452+00
4dcc3819-424c-4d09-9482-91ed2d9d19ab	0197f7a2-c941-4f2d-93d2-9103cfe3e234	d7465638-ca92-4b34-b9b1-b1ab5012de48	پیشرفت اولیه و بررسی نیازمندی‌ها	215	100	2026-07-16	approved	5e03da3d-4fd1-4305-91ec-8a61bd1f28ee	\N	54d266f8-5d42-4a35-90b4-209b6187cdab	2026-07-20 11:11:03.957452+00	2026-07-20 11:11:03.957452+00
4dcc3819-424c-4d09-9482-91ed2d9d19ab	20311053-75e7-4622-9938-c6e6eaa3129d	8d97ee0b-e8f3-4aec-ab48-db76ef6ede39	تست و اطمینان از عملکرد صحیح	73	24	2026-07-07	approved	5e03da3d-4fd1-4305-91ec-8a61bd1f28ee	\N	7faf3c19-09de-4675-ba79-35fac1e840a9	2026-07-20 11:11:03.957452+00	2026-07-20 11:11:03.957452+00
4dcc3819-424c-4d09-9482-91ed2d9d19ab	20311053-75e7-4622-9938-c6e6eaa3129d	8d97ee0b-e8f3-4aec-ab48-db76ef6ede39	رفع اشکالات و بازبینی	98	70	2026-07-10	approved	5e03da3d-4fd1-4305-91ec-8a61bd1f28ee	\N	1e8d9ee7-9d19-45e6-9726-88480107ca6a	2026-07-20 11:11:03.957452+00	2026-07-20 11:11:03.957452+00
4dcc3819-424c-4d09-9482-91ed2d9d19ab	90e29895-8f1a-49bf-b6c5-cd0af8d17aa5	5742bab4-624b-41df-aff7-c3517eed7f4c	پیاده‌سازی بخش اصلی	141	28	2026-07-16	approved	5e03da3d-4fd1-4305-91ec-8a61bd1f28ee	\N	eaad4832-1882-4bfb-bdbb-f1157c0794e5	2026-07-20 11:11:03.957452+00	2026-07-20 11:11:03.957452+00
4dcc3819-424c-4d09-9482-91ed2d9d19ab	90e29895-8f1a-49bf-b6c5-cd0af8d17aa5	5742bab4-624b-41df-aff7-c3517eed7f4c	رفع اشکالات و بازبینی	153	44	2026-07-16	approved	5e03da3d-4fd1-4305-91ec-8a61bd1f28ee	\N	0564ce1e-5e5d-41bf-b6f6-add453a04a05	2026-07-20 11:11:03.957452+00	2026-07-20 11:11:03.957452+00
4dcc3819-424c-4d09-9482-91ed2d9d19ab	1fc5d2bd-36e5-4480-a94b-21e0534edf23	5e03da3d-4fd1-4305-91ec-8a61bd1f28ee	تست و اطمینان از عملکرد صحیح	182	39	2026-07-01	submitted	\N	\N	db04f986-b68e-42b1-a59d-2e7104007d68	2026-07-20 11:11:03.957452+00	2026-07-20 11:11:03.957452+00
4dcc3819-424c-4d09-9482-91ed2d9d19ab	1fc5d2bd-36e5-4480-a94b-21e0534edf23	5e03da3d-4fd1-4305-91ec-8a61bd1f28ee	پیاده‌سازی بخش اصلی	107	40	2026-07-03	approved	5e03da3d-4fd1-4305-91ec-8a61bd1f28ee	\N	6d8885b3-8c87-416f-bd1e-59e34e0670a0	2026-07-20 11:11:03.957452+00	2026-07-20 11:11:03.957452+00
4dcc3819-424c-4d09-9482-91ed2d9d19ab	1fc5d2bd-36e5-4480-a94b-21e0534edf23	5e03da3d-4fd1-4305-91ec-8a61bd1f28ee	مستندسازی و نهایی‌سازی	127	90	2026-07-09	approved	5e03da3d-4fd1-4305-91ec-8a61bd1f28ee	\N	0ce1fdd9-47e9-41f5-90a4-e198d41fc8ea	2026-07-20 11:11:03.957452+00	2026-07-20 11:11:03.957452+00
4dcc3819-424c-4d09-9482-91ed2d9d19ab	fb9d7cdf-6a0e-4d1a-a615-3db27c23daee	24baa76f-b9d0-4a8f-b28d-605d780d066a	تست و اطمینان از عملکرد صحیح	238	40	2026-07-15	approved	5e03da3d-4fd1-4305-91ec-8a61bd1f28ee	\N	c9cc23a5-4e50-43b9-a6fa-ce1c054887bf	2026-07-20 11:11:03.957452+00	2026-07-20 11:11:03.957452+00
4dcc3819-424c-4d09-9482-91ed2d9d19ab	fb9d7cdf-6a0e-4d1a-a615-3db27c23daee	24baa76f-b9d0-4a8f-b28d-605d780d066a	رفع اشکالات و بازبینی	112	78	2026-07-16	approved	5e03da3d-4fd1-4305-91ec-8a61bd1f28ee	\N	ab83ec0d-5864-4382-baed-f8bb7254d872	2026-07-20 11:11:03.957452+00	2026-07-20 11:11:03.957452+00
4dcc3819-424c-4d09-9482-91ed2d9d19ab	fb9d7cdf-6a0e-4d1a-a615-3db27c23daee	24baa76f-b9d0-4a8f-b28d-605d780d066a	تست و اطمینان از عملکرد صحیح	110	75	2026-07-16	approved	5e03da3d-4fd1-4305-91ec-8a61bd1f28ee	\N	04e5c9a4-3d91-4e45-a19b-0d89d9d64434	2026-07-20 11:11:03.957452+00	2026-07-20 11:11:03.957452+00
4dcc3819-424c-4d09-9482-91ed2d9d19ab	fb9d7cdf-6a0e-4d1a-a615-3db27c23daee	24baa76f-b9d0-4a8f-b28d-605d780d066a	رفع اشکالات و بازبینی	104	100	2026-07-16	approved	5e03da3d-4fd1-4305-91ec-8a61bd1f28ee	\N	026484ad-ed9f-4010-a601-a0098979132e	2026-07-20 11:11:03.957452+00	2026-07-20 11:11:03.957452+00
4dcc3819-424c-4d09-9482-91ed2d9d19ab	3474c7a6-df57-4bc4-9f5f-14a21299c785	5e03da3d-4fd1-4305-91ec-8a61bd1f28ee	رفع اشکالات و بازبینی	239	32	2026-07-16	approved	5e03da3d-4fd1-4305-91ec-8a61bd1f28ee	\N	8cde2bbe-5a61-4188-90d3-dd13fda7f814	2026-07-20 11:11:03.957452+00	2026-07-20 11:11:03.957452+00
4dcc3819-424c-4d09-9482-91ed2d9d19ab	3474c7a6-df57-4bc4-9f5f-14a21299c785	5e03da3d-4fd1-4305-91ec-8a61bd1f28ee	مستندسازی و نهایی‌سازی	81	76	2026-07-16	approved	5e03da3d-4fd1-4305-91ec-8a61bd1f28ee	\N	c21d00bf-9d0d-4a37-85fe-44e76e140d83	2026-07-20 11:11:03.957452+00	2026-07-20 11:11:03.957452+00
4dcc3819-424c-4d09-9482-91ed2d9d19ab	3474c7a6-df57-4bc4-9f5f-14a21299c785	5e03da3d-4fd1-4305-91ec-8a61bd1f28ee	مستندسازی و نهایی‌سازی	36	100	2026-07-16	approved	5e03da3d-4fd1-4305-91ec-8a61bd1f28ee	\N	b0241269-3207-476f-9742-daea28c35c35	2026-07-20 11:11:03.957452+00	2026-07-20 11:11:03.957452+00
4dcc3819-424c-4d09-9482-91ed2d9d19ab	3474c7a6-df57-4bc4-9f5f-14a21299c785	5e03da3d-4fd1-4305-91ec-8a61bd1f28ee	رفع اشکالات و بازبینی	207	88	2026-07-16	approved	5e03da3d-4fd1-4305-91ec-8a61bd1f28ee	\N	02a823ac-6f21-41f1-a0ed-2d103ca0b728	2026-07-20 11:11:03.957452+00	2026-07-20 11:11:03.957452+00
4dcc3819-424c-4d09-9482-91ed2d9d19ab	985811df-d3de-4c8e-8f22-91899134d2d9	5e03da3d-4fd1-4305-91ec-8a61bd1f28ee	رفع اشکالات و بازبینی	91	28	2026-07-16	approved	5e03da3d-4fd1-4305-91ec-8a61bd1f28ee	\N	b5ad609f-33aa-4a6c-a766-4c950f65c5aa	2026-07-20 11:11:03.957452+00	2026-07-20 11:11:03.957452+00
4dcc3819-424c-4d09-9482-91ed2d9d19ab	985811df-d3de-4c8e-8f22-91899134d2d9	5e03da3d-4fd1-4305-91ec-8a61bd1f28ee	تست و اطمینان از عملکرد صحیح	48	68	2026-07-16	submitted	\N	\N	56299761-12f5-4e5c-9f1d-f768dd9c866f	2026-07-20 11:11:03.957452+00	2026-07-20 11:11:03.957452+00
4dcc3819-424c-4d09-9482-91ed2d9d19ab	985811df-d3de-4c8e-8f22-91899134d2d9	5e03da3d-4fd1-4305-91ec-8a61bd1f28ee	مستندسازی و نهایی‌سازی	159	99	2026-07-16	approved	5e03da3d-4fd1-4305-91ec-8a61bd1f28ee	\N	11621ed7-0cff-4544-a61d-59c04b77a098	2026-07-20 11:11:03.957452+00	2026-07-20 11:11:03.957452+00
4dcc3819-424c-4d09-9482-91ed2d9d19ab	985811df-d3de-4c8e-8f22-91899134d2d9	5e03da3d-4fd1-4305-91ec-8a61bd1f28ee	رفع اشکالات و بازبینی	209	100	2026-07-16	submitted	\N	\N	1eb21062-637a-4111-a6fb-fb810d1b7209	2026-07-20 11:11:03.957452+00	2026-07-20 11:11:03.957452+00
4dcc3819-424c-4d09-9482-91ed2d9d19ab	502d45a5-3de5-4569-8dfb-b9325bba8205	7a6ee833-86b5-4c74-a2b1-845608f4fbab	پیاده‌سازی بخش اصلی	198	31	2026-06-24	approved	5e03da3d-4fd1-4305-91ec-8a61bd1f28ee	\N	bc50553c-3a4a-4ef4-8359-7e7365ca632f	2026-07-20 11:11:03.957452+00	2026-07-20 11:11:03.957452+00
4dcc3819-424c-4d09-9482-91ed2d9d19ab	ee75a05f-48bc-4fee-87d8-605085e4e531	5742bab4-624b-41df-aff7-c3517eed7f4c	مستندسازی و نهایی‌سازی	195	40	2026-07-16	approved	5e03da3d-4fd1-4305-91ec-8a61bd1f28ee	\N	01852f7b-71d1-4aec-9eae-dcb23265930a	2026-07-20 11:11:03.957452+00	2026-07-20 11:11:03.957452+00
4dcc3819-424c-4d09-9482-91ed2d9d19ab	ee75a05f-48bc-4fee-87d8-605085e4e531	5742bab4-624b-41df-aff7-c3517eed7f4c	رفع اشکالات و بازبینی	233	66	2026-07-16	approved	5e03da3d-4fd1-4305-91ec-8a61bd1f28ee	\N	3e6e3fb7-3239-46aa-9069-945a94aafbd9	2026-07-20 11:11:03.957452+00	2026-07-20 11:11:03.957452+00
4dcc3819-424c-4d09-9482-91ed2d9d19ab	9c8365ea-a6f5-4967-9efa-62c3cc789129	7a6ee833-86b5-4c74-a2b1-845608f4fbab	پیشرفت اولیه و بررسی نیازمندی‌ها	96	27	2026-07-16	approved	5e03da3d-4fd1-4305-91ec-8a61bd1f28ee	\N	dabca4dc-9f1c-4646-a101-f6147c1af5df	2026-07-20 11:11:03.957452+00	2026-07-20 11:11:03.957452+00
4dcc3819-424c-4d09-9482-91ed2d9d19ab	14cf657f-c4ec-45a7-8179-2eec35031e1e	d7465638-ca92-4b34-b9b1-b1ab5012de48	رفع اشکالات و بازبینی	130	34	2026-07-16	approved	5e03da3d-4fd1-4305-91ec-8a61bd1f28ee	\N	993994a3-038f-4361-8e77-87010afa6497	2026-07-20 11:11:03.957452+00	2026-07-20 11:11:03.957452+00
4dcc3819-424c-4d09-9482-91ed2d9d19ab	14cf657f-c4ec-45a7-8179-2eec35031e1e	d7465638-ca92-4b34-b9b1-b1ab5012de48	رفع اشکالات و بازبینی	36	70	2026-07-16	approved	5e03da3d-4fd1-4305-91ec-8a61bd1f28ee	\N	31e5fa18-704a-4437-b6ef-ffffaab796d7	2026-07-20 11:11:03.957452+00	2026-07-20 11:11:03.957452+00
4dcc3819-424c-4d09-9482-91ed2d9d19ab	7cf51bc5-f86c-4ecd-8ab9-76eb1a650460	5742bab4-624b-41df-aff7-c3517eed7f4c	پیشرفت اولیه و بررسی نیازمندی‌ها	59	24	2026-07-16	approved	5e03da3d-4fd1-4305-91ec-8a61bd1f28ee	\N	2aa57487-56f0-478e-a094-ca619ea1f237	2026-07-20 11:11:03.957452+00	2026-07-20 11:11:03.957452+00
4dcc3819-424c-4d09-9482-91ed2d9d19ab	39532a48-a60d-45ec-893c-9bd85f10f3b4	8e78a4d9-50d5-40e6-bcd8-fd3f57c31286	رفع اشکالات و بازبینی	146	26	2026-07-16	approved	5e03da3d-4fd1-4305-91ec-8a61bd1f28ee	\N	3296e2c5-53ba-429f-a9da-349a7b9c7926	2026-07-20 11:11:03.957452+00	2026-07-20 11:11:03.957452+00
4dcc3819-424c-4d09-9482-91ed2d9d19ab	39532a48-a60d-45ec-893c-9bd85f10f3b4	8e78a4d9-50d5-40e6-bcd8-fd3f57c31286	رفع اشکالات و بازبینی	151	46	2026-07-16	approved	5e03da3d-4fd1-4305-91ec-8a61bd1f28ee	\N	de9cebb1-4b02-4824-ba08-e7e27e1c317f	2026-07-20 11:11:03.957452+00	2026-07-20 11:11:03.957452+00
4dcc3819-424c-4d09-9482-91ed2d9d19ab	39532a48-a60d-45ec-893c-9bd85f10f3b4	8e78a4d9-50d5-40e6-bcd8-fd3f57c31286	تست و اطمینان از عملکرد صحیح	111	66	2026-07-16	approved	5e03da3d-4fd1-4305-91ec-8a61bd1f28ee	\N	59176f18-3a4e-470e-900d-4bafaba751ea	2026-07-20 11:11:03.957452+00	2026-07-20 11:11:03.957452+00
4dcc3819-424c-4d09-9482-91ed2d9d19ab	45c7f6ce-389e-4404-a127-0926df5c2060	d7465638-ca92-4b34-b9b1-b1ab5012de48	پیشرفت اولیه و بررسی نیازمندی‌ها	35	30	2026-07-16	approved	5e03da3d-4fd1-4305-91ec-8a61bd1f28ee	\N	70b53c4d-dd61-4c9a-9b0a-1fa7f7da042e	2026-07-20 11:11:03.957452+00	2026-07-20 11:11:03.957452+00
4dcc3819-424c-4d09-9482-91ed2d9d19ab	45c7f6ce-389e-4404-a127-0926df5c2060	d7465638-ca92-4b34-b9b1-b1ab5012de48	پیاده‌سازی بخش اصلی	219	54	2026-07-16	approved	5e03da3d-4fd1-4305-91ec-8a61bd1f28ee	\N	05274e52-e1c4-4ae4-b299-9fe38eafd102	2026-07-20 11:11:03.957452+00	2026-07-20 11:11:03.957452+00
4dcc3819-424c-4d09-9482-91ed2d9d19ab	45c7f6ce-389e-4404-a127-0926df5c2060	d7465638-ca92-4b34-b9b1-b1ab5012de48	مستندسازی و نهایی‌سازی	70	90	2026-07-16	approved	5e03da3d-4fd1-4305-91ec-8a61bd1f28ee	\N	b3877343-4c68-4a3e-9680-302ca6dc700d	2026-07-20 11:11:03.957452+00	2026-07-20 11:11:03.957452+00
4dcc3819-424c-4d09-9482-91ed2d9d19ab	b4d0c2a1-e9b1-47d1-82f9-1602732af21f	8e78a4d9-50d5-40e6-bcd8-fd3f57c31286	پیاده‌سازی بخش اصلی	234	32	2026-07-16	approved	5e03da3d-4fd1-4305-91ec-8a61bd1f28ee	\N	ac960be2-4518-4876-8945-837feff0f1e1	2026-07-20 11:11:03.957452+00	2026-07-20 11:11:03.957452+00
4dcc3819-424c-4d09-9482-91ed2d9d19ab	b4d0c2a1-e9b1-47d1-82f9-1602732af21f	8e78a4d9-50d5-40e6-bcd8-fd3f57c31286	پیاده‌سازی بخش اصلی	193	66	2026-07-16	approved	5e03da3d-4fd1-4305-91ec-8a61bd1f28ee	\N	011aa516-dba0-4e30-8003-7125f0d0da38	2026-07-20 11:11:03.957452+00	2026-07-20 11:11:03.957452+00
4dcc3819-424c-4d09-9482-91ed2d9d19ab	b4d0c2a1-e9b1-47d1-82f9-1602732af21f	8e78a4d9-50d5-40e6-bcd8-fd3f57c31286	پیشرفت اولیه و بررسی نیازمندی‌ها	218	100	2026-07-16	approved	5e03da3d-4fd1-4305-91ec-8a61bd1f28ee	\N	7cd96236-8fb8-47eb-8e1c-6d55195bacfd	2026-07-20 11:11:03.957452+00	2026-07-20 11:11:03.957452+00
4dcc3819-424c-4d09-9482-91ed2d9d19ab	b4d0c2a1-e9b1-47d1-82f9-1602732af21f	8e78a4d9-50d5-40e6-bcd8-fd3f57c31286	تست و اطمینان از عملکرد صحیح	181	100	2026-07-16	approved	5e03da3d-4fd1-4305-91ec-8a61bd1f28ee	\N	e8ba3c5a-ff3a-4fcb-be65-207e2b3c1e15	2026-07-20 11:11:03.957452+00	2026-07-20 11:11:03.957452+00
4dcc3819-424c-4d09-9482-91ed2d9d19ab	a24b4602-80e6-4cc5-8cc0-ab9782007316	8e78a4d9-50d5-40e6-bcd8-fd3f57c31286	پیاده‌سازی بخش اصلی	101	22	2026-07-12	submitted	\N	\N	317eeaf2-a116-4e85-a666-a8c82b8aa5b4	2026-07-20 11:11:03.957452+00	2026-07-20 11:11:03.957452+00
4dcc3819-424c-4d09-9482-91ed2d9d19ab	a24b4602-80e6-4cc5-8cc0-ab9782007316	8e78a4d9-50d5-40e6-bcd8-fd3f57c31286	مستندسازی و نهایی‌سازی	77	62	2026-07-13	submitted	\N	\N	be4eb9e7-f10b-4fe9-8c68-56ffa4b76149	2026-07-20 11:11:03.957452+00	2026-07-20 11:11:03.957452+00
4dcc3819-424c-4d09-9482-91ed2d9d19ab	a24b4602-80e6-4cc5-8cc0-ab9782007316	8e78a4d9-50d5-40e6-bcd8-fd3f57c31286	پیشرفت اولیه و بررسی نیازمندی‌ها	97	100	2026-07-16	approved	5e03da3d-4fd1-4305-91ec-8a61bd1f28ee	\N	92a70550-ff02-4af3-b85d-0c940313eeff	2026-07-20 11:11:03.957452+00	2026-07-20 11:11:03.957452+00
4dcc3819-424c-4d09-9482-91ed2d9d19ab	a24b4602-80e6-4cc5-8cc0-ab9782007316	8e78a4d9-50d5-40e6-bcd8-fd3f57c31286	مستندسازی و نهایی‌سازی	130	100	2026-07-16	approved	5e03da3d-4fd1-4305-91ec-8a61bd1f28ee	\N	30c85105-4aa4-4629-b908-ffd1a1e64fae	2026-07-20 11:11:03.957452+00	2026-07-20 11:11:03.957452+00
4dcc3819-424c-4d09-9482-91ed2d9d19ab	4ccf0c27-e251-4528-b213-62cc91f70c44	8e78a4d9-50d5-40e6-bcd8-fd3f57c31286	رفع اشکالات و بازبینی	147	39	2026-06-19	approved	5e03da3d-4fd1-4305-91ec-8a61bd1f28ee	\N	a18ecc12-39c2-4eaa-b6e1-2bfb86a2ff14	2026-07-20 11:11:03.957452+00	2026-07-20 11:11:03.957452+00
4dcc3819-424c-4d09-9482-91ed2d9d19ab	8ecac59b-e856-482c-ab18-aa8dbc6c349f	8e78a4d9-50d5-40e6-bcd8-fd3f57c31286	مستندسازی و نهایی‌سازی	181	22	2026-07-06	approved	5e03da3d-4fd1-4305-91ec-8a61bd1f28ee	\N	3c78581d-52b0-4e30-81fb-4ddcdd2c451e	2026-07-20 11:11:03.957452+00	2026-07-20 11:11:03.957452+00
4dcc3819-424c-4d09-9482-91ed2d9d19ab	8ecac59b-e856-482c-ab18-aa8dbc6c349f	8e78a4d9-50d5-40e6-bcd8-fd3f57c31286	رفع اشکالات و بازبینی	60	54	2026-07-08	approved	5e03da3d-4fd1-4305-91ec-8a61bd1f28ee	\N	b4081d61-89c3-4c10-8196-22d6e6267ab5	2026-07-20 11:11:03.957452+00	2026-07-20 11:11:03.957452+00
4dcc3819-424c-4d09-9482-91ed2d9d19ab	f618a21b-040e-40e4-83d1-bc37cb69d7ff	5742bab4-624b-41df-aff7-c3517eed7f4c	پیاده‌سازی بخش اصلی	125	24	2026-07-16	approved	5e03da3d-4fd1-4305-91ec-8a61bd1f28ee	\N	18681c42-bc5e-497a-856e-2f7156cf8858	2026-07-20 11:11:03.957452+00	2026-07-20 11:11:03.957452+00
4dcc3819-424c-4d09-9482-91ed2d9d19ab	f618a21b-040e-40e4-83d1-bc37cb69d7ff	5742bab4-624b-41df-aff7-c3517eed7f4c	تست و اطمینان از عملکرد صحیح	182	48	2026-07-16	approved	5e03da3d-4fd1-4305-91ec-8a61bd1f28ee	\N	affd2b41-5c7a-4c94-9b52-1986c278f66a	2026-07-20 11:11:03.957452+00	2026-07-20 11:11:03.957452+00
4dcc3819-424c-4d09-9482-91ed2d9d19ab	f618a21b-040e-40e4-83d1-bc37cb69d7ff	5742bab4-624b-41df-aff7-c3517eed7f4c	تست و اطمینان از عملکرد صحیح	77	100	2026-07-16	approved	5e03da3d-4fd1-4305-91ec-8a61bd1f28ee	\N	4a3d8c4f-b448-4ea9-9ba5-291d61cb6d37	2026-07-20 11:11:03.957452+00	2026-07-20 11:11:03.957452+00
4dcc3819-424c-4d09-9482-91ed2d9d19ab	84c1c504-0816-41f8-a2c4-1a9cf4205bd2	24baa76f-b9d0-4a8f-b28d-605d780d066a	پیاده‌سازی بخش اصلی	77	30	2026-07-16	approved	5e03da3d-4fd1-4305-91ec-8a61bd1f28ee	\N	7a13743d-7c36-4801-9bf9-8a808d4f3feb	2026-07-20 11:11:03.957452+00	2026-07-20 11:11:03.957452+00
4dcc3819-424c-4d09-9482-91ed2d9d19ab	84c1c504-0816-41f8-a2c4-1a9cf4205bd2	24baa76f-b9d0-4a8f-b28d-605d780d066a	رفع اشکالات و بازبینی	32	70	2026-07-16	approved	5e03da3d-4fd1-4305-91ec-8a61bd1f28ee	\N	10bd60e5-d170-4067-9978-3486688f639c	2026-07-20 11:11:03.957452+00	2026-07-20 11:11:03.957452+00
4dcc3819-424c-4d09-9482-91ed2d9d19ab	81233d55-4d20-4b83-b997-4c1a2455c079	8e78a4d9-50d5-40e6-bcd8-fd3f57c31286	تست و اطمینان از عملکرد صحیح	173	36	2026-07-16	approved	5e03da3d-4fd1-4305-91ec-8a61bd1f28ee	\N	a3729ec0-84af-44d9-aeba-265d18dfd67a	2026-07-20 11:11:03.957452+00	2026-07-20 11:11:03.957452+00
4dcc3819-424c-4d09-9482-91ed2d9d19ab	81233d55-4d20-4b83-b997-4c1a2455c079	8e78a4d9-50d5-40e6-bcd8-fd3f57c31286	تست و اطمینان از عملکرد صحیح	205	70	2026-07-16	approved	5e03da3d-4fd1-4305-91ec-8a61bd1f28ee	\N	731c6da2-0fa7-40bd-893c-db6fc0211815	2026-07-20 11:11:03.957452+00	2026-07-20 11:11:03.957452+00
4dcc3819-424c-4d09-9482-91ed2d9d19ab	c0ccf45a-9635-47c3-94c9-8132e681d85c	d7465638-ca92-4b34-b9b1-b1ab5012de48	تست و اطمینان از عملکرد صحیح	72	22	2026-07-03	approved	5e03da3d-4fd1-4305-91ec-8a61bd1f28ee	\N	1449a76f-c04b-4654-98e3-bb6be81e7373	2026-07-20 11:11:03.957452+00	2026-07-20 11:11:03.957452+00
4dcc3819-424c-4d09-9482-91ed2d9d19ab	c0ccf45a-9635-47c3-94c9-8132e681d85c	d7465638-ca92-4b34-b9b1-b1ab5012de48	پیاده‌سازی بخش اصلی	104	42	2026-07-04	approved	5e03da3d-4fd1-4305-91ec-8a61bd1f28ee	\N	9d23fd0f-ba4f-4d83-9398-36eb28a18e8b	2026-07-20 11:11:03.957452+00	2026-07-20 11:11:03.957452+00
4dcc3819-424c-4d09-9482-91ed2d9d19ab	c0ccf45a-9635-47c3-94c9-8132e681d85c	d7465638-ca92-4b34-b9b1-b1ab5012de48	پیاده‌سازی بخش اصلی	167	87	2026-07-09	approved	5e03da3d-4fd1-4305-91ec-8a61bd1f28ee	\N	1bac2fbc-bdd1-4691-809d-5c3edf88f558	2026-07-20 11:11:03.957452+00	2026-07-20 11:11:03.957452+00
4dcc3819-424c-4d09-9482-91ed2d9d19ab	c0ccf45a-9635-47c3-94c9-8132e681d85c	d7465638-ca92-4b34-b9b1-b1ab5012de48	تست و اطمینان از عملکرد صحیح	174	100	2026-07-09	approved	5e03da3d-4fd1-4305-91ec-8a61bd1f28ee	\N	f787fc3f-82b7-4320-84e8-ce9cca45c429	2026-07-20 11:11:03.957452+00	2026-07-20 11:11:03.957452+00
4dcc3819-424c-4d09-9482-91ed2d9d19ab	f972eb63-88f5-4e72-82d0-19fb5d7f512d	8d97ee0b-e8f3-4aec-ab48-db76ef6ede39	مستندسازی و نهایی‌سازی	240	31	2026-07-16	approved	5e03da3d-4fd1-4305-91ec-8a61bd1f28ee	\N	df1f8c30-7872-41da-ba20-712753ec0047	2026-07-20 11:11:03.957452+00	2026-07-20 11:11:03.957452+00
4dcc3819-424c-4d09-9482-91ed2d9d19ab	1ccc5bc0-88ad-4f93-8ce6-c2a2add8da09	5e03da3d-4fd1-4305-91ec-8a61bd1f28ee	تست و اطمینان از عملکرد صحیح	56	40	2026-07-16	approved	5e03da3d-4fd1-4305-91ec-8a61bd1f28ee	\N	2d79a309-e5a6-4c0a-9b9a-004d481e36ef	2026-07-20 11:11:03.957452+00	2026-07-20 11:11:03.957452+00
4dcc3819-424c-4d09-9482-91ed2d9d19ab	9b476c5e-1b89-4a88-b459-599ad713f63b	d7465638-ca92-4b34-b9b1-b1ab5012de48	پیشرفت اولیه و بررسی نیازمندی‌ها	145	28	2026-07-16	approved	5e03da3d-4fd1-4305-91ec-8a61bd1f28ee	\N	4f948000-87f6-438c-a1fc-baa7312f5ffa	2026-07-20 11:11:03.957452+00	2026-07-20 11:11:03.957452+00
4dcc3819-424c-4d09-9482-91ed2d9d19ab	9b476c5e-1b89-4a88-b459-599ad713f63b	d7465638-ca92-4b34-b9b1-b1ab5012de48	پیشرفت اولیه و بررسی نیازمندی‌ها	142	46	2026-07-16	approved	5e03da3d-4fd1-4305-91ec-8a61bd1f28ee	\N	d7b91955-3876-4455-aa85-81a5c21fa5e3	2026-07-20 11:11:03.957452+00	2026-07-20 11:11:03.957452+00
4dcc3819-424c-4d09-9482-91ed2d9d19ab	f2a0899b-55f0-4fb0-9830-096260fc2d92	7a6ee833-86b5-4c74-a2b1-845608f4fbab	مستندسازی و نهایی‌سازی	206	31	2026-07-01	submitted	\N	\N	efb40d1c-ecaa-46d4-8597-0552b782ee70	2026-07-20 11:11:03.957452+00	2026-07-20 11:11:03.957452+00
4dcc3819-424c-4d09-9482-91ed2d9d19ab	f2a0899b-55f0-4fb0-9830-096260fc2d92	7a6ee833-86b5-4c74-a2b1-845608f4fbab	پیاده‌سازی بخش اصلی	230	52	2026-07-05	approved	5e03da3d-4fd1-4305-91ec-8a61bd1f28ee	\N	0dbcacbe-87a1-469d-81c0-40f55f3402f7	2026-07-20 11:11:03.957452+00	2026-07-20 11:11:03.957452+00
4dcc3819-424c-4d09-9482-91ed2d9d19ab	f90e2741-210c-40e2-aede-790faaea9b24	24baa76f-b9d0-4a8f-b28d-605d780d066a	مستندسازی و نهایی‌سازی	119	37	2026-07-04	approved	5e03da3d-4fd1-4305-91ec-8a61bd1f28ee	\N	42dc9c79-9759-410b-8b05-b5663b1b1fff	2026-07-20 11:11:03.957452+00	2026-07-20 11:11:03.957452+00
4dcc3819-424c-4d09-9482-91ed2d9d19ab	f90e2741-210c-40e2-aede-790faaea9b24	24baa76f-b9d0-4a8f-b28d-605d780d066a	مستندسازی و نهایی‌سازی	167	50	2026-07-07	approved	5e03da3d-4fd1-4305-91ec-8a61bd1f28ee	\N	d1637aa9-4fea-427a-b552-b57962e70f44	2026-07-20 11:11:03.957452+00	2026-07-20 11:11:03.957452+00
4dcc3819-424c-4d09-9482-91ed2d9d19ab	468d97af-7737-49ac-b733-68b6101746f3	5e03da3d-4fd1-4305-91ec-8a61bd1f28ee	رفع اشکالات و بازبینی	176	28	2026-07-16	approved	5e03da3d-4fd1-4305-91ec-8a61bd1f28ee	\N	c0a147be-620e-485c-9b82-08275c8413a3	2026-07-20 11:11:03.957452+00	2026-07-20 11:11:03.957452+00
4dcc3819-424c-4d09-9482-91ed2d9d19ab	468d97af-7737-49ac-b733-68b6101746f3	5e03da3d-4fd1-4305-91ec-8a61bd1f28ee	پیاده‌سازی بخش اصلی	222	66	2026-07-16	approved	5e03da3d-4fd1-4305-91ec-8a61bd1f28ee	\N	3cf2675f-97ac-4d24-9e4d-c369eb26392a	2026-07-20 11:11:03.957452+00	2026-07-20 11:11:03.957452+00
4dcc3819-424c-4d09-9482-91ed2d9d19ab	468d97af-7737-49ac-b733-68b6101746f3	5e03da3d-4fd1-4305-91ec-8a61bd1f28ee	رفع اشکالات و بازبینی	197	72	2026-07-16	approved	5e03da3d-4fd1-4305-91ec-8a61bd1f28ee	\N	6dbcfcbe-5ddc-4ecf-bd57-4c34934ac8a8	2026-07-20 11:11:03.957452+00	2026-07-20 11:11:03.957452+00
4dcc3819-424c-4d09-9482-91ed2d9d19ab	6b321cbc-33f7-486b-95ca-f7c5305c3565	8e78a4d9-50d5-40e6-bcd8-fd3f57c31286	رفع اشکالات و بازبینی	93	32	2026-07-16	approved	5e03da3d-4fd1-4305-91ec-8a61bd1f28ee	\N	228bb572-9e81-4b40-93ef-b46a975d1e4e	2026-07-20 11:11:03.957452+00	2026-07-20 11:11:03.957452+00
4dcc3819-424c-4d09-9482-91ed2d9d19ab	6b321cbc-33f7-486b-95ca-f7c5305c3565	8e78a4d9-50d5-40e6-bcd8-fd3f57c31286	رفع اشکالات و بازبینی	190	66	2026-07-16	approved	5e03da3d-4fd1-4305-91ec-8a61bd1f28ee	\N	acd8d577-c955-4f66-abae-2b6c8eeb8c9f	2026-07-20 11:11:03.957452+00	2026-07-20 11:11:03.957452+00
4dcc3819-424c-4d09-9482-91ed2d9d19ab	0c3007ea-4bc9-4402-ba37-ccce7ea2efb9	5742bab4-624b-41df-aff7-c3517eed7f4c	پیشرفت اولیه و بررسی نیازمندی‌ها	133	36	2026-07-15	approved	5e03da3d-4fd1-4305-91ec-8a61bd1f28ee	\N	e899d498-ffa2-405b-83e9-f47f3b518e33	2026-07-20 11:11:03.957452+00	2026-07-20 11:11:03.957452+00
4dcc3819-424c-4d09-9482-91ed2d9d19ab	0c3007ea-4bc9-4402-ba37-ccce7ea2efb9	5742bab4-624b-41df-aff7-c3517eed7f4c	رفع اشکالات و بازبینی	146	70	2026-07-16	approved	5e03da3d-4fd1-4305-91ec-8a61bd1f28ee	\N	cf8fae4d-cf96-45c2-96ee-20fb05e6659a	2026-07-20 11:11:03.957452+00	2026-07-20 11:11:03.957452+00
4dcc3819-424c-4d09-9482-91ed2d9d19ab	0c3007ea-4bc9-4402-ba37-ccce7ea2efb9	5742bab4-624b-41df-aff7-c3517eed7f4c	پیشرفت اولیه و بررسی نیازمندی‌ها	217	100	2026-07-16	approved	5e03da3d-4fd1-4305-91ec-8a61bd1f28ee	\N	011a4d85-60bd-47dd-8f56-3a5464de33d3	2026-07-20 11:11:03.957452+00	2026-07-20 11:11:03.957452+00
4dcc3819-424c-4d09-9482-91ed2d9d19ab	0c3007ea-4bc9-4402-ba37-ccce7ea2efb9	5742bab4-624b-41df-aff7-c3517eed7f4c	مستندسازی و نهایی‌سازی	131	100	2026-07-16	submitted	\N	\N	670596d2-e351-4ce1-8244-1a726b1a51e9	2026-07-20 11:11:03.957452+00	2026-07-20 11:11:03.957452+00
4dcc3819-424c-4d09-9482-91ed2d9d19ab	422f7bda-91c9-41a1-be58-28f33faaf382	8d97ee0b-e8f3-4aec-ab48-db76ef6ede39	رفع اشکالات و بازبینی	102	30	2026-06-28	approved	5e03da3d-4fd1-4305-91ec-8a61bd1f28ee	\N	396e7403-fa9f-490b-a2b3-9ff4f4f2d5c3	2026-07-20 11:11:03.957452+00	2026-07-20 11:11:03.957452+00
4dcc3819-424c-4d09-9482-91ed2d9d19ab	422f7bda-91c9-41a1-be58-28f33faaf382	8d97ee0b-e8f3-4aec-ab48-db76ef6ede39	تست و اطمینان از عملکرد صحیح	231	60	2026-06-30	approved	5e03da3d-4fd1-4305-91ec-8a61bd1f28ee	\N	54a00387-87cc-4809-a8f2-13d7a20759a2	2026-07-20 11:11:03.957452+00	2026-07-20 11:11:03.957452+00
4dcc3819-424c-4d09-9482-91ed2d9d19ab	422f7bda-91c9-41a1-be58-28f33faaf382	8d97ee0b-e8f3-4aec-ab48-db76ef6ede39	تست و اطمینان از عملکرد صحیح	34	69	2026-06-30	approved	5e03da3d-4fd1-4305-91ec-8a61bd1f28ee	\N	4bbb7150-88da-462b-a8de-c117f96c4c20	2026-07-20 11:11:03.957452+00	2026-07-20 11:11:03.957452+00
4dcc3819-424c-4d09-9482-91ed2d9d19ab	422f7bda-91c9-41a1-be58-28f33faaf382	8d97ee0b-e8f3-4aec-ab48-db76ef6ede39	پیشرفت اولیه و بررسی نیازمندی‌ها	139	100	2026-07-04	approved	5e03da3d-4fd1-4305-91ec-8a61bd1f28ee	\N	8861a4d8-8bd1-45ae-8478-b66dd0854f26	2026-07-20 11:11:03.957452+00	2026-07-20 11:11:03.957452+00
4dcc3819-424c-4d09-9482-91ed2d9d19ab	1bb9cae8-aa87-4058-9813-d8bd51ac56e2	8d97ee0b-e8f3-4aec-ab48-db76ef6ede39	پیاده‌سازی بخش اصلی	100	22	2026-06-24	approved	5e03da3d-4fd1-4305-91ec-8a61bd1f28ee	\N	6635b97d-77e1-44d0-b5c2-6b8d8711527c	2026-07-20 11:11:03.957452+00	2026-07-20 11:11:03.957452+00
4dcc3819-424c-4d09-9482-91ed2d9d19ab	1bb9cae8-aa87-4058-9813-d8bd51ac56e2	8d97ee0b-e8f3-4aec-ab48-db76ef6ede39	رفع اشکالات و بازبینی	51	62	2026-06-27	approved	5e03da3d-4fd1-4305-91ec-8a61bd1f28ee	\N	20506216-3665-4ebd-8dd7-330b337e06f3	2026-07-20 11:11:03.957452+00	2026-07-20 11:11:03.957452+00
4dcc3819-424c-4d09-9482-91ed2d9d19ab	d8e8bcf6-a2b8-4982-a1ff-77ea63047b8e	8d97ee0b-e8f3-4aec-ab48-db76ef6ede39	رفع اشکالات و بازبینی	215	27	2026-07-14	approved	5e03da3d-4fd1-4305-91ec-8a61bd1f28ee	\N	65131146-3325-49ac-a2af-ba85e76de2c0	2026-07-20 11:11:03.957452+00	2026-07-20 11:11:03.957452+00
4dcc3819-424c-4d09-9482-91ed2d9d19ab	d8e8bcf6-a2b8-4982-a1ff-77ea63047b8e	8d97ee0b-e8f3-4aec-ab48-db76ef6ede39	پیشرفت اولیه و بررسی نیازمندی‌ها	30	52	2026-07-16	approved	5e03da3d-4fd1-4305-91ec-8a61bd1f28ee	\N	1b68f97b-be01-4b07-bf9f-77416c757be4	2026-07-20 11:11:03.957452+00	2026-07-20 11:11:03.957452+00
4dcc3819-424c-4d09-9482-91ed2d9d19ab	1c58fb56-c774-4c00-836b-01035c47935f	5e03da3d-4fd1-4305-91ec-8a61bd1f28ee	پیاده‌سازی بخش اصلی	162	34	2026-07-16	approved	5e03da3d-4fd1-4305-91ec-8a61bd1f28ee	\N	4f2c5205-3671-402d-a462-68a4136cd72f	2026-07-20 11:11:03.957452+00	2026-07-20 11:11:03.957452+00
4dcc3819-424c-4d09-9482-91ed2d9d19ab	1c58fb56-c774-4c00-836b-01035c47935f	5e03da3d-4fd1-4305-91ec-8a61bd1f28ee	رفع اشکالات و بازبینی	239	46	2026-07-16	approved	5e03da3d-4fd1-4305-91ec-8a61bd1f28ee	\N	8b502402-2e1c-426c-98d5-87b1cd2c6050	2026-07-20 11:11:03.957452+00	2026-07-20 11:11:03.957452+00
4dcc3819-424c-4d09-9482-91ed2d9d19ab	1c58fb56-c774-4c00-836b-01035c47935f	5e03da3d-4fd1-4305-91ec-8a61bd1f28ee	تست و اطمینان از عملکرد صحیح	48	81	2026-07-16	approved	5e03da3d-4fd1-4305-91ec-8a61bd1f28ee	\N	1de18ee6-2285-4982-8c82-e8172a95e306	2026-07-20 11:11:03.957452+00	2026-07-20 11:11:03.957452+00
4dcc3819-424c-4d09-9482-91ed2d9d19ab	1c58fb56-c774-4c00-836b-01035c47935f	5e03da3d-4fd1-4305-91ec-8a61bd1f28ee	پیشرفت اولیه و بررسی نیازمندی‌ها	56	100	2026-07-16	approved	5e03da3d-4fd1-4305-91ec-8a61bd1f28ee	\N	46cff348-f903-4d1d-8b75-fa6160bca3b0	2026-07-20 11:11:03.957452+00	2026-07-20 11:11:03.957452+00
4dcc3819-424c-4d09-9482-91ed2d9d19ab	8d035bf7-8a51-4fb8-b1b9-ef9322697682	8d97ee0b-e8f3-4aec-ab48-db76ef6ede39	پیاده‌سازی بخش اصلی	194	24	2026-06-26	approved	5e03da3d-4fd1-4305-91ec-8a61bd1f28ee	\N	1e5a27e5-0a0f-4ede-9a24-6afa1bd1a5b5	2026-07-20 11:11:03.957452+00	2026-07-20 11:11:03.957452+00
4dcc3819-424c-4d09-9482-91ed2d9d19ab	8d035bf7-8a51-4fb8-b1b9-ef9322697682	8d97ee0b-e8f3-4aec-ab48-db76ef6ede39	پیشرفت اولیه و بررسی نیازمندی‌ها	186	80	2026-06-27	approved	5e03da3d-4fd1-4305-91ec-8a61bd1f28ee	\N	9adb38d1-94ea-46f6-b6f2-23fd2085a406	2026-07-20 11:11:03.957452+00	2026-07-20 11:11:03.957452+00
4dcc3819-424c-4d09-9482-91ed2d9d19ab	8d035bf7-8a51-4fb8-b1b9-ef9322697682	8d97ee0b-e8f3-4aec-ab48-db76ef6ede39	پیاده‌سازی بخش اصلی	190	72	2026-06-30	approved	5e03da3d-4fd1-4305-91ec-8a61bd1f28ee	\N	5f5b00d8-60c6-4394-bac8-7218e5520796	2026-07-20 11:11:03.957452+00	2026-07-20 11:11:03.957452+00
4dcc3819-424c-4d09-9482-91ed2d9d19ab	32048e87-dac4-4257-bea7-39a362f61f7e	8e78a4d9-50d5-40e6-bcd8-fd3f57c31286	پیشرفت اولیه و بررسی نیازمندی‌ها	55	24	2026-07-09	submitted	\N	\N	93d58b82-5bd2-462e-95d1-405125d007a0	2026-07-20 11:11:03.957452+00	2026-07-20 11:11:03.957452+00
4dcc3819-424c-4d09-9482-91ed2d9d19ab	32048e87-dac4-4257-bea7-39a362f61f7e	8e78a4d9-50d5-40e6-bcd8-fd3f57c31286	تست و اطمینان از عملکرد صحیح	119	66	2026-07-10	approved	5e03da3d-4fd1-4305-91ec-8a61bd1f28ee	\N	a315560c-9efd-4723-8ac6-66223d6e463c	2026-07-20 11:11:03.957452+00	2026-07-20 11:11:03.957452+00
4dcc3819-424c-4d09-9482-91ed2d9d19ab	32048e87-dac4-4257-bea7-39a362f61f7e	8e78a4d9-50d5-40e6-bcd8-fd3f57c31286	پیاده‌سازی بخش اصلی	100	100	2026-07-15	submitted	\N	\N	80937426-edf3-4e27-bdfd-f352649055e9	2026-07-20 11:11:03.957452+00	2026-07-20 11:11:03.957452+00
4dcc3819-424c-4d09-9482-91ed2d9d19ab	32048e87-dac4-4257-bea7-39a362f61f7e	8e78a4d9-50d5-40e6-bcd8-fd3f57c31286	مستندسازی و نهایی‌سازی	183	100	2026-07-12	approved	5e03da3d-4fd1-4305-91ec-8a61bd1f28ee	\N	1ed3c97a-98ef-49c4-8333-dc19926b3ac7	2026-07-20 11:11:03.957452+00	2026-07-20 11:11:03.957452+00
4dcc3819-424c-4d09-9482-91ed2d9d19ab	bb2a52bc-183a-4634-99a1-47e0dd61da95	8d97ee0b-e8f3-4aec-ab48-db76ef6ede39	رفع اشکالات و بازبینی	82	36	2026-07-16	approved	5e03da3d-4fd1-4305-91ec-8a61bd1f28ee	\N	89bda20b-0fb8-4cbc-b265-8b239efbb42f	2026-07-20 11:11:03.957452+00	2026-07-20 11:11:03.957452+00
4dcc3819-424c-4d09-9482-91ed2d9d19ab	bb2a52bc-183a-4634-99a1-47e0dd61da95	8d97ee0b-e8f3-4aec-ab48-db76ef6ede39	تست و اطمینان از عملکرد صحیح	105	80	2026-07-16	approved	5e03da3d-4fd1-4305-91ec-8a61bd1f28ee	\N	271245bf-ca65-423f-85df-bd4d75ecf7dd	2026-07-20 11:11:03.957452+00	2026-07-20 11:11:03.957452+00
4dcc3819-424c-4d09-9482-91ed2d9d19ab	bb2a52bc-183a-4634-99a1-47e0dd61da95	8d97ee0b-e8f3-4aec-ab48-db76ef6ede39	پیاده‌سازی بخش اصلی	156	96	2026-07-16	approved	5e03da3d-4fd1-4305-91ec-8a61bd1f28ee	\N	bf54f428-90c6-4f24-a011-64ba520733e1	2026-07-20 11:11:03.957452+00	2026-07-20 11:11:03.957452+00
4dcc3819-424c-4d09-9482-91ed2d9d19ab	a8738110-a033-43d8-95b1-99f040fe8749	d7465638-ca92-4b34-b9b1-b1ab5012de48	تست و اطمینان از عملکرد صحیح	193	39	2026-07-16	approved	5e03da3d-4fd1-4305-91ec-8a61bd1f28ee	\N	e08062b4-d8c0-4c8f-8a67-6af3cb1adbcd	2026-07-20 11:11:03.957452+00	2026-07-20 11:11:03.957452+00
4dcc3819-424c-4d09-9482-91ed2d9d19ab	002e1376-5644-42de-aa57-11d60d218c14	8d97ee0b-e8f3-4aec-ab48-db76ef6ede39	رفع اشکالات و بازبینی	111	24	2026-07-16	approved	5e03da3d-4fd1-4305-91ec-8a61bd1f28ee	\N	e9be8f00-dadf-405e-87d9-cc1912236b0f	2026-07-20 11:11:03.957452+00	2026-07-20 11:11:03.957452+00
4dcc3819-424c-4d09-9482-91ed2d9d19ab	da049353-ea9f-4832-9c21-3407450ef12b	8d97ee0b-e8f3-4aec-ab48-db76ef6ede39	پیاده‌سازی بخش اصلی	225	35	2026-07-16	approved	5e03da3d-4fd1-4305-91ec-8a61bd1f28ee	\N	e246c61b-3c49-4b9f-99d3-eac484900e33	2026-07-20 11:11:03.957452+00	2026-07-20 11:11:03.957452+00
4dcc3819-424c-4d09-9482-91ed2d9d19ab	da049353-ea9f-4832-9c21-3407450ef12b	8d97ee0b-e8f3-4aec-ab48-db76ef6ede39	پیشرفت اولیه و بررسی نیازمندی‌ها	33	56	2026-07-16	approved	5e03da3d-4fd1-4305-91ec-8a61bd1f28ee	\N	6541dd7f-110c-4156-89ff-a4a4baa5a5c2	2026-07-20 11:11:03.957452+00	2026-07-20 11:11:03.957452+00
4dcc3819-424c-4d09-9482-91ed2d9d19ab	da049353-ea9f-4832-9c21-3407450ef12b	8d97ee0b-e8f3-4aec-ab48-db76ef6ede39	پیشرفت اولیه و بررسی نیازمندی‌ها	232	96	2026-07-16	approved	5e03da3d-4fd1-4305-91ec-8a61bd1f28ee	\N	79e339ce-17e4-476e-90cb-1a050ad5ed36	2026-07-20 11:11:03.957452+00	2026-07-20 11:11:03.957452+00
4dcc3819-424c-4d09-9482-91ed2d9d19ab	da049353-ea9f-4832-9c21-3407450ef12b	8d97ee0b-e8f3-4aec-ab48-db76ef6ede39	مستندسازی و نهایی‌سازی	226	100	2026-07-16	approved	5e03da3d-4fd1-4305-91ec-8a61bd1f28ee	\N	ee885c55-15d9-45c5-ab81-b23eb75e3bfa	2026-07-20 11:11:03.957452+00	2026-07-20 11:11:03.957452+00
4dcc3819-424c-4d09-9482-91ed2d9d19ab	aac55eb9-cd4f-4d1b-9c14-fa62ba1acb71	8d97ee0b-e8f3-4aec-ab48-db76ef6ede39	مستندسازی و نهایی‌سازی	167	39	2026-07-16	approved	5e03da3d-4fd1-4305-91ec-8a61bd1f28ee	\N	9114093f-7bcc-45f0-8a08-498d311b4f39	2026-07-20 11:11:03.957452+00	2026-07-20 11:11:03.957452+00
4dcc3819-424c-4d09-9482-91ed2d9d19ab	aac55eb9-cd4f-4d1b-9c14-fa62ba1acb71	8d97ee0b-e8f3-4aec-ab48-db76ef6ede39	رفع اشکالات و بازبینی	50	72	2026-07-16	approved	5e03da3d-4fd1-4305-91ec-8a61bd1f28ee	\N	c4c38084-bd14-40f8-afc0-cde9bfac1e0e	2026-07-20 11:11:03.957452+00	2026-07-20 11:11:03.957452+00
4dcc3819-424c-4d09-9482-91ed2d9d19ab	aac55eb9-cd4f-4d1b-9c14-fa62ba1acb71	8d97ee0b-e8f3-4aec-ab48-db76ef6ede39	پیاده‌سازی بخش اصلی	167	90	2026-07-16	submitted	\N	\N	d1567906-a8ef-4e73-913e-f5ca5fb44167	2026-07-20 11:11:03.957452+00	2026-07-20 11:11:03.957452+00
4dcc3819-424c-4d09-9482-91ed2d9d19ab	aac55eb9-cd4f-4d1b-9c14-fa62ba1acb71	8d97ee0b-e8f3-4aec-ab48-db76ef6ede39	پیشرفت اولیه و بررسی نیازمندی‌ها	109	100	2026-07-16	approved	5e03da3d-4fd1-4305-91ec-8a61bd1f28ee	\N	556029bf-646d-4adb-96f6-070b14f182fa	2026-07-20 11:11:03.957452+00	2026-07-20 11:11:03.957452+00
4dcc3819-424c-4d09-9482-91ed2d9d19ab	f35abd35-e113-481d-bcf6-3b360e723041	8d97ee0b-e8f3-4aec-ab48-db76ef6ede39	پیاده‌سازی بخش اصلی	52	33	2026-07-16	approved	5e03da3d-4fd1-4305-91ec-8a61bd1f28ee	\N	33e60c17-b2f5-4c2c-a708-54e1cb500806	2026-07-20 11:11:03.957452+00	2026-07-20 11:11:03.957452+00
4dcc3819-424c-4d09-9482-91ed2d9d19ab	f35abd35-e113-481d-bcf6-3b360e723041	8d97ee0b-e8f3-4aec-ab48-db76ef6ede39	تست و اطمینان از عملکرد صحیح	186	78	2026-07-16	approved	5e03da3d-4fd1-4305-91ec-8a61bd1f28ee	\N	0872623b-c6ac-4a73-95f1-9e1061ce449d	2026-07-20 11:11:03.957452+00	2026-07-20 11:11:03.957452+00
4dcc3819-424c-4d09-9482-91ed2d9d19ab	4e56b431-b4ec-4e0c-8a8a-bf814aee9852	8e78a4d9-50d5-40e6-bcd8-fd3f57c31286	پیاده‌سازی بخش اصلی	60	20	2026-07-16	approved	5e03da3d-4fd1-4305-91ec-8a61bd1f28ee	\N	73799abe-6a8d-406e-ad70-0dc6e4f666c0	2026-07-20 11:11:03.957452+00	2026-07-20 11:11:03.957452+00
4dcc3819-424c-4d09-9482-91ed2d9d19ab	78161dda-0f25-49c1-b5e7-e315cd66d482	8d97ee0b-e8f3-4aec-ab48-db76ef6ede39	پیاده‌سازی بخش اصلی	157	31	2026-06-30	approved	5e03da3d-4fd1-4305-91ec-8a61bd1f28ee	\N	8c5c0456-871b-47d0-8132-0b2053adf429	2026-07-20 11:11:03.957452+00	2026-07-20 11:11:03.957452+00
4dcc3819-424c-4d09-9482-91ed2d9d19ab	78161dda-0f25-49c1-b5e7-e315cd66d482	8d97ee0b-e8f3-4aec-ab48-db76ef6ede39	پیاده‌سازی بخش اصلی	125	48	2026-07-03	approved	5e03da3d-4fd1-4305-91ec-8a61bd1f28ee	\N	68b3d0fe-6f04-42f5-a8c9-817ef4438bdd	2026-07-20 11:11:03.957452+00	2026-07-20 11:11:03.957452+00
4dcc3819-424c-4d09-9482-91ed2d9d19ab	08107ef8-3088-40df-9750-115bea410ddb	8d97ee0b-e8f3-4aec-ab48-db76ef6ede39	پیشرفت اولیه و بررسی نیازمندی‌ها	115	33	2026-07-13	approved	5e03da3d-4fd1-4305-91ec-8a61bd1f28ee	\N	9d279d1b-c211-4ae4-9a04-6f7eecc89560	2026-07-20 11:11:03.957452+00	2026-07-20 11:11:03.957452+00
4dcc3819-424c-4d09-9482-91ed2d9d19ab	08107ef8-3088-40df-9750-115bea410ddb	8d97ee0b-e8f3-4aec-ab48-db76ef6ede39	مستندسازی و نهایی‌سازی	46	56	2026-07-16	approved	5e03da3d-4fd1-4305-91ec-8a61bd1f28ee	\N	26e47d87-8e92-46a9-b759-232c7503ca9b	2026-07-20 11:11:03.957452+00	2026-07-20 11:11:03.957452+00
4dcc3819-424c-4d09-9482-91ed2d9d19ab	08107ef8-3088-40df-9750-115bea410ddb	8d97ee0b-e8f3-4aec-ab48-db76ef6ede39	تست و اطمینان از عملکرد صحیح	146	100	2026-07-15	approved	5e03da3d-4fd1-4305-91ec-8a61bd1f28ee	\N	9f26aeef-9b9f-4fef-9948-1e637e734698	2026-07-20 11:11:03.957452+00	2026-07-20 11:11:03.957452+00
4dcc3819-424c-4d09-9482-91ed2d9d19ab	b5cd86bf-8b06-4a38-966a-89a7536d5485	8e78a4d9-50d5-40e6-bcd8-fd3f57c31286	مستندسازی و نهایی‌سازی	72	31	2026-07-16	approved	5e03da3d-4fd1-4305-91ec-8a61bd1f28ee	\N	a7860e25-6e10-45f8-b7f0-c0beea19d9fa	2026-07-20 11:11:03.957452+00	2026-07-20 11:11:03.957452+00
4dcc3819-424c-4d09-9482-91ed2d9d19ab	b5cd86bf-8b06-4a38-966a-89a7536d5485	8e78a4d9-50d5-40e6-bcd8-fd3f57c31286	پیشرفت اولیه و بررسی نیازمندی‌ها	176	46	2026-07-16	approved	5e03da3d-4fd1-4305-91ec-8a61bd1f28ee	\N	1a9da26b-adf3-4541-9b07-508d49bd7f37	2026-07-20 11:11:03.957452+00	2026-07-20 11:11:03.957452+00
4dcc3819-424c-4d09-9482-91ed2d9d19ab	b5cd86bf-8b06-4a38-966a-89a7536d5485	8e78a4d9-50d5-40e6-bcd8-fd3f57c31286	پیشرفت اولیه و بررسی نیازمندی‌ها	41	60	2026-07-16	submitted	\N	\N	979bda41-c373-44f6-845a-f5d562ee5933	2026-07-20 11:11:03.957452+00	2026-07-20 11:11:03.957452+00
4dcc3819-424c-4d09-9482-91ed2d9d19ab	3e497368-61d8-4838-82ad-d10c4bcd75e8	5e03da3d-4fd1-4305-91ec-8a61bd1f28ee	تست و اطمینان از عملکرد صحیح	123	32	2026-07-16	approved	5e03da3d-4fd1-4305-91ec-8a61bd1f28ee	\N	3c585f67-bb8f-45a7-94cf-f5cb560bb6d1	2026-07-20 11:11:03.957452+00	2026-07-20 11:11:03.957452+00
4dcc3819-424c-4d09-9482-91ed2d9d19ab	3e497368-61d8-4838-82ad-d10c4bcd75e8	5e03da3d-4fd1-4305-91ec-8a61bd1f28ee	پیاده‌سازی بخش اصلی	39	74	2026-07-16	approved	5e03da3d-4fd1-4305-91ec-8a61bd1f28ee	\N	6578cedd-d014-4657-9393-96ad0c68cd02	2026-07-20 11:11:03.957452+00	2026-07-20 11:11:03.957452+00
4dcc3819-424c-4d09-9482-91ed2d9d19ab	0f524f5c-2d75-4e77-927b-907ccb607477	8d97ee0b-e8f3-4aec-ab48-db76ef6ede39	تست و اطمینان از عملکرد صحیح	214	30	2026-07-16	approved	5e03da3d-4fd1-4305-91ec-8a61bd1f28ee	\N	e8689602-7040-491d-ad1a-2a2042f1416e	2026-07-20 11:11:03.957452+00	2026-07-20 11:11:03.957452+00
4dcc3819-424c-4d09-9482-91ed2d9d19ab	0f524f5c-2d75-4e77-927b-907ccb607477	8d97ee0b-e8f3-4aec-ab48-db76ef6ede39	مستندسازی و نهایی‌سازی	125	46	2026-07-16	submitted	\N	\N	b1811fc6-6813-4e0c-b338-298ebb62403a	2026-07-20 11:11:03.957452+00	2026-07-20 11:11:03.957452+00
4dcc3819-424c-4d09-9482-91ed2d9d19ab	0f524f5c-2d75-4e77-927b-907ccb607477	8d97ee0b-e8f3-4aec-ab48-db76ef6ede39	مستندسازی و نهایی‌سازی	41	96	2026-07-16	approved	5e03da3d-4fd1-4305-91ec-8a61bd1f28ee	\N	bb4a21d7-a195-4ea5-a506-34a825c7c382	2026-07-20 11:11:03.957452+00	2026-07-20 11:11:03.957452+00
4dcc3819-424c-4d09-9482-91ed2d9d19ab	0f524f5c-2d75-4e77-927b-907ccb607477	8d97ee0b-e8f3-4aec-ab48-db76ef6ede39	رفع اشکالات و بازبینی	228	100	2026-07-16	submitted	\N	\N	d396638d-6784-4a78-87dd-bcac747a62a2	2026-07-20 11:11:03.957452+00	2026-07-20 11:11:03.957452+00
4dcc3819-424c-4d09-9482-91ed2d9d19ab	47d11ffe-6f2f-4da2-9307-5197b012afa1	5742bab4-624b-41df-aff7-c3517eed7f4c	پیشرفت اولیه و بررسی نیازمندی‌ها	124	26	2026-07-16	approved	5e03da3d-4fd1-4305-91ec-8a61bd1f28ee	\N	33de209a-a974-4422-9f9d-0a830e4d879a	2026-07-20 11:11:03.957452+00	2026-07-20 11:11:03.957452+00
4dcc3819-424c-4d09-9482-91ed2d9d19ab	47d11ffe-6f2f-4da2-9307-5197b012afa1	5742bab4-624b-41df-aff7-c3517eed7f4c	رفع اشکالات و بازبینی	219	78	2026-07-16	approved	5e03da3d-4fd1-4305-91ec-8a61bd1f28ee	\N	6c72a810-2872-47ff-976b-a21f26a8c580	2026-07-20 11:11:03.957452+00	2026-07-20 11:11:03.957452+00
4dcc3819-424c-4d09-9482-91ed2d9d19ab	47d11ffe-6f2f-4da2-9307-5197b012afa1	5742bab4-624b-41df-aff7-c3517eed7f4c	مستندسازی و نهایی‌سازی	156	78	2026-07-16	approved	5e03da3d-4fd1-4305-91ec-8a61bd1f28ee	\N	932ed622-3579-41fe-a62b-ae3caf1172b9	2026-07-20 11:11:03.957452+00	2026-07-20 11:11:03.957452+00
4dcc3819-424c-4d09-9482-91ed2d9d19ab	32089428-166a-4b7d-b5a9-16ced1d56764	d7465638-ca92-4b34-b9b1-b1ab5012de48	تست و اطمینان از عملکرد صحیح	36	27	2026-07-01	approved	5e03da3d-4fd1-4305-91ec-8a61bd1f28ee	\N	1ccc126a-c3d1-4684-85d9-1842c907397d	2026-07-20 11:11:03.957452+00	2026-07-20 11:11:03.957452+00
4dcc3819-424c-4d09-9482-91ed2d9d19ab	32089428-166a-4b7d-b5a9-16ced1d56764	d7465638-ca92-4b34-b9b1-b1ab5012de48	پیشرفت اولیه و بررسی نیازمندی‌ها	115	40	2026-07-04	approved	5e03da3d-4fd1-4305-91ec-8a61bd1f28ee	\N	dce2f61d-53d1-4a23-b861-2891a3a0f33a	2026-07-20 11:11:03.957452+00	2026-07-20 11:11:03.957452+00
4dcc3819-424c-4d09-9482-91ed2d9d19ab	ad0fe2b1-2301-4f13-bb56-b72beb6bb74d	5742bab4-624b-41df-aff7-c3517eed7f4c	مستندسازی و نهایی‌سازی	90	33	2026-06-19	approved	5e03da3d-4fd1-4305-91ec-8a61bd1f28ee	\N	be92d829-e177-4482-9ac4-18f15fedf4f9	2026-07-20 11:11:03.957452+00	2026-07-20 11:11:03.957452+00
4dcc3819-424c-4d09-9482-91ed2d9d19ab	ad0fe2b1-2301-4f13-bb56-b72beb6bb74d	5742bab4-624b-41df-aff7-c3517eed7f4c	پیاده‌سازی بخش اصلی	212	56	2026-06-23	submitted	\N	\N	ade53fb4-53c8-4924-ad98-4c2213b620e3	2026-07-20 11:11:03.957452+00	2026-07-20 11:11:03.957452+00
4dcc3819-424c-4d09-9482-91ed2d9d19ab	ad0fe2b1-2301-4f13-bb56-b72beb6bb74d	5742bab4-624b-41df-aff7-c3517eed7f4c	پیاده‌سازی بخش اصلی	163	99	2026-06-21	approved	5e03da3d-4fd1-4305-91ec-8a61bd1f28ee	\N	922e2b7c-e471-470f-874c-d3cbf6e212d5	2026-07-20 11:11:03.957452+00	2026-07-20 11:11:03.957452+00
4dcc3819-424c-4d09-9482-91ed2d9d19ab	ad0fe2b1-2301-4f13-bb56-b72beb6bb74d	5742bab4-624b-41df-aff7-c3517eed7f4c	پیشرفت اولیه و بررسی نیازمندی‌ها	178	92	2026-06-28	approved	5e03da3d-4fd1-4305-91ec-8a61bd1f28ee	\N	70c05a70-8371-4e17-9603-6e053f418b35	2026-07-20 11:11:03.957452+00	2026-07-20 11:11:03.957452+00
4dcc3819-424c-4d09-9482-91ed2d9d19ab	e1357c02-515d-4114-bf8c-d26b3d415118	8d97ee0b-e8f3-4aec-ab48-db76ef6ede39	پیشرفت اولیه و بررسی نیازمندی‌ها	181	38	2026-07-08	approved	5e03da3d-4fd1-4305-91ec-8a61bd1f28ee	\N	5ba4a12c-444b-4a3a-96a8-51359fba303c	2026-07-20 11:11:03.957452+00	2026-07-20 11:11:03.957452+00
4dcc3819-424c-4d09-9482-91ed2d9d19ab	e1357c02-515d-4114-bf8c-d26b3d415118	8d97ee0b-e8f3-4aec-ab48-db76ef6ede39	تست و اطمینان از عملکرد صحیح	199	48	2026-07-09	approved	5e03da3d-4fd1-4305-91ec-8a61bd1f28ee	\N	f4a70bec-7f58-4aa5-aca5-5ae1354265f6	2026-07-20 11:11:03.957452+00	2026-07-20 11:11:03.957452+00
4dcc3819-424c-4d09-9482-91ed2d9d19ab	edaafe66-d145-4e82-9d93-464ec0a29b16	8d97ee0b-e8f3-4aec-ab48-db76ef6ede39	رفع اشکالات و بازبینی	235	32	2026-06-25	approved	5e03da3d-4fd1-4305-91ec-8a61bd1f28ee	\N	aea73ef1-3bd6-406f-838a-9c3a589b9212	2026-07-20 11:11:03.957452+00	2026-07-20 11:11:03.957452+00
4dcc3819-424c-4d09-9482-91ed2d9d19ab	edaafe66-d145-4e82-9d93-464ec0a29b16	8d97ee0b-e8f3-4aec-ab48-db76ef6ede39	رفع اشکالات و بازبینی	89	44	2026-06-28	approved	5e03da3d-4fd1-4305-91ec-8a61bd1f28ee	\N	87b15a01-e55e-4d6d-ba56-d3adb7b6c57b	2026-07-20 11:11:03.957452+00	2026-07-20 11:11:03.957452+00
4dcc3819-424c-4d09-9482-91ed2d9d19ab	66be4112-872d-4153-ab36-6aaeb7f84b75	d7465638-ca92-4b34-b9b1-b1ab5012de48	مستندسازی و نهایی‌سازی	57	24	2026-07-05	submitted	\N	\N	26d02610-1b50-47b6-be21-36b91b938342	2026-07-20 11:11:03.957452+00	2026-07-20 11:11:03.957452+00
4dcc3819-424c-4d09-9482-91ed2d9d19ab	66be4112-872d-4153-ab36-6aaeb7f84b75	d7465638-ca92-4b34-b9b1-b1ab5012de48	تست و اطمینان از عملکرد صحیح	110	66	2026-07-06	approved	5e03da3d-4fd1-4305-91ec-8a61bd1f28ee	\N	d8a0f793-d8a9-4377-8982-14bf02f0aa04	2026-07-20 11:11:03.957452+00	2026-07-20 11:11:03.957452+00
4dcc3819-424c-4d09-9482-91ed2d9d19ab	cd08d129-70d3-4594-aeca-50691b1df1df	8d97ee0b-e8f3-4aec-ab48-db76ef6ede39	پیاده‌سازی بخش اصلی	145	29	2026-07-10	approved	5e03da3d-4fd1-4305-91ec-8a61bd1f28ee	\N	32ef9a21-540e-419d-9b18-fd1cfad848cc	2026-07-20 11:11:03.957452+00	2026-07-20 11:11:03.957452+00
4dcc3819-424c-4d09-9482-91ed2d9d19ab	a3212536-ffa5-4dd1-a817-b72c5a8e2456	5e03da3d-4fd1-4305-91ec-8a61bd1f28ee	پیشرفت اولیه و بررسی نیازمندی‌ها	53	25	2026-06-21	approved	5e03da3d-4fd1-4305-91ec-8a61bd1f28ee	\N	7bdf3a46-9324-41b0-94b7-87b4685bff1c	2026-07-20 11:11:03.957452+00	2026-07-20 11:11:03.957452+00
4dcc3819-424c-4d09-9482-91ed2d9d19ab	a3212536-ffa5-4dd1-a817-b72c5a8e2456	5e03da3d-4fd1-4305-91ec-8a61bd1f28ee	مستندسازی و نهایی‌سازی	40	52	2026-06-24	approved	5e03da3d-4fd1-4305-91ec-8a61bd1f28ee	\N	f5b2a28a-3bdb-4657-9fe8-b40500d4b835	2026-07-20 11:11:03.957452+00	2026-07-20 11:11:03.957452+00
4dcc3819-424c-4d09-9482-91ed2d9d19ab	a3212536-ffa5-4dd1-a817-b72c5a8e2456	5e03da3d-4fd1-4305-91ec-8a61bd1f28ee	پیاده‌سازی بخش اصلی	53	81	2026-06-27	approved	5e03da3d-4fd1-4305-91ec-8a61bd1f28ee	\N	0500bc05-86fe-4bfe-94b2-4b42af5db047	2026-07-20 11:11:03.957452+00	2026-07-20 11:11:03.957452+00
4dcc3819-424c-4d09-9482-91ed2d9d19ab	a3212536-ffa5-4dd1-a817-b72c5a8e2456	5e03da3d-4fd1-4305-91ec-8a61bd1f28ee	تست و اطمینان از عملکرد صحیح	161	84	2026-06-30	approved	5e03da3d-4fd1-4305-91ec-8a61bd1f28ee	\N	ac9fa241-a63e-437d-8ebe-2ba7b1252068	2026-07-20 11:11:03.957452+00	2026-07-20 11:11:03.957452+00
4dcc3819-424c-4d09-9482-91ed2d9d19ab	a0a80d7a-067f-469d-a990-b1e19b9aa3f0	8d97ee0b-e8f3-4aec-ab48-db76ef6ede39	پیاده‌سازی بخش اصلی	37	32	2026-06-18	approved	5e03da3d-4fd1-4305-91ec-8a61bd1f28ee	\N	dec07ac7-2dcb-4e2b-a14b-ceda3b4c3f04	2026-07-20 11:11:03.957452+00	2026-07-20 11:11:03.957452+00
4dcc3819-424c-4d09-9482-91ed2d9d19ab	a0a80d7a-067f-469d-a990-b1e19b9aa3f0	8d97ee0b-e8f3-4aec-ab48-db76ef6ede39	مستندسازی و نهایی‌سازی	221	74	2026-06-22	approved	5e03da3d-4fd1-4305-91ec-8a61bd1f28ee	\N	bc02e03c-c2e7-454d-b869-55197383d853	2026-07-20 11:11:03.957452+00	2026-07-20 11:11:03.957452+00
4dcc3819-424c-4d09-9482-91ed2d9d19ab	a0a80d7a-067f-469d-a990-b1e19b9aa3f0	8d97ee0b-e8f3-4aec-ab48-db76ef6ede39	پیشرفت اولیه و بررسی نیازمندی‌ها	148	69	2026-06-22	approved	5e03da3d-4fd1-4305-91ec-8a61bd1f28ee	\N	83553b61-5067-4145-a235-1c738c2c2ed5	2026-07-20 11:11:03.957452+00	2026-07-20 11:11:03.957452+00
4dcc3819-424c-4d09-9482-91ed2d9d19ab	66d185ef-851a-44da-b7a7-19376684942f	ac9072e5-ff0f-4d63-880d-330ba7a1645e	پیاده‌سازی بخش اصلی	153	31	2026-07-03	approved	ac9072e5-ff0f-4d63-880d-330ba7a1645e	\N	99043ddc-9912-4434-96ce-832f1465a5be	2026-07-20 11:11:03.957452+00	2026-07-20 11:11:03.957452+00
4dcc3819-424c-4d09-9482-91ed2d9d19ab	bf1de8e4-a319-4cc4-af33-540f6144774a	57aede22-e4a3-452e-8ade-22917514d015	مستندسازی و نهایی‌سازی	186	21	2026-06-26	submitted	\N	\N	07d722be-4e6c-4bb2-b9f6-fe89f382fa70	2026-07-20 11:11:03.957452+00	2026-07-20 11:11:03.957452+00
4dcc3819-424c-4d09-9482-91ed2d9d19ab	bf1de8e4-a319-4cc4-af33-540f6144774a	57aede22-e4a3-452e-8ade-22917514d015	پیاده‌سازی بخش اصلی	159	70	2026-06-27	approved	ac9072e5-ff0f-4d63-880d-330ba7a1645e	\N	177c6499-6990-4ebb-a194-de820bf44f44	2026-07-20 11:11:03.957452+00	2026-07-20 11:11:03.957452+00
4dcc3819-424c-4d09-9482-91ed2d9d19ab	bf1de8e4-a319-4cc4-af33-540f6144774a	57aede22-e4a3-452e-8ade-22917514d015	پیشرفت اولیه و بررسی نیازمندی‌ها	222	100	2026-07-04	submitted	\N	\N	a1ed87b3-c03d-4254-a813-e5ecf8bfdbd9	2026-07-20 11:11:03.957452+00	2026-07-20 11:11:03.957452+00
4dcc3819-424c-4d09-9482-91ed2d9d19ab	bf1de8e4-a319-4cc4-af33-540f6144774a	57aede22-e4a3-452e-8ade-22917514d015	رفع اشکالات و بازبینی	42	100	2026-07-05	approved	ac9072e5-ff0f-4d63-880d-330ba7a1645e	\N	8a54f8e5-3e33-4d50-b0ba-a83acb4b4a06	2026-07-20 11:11:03.957452+00	2026-07-20 11:11:03.957452+00
4dcc3819-424c-4d09-9482-91ed2d9d19ab	5b91116c-e916-40ca-9323-e40a6c06ef94	c159ec20-f52f-44c6-a62b-b5579693a2e2	تست و اطمینان از عملکرد صحیح	239	27	2026-06-19	approved	ac9072e5-ff0f-4d63-880d-330ba7a1645e	\N	b9d1dbe6-3371-4408-91f5-cdcb773d2dd0	2026-07-20 11:11:03.957452+00	2026-07-20 11:11:03.957452+00
4dcc3819-424c-4d09-9482-91ed2d9d19ab	5b91116c-e916-40ca-9323-e40a6c06ef94	c159ec20-f52f-44c6-a62b-b5579693a2e2	تست و اطمینان از عملکرد صحیح	143	76	2026-06-20	approved	ac9072e5-ff0f-4d63-880d-330ba7a1645e	\N	21e1e042-27c6-43c4-85ca-351e757236cd	2026-07-20 11:11:03.957452+00	2026-07-20 11:11:03.957452+00
4dcc3819-424c-4d09-9482-91ed2d9d19ab	1f4fa995-80be-421a-b446-1f21363212a6	ac9072e5-ff0f-4d63-880d-330ba7a1645e	تست و اطمینان از عملکرد صحیح	144	30	2026-07-16	approved	ac9072e5-ff0f-4d63-880d-330ba7a1645e	\N	786123ea-34e3-423b-92fd-239fe4ae4cd7	2026-07-20 11:11:03.957452+00	2026-07-20 11:11:03.957452+00
4dcc3819-424c-4d09-9482-91ed2d9d19ab	1f4fa995-80be-421a-b446-1f21363212a6	ac9072e5-ff0f-4d63-880d-330ba7a1645e	تست و اطمینان از عملکرد صحیح	220	80	2026-07-16	approved	ac9072e5-ff0f-4d63-880d-330ba7a1645e	\N	5a7115de-08fa-4196-add1-d6cff570671f	2026-07-20 11:11:03.957452+00	2026-07-20 11:11:03.957452+00
4dcc3819-424c-4d09-9482-91ed2d9d19ab	1f4fa995-80be-421a-b446-1f21363212a6	ac9072e5-ff0f-4d63-880d-330ba7a1645e	پیشرفت اولیه و بررسی نیازمندی‌ها	133	99	2026-07-16	approved	ac9072e5-ff0f-4d63-880d-330ba7a1645e	\N	7b9452d9-d849-4011-b088-0b6751ca5d03	2026-07-20 11:11:03.957452+00	2026-07-20 11:11:03.957452+00
4dcc3819-424c-4d09-9482-91ed2d9d19ab	1f4fa995-80be-421a-b446-1f21363212a6	ac9072e5-ff0f-4d63-880d-330ba7a1645e	مستندسازی و نهایی‌سازی	170	80	2026-07-16	approved	ac9072e5-ff0f-4d63-880d-330ba7a1645e	\N	08791b20-c215-43ec-ae3b-7ad5d91937a3	2026-07-20 11:11:03.957452+00	2026-07-20 11:11:03.957452+00
4dcc3819-424c-4d09-9482-91ed2d9d19ab	ada5bc47-ada1-4e3c-90b5-f95c4d5f1ebe	fbd6cd8f-ebe9-40af-a413-fa64b9419d5a	مستندسازی و نهایی‌سازی	173	26	2026-06-27	approved	ac9072e5-ff0f-4d63-880d-330ba7a1645e	\N	73d08400-c05d-40ff-b7c1-2dbd5d39d9fe	2026-07-20 11:11:03.957452+00	2026-07-20 11:11:03.957452+00
4dcc3819-424c-4d09-9482-91ed2d9d19ab	bbe8141f-bd61-4095-aa93-b606ec028347	57aede22-e4a3-452e-8ade-22917514d015	پیشرفت اولیه و بررسی نیازمندی‌ها	239	27	2026-06-17	approved	ac9072e5-ff0f-4d63-880d-330ba7a1645e	\N	c0115f8d-a232-4b5a-be26-48621f63f4a7	2026-07-20 11:11:03.957452+00	2026-07-20 11:11:03.957452+00
4dcc3819-424c-4d09-9482-91ed2d9d19ab	bbe8141f-bd61-4095-aa93-b606ec028347	57aede22-e4a3-452e-8ade-22917514d015	مستندسازی و نهایی‌سازی	183	70	2026-06-21	approved	ac9072e5-ff0f-4d63-880d-330ba7a1645e	\N	41394100-056b-47e0-97f3-0e8518ff56d6	2026-07-20 11:11:03.957452+00	2026-07-20 11:11:03.957452+00
4dcc3819-424c-4d09-9482-91ed2d9d19ab	bbe8141f-bd61-4095-aa93-b606ec028347	57aede22-e4a3-452e-8ade-22917514d015	پیشرفت اولیه و بررسی نیازمندی‌ها	54	81	2026-06-23	submitted	\N	\N	09bc15d5-4e81-4e63-b94e-785a994f9d99	2026-07-20 11:11:03.957452+00	2026-07-20 11:11:03.957452+00
4dcc3819-424c-4d09-9482-91ed2d9d19ab	bbe8141f-bd61-4095-aa93-b606ec028347	57aede22-e4a3-452e-8ade-22917514d015	رفع اشکالات و بازبینی	170	100	2026-06-20	approved	ac9072e5-ff0f-4d63-880d-330ba7a1645e	\N	dfdcf3b0-354d-4d4d-b834-5a56522ad506	2026-07-20 11:11:03.957452+00	2026-07-20 11:11:03.957452+00
4dcc3819-424c-4d09-9482-91ed2d9d19ab	758c2dba-201c-490c-8498-c2773e9eb9a7	57aede22-e4a3-452e-8ade-22917514d015	پیشرفت اولیه و بررسی نیازمندی‌ها	72	35	2026-07-16	approved	ac9072e5-ff0f-4d63-880d-330ba7a1645e	\N	2337f275-6eed-43f4-8051-1efac727287f	2026-07-20 11:11:03.957452+00	2026-07-20 11:11:03.957452+00
4dcc3819-424c-4d09-9482-91ed2d9d19ab	758c2dba-201c-490c-8498-c2773e9eb9a7	57aede22-e4a3-452e-8ade-22917514d015	تست و اطمینان از عملکرد صحیح	57	56	2026-07-16	approved	ac9072e5-ff0f-4d63-880d-330ba7a1645e	\N	6861f9b5-feb0-4dc7-90b2-b35c9214a27c	2026-07-20 11:11:03.957452+00	2026-07-20 11:11:03.957452+00
4dcc3819-424c-4d09-9482-91ed2d9d19ab	758c2dba-201c-490c-8498-c2773e9eb9a7	57aede22-e4a3-452e-8ade-22917514d015	پیاده‌سازی بخش اصلی	60	96	2026-07-16	approved	ac9072e5-ff0f-4d63-880d-330ba7a1645e	\N	96f65cf3-48be-4968-b8f4-6f2d9e3c98ef	2026-07-20 11:11:03.957452+00	2026-07-20 11:11:03.957452+00
4dcc3819-424c-4d09-9482-91ed2d9d19ab	9f6418bd-3017-4450-b120-86cffe58920d	ac9072e5-ff0f-4d63-880d-330ba7a1645e	پیاده‌سازی بخش اصلی	213	30	2026-07-16	submitted	\N	\N	3b813e13-a4cb-4a76-8ce3-7c1a458f7a91	2026-07-20 11:11:03.957452+00	2026-07-20 11:11:03.957452+00
4dcc3819-424c-4d09-9482-91ed2d9d19ab	9f6418bd-3017-4450-b120-86cffe58920d	ac9072e5-ff0f-4d63-880d-330ba7a1645e	پیشرفت اولیه و بررسی نیازمندی‌ها	192	76	2026-07-16	submitted	\N	\N	66bc0c17-4d51-42f5-ba76-be0c0888327a	2026-07-20 11:11:03.957452+00	2026-07-20 11:11:03.957452+00
4dcc3819-424c-4d09-9482-91ed2d9d19ab	04080bbf-afa2-4665-b1f6-4ef5532f3854	fbd6cd8f-ebe9-40af-a413-fa64b9419d5a	تست و اطمینان از عملکرد صحیح	198	38	2026-07-16	approved	ac9072e5-ff0f-4d63-880d-330ba7a1645e	\N	4bee45f4-91ae-49be-b749-6147942286bc	2026-07-20 11:11:03.957452+00	2026-07-20 11:11:03.957452+00
4dcc3819-424c-4d09-9482-91ed2d9d19ab	c7ba8056-10fd-48ac-a5d6-aae54c756e52	3a5bbe57-a350-4aac-a8a7-02d037f0c644	پیشرفت اولیه و بررسی نیازمندی‌ها	165	21	2026-07-16	approved	ac9072e5-ff0f-4d63-880d-330ba7a1645e	\N	edcb47f3-ec0a-4370-81cc-136f88170f0b	2026-07-20 11:11:03.957452+00	2026-07-20 11:11:03.957452+00
4dcc3819-424c-4d09-9482-91ed2d9d19ab	c7ba8056-10fd-48ac-a5d6-aae54c756e52	3a5bbe57-a350-4aac-a8a7-02d037f0c644	مستندسازی و نهایی‌سازی	153	72	2026-07-16	approved	ac9072e5-ff0f-4d63-880d-330ba7a1645e	\N	980cae39-9870-4717-8967-5abcdf245d28	2026-07-20 11:11:03.957452+00	2026-07-20 11:11:03.957452+00
4dcc3819-424c-4d09-9482-91ed2d9d19ab	88f14489-e39a-4611-bc6f-a0d4a00bee59	0631f64d-7a8f-4a1f-b13c-6e22248209c5	پیاده‌سازی بخش اصلی	56	32	2026-07-07	approved	ac9072e5-ff0f-4d63-880d-330ba7a1645e	\N	a776b2db-8613-4d15-b484-31c6dcbb8efb	2026-07-20 11:11:03.957452+00	2026-07-20 11:11:03.957452+00
4dcc3819-424c-4d09-9482-91ed2d9d19ab	88f14489-e39a-4611-bc6f-a0d4a00bee59	0631f64d-7a8f-4a1f-b13c-6e22248209c5	مستندسازی و نهایی‌سازی	128	66	2026-07-10	approved	ac9072e5-ff0f-4d63-880d-330ba7a1645e	\N	a0a72dd8-afed-4c13-9c73-fe887be9788b	2026-07-20 11:11:03.957452+00	2026-07-20 11:11:03.957452+00
4dcc3819-424c-4d09-9482-91ed2d9d19ab	a1d02e76-699e-4979-9169-c6df9a537f5a	ea1e6921-d2aa-44c0-978b-ff36b7d9fff2	تست و اطمینان از عملکرد صحیح	117	29	2026-07-12	approved	ac9072e5-ff0f-4d63-880d-330ba7a1645e	\N	bbb3dd4f-74ad-412e-a2c4-5b5c59333d97	2026-07-20 11:11:03.957452+00	2026-07-20 11:11:03.957452+00
4dcc3819-424c-4d09-9482-91ed2d9d19ab	a1d02e76-699e-4979-9169-c6df9a537f5a	ea1e6921-d2aa-44c0-978b-ff36b7d9fff2	پیاده‌سازی بخش اصلی	65	66	2026-07-16	approved	ac9072e5-ff0f-4d63-880d-330ba7a1645e	\N	b8653db0-195e-46f1-a1cb-8431a1a94060	2026-07-20 11:11:03.957452+00	2026-07-20 11:11:03.957452+00
4dcc3819-424c-4d09-9482-91ed2d9d19ab	02fc6d47-21c2-489e-932c-91d7fce51c32	3a5bbe57-a350-4aac-a8a7-02d037f0c644	مستندسازی و نهایی‌سازی	191	26	2026-07-16	approved	ac9072e5-ff0f-4d63-880d-330ba7a1645e	\N	ab8d5661-9169-4145-9fa3-2a88f7bc7686	2026-07-20 11:11:03.957452+00	2026-07-20 11:11:03.957452+00
4dcc3819-424c-4d09-9482-91ed2d9d19ab	02fc6d47-21c2-489e-932c-91d7fce51c32	3a5bbe57-a350-4aac-a8a7-02d037f0c644	پیاده‌سازی بخش اصلی	189	58	2026-07-16	approved	ac9072e5-ff0f-4d63-880d-330ba7a1645e	\N	875d6e4a-4702-4b36-bf7c-53fcfb27fa4d	2026-07-20 11:11:03.957452+00	2026-07-20 11:11:03.957452+00
4dcc3819-424c-4d09-9482-91ed2d9d19ab	02fc6d47-21c2-489e-932c-91d7fce51c32	3a5bbe57-a350-4aac-a8a7-02d037f0c644	پیاده‌سازی بخش اصلی	211	100	2026-07-16	approved	ac9072e5-ff0f-4d63-880d-330ba7a1645e	\N	272d846b-a979-40b3-ba36-510c31ac4cc8	2026-07-20 11:11:03.957452+00	2026-07-20 11:11:03.957452+00
4dcc3819-424c-4d09-9482-91ed2d9d19ab	98ccb7b4-5730-4ad6-8578-245eed7f8e13	0631f64d-7a8f-4a1f-b13c-6e22248209c5	رفع اشکالات و بازبینی	173	35	2026-06-26	submitted	\N	\N	394c6e51-37e2-4672-96de-66a5aa8763e7	2026-07-20 11:11:03.957452+00	2026-07-20 11:11:03.957452+00
4dcc3819-424c-4d09-9482-91ed2d9d19ab	98ccb7b4-5730-4ad6-8578-245eed7f8e13	0631f64d-7a8f-4a1f-b13c-6e22248209c5	مستندسازی و نهایی‌سازی	103	66	2026-06-30	approved	ac9072e5-ff0f-4d63-880d-330ba7a1645e	\N	31d131c5-bc60-40d1-8c8e-266c21be389a	2026-07-20 11:11:03.957452+00	2026-07-20 11:11:03.957452+00
4dcc3819-424c-4d09-9482-91ed2d9d19ab	612ed3ab-0667-4243-8bfa-111545ed4876	fbd6cd8f-ebe9-40af-a413-fa64b9419d5a	پیاده‌سازی بخش اصلی	43	21	2026-07-16	approved	ac9072e5-ff0f-4d63-880d-330ba7a1645e	\N	b7c2cf12-92a4-4e97-b26a-5b3ce61a4e74	2026-07-20 11:11:03.957452+00	2026-07-20 11:11:03.957452+00
4dcc3819-424c-4d09-9482-91ed2d9d19ab	f91d4279-5084-4981-adce-ec6a76b161f5	3a5bbe57-a350-4aac-a8a7-02d037f0c644	پیاده‌سازی بخش اصلی	103	28	2026-07-01	submitted	\N	\N	3ea98529-9972-4894-a31c-0490fc029487	2026-07-20 11:11:03.957452+00	2026-07-20 11:11:03.957452+00
4dcc3819-424c-4d09-9482-91ed2d9d19ab	f91d4279-5084-4981-adce-ec6a76b161f5	3a5bbe57-a350-4aac-a8a7-02d037f0c644	رفع اشکالات و بازبینی	82	74	2026-07-03	submitted	\N	\N	7b5efb02-f688-478d-a7c4-6df8cb832f95	2026-07-20 11:11:03.957452+00	2026-07-20 11:11:03.957452+00
4dcc3819-424c-4d09-9482-91ed2d9d19ab	f2d3e5a7-898d-467a-86fd-c42a811b5361	0631f64d-7a8f-4a1f-b13c-6e22248209c5	تست و اطمینان از عملکرد صحیح	56	39	2026-06-28	approved	ac9072e5-ff0f-4d63-880d-330ba7a1645e	\N	71a6f6b9-ca3c-4906-973f-042eea3b2666	2026-07-20 11:11:03.957452+00	2026-07-20 11:11:03.957452+00
4dcc3819-424c-4d09-9482-91ed2d9d19ab	604e1e64-73d0-47c8-a9e4-8f51455664c4	0631f64d-7a8f-4a1f-b13c-6e22248209c5	رفع اشکالات و بازبینی	207	21	2026-06-21	approved	ac9072e5-ff0f-4d63-880d-330ba7a1645e	\N	62a1424b-07b8-46c2-85c5-858bf87eaa45	2026-07-20 11:11:03.957452+00	2026-07-20 11:11:03.957452+00
4dcc3819-424c-4d09-9482-91ed2d9d19ab	604e1e64-73d0-47c8-a9e4-8f51455664c4	0631f64d-7a8f-4a1f-b13c-6e22248209c5	رفع اشکالات و بازبینی	171	42	2026-06-25	approved	ac9072e5-ff0f-4d63-880d-330ba7a1645e	\N	b60659b6-692d-4e46-80cb-4200aa24910d	2026-07-20 11:11:03.957452+00	2026-07-20 11:11:03.957452+00
4dcc3819-424c-4d09-9482-91ed2d9d19ab	ab9073a5-4bc4-40f9-b809-d128a84a7730	c159ec20-f52f-44c6-a62b-b5579693a2e2	تست و اطمینان از عملکرد صحیح	87	40	2026-07-16	approved	ac9072e5-ff0f-4d63-880d-330ba7a1645e	\N	e342cf4a-a714-40ea-8c24-50dc1d27f342	2026-07-20 11:11:03.957452+00	2026-07-20 11:11:03.957452+00
4dcc3819-424c-4d09-9482-91ed2d9d19ab	e68b9d53-ca29-4398-83fe-dc50cc6fa175	3a5bbe57-a350-4aac-a8a7-02d037f0c644	پیاده‌سازی بخش اصلی	105	34	2026-07-16	approved	ac9072e5-ff0f-4d63-880d-330ba7a1645e	\N	2f8b8ed4-2af1-4bcf-af2a-7407195bb44f	2026-07-20 11:11:03.957452+00	2026-07-20 11:11:03.957452+00
4dcc3819-424c-4d09-9482-91ed2d9d19ab	e68b9d53-ca29-4398-83fe-dc50cc6fa175	3a5bbe57-a350-4aac-a8a7-02d037f0c644	پیشرفت اولیه و بررسی نیازمندی‌ها	77	50	2026-07-16	approved	ac9072e5-ff0f-4d63-880d-330ba7a1645e	\N	af61ae7f-4302-4449-81e5-69f640a6f5a2	2026-07-20 11:11:03.957452+00	2026-07-20 11:11:03.957452+00
4dcc3819-424c-4d09-9482-91ed2d9d19ab	e68b9d53-ca29-4398-83fe-dc50cc6fa175	3a5bbe57-a350-4aac-a8a7-02d037f0c644	تست و اطمینان از عملکرد صحیح	40	99	2026-07-16	approved	ac9072e5-ff0f-4d63-880d-330ba7a1645e	\N	a9270afd-e827-482a-8cd9-b87ba806db4c	2026-07-20 11:11:03.957452+00	2026-07-20 11:11:03.957452+00
4dcc3819-424c-4d09-9482-91ed2d9d19ab	558b6559-0d60-4de4-8180-18fe5cb16b9d	ea1e6921-d2aa-44c0-978b-ff36b7d9fff2	پیاده‌سازی بخش اصلی	71	38	2026-07-16	approved	ac9072e5-ff0f-4d63-880d-330ba7a1645e	\N	090f4c5c-6361-4364-9abb-1084a14aeb82	2026-07-20 11:11:03.957452+00	2026-07-20 11:11:03.957452+00
4dcc3819-424c-4d09-9482-91ed2d9d19ab	558b6559-0d60-4de4-8180-18fe5cb16b9d	ea1e6921-d2aa-44c0-978b-ff36b7d9fff2	پیشرفت اولیه و بررسی نیازمندی‌ها	114	68	2026-07-16	approved	ac9072e5-ff0f-4d63-880d-330ba7a1645e	\N	ff78da3c-0b42-4830-81ee-3cbab91fbb14	2026-07-20 11:11:03.957452+00	2026-07-20 11:11:03.957452+00
4dcc3819-424c-4d09-9482-91ed2d9d19ab	558b6559-0d60-4de4-8180-18fe5cb16b9d	ea1e6921-d2aa-44c0-978b-ff36b7d9fff2	پیشرفت اولیه و بررسی نیازمندی‌ها	69	90	2026-07-16	approved	ac9072e5-ff0f-4d63-880d-330ba7a1645e	\N	5539344b-d90e-42c8-b94b-05e6dd3ce120	2026-07-20 11:11:03.957452+00	2026-07-20 11:11:03.957452+00
4dcc3819-424c-4d09-9482-91ed2d9d19ab	aca7b0f7-213f-4634-b7f4-5286a01ef0ac	ac9072e5-ff0f-4d63-880d-330ba7a1645e	مستندسازی و نهایی‌سازی	170	31	2026-07-16	approved	ac9072e5-ff0f-4d63-880d-330ba7a1645e	\N	090bd4f5-cd61-4f45-a739-e43b2994284e	2026-07-20 11:11:03.957452+00	2026-07-20 11:11:03.957452+00
4dcc3819-424c-4d09-9482-91ed2d9d19ab	9775b733-5ba9-4d65-9a83-a9ba5664b3ad	0631f64d-7a8f-4a1f-b13c-6e22248209c5	مستندسازی و نهایی‌سازی	86	25	2026-07-16	approved	ac9072e5-ff0f-4d63-880d-330ba7a1645e	\N	3bc111ac-92e8-4d49-aade-6c5d7a3bd74c	2026-07-20 11:11:03.957452+00	2026-07-20 11:11:03.957452+00
4dcc3819-424c-4d09-9482-91ed2d9d19ab	3e57c0db-9163-4a73-9dde-2b382784d631	c159ec20-f52f-44c6-a62b-b5579693a2e2	تست و اطمینان از عملکرد صحیح	169	37	2026-07-16	approved	ac9072e5-ff0f-4d63-880d-330ba7a1645e	\N	d1fd70dc-d819-4f26-af69-76a9c19936f5	2026-07-20 11:11:03.957452+00	2026-07-20 11:11:03.957452+00
4dcc3819-424c-4d09-9482-91ed2d9d19ab	d635c179-154f-486d-ab80-ed8844a9f8ab	57aede22-e4a3-452e-8ade-22917514d015	رفع اشکالات و بازبینی	86	26	2026-06-16	approved	ac9072e5-ff0f-4d63-880d-330ba7a1645e	\N	dbeeaa07-d0cf-43e0-8f51-142e1fa77583	2026-07-20 11:11:03.957452+00	2026-07-20 11:11:03.957452+00
4dcc3819-424c-4d09-9482-91ed2d9d19ab	d635c179-154f-486d-ab80-ed8844a9f8ab	57aede22-e4a3-452e-8ade-22917514d015	رفع اشکالات و بازبینی	122	58	2026-06-19	approved	ac9072e5-ff0f-4d63-880d-330ba7a1645e	\N	f2c0bbcc-6e3f-4750-8127-c9cd0d7fe8f3	2026-07-20 11:11:03.957452+00	2026-07-20 11:11:03.957452+00
4dcc3819-424c-4d09-9482-91ed2d9d19ab	d635c179-154f-486d-ab80-ed8844a9f8ab	57aede22-e4a3-452e-8ade-22917514d015	مستندسازی و نهایی‌سازی	165	100	2026-06-20	approved	ac9072e5-ff0f-4d63-880d-330ba7a1645e	\N	47ec08d3-30b8-4be1-8bdd-81f6ea0dac68	2026-07-20 11:11:03.957452+00	2026-07-20 11:11:03.957452+00
4dcc3819-424c-4d09-9482-91ed2d9d19ab	d635c179-154f-486d-ab80-ed8844a9f8ab	57aede22-e4a3-452e-8ade-22917514d015	پیشرفت اولیه و بررسی نیازمندی‌ها	201	100	2026-06-19	approved	ac9072e5-ff0f-4d63-880d-330ba7a1645e	\N	600b32ef-fefd-463f-bbdd-796ead726ae0	2026-07-20 11:11:03.957452+00	2026-07-20 11:11:03.957452+00
4dcc3819-424c-4d09-9482-91ed2d9d19ab	c3b77227-5c45-410b-a673-5b2635992d41	ac9072e5-ff0f-4d63-880d-330ba7a1645e	مستندسازی و نهایی‌سازی	189	27	2026-06-25	submitted	\N	\N	06904a61-5137-4904-b83e-d31b8d787ce1	2026-07-20 11:11:03.957452+00	2026-07-20 11:11:03.957452+00
4dcc3819-424c-4d09-9482-91ed2d9d19ab	c3b77227-5c45-410b-a673-5b2635992d41	ac9072e5-ff0f-4d63-880d-330ba7a1645e	رفع اشکالات و بازبینی	127	46	2026-06-26	approved	ac9072e5-ff0f-4d63-880d-330ba7a1645e	\N	26bcbe4f-a37f-4297-b4ab-56829603ded6	2026-07-20 11:11:03.957452+00	2026-07-20 11:11:03.957452+00
4dcc3819-424c-4d09-9482-91ed2d9d19ab	c3b77227-5c45-410b-a673-5b2635992d41	ac9072e5-ff0f-4d63-880d-330ba7a1645e	رفع اشکالات و بازبینی	36	100	2026-07-03	approved	ac9072e5-ff0f-4d63-880d-330ba7a1645e	\N	270f2b18-2e22-462d-893f-0ee04b6ae3fd	2026-07-20 11:11:03.957452+00	2026-07-20 11:11:03.957452+00
4dcc3819-424c-4d09-9482-91ed2d9d19ab	c3b77227-5c45-410b-a673-5b2635992d41	ac9072e5-ff0f-4d63-880d-330ba7a1645e	مستندسازی و نهایی‌سازی	144	100	2026-07-04	approved	ac9072e5-ff0f-4d63-880d-330ba7a1645e	\N	06f3c80e-54b1-462d-994e-1f71bbed666e	2026-07-20 11:11:03.957452+00	2026-07-20 11:11:03.957452+00
4dcc3819-424c-4d09-9482-91ed2d9d19ab	c65d64f4-c318-48f1-9cbe-d7df69aafd50	ea1e6921-d2aa-44c0-978b-ff36b7d9fff2	پیاده‌سازی بخش اصلی	112	36	2026-07-10	submitted	\N	\N	8d1b0a69-c6fa-4aa6-8876-c8a62b5075d0	2026-07-20 11:11:03.957452+00	2026-07-20 11:11:03.957452+00
4dcc3819-424c-4d09-9482-91ed2d9d19ab	9af6a4c8-cff7-4ae5-982a-d0a84e4b4fd0	3a5bbe57-a350-4aac-a8a7-02d037f0c644	مستندسازی و نهایی‌سازی	166	20	2026-06-25	approved	ac9072e5-ff0f-4d63-880d-330ba7a1645e	\N	952dab11-58ba-4bdc-a46f-01783a16de14	2026-07-20 11:11:03.957452+00	2026-07-20 11:11:03.957452+00
4dcc3819-424c-4d09-9482-91ed2d9d19ab	852e6f39-de5f-460f-a9c4-fdc825b216ce	3a5bbe57-a350-4aac-a8a7-02d037f0c644	پیاده‌سازی بخش اصلی	205	33	2026-07-16	approved	ac9072e5-ff0f-4d63-880d-330ba7a1645e	\N	1bc96d9a-156a-4ca2-9af5-d3038cec6378	2026-07-20 11:11:03.957452+00	2026-07-20 11:11:03.957452+00
4dcc3819-424c-4d09-9482-91ed2d9d19ab	18d8e9bb-96f1-4aa7-b07f-2dbccfdcd384	ac9072e5-ff0f-4d63-880d-330ba7a1645e	تست و اطمینان از عملکرد صحیح	195	22	2026-07-16	approved	ac9072e5-ff0f-4d63-880d-330ba7a1645e	\N	9740453a-88ee-4f51-a870-62b2865cef0d	2026-07-20 11:11:03.957452+00	2026-07-20 11:11:03.957452+00
4dcc3819-424c-4d09-9482-91ed2d9d19ab	9b840f37-8825-4e84-9e11-1c08d0d51ee9	3a5bbe57-a350-4aac-a8a7-02d037f0c644	رفع اشکالات و بازبینی	39	22	2026-07-16	approved	ac9072e5-ff0f-4d63-880d-330ba7a1645e	\N	d90e4cfb-f04d-4410-9b05-1b6925e05e5c	2026-07-20 11:11:03.957452+00	2026-07-20 11:11:03.957452+00
4dcc3819-424c-4d09-9482-91ed2d9d19ab	9b840f37-8825-4e84-9e11-1c08d0d51ee9	3a5bbe57-a350-4aac-a8a7-02d037f0c644	رفع اشکالات و بازبینی	172	44	2026-07-16	approved	ac9072e5-ff0f-4d63-880d-330ba7a1645e	\N	620f9fa7-3227-498c-a44b-d77e4e2ca745	2026-07-20 11:11:03.957452+00	2026-07-20 11:11:03.957452+00
4dcc3819-424c-4d09-9482-91ed2d9d19ab	99bb9ae6-ac6a-4e70-9dd0-a32e04caa315	fbd6cd8f-ebe9-40af-a413-fa64b9419d5a	تست و اطمینان از عملکرد صحیح	191	32	2026-07-16	approved	ac9072e5-ff0f-4d63-880d-330ba7a1645e	\N	3ead0b7a-ed0f-45fc-809a-e526f9bb7acc	2026-07-20 11:11:03.957452+00	2026-07-20 11:11:03.957452+00
4dcc3819-424c-4d09-9482-91ed2d9d19ab	99bb9ae6-ac6a-4e70-9dd0-a32e04caa315	fbd6cd8f-ebe9-40af-a413-fa64b9419d5a	تست و اطمینان از عملکرد صحیح	202	46	2026-07-16	approved	ac9072e5-ff0f-4d63-880d-330ba7a1645e	\N	0bda4c9c-c290-41df-8cb2-ab53ab973c48	2026-07-20 11:11:03.957452+00	2026-07-20 11:11:03.957452+00
4dcc3819-424c-4d09-9482-91ed2d9d19ab	840e8321-8226-4743-bb2b-cf1b89ca7d26	c159ec20-f52f-44c6-a62b-b5579693a2e2	مستندسازی و نهایی‌سازی	41	22	2026-06-17	approved	ac9072e5-ff0f-4d63-880d-330ba7a1645e	\N	5427829b-f15d-4471-a19a-89b511350dd4	2026-07-20 11:11:03.957452+00	2026-07-20 11:11:03.957452+00
4dcc3819-424c-4d09-9482-91ed2d9d19ab	d43c535d-a946-476d-ab11-ddc95ae1840d	c159ec20-f52f-44c6-a62b-b5579693a2e2	رفع اشکالات و بازبینی	231	29	2026-07-16	approved	ac9072e5-ff0f-4d63-880d-330ba7a1645e	\N	fac6d4aa-83b7-433a-ac17-11ce68935a12	2026-07-20 11:11:03.957452+00	2026-07-20 11:11:03.957452+00
4dcc3819-424c-4d09-9482-91ed2d9d19ab	d43c535d-a946-476d-ab11-ddc95ae1840d	c159ec20-f52f-44c6-a62b-b5579693a2e2	رفع اشکالات و بازبینی	225	68	2026-07-16	approved	ac9072e5-ff0f-4d63-880d-330ba7a1645e	\N	a26cee81-8cf2-47d3-9bdc-5d54f1de6c83	2026-07-20 11:11:03.957452+00	2026-07-20 11:11:03.957452+00
4dcc3819-424c-4d09-9482-91ed2d9d19ab	d43c535d-a946-476d-ab11-ddc95ae1840d	c159ec20-f52f-44c6-a62b-b5579693a2e2	تست و اطمینان از عملکرد صحیح	240	60	2026-07-16	approved	ac9072e5-ff0f-4d63-880d-330ba7a1645e	\N	d950c67a-dc7f-4a59-9e85-cd1f1d6ae1af	2026-07-20 11:11:03.957452+00	2026-07-20 11:11:03.957452+00
4dcc3819-424c-4d09-9482-91ed2d9d19ab	f34068c7-ce0a-43a5-be82-7e5a79480fcd	ea1e6921-d2aa-44c0-978b-ff36b7d9fff2	مستندسازی و نهایی‌سازی	86	24	2026-07-16	approved	ac9072e5-ff0f-4d63-880d-330ba7a1645e	\N	9fe0bf6a-0531-45d6-85fe-fade0aca1821	2026-07-20 11:11:03.957452+00	2026-07-20 11:11:03.957452+00
4dcc3819-424c-4d09-9482-91ed2d9d19ab	f34068c7-ce0a-43a5-be82-7e5a79480fcd	ea1e6921-d2aa-44c0-978b-ff36b7d9fff2	مستندسازی و نهایی‌سازی	105	80	2026-07-16	approved	ac9072e5-ff0f-4d63-880d-330ba7a1645e	\N	3450cff3-3272-4e58-91a2-d8d67a137db5	2026-07-20 11:11:03.957452+00	2026-07-20 11:11:03.957452+00
4dcc3819-424c-4d09-9482-91ed2d9d19ab	f34068c7-ce0a-43a5-be82-7e5a79480fcd	ea1e6921-d2aa-44c0-978b-ff36b7d9fff2	رفع اشکالات و بازبینی	203	100	2026-07-16	approved	ac9072e5-ff0f-4d63-880d-330ba7a1645e	\N	04acc4d5-668f-4dbe-bff0-b6ccca0172cf	2026-07-20 11:11:03.957452+00	2026-07-20 11:11:03.957452+00
4dcc3819-424c-4d09-9482-91ed2d9d19ab	f34068c7-ce0a-43a5-be82-7e5a79480fcd	ea1e6921-d2aa-44c0-978b-ff36b7d9fff2	پیشرفت اولیه و بررسی نیازمندی‌ها	171	100	2026-07-16	approved	ac9072e5-ff0f-4d63-880d-330ba7a1645e	\N	36d2c2b7-8767-4367-89a7-65b2cd6240a8	2026-07-20 11:11:03.957452+00	2026-07-20 11:11:03.957452+00
4dcc3819-424c-4d09-9482-91ed2d9d19ab	d76b1069-1aec-4c5e-ba32-a5569d21a951	fbd6cd8f-ebe9-40af-a413-fa64b9419d5a	مستندسازی و نهایی‌سازی	182	32	2026-07-16	approved	ac9072e5-ff0f-4d63-880d-330ba7a1645e	\N	a513370b-3fd3-4a79-a2ec-28ccb44e9110	2026-07-20 11:11:03.957452+00	2026-07-20 11:11:03.957452+00
4dcc3819-424c-4d09-9482-91ed2d9d19ab	d76b1069-1aec-4c5e-ba32-a5569d21a951	fbd6cd8f-ebe9-40af-a413-fa64b9419d5a	رفع اشکالات و بازبینی	84	66	2026-07-16	approved	ac9072e5-ff0f-4d63-880d-330ba7a1645e	\N	6fce0bb9-9311-4c7f-ae8d-b771e5c8c90b	2026-07-20 11:11:03.957452+00	2026-07-20 11:11:03.957452+00
4dcc3819-424c-4d09-9482-91ed2d9d19ab	8857ea02-d6c2-4b60-bbb9-ed2e21f8edb4	c159ec20-f52f-44c6-a62b-b5579693a2e2	پیاده‌سازی بخش اصلی	86	39	2026-06-29	approved	ac9072e5-ff0f-4d63-880d-330ba7a1645e	\N	60ce3ebe-77ab-4581-9d21-6ff9570b2097	2026-07-20 11:11:03.957452+00	2026-07-20 11:11:03.957452+00
4dcc3819-424c-4d09-9482-91ed2d9d19ab	8857ea02-d6c2-4b60-bbb9-ed2e21f8edb4	c159ec20-f52f-44c6-a62b-b5579693a2e2	پیاده‌سازی بخش اصلی	59	50	2026-07-02	approved	ac9072e5-ff0f-4d63-880d-330ba7a1645e	\N	cdbc42de-3d5f-42ad-930c-48007a1247eb	2026-07-20 11:11:03.957452+00	2026-07-20 11:11:03.957452+00
4dcc3819-424c-4d09-9482-91ed2d9d19ab	bf65a4ae-6724-49ad-bc25-24a4d4ced8b2	3a5bbe57-a350-4aac-a8a7-02d037f0c644	مستندسازی و نهایی‌سازی	48	29	2026-06-17	approved	ac9072e5-ff0f-4d63-880d-330ba7a1645e	\N	9b3b4785-884b-4854-ac99-4eac4cd1d34e	2026-07-20 11:11:03.957452+00	2026-07-20 11:11:03.957452+00
4dcc3819-424c-4d09-9482-91ed2d9d19ab	f2f01099-76c0-481b-9cd2-0a26a448b0b8	ea1e6921-d2aa-44c0-978b-ff36b7d9fff2	مستندسازی و نهایی‌سازی	154	30	2026-07-15	approved	ac9072e5-ff0f-4d63-880d-330ba7a1645e	\N	93144691-851d-4c9b-a3b1-6a98b11c4565	2026-07-20 11:11:03.957452+00	2026-07-20 11:11:03.957452+00
4dcc3819-424c-4d09-9482-91ed2d9d19ab	8829350e-47b9-4a12-b7cb-0a567cf6edbe	c159ec20-f52f-44c6-a62b-b5579693a2e2	پیاده‌سازی بخش اصلی	55	29	2026-06-22	approved	ac9072e5-ff0f-4d63-880d-330ba7a1645e	\N	359dc1c9-0944-4c62-b958-d423b47f3a8e	2026-07-20 11:11:03.957452+00	2026-07-20 11:11:03.957452+00
4dcc3819-424c-4d09-9482-91ed2d9d19ab	8829350e-47b9-4a12-b7cb-0a567cf6edbe	c159ec20-f52f-44c6-a62b-b5579693a2e2	پیاده‌سازی بخش اصلی	111	70	2026-06-23	approved	ac9072e5-ff0f-4d63-880d-330ba7a1645e	\N	56c7c40a-8e4e-4991-b6b3-777c6f2b5989	2026-07-20 11:11:03.957452+00	2026-07-20 11:11:03.957452+00
4dcc3819-424c-4d09-9482-91ed2d9d19ab	8829350e-47b9-4a12-b7cb-0a567cf6edbe	c159ec20-f52f-44c6-a62b-b5579693a2e2	رفع اشکالات و بازبینی	187	87	2026-06-30	approved	ac9072e5-ff0f-4d63-880d-330ba7a1645e	\N	b913075c-3ce4-45ab-ae77-d840f7affa51	2026-07-20 11:11:03.957452+00	2026-07-20 11:11:03.957452+00
4dcc3819-424c-4d09-9482-91ed2d9d19ab	994f4477-7960-42fa-b5c2-363f4f51e217	c159ec20-f52f-44c6-a62b-b5579693a2e2	تست و اطمینان از عملکرد صحیح	73	20	2026-07-16	submitted	\N	\N	031c53da-458b-443e-b160-ff3f5f2759de	2026-07-20 11:11:03.957452+00	2026-07-20 11:11:03.957452+00
4dcc3819-424c-4d09-9482-91ed2d9d19ab	994f4477-7960-42fa-b5c2-363f4f51e217	c159ec20-f52f-44c6-a62b-b5579693a2e2	پیاده‌سازی بخش اصلی	212	80	2026-07-16	approved	ac9072e5-ff0f-4d63-880d-330ba7a1645e	\N	20a2b645-8400-4a31-95f3-b5b64d0af40e	2026-07-20 11:11:03.957452+00	2026-07-20 11:11:03.957452+00
4dcc3819-424c-4d09-9482-91ed2d9d19ab	d75153f8-36c0-41d6-80cb-e3d0f40173a2	0631f64d-7a8f-4a1f-b13c-6e22248209c5	رفع اشکالات و بازبینی	64	30	2026-06-25	approved	ac9072e5-ff0f-4d63-880d-330ba7a1645e	\N	ccaee45e-0881-4632-b7d8-69a398277b0b	2026-07-20 11:11:03.957452+00	2026-07-20 11:11:03.957452+00
4dcc3819-424c-4d09-9482-91ed2d9d19ab	d75153f8-36c0-41d6-80cb-e3d0f40173a2	0631f64d-7a8f-4a1f-b13c-6e22248209c5	تست و اطمینان از عملکرد صحیح	144	62	2026-06-29	approved	ac9072e5-ff0f-4d63-880d-330ba7a1645e	\N	c3bd4709-2d8a-4eb9-ad89-1e3e52bd3207	2026-07-20 11:11:03.957452+00	2026-07-20 11:11:03.957452+00
4dcc3819-424c-4d09-9482-91ed2d9d19ab	d75153f8-36c0-41d6-80cb-e3d0f40173a2	0631f64d-7a8f-4a1f-b13c-6e22248209c5	تست و اطمینان از عملکرد صحیح	171	69	2026-07-01	approved	ac9072e5-ff0f-4d63-880d-330ba7a1645e	\N	b0e7b881-8458-4fb8-8860-66658abf5e2e	2026-07-20 11:11:03.957452+00	2026-07-20 11:11:03.957452+00
4dcc3819-424c-4d09-9482-91ed2d9d19ab	d75153f8-36c0-41d6-80cb-e3d0f40173a2	0631f64d-7a8f-4a1f-b13c-6e22248209c5	مستندسازی و نهایی‌سازی	50	100	2026-07-01	approved	ac9072e5-ff0f-4d63-880d-330ba7a1645e	\N	2ef85881-6676-4174-8d44-cf1fce0be50a	2026-07-20 11:11:03.957452+00	2026-07-20 11:11:03.957452+00
4dcc3819-424c-4d09-9482-91ed2d9d19ab	ba50d725-d9cc-4488-a7cd-01276e08b1af	c159ec20-f52f-44c6-a62b-b5579693a2e2	رفع اشکالات و بازبینی	217	40	2026-07-06	approved	ac9072e5-ff0f-4d63-880d-330ba7a1645e	\N	0513da6d-02aa-4385-b027-1c8265f6cffa	2026-07-20 11:11:03.957452+00	2026-07-20 11:11:03.957452+00
4dcc3819-424c-4d09-9482-91ed2d9d19ab	ba50d725-d9cc-4488-a7cd-01276e08b1af	c159ec20-f52f-44c6-a62b-b5579693a2e2	پیشرفت اولیه و بررسی نیازمندی‌ها	34	72	2026-07-07	approved	ac9072e5-ff0f-4d63-880d-330ba7a1645e	\N	1d019d0e-f350-47d6-88b5-37741af79a5e	2026-07-20 11:11:03.957452+00	2026-07-20 11:11:03.957452+00
4dcc3819-424c-4d09-9482-91ed2d9d19ab	54a1e824-9a2a-4b96-a866-82e4b4a3b4b3	3a5bbe57-a350-4aac-a8a7-02d037f0c644	پیاده‌سازی بخش اصلی	39	37	2026-07-16	submitted	\N	\N	cb052895-93a2-4c69-81b5-e8f08d6465e7	2026-07-20 11:11:03.957452+00	2026-07-20 11:11:03.957452+00
4dcc3819-424c-4d09-9482-91ed2d9d19ab	2c401f6e-dfcb-4003-aac4-678cbc110498	0631f64d-7a8f-4a1f-b13c-6e22248209c5	پیاده‌سازی بخش اصلی	123	32	2026-07-16	approved	ac9072e5-ff0f-4d63-880d-330ba7a1645e	\N	c923f770-22d9-40f9-9c17-3edaefc0f46e	2026-07-20 11:11:03.957452+00	2026-07-20 11:11:03.957452+00
4dcc3819-424c-4d09-9482-91ed2d9d19ab	2c401f6e-dfcb-4003-aac4-678cbc110498	0631f64d-7a8f-4a1f-b13c-6e22248209c5	مستندسازی و نهایی‌سازی	217	58	2026-07-16	submitted	\N	\N	a3f7c32e-b3b3-4329-9046-95dd26261d52	2026-07-20 11:11:03.957452+00	2026-07-20 11:11:03.957452+00
4dcc3819-424c-4d09-9482-91ed2d9d19ab	2c401f6e-dfcb-4003-aac4-678cbc110498	0631f64d-7a8f-4a1f-b13c-6e22248209c5	مستندسازی و نهایی‌سازی	53	96	2026-07-16	approved	ac9072e5-ff0f-4d63-880d-330ba7a1645e	\N	46db6485-851b-45a7-b393-d4ce12736e0a	2026-07-20 11:11:03.957452+00	2026-07-20 11:11:03.957452+00
4dcc3819-424c-4d09-9482-91ed2d9d19ab	5582939c-a8c6-4202-9495-bb3cc76314a6	ac9072e5-ff0f-4d63-880d-330ba7a1645e	پیاده‌سازی بخش اصلی	236	39	2026-07-02	approved	ac9072e5-ff0f-4d63-880d-330ba7a1645e	\N	f6b90bb2-e1d5-43f9-9f19-a8ee7b13da5b	2026-07-20 11:11:03.957452+00	2026-07-20 11:11:03.957452+00
4dcc3819-424c-4d09-9482-91ed2d9d19ab	5582939c-a8c6-4202-9495-bb3cc76314a6	ac9072e5-ff0f-4d63-880d-330ba7a1645e	مستندسازی و نهایی‌سازی	65	68	2026-07-04	approved	ac9072e5-ff0f-4d63-880d-330ba7a1645e	\N	8bfc0ed0-ff4d-471a-80b1-aff7ce398e10	2026-07-20 11:11:03.957452+00	2026-07-20 11:11:03.957452+00
4dcc3819-424c-4d09-9482-91ed2d9d19ab	5582939c-a8c6-4202-9495-bb3cc76314a6	ac9072e5-ff0f-4d63-880d-330ba7a1645e	پیاده‌سازی بخش اصلی	174	100	2026-07-06	approved	ac9072e5-ff0f-4d63-880d-330ba7a1645e	\N	8b260c65-2de6-4bf1-83cb-76f8ff597a6f	2026-07-20 11:11:03.957452+00	2026-07-20 11:11:03.957452+00
4dcc3819-424c-4d09-9482-91ed2d9d19ab	82172cb4-11e3-462b-b07d-0dda985427a3	3a5bbe57-a350-4aac-a8a7-02d037f0c644	رفع اشکالات و بازبینی	40	27	2026-07-08	approved	ac9072e5-ff0f-4d63-880d-330ba7a1645e	\N	f2118e37-a38b-4022-b55a-f06625c4a0f6	2026-07-20 11:11:03.957452+00	2026-07-20 11:11:03.957452+00
4dcc3819-424c-4d09-9482-91ed2d9d19ab	82172cb4-11e3-462b-b07d-0dda985427a3	3a5bbe57-a350-4aac-a8a7-02d037f0c644	پیاده‌سازی بخش اصلی	46	56	2026-07-12	approved	ac9072e5-ff0f-4d63-880d-330ba7a1645e	\N	74f2ed36-5383-4b89-955b-fab01546cb55	2026-07-20 11:11:03.957452+00	2026-07-20 11:11:03.957452+00
4dcc3819-424c-4d09-9482-91ed2d9d19ab	96f673fc-9332-48ac-b2e9-9a50d8a40f8b	3a5bbe57-a350-4aac-a8a7-02d037f0c644	پیاده‌سازی بخش اصلی	162	31	2026-07-02	approved	ac9072e5-ff0f-4d63-880d-330ba7a1645e	\N	16c14fae-5941-43e3-815c-872eedc6475d	2026-07-20 11:11:03.957452+00	2026-07-20 11:11:03.957452+00
4dcc3819-424c-4d09-9482-91ed2d9d19ab	96f673fc-9332-48ac-b2e9-9a50d8a40f8b	3a5bbe57-a350-4aac-a8a7-02d037f0c644	تست و اطمینان از عملکرد صحیح	41	42	2026-07-06	approved	ac9072e5-ff0f-4d63-880d-330ba7a1645e	\N	a301cae9-53cc-4ec1-b9db-daef1d3d6c02	2026-07-20 11:11:03.957452+00	2026-07-20 11:11:03.957452+00
4dcc3819-424c-4d09-9482-91ed2d9d19ab	96f673fc-9332-48ac-b2e9-9a50d8a40f8b	3a5bbe57-a350-4aac-a8a7-02d037f0c644	مستندسازی و نهایی‌سازی	192	84	2026-07-08	approved	ac9072e5-ff0f-4d63-880d-330ba7a1645e	\N	6530c9ba-5b52-4019-a00b-b62773a9a0ed	2026-07-20 11:11:03.957452+00	2026-07-20 11:11:03.957452+00
4dcc3819-424c-4d09-9482-91ed2d9d19ab	a96e0cdc-0846-49e1-95ab-2eef23819a93	c159ec20-f52f-44c6-a62b-b5579693a2e2	تست و اطمینان از عملکرد صحیح	197	32	2026-07-16	approved	ac9072e5-ff0f-4d63-880d-330ba7a1645e	\N	90753a7f-4282-4ed2-ab56-db59eceb4829	2026-07-20 11:11:03.957452+00	2026-07-20 11:11:03.957452+00
4dcc3819-424c-4d09-9482-91ed2d9d19ab	a96e0cdc-0846-49e1-95ab-2eef23819a93	c159ec20-f52f-44c6-a62b-b5579693a2e2	مستندسازی و نهایی‌سازی	197	44	2026-07-16	approved	ac9072e5-ff0f-4d63-880d-330ba7a1645e	\N	324bfd20-84f2-43f5-9684-cb5db741bf72	2026-07-20 11:11:03.957452+00	2026-07-20 11:11:03.957452+00
4dcc3819-424c-4d09-9482-91ed2d9d19ab	a96e0cdc-0846-49e1-95ab-2eef23819a93	c159ec20-f52f-44c6-a62b-b5579693a2e2	تست و اطمینان از عملکرد صحیح	87	100	2026-07-16	approved	ac9072e5-ff0f-4d63-880d-330ba7a1645e	\N	f1758081-8317-4196-bd28-c6e4c959f07c	2026-07-20 11:11:03.957452+00	2026-07-20 11:11:03.957452+00
4dcc3819-424c-4d09-9482-91ed2d9d19ab	9994f419-8039-4aea-8c70-dc26f1de02d8	fbd6cd8f-ebe9-40af-a413-fa64b9419d5a	رفع اشکالات و بازبینی	154	35	2026-07-16	submitted	\N	\N	ca123d32-213b-4ff5-9d98-5fbd6c3b0bb7	2026-07-20 11:11:03.957452+00	2026-07-20 11:11:03.957452+00
4dcc3819-424c-4d09-9482-91ed2d9d19ab	9994f419-8039-4aea-8c70-dc26f1de02d8	fbd6cd8f-ebe9-40af-a413-fa64b9419d5a	پیاده‌سازی بخش اصلی	142	50	2026-07-16	approved	ac9072e5-ff0f-4d63-880d-330ba7a1645e	\N	713cdefa-ed21-4e54-ada1-c3ff60a2fa46	2026-07-20 11:11:03.957452+00	2026-07-20 11:11:03.957452+00
4dcc3819-424c-4d09-9482-91ed2d9d19ab	9994f419-8039-4aea-8c70-dc26f1de02d8	fbd6cd8f-ebe9-40af-a413-fa64b9419d5a	رفع اشکالات و بازبینی	84	72	2026-07-16	approved	ac9072e5-ff0f-4d63-880d-330ba7a1645e	\N	704744a2-7f2b-4490-897c-1e69e2bb6895	2026-07-20 11:11:03.957452+00	2026-07-20 11:11:03.957452+00
4dcc3819-424c-4d09-9482-91ed2d9d19ab	9994f419-8039-4aea-8c70-dc26f1de02d8	fbd6cd8f-ebe9-40af-a413-fa64b9419d5a	مستندسازی و نهایی‌سازی	213	92	2026-07-16	approved	ac9072e5-ff0f-4d63-880d-330ba7a1645e	\N	f97a71bb-f258-474c-8210-9f46d9a488ac	2026-07-20 11:11:03.957452+00	2026-07-20 11:11:03.957452+00
4dcc3819-424c-4d09-9482-91ed2d9d19ab	5092ef86-2ad5-4fa4-b89b-2bfea7f42408	0631f64d-7a8f-4a1f-b13c-6e22248209c5	پیشرفت اولیه و بررسی نیازمندی‌ها	153	35	2026-07-11	submitted	\N	\N	35ac8a0d-8792-42a0-8212-14c6d79f836a	2026-07-20 11:11:03.957452+00	2026-07-20 11:11:03.957452+00
4dcc3819-424c-4d09-9482-91ed2d9d19ab	5092ef86-2ad5-4fa4-b89b-2bfea7f42408	0631f64d-7a8f-4a1f-b13c-6e22248209c5	پیاده‌سازی بخش اصلی	195	66	2026-07-15	approved	ac9072e5-ff0f-4d63-880d-330ba7a1645e	\N	2d25659b-c4e0-4f5a-95dd-6023a8c74458	2026-07-20 11:11:03.957452+00	2026-07-20 11:11:03.957452+00
4dcc3819-424c-4d09-9482-91ed2d9d19ab	f89a00e0-c6ea-44dd-8ea9-bb22af97189a	fbd6cd8f-ebe9-40af-a413-fa64b9419d5a	پیشرفت اولیه و بررسی نیازمندی‌ها	62	38	2026-07-09	approved	ac9072e5-ff0f-4d63-880d-330ba7a1645e	\N	0f8b5fa7-d100-44c2-aec1-a66569eab42f	2026-07-20 11:11:03.957452+00	2026-07-20 11:11:03.957452+00
4dcc3819-424c-4d09-9482-91ed2d9d19ab	d0145a8f-d8a0-4aea-889e-176b83d30096	ac9072e5-ff0f-4d63-880d-330ba7a1645e	پیشرفت اولیه و بررسی نیازمندی‌ها	176	24	2026-07-16	approved	ac9072e5-ff0f-4d63-880d-330ba7a1645e	\N	70500ea3-5d30-4abd-8a2e-0ac50bbc3f11	2026-07-20 11:11:03.957452+00	2026-07-20 11:11:03.957452+00
4dcc3819-424c-4d09-9482-91ed2d9d19ab	d0145a8f-d8a0-4aea-889e-176b83d30096	ac9072e5-ff0f-4d63-880d-330ba7a1645e	پیاده‌سازی بخش اصلی	162	64	2026-07-16	approved	ac9072e5-ff0f-4d63-880d-330ba7a1645e	\N	5bc8d11b-9b4d-4b0d-aaa4-e4be2e66a7c2	2026-07-20 11:11:03.957452+00	2026-07-20 11:11:03.957452+00
4dcc3819-424c-4d09-9482-91ed2d9d19ab	5bea899f-f875-4671-8458-fec124ca740f	3a5bbe57-a350-4aac-a8a7-02d037f0c644	پیاده‌سازی بخش اصلی	144	39	2026-07-15	submitted	\N	\N	d9575e11-ea3a-47eb-97de-dd2384e2c3f2	2026-07-20 11:11:03.957452+00	2026-07-20 11:11:03.957452+00
4dcc3819-424c-4d09-9482-91ed2d9d19ab	382836eb-0786-41c4-82e9-a9c9c3537285	c159ec20-f52f-44c6-a62b-b5579693a2e2	تست و اطمینان از عملکرد صحیح	183	24	2026-06-17	approved	ac9072e5-ff0f-4d63-880d-330ba7a1645e	\N	17d69b6a-a9e2-43c2-9c27-705a1f49bc4f	2026-07-20 11:11:03.957452+00	2026-07-20 11:11:03.957452+00
4dcc3819-424c-4d09-9482-91ed2d9d19ab	382836eb-0786-41c4-82e9-a9c9c3537285	c159ec20-f52f-44c6-a62b-b5579693a2e2	مستندسازی و نهایی‌سازی	97	50	2026-06-19	approved	ac9072e5-ff0f-4d63-880d-330ba7a1645e	\N	5e2f4a67-3df4-47ab-9613-e97bf2172093	2026-07-20 11:11:03.957452+00	2026-07-20 11:11:03.957452+00
4dcc3819-424c-4d09-9482-91ed2d9d19ab	382836eb-0786-41c4-82e9-a9c9c3537285	c159ec20-f52f-44c6-a62b-b5579693a2e2	مستندسازی و نهایی‌سازی	181	66	2026-06-23	submitted	\N	\N	c1ae9d5a-9d85-4b7e-9bb3-0b8a0e80085a	2026-07-20 11:11:03.957452+00	2026-07-20 11:11:03.957452+00
4dcc3819-424c-4d09-9482-91ed2d9d19ab	382836eb-0786-41c4-82e9-a9c9c3537285	c159ec20-f52f-44c6-a62b-b5579693a2e2	پیاده‌سازی بخش اصلی	57	80	2026-06-23	approved	ac9072e5-ff0f-4d63-880d-330ba7a1645e	\N	73a33642-ea5c-45e6-8173-bc25ecc25b90	2026-07-20 11:11:03.957452+00	2026-07-20 11:11:03.957452+00
4dcc3819-424c-4d09-9482-91ed2d9d19ab	cc5adbd1-fc26-4771-8b92-5ae77770353e	ac9072e5-ff0f-4d63-880d-330ba7a1645e	پیاده‌سازی بخش اصلی	185	23	2026-06-23	approved	ac9072e5-ff0f-4d63-880d-330ba7a1645e	\N	a03b275c-9ec8-47ad-90d6-bff0f27c57cb	2026-07-20 11:11:03.957452+00	2026-07-20 11:11:03.957452+00
4dcc3819-424c-4d09-9482-91ed2d9d19ab	cc5adbd1-fc26-4771-8b92-5ae77770353e	ac9072e5-ff0f-4d63-880d-330ba7a1645e	تست و اطمینان از عملکرد صحیح	187	78	2026-06-25	approved	ac9072e5-ff0f-4d63-880d-330ba7a1645e	\N	d44f184f-4d20-40ea-bd58-80b64d9a4482	2026-07-20 11:11:03.957452+00	2026-07-20 11:11:03.957452+00
4dcc3819-424c-4d09-9482-91ed2d9d19ab	3194b873-443a-4437-b347-de8bd7446fbb	ea1e6921-d2aa-44c0-978b-ff36b7d9fff2	پیشرفت اولیه و بررسی نیازمندی‌ها	153	24	2026-07-16	approved	ac9072e5-ff0f-4d63-880d-330ba7a1645e	\N	a5b371a7-3a29-4b4a-9ae6-e72ada3f4a87	2026-07-20 11:11:03.957452+00	2026-07-20 11:11:03.957452+00
4dcc3819-424c-4d09-9482-91ed2d9d19ab	dc7cd50f-f2ec-417b-bbc1-5c84caaad9da	0631f64d-7a8f-4a1f-b13c-6e22248209c5	مستندسازی و نهایی‌سازی	137	31	2026-07-12	approved	ac9072e5-ff0f-4d63-880d-330ba7a1645e	\N	88766057-bd18-48e9-8bcf-eb6711cf47d5	2026-07-20 11:11:03.957452+00	2026-07-20 11:11:03.957452+00
4dcc3819-424c-4d09-9482-91ed2d9d19ab	be739564-4c45-414d-8e4b-3877515faddb	57aede22-e4a3-452e-8ade-22917514d015	پیاده‌سازی بخش اصلی	235	35	2026-07-16	approved	ac9072e5-ff0f-4d63-880d-330ba7a1645e	\N	a730bffa-85b9-4c14-b8a6-b495259eeb54	2026-07-20 11:11:03.957452+00	2026-07-20 11:11:03.957452+00
4dcc3819-424c-4d09-9482-91ed2d9d19ab	20a3a982-0de8-4a08-b43f-03086897e8ae	3a5bbe57-a350-4aac-a8a7-02d037f0c644	مستندسازی و نهایی‌سازی	235	38	2026-07-08	approved	ac9072e5-ff0f-4d63-880d-330ba7a1645e	\N	73fa77c4-32e8-4bbe-9e52-f6536b04899e	2026-07-20 11:11:03.957452+00	2026-07-20 11:11:03.957452+00
4dcc3819-424c-4d09-9482-91ed2d9d19ab	20a3a982-0de8-4a08-b43f-03086897e8ae	3a5bbe57-a350-4aac-a8a7-02d037f0c644	تست و اطمینان از عملکرد صحیح	64	56	2026-07-09	approved	ac9072e5-ff0f-4d63-880d-330ba7a1645e	\N	0b01a665-5d47-412f-bf81-5a3b1a9c03f7	2026-07-20 11:11:03.957452+00	2026-07-20 11:11:03.957452+00
4dcc3819-424c-4d09-9482-91ed2d9d19ab	20a3a982-0de8-4a08-b43f-03086897e8ae	3a5bbe57-a350-4aac-a8a7-02d037f0c644	پیاده‌سازی بخش اصلی	51	87	2026-07-16	approved	ac9072e5-ff0f-4d63-880d-330ba7a1645e	\N	09caf15c-225b-447e-aa7c-9f1c542fdc57	2026-07-20 11:11:03.957452+00	2026-07-20 11:11:03.957452+00
4dcc3819-424c-4d09-9482-91ed2d9d19ab	20a3a982-0de8-4a08-b43f-03086897e8ae	3a5bbe57-a350-4aac-a8a7-02d037f0c644	رفع اشکالات و بازبینی	78	80	2026-07-16	approved	ac9072e5-ff0f-4d63-880d-330ba7a1645e	\N	ac3066fa-e83f-4bc3-9711-9b93348afce7	2026-07-20 11:11:03.957452+00	2026-07-20 11:11:03.957452+00
4dcc3819-424c-4d09-9482-91ed2d9d19ab	106de1b8-0b17-4ac5-955f-fd50b81883a5	ea1e6921-d2aa-44c0-978b-ff36b7d9fff2	تست و اطمینان از عملکرد صحیح	197	26	2026-07-16	approved	ac9072e5-ff0f-4d63-880d-330ba7a1645e	\N	eb06609d-1d31-4079-911d-569a12d4d41e	2026-07-20 11:11:03.957452+00	2026-07-20 11:11:03.957452+00
4dcc3819-424c-4d09-9482-91ed2d9d19ab	3db5ea5c-e5b2-4b13-863d-009b3c9f4e3d	c159ec20-f52f-44c6-a62b-b5579693a2e2	رفع اشکالات و بازبینی	57	24	2026-07-16	approved	ac9072e5-ff0f-4d63-880d-330ba7a1645e	\N	98c205ff-f82f-4978-b124-a1c9cb87e99d	2026-07-20 11:11:03.957452+00	2026-07-20 11:11:03.957452+00
4dcc3819-424c-4d09-9482-91ed2d9d19ab	3db5ea5c-e5b2-4b13-863d-009b3c9f4e3d	c159ec20-f52f-44c6-a62b-b5579693a2e2	مستندسازی و نهایی‌سازی	94	56	2026-07-16	approved	ac9072e5-ff0f-4d63-880d-330ba7a1645e	\N	02b3c246-931e-4250-a4a5-f5499c1a2d73	2026-07-20 11:11:03.957452+00	2026-07-20 11:11:03.957452+00
4dcc3819-424c-4d09-9482-91ed2d9d19ab	3db5ea5c-e5b2-4b13-863d-009b3c9f4e3d	c159ec20-f52f-44c6-a62b-b5579693a2e2	مستندسازی و نهایی‌سازی	123	100	2026-07-16	approved	ac9072e5-ff0f-4d63-880d-330ba7a1645e	\N	669b0adf-0607-47c7-92c9-023e75496ceb	2026-07-20 11:11:03.957452+00	2026-07-20 11:11:03.957452+00
4dcc3819-424c-4d09-9482-91ed2d9d19ab	591e1251-7e5c-4053-9055-1e7d9c9da7ed	ea1e6921-d2aa-44c0-978b-ff36b7d9fff2	تست و اطمینان از عملکرد صحیح	171	37	2026-07-02	submitted	\N	\N	0888d8db-1f7c-487f-bbb1-9f4ef4f188d2	2026-07-20 11:11:03.957452+00	2026-07-20 11:11:03.957452+00
4dcc3819-424c-4d09-9482-91ed2d9d19ab	591e1251-7e5c-4053-9055-1e7d9c9da7ed	ea1e6921-d2aa-44c0-978b-ff36b7d9fff2	مستندسازی و نهایی‌سازی	172	70	2026-07-06	approved	ac9072e5-ff0f-4d63-880d-330ba7a1645e	\N	3f9d2e84-9b25-4aa3-95cb-21aaea874ad5	2026-07-20 11:11:03.957452+00	2026-07-20 11:11:03.957452+00
4dcc3819-424c-4d09-9482-91ed2d9d19ab	591e1251-7e5c-4053-9055-1e7d9c9da7ed	ea1e6921-d2aa-44c0-978b-ff36b7d9fff2	مستندسازی و نهایی‌سازی	118	96	2026-07-08	submitted	\N	\N	39ed9eab-2946-45ad-98ee-510d02fca57e	2026-07-20 11:11:03.957452+00	2026-07-20 11:11:03.957452+00
4dcc3819-424c-4d09-9482-91ed2d9d19ab	08516d02-0f69-4278-a6c1-b8b7ea81882e	c159ec20-f52f-44c6-a62b-b5579693a2e2	تست و اطمینان از عملکرد صحیح	230	25	2026-07-09	submitted	\N	\N	a9c5abe7-50f0-4bf6-be9c-adcc1c1983ff	2026-07-20 11:11:03.957452+00	2026-07-20 11:11:03.957452+00
4dcc3819-424c-4d09-9482-91ed2d9d19ab	08516d02-0f69-4278-a6c1-b8b7ea81882e	c159ec20-f52f-44c6-a62b-b5579693a2e2	تست و اطمینان از عملکرد صحیح	231	60	2026-07-10	approved	ac9072e5-ff0f-4d63-880d-330ba7a1645e	\N	5ebfb14a-ada2-4b89-8841-f8336c46c95f	2026-07-20 11:11:03.957452+00	2026-07-20 11:11:03.957452+00
4dcc3819-424c-4d09-9482-91ed2d9d19ab	4c26af3f-32f7-4ef2-bd23-29b230be4e52	ea1e6921-d2aa-44c0-978b-ff36b7d9fff2	تست و اطمینان از عملکرد صحیح	192	20	2026-07-16	approved	ac9072e5-ff0f-4d63-880d-330ba7a1645e	\N	c95a8ec9-42d8-4363-a753-679f4e91ce49	2026-07-20 11:11:03.957452+00	2026-07-20 11:11:03.957452+00
4dcc3819-424c-4d09-9482-91ed2d9d19ab	07b79ded-0be0-4e1b-bed9-2a803be46ca0	ea1e6921-d2aa-44c0-978b-ff36b7d9fff2	مستندسازی و نهایی‌سازی	141	22	2026-07-15	approved	ac9072e5-ff0f-4d63-880d-330ba7a1645e	\N	d01e281a-7680-4e7b-8d3a-7110860d30ec	2026-07-20 11:11:03.957452+00	2026-07-20 11:11:03.957452+00
4dcc3819-424c-4d09-9482-91ed2d9d19ab	a5ca0270-2799-4d4e-b606-bc9f0a084ca6	0631f64d-7a8f-4a1f-b13c-6e22248209c5	پیاده‌سازی بخش اصلی	124	22	2026-07-10	approved	ac9072e5-ff0f-4d63-880d-330ba7a1645e	\N	126ff3a3-e5bf-400e-9cc0-477616bf8be5	2026-07-20 11:11:03.957452+00	2026-07-20 11:11:03.957452+00
4dcc3819-424c-4d09-9482-91ed2d9d19ab	9233ea01-b721-4bd8-bfa6-4fbc5c06e581	c159ec20-f52f-44c6-a62b-b5579693a2e2	تست و اطمینان از عملکرد صحیح	187	40	2026-07-16	approved	ac9072e5-ff0f-4d63-880d-330ba7a1645e	\N	8b38ada2-09af-4741-8c10-0ff7fff2bf22	2026-07-20 11:11:03.957452+00	2026-07-20 11:11:03.957452+00
4dcc3819-424c-4d09-9482-91ed2d9d19ab	ed11b037-b9ce-41ee-9de5-059d401bbe68	0631f64d-7a8f-4a1f-b13c-6e22248209c5	پیاده‌سازی بخش اصلی	193	35	2026-07-16	approved	ac9072e5-ff0f-4d63-880d-330ba7a1645e	\N	54932929-05f9-47f6-b66f-588de9dc4f50	2026-07-20 11:11:03.957452+00	2026-07-20 11:11:03.957452+00
4dcc3819-424c-4d09-9482-91ed2d9d19ab	ed11b037-b9ce-41ee-9de5-059d401bbe68	0631f64d-7a8f-4a1f-b13c-6e22248209c5	پیشرفت اولیه و بررسی نیازمندی‌ها	81	72	2026-07-16	approved	ac9072e5-ff0f-4d63-880d-330ba7a1645e	\N	8e7df204-2a86-4225-8833-e2ebaf1fd049	2026-07-20 11:11:03.957452+00	2026-07-20 11:11:03.957452+00
4dcc3819-424c-4d09-9482-91ed2d9d19ab	ed11b037-b9ce-41ee-9de5-059d401bbe68	0631f64d-7a8f-4a1f-b13c-6e22248209c5	پیاده‌سازی بخش اصلی	38	100	2026-07-16	approved	ac9072e5-ff0f-4d63-880d-330ba7a1645e	\N	634a6b80-e164-4a90-8ca3-4a89db40ebf9	2026-07-20 11:11:03.957452+00	2026-07-20 11:11:03.957452+00
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


