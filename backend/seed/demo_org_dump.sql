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
2026-07-20 09:59:51.805047+00	a03a787d-b998-4a31-aa2e-2aef31ab5784	487a4011-366a-4e1c-ac4d-6f24e62436c6	user.login	user	487a4011-366a-4e1c-ac4d-6f24e62436c6	{}	d7e54dc8-fc6b-4406-8ede-2193cdf92c9c
2026-07-20 10:00:12.516448+00	a03a787d-b998-4a31-aa2e-2aef31ab5784	487a4011-366a-4e1c-ac4d-6f24e62436c6	user.login	user	487a4011-366a-4e1c-ac4d-6f24e62436c6	{}	124e4a4a-72d1-4431-a6ce-6159de610acd
2026-07-20 10:06:15.878279+00	a03a787d-b998-4a31-aa2e-2aef31ab5784	487a4011-366a-4e1c-ac4d-6f24e62436c6	user.login	user	487a4011-366a-4e1c-ac4d-6f24e62436c6	{}	06119de5-69df-4963-b895-8315796cb578
\.


--
-- Data for Name: calendar_events; Type: TABLE DATA; Schema: public; Owner: -
--

COPY public.calendar_events (id, created_at, updated_at, organization_id, created_by_id, project_id, user_id, title, description, event_type, start_at, end_at, all_day) FROM stdin;
ff29d65d-fff0-4e60-9955-0e63c83de697	2026-07-20 09:59:26.363877+00	2026-07-20 09:59:26.363877+00	a03a787d-b998-4a31-aa2e-2aef31ab5784	1fd6e737-0c6b-49b7-841e-0f8a73d3c1a1	b2f9aaf2-33f5-448b-8177-93cf8a2e2cda	\N	جلسهٔ مرور با مدیریت	\N	meeting	2026-06-19 10:00:00+00	2026-06-19 11:00:00+00	f
c6b25efe-ecc5-40f0-b129-46d602ad4f03	2026-07-20 09:59:26.363877+00	2026-07-20 09:59:26.363877+00	a03a787d-b998-4a31-aa2e-2aef31ab5784	842034d4-0d08-46e1-bdd9-05eec45bcffa	05099cdc-50af-4a51-810f-e8a374ef5665	\N	یادآوری پیگیری مشتری	\N	reminder	2026-06-16 00:00:00+00	2026-06-16 01:00:00+00	t
19ce0af2-9277-4ac9-ac1d-3c841f5d4caa	2026-07-20 09:59:26.363877+00	2026-07-20 09:59:26.363877+00	a03a787d-b998-4a31-aa2e-2aef31ab5784	9827c403-87f1-46cd-875d-0796d77e64a1	\N	\N	تعطیلی رسمی	\N	holiday	2026-06-18 00:00:00+00	2026-06-18 01:00:00+00	t
89844b78-6a75-4fab-977d-267c4dba7b19	2026-07-20 09:59:26.363877+00	2026-07-20 09:59:26.363877+00	a03a787d-b998-4a31-aa2e-2aef31ab5784	1fd6e737-0c6b-49b7-841e-0f8a73d3c1a1	5730191d-f4bd-43eb-90fc-18243ae04e10	\N	جلسهٔ بررسی پیشرفت پروژه	\N	meeting	2026-06-27 10:00:00+00	2026-06-27 11:00:00+00	f
26881fe0-3d03-4f18-be09-04a5a3ae1bc0	2026-07-20 09:59:26.363877+00	2026-07-20 09:59:26.363877+00	a03a787d-b998-4a31-aa2e-2aef31ab5784	be1819a8-75ce-4c92-8f50-3b2a8aa29e30	c52c73bc-c6d8-4e9b-a31c-7665a092eaa2	\N	یادآوری تمدید قرارداد	\N	reminder	2026-06-28 00:00:00+00	2026-06-28 01:00:00+00	t
13d66ee9-cea9-4f0b-acdb-ac8773bb4241	2026-07-20 09:59:26.363877+00	2026-07-20 09:59:26.363877+00	a03a787d-b998-4a31-aa2e-2aef31ab5784	1fd6e737-0c6b-49b7-841e-0f8a73d3c1a1	e47f5049-79ab-4a81-b5e4-d5e5b14eda2c	\N	جلسهٔ برنامه‌ریزی اسپرینت	\N	meeting	2026-07-04 10:00:00+00	2026-07-04 11:00:00+00	f
dd20d72b-f703-40e3-a111-c67129f3771f	2026-07-20 09:59:26.363877+00	2026-07-20 09:59:26.363877+00	a03a787d-b998-4a31-aa2e-2aef31ab5784	d6fc165d-7448-431b-af51-26d9bb7751a1	05099cdc-50af-4a51-810f-e8a374ef5665	\N	یادآوری ارسال گزارش	\N	reminder	2026-07-01 00:00:00+00	2026-07-01 01:00:00+00	t
cb274c28-fedb-4e8f-bf61-3d03ec8ad69b	2026-07-20 09:59:26.363877+00	2026-07-20 09:59:26.363877+00	a03a787d-b998-4a31-aa2e-2aef31ab5784	1fd6e737-0c6b-49b7-841e-0f8a73d3c1a1	e47f5049-79ab-4a81-b5e4-d5e5b14eda2c	\N	جلسهٔ برنامه‌ریزی اسپرینت	\N	meeting	2026-07-11 10:00:00+00	2026-07-11 11:00:00+00	f
35808622-1d55-4177-abed-321bc7e817c9	2026-07-20 09:59:26.363877+00	2026-07-20 09:59:26.363877+00	a03a787d-b998-4a31-aa2e-2aef31ab5784	d6fc165d-7448-431b-af51-26d9bb7751a1	5730191d-f4bd-43eb-90fc-18243ae04e10	\N	یادآوری پیگیری مشتری	\N	reminder	2026-07-07 00:00:00+00	2026-07-07 01:00:00+00	t
0c9c3f63-4f18-45f2-89c6-3f2893076653	2026-07-20 09:59:26.363877+00	2026-07-20 09:59:26.363877+00	a03a787d-b998-4a31-aa2e-2aef31ab5784	1fd6e737-0c6b-49b7-841e-0f8a73d3c1a1	5730191d-f4bd-43eb-90fc-18243ae04e10	\N	جلسهٔ هماهنگی هفتگی	\N	meeting	2026-07-18 10:00:00+00	2026-07-18 11:00:00+00	f
68233a8a-d584-46e7-a881-160e7f18ba5c	2026-07-20 09:59:26.363877+00	2026-07-20 09:59:26.363877+00	a03a787d-b998-4a31-aa2e-2aef31ab5784	e5ed62a2-bd4a-46d5-a6c6-be866906977f	e47f5049-79ab-4a81-b5e4-d5e5b14eda2c	\N	یادآوری پیگیری مشتری	\N	reminder	2026-07-17 00:00:00+00	2026-07-17 01:00:00+00	t
ab2fa9a8-4821-4ce3-9af4-d57f0d492a98	2026-07-20 09:59:26.363877+00	2026-07-20 09:59:26.363877+00	a03a787d-b998-4a31-aa2e-2aef31ab5784	9827c403-87f1-46cd-875d-0796d77e64a1	\N	\N	تعطیلی رسمی	\N	holiday	2026-07-16 00:00:00+00	2026-07-16 01:00:00+00	t
765ff651-1c24-4d14-b1ee-7e2637b97303	2026-07-20 09:59:26.363877+00	2026-07-20 09:59:26.363877+00	a03a787d-b998-4a31-aa2e-2aef31ab5784	1fd6e737-0c6b-49b7-841e-0f8a73d3c1a1	c52c73bc-c6d8-4e9b-a31c-7665a092eaa2	\N	جلسهٔ هماهنگی هفتگی	\N	meeting	2026-07-23 10:00:00+00	2026-07-23 11:00:00+00	f
22acef18-c28f-4838-b07e-8694f6957fbc	2026-07-20 09:59:26.363877+00	2026-07-20 09:59:26.363877+00	a03a787d-b998-4a31-aa2e-2aef31ab5784	842034d4-0d08-46e1-bdd9-05eec45bcffa	c52c73bc-c6d8-4e9b-a31c-7665a092eaa2	\N	یادآوری ارسال گزارش	\N	reminder	2026-07-23 00:00:00+00	2026-07-23 01:00:00+00	t
05e7c0b9-b52d-43a2-af6b-77328695db73	2026-07-20 09:59:26.363877+00	2026-07-20 09:59:26.363877+00	a03a787d-b998-4a31-aa2e-2aef31ab5784	1fd6e737-0c6b-49b7-841e-0f8a73d3c1a1	e47f5049-79ab-4a81-b5e4-d5e5b14eda2c	\N	جلسهٔ برنامه‌ریزی اسپرینت	\N	meeting	2026-08-01 10:00:00+00	2026-08-01 11:00:00+00	f
abfa8326-123a-4085-b9d2-96ebf8b4a21d	2026-07-20 09:59:26.363877+00	2026-07-20 09:59:26.363877+00	a03a787d-b998-4a31-aa2e-2aef31ab5784	842034d4-0d08-46e1-bdd9-05eec45bcffa	c52c73bc-c6d8-4e9b-a31c-7665a092eaa2	\N	یادآوری پیگیری مشتری	\N	reminder	2026-07-29 00:00:00+00	2026-07-29 01:00:00+00	t
bf3605e8-b800-4607-b1b9-3a278ef35c30	2026-07-20 09:59:26.363877+00	2026-07-20 09:59:26.363877+00	a03a787d-b998-4a31-aa2e-2aef31ab5784	1fd6e737-0c6b-49b7-841e-0f8a73d3c1a1	c52c73bc-c6d8-4e9b-a31c-7665a092eaa2	\N	جلسهٔ مرور با مدیریت	\N	meeting	2026-08-05 10:00:00+00	2026-08-05 11:00:00+00	f
2f96b173-661e-4333-9868-bbd482fe99ed	2026-07-20 09:59:26.363877+00	2026-07-20 09:59:26.363877+00	a03a787d-b998-4a31-aa2e-2aef31ab5784	e5ed62a2-bd4a-46d5-a6c6-be866906977f	b2f9aaf2-33f5-448b-8177-93cf8a2e2cda	\N	یادآوری ارسال گزارش	\N	reminder	2026-08-09 00:00:00+00	2026-08-09 01:00:00+00	t
27770cf6-d21d-436c-bbb1-421c1448b6f5	2026-07-20 09:59:26.363877+00	2026-07-20 09:59:26.363877+00	a03a787d-b998-4a31-aa2e-2aef31ab5784	1fd6e737-0c6b-49b7-841e-0f8a73d3c1a1	e47f5049-79ab-4a81-b5e4-d5e5b14eda2c	\N	جلسهٔ هماهنگی هفتگی	\N	meeting	2026-08-14 10:00:00+00	2026-08-14 11:00:00+00	f
f0c3d2b6-f4c7-4849-b500-27931fb42a2c	2026-07-20 09:59:26.363877+00	2026-07-20 09:59:26.363877+00	a03a787d-b998-4a31-aa2e-2aef31ab5784	be1819a8-75ce-4c92-8f50-3b2a8aa29e30	e47f5049-79ab-4a81-b5e4-d5e5b14eda2c	\N	یادآوری ارسال گزارش	\N	reminder	2026-08-13 00:00:00+00	2026-08-13 01:00:00+00	t
69b9de4f-bc06-48a4-8d11-02bd0953bb20	2026-07-20 09:59:26.363877+00	2026-07-20 09:59:26.363877+00	a03a787d-b998-4a31-aa2e-2aef31ab5784	9827c403-87f1-46cd-875d-0796d77e64a1	\N	\N	تعطیلی رسمی	\N	holiday	2026-08-13 00:00:00+00	2026-08-13 01:00:00+00	t
1d0bea5f-aa38-492e-888e-6c6ce3b810e0	2026-07-20 09:59:26.363877+00	2026-07-20 09:59:26.363877+00	a03a787d-b998-4a31-aa2e-2aef31ab5784	328fce4c-c7e7-4b44-8dcb-45aad65bd8e5	1fbf1e47-ab67-430d-841c-ca56a83c091e	\N	جلسهٔ هماهنگی هفتگی	\N	meeting	2026-06-16 10:00:00+00	2026-06-16 11:00:00+00	f
01c27483-89ee-4dfe-a304-207f2d3a026a	2026-07-20 09:59:26.363877+00	2026-07-20 09:59:26.363877+00	a03a787d-b998-4a31-aa2e-2aef31ab5784	c1eff56a-cf6f-4901-9c44-9063f53db8c8	718abbd9-dab5-433d-bd20-046f3974f6ef	\N	یادآوری ارسال گزارش	\N	reminder	2026-06-16 00:00:00+00	2026-06-16 01:00:00+00	t
1a248fb9-1a0e-4d88-a175-0b634e9a344b	2026-07-20 09:59:26.363877+00	2026-07-20 09:59:26.363877+00	a03a787d-b998-4a31-aa2e-2aef31ab5784	9827c403-87f1-46cd-875d-0796d77e64a1	\N	\N	تعطیلی رسمی	\N	holiday	2026-06-18 00:00:00+00	2026-06-18 01:00:00+00	t
34b946d2-ccb1-4077-8a4d-04f383b0eeb9	2026-07-20 09:59:26.363877+00	2026-07-20 09:59:26.363877+00	a03a787d-b998-4a31-aa2e-2aef31ab5784	328fce4c-c7e7-4b44-8dcb-45aad65bd8e5	1fbf1e47-ab67-430d-841c-ca56a83c091e	\N	جلسهٔ هماهنگی هفتگی	\N	meeting	2026-06-23 10:00:00+00	2026-06-23 11:00:00+00	f
ec17666c-6144-4d7f-b276-e69c223b8444	2026-07-20 09:59:26.363877+00	2026-07-20 09:59:26.363877+00	a03a787d-b998-4a31-aa2e-2aef31ab5784	1775df44-8335-487a-9a3b-a1a6eb5949f5	349ecde7-6ae3-4dbc-85ce-291df6cda967	\N	یادآوری پیگیری مشتری	\N	reminder	2026-06-26 00:00:00+00	2026-06-26 01:00:00+00	t
2f264fb4-0efa-43cf-8d3c-54df8634351e	2026-07-20 09:59:26.363877+00	2026-07-20 09:59:26.363877+00	a03a787d-b998-4a31-aa2e-2aef31ab5784	328fce4c-c7e7-4b44-8dcb-45aad65bd8e5	718abbd9-dab5-433d-bd20-046f3974f6ef	\N	جلسهٔ مرور با مدیریت	\N	meeting	2026-07-03 10:00:00+00	2026-07-03 11:00:00+00	f
291dfb76-4eef-4fc3-b6e3-a4887449d919	2026-07-20 09:59:26.363877+00	2026-07-20 09:59:26.363877+00	a03a787d-b998-4a31-aa2e-2aef31ab5784	767b011b-ff3a-4faf-b85b-c424554a44a0	718abbd9-dab5-433d-bd20-046f3974f6ef	\N	یادآوری ارسال گزارش	\N	reminder	2026-06-30 00:00:00+00	2026-06-30 01:00:00+00	t
1ca4a585-52e8-4704-9f1d-89a18e06ce34	2026-07-20 09:59:26.363877+00	2026-07-20 09:59:26.363877+00	a03a787d-b998-4a31-aa2e-2aef31ab5784	328fce4c-c7e7-4b44-8dcb-45aad65bd8e5	1fbf1e47-ab67-430d-841c-ca56a83c091e	\N	جلسهٔ بررسی پیشرفت پروژه	\N	meeting	2026-07-08 10:00:00+00	2026-07-08 11:00:00+00	f
8061c902-fb8c-4a7d-850c-2b6353ec81b2	2026-07-20 09:59:26.363877+00	2026-07-20 09:59:26.363877+00	a03a787d-b998-4a31-aa2e-2aef31ab5784	9c22bc65-2479-4780-b3a0-0ed5e139ee5f	718abbd9-dab5-433d-bd20-046f3974f6ef	\N	یادآوری ارسال گزارش	\N	reminder	2026-07-09 00:00:00+00	2026-07-09 01:00:00+00	t
9d7cc954-f642-423f-bc87-b8b8370825de	2026-07-20 09:59:26.363877+00	2026-07-20 09:59:26.363877+00	a03a787d-b998-4a31-aa2e-2aef31ab5784	328fce4c-c7e7-4b44-8dcb-45aad65bd8e5	d6f8a913-4870-4aa5-a45f-e9c04e17b7fc	\N	جلسهٔ بررسی پیشرفت پروژه	\N	meeting	2026-07-18 10:00:00+00	2026-07-18 11:00:00+00	f
0335ad26-e3dd-4aab-bc31-a6b94963985e	2026-07-20 09:59:26.363877+00	2026-07-20 09:59:26.363877+00	a03a787d-b998-4a31-aa2e-2aef31ab5784	9c22bc65-2479-4780-b3a0-0ed5e139ee5f	718abbd9-dab5-433d-bd20-046f3974f6ef	\N	یادآوری تمدید قرارداد	\N	reminder	2026-07-19 00:00:00+00	2026-07-19 01:00:00+00	t
bc53d4ae-8cb0-4a0a-a17c-dba23caa9d95	2026-07-20 09:59:26.363877+00	2026-07-20 09:59:26.363877+00	a03a787d-b998-4a31-aa2e-2aef31ab5784	9827c403-87f1-46cd-875d-0796d77e64a1	\N	\N	تعطیلی رسمی	\N	holiday	2026-07-16 00:00:00+00	2026-07-16 01:00:00+00	t
cdfdb1c0-11b5-45ae-a26c-68d75b1d1312	2026-07-20 09:59:26.363877+00	2026-07-20 09:59:26.363877+00	a03a787d-b998-4a31-aa2e-2aef31ab5784	328fce4c-c7e7-4b44-8dcb-45aad65bd8e5	d6f8a913-4870-4aa5-a45f-e9c04e17b7fc	\N	جلسهٔ برنامه‌ریزی اسپرینت	\N	meeting	2026-07-21 10:00:00+00	2026-07-21 11:00:00+00	f
6738cd0b-1b8f-47bd-aa27-74957edb0df6	2026-07-20 09:59:26.363877+00	2026-07-20 09:59:26.363877+00	a03a787d-b998-4a31-aa2e-2aef31ab5784	c1eff56a-cf6f-4901-9c44-9063f53db8c8	718abbd9-dab5-433d-bd20-046f3974f6ef	\N	یادآوری ارسال گزارش	\N	reminder	2026-07-24 00:00:00+00	2026-07-24 01:00:00+00	t
b49d1108-0da9-40af-9f83-8ac86fadf7f9	2026-07-20 09:59:26.363877+00	2026-07-20 09:59:26.363877+00	a03a787d-b998-4a31-aa2e-2aef31ab5784	328fce4c-c7e7-4b44-8dcb-45aad65bd8e5	cb1c5120-3d84-4bc6-b309-5985dd7264ed	\N	جلسهٔ هماهنگی هفتگی	\N	meeting	2026-07-29 10:00:00+00	2026-07-29 11:00:00+00	f
69335bc0-4bbe-41b8-9b00-25b0ec7f58b6	2026-07-20 09:59:26.363877+00	2026-07-20 09:59:26.363877+00	a03a787d-b998-4a31-aa2e-2aef31ab5784	276feb60-37b2-42ff-be39-f9e79af8ae2a	1fbf1e47-ab67-430d-841c-ca56a83c091e	\N	یادآوری تمدید قرارداد	\N	reminder	2026-07-31 00:00:00+00	2026-07-31 01:00:00+00	t
e7a9f2c8-7293-4cd0-a6f4-c457d3efc65e	2026-07-20 09:59:26.363877+00	2026-07-20 09:59:26.363877+00	a03a787d-b998-4a31-aa2e-2aef31ab5784	328fce4c-c7e7-4b44-8dcb-45aad65bd8e5	cb1c5120-3d84-4bc6-b309-5985dd7264ed	\N	جلسهٔ برنامه‌ریزی اسپرینت	\N	meeting	2026-08-07 10:00:00+00	2026-08-07 11:00:00+00	f
aaa74488-ee81-4045-a763-d5fbc6926a63	2026-07-20 09:59:26.363877+00	2026-07-20 09:59:26.363877+00	a03a787d-b998-4a31-aa2e-2aef31ab5784	f2917b41-6f1c-4444-a73d-884a91e847fe	1fbf1e47-ab67-430d-841c-ca56a83c091e	\N	یادآوری تمدید قرارداد	\N	reminder	2026-08-08 00:00:00+00	2026-08-08 01:00:00+00	t
5a138098-5948-4cf7-84f3-5b734e743405	2026-07-20 09:59:26.363877+00	2026-07-20 09:59:26.363877+00	a03a787d-b998-4a31-aa2e-2aef31ab5784	328fce4c-c7e7-4b44-8dcb-45aad65bd8e5	1fbf1e47-ab67-430d-841c-ca56a83c091e	\N	جلسهٔ هماهنگی هفتگی	\N	meeting	2026-08-12 10:00:00+00	2026-08-12 11:00:00+00	f
e5d0ad8b-b9c4-4402-b477-e3b4e78b6bb5	2026-07-20 09:59:26.363877+00	2026-07-20 09:59:26.363877+00	a03a787d-b998-4a31-aa2e-2aef31ab5784	f2917b41-6f1c-4444-a73d-884a91e847fe	349ecde7-6ae3-4dbc-85ce-291df6cda967	\N	یادآوری ارسال گزارش	\N	reminder	2026-08-13 00:00:00+00	2026-08-13 01:00:00+00	t
fd476451-a154-4359-8d54-cbd10d886f37	2026-07-20 09:59:26.363877+00	2026-07-20 09:59:26.363877+00	a03a787d-b998-4a31-aa2e-2aef31ab5784	9827c403-87f1-46cd-875d-0796d77e64a1	\N	\N	تعطیلی رسمی	\N	holiday	2026-08-13 00:00:00+00	2026-08-13 01:00:00+00	t
b6cb4a19-c076-4b93-8d09-fdb709d87bc5	2026-07-20 09:59:26.363877+00	2026-07-20 09:59:26.363877+00	a03a787d-b998-4a31-aa2e-2aef31ab5784	487a4011-366a-4e1c-ac4d-6f24e62436c6	17bfb4bf-c4f1-4255-89ec-adba16e7232a	\N	جلسهٔ برنامه‌ریزی اسپرینت	\N	meeting	2026-06-17 10:00:00+00	2026-06-17 11:00:00+00	f
fe27fb43-4c06-4533-a8e1-505cb697448d	2026-07-20 09:59:26.363877+00	2026-07-20 09:59:26.363877+00	a03a787d-b998-4a31-aa2e-2aef31ab5784	3de0e871-5193-4e41-885f-531073da833a	3a0cafbb-bb8f-4904-bbf0-f2dfb0fc0f5b	\N	یادآوری پیگیری مشتری	\N	reminder	2026-06-17 00:00:00+00	2026-06-17 01:00:00+00	t
7c2d54ac-f1a0-4868-a154-405e76dfe3b9	2026-07-20 09:59:26.363877+00	2026-07-20 09:59:26.363877+00	a03a787d-b998-4a31-aa2e-2aef31ab5784	9827c403-87f1-46cd-875d-0796d77e64a1	\N	\N	تعطیلی رسمی	\N	holiday	2026-06-18 00:00:00+00	2026-06-18 01:00:00+00	t
e04fe98c-5619-461e-aaf5-6fc267a6a201	2026-07-20 09:59:26.363877+00	2026-07-20 09:59:26.363877+00	a03a787d-b998-4a31-aa2e-2aef31ab5784	487a4011-366a-4e1c-ac4d-6f24e62436c6	17bfb4bf-c4f1-4255-89ec-adba16e7232a	\N	جلسهٔ مرور با مدیریت	\N	meeting	2026-06-24 10:00:00+00	2026-06-24 11:00:00+00	f
782108f2-a75a-4b87-beaa-c96dba07d35b	2026-07-20 09:59:26.363877+00	2026-07-20 09:59:26.363877+00	a03a787d-b998-4a31-aa2e-2aef31ab5784	06467080-462f-4467-a2ac-577bc7c7dff6	3a0cafbb-bb8f-4904-bbf0-f2dfb0fc0f5b	\N	یادآوری پیگیری مشتری	\N	reminder	2026-06-26 00:00:00+00	2026-06-26 01:00:00+00	t
3572fdfd-2260-4242-ab23-43a48795d60b	2026-07-20 09:59:26.363877+00	2026-07-20 09:59:26.363877+00	a03a787d-b998-4a31-aa2e-2aef31ab5784	487a4011-366a-4e1c-ac4d-6f24e62436c6	17bfb4bf-c4f1-4255-89ec-adba16e7232a	\N	جلسهٔ مرور با مدیریت	\N	meeting	2026-07-02 10:00:00+00	2026-07-02 11:00:00+00	f
7454a520-6835-4d5b-8e76-2bbd0130e4ae	2026-07-20 09:59:26.363877+00	2026-07-20 09:59:26.363877+00	a03a787d-b998-4a31-aa2e-2aef31ab5784	fac1f37f-7665-4a91-b497-43238269a2e8	0997a305-ffa8-4263-8d7a-3d07622a211e	\N	یادآوری پیگیری مشتری	\N	reminder	2026-07-02 00:00:00+00	2026-07-02 01:00:00+00	t
54d508b7-2c1d-49f5-ba3c-5dd3a13e4371	2026-07-20 09:59:26.363877+00	2026-07-20 09:59:26.363877+00	a03a787d-b998-4a31-aa2e-2aef31ab5784	487a4011-366a-4e1c-ac4d-6f24e62436c6	0997a305-ffa8-4263-8d7a-3d07622a211e	\N	جلسهٔ بررسی پیشرفت پروژه	\N	meeting	2026-07-11 10:00:00+00	2026-07-11 11:00:00+00	f
c5040673-ec3c-4107-baad-8d04bcb8272a	2026-07-20 09:59:26.363877+00	2026-07-20 09:59:26.363877+00	a03a787d-b998-4a31-aa2e-2aef31ab5784	8eb048e0-49b1-4d8a-9e1f-ab534f5d1564	17bfb4bf-c4f1-4255-89ec-adba16e7232a	\N	یادآوری ارسال گزارش	\N	reminder	2026-07-13 00:00:00+00	2026-07-13 01:00:00+00	t
0ff649a0-a4da-4443-af62-2e49d80b1fce	2026-07-20 09:59:26.363877+00	2026-07-20 09:59:26.363877+00	a03a787d-b998-4a31-aa2e-2aef31ab5784	487a4011-366a-4e1c-ac4d-6f24e62436c6	17a90a26-1810-4dfa-b570-d013f4ee3a15	\N	جلسهٔ مرور با مدیریت	\N	meeting	2026-07-17 10:00:00+00	2026-07-17 11:00:00+00	f
a64946df-c40b-482d-8093-5b8c89c01e3a	2026-07-20 09:59:26.363877+00	2026-07-20 09:59:26.363877+00	a03a787d-b998-4a31-aa2e-2aef31ab5784	06467080-462f-4467-a2ac-577bc7c7dff6	0997a305-ffa8-4263-8d7a-3d07622a211e	\N	یادآوری تمدید قرارداد	\N	reminder	2026-07-15 00:00:00+00	2026-07-15 01:00:00+00	t
a2b0afba-e0b5-4dba-ba5f-6b98cd1b40a6	2026-07-20 09:59:26.363877+00	2026-07-20 09:59:26.363877+00	a03a787d-b998-4a31-aa2e-2aef31ab5784	9827c403-87f1-46cd-875d-0796d77e64a1	\N	\N	تعطیلی رسمی	\N	holiday	2026-07-16 00:00:00+00	2026-07-16 01:00:00+00	t
b97e5e2f-f52d-477c-8331-260e694ffbf2	2026-07-20 09:59:26.363877+00	2026-07-20 09:59:26.363877+00	a03a787d-b998-4a31-aa2e-2aef31ab5784	487a4011-366a-4e1c-ac4d-6f24e62436c6	0997a305-ffa8-4263-8d7a-3d07622a211e	\N	جلسهٔ مرور با مدیریت	\N	meeting	2026-07-24 10:00:00+00	2026-07-24 11:00:00+00	f
b1320c1c-4447-416f-8644-f0b89225707a	2026-07-20 09:59:26.363877+00	2026-07-20 09:59:26.363877+00	a03a787d-b998-4a31-aa2e-2aef31ab5784	929fcc10-abd5-4d94-9b84-fb05ba764ba0	17a90a26-1810-4dfa-b570-d013f4ee3a15	\N	یادآوری پیگیری مشتری	\N	reminder	2026-07-22 00:00:00+00	2026-07-22 01:00:00+00	t
64c2c506-9dd4-4efc-8656-c95b4ad40f3c	2026-07-20 09:59:26.363877+00	2026-07-20 09:59:26.363877+00	a03a787d-b998-4a31-aa2e-2aef31ab5784	487a4011-366a-4e1c-ac4d-6f24e62436c6	17bfb4bf-c4f1-4255-89ec-adba16e7232a	\N	جلسهٔ برنامه‌ریزی اسپرینت	\N	meeting	2026-07-31 10:00:00+00	2026-07-31 11:00:00+00	f
ff4b90b0-4284-4c38-adb1-fcd29249edfe	2026-07-20 09:59:26.363877+00	2026-07-20 09:59:26.363877+00	a03a787d-b998-4a31-aa2e-2aef31ab5784	48c7fe74-5692-42c1-9068-c52c071221e8	17a90a26-1810-4dfa-b570-d013f4ee3a15	\N	یادآوری ارسال گزارش	\N	reminder	2026-07-30 00:00:00+00	2026-07-30 01:00:00+00	t
06657bd4-9b63-4a47-be49-4683ebe29270	2026-07-20 09:59:26.363877+00	2026-07-20 09:59:26.363877+00	a03a787d-b998-4a31-aa2e-2aef31ab5784	487a4011-366a-4e1c-ac4d-6f24e62436c6	3a0cafbb-bb8f-4904-bbf0-f2dfb0fc0f5b	\N	جلسهٔ بررسی پیشرفت پروژه	\N	meeting	2026-08-04 10:00:00+00	2026-08-04 11:00:00+00	f
29fa5bbe-ddbe-44a0-9233-c0ba9f4d3687	2026-07-20 09:59:26.363877+00	2026-07-20 09:59:26.363877+00	a03a787d-b998-4a31-aa2e-2aef31ab5784	06467080-462f-4467-a2ac-577bc7c7dff6	17bfb4bf-c4f1-4255-89ec-adba16e7232a	\N	یادآوری تمدید قرارداد	\N	reminder	2026-08-04 00:00:00+00	2026-08-04 01:00:00+00	t
94ac8a81-e993-4a69-9e9c-a41f9079a93c	2026-07-20 09:59:26.363877+00	2026-07-20 09:59:26.363877+00	a03a787d-b998-4a31-aa2e-2aef31ab5784	487a4011-366a-4e1c-ac4d-6f24e62436c6	38b2f96b-aad2-4a1d-9d01-1cd7e9820c8e	\N	جلسهٔ برنامه‌ریزی اسپرینت	\N	meeting	2026-08-14 10:00:00+00	2026-08-14 11:00:00+00	f
3a7eb0dc-3619-4611-8ca9-47f82d3dbac2	2026-07-20 09:59:26.363877+00	2026-07-20 09:59:26.363877+00	a03a787d-b998-4a31-aa2e-2aef31ab5784	3de0e871-5193-4e41-885f-531073da833a	17bfb4bf-c4f1-4255-89ec-adba16e7232a	\N	یادآوری پیگیری مشتری	\N	reminder	2026-08-13 00:00:00+00	2026-08-13 01:00:00+00	t
9eef46df-a8f0-4b7e-8d73-98632b28c80c	2026-07-20 09:59:26.363877+00	2026-07-20 09:59:26.363877+00	a03a787d-b998-4a31-aa2e-2aef31ab5784	9827c403-87f1-46cd-875d-0796d77e64a1	\N	\N	تعطیلی رسمی	\N	holiday	2026-08-13 00:00:00+00	2026-08-13 01:00:00+00	t
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
3b06bb29-d642-4407-bf7b-2b4d67fe3d73	2026-07-20 09:59:26.363877+00	2026-07-20 09:59:26.363877+00	a03a787d-b998-4a31-aa2e-2aef31ab5784	1fd6e737-0c6b-49b7-841e-0f8a73d3c1a1	f4d62802-b855-4f52-8349-6643ab15df57	project_manager
5a11a460-8db5-4bf3-bd98-9e5613982d47	2026-07-20 09:59:26.363877+00	2026-07-20 09:59:26.363877+00	a03a787d-b998-4a31-aa2e-2aef31ab5784	842034d4-0d08-46e1-bdd9-05eec45bcffa	f4d62802-b855-4f52-8349-6643ab15df57	employee
a6216733-a153-4e58-b7f8-504b1701a7be	2026-07-20 09:59:26.363877+00	2026-07-20 09:59:26.363877+00	a03a787d-b998-4a31-aa2e-2aef31ab5784	be1819a8-75ce-4c92-8f50-3b2a8aa29e30	f4d62802-b855-4f52-8349-6643ab15df57	employee
b3841165-e365-4c6b-9314-c44a8aa2c9fe	2026-07-20 09:59:26.363877+00	2026-07-20 09:59:26.363877+00	a03a787d-b998-4a31-aa2e-2aef31ab5784	07e1c1ad-90c2-4b01-80d6-88ad81b6cc78	f4d62802-b855-4f52-8349-6643ab15df57	employee
650fd6e7-ce58-4a0f-89e3-6ab01a170315	2026-07-20 09:59:26.363877+00	2026-07-20 09:59:26.363877+00	a03a787d-b998-4a31-aa2e-2aef31ab5784	e5ed62a2-bd4a-46d5-a6c6-be866906977f	f4d62802-b855-4f52-8349-6643ab15df57	employee
fb87c479-0799-4165-9cf3-659237b2385e	2026-07-20 09:59:26.363877+00	2026-07-20 09:59:26.363877+00	a03a787d-b998-4a31-aa2e-2aef31ab5784	d6fc165d-7448-431b-af51-26d9bb7751a1	f4d62802-b855-4f52-8349-6643ab15df57	employee
653f106d-7bdd-4350-a128-cb88203350b8	2026-07-20 09:59:26.363877+00	2026-07-20 09:59:26.363877+00	a03a787d-b998-4a31-aa2e-2aef31ab5784	b0bcd30d-df04-4c14-bdf8-7923f39ea52e	f4d62802-b855-4f52-8349-6643ab15df57	employee
168ecf05-8fdd-4572-87b1-6ab921f405c3	2026-07-20 09:59:26.363877+00	2026-07-20 09:59:26.363877+00	a03a787d-b998-4a31-aa2e-2aef31ab5784	328fce4c-c7e7-4b44-8dcb-45aad65bd8e5	bfceb7aa-5547-4d7c-a828-f73ac786de5a	project_manager
b443e4c6-a1b7-4757-bebe-887dd2071f2a	2026-07-20 09:59:26.363877+00	2026-07-20 09:59:26.363877+00	a03a787d-b998-4a31-aa2e-2aef31ab5784	1775df44-8335-487a-9a3b-a1a6eb5949f5	bfceb7aa-5547-4d7c-a828-f73ac786de5a	employee
68b7ed01-c13a-4f36-ab57-780b5e94c362	2026-07-20 09:59:26.363877+00	2026-07-20 09:59:26.363877+00	a03a787d-b998-4a31-aa2e-2aef31ab5784	c1eff56a-cf6f-4901-9c44-9063f53db8c8	bfceb7aa-5547-4d7c-a828-f73ac786de5a	employee
866fe1ee-4203-4345-9e68-1d1c856f5d82	2026-07-20 09:59:26.363877+00	2026-07-20 09:59:26.363877+00	a03a787d-b998-4a31-aa2e-2aef31ab5784	9c22bc65-2479-4780-b3a0-0ed5e139ee5f	bfceb7aa-5547-4d7c-a828-f73ac786de5a	employee
03c913a3-cf63-4aee-a25b-56ac3ced8457	2026-07-20 09:59:26.363877+00	2026-07-20 09:59:26.363877+00	a03a787d-b998-4a31-aa2e-2aef31ab5784	767b011b-ff3a-4faf-b85b-c424554a44a0	bfceb7aa-5547-4d7c-a828-f73ac786de5a	employee
dc689276-384a-4144-a49a-65d992090864	2026-07-20 09:59:26.363877+00	2026-07-20 09:59:26.363877+00	a03a787d-b998-4a31-aa2e-2aef31ab5784	f2917b41-6f1c-4444-a73d-884a91e847fe	bfceb7aa-5547-4d7c-a828-f73ac786de5a	employee
5483f5bf-5345-4b54-a384-1fe25b177a16	2026-07-20 09:59:26.363877+00	2026-07-20 09:59:26.363877+00	a03a787d-b998-4a31-aa2e-2aef31ab5784	276feb60-37b2-42ff-be39-f9e79af8ae2a	bfceb7aa-5547-4d7c-a828-f73ac786de5a	employee
7bb951c7-81f8-4b47-89eb-b5634e1576b5	2026-07-20 09:59:26.363877+00	2026-07-20 09:59:26.363877+00	a03a787d-b998-4a31-aa2e-2aef31ab5784	487a4011-366a-4e1c-ac4d-6f24e62436c6	40f20b30-be21-4dbc-bf5d-2461e3328527	project_manager
b8696939-e3b1-4df4-840b-bb2ad8ca0c8c	2026-07-20 09:59:26.363877+00	2026-07-20 09:59:26.363877+00	a03a787d-b998-4a31-aa2e-2aef31ab5784	8eb048e0-49b1-4d8a-9e1f-ab534f5d1564	40f20b30-be21-4dbc-bf5d-2461e3328527	employee
fd36aa4b-1bfe-43db-be9f-a239a4e69487	2026-07-20 09:59:26.363877+00	2026-07-20 09:59:26.363877+00	a03a787d-b998-4a31-aa2e-2aef31ab5784	06467080-462f-4467-a2ac-577bc7c7dff6	40f20b30-be21-4dbc-bf5d-2461e3328527	employee
c4874598-703b-4593-b023-b6d2f5707e4c	2026-07-20 09:59:26.363877+00	2026-07-20 09:59:26.363877+00	a03a787d-b998-4a31-aa2e-2aef31ab5784	3de0e871-5193-4e41-885f-531073da833a	40f20b30-be21-4dbc-bf5d-2461e3328527	employee
3438cc3f-6904-4a31-b238-0bdba5d0a3ce	2026-07-20 09:59:26.363877+00	2026-07-20 09:59:26.363877+00	a03a787d-b998-4a31-aa2e-2aef31ab5784	fac1f37f-7665-4a91-b497-43238269a2e8	40f20b30-be21-4dbc-bf5d-2461e3328527	employee
781832b0-8f05-449d-8f37-f2c1045dc2a6	2026-07-20 09:59:26.363877+00	2026-07-20 09:59:26.363877+00	a03a787d-b998-4a31-aa2e-2aef31ab5784	48c7fe74-5692-42c1-9068-c52c071221e8	40f20b30-be21-4dbc-bf5d-2461e3328527	employee
436e14a0-0f82-433b-9d77-238323bbe238	2026-07-20 09:59:26.363877+00	2026-07-20 09:59:26.363877+00	a03a787d-b998-4a31-aa2e-2aef31ab5784	929fcc10-abd5-4d94-9b84-fb05ba764ba0	40f20b30-be21-4dbc-bf5d-2461e3328527	employee
73c8ff64-3e65-4258-ac02-799bfc63ee46	2026-07-20 09:59:26.363877+00	2026-07-20 09:59:26.363877+00	a03a787d-b998-4a31-aa2e-2aef31ab5784	487a4011-366a-4e1c-ac4d-6f24e62436c6	f4d62802-b855-4f52-8349-6643ab15df57	employee
78a9218e-6c07-4a5f-a539-071ac30e664f	2026-07-20 09:59:26.363877+00	2026-07-20 09:59:26.363877+00	a03a787d-b998-4a31-aa2e-2aef31ab5784	842034d4-0d08-46e1-bdd9-05eec45bcffa	bfceb7aa-5547-4d7c-a828-f73ac786de5a	employee
\.


--
-- Data for Name: departments; Type: TABLE DATA; Schema: public; Owner: -
--

COPY public.departments (id, created_at, updated_at, organization_id, name) FROM stdin;
f4d62802-b855-4f52-8349-6643ab15df57	2026-07-20 09:59:26.363877+00	2026-07-20 09:59:26.363877+00	a03a787d-b998-4a31-aa2e-2aef31ab5784	مهندسی و فنی
bfceb7aa-5547-4d7c-a828-f73ac786de5a	2026-07-20 09:59:26.363877+00	2026-07-20 09:59:26.363877+00	a03a787d-b998-4a31-aa2e-2aef31ab5784	حسابداری و مالی
40f20b30-be21-4dbc-bf5d-2461e3328527	2026-07-20 09:59:26.363877+00	2026-07-20 09:59:26.363877+00	a03a787d-b998-4a31-aa2e-2aef31ab5784	منابع انسانی
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
شرکت نمونهٔ آزمایشی	demo-org-607682f8	t	a03a787d-b998-4a31-aa2e-2aef31ab5784	2026-07-20 09:59:26.363877+00	2026-07-20 09:59:26.363877+00
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
e47f5049-79ab-4a81-b5e4-d5e5b14eda2c	1fd6e737-0c6b-49b7-841e-0f8a73d3c1a1	4ec9014a-132b-4a10-9bbe-ca9500fb5f60	2026-07-20 09:59:26.363877+00	2026-07-20 09:59:26.363877+00
e47f5049-79ab-4a81-b5e4-d5e5b14eda2c	b0bcd30d-df04-4c14-bdf8-7923f39ea52e	c91f88e6-78f7-49ac-830c-a29152e5507f	2026-07-20 09:59:26.363877+00	2026-07-20 09:59:26.363877+00
e47f5049-79ab-4a81-b5e4-d5e5b14eda2c	842034d4-0d08-46e1-bdd9-05eec45bcffa	ccef1a9c-68f0-414d-8b00-ea100a611b67	2026-07-20 09:59:26.363877+00	2026-07-20 09:59:26.363877+00
e47f5049-79ab-4a81-b5e4-d5e5b14eda2c	d6fc165d-7448-431b-af51-26d9bb7751a1	51f59e26-1051-4378-ab4a-725bf318ec3a	2026-07-20 09:59:26.363877+00	2026-07-20 09:59:26.363877+00
b2f9aaf2-33f5-448b-8177-93cf8a2e2cda	1fd6e737-0c6b-49b7-841e-0f8a73d3c1a1	b5110005-33f9-4598-b9a8-b2cb854e841d	2026-07-20 09:59:26.363877+00	2026-07-20 09:59:26.363877+00
b2f9aaf2-33f5-448b-8177-93cf8a2e2cda	b0bcd30d-df04-4c14-bdf8-7923f39ea52e	e97316f9-8f01-4537-ad52-b095c296dad6	2026-07-20 09:59:26.363877+00	2026-07-20 09:59:26.363877+00
b2f9aaf2-33f5-448b-8177-93cf8a2e2cda	07e1c1ad-90c2-4b01-80d6-88ad81b6cc78	03795911-4df4-4c81-89a1-f0e03acfb8d5	2026-07-20 09:59:26.363877+00	2026-07-20 09:59:26.363877+00
b2f9aaf2-33f5-448b-8177-93cf8a2e2cda	be1819a8-75ce-4c92-8f50-3b2a8aa29e30	70c07db8-0c5e-4160-a6d9-4cd5f9fb4614	2026-07-20 09:59:26.363877+00	2026-07-20 09:59:26.363877+00
c52c73bc-c6d8-4e9b-a31c-7665a092eaa2	1fd6e737-0c6b-49b7-841e-0f8a73d3c1a1	b20a6f8b-d2ae-4d91-aecb-4245dbb8f19d	2026-07-20 09:59:26.363877+00	2026-07-20 09:59:26.363877+00
c52c73bc-c6d8-4e9b-a31c-7665a092eaa2	be1819a8-75ce-4c92-8f50-3b2a8aa29e30	c278ef16-2e89-4b03-bd3e-94d153f05bc4	2026-07-20 09:59:26.363877+00	2026-07-20 09:59:26.363877+00
c52c73bc-c6d8-4e9b-a31c-7665a092eaa2	b0bcd30d-df04-4c14-bdf8-7923f39ea52e	1d5cdc12-bfb8-4b65-b9b6-d79cdeed8b6f	2026-07-20 09:59:26.363877+00	2026-07-20 09:59:26.363877+00
c52c73bc-c6d8-4e9b-a31c-7665a092eaa2	842034d4-0d08-46e1-bdd9-05eec45bcffa	775eaf35-b930-4c9f-bab0-a702c99a9102	2026-07-20 09:59:26.363877+00	2026-07-20 09:59:26.363877+00
05099cdc-50af-4a51-810f-e8a374ef5665	1fd6e737-0c6b-49b7-841e-0f8a73d3c1a1	bf31445b-8ad8-4b38-bfcc-af389246de0f	2026-07-20 09:59:26.363877+00	2026-07-20 09:59:26.363877+00
05099cdc-50af-4a51-810f-e8a374ef5665	b0bcd30d-df04-4c14-bdf8-7923f39ea52e	0a145107-397f-41f9-bc7f-70fc1fb2ad1f	2026-07-20 09:59:26.363877+00	2026-07-20 09:59:26.363877+00
05099cdc-50af-4a51-810f-e8a374ef5665	d6fc165d-7448-431b-af51-26d9bb7751a1	049dd4ab-d7f6-4836-a67d-31f969f4bf55	2026-07-20 09:59:26.363877+00	2026-07-20 09:59:26.363877+00
05099cdc-50af-4a51-810f-e8a374ef5665	842034d4-0d08-46e1-bdd9-05eec45bcffa	b553295a-64cb-4135-9a71-532c7a37e7ff	2026-07-20 09:59:26.363877+00	2026-07-20 09:59:26.363877+00
5730191d-f4bd-43eb-90fc-18243ae04e10	1fd6e737-0c6b-49b7-841e-0f8a73d3c1a1	abbfc885-2af3-4c94-8842-920589095001	2026-07-20 09:59:26.363877+00	2026-07-20 09:59:26.363877+00
5730191d-f4bd-43eb-90fc-18243ae04e10	d6fc165d-7448-431b-af51-26d9bb7751a1	e28dc5b4-c7d7-4007-b652-5298bdb228c8	2026-07-20 09:59:26.363877+00	2026-07-20 09:59:26.363877+00
5730191d-f4bd-43eb-90fc-18243ae04e10	e5ed62a2-bd4a-46d5-a6c6-be866906977f	65e65682-de8f-4e62-90ec-be3eea0fd1c1	2026-07-20 09:59:26.363877+00	2026-07-20 09:59:26.363877+00
5730191d-f4bd-43eb-90fc-18243ae04e10	842034d4-0d08-46e1-bdd9-05eec45bcffa	441b94da-dd05-4545-8197-6b02a4f82974	2026-07-20 09:59:26.363877+00	2026-07-20 09:59:26.363877+00
d6f8a913-4870-4aa5-a45f-e9c04e17b7fc	328fce4c-c7e7-4b44-8dcb-45aad65bd8e5	8f3c4e4d-f36c-4fa1-84d9-1ce662f09911	2026-07-20 09:59:26.363877+00	2026-07-20 09:59:26.363877+00
d6f8a913-4870-4aa5-a45f-e9c04e17b7fc	9c22bc65-2479-4780-b3a0-0ed5e139ee5f	175c8ee0-5ec1-441a-a567-10da3e1eeacd	2026-07-20 09:59:26.363877+00	2026-07-20 09:59:26.363877+00
d6f8a913-4870-4aa5-a45f-e9c04e17b7fc	276feb60-37b2-42ff-be39-f9e79af8ae2a	646ab7a9-93c4-45c0-8420-411e54878076	2026-07-20 09:59:26.363877+00	2026-07-20 09:59:26.363877+00
d6f8a913-4870-4aa5-a45f-e9c04e17b7fc	767b011b-ff3a-4faf-b85b-c424554a44a0	44509483-d684-45ad-9a76-bf977d40f9e5	2026-07-20 09:59:26.363877+00	2026-07-20 09:59:26.363877+00
349ecde7-6ae3-4dbc-85ce-291df6cda967	328fce4c-c7e7-4b44-8dcb-45aad65bd8e5	2645fc7a-7fbd-4144-bfbf-5b40d3e917cc	2026-07-20 09:59:26.363877+00	2026-07-20 09:59:26.363877+00
349ecde7-6ae3-4dbc-85ce-291df6cda967	f2917b41-6f1c-4444-a73d-884a91e847fe	8a4047e4-a536-42f0-9826-0c7d6712872e	2026-07-20 09:59:26.363877+00	2026-07-20 09:59:26.363877+00
349ecde7-6ae3-4dbc-85ce-291df6cda967	767b011b-ff3a-4faf-b85b-c424554a44a0	6f523614-e278-487c-a51e-5f3ae71ace55	2026-07-20 09:59:26.363877+00	2026-07-20 09:59:26.363877+00
349ecde7-6ae3-4dbc-85ce-291df6cda967	9c22bc65-2479-4780-b3a0-0ed5e139ee5f	875010d0-49fc-42b1-a5d0-3b2a4c2a18a1	2026-07-20 09:59:26.363877+00	2026-07-20 09:59:26.363877+00
1fbf1e47-ab67-430d-841c-ca56a83c091e	328fce4c-c7e7-4b44-8dcb-45aad65bd8e5	9dd1df83-85a9-45bb-a98c-705930f63a2c	2026-07-20 09:59:26.363877+00	2026-07-20 09:59:26.363877+00
1fbf1e47-ab67-430d-841c-ca56a83c091e	1775df44-8335-487a-9a3b-a1a6eb5949f5	607c6462-8b50-4276-9755-939bf957cd06	2026-07-20 09:59:26.363877+00	2026-07-20 09:59:26.363877+00
1fbf1e47-ab67-430d-841c-ca56a83c091e	c1eff56a-cf6f-4901-9c44-9063f53db8c8	d2b2af75-3068-447a-af20-13230b7c3594	2026-07-20 09:59:26.363877+00	2026-07-20 09:59:26.363877+00
1fbf1e47-ab67-430d-841c-ca56a83c091e	9c22bc65-2479-4780-b3a0-0ed5e139ee5f	e0b0f854-d729-41c4-a3ec-1e28b05f4e91	2026-07-20 09:59:26.363877+00	2026-07-20 09:59:26.363877+00
718abbd9-dab5-433d-bd20-046f3974f6ef	328fce4c-c7e7-4b44-8dcb-45aad65bd8e5	33a6fcd6-54dc-4b38-b7a3-ee9d7c7a329d	2026-07-20 09:59:26.363877+00	2026-07-20 09:59:26.363877+00
718abbd9-dab5-433d-bd20-046f3974f6ef	9c22bc65-2479-4780-b3a0-0ed5e139ee5f	3d69d24f-4967-4c4b-81ea-8e9b65846440	2026-07-20 09:59:26.363877+00	2026-07-20 09:59:26.363877+00
718abbd9-dab5-433d-bd20-046f3974f6ef	1775df44-8335-487a-9a3b-a1a6eb5949f5	b2de9600-5771-4c04-aeac-55a61f7382f8	2026-07-20 09:59:26.363877+00	2026-07-20 09:59:26.363877+00
718abbd9-dab5-433d-bd20-046f3974f6ef	276feb60-37b2-42ff-be39-f9e79af8ae2a	0f21f13d-f4d4-4e04-ad54-1e489a37c62f	2026-07-20 09:59:26.363877+00	2026-07-20 09:59:26.363877+00
cb1c5120-3d84-4bc6-b309-5985dd7264ed	328fce4c-c7e7-4b44-8dcb-45aad65bd8e5	77112b25-2cfa-47c3-975a-bf6484b2a184	2026-07-20 09:59:26.363877+00	2026-07-20 09:59:26.363877+00
cb1c5120-3d84-4bc6-b309-5985dd7264ed	9c22bc65-2479-4780-b3a0-0ed5e139ee5f	03de68a8-db3c-40c8-9ac8-fb907139e9cb	2026-07-20 09:59:26.363877+00	2026-07-20 09:59:26.363877+00
cb1c5120-3d84-4bc6-b309-5985dd7264ed	1775df44-8335-487a-9a3b-a1a6eb5949f5	3191ea81-877c-4c49-abe4-4ad2ae4f630a	2026-07-20 09:59:26.363877+00	2026-07-20 09:59:26.363877+00
cb1c5120-3d84-4bc6-b309-5985dd7264ed	276feb60-37b2-42ff-be39-f9e79af8ae2a	dd8088e1-5794-4c45-811e-39b2d2b1d3f5	2026-07-20 09:59:26.363877+00	2026-07-20 09:59:26.363877+00
38b2f96b-aad2-4a1d-9d01-1cd7e9820c8e	487a4011-366a-4e1c-ac4d-6f24e62436c6	ef355079-f974-4070-a87e-a8c9f6abbecb	2026-07-20 09:59:26.363877+00	2026-07-20 09:59:26.363877+00
38b2f96b-aad2-4a1d-9d01-1cd7e9820c8e	8eb048e0-49b1-4d8a-9e1f-ab534f5d1564	bdf3de9e-07d6-4016-9096-c0eec09cae9b	2026-07-20 09:59:26.363877+00	2026-07-20 09:59:26.363877+00
38b2f96b-aad2-4a1d-9d01-1cd7e9820c8e	fac1f37f-7665-4a91-b497-43238269a2e8	dc313b3f-ceae-4ec9-9a33-5159f3f292c5	2026-07-20 09:59:26.363877+00	2026-07-20 09:59:26.363877+00
38b2f96b-aad2-4a1d-9d01-1cd7e9820c8e	3de0e871-5193-4e41-885f-531073da833a	83e8b90a-e16e-41c8-826d-3ef01910c894	2026-07-20 09:59:26.363877+00	2026-07-20 09:59:26.363877+00
0997a305-ffa8-4263-8d7a-3d07622a211e	487a4011-366a-4e1c-ac4d-6f24e62436c6	decfe4ce-916b-49e0-9e6b-37ff2ba81c7c	2026-07-20 09:59:26.363877+00	2026-07-20 09:59:26.363877+00
0997a305-ffa8-4263-8d7a-3d07622a211e	48c7fe74-5692-42c1-9068-c52c071221e8	de624a58-c7a2-4873-8e1a-54e1fb004fd1	2026-07-20 09:59:26.363877+00	2026-07-20 09:59:26.363877+00
0997a305-ffa8-4263-8d7a-3d07622a211e	06467080-462f-4467-a2ac-577bc7c7dff6	21ddbd5d-8dfa-42a1-b6c2-9f7a13a65309	2026-07-20 09:59:26.363877+00	2026-07-20 09:59:26.363877+00
0997a305-ffa8-4263-8d7a-3d07622a211e	929fcc10-abd5-4d94-9b84-fb05ba764ba0	c59fe25c-5bef-49e4-a10d-7b6e3f747751	2026-07-20 09:59:26.363877+00	2026-07-20 09:59:26.363877+00
17bfb4bf-c4f1-4255-89ec-adba16e7232a	487a4011-366a-4e1c-ac4d-6f24e62436c6	dc8e385b-2b76-458e-9486-8d332fecb15b	2026-07-20 09:59:26.363877+00	2026-07-20 09:59:26.363877+00
17bfb4bf-c4f1-4255-89ec-adba16e7232a	8eb048e0-49b1-4d8a-9e1f-ab534f5d1564	6a882d6a-b258-40fd-9884-40a9f2ec63ae	2026-07-20 09:59:26.363877+00	2026-07-20 09:59:26.363877+00
17bfb4bf-c4f1-4255-89ec-adba16e7232a	06467080-462f-4467-a2ac-577bc7c7dff6	1796cf95-0e27-458f-b2b8-ef12f9bf27b0	2026-07-20 09:59:26.363877+00	2026-07-20 09:59:26.363877+00
17bfb4bf-c4f1-4255-89ec-adba16e7232a	48c7fe74-5692-42c1-9068-c52c071221e8	b3439acb-43a0-485d-99dd-aff3eab4c055	2026-07-20 09:59:26.363877+00	2026-07-20 09:59:26.363877+00
3a0cafbb-bb8f-4904-bbf0-f2dfb0fc0f5b	487a4011-366a-4e1c-ac4d-6f24e62436c6	89a1e2b8-3d3c-49f3-9f63-8fef9456d103	2026-07-20 09:59:26.363877+00	2026-07-20 09:59:26.363877+00
3a0cafbb-bb8f-4904-bbf0-f2dfb0fc0f5b	3de0e871-5193-4e41-885f-531073da833a	8f0475a8-dca4-461a-ace8-f35c00191d62	2026-07-20 09:59:26.363877+00	2026-07-20 09:59:26.363877+00
3a0cafbb-bb8f-4904-bbf0-f2dfb0fc0f5b	48c7fe74-5692-42c1-9068-c52c071221e8	7c57d38e-3cb8-4dfe-943b-6ba69381a037	2026-07-20 09:59:26.363877+00	2026-07-20 09:59:26.363877+00
3a0cafbb-bb8f-4904-bbf0-f2dfb0fc0f5b	8eb048e0-49b1-4d8a-9e1f-ab534f5d1564	5e3d8d36-8146-40af-97cd-61513e9558a2	2026-07-20 09:59:26.363877+00	2026-07-20 09:59:26.363877+00
17a90a26-1810-4dfa-b570-d013f4ee3a15	487a4011-366a-4e1c-ac4d-6f24e62436c6	e00afbeb-17ef-484b-ab33-1fb41bc8520d	2026-07-20 09:59:26.363877+00	2026-07-20 09:59:26.363877+00
17a90a26-1810-4dfa-b570-d013f4ee3a15	06467080-462f-4467-a2ac-577bc7c7dff6	e4e01eff-ba98-45a0-b80c-741418f51c56	2026-07-20 09:59:26.363877+00	2026-07-20 09:59:26.363877+00
17a90a26-1810-4dfa-b570-d013f4ee3a15	48c7fe74-5692-42c1-9068-c52c071221e8	7199d0ff-a169-4305-8f83-af07754f0428	2026-07-20 09:59:26.363877+00	2026-07-20 09:59:26.363877+00
17a90a26-1810-4dfa-b570-d013f4ee3a15	fac1f37f-7665-4a91-b497-43238269a2e8	42d7c6db-129c-4948-873b-7244466b56b1	2026-07-20 09:59:26.363877+00	2026-07-20 09:59:26.363877+00
\.


--
-- Data for Name: projects; Type: TABLE DATA; Schema: public; Owner: -
--

COPY public.projects (organization_id, name, description, start_date, end_date, status, created_by_id, id, created_at, updated_at, manager_id, cooperation_start_date, department_id) FROM stdin;
a03a787d-b998-4a31-aa2e-2aef31ab5784	بازطراحی وب‌سایت شرکتی	پروژهٔ مهندسی و فنی شماره 1	2026-06-16	2026-10-14	active	9827c403-87f1-46cd-875d-0796d77e64a1	e47f5049-79ab-4a81-b5e4-d5e5b14eda2c	2026-07-20 09:59:26.363877+00	2026-07-20 09:59:26.363877+00	1fd6e737-0c6b-49b7-841e-0f8a73d3c1a1	2026-06-16	f4d62802-b855-4f52-8349-6643ab15df57
a03a787d-b998-4a31-aa2e-2aef31ab5784	توسعهٔ اپلیکیشن موبایل فروش	پروژهٔ مهندسی و فنی شماره 2	2026-06-16	2026-10-14	active	9827c403-87f1-46cd-875d-0796d77e64a1	b2f9aaf2-33f5-448b-8177-93cf8a2e2cda	2026-07-20 09:59:26.363877+00	2026-07-20 09:59:26.363877+00	1fd6e737-0c6b-49b7-841e-0f8a73d3c1a1	2026-06-16	f4d62802-b855-4f52-8349-6643ab15df57
a03a787d-b998-4a31-aa2e-2aef31ab5784	مهاجرت زیرساخت به ابر	پروژهٔ مهندسی و فنی شماره 3	2026-06-16	2026-10-14	active	9827c403-87f1-46cd-875d-0796d77e64a1	c52c73bc-c6d8-4e9b-a31c-7665a092eaa2	2026-07-20 09:59:26.363877+00	2026-07-20 09:59:26.363877+00	1fd6e737-0c6b-49b7-841e-0f8a73d3c1a1	2026-06-16	f4d62802-b855-4f52-8349-6643ab15df57
a03a787d-b998-4a31-aa2e-2aef31ab5784	پیاده‌سازی سامانهٔ مانیتورینگ	پروژهٔ مهندسی و فنی شماره 4	2026-06-16	2026-10-14	active	9827c403-87f1-46cd-875d-0796d77e64a1	05099cdc-50af-4a51-810f-e8a374ef5665	2026-07-20 09:59:26.363877+00	2026-07-20 09:59:26.363877+00	1fd6e737-0c6b-49b7-841e-0f8a73d3c1a1	2026-06-16	f4d62802-b855-4f52-8349-6643ab15df57
a03a787d-b998-4a31-aa2e-2aef31ab5784	بهبود عملکرد پایگاه‌داده	پروژهٔ مهندسی و فنی شماره 5	2026-06-16	2026-10-14	active	9827c403-87f1-46cd-875d-0796d77e64a1	5730191d-f4bd-43eb-90fc-18243ae04e10	2026-07-20 09:59:26.363877+00	2026-07-20 09:59:26.363877+00	1fd6e737-0c6b-49b7-841e-0f8a73d3c1a1	2026-06-16	f4d62802-b855-4f52-8349-6643ab15df57
a03a787d-b998-4a31-aa2e-2aef31ab5784	بستن حساب‌های مالی سال	پروژهٔ حسابداری و مالی شماره 1	2026-06-16	2026-10-14	active	9827c403-87f1-46cd-875d-0796d77e64a1	d6f8a913-4870-4aa5-a45f-e9c04e17b7fc	2026-07-20 09:59:26.363877+00	2026-07-20 09:59:26.363877+00	328fce4c-c7e7-4b44-8dcb-45aad65bd8e5	2026-06-16	bfceb7aa-5547-4d7c-a828-f73ac786de5a
a03a787d-b998-4a31-aa2e-2aef31ab5784	پیاده‌سازی سامانهٔ فاکتور الکترونیک	پروژهٔ حسابداری و مالی شماره 2	2026-06-16	2026-10-14	active	9827c403-87f1-46cd-875d-0796d77e64a1	349ecde7-6ae3-4dbc-85ce-291df6cda967	2026-07-20 09:59:26.363877+00	2026-07-20 09:59:26.363877+00	328fce4c-c7e7-4b44-8dcb-45aad65bd8e5	2026-06-16	bfceb7aa-5547-4d7c-a828-f73ac786de5a
a03a787d-b998-4a31-aa2e-2aef31ab5784	ممیزی مالی سه‌ماههٔ دوم	پروژهٔ حسابداری و مالی شماره 3	2026-06-16	2026-10-14	active	9827c403-87f1-46cd-875d-0796d77e64a1	1fbf1e47-ab67-430d-841c-ca56a83c091e	2026-07-20 09:59:26.363877+00	2026-07-20 09:59:26.363877+00	328fce4c-c7e7-4b44-8dcb-45aad65bd8e5	2026-06-16	bfceb7aa-5547-4d7c-a828-f73ac786de5a
a03a787d-b998-4a31-aa2e-2aef31ab5784	تدوین بودجهٔ سال آینده	پروژهٔ حسابداری و مالی شماره 4	2026-06-16	2026-10-14	active	9827c403-87f1-46cd-875d-0796d77e64a1	718abbd9-dab5-433d-bd20-046f3974f6ef	2026-07-20 09:59:26.363877+00	2026-07-20 09:59:26.363877+00	328fce4c-c7e7-4b44-8dcb-45aad65bd8e5	2026-06-16	bfceb7aa-5547-4d7c-a828-f73ac786de5a
a03a787d-b998-4a31-aa2e-2aef31ab5784	مدیریت مطالبات و بدهی‌ها	پروژهٔ حسابداری و مالی شماره 5	2026-06-16	2026-10-14	active	9827c403-87f1-46cd-875d-0796d77e64a1	cb1c5120-3d84-4bc6-b309-5985dd7264ed	2026-07-20 09:59:26.363877+00	2026-07-20 09:59:26.363877+00	328fce4c-c7e7-4b44-8dcb-45aad65bd8e5	2026-06-16	bfceb7aa-5547-4d7c-a828-f73ac786de5a
a03a787d-b998-4a31-aa2e-2aef31ab5784	برگزاری دورهٔ آموزشی کارکنان	پروژهٔ منابع انسانی شماره 1	2026-06-16	2026-10-14	active	9827c403-87f1-46cd-875d-0796d77e64a1	38b2f96b-aad2-4a1d-9d01-1cd7e9820c8e	2026-07-20 09:59:26.363877+00	2026-07-20 09:59:26.363877+00	487a4011-366a-4e1c-ac4d-6f24e62436c6	2026-06-16	40f20b30-be21-4dbc-bf5d-2461e3328527
a03a787d-b998-4a31-aa2e-2aef31ab5784	بازطراحی فرایند جذب و استخدام	پروژهٔ منابع انسانی شماره 2	2026-06-16	2026-10-14	active	9827c403-87f1-46cd-875d-0796d77e64a1	0997a305-ffa8-4263-8d7a-3d07622a211e	2026-07-20 09:59:26.363877+00	2026-07-20 09:59:26.363877+00	487a4011-366a-4e1c-ac4d-6f24e62436c6	2026-06-16	40f20b30-be21-4dbc-bf5d-2461e3328527
a03a787d-b998-4a31-aa2e-2aef31ab5784	ارزیابی عملکرد سالانهٔ کارکنان	پروژهٔ منابع انسانی شماره 3	2026-06-16	2026-10-14	active	9827c403-87f1-46cd-875d-0796d77e64a1	17bfb4bf-c4f1-4255-89ec-adba16e7232a	2026-07-20 09:59:26.363877+00	2026-07-20 09:59:26.363877+00	487a4011-366a-4e1c-ac4d-6f24e62436c6	2026-06-16	40f20b30-be21-4dbc-bf5d-2461e3328527
a03a787d-b998-4a31-aa2e-2aef31ab5784	طراحی برنامهٔ رفاهی کارکنان	پروژهٔ منابع انسانی شماره 4	2026-06-16	2026-10-14	active	9827c403-87f1-46cd-875d-0796d77e64a1	3a0cafbb-bb8f-4904-bbf0-f2dfb0fc0f5b	2026-07-20 09:59:26.363877+00	2026-07-20 09:59:26.363877+00	487a4011-366a-4e1c-ac4d-6f24e62436c6	2026-06-16	40f20b30-be21-4dbc-bf5d-2461e3328527
a03a787d-b998-4a31-aa2e-2aef31ab5784	پیاده‌سازی سامانهٔ حضور و غیاب	پروژهٔ منابع انسانی شماره 5	2026-06-16	2026-10-14	active	9827c403-87f1-46cd-875d-0796d77e64a1	17a90a26-1810-4dfa-b570-d013f4ee3a15	2026-07-20 09:59:26.363877+00	2026-07-20 09:59:26.363877+00	487a4011-366a-4e1c-ac4d-6f24e62436c6	2026-06-16	40f20b30-be21-4dbc-bf5d-2461e3328527
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
a03a787d-b998-4a31-aa2e-2aef31ab5784	e47f5049-79ab-4a81-b5e4-d5e5b14eda2c	\N	1fd6e737-0c6b-49b7-841e-0f8a73d3c1a1	1fd6e737-0c6b-49b7-841e-0f8a73d3c1a1	به‌روزرسانی کتابخانه‌های وابسته #1	\N	high	2026-07-08	1f164ccf-c6e9-4520-85a8-da94c937f74b	2026-07-20 09:59:26.363877+00	2026-07-20 09:59:26.363877+00	todo	\N	3	23.30	2026-06-29
a03a787d-b998-4a31-aa2e-2aef31ab5784	e47f5049-79ab-4a81-b5e4-d5e5b14eda2c	\N	d6fc165d-7448-431b-af51-26d9bb7751a1	1fd6e737-0c6b-49b7-841e-0f8a73d3c1a1	بررسی و رفع آسیب‌پذیری امنیتی #2	\N	high	2026-07-21	7338d11b-7d86-4e3f-b24a-6bb8af79486b	2026-07-20 09:59:26.363877+00	2026-07-20 09:59:26.363877+00	completed	pending	100	12.60	2026-07-12
a03a787d-b998-4a31-aa2e-2aef31ab5784	e47f5049-79ab-4a81-b5e4-d5e5b14eda2c	\N	b0bcd30d-df04-4c14-bdf8-7923f39ea52e	1fd6e737-0c6b-49b7-841e-0f8a73d3c1a1	نوشتن مستندات فنی API #3	\N	medium	2026-08-10	cebb2c32-6fa0-4277-bc9b-dc60e404288d	2026-07-20 09:59:26.363877+00	2026-07-20 09:59:26.363877+00	todo	\N	43	12.60	2026-08-03
a03a787d-b998-4a31-aa2e-2aef31ab5784	e47f5049-79ab-4a81-b5e4-d5e5b14eda2c	\N	842034d4-0d08-46e1-bdd9-05eec45bcffa	1fd6e737-0c6b-49b7-841e-0f8a73d3c1a1	پیاده‌سازی صفحهٔ ورود جدید #4	\N	medium	2026-07-12	66eb5e95-b634-46a7-98d5-ed8b6fe49e51	2026-07-20 09:59:26.363877+00	2026-07-20 09:59:26.363877+00	archived	\N	12	15.60	2026-07-07
a03a787d-b998-4a31-aa2e-2aef31ab5784	e47f5049-79ab-4a81-b5e4-d5e5b14eda2c	\N	be1819a8-75ce-4c92-8f50-3b2a8aa29e30	1fd6e737-0c6b-49b7-841e-0f8a73d3c1a1	به‌روزرسانی کتابخانه‌های وابسته #5	\N	low	2026-07-04	9a8b5087-3afd-4d63-8c58-be3409ac1003	2026-07-20 09:59:26.363877+00	2026-07-20 09:59:26.363877+00	completed	approved	100	39.00	2026-06-18
a03a787d-b998-4a31-aa2e-2aef31ab5784	e47f5049-79ab-4a81-b5e4-d5e5b14eda2c	\N	07e1c1ad-90c2-4b01-80d6-88ad81b6cc78	1fd6e737-0c6b-49b7-841e-0f8a73d3c1a1	بازنویسی ماژول اعلان‌ها #6	\N	high	2026-08-01	b93b7a9d-d950-4f04-a14c-ec4271ea70d7	2026-07-20 09:59:26.363877+00	2026-07-20 09:59:26.363877+00	todo	\N	79	35.60	2026-07-21
a03a787d-b998-4a31-aa2e-2aef31ab5784	e47f5049-79ab-4a81-b5e4-d5e5b14eda2c	\N	be1819a8-75ce-4c92-8f50-3b2a8aa29e30	1fd6e737-0c6b-49b7-841e-0f8a73d3c1a1	تنظیم پایپ‌لاین CI/CD #7	\N	low	2026-06-23	d9f10ef0-42cc-4368-b84d-e140b3d4d06c	2026-07-20 09:59:26.363877+00	2026-07-20 09:59:26.363877+00	completed	approved	100	31.40	2026-06-20
a03a787d-b998-4a31-aa2e-2aef31ab5784	e47f5049-79ab-4a81-b5e4-d5e5b14eda2c	\N	1fd6e737-0c6b-49b7-841e-0f8a73d3c1a1	1fd6e737-0c6b-49b7-841e-0f8a73d3c1a1	پیاده‌سازی احراز هویت دومرحله‌ای #8	\N	medium	2026-08-15	5d9ac457-0cd7-4b15-afc1-b268902ca34e	2026-07-20 09:59:26.363877+00	2026-07-20 09:59:26.363877+00	in_progress	\N	58	26.20	2026-08-10
a03a787d-b998-4a31-aa2e-2aef31ab5784	e47f5049-79ab-4a81-b5e4-d5e5b14eda2c	\N	be1819a8-75ce-4c92-8f50-3b2a8aa29e30	1fd6e737-0c6b-49b7-841e-0f8a73d3c1a1	افزودن تست واحد برای سرویس کاربران #9	\N	high	2026-07-22	9de91469-8cac-4411-9c91-c9af374cffa6	2026-07-20 09:59:26.363877+00	2026-07-20 09:59:26.363877+00	todo	\N	34	28.70	2026-07-09
a03a787d-b998-4a31-aa2e-2aef31ab5784	e47f5049-79ab-4a81-b5e4-d5e5b14eda2c	\N	d6fc165d-7448-431b-af51-26d9bb7751a1	1fd6e737-0c6b-49b7-841e-0f8a73d3c1a1	به‌روزرسانی کتابخانه‌های وابسته #10	\N	high	2026-08-02	6dcf9705-665e-48c4-9a55-9612d8c0040b	2026-07-20 09:59:26.363877+00	2026-07-20 09:59:26.363877+00	completed	approved	100	11.30	2026-07-26
a03a787d-b998-4a31-aa2e-2aef31ab5784	e47f5049-79ab-4a81-b5e4-d5e5b14eda2c	\N	07e1c1ad-90c2-4b01-80d6-88ad81b6cc78	1fd6e737-0c6b-49b7-841e-0f8a73d3c1a1	افزودن تست واحد برای سرویس کاربران #11	\N	high	2026-07-22	a5984b9d-706c-47dd-900a-f62839c46d02	2026-07-20 09:59:26.363877+00	2026-07-20 09:59:26.363877+00	in_progress	\N	41	34.00	2026-07-03
a03a787d-b998-4a31-aa2e-2aef31ab5784	e47f5049-79ab-4a81-b5e4-d5e5b14eda2c	\N	b0bcd30d-df04-4c14-bdf8-7923f39ea52e	1fd6e737-0c6b-49b7-841e-0f8a73d3c1a1	رفع مشکل ناسازگاری مرورگر #12	\N	medium	2026-07-03	37edcfbc-8df2-4fed-87ea-3a14ec1d850d	2026-07-20 09:59:26.363877+00	2026-07-20 09:59:26.363877+00	todo	\N	51	12.20	2026-06-30
a03a787d-b998-4a31-aa2e-2aef31ab5784	e47f5049-79ab-4a81-b5e4-d5e5b14eda2c	\N	842034d4-0d08-46e1-bdd9-05eec45bcffa	1fd6e737-0c6b-49b7-841e-0f8a73d3c1a1	تنظیم پایپ‌لاین CI/CD #13	\N	medium	2026-07-14	ab088a6f-2a7e-42df-8f86-aec1612a3c47	2026-07-20 09:59:26.363877+00	2026-07-20 09:59:26.363877+00	completed	pending	100	17.00	2026-07-06
a03a787d-b998-4a31-aa2e-2aef31ab5784	e47f5049-79ab-4a81-b5e4-d5e5b14eda2c	\N	d6fc165d-7448-431b-af51-26d9bb7751a1	1fd6e737-0c6b-49b7-841e-0f8a73d3c1a1	نوشتن مستندات فنی API #14	\N	high	2026-07-03	2ae6a384-be09-4166-9550-79109f742e58	2026-07-20 09:59:26.363877+00	2026-07-20 09:59:26.363877+00	completed	approved	100	22.50	2026-06-24
a03a787d-b998-4a31-aa2e-2aef31ab5784	e47f5049-79ab-4a81-b5e4-d5e5b14eda2c	\N	d6fc165d-7448-431b-af51-26d9bb7751a1	1fd6e737-0c6b-49b7-841e-0f8a73d3c1a1	رفع مشکل کندی بارگذاری صفحه #15	\N	low	2026-08-06	c9432a30-9f31-4fc2-a4f2-ca267097ca48	2026-07-20 09:59:26.363877+00	2026-07-20 09:59:26.363877+00	completed	approved	100	39.90	2026-07-23
a03a787d-b998-4a31-aa2e-2aef31ab5784	e47f5049-79ab-4a81-b5e4-d5e5b14eda2c	\N	842034d4-0d08-46e1-bdd9-05eec45bcffa	1fd6e737-0c6b-49b7-841e-0f8a73d3c1a1	بازنویسی ماژول اعلان‌ها #16	\N	low	2026-08-06	60b13366-60ed-41c5-912e-7d347f99a3ef	2026-07-20 09:59:26.363877+00	2026-07-20 09:59:26.363877+00	completed	approved	100	7.80	2026-08-03
a03a787d-b998-4a31-aa2e-2aef31ab5784	e47f5049-79ab-4a81-b5e4-d5e5b14eda2c	\N	842034d4-0d08-46e1-bdd9-05eec45bcffa	1fd6e737-0c6b-49b7-841e-0f8a73d3c1a1	پیاده‌سازی احراز هویت دومرحله‌ای #17	\N	high	2026-07-04	313d57ec-292f-4200-bd27-3c855097e8e5	2026-07-20 09:59:26.363877+00	2026-07-20 09:59:26.363877+00	completed	approved	100	39.90	2026-06-20
a03a787d-b998-4a31-aa2e-2aef31ab5784	e47f5049-79ab-4a81-b5e4-d5e5b14eda2c	\N	e5ed62a2-bd4a-46d5-a6c6-be866906977f	1fd6e737-0c6b-49b7-841e-0f8a73d3c1a1	تنظیم پایپ‌لاین CI/CD #18	\N	high	2026-07-23	1e2d78aa-e6f9-47cc-82fc-f76233a6e12b	2026-07-20 09:59:26.363877+00	2026-07-20 09:59:26.363877+00	in_progress	\N	14	27.90	2026-07-21
a03a787d-b998-4a31-aa2e-2aef31ab5784	b2f9aaf2-33f5-448b-8177-93cf8a2e2cda	\N	e5ed62a2-bd4a-46d5-a6c6-be866906977f	1fd6e737-0c6b-49b7-841e-0f8a73d3c1a1	پیاده‌سازی صفحهٔ ورود جدید #19	\N	medium	2026-07-15	9415daf5-6d23-4fa7-a52b-90efc8de35e9	2026-07-20 09:59:26.363877+00	2026-07-20 09:59:26.363877+00	archived	\N	55	8.00	2026-07-03
a03a787d-b998-4a31-aa2e-2aef31ab5784	b2f9aaf2-33f5-448b-8177-93cf8a2e2cda	\N	1fd6e737-0c6b-49b7-841e-0f8a73d3c1a1	1fd6e737-0c6b-49b7-841e-0f8a73d3c1a1	به‌روزرسانی کتابخانه‌های وابسته #20	\N	low	2026-08-21	2430602e-8986-465b-8756-10b51693b5bb	2026-07-20 09:59:26.363877+00	2026-07-20 09:59:26.363877+00	archived	\N	64	36.70	2026-08-11
a03a787d-b998-4a31-aa2e-2aef31ab5784	b2f9aaf2-33f5-448b-8177-93cf8a2e2cda	\N	b0bcd30d-df04-4c14-bdf8-7923f39ea52e	1fd6e737-0c6b-49b7-841e-0f8a73d3c1a1	پیاده‌سازی صفحهٔ داشبورد مدیریتی #21	\N	low	2026-08-13	50bff075-48a2-4a6e-939c-67237f134a68	2026-07-20 09:59:26.363877+00	2026-07-20 09:59:26.363877+00	completed	approved	100	7.80	2026-07-26
a03a787d-b998-4a31-aa2e-2aef31ab5784	b2f9aaf2-33f5-448b-8177-93cf8a2e2cda	\N	b0bcd30d-df04-4c14-bdf8-7923f39ea52e	1fd6e737-0c6b-49b7-841e-0f8a73d3c1a1	افزودن قابلیت جست‌وجوی پیشرفته #22	\N	low	2026-08-07	b3b09fa6-fa4c-44d3-916c-9a7ee9898e6f	2026-07-20 09:59:26.363877+00	2026-07-20 09:59:26.363877+00	todo	\N	76	14.30	2026-07-20
a03a787d-b998-4a31-aa2e-2aef31ab5784	b2f9aaf2-33f5-448b-8177-93cf8a2e2cda	\N	1fd6e737-0c6b-49b7-841e-0f8a73d3c1a1	1fd6e737-0c6b-49b7-841e-0f8a73d3c1a1	افزودن قابلیت جست‌وجوی پیشرفته #23	\N	medium	2026-08-27	6d150b7a-8958-41ae-9315-c582b242b40a	2026-07-20 09:59:26.363877+00	2026-07-20 09:59:26.363877+00	todo	\N	30	4.20	2026-08-14
a03a787d-b998-4a31-aa2e-2aef31ab5784	b2f9aaf2-33f5-448b-8177-93cf8a2e2cda	\N	e5ed62a2-bd4a-46d5-a6c6-be866906977f	1fd6e737-0c6b-49b7-841e-0f8a73d3c1a1	بازنویسی ماژول اعلان‌ها #24	\N	low	2026-07-08	a06dde71-f601-4dc0-b2ca-a5c7bf662409	2026-07-20 09:59:26.363877+00	2026-07-20 09:59:26.363877+00	todo	\N	68	31.10	2026-06-21
a03a787d-b998-4a31-aa2e-2aef31ab5784	b2f9aaf2-33f5-448b-8177-93cf8a2e2cda	\N	842034d4-0d08-46e1-bdd9-05eec45bcffa	1fd6e737-0c6b-49b7-841e-0f8a73d3c1a1	طراحی API نسخهٔ دوم #25	\N	high	2026-07-28	c397957b-61cb-4435-862a-d2667d41289a	2026-07-20 09:59:26.363877+00	2026-07-20 09:59:26.363877+00	completed	approved	100	35.20	2026-07-21
a03a787d-b998-4a31-aa2e-2aef31ab5784	b2f9aaf2-33f5-448b-8177-93cf8a2e2cda	\N	07e1c1ad-90c2-4b01-80d6-88ad81b6cc78	1fd6e737-0c6b-49b7-841e-0f8a73d3c1a1	رفع مشکل ناسازگاری مرورگر #26	\N	high	2026-09-02	c0517833-8f26-4cca-b174-3840fc2d6c7c	2026-07-20 09:59:26.363877+00	2026-07-20 09:59:26.363877+00	in_progress	\N	25	29.10	2026-08-14
a03a787d-b998-4a31-aa2e-2aef31ab5784	b2f9aaf2-33f5-448b-8177-93cf8a2e2cda	\N	07e1c1ad-90c2-4b01-80d6-88ad81b6cc78	1fd6e737-0c6b-49b7-841e-0f8a73d3c1a1	بررسی و رفع آسیب‌پذیری امنیتی #27	\N	low	2026-08-01	72d9f497-52ed-4a58-91c6-bb0eb11a6c4d	2026-07-20 09:59:26.363877+00	2026-07-20 09:59:26.363877+00	completed	pending	100	11.40	2026-07-14
a03a787d-b998-4a31-aa2e-2aef31ab5784	b2f9aaf2-33f5-448b-8177-93cf8a2e2cda	\N	1fd6e737-0c6b-49b7-841e-0f8a73d3c1a1	1fd6e737-0c6b-49b7-841e-0f8a73d3c1a1	به‌روزرسانی کتابخانه‌های وابسته #28	\N	low	2026-07-07	9f23e451-3203-4580-8afd-91a1b3785c0f	2026-07-20 09:59:26.363877+00	2026-07-20 09:59:26.363877+00	in_progress	\N	75	10.40	2026-06-17
a03a787d-b998-4a31-aa2e-2aef31ab5784	b2f9aaf2-33f5-448b-8177-93cf8a2e2cda	\N	1fd6e737-0c6b-49b7-841e-0f8a73d3c1a1	1fd6e737-0c6b-49b7-841e-0f8a73d3c1a1	افزودن تست واحد برای سرویس کاربران #29	\N	low	2026-07-29	c80af628-a8f8-4996-b098-7b3fd4556593	2026-07-20 09:59:26.363877+00	2026-07-20 09:59:26.363877+00	archived	\N	4	34.70	2026-07-26
a03a787d-b998-4a31-aa2e-2aef31ab5784	b2f9aaf2-33f5-448b-8177-93cf8a2e2cda	\N	1fd6e737-0c6b-49b7-841e-0f8a73d3c1a1	1fd6e737-0c6b-49b7-841e-0f8a73d3c1a1	افزودن تست واحد برای سرویس کاربران #30	\N	high	2026-08-14	db23344f-538d-4c6c-b596-cd981afcb812	2026-07-20 09:59:26.363877+00	2026-07-20 09:59:26.363877+00	completed	approved	100	7.00	2026-07-28
a03a787d-b998-4a31-aa2e-2aef31ab5784	b2f9aaf2-33f5-448b-8177-93cf8a2e2cda	\N	e5ed62a2-bd4a-46d5-a6c6-be866906977f	1fd6e737-0c6b-49b7-841e-0f8a73d3c1a1	رفع مشکل ناسازگاری مرورگر #31	\N	medium	2026-08-22	df24183a-c61b-416d-baac-2dda67567e02	2026-07-20 09:59:26.363877+00	2026-07-20 09:59:26.363877+00	completed	approved	100	9.20	2026-08-05
a03a787d-b998-4a31-aa2e-2aef31ab5784	b2f9aaf2-33f5-448b-8177-93cf8a2e2cda	\N	1fd6e737-0c6b-49b7-841e-0f8a73d3c1a1	1fd6e737-0c6b-49b7-841e-0f8a73d3c1a1	بررسی و رفع آسیب‌پذیری امنیتی #32	\N	high	2026-07-28	9a98ab92-a0fe-4a08-a9a6-01dda768f49e	2026-07-20 09:59:26.363877+00	2026-07-20 09:59:26.363877+00	completed	approved	100	4.10	2026-07-13
a03a787d-b998-4a31-aa2e-2aef31ab5784	b2f9aaf2-33f5-448b-8177-93cf8a2e2cda	\N	d6fc165d-7448-431b-af51-26d9bb7751a1	1fd6e737-0c6b-49b7-841e-0f8a73d3c1a1	رفع مشکل ناسازگاری مرورگر #33	\N	low	2026-07-23	0573add8-d250-43db-9bd1-2f70ea1a89e0	2026-07-20 09:59:26.363877+00	2026-07-20 09:59:26.363877+00	completed	approved	100	11.40	2026-07-11
a03a787d-b998-4a31-aa2e-2aef31ab5784	b2f9aaf2-33f5-448b-8177-93cf8a2e2cda	\N	842034d4-0d08-46e1-bdd9-05eec45bcffa	1fd6e737-0c6b-49b7-841e-0f8a73d3c1a1	طراحی API نسخهٔ دوم #34	\N	medium	2026-07-20	fb096ac1-c120-4e6d-b8a8-e93c420ce590	2026-07-20 09:59:26.363877+00	2026-07-20 09:59:26.363877+00	completed	approved	100	11.50	2026-07-13
a03a787d-b998-4a31-aa2e-2aef31ab5784	b2f9aaf2-33f5-448b-8177-93cf8a2e2cda	\N	1fd6e737-0c6b-49b7-841e-0f8a73d3c1a1	1fd6e737-0c6b-49b7-841e-0f8a73d3c1a1	پیاده‌سازی صفحهٔ ورود جدید #35	\N	low	2026-08-28	4970c728-2454-4c41-a0d4-7fb44dd98ba9	2026-07-20 09:59:26.363877+00	2026-07-20 09:59:26.363877+00	completed	pending	100	26.80	2026-08-09
a03a787d-b998-4a31-aa2e-2aef31ab5784	b2f9aaf2-33f5-448b-8177-93cf8a2e2cda	\N	e5ed62a2-bd4a-46d5-a6c6-be866906977f	1fd6e737-0c6b-49b7-841e-0f8a73d3c1a1	بهینه‌سازی کوئری‌های گزارش‌گیری #36	\N	medium	2026-06-30	9660e3ee-20d0-4cf2-8ab1-18862dee1d56	2026-07-20 09:59:26.363877+00	2026-07-20 09:59:26.363877+00	todo	\N	62	20.30	2026-06-21
a03a787d-b998-4a31-aa2e-2aef31ab5784	c52c73bc-c6d8-4e9b-a31c-7665a092eaa2	\N	b0bcd30d-df04-4c14-bdf8-7923f39ea52e	1fd6e737-0c6b-49b7-841e-0f8a73d3c1a1	بهینه‌سازی کوئری‌های گزارش‌گیری #37	\N	medium	2026-08-15	13b3b11c-595c-42c4-a41a-0bf95675a51b	2026-07-20 09:59:26.363877+00	2026-07-20 09:59:26.363877+00	in_progress	\N	0	39.40	2026-08-12
a03a787d-b998-4a31-aa2e-2aef31ab5784	c52c73bc-c6d8-4e9b-a31c-7665a092eaa2	\N	be1819a8-75ce-4c92-8f50-3b2a8aa29e30	1fd6e737-0c6b-49b7-841e-0f8a73d3c1a1	تنظیم پایپ‌لاین CI/CD #38	\N	high	2026-08-18	cd36f159-85e5-41ab-820f-67bd17ed9dab	2026-07-20 09:59:26.363877+00	2026-07-20 09:59:26.363877+00	completed	approved	100	20.50	2026-07-30
a03a787d-b998-4a31-aa2e-2aef31ab5784	c52c73bc-c6d8-4e9b-a31c-7665a092eaa2	\N	842034d4-0d08-46e1-bdd9-05eec45bcffa	1fd6e737-0c6b-49b7-841e-0f8a73d3c1a1	پیاده‌سازی صفحهٔ داشبورد مدیریتی #39	\N	high	2026-07-02	261b9548-75f2-4938-96e6-5d4d608c21e4	2026-07-20 09:59:26.363877+00	2026-07-20 09:59:26.363877+00	in_progress	\N	69	4.30	2026-06-29
a03a787d-b998-4a31-aa2e-2aef31ab5784	c52c73bc-c6d8-4e9b-a31c-7665a092eaa2	\N	be1819a8-75ce-4c92-8f50-3b2a8aa29e30	1fd6e737-0c6b-49b7-841e-0f8a73d3c1a1	بررسی و رفع آسیب‌پذیری امنیتی #40	\N	high	2026-07-09	609ea0ef-be74-4b86-9039-4a29ee8a1929	2026-07-20 09:59:26.363877+00	2026-07-20 09:59:26.363877+00	todo	\N	67	8.00	2026-06-19
a03a787d-b998-4a31-aa2e-2aef31ab5784	c52c73bc-c6d8-4e9b-a31c-7665a092eaa2	\N	e5ed62a2-bd4a-46d5-a6c6-be866906977f	1fd6e737-0c6b-49b7-841e-0f8a73d3c1a1	پیاده‌سازی صفحهٔ ورود جدید #41	\N	high	2026-08-16	9523ce3e-e0bb-4865-b5dc-2ddcbabe6d77	2026-07-20 09:59:26.363877+00	2026-07-20 09:59:26.363877+00	todo	\N	8	27.70	2026-08-09
a03a787d-b998-4a31-aa2e-2aef31ab5784	c52c73bc-c6d8-4e9b-a31c-7665a092eaa2	\N	842034d4-0d08-46e1-bdd9-05eec45bcffa	1fd6e737-0c6b-49b7-841e-0f8a73d3c1a1	افزودن تست واحد برای سرویس کاربران #42	\N	high	2026-07-13	51222d9e-adff-41f1-ad5c-3702e014132d	2026-07-20 09:59:26.363877+00	2026-07-20 09:59:26.363877+00	in_progress	\N	76	3.50	2026-06-23
a03a787d-b998-4a31-aa2e-2aef31ab5784	c52c73bc-c6d8-4e9b-a31c-7665a092eaa2	\N	1fd6e737-0c6b-49b7-841e-0f8a73d3c1a1	1fd6e737-0c6b-49b7-841e-0f8a73d3c1a1	پیاده‌سازی صفحهٔ داشبورد مدیریتی #43	\N	high	2026-08-17	d4444be1-12ae-4337-a21c-88ccf1d42f39	2026-07-20 09:59:26.363877+00	2026-07-20 09:59:26.363877+00	in_progress	\N	40	37.50	2026-07-28
a03a787d-b998-4a31-aa2e-2aef31ab5784	c52c73bc-c6d8-4e9b-a31c-7665a092eaa2	\N	842034d4-0d08-46e1-bdd9-05eec45bcffa	1fd6e737-0c6b-49b7-841e-0f8a73d3c1a1	پیاده‌سازی احراز هویت دومرحله‌ای #44	\N	low	2026-07-11	43f85057-4e32-4328-bff2-c363eb5e75be	2026-07-20 09:59:26.363877+00	2026-07-20 09:59:26.363877+00	completed	pending	100	27.50	2026-07-01
a03a787d-b998-4a31-aa2e-2aef31ab5784	c52c73bc-c6d8-4e9b-a31c-7665a092eaa2	\N	be1819a8-75ce-4c92-8f50-3b2a8aa29e30	1fd6e737-0c6b-49b7-841e-0f8a73d3c1a1	رفع باگ در ماژول پرداخت #45	\N	medium	2026-08-07	17d56399-8d5b-4f53-823f-07ca1e5b455f	2026-07-20 09:59:26.363877+00	2026-07-20 09:59:26.363877+00	completed	approved	100	25.60	2026-08-03
a03a787d-b998-4a31-aa2e-2aef31ab5784	c52c73bc-c6d8-4e9b-a31c-7665a092eaa2	\N	e5ed62a2-bd4a-46d5-a6c6-be866906977f	1fd6e737-0c6b-49b7-841e-0f8a73d3c1a1	افزودن تست واحد برای سرویس کاربران #46	\N	high	2026-07-09	33c4ef6e-86d0-44b3-b1de-d10973835f7e	2026-07-20 09:59:26.363877+00	2026-07-20 09:59:26.363877+00	todo	\N	33	7.00	2026-06-20
a03a787d-b998-4a31-aa2e-2aef31ab5784	c52c73bc-c6d8-4e9b-a31c-7665a092eaa2	\N	be1819a8-75ce-4c92-8f50-3b2a8aa29e30	1fd6e737-0c6b-49b7-841e-0f8a73d3c1a1	رفع مشکل کندی بارگذاری صفحه #47	\N	medium	2026-08-20	b296a190-14a6-47e1-841b-b7130e5e8474	2026-07-20 09:59:26.363877+00	2026-07-20 09:59:26.363877+00	todo	\N	20	18.70	2026-08-11
a03a787d-b998-4a31-aa2e-2aef31ab5784	c52c73bc-c6d8-4e9b-a31c-7665a092eaa2	\N	e5ed62a2-bd4a-46d5-a6c6-be866906977f	1fd6e737-0c6b-49b7-841e-0f8a73d3c1a1	رفع مشکل ناسازگاری مرورگر #48	\N	high	2026-07-26	eef1ebf2-8940-4f32-80f3-387bf1762b3f	2026-07-20 09:59:26.363877+00	2026-07-20 09:59:26.363877+00	archived	\N	67	2.30	2026-07-05
a03a787d-b998-4a31-aa2e-2aef31ab5784	c52c73bc-c6d8-4e9b-a31c-7665a092eaa2	\N	b0bcd30d-df04-4c14-bdf8-7923f39ea52e	1fd6e737-0c6b-49b7-841e-0f8a73d3c1a1	افزودن قابلیت جست‌وجوی پیشرفته #49	\N	low	2026-08-02	f0bedd4e-ed71-4a5b-aa86-b019c1354373	2026-07-20 09:59:26.363877+00	2026-07-20 09:59:26.363877+00	completed	approved	100	12.00	2026-07-28
a03a787d-b998-4a31-aa2e-2aef31ab5784	c52c73bc-c6d8-4e9b-a31c-7665a092eaa2	\N	1fd6e737-0c6b-49b7-841e-0f8a73d3c1a1	1fd6e737-0c6b-49b7-841e-0f8a73d3c1a1	طراحی API نسخهٔ دوم #50	\N	medium	2026-07-27	052707ac-a65d-4bf9-801a-52aa0dbf6b94	2026-07-20 09:59:26.363877+00	2026-07-20 09:59:26.363877+00	archived	\N	77	10.00	2026-07-21
a03a787d-b998-4a31-aa2e-2aef31ab5784	c52c73bc-c6d8-4e9b-a31c-7665a092eaa2	\N	be1819a8-75ce-4c92-8f50-3b2a8aa29e30	1fd6e737-0c6b-49b7-841e-0f8a73d3c1a1	به‌روزرسانی کتابخانه‌های وابسته #51	\N	medium	2026-08-08	8b9b1245-bfa1-4706-bce6-0d14af61e663	2026-07-20 09:59:26.363877+00	2026-07-20 09:59:26.363877+00	in_progress	\N	32	36.40	2026-07-29
a03a787d-b998-4a31-aa2e-2aef31ab5784	c52c73bc-c6d8-4e9b-a31c-7665a092eaa2	\N	b0bcd30d-df04-4c14-bdf8-7923f39ea52e	1fd6e737-0c6b-49b7-841e-0f8a73d3c1a1	بازنویسی ماژول اعلان‌ها #52	\N	medium	2026-07-06	58900e1b-da2e-4b49-8095-bb605f63a7b1	2026-07-20 09:59:26.363877+00	2026-07-20 09:59:26.363877+00	todo	\N	5	2.10	2026-06-21
a03a787d-b998-4a31-aa2e-2aef31ab5784	c52c73bc-c6d8-4e9b-a31c-7665a092eaa2	\N	b0bcd30d-df04-4c14-bdf8-7923f39ea52e	1fd6e737-0c6b-49b7-841e-0f8a73d3c1a1	بهینه‌سازی کوئری‌های گزارش‌گیری #53	\N	high	2026-08-05	c1f3e425-dbf2-490f-97d8-f9334a2a8d7b	2026-07-20 09:59:26.363877+00	2026-07-20 09:59:26.363877+00	todo	\N	56	23.00	2026-07-26
a03a787d-b998-4a31-aa2e-2aef31ab5784	c52c73bc-c6d8-4e9b-a31c-7665a092eaa2	\N	07e1c1ad-90c2-4b01-80d6-88ad81b6cc78	1fd6e737-0c6b-49b7-841e-0f8a73d3c1a1	به‌روزرسانی کتابخانه‌های وابسته #54	\N	low	2026-06-26	60f56971-4ae5-40b8-8358-c51de8fbef83	2026-07-20 09:59:26.363877+00	2026-07-20 09:59:26.363877+00	completed	approved	100	33.70	2026-06-20
a03a787d-b998-4a31-aa2e-2aef31ab5784	05099cdc-50af-4a51-810f-e8a374ef5665	\N	e5ed62a2-bd4a-46d5-a6c6-be866906977f	1fd6e737-0c6b-49b7-841e-0f8a73d3c1a1	طراحی API نسخهٔ دوم #55	\N	medium	2026-06-27	f6d6b8a6-8e40-4682-8264-eb40174b9ac2	2026-07-20 09:59:26.363877+00	2026-07-20 09:59:26.363877+00	completed	approved	100	36.20	2026-06-24
a03a787d-b998-4a31-aa2e-2aef31ab5784	05099cdc-50af-4a51-810f-e8a374ef5665	\N	b0bcd30d-df04-4c14-bdf8-7923f39ea52e	1fd6e737-0c6b-49b7-841e-0f8a73d3c1a1	افزودن تست واحد برای سرویس کاربران #56	\N	high	2026-08-25	a49dcc59-5570-41e6-ba8c-ae12622d1822	2026-07-20 09:59:26.363877+00	2026-07-20 09:59:26.363877+00	todo	\N	31	27.30	2026-08-12
a03a787d-b998-4a31-aa2e-2aef31ab5784	05099cdc-50af-4a51-810f-e8a374ef5665	\N	be1819a8-75ce-4c92-8f50-3b2a8aa29e30	1fd6e737-0c6b-49b7-841e-0f8a73d3c1a1	پیاده‌سازی صفحهٔ داشبورد مدیریتی #57	\N	high	2026-08-05	84840f44-607d-4502-baa7-69c7658ff81e	2026-07-20 09:59:26.363877+00	2026-07-20 09:59:26.363877+00	archived	\N	19	37.20	2026-07-21
a03a787d-b998-4a31-aa2e-2aef31ab5784	05099cdc-50af-4a51-810f-e8a374ef5665	\N	842034d4-0d08-46e1-bdd9-05eec45bcffa	1fd6e737-0c6b-49b7-841e-0f8a73d3c1a1	افزودن قابلیت جست‌وجوی پیشرفته #58	\N	medium	2026-08-13	ed81753e-df43-4894-946f-1cd8c57783b7	2026-07-20 09:59:26.363877+00	2026-07-20 09:59:26.363877+00	todo	\N	3	8.80	2026-08-06
a03a787d-b998-4a31-aa2e-2aef31ab5784	05099cdc-50af-4a51-810f-e8a374ef5665	\N	be1819a8-75ce-4c92-8f50-3b2a8aa29e30	1fd6e737-0c6b-49b7-841e-0f8a73d3c1a1	طراحی API نسخهٔ دوم #59	\N	low	2026-08-15	609cbb9b-b292-4178-8733-ccd3049a001f	2026-07-20 09:59:26.363877+00	2026-07-20 09:59:26.363877+00	in_progress	\N	13	16.50	2026-08-06
a03a787d-b998-4a31-aa2e-2aef31ab5784	05099cdc-50af-4a51-810f-e8a374ef5665	\N	1fd6e737-0c6b-49b7-841e-0f8a73d3c1a1	1fd6e737-0c6b-49b7-841e-0f8a73d3c1a1	رفع مشکل کندی بارگذاری صفحه #60	\N	medium	2026-08-23	722e851f-2776-4099-a800-29ded0c5919d	2026-07-20 09:59:26.363877+00	2026-07-20 09:59:26.363877+00	completed	approved	100	33.20	2026-08-07
a03a787d-b998-4a31-aa2e-2aef31ab5784	05099cdc-50af-4a51-810f-e8a374ef5665	\N	b0bcd30d-df04-4c14-bdf8-7923f39ea52e	1fd6e737-0c6b-49b7-841e-0f8a73d3c1a1	تنظیم پایپ‌لاین CI/CD #61	\N	low	2026-07-02	43dbd99d-4e5d-4d5f-bfc6-9b4e00abf127	2026-07-20 09:59:26.363877+00	2026-07-20 09:59:26.363877+00	in_progress	\N	51	14.50	2026-06-30
a03a787d-b998-4a31-aa2e-2aef31ab5784	05099cdc-50af-4a51-810f-e8a374ef5665	\N	b0bcd30d-df04-4c14-bdf8-7923f39ea52e	1fd6e737-0c6b-49b7-841e-0f8a73d3c1a1	رفع مشکل کندی بارگذاری صفحه #62	\N	high	2026-08-14	7ff9c8e8-30f1-4010-9476-78bfb801a029	2026-07-20 09:59:26.363877+00	2026-07-20 09:59:26.363877+00	todo	\N	65	17.20	2026-08-04
a03a787d-b998-4a31-aa2e-2aef31ab5784	05099cdc-50af-4a51-810f-e8a374ef5665	\N	b0bcd30d-df04-4c14-bdf8-7923f39ea52e	1fd6e737-0c6b-49b7-841e-0f8a73d3c1a1	افزودن قابلیت جست‌وجوی پیشرفته #63	\N	medium	2026-06-22	8d373e65-993e-408b-8a7b-2bd3cad0d385	2026-07-20 09:59:26.363877+00	2026-07-20 09:59:26.363877+00	completed	approved	100	8.80	2026-06-17
a03a787d-b998-4a31-aa2e-2aef31ab5784	05099cdc-50af-4a51-810f-e8a374ef5665	\N	be1819a8-75ce-4c92-8f50-3b2a8aa29e30	1fd6e737-0c6b-49b7-841e-0f8a73d3c1a1	پیاده‌سازی احراز هویت دومرحله‌ای #64	\N	medium	2026-07-13	7bf56c41-3b05-408e-8a04-742b0ab49e59	2026-07-20 09:59:26.363877+00	2026-07-20 09:59:26.363877+00	todo	\N	40	18.60	2026-06-22
a03a787d-b998-4a31-aa2e-2aef31ab5784	05099cdc-50af-4a51-810f-e8a374ef5665	\N	e5ed62a2-bd4a-46d5-a6c6-be866906977f	1fd6e737-0c6b-49b7-841e-0f8a73d3c1a1	افزودن تست واحد برای سرویس کاربران #65	\N	medium	2026-07-30	8d6d6b6e-1ad7-45cc-a6e9-490f6c18eb7a	2026-07-20 09:59:26.363877+00	2026-07-20 09:59:26.363877+00	todo	\N	5	28.90	2026-07-10
a03a787d-b998-4a31-aa2e-2aef31ab5784	05099cdc-50af-4a51-810f-e8a374ef5665	\N	1fd6e737-0c6b-49b7-841e-0f8a73d3c1a1	1fd6e737-0c6b-49b7-841e-0f8a73d3c1a1	رفع مشکل کندی بارگذاری صفحه #66	\N	medium	2026-07-28	5d6d0e43-7efb-4f75-804a-0aba64b898cb	2026-07-20 09:59:26.363877+00	2026-07-20 09:59:26.363877+00	completed	rejected	100	4.70	2026-07-20
a03a787d-b998-4a31-aa2e-2aef31ab5784	05099cdc-50af-4a51-810f-e8a374ef5665	\N	d6fc165d-7448-431b-af51-26d9bb7751a1	1fd6e737-0c6b-49b7-841e-0f8a73d3c1a1	تنظیم پایپ‌لاین CI/CD #67	\N	low	2026-08-06	2353ba14-d382-4b4d-a23c-68af86c4459a	2026-07-20 09:59:26.363877+00	2026-07-20 09:59:26.363877+00	in_progress	\N	38	21.30	2026-07-25
a03a787d-b998-4a31-aa2e-2aef31ab5784	05099cdc-50af-4a51-810f-e8a374ef5665	\N	d6fc165d-7448-431b-af51-26d9bb7751a1	1fd6e737-0c6b-49b7-841e-0f8a73d3c1a1	نوشتن مستندات فنی API #68	\N	medium	2026-07-20	9a62d619-23e7-4326-b107-567ae9ae1c2b	2026-07-20 09:59:26.363877+00	2026-07-20 09:59:26.363877+00	in_progress	\N	70	6.80	2026-07-06
a03a787d-b998-4a31-aa2e-2aef31ab5784	05099cdc-50af-4a51-810f-e8a374ef5665	\N	07e1c1ad-90c2-4b01-80d6-88ad81b6cc78	1fd6e737-0c6b-49b7-841e-0f8a73d3c1a1	پیاده‌سازی صفحهٔ داشبورد مدیریتی #69	\N	high	2026-08-05	351cd82f-becf-4ac7-bd78-ea205404125f	2026-07-20 09:59:26.363877+00	2026-07-20 09:59:26.363877+00	completed	rejected	100	13.40	2026-07-29
a03a787d-b998-4a31-aa2e-2aef31ab5784	05099cdc-50af-4a51-810f-e8a374ef5665	\N	e5ed62a2-bd4a-46d5-a6c6-be866906977f	1fd6e737-0c6b-49b7-841e-0f8a73d3c1a1	افزودن تست واحد برای سرویس کاربران #70	\N	medium	2026-07-16	a4e4e774-e3fd-4a52-a58a-feb1cb4e317a	2026-07-20 09:59:26.363877+00	2026-07-20 09:59:26.363877+00	todo	\N	74	25.10	2026-07-05
a03a787d-b998-4a31-aa2e-2aef31ab5784	05099cdc-50af-4a51-810f-e8a374ef5665	\N	be1819a8-75ce-4c92-8f50-3b2a8aa29e30	1fd6e737-0c6b-49b7-841e-0f8a73d3c1a1	به‌روزرسانی کتابخانه‌های وابسته #71	\N	medium	2026-08-06	3114e03e-fff8-4152-bd48-85d1632874a0	2026-07-20 09:59:26.363877+00	2026-07-20 09:59:26.363877+00	completed	approved	100	32.20	2026-07-29
a03a787d-b998-4a31-aa2e-2aef31ab5784	05099cdc-50af-4a51-810f-e8a374ef5665	\N	b0bcd30d-df04-4c14-bdf8-7923f39ea52e	1fd6e737-0c6b-49b7-841e-0f8a73d3c1a1	طراحی API نسخهٔ دوم #72	\N	high	2026-06-30	c69c8b1d-d6a0-444d-aa9c-7a15ec0cc41d	2026-07-20 09:59:26.363877+00	2026-07-20 09:59:26.363877+00	archived	\N	79	14.70	2026-06-26
a03a787d-b998-4a31-aa2e-2aef31ab5784	5730191d-f4bd-43eb-90fc-18243ae04e10	\N	b0bcd30d-df04-4c14-bdf8-7923f39ea52e	1fd6e737-0c6b-49b7-841e-0f8a73d3c1a1	افزودن تست واحد برای سرویس کاربران #73	\N	low	2026-07-12	f5c3f2ec-51e7-4cb8-9ef4-df16245cef4f	2026-07-20 09:59:26.363877+00	2026-07-20 09:59:26.363877+00	archived	\N	18	2.90	2026-07-01
a03a787d-b998-4a31-aa2e-2aef31ab5784	5730191d-f4bd-43eb-90fc-18243ae04e10	\N	842034d4-0d08-46e1-bdd9-05eec45bcffa	1fd6e737-0c6b-49b7-841e-0f8a73d3c1a1	بررسی و رفع آسیب‌پذیری امنیتی #74	\N	medium	2026-08-08	f83137e7-89c2-4664-9c5b-fdb49a18878e	2026-07-20 09:59:26.363877+00	2026-07-20 09:59:26.363877+00	completed	pending	100	35.70	2026-08-04
a03a787d-b998-4a31-aa2e-2aef31ab5784	5730191d-f4bd-43eb-90fc-18243ae04e10	\N	e5ed62a2-bd4a-46d5-a6c6-be866906977f	1fd6e737-0c6b-49b7-841e-0f8a73d3c1a1	بررسی و رفع آسیب‌پذیری امنیتی #75	\N	medium	2026-08-14	65789748-ba3b-43a7-a6f0-602890be13c0	2026-07-20 09:59:26.363877+00	2026-07-20 09:59:26.363877+00	todo	\N	31	7.60	2026-07-31
a03a787d-b998-4a31-aa2e-2aef31ab5784	5730191d-f4bd-43eb-90fc-18243ae04e10	\N	d6fc165d-7448-431b-af51-26d9bb7751a1	1fd6e737-0c6b-49b7-841e-0f8a73d3c1a1	رفع مشکل ناسازگاری مرورگر #76	\N	medium	2026-08-17	e985383a-b46e-4ad1-aac2-075c3efadb1b	2026-07-20 09:59:26.363877+00	2026-07-20 09:59:26.363877+00	todo	\N	28	8.70	2026-08-12
a03a787d-b998-4a31-aa2e-2aef31ab5784	5730191d-f4bd-43eb-90fc-18243ae04e10	\N	d6fc165d-7448-431b-af51-26d9bb7751a1	1fd6e737-0c6b-49b7-841e-0f8a73d3c1a1	افزودن قابلیت جست‌وجوی پیشرفته #77	\N	low	2026-07-30	cdb3c7a8-a9f7-4aa4-9c83-805a53057c28	2026-07-20 09:59:26.363877+00	2026-07-20 09:59:26.363877+00	completed	approved	100	19.30	2026-07-21
a03a787d-b998-4a31-aa2e-2aef31ab5784	5730191d-f4bd-43eb-90fc-18243ae04e10	\N	b0bcd30d-df04-4c14-bdf8-7923f39ea52e	1fd6e737-0c6b-49b7-841e-0f8a73d3c1a1	رفع مشکل کندی بارگذاری صفحه #78	\N	medium	2026-08-11	fd7a65c2-67c3-4d58-b9fb-0ffe072833db	2026-07-20 09:59:26.363877+00	2026-07-20 09:59:26.363877+00	completed	pending	100	25.30	2026-07-21
a03a787d-b998-4a31-aa2e-2aef31ab5784	5730191d-f4bd-43eb-90fc-18243ae04e10	\N	d6fc165d-7448-431b-af51-26d9bb7751a1	1fd6e737-0c6b-49b7-841e-0f8a73d3c1a1	بررسی و رفع آسیب‌پذیری امنیتی #79	\N	low	2026-09-01	5eb3e021-9714-41ef-a9d9-6a111319dae8	2026-07-20 09:59:26.363877+00	2026-07-20 09:59:26.363877+00	completed	approved	100	30.30	2026-08-13
a03a787d-b998-4a31-aa2e-2aef31ab5784	5730191d-f4bd-43eb-90fc-18243ae04e10	\N	07e1c1ad-90c2-4b01-80d6-88ad81b6cc78	1fd6e737-0c6b-49b7-841e-0f8a73d3c1a1	رفع مشکل ناسازگاری مرورگر #80	\N	high	2026-07-11	52a42842-639d-4b69-9539-b4030a1bc726	2026-07-20 09:59:26.363877+00	2026-07-20 09:59:26.363877+00	completed	approved	100	20.40	2026-07-01
a03a787d-b998-4a31-aa2e-2aef31ab5784	5730191d-f4bd-43eb-90fc-18243ae04e10	\N	842034d4-0d08-46e1-bdd9-05eec45bcffa	1fd6e737-0c6b-49b7-841e-0f8a73d3c1a1	نوشتن مستندات فنی API #81	\N	medium	2026-07-18	75ea9a0f-bd48-4906-b07f-920209284136	2026-07-20 09:59:26.363877+00	2026-07-20 09:59:26.363877+00	in_progress	\N	30	12.30	2026-07-14
a03a787d-b998-4a31-aa2e-2aef31ab5784	5730191d-f4bd-43eb-90fc-18243ae04e10	\N	be1819a8-75ce-4c92-8f50-3b2a8aa29e30	1fd6e737-0c6b-49b7-841e-0f8a73d3c1a1	پیاده‌سازی احراز هویت دومرحله‌ای #82	\N	high	2026-07-04	db319da9-c71b-4eb7-9e1d-827fb03d6b03	2026-07-20 09:59:26.363877+00	2026-07-20 09:59:26.363877+00	completed	approved	100	7.80	2026-06-25
a03a787d-b998-4a31-aa2e-2aef31ab5784	5730191d-f4bd-43eb-90fc-18243ae04e10	\N	842034d4-0d08-46e1-bdd9-05eec45bcffa	1fd6e737-0c6b-49b7-841e-0f8a73d3c1a1	رفع مشکل کندی بارگذاری صفحه #83	\N	high	2026-07-27	b0d3f273-2e56-415f-924c-b405a3abe832	2026-07-20 09:59:26.363877+00	2026-07-20 09:59:26.363877+00	todo	\N	59	17.80	2026-07-12
a03a787d-b998-4a31-aa2e-2aef31ab5784	5730191d-f4bd-43eb-90fc-18243ae04e10	\N	842034d4-0d08-46e1-bdd9-05eec45bcffa	1fd6e737-0c6b-49b7-841e-0f8a73d3c1a1	نوشتن مستندات فنی API #84	\N	low	2026-07-30	05e71afe-0a12-437e-920e-b75510637d85	2026-07-20 09:59:26.363877+00	2026-07-20 09:59:26.363877+00	in_progress	\N	73	16.50	2026-07-10
a03a787d-b998-4a31-aa2e-2aef31ab5784	5730191d-f4bd-43eb-90fc-18243ae04e10	\N	1fd6e737-0c6b-49b7-841e-0f8a73d3c1a1	1fd6e737-0c6b-49b7-841e-0f8a73d3c1a1	بازنویسی ماژول اعلان‌ها #85	\N	medium	2026-07-19	b93cbd6a-bcd3-4276-b8e8-e79257e29b60	2026-07-20 09:59:26.363877+00	2026-07-20 09:59:26.363877+00	in_progress	\N	68	30.40	2026-07-05
a03a787d-b998-4a31-aa2e-2aef31ab5784	5730191d-f4bd-43eb-90fc-18243ae04e10	\N	e5ed62a2-bd4a-46d5-a6c6-be866906977f	1fd6e737-0c6b-49b7-841e-0f8a73d3c1a1	طراحی API نسخهٔ دوم #86	\N	medium	2026-07-26	b9811892-86ef-45c2-bff9-a609e0d89088	2026-07-20 09:59:26.363877+00	2026-07-20 09:59:26.363877+00	completed	pending	100	20.50	2026-07-17
a03a787d-b998-4a31-aa2e-2aef31ab5784	5730191d-f4bd-43eb-90fc-18243ae04e10	\N	07e1c1ad-90c2-4b01-80d6-88ad81b6cc78	1fd6e737-0c6b-49b7-841e-0f8a73d3c1a1	نوشتن مستندات فنی API #87	\N	low	2026-08-11	55c55bbe-a242-42ba-b449-cebde5c9ffa3	2026-07-20 09:59:26.363877+00	2026-07-20 09:59:26.363877+00	in_progress	\N	59	36.90	2026-07-28
a03a787d-b998-4a31-aa2e-2aef31ab5784	5730191d-f4bd-43eb-90fc-18243ae04e10	\N	e5ed62a2-bd4a-46d5-a6c6-be866906977f	1fd6e737-0c6b-49b7-841e-0f8a73d3c1a1	پیاده‌سازی صفحهٔ داشبورد مدیریتی #88	\N	high	2026-07-31	e99b1583-ece2-4431-ab93-c54f66e2be43	2026-07-20 09:59:26.363877+00	2026-07-20 09:59:26.363877+00	completed	approved	100	3.00	2026-07-11
a03a787d-b998-4a31-aa2e-2aef31ab5784	5730191d-f4bd-43eb-90fc-18243ae04e10	\N	d6fc165d-7448-431b-af51-26d9bb7751a1	1fd6e737-0c6b-49b7-841e-0f8a73d3c1a1	بهینه‌سازی کوئری‌های گزارش‌گیری #89	\N	low	2026-07-10	ccaf9c44-5dc4-4fb1-9123-8ee71dfa8370	2026-07-20 09:59:26.363877+00	2026-07-20 09:59:26.363877+00	in_progress	\N	33	16.40	2026-06-24
a03a787d-b998-4a31-aa2e-2aef31ab5784	5730191d-f4bd-43eb-90fc-18243ae04e10	\N	842034d4-0d08-46e1-bdd9-05eec45bcffa	1fd6e737-0c6b-49b7-841e-0f8a73d3c1a1	طراحی API نسخهٔ دوم #90	\N	medium	2026-08-17	c6d604bf-aa8f-4b04-869a-f98da13c49c1	2026-07-20 09:59:26.363877+00	2026-07-20 09:59:26.363877+00	completed	approved	100	11.60	2026-08-03
a03a787d-b998-4a31-aa2e-2aef31ab5784	\N	\N	1fd6e737-0c6b-49b7-841e-0f8a73d3c1a1	1fd6e737-0c6b-49b7-841e-0f8a73d3c1a1	رفع مشکل کندی بارگذاری صفحه #91	\N	low	2026-07-23	cb748164-2ac5-48a0-ac86-0c9e1d4dec1e	2026-07-20 09:59:26.363877+00	2026-07-20 09:59:26.363877+00	completed	approved	100	26.70	2026-07-20
a03a787d-b998-4a31-aa2e-2aef31ab5784	\N	\N	b0bcd30d-df04-4c14-bdf8-7923f39ea52e	b0bcd30d-df04-4c14-bdf8-7923f39ea52e	افزودن تست واحد برای سرویس کاربران #92	\N	low	2026-06-26	233a7d09-c27f-4e93-8418-c7e1dfbf7064	2026-07-20 09:59:26.363877+00	2026-07-20 09:59:26.363877+00	completed	approved	100	25.60	2026-06-17
a03a787d-b998-4a31-aa2e-2aef31ab5784	\N	\N	842034d4-0d08-46e1-bdd9-05eec45bcffa	842034d4-0d08-46e1-bdd9-05eec45bcffa	پیاده‌سازی صفحهٔ داشبورد مدیریتی #93	\N	low	2026-07-21	1823e886-bc36-48a1-8a75-5b82cbe4f57c	2026-07-20 09:59:26.363877+00	2026-07-20 09:59:26.363877+00	todo	\N	59	28.60	2026-07-16
a03a787d-b998-4a31-aa2e-2aef31ab5784	\N	\N	b0bcd30d-df04-4c14-bdf8-7923f39ea52e	b0bcd30d-df04-4c14-bdf8-7923f39ea52e	پیاده‌سازی صفحهٔ داشبورد مدیریتی #94	\N	high	2026-07-17	4c0ad30b-9a07-42db-aaf6-28048f910be0	2026-07-20 09:59:26.363877+00	2026-07-20 09:59:26.363877+00	in_progress	\N	14	31.60	2026-06-26
a03a787d-b998-4a31-aa2e-2aef31ab5784	\N	\N	842034d4-0d08-46e1-bdd9-05eec45bcffa	842034d4-0d08-46e1-bdd9-05eec45bcffa	رفع باگ در ماژول پرداخت #95	\N	medium	2026-07-12	ef9ffb06-d2bf-482b-9ac3-fbfdaf11e549	2026-07-20 09:59:26.363877+00	2026-07-20 09:59:26.363877+00	in_progress	\N	73	27.70	2026-06-22
a03a787d-b998-4a31-aa2e-2aef31ab5784	\N	\N	07e1c1ad-90c2-4b01-80d6-88ad81b6cc78	07e1c1ad-90c2-4b01-80d6-88ad81b6cc78	پیاده‌سازی صفحهٔ ورود جدید #96	\N	high	2026-08-23	2cbda324-97d1-47ad-9a44-c06f8a4c24b4	2026-07-20 09:59:26.363877+00	2026-07-20 09:59:26.363877+00	in_progress	\N	80	11.20	2026-08-15
a03a787d-b998-4a31-aa2e-2aef31ab5784	\N	\N	d6fc165d-7448-431b-af51-26d9bb7751a1	d6fc165d-7448-431b-af51-26d9bb7751a1	رفع مشکل ناسازگاری مرورگر #97	\N	low	2026-07-26	b01e6044-9092-46c7-8174-575249bf127f	2026-07-20 09:59:26.363877+00	2026-07-20 09:59:26.363877+00	archived	\N	72	31.70	2026-07-05
a03a787d-b998-4a31-aa2e-2aef31ab5784	\N	\N	be1819a8-75ce-4c92-8f50-3b2a8aa29e30	be1819a8-75ce-4c92-8f50-3b2a8aa29e30	به‌روزرسانی کتابخانه‌های وابسته #98	\N	high	2026-07-13	930d59e6-67de-4363-87b1-572cc8087ee0	2026-07-20 09:59:26.363877+00	2026-07-20 09:59:26.363877+00	completed	approved	100	15.00	2026-07-09
a03a787d-b998-4a31-aa2e-2aef31ab5784	\N	\N	b0bcd30d-df04-4c14-bdf8-7923f39ea52e	b0bcd30d-df04-4c14-bdf8-7923f39ea52e	پیاده‌سازی صفحهٔ ورود جدید #99	\N	medium	2026-08-24	8c70a82f-8d0e-4667-80e8-93f1f8163041	2026-07-20 09:59:26.363877+00	2026-07-20 09:59:26.363877+00	in_progress	\N	46	26.20	2026-08-07
a03a787d-b998-4a31-aa2e-2aef31ab5784	\N	\N	b0bcd30d-df04-4c14-bdf8-7923f39ea52e	b0bcd30d-df04-4c14-bdf8-7923f39ea52e	نوشتن مستندات فنی API #100	\N	high	2026-07-20	111f9e2c-bb31-41f6-884f-e3d573ea42f2	2026-07-20 09:59:26.363877+00	2026-07-20 09:59:26.363877+00	completed	pending	100	38.70	2026-07-13
a03a787d-b998-4a31-aa2e-2aef31ab5784	\N	\N	be1819a8-75ce-4c92-8f50-3b2a8aa29e30	be1819a8-75ce-4c92-8f50-3b2a8aa29e30	بررسی و رفع آسیب‌پذیری امنیتی #101	\N	medium	2026-08-06	852b6ed4-054e-4973-a30b-bf1659d3503d	2026-07-20 09:59:26.363877+00	2026-07-20 09:59:26.363877+00	completed	pending	100	33.40	2026-07-20
a03a787d-b998-4a31-aa2e-2aef31ab5784	\N	\N	e5ed62a2-bd4a-46d5-a6c6-be866906977f	e5ed62a2-bd4a-46d5-a6c6-be866906977f	بازنویسی ماژول اعلان‌ها #102	\N	low	2026-07-15	3cded444-c1e3-496a-997c-f1a87716d408	2026-07-20 09:59:26.363877+00	2026-07-20 09:59:26.363877+00	in_progress	\N	35	35.50	2026-07-06
a03a787d-b998-4a31-aa2e-2aef31ab5784	\N	\N	842034d4-0d08-46e1-bdd9-05eec45bcffa	842034d4-0d08-46e1-bdd9-05eec45bcffa	پیاده‌سازی صفحهٔ داشبورد مدیریتی #103	\N	high	2026-08-04	ca2b6e45-b5a5-42bc-812c-36bb9b3f0fc3	2026-07-20 09:59:26.363877+00	2026-07-20 09:59:26.363877+00	archived	\N	48	14.80	2026-07-15
a03a787d-b998-4a31-aa2e-2aef31ab5784	\N	\N	07e1c1ad-90c2-4b01-80d6-88ad81b6cc78	07e1c1ad-90c2-4b01-80d6-88ad81b6cc78	افزودن تست واحد برای سرویس کاربران #104	\N	medium	2026-07-14	c75b8a6d-92c8-40a7-830e-0727c10fc214	2026-07-20 09:59:26.363877+00	2026-07-20 09:59:26.363877+00	in_progress	\N	33	14.90	2026-06-27
a03a787d-b998-4a31-aa2e-2aef31ab5784	\N	\N	e5ed62a2-bd4a-46d5-a6c6-be866906977f	e5ed62a2-bd4a-46d5-a6c6-be866906977f	به‌روزرسانی کتابخانه‌های وابسته #105	\N	low	2026-07-23	10a660a0-0531-4ef2-85ac-3687deefbb6d	2026-07-20 09:59:26.363877+00	2026-07-20 09:59:26.363877+00	completed	pending	100	5.30	2026-07-21
a03a787d-b998-4a31-aa2e-2aef31ab5784	d6f8a913-4870-4aa5-a45f-e9c04e17b7fc	\N	9c22bc65-2479-4780-b3a0-0ed5e139ee5f	328fce4c-c7e7-4b44-8dcb-45aad65bd8e5	بررسی قراردادهای مالی جدید #1	\N	medium	2026-08-18	09e0a150-abb0-42f9-8167-cfba30f26ce7	2026-07-20 09:59:26.363877+00	2026-07-20 09:59:26.363877+00	in_progress	\N	43	39.00	2026-08-02
a03a787d-b998-4a31-aa2e-2aef31ab5784	d6f8a913-4870-4aa5-a45f-e9c04e17b7fc	\N	9c22bc65-2479-4780-b3a0-0ed5e139ee5f	328fce4c-c7e7-4b44-8dcb-45aad65bd8e5	پیگیری مطالبات معوق مشتریان #2	\N	low	2026-09-01	c7dacc4b-6f9a-4a52-a4a7-86b10cf0df42	2026-07-20 09:59:26.363877+00	2026-07-20 09:59:26.363877+00	completed	approved	100	29.60	2026-08-14
a03a787d-b998-4a31-aa2e-2aef31ab5784	d6f8a913-4870-4aa5-a45f-e9c04e17b7fc	\N	328fce4c-c7e7-4b44-8dcb-45aad65bd8e5	328fce4c-c7e7-4b44-8dcb-45aad65bd8e5	تهیهٔ پیش‌نویس بودجهٔ واحد #3	\N	medium	2026-08-14	841e11ce-e7c2-45fb-b3c9-d99f4648100c	2026-07-20 09:59:26.363877+00	2026-07-20 09:59:26.363877+00	completed	pending	100	14.20	2026-08-07
a03a787d-b998-4a31-aa2e-2aef31ab5784	d6f8a913-4870-4aa5-a45f-e9c04e17b7fc	\N	328fce4c-c7e7-4b44-8dcb-45aad65bd8e5	328fce4c-c7e7-4b44-8dcb-45aad65bd8e5	پیگیری مطالبات معوق مشتریان #4	\N	medium	2026-08-08	dd1c62b6-a7fd-4430-affa-03d527359088	2026-07-20 09:59:26.363877+00	2026-07-20 09:59:26.363877+00	in_progress	\N	77	29.30	2026-07-28
a03a787d-b998-4a31-aa2e-2aef31ab5784	d6f8a913-4870-4aa5-a45f-e9c04e17b7fc	\N	1775df44-8335-487a-9a3b-a1a6eb5949f5	328fce4c-c7e7-4b44-8dcb-45aad65bd8e5	تهیهٔ گزارش جریان نقدی #5	\N	medium	2026-07-17	928096af-708b-4d6e-9405-27c454f738ea	2026-07-20 09:59:26.363877+00	2026-07-20 09:59:26.363877+00	completed	approved	100	25.40	2026-07-14
a03a787d-b998-4a31-aa2e-2aef31ab5784	d6f8a913-4870-4aa5-a45f-e9c04e17b7fc	\N	9c22bc65-2479-4780-b3a0-0ed5e139ee5f	328fce4c-c7e7-4b44-8dcb-45aad65bd8e5	تهیهٔ گزارش سود و زیان ماهانه #6	\N	high	2026-07-29	5d6fbf79-eefa-451c-b230-1f5ea9409dec	2026-07-20 09:59:26.363877+00	2026-07-20 09:59:26.363877+00	in_progress	\N	51	15.80	2026-07-26
a03a787d-b998-4a31-aa2e-2aef31ab5784	d6f8a913-4870-4aa5-a45f-e9c04e17b7fc	\N	276feb60-37b2-42ff-be39-f9e79af8ae2a	328fce4c-c7e7-4b44-8dcb-45aad65bd8e5	بررسی و تأیید صورت‌حساب‌های خرید #7	\N	low	2026-08-05	327fbe5d-06a4-4e7b-ad21-43d83e227549	2026-07-20 09:59:26.363877+00	2026-07-20 09:59:26.363877+00	archived	\N	77	27.80	2026-07-29
a03a787d-b998-4a31-aa2e-2aef31ab5784	d6f8a913-4870-4aa5-a45f-e9c04e17b7fc	\N	9c22bc65-2479-4780-b3a0-0ed5e139ee5f	328fce4c-c7e7-4b44-8dcb-45aad65bd8e5	ثبت اسناد حسابداری هفتگی #8	\N	high	2026-06-28	d25dbb2b-eec3-411f-8e6d-1c6e5826958a	2026-07-20 09:59:26.363877+00	2026-07-20 09:59:26.363877+00	todo	\N	46	15.80	2026-06-24
a03a787d-b998-4a31-aa2e-2aef31ab5784	d6f8a913-4870-4aa5-a45f-e9c04e17b7fc	\N	767b011b-ff3a-4faf-b85b-c424554a44a0	328fce4c-c7e7-4b44-8dcb-45aad65bd8e5	تطبیق موجودی انبار با حساب‌ها #9	\N	medium	2026-07-30	386624a8-0d40-4f33-a17c-3721f765086f	2026-07-20 09:59:26.363877+00	2026-07-20 09:59:26.363877+00	todo	\N	47	16.10	2026-07-24
a03a787d-b998-4a31-aa2e-2aef31ab5784	d6f8a913-4870-4aa5-a45f-e9c04e17b7fc	\N	276feb60-37b2-42ff-be39-f9e79af8ae2a	328fce4c-c7e7-4b44-8dcb-45aad65bd8e5	تهیهٔ پیش‌نویس بودجهٔ واحد #10	\N	medium	2026-07-28	14a82efe-7818-4fdd-bcef-eaa4e4fd8247	2026-07-20 09:59:26.363877+00	2026-07-20 09:59:26.363877+00	todo	\N	50	13.90	2026-07-22
a03a787d-b998-4a31-aa2e-2aef31ab5784	d6f8a913-4870-4aa5-a45f-e9c04e17b7fc	\N	c1eff56a-cf6f-4901-9c44-9063f53db8c8	328fce4c-c7e7-4b44-8dcb-45aad65bd8e5	تهیهٔ گزارش جریان نقدی #11	\N	low	2026-06-25	d0a748af-632e-4682-8c53-637046c6aea2	2026-07-20 09:59:26.363877+00	2026-07-20 09:59:26.363877+00	in_progress	\N	63	21.70	2026-06-23
a03a787d-b998-4a31-aa2e-2aef31ab5784	d6f8a913-4870-4aa5-a45f-e9c04e17b7fc	\N	767b011b-ff3a-4faf-b85b-c424554a44a0	328fce4c-c7e7-4b44-8dcb-45aad65bd8e5	تهیهٔ گزارش جریان نقدی #12	\N	medium	2026-07-12	48b06f21-f36d-4c2e-a995-319d3495a419	2026-07-20 09:59:26.363877+00	2026-07-20 09:59:26.363877+00	todo	\N	27	39.90	2026-07-02
a03a787d-b998-4a31-aa2e-2aef31ab5784	d6f8a913-4870-4aa5-a45f-e9c04e17b7fc	\N	c1eff56a-cf6f-4901-9c44-9063f53db8c8	328fce4c-c7e7-4b44-8dcb-45aad65bd8e5	تهیهٔ گزارش سود و زیان ماهانه #13	\N	low	2026-07-25	b37d8cc3-6d56-456d-ba16-73d574fe6c78	2026-07-20 09:59:26.363877+00	2026-07-20 09:59:26.363877+00	completed	rejected	100	34.40	2026-07-17
a03a787d-b998-4a31-aa2e-2aef31ab5784	d6f8a913-4870-4aa5-a45f-e9c04e17b7fc	\N	9c22bc65-2479-4780-b3a0-0ed5e139ee5f	328fce4c-c7e7-4b44-8dcb-45aad65bd8e5	تهیهٔ گزارش سود و زیان ماهانه #14	\N	high	2026-08-28	531b6a28-b471-44f3-b254-478ac0929434	2026-07-20 09:59:26.363877+00	2026-07-20 09:59:26.363877+00	todo	\N	40	27.40	2026-08-12
a03a787d-b998-4a31-aa2e-2aef31ab5784	d6f8a913-4870-4aa5-a45f-e9c04e17b7fc	\N	f2917b41-6f1c-4444-a73d-884a91e847fe	328fce4c-c7e7-4b44-8dcb-45aad65bd8e5	پیگیری مطالبات معوق مشتریان #15	\N	medium	2026-08-09	c80f6881-ade6-4a45-993f-67d8f5f5b377	2026-07-20 09:59:26.363877+00	2026-07-20 09:59:26.363877+00	todo	\N	20	29.00	2026-07-21
a03a787d-b998-4a31-aa2e-2aef31ab5784	d6f8a913-4870-4aa5-a45f-e9c04e17b7fc	\N	f2917b41-6f1c-4444-a73d-884a91e847fe	328fce4c-c7e7-4b44-8dcb-45aad65bd8e5	ثبت اسناد حسابداری هفتگی #16	\N	low	2026-07-27	ac6ce572-bba3-4ddb-b1d9-506d128f0df5	2026-07-20 09:59:26.363877+00	2026-07-20 09:59:26.363877+00	completed	approved	100	39.40	2026-07-09
a03a787d-b998-4a31-aa2e-2aef31ab5784	d6f8a913-4870-4aa5-a45f-e9c04e17b7fc	\N	276feb60-37b2-42ff-be39-f9e79af8ae2a	328fce4c-c7e7-4b44-8dcb-45aad65bd8e5	بررسی و تأیید صورت‌حساب‌های خرید #17	\N	medium	2026-07-18	bc891bb3-ab74-404d-8d73-12bb79fe47f9	2026-07-20 09:59:26.363877+00	2026-07-20 09:59:26.363877+00	todo	\N	70	23.70	2026-07-01
a03a787d-b998-4a31-aa2e-2aef31ab5784	d6f8a913-4870-4aa5-a45f-e9c04e17b7fc	\N	9c22bc65-2479-4780-b3a0-0ed5e139ee5f	328fce4c-c7e7-4b44-8dcb-45aad65bd8e5	تهیهٔ گزارش سود و زیان ماهانه #18	\N	medium	2026-08-15	8d8bd017-eaaf-4f21-a91d-73a928dddf1d	2026-07-20 09:59:26.363877+00	2026-07-20 09:59:26.363877+00	completed	approved	100	17.10	2026-08-11
a03a787d-b998-4a31-aa2e-2aef31ab5784	349ecde7-6ae3-4dbc-85ce-291df6cda967	\N	f2917b41-6f1c-4444-a73d-884a91e847fe	328fce4c-c7e7-4b44-8dcb-45aad65bd8e5	بررسی فاکتورهای فروش صادرشده #19	\N	medium	2026-08-03	339a7d65-3bc7-4cc2-ad87-a4beb491511d	2026-07-20 09:59:26.363877+00	2026-07-20 09:59:26.363877+00	archived	\N	73	4.80	2026-07-16
a03a787d-b998-4a31-aa2e-2aef31ab5784	349ecde7-6ae3-4dbc-85ce-291df6cda967	\N	c1eff56a-cf6f-4901-9c44-9063f53db8c8	328fce4c-c7e7-4b44-8dcb-45aad65bd8e5	تهیهٔ گزارش مالیاتی فصلی #20	\N	low	2026-08-02	fd5ede1a-65b0-4b66-a047-3ff639c3d0d5	2026-07-20 09:59:26.363877+00	2026-07-20 09:59:26.363877+00	completed	approved	100	35.40	2026-07-15
a03a787d-b998-4a31-aa2e-2aef31ab5784	349ecde7-6ae3-4dbc-85ce-291df6cda967	\N	276feb60-37b2-42ff-be39-f9e79af8ae2a	328fce4c-c7e7-4b44-8dcb-45aad65bd8e5	بررسی فاکتورهای فروش صادرشده #21	\N	high	2026-07-03	72e0a2f5-cafe-4c8f-b94d-6951235e8096	2026-07-20 09:59:26.363877+00	2026-07-20 09:59:26.363877+00	completed	pending	100	36.60	2026-06-27
a03a787d-b998-4a31-aa2e-2aef31ab5784	349ecde7-6ae3-4dbc-85ce-291df6cda967	\N	328fce4c-c7e7-4b44-8dcb-45aad65bd8e5	328fce4c-c7e7-4b44-8dcb-45aad65bd8e5	پیگیری مطالبات معوق مشتریان #22	\N	low	2026-07-25	2b683d2a-d9df-4dd9-b33f-5a5614b9dab4	2026-07-20 09:59:26.363877+00	2026-07-20 09:59:26.363877+00	todo	\N	20	14.30	2026-07-19
a03a787d-b998-4a31-aa2e-2aef31ab5784	349ecde7-6ae3-4dbc-85ce-291df6cda967	\N	f2917b41-6f1c-4444-a73d-884a91e847fe	328fce4c-c7e7-4b44-8dcb-45aad65bd8e5	بررسی قراردادهای مالی جدید #23	\N	medium	2026-07-26	69ece2e8-7a04-4d2c-b170-5e5a0c81529b	2026-07-20 09:59:26.363877+00	2026-07-20 09:59:26.363877+00	in_progress	\N	10	11.50	2026-07-08
a03a787d-b998-4a31-aa2e-2aef31ab5784	349ecde7-6ae3-4dbc-85ce-291df6cda967	\N	f2917b41-6f1c-4444-a73d-884a91e847fe	328fce4c-c7e7-4b44-8dcb-45aad65bd8e5	بررسی صورت وضعیت پیمانکاران #24	\N	high	2026-08-06	6c9e9812-65e9-4e9f-bddb-c86c88766c28	2026-07-20 09:59:26.363877+00	2026-07-20 09:59:26.363877+00	completed	approved	100	5.60	2026-07-26
a03a787d-b998-4a31-aa2e-2aef31ab5784	349ecde7-6ae3-4dbc-85ce-291df6cda967	\N	f2917b41-6f1c-4444-a73d-884a91e847fe	328fce4c-c7e7-4b44-8dcb-45aad65bd8e5	مغایرت‌گیری حساب‌های بانکی #25	\N	low	2026-08-12	681b419c-ac30-4485-8bf5-1249350dbd78	2026-07-20 09:59:26.363877+00	2026-07-20 09:59:26.363877+00	todo	\N	79	29.40	2026-07-23
a03a787d-b998-4a31-aa2e-2aef31ab5784	349ecde7-6ae3-4dbc-85ce-291df6cda967	\N	767b011b-ff3a-4faf-b85b-c424554a44a0	328fce4c-c7e7-4b44-8dcb-45aad65bd8e5	بررسی و تأیید صورت‌حساب‌های خرید #26	\N	low	2026-08-28	e05c4036-c226-4d2d-94bb-49e2b786f03b	2026-07-20 09:59:26.363877+00	2026-07-20 09:59:26.363877+00	in_progress	\N	10	3.70	2026-08-08
a03a787d-b998-4a31-aa2e-2aef31ab5784	349ecde7-6ae3-4dbc-85ce-291df6cda967	\N	f2917b41-6f1c-4444-a73d-884a91e847fe	328fce4c-c7e7-4b44-8dcb-45aad65bd8e5	تطبیق موجودی انبار با حساب‌ها #27	\N	low	2026-08-01	39fc0058-27d3-4ad8-9445-5eb609ea0415	2026-07-20 09:59:26.363877+00	2026-07-20 09:59:26.363877+00	archived	\N	73	17.80	2026-07-22
a03a787d-b998-4a31-aa2e-2aef31ab5784	349ecde7-6ae3-4dbc-85ce-291df6cda967	\N	f2917b41-6f1c-4444-a73d-884a91e847fe	328fce4c-c7e7-4b44-8dcb-45aad65bd8e5	پیگیری مطالبات معوق مشتریان #28	\N	high	2026-08-05	43593206-674b-4a84-8f81-ef37d7ba17b3	2026-07-20 09:59:26.363877+00	2026-07-20 09:59:26.363877+00	todo	\N	38	20.40	2026-07-17
a03a787d-b998-4a31-aa2e-2aef31ab5784	349ecde7-6ae3-4dbc-85ce-291df6cda967	\N	276feb60-37b2-42ff-be39-f9e79af8ae2a	328fce4c-c7e7-4b44-8dcb-45aad65bd8e5	تهیهٔ گزارش جریان نقدی #29	\N	low	2026-07-19	d80b6d81-8e2e-498f-9653-97dcdade0eb4	2026-07-20 09:59:26.363877+00	2026-07-20 09:59:26.363877+00	completed	approved	100	8.00	2026-07-15
a03a787d-b998-4a31-aa2e-2aef31ab5784	349ecde7-6ae3-4dbc-85ce-291df6cda967	\N	9c22bc65-2479-4780-b3a0-0ed5e139ee5f	328fce4c-c7e7-4b44-8dcb-45aad65bd8e5	مغایرت‌گیری حساب‌های بانکی #30	\N	medium	2026-07-28	47e13583-eac2-415c-8caf-3d05574dc4a7	2026-07-20 09:59:26.363877+00	2026-07-20 09:59:26.363877+00	completed	approved	100	34.70	2026-07-07
a03a787d-b998-4a31-aa2e-2aef31ab5784	349ecde7-6ae3-4dbc-85ce-291df6cda967	\N	c1eff56a-cf6f-4901-9c44-9063f53db8c8	328fce4c-c7e7-4b44-8dcb-45aad65bd8e5	بررسی فاکتورهای فروش صادرشده #31	\N	low	2026-08-23	0d8c4d5b-fdff-49bb-a417-183eaf90c6a6	2026-07-20 09:59:26.363877+00	2026-07-20 09:59:26.363877+00	archived	\N	47	21.60	2026-08-10
a03a787d-b998-4a31-aa2e-2aef31ab5784	349ecde7-6ae3-4dbc-85ce-291df6cda967	\N	328fce4c-c7e7-4b44-8dcb-45aad65bd8e5	328fce4c-c7e7-4b44-8dcb-45aad65bd8e5	تهیهٔ گزارش سود و زیان ماهانه #32	\N	medium	2026-07-17	26703eaf-1795-4473-9456-bb8c896f9282	2026-07-20 09:59:26.363877+00	2026-07-20 09:59:26.363877+00	in_progress	\N	57	11.40	2026-07-01
a03a787d-b998-4a31-aa2e-2aef31ab5784	349ecde7-6ae3-4dbc-85ce-291df6cda967	\N	328fce4c-c7e7-4b44-8dcb-45aad65bd8e5	328fce4c-c7e7-4b44-8dcb-45aad65bd8e5	پیگیری بیمهٔ کارکنان #33	\N	high	2026-07-18	c17c5035-0243-4642-a99f-ab55766d4e76	2026-07-20 09:59:26.363877+00	2026-07-20 09:59:26.363877+00	todo	\N	53	11.40	2026-07-04
a03a787d-b998-4a31-aa2e-2aef31ab5784	349ecde7-6ae3-4dbc-85ce-291df6cda967	\N	276feb60-37b2-42ff-be39-f9e79af8ae2a	328fce4c-c7e7-4b44-8dcb-45aad65bd8e5	بررسی قراردادهای مالی جدید #34	\N	high	2026-08-19	1238a3a0-7591-462e-99d3-b2610a5c3d3f	2026-07-20 09:59:26.363877+00	2026-07-20 09:59:26.363877+00	todo	\N	40	9.20	2026-08-07
a03a787d-b998-4a31-aa2e-2aef31ab5784	349ecde7-6ae3-4dbc-85ce-291df6cda967	\N	1775df44-8335-487a-9a3b-a1a6eb5949f5	328fce4c-c7e7-4b44-8dcb-45aad65bd8e5	بررسی قراردادهای مالی جدید #35	\N	medium	2026-08-01	b1623dbf-68b9-4f79-b7cc-b60ec24c9c1f	2026-07-20 09:59:26.363877+00	2026-07-20 09:59:26.363877+00	completed	rejected	100	20.90	2026-07-15
a03a787d-b998-4a31-aa2e-2aef31ab5784	349ecde7-6ae3-4dbc-85ce-291df6cda967	\N	328fce4c-c7e7-4b44-8dcb-45aad65bd8e5	328fce4c-c7e7-4b44-8dcb-45aad65bd8e5	ثبت اسناد حسابداری هفتگی #36	\N	low	2026-08-03	82ba62d6-38b5-4401-b3d0-654d0d6e9555	2026-07-20 09:59:26.363877+00	2026-07-20 09:59:26.363877+00	in_progress	\N	74	15.40	2026-07-18
a03a787d-b998-4a31-aa2e-2aef31ab5784	1fbf1e47-ab67-430d-841c-ca56a83c091e	\N	328fce4c-c7e7-4b44-8dcb-45aad65bd8e5	328fce4c-c7e7-4b44-8dcb-45aad65bd8e5	بررسی قراردادهای مالی جدید #37	\N	high	2026-08-07	201721e4-774b-4680-8f11-2a98ebcccdd3	2026-07-20 09:59:26.363877+00	2026-07-20 09:59:26.363877+00	in_progress	\N	60	12.90	2026-07-17
a03a787d-b998-4a31-aa2e-2aef31ab5784	1fbf1e47-ab67-430d-841c-ca56a83c091e	\N	328fce4c-c7e7-4b44-8dcb-45aad65bd8e5	328fce4c-c7e7-4b44-8dcb-45aad65bd8e5	بررسی قراردادهای مالی جدید #38	\N	medium	2026-07-19	0eb21822-0c7d-4e53-a412-b8517aebac4b	2026-07-20 09:59:26.363877+00	2026-07-20 09:59:26.363877+00	todo	\N	46	31.00	2026-07-13
a03a787d-b998-4a31-aa2e-2aef31ab5784	1fbf1e47-ab67-430d-841c-ca56a83c091e	\N	c1eff56a-cf6f-4901-9c44-9063f53db8c8	328fce4c-c7e7-4b44-8dcb-45aad65bd8e5	بررسی صورت وضعیت پیمانکاران #39	\N	high	2026-07-14	e60a3c52-07d6-4cd2-89d7-5273b0fb2fd3	2026-07-20 09:59:26.363877+00	2026-07-20 09:59:26.363877+00	todo	\N	24	15.80	2026-07-11
a03a787d-b998-4a31-aa2e-2aef31ab5784	1fbf1e47-ab67-430d-841c-ca56a83c091e	\N	c1eff56a-cf6f-4901-9c44-9063f53db8c8	328fce4c-c7e7-4b44-8dcb-45aad65bd8e5	به‌روزرسانی جدول حقوق و دستمزد #40	\N	high	2026-07-28	66d4fbca-fcfd-4d62-95ad-55748aa0e26c	2026-07-20 09:59:26.363877+00	2026-07-20 09:59:26.363877+00	todo	\N	35	33.40	2026-07-10
a03a787d-b998-4a31-aa2e-2aef31ab5784	1fbf1e47-ab67-430d-841c-ca56a83c091e	\N	767b011b-ff3a-4faf-b85b-c424554a44a0	328fce4c-c7e7-4b44-8dcb-45aad65bd8e5	بررسی فاکتورهای فروش صادرشده #41	\N	medium	2026-06-29	2bc6e958-b864-4ae3-b241-23627f96fb7c	2026-07-20 09:59:26.363877+00	2026-07-20 09:59:26.363877+00	completed	pending	100	32.20	2026-06-24
a03a787d-b998-4a31-aa2e-2aef31ab5784	1fbf1e47-ab67-430d-841c-ca56a83c091e	\N	c1eff56a-cf6f-4901-9c44-9063f53db8c8	328fce4c-c7e7-4b44-8dcb-45aad65bd8e5	ثبت اسناد حسابداری هفتگی #42	\N	high	2026-08-09	544de8f4-ac41-41c1-a64b-43d36094afe3	2026-07-20 09:59:26.363877+00	2026-07-20 09:59:26.363877+00	completed	rejected	100	21.30	2026-08-03
a03a787d-b998-4a31-aa2e-2aef31ab5784	1fbf1e47-ab67-430d-841c-ca56a83c091e	\N	767b011b-ff3a-4faf-b85b-c424554a44a0	328fce4c-c7e7-4b44-8dcb-45aad65bd8e5	مغایرت‌گیری حساب‌های بانکی #43	\N	high	2026-06-21	9c6014bd-1e23-4bb0-981e-29805ed218cb	2026-07-20 09:59:26.363877+00	2026-07-20 09:59:26.363877+00	todo	\N	42	32.60	2026-06-18
a03a787d-b998-4a31-aa2e-2aef31ab5784	1fbf1e47-ab67-430d-841c-ca56a83c091e	\N	767b011b-ff3a-4faf-b85b-c424554a44a0	328fce4c-c7e7-4b44-8dcb-45aad65bd8e5	مغایرت‌گیری حساب‌های بانکی #44	\N	medium	2026-08-30	9057f71b-abea-4aae-9f30-89ef1f0a84f6	2026-07-20 09:59:26.363877+00	2026-07-20 09:59:26.363877+00	completed	approved	100	37.40	2026-08-12
a03a787d-b998-4a31-aa2e-2aef31ab5784	1fbf1e47-ab67-430d-841c-ca56a83c091e	\N	c1eff56a-cf6f-4901-9c44-9063f53db8c8	328fce4c-c7e7-4b44-8dcb-45aad65bd8e5	تهیهٔ گزارش جریان نقدی #45	\N	medium	2026-08-01	211f4d0a-0dd1-45d3-bed4-fc1836b39db7	2026-07-20 09:59:26.363877+00	2026-07-20 09:59:26.363877+00	todo	\N	75	14.80	2026-07-11
a03a787d-b998-4a31-aa2e-2aef31ab5784	1fbf1e47-ab67-430d-841c-ca56a83c091e	\N	276feb60-37b2-42ff-be39-f9e79af8ae2a	328fce4c-c7e7-4b44-8dcb-45aad65bd8e5	پیگیری مطالبات معوق مشتریان #46	\N	medium	2026-08-20	25c364b1-a0a3-46c6-a5e4-f68dbc0b8a49	2026-07-20 09:59:26.363877+00	2026-07-20 09:59:26.363877+00	completed	approved	100	33.00	2026-07-31
a03a787d-b998-4a31-aa2e-2aef31ab5784	1fbf1e47-ab67-430d-841c-ca56a83c091e	\N	c1eff56a-cf6f-4901-9c44-9063f53db8c8	328fce4c-c7e7-4b44-8dcb-45aad65bd8e5	بررسی فاکتورهای فروش صادرشده #47	\N	high	2026-08-03	836031d4-f867-413f-a9e5-8891bbc7fd58	2026-07-20 09:59:26.363877+00	2026-07-20 09:59:26.363877+00	in_progress	\N	39	32.30	2026-07-29
a03a787d-b998-4a31-aa2e-2aef31ab5784	1fbf1e47-ab67-430d-841c-ca56a83c091e	\N	f2917b41-6f1c-4444-a73d-884a91e847fe	328fce4c-c7e7-4b44-8dcb-45aad65bd8e5	پیگیری مطالبات معوق مشتریان #48	\N	high	2026-08-10	ae7a8213-ca2b-4903-89da-de31978a2e8b	2026-07-20 09:59:26.363877+00	2026-07-20 09:59:26.363877+00	completed	pending	100	31.80	2026-07-24
a03a787d-b998-4a31-aa2e-2aef31ab5784	1fbf1e47-ab67-430d-841c-ca56a83c091e	\N	276feb60-37b2-42ff-be39-f9e79af8ae2a	328fce4c-c7e7-4b44-8dcb-45aad65bd8e5	بررسی صورت وضعیت پیمانکاران #49	\N	medium	2026-08-04	1f5fdd86-102a-4348-9ced-30645af612bb	2026-07-20 09:59:26.363877+00	2026-07-20 09:59:26.363877+00	completed	approved	100	8.50	2026-08-01
a03a787d-b998-4a31-aa2e-2aef31ab5784	1fbf1e47-ab67-430d-841c-ca56a83c091e	\N	f2917b41-6f1c-4444-a73d-884a91e847fe	328fce4c-c7e7-4b44-8dcb-45aad65bd8e5	مغایرت‌گیری حساب‌های بانکی #50	\N	high	2026-08-08	42fc6f61-5d94-4dac-9e8d-a0cf1b529886	2026-07-20 09:59:26.363877+00	2026-07-20 09:59:26.363877+00	archived	\N	31	3.20	2026-07-25
a03a787d-b998-4a31-aa2e-2aef31ab5784	1fbf1e47-ab67-430d-841c-ca56a83c091e	\N	f2917b41-6f1c-4444-a73d-884a91e847fe	328fce4c-c7e7-4b44-8dcb-45aad65bd8e5	به‌روزرسانی جدول حقوق و دستمزد #51	\N	medium	2026-06-30	17188b77-b6bf-414c-a805-142bb4ac8bd4	2026-07-20 09:59:26.363877+00	2026-07-20 09:59:26.363877+00	todo	\N	53	7.80	2026-06-28
a03a787d-b998-4a31-aa2e-2aef31ab5784	1fbf1e47-ab67-430d-841c-ca56a83c091e	\N	f2917b41-6f1c-4444-a73d-884a91e847fe	328fce4c-c7e7-4b44-8dcb-45aad65bd8e5	بررسی و تسویهٔ کارت اعتباری شرکت #52	\N	high	2026-07-30	2dfb3f83-275c-4f27-8cdd-88799b2e4721	2026-07-20 09:59:26.363877+00	2026-07-20 09:59:26.363877+00	in_progress	\N	60	35.20	2026-07-12
a03a787d-b998-4a31-aa2e-2aef31ab5784	1fbf1e47-ab67-430d-841c-ca56a83c091e	\N	f2917b41-6f1c-4444-a73d-884a91e847fe	328fce4c-c7e7-4b44-8dcb-45aad65bd8e5	تهیهٔ پیش‌نویس بودجهٔ واحد #53	\N	low	2026-06-25	26f4b33e-4b67-4d08-a323-a4b5093d4fe2	2026-07-20 09:59:26.363877+00	2026-07-20 09:59:26.363877+00	archived	\N	71	14.40	2026-06-19
a03a787d-b998-4a31-aa2e-2aef31ab5784	1fbf1e47-ab67-430d-841c-ca56a83c091e	\N	f2917b41-6f1c-4444-a73d-884a91e847fe	328fce4c-c7e7-4b44-8dcb-45aad65bd8e5	به‌روزرسانی جدول حقوق و دستمزد #54	\N	high	2026-07-13	43a24e56-7465-4283-8a34-1b560c3f12b3	2026-07-20 09:59:26.363877+00	2026-07-20 09:59:26.363877+00	completed	approved	100	15.00	2026-07-06
a03a787d-b998-4a31-aa2e-2aef31ab5784	718abbd9-dab5-433d-bd20-046f3974f6ef	\N	c1eff56a-cf6f-4901-9c44-9063f53db8c8	328fce4c-c7e7-4b44-8dcb-45aad65bd8e5	بررسی صورت وضعیت پیمانکاران #55	\N	medium	2026-08-11	9871880d-37c7-4a8c-96d6-9ce6c72f88d3	2026-07-20 09:59:26.363877+00	2026-07-20 09:59:26.363877+00	completed	pending	100	9.30	2026-08-01
a03a787d-b998-4a31-aa2e-2aef31ab5784	718abbd9-dab5-433d-bd20-046f3974f6ef	\N	1775df44-8335-487a-9a3b-a1a6eb5949f5	328fce4c-c7e7-4b44-8dcb-45aad65bd8e5	ثبت اسناد حسابداری هفتگی #56	\N	medium	2026-08-01	dbdd5e88-519c-42ae-9240-c2123ed24ace	2026-07-20 09:59:26.363877+00	2026-07-20 09:59:26.363877+00	in_progress	\N	36	28.80	2026-07-21
a03a787d-b998-4a31-aa2e-2aef31ab5784	718abbd9-dab5-433d-bd20-046f3974f6ef	\N	f2917b41-6f1c-4444-a73d-884a91e847fe	328fce4c-c7e7-4b44-8dcb-45aad65bd8e5	به‌روزرسانی جدول حقوق و دستمزد #57	\N	medium	2026-07-29	807af3a5-a701-4a73-9dff-178000372c84	2026-07-20 09:59:26.363877+00	2026-07-20 09:59:26.363877+00	archived	\N	71	37.50	2026-07-17
a03a787d-b998-4a31-aa2e-2aef31ab5784	718abbd9-dab5-433d-bd20-046f3974f6ef	\N	276feb60-37b2-42ff-be39-f9e79af8ae2a	328fce4c-c7e7-4b44-8dcb-45aad65bd8e5	تهیهٔ گزارش سود و زیان ماهانه #58	\N	high	2026-07-14	06727d14-05f5-4caa-b1bf-d1411268b8a1	2026-07-20 09:59:26.363877+00	2026-07-20 09:59:26.363877+00	archived	\N	69	16.40	2026-07-03
a03a787d-b998-4a31-aa2e-2aef31ab5784	718abbd9-dab5-433d-bd20-046f3974f6ef	\N	9c22bc65-2479-4780-b3a0-0ed5e139ee5f	328fce4c-c7e7-4b44-8dcb-45aad65bd8e5	پیگیری مطالبات معوق مشتریان #59	\N	low	2026-08-10	e77cfef8-1b7b-44ab-9258-25e8af194279	2026-07-20 09:59:26.363877+00	2026-07-20 09:59:26.363877+00	in_progress	\N	36	38.30	2026-08-04
a03a787d-b998-4a31-aa2e-2aef31ab5784	718abbd9-dab5-433d-bd20-046f3974f6ef	\N	328fce4c-c7e7-4b44-8dcb-45aad65bd8e5	328fce4c-c7e7-4b44-8dcb-45aad65bd8e5	تطبیق موجودی انبار با حساب‌ها #60	\N	medium	2026-08-30	d6657387-6096-497b-9a0b-781b8bbab764	2026-07-20 09:59:26.363877+00	2026-07-20 09:59:26.363877+00	in_progress	\N	61	10.10	2026-08-14
a03a787d-b998-4a31-aa2e-2aef31ab5784	718abbd9-dab5-433d-bd20-046f3974f6ef	\N	276feb60-37b2-42ff-be39-f9e79af8ae2a	328fce4c-c7e7-4b44-8dcb-45aad65bd8e5	مغایرت‌گیری حساب‌های بانکی #61	\N	low	2026-07-31	b1f2b8bb-d944-439f-ac99-afe272d791ce	2026-07-20 09:59:26.363877+00	2026-07-20 09:59:26.363877+00	completed	approved	100	25.40	2026-07-21
a03a787d-b998-4a31-aa2e-2aef31ab5784	718abbd9-dab5-433d-bd20-046f3974f6ef	\N	767b011b-ff3a-4faf-b85b-c424554a44a0	328fce4c-c7e7-4b44-8dcb-45aad65bd8e5	تطبیق موجودی انبار با حساب‌ها #62	\N	high	2026-07-04	5b95558f-9bde-478f-9a27-96756e679890	2026-07-20 09:59:26.363877+00	2026-07-20 09:59:26.363877+00	in_progress	\N	28	26.20	2026-07-01
a03a787d-b998-4a31-aa2e-2aef31ab5784	718abbd9-dab5-433d-bd20-046f3974f6ef	\N	328fce4c-c7e7-4b44-8dcb-45aad65bd8e5	328fce4c-c7e7-4b44-8dcb-45aad65bd8e5	تهیهٔ گزارش جریان نقدی #63	\N	medium	2026-07-24	2670f438-0c06-484e-8011-566f9b32b5c5	2026-07-20 09:59:26.363877+00	2026-07-20 09:59:26.363877+00	todo	\N	12	27.90	2026-07-12
a03a787d-b998-4a31-aa2e-2aef31ab5784	718abbd9-dab5-433d-bd20-046f3974f6ef	\N	1775df44-8335-487a-9a3b-a1a6eb5949f5	328fce4c-c7e7-4b44-8dcb-45aad65bd8e5	بررسی فاکتورهای فروش صادرشده #64	\N	high	2026-07-28	4f52567e-cf3f-4bc7-9936-0ee6b84fe543	2026-07-20 09:59:26.363877+00	2026-07-20 09:59:26.363877+00	todo	\N	60	20.10	2026-07-21
a03a787d-b998-4a31-aa2e-2aef31ab5784	718abbd9-dab5-433d-bd20-046f3974f6ef	\N	1775df44-8335-487a-9a3b-a1a6eb5949f5	328fce4c-c7e7-4b44-8dcb-45aad65bd8e5	پیگیری مطالبات معوق مشتریان #65	\N	high	2026-07-16	835843bc-e689-4451-803c-8b1c80fd7ee6	2026-07-20 09:59:26.363877+00	2026-07-20 09:59:26.363877+00	archived	\N	7	36.50	2026-07-04
a03a787d-b998-4a31-aa2e-2aef31ab5784	718abbd9-dab5-433d-bd20-046f3974f6ef	\N	328fce4c-c7e7-4b44-8dcb-45aad65bd8e5	328fce4c-c7e7-4b44-8dcb-45aad65bd8e5	بررسی قراردادهای مالی جدید #66	\N	low	2026-07-23	3644e178-6228-4314-a56d-a28f63cc7fc6	2026-07-20 09:59:26.363877+00	2026-07-20 09:59:26.363877+00	completed	approved	100	17.90	2026-07-20
a03a787d-b998-4a31-aa2e-2aef31ab5784	718abbd9-dab5-433d-bd20-046f3974f6ef	\N	276feb60-37b2-42ff-be39-f9e79af8ae2a	328fce4c-c7e7-4b44-8dcb-45aad65bd8e5	پیگیری بیمهٔ کارکنان #67	\N	medium	2026-08-17	2682206f-0a63-4285-9b7e-30e4441631e7	2026-07-20 09:59:26.363877+00	2026-07-20 09:59:26.363877+00	todo	\N	63	9.10	2026-08-14
a03a787d-b998-4a31-aa2e-2aef31ab5784	718abbd9-dab5-433d-bd20-046f3974f6ef	\N	f2917b41-6f1c-4444-a73d-884a91e847fe	328fce4c-c7e7-4b44-8dcb-45aad65bd8e5	بررسی و تأیید صورت‌حساب‌های خرید #68	\N	medium	2026-08-14	c1e6700c-db11-4a96-a379-53ef14a78809	2026-07-20 09:59:26.363877+00	2026-07-20 09:59:26.363877+00	in_progress	\N	72	24.90	2026-08-11
a03a787d-b998-4a31-aa2e-2aef31ab5784	718abbd9-dab5-433d-bd20-046f3974f6ef	\N	c1eff56a-cf6f-4901-9c44-9063f53db8c8	328fce4c-c7e7-4b44-8dcb-45aad65bd8e5	تهیهٔ پیش‌نویس بودجهٔ واحد #69	\N	medium	2026-08-03	081a1c29-6eb4-4a8a-8d20-70a7c844d562	2026-07-20 09:59:26.363877+00	2026-07-20 09:59:26.363877+00	in_progress	\N	17	34.30	2026-07-15
a03a787d-b998-4a31-aa2e-2aef31ab5784	718abbd9-dab5-433d-bd20-046f3974f6ef	\N	9c22bc65-2479-4780-b3a0-0ed5e139ee5f	328fce4c-c7e7-4b44-8dcb-45aad65bd8e5	تهیهٔ گزارش مالیاتی فصلی #70	\N	low	2026-07-03	fae2d2e9-b1b2-4ab4-9f2e-07d1e8e04814	2026-07-20 09:59:26.363877+00	2026-07-20 09:59:26.363877+00	in_progress	\N	58	26.60	2026-06-28
a03a787d-b998-4a31-aa2e-2aef31ab5784	718abbd9-dab5-433d-bd20-046f3974f6ef	\N	f2917b41-6f1c-4444-a73d-884a91e847fe	328fce4c-c7e7-4b44-8dcb-45aad65bd8e5	بررسی و تسویهٔ کارت اعتباری شرکت #71	\N	medium	2026-06-28	d957d0cd-3aa2-4770-b055-9ea30099e43e	2026-07-20 09:59:26.363877+00	2026-07-20 09:59:26.363877+00	todo	\N	72	27.60	2026-06-16
a03a787d-b998-4a31-aa2e-2aef31ab5784	718abbd9-dab5-433d-bd20-046f3974f6ef	\N	1775df44-8335-487a-9a3b-a1a6eb5949f5	328fce4c-c7e7-4b44-8dcb-45aad65bd8e5	پیگیری بیمهٔ کارکنان #72	\N	medium	2026-08-08	da1f03f1-698b-40b7-abd4-48e2dab71262	2026-07-20 09:59:26.363877+00	2026-07-20 09:59:26.363877+00	todo	\N	65	14.50	2026-07-25
a03a787d-b998-4a31-aa2e-2aef31ab5784	cb1c5120-3d84-4bc6-b309-5985dd7264ed	\N	9c22bc65-2479-4780-b3a0-0ed5e139ee5f	328fce4c-c7e7-4b44-8dcb-45aad65bd8e5	تهیهٔ گزارش مالیاتی فصلی #73	\N	low	2026-07-11	4cb43177-e012-428b-b7b6-0ae2e3586445	2026-07-20 09:59:26.363877+00	2026-07-20 09:59:26.363877+00	completed	approved	100	2.30	2026-06-24
a03a787d-b998-4a31-aa2e-2aef31ab5784	cb1c5120-3d84-4bc6-b309-5985dd7264ed	\N	9c22bc65-2479-4780-b3a0-0ed5e139ee5f	328fce4c-c7e7-4b44-8dcb-45aad65bd8e5	تهیهٔ گزارش مالیاتی فصلی #74	\N	medium	2026-07-24	b9c4e8e0-5509-4325-901e-535d71ac7b5e	2026-07-20 09:59:26.363877+00	2026-07-20 09:59:26.363877+00	in_progress	\N	74	29.50	2026-07-14
a03a787d-b998-4a31-aa2e-2aef31ab5784	cb1c5120-3d84-4bc6-b309-5985dd7264ed	\N	328fce4c-c7e7-4b44-8dcb-45aad65bd8e5	328fce4c-c7e7-4b44-8dcb-45aad65bd8e5	تهیهٔ گزارش جریان نقدی #75	\N	low	2026-08-09	735208bc-cde4-4522-8d7f-db62cf545fed	2026-07-20 09:59:26.363877+00	2026-07-20 09:59:26.363877+00	in_progress	\N	7	27.40	2026-07-27
a03a787d-b998-4a31-aa2e-2aef31ab5784	cb1c5120-3d84-4bc6-b309-5985dd7264ed	\N	9c22bc65-2479-4780-b3a0-0ed5e139ee5f	328fce4c-c7e7-4b44-8dcb-45aad65bd8e5	تطبیق موجودی انبار با حساب‌ها #76	\N	high	2026-07-10	ad170516-00e3-4ac5-b52c-636892b3334f	2026-07-20 09:59:26.363877+00	2026-07-20 09:59:26.363877+00	in_progress	\N	39	28.20	2026-06-26
a03a787d-b998-4a31-aa2e-2aef31ab5784	cb1c5120-3d84-4bc6-b309-5985dd7264ed	\N	f2917b41-6f1c-4444-a73d-884a91e847fe	328fce4c-c7e7-4b44-8dcb-45aad65bd8e5	ثبت اسناد حسابداری هفتگی #77	\N	low	2026-07-30	a10ca374-4d8c-4d32-86c5-7219b483859a	2026-07-20 09:59:26.363877+00	2026-07-20 09:59:26.363877+00	in_progress	\N	17	20.20	2026-07-09
a03a787d-b998-4a31-aa2e-2aef31ab5784	cb1c5120-3d84-4bc6-b309-5985dd7264ed	\N	9c22bc65-2479-4780-b3a0-0ed5e139ee5f	328fce4c-c7e7-4b44-8dcb-45aad65bd8e5	بررسی فاکتورهای فروش صادرشده #78	\N	high	2026-08-06	c40a8535-1126-43a2-acaa-6803c4f7e5d3	2026-07-20 09:59:26.363877+00	2026-07-20 09:59:26.363877+00	archived	\N	70	36.70	2026-07-24
a03a787d-b998-4a31-aa2e-2aef31ab5784	cb1c5120-3d84-4bc6-b309-5985dd7264ed	\N	276feb60-37b2-42ff-be39-f9e79af8ae2a	328fce4c-c7e7-4b44-8dcb-45aad65bd8e5	بررسی و تسویهٔ کارت اعتباری شرکت #79	\N	low	2026-08-15	fed5f6fb-8c42-4b24-ba08-0f30ef139073	2026-07-20 09:59:26.363877+00	2026-07-20 09:59:26.363877+00	completed	pending	100	27.90	2026-08-07
a03a787d-b998-4a31-aa2e-2aef31ab5784	cb1c5120-3d84-4bc6-b309-5985dd7264ed	\N	767b011b-ff3a-4faf-b85b-c424554a44a0	328fce4c-c7e7-4b44-8dcb-45aad65bd8e5	تهیهٔ پیش‌نویس بودجهٔ واحد #80	\N	high	2026-08-04	03c6d91b-b757-4d03-a421-a1d437fa289e	2026-07-20 09:59:26.363877+00	2026-07-20 09:59:26.363877+00	todo	\N	46	5.00	2026-07-19
a03a787d-b998-4a31-aa2e-2aef31ab5784	cb1c5120-3d84-4bc6-b309-5985dd7264ed	\N	767b011b-ff3a-4faf-b85b-c424554a44a0	328fce4c-c7e7-4b44-8dcb-45aad65bd8e5	بررسی قراردادهای مالی جدید #81	\N	high	2026-07-08	4f9f44a3-6298-42cd-a4cd-2f4597b04ac7	2026-07-20 09:59:26.363877+00	2026-07-20 09:59:26.363877+00	todo	\N	25	23.80	2026-06-19
a03a787d-b998-4a31-aa2e-2aef31ab5784	cb1c5120-3d84-4bc6-b309-5985dd7264ed	\N	1775df44-8335-487a-9a3b-a1a6eb5949f5	328fce4c-c7e7-4b44-8dcb-45aad65bd8e5	به‌روزرسانی جدول حقوق و دستمزد #82	\N	low	2026-07-24	e9dab3b6-74ca-4741-9890-2729265b1696	2026-07-20 09:59:26.363877+00	2026-07-20 09:59:26.363877+00	todo	\N	26	29.20	2026-07-06
a03a787d-b998-4a31-aa2e-2aef31ab5784	cb1c5120-3d84-4bc6-b309-5985dd7264ed	\N	9c22bc65-2479-4780-b3a0-0ed5e139ee5f	328fce4c-c7e7-4b44-8dcb-45aad65bd8e5	به‌روزرسانی جدول حقوق و دستمزد #83	\N	low	2026-08-30	70268ca1-a2ce-40ef-a1b0-c1bec7223b4a	2026-07-20 09:59:26.363877+00	2026-07-20 09:59:26.363877+00	todo	\N	58	7.00	2026-08-12
a03a787d-b998-4a31-aa2e-2aef31ab5784	cb1c5120-3d84-4bc6-b309-5985dd7264ed	\N	9c22bc65-2479-4780-b3a0-0ed5e139ee5f	328fce4c-c7e7-4b44-8dcb-45aad65bd8e5	تطبیق موجودی انبار با حساب‌ها #84	\N	medium	2026-08-06	617e31ab-6faa-4a51-a9b0-a98ef40e2656	2026-07-20 09:59:26.363877+00	2026-07-20 09:59:26.363877+00	completed	approved	100	29.50	2026-07-21
a03a787d-b998-4a31-aa2e-2aef31ab5784	cb1c5120-3d84-4bc6-b309-5985dd7264ed	\N	9c22bc65-2479-4780-b3a0-0ed5e139ee5f	328fce4c-c7e7-4b44-8dcb-45aad65bd8e5	تهیهٔ گزارش جریان نقدی #85	\N	low	2026-08-09	d5fc9267-1f2b-4bf1-af59-7615e47abdab	2026-07-20 09:59:26.363877+00	2026-07-20 09:59:26.363877+00	in_progress	\N	74	4.80	2026-08-07
a03a787d-b998-4a31-aa2e-2aef31ab5784	cb1c5120-3d84-4bc6-b309-5985dd7264ed	\N	9c22bc65-2479-4780-b3a0-0ed5e139ee5f	328fce4c-c7e7-4b44-8dcb-45aad65bd8e5	تهیهٔ پیش‌نویس بودجهٔ واحد #86	\N	low	2026-08-03	942036ff-c665-46ca-81eb-1d50d7b9e600	2026-07-20 09:59:26.363877+00	2026-07-20 09:59:26.363877+00	in_progress	\N	8	39.50	2026-07-30
a03a787d-b998-4a31-aa2e-2aef31ab5784	cb1c5120-3d84-4bc6-b309-5985dd7264ed	\N	9c22bc65-2479-4780-b3a0-0ed5e139ee5f	328fce4c-c7e7-4b44-8dcb-45aad65bd8e5	مغایرت‌گیری حساب‌های بانکی #87	\N	low	2026-07-19	ff65557b-71fb-469d-b976-c623f13de0ae	2026-07-20 09:59:26.363877+00	2026-07-20 09:59:26.363877+00	todo	\N	53	16.20	2026-07-04
a03a787d-b998-4a31-aa2e-2aef31ab5784	cb1c5120-3d84-4bc6-b309-5985dd7264ed	\N	9c22bc65-2479-4780-b3a0-0ed5e139ee5f	328fce4c-c7e7-4b44-8dcb-45aad65bd8e5	بررسی فاکتورهای فروش صادرشده #88	\N	low	2026-08-27	688cc48e-af22-4da4-be66-5202ca6c27aa	2026-07-20 09:59:26.363877+00	2026-07-20 09:59:26.363877+00	completed	pending	100	27.90	2026-08-13
a03a787d-b998-4a31-aa2e-2aef31ab5784	cb1c5120-3d84-4bc6-b309-5985dd7264ed	\N	f2917b41-6f1c-4444-a73d-884a91e847fe	328fce4c-c7e7-4b44-8dcb-45aad65bd8e5	تهیهٔ گزارش سود و زیان ماهانه #89	\N	low	2026-08-23	9111fae1-c6be-4d1c-a7b1-c5418c69c58a	2026-07-20 09:59:26.363877+00	2026-07-20 09:59:26.363877+00	completed	approved	100	39.70	2026-08-10
a03a787d-b998-4a31-aa2e-2aef31ab5784	cb1c5120-3d84-4bc6-b309-5985dd7264ed	\N	9c22bc65-2479-4780-b3a0-0ed5e139ee5f	328fce4c-c7e7-4b44-8dcb-45aad65bd8e5	بررسی و تسویهٔ کارت اعتباری شرکت #90	\N	low	2026-07-02	d7613dd6-a4d8-414b-a8a1-e8bd9a3d15f5	2026-07-20 09:59:26.363877+00	2026-07-20 09:59:26.363877+00	completed	approved	100	39.20	2026-06-30
a03a787d-b998-4a31-aa2e-2aef31ab5784	\N	\N	9c22bc65-2479-4780-b3a0-0ed5e139ee5f	9c22bc65-2479-4780-b3a0-0ed5e139ee5f	بررسی فاکتورهای فروش صادرشده #91	\N	low	2026-08-01	045ab9b7-ba72-4f57-a64f-92165c4debd6	2026-07-20 09:59:26.363877+00	2026-07-20 09:59:26.363877+00	completed	pending	100	11.40	2026-07-13
a03a787d-b998-4a31-aa2e-2aef31ab5784	\N	\N	c1eff56a-cf6f-4901-9c44-9063f53db8c8	c1eff56a-cf6f-4901-9c44-9063f53db8c8	بررسی قراردادهای مالی جدید #92	\N	high	2026-07-11	9f7271a8-6b62-4b5d-a7d4-3705f3babee0	2026-07-20 09:59:26.363877+00	2026-07-20 09:59:26.363877+00	todo	\N	14	3.20	2026-07-03
a03a787d-b998-4a31-aa2e-2aef31ab5784	\N	\N	f2917b41-6f1c-4444-a73d-884a91e847fe	f2917b41-6f1c-4444-a73d-884a91e847fe	ثبت اسناد حسابداری هفتگی #93	\N	low	2026-07-27	761c4a67-db89-428f-b8d2-e4dc05ab623f	2026-07-20 09:59:26.363877+00	2026-07-20 09:59:26.363877+00	in_progress	\N	8	5.80	2026-07-25
a03a787d-b998-4a31-aa2e-2aef31ab5784	\N	\N	328fce4c-c7e7-4b44-8dcb-45aad65bd8e5	328fce4c-c7e7-4b44-8dcb-45aad65bd8e5	ثبت اسناد حسابداری هفتگی #94	\N	high	2026-08-03	21250fd6-d304-42cf-9786-a0ef30e7b447	2026-07-20 09:59:26.363877+00	2026-07-20 09:59:26.363877+00	completed	approved	100	3.70	2026-07-31
a03a787d-b998-4a31-aa2e-2aef31ab5784	\N	\N	9c22bc65-2479-4780-b3a0-0ed5e139ee5f	9c22bc65-2479-4780-b3a0-0ed5e139ee5f	بررسی و تسویهٔ کارت اعتباری شرکت #95	\N	low	2026-07-28	b3e452a1-5b75-48be-aec5-a96f6eafd97f	2026-07-20 09:59:26.363877+00	2026-07-20 09:59:26.363877+00	in_progress	\N	17	21.10	2026-07-20
a03a787d-b998-4a31-aa2e-2aef31ab5784	\N	\N	c1eff56a-cf6f-4901-9c44-9063f53db8c8	c1eff56a-cf6f-4901-9c44-9063f53db8c8	تهیهٔ گزارش مالیاتی فصلی #96	\N	high	2026-08-27	3568c190-33f6-4754-8c1e-1a5a90a2656b	2026-07-20 09:59:26.363877+00	2026-07-20 09:59:26.363877+00	in_progress	\N	76	31.40	2026-08-07
a03a787d-b998-4a31-aa2e-2aef31ab5784	\N	\N	276feb60-37b2-42ff-be39-f9e79af8ae2a	276feb60-37b2-42ff-be39-f9e79af8ae2a	بررسی قراردادهای مالی جدید #97	\N	low	2026-07-12	4acf5c94-5b6e-43a9-af45-e3f30e0a141c	2026-07-20 09:59:26.363877+00	2026-07-20 09:59:26.363877+00	in_progress	\N	66	10.40	2026-07-01
a03a787d-b998-4a31-aa2e-2aef31ab5784	\N	\N	c1eff56a-cf6f-4901-9c44-9063f53db8c8	c1eff56a-cf6f-4901-9c44-9063f53db8c8	بررسی صورت وضعیت پیمانکاران #98	\N	high	2026-07-08	b5537274-fac4-499b-9b4b-4b2a7ec3f207	2026-07-20 09:59:26.363877+00	2026-07-20 09:59:26.363877+00	in_progress	\N	22	25.80	2026-06-19
a03a787d-b998-4a31-aa2e-2aef31ab5784	\N	\N	9c22bc65-2479-4780-b3a0-0ed5e139ee5f	9c22bc65-2479-4780-b3a0-0ed5e139ee5f	بررسی و تسویهٔ کارت اعتباری شرکت #99	\N	high	2026-07-22	27a29d91-4946-45b2-9fd9-58abf2939046	2026-07-20 09:59:26.363877+00	2026-07-20 09:59:26.363877+00	completed	approved	100	14.10	2026-07-08
a03a787d-b998-4a31-aa2e-2aef31ab5784	\N	\N	9c22bc65-2479-4780-b3a0-0ed5e139ee5f	9c22bc65-2479-4780-b3a0-0ed5e139ee5f	بررسی فاکتورهای فروش صادرشده #100	\N	low	2026-07-06	7de590b3-9d64-4ad4-b221-d1cdaa7338f9	2026-07-20 09:59:26.363877+00	2026-07-20 09:59:26.363877+00	in_progress	\N	68	20.00	2026-06-25
a03a787d-b998-4a31-aa2e-2aef31ab5784	\N	\N	276feb60-37b2-42ff-be39-f9e79af8ae2a	276feb60-37b2-42ff-be39-f9e79af8ae2a	بررسی و تسویهٔ کارت اعتباری شرکت #101	\N	medium	2026-07-11	5043dea2-91e6-4ec8-9cd1-e99267ebac5d	2026-07-20 09:59:26.363877+00	2026-07-20 09:59:26.363877+00	in_progress	\N	7	23.40	2026-07-05
a03a787d-b998-4a31-aa2e-2aef31ab5784	\N	\N	9c22bc65-2479-4780-b3a0-0ed5e139ee5f	9c22bc65-2479-4780-b3a0-0ed5e139ee5f	پیگیری مطالبات معوق مشتریان #102	\N	low	2026-07-19	a23ff4ba-cbfc-4ab4-b91b-5cab6bb189a1	2026-07-20 09:59:26.363877+00	2026-07-20 09:59:26.363877+00	completed	approved	100	14.50	2026-07-10
a03a787d-b998-4a31-aa2e-2aef31ab5784	\N	\N	328fce4c-c7e7-4b44-8dcb-45aad65bd8e5	328fce4c-c7e7-4b44-8dcb-45aad65bd8e5	تهیهٔ گزارش جریان نقدی #103	\N	low	2026-07-10	3294a6f3-ecb6-4950-bc90-299dab897cb4	2026-07-20 09:59:26.363877+00	2026-07-20 09:59:26.363877+00	completed	pending	100	4.00	2026-06-21
a03a787d-b998-4a31-aa2e-2aef31ab5784	\N	\N	9c22bc65-2479-4780-b3a0-0ed5e139ee5f	9c22bc65-2479-4780-b3a0-0ed5e139ee5f	ثبت اسناد حسابداری هفتگی #104	\N	high	2026-06-22	ee961817-be5f-4bc6-9e24-48a354dbea4e	2026-07-20 09:59:26.363877+00	2026-07-20 09:59:26.363877+00	completed	pending	100	29.50	2026-06-18
a03a787d-b998-4a31-aa2e-2aef31ab5784	\N	\N	767b011b-ff3a-4faf-b85b-c424554a44a0	767b011b-ff3a-4faf-b85b-c424554a44a0	پیگیری بیمهٔ کارکنان #105	\N	medium	2026-07-24	30f8f142-9098-4a97-a5ec-f1e93c2ac3e7	2026-07-20 09:59:26.363877+00	2026-07-20 09:59:26.363877+00	in_progress	\N	38	38.40	2026-07-16
a03a787d-b998-4a31-aa2e-2aef31ab5784	38b2f96b-aad2-4a1d-9d01-1cd7e9820c8e	\N	06467080-462f-4467-a2ac-577bc7c7dff6	487a4011-366a-4e1c-ac4d-6f24e62436c6	تدوین برنامهٔ آموزشی سال آینده #1	\N	medium	2026-07-06	c2e40868-d189-4b0b-89c7-56284fb41c88	2026-07-20 09:59:26.363877+00	2026-07-20 09:59:26.363877+00	todo	\N	45	36.70	2026-06-27
a03a787d-b998-4a31-aa2e-2aef31ab5784	38b2f96b-aad2-4a1d-9d01-1cd7e9820c8e	\N	487a4011-366a-4e1c-ac4d-6f24e62436c6	487a4011-366a-4e1c-ac4d-6f24e62436c6	تدوین برنامهٔ آموزشی سال آینده #2	\N	high	2026-08-12	93c969b1-ebb9-4c67-865c-17acb575df5e	2026-07-20 09:59:26.363877+00	2026-07-20 09:59:26.363877+00	archived	\N	18	23.40	2026-07-30
a03a787d-b998-4a31-aa2e-2aef31ab5784	38b2f96b-aad2-4a1d-9d01-1cd7e9820c8e	\N	8eb048e0-49b1-4d8a-9e1f-ab534f5d1564	487a4011-366a-4e1c-ac4d-6f24e62436c6	بررسی رزومه‌های متقاضیان شغلی #3	\N	low	2026-07-14	f57490cb-c52c-4ede-8249-aca5e61165f1	2026-07-20 09:59:26.363877+00	2026-07-20 09:59:26.363877+00	completed	approved	100	4.10	2026-06-27
a03a787d-b998-4a31-aa2e-2aef31ab5784	38b2f96b-aad2-4a1d-9d01-1cd7e9820c8e	\N	fac1f37f-7665-4a91-b497-43238269a2e8	487a4011-366a-4e1c-ac4d-6f24e62436c6	برنامه‌ریزی رویداد تیم‌سازی #4	\N	low	2026-07-05	b359cdff-9d8b-41b1-a00e-62afe6392c02	2026-07-20 09:59:26.363877+00	2026-07-20 09:59:26.363877+00	in_progress	\N	42	36.90	2026-06-17
a03a787d-b998-4a31-aa2e-2aef31ab5784	38b2f96b-aad2-4a1d-9d01-1cd7e9820c8e	\N	8eb048e0-49b1-4d8a-9e1f-ab534f5d1564	487a4011-366a-4e1c-ac4d-6f24e62436c6	بررسی درخواست ترفیع کارکنان #5	\N	medium	2026-07-14	f9457236-1fee-42a1-aff0-998e71cbc21c	2026-07-20 09:59:26.363877+00	2026-07-20 09:59:26.363877+00	todo	\N	7	2.80	2026-07-07
a03a787d-b998-4a31-aa2e-2aef31ab5784	38b2f96b-aad2-4a1d-9d01-1cd7e9820c8e	\N	fac1f37f-7665-4a91-b497-43238269a2e8	487a4011-366a-4e1c-ac4d-6f24e62436c6	برگزاری نظرسنجی رضایت شغلی #6	\N	low	2026-08-19	1214aaf5-7ca0-4b08-971b-b0700b3b94b7	2026-07-20 09:59:26.363877+00	2026-07-20 09:59:26.363877+00	archived	\N	67	34.70	2026-08-13
a03a787d-b998-4a31-aa2e-2aef31ab5784	38b2f96b-aad2-4a1d-9d01-1cd7e9820c8e	\N	487a4011-366a-4e1c-ac4d-6f24e62436c6	487a4011-366a-4e1c-ac4d-6f24e62436c6	تدوین برنامهٔ آموزشی سال آینده #7	\N	low	2026-08-14	c169aa37-bc4f-4b07-8703-afae36e8f5d3	2026-07-20 09:59:26.363877+00	2026-07-20 09:59:26.363877+00	in_progress	\N	43	13.50	2026-07-31
a03a787d-b998-4a31-aa2e-2aef31ab5784	38b2f96b-aad2-4a1d-9d01-1cd7e9820c8e	\N	8eb048e0-49b1-4d8a-9e1f-ab534f5d1564	487a4011-366a-4e1c-ac4d-6f24e62436c6	برگزاری نظرسنجی رضایت شغلی #8	\N	high	2026-08-16	36948eb7-8623-4e8e-8693-487169f19191	2026-07-20 09:59:26.363877+00	2026-07-20 09:59:26.363877+00	todo	\N	62	26.70	2026-08-01
a03a787d-b998-4a31-aa2e-2aef31ab5784	38b2f96b-aad2-4a1d-9d01-1cd7e9820c8e	\N	8eb048e0-49b1-4d8a-9e1f-ab534f5d1564	487a4011-366a-4e1c-ac4d-6f24e62436c6	برگزاری نظرسنجی رضایت شغلی #9	\N	medium	2026-08-11	9b9d95d0-4be0-461e-9292-97fac60bc352	2026-07-20 09:59:26.363877+00	2026-07-20 09:59:26.363877+00	archived	\N	28	27.30	2026-07-21
a03a787d-b998-4a31-aa2e-2aef31ab5784	38b2f96b-aad2-4a1d-9d01-1cd7e9820c8e	\N	929fcc10-abd5-4d94-9b84-fb05ba764ba0	487a4011-366a-4e1c-ac4d-6f24e62436c6	به‌روزرسانی پروندهٔ پرسنلی #10	\N	high	2026-07-21	44c2f6c8-a3ec-4cc0-9cd0-cecd612d1df7	2026-07-20 09:59:26.363877+00	2026-07-20 09:59:26.363877+00	todo	\N	37	6.80	2026-07-10
a03a787d-b998-4a31-aa2e-2aef31ab5784	38b2f96b-aad2-4a1d-9d01-1cd7e9820c8e	\N	48c7fe74-5692-42c1-9068-c52c071221e8	487a4011-366a-4e1c-ac4d-6f24e62436c6	تهیهٔ فرم ارزیابی سه‌ماهه #11	\N	high	2026-09-04	72e48872-4090-4202-8e53-2fcfa9619654	2026-07-20 09:59:26.363877+00	2026-07-20 09:59:26.363877+00	todo	\N	4	8.90	2026-08-15
a03a787d-b998-4a31-aa2e-2aef31ab5784	38b2f96b-aad2-4a1d-9d01-1cd7e9820c8e	\N	06467080-462f-4467-a2ac-577bc7c7dff6	487a4011-366a-4e1c-ac4d-6f24e62436c6	بررسی درخواست ترفیع کارکنان #12	\N	medium	2026-07-27	bde0b27e-197e-4b80-acb3-7c99ff850537	2026-07-20 09:59:26.363877+00	2026-07-20 09:59:26.363877+00	completed	approved	100	7.30	2026-07-22
a03a787d-b998-4a31-aa2e-2aef31ab5784	38b2f96b-aad2-4a1d-9d01-1cd7e9820c8e	\N	48c7fe74-5692-42c1-9068-c52c071221e8	487a4011-366a-4e1c-ac4d-6f24e62436c6	پیگیری درخواست‌های رفاهی کارکنان #13	\N	low	2026-07-14	b37ce28b-ff5e-4c44-a19c-b4bad336714e	2026-07-20 09:59:26.363877+00	2026-07-20 09:59:26.363877+00	todo	\N	11	33.20	2026-07-01
a03a787d-b998-4a31-aa2e-2aef31ab5784	38b2f96b-aad2-4a1d-9d01-1cd7e9820c8e	\N	48c7fe74-5692-42c1-9068-c52c071221e8	487a4011-366a-4e1c-ac4d-6f24e62436c6	بررسی رزومه‌های متقاضیان شغلی #14	\N	medium	2026-07-23	69ff658d-6c9e-4e3c-ae69-a0c7ac4b4b56	2026-07-20 09:59:26.363877+00	2026-07-20 09:59:26.363877+00	completed	pending	100	10.00	2026-07-07
a03a787d-b998-4a31-aa2e-2aef31ab5784	38b2f96b-aad2-4a1d-9d01-1cd7e9820c8e	\N	48c7fe74-5692-42c1-9068-c52c071221e8	487a4011-366a-4e1c-ac4d-6f24e62436c6	برگزاری نظرسنجی رضایت شغلی #15	\N	low	2026-07-18	8c5b25cb-ebb8-4f64-8a09-208a02702498	2026-07-20 09:59:26.363877+00	2026-07-20 09:59:26.363877+00	todo	\N	0	3.80	2026-07-08
a03a787d-b998-4a31-aa2e-2aef31ab5784	38b2f96b-aad2-4a1d-9d01-1cd7e9820c8e	\N	3de0e871-5193-4e41-885f-531073da833a	487a4011-366a-4e1c-ac4d-6f24e62436c6	بررسی درخواست ترفیع کارکنان #16	\N	medium	2026-07-19	cccef3c8-df7f-4c3c-830c-fc6c6081bd0c	2026-07-20 09:59:26.363877+00	2026-07-20 09:59:26.363877+00	archived	\N	63	35.50	2026-07-12
a03a787d-b998-4a31-aa2e-2aef31ab5784	38b2f96b-aad2-4a1d-9d01-1cd7e9820c8e	\N	06467080-462f-4467-a2ac-577bc7c7dff6	487a4011-366a-4e1c-ac4d-6f24e62436c6	برگزاری نظرسنجی رضایت شغلی #17	\N	high	2026-08-25	bfa7fa43-e089-4a7a-bb7e-ba1b64c6e859	2026-07-20 09:59:26.363877+00	2026-07-20 09:59:26.363877+00	completed	approved	100	26.70	2026-08-08
a03a787d-b998-4a31-aa2e-2aef31ab5784	38b2f96b-aad2-4a1d-9d01-1cd7e9820c8e	\N	48c7fe74-5692-42c1-9068-c52c071221e8	487a4011-366a-4e1c-ac4d-6f24e62436c6	برنامه‌ریزی مصاحبهٔ استخدامی #18	\N	low	2026-07-12	abb0f1e2-ffa4-4d10-8149-466f73480a43	2026-07-20 09:59:26.363877+00	2026-07-20 09:59:26.363877+00	in_progress	\N	37	2.80	2026-06-26
a03a787d-b998-4a31-aa2e-2aef31ab5784	0997a305-ffa8-4263-8d7a-3d07622a211e	\N	06467080-462f-4467-a2ac-577bc7c7dff6	487a4011-366a-4e1c-ac4d-6f24e62436c6	تهیهٔ گزارش ارزیابی عملکرد #19	\N	medium	2026-07-02	5e17773a-ee32-419d-84c8-f8e2ff18f20d	2026-07-20 09:59:26.363877+00	2026-07-20 09:59:26.363877+00	todo	\N	20	29.80	2026-06-20
a03a787d-b998-4a31-aa2e-2aef31ab5784	0997a305-ffa8-4263-8d7a-3d07622a211e	\N	fac1f37f-7665-4a91-b497-43238269a2e8	487a4011-366a-4e1c-ac4d-6f24e62436c6	تدوین برنامهٔ آموزشی سال آینده #20	\N	medium	2026-07-28	bb279d09-ed19-4c2b-84b5-745f1e396216	2026-07-20 09:59:26.363877+00	2026-07-20 09:59:26.363877+00	todo	\N	3	18.40	2026-07-07
a03a787d-b998-4a31-aa2e-2aef31ab5784	0997a305-ffa8-4263-8d7a-3d07622a211e	\N	48c7fe74-5692-42c1-9068-c52c071221e8	487a4011-366a-4e1c-ac4d-6f24e62436c6	تهیهٔ گزارش ارزیابی عملکرد #21	\N	low	2026-08-08	f9dcf7af-bc97-40ee-a7b4-f3af3c0efac7	2026-07-20 09:59:26.363877+00	2026-07-20 09:59:26.363877+00	todo	\N	12	14.60	2026-07-24
a03a787d-b998-4a31-aa2e-2aef31ab5784	0997a305-ffa8-4263-8d7a-3d07622a211e	\N	8eb048e0-49b1-4d8a-9e1f-ab534f5d1564	487a4011-366a-4e1c-ac4d-6f24e62436c6	به‌روزرسانی پروندهٔ پرسنلی #22	\N	high	2026-08-18	1a7380e3-ed0b-4b25-9a99-caf67a01e815	2026-07-20 09:59:26.363877+00	2026-07-20 09:59:26.363877+00	in_progress	\N	69	12.10	2026-07-30
a03a787d-b998-4a31-aa2e-2aef31ab5784	0997a305-ffa8-4263-8d7a-3d07622a211e	\N	06467080-462f-4467-a2ac-577bc7c7dff6	487a4011-366a-4e1c-ac4d-6f24e62436c6	بررسی رزومه‌های متقاضیان شغلی #23	\N	medium	2026-07-06	54eafa6b-1c1d-40ca-8fc8-55c1a266340f	2026-07-20 09:59:26.363877+00	2026-07-20 09:59:26.363877+00	in_progress	\N	73	22.90	2026-07-01
a03a787d-b998-4a31-aa2e-2aef31ab5784	0997a305-ffa8-4263-8d7a-3d07622a211e	\N	3de0e871-5193-4e41-885f-531073da833a	487a4011-366a-4e1c-ac4d-6f24e62436c6	بررسی رزومه‌های متقاضیان شغلی #24	\N	medium	2026-07-02	0b340ccc-29c4-48f4-8b48-f78cda0566ea	2026-07-20 09:59:26.363877+00	2026-07-20 09:59:26.363877+00	todo	\N	11	13.20	2026-06-19
a03a787d-b998-4a31-aa2e-2aef31ab5784	0997a305-ffa8-4263-8d7a-3d07622a211e	\N	48c7fe74-5692-42c1-9068-c52c071221e8	487a4011-366a-4e1c-ac4d-6f24e62436c6	بررسی رزومه‌های متقاضیان شغلی #25	\N	low	2026-07-03	91f74f13-0f43-4708-9eaa-3c7019e27b7c	2026-07-20 09:59:26.363877+00	2026-07-20 09:59:26.363877+00	completed	pending	100	8.50	2026-06-28
a03a787d-b998-4a31-aa2e-2aef31ab5784	0997a305-ffa8-4263-8d7a-3d07622a211e	\N	06467080-462f-4467-a2ac-577bc7c7dff6	487a4011-366a-4e1c-ac4d-6f24e62436c6	به‌روزرسانی آیین‌نامهٔ داخلی شرکت #26	\N	medium	2026-07-21	dc7cfeda-14b8-44ea-81c6-1ba833029127	2026-07-20 09:59:26.363877+00	2026-07-20 09:59:26.363877+00	todo	\N	60	20.60	2026-07-16
a03a787d-b998-4a31-aa2e-2aef31ab5784	0997a305-ffa8-4263-8d7a-3d07622a211e	\N	48c7fe74-5692-42c1-9068-c52c071221e8	487a4011-366a-4e1c-ac4d-6f24e62436c6	تهیهٔ فرم ارزیابی سه‌ماهه #27	\N	low	2026-07-10	d2fcafec-16ad-4ff2-beb5-e1db3e03449e	2026-07-20 09:59:26.363877+00	2026-07-20 09:59:26.363877+00	in_progress	\N	47	35.60	2026-06-21
a03a787d-b998-4a31-aa2e-2aef31ab5784	0997a305-ffa8-4263-8d7a-3d07622a211e	\N	06467080-462f-4467-a2ac-577bc7c7dff6	487a4011-366a-4e1c-ac4d-6f24e62436c6	به‌روزرسانی آیین‌نامهٔ داخلی شرکت #28	\N	medium	2026-07-17	ae4b2cbc-8de6-4d5a-a8ff-97f63d814c18	2026-07-20 09:59:26.363877+00	2026-07-20 09:59:26.363877+00	todo	\N	59	12.00	2026-07-14
a03a787d-b998-4a31-aa2e-2aef31ab5784	0997a305-ffa8-4263-8d7a-3d07622a211e	\N	929fcc10-abd5-4d94-9b84-fb05ba764ba0	487a4011-366a-4e1c-ac4d-6f24e62436c6	تهیهٔ گزارش ارزیابی عملکرد #29	\N	high	2026-07-25	bf6863ce-f215-4d25-b2ec-cf7641c84a64	2026-07-20 09:59:26.363877+00	2026-07-20 09:59:26.363877+00	in_progress	\N	12	5.30	2026-07-22
a03a787d-b998-4a31-aa2e-2aef31ab5784	0997a305-ffa8-4263-8d7a-3d07622a211e	\N	06467080-462f-4467-a2ac-577bc7c7dff6	487a4011-366a-4e1c-ac4d-6f24e62436c6	برگزاری جلسهٔ آموزش کارکنان جدید #30	\N	high	2026-08-23	2db1b347-0021-473c-a91f-12f4e979bdef	2026-07-20 09:59:26.363877+00	2026-07-20 09:59:26.363877+00	completed	approved	100	4.30	2026-08-03
a03a787d-b998-4a31-aa2e-2aef31ab5784	0997a305-ffa8-4263-8d7a-3d07622a211e	\N	3de0e871-5193-4e41-885f-531073da833a	487a4011-366a-4e1c-ac4d-6f24e62436c6	تدوین برنامهٔ آموزشی سال آینده #31	\N	low	2026-08-06	d94edb5e-4bc9-4749-badb-da4a883a652f	2026-07-20 09:59:26.363877+00	2026-07-20 09:59:26.363877+00	completed	approved	100	20.10	2026-07-20
a03a787d-b998-4a31-aa2e-2aef31ab5784	0997a305-ffa8-4263-8d7a-3d07622a211e	\N	487a4011-366a-4e1c-ac4d-6f24e62436c6	487a4011-366a-4e1c-ac4d-6f24e62436c6	بررسی و تمدید قراردادهای پرسنلی #32	\N	high	2026-08-15	f0afc7d3-2396-44d2-a7ab-afee41cf05ed	2026-07-20 09:59:26.363877+00	2026-07-20 09:59:26.363877+00	in_progress	\N	66	32.40	2026-08-12
a03a787d-b998-4a31-aa2e-2aef31ab5784	0997a305-ffa8-4263-8d7a-3d07622a211e	\N	48c7fe74-5692-42c1-9068-c52c071221e8	487a4011-366a-4e1c-ac4d-6f24e62436c6	تهیهٔ گزارش ارزیابی عملکرد #33	\N	low	2026-08-31	c5f232f8-2875-4df7-a475-39fcfb411ab7	2026-07-20 09:59:26.363877+00	2026-07-20 09:59:26.363877+00	completed	approved	100	38.90	2026-08-15
a03a787d-b998-4a31-aa2e-2aef31ab5784	0997a305-ffa8-4263-8d7a-3d07622a211e	\N	929fcc10-abd5-4d94-9b84-fb05ba764ba0	487a4011-366a-4e1c-ac4d-6f24e62436c6	تهیهٔ فرم ارزیابی سه‌ماهه #34	\N	low	2026-06-27	f96c3723-b2bf-42e7-9bee-061dfe649a6c	2026-07-20 09:59:26.363877+00	2026-07-20 09:59:26.363877+00	todo	\N	55	9.70	2026-06-24
a03a787d-b998-4a31-aa2e-2aef31ab5784	0997a305-ffa8-4263-8d7a-3d07622a211e	\N	929fcc10-abd5-4d94-9b84-fb05ba764ba0	487a4011-366a-4e1c-ac4d-6f24e62436c6	پیگیری درخواست‌های رفاهی کارکنان #35	\N	high	2026-08-03	9ee72df7-ff2d-4105-991e-a2c98a45de3b	2026-07-20 09:59:26.363877+00	2026-07-20 09:59:26.363877+00	completed	approved	100	36.70	2026-07-24
a03a787d-b998-4a31-aa2e-2aef31ab5784	0997a305-ffa8-4263-8d7a-3d07622a211e	\N	487a4011-366a-4e1c-ac4d-6f24e62436c6	487a4011-366a-4e1c-ac4d-6f24e62436c6	تهیهٔ فرم ارزیابی سه‌ماهه #36	\N	high	2026-07-29	f79bda84-d71e-456d-b333-57ab9b01f78c	2026-07-20 09:59:26.363877+00	2026-07-20 09:59:26.363877+00	todo	\N	41	34.60	2026-07-10
a03a787d-b998-4a31-aa2e-2aef31ab5784	17bfb4bf-c4f1-4255-89ec-adba16e7232a	\N	fac1f37f-7665-4a91-b497-43238269a2e8	487a4011-366a-4e1c-ac4d-6f24e62436c6	تدوین برنامهٔ آموزشی سال آینده #37	\N	high	2026-07-07	d0cecb81-afaa-4e13-a11a-25fc0fd64a56	2026-07-20 09:59:26.363877+00	2026-07-20 09:59:26.363877+00	completed	rejected	100	31.70	2026-06-16
a03a787d-b998-4a31-aa2e-2aef31ab5784	17bfb4bf-c4f1-4255-89ec-adba16e7232a	\N	487a4011-366a-4e1c-ac4d-6f24e62436c6	487a4011-366a-4e1c-ac4d-6f24e62436c6	تدوین برنامهٔ آموزشی سال آینده #38	\N	high	2026-07-01	7f18374b-5da5-4667-89e0-4bfc4364e37d	2026-07-20 09:59:26.363877+00	2026-07-20 09:59:26.363877+00	in_progress	\N	74	30.80	2026-06-25
a03a787d-b998-4a31-aa2e-2aef31ab5784	17bfb4bf-c4f1-4255-89ec-adba16e7232a	\N	487a4011-366a-4e1c-ac4d-6f24e62436c6	487a4011-366a-4e1c-ac4d-6f24e62436c6	برگزاری نظرسنجی رضایت شغلی #39	\N	medium	2026-07-27	f2d54d3e-436a-4bdf-880c-2bb54415e62a	2026-07-20 09:59:26.363877+00	2026-07-20 09:59:26.363877+00	todo	\N	68	35.40	2026-07-22
a03a787d-b998-4a31-aa2e-2aef31ab5784	17bfb4bf-c4f1-4255-89ec-adba16e7232a	\N	3de0e871-5193-4e41-885f-531073da833a	487a4011-366a-4e1c-ac4d-6f24e62436c6	تدوین برنامهٔ آموزشی سال آینده #40	\N	high	2026-07-27	a28166df-880b-48f2-b628-58cbcbed4fe2	2026-07-20 09:59:26.363877+00	2026-07-20 09:59:26.363877+00	in_progress	\N	60	3.40	2026-07-10
a03a787d-b998-4a31-aa2e-2aef31ab5784	17bfb4bf-c4f1-4255-89ec-adba16e7232a	\N	06467080-462f-4467-a2ac-577bc7c7dff6	487a4011-366a-4e1c-ac4d-6f24e62436c6	تدوین برنامهٔ آموزشی سال آینده #41	\N	high	2026-07-16	df53a3f7-2094-41c6-b723-372e6d17adb6	2026-07-20 09:59:26.363877+00	2026-07-20 09:59:26.363877+00	in_progress	\N	51	3.50	2026-06-25
a03a787d-b998-4a31-aa2e-2aef31ab5784	17bfb4bf-c4f1-4255-89ec-adba16e7232a	\N	06467080-462f-4467-a2ac-577bc7c7dff6	487a4011-366a-4e1c-ac4d-6f24e62436c6	بررسی درخواست ترفیع کارکنان #42	\N	medium	2026-08-19	974ca9a7-8f2d-483e-8497-f57a8d2d567f	2026-07-20 09:59:26.363877+00	2026-07-20 09:59:26.363877+00	completed	approved	100	36.10	2026-08-02
a03a787d-b998-4a31-aa2e-2aef31ab5784	17bfb4bf-c4f1-4255-89ec-adba16e7232a	\N	487a4011-366a-4e1c-ac4d-6f24e62436c6	487a4011-366a-4e1c-ac4d-6f24e62436c6	به‌روزرسانی آیین‌نامهٔ داخلی شرکت #43	\N	medium	2026-08-18	2323795b-aa74-4c1c-89a6-d68e3a46c480	2026-07-20 09:59:26.363877+00	2026-07-20 09:59:26.363877+00	in_progress	\N	62	34.60	2026-08-07
a03a787d-b998-4a31-aa2e-2aef31ab5784	17bfb4bf-c4f1-4255-89ec-adba16e7232a	\N	48c7fe74-5692-42c1-9068-c52c071221e8	487a4011-366a-4e1c-ac4d-6f24e62436c6	تهیهٔ گزارش ارزیابی عملکرد #44	\N	medium	2026-08-19	04216b60-7e98-4e9b-8db3-f38f680c7fdb	2026-07-20 09:59:26.363877+00	2026-07-20 09:59:26.363877+00	todo	\N	56	31.40	2026-08-10
a03a787d-b998-4a31-aa2e-2aef31ab5784	17bfb4bf-c4f1-4255-89ec-adba16e7232a	\N	06467080-462f-4467-a2ac-577bc7c7dff6	487a4011-366a-4e1c-ac4d-6f24e62436c6	تدوین برنامهٔ آموزشی سال آینده #45	\N	high	2026-08-16	a78676ff-d6f3-4b62-868c-08eefcfba7fc	2026-07-20 09:59:26.363877+00	2026-07-20 09:59:26.363877+00	in_progress	\N	11	9.10	2026-08-01
a03a787d-b998-4a31-aa2e-2aef31ab5784	17bfb4bf-c4f1-4255-89ec-adba16e7232a	\N	8eb048e0-49b1-4d8a-9e1f-ab534f5d1564	487a4011-366a-4e1c-ac4d-6f24e62436c6	برگزاری نظرسنجی رضایت شغلی #46	\N	high	2026-08-19	bab6f2e7-91ca-40db-9111-01b5c8563043	2026-07-20 09:59:26.363877+00	2026-07-20 09:59:26.363877+00	in_progress	\N	47	33.20	2026-08-02
a03a787d-b998-4a31-aa2e-2aef31ab5784	17bfb4bf-c4f1-4255-89ec-adba16e7232a	\N	fac1f37f-7665-4a91-b497-43238269a2e8	487a4011-366a-4e1c-ac4d-6f24e62436c6	به‌روزرسانی پروندهٔ پرسنلی #47	\N	high	2026-07-01	1bc16d0f-3372-42eb-9590-3d6625126947	2026-07-20 09:59:26.363877+00	2026-07-20 09:59:26.363877+00	todo	\N	51	7.20	2026-06-20
a03a787d-b998-4a31-aa2e-2aef31ab5784	17bfb4bf-c4f1-4255-89ec-adba16e7232a	\N	929fcc10-abd5-4d94-9b84-fb05ba764ba0	487a4011-366a-4e1c-ac4d-6f24e62436c6	برگزاری جلسهٔ آموزش کارکنان جدید #48	\N	low	2026-06-24	8ef6f2a8-c3df-4b35-abe0-8e27a8c4b046	2026-07-20 09:59:26.363877+00	2026-07-20 09:59:26.363877+00	completed	pending	100	33.80	2026-06-17
a03a787d-b998-4a31-aa2e-2aef31ab5784	17bfb4bf-c4f1-4255-89ec-adba16e7232a	\N	8eb048e0-49b1-4d8a-9e1f-ab534f5d1564	487a4011-366a-4e1c-ac4d-6f24e62436c6	بررسی درخواست ترفیع کارکنان #49	\N	medium	2026-07-18	691a1f75-ba1b-43d7-9c2a-1ae3dd12d455	2026-07-20 09:59:26.363877+00	2026-07-20 09:59:26.363877+00	todo	\N	25	12.40	2026-07-15
a03a787d-b998-4a31-aa2e-2aef31ab5784	17bfb4bf-c4f1-4255-89ec-adba16e7232a	\N	929fcc10-abd5-4d94-9b84-fb05ba764ba0	487a4011-366a-4e1c-ac4d-6f24e62436c6	پیگیری مرخصی و مأموریت کارکنان #50	\N	low	2026-07-31	6c3b8578-966b-45b6-a637-483b9bc619bc	2026-07-20 09:59:26.363877+00	2026-07-20 09:59:26.363877+00	completed	approved	100	11.20	2026-07-26
a03a787d-b998-4a31-aa2e-2aef31ab5784	17bfb4bf-c4f1-4255-89ec-adba16e7232a	\N	3de0e871-5193-4e41-885f-531073da833a	487a4011-366a-4e1c-ac4d-6f24e62436c6	تدوین برنامهٔ آموزشی سال آینده #51	\N	high	2026-08-27	28824178-fe03-47f5-97c3-b24d806c0fff	2026-07-20 09:59:26.363877+00	2026-07-20 09:59:26.363877+00	completed	approved	100	15.30	2026-08-10
a03a787d-b998-4a31-aa2e-2aef31ab5784	17bfb4bf-c4f1-4255-89ec-adba16e7232a	\N	8eb048e0-49b1-4d8a-9e1f-ab534f5d1564	487a4011-366a-4e1c-ac4d-6f24e62436c6	به‌روزرسانی آیین‌نامهٔ داخلی شرکت #52	\N	low	2026-08-06	19cf99c9-30d8-4771-a68a-2f4cb4da8c0b	2026-07-20 09:59:26.363877+00	2026-07-20 09:59:26.363877+00	in_progress	\N	49	3.90	2026-08-02
a03a787d-b998-4a31-aa2e-2aef31ab5784	17bfb4bf-c4f1-4255-89ec-adba16e7232a	\N	929fcc10-abd5-4d94-9b84-fb05ba764ba0	487a4011-366a-4e1c-ac4d-6f24e62436c6	پیگیری مرخصی و مأموریت کارکنان #53	\N	low	2026-07-08	11172009-5f75-4630-826a-0da1d429763b	2026-07-20 09:59:26.363877+00	2026-07-20 09:59:26.363877+00	completed	pending	100	27.80	2026-06-29
a03a787d-b998-4a31-aa2e-2aef31ab5784	17bfb4bf-c4f1-4255-89ec-adba16e7232a	\N	06467080-462f-4467-a2ac-577bc7c7dff6	487a4011-366a-4e1c-ac4d-6f24e62436c6	برنامه‌ریزی رویداد تیم‌سازی #54	\N	low	2026-06-19	84a27e70-764e-480c-bb5d-7997bdbb7163	2026-07-20 09:59:26.363877+00	2026-07-20 09:59:26.363877+00	completed	approved	100	26.60	2026-06-17
a03a787d-b998-4a31-aa2e-2aef31ab5784	3a0cafbb-bb8f-4904-bbf0-f2dfb0fc0f5b	\N	fac1f37f-7665-4a91-b497-43238269a2e8	487a4011-366a-4e1c-ac4d-6f24e62436c6	تدوین برنامهٔ آموزشی سال آینده #55	\N	medium	2026-07-10	c74fe243-3b82-4316-b72d-b8b0732b3993	2026-07-20 09:59:26.363877+00	2026-07-20 09:59:26.363877+00	todo	\N	35	18.10	2026-06-30
a03a787d-b998-4a31-aa2e-2aef31ab5784	3a0cafbb-bb8f-4904-bbf0-f2dfb0fc0f5b	\N	3de0e871-5193-4e41-885f-531073da833a	487a4011-366a-4e1c-ac4d-6f24e62436c6	برگزاری جلسهٔ آموزش کارکنان جدید #56	\N	medium	2026-07-25	a4e70064-bf5f-4594-87bb-48da8c180ab5	2026-07-20 09:59:26.363877+00	2026-07-20 09:59:26.363877+00	in_progress	\N	38	27.70	2026-07-15
a03a787d-b998-4a31-aa2e-2aef31ab5784	3a0cafbb-bb8f-4904-bbf0-f2dfb0fc0f5b	\N	929fcc10-abd5-4d94-9b84-fb05ba764ba0	487a4011-366a-4e1c-ac4d-6f24e62436c6	بررسی و تمدید قراردادهای پرسنلی #57	\N	high	2026-06-24	2460ef2f-3c11-404a-94d3-0ff2b500a5dc	2026-07-20 09:59:26.363877+00	2026-07-20 09:59:26.363877+00	completed	approved	100	38.70	2026-06-22
a03a787d-b998-4a31-aa2e-2aef31ab5784	3a0cafbb-bb8f-4904-bbf0-f2dfb0fc0f5b	\N	929fcc10-abd5-4d94-9b84-fb05ba764ba0	487a4011-366a-4e1c-ac4d-6f24e62436c6	تدوین برنامهٔ آموزشی سال آینده #58	\N	medium	2026-08-11	cd8747a6-18ed-4daf-8be0-002347ebe8f6	2026-07-20 09:59:26.363877+00	2026-07-20 09:59:26.363877+00	in_progress	\N	38	28.00	2026-07-21
a03a787d-b998-4a31-aa2e-2aef31ab5784	3a0cafbb-bb8f-4904-bbf0-f2dfb0fc0f5b	\N	3de0e871-5193-4e41-885f-531073da833a	487a4011-366a-4e1c-ac4d-6f24e62436c6	پیگیری مرخصی و مأموریت کارکنان #59	\N	medium	2026-07-17	18c3dccc-cff9-43ba-b22c-d4b8248adabe	2026-07-20 09:59:26.363877+00	2026-07-20 09:59:26.363877+00	todo	\N	35	11.90	2026-07-07
a03a787d-b998-4a31-aa2e-2aef31ab5784	3a0cafbb-bb8f-4904-bbf0-f2dfb0fc0f5b	\N	48c7fe74-5692-42c1-9068-c52c071221e8	487a4011-366a-4e1c-ac4d-6f24e62436c6	برگزاری نظرسنجی رضایت شغلی #60	\N	low	2026-07-13	82646fe1-3570-462a-8085-782230699795	2026-07-20 09:59:26.363877+00	2026-07-20 09:59:26.363877+00	completed	approved	100	36.20	2026-06-25
a03a787d-b998-4a31-aa2e-2aef31ab5784	3a0cafbb-bb8f-4904-bbf0-f2dfb0fc0f5b	\N	929fcc10-abd5-4d94-9b84-fb05ba764ba0	487a4011-366a-4e1c-ac4d-6f24e62436c6	به‌روزرسانی پروندهٔ پرسنلی #61	\N	low	2026-07-12	e6f38f13-4bc3-46b0-90f1-0ca7605861eb	2026-07-20 09:59:26.363877+00	2026-07-20 09:59:26.363877+00	completed	approved	100	26.90	2026-07-06
a03a787d-b998-4a31-aa2e-2aef31ab5784	3a0cafbb-bb8f-4904-bbf0-f2dfb0fc0f5b	\N	06467080-462f-4467-a2ac-577bc7c7dff6	487a4011-366a-4e1c-ac4d-6f24e62436c6	تهیهٔ فرم ارزیابی سه‌ماهه #62	\N	medium	2026-08-28	7e9ad475-17fb-42e5-9b39-c02c6a3cf356	2026-07-20 09:59:26.363877+00	2026-07-20 09:59:26.363877+00	in_progress	\N	4	24.20	2026-08-13
a03a787d-b998-4a31-aa2e-2aef31ab5784	3a0cafbb-bb8f-4904-bbf0-f2dfb0fc0f5b	\N	fac1f37f-7665-4a91-b497-43238269a2e8	487a4011-366a-4e1c-ac4d-6f24e62436c6	پیگیری مرخصی و مأموریت کارکنان #63	\N	high	2026-07-16	5ca85987-c911-4ab6-86cf-144f397b84ce	2026-07-20 09:59:26.363877+00	2026-07-20 09:59:26.363877+00	todo	\N	60	36.40	2026-07-07
a03a787d-b998-4a31-aa2e-2aef31ab5784	3a0cafbb-bb8f-4904-bbf0-f2dfb0fc0f5b	\N	48c7fe74-5692-42c1-9068-c52c071221e8	487a4011-366a-4e1c-ac4d-6f24e62436c6	تهیهٔ گزارش غیبت و تأخیر #64	\N	low	2026-07-29	c859a2cc-abd6-44f4-9f8e-314401865796	2026-07-20 09:59:26.363877+00	2026-07-20 09:59:26.363877+00	in_progress	\N	71	8.90	2026-07-18
a03a787d-b998-4a31-aa2e-2aef31ab5784	3a0cafbb-bb8f-4904-bbf0-f2dfb0fc0f5b	\N	487a4011-366a-4e1c-ac4d-6f24e62436c6	487a4011-366a-4e1c-ac4d-6f24e62436c6	برگزاری نظرسنجی رضایت شغلی #65	\N	low	2026-07-21	bdac5670-dbdc-4b4d-81d7-3056b935f600	2026-07-20 09:59:26.363877+00	2026-07-20 09:59:26.363877+00	completed	approved	100	38.00	2026-07-02
a03a787d-b998-4a31-aa2e-2aef31ab5784	3a0cafbb-bb8f-4904-bbf0-f2dfb0fc0f5b	\N	06467080-462f-4467-a2ac-577bc7c7dff6	487a4011-366a-4e1c-ac4d-6f24e62436c6	به‌روزرسانی پروندهٔ پرسنلی #66	\N	medium	2026-07-17	bdc49991-7bdd-411c-af88-1f56bf9a9916	2026-07-20 09:59:26.363877+00	2026-07-20 09:59:26.363877+00	completed	approved	100	18.00	2026-07-08
a03a787d-b998-4a31-aa2e-2aef31ab5784	3a0cafbb-bb8f-4904-bbf0-f2dfb0fc0f5b	\N	06467080-462f-4467-a2ac-577bc7c7dff6	487a4011-366a-4e1c-ac4d-6f24e62436c6	به‌روزرسانی آیین‌نامهٔ داخلی شرکت #67	\N	medium	2026-07-22	7b2fc572-f72c-4bb6-9d5a-33dfe3d907b3	2026-07-20 09:59:26.363877+00	2026-07-20 09:59:26.363877+00	in_progress	\N	15	19.90	2026-07-02
a03a787d-b998-4a31-aa2e-2aef31ab5784	3a0cafbb-bb8f-4904-bbf0-f2dfb0fc0f5b	\N	929fcc10-abd5-4d94-9b84-fb05ba764ba0	487a4011-366a-4e1c-ac4d-6f24e62436c6	برنامه‌ریزی مصاحبهٔ استخدامی #68	\N	medium	2026-09-05	a6d1713e-1288-4595-bf0f-51b852643d59	2026-07-20 09:59:26.363877+00	2026-07-20 09:59:26.363877+00	completed	approved	100	35.80	2026-08-15
a03a787d-b998-4a31-aa2e-2aef31ab5784	3a0cafbb-bb8f-4904-bbf0-f2dfb0fc0f5b	\N	fac1f37f-7665-4a91-b497-43238269a2e8	487a4011-366a-4e1c-ac4d-6f24e62436c6	بررسی و تمدید قراردادهای پرسنلی #69	\N	medium	2026-08-24	865158e7-0f38-428d-8ffe-b7078a53aa7c	2026-07-20 09:59:26.363877+00	2026-07-20 09:59:26.363877+00	todo	\N	52	4.10	2026-08-10
a03a787d-b998-4a31-aa2e-2aef31ab5784	3a0cafbb-bb8f-4904-bbf0-f2dfb0fc0f5b	\N	929fcc10-abd5-4d94-9b84-fb05ba764ba0	487a4011-366a-4e1c-ac4d-6f24e62436c6	پیگیری درخواست‌های رفاهی کارکنان #70	\N	medium	2026-07-02	7046909d-cce5-43e3-911b-050a80a40af9	2026-07-20 09:59:26.363877+00	2026-07-20 09:59:26.363877+00	todo	\N	72	35.90	2026-06-24
a03a787d-b998-4a31-aa2e-2aef31ab5784	3a0cafbb-bb8f-4904-bbf0-f2dfb0fc0f5b	\N	3de0e871-5193-4e41-885f-531073da833a	487a4011-366a-4e1c-ac4d-6f24e62436c6	برگزاری نظرسنجی رضایت شغلی #71	\N	low	2026-07-13	558cd346-5fed-48de-b69a-e05788d61a1b	2026-07-20 09:59:26.363877+00	2026-07-20 09:59:26.363877+00	todo	\N	62	14.60	2026-07-06
a03a787d-b998-4a31-aa2e-2aef31ab5784	3a0cafbb-bb8f-4904-bbf0-f2dfb0fc0f5b	\N	8eb048e0-49b1-4d8a-9e1f-ab534f5d1564	487a4011-366a-4e1c-ac4d-6f24e62436c6	بررسی رزومه‌های متقاضیان شغلی #72	\N	medium	2026-07-29	2a7b9365-a18b-4e9f-b80b-d803f679eca6	2026-07-20 09:59:26.363877+00	2026-07-20 09:59:26.363877+00	in_progress	\N	35	10.00	2026-07-26
a03a787d-b998-4a31-aa2e-2aef31ab5784	17a90a26-1810-4dfa-b570-d013f4ee3a15	\N	929fcc10-abd5-4d94-9b84-fb05ba764ba0	487a4011-366a-4e1c-ac4d-6f24e62436c6	برنامه‌ریزی رویداد تیم‌سازی #73	\N	low	2026-07-29	c4376a3c-8645-4dc4-b8d3-d7896f50d205	2026-07-20 09:59:26.363877+00	2026-07-20 09:59:26.363877+00	todo	\N	16	25.40	2026-07-22
a03a787d-b998-4a31-aa2e-2aef31ab5784	17a90a26-1810-4dfa-b570-d013f4ee3a15	\N	48c7fe74-5692-42c1-9068-c52c071221e8	487a4011-366a-4e1c-ac4d-6f24e62436c6	برنامه‌ریزی رویداد تیم‌سازی #74	\N	medium	2026-07-26	5eb1887c-3398-4ad8-b2a2-30d9eb0d08ed	2026-07-20 09:59:26.363877+00	2026-07-20 09:59:26.363877+00	in_progress	\N	0	3.40	2026-07-11
a03a787d-b998-4a31-aa2e-2aef31ab5784	17a90a26-1810-4dfa-b570-d013f4ee3a15	\N	8eb048e0-49b1-4d8a-9e1f-ab534f5d1564	487a4011-366a-4e1c-ac4d-6f24e62436c6	بررسی درخواست ترفیع کارکنان #75	\N	medium	2026-07-11	fa7e72e1-7750-4073-b923-34e5f7ad958e	2026-07-20 09:59:26.363877+00	2026-07-20 09:59:26.363877+00	archived	\N	67	9.20	2026-07-09
a03a787d-b998-4a31-aa2e-2aef31ab5784	17a90a26-1810-4dfa-b570-d013f4ee3a15	\N	48c7fe74-5692-42c1-9068-c52c071221e8	487a4011-366a-4e1c-ac4d-6f24e62436c6	برگزاری جلسهٔ آموزش کارکنان جدید #76	\N	high	2026-08-04	afd65e91-cb65-4824-9218-31180563c707	2026-07-20 09:59:26.363877+00	2026-07-20 09:59:26.363877+00	todo	\N	44	13.90	2026-07-26
a03a787d-b998-4a31-aa2e-2aef31ab5784	17a90a26-1810-4dfa-b570-d013f4ee3a15	\N	487a4011-366a-4e1c-ac4d-6f24e62436c6	487a4011-366a-4e1c-ac4d-6f24e62436c6	به‌روزرسانی آیین‌نامهٔ داخلی شرکت #77	\N	low	2026-08-07	ecfc4133-a57e-484a-a90f-e825c0e976e2	2026-07-20 09:59:26.363877+00	2026-07-20 09:59:26.363877+00	in_progress	\N	8	33.30	2026-07-18
a03a787d-b998-4a31-aa2e-2aef31ab5784	17a90a26-1810-4dfa-b570-d013f4ee3a15	\N	06467080-462f-4467-a2ac-577bc7c7dff6	487a4011-366a-4e1c-ac4d-6f24e62436c6	تدوین برنامهٔ آموزشی سال آینده #78	\N	high	2026-08-02	5b68df57-3a81-4828-8755-d3a618d4b269	2026-07-20 09:59:26.363877+00	2026-07-20 09:59:26.363877+00	in_progress	\N	43	18.50	2026-07-15
a03a787d-b998-4a31-aa2e-2aef31ab5784	17a90a26-1810-4dfa-b570-d013f4ee3a15	\N	48c7fe74-5692-42c1-9068-c52c071221e8	487a4011-366a-4e1c-ac4d-6f24e62436c6	پیگیری درخواست‌های رفاهی کارکنان #79	\N	low	2026-07-24	d767faab-f9e5-4b6b-b13f-d70141e9afc0	2026-07-20 09:59:26.363877+00	2026-07-20 09:59:26.363877+00	todo	\N	21	38.00	2026-07-07
a03a787d-b998-4a31-aa2e-2aef31ab5784	17a90a26-1810-4dfa-b570-d013f4ee3a15	\N	929fcc10-abd5-4d94-9b84-fb05ba764ba0	487a4011-366a-4e1c-ac4d-6f24e62436c6	برگزاری جلسهٔ آموزش کارکنان جدید #80	\N	high	2026-06-26	b825fc5f-3b81-4def-8750-6de24f601e44	2026-07-20 09:59:26.363877+00	2026-07-20 09:59:26.363877+00	in_progress	\N	16	10.00	2026-06-17
a03a787d-b998-4a31-aa2e-2aef31ab5784	17a90a26-1810-4dfa-b570-d013f4ee3a15	\N	487a4011-366a-4e1c-ac4d-6f24e62436c6	487a4011-366a-4e1c-ac4d-6f24e62436c6	به‌روزرسانی پروندهٔ پرسنلی #81	\N	high	2026-07-06	b79cc6ea-affe-4198-98cc-8dc1704c013a	2026-07-20 09:59:26.363877+00	2026-07-20 09:59:26.363877+00	completed	approved	100	32.10	2026-06-23
a03a787d-b998-4a31-aa2e-2aef31ab5784	17a90a26-1810-4dfa-b570-d013f4ee3a15	\N	3de0e871-5193-4e41-885f-531073da833a	487a4011-366a-4e1c-ac4d-6f24e62436c6	بررسی رزومه‌های متقاضیان شغلی #82	\N	high	2026-08-10	4ea4ffaa-389f-434c-8d7b-b63a6fd6d732	2026-07-20 09:59:26.363877+00	2026-07-20 09:59:26.363877+00	completed	approved	100	39.80	2026-07-20
a03a787d-b998-4a31-aa2e-2aef31ab5784	17a90a26-1810-4dfa-b570-d013f4ee3a15	\N	48c7fe74-5692-42c1-9068-c52c071221e8	487a4011-366a-4e1c-ac4d-6f24e62436c6	بررسی رزومه‌های متقاضیان شغلی #83	\N	high	2026-07-29	b14c05be-1566-4c1f-84d8-3c64b1a60ef3	2026-07-20 09:59:26.363877+00	2026-07-20 09:59:26.363877+00	todo	\N	14	17.80	2026-07-27
a03a787d-b998-4a31-aa2e-2aef31ab5784	17a90a26-1810-4dfa-b570-d013f4ee3a15	\N	3de0e871-5193-4e41-885f-531073da833a	487a4011-366a-4e1c-ac4d-6f24e62436c6	برنامه‌ریزی رویداد تیم‌سازی #84	\N	high	2026-07-31	59d34b0e-9949-4175-aaef-639290a3a40d	2026-07-20 09:59:26.363877+00	2026-07-20 09:59:26.363877+00	todo	\N	19	9.80	2026-07-21
a03a787d-b998-4a31-aa2e-2aef31ab5784	17a90a26-1810-4dfa-b570-d013f4ee3a15	\N	48c7fe74-5692-42c1-9068-c52c071221e8	487a4011-366a-4e1c-ac4d-6f24e62436c6	پیگیری مرخصی و مأموریت کارکنان #85	\N	high	2026-07-17	575e6493-aa8a-46d9-acc4-27a41822634d	2026-07-20 09:59:26.363877+00	2026-07-20 09:59:26.363877+00	completed	approved	100	12.30	2026-07-12
a03a787d-b998-4a31-aa2e-2aef31ab5784	17a90a26-1810-4dfa-b570-d013f4ee3a15	\N	fac1f37f-7665-4a91-b497-43238269a2e8	487a4011-366a-4e1c-ac4d-6f24e62436c6	بررسی و تمدید قراردادهای پرسنلی #86	\N	high	2026-08-13	d570cd0c-b466-4ae6-b8e0-6b4c2fac708f	2026-07-20 09:59:26.363877+00	2026-07-20 09:59:26.363877+00	completed	approved	100	25.50	2026-08-08
a03a787d-b998-4a31-aa2e-2aef31ab5784	17a90a26-1810-4dfa-b570-d013f4ee3a15	\N	06467080-462f-4467-a2ac-577bc7c7dff6	487a4011-366a-4e1c-ac4d-6f24e62436c6	برنامه‌ریزی رویداد تیم‌سازی #87	\N	low	2026-08-10	6163f81d-f772-40d4-ba1c-e52df81babf6	2026-07-20 09:59:26.363877+00	2026-07-20 09:59:26.363877+00	todo	\N	77	9.60	2026-08-05
a03a787d-b998-4a31-aa2e-2aef31ab5784	17a90a26-1810-4dfa-b570-d013f4ee3a15	\N	06467080-462f-4467-a2ac-577bc7c7dff6	487a4011-366a-4e1c-ac4d-6f24e62436c6	به‌روزرسانی آیین‌نامهٔ داخلی شرکت #88	\N	low	2026-07-23	a894e7b2-485d-4dbc-9490-6a066715a433	2026-07-20 09:59:26.363877+00	2026-07-20 09:59:26.363877+00	completed	rejected	100	3.50	2026-07-08
a03a787d-b998-4a31-aa2e-2aef31ab5784	17a90a26-1810-4dfa-b570-d013f4ee3a15	\N	3de0e871-5193-4e41-885f-531073da833a	487a4011-366a-4e1c-ac4d-6f24e62436c6	پیگیری درخواست‌های رفاهی کارکنان #89	\N	low	2026-08-16	081bfe26-75bf-4f2e-b0c3-974827627546	2026-07-20 09:59:26.363877+00	2026-07-20 09:59:26.363877+00	in_progress	\N	0	2.50	2026-07-30
a03a787d-b998-4a31-aa2e-2aef31ab5784	17a90a26-1810-4dfa-b570-d013f4ee3a15	\N	487a4011-366a-4e1c-ac4d-6f24e62436c6	487a4011-366a-4e1c-ac4d-6f24e62436c6	پیگیری مرخصی و مأموریت کارکنان #90	\N	medium	2026-08-28	65d8eb7e-e8b9-4a86-8975-c55962fa06e0	2026-07-20 09:59:26.363877+00	2026-07-20 09:59:26.363877+00	todo	\N	19	38.10	2026-08-08
a03a787d-b998-4a31-aa2e-2aef31ab5784	\N	\N	929fcc10-abd5-4d94-9b84-fb05ba764ba0	929fcc10-abd5-4d94-9b84-fb05ba764ba0	بررسی درخواست ترفیع کارکنان #91	\N	medium	2026-08-06	a9685974-643c-4e8d-8523-60f40134a3da	2026-07-20 09:59:26.363877+00	2026-07-20 09:59:26.363877+00	completed	approved	100	26.50	2026-08-01
a03a787d-b998-4a31-aa2e-2aef31ab5784	\N	\N	3de0e871-5193-4e41-885f-531073da833a	3de0e871-5193-4e41-885f-531073da833a	بررسی رزومه‌های متقاضیان شغلی #92	\N	low	2026-07-18	2bee29de-2343-4617-8e54-9f266f894d49	2026-07-20 09:59:26.363877+00	2026-07-20 09:59:26.363877+00	in_progress	\N	22	35.20	2026-07-02
a03a787d-b998-4a31-aa2e-2aef31ab5784	\N	\N	929fcc10-abd5-4d94-9b84-fb05ba764ba0	929fcc10-abd5-4d94-9b84-fb05ba764ba0	تهیهٔ فرم ارزیابی سه‌ماهه #93	\N	high	2026-07-21	ad8526ac-92f0-4b0b-9a03-f24a2d7ed22d	2026-07-20 09:59:26.363877+00	2026-07-20 09:59:26.363877+00	in_progress	\N	14	5.60	2026-07-09
a03a787d-b998-4a31-aa2e-2aef31ab5784	\N	\N	929fcc10-abd5-4d94-9b84-fb05ba764ba0	929fcc10-abd5-4d94-9b84-fb05ba764ba0	پیگیری مرخصی و مأموریت کارکنان #94	\N	high	2026-06-22	a111e9c6-1356-46e6-973e-268901a3a472	2026-07-20 09:59:26.363877+00	2026-07-20 09:59:26.363877+00	todo	\N	21	14.50	2026-06-16
a03a787d-b998-4a31-aa2e-2aef31ab5784	\N	\N	3de0e871-5193-4e41-885f-531073da833a	3de0e871-5193-4e41-885f-531073da833a	پیگیری درخواست‌های رفاهی کارکنان #95	\N	medium	2026-08-05	3db269cd-c7c2-40df-8025-3c85bc1545f4	2026-07-20 09:59:26.363877+00	2026-07-20 09:59:26.363877+00	completed	approved	100	8.90	2026-08-01
a03a787d-b998-4a31-aa2e-2aef31ab5784	\N	\N	3de0e871-5193-4e41-885f-531073da833a	3de0e871-5193-4e41-885f-531073da833a	تهیهٔ گزارش غیبت و تأخیر #96	\N	medium	2026-07-25	301452c7-449a-4e95-9bc9-66fee3ac2faa	2026-07-20 09:59:26.363877+00	2026-07-20 09:59:26.363877+00	in_progress	\N	61	32.40	2026-07-15
a03a787d-b998-4a31-aa2e-2aef31ab5784	\N	\N	48c7fe74-5692-42c1-9068-c52c071221e8	48c7fe74-5692-42c1-9068-c52c071221e8	به‌روزرسانی پروندهٔ پرسنلی #97	\N	high	2026-06-29	d9caabd4-9dc6-4c4c-909b-c51285857426	2026-07-20 09:59:26.363877+00	2026-07-20 09:59:26.363877+00	todo	\N	7	39.30	2026-06-23
a03a787d-b998-4a31-aa2e-2aef31ab5784	\N	\N	929fcc10-abd5-4d94-9b84-fb05ba764ba0	929fcc10-abd5-4d94-9b84-fb05ba764ba0	بررسی درخواست ترفیع کارکنان #98	\N	high	2026-07-07	5d662123-e7d6-438a-b4b6-b5b2f10237c3	2026-07-20 09:59:26.363877+00	2026-07-20 09:59:26.363877+00	todo	\N	61	32.50	2026-06-22
a03a787d-b998-4a31-aa2e-2aef31ab5784	\N	\N	48c7fe74-5692-42c1-9068-c52c071221e8	48c7fe74-5692-42c1-9068-c52c071221e8	تدوین برنامهٔ آموزشی سال آینده #99	\N	low	2026-07-23	e1d35c64-ccda-4b08-a84f-e4688fd5495b	2026-07-20 09:59:26.363877+00	2026-07-20 09:59:26.363877+00	completed	approved	100	34.80	2026-07-10
a03a787d-b998-4a31-aa2e-2aef31ab5784	\N	\N	929fcc10-abd5-4d94-9b84-fb05ba764ba0	929fcc10-abd5-4d94-9b84-fb05ba764ba0	برنامه‌ریزی رویداد تیم‌سازی #100	\N	medium	2026-08-18	335ef8ba-6ec0-4d31-9d09-0ae3f5b239a1	2026-07-20 09:59:26.363877+00	2026-07-20 09:59:26.363877+00	archived	\N	14	35.70	2026-08-12
a03a787d-b998-4a31-aa2e-2aef31ab5784	\N	\N	3de0e871-5193-4e41-885f-531073da833a	3de0e871-5193-4e41-885f-531073da833a	پیگیری مرخصی و مأموریت کارکنان #101	\N	medium	2026-06-30	e296f496-9b69-4db9-94d8-693d3f7dfd48	2026-07-20 09:59:26.363877+00	2026-07-20 09:59:26.363877+00	todo	\N	1	28.80	2026-06-20
a03a787d-b998-4a31-aa2e-2aef31ab5784	\N	\N	48c7fe74-5692-42c1-9068-c52c071221e8	48c7fe74-5692-42c1-9068-c52c071221e8	برگزاری جلسهٔ آموزش کارکنان جدید #102	\N	high	2026-08-11	cee1c0ec-7d0b-4422-99cf-f8d95711b2d8	2026-07-20 09:59:26.363877+00	2026-07-20 09:59:26.363877+00	completed	pending	100	35.20	2026-07-22
a03a787d-b998-4a31-aa2e-2aef31ab5784	\N	\N	fac1f37f-7665-4a91-b497-43238269a2e8	fac1f37f-7665-4a91-b497-43238269a2e8	تهیهٔ فرم ارزیابی سه‌ماهه #103	\N	high	2026-07-30	6d425010-a6fd-457f-b610-589c92b5737c	2026-07-20 09:59:26.363877+00	2026-07-20 09:59:26.363877+00	completed	pending	100	29.60	2026-07-25
a03a787d-b998-4a31-aa2e-2aef31ab5784	\N	\N	3de0e871-5193-4e41-885f-531073da833a	3de0e871-5193-4e41-885f-531073da833a	تهیهٔ گزارش ارزیابی عملکرد #104	\N	high	2026-08-11	6d300990-f017-46bc-a27a-f5a9df2a53d3	2026-07-20 09:59:26.363877+00	2026-07-20 09:59:26.363877+00	in_progress	\N	78	4.10	2026-07-28
a03a787d-b998-4a31-aa2e-2aef31ab5784	\N	\N	48c7fe74-5692-42c1-9068-c52c071221e8	48c7fe74-5692-42c1-9068-c52c071221e8	تهیهٔ گزارش غیبت و تأخیر #105	\N	medium	2026-08-04	3e862951-0205-4c6b-b503-c24e9a96ce31	2026-07-20 09:59:26.363877+00	2026-07-20 09:59:26.363877+00	todo	\N	21	4.80	2026-07-18
\.


--
-- Data for Name: users; Type: TABLE DATA; Schema: public; Owner: -
--

COPY public.users (organization_id, email, hashed_password, full_name, role, is_active, id, created_at, updated_at, phone_number, department_id) FROM stdin;
a03a787d-b998-4a31-aa2e-2aef31ab5784	admin@test.local	$2b$12$nTZAaklyEH3Mdu8kgBHcVenySh3ww58UeGdifSwIFzmTABQDoaibG	مدیر سازمان	org_admin	t	9827c403-87f1-46cd-875d-0796d77e64a1	2026-07-20 09:59:26.363877+00	2026-07-20 09:59:26.363877+00	09100000001	f4d62802-b855-4f52-8349-6643ab15df57
a03a787d-b998-4a31-aa2e-2aef31ab5784	eng.manager@test.local	$2b$12$D6pdysfI1c2YBv/6S8M5Uuk6rgMiUo6UsJ.ExlH6hSuOHl3fz.QP6	مدیر پروژه مهندسی و فنی	project_manager	t	1fd6e737-0c6b-49b7-841e-0f8a73d3c1a1	2026-07-20 09:59:26.363877+00	2026-07-20 09:59:26.363877+00	09111000000	f4d62802-b855-4f52-8349-6643ab15df57
a03a787d-b998-4a31-aa2e-2aef31ab5784	eng.emp1@test.local	$2b$12$LaMqNolYzDIf3RkgvnwbcOjm5duUvsXfNj3O8ZrUbbKzQxm3BS4SG	کارمند 1 مهندسی و فنی	employee	t	842034d4-0d08-46e1-bdd9-05eec45bcffa	2026-07-20 09:59:26.363877+00	2026-07-20 09:59:26.363877+00	09111000011	f4d62802-b855-4f52-8349-6643ab15df57
a03a787d-b998-4a31-aa2e-2aef31ab5784	eng.emp2@test.local	$2b$12$U7RvzSs9hWt5DLkR9R8A.e/7de6r15ivRQY9k3GOC7sPBwGUkGXGG	کارمند 2 مهندسی و فنی	employee	t	be1819a8-75ce-4c92-8f50-3b2a8aa29e30	2026-07-20 09:59:26.363877+00	2026-07-20 09:59:26.363877+00	09111000012	f4d62802-b855-4f52-8349-6643ab15df57
a03a787d-b998-4a31-aa2e-2aef31ab5784	eng.emp3@test.local	$2b$12$P1DI17u4klikGQq.qnq6IuTZUNcp3heGoDu9h4ONbx.j6rc0WBtOu	کارمند 3 مهندسی و فنی	employee	t	07e1c1ad-90c2-4b01-80d6-88ad81b6cc78	2026-07-20 09:59:26.363877+00	2026-07-20 09:59:26.363877+00	09111000013	f4d62802-b855-4f52-8349-6643ab15df57
a03a787d-b998-4a31-aa2e-2aef31ab5784	eng.emp4@test.local	$2b$12$AQIFpWc1Y.PHQ6F6XG/SNeM5IxtaWccIEiwFo5CC/HYXEZ4b5KzDS	کارمند 4 مهندسی و فنی	employee	t	e5ed62a2-bd4a-46d5-a6c6-be866906977f	2026-07-20 09:59:26.363877+00	2026-07-20 09:59:26.363877+00	09111000014	f4d62802-b855-4f52-8349-6643ab15df57
a03a787d-b998-4a31-aa2e-2aef31ab5784	eng.emp5@test.local	$2b$12$ztgKaAGoM9d06A8eQQlkjOTWEs0Q9xZIh7Nfk/XCAwsEgmMVynk4a	کارمند 5 مهندسی و فنی	employee	t	d6fc165d-7448-431b-af51-26d9bb7751a1	2026-07-20 09:59:26.363877+00	2026-07-20 09:59:26.363877+00	09111000015	f4d62802-b855-4f52-8349-6643ab15df57
a03a787d-b998-4a31-aa2e-2aef31ab5784	eng.emp6@test.local	$2b$12$pILSGYi/Sil9mLusFQTY/edCPD4wWhswmeiPkqKkyv2SHbpgDd3Pm	کارمند 6 مهندسی و فنی	employee	t	b0bcd30d-df04-4c14-bdf8-7923f39ea52e	2026-07-20 09:59:26.363877+00	2026-07-20 09:59:26.363877+00	09111000016	f4d62802-b855-4f52-8349-6643ab15df57
a03a787d-b998-4a31-aa2e-2aef31ab5784	fin.manager@test.local	$2b$12$s4ilKAm5gEbsrUwx7ZuzJeTFoN5MSuLJ8pq8wnFMbXrADXUgcIVpu	مدیر پروژه حسابداری و مالی	project_manager	t	328fce4c-c7e7-4b44-8dcb-45aad65bd8e5	2026-07-20 09:59:26.363877+00	2026-07-20 09:59:26.363877+00	09121000100	bfceb7aa-5547-4d7c-a828-f73ac786de5a
a03a787d-b998-4a31-aa2e-2aef31ab5784	fin.emp1@test.local	$2b$12$q12EVNUgA38/VgNKk12kkuVbuqnXnpLT5c.TODNNfU0pnx/hIM89m	کارمند 1 حسابداری و مالی	employee	t	1775df44-8335-487a-9a3b-a1a6eb5949f5	2026-07-20 09:59:26.363877+00	2026-07-20 09:59:26.363877+00	09121000111	bfceb7aa-5547-4d7c-a828-f73ac786de5a
a03a787d-b998-4a31-aa2e-2aef31ab5784	fin.emp2@test.local	$2b$12$iPb3KYiyFLcSQRJVhiI9YebUG6Mm9/BnoUdbkBSD/KxQz80Bl3AlW	کارمند 2 حسابداری و مالی	employee	t	c1eff56a-cf6f-4901-9c44-9063f53db8c8	2026-07-20 09:59:26.363877+00	2026-07-20 09:59:26.363877+00	09121000112	bfceb7aa-5547-4d7c-a828-f73ac786de5a
a03a787d-b998-4a31-aa2e-2aef31ab5784	fin.emp3@test.local	$2b$12$DF1UM/RRpU1WBx4ZGUgijO5nAtub.00dmpvP.BfwGL/x1giL9X1nW	کارمند 3 حسابداری و مالی	employee	t	9c22bc65-2479-4780-b3a0-0ed5e139ee5f	2026-07-20 09:59:26.363877+00	2026-07-20 09:59:26.363877+00	09121000113	bfceb7aa-5547-4d7c-a828-f73ac786de5a
a03a787d-b998-4a31-aa2e-2aef31ab5784	fin.emp4@test.local	$2b$12$3O.U8Zr0xW/AvsVFhgyQ9uj66orYS6.f.tsAi41xcJ7.3gDaypmJa	کارمند 4 حسابداری و مالی	employee	t	767b011b-ff3a-4faf-b85b-c424554a44a0	2026-07-20 09:59:26.363877+00	2026-07-20 09:59:26.363877+00	09121000114	bfceb7aa-5547-4d7c-a828-f73ac786de5a
a03a787d-b998-4a31-aa2e-2aef31ab5784	fin.emp5@test.local	$2b$12$hIBN/rwXuvULjroBFPU7OuZ7vU7KTy1b/Uy09dAHLbzil0bWijcDe	کارمند 5 حسابداری و مالی	employee	t	f2917b41-6f1c-4444-a73d-884a91e847fe	2026-07-20 09:59:26.363877+00	2026-07-20 09:59:26.363877+00	09121000115	bfceb7aa-5547-4d7c-a828-f73ac786de5a
a03a787d-b998-4a31-aa2e-2aef31ab5784	fin.emp6@test.local	$2b$12$6NpN.SinwuT4tCZHTrX2g.AGsgNCVGPXMSBkkEnfm0V8TDhk/9ye6	کارمند 6 حسابداری و مالی	employee	t	276feb60-37b2-42ff-be39-f9e79af8ae2a	2026-07-20 09:59:26.363877+00	2026-07-20 09:59:26.363877+00	09121000116	bfceb7aa-5547-4d7c-a828-f73ac786de5a
a03a787d-b998-4a31-aa2e-2aef31ab5784	hr.manager@test.local	$2b$12$ExXDj0rUKIM4OyGEXjPhpe5i6qGOeDwNTA4dlavYU6KS.kDg6c8RK	مدیر پروژه منابع انسانی	project_manager	t	487a4011-366a-4e1c-ac4d-6f24e62436c6	2026-07-20 09:59:26.363877+00	2026-07-20 09:59:26.363877+00	09131000200	40f20b30-be21-4dbc-bf5d-2461e3328527
a03a787d-b998-4a31-aa2e-2aef31ab5784	hr.emp1@test.local	$2b$12$qufXRpfCPfpaYDE.1IlQO.zm.woOZcyp3nIvqnAy3a2LCGKrd0ycO	کارمند 1 منابع انسانی	employee	t	8eb048e0-49b1-4d8a-9e1f-ab534f5d1564	2026-07-20 09:59:26.363877+00	2026-07-20 09:59:26.363877+00	09131000211	40f20b30-be21-4dbc-bf5d-2461e3328527
a03a787d-b998-4a31-aa2e-2aef31ab5784	hr.emp2@test.local	$2b$12$IdQdA2MvQ8IhbebYaSQxvOT8mlorSduZmOf6dYYF.89LFm9zifoLC	کارمند 2 منابع انسانی	employee	t	06467080-462f-4467-a2ac-577bc7c7dff6	2026-07-20 09:59:26.363877+00	2026-07-20 09:59:26.363877+00	09131000212	40f20b30-be21-4dbc-bf5d-2461e3328527
a03a787d-b998-4a31-aa2e-2aef31ab5784	hr.emp3@test.local	$2b$12$dwMvdlcP65H/mTAMF12Pl.b1IxdHhfGYLWokdZrUwPe2K2EPWTl9G	کارمند 3 منابع انسانی	employee	t	3de0e871-5193-4e41-885f-531073da833a	2026-07-20 09:59:26.363877+00	2026-07-20 09:59:26.363877+00	09131000213	40f20b30-be21-4dbc-bf5d-2461e3328527
a03a787d-b998-4a31-aa2e-2aef31ab5784	hr.emp4@test.local	$2b$12$dZ7Cs3k84ifs1EPlyq3KXeIV7xfzlcFVW2XyqbI0MYO/EHyDMNH7C	کارمند 4 منابع انسانی	employee	t	fac1f37f-7665-4a91-b497-43238269a2e8	2026-07-20 09:59:26.363877+00	2026-07-20 09:59:26.363877+00	09131000214	40f20b30-be21-4dbc-bf5d-2461e3328527
a03a787d-b998-4a31-aa2e-2aef31ab5784	hr.emp5@test.local	$2b$12$r2JNj.Wv.Y6573Q73pephu0I35WkWhVRE/1wp3r4TRyJqX4UTL30W	کارمند 5 منابع انسانی	employee	t	48c7fe74-5692-42c1-9068-c52c071221e8	2026-07-20 09:59:26.363877+00	2026-07-20 09:59:26.363877+00	09131000215	40f20b30-be21-4dbc-bf5d-2461e3328527
a03a787d-b998-4a31-aa2e-2aef31ab5784	hr.emp6@test.local	$2b$12$9Z6xYENDpR4HyHfQXebtY.mw00EsiDDXpSH0gnEqV6WX277TZc3ny	کارمند 6 منابع انسانی	employee	t	929fcc10-abd5-4d94-9b84-fb05ba764ba0	2026-07-20 09:59:26.363877+00	2026-07-20 09:59:26.363877+00	09131000216	40f20b30-be21-4dbc-bf5d-2461e3328527
\.


--
-- Data for Name: worklogs; Type: TABLE DATA; Schema: public; Owner: -
--

COPY public.worklogs (organization_id, task_id, user_id, activity_description, time_spent_minutes, progress_percent, log_date, status, reviewed_by_id, review_comment, id, created_at, updated_at) FROM stdin;
a03a787d-b998-4a31-aa2e-2aef31ab5784	7338d11b-7d86-4e3f-b24a-6bb8af79486b	d6fc165d-7448-431b-af51-26d9bb7751a1	مستندسازی و نهایی‌سازی	224	27	2026-07-12	approved	1fd6e737-0c6b-49b7-841e-0f8a73d3c1a1	\N	eae40834-c61f-44da-baaf-23c3a08e4fb7	2026-07-20 09:59:26.363877+00	2026-07-20 09:59:26.363877+00
a03a787d-b998-4a31-aa2e-2aef31ab5784	7338d11b-7d86-4e3f-b24a-6bb8af79486b	d6fc165d-7448-431b-af51-26d9bb7751a1	تست و اطمینان از عملکرد صحیح	144	40	2026-07-16	approved	1fd6e737-0c6b-49b7-841e-0f8a73d3c1a1	\N	c0bedd39-fc02-4d77-ba88-78d31f43ac08	2026-07-20 09:59:26.363877+00	2026-07-20 09:59:26.363877+00
a03a787d-b998-4a31-aa2e-2aef31ab5784	7338d11b-7d86-4e3f-b24a-6bb8af79486b	d6fc165d-7448-431b-af51-26d9bb7751a1	رفع اشکالات و بازبینی	86	96	2026-07-14	approved	1fd6e737-0c6b-49b7-841e-0f8a73d3c1a1	\N	a8e978c0-5db9-481b-b67d-6d726419025f	2026-07-20 09:59:26.363877+00	2026-07-20 09:59:26.363877+00
a03a787d-b998-4a31-aa2e-2aef31ab5784	7338d11b-7d86-4e3f-b24a-6bb8af79486b	d6fc165d-7448-431b-af51-26d9bb7751a1	رفع اشکالات و بازبینی	199	100	2026-07-16	approved	1fd6e737-0c6b-49b7-841e-0f8a73d3c1a1	\N	3ac98c93-0ec3-4aad-b9e9-cf60399670f8	2026-07-20 09:59:26.363877+00	2026-07-20 09:59:26.363877+00
a03a787d-b998-4a31-aa2e-2aef31ab5784	66eb5e95-b634-46a7-98d5-ed8b6fe49e51	842034d4-0d08-46e1-bdd9-05eec45bcffa	مستندسازی و نهایی‌سازی	165	31	2026-07-07	approved	1fd6e737-0c6b-49b7-841e-0f8a73d3c1a1	\N	0eb2c8ee-0413-4a0d-a955-d2fa55d63dda	2026-07-20 09:59:26.363877+00	2026-07-20 09:59:26.363877+00
a03a787d-b998-4a31-aa2e-2aef31ab5784	66eb5e95-b634-46a7-98d5-ed8b6fe49e51	842034d4-0d08-46e1-bdd9-05eec45bcffa	مستندسازی و نهایی‌سازی	114	62	2026-07-11	approved	1fd6e737-0c6b-49b7-841e-0f8a73d3c1a1	\N	2316a0bc-b4a0-41d8-9b78-71a2f0559312	2026-07-20 09:59:26.363877+00	2026-07-20 09:59:26.363877+00
a03a787d-b998-4a31-aa2e-2aef31ab5784	66eb5e95-b634-46a7-98d5-ed8b6fe49e51	842034d4-0d08-46e1-bdd9-05eec45bcffa	رفع اشکالات و بازبینی	108	84	2026-07-15	approved	1fd6e737-0c6b-49b7-841e-0f8a73d3c1a1	\N	672f37c7-0945-4136-bc3b-3a07a84eb1ad	2026-07-20 09:59:26.363877+00	2026-07-20 09:59:26.363877+00
a03a787d-b998-4a31-aa2e-2aef31ab5784	9a8b5087-3afd-4d63-8c58-be3409ac1003	be1819a8-75ce-4c92-8f50-3b2a8aa29e30	پیاده‌سازی بخش اصلی	110	23	2026-06-18	approved	1fd6e737-0c6b-49b7-841e-0f8a73d3c1a1	\N	ed0392db-1b0e-467e-a245-02edd684eb75	2026-07-20 09:59:26.363877+00	2026-07-20 09:59:26.363877+00
a03a787d-b998-4a31-aa2e-2aef31ab5784	9a8b5087-3afd-4d63-8c58-be3409ac1003	be1819a8-75ce-4c92-8f50-3b2a8aa29e30	پیاده‌سازی بخش اصلی	85	70	2026-06-20	approved	1fd6e737-0c6b-49b7-841e-0f8a73d3c1a1	\N	9b339713-573b-422c-a88f-638167bda986	2026-07-20 09:59:26.363877+00	2026-07-20 09:59:26.363877+00
a03a787d-b998-4a31-aa2e-2aef31ab5784	d9f10ef0-42cc-4368-b84d-e140b3d4d06c	be1819a8-75ce-4c92-8f50-3b2a8aa29e30	پیشرفت اولیه و بررسی نیازمندی‌ها	79	29	2026-06-20	approved	1fd6e737-0c6b-49b7-841e-0f8a73d3c1a1	\N	60df072b-7701-496d-b331-409ca36a318c	2026-07-20 09:59:26.363877+00	2026-07-20 09:59:26.363877+00
a03a787d-b998-4a31-aa2e-2aef31ab5784	d9f10ef0-42cc-4368-b84d-e140b3d4d06c	be1819a8-75ce-4c92-8f50-3b2a8aa29e30	رفع اشکالات و بازبینی	75	58	2026-06-22	approved	1fd6e737-0c6b-49b7-841e-0f8a73d3c1a1	\N	ede6ec49-4651-4988-a24a-6ae2061d2edb	2026-07-20 09:59:26.363877+00	2026-07-20 09:59:26.363877+00
a03a787d-b998-4a31-aa2e-2aef31ab5784	d9f10ef0-42cc-4368-b84d-e140b3d4d06c	be1819a8-75ce-4c92-8f50-3b2a8aa29e30	مستندسازی و نهایی‌سازی	62	84	2026-06-22	approved	1fd6e737-0c6b-49b7-841e-0f8a73d3c1a1	\N	7efc27a0-cc67-4a5d-aa9b-4e613f79e63b	2026-07-20 09:59:26.363877+00	2026-07-20 09:59:26.363877+00
a03a787d-b998-4a31-aa2e-2aef31ab5784	5d9ac457-0cd7-4b15-afc1-b268902ca34e	1fd6e737-0c6b-49b7-841e-0f8a73d3c1a1	پیاده‌سازی بخش اصلی	193	35	2026-07-16	approved	1fd6e737-0c6b-49b7-841e-0f8a73d3c1a1	\N	dad54fb6-d330-4009-a3a3-1793c446bfe2	2026-07-20 09:59:26.363877+00	2026-07-20 09:59:26.363877+00
a03a787d-b998-4a31-aa2e-2aef31ab5784	6dcf9705-665e-48c4-9a55-9612d8c0040b	d6fc165d-7448-431b-af51-26d9bb7751a1	مستندسازی و نهایی‌سازی	102	35	2026-07-16	approved	1fd6e737-0c6b-49b7-841e-0f8a73d3c1a1	\N	ae936715-76aa-43ba-ab8d-a6f44c835091	2026-07-20 09:59:26.363877+00	2026-07-20 09:59:26.363877+00
a03a787d-b998-4a31-aa2e-2aef31ab5784	a5984b9d-706c-47dd-900a-f62839c46d02	07e1c1ad-90c2-4b01-80d6-88ad81b6cc78	پیشرفت اولیه و بررسی نیازمندی‌ها	94	35	2026-07-03	approved	1fd6e737-0c6b-49b7-841e-0f8a73d3c1a1	\N	f054a53b-02a7-4899-b4c3-29a1001d9397	2026-07-20 09:59:26.363877+00	2026-07-20 09:59:26.363877+00
a03a787d-b998-4a31-aa2e-2aef31ab5784	a5984b9d-706c-47dd-900a-f62839c46d02	07e1c1ad-90c2-4b01-80d6-88ad81b6cc78	تست و اطمینان از عملکرد صحیح	155	44	2026-07-04	submitted	\N	\N	e8c56311-8668-4fe6-8807-317c9c7c0791	2026-07-20 09:59:26.363877+00	2026-07-20 09:59:26.363877+00
a03a787d-b998-4a31-aa2e-2aef31ab5784	a5984b9d-706c-47dd-900a-f62839c46d02	07e1c1ad-90c2-4b01-80d6-88ad81b6cc78	مستندسازی و نهایی‌سازی	107	66	2026-07-05	approved	1fd6e737-0c6b-49b7-841e-0f8a73d3c1a1	\N	17345ad2-72f7-4dec-995d-0f77d515b2a3	2026-07-20 09:59:26.363877+00	2026-07-20 09:59:26.363877+00
a03a787d-b998-4a31-aa2e-2aef31ab5784	a5984b9d-706c-47dd-900a-f62839c46d02	07e1c1ad-90c2-4b01-80d6-88ad81b6cc78	تست و اطمینان از عملکرد صحیح	185	100	2026-07-09	approved	1fd6e737-0c6b-49b7-841e-0f8a73d3c1a1	\N	22c8895c-1a65-4ecc-8914-2b8e2dc8f05e	2026-07-20 09:59:26.363877+00	2026-07-20 09:59:26.363877+00
a03a787d-b998-4a31-aa2e-2aef31ab5784	ab088a6f-2a7e-42df-8f86-aec1612a3c47	842034d4-0d08-46e1-bdd9-05eec45bcffa	تست و اطمینان از عملکرد صحیح	143	29	2026-07-06	approved	1fd6e737-0c6b-49b7-841e-0f8a73d3c1a1	\N	e707ea8f-bd8f-4a71-9893-66b932d63999	2026-07-20 09:59:26.363877+00	2026-07-20 09:59:26.363877+00
a03a787d-b998-4a31-aa2e-2aef31ab5784	ab088a6f-2a7e-42df-8f86-aec1612a3c47	842034d4-0d08-46e1-bdd9-05eec45bcffa	رفع اشکالات و بازبینی	175	78	2026-07-10	approved	1fd6e737-0c6b-49b7-841e-0f8a73d3c1a1	\N	ae996f8a-4d7b-4481-b5b2-730b0eb28953	2026-07-20 09:59:26.363877+00	2026-07-20 09:59:26.363877+00
a03a787d-b998-4a31-aa2e-2aef31ab5784	2ae6a384-be09-4166-9550-79109f742e58	d6fc165d-7448-431b-af51-26d9bb7751a1	پیاده‌سازی بخش اصلی	190	26	2026-06-24	approved	1fd6e737-0c6b-49b7-841e-0f8a73d3c1a1	\N	576d50f7-f397-4e9b-8e4b-db30fd312114	2026-07-20 09:59:26.363877+00	2026-07-20 09:59:26.363877+00
a03a787d-b998-4a31-aa2e-2aef31ab5784	c9432a30-9f31-4fc2-a4f2-ca267097ca48	d6fc165d-7448-431b-af51-26d9bb7751a1	پیاده‌سازی بخش اصلی	91	25	2026-07-16	approved	1fd6e737-0c6b-49b7-841e-0f8a73d3c1a1	\N	04ddde58-2eab-4505-945a-15c3412ba831	2026-07-20 09:59:26.363877+00	2026-07-20 09:59:26.363877+00
a03a787d-b998-4a31-aa2e-2aef31ab5784	c9432a30-9f31-4fc2-a4f2-ca267097ca48	d6fc165d-7448-431b-af51-26d9bb7751a1	پیاده‌سازی بخش اصلی	30	66	2026-07-16	approved	1fd6e737-0c6b-49b7-841e-0f8a73d3c1a1	\N	ba8018f5-2dea-47fa-b367-c7a8d39be54e	2026-07-20 09:59:26.363877+00	2026-07-20 09:59:26.363877+00
a03a787d-b998-4a31-aa2e-2aef31ab5784	c9432a30-9f31-4fc2-a4f2-ca267097ca48	d6fc165d-7448-431b-af51-26d9bb7751a1	مستندسازی و نهایی‌سازی	150	87	2026-07-16	approved	1fd6e737-0c6b-49b7-841e-0f8a73d3c1a1	\N	77c065c4-fd3f-4b44-bb2d-cd0d41c6f1cb	2026-07-20 09:59:26.363877+00	2026-07-20 09:59:26.363877+00
a03a787d-b998-4a31-aa2e-2aef31ab5784	60b13366-60ed-41c5-912e-7d347f99a3ef	842034d4-0d08-46e1-bdd9-05eec45bcffa	رفع اشکالات و بازبینی	210	29	2026-07-16	approved	1fd6e737-0c6b-49b7-841e-0f8a73d3c1a1	\N	a6b002f6-6dfd-4903-a13a-307ae5cc10c2	2026-07-20 09:59:26.363877+00	2026-07-20 09:59:26.363877+00
a03a787d-b998-4a31-aa2e-2aef31ab5784	313d57ec-292f-4200-bd27-3c855097e8e5	842034d4-0d08-46e1-bdd9-05eec45bcffa	پیاده‌سازی بخش اصلی	97	40	2026-06-20	approved	1fd6e737-0c6b-49b7-841e-0f8a73d3c1a1	\N	05423d67-348c-4d44-9ed3-43c2bae24e72	2026-07-20 09:59:26.363877+00	2026-07-20 09:59:26.363877+00
a03a787d-b998-4a31-aa2e-2aef31ab5784	313d57ec-292f-4200-bd27-3c855097e8e5	842034d4-0d08-46e1-bdd9-05eec45bcffa	تست و اطمینان از عملکرد صحیح	59	74	2026-06-22	approved	1fd6e737-0c6b-49b7-841e-0f8a73d3c1a1	\N	f9a8711f-a7ac-407c-80bd-1ece108ca416	2026-07-20 09:59:26.363877+00	2026-07-20 09:59:26.363877+00
a03a787d-b998-4a31-aa2e-2aef31ab5784	313d57ec-292f-4200-bd27-3c855097e8e5	842034d4-0d08-46e1-bdd9-05eec45bcffa	پیاده‌سازی بخش اصلی	98	72	2026-06-24	approved	1fd6e737-0c6b-49b7-841e-0f8a73d3c1a1	\N	83cbf545-83e0-4d68-adbd-454886493336	2026-07-20 09:59:26.363877+00	2026-07-20 09:59:26.363877+00
a03a787d-b998-4a31-aa2e-2aef31ab5784	313d57ec-292f-4200-bd27-3c855097e8e5	842034d4-0d08-46e1-bdd9-05eec45bcffa	پیشرفت اولیه و بررسی نیازمندی‌ها	72	100	2026-06-23	approved	1fd6e737-0c6b-49b7-841e-0f8a73d3c1a1	\N	679da3de-cf94-4c66-b3af-28abf8500e2d	2026-07-20 09:59:26.363877+00	2026-07-20 09:59:26.363877+00
a03a787d-b998-4a31-aa2e-2aef31ab5784	1e2d78aa-e6f9-47cc-82fc-f76233a6e12b	e5ed62a2-bd4a-46d5-a6c6-be866906977f	رفع اشکالات و بازبینی	209	32	2026-07-16	approved	1fd6e737-0c6b-49b7-841e-0f8a73d3c1a1	\N	c146df9a-cbe1-4cd6-9d03-6c18cc351c96	2026-07-20 09:59:26.363877+00	2026-07-20 09:59:26.363877+00
a03a787d-b998-4a31-aa2e-2aef31ab5784	1e2d78aa-e6f9-47cc-82fc-f76233a6e12b	e5ed62a2-bd4a-46d5-a6c6-be866906977f	تست و اطمینان از عملکرد صحیح	142	44	2026-07-16	approved	1fd6e737-0c6b-49b7-841e-0f8a73d3c1a1	\N	b0bbdeee-00ab-43ea-b051-8e44204cdb96	2026-07-20 09:59:26.363877+00	2026-07-20 09:59:26.363877+00
a03a787d-b998-4a31-aa2e-2aef31ab5784	1e2d78aa-e6f9-47cc-82fc-f76233a6e12b	e5ed62a2-bd4a-46d5-a6c6-be866906977f	رفع اشکالات و بازبینی	184	84	2026-07-16	submitted	\N	\N	e089f191-d584-460d-9742-38fd23451ee3	2026-07-20 09:59:26.363877+00	2026-07-20 09:59:26.363877+00
a03a787d-b998-4a31-aa2e-2aef31ab5784	9415daf5-6d23-4fa7-a52b-90efc8de35e9	e5ed62a2-bd4a-46d5-a6c6-be866906977f	پیاده‌سازی بخش اصلی	202	38	2026-07-03	approved	1fd6e737-0c6b-49b7-841e-0f8a73d3c1a1	\N	6f6ae46d-2e18-4b7a-baab-3bb4f403abff	2026-07-20 09:59:26.363877+00	2026-07-20 09:59:26.363877+00
a03a787d-b998-4a31-aa2e-2aef31ab5784	2430602e-8986-465b-8756-10b51693b5bb	1fd6e737-0c6b-49b7-841e-0f8a73d3c1a1	مستندسازی و نهایی‌سازی	40	25	2026-07-16	approved	1fd6e737-0c6b-49b7-841e-0f8a73d3c1a1	\N	d5bbcf82-a7e5-457a-8a65-c713343baeb8	2026-07-20 09:59:26.363877+00	2026-07-20 09:59:26.363877+00
a03a787d-b998-4a31-aa2e-2aef31ab5784	50bff075-48a2-4a6e-939c-67237f134a68	b0bcd30d-df04-4c14-bdf8-7923f39ea52e	رفع اشکالات و بازبینی	76	38	2026-07-16	approved	1fd6e737-0c6b-49b7-841e-0f8a73d3c1a1	\N	549c2a26-b86a-4527-bd22-b94122eb624b	2026-07-20 09:59:26.363877+00	2026-07-20 09:59:26.363877+00
a03a787d-b998-4a31-aa2e-2aef31ab5784	50bff075-48a2-4a6e-939c-67237f134a68	b0bcd30d-df04-4c14-bdf8-7923f39ea52e	تست و اطمینان از عملکرد صحیح	53	70	2026-07-16	approved	1fd6e737-0c6b-49b7-841e-0f8a73d3c1a1	\N	897682f7-9cc4-43b8-b81e-a06ca3707461	2026-07-20 09:59:26.363877+00	2026-07-20 09:59:26.363877+00
a03a787d-b998-4a31-aa2e-2aef31ab5784	50bff075-48a2-4a6e-939c-67237f134a68	b0bcd30d-df04-4c14-bdf8-7923f39ea52e	تست و اطمینان از عملکرد صحیح	115	90	2026-07-16	approved	1fd6e737-0c6b-49b7-841e-0f8a73d3c1a1	\N	5565b41e-8a35-4584-9cdc-d405ceff005c	2026-07-20 09:59:26.363877+00	2026-07-20 09:59:26.363877+00
a03a787d-b998-4a31-aa2e-2aef31ab5784	50bff075-48a2-4a6e-939c-67237f134a68	b0bcd30d-df04-4c14-bdf8-7923f39ea52e	پیاده‌سازی بخش اصلی	114	100	2026-07-16	approved	1fd6e737-0c6b-49b7-841e-0f8a73d3c1a1	\N	c8c5403a-a886-4377-970c-ec822ad3acca	2026-07-20 09:59:26.363877+00	2026-07-20 09:59:26.363877+00
a03a787d-b998-4a31-aa2e-2aef31ab5784	c397957b-61cb-4435-862a-d2667d41289a	842034d4-0d08-46e1-bdd9-05eec45bcffa	تست و اطمینان از عملکرد صحیح	238	37	2026-07-16	approved	1fd6e737-0c6b-49b7-841e-0f8a73d3c1a1	\N	65eb850c-628a-49a8-a2a7-2216fd963e62	2026-07-20 09:59:26.363877+00	2026-07-20 09:59:26.363877+00
a03a787d-b998-4a31-aa2e-2aef31ab5784	c397957b-61cb-4435-862a-d2667d41289a	842034d4-0d08-46e1-bdd9-05eec45bcffa	تست و اطمینان از عملکرد صحیح	52	60	2026-07-16	approved	1fd6e737-0c6b-49b7-841e-0f8a73d3c1a1	\N	d36ebb6d-a759-4154-b14b-e29acc3b196a	2026-07-20 09:59:26.363877+00	2026-07-20 09:59:26.363877+00
a03a787d-b998-4a31-aa2e-2aef31ab5784	c397957b-61cb-4435-862a-d2667d41289a	842034d4-0d08-46e1-bdd9-05eec45bcffa	رفع اشکالات و بازبینی	59	96	2026-07-16	approved	1fd6e737-0c6b-49b7-841e-0f8a73d3c1a1	\N	978fc799-3ff6-4151-90db-22e751b5884e	2026-07-20 09:59:26.363877+00	2026-07-20 09:59:26.363877+00
a03a787d-b998-4a31-aa2e-2aef31ab5784	c397957b-61cb-4435-862a-d2667d41289a	842034d4-0d08-46e1-bdd9-05eec45bcffa	مستندسازی و نهایی‌سازی	148	100	2026-07-16	approved	1fd6e737-0c6b-49b7-841e-0f8a73d3c1a1	\N	bf2ab56f-5bf7-4d2a-9d7b-9d429bd92629	2026-07-20 09:59:26.363877+00	2026-07-20 09:59:26.363877+00
a03a787d-b998-4a31-aa2e-2aef31ab5784	c0517833-8f26-4cca-b174-3840fc2d6c7c	07e1c1ad-90c2-4b01-80d6-88ad81b6cc78	مستندسازی و نهایی‌سازی	223	35	2026-07-16	approved	1fd6e737-0c6b-49b7-841e-0f8a73d3c1a1	\N	82d0f57e-c93f-4168-9996-fb69e0cf9e68	2026-07-20 09:59:26.363877+00	2026-07-20 09:59:26.363877+00
a03a787d-b998-4a31-aa2e-2aef31ab5784	72d9f497-52ed-4a58-91c6-bb0eb11a6c4d	07e1c1ad-90c2-4b01-80d6-88ad81b6cc78	پیاده‌سازی بخش اصلی	98	37	2026-07-14	approved	1fd6e737-0c6b-49b7-841e-0f8a73d3c1a1	\N	f032e511-77c4-4648-a657-d539c0f223fd	2026-07-20 09:59:26.363877+00	2026-07-20 09:59:26.363877+00
a03a787d-b998-4a31-aa2e-2aef31ab5784	72d9f497-52ed-4a58-91c6-bb0eb11a6c4d	07e1c1ad-90c2-4b01-80d6-88ad81b6cc78	رفع اشکالات و بازبینی	142	70	2026-07-16	approved	1fd6e737-0c6b-49b7-841e-0f8a73d3c1a1	\N	a812ffaa-d33e-4080-a389-08447966905a	2026-07-20 09:59:26.363877+00	2026-07-20 09:59:26.363877+00
a03a787d-b998-4a31-aa2e-2aef31ab5784	72d9f497-52ed-4a58-91c6-bb0eb11a6c4d	07e1c1ad-90c2-4b01-80d6-88ad81b6cc78	پیشرفت اولیه و بررسی نیازمندی‌ها	191	100	2026-07-16	approved	1fd6e737-0c6b-49b7-841e-0f8a73d3c1a1	\N	624060fc-3f96-44f9-8f6c-ad753ac55030	2026-07-20 09:59:26.363877+00	2026-07-20 09:59:26.363877+00
a03a787d-b998-4a31-aa2e-2aef31ab5784	72d9f497-52ed-4a58-91c6-bb0eb11a6c4d	07e1c1ad-90c2-4b01-80d6-88ad81b6cc78	پیاده‌سازی بخش اصلی	109	100	2026-07-16	approved	1fd6e737-0c6b-49b7-841e-0f8a73d3c1a1	\N	68f1db1b-d964-48cb-9bd5-b6550cdbfa04	2026-07-20 09:59:26.363877+00	2026-07-20 09:59:26.363877+00
a03a787d-b998-4a31-aa2e-2aef31ab5784	9f23e451-3203-4580-8afd-91a1b3785c0f	1fd6e737-0c6b-49b7-841e-0f8a73d3c1a1	پیشرفت اولیه و بررسی نیازمندی‌ها	148	23	2026-06-17	approved	1fd6e737-0c6b-49b7-841e-0f8a73d3c1a1	\N	a87310fb-bad5-4abd-9523-de7706176d1e	2026-07-20 09:59:26.363877+00	2026-07-20 09:59:26.363877+00
a03a787d-b998-4a31-aa2e-2aef31ab5784	c80af628-a8f8-4996-b098-7b3fd4556593	1fd6e737-0c6b-49b7-841e-0f8a73d3c1a1	رفع اشکالات و بازبینی	160	28	2026-07-16	approved	1fd6e737-0c6b-49b7-841e-0f8a73d3c1a1	\N	0db43f57-479b-4f89-9f19-7b08c64aaf34	2026-07-20 09:59:26.363877+00	2026-07-20 09:59:26.363877+00
a03a787d-b998-4a31-aa2e-2aef31ab5784	c80af628-a8f8-4996-b098-7b3fd4556593	1fd6e737-0c6b-49b7-841e-0f8a73d3c1a1	تست و اطمینان از عملکرد صحیح	150	54	2026-07-16	approved	1fd6e737-0c6b-49b7-841e-0f8a73d3c1a1	\N	43b0215e-229f-4013-b69d-cd43102772d4	2026-07-20 09:59:26.363877+00	2026-07-20 09:59:26.363877+00
a03a787d-b998-4a31-aa2e-2aef31ab5784	db23344f-538d-4c6c-b596-cd981afcb812	1fd6e737-0c6b-49b7-841e-0f8a73d3c1a1	تست و اطمینان از عملکرد صحیح	78	39	2026-07-16	approved	1fd6e737-0c6b-49b7-841e-0f8a73d3c1a1	\N	d44c9099-79f8-48e5-a6de-3e0d4437bf1f	2026-07-20 09:59:26.363877+00	2026-07-20 09:59:26.363877+00
a03a787d-b998-4a31-aa2e-2aef31ab5784	db23344f-538d-4c6c-b596-cd981afcb812	1fd6e737-0c6b-49b7-841e-0f8a73d3c1a1	پیشرفت اولیه و بررسی نیازمندی‌ها	100	66	2026-07-16	approved	1fd6e737-0c6b-49b7-841e-0f8a73d3c1a1	\N	6b2ae1f7-979f-4338-9d24-4b54754bad1a	2026-07-20 09:59:26.363877+00	2026-07-20 09:59:26.363877+00
a03a787d-b998-4a31-aa2e-2aef31ab5784	db23344f-538d-4c6c-b596-cd981afcb812	1fd6e737-0c6b-49b7-841e-0f8a73d3c1a1	مستندسازی و نهایی‌سازی	98	60	2026-07-16	approved	1fd6e737-0c6b-49b7-841e-0f8a73d3c1a1	\N	2ef3b8cd-271a-4142-8eb0-862e743b6394	2026-07-20 09:59:26.363877+00	2026-07-20 09:59:26.363877+00
a03a787d-b998-4a31-aa2e-2aef31ab5784	db23344f-538d-4c6c-b596-cd981afcb812	1fd6e737-0c6b-49b7-841e-0f8a73d3c1a1	رفع اشکالات و بازبینی	180	100	2026-07-16	approved	1fd6e737-0c6b-49b7-841e-0f8a73d3c1a1	\N	6b2101ba-7372-49ec-b256-b3409e1b2055	2026-07-20 09:59:26.363877+00	2026-07-20 09:59:26.363877+00
a03a787d-b998-4a31-aa2e-2aef31ab5784	df24183a-c61b-416d-baac-2dda67567e02	e5ed62a2-bd4a-46d5-a6c6-be866906977f	تست و اطمینان از عملکرد صحیح	167	35	2026-07-16	approved	1fd6e737-0c6b-49b7-841e-0f8a73d3c1a1	\N	bb3475a3-1a2d-41b5-a8ab-6642f3289b33	2026-07-20 09:59:26.363877+00	2026-07-20 09:59:26.363877+00
a03a787d-b998-4a31-aa2e-2aef31ab5784	df24183a-c61b-416d-baac-2dda67567e02	e5ed62a2-bd4a-46d5-a6c6-be866906977f	رفع اشکالات و بازبینی	171	74	2026-07-16	approved	1fd6e737-0c6b-49b7-841e-0f8a73d3c1a1	\N	d43c8c4d-469c-4218-93b9-bd4b3f337a31	2026-07-20 09:59:26.363877+00	2026-07-20 09:59:26.363877+00
a03a787d-b998-4a31-aa2e-2aef31ab5784	df24183a-c61b-416d-baac-2dda67567e02	e5ed62a2-bd4a-46d5-a6c6-be866906977f	تست و اطمینان از عملکرد صحیح	112	78	2026-07-16	approved	1fd6e737-0c6b-49b7-841e-0f8a73d3c1a1	\N	fd061aad-4b58-4b42-b9e9-c1bbc9210f9b	2026-07-20 09:59:26.363877+00	2026-07-20 09:59:26.363877+00
a03a787d-b998-4a31-aa2e-2aef31ab5784	df24183a-c61b-416d-baac-2dda67567e02	e5ed62a2-bd4a-46d5-a6c6-be866906977f	مستندسازی و نهایی‌سازی	128	100	2026-07-16	approved	1fd6e737-0c6b-49b7-841e-0f8a73d3c1a1	\N	fde24591-efe9-4563-812c-46c2a8f554f0	2026-07-20 09:59:26.363877+00	2026-07-20 09:59:26.363877+00
a03a787d-b998-4a31-aa2e-2aef31ab5784	9a98ab92-a0fe-4a08-a9a6-01dda768f49e	1fd6e737-0c6b-49b7-841e-0f8a73d3c1a1	رفع اشکالات و بازبینی	220	35	2026-07-13	approved	1fd6e737-0c6b-49b7-841e-0f8a73d3c1a1	\N	ad5a18fd-bcbe-4412-a859-994547ca8cdf	2026-07-20 09:59:26.363877+00	2026-07-20 09:59:26.363877+00
a03a787d-b998-4a31-aa2e-2aef31ab5784	9a98ab92-a0fe-4a08-a9a6-01dda768f49e	1fd6e737-0c6b-49b7-841e-0f8a73d3c1a1	تست و اطمینان از عملکرد صحیح	199	80	2026-07-16	approved	1fd6e737-0c6b-49b7-841e-0f8a73d3c1a1	\N	05830cb7-7293-4703-9304-387dcb321f6c	2026-07-20 09:59:26.363877+00	2026-07-20 09:59:26.363877+00
a03a787d-b998-4a31-aa2e-2aef31ab5784	9a98ab92-a0fe-4a08-a9a6-01dda768f49e	1fd6e737-0c6b-49b7-841e-0f8a73d3c1a1	تست و اطمینان از عملکرد صحیح	39	72	2026-07-16	approved	1fd6e737-0c6b-49b7-841e-0f8a73d3c1a1	\N	95bc03f5-c108-46f5-a9dc-6496426ec17b	2026-07-20 09:59:26.363877+00	2026-07-20 09:59:26.363877+00
a03a787d-b998-4a31-aa2e-2aef31ab5784	9a98ab92-a0fe-4a08-a9a6-01dda768f49e	1fd6e737-0c6b-49b7-841e-0f8a73d3c1a1	پیشرفت اولیه و بررسی نیازمندی‌ها	142	92	2026-07-16	approved	1fd6e737-0c6b-49b7-841e-0f8a73d3c1a1	\N	1b7ddc13-6227-402f-a7a2-ef715d3608b1	2026-07-20 09:59:26.363877+00	2026-07-20 09:59:26.363877+00
a03a787d-b998-4a31-aa2e-2aef31ab5784	0573add8-d250-43db-9bd1-2f70ea1a89e0	d6fc165d-7448-431b-af51-26d9bb7751a1	پیاده‌سازی بخش اصلی	134	40	2026-07-11	approved	1fd6e737-0c6b-49b7-841e-0f8a73d3c1a1	\N	c98ac105-5789-4e46-a534-f7fce8f79e3e	2026-07-20 09:59:26.363877+00	2026-07-20 09:59:26.363877+00
a03a787d-b998-4a31-aa2e-2aef31ab5784	0573add8-d250-43db-9bd1-2f70ea1a89e0	d6fc165d-7448-431b-af51-26d9bb7751a1	پیشرفت اولیه و بررسی نیازمندی‌ها	150	56	2026-07-13	approved	1fd6e737-0c6b-49b7-841e-0f8a73d3c1a1	\N	13be5ae8-d3f0-4ed3-bf66-11610adbd56a	2026-07-20 09:59:26.363877+00	2026-07-20 09:59:26.363877+00
a03a787d-b998-4a31-aa2e-2aef31ab5784	0573add8-d250-43db-9bd1-2f70ea1a89e0	d6fc165d-7448-431b-af51-26d9bb7751a1	مستندسازی و نهایی‌سازی	207	96	2026-07-16	approved	1fd6e737-0c6b-49b7-841e-0f8a73d3c1a1	\N	63b9f459-9fd1-44ab-ba57-617b98ea0b8e	2026-07-20 09:59:26.363877+00	2026-07-20 09:59:26.363877+00
a03a787d-b998-4a31-aa2e-2aef31ab5784	0573add8-d250-43db-9bd1-2f70ea1a89e0	d6fc165d-7448-431b-af51-26d9bb7751a1	رفع اشکالات و بازبینی	202	100	2026-07-14	approved	1fd6e737-0c6b-49b7-841e-0f8a73d3c1a1	\N	cd3936f3-b1d5-4e2a-9000-505c47a95c4b	2026-07-20 09:59:26.363877+00	2026-07-20 09:59:26.363877+00
a03a787d-b998-4a31-aa2e-2aef31ab5784	fb096ac1-c120-4e6d-b8a8-e93c420ce590	842034d4-0d08-46e1-bdd9-05eec45bcffa	تست و اطمینان از عملکرد صحیح	168	21	2026-07-13	approved	1fd6e737-0c6b-49b7-841e-0f8a73d3c1a1	\N	154496fd-27b3-4cea-a17c-691271de6d12	2026-07-20 09:59:26.363877+00	2026-07-20 09:59:26.363877+00
a03a787d-b998-4a31-aa2e-2aef31ab5784	fb096ac1-c120-4e6d-b8a8-e93c420ce590	842034d4-0d08-46e1-bdd9-05eec45bcffa	پیاده‌سازی بخش اصلی	191	58	2026-07-14	approved	1fd6e737-0c6b-49b7-841e-0f8a73d3c1a1	\N	5ab86320-580e-4197-83a9-0507d7b1464a	2026-07-20 09:59:26.363877+00	2026-07-20 09:59:26.363877+00
a03a787d-b998-4a31-aa2e-2aef31ab5784	fb096ac1-c120-4e6d-b8a8-e93c420ce590	842034d4-0d08-46e1-bdd9-05eec45bcffa	پیشرفت اولیه و بررسی نیازمندی‌ها	141	69	2026-07-16	approved	1fd6e737-0c6b-49b7-841e-0f8a73d3c1a1	\N	cca2ef8a-998f-47d6-8f0e-fe45c36d1523	2026-07-20 09:59:26.363877+00	2026-07-20 09:59:26.363877+00
a03a787d-b998-4a31-aa2e-2aef31ab5784	fb096ac1-c120-4e6d-b8a8-e93c420ce590	842034d4-0d08-46e1-bdd9-05eec45bcffa	تست و اطمینان از عملکرد صحیح	72	100	2026-07-16	approved	1fd6e737-0c6b-49b7-841e-0f8a73d3c1a1	\N	8726fdca-3c01-45d0-9fb0-47254918ffcf	2026-07-20 09:59:26.363877+00	2026-07-20 09:59:26.363877+00
a03a787d-b998-4a31-aa2e-2aef31ab5784	4970c728-2454-4c41-a0d4-7fb44dd98ba9	1fd6e737-0c6b-49b7-841e-0f8a73d3c1a1	رفع اشکالات و بازبینی	233	21	2026-07-16	approved	1fd6e737-0c6b-49b7-841e-0f8a73d3c1a1	\N	36d84414-3186-40d4-a285-b1dd3dd615f0	2026-07-20 09:59:26.363877+00	2026-07-20 09:59:26.363877+00
a03a787d-b998-4a31-aa2e-2aef31ab5784	13b3b11c-595c-42c4-a41a-0bf95675a51b	b0bcd30d-df04-4c14-bdf8-7923f39ea52e	پیاده‌سازی بخش اصلی	92	36	2026-07-16	approved	1fd6e737-0c6b-49b7-841e-0f8a73d3c1a1	\N	c6dba8c2-293c-404f-b395-372bf44b6b58	2026-07-20 09:59:26.363877+00	2026-07-20 09:59:26.363877+00
a03a787d-b998-4a31-aa2e-2aef31ab5784	13b3b11c-595c-42c4-a41a-0bf95675a51b	b0bcd30d-df04-4c14-bdf8-7923f39ea52e	پیاده‌سازی بخش اصلی	73	50	2026-07-16	approved	1fd6e737-0c6b-49b7-841e-0f8a73d3c1a1	\N	364252e5-403c-47a6-abce-8b5cb286ff75	2026-07-20 09:59:26.363877+00	2026-07-20 09:59:26.363877+00
a03a787d-b998-4a31-aa2e-2aef31ab5784	13b3b11c-595c-42c4-a41a-0bf95675a51b	b0bcd30d-df04-4c14-bdf8-7923f39ea52e	تست و اطمینان از عملکرد صحیح	188	81	2026-07-16	approved	1fd6e737-0c6b-49b7-841e-0f8a73d3c1a1	\N	fe04bbff-528e-40f7-902d-332a2f504dea	2026-07-20 09:59:26.363877+00	2026-07-20 09:59:26.363877+00
a03a787d-b998-4a31-aa2e-2aef31ab5784	cd36f159-85e5-41ab-820f-67bd17ed9dab	be1819a8-75ce-4c92-8f50-3b2a8aa29e30	پیاده‌سازی بخش اصلی	148	40	2026-07-16	approved	1fd6e737-0c6b-49b7-841e-0f8a73d3c1a1	\N	c3d1d381-3cbb-40b1-821b-970e3ff87ef5	2026-07-20 09:59:26.363877+00	2026-07-20 09:59:26.363877+00
a03a787d-b998-4a31-aa2e-2aef31ab5784	cd36f159-85e5-41ab-820f-67bd17ed9dab	be1819a8-75ce-4c92-8f50-3b2a8aa29e30	تست و اطمینان از عملکرد صحیح	95	40	2026-07-16	approved	1fd6e737-0c6b-49b7-841e-0f8a73d3c1a1	\N	2181b27d-b441-4743-a5ab-0420efd11a75	2026-07-20 09:59:26.363877+00	2026-07-20 09:59:26.363877+00
a03a787d-b998-4a31-aa2e-2aef31ab5784	cd36f159-85e5-41ab-820f-67bd17ed9dab	be1819a8-75ce-4c92-8f50-3b2a8aa29e30	رفع اشکالات و بازبینی	203	100	2026-07-16	approved	1fd6e737-0c6b-49b7-841e-0f8a73d3c1a1	\N	230f4d60-4956-43fe-b7f9-c7c4cdb19828	2026-07-20 09:59:26.363877+00	2026-07-20 09:59:26.363877+00
a03a787d-b998-4a31-aa2e-2aef31ab5784	cd36f159-85e5-41ab-820f-67bd17ed9dab	be1819a8-75ce-4c92-8f50-3b2a8aa29e30	پیشرفت اولیه و بررسی نیازمندی‌ها	143	100	2026-07-16	approved	1fd6e737-0c6b-49b7-841e-0f8a73d3c1a1	\N	e9e65460-3094-4c59-a44f-827f9c86cf54	2026-07-20 09:59:26.363877+00	2026-07-20 09:59:26.363877+00
a03a787d-b998-4a31-aa2e-2aef31ab5784	261b9548-75f2-4938-96e6-5d4d608c21e4	842034d4-0d08-46e1-bdd9-05eec45bcffa	تست و اطمینان از عملکرد صحیح	107	26	2026-06-29	approved	1fd6e737-0c6b-49b7-841e-0f8a73d3c1a1	\N	83ac723a-2f4e-414f-b119-d9c77c8bc71e	2026-07-20 09:59:26.363877+00	2026-07-20 09:59:26.363877+00
a03a787d-b998-4a31-aa2e-2aef31ab5784	261b9548-75f2-4938-96e6-5d4d608c21e4	842034d4-0d08-46e1-bdd9-05eec45bcffa	پیشرفت اولیه و بررسی نیازمندی‌ها	90	64	2026-07-03	submitted	\N	\N	0ab8dc5b-b129-45bb-9e51-7b3f5d009b27	2026-07-20 09:59:26.363877+00	2026-07-20 09:59:26.363877+00
a03a787d-b998-4a31-aa2e-2aef31ab5784	261b9548-75f2-4938-96e6-5d4d608c21e4	842034d4-0d08-46e1-bdd9-05eec45bcffa	رفع اشکالات و بازبینی	35	96	2026-07-05	approved	1fd6e737-0c6b-49b7-841e-0f8a73d3c1a1	\N	68c16624-0414-4cd5-8ba0-51c764bf0748	2026-07-20 09:59:26.363877+00	2026-07-20 09:59:26.363877+00
a03a787d-b998-4a31-aa2e-2aef31ab5784	51222d9e-adff-41f1-ad5c-3702e014132d	842034d4-0d08-46e1-bdd9-05eec45bcffa	پیشرفت اولیه و بررسی نیازمندی‌ها	185	35	2026-06-23	approved	1fd6e737-0c6b-49b7-841e-0f8a73d3c1a1	\N	ea964b69-be53-4cec-94e7-e1b32706f540	2026-07-20 09:59:26.363877+00	2026-07-20 09:59:26.363877+00
a03a787d-b998-4a31-aa2e-2aef31ab5784	51222d9e-adff-41f1-ad5c-3702e014132d	842034d4-0d08-46e1-bdd9-05eec45bcffa	پیاده‌سازی بخش اصلی	185	62	2026-06-26	submitted	\N	\N	8f186e7b-724a-4f6f-bd9b-59113d544b47	2026-07-20 09:59:26.363877+00	2026-07-20 09:59:26.363877+00
a03a787d-b998-4a31-aa2e-2aef31ab5784	51222d9e-adff-41f1-ad5c-3702e014132d	842034d4-0d08-46e1-bdd9-05eec45bcffa	مستندسازی و نهایی‌سازی	94	72	2026-06-27	approved	1fd6e737-0c6b-49b7-841e-0f8a73d3c1a1	\N	65b209be-4452-4539-9115-332c597a9850	2026-07-20 09:59:26.363877+00	2026-07-20 09:59:26.363877+00
a03a787d-b998-4a31-aa2e-2aef31ab5784	d4444be1-12ae-4337-a21c-88ccf1d42f39	1fd6e737-0c6b-49b7-841e-0f8a73d3c1a1	تست و اطمینان از عملکرد صحیح	38	38	2026-07-16	approved	1fd6e737-0c6b-49b7-841e-0f8a73d3c1a1	\N	71c6b392-b537-4d62-9098-b4922defd3b9	2026-07-20 09:59:26.363877+00	2026-07-20 09:59:26.363877+00
a03a787d-b998-4a31-aa2e-2aef31ab5784	43f85057-4e32-4328-bff2-c363eb5e75be	842034d4-0d08-46e1-bdd9-05eec45bcffa	پیشرفت اولیه و بررسی نیازمندی‌ها	105	30	2026-07-01	approved	1fd6e737-0c6b-49b7-841e-0f8a73d3c1a1	\N	3fc97be9-b7b8-4559-89b9-e7c85aad0c72	2026-07-20 09:59:26.363877+00	2026-07-20 09:59:26.363877+00
a03a787d-b998-4a31-aa2e-2aef31ab5784	43f85057-4e32-4328-bff2-c363eb5e75be	842034d4-0d08-46e1-bdd9-05eec45bcffa	پیاده‌سازی بخش اصلی	81	48	2026-07-05	approved	1fd6e737-0c6b-49b7-841e-0f8a73d3c1a1	\N	af4924cc-0635-47ae-866e-5c4de7347c21	2026-07-20 09:59:26.363877+00	2026-07-20 09:59:26.363877+00
a03a787d-b998-4a31-aa2e-2aef31ab5784	43f85057-4e32-4328-bff2-c363eb5e75be	842034d4-0d08-46e1-bdd9-05eec45bcffa	مستندسازی و نهایی‌سازی	158	84	2026-07-07	approved	1fd6e737-0c6b-49b7-841e-0f8a73d3c1a1	\N	3eb2b671-a4bd-4978-91a1-d91a51a223b4	2026-07-20 09:59:26.363877+00	2026-07-20 09:59:26.363877+00
a03a787d-b998-4a31-aa2e-2aef31ab5784	17d56399-8d5b-4f53-823f-07ca1e5b455f	be1819a8-75ce-4c92-8f50-3b2a8aa29e30	تست و اطمینان از عملکرد صحیح	236	29	2026-07-16	approved	1fd6e737-0c6b-49b7-841e-0f8a73d3c1a1	\N	09d5cc31-a3fc-4578-bc0f-40152f86bd11	2026-07-20 09:59:26.363877+00	2026-07-20 09:59:26.363877+00
a03a787d-b998-4a31-aa2e-2aef31ab5784	17d56399-8d5b-4f53-823f-07ca1e5b455f	be1819a8-75ce-4c92-8f50-3b2a8aa29e30	پیشرفت اولیه و بررسی نیازمندی‌ها	149	44	2026-07-16	approved	1fd6e737-0c6b-49b7-841e-0f8a73d3c1a1	\N	56f9f52a-1e56-479e-8f11-3adc96b611dd	2026-07-20 09:59:26.363877+00	2026-07-20 09:59:26.363877+00
a03a787d-b998-4a31-aa2e-2aef31ab5784	eef1ebf2-8940-4f32-80f3-387bf1762b3f	e5ed62a2-bd4a-46d5-a6c6-be866906977f	تست و اطمینان از عملکرد صحیح	235	37	2026-07-05	approved	1fd6e737-0c6b-49b7-841e-0f8a73d3c1a1	\N	d219af9e-4c1c-44b1-a620-d4257cf52d57	2026-07-20 09:59:26.363877+00	2026-07-20 09:59:26.363877+00
a03a787d-b998-4a31-aa2e-2aef31ab5784	eef1ebf2-8940-4f32-80f3-387bf1762b3f	e5ed62a2-bd4a-46d5-a6c6-be866906977f	پیشرفت اولیه و بررسی نیازمندی‌ها	232	64	2026-07-08	approved	1fd6e737-0c6b-49b7-841e-0f8a73d3c1a1	\N	b23a1053-0374-4172-b90d-df914ef8d4a4	2026-07-20 09:59:26.363877+00	2026-07-20 09:59:26.363877+00
a03a787d-b998-4a31-aa2e-2aef31ab5784	f0bedd4e-ed71-4a5b-aa86-b019c1354373	b0bcd30d-df04-4c14-bdf8-7923f39ea52e	مستندسازی و نهایی‌سازی	61	34	2026-07-16	approved	1fd6e737-0c6b-49b7-841e-0f8a73d3c1a1	\N	2e2eec3a-7f26-4b1e-a92c-09c1c6310202	2026-07-20 09:59:26.363877+00	2026-07-20 09:59:26.363877+00
a03a787d-b998-4a31-aa2e-2aef31ab5784	052707ac-a65d-4bf9-801a-52aa0dbf6b94	1fd6e737-0c6b-49b7-841e-0f8a73d3c1a1	مستندسازی و نهایی‌سازی	127	40	2026-07-16	approved	1fd6e737-0c6b-49b7-841e-0f8a73d3c1a1	\N	bc561b35-ceaf-4831-9092-25b51d8fb0fa	2026-07-20 09:59:26.363877+00	2026-07-20 09:59:26.363877+00
a03a787d-b998-4a31-aa2e-2aef31ab5784	052707ac-a65d-4bf9-801a-52aa0dbf6b94	1fd6e737-0c6b-49b7-841e-0f8a73d3c1a1	پیشرفت اولیه و بررسی نیازمندی‌ها	202	54	2026-07-16	approved	1fd6e737-0c6b-49b7-841e-0f8a73d3c1a1	\N	caa2dbc2-8a53-4040-acb7-3acbaa014a2c	2026-07-20 09:59:26.363877+00	2026-07-20 09:59:26.363877+00
a03a787d-b998-4a31-aa2e-2aef31ab5784	052707ac-a65d-4bf9-801a-52aa0dbf6b94	1fd6e737-0c6b-49b7-841e-0f8a73d3c1a1	پیشرفت اولیه و بررسی نیازمندی‌ها	188	100	2026-07-16	approved	1fd6e737-0c6b-49b7-841e-0f8a73d3c1a1	\N	03a15bef-87f2-439f-9e3c-b47eb8d6a8ba	2026-07-20 09:59:26.363877+00	2026-07-20 09:59:26.363877+00
a03a787d-b998-4a31-aa2e-2aef31ab5784	8b9b1245-bfa1-4706-bce6-0d14af61e663	be1819a8-75ce-4c92-8f50-3b2a8aa29e30	تست و اطمینان از عملکرد صحیح	209	29	2026-07-16	approved	1fd6e737-0c6b-49b7-841e-0f8a73d3c1a1	\N	ead6f638-31e4-4d9d-8247-f4068c46ec2c	2026-07-20 09:59:26.363877+00	2026-07-20 09:59:26.363877+00
a03a787d-b998-4a31-aa2e-2aef31ab5784	8b9b1245-bfa1-4706-bce6-0d14af61e663	be1819a8-75ce-4c92-8f50-3b2a8aa29e30	پیشرفت اولیه و بررسی نیازمندی‌ها	39	58	2026-07-16	approved	1fd6e737-0c6b-49b7-841e-0f8a73d3c1a1	\N	3f047c2f-6daf-47bd-a6a1-423d5f2e1d07	2026-07-20 09:59:26.363877+00	2026-07-20 09:59:26.363877+00
a03a787d-b998-4a31-aa2e-2aef31ab5784	8b9b1245-bfa1-4706-bce6-0d14af61e663	be1819a8-75ce-4c92-8f50-3b2a8aa29e30	پیاده‌سازی بخش اصلی	167	72	2026-07-16	approved	1fd6e737-0c6b-49b7-841e-0f8a73d3c1a1	\N	f7317ba4-5bd8-4fbc-b4ea-252d56ea2cf5	2026-07-20 09:59:26.363877+00	2026-07-20 09:59:26.363877+00
a03a787d-b998-4a31-aa2e-2aef31ab5784	60f56971-4ae5-40b8-8358-c51de8fbef83	07e1c1ad-90c2-4b01-80d6-88ad81b6cc78	رفع اشکالات و بازبینی	201	37	2026-06-20	approved	1fd6e737-0c6b-49b7-841e-0f8a73d3c1a1	\N	087373cf-aee4-4df4-9ac3-c70716a7e2d1	2026-07-20 09:59:26.363877+00	2026-07-20 09:59:26.363877+00
a03a787d-b998-4a31-aa2e-2aef31ab5784	60f56971-4ae5-40b8-8358-c51de8fbef83	07e1c1ad-90c2-4b01-80d6-88ad81b6cc78	مستندسازی و نهایی‌سازی	220	48	2026-06-24	approved	1fd6e737-0c6b-49b7-841e-0f8a73d3c1a1	\N	33fdd1bc-242f-4cca-b2ce-01c4d15c0949	2026-07-20 09:59:26.363877+00	2026-07-20 09:59:26.363877+00
a03a787d-b998-4a31-aa2e-2aef31ab5784	60f56971-4ae5-40b8-8358-c51de8fbef83	07e1c1ad-90c2-4b01-80d6-88ad81b6cc78	پیشرفت اولیه و بررسی نیازمندی‌ها	155	100	2026-06-28	approved	1fd6e737-0c6b-49b7-841e-0f8a73d3c1a1	\N	7d1a29eb-9607-4da1-8bc4-790d672fe49a	2026-07-20 09:59:26.363877+00	2026-07-20 09:59:26.363877+00
a03a787d-b998-4a31-aa2e-2aef31ab5784	60f56971-4ae5-40b8-8358-c51de8fbef83	07e1c1ad-90c2-4b01-80d6-88ad81b6cc78	رفع اشکالات و بازبینی	38	100	2026-07-02	approved	1fd6e737-0c6b-49b7-841e-0f8a73d3c1a1	\N	64e73594-8c02-4413-9f72-959321b1f4ff	2026-07-20 09:59:26.363877+00	2026-07-20 09:59:26.363877+00
a03a787d-b998-4a31-aa2e-2aef31ab5784	f6d6b8a6-8e40-4682-8264-eb40174b9ac2	e5ed62a2-bd4a-46d5-a6c6-be866906977f	تست و اطمینان از عملکرد صحیح	90	31	2026-06-24	approved	1fd6e737-0c6b-49b7-841e-0f8a73d3c1a1	\N	4548b611-c166-4ae8-affb-113a5c824f52	2026-07-20 09:59:26.363877+00	2026-07-20 09:59:26.363877+00
a03a787d-b998-4a31-aa2e-2aef31ab5784	f6d6b8a6-8e40-4682-8264-eb40174b9ac2	e5ed62a2-bd4a-46d5-a6c6-be866906977f	رفع اشکالات و بازبینی	169	80	2026-06-25	approved	1fd6e737-0c6b-49b7-841e-0f8a73d3c1a1	\N	bc96c900-fdea-47b1-bbdc-6b91df1e59d7	2026-07-20 09:59:26.363877+00	2026-07-20 09:59:26.363877+00
a03a787d-b998-4a31-aa2e-2aef31ab5784	84840f44-607d-4502-baa7-69c7658ff81e	be1819a8-75ce-4c92-8f50-3b2a8aa29e30	تست و اطمینان از عملکرد صحیح	100	26	2026-07-16	approved	1fd6e737-0c6b-49b7-841e-0f8a73d3c1a1	\N	95e9c588-53e6-46b0-9afc-8e9eb0088f64	2026-07-20 09:59:26.363877+00	2026-07-20 09:59:26.363877+00
a03a787d-b998-4a31-aa2e-2aef31ab5784	84840f44-607d-4502-baa7-69c7658ff81e	be1819a8-75ce-4c92-8f50-3b2a8aa29e30	تست و اطمینان از عملکرد صحیح	53	52	2026-07-16	approved	1fd6e737-0c6b-49b7-841e-0f8a73d3c1a1	\N	f1833f6c-b400-4913-9839-1ca232e17e59	2026-07-20 09:59:26.363877+00	2026-07-20 09:59:26.363877+00
a03a787d-b998-4a31-aa2e-2aef31ab5784	84840f44-607d-4502-baa7-69c7658ff81e	be1819a8-75ce-4c92-8f50-3b2a8aa29e30	پیشرفت اولیه و بررسی نیازمندی‌ها	231	90	2026-07-16	approved	1fd6e737-0c6b-49b7-841e-0f8a73d3c1a1	\N	a28eb866-8367-4022-acbc-636bff3064b1	2026-07-20 09:59:26.363877+00	2026-07-20 09:59:26.363877+00
a03a787d-b998-4a31-aa2e-2aef31ab5784	609cbb9b-b292-4178-8733-ccd3049a001f	be1819a8-75ce-4c92-8f50-3b2a8aa29e30	پیاده‌سازی بخش اصلی	47	37	2026-07-16	submitted	\N	\N	427575b4-22fc-407d-809f-6339a5f3903f	2026-07-20 09:59:26.363877+00	2026-07-20 09:59:26.363877+00
a03a787d-b998-4a31-aa2e-2aef31ab5784	609cbb9b-b292-4178-8733-ccd3049a001f	be1819a8-75ce-4c92-8f50-3b2a8aa29e30	پیاده‌سازی بخش اصلی	114	48	2026-07-16	approved	1fd6e737-0c6b-49b7-841e-0f8a73d3c1a1	\N	dfb00bc9-8ce5-4491-a418-db13aa3d3b73	2026-07-20 09:59:26.363877+00	2026-07-20 09:59:26.363877+00
a03a787d-b998-4a31-aa2e-2aef31ab5784	722e851f-2776-4099-a800-29ded0c5919d	1fd6e737-0c6b-49b7-841e-0f8a73d3c1a1	پیاده‌سازی بخش اصلی	63	37	2026-07-16	approved	1fd6e737-0c6b-49b7-841e-0f8a73d3c1a1	\N	36219db8-6b7b-4a7d-b59d-39a832d53da9	2026-07-20 09:59:26.363877+00	2026-07-20 09:59:26.363877+00
a03a787d-b998-4a31-aa2e-2aef31ab5784	43dbd99d-4e5d-4d5f-bfc6-9b4e00abf127	b0bcd30d-df04-4c14-bdf8-7923f39ea52e	پیشرفت اولیه و بررسی نیازمندی‌ها	63	20	2026-06-30	approved	1fd6e737-0c6b-49b7-841e-0f8a73d3c1a1	\N	b6806665-3d8a-4886-80e0-57f7fb49fef0	2026-07-20 09:59:26.363877+00	2026-07-20 09:59:26.363877+00
a03a787d-b998-4a31-aa2e-2aef31ab5784	43dbd99d-4e5d-4d5f-bfc6-9b4e00abf127	b0bcd30d-df04-4c14-bdf8-7923f39ea52e	پیاده‌سازی بخش اصلی	180	60	2026-07-03	submitted	\N	\N	5b0e8631-f165-4bdf-909d-c09598113246	2026-07-20 09:59:26.363877+00	2026-07-20 09:59:26.363877+00
a03a787d-b998-4a31-aa2e-2aef31ab5784	43dbd99d-4e5d-4d5f-bfc6-9b4e00abf127	b0bcd30d-df04-4c14-bdf8-7923f39ea52e	پیشرفت اولیه و بررسی نیازمندی‌ها	62	99	2026-07-02	approved	1fd6e737-0c6b-49b7-841e-0f8a73d3c1a1	\N	d90de871-04aa-44fb-92ad-54ac23de6aed	2026-07-20 09:59:26.363877+00	2026-07-20 09:59:26.363877+00
a03a787d-b998-4a31-aa2e-2aef31ab5784	8d373e65-993e-408b-8a7b-2bd3cad0d385	b0bcd30d-df04-4c14-bdf8-7923f39ea52e	تست و اطمینان از عملکرد صحیح	144	31	2026-06-17	approved	1fd6e737-0c6b-49b7-841e-0f8a73d3c1a1	\N	b0054b6b-c208-4f40-9ff8-cbaace0778fc	2026-07-20 09:59:26.363877+00	2026-07-20 09:59:26.363877+00
a03a787d-b998-4a31-aa2e-2aef31ab5784	5d6d0e43-7efb-4f75-804a-0aba64b898cb	1fd6e737-0c6b-49b7-841e-0f8a73d3c1a1	مستندسازی و نهایی‌سازی	86	39	2026-07-16	approved	1fd6e737-0c6b-49b7-841e-0f8a73d3c1a1	\N	ae446a59-fcff-4cb1-89bd-29eae0680f08	2026-07-20 09:59:26.363877+00	2026-07-20 09:59:26.363877+00
a03a787d-b998-4a31-aa2e-2aef31ab5784	2353ba14-d382-4b4d-a23c-68af86c4459a	d6fc165d-7448-431b-af51-26d9bb7751a1	پیشرفت اولیه و بررسی نیازمندی‌ها	45	35	2026-07-16	approved	1fd6e737-0c6b-49b7-841e-0f8a73d3c1a1	\N	1fbcd1b7-1871-4b91-ac88-32110edfdf7b	2026-07-20 09:59:26.363877+00	2026-07-20 09:59:26.363877+00
a03a787d-b998-4a31-aa2e-2aef31ab5784	9a62d619-23e7-4326-b107-567ae9ae1c2b	d6fc165d-7448-431b-af51-26d9bb7751a1	تست و اطمینان از عملکرد صحیح	212	34	2026-07-06	approved	1fd6e737-0c6b-49b7-841e-0f8a73d3c1a1	\N	ab096931-dac8-444b-a01b-2d293a08792d	2026-07-20 09:59:26.363877+00	2026-07-20 09:59:26.363877+00
a03a787d-b998-4a31-aa2e-2aef31ab5784	9a62d619-23e7-4326-b107-567ae9ae1c2b	d6fc165d-7448-431b-af51-26d9bb7751a1	رفع اشکالات و بازبینی	185	48	2026-07-07	submitted	\N	\N	8144a84f-2a26-43d2-881d-1784842b4c73	2026-07-20 09:59:26.363877+00	2026-07-20 09:59:26.363877+00
a03a787d-b998-4a31-aa2e-2aef31ab5784	9a62d619-23e7-4326-b107-567ae9ae1c2b	d6fc165d-7448-431b-af51-26d9bb7751a1	مستندسازی و نهایی‌سازی	192	100	2026-07-08	approved	1fd6e737-0c6b-49b7-841e-0f8a73d3c1a1	\N	6bc31616-1481-4613-b607-a5e9b0cf1935	2026-07-20 09:59:26.363877+00	2026-07-20 09:59:26.363877+00
a03a787d-b998-4a31-aa2e-2aef31ab5784	9a62d619-23e7-4326-b107-567ae9ae1c2b	d6fc165d-7448-431b-af51-26d9bb7751a1	مستندسازی و نهایی‌سازی	165	100	2026-07-15	approved	1fd6e737-0c6b-49b7-841e-0f8a73d3c1a1	\N	6a3474ac-ceb9-41fd-b310-59d7a456cb29	2026-07-20 09:59:26.363877+00	2026-07-20 09:59:26.363877+00
a03a787d-b998-4a31-aa2e-2aef31ab5784	351cd82f-becf-4ac7-bd78-ea205404125f	07e1c1ad-90c2-4b01-80d6-88ad81b6cc78	پیشرفت اولیه و بررسی نیازمندی‌ها	233	23	2026-07-16	approved	1fd6e737-0c6b-49b7-841e-0f8a73d3c1a1	\N	4c03d503-5585-4d60-bd18-1358718fcec4	2026-07-20 09:59:26.363877+00	2026-07-20 09:59:26.363877+00
a03a787d-b998-4a31-aa2e-2aef31ab5784	351cd82f-becf-4ac7-bd78-ea205404125f	07e1c1ad-90c2-4b01-80d6-88ad81b6cc78	تست و اطمینان از عملکرد صحیح	145	54	2026-07-16	approved	1fd6e737-0c6b-49b7-841e-0f8a73d3c1a1	\N	344436ee-dd37-4646-8eec-5e0dad121411	2026-07-20 09:59:26.363877+00	2026-07-20 09:59:26.363877+00
a03a787d-b998-4a31-aa2e-2aef31ab5784	351cd82f-becf-4ac7-bd78-ea205404125f	07e1c1ad-90c2-4b01-80d6-88ad81b6cc78	رفع اشکالات و بازبینی	146	96	2026-07-16	approved	1fd6e737-0c6b-49b7-841e-0f8a73d3c1a1	\N	31f9f269-b0a7-4f6e-8ddc-f32fe144affc	2026-07-20 09:59:26.363877+00	2026-07-20 09:59:26.363877+00
a03a787d-b998-4a31-aa2e-2aef31ab5784	351cd82f-becf-4ac7-bd78-ea205404125f	07e1c1ad-90c2-4b01-80d6-88ad81b6cc78	پیشرفت اولیه و بررسی نیازمندی‌ها	110	100	2026-07-16	approved	1fd6e737-0c6b-49b7-841e-0f8a73d3c1a1	\N	e9b8b17f-e9ee-4bae-9998-b29f1d433a43	2026-07-20 09:59:26.363877+00	2026-07-20 09:59:26.363877+00
a03a787d-b998-4a31-aa2e-2aef31ab5784	3114e03e-fff8-4152-bd48-85d1632874a0	be1819a8-75ce-4c92-8f50-3b2a8aa29e30	رفع اشکالات و بازبینی	69	35	2026-07-16	approved	1fd6e737-0c6b-49b7-841e-0f8a73d3c1a1	\N	bd23752b-54a2-466f-826f-26fb048337e1	2026-07-20 09:59:26.363877+00	2026-07-20 09:59:26.363877+00
a03a787d-b998-4a31-aa2e-2aef31ab5784	3114e03e-fff8-4152-bd48-85d1632874a0	be1819a8-75ce-4c92-8f50-3b2a8aa29e30	پیشرفت اولیه و بررسی نیازمندی‌ها	51	44	2026-07-16	approved	1fd6e737-0c6b-49b7-841e-0f8a73d3c1a1	\N	ac7e7e7e-ac55-4232-95a9-c05a13543d4a	2026-07-20 09:59:26.363877+00	2026-07-20 09:59:26.363877+00
a03a787d-b998-4a31-aa2e-2aef31ab5784	3114e03e-fff8-4152-bd48-85d1632874a0	be1819a8-75ce-4c92-8f50-3b2a8aa29e30	پیشرفت اولیه و بررسی نیازمندی‌ها	220	93	2026-07-16	approved	1fd6e737-0c6b-49b7-841e-0f8a73d3c1a1	\N	5898f7f3-bca0-4bb6-8f9f-915eb6d0fe75	2026-07-20 09:59:26.363877+00	2026-07-20 09:59:26.363877+00
a03a787d-b998-4a31-aa2e-2aef31ab5784	c69c8b1d-d6a0-444d-aa9c-7a15ec0cc41d	b0bcd30d-df04-4c14-bdf8-7923f39ea52e	مستندسازی و نهایی‌سازی	173	37	2026-06-26	approved	1fd6e737-0c6b-49b7-841e-0f8a73d3c1a1	\N	7fc54953-9b97-4520-ad4d-bde158e17727	2026-07-20 09:59:26.363877+00	2026-07-20 09:59:26.363877+00
a03a787d-b998-4a31-aa2e-2aef31ab5784	c69c8b1d-d6a0-444d-aa9c-7a15ec0cc41d	b0bcd30d-df04-4c14-bdf8-7923f39ea52e	پیشرفت اولیه و بررسی نیازمندی‌ها	135	62	2026-06-29	approved	1fd6e737-0c6b-49b7-841e-0f8a73d3c1a1	\N	354fde05-7f38-4ce0-85c8-a7a03721bc4a	2026-07-20 09:59:26.363877+00	2026-07-20 09:59:26.363877+00
a03a787d-b998-4a31-aa2e-2aef31ab5784	f5c3f2ec-51e7-4cb8-9ef4-df16245cef4f	b0bcd30d-df04-4c14-bdf8-7923f39ea52e	رفع اشکالات و بازبینی	183	29	2026-07-01	approved	1fd6e737-0c6b-49b7-841e-0f8a73d3c1a1	\N	3917c860-00e7-454d-b3b0-178ae9ed9413	2026-07-20 09:59:26.363877+00	2026-07-20 09:59:26.363877+00
a03a787d-b998-4a31-aa2e-2aef31ab5784	f5c3f2ec-51e7-4cb8-9ef4-df16245cef4f	b0bcd30d-df04-4c14-bdf8-7923f39ea52e	پیشرفت اولیه و بررسی نیازمندی‌ها	177	72	2026-07-04	approved	1fd6e737-0c6b-49b7-841e-0f8a73d3c1a1	\N	651b7ca1-cab1-4608-bff5-9adc64c7fa2e	2026-07-20 09:59:26.363877+00	2026-07-20 09:59:26.363877+00
a03a787d-b998-4a31-aa2e-2aef31ab5784	f5c3f2ec-51e7-4cb8-9ef4-df16245cef4f	b0bcd30d-df04-4c14-bdf8-7923f39ea52e	پیاده‌سازی بخش اصلی	198	100	2026-07-05	approved	1fd6e737-0c6b-49b7-841e-0f8a73d3c1a1	\N	78a6614c-afed-4f01-98f9-7edb380388e3	2026-07-20 09:59:26.363877+00	2026-07-20 09:59:26.363877+00
a03a787d-b998-4a31-aa2e-2aef31ab5784	f5c3f2ec-51e7-4cb8-9ef4-df16245cef4f	b0bcd30d-df04-4c14-bdf8-7923f39ea52e	پیشرفت اولیه و بررسی نیازمندی‌ها	119	100	2026-07-07	approved	1fd6e737-0c6b-49b7-841e-0f8a73d3c1a1	\N	6d48d81f-071d-472b-bac0-406c89f853c6	2026-07-20 09:59:26.363877+00	2026-07-20 09:59:26.363877+00
a03a787d-b998-4a31-aa2e-2aef31ab5784	f83137e7-89c2-4664-9c5b-fdb49a18878e	842034d4-0d08-46e1-bdd9-05eec45bcffa	رفع اشکالات و بازبینی	176	27	2026-07-16	approved	1fd6e737-0c6b-49b7-841e-0f8a73d3c1a1	\N	bc5dd25b-9a1d-417a-8b38-1037f22b7d8e	2026-07-20 09:59:26.363877+00	2026-07-20 09:59:26.363877+00
a03a787d-b998-4a31-aa2e-2aef31ab5784	f83137e7-89c2-4664-9c5b-fdb49a18878e	842034d4-0d08-46e1-bdd9-05eec45bcffa	مستندسازی و نهایی‌سازی	226	78	2026-07-16	approved	1fd6e737-0c6b-49b7-841e-0f8a73d3c1a1	\N	d79d1dcc-bf75-450d-ab9f-306daa69edd1	2026-07-20 09:59:26.363877+00	2026-07-20 09:59:26.363877+00
a03a787d-b998-4a31-aa2e-2aef31ab5784	f83137e7-89c2-4664-9c5b-fdb49a18878e	842034d4-0d08-46e1-bdd9-05eec45bcffa	مستندسازی و نهایی‌سازی	198	84	2026-07-16	approved	1fd6e737-0c6b-49b7-841e-0f8a73d3c1a1	\N	72b65342-63ba-44d1-a5ff-8ab98753c36d	2026-07-20 09:59:26.363877+00	2026-07-20 09:59:26.363877+00
a03a787d-b998-4a31-aa2e-2aef31ab5784	cdb3c7a8-a9f7-4aa4-9c83-805a53057c28	d6fc165d-7448-431b-af51-26d9bb7751a1	رفع اشکالات و بازبینی	209	29	2026-07-16	approved	1fd6e737-0c6b-49b7-841e-0f8a73d3c1a1	\N	dc9a487a-e89c-4d64-9026-e1cb40b1470f	2026-07-20 09:59:26.363877+00	2026-07-20 09:59:26.363877+00
a03a787d-b998-4a31-aa2e-2aef31ab5784	fd7a65c2-67c3-4d58-b9fb-0ffe072833db	b0bcd30d-df04-4c14-bdf8-7923f39ea52e	پیشرفت اولیه و بررسی نیازمندی‌ها	76	24	2026-07-16	approved	1fd6e737-0c6b-49b7-841e-0f8a73d3c1a1	\N	2ae3d818-cfd5-4725-abdc-09da7f587b35	2026-07-20 09:59:26.363877+00	2026-07-20 09:59:26.363877+00
a03a787d-b998-4a31-aa2e-2aef31ab5784	fd7a65c2-67c3-4d58-b9fb-0ffe072833db	b0bcd30d-df04-4c14-bdf8-7923f39ea52e	پیشرفت اولیه و بررسی نیازمندی‌ها	66	80	2026-07-16	approved	1fd6e737-0c6b-49b7-841e-0f8a73d3c1a1	\N	27966d12-b9c8-45e5-a5a9-f8dd7a13212c	2026-07-20 09:59:26.363877+00	2026-07-20 09:59:26.363877+00
a03a787d-b998-4a31-aa2e-2aef31ab5784	fd7a65c2-67c3-4d58-b9fb-0ffe072833db	b0bcd30d-df04-4c14-bdf8-7923f39ea52e	پیشرفت اولیه و بررسی نیازمندی‌ها	221	100	2026-07-16	approved	1fd6e737-0c6b-49b7-841e-0f8a73d3c1a1	\N	11b642f9-8211-4ee0-af76-3e4968e34966	2026-07-20 09:59:26.363877+00	2026-07-20 09:59:26.363877+00
a03a787d-b998-4a31-aa2e-2aef31ab5784	5eb3e021-9714-41ef-a9d9-6a111319dae8	d6fc165d-7448-431b-af51-26d9bb7751a1	تست و اطمینان از عملکرد صحیح	146	30	2026-07-16	approved	1fd6e737-0c6b-49b7-841e-0f8a73d3c1a1	\N	77ce414a-42f1-4fd3-ac6f-6c8ce5ae31b4	2026-07-20 09:59:26.363877+00	2026-07-20 09:59:26.363877+00
a03a787d-b998-4a31-aa2e-2aef31ab5784	5eb3e021-9714-41ef-a9d9-6a111319dae8	d6fc165d-7448-431b-af51-26d9bb7751a1	رفع اشکالات و بازبینی	109	60	2026-07-16	approved	1fd6e737-0c6b-49b7-841e-0f8a73d3c1a1	\N	f38e8f00-7d28-4b14-91b3-c0231966f9ce	2026-07-20 09:59:26.363877+00	2026-07-20 09:59:26.363877+00
a03a787d-b998-4a31-aa2e-2aef31ab5784	52a42842-639d-4b69-9539-b4030a1bc726	07e1c1ad-90c2-4b01-80d6-88ad81b6cc78	پیاده‌سازی بخش اصلی	70	39	2026-07-01	approved	1fd6e737-0c6b-49b7-841e-0f8a73d3c1a1	\N	de21b5c2-1cd9-4bd0-b11d-2123d1ddf71d	2026-07-20 09:59:26.363877+00	2026-07-20 09:59:26.363877+00
a03a787d-b998-4a31-aa2e-2aef31ab5784	75ea9a0f-bd48-4906-b07f-920209284136	842034d4-0d08-46e1-bdd9-05eec45bcffa	تست و اطمینان از عملکرد صحیح	154	39	2026-07-14	approved	1fd6e737-0c6b-49b7-841e-0f8a73d3c1a1	\N	93b6cfc6-347a-427d-9edf-cbb343b72134	2026-07-20 09:59:26.363877+00	2026-07-20 09:59:26.363877+00
a03a787d-b998-4a31-aa2e-2aef31ab5784	db319da9-c71b-4eb7-9e1d-827fb03d6b03	be1819a8-75ce-4c92-8f50-3b2a8aa29e30	رفع اشکالات و بازبینی	85	36	2026-06-25	approved	1fd6e737-0c6b-49b7-841e-0f8a73d3c1a1	\N	a127b563-82d9-4725-a21d-4e64ede13c62	2026-07-20 09:59:26.363877+00	2026-07-20 09:59:26.363877+00
a03a787d-b998-4a31-aa2e-2aef31ab5784	db319da9-c71b-4eb7-9e1d-827fb03d6b03	be1819a8-75ce-4c92-8f50-3b2a8aa29e30	رفع اشکالات و بازبینی	140	46	2026-06-26	approved	1fd6e737-0c6b-49b7-841e-0f8a73d3c1a1	\N	9baaae71-f8ab-4777-99b0-0fd1d7204e9a	2026-07-20 09:59:26.363877+00	2026-07-20 09:59:26.363877+00
a03a787d-b998-4a31-aa2e-2aef31ab5784	db319da9-c71b-4eb7-9e1d-827fb03d6b03	be1819a8-75ce-4c92-8f50-3b2a8aa29e30	مستندسازی و نهایی‌سازی	154	100	2026-07-01	approved	1fd6e737-0c6b-49b7-841e-0f8a73d3c1a1	\N	8c2797dd-e0c5-4906-a76f-a7baa92fc6f0	2026-07-20 09:59:26.363877+00	2026-07-20 09:59:26.363877+00
a03a787d-b998-4a31-aa2e-2aef31ab5784	db319da9-c71b-4eb7-9e1d-827fb03d6b03	be1819a8-75ce-4c92-8f50-3b2a8aa29e30	پیشرفت اولیه و بررسی نیازمندی‌ها	86	100	2026-07-04	approved	1fd6e737-0c6b-49b7-841e-0f8a73d3c1a1	\N	404d427f-c501-4750-9b78-a7b1f5bb46a0	2026-07-20 09:59:26.363877+00	2026-07-20 09:59:26.363877+00
a03a787d-b998-4a31-aa2e-2aef31ab5784	05e71afe-0a12-437e-920e-b75510637d85	842034d4-0d08-46e1-bdd9-05eec45bcffa	پیاده‌سازی بخش اصلی	226	24	2026-07-10	approved	1fd6e737-0c6b-49b7-841e-0f8a73d3c1a1	\N	c3f048a4-e571-4b55-acd5-24be4bc6cf55	2026-07-20 09:59:26.363877+00	2026-07-20 09:59:26.363877+00
a03a787d-b998-4a31-aa2e-2aef31ab5784	b93cbd6a-bcd3-4276-b8e8-e79257e29b60	1fd6e737-0c6b-49b7-841e-0f8a73d3c1a1	پیشرفت اولیه و بررسی نیازمندی‌ها	157	33	2026-07-05	approved	1fd6e737-0c6b-49b7-841e-0f8a73d3c1a1	\N	13d63f4e-acd4-4f18-b5c9-a5b645f44fa9	2026-07-20 09:59:26.363877+00	2026-07-20 09:59:26.363877+00
a03a787d-b998-4a31-aa2e-2aef31ab5784	b93cbd6a-bcd3-4276-b8e8-e79257e29b60	1fd6e737-0c6b-49b7-841e-0f8a73d3c1a1	مستندسازی و نهایی‌سازی	210	54	2026-07-07	approved	1fd6e737-0c6b-49b7-841e-0f8a73d3c1a1	\N	07309c38-5452-416a-929f-280bd8e84657	2026-07-20 09:59:26.363877+00	2026-07-20 09:59:26.363877+00
a03a787d-b998-4a31-aa2e-2aef31ab5784	b93cbd6a-bcd3-4276-b8e8-e79257e29b60	1fd6e737-0c6b-49b7-841e-0f8a73d3c1a1	پیشرفت اولیه و بررسی نیازمندی‌ها	141	60	2026-07-11	approved	1fd6e737-0c6b-49b7-841e-0f8a73d3c1a1	\N	474f238c-74ef-4943-8ebe-de60d5b17cab	2026-07-20 09:59:26.363877+00	2026-07-20 09:59:26.363877+00
a03a787d-b998-4a31-aa2e-2aef31ab5784	b9811892-86ef-45c2-bff9-a609e0d89088	e5ed62a2-bd4a-46d5-a6c6-be866906977f	رفع اشکالات و بازبینی	177	33	2026-07-16	approved	1fd6e737-0c6b-49b7-841e-0f8a73d3c1a1	\N	39e87322-ce56-4614-a5e5-9138235f91af	2026-07-20 09:59:26.363877+00	2026-07-20 09:59:26.363877+00
a03a787d-b998-4a31-aa2e-2aef31ab5784	b9811892-86ef-45c2-bff9-a609e0d89088	e5ed62a2-bd4a-46d5-a6c6-be866906977f	تست و اطمینان از عملکرد صحیح	104	46	2026-07-16	approved	1fd6e737-0c6b-49b7-841e-0f8a73d3c1a1	\N	3455b8c3-1b91-4319-b04c-864962f68b92	2026-07-20 09:59:26.363877+00	2026-07-20 09:59:26.363877+00
a03a787d-b998-4a31-aa2e-2aef31ab5784	b9811892-86ef-45c2-bff9-a609e0d89088	e5ed62a2-bd4a-46d5-a6c6-be866906977f	پیشرفت اولیه و بررسی نیازمندی‌ها	113	75	2026-07-16	approved	1fd6e737-0c6b-49b7-841e-0f8a73d3c1a1	\N	581ae760-312d-49de-9118-7d20962a58fe	2026-07-20 09:59:26.363877+00	2026-07-20 09:59:26.363877+00
a03a787d-b998-4a31-aa2e-2aef31ab5784	b9811892-86ef-45c2-bff9-a609e0d89088	e5ed62a2-bd4a-46d5-a6c6-be866906977f	رفع اشکالات و بازبینی	52	100	2026-07-16	approved	1fd6e737-0c6b-49b7-841e-0f8a73d3c1a1	\N	55570d6d-8416-4cc4-8a55-e86f4fe5bbc8	2026-07-20 09:59:26.363877+00	2026-07-20 09:59:26.363877+00
a03a787d-b998-4a31-aa2e-2aef31ab5784	55c55bbe-a242-42ba-b449-cebde5c9ffa3	07e1c1ad-90c2-4b01-80d6-88ad81b6cc78	تست و اطمینان از عملکرد صحیح	164	22	2026-07-16	approved	1fd6e737-0c6b-49b7-841e-0f8a73d3c1a1	\N	bd9f63dc-8c9c-43ed-b668-6be6049f8a0e	2026-07-20 09:59:26.363877+00	2026-07-20 09:59:26.363877+00
a03a787d-b998-4a31-aa2e-2aef31ab5784	e99b1583-ece2-4431-ab93-c54f66e2be43	e5ed62a2-bd4a-46d5-a6c6-be866906977f	رفع اشکالات و بازبینی	86	30	2026-07-11	approved	1fd6e737-0c6b-49b7-841e-0f8a73d3c1a1	\N	79e0d334-624f-491b-8617-3710a93ba898	2026-07-20 09:59:26.363877+00	2026-07-20 09:59:26.363877+00
a03a787d-b998-4a31-aa2e-2aef31ab5784	e99b1583-ece2-4431-ab93-c54f66e2be43	e5ed62a2-bd4a-46d5-a6c6-be866906977f	پیشرفت اولیه و بررسی نیازمندی‌ها	160	80	2026-07-13	approved	1fd6e737-0c6b-49b7-841e-0f8a73d3c1a1	\N	eafb805a-848c-4e04-ab08-1149165f9d18	2026-07-20 09:59:26.363877+00	2026-07-20 09:59:26.363877+00
a03a787d-b998-4a31-aa2e-2aef31ab5784	e99b1583-ece2-4431-ab93-c54f66e2be43	e5ed62a2-bd4a-46d5-a6c6-be866906977f	مستندسازی و نهایی‌سازی	160	78	2026-07-13	approved	1fd6e737-0c6b-49b7-841e-0f8a73d3c1a1	\N	9c9a935c-c281-476f-aba8-0566d64eb073	2026-07-20 09:59:26.363877+00	2026-07-20 09:59:26.363877+00
a03a787d-b998-4a31-aa2e-2aef31ab5784	e99b1583-ece2-4431-ab93-c54f66e2be43	e5ed62a2-bd4a-46d5-a6c6-be866906977f	رفع اشکالات و بازبینی	216	100	2026-07-16	approved	1fd6e737-0c6b-49b7-841e-0f8a73d3c1a1	\N	576bd1e5-75fa-4a36-a515-516796d1411e	2026-07-20 09:59:26.363877+00	2026-07-20 09:59:26.363877+00
a03a787d-b998-4a31-aa2e-2aef31ab5784	ccaf9c44-5dc4-4fb1-9123-8ee71dfa8370	d6fc165d-7448-431b-af51-26d9bb7751a1	رفع اشکالات و بازبینی	80	25	2026-06-24	approved	1fd6e737-0c6b-49b7-841e-0f8a73d3c1a1	\N	dfc46b7d-9275-499c-9ea7-1ba1d375d56a	2026-07-20 09:59:26.363877+00	2026-07-20 09:59:26.363877+00
a03a787d-b998-4a31-aa2e-2aef31ab5784	ccaf9c44-5dc4-4fb1-9123-8ee71dfa8370	d6fc165d-7448-431b-af51-26d9bb7751a1	پیشرفت اولیه و بررسی نیازمندی‌ها	75	80	2026-06-26	submitted	\N	\N	0d9785c7-7166-4be0-926e-7c7076e9465d	2026-07-20 09:59:26.363877+00	2026-07-20 09:59:26.363877+00
a03a787d-b998-4a31-aa2e-2aef31ab5784	c6d604bf-aa8f-4b04-869a-f98da13c49c1	842034d4-0d08-46e1-bdd9-05eec45bcffa	مستندسازی و نهایی‌سازی	224	38	2026-07-16	approved	1fd6e737-0c6b-49b7-841e-0f8a73d3c1a1	\N	589fa9ce-d84d-44b5-831f-454a9cbb287a	2026-07-20 09:59:26.363877+00	2026-07-20 09:59:26.363877+00
a03a787d-b998-4a31-aa2e-2aef31ab5784	c6d604bf-aa8f-4b04-869a-f98da13c49c1	842034d4-0d08-46e1-bdd9-05eec45bcffa	مستندسازی و نهایی‌سازی	194	80	2026-07-16	approved	1fd6e737-0c6b-49b7-841e-0f8a73d3c1a1	\N	bc14180d-baf4-4c32-a4d3-5921f3a6cba1	2026-07-20 09:59:26.363877+00	2026-07-20 09:59:26.363877+00
a03a787d-b998-4a31-aa2e-2aef31ab5784	c6d604bf-aa8f-4b04-869a-f98da13c49c1	842034d4-0d08-46e1-bdd9-05eec45bcffa	رفع اشکالات و بازبینی	68	100	2026-07-16	approved	1fd6e737-0c6b-49b7-841e-0f8a73d3c1a1	\N	48b56fd7-9da6-4466-819c-535d96ad8d78	2026-07-20 09:59:26.363877+00	2026-07-20 09:59:26.363877+00
a03a787d-b998-4a31-aa2e-2aef31ab5784	c6d604bf-aa8f-4b04-869a-f98da13c49c1	842034d4-0d08-46e1-bdd9-05eec45bcffa	تست و اطمینان از عملکرد صحیح	143	100	2026-07-16	approved	1fd6e737-0c6b-49b7-841e-0f8a73d3c1a1	\N	5d68a742-f51f-4c6c-82a2-10f2f6803b09	2026-07-20 09:59:26.363877+00	2026-07-20 09:59:26.363877+00
a03a787d-b998-4a31-aa2e-2aef31ab5784	cb748164-2ac5-48a0-ac86-0c9e1d4dec1e	1fd6e737-0c6b-49b7-841e-0f8a73d3c1a1	مستندسازی و نهایی‌سازی	44	31	2026-07-16	approved	1fd6e737-0c6b-49b7-841e-0f8a73d3c1a1	\N	169655b8-bdb0-47ac-87f0-5d27b5b67dc0	2026-07-20 09:59:26.363877+00	2026-07-20 09:59:26.363877+00
a03a787d-b998-4a31-aa2e-2aef31ab5784	cb748164-2ac5-48a0-ac86-0c9e1d4dec1e	1fd6e737-0c6b-49b7-841e-0f8a73d3c1a1	رفع اشکالات و بازبینی	148	68	2026-07-16	approved	1fd6e737-0c6b-49b7-841e-0f8a73d3c1a1	\N	3ba0d1ab-fc11-4d15-963d-0d8f8510891b	2026-07-20 09:59:26.363877+00	2026-07-20 09:59:26.363877+00
a03a787d-b998-4a31-aa2e-2aef31ab5784	cb748164-2ac5-48a0-ac86-0c9e1d4dec1e	1fd6e737-0c6b-49b7-841e-0f8a73d3c1a1	پیشرفت اولیه و بررسی نیازمندی‌ها	124	87	2026-07-16	approved	1fd6e737-0c6b-49b7-841e-0f8a73d3c1a1	\N	acc98335-7a6b-47a6-b068-10678ce8455b	2026-07-20 09:59:26.363877+00	2026-07-20 09:59:26.363877+00
a03a787d-b998-4a31-aa2e-2aef31ab5784	233a7d09-c27f-4e93-8418-c7e1dfbf7064	b0bcd30d-df04-4c14-bdf8-7923f39ea52e	مستندسازی و نهایی‌سازی	182	36	2026-06-17	approved	1fd6e737-0c6b-49b7-841e-0f8a73d3c1a1	\N	8c764569-1bae-4162-a6df-c220c4f1f7e6	2026-07-20 09:59:26.363877+00	2026-07-20 09:59:26.363877+00
a03a787d-b998-4a31-aa2e-2aef31ab5784	4c0ad30b-9a07-42db-aaf6-28048f910be0	b0bcd30d-df04-4c14-bdf8-7923f39ea52e	پیشرفت اولیه و بررسی نیازمندی‌ها	145	38	2026-06-26	approved	1fd6e737-0c6b-49b7-841e-0f8a73d3c1a1	\N	5dda43af-200f-4185-ab64-b540f1d60582	2026-07-20 09:59:26.363877+00	2026-07-20 09:59:26.363877+00
a03a787d-b998-4a31-aa2e-2aef31ab5784	4c0ad30b-9a07-42db-aaf6-28048f910be0	b0bcd30d-df04-4c14-bdf8-7923f39ea52e	تست و اطمینان از عملکرد صحیح	158	48	2026-06-28	approved	1fd6e737-0c6b-49b7-841e-0f8a73d3c1a1	\N	68145800-d42c-4154-968c-1f2c36957fec	2026-07-20 09:59:26.363877+00	2026-07-20 09:59:26.363877+00
a03a787d-b998-4a31-aa2e-2aef31ab5784	4c0ad30b-9a07-42db-aaf6-28048f910be0	b0bcd30d-df04-4c14-bdf8-7923f39ea52e	رفع اشکالات و بازبینی	212	66	2026-06-28	approved	1fd6e737-0c6b-49b7-841e-0f8a73d3c1a1	\N	1cb6ed7e-ea27-4fc9-97d1-5e5a89b491b6	2026-07-20 09:59:26.363877+00	2026-07-20 09:59:26.363877+00
a03a787d-b998-4a31-aa2e-2aef31ab5784	4c0ad30b-9a07-42db-aaf6-28048f910be0	b0bcd30d-df04-4c14-bdf8-7923f39ea52e	تست و اطمینان از عملکرد صحیح	142	100	2026-07-02	approved	1fd6e737-0c6b-49b7-841e-0f8a73d3c1a1	\N	d6aa7d99-ee93-40a4-b92a-f754ac82c70e	2026-07-20 09:59:26.363877+00	2026-07-20 09:59:26.363877+00
a03a787d-b998-4a31-aa2e-2aef31ab5784	ef9ffb06-d2bf-482b-9ac3-fbfdaf11e549	842034d4-0d08-46e1-bdd9-05eec45bcffa	رفع اشکالات و بازبینی	129	33	2026-06-22	approved	1fd6e737-0c6b-49b7-841e-0f8a73d3c1a1	\N	49870c99-15e9-49af-b119-ceadd73a6df8	2026-07-20 09:59:26.363877+00	2026-07-20 09:59:26.363877+00
a03a787d-b998-4a31-aa2e-2aef31ab5784	ef9ffb06-d2bf-482b-9ac3-fbfdaf11e549	842034d4-0d08-46e1-bdd9-05eec45bcffa	پیشرفت اولیه و بررسی نیازمندی‌ها	232	80	2026-06-25	approved	1fd6e737-0c6b-49b7-841e-0f8a73d3c1a1	\N	8c9842e8-c386-4f19-9c0b-5cffb4731e03	2026-07-20 09:59:26.363877+00	2026-07-20 09:59:26.363877+00
a03a787d-b998-4a31-aa2e-2aef31ab5784	2cbda324-97d1-47ad-9a44-c06f8a4c24b4	07e1c1ad-90c2-4b01-80d6-88ad81b6cc78	مستندسازی و نهایی‌سازی	203	32	2026-07-16	approved	1fd6e737-0c6b-49b7-841e-0f8a73d3c1a1	\N	c7bcb0ac-dcb8-4901-83ed-def6b0c66304	2026-07-20 09:59:26.363877+00	2026-07-20 09:59:26.363877+00
a03a787d-b998-4a31-aa2e-2aef31ab5784	2cbda324-97d1-47ad-9a44-c06f8a4c24b4	07e1c1ad-90c2-4b01-80d6-88ad81b6cc78	مستندسازی و نهایی‌سازی	68	60	2026-07-16	approved	1fd6e737-0c6b-49b7-841e-0f8a73d3c1a1	\N	4ab22a2d-8a00-4243-8f0c-4d6ced1bb513	2026-07-20 09:59:26.363877+00	2026-07-20 09:59:26.363877+00
a03a787d-b998-4a31-aa2e-2aef31ab5784	2cbda324-97d1-47ad-9a44-c06f8a4c24b4	07e1c1ad-90c2-4b01-80d6-88ad81b6cc78	پیاده‌سازی بخش اصلی	119	87	2026-07-16	approved	1fd6e737-0c6b-49b7-841e-0f8a73d3c1a1	\N	b0edfd32-7fe8-4bb6-b93f-a119fbadd2a8	2026-07-20 09:59:26.363877+00	2026-07-20 09:59:26.363877+00
a03a787d-b998-4a31-aa2e-2aef31ab5784	b01e6044-9092-46c7-8174-575249bf127f	d6fc165d-7448-431b-af51-26d9bb7751a1	مستندسازی و نهایی‌سازی	211	22	2026-07-05	approved	1fd6e737-0c6b-49b7-841e-0f8a73d3c1a1	\N	7b33e14f-3aff-4968-8cee-48e8e62b56ba	2026-07-20 09:59:26.363877+00	2026-07-20 09:59:26.363877+00
a03a787d-b998-4a31-aa2e-2aef31ab5784	b01e6044-9092-46c7-8174-575249bf127f	d6fc165d-7448-431b-af51-26d9bb7751a1	مستندسازی و نهایی‌سازی	126	80	2026-07-08	approved	1fd6e737-0c6b-49b7-841e-0f8a73d3c1a1	\N	be105541-aaa5-4b02-8d33-1f6fa9eee261	2026-07-20 09:59:26.363877+00	2026-07-20 09:59:26.363877+00
a03a787d-b998-4a31-aa2e-2aef31ab5784	b01e6044-9092-46c7-8174-575249bf127f	d6fc165d-7448-431b-af51-26d9bb7751a1	پیاده‌سازی بخش اصلی	201	100	2026-07-11	approved	1fd6e737-0c6b-49b7-841e-0f8a73d3c1a1	\N	b85eca6f-8d80-4363-b8d8-10101672ef06	2026-07-20 09:59:26.363877+00	2026-07-20 09:59:26.363877+00
a03a787d-b998-4a31-aa2e-2aef31ab5784	b01e6044-9092-46c7-8174-575249bf127f	d6fc165d-7448-431b-af51-26d9bb7751a1	تست و اطمینان از عملکرد صحیح	160	100	2026-07-08	approved	1fd6e737-0c6b-49b7-841e-0f8a73d3c1a1	\N	8f7a4fe6-b40c-465d-aeaa-fe7e645522bf	2026-07-20 09:59:26.363877+00	2026-07-20 09:59:26.363877+00
a03a787d-b998-4a31-aa2e-2aef31ab5784	930d59e6-67de-4363-87b1-572cc8087ee0	be1819a8-75ce-4c92-8f50-3b2a8aa29e30	رفع اشکالات و بازبینی	76	26	2026-07-09	approved	1fd6e737-0c6b-49b7-841e-0f8a73d3c1a1	\N	edcfefa3-131b-4174-8f5e-8da19a3b6cc9	2026-07-20 09:59:26.363877+00	2026-07-20 09:59:26.363877+00
a03a787d-b998-4a31-aa2e-2aef31ab5784	8c70a82f-8d0e-4667-80e8-93f1f8163041	b0bcd30d-df04-4c14-bdf8-7923f39ea52e	پیاده‌سازی بخش اصلی	69	22	2026-07-16	approved	1fd6e737-0c6b-49b7-841e-0f8a73d3c1a1	\N	41ae4992-ddc8-42a4-858f-fdc8fa69a1af	2026-07-20 09:59:26.363877+00	2026-07-20 09:59:26.363877+00
a03a787d-b998-4a31-aa2e-2aef31ab5784	8c70a82f-8d0e-4667-80e8-93f1f8163041	b0bcd30d-df04-4c14-bdf8-7923f39ea52e	پیشرفت اولیه و بررسی نیازمندی‌ها	159	74	2026-07-16	submitted	\N	\N	589c40ac-6fd9-48e9-aefd-85ca22c9de08	2026-07-20 09:59:26.363877+00	2026-07-20 09:59:26.363877+00
a03a787d-b998-4a31-aa2e-2aef31ab5784	8c70a82f-8d0e-4667-80e8-93f1f8163041	b0bcd30d-df04-4c14-bdf8-7923f39ea52e	مستندسازی و نهایی‌سازی	63	100	2026-07-16	approved	1fd6e737-0c6b-49b7-841e-0f8a73d3c1a1	\N	0ded574f-24cb-4994-9e63-c6c73c47f18f	2026-07-20 09:59:26.363877+00	2026-07-20 09:59:26.363877+00
a03a787d-b998-4a31-aa2e-2aef31ab5784	111f9e2c-bb31-41f6-884f-e3d573ea42f2	b0bcd30d-df04-4c14-bdf8-7923f39ea52e	پیاده‌سازی بخش اصلی	76	39	2026-07-13	approved	1fd6e737-0c6b-49b7-841e-0f8a73d3c1a1	\N	83d59708-78a2-4233-be25-04fc40f29bfb	2026-07-20 09:59:26.363877+00	2026-07-20 09:59:26.363877+00
a03a787d-b998-4a31-aa2e-2aef31ab5784	111f9e2c-bb31-41f6-884f-e3d573ea42f2	b0bcd30d-df04-4c14-bdf8-7923f39ea52e	تست و اطمینان از عملکرد صحیح	41	66	2026-07-15	approved	1fd6e737-0c6b-49b7-841e-0f8a73d3c1a1	\N	f6894178-d3f3-4118-b4c0-816d1888e519	2026-07-20 09:59:26.363877+00	2026-07-20 09:59:26.363877+00
a03a787d-b998-4a31-aa2e-2aef31ab5784	111f9e2c-bb31-41f6-884f-e3d573ea42f2	b0bcd30d-df04-4c14-bdf8-7923f39ea52e	پیاده‌سازی بخش اصلی	143	100	2026-07-16	approved	1fd6e737-0c6b-49b7-841e-0f8a73d3c1a1	\N	29999e6d-a0c4-41e1-805e-971cb9c17ab2	2026-07-20 09:59:26.363877+00	2026-07-20 09:59:26.363877+00
a03a787d-b998-4a31-aa2e-2aef31ab5784	111f9e2c-bb31-41f6-884f-e3d573ea42f2	b0bcd30d-df04-4c14-bdf8-7923f39ea52e	تست و اطمینان از عملکرد صحیح	89	100	2026-07-16	approved	1fd6e737-0c6b-49b7-841e-0f8a73d3c1a1	\N	68097cf1-7fcd-4074-ad2a-4518869e67c4	2026-07-20 09:59:26.363877+00	2026-07-20 09:59:26.363877+00
a03a787d-b998-4a31-aa2e-2aef31ab5784	852b6ed4-054e-4973-a30b-bf1659d3503d	be1819a8-75ce-4c92-8f50-3b2a8aa29e30	تست و اطمینان از عملکرد صحیح	79	31	2026-07-16	approved	1fd6e737-0c6b-49b7-841e-0f8a73d3c1a1	\N	d8f65676-9abf-4bdf-a07a-14a399c878f6	2026-07-20 09:59:26.363877+00	2026-07-20 09:59:26.363877+00
a03a787d-b998-4a31-aa2e-2aef31ab5784	852b6ed4-054e-4973-a30b-bf1659d3503d	be1819a8-75ce-4c92-8f50-3b2a8aa29e30	تست و اطمینان از عملکرد صحیح	226	58	2026-07-16	approved	1fd6e737-0c6b-49b7-841e-0f8a73d3c1a1	\N	3a03c8c4-7d0f-4bbb-b6b5-126651a2f78b	2026-07-20 09:59:26.363877+00	2026-07-20 09:59:26.363877+00
a03a787d-b998-4a31-aa2e-2aef31ab5784	3cded444-c1e3-496a-997c-f1a87716d408	e5ed62a2-bd4a-46d5-a6c6-be866906977f	پیاده‌سازی بخش اصلی	235	39	2026-07-06	submitted	\N	\N	5de60b4b-9afc-43d9-b481-2d31e608f8b7	2026-07-20 09:59:26.363877+00	2026-07-20 09:59:26.363877+00
a03a787d-b998-4a31-aa2e-2aef31ab5784	3cded444-c1e3-496a-997c-f1a87716d408	e5ed62a2-bd4a-46d5-a6c6-be866906977f	پیشرفت اولیه و بررسی نیازمندی‌ها	194	70	2026-07-08	submitted	\N	\N	9f90a583-42fa-4030-9c58-b9203430aeac	2026-07-20 09:59:26.363877+00	2026-07-20 09:59:26.363877+00
a03a787d-b998-4a31-aa2e-2aef31ab5784	3cded444-c1e3-496a-997c-f1a87716d408	e5ed62a2-bd4a-46d5-a6c6-be866906977f	پیشرفت اولیه و بررسی نیازمندی‌ها	212	100	2026-07-12	approved	1fd6e737-0c6b-49b7-841e-0f8a73d3c1a1	\N	1f8b1e68-b394-4356-941f-8a70a8444631	2026-07-20 09:59:26.363877+00	2026-07-20 09:59:26.363877+00
a03a787d-b998-4a31-aa2e-2aef31ab5784	3cded444-c1e3-496a-997c-f1a87716d408	e5ed62a2-bd4a-46d5-a6c6-be866906977f	پیاده‌سازی بخش اصلی	99	100	2026-07-09	approved	1fd6e737-0c6b-49b7-841e-0f8a73d3c1a1	\N	505f03d9-4b15-4b7c-8dbc-471d54d862b8	2026-07-20 09:59:26.363877+00	2026-07-20 09:59:26.363877+00
a03a787d-b998-4a31-aa2e-2aef31ab5784	ca2b6e45-b5a5-42bc-812c-36bb9b3f0fc3	842034d4-0d08-46e1-bdd9-05eec45bcffa	پیشرفت اولیه و بررسی نیازمندی‌ها	86	34	2026-07-15	approved	1fd6e737-0c6b-49b7-841e-0f8a73d3c1a1	\N	05269c7c-a5a9-4688-b1e5-8925af62812b	2026-07-20 09:59:26.363877+00	2026-07-20 09:59:26.363877+00
a03a787d-b998-4a31-aa2e-2aef31ab5784	ca2b6e45-b5a5-42bc-812c-36bb9b3f0fc3	842034d4-0d08-46e1-bdd9-05eec45bcffa	پیشرفت اولیه و بررسی نیازمندی‌ها	136	42	2026-07-16	approved	1fd6e737-0c6b-49b7-841e-0f8a73d3c1a1	\N	88c83616-9027-486a-ab9d-f957ffd8ce41	2026-07-20 09:59:26.363877+00	2026-07-20 09:59:26.363877+00
a03a787d-b998-4a31-aa2e-2aef31ab5784	c75b8a6d-92c8-40a7-830e-0727c10fc214	07e1c1ad-90c2-4b01-80d6-88ad81b6cc78	پیشرفت اولیه و بررسی نیازمندی‌ها	125	27	2026-06-27	approved	1fd6e737-0c6b-49b7-841e-0f8a73d3c1a1	\N	6b82e67c-b620-4fcb-8bac-23b4f38b2686	2026-07-20 09:59:26.363877+00	2026-07-20 09:59:26.363877+00
a03a787d-b998-4a31-aa2e-2aef31ab5784	c75b8a6d-92c8-40a7-830e-0727c10fc214	07e1c1ad-90c2-4b01-80d6-88ad81b6cc78	پیشرفت اولیه و بررسی نیازمندی‌ها	212	80	2026-06-28	approved	1fd6e737-0c6b-49b7-841e-0f8a73d3c1a1	\N	8616e516-1320-4722-a8ce-2b8ea6e7d663	2026-07-20 09:59:26.363877+00	2026-07-20 09:59:26.363877+00
a03a787d-b998-4a31-aa2e-2aef31ab5784	c75b8a6d-92c8-40a7-830e-0727c10fc214	07e1c1ad-90c2-4b01-80d6-88ad81b6cc78	پیاده‌سازی بخش اصلی	39	87	2026-07-03	submitted	\N	\N	3308c758-e234-4d42-8c14-2f330640a35f	2026-07-20 09:59:26.363877+00	2026-07-20 09:59:26.363877+00
a03a787d-b998-4a31-aa2e-2aef31ab5784	c75b8a6d-92c8-40a7-830e-0727c10fc214	07e1c1ad-90c2-4b01-80d6-88ad81b6cc78	پیاده‌سازی بخش اصلی	224	100	2026-07-09	approved	1fd6e737-0c6b-49b7-841e-0f8a73d3c1a1	\N	a6d4138e-046b-4b66-9ac3-bbc3e7c09811	2026-07-20 09:59:26.363877+00	2026-07-20 09:59:26.363877+00
a03a787d-b998-4a31-aa2e-2aef31ab5784	10a660a0-0531-4ef2-85ac-3687deefbb6d	e5ed62a2-bd4a-46d5-a6c6-be866906977f	پیشرفت اولیه و بررسی نیازمندی‌ها	34	28	2026-07-16	approved	1fd6e737-0c6b-49b7-841e-0f8a73d3c1a1	\N	71e223e7-89a4-413e-8305-3bba07b0c683	2026-07-20 09:59:26.363877+00	2026-07-20 09:59:26.363877+00
a03a787d-b998-4a31-aa2e-2aef31ab5784	10a660a0-0531-4ef2-85ac-3687deefbb6d	e5ed62a2-bd4a-46d5-a6c6-be866906977f	پیاده‌سازی بخش اصلی	170	78	2026-07-16	approved	1fd6e737-0c6b-49b7-841e-0f8a73d3c1a1	\N	e8beb154-fda0-4fb6-9919-50dde4737705	2026-07-20 09:59:26.363877+00	2026-07-20 09:59:26.363877+00
a03a787d-b998-4a31-aa2e-2aef31ab5784	10a660a0-0531-4ef2-85ac-3687deefbb6d	e5ed62a2-bd4a-46d5-a6c6-be866906977f	پیشرفت اولیه و بررسی نیازمندی‌ها	228	87	2026-07-16	approved	1fd6e737-0c6b-49b7-841e-0f8a73d3c1a1	\N	96ae24c5-1111-4777-a6cd-3db00c52f229	2026-07-20 09:59:26.363877+00	2026-07-20 09:59:26.363877+00
a03a787d-b998-4a31-aa2e-2aef31ab5784	10a660a0-0531-4ef2-85ac-3687deefbb6d	e5ed62a2-bd4a-46d5-a6c6-be866906977f	رفع اشکالات و بازبینی	61	84	2026-07-16	approved	1fd6e737-0c6b-49b7-841e-0f8a73d3c1a1	\N	d61f7743-595d-425c-bf39-21077b74f2b9	2026-07-20 09:59:26.363877+00	2026-07-20 09:59:26.363877+00
a03a787d-b998-4a31-aa2e-2aef31ab5784	09e0a150-abb0-42f9-8167-cfba30f26ce7	9c22bc65-2479-4780-b3a0-0ed5e139ee5f	پیشرفت اولیه و بررسی نیازمندی‌ها	221	35	2026-07-16	submitted	\N	\N	43e50eaf-f56d-481a-bf42-8d1ab9a55e9b	2026-07-20 09:59:26.363877+00	2026-07-20 09:59:26.363877+00
a03a787d-b998-4a31-aa2e-2aef31ab5784	c7dacc4b-6f9a-4a52-a4a7-86b10cf0df42	9c22bc65-2479-4780-b3a0-0ed5e139ee5f	تست و اطمینان از عملکرد صحیح	91	37	2026-07-16	approved	328fce4c-c7e7-4b44-8dcb-45aad65bd8e5	\N	8ee4e952-6ba7-4cfa-abf5-b54d6696ab85	2026-07-20 09:59:26.363877+00	2026-07-20 09:59:26.363877+00
a03a787d-b998-4a31-aa2e-2aef31ab5784	c7dacc4b-6f9a-4a52-a4a7-86b10cf0df42	9c22bc65-2479-4780-b3a0-0ed5e139ee5f	رفع اشکالات و بازبینی	127	68	2026-07-16	approved	328fce4c-c7e7-4b44-8dcb-45aad65bd8e5	\N	63412e79-f2c8-48c3-8a36-347593e27f60	2026-07-20 09:59:26.363877+00	2026-07-20 09:59:26.363877+00
a03a787d-b998-4a31-aa2e-2aef31ab5784	841e11ce-e7c2-45fb-b3c9-d99f4648100c	328fce4c-c7e7-4b44-8dcb-45aad65bd8e5	رفع اشکالات و بازبینی	122	36	2026-07-16	approved	328fce4c-c7e7-4b44-8dcb-45aad65bd8e5	\N	c4d97442-3771-4923-b902-8ee2c4e87519	2026-07-20 09:59:26.363877+00	2026-07-20 09:59:26.363877+00
a03a787d-b998-4a31-aa2e-2aef31ab5784	841e11ce-e7c2-45fb-b3c9-d99f4648100c	328fce4c-c7e7-4b44-8dcb-45aad65bd8e5	تست و اطمینان از عملکرد صحیح	55	70	2026-07-16	approved	328fce4c-c7e7-4b44-8dcb-45aad65bd8e5	\N	e7d7a2e4-1434-4304-b971-cbada96ac595	2026-07-20 09:59:26.363877+00	2026-07-20 09:59:26.363877+00
a03a787d-b998-4a31-aa2e-2aef31ab5784	841e11ce-e7c2-45fb-b3c9-d99f4648100c	328fce4c-c7e7-4b44-8dcb-45aad65bd8e5	پیاده‌سازی بخش اصلی	124	90	2026-07-16	approved	328fce4c-c7e7-4b44-8dcb-45aad65bd8e5	\N	03cd7116-482b-4533-9a23-6378954b2762	2026-07-20 09:59:26.363877+00	2026-07-20 09:59:26.363877+00
a03a787d-b998-4a31-aa2e-2aef31ab5784	dd1c62b6-a7fd-4430-affa-03d527359088	328fce4c-c7e7-4b44-8dcb-45aad65bd8e5	پیاده‌سازی بخش اصلی	219	24	2026-07-16	approved	328fce4c-c7e7-4b44-8dcb-45aad65bd8e5	\N	86c12623-58b4-4b72-97b7-9b0e711e0406	2026-07-20 09:59:26.363877+00	2026-07-20 09:59:26.363877+00
a03a787d-b998-4a31-aa2e-2aef31ab5784	dd1c62b6-a7fd-4430-affa-03d527359088	328fce4c-c7e7-4b44-8dcb-45aad65bd8e5	مستندسازی و نهایی‌سازی	178	66	2026-07-16	approved	328fce4c-c7e7-4b44-8dcb-45aad65bd8e5	\N	acdbb723-c15d-4026-8a2d-41e962a9e8ae	2026-07-20 09:59:26.363877+00	2026-07-20 09:59:26.363877+00
a03a787d-b998-4a31-aa2e-2aef31ab5784	dd1c62b6-a7fd-4430-affa-03d527359088	328fce4c-c7e7-4b44-8dcb-45aad65bd8e5	رفع اشکالات و بازبینی	88	96	2026-07-16	approved	328fce4c-c7e7-4b44-8dcb-45aad65bd8e5	\N	32dcd831-38b3-414e-a234-e67e1cb9875a	2026-07-20 09:59:26.363877+00	2026-07-20 09:59:26.363877+00
a03a787d-b998-4a31-aa2e-2aef31ab5784	dd1c62b6-a7fd-4430-affa-03d527359088	328fce4c-c7e7-4b44-8dcb-45aad65bd8e5	رفع اشکالات و بازبینی	95	100	2026-07-16	approved	328fce4c-c7e7-4b44-8dcb-45aad65bd8e5	\N	2cdd4ca2-f9b4-4b17-b41a-d233fde1c1c0	2026-07-20 09:59:26.363877+00	2026-07-20 09:59:26.363877+00
a03a787d-b998-4a31-aa2e-2aef31ab5784	928096af-708b-4d6e-9405-27c454f738ea	1775df44-8335-487a-9a3b-a1a6eb5949f5	پیاده‌سازی بخش اصلی	217	31	2026-07-14	approved	328fce4c-c7e7-4b44-8dcb-45aad65bd8e5	\N	6f3c906a-e8e7-451b-b5ae-4996641564e1	2026-07-20 09:59:26.363877+00	2026-07-20 09:59:26.363877+00
a03a787d-b998-4a31-aa2e-2aef31ab5784	928096af-708b-4d6e-9405-27c454f738ea	1775df44-8335-487a-9a3b-a1a6eb5949f5	پیاده‌سازی بخش اصلی	214	74	2026-07-16	approved	328fce4c-c7e7-4b44-8dcb-45aad65bd8e5	\N	cf27b647-381e-453c-ba3a-f03fd7fd9d61	2026-07-20 09:59:26.363877+00	2026-07-20 09:59:26.363877+00
a03a787d-b998-4a31-aa2e-2aef31ab5784	928096af-708b-4d6e-9405-27c454f738ea	1775df44-8335-487a-9a3b-a1a6eb5949f5	پیاده‌سازی بخش اصلی	168	100	2026-07-16	approved	328fce4c-c7e7-4b44-8dcb-45aad65bd8e5	\N	d004ce02-8e6d-400d-a17b-9e0900afd1bc	2026-07-20 09:59:26.363877+00	2026-07-20 09:59:26.363877+00
a03a787d-b998-4a31-aa2e-2aef31ab5784	928096af-708b-4d6e-9405-27c454f738ea	1775df44-8335-487a-9a3b-a1a6eb5949f5	مستندسازی و نهایی‌سازی	38	88	2026-07-16	approved	328fce4c-c7e7-4b44-8dcb-45aad65bd8e5	\N	796387c4-d5e2-4933-ac64-f57437656c52	2026-07-20 09:59:26.363877+00	2026-07-20 09:59:26.363877+00
a03a787d-b998-4a31-aa2e-2aef31ab5784	5d6fbf79-eefa-451c-b230-1f5ea9409dec	9c22bc65-2479-4780-b3a0-0ed5e139ee5f	پیاده‌سازی بخش اصلی	47	24	2026-07-16	approved	328fce4c-c7e7-4b44-8dcb-45aad65bd8e5	\N	93bd687a-cff0-4fd9-8413-c6c14b44da0b	2026-07-20 09:59:26.363877+00	2026-07-20 09:59:26.363877+00
a03a787d-b998-4a31-aa2e-2aef31ab5784	327fbe5d-06a4-4e7b-ad21-43d83e227549	276feb60-37b2-42ff-be39-f9e79af8ae2a	مستندسازی و نهایی‌سازی	146	31	2026-07-16	approved	328fce4c-c7e7-4b44-8dcb-45aad65bd8e5	\N	3b9dbac8-7deb-4fbf-a564-61cbd336ad74	2026-07-20 09:59:26.363877+00	2026-07-20 09:59:26.363877+00
a03a787d-b998-4a31-aa2e-2aef31ab5784	d0a748af-632e-4682-8c53-637046c6aea2	c1eff56a-cf6f-4901-9c44-9063f53db8c8	پیشرفت اولیه و بررسی نیازمندی‌ها	31	37	2026-06-23	approved	328fce4c-c7e7-4b44-8dcb-45aad65bd8e5	\N	8582d3a6-1704-4ce5-a518-e4606fabf512	2026-07-20 09:59:26.363877+00	2026-07-20 09:59:26.363877+00
a03a787d-b998-4a31-aa2e-2aef31ab5784	b37d8cc3-6d56-456d-ba16-73d574fe6c78	c1eff56a-cf6f-4901-9c44-9063f53db8c8	پیشرفت اولیه و بررسی نیازمندی‌ها	165	28	2026-07-16	approved	328fce4c-c7e7-4b44-8dcb-45aad65bd8e5	\N	a7add026-e47d-4ce2-98f5-14bd38e8a965	2026-07-20 09:59:26.363877+00	2026-07-20 09:59:26.363877+00
a03a787d-b998-4a31-aa2e-2aef31ab5784	b37d8cc3-6d56-456d-ba16-73d574fe6c78	c1eff56a-cf6f-4901-9c44-9063f53db8c8	پیشرفت اولیه و بررسی نیازمندی‌ها	158	66	2026-07-16	approved	328fce4c-c7e7-4b44-8dcb-45aad65bd8e5	\N	ba01b982-c01c-4a3c-b44f-8dad52f76cdd	2026-07-20 09:59:26.363877+00	2026-07-20 09:59:26.363877+00
a03a787d-b998-4a31-aa2e-2aef31ab5784	b37d8cc3-6d56-456d-ba16-73d574fe6c78	c1eff56a-cf6f-4901-9c44-9063f53db8c8	پیشرفت اولیه و بررسی نیازمندی‌ها	54	100	2026-07-16	approved	328fce4c-c7e7-4b44-8dcb-45aad65bd8e5	\N	d5b35f6a-f382-40bc-b819-903166bb5abb	2026-07-20 09:59:26.363877+00	2026-07-20 09:59:26.363877+00
a03a787d-b998-4a31-aa2e-2aef31ab5784	b37d8cc3-6d56-456d-ba16-73d574fe6c78	c1eff56a-cf6f-4901-9c44-9063f53db8c8	پیاده‌سازی بخش اصلی	79	100	2026-07-16	approved	328fce4c-c7e7-4b44-8dcb-45aad65bd8e5	\N	5884da04-d49c-4699-91a7-525282723bfe	2026-07-20 09:59:26.363877+00	2026-07-20 09:59:26.363877+00
a03a787d-b998-4a31-aa2e-2aef31ab5784	ac6ce572-bba3-4ddb-b1d9-506d128f0df5	f2917b41-6f1c-4444-a73d-884a91e847fe	رفع اشکالات و بازبینی	233	32	2026-07-09	approved	328fce4c-c7e7-4b44-8dcb-45aad65bd8e5	\N	a298bd6e-4afa-45ac-89d8-dedd6f91eef4	2026-07-20 09:59:26.363877+00	2026-07-20 09:59:26.363877+00
a03a787d-b998-4a31-aa2e-2aef31ab5784	ac6ce572-bba3-4ddb-b1d9-506d128f0df5	f2917b41-6f1c-4444-a73d-884a91e847fe	رفع اشکالات و بازبینی	133	68	2026-07-10	approved	328fce4c-c7e7-4b44-8dcb-45aad65bd8e5	\N	18d3f488-7934-46b2-9728-1b0d289b3985	2026-07-20 09:59:26.363877+00	2026-07-20 09:59:26.363877+00
a03a787d-b998-4a31-aa2e-2aef31ab5784	ac6ce572-bba3-4ddb-b1d9-506d128f0df5	f2917b41-6f1c-4444-a73d-884a91e847fe	پیاده‌سازی بخش اصلی	106	66	2026-07-13	approved	328fce4c-c7e7-4b44-8dcb-45aad65bd8e5	\N	6ea5dbd4-9662-4297-88a8-38906db8ca36	2026-07-20 09:59:26.363877+00	2026-07-20 09:59:26.363877+00
a03a787d-b998-4a31-aa2e-2aef31ab5784	8d8bd017-eaaf-4f21-a91d-73a928dddf1d	9c22bc65-2479-4780-b3a0-0ed5e139ee5f	تست و اطمینان از عملکرد صحیح	127	32	2026-07-16	approved	328fce4c-c7e7-4b44-8dcb-45aad65bd8e5	\N	91989822-a964-469e-85e1-652ad326f93e	2026-07-20 09:59:26.363877+00	2026-07-20 09:59:26.363877+00
a03a787d-b998-4a31-aa2e-2aef31ab5784	339a7d65-3bc7-4cc2-ad87-a4beb491511d	f2917b41-6f1c-4444-a73d-884a91e847fe	پیشرفت اولیه و بررسی نیازمندی‌ها	209	25	2026-07-16	approved	328fce4c-c7e7-4b44-8dcb-45aad65bd8e5	\N	08930418-da26-456d-ab8c-2fe300d81e68	2026-07-20 09:59:26.363877+00	2026-07-20 09:59:26.363877+00
a03a787d-b998-4a31-aa2e-2aef31ab5784	339a7d65-3bc7-4cc2-ad87-a4beb491511d	f2917b41-6f1c-4444-a73d-884a91e847fe	تست و اطمینان از عملکرد صحیح	141	80	2026-07-16	approved	328fce4c-c7e7-4b44-8dcb-45aad65bd8e5	\N	35fdc9cb-768a-4337-ba2d-c508bc48d02a	2026-07-20 09:59:26.363877+00	2026-07-20 09:59:26.363877+00
a03a787d-b998-4a31-aa2e-2aef31ab5784	339a7d65-3bc7-4cc2-ad87-a4beb491511d	f2917b41-6f1c-4444-a73d-884a91e847fe	مستندسازی و نهایی‌سازی	54	100	2026-07-16	approved	328fce4c-c7e7-4b44-8dcb-45aad65bd8e5	\N	54df8ceb-ba75-45c3-ad03-a9ed1bbc77ee	2026-07-20 09:59:26.363877+00	2026-07-20 09:59:26.363877+00
a03a787d-b998-4a31-aa2e-2aef31ab5784	339a7d65-3bc7-4cc2-ad87-a4beb491511d	f2917b41-6f1c-4444-a73d-884a91e847fe	پیاده‌سازی بخش اصلی	84	100	2026-07-16	approved	328fce4c-c7e7-4b44-8dcb-45aad65bd8e5	\N	01c59599-bd7f-4b77-9c73-24fc7c415fa8	2026-07-20 09:59:26.363877+00	2026-07-20 09:59:26.363877+00
a03a787d-b998-4a31-aa2e-2aef31ab5784	fd5ede1a-65b0-4b66-a047-3ff639c3d0d5	c1eff56a-cf6f-4901-9c44-9063f53db8c8	پیشرفت اولیه و بررسی نیازمندی‌ها	49	28	2026-07-15	approved	328fce4c-c7e7-4b44-8dcb-45aad65bd8e5	\N	d072dfa5-88f6-4488-9e36-06a1797b0797	2026-07-20 09:59:26.363877+00	2026-07-20 09:59:26.363877+00
a03a787d-b998-4a31-aa2e-2aef31ab5784	fd5ede1a-65b0-4b66-a047-3ff639c3d0d5	c1eff56a-cf6f-4901-9c44-9063f53db8c8	پیاده‌سازی بخش اصلی	110	40	2026-07-16	approved	328fce4c-c7e7-4b44-8dcb-45aad65bd8e5	\N	3a7e65b1-aaf8-4588-81b1-d1abd552e5d0	2026-07-20 09:59:26.363877+00	2026-07-20 09:59:26.363877+00
a03a787d-b998-4a31-aa2e-2aef31ab5784	fd5ede1a-65b0-4b66-a047-3ff639c3d0d5	c1eff56a-cf6f-4901-9c44-9063f53db8c8	مستندسازی و نهایی‌سازی	66	96	2026-07-16	approved	328fce4c-c7e7-4b44-8dcb-45aad65bd8e5	\N	7964a4dd-23e2-4f82-8351-1f15097522ef	2026-07-20 09:59:26.363877+00	2026-07-20 09:59:26.363877+00
a03a787d-b998-4a31-aa2e-2aef31ab5784	fd5ede1a-65b0-4b66-a047-3ff639c3d0d5	c1eff56a-cf6f-4901-9c44-9063f53db8c8	رفع اشکالات و بازبینی	71	100	2026-07-16	approved	328fce4c-c7e7-4b44-8dcb-45aad65bd8e5	\N	a5635ffc-5174-482a-9d94-9412c22c1149	2026-07-20 09:59:26.363877+00	2026-07-20 09:59:26.363877+00
a03a787d-b998-4a31-aa2e-2aef31ab5784	72e0a2f5-cafe-4c8f-b94d-6951235e8096	276feb60-37b2-42ff-be39-f9e79af8ae2a	مستندسازی و نهایی‌سازی	114	32	2026-06-27	approved	328fce4c-c7e7-4b44-8dcb-45aad65bd8e5	\N	2f2d455d-2715-406d-a39a-6062e83d16ca	2026-07-20 09:59:26.363877+00	2026-07-20 09:59:26.363877+00
a03a787d-b998-4a31-aa2e-2aef31ab5784	72e0a2f5-cafe-4c8f-b94d-6951235e8096	276feb60-37b2-42ff-be39-f9e79af8ae2a	پیشرفت اولیه و بررسی نیازمندی‌ها	158	62	2026-06-29	approved	328fce4c-c7e7-4b44-8dcb-45aad65bd8e5	\N	349f0201-91e7-4ac1-ba44-4a37e8147d14	2026-07-20 09:59:26.363877+00	2026-07-20 09:59:26.363877+00
a03a787d-b998-4a31-aa2e-2aef31ab5784	69ece2e8-7a04-4d2c-b170-5e5a0c81529b	f2917b41-6f1c-4444-a73d-884a91e847fe	پیشرفت اولیه و بررسی نیازمندی‌ها	117	39	2026-07-08	approved	328fce4c-c7e7-4b44-8dcb-45aad65bd8e5	\N	88828a79-a41b-43e6-a4c8-ebe95eb2a0bf	2026-07-20 09:59:26.363877+00	2026-07-20 09:59:26.363877+00
a03a787d-b998-4a31-aa2e-2aef31ab5784	6c9e9812-65e9-4e9f-bddb-c86c88766c28	f2917b41-6f1c-4444-a73d-884a91e847fe	پیشرفت اولیه و بررسی نیازمندی‌ها	192	28	2026-07-16	approved	328fce4c-c7e7-4b44-8dcb-45aad65bd8e5	\N	87877c11-4741-4d45-8f72-859b884897b0	2026-07-20 09:59:26.363877+00	2026-07-20 09:59:26.363877+00
a03a787d-b998-4a31-aa2e-2aef31ab5784	6c9e9812-65e9-4e9f-bddb-c86c88766c28	f2917b41-6f1c-4444-a73d-884a91e847fe	تست و اطمینان از عملکرد صحیح	88	62	2026-07-16	approved	328fce4c-c7e7-4b44-8dcb-45aad65bd8e5	\N	af9e6fd2-8858-4976-8967-0023295cff26	2026-07-20 09:59:26.363877+00	2026-07-20 09:59:26.363877+00
a03a787d-b998-4a31-aa2e-2aef31ab5784	6c9e9812-65e9-4e9f-bddb-c86c88766c28	f2917b41-6f1c-4444-a73d-884a91e847fe	تست و اطمینان از عملکرد صحیح	77	100	2026-07-16	approved	328fce4c-c7e7-4b44-8dcb-45aad65bd8e5	\N	4d10e736-f17c-4621-92ef-c68b754970f9	2026-07-20 09:59:26.363877+00	2026-07-20 09:59:26.363877+00
a03a787d-b998-4a31-aa2e-2aef31ab5784	6c9e9812-65e9-4e9f-bddb-c86c88766c28	f2917b41-6f1c-4444-a73d-884a91e847fe	پیشرفت اولیه و بررسی نیازمندی‌ها	227	100	2026-07-16	approved	328fce4c-c7e7-4b44-8dcb-45aad65bd8e5	\N	5867e694-bb27-4e06-88ee-3faff2ad7493	2026-07-20 09:59:26.363877+00	2026-07-20 09:59:26.363877+00
a03a787d-b998-4a31-aa2e-2aef31ab5784	e05c4036-c226-4d2d-94bb-49e2b786f03b	767b011b-ff3a-4faf-b85b-c424554a44a0	پیشرفت اولیه و بررسی نیازمندی‌ها	98	24	2026-07-16	submitted	\N	\N	2967d7d5-8946-4ae6-8229-47b9977f598e	2026-07-20 09:59:26.363877+00	2026-07-20 09:59:26.363877+00
a03a787d-b998-4a31-aa2e-2aef31ab5784	e05c4036-c226-4d2d-94bb-49e2b786f03b	767b011b-ff3a-4faf-b85b-c424554a44a0	پیاده‌سازی بخش اصلی	219	64	2026-07-16	submitted	\N	\N	9a142906-5ba5-4374-bbf9-5c9080b434c4	2026-07-20 09:59:26.363877+00	2026-07-20 09:59:26.363877+00
a03a787d-b998-4a31-aa2e-2aef31ab5784	e05c4036-c226-4d2d-94bb-49e2b786f03b	767b011b-ff3a-4faf-b85b-c424554a44a0	پیشرفت اولیه و بررسی نیازمندی‌ها	31	87	2026-07-16	approved	328fce4c-c7e7-4b44-8dcb-45aad65bd8e5	\N	50ed9bfb-323b-4759-bd7a-c7fb840cafde	2026-07-20 09:59:26.363877+00	2026-07-20 09:59:26.363877+00
a03a787d-b998-4a31-aa2e-2aef31ab5784	39fc0058-27d3-4ad8-9445-5eb609ea0415	f2917b41-6f1c-4444-a73d-884a91e847fe	رفع اشکالات و بازبینی	56	24	2026-07-16	approved	328fce4c-c7e7-4b44-8dcb-45aad65bd8e5	\N	6a272ca3-1a62-4e06-82aa-d3df9e71c489	2026-07-20 09:59:26.363877+00	2026-07-20 09:59:26.363877+00
a03a787d-b998-4a31-aa2e-2aef31ab5784	39fc0058-27d3-4ad8-9445-5eb609ea0415	f2917b41-6f1c-4444-a73d-884a91e847fe	پیاده‌سازی بخش اصلی	140	68	2026-07-16	approved	328fce4c-c7e7-4b44-8dcb-45aad65bd8e5	\N	56fe38fe-abe3-4681-977e-e7decf438dbd	2026-07-20 09:59:26.363877+00	2026-07-20 09:59:26.363877+00
a03a787d-b998-4a31-aa2e-2aef31ab5784	39fc0058-27d3-4ad8-9445-5eb609ea0415	f2917b41-6f1c-4444-a73d-884a91e847fe	پیشرفت اولیه و بررسی نیازمندی‌ها	36	66	2026-07-16	approved	328fce4c-c7e7-4b44-8dcb-45aad65bd8e5	\N	8c5c4484-f952-47a5-9a67-e1a97c2d8ed0	2026-07-20 09:59:26.363877+00	2026-07-20 09:59:26.363877+00
a03a787d-b998-4a31-aa2e-2aef31ab5784	39fc0058-27d3-4ad8-9445-5eb609ea0415	f2917b41-6f1c-4444-a73d-884a91e847fe	مستندسازی و نهایی‌سازی	53	100	2026-07-16	approved	328fce4c-c7e7-4b44-8dcb-45aad65bd8e5	\N	9a7aeba6-b2ec-4ddb-8f34-83f8dc4a0b41	2026-07-20 09:59:26.363877+00	2026-07-20 09:59:26.363877+00
a03a787d-b998-4a31-aa2e-2aef31ab5784	d80b6d81-8e2e-498f-9653-97dcdade0eb4	276feb60-37b2-42ff-be39-f9e79af8ae2a	پیشرفت اولیه و بررسی نیازمندی‌ها	104	33	2026-07-15	approved	328fce4c-c7e7-4b44-8dcb-45aad65bd8e5	\N	bdbfcf92-f2c7-4acd-93f5-941f61e3d64d	2026-07-20 09:59:26.363877+00	2026-07-20 09:59:26.363877+00
a03a787d-b998-4a31-aa2e-2aef31ab5784	d80b6d81-8e2e-498f-9653-97dcdade0eb4	276feb60-37b2-42ff-be39-f9e79af8ae2a	پیشرفت اولیه و بررسی نیازمندی‌ها	215	74	2026-07-16	approved	328fce4c-c7e7-4b44-8dcb-45aad65bd8e5	\N	8be3d4e3-3510-4c31-991b-a7868ae5c3f0	2026-07-20 09:59:26.363877+00	2026-07-20 09:59:26.363877+00
a03a787d-b998-4a31-aa2e-2aef31ab5784	d80b6d81-8e2e-498f-9653-97dcdade0eb4	276feb60-37b2-42ff-be39-f9e79af8ae2a	مستندسازی و نهایی‌سازی	163	75	2026-07-16	approved	328fce4c-c7e7-4b44-8dcb-45aad65bd8e5	\N	96ea7043-2aaa-422c-98ae-fdc9f3123209	2026-07-20 09:59:26.363877+00	2026-07-20 09:59:26.363877+00
a03a787d-b998-4a31-aa2e-2aef31ab5784	47e13583-eac2-415c-8caf-3d05574dc4a7	9c22bc65-2479-4780-b3a0-0ed5e139ee5f	پیاده‌سازی بخش اصلی	98	29	2026-07-07	approved	328fce4c-c7e7-4b44-8dcb-45aad65bd8e5	\N	d497eab2-4847-412d-90e6-11599e5e7fda	2026-07-20 09:59:26.363877+00	2026-07-20 09:59:26.363877+00
a03a787d-b998-4a31-aa2e-2aef31ab5784	47e13583-eac2-415c-8caf-3d05574dc4a7	9c22bc65-2479-4780-b3a0-0ed5e139ee5f	تست و اطمینان از عملکرد صحیح	67	44	2026-07-10	approved	328fce4c-c7e7-4b44-8dcb-45aad65bd8e5	\N	3f34ef3d-d9be-44b0-9642-1c6e9971df99	2026-07-20 09:59:26.363877+00	2026-07-20 09:59:26.363877+00
a03a787d-b998-4a31-aa2e-2aef31ab5784	47e13583-eac2-415c-8caf-3d05574dc4a7	9c22bc65-2479-4780-b3a0-0ed5e139ee5f	تست و اطمینان از عملکرد صحیح	100	99	2026-07-11	approved	328fce4c-c7e7-4b44-8dcb-45aad65bd8e5	\N	137a03f1-515b-423f-bc3c-8044bf955bf0	2026-07-20 09:59:26.363877+00	2026-07-20 09:59:26.363877+00
a03a787d-b998-4a31-aa2e-2aef31ab5784	47e13583-eac2-415c-8caf-3d05574dc4a7	9c22bc65-2479-4780-b3a0-0ed5e139ee5f	تست و اطمینان از عملکرد صحیح	230	88	2026-07-16	approved	328fce4c-c7e7-4b44-8dcb-45aad65bd8e5	\N	85da0b5d-b238-400e-b150-cb636cbf721e	2026-07-20 09:59:26.363877+00	2026-07-20 09:59:26.363877+00
a03a787d-b998-4a31-aa2e-2aef31ab5784	0d8c4d5b-fdff-49bb-a417-183eaf90c6a6	c1eff56a-cf6f-4901-9c44-9063f53db8c8	پیاده‌سازی بخش اصلی	214	40	2026-07-16	approved	328fce4c-c7e7-4b44-8dcb-45aad65bd8e5	\N	dfc98378-9151-4a7c-a083-19e741a14e1b	2026-07-20 09:59:26.363877+00	2026-07-20 09:59:26.363877+00
a03a787d-b998-4a31-aa2e-2aef31ab5784	0d8c4d5b-fdff-49bb-a417-183eaf90c6a6	c1eff56a-cf6f-4901-9c44-9063f53db8c8	مستندسازی و نهایی‌سازی	187	52	2026-07-16	approved	328fce4c-c7e7-4b44-8dcb-45aad65bd8e5	\N	b9c2da6b-bea4-4022-bc47-adf7573a94b4	2026-07-20 09:59:26.363877+00	2026-07-20 09:59:26.363877+00
a03a787d-b998-4a31-aa2e-2aef31ab5784	0d8c4d5b-fdff-49bb-a417-183eaf90c6a6	c1eff56a-cf6f-4901-9c44-9063f53db8c8	پیشرفت اولیه و بررسی نیازمندی‌ها	64	87	2026-07-16	approved	328fce4c-c7e7-4b44-8dcb-45aad65bd8e5	\N	6347449f-0ae2-4b12-8df9-9c10e615c051	2026-07-20 09:59:26.363877+00	2026-07-20 09:59:26.363877+00
a03a787d-b998-4a31-aa2e-2aef31ab5784	26703eaf-1795-4473-9456-bb8c896f9282	328fce4c-c7e7-4b44-8dcb-45aad65bd8e5	مستندسازی و نهایی‌سازی	127	30	2026-07-01	approved	328fce4c-c7e7-4b44-8dcb-45aad65bd8e5	\N	40424ddd-a35c-4edf-b9f7-83f8a89650ab	2026-07-20 09:59:26.363877+00	2026-07-20 09:59:26.363877+00
a03a787d-b998-4a31-aa2e-2aef31ab5784	b1623dbf-68b9-4f79-b7cc-b60ec24c9c1f	1775df44-8335-487a-9a3b-a1a6eb5949f5	تست و اطمینان از عملکرد صحیح	238	40	2026-07-15	approved	328fce4c-c7e7-4b44-8dcb-45aad65bd8e5	\N	767a272a-7c7a-4567-abab-68112ed96d03	2026-07-20 09:59:26.363877+00	2026-07-20 09:59:26.363877+00
a03a787d-b998-4a31-aa2e-2aef31ab5784	b1623dbf-68b9-4f79-b7cc-b60ec24c9c1f	1775df44-8335-487a-9a3b-a1a6eb5949f5	رفع اشکالات و بازبینی	112	78	2026-07-16	approved	328fce4c-c7e7-4b44-8dcb-45aad65bd8e5	\N	3c4c85d3-f3e7-40bf-84e3-c294b01d65e7	2026-07-20 09:59:26.363877+00	2026-07-20 09:59:26.363877+00
a03a787d-b998-4a31-aa2e-2aef31ab5784	b1623dbf-68b9-4f79-b7cc-b60ec24c9c1f	1775df44-8335-487a-9a3b-a1a6eb5949f5	تست و اطمینان از عملکرد صحیح	110	75	2026-07-16	approved	328fce4c-c7e7-4b44-8dcb-45aad65bd8e5	\N	b9f385d5-4e40-46ba-a93c-a4bd68ca90fe	2026-07-20 09:59:26.363877+00	2026-07-20 09:59:26.363877+00
a03a787d-b998-4a31-aa2e-2aef31ab5784	b1623dbf-68b9-4f79-b7cc-b60ec24c9c1f	1775df44-8335-487a-9a3b-a1a6eb5949f5	رفع اشکالات و بازبینی	104	100	2026-07-16	approved	328fce4c-c7e7-4b44-8dcb-45aad65bd8e5	\N	2d0cd745-c1a1-4b84-b1b2-f37219a7cfe0	2026-07-20 09:59:26.363877+00	2026-07-20 09:59:26.363877+00
a03a787d-b998-4a31-aa2e-2aef31ab5784	82ba62d6-38b5-4401-b3d0-654d0d6e9555	328fce4c-c7e7-4b44-8dcb-45aad65bd8e5	رفع اشکالات و بازبینی	239	32	2026-07-16	approved	328fce4c-c7e7-4b44-8dcb-45aad65bd8e5	\N	d720a3b7-18f4-44a3-9e00-75021180bace	2026-07-20 09:59:26.363877+00	2026-07-20 09:59:26.363877+00
a03a787d-b998-4a31-aa2e-2aef31ab5784	82ba62d6-38b5-4401-b3d0-654d0d6e9555	328fce4c-c7e7-4b44-8dcb-45aad65bd8e5	مستندسازی و نهایی‌سازی	81	76	2026-07-16	approved	328fce4c-c7e7-4b44-8dcb-45aad65bd8e5	\N	527c1882-f9e8-44f7-aa2d-0508fac20a58	2026-07-20 09:59:26.363877+00	2026-07-20 09:59:26.363877+00
a03a787d-b998-4a31-aa2e-2aef31ab5784	82ba62d6-38b5-4401-b3d0-654d0d6e9555	328fce4c-c7e7-4b44-8dcb-45aad65bd8e5	مستندسازی و نهایی‌سازی	36	100	2026-07-16	approved	328fce4c-c7e7-4b44-8dcb-45aad65bd8e5	\N	b813b514-6063-4fcf-96ac-cbe35ea8a13a	2026-07-20 09:59:26.363877+00	2026-07-20 09:59:26.363877+00
a03a787d-b998-4a31-aa2e-2aef31ab5784	82ba62d6-38b5-4401-b3d0-654d0d6e9555	328fce4c-c7e7-4b44-8dcb-45aad65bd8e5	رفع اشکالات و بازبینی	207	88	2026-07-16	approved	328fce4c-c7e7-4b44-8dcb-45aad65bd8e5	\N	3e383ec2-3a1b-4710-a9f0-b0a6f47ef9b3	2026-07-20 09:59:26.363877+00	2026-07-20 09:59:26.363877+00
a03a787d-b998-4a31-aa2e-2aef31ab5784	201721e4-774b-4680-8f11-2a98ebcccdd3	328fce4c-c7e7-4b44-8dcb-45aad65bd8e5	رفع اشکالات و بازبینی	91	28	2026-07-16	approved	328fce4c-c7e7-4b44-8dcb-45aad65bd8e5	\N	205bfd5d-094e-4234-9970-a61e51089bda	2026-07-20 09:59:26.363877+00	2026-07-20 09:59:26.363877+00
a03a787d-b998-4a31-aa2e-2aef31ab5784	201721e4-774b-4680-8f11-2a98ebcccdd3	328fce4c-c7e7-4b44-8dcb-45aad65bd8e5	تست و اطمینان از عملکرد صحیح	48	68	2026-07-16	submitted	\N	\N	017c6f16-16b6-4651-8955-28f46cd97770	2026-07-20 09:59:26.363877+00	2026-07-20 09:59:26.363877+00
a03a787d-b998-4a31-aa2e-2aef31ab5784	201721e4-774b-4680-8f11-2a98ebcccdd3	328fce4c-c7e7-4b44-8dcb-45aad65bd8e5	مستندسازی و نهایی‌سازی	159	99	2026-07-16	approved	328fce4c-c7e7-4b44-8dcb-45aad65bd8e5	\N	8ee33b38-119f-47dc-9672-b0b99c66fd12	2026-07-20 09:59:26.363877+00	2026-07-20 09:59:26.363877+00
a03a787d-b998-4a31-aa2e-2aef31ab5784	201721e4-774b-4680-8f11-2a98ebcccdd3	328fce4c-c7e7-4b44-8dcb-45aad65bd8e5	رفع اشکالات و بازبینی	209	100	2026-07-16	submitted	\N	\N	70996976-3c1c-4b4c-8c22-3620b85cff86	2026-07-20 09:59:26.363877+00	2026-07-20 09:59:26.363877+00
a03a787d-b998-4a31-aa2e-2aef31ab5784	2bc6e958-b864-4ae3-b241-23627f96fb7c	767b011b-ff3a-4faf-b85b-c424554a44a0	پیاده‌سازی بخش اصلی	198	31	2026-06-24	approved	328fce4c-c7e7-4b44-8dcb-45aad65bd8e5	\N	bee0f1f8-fe23-42b7-b20b-320f15f90ab8	2026-07-20 09:59:26.363877+00	2026-07-20 09:59:26.363877+00
a03a787d-b998-4a31-aa2e-2aef31ab5784	544de8f4-ac41-41c1-a64b-43d36094afe3	c1eff56a-cf6f-4901-9c44-9063f53db8c8	مستندسازی و نهایی‌سازی	195	40	2026-07-16	approved	328fce4c-c7e7-4b44-8dcb-45aad65bd8e5	\N	2fd2dce5-b06e-4028-882d-8b5f8441b80c	2026-07-20 09:59:26.363877+00	2026-07-20 09:59:26.363877+00
a03a787d-b998-4a31-aa2e-2aef31ab5784	544de8f4-ac41-41c1-a64b-43d36094afe3	c1eff56a-cf6f-4901-9c44-9063f53db8c8	رفع اشکالات و بازبینی	233	66	2026-07-16	approved	328fce4c-c7e7-4b44-8dcb-45aad65bd8e5	\N	f65b1fce-9c53-4806-840e-ce85afed8415	2026-07-20 09:59:26.363877+00	2026-07-20 09:59:26.363877+00
a03a787d-b998-4a31-aa2e-2aef31ab5784	9057f71b-abea-4aae-9f30-89ef1f0a84f6	767b011b-ff3a-4faf-b85b-c424554a44a0	پیشرفت اولیه و بررسی نیازمندی‌ها	96	27	2026-07-16	approved	328fce4c-c7e7-4b44-8dcb-45aad65bd8e5	\N	02ae9f0b-8353-44cb-8041-8cb9535a7add	2026-07-20 09:59:26.363877+00	2026-07-20 09:59:26.363877+00
a03a787d-b998-4a31-aa2e-2aef31ab5784	25c364b1-a0a3-46c6-a5e4-f68dbc0b8a49	276feb60-37b2-42ff-be39-f9e79af8ae2a	رفع اشکالات و بازبینی	130	34	2026-07-16	approved	328fce4c-c7e7-4b44-8dcb-45aad65bd8e5	\N	b25f5e43-8086-44b5-aaa1-1338de61d6e9	2026-07-20 09:59:26.363877+00	2026-07-20 09:59:26.363877+00
a03a787d-b998-4a31-aa2e-2aef31ab5784	25c364b1-a0a3-46c6-a5e4-f68dbc0b8a49	276feb60-37b2-42ff-be39-f9e79af8ae2a	رفع اشکالات و بازبینی	36	70	2026-07-16	approved	328fce4c-c7e7-4b44-8dcb-45aad65bd8e5	\N	63a37a15-2794-44d0-8262-233fd325b472	2026-07-20 09:59:26.363877+00	2026-07-20 09:59:26.363877+00
a03a787d-b998-4a31-aa2e-2aef31ab5784	836031d4-f867-413f-a9e5-8891bbc7fd58	c1eff56a-cf6f-4901-9c44-9063f53db8c8	پیشرفت اولیه و بررسی نیازمندی‌ها	59	24	2026-07-16	approved	328fce4c-c7e7-4b44-8dcb-45aad65bd8e5	\N	d8bf1f24-1d8e-4f2c-bf73-3d05a0de1409	2026-07-20 09:59:26.363877+00	2026-07-20 09:59:26.363877+00
a03a787d-b998-4a31-aa2e-2aef31ab5784	ae7a8213-ca2b-4903-89da-de31978a2e8b	f2917b41-6f1c-4444-a73d-884a91e847fe	رفع اشکالات و بازبینی	146	26	2026-07-16	approved	328fce4c-c7e7-4b44-8dcb-45aad65bd8e5	\N	958d9a5f-f0ab-425c-8a7c-90427a4866df	2026-07-20 09:59:26.363877+00	2026-07-20 09:59:26.363877+00
a03a787d-b998-4a31-aa2e-2aef31ab5784	ae7a8213-ca2b-4903-89da-de31978a2e8b	f2917b41-6f1c-4444-a73d-884a91e847fe	رفع اشکالات و بازبینی	151	46	2026-07-16	approved	328fce4c-c7e7-4b44-8dcb-45aad65bd8e5	\N	7e688846-7ee5-45f1-bc71-0af167bd91e1	2026-07-20 09:59:26.363877+00	2026-07-20 09:59:26.363877+00
a03a787d-b998-4a31-aa2e-2aef31ab5784	ae7a8213-ca2b-4903-89da-de31978a2e8b	f2917b41-6f1c-4444-a73d-884a91e847fe	تست و اطمینان از عملکرد صحیح	111	66	2026-07-16	approved	328fce4c-c7e7-4b44-8dcb-45aad65bd8e5	\N	7b8dfa7a-cca9-4cad-aa6a-16d739f77c94	2026-07-20 09:59:26.363877+00	2026-07-20 09:59:26.363877+00
a03a787d-b998-4a31-aa2e-2aef31ab5784	1f5fdd86-102a-4348-9ced-30645af612bb	276feb60-37b2-42ff-be39-f9e79af8ae2a	پیشرفت اولیه و بررسی نیازمندی‌ها	35	30	2026-07-16	approved	328fce4c-c7e7-4b44-8dcb-45aad65bd8e5	\N	b0c673d1-7fc6-4640-9c51-9dfcc350b89d	2026-07-20 09:59:26.363877+00	2026-07-20 09:59:26.363877+00
a03a787d-b998-4a31-aa2e-2aef31ab5784	1f5fdd86-102a-4348-9ced-30645af612bb	276feb60-37b2-42ff-be39-f9e79af8ae2a	پیاده‌سازی بخش اصلی	219	54	2026-07-16	approved	328fce4c-c7e7-4b44-8dcb-45aad65bd8e5	\N	50097f25-63c2-42cb-9423-f50077639889	2026-07-20 09:59:26.363877+00	2026-07-20 09:59:26.363877+00
a03a787d-b998-4a31-aa2e-2aef31ab5784	1f5fdd86-102a-4348-9ced-30645af612bb	276feb60-37b2-42ff-be39-f9e79af8ae2a	مستندسازی و نهایی‌سازی	70	90	2026-07-16	approved	328fce4c-c7e7-4b44-8dcb-45aad65bd8e5	\N	4bf59c20-4da3-4aff-854e-34367d906e06	2026-07-20 09:59:26.363877+00	2026-07-20 09:59:26.363877+00
a03a787d-b998-4a31-aa2e-2aef31ab5784	42fc6f61-5d94-4dac-9e8d-a0cf1b529886	f2917b41-6f1c-4444-a73d-884a91e847fe	پیاده‌سازی بخش اصلی	234	32	2026-07-16	approved	328fce4c-c7e7-4b44-8dcb-45aad65bd8e5	\N	f11761fd-1ebf-4fea-abeb-1060bb1591fa	2026-07-20 09:59:26.363877+00	2026-07-20 09:59:26.363877+00
a03a787d-b998-4a31-aa2e-2aef31ab5784	42fc6f61-5d94-4dac-9e8d-a0cf1b529886	f2917b41-6f1c-4444-a73d-884a91e847fe	پیاده‌سازی بخش اصلی	193	66	2026-07-16	approved	328fce4c-c7e7-4b44-8dcb-45aad65bd8e5	\N	c3fa3a4e-fdb9-47bd-9828-6aed76f42936	2026-07-20 09:59:26.363877+00	2026-07-20 09:59:26.363877+00
a03a787d-b998-4a31-aa2e-2aef31ab5784	42fc6f61-5d94-4dac-9e8d-a0cf1b529886	f2917b41-6f1c-4444-a73d-884a91e847fe	پیشرفت اولیه و بررسی نیازمندی‌ها	218	100	2026-07-16	approved	328fce4c-c7e7-4b44-8dcb-45aad65bd8e5	\N	38a510e3-34ef-4752-86c4-f20f275150c5	2026-07-20 09:59:26.363877+00	2026-07-20 09:59:26.363877+00
a03a787d-b998-4a31-aa2e-2aef31ab5784	42fc6f61-5d94-4dac-9e8d-a0cf1b529886	f2917b41-6f1c-4444-a73d-884a91e847fe	تست و اطمینان از عملکرد صحیح	181	100	2026-07-16	approved	328fce4c-c7e7-4b44-8dcb-45aad65bd8e5	\N	00eb75cd-7af5-49b4-ac66-e8b69ce976a5	2026-07-20 09:59:26.363877+00	2026-07-20 09:59:26.363877+00
a03a787d-b998-4a31-aa2e-2aef31ab5784	2dfb3f83-275c-4f27-8cdd-88799b2e4721	f2917b41-6f1c-4444-a73d-884a91e847fe	پیاده‌سازی بخش اصلی	101	22	2026-07-12	submitted	\N	\N	1241c143-189e-48c9-9947-3eb3e3e11176	2026-07-20 09:59:26.363877+00	2026-07-20 09:59:26.363877+00
a03a787d-b998-4a31-aa2e-2aef31ab5784	2dfb3f83-275c-4f27-8cdd-88799b2e4721	f2917b41-6f1c-4444-a73d-884a91e847fe	مستندسازی و نهایی‌سازی	77	62	2026-07-13	submitted	\N	\N	45af5a90-e06c-41cf-a546-7201f70c22cc	2026-07-20 09:59:26.363877+00	2026-07-20 09:59:26.363877+00
a03a787d-b998-4a31-aa2e-2aef31ab5784	2dfb3f83-275c-4f27-8cdd-88799b2e4721	f2917b41-6f1c-4444-a73d-884a91e847fe	پیشرفت اولیه و بررسی نیازمندی‌ها	97	100	2026-07-16	approved	328fce4c-c7e7-4b44-8dcb-45aad65bd8e5	\N	18234010-d8d3-4ceb-a2d8-a54236f66765	2026-07-20 09:59:26.363877+00	2026-07-20 09:59:26.363877+00
a03a787d-b998-4a31-aa2e-2aef31ab5784	2dfb3f83-275c-4f27-8cdd-88799b2e4721	f2917b41-6f1c-4444-a73d-884a91e847fe	مستندسازی و نهایی‌سازی	130	100	2026-07-16	approved	328fce4c-c7e7-4b44-8dcb-45aad65bd8e5	\N	435eb8d4-dc3a-46ad-8574-a4b0a29389fe	2026-07-20 09:59:26.363877+00	2026-07-20 09:59:26.363877+00
a03a787d-b998-4a31-aa2e-2aef31ab5784	26f4b33e-4b67-4d08-a323-a4b5093d4fe2	f2917b41-6f1c-4444-a73d-884a91e847fe	رفع اشکالات و بازبینی	147	39	2026-06-19	approved	328fce4c-c7e7-4b44-8dcb-45aad65bd8e5	\N	db26bae4-cf8e-444f-a023-24a1d7bb032b	2026-07-20 09:59:26.363877+00	2026-07-20 09:59:26.363877+00
a03a787d-b998-4a31-aa2e-2aef31ab5784	43a24e56-7465-4283-8a34-1b560c3f12b3	f2917b41-6f1c-4444-a73d-884a91e847fe	مستندسازی و نهایی‌سازی	181	22	2026-07-06	approved	328fce4c-c7e7-4b44-8dcb-45aad65bd8e5	\N	e46478d4-ea58-4d04-b3c2-1b79e1464ec9	2026-07-20 09:59:26.363877+00	2026-07-20 09:59:26.363877+00
a03a787d-b998-4a31-aa2e-2aef31ab5784	43a24e56-7465-4283-8a34-1b560c3f12b3	f2917b41-6f1c-4444-a73d-884a91e847fe	رفع اشکالات و بازبینی	60	54	2026-07-08	approved	328fce4c-c7e7-4b44-8dcb-45aad65bd8e5	\N	530f1a70-29b8-4a54-b95f-6a28a4668ada	2026-07-20 09:59:26.363877+00	2026-07-20 09:59:26.363877+00
a03a787d-b998-4a31-aa2e-2aef31ab5784	9871880d-37c7-4a8c-96d6-9ce6c72f88d3	c1eff56a-cf6f-4901-9c44-9063f53db8c8	پیاده‌سازی بخش اصلی	125	24	2026-07-16	approved	328fce4c-c7e7-4b44-8dcb-45aad65bd8e5	\N	13af1061-6860-48f3-a04b-70df8e4e0045	2026-07-20 09:59:26.363877+00	2026-07-20 09:59:26.363877+00
a03a787d-b998-4a31-aa2e-2aef31ab5784	9871880d-37c7-4a8c-96d6-9ce6c72f88d3	c1eff56a-cf6f-4901-9c44-9063f53db8c8	تست و اطمینان از عملکرد صحیح	182	48	2026-07-16	approved	328fce4c-c7e7-4b44-8dcb-45aad65bd8e5	\N	aebba013-26ad-48bf-a933-05100c6e9d2e	2026-07-20 09:59:26.363877+00	2026-07-20 09:59:26.363877+00
a03a787d-b998-4a31-aa2e-2aef31ab5784	9871880d-37c7-4a8c-96d6-9ce6c72f88d3	c1eff56a-cf6f-4901-9c44-9063f53db8c8	تست و اطمینان از عملکرد صحیح	77	100	2026-07-16	approved	328fce4c-c7e7-4b44-8dcb-45aad65bd8e5	\N	c64c3555-f72e-4a22-be40-71fff69871b1	2026-07-20 09:59:26.363877+00	2026-07-20 09:59:26.363877+00
a03a787d-b998-4a31-aa2e-2aef31ab5784	dbdd5e88-519c-42ae-9240-c2123ed24ace	1775df44-8335-487a-9a3b-a1a6eb5949f5	پیاده‌سازی بخش اصلی	77	30	2026-07-16	approved	328fce4c-c7e7-4b44-8dcb-45aad65bd8e5	\N	25a3104c-cb34-45cd-ba0c-5e1a799129ce	2026-07-20 09:59:26.363877+00	2026-07-20 09:59:26.363877+00
a03a787d-b998-4a31-aa2e-2aef31ab5784	dbdd5e88-519c-42ae-9240-c2123ed24ace	1775df44-8335-487a-9a3b-a1a6eb5949f5	رفع اشکالات و بازبینی	32	70	2026-07-16	approved	328fce4c-c7e7-4b44-8dcb-45aad65bd8e5	\N	0566509c-ab23-495f-99e0-fabc92a160e5	2026-07-20 09:59:26.363877+00	2026-07-20 09:59:26.363877+00
a03a787d-b998-4a31-aa2e-2aef31ab5784	807af3a5-a701-4a73-9dff-178000372c84	f2917b41-6f1c-4444-a73d-884a91e847fe	تست و اطمینان از عملکرد صحیح	173	36	2026-07-16	approved	328fce4c-c7e7-4b44-8dcb-45aad65bd8e5	\N	a757b82c-1a20-42b5-b201-20c5e7869296	2026-07-20 09:59:26.363877+00	2026-07-20 09:59:26.363877+00
a03a787d-b998-4a31-aa2e-2aef31ab5784	807af3a5-a701-4a73-9dff-178000372c84	f2917b41-6f1c-4444-a73d-884a91e847fe	تست و اطمینان از عملکرد صحیح	205	70	2026-07-16	approved	328fce4c-c7e7-4b44-8dcb-45aad65bd8e5	\N	658fbe6c-4f53-4e3e-8bc4-caac62a2465a	2026-07-20 09:59:26.363877+00	2026-07-20 09:59:26.363877+00
a03a787d-b998-4a31-aa2e-2aef31ab5784	06727d14-05f5-4caa-b1bf-d1411268b8a1	276feb60-37b2-42ff-be39-f9e79af8ae2a	تست و اطمینان از عملکرد صحیح	72	22	2026-07-03	approved	328fce4c-c7e7-4b44-8dcb-45aad65bd8e5	\N	b9e3c301-3442-4e76-b09c-2572bfd8f3e9	2026-07-20 09:59:26.363877+00	2026-07-20 09:59:26.363877+00
a03a787d-b998-4a31-aa2e-2aef31ab5784	06727d14-05f5-4caa-b1bf-d1411268b8a1	276feb60-37b2-42ff-be39-f9e79af8ae2a	پیاده‌سازی بخش اصلی	104	42	2026-07-04	approved	328fce4c-c7e7-4b44-8dcb-45aad65bd8e5	\N	34249fa3-b390-479c-b47b-d4e261143ead	2026-07-20 09:59:26.363877+00	2026-07-20 09:59:26.363877+00
a03a787d-b998-4a31-aa2e-2aef31ab5784	06727d14-05f5-4caa-b1bf-d1411268b8a1	276feb60-37b2-42ff-be39-f9e79af8ae2a	پیاده‌سازی بخش اصلی	167	87	2026-07-09	approved	328fce4c-c7e7-4b44-8dcb-45aad65bd8e5	\N	2a8e41ac-9538-4eda-91e8-d25564e4563e	2026-07-20 09:59:26.363877+00	2026-07-20 09:59:26.363877+00
a03a787d-b998-4a31-aa2e-2aef31ab5784	06727d14-05f5-4caa-b1bf-d1411268b8a1	276feb60-37b2-42ff-be39-f9e79af8ae2a	تست و اطمینان از عملکرد صحیح	174	100	2026-07-09	approved	328fce4c-c7e7-4b44-8dcb-45aad65bd8e5	\N	40d63bea-54ae-4f13-b84a-ada5795a9528	2026-07-20 09:59:26.363877+00	2026-07-20 09:59:26.363877+00
a03a787d-b998-4a31-aa2e-2aef31ab5784	e77cfef8-1b7b-44ab-9258-25e8af194279	9c22bc65-2479-4780-b3a0-0ed5e139ee5f	مستندسازی و نهایی‌سازی	240	31	2026-07-16	approved	328fce4c-c7e7-4b44-8dcb-45aad65bd8e5	\N	b488133c-2c60-4899-8d86-52f0d6820b7c	2026-07-20 09:59:26.363877+00	2026-07-20 09:59:26.363877+00
a03a787d-b998-4a31-aa2e-2aef31ab5784	d6657387-6096-497b-9a0b-781b8bbab764	328fce4c-c7e7-4b44-8dcb-45aad65bd8e5	تست و اطمینان از عملکرد صحیح	56	40	2026-07-16	approved	328fce4c-c7e7-4b44-8dcb-45aad65bd8e5	\N	170cb576-5524-4e28-b2fe-a73079d5e316	2026-07-20 09:59:26.363877+00	2026-07-20 09:59:26.363877+00
a03a787d-b998-4a31-aa2e-2aef31ab5784	b1f2b8bb-d944-439f-ac99-afe272d791ce	276feb60-37b2-42ff-be39-f9e79af8ae2a	پیشرفت اولیه و بررسی نیازمندی‌ها	145	28	2026-07-16	approved	328fce4c-c7e7-4b44-8dcb-45aad65bd8e5	\N	fb731630-8ab3-4b2a-b93d-8d057bf09739	2026-07-20 09:59:26.363877+00	2026-07-20 09:59:26.363877+00
a03a787d-b998-4a31-aa2e-2aef31ab5784	b1f2b8bb-d944-439f-ac99-afe272d791ce	276feb60-37b2-42ff-be39-f9e79af8ae2a	پیشرفت اولیه و بررسی نیازمندی‌ها	142	46	2026-07-16	approved	328fce4c-c7e7-4b44-8dcb-45aad65bd8e5	\N	a9d3543b-99f0-4f33-859d-154156b3b3ee	2026-07-20 09:59:26.363877+00	2026-07-20 09:59:26.363877+00
a03a787d-b998-4a31-aa2e-2aef31ab5784	5b95558f-9bde-478f-9a27-96756e679890	767b011b-ff3a-4faf-b85b-c424554a44a0	مستندسازی و نهایی‌سازی	206	31	2026-07-01	submitted	\N	\N	05a9da47-d7bb-4c9c-ad50-7bda26c8b7fe	2026-07-20 09:59:26.363877+00	2026-07-20 09:59:26.363877+00
a03a787d-b998-4a31-aa2e-2aef31ab5784	5b95558f-9bde-478f-9a27-96756e679890	767b011b-ff3a-4faf-b85b-c424554a44a0	پیاده‌سازی بخش اصلی	230	52	2026-07-05	approved	328fce4c-c7e7-4b44-8dcb-45aad65bd8e5	\N	203e1124-59c6-4fad-862a-96a83b4f88cc	2026-07-20 09:59:26.363877+00	2026-07-20 09:59:26.363877+00
a03a787d-b998-4a31-aa2e-2aef31ab5784	835843bc-e689-4451-803c-8b1c80fd7ee6	1775df44-8335-487a-9a3b-a1a6eb5949f5	مستندسازی و نهایی‌سازی	119	37	2026-07-04	approved	328fce4c-c7e7-4b44-8dcb-45aad65bd8e5	\N	e22683b4-936c-4bc0-8a43-83421aa1dc42	2026-07-20 09:59:26.363877+00	2026-07-20 09:59:26.363877+00
a03a787d-b998-4a31-aa2e-2aef31ab5784	835843bc-e689-4451-803c-8b1c80fd7ee6	1775df44-8335-487a-9a3b-a1a6eb5949f5	مستندسازی و نهایی‌سازی	167	50	2026-07-07	approved	328fce4c-c7e7-4b44-8dcb-45aad65bd8e5	\N	ef562c41-7951-4324-9519-bd8b830f5062	2026-07-20 09:59:26.363877+00	2026-07-20 09:59:26.363877+00
a03a787d-b998-4a31-aa2e-2aef31ab5784	3644e178-6228-4314-a56d-a28f63cc7fc6	328fce4c-c7e7-4b44-8dcb-45aad65bd8e5	رفع اشکالات و بازبینی	176	28	2026-07-16	approved	328fce4c-c7e7-4b44-8dcb-45aad65bd8e5	\N	aa75218b-e913-4fa4-b352-ef9a972390b1	2026-07-20 09:59:26.363877+00	2026-07-20 09:59:26.363877+00
a03a787d-b998-4a31-aa2e-2aef31ab5784	3644e178-6228-4314-a56d-a28f63cc7fc6	328fce4c-c7e7-4b44-8dcb-45aad65bd8e5	پیاده‌سازی بخش اصلی	222	66	2026-07-16	approved	328fce4c-c7e7-4b44-8dcb-45aad65bd8e5	\N	1e75f34e-db2d-4fff-8860-4407097335fc	2026-07-20 09:59:26.363877+00	2026-07-20 09:59:26.363877+00
a03a787d-b998-4a31-aa2e-2aef31ab5784	3644e178-6228-4314-a56d-a28f63cc7fc6	328fce4c-c7e7-4b44-8dcb-45aad65bd8e5	رفع اشکالات و بازبینی	197	72	2026-07-16	approved	328fce4c-c7e7-4b44-8dcb-45aad65bd8e5	\N	9fadac54-b552-4bd1-a30b-d2b23f7cad99	2026-07-20 09:59:26.363877+00	2026-07-20 09:59:26.363877+00
a03a787d-b998-4a31-aa2e-2aef31ab5784	c1e6700c-db11-4a96-a379-53ef14a78809	f2917b41-6f1c-4444-a73d-884a91e847fe	رفع اشکالات و بازبینی	93	32	2026-07-16	approved	328fce4c-c7e7-4b44-8dcb-45aad65bd8e5	\N	b79b1faa-deae-4252-abc4-a9482ab226f0	2026-07-20 09:59:26.363877+00	2026-07-20 09:59:26.363877+00
a03a787d-b998-4a31-aa2e-2aef31ab5784	c1e6700c-db11-4a96-a379-53ef14a78809	f2917b41-6f1c-4444-a73d-884a91e847fe	رفع اشکالات و بازبینی	190	66	2026-07-16	approved	328fce4c-c7e7-4b44-8dcb-45aad65bd8e5	\N	1b936855-e6f0-469d-ba46-b7fae4a40237	2026-07-20 09:59:26.363877+00	2026-07-20 09:59:26.363877+00
a03a787d-b998-4a31-aa2e-2aef31ab5784	081a1c29-6eb4-4a8a-8d20-70a7c844d562	c1eff56a-cf6f-4901-9c44-9063f53db8c8	پیشرفت اولیه و بررسی نیازمندی‌ها	133	36	2026-07-15	approved	328fce4c-c7e7-4b44-8dcb-45aad65bd8e5	\N	d7dfa742-f481-4d36-bfe8-5b715b8c9211	2026-07-20 09:59:26.363877+00	2026-07-20 09:59:26.363877+00
a03a787d-b998-4a31-aa2e-2aef31ab5784	081a1c29-6eb4-4a8a-8d20-70a7c844d562	c1eff56a-cf6f-4901-9c44-9063f53db8c8	رفع اشکالات و بازبینی	146	70	2026-07-16	approved	328fce4c-c7e7-4b44-8dcb-45aad65bd8e5	\N	d4cb3e4e-d078-411e-9736-e22e15e93589	2026-07-20 09:59:26.363877+00	2026-07-20 09:59:26.363877+00
a03a787d-b998-4a31-aa2e-2aef31ab5784	081a1c29-6eb4-4a8a-8d20-70a7c844d562	c1eff56a-cf6f-4901-9c44-9063f53db8c8	پیشرفت اولیه و بررسی نیازمندی‌ها	217	100	2026-07-16	approved	328fce4c-c7e7-4b44-8dcb-45aad65bd8e5	\N	8fbd3399-40b8-4fbe-9684-f7cb8c6cd383	2026-07-20 09:59:26.363877+00	2026-07-20 09:59:26.363877+00
a03a787d-b998-4a31-aa2e-2aef31ab5784	081a1c29-6eb4-4a8a-8d20-70a7c844d562	c1eff56a-cf6f-4901-9c44-9063f53db8c8	مستندسازی و نهایی‌سازی	131	100	2026-07-16	submitted	\N	\N	fb5c0bf7-649f-4791-9141-7520167e8c7a	2026-07-20 09:59:26.363877+00	2026-07-20 09:59:26.363877+00
a03a787d-b998-4a31-aa2e-2aef31ab5784	fae2d2e9-b1b2-4ab4-9f2e-07d1e8e04814	9c22bc65-2479-4780-b3a0-0ed5e139ee5f	رفع اشکالات و بازبینی	102	30	2026-06-28	approved	328fce4c-c7e7-4b44-8dcb-45aad65bd8e5	\N	6d9386db-41b5-48be-8d32-d5361e7afbb4	2026-07-20 09:59:26.363877+00	2026-07-20 09:59:26.363877+00
a03a787d-b998-4a31-aa2e-2aef31ab5784	fae2d2e9-b1b2-4ab4-9f2e-07d1e8e04814	9c22bc65-2479-4780-b3a0-0ed5e139ee5f	تست و اطمینان از عملکرد صحیح	231	60	2026-06-30	approved	328fce4c-c7e7-4b44-8dcb-45aad65bd8e5	\N	7cbb3620-1c12-4e4e-ab1f-f31855614c7b	2026-07-20 09:59:26.363877+00	2026-07-20 09:59:26.363877+00
a03a787d-b998-4a31-aa2e-2aef31ab5784	fae2d2e9-b1b2-4ab4-9f2e-07d1e8e04814	9c22bc65-2479-4780-b3a0-0ed5e139ee5f	تست و اطمینان از عملکرد صحیح	34	69	2026-06-30	approved	328fce4c-c7e7-4b44-8dcb-45aad65bd8e5	\N	a15b5d4c-4fe3-4f4c-a9e6-ff3f3edf7970	2026-07-20 09:59:26.363877+00	2026-07-20 09:59:26.363877+00
a03a787d-b998-4a31-aa2e-2aef31ab5784	fae2d2e9-b1b2-4ab4-9f2e-07d1e8e04814	9c22bc65-2479-4780-b3a0-0ed5e139ee5f	پیشرفت اولیه و بررسی نیازمندی‌ها	139	100	2026-07-04	approved	328fce4c-c7e7-4b44-8dcb-45aad65bd8e5	\N	b3650baf-4c5e-478b-bbd5-d278ce03c80f	2026-07-20 09:59:26.363877+00	2026-07-20 09:59:26.363877+00
a03a787d-b998-4a31-aa2e-2aef31ab5784	4cb43177-e012-428b-b7b6-0ae2e3586445	9c22bc65-2479-4780-b3a0-0ed5e139ee5f	پیاده‌سازی بخش اصلی	100	22	2026-06-24	approved	328fce4c-c7e7-4b44-8dcb-45aad65bd8e5	\N	afcdf078-a4ad-4c5e-8173-3d7d1e364397	2026-07-20 09:59:26.363877+00	2026-07-20 09:59:26.363877+00
a03a787d-b998-4a31-aa2e-2aef31ab5784	4cb43177-e012-428b-b7b6-0ae2e3586445	9c22bc65-2479-4780-b3a0-0ed5e139ee5f	رفع اشکالات و بازبینی	51	62	2026-06-27	approved	328fce4c-c7e7-4b44-8dcb-45aad65bd8e5	\N	ee00c28f-b207-406b-a73f-44551cf56b07	2026-07-20 09:59:26.363877+00	2026-07-20 09:59:26.363877+00
a03a787d-b998-4a31-aa2e-2aef31ab5784	b9c4e8e0-5509-4325-901e-535d71ac7b5e	9c22bc65-2479-4780-b3a0-0ed5e139ee5f	رفع اشکالات و بازبینی	215	27	2026-07-14	approved	328fce4c-c7e7-4b44-8dcb-45aad65bd8e5	\N	4ec94ed5-0a7c-424b-a6c0-b3c62b4b6982	2026-07-20 09:59:26.363877+00	2026-07-20 09:59:26.363877+00
a03a787d-b998-4a31-aa2e-2aef31ab5784	b9c4e8e0-5509-4325-901e-535d71ac7b5e	9c22bc65-2479-4780-b3a0-0ed5e139ee5f	پیشرفت اولیه و بررسی نیازمندی‌ها	30	52	2026-07-16	approved	328fce4c-c7e7-4b44-8dcb-45aad65bd8e5	\N	54dc4ff8-420b-432b-a6ed-4518efa5f10f	2026-07-20 09:59:26.363877+00	2026-07-20 09:59:26.363877+00
a03a787d-b998-4a31-aa2e-2aef31ab5784	735208bc-cde4-4522-8d7f-db62cf545fed	328fce4c-c7e7-4b44-8dcb-45aad65bd8e5	پیاده‌سازی بخش اصلی	162	34	2026-07-16	approved	328fce4c-c7e7-4b44-8dcb-45aad65bd8e5	\N	f4fdb319-8d2f-4ce4-b19f-40124a81064a	2026-07-20 09:59:26.363877+00	2026-07-20 09:59:26.363877+00
a03a787d-b998-4a31-aa2e-2aef31ab5784	735208bc-cde4-4522-8d7f-db62cf545fed	328fce4c-c7e7-4b44-8dcb-45aad65bd8e5	رفع اشکالات و بازبینی	239	46	2026-07-16	approved	328fce4c-c7e7-4b44-8dcb-45aad65bd8e5	\N	d1d3e6fa-6475-40e6-aaf1-3cd14018d4fd	2026-07-20 09:59:26.363877+00	2026-07-20 09:59:26.363877+00
a03a787d-b998-4a31-aa2e-2aef31ab5784	735208bc-cde4-4522-8d7f-db62cf545fed	328fce4c-c7e7-4b44-8dcb-45aad65bd8e5	تست و اطمینان از عملکرد صحیح	48	81	2026-07-16	approved	328fce4c-c7e7-4b44-8dcb-45aad65bd8e5	\N	0d5ddf65-5466-4001-ae99-265988f60066	2026-07-20 09:59:26.363877+00	2026-07-20 09:59:26.363877+00
a03a787d-b998-4a31-aa2e-2aef31ab5784	735208bc-cde4-4522-8d7f-db62cf545fed	328fce4c-c7e7-4b44-8dcb-45aad65bd8e5	پیشرفت اولیه و بررسی نیازمندی‌ها	56	100	2026-07-16	approved	328fce4c-c7e7-4b44-8dcb-45aad65bd8e5	\N	91e2638b-c870-4d1f-9c93-64d07fd58975	2026-07-20 09:59:26.363877+00	2026-07-20 09:59:26.363877+00
a03a787d-b998-4a31-aa2e-2aef31ab5784	ad170516-00e3-4ac5-b52c-636892b3334f	9c22bc65-2479-4780-b3a0-0ed5e139ee5f	پیاده‌سازی بخش اصلی	194	24	2026-06-26	approved	328fce4c-c7e7-4b44-8dcb-45aad65bd8e5	\N	2c149c61-8990-4688-a7da-0ce8d2b54901	2026-07-20 09:59:26.363877+00	2026-07-20 09:59:26.363877+00
a03a787d-b998-4a31-aa2e-2aef31ab5784	ad170516-00e3-4ac5-b52c-636892b3334f	9c22bc65-2479-4780-b3a0-0ed5e139ee5f	پیشرفت اولیه و بررسی نیازمندی‌ها	186	80	2026-06-27	approved	328fce4c-c7e7-4b44-8dcb-45aad65bd8e5	\N	4944a89f-e60f-4d2f-9d66-f2ddf117e2e0	2026-07-20 09:59:26.363877+00	2026-07-20 09:59:26.363877+00
a03a787d-b998-4a31-aa2e-2aef31ab5784	ad170516-00e3-4ac5-b52c-636892b3334f	9c22bc65-2479-4780-b3a0-0ed5e139ee5f	پیاده‌سازی بخش اصلی	190	72	2026-06-30	approved	328fce4c-c7e7-4b44-8dcb-45aad65bd8e5	\N	b510c593-9d7e-4711-a2e1-ea5319eea830	2026-07-20 09:59:26.363877+00	2026-07-20 09:59:26.363877+00
a03a787d-b998-4a31-aa2e-2aef31ab5784	a10ca374-4d8c-4d32-86c5-7219b483859a	f2917b41-6f1c-4444-a73d-884a91e847fe	پیشرفت اولیه و بررسی نیازمندی‌ها	55	24	2026-07-09	submitted	\N	\N	aaced1df-c010-440c-a302-321c1cea6d54	2026-07-20 09:59:26.363877+00	2026-07-20 09:59:26.363877+00
a03a787d-b998-4a31-aa2e-2aef31ab5784	a10ca374-4d8c-4d32-86c5-7219b483859a	f2917b41-6f1c-4444-a73d-884a91e847fe	تست و اطمینان از عملکرد صحیح	119	66	2026-07-10	approved	328fce4c-c7e7-4b44-8dcb-45aad65bd8e5	\N	59097617-bbef-4d6f-ad12-3a231bdd73d5	2026-07-20 09:59:26.363877+00	2026-07-20 09:59:26.363877+00
a03a787d-b998-4a31-aa2e-2aef31ab5784	a10ca374-4d8c-4d32-86c5-7219b483859a	f2917b41-6f1c-4444-a73d-884a91e847fe	پیاده‌سازی بخش اصلی	100	100	2026-07-15	submitted	\N	\N	149960ff-e411-4753-970c-f1783167f5e3	2026-07-20 09:59:26.363877+00	2026-07-20 09:59:26.363877+00
a03a787d-b998-4a31-aa2e-2aef31ab5784	a10ca374-4d8c-4d32-86c5-7219b483859a	f2917b41-6f1c-4444-a73d-884a91e847fe	مستندسازی و نهایی‌سازی	183	100	2026-07-12	approved	328fce4c-c7e7-4b44-8dcb-45aad65bd8e5	\N	84eac6c1-6570-4685-b8bc-4073f960fd23	2026-07-20 09:59:26.363877+00	2026-07-20 09:59:26.363877+00
a03a787d-b998-4a31-aa2e-2aef31ab5784	c40a8535-1126-43a2-acaa-6803c4f7e5d3	9c22bc65-2479-4780-b3a0-0ed5e139ee5f	رفع اشکالات و بازبینی	82	36	2026-07-16	approved	328fce4c-c7e7-4b44-8dcb-45aad65bd8e5	\N	5a2c2f91-cd18-4699-aaff-96335bb8d01b	2026-07-20 09:59:26.363877+00	2026-07-20 09:59:26.363877+00
a03a787d-b998-4a31-aa2e-2aef31ab5784	c40a8535-1126-43a2-acaa-6803c4f7e5d3	9c22bc65-2479-4780-b3a0-0ed5e139ee5f	تست و اطمینان از عملکرد صحیح	105	80	2026-07-16	approved	328fce4c-c7e7-4b44-8dcb-45aad65bd8e5	\N	13f0d3d0-840b-4f88-84da-308e80780fd5	2026-07-20 09:59:26.363877+00	2026-07-20 09:59:26.363877+00
a03a787d-b998-4a31-aa2e-2aef31ab5784	c40a8535-1126-43a2-acaa-6803c4f7e5d3	9c22bc65-2479-4780-b3a0-0ed5e139ee5f	پیاده‌سازی بخش اصلی	156	96	2026-07-16	approved	328fce4c-c7e7-4b44-8dcb-45aad65bd8e5	\N	870e56e3-21e5-4bad-8091-dc8b38c579b0	2026-07-20 09:59:26.363877+00	2026-07-20 09:59:26.363877+00
a03a787d-b998-4a31-aa2e-2aef31ab5784	fed5f6fb-8c42-4b24-ba08-0f30ef139073	276feb60-37b2-42ff-be39-f9e79af8ae2a	تست و اطمینان از عملکرد صحیح	193	39	2026-07-16	approved	328fce4c-c7e7-4b44-8dcb-45aad65bd8e5	\N	150bb194-2768-404b-9344-9ded3d1b4be4	2026-07-20 09:59:26.363877+00	2026-07-20 09:59:26.363877+00
a03a787d-b998-4a31-aa2e-2aef31ab5784	617e31ab-6faa-4a51-a9b0-a98ef40e2656	9c22bc65-2479-4780-b3a0-0ed5e139ee5f	رفع اشکالات و بازبینی	111	24	2026-07-16	approved	328fce4c-c7e7-4b44-8dcb-45aad65bd8e5	\N	a84f0fa2-9b39-426d-a3a0-31740d354583	2026-07-20 09:59:26.363877+00	2026-07-20 09:59:26.363877+00
a03a787d-b998-4a31-aa2e-2aef31ab5784	d5fc9267-1f2b-4bf1-af59-7615e47abdab	9c22bc65-2479-4780-b3a0-0ed5e139ee5f	پیاده‌سازی بخش اصلی	225	35	2026-07-16	approved	328fce4c-c7e7-4b44-8dcb-45aad65bd8e5	\N	20eb5f05-a374-4b67-bffb-c7de046ca46f	2026-07-20 09:59:26.363877+00	2026-07-20 09:59:26.363877+00
a03a787d-b998-4a31-aa2e-2aef31ab5784	d5fc9267-1f2b-4bf1-af59-7615e47abdab	9c22bc65-2479-4780-b3a0-0ed5e139ee5f	پیشرفت اولیه و بررسی نیازمندی‌ها	33	56	2026-07-16	approved	328fce4c-c7e7-4b44-8dcb-45aad65bd8e5	\N	479d780f-ad92-43df-925a-3a36d6448df1	2026-07-20 09:59:26.363877+00	2026-07-20 09:59:26.363877+00
a03a787d-b998-4a31-aa2e-2aef31ab5784	d5fc9267-1f2b-4bf1-af59-7615e47abdab	9c22bc65-2479-4780-b3a0-0ed5e139ee5f	پیشرفت اولیه و بررسی نیازمندی‌ها	232	96	2026-07-16	approved	328fce4c-c7e7-4b44-8dcb-45aad65bd8e5	\N	f2f71306-997b-4b2d-8e6f-47ec567d61b6	2026-07-20 09:59:26.363877+00	2026-07-20 09:59:26.363877+00
a03a787d-b998-4a31-aa2e-2aef31ab5784	d5fc9267-1f2b-4bf1-af59-7615e47abdab	9c22bc65-2479-4780-b3a0-0ed5e139ee5f	مستندسازی و نهایی‌سازی	226	100	2026-07-16	approved	328fce4c-c7e7-4b44-8dcb-45aad65bd8e5	\N	e93f254a-13e7-49c9-8806-e185bdfdf0fd	2026-07-20 09:59:26.363877+00	2026-07-20 09:59:26.363877+00
a03a787d-b998-4a31-aa2e-2aef31ab5784	942036ff-c665-46ca-81eb-1d50d7b9e600	9c22bc65-2479-4780-b3a0-0ed5e139ee5f	مستندسازی و نهایی‌سازی	167	39	2026-07-16	approved	328fce4c-c7e7-4b44-8dcb-45aad65bd8e5	\N	53b34941-b228-44c8-a3f1-3b7b614d81c3	2026-07-20 09:59:26.363877+00	2026-07-20 09:59:26.363877+00
a03a787d-b998-4a31-aa2e-2aef31ab5784	942036ff-c665-46ca-81eb-1d50d7b9e600	9c22bc65-2479-4780-b3a0-0ed5e139ee5f	رفع اشکالات و بازبینی	50	72	2026-07-16	approved	328fce4c-c7e7-4b44-8dcb-45aad65bd8e5	\N	4d619186-b352-474c-950e-38e544cafc5c	2026-07-20 09:59:26.363877+00	2026-07-20 09:59:26.363877+00
a03a787d-b998-4a31-aa2e-2aef31ab5784	942036ff-c665-46ca-81eb-1d50d7b9e600	9c22bc65-2479-4780-b3a0-0ed5e139ee5f	پیاده‌سازی بخش اصلی	167	90	2026-07-16	submitted	\N	\N	7fffb7cb-7800-4bda-81fc-590742ed2b49	2026-07-20 09:59:26.363877+00	2026-07-20 09:59:26.363877+00
a03a787d-b998-4a31-aa2e-2aef31ab5784	942036ff-c665-46ca-81eb-1d50d7b9e600	9c22bc65-2479-4780-b3a0-0ed5e139ee5f	پیشرفت اولیه و بررسی نیازمندی‌ها	109	100	2026-07-16	approved	328fce4c-c7e7-4b44-8dcb-45aad65bd8e5	\N	bf5189e0-3b32-41e1-896f-c7566c985560	2026-07-20 09:59:26.363877+00	2026-07-20 09:59:26.363877+00
a03a787d-b998-4a31-aa2e-2aef31ab5784	688cc48e-af22-4da4-be66-5202ca6c27aa	9c22bc65-2479-4780-b3a0-0ed5e139ee5f	پیاده‌سازی بخش اصلی	52	33	2026-07-16	approved	328fce4c-c7e7-4b44-8dcb-45aad65bd8e5	\N	e44a8708-f27f-4926-a347-48977d75b95c	2026-07-20 09:59:26.363877+00	2026-07-20 09:59:26.363877+00
a03a787d-b998-4a31-aa2e-2aef31ab5784	688cc48e-af22-4da4-be66-5202ca6c27aa	9c22bc65-2479-4780-b3a0-0ed5e139ee5f	تست و اطمینان از عملکرد صحیح	186	78	2026-07-16	approved	328fce4c-c7e7-4b44-8dcb-45aad65bd8e5	\N	f7af8992-f38a-477d-97c1-049025664cb4	2026-07-20 09:59:26.363877+00	2026-07-20 09:59:26.363877+00
a03a787d-b998-4a31-aa2e-2aef31ab5784	9111fae1-c6be-4d1c-a7b1-c5418c69c58a	f2917b41-6f1c-4444-a73d-884a91e847fe	پیاده‌سازی بخش اصلی	60	20	2026-07-16	approved	328fce4c-c7e7-4b44-8dcb-45aad65bd8e5	\N	730f9798-f07e-4041-8623-13aa9b956eae	2026-07-20 09:59:26.363877+00	2026-07-20 09:59:26.363877+00
a03a787d-b998-4a31-aa2e-2aef31ab5784	d7613dd6-a4d8-414b-a8a1-e8bd9a3d15f5	9c22bc65-2479-4780-b3a0-0ed5e139ee5f	پیاده‌سازی بخش اصلی	157	31	2026-06-30	approved	328fce4c-c7e7-4b44-8dcb-45aad65bd8e5	\N	ccdcb451-1609-4cb1-98c7-2caec92c4642	2026-07-20 09:59:26.363877+00	2026-07-20 09:59:26.363877+00
a03a787d-b998-4a31-aa2e-2aef31ab5784	d7613dd6-a4d8-414b-a8a1-e8bd9a3d15f5	9c22bc65-2479-4780-b3a0-0ed5e139ee5f	پیاده‌سازی بخش اصلی	125	48	2026-07-03	approved	328fce4c-c7e7-4b44-8dcb-45aad65bd8e5	\N	cc4874f0-7eab-4047-aa1a-3bc40bdab178	2026-07-20 09:59:26.363877+00	2026-07-20 09:59:26.363877+00
a03a787d-b998-4a31-aa2e-2aef31ab5784	045ab9b7-ba72-4f57-a64f-92165c4debd6	9c22bc65-2479-4780-b3a0-0ed5e139ee5f	پیشرفت اولیه و بررسی نیازمندی‌ها	115	33	2026-07-13	approved	328fce4c-c7e7-4b44-8dcb-45aad65bd8e5	\N	1c8487f5-344f-4c7e-91e6-bfd6bb620308	2026-07-20 09:59:26.363877+00	2026-07-20 09:59:26.363877+00
a03a787d-b998-4a31-aa2e-2aef31ab5784	045ab9b7-ba72-4f57-a64f-92165c4debd6	9c22bc65-2479-4780-b3a0-0ed5e139ee5f	مستندسازی و نهایی‌سازی	46	56	2026-07-16	approved	328fce4c-c7e7-4b44-8dcb-45aad65bd8e5	\N	c5cd9ce8-c262-47a8-9170-ee1df17922d5	2026-07-20 09:59:26.363877+00	2026-07-20 09:59:26.363877+00
a03a787d-b998-4a31-aa2e-2aef31ab5784	045ab9b7-ba72-4f57-a64f-92165c4debd6	9c22bc65-2479-4780-b3a0-0ed5e139ee5f	تست و اطمینان از عملکرد صحیح	146	100	2026-07-15	approved	328fce4c-c7e7-4b44-8dcb-45aad65bd8e5	\N	dd7b6c8c-0a4e-41b8-a316-e0b7e832c5c8	2026-07-20 09:59:26.363877+00	2026-07-20 09:59:26.363877+00
a03a787d-b998-4a31-aa2e-2aef31ab5784	761c4a67-db89-428f-b8d2-e4dc05ab623f	f2917b41-6f1c-4444-a73d-884a91e847fe	مستندسازی و نهایی‌سازی	72	31	2026-07-16	approved	328fce4c-c7e7-4b44-8dcb-45aad65bd8e5	\N	6131621d-f0c1-4995-9269-19630aa1aa00	2026-07-20 09:59:26.363877+00	2026-07-20 09:59:26.363877+00
a03a787d-b998-4a31-aa2e-2aef31ab5784	761c4a67-db89-428f-b8d2-e4dc05ab623f	f2917b41-6f1c-4444-a73d-884a91e847fe	پیشرفت اولیه و بررسی نیازمندی‌ها	176	46	2026-07-16	approved	328fce4c-c7e7-4b44-8dcb-45aad65bd8e5	\N	25b0c26e-ffb0-44aa-89f1-a1d9e8c5f07c	2026-07-20 09:59:26.363877+00	2026-07-20 09:59:26.363877+00
a03a787d-b998-4a31-aa2e-2aef31ab5784	761c4a67-db89-428f-b8d2-e4dc05ab623f	f2917b41-6f1c-4444-a73d-884a91e847fe	پیشرفت اولیه و بررسی نیازمندی‌ها	41	60	2026-07-16	submitted	\N	\N	4213a3e9-a5e6-435e-a637-802799df05c6	2026-07-20 09:59:26.363877+00	2026-07-20 09:59:26.363877+00
a03a787d-b998-4a31-aa2e-2aef31ab5784	21250fd6-d304-42cf-9786-a0ef30e7b447	328fce4c-c7e7-4b44-8dcb-45aad65bd8e5	تست و اطمینان از عملکرد صحیح	123	32	2026-07-16	approved	328fce4c-c7e7-4b44-8dcb-45aad65bd8e5	\N	eeb42d28-8955-4ae4-ab22-b67880b938dc	2026-07-20 09:59:26.363877+00	2026-07-20 09:59:26.363877+00
a03a787d-b998-4a31-aa2e-2aef31ab5784	21250fd6-d304-42cf-9786-a0ef30e7b447	328fce4c-c7e7-4b44-8dcb-45aad65bd8e5	پیاده‌سازی بخش اصلی	39	74	2026-07-16	approved	328fce4c-c7e7-4b44-8dcb-45aad65bd8e5	\N	bac77009-1cbc-42c8-93b7-eceeae0d4976	2026-07-20 09:59:26.363877+00	2026-07-20 09:59:26.363877+00
a03a787d-b998-4a31-aa2e-2aef31ab5784	b3e452a1-5b75-48be-aec5-a96f6eafd97f	9c22bc65-2479-4780-b3a0-0ed5e139ee5f	تست و اطمینان از عملکرد صحیح	214	30	2026-07-16	approved	328fce4c-c7e7-4b44-8dcb-45aad65bd8e5	\N	6ddd441c-9b7c-4262-aa10-78e1aa324618	2026-07-20 09:59:26.363877+00	2026-07-20 09:59:26.363877+00
a03a787d-b998-4a31-aa2e-2aef31ab5784	b3e452a1-5b75-48be-aec5-a96f6eafd97f	9c22bc65-2479-4780-b3a0-0ed5e139ee5f	مستندسازی و نهایی‌سازی	125	46	2026-07-16	submitted	\N	\N	4b8d6b4c-e7cf-44a4-b373-1aaf634cd59d	2026-07-20 09:59:26.363877+00	2026-07-20 09:59:26.363877+00
a03a787d-b998-4a31-aa2e-2aef31ab5784	b3e452a1-5b75-48be-aec5-a96f6eafd97f	9c22bc65-2479-4780-b3a0-0ed5e139ee5f	مستندسازی و نهایی‌سازی	41	96	2026-07-16	approved	328fce4c-c7e7-4b44-8dcb-45aad65bd8e5	\N	d71a99fd-affc-4a1a-a6df-fe02104bf0cc	2026-07-20 09:59:26.363877+00	2026-07-20 09:59:26.363877+00
a03a787d-b998-4a31-aa2e-2aef31ab5784	b3e452a1-5b75-48be-aec5-a96f6eafd97f	9c22bc65-2479-4780-b3a0-0ed5e139ee5f	رفع اشکالات و بازبینی	228	100	2026-07-16	submitted	\N	\N	2b3756a9-a5ae-4994-815c-76424c5b1225	2026-07-20 09:59:26.363877+00	2026-07-20 09:59:26.363877+00
a03a787d-b998-4a31-aa2e-2aef31ab5784	3568c190-33f6-4754-8c1e-1a5a90a2656b	c1eff56a-cf6f-4901-9c44-9063f53db8c8	پیشرفت اولیه و بررسی نیازمندی‌ها	124	26	2026-07-16	approved	328fce4c-c7e7-4b44-8dcb-45aad65bd8e5	\N	fc1dee3a-51d7-44d6-911a-40046b5c1608	2026-07-20 09:59:26.363877+00	2026-07-20 09:59:26.363877+00
a03a787d-b998-4a31-aa2e-2aef31ab5784	3568c190-33f6-4754-8c1e-1a5a90a2656b	c1eff56a-cf6f-4901-9c44-9063f53db8c8	رفع اشکالات و بازبینی	219	78	2026-07-16	approved	328fce4c-c7e7-4b44-8dcb-45aad65bd8e5	\N	f04e210d-99e3-450d-b009-0e0f53a692db	2026-07-20 09:59:26.363877+00	2026-07-20 09:59:26.363877+00
a03a787d-b998-4a31-aa2e-2aef31ab5784	3568c190-33f6-4754-8c1e-1a5a90a2656b	c1eff56a-cf6f-4901-9c44-9063f53db8c8	مستندسازی و نهایی‌سازی	156	78	2026-07-16	approved	328fce4c-c7e7-4b44-8dcb-45aad65bd8e5	\N	5be3665a-117d-4d27-8f3b-fd182f1a0f5b	2026-07-20 09:59:26.363877+00	2026-07-20 09:59:26.363877+00
a03a787d-b998-4a31-aa2e-2aef31ab5784	4acf5c94-5b6e-43a9-af45-e3f30e0a141c	276feb60-37b2-42ff-be39-f9e79af8ae2a	تست و اطمینان از عملکرد صحیح	36	27	2026-07-01	approved	328fce4c-c7e7-4b44-8dcb-45aad65bd8e5	\N	938769a3-5a66-4781-a55f-2a485e002075	2026-07-20 09:59:26.363877+00	2026-07-20 09:59:26.363877+00
a03a787d-b998-4a31-aa2e-2aef31ab5784	4acf5c94-5b6e-43a9-af45-e3f30e0a141c	276feb60-37b2-42ff-be39-f9e79af8ae2a	پیشرفت اولیه و بررسی نیازمندی‌ها	115	40	2026-07-04	approved	328fce4c-c7e7-4b44-8dcb-45aad65bd8e5	\N	cf9ec7ad-7b5c-4187-bdc5-406b0125532b	2026-07-20 09:59:26.363877+00	2026-07-20 09:59:26.363877+00
a03a787d-b998-4a31-aa2e-2aef31ab5784	b5537274-fac4-499b-9b4b-4b2a7ec3f207	c1eff56a-cf6f-4901-9c44-9063f53db8c8	مستندسازی و نهایی‌سازی	90	33	2026-06-19	approved	328fce4c-c7e7-4b44-8dcb-45aad65bd8e5	\N	1848bf04-220c-441c-9fa4-2d76bff65450	2026-07-20 09:59:26.363877+00	2026-07-20 09:59:26.363877+00
a03a787d-b998-4a31-aa2e-2aef31ab5784	b5537274-fac4-499b-9b4b-4b2a7ec3f207	c1eff56a-cf6f-4901-9c44-9063f53db8c8	پیاده‌سازی بخش اصلی	212	56	2026-06-23	submitted	\N	\N	ecee482c-680c-479b-b5b4-f42b0daabcae	2026-07-20 09:59:26.363877+00	2026-07-20 09:59:26.363877+00
a03a787d-b998-4a31-aa2e-2aef31ab5784	b5537274-fac4-499b-9b4b-4b2a7ec3f207	c1eff56a-cf6f-4901-9c44-9063f53db8c8	پیاده‌سازی بخش اصلی	163	99	2026-06-21	approved	328fce4c-c7e7-4b44-8dcb-45aad65bd8e5	\N	70eb9182-b09f-4eb6-8be0-cf3b87559e8d	2026-07-20 09:59:26.363877+00	2026-07-20 09:59:26.363877+00
a03a787d-b998-4a31-aa2e-2aef31ab5784	b5537274-fac4-499b-9b4b-4b2a7ec3f207	c1eff56a-cf6f-4901-9c44-9063f53db8c8	پیشرفت اولیه و بررسی نیازمندی‌ها	178	92	2026-06-28	approved	328fce4c-c7e7-4b44-8dcb-45aad65bd8e5	\N	0516a99f-e128-485e-ab51-33c7b13666e7	2026-07-20 09:59:26.363877+00	2026-07-20 09:59:26.363877+00
a03a787d-b998-4a31-aa2e-2aef31ab5784	27a29d91-4946-45b2-9fd9-58abf2939046	9c22bc65-2479-4780-b3a0-0ed5e139ee5f	پیشرفت اولیه و بررسی نیازمندی‌ها	181	38	2026-07-08	approved	328fce4c-c7e7-4b44-8dcb-45aad65bd8e5	\N	4604f6ac-f3a9-4ca8-93ca-23847aaca1a6	2026-07-20 09:59:26.363877+00	2026-07-20 09:59:26.363877+00
a03a787d-b998-4a31-aa2e-2aef31ab5784	27a29d91-4946-45b2-9fd9-58abf2939046	9c22bc65-2479-4780-b3a0-0ed5e139ee5f	تست و اطمینان از عملکرد صحیح	199	48	2026-07-09	approved	328fce4c-c7e7-4b44-8dcb-45aad65bd8e5	\N	d035ef6d-3872-42c3-ab3f-620dc8b0e4ca	2026-07-20 09:59:26.363877+00	2026-07-20 09:59:26.363877+00
a03a787d-b998-4a31-aa2e-2aef31ab5784	7de590b3-9d64-4ad4-b221-d1cdaa7338f9	9c22bc65-2479-4780-b3a0-0ed5e139ee5f	رفع اشکالات و بازبینی	235	32	2026-06-25	approved	328fce4c-c7e7-4b44-8dcb-45aad65bd8e5	\N	3cb7e3da-a99e-4844-8f10-c7295ce09dd3	2026-07-20 09:59:26.363877+00	2026-07-20 09:59:26.363877+00
a03a787d-b998-4a31-aa2e-2aef31ab5784	7de590b3-9d64-4ad4-b221-d1cdaa7338f9	9c22bc65-2479-4780-b3a0-0ed5e139ee5f	رفع اشکالات و بازبینی	89	44	2026-06-28	approved	328fce4c-c7e7-4b44-8dcb-45aad65bd8e5	\N	3713b9d4-044a-4868-8eb5-f1924b7c9435	2026-07-20 09:59:26.363877+00	2026-07-20 09:59:26.363877+00
a03a787d-b998-4a31-aa2e-2aef31ab5784	5043dea2-91e6-4ec8-9cd1-e99267ebac5d	276feb60-37b2-42ff-be39-f9e79af8ae2a	مستندسازی و نهایی‌سازی	57	24	2026-07-05	submitted	\N	\N	e4cdff85-1cf7-4885-96fd-d746d38e85ef	2026-07-20 09:59:26.363877+00	2026-07-20 09:59:26.363877+00
a03a787d-b998-4a31-aa2e-2aef31ab5784	5043dea2-91e6-4ec8-9cd1-e99267ebac5d	276feb60-37b2-42ff-be39-f9e79af8ae2a	تست و اطمینان از عملکرد صحیح	110	66	2026-07-06	approved	328fce4c-c7e7-4b44-8dcb-45aad65bd8e5	\N	8166fe05-6cb0-4468-8ae5-ae98cd16a3bd	2026-07-20 09:59:26.363877+00	2026-07-20 09:59:26.363877+00
a03a787d-b998-4a31-aa2e-2aef31ab5784	a23ff4ba-cbfc-4ab4-b91b-5cab6bb189a1	9c22bc65-2479-4780-b3a0-0ed5e139ee5f	پیاده‌سازی بخش اصلی	145	29	2026-07-10	approved	328fce4c-c7e7-4b44-8dcb-45aad65bd8e5	\N	01110f92-9032-4386-a3b8-eeac3f78d35c	2026-07-20 09:59:26.363877+00	2026-07-20 09:59:26.363877+00
a03a787d-b998-4a31-aa2e-2aef31ab5784	3294a6f3-ecb6-4950-bc90-299dab897cb4	328fce4c-c7e7-4b44-8dcb-45aad65bd8e5	پیشرفت اولیه و بررسی نیازمندی‌ها	53	25	2026-06-21	approved	328fce4c-c7e7-4b44-8dcb-45aad65bd8e5	\N	5418b37a-903c-4462-93cd-5634e44f4558	2026-07-20 09:59:26.363877+00	2026-07-20 09:59:26.363877+00
a03a787d-b998-4a31-aa2e-2aef31ab5784	3294a6f3-ecb6-4950-bc90-299dab897cb4	328fce4c-c7e7-4b44-8dcb-45aad65bd8e5	مستندسازی و نهایی‌سازی	40	52	2026-06-24	approved	328fce4c-c7e7-4b44-8dcb-45aad65bd8e5	\N	a399340b-797f-4137-9a8e-d85032080b77	2026-07-20 09:59:26.363877+00	2026-07-20 09:59:26.363877+00
a03a787d-b998-4a31-aa2e-2aef31ab5784	3294a6f3-ecb6-4950-bc90-299dab897cb4	328fce4c-c7e7-4b44-8dcb-45aad65bd8e5	پیاده‌سازی بخش اصلی	53	81	2026-06-27	approved	328fce4c-c7e7-4b44-8dcb-45aad65bd8e5	\N	42f9497a-1a51-4e2a-90ee-d3a7970388f7	2026-07-20 09:59:26.363877+00	2026-07-20 09:59:26.363877+00
a03a787d-b998-4a31-aa2e-2aef31ab5784	3294a6f3-ecb6-4950-bc90-299dab897cb4	328fce4c-c7e7-4b44-8dcb-45aad65bd8e5	تست و اطمینان از عملکرد صحیح	161	84	2026-06-30	approved	328fce4c-c7e7-4b44-8dcb-45aad65bd8e5	\N	676d7b8f-5d4b-4fb3-933a-a98d18546e32	2026-07-20 09:59:26.363877+00	2026-07-20 09:59:26.363877+00
a03a787d-b998-4a31-aa2e-2aef31ab5784	ee961817-be5f-4bc6-9e24-48a354dbea4e	9c22bc65-2479-4780-b3a0-0ed5e139ee5f	پیاده‌سازی بخش اصلی	37	32	2026-06-18	approved	328fce4c-c7e7-4b44-8dcb-45aad65bd8e5	\N	37bb3bb9-201d-4267-b8db-2560bf43df65	2026-07-20 09:59:26.363877+00	2026-07-20 09:59:26.363877+00
a03a787d-b998-4a31-aa2e-2aef31ab5784	ee961817-be5f-4bc6-9e24-48a354dbea4e	9c22bc65-2479-4780-b3a0-0ed5e139ee5f	مستندسازی و نهایی‌سازی	221	74	2026-06-22	approved	328fce4c-c7e7-4b44-8dcb-45aad65bd8e5	\N	c89b8ffa-5287-481f-8ee4-5b23a993df6e	2026-07-20 09:59:26.363877+00	2026-07-20 09:59:26.363877+00
a03a787d-b998-4a31-aa2e-2aef31ab5784	ee961817-be5f-4bc6-9e24-48a354dbea4e	9c22bc65-2479-4780-b3a0-0ed5e139ee5f	پیشرفت اولیه و بررسی نیازمندی‌ها	148	69	2026-06-22	approved	328fce4c-c7e7-4b44-8dcb-45aad65bd8e5	\N	4e96271e-c6eb-43b4-81b8-6dcf8ed97c15	2026-07-20 09:59:26.363877+00	2026-07-20 09:59:26.363877+00
a03a787d-b998-4a31-aa2e-2aef31ab5784	30f8f142-9098-4a97-a5ec-f1e93c2ac3e7	767b011b-ff3a-4faf-b85b-c424554a44a0	پیاده‌سازی بخش اصلی	63	26	2026-07-16	approved	328fce4c-c7e7-4b44-8dcb-45aad65bd8e5	\N	77a144f2-7cf0-4e39-94f7-db2c85713fc3	2026-07-20 09:59:26.363877+00	2026-07-20 09:59:26.363877+00
a03a787d-b998-4a31-aa2e-2aef31ab5784	30f8f142-9098-4a97-a5ec-f1e93c2ac3e7	767b011b-ff3a-4faf-b85b-c424554a44a0	پیشرفت اولیه و بررسی نیازمندی‌ها	179	76	2026-07-16	approved	328fce4c-c7e7-4b44-8dcb-45aad65bd8e5	\N	32d7f5ae-afb1-4945-bc2e-cdd1fad1a72f	2026-07-20 09:59:26.363877+00	2026-07-20 09:59:26.363877+00
a03a787d-b998-4a31-aa2e-2aef31ab5784	93c969b1-ebb9-4c67-865c-17acb575df5e	487a4011-366a-4e1c-ac4d-6f24e62436c6	پیاده‌سازی بخش اصلی	114	28	2026-07-16	approved	487a4011-366a-4e1c-ac4d-6f24e62436c6	\N	1c0d1839-4e51-401f-b160-24c2989e4181	2026-07-20 09:59:26.363877+00	2026-07-20 09:59:26.363877+00
a03a787d-b998-4a31-aa2e-2aef31ab5784	93c969b1-ebb9-4c67-865c-17acb575df5e	487a4011-366a-4e1c-ac4d-6f24e62436c6	مستندسازی و نهایی‌سازی	87	74	2026-07-16	approved	487a4011-366a-4e1c-ac4d-6f24e62436c6	\N	9db9293f-7cad-4fda-a4b0-5fa27d56de90	2026-07-20 09:59:26.363877+00	2026-07-20 09:59:26.363877+00
a03a787d-b998-4a31-aa2e-2aef31ab5784	93c969b1-ebb9-4c67-865c-17acb575df5e	487a4011-366a-4e1c-ac4d-6f24e62436c6	تست و اطمینان از عملکرد صحیح	239	81	2026-07-16	approved	487a4011-366a-4e1c-ac4d-6f24e62436c6	\N	2d0a8afc-8de5-4d97-8001-31ab7b1f996e	2026-07-20 09:59:26.363877+00	2026-07-20 09:59:26.363877+00
a03a787d-b998-4a31-aa2e-2aef31ab5784	93c969b1-ebb9-4c67-865c-17acb575df5e	487a4011-366a-4e1c-ac4d-6f24e62436c6	تست و اطمینان از عملکرد صحیح	143	100	2026-07-16	approved	487a4011-366a-4e1c-ac4d-6f24e62436c6	\N	afc4575c-fea1-4aa9-87cd-330d681cdf9a	2026-07-20 09:59:26.363877+00	2026-07-20 09:59:26.363877+00
a03a787d-b998-4a31-aa2e-2aef31ab5784	f57490cb-c52c-4ede-8249-aca5e61165f1	8eb048e0-49b1-4d8a-9e1f-ab534f5d1564	تست و اطمینان از عملکرد صحیح	144	30	2026-06-27	approved	487a4011-366a-4e1c-ac4d-6f24e62436c6	\N	208d9864-2784-4111-80d8-d5be19110c62	2026-07-20 09:59:26.363877+00	2026-07-20 09:59:26.363877+00
a03a787d-b998-4a31-aa2e-2aef31ab5784	f57490cb-c52c-4ede-8249-aca5e61165f1	8eb048e0-49b1-4d8a-9e1f-ab534f5d1564	تست و اطمینان از عملکرد صحیح	220	80	2026-06-28	approved	487a4011-366a-4e1c-ac4d-6f24e62436c6	\N	13fc1ba1-7091-4e70-8f63-73fc18b566bd	2026-07-20 09:59:26.363877+00	2026-07-20 09:59:26.363877+00
a03a787d-b998-4a31-aa2e-2aef31ab5784	f57490cb-c52c-4ede-8249-aca5e61165f1	8eb048e0-49b1-4d8a-9e1f-ab534f5d1564	پیشرفت اولیه و بررسی نیازمندی‌ها	133	99	2026-06-29	approved	487a4011-366a-4e1c-ac4d-6f24e62436c6	\N	c2df7bc4-c65e-4ce0-a5d4-4ae3fc7a5790	2026-07-20 09:59:26.363877+00	2026-07-20 09:59:26.363877+00
a03a787d-b998-4a31-aa2e-2aef31ab5784	f57490cb-c52c-4ede-8249-aca5e61165f1	8eb048e0-49b1-4d8a-9e1f-ab534f5d1564	مستندسازی و نهایی‌سازی	170	80	2026-06-30	approved	487a4011-366a-4e1c-ac4d-6f24e62436c6	\N	4cdcaa90-8f96-41db-a3f6-ef57e484048e	2026-07-20 09:59:26.363877+00	2026-07-20 09:59:26.363877+00
a03a787d-b998-4a31-aa2e-2aef31ab5784	b359cdff-9d8b-41b1-a00e-62afe6392c02	fac1f37f-7665-4a91-b497-43238269a2e8	مستندسازی و نهایی‌سازی	82	40	2026-06-17	submitted	\N	\N	08f1faad-3d60-419c-a0ee-f8b2aabdbaf3	2026-07-20 09:59:26.363877+00	2026-07-20 09:59:26.363877+00
a03a787d-b998-4a31-aa2e-2aef31ab5784	1214aaf5-7ca0-4b08-971b-b0700b3b94b7	fac1f37f-7665-4a91-b497-43238269a2e8	رفع اشکالات و بازبینی	43	27	2026-07-16	approved	487a4011-366a-4e1c-ac4d-6f24e62436c6	\N	2cbaafbe-e6d1-4974-b42c-628f88fd17a0	2026-07-20 09:59:26.363877+00	2026-07-20 09:59:26.363877+00
a03a787d-b998-4a31-aa2e-2aef31ab5784	1214aaf5-7ca0-4b08-971b-b0700b3b94b7	fac1f37f-7665-4a91-b497-43238269a2e8	رفع اشکالات و بازبینی	173	78	2026-07-16	approved	487a4011-366a-4e1c-ac4d-6f24e62436c6	\N	a9134d34-8800-46c0-94d3-1b9f0e2faf7a	2026-07-20 09:59:26.363877+00	2026-07-20 09:59:26.363877+00
a03a787d-b998-4a31-aa2e-2aef31ab5784	1214aaf5-7ca0-4b08-971b-b0700b3b94b7	fac1f37f-7665-4a91-b497-43238269a2e8	رفع اشکالات و بازبینی	213	100	2026-07-16	approved	487a4011-366a-4e1c-ac4d-6f24e62436c6	\N	57a82564-dabc-4ff0-a594-b0d67e90d89a	2026-07-20 09:59:26.363877+00	2026-07-20 09:59:26.363877+00
a03a787d-b998-4a31-aa2e-2aef31ab5784	1214aaf5-7ca0-4b08-971b-b0700b3b94b7	fac1f37f-7665-4a91-b497-43238269a2e8	پیشرفت اولیه و بررسی نیازمندی‌ها	224	100	2026-07-16	approved	487a4011-366a-4e1c-ac4d-6f24e62436c6	\N	33f3139c-f213-44b6-b992-c466124fda04	2026-07-20 09:59:26.363877+00	2026-07-20 09:59:26.363877+00
a03a787d-b998-4a31-aa2e-2aef31ab5784	c169aa37-bc4f-4b07-8703-afae36e8f5d3	487a4011-366a-4e1c-ac4d-6f24e62436c6	رفع اشکالات و بازبینی	170	36	2026-07-16	approved	487a4011-366a-4e1c-ac4d-6f24e62436c6	\N	259c3b31-6009-4b18-8fc1-9252d02923e3	2026-07-20 09:59:26.363877+00	2026-07-20 09:59:26.363877+00
a03a787d-b998-4a31-aa2e-2aef31ab5784	9b9d95d0-4be0-461e-9292-97fac60bc352	8eb048e0-49b1-4d8a-9e1f-ab534f5d1564	پیشرفت اولیه و بررسی نیازمندی‌ها	72	35	2026-07-16	approved	487a4011-366a-4e1c-ac4d-6f24e62436c6	\N	84265291-4ff5-446b-a1b6-07450ab8e76c	2026-07-20 09:59:26.363877+00	2026-07-20 09:59:26.363877+00
a03a787d-b998-4a31-aa2e-2aef31ab5784	9b9d95d0-4be0-461e-9292-97fac60bc352	8eb048e0-49b1-4d8a-9e1f-ab534f5d1564	تست و اطمینان از عملکرد صحیح	57	56	2026-07-16	approved	487a4011-366a-4e1c-ac4d-6f24e62436c6	\N	edcf4ecb-0ffb-4a54-b893-0bc6c458c921	2026-07-20 09:59:26.363877+00	2026-07-20 09:59:26.363877+00
a03a787d-b998-4a31-aa2e-2aef31ab5784	9b9d95d0-4be0-461e-9292-97fac60bc352	8eb048e0-49b1-4d8a-9e1f-ab534f5d1564	پیاده‌سازی بخش اصلی	60	96	2026-07-16	approved	487a4011-366a-4e1c-ac4d-6f24e62436c6	\N	e067175a-f4b8-4492-a2ba-1973641ad223	2026-07-20 09:59:26.363877+00	2026-07-20 09:59:26.363877+00
a03a787d-b998-4a31-aa2e-2aef31ab5784	bde0b27e-197e-4b80-acb3-7c99ff850537	06467080-462f-4467-a2ac-577bc7c7dff6	پیاده‌سازی بخش اصلی	213	30	2026-07-16	approved	487a4011-366a-4e1c-ac4d-6f24e62436c6	\N	9cfc805b-d9c8-429e-bdbf-09a79c6ee77c	2026-07-20 09:59:26.363877+00	2026-07-20 09:59:26.363877+00
a03a787d-b998-4a31-aa2e-2aef31ab5784	bde0b27e-197e-4b80-acb3-7c99ff850537	06467080-462f-4467-a2ac-577bc7c7dff6	تست و اطمینان از عملکرد صحیح	41	80	2026-07-16	approved	487a4011-366a-4e1c-ac4d-6f24e62436c6	\N	2a002ca7-7e6d-4380-a407-395cc86dc2c2	2026-07-20 09:59:26.363877+00	2026-07-20 09:59:26.363877+00
a03a787d-b998-4a31-aa2e-2aef31ab5784	69ff658d-6c9e-4e3c-ae69-a0c7ac4b4b56	48c7fe74-5692-42c1-9068-c52c071221e8	تست و اطمینان از عملکرد صحیح	198	38	2026-07-07	approved	487a4011-366a-4e1c-ac4d-6f24e62436c6	\N	49945d0b-a6a3-4910-8a4c-df03f283bc88	2026-07-20 09:59:26.363877+00	2026-07-20 09:59:26.363877+00
a03a787d-b998-4a31-aa2e-2aef31ab5784	cccef3c8-df7f-4c3c-830c-fc6c6081bd0c	3de0e871-5193-4e41-885f-531073da833a	پیشرفت اولیه و بررسی نیازمندی‌ها	165	21	2026-07-12	approved	487a4011-366a-4e1c-ac4d-6f24e62436c6	\N	a3484110-4e6f-4bd9-8745-30fd3eab15a6	2026-07-20 09:59:26.363877+00	2026-07-20 09:59:26.363877+00
a03a787d-b998-4a31-aa2e-2aef31ab5784	cccef3c8-df7f-4c3c-830c-fc6c6081bd0c	3de0e871-5193-4e41-885f-531073da833a	مستندسازی و نهایی‌سازی	153	72	2026-07-16	approved	487a4011-366a-4e1c-ac4d-6f24e62436c6	\N	538a33ee-25de-45d2-a867-2ce4b06cdc13	2026-07-20 09:59:26.363877+00	2026-07-20 09:59:26.363877+00
a03a787d-b998-4a31-aa2e-2aef31ab5784	bfa7fa43-e089-4a7a-bb7e-ba1b64c6e859	06467080-462f-4467-a2ac-577bc7c7dff6	پیاده‌سازی بخش اصلی	56	32	2026-07-16	approved	487a4011-366a-4e1c-ac4d-6f24e62436c6	\N	bda5a8d9-c085-4e98-8c4a-cbe7650f2834	2026-07-20 09:59:26.363877+00	2026-07-20 09:59:26.363877+00
a03a787d-b998-4a31-aa2e-2aef31ab5784	bfa7fa43-e089-4a7a-bb7e-ba1b64c6e859	06467080-462f-4467-a2ac-577bc7c7dff6	مستندسازی و نهایی‌سازی	128	66	2026-07-16	approved	487a4011-366a-4e1c-ac4d-6f24e62436c6	\N	55843764-baa7-444b-ab55-5f664218de0f	2026-07-20 09:59:26.363877+00	2026-07-20 09:59:26.363877+00
a03a787d-b998-4a31-aa2e-2aef31ab5784	abb0f1e2-ffa4-4d10-8149-466f73480a43	48c7fe74-5692-42c1-9068-c52c071221e8	رفع اشکالات و بازبینی	105	34	2026-06-26	approved	487a4011-366a-4e1c-ac4d-6f24e62436c6	\N	99d27e88-90c1-45a6-88f2-29363e4b098a	2026-07-20 09:59:26.363877+00	2026-07-20 09:59:26.363877+00
a03a787d-b998-4a31-aa2e-2aef31ab5784	abb0f1e2-ffa4-4d10-8149-466f73480a43	48c7fe74-5692-42c1-9068-c52c071221e8	مستندسازی و نهایی‌سازی	209	72	2026-06-28	approved	487a4011-366a-4e1c-ac4d-6f24e62436c6	\N	d2581cff-0953-4fe7-9162-ba64c26dffba	2026-07-20 09:59:26.363877+00	2026-07-20 09:59:26.363877+00
a03a787d-b998-4a31-aa2e-2aef31ab5784	1a7380e3-ed0b-4b25-9a99-caf67a01e815	8eb048e0-49b1-4d8a-9e1f-ab534f5d1564	مستندسازی و نهایی‌سازی	191	26	2026-07-16	submitted	\N	\N	7c0db541-ab81-488e-87d5-8c42ca5a3b78	2026-07-20 09:59:26.363877+00	2026-07-20 09:59:26.363877+00
a03a787d-b998-4a31-aa2e-2aef31ab5784	1a7380e3-ed0b-4b25-9a99-caf67a01e815	8eb048e0-49b1-4d8a-9e1f-ab534f5d1564	رفع اشکالات و بازبینی	205	62	2026-07-16	approved	487a4011-366a-4e1c-ac4d-6f24e62436c6	\N	be1cd916-1229-4e19-8cbb-7a2429c30441	2026-07-20 09:59:26.363877+00	2026-07-20 09:59:26.363877+00
a03a787d-b998-4a31-aa2e-2aef31ab5784	1a7380e3-ed0b-4b25-9a99-caf67a01e815	8eb048e0-49b1-4d8a-9e1f-ab534f5d1564	پیاده‌سازی بخش اصلی	158	100	2026-07-16	submitted	\N	\N	8bc7075e-a667-491f-b25d-e714c32d241b	2026-07-20 09:59:26.363877+00	2026-07-20 09:59:26.363877+00
a03a787d-b998-4a31-aa2e-2aef31ab5784	54eafa6b-1c1d-40ca-8fc8-55c1a266340f	06467080-462f-4467-a2ac-577bc7c7dff6	مستندسازی و نهایی‌سازی	152	38	2026-07-01	submitted	\N	\N	22d4972b-13cd-4bf4-b513-3e11062a6e8f	2026-07-20 09:59:26.363877+00	2026-07-20 09:59:26.363877+00
a03a787d-b998-4a31-aa2e-2aef31ab5784	54eafa6b-1c1d-40ca-8fc8-55c1a266340f	06467080-462f-4467-a2ac-577bc7c7dff6	مستندسازی و نهایی‌سازی	103	66	2026-07-05	approved	487a4011-366a-4e1c-ac4d-6f24e62436c6	\N	70dd4c50-292b-4ae3-b346-4384ee790aba	2026-07-20 09:59:26.363877+00	2026-07-20 09:59:26.363877+00
a03a787d-b998-4a31-aa2e-2aef31ab5784	54eafa6b-1c1d-40ca-8fc8-55c1a266340f	06467080-462f-4467-a2ac-577bc7c7dff6	پیشرفت اولیه و بررسی نیازمندی‌ها	127	72	2026-07-03	approved	487a4011-366a-4e1c-ac4d-6f24e62436c6	\N	ca132c31-a2a5-495b-9bcc-74cf976aa0ca	2026-07-20 09:59:26.363877+00	2026-07-20 09:59:26.363877+00
a03a787d-b998-4a31-aa2e-2aef31ab5784	91f74f13-0f43-4708-9eaa-3c7019e27b7c	48c7fe74-5692-42c1-9068-c52c071221e8	پیاده‌سازی بخش اصلی	98	25	2026-06-28	approved	487a4011-366a-4e1c-ac4d-6f24e62436c6	\N	d3fda263-8c61-4a6c-8e21-5a16f9cd4292	2026-07-20 09:59:26.363877+00	2026-07-20 09:59:26.363877+00
a03a787d-b998-4a31-aa2e-2aef31ab5784	d2fcafec-16ad-4ff2-beb5-e1db3e03449e	48c7fe74-5692-42c1-9068-c52c071221e8	پیشرفت اولیه و بررسی نیازمندی‌ها	206	29	2026-06-21	approved	487a4011-366a-4e1c-ac4d-6f24e62436c6	\N	ead291f4-c429-4e15-855c-24189bf7791d	2026-07-20 09:59:26.363877+00	2026-07-20 09:59:26.363877+00
a03a787d-b998-4a31-aa2e-2aef31ab5784	d2fcafec-16ad-4ff2-beb5-e1db3e03449e	48c7fe74-5692-42c1-9068-c52c071221e8	پیشرفت اولیه و بررسی نیازمندی‌ها	121	68	2026-06-23	submitted	\N	\N	fa9fcc4e-93b4-4046-b6fd-150afae1cf19	2026-07-20 09:59:26.363877+00	2026-07-20 09:59:26.363877+00
a03a787d-b998-4a31-aa2e-2aef31ab5784	d2fcafec-16ad-4ff2-beb5-e1db3e03449e	48c7fe74-5692-42c1-9068-c52c071221e8	مستندسازی و نهایی‌سازی	87	100	2026-06-23	approved	487a4011-366a-4e1c-ac4d-6f24e62436c6	\N	e3e532ca-e9f9-4fc0-93f5-a39ad4784b6b	2026-07-20 09:59:26.363877+00	2026-07-20 09:59:26.363877+00
a03a787d-b998-4a31-aa2e-2aef31ab5784	bf6863ce-f215-4d25-b2ec-cf7641c84a64	929fcc10-abd5-4d94-9b84-fb05ba764ba0	رفع اشکالات و بازبینی	207	21	2026-07-16	approved	487a4011-366a-4e1c-ac4d-6f24e62436c6	\N	cfc9a86e-8335-4efc-a369-9530bbe6803c	2026-07-20 09:59:26.363877+00	2026-07-20 09:59:26.363877+00
a03a787d-b998-4a31-aa2e-2aef31ab5784	bf6863ce-f215-4d25-b2ec-cf7641c84a64	929fcc10-abd5-4d94-9b84-fb05ba764ba0	رفع اشکالات و بازبینی	171	42	2026-07-16	approved	487a4011-366a-4e1c-ac4d-6f24e62436c6	\N	de642b64-bb0e-4047-9d8f-dcb6e844fceb	2026-07-20 09:59:26.363877+00	2026-07-20 09:59:26.363877+00
a03a787d-b998-4a31-aa2e-2aef31ab5784	bf6863ce-f215-4d25-b2ec-cf7641c84a64	929fcc10-abd5-4d94-9b84-fb05ba764ba0	پیاده‌سازی بخش اصلی	188	100	2026-07-16	submitted	\N	\N	819b2e60-9718-41dc-b271-fb9d2cf31098	2026-07-20 09:59:26.363877+00	2026-07-20 09:59:26.363877+00
a03a787d-b998-4a31-aa2e-2aef31ab5784	bf6863ce-f215-4d25-b2ec-cf7641c84a64	929fcc10-abd5-4d94-9b84-fb05ba764ba0	رفع اشکالات و بازبینی	223	100	2026-07-16	submitted	\N	\N	5d82e076-6f54-432c-95a9-69eab488b687	2026-07-20 09:59:26.363877+00	2026-07-20 09:59:26.363877+00
a03a787d-b998-4a31-aa2e-2aef31ab5784	2db1b347-0021-473c-a91f-12f4e979bdef	06467080-462f-4467-a2ac-577bc7c7dff6	رفع اشکالات و بازبینی	144	25	2026-07-16	approved	487a4011-366a-4e1c-ac4d-6f24e62436c6	\N	99202e0d-1cd6-4c43-85a2-e8df5312914d	2026-07-20 09:59:26.363877+00	2026-07-20 09:59:26.363877+00
a03a787d-b998-4a31-aa2e-2aef31ab5784	2db1b347-0021-473c-a91f-12f4e979bdef	06467080-462f-4467-a2ac-577bc7c7dff6	پیاده‌سازی بخش اصلی	74	72	2026-07-16	approved	487a4011-366a-4e1c-ac4d-6f24e62436c6	\N	e7ccf730-84ff-4fbb-876b-c2527277a8bc	2026-07-20 09:59:26.363877+00	2026-07-20 09:59:26.363877+00
a03a787d-b998-4a31-aa2e-2aef31ab5784	d94edb5e-4bc9-4749-badb-da4a883a652f	3de0e871-5193-4e41-885f-531073da833a	پیشرفت اولیه و بررسی نیازمندی‌ها	139	28	2026-07-16	approved	487a4011-366a-4e1c-ac4d-6f24e62436c6	\N	8b7bb9e8-9bf9-4552-b683-ab50dbe562c5	2026-07-20 09:59:26.363877+00	2026-07-20 09:59:26.363877+00
a03a787d-b998-4a31-aa2e-2aef31ab5784	f0afc7d3-2396-44d2-a7ab-afee41cf05ed	487a4011-366a-4e1c-ac4d-6f24e62436c6	رفع اشکالات و بازبینی	31	30	2026-07-16	approved	487a4011-366a-4e1c-ac4d-6f24e62436c6	\N	8fb51fd5-dcbe-432b-99ab-dea237fdc4af	2026-07-20 09:59:26.363877+00	2026-07-20 09:59:26.363877+00
a03a787d-b998-4a31-aa2e-2aef31ab5784	f0afc7d3-2396-44d2-a7ab-afee41cf05ed	487a4011-366a-4e1c-ac4d-6f24e62436c6	پیاده‌سازی بخش اصلی	40	48	2026-07-16	submitted	\N	\N	c1e1f14f-c2b1-4cb4-b38b-ae1928a98958	2026-07-20 09:59:26.363877+00	2026-07-20 09:59:26.363877+00
a03a787d-b998-4a31-aa2e-2aef31ab5784	f0afc7d3-2396-44d2-a7ab-afee41cf05ed	487a4011-366a-4e1c-ac4d-6f24e62436c6	مستندسازی و نهایی‌سازی	199	87	2026-07-16	approved	487a4011-366a-4e1c-ac4d-6f24e62436c6	\N	67967b56-2141-4095-8966-7ebc034a3cb5	2026-07-20 09:59:26.363877+00	2026-07-20 09:59:26.363877+00
a03a787d-b998-4a31-aa2e-2aef31ab5784	c5f232f8-2875-4df7-a475-39fcfb411ab7	48c7fe74-5692-42c1-9068-c52c071221e8	پیشرفت اولیه و بررسی نیازمندی‌ها	230	30	2026-07-16	approved	487a4011-366a-4e1c-ac4d-6f24e62436c6	\N	c8997162-da5d-4f72-926c-8ace18b8de19	2026-07-20 09:59:26.363877+00	2026-07-20 09:59:26.363877+00
a03a787d-b998-4a31-aa2e-2aef31ab5784	c5f232f8-2875-4df7-a475-39fcfb411ab7	48c7fe74-5692-42c1-9068-c52c071221e8	پیاده‌سازی بخش اصلی	163	44	2026-07-16	approved	487a4011-366a-4e1c-ac4d-6f24e62436c6	\N	4bc89e5d-ca59-48af-a448-aa61a8a6193e	2026-07-20 09:59:26.363877+00	2026-07-20 09:59:26.363877+00
a03a787d-b998-4a31-aa2e-2aef31ab5784	c5f232f8-2875-4df7-a475-39fcfb411ab7	48c7fe74-5692-42c1-9068-c52c071221e8	تست و اطمینان از عملکرد صحیح	169	100	2026-07-16	approved	487a4011-366a-4e1c-ac4d-6f24e62436c6	\N	1f972788-b3cf-4931-be2f-986f94b8cc0e	2026-07-20 09:59:26.363877+00	2026-07-20 09:59:26.363877+00
a03a787d-b998-4a31-aa2e-2aef31ab5784	c5f232f8-2875-4df7-a475-39fcfb411ab7	48c7fe74-5692-42c1-9068-c52c071221e8	پیشرفت اولیه و بررسی نیازمندی‌ها	119	100	2026-07-16	approved	487a4011-366a-4e1c-ac4d-6f24e62436c6	\N	63349c8d-dc6c-41fb-8865-5da0f668ceb0	2026-07-20 09:59:26.363877+00	2026-07-20 09:59:26.363877+00
a03a787d-b998-4a31-aa2e-2aef31ab5784	9ee72df7-ff2d-4105-991e-a2c98a45de3b	929fcc10-abd5-4d94-9b84-fb05ba764ba0	رفع اشکالات و بازبینی	122	29	2026-07-16	approved	487a4011-366a-4e1c-ac4d-6f24e62436c6	\N	5716be45-0728-45ed-a626-d98c116fe6a3	2026-07-20 09:59:26.363877+00	2026-07-20 09:59:26.363877+00
a03a787d-b998-4a31-aa2e-2aef31ab5784	9ee72df7-ff2d-4105-991e-a2c98a45de3b	929fcc10-abd5-4d94-9b84-fb05ba764ba0	مستندسازی و نهایی‌سازی	165	70	2026-07-16	approved	487a4011-366a-4e1c-ac4d-6f24e62436c6	\N	dddc146c-69af-4eb3-bddb-f07a7a284aaf	2026-07-20 09:59:26.363877+00	2026-07-20 09:59:26.363877+00
a03a787d-b998-4a31-aa2e-2aef31ab5784	d0cecb81-afaa-4e13-a11a-25fc0fd64a56	fac1f37f-7665-4a91-b497-43238269a2e8	رفع اشکالات و بازبینی	144	27	2026-06-16	approved	487a4011-366a-4e1c-ac4d-6f24e62436c6	\N	7a07055f-6ef9-49ee-9cb3-57c5d673e3c5	2026-07-20 09:59:26.363877+00	2026-07-20 09:59:26.363877+00
a03a787d-b998-4a31-aa2e-2aef31ab5784	7f18374b-5da5-4667-89e0-4bfc4364e37d	487a4011-366a-4e1c-ac4d-6f24e62436c6	رفع اشکالات و بازبینی	127	23	2026-06-25	approved	487a4011-366a-4e1c-ac4d-6f24e62436c6	\N	cc644b8f-efef-4fe8-b8b1-d98bf53549de	2026-07-20 09:59:26.363877+00	2026-07-20 09:59:26.363877+00
a03a787d-b998-4a31-aa2e-2aef31ab5784	7f18374b-5da5-4667-89e0-4bfc4364e37d	487a4011-366a-4e1c-ac4d-6f24e62436c6	رفع اشکالات و بازبینی	36	72	2026-06-29	approved	487a4011-366a-4e1c-ac4d-6f24e62436c6	\N	2ae82e8a-bed6-4dc5-a5d0-6feda79c8b01	2026-07-20 09:59:26.363877+00	2026-07-20 09:59:26.363877+00
a03a787d-b998-4a31-aa2e-2aef31ab5784	a28166df-880b-48f2-b628-58cbcbed4fe2	3de0e871-5193-4e41-885f-531073da833a	رفع اشکالات و بازبینی	196	26	2026-07-10	approved	487a4011-366a-4e1c-ac4d-6f24e62436c6	\N	2d30cd6f-a900-4d56-8027-85c57472a851	2026-07-20 09:59:26.363877+00	2026-07-20 09:59:26.363877+00
a03a787d-b998-4a31-aa2e-2aef31ab5784	a28166df-880b-48f2-b628-58cbcbed4fe2	3de0e871-5193-4e41-885f-531073da833a	پیشرفت اولیه و بررسی نیازمندی‌ها	72	74	2026-07-13	approved	487a4011-366a-4e1c-ac4d-6f24e62436c6	\N	20bf0acb-32a3-4f14-9681-2030fd70e13a	2026-07-20 09:59:26.363877+00	2026-07-20 09:59:26.363877+00
a03a787d-b998-4a31-aa2e-2aef31ab5784	a28166df-880b-48f2-b628-58cbcbed4fe2	3de0e871-5193-4e41-885f-531073da833a	پیاده‌سازی بخش اصلی	201	100	2026-07-12	approved	487a4011-366a-4e1c-ac4d-6f24e62436c6	\N	942ae6dc-06cc-4ec8-b254-a6276101edc4	2026-07-20 09:59:26.363877+00	2026-07-20 09:59:26.363877+00
a03a787d-b998-4a31-aa2e-2aef31ab5784	df53a3f7-2094-41c6-b723-372e6d17adb6	06467080-462f-4467-a2ac-577bc7c7dff6	پیاده‌سازی بخش اصلی	167	33	2026-06-25	submitted	\N	\N	1ac27e5f-c835-420b-904f-c0448a49dfc4	2026-07-20 09:59:26.363877+00	2026-07-20 09:59:26.363877+00
a03a787d-b998-4a31-aa2e-2aef31ab5784	df53a3f7-2094-41c6-b723-372e6d17adb6	06467080-462f-4467-a2ac-577bc7c7dff6	پیاده‌سازی بخش اصلی	36	68	2026-06-26	submitted	\N	\N	d3e7aac7-9726-4451-a518-1b059a928603	2026-07-20 09:59:26.363877+00	2026-07-20 09:59:26.363877+00
a03a787d-b998-4a31-aa2e-2aef31ab5784	974ca9a7-8f2d-483e-8497-f57a8d2d567f	06467080-462f-4467-a2ac-577bc7c7dff6	پیشرفت اولیه و بررسی نیازمندی‌ها	48	21	2026-07-16	approved	487a4011-366a-4e1c-ac4d-6f24e62436c6	\N	61918f53-0874-43b3-b963-b5854c227fd6	2026-07-20 09:59:26.363877+00	2026-07-20 09:59:26.363877+00
a03a787d-b998-4a31-aa2e-2aef31ab5784	974ca9a7-8f2d-483e-8497-f57a8d2d567f	06467080-462f-4467-a2ac-577bc7c7dff6	رفع اشکالات و بازبینی	172	44	2026-07-16	approved	487a4011-366a-4e1c-ac4d-6f24e62436c6	\N	502a661d-94ed-45d7-a61c-4b15356db303	2026-07-20 09:59:26.363877+00	2026-07-20 09:59:26.363877+00
a03a787d-b998-4a31-aa2e-2aef31ab5784	974ca9a7-8f2d-483e-8497-f57a8d2d567f	06467080-462f-4467-a2ac-577bc7c7dff6	رفع اشکالات و بازبینی	134	96	2026-07-16	approved	487a4011-366a-4e1c-ac4d-6f24e62436c6	\N	4a519ac0-2307-4b8e-a04e-b4d2719b98eb	2026-07-20 09:59:26.363877+00	2026-07-20 09:59:26.363877+00
a03a787d-b998-4a31-aa2e-2aef31ab5784	2323795b-aa74-4c1c-89a6-d68e3a46c480	487a4011-366a-4e1c-ac4d-6f24e62436c6	پیشرفت اولیه و بررسی نیازمندی‌ها	129	23	2026-07-16	approved	487a4011-366a-4e1c-ac4d-6f24e62436c6	\N	f902e813-83e1-4793-a756-af7c41dedc02	2026-07-20 09:59:26.363877+00	2026-07-20 09:59:26.363877+00
a03a787d-b998-4a31-aa2e-2aef31ab5784	2323795b-aa74-4c1c-89a6-d68e3a46c480	487a4011-366a-4e1c-ac4d-6f24e62436c6	مستندسازی و نهایی‌سازی	46	76	2026-07-16	approved	487a4011-366a-4e1c-ac4d-6f24e62436c6	\N	c8aebebf-2a15-40d7-9e7a-a9b5438f00f4	2026-07-20 09:59:26.363877+00	2026-07-20 09:59:26.363877+00
a03a787d-b998-4a31-aa2e-2aef31ab5784	2323795b-aa74-4c1c-89a6-d68e3a46c480	487a4011-366a-4e1c-ac4d-6f24e62436c6	پیشرفت اولیه و بررسی نیازمندی‌ها	121	100	2026-07-16	submitted	\N	\N	56f4e0d0-1cfa-43eb-b71a-d05dcea84b51	2026-07-20 09:59:26.363877+00	2026-07-20 09:59:26.363877+00
a03a787d-b998-4a31-aa2e-2aef31ab5784	2323795b-aa74-4c1c-89a6-d68e3a46c480	487a4011-366a-4e1c-ac4d-6f24e62436c6	رفع اشکالات و بازبینی	185	88	2026-07-16	approved	487a4011-366a-4e1c-ac4d-6f24e62436c6	\N	4b878e9a-272d-4385-bd59-33b7a1635357	2026-07-20 09:59:26.363877+00	2026-07-20 09:59:26.363877+00
a03a787d-b998-4a31-aa2e-2aef31ab5784	a78676ff-d6f3-4b62-868c-08eefcfba7fc	06467080-462f-4467-a2ac-577bc7c7dff6	پیشرفت اولیه و بررسی نیازمندی‌ها	151	25	2026-07-16	approved	487a4011-366a-4e1c-ac4d-6f24e62436c6	\N	b58514da-fdf2-4a19-ba5c-4bbc2f38b720	2026-07-20 09:59:26.363877+00	2026-07-20 09:59:26.363877+00
a03a787d-b998-4a31-aa2e-2aef31ab5784	a78676ff-d6f3-4b62-868c-08eefcfba7fc	06467080-462f-4467-a2ac-577bc7c7dff6	تست و اطمینان از عملکرد صحیح	233	74	2026-07-16	approved	487a4011-366a-4e1c-ac4d-6f24e62436c6	\N	3b8373c8-9407-4030-9ead-752611b3fd36	2026-07-20 09:59:26.363877+00	2026-07-20 09:59:26.363877+00
a03a787d-b998-4a31-aa2e-2aef31ab5784	a78676ff-d6f3-4b62-868c-08eefcfba7fc	06467080-462f-4467-a2ac-577bc7c7dff6	پیاده‌سازی بخش اصلی	106	100	2026-07-16	submitted	\N	\N	ed3089da-7cc3-4842-87c9-f1735e072abc	2026-07-20 09:59:26.363877+00	2026-07-20 09:59:26.363877+00
a03a787d-b998-4a31-aa2e-2aef31ab5784	bab6f2e7-91ca-40db-9111-01b5c8563043	8eb048e0-49b1-4d8a-9e1f-ab534f5d1564	مستندسازی و نهایی‌سازی	66	23	2026-07-16	approved	487a4011-366a-4e1c-ac4d-6f24e62436c6	\N	eb7f635a-e82b-4753-a343-fe2c659e3615	2026-07-20 09:59:26.363877+00	2026-07-20 09:59:26.363877+00
a03a787d-b998-4a31-aa2e-2aef31ab5784	bab6f2e7-91ca-40db-9111-01b5c8563043	8eb048e0-49b1-4d8a-9e1f-ab534f5d1564	مستندسازی و نهایی‌سازی	130	74	2026-07-16	approved	487a4011-366a-4e1c-ac4d-6f24e62436c6	\N	09f190c2-3228-4630-ab6d-a067958e1941	2026-07-20 09:59:26.363877+00	2026-07-20 09:59:26.363877+00
a03a787d-b998-4a31-aa2e-2aef31ab5784	bab6f2e7-91ca-40db-9111-01b5c8563043	8eb048e0-49b1-4d8a-9e1f-ab534f5d1564	رفع اشکالات و بازبینی	84	99	2026-07-16	approved	487a4011-366a-4e1c-ac4d-6f24e62436c6	\N	d1a981a8-7e99-4da0-8393-392749c5fbc2	2026-07-20 09:59:26.363877+00	2026-07-20 09:59:26.363877+00
a03a787d-b998-4a31-aa2e-2aef31ab5784	8ef6f2a8-c3df-4b35-abe0-8e27a8c4b046	929fcc10-abd5-4d94-9b84-fb05ba764ba0	پیاده‌سازی بخش اصلی	86	39	2026-06-17	approved	487a4011-366a-4e1c-ac4d-6f24e62436c6	\N	1b77aae2-22a5-46e3-bb67-c16253ce50c6	2026-07-20 09:59:26.363877+00	2026-07-20 09:59:26.363877+00
a03a787d-b998-4a31-aa2e-2aef31ab5784	8ef6f2a8-c3df-4b35-abe0-8e27a8c4b046	929fcc10-abd5-4d94-9b84-fb05ba764ba0	پیاده‌سازی بخش اصلی	59	50	2026-06-20	approved	487a4011-366a-4e1c-ac4d-6f24e62436c6	\N	d07b75b5-3986-4590-a126-286f47981c3e	2026-07-20 09:59:26.363877+00	2026-07-20 09:59:26.363877+00
a03a787d-b998-4a31-aa2e-2aef31ab5784	6c3b8578-966b-45b6-a637-483b9bc619bc	929fcc10-abd5-4d94-9b84-fb05ba764ba0	مستندسازی و نهایی‌سازی	48	29	2026-07-16	approved	487a4011-366a-4e1c-ac4d-6f24e62436c6	\N	0ea60d22-af32-4260-abd0-32722e814445	2026-07-20 09:59:26.363877+00	2026-07-20 09:59:26.363877+00
a03a787d-b998-4a31-aa2e-2aef31ab5784	28824178-fe03-47f5-97c3-b24d806c0fff	3de0e871-5193-4e41-885f-531073da833a	پیشرفت اولیه و بررسی نیازمندی‌ها	80	38	2026-07-16	approved	487a4011-366a-4e1c-ac4d-6f24e62436c6	\N	c3c78188-5cef-4bd5-b2d6-8e1ab3c4888c	2026-07-20 09:59:26.363877+00	2026-07-20 09:59:26.363877+00
a03a787d-b998-4a31-aa2e-2aef31ab5784	19cf99c9-30d8-4771-a68a-2f4cb4da8c0b	8eb048e0-49b1-4d8a-9e1f-ab534f5d1564	پیاده‌سازی بخش اصلی	55	29	2026-07-16	approved	487a4011-366a-4e1c-ac4d-6f24e62436c6	\N	2febcdfa-3cf1-468f-b821-f7e9dfcb2cff	2026-07-20 09:59:26.363877+00	2026-07-20 09:59:26.363877+00
a03a787d-b998-4a31-aa2e-2aef31ab5784	19cf99c9-30d8-4771-a68a-2f4cb4da8c0b	8eb048e0-49b1-4d8a-9e1f-ab534f5d1564	رفع اشکالات و بازبینی	154	68	2026-07-16	submitted	\N	\N	7f9400e2-ddc6-40c5-a4cb-73734a8e9df4	2026-07-20 09:59:26.363877+00	2026-07-20 09:59:26.363877+00
a03a787d-b998-4a31-aa2e-2aef31ab5784	19cf99c9-30d8-4771-a68a-2f4cb4da8c0b	8eb048e0-49b1-4d8a-9e1f-ab534f5d1564	رفع اشکالات و بازبینی	207	100	2026-07-16	approved	487a4011-366a-4e1c-ac4d-6f24e62436c6	\N	b6ed9c33-c7ef-4e3e-8d79-b231c87a0e6b	2026-07-20 09:59:26.363877+00	2026-07-20 09:59:26.363877+00
a03a787d-b998-4a31-aa2e-2aef31ab5784	19cf99c9-30d8-4771-a68a-2f4cb4da8c0b	8eb048e0-49b1-4d8a-9e1f-ab534f5d1564	رفع اشکالات و بازبینی	236	100	2026-07-16	approved	487a4011-366a-4e1c-ac4d-6f24e62436c6	\N	acb6c5b5-c180-45f1-8b53-dc87c717e0ba	2026-07-20 09:59:26.363877+00	2026-07-20 09:59:26.363877+00
a03a787d-b998-4a31-aa2e-2aef31ab5784	11172009-5f75-4630-826a-0da1d429763b	929fcc10-abd5-4d94-9b84-fb05ba764ba0	پیشرفت اولیه و بررسی نیازمندی‌ها	110	27	2026-06-29	approved	487a4011-366a-4e1c-ac4d-6f24e62436c6	\N	7e321680-1be6-4e53-8282-bef176222b90	2026-07-20 09:59:26.363877+00	2026-07-20 09:59:26.363877+00
a03a787d-b998-4a31-aa2e-2aef31ab5784	11172009-5f75-4630-826a-0da1d429763b	929fcc10-abd5-4d94-9b84-fb05ba764ba0	تست و اطمینان از عملکرد صحیح	100	62	2026-07-01	approved	487a4011-366a-4e1c-ac4d-6f24e62436c6	\N	4f4936a0-99d7-456d-b06d-165e06acc2a1	2026-07-20 09:59:26.363877+00	2026-07-20 09:59:26.363877+00
a03a787d-b998-4a31-aa2e-2aef31ab5784	11172009-5f75-4630-826a-0da1d429763b	929fcc10-abd5-4d94-9b84-fb05ba764ba0	رفع اشکالات و بازبینی	152	100	2026-07-03	approved	487a4011-366a-4e1c-ac4d-6f24e62436c6	\N	c77bb99b-b8b5-4a71-88f6-68173d27d12b	2026-07-20 09:59:26.363877+00	2026-07-20 09:59:26.363877+00
a03a787d-b998-4a31-aa2e-2aef31ab5784	11172009-5f75-4630-826a-0da1d429763b	929fcc10-abd5-4d94-9b84-fb05ba764ba0	رفع اشکالات و بازبینی	228	100	2026-07-11	approved	487a4011-366a-4e1c-ac4d-6f24e62436c6	\N	40933923-ac3a-4905-bb43-9d35c6bf4439	2026-07-20 09:59:26.363877+00	2026-07-20 09:59:26.363877+00
a03a787d-b998-4a31-aa2e-2aef31ab5784	84a27e70-764e-480c-bb5d-7997bdbb7163	06467080-462f-4467-a2ac-577bc7c7dff6	پیاده‌سازی بخش اصلی	195	39	2026-06-17	approved	487a4011-366a-4e1c-ac4d-6f24e62436c6	\N	fc337923-3f93-4871-bedf-83cbca75caf6	2026-07-20 09:59:26.363877+00	2026-07-20 09:59:26.363877+00
a03a787d-b998-4a31-aa2e-2aef31ab5784	84a27e70-764e-480c-bb5d-7997bdbb7163	06467080-462f-4467-a2ac-577bc7c7dff6	رفع اشکالات و بازبینی	65	74	2026-06-18	approved	487a4011-366a-4e1c-ac4d-6f24e62436c6	\N	1163007c-0f5c-4786-9fea-07583774232d	2026-07-20 09:59:26.363877+00	2026-07-20 09:59:26.363877+00
a03a787d-b998-4a31-aa2e-2aef31ab5784	84a27e70-764e-480c-bb5d-7997bdbb7163	06467080-462f-4467-a2ac-577bc7c7dff6	رفع اشکالات و بازبینی	217	100	2026-06-21	approved	487a4011-366a-4e1c-ac4d-6f24e62436c6	\N	9a7ab7cb-63c3-47d0-9eb8-65571297db74	2026-07-20 09:59:26.363877+00	2026-07-20 09:59:26.363877+00
a03a787d-b998-4a31-aa2e-2aef31ab5784	84a27e70-764e-480c-bb5d-7997bdbb7163	06467080-462f-4467-a2ac-577bc7c7dff6	پیشرفت اولیه و بررسی نیازمندی‌ها	34	100	2026-06-20	approved	487a4011-366a-4e1c-ac4d-6f24e62436c6	\N	9938c06e-6a38-4c45-adb3-32bd4a91f384	2026-07-20 09:59:26.363877+00	2026-07-20 09:59:26.363877+00
a03a787d-b998-4a31-aa2e-2aef31ab5784	a4e70064-bf5f-4594-87bb-48da8c180ab5	3de0e871-5193-4e41-885f-531073da833a	پیاده‌سازی بخش اصلی	39	37	2026-07-15	submitted	\N	\N	74809786-f045-4752-a8de-d5b4f971f1a9	2026-07-20 09:59:26.363877+00	2026-07-20 09:59:26.363877+00
a03a787d-b998-4a31-aa2e-2aef31ab5784	2460ef2f-3c11-404a-94d3-0ff2b500a5dc	929fcc10-abd5-4d94-9b84-fb05ba764ba0	پیاده‌سازی بخش اصلی	123	32	2026-06-22	approved	487a4011-366a-4e1c-ac4d-6f24e62436c6	\N	b43f8a4f-f693-445a-96ed-da07af271e48	2026-07-20 09:59:26.363877+00	2026-07-20 09:59:26.363877+00
a03a787d-b998-4a31-aa2e-2aef31ab5784	2460ef2f-3c11-404a-94d3-0ff2b500a5dc	929fcc10-abd5-4d94-9b84-fb05ba764ba0	مستندسازی و نهایی‌سازی	217	58	2026-06-24	approved	487a4011-366a-4e1c-ac4d-6f24e62436c6	\N	f3cde300-a76e-4282-a4b9-8a82ccb825d1	2026-07-20 09:59:26.363877+00	2026-07-20 09:59:26.363877+00
a03a787d-b998-4a31-aa2e-2aef31ab5784	2460ef2f-3c11-404a-94d3-0ff2b500a5dc	929fcc10-abd5-4d94-9b84-fb05ba764ba0	تست و اطمینان از عملکرد صحیح	158	100	2026-06-26	approved	487a4011-366a-4e1c-ac4d-6f24e62436c6	\N	da44b1ce-d0c7-4c5d-bf39-f412ac8a7843	2026-07-20 09:59:26.363877+00	2026-07-20 09:59:26.363877+00
a03a787d-b998-4a31-aa2e-2aef31ab5784	cd8747a6-18ed-4daf-8be0-002347ebe8f6	929fcc10-abd5-4d94-9b84-fb05ba764ba0	پیشرفت اولیه و بررسی نیازمندی‌ها	199	27	2026-07-16	approved	487a4011-366a-4e1c-ac4d-6f24e62436c6	\N	b5cb536f-a42b-4d11-994e-b7ce9b282147	2026-07-20 09:59:26.363877+00	2026-07-20 09:59:26.363877+00
a03a787d-b998-4a31-aa2e-2aef31ab5784	82646fe1-3570-462a-8085-782230699795	48c7fe74-5692-42c1-9068-c52c071221e8	تست و اطمینان از عملکرد صحیح	70	25	2026-06-25	approved	487a4011-366a-4e1c-ac4d-6f24e62436c6	\N	2149b146-8063-40b3-9e06-e14fdde4a9d1	2026-07-20 09:59:26.363877+00	2026-07-20 09:59:26.363877+00
a03a787d-b998-4a31-aa2e-2aef31ab5784	82646fe1-3570-462a-8085-782230699795	48c7fe74-5692-42c1-9068-c52c071221e8	تست و اطمینان از عملکرد صحیح	121	42	2026-06-27	approved	487a4011-366a-4e1c-ac4d-6f24e62436c6	\N	4a13f675-7b6e-4698-bb3b-8e32d93d7b3a	2026-07-20 09:59:26.363877+00	2026-07-20 09:59:26.363877+00
a03a787d-b998-4a31-aa2e-2aef31ab5784	e6f38f13-4bc3-46b0-90f1-0ca7605861eb	929fcc10-abd5-4d94-9b84-fb05ba764ba0	پیاده‌سازی بخش اصلی	46	28	2026-07-06	approved	487a4011-366a-4e1c-ac4d-6f24e62436c6	\N	7ce6e3b6-c90c-4ebd-bfad-58050daa4b66	2026-07-20 09:59:26.363877+00	2026-07-20 09:59:26.363877+00
a03a787d-b998-4a31-aa2e-2aef31ab5784	e6f38f13-4bc3-46b0-90f1-0ca7605861eb	929fcc10-abd5-4d94-9b84-fb05ba764ba0	پیاده‌سازی بخش اصلی	40	52	2026-07-09	approved	487a4011-366a-4e1c-ac4d-6f24e62436c6	\N	09d4a164-8a7a-4478-a235-8311971417a0	2026-07-20 09:59:26.363877+00	2026-07-20 09:59:26.363877+00
a03a787d-b998-4a31-aa2e-2aef31ab5784	7e9ad475-17fb-42e5-9b39-c02c6a3cf356	06467080-462f-4467-a2ac-577bc7c7dff6	تست و اطمینان از عملکرد صحیح	41	21	2026-07-16	approved	487a4011-366a-4e1c-ac4d-6f24e62436c6	\N	c1388351-2730-4628-a341-b1ccd6f596d5	2026-07-20 09:59:26.363877+00	2026-07-20 09:59:26.363877+00
a03a787d-b998-4a31-aa2e-2aef31ab5784	7e9ad475-17fb-42e5-9b39-c02c6a3cf356	06467080-462f-4467-a2ac-577bc7c7dff6	مستندسازی و نهایی‌سازی	192	56	2026-07-16	approved	487a4011-366a-4e1c-ac4d-6f24e62436c6	\N	bb771196-07b0-47f0-b365-366a162e65a0	2026-07-20 09:59:26.363877+00	2026-07-20 09:59:26.363877+00
a03a787d-b998-4a31-aa2e-2aef31ab5784	7e9ad475-17fb-42e5-9b39-c02c6a3cf356	06467080-462f-4467-a2ac-577bc7c7dff6	مستندسازی و نهایی‌سازی	74	96	2026-07-16	approved	487a4011-366a-4e1c-ac4d-6f24e62436c6	\N	9cde06fc-cf13-495e-9ca6-97503bc81131	2026-07-20 09:59:26.363877+00	2026-07-20 09:59:26.363877+00
a03a787d-b998-4a31-aa2e-2aef31ab5784	c859a2cc-abd6-44f4-9f8e-314401865796	48c7fe74-5692-42c1-9068-c52c071221e8	پیشرفت اولیه و بررسی نیازمندی‌ها	162	28	2026-07-16	approved	487a4011-366a-4e1c-ac4d-6f24e62436c6	\N	336640fc-1a56-456b-b285-1fd424bef3a2	2026-07-20 09:59:26.363877+00	2026-07-20 09:59:26.363877+00
a03a787d-b998-4a31-aa2e-2aef31ab5784	c859a2cc-abd6-44f4-9f8e-314401865796	48c7fe74-5692-42c1-9068-c52c071221e8	پیاده‌سازی بخش اصلی	162	64	2026-07-16	submitted	\N	\N	762595fd-c0f1-4c8a-a164-a39919cc9689	2026-07-20 09:59:26.363877+00	2026-07-20 09:59:26.363877+00
a03a787d-b998-4a31-aa2e-2aef31ab5784	c859a2cc-abd6-44f4-9f8e-314401865796	48c7fe74-5692-42c1-9068-c52c071221e8	رفع اشکالات و بازبینی	154	100	2026-07-16	submitted	\N	\N	0216c880-c5a4-4bdd-9747-f03112e63c20	2026-07-20 09:59:26.363877+00	2026-07-20 09:59:26.363877+00
a03a787d-b998-4a31-aa2e-2aef31ab5784	c859a2cc-abd6-44f4-9f8e-314401865796	48c7fe74-5692-42c1-9068-c52c071221e8	پیاده‌سازی بخش اصلی	142	100	2026-07-16	approved	487a4011-366a-4e1c-ac4d-6f24e62436c6	\N	033572df-6def-4e97-b1dd-28e97454fa39	2026-07-20 09:59:26.363877+00	2026-07-20 09:59:26.363877+00
a03a787d-b998-4a31-aa2e-2aef31ab5784	bdac5670-dbdc-4b4d-81d7-3056b935f600	487a4011-366a-4e1c-ac4d-6f24e62436c6	مستندسازی و نهایی‌سازی	194	28	2026-07-02	approved	487a4011-366a-4e1c-ac4d-6f24e62436c6	\N	b98d19c3-0c8e-403e-a6ad-2508a743204d	2026-07-20 09:59:26.363877+00	2026-07-20 09:59:26.363877+00
a03a787d-b998-4a31-aa2e-2aef31ab5784	bdac5670-dbdc-4b4d-81d7-3056b935f600	487a4011-366a-4e1c-ac4d-6f24e62436c6	پیاده‌سازی بخش اصلی	77	50	2026-07-04	approved	487a4011-366a-4e1c-ac4d-6f24e62436c6	\N	5033e7e1-7b9b-4f34-9d5f-f8c95941188c	2026-07-20 09:59:26.363877+00	2026-07-20 09:59:26.363877+00
a03a787d-b998-4a31-aa2e-2aef31ab5784	bdc49991-7bdd-411c-af88-1f56bf9a9916	06467080-462f-4467-a2ac-577bc7c7dff6	پیاده‌سازی بخش اصلی	136	30	2026-07-08	approved	487a4011-366a-4e1c-ac4d-6f24e62436c6	\N	3b4dd6b1-07c7-445e-b338-774b3c3c6307	2026-07-20 09:59:26.363877+00	2026-07-20 09:59:26.363877+00
a03a787d-b998-4a31-aa2e-2aef31ab5784	bdc49991-7bdd-411c-af88-1f56bf9a9916	06467080-462f-4467-a2ac-577bc7c7dff6	تست و اطمینان از عملکرد صحیح	202	70	2026-07-09	approved	487a4011-366a-4e1c-ac4d-6f24e62436c6	\N	e013c392-4cc6-47ac-9c98-a067ecf4a197	2026-07-20 09:59:26.363877+00	2026-07-20 09:59:26.363877+00
a03a787d-b998-4a31-aa2e-2aef31ab5784	bdc49991-7bdd-411c-af88-1f56bf9a9916	06467080-462f-4467-a2ac-577bc7c7dff6	پیاده‌سازی بخش اصلی	181	75	2026-07-16	approved	487a4011-366a-4e1c-ac4d-6f24e62436c6	\N	a857f7f5-bffe-4bd7-8708-619d3c1c2951	2026-07-20 09:59:26.363877+00	2026-07-20 09:59:26.363877+00
a03a787d-b998-4a31-aa2e-2aef31ab5784	7b2fc572-f72c-4bb6-9d5a-33dfe3d907b3	06467080-462f-4467-a2ac-577bc7c7dff6	پیاده‌سازی بخش اصلی	176	38	2026-07-02	approved	487a4011-366a-4e1c-ac4d-6f24e62436c6	\N	793e5b68-0a4d-4e1a-b7cb-03aa545bb23a	2026-07-20 09:59:26.363877+00	2026-07-20 09:59:26.363877+00
a03a787d-b998-4a31-aa2e-2aef31ab5784	7b2fc572-f72c-4bb6-9d5a-33dfe3d907b3	06467080-462f-4467-a2ac-577bc7c7dff6	مستندسازی و نهایی‌سازی	40	76	2026-07-04	approved	487a4011-366a-4e1c-ac4d-6f24e62436c6	\N	723518ed-55f9-4d48-825f-b407fe92663f	2026-07-20 09:59:26.363877+00	2026-07-20 09:59:26.363877+00
a03a787d-b998-4a31-aa2e-2aef31ab5784	7b2fc572-f72c-4bb6-9d5a-33dfe3d907b3	06467080-462f-4467-a2ac-577bc7c7dff6	رفع اشکالات و بازبینی	76	100	2026-07-06	approved	487a4011-366a-4e1c-ac4d-6f24e62436c6	\N	3bc54c88-1aa8-48af-8422-d9c5503950d4	2026-07-20 09:59:26.363877+00	2026-07-20 09:59:26.363877+00
a03a787d-b998-4a31-aa2e-2aef31ab5784	7b2fc572-f72c-4bb6-9d5a-33dfe3d907b3	06467080-462f-4467-a2ac-577bc7c7dff6	مستندسازی و نهایی‌سازی	193	80	2026-07-14	approved	487a4011-366a-4e1c-ac4d-6f24e62436c6	\N	26355e00-c988-4121-9e7d-fe175aaa2230	2026-07-20 09:59:26.363877+00	2026-07-20 09:59:26.363877+00
a03a787d-b998-4a31-aa2e-2aef31ab5784	a6d1713e-1288-4595-bf0f-51b852643d59	929fcc10-abd5-4d94-9b84-fb05ba764ba0	پیاده‌سازی بخش اصلی	144	39	2026-07-16	approved	487a4011-366a-4e1c-ac4d-6f24e62436c6	\N	b7cafc52-6921-4813-b7a5-f1e231c7e949	2026-07-20 09:59:26.363877+00	2026-07-20 09:59:26.363877+00
a03a787d-b998-4a31-aa2e-2aef31ab5784	a6d1713e-1288-4595-bf0f-51b852643d59	929fcc10-abd5-4d94-9b84-fb05ba764ba0	تست و اطمینان از عملکرد صحیح	73	54	2026-07-16	approved	487a4011-366a-4e1c-ac4d-6f24e62436c6	\N	e68d7df2-3d75-49df-a06e-0f7b5fb000fd	2026-07-20 09:59:26.363877+00	2026-07-20 09:59:26.363877+00
a03a787d-b998-4a31-aa2e-2aef31ab5784	a6d1713e-1288-4595-bf0f-51b852643d59	929fcc10-abd5-4d94-9b84-fb05ba764ba0	مستندسازی و نهایی‌سازی	66	100	2026-07-16	approved	487a4011-366a-4e1c-ac4d-6f24e62436c6	\N	57b16e4d-b0c7-4038-bf83-497627f8e8e0	2026-07-20 09:59:26.363877+00	2026-07-20 09:59:26.363877+00
a03a787d-b998-4a31-aa2e-2aef31ab5784	2a7b9365-a18b-4e9f-b80b-d803f679eca6	8eb048e0-49b1-4d8a-9e1f-ab534f5d1564	رفع اشکالات و بازبینی	146	39	2026-07-16	approved	487a4011-366a-4e1c-ac4d-6f24e62436c6	\N	5799f0f4-68fa-4a1d-9a2f-e22e9551d429	2026-07-20 09:59:26.363877+00	2026-07-20 09:59:26.363877+00
a03a787d-b998-4a31-aa2e-2aef31ab5784	2a7b9365-a18b-4e9f-b80b-d803f679eca6	8eb048e0-49b1-4d8a-9e1f-ab534f5d1564	تست و اطمینان از عملکرد صحیح	63	46	2026-07-16	approved	487a4011-366a-4e1c-ac4d-6f24e62436c6	\N	0d18cac6-ee51-46fb-b7b7-2bfab6377870	2026-07-20 09:59:26.363877+00	2026-07-20 09:59:26.363877+00
a03a787d-b998-4a31-aa2e-2aef31ab5784	5eb1887c-3398-4ad8-b2a2-30d9eb0d08ed	48c7fe74-5692-42c1-9068-c52c071221e8	مستندسازی و نهایی‌سازی	205	33	2026-07-11	approved	487a4011-366a-4e1c-ac4d-6f24e62436c6	\N	2b719035-dc87-427e-8c15-206428d388c3	2026-07-20 09:59:26.363877+00	2026-07-20 09:59:26.363877+00
a03a787d-b998-4a31-aa2e-2aef31ab5784	fa7e72e1-7750-4073-b923-34e5f7ad958e	8eb048e0-49b1-4d8a-9e1f-ab534f5d1564	پیاده‌سازی بخش اصلی	151	39	2026-07-09	approved	487a4011-366a-4e1c-ac4d-6f24e62436c6	\N	0aa20c4f-6077-4de0-95ce-efbbf664835a	2026-07-20 09:59:26.363877+00	2026-07-20 09:59:26.363877+00
a03a787d-b998-4a31-aa2e-2aef31ab5784	fa7e72e1-7750-4073-b923-34e5f7ad958e	8eb048e0-49b1-4d8a-9e1f-ab534f5d1564	مستندسازی و نهایی‌سازی	158	46	2026-07-10	approved	487a4011-366a-4e1c-ac4d-6f24e62436c6	\N	68d98603-1466-45cd-9676-1cf753a82ae3	2026-07-20 09:59:26.363877+00	2026-07-20 09:59:26.363877+00
a03a787d-b998-4a31-aa2e-2aef31ab5784	ecfc4133-a57e-484a-a90f-e825c0e976e2	487a4011-366a-4e1c-ac4d-6f24e62436c6	مستندسازی و نهایی‌سازی	168	20	2026-07-16	approved	487a4011-366a-4e1c-ac4d-6f24e62436c6	\N	cd91b4e1-6d2f-48cb-a31b-f109dfbfc96d	2026-07-20 09:59:26.363877+00	2026-07-20 09:59:26.363877+00
a03a787d-b998-4a31-aa2e-2aef31ab5784	5b68df57-3a81-4828-8755-d3a618d4b269	06467080-462f-4467-a2ac-577bc7c7dff6	پیشرفت اولیه و بررسی نیازمندی‌ها	208	36	2026-07-15	approved	487a4011-366a-4e1c-ac4d-6f24e62436c6	\N	5c4e9cd3-85b8-4b61-b124-9ea7b74386fc	2026-07-20 09:59:26.363877+00	2026-07-20 09:59:26.363877+00
a03a787d-b998-4a31-aa2e-2aef31ab5784	5b68df57-3a81-4828-8755-d3a618d4b269	06467080-462f-4467-a2ac-577bc7c7dff6	تست و اطمینان از عملکرد صحیح	232	64	2026-07-16	approved	487a4011-366a-4e1c-ac4d-6f24e62436c6	\N	9e273fc8-d619-4f5f-a457-f8f02b8de8f9	2026-07-20 09:59:26.363877+00	2026-07-20 09:59:26.363877+00
a03a787d-b998-4a31-aa2e-2aef31ab5784	5b68df57-3a81-4828-8755-d3a618d4b269	06467080-462f-4467-a2ac-577bc7c7dff6	مستندسازی و نهایی‌سازی	55	99	2026-07-16	approved	487a4011-366a-4e1c-ac4d-6f24e62436c6	\N	93865673-7fdb-4704-a115-59412f5267e2	2026-07-20 09:59:26.363877+00	2026-07-20 09:59:26.363877+00
a03a787d-b998-4a31-aa2e-2aef31ab5784	5b68df57-3a81-4828-8755-d3a618d4b269	06467080-462f-4467-a2ac-577bc7c7dff6	پیاده‌سازی بخش اصلی	51	100	2026-07-16	approved	487a4011-366a-4e1c-ac4d-6f24e62436c6	\N	afdf550d-0d08-4eb3-b634-22fda626b1b0	2026-07-20 09:59:26.363877+00	2026-07-20 09:59:26.363877+00
a03a787d-b998-4a31-aa2e-2aef31ab5784	b825fc5f-3b81-4def-8750-6de24f601e44	929fcc10-abd5-4d94-9b84-fb05ba764ba0	پیشرفت اولیه و بررسی نیازمندی‌ها	177	36	2026-06-17	approved	487a4011-366a-4e1c-ac4d-6f24e62436c6	\N	7d67922c-b676-409a-978c-ac9ca6bbeae6	2026-07-20 09:59:26.363877+00	2026-07-20 09:59:26.363877+00
a03a787d-b998-4a31-aa2e-2aef31ab5784	b825fc5f-3b81-4def-8750-6de24f601e44	929fcc10-abd5-4d94-9b84-fb05ba764ba0	تست و اطمینان از عملکرد صحیح	197	52	2026-06-18	approved	487a4011-366a-4e1c-ac4d-6f24e62436c6	\N	2130c572-cb34-42cf-9fb2-9bd4316bd9c7	2026-07-20 09:59:26.363877+00	2026-07-20 09:59:26.363877+00
a03a787d-b998-4a31-aa2e-2aef31ab5784	b825fc5f-3b81-4def-8750-6de24f601e44	929fcc10-abd5-4d94-9b84-fb05ba764ba0	پیشرفت اولیه و بررسی نیازمندی‌ها	69	99	2026-06-23	approved	487a4011-366a-4e1c-ac4d-6f24e62436c6	\N	e14e867d-19a9-40bb-9561-5aa3a4983e7c	2026-07-20 09:59:26.363877+00	2026-07-20 09:59:26.363877+00
a03a787d-b998-4a31-aa2e-2aef31ab5784	b825fc5f-3b81-4def-8750-6de24f601e44	929fcc10-abd5-4d94-9b84-fb05ba764ba0	مستندسازی و نهایی‌سازی	138	100	2026-06-26	approved	487a4011-366a-4e1c-ac4d-6f24e62436c6	\N	07c76308-e4d9-4306-864b-a00e83fbea36	2026-07-20 09:59:26.363877+00	2026-07-20 09:59:26.363877+00
a03a787d-b998-4a31-aa2e-2aef31ab5784	b79cc6ea-affe-4198-98cc-8dc1704c013a	487a4011-366a-4e1c-ac4d-6f24e62436c6	تست و اطمینان از عملکرد صحیح	223	26	2026-06-23	approved	487a4011-366a-4e1c-ac4d-6f24e62436c6	\N	050027a6-1add-438d-a207-f1169fb1af51	2026-07-20 09:59:26.363877+00	2026-07-20 09:59:26.363877+00
a03a787d-b998-4a31-aa2e-2aef31ab5784	b79cc6ea-affe-4198-98cc-8dc1704c013a	487a4011-366a-4e1c-ac4d-6f24e62436c6	مستندسازی و نهایی‌سازی	230	74	2026-06-27	approved	487a4011-366a-4e1c-ac4d-6f24e62436c6	\N	a691f8b9-a2b0-4721-9b61-5eaa7dceaeeb	2026-07-20 09:59:26.363877+00	2026-07-20 09:59:26.363877+00
a03a787d-b998-4a31-aa2e-2aef31ab5784	b79cc6ea-affe-4198-98cc-8dc1704c013a	487a4011-366a-4e1c-ac4d-6f24e62436c6	پیاده‌سازی بخش اصلی	124	100	2026-07-01	approved	487a4011-366a-4e1c-ac4d-6f24e62436c6	\N	4629b3ca-a951-4332-88c1-d29b00a243da	2026-07-20 09:59:26.363877+00	2026-07-20 09:59:26.363877+00
a03a787d-b998-4a31-aa2e-2aef31ab5784	4ea4ffaa-389f-434c-8d7b-b63a6fd6d732	3de0e871-5193-4e41-885f-531073da833a	رفع اشکالات و بازبینی	177	31	2026-07-16	approved	487a4011-366a-4e1c-ac4d-6f24e62436c6	\N	ac2373c8-8146-4816-a86b-23e627a5aa68	2026-07-20 09:59:26.363877+00	2026-07-20 09:59:26.363877+00
a03a787d-b998-4a31-aa2e-2aef31ab5784	4ea4ffaa-389f-434c-8d7b-b63a6fd6d732	3de0e871-5193-4e41-885f-531073da833a	پیاده‌سازی بخش اصلی	198	46	2026-07-16	approved	487a4011-366a-4e1c-ac4d-6f24e62436c6	\N	204a7483-6206-4ffa-bb08-e0cd072fd867	2026-07-20 09:59:26.363877+00	2026-07-20 09:59:26.363877+00
a03a787d-b998-4a31-aa2e-2aef31ab5784	4ea4ffaa-389f-434c-8d7b-b63a6fd6d732	3de0e871-5193-4e41-885f-531073da833a	تست و اطمینان از عملکرد صحیح	230	75	2026-07-16	approved	487a4011-366a-4e1c-ac4d-6f24e62436c6	\N	e00b63b0-4433-441b-94af-336790986886	2026-07-20 09:59:26.363877+00	2026-07-20 09:59:26.363877+00
a03a787d-b998-4a31-aa2e-2aef31ab5784	4ea4ffaa-389f-434c-8d7b-b63a6fd6d732	3de0e871-5193-4e41-885f-531073da833a	پیاده‌سازی بخش اصلی	160	100	2026-07-16	approved	487a4011-366a-4e1c-ac4d-6f24e62436c6	\N	beddf4d5-f460-40c8-8faa-6a526ba8c6cf	2026-07-20 09:59:26.363877+00	2026-07-20 09:59:26.363877+00
a03a787d-b998-4a31-aa2e-2aef31ab5784	575e6493-aa8a-46d9-acc4-27a41822634d	48c7fe74-5692-42c1-9068-c52c071221e8	پیاده‌سازی بخش اصلی	129	40	2026-07-12	approved	487a4011-366a-4e1c-ac4d-6f24e62436c6	\N	5a3134fd-93d0-407b-8e4d-e14b9cee8049	2026-07-20 09:59:26.363877+00	2026-07-20 09:59:26.363877+00
a03a787d-b998-4a31-aa2e-2aef31ab5784	575e6493-aa8a-46d9-acc4-27a41822634d	48c7fe74-5692-42c1-9068-c52c071221e8	پیشرفت اولیه و بررسی نیازمندی‌ها	240	48	2026-07-13	approved	487a4011-366a-4e1c-ac4d-6f24e62436c6	\N	ba68465f-29ae-4364-b92e-22375b0ad50c	2026-07-20 09:59:26.363877+00	2026-07-20 09:59:26.363877+00
a03a787d-b998-4a31-aa2e-2aef31ab5784	575e6493-aa8a-46d9-acc4-27a41822634d	48c7fe74-5692-42c1-9068-c52c071221e8	مستندسازی و نهایی‌سازی	141	66	2026-07-16	approved	487a4011-366a-4e1c-ac4d-6f24e62436c6	\N	a1c937c1-9e68-44f9-83da-d5c479a7f5a5	2026-07-20 09:59:26.363877+00	2026-07-20 09:59:26.363877+00
a03a787d-b998-4a31-aa2e-2aef31ab5784	d570cd0c-b466-4ae6-b8e0-6b4c2fac708f	fac1f37f-7665-4a91-b497-43238269a2e8	پیاده‌سازی بخش اصلی	124	22	2026-07-16	approved	487a4011-366a-4e1c-ac4d-6f24e62436c6	\N	4ea5ee82-765d-4a6c-b848-5a255f2babf4	2026-07-20 09:59:26.363877+00	2026-07-20 09:59:26.363877+00
a03a787d-b998-4a31-aa2e-2aef31ab5784	a894e7b2-485d-4dbc-9490-6a066715a433	06467080-462f-4467-a2ac-577bc7c7dff6	تست و اطمینان از عملکرد صحیح	187	40	2026-07-08	approved	487a4011-366a-4e1c-ac4d-6f24e62436c6	\N	d7a00b8f-2872-4a7d-9d55-484d19b19ee1	2026-07-20 09:59:26.363877+00	2026-07-20 09:59:26.363877+00
a03a787d-b998-4a31-aa2e-2aef31ab5784	081bfe26-75bf-4f2e-b0c3-974827627546	3de0e871-5193-4e41-885f-531073da833a	پیاده‌سازی بخش اصلی	193	35	2026-07-16	submitted	\N	\N	32849418-39e0-43a0-b4f0-b9d3aa5a0671	2026-07-20 09:59:26.363877+00	2026-07-20 09:59:26.363877+00
a03a787d-b998-4a31-aa2e-2aef31ab5784	081bfe26-75bf-4f2e-b0c3-974827627546	3de0e871-5193-4e41-885f-531073da833a	مستندسازی و نهایی‌سازی	103	52	2026-07-16	approved	487a4011-366a-4e1c-ac4d-6f24e62436c6	\N	91f5fb8e-1525-4133-bf09-f203c1937e89	2026-07-20 09:59:26.363877+00	2026-07-20 09:59:26.363877+00
a03a787d-b998-4a31-aa2e-2aef31ab5784	081bfe26-75bf-4f2e-b0c3-974827627546	3de0e871-5193-4e41-885f-531073da833a	مستندسازی و نهایی‌سازی	162	81	2026-07-16	submitted	\N	\N	3f9e9325-5204-4676-8217-7e6924175e8a	2026-07-20 09:59:26.363877+00	2026-07-20 09:59:26.363877+00
a03a787d-b998-4a31-aa2e-2aef31ab5784	a9685974-643c-4e8d-8523-60f40134a3da	929fcc10-abd5-4d94-9b84-fb05ba764ba0	رفع اشکالات و بازبینی	91	40	2026-07-16	approved	487a4011-366a-4e1c-ac4d-6f24e62436c6	\N	44af531c-fb39-442e-acb3-0c04f7770c3f	2026-07-20 09:59:26.363877+00	2026-07-20 09:59:26.363877+00
a03a787d-b998-4a31-aa2e-2aef31ab5784	a9685974-643c-4e8d-8523-60f40134a3da	929fcc10-abd5-4d94-9b84-fb05ba764ba0	پیاده‌سازی بخش اصلی	52	56	2026-07-16	approved	487a4011-366a-4e1c-ac4d-6f24e62436c6	\N	a8d4d3a0-fb12-442d-b02b-7578d4d9e0f9	2026-07-20 09:59:26.363877+00	2026-07-20 09:59:26.363877+00
a03a787d-b998-4a31-aa2e-2aef31ab5784	2bee29de-2343-4617-8e54-9f266f894d49	3de0e871-5193-4e41-885f-531073da833a	تست و اطمینان از عملکرد صحیح	180	26	2026-07-02	approved	487a4011-366a-4e1c-ac4d-6f24e62436c6	\N	385bac32-9d94-4d2b-9995-d7c50440abc2	2026-07-20 09:59:26.363877+00	2026-07-20 09:59:26.363877+00
a03a787d-b998-4a31-aa2e-2aef31ab5784	2bee29de-2343-4617-8e54-9f266f894d49	3de0e871-5193-4e41-885f-531073da833a	پیشرفت اولیه و بررسی نیازمندی‌ها	53	74	2026-07-03	submitted	\N	\N	01210587-e8ab-4475-b60b-b594adbb5612	2026-07-20 09:59:26.363877+00	2026-07-20 09:59:26.363877+00
a03a787d-b998-4a31-aa2e-2aef31ab5784	2bee29de-2343-4617-8e54-9f266f894d49	3de0e871-5193-4e41-885f-531073da833a	مستندسازی و نهایی‌سازی	179	93	2026-07-08	submitted	\N	\N	a1a67712-d29c-44ed-b2dc-d33a68186892	2026-07-20 09:59:26.363877+00	2026-07-20 09:59:26.363877+00
a03a787d-b998-4a31-aa2e-2aef31ab5784	2bee29de-2343-4617-8e54-9f266f894d49	3de0e871-5193-4e41-885f-531073da833a	رفع اشکالات و بازبینی	87	100	2026-07-11	submitted	\N	\N	e8619cff-2cd7-47b9-9193-493ed45bfa21	2026-07-20 09:59:26.363877+00	2026-07-20 09:59:26.363877+00
a03a787d-b998-4a31-aa2e-2aef31ab5784	ad8526ac-92f0-4b0b-9a03-f24a2d7ed22d	929fcc10-abd5-4d94-9b84-fb05ba764ba0	مستندسازی و نهایی‌سازی	31	28	2026-07-09	submitted	\N	\N	89955ad4-8bb2-4171-956a-af4efeecbfb7	2026-07-20 09:59:26.363877+00	2026-07-20 09:59:26.363877+00
a03a787d-b998-4a31-aa2e-2aef31ab5784	ad8526ac-92f0-4b0b-9a03-f24a2d7ed22d	929fcc10-abd5-4d94-9b84-fb05ba764ba0	پیشرفت اولیه و بررسی نیازمندی‌ها	173	44	2026-07-11	approved	487a4011-366a-4e1c-ac4d-6f24e62436c6	\N	b700e05f-8e52-4fc0-81da-afb3d87f2ed9	2026-07-20 09:59:26.363877+00	2026-07-20 09:59:26.363877+00
a03a787d-b998-4a31-aa2e-2aef31ab5784	3db269cd-c7c2-40df-8025-3c85bc1545f4	3de0e871-5193-4e41-885f-531073da833a	پیشرفت اولیه و بررسی نیازمندی‌ها	235	36	2026-07-16	approved	487a4011-366a-4e1c-ac4d-6f24e62436c6	\N	701f0ec1-f17d-4741-b9af-68e0f93a383f	2026-07-20 09:59:26.363877+00	2026-07-20 09:59:26.363877+00
a03a787d-b998-4a31-aa2e-2aef31ab5784	3db269cd-c7c2-40df-8025-3c85bc1545f4	3de0e871-5193-4e41-885f-531073da833a	مستندسازی و نهایی‌سازی	238	76	2026-07-16	approved	487a4011-366a-4e1c-ac4d-6f24e62436c6	\N	6e7c2682-7529-44fc-83c1-da2a895a69ce	2026-07-20 09:59:26.363877+00	2026-07-20 09:59:26.363877+00
a03a787d-b998-4a31-aa2e-2aef31ab5784	3db269cd-c7c2-40df-8025-3c85bc1545f4	3de0e871-5193-4e41-885f-531073da833a	تست و اطمینان از عملکرد صحیح	126	100	2026-07-16	approved	487a4011-366a-4e1c-ac4d-6f24e62436c6	\N	25251470-f781-4314-a617-2960824f5321	2026-07-20 09:59:26.363877+00	2026-07-20 09:59:26.363877+00
a03a787d-b998-4a31-aa2e-2aef31ab5784	301452c7-449a-4e95-9bc9-66fee3ac2faa	3de0e871-5193-4e41-885f-531073da833a	تست و اطمینان از عملکرد صحیح	204	34	2026-07-15	submitted	\N	\N	3a6cd239-2fff-4df5-b82d-16b54b15e29f	2026-07-20 09:59:26.363877+00	2026-07-20 09:59:26.363877+00
a03a787d-b998-4a31-aa2e-2aef31ab5784	301452c7-449a-4e95-9bc9-66fee3ac2faa	3de0e871-5193-4e41-885f-531073da833a	رفع اشکالات و بازبینی	47	64	2026-07-16	approved	487a4011-366a-4e1c-ac4d-6f24e62436c6	\N	eec2017f-5dc8-4fc8-a3b4-e5080fc2a020	2026-07-20 09:59:26.363877+00	2026-07-20 09:59:26.363877+00
a03a787d-b998-4a31-aa2e-2aef31ab5784	301452c7-449a-4e95-9bc9-66fee3ac2faa	3de0e871-5193-4e41-885f-531073da833a	پیاده‌سازی بخش اصلی	234	90	2026-07-16	approved	487a4011-366a-4e1c-ac4d-6f24e62436c6	\N	ebef23d0-f047-44b5-8cf9-7716ae272637	2026-07-20 09:59:26.363877+00	2026-07-20 09:59:26.363877+00
a03a787d-b998-4a31-aa2e-2aef31ab5784	301452c7-449a-4e95-9bc9-66fee3ac2faa	3de0e871-5193-4e41-885f-531073da833a	مستندسازی و نهایی‌سازی	167	80	2026-07-16	submitted	\N	\N	67dc28f6-7fef-4803-8e9b-6fb2ff63b3fc	2026-07-20 09:59:26.363877+00	2026-07-20 09:59:26.363877+00
a03a787d-b998-4a31-aa2e-2aef31ab5784	e1d35c64-ccda-4b08-a84f-e4688fd5495b	48c7fe74-5692-42c1-9068-c52c071221e8	رفع اشکالات و بازبینی	53	32	2026-07-10	approved	487a4011-366a-4e1c-ac4d-6f24e62436c6	\N	03d08867-055a-49b9-82a4-d81f8057ff3e	2026-07-20 09:59:26.363877+00	2026-07-20 09:59:26.363877+00
a03a787d-b998-4a31-aa2e-2aef31ab5784	e1d35c64-ccda-4b08-a84f-e4688fd5495b	48c7fe74-5692-42c1-9068-c52c071221e8	پیشرفت اولیه و بررسی نیازمندی‌ها	171	50	2026-07-13	approved	487a4011-366a-4e1c-ac4d-6f24e62436c6	\N	b8015ed4-308d-498b-95fe-b2d3a706c11a	2026-07-20 09:59:26.363877+00	2026-07-20 09:59:26.363877+00
a03a787d-b998-4a31-aa2e-2aef31ab5784	e1d35c64-ccda-4b08-a84f-e4688fd5495b	48c7fe74-5692-42c1-9068-c52c071221e8	رفع اشکالات و بازبینی	120	78	2026-07-16	approved	487a4011-366a-4e1c-ac4d-6f24e62436c6	\N	071c4ad0-6a86-4af5-be85-26adfe6c8724	2026-07-20 09:59:26.363877+00	2026-07-20 09:59:26.363877+00
a03a787d-b998-4a31-aa2e-2aef31ab5784	335ef8ba-6ec0-4d31-9d09-0ae3f5b239a1	929fcc10-abd5-4d94-9b84-fb05ba764ba0	پیاده‌سازی بخش اصلی	157	26	2026-07-16	approved	487a4011-366a-4e1c-ac4d-6f24e62436c6	\N	c967b774-4a14-4276-9bf2-06dc1b46286b	2026-07-20 09:59:26.363877+00	2026-07-20 09:59:26.363877+00
a03a787d-b998-4a31-aa2e-2aef31ab5784	335ef8ba-6ec0-4d31-9d09-0ae3f5b239a1	929fcc10-abd5-4d94-9b84-fb05ba764ba0	پیاده‌سازی بخش اصلی	97	52	2026-07-16	approved	487a4011-366a-4e1c-ac4d-6f24e62436c6	\N	95dbb9b7-7abf-4246-9ea1-a0eb5859903f	2026-07-20 09:59:26.363877+00	2026-07-20 09:59:26.363877+00
a03a787d-b998-4a31-aa2e-2aef31ab5784	335ef8ba-6ec0-4d31-9d09-0ae3f5b239a1	929fcc10-abd5-4d94-9b84-fb05ba764ba0	پیاده‌سازی بخش اصلی	93	100	2026-07-16	approved	487a4011-366a-4e1c-ac4d-6f24e62436c6	\N	004d0fa8-a851-4b13-820e-3d56a3f28e85	2026-07-20 09:59:26.363877+00	2026-07-20 09:59:26.363877+00
a03a787d-b998-4a31-aa2e-2aef31ab5784	cee1c0ec-7d0b-4422-99cf-f8d95711b2d8	48c7fe74-5692-42c1-9068-c52c071221e8	پیشرفت اولیه و بررسی نیازمندی‌ها	60	22	2026-07-16	approved	487a4011-366a-4e1c-ac4d-6f24e62436c6	\N	8537c6db-cb2c-4701-b974-d5cba5b86cfd	2026-07-20 09:59:26.363877+00	2026-07-20 09:59:26.363877+00
a03a787d-b998-4a31-aa2e-2aef31ab5784	cee1c0ec-7d0b-4422-99cf-f8d95711b2d8	48c7fe74-5692-42c1-9068-c52c071221e8	مستندسازی و نهایی‌سازی	31	74	2026-07-16	approved	487a4011-366a-4e1c-ac4d-6f24e62436c6	\N	e1844034-63f9-4604-9e73-17286acfa5b0	2026-07-20 09:59:26.363877+00	2026-07-20 09:59:26.363877+00
a03a787d-b998-4a31-aa2e-2aef31ab5784	cee1c0ec-7d0b-4422-99cf-f8d95711b2d8	48c7fe74-5692-42c1-9068-c52c071221e8	تست و اطمینان از عملکرد صحیح	125	100	2026-07-16	approved	487a4011-366a-4e1c-ac4d-6f24e62436c6	\N	7346b1fd-2f0c-4cd6-b6f2-ad8e5629c434	2026-07-20 09:59:26.363877+00	2026-07-20 09:59:26.363877+00
a03a787d-b998-4a31-aa2e-2aef31ab5784	6d425010-a6fd-457f-b610-589c92b5737c	fac1f37f-7665-4a91-b497-43238269a2e8	مستندسازی و نهایی‌سازی	100	35	2026-07-16	approved	487a4011-366a-4e1c-ac4d-6f24e62436c6	\N	e47a6e39-04b3-4741-82a8-c76ace2b8a05	2026-07-20 09:59:26.363877+00	2026-07-20 09:59:26.363877+00
a03a787d-b998-4a31-aa2e-2aef31ab5784	6d425010-a6fd-457f-b610-589c92b5737c	fac1f37f-7665-4a91-b497-43238269a2e8	مستندسازی و نهایی‌سازی	101	64	2026-07-16	approved	487a4011-366a-4e1c-ac4d-6f24e62436c6	\N	6b9e5793-ee92-4562-9b42-5f684881f635	2026-07-20 09:59:26.363877+00	2026-07-20 09:59:26.363877+00
a03a787d-b998-4a31-aa2e-2aef31ab5784	6d425010-a6fd-457f-b610-589c92b5737c	fac1f37f-7665-4a91-b497-43238269a2e8	مستندسازی و نهایی‌سازی	62	63	2026-07-16	approved	487a4011-366a-4e1c-ac4d-6f24e62436c6	\N	72e82079-dedf-44c8-9e02-a27a50603af0	2026-07-20 09:59:26.363877+00	2026-07-20 09:59:26.363877+00
a03a787d-b998-4a31-aa2e-2aef31ab5784	6d300990-f017-46bc-a27a-f5a9df2a53d3	3de0e871-5193-4e41-885f-531073da833a	پیشرفت اولیه و بررسی نیازمندی‌ها	158	31	2026-07-16	submitted	\N	\N	43eaf1d1-7b17-451c-be3b-762cbf6b241b	2026-07-20 09:59:26.363877+00	2026-07-20 09:59:26.363877+00
a03a787d-b998-4a31-aa2e-2aef31ab5784	6d300990-f017-46bc-a27a-f5a9df2a53d3	3de0e871-5193-4e41-885f-531073da833a	پیاده‌سازی بخش اصلی	147	46	2026-07-16	submitted	\N	\N	78fde021-fe0b-4fec-8fac-6f9e13b876bd	2026-07-20 09:59:26.363877+00	2026-07-20 09:59:26.363877+00
a03a787d-b998-4a31-aa2e-2aef31ab5784	6d300990-f017-46bc-a27a-f5a9df2a53d3	3de0e871-5193-4e41-885f-531073da833a	پیشرفت اولیه و بررسی نیازمندی‌ها	33	78	2026-07-16	approved	487a4011-366a-4e1c-ac4d-6f24e62436c6	\N	025c40a9-8577-4124-8459-6dfb42e1cfc3	2026-07-20 09:59:26.363877+00	2026-07-20 09:59:26.363877+00
a03a787d-b998-4a31-aa2e-2aef31ab5784	6d300990-f017-46bc-a27a-f5a9df2a53d3	3de0e871-5193-4e41-885f-531073da833a	رفع اشکالات و بازبینی	122	100	2026-07-16	approved	487a4011-366a-4e1c-ac4d-6f24e62436c6	\N	b1302449-8644-4914-a8d2-74a39b72ff4a	2026-07-20 09:59:26.363877+00	2026-07-20 09:59:26.363877+00
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


