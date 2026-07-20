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
067cfe90-6907-456c-9779-555fc549ad12	2026-07-20 11:46:45.199839+00	2026-07-20 11:46:45.199839+00	6fa5de46-9edd-404a-915e-89d9f3f21ae7	6367109c-4684-4a1b-a6b5-9843aa3f6a9d	1c7c9744-f184-4945-939c-92a23d462b12	\N	جلسهٔ برنامه‌ریزی اسپرینت	\N	meeting	2026-06-20 10:00:00+00	2026-06-20 11:00:00+00	f
b9ef33ca-a533-4beb-844d-7a9ba424d383	2026-07-20 11:46:45.199839+00	2026-07-20 11:46:45.199839+00	6fa5de46-9edd-404a-915e-89d9f3f21ae7	fd5161f1-4abf-4cc9-8f06-914566393088	23082ced-9e61-45d1-bb62-c2bd122dbba1	\N	یادآوری ارسال گزارش	\N	reminder	2026-06-17 00:00:00+00	2026-06-17 01:00:00+00	t
4a71d9e8-835a-4305-a44c-521918ec4a91	2026-07-20 11:46:45.199839+00	2026-07-20 11:46:45.199839+00	6fa5de46-9edd-404a-915e-89d9f3f21ae7	6367109c-4684-4a1b-a6b5-9843aa3f6a9d	1c7c9744-f184-4945-939c-92a23d462b12	\N	جلسهٔ برنامه‌ریزی اسپرینت	\N	meeting	2026-06-27 10:00:00+00	2026-06-27 11:00:00+00	f
1707e790-e127-4038-b6a3-af85f7e34e6d	2026-07-20 11:46:45.199839+00	2026-07-20 11:46:45.199839+00	6fa5de46-9edd-404a-915e-89d9f3f21ae7	fd5161f1-4abf-4cc9-8f06-914566393088	4d1e5701-762a-4826-afcd-c7c64e14ccb5	\N	یادآوری پیگیری مشتری	\N	reminder	2026-06-23 00:00:00+00	2026-06-23 01:00:00+00	t
5212810a-bf6c-45a0-97b7-fc12a36de6ba	2026-07-20 11:46:45.199839+00	2026-07-20 11:46:45.199839+00	6fa5de46-9edd-404a-915e-89d9f3f21ae7	6367109c-4684-4a1b-a6b5-9843aa3f6a9d	4d1e5701-762a-4826-afcd-c7c64e14ccb5	\N	جلسهٔ هماهنگی هفتگی	\N	meeting	2026-07-04 10:00:00+00	2026-07-04 11:00:00+00	f
3c337533-e625-4291-ac1f-926124529a0e	2026-07-20 11:46:45.199839+00	2026-07-20 11:46:45.199839+00	6fa5de46-9edd-404a-915e-89d9f3f21ae7	a42bd423-3577-42e0-b239-611eb7480fb9	1c7c9744-f184-4945-939c-92a23d462b12	\N	یادآوری پیگیری مشتری	\N	reminder	2026-07-03 00:00:00+00	2026-07-03 01:00:00+00	t
0dbd7d21-f03e-49f2-ac92-3a66c5c7a05c	2026-07-20 11:46:45.199839+00	2026-07-20 11:46:45.199839+00	6fa5de46-9edd-404a-915e-89d9f3f21ae7	6367109c-4684-4a1b-a6b5-9843aa3f6a9d	23082ced-9e61-45d1-bb62-c2bd122dbba1	\N	جلسهٔ برنامه‌ریزی اسپرینت	\N	meeting	2026-07-09 10:00:00+00	2026-07-09 11:00:00+00	f
9d7d8033-1f11-4d85-912a-ea2a61aed169	2026-07-20 11:46:45.199839+00	2026-07-20 11:46:45.199839+00	6fa5de46-9edd-404a-915e-89d9f3f21ae7	7c364485-75f2-4d57-81ee-62ec42c62177	b2c5e0fe-deb4-4a0f-bf3b-58b26bc437f5	\N	یادآوری ارسال گزارش	\N	reminder	2026-07-12 00:00:00+00	2026-07-12 01:00:00+00	t
41a52678-8973-4107-b3ea-91dd3abe0f7e	2026-07-20 11:46:45.199839+00	2026-07-20 11:46:45.199839+00	6fa5de46-9edd-404a-915e-89d9f3f21ae7	6367109c-4684-4a1b-a6b5-9843aa3f6a9d	b2c5e0fe-deb4-4a0f-bf3b-58b26bc437f5	\N	جلسهٔ هماهنگی هفتگی	\N	meeting	2026-07-15 10:00:00+00	2026-07-15 11:00:00+00	f
f291e62a-21e9-4e1c-8fe8-f2227bfda3d1	2026-07-20 11:46:45.199839+00	2026-07-20 11:46:45.199839+00	6fa5de46-9edd-404a-915e-89d9f3f21ae7	fd5161f1-4abf-4cc9-8f06-914566393088	b2c5e0fe-deb4-4a0f-bf3b-58b26bc437f5	\N	یادآوری ارسال گزارش	\N	reminder	2026-07-20 00:00:00+00	2026-07-20 01:00:00+00	t
9151ec34-1ed3-4b4d-97ba-080ac567c058	2026-07-20 11:46:45.199839+00	2026-07-20 11:46:45.199839+00	6fa5de46-9edd-404a-915e-89d9f3f21ae7	6367109c-4684-4a1b-a6b5-9843aa3f6a9d	1c7c9744-f184-4945-939c-92a23d462b12	\N	جلسهٔ برنامه‌ریزی اسپرینت	\N	meeting	2026-07-23 10:00:00+00	2026-07-23 11:00:00+00	f
d86e0a5f-7b39-48d9-81f7-293e9a6fbc8e	2026-07-20 11:46:45.199839+00	2026-07-20 11:46:45.199839+00	6fa5de46-9edd-404a-915e-89d9f3f21ae7	a34644cb-4fa6-4ad1-904f-3e26b23679cd	adfcac3e-63b8-4b84-a951-57550e399e3a	\N	یادآوری پیگیری مشتری	\N	reminder	2026-07-27 00:00:00+00	2026-07-27 01:00:00+00	t
01e862d7-6db8-4c8f-a0e1-51a8c42bbb68	2026-07-20 11:46:45.199839+00	2026-07-20 11:46:45.199839+00	6fa5de46-9edd-404a-915e-89d9f3f21ae7	6367109c-4684-4a1b-a6b5-9843aa3f6a9d	23082ced-9e61-45d1-bb62-c2bd122dbba1	\N	جلسهٔ بررسی پیشرفت پروژه	\N	meeting	2026-07-31 10:00:00+00	2026-07-31 11:00:00+00	f
e53b59a8-265a-4679-9d2d-19ab2799aec9	2026-07-20 11:46:45.199839+00	2026-07-20 11:46:45.199839+00	6fa5de46-9edd-404a-915e-89d9f3f21ae7	398f8c1c-1d8b-48eb-9aed-08ebb479cff3	1c7c9744-f184-4945-939c-92a23d462b12	\N	یادآوری پیگیری مشتری	\N	reminder	2026-08-03 00:00:00+00	2026-08-03 01:00:00+00	t
a461a435-b035-4d5e-8e36-20e7e1670912	2026-07-20 11:46:45.199839+00	2026-07-20 11:46:45.199839+00	6fa5de46-9edd-404a-915e-89d9f3f21ae7	6367109c-4684-4a1b-a6b5-9843aa3f6a9d	23082ced-9e61-45d1-bb62-c2bd122dbba1	\N	جلسهٔ برنامه‌ریزی اسپرینت	\N	meeting	2026-08-04 10:00:00+00	2026-08-04 11:00:00+00	f
2bbd2998-c031-42a2-a1fa-88ea58116096	2026-07-20 11:46:45.199839+00	2026-07-20 11:46:45.199839+00	6fa5de46-9edd-404a-915e-89d9f3f21ae7	7c364485-75f2-4d57-81ee-62ec42c62177	adfcac3e-63b8-4b84-a951-57550e399e3a	\N	یادآوری ارسال گزارش	\N	reminder	2026-08-05 00:00:00+00	2026-08-05 01:00:00+00	t
c187bc44-aa85-4055-809d-6f807359b804	2026-07-20 11:46:45.199839+00	2026-07-20 11:46:45.199839+00	6fa5de46-9edd-404a-915e-89d9f3f21ae7	6367109c-4684-4a1b-a6b5-9843aa3f6a9d	b2c5e0fe-deb4-4a0f-bf3b-58b26bc437f5	\N	جلسهٔ مرور با مدیریت	\N	meeting	2026-08-13 10:00:00+00	2026-08-13 11:00:00+00	f
3393a0b1-5a1a-4851-9b80-13c185a8717a	2026-07-20 11:46:45.199839+00	2026-07-20 11:46:45.199839+00	6fa5de46-9edd-404a-915e-89d9f3f21ae7	fd5161f1-4abf-4cc9-8f06-914566393088	23082ced-9e61-45d1-bb62-c2bd122dbba1	\N	یادآوری تمدید قرارداد	\N	reminder	2026-08-17 00:00:00+00	2026-08-17 01:00:00+00	t
e2ea062d-903d-47df-89d3-0b7028f7f1fa	2026-07-20 11:46:45.199839+00	2026-07-20 11:46:45.199839+00	6fa5de46-9edd-404a-915e-89d9f3f21ae7	6f0889c3-21cf-4af8-92e8-834e06a4a09c	948c5ce5-0757-4628-be4f-0a827239068b	\N	جلسهٔ برنامه‌ریزی اسپرینت	\N	meeting	2026-06-17 10:00:00+00	2026-06-17 11:00:00+00	f
822d73e3-ab58-4ec0-8189-edace5480e7d	2026-07-20 11:46:45.199839+00	2026-07-20 11:46:45.199839+00	6fa5de46-9edd-404a-915e-89d9f3f21ae7	3cba84f1-51a4-4831-ac2b-61b820a1122a	948c5ce5-0757-4628-be4f-0a827239068b	\N	یادآوری تمدید قرارداد	\N	reminder	2026-06-19 00:00:00+00	2026-06-19 01:00:00+00	t
7db11e02-75bd-4714-86ab-5dea1f9c64a2	2026-07-20 11:46:45.199839+00	2026-07-20 11:46:45.199839+00	6fa5de46-9edd-404a-915e-89d9f3f21ae7	6f0889c3-21cf-4af8-92e8-834e06a4a09c	abe514ef-e3c3-4d74-859b-cb25c77c879d	\N	جلسهٔ برنامه‌ریزی اسپرینت	\N	meeting	2026-06-23 10:00:00+00	2026-06-23 11:00:00+00	f
92ff5bff-de1d-42fe-b6c3-5e50d6064e81	2026-07-20 11:46:45.199839+00	2026-07-20 11:46:45.199839+00	6fa5de46-9edd-404a-915e-89d9f3f21ae7	eeebc2e6-a734-4f02-8d65-173ba01323d3	e6e0814d-c93d-4ff2-ac03-0f95e574998a	\N	یادآوری ارسال گزارش	\N	reminder	2026-06-26 00:00:00+00	2026-06-26 01:00:00+00	t
579a37e0-1fbb-4b60-bf7f-cecc9d703cfc	2026-07-20 11:46:45.199839+00	2026-07-20 11:46:45.199839+00	6fa5de46-9edd-404a-915e-89d9f3f21ae7	6f0889c3-21cf-4af8-92e8-834e06a4a09c	948c5ce5-0757-4628-be4f-0a827239068b	\N	جلسهٔ هماهنگی هفتگی	\N	meeting	2026-07-01 10:00:00+00	2026-07-01 11:00:00+00	f
8f201e0c-982a-488d-bcb1-ef79819b2cfc	2026-07-20 11:46:45.199839+00	2026-07-20 11:46:45.199839+00	6fa5de46-9edd-404a-915e-89d9f3f21ae7	c28803c6-5155-4136-94b4-4f91ec6ee698	a38f3ca8-458d-4d9a-8c39-fd18807ebffc	\N	یادآوری تمدید قرارداد	\N	reminder	2026-07-03 00:00:00+00	2026-07-03 01:00:00+00	t
1f99ae94-9a73-4d9b-91d5-51df73545e2d	2026-07-20 11:46:45.199839+00	2026-07-20 11:46:45.199839+00	6fa5de46-9edd-404a-915e-89d9f3f21ae7	6f0889c3-21cf-4af8-92e8-834e06a4a09c	948c5ce5-0757-4628-be4f-0a827239068b	\N	جلسهٔ برنامه‌ریزی اسپرینت	\N	meeting	2026-07-10 10:00:00+00	2026-07-10 11:00:00+00	f
138212ec-bae9-49b2-ac67-aa5ca3cf1e60	2026-07-20 11:46:45.199839+00	2026-07-20 11:46:45.199839+00	6fa5de46-9edd-404a-915e-89d9f3f21ae7	ca92a9d5-cf4a-4b8b-9fe5-6fadd5c44ca2	a38f3ca8-458d-4d9a-8c39-fd18807ebffc	\N	یادآوری تمدید قرارداد	\N	reminder	2026-07-11 00:00:00+00	2026-07-11 01:00:00+00	t
8450fdaf-5dc7-40dd-87bd-e48d6cf7570b	2026-07-20 11:46:45.199839+00	2026-07-20 11:46:45.199839+00	6fa5de46-9edd-404a-915e-89d9f3f21ae7	6f0889c3-21cf-4af8-92e8-834e06a4a09c	a38f3ca8-458d-4d9a-8c39-fd18807ebffc	\N	جلسهٔ هماهنگی هفتگی	\N	meeting	2026-07-15 10:00:00+00	2026-07-15 11:00:00+00	f
15b6fdd5-3a88-4b70-9865-88641d85aaa7	2026-07-20 11:46:45.199839+00	2026-07-20 11:46:45.199839+00	6fa5de46-9edd-404a-915e-89d9f3f21ae7	ca92a9d5-cf4a-4b8b-9fe5-6fadd5c44ca2	ad7056fc-1499-4430-8506-dc250e383b19	\N	یادآوری ارسال گزارش	\N	reminder	2026-07-16 00:00:00+00	2026-07-16 01:00:00+00	t
631e703a-58ae-4775-acb9-e6ddf1b29734	2026-07-20 11:46:45.199839+00	2026-07-20 11:46:45.199839+00	6fa5de46-9edd-404a-915e-89d9f3f21ae7	6f0889c3-21cf-4af8-92e8-834e06a4a09c	a38f3ca8-458d-4d9a-8c39-fd18807ebffc	\N	جلسهٔ مرور با مدیریت	\N	meeting	2026-07-21 10:00:00+00	2026-07-21 11:00:00+00	f
cfb7b499-91f0-4692-92dc-466a5ded6b23	2026-07-20 11:46:45.199839+00	2026-07-20 11:46:45.199839+00	6fa5de46-9edd-404a-915e-89d9f3f21ae7	56ee4c58-1504-48a5-b37d-7d040bb2bd16	948c5ce5-0757-4628-be4f-0a827239068b	\N	یادآوری ارسال گزارش	\N	reminder	2026-07-25 00:00:00+00	2026-07-25 01:00:00+00	t
7a818f22-b494-4e42-a626-2d6f9ae2c392	2026-07-20 11:46:45.199839+00	2026-07-20 11:46:45.199839+00	6fa5de46-9edd-404a-915e-89d9f3f21ae7	6f0889c3-21cf-4af8-92e8-834e06a4a09c	ad7056fc-1499-4430-8506-dc250e383b19	\N	جلسهٔ بررسی پیشرفت پروژه	\N	meeting	2026-07-28 10:00:00+00	2026-07-28 11:00:00+00	f
a5f0d97f-56c4-4a31-9ee6-7cc024e7766a	2026-07-20 11:46:45.199839+00	2026-07-20 11:46:45.199839+00	6fa5de46-9edd-404a-915e-89d9f3f21ae7	eeebc2e6-a734-4f02-8d65-173ba01323d3	a38f3ca8-458d-4d9a-8c39-fd18807ebffc	\N	یادآوری پیگیری مشتری	\N	reminder	2026-08-02 00:00:00+00	2026-08-02 01:00:00+00	t
bb620473-b983-493b-9d72-5cfc7ccfc198	2026-07-20 11:46:45.199839+00	2026-07-20 11:46:45.199839+00	6fa5de46-9edd-404a-915e-89d9f3f21ae7	6f0889c3-21cf-4af8-92e8-834e06a4a09c	abe514ef-e3c3-4d74-859b-cb25c77c879d	\N	جلسهٔ مرور با مدیریت	\N	meeting	2026-08-05 10:00:00+00	2026-08-05 11:00:00+00	f
d663ecc7-5fb5-44ce-86f6-4c1bb7b9ee03	2026-07-20 11:46:45.199839+00	2026-07-20 11:46:45.199839+00	6fa5de46-9edd-404a-915e-89d9f3f21ae7	eeebc2e6-a734-4f02-8d65-173ba01323d3	ad7056fc-1499-4430-8506-dc250e383b19	\N	یادآوری ارسال گزارش	\N	reminder	2026-08-06 00:00:00+00	2026-08-06 01:00:00+00	t
21564eae-74d0-4ead-834a-dd159bf42fbc	2026-07-20 11:46:45.199839+00	2026-07-20 11:46:45.199839+00	6fa5de46-9edd-404a-915e-89d9f3f21ae7	6f0889c3-21cf-4af8-92e8-834e06a4a09c	948c5ce5-0757-4628-be4f-0a827239068b	\N	جلسهٔ برنامه‌ریزی اسپرینت	\N	meeting	2026-08-13 10:00:00+00	2026-08-13 11:00:00+00	f
bb660847-f333-47b6-a2d1-aa1c71a886f2	2026-07-20 11:46:45.199839+00	2026-07-20 11:46:45.199839+00	6fa5de46-9edd-404a-915e-89d9f3f21ae7	9255642c-40dc-467b-8897-f23fd07f2394	a38f3ca8-458d-4d9a-8c39-fd18807ebffc	\N	یادآوری پیگیری مشتری	\N	reminder	2026-08-15 00:00:00+00	2026-08-15 01:00:00+00	t
e097eea7-096b-4463-b75b-cccde167a378	2026-07-20 11:46:45.199839+00	2026-07-20 11:46:45.199839+00	6fa5de46-9edd-404a-915e-89d9f3f21ae7	c2241423-6f70-4f15-92a9-c4a433dfec70	2863ba04-93e9-4609-a47b-9c793b5ff35f	\N	جلسهٔ هماهنگی هفتگی	\N	meeting	2026-06-20 10:00:00+00	2026-06-20 11:00:00+00	f
827da8a6-dac5-4e6e-93dd-a0134b7623a7	2026-07-20 11:46:45.199839+00	2026-07-20 11:46:45.199839+00	6fa5de46-9edd-404a-915e-89d9f3f21ae7	c700c6fb-ad08-4eaa-9597-f02c27aa0e58	07c27000-8555-48ac-9933-ddc1983684fc	\N	یادآوری ارسال گزارش	\N	reminder	2026-06-19 00:00:00+00	2026-06-19 01:00:00+00	t
ac968a4e-8314-42a9-8df4-9306dadabf22	2026-07-20 11:46:45.199839+00	2026-07-20 11:46:45.199839+00	6fa5de46-9edd-404a-915e-89d9f3f21ae7	c2241423-6f70-4f15-92a9-c4a433dfec70	07c27000-8555-48ac-9933-ddc1983684fc	\N	جلسهٔ مرور با مدیریت	\N	meeting	2026-06-25 10:00:00+00	2026-06-25 11:00:00+00	f
07946582-5645-4f9b-a0a5-17ca7798e594	2026-07-20 11:46:45.199839+00	2026-07-20 11:46:45.199839+00	6fa5de46-9edd-404a-915e-89d9f3f21ae7	07fc03fd-5b06-4623-adbc-9d3292322efa	bf961011-51f2-4658-9ee8-3e751094c075	\N	یادآوری تمدید قرارداد	\N	reminder	2026-06-29 00:00:00+00	2026-06-29 01:00:00+00	t
eb6fb37d-ba9a-48ae-8159-4de15358d81b	2026-07-20 11:46:45.199839+00	2026-07-20 11:46:45.199839+00	6fa5de46-9edd-404a-915e-89d9f3f21ae7	c2241423-6f70-4f15-92a9-c4a433dfec70	fe4b316c-1eee-4af3-b5d4-8c5c6710c9bb	\N	جلسهٔ برنامه‌ریزی اسپرینت	\N	meeting	2026-07-02 10:00:00+00	2026-07-02 11:00:00+00	f
07610dd5-97e6-4747-a7bf-451d7ac1a642	2026-07-20 11:46:45.199839+00	2026-07-20 11:46:45.199839+00	6fa5de46-9edd-404a-915e-89d9f3f21ae7	0bf949b7-932b-40ba-8d67-4ea888360556	2863ba04-93e9-4609-a47b-9c793b5ff35f	\N	یادآوری تمدید قرارداد	\N	reminder	2026-07-02 00:00:00+00	2026-07-02 01:00:00+00	t
0905fc9b-39c8-4c71-8f9c-59aed8b16cef	2026-07-20 11:46:45.199839+00	2026-07-20 11:46:45.199839+00	6fa5de46-9edd-404a-915e-89d9f3f21ae7	c2241423-6f70-4f15-92a9-c4a433dfec70	fe4b316c-1eee-4af3-b5d4-8c5c6710c9bb	\N	جلسهٔ مرور با مدیریت	\N	meeting	2026-07-07 10:00:00+00	2026-07-07 11:00:00+00	f
f3e28505-36e5-4393-9599-4d59b93f9f27	2026-07-20 11:46:45.199839+00	2026-07-20 11:46:45.199839+00	6fa5de46-9edd-404a-915e-89d9f3f21ae7	cf5d8b24-a057-421e-9cc3-b442f742293f	2863ba04-93e9-4609-a47b-9c793b5ff35f	\N	یادآوری ارسال گزارش	\N	reminder	2026-07-07 00:00:00+00	2026-07-07 01:00:00+00	t
c5609bca-4199-46a4-8867-67e0d7ef9d63	2026-07-20 11:46:45.199839+00	2026-07-20 11:46:45.199839+00	6fa5de46-9edd-404a-915e-89d9f3f21ae7	c2241423-6f70-4f15-92a9-c4a433dfec70	2863ba04-93e9-4609-a47b-9c793b5ff35f	\N	جلسهٔ بررسی پیشرفت پروژه	\N	meeting	2026-07-18 10:00:00+00	2026-07-18 11:00:00+00	f
ff7d3887-2145-4738-b153-2fe8af7b663f	2026-07-20 11:46:45.199839+00	2026-07-20 11:46:45.199839+00	6fa5de46-9edd-404a-915e-89d9f3f21ae7	cf5d8b24-a057-421e-9cc3-b442f742293f	fe4b316c-1eee-4af3-b5d4-8c5c6710c9bb	\N	یادآوری تمدید قرارداد	\N	reminder	2026-07-20 00:00:00+00	2026-07-20 01:00:00+00	t
1606c654-1ede-4e08-b361-a5a9159690ed	2026-07-20 11:46:45.199839+00	2026-07-20 11:46:45.199839+00	6fa5de46-9edd-404a-915e-89d9f3f21ae7	c2241423-6f70-4f15-92a9-c4a433dfec70	2863ba04-93e9-4609-a47b-9c793b5ff35f	\N	جلسهٔ مرور با مدیریت	\N	meeting	2026-07-24 10:00:00+00	2026-07-24 11:00:00+00	f
c3aba085-ba30-4e9a-b86d-8c91da13528e	2026-07-20 11:46:45.199839+00	2026-07-20 11:46:45.199839+00	6fa5de46-9edd-404a-915e-89d9f3f21ae7	cd92c461-1da5-4222-b6f0-60ce30f3d910	2863ba04-93e9-4609-a47b-9c793b5ff35f	\N	یادآوری تمدید قرارداد	\N	reminder	2026-07-21 00:00:00+00	2026-07-21 01:00:00+00	t
780f7222-02eb-49cf-a5df-aceafee52cb9	2026-07-20 11:46:45.199839+00	2026-07-20 11:46:45.199839+00	6fa5de46-9edd-404a-915e-89d9f3f21ae7	c2241423-6f70-4f15-92a9-c4a433dfec70	12b3562f-9b7e-4fd7-b326-d7e733197f75	\N	جلسهٔ بررسی پیشرفت پروژه	\N	meeting	2026-07-29 10:00:00+00	2026-07-29 11:00:00+00	f
f517184d-e7e7-454b-b22c-d17399b50bd4	2026-07-20 11:46:45.199839+00	2026-07-20 11:46:45.199839+00	6fa5de46-9edd-404a-915e-89d9f3f21ae7	cf5d8b24-a057-421e-9cc3-b442f742293f	12b3562f-9b7e-4fd7-b326-d7e733197f75	\N	یادآوری پیگیری مشتری	\N	reminder	2026-08-02 00:00:00+00	2026-08-02 01:00:00+00	t
a689eed2-3070-499c-9480-12adc042f990	2026-07-20 11:46:45.199839+00	2026-07-20 11:46:45.199839+00	6fa5de46-9edd-404a-915e-89d9f3f21ae7	c2241423-6f70-4f15-92a9-c4a433dfec70	2863ba04-93e9-4609-a47b-9c793b5ff35f	\N	جلسهٔ مرور با مدیریت	\N	meeting	2026-08-08 10:00:00+00	2026-08-08 11:00:00+00	f
10ff4e86-d738-490c-8f46-80d1215944c2	2026-07-20 11:46:45.199839+00	2026-07-20 11:46:45.199839+00	6fa5de46-9edd-404a-915e-89d9f3f21ae7	c700c6fb-ad08-4eaa-9597-f02c27aa0e58	bf961011-51f2-4658-9ee8-3e751094c075	\N	یادآوری ارسال گزارش	\N	reminder	2026-08-10 00:00:00+00	2026-08-10 01:00:00+00	t
83ba7ce4-b6cc-45e5-b219-b108cb256d5b	2026-07-20 11:46:45.199839+00	2026-07-20 11:46:45.199839+00	6fa5de46-9edd-404a-915e-89d9f3f21ae7	c2241423-6f70-4f15-92a9-c4a433dfec70	fe4b316c-1eee-4af3-b5d4-8c5c6710c9bb	\N	جلسهٔ برنامه‌ریزی اسپرینت	\N	meeting	2026-08-12 10:00:00+00	2026-08-12 11:00:00+00	f
ea2c3d05-dc4e-4b54-8fc1-bfc8f0bdf389	2026-07-20 11:46:45.199839+00	2026-07-20 11:46:45.199839+00	6fa5de46-9edd-404a-915e-89d9f3f21ae7	07fc03fd-5b06-4623-adbc-9d3292322efa	fe4b316c-1eee-4af3-b5d4-8c5c6710c9bb	\N	یادآوری پیگیری مشتری	\N	reminder	2026-08-13 00:00:00+00	2026-08-13 01:00:00+00	t
3d16b1b9-ab97-430c-a50a-c3ab37c4a2d3	2026-07-20 11:46:45.199839+00	2026-07-20 11:46:45.199839+00	6fa5de46-9edd-404a-915e-89d9f3f21ae7	17797748-c29a-4be6-a26c-3b13a6d22c31	\N	\N	تعطیلی رسمی	\N	holiday	2026-06-18 00:00:00+00	2026-06-18 01:00:00+00	t
42e18600-e7bc-45bb-aab5-db040cef96b9	2026-07-20 11:46:45.199839+00	2026-07-20 11:46:45.199839+00	6fa5de46-9edd-404a-915e-89d9f3f21ae7	17797748-c29a-4be6-a26c-3b13a6d22c31	\N	\N	تعطیلی رسمی	\N	holiday	2026-07-16 00:00:00+00	2026-07-16 01:00:00+00	t
da1326c2-dbdf-4a1b-acc7-9391de3ac2d5	2026-07-20 11:46:45.199839+00	2026-07-20 11:46:45.199839+00	6fa5de46-9edd-404a-915e-89d9f3f21ae7	17797748-c29a-4be6-a26c-3b13a6d22c31	\N	\N	تعطیلی رسمی	\N	holiday	2026-08-13 00:00:00+00	2026-08-13 01:00:00+00	t
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
65781382-a196-43d3-aff0-78fbcca6f20f	2026-07-20 11:46:45.199839+00	2026-07-20 11:46:45.199839+00	6fa5de46-9edd-404a-915e-89d9f3f21ae7	6367109c-4684-4a1b-a6b5-9843aa3f6a9d	a5170653-16f8-45a8-8ab3-21c8f3d3557e	project_manager
af1fe21a-a8ca-425c-98ad-e8b27f5e3a45	2026-07-20 11:46:45.199839+00	2026-07-20 11:46:45.199839+00	6fa5de46-9edd-404a-915e-89d9f3f21ae7	7c364485-75f2-4d57-81ee-62ec42c62177	a5170653-16f8-45a8-8ab3-21c8f3d3557e	employee
f0820afb-bb78-4d37-adf1-3855f463ebee	2026-07-20 11:46:45.199839+00	2026-07-20 11:46:45.199839+00	6fa5de46-9edd-404a-915e-89d9f3f21ae7	398f8c1c-1d8b-48eb-9aed-08ebb479cff3	a5170653-16f8-45a8-8ab3-21c8f3d3557e	employee
1bdd06bd-3748-4d5d-a297-45b47e2ef34b	2026-07-20 11:46:45.199839+00	2026-07-20 11:46:45.199839+00	6fa5de46-9edd-404a-915e-89d9f3f21ae7	3051f03b-e73a-49fb-a6d2-ab7406c6850b	a5170653-16f8-45a8-8ab3-21c8f3d3557e	employee
f7f67021-4c35-41fb-9eee-c45bfa8b75b9	2026-07-20 11:46:45.199839+00	2026-07-20 11:46:45.199839+00	6fa5de46-9edd-404a-915e-89d9f3f21ae7	a42bd423-3577-42e0-b239-611eb7480fb9	a5170653-16f8-45a8-8ab3-21c8f3d3557e	employee
5bc595cc-e995-4505-ab83-6de2ba802f7a	2026-07-20 11:46:45.199839+00	2026-07-20 11:46:45.199839+00	6fa5de46-9edd-404a-915e-89d9f3f21ae7	fd5161f1-4abf-4cc9-8f06-914566393088	a5170653-16f8-45a8-8ab3-21c8f3d3557e	employee
dbb6b378-ee9b-4b0b-8d57-d959ecef9813	2026-07-20 11:46:45.199839+00	2026-07-20 11:46:45.199839+00	6fa5de46-9edd-404a-915e-89d9f3f21ae7	a34644cb-4fa6-4ad1-904f-3e26b23679cd	a5170653-16f8-45a8-8ab3-21c8f3d3557e	employee
a62504e5-ebdc-4401-9c52-176d117afbc6	2026-07-20 11:46:45.199839+00	2026-07-20 11:46:45.199839+00	6fa5de46-9edd-404a-915e-89d9f3f21ae7	6f0889c3-21cf-4af8-92e8-834e06a4a09c	e2331c94-951e-48e2-b9df-95c0b3ba5e4b	project_manager
12b098a6-99a0-4a72-8140-48b42144fa70	2026-07-20 11:46:45.199839+00	2026-07-20 11:46:45.199839+00	6fa5de46-9edd-404a-915e-89d9f3f21ae7	9255642c-40dc-467b-8897-f23fd07f2394	e2331c94-951e-48e2-b9df-95c0b3ba5e4b	employee
f3256199-2931-4301-ba0f-670a1b829ab2	2026-07-20 11:46:45.199839+00	2026-07-20 11:46:45.199839+00	6fa5de46-9edd-404a-915e-89d9f3f21ae7	eeebc2e6-a734-4f02-8d65-173ba01323d3	e2331c94-951e-48e2-b9df-95c0b3ba5e4b	employee
22b07ca8-d0c4-4563-b51a-6bd5ac1d15bc	2026-07-20 11:46:45.199839+00	2026-07-20 11:46:45.199839+00	6fa5de46-9edd-404a-915e-89d9f3f21ae7	56ee4c58-1504-48a5-b37d-7d040bb2bd16	e2331c94-951e-48e2-b9df-95c0b3ba5e4b	employee
9a2c88fb-8fb4-41bc-8e8d-2689154fc88c	2026-07-20 11:46:45.199839+00	2026-07-20 11:46:45.199839+00	6fa5de46-9edd-404a-915e-89d9f3f21ae7	3cba84f1-51a4-4831-ac2b-61b820a1122a	e2331c94-951e-48e2-b9df-95c0b3ba5e4b	employee
b1ac62fe-b6ce-4809-9199-9558f8fa62de	2026-07-20 11:46:45.199839+00	2026-07-20 11:46:45.199839+00	6fa5de46-9edd-404a-915e-89d9f3f21ae7	ca92a9d5-cf4a-4b8b-9fe5-6fadd5c44ca2	e2331c94-951e-48e2-b9df-95c0b3ba5e4b	employee
4cb2a0f4-a702-4b3e-a3bd-fae9e0edcbec	2026-07-20 11:46:45.199839+00	2026-07-20 11:46:45.199839+00	6fa5de46-9edd-404a-915e-89d9f3f21ae7	c28803c6-5155-4136-94b4-4f91ec6ee698	e2331c94-951e-48e2-b9df-95c0b3ba5e4b	employee
be0695f3-3e21-4d9b-90b0-a82f3392753c	2026-07-20 11:46:45.199839+00	2026-07-20 11:46:45.199839+00	6fa5de46-9edd-404a-915e-89d9f3f21ae7	c2241423-6f70-4f15-92a9-c4a433dfec70	571b9f1d-680e-45b9-b80e-18f6904a83bc	project_manager
190e5852-f6ed-452a-b1b0-c50073d905ca	2026-07-20 11:46:45.199839+00	2026-07-20 11:46:45.199839+00	6fa5de46-9edd-404a-915e-89d9f3f21ae7	c700c6fb-ad08-4eaa-9597-f02c27aa0e58	571b9f1d-680e-45b9-b80e-18f6904a83bc	employee
88790a34-c3b8-4f1f-85dc-d73b7bff6c56	2026-07-20 11:46:45.199839+00	2026-07-20 11:46:45.199839+00	6fa5de46-9edd-404a-915e-89d9f3f21ae7	16119c08-e43f-4846-adcd-f77ad1aca132	571b9f1d-680e-45b9-b80e-18f6904a83bc	employee
20520f5b-6eb1-4fd8-8870-3ab54bf1f5d1	2026-07-20 11:46:45.199839+00	2026-07-20 11:46:45.199839+00	6fa5de46-9edd-404a-915e-89d9f3f21ae7	cf5d8b24-a057-421e-9cc3-b442f742293f	571b9f1d-680e-45b9-b80e-18f6904a83bc	employee
060ce5af-a63c-41e8-b8e3-b0991cf4799d	2026-07-20 11:46:45.199839+00	2026-07-20 11:46:45.199839+00	6fa5de46-9edd-404a-915e-89d9f3f21ae7	cd92c461-1da5-4222-b6f0-60ce30f3d910	571b9f1d-680e-45b9-b80e-18f6904a83bc	employee
bc012c78-cc6a-4590-a262-aeb43546ea96	2026-07-20 11:46:45.199839+00	2026-07-20 11:46:45.199839+00	6fa5de46-9edd-404a-915e-89d9f3f21ae7	0bf949b7-932b-40ba-8d67-4ea888360556	571b9f1d-680e-45b9-b80e-18f6904a83bc	employee
45996c3e-ff57-4512-a5ea-a52fcc2739e8	2026-07-20 11:46:45.199839+00	2026-07-20 11:46:45.199839+00	6fa5de46-9edd-404a-915e-89d9f3f21ae7	07fc03fd-5b06-4623-adbc-9d3292322efa	571b9f1d-680e-45b9-b80e-18f6904a83bc	employee
5d7b8b57-9754-4b55-ba58-457e3fd568df	2026-07-20 11:46:45.199839+00	2026-07-20 11:46:45.199839+00	6fa5de46-9edd-404a-915e-89d9f3f21ae7	c2241423-6f70-4f15-92a9-c4a433dfec70	a5170653-16f8-45a8-8ab3-21c8f3d3557e	employee
50e3ef51-fa39-466a-bf59-698fb4bfd718	2026-07-20 11:46:45.199839+00	2026-07-20 11:46:45.199839+00	6fa5de46-9edd-404a-915e-89d9f3f21ae7	7c364485-75f2-4d57-81ee-62ec42c62177	e2331c94-951e-48e2-b9df-95c0b3ba5e4b	employee
\.


--
-- Data for Name: departments; Type: TABLE DATA; Schema: public; Owner: -
--

COPY public.departments (id, created_at, updated_at, organization_id, name) FROM stdin;
a5170653-16f8-45a8-8ab3-21c8f3d3557e	2026-07-20 11:46:45.199839+00	2026-07-20 11:46:45.199839+00	6fa5de46-9edd-404a-915e-89d9f3f21ae7	مهندسی و فنی
e2331c94-951e-48e2-b9df-95c0b3ba5e4b	2026-07-20 11:46:45.199839+00	2026-07-20 11:46:45.199839+00	6fa5de46-9edd-404a-915e-89d9f3f21ae7	حسابداری و مالی
571b9f1d-680e-45b9-b80e-18f6904a83bc	2026-07-20 11:46:45.199839+00	2026-07-20 11:46:45.199839+00	6fa5de46-9edd-404a-915e-89d9f3f21ae7	منابع انسانی
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
شرکت نمونهٔ آزمایشی	demo-org-ec76db80	t	6fa5de46-9edd-404a-915e-89d9f3f21ae7	2026-07-20 11:46:45.199839+00	2026-07-20 11:46:45.199839+00
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
1c7c9744-f184-4945-939c-92a23d462b12	6367109c-4684-4a1b-a6b5-9843aa3f6a9d	19c68055-9d8e-426d-a71d-55976ce56607	2026-07-20 11:46:45.199839+00	2026-07-20 11:46:45.199839+00
1c7c9744-f184-4945-939c-92a23d462b12	a34644cb-4fa6-4ad1-904f-3e26b23679cd	c56e6a2f-0c52-4508-8eba-4b4b6397e338	2026-07-20 11:46:45.199839+00	2026-07-20 11:46:45.199839+00
1c7c9744-f184-4945-939c-92a23d462b12	7c364485-75f2-4d57-81ee-62ec42c62177	95521f30-7fff-4d86-bf61-56e454a64d51	2026-07-20 11:46:45.199839+00	2026-07-20 11:46:45.199839+00
1c7c9744-f184-4945-939c-92a23d462b12	fd5161f1-4abf-4cc9-8f06-914566393088	4b8148af-96c2-4731-8b26-a8d8fb42ee0d	2026-07-20 11:46:45.199839+00	2026-07-20 11:46:45.199839+00
adfcac3e-63b8-4b84-a951-57550e399e3a	6367109c-4684-4a1b-a6b5-9843aa3f6a9d	633918f2-9992-4d43-8f58-1a52109bdafa	2026-07-20 11:46:45.199839+00	2026-07-20 11:46:45.199839+00
adfcac3e-63b8-4b84-a951-57550e399e3a	398f8c1c-1d8b-48eb-9aed-08ebb479cff3	153f3489-d5d4-4120-9590-50423fe8f635	2026-07-20 11:46:45.199839+00	2026-07-20 11:46:45.199839+00
adfcac3e-63b8-4b84-a951-57550e399e3a	a34644cb-4fa6-4ad1-904f-3e26b23679cd	3257e152-bbc4-4ed0-806d-72de0719186e	2026-07-20 11:46:45.199839+00	2026-07-20 11:46:45.199839+00
adfcac3e-63b8-4b84-a951-57550e399e3a	7c364485-75f2-4d57-81ee-62ec42c62177	196f4519-7604-4acb-8100-cbb78196a335	2026-07-20 11:46:45.199839+00	2026-07-20 11:46:45.199839+00
b2c5e0fe-deb4-4a0f-bf3b-58b26bc437f5	6367109c-4684-4a1b-a6b5-9843aa3f6a9d	6d2523ab-eb56-4f89-8c9e-764b0b0a257b	2026-07-20 11:46:45.199839+00	2026-07-20 11:46:45.199839+00
b2c5e0fe-deb4-4a0f-bf3b-58b26bc437f5	fd5161f1-4abf-4cc9-8f06-914566393088	184cad7d-c36d-469b-9c96-6b3a304d0936	2026-07-20 11:46:45.199839+00	2026-07-20 11:46:45.199839+00
b2c5e0fe-deb4-4a0f-bf3b-58b26bc437f5	a42bd423-3577-42e0-b239-611eb7480fb9	a2ba4d76-65df-4ee6-9c5e-0515670c4cc2	2026-07-20 11:46:45.199839+00	2026-07-20 11:46:45.199839+00
b2c5e0fe-deb4-4a0f-bf3b-58b26bc437f5	7c364485-75f2-4d57-81ee-62ec42c62177	6b8f73cd-002e-436d-a19b-e73253bc399c	2026-07-20 11:46:45.199839+00	2026-07-20 11:46:45.199839+00
23082ced-9e61-45d1-bb62-c2bd122dbba1	6367109c-4684-4a1b-a6b5-9843aa3f6a9d	5c94939a-7028-40b8-80f6-8f64f6192095	2026-07-20 11:46:45.199839+00	2026-07-20 11:46:45.199839+00
23082ced-9e61-45d1-bb62-c2bd122dbba1	398f8c1c-1d8b-48eb-9aed-08ebb479cff3	0dd4f5c5-9f4c-4815-867d-4b3cca72e585	2026-07-20 11:46:45.199839+00	2026-07-20 11:46:45.199839+00
23082ced-9e61-45d1-bb62-c2bd122dbba1	a34644cb-4fa6-4ad1-904f-3e26b23679cd	77befc0d-1175-4270-a740-c39bf2e68328	2026-07-20 11:46:45.199839+00	2026-07-20 11:46:45.199839+00
23082ced-9e61-45d1-bb62-c2bd122dbba1	7c364485-75f2-4d57-81ee-62ec42c62177	16b3bac2-4686-4964-ac42-ab7b5b6bc24f	2026-07-20 11:46:45.199839+00	2026-07-20 11:46:45.199839+00
4d1e5701-762a-4826-afcd-c7c64e14ccb5	6367109c-4684-4a1b-a6b5-9843aa3f6a9d	85a0cd3c-f29e-4ecd-867b-13c8e3593c7b	2026-07-20 11:46:45.199839+00	2026-07-20 11:46:45.199839+00
4d1e5701-762a-4826-afcd-c7c64e14ccb5	a34644cb-4fa6-4ad1-904f-3e26b23679cd	bf4a3425-68c7-431d-8640-12e2e26c6c6a	2026-07-20 11:46:45.199839+00	2026-07-20 11:46:45.199839+00
4d1e5701-762a-4826-afcd-c7c64e14ccb5	fd5161f1-4abf-4cc9-8f06-914566393088	dcc6b769-552c-4353-b39c-17f11ec48a36	2026-07-20 11:46:45.199839+00	2026-07-20 11:46:45.199839+00
4d1e5701-762a-4826-afcd-c7c64e14ccb5	a42bd423-3577-42e0-b239-611eb7480fb9	0a20b112-b1ea-4ce0-a0c4-5dab9d136af4	2026-07-20 11:46:45.199839+00	2026-07-20 11:46:45.199839+00
abe514ef-e3c3-4d74-859b-cb25c77c879d	6f0889c3-21cf-4af8-92e8-834e06a4a09c	e345c13d-cb9b-440b-89bd-3a0095da57b4	2026-07-20 11:46:45.199839+00	2026-07-20 11:46:45.199839+00
abe514ef-e3c3-4d74-859b-cb25c77c879d	9255642c-40dc-467b-8897-f23fd07f2394	62d18f5f-2cb9-40ca-bf26-6767dc93b672	2026-07-20 11:46:45.199839+00	2026-07-20 11:46:45.199839+00
abe514ef-e3c3-4d74-859b-cb25c77c879d	eeebc2e6-a734-4f02-8d65-173ba01323d3	02d84f40-564a-42bd-9443-4fd68abf1f34	2026-07-20 11:46:45.199839+00	2026-07-20 11:46:45.199839+00
abe514ef-e3c3-4d74-859b-cb25c77c879d	56ee4c58-1504-48a5-b37d-7d040bb2bd16	7cafc864-614a-495e-92c8-6320e397f618	2026-07-20 11:46:45.199839+00	2026-07-20 11:46:45.199839+00
ad7056fc-1499-4430-8506-dc250e383b19	6f0889c3-21cf-4af8-92e8-834e06a4a09c	d5fe7c30-4631-45f1-bdf1-aef84c7d62fa	2026-07-20 11:46:45.199839+00	2026-07-20 11:46:45.199839+00
ad7056fc-1499-4430-8506-dc250e383b19	9255642c-40dc-467b-8897-f23fd07f2394	b09f25f1-2e2c-445e-9968-fd88340b08d8	2026-07-20 11:46:45.199839+00	2026-07-20 11:46:45.199839+00
ad7056fc-1499-4430-8506-dc250e383b19	56ee4c58-1504-48a5-b37d-7d040bb2bd16	b6e1cd83-c3ab-4922-98ec-4f19ccb9efae	2026-07-20 11:46:45.199839+00	2026-07-20 11:46:45.199839+00
ad7056fc-1499-4430-8506-dc250e383b19	ca92a9d5-cf4a-4b8b-9fe5-6fadd5c44ca2	a2fb50af-2859-403e-b54d-856278919298	2026-07-20 11:46:45.199839+00	2026-07-20 11:46:45.199839+00
a38f3ca8-458d-4d9a-8c39-fd18807ebffc	6f0889c3-21cf-4af8-92e8-834e06a4a09c	efed123e-4551-47be-a682-c3976f9157ff	2026-07-20 11:46:45.199839+00	2026-07-20 11:46:45.199839+00
a38f3ca8-458d-4d9a-8c39-fd18807ebffc	56ee4c58-1504-48a5-b37d-7d040bb2bd16	12c30332-4775-41db-9b78-57a2c5a5507d	2026-07-20 11:46:45.199839+00	2026-07-20 11:46:45.199839+00
a38f3ca8-458d-4d9a-8c39-fd18807ebffc	3cba84f1-51a4-4831-ac2b-61b820a1122a	c340b05c-4541-424b-9eac-2451e23b89c5	2026-07-20 11:46:45.199839+00	2026-07-20 11:46:45.199839+00
a38f3ca8-458d-4d9a-8c39-fd18807ebffc	ca92a9d5-cf4a-4b8b-9fe5-6fadd5c44ca2	2ad42c08-838d-4d70-af83-533b902be616	2026-07-20 11:46:45.199839+00	2026-07-20 11:46:45.199839+00
e6e0814d-c93d-4ff2-ac03-0f95e574998a	6f0889c3-21cf-4af8-92e8-834e06a4a09c	edcb96a7-8ef3-4262-8e2c-ee5e5cffe9d6	2026-07-20 11:46:45.199839+00	2026-07-20 11:46:45.199839+00
e6e0814d-c93d-4ff2-ac03-0f95e574998a	56ee4c58-1504-48a5-b37d-7d040bb2bd16	a41487df-7759-4f6a-9b23-829a5c96e6e0	2026-07-20 11:46:45.199839+00	2026-07-20 11:46:45.199839+00
e6e0814d-c93d-4ff2-ac03-0f95e574998a	eeebc2e6-a734-4f02-8d65-173ba01323d3	5628bdf0-826f-4fcf-8599-690f11eff4b5	2026-07-20 11:46:45.199839+00	2026-07-20 11:46:45.199839+00
e6e0814d-c93d-4ff2-ac03-0f95e574998a	3cba84f1-51a4-4831-ac2b-61b820a1122a	57c6eded-ffdd-4650-a9bf-3c146a3eed53	2026-07-20 11:46:45.199839+00	2026-07-20 11:46:45.199839+00
948c5ce5-0757-4628-be4f-0a827239068b	6f0889c3-21cf-4af8-92e8-834e06a4a09c	87fd8deb-081f-44c3-bc30-b568eb601070	2026-07-20 11:46:45.199839+00	2026-07-20 11:46:45.199839+00
948c5ce5-0757-4628-be4f-0a827239068b	ca92a9d5-cf4a-4b8b-9fe5-6fadd5c44ca2	597f953e-2ac8-4099-ac02-6271964ec99e	2026-07-20 11:46:45.199839+00	2026-07-20 11:46:45.199839+00
948c5ce5-0757-4628-be4f-0a827239068b	56ee4c58-1504-48a5-b37d-7d040bb2bd16	3ab817ae-3065-4fb8-8396-2e7970477a59	2026-07-20 11:46:45.199839+00	2026-07-20 11:46:45.199839+00
948c5ce5-0757-4628-be4f-0a827239068b	9255642c-40dc-467b-8897-f23fd07f2394	c45cabea-322d-4911-9ce4-95d0e69d0e92	2026-07-20 11:46:45.199839+00	2026-07-20 11:46:45.199839+00
bf961011-51f2-4658-9ee8-3e751094c075	c2241423-6f70-4f15-92a9-c4a433dfec70	2e72752e-7bc1-4fee-bdc8-1d20d13a79a7	2026-07-20 11:46:45.199839+00	2026-07-20 11:46:45.199839+00
bf961011-51f2-4658-9ee8-3e751094c075	0bf949b7-932b-40ba-8d67-4ea888360556	21aa16f3-59f7-49f4-b4d9-d250365aa197	2026-07-20 11:46:45.199839+00	2026-07-20 11:46:45.199839+00
bf961011-51f2-4658-9ee8-3e751094c075	16119c08-e43f-4846-adcd-f77ad1aca132	3fc45ff7-d834-4858-b5d0-e12db542a1c0	2026-07-20 11:46:45.199839+00	2026-07-20 11:46:45.199839+00
bf961011-51f2-4658-9ee8-3e751094c075	07fc03fd-5b06-4623-adbc-9d3292322efa	acb2656e-f33a-460a-a292-29932c6b8b74	2026-07-20 11:46:45.199839+00	2026-07-20 11:46:45.199839+00
07c27000-8555-48ac-9933-ddc1983684fc	c2241423-6f70-4f15-92a9-c4a433dfec70	7587354d-57bf-44e0-856e-d7e1d1289e70	2026-07-20 11:46:45.199839+00	2026-07-20 11:46:45.199839+00
07c27000-8555-48ac-9933-ddc1983684fc	cf5d8b24-a057-421e-9cc3-b442f742293f	7bfdcc91-1517-44c8-8ba5-824a628ae2df	2026-07-20 11:46:45.199839+00	2026-07-20 11:46:45.199839+00
07c27000-8555-48ac-9933-ddc1983684fc	16119c08-e43f-4846-adcd-f77ad1aca132	0c0aba76-84e3-42d0-a104-9053c5769b01	2026-07-20 11:46:45.199839+00	2026-07-20 11:46:45.199839+00
07c27000-8555-48ac-9933-ddc1983684fc	cd92c461-1da5-4222-b6f0-60ce30f3d910	8a7e8340-1086-431c-8a37-cd9139d10d5f	2026-07-20 11:46:45.199839+00	2026-07-20 11:46:45.199839+00
fe4b316c-1eee-4af3-b5d4-8c5c6710c9bb	c2241423-6f70-4f15-92a9-c4a433dfec70	3a6d4213-74b5-4e98-a0d3-9bcdb4b8deb8	2026-07-20 11:46:45.199839+00	2026-07-20 11:46:45.199839+00
fe4b316c-1eee-4af3-b5d4-8c5c6710c9bb	c700c6fb-ad08-4eaa-9597-f02c27aa0e58	8602e39e-c3c3-470c-9756-2bbf2847c921	2026-07-20 11:46:45.199839+00	2026-07-20 11:46:45.199839+00
fe4b316c-1eee-4af3-b5d4-8c5c6710c9bb	16119c08-e43f-4846-adcd-f77ad1aca132	d0c42f40-f79c-46c9-bb55-02b04876f36b	2026-07-20 11:46:45.199839+00	2026-07-20 11:46:45.199839+00
fe4b316c-1eee-4af3-b5d4-8c5c6710c9bb	0bf949b7-932b-40ba-8d67-4ea888360556	24b99262-d40e-4ee8-a251-375112946a61	2026-07-20 11:46:45.199839+00	2026-07-20 11:46:45.199839+00
12b3562f-9b7e-4fd7-b326-d7e733197f75	c2241423-6f70-4f15-92a9-c4a433dfec70	ea6335ad-547b-41cb-b0e2-596ab9232815	2026-07-20 11:46:45.199839+00	2026-07-20 11:46:45.199839+00
12b3562f-9b7e-4fd7-b326-d7e733197f75	cd92c461-1da5-4222-b6f0-60ce30f3d910	4a0905a3-10af-4426-b9f6-babeb74ef9c2	2026-07-20 11:46:45.199839+00	2026-07-20 11:46:45.199839+00
12b3562f-9b7e-4fd7-b326-d7e733197f75	c700c6fb-ad08-4eaa-9597-f02c27aa0e58	0ea3ad61-4ef6-4bdb-a3ba-f82e80fc4603	2026-07-20 11:46:45.199839+00	2026-07-20 11:46:45.199839+00
12b3562f-9b7e-4fd7-b326-d7e733197f75	cf5d8b24-a057-421e-9cc3-b442f742293f	8be5ec2f-8655-4b9f-8eb2-6c34169f58d3	2026-07-20 11:46:45.199839+00	2026-07-20 11:46:45.199839+00
2863ba04-93e9-4609-a47b-9c793b5ff35f	c2241423-6f70-4f15-92a9-c4a433dfec70	ef52ae69-99fd-4b81-b923-66a95fdee56d	2026-07-20 11:46:45.199839+00	2026-07-20 11:46:45.199839+00
2863ba04-93e9-4609-a47b-9c793b5ff35f	16119c08-e43f-4846-adcd-f77ad1aca132	fb6ee556-86f8-4e57-bdeb-31a31ade9511	2026-07-20 11:46:45.199839+00	2026-07-20 11:46:45.199839+00
2863ba04-93e9-4609-a47b-9c793b5ff35f	cf5d8b24-a057-421e-9cc3-b442f742293f	eaa680c9-ee3b-4636-bd01-971d217ac41f	2026-07-20 11:46:45.199839+00	2026-07-20 11:46:45.199839+00
2863ba04-93e9-4609-a47b-9c793b5ff35f	07fc03fd-5b06-4623-adbc-9d3292322efa	1822ed75-712b-4f01-8b5f-16a9d6680163	2026-07-20 11:46:45.199839+00	2026-07-20 11:46:45.199839+00
\.


--
-- Data for Name: projects; Type: TABLE DATA; Schema: public; Owner: -
--

COPY public.projects (organization_id, name, description, start_date, end_date, status, created_by_id, id, created_at, updated_at, manager_id, cooperation_start_date, department_id) FROM stdin;
6fa5de46-9edd-404a-915e-89d9f3f21ae7	بازطراحی وب‌سایت شرکتی	پروژهٔ مهندسی و فنی شماره 1	2026-06-01	2026-08-16	active	17797748-c29a-4be6-a26c-3b13a6d22c31	1c7c9744-f184-4945-939c-92a23d462b12	2026-07-20 11:46:45.199839+00	2026-07-20 11:46:45.199839+00	6367109c-4684-4a1b-a6b5-9843aa3f6a9d	2026-06-01	a5170653-16f8-45a8-8ab3-21c8f3d3557e
6fa5de46-9edd-404a-915e-89d9f3f21ae7	توسعهٔ اپلیکیشن موبایل فروش	پروژهٔ مهندسی و فنی شماره 2	2026-04-28	2026-06-23	active	17797748-c29a-4be6-a26c-3b13a6d22c31	adfcac3e-63b8-4b84-a951-57550e399e3a	2026-07-20 11:46:45.199839+00	2026-07-20 11:46:45.199839+00	6367109c-4684-4a1b-a6b5-9843aa3f6a9d	2026-04-28	a5170653-16f8-45a8-8ab3-21c8f3d3557e
6fa5de46-9edd-404a-915e-89d9f3f21ae7	مهاجرت زیرساخت به ابر	پروژهٔ مهندسی و فنی شماره 3	2026-07-03	2026-08-28	active	17797748-c29a-4be6-a26c-3b13a6d22c31	b2c5e0fe-deb4-4a0f-bf3b-58b26bc437f5	2026-07-20 11:46:45.199839+00	2026-07-20 11:46:45.199839+00	6367109c-4684-4a1b-a6b5-9843aa3f6a9d	2026-07-03	a5170653-16f8-45a8-8ab3-21c8f3d3557e
6fa5de46-9edd-404a-915e-89d9f3f21ae7	پیاده‌سازی سامانهٔ مانیتورینگ	پروژهٔ مهندسی و فنی شماره 4	2026-04-26	2026-07-05	active	17797748-c29a-4be6-a26c-3b13a6d22c31	23082ced-9e61-45d1-bb62-c2bd122dbba1	2026-07-20 11:46:45.199839+00	2026-07-20 11:46:45.199839+00	6367109c-4684-4a1b-a6b5-9843aa3f6a9d	2026-04-26	a5170653-16f8-45a8-8ab3-21c8f3d3557e
6fa5de46-9edd-404a-915e-89d9f3f21ae7	بهبود عملکرد پایگاه‌داده	پروژهٔ مهندسی و فنی شماره 5	2026-06-08	2026-09-18	active	17797748-c29a-4be6-a26c-3b13a6d22c31	4d1e5701-762a-4826-afcd-c7c64e14ccb5	2026-07-20 11:46:45.199839+00	2026-07-20 11:46:45.199839+00	6367109c-4684-4a1b-a6b5-9843aa3f6a9d	2026-06-08	a5170653-16f8-45a8-8ab3-21c8f3d3557e
6fa5de46-9edd-404a-915e-89d9f3f21ae7	بستن حساب‌های مالی سال	پروژهٔ حسابداری و مالی شماره 1	2026-05-22	2026-10-13	active	17797748-c29a-4be6-a26c-3b13a6d22c31	abe514ef-e3c3-4d74-859b-cb25c77c879d	2026-07-20 11:46:45.199839+00	2026-07-20 11:46:45.199839+00	6f0889c3-21cf-4af8-92e8-834e06a4a09c	2026-05-22	e2331c94-951e-48e2-b9df-95c0b3ba5e4b
6fa5de46-9edd-404a-915e-89d9f3f21ae7	پیاده‌سازی سامانهٔ فاکتور الکترونیک	پروژهٔ حسابداری و مالی شماره 2	2026-06-21	2026-11-15	active	17797748-c29a-4be6-a26c-3b13a6d22c31	ad7056fc-1499-4430-8506-dc250e383b19	2026-07-20 11:46:45.199839+00	2026-07-20 11:46:45.199839+00	6f0889c3-21cf-4af8-92e8-834e06a4a09c	2026-06-21	e2331c94-951e-48e2-b9df-95c0b3ba5e4b
6fa5de46-9edd-404a-915e-89d9f3f21ae7	ممیزی مالی سه‌ماههٔ دوم	پروژهٔ حسابداری و مالی شماره 3	2026-05-11	2026-08-13	active	17797748-c29a-4be6-a26c-3b13a6d22c31	a38f3ca8-458d-4d9a-8c39-fd18807ebffc	2026-07-20 11:46:45.199839+00	2026-07-20 11:46:45.199839+00	6f0889c3-21cf-4af8-92e8-834e06a4a09c	2026-05-11	e2331c94-951e-48e2-b9df-95c0b3ba5e4b
6fa5de46-9edd-404a-915e-89d9f3f21ae7	تدوین بودجهٔ سال آینده	پروژهٔ حسابداری و مالی شماره 4	2026-05-04	2026-08-04	active	17797748-c29a-4be6-a26c-3b13a6d22c31	e6e0814d-c93d-4ff2-ac03-0f95e574998a	2026-07-20 11:46:45.199839+00	2026-07-20 11:46:45.199839+00	6f0889c3-21cf-4af8-92e8-834e06a4a09c	2026-05-04	e2331c94-951e-48e2-b9df-95c0b3ba5e4b
6fa5de46-9edd-404a-915e-89d9f3f21ae7	مدیریت مطالبات و بدهی‌ها	پروژهٔ حسابداری و مالی شماره 5	2026-05-13	2026-07-07	active	17797748-c29a-4be6-a26c-3b13a6d22c31	948c5ce5-0757-4628-be4f-0a827239068b	2026-07-20 11:46:45.199839+00	2026-07-20 11:46:45.199839+00	6f0889c3-21cf-4af8-92e8-834e06a4a09c	2026-05-13	e2331c94-951e-48e2-b9df-95c0b3ba5e4b
6fa5de46-9edd-404a-915e-89d9f3f21ae7	برگزاری دورهٔ آموزشی کارکنان	پروژهٔ منابع انسانی شماره 1	2026-05-04	2026-08-26	active	17797748-c29a-4be6-a26c-3b13a6d22c31	bf961011-51f2-4658-9ee8-3e751094c075	2026-07-20 11:46:45.199839+00	2026-07-20 11:46:45.199839+00	c2241423-6f70-4f15-92a9-c4a433dfec70	2026-05-04	571b9f1d-680e-45b9-b80e-18f6904a83bc
6fa5de46-9edd-404a-915e-89d9f3f21ae7	بازطراحی فرایند جذب و استخدام	پروژهٔ منابع انسانی شماره 2	2026-07-02	2026-08-27	active	17797748-c29a-4be6-a26c-3b13a6d22c31	07c27000-8555-48ac-9933-ddc1983684fc	2026-07-20 11:46:45.199839+00	2026-07-20 11:46:45.199839+00	c2241423-6f70-4f15-92a9-c4a433dfec70	2026-07-02	571b9f1d-680e-45b9-b80e-18f6904a83bc
6fa5de46-9edd-404a-915e-89d9f3f21ae7	ارزیابی عملکرد سالانهٔ کارکنان	پروژهٔ منابع انسانی شماره 3	2026-07-04	2026-10-24	active	17797748-c29a-4be6-a26c-3b13a6d22c31	fe4b316c-1eee-4af3-b5d4-8c5c6710c9bb	2026-07-20 11:46:45.199839+00	2026-07-20 11:46:45.199839+00	c2241423-6f70-4f15-92a9-c4a433dfec70	2026-07-04	571b9f1d-680e-45b9-b80e-18f6904a83bc
6fa5de46-9edd-404a-915e-89d9f3f21ae7	طراحی برنامهٔ رفاهی کارکنان	پروژهٔ منابع انسانی شماره 4	2026-04-19	2026-06-28	active	17797748-c29a-4be6-a26c-3b13a6d22c31	12b3562f-9b7e-4fd7-b326-d7e733197f75	2026-07-20 11:46:45.199839+00	2026-07-20 11:46:45.199839+00	c2241423-6f70-4f15-92a9-c4a433dfec70	2026-04-19	571b9f1d-680e-45b9-b80e-18f6904a83bc
6fa5de46-9edd-404a-915e-89d9f3f21ae7	پیاده‌سازی سامانهٔ حضور و غیاب	پروژهٔ منابع انسانی شماره 5	2026-05-26	2026-07-17	active	17797748-c29a-4be6-a26c-3b13a6d22c31	2863ba04-93e9-4609-a47b-9c793b5ff35f	2026-07-20 11:46:45.199839+00	2026-07-20 11:46:45.199839+00	c2241423-6f70-4f15-92a9-c4a433dfec70	2026-05-26	571b9f1d-680e-45b9-b80e-18f6904a83bc
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
6fa5de46-9edd-404a-915e-89d9f3f21ae7	1c7c9744-f184-4945-939c-92a23d462b12	\N	a42bd423-3577-42e0-b239-611eb7480fb9	6367109c-4684-4a1b-a6b5-9843aa3f6a9d	رفع مشکل ناسازگاری مرورگر #1	\N	low	2026-08-08	4ce6036e-f3a0-47e0-82ad-455206cc474a	2026-07-20 11:46:45.199839+00	2026-07-20 11:46:45.199839+00	in_progress	\N	54	14.90	2026-08-06
6fa5de46-9edd-404a-915e-89d9f3f21ae7	1c7c9744-f184-4945-939c-92a23d462b12	\N	7c364485-75f2-4d57-81ee-62ec42c62177	6367109c-4684-4a1b-a6b5-9843aa3f6a9d	پیاده‌سازی صفحهٔ ورود جدید #2	\N	low	2026-08-15	cafd49a1-10e0-4931-8095-7723d3410744	2026-07-20 11:46:45.199839+00	2026-07-20 11:46:45.199839+00	in_progress	\N	48	5.70	2026-08-03
6fa5de46-9edd-404a-915e-89d9f3f21ae7	1c7c9744-f184-4945-939c-92a23d462b12	\N	a34644cb-4fa6-4ad1-904f-3e26b23679cd	6367109c-4684-4a1b-a6b5-9843aa3f6a9d	رفع مشکل ناسازگاری مرورگر #3	\N	low	2026-08-03	4007d8ed-236a-45cc-96b9-67fa88e5622a	2026-07-20 11:46:45.199839+00	2026-07-20 11:46:45.199839+00	in_progress	\N	58	22.40	2026-07-24
6fa5de46-9edd-404a-915e-89d9f3f21ae7	1c7c9744-f184-4945-939c-92a23d462b12	\N	3051f03b-e73a-49fb-a6d2-ab7406c6850b	6367109c-4684-4a1b-a6b5-9843aa3f6a9d	بازنویسی ماژول اعلان‌ها #4	\N	high	2026-08-01	f3319b58-77ba-433b-9133-34bf55a08965	2026-07-20 11:46:45.199839+00	2026-07-20 11:46:45.199839+00	todo	\N	79	35.60	2026-07-21
6fa5de46-9edd-404a-915e-89d9f3f21ae7	1c7c9744-f184-4945-939c-92a23d462b12	\N	398f8c1c-1d8b-48eb-9aed-08ebb479cff3	6367109c-4684-4a1b-a6b5-9843aa3f6a9d	تنظیم پایپ‌لاین CI/CD #5	\N	low	2026-06-23	9076222c-1351-4727-9b75-f8f7c8654de1	2026-07-20 11:46:45.199839+00	2026-07-20 11:46:45.199839+00	completed	approved	100	31.40	2026-06-20
6fa5de46-9edd-404a-915e-89d9f3f21ae7	1c7c9744-f184-4945-939c-92a23d462b12	\N	6367109c-4684-4a1b-a6b5-9843aa3f6a9d	6367109c-4684-4a1b-a6b5-9843aa3f6a9d	پیاده‌سازی احراز هویت دومرحله‌ای #6	\N	medium	2026-08-15	3757a60a-c298-4f9c-8797-b740ea859539	2026-07-20 11:46:45.199839+00	2026-07-20 11:46:45.199839+00	in_progress	\N	58	26.20	2026-08-10
6fa5de46-9edd-404a-915e-89d9f3f21ae7	1c7c9744-f184-4945-939c-92a23d462b12	\N	398f8c1c-1d8b-48eb-9aed-08ebb479cff3	6367109c-4684-4a1b-a6b5-9843aa3f6a9d	افزودن تست واحد برای سرویس کاربران #7	\N	high	2026-07-22	9bd5afb9-6377-4f65-b257-e34718e14a8c	2026-07-20 11:46:45.199839+00	2026-07-20 11:46:45.199839+00	todo	\N	34	28.70	2026-07-09
6fa5de46-9edd-404a-915e-89d9f3f21ae7	1c7c9744-f184-4945-939c-92a23d462b12	\N	fd5161f1-4abf-4cc9-8f06-914566393088	6367109c-4684-4a1b-a6b5-9843aa3f6a9d	به‌روزرسانی کتابخانه‌های وابسته #8	\N	high	2026-08-02	edd9304c-e9ad-45e5-97ca-7f66149348de	2026-07-20 11:46:45.199839+00	2026-07-20 11:46:45.199839+00	completed	approved	100	11.30	2026-07-26
6fa5de46-9edd-404a-915e-89d9f3f21ae7	1c7c9744-f184-4945-939c-92a23d462b12	\N	3051f03b-e73a-49fb-a6d2-ab7406c6850b	6367109c-4684-4a1b-a6b5-9843aa3f6a9d	افزودن تست واحد برای سرویس کاربران #9	\N	high	2026-07-22	046c72a5-4fe6-4300-b464-bc9d49bebea7	2026-07-20 11:46:45.199839+00	2026-07-20 11:46:45.199839+00	in_progress	\N	41	34.00	2026-07-03
6fa5de46-9edd-404a-915e-89d9f3f21ae7	1c7c9744-f184-4945-939c-92a23d462b12	\N	a34644cb-4fa6-4ad1-904f-3e26b23679cd	6367109c-4684-4a1b-a6b5-9843aa3f6a9d	رفع مشکل ناسازگاری مرورگر #10	\N	medium	2026-07-03	01d9addb-7e81-49b9-87dc-a5f74564e209	2026-07-20 11:46:45.199839+00	2026-07-20 11:46:45.199839+00	todo	\N	51	12.20	2026-06-30
6fa5de46-9edd-404a-915e-89d9f3f21ae7	1c7c9744-f184-4945-939c-92a23d462b12	\N	7c364485-75f2-4d57-81ee-62ec42c62177	6367109c-4684-4a1b-a6b5-9843aa3f6a9d	تنظیم پایپ‌لاین CI/CD #11	\N	medium	2026-07-14	1dcc82ac-67c1-4169-b6f7-4a2f2e331502	2026-07-20 11:46:45.199839+00	2026-07-20 11:46:45.199839+00	completed	pending	100	17.00	2026-07-06
6fa5de46-9edd-404a-915e-89d9f3f21ae7	1c7c9744-f184-4945-939c-92a23d462b12	\N	fd5161f1-4abf-4cc9-8f06-914566393088	6367109c-4684-4a1b-a6b5-9843aa3f6a9d	نوشتن مستندات فنی API #12	\N	high	2026-07-03	ad1c23e6-a53c-49f9-b85c-36fac1ed4e97	2026-07-20 11:46:45.199839+00	2026-07-20 11:46:45.199839+00	completed	approved	100	22.50	2026-06-24
6fa5de46-9edd-404a-915e-89d9f3f21ae7	1c7c9744-f184-4945-939c-92a23d462b12	\N	fd5161f1-4abf-4cc9-8f06-914566393088	6367109c-4684-4a1b-a6b5-9843aa3f6a9d	رفع مشکل کندی بارگذاری صفحه #13	\N	low	2026-08-06	4aeaf774-85bb-4399-8efb-cd55d3b0feaf	2026-07-20 11:46:45.199839+00	2026-07-20 11:46:45.199839+00	completed	approved	100	39.90	2026-07-23
6fa5de46-9edd-404a-915e-89d9f3f21ae7	1c7c9744-f184-4945-939c-92a23d462b12	\N	7c364485-75f2-4d57-81ee-62ec42c62177	6367109c-4684-4a1b-a6b5-9843aa3f6a9d	بازنویسی ماژول اعلان‌ها #14	\N	low	2026-08-06	4ae2f1d0-ed28-4c07-82ac-3f4ddaaf6945	2026-07-20 11:46:45.199839+00	2026-07-20 11:46:45.199839+00	completed	approved	100	7.80	2026-08-03
6fa5de46-9edd-404a-915e-89d9f3f21ae7	1c7c9744-f184-4945-939c-92a23d462b12	\N	7c364485-75f2-4d57-81ee-62ec42c62177	6367109c-4684-4a1b-a6b5-9843aa3f6a9d	پیاده‌سازی احراز هویت دومرحله‌ای #15	\N	high	2026-07-04	6dd96452-dbbd-43a5-a522-544093a832f2	2026-07-20 11:46:45.199839+00	2026-07-20 11:46:45.199839+00	completed	approved	100	39.90	2026-06-20
6fa5de46-9edd-404a-915e-89d9f3f21ae7	1c7c9744-f184-4945-939c-92a23d462b12	\N	a42bd423-3577-42e0-b239-611eb7480fb9	6367109c-4684-4a1b-a6b5-9843aa3f6a9d	تنظیم پایپ‌لاین CI/CD #16	\N	high	2026-07-23	ddc02e4f-2e48-48a1-aebe-4dfd228dc20c	2026-07-20 11:46:45.199839+00	2026-07-20 11:46:45.199839+00	in_progress	\N	14	27.90	2026-07-21
6fa5de46-9edd-404a-915e-89d9f3f21ae7	1c7c9744-f184-4945-939c-92a23d462b12	\N	a42bd423-3577-42e0-b239-611eb7480fb9	6367109c-4684-4a1b-a6b5-9843aa3f6a9d	پیاده‌سازی صفحهٔ ورود جدید #17	\N	medium	2026-07-15	ab8a62be-cb91-4a0b-a863-48375adf3f65	2026-07-20 11:46:45.199839+00	2026-07-20 11:46:45.199839+00	archived	\N	55	8.00	2026-07-03
6fa5de46-9edd-404a-915e-89d9f3f21ae7	1c7c9744-f184-4945-939c-92a23d462b12	\N	6367109c-4684-4a1b-a6b5-9843aa3f6a9d	6367109c-4684-4a1b-a6b5-9843aa3f6a9d	به‌روزرسانی کتابخانه‌های وابسته #18	\N	low	2026-08-21	dd33859a-239b-475b-a1d2-2dd4b2581969	2026-07-20 11:46:45.199839+00	2026-07-20 11:46:45.199839+00	archived	\N	64	36.70	2026-08-11
6fa5de46-9edd-404a-915e-89d9f3f21ae7	adfcac3e-63b8-4b84-a951-57550e399e3a	\N	a34644cb-4fa6-4ad1-904f-3e26b23679cd	6367109c-4684-4a1b-a6b5-9843aa3f6a9d	پیاده‌سازی صفحهٔ داشبورد مدیریتی #19	\N	low	2026-08-13	d05e5a12-c2b2-4ce0-b976-fa443bcb45a6	2026-07-20 11:46:45.199839+00	2026-07-20 11:46:45.199839+00	completed	approved	100	7.80	2026-07-26
6fa5de46-9edd-404a-915e-89d9f3f21ae7	adfcac3e-63b8-4b84-a951-57550e399e3a	\N	a34644cb-4fa6-4ad1-904f-3e26b23679cd	6367109c-4684-4a1b-a6b5-9843aa3f6a9d	افزودن قابلیت جست‌وجوی پیشرفته #20	\N	low	2026-08-07	20004785-1ad9-4d72-b00d-52ba9100fab9	2026-07-20 11:46:45.199839+00	2026-07-20 11:46:45.199839+00	todo	\N	76	14.30	2026-07-20
6fa5de46-9edd-404a-915e-89d9f3f21ae7	adfcac3e-63b8-4b84-a951-57550e399e3a	\N	6367109c-4684-4a1b-a6b5-9843aa3f6a9d	6367109c-4684-4a1b-a6b5-9843aa3f6a9d	افزودن قابلیت جست‌وجوی پیشرفته #21	\N	medium	2026-08-27	b38276cd-b84f-488e-b02c-54c55b04701d	2026-07-20 11:46:45.199839+00	2026-07-20 11:46:45.199839+00	todo	\N	30	4.20	2026-08-14
6fa5de46-9edd-404a-915e-89d9f3f21ae7	adfcac3e-63b8-4b84-a951-57550e399e3a	\N	a42bd423-3577-42e0-b239-611eb7480fb9	6367109c-4684-4a1b-a6b5-9843aa3f6a9d	بازنویسی ماژول اعلان‌ها #22	\N	low	2026-07-08	187f5fc9-e3d2-4df2-abfb-c26138b993de	2026-07-20 11:46:45.199839+00	2026-07-20 11:46:45.199839+00	todo	\N	68	31.10	2026-06-21
6fa5de46-9edd-404a-915e-89d9f3f21ae7	adfcac3e-63b8-4b84-a951-57550e399e3a	\N	7c364485-75f2-4d57-81ee-62ec42c62177	6367109c-4684-4a1b-a6b5-9843aa3f6a9d	طراحی API نسخهٔ دوم #23	\N	high	2026-07-28	a40edda0-642d-4650-aa2b-7633bdf24624	2026-07-20 11:46:45.199839+00	2026-07-20 11:46:45.199839+00	completed	approved	100	35.20	2026-07-21
6fa5de46-9edd-404a-915e-89d9f3f21ae7	adfcac3e-63b8-4b84-a951-57550e399e3a	\N	3051f03b-e73a-49fb-a6d2-ab7406c6850b	6367109c-4684-4a1b-a6b5-9843aa3f6a9d	رفع مشکل ناسازگاری مرورگر #24	\N	high	2026-09-02	b7169780-724e-451a-ae17-19f441a26308	2026-07-20 11:46:45.199839+00	2026-07-20 11:46:45.199839+00	in_progress	\N	25	29.10	2026-08-14
6fa5de46-9edd-404a-915e-89d9f3f21ae7	adfcac3e-63b8-4b84-a951-57550e399e3a	\N	3051f03b-e73a-49fb-a6d2-ab7406c6850b	6367109c-4684-4a1b-a6b5-9843aa3f6a9d	بررسی و رفع آسیب‌پذیری امنیتی #25	\N	low	2026-08-01	096f7f29-fc56-4e30-823e-e6ca70e8e59a	2026-07-20 11:46:45.199839+00	2026-07-20 11:46:45.199839+00	completed	pending	100	11.40	2026-07-14
6fa5de46-9edd-404a-915e-89d9f3f21ae7	adfcac3e-63b8-4b84-a951-57550e399e3a	\N	6367109c-4684-4a1b-a6b5-9843aa3f6a9d	6367109c-4684-4a1b-a6b5-9843aa3f6a9d	به‌روزرسانی کتابخانه‌های وابسته #26	\N	low	2026-07-07	8430c3c1-297d-4114-a059-c1fa92640b19	2026-07-20 11:46:45.199839+00	2026-07-20 11:46:45.199839+00	in_progress	\N	75	10.40	2026-06-17
6fa5de46-9edd-404a-915e-89d9f3f21ae7	adfcac3e-63b8-4b84-a951-57550e399e3a	\N	6367109c-4684-4a1b-a6b5-9843aa3f6a9d	6367109c-4684-4a1b-a6b5-9843aa3f6a9d	افزودن تست واحد برای سرویس کاربران #27	\N	low	2026-07-29	21003b7c-9144-4f74-943d-17d4cfaef9a5	2026-07-20 11:46:45.199839+00	2026-07-20 11:46:45.199839+00	archived	\N	4	34.70	2026-07-26
6fa5de46-9edd-404a-915e-89d9f3f21ae7	adfcac3e-63b8-4b84-a951-57550e399e3a	\N	6367109c-4684-4a1b-a6b5-9843aa3f6a9d	6367109c-4684-4a1b-a6b5-9843aa3f6a9d	افزودن تست واحد برای سرویس کاربران #28	\N	high	2026-08-14	13257893-b253-483e-a87a-7e1a3966fcbb	2026-07-20 11:46:45.199839+00	2026-07-20 11:46:45.199839+00	completed	approved	100	7.00	2026-07-28
6fa5de46-9edd-404a-915e-89d9f3f21ae7	adfcac3e-63b8-4b84-a951-57550e399e3a	\N	a42bd423-3577-42e0-b239-611eb7480fb9	6367109c-4684-4a1b-a6b5-9843aa3f6a9d	رفع مشکل ناسازگاری مرورگر #29	\N	medium	2026-08-22	2816cfb0-f896-4eff-a3b4-abb075f0dc45	2026-07-20 11:46:45.199839+00	2026-07-20 11:46:45.199839+00	completed	approved	100	9.20	2026-08-05
6fa5de46-9edd-404a-915e-89d9f3f21ae7	adfcac3e-63b8-4b84-a951-57550e399e3a	\N	6367109c-4684-4a1b-a6b5-9843aa3f6a9d	6367109c-4684-4a1b-a6b5-9843aa3f6a9d	بررسی و رفع آسیب‌پذیری امنیتی #30	\N	high	2026-07-28	54275bdf-1154-44a4-b628-2e78a6b4b79c	2026-07-20 11:46:45.199839+00	2026-07-20 11:46:45.199839+00	completed	approved	100	4.10	2026-07-13
6fa5de46-9edd-404a-915e-89d9f3f21ae7	adfcac3e-63b8-4b84-a951-57550e399e3a	\N	fd5161f1-4abf-4cc9-8f06-914566393088	6367109c-4684-4a1b-a6b5-9843aa3f6a9d	رفع مشکل ناسازگاری مرورگر #31	\N	low	2026-07-23	9318e72a-b31d-421f-a86a-0910c1745e11	2026-07-20 11:46:45.199839+00	2026-07-20 11:46:45.199839+00	completed	approved	100	11.40	2026-07-11
6fa5de46-9edd-404a-915e-89d9f3f21ae7	adfcac3e-63b8-4b84-a951-57550e399e3a	\N	7c364485-75f2-4d57-81ee-62ec42c62177	6367109c-4684-4a1b-a6b5-9843aa3f6a9d	طراحی API نسخهٔ دوم #32	\N	medium	2026-07-20	4840e870-0f81-4bae-bd5c-c617bd670553	2026-07-20 11:46:45.199839+00	2026-07-20 11:46:45.199839+00	completed	approved	100	11.50	2026-07-13
6fa5de46-9edd-404a-915e-89d9f3f21ae7	adfcac3e-63b8-4b84-a951-57550e399e3a	\N	6367109c-4684-4a1b-a6b5-9843aa3f6a9d	6367109c-4684-4a1b-a6b5-9843aa3f6a9d	پیاده‌سازی صفحهٔ ورود جدید #33	\N	low	2026-08-28	14f54408-a36b-401c-b5cb-f24cd4b58bd5	2026-07-20 11:46:45.199839+00	2026-07-20 11:46:45.199839+00	completed	pending	100	26.80	2026-08-09
6fa5de46-9edd-404a-915e-89d9f3f21ae7	adfcac3e-63b8-4b84-a951-57550e399e3a	\N	a42bd423-3577-42e0-b239-611eb7480fb9	6367109c-4684-4a1b-a6b5-9843aa3f6a9d	بهینه‌سازی کوئری‌های گزارش‌گیری #34	\N	medium	2026-06-30	622ac1af-4bf4-452f-8a0f-70ae5f16b295	2026-07-20 11:46:45.199839+00	2026-07-20 11:46:45.199839+00	todo	\N	62	20.30	2026-06-21
6fa5de46-9edd-404a-915e-89d9f3f21ae7	adfcac3e-63b8-4b84-a951-57550e399e3a	\N	a34644cb-4fa6-4ad1-904f-3e26b23679cd	6367109c-4684-4a1b-a6b5-9843aa3f6a9d	بهینه‌سازی کوئری‌های گزارش‌گیری #35	\N	medium	2026-08-15	13c26385-7b15-402b-af4a-3311cbab9488	2026-07-20 11:46:45.199839+00	2026-07-20 11:46:45.199839+00	in_progress	\N	0	39.40	2026-08-12
6fa5de46-9edd-404a-915e-89d9f3f21ae7	adfcac3e-63b8-4b84-a951-57550e399e3a	\N	398f8c1c-1d8b-48eb-9aed-08ebb479cff3	6367109c-4684-4a1b-a6b5-9843aa3f6a9d	تنظیم پایپ‌لاین CI/CD #36	\N	high	2026-08-18	7d1e13ab-bc62-4d3c-9133-2cb500461ad1	2026-07-20 11:46:45.199839+00	2026-07-20 11:46:45.199839+00	completed	approved	100	20.50	2026-07-30
6fa5de46-9edd-404a-915e-89d9f3f21ae7	b2c5e0fe-deb4-4a0f-bf3b-58b26bc437f5	\N	7c364485-75f2-4d57-81ee-62ec42c62177	6367109c-4684-4a1b-a6b5-9843aa3f6a9d	پیاده‌سازی صفحهٔ داشبورد مدیریتی #37	\N	high	2026-07-02	a1d258f5-6539-48ff-9d63-1249c9e66a02	2026-07-20 11:46:45.199839+00	2026-07-20 11:46:45.199839+00	in_progress	\N	69	4.30	2026-06-29
6fa5de46-9edd-404a-915e-89d9f3f21ae7	b2c5e0fe-deb4-4a0f-bf3b-58b26bc437f5	\N	398f8c1c-1d8b-48eb-9aed-08ebb479cff3	6367109c-4684-4a1b-a6b5-9843aa3f6a9d	بررسی و رفع آسیب‌پذیری امنیتی #38	\N	high	2026-07-09	01064395-13a2-4de9-9073-e5d91dd3b3e4	2026-07-20 11:46:45.199839+00	2026-07-20 11:46:45.199839+00	todo	\N	67	8.00	2026-06-19
6fa5de46-9edd-404a-915e-89d9f3f21ae7	b2c5e0fe-deb4-4a0f-bf3b-58b26bc437f5	\N	a42bd423-3577-42e0-b239-611eb7480fb9	6367109c-4684-4a1b-a6b5-9843aa3f6a9d	پیاده‌سازی صفحهٔ ورود جدید #39	\N	high	2026-08-16	580d50a3-c279-421f-b51a-c38a4466416d	2026-07-20 11:46:45.199839+00	2026-07-20 11:46:45.199839+00	todo	\N	8	27.70	2026-08-09
6fa5de46-9edd-404a-915e-89d9f3f21ae7	b2c5e0fe-deb4-4a0f-bf3b-58b26bc437f5	\N	7c364485-75f2-4d57-81ee-62ec42c62177	6367109c-4684-4a1b-a6b5-9843aa3f6a9d	افزودن تست واحد برای سرویس کاربران #40	\N	high	2026-07-13	a2dfae99-79ae-4f4b-8e87-d766edb93e5f	2026-07-20 11:46:45.199839+00	2026-07-20 11:46:45.199839+00	in_progress	\N	76	3.50	2026-06-23
6fa5de46-9edd-404a-915e-89d9f3f21ae7	b2c5e0fe-deb4-4a0f-bf3b-58b26bc437f5	\N	6367109c-4684-4a1b-a6b5-9843aa3f6a9d	6367109c-4684-4a1b-a6b5-9843aa3f6a9d	پیاده‌سازی صفحهٔ داشبورد مدیریتی #41	\N	high	2026-08-17	5456f8bb-fc35-46a2-b317-62c55003b64f	2026-07-20 11:46:45.199839+00	2026-07-20 11:46:45.199839+00	in_progress	\N	40	37.50	2026-07-28
6fa5de46-9edd-404a-915e-89d9f3f21ae7	b2c5e0fe-deb4-4a0f-bf3b-58b26bc437f5	\N	7c364485-75f2-4d57-81ee-62ec42c62177	6367109c-4684-4a1b-a6b5-9843aa3f6a9d	پیاده‌سازی احراز هویت دومرحله‌ای #42	\N	low	2026-07-11	3753f4fd-d921-45ee-b0f7-bf06fc8822f5	2026-07-20 11:46:45.199839+00	2026-07-20 11:46:45.199839+00	completed	pending	100	27.50	2026-07-01
6fa5de46-9edd-404a-915e-89d9f3f21ae7	b2c5e0fe-deb4-4a0f-bf3b-58b26bc437f5	\N	398f8c1c-1d8b-48eb-9aed-08ebb479cff3	6367109c-4684-4a1b-a6b5-9843aa3f6a9d	رفع باگ در ماژول پرداخت #43	\N	medium	2026-08-07	3f66d431-45ea-48e9-99a7-695c0e5ba17e	2026-07-20 11:46:45.199839+00	2026-07-20 11:46:45.199839+00	completed	approved	100	25.60	2026-08-03
6fa5de46-9edd-404a-915e-89d9f3f21ae7	b2c5e0fe-deb4-4a0f-bf3b-58b26bc437f5	\N	a42bd423-3577-42e0-b239-611eb7480fb9	6367109c-4684-4a1b-a6b5-9843aa3f6a9d	افزودن تست واحد برای سرویس کاربران #44	\N	high	2026-07-09	32cb3c35-b48f-42a7-b720-eebb2f3659f2	2026-07-20 11:46:45.199839+00	2026-07-20 11:46:45.199839+00	todo	\N	33	7.00	2026-06-20
6fa5de46-9edd-404a-915e-89d9f3f21ae7	b2c5e0fe-deb4-4a0f-bf3b-58b26bc437f5	\N	398f8c1c-1d8b-48eb-9aed-08ebb479cff3	6367109c-4684-4a1b-a6b5-9843aa3f6a9d	رفع مشکل کندی بارگذاری صفحه #45	\N	medium	2026-08-20	e9de6904-1115-4069-bf37-7b39f1018475	2026-07-20 11:46:45.199839+00	2026-07-20 11:46:45.199839+00	todo	\N	20	18.70	2026-08-11
6fa5de46-9edd-404a-915e-89d9f3f21ae7	b2c5e0fe-deb4-4a0f-bf3b-58b26bc437f5	\N	a42bd423-3577-42e0-b239-611eb7480fb9	6367109c-4684-4a1b-a6b5-9843aa3f6a9d	رفع مشکل ناسازگاری مرورگر #46	\N	high	2026-07-26	55db2a01-80b5-405f-97f1-f92356356712	2026-07-20 11:46:45.199839+00	2026-07-20 11:46:45.199839+00	archived	\N	67	2.30	2026-07-05
6fa5de46-9edd-404a-915e-89d9f3f21ae7	b2c5e0fe-deb4-4a0f-bf3b-58b26bc437f5	\N	a34644cb-4fa6-4ad1-904f-3e26b23679cd	6367109c-4684-4a1b-a6b5-9843aa3f6a9d	افزودن قابلیت جست‌وجوی پیشرفته #47	\N	low	2026-08-02	31ad8ea6-0706-46ab-9150-464d7cb28efa	2026-07-20 11:46:45.199839+00	2026-07-20 11:46:45.199839+00	completed	approved	100	12.00	2026-07-28
6fa5de46-9edd-404a-915e-89d9f3f21ae7	b2c5e0fe-deb4-4a0f-bf3b-58b26bc437f5	\N	6367109c-4684-4a1b-a6b5-9843aa3f6a9d	6367109c-4684-4a1b-a6b5-9843aa3f6a9d	طراحی API نسخهٔ دوم #48	\N	medium	2026-07-27	efe7716b-8a35-461f-9f24-198520502521	2026-07-20 11:46:45.199839+00	2026-07-20 11:46:45.199839+00	archived	\N	77	10.00	2026-07-21
6fa5de46-9edd-404a-915e-89d9f3f21ae7	b2c5e0fe-deb4-4a0f-bf3b-58b26bc437f5	\N	398f8c1c-1d8b-48eb-9aed-08ebb479cff3	6367109c-4684-4a1b-a6b5-9843aa3f6a9d	به‌روزرسانی کتابخانه‌های وابسته #49	\N	medium	2026-08-08	5b03be5a-25d6-4f3d-a70b-6d013be4d622	2026-07-20 11:46:45.199839+00	2026-07-20 11:46:45.199839+00	in_progress	\N	32	36.40	2026-07-29
6fa5de46-9edd-404a-915e-89d9f3f21ae7	b2c5e0fe-deb4-4a0f-bf3b-58b26bc437f5	\N	a34644cb-4fa6-4ad1-904f-3e26b23679cd	6367109c-4684-4a1b-a6b5-9843aa3f6a9d	بازنویسی ماژول اعلان‌ها #50	\N	medium	2026-07-06	ba588c3b-5b43-48ed-acb0-528223f9c9b0	2026-07-20 11:46:45.199839+00	2026-07-20 11:46:45.199839+00	todo	\N	5	2.10	2026-06-21
6fa5de46-9edd-404a-915e-89d9f3f21ae7	b2c5e0fe-deb4-4a0f-bf3b-58b26bc437f5	\N	a34644cb-4fa6-4ad1-904f-3e26b23679cd	6367109c-4684-4a1b-a6b5-9843aa3f6a9d	بهینه‌سازی کوئری‌های گزارش‌گیری #51	\N	high	2026-08-05	cd3da594-8b43-489c-9602-247972bc67af	2026-07-20 11:46:45.199839+00	2026-07-20 11:46:45.199839+00	todo	\N	56	23.00	2026-07-26
6fa5de46-9edd-404a-915e-89d9f3f21ae7	b2c5e0fe-deb4-4a0f-bf3b-58b26bc437f5	\N	3051f03b-e73a-49fb-a6d2-ab7406c6850b	6367109c-4684-4a1b-a6b5-9843aa3f6a9d	به‌روزرسانی کتابخانه‌های وابسته #52	\N	low	2026-06-26	a14ca87d-8fba-4680-b894-04c592182789	2026-07-20 11:46:45.199839+00	2026-07-20 11:46:45.199839+00	completed	approved	100	33.70	2026-06-20
6fa5de46-9edd-404a-915e-89d9f3f21ae7	b2c5e0fe-deb4-4a0f-bf3b-58b26bc437f5	\N	a42bd423-3577-42e0-b239-611eb7480fb9	6367109c-4684-4a1b-a6b5-9843aa3f6a9d	طراحی API نسخهٔ دوم #53	\N	medium	2026-06-27	1276c989-5672-4ed3-ad9b-60c79ea923d6	2026-07-20 11:46:45.199839+00	2026-07-20 11:46:45.199839+00	completed	approved	100	36.20	2026-06-24
6fa5de46-9edd-404a-915e-89d9f3f21ae7	b2c5e0fe-deb4-4a0f-bf3b-58b26bc437f5	\N	a34644cb-4fa6-4ad1-904f-3e26b23679cd	6367109c-4684-4a1b-a6b5-9843aa3f6a9d	افزودن تست واحد برای سرویس کاربران #54	\N	high	2026-08-25	f124f160-02b5-40ef-acdf-5f77b9a9ba65	2026-07-20 11:46:45.199839+00	2026-07-20 11:46:45.199839+00	todo	\N	31	27.30	2026-08-12
6fa5de46-9edd-404a-915e-89d9f3f21ae7	23082ced-9e61-45d1-bb62-c2bd122dbba1	\N	398f8c1c-1d8b-48eb-9aed-08ebb479cff3	6367109c-4684-4a1b-a6b5-9843aa3f6a9d	پیاده‌سازی صفحهٔ داشبورد مدیریتی #55	\N	high	2026-08-05	b582082f-0a26-4d58-92c0-708c2cb4e8b8	2026-07-20 11:46:45.199839+00	2026-07-20 11:46:45.199839+00	archived	\N	19	37.20	2026-07-21
6fa5de46-9edd-404a-915e-89d9f3f21ae7	23082ced-9e61-45d1-bb62-c2bd122dbba1	\N	7c364485-75f2-4d57-81ee-62ec42c62177	6367109c-4684-4a1b-a6b5-9843aa3f6a9d	افزودن قابلیت جست‌وجوی پیشرفته #56	\N	medium	2026-08-13	79f50796-0593-4f91-adb6-238b92b4c961	2026-07-20 11:46:45.199839+00	2026-07-20 11:46:45.199839+00	todo	\N	3	8.80	2026-08-06
6fa5de46-9edd-404a-915e-89d9f3f21ae7	23082ced-9e61-45d1-bb62-c2bd122dbba1	\N	398f8c1c-1d8b-48eb-9aed-08ebb479cff3	6367109c-4684-4a1b-a6b5-9843aa3f6a9d	طراحی API نسخهٔ دوم #57	\N	low	2026-08-15	4c1b7d2f-c80a-4ad1-9085-2753bf699b38	2026-07-20 11:46:45.199839+00	2026-07-20 11:46:45.199839+00	in_progress	\N	13	16.50	2026-08-06
6fa5de46-9edd-404a-915e-89d9f3f21ae7	23082ced-9e61-45d1-bb62-c2bd122dbba1	\N	6367109c-4684-4a1b-a6b5-9843aa3f6a9d	6367109c-4684-4a1b-a6b5-9843aa3f6a9d	رفع مشکل کندی بارگذاری صفحه #58	\N	medium	2026-08-23	787adb4d-2ca5-4a61-bfe6-aaf94d0e22b9	2026-07-20 11:46:45.199839+00	2026-07-20 11:46:45.199839+00	completed	approved	100	33.20	2026-08-07
6fa5de46-9edd-404a-915e-89d9f3f21ae7	23082ced-9e61-45d1-bb62-c2bd122dbba1	\N	a34644cb-4fa6-4ad1-904f-3e26b23679cd	6367109c-4684-4a1b-a6b5-9843aa3f6a9d	تنظیم پایپ‌لاین CI/CD #59	\N	low	2026-07-02	57cd034f-20d1-4d05-8003-ac11421bad86	2026-07-20 11:46:45.199839+00	2026-07-20 11:46:45.199839+00	in_progress	\N	51	14.50	2026-06-30
6fa5de46-9edd-404a-915e-89d9f3f21ae7	23082ced-9e61-45d1-bb62-c2bd122dbba1	\N	a34644cb-4fa6-4ad1-904f-3e26b23679cd	6367109c-4684-4a1b-a6b5-9843aa3f6a9d	رفع مشکل کندی بارگذاری صفحه #60	\N	high	2026-08-14	8c758fe0-d6ad-405c-adf5-21e627012981	2026-07-20 11:46:45.199839+00	2026-07-20 11:46:45.199839+00	todo	\N	65	17.20	2026-08-04
6fa5de46-9edd-404a-915e-89d9f3f21ae7	23082ced-9e61-45d1-bb62-c2bd122dbba1	\N	a34644cb-4fa6-4ad1-904f-3e26b23679cd	6367109c-4684-4a1b-a6b5-9843aa3f6a9d	افزودن قابلیت جست‌وجوی پیشرفته #61	\N	medium	2026-06-22	0db9e83d-51a7-47c2-a069-7edac3a73a09	2026-07-20 11:46:45.199839+00	2026-07-20 11:46:45.199839+00	completed	approved	100	8.80	2026-06-17
6fa5de46-9edd-404a-915e-89d9f3f21ae7	23082ced-9e61-45d1-bb62-c2bd122dbba1	\N	398f8c1c-1d8b-48eb-9aed-08ebb479cff3	6367109c-4684-4a1b-a6b5-9843aa3f6a9d	پیاده‌سازی احراز هویت دومرحله‌ای #62	\N	medium	2026-07-13	7ff0771f-7ab8-45fa-9e73-9ea1e0979873	2026-07-20 11:46:45.199839+00	2026-07-20 11:46:45.199839+00	todo	\N	40	18.60	2026-06-22
6fa5de46-9edd-404a-915e-89d9f3f21ae7	23082ced-9e61-45d1-bb62-c2bd122dbba1	\N	a42bd423-3577-42e0-b239-611eb7480fb9	6367109c-4684-4a1b-a6b5-9843aa3f6a9d	افزودن تست واحد برای سرویس کاربران #63	\N	medium	2026-07-30	c0624abd-767d-40c3-96e8-a7aced76e754	2026-07-20 11:46:45.199839+00	2026-07-20 11:46:45.199839+00	todo	\N	5	28.90	2026-07-10
6fa5de46-9edd-404a-915e-89d9f3f21ae7	23082ced-9e61-45d1-bb62-c2bd122dbba1	\N	6367109c-4684-4a1b-a6b5-9843aa3f6a9d	6367109c-4684-4a1b-a6b5-9843aa3f6a9d	رفع مشکل کندی بارگذاری صفحه #64	\N	medium	2026-07-28	9f945151-1c1a-48cd-91e1-ae32cb5228a8	2026-07-20 11:46:45.199839+00	2026-07-20 11:46:45.199839+00	completed	rejected	100	4.70	2026-07-20
6fa5de46-9edd-404a-915e-89d9f3f21ae7	23082ced-9e61-45d1-bb62-c2bd122dbba1	\N	fd5161f1-4abf-4cc9-8f06-914566393088	6367109c-4684-4a1b-a6b5-9843aa3f6a9d	تنظیم پایپ‌لاین CI/CD #65	\N	low	2026-08-06	28f1a7d9-d150-4ef2-b7b7-ad0a38d85ccb	2026-07-20 11:46:45.199839+00	2026-07-20 11:46:45.199839+00	in_progress	\N	38	21.30	2026-07-25
6fa5de46-9edd-404a-915e-89d9f3f21ae7	23082ced-9e61-45d1-bb62-c2bd122dbba1	\N	fd5161f1-4abf-4cc9-8f06-914566393088	6367109c-4684-4a1b-a6b5-9843aa3f6a9d	نوشتن مستندات فنی API #66	\N	medium	2026-07-20	14465c9c-b8c0-4334-abdb-25e7f214a7a1	2026-07-20 11:46:45.199839+00	2026-07-20 11:46:45.199839+00	in_progress	\N	70	6.80	2026-07-06
6fa5de46-9edd-404a-915e-89d9f3f21ae7	23082ced-9e61-45d1-bb62-c2bd122dbba1	\N	3051f03b-e73a-49fb-a6d2-ab7406c6850b	6367109c-4684-4a1b-a6b5-9843aa3f6a9d	پیاده‌سازی صفحهٔ داشبورد مدیریتی #67	\N	high	2026-08-05	9cb78109-41ea-4ffc-ba37-0180a6385ac2	2026-07-20 11:46:45.199839+00	2026-07-20 11:46:45.199839+00	completed	rejected	100	13.40	2026-07-29
6fa5de46-9edd-404a-915e-89d9f3f21ae7	23082ced-9e61-45d1-bb62-c2bd122dbba1	\N	a42bd423-3577-42e0-b239-611eb7480fb9	6367109c-4684-4a1b-a6b5-9843aa3f6a9d	افزودن تست واحد برای سرویس کاربران #68	\N	medium	2026-07-16	b6f80ff3-7da4-4408-9da3-9e2884185852	2026-07-20 11:46:45.199839+00	2026-07-20 11:46:45.199839+00	todo	\N	74	25.10	2026-07-05
6fa5de46-9edd-404a-915e-89d9f3f21ae7	23082ced-9e61-45d1-bb62-c2bd122dbba1	\N	398f8c1c-1d8b-48eb-9aed-08ebb479cff3	6367109c-4684-4a1b-a6b5-9843aa3f6a9d	به‌روزرسانی کتابخانه‌های وابسته #69	\N	medium	2026-08-06	720701a9-e459-4108-bed0-9cd48bad5fbc	2026-07-20 11:46:45.199839+00	2026-07-20 11:46:45.199839+00	completed	approved	100	32.20	2026-07-29
6fa5de46-9edd-404a-915e-89d9f3f21ae7	23082ced-9e61-45d1-bb62-c2bd122dbba1	\N	a34644cb-4fa6-4ad1-904f-3e26b23679cd	6367109c-4684-4a1b-a6b5-9843aa3f6a9d	طراحی API نسخهٔ دوم #70	\N	high	2026-06-30	d48b90d7-2da2-4105-ba0c-ee39244f79cd	2026-07-20 11:46:45.199839+00	2026-07-20 11:46:45.199839+00	archived	\N	79	14.70	2026-06-26
6fa5de46-9edd-404a-915e-89d9f3f21ae7	23082ced-9e61-45d1-bb62-c2bd122dbba1	\N	a34644cb-4fa6-4ad1-904f-3e26b23679cd	6367109c-4684-4a1b-a6b5-9843aa3f6a9d	افزودن تست واحد برای سرویس کاربران #71	\N	low	2026-07-12	0d0ae620-c75a-4269-a959-cf4c2519bcdb	2026-07-20 11:46:45.199839+00	2026-07-20 11:46:45.199839+00	archived	\N	18	2.90	2026-07-01
6fa5de46-9edd-404a-915e-89d9f3f21ae7	23082ced-9e61-45d1-bb62-c2bd122dbba1	\N	7c364485-75f2-4d57-81ee-62ec42c62177	6367109c-4684-4a1b-a6b5-9843aa3f6a9d	بررسی و رفع آسیب‌پذیری امنیتی #72	\N	medium	2026-08-08	e451e390-7cb3-45f5-a25d-1335bfe3ca60	2026-07-20 11:46:45.199839+00	2026-07-20 11:46:45.199839+00	completed	pending	100	35.70	2026-08-04
6fa5de46-9edd-404a-915e-89d9f3f21ae7	4d1e5701-762a-4826-afcd-c7c64e14ccb5	\N	a42bd423-3577-42e0-b239-611eb7480fb9	6367109c-4684-4a1b-a6b5-9843aa3f6a9d	بررسی و رفع آسیب‌پذیری امنیتی #73	\N	medium	2026-08-14	43caf652-4429-4c37-806b-1ee62037438c	2026-07-20 11:46:45.199839+00	2026-07-20 11:46:45.199839+00	todo	\N	31	7.60	2026-07-31
6fa5de46-9edd-404a-915e-89d9f3f21ae7	4d1e5701-762a-4826-afcd-c7c64e14ccb5	\N	fd5161f1-4abf-4cc9-8f06-914566393088	6367109c-4684-4a1b-a6b5-9843aa3f6a9d	رفع مشکل ناسازگاری مرورگر #74	\N	medium	2026-08-17	5965848b-bc6a-490c-bb9c-9705268add63	2026-07-20 11:46:45.199839+00	2026-07-20 11:46:45.199839+00	todo	\N	28	8.70	2026-08-12
6fa5de46-9edd-404a-915e-89d9f3f21ae7	4d1e5701-762a-4826-afcd-c7c64e14ccb5	\N	fd5161f1-4abf-4cc9-8f06-914566393088	6367109c-4684-4a1b-a6b5-9843aa3f6a9d	افزودن قابلیت جست‌وجوی پیشرفته #75	\N	low	2026-07-30	75cc91d1-fd1a-4ac5-9ae5-9e2eb4ed3715	2026-07-20 11:46:45.199839+00	2026-07-20 11:46:45.199839+00	completed	approved	100	19.30	2026-07-21
6fa5de46-9edd-404a-915e-89d9f3f21ae7	4d1e5701-762a-4826-afcd-c7c64e14ccb5	\N	a34644cb-4fa6-4ad1-904f-3e26b23679cd	6367109c-4684-4a1b-a6b5-9843aa3f6a9d	رفع مشکل کندی بارگذاری صفحه #76	\N	medium	2026-08-11	7f153083-0304-4496-8838-c775e807ec51	2026-07-20 11:46:45.199839+00	2026-07-20 11:46:45.199839+00	completed	pending	100	25.30	2026-07-21
6fa5de46-9edd-404a-915e-89d9f3f21ae7	4d1e5701-762a-4826-afcd-c7c64e14ccb5	\N	fd5161f1-4abf-4cc9-8f06-914566393088	6367109c-4684-4a1b-a6b5-9843aa3f6a9d	بررسی و رفع آسیب‌پذیری امنیتی #77	\N	low	2026-09-01	0bd35daf-b38a-47a0-a71f-47935c219f7e	2026-07-20 11:46:45.199839+00	2026-07-20 11:46:45.199839+00	completed	approved	100	30.30	2026-08-13
6fa5de46-9edd-404a-915e-89d9f3f21ae7	4d1e5701-762a-4826-afcd-c7c64e14ccb5	\N	3051f03b-e73a-49fb-a6d2-ab7406c6850b	6367109c-4684-4a1b-a6b5-9843aa3f6a9d	رفع مشکل ناسازگاری مرورگر #78	\N	high	2026-07-11	c16d9478-c862-4552-9449-7c1052e7cf4e	2026-07-20 11:46:45.199839+00	2026-07-20 11:46:45.199839+00	completed	approved	100	20.40	2026-07-01
6fa5de46-9edd-404a-915e-89d9f3f21ae7	4d1e5701-762a-4826-afcd-c7c64e14ccb5	\N	7c364485-75f2-4d57-81ee-62ec42c62177	6367109c-4684-4a1b-a6b5-9843aa3f6a9d	نوشتن مستندات فنی API #79	\N	medium	2026-07-18	ca32b349-c851-4ab9-bd87-fb52e71301f5	2026-07-20 11:46:45.199839+00	2026-07-20 11:46:45.199839+00	in_progress	\N	30	12.30	2026-07-14
6fa5de46-9edd-404a-915e-89d9f3f21ae7	4d1e5701-762a-4826-afcd-c7c64e14ccb5	\N	398f8c1c-1d8b-48eb-9aed-08ebb479cff3	6367109c-4684-4a1b-a6b5-9843aa3f6a9d	پیاده‌سازی احراز هویت دومرحله‌ای #80	\N	high	2026-07-04	17fd0d2e-bea8-49db-9e4b-977410c1436d	2026-07-20 11:46:45.199839+00	2026-07-20 11:46:45.199839+00	completed	approved	100	7.80	2026-06-25
6fa5de46-9edd-404a-915e-89d9f3f21ae7	4d1e5701-762a-4826-afcd-c7c64e14ccb5	\N	7c364485-75f2-4d57-81ee-62ec42c62177	6367109c-4684-4a1b-a6b5-9843aa3f6a9d	رفع مشکل کندی بارگذاری صفحه #81	\N	high	2026-07-27	897ba877-3de5-476a-b524-0b78dec7656b	2026-07-20 11:46:45.199839+00	2026-07-20 11:46:45.199839+00	todo	\N	59	17.80	2026-07-12
6fa5de46-9edd-404a-915e-89d9f3f21ae7	4d1e5701-762a-4826-afcd-c7c64e14ccb5	\N	7c364485-75f2-4d57-81ee-62ec42c62177	6367109c-4684-4a1b-a6b5-9843aa3f6a9d	نوشتن مستندات فنی API #82	\N	low	2026-07-30	156a0446-48a0-438b-8371-97c044b40621	2026-07-20 11:46:45.199839+00	2026-07-20 11:46:45.199839+00	in_progress	\N	73	16.50	2026-07-10
6fa5de46-9edd-404a-915e-89d9f3f21ae7	4d1e5701-762a-4826-afcd-c7c64e14ccb5	\N	6367109c-4684-4a1b-a6b5-9843aa3f6a9d	6367109c-4684-4a1b-a6b5-9843aa3f6a9d	بازنویسی ماژول اعلان‌ها #83	\N	medium	2026-07-19	903966b3-a4b3-4b35-9602-ae369fc78145	2026-07-20 11:46:45.199839+00	2026-07-20 11:46:45.199839+00	in_progress	\N	68	30.40	2026-07-05
6fa5de46-9edd-404a-915e-89d9f3f21ae7	4d1e5701-762a-4826-afcd-c7c64e14ccb5	\N	a42bd423-3577-42e0-b239-611eb7480fb9	6367109c-4684-4a1b-a6b5-9843aa3f6a9d	طراحی API نسخهٔ دوم #84	\N	medium	2026-07-26	aa7e499d-78a9-4801-ab15-4ebd32fa7b4c	2026-07-20 11:46:45.199839+00	2026-07-20 11:46:45.199839+00	completed	pending	100	20.50	2026-07-17
6fa5de46-9edd-404a-915e-89d9f3f21ae7	4d1e5701-762a-4826-afcd-c7c64e14ccb5	\N	3051f03b-e73a-49fb-a6d2-ab7406c6850b	6367109c-4684-4a1b-a6b5-9843aa3f6a9d	نوشتن مستندات فنی API #85	\N	low	2026-08-11	d3965c11-7b79-4cb6-b732-2199df57b453	2026-07-20 11:46:45.199839+00	2026-07-20 11:46:45.199839+00	in_progress	\N	59	36.90	2026-07-28
6fa5de46-9edd-404a-915e-89d9f3f21ae7	4d1e5701-762a-4826-afcd-c7c64e14ccb5	\N	a42bd423-3577-42e0-b239-611eb7480fb9	6367109c-4684-4a1b-a6b5-9843aa3f6a9d	پیاده‌سازی صفحهٔ داشبورد مدیریتی #86	\N	high	2026-07-31	4b76762a-881e-4462-a7bc-3272453adee1	2026-07-20 11:46:45.199839+00	2026-07-20 11:46:45.199839+00	completed	approved	100	3.00	2026-07-11
6fa5de46-9edd-404a-915e-89d9f3f21ae7	4d1e5701-762a-4826-afcd-c7c64e14ccb5	\N	fd5161f1-4abf-4cc9-8f06-914566393088	6367109c-4684-4a1b-a6b5-9843aa3f6a9d	بهینه‌سازی کوئری‌های گزارش‌گیری #87	\N	low	2026-07-10	be013270-01ba-4c5c-adf3-d8e6b6654379	2026-07-20 11:46:45.199839+00	2026-07-20 11:46:45.199839+00	in_progress	\N	33	16.40	2026-06-24
6fa5de46-9edd-404a-915e-89d9f3f21ae7	4d1e5701-762a-4826-afcd-c7c64e14ccb5	\N	7c364485-75f2-4d57-81ee-62ec42c62177	6367109c-4684-4a1b-a6b5-9843aa3f6a9d	طراحی API نسخهٔ دوم #88	\N	medium	2026-08-17	ec1da620-276d-4d69-badd-3948c3bee1de	2026-07-20 11:46:45.199839+00	2026-07-20 11:46:45.199839+00	completed	approved	100	11.60	2026-08-03
6fa5de46-9edd-404a-915e-89d9f3f21ae7	4d1e5701-762a-4826-afcd-c7c64e14ccb5	\N	6367109c-4684-4a1b-a6b5-9843aa3f6a9d	6367109c-4684-4a1b-a6b5-9843aa3f6a9d	رفع مشکل کندی بارگذاری صفحه #89	\N	low	2026-07-23	1639a96d-6f30-41b1-8f7c-23d614fb9e1d	2026-07-20 11:46:45.199839+00	2026-07-20 11:46:45.199839+00	completed	approved	100	26.70	2026-07-20
6fa5de46-9edd-404a-915e-89d9f3f21ae7	4d1e5701-762a-4826-afcd-c7c64e14ccb5	\N	a34644cb-4fa6-4ad1-904f-3e26b23679cd	6367109c-4684-4a1b-a6b5-9843aa3f6a9d	افزودن تست واحد برای سرویس کاربران #90	\N	low	2026-06-26	60aa40bf-c203-48d1-92b7-5ee74b85041b	2026-07-20 11:46:45.199839+00	2026-07-20 11:46:45.199839+00	completed	approved	100	25.60	2026-06-17
6fa5de46-9edd-404a-915e-89d9f3f21ae7	\N	\N	7c364485-75f2-4d57-81ee-62ec42c62177	7c364485-75f2-4d57-81ee-62ec42c62177	پیاده‌سازی صفحهٔ داشبورد مدیریتی #91	\N	low	2026-07-21	9439b101-9f95-473a-bc36-188932a71483	2026-07-20 11:46:45.199839+00	2026-07-20 11:46:45.199839+00	todo	\N	59	28.60	2026-07-16
6fa5de46-9edd-404a-915e-89d9f3f21ae7	\N	\N	a34644cb-4fa6-4ad1-904f-3e26b23679cd	a34644cb-4fa6-4ad1-904f-3e26b23679cd	پیاده‌سازی صفحهٔ داشبورد مدیریتی #92	\N	high	2026-07-17	c69cc453-5588-4e44-9c89-463498234c1c	2026-07-20 11:46:45.199839+00	2026-07-20 11:46:45.199839+00	in_progress	\N	14	31.60	2026-06-26
6fa5de46-9edd-404a-915e-89d9f3f21ae7	\N	\N	7c364485-75f2-4d57-81ee-62ec42c62177	7c364485-75f2-4d57-81ee-62ec42c62177	رفع باگ در ماژول پرداخت #93	\N	medium	2026-07-12	e7232dd1-78bf-4723-ac57-d3f7008289f1	2026-07-20 11:46:45.199839+00	2026-07-20 11:46:45.199839+00	in_progress	\N	73	27.70	2026-06-22
6fa5de46-9edd-404a-915e-89d9f3f21ae7	\N	\N	3051f03b-e73a-49fb-a6d2-ab7406c6850b	3051f03b-e73a-49fb-a6d2-ab7406c6850b	پیاده‌سازی صفحهٔ ورود جدید #94	\N	high	2026-08-23	c211fdc2-48f5-4fd8-bf90-cb3be185efdb	2026-07-20 11:46:45.199839+00	2026-07-20 11:46:45.199839+00	in_progress	\N	80	11.20	2026-08-15
6fa5de46-9edd-404a-915e-89d9f3f21ae7	\N	\N	fd5161f1-4abf-4cc9-8f06-914566393088	fd5161f1-4abf-4cc9-8f06-914566393088	رفع مشکل ناسازگاری مرورگر #95	\N	low	2026-07-26	f5640209-74c5-4815-9d05-113b3c86f7a8	2026-07-20 11:46:45.199839+00	2026-07-20 11:46:45.199839+00	archived	\N	72	31.70	2026-07-05
6fa5de46-9edd-404a-915e-89d9f3f21ae7	\N	\N	398f8c1c-1d8b-48eb-9aed-08ebb479cff3	398f8c1c-1d8b-48eb-9aed-08ebb479cff3	به‌روزرسانی کتابخانه‌های وابسته #96	\N	high	2026-07-13	279eb63e-f5c2-46bf-92d9-aa876361a61a	2026-07-20 11:46:45.199839+00	2026-07-20 11:46:45.199839+00	completed	approved	100	15.00	2026-07-09
6fa5de46-9edd-404a-915e-89d9f3f21ae7	\N	\N	a34644cb-4fa6-4ad1-904f-3e26b23679cd	a34644cb-4fa6-4ad1-904f-3e26b23679cd	پیاده‌سازی صفحهٔ ورود جدید #97	\N	medium	2026-08-24	8ec02445-7355-49ab-b911-35cb8c4ea078	2026-07-20 11:46:45.199839+00	2026-07-20 11:46:45.199839+00	in_progress	\N	46	26.20	2026-08-07
6fa5de46-9edd-404a-915e-89d9f3f21ae7	\N	\N	a34644cb-4fa6-4ad1-904f-3e26b23679cd	a34644cb-4fa6-4ad1-904f-3e26b23679cd	نوشتن مستندات فنی API #98	\N	high	2026-07-20	7b4304d6-b830-473c-ad71-3aecec27ef3f	2026-07-20 11:46:45.199839+00	2026-07-20 11:46:45.199839+00	completed	pending	100	38.70	2026-07-13
6fa5de46-9edd-404a-915e-89d9f3f21ae7	\N	\N	398f8c1c-1d8b-48eb-9aed-08ebb479cff3	398f8c1c-1d8b-48eb-9aed-08ebb479cff3	بررسی و رفع آسیب‌پذیری امنیتی #99	\N	medium	2026-08-06	4256e0f2-8fc0-4354-8cbb-a703616e6fdb	2026-07-20 11:46:45.199839+00	2026-07-20 11:46:45.199839+00	completed	pending	100	33.40	2026-07-20
6fa5de46-9edd-404a-915e-89d9f3f21ae7	\N	\N	a42bd423-3577-42e0-b239-611eb7480fb9	a42bd423-3577-42e0-b239-611eb7480fb9	بازنویسی ماژول اعلان‌ها #100	\N	low	2026-07-15	f9f52157-5706-42e8-ba84-94fb0b5cbc46	2026-07-20 11:46:45.199839+00	2026-07-20 11:46:45.199839+00	in_progress	\N	35	35.50	2026-07-06
6fa5de46-9edd-404a-915e-89d9f3f21ae7	\N	\N	7c364485-75f2-4d57-81ee-62ec42c62177	7c364485-75f2-4d57-81ee-62ec42c62177	پیاده‌سازی صفحهٔ داشبورد مدیریتی #101	\N	high	2026-08-04	ae097835-15a0-4a7f-813b-c223078b8148	2026-07-20 11:46:45.199839+00	2026-07-20 11:46:45.199839+00	archived	\N	48	14.80	2026-07-15
6fa5de46-9edd-404a-915e-89d9f3f21ae7	\N	\N	3051f03b-e73a-49fb-a6d2-ab7406c6850b	3051f03b-e73a-49fb-a6d2-ab7406c6850b	افزودن تست واحد برای سرویس کاربران #102	\N	medium	2026-07-14	3a03cbf3-fc3c-4a97-acaa-d8c84104bbc3	2026-07-20 11:46:45.199839+00	2026-07-20 11:46:45.199839+00	in_progress	\N	33	14.90	2026-06-27
6fa5de46-9edd-404a-915e-89d9f3f21ae7	\N	\N	a42bd423-3577-42e0-b239-611eb7480fb9	a42bd423-3577-42e0-b239-611eb7480fb9	به‌روزرسانی کتابخانه‌های وابسته #103	\N	low	2026-07-23	64de961b-59bf-4162-86d1-b405db905e09	2026-07-20 11:46:45.199839+00	2026-07-20 11:46:45.199839+00	completed	pending	100	5.30	2026-07-21
6fa5de46-9edd-404a-915e-89d9f3f21ae7	\N	\N	fd5161f1-4abf-4cc9-8f06-914566393088	fd5161f1-4abf-4cc9-8f06-914566393088	رفع مشکل ناسازگاری مرورگر #104	\N	low	2026-08-05	bd2cd141-e749-4b6a-98d6-dfd1319beef1	2026-07-20 11:46:45.199839+00	2026-07-20 11:46:45.199839+00	in_progress	\N	60	26.50	2026-07-17
6fa5de46-9edd-404a-915e-89d9f3f21ae7	\N	\N	3051f03b-e73a-49fb-a6d2-ab7406c6850b	3051f03b-e73a-49fb-a6d2-ab7406c6850b	افزودن تست واحد برای سرویس کاربران #105	\N	medium	2026-07-02	432c4aeb-3987-47e0-a01f-bef4f8810818	2026-07-20 11:46:45.199839+00	2026-07-20 11:46:45.199839+00	completed	pending	100	28.30	2026-06-21
6fa5de46-9edd-404a-915e-89d9f3f21ae7	abe514ef-e3c3-4d74-859b-cb25c77c879d	\N	56ee4c58-1504-48a5-b37d-7d040bb2bd16	6f0889c3-21cf-4af8-92e8-834e06a4a09c	پیگیری مطالبات معوق مشتریان #1	\N	medium	2026-07-16	6936dbee-7827-4efd-aee9-d7629e484549	2026-07-20 11:46:45.199839+00	2026-07-20 11:46:45.199839+00	completed	rejected	100	5.90	2026-06-27
6fa5de46-9edd-404a-915e-89d9f3f21ae7	abe514ef-e3c3-4d74-859b-cb25c77c879d	\N	eeebc2e6-a734-4f02-8d65-173ba01323d3	6f0889c3-21cf-4af8-92e8-834e06a4a09c	تهیهٔ گزارش جریان نقدی #2	\N	medium	2026-08-04	37811384-4506-46ba-b7d6-fd22faef27e0	2026-07-20 11:46:45.199839+00	2026-07-20 11:46:45.199839+00	completed	approved	100	8.30	2026-07-14
6fa5de46-9edd-404a-915e-89d9f3f21ae7	abe514ef-e3c3-4d74-859b-cb25c77c879d	\N	56ee4c58-1504-48a5-b37d-7d040bb2bd16	6f0889c3-21cf-4af8-92e8-834e06a4a09c	تهیهٔ گزارش جریان نقدی #3	\N	medium	2026-07-17	680ad17e-0f48-4f85-b84b-f55076da0101	2026-07-20 11:46:45.199839+00	2026-07-20 11:46:45.199839+00	in_progress	\N	78	39.90	2026-07-14
6fa5de46-9edd-404a-915e-89d9f3f21ae7	abe514ef-e3c3-4d74-859b-cb25c77c879d	\N	eeebc2e6-a734-4f02-8d65-173ba01323d3	6f0889c3-21cf-4af8-92e8-834e06a4a09c	تهیهٔ گزارش سود و زیان ماهانه #4	\N	high	2026-08-18	0f6f5d1e-dad5-472d-ab4d-083a537ae985	2026-07-20 11:46:45.199839+00	2026-07-20 11:46:45.199839+00	completed	rejected	100	26.20	2026-08-15
6fa5de46-9edd-404a-915e-89d9f3f21ae7	abe514ef-e3c3-4d74-859b-cb25c77c879d	\N	eeebc2e6-a734-4f02-8d65-173ba01323d3	6f0889c3-21cf-4af8-92e8-834e06a4a09c	بررسی و تأیید صورت‌حساب‌های خرید #5	\N	low	2026-08-05	eb3394e8-cd27-4963-a3c5-3c8ec8260541	2026-07-20 11:46:45.199839+00	2026-07-20 11:46:45.199839+00	completed	pending	100	34.20	2026-07-29
6fa5de46-9edd-404a-915e-89d9f3f21ae7	abe514ef-e3c3-4d74-859b-cb25c77c879d	\N	ca92a9d5-cf4a-4b8b-9fe5-6fadd5c44ca2	6f0889c3-21cf-4af8-92e8-834e06a4a09c	بررسی و تسویهٔ کارت اعتباری شرکت #6	\N	high	2026-06-29	566aeb3c-816f-4ea9-acfa-12c59c919b83	2026-07-20 11:46:45.199839+00	2026-07-20 11:46:45.199839+00	completed	approved	100	15.90	2026-06-20
6fa5de46-9edd-404a-915e-89d9f3f21ae7	abe514ef-e3c3-4d74-859b-cb25c77c879d	\N	56ee4c58-1504-48a5-b37d-7d040bb2bd16	6f0889c3-21cf-4af8-92e8-834e06a4a09c	تهیهٔ گزارش مالیاتی فصلی #7	\N	medium	2026-07-11	66c624bd-1b9f-4b95-8fe8-841c426b3555	2026-07-20 11:46:45.199839+00	2026-07-20 11:46:45.199839+00	completed	approved	100	18.90	2026-06-25
6fa5de46-9edd-404a-915e-89d9f3f21ae7	abe514ef-e3c3-4d74-859b-cb25c77c879d	\N	6f0889c3-21cf-4af8-92e8-834e06a4a09c	6f0889c3-21cf-4af8-92e8-834e06a4a09c	تهیهٔ گزارش مالیاتی فصلی #8	\N	high	2026-07-23	995017e1-c3e9-4df9-b4dc-0db4625b2975	2026-07-20 11:46:45.199839+00	2026-07-20 11:46:45.199839+00	completed	approved	100	12.60	2026-07-09
6fa5de46-9edd-404a-915e-89d9f3f21ae7	abe514ef-e3c3-4d74-859b-cb25c77c879d	\N	6f0889c3-21cf-4af8-92e8-834e06a4a09c	6f0889c3-21cf-4af8-92e8-834e06a4a09c	به‌روزرسانی جدول حقوق و دستمزد #9	\N	high	2026-08-09	4e08fe4f-39e3-4b5a-b747-92b598e32fde	2026-07-20 11:46:45.199839+00	2026-07-20 11:46:45.199839+00	todo	\N	49	36.70	2026-08-02
6fa5de46-9edd-404a-915e-89d9f3f21ae7	abe514ef-e3c3-4d74-859b-cb25c77c879d	\N	6f0889c3-21cf-4af8-92e8-834e06a4a09c	6f0889c3-21cf-4af8-92e8-834e06a4a09c	تهیهٔ گزارش جریان نقدی #10	\N	medium	2026-08-14	46f41b87-47fd-4311-9a10-07d024230cd8	2026-07-20 11:46:45.199839+00	2026-07-20 11:46:45.199839+00	in_progress	\N	27	39.90	2026-08-04
6fa5de46-9edd-404a-915e-89d9f3f21ae7	abe514ef-e3c3-4d74-859b-cb25c77c879d	\N	eeebc2e6-a734-4f02-8d65-173ba01323d3	6f0889c3-21cf-4af8-92e8-834e06a4a09c	تهیهٔ گزارش سود و زیان ماهانه #11	\N	low	2026-07-25	190e7424-585e-4e91-a2a1-d657b07c0f19	2026-07-20 11:46:45.199839+00	2026-07-20 11:46:45.199839+00	completed	rejected	100	34.40	2026-07-17
6fa5de46-9edd-404a-915e-89d9f3f21ae7	abe514ef-e3c3-4d74-859b-cb25c77c879d	\N	56ee4c58-1504-48a5-b37d-7d040bb2bd16	6f0889c3-21cf-4af8-92e8-834e06a4a09c	تهیهٔ گزارش سود و زیان ماهانه #12	\N	high	2026-08-28	14df6fab-ddd6-4828-b6ed-4a64b898b529	2026-07-20 11:46:45.199839+00	2026-07-20 11:46:45.199839+00	todo	\N	40	27.40	2026-08-12
6fa5de46-9edd-404a-915e-89d9f3f21ae7	abe514ef-e3c3-4d74-859b-cb25c77c879d	\N	ca92a9d5-cf4a-4b8b-9fe5-6fadd5c44ca2	6f0889c3-21cf-4af8-92e8-834e06a4a09c	پیگیری مطالبات معوق مشتریان #13	\N	medium	2026-08-09	025db656-ca2a-4f4f-bce4-43c054d90bb9	2026-07-20 11:46:45.199839+00	2026-07-20 11:46:45.199839+00	todo	\N	20	29.00	2026-07-21
6fa5de46-9edd-404a-915e-89d9f3f21ae7	abe514ef-e3c3-4d74-859b-cb25c77c879d	\N	ca92a9d5-cf4a-4b8b-9fe5-6fadd5c44ca2	6f0889c3-21cf-4af8-92e8-834e06a4a09c	ثبت اسناد حسابداری هفتگی #14	\N	low	2026-07-27	95957ef8-e0e3-4f8d-b4e3-9909ad077929	2026-07-20 11:46:45.199839+00	2026-07-20 11:46:45.199839+00	completed	approved	100	39.40	2026-07-09
6fa5de46-9edd-404a-915e-89d9f3f21ae7	abe514ef-e3c3-4d74-859b-cb25c77c879d	\N	c28803c6-5155-4136-94b4-4f91ec6ee698	6f0889c3-21cf-4af8-92e8-834e06a4a09c	بررسی و تأیید صورت‌حساب‌های خرید #15	\N	medium	2026-07-18	f9e90499-ae1f-4133-a251-d63c07086acf	2026-07-20 11:46:45.199839+00	2026-07-20 11:46:45.199839+00	todo	\N	70	23.70	2026-07-01
6fa5de46-9edd-404a-915e-89d9f3f21ae7	abe514ef-e3c3-4d74-859b-cb25c77c879d	\N	56ee4c58-1504-48a5-b37d-7d040bb2bd16	6f0889c3-21cf-4af8-92e8-834e06a4a09c	تهیهٔ گزارش سود و زیان ماهانه #16	\N	medium	2026-08-15	0f5cb204-6b80-4a1a-982a-32579c78683e	2026-07-20 11:46:45.199839+00	2026-07-20 11:46:45.199839+00	completed	approved	100	17.10	2026-08-11
6fa5de46-9edd-404a-915e-89d9f3f21ae7	abe514ef-e3c3-4d74-859b-cb25c77c879d	\N	ca92a9d5-cf4a-4b8b-9fe5-6fadd5c44ca2	6f0889c3-21cf-4af8-92e8-834e06a4a09c	بررسی فاکتورهای فروش صادرشده #17	\N	medium	2026-08-03	20cc3706-fdc2-4841-a886-40388acfd567	2026-07-20 11:46:45.199839+00	2026-07-20 11:46:45.199839+00	archived	\N	73	4.80	2026-07-16
6fa5de46-9edd-404a-915e-89d9f3f21ae7	abe514ef-e3c3-4d74-859b-cb25c77c879d	\N	eeebc2e6-a734-4f02-8d65-173ba01323d3	6f0889c3-21cf-4af8-92e8-834e06a4a09c	تهیهٔ گزارش مالیاتی فصلی #18	\N	low	2026-08-02	7cd602f5-ed0a-4789-81c5-9a45d9b91187	2026-07-20 11:46:45.199839+00	2026-07-20 11:46:45.199839+00	completed	approved	100	35.40	2026-07-15
6fa5de46-9edd-404a-915e-89d9f3f21ae7	ad7056fc-1499-4430-8506-dc250e383b19	\N	c28803c6-5155-4136-94b4-4f91ec6ee698	6f0889c3-21cf-4af8-92e8-834e06a4a09c	بررسی فاکتورهای فروش صادرشده #19	\N	high	2026-07-03	7bb78b43-0b5f-488b-b05c-7b0930ffa3fc	2026-07-20 11:46:45.199839+00	2026-07-20 11:46:45.199839+00	completed	pending	100	36.60	2026-06-27
6fa5de46-9edd-404a-915e-89d9f3f21ae7	ad7056fc-1499-4430-8506-dc250e383b19	\N	6f0889c3-21cf-4af8-92e8-834e06a4a09c	6f0889c3-21cf-4af8-92e8-834e06a4a09c	پیگیری مطالبات معوق مشتریان #20	\N	low	2026-07-25	e31d8ce6-fc1a-4775-adb9-980b544c563e	2026-07-20 11:46:45.199839+00	2026-07-20 11:46:45.199839+00	todo	\N	20	14.30	2026-07-19
6fa5de46-9edd-404a-915e-89d9f3f21ae7	ad7056fc-1499-4430-8506-dc250e383b19	\N	ca92a9d5-cf4a-4b8b-9fe5-6fadd5c44ca2	6f0889c3-21cf-4af8-92e8-834e06a4a09c	بررسی قراردادهای مالی جدید #21	\N	medium	2026-07-26	33dfea5d-b48a-45f0-b28b-c621230bd50f	2026-07-20 11:46:45.199839+00	2026-07-20 11:46:45.199839+00	in_progress	\N	10	11.50	2026-07-08
6fa5de46-9edd-404a-915e-89d9f3f21ae7	ad7056fc-1499-4430-8506-dc250e383b19	\N	ca92a9d5-cf4a-4b8b-9fe5-6fadd5c44ca2	6f0889c3-21cf-4af8-92e8-834e06a4a09c	بررسی صورت وضعیت پیمانکاران #22	\N	high	2026-08-06	b7f31b43-deac-4dae-9104-2ff3f33915ca	2026-07-20 11:46:45.199839+00	2026-07-20 11:46:45.199839+00	completed	approved	100	5.60	2026-07-26
6fa5de46-9edd-404a-915e-89d9f3f21ae7	ad7056fc-1499-4430-8506-dc250e383b19	\N	ca92a9d5-cf4a-4b8b-9fe5-6fadd5c44ca2	6f0889c3-21cf-4af8-92e8-834e06a4a09c	مغایرت‌گیری حساب‌های بانکی #23	\N	low	2026-08-12	40798a64-f260-42d4-886c-c4aec658d8d2	2026-07-20 11:46:45.199839+00	2026-07-20 11:46:45.199839+00	todo	\N	79	29.40	2026-07-23
6fa5de46-9edd-404a-915e-89d9f3f21ae7	ad7056fc-1499-4430-8506-dc250e383b19	\N	3cba84f1-51a4-4831-ac2b-61b820a1122a	6f0889c3-21cf-4af8-92e8-834e06a4a09c	بررسی و تأیید صورت‌حساب‌های خرید #24	\N	low	2026-08-28	a37f5732-0696-4f0d-b603-e26cd93f3688	2026-07-20 11:46:45.199839+00	2026-07-20 11:46:45.199839+00	in_progress	\N	10	3.70	2026-08-08
6fa5de46-9edd-404a-915e-89d9f3f21ae7	ad7056fc-1499-4430-8506-dc250e383b19	\N	ca92a9d5-cf4a-4b8b-9fe5-6fadd5c44ca2	6f0889c3-21cf-4af8-92e8-834e06a4a09c	تطبیق موجودی انبار با حساب‌ها #25	\N	low	2026-08-01	d32a4eca-60fa-4c01-93ff-13abe1005dcb	2026-07-20 11:46:45.199839+00	2026-07-20 11:46:45.199839+00	archived	\N	73	17.80	2026-07-22
6fa5de46-9edd-404a-915e-89d9f3f21ae7	ad7056fc-1499-4430-8506-dc250e383b19	\N	ca92a9d5-cf4a-4b8b-9fe5-6fadd5c44ca2	6f0889c3-21cf-4af8-92e8-834e06a4a09c	پیگیری مطالبات معوق مشتریان #26	\N	high	2026-08-05	36def23d-4540-47ce-9142-79c8bc51bd7b	2026-07-20 11:46:45.199839+00	2026-07-20 11:46:45.199839+00	todo	\N	38	20.40	2026-07-17
6fa5de46-9edd-404a-915e-89d9f3f21ae7	ad7056fc-1499-4430-8506-dc250e383b19	\N	c28803c6-5155-4136-94b4-4f91ec6ee698	6f0889c3-21cf-4af8-92e8-834e06a4a09c	تهیهٔ گزارش جریان نقدی #27	\N	low	2026-07-19	46e98616-fcd9-49e0-a8e5-cd0505debd0b	2026-07-20 11:46:45.199839+00	2026-07-20 11:46:45.199839+00	completed	approved	100	8.00	2026-07-15
6fa5de46-9edd-404a-915e-89d9f3f21ae7	ad7056fc-1499-4430-8506-dc250e383b19	\N	56ee4c58-1504-48a5-b37d-7d040bb2bd16	6f0889c3-21cf-4af8-92e8-834e06a4a09c	مغایرت‌گیری حساب‌های بانکی #28	\N	medium	2026-07-28	d18e6ec9-2009-41e5-956a-25cf555f07eb	2026-07-20 11:46:45.199839+00	2026-07-20 11:46:45.199839+00	completed	approved	100	34.70	2026-07-07
6fa5de46-9edd-404a-915e-89d9f3f21ae7	ad7056fc-1499-4430-8506-dc250e383b19	\N	eeebc2e6-a734-4f02-8d65-173ba01323d3	6f0889c3-21cf-4af8-92e8-834e06a4a09c	بررسی فاکتورهای فروش صادرشده #29	\N	low	2026-08-23	d110d70f-a267-4df9-b72c-356f496e52b5	2026-07-20 11:46:45.199839+00	2026-07-20 11:46:45.199839+00	archived	\N	47	21.60	2026-08-10
6fa5de46-9edd-404a-915e-89d9f3f21ae7	ad7056fc-1499-4430-8506-dc250e383b19	\N	6f0889c3-21cf-4af8-92e8-834e06a4a09c	6f0889c3-21cf-4af8-92e8-834e06a4a09c	تهیهٔ گزارش سود و زیان ماهانه #30	\N	medium	2026-07-17	8a54f6c7-15a2-4f49-869d-374382cdc607	2026-07-20 11:46:45.199839+00	2026-07-20 11:46:45.199839+00	in_progress	\N	57	11.40	2026-07-01
6fa5de46-9edd-404a-915e-89d9f3f21ae7	ad7056fc-1499-4430-8506-dc250e383b19	\N	6f0889c3-21cf-4af8-92e8-834e06a4a09c	6f0889c3-21cf-4af8-92e8-834e06a4a09c	پیگیری بیمهٔ کارکنان #31	\N	high	2026-07-18	c4db833f-6e02-4a37-b415-99febd0f2e5f	2026-07-20 11:46:45.199839+00	2026-07-20 11:46:45.199839+00	todo	\N	53	11.40	2026-07-04
6fa5de46-9edd-404a-915e-89d9f3f21ae7	ad7056fc-1499-4430-8506-dc250e383b19	\N	c28803c6-5155-4136-94b4-4f91ec6ee698	6f0889c3-21cf-4af8-92e8-834e06a4a09c	بررسی قراردادهای مالی جدید #32	\N	high	2026-08-19	dccedce6-d35f-449b-ab87-507e75da061e	2026-07-20 11:46:45.199839+00	2026-07-20 11:46:45.199839+00	todo	\N	40	9.20	2026-08-07
6fa5de46-9edd-404a-915e-89d9f3f21ae7	ad7056fc-1499-4430-8506-dc250e383b19	\N	9255642c-40dc-467b-8897-f23fd07f2394	6f0889c3-21cf-4af8-92e8-834e06a4a09c	بررسی قراردادهای مالی جدید #33	\N	medium	2026-08-01	7dc26ec8-b454-4d4b-94bf-5cbee79ea22b	2026-07-20 11:46:45.199839+00	2026-07-20 11:46:45.199839+00	completed	rejected	100	20.90	2026-07-15
6fa5de46-9edd-404a-915e-89d9f3f21ae7	ad7056fc-1499-4430-8506-dc250e383b19	\N	6f0889c3-21cf-4af8-92e8-834e06a4a09c	6f0889c3-21cf-4af8-92e8-834e06a4a09c	ثبت اسناد حسابداری هفتگی #34	\N	low	2026-08-03	f2dfd45a-e150-4e88-9b9a-fa581f81e864	2026-07-20 11:46:45.199839+00	2026-07-20 11:46:45.199839+00	in_progress	\N	74	15.40	2026-07-18
6fa5de46-9edd-404a-915e-89d9f3f21ae7	ad7056fc-1499-4430-8506-dc250e383b19	\N	6f0889c3-21cf-4af8-92e8-834e06a4a09c	6f0889c3-21cf-4af8-92e8-834e06a4a09c	بررسی قراردادهای مالی جدید #35	\N	high	2026-08-07	b2926a65-3c28-4155-a0f9-fbc0d411c93a	2026-07-20 11:46:45.199839+00	2026-07-20 11:46:45.199839+00	in_progress	\N	60	12.90	2026-07-17
6fa5de46-9edd-404a-915e-89d9f3f21ae7	ad7056fc-1499-4430-8506-dc250e383b19	\N	6f0889c3-21cf-4af8-92e8-834e06a4a09c	6f0889c3-21cf-4af8-92e8-834e06a4a09c	بررسی قراردادهای مالی جدید #36	\N	medium	2026-07-19	cd88c3cd-31bf-46de-8cad-626fae75a7d6	2026-07-20 11:46:45.199839+00	2026-07-20 11:46:45.199839+00	todo	\N	46	31.00	2026-07-13
6fa5de46-9edd-404a-915e-89d9f3f21ae7	a38f3ca8-458d-4d9a-8c39-fd18807ebffc	\N	eeebc2e6-a734-4f02-8d65-173ba01323d3	6f0889c3-21cf-4af8-92e8-834e06a4a09c	بررسی صورت وضعیت پیمانکاران #37	\N	high	2026-07-14	2faff8d5-393d-40b7-b6af-8cd1139b57c8	2026-07-20 11:46:45.199839+00	2026-07-20 11:46:45.199839+00	todo	\N	24	15.80	2026-07-11
6fa5de46-9edd-404a-915e-89d9f3f21ae7	a38f3ca8-458d-4d9a-8c39-fd18807ebffc	\N	eeebc2e6-a734-4f02-8d65-173ba01323d3	6f0889c3-21cf-4af8-92e8-834e06a4a09c	به‌روزرسانی جدول حقوق و دستمزد #38	\N	high	2026-07-28	a798c544-f7db-4ad7-ab54-b205d6d59ec0	2026-07-20 11:46:45.199839+00	2026-07-20 11:46:45.199839+00	todo	\N	35	33.40	2026-07-10
6fa5de46-9edd-404a-915e-89d9f3f21ae7	a38f3ca8-458d-4d9a-8c39-fd18807ebffc	\N	3cba84f1-51a4-4831-ac2b-61b820a1122a	6f0889c3-21cf-4af8-92e8-834e06a4a09c	بررسی فاکتورهای فروش صادرشده #39	\N	medium	2026-06-29	ec2f4901-dfc4-4422-b699-df52142bd228	2026-07-20 11:46:45.199839+00	2026-07-20 11:46:45.199839+00	completed	pending	100	32.20	2026-06-24
6fa5de46-9edd-404a-915e-89d9f3f21ae7	a38f3ca8-458d-4d9a-8c39-fd18807ebffc	\N	eeebc2e6-a734-4f02-8d65-173ba01323d3	6f0889c3-21cf-4af8-92e8-834e06a4a09c	ثبت اسناد حسابداری هفتگی #40	\N	high	2026-08-09	0c14f52f-0056-4a5d-b696-7c9e31e5d9cf	2026-07-20 11:46:45.199839+00	2026-07-20 11:46:45.199839+00	completed	rejected	100	21.30	2026-08-03
6fa5de46-9edd-404a-915e-89d9f3f21ae7	a38f3ca8-458d-4d9a-8c39-fd18807ebffc	\N	3cba84f1-51a4-4831-ac2b-61b820a1122a	6f0889c3-21cf-4af8-92e8-834e06a4a09c	مغایرت‌گیری حساب‌های بانکی #41	\N	high	2026-06-21	5025a162-2989-467b-9ea8-05563582b12c	2026-07-20 11:46:45.199839+00	2026-07-20 11:46:45.199839+00	todo	\N	42	32.60	2026-06-18
6fa5de46-9edd-404a-915e-89d9f3f21ae7	a38f3ca8-458d-4d9a-8c39-fd18807ebffc	\N	3cba84f1-51a4-4831-ac2b-61b820a1122a	6f0889c3-21cf-4af8-92e8-834e06a4a09c	مغایرت‌گیری حساب‌های بانکی #42	\N	medium	2026-08-30	324e8bab-ef77-4c60-a317-8d4d2d3ed147	2026-07-20 11:46:45.199839+00	2026-07-20 11:46:45.199839+00	completed	approved	100	37.40	2026-08-12
6fa5de46-9edd-404a-915e-89d9f3f21ae7	a38f3ca8-458d-4d9a-8c39-fd18807ebffc	\N	eeebc2e6-a734-4f02-8d65-173ba01323d3	6f0889c3-21cf-4af8-92e8-834e06a4a09c	تهیهٔ گزارش جریان نقدی #43	\N	medium	2026-08-01	71e1dfd1-6f70-43d2-b55d-40a76e2ed4eb	2026-07-20 11:46:45.199839+00	2026-07-20 11:46:45.199839+00	todo	\N	75	14.80	2026-07-11
6fa5de46-9edd-404a-915e-89d9f3f21ae7	a38f3ca8-458d-4d9a-8c39-fd18807ebffc	\N	c28803c6-5155-4136-94b4-4f91ec6ee698	6f0889c3-21cf-4af8-92e8-834e06a4a09c	پیگیری مطالبات معوق مشتریان #44	\N	medium	2026-08-20	753f4042-a371-4370-99a6-9567d5083ad5	2026-07-20 11:46:45.199839+00	2026-07-20 11:46:45.199839+00	completed	approved	100	33.00	2026-07-31
6fa5de46-9edd-404a-915e-89d9f3f21ae7	a38f3ca8-458d-4d9a-8c39-fd18807ebffc	\N	eeebc2e6-a734-4f02-8d65-173ba01323d3	6f0889c3-21cf-4af8-92e8-834e06a4a09c	بررسی فاکتورهای فروش صادرشده #45	\N	high	2026-08-03	29ecdd0a-4db0-49ff-a3b3-d9fc0f8976b3	2026-07-20 11:46:45.199839+00	2026-07-20 11:46:45.199839+00	in_progress	\N	39	32.30	2026-07-29
6fa5de46-9edd-404a-915e-89d9f3f21ae7	a38f3ca8-458d-4d9a-8c39-fd18807ebffc	\N	ca92a9d5-cf4a-4b8b-9fe5-6fadd5c44ca2	6f0889c3-21cf-4af8-92e8-834e06a4a09c	پیگیری مطالبات معوق مشتریان #46	\N	high	2026-08-10	41c28438-84b5-424e-a22a-1b1b4460fe51	2026-07-20 11:46:45.199839+00	2026-07-20 11:46:45.199839+00	completed	pending	100	31.80	2026-07-24
6fa5de46-9edd-404a-915e-89d9f3f21ae7	a38f3ca8-458d-4d9a-8c39-fd18807ebffc	\N	c28803c6-5155-4136-94b4-4f91ec6ee698	6f0889c3-21cf-4af8-92e8-834e06a4a09c	بررسی صورت وضعیت پیمانکاران #47	\N	medium	2026-08-04	0b3d8ba4-20ac-46ff-9d74-64ab23acf432	2026-07-20 11:46:45.199839+00	2026-07-20 11:46:45.199839+00	completed	approved	100	8.50	2026-08-01
6fa5de46-9edd-404a-915e-89d9f3f21ae7	a38f3ca8-458d-4d9a-8c39-fd18807ebffc	\N	ca92a9d5-cf4a-4b8b-9fe5-6fadd5c44ca2	6f0889c3-21cf-4af8-92e8-834e06a4a09c	مغایرت‌گیری حساب‌های بانکی #48	\N	high	2026-08-08	9d83b59c-7c0d-4d11-9e98-122c9c203f67	2026-07-20 11:46:45.199839+00	2026-07-20 11:46:45.199839+00	archived	\N	31	3.20	2026-07-25
6fa5de46-9edd-404a-915e-89d9f3f21ae7	a38f3ca8-458d-4d9a-8c39-fd18807ebffc	\N	ca92a9d5-cf4a-4b8b-9fe5-6fadd5c44ca2	6f0889c3-21cf-4af8-92e8-834e06a4a09c	به‌روزرسانی جدول حقوق و دستمزد #49	\N	medium	2026-06-30	a9658a0d-c146-45e2-b290-d8cdb50704e8	2026-07-20 11:46:45.199839+00	2026-07-20 11:46:45.199839+00	todo	\N	53	7.80	2026-06-28
6fa5de46-9edd-404a-915e-89d9f3f21ae7	a38f3ca8-458d-4d9a-8c39-fd18807ebffc	\N	ca92a9d5-cf4a-4b8b-9fe5-6fadd5c44ca2	6f0889c3-21cf-4af8-92e8-834e06a4a09c	بررسی و تسویهٔ کارت اعتباری شرکت #50	\N	high	2026-07-30	a03c2123-6df0-4c97-badd-d22f4d9ebf73	2026-07-20 11:46:45.199839+00	2026-07-20 11:46:45.199839+00	in_progress	\N	60	35.20	2026-07-12
6fa5de46-9edd-404a-915e-89d9f3f21ae7	a38f3ca8-458d-4d9a-8c39-fd18807ebffc	\N	ca92a9d5-cf4a-4b8b-9fe5-6fadd5c44ca2	6f0889c3-21cf-4af8-92e8-834e06a4a09c	تهیهٔ پیش‌نویس بودجهٔ واحد #51	\N	low	2026-06-25	381e15f6-f1fd-4f96-9bfc-4111a27b6c75	2026-07-20 11:46:45.199839+00	2026-07-20 11:46:45.199839+00	archived	\N	71	14.40	2026-06-19
6fa5de46-9edd-404a-915e-89d9f3f21ae7	a38f3ca8-458d-4d9a-8c39-fd18807ebffc	\N	ca92a9d5-cf4a-4b8b-9fe5-6fadd5c44ca2	6f0889c3-21cf-4af8-92e8-834e06a4a09c	به‌روزرسانی جدول حقوق و دستمزد #52	\N	high	2026-07-13	52e5beff-394e-49c7-a71f-c6772d99bb99	2026-07-20 11:46:45.199839+00	2026-07-20 11:46:45.199839+00	completed	approved	100	15.00	2026-07-06
6fa5de46-9edd-404a-915e-89d9f3f21ae7	a38f3ca8-458d-4d9a-8c39-fd18807ebffc	\N	eeebc2e6-a734-4f02-8d65-173ba01323d3	6f0889c3-21cf-4af8-92e8-834e06a4a09c	بررسی صورت وضعیت پیمانکاران #53	\N	medium	2026-08-11	8c4ad87f-5651-4e69-a592-f5d3d5b4261b	2026-07-20 11:46:45.199839+00	2026-07-20 11:46:45.199839+00	completed	pending	100	9.30	2026-08-01
6fa5de46-9edd-404a-915e-89d9f3f21ae7	a38f3ca8-458d-4d9a-8c39-fd18807ebffc	\N	9255642c-40dc-467b-8897-f23fd07f2394	6f0889c3-21cf-4af8-92e8-834e06a4a09c	ثبت اسناد حسابداری هفتگی #54	\N	medium	2026-08-01	dc4689f4-6d61-45c1-8328-3183e938b742	2026-07-20 11:46:45.199839+00	2026-07-20 11:46:45.199839+00	in_progress	\N	36	28.80	2026-07-21
6fa5de46-9edd-404a-915e-89d9f3f21ae7	e6e0814d-c93d-4ff2-ac03-0f95e574998a	\N	ca92a9d5-cf4a-4b8b-9fe5-6fadd5c44ca2	6f0889c3-21cf-4af8-92e8-834e06a4a09c	به‌روزرسانی جدول حقوق و دستمزد #55	\N	medium	2026-07-29	d0c80c2b-f647-48b7-a8fe-4844a118af16	2026-07-20 11:46:45.199839+00	2026-07-20 11:46:45.199839+00	archived	\N	71	37.50	2026-07-17
6fa5de46-9edd-404a-915e-89d9f3f21ae7	e6e0814d-c93d-4ff2-ac03-0f95e574998a	\N	c28803c6-5155-4136-94b4-4f91ec6ee698	6f0889c3-21cf-4af8-92e8-834e06a4a09c	تهیهٔ گزارش سود و زیان ماهانه #56	\N	high	2026-07-14	c0443e96-764d-4b26-b347-f193869ca757	2026-07-20 11:46:45.199839+00	2026-07-20 11:46:45.199839+00	archived	\N	69	16.40	2026-07-03
6fa5de46-9edd-404a-915e-89d9f3f21ae7	e6e0814d-c93d-4ff2-ac03-0f95e574998a	\N	56ee4c58-1504-48a5-b37d-7d040bb2bd16	6f0889c3-21cf-4af8-92e8-834e06a4a09c	پیگیری مطالبات معوق مشتریان #57	\N	low	2026-08-10	6219dc62-e731-4d0f-bdc8-23a6fb51da03	2026-07-20 11:46:45.199839+00	2026-07-20 11:46:45.199839+00	in_progress	\N	36	38.30	2026-08-04
6fa5de46-9edd-404a-915e-89d9f3f21ae7	e6e0814d-c93d-4ff2-ac03-0f95e574998a	\N	6f0889c3-21cf-4af8-92e8-834e06a4a09c	6f0889c3-21cf-4af8-92e8-834e06a4a09c	تطبیق موجودی انبار با حساب‌ها #58	\N	medium	2026-08-30	e3411c1e-cb9f-4063-9cde-05a1c1959da6	2026-07-20 11:46:45.199839+00	2026-07-20 11:46:45.199839+00	in_progress	\N	61	10.10	2026-08-14
6fa5de46-9edd-404a-915e-89d9f3f21ae7	e6e0814d-c93d-4ff2-ac03-0f95e574998a	\N	c28803c6-5155-4136-94b4-4f91ec6ee698	6f0889c3-21cf-4af8-92e8-834e06a4a09c	مغایرت‌گیری حساب‌های بانکی #59	\N	low	2026-07-31	24ed313a-81d3-44b0-9bce-ceeda2358989	2026-07-20 11:46:45.199839+00	2026-07-20 11:46:45.199839+00	completed	approved	100	25.40	2026-07-21
6fa5de46-9edd-404a-915e-89d9f3f21ae7	e6e0814d-c93d-4ff2-ac03-0f95e574998a	\N	3cba84f1-51a4-4831-ac2b-61b820a1122a	6f0889c3-21cf-4af8-92e8-834e06a4a09c	تطبیق موجودی انبار با حساب‌ها #60	\N	high	2026-07-04	1d7bea49-a60f-4e4e-b6fb-497bdca812fc	2026-07-20 11:46:45.199839+00	2026-07-20 11:46:45.199839+00	in_progress	\N	28	26.20	2026-07-01
6fa5de46-9edd-404a-915e-89d9f3f21ae7	e6e0814d-c93d-4ff2-ac03-0f95e574998a	\N	6f0889c3-21cf-4af8-92e8-834e06a4a09c	6f0889c3-21cf-4af8-92e8-834e06a4a09c	تهیهٔ گزارش جریان نقدی #61	\N	medium	2026-07-24	74121c98-21ef-4742-8515-3e5967a44f00	2026-07-20 11:46:45.199839+00	2026-07-20 11:46:45.199839+00	todo	\N	12	27.90	2026-07-12
6fa5de46-9edd-404a-915e-89d9f3f21ae7	e6e0814d-c93d-4ff2-ac03-0f95e574998a	\N	9255642c-40dc-467b-8897-f23fd07f2394	6f0889c3-21cf-4af8-92e8-834e06a4a09c	بررسی فاکتورهای فروش صادرشده #62	\N	high	2026-07-28	f9a96530-23c5-4a3d-9c2f-de0ba45697a5	2026-07-20 11:46:45.199839+00	2026-07-20 11:46:45.199839+00	todo	\N	60	20.10	2026-07-21
6fa5de46-9edd-404a-915e-89d9f3f21ae7	e6e0814d-c93d-4ff2-ac03-0f95e574998a	\N	9255642c-40dc-467b-8897-f23fd07f2394	6f0889c3-21cf-4af8-92e8-834e06a4a09c	پیگیری مطالبات معوق مشتریان #63	\N	high	2026-07-16	6028d50a-524e-449b-9a28-26d07819e9a3	2026-07-20 11:46:45.199839+00	2026-07-20 11:46:45.199839+00	archived	\N	7	36.50	2026-07-04
6fa5de46-9edd-404a-915e-89d9f3f21ae7	e6e0814d-c93d-4ff2-ac03-0f95e574998a	\N	6f0889c3-21cf-4af8-92e8-834e06a4a09c	6f0889c3-21cf-4af8-92e8-834e06a4a09c	بررسی قراردادهای مالی جدید #64	\N	low	2026-07-23	d04049c4-466c-48ea-9491-72d39a02160d	2026-07-20 11:46:45.199839+00	2026-07-20 11:46:45.199839+00	completed	approved	100	17.90	2026-07-20
6fa5de46-9edd-404a-915e-89d9f3f21ae7	e6e0814d-c93d-4ff2-ac03-0f95e574998a	\N	c28803c6-5155-4136-94b4-4f91ec6ee698	6f0889c3-21cf-4af8-92e8-834e06a4a09c	پیگیری بیمهٔ کارکنان #65	\N	medium	2026-08-17	f6c5016c-17c6-42dc-a6e7-ee856ff68549	2026-07-20 11:46:45.199839+00	2026-07-20 11:46:45.199839+00	todo	\N	63	9.10	2026-08-14
6fa5de46-9edd-404a-915e-89d9f3f21ae7	e6e0814d-c93d-4ff2-ac03-0f95e574998a	\N	ca92a9d5-cf4a-4b8b-9fe5-6fadd5c44ca2	6f0889c3-21cf-4af8-92e8-834e06a4a09c	بررسی و تأیید صورت‌حساب‌های خرید #66	\N	medium	2026-08-14	10923ca0-79e5-47b8-8c15-9fdd152b4de4	2026-07-20 11:46:45.199839+00	2026-07-20 11:46:45.199839+00	in_progress	\N	72	24.90	2026-08-11
6fa5de46-9edd-404a-915e-89d9f3f21ae7	e6e0814d-c93d-4ff2-ac03-0f95e574998a	\N	eeebc2e6-a734-4f02-8d65-173ba01323d3	6f0889c3-21cf-4af8-92e8-834e06a4a09c	تهیهٔ پیش‌نویس بودجهٔ واحد #67	\N	medium	2026-08-03	cf69f89a-c4ae-463d-a842-2cbd1f3ff55c	2026-07-20 11:46:45.199839+00	2026-07-20 11:46:45.199839+00	in_progress	\N	17	34.30	2026-07-15
6fa5de46-9edd-404a-915e-89d9f3f21ae7	e6e0814d-c93d-4ff2-ac03-0f95e574998a	\N	56ee4c58-1504-48a5-b37d-7d040bb2bd16	6f0889c3-21cf-4af8-92e8-834e06a4a09c	تهیهٔ گزارش مالیاتی فصلی #68	\N	low	2026-07-03	19134162-fb23-47ee-a9ba-964b24c817fe	2026-07-20 11:46:45.199839+00	2026-07-20 11:46:45.199839+00	in_progress	\N	58	26.60	2026-06-28
6fa5de46-9edd-404a-915e-89d9f3f21ae7	e6e0814d-c93d-4ff2-ac03-0f95e574998a	\N	ca92a9d5-cf4a-4b8b-9fe5-6fadd5c44ca2	6f0889c3-21cf-4af8-92e8-834e06a4a09c	بررسی و تسویهٔ کارت اعتباری شرکت #69	\N	medium	2026-06-28	2f3a8f6d-833a-40e8-a23c-e64982baa04a	2026-07-20 11:46:45.199839+00	2026-07-20 11:46:45.199839+00	todo	\N	72	27.60	2026-06-16
6fa5de46-9edd-404a-915e-89d9f3f21ae7	e6e0814d-c93d-4ff2-ac03-0f95e574998a	\N	9255642c-40dc-467b-8897-f23fd07f2394	6f0889c3-21cf-4af8-92e8-834e06a4a09c	پیگیری بیمهٔ کارکنان #70	\N	medium	2026-08-08	5538d0aa-3bf1-4f46-a6b3-37711d4ffb2a	2026-07-20 11:46:45.199839+00	2026-07-20 11:46:45.199839+00	todo	\N	65	14.50	2026-07-25
6fa5de46-9edd-404a-915e-89d9f3f21ae7	e6e0814d-c93d-4ff2-ac03-0f95e574998a	\N	56ee4c58-1504-48a5-b37d-7d040bb2bd16	6f0889c3-21cf-4af8-92e8-834e06a4a09c	تهیهٔ گزارش مالیاتی فصلی #71	\N	low	2026-07-11	d512005b-0be7-4e8c-b040-f606d685920f	2026-07-20 11:46:45.199839+00	2026-07-20 11:46:45.199839+00	completed	approved	100	2.30	2026-06-24
6fa5de46-9edd-404a-915e-89d9f3f21ae7	e6e0814d-c93d-4ff2-ac03-0f95e574998a	\N	56ee4c58-1504-48a5-b37d-7d040bb2bd16	6f0889c3-21cf-4af8-92e8-834e06a4a09c	تهیهٔ گزارش مالیاتی فصلی #72	\N	medium	2026-07-24	b0031809-6de6-4d6d-96a9-10cc01e2e3ca	2026-07-20 11:46:45.199839+00	2026-07-20 11:46:45.199839+00	in_progress	\N	74	29.50	2026-07-14
6fa5de46-9edd-404a-915e-89d9f3f21ae7	948c5ce5-0757-4628-be4f-0a827239068b	\N	6f0889c3-21cf-4af8-92e8-834e06a4a09c	6f0889c3-21cf-4af8-92e8-834e06a4a09c	تهیهٔ گزارش جریان نقدی #73	\N	low	2026-08-09	fe21d906-16e8-403f-86ec-954b051c5413	2026-07-20 11:46:45.199839+00	2026-07-20 11:46:45.199839+00	in_progress	\N	7	27.40	2026-07-27
6fa5de46-9edd-404a-915e-89d9f3f21ae7	948c5ce5-0757-4628-be4f-0a827239068b	\N	56ee4c58-1504-48a5-b37d-7d040bb2bd16	6f0889c3-21cf-4af8-92e8-834e06a4a09c	تطبیق موجودی انبار با حساب‌ها #74	\N	high	2026-07-10	082ff14b-6963-44fd-915b-4d7ac30f69e8	2026-07-20 11:46:45.199839+00	2026-07-20 11:46:45.199839+00	in_progress	\N	39	28.20	2026-06-26
6fa5de46-9edd-404a-915e-89d9f3f21ae7	948c5ce5-0757-4628-be4f-0a827239068b	\N	ca92a9d5-cf4a-4b8b-9fe5-6fadd5c44ca2	6f0889c3-21cf-4af8-92e8-834e06a4a09c	ثبت اسناد حسابداری هفتگی #75	\N	low	2026-07-30	74989650-dd14-4c7f-aea8-93ff49e6d21b	2026-07-20 11:46:45.199839+00	2026-07-20 11:46:45.199839+00	in_progress	\N	17	20.20	2026-07-09
6fa5de46-9edd-404a-915e-89d9f3f21ae7	948c5ce5-0757-4628-be4f-0a827239068b	\N	56ee4c58-1504-48a5-b37d-7d040bb2bd16	6f0889c3-21cf-4af8-92e8-834e06a4a09c	بررسی فاکتورهای فروش صادرشده #76	\N	high	2026-08-06	e81b8411-c523-45c8-bb18-bf3775df9c60	2026-07-20 11:46:45.199839+00	2026-07-20 11:46:45.199839+00	archived	\N	70	36.70	2026-07-24
6fa5de46-9edd-404a-915e-89d9f3f21ae7	948c5ce5-0757-4628-be4f-0a827239068b	\N	c28803c6-5155-4136-94b4-4f91ec6ee698	6f0889c3-21cf-4af8-92e8-834e06a4a09c	بررسی و تسویهٔ کارت اعتباری شرکت #77	\N	low	2026-08-15	79aac3f0-933e-41f8-baa4-d119c0a882c1	2026-07-20 11:46:45.199839+00	2026-07-20 11:46:45.199839+00	completed	pending	100	27.90	2026-08-07
6fa5de46-9edd-404a-915e-89d9f3f21ae7	948c5ce5-0757-4628-be4f-0a827239068b	\N	3cba84f1-51a4-4831-ac2b-61b820a1122a	6f0889c3-21cf-4af8-92e8-834e06a4a09c	تهیهٔ پیش‌نویس بودجهٔ واحد #78	\N	high	2026-08-04	609a67ca-8fd1-4d03-8b67-fa53607941bd	2026-07-20 11:46:45.199839+00	2026-07-20 11:46:45.199839+00	todo	\N	46	5.00	2026-07-19
6fa5de46-9edd-404a-915e-89d9f3f21ae7	948c5ce5-0757-4628-be4f-0a827239068b	\N	3cba84f1-51a4-4831-ac2b-61b820a1122a	6f0889c3-21cf-4af8-92e8-834e06a4a09c	بررسی قراردادهای مالی جدید #79	\N	high	2026-07-08	3c947951-3ef3-4296-ab70-d5759719990e	2026-07-20 11:46:45.199839+00	2026-07-20 11:46:45.199839+00	todo	\N	25	23.80	2026-06-19
6fa5de46-9edd-404a-915e-89d9f3f21ae7	948c5ce5-0757-4628-be4f-0a827239068b	\N	9255642c-40dc-467b-8897-f23fd07f2394	6f0889c3-21cf-4af8-92e8-834e06a4a09c	به‌روزرسانی جدول حقوق و دستمزد #80	\N	low	2026-07-24	b49e4777-dd09-45d4-a1cf-6f6f7ba6bf95	2026-07-20 11:46:45.199839+00	2026-07-20 11:46:45.199839+00	todo	\N	26	29.20	2026-07-06
6fa5de46-9edd-404a-915e-89d9f3f21ae7	948c5ce5-0757-4628-be4f-0a827239068b	\N	56ee4c58-1504-48a5-b37d-7d040bb2bd16	6f0889c3-21cf-4af8-92e8-834e06a4a09c	به‌روزرسانی جدول حقوق و دستمزد #81	\N	low	2026-08-30	b8d9f9be-6103-4b60-964a-50cca497780a	2026-07-20 11:46:45.199839+00	2026-07-20 11:46:45.199839+00	todo	\N	58	7.00	2026-08-12
6fa5de46-9edd-404a-915e-89d9f3f21ae7	948c5ce5-0757-4628-be4f-0a827239068b	\N	56ee4c58-1504-48a5-b37d-7d040bb2bd16	6f0889c3-21cf-4af8-92e8-834e06a4a09c	تطبیق موجودی انبار با حساب‌ها #82	\N	medium	2026-08-06	4f9ee262-448c-42cc-83a2-22e395a28688	2026-07-20 11:46:45.199839+00	2026-07-20 11:46:45.199839+00	completed	approved	100	29.50	2026-07-21
6fa5de46-9edd-404a-915e-89d9f3f21ae7	948c5ce5-0757-4628-be4f-0a827239068b	\N	56ee4c58-1504-48a5-b37d-7d040bb2bd16	6f0889c3-21cf-4af8-92e8-834e06a4a09c	تهیهٔ گزارش جریان نقدی #83	\N	low	2026-08-09	327beb9a-ae6f-44dd-8ec3-c6c43140855b	2026-07-20 11:46:45.199839+00	2026-07-20 11:46:45.199839+00	in_progress	\N	74	4.80	2026-08-07
6fa5de46-9edd-404a-915e-89d9f3f21ae7	948c5ce5-0757-4628-be4f-0a827239068b	\N	56ee4c58-1504-48a5-b37d-7d040bb2bd16	6f0889c3-21cf-4af8-92e8-834e06a4a09c	تهیهٔ پیش‌نویس بودجهٔ واحد #84	\N	low	2026-08-03	9ca4b959-c0d9-4a8f-a05f-12c208e7926f	2026-07-20 11:46:45.199839+00	2026-07-20 11:46:45.199839+00	in_progress	\N	8	39.50	2026-07-30
6fa5de46-9edd-404a-915e-89d9f3f21ae7	948c5ce5-0757-4628-be4f-0a827239068b	\N	56ee4c58-1504-48a5-b37d-7d040bb2bd16	6f0889c3-21cf-4af8-92e8-834e06a4a09c	مغایرت‌گیری حساب‌های بانکی #85	\N	low	2026-07-19	f46a2727-594e-4c3c-b21a-eb69a08740f6	2026-07-20 11:46:45.199839+00	2026-07-20 11:46:45.199839+00	todo	\N	53	16.20	2026-07-04
6fa5de46-9edd-404a-915e-89d9f3f21ae7	948c5ce5-0757-4628-be4f-0a827239068b	\N	56ee4c58-1504-48a5-b37d-7d040bb2bd16	6f0889c3-21cf-4af8-92e8-834e06a4a09c	بررسی فاکتورهای فروش صادرشده #86	\N	low	2026-08-27	5ca56f0c-2984-432f-b21a-1fda1fea2aab	2026-07-20 11:46:45.199839+00	2026-07-20 11:46:45.199839+00	completed	pending	100	27.90	2026-08-13
6fa5de46-9edd-404a-915e-89d9f3f21ae7	948c5ce5-0757-4628-be4f-0a827239068b	\N	ca92a9d5-cf4a-4b8b-9fe5-6fadd5c44ca2	6f0889c3-21cf-4af8-92e8-834e06a4a09c	تهیهٔ گزارش سود و زیان ماهانه #87	\N	low	2026-08-23	d7c721de-cff8-4458-a2eb-de892c3416a6	2026-07-20 11:46:45.199839+00	2026-07-20 11:46:45.199839+00	completed	approved	100	39.70	2026-08-10
6fa5de46-9edd-404a-915e-89d9f3f21ae7	948c5ce5-0757-4628-be4f-0a827239068b	\N	56ee4c58-1504-48a5-b37d-7d040bb2bd16	6f0889c3-21cf-4af8-92e8-834e06a4a09c	بررسی و تسویهٔ کارت اعتباری شرکت #88	\N	low	2026-07-02	ce25cf6d-c24b-47b0-be35-fce61486c9ab	2026-07-20 11:46:45.199839+00	2026-07-20 11:46:45.199839+00	completed	approved	100	39.20	2026-06-30
6fa5de46-9edd-404a-915e-89d9f3f21ae7	948c5ce5-0757-4628-be4f-0a827239068b	\N	56ee4c58-1504-48a5-b37d-7d040bb2bd16	6f0889c3-21cf-4af8-92e8-834e06a4a09c	بررسی فاکتورهای فروش صادرشده #89	\N	low	2026-08-01	0d5c789c-b1c5-4530-bfd9-83a7d14942d0	2026-07-20 11:46:45.199839+00	2026-07-20 11:46:45.199839+00	completed	pending	100	11.40	2026-07-13
6fa5de46-9edd-404a-915e-89d9f3f21ae7	948c5ce5-0757-4628-be4f-0a827239068b	\N	eeebc2e6-a734-4f02-8d65-173ba01323d3	6f0889c3-21cf-4af8-92e8-834e06a4a09c	بررسی قراردادهای مالی جدید #90	\N	high	2026-07-11	51281c2b-f9f1-470f-9f33-d8c54c7d937e	2026-07-20 11:46:45.199839+00	2026-07-20 11:46:45.199839+00	todo	\N	14	3.20	2026-07-03
6fa5de46-9edd-404a-915e-89d9f3f21ae7	\N	\N	ca92a9d5-cf4a-4b8b-9fe5-6fadd5c44ca2	ca92a9d5-cf4a-4b8b-9fe5-6fadd5c44ca2	ثبت اسناد حسابداری هفتگی #91	\N	low	2026-07-27	2a9ba646-b8a0-4f0a-bcf2-37fe41069b1d	2026-07-20 11:46:45.199839+00	2026-07-20 11:46:45.199839+00	in_progress	\N	8	5.80	2026-07-25
6fa5de46-9edd-404a-915e-89d9f3f21ae7	\N	\N	6f0889c3-21cf-4af8-92e8-834e06a4a09c	6f0889c3-21cf-4af8-92e8-834e06a4a09c	ثبت اسناد حسابداری هفتگی #92	\N	high	2026-08-03	8879a246-afae-49f5-91fe-25394acba4a7	2026-07-20 11:46:45.199839+00	2026-07-20 11:46:45.199839+00	completed	approved	100	3.70	2026-07-31
6fa5de46-9edd-404a-915e-89d9f3f21ae7	\N	\N	56ee4c58-1504-48a5-b37d-7d040bb2bd16	56ee4c58-1504-48a5-b37d-7d040bb2bd16	بررسی و تسویهٔ کارت اعتباری شرکت #93	\N	low	2026-07-28	27287657-4306-41f6-aa12-d6d8f33e066f	2026-07-20 11:46:45.199839+00	2026-07-20 11:46:45.199839+00	in_progress	\N	17	21.10	2026-07-20
6fa5de46-9edd-404a-915e-89d9f3f21ae7	\N	\N	eeebc2e6-a734-4f02-8d65-173ba01323d3	eeebc2e6-a734-4f02-8d65-173ba01323d3	تهیهٔ گزارش مالیاتی فصلی #94	\N	high	2026-08-27	fd3cfc03-c713-4b69-babe-279b7416cb3a	2026-07-20 11:46:45.199839+00	2026-07-20 11:46:45.199839+00	in_progress	\N	76	31.40	2026-08-07
6fa5de46-9edd-404a-915e-89d9f3f21ae7	\N	\N	c28803c6-5155-4136-94b4-4f91ec6ee698	c28803c6-5155-4136-94b4-4f91ec6ee698	بررسی قراردادهای مالی جدید #95	\N	low	2026-07-12	8822e29f-2630-4518-b175-3855723c1301	2026-07-20 11:46:45.199839+00	2026-07-20 11:46:45.199839+00	in_progress	\N	66	10.40	2026-07-01
6fa5de46-9edd-404a-915e-89d9f3f21ae7	\N	\N	eeebc2e6-a734-4f02-8d65-173ba01323d3	eeebc2e6-a734-4f02-8d65-173ba01323d3	بررسی صورت وضعیت پیمانکاران #96	\N	high	2026-07-08	015ee77c-6eb5-472c-8cce-82d5a0f42bd8	2026-07-20 11:46:45.199839+00	2026-07-20 11:46:45.199839+00	in_progress	\N	22	25.80	2026-06-19
6fa5de46-9edd-404a-915e-89d9f3f21ae7	\N	\N	56ee4c58-1504-48a5-b37d-7d040bb2bd16	56ee4c58-1504-48a5-b37d-7d040bb2bd16	بررسی و تسویهٔ کارت اعتباری شرکت #97	\N	high	2026-07-22	32212044-37e6-474f-b1ca-189742900047	2026-07-20 11:46:45.199839+00	2026-07-20 11:46:45.199839+00	completed	approved	100	14.10	2026-07-08
6fa5de46-9edd-404a-915e-89d9f3f21ae7	\N	\N	56ee4c58-1504-48a5-b37d-7d040bb2bd16	56ee4c58-1504-48a5-b37d-7d040bb2bd16	بررسی فاکتورهای فروش صادرشده #98	\N	low	2026-07-06	2a5f6e77-df84-49f6-93de-c5d5b94619ba	2026-07-20 11:46:45.199839+00	2026-07-20 11:46:45.199839+00	in_progress	\N	68	20.00	2026-06-25
6fa5de46-9edd-404a-915e-89d9f3f21ae7	\N	\N	c28803c6-5155-4136-94b4-4f91ec6ee698	c28803c6-5155-4136-94b4-4f91ec6ee698	بررسی و تسویهٔ کارت اعتباری شرکت #99	\N	medium	2026-07-11	18643d2f-db24-482b-96e5-c4deab3ace1e	2026-07-20 11:46:45.199839+00	2026-07-20 11:46:45.199839+00	in_progress	\N	7	23.40	2026-07-05
6fa5de46-9edd-404a-915e-89d9f3f21ae7	\N	\N	56ee4c58-1504-48a5-b37d-7d040bb2bd16	56ee4c58-1504-48a5-b37d-7d040bb2bd16	پیگیری مطالبات معوق مشتریان #100	\N	low	2026-07-19	4394dfd4-c658-45b7-8e34-5a3848502ba2	2026-07-20 11:46:45.199839+00	2026-07-20 11:46:45.199839+00	completed	approved	100	14.50	2026-07-10
6fa5de46-9edd-404a-915e-89d9f3f21ae7	\N	\N	6f0889c3-21cf-4af8-92e8-834e06a4a09c	6f0889c3-21cf-4af8-92e8-834e06a4a09c	تهیهٔ گزارش جریان نقدی #101	\N	low	2026-07-10	51336c23-f3c4-4d9a-9744-ade80bdf1d92	2026-07-20 11:46:45.199839+00	2026-07-20 11:46:45.199839+00	completed	pending	100	4.00	2026-06-21
6fa5de46-9edd-404a-915e-89d9f3f21ae7	\N	\N	56ee4c58-1504-48a5-b37d-7d040bb2bd16	56ee4c58-1504-48a5-b37d-7d040bb2bd16	ثبت اسناد حسابداری هفتگی #102	\N	high	2026-06-22	65770e94-70d6-4de1-a0cf-73c7a41e9dd8	2026-07-20 11:46:45.199839+00	2026-07-20 11:46:45.199839+00	completed	pending	100	29.50	2026-06-18
6fa5de46-9edd-404a-915e-89d9f3f21ae7	\N	\N	3cba84f1-51a4-4831-ac2b-61b820a1122a	3cba84f1-51a4-4831-ac2b-61b820a1122a	پیگیری بیمهٔ کارکنان #103	\N	medium	2026-07-24	e6438295-3639-4035-bf6b-843ad3605bd7	2026-07-20 11:46:45.199839+00	2026-07-20 11:46:45.199839+00	in_progress	\N	38	38.40	2026-07-16
6fa5de46-9edd-404a-915e-89d9f3f21ae7	\N	\N	6f0889c3-21cf-4af8-92e8-834e06a4a09c	6f0889c3-21cf-4af8-92e8-834e06a4a09c	تهیهٔ گزارش جریان نقدی #104	\N	low	2026-08-22	b384ef43-2f17-4bd3-bbd0-a024f179a6d3	2026-07-20 11:46:45.199839+00	2026-07-20 11:46:45.199839+00	in_progress	\N	61	36.70	2026-08-14
6fa5de46-9edd-404a-915e-89d9f3f21ae7	\N	\N	ca92a9d5-cf4a-4b8b-9fe5-6fadd5c44ca2	ca92a9d5-cf4a-4b8b-9fe5-6fadd5c44ca2	تهیهٔ پیش‌نویس بودجهٔ واحد #105	\N	medium	2026-07-20	2d867f62-6440-416b-8340-29f14285ffa4	2026-07-20 11:46:45.199839+00	2026-07-20 11:46:45.199839+00	completed	pending	100	31.50	2026-07-11
6fa5de46-9edd-404a-915e-89d9f3f21ae7	bf961011-51f2-4658-9ee8-3e751094c075	\N	c2241423-6f70-4f15-92a9-c4a433dfec70	c2241423-6f70-4f15-92a9-c4a433dfec70	برگزاری نظرسنجی رضایت شغلی #1	\N	low	2026-07-29	22cf1ead-f17b-4dcf-99b0-a1b1a3ed8850	2026-07-20 11:46:45.199839+00	2026-07-20 11:46:45.199839+00	todo	\N	67	34.70	2026-07-23
6fa5de46-9edd-404a-915e-89d9f3f21ae7	bf961011-51f2-4658-9ee8-3e751094c075	\N	c2241423-6f70-4f15-92a9-c4a433dfec70	c2241423-6f70-4f15-92a9-c4a433dfec70	تدوین برنامهٔ آموزشی سال آینده #2	\N	low	2026-08-14	1313cf9c-b4fe-483b-aef2-21fd5124981d	2026-07-20 11:46:45.199839+00	2026-07-20 11:46:45.199839+00	in_progress	\N	43	13.50	2026-07-31
6fa5de46-9edd-404a-915e-89d9f3f21ae7	bf961011-51f2-4658-9ee8-3e751094c075	\N	c700c6fb-ad08-4eaa-9597-f02c27aa0e58	c2241423-6f70-4f15-92a9-c4a433dfec70	برگزاری نظرسنجی رضایت شغلی #3	\N	high	2026-08-16	aa3d53cc-81e4-44ce-92f7-9e884dc6d059	2026-07-20 11:46:45.199839+00	2026-07-20 11:46:45.199839+00	todo	\N	62	26.70	2026-08-01
6fa5de46-9edd-404a-915e-89d9f3f21ae7	bf961011-51f2-4658-9ee8-3e751094c075	\N	c700c6fb-ad08-4eaa-9597-f02c27aa0e58	c2241423-6f70-4f15-92a9-c4a433dfec70	برگزاری نظرسنجی رضایت شغلی #4	\N	medium	2026-08-11	2c7fc683-33d0-4e4b-8411-45477b760582	2026-07-20 11:46:45.199839+00	2026-07-20 11:46:45.199839+00	archived	\N	28	27.30	2026-07-21
6fa5de46-9edd-404a-915e-89d9f3f21ae7	bf961011-51f2-4658-9ee8-3e751094c075	\N	07fc03fd-5b06-4623-adbc-9d3292322efa	c2241423-6f70-4f15-92a9-c4a433dfec70	به‌روزرسانی پروندهٔ پرسنلی #5	\N	high	2026-07-21	dee8dd36-7f55-41e9-85d3-620cd68d345f	2026-07-20 11:46:45.199839+00	2026-07-20 11:46:45.199839+00	todo	\N	37	6.80	2026-07-10
6fa5de46-9edd-404a-915e-89d9f3f21ae7	bf961011-51f2-4658-9ee8-3e751094c075	\N	0bf949b7-932b-40ba-8d67-4ea888360556	c2241423-6f70-4f15-92a9-c4a433dfec70	تهیهٔ فرم ارزیابی سه‌ماهه #6	\N	high	2026-09-04	579c3032-09f0-4852-ad28-5c27aac53e12	2026-07-20 11:46:45.199839+00	2026-07-20 11:46:45.199839+00	todo	\N	4	8.90	2026-08-15
6fa5de46-9edd-404a-915e-89d9f3f21ae7	bf961011-51f2-4658-9ee8-3e751094c075	\N	16119c08-e43f-4846-adcd-f77ad1aca132	c2241423-6f70-4f15-92a9-c4a433dfec70	بررسی درخواست ترفیع کارکنان #7	\N	medium	2026-07-27	5a4ffe2f-3079-4e6f-bbce-f3a61e00c16c	2026-07-20 11:46:45.199839+00	2026-07-20 11:46:45.199839+00	completed	approved	100	7.30	2026-07-22
6fa5de46-9edd-404a-915e-89d9f3f21ae7	bf961011-51f2-4658-9ee8-3e751094c075	\N	0bf949b7-932b-40ba-8d67-4ea888360556	c2241423-6f70-4f15-92a9-c4a433dfec70	پیگیری درخواست‌های رفاهی کارکنان #8	\N	low	2026-07-14	850d56d3-ef43-417a-ac2b-c0e7a8517ba1	2026-07-20 11:46:45.199839+00	2026-07-20 11:46:45.199839+00	todo	\N	11	33.20	2026-07-01
6fa5de46-9edd-404a-915e-89d9f3f21ae7	bf961011-51f2-4658-9ee8-3e751094c075	\N	0bf949b7-932b-40ba-8d67-4ea888360556	c2241423-6f70-4f15-92a9-c4a433dfec70	بررسی رزومه‌های متقاضیان شغلی #9	\N	medium	2026-07-23	77f55057-0625-4841-a68c-e8aade86d09e	2026-07-20 11:46:45.199839+00	2026-07-20 11:46:45.199839+00	completed	pending	100	10.00	2026-07-07
6fa5de46-9edd-404a-915e-89d9f3f21ae7	bf961011-51f2-4658-9ee8-3e751094c075	\N	0bf949b7-932b-40ba-8d67-4ea888360556	c2241423-6f70-4f15-92a9-c4a433dfec70	برگزاری نظرسنجی رضایت شغلی #10	\N	low	2026-07-18	2252a1c1-5cbd-48a7-b01a-ef174d3e459e	2026-07-20 11:46:45.199839+00	2026-07-20 11:46:45.199839+00	todo	\N	0	3.80	2026-07-08
6fa5de46-9edd-404a-915e-89d9f3f21ae7	bf961011-51f2-4658-9ee8-3e751094c075	\N	cf5d8b24-a057-421e-9cc3-b442f742293f	c2241423-6f70-4f15-92a9-c4a433dfec70	بررسی درخواست ترفیع کارکنان #11	\N	medium	2026-07-19	b7a6249e-3e78-46e1-9c06-af77b772ed74	2026-07-20 11:46:45.199839+00	2026-07-20 11:46:45.199839+00	archived	\N	63	35.50	2026-07-12
6fa5de46-9edd-404a-915e-89d9f3f21ae7	bf961011-51f2-4658-9ee8-3e751094c075	\N	16119c08-e43f-4846-adcd-f77ad1aca132	c2241423-6f70-4f15-92a9-c4a433dfec70	برگزاری نظرسنجی رضایت شغلی #12	\N	high	2026-08-25	ff5bed90-6c18-4beb-a33a-85cc6b0786cd	2026-07-20 11:46:45.199839+00	2026-07-20 11:46:45.199839+00	completed	approved	100	26.70	2026-08-08
6fa5de46-9edd-404a-915e-89d9f3f21ae7	bf961011-51f2-4658-9ee8-3e751094c075	\N	0bf949b7-932b-40ba-8d67-4ea888360556	c2241423-6f70-4f15-92a9-c4a433dfec70	برنامه‌ریزی مصاحبهٔ استخدامی #13	\N	low	2026-07-12	096beeef-a670-4862-8c23-34f45d9dd637	2026-07-20 11:46:45.199839+00	2026-07-20 11:46:45.199839+00	in_progress	\N	37	2.80	2026-06-26
6fa5de46-9edd-404a-915e-89d9f3f21ae7	bf961011-51f2-4658-9ee8-3e751094c075	\N	16119c08-e43f-4846-adcd-f77ad1aca132	c2241423-6f70-4f15-92a9-c4a433dfec70	تهیهٔ گزارش ارزیابی عملکرد #14	\N	medium	2026-07-02	b96a60f3-ebf8-4d2e-bc37-4253bdc2a761	2026-07-20 11:46:45.199839+00	2026-07-20 11:46:45.199839+00	todo	\N	20	29.80	2026-06-20
6fa5de46-9edd-404a-915e-89d9f3f21ae7	bf961011-51f2-4658-9ee8-3e751094c075	\N	cd92c461-1da5-4222-b6f0-60ce30f3d910	c2241423-6f70-4f15-92a9-c4a433dfec70	تدوین برنامهٔ آموزشی سال آینده #15	\N	medium	2026-07-28	ab175f7e-c086-4ec8-bd83-c44dcb7f33d8	2026-07-20 11:46:45.199839+00	2026-07-20 11:46:45.199839+00	todo	\N	3	18.40	2026-07-07
6fa5de46-9edd-404a-915e-89d9f3f21ae7	bf961011-51f2-4658-9ee8-3e751094c075	\N	0bf949b7-932b-40ba-8d67-4ea888360556	c2241423-6f70-4f15-92a9-c4a433dfec70	تهیهٔ گزارش ارزیابی عملکرد #16	\N	low	2026-08-08	dca31a3f-56a7-4d2f-a8b3-122a393faa4b	2026-07-20 11:46:45.199839+00	2026-07-20 11:46:45.199839+00	todo	\N	12	14.60	2026-07-24
6fa5de46-9edd-404a-915e-89d9f3f21ae7	bf961011-51f2-4658-9ee8-3e751094c075	\N	c700c6fb-ad08-4eaa-9597-f02c27aa0e58	c2241423-6f70-4f15-92a9-c4a433dfec70	به‌روزرسانی پروندهٔ پرسنلی #17	\N	high	2026-08-18	9d941e57-248a-4748-b178-c41b43a24359	2026-07-20 11:46:45.199839+00	2026-07-20 11:46:45.199839+00	in_progress	\N	69	12.10	2026-07-30
6fa5de46-9edd-404a-915e-89d9f3f21ae7	bf961011-51f2-4658-9ee8-3e751094c075	\N	16119c08-e43f-4846-adcd-f77ad1aca132	c2241423-6f70-4f15-92a9-c4a433dfec70	بررسی رزومه‌های متقاضیان شغلی #18	\N	medium	2026-07-06	e2bf4f0f-c15a-463d-9255-ec9a51bd6551	2026-07-20 11:46:45.199839+00	2026-07-20 11:46:45.199839+00	in_progress	\N	73	22.90	2026-07-01
6fa5de46-9edd-404a-915e-89d9f3f21ae7	07c27000-8555-48ac-9933-ddc1983684fc	\N	cf5d8b24-a057-421e-9cc3-b442f742293f	c2241423-6f70-4f15-92a9-c4a433dfec70	بررسی رزومه‌های متقاضیان شغلی #19	\N	medium	2026-07-02	1ffd4e42-f9c9-4b06-9c77-1f692241a788	2026-07-20 11:46:45.199839+00	2026-07-20 11:46:45.199839+00	todo	\N	11	13.20	2026-06-19
6fa5de46-9edd-404a-915e-89d9f3f21ae7	07c27000-8555-48ac-9933-ddc1983684fc	\N	0bf949b7-932b-40ba-8d67-4ea888360556	c2241423-6f70-4f15-92a9-c4a433dfec70	بررسی رزومه‌های متقاضیان شغلی #20	\N	low	2026-07-03	1979485e-17f3-4083-bb17-e8397cbcaead	2026-07-20 11:46:45.199839+00	2026-07-20 11:46:45.199839+00	completed	pending	100	8.50	2026-06-28
6fa5de46-9edd-404a-915e-89d9f3f21ae7	07c27000-8555-48ac-9933-ddc1983684fc	\N	16119c08-e43f-4846-adcd-f77ad1aca132	c2241423-6f70-4f15-92a9-c4a433dfec70	به‌روزرسانی آیین‌نامهٔ داخلی شرکت #21	\N	medium	2026-07-21	2158ccfb-fbf9-4039-ab09-1ed72d56c387	2026-07-20 11:46:45.199839+00	2026-07-20 11:46:45.199839+00	todo	\N	60	20.60	2026-07-16
6fa5de46-9edd-404a-915e-89d9f3f21ae7	07c27000-8555-48ac-9933-ddc1983684fc	\N	0bf949b7-932b-40ba-8d67-4ea888360556	c2241423-6f70-4f15-92a9-c4a433dfec70	تهیهٔ فرم ارزیابی سه‌ماهه #22	\N	low	2026-07-10	29b69f62-3ce5-401f-8b1e-6d75b155e829	2026-07-20 11:46:45.199839+00	2026-07-20 11:46:45.199839+00	in_progress	\N	47	35.60	2026-06-21
6fa5de46-9edd-404a-915e-89d9f3f21ae7	07c27000-8555-48ac-9933-ddc1983684fc	\N	16119c08-e43f-4846-adcd-f77ad1aca132	c2241423-6f70-4f15-92a9-c4a433dfec70	به‌روزرسانی آیین‌نامهٔ داخلی شرکت #23	\N	medium	2026-07-17	71326331-d825-4ef7-a25d-4cd7d5f8a181	2026-07-20 11:46:45.199839+00	2026-07-20 11:46:45.199839+00	todo	\N	59	12.00	2026-07-14
6fa5de46-9edd-404a-915e-89d9f3f21ae7	07c27000-8555-48ac-9933-ddc1983684fc	\N	07fc03fd-5b06-4623-adbc-9d3292322efa	c2241423-6f70-4f15-92a9-c4a433dfec70	تهیهٔ گزارش ارزیابی عملکرد #24	\N	high	2026-07-25	724e2731-22a6-4823-a777-de83b8150d20	2026-07-20 11:46:45.199839+00	2026-07-20 11:46:45.199839+00	in_progress	\N	12	5.30	2026-07-22
6fa5de46-9edd-404a-915e-89d9f3f21ae7	07c27000-8555-48ac-9933-ddc1983684fc	\N	16119c08-e43f-4846-adcd-f77ad1aca132	c2241423-6f70-4f15-92a9-c4a433dfec70	برگزاری جلسهٔ آموزش کارکنان جدید #25	\N	high	2026-08-23	e6cef5f2-13a6-4336-ba11-dc3758aa7b24	2026-07-20 11:46:45.199839+00	2026-07-20 11:46:45.199839+00	completed	approved	100	4.30	2026-08-03
6fa5de46-9edd-404a-915e-89d9f3f21ae7	07c27000-8555-48ac-9933-ddc1983684fc	\N	cf5d8b24-a057-421e-9cc3-b442f742293f	c2241423-6f70-4f15-92a9-c4a433dfec70	تدوین برنامهٔ آموزشی سال آینده #26	\N	low	2026-08-06	de9f2bf8-7068-4382-a5ad-5a4bd375dc71	2026-07-20 11:46:45.199839+00	2026-07-20 11:46:45.199839+00	completed	approved	100	20.10	2026-07-20
6fa5de46-9edd-404a-915e-89d9f3f21ae7	07c27000-8555-48ac-9933-ddc1983684fc	\N	c2241423-6f70-4f15-92a9-c4a433dfec70	c2241423-6f70-4f15-92a9-c4a433dfec70	بررسی و تمدید قراردادهای پرسنلی #27	\N	high	2026-08-15	216f5802-fcf0-4fb6-afce-6bc921c0858b	2026-07-20 11:46:45.199839+00	2026-07-20 11:46:45.199839+00	in_progress	\N	66	32.40	2026-08-12
6fa5de46-9edd-404a-915e-89d9f3f21ae7	07c27000-8555-48ac-9933-ddc1983684fc	\N	0bf949b7-932b-40ba-8d67-4ea888360556	c2241423-6f70-4f15-92a9-c4a433dfec70	تهیهٔ گزارش ارزیابی عملکرد #28	\N	low	2026-08-31	387e2534-4e13-42d7-8239-b2725a713ff4	2026-07-20 11:46:45.199839+00	2026-07-20 11:46:45.199839+00	completed	approved	100	38.90	2026-08-15
6fa5de46-9edd-404a-915e-89d9f3f21ae7	07c27000-8555-48ac-9933-ddc1983684fc	\N	07fc03fd-5b06-4623-adbc-9d3292322efa	c2241423-6f70-4f15-92a9-c4a433dfec70	تهیهٔ فرم ارزیابی سه‌ماهه #29	\N	low	2026-06-27	c31f2fe8-a71d-48c8-a8ba-c34762c5cfde	2026-07-20 11:46:45.199839+00	2026-07-20 11:46:45.199839+00	todo	\N	55	9.70	2026-06-24
6fa5de46-9edd-404a-915e-89d9f3f21ae7	07c27000-8555-48ac-9933-ddc1983684fc	\N	07fc03fd-5b06-4623-adbc-9d3292322efa	c2241423-6f70-4f15-92a9-c4a433dfec70	پیگیری درخواست‌های رفاهی کارکنان #30	\N	high	2026-08-03	476980dc-54db-43d9-a7b7-35755db6401a	2026-07-20 11:46:45.199839+00	2026-07-20 11:46:45.199839+00	completed	approved	100	36.70	2026-07-24
6fa5de46-9edd-404a-915e-89d9f3f21ae7	07c27000-8555-48ac-9933-ddc1983684fc	\N	c2241423-6f70-4f15-92a9-c4a433dfec70	c2241423-6f70-4f15-92a9-c4a433dfec70	تهیهٔ فرم ارزیابی سه‌ماهه #31	\N	high	2026-07-29	ab2341a2-ab07-4906-9c8f-4ee2fdb082c3	2026-07-20 11:46:45.199839+00	2026-07-20 11:46:45.199839+00	todo	\N	41	34.60	2026-07-10
6fa5de46-9edd-404a-915e-89d9f3f21ae7	07c27000-8555-48ac-9933-ddc1983684fc	\N	cd92c461-1da5-4222-b6f0-60ce30f3d910	c2241423-6f70-4f15-92a9-c4a433dfec70	تدوین برنامهٔ آموزشی سال آینده #32	\N	high	2026-07-07	384a495a-f801-4410-ba8b-a941eaa14343	2026-07-20 11:46:45.199839+00	2026-07-20 11:46:45.199839+00	completed	rejected	100	31.70	2026-06-16
6fa5de46-9edd-404a-915e-89d9f3f21ae7	07c27000-8555-48ac-9933-ddc1983684fc	\N	c2241423-6f70-4f15-92a9-c4a433dfec70	c2241423-6f70-4f15-92a9-c4a433dfec70	تدوین برنامهٔ آموزشی سال آینده #33	\N	high	2026-07-01	778e2d55-63db-46ad-a021-01d4ca11c6cc	2026-07-20 11:46:45.199839+00	2026-07-20 11:46:45.199839+00	in_progress	\N	74	30.80	2026-06-25
6fa5de46-9edd-404a-915e-89d9f3f21ae7	07c27000-8555-48ac-9933-ddc1983684fc	\N	c2241423-6f70-4f15-92a9-c4a433dfec70	c2241423-6f70-4f15-92a9-c4a433dfec70	برگزاری نظرسنجی رضایت شغلی #34	\N	medium	2026-07-27	4ea7f21f-de01-4632-969a-15b03977ad40	2026-07-20 11:46:45.199839+00	2026-07-20 11:46:45.199839+00	todo	\N	68	35.40	2026-07-22
6fa5de46-9edd-404a-915e-89d9f3f21ae7	07c27000-8555-48ac-9933-ddc1983684fc	\N	cf5d8b24-a057-421e-9cc3-b442f742293f	c2241423-6f70-4f15-92a9-c4a433dfec70	تدوین برنامهٔ آموزشی سال آینده #35	\N	high	2026-07-27	71c9ea7b-33bf-4612-a7f8-3970801ea8f6	2026-07-20 11:46:45.199839+00	2026-07-20 11:46:45.199839+00	in_progress	\N	60	3.40	2026-07-10
6fa5de46-9edd-404a-915e-89d9f3f21ae7	07c27000-8555-48ac-9933-ddc1983684fc	\N	16119c08-e43f-4846-adcd-f77ad1aca132	c2241423-6f70-4f15-92a9-c4a433dfec70	تدوین برنامهٔ آموزشی سال آینده #36	\N	high	2026-07-16	1e5df6f3-328a-40d6-9ed6-b39349d8bb67	2026-07-20 11:46:45.199839+00	2026-07-20 11:46:45.199839+00	in_progress	\N	51	3.50	2026-06-25
6fa5de46-9edd-404a-915e-89d9f3f21ae7	fe4b316c-1eee-4af3-b5d4-8c5c6710c9bb	\N	16119c08-e43f-4846-adcd-f77ad1aca132	c2241423-6f70-4f15-92a9-c4a433dfec70	بررسی درخواست ترفیع کارکنان #37	\N	medium	2026-08-19	47119011-6f99-4866-9058-db8ec825d241	2026-07-20 11:46:45.199839+00	2026-07-20 11:46:45.199839+00	completed	approved	100	36.10	2026-08-02
6fa5de46-9edd-404a-915e-89d9f3f21ae7	fe4b316c-1eee-4af3-b5d4-8c5c6710c9bb	\N	c2241423-6f70-4f15-92a9-c4a433dfec70	c2241423-6f70-4f15-92a9-c4a433dfec70	به‌روزرسانی آیین‌نامهٔ داخلی شرکت #38	\N	medium	2026-08-18	84ed4d26-f0ab-43e4-9daf-2b7034f1a7cf	2026-07-20 11:46:45.199839+00	2026-07-20 11:46:45.199839+00	in_progress	\N	62	34.60	2026-08-07
6fa5de46-9edd-404a-915e-89d9f3f21ae7	fe4b316c-1eee-4af3-b5d4-8c5c6710c9bb	\N	0bf949b7-932b-40ba-8d67-4ea888360556	c2241423-6f70-4f15-92a9-c4a433dfec70	تهیهٔ گزارش ارزیابی عملکرد #39	\N	medium	2026-08-19	241c5cb7-0966-4684-a1de-1f0f3f4c8ee9	2026-07-20 11:46:45.199839+00	2026-07-20 11:46:45.199839+00	todo	\N	56	31.40	2026-08-10
6fa5de46-9edd-404a-915e-89d9f3f21ae7	fe4b316c-1eee-4af3-b5d4-8c5c6710c9bb	\N	16119c08-e43f-4846-adcd-f77ad1aca132	c2241423-6f70-4f15-92a9-c4a433dfec70	تدوین برنامهٔ آموزشی سال آینده #40	\N	high	2026-08-16	79c62471-1912-41ae-bfb9-b02d5a18e580	2026-07-20 11:46:45.199839+00	2026-07-20 11:46:45.199839+00	in_progress	\N	11	9.10	2026-08-01
6fa5de46-9edd-404a-915e-89d9f3f21ae7	fe4b316c-1eee-4af3-b5d4-8c5c6710c9bb	\N	c700c6fb-ad08-4eaa-9597-f02c27aa0e58	c2241423-6f70-4f15-92a9-c4a433dfec70	برگزاری نظرسنجی رضایت شغلی #41	\N	high	2026-08-19	b9cff182-d720-4d76-9a5b-1b37b3842fae	2026-07-20 11:46:45.199839+00	2026-07-20 11:46:45.199839+00	in_progress	\N	47	33.20	2026-08-02
6fa5de46-9edd-404a-915e-89d9f3f21ae7	fe4b316c-1eee-4af3-b5d4-8c5c6710c9bb	\N	cd92c461-1da5-4222-b6f0-60ce30f3d910	c2241423-6f70-4f15-92a9-c4a433dfec70	به‌روزرسانی پروندهٔ پرسنلی #42	\N	high	2026-07-01	bc50f0df-36d9-4c59-bdd2-ba98cbe72f4a	2026-07-20 11:46:45.199839+00	2026-07-20 11:46:45.199839+00	todo	\N	51	7.20	2026-06-20
6fa5de46-9edd-404a-915e-89d9f3f21ae7	fe4b316c-1eee-4af3-b5d4-8c5c6710c9bb	\N	07fc03fd-5b06-4623-adbc-9d3292322efa	c2241423-6f70-4f15-92a9-c4a433dfec70	برگزاری جلسهٔ آموزش کارکنان جدید #43	\N	low	2026-06-24	44b2d040-31d8-4f86-89b5-7c39bf8b2979	2026-07-20 11:46:45.199839+00	2026-07-20 11:46:45.199839+00	completed	pending	100	33.80	2026-06-17
6fa5de46-9edd-404a-915e-89d9f3f21ae7	fe4b316c-1eee-4af3-b5d4-8c5c6710c9bb	\N	c700c6fb-ad08-4eaa-9597-f02c27aa0e58	c2241423-6f70-4f15-92a9-c4a433dfec70	بررسی درخواست ترفیع کارکنان #44	\N	medium	2026-07-18	70428499-318c-4db7-bbc6-c05350c3b2b0	2026-07-20 11:46:45.199839+00	2026-07-20 11:46:45.199839+00	todo	\N	25	12.40	2026-07-15
6fa5de46-9edd-404a-915e-89d9f3f21ae7	fe4b316c-1eee-4af3-b5d4-8c5c6710c9bb	\N	07fc03fd-5b06-4623-adbc-9d3292322efa	c2241423-6f70-4f15-92a9-c4a433dfec70	پیگیری مرخصی و مأموریت کارکنان #45	\N	low	2026-07-31	37370659-b015-4d80-8d8f-5a96661e1523	2026-07-20 11:46:45.199839+00	2026-07-20 11:46:45.199839+00	completed	approved	100	11.20	2026-07-26
6fa5de46-9edd-404a-915e-89d9f3f21ae7	fe4b316c-1eee-4af3-b5d4-8c5c6710c9bb	\N	cf5d8b24-a057-421e-9cc3-b442f742293f	c2241423-6f70-4f15-92a9-c4a433dfec70	تدوین برنامهٔ آموزشی سال آینده #46	\N	high	2026-08-27	e470138e-4ec3-4d05-9919-82c3fd0d1781	2026-07-20 11:46:45.199839+00	2026-07-20 11:46:45.199839+00	completed	approved	100	15.30	2026-08-10
6fa5de46-9edd-404a-915e-89d9f3f21ae7	fe4b316c-1eee-4af3-b5d4-8c5c6710c9bb	\N	c700c6fb-ad08-4eaa-9597-f02c27aa0e58	c2241423-6f70-4f15-92a9-c4a433dfec70	به‌روزرسانی آیین‌نامهٔ داخلی شرکت #47	\N	low	2026-08-06	5d80edd8-8e71-487b-a5ce-729e923ee9d0	2026-07-20 11:46:45.199839+00	2026-07-20 11:46:45.199839+00	in_progress	\N	49	3.90	2026-08-02
6fa5de46-9edd-404a-915e-89d9f3f21ae7	fe4b316c-1eee-4af3-b5d4-8c5c6710c9bb	\N	07fc03fd-5b06-4623-adbc-9d3292322efa	c2241423-6f70-4f15-92a9-c4a433dfec70	پیگیری مرخصی و مأموریت کارکنان #48	\N	low	2026-07-08	af8720ff-0e1b-41bc-af11-d34f86e49df7	2026-07-20 11:46:45.199839+00	2026-07-20 11:46:45.199839+00	completed	pending	100	27.80	2026-06-29
6fa5de46-9edd-404a-915e-89d9f3f21ae7	fe4b316c-1eee-4af3-b5d4-8c5c6710c9bb	\N	16119c08-e43f-4846-adcd-f77ad1aca132	c2241423-6f70-4f15-92a9-c4a433dfec70	برنامه‌ریزی رویداد تیم‌سازی #49	\N	low	2026-06-19	79915aad-3657-42d5-afbb-6ca2237797e9	2026-07-20 11:46:45.199839+00	2026-07-20 11:46:45.199839+00	completed	approved	100	26.60	2026-06-17
6fa5de46-9edd-404a-915e-89d9f3f21ae7	fe4b316c-1eee-4af3-b5d4-8c5c6710c9bb	\N	cd92c461-1da5-4222-b6f0-60ce30f3d910	c2241423-6f70-4f15-92a9-c4a433dfec70	تدوین برنامهٔ آموزشی سال آینده #50	\N	medium	2026-07-10	46a41773-f9e4-4028-984e-a6fde6dd75c2	2026-07-20 11:46:45.199839+00	2026-07-20 11:46:45.199839+00	todo	\N	35	18.10	2026-06-30
6fa5de46-9edd-404a-915e-89d9f3f21ae7	fe4b316c-1eee-4af3-b5d4-8c5c6710c9bb	\N	cf5d8b24-a057-421e-9cc3-b442f742293f	c2241423-6f70-4f15-92a9-c4a433dfec70	برگزاری جلسهٔ آموزش کارکنان جدید #51	\N	medium	2026-07-25	0573a164-5530-431a-a229-9d8dc6471418	2026-07-20 11:46:45.199839+00	2026-07-20 11:46:45.199839+00	in_progress	\N	38	27.70	2026-07-15
6fa5de46-9edd-404a-915e-89d9f3f21ae7	fe4b316c-1eee-4af3-b5d4-8c5c6710c9bb	\N	07fc03fd-5b06-4623-adbc-9d3292322efa	c2241423-6f70-4f15-92a9-c4a433dfec70	بررسی و تمدید قراردادهای پرسنلی #52	\N	high	2026-06-24	572b3a58-7551-4804-bc0d-d4a583aaeddf	2026-07-20 11:46:45.199839+00	2026-07-20 11:46:45.199839+00	completed	approved	100	38.70	2026-06-22
6fa5de46-9edd-404a-915e-89d9f3f21ae7	fe4b316c-1eee-4af3-b5d4-8c5c6710c9bb	\N	07fc03fd-5b06-4623-adbc-9d3292322efa	c2241423-6f70-4f15-92a9-c4a433dfec70	تدوین برنامهٔ آموزشی سال آینده #53	\N	medium	2026-08-11	0f8471e9-c184-42b5-883a-a8a92c2251bd	2026-07-20 11:46:45.199839+00	2026-07-20 11:46:45.199839+00	in_progress	\N	38	28.00	2026-07-21
6fa5de46-9edd-404a-915e-89d9f3f21ae7	fe4b316c-1eee-4af3-b5d4-8c5c6710c9bb	\N	cf5d8b24-a057-421e-9cc3-b442f742293f	c2241423-6f70-4f15-92a9-c4a433dfec70	پیگیری مرخصی و مأموریت کارکنان #54	\N	medium	2026-07-17	51c0f486-c306-4ac6-a384-f9b16c717897	2026-07-20 11:46:45.199839+00	2026-07-20 11:46:45.199839+00	todo	\N	35	11.90	2026-07-07
6fa5de46-9edd-404a-915e-89d9f3f21ae7	12b3562f-9b7e-4fd7-b326-d7e733197f75	\N	0bf949b7-932b-40ba-8d67-4ea888360556	c2241423-6f70-4f15-92a9-c4a433dfec70	برگزاری نظرسنجی رضایت شغلی #55	\N	low	2026-07-13	11c3323b-eaf8-4691-b05a-7aee46a8cf38	2026-07-20 11:46:45.199839+00	2026-07-20 11:46:45.199839+00	completed	approved	100	36.20	2026-06-25
6fa5de46-9edd-404a-915e-89d9f3f21ae7	12b3562f-9b7e-4fd7-b326-d7e733197f75	\N	07fc03fd-5b06-4623-adbc-9d3292322efa	c2241423-6f70-4f15-92a9-c4a433dfec70	به‌روزرسانی پروندهٔ پرسنلی #56	\N	low	2026-07-12	a17d3814-02b6-4b17-8526-d8d9c4196f92	2026-07-20 11:46:45.199839+00	2026-07-20 11:46:45.199839+00	completed	approved	100	26.90	2026-07-06
6fa5de46-9edd-404a-915e-89d9f3f21ae7	12b3562f-9b7e-4fd7-b326-d7e733197f75	\N	16119c08-e43f-4846-adcd-f77ad1aca132	c2241423-6f70-4f15-92a9-c4a433dfec70	تهیهٔ فرم ارزیابی سه‌ماهه #57	\N	medium	2026-08-28	dbd092d1-adb9-47b5-82ba-8dfc00d178c6	2026-07-20 11:46:45.199839+00	2026-07-20 11:46:45.199839+00	in_progress	\N	4	24.20	2026-08-13
6fa5de46-9edd-404a-915e-89d9f3f21ae7	12b3562f-9b7e-4fd7-b326-d7e733197f75	\N	cd92c461-1da5-4222-b6f0-60ce30f3d910	c2241423-6f70-4f15-92a9-c4a433dfec70	پیگیری مرخصی و مأموریت کارکنان #58	\N	high	2026-07-16	9a6d46bd-c395-4ce2-bf19-00667ed8648c	2026-07-20 11:46:45.199839+00	2026-07-20 11:46:45.199839+00	todo	\N	60	36.40	2026-07-07
6fa5de46-9edd-404a-915e-89d9f3f21ae7	12b3562f-9b7e-4fd7-b326-d7e733197f75	\N	0bf949b7-932b-40ba-8d67-4ea888360556	c2241423-6f70-4f15-92a9-c4a433dfec70	تهیهٔ گزارش غیبت و تأخیر #59	\N	low	2026-07-29	d5c5e748-99f6-4a47-b439-87244cf58419	2026-07-20 11:46:45.199839+00	2026-07-20 11:46:45.199839+00	in_progress	\N	71	8.90	2026-07-18
6fa5de46-9edd-404a-915e-89d9f3f21ae7	12b3562f-9b7e-4fd7-b326-d7e733197f75	\N	c2241423-6f70-4f15-92a9-c4a433dfec70	c2241423-6f70-4f15-92a9-c4a433dfec70	برگزاری نظرسنجی رضایت شغلی #60	\N	low	2026-07-21	61a1127c-6765-4dcf-9c06-7dbdd0d13f82	2026-07-20 11:46:45.199839+00	2026-07-20 11:46:45.199839+00	completed	approved	100	38.00	2026-07-02
6fa5de46-9edd-404a-915e-89d9f3f21ae7	12b3562f-9b7e-4fd7-b326-d7e733197f75	\N	16119c08-e43f-4846-adcd-f77ad1aca132	c2241423-6f70-4f15-92a9-c4a433dfec70	به‌روزرسانی پروندهٔ پرسنلی #61	\N	medium	2026-07-17	ffe1f5cb-aea7-4e93-9d73-c7fcc0757c05	2026-07-20 11:46:45.199839+00	2026-07-20 11:46:45.199839+00	completed	approved	100	18.00	2026-07-08
6fa5de46-9edd-404a-915e-89d9f3f21ae7	12b3562f-9b7e-4fd7-b326-d7e733197f75	\N	16119c08-e43f-4846-adcd-f77ad1aca132	c2241423-6f70-4f15-92a9-c4a433dfec70	به‌روزرسانی آیین‌نامهٔ داخلی شرکت #62	\N	medium	2026-07-22	11bf9856-746f-4342-bb36-fb1d8c3e0a0b	2026-07-20 11:46:45.199839+00	2026-07-20 11:46:45.199839+00	in_progress	\N	15	19.90	2026-07-02
6fa5de46-9edd-404a-915e-89d9f3f21ae7	12b3562f-9b7e-4fd7-b326-d7e733197f75	\N	07fc03fd-5b06-4623-adbc-9d3292322efa	c2241423-6f70-4f15-92a9-c4a433dfec70	برنامه‌ریزی مصاحبهٔ استخدامی #63	\N	medium	2026-09-05	af1e0862-ef05-4fd5-8002-5c9b545102aa	2026-07-20 11:46:45.199839+00	2026-07-20 11:46:45.199839+00	completed	approved	100	35.80	2026-08-15
6fa5de46-9edd-404a-915e-89d9f3f21ae7	12b3562f-9b7e-4fd7-b326-d7e733197f75	\N	cd92c461-1da5-4222-b6f0-60ce30f3d910	c2241423-6f70-4f15-92a9-c4a433dfec70	بررسی و تمدید قراردادهای پرسنلی #64	\N	medium	2026-08-24	7f4696e6-d8b6-4bbe-b6bb-88d8f358413a	2026-07-20 11:46:45.199839+00	2026-07-20 11:46:45.199839+00	todo	\N	52	4.10	2026-08-10
6fa5de46-9edd-404a-915e-89d9f3f21ae7	12b3562f-9b7e-4fd7-b326-d7e733197f75	\N	07fc03fd-5b06-4623-adbc-9d3292322efa	c2241423-6f70-4f15-92a9-c4a433dfec70	پیگیری درخواست‌های رفاهی کارکنان #65	\N	medium	2026-07-02	6949c40b-67c4-405d-a8e5-1a76e4864043	2026-07-20 11:46:45.199839+00	2026-07-20 11:46:45.199839+00	todo	\N	72	35.90	2026-06-24
6fa5de46-9edd-404a-915e-89d9f3f21ae7	12b3562f-9b7e-4fd7-b326-d7e733197f75	\N	cf5d8b24-a057-421e-9cc3-b442f742293f	c2241423-6f70-4f15-92a9-c4a433dfec70	برگزاری نظرسنجی رضایت شغلی #66	\N	low	2026-07-13	6b08eccf-74a0-4249-ae12-66cf5c2bf505	2026-07-20 11:46:45.199839+00	2026-07-20 11:46:45.199839+00	todo	\N	62	14.60	2026-07-06
6fa5de46-9edd-404a-915e-89d9f3f21ae7	12b3562f-9b7e-4fd7-b326-d7e733197f75	\N	c700c6fb-ad08-4eaa-9597-f02c27aa0e58	c2241423-6f70-4f15-92a9-c4a433dfec70	بررسی رزومه‌های متقاضیان شغلی #67	\N	medium	2026-07-29	fb625cfb-f135-4530-b1e1-3da74454ae23	2026-07-20 11:46:45.199839+00	2026-07-20 11:46:45.199839+00	in_progress	\N	35	10.00	2026-07-26
6fa5de46-9edd-404a-915e-89d9f3f21ae7	12b3562f-9b7e-4fd7-b326-d7e733197f75	\N	07fc03fd-5b06-4623-adbc-9d3292322efa	c2241423-6f70-4f15-92a9-c4a433dfec70	برنامه‌ریزی رویداد تیم‌سازی #68	\N	low	2026-07-29	ad2b47f0-7b48-4800-a0a9-7c3348cafe10	2026-07-20 11:46:45.199839+00	2026-07-20 11:46:45.199839+00	todo	\N	16	25.40	2026-07-22
6fa5de46-9edd-404a-915e-89d9f3f21ae7	12b3562f-9b7e-4fd7-b326-d7e733197f75	\N	0bf949b7-932b-40ba-8d67-4ea888360556	c2241423-6f70-4f15-92a9-c4a433dfec70	برنامه‌ریزی رویداد تیم‌سازی #69	\N	medium	2026-07-26	501e8a21-b889-4d2a-999d-f0087c0d6c11	2026-07-20 11:46:45.199839+00	2026-07-20 11:46:45.199839+00	in_progress	\N	0	3.40	2026-07-11
6fa5de46-9edd-404a-915e-89d9f3f21ae7	12b3562f-9b7e-4fd7-b326-d7e733197f75	\N	c700c6fb-ad08-4eaa-9597-f02c27aa0e58	c2241423-6f70-4f15-92a9-c4a433dfec70	بررسی درخواست ترفیع کارکنان #70	\N	medium	2026-07-11	299d172c-b55e-4816-9b99-6774a97ff257	2026-07-20 11:46:45.199839+00	2026-07-20 11:46:45.199839+00	archived	\N	67	9.20	2026-07-09
6fa5de46-9edd-404a-915e-89d9f3f21ae7	12b3562f-9b7e-4fd7-b326-d7e733197f75	\N	0bf949b7-932b-40ba-8d67-4ea888360556	c2241423-6f70-4f15-92a9-c4a433dfec70	برگزاری جلسهٔ آموزش کارکنان جدید #71	\N	high	2026-08-04	9d2c3e04-7f61-45e3-aab8-6bc7460416dc	2026-07-20 11:46:45.199839+00	2026-07-20 11:46:45.199839+00	todo	\N	44	13.90	2026-07-26
6fa5de46-9edd-404a-915e-89d9f3f21ae7	12b3562f-9b7e-4fd7-b326-d7e733197f75	\N	c2241423-6f70-4f15-92a9-c4a433dfec70	c2241423-6f70-4f15-92a9-c4a433dfec70	به‌روزرسانی آیین‌نامهٔ داخلی شرکت #72	\N	low	2026-08-07	593373ee-dde5-4cf5-89c8-9805761c391b	2026-07-20 11:46:45.199839+00	2026-07-20 11:46:45.199839+00	in_progress	\N	8	33.30	2026-07-18
6fa5de46-9edd-404a-915e-89d9f3f21ae7	2863ba04-93e9-4609-a47b-9c793b5ff35f	\N	16119c08-e43f-4846-adcd-f77ad1aca132	c2241423-6f70-4f15-92a9-c4a433dfec70	تدوین برنامهٔ آموزشی سال آینده #73	\N	high	2026-08-02	6763cf89-2f64-457d-85f7-057e33bb9204	2026-07-20 11:46:45.199839+00	2026-07-20 11:46:45.199839+00	in_progress	\N	43	18.50	2026-07-15
6fa5de46-9edd-404a-915e-89d9f3f21ae7	2863ba04-93e9-4609-a47b-9c793b5ff35f	\N	0bf949b7-932b-40ba-8d67-4ea888360556	c2241423-6f70-4f15-92a9-c4a433dfec70	پیگیری درخواست‌های رفاهی کارکنان #74	\N	low	2026-07-24	3c5d4535-0918-4686-9892-589c9fcd7c36	2026-07-20 11:46:45.199839+00	2026-07-20 11:46:45.199839+00	todo	\N	21	38.00	2026-07-07
6fa5de46-9edd-404a-915e-89d9f3f21ae7	2863ba04-93e9-4609-a47b-9c793b5ff35f	\N	07fc03fd-5b06-4623-adbc-9d3292322efa	c2241423-6f70-4f15-92a9-c4a433dfec70	برگزاری جلسهٔ آموزش کارکنان جدید #75	\N	high	2026-06-26	e6f414fa-ed51-4895-ba4d-255358ef63cb	2026-07-20 11:46:45.199839+00	2026-07-20 11:46:45.199839+00	in_progress	\N	16	10.00	2026-06-17
6fa5de46-9edd-404a-915e-89d9f3f21ae7	2863ba04-93e9-4609-a47b-9c793b5ff35f	\N	c2241423-6f70-4f15-92a9-c4a433dfec70	c2241423-6f70-4f15-92a9-c4a433dfec70	به‌روزرسانی پروندهٔ پرسنلی #76	\N	high	2026-07-06	16549894-f239-4c74-bd40-a63aff2d7bb3	2026-07-20 11:46:45.199839+00	2026-07-20 11:46:45.199839+00	completed	approved	100	32.10	2026-06-23
6fa5de46-9edd-404a-915e-89d9f3f21ae7	2863ba04-93e9-4609-a47b-9c793b5ff35f	\N	cf5d8b24-a057-421e-9cc3-b442f742293f	c2241423-6f70-4f15-92a9-c4a433dfec70	بررسی رزومه‌های متقاضیان شغلی #77	\N	high	2026-08-10	b3800102-8420-4e55-b6eb-2d7486f33115	2026-07-20 11:46:45.199839+00	2026-07-20 11:46:45.199839+00	completed	approved	100	39.80	2026-07-20
6fa5de46-9edd-404a-915e-89d9f3f21ae7	2863ba04-93e9-4609-a47b-9c793b5ff35f	\N	0bf949b7-932b-40ba-8d67-4ea888360556	c2241423-6f70-4f15-92a9-c4a433dfec70	بررسی رزومه‌های متقاضیان شغلی #78	\N	high	2026-07-29	c681148c-d6ae-4efe-b27e-14337bbc14d5	2026-07-20 11:46:45.199839+00	2026-07-20 11:46:45.199839+00	todo	\N	14	17.80	2026-07-27
6fa5de46-9edd-404a-915e-89d9f3f21ae7	2863ba04-93e9-4609-a47b-9c793b5ff35f	\N	cf5d8b24-a057-421e-9cc3-b442f742293f	c2241423-6f70-4f15-92a9-c4a433dfec70	برنامه‌ریزی رویداد تیم‌سازی #79	\N	high	2026-07-31	820c24e3-af94-42e6-8647-679dbe982010	2026-07-20 11:46:45.199839+00	2026-07-20 11:46:45.199839+00	todo	\N	19	9.80	2026-07-21
6fa5de46-9edd-404a-915e-89d9f3f21ae7	2863ba04-93e9-4609-a47b-9c793b5ff35f	\N	0bf949b7-932b-40ba-8d67-4ea888360556	c2241423-6f70-4f15-92a9-c4a433dfec70	پیگیری مرخصی و مأموریت کارکنان #80	\N	high	2026-07-17	e4e5a794-7c17-4adf-838f-3aa4efb27e70	2026-07-20 11:46:45.199839+00	2026-07-20 11:46:45.199839+00	completed	approved	100	12.30	2026-07-12
6fa5de46-9edd-404a-915e-89d9f3f21ae7	2863ba04-93e9-4609-a47b-9c793b5ff35f	\N	cd92c461-1da5-4222-b6f0-60ce30f3d910	c2241423-6f70-4f15-92a9-c4a433dfec70	بررسی و تمدید قراردادهای پرسنلی #81	\N	high	2026-08-13	f32868a3-318d-4148-9e73-8337e1ed9847	2026-07-20 11:46:45.199839+00	2026-07-20 11:46:45.199839+00	completed	approved	100	25.50	2026-08-08
6fa5de46-9edd-404a-915e-89d9f3f21ae7	2863ba04-93e9-4609-a47b-9c793b5ff35f	\N	16119c08-e43f-4846-adcd-f77ad1aca132	c2241423-6f70-4f15-92a9-c4a433dfec70	برنامه‌ریزی رویداد تیم‌سازی #82	\N	low	2026-08-10	50b96361-1336-45cf-8113-5100fa5b1a01	2026-07-20 11:46:45.199839+00	2026-07-20 11:46:45.199839+00	todo	\N	77	9.60	2026-08-05
6fa5de46-9edd-404a-915e-89d9f3f21ae7	2863ba04-93e9-4609-a47b-9c793b5ff35f	\N	16119c08-e43f-4846-adcd-f77ad1aca132	c2241423-6f70-4f15-92a9-c4a433dfec70	به‌روزرسانی آیین‌نامهٔ داخلی شرکت #83	\N	low	2026-07-23	e06f6c4f-74a2-4bc6-9d32-bfae9dba96cc	2026-07-20 11:46:45.199839+00	2026-07-20 11:46:45.199839+00	completed	rejected	100	3.50	2026-07-08
6fa5de46-9edd-404a-915e-89d9f3f21ae7	2863ba04-93e9-4609-a47b-9c793b5ff35f	\N	cf5d8b24-a057-421e-9cc3-b442f742293f	c2241423-6f70-4f15-92a9-c4a433dfec70	پیگیری درخواست‌های رفاهی کارکنان #84	\N	low	2026-08-16	b5783de0-a460-4ae2-bc85-e09160703a7c	2026-07-20 11:46:45.199839+00	2026-07-20 11:46:45.199839+00	in_progress	\N	0	2.50	2026-07-30
6fa5de46-9edd-404a-915e-89d9f3f21ae7	2863ba04-93e9-4609-a47b-9c793b5ff35f	\N	c2241423-6f70-4f15-92a9-c4a433dfec70	c2241423-6f70-4f15-92a9-c4a433dfec70	پیگیری مرخصی و مأموریت کارکنان #85	\N	medium	2026-08-28	28ac23b6-3f47-48d6-96ec-175596e3f635	2026-07-20 11:46:45.199839+00	2026-07-20 11:46:45.199839+00	todo	\N	19	38.10	2026-08-08
6fa5de46-9edd-404a-915e-89d9f3f21ae7	2863ba04-93e9-4609-a47b-9c793b5ff35f	\N	07fc03fd-5b06-4623-adbc-9d3292322efa	c2241423-6f70-4f15-92a9-c4a433dfec70	بررسی درخواست ترفیع کارکنان #86	\N	medium	2026-08-06	4963422a-4961-4bf3-9f9a-9e92525a8173	2026-07-20 11:46:45.199839+00	2026-07-20 11:46:45.199839+00	completed	approved	100	26.50	2026-08-01
6fa5de46-9edd-404a-915e-89d9f3f21ae7	2863ba04-93e9-4609-a47b-9c793b5ff35f	\N	cf5d8b24-a057-421e-9cc3-b442f742293f	c2241423-6f70-4f15-92a9-c4a433dfec70	بررسی رزومه‌های متقاضیان شغلی #87	\N	low	2026-07-18	9ea8e68b-bb76-478c-a344-033e8127ce4f	2026-07-20 11:46:45.199839+00	2026-07-20 11:46:45.199839+00	in_progress	\N	22	35.20	2026-07-02
6fa5de46-9edd-404a-915e-89d9f3f21ae7	2863ba04-93e9-4609-a47b-9c793b5ff35f	\N	07fc03fd-5b06-4623-adbc-9d3292322efa	c2241423-6f70-4f15-92a9-c4a433dfec70	تهیهٔ فرم ارزیابی سه‌ماهه #88	\N	high	2026-07-21	ebf62f6e-42a8-4bf6-9649-ee92314b80aa	2026-07-20 11:46:45.199839+00	2026-07-20 11:46:45.199839+00	in_progress	\N	14	5.60	2026-07-09
6fa5de46-9edd-404a-915e-89d9f3f21ae7	2863ba04-93e9-4609-a47b-9c793b5ff35f	\N	07fc03fd-5b06-4623-adbc-9d3292322efa	c2241423-6f70-4f15-92a9-c4a433dfec70	پیگیری مرخصی و مأموریت کارکنان #89	\N	high	2026-06-22	ea40c628-c4f5-419a-aae7-62b1da943ebe	2026-07-20 11:46:45.199839+00	2026-07-20 11:46:45.199839+00	todo	\N	21	14.50	2026-06-16
6fa5de46-9edd-404a-915e-89d9f3f21ae7	2863ba04-93e9-4609-a47b-9c793b5ff35f	\N	cf5d8b24-a057-421e-9cc3-b442f742293f	c2241423-6f70-4f15-92a9-c4a433dfec70	پیگیری درخواست‌های رفاهی کارکنان #90	\N	medium	2026-08-05	e9734d4f-8c19-4bae-b0e3-9e0690f80de4	2026-07-20 11:46:45.199839+00	2026-07-20 11:46:45.199839+00	completed	approved	100	8.90	2026-08-01
6fa5de46-9edd-404a-915e-89d9f3f21ae7	\N	\N	cf5d8b24-a057-421e-9cc3-b442f742293f	cf5d8b24-a057-421e-9cc3-b442f742293f	تهیهٔ گزارش غیبت و تأخیر #91	\N	medium	2026-07-25	c5eaa1cf-61b5-439f-929f-f27d880b922a	2026-07-20 11:46:45.199839+00	2026-07-20 11:46:45.199839+00	in_progress	\N	61	32.40	2026-07-15
6fa5de46-9edd-404a-915e-89d9f3f21ae7	\N	\N	0bf949b7-932b-40ba-8d67-4ea888360556	0bf949b7-932b-40ba-8d67-4ea888360556	به‌روزرسانی پروندهٔ پرسنلی #92	\N	high	2026-06-29	a16e0399-b8e0-4019-a2fa-b36352e6df38	2026-07-20 11:46:45.199839+00	2026-07-20 11:46:45.199839+00	todo	\N	7	39.30	2026-06-23
6fa5de46-9edd-404a-915e-89d9f3f21ae7	\N	\N	07fc03fd-5b06-4623-adbc-9d3292322efa	07fc03fd-5b06-4623-adbc-9d3292322efa	بررسی درخواست ترفیع کارکنان #93	\N	high	2026-07-07	21492a75-21f6-4601-8552-9f990dcb90b1	2026-07-20 11:46:45.199839+00	2026-07-20 11:46:45.199839+00	todo	\N	61	32.50	2026-06-22
6fa5de46-9edd-404a-915e-89d9f3f21ae7	\N	\N	0bf949b7-932b-40ba-8d67-4ea888360556	0bf949b7-932b-40ba-8d67-4ea888360556	تدوین برنامهٔ آموزشی سال آینده #94	\N	low	2026-07-23	5c8b8e01-4630-4dd2-852c-de717b3c97b8	2026-07-20 11:46:45.199839+00	2026-07-20 11:46:45.199839+00	completed	approved	100	34.80	2026-07-10
6fa5de46-9edd-404a-915e-89d9f3f21ae7	\N	\N	07fc03fd-5b06-4623-adbc-9d3292322efa	07fc03fd-5b06-4623-adbc-9d3292322efa	برنامه‌ریزی رویداد تیم‌سازی #95	\N	medium	2026-08-18	72e247e3-8d8c-4b08-8dc4-0f11a0178b24	2026-07-20 11:46:45.199839+00	2026-07-20 11:46:45.199839+00	archived	\N	14	35.70	2026-08-12
6fa5de46-9edd-404a-915e-89d9f3f21ae7	\N	\N	cf5d8b24-a057-421e-9cc3-b442f742293f	cf5d8b24-a057-421e-9cc3-b442f742293f	پیگیری مرخصی و مأموریت کارکنان #96	\N	medium	2026-06-30	5ee099b4-3a04-47a5-aa77-4d5ccc3bde5d	2026-07-20 11:46:45.199839+00	2026-07-20 11:46:45.199839+00	todo	\N	1	28.80	2026-06-20
6fa5de46-9edd-404a-915e-89d9f3f21ae7	\N	\N	0bf949b7-932b-40ba-8d67-4ea888360556	0bf949b7-932b-40ba-8d67-4ea888360556	برگزاری جلسهٔ آموزش کارکنان جدید #97	\N	high	2026-08-11	67e2307f-723c-4d2c-8e8d-d8be12b379a5	2026-07-20 11:46:45.199839+00	2026-07-20 11:46:45.199839+00	completed	pending	100	35.20	2026-07-22
6fa5de46-9edd-404a-915e-89d9f3f21ae7	\N	\N	cd92c461-1da5-4222-b6f0-60ce30f3d910	cd92c461-1da5-4222-b6f0-60ce30f3d910	تهیهٔ فرم ارزیابی سه‌ماهه #98	\N	high	2026-07-30	2fe373b3-4214-4cd1-9522-337ef41ecf63	2026-07-20 11:46:45.199839+00	2026-07-20 11:46:45.199839+00	completed	pending	100	29.60	2026-07-25
6fa5de46-9edd-404a-915e-89d9f3f21ae7	\N	\N	cf5d8b24-a057-421e-9cc3-b442f742293f	cf5d8b24-a057-421e-9cc3-b442f742293f	تهیهٔ گزارش ارزیابی عملکرد #99	\N	high	2026-08-11	07ee2585-20d1-4625-afde-bfe2a96892a9	2026-07-20 11:46:45.199839+00	2026-07-20 11:46:45.199839+00	in_progress	\N	78	4.10	2026-07-28
6fa5de46-9edd-404a-915e-89d9f3f21ae7	\N	\N	0bf949b7-932b-40ba-8d67-4ea888360556	0bf949b7-932b-40ba-8d67-4ea888360556	تهیهٔ گزارش غیبت و تأخیر #100	\N	medium	2026-08-04	40065e3a-6da2-428b-8438-52fe7da7b7a1	2026-07-20 11:46:45.199839+00	2026-07-20 11:46:45.199839+00	todo	\N	21	4.80	2026-07-18
6fa5de46-9edd-404a-915e-89d9f3f21ae7	\N	\N	cf5d8b24-a057-421e-9cc3-b442f742293f	cf5d8b24-a057-421e-9cc3-b442f742293f	به‌روزرسانی آیین‌نامهٔ داخلی شرکت #101	\N	low	2026-07-13	487a4d5e-719f-4e10-9f6b-2282885d3b95	2026-07-20 11:46:45.199839+00	2026-07-20 11:46:45.199839+00	in_progress	\N	64	10.50	2026-07-01
6fa5de46-9edd-404a-915e-89d9f3f21ae7	\N	\N	0bf949b7-932b-40ba-8d67-4ea888360556	0bf949b7-932b-40ba-8d67-4ea888360556	برنامه‌ریزی مصاحبهٔ استخدامی #102	\N	medium	2026-07-20	7aca59ad-56e2-4658-bfd6-85937054408d	2026-07-20 11:46:45.199839+00	2026-07-20 11:46:45.199839+00	in_progress	\N	56	32.40	2026-07-11
6fa5de46-9edd-404a-915e-89d9f3f21ae7	\N	\N	cf5d8b24-a057-421e-9cc3-b442f742293f	cf5d8b24-a057-421e-9cc3-b442f742293f	برنامه‌ریزی رویداد تیم‌سازی #103	\N	medium	2026-08-26	ac57a07b-9bec-4ec6-a23b-1a53db3045d6	2026-07-20 11:46:45.199839+00	2026-07-20 11:46:45.199839+00	todo	\N	15	39.30	2026-08-09
6fa5de46-9edd-404a-915e-89d9f3f21ae7	\N	\N	0bf949b7-932b-40ba-8d67-4ea888360556	0bf949b7-932b-40ba-8d67-4ea888360556	بررسی رزومه‌های متقاضیان شغلی #104	\N	high	2026-07-26	ba4025c1-08a4-4489-9ee3-ee4159eb3882	2026-07-20 11:46:45.199839+00	2026-07-20 11:46:45.199839+00	completed	approved	100	22.90	2026-07-11
6fa5de46-9edd-404a-915e-89d9f3f21ae7	\N	\N	07fc03fd-5b06-4623-adbc-9d3292322efa	07fc03fd-5b06-4623-adbc-9d3292322efa	تدوین برنامهٔ آموزشی سال آینده #105	\N	high	2026-08-26	c10af4f1-cec2-4f4d-a0e0-01f17e71c6dc	2026-07-20 11:46:45.199839+00	2026-07-20 11:46:45.199839+00	todo	\N	38	35.80	2026-08-05
\.


--
-- Data for Name: users; Type: TABLE DATA; Schema: public; Owner: -
--

COPY public.users (organization_id, email, hashed_password, full_name, role, is_active, id, created_at, updated_at, phone_number, department_id) FROM stdin;
6fa5de46-9edd-404a-915e-89d9f3f21ae7	admin@test.local	$2b$12$gr72D7n0ulz3d.q6l9AnX.ZdmtfVuoY8Pb3pWP/MqOimgADIr6uP.	مدیر سازمان	org_admin	t	17797748-c29a-4be6-a26c-3b13a6d22c31	2026-07-20 11:46:45.199839+00	2026-07-20 11:46:45.199839+00	09100000001	a5170653-16f8-45a8-8ab3-21c8f3d3557e
6fa5de46-9edd-404a-915e-89d9f3f21ae7	eng.manager@test.local	$2b$12$jwvrgzJJQgHhR8Gkb8Ofm.w0v6JD8CebX5wNWnvabR/rR6V6UIHCC	مدیر پروژه مهندسی و فنی	project_manager	t	6367109c-4684-4a1b-a6b5-9843aa3f6a9d	2026-07-20 11:46:45.199839+00	2026-07-20 11:46:45.199839+00	09111000000	a5170653-16f8-45a8-8ab3-21c8f3d3557e
6fa5de46-9edd-404a-915e-89d9f3f21ae7	eng.emp1@test.local	$2b$12$U2cijAElKz.CV5ghhy84gepAYFSRSUX1ZBVmRUNowvWOSWde9rDLy	کارمند 1 مهندسی و فنی	employee	t	7c364485-75f2-4d57-81ee-62ec42c62177	2026-07-20 11:46:45.199839+00	2026-07-20 11:46:45.199839+00	09111000011	a5170653-16f8-45a8-8ab3-21c8f3d3557e
6fa5de46-9edd-404a-915e-89d9f3f21ae7	eng.emp2@test.local	$2b$12$fBHDhTuMXhfTyi56YPnfyeOHu0kQjGj5t20CIBCJaGK7U9W.9VHkG	کارمند 2 مهندسی و فنی	employee	t	398f8c1c-1d8b-48eb-9aed-08ebb479cff3	2026-07-20 11:46:45.199839+00	2026-07-20 11:46:45.199839+00	09111000012	a5170653-16f8-45a8-8ab3-21c8f3d3557e
6fa5de46-9edd-404a-915e-89d9f3f21ae7	eng.emp3@test.local	$2b$12$koYNgBKj5m.8Q8U5frNYC..jqZTehSooETc0DsbnIJUQ2oiTT75xS	کارمند 3 مهندسی و فنی	employee	t	3051f03b-e73a-49fb-a6d2-ab7406c6850b	2026-07-20 11:46:45.199839+00	2026-07-20 11:46:45.199839+00	09111000013	a5170653-16f8-45a8-8ab3-21c8f3d3557e
6fa5de46-9edd-404a-915e-89d9f3f21ae7	eng.emp4@test.local	$2b$12$3fTvcYmMzymdCXGVU16Efu4bUcrzMSXyHXies3bGMTadz0YmltdLi	کارمند 4 مهندسی و فنی	employee	t	a42bd423-3577-42e0-b239-611eb7480fb9	2026-07-20 11:46:45.199839+00	2026-07-20 11:46:45.199839+00	09111000014	a5170653-16f8-45a8-8ab3-21c8f3d3557e
6fa5de46-9edd-404a-915e-89d9f3f21ae7	eng.emp5@test.local	$2b$12$shXN9WaAT1wLah7/RS.YLONRPhV6l6gOH26WhAX0l0pc9/hBibLIq	کارمند 5 مهندسی و فنی	employee	t	fd5161f1-4abf-4cc9-8f06-914566393088	2026-07-20 11:46:45.199839+00	2026-07-20 11:46:45.199839+00	09111000015	a5170653-16f8-45a8-8ab3-21c8f3d3557e
6fa5de46-9edd-404a-915e-89d9f3f21ae7	eng.emp6@test.local	$2b$12$7wZDphn6Qi92oZfffFScveVkIyvZ2wyw.AGrr0SFq69hBjP54.Qjm	کارمند 6 مهندسی و فنی	employee	t	a34644cb-4fa6-4ad1-904f-3e26b23679cd	2026-07-20 11:46:45.199839+00	2026-07-20 11:46:45.199839+00	09111000016	a5170653-16f8-45a8-8ab3-21c8f3d3557e
6fa5de46-9edd-404a-915e-89d9f3f21ae7	fin.manager@test.local	$2b$12$HeuDtJXZ1lgVAPj7/.vkauI/nf7dRxweojAZu.aJdPYJHeFpXWcyi	مدیر پروژه حسابداری و مالی	project_manager	t	6f0889c3-21cf-4af8-92e8-834e06a4a09c	2026-07-20 11:46:45.199839+00	2026-07-20 11:46:45.199839+00	09121000100	e2331c94-951e-48e2-b9df-95c0b3ba5e4b
6fa5de46-9edd-404a-915e-89d9f3f21ae7	fin.emp1@test.local	$2b$12$R6kSLFPcDk34xQmS8Yit9OYcsmAj31npao1I51JYw8h4aloNZ83Hq	کارمند 1 حسابداری و مالی	employee	t	9255642c-40dc-467b-8897-f23fd07f2394	2026-07-20 11:46:45.199839+00	2026-07-20 11:46:45.199839+00	09121000111	e2331c94-951e-48e2-b9df-95c0b3ba5e4b
6fa5de46-9edd-404a-915e-89d9f3f21ae7	fin.emp2@test.local	$2b$12$Shrjczin44lAATnpi5usm.RkOjCsSDKD/JV6kJwwtb2UrDGof36m6	کارمند 2 حسابداری و مالی	employee	t	eeebc2e6-a734-4f02-8d65-173ba01323d3	2026-07-20 11:46:45.199839+00	2026-07-20 11:46:45.199839+00	09121000112	e2331c94-951e-48e2-b9df-95c0b3ba5e4b
6fa5de46-9edd-404a-915e-89d9f3f21ae7	fin.emp3@test.local	$2b$12$4AASKRns6v1gof.gd0nGNeXV8h/XExYGSZk.DAD1xfgvYJof3aMJC	کارمند 3 حسابداری و مالی	employee	t	56ee4c58-1504-48a5-b37d-7d040bb2bd16	2026-07-20 11:46:45.199839+00	2026-07-20 11:46:45.199839+00	09121000113	e2331c94-951e-48e2-b9df-95c0b3ba5e4b
6fa5de46-9edd-404a-915e-89d9f3f21ae7	fin.emp4@test.local	$2b$12$0NuEjc.k9zaolNcLTn7IDeTaH6e9e73GpJgRGjV9BZKzCX9kY0rfK	کارمند 4 حسابداری و مالی	employee	t	3cba84f1-51a4-4831-ac2b-61b820a1122a	2026-07-20 11:46:45.199839+00	2026-07-20 11:46:45.199839+00	09121000114	e2331c94-951e-48e2-b9df-95c0b3ba5e4b
6fa5de46-9edd-404a-915e-89d9f3f21ae7	fin.emp5@test.local	$2b$12$wTgreP90xj5Uv5k5TB5qmeQeK3kx5NgwoWmzAo3VDF0bxk31UhY9i	کارمند 5 حسابداری و مالی	employee	t	ca92a9d5-cf4a-4b8b-9fe5-6fadd5c44ca2	2026-07-20 11:46:45.199839+00	2026-07-20 11:46:45.199839+00	09121000115	e2331c94-951e-48e2-b9df-95c0b3ba5e4b
6fa5de46-9edd-404a-915e-89d9f3f21ae7	fin.emp6@test.local	$2b$12$lJng/m5xrXVZDm6ycDA7yO46SUEB6WKrSWi4VVOPreChTs51X.DjO	کارمند 6 حسابداری و مالی	employee	t	c28803c6-5155-4136-94b4-4f91ec6ee698	2026-07-20 11:46:45.199839+00	2026-07-20 11:46:45.199839+00	09121000116	e2331c94-951e-48e2-b9df-95c0b3ba5e4b
6fa5de46-9edd-404a-915e-89d9f3f21ae7	hr.manager@test.local	$2b$12$fgH6g.3kXKhe8f1bSIMYhe9KGkaUSh7V7lLMKOI5TjUrY0vGVNxD2	مدیر پروژه منابع انسانی	project_manager	t	c2241423-6f70-4f15-92a9-c4a433dfec70	2026-07-20 11:46:45.199839+00	2026-07-20 11:46:45.199839+00	09131000200	571b9f1d-680e-45b9-b80e-18f6904a83bc
6fa5de46-9edd-404a-915e-89d9f3f21ae7	hr.emp1@test.local	$2b$12$FWd/j7ZIbRfP8LbRSQDQx.5tq6/RzOI5PW1QPqkMF5qKjry3baUDq	کارمند 1 منابع انسانی	employee	t	c700c6fb-ad08-4eaa-9597-f02c27aa0e58	2026-07-20 11:46:45.199839+00	2026-07-20 11:46:45.199839+00	09131000211	571b9f1d-680e-45b9-b80e-18f6904a83bc
6fa5de46-9edd-404a-915e-89d9f3f21ae7	hr.emp2@test.local	$2b$12$U5iJhnj2BH81fxNoaj1OL.VnauQP/.4H6VkXYaEhk4XdD6pcByJp.	کارمند 2 منابع انسانی	employee	t	16119c08-e43f-4846-adcd-f77ad1aca132	2026-07-20 11:46:45.199839+00	2026-07-20 11:46:45.199839+00	09131000212	571b9f1d-680e-45b9-b80e-18f6904a83bc
6fa5de46-9edd-404a-915e-89d9f3f21ae7	hr.emp3@test.local	$2b$12$9gb87YyVbzKlD2DaegcuNOMx7cWwV3TXdp4RWxlX03pm2AcVgf93m	کارمند 3 منابع انسانی	employee	t	cf5d8b24-a057-421e-9cc3-b442f742293f	2026-07-20 11:46:45.199839+00	2026-07-20 11:46:45.199839+00	09131000213	571b9f1d-680e-45b9-b80e-18f6904a83bc
6fa5de46-9edd-404a-915e-89d9f3f21ae7	hr.emp4@test.local	$2b$12$RXK/ipLGVyy9Q1hOdpzHmuPlvw3NJ/0bP2pP.EkgfZHHYNIaMpBCy	کارمند 4 منابع انسانی	employee	t	cd92c461-1da5-4222-b6f0-60ce30f3d910	2026-07-20 11:46:45.199839+00	2026-07-20 11:46:45.199839+00	09131000214	571b9f1d-680e-45b9-b80e-18f6904a83bc
6fa5de46-9edd-404a-915e-89d9f3f21ae7	hr.emp5@test.local	$2b$12$FcksfoH/SkGBYTGuUoBDY.wrh0W31QZECsXoXrBGDa9EJmqK3Bngu	کارمند 5 منابع انسانی	employee	t	0bf949b7-932b-40ba-8d67-4ea888360556	2026-07-20 11:46:45.199839+00	2026-07-20 11:46:45.199839+00	09131000215	571b9f1d-680e-45b9-b80e-18f6904a83bc
6fa5de46-9edd-404a-915e-89d9f3f21ae7	hr.emp6@test.local	$2b$12$FYJZmYSDZAU9ZXha7GKPv.5ahybIRRCm0pkTPHMUf5IDhIbHfy48q	کارمند 6 منابع انسانی	employee	t	07fc03fd-5b06-4623-adbc-9d3292322efa	2026-07-20 11:46:45.199839+00	2026-07-20 11:46:45.199839+00	09131000216	571b9f1d-680e-45b9-b80e-18f6904a83bc
\.


--
-- Data for Name: worklogs; Type: TABLE DATA; Schema: public; Owner: -
--

COPY public.worklogs (organization_id, task_id, user_id, activity_description, time_spent_minutes, progress_percent, log_date, status, reviewed_by_id, review_comment, id, created_at, updated_at) FROM stdin;
6fa5de46-9edd-404a-915e-89d9f3f21ae7	4ce6036e-f3a0-47e0-82ad-455206cc474a	a42bd423-3577-42e0-b239-611eb7480fb9	مستندسازی و نهایی‌سازی	118	33	2026-07-16	approved	6367109c-4684-4a1b-a6b5-9843aa3f6a9d	\N	173627c9-313f-480b-959e-987e895eed10	2026-07-20 11:46:45.199839+00	2026-07-20 11:46:45.199839+00
6fa5de46-9edd-404a-915e-89d9f3f21ae7	4ce6036e-f3a0-47e0-82ad-455206cc474a	a42bd423-3577-42e0-b239-611eb7480fb9	تست و اطمینان از عملکرد صحیح	99	58	2026-07-16	approved	6367109c-4684-4a1b-a6b5-9843aa3f6a9d	\N	8ce74b3a-c63e-49d5-9ae2-c9eaca65dd58	2026-07-20 11:46:45.199839+00	2026-07-20 11:46:45.199839+00
6fa5de46-9edd-404a-915e-89d9f3f21ae7	4ce6036e-f3a0-47e0-82ad-455206cc474a	a42bd423-3577-42e0-b239-611eb7480fb9	پیاده‌سازی بخش اصلی	110	69	2026-07-16	approved	6367109c-4684-4a1b-a6b5-9843aa3f6a9d	\N	ee404bd3-db8f-4596-8d72-c99dac3ca541	2026-07-20 11:46:45.199839+00	2026-07-20 11:46:45.199839+00
6fa5de46-9edd-404a-915e-89d9f3f21ae7	cafd49a1-10e0-4931-8095-7723d3410744	7c364485-75f2-4d57-81ee-62ec42c62177	تست و اطمینان از عملکرد صحیح	100	38	2026-07-16	approved	6367109c-4684-4a1b-a6b5-9843aa3f6a9d	\N	ccd1e44d-2ed7-43b6-bf25-4c71671471f0	2026-07-20 11:46:45.199839+00	2026-07-20 11:46:45.199839+00
6fa5de46-9edd-404a-915e-89d9f3f21ae7	cafd49a1-10e0-4931-8095-7723d3410744	7c364485-75f2-4d57-81ee-62ec42c62177	پیاده‌سازی بخش اصلی	105	54	2026-07-16	submitted	\N	\N	42bb190b-49cd-4516-943d-a9f099a7ef01	2026-07-20 11:46:45.199839+00	2026-07-20 11:46:45.199839+00
6fa5de46-9edd-404a-915e-89d9f3f21ae7	4007d8ed-236a-45cc-96b9-67fa88e5622a	a34644cb-4fa6-4ad1-904f-3e26b23679cd	مستندسازی و نهایی‌سازی	62	28	2026-07-16	approved	6367109c-4684-4a1b-a6b5-9843aa3f6a9d	\N	b2f82267-3ce5-45a1-9272-8743c8d7c01f	2026-07-20 11:46:45.199839+00	2026-07-20 11:46:45.199839+00
6fa5de46-9edd-404a-915e-89d9f3f21ae7	4007d8ed-236a-45cc-96b9-67fa88e5622a	a34644cb-4fa6-4ad1-904f-3e26b23679cd	مستندسازی و نهایی‌سازی	104	48	2026-07-16	submitted	\N	\N	9c3c3b7c-8ea8-4233-a3d9-82747e1d23dc	2026-07-20 11:46:45.199839+00	2026-07-20 11:46:45.199839+00
6fa5de46-9edd-404a-915e-89d9f3f21ae7	4007d8ed-236a-45cc-96b9-67fa88e5622a	a34644cb-4fa6-4ad1-904f-3e26b23679cd	پیشرفت اولیه و بررسی نیازمندی‌ها	176	87	2026-07-16	approved	6367109c-4684-4a1b-a6b5-9843aa3f6a9d	\N	86bd6add-0ede-4c0f-908b-c062fe8a19cb	2026-07-20 11:46:45.199839+00	2026-07-20 11:46:45.199839+00
6fa5de46-9edd-404a-915e-89d9f3f21ae7	9076222c-1351-4727-9b75-f8f7c8654de1	398f8c1c-1d8b-48eb-9aed-08ebb479cff3	تست و اطمینان از عملکرد صحیح	117	25	2026-06-20	approved	6367109c-4684-4a1b-a6b5-9843aa3f6a9d	\N	a7855d29-13ed-4954-910c-a9ee199e2fd1	2026-07-20 11:46:45.199839+00	2026-07-20 11:46:45.199839+00
6fa5de46-9edd-404a-915e-89d9f3f21ae7	9076222c-1351-4727-9b75-f8f7c8654de1	398f8c1c-1d8b-48eb-9aed-08ebb479cff3	رفع اشکالات و بازبینی	152	46	2026-06-21	approved	6367109c-4684-4a1b-a6b5-9843aa3f6a9d	\N	bd2da2fe-5690-48ad-82eb-fac302332bba	2026-07-20 11:46:45.199839+00	2026-07-20 11:46:45.199839+00
6fa5de46-9edd-404a-915e-89d9f3f21ae7	9076222c-1351-4727-9b75-f8f7c8654de1	398f8c1c-1d8b-48eb-9aed-08ebb479cff3	تست و اطمینان از عملکرد صحیح	155	66	2026-06-22	approved	6367109c-4684-4a1b-a6b5-9843aa3f6a9d	\N	286de10d-e0c3-4448-992f-31acd627b2a3	2026-07-20 11:46:45.199839+00	2026-07-20 11:46:45.199839+00
6fa5de46-9edd-404a-915e-89d9f3f21ae7	9076222c-1351-4727-9b75-f8f7c8654de1	398f8c1c-1d8b-48eb-9aed-08ebb479cff3	پیاده‌سازی بخش اصلی	68	100	2026-06-23	approved	6367109c-4684-4a1b-a6b5-9843aa3f6a9d	\N	5813ee87-fe2d-4437-869d-6c7833d6986a	2026-07-20 11:46:45.199839+00	2026-07-20 11:46:45.199839+00
6fa5de46-9edd-404a-915e-89d9f3f21ae7	3757a60a-c298-4f9c-8797-b740ea859539	6367109c-4684-4a1b-a6b5-9843aa3f6a9d	پیشرفت اولیه و بررسی نیازمندی‌ها	172	33	2026-07-16	submitted	\N	\N	2891fccf-29c1-4ddd-83ae-a6a7bcacea59	2026-07-20 11:46:45.199839+00	2026-07-20 11:46:45.199839+00
6fa5de46-9edd-404a-915e-89d9f3f21ae7	3757a60a-c298-4f9c-8797-b740ea859539	6367109c-4684-4a1b-a6b5-9843aa3f6a9d	تست و اطمینان از عملکرد صحیح	145	68	2026-07-16	submitted	\N	\N	0e9dd48c-7fda-4b89-8784-c01e700ba5b6	2026-07-20 11:46:45.199839+00	2026-07-20 11:46:45.199839+00
6fa5de46-9edd-404a-915e-89d9f3f21ae7	3757a60a-c298-4f9c-8797-b740ea859539	6367109c-4684-4a1b-a6b5-9843aa3f6a9d	تست و اطمینان از عملکرد صحیح	108	100	2026-07-16	submitted	\N	\N	d6c21aab-7f2c-4b83-a678-3d5cbc1e0e0a	2026-07-20 11:46:45.199839+00	2026-07-20 11:46:45.199839+00
6fa5de46-9edd-404a-915e-89d9f3f21ae7	edd9304c-e9ad-45e5-97ca-7f66149348de	fd5161f1-4abf-4cc9-8f06-914566393088	پیاده‌سازی بخش اصلی	190	26	2026-07-16	approved	6367109c-4684-4a1b-a6b5-9843aa3f6a9d	\N	4e49703d-25f9-4047-a55b-f299e423c6d7	2026-07-20 11:46:45.199839+00	2026-07-20 11:46:45.199839+00
6fa5de46-9edd-404a-915e-89d9f3f21ae7	046c72a5-4fe6-4300-b464-bc9d49bebea7	3051f03b-e73a-49fb-a6d2-ab7406c6850b	پیاده‌سازی بخش اصلی	171	22	2026-07-03	approved	6367109c-4684-4a1b-a6b5-9843aa3f6a9d	\N	5e8dd219-eeef-4d8b-853b-bd455b888e48	2026-07-20 11:46:45.199839+00	2026-07-20 11:46:45.199839+00
6fa5de46-9edd-404a-915e-89d9f3f21ae7	046c72a5-4fe6-4300-b464-bc9d49bebea7	3051f03b-e73a-49fb-a6d2-ab7406c6850b	تست و اطمینان از عملکرد صحیح	206	78	2026-07-05	approved	6367109c-4684-4a1b-a6b5-9843aa3f6a9d	\N	8274be33-7ac8-4f2b-aa2f-fe4158665b1f	2026-07-20 11:46:45.199839+00	2026-07-20 11:46:45.199839+00
6fa5de46-9edd-404a-915e-89d9f3f21ae7	046c72a5-4fe6-4300-b464-bc9d49bebea7	3051f03b-e73a-49fb-a6d2-ab7406c6850b	پیاده‌سازی بخش اصلی	103	87	2026-07-11	approved	6367109c-4684-4a1b-a6b5-9843aa3f6a9d	\N	4d4fdea6-e07b-4a47-8efb-93b57f631df0	2026-07-20 11:46:45.199839+00	2026-07-20 11:46:45.199839+00
6fa5de46-9edd-404a-915e-89d9f3f21ae7	1dcc82ac-67c1-4169-b6f7-4a2f2e331502	7c364485-75f2-4d57-81ee-62ec42c62177	پیاده‌سازی بخش اصلی	97	40	2026-07-06	approved	6367109c-4684-4a1b-a6b5-9843aa3f6a9d	\N	add0b89f-568f-4520-90f7-709c450dfbeb	2026-07-20 11:46:45.199839+00	2026-07-20 11:46:45.199839+00
6fa5de46-9edd-404a-915e-89d9f3f21ae7	1dcc82ac-67c1-4169-b6f7-4a2f2e331502	7c364485-75f2-4d57-81ee-62ec42c62177	تست و اطمینان از عملکرد صحیح	59	74	2026-07-08	approved	6367109c-4684-4a1b-a6b5-9843aa3f6a9d	\N	4636fd56-787c-46d3-8994-35415df731ba	2026-07-20 11:46:45.199839+00	2026-07-20 11:46:45.199839+00
6fa5de46-9edd-404a-915e-89d9f3f21ae7	1dcc82ac-67c1-4169-b6f7-4a2f2e331502	7c364485-75f2-4d57-81ee-62ec42c62177	پیاده‌سازی بخش اصلی	98	72	2026-07-10	approved	6367109c-4684-4a1b-a6b5-9843aa3f6a9d	\N	7d4035fc-34d6-4f79-8565-a2c5b146066e	2026-07-20 11:46:45.199839+00	2026-07-20 11:46:45.199839+00
6fa5de46-9edd-404a-915e-89d9f3f21ae7	1dcc82ac-67c1-4169-b6f7-4a2f2e331502	7c364485-75f2-4d57-81ee-62ec42c62177	پیشرفت اولیه و بررسی نیازمندی‌ها	72	100	2026-07-09	approved	6367109c-4684-4a1b-a6b5-9843aa3f6a9d	\N	a539e707-7a39-4e5d-8798-6b91316d21b8	2026-07-20 11:46:45.199839+00	2026-07-20 11:46:45.199839+00
6fa5de46-9edd-404a-915e-89d9f3f21ae7	ad1c23e6-a53c-49f9-b85c-36fac1ed4e97	fd5161f1-4abf-4cc9-8f06-914566393088	پیشرفت اولیه و بررسی نیازمندی‌ها	149	29	2026-06-24	approved	6367109c-4684-4a1b-a6b5-9843aa3f6a9d	\N	7642563d-f59e-439b-9361-57a16eabbde3	2026-07-20 11:46:45.199839+00	2026-07-20 11:46:45.199839+00
6fa5de46-9edd-404a-915e-89d9f3f21ae7	ad1c23e6-a53c-49f9-b85c-36fac1ed4e97	fd5161f1-4abf-4cc9-8f06-914566393088	رفع اشکالات و بازبینی	158	74	2026-06-28	approved	6367109c-4684-4a1b-a6b5-9843aa3f6a9d	\N	a2c1bfa3-4ea6-454f-93da-984576ad6f65	2026-07-20 11:46:45.199839+00	2026-07-20 11:46:45.199839+00
6fa5de46-9edd-404a-915e-89d9f3f21ae7	ad1c23e6-a53c-49f9-b85c-36fac1ed4e97	fd5161f1-4abf-4cc9-8f06-914566393088	تست و اطمینان از عملکرد صحیح	50	100	2026-07-02	approved	6367109c-4684-4a1b-a6b5-9843aa3f6a9d	\N	072dd822-3436-44c5-8e3a-8995c321cea7	2026-07-20 11:46:45.199839+00	2026-07-20 11:46:45.199839+00
6fa5de46-9edd-404a-915e-89d9f3f21ae7	4aeaf774-85bb-4399-8efb-cd55d3b0feaf	fd5161f1-4abf-4cc9-8f06-914566393088	رفع اشکالات و بازبینی	184	28	2026-07-16	approved	6367109c-4684-4a1b-a6b5-9843aa3f6a9d	\N	d61eafbd-8514-4262-914d-c63e166aca9c	2026-07-20 11:46:45.199839+00	2026-07-20 11:46:45.199839+00
6fa5de46-9edd-404a-915e-89d9f3f21ae7	4ae2f1d0-ed28-4c07-82ac-3f4ddaaf6945	7c364485-75f2-4d57-81ee-62ec42c62177	پیاده‌سازی بخش اصلی	202	38	2026-07-16	approved	6367109c-4684-4a1b-a6b5-9843aa3f6a9d	\N	d441e318-e349-4bc8-98b3-f98a90344e54	2026-07-20 11:46:45.199839+00	2026-07-20 11:46:45.199839+00
6fa5de46-9edd-404a-915e-89d9f3f21ae7	6dd96452-dbbd-43a5-a522-544093a832f2	7c364485-75f2-4d57-81ee-62ec42c62177	مستندسازی و نهایی‌سازی	40	25	2026-06-20	approved	6367109c-4684-4a1b-a6b5-9843aa3f6a9d	\N	59db7602-e609-4f21-b90b-a0ee347a8e99	2026-07-20 11:46:45.199839+00	2026-07-20 11:46:45.199839+00
6fa5de46-9edd-404a-915e-89d9f3f21ae7	ddc02e4f-2e48-48a1-aebe-4dfd228dc20c	a42bd423-3577-42e0-b239-611eb7480fb9	پیاده‌سازی بخش اصلی	179	33	2026-07-16	submitted	\N	\N	6adced0c-bb67-4b22-9a57-b0413534eb7f	2026-07-20 11:46:45.199839+00	2026-07-20 11:46:45.199839+00
6fa5de46-9edd-404a-915e-89d9f3f21ae7	ddc02e4f-2e48-48a1-aebe-4dfd228dc20c	a42bd423-3577-42e0-b239-611eb7480fb9	تست و اطمینان از عملکرد صحیح	119	66	2026-07-16	submitted	\N	\N	2abff1f7-0eb8-4535-be2f-6c0c7955c58b	2026-07-20 11:46:45.199839+00	2026-07-20 11:46:45.199839+00
6fa5de46-9edd-404a-915e-89d9f3f21ae7	ddc02e4f-2e48-48a1-aebe-4dfd228dc20c	a42bd423-3577-42e0-b239-611eb7480fb9	پیشرفت اولیه و بررسی نیازمندی‌ها	71	90	2026-07-16	approved	6367109c-4684-4a1b-a6b5-9843aa3f6a9d	\N	b664c912-84a4-4c62-ae05-7dfa4d9ec105	2026-07-20 11:46:45.199839+00	2026-07-20 11:46:45.199839+00
6fa5de46-9edd-404a-915e-89d9f3f21ae7	ddc02e4f-2e48-48a1-aebe-4dfd228dc20c	a42bd423-3577-42e0-b239-611eb7480fb9	رفع اشکالات و بازبینی	199	100	2026-07-16	approved	6367109c-4684-4a1b-a6b5-9843aa3f6a9d	\N	2e2b9aa5-b4ed-4156-8fe9-8d5a56546f1b	2026-07-20 11:46:45.199839+00	2026-07-20 11:46:45.199839+00
6fa5de46-9edd-404a-915e-89d9f3f21ae7	ab8a62be-cb91-4a0b-a863-48375adf3f65	a42bd423-3577-42e0-b239-611eb7480fb9	پیشرفت اولیه و بررسی نیازمندی‌ها	110	28	2026-07-03	approved	6367109c-4684-4a1b-a6b5-9843aa3f6a9d	\N	29170d33-2ebc-479d-b3e5-0eaaf392b2a5	2026-07-20 11:46:45.199839+00	2026-07-20 11:46:45.199839+00
6fa5de46-9edd-404a-915e-89d9f3f21ae7	dd33859a-239b-475b-a1d2-2dd4b2581969	6367109c-4684-4a1b-a6b5-9843aa3f6a9d	تست و اطمینان از عملکرد صحیح	161	20	2026-07-16	approved	6367109c-4684-4a1b-a6b5-9843aa3f6a9d	\N	2bcd1656-a9a8-4b75-b269-cd3638336fdf	2026-07-20 11:46:45.199839+00	2026-07-20 11:46:45.199839+00
6fa5de46-9edd-404a-915e-89d9f3f21ae7	dd33859a-239b-475b-a1d2-2dd4b2581969	6367109c-4684-4a1b-a6b5-9843aa3f6a9d	تست و اطمینان از عملکرد صحیح	43	52	2026-07-16	approved	6367109c-4684-4a1b-a6b5-9843aa3f6a9d	\N	629a058d-6e1f-492c-9178-5f5e96ba84ce	2026-07-20 11:46:45.199839+00	2026-07-20 11:46:45.199839+00
6fa5de46-9edd-404a-915e-89d9f3f21ae7	dd33859a-239b-475b-a1d2-2dd4b2581969	6367109c-4684-4a1b-a6b5-9843aa3f6a9d	مستندسازی و نهایی‌سازی	223	100	2026-07-16	approved	6367109c-4684-4a1b-a6b5-9843aa3f6a9d	\N	e1e22f2b-0f42-4b3a-832b-bf9bc7faa006	2026-07-20 11:46:45.199839+00	2026-07-20 11:46:45.199839+00
6fa5de46-9edd-404a-915e-89d9f3f21ae7	d05e5a12-c2b2-4ce0-b976-fa443bcb45a6	a34644cb-4fa6-4ad1-904f-3e26b23679cd	پیاده‌سازی بخش اصلی	98	37	2026-07-16	approved	6367109c-4684-4a1b-a6b5-9843aa3f6a9d	\N	7703926d-ffd4-4258-ae14-03edbc079b8f	2026-07-20 11:46:45.199839+00	2026-07-20 11:46:45.199839+00
6fa5de46-9edd-404a-915e-89d9f3f21ae7	d05e5a12-c2b2-4ce0-b976-fa443bcb45a6	a34644cb-4fa6-4ad1-904f-3e26b23679cd	رفع اشکالات و بازبینی	142	70	2026-07-16	approved	6367109c-4684-4a1b-a6b5-9843aa3f6a9d	\N	532e08cf-aec9-49b5-b535-debfbaea62f1	2026-07-20 11:46:45.199839+00	2026-07-20 11:46:45.199839+00
6fa5de46-9edd-404a-915e-89d9f3f21ae7	d05e5a12-c2b2-4ce0-b976-fa443bcb45a6	a34644cb-4fa6-4ad1-904f-3e26b23679cd	پیشرفت اولیه و بررسی نیازمندی‌ها	191	100	2026-07-16	approved	6367109c-4684-4a1b-a6b5-9843aa3f6a9d	\N	30b64630-8c57-4a7b-b31e-1d24d85f85b9	2026-07-20 11:46:45.199839+00	2026-07-20 11:46:45.199839+00
6fa5de46-9edd-404a-915e-89d9f3f21ae7	d05e5a12-c2b2-4ce0-b976-fa443bcb45a6	a34644cb-4fa6-4ad1-904f-3e26b23679cd	پیاده‌سازی بخش اصلی	109	100	2026-07-16	approved	6367109c-4684-4a1b-a6b5-9843aa3f6a9d	\N	c49d4239-8968-4802-b5e7-27ca06dfdcf0	2026-07-20 11:46:45.199839+00	2026-07-20 11:46:45.199839+00
6fa5de46-9edd-404a-915e-89d9f3f21ae7	a40edda0-642d-4650-aa2b-7633bdf24624	7c364485-75f2-4d57-81ee-62ec42c62177	پیشرفت اولیه و بررسی نیازمندی‌ها	87	23	2026-07-16	approved	6367109c-4684-4a1b-a6b5-9843aa3f6a9d	\N	dd85b46d-b282-4365-ae09-e9be06e35ccb	2026-07-20 11:46:45.199839+00	2026-07-20 11:46:45.199839+00
6fa5de46-9edd-404a-915e-89d9f3f21ae7	b7169780-724e-451a-ae17-19f441a26308	3051f03b-e73a-49fb-a6d2-ab7406c6850b	پیاده‌سازی بخش اصلی	157	29	2026-07-16	approved	6367109c-4684-4a1b-a6b5-9843aa3f6a9d	\N	b1a2a7fd-3bff-4e06-9a61-3c487ab11a6f	2026-07-20 11:46:45.199839+00	2026-07-20 11:46:45.199839+00
6fa5de46-9edd-404a-915e-89d9f3f21ae7	b7169780-724e-451a-ae17-19f441a26308	3051f03b-e73a-49fb-a6d2-ab7406c6850b	تست و اطمینان از عملکرد صحیح	150	54	2026-07-16	approved	6367109c-4684-4a1b-a6b5-9843aa3f6a9d	\N	e8fc938a-1bcb-482e-8920-d8a697fbbd0b	2026-07-20 11:46:45.199839+00	2026-07-20 11:46:45.199839+00
6fa5de46-9edd-404a-915e-89d9f3f21ae7	b7169780-724e-451a-ae17-19f441a26308	3051f03b-e73a-49fb-a6d2-ab7406c6850b	تست و اطمینان از عملکرد صحیح	78	100	2026-07-16	approved	6367109c-4684-4a1b-a6b5-9843aa3f6a9d	\N	bc1c515a-ba3e-4796-8d7e-e2f450cbd409	2026-07-20 11:46:45.199839+00	2026-07-20 11:46:45.199839+00
6fa5de46-9edd-404a-915e-89d9f3f21ae7	b7169780-724e-451a-ae17-19f441a26308	3051f03b-e73a-49fb-a6d2-ab7406c6850b	رفع اشکالات و بازبینی	227	100	2026-07-16	submitted	\N	\N	afe821fc-aefc-426c-b02a-11b064be7c0b	2026-07-20 11:46:45.199839+00	2026-07-20 11:46:45.199839+00
6fa5de46-9edd-404a-915e-89d9f3f21ae7	096f7f29-fc56-4e30-823e-e6ca70e8e59a	3051f03b-e73a-49fb-a6d2-ab7406c6850b	پیشرفت اولیه و بررسی نیازمندی‌ها	102	29	2026-07-14	approved	6367109c-4684-4a1b-a6b5-9843aa3f6a9d	\N	53c261fe-38af-497f-996c-3cceec1cb09b	2026-07-20 11:46:45.199839+00	2026-07-20 11:46:45.199839+00
6fa5de46-9edd-404a-915e-89d9f3f21ae7	096f7f29-fc56-4e30-823e-e6ca70e8e59a	3051f03b-e73a-49fb-a6d2-ab7406c6850b	پیاده‌سازی بخش اصلی	144	74	2026-07-16	approved	6367109c-4684-4a1b-a6b5-9843aa3f6a9d	\N	500ca365-976c-4129-bdc9-fca9f0b3a99d	2026-07-20 11:46:45.199839+00	2026-07-20 11:46:45.199839+00
6fa5de46-9edd-404a-915e-89d9f3f21ae7	096f7f29-fc56-4e30-823e-e6ca70e8e59a	3051f03b-e73a-49fb-a6d2-ab7406c6850b	رفع اشکالات و بازبینی	115	100	2026-07-16	approved	6367109c-4684-4a1b-a6b5-9843aa3f6a9d	\N	47d85b5b-c43e-45d8-9abb-c420bda02a29	2026-07-20 11:46:45.199839+00	2026-07-20 11:46:45.199839+00
6fa5de46-9edd-404a-915e-89d9f3f21ae7	8430c3c1-297d-4114-a059-c1fa92640b19	6367109c-4684-4a1b-a6b5-9843aa3f6a9d	پیاده‌سازی بخش اصلی	208	27	2026-06-17	submitted	\N	\N	e90c4364-affa-46ed-a596-2d162a964aab	2026-07-20 11:46:45.199839+00	2026-07-20 11:46:45.199839+00
6fa5de46-9edd-404a-915e-89d9f3f21ae7	8430c3c1-297d-4114-a059-c1fa92640b19	6367109c-4684-4a1b-a6b5-9843aa3f6a9d	تست و اطمینان از عملکرد صحیح	41	60	2026-06-21	approved	6367109c-4684-4a1b-a6b5-9843aa3f6a9d	\N	d8602e19-ef04-4122-a659-f051e278fd52	2026-07-20 11:46:45.199839+00	2026-07-20 11:46:45.199839+00
6fa5de46-9edd-404a-915e-89d9f3f21ae7	8430c3c1-297d-4114-a059-c1fa92640b19	6367109c-4684-4a1b-a6b5-9843aa3f6a9d	تست و اطمینان از عملکرد صحیح	128	100	2026-06-25	submitted	\N	\N	f1df7803-dc2f-4fd8-ba4d-886adf981706	2026-07-20 11:46:45.199839+00	2026-07-20 11:46:45.199839+00
6fa5de46-9edd-404a-915e-89d9f3f21ae7	8430c3c1-297d-4114-a059-c1fa92640b19	6367109c-4684-4a1b-a6b5-9843aa3f6a9d	پیشرفت اولیه و بررسی نیازمندی‌ها	62	100	2026-06-23	approved	6367109c-4684-4a1b-a6b5-9843aa3f6a9d	\N	0383d34f-5f67-4cda-973d-fcef1bb9d70c	2026-07-20 11:46:45.199839+00	2026-07-20 11:46:45.199839+00
6fa5de46-9edd-404a-915e-89d9f3f21ae7	21003b7c-9144-4f74-943d-17d4cfaef9a5	6367109c-4684-4a1b-a6b5-9843aa3f6a9d	تست و اطمینان از عملکرد صحیح	55	36	2026-07-16	approved	6367109c-4684-4a1b-a6b5-9843aa3f6a9d	\N	03eed3ce-aa80-4eda-a74a-3c0a3248c7a3	2026-07-20 11:46:45.199839+00	2026-07-20 11:46:45.199839+00
6fa5de46-9edd-404a-915e-89d9f3f21ae7	21003b7c-9144-4f74-943d-17d4cfaef9a5	6367109c-4684-4a1b-a6b5-9843aa3f6a9d	پیشرفت اولیه و بررسی نیازمندی‌ها	214	48	2026-07-16	approved	6367109c-4684-4a1b-a6b5-9843aa3f6a9d	\N	b92c6c16-cc90-4ccb-9b3a-175e66d87416	2026-07-20 11:46:45.199839+00	2026-07-20 11:46:45.199839+00
6fa5de46-9edd-404a-915e-89d9f3f21ae7	21003b7c-9144-4f74-943d-17d4cfaef9a5	6367109c-4684-4a1b-a6b5-9843aa3f6a9d	پیاده‌سازی بخش اصلی	49	100	2026-07-16	approved	6367109c-4684-4a1b-a6b5-9843aa3f6a9d	\N	499f3b02-be86-4b27-8426-c54d83c12dee	2026-07-20 11:46:45.199839+00	2026-07-20 11:46:45.199839+00
6fa5de46-9edd-404a-915e-89d9f3f21ae7	13257893-b253-483e-a87a-7e1a3966fcbb	6367109c-4684-4a1b-a6b5-9843aa3f6a9d	مستندسازی و نهایی‌سازی	207	32	2026-07-16	approved	6367109c-4684-4a1b-a6b5-9843aa3f6a9d	\N	4856d60b-cc30-4f9e-a61d-90a00b98d1d0	2026-07-20 11:46:45.199839+00	2026-07-20 11:46:45.199839+00
6fa5de46-9edd-404a-915e-89d9f3f21ae7	13257893-b253-483e-a87a-7e1a3966fcbb	6367109c-4684-4a1b-a6b5-9843aa3f6a9d	رفع اشکالات و بازبینی	202	74	2026-07-16	approved	6367109c-4684-4a1b-a6b5-9843aa3f6a9d	\N	5fd787f4-fb72-412b-8d66-636492ff1df7	2026-07-20 11:46:45.199839+00	2026-07-20 11:46:45.199839+00
6fa5de46-9edd-404a-915e-89d9f3f21ae7	13257893-b253-483e-a87a-7e1a3966fcbb	6367109c-4684-4a1b-a6b5-9843aa3f6a9d	رفع اشکالات و بازبینی	190	100	2026-07-16	approved	6367109c-4684-4a1b-a6b5-9843aa3f6a9d	\N	826f929b-0908-42a9-8258-8a0ea8a91b30	2026-07-20 11:46:45.199839+00	2026-07-20 11:46:45.199839+00
6fa5de46-9edd-404a-915e-89d9f3f21ae7	2816cfb0-f896-4eff-a3b4-abb075f0dc45	a42bd423-3577-42e0-b239-611eb7480fb9	پیاده‌سازی بخش اصلی	191	29	2026-07-16	approved	6367109c-4684-4a1b-a6b5-9843aa3f6a9d	\N	301923e8-191a-449a-940a-d5e376693d25	2026-07-20 11:46:45.199839+00	2026-07-20 11:46:45.199839+00
6fa5de46-9edd-404a-915e-89d9f3f21ae7	54275bdf-1154-44a4-b628-2e78a6b4b79c	6367109c-4684-4a1b-a6b5-9843aa3f6a9d	تست و اطمینان از عملکرد صحیح	55	40	2026-07-13	approved	6367109c-4684-4a1b-a6b5-9843aa3f6a9d	\N	7377b9cf-b12c-4b43-ab2b-6923ad513a7b	2026-07-20 11:46:45.199839+00	2026-07-20 11:46:45.199839+00
6fa5de46-9edd-404a-915e-89d9f3f21ae7	54275bdf-1154-44a4-b628-2e78a6b4b79c	6367109c-4684-4a1b-a6b5-9843aa3f6a9d	تست و اطمینان از عملکرد صحیح	72	58	2026-07-14	approved	6367109c-4684-4a1b-a6b5-9843aa3f6a9d	\N	c4d2cd43-e9de-49b6-bf16-db35df5f4308	2026-07-20 11:46:45.199839+00	2026-07-20 11:46:45.199839+00
6fa5de46-9edd-404a-915e-89d9f3f21ae7	9318e72a-b31d-421f-a86a-0910c1745e11	fd5161f1-4abf-4cc9-8f06-914566393088	رفع اشکالات و بازبینی	233	21	2026-07-11	approved	6367109c-4684-4a1b-a6b5-9843aa3f6a9d	\N	1c08e7d8-be50-460b-8c1d-44c470701678	2026-07-20 11:46:45.199839+00	2026-07-20 11:46:45.199839+00
6fa5de46-9edd-404a-915e-89d9f3f21ae7	4840e870-0f81-4bae-bd5c-c617bd670553	7c364485-75f2-4d57-81ee-62ec42c62177	رفع اشکالات و بازبینی	140	24	2026-07-13	approved	6367109c-4684-4a1b-a6b5-9843aa3f6a9d	\N	79ddde10-6f46-4934-b612-1f008397535b	2026-07-20 11:46:45.199839+00	2026-07-20 11:46:45.199839+00
6fa5de46-9edd-404a-915e-89d9f3f21ae7	4840e870-0f81-4bae-bd5c-c617bd670553	7c364485-75f2-4d57-81ee-62ec42c62177	مستندسازی و نهایی‌سازی	135	76	2026-07-15	approved	6367109c-4684-4a1b-a6b5-9843aa3f6a9d	\N	06e4c766-3c6b-4329-ad6e-44712c6caeb5	2026-07-20 11:46:45.199839+00	2026-07-20 11:46:45.199839+00
6fa5de46-9edd-404a-915e-89d9f3f21ae7	4840e870-0f81-4bae-bd5c-c617bd670553	7c364485-75f2-4d57-81ee-62ec42c62177	پیاده‌سازی بخش اصلی	74	66	2026-07-16	approved	6367109c-4684-4a1b-a6b5-9843aa3f6a9d	\N	5f966261-cda5-4ec6-a21c-f0aa91f47638	2026-07-20 11:46:45.199839+00	2026-07-20 11:46:45.199839+00
6fa5de46-9edd-404a-915e-89d9f3f21ae7	14f54408-a36b-401c-b5cb-f24cd4b58bd5	6367109c-4684-4a1b-a6b5-9843aa3f6a9d	تست و اطمینان از عملکرد صحیح	179	24	2026-07-16	approved	6367109c-4684-4a1b-a6b5-9843aa3f6a9d	\N	c9549251-65c2-4725-8a35-d5c5ac1247b4	2026-07-20 11:46:45.199839+00	2026-07-20 11:46:45.199839+00
6fa5de46-9edd-404a-915e-89d9f3f21ae7	14f54408-a36b-401c-b5cb-f24cd4b58bd5	6367109c-4684-4a1b-a6b5-9843aa3f6a9d	تست و اطمینان از عملکرد صحیح	193	56	2026-07-16	approved	6367109c-4684-4a1b-a6b5-9843aa3f6a9d	\N	c187abad-e89e-473a-ae6f-a0e8c541fc0c	2026-07-20 11:46:45.199839+00	2026-07-20 11:46:45.199839+00
6fa5de46-9edd-404a-915e-89d9f3f21ae7	14f54408-a36b-401c-b5cb-f24cd4b58bd5	6367109c-4684-4a1b-a6b5-9843aa3f6a9d	رفع اشکالات و بازبینی	200	60	2026-07-16	approved	6367109c-4684-4a1b-a6b5-9843aa3f6a9d	\N	1b7594c8-0e74-4411-a2fe-740c8d68df92	2026-07-20 11:46:45.199839+00	2026-07-20 11:46:45.199839+00
6fa5de46-9edd-404a-915e-89d9f3f21ae7	14f54408-a36b-401c-b5cb-f24cd4b58bd5	6367109c-4684-4a1b-a6b5-9843aa3f6a9d	رفع اشکالات و بازبینی	203	100	2026-07-16	approved	6367109c-4684-4a1b-a6b5-9843aa3f6a9d	\N	b0f5b6a5-2858-4499-8133-b424c56afaa7	2026-07-20 11:46:45.199839+00	2026-07-20 11:46:45.199839+00
6fa5de46-9edd-404a-915e-89d9f3f21ae7	13c26385-7b15-402b-af4a-3311cbab9488	a34644cb-4fa6-4ad1-904f-3e26b23679cd	رفع اشکالات و بازبینی	180	29	2026-07-16	approved	6367109c-4684-4a1b-a6b5-9843aa3f6a9d	\N	c733f458-0afb-4f28-b2ed-bc8a9e53d99a	2026-07-20 11:46:45.199839+00	2026-07-20 11:46:45.199839+00
6fa5de46-9edd-404a-915e-89d9f3f21ae7	13c26385-7b15-402b-af4a-3311cbab9488	a34644cb-4fa6-4ad1-904f-3e26b23679cd	تست و اطمینان از عملکرد صحیح	107	52	2026-07-16	approved	6367109c-4684-4a1b-a6b5-9843aa3f6a9d	\N	17beb57e-385f-4b0c-bb12-d4afce91e6b5	2026-07-20 11:46:45.199839+00	2026-07-20 11:46:45.199839+00
6fa5de46-9edd-404a-915e-89d9f3f21ae7	7d1e13ab-bc62-4d3c-9133-2cb500461ad1	398f8c1c-1d8b-48eb-9aed-08ebb479cff3	پیشرفت اولیه و بررسی نیازمندی‌ها	90	32	2026-07-16	approved	6367109c-4684-4a1b-a6b5-9843aa3f6a9d	\N	e10935d9-9a5c-42d7-835c-5e816fea017d	2026-07-20 11:46:45.199839+00	2026-07-20 11:46:45.199839+00
6fa5de46-9edd-404a-915e-89d9f3f21ae7	7d1e13ab-bc62-4d3c-9133-2cb500461ad1	398f8c1c-1d8b-48eb-9aed-08ebb479cff3	مستندسازی و نهایی‌سازی	105	58	2026-07-16	approved	6367109c-4684-4a1b-a6b5-9843aa3f6a9d	\N	024b0454-9b4e-4ca1-be0b-45151331c9c6	2026-07-20 11:46:45.199839+00	2026-07-20 11:46:45.199839+00
6fa5de46-9edd-404a-915e-89d9f3f21ae7	7d1e13ab-bc62-4d3c-9133-2cb500461ad1	398f8c1c-1d8b-48eb-9aed-08ebb479cff3	تست و اطمینان از عملکرد صحیح	100	60	2026-07-16	approved	6367109c-4684-4a1b-a6b5-9843aa3f6a9d	\N	388b764b-1ab1-4a4d-ae8f-0e5c92db7a18	2026-07-20 11:46:45.199839+00	2026-07-20 11:46:45.199839+00
6fa5de46-9edd-404a-915e-89d9f3f21ae7	7d1e13ab-bc62-4d3c-9133-2cb500461ad1	398f8c1c-1d8b-48eb-9aed-08ebb479cff3	مستندسازی و نهایی‌سازی	220	100	2026-07-16	approved	6367109c-4684-4a1b-a6b5-9843aa3f6a9d	\N	f5a95dc0-e177-4639-8989-505b5473dbb3	2026-07-20 11:46:45.199839+00	2026-07-20 11:46:45.199839+00
6fa5de46-9edd-404a-915e-89d9f3f21ae7	a1d258f5-6539-48ff-9d63-1249c9e66a02	7c364485-75f2-4d57-81ee-62ec42c62177	رفع اشکالات و بازبینی	86	40	2026-06-29	approved	6367109c-4684-4a1b-a6b5-9843aa3f6a9d	\N	ae5982c5-aa60-49eb-aa49-1d7470dd4a0b	2026-07-20 11:46:45.199839+00	2026-07-20 11:46:45.199839+00
6fa5de46-9edd-404a-915e-89d9f3f21ae7	a1d258f5-6539-48ff-9d63-1249c9e66a02	7c364485-75f2-4d57-81ee-62ec42c62177	پیاده‌سازی بخش اصلی	190	46	2026-07-01	approved	6367109c-4684-4a1b-a6b5-9843aa3f6a9d	\N	36d441ca-cce3-4c3c-98ae-47d210ec5f38	2026-07-20 11:46:45.199839+00	2026-07-20 11:46:45.199839+00
6fa5de46-9edd-404a-915e-89d9f3f21ae7	a1d258f5-6539-48ff-9d63-1249c9e66a02	7c364485-75f2-4d57-81ee-62ec42c62177	تست و اطمینان از عملکرد صحیح	38	100	2026-07-01	approved	6367109c-4684-4a1b-a6b5-9843aa3f6a9d	\N	97d12315-d9e8-498e-896a-a38ff23564e6	2026-07-20 11:46:45.199839+00	2026-07-20 11:46:45.199839+00
6fa5de46-9edd-404a-915e-89d9f3f21ae7	a2dfae99-79ae-4f4b-8e87-d766edb93e5f	7c364485-75f2-4d57-81ee-62ec42c62177	رفع اشکالات و بازبینی	113	33	2026-06-23	approved	6367109c-4684-4a1b-a6b5-9843aa3f6a9d	\N	0d751132-6509-4664-9f45-1ddd2a008f58	2026-07-20 11:46:45.199839+00	2026-07-20 11:46:45.199839+00
6fa5de46-9edd-404a-915e-89d9f3f21ae7	a2dfae99-79ae-4f4b-8e87-d766edb93e5f	7c364485-75f2-4d57-81ee-62ec42c62177	مستندسازی و نهایی‌سازی	123	72	2026-06-25	approved	6367109c-4684-4a1b-a6b5-9843aa3f6a9d	\N	191807fb-d5f0-4f90-8039-ccdb4f13420b	2026-07-20 11:46:45.199839+00	2026-07-20 11:46:45.199839+00
6fa5de46-9edd-404a-915e-89d9f3f21ae7	a2dfae99-79ae-4f4b-8e87-d766edb93e5f	7c364485-75f2-4d57-81ee-62ec42c62177	رفع اشکالات و بازبینی	153	87	2026-06-29	submitted	\N	\N	014563fa-07f6-4336-98ff-8e089fe411a0	2026-07-20 11:46:45.199839+00	2026-07-20 11:46:45.199839+00
6fa5de46-9edd-404a-915e-89d9f3f21ae7	5456f8bb-fc35-46a2-b317-62c55003b64f	6367109c-4684-4a1b-a6b5-9843aa3f6a9d	پیشرفت اولیه و بررسی نیازمندی‌ها	66	27	2026-07-16	approved	6367109c-4684-4a1b-a6b5-9843aa3f6a9d	\N	e6010464-40c4-4e02-9a14-2f0d1b28a9cf	2026-07-20 11:46:45.199839+00	2026-07-20 11:46:45.199839+00
6fa5de46-9edd-404a-915e-89d9f3f21ae7	5456f8bb-fc35-46a2-b317-62c55003b64f	6367109c-4684-4a1b-a6b5-9843aa3f6a9d	مستندسازی و نهایی‌سازی	123	44	2026-07-16	submitted	\N	\N	898bef32-b14d-430e-b983-eda2fae6e6b0	2026-07-20 11:46:45.199839+00	2026-07-20 11:46:45.199839+00
6fa5de46-9edd-404a-915e-89d9f3f21ae7	5456f8bb-fc35-46a2-b317-62c55003b64f	6367109c-4684-4a1b-a6b5-9843aa3f6a9d	مستندسازی و نهایی‌سازی	61	100	2026-07-16	approved	6367109c-4684-4a1b-a6b5-9843aa3f6a9d	\N	aada9261-7141-432f-a19a-02a92957b306	2026-07-20 11:46:45.199839+00	2026-07-20 11:46:45.199839+00
6fa5de46-9edd-404a-915e-89d9f3f21ae7	3753f4fd-d921-45ee-b0f7-bf06fc8822f5	7c364485-75f2-4d57-81ee-62ec42c62177	مستندسازی و نهایی‌سازی	127	40	2026-07-01	approved	6367109c-4684-4a1b-a6b5-9843aa3f6a9d	\N	cdf3ff70-5518-43f8-ad58-f5d88290c5e7	2026-07-20 11:46:45.199839+00	2026-07-20 11:46:45.199839+00
6fa5de46-9edd-404a-915e-89d9f3f21ae7	3753f4fd-d921-45ee-b0f7-bf06fc8822f5	7c364485-75f2-4d57-81ee-62ec42c62177	پیشرفت اولیه و بررسی نیازمندی‌ها	202	54	2026-07-04	approved	6367109c-4684-4a1b-a6b5-9843aa3f6a9d	\N	fb2f8498-ec9b-4a4a-9760-c37a2e9b0b1e	2026-07-20 11:46:45.199839+00	2026-07-20 11:46:45.199839+00
6fa5de46-9edd-404a-915e-89d9f3f21ae7	3753f4fd-d921-45ee-b0f7-bf06fc8822f5	7c364485-75f2-4d57-81ee-62ec42c62177	پیشرفت اولیه و بررسی نیازمندی‌ها	188	100	2026-07-09	approved	6367109c-4684-4a1b-a6b5-9843aa3f6a9d	\N	5852d927-1cb6-4060-8b6b-0738a5b833ac	2026-07-20 11:46:45.199839+00	2026-07-20 11:46:45.199839+00
6fa5de46-9edd-404a-915e-89d9f3f21ae7	3f66d431-45ea-48e9-99a7-695c0e5ba17e	398f8c1c-1d8b-48eb-9aed-08ebb479cff3	پیشرفت اولیه و بررسی نیازمندی‌ها	192	34	2026-07-16	approved	6367109c-4684-4a1b-a6b5-9843aa3f6a9d	\N	036ab566-3bee-4ae9-beee-d19e6e6aeed0	2026-07-20 11:46:45.199839+00	2026-07-20 11:46:45.199839+00
6fa5de46-9edd-404a-915e-89d9f3f21ae7	3f66d431-45ea-48e9-99a7-695c0e5ba17e	398f8c1c-1d8b-48eb-9aed-08ebb479cff3	تست و اطمینان از عملکرد صحیح	59	48	2026-07-16	approved	6367109c-4684-4a1b-a6b5-9843aa3f6a9d	\N	5a1ed067-2993-4bc6-a5af-8096ac1cb7d9	2026-07-20 11:46:45.199839+00	2026-07-20 11:46:45.199839+00
6fa5de46-9edd-404a-915e-89d9f3f21ae7	3f66d431-45ea-48e9-99a7-695c0e5ba17e	398f8c1c-1d8b-48eb-9aed-08ebb479cff3	پیشرفت اولیه و بررسی نیازمندی‌ها	107	100	2026-07-16	approved	6367109c-4684-4a1b-a6b5-9843aa3f6a9d	\N	2e9b4d11-2597-4e38-931b-6e91a60d83a4	2026-07-20 11:46:45.199839+00	2026-07-20 11:46:45.199839+00
6fa5de46-9edd-404a-915e-89d9f3f21ae7	55db2a01-80b5-405f-97f1-f92356356712	a42bd423-3577-42e0-b239-611eb7480fb9	پیاده‌سازی بخش اصلی	167	24	2026-07-05	approved	6367109c-4684-4a1b-a6b5-9843aa3f6a9d	\N	5d1d32c2-fa0b-4fba-aa2c-b013fec85126	2026-07-20 11:46:45.199839+00	2026-07-20 11:46:45.199839+00
6fa5de46-9edd-404a-915e-89d9f3f21ae7	31ad8ea6-0706-46ab-9150-464d7cb28efa	a34644cb-4fa6-4ad1-904f-3e26b23679cd	رفع اشکالات و بازبینی	201	37	2026-07-16	approved	6367109c-4684-4a1b-a6b5-9843aa3f6a9d	\N	77f45281-9756-4617-a7f4-e9be0ce9d9c3	2026-07-20 11:46:45.199839+00	2026-07-20 11:46:45.199839+00
6fa5de46-9edd-404a-915e-89d9f3f21ae7	31ad8ea6-0706-46ab-9150-464d7cb28efa	a34644cb-4fa6-4ad1-904f-3e26b23679cd	مستندسازی و نهایی‌سازی	220	48	2026-07-16	approved	6367109c-4684-4a1b-a6b5-9843aa3f6a9d	\N	55d7c6c9-84e6-4223-b023-b239867941ec	2026-07-20 11:46:45.199839+00	2026-07-20 11:46:45.199839+00
6fa5de46-9edd-404a-915e-89d9f3f21ae7	31ad8ea6-0706-46ab-9150-464d7cb28efa	a34644cb-4fa6-4ad1-904f-3e26b23679cd	پیشرفت اولیه و بررسی نیازمندی‌ها	155	100	2026-07-16	approved	6367109c-4684-4a1b-a6b5-9843aa3f6a9d	\N	45a1d935-9362-4760-9837-73bcbb4b50aa	2026-07-20 11:46:45.199839+00	2026-07-20 11:46:45.199839+00
6fa5de46-9edd-404a-915e-89d9f3f21ae7	31ad8ea6-0706-46ab-9150-464d7cb28efa	a34644cb-4fa6-4ad1-904f-3e26b23679cd	رفع اشکالات و بازبینی	38	100	2026-07-16	approved	6367109c-4684-4a1b-a6b5-9843aa3f6a9d	\N	7ad8ed4f-ce1b-4b5c-bad0-7bb560597877	2026-07-20 11:46:45.199839+00	2026-07-20 11:46:45.199839+00
6fa5de46-9edd-404a-915e-89d9f3f21ae7	efe7716b-8a35-461f-9f24-198520502521	6367109c-4684-4a1b-a6b5-9843aa3f6a9d	تست و اطمینان از عملکرد صحیح	90	31	2026-07-16	approved	6367109c-4684-4a1b-a6b5-9843aa3f6a9d	\N	d1508631-70a6-4f8d-90f5-91ff97f332b3	2026-07-20 11:46:45.199839+00	2026-07-20 11:46:45.199839+00
6fa5de46-9edd-404a-915e-89d9f3f21ae7	efe7716b-8a35-461f-9f24-198520502521	6367109c-4684-4a1b-a6b5-9843aa3f6a9d	رفع اشکالات و بازبینی	169	80	2026-07-16	approved	6367109c-4684-4a1b-a6b5-9843aa3f6a9d	\N	e57d4ed2-18c4-42bb-89f1-a8d2415fa175	2026-07-20 11:46:45.199839+00	2026-07-20 11:46:45.199839+00
6fa5de46-9edd-404a-915e-89d9f3f21ae7	5b03be5a-25d6-4f3d-a70b-6d013be4d622	398f8c1c-1d8b-48eb-9aed-08ebb479cff3	پیاده‌سازی بخش اصلی	61	34	2026-07-16	approved	6367109c-4684-4a1b-a6b5-9843aa3f6a9d	\N	6b546bfe-cf6c-4804-ad8a-9c63b27b2328	2026-07-20 11:46:45.199839+00	2026-07-20 11:46:45.199839+00
6fa5de46-9edd-404a-915e-89d9f3f21ae7	5b03be5a-25d6-4f3d-a70b-6d013be4d622	398f8c1c-1d8b-48eb-9aed-08ebb479cff3	مستندسازی و نهایی‌سازی	35	42	2026-07-16	approved	6367109c-4684-4a1b-a6b5-9843aa3f6a9d	\N	5cd1ae71-cf3e-4f48-b6af-a13eca3e547c	2026-07-20 11:46:45.199839+00	2026-07-20 11:46:45.199839+00
6fa5de46-9edd-404a-915e-89d9f3f21ae7	5b03be5a-25d6-4f3d-a70b-6d013be4d622	398f8c1c-1d8b-48eb-9aed-08ebb479cff3	پیاده‌سازی بخش اصلی	231	100	2026-07-16	approved	6367109c-4684-4a1b-a6b5-9843aa3f6a9d	\N	dac9de2d-cb33-4e04-89ec-27fa9cfcf78f	2026-07-20 11:46:45.199839+00	2026-07-20 11:46:45.199839+00
6fa5de46-9edd-404a-915e-89d9f3f21ae7	a14ca87d-8fba-4680-b894-04c592182789	3051f03b-e73a-49fb-a6d2-ab7406c6850b	مستندسازی و نهایی‌سازی	83	38	2026-06-20	approved	6367109c-4684-4a1b-a6b5-9843aa3f6a9d	\N	182a0683-be81-441a-9c9f-00ce1af3c429	2026-07-20 11:46:45.199839+00	2026-07-20 11:46:45.199839+00
6fa5de46-9edd-404a-915e-89d9f3f21ae7	a14ca87d-8fba-4680-b894-04c592182789	3051f03b-e73a-49fb-a6d2-ab7406c6850b	پیاده‌سازی بخش اصلی	114	48	2026-06-22	approved	6367109c-4684-4a1b-a6b5-9843aa3f6a9d	\N	5af53c6e-426f-4a20-80ca-139eb0c10fa7	2026-07-20 11:46:45.199839+00	2026-07-20 11:46:45.199839+00
6fa5de46-9edd-404a-915e-89d9f3f21ae7	1276c989-5672-4ed3-ad9b-60c79ea923d6	a42bd423-3577-42e0-b239-611eb7480fb9	پیاده‌سازی بخش اصلی	63	37	2026-06-24	approved	6367109c-4684-4a1b-a6b5-9843aa3f6a9d	\N	50779b3b-a1cb-4797-8278-86be3c96df73	2026-07-20 11:46:45.199839+00	2026-07-20 11:46:45.199839+00
6fa5de46-9edd-404a-915e-89d9f3f21ae7	b582082f-0a26-4d58-92c0-708c2cb4e8b8	398f8c1c-1d8b-48eb-9aed-08ebb479cff3	پیشرفت اولیه و بررسی نیازمندی‌ها	199	20	2026-07-16	approved	6367109c-4684-4a1b-a6b5-9843aa3f6a9d	\N	bb5780c5-557a-4a8c-b0b2-9d1e541cf5a7	2026-07-20 11:46:45.199839+00	2026-07-20 11:46:45.199839+00
6fa5de46-9edd-404a-915e-89d9f3f21ae7	b582082f-0a26-4d58-92c0-708c2cb4e8b8	398f8c1c-1d8b-48eb-9aed-08ebb479cff3	پیشرفت اولیه و بررسی نیازمندی‌ها	121	54	2026-07-16	approved	6367109c-4684-4a1b-a6b5-9843aa3f6a9d	\N	98a3c51d-9062-436a-b6f4-49e46e6fca90	2026-07-20 11:46:45.199839+00	2026-07-20 11:46:45.199839+00
6fa5de46-9edd-404a-915e-89d9f3f21ae7	b582082f-0a26-4d58-92c0-708c2cb4e8b8	398f8c1c-1d8b-48eb-9aed-08ebb479cff3	پیشرفت اولیه و بررسی نیازمندی‌ها	74	84	2026-07-16	approved	6367109c-4684-4a1b-a6b5-9843aa3f6a9d	\N	a252bc3a-23c1-4be1-95b3-cb4fb00dd564	2026-07-20 11:46:45.199839+00	2026-07-20 11:46:45.199839+00
6fa5de46-9edd-404a-915e-89d9f3f21ae7	4c1b7d2f-c80a-4ad1-9085-2753bf699b38	398f8c1c-1d8b-48eb-9aed-08ebb479cff3	مستندسازی و نهایی‌سازی	59	22	2026-07-16	submitted	\N	\N	75e37646-ed3b-4555-b081-cbf8e1e1214f	2026-07-20 11:46:45.199839+00	2026-07-20 11:46:45.199839+00
6fa5de46-9edd-404a-915e-89d9f3f21ae7	787adb4d-2ca5-4a61-bfe6-aaf94d0e22b9	6367109c-4684-4a1b-a6b5-9843aa3f6a9d	رفع اشکالات و بازبینی	161	38	2026-07-16	approved	6367109c-4684-4a1b-a6b5-9843aa3f6a9d	\N	7c537066-1cc9-4a3f-bea2-cfedcaf7b587	2026-07-20 11:46:45.199839+00	2026-07-20 11:46:45.199839+00
6fa5de46-9edd-404a-915e-89d9f3f21ae7	787adb4d-2ca5-4a61-bfe6-aaf94d0e22b9	6367109c-4684-4a1b-a6b5-9843aa3f6a9d	تست و اطمینان از عملکرد صحیح	158	54	2026-07-16	approved	6367109c-4684-4a1b-a6b5-9843aa3f6a9d	\N	1945ba38-cf3b-4b2e-829f-2a278db71f86	2026-07-20 11:46:45.199839+00	2026-07-20 11:46:45.199839+00
6fa5de46-9edd-404a-915e-89d9f3f21ae7	787adb4d-2ca5-4a61-bfe6-aaf94d0e22b9	6367109c-4684-4a1b-a6b5-9843aa3f6a9d	مستندسازی و نهایی‌سازی	107	100	2026-07-16	approved	6367109c-4684-4a1b-a6b5-9843aa3f6a9d	\N	ec433634-4f7e-4b44-bb71-a6d99423b741	2026-07-20 11:46:45.199839+00	2026-07-20 11:46:45.199839+00
6fa5de46-9edd-404a-915e-89d9f3f21ae7	787adb4d-2ca5-4a61-bfe6-aaf94d0e22b9	6367109c-4684-4a1b-a6b5-9843aa3f6a9d	پیشرفت اولیه و بررسی نیازمندی‌ها	152	100	2026-07-16	approved	6367109c-4684-4a1b-a6b5-9843aa3f6a9d	\N	666befbb-ec4e-4717-8856-4856f3173901	2026-07-20 11:46:45.199839+00	2026-07-20 11:46:45.199839+00
6fa5de46-9edd-404a-915e-89d9f3f21ae7	57cd034f-20d1-4d05-8003-ac11421bad86	a34644cb-4fa6-4ad1-904f-3e26b23679cd	تست و اطمینان از عملکرد صحیح	48	22	2026-06-30	approved	6367109c-4684-4a1b-a6b5-9843aa3f6a9d	\N	82964c1f-2d98-437d-9fa0-564286391407	2026-07-20 11:46:45.199839+00	2026-07-20 11:46:45.199839+00
6fa5de46-9edd-404a-915e-89d9f3f21ae7	57cd034f-20d1-4d05-8003-ac11421bad86	a34644cb-4fa6-4ad1-904f-3e26b23679cd	پیشرفت اولیه و بررسی نیازمندی‌ها	62	56	2026-07-03	approved	6367109c-4684-4a1b-a6b5-9843aa3f6a9d	\N	08a713c2-4e0c-428d-b745-ed8001ca54fe	2026-07-20 11:46:45.199839+00	2026-07-20 11:46:45.199839+00
6fa5de46-9edd-404a-915e-89d9f3f21ae7	57cd034f-20d1-4d05-8003-ac11421bad86	a34644cb-4fa6-4ad1-904f-3e26b23679cd	مستندسازی و نهایی‌سازی	165	87	2026-07-06	approved	6367109c-4684-4a1b-a6b5-9843aa3f6a9d	\N	422c1600-087b-402f-8ed4-bc71873371ad	2026-07-20 11:46:45.199839+00	2026-07-20 11:46:45.199839+00
6fa5de46-9edd-404a-915e-89d9f3f21ae7	57cd034f-20d1-4d05-8003-ac11421bad86	a34644cb-4fa6-4ad1-904f-3e26b23679cd	تست و اطمینان از عملکرد صحیح	55	92	2026-07-12	approved	6367109c-4684-4a1b-a6b5-9843aa3f6a9d	\N	eba1dd36-1f1b-4d68-855b-e68ec448e5a5	2026-07-20 11:46:45.199839+00	2026-07-20 11:46:45.199839+00
6fa5de46-9edd-404a-915e-89d9f3f21ae7	0db9e83d-51a7-47c2-a069-7edac3a73a09	a34644cb-4fa6-4ad1-904f-3e26b23679cd	تست و اطمینان از عملکرد صحیح	88	33	2026-06-17	approved	6367109c-4684-4a1b-a6b5-9843aa3f6a9d	\N	b85d9068-db8b-4931-ae03-add1c97367a1	2026-07-20 11:46:45.199839+00	2026-07-20 11:46:45.199839+00
6fa5de46-9edd-404a-915e-89d9f3f21ae7	0db9e83d-51a7-47c2-a069-7edac3a73a09	a34644cb-4fa6-4ad1-904f-3e26b23679cd	تست و اطمینان از عملکرد صحیح	132	66	2026-06-20	approved	6367109c-4684-4a1b-a6b5-9843aa3f6a9d	\N	696c2a28-897e-48f2-b933-b2c806b8663e	2026-07-20 11:46:45.199839+00	2026-07-20 11:46:45.199839+00
6fa5de46-9edd-404a-915e-89d9f3f21ae7	9f945151-1c1a-48cd-91e1-ae32cb5228a8	6367109c-4684-4a1b-a6b5-9843aa3f6a9d	تست و اطمینان از عملکرد صحیح	110	28	2026-07-16	approved	6367109c-4684-4a1b-a6b5-9843aa3f6a9d	\N	1e8601e5-80ab-4b42-846f-d6f7b3e55def	2026-07-20 11:46:45.199839+00	2026-07-20 11:46:45.199839+00
6fa5de46-9edd-404a-915e-89d9f3f21ae7	28f1a7d9-d150-4ef2-b7b7-ad0a38d85ccb	fd5161f1-4abf-4cc9-8f06-914566393088	تست و اطمینان از عملکرد صحیح	47	22	2026-07-16	approved	6367109c-4684-4a1b-a6b5-9843aa3f6a9d	\N	431b1558-7c5b-486f-a23f-560c4b96bb36	2026-07-20 11:46:45.199839+00	2026-07-20 11:46:45.199839+00
6fa5de46-9edd-404a-915e-89d9f3f21ae7	28f1a7d9-d150-4ef2-b7b7-ad0a38d85ccb	fd5161f1-4abf-4cc9-8f06-914566393088	پیشرفت اولیه و بررسی نیازمندی‌ها	220	62	2026-07-16	approved	6367109c-4684-4a1b-a6b5-9843aa3f6a9d	\N	b4029173-5707-4d8e-ad61-6f1e5e8acc06	2026-07-20 11:46:45.199839+00	2026-07-20 11:46:45.199839+00
6fa5de46-9edd-404a-915e-89d9f3f21ae7	28f1a7d9-d150-4ef2-b7b7-ad0a38d85ccb	fd5161f1-4abf-4cc9-8f06-914566393088	مستندسازی و نهایی‌سازی	173	100	2026-07-16	approved	6367109c-4684-4a1b-a6b5-9843aa3f6a9d	\N	68eff5fe-2566-443d-a8c9-192ec2366776	2026-07-20 11:46:45.199839+00	2026-07-20 11:46:45.199839+00
6fa5de46-9edd-404a-915e-89d9f3f21ae7	14465c9c-b8c0-4334-abdb-25e7f214a7a1	fd5161f1-4abf-4cc9-8f06-914566393088	تست و اطمینان از عملکرد صحیح	214	21	2026-07-06	approved	6367109c-4684-4a1b-a6b5-9843aa3f6a9d	\N	dca6cf04-4fdc-495e-94bd-84a7b6033738	2026-07-20 11:46:45.199839+00	2026-07-20 11:46:45.199839+00
6fa5de46-9edd-404a-915e-89d9f3f21ae7	14465c9c-b8c0-4334-abdb-25e7f214a7a1	fd5161f1-4abf-4cc9-8f06-914566393088	رفع اشکالات و بازبینی	56	76	2026-07-09	approved	6367109c-4684-4a1b-a6b5-9843aa3f6a9d	\N	6be2f839-18e9-4756-baaa-fb549c1c41a1	2026-07-20 11:46:45.199839+00	2026-07-20 11:46:45.199839+00
6fa5de46-9edd-404a-915e-89d9f3f21ae7	14465c9c-b8c0-4334-abdb-25e7f214a7a1	fd5161f1-4abf-4cc9-8f06-914566393088	تست و اطمینان از عملکرد صحیح	87	69	2026-07-10	approved	6367109c-4684-4a1b-a6b5-9843aa3f6a9d	\N	cab3f7a0-8713-4533-a632-2d1a55aff03a	2026-07-20 11:46:45.199839+00	2026-07-20 11:46:45.199839+00
6fa5de46-9edd-404a-915e-89d9f3f21ae7	9cb78109-41ea-4ffc-ba37-0180a6385ac2	3051f03b-e73a-49fb-a6d2-ab7406c6850b	پیشرفت اولیه و بررسی نیازمندی‌ها	225	28	2026-07-16	approved	6367109c-4684-4a1b-a6b5-9843aa3f6a9d	\N	b49c28a9-122c-4b1f-bfec-e96cc77060b5	2026-07-20 11:46:45.199839+00	2026-07-20 11:46:45.199839+00
6fa5de46-9edd-404a-915e-89d9f3f21ae7	9cb78109-41ea-4ffc-ba37-0180a6385ac2	3051f03b-e73a-49fb-a6d2-ab7406c6850b	تست و اطمینان از عملکرد صحیح	173	78	2026-07-16	approved	6367109c-4684-4a1b-a6b5-9843aa3f6a9d	\N	dd2c6ea8-8408-4d5f-9db8-9cfc60b197c4	2026-07-20 11:46:45.199839+00	2026-07-20 11:46:45.199839+00
6fa5de46-9edd-404a-915e-89d9f3f21ae7	9cb78109-41ea-4ffc-ba37-0180a6385ac2	3051f03b-e73a-49fb-a6d2-ab7406c6850b	مستندسازی و نهایی‌سازی	198	84	2026-07-16	approved	6367109c-4684-4a1b-a6b5-9843aa3f6a9d	\N	ddac264c-2c20-44e8-9c70-cc44eb66aef9	2026-07-20 11:46:45.199839+00	2026-07-20 11:46:45.199839+00
6fa5de46-9edd-404a-915e-89d9f3f21ae7	720701a9-e459-4108-bed0-9cd48bad5fbc	398f8c1c-1d8b-48eb-9aed-08ebb479cff3	رفع اشکالات و بازبینی	209	29	2026-07-16	approved	6367109c-4684-4a1b-a6b5-9843aa3f6a9d	\N	d80d8015-ff35-45e8-9205-5d73403c33d3	2026-07-20 11:46:45.199839+00	2026-07-20 11:46:45.199839+00
6fa5de46-9edd-404a-915e-89d9f3f21ae7	d48b90d7-2da2-4105-ba0c-ee39244f79cd	a34644cb-4fa6-4ad1-904f-3e26b23679cd	پیشرفت اولیه و بررسی نیازمندی‌ها	76	24	2026-06-26	approved	6367109c-4684-4a1b-a6b5-9843aa3f6a9d	\N	925a259a-3644-4f23-8df1-569fbae108b3	2026-07-20 11:46:45.199839+00	2026-07-20 11:46:45.199839+00
6fa5de46-9edd-404a-915e-89d9f3f21ae7	d48b90d7-2da2-4105-ba0c-ee39244f79cd	a34644cb-4fa6-4ad1-904f-3e26b23679cd	پیشرفت اولیه و بررسی نیازمندی‌ها	66	80	2026-06-30	approved	6367109c-4684-4a1b-a6b5-9843aa3f6a9d	\N	9bd99d1b-1730-432f-b28f-8d5cf518b915	2026-07-20 11:46:45.199839+00	2026-07-20 11:46:45.199839+00
6fa5de46-9edd-404a-915e-89d9f3f21ae7	d48b90d7-2da2-4105-ba0c-ee39244f79cd	a34644cb-4fa6-4ad1-904f-3e26b23679cd	پیشرفت اولیه و بررسی نیازمندی‌ها	221	100	2026-06-28	approved	6367109c-4684-4a1b-a6b5-9843aa3f6a9d	\N	fc96f42c-cac3-4158-8a0a-eb53a0724349	2026-07-20 11:46:45.199839+00	2026-07-20 11:46:45.199839+00
6fa5de46-9edd-404a-915e-89d9f3f21ae7	0d0ae620-c75a-4269-a959-cf4c2519bcdb	a34644cb-4fa6-4ad1-904f-3e26b23679cd	تست و اطمینان از عملکرد صحیح	146	30	2026-07-01	approved	6367109c-4684-4a1b-a6b5-9843aa3f6a9d	\N	f20f245f-18c9-4f42-978b-6e72a3690333	2026-07-20 11:46:45.199839+00	2026-07-20 11:46:45.199839+00
6fa5de46-9edd-404a-915e-89d9f3f21ae7	0d0ae620-c75a-4269-a959-cf4c2519bcdb	a34644cb-4fa6-4ad1-904f-3e26b23679cd	رفع اشکالات و بازبینی	109	60	2026-07-03	approved	6367109c-4684-4a1b-a6b5-9843aa3f6a9d	\N	4843cd0c-bf10-4773-81e0-483a2cf040c5	2026-07-20 11:46:45.199839+00	2026-07-20 11:46:45.199839+00
6fa5de46-9edd-404a-915e-89d9f3f21ae7	e451e390-7cb3-45f5-a25d-1335bfe3ca60	7c364485-75f2-4d57-81ee-62ec42c62177	پیاده‌سازی بخش اصلی	70	39	2026-07-16	approved	6367109c-4684-4a1b-a6b5-9843aa3f6a9d	\N	aafe48f1-c104-4564-9636-d9c2b30bc7e5	2026-07-20 11:46:45.199839+00	2026-07-20 11:46:45.199839+00
6fa5de46-9edd-404a-915e-89d9f3f21ae7	75cc91d1-fd1a-4ac5-9ae5-9e2eb4ed3715	fd5161f1-4abf-4cc9-8f06-914566393088	رفع اشکالات و بازبینی	143	33	2026-07-16	approved	6367109c-4684-4a1b-a6b5-9843aa3f6a9d	\N	d7c07ed6-be54-4d01-b19d-a077b41be281	2026-07-20 11:46:45.199839+00	2026-07-20 11:46:45.199839+00
6fa5de46-9edd-404a-915e-89d9f3f21ae7	7f153083-0304-4496-8838-c775e807ec51	a34644cb-4fa6-4ad1-904f-3e26b23679cd	تست و اطمینان از عملکرد صحیح	99	26	2026-07-16	approved	6367109c-4684-4a1b-a6b5-9843aa3f6a9d	\N	e783ffd3-6347-4808-8f55-0771dd1de121	2026-07-20 11:46:45.199839+00	2026-07-20 11:46:45.199839+00
6fa5de46-9edd-404a-915e-89d9f3f21ae7	7f153083-0304-4496-8838-c775e807ec51	a34644cb-4fa6-4ad1-904f-3e26b23679cd	رفع اشکالات و بازبینی	140	46	2026-07-16	approved	6367109c-4684-4a1b-a6b5-9843aa3f6a9d	\N	f7fc62f8-1786-4462-9c13-2b8b40c96290	2026-07-20 11:46:45.199839+00	2026-07-20 11:46:45.199839+00
6fa5de46-9edd-404a-915e-89d9f3f21ae7	7f153083-0304-4496-8838-c775e807ec51	a34644cb-4fa6-4ad1-904f-3e26b23679cd	مستندسازی و نهایی‌سازی	154	100	2026-07-16	approved	6367109c-4684-4a1b-a6b5-9843aa3f6a9d	\N	0805ca36-746e-44f6-ab4c-668d8f37873b	2026-07-20 11:46:45.199839+00	2026-07-20 11:46:45.199839+00
6fa5de46-9edd-404a-915e-89d9f3f21ae7	7f153083-0304-4496-8838-c775e807ec51	a34644cb-4fa6-4ad1-904f-3e26b23679cd	پیشرفت اولیه و بررسی نیازمندی‌ها	86	100	2026-07-16	approved	6367109c-4684-4a1b-a6b5-9843aa3f6a9d	\N	2799a7db-26fd-436c-b1f2-23d6c26752b5	2026-07-20 11:46:45.199839+00	2026-07-20 11:46:45.199839+00
6fa5de46-9edd-404a-915e-89d9f3f21ae7	0bd35daf-b38a-47a0-a71f-47935c219f7e	fd5161f1-4abf-4cc9-8f06-914566393088	پیاده‌سازی بخش اصلی	107	26	2026-07-16	approved	6367109c-4684-4a1b-a6b5-9843aa3f6a9d	\N	9f07ce4d-4bdf-436b-97a5-d262287514fb	2026-07-20 11:46:45.199839+00	2026-07-20 11:46:45.199839+00
6fa5de46-9edd-404a-915e-89d9f3f21ae7	c16d9478-c862-4552-9449-7c1052e7cf4e	3051f03b-e73a-49fb-a6d2-ab7406c6850b	رفع اشکالات و بازبینی	113	23	2026-07-01	approved	6367109c-4684-4a1b-a6b5-9843aa3f6a9d	\N	c95ee788-fd18-41fd-bd49-f84c3951faef	2026-07-20 11:46:45.199839+00	2026-07-20 11:46:45.199839+00
6fa5de46-9edd-404a-915e-89d9f3f21ae7	c16d9478-c862-4552-9449-7c1052e7cf4e	3051f03b-e73a-49fb-a6d2-ab7406c6850b	تست و اطمینان از عملکرد صحیح	221	66	2026-07-02	approved	6367109c-4684-4a1b-a6b5-9843aa3f6a9d	\N	f1794e47-962c-46ae-a365-4b85fa69c1eb	2026-07-20 11:46:45.199839+00	2026-07-20 11:46:45.199839+00
6fa5de46-9edd-404a-915e-89d9f3f21ae7	ca32b349-c851-4ab9-bd87-fb52e71301f5	7c364485-75f2-4d57-81ee-62ec42c62177	پیاده‌سازی بخش اصلی	158	37	2026-07-14	approved	6367109c-4684-4a1b-a6b5-9843aa3f6a9d	\N	01aa845b-3a34-48ee-831b-d86933e8a793	2026-07-20 11:46:45.199839+00	2026-07-20 11:46:45.199839+00
6fa5de46-9edd-404a-915e-89d9f3f21ae7	ca32b349-c851-4ab9-bd87-fb52e71301f5	7c364485-75f2-4d57-81ee-62ec42c62177	پیشرفت اولیه و بررسی نیازمندی‌ها	141	40	2026-07-16	approved	6367109c-4684-4a1b-a6b5-9843aa3f6a9d	\N	48b9f4d5-461b-4a8e-9f1c-338d2f22feaf	2026-07-20 11:46:45.199839+00	2026-07-20 11:46:45.199839+00
6fa5de46-9edd-404a-915e-89d9f3f21ae7	17fd0d2e-bea8-49db-9e4b-977410c1436d	398f8c1c-1d8b-48eb-9aed-08ebb479cff3	رفع اشکالات و بازبینی	177	33	2026-06-25	approved	6367109c-4684-4a1b-a6b5-9843aa3f6a9d	\N	2d2dbf74-cfe4-4838-9e88-78e13384bbeb	2026-07-20 11:46:45.199839+00	2026-07-20 11:46:45.199839+00
6fa5de46-9edd-404a-915e-89d9f3f21ae7	17fd0d2e-bea8-49db-9e4b-977410c1436d	398f8c1c-1d8b-48eb-9aed-08ebb479cff3	تست و اطمینان از عملکرد صحیح	104	46	2026-06-29	approved	6367109c-4684-4a1b-a6b5-9843aa3f6a9d	\N	5f85df66-aeaf-4f09-9591-1ee8fbf8c13f	2026-07-20 11:46:45.199839+00	2026-07-20 11:46:45.199839+00
6fa5de46-9edd-404a-915e-89d9f3f21ae7	17fd0d2e-bea8-49db-9e4b-977410c1436d	398f8c1c-1d8b-48eb-9aed-08ebb479cff3	پیشرفت اولیه و بررسی نیازمندی‌ها	113	75	2026-07-03	approved	6367109c-4684-4a1b-a6b5-9843aa3f6a9d	\N	2ab526d0-4b61-4ed6-9a64-489234c0c3ec	2026-07-20 11:46:45.199839+00	2026-07-20 11:46:45.199839+00
6fa5de46-9edd-404a-915e-89d9f3f21ae7	17fd0d2e-bea8-49db-9e4b-977410c1436d	398f8c1c-1d8b-48eb-9aed-08ebb479cff3	رفع اشکالات و بازبینی	52	100	2026-07-07	approved	6367109c-4684-4a1b-a6b5-9843aa3f6a9d	\N	472193b8-a885-434d-b765-d6c9cc653f6c	2026-07-20 11:46:45.199839+00	2026-07-20 11:46:45.199839+00
6fa5de46-9edd-404a-915e-89d9f3f21ae7	156a0446-48a0-438b-8371-97c044b40621	7c364485-75f2-4d57-81ee-62ec42c62177	تست و اطمینان از عملکرد صحیح	164	22	2026-07-10	approved	6367109c-4684-4a1b-a6b5-9843aa3f6a9d	\N	4e4038a7-2b8f-4900-ade2-7a82e118ab13	2026-07-20 11:46:45.199839+00	2026-07-20 11:46:45.199839+00
6fa5de46-9edd-404a-915e-89d9f3f21ae7	903966b3-a4b3-4b35-9602-ae369fc78145	6367109c-4684-4a1b-a6b5-9843aa3f6a9d	پیاده‌سازی بخش اصلی	115	25	2026-07-05	submitted	\N	\N	1d0a85dc-6c53-477a-ad28-444a0c2663fe	2026-07-20 11:46:45.199839+00	2026-07-20 11:46:45.199839+00
6fa5de46-9edd-404a-915e-89d9f3f21ae7	903966b3-a4b3-4b35-9602-ae369fc78145	6367109c-4684-4a1b-a6b5-9843aa3f6a9d	پیشرفت اولیه و بررسی نیازمندی‌ها	165	72	2026-07-06	approved	6367109c-4684-4a1b-a6b5-9843aa3f6a9d	\N	4de4ab46-f1a5-4591-aa6c-c6fab199cb6f	2026-07-20 11:46:45.199839+00	2026-07-20 11:46:45.199839+00
6fa5de46-9edd-404a-915e-89d9f3f21ae7	903966b3-a4b3-4b35-9602-ae369fc78145	6367109c-4684-4a1b-a6b5-9843aa3f6a9d	رفع اشکالات و بازبینی	119	100	2026-07-09	submitted	\N	\N	4632ac7c-249c-4e0f-83d7-0131943d206a	2026-07-20 11:46:45.199839+00	2026-07-20 11:46:45.199839+00
6fa5de46-9edd-404a-915e-89d9f3f21ae7	903966b3-a4b3-4b35-9602-ae369fc78145	6367109c-4684-4a1b-a6b5-9843aa3f6a9d	پیاده‌سازی بخش اصلی	95	100	2026-07-11	approved	6367109c-4684-4a1b-a6b5-9843aa3f6a9d	\N	5a6aa29c-c158-42df-bb3b-f4c3695ad6cf	2026-07-20 11:46:45.199839+00	2026-07-20 11:46:45.199839+00
6fa5de46-9edd-404a-915e-89d9f3f21ae7	aa7e499d-78a9-4801-ab15-4ebd32fa7b4c	a42bd423-3577-42e0-b239-611eb7480fb9	پیشرفت اولیه و بررسی نیازمندی‌ها	75	40	2026-07-16	approved	6367109c-4684-4a1b-a6b5-9843aa3f6a9d	\N	63fb0cf5-1afd-4ec4-82da-e206b381d94d	2026-07-20 11:46:45.199839+00	2026-07-20 11:46:45.199839+00
6fa5de46-9edd-404a-915e-89d9f3f21ae7	aa7e499d-78a9-4801-ab15-4ebd32fa7b4c	a42bd423-3577-42e0-b239-611eb7480fb9	تست و اطمینان از عملکرد صحیح	223	76	2026-07-16	approved	6367109c-4684-4a1b-a6b5-9843aa3f6a9d	\N	52fa14ec-9490-43d7-a7a9-7fec355343ad	2026-07-20 11:46:45.199839+00	2026-07-20 11:46:45.199839+00
6fa5de46-9edd-404a-915e-89d9f3f21ae7	d3965c11-7b79-4cb6-b732-2199df57b453	3051f03b-e73a-49fb-a6d2-ab7406c6850b	رفع اشکالات و بازبینی	68	34	2026-07-16	submitted	\N	\N	48546f7d-96b0-4fbf-8af7-729e6610ff69	2026-07-20 11:46:45.199839+00	2026-07-20 11:46:45.199839+00
6fa5de46-9edd-404a-915e-89d9f3f21ae7	d3965c11-7b79-4cb6-b732-2199df57b453	3051f03b-e73a-49fb-a6d2-ab7406c6850b	رفع اشکالات و بازبینی	233	56	2026-07-16	approved	6367109c-4684-4a1b-a6b5-9843aa3f6a9d	\N	97b26596-a8ec-4819-8edf-ca4398f79fde	2026-07-20 11:46:45.199839+00	2026-07-20 11:46:45.199839+00
6fa5de46-9edd-404a-915e-89d9f3f21ae7	d3965c11-7b79-4cb6-b732-2199df57b453	3051f03b-e73a-49fb-a6d2-ab7406c6850b	پیشرفت اولیه و بررسی نیازمندی‌ها	109	100	2026-07-16	approved	6367109c-4684-4a1b-a6b5-9843aa3f6a9d	\N	76ae43ff-0c36-4131-8578-7fdcfbdbe80c	2026-07-20 11:46:45.199839+00	2026-07-20 11:46:45.199839+00
6fa5de46-9edd-404a-915e-89d9f3f21ae7	d3965c11-7b79-4cb6-b732-2199df57b453	3051f03b-e73a-49fb-a6d2-ab7406c6850b	رفع اشکالات و بازبینی	103	88	2026-07-16	approved	6367109c-4684-4a1b-a6b5-9843aa3f6a9d	\N	f0cea293-78c0-4b9c-ad36-b631e07a4f92	2026-07-20 11:46:45.199839+00	2026-07-20 11:46:45.199839+00
6fa5de46-9edd-404a-915e-89d9f3f21ae7	4b76762a-881e-4462-a7bc-3272453adee1	a42bd423-3577-42e0-b239-611eb7480fb9	تست و اطمینان از عملکرد صحیح	178	37	2026-07-11	approved	6367109c-4684-4a1b-a6b5-9843aa3f6a9d	\N	6f800009-70a5-49e0-8889-a7830c69ec8b	2026-07-20 11:46:45.199839+00	2026-07-20 11:46:45.199839+00
6fa5de46-9edd-404a-915e-89d9f3f21ae7	be013270-01ba-4c5c-adf3-d8e6b6654379	fd5161f1-4abf-4cc9-8f06-914566393088	مستندسازی و نهایی‌سازی	196	26	2026-06-24	submitted	\N	\N	67644327-3580-4c18-9477-e97797a3a8c8	2026-07-20 11:46:45.199839+00	2026-07-20 11:46:45.199839+00
6fa5de46-9edd-404a-915e-89d9f3f21ae7	ec1da620-276d-4d69-badd-3948c3bee1de	7c364485-75f2-4d57-81ee-62ec42c62177	مستندسازی و نهایی‌سازی	68	21	2026-07-16	approved	6367109c-4684-4a1b-a6b5-9843aa3f6a9d	\N	a1cb9a1b-09b6-48bb-885a-531091ae4fef	2026-07-20 11:46:45.199839+00	2026-07-20 11:46:45.199839+00
6fa5de46-9edd-404a-915e-89d9f3f21ae7	ec1da620-276d-4d69-badd-3948c3bee1de	7c364485-75f2-4d57-81ee-62ec42c62177	پیشرفت اولیه و بررسی نیازمندی‌ها	237	60	2026-07-16	approved	6367109c-4684-4a1b-a6b5-9843aa3f6a9d	\N	0b9fa5b9-6864-4c47-8d5e-721f4d81ff62	2026-07-20 11:46:45.199839+00	2026-07-20 11:46:45.199839+00
6fa5de46-9edd-404a-915e-89d9f3f21ae7	ec1da620-276d-4d69-badd-3948c3bee1de	7c364485-75f2-4d57-81ee-62ec42c62177	مستندسازی و نهایی‌سازی	195	75	2026-07-16	approved	6367109c-4684-4a1b-a6b5-9843aa3f6a9d	\N	9a69dae8-4065-4a33-b189-4531b6970421	2026-07-20 11:46:45.199839+00	2026-07-20 11:46:45.199839+00
6fa5de46-9edd-404a-915e-89d9f3f21ae7	1639a96d-6f30-41b1-8f7c-23d614fb9e1d	6367109c-4684-4a1b-a6b5-9843aa3f6a9d	تست و اطمینان از عملکرد صحیح	142	36	2026-07-16	approved	6367109c-4684-4a1b-a6b5-9843aa3f6a9d	\N	b1a83063-03e0-4059-bbf5-484ed10749ae	2026-07-20 11:46:45.199839+00	2026-07-20 11:46:45.199839+00
6fa5de46-9edd-404a-915e-89d9f3f21ae7	60aa40bf-c203-48d1-92b7-5ee74b85041b	a34644cb-4fa6-4ad1-904f-3e26b23679cd	رفع اشکالات و بازبینی	102	32	2026-06-17	approved	6367109c-4684-4a1b-a6b5-9843aa3f6a9d	\N	3b9bfb05-130b-4e64-b3fd-ede35df09434	2026-07-20 11:46:45.199839+00	2026-07-20 11:46:45.199839+00
6fa5de46-9edd-404a-915e-89d9f3f21ae7	60aa40bf-c203-48d1-92b7-5ee74b85041b	a34644cb-4fa6-4ad1-904f-3e26b23679cd	رفع اشکالات و بازبینی	203	78	2026-06-21	approved	6367109c-4684-4a1b-a6b5-9843aa3f6a9d	\N	e81a566c-99d0-49a2-b660-ae4ecaa99b20	2026-07-20 11:46:45.199839+00	2026-07-20 11:46:45.199839+00
6fa5de46-9edd-404a-915e-89d9f3f21ae7	c69cc453-5588-4e44-9c89-463498234c1c	a34644cb-4fa6-4ad1-904f-3e26b23679cd	پیشرفت اولیه و بررسی نیازمندی‌ها	172	32	2026-06-26	approved	6367109c-4684-4a1b-a6b5-9843aa3f6a9d	\N	4bd3ac29-6eac-443a-9115-b735f0b060d5	2026-07-20 11:46:45.199839+00	2026-07-20 11:46:45.199839+00
6fa5de46-9edd-404a-915e-89d9f3f21ae7	e7232dd1-78bf-4723-ac57-d3f7008289f1	7c364485-75f2-4d57-81ee-62ec42c62177	مستندسازی و نهایی‌سازی	68	30	2026-06-22	submitted	\N	\N	c9f9f3e9-bab8-4da7-a6cf-b72749dd7545	2026-07-20 11:46:45.199839+00	2026-07-20 11:46:45.199839+00
6fa5de46-9edd-404a-915e-89d9f3f21ae7	e7232dd1-78bf-4723-ac57-d3f7008289f1	7c364485-75f2-4d57-81ee-62ec42c62177	پیاده‌سازی بخش اصلی	119	58	2026-06-23	approved	6367109c-4684-4a1b-a6b5-9843aa3f6a9d	\N	6b373aed-6790-4591-84a7-877752a228e7	2026-07-20 11:46:45.199839+00	2026-07-20 11:46:45.199839+00
6fa5de46-9edd-404a-915e-89d9f3f21ae7	e7232dd1-78bf-4723-ac57-d3f7008289f1	7c364485-75f2-4d57-81ee-62ec42c62177	پیشرفت اولیه و بررسی نیازمندی‌ها	109	100	2026-06-30	approved	6367109c-4684-4a1b-a6b5-9843aa3f6a9d	\N	f06a0e28-0765-4d82-a505-42f810a70246	2026-07-20 11:46:45.199839+00	2026-07-20 11:46:45.199839+00
6fa5de46-9edd-404a-915e-89d9f3f21ae7	c211fdc2-48f5-4fd8-bf90-cb3be185efdb	3051f03b-e73a-49fb-a6d2-ab7406c6850b	مستندسازی و نهایی‌سازی	53	40	2026-07-16	submitted	\N	\N	e7c817ce-8749-4fb2-8e08-8380e1567dac	2026-07-20 11:46:45.199839+00	2026-07-20 11:46:45.199839+00
6fa5de46-9edd-404a-915e-89d9f3f21ae7	c211fdc2-48f5-4fd8-bf90-cb3be185efdb	3051f03b-e73a-49fb-a6d2-ab7406c6850b	پیشرفت اولیه و بررسی نیازمندی‌ها	122	58	2026-07-16	approved	6367109c-4684-4a1b-a6b5-9843aa3f6a9d	\N	9b8f844c-bfe8-4a5e-8199-d4543d91bab7	2026-07-20 11:46:45.199839+00	2026-07-20 11:46:45.199839+00
6fa5de46-9edd-404a-915e-89d9f3f21ae7	c211fdc2-48f5-4fd8-bf90-cb3be185efdb	3051f03b-e73a-49fb-a6d2-ab7406c6850b	رفع اشکالات و بازبینی	226	100	2026-07-16	submitted	\N	\N	4a1df028-141a-4bce-a447-f0d169c8f726	2026-07-20 11:46:45.199839+00	2026-07-20 11:46:45.199839+00
6fa5de46-9edd-404a-915e-89d9f3f21ae7	c211fdc2-48f5-4fd8-bf90-cb3be185efdb	3051f03b-e73a-49fb-a6d2-ab7406c6850b	پیاده‌سازی بخش اصلی	69	88	2026-07-16	approved	6367109c-4684-4a1b-a6b5-9843aa3f6a9d	\N	435b5ed1-2fa2-4445-ac94-1b07ab7575be	2026-07-20 11:46:45.199839+00	2026-07-20 11:46:45.199839+00
6fa5de46-9edd-404a-915e-89d9f3f21ae7	f5640209-74c5-4815-9d05-113b3c86f7a8	fd5161f1-4abf-4cc9-8f06-914566393088	مستندسازی و نهایی‌سازی	227	37	2026-07-05	approved	6367109c-4684-4a1b-a6b5-9843aa3f6a9d	\N	2cc80863-9bdf-44b6-a57e-e56ee8a5fd88	2026-07-20 11:46:45.199839+00	2026-07-20 11:46:45.199839+00
6fa5de46-9edd-404a-915e-89d9f3f21ae7	f5640209-74c5-4815-9d05-113b3c86f7a8	fd5161f1-4abf-4cc9-8f06-914566393088	رفع اشکالات و بازبینی	226	78	2026-07-06	approved	6367109c-4684-4a1b-a6b5-9843aa3f6a9d	\N	2f7847f0-8c36-4eb5-b6d9-8d17b8493617	2026-07-20 11:46:45.199839+00	2026-07-20 11:46:45.199839+00
6fa5de46-9edd-404a-915e-89d9f3f21ae7	f5640209-74c5-4815-9d05-113b3c86f7a8	fd5161f1-4abf-4cc9-8f06-914566393088	مستندسازی و نهایی‌سازی	126	72	2026-07-09	approved	6367109c-4684-4a1b-a6b5-9843aa3f6a9d	\N	334f9a39-b79b-4cbe-b678-b943e59fcbc4	2026-07-20 11:46:45.199839+00	2026-07-20 11:46:45.199839+00
6fa5de46-9edd-404a-915e-89d9f3f21ae7	279eb63e-f5c2-46bf-92d9-aa876361a61a	398f8c1c-1d8b-48eb-9aed-08ebb479cff3	مستندسازی و نهایی‌سازی	237	25	2026-07-09	approved	6367109c-4684-4a1b-a6b5-9843aa3f6a9d	\N	d8ead96d-0502-4ee4-9bed-b91fc2abe7ab	2026-07-20 11:46:45.199839+00	2026-07-20 11:46:45.199839+00
6fa5de46-9edd-404a-915e-89d9f3f21ae7	279eb63e-f5c2-46bf-92d9-aa876361a61a	398f8c1c-1d8b-48eb-9aed-08ebb479cff3	پیشرفت اولیه و بررسی نیازمندی‌ها	135	62	2026-07-13	approved	6367109c-4684-4a1b-a6b5-9843aa3f6a9d	\N	7480c3aa-6279-46b8-99df-fa0c69c0a1d0	2026-07-20 11:46:45.199839+00	2026-07-20 11:46:45.199839+00
6fa5de46-9edd-404a-915e-89d9f3f21ae7	8ec02445-7355-49ab-b911-35cb8c4ea078	a34644cb-4fa6-4ad1-904f-3e26b23679cd	تست و اطمینان از عملکرد صحیح	89	37	2026-07-16	approved	6367109c-4684-4a1b-a6b5-9843aa3f6a9d	\N	d8b12e16-d606-4c13-9557-b63ba8298b2a	2026-07-20 11:46:45.199839+00	2026-07-20 11:46:45.199839+00
6fa5de46-9edd-404a-915e-89d9f3f21ae7	8ec02445-7355-49ab-b911-35cb8c4ea078	a34644cb-4fa6-4ad1-904f-3e26b23679cd	تست و اطمینان از عملکرد صحیح	79	62	2026-07-16	approved	6367109c-4684-4a1b-a6b5-9843aa3f6a9d	\N	9d39b12e-4d67-472a-8b1b-67e0eee9ca8f	2026-07-20 11:46:45.199839+00	2026-07-20 11:46:45.199839+00
6fa5de46-9edd-404a-915e-89d9f3f21ae7	7b4304d6-b830-473c-ad71-3aecec27ef3f	a34644cb-4fa6-4ad1-904f-3e26b23679cd	رفع اشکالات و بازبینی	229	32	2026-07-13	approved	6367109c-4684-4a1b-a6b5-9843aa3f6a9d	\N	7a11118c-74a9-41b8-bfa1-2f069f921316	2026-07-20 11:46:45.199839+00	2026-07-20 11:46:45.199839+00
6fa5de46-9edd-404a-915e-89d9f3f21ae7	7b4304d6-b830-473c-ad71-3aecec27ef3f	a34644cb-4fa6-4ad1-904f-3e26b23679cd	پیاده‌سازی بخش اصلی	239	52	2026-07-16	approved	6367109c-4684-4a1b-a6b5-9843aa3f6a9d	\N	37c8862c-d02a-445e-bf08-5b06ae97c9b4	2026-07-20 11:46:45.199839+00	2026-07-20 11:46:45.199839+00
6fa5de46-9edd-404a-915e-89d9f3f21ae7	7b4304d6-b830-473c-ad71-3aecec27ef3f	a34644cb-4fa6-4ad1-904f-3e26b23679cd	رفع اشکالات و بازبینی	43	100	2026-07-16	approved	6367109c-4684-4a1b-a6b5-9843aa3f6a9d	\N	f4dca08c-6d43-4478-a838-5f13ae2ca15e	2026-07-20 11:46:45.199839+00	2026-07-20 11:46:45.199839+00
6fa5de46-9edd-404a-915e-89d9f3f21ae7	7b4304d6-b830-473c-ad71-3aecec27ef3f	a34644cb-4fa6-4ad1-904f-3e26b23679cd	رفع اشکالات و بازبینی	171	92	2026-07-16	approved	6367109c-4684-4a1b-a6b5-9843aa3f6a9d	\N	0872f3ec-52c0-4525-ab38-0ff96a07d8f1	2026-07-20 11:46:45.199839+00	2026-07-20 11:46:45.199839+00
6fa5de46-9edd-404a-915e-89d9f3f21ae7	4256e0f2-8fc0-4354-8cbb-a703616e6fdb	398f8c1c-1d8b-48eb-9aed-08ebb479cff3	پیشرفت اولیه و بررسی نیازمندی‌ها	225	25	2026-07-16	approved	6367109c-4684-4a1b-a6b5-9843aa3f6a9d	\N	544979d1-663a-497d-88df-f3a65d63a448	2026-07-20 11:46:45.199839+00	2026-07-20 11:46:45.199839+00
6fa5de46-9edd-404a-915e-89d9f3f21ae7	f9f52157-5706-42e8-ba84-94fb0b5cbc46	a42bd423-3577-42e0-b239-611eb7480fb9	پیاده‌سازی بخش اصلی	141	22	2026-07-06	submitted	\N	\N	173292c2-fc1f-45e6-ab83-ac3efe9d472f	2026-07-20 11:46:45.199839+00	2026-07-20 11:46:45.199839+00
6fa5de46-9edd-404a-915e-89d9f3f21ae7	f9f52157-5706-42e8-ba84-94fb0b5cbc46	a42bd423-3577-42e0-b239-611eb7480fb9	رفع اشکالات و بازبینی	36	66	2026-07-08	submitted	\N	\N	bab1f4da-d29c-4991-9a71-2fc4a3be9be1	2026-07-20 11:46:45.199839+00	2026-07-20 11:46:45.199839+00
6fa5de46-9edd-404a-915e-89d9f3f21ae7	f9f52157-5706-42e8-ba84-94fb0b5cbc46	a42bd423-3577-42e0-b239-611eb7480fb9	رفع اشکالات و بازبینی	90	96	2026-07-08	approved	6367109c-4684-4a1b-a6b5-9843aa3f6a9d	\N	4bf1c30a-6723-4ecb-bfbb-62b4d8dc33cd	2026-07-20 11:46:45.199839+00	2026-07-20 11:46:45.199839+00
6fa5de46-9edd-404a-915e-89d9f3f21ae7	ae097835-15a0-4a7f-813b-c223078b8148	7c364485-75f2-4d57-81ee-62ec42c62177	پیاده‌سازی بخش اصلی	37	30	2026-07-15	approved	6367109c-4684-4a1b-a6b5-9843aa3f6a9d	\N	4e0c1afe-f990-4328-9476-1cd8204b7529	2026-07-20 11:46:45.199839+00	2026-07-20 11:46:45.199839+00
6fa5de46-9edd-404a-915e-89d9f3f21ae7	3a03cbf3-fc3c-4a97-acaa-d8c84104bbc3	3051f03b-e73a-49fb-a6d2-ab7406c6850b	پیاده‌سازی بخش اصلی	39	29	2026-06-27	submitted	\N	\N	a2ee2d95-2089-49a0-9b90-be50b11dadaa	2026-07-20 11:46:45.199839+00	2026-07-20 11:46:45.199839+00
6fa5de46-9edd-404a-915e-89d9f3f21ae7	64de961b-59bf-4162-86d1-b405db905e09	a42bd423-3577-42e0-b239-611eb7480fb9	تست و اطمینان از عملکرد صحیح	144	39	2026-07-16	approved	6367109c-4684-4a1b-a6b5-9843aa3f6a9d	\N	5f4ceb7d-1683-4f13-82fd-f66f5be8b0c3	2026-07-20 11:46:45.199839+00	2026-07-20 11:46:45.199839+00
6fa5de46-9edd-404a-915e-89d9f3f21ae7	64de961b-59bf-4162-86d1-b405db905e09	a42bd423-3577-42e0-b239-611eb7480fb9	پیشرفت اولیه و بررسی نیازمندی‌ها	34	56	2026-07-16	approved	6367109c-4684-4a1b-a6b5-9843aa3f6a9d	\N	4d6baa3c-72dc-48b0-901d-19de829a9a26	2026-07-20 11:46:45.199839+00	2026-07-20 11:46:45.199839+00
6fa5de46-9edd-404a-915e-89d9f3f21ae7	64de961b-59bf-4162-86d1-b405db905e09	a42bd423-3577-42e0-b239-611eb7480fb9	پیاده‌سازی بخش اصلی	170	100	2026-07-16	approved	6367109c-4684-4a1b-a6b5-9843aa3f6a9d	\N	9d1d586d-d48c-454a-962f-f2e3f77cd2a3	2026-07-20 11:46:45.199839+00	2026-07-20 11:46:45.199839+00
6fa5de46-9edd-404a-915e-89d9f3f21ae7	64de961b-59bf-4162-86d1-b405db905e09	a42bd423-3577-42e0-b239-611eb7480fb9	پیشرفت اولیه و بررسی نیازمندی‌ها	228	100	2026-07-16	approved	6367109c-4684-4a1b-a6b5-9843aa3f6a9d	\N	b0de14a5-79c7-40d7-91fb-c5296eac5098	2026-07-20 11:46:45.199839+00	2026-07-20 11:46:45.199839+00
6fa5de46-9edd-404a-915e-89d9f3f21ae7	bd2cd141-e749-4b6a-98d6-dfd1319beef1	fd5161f1-4abf-4cc9-8f06-914566393088	پیاده‌سازی بخش اصلی	137	40	2026-07-16	approved	6367109c-4684-4a1b-a6b5-9843aa3f6a9d	\N	16d6be84-6901-49e0-a603-d308f0fc52c3	2026-07-20 11:46:45.199839+00	2026-07-20 11:46:45.199839+00
6fa5de46-9edd-404a-915e-89d9f3f21ae7	bd2cd141-e749-4b6a-98d6-dfd1319beef1	fd5161f1-4abf-4cc9-8f06-914566393088	تست و اطمینان از عملکرد صحیح	182	74	2026-07-16	approved	6367109c-4684-4a1b-a6b5-9843aa3f6a9d	\N	8e460674-fb59-4019-9718-21e41f14f5fe	2026-07-20 11:46:45.199839+00	2026-07-20 11:46:45.199839+00
6fa5de46-9edd-404a-915e-89d9f3f21ae7	432c4aeb-3987-47e0-a01f-bef4f8810818	3051f03b-e73a-49fb-a6d2-ab7406c6850b	پیاده‌سازی بخش اصلی	104	33	2026-06-21	approved	6367109c-4684-4a1b-a6b5-9843aa3f6a9d	\N	40022fa3-a69a-4e55-9c9a-1624bbed739f	2026-07-20 11:46:45.199839+00	2026-07-20 11:46:45.199839+00
6fa5de46-9edd-404a-915e-89d9f3f21ae7	6936dbee-7827-4efd-aee9-d7629e484549	56ee4c58-1504-48a5-b37d-7d040bb2bd16	مستندسازی و نهایی‌سازی	196	31	2026-06-27	approved	6f0889c3-21cf-4af8-92e8-834e06a4a09c	\N	cff6aacf-b7e4-4af8-aa87-a3f85571234e	2026-07-20 11:46:45.199839+00	2026-07-20 11:46:45.199839+00
6fa5de46-9edd-404a-915e-89d9f3f21ae7	6936dbee-7827-4efd-aee9-d7629e484549	56ee4c58-1504-48a5-b37d-7d040bb2bd16	رفع اشکالات و بازبینی	122	72	2026-06-30	approved	6f0889c3-21cf-4af8-92e8-834e06a4a09c	\N	5d82f2bc-3791-4637-a7e6-eee1efb60a74	2026-07-20 11:46:45.199839+00	2026-07-20 11:46:45.199839+00
6fa5de46-9edd-404a-915e-89d9f3f21ae7	6936dbee-7827-4efd-aee9-d7629e484549	56ee4c58-1504-48a5-b37d-7d040bb2bd16	تست و اطمینان از عملکرد صحیح	55	100	2026-07-05	approved	6f0889c3-21cf-4af8-92e8-834e06a4a09c	\N	ffb42b73-9d24-40e0-aa6a-ee986ae0893f	2026-07-20 11:46:45.199839+00	2026-07-20 11:46:45.199839+00
6fa5de46-9edd-404a-915e-89d9f3f21ae7	6936dbee-7827-4efd-aee9-d7629e484549	56ee4c58-1504-48a5-b37d-7d040bb2bd16	پیاده‌سازی بخش اصلی	124	100	2026-07-06	approved	6f0889c3-21cf-4af8-92e8-834e06a4a09c	\N	42f86442-79b9-46e1-8553-ce57343bea82	2026-07-20 11:46:45.199839+00	2026-07-20 11:46:45.199839+00
6fa5de46-9edd-404a-915e-89d9f3f21ae7	37811384-4506-46ba-b7d6-fd22faef27e0	eeebc2e6-a734-4f02-8d65-173ba01323d3	مستندسازی و نهایی‌سازی	86	24	2026-07-14	approved	6f0889c3-21cf-4af8-92e8-834e06a4a09c	\N	b8fed5ec-93dd-45e3-9889-7c3ee1726df6	2026-07-20 11:46:45.199839+00	2026-07-20 11:46:45.199839+00
6fa5de46-9edd-404a-915e-89d9f3f21ae7	37811384-4506-46ba-b7d6-fd22faef27e0	eeebc2e6-a734-4f02-8d65-173ba01323d3	رفع اشکالات و بازبینی	171	76	2026-07-15	approved	6f0889c3-21cf-4af8-92e8-834e06a4a09c	\N	9fdbcc1c-22c4-422e-a41d-ba51d5ebeab7	2026-07-20 11:46:45.199839+00	2026-07-20 11:46:45.199839+00
6fa5de46-9edd-404a-915e-89d9f3f21ae7	37811384-4506-46ba-b7d6-fd22faef27e0	eeebc2e6-a734-4f02-8d65-173ba01323d3	رفع اشکالات و بازبینی	69	78	2026-07-16	approved	6f0889c3-21cf-4af8-92e8-834e06a4a09c	\N	90dc9949-07a1-40be-a93f-6c68726008e1	2026-07-20 11:46:45.199839+00	2026-07-20 11:46:45.199839+00
6fa5de46-9edd-404a-915e-89d9f3f21ae7	37811384-4506-46ba-b7d6-fd22faef27e0	eeebc2e6-a734-4f02-8d65-173ba01323d3	پیاده‌سازی بخش اصلی	127	100	2026-07-16	approved	6f0889c3-21cf-4af8-92e8-834e06a4a09c	\N	028cc3d6-07aa-400e-95a7-d1c2b43fb919	2026-07-20 11:46:45.199839+00	2026-07-20 11:46:45.199839+00
6fa5de46-9edd-404a-915e-89d9f3f21ae7	680ad17e-0f48-4f85-b84b-f55076da0101	56ee4c58-1504-48a5-b37d-7d040bb2bd16	رفع اشکالات و بازبینی	95	35	2026-07-14	approved	6f0889c3-21cf-4af8-92e8-834e06a4a09c	\N	2714622a-79fc-4f63-a88e-87aa5655d9c7	2026-07-20 11:46:45.199839+00	2026-07-20 11:46:45.199839+00
6fa5de46-9edd-404a-915e-89d9f3f21ae7	680ad17e-0f48-4f85-b84b-f55076da0101	56ee4c58-1504-48a5-b37d-7d040bb2bd16	رفع اشکالات و بازبینی	73	48	2026-07-16	approved	6f0889c3-21cf-4af8-92e8-834e06a4a09c	\N	6d73ea91-713d-48e2-bed7-44d7c07ea86d	2026-07-20 11:46:45.199839+00	2026-07-20 11:46:45.199839+00
6fa5de46-9edd-404a-915e-89d9f3f21ae7	0f6f5d1e-dad5-472d-ab4d-083a537ae985	eeebc2e6-a734-4f02-8d65-173ba01323d3	مستندسازی و نهایی‌سازی	194	21	2026-07-16	approved	6f0889c3-21cf-4af8-92e8-834e06a4a09c	\N	106a5b75-9f9f-419e-9731-1001e62c4334	2026-07-20 11:46:45.199839+00	2026-07-20 11:46:45.199839+00
6fa5de46-9edd-404a-915e-89d9f3f21ae7	0f6f5d1e-dad5-472d-ab4d-083a537ae985	eeebc2e6-a734-4f02-8d65-173ba01323d3	پیشرفت اولیه و بررسی نیازمندی‌ها	239	42	2026-07-16	approved	6f0889c3-21cf-4af8-92e8-834e06a4a09c	\N	26c18660-46e6-446a-b728-7c7d5570f39f	2026-07-20 11:46:45.199839+00	2026-07-20 11:46:45.199839+00
6fa5de46-9edd-404a-915e-89d9f3f21ae7	0f6f5d1e-dad5-472d-ab4d-083a537ae985	eeebc2e6-a734-4f02-8d65-173ba01323d3	تست و اطمینان از عملکرد صحیح	65	100	2026-07-16	approved	6f0889c3-21cf-4af8-92e8-834e06a4a09c	\N	69bd9894-dfe5-4206-9c1b-eb58a7a47bcb	2026-07-20 11:46:45.199839+00	2026-07-20 11:46:45.199839+00
6fa5de46-9edd-404a-915e-89d9f3f21ae7	0f6f5d1e-dad5-472d-ab4d-083a537ae985	eeebc2e6-a734-4f02-8d65-173ba01323d3	پیشرفت اولیه و بررسی نیازمندی‌ها	211	96	2026-07-16	approved	6f0889c3-21cf-4af8-92e8-834e06a4a09c	\N	69628089-92ae-4fd7-a9c2-4d599ec7496a	2026-07-20 11:46:45.199839+00	2026-07-20 11:46:45.199839+00
6fa5de46-9edd-404a-915e-89d9f3f21ae7	eb3394e8-cd27-4963-a3c5-3c8ec8260541	eeebc2e6-a734-4f02-8d65-173ba01323d3	مستندسازی و نهایی‌سازی	146	31	2026-07-16	approved	6f0889c3-21cf-4af8-92e8-834e06a4a09c	\N	151bc4cc-54eb-4ce7-acf8-a37cc2582085	2026-07-20 11:46:45.199839+00	2026-07-20 11:46:45.199839+00
6fa5de46-9edd-404a-915e-89d9f3f21ae7	566aeb3c-816f-4ea9-acfa-12c59c919b83	ca92a9d5-cf4a-4b8b-9fe5-6fadd5c44ca2	تست و اطمینان از عملکرد صحیح	34	20	2026-06-20	approved	6f0889c3-21cf-4af8-92e8-834e06a4a09c	\N	1929da72-52d0-472d-a1f4-2bfa4657998f	2026-07-20 11:46:45.199839+00	2026-07-20 11:46:45.199839+00
6fa5de46-9edd-404a-915e-89d9f3f21ae7	66c624bd-1b9f-4b95-8fe8-841c426b3555	56ee4c58-1504-48a5-b37d-7d040bb2bd16	پیشرفت اولیه و بررسی نیازمندی‌ها	165	28	2026-06-25	approved	6f0889c3-21cf-4af8-92e8-834e06a4a09c	\N	a0eacf34-6c59-473d-86e9-45d364b67510	2026-07-20 11:46:45.199839+00	2026-07-20 11:46:45.199839+00
6fa5de46-9edd-404a-915e-89d9f3f21ae7	66c624bd-1b9f-4b95-8fe8-841c426b3555	56ee4c58-1504-48a5-b37d-7d040bb2bd16	پیشرفت اولیه و بررسی نیازمندی‌ها	158	66	2026-06-28	approved	6f0889c3-21cf-4af8-92e8-834e06a4a09c	\N	3b79c03f-179d-4b7f-a437-2fee85600f09	2026-07-20 11:46:45.199839+00	2026-07-20 11:46:45.199839+00
6fa5de46-9edd-404a-915e-89d9f3f21ae7	66c624bd-1b9f-4b95-8fe8-841c426b3555	56ee4c58-1504-48a5-b37d-7d040bb2bd16	پیشرفت اولیه و بررسی نیازمندی‌ها	54	100	2026-06-29	approved	6f0889c3-21cf-4af8-92e8-834e06a4a09c	\N	73723e0d-ca4f-4109-9486-9fa41b3143aa	2026-07-20 11:46:45.199839+00	2026-07-20 11:46:45.199839+00
6fa5de46-9edd-404a-915e-89d9f3f21ae7	66c624bd-1b9f-4b95-8fe8-841c426b3555	56ee4c58-1504-48a5-b37d-7d040bb2bd16	پیاده‌سازی بخش اصلی	79	100	2026-07-01	approved	6f0889c3-21cf-4af8-92e8-834e06a4a09c	\N	215978b0-8056-40a6-a54e-611704f3b7c9	2026-07-20 11:46:45.199839+00	2026-07-20 11:46:45.199839+00
6fa5de46-9edd-404a-915e-89d9f3f21ae7	995017e1-c3e9-4df9-b4dc-0db4625b2975	6f0889c3-21cf-4af8-92e8-834e06a4a09c	رفع اشکالات و بازبینی	233	32	2026-07-09	approved	6f0889c3-21cf-4af8-92e8-834e06a4a09c	\N	d720653d-3d7d-4057-b8e6-7942de150626	2026-07-20 11:46:45.199839+00	2026-07-20 11:46:45.199839+00
6fa5de46-9edd-404a-915e-89d9f3f21ae7	995017e1-c3e9-4df9-b4dc-0db4625b2975	6f0889c3-21cf-4af8-92e8-834e06a4a09c	رفع اشکالات و بازبینی	133	68	2026-07-10	approved	6f0889c3-21cf-4af8-92e8-834e06a4a09c	\N	5e7cbf8c-0963-411b-9fe9-e8acf113c5d6	2026-07-20 11:46:45.199839+00	2026-07-20 11:46:45.199839+00
6fa5de46-9edd-404a-915e-89d9f3f21ae7	995017e1-c3e9-4df9-b4dc-0db4625b2975	6f0889c3-21cf-4af8-92e8-834e06a4a09c	پیاده‌سازی بخش اصلی	106	66	2026-07-13	approved	6f0889c3-21cf-4af8-92e8-834e06a4a09c	\N	feab3f85-6036-4376-a44f-743f8840bb06	2026-07-20 11:46:45.199839+00	2026-07-20 11:46:45.199839+00
6fa5de46-9edd-404a-915e-89d9f3f21ae7	46f41b87-47fd-4311-9a10-07d024230cd8	6f0889c3-21cf-4af8-92e8-834e06a4a09c	تست و اطمینان از عملکرد صحیح	171	35	2026-07-16	approved	6f0889c3-21cf-4af8-92e8-834e06a4a09c	\N	115aa1ca-dadc-4dbd-89bd-f6f6f610fa9a	2026-07-20 11:46:45.199839+00	2026-07-20 11:46:45.199839+00
6fa5de46-9edd-404a-915e-89d9f3f21ae7	190e7424-585e-4e91-a2a1-d657b07c0f19	eeebc2e6-a734-4f02-8d65-173ba01323d3	پیاده‌سازی بخش اصلی	51	35	2026-07-16	approved	6f0889c3-21cf-4af8-92e8-834e06a4a09c	\N	5b0b2772-3943-460b-b204-652c06ebc26d	2026-07-20 11:46:45.199839+00	2026-07-20 11:46:45.199839+00
6fa5de46-9edd-404a-915e-89d9f3f21ae7	95957ef8-e0e3-4f8d-b4e3-9909ad077929	ca92a9d5-cf4a-4b8b-9fe5-6fadd5c44ca2	مستندسازی و نهایی‌سازی	54	36	2026-07-09	approved	6f0889c3-21cf-4af8-92e8-834e06a4a09c	\N	c564289c-e890-4700-be65-73451cda30ce	2026-07-20 11:46:45.199839+00	2026-07-20 11:46:45.199839+00
6fa5de46-9edd-404a-915e-89d9f3f21ae7	95957ef8-e0e3-4f8d-b4e3-9909ad077929	ca92a9d5-cf4a-4b8b-9fe5-6fadd5c44ca2	پیاده‌سازی بخش اصلی	84	76	2026-07-10	approved	6f0889c3-21cf-4af8-92e8-834e06a4a09c	\N	d00a9a69-c721-46e6-977e-f636d61a489c	2026-07-20 11:46:45.199839+00	2026-07-20 11:46:45.199839+00
6fa5de46-9edd-404a-915e-89d9f3f21ae7	95957ef8-e0e3-4f8d-b4e3-9909ad077929	ca92a9d5-cf4a-4b8b-9fe5-6fadd5c44ca2	رفع اشکالات و بازبینی	41	66	2026-07-16	approved	6f0889c3-21cf-4af8-92e8-834e06a4a09c	\N	1e210dc4-d029-4b06-b2f2-d03f48ec9ae7	2026-07-20 11:46:45.199839+00	2026-07-20 11:46:45.199839+00
6fa5de46-9edd-404a-915e-89d9f3f21ae7	95957ef8-e0e3-4f8d-b4e3-9909ad077929	ca92a9d5-cf4a-4b8b-9fe5-6fadd5c44ca2	مستندسازی و نهایی‌سازی	174	84	2026-07-16	approved	6f0889c3-21cf-4af8-92e8-834e06a4a09c	\N	776686b2-f4a7-4faf-aafc-2c7a68e22e68	2026-07-20 11:46:45.199839+00	2026-07-20 11:46:45.199839+00
6fa5de46-9edd-404a-915e-89d9f3f21ae7	0f5cb204-6b80-4a1a-982a-32579c78683e	56ee4c58-1504-48a5-b37d-7d040bb2bd16	پیشرفت اولیه و بررسی نیازمندی‌ها	83	38	2026-07-16	approved	6f0889c3-21cf-4af8-92e8-834e06a4a09c	\N	b9436b5c-68f0-44ca-a69a-113532a6da4d	2026-07-20 11:46:45.199839+00	2026-07-20 11:46:45.199839+00
6fa5de46-9edd-404a-915e-89d9f3f21ae7	0f5cb204-6b80-4a1a-982a-32579c78683e	56ee4c58-1504-48a5-b37d-7d040bb2bd16	تست و اطمینان از عملکرد صحیح	49	58	2026-07-16	approved	6f0889c3-21cf-4af8-92e8-834e06a4a09c	\N	d9d44409-9bde-4d45-826d-9d58049a086a	2026-07-20 11:46:45.199839+00	2026-07-20 11:46:45.199839+00
6fa5de46-9edd-404a-915e-89d9f3f21ae7	20cc3706-fdc2-4841-a886-40388acfd567	ca92a9d5-cf4a-4b8b-9fe5-6fadd5c44ca2	مستندسازی و نهایی‌سازی	129	37	2026-07-16	approved	6f0889c3-21cf-4af8-92e8-834e06a4a09c	\N	290bb3dc-2fe4-43dc-be09-e664e8eddf57	2026-07-20 11:46:45.199839+00	2026-07-20 11:46:45.199839+00
6fa5de46-9edd-404a-915e-89d9f3f21ae7	20cc3706-fdc2-4841-a886-40388acfd567	ca92a9d5-cf4a-4b8b-9fe5-6fadd5c44ca2	تست و اطمینان از عملکرد صحیح	223	48	2026-07-16	approved	6f0889c3-21cf-4af8-92e8-834e06a4a09c	\N	9d77dd8a-a657-4290-874c-c180b058f3ac	2026-07-20 11:46:45.199839+00	2026-07-20 11:46:45.199839+00
6fa5de46-9edd-404a-915e-89d9f3f21ae7	7cd602f5-ed0a-4789-81c5-9a45d9b91187	eeebc2e6-a734-4f02-8d65-173ba01323d3	پیشرفت اولیه و بررسی نیازمندی‌ها	55	33	2026-07-15	approved	6f0889c3-21cf-4af8-92e8-834e06a4a09c	\N	38cfd214-6787-48fa-904f-ad6d0fea9acd	2026-07-20 11:46:45.199839+00	2026-07-20 11:46:45.199839+00
6fa5de46-9edd-404a-915e-89d9f3f21ae7	7bb78b43-0b5f-488b-b05c-7b0930ffa3fc	c28803c6-5155-4136-94b4-4f91ec6ee698	رفع اشکالات و بازبینی	184	39	2026-06-27	approved	6f0889c3-21cf-4af8-92e8-834e06a4a09c	\N	65809338-938d-4028-aa1a-6cbd5001cd90	2026-07-20 11:46:45.199839+00	2026-07-20 11:46:45.199839+00
6fa5de46-9edd-404a-915e-89d9f3f21ae7	7bb78b43-0b5f-488b-b05c-7b0930ffa3fc	c28803c6-5155-4136-94b4-4f91ec6ee698	رفع اشکالات و بازبینی	37	80	2026-07-01	approved	6f0889c3-21cf-4af8-92e8-834e06a4a09c	\N	d7e86be1-ff9c-4f8a-ace0-9e166c20f9d0	2026-07-20 11:46:45.199839+00	2026-07-20 11:46:45.199839+00
6fa5de46-9edd-404a-915e-89d9f3f21ae7	33dfea5d-b48a-45f0-b28b-c621230bd50f	ca92a9d5-cf4a-4b8b-9fe5-6fadd5c44ca2	رفع اشکالات و بازبینی	171	32	2026-07-08	approved	6f0889c3-21cf-4af8-92e8-834e06a4a09c	\N	8e9178c2-1fb1-4cd5-9be9-d45ec98270ea	2026-07-20 11:46:45.199839+00	2026-07-20 11:46:45.199839+00
6fa5de46-9edd-404a-915e-89d9f3f21ae7	33dfea5d-b48a-45f0-b28b-c621230bd50f	ca92a9d5-cf4a-4b8b-9fe5-6fadd5c44ca2	مستندسازی و نهایی‌سازی	199	64	2026-07-12	approved	6f0889c3-21cf-4af8-92e8-834e06a4a09c	\N	36e36bd0-f3ef-45da-8231-65093b1b242e	2026-07-20 11:46:45.199839+00	2026-07-20 11:46:45.199839+00
6fa5de46-9edd-404a-915e-89d9f3f21ae7	33dfea5d-b48a-45f0-b28b-c621230bd50f	ca92a9d5-cf4a-4b8b-9fe5-6fadd5c44ca2	رفع اشکالات و بازبینی	234	81	2026-07-10	submitted	\N	\N	1d504d53-b7d3-4ff0-a2c7-170f8f2f7784	2026-07-20 11:46:45.199839+00	2026-07-20 11:46:45.199839+00
6fa5de46-9edd-404a-915e-89d9f3f21ae7	b7f31b43-deac-4dae-9104-2ff3f33915ca	ca92a9d5-cf4a-4b8b-9fe5-6fadd5c44ca2	رفع اشکالات و بازبینی	69	32	2026-07-16	approved	6f0889c3-21cf-4af8-92e8-834e06a4a09c	\N	ff76e941-3687-4b94-bf61-0095e6afad66	2026-07-20 11:46:45.199839+00	2026-07-20 11:46:45.199839+00
6fa5de46-9edd-404a-915e-89d9f3f21ae7	a37f5732-0696-4f0d-b603-e26cd93f3688	3cba84f1-51a4-4831-ac2b-61b820a1122a	پیشرفت اولیه و بررسی نیازمندی‌ها	53	20	2026-07-16	approved	6f0889c3-21cf-4af8-92e8-834e06a4a09c	\N	0c322ba1-acf6-4719-988a-9a5601a8cc1c	2026-07-20 11:46:45.199839+00	2026-07-20 11:46:45.199839+00
6fa5de46-9edd-404a-915e-89d9f3f21ae7	a37f5732-0696-4f0d-b603-e26cd93f3688	3cba84f1-51a4-4831-ac2b-61b820a1122a	رفع اشکالات و بازبینی	56	48	2026-07-16	approved	6f0889c3-21cf-4af8-92e8-834e06a4a09c	\N	6ae7be05-50c7-4cb0-9075-26eb2efbc204	2026-07-20 11:46:45.199839+00	2026-07-20 11:46:45.199839+00
6fa5de46-9edd-404a-915e-89d9f3f21ae7	d32a4eca-60fa-4c01-93ff-13abe1005dcb	ca92a9d5-cf4a-4b8b-9fe5-6fadd5c44ca2	تست و اطمینان از عملکرد صحیح	144	37	2026-07-16	approved	6f0889c3-21cf-4af8-92e8-834e06a4a09c	\N	3e084346-e274-4041-8bd1-529c6c092855	2026-07-20 11:46:45.199839+00	2026-07-20 11:46:45.199839+00
6fa5de46-9edd-404a-915e-89d9f3f21ae7	46e98616-fcd9-49e0-a8e5-cd0505debd0b	c28803c6-5155-4136-94b4-4f91ec6ee698	پیشرفت اولیه و بررسی نیازمندی‌ها	52	31	2026-07-15	approved	6f0889c3-21cf-4af8-92e8-834e06a4a09c	\N	5f106958-717d-4ea6-b0c2-9dfb91e22576	2026-07-20 11:46:45.199839+00	2026-07-20 11:46:45.199839+00
6fa5de46-9edd-404a-915e-89d9f3f21ae7	46e98616-fcd9-49e0-a8e5-cd0505debd0b	c28803c6-5155-4136-94b4-4f91ec6ee698	مستندسازی و نهایی‌سازی	183	60	2026-07-16	approved	6f0889c3-21cf-4af8-92e8-834e06a4a09c	\N	b5e8f9e4-06f4-4b66-a225-9091eb4327fb	2026-07-20 11:46:45.199839+00	2026-07-20 11:46:45.199839+00
6fa5de46-9edd-404a-915e-89d9f3f21ae7	46e98616-fcd9-49e0-a8e5-cd0505debd0b	c28803c6-5155-4136-94b4-4f91ec6ee698	پیشرفت اولیه و بررسی نیازمندی‌ها	104	99	2026-07-16	approved	6f0889c3-21cf-4af8-92e8-834e06a4a09c	\N	27ab810f-bedd-483b-a471-573c5d0a83fc	2026-07-20 11:46:45.199839+00	2026-07-20 11:46:45.199839+00
6fa5de46-9edd-404a-915e-89d9f3f21ae7	46e98616-fcd9-49e0-a8e5-cd0505debd0b	c28803c6-5155-4136-94b4-4f91ec6ee698	پیشرفت اولیه و بررسی نیازمندی‌ها	215	100	2026-07-16	approved	6f0889c3-21cf-4af8-92e8-834e06a4a09c	\N	d24bd8e5-e183-4329-9f6b-2d5293ceea53	2026-07-20 11:46:45.199839+00	2026-07-20 11:46:45.199839+00
6fa5de46-9edd-404a-915e-89d9f3f21ae7	d18e6ec9-2009-41e5-956a-25cf555f07eb	56ee4c58-1504-48a5-b37d-7d040bb2bd16	تست و اطمینان از عملکرد صحیح	73	24	2026-07-07	approved	6f0889c3-21cf-4af8-92e8-834e06a4a09c	\N	b13656fd-dc95-45ab-bb07-f72e5fe93a4c	2026-07-20 11:46:45.199839+00	2026-07-20 11:46:45.199839+00
6fa5de46-9edd-404a-915e-89d9f3f21ae7	d18e6ec9-2009-41e5-956a-25cf555f07eb	56ee4c58-1504-48a5-b37d-7d040bb2bd16	رفع اشکالات و بازبینی	98	70	2026-07-10	approved	6f0889c3-21cf-4af8-92e8-834e06a4a09c	\N	f67e1676-4a94-499b-a9c0-8f64e4e6fb71	2026-07-20 11:46:45.199839+00	2026-07-20 11:46:45.199839+00
6fa5de46-9edd-404a-915e-89d9f3f21ae7	d110d70f-a267-4df9-b72c-356f496e52b5	eeebc2e6-a734-4f02-8d65-173ba01323d3	پیاده‌سازی بخش اصلی	141	28	2026-07-16	approved	6f0889c3-21cf-4af8-92e8-834e06a4a09c	\N	be4e4c8c-028c-4dc7-bd62-c10c41f57551	2026-07-20 11:46:45.199839+00	2026-07-20 11:46:45.199839+00
6fa5de46-9edd-404a-915e-89d9f3f21ae7	d110d70f-a267-4df9-b72c-356f496e52b5	eeebc2e6-a734-4f02-8d65-173ba01323d3	رفع اشکالات و بازبینی	153	44	2026-07-16	approved	6f0889c3-21cf-4af8-92e8-834e06a4a09c	\N	0a1b93ad-42d7-4113-a8e1-df47e0b565d0	2026-07-20 11:46:45.199839+00	2026-07-20 11:46:45.199839+00
6fa5de46-9edd-404a-915e-89d9f3f21ae7	8a54f6c7-15a2-4f49-869d-374382cdc607	6f0889c3-21cf-4af8-92e8-834e06a4a09c	تست و اطمینان از عملکرد صحیح	182	39	2026-07-01	submitted	\N	\N	61560867-0c45-4c7d-8026-ecec266c81a8	2026-07-20 11:46:45.199839+00	2026-07-20 11:46:45.199839+00
6fa5de46-9edd-404a-915e-89d9f3f21ae7	8a54f6c7-15a2-4f49-869d-374382cdc607	6f0889c3-21cf-4af8-92e8-834e06a4a09c	پیاده‌سازی بخش اصلی	107	40	2026-07-03	approved	6f0889c3-21cf-4af8-92e8-834e06a4a09c	\N	efbeb1e3-0e52-4de5-917f-9596d9a8ff34	2026-07-20 11:46:45.199839+00	2026-07-20 11:46:45.199839+00
6fa5de46-9edd-404a-915e-89d9f3f21ae7	8a54f6c7-15a2-4f49-869d-374382cdc607	6f0889c3-21cf-4af8-92e8-834e06a4a09c	مستندسازی و نهایی‌سازی	127	90	2026-07-09	approved	6f0889c3-21cf-4af8-92e8-834e06a4a09c	\N	5a37cdda-f65b-4b85-9292-8e30e7484758	2026-07-20 11:46:45.199839+00	2026-07-20 11:46:45.199839+00
6fa5de46-9edd-404a-915e-89d9f3f21ae7	7dc26ec8-b454-4d4b-94bf-5cbee79ea22b	9255642c-40dc-467b-8897-f23fd07f2394	تست و اطمینان از عملکرد صحیح	238	40	2026-07-15	approved	6f0889c3-21cf-4af8-92e8-834e06a4a09c	\N	eb8a8279-10e0-4cf1-b2ab-4d141f418280	2026-07-20 11:46:45.199839+00	2026-07-20 11:46:45.199839+00
6fa5de46-9edd-404a-915e-89d9f3f21ae7	7dc26ec8-b454-4d4b-94bf-5cbee79ea22b	9255642c-40dc-467b-8897-f23fd07f2394	رفع اشکالات و بازبینی	112	78	2026-07-16	approved	6f0889c3-21cf-4af8-92e8-834e06a4a09c	\N	d0be92f2-3f1c-4402-81bc-95d08f14d75d	2026-07-20 11:46:45.199839+00	2026-07-20 11:46:45.199839+00
6fa5de46-9edd-404a-915e-89d9f3f21ae7	7dc26ec8-b454-4d4b-94bf-5cbee79ea22b	9255642c-40dc-467b-8897-f23fd07f2394	تست و اطمینان از عملکرد صحیح	110	75	2026-07-16	approved	6f0889c3-21cf-4af8-92e8-834e06a4a09c	\N	bbc8d05b-5de9-483c-9d82-80b37ed9bf71	2026-07-20 11:46:45.199839+00	2026-07-20 11:46:45.199839+00
6fa5de46-9edd-404a-915e-89d9f3f21ae7	7dc26ec8-b454-4d4b-94bf-5cbee79ea22b	9255642c-40dc-467b-8897-f23fd07f2394	رفع اشکالات و بازبینی	104	100	2026-07-16	approved	6f0889c3-21cf-4af8-92e8-834e06a4a09c	\N	3a40cef3-7891-48bf-81b5-8c6af5c922ce	2026-07-20 11:46:45.199839+00	2026-07-20 11:46:45.199839+00
6fa5de46-9edd-404a-915e-89d9f3f21ae7	f2dfd45a-e150-4e88-9b9a-fa581f81e864	6f0889c3-21cf-4af8-92e8-834e06a4a09c	رفع اشکالات و بازبینی	239	32	2026-07-16	approved	6f0889c3-21cf-4af8-92e8-834e06a4a09c	\N	05e92386-acbf-48f7-a464-df7878c430fb	2026-07-20 11:46:45.199839+00	2026-07-20 11:46:45.199839+00
6fa5de46-9edd-404a-915e-89d9f3f21ae7	f2dfd45a-e150-4e88-9b9a-fa581f81e864	6f0889c3-21cf-4af8-92e8-834e06a4a09c	مستندسازی و نهایی‌سازی	81	76	2026-07-16	approved	6f0889c3-21cf-4af8-92e8-834e06a4a09c	\N	fbbb73d4-dfc5-41b5-a3e3-f9dbe024864a	2026-07-20 11:46:45.199839+00	2026-07-20 11:46:45.199839+00
6fa5de46-9edd-404a-915e-89d9f3f21ae7	f2dfd45a-e150-4e88-9b9a-fa581f81e864	6f0889c3-21cf-4af8-92e8-834e06a4a09c	مستندسازی و نهایی‌سازی	36	100	2026-07-16	approved	6f0889c3-21cf-4af8-92e8-834e06a4a09c	\N	0496ec8d-352e-4459-b304-6564fd23b025	2026-07-20 11:46:45.199839+00	2026-07-20 11:46:45.199839+00
6fa5de46-9edd-404a-915e-89d9f3f21ae7	f2dfd45a-e150-4e88-9b9a-fa581f81e864	6f0889c3-21cf-4af8-92e8-834e06a4a09c	رفع اشکالات و بازبینی	207	88	2026-07-16	approved	6f0889c3-21cf-4af8-92e8-834e06a4a09c	\N	776fe969-6f1b-4fcd-ac5c-8aa1431e0e06	2026-07-20 11:46:45.199839+00	2026-07-20 11:46:45.199839+00
6fa5de46-9edd-404a-915e-89d9f3f21ae7	b2926a65-3c28-4155-a0f9-fbc0d411c93a	6f0889c3-21cf-4af8-92e8-834e06a4a09c	رفع اشکالات و بازبینی	91	28	2026-07-16	approved	6f0889c3-21cf-4af8-92e8-834e06a4a09c	\N	a91c80f8-32c7-4a03-8c58-6a06d5d73703	2026-07-20 11:46:45.199839+00	2026-07-20 11:46:45.199839+00
6fa5de46-9edd-404a-915e-89d9f3f21ae7	b2926a65-3c28-4155-a0f9-fbc0d411c93a	6f0889c3-21cf-4af8-92e8-834e06a4a09c	تست و اطمینان از عملکرد صحیح	48	68	2026-07-16	submitted	\N	\N	0cd450db-bd2c-4d41-8c63-414f902eeb05	2026-07-20 11:46:45.199839+00	2026-07-20 11:46:45.199839+00
6fa5de46-9edd-404a-915e-89d9f3f21ae7	b2926a65-3c28-4155-a0f9-fbc0d411c93a	6f0889c3-21cf-4af8-92e8-834e06a4a09c	مستندسازی و نهایی‌سازی	159	99	2026-07-16	approved	6f0889c3-21cf-4af8-92e8-834e06a4a09c	\N	c9bca084-c7de-4e0c-97a2-5c676545b810	2026-07-20 11:46:45.199839+00	2026-07-20 11:46:45.199839+00
6fa5de46-9edd-404a-915e-89d9f3f21ae7	b2926a65-3c28-4155-a0f9-fbc0d411c93a	6f0889c3-21cf-4af8-92e8-834e06a4a09c	رفع اشکالات و بازبینی	209	100	2026-07-16	submitted	\N	\N	fc4b49fc-4a7f-4222-91c6-620f4d1b02b2	2026-07-20 11:46:45.199839+00	2026-07-20 11:46:45.199839+00
6fa5de46-9edd-404a-915e-89d9f3f21ae7	ec2f4901-dfc4-4422-b699-df52142bd228	3cba84f1-51a4-4831-ac2b-61b820a1122a	پیاده‌سازی بخش اصلی	198	31	2026-06-24	approved	6f0889c3-21cf-4af8-92e8-834e06a4a09c	\N	7f8d9147-c05b-4027-82d8-f48bf8b45470	2026-07-20 11:46:45.199839+00	2026-07-20 11:46:45.199839+00
6fa5de46-9edd-404a-915e-89d9f3f21ae7	0c14f52f-0056-4a5d-b696-7c9e31e5d9cf	eeebc2e6-a734-4f02-8d65-173ba01323d3	مستندسازی و نهایی‌سازی	195	40	2026-07-16	approved	6f0889c3-21cf-4af8-92e8-834e06a4a09c	\N	12262447-c5ba-4734-86d1-ce0c4d04ca6a	2026-07-20 11:46:45.199839+00	2026-07-20 11:46:45.199839+00
6fa5de46-9edd-404a-915e-89d9f3f21ae7	0c14f52f-0056-4a5d-b696-7c9e31e5d9cf	eeebc2e6-a734-4f02-8d65-173ba01323d3	رفع اشکالات و بازبینی	233	66	2026-07-16	approved	6f0889c3-21cf-4af8-92e8-834e06a4a09c	\N	fd46a948-4398-4115-8373-c4a2e36f2d60	2026-07-20 11:46:45.199839+00	2026-07-20 11:46:45.199839+00
6fa5de46-9edd-404a-915e-89d9f3f21ae7	324e8bab-ef77-4c60-a317-8d4d2d3ed147	3cba84f1-51a4-4831-ac2b-61b820a1122a	پیشرفت اولیه و بررسی نیازمندی‌ها	96	27	2026-07-16	approved	6f0889c3-21cf-4af8-92e8-834e06a4a09c	\N	d314a9c9-a730-47a5-b720-81a7531cff4c	2026-07-20 11:46:45.199839+00	2026-07-20 11:46:45.199839+00
6fa5de46-9edd-404a-915e-89d9f3f21ae7	753f4042-a371-4370-99a6-9567d5083ad5	c28803c6-5155-4136-94b4-4f91ec6ee698	رفع اشکالات و بازبینی	130	34	2026-07-16	approved	6f0889c3-21cf-4af8-92e8-834e06a4a09c	\N	df1adc9c-5715-42ac-8c1d-9829fc34e9ca	2026-07-20 11:46:45.199839+00	2026-07-20 11:46:45.199839+00
6fa5de46-9edd-404a-915e-89d9f3f21ae7	753f4042-a371-4370-99a6-9567d5083ad5	c28803c6-5155-4136-94b4-4f91ec6ee698	رفع اشکالات و بازبینی	36	70	2026-07-16	approved	6f0889c3-21cf-4af8-92e8-834e06a4a09c	\N	a7f3707e-25c1-4e5f-a320-f12951d70dc3	2026-07-20 11:46:45.199839+00	2026-07-20 11:46:45.199839+00
6fa5de46-9edd-404a-915e-89d9f3f21ae7	29ecdd0a-4db0-49ff-a3b3-d9fc0f8976b3	eeebc2e6-a734-4f02-8d65-173ba01323d3	پیشرفت اولیه و بررسی نیازمندی‌ها	59	24	2026-07-16	approved	6f0889c3-21cf-4af8-92e8-834e06a4a09c	\N	985eab83-0daf-41ff-96ed-a03efab15e58	2026-07-20 11:46:45.199839+00	2026-07-20 11:46:45.199839+00
6fa5de46-9edd-404a-915e-89d9f3f21ae7	41c28438-84b5-424e-a22a-1b1b4460fe51	ca92a9d5-cf4a-4b8b-9fe5-6fadd5c44ca2	رفع اشکالات و بازبینی	146	26	2026-07-16	approved	6f0889c3-21cf-4af8-92e8-834e06a4a09c	\N	ea0da2ef-0e64-4b47-bbcb-490453cb7288	2026-07-20 11:46:45.199839+00	2026-07-20 11:46:45.199839+00
6fa5de46-9edd-404a-915e-89d9f3f21ae7	41c28438-84b5-424e-a22a-1b1b4460fe51	ca92a9d5-cf4a-4b8b-9fe5-6fadd5c44ca2	رفع اشکالات و بازبینی	151	46	2026-07-16	approved	6f0889c3-21cf-4af8-92e8-834e06a4a09c	\N	fee8a243-4e0e-406c-a594-dc9d2fd9287f	2026-07-20 11:46:45.199839+00	2026-07-20 11:46:45.199839+00
6fa5de46-9edd-404a-915e-89d9f3f21ae7	41c28438-84b5-424e-a22a-1b1b4460fe51	ca92a9d5-cf4a-4b8b-9fe5-6fadd5c44ca2	تست و اطمینان از عملکرد صحیح	111	66	2026-07-16	approved	6f0889c3-21cf-4af8-92e8-834e06a4a09c	\N	37af726a-d3a4-44a9-885b-c9de4a0712eb	2026-07-20 11:46:45.199839+00	2026-07-20 11:46:45.199839+00
6fa5de46-9edd-404a-915e-89d9f3f21ae7	0b3d8ba4-20ac-46ff-9d74-64ab23acf432	c28803c6-5155-4136-94b4-4f91ec6ee698	پیشرفت اولیه و بررسی نیازمندی‌ها	35	30	2026-07-16	approved	6f0889c3-21cf-4af8-92e8-834e06a4a09c	\N	e3512f5f-fd86-44aa-a17c-8f2d0b8cb0d1	2026-07-20 11:46:45.199839+00	2026-07-20 11:46:45.199839+00
6fa5de46-9edd-404a-915e-89d9f3f21ae7	0b3d8ba4-20ac-46ff-9d74-64ab23acf432	c28803c6-5155-4136-94b4-4f91ec6ee698	پیاده‌سازی بخش اصلی	219	54	2026-07-16	approved	6f0889c3-21cf-4af8-92e8-834e06a4a09c	\N	8c6e1e46-e8e9-416b-affa-8d990207b4a4	2026-07-20 11:46:45.199839+00	2026-07-20 11:46:45.199839+00
6fa5de46-9edd-404a-915e-89d9f3f21ae7	0b3d8ba4-20ac-46ff-9d74-64ab23acf432	c28803c6-5155-4136-94b4-4f91ec6ee698	مستندسازی و نهایی‌سازی	70	90	2026-07-16	approved	6f0889c3-21cf-4af8-92e8-834e06a4a09c	\N	7173f27a-848f-4fa4-8787-997844c15f56	2026-07-20 11:46:45.199839+00	2026-07-20 11:46:45.199839+00
6fa5de46-9edd-404a-915e-89d9f3f21ae7	9d83b59c-7c0d-4d11-9e98-122c9c203f67	ca92a9d5-cf4a-4b8b-9fe5-6fadd5c44ca2	پیاده‌سازی بخش اصلی	234	32	2026-07-16	approved	6f0889c3-21cf-4af8-92e8-834e06a4a09c	\N	c1a2d72e-4766-4086-9491-ae8ad1c30f88	2026-07-20 11:46:45.199839+00	2026-07-20 11:46:45.199839+00
6fa5de46-9edd-404a-915e-89d9f3f21ae7	9d83b59c-7c0d-4d11-9e98-122c9c203f67	ca92a9d5-cf4a-4b8b-9fe5-6fadd5c44ca2	پیاده‌سازی بخش اصلی	193	66	2026-07-16	approved	6f0889c3-21cf-4af8-92e8-834e06a4a09c	\N	5c2a393b-4435-4d7f-bcfe-b6a5c728aa47	2026-07-20 11:46:45.199839+00	2026-07-20 11:46:45.199839+00
6fa5de46-9edd-404a-915e-89d9f3f21ae7	9d83b59c-7c0d-4d11-9e98-122c9c203f67	ca92a9d5-cf4a-4b8b-9fe5-6fadd5c44ca2	پیشرفت اولیه و بررسی نیازمندی‌ها	218	100	2026-07-16	approved	6f0889c3-21cf-4af8-92e8-834e06a4a09c	\N	5ffe0d9d-191c-4479-ae36-1d0811af8f7e	2026-07-20 11:46:45.199839+00	2026-07-20 11:46:45.199839+00
6fa5de46-9edd-404a-915e-89d9f3f21ae7	9d83b59c-7c0d-4d11-9e98-122c9c203f67	ca92a9d5-cf4a-4b8b-9fe5-6fadd5c44ca2	تست و اطمینان از عملکرد صحیح	181	100	2026-07-16	approved	6f0889c3-21cf-4af8-92e8-834e06a4a09c	\N	ddcbd6f5-96a6-4635-87df-cb3356585428	2026-07-20 11:46:45.199839+00	2026-07-20 11:46:45.199839+00
6fa5de46-9edd-404a-915e-89d9f3f21ae7	a03c2123-6df0-4c97-badd-d22f4d9ebf73	ca92a9d5-cf4a-4b8b-9fe5-6fadd5c44ca2	پیاده‌سازی بخش اصلی	101	22	2026-07-12	submitted	\N	\N	f2165b29-8fe2-42a7-a97e-264bd5c6e1b8	2026-07-20 11:46:45.199839+00	2026-07-20 11:46:45.199839+00
6fa5de46-9edd-404a-915e-89d9f3f21ae7	a03c2123-6df0-4c97-badd-d22f4d9ebf73	ca92a9d5-cf4a-4b8b-9fe5-6fadd5c44ca2	مستندسازی و نهایی‌سازی	77	62	2026-07-13	submitted	\N	\N	83327013-2ffc-4076-a82e-da0ae9d65cca	2026-07-20 11:46:45.199839+00	2026-07-20 11:46:45.199839+00
6fa5de46-9edd-404a-915e-89d9f3f21ae7	a03c2123-6df0-4c97-badd-d22f4d9ebf73	ca92a9d5-cf4a-4b8b-9fe5-6fadd5c44ca2	پیشرفت اولیه و بررسی نیازمندی‌ها	97	100	2026-07-16	approved	6f0889c3-21cf-4af8-92e8-834e06a4a09c	\N	6470dc97-d715-4bbb-802d-d560174c7b55	2026-07-20 11:46:45.199839+00	2026-07-20 11:46:45.199839+00
6fa5de46-9edd-404a-915e-89d9f3f21ae7	a03c2123-6df0-4c97-badd-d22f4d9ebf73	ca92a9d5-cf4a-4b8b-9fe5-6fadd5c44ca2	مستندسازی و نهایی‌سازی	130	100	2026-07-16	approved	6f0889c3-21cf-4af8-92e8-834e06a4a09c	\N	10fd15b6-a102-490a-8b13-729aa1c591b3	2026-07-20 11:46:45.199839+00	2026-07-20 11:46:45.199839+00
6fa5de46-9edd-404a-915e-89d9f3f21ae7	381e15f6-f1fd-4f96-9bfc-4111a27b6c75	ca92a9d5-cf4a-4b8b-9fe5-6fadd5c44ca2	رفع اشکالات و بازبینی	147	39	2026-06-19	approved	6f0889c3-21cf-4af8-92e8-834e06a4a09c	\N	a9ee6bce-da9d-4e08-8be1-049ade43f7f1	2026-07-20 11:46:45.199839+00	2026-07-20 11:46:45.199839+00
6fa5de46-9edd-404a-915e-89d9f3f21ae7	52e5beff-394e-49c7-a71f-c6772d99bb99	ca92a9d5-cf4a-4b8b-9fe5-6fadd5c44ca2	مستندسازی و نهایی‌سازی	181	22	2026-07-06	approved	6f0889c3-21cf-4af8-92e8-834e06a4a09c	\N	b2bb8ad9-d0c3-43d8-ba52-35fc783d6b55	2026-07-20 11:46:45.199839+00	2026-07-20 11:46:45.199839+00
6fa5de46-9edd-404a-915e-89d9f3f21ae7	52e5beff-394e-49c7-a71f-c6772d99bb99	ca92a9d5-cf4a-4b8b-9fe5-6fadd5c44ca2	رفع اشکالات و بازبینی	60	54	2026-07-08	approved	6f0889c3-21cf-4af8-92e8-834e06a4a09c	\N	74afe999-4f19-4eb7-b766-2b6305c838d4	2026-07-20 11:46:45.199839+00	2026-07-20 11:46:45.199839+00
6fa5de46-9edd-404a-915e-89d9f3f21ae7	8c4ad87f-5651-4e69-a592-f5d3d5b4261b	eeebc2e6-a734-4f02-8d65-173ba01323d3	پیاده‌سازی بخش اصلی	125	24	2026-07-16	approved	6f0889c3-21cf-4af8-92e8-834e06a4a09c	\N	c4296cb7-8ed0-4ee4-9bac-70701c55753b	2026-07-20 11:46:45.199839+00	2026-07-20 11:46:45.199839+00
6fa5de46-9edd-404a-915e-89d9f3f21ae7	8c4ad87f-5651-4e69-a592-f5d3d5b4261b	eeebc2e6-a734-4f02-8d65-173ba01323d3	تست و اطمینان از عملکرد صحیح	182	48	2026-07-16	approved	6f0889c3-21cf-4af8-92e8-834e06a4a09c	\N	180573ed-336a-40c6-bd1d-7ace4bb4cba0	2026-07-20 11:46:45.199839+00	2026-07-20 11:46:45.199839+00
6fa5de46-9edd-404a-915e-89d9f3f21ae7	8c4ad87f-5651-4e69-a592-f5d3d5b4261b	eeebc2e6-a734-4f02-8d65-173ba01323d3	تست و اطمینان از عملکرد صحیح	77	100	2026-07-16	approved	6f0889c3-21cf-4af8-92e8-834e06a4a09c	\N	dd0c4f69-4e6b-482d-a580-f3d5178db24e	2026-07-20 11:46:45.199839+00	2026-07-20 11:46:45.199839+00
6fa5de46-9edd-404a-915e-89d9f3f21ae7	dc4689f4-6d61-45c1-8328-3183e938b742	9255642c-40dc-467b-8897-f23fd07f2394	پیاده‌سازی بخش اصلی	77	30	2026-07-16	approved	6f0889c3-21cf-4af8-92e8-834e06a4a09c	\N	41f2f607-e1b5-4e10-b869-6c797a528dfa	2026-07-20 11:46:45.199839+00	2026-07-20 11:46:45.199839+00
6fa5de46-9edd-404a-915e-89d9f3f21ae7	dc4689f4-6d61-45c1-8328-3183e938b742	9255642c-40dc-467b-8897-f23fd07f2394	رفع اشکالات و بازبینی	32	70	2026-07-16	approved	6f0889c3-21cf-4af8-92e8-834e06a4a09c	\N	79e84de9-ac00-48e0-a554-fb03b8a92262	2026-07-20 11:46:45.199839+00	2026-07-20 11:46:45.199839+00
6fa5de46-9edd-404a-915e-89d9f3f21ae7	d0c80c2b-f647-48b7-a8fe-4844a118af16	ca92a9d5-cf4a-4b8b-9fe5-6fadd5c44ca2	تست و اطمینان از عملکرد صحیح	173	36	2026-07-16	approved	6f0889c3-21cf-4af8-92e8-834e06a4a09c	\N	b576f0d9-ab2e-4eb1-9705-1a4ab993af31	2026-07-20 11:46:45.199839+00	2026-07-20 11:46:45.199839+00
6fa5de46-9edd-404a-915e-89d9f3f21ae7	d0c80c2b-f647-48b7-a8fe-4844a118af16	ca92a9d5-cf4a-4b8b-9fe5-6fadd5c44ca2	تست و اطمینان از عملکرد صحیح	205	70	2026-07-16	approved	6f0889c3-21cf-4af8-92e8-834e06a4a09c	\N	87b3bedb-1f50-4a07-8c46-bc903d2cb9f1	2026-07-20 11:46:45.199839+00	2026-07-20 11:46:45.199839+00
6fa5de46-9edd-404a-915e-89d9f3f21ae7	c0443e96-764d-4b26-b347-f193869ca757	c28803c6-5155-4136-94b4-4f91ec6ee698	تست و اطمینان از عملکرد صحیح	72	22	2026-07-03	approved	6f0889c3-21cf-4af8-92e8-834e06a4a09c	\N	c9ea52d2-e21e-4cba-9de8-d912ba9cba97	2026-07-20 11:46:45.199839+00	2026-07-20 11:46:45.199839+00
6fa5de46-9edd-404a-915e-89d9f3f21ae7	c0443e96-764d-4b26-b347-f193869ca757	c28803c6-5155-4136-94b4-4f91ec6ee698	پیاده‌سازی بخش اصلی	104	42	2026-07-04	approved	6f0889c3-21cf-4af8-92e8-834e06a4a09c	\N	d97b65ee-85f2-4f56-a4e8-ed91688e0596	2026-07-20 11:46:45.199839+00	2026-07-20 11:46:45.199839+00
6fa5de46-9edd-404a-915e-89d9f3f21ae7	c0443e96-764d-4b26-b347-f193869ca757	c28803c6-5155-4136-94b4-4f91ec6ee698	پیاده‌سازی بخش اصلی	167	87	2026-07-09	approved	6f0889c3-21cf-4af8-92e8-834e06a4a09c	\N	129016d4-eafa-4ae5-8a8e-40fb0b23a2ec	2026-07-20 11:46:45.199839+00	2026-07-20 11:46:45.199839+00
6fa5de46-9edd-404a-915e-89d9f3f21ae7	c0443e96-764d-4b26-b347-f193869ca757	c28803c6-5155-4136-94b4-4f91ec6ee698	تست و اطمینان از عملکرد صحیح	174	100	2026-07-09	approved	6f0889c3-21cf-4af8-92e8-834e06a4a09c	\N	cedb3ae4-3ad8-485d-a1de-5303814f367a	2026-07-20 11:46:45.199839+00	2026-07-20 11:46:45.199839+00
6fa5de46-9edd-404a-915e-89d9f3f21ae7	6219dc62-e731-4d0f-bdc8-23a6fb51da03	56ee4c58-1504-48a5-b37d-7d040bb2bd16	مستندسازی و نهایی‌سازی	240	31	2026-07-16	approved	6f0889c3-21cf-4af8-92e8-834e06a4a09c	\N	b059ff25-723b-4e3b-b4c6-f34f3620a8da	2026-07-20 11:46:45.199839+00	2026-07-20 11:46:45.199839+00
6fa5de46-9edd-404a-915e-89d9f3f21ae7	e3411c1e-cb9f-4063-9cde-05a1c1959da6	6f0889c3-21cf-4af8-92e8-834e06a4a09c	تست و اطمینان از عملکرد صحیح	56	40	2026-07-16	approved	6f0889c3-21cf-4af8-92e8-834e06a4a09c	\N	5e94a176-3701-4a14-931e-a507ebd50cd8	2026-07-20 11:46:45.199839+00	2026-07-20 11:46:45.199839+00
6fa5de46-9edd-404a-915e-89d9f3f21ae7	24ed313a-81d3-44b0-9bce-ceeda2358989	c28803c6-5155-4136-94b4-4f91ec6ee698	پیشرفت اولیه و بررسی نیازمندی‌ها	145	28	2026-07-16	approved	6f0889c3-21cf-4af8-92e8-834e06a4a09c	\N	57657fa7-fe90-482e-857a-1781d5822d94	2026-07-20 11:46:45.199839+00	2026-07-20 11:46:45.199839+00
6fa5de46-9edd-404a-915e-89d9f3f21ae7	24ed313a-81d3-44b0-9bce-ceeda2358989	c28803c6-5155-4136-94b4-4f91ec6ee698	پیشرفت اولیه و بررسی نیازمندی‌ها	142	46	2026-07-16	approved	6f0889c3-21cf-4af8-92e8-834e06a4a09c	\N	60ca5a2c-2412-493f-8fb2-1231ac4964da	2026-07-20 11:46:45.199839+00	2026-07-20 11:46:45.199839+00
6fa5de46-9edd-404a-915e-89d9f3f21ae7	1d7bea49-a60f-4e4e-b6fb-497bdca812fc	3cba84f1-51a4-4831-ac2b-61b820a1122a	مستندسازی و نهایی‌سازی	206	31	2026-07-01	submitted	\N	\N	44ea126e-31fe-4a47-9906-fd8f9ed461ab	2026-07-20 11:46:45.199839+00	2026-07-20 11:46:45.199839+00
6fa5de46-9edd-404a-915e-89d9f3f21ae7	1d7bea49-a60f-4e4e-b6fb-497bdca812fc	3cba84f1-51a4-4831-ac2b-61b820a1122a	پیاده‌سازی بخش اصلی	230	52	2026-07-05	approved	6f0889c3-21cf-4af8-92e8-834e06a4a09c	\N	1b0b7ee3-9e73-462b-bdf9-5e03ead6d527	2026-07-20 11:46:45.199839+00	2026-07-20 11:46:45.199839+00
6fa5de46-9edd-404a-915e-89d9f3f21ae7	6028d50a-524e-449b-9a28-26d07819e9a3	9255642c-40dc-467b-8897-f23fd07f2394	مستندسازی و نهایی‌سازی	119	37	2026-07-04	approved	6f0889c3-21cf-4af8-92e8-834e06a4a09c	\N	4a660ad7-2057-4360-be38-4fb57a0e4026	2026-07-20 11:46:45.199839+00	2026-07-20 11:46:45.199839+00
6fa5de46-9edd-404a-915e-89d9f3f21ae7	6028d50a-524e-449b-9a28-26d07819e9a3	9255642c-40dc-467b-8897-f23fd07f2394	مستندسازی و نهایی‌سازی	167	50	2026-07-07	approved	6f0889c3-21cf-4af8-92e8-834e06a4a09c	\N	c1428231-0d85-4c47-a809-ef71e0546984	2026-07-20 11:46:45.199839+00	2026-07-20 11:46:45.199839+00
6fa5de46-9edd-404a-915e-89d9f3f21ae7	d04049c4-466c-48ea-9491-72d39a02160d	6f0889c3-21cf-4af8-92e8-834e06a4a09c	رفع اشکالات و بازبینی	176	28	2026-07-16	approved	6f0889c3-21cf-4af8-92e8-834e06a4a09c	\N	8945da40-9a60-41b2-bf7e-afdbbc1ec1f6	2026-07-20 11:46:45.199839+00	2026-07-20 11:46:45.199839+00
6fa5de46-9edd-404a-915e-89d9f3f21ae7	d04049c4-466c-48ea-9491-72d39a02160d	6f0889c3-21cf-4af8-92e8-834e06a4a09c	پیاده‌سازی بخش اصلی	222	66	2026-07-16	approved	6f0889c3-21cf-4af8-92e8-834e06a4a09c	\N	1d6bfd55-c9f8-481c-96a8-92fa1e67fc3d	2026-07-20 11:46:45.199839+00	2026-07-20 11:46:45.199839+00
6fa5de46-9edd-404a-915e-89d9f3f21ae7	d04049c4-466c-48ea-9491-72d39a02160d	6f0889c3-21cf-4af8-92e8-834e06a4a09c	رفع اشکالات و بازبینی	197	72	2026-07-16	approved	6f0889c3-21cf-4af8-92e8-834e06a4a09c	\N	da60c79f-3516-4a03-a98e-acce0f12152b	2026-07-20 11:46:45.199839+00	2026-07-20 11:46:45.199839+00
6fa5de46-9edd-404a-915e-89d9f3f21ae7	10923ca0-79e5-47b8-8c15-9fdd152b4de4	ca92a9d5-cf4a-4b8b-9fe5-6fadd5c44ca2	رفع اشکالات و بازبینی	93	32	2026-07-16	approved	6f0889c3-21cf-4af8-92e8-834e06a4a09c	\N	f252cc97-ddb7-4a35-98ae-9e59bd251108	2026-07-20 11:46:45.199839+00	2026-07-20 11:46:45.199839+00
6fa5de46-9edd-404a-915e-89d9f3f21ae7	10923ca0-79e5-47b8-8c15-9fdd152b4de4	ca92a9d5-cf4a-4b8b-9fe5-6fadd5c44ca2	رفع اشکالات و بازبینی	190	66	2026-07-16	approved	6f0889c3-21cf-4af8-92e8-834e06a4a09c	\N	ffcb2351-f7de-40f8-af71-9759085552c4	2026-07-20 11:46:45.199839+00	2026-07-20 11:46:45.199839+00
6fa5de46-9edd-404a-915e-89d9f3f21ae7	cf69f89a-c4ae-463d-a842-2cbd1f3ff55c	eeebc2e6-a734-4f02-8d65-173ba01323d3	پیشرفت اولیه و بررسی نیازمندی‌ها	133	36	2026-07-15	approved	6f0889c3-21cf-4af8-92e8-834e06a4a09c	\N	3fc2eec1-13e7-47ce-a85b-76cc9642ef47	2026-07-20 11:46:45.199839+00	2026-07-20 11:46:45.199839+00
6fa5de46-9edd-404a-915e-89d9f3f21ae7	cf69f89a-c4ae-463d-a842-2cbd1f3ff55c	eeebc2e6-a734-4f02-8d65-173ba01323d3	رفع اشکالات و بازبینی	146	70	2026-07-16	approved	6f0889c3-21cf-4af8-92e8-834e06a4a09c	\N	d21e8c22-a85e-4a86-a476-2f25402117cf	2026-07-20 11:46:45.199839+00	2026-07-20 11:46:45.199839+00
6fa5de46-9edd-404a-915e-89d9f3f21ae7	cf69f89a-c4ae-463d-a842-2cbd1f3ff55c	eeebc2e6-a734-4f02-8d65-173ba01323d3	پیشرفت اولیه و بررسی نیازمندی‌ها	217	100	2026-07-16	approved	6f0889c3-21cf-4af8-92e8-834e06a4a09c	\N	12a06683-04c3-4ba4-b5a2-580d63c89cdc	2026-07-20 11:46:45.199839+00	2026-07-20 11:46:45.199839+00
6fa5de46-9edd-404a-915e-89d9f3f21ae7	cf69f89a-c4ae-463d-a842-2cbd1f3ff55c	eeebc2e6-a734-4f02-8d65-173ba01323d3	مستندسازی و نهایی‌سازی	131	100	2026-07-16	submitted	\N	\N	1a454612-dd13-4b98-b9aa-9f920ce9f559	2026-07-20 11:46:45.199839+00	2026-07-20 11:46:45.199839+00
6fa5de46-9edd-404a-915e-89d9f3f21ae7	19134162-fb23-47ee-a9ba-964b24c817fe	56ee4c58-1504-48a5-b37d-7d040bb2bd16	رفع اشکالات و بازبینی	102	30	2026-06-28	approved	6f0889c3-21cf-4af8-92e8-834e06a4a09c	\N	bd4f1667-08f6-442c-aad7-fc5d6d383f01	2026-07-20 11:46:45.199839+00	2026-07-20 11:46:45.199839+00
6fa5de46-9edd-404a-915e-89d9f3f21ae7	19134162-fb23-47ee-a9ba-964b24c817fe	56ee4c58-1504-48a5-b37d-7d040bb2bd16	تست و اطمینان از عملکرد صحیح	231	60	2026-06-30	approved	6f0889c3-21cf-4af8-92e8-834e06a4a09c	\N	9ce51a5f-a964-432a-9eb7-b38fa2b621bd	2026-07-20 11:46:45.199839+00	2026-07-20 11:46:45.199839+00
6fa5de46-9edd-404a-915e-89d9f3f21ae7	19134162-fb23-47ee-a9ba-964b24c817fe	56ee4c58-1504-48a5-b37d-7d040bb2bd16	تست و اطمینان از عملکرد صحیح	34	69	2026-06-30	approved	6f0889c3-21cf-4af8-92e8-834e06a4a09c	\N	82bebdf0-f69a-4d1b-ac6f-6732921a60f5	2026-07-20 11:46:45.199839+00	2026-07-20 11:46:45.199839+00
6fa5de46-9edd-404a-915e-89d9f3f21ae7	19134162-fb23-47ee-a9ba-964b24c817fe	56ee4c58-1504-48a5-b37d-7d040bb2bd16	پیشرفت اولیه و بررسی نیازمندی‌ها	139	100	2026-07-04	approved	6f0889c3-21cf-4af8-92e8-834e06a4a09c	\N	cafe2775-9896-43b8-8ee2-6319d2f3e8f2	2026-07-20 11:46:45.199839+00	2026-07-20 11:46:45.199839+00
6fa5de46-9edd-404a-915e-89d9f3f21ae7	d512005b-0be7-4e8c-b040-f606d685920f	56ee4c58-1504-48a5-b37d-7d040bb2bd16	پیاده‌سازی بخش اصلی	100	22	2026-06-24	approved	6f0889c3-21cf-4af8-92e8-834e06a4a09c	\N	92043470-c4ec-40e7-97f2-68caa1622c13	2026-07-20 11:46:45.199839+00	2026-07-20 11:46:45.199839+00
6fa5de46-9edd-404a-915e-89d9f3f21ae7	d512005b-0be7-4e8c-b040-f606d685920f	56ee4c58-1504-48a5-b37d-7d040bb2bd16	رفع اشکالات و بازبینی	51	62	2026-06-27	approved	6f0889c3-21cf-4af8-92e8-834e06a4a09c	\N	a60219cf-e542-4c0c-af36-9a51df62c82f	2026-07-20 11:46:45.199839+00	2026-07-20 11:46:45.199839+00
6fa5de46-9edd-404a-915e-89d9f3f21ae7	b0031809-6de6-4d6d-96a9-10cc01e2e3ca	56ee4c58-1504-48a5-b37d-7d040bb2bd16	رفع اشکالات و بازبینی	215	27	2026-07-14	approved	6f0889c3-21cf-4af8-92e8-834e06a4a09c	\N	3ff07f8a-2e3a-4402-8d0a-33c421b8da83	2026-07-20 11:46:45.199839+00	2026-07-20 11:46:45.199839+00
6fa5de46-9edd-404a-915e-89d9f3f21ae7	b0031809-6de6-4d6d-96a9-10cc01e2e3ca	56ee4c58-1504-48a5-b37d-7d040bb2bd16	پیشرفت اولیه و بررسی نیازمندی‌ها	30	52	2026-07-16	approved	6f0889c3-21cf-4af8-92e8-834e06a4a09c	\N	14d4070f-5251-427e-bfb4-2f7ce29c69d8	2026-07-20 11:46:45.199839+00	2026-07-20 11:46:45.199839+00
6fa5de46-9edd-404a-915e-89d9f3f21ae7	fe21d906-16e8-403f-86ec-954b051c5413	6f0889c3-21cf-4af8-92e8-834e06a4a09c	پیاده‌سازی بخش اصلی	162	34	2026-07-16	approved	6f0889c3-21cf-4af8-92e8-834e06a4a09c	\N	f35337dc-380c-4d1e-ab72-0e86cc0196ad	2026-07-20 11:46:45.199839+00	2026-07-20 11:46:45.199839+00
6fa5de46-9edd-404a-915e-89d9f3f21ae7	fe21d906-16e8-403f-86ec-954b051c5413	6f0889c3-21cf-4af8-92e8-834e06a4a09c	رفع اشکالات و بازبینی	239	46	2026-07-16	approved	6f0889c3-21cf-4af8-92e8-834e06a4a09c	\N	58b55723-6186-4d26-98b9-14bacd9060f5	2026-07-20 11:46:45.199839+00	2026-07-20 11:46:45.199839+00
6fa5de46-9edd-404a-915e-89d9f3f21ae7	fe21d906-16e8-403f-86ec-954b051c5413	6f0889c3-21cf-4af8-92e8-834e06a4a09c	تست و اطمینان از عملکرد صحیح	48	81	2026-07-16	approved	6f0889c3-21cf-4af8-92e8-834e06a4a09c	\N	400f2c39-d26c-4155-be33-90a22ff71330	2026-07-20 11:46:45.199839+00	2026-07-20 11:46:45.199839+00
6fa5de46-9edd-404a-915e-89d9f3f21ae7	fe21d906-16e8-403f-86ec-954b051c5413	6f0889c3-21cf-4af8-92e8-834e06a4a09c	پیشرفت اولیه و بررسی نیازمندی‌ها	56	100	2026-07-16	approved	6f0889c3-21cf-4af8-92e8-834e06a4a09c	\N	b3b53728-528d-4492-a3ad-e3a739c04682	2026-07-20 11:46:45.199839+00	2026-07-20 11:46:45.199839+00
6fa5de46-9edd-404a-915e-89d9f3f21ae7	082ff14b-6963-44fd-915b-4d7ac30f69e8	56ee4c58-1504-48a5-b37d-7d040bb2bd16	پیاده‌سازی بخش اصلی	194	24	2026-06-26	approved	6f0889c3-21cf-4af8-92e8-834e06a4a09c	\N	2c5be120-f1fe-44ea-a21a-1beea73feb44	2026-07-20 11:46:45.199839+00	2026-07-20 11:46:45.199839+00
6fa5de46-9edd-404a-915e-89d9f3f21ae7	082ff14b-6963-44fd-915b-4d7ac30f69e8	56ee4c58-1504-48a5-b37d-7d040bb2bd16	پیشرفت اولیه و بررسی نیازمندی‌ها	186	80	2026-06-27	approved	6f0889c3-21cf-4af8-92e8-834e06a4a09c	\N	2b83ea0f-0938-437b-b20e-090ea068680f	2026-07-20 11:46:45.199839+00	2026-07-20 11:46:45.199839+00
6fa5de46-9edd-404a-915e-89d9f3f21ae7	082ff14b-6963-44fd-915b-4d7ac30f69e8	56ee4c58-1504-48a5-b37d-7d040bb2bd16	پیاده‌سازی بخش اصلی	190	72	2026-06-30	approved	6f0889c3-21cf-4af8-92e8-834e06a4a09c	\N	de2095ac-9bdf-43b0-9610-5460aee9d3c4	2026-07-20 11:46:45.199839+00	2026-07-20 11:46:45.199839+00
6fa5de46-9edd-404a-915e-89d9f3f21ae7	74989650-dd14-4c7f-aea8-93ff49e6d21b	ca92a9d5-cf4a-4b8b-9fe5-6fadd5c44ca2	پیشرفت اولیه و بررسی نیازمندی‌ها	55	24	2026-07-09	submitted	\N	\N	adf4527e-aed1-4c2c-acb3-ec38c66b204a	2026-07-20 11:46:45.199839+00	2026-07-20 11:46:45.199839+00
6fa5de46-9edd-404a-915e-89d9f3f21ae7	74989650-dd14-4c7f-aea8-93ff49e6d21b	ca92a9d5-cf4a-4b8b-9fe5-6fadd5c44ca2	تست و اطمینان از عملکرد صحیح	119	66	2026-07-10	approved	6f0889c3-21cf-4af8-92e8-834e06a4a09c	\N	020756fb-6d56-471c-b233-71cdade77f5e	2026-07-20 11:46:45.199839+00	2026-07-20 11:46:45.199839+00
6fa5de46-9edd-404a-915e-89d9f3f21ae7	74989650-dd14-4c7f-aea8-93ff49e6d21b	ca92a9d5-cf4a-4b8b-9fe5-6fadd5c44ca2	پیاده‌سازی بخش اصلی	100	100	2026-07-15	submitted	\N	\N	c83f81b6-20a5-466c-9f1c-45202c6f1335	2026-07-20 11:46:45.199839+00	2026-07-20 11:46:45.199839+00
6fa5de46-9edd-404a-915e-89d9f3f21ae7	74989650-dd14-4c7f-aea8-93ff49e6d21b	ca92a9d5-cf4a-4b8b-9fe5-6fadd5c44ca2	مستندسازی و نهایی‌سازی	183	100	2026-07-12	approved	6f0889c3-21cf-4af8-92e8-834e06a4a09c	\N	d13b391a-b0f6-4ce3-a8cf-a2dbb83000fa	2026-07-20 11:46:45.199839+00	2026-07-20 11:46:45.199839+00
6fa5de46-9edd-404a-915e-89d9f3f21ae7	e81b8411-c523-45c8-bb18-bf3775df9c60	56ee4c58-1504-48a5-b37d-7d040bb2bd16	رفع اشکالات و بازبینی	82	36	2026-07-16	approved	6f0889c3-21cf-4af8-92e8-834e06a4a09c	\N	5d242fcd-2f89-445c-bd89-af7a005c13e8	2026-07-20 11:46:45.199839+00	2026-07-20 11:46:45.199839+00
6fa5de46-9edd-404a-915e-89d9f3f21ae7	e81b8411-c523-45c8-bb18-bf3775df9c60	56ee4c58-1504-48a5-b37d-7d040bb2bd16	تست و اطمینان از عملکرد صحیح	105	80	2026-07-16	approved	6f0889c3-21cf-4af8-92e8-834e06a4a09c	\N	0f5ba0ac-14f3-496c-b7ad-284a96bc4860	2026-07-20 11:46:45.199839+00	2026-07-20 11:46:45.199839+00
6fa5de46-9edd-404a-915e-89d9f3f21ae7	e81b8411-c523-45c8-bb18-bf3775df9c60	56ee4c58-1504-48a5-b37d-7d040bb2bd16	پیاده‌سازی بخش اصلی	156	96	2026-07-16	approved	6f0889c3-21cf-4af8-92e8-834e06a4a09c	\N	9ffedf84-5c32-447e-85ce-adc09e07baf2	2026-07-20 11:46:45.199839+00	2026-07-20 11:46:45.199839+00
6fa5de46-9edd-404a-915e-89d9f3f21ae7	79aac3f0-933e-41f8-baa4-d119c0a882c1	c28803c6-5155-4136-94b4-4f91ec6ee698	تست و اطمینان از عملکرد صحیح	193	39	2026-07-16	approved	6f0889c3-21cf-4af8-92e8-834e06a4a09c	\N	033724ac-930a-4ddf-96b6-010e1de02351	2026-07-20 11:46:45.199839+00	2026-07-20 11:46:45.199839+00
6fa5de46-9edd-404a-915e-89d9f3f21ae7	4f9ee262-448c-42cc-83a2-22e395a28688	56ee4c58-1504-48a5-b37d-7d040bb2bd16	رفع اشکالات و بازبینی	111	24	2026-07-16	approved	6f0889c3-21cf-4af8-92e8-834e06a4a09c	\N	e73fa790-d959-4639-8d02-90a3cc11972d	2026-07-20 11:46:45.199839+00	2026-07-20 11:46:45.199839+00
6fa5de46-9edd-404a-915e-89d9f3f21ae7	327beb9a-ae6f-44dd-8ec3-c6c43140855b	56ee4c58-1504-48a5-b37d-7d040bb2bd16	پیاده‌سازی بخش اصلی	225	35	2026-07-16	approved	6f0889c3-21cf-4af8-92e8-834e06a4a09c	\N	1e703c5e-57fd-4710-bfce-eb614c695295	2026-07-20 11:46:45.199839+00	2026-07-20 11:46:45.199839+00
6fa5de46-9edd-404a-915e-89d9f3f21ae7	327beb9a-ae6f-44dd-8ec3-c6c43140855b	56ee4c58-1504-48a5-b37d-7d040bb2bd16	پیشرفت اولیه و بررسی نیازمندی‌ها	33	56	2026-07-16	approved	6f0889c3-21cf-4af8-92e8-834e06a4a09c	\N	6b40a5b0-fa07-4d97-b1a9-733b503869ed	2026-07-20 11:46:45.199839+00	2026-07-20 11:46:45.199839+00
6fa5de46-9edd-404a-915e-89d9f3f21ae7	327beb9a-ae6f-44dd-8ec3-c6c43140855b	56ee4c58-1504-48a5-b37d-7d040bb2bd16	پیشرفت اولیه و بررسی نیازمندی‌ها	232	96	2026-07-16	approved	6f0889c3-21cf-4af8-92e8-834e06a4a09c	\N	291742cb-5888-4054-8660-9ecba574b796	2026-07-20 11:46:45.199839+00	2026-07-20 11:46:45.199839+00
6fa5de46-9edd-404a-915e-89d9f3f21ae7	327beb9a-ae6f-44dd-8ec3-c6c43140855b	56ee4c58-1504-48a5-b37d-7d040bb2bd16	مستندسازی و نهایی‌سازی	226	100	2026-07-16	approved	6f0889c3-21cf-4af8-92e8-834e06a4a09c	\N	77c13e0c-f9c9-4da5-ab37-3d15c685f32a	2026-07-20 11:46:45.199839+00	2026-07-20 11:46:45.199839+00
6fa5de46-9edd-404a-915e-89d9f3f21ae7	9ca4b959-c0d9-4a8f-a05f-12c208e7926f	56ee4c58-1504-48a5-b37d-7d040bb2bd16	مستندسازی و نهایی‌سازی	167	39	2026-07-16	approved	6f0889c3-21cf-4af8-92e8-834e06a4a09c	\N	4fb506ad-2d7d-4744-b360-8fa2cdc76ab9	2026-07-20 11:46:45.199839+00	2026-07-20 11:46:45.199839+00
6fa5de46-9edd-404a-915e-89d9f3f21ae7	9ca4b959-c0d9-4a8f-a05f-12c208e7926f	56ee4c58-1504-48a5-b37d-7d040bb2bd16	رفع اشکالات و بازبینی	50	72	2026-07-16	approved	6f0889c3-21cf-4af8-92e8-834e06a4a09c	\N	00f9b4f6-39e1-4f24-8022-420c2949a925	2026-07-20 11:46:45.199839+00	2026-07-20 11:46:45.199839+00
6fa5de46-9edd-404a-915e-89d9f3f21ae7	9ca4b959-c0d9-4a8f-a05f-12c208e7926f	56ee4c58-1504-48a5-b37d-7d040bb2bd16	پیاده‌سازی بخش اصلی	167	90	2026-07-16	submitted	\N	\N	3ce471b6-33d7-44fe-9ab7-5c4c4938fc78	2026-07-20 11:46:45.199839+00	2026-07-20 11:46:45.199839+00
6fa5de46-9edd-404a-915e-89d9f3f21ae7	9ca4b959-c0d9-4a8f-a05f-12c208e7926f	56ee4c58-1504-48a5-b37d-7d040bb2bd16	پیشرفت اولیه و بررسی نیازمندی‌ها	109	100	2026-07-16	approved	6f0889c3-21cf-4af8-92e8-834e06a4a09c	\N	43abfa24-b80a-441d-84f2-d7f75760292e	2026-07-20 11:46:45.199839+00	2026-07-20 11:46:45.199839+00
6fa5de46-9edd-404a-915e-89d9f3f21ae7	5ca56f0c-2984-432f-b21a-1fda1fea2aab	56ee4c58-1504-48a5-b37d-7d040bb2bd16	پیاده‌سازی بخش اصلی	52	33	2026-07-16	approved	6f0889c3-21cf-4af8-92e8-834e06a4a09c	\N	7d351b35-48d2-4598-a8a1-3fa69beae049	2026-07-20 11:46:45.199839+00	2026-07-20 11:46:45.199839+00
6fa5de46-9edd-404a-915e-89d9f3f21ae7	5ca56f0c-2984-432f-b21a-1fda1fea2aab	56ee4c58-1504-48a5-b37d-7d040bb2bd16	تست و اطمینان از عملکرد صحیح	186	78	2026-07-16	approved	6f0889c3-21cf-4af8-92e8-834e06a4a09c	\N	5ba1ba8b-49eb-4193-b26e-13c8f6b389f9	2026-07-20 11:46:45.199839+00	2026-07-20 11:46:45.199839+00
6fa5de46-9edd-404a-915e-89d9f3f21ae7	d7c721de-cff8-4458-a2eb-de892c3416a6	ca92a9d5-cf4a-4b8b-9fe5-6fadd5c44ca2	پیاده‌سازی بخش اصلی	60	20	2026-07-16	approved	6f0889c3-21cf-4af8-92e8-834e06a4a09c	\N	a1b16217-28e0-46a1-aafd-e3a64f3e9ce3	2026-07-20 11:46:45.199839+00	2026-07-20 11:46:45.199839+00
6fa5de46-9edd-404a-915e-89d9f3f21ae7	ce25cf6d-c24b-47b0-be35-fce61486c9ab	56ee4c58-1504-48a5-b37d-7d040bb2bd16	پیاده‌سازی بخش اصلی	157	31	2026-06-30	approved	6f0889c3-21cf-4af8-92e8-834e06a4a09c	\N	22de5e41-12db-4160-bc52-07e4ff640288	2026-07-20 11:46:45.199839+00	2026-07-20 11:46:45.199839+00
6fa5de46-9edd-404a-915e-89d9f3f21ae7	ce25cf6d-c24b-47b0-be35-fce61486c9ab	56ee4c58-1504-48a5-b37d-7d040bb2bd16	پیاده‌سازی بخش اصلی	125	48	2026-07-03	approved	6f0889c3-21cf-4af8-92e8-834e06a4a09c	\N	1aa25b8f-d685-4cbb-8ab8-55da163e4487	2026-07-20 11:46:45.199839+00	2026-07-20 11:46:45.199839+00
6fa5de46-9edd-404a-915e-89d9f3f21ae7	0d5c789c-b1c5-4530-bfd9-83a7d14942d0	56ee4c58-1504-48a5-b37d-7d040bb2bd16	پیشرفت اولیه و بررسی نیازمندی‌ها	115	33	2026-07-13	approved	6f0889c3-21cf-4af8-92e8-834e06a4a09c	\N	9b50d54a-0a39-4331-a338-4a71c3340adc	2026-07-20 11:46:45.199839+00	2026-07-20 11:46:45.199839+00
6fa5de46-9edd-404a-915e-89d9f3f21ae7	0d5c789c-b1c5-4530-bfd9-83a7d14942d0	56ee4c58-1504-48a5-b37d-7d040bb2bd16	مستندسازی و نهایی‌سازی	46	56	2026-07-16	approved	6f0889c3-21cf-4af8-92e8-834e06a4a09c	\N	d8fca9af-3ff9-41b9-96c3-56bb768b436f	2026-07-20 11:46:45.199839+00	2026-07-20 11:46:45.199839+00
6fa5de46-9edd-404a-915e-89d9f3f21ae7	0d5c789c-b1c5-4530-bfd9-83a7d14942d0	56ee4c58-1504-48a5-b37d-7d040bb2bd16	تست و اطمینان از عملکرد صحیح	146	100	2026-07-15	approved	6f0889c3-21cf-4af8-92e8-834e06a4a09c	\N	538d6fb7-a36e-4186-9fab-a470c39cf5c3	2026-07-20 11:46:45.199839+00	2026-07-20 11:46:45.199839+00
6fa5de46-9edd-404a-915e-89d9f3f21ae7	2a9ba646-b8a0-4f0a-bcf2-37fe41069b1d	ca92a9d5-cf4a-4b8b-9fe5-6fadd5c44ca2	مستندسازی و نهایی‌سازی	72	31	2026-07-16	approved	6f0889c3-21cf-4af8-92e8-834e06a4a09c	\N	05f10bb1-151e-40b0-80c9-1f642b77b831	2026-07-20 11:46:45.199839+00	2026-07-20 11:46:45.199839+00
6fa5de46-9edd-404a-915e-89d9f3f21ae7	2a9ba646-b8a0-4f0a-bcf2-37fe41069b1d	ca92a9d5-cf4a-4b8b-9fe5-6fadd5c44ca2	پیشرفت اولیه و بررسی نیازمندی‌ها	176	46	2026-07-16	approved	6f0889c3-21cf-4af8-92e8-834e06a4a09c	\N	551f5633-78b8-4397-98a4-3f602ef87124	2026-07-20 11:46:45.199839+00	2026-07-20 11:46:45.199839+00
6fa5de46-9edd-404a-915e-89d9f3f21ae7	2a9ba646-b8a0-4f0a-bcf2-37fe41069b1d	ca92a9d5-cf4a-4b8b-9fe5-6fadd5c44ca2	پیشرفت اولیه و بررسی نیازمندی‌ها	41	60	2026-07-16	submitted	\N	\N	72860663-6503-4979-972e-a01d9b88b47e	2026-07-20 11:46:45.199839+00	2026-07-20 11:46:45.199839+00
6fa5de46-9edd-404a-915e-89d9f3f21ae7	8879a246-afae-49f5-91fe-25394acba4a7	6f0889c3-21cf-4af8-92e8-834e06a4a09c	تست و اطمینان از عملکرد صحیح	123	32	2026-07-16	approved	6f0889c3-21cf-4af8-92e8-834e06a4a09c	\N	cf5de262-33b7-46cf-917a-402e4d58e696	2026-07-20 11:46:45.199839+00	2026-07-20 11:46:45.199839+00
6fa5de46-9edd-404a-915e-89d9f3f21ae7	8879a246-afae-49f5-91fe-25394acba4a7	6f0889c3-21cf-4af8-92e8-834e06a4a09c	پیاده‌سازی بخش اصلی	39	74	2026-07-16	approved	6f0889c3-21cf-4af8-92e8-834e06a4a09c	\N	f0a3126c-6a6a-44ed-914f-414dada7e4fa	2026-07-20 11:46:45.199839+00	2026-07-20 11:46:45.199839+00
6fa5de46-9edd-404a-915e-89d9f3f21ae7	27287657-4306-41f6-aa12-d6d8f33e066f	56ee4c58-1504-48a5-b37d-7d040bb2bd16	تست و اطمینان از عملکرد صحیح	214	30	2026-07-16	approved	6f0889c3-21cf-4af8-92e8-834e06a4a09c	\N	8276bcb8-09e2-463e-9dfa-26615d685fcd	2026-07-20 11:46:45.199839+00	2026-07-20 11:46:45.199839+00
6fa5de46-9edd-404a-915e-89d9f3f21ae7	27287657-4306-41f6-aa12-d6d8f33e066f	56ee4c58-1504-48a5-b37d-7d040bb2bd16	مستندسازی و نهایی‌سازی	125	46	2026-07-16	submitted	\N	\N	cf7448e9-1682-449f-8dbd-ee994015a94d	2026-07-20 11:46:45.199839+00	2026-07-20 11:46:45.199839+00
6fa5de46-9edd-404a-915e-89d9f3f21ae7	27287657-4306-41f6-aa12-d6d8f33e066f	56ee4c58-1504-48a5-b37d-7d040bb2bd16	مستندسازی و نهایی‌سازی	41	96	2026-07-16	approved	6f0889c3-21cf-4af8-92e8-834e06a4a09c	\N	f064707f-00a9-4e26-95c8-da00eb141e02	2026-07-20 11:46:45.199839+00	2026-07-20 11:46:45.199839+00
6fa5de46-9edd-404a-915e-89d9f3f21ae7	27287657-4306-41f6-aa12-d6d8f33e066f	56ee4c58-1504-48a5-b37d-7d040bb2bd16	رفع اشکالات و بازبینی	228	100	2026-07-16	submitted	\N	\N	5c0fc8aa-776d-47ca-b769-18d991f9edac	2026-07-20 11:46:45.199839+00	2026-07-20 11:46:45.199839+00
6fa5de46-9edd-404a-915e-89d9f3f21ae7	fd3cfc03-c713-4b69-babe-279b7416cb3a	eeebc2e6-a734-4f02-8d65-173ba01323d3	پیشرفت اولیه و بررسی نیازمندی‌ها	124	26	2026-07-16	approved	6f0889c3-21cf-4af8-92e8-834e06a4a09c	\N	7178a96d-8322-40a9-8a2f-8f33ff630409	2026-07-20 11:46:45.199839+00	2026-07-20 11:46:45.199839+00
6fa5de46-9edd-404a-915e-89d9f3f21ae7	fd3cfc03-c713-4b69-babe-279b7416cb3a	eeebc2e6-a734-4f02-8d65-173ba01323d3	رفع اشکالات و بازبینی	219	78	2026-07-16	approved	6f0889c3-21cf-4af8-92e8-834e06a4a09c	\N	3958ae5a-65f1-4502-976f-ccbe6463958e	2026-07-20 11:46:45.199839+00	2026-07-20 11:46:45.199839+00
6fa5de46-9edd-404a-915e-89d9f3f21ae7	fd3cfc03-c713-4b69-babe-279b7416cb3a	eeebc2e6-a734-4f02-8d65-173ba01323d3	مستندسازی و نهایی‌سازی	156	78	2026-07-16	approved	6f0889c3-21cf-4af8-92e8-834e06a4a09c	\N	b87e0726-6a39-40cc-aceb-7e1c0d21d8fa	2026-07-20 11:46:45.199839+00	2026-07-20 11:46:45.199839+00
6fa5de46-9edd-404a-915e-89d9f3f21ae7	8822e29f-2630-4518-b175-3855723c1301	c28803c6-5155-4136-94b4-4f91ec6ee698	تست و اطمینان از عملکرد صحیح	36	27	2026-07-01	approved	6f0889c3-21cf-4af8-92e8-834e06a4a09c	\N	e06290d8-8a81-44e4-aba0-783b081391db	2026-07-20 11:46:45.199839+00	2026-07-20 11:46:45.199839+00
6fa5de46-9edd-404a-915e-89d9f3f21ae7	8822e29f-2630-4518-b175-3855723c1301	c28803c6-5155-4136-94b4-4f91ec6ee698	پیشرفت اولیه و بررسی نیازمندی‌ها	115	40	2026-07-04	approved	6f0889c3-21cf-4af8-92e8-834e06a4a09c	\N	c9081700-87b9-4c3a-90e9-3e19bc066248	2026-07-20 11:46:45.199839+00	2026-07-20 11:46:45.199839+00
6fa5de46-9edd-404a-915e-89d9f3f21ae7	015ee77c-6eb5-472c-8cce-82d5a0f42bd8	eeebc2e6-a734-4f02-8d65-173ba01323d3	مستندسازی و نهایی‌سازی	90	33	2026-06-19	approved	6f0889c3-21cf-4af8-92e8-834e06a4a09c	\N	a024ee32-d06f-4974-a397-568a8287ee7e	2026-07-20 11:46:45.199839+00	2026-07-20 11:46:45.199839+00
6fa5de46-9edd-404a-915e-89d9f3f21ae7	015ee77c-6eb5-472c-8cce-82d5a0f42bd8	eeebc2e6-a734-4f02-8d65-173ba01323d3	پیاده‌سازی بخش اصلی	212	56	2026-06-23	submitted	\N	\N	6642ef0c-3ce1-4601-af1d-88eb428ad521	2026-07-20 11:46:45.199839+00	2026-07-20 11:46:45.199839+00
6fa5de46-9edd-404a-915e-89d9f3f21ae7	015ee77c-6eb5-472c-8cce-82d5a0f42bd8	eeebc2e6-a734-4f02-8d65-173ba01323d3	پیاده‌سازی بخش اصلی	163	99	2026-06-21	approved	6f0889c3-21cf-4af8-92e8-834e06a4a09c	\N	289557fc-c0e0-4361-a384-abcce6237448	2026-07-20 11:46:45.199839+00	2026-07-20 11:46:45.199839+00
6fa5de46-9edd-404a-915e-89d9f3f21ae7	015ee77c-6eb5-472c-8cce-82d5a0f42bd8	eeebc2e6-a734-4f02-8d65-173ba01323d3	پیشرفت اولیه و بررسی نیازمندی‌ها	178	92	2026-06-28	approved	6f0889c3-21cf-4af8-92e8-834e06a4a09c	\N	d21ea35b-78c7-4cec-878d-6ea088e0b1d8	2026-07-20 11:46:45.199839+00	2026-07-20 11:46:45.199839+00
6fa5de46-9edd-404a-915e-89d9f3f21ae7	32212044-37e6-474f-b1ca-189742900047	56ee4c58-1504-48a5-b37d-7d040bb2bd16	پیشرفت اولیه و بررسی نیازمندی‌ها	181	38	2026-07-08	approved	6f0889c3-21cf-4af8-92e8-834e06a4a09c	\N	464bae72-d0c4-4973-b84c-8a7e45bcf2a5	2026-07-20 11:46:45.199839+00	2026-07-20 11:46:45.199839+00
6fa5de46-9edd-404a-915e-89d9f3f21ae7	32212044-37e6-474f-b1ca-189742900047	56ee4c58-1504-48a5-b37d-7d040bb2bd16	تست و اطمینان از عملکرد صحیح	199	48	2026-07-09	approved	6f0889c3-21cf-4af8-92e8-834e06a4a09c	\N	259d7d32-2cb2-41e6-9336-be687cfb9e9c	2026-07-20 11:46:45.199839+00	2026-07-20 11:46:45.199839+00
6fa5de46-9edd-404a-915e-89d9f3f21ae7	2a5f6e77-df84-49f6-93de-c5d5b94619ba	56ee4c58-1504-48a5-b37d-7d040bb2bd16	رفع اشکالات و بازبینی	235	32	2026-06-25	approved	6f0889c3-21cf-4af8-92e8-834e06a4a09c	\N	94a496c5-58ae-4600-8ee1-8346de8204bd	2026-07-20 11:46:45.199839+00	2026-07-20 11:46:45.199839+00
6fa5de46-9edd-404a-915e-89d9f3f21ae7	2a5f6e77-df84-49f6-93de-c5d5b94619ba	56ee4c58-1504-48a5-b37d-7d040bb2bd16	رفع اشکالات و بازبینی	89	44	2026-06-28	approved	6f0889c3-21cf-4af8-92e8-834e06a4a09c	\N	7d36fd1f-d65e-4338-9877-942729cd28f7	2026-07-20 11:46:45.199839+00	2026-07-20 11:46:45.199839+00
6fa5de46-9edd-404a-915e-89d9f3f21ae7	18643d2f-db24-482b-96e5-c4deab3ace1e	c28803c6-5155-4136-94b4-4f91ec6ee698	مستندسازی و نهایی‌سازی	57	24	2026-07-05	submitted	\N	\N	1156f651-d3fd-4474-ab47-aa597ce0f357	2026-07-20 11:46:45.199839+00	2026-07-20 11:46:45.199839+00
6fa5de46-9edd-404a-915e-89d9f3f21ae7	18643d2f-db24-482b-96e5-c4deab3ace1e	c28803c6-5155-4136-94b4-4f91ec6ee698	تست و اطمینان از عملکرد صحیح	110	66	2026-07-06	approved	6f0889c3-21cf-4af8-92e8-834e06a4a09c	\N	c1a7c771-1041-42c5-909b-526bf9c9fad6	2026-07-20 11:46:45.199839+00	2026-07-20 11:46:45.199839+00
6fa5de46-9edd-404a-915e-89d9f3f21ae7	4394dfd4-c658-45b7-8e34-5a3848502ba2	56ee4c58-1504-48a5-b37d-7d040bb2bd16	پیاده‌سازی بخش اصلی	145	29	2026-07-10	approved	6f0889c3-21cf-4af8-92e8-834e06a4a09c	\N	f4bbfd63-9b5a-4310-b053-9e8cbd336449	2026-07-20 11:46:45.199839+00	2026-07-20 11:46:45.199839+00
6fa5de46-9edd-404a-915e-89d9f3f21ae7	51336c23-f3c4-4d9a-9744-ade80bdf1d92	6f0889c3-21cf-4af8-92e8-834e06a4a09c	پیشرفت اولیه و بررسی نیازمندی‌ها	53	25	2026-06-21	approved	6f0889c3-21cf-4af8-92e8-834e06a4a09c	\N	091b9bb2-a64f-4448-a8c7-9ca7cad619c9	2026-07-20 11:46:45.199839+00	2026-07-20 11:46:45.199839+00
6fa5de46-9edd-404a-915e-89d9f3f21ae7	51336c23-f3c4-4d9a-9744-ade80bdf1d92	6f0889c3-21cf-4af8-92e8-834e06a4a09c	مستندسازی و نهایی‌سازی	40	52	2026-06-24	approved	6f0889c3-21cf-4af8-92e8-834e06a4a09c	\N	f2553069-1993-43e3-8636-4f93ce4826f6	2026-07-20 11:46:45.199839+00	2026-07-20 11:46:45.199839+00
6fa5de46-9edd-404a-915e-89d9f3f21ae7	51336c23-f3c4-4d9a-9744-ade80bdf1d92	6f0889c3-21cf-4af8-92e8-834e06a4a09c	پیاده‌سازی بخش اصلی	53	81	2026-06-27	approved	6f0889c3-21cf-4af8-92e8-834e06a4a09c	\N	80eaeb28-e761-461f-8cb0-8ed664d8b52c	2026-07-20 11:46:45.199839+00	2026-07-20 11:46:45.199839+00
6fa5de46-9edd-404a-915e-89d9f3f21ae7	51336c23-f3c4-4d9a-9744-ade80bdf1d92	6f0889c3-21cf-4af8-92e8-834e06a4a09c	تست و اطمینان از عملکرد صحیح	161	84	2026-06-30	approved	6f0889c3-21cf-4af8-92e8-834e06a4a09c	\N	520449b9-d004-4a07-9ffc-02178129a8f8	2026-07-20 11:46:45.199839+00	2026-07-20 11:46:45.199839+00
6fa5de46-9edd-404a-915e-89d9f3f21ae7	65770e94-70d6-4de1-a0cf-73c7a41e9dd8	56ee4c58-1504-48a5-b37d-7d040bb2bd16	پیاده‌سازی بخش اصلی	37	32	2026-06-18	approved	6f0889c3-21cf-4af8-92e8-834e06a4a09c	\N	9e499969-fdec-4132-8b9d-941bf77a93b1	2026-07-20 11:46:45.199839+00	2026-07-20 11:46:45.199839+00
6fa5de46-9edd-404a-915e-89d9f3f21ae7	65770e94-70d6-4de1-a0cf-73c7a41e9dd8	56ee4c58-1504-48a5-b37d-7d040bb2bd16	مستندسازی و نهایی‌سازی	221	74	2026-06-22	approved	6f0889c3-21cf-4af8-92e8-834e06a4a09c	\N	1fa995a3-45e5-44a2-9606-086f0e3aa32d	2026-07-20 11:46:45.199839+00	2026-07-20 11:46:45.199839+00
6fa5de46-9edd-404a-915e-89d9f3f21ae7	65770e94-70d6-4de1-a0cf-73c7a41e9dd8	56ee4c58-1504-48a5-b37d-7d040bb2bd16	پیشرفت اولیه و بررسی نیازمندی‌ها	148	69	2026-06-22	approved	6f0889c3-21cf-4af8-92e8-834e06a4a09c	\N	8635c763-f939-4ee4-9404-8ff3cee87844	2026-07-20 11:46:45.199839+00	2026-07-20 11:46:45.199839+00
6fa5de46-9edd-404a-915e-89d9f3f21ae7	e6438295-3639-4035-bf6b-843ad3605bd7	3cba84f1-51a4-4831-ac2b-61b820a1122a	پیاده‌سازی بخش اصلی	63	26	2026-07-16	approved	6f0889c3-21cf-4af8-92e8-834e06a4a09c	\N	112b6817-b8db-4769-b23d-e0264f474c2f	2026-07-20 11:46:45.199839+00	2026-07-20 11:46:45.199839+00
6fa5de46-9edd-404a-915e-89d9f3f21ae7	e6438295-3639-4035-bf6b-843ad3605bd7	3cba84f1-51a4-4831-ac2b-61b820a1122a	پیشرفت اولیه و بررسی نیازمندی‌ها	179	76	2026-07-16	approved	6f0889c3-21cf-4af8-92e8-834e06a4a09c	\N	f587d58f-e92c-4f04-9509-c886c980495c	2026-07-20 11:46:45.199839+00	2026-07-20 11:46:45.199839+00
6fa5de46-9edd-404a-915e-89d9f3f21ae7	b384ef43-2f17-4bd3-bbd0-a024f179a6d3	6f0889c3-21cf-4af8-92e8-834e06a4a09c	پیشرفت اولیه و بررسی نیازمندی‌ها	80	40	2026-07-16	approved	6f0889c3-21cf-4af8-92e8-834e06a4a09c	\N	1ff30365-738b-4bdb-9c3f-40d961c446f5	2026-07-20 11:46:45.199839+00	2026-07-20 11:46:45.199839+00
6fa5de46-9edd-404a-915e-89d9f3f21ae7	b384ef43-2f17-4bd3-bbd0-a024f179a6d3	6f0889c3-21cf-4af8-92e8-834e06a4a09c	پیشرفت اولیه و بررسی نیازمندی‌ها	237	60	2026-07-16	submitted	\N	\N	176eae5d-9e08-49fc-8be5-5d368a3cba86	2026-07-20 11:46:45.199839+00	2026-07-20 11:46:45.199839+00
6fa5de46-9edd-404a-915e-89d9f3f21ae7	b384ef43-2f17-4bd3-bbd0-a024f179a6d3	6f0889c3-21cf-4af8-92e8-834e06a4a09c	تست و اطمینان از عملکرد صحیح	42	75	2026-07-16	approved	6f0889c3-21cf-4af8-92e8-834e06a4a09c	\N	8629c878-6285-4f64-b648-fa7090558b23	2026-07-20 11:46:45.199839+00	2026-07-20 11:46:45.199839+00
6fa5de46-9edd-404a-915e-89d9f3f21ae7	2d867f62-6440-416b-8340-29f14285ffa4	ca92a9d5-cf4a-4b8b-9fe5-6fadd5c44ca2	تست و اطمینان از عملکرد صحیح	37	32	2026-07-11	approved	6f0889c3-21cf-4af8-92e8-834e06a4a09c	\N	77698bf8-4d7a-43b9-9ad4-508db2fdb114	2026-07-20 11:46:45.199839+00	2026-07-20 11:46:45.199839+00
6fa5de46-9edd-404a-915e-89d9f3f21ae7	2d867f62-6440-416b-8340-29f14285ffa4	ca92a9d5-cf4a-4b8b-9fe5-6fadd5c44ca2	پیاده‌سازی بخش اصلی	120	52	2026-07-15	approved	6f0889c3-21cf-4af8-92e8-834e06a4a09c	\N	168b2c1c-404d-4eee-982b-f2c4c4699a88	2026-07-20 11:46:45.199839+00	2026-07-20 11:46:45.199839+00
6fa5de46-9edd-404a-915e-89d9f3f21ae7	2d867f62-6440-416b-8340-29f14285ffa4	ca92a9d5-cf4a-4b8b-9fe5-6fadd5c44ca2	رفع اشکالات و بازبینی	101	100	2026-07-15	approved	6f0889c3-21cf-4af8-92e8-834e06a4a09c	\N	6080fa2a-1c84-498c-91a8-8032baf6693c	2026-07-20 11:46:45.199839+00	2026-07-20 11:46:45.199839+00
6fa5de46-9edd-404a-915e-89d9f3f21ae7	2d867f62-6440-416b-8340-29f14285ffa4	ca92a9d5-cf4a-4b8b-9fe5-6fadd5c44ca2	پیشرفت اولیه و بررسی نیازمندی‌ها	187	100	2026-07-16	approved	6f0889c3-21cf-4af8-92e8-834e06a4a09c	\N	e8d838b3-e847-4e08-9788-67d1e241a3f2	2026-07-20 11:46:45.199839+00	2026-07-20 11:46:45.199839+00
6fa5de46-9edd-404a-915e-89d9f3f21ae7	1313cf9c-b4fe-483b-aef2-21fd5124981d	c2241423-6f70-4f15-92a9-c4a433dfec70	رفع اشکالات و بازبینی	43	27	2026-07-16	submitted	\N	\N	9fe6e9d5-3dcc-4130-9ebe-7c25b7de0f26	2026-07-20 11:46:45.199839+00	2026-07-20 11:46:45.199839+00
6fa5de46-9edd-404a-915e-89d9f3f21ae7	1313cf9c-b4fe-483b-aef2-21fd5124981d	c2241423-6f70-4f15-92a9-c4a433dfec70	مستندسازی و نهایی‌سازی	183	70	2026-07-16	approved	c2241423-6f70-4f15-92a9-c4a433dfec70	\N	d5ce5e3c-a8e7-4277-ad9a-d0b2a863b3a3	2026-07-20 11:46:45.199839+00	2026-07-20 11:46:45.199839+00
6fa5de46-9edd-404a-915e-89d9f3f21ae7	2c7fc683-33d0-4e4b-8411-45477b760582	c700c6fb-ad08-4eaa-9597-f02c27aa0e58	پیشرفت اولیه و بررسی نیازمندی‌ها	54	27	2026-07-16	approved	c2241423-6f70-4f15-92a9-c4a433dfec70	\N	0ca0d3b1-be76-430d-8b39-34f6852905f5	2026-07-20 11:46:45.199839+00	2026-07-20 11:46:45.199839+00
6fa5de46-9edd-404a-915e-89d9f3f21ae7	2c7fc683-33d0-4e4b-8411-45477b760582	c700c6fb-ad08-4eaa-9597-f02c27aa0e58	رفع اشکالات و بازبینی	120	80	2026-07-16	approved	c2241423-6f70-4f15-92a9-c4a433dfec70	\N	dfa0cee7-fd9a-4fff-9f47-3fc25e318428	2026-07-20 11:46:45.199839+00	2026-07-20 11:46:45.199839+00
6fa5de46-9edd-404a-915e-89d9f3f21ae7	2c7fc683-33d0-4e4b-8411-45477b760582	c700c6fb-ad08-4eaa-9597-f02c27aa0e58	مستندسازی و نهایی‌سازی	163	93	2026-07-16	approved	c2241423-6f70-4f15-92a9-c4a433dfec70	\N	035cb411-b517-4a22-baae-12dd7af153ad	2026-07-20 11:46:45.199839+00	2026-07-20 11:46:45.199839+00
6fa5de46-9edd-404a-915e-89d9f3f21ae7	5a4ffe2f-3079-4e6f-bbce-f3a61e00c16c	16119c08-e43f-4846-adcd-f77ad1aca132	پیاده‌سازی بخش اصلی	156	24	2026-07-16	approved	c2241423-6f70-4f15-92a9-c4a433dfec70	\N	5aa985d8-5350-4abe-a8a6-3e7f6a5f403d	2026-07-20 11:46:45.199839+00	2026-07-20 11:46:45.199839+00
6fa5de46-9edd-404a-915e-89d9f3f21ae7	77f55057-0625-4841-a68c-e8aade86d09e	0bf949b7-932b-40ba-8d67-4ea888360556	رفع اشکالات و بازبینی	186	26	2026-07-07	approved	c2241423-6f70-4f15-92a9-c4a433dfec70	\N	39101302-6eeb-49e7-b94a-b54023e32f0d	2026-07-20 11:46:45.199839+00	2026-07-20 11:46:45.199839+00
6fa5de46-9edd-404a-915e-89d9f3f21ae7	77f55057-0625-4841-a68c-e8aade86d09e	0bf949b7-932b-40ba-8d67-4ea888360556	پیشرفت اولیه و بررسی نیازمندی‌ها	130	52	2026-07-09	approved	c2241423-6f70-4f15-92a9-c4a433dfec70	\N	ef0abc39-57b7-452f-afd8-e703f6653ec7	2026-07-20 11:46:45.199839+00	2026-07-20 11:46:45.199839+00
6fa5de46-9edd-404a-915e-89d9f3f21ae7	77f55057-0625-4841-a68c-e8aade86d09e	0bf949b7-932b-40ba-8d67-4ea888360556	پیاده‌سازی بخش اصلی	213	90	2026-07-15	approved	c2241423-6f70-4f15-92a9-c4a433dfec70	\N	7bf74bec-b99b-47c9-bdc7-168d8398d7bd	2026-07-20 11:46:45.199839+00	2026-07-20 11:46:45.199839+00
6fa5de46-9edd-404a-915e-89d9f3f21ae7	77f55057-0625-4841-a68c-e8aade86d09e	0bf949b7-932b-40ba-8d67-4ea888360556	تست و اطمینان از عملکرد صحیح	41	100	2026-07-10	approved	c2241423-6f70-4f15-92a9-c4a433dfec70	\N	bc577830-a3ce-41c2-acba-f046681019e0	2026-07-20 11:46:45.199839+00	2026-07-20 11:46:45.199839+00
6fa5de46-9edd-404a-915e-89d9f3f21ae7	b7a6249e-3e78-46e1-9c06-af77b772ed74	cf5d8b24-a057-421e-9cc3-b442f742293f	تست و اطمینان از عملکرد صحیح	198	38	2026-07-12	approved	c2241423-6f70-4f15-92a9-c4a433dfec70	\N	09248a54-5393-46f6-b394-4071a144c7f8	2026-07-20 11:46:45.199839+00	2026-07-20 11:46:45.199839+00
6fa5de46-9edd-404a-915e-89d9f3f21ae7	ff5bed90-6c18-4beb-a33a-85cc6b0786cd	16119c08-e43f-4846-adcd-f77ad1aca132	پیشرفت اولیه و بررسی نیازمندی‌ها	165	21	2026-07-16	approved	c2241423-6f70-4f15-92a9-c4a433dfec70	\N	378f0409-5b96-4502-bdba-564e54819729	2026-07-20 11:46:45.199839+00	2026-07-20 11:46:45.199839+00
6fa5de46-9edd-404a-915e-89d9f3f21ae7	ff5bed90-6c18-4beb-a33a-85cc6b0786cd	16119c08-e43f-4846-adcd-f77ad1aca132	مستندسازی و نهایی‌سازی	153	72	2026-07-16	approved	c2241423-6f70-4f15-92a9-c4a433dfec70	\N	e1d7eed7-f7fc-4b1d-845a-4f298458ded5	2026-07-20 11:46:45.199839+00	2026-07-20 11:46:45.199839+00
6fa5de46-9edd-404a-915e-89d9f3f21ae7	096beeef-a670-4862-8c23-34f45d9dd637	0bf949b7-932b-40ba-8d67-4ea888360556	پیاده‌سازی بخش اصلی	56	32	2026-06-26	submitted	\N	\N	fb03e81e-56d8-4181-b7fd-8a5501919eb5	2026-07-20 11:46:45.199839+00	2026-07-20 11:46:45.199839+00
6fa5de46-9edd-404a-915e-89d9f3f21ae7	096beeef-a670-4862-8c23-34f45d9dd637	0bf949b7-932b-40ba-8d67-4ea888360556	تست و اطمینان از عملکرد صحیح	137	78	2026-06-29	approved	c2241423-6f70-4f15-92a9-c4a433dfec70	\N	01261913-beba-4d89-bf44-00af0c256c47	2026-07-20 11:46:45.199839+00	2026-07-20 11:46:45.199839+00
6fa5de46-9edd-404a-915e-89d9f3f21ae7	9d941e57-248a-4748-b178-c41b43a24359	c700c6fb-ad08-4eaa-9597-f02c27aa0e58	رفع اشکالات و بازبینی	105	34	2026-07-16	approved	c2241423-6f70-4f15-92a9-c4a433dfec70	\N	db0c9f4b-264a-4660-a682-132dba5ea05b	2026-07-20 11:46:45.199839+00	2026-07-20 11:46:45.199839+00
6fa5de46-9edd-404a-915e-89d9f3f21ae7	9d941e57-248a-4748-b178-c41b43a24359	c700c6fb-ad08-4eaa-9597-f02c27aa0e58	مستندسازی و نهایی‌سازی	209	72	2026-07-16	approved	c2241423-6f70-4f15-92a9-c4a433dfec70	\N	deaf79d3-f3ea-4cc4-b26e-d21258916750	2026-07-20 11:46:45.199839+00	2026-07-20 11:46:45.199839+00
6fa5de46-9edd-404a-915e-89d9f3f21ae7	e2bf4f0f-c15a-463d-9255-ec9a51bd6551	16119c08-e43f-4846-adcd-f77ad1aca132	مستندسازی و نهایی‌سازی	191	26	2026-07-01	submitted	\N	\N	3888094e-0387-4602-b3e6-55b5856286cc	2026-07-20 11:46:45.199839+00	2026-07-20 11:46:45.199839+00
6fa5de46-9edd-404a-915e-89d9f3f21ae7	e2bf4f0f-c15a-463d-9255-ec9a51bd6551	16119c08-e43f-4846-adcd-f77ad1aca132	رفع اشکالات و بازبینی	205	62	2026-07-03	approved	c2241423-6f70-4f15-92a9-c4a433dfec70	\N	3ec61d4f-5d67-47a0-b603-d2b4120a0b4a	2026-07-20 11:46:45.199839+00	2026-07-20 11:46:45.199839+00
6fa5de46-9edd-404a-915e-89d9f3f21ae7	e2bf4f0f-c15a-463d-9255-ec9a51bd6551	16119c08-e43f-4846-adcd-f77ad1aca132	پیاده‌سازی بخش اصلی	158	100	2026-07-05	submitted	\N	\N	7454911c-7f73-421a-bf18-fb7da9eb036a	2026-07-20 11:46:45.199839+00	2026-07-20 11:46:45.199839+00
6fa5de46-9edd-404a-915e-89d9f3f21ae7	1979485e-17f3-4083-bb17-e8397cbcaead	0bf949b7-932b-40ba-8d67-4ea888360556	رفع اشکالات و بازبینی	173	35	2026-06-28	approved	c2241423-6f70-4f15-92a9-c4a433dfec70	\N	d3860ef8-9db3-43e7-906e-a4da4fac91bb	2026-07-20 11:46:45.199839+00	2026-07-20 11:46:45.199839+00
6fa5de46-9edd-404a-915e-89d9f3f21ae7	1979485e-17f3-4083-bb17-e8397cbcaead	0bf949b7-932b-40ba-8d67-4ea888360556	مستندسازی و نهایی‌سازی	103	66	2026-07-02	approved	c2241423-6f70-4f15-92a9-c4a433dfec70	\N	9f965e87-572a-4db3-a9d1-038e9e5ff5c5	2026-07-20 11:46:45.199839+00	2026-07-20 11:46:45.199839+00
6fa5de46-9edd-404a-915e-89d9f3f21ae7	1979485e-17f3-4083-bb17-e8397cbcaead	0bf949b7-932b-40ba-8d67-4ea888360556	مستندسازی و نهایی‌سازی	57	60	2026-06-30	approved	c2241423-6f70-4f15-92a9-c4a433dfec70	\N	57454799-3ab2-4eaa-a76e-f83c88309252	2026-07-20 11:46:45.199839+00	2026-07-20 11:46:45.199839+00
6fa5de46-9edd-404a-915e-89d9f3f21ae7	29b69f62-3ce5-401f-8b1e-6d75b155e829	0bf949b7-932b-40ba-8d67-4ea888360556	پیشرفت اولیه و بررسی نیازمندی‌ها	81	28	2026-06-21	approved	c2241423-6f70-4f15-92a9-c4a433dfec70	\N	46fb9550-08e8-4e98-ba39-acf9ed7aaec2	2026-07-20 11:46:45.199839+00	2026-07-20 11:46:45.199839+00
6fa5de46-9edd-404a-915e-89d9f3f21ae7	29b69f62-3ce5-401f-8b1e-6d75b155e829	0bf949b7-932b-40ba-8d67-4ea888360556	رفع اشکالات و بازبینی	67	42	2026-06-23	submitted	\N	\N	95de82b0-98a8-4eaa-a11c-139d9076f8d1	2026-07-20 11:46:45.199839+00	2026-07-20 11:46:45.199839+00
6fa5de46-9edd-404a-915e-89d9f3f21ae7	29b69f62-3ce5-401f-8b1e-6d75b155e829	0bf949b7-932b-40ba-8d67-4ea888360556	مستندسازی و نهایی‌سازی	38	93	2026-06-27	approved	c2241423-6f70-4f15-92a9-c4a433dfec70	\N	04bd7d6e-3d27-4408-8018-033aa1ba26c0	2026-07-20 11:46:45.199839+00	2026-07-20 11:46:45.199839+00
6fa5de46-9edd-404a-915e-89d9f3f21ae7	29b69f62-3ce5-401f-8b1e-6d75b155e829	0bf949b7-932b-40ba-8d67-4ea888360556	مستندسازی و نهایی‌سازی	87	100	2026-07-03	approved	c2241423-6f70-4f15-92a9-c4a433dfec70	\N	1e59171a-f681-4d3c-939e-f75f1b14dd24	2026-07-20 11:46:45.199839+00	2026-07-20 11:46:45.199839+00
6fa5de46-9edd-404a-915e-89d9f3f21ae7	724e2731-22a6-4823-a777-de83b8150d20	07fc03fd-5b06-4623-adbc-9d3292322efa	رفع اشکالات و بازبینی	207	21	2026-07-16	approved	c2241423-6f70-4f15-92a9-c4a433dfec70	\N	c25d1277-7dd7-4be7-8a22-197a7b667866	2026-07-20 11:46:45.199839+00	2026-07-20 11:46:45.199839+00
6fa5de46-9edd-404a-915e-89d9f3f21ae7	724e2731-22a6-4823-a777-de83b8150d20	07fc03fd-5b06-4623-adbc-9d3292322efa	رفع اشکالات و بازبینی	171	42	2026-07-16	approved	c2241423-6f70-4f15-92a9-c4a433dfec70	\N	354ddb91-7d99-4298-b38c-7122f5121b2d	2026-07-20 11:46:45.199839+00	2026-07-20 11:46:45.199839+00
6fa5de46-9edd-404a-915e-89d9f3f21ae7	724e2731-22a6-4823-a777-de83b8150d20	07fc03fd-5b06-4623-adbc-9d3292322efa	پیاده‌سازی بخش اصلی	188	100	2026-07-16	submitted	\N	\N	100640f7-e3ea-4b1d-8da4-170badb7b9ab	2026-07-20 11:46:45.199839+00	2026-07-20 11:46:45.199839+00
6fa5de46-9edd-404a-915e-89d9f3f21ae7	724e2731-22a6-4823-a777-de83b8150d20	07fc03fd-5b06-4623-adbc-9d3292322efa	رفع اشکالات و بازبینی	223	100	2026-07-16	submitted	\N	\N	6a861d98-60f9-4ec3-be2f-32f7862ff299	2026-07-20 11:46:45.199839+00	2026-07-20 11:46:45.199839+00
6fa5de46-9edd-404a-915e-89d9f3f21ae7	e6cef5f2-13a6-4336-ba11-dc3758aa7b24	16119c08-e43f-4846-adcd-f77ad1aca132	رفع اشکالات و بازبینی	144	25	2026-07-16	approved	c2241423-6f70-4f15-92a9-c4a433dfec70	\N	d0950ad5-82a1-4950-8f1b-0f1e3737f68a	2026-07-20 11:46:45.199839+00	2026-07-20 11:46:45.199839+00
6fa5de46-9edd-404a-915e-89d9f3f21ae7	e6cef5f2-13a6-4336-ba11-dc3758aa7b24	16119c08-e43f-4846-adcd-f77ad1aca132	پیاده‌سازی بخش اصلی	74	72	2026-07-16	approved	c2241423-6f70-4f15-92a9-c4a433dfec70	\N	691e4326-0b7e-42b5-b786-70fbfc4b7552	2026-07-20 11:46:45.199839+00	2026-07-20 11:46:45.199839+00
6fa5de46-9edd-404a-915e-89d9f3f21ae7	de9f2bf8-7068-4382-a5ad-5a4bd375dc71	cf5d8b24-a057-421e-9cc3-b442f742293f	پیشرفت اولیه و بررسی نیازمندی‌ها	139	28	2026-07-16	approved	c2241423-6f70-4f15-92a9-c4a433dfec70	\N	a0ebf881-b4c8-44c5-9c37-156f70ed08fe	2026-07-20 11:46:45.199839+00	2026-07-20 11:46:45.199839+00
6fa5de46-9edd-404a-915e-89d9f3f21ae7	216f5802-fcf0-4fb6-afce-6bc921c0858b	c2241423-6f70-4f15-92a9-c4a433dfec70	رفع اشکالات و بازبینی	31	30	2026-07-16	approved	c2241423-6f70-4f15-92a9-c4a433dfec70	\N	ae83c5b2-00dd-48de-8d89-f1b247ec3c77	2026-07-20 11:46:45.199839+00	2026-07-20 11:46:45.199839+00
6fa5de46-9edd-404a-915e-89d9f3f21ae7	216f5802-fcf0-4fb6-afce-6bc921c0858b	c2241423-6f70-4f15-92a9-c4a433dfec70	پیاده‌سازی بخش اصلی	40	48	2026-07-16	submitted	\N	\N	0359529d-ce95-4708-8d97-92ad070efb46	2026-07-20 11:46:45.199839+00	2026-07-20 11:46:45.199839+00
6fa5de46-9edd-404a-915e-89d9f3f21ae7	216f5802-fcf0-4fb6-afce-6bc921c0858b	c2241423-6f70-4f15-92a9-c4a433dfec70	مستندسازی و نهایی‌سازی	199	87	2026-07-16	approved	c2241423-6f70-4f15-92a9-c4a433dfec70	\N	31bef665-c007-40fe-a0a5-b1232998f0c5	2026-07-20 11:46:45.199839+00	2026-07-20 11:46:45.199839+00
6fa5de46-9edd-404a-915e-89d9f3f21ae7	387e2534-4e13-42d7-8239-b2725a713ff4	0bf949b7-932b-40ba-8d67-4ea888360556	پیشرفت اولیه و بررسی نیازمندی‌ها	230	30	2026-07-16	approved	c2241423-6f70-4f15-92a9-c4a433dfec70	\N	5af71198-d969-4720-9257-8ca86817cea6	2026-07-20 11:46:45.199839+00	2026-07-20 11:46:45.199839+00
6fa5de46-9edd-404a-915e-89d9f3f21ae7	387e2534-4e13-42d7-8239-b2725a713ff4	0bf949b7-932b-40ba-8d67-4ea888360556	پیاده‌سازی بخش اصلی	163	44	2026-07-16	approved	c2241423-6f70-4f15-92a9-c4a433dfec70	\N	7c3ff46f-a1ea-4381-b68c-e3acd71d8294	2026-07-20 11:46:45.199839+00	2026-07-20 11:46:45.199839+00
6fa5de46-9edd-404a-915e-89d9f3f21ae7	387e2534-4e13-42d7-8239-b2725a713ff4	0bf949b7-932b-40ba-8d67-4ea888360556	تست و اطمینان از عملکرد صحیح	169	100	2026-07-16	approved	c2241423-6f70-4f15-92a9-c4a433dfec70	\N	23b2f9b1-2665-4e5f-b723-dc7f2b098031	2026-07-20 11:46:45.199839+00	2026-07-20 11:46:45.199839+00
6fa5de46-9edd-404a-915e-89d9f3f21ae7	387e2534-4e13-42d7-8239-b2725a713ff4	0bf949b7-932b-40ba-8d67-4ea888360556	پیشرفت اولیه و بررسی نیازمندی‌ها	119	100	2026-07-16	approved	c2241423-6f70-4f15-92a9-c4a433dfec70	\N	5ac2deb5-c003-4a2b-a9f1-620fe0cf5ae5	2026-07-20 11:46:45.199839+00	2026-07-20 11:46:45.199839+00
6fa5de46-9edd-404a-915e-89d9f3f21ae7	476980dc-54db-43d9-a7b7-35755db6401a	07fc03fd-5b06-4623-adbc-9d3292322efa	رفع اشکالات و بازبینی	122	29	2026-07-16	approved	c2241423-6f70-4f15-92a9-c4a433dfec70	\N	704fc0d6-eac8-435c-9927-dde2a122cd62	2026-07-20 11:46:45.199839+00	2026-07-20 11:46:45.199839+00
6fa5de46-9edd-404a-915e-89d9f3f21ae7	476980dc-54db-43d9-a7b7-35755db6401a	07fc03fd-5b06-4623-adbc-9d3292322efa	مستندسازی و نهایی‌سازی	165	70	2026-07-16	approved	c2241423-6f70-4f15-92a9-c4a433dfec70	\N	3de9342a-a4b3-47c8-8f50-05c8cf665b00	2026-07-20 11:46:45.199839+00	2026-07-20 11:46:45.199839+00
6fa5de46-9edd-404a-915e-89d9f3f21ae7	384a495a-f801-4410-ba8b-a941eaa14343	cd92c461-1da5-4222-b6f0-60ce30f3d910	رفع اشکالات و بازبینی	144	27	2026-06-16	approved	c2241423-6f70-4f15-92a9-c4a433dfec70	\N	ca2fe0d2-0b90-4481-9c03-3c3ad9406c05	2026-07-20 11:46:45.199839+00	2026-07-20 11:46:45.199839+00
6fa5de46-9edd-404a-915e-89d9f3f21ae7	778e2d55-63db-46ad-a021-01d4ca11c6cc	c2241423-6f70-4f15-92a9-c4a433dfec70	رفع اشکالات و بازبینی	127	23	2026-06-25	approved	c2241423-6f70-4f15-92a9-c4a433dfec70	\N	d4572ae7-6f43-42a4-a50f-991bfc0c4e67	2026-07-20 11:46:45.199839+00	2026-07-20 11:46:45.199839+00
6fa5de46-9edd-404a-915e-89d9f3f21ae7	778e2d55-63db-46ad-a021-01d4ca11c6cc	c2241423-6f70-4f15-92a9-c4a433dfec70	رفع اشکالات و بازبینی	36	72	2026-06-29	approved	c2241423-6f70-4f15-92a9-c4a433dfec70	\N	a5f1a1ea-4325-4d00-9f1f-8fda810b982a	2026-07-20 11:46:45.199839+00	2026-07-20 11:46:45.199839+00
6fa5de46-9edd-404a-915e-89d9f3f21ae7	71c9ea7b-33bf-4612-a7f8-3970801ea8f6	cf5d8b24-a057-421e-9cc3-b442f742293f	رفع اشکالات و بازبینی	196	26	2026-07-10	approved	c2241423-6f70-4f15-92a9-c4a433dfec70	\N	e678940e-fb45-4255-a812-401972b535aa	2026-07-20 11:46:45.199839+00	2026-07-20 11:46:45.199839+00
6fa5de46-9edd-404a-915e-89d9f3f21ae7	71c9ea7b-33bf-4612-a7f8-3970801ea8f6	cf5d8b24-a057-421e-9cc3-b442f742293f	پیشرفت اولیه و بررسی نیازمندی‌ها	72	74	2026-07-13	approved	c2241423-6f70-4f15-92a9-c4a433dfec70	\N	41ca42cb-11f0-4b59-92db-d449ac2a7448	2026-07-20 11:46:45.199839+00	2026-07-20 11:46:45.199839+00
6fa5de46-9edd-404a-915e-89d9f3f21ae7	71c9ea7b-33bf-4612-a7f8-3970801ea8f6	cf5d8b24-a057-421e-9cc3-b442f742293f	پیاده‌سازی بخش اصلی	201	100	2026-07-12	approved	c2241423-6f70-4f15-92a9-c4a433dfec70	\N	0a83045c-9a60-4e1d-89d7-eb5fa12412b4	2026-07-20 11:46:45.199839+00	2026-07-20 11:46:45.199839+00
6fa5de46-9edd-404a-915e-89d9f3f21ae7	1e5df6f3-328a-40d6-9ed6-b39349d8bb67	16119c08-e43f-4846-adcd-f77ad1aca132	پیاده‌سازی بخش اصلی	167	33	2026-06-25	submitted	\N	\N	88ae138c-17cf-4c08-8123-5f0915ac15e6	2026-07-20 11:46:45.199839+00	2026-07-20 11:46:45.199839+00
6fa5de46-9edd-404a-915e-89d9f3f21ae7	1e5df6f3-328a-40d6-9ed6-b39349d8bb67	16119c08-e43f-4846-adcd-f77ad1aca132	پیاده‌سازی بخش اصلی	36	68	2026-06-26	submitted	\N	\N	8ed1a187-f56b-4090-bb61-249228a2d545	2026-07-20 11:46:45.199839+00	2026-07-20 11:46:45.199839+00
6fa5de46-9edd-404a-915e-89d9f3f21ae7	47119011-6f99-4866-9058-db8ec825d241	16119c08-e43f-4846-adcd-f77ad1aca132	پیشرفت اولیه و بررسی نیازمندی‌ها	48	21	2026-07-16	approved	c2241423-6f70-4f15-92a9-c4a433dfec70	\N	f212a75f-d38e-47c5-9eb8-1d127c9f9fe0	2026-07-20 11:46:45.199839+00	2026-07-20 11:46:45.199839+00
6fa5de46-9edd-404a-915e-89d9f3f21ae7	47119011-6f99-4866-9058-db8ec825d241	16119c08-e43f-4846-adcd-f77ad1aca132	رفع اشکالات و بازبینی	172	44	2026-07-16	approved	c2241423-6f70-4f15-92a9-c4a433dfec70	\N	043f9a1e-c7dc-43dc-b949-d75f9c1a09b1	2026-07-20 11:46:45.199839+00	2026-07-20 11:46:45.199839+00
6fa5de46-9edd-404a-915e-89d9f3f21ae7	47119011-6f99-4866-9058-db8ec825d241	16119c08-e43f-4846-adcd-f77ad1aca132	رفع اشکالات و بازبینی	134	96	2026-07-16	approved	c2241423-6f70-4f15-92a9-c4a433dfec70	\N	569f23aa-17fa-4398-adfe-4f478866e8ca	2026-07-20 11:46:45.199839+00	2026-07-20 11:46:45.199839+00
6fa5de46-9edd-404a-915e-89d9f3f21ae7	84ed4d26-f0ab-43e4-9daf-2b7034f1a7cf	c2241423-6f70-4f15-92a9-c4a433dfec70	پیشرفت اولیه و بررسی نیازمندی‌ها	129	23	2026-07-16	approved	c2241423-6f70-4f15-92a9-c4a433dfec70	\N	013dd744-9c9b-4422-b5c7-ff2a223a7d19	2026-07-20 11:46:45.199839+00	2026-07-20 11:46:45.199839+00
6fa5de46-9edd-404a-915e-89d9f3f21ae7	84ed4d26-f0ab-43e4-9daf-2b7034f1a7cf	c2241423-6f70-4f15-92a9-c4a433dfec70	مستندسازی و نهایی‌سازی	46	76	2026-07-16	approved	c2241423-6f70-4f15-92a9-c4a433dfec70	\N	c3b1a44c-843a-4ca1-aa7a-fe4341aabc7e	2026-07-20 11:46:45.199839+00	2026-07-20 11:46:45.199839+00
6fa5de46-9edd-404a-915e-89d9f3f21ae7	84ed4d26-f0ab-43e4-9daf-2b7034f1a7cf	c2241423-6f70-4f15-92a9-c4a433dfec70	پیشرفت اولیه و بررسی نیازمندی‌ها	121	100	2026-07-16	submitted	\N	\N	db3ead13-6170-4b48-996c-cfccf2cdf86f	2026-07-20 11:46:45.199839+00	2026-07-20 11:46:45.199839+00
6fa5de46-9edd-404a-915e-89d9f3f21ae7	84ed4d26-f0ab-43e4-9daf-2b7034f1a7cf	c2241423-6f70-4f15-92a9-c4a433dfec70	رفع اشکالات و بازبینی	185	88	2026-07-16	approved	c2241423-6f70-4f15-92a9-c4a433dfec70	\N	635ace23-9688-4294-a940-f7b8d9fe2f4e	2026-07-20 11:46:45.199839+00	2026-07-20 11:46:45.199839+00
6fa5de46-9edd-404a-915e-89d9f3f21ae7	79c62471-1912-41ae-bfb9-b02d5a18e580	16119c08-e43f-4846-adcd-f77ad1aca132	پیشرفت اولیه و بررسی نیازمندی‌ها	151	25	2026-07-16	approved	c2241423-6f70-4f15-92a9-c4a433dfec70	\N	0fafad56-eefc-49ba-bd56-e6922a8eea06	2026-07-20 11:46:45.199839+00	2026-07-20 11:46:45.199839+00
6fa5de46-9edd-404a-915e-89d9f3f21ae7	79c62471-1912-41ae-bfb9-b02d5a18e580	16119c08-e43f-4846-adcd-f77ad1aca132	تست و اطمینان از عملکرد صحیح	233	74	2026-07-16	approved	c2241423-6f70-4f15-92a9-c4a433dfec70	\N	4cad5998-bac4-416b-b209-e3e0025994e7	2026-07-20 11:46:45.199839+00	2026-07-20 11:46:45.199839+00
6fa5de46-9edd-404a-915e-89d9f3f21ae7	79c62471-1912-41ae-bfb9-b02d5a18e580	16119c08-e43f-4846-adcd-f77ad1aca132	پیاده‌سازی بخش اصلی	106	100	2026-07-16	submitted	\N	\N	b0199ac1-53eb-488c-a97d-a319db746e2d	2026-07-20 11:46:45.199839+00	2026-07-20 11:46:45.199839+00
6fa5de46-9edd-404a-915e-89d9f3f21ae7	b9cff182-d720-4d76-9a5b-1b37b3842fae	c700c6fb-ad08-4eaa-9597-f02c27aa0e58	مستندسازی و نهایی‌سازی	66	23	2026-07-16	approved	c2241423-6f70-4f15-92a9-c4a433dfec70	\N	ed274b06-b3b1-4f02-89ba-1ad87959980e	2026-07-20 11:46:45.199839+00	2026-07-20 11:46:45.199839+00
6fa5de46-9edd-404a-915e-89d9f3f21ae7	b9cff182-d720-4d76-9a5b-1b37b3842fae	c700c6fb-ad08-4eaa-9597-f02c27aa0e58	مستندسازی و نهایی‌سازی	130	74	2026-07-16	approved	c2241423-6f70-4f15-92a9-c4a433dfec70	\N	4fed222e-587e-4017-b7f0-c9373450cb15	2026-07-20 11:46:45.199839+00	2026-07-20 11:46:45.199839+00
6fa5de46-9edd-404a-915e-89d9f3f21ae7	b9cff182-d720-4d76-9a5b-1b37b3842fae	c700c6fb-ad08-4eaa-9597-f02c27aa0e58	رفع اشکالات و بازبینی	84	99	2026-07-16	approved	c2241423-6f70-4f15-92a9-c4a433dfec70	\N	f366a08d-d036-41e3-84a4-a806a1651932	2026-07-20 11:46:45.199839+00	2026-07-20 11:46:45.199839+00
6fa5de46-9edd-404a-915e-89d9f3f21ae7	44b2d040-31d8-4f86-89b5-7c39bf8b2979	07fc03fd-5b06-4623-adbc-9d3292322efa	پیاده‌سازی بخش اصلی	86	39	2026-06-17	approved	c2241423-6f70-4f15-92a9-c4a433dfec70	\N	e1990b44-82a6-4260-aab8-a504121c06b7	2026-07-20 11:46:45.199839+00	2026-07-20 11:46:45.199839+00
6fa5de46-9edd-404a-915e-89d9f3f21ae7	44b2d040-31d8-4f86-89b5-7c39bf8b2979	07fc03fd-5b06-4623-adbc-9d3292322efa	پیاده‌سازی بخش اصلی	59	50	2026-06-20	approved	c2241423-6f70-4f15-92a9-c4a433dfec70	\N	d6e31fe6-2b0e-468b-b61b-564b082a5c2b	2026-07-20 11:46:45.199839+00	2026-07-20 11:46:45.199839+00
6fa5de46-9edd-404a-915e-89d9f3f21ae7	37370659-b015-4d80-8d8f-5a96661e1523	07fc03fd-5b06-4623-adbc-9d3292322efa	مستندسازی و نهایی‌سازی	48	29	2026-07-16	approved	c2241423-6f70-4f15-92a9-c4a433dfec70	\N	2d1c31c8-965b-4d8b-b045-f9540f351493	2026-07-20 11:46:45.199839+00	2026-07-20 11:46:45.199839+00
6fa5de46-9edd-404a-915e-89d9f3f21ae7	e470138e-4ec3-4d05-9919-82c3fd0d1781	cf5d8b24-a057-421e-9cc3-b442f742293f	پیشرفت اولیه و بررسی نیازمندی‌ها	80	38	2026-07-16	approved	c2241423-6f70-4f15-92a9-c4a433dfec70	\N	45d162ec-c267-4be6-8237-dd4e5a58cabd	2026-07-20 11:46:45.199839+00	2026-07-20 11:46:45.199839+00
6fa5de46-9edd-404a-915e-89d9f3f21ae7	5d80edd8-8e71-487b-a5ce-729e923ee9d0	c700c6fb-ad08-4eaa-9597-f02c27aa0e58	پیاده‌سازی بخش اصلی	55	29	2026-07-16	approved	c2241423-6f70-4f15-92a9-c4a433dfec70	\N	92448a94-51f7-4d55-980d-1df02a4402c7	2026-07-20 11:46:45.199839+00	2026-07-20 11:46:45.199839+00
6fa5de46-9edd-404a-915e-89d9f3f21ae7	5d80edd8-8e71-487b-a5ce-729e923ee9d0	c700c6fb-ad08-4eaa-9597-f02c27aa0e58	رفع اشکالات و بازبینی	154	68	2026-07-16	submitted	\N	\N	c2a9c361-24ad-49ce-a2f7-ddff87a0663f	2026-07-20 11:46:45.199839+00	2026-07-20 11:46:45.199839+00
6fa5de46-9edd-404a-915e-89d9f3f21ae7	5d80edd8-8e71-487b-a5ce-729e923ee9d0	c700c6fb-ad08-4eaa-9597-f02c27aa0e58	رفع اشکالات و بازبینی	207	100	2026-07-16	approved	c2241423-6f70-4f15-92a9-c4a433dfec70	\N	0102fe77-baa9-4205-9199-2b23b3dc7217	2026-07-20 11:46:45.199839+00	2026-07-20 11:46:45.199839+00
6fa5de46-9edd-404a-915e-89d9f3f21ae7	5d80edd8-8e71-487b-a5ce-729e923ee9d0	c700c6fb-ad08-4eaa-9597-f02c27aa0e58	رفع اشکالات و بازبینی	236	100	2026-07-16	approved	c2241423-6f70-4f15-92a9-c4a433dfec70	\N	af218566-9ec1-48cb-b43f-70daca99145f	2026-07-20 11:46:45.199839+00	2026-07-20 11:46:45.199839+00
6fa5de46-9edd-404a-915e-89d9f3f21ae7	af8720ff-0e1b-41bc-af11-d34f86e49df7	07fc03fd-5b06-4623-adbc-9d3292322efa	پیشرفت اولیه و بررسی نیازمندی‌ها	110	27	2026-06-29	approved	c2241423-6f70-4f15-92a9-c4a433dfec70	\N	368063ab-c082-4634-834b-b85a05ca5c9d	2026-07-20 11:46:45.199839+00	2026-07-20 11:46:45.199839+00
6fa5de46-9edd-404a-915e-89d9f3f21ae7	af8720ff-0e1b-41bc-af11-d34f86e49df7	07fc03fd-5b06-4623-adbc-9d3292322efa	تست و اطمینان از عملکرد صحیح	100	62	2026-07-01	approved	c2241423-6f70-4f15-92a9-c4a433dfec70	\N	a5b0661f-af3b-4cdb-b075-df9820ee596f	2026-07-20 11:46:45.199839+00	2026-07-20 11:46:45.199839+00
6fa5de46-9edd-404a-915e-89d9f3f21ae7	af8720ff-0e1b-41bc-af11-d34f86e49df7	07fc03fd-5b06-4623-adbc-9d3292322efa	رفع اشکالات و بازبینی	152	100	2026-07-03	approved	c2241423-6f70-4f15-92a9-c4a433dfec70	\N	667fcc28-4125-486b-a498-206172e87c45	2026-07-20 11:46:45.199839+00	2026-07-20 11:46:45.199839+00
6fa5de46-9edd-404a-915e-89d9f3f21ae7	af8720ff-0e1b-41bc-af11-d34f86e49df7	07fc03fd-5b06-4623-adbc-9d3292322efa	رفع اشکالات و بازبینی	228	100	2026-07-11	approved	c2241423-6f70-4f15-92a9-c4a433dfec70	\N	f1979b8a-deda-4803-b2fe-9ae6efd40d9d	2026-07-20 11:46:45.199839+00	2026-07-20 11:46:45.199839+00
6fa5de46-9edd-404a-915e-89d9f3f21ae7	79915aad-3657-42d5-afbb-6ca2237797e9	16119c08-e43f-4846-adcd-f77ad1aca132	پیاده‌سازی بخش اصلی	195	39	2026-06-17	approved	c2241423-6f70-4f15-92a9-c4a433dfec70	\N	570c1e95-9e52-449b-a1c8-495d0d61f18b	2026-07-20 11:46:45.199839+00	2026-07-20 11:46:45.199839+00
6fa5de46-9edd-404a-915e-89d9f3f21ae7	79915aad-3657-42d5-afbb-6ca2237797e9	16119c08-e43f-4846-adcd-f77ad1aca132	رفع اشکالات و بازبینی	65	74	2026-06-18	approved	c2241423-6f70-4f15-92a9-c4a433dfec70	\N	aa500e6e-045a-4351-a96e-d56e54a09cc0	2026-07-20 11:46:45.199839+00	2026-07-20 11:46:45.199839+00
6fa5de46-9edd-404a-915e-89d9f3f21ae7	79915aad-3657-42d5-afbb-6ca2237797e9	16119c08-e43f-4846-adcd-f77ad1aca132	رفع اشکالات و بازبینی	217	100	2026-06-21	approved	c2241423-6f70-4f15-92a9-c4a433dfec70	\N	f61dae30-09bd-41a3-beeb-2f1093cc4b95	2026-07-20 11:46:45.199839+00	2026-07-20 11:46:45.199839+00
6fa5de46-9edd-404a-915e-89d9f3f21ae7	79915aad-3657-42d5-afbb-6ca2237797e9	16119c08-e43f-4846-adcd-f77ad1aca132	پیشرفت اولیه و بررسی نیازمندی‌ها	34	100	2026-06-20	approved	c2241423-6f70-4f15-92a9-c4a433dfec70	\N	f127eca6-f320-4b2f-a360-020e6744e6a1	2026-07-20 11:46:45.199839+00	2026-07-20 11:46:45.199839+00
6fa5de46-9edd-404a-915e-89d9f3f21ae7	0573a164-5530-431a-a229-9d8dc6471418	cf5d8b24-a057-421e-9cc3-b442f742293f	پیاده‌سازی بخش اصلی	39	37	2026-07-15	submitted	\N	\N	834bafdf-7413-4269-8976-1de74ebf4d43	2026-07-20 11:46:45.199839+00	2026-07-20 11:46:45.199839+00
6fa5de46-9edd-404a-915e-89d9f3f21ae7	572b3a58-7551-4804-bc0d-d4a583aaeddf	07fc03fd-5b06-4623-adbc-9d3292322efa	پیاده‌سازی بخش اصلی	123	32	2026-06-22	approved	c2241423-6f70-4f15-92a9-c4a433dfec70	\N	25a4938d-a763-4b96-b9b4-f3b4692c7e42	2026-07-20 11:46:45.199839+00	2026-07-20 11:46:45.199839+00
6fa5de46-9edd-404a-915e-89d9f3f21ae7	572b3a58-7551-4804-bc0d-d4a583aaeddf	07fc03fd-5b06-4623-adbc-9d3292322efa	مستندسازی و نهایی‌سازی	217	58	2026-06-24	approved	c2241423-6f70-4f15-92a9-c4a433dfec70	\N	3e4439e1-d13e-45ae-919a-9d8ac56e8d85	2026-07-20 11:46:45.199839+00	2026-07-20 11:46:45.199839+00
6fa5de46-9edd-404a-915e-89d9f3f21ae7	572b3a58-7551-4804-bc0d-d4a583aaeddf	07fc03fd-5b06-4623-adbc-9d3292322efa	تست و اطمینان از عملکرد صحیح	158	100	2026-06-26	approved	c2241423-6f70-4f15-92a9-c4a433dfec70	\N	8326422d-e929-4bc6-a0fe-c0c0f71825f5	2026-07-20 11:46:45.199839+00	2026-07-20 11:46:45.199839+00
6fa5de46-9edd-404a-915e-89d9f3f21ae7	0f8471e9-c184-42b5-883a-a8a92c2251bd	07fc03fd-5b06-4623-adbc-9d3292322efa	پیشرفت اولیه و بررسی نیازمندی‌ها	199	27	2026-07-16	approved	c2241423-6f70-4f15-92a9-c4a433dfec70	\N	8a5d6b65-e210-4fe0-bef1-6ef0379ef466	2026-07-20 11:46:45.199839+00	2026-07-20 11:46:45.199839+00
6fa5de46-9edd-404a-915e-89d9f3f21ae7	11c3323b-eaf8-4691-b05a-7aee46a8cf38	0bf949b7-932b-40ba-8d67-4ea888360556	تست و اطمینان از عملکرد صحیح	70	25	2026-06-25	approved	c2241423-6f70-4f15-92a9-c4a433dfec70	\N	c2ee7e2a-ce0c-4765-9a0b-c78d933d996b	2026-07-20 11:46:45.199839+00	2026-07-20 11:46:45.199839+00
6fa5de46-9edd-404a-915e-89d9f3f21ae7	11c3323b-eaf8-4691-b05a-7aee46a8cf38	0bf949b7-932b-40ba-8d67-4ea888360556	تست و اطمینان از عملکرد صحیح	121	42	2026-06-27	approved	c2241423-6f70-4f15-92a9-c4a433dfec70	\N	169a7388-dfea-40cc-8d26-ef19f657e054	2026-07-20 11:46:45.199839+00	2026-07-20 11:46:45.199839+00
6fa5de46-9edd-404a-915e-89d9f3f21ae7	a17d3814-02b6-4b17-8526-d8d9c4196f92	07fc03fd-5b06-4623-adbc-9d3292322efa	پیاده‌سازی بخش اصلی	46	28	2026-07-06	approved	c2241423-6f70-4f15-92a9-c4a433dfec70	\N	163f86d0-9cca-4526-80a2-7f7f4675630d	2026-07-20 11:46:45.199839+00	2026-07-20 11:46:45.199839+00
6fa5de46-9edd-404a-915e-89d9f3f21ae7	a17d3814-02b6-4b17-8526-d8d9c4196f92	07fc03fd-5b06-4623-adbc-9d3292322efa	پیاده‌سازی بخش اصلی	40	52	2026-07-09	approved	c2241423-6f70-4f15-92a9-c4a433dfec70	\N	218e8531-334e-4ad3-a4be-3604f8466cc6	2026-07-20 11:46:45.199839+00	2026-07-20 11:46:45.199839+00
6fa5de46-9edd-404a-915e-89d9f3f21ae7	dbd092d1-adb9-47b5-82ba-8dfc00d178c6	16119c08-e43f-4846-adcd-f77ad1aca132	تست و اطمینان از عملکرد صحیح	41	21	2026-07-16	approved	c2241423-6f70-4f15-92a9-c4a433dfec70	\N	c01f2bb2-b66b-4911-b4cd-425ae4415c9c	2026-07-20 11:46:45.199839+00	2026-07-20 11:46:45.199839+00
6fa5de46-9edd-404a-915e-89d9f3f21ae7	dbd092d1-adb9-47b5-82ba-8dfc00d178c6	16119c08-e43f-4846-adcd-f77ad1aca132	مستندسازی و نهایی‌سازی	192	56	2026-07-16	approved	c2241423-6f70-4f15-92a9-c4a433dfec70	\N	5e74925f-8a37-4719-b1f8-d7d3ff865b87	2026-07-20 11:46:45.199839+00	2026-07-20 11:46:45.199839+00
6fa5de46-9edd-404a-915e-89d9f3f21ae7	dbd092d1-adb9-47b5-82ba-8dfc00d178c6	16119c08-e43f-4846-adcd-f77ad1aca132	مستندسازی و نهایی‌سازی	74	96	2026-07-16	approved	c2241423-6f70-4f15-92a9-c4a433dfec70	\N	f4cc519e-7429-486e-b353-b25752669114	2026-07-20 11:46:45.199839+00	2026-07-20 11:46:45.199839+00
6fa5de46-9edd-404a-915e-89d9f3f21ae7	d5c5e748-99f6-4a47-b439-87244cf58419	0bf949b7-932b-40ba-8d67-4ea888360556	پیشرفت اولیه و بررسی نیازمندی‌ها	162	28	2026-07-16	approved	c2241423-6f70-4f15-92a9-c4a433dfec70	\N	dba35fb6-1169-4d01-8e0c-3f3d8f66f68d	2026-07-20 11:46:45.199839+00	2026-07-20 11:46:45.199839+00
6fa5de46-9edd-404a-915e-89d9f3f21ae7	d5c5e748-99f6-4a47-b439-87244cf58419	0bf949b7-932b-40ba-8d67-4ea888360556	پیاده‌سازی بخش اصلی	162	64	2026-07-16	submitted	\N	\N	af9cd3a7-2af8-4319-94b1-bad88da4304c	2026-07-20 11:46:45.199839+00	2026-07-20 11:46:45.199839+00
6fa5de46-9edd-404a-915e-89d9f3f21ae7	d5c5e748-99f6-4a47-b439-87244cf58419	0bf949b7-932b-40ba-8d67-4ea888360556	رفع اشکالات و بازبینی	154	100	2026-07-16	submitted	\N	\N	82c79d5d-5019-4824-9e10-2a0bb2e9d68c	2026-07-20 11:46:45.199839+00	2026-07-20 11:46:45.199839+00
6fa5de46-9edd-404a-915e-89d9f3f21ae7	d5c5e748-99f6-4a47-b439-87244cf58419	0bf949b7-932b-40ba-8d67-4ea888360556	پیاده‌سازی بخش اصلی	142	100	2026-07-16	approved	c2241423-6f70-4f15-92a9-c4a433dfec70	\N	e4b25364-d36f-4a45-b471-aab260311d3f	2026-07-20 11:46:45.199839+00	2026-07-20 11:46:45.199839+00
6fa5de46-9edd-404a-915e-89d9f3f21ae7	61a1127c-6765-4dcf-9c06-7dbdd0d13f82	c2241423-6f70-4f15-92a9-c4a433dfec70	مستندسازی و نهایی‌سازی	194	28	2026-07-02	approved	c2241423-6f70-4f15-92a9-c4a433dfec70	\N	716c738f-d389-4cdf-9227-d2106a25a3c5	2026-07-20 11:46:45.199839+00	2026-07-20 11:46:45.199839+00
6fa5de46-9edd-404a-915e-89d9f3f21ae7	61a1127c-6765-4dcf-9c06-7dbdd0d13f82	c2241423-6f70-4f15-92a9-c4a433dfec70	پیاده‌سازی بخش اصلی	77	50	2026-07-04	approved	c2241423-6f70-4f15-92a9-c4a433dfec70	\N	5f79279a-c484-45d5-bbb1-99b5a6e53035	2026-07-20 11:46:45.199839+00	2026-07-20 11:46:45.199839+00
6fa5de46-9edd-404a-915e-89d9f3f21ae7	ffe1f5cb-aea7-4e93-9d73-c7fcc0757c05	16119c08-e43f-4846-adcd-f77ad1aca132	پیاده‌سازی بخش اصلی	136	30	2026-07-08	approved	c2241423-6f70-4f15-92a9-c4a433dfec70	\N	449d6976-3aeb-42fa-86c8-d7958fb41720	2026-07-20 11:46:45.199839+00	2026-07-20 11:46:45.199839+00
6fa5de46-9edd-404a-915e-89d9f3f21ae7	ffe1f5cb-aea7-4e93-9d73-c7fcc0757c05	16119c08-e43f-4846-adcd-f77ad1aca132	تست و اطمینان از عملکرد صحیح	202	70	2026-07-09	approved	c2241423-6f70-4f15-92a9-c4a433dfec70	\N	01752594-73c2-415f-bdbc-e2403fdc5225	2026-07-20 11:46:45.199839+00	2026-07-20 11:46:45.199839+00
6fa5de46-9edd-404a-915e-89d9f3f21ae7	ffe1f5cb-aea7-4e93-9d73-c7fcc0757c05	16119c08-e43f-4846-adcd-f77ad1aca132	پیاده‌سازی بخش اصلی	181	75	2026-07-16	approved	c2241423-6f70-4f15-92a9-c4a433dfec70	\N	699c6670-01d9-4023-b19d-0668c644dc60	2026-07-20 11:46:45.199839+00	2026-07-20 11:46:45.199839+00
6fa5de46-9edd-404a-915e-89d9f3f21ae7	11bf9856-746f-4342-bb36-fb1d8c3e0a0b	16119c08-e43f-4846-adcd-f77ad1aca132	پیاده‌سازی بخش اصلی	176	38	2026-07-02	approved	c2241423-6f70-4f15-92a9-c4a433dfec70	\N	14d7f43e-a512-4014-a0bb-2b0d0016d0ef	2026-07-20 11:46:45.199839+00	2026-07-20 11:46:45.199839+00
6fa5de46-9edd-404a-915e-89d9f3f21ae7	11bf9856-746f-4342-bb36-fb1d8c3e0a0b	16119c08-e43f-4846-adcd-f77ad1aca132	مستندسازی و نهایی‌سازی	40	76	2026-07-04	approved	c2241423-6f70-4f15-92a9-c4a433dfec70	\N	7709038c-4552-4d22-b7fb-81549dd1be70	2026-07-20 11:46:45.199839+00	2026-07-20 11:46:45.199839+00
6fa5de46-9edd-404a-915e-89d9f3f21ae7	11bf9856-746f-4342-bb36-fb1d8c3e0a0b	16119c08-e43f-4846-adcd-f77ad1aca132	رفع اشکالات و بازبینی	76	100	2026-07-06	approved	c2241423-6f70-4f15-92a9-c4a433dfec70	\N	896399ef-8222-40ec-a666-d0755a33c973	2026-07-20 11:46:45.199839+00	2026-07-20 11:46:45.199839+00
6fa5de46-9edd-404a-915e-89d9f3f21ae7	11bf9856-746f-4342-bb36-fb1d8c3e0a0b	16119c08-e43f-4846-adcd-f77ad1aca132	مستندسازی و نهایی‌سازی	193	80	2026-07-14	approved	c2241423-6f70-4f15-92a9-c4a433dfec70	\N	f72e1cd1-a7bb-42e9-8645-3976b81149da	2026-07-20 11:46:45.199839+00	2026-07-20 11:46:45.199839+00
6fa5de46-9edd-404a-915e-89d9f3f21ae7	af1e0862-ef05-4fd5-8002-5c9b545102aa	07fc03fd-5b06-4623-adbc-9d3292322efa	پیاده‌سازی بخش اصلی	144	39	2026-07-16	approved	c2241423-6f70-4f15-92a9-c4a433dfec70	\N	3a03ee9f-1f4f-47c8-abd9-6a0bc35cc808	2026-07-20 11:46:45.199839+00	2026-07-20 11:46:45.199839+00
6fa5de46-9edd-404a-915e-89d9f3f21ae7	af1e0862-ef05-4fd5-8002-5c9b545102aa	07fc03fd-5b06-4623-adbc-9d3292322efa	تست و اطمینان از عملکرد صحیح	73	54	2026-07-16	approved	c2241423-6f70-4f15-92a9-c4a433dfec70	\N	b21f7135-858e-4a05-9f4c-d02f1ee00ee2	2026-07-20 11:46:45.199839+00	2026-07-20 11:46:45.199839+00
6fa5de46-9edd-404a-915e-89d9f3f21ae7	af1e0862-ef05-4fd5-8002-5c9b545102aa	07fc03fd-5b06-4623-adbc-9d3292322efa	مستندسازی و نهایی‌سازی	66	100	2026-07-16	approved	c2241423-6f70-4f15-92a9-c4a433dfec70	\N	b2da0cae-0649-4926-b6aa-8f8589f90ba7	2026-07-20 11:46:45.199839+00	2026-07-20 11:46:45.199839+00
6fa5de46-9edd-404a-915e-89d9f3f21ae7	fb625cfb-f135-4530-b1e1-3da74454ae23	c700c6fb-ad08-4eaa-9597-f02c27aa0e58	رفع اشکالات و بازبینی	146	39	2026-07-16	approved	c2241423-6f70-4f15-92a9-c4a433dfec70	\N	148218bd-92ee-438d-8aca-e00b52b7afe0	2026-07-20 11:46:45.199839+00	2026-07-20 11:46:45.199839+00
6fa5de46-9edd-404a-915e-89d9f3f21ae7	fb625cfb-f135-4530-b1e1-3da74454ae23	c700c6fb-ad08-4eaa-9597-f02c27aa0e58	تست و اطمینان از عملکرد صحیح	63	46	2026-07-16	approved	c2241423-6f70-4f15-92a9-c4a433dfec70	\N	172db8ce-38bb-446a-b084-95854cc7a1b7	2026-07-20 11:46:45.199839+00	2026-07-20 11:46:45.199839+00
6fa5de46-9edd-404a-915e-89d9f3f21ae7	501e8a21-b889-4d2a-999d-f0087c0d6c11	0bf949b7-932b-40ba-8d67-4ea888360556	مستندسازی و نهایی‌سازی	205	33	2026-07-11	approved	c2241423-6f70-4f15-92a9-c4a433dfec70	\N	1f1f37bb-16e0-43eb-adfb-a293cf4eff9d	2026-07-20 11:46:45.199839+00	2026-07-20 11:46:45.199839+00
6fa5de46-9edd-404a-915e-89d9f3f21ae7	299d172c-b55e-4816-9b99-6774a97ff257	c700c6fb-ad08-4eaa-9597-f02c27aa0e58	پیاده‌سازی بخش اصلی	151	39	2026-07-09	approved	c2241423-6f70-4f15-92a9-c4a433dfec70	\N	f8f2a27f-a94a-4ac7-9a2c-47f4fe7b71e7	2026-07-20 11:46:45.199839+00	2026-07-20 11:46:45.199839+00
6fa5de46-9edd-404a-915e-89d9f3f21ae7	299d172c-b55e-4816-9b99-6774a97ff257	c700c6fb-ad08-4eaa-9597-f02c27aa0e58	مستندسازی و نهایی‌سازی	158	46	2026-07-10	approved	c2241423-6f70-4f15-92a9-c4a433dfec70	\N	83afbd9b-15b5-42dd-bbea-be46beb141ad	2026-07-20 11:46:45.199839+00	2026-07-20 11:46:45.199839+00
6fa5de46-9edd-404a-915e-89d9f3f21ae7	593373ee-dde5-4cf5-89c8-9805761c391b	c2241423-6f70-4f15-92a9-c4a433dfec70	مستندسازی و نهایی‌سازی	168	20	2026-07-16	approved	c2241423-6f70-4f15-92a9-c4a433dfec70	\N	afb9ce63-70e4-479f-9057-e84e42e848bd	2026-07-20 11:46:45.199839+00	2026-07-20 11:46:45.199839+00
6fa5de46-9edd-404a-915e-89d9f3f21ae7	6763cf89-2f64-457d-85f7-057e33bb9204	16119c08-e43f-4846-adcd-f77ad1aca132	پیشرفت اولیه و بررسی نیازمندی‌ها	208	36	2026-07-15	approved	c2241423-6f70-4f15-92a9-c4a433dfec70	\N	69187187-de2e-444f-a138-925b325a6ea2	2026-07-20 11:46:45.199839+00	2026-07-20 11:46:45.199839+00
6fa5de46-9edd-404a-915e-89d9f3f21ae7	6763cf89-2f64-457d-85f7-057e33bb9204	16119c08-e43f-4846-adcd-f77ad1aca132	تست و اطمینان از عملکرد صحیح	232	64	2026-07-16	approved	c2241423-6f70-4f15-92a9-c4a433dfec70	\N	b5ea383a-ee1c-49d4-9218-1fe1df12cddb	2026-07-20 11:46:45.199839+00	2026-07-20 11:46:45.199839+00
6fa5de46-9edd-404a-915e-89d9f3f21ae7	6763cf89-2f64-457d-85f7-057e33bb9204	16119c08-e43f-4846-adcd-f77ad1aca132	مستندسازی و نهایی‌سازی	55	99	2026-07-16	approved	c2241423-6f70-4f15-92a9-c4a433dfec70	\N	f0961a58-ec5c-4612-9b2c-892fe86976a5	2026-07-20 11:46:45.199839+00	2026-07-20 11:46:45.199839+00
6fa5de46-9edd-404a-915e-89d9f3f21ae7	6763cf89-2f64-457d-85f7-057e33bb9204	16119c08-e43f-4846-adcd-f77ad1aca132	پیاده‌سازی بخش اصلی	51	100	2026-07-16	approved	c2241423-6f70-4f15-92a9-c4a433dfec70	\N	ea23096d-4c62-414e-ae8c-d56738c0acf3	2026-07-20 11:46:45.199839+00	2026-07-20 11:46:45.199839+00
6fa5de46-9edd-404a-915e-89d9f3f21ae7	e6f414fa-ed51-4895-ba4d-255358ef63cb	07fc03fd-5b06-4623-adbc-9d3292322efa	پیشرفت اولیه و بررسی نیازمندی‌ها	177	36	2026-06-17	approved	c2241423-6f70-4f15-92a9-c4a433dfec70	\N	01b8f5c9-790a-40bb-b8a6-84e47bffad6b	2026-07-20 11:46:45.199839+00	2026-07-20 11:46:45.199839+00
6fa5de46-9edd-404a-915e-89d9f3f21ae7	e6f414fa-ed51-4895-ba4d-255358ef63cb	07fc03fd-5b06-4623-adbc-9d3292322efa	تست و اطمینان از عملکرد صحیح	197	52	2026-06-18	approved	c2241423-6f70-4f15-92a9-c4a433dfec70	\N	6f97bbaa-2467-4400-a45f-a0ac99fe75c9	2026-07-20 11:46:45.199839+00	2026-07-20 11:46:45.199839+00
6fa5de46-9edd-404a-915e-89d9f3f21ae7	e6f414fa-ed51-4895-ba4d-255358ef63cb	07fc03fd-5b06-4623-adbc-9d3292322efa	پیشرفت اولیه و بررسی نیازمندی‌ها	69	99	2026-06-23	approved	c2241423-6f70-4f15-92a9-c4a433dfec70	\N	25fdee9c-feb6-45ae-86c3-baad85550f20	2026-07-20 11:46:45.199839+00	2026-07-20 11:46:45.199839+00
6fa5de46-9edd-404a-915e-89d9f3f21ae7	e6f414fa-ed51-4895-ba4d-255358ef63cb	07fc03fd-5b06-4623-adbc-9d3292322efa	مستندسازی و نهایی‌سازی	138	100	2026-06-26	approved	c2241423-6f70-4f15-92a9-c4a433dfec70	\N	93b11e7f-eb93-438c-b54c-d59ad4d2f308	2026-07-20 11:46:45.199839+00	2026-07-20 11:46:45.199839+00
6fa5de46-9edd-404a-915e-89d9f3f21ae7	16549894-f239-4c74-bd40-a63aff2d7bb3	c2241423-6f70-4f15-92a9-c4a433dfec70	تست و اطمینان از عملکرد صحیح	223	26	2026-06-23	approved	c2241423-6f70-4f15-92a9-c4a433dfec70	\N	2b4a0868-558e-43fc-a226-33e712725643	2026-07-20 11:46:45.199839+00	2026-07-20 11:46:45.199839+00
6fa5de46-9edd-404a-915e-89d9f3f21ae7	16549894-f239-4c74-bd40-a63aff2d7bb3	c2241423-6f70-4f15-92a9-c4a433dfec70	مستندسازی و نهایی‌سازی	230	74	2026-06-27	approved	c2241423-6f70-4f15-92a9-c4a433dfec70	\N	16ab5ac7-7676-4ab6-8870-2dcf1a482227	2026-07-20 11:46:45.199839+00	2026-07-20 11:46:45.199839+00
6fa5de46-9edd-404a-915e-89d9f3f21ae7	16549894-f239-4c74-bd40-a63aff2d7bb3	c2241423-6f70-4f15-92a9-c4a433dfec70	پیاده‌سازی بخش اصلی	124	100	2026-07-01	approved	c2241423-6f70-4f15-92a9-c4a433dfec70	\N	69078314-93bd-49f7-9fbb-69bfc2dd24a4	2026-07-20 11:46:45.199839+00	2026-07-20 11:46:45.199839+00
6fa5de46-9edd-404a-915e-89d9f3f21ae7	b3800102-8420-4e55-b6eb-2d7486f33115	cf5d8b24-a057-421e-9cc3-b442f742293f	رفع اشکالات و بازبینی	177	31	2026-07-16	approved	c2241423-6f70-4f15-92a9-c4a433dfec70	\N	374273a1-861d-4db6-8970-6549bb25b96b	2026-07-20 11:46:45.199839+00	2026-07-20 11:46:45.199839+00
6fa5de46-9edd-404a-915e-89d9f3f21ae7	b3800102-8420-4e55-b6eb-2d7486f33115	cf5d8b24-a057-421e-9cc3-b442f742293f	پیاده‌سازی بخش اصلی	198	46	2026-07-16	approved	c2241423-6f70-4f15-92a9-c4a433dfec70	\N	d8522b02-b0f3-4d11-9070-ae6a3d750148	2026-07-20 11:46:45.199839+00	2026-07-20 11:46:45.199839+00
6fa5de46-9edd-404a-915e-89d9f3f21ae7	b3800102-8420-4e55-b6eb-2d7486f33115	cf5d8b24-a057-421e-9cc3-b442f742293f	تست و اطمینان از عملکرد صحیح	230	75	2026-07-16	approved	c2241423-6f70-4f15-92a9-c4a433dfec70	\N	957d7a6f-88eb-4b2b-9458-9fa90e1fa1c1	2026-07-20 11:46:45.199839+00	2026-07-20 11:46:45.199839+00
6fa5de46-9edd-404a-915e-89d9f3f21ae7	b3800102-8420-4e55-b6eb-2d7486f33115	cf5d8b24-a057-421e-9cc3-b442f742293f	پیاده‌سازی بخش اصلی	160	100	2026-07-16	approved	c2241423-6f70-4f15-92a9-c4a433dfec70	\N	ac90be96-0ba9-4b65-8989-3ad0ea61782f	2026-07-20 11:46:45.199839+00	2026-07-20 11:46:45.199839+00
6fa5de46-9edd-404a-915e-89d9f3f21ae7	e4e5a794-7c17-4adf-838f-3aa4efb27e70	0bf949b7-932b-40ba-8d67-4ea888360556	پیاده‌سازی بخش اصلی	129	40	2026-07-12	approved	c2241423-6f70-4f15-92a9-c4a433dfec70	\N	1b6d2a15-ad66-4108-81db-fcb42d2ff712	2026-07-20 11:46:45.199839+00	2026-07-20 11:46:45.199839+00
6fa5de46-9edd-404a-915e-89d9f3f21ae7	e4e5a794-7c17-4adf-838f-3aa4efb27e70	0bf949b7-932b-40ba-8d67-4ea888360556	پیشرفت اولیه و بررسی نیازمندی‌ها	240	48	2026-07-13	approved	c2241423-6f70-4f15-92a9-c4a433dfec70	\N	b2b85eee-2234-451e-a4f9-c87f495fb2ec	2026-07-20 11:46:45.199839+00	2026-07-20 11:46:45.199839+00
6fa5de46-9edd-404a-915e-89d9f3f21ae7	e4e5a794-7c17-4adf-838f-3aa4efb27e70	0bf949b7-932b-40ba-8d67-4ea888360556	مستندسازی و نهایی‌سازی	141	66	2026-07-16	approved	c2241423-6f70-4f15-92a9-c4a433dfec70	\N	c2b26f2e-c383-4560-86a6-25696651e397	2026-07-20 11:46:45.199839+00	2026-07-20 11:46:45.199839+00
6fa5de46-9edd-404a-915e-89d9f3f21ae7	f32868a3-318d-4148-9e73-8337e1ed9847	cd92c461-1da5-4222-b6f0-60ce30f3d910	پیاده‌سازی بخش اصلی	124	22	2026-07-16	approved	c2241423-6f70-4f15-92a9-c4a433dfec70	\N	46104517-18ec-4a43-be36-7829535a4f7a	2026-07-20 11:46:45.199839+00	2026-07-20 11:46:45.199839+00
6fa5de46-9edd-404a-915e-89d9f3f21ae7	e06f6c4f-74a2-4bc6-9d32-bfae9dba96cc	16119c08-e43f-4846-adcd-f77ad1aca132	تست و اطمینان از عملکرد صحیح	187	40	2026-07-08	approved	c2241423-6f70-4f15-92a9-c4a433dfec70	\N	186dad03-00f3-4fbe-8699-4371db83055f	2026-07-20 11:46:45.199839+00	2026-07-20 11:46:45.199839+00
6fa5de46-9edd-404a-915e-89d9f3f21ae7	b5783de0-a460-4ae2-bc85-e09160703a7c	cf5d8b24-a057-421e-9cc3-b442f742293f	پیاده‌سازی بخش اصلی	193	35	2026-07-16	submitted	\N	\N	3b219fd7-d154-44fa-b676-1ab9edf8f220	2026-07-20 11:46:45.199839+00	2026-07-20 11:46:45.199839+00
6fa5de46-9edd-404a-915e-89d9f3f21ae7	b5783de0-a460-4ae2-bc85-e09160703a7c	cf5d8b24-a057-421e-9cc3-b442f742293f	مستندسازی و نهایی‌سازی	103	52	2026-07-16	approved	c2241423-6f70-4f15-92a9-c4a433dfec70	\N	fbf2999b-4647-4c3d-a172-8a61cc129c5b	2026-07-20 11:46:45.199839+00	2026-07-20 11:46:45.199839+00
6fa5de46-9edd-404a-915e-89d9f3f21ae7	b5783de0-a460-4ae2-bc85-e09160703a7c	cf5d8b24-a057-421e-9cc3-b442f742293f	مستندسازی و نهایی‌سازی	162	81	2026-07-16	submitted	\N	\N	ecc2e41f-8ad4-407d-8129-92667fd5b8be	2026-07-20 11:46:45.199839+00	2026-07-20 11:46:45.199839+00
6fa5de46-9edd-404a-915e-89d9f3f21ae7	4963422a-4961-4bf3-9f9a-9e92525a8173	07fc03fd-5b06-4623-adbc-9d3292322efa	رفع اشکالات و بازبینی	91	40	2026-07-16	approved	c2241423-6f70-4f15-92a9-c4a433dfec70	\N	3657df3b-823c-4669-ab30-f028e896a254	2026-07-20 11:46:45.199839+00	2026-07-20 11:46:45.199839+00
6fa5de46-9edd-404a-915e-89d9f3f21ae7	4963422a-4961-4bf3-9f9a-9e92525a8173	07fc03fd-5b06-4623-adbc-9d3292322efa	پیاده‌سازی بخش اصلی	52	56	2026-07-16	approved	c2241423-6f70-4f15-92a9-c4a433dfec70	\N	ee413d70-7de2-4572-b5e2-47ceef8d9e9e	2026-07-20 11:46:45.199839+00	2026-07-20 11:46:45.199839+00
6fa5de46-9edd-404a-915e-89d9f3f21ae7	9ea8e68b-bb76-478c-a344-033e8127ce4f	cf5d8b24-a057-421e-9cc3-b442f742293f	تست و اطمینان از عملکرد صحیح	180	26	2026-07-02	approved	c2241423-6f70-4f15-92a9-c4a433dfec70	\N	d8b8ef7d-1b54-45d3-ac27-29826197efb8	2026-07-20 11:46:45.199839+00	2026-07-20 11:46:45.199839+00
6fa5de46-9edd-404a-915e-89d9f3f21ae7	9ea8e68b-bb76-478c-a344-033e8127ce4f	cf5d8b24-a057-421e-9cc3-b442f742293f	پیشرفت اولیه و بررسی نیازمندی‌ها	53	74	2026-07-03	submitted	\N	\N	154ca96e-a209-467a-94f4-b739777e7142	2026-07-20 11:46:45.199839+00	2026-07-20 11:46:45.199839+00
6fa5de46-9edd-404a-915e-89d9f3f21ae7	9ea8e68b-bb76-478c-a344-033e8127ce4f	cf5d8b24-a057-421e-9cc3-b442f742293f	مستندسازی و نهایی‌سازی	179	93	2026-07-08	submitted	\N	\N	f062e7ce-dedb-4240-ade7-460e97b47532	2026-07-20 11:46:45.199839+00	2026-07-20 11:46:45.199839+00
6fa5de46-9edd-404a-915e-89d9f3f21ae7	9ea8e68b-bb76-478c-a344-033e8127ce4f	cf5d8b24-a057-421e-9cc3-b442f742293f	رفع اشکالات و بازبینی	87	100	2026-07-11	submitted	\N	\N	192da282-370d-4e30-bfb1-611100c799c2	2026-07-20 11:46:45.199839+00	2026-07-20 11:46:45.199839+00
6fa5de46-9edd-404a-915e-89d9f3f21ae7	ebf62f6e-42a8-4bf6-9649-ee92314b80aa	07fc03fd-5b06-4623-adbc-9d3292322efa	مستندسازی و نهایی‌سازی	31	28	2026-07-09	submitted	\N	\N	ed606520-1b1c-49a0-9705-6664d0247752	2026-07-20 11:46:45.199839+00	2026-07-20 11:46:45.199839+00
6fa5de46-9edd-404a-915e-89d9f3f21ae7	ebf62f6e-42a8-4bf6-9649-ee92314b80aa	07fc03fd-5b06-4623-adbc-9d3292322efa	پیشرفت اولیه و بررسی نیازمندی‌ها	173	44	2026-07-11	approved	c2241423-6f70-4f15-92a9-c4a433dfec70	\N	91a5a807-80a8-4f6b-ab11-43468508f367	2026-07-20 11:46:45.199839+00	2026-07-20 11:46:45.199839+00
6fa5de46-9edd-404a-915e-89d9f3f21ae7	e9734d4f-8c19-4bae-b0e3-9e0690f80de4	cf5d8b24-a057-421e-9cc3-b442f742293f	پیشرفت اولیه و بررسی نیازمندی‌ها	235	36	2026-07-16	approved	c2241423-6f70-4f15-92a9-c4a433dfec70	\N	36b65ad6-11d7-4a29-be3f-504506290fda	2026-07-20 11:46:45.199839+00	2026-07-20 11:46:45.199839+00
6fa5de46-9edd-404a-915e-89d9f3f21ae7	e9734d4f-8c19-4bae-b0e3-9e0690f80de4	cf5d8b24-a057-421e-9cc3-b442f742293f	مستندسازی و نهایی‌سازی	238	76	2026-07-16	approved	c2241423-6f70-4f15-92a9-c4a433dfec70	\N	8002aa1a-a504-43d3-b18a-8a98e2062850	2026-07-20 11:46:45.199839+00	2026-07-20 11:46:45.199839+00
6fa5de46-9edd-404a-915e-89d9f3f21ae7	e9734d4f-8c19-4bae-b0e3-9e0690f80de4	cf5d8b24-a057-421e-9cc3-b442f742293f	تست و اطمینان از عملکرد صحیح	126	100	2026-07-16	approved	c2241423-6f70-4f15-92a9-c4a433dfec70	\N	c43c4efc-4b15-41f4-95c2-016b2ee7d6f7	2026-07-20 11:46:45.199839+00	2026-07-20 11:46:45.199839+00
6fa5de46-9edd-404a-915e-89d9f3f21ae7	c5eaa1cf-61b5-439f-929f-f27d880b922a	cf5d8b24-a057-421e-9cc3-b442f742293f	تست و اطمینان از عملکرد صحیح	204	34	2026-07-15	submitted	\N	\N	98c17dc4-661f-4065-beea-f2aa4141f5e9	2026-07-20 11:46:45.199839+00	2026-07-20 11:46:45.199839+00
6fa5de46-9edd-404a-915e-89d9f3f21ae7	c5eaa1cf-61b5-439f-929f-f27d880b922a	cf5d8b24-a057-421e-9cc3-b442f742293f	رفع اشکالات و بازبینی	47	64	2026-07-16	approved	c2241423-6f70-4f15-92a9-c4a433dfec70	\N	d69a9a10-f268-417a-bbaf-88f8b0a69f31	2026-07-20 11:46:45.199839+00	2026-07-20 11:46:45.199839+00
6fa5de46-9edd-404a-915e-89d9f3f21ae7	c5eaa1cf-61b5-439f-929f-f27d880b922a	cf5d8b24-a057-421e-9cc3-b442f742293f	پیاده‌سازی بخش اصلی	234	90	2026-07-16	approved	c2241423-6f70-4f15-92a9-c4a433dfec70	\N	213a7d20-f1c3-4303-9138-51a41bdd2f3f	2026-07-20 11:46:45.199839+00	2026-07-20 11:46:45.199839+00
6fa5de46-9edd-404a-915e-89d9f3f21ae7	c5eaa1cf-61b5-439f-929f-f27d880b922a	cf5d8b24-a057-421e-9cc3-b442f742293f	مستندسازی و نهایی‌سازی	167	80	2026-07-16	submitted	\N	\N	21e0b186-7976-4e78-a692-b23ae9519803	2026-07-20 11:46:45.199839+00	2026-07-20 11:46:45.199839+00
6fa5de46-9edd-404a-915e-89d9f3f21ae7	5c8b8e01-4630-4dd2-852c-de717b3c97b8	0bf949b7-932b-40ba-8d67-4ea888360556	رفع اشکالات و بازبینی	53	32	2026-07-10	approved	c2241423-6f70-4f15-92a9-c4a433dfec70	\N	310b56db-f45f-49e2-afff-33a838ba5097	2026-07-20 11:46:45.199839+00	2026-07-20 11:46:45.199839+00
6fa5de46-9edd-404a-915e-89d9f3f21ae7	5c8b8e01-4630-4dd2-852c-de717b3c97b8	0bf949b7-932b-40ba-8d67-4ea888360556	پیشرفت اولیه و بررسی نیازمندی‌ها	171	50	2026-07-13	approved	c2241423-6f70-4f15-92a9-c4a433dfec70	\N	f7372aee-44fc-471e-98e1-da21a96bbc2a	2026-07-20 11:46:45.199839+00	2026-07-20 11:46:45.199839+00
6fa5de46-9edd-404a-915e-89d9f3f21ae7	5c8b8e01-4630-4dd2-852c-de717b3c97b8	0bf949b7-932b-40ba-8d67-4ea888360556	رفع اشکالات و بازبینی	120	78	2026-07-16	approved	c2241423-6f70-4f15-92a9-c4a433dfec70	\N	c353ccc4-ae20-41cb-bce7-b46b87704654	2026-07-20 11:46:45.199839+00	2026-07-20 11:46:45.199839+00
6fa5de46-9edd-404a-915e-89d9f3f21ae7	72e247e3-8d8c-4b08-8dc4-0f11a0178b24	07fc03fd-5b06-4623-adbc-9d3292322efa	پیاده‌سازی بخش اصلی	157	26	2026-07-16	approved	c2241423-6f70-4f15-92a9-c4a433dfec70	\N	1afcfe15-2264-4479-92ef-9ce08e70126d	2026-07-20 11:46:45.199839+00	2026-07-20 11:46:45.199839+00
6fa5de46-9edd-404a-915e-89d9f3f21ae7	72e247e3-8d8c-4b08-8dc4-0f11a0178b24	07fc03fd-5b06-4623-adbc-9d3292322efa	پیاده‌سازی بخش اصلی	97	52	2026-07-16	approved	c2241423-6f70-4f15-92a9-c4a433dfec70	\N	00cce5d3-8434-4862-bf37-f468b1c07766	2026-07-20 11:46:45.199839+00	2026-07-20 11:46:45.199839+00
6fa5de46-9edd-404a-915e-89d9f3f21ae7	72e247e3-8d8c-4b08-8dc4-0f11a0178b24	07fc03fd-5b06-4623-adbc-9d3292322efa	پیاده‌سازی بخش اصلی	93	100	2026-07-16	approved	c2241423-6f70-4f15-92a9-c4a433dfec70	\N	e501a322-1875-4615-ba3e-76204731d792	2026-07-20 11:46:45.199839+00	2026-07-20 11:46:45.199839+00
6fa5de46-9edd-404a-915e-89d9f3f21ae7	67e2307f-723c-4d2c-8e8d-d8be12b379a5	0bf949b7-932b-40ba-8d67-4ea888360556	پیشرفت اولیه و بررسی نیازمندی‌ها	60	22	2026-07-16	approved	c2241423-6f70-4f15-92a9-c4a433dfec70	\N	a02dfc60-f1ef-43f3-91c3-7f5077866173	2026-07-20 11:46:45.199839+00	2026-07-20 11:46:45.199839+00
6fa5de46-9edd-404a-915e-89d9f3f21ae7	67e2307f-723c-4d2c-8e8d-d8be12b379a5	0bf949b7-932b-40ba-8d67-4ea888360556	مستندسازی و نهایی‌سازی	31	74	2026-07-16	approved	c2241423-6f70-4f15-92a9-c4a433dfec70	\N	1d15a30d-8ec2-41c2-9dc8-3c1aa17ddc69	2026-07-20 11:46:45.199839+00	2026-07-20 11:46:45.199839+00
6fa5de46-9edd-404a-915e-89d9f3f21ae7	67e2307f-723c-4d2c-8e8d-d8be12b379a5	0bf949b7-932b-40ba-8d67-4ea888360556	تست و اطمینان از عملکرد صحیح	125	100	2026-07-16	approved	c2241423-6f70-4f15-92a9-c4a433dfec70	\N	655f7da4-7aed-4aa4-bec6-2987668a2668	2026-07-20 11:46:45.199839+00	2026-07-20 11:46:45.199839+00
6fa5de46-9edd-404a-915e-89d9f3f21ae7	2fe373b3-4214-4cd1-9522-337ef41ecf63	cd92c461-1da5-4222-b6f0-60ce30f3d910	مستندسازی و نهایی‌سازی	100	35	2026-07-16	approved	c2241423-6f70-4f15-92a9-c4a433dfec70	\N	354273bb-0f31-494f-97e5-07dce31e72c0	2026-07-20 11:46:45.199839+00	2026-07-20 11:46:45.199839+00
6fa5de46-9edd-404a-915e-89d9f3f21ae7	2fe373b3-4214-4cd1-9522-337ef41ecf63	cd92c461-1da5-4222-b6f0-60ce30f3d910	مستندسازی و نهایی‌سازی	101	64	2026-07-16	approved	c2241423-6f70-4f15-92a9-c4a433dfec70	\N	0acde0aa-a5fe-4a62-b61a-e1d3d34ed2f9	2026-07-20 11:46:45.199839+00	2026-07-20 11:46:45.199839+00
6fa5de46-9edd-404a-915e-89d9f3f21ae7	2fe373b3-4214-4cd1-9522-337ef41ecf63	cd92c461-1da5-4222-b6f0-60ce30f3d910	مستندسازی و نهایی‌سازی	62	63	2026-07-16	approved	c2241423-6f70-4f15-92a9-c4a433dfec70	\N	d7fc91df-9f2a-4455-8631-8fa79f2da3e4	2026-07-20 11:46:45.199839+00	2026-07-20 11:46:45.199839+00
6fa5de46-9edd-404a-915e-89d9f3f21ae7	07ee2585-20d1-4625-afde-bfe2a96892a9	cf5d8b24-a057-421e-9cc3-b442f742293f	پیشرفت اولیه و بررسی نیازمندی‌ها	158	31	2026-07-16	submitted	\N	\N	dc59038d-83de-462f-b81d-e495c182a58d	2026-07-20 11:46:45.199839+00	2026-07-20 11:46:45.199839+00
6fa5de46-9edd-404a-915e-89d9f3f21ae7	07ee2585-20d1-4625-afde-bfe2a96892a9	cf5d8b24-a057-421e-9cc3-b442f742293f	پیاده‌سازی بخش اصلی	147	46	2026-07-16	submitted	\N	\N	0a32a118-0370-497a-89bb-60f52be0586f	2026-07-20 11:46:45.199839+00	2026-07-20 11:46:45.199839+00
6fa5de46-9edd-404a-915e-89d9f3f21ae7	07ee2585-20d1-4625-afde-bfe2a96892a9	cf5d8b24-a057-421e-9cc3-b442f742293f	پیشرفت اولیه و بررسی نیازمندی‌ها	33	78	2026-07-16	approved	c2241423-6f70-4f15-92a9-c4a433dfec70	\N	88876c36-7c51-430c-9c5b-c2ca586db12e	2026-07-20 11:46:45.199839+00	2026-07-20 11:46:45.199839+00
6fa5de46-9edd-404a-915e-89d9f3f21ae7	07ee2585-20d1-4625-afde-bfe2a96892a9	cf5d8b24-a057-421e-9cc3-b442f742293f	رفع اشکالات و بازبینی	122	100	2026-07-16	approved	c2241423-6f70-4f15-92a9-c4a433dfec70	\N	68660745-0e4e-410e-bcf2-cc2c2490519b	2026-07-20 11:46:45.199839+00	2026-07-20 11:46:45.199839+00
6fa5de46-9edd-404a-915e-89d9f3f21ae7	487a4d5e-719f-4e10-9f6b-2282885d3b95	cf5d8b24-a057-421e-9cc3-b442f742293f	پیاده‌سازی بخش اصلی	98	35	2026-07-01	approved	c2241423-6f70-4f15-92a9-c4a433dfec70	\N	c451ed48-e75d-44d1-82ee-ae46948e23cc	2026-07-20 11:46:45.199839+00	2026-07-20 11:46:45.199839+00
6fa5de46-9edd-404a-915e-89d9f3f21ae7	487a4d5e-719f-4e10-9f6b-2282885d3b95	cf5d8b24-a057-421e-9cc3-b442f742293f	تست و اطمینان از عملکرد صحیح	138	52	2026-07-04	approved	c2241423-6f70-4f15-92a9-c4a433dfec70	\N	656ffb36-146f-41c4-9c5b-ed35e0cad438	2026-07-20 11:46:45.199839+00	2026-07-20 11:46:45.199839+00
6fa5de46-9edd-404a-915e-89d9f3f21ae7	487a4d5e-719f-4e10-9f6b-2282885d3b95	cf5d8b24-a057-421e-9cc3-b442f742293f	رفع اشکالات و بازبینی	123	96	2026-07-09	submitted	\N	\N	b8e9816c-7c4b-4d87-9265-34b4b41f891a	2026-07-20 11:46:45.199839+00	2026-07-20 11:46:45.199839+00
6fa5de46-9edd-404a-915e-89d9f3f21ae7	7aca59ad-56e2-4658-bfd6-85937054408d	0bf949b7-932b-40ba-8d67-4ea888360556	پیاده‌سازی بخش اصلی	177	27	2026-07-11	approved	c2241423-6f70-4f15-92a9-c4a433dfec70	\N	9b778628-2afc-405b-a34e-66cfed16e446	2026-07-20 11:46:45.199839+00	2026-07-20 11:46:45.199839+00
6fa5de46-9edd-404a-915e-89d9f3f21ae7	7aca59ad-56e2-4658-bfd6-85937054408d	0bf949b7-932b-40ba-8d67-4ea888360556	پیاده‌سازی بخش اصلی	172	66	2026-07-12	submitted	\N	\N	4e2a0e1a-cab3-4c00-95ff-69d644b8c31e	2026-07-20 11:46:45.199839+00	2026-07-20 11:46:45.199839+00
6fa5de46-9edd-404a-915e-89d9f3f21ae7	7aca59ad-56e2-4658-bfd6-85937054408d	0bf949b7-932b-40ba-8d67-4ea888360556	پیاده‌سازی بخش اصلی	151	60	2026-07-16	approved	c2241423-6f70-4f15-92a9-c4a433dfec70	\N	bc1a2033-5aee-410e-9ef0-ed2f5125dc73	2026-07-20 11:46:45.199839+00	2026-07-20 11:46:45.199839+00
6fa5de46-9edd-404a-915e-89d9f3f21ae7	ba4025c1-08a4-4489-9ee3-ee4159eb3882	0bf949b7-932b-40ba-8d67-4ea888360556	تست و اطمینان از عملکرد صحیح	64	40	2026-07-11	approved	c2241423-6f70-4f15-92a9-c4a433dfec70	\N	93f4d3ce-c5a7-4e11-bb77-99deb261bbcc	2026-07-20 11:46:45.199839+00	2026-07-20 11:46:45.199839+00
6fa5de46-9edd-404a-915e-89d9f3f21ae7	ba4025c1-08a4-4489-9ee3-ee4159eb3882	0bf949b7-932b-40ba-8d67-4ea888360556	تست و اطمینان از عملکرد صحیح	106	56	2026-07-14	approved	c2241423-6f70-4f15-92a9-c4a433dfec70	\N	c55bd05e-9502-4356-93e7-e13e8a189128	2026-07-20 11:46:45.199839+00	2026-07-20 11:46:45.199839+00
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


