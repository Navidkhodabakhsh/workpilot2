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
2026-07-20 09:22:24.106985+00	1d224113-52fd-42ec-a3d9-ee5e9338d4af	35524a39-bb53-4f81-b913-a64fc2c0bc5e	user.login	user	35524a39-bb53-4f81-b913-a64fc2c0bc5e	{}	1d66b5db-7b56-48c4-8579-7c60c07b2868
2026-07-20 09:22:34.311583+00	1d224113-52fd-42ec-a3d9-ee5e9338d4af	35524a39-bb53-4f81-b913-a64fc2c0bc5e	user.login	user	35524a39-bb53-4f81-b913-a64fc2c0bc5e	{}	3f6b17a4-1c67-4d5d-b1a6-ff90c4b8a70c
2026-07-20 09:22:43.937198+00	1d224113-52fd-42ec-a3d9-ee5e9338d4af	35524a39-bb53-4f81-b913-a64fc2c0bc5e	user.login	user	35524a39-bb53-4f81-b913-a64fc2c0bc5e	{}	ad3f6211-b0a8-4628-9124-56db247d07e5
2026-07-20 09:22:56.838238+00	1d224113-52fd-42ec-a3d9-ee5e9338d4af	1bd96f4a-6acb-4464-8452-ca1d3114a328	user.login	user	1bd96f4a-6acb-4464-8452-ca1d3114a328	{}	64d32a4a-1cd7-4411-8163-fd37975c9dcd
2026-07-20 09:23:07.484184+00	1d224113-52fd-42ec-a3d9-ee5e9338d4af	b3e7b1f6-d818-46bc-a98e-9f7048e16f8f	user.login	user	b3e7b1f6-d818-46bc-a98e-9f7048e16f8f	{}	f3fd2478-fba1-4f48-a2ca-504c9f088c1f
2026-07-20 09:23:07.778503+00	1d224113-52fd-42ec-a3d9-ee5e9338d4af	b3e7b1f6-d818-46bc-a98e-9f7048e16f8f	worklog.approve	worklog	7234ce3f-9db8-4122-8430-06e9fcf2a7db	{}	afe2135e-8fed-4787-85bb-02008f660890
2026-07-20 09:23:07.811452+00	1d224113-52fd-42ec-a3d9-ee5e9338d4af	1bd96f4a-6acb-4464-8452-ca1d3114a328	user.login	user	1bd96f4a-6acb-4464-8452-ca1d3114a328	{}	20057167-57f0-48db-9d18-2a452dc82f71
\.


--
-- Data for Name: calendar_events; Type: TABLE DATA; Schema: public; Owner: -
--

COPY public.calendar_events (id, created_at, updated_at, organization_id, created_by_id, project_id, user_id, title, description, event_type, start_at, end_at, all_day) FROM stdin;
6ff7b0d7-39e3-405a-b13e-c35a8670efbf	2026-07-20 09:22:03.794401+00	2026-07-20 09:22:03.794401+00	1d224113-52fd-42ec-a3d9-ee5e9338d4af	127c1187-f85a-48c8-82b5-451a4ccfeb71	eada99a6-4c95-418c-8fa0-baf7c82570b1	\N	جلسهٔ مرور با مدیریت	\N	meeting	2026-06-19 10:00:00+00	2026-06-19 11:00:00+00	f
5946828c-e286-4b9b-b575-7eb0783ef998	2026-07-20 09:22:03.794401+00	2026-07-20 09:22:03.794401+00	1d224113-52fd-42ec-a3d9-ee5e9338d4af	0132fd66-319f-4f6e-8e2f-d16328d278e8	91889926-2b3f-4643-8d23-0cd8a3d96488	\N	یادآوری پیگیری مشتری	\N	reminder	2026-06-16 00:00:00+00	2026-06-16 01:00:00+00	t
f313ea87-6ce3-4d41-90d0-ab526b7a91d7	2026-07-20 09:22:03.794401+00	2026-07-20 09:22:03.794401+00	1d224113-52fd-42ec-a3d9-ee5e9338d4af	35524a39-bb53-4f81-b913-a64fc2c0bc5e	\N	\N	تعطیلی رسمی	\N	holiday	2026-06-18 00:00:00+00	2026-06-18 01:00:00+00	t
67eb01f5-de58-4c33-b9ad-cf46fa77dbd5	2026-07-20 09:22:03.794401+00	2026-07-20 09:22:03.794401+00	1d224113-52fd-42ec-a3d9-ee5e9338d4af	127c1187-f85a-48c8-82b5-451a4ccfeb71	d86107c2-52f7-48ef-847b-f82fecf566dd	\N	جلسهٔ بررسی پیشرفت پروژه	\N	meeting	2026-06-27 10:00:00+00	2026-06-27 11:00:00+00	f
9bb305b7-1fdb-4bba-9769-4a38a1a9eb39	2026-07-20 09:22:03.794401+00	2026-07-20 09:22:03.794401+00	1d224113-52fd-42ec-a3d9-ee5e9338d4af	a2c3e527-82e9-4bd2-be63-85f6ead97337	61c13830-e388-41dc-bb0e-d6b8f1f0d634	\N	یادآوری تمدید قرارداد	\N	reminder	2026-06-28 00:00:00+00	2026-06-28 01:00:00+00	t
d75b2741-1173-4e3e-847c-f82a64358c4d	2026-07-20 09:22:03.794401+00	2026-07-20 09:22:03.794401+00	1d224113-52fd-42ec-a3d9-ee5e9338d4af	127c1187-f85a-48c8-82b5-451a4ccfeb71	7e20e869-c4d2-4866-a078-03145a732db4	\N	جلسهٔ برنامه‌ریزی اسپرینت	\N	meeting	2026-07-04 10:00:00+00	2026-07-04 11:00:00+00	f
b81d3c27-724f-4781-ab6c-6fe35fcbe8ef	2026-07-20 09:22:03.794401+00	2026-07-20 09:22:03.794401+00	1d224113-52fd-42ec-a3d9-ee5e9338d4af	3940e09c-eede-4772-818b-3a4bc4703195	91889926-2b3f-4643-8d23-0cd8a3d96488	\N	یادآوری ارسال گزارش	\N	reminder	2026-07-01 00:00:00+00	2026-07-01 01:00:00+00	t
4b17e789-58cf-432f-9468-8cbf16ccfdc4	2026-07-20 09:22:03.794401+00	2026-07-20 09:22:03.794401+00	1d224113-52fd-42ec-a3d9-ee5e9338d4af	127c1187-f85a-48c8-82b5-451a4ccfeb71	7e20e869-c4d2-4866-a078-03145a732db4	\N	جلسهٔ برنامه‌ریزی اسپرینت	\N	meeting	2026-07-11 10:00:00+00	2026-07-11 11:00:00+00	f
8721000b-e15b-4cf5-9515-188dcd2d4ec5	2026-07-20 09:22:03.794401+00	2026-07-20 09:22:03.794401+00	1d224113-52fd-42ec-a3d9-ee5e9338d4af	3940e09c-eede-4772-818b-3a4bc4703195	d86107c2-52f7-48ef-847b-f82fecf566dd	\N	یادآوری پیگیری مشتری	\N	reminder	2026-07-07 00:00:00+00	2026-07-07 01:00:00+00	t
ea57da3c-4d64-463a-a9f9-3ff1e5b4a8a2	2026-07-20 09:22:03.794401+00	2026-07-20 09:22:03.794401+00	1d224113-52fd-42ec-a3d9-ee5e9338d4af	127c1187-f85a-48c8-82b5-451a4ccfeb71	d86107c2-52f7-48ef-847b-f82fecf566dd	\N	جلسهٔ هماهنگی هفتگی	\N	meeting	2026-07-18 10:00:00+00	2026-07-18 11:00:00+00	f
03e35dc3-6f4f-4ac6-8308-4cb300d3e7d7	2026-07-20 09:22:03.794401+00	2026-07-20 09:22:03.794401+00	1d224113-52fd-42ec-a3d9-ee5e9338d4af	054f46d3-1cc2-42df-9532-2b310816822b	7e20e869-c4d2-4866-a078-03145a732db4	\N	یادآوری پیگیری مشتری	\N	reminder	2026-07-17 00:00:00+00	2026-07-17 01:00:00+00	t
a79a5402-239f-47e7-950d-c55cb03d94d9	2026-07-20 09:22:03.794401+00	2026-07-20 09:22:03.794401+00	1d224113-52fd-42ec-a3d9-ee5e9338d4af	35524a39-bb53-4f81-b913-a64fc2c0bc5e	\N	\N	تعطیلی رسمی	\N	holiday	2026-07-16 00:00:00+00	2026-07-16 01:00:00+00	t
1ae01eec-2e39-48ef-aa32-b8f9751ea265	2026-07-20 09:22:03.794401+00	2026-07-20 09:22:03.794401+00	1d224113-52fd-42ec-a3d9-ee5e9338d4af	127c1187-f85a-48c8-82b5-451a4ccfeb71	61c13830-e388-41dc-bb0e-d6b8f1f0d634	\N	جلسهٔ هماهنگی هفتگی	\N	meeting	2026-07-23 10:00:00+00	2026-07-23 11:00:00+00	f
7579b29d-10eb-41eb-8a28-61e3fabdd9cc	2026-07-20 09:22:03.794401+00	2026-07-20 09:22:03.794401+00	1d224113-52fd-42ec-a3d9-ee5e9338d4af	0132fd66-319f-4f6e-8e2f-d16328d278e8	61c13830-e388-41dc-bb0e-d6b8f1f0d634	\N	یادآوری ارسال گزارش	\N	reminder	2026-07-23 00:00:00+00	2026-07-23 01:00:00+00	t
c60e34c9-eb6c-47fc-bb48-eb3c27e98433	2026-07-20 09:22:03.794401+00	2026-07-20 09:22:03.794401+00	1d224113-52fd-42ec-a3d9-ee5e9338d4af	127c1187-f85a-48c8-82b5-451a4ccfeb71	7e20e869-c4d2-4866-a078-03145a732db4	\N	جلسهٔ برنامه‌ریزی اسپرینت	\N	meeting	2026-08-01 10:00:00+00	2026-08-01 11:00:00+00	f
183ffa16-5db5-4e50-a770-eb63d6dfcb70	2026-07-20 09:22:03.794401+00	2026-07-20 09:22:03.794401+00	1d224113-52fd-42ec-a3d9-ee5e9338d4af	0132fd66-319f-4f6e-8e2f-d16328d278e8	61c13830-e388-41dc-bb0e-d6b8f1f0d634	\N	یادآوری پیگیری مشتری	\N	reminder	2026-07-29 00:00:00+00	2026-07-29 01:00:00+00	t
0f6c9c61-bcd6-46a9-be5a-49f4492ec7ef	2026-07-20 09:22:03.794401+00	2026-07-20 09:22:03.794401+00	1d224113-52fd-42ec-a3d9-ee5e9338d4af	127c1187-f85a-48c8-82b5-451a4ccfeb71	61c13830-e388-41dc-bb0e-d6b8f1f0d634	\N	جلسهٔ مرور با مدیریت	\N	meeting	2026-08-05 10:00:00+00	2026-08-05 11:00:00+00	f
6555b2cd-27a4-40dd-a436-b99931b5b9b0	2026-07-20 09:22:03.794401+00	2026-07-20 09:22:03.794401+00	1d224113-52fd-42ec-a3d9-ee5e9338d4af	054f46d3-1cc2-42df-9532-2b310816822b	eada99a6-4c95-418c-8fa0-baf7c82570b1	\N	یادآوری ارسال گزارش	\N	reminder	2026-08-09 00:00:00+00	2026-08-09 01:00:00+00	t
92169ec4-b325-4cec-8cd8-05383357d6f0	2026-07-20 09:22:03.794401+00	2026-07-20 09:22:03.794401+00	1d224113-52fd-42ec-a3d9-ee5e9338d4af	127c1187-f85a-48c8-82b5-451a4ccfeb71	7e20e869-c4d2-4866-a078-03145a732db4	\N	جلسهٔ هماهنگی هفتگی	\N	meeting	2026-08-14 10:00:00+00	2026-08-14 11:00:00+00	f
e2e4e424-e688-4517-9fc9-9ed3b4ab619c	2026-07-20 09:22:03.794401+00	2026-07-20 09:22:03.794401+00	1d224113-52fd-42ec-a3d9-ee5e9338d4af	a2c3e527-82e9-4bd2-be63-85f6ead97337	7e20e869-c4d2-4866-a078-03145a732db4	\N	یادآوری ارسال گزارش	\N	reminder	2026-08-13 00:00:00+00	2026-08-13 01:00:00+00	t
ce06653f-d322-4fa3-9bf1-482c42d36aba	2026-07-20 09:22:03.794401+00	2026-07-20 09:22:03.794401+00	1d224113-52fd-42ec-a3d9-ee5e9338d4af	35524a39-bb53-4f81-b913-a64fc2c0bc5e	\N	\N	تعطیلی رسمی	\N	holiday	2026-08-13 00:00:00+00	2026-08-13 01:00:00+00	t
3fb2b6e1-040e-4880-bea3-22633a6eb09f	2026-07-20 09:22:03.794401+00	2026-07-20 09:22:03.794401+00	1d224113-52fd-42ec-a3d9-ee5e9338d4af	b3e7b1f6-d818-46bc-a98e-9f7048e16f8f	bd97c764-a55c-4687-96d6-225085ccda6f	\N	جلسهٔ هماهنگی هفتگی	\N	meeting	2026-06-16 10:00:00+00	2026-06-16 11:00:00+00	f
8b29f6ff-9b11-4b41-8620-fdc490ac4dea	2026-07-20 09:22:03.794401+00	2026-07-20 09:22:03.794401+00	1d224113-52fd-42ec-a3d9-ee5e9338d4af	8cca3fcf-f7a7-421a-b9a4-5dab90fe1b83	24aaff84-b716-40f0-bc01-1438192b4c8c	\N	یادآوری ارسال گزارش	\N	reminder	2026-06-16 00:00:00+00	2026-06-16 01:00:00+00	t
0f0e2b57-7159-4d74-9731-ef3b43438613	2026-07-20 09:22:03.794401+00	2026-07-20 09:22:03.794401+00	1d224113-52fd-42ec-a3d9-ee5e9338d4af	35524a39-bb53-4f81-b913-a64fc2c0bc5e	\N	\N	تعطیلی رسمی	\N	holiday	2026-06-18 00:00:00+00	2026-06-18 01:00:00+00	t
5cff90fa-c83e-43da-b5e9-e2555ddf457e	2026-07-20 09:22:03.794401+00	2026-07-20 09:22:03.794401+00	1d224113-52fd-42ec-a3d9-ee5e9338d4af	b3e7b1f6-d818-46bc-a98e-9f7048e16f8f	bd97c764-a55c-4687-96d6-225085ccda6f	\N	جلسهٔ هماهنگی هفتگی	\N	meeting	2026-06-23 10:00:00+00	2026-06-23 11:00:00+00	f
adafcc39-de61-4cdb-8c41-0bf0686c85f0	2026-07-20 09:22:03.794401+00	2026-07-20 09:22:03.794401+00	1d224113-52fd-42ec-a3d9-ee5e9338d4af	1bd96f4a-6acb-4464-8452-ca1d3114a328	8d09c967-bbac-40b4-b041-c8ea0286cd15	\N	یادآوری پیگیری مشتری	\N	reminder	2026-06-26 00:00:00+00	2026-06-26 01:00:00+00	t
8529fd21-7a70-4434-92f6-c8924b20e822	2026-07-20 09:22:03.794401+00	2026-07-20 09:22:03.794401+00	1d224113-52fd-42ec-a3d9-ee5e9338d4af	b3e7b1f6-d818-46bc-a98e-9f7048e16f8f	24aaff84-b716-40f0-bc01-1438192b4c8c	\N	جلسهٔ مرور با مدیریت	\N	meeting	2026-07-03 10:00:00+00	2026-07-03 11:00:00+00	f
19a538c0-6514-42ee-88db-eb4938beb638	2026-07-20 09:22:03.794401+00	2026-07-20 09:22:03.794401+00	1d224113-52fd-42ec-a3d9-ee5e9338d4af	b720465e-b31b-4b9b-99d6-b303ca5f639d	24aaff84-b716-40f0-bc01-1438192b4c8c	\N	یادآوری ارسال گزارش	\N	reminder	2026-06-30 00:00:00+00	2026-06-30 01:00:00+00	t
bf8202e4-8d7a-4003-a063-797ce1f6af26	2026-07-20 09:22:03.794401+00	2026-07-20 09:22:03.794401+00	1d224113-52fd-42ec-a3d9-ee5e9338d4af	b3e7b1f6-d818-46bc-a98e-9f7048e16f8f	bd97c764-a55c-4687-96d6-225085ccda6f	\N	جلسهٔ بررسی پیشرفت پروژه	\N	meeting	2026-07-08 10:00:00+00	2026-07-08 11:00:00+00	f
04f6b88d-b97f-42f5-9d40-3408031495cc	2026-07-20 09:22:03.794401+00	2026-07-20 09:22:03.794401+00	1d224113-52fd-42ec-a3d9-ee5e9338d4af	1fd4dffb-d8db-4387-914a-be2a2a6fd6b1	24aaff84-b716-40f0-bc01-1438192b4c8c	\N	یادآوری ارسال گزارش	\N	reminder	2026-07-09 00:00:00+00	2026-07-09 01:00:00+00	t
6ad14d68-acfa-427e-aedc-27f3607c6f66	2026-07-20 09:22:03.794401+00	2026-07-20 09:22:03.794401+00	1d224113-52fd-42ec-a3d9-ee5e9338d4af	b3e7b1f6-d818-46bc-a98e-9f7048e16f8f	58a3e39a-4d3f-4eeb-bf3e-fbf3ae866a53	\N	جلسهٔ بررسی پیشرفت پروژه	\N	meeting	2026-07-18 10:00:00+00	2026-07-18 11:00:00+00	f
b07b88bf-289d-4d57-9c59-4b5e31a41cce	2026-07-20 09:22:03.794401+00	2026-07-20 09:22:03.794401+00	1d224113-52fd-42ec-a3d9-ee5e9338d4af	1fd4dffb-d8db-4387-914a-be2a2a6fd6b1	24aaff84-b716-40f0-bc01-1438192b4c8c	\N	یادآوری تمدید قرارداد	\N	reminder	2026-07-19 00:00:00+00	2026-07-19 01:00:00+00	t
417b8f20-5287-4030-af49-0a5a4d891476	2026-07-20 09:22:03.794401+00	2026-07-20 09:22:03.794401+00	1d224113-52fd-42ec-a3d9-ee5e9338d4af	35524a39-bb53-4f81-b913-a64fc2c0bc5e	\N	\N	تعطیلی رسمی	\N	holiday	2026-07-16 00:00:00+00	2026-07-16 01:00:00+00	t
6fb993ac-1804-4cc9-ac8c-8d367035660b	2026-07-20 09:22:03.794401+00	2026-07-20 09:22:03.794401+00	1d224113-52fd-42ec-a3d9-ee5e9338d4af	b3e7b1f6-d818-46bc-a98e-9f7048e16f8f	58a3e39a-4d3f-4eeb-bf3e-fbf3ae866a53	\N	جلسهٔ برنامه‌ریزی اسپرینت	\N	meeting	2026-07-21 10:00:00+00	2026-07-21 11:00:00+00	f
baaf74a0-2067-4de0-9dee-c0579497e00f	2026-07-20 09:22:03.794401+00	2026-07-20 09:22:03.794401+00	1d224113-52fd-42ec-a3d9-ee5e9338d4af	8cca3fcf-f7a7-421a-b9a4-5dab90fe1b83	24aaff84-b716-40f0-bc01-1438192b4c8c	\N	یادآوری ارسال گزارش	\N	reminder	2026-07-24 00:00:00+00	2026-07-24 01:00:00+00	t
a758fde4-709d-495a-b901-f646a866a198	2026-07-20 09:22:03.794401+00	2026-07-20 09:22:03.794401+00	1d224113-52fd-42ec-a3d9-ee5e9338d4af	b3e7b1f6-d818-46bc-a98e-9f7048e16f8f	31f35274-08e2-4c6a-8607-ad731054db18	\N	جلسهٔ هماهنگی هفتگی	\N	meeting	2026-07-29 10:00:00+00	2026-07-29 11:00:00+00	f
dda098fa-ec23-4a8f-9ab3-0846e83979e6	2026-07-20 09:22:03.794401+00	2026-07-20 09:22:03.794401+00	1d224113-52fd-42ec-a3d9-ee5e9338d4af	03c131a9-29b0-4e66-8d67-be78cfa01885	bd97c764-a55c-4687-96d6-225085ccda6f	\N	یادآوری تمدید قرارداد	\N	reminder	2026-07-31 00:00:00+00	2026-07-31 01:00:00+00	t
10030915-6ae6-4982-9bdf-aad40e90e9fc	2026-07-20 09:22:03.794401+00	2026-07-20 09:22:03.794401+00	1d224113-52fd-42ec-a3d9-ee5e9338d4af	b3e7b1f6-d818-46bc-a98e-9f7048e16f8f	31f35274-08e2-4c6a-8607-ad731054db18	\N	جلسهٔ برنامه‌ریزی اسپرینت	\N	meeting	2026-08-07 10:00:00+00	2026-08-07 11:00:00+00	f
9803cdea-1842-42d2-bbe4-f3ef8b479a20	2026-07-20 09:22:03.794401+00	2026-07-20 09:22:03.794401+00	1d224113-52fd-42ec-a3d9-ee5e9338d4af	8a6bd071-9f82-4273-b101-9c763d6c4be4	bd97c764-a55c-4687-96d6-225085ccda6f	\N	یادآوری تمدید قرارداد	\N	reminder	2026-08-08 00:00:00+00	2026-08-08 01:00:00+00	t
f0fb663a-cf36-4c9e-a2b0-121a9a7f0485	2026-07-20 09:22:03.794401+00	2026-07-20 09:22:03.794401+00	1d224113-52fd-42ec-a3d9-ee5e9338d4af	b3e7b1f6-d818-46bc-a98e-9f7048e16f8f	bd97c764-a55c-4687-96d6-225085ccda6f	\N	جلسهٔ هماهنگی هفتگی	\N	meeting	2026-08-12 10:00:00+00	2026-08-12 11:00:00+00	f
99c7ec7b-b63c-4425-acd9-586f84708386	2026-07-20 09:22:03.794401+00	2026-07-20 09:22:03.794401+00	1d224113-52fd-42ec-a3d9-ee5e9338d4af	8a6bd071-9f82-4273-b101-9c763d6c4be4	8d09c967-bbac-40b4-b041-c8ea0286cd15	\N	یادآوری ارسال گزارش	\N	reminder	2026-08-13 00:00:00+00	2026-08-13 01:00:00+00	t
86b0f465-2af1-4dc1-a6de-cfea31cf6740	2026-07-20 09:22:03.794401+00	2026-07-20 09:22:03.794401+00	1d224113-52fd-42ec-a3d9-ee5e9338d4af	35524a39-bb53-4f81-b913-a64fc2c0bc5e	\N	\N	تعطیلی رسمی	\N	holiday	2026-08-13 00:00:00+00	2026-08-13 01:00:00+00	t
dd652e2a-1a50-4c28-bfa7-365fc230be7b	2026-07-20 09:22:03.794401+00	2026-07-20 09:22:03.794401+00	1d224113-52fd-42ec-a3d9-ee5e9338d4af	7891652b-f708-4834-90b3-b7e06f9dd5ab	7f30992b-6766-462f-af35-f6ccf27fe636	\N	جلسهٔ برنامه‌ریزی اسپرینت	\N	meeting	2026-06-17 10:00:00+00	2026-06-17 11:00:00+00	f
f77d44c5-e88a-4450-845d-6ac644d037e9	2026-07-20 09:22:03.794401+00	2026-07-20 09:22:03.794401+00	1d224113-52fd-42ec-a3d9-ee5e9338d4af	3623572f-edd3-4d8b-a827-788687faac93	8ea72ae4-a2b9-4204-98a6-7dfa14a12164	\N	یادآوری پیگیری مشتری	\N	reminder	2026-06-17 00:00:00+00	2026-06-17 01:00:00+00	t
a1a42eb9-dfe7-44d8-81fd-73b9e6e9321c	2026-07-20 09:22:03.794401+00	2026-07-20 09:22:03.794401+00	1d224113-52fd-42ec-a3d9-ee5e9338d4af	35524a39-bb53-4f81-b913-a64fc2c0bc5e	\N	\N	تعطیلی رسمی	\N	holiday	2026-06-18 00:00:00+00	2026-06-18 01:00:00+00	t
9f94a0c2-1445-4b9b-b09f-da3a77d50260	2026-07-20 09:22:03.794401+00	2026-07-20 09:22:03.794401+00	1d224113-52fd-42ec-a3d9-ee5e9338d4af	7891652b-f708-4834-90b3-b7e06f9dd5ab	7f30992b-6766-462f-af35-f6ccf27fe636	\N	جلسهٔ مرور با مدیریت	\N	meeting	2026-06-24 10:00:00+00	2026-06-24 11:00:00+00	f
4302efb0-0a92-4629-a830-5a17fc8640ae	2026-07-20 09:22:03.794401+00	2026-07-20 09:22:03.794401+00	1d224113-52fd-42ec-a3d9-ee5e9338d4af	57b624b6-2a61-45ab-95e9-0d4965be1a7e	8ea72ae4-a2b9-4204-98a6-7dfa14a12164	\N	یادآوری پیگیری مشتری	\N	reminder	2026-06-26 00:00:00+00	2026-06-26 01:00:00+00	t
38da647d-5088-4080-a1c1-179357d89497	2026-07-20 09:22:03.794401+00	2026-07-20 09:22:03.794401+00	1d224113-52fd-42ec-a3d9-ee5e9338d4af	7891652b-f708-4834-90b3-b7e06f9dd5ab	7f30992b-6766-462f-af35-f6ccf27fe636	\N	جلسهٔ مرور با مدیریت	\N	meeting	2026-07-02 10:00:00+00	2026-07-02 11:00:00+00	f
e464c675-bbc2-404f-8d10-84eb4508c2c0	2026-07-20 09:22:03.794401+00	2026-07-20 09:22:03.794401+00	1d224113-52fd-42ec-a3d9-ee5e9338d4af	fc439dd8-ff4f-4760-bcc2-e3cddcba6888	536ad236-1a6a-4963-aab2-e8e45fcc9989	\N	یادآوری پیگیری مشتری	\N	reminder	2026-07-02 00:00:00+00	2026-07-02 01:00:00+00	t
e99ff382-85fc-464a-890a-e2a9e06497b8	2026-07-20 09:22:03.794401+00	2026-07-20 09:22:03.794401+00	1d224113-52fd-42ec-a3d9-ee5e9338d4af	7891652b-f708-4834-90b3-b7e06f9dd5ab	536ad236-1a6a-4963-aab2-e8e45fcc9989	\N	جلسهٔ بررسی پیشرفت پروژه	\N	meeting	2026-07-11 10:00:00+00	2026-07-11 11:00:00+00	f
9c5b30f8-2134-4632-9f94-c9289df7eaed	2026-07-20 09:22:03.794401+00	2026-07-20 09:22:03.794401+00	1d224113-52fd-42ec-a3d9-ee5e9338d4af	726b1bd0-c51d-4f38-9e37-f4c46a258d1b	7f30992b-6766-462f-af35-f6ccf27fe636	\N	یادآوری ارسال گزارش	\N	reminder	2026-07-13 00:00:00+00	2026-07-13 01:00:00+00	t
09e1e9c2-5573-4eef-83db-8b822e0ac260	2026-07-20 09:22:03.794401+00	2026-07-20 09:22:03.794401+00	1d224113-52fd-42ec-a3d9-ee5e9338d4af	7891652b-f708-4834-90b3-b7e06f9dd5ab	be632b24-428c-485a-92f7-5e9d91fe40fc	\N	جلسهٔ مرور با مدیریت	\N	meeting	2026-07-17 10:00:00+00	2026-07-17 11:00:00+00	f
9837c303-2ec6-4fb9-905e-4436175e51e8	2026-07-20 09:22:03.794401+00	2026-07-20 09:22:03.794401+00	1d224113-52fd-42ec-a3d9-ee5e9338d4af	57b624b6-2a61-45ab-95e9-0d4965be1a7e	536ad236-1a6a-4963-aab2-e8e45fcc9989	\N	یادآوری تمدید قرارداد	\N	reminder	2026-07-15 00:00:00+00	2026-07-15 01:00:00+00	t
a439d41e-3705-4361-9cc4-4d75f08933aa	2026-07-20 09:22:03.794401+00	2026-07-20 09:22:03.794401+00	1d224113-52fd-42ec-a3d9-ee5e9338d4af	35524a39-bb53-4f81-b913-a64fc2c0bc5e	\N	\N	تعطیلی رسمی	\N	holiday	2026-07-16 00:00:00+00	2026-07-16 01:00:00+00	t
f2a62e1e-0120-4faa-a307-ac07f344d9f8	2026-07-20 09:22:03.794401+00	2026-07-20 09:22:03.794401+00	1d224113-52fd-42ec-a3d9-ee5e9338d4af	7891652b-f708-4834-90b3-b7e06f9dd5ab	536ad236-1a6a-4963-aab2-e8e45fcc9989	\N	جلسهٔ مرور با مدیریت	\N	meeting	2026-07-24 10:00:00+00	2026-07-24 11:00:00+00	f
2e972212-36b9-486c-8fc7-16a3a4a6dcc7	2026-07-20 09:22:03.794401+00	2026-07-20 09:22:03.794401+00	1d224113-52fd-42ec-a3d9-ee5e9338d4af	39f6a330-2d20-4870-ba2a-2457ecb3df8d	be632b24-428c-485a-92f7-5e9d91fe40fc	\N	یادآوری پیگیری مشتری	\N	reminder	2026-07-22 00:00:00+00	2026-07-22 01:00:00+00	t
63e59eb8-6469-4517-b4d3-488f6dcd0ee0	2026-07-20 09:22:03.794401+00	2026-07-20 09:22:03.794401+00	1d224113-52fd-42ec-a3d9-ee5e9338d4af	7891652b-f708-4834-90b3-b7e06f9dd5ab	7f30992b-6766-462f-af35-f6ccf27fe636	\N	جلسهٔ برنامه‌ریزی اسپرینت	\N	meeting	2026-07-31 10:00:00+00	2026-07-31 11:00:00+00	f
1f509ed9-e7cb-49b6-b328-6bd5499b4db3	2026-07-20 09:22:03.794401+00	2026-07-20 09:22:03.794401+00	1d224113-52fd-42ec-a3d9-ee5e9338d4af	81977026-b6d9-4183-92f3-63f6484c7ae5	be632b24-428c-485a-92f7-5e9d91fe40fc	\N	یادآوری ارسال گزارش	\N	reminder	2026-07-30 00:00:00+00	2026-07-30 01:00:00+00	t
eba051c5-3955-4612-99e8-be8d21693f0a	2026-07-20 09:22:03.794401+00	2026-07-20 09:22:03.794401+00	1d224113-52fd-42ec-a3d9-ee5e9338d4af	7891652b-f708-4834-90b3-b7e06f9dd5ab	8ea72ae4-a2b9-4204-98a6-7dfa14a12164	\N	جلسهٔ بررسی پیشرفت پروژه	\N	meeting	2026-08-04 10:00:00+00	2026-08-04 11:00:00+00	f
7a84d783-3e2a-41ed-b644-d004bed66a6f	2026-07-20 09:22:03.794401+00	2026-07-20 09:22:03.794401+00	1d224113-52fd-42ec-a3d9-ee5e9338d4af	57b624b6-2a61-45ab-95e9-0d4965be1a7e	7f30992b-6766-462f-af35-f6ccf27fe636	\N	یادآوری تمدید قرارداد	\N	reminder	2026-08-04 00:00:00+00	2026-08-04 01:00:00+00	t
33999234-bd37-49fb-9eb2-5c9fd7907ada	2026-07-20 09:22:03.794401+00	2026-07-20 09:22:03.794401+00	1d224113-52fd-42ec-a3d9-ee5e9338d4af	7891652b-f708-4834-90b3-b7e06f9dd5ab	d4c60db1-32fc-4fff-9b44-e4d116cb53d4	\N	جلسهٔ برنامه‌ریزی اسپرینت	\N	meeting	2026-08-14 10:00:00+00	2026-08-14 11:00:00+00	f
72b916e4-038b-40c3-8c21-affa41852e07	2026-07-20 09:22:03.794401+00	2026-07-20 09:22:03.794401+00	1d224113-52fd-42ec-a3d9-ee5e9338d4af	3623572f-edd3-4d8b-a827-788687faac93	7f30992b-6766-462f-af35-f6ccf27fe636	\N	یادآوری پیگیری مشتری	\N	reminder	2026-08-13 00:00:00+00	2026-08-13 01:00:00+00	t
7277dd1a-8296-470e-bd29-7224e41dd8d9	2026-07-20 09:22:03.794401+00	2026-07-20 09:22:03.794401+00	1d224113-52fd-42ec-a3d9-ee5e9338d4af	35524a39-bb53-4f81-b913-a64fc2c0bc5e	\N	\N	تعطیلی رسمی	\N	holiday	2026-08-13 00:00:00+00	2026-08-13 01:00:00+00	t
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
895d0d58-2797-442c-ab90-133cfd1997d5	2026-07-20 09:22:03.794401+00	2026-07-20 09:22:03.794401+00	1d224113-52fd-42ec-a3d9-ee5e9338d4af	مهندسی و فنی
3203500b-f7b4-46ac-9894-9af6675608c0	2026-07-20 09:22:03.794401+00	2026-07-20 09:22:03.794401+00	1d224113-52fd-42ec-a3d9-ee5e9338d4af	حسابداری و مالی
0058b701-84a4-4426-9d09-f89608fd6adc	2026-07-20 09:22:03.794401+00	2026-07-20 09:22:03.794401+00	1d224113-52fd-42ec-a3d9-ee5e9338d4af	منابع انسانی
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
1d224113-52fd-42ec-a3d9-ee5e9338d4af	b3e7b1f6-d818-46bc-a98e-9f7048e16f8f	report_submitted	{"task_id": "1b9015fe-8f2d-48ec-ba19-68e9b51d02c6", "task_title": "تهیهٔ گزارش جریان نقدی #5", "worklog_id": "7234ce3f-9db8-4122-8430-06e9fcf2a7db"}	f	8efd3e08-949a-47ae-a1dc-97f46550d5a7	2026-07-20 09:22:57.243373+00	2026-07-20 09:22:57.243373+00
1d224113-52fd-42ec-a3d9-ee5e9338d4af	1bd96f4a-6acb-4464-8452-ca1d3114a328	report_reviewed	{"status": "approved", "task_id": "1b9015fe-8f2d-48ec-ba19-68e9b51d02c6", "worklog_id": "7234ce3f-9db8-4122-8430-06e9fcf2a7db"}	f	deca1e13-12b4-42d0-919a-77d1627305c1	2026-07-20 09:23:07.778503+00	2026-07-20 09:23:07.778503+00
\.


--
-- Data for Name: organizations; Type: TABLE DATA; Schema: public; Owner: -
--

COPY public.organizations (name, slug, is_active, id, created_at, updated_at) FROM stdin;
شرکت نمونهٔ آزمایشی	demo-org-04eb147d	t	1d224113-52fd-42ec-a3d9-ee5e9338d4af	2026-07-20 09:22:03.794401+00	2026-07-20 09:22:03.794401+00
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
7e20e869-c4d2-4866-a078-03145a732db4	127c1187-f85a-48c8-82b5-451a4ccfeb71	490464d3-2472-4d95-bb44-8dd1607326a5	2026-07-20 09:22:03.794401+00	2026-07-20 09:22:03.794401+00
7e20e869-c4d2-4866-a078-03145a732db4	6fb1a35d-b064-46b8-8796-54c4fec69d24	6c41bfff-d0dd-420e-b888-42cbba28e600	2026-07-20 09:22:03.794401+00	2026-07-20 09:22:03.794401+00
7e20e869-c4d2-4866-a078-03145a732db4	0132fd66-319f-4f6e-8e2f-d16328d278e8	6206405a-90c1-4554-afe2-cb5c892f2639	2026-07-20 09:22:03.794401+00	2026-07-20 09:22:03.794401+00
7e20e869-c4d2-4866-a078-03145a732db4	3940e09c-eede-4772-818b-3a4bc4703195	10e2063b-2506-4c31-84bb-ec409bbbc049	2026-07-20 09:22:03.794401+00	2026-07-20 09:22:03.794401+00
eada99a6-4c95-418c-8fa0-baf7c82570b1	127c1187-f85a-48c8-82b5-451a4ccfeb71	4b2770c4-5ac2-4241-9e36-3a37e982f798	2026-07-20 09:22:03.794401+00	2026-07-20 09:22:03.794401+00
eada99a6-4c95-418c-8fa0-baf7c82570b1	6fb1a35d-b064-46b8-8796-54c4fec69d24	537462ba-c533-49fd-86e3-d868984926c8	2026-07-20 09:22:03.794401+00	2026-07-20 09:22:03.794401+00
eada99a6-4c95-418c-8fa0-baf7c82570b1	f4e6dc2a-b9f2-43e2-8db1-3516a3e2985c	77d89bb0-663b-4c4a-8770-ea5dadfca6f2	2026-07-20 09:22:03.794401+00	2026-07-20 09:22:03.794401+00
eada99a6-4c95-418c-8fa0-baf7c82570b1	a2c3e527-82e9-4bd2-be63-85f6ead97337	33d38ce9-decc-42fb-975c-0945041e7b81	2026-07-20 09:22:03.794401+00	2026-07-20 09:22:03.794401+00
61c13830-e388-41dc-bb0e-d6b8f1f0d634	127c1187-f85a-48c8-82b5-451a4ccfeb71	0c319e21-8b48-46e2-9fbc-314751ab20c1	2026-07-20 09:22:03.794401+00	2026-07-20 09:22:03.794401+00
61c13830-e388-41dc-bb0e-d6b8f1f0d634	a2c3e527-82e9-4bd2-be63-85f6ead97337	f18a682f-2a7c-4d38-bd71-7743a524d097	2026-07-20 09:22:03.794401+00	2026-07-20 09:22:03.794401+00
61c13830-e388-41dc-bb0e-d6b8f1f0d634	6fb1a35d-b064-46b8-8796-54c4fec69d24	b3f1fb69-f0a0-4dca-829c-60c3dc70e74a	2026-07-20 09:22:03.794401+00	2026-07-20 09:22:03.794401+00
61c13830-e388-41dc-bb0e-d6b8f1f0d634	0132fd66-319f-4f6e-8e2f-d16328d278e8	4d34c898-1b74-4646-b085-90efecd03dda	2026-07-20 09:22:03.794401+00	2026-07-20 09:22:03.794401+00
91889926-2b3f-4643-8d23-0cd8a3d96488	127c1187-f85a-48c8-82b5-451a4ccfeb71	e905264d-c269-4a79-8a45-28e85c2e8f19	2026-07-20 09:22:03.794401+00	2026-07-20 09:22:03.794401+00
91889926-2b3f-4643-8d23-0cd8a3d96488	6fb1a35d-b064-46b8-8796-54c4fec69d24	5b4042af-a073-4de0-b017-29a2d44f11d7	2026-07-20 09:22:03.794401+00	2026-07-20 09:22:03.794401+00
91889926-2b3f-4643-8d23-0cd8a3d96488	3940e09c-eede-4772-818b-3a4bc4703195	ce3e8e0e-97de-4c5a-af74-0d9cd8e02ae6	2026-07-20 09:22:03.794401+00	2026-07-20 09:22:03.794401+00
91889926-2b3f-4643-8d23-0cd8a3d96488	0132fd66-319f-4f6e-8e2f-d16328d278e8	5bf760bd-66de-4617-b260-fc2d1aa109e6	2026-07-20 09:22:03.794401+00	2026-07-20 09:22:03.794401+00
d86107c2-52f7-48ef-847b-f82fecf566dd	127c1187-f85a-48c8-82b5-451a4ccfeb71	af32a7a5-c6a5-4401-9c1a-b07ff6769bf1	2026-07-20 09:22:03.794401+00	2026-07-20 09:22:03.794401+00
d86107c2-52f7-48ef-847b-f82fecf566dd	3940e09c-eede-4772-818b-3a4bc4703195	19143a3c-8e49-4414-a670-514c3d37a61c	2026-07-20 09:22:03.794401+00	2026-07-20 09:22:03.794401+00
d86107c2-52f7-48ef-847b-f82fecf566dd	054f46d3-1cc2-42df-9532-2b310816822b	2785406c-5cca-47cd-9c95-a10270a0cf08	2026-07-20 09:22:03.794401+00	2026-07-20 09:22:03.794401+00
d86107c2-52f7-48ef-847b-f82fecf566dd	0132fd66-319f-4f6e-8e2f-d16328d278e8	0abed9ae-8753-49d4-8a85-68acb2046f58	2026-07-20 09:22:03.794401+00	2026-07-20 09:22:03.794401+00
58a3e39a-4d3f-4eeb-bf3e-fbf3ae866a53	b3e7b1f6-d818-46bc-a98e-9f7048e16f8f	f3710740-f8b7-42fb-9e80-038e8b2e3184	2026-07-20 09:22:03.794401+00	2026-07-20 09:22:03.794401+00
58a3e39a-4d3f-4eeb-bf3e-fbf3ae866a53	1fd4dffb-d8db-4387-914a-be2a2a6fd6b1	3c4b0e82-5675-444a-9e36-ef291b2dad0a	2026-07-20 09:22:03.794401+00	2026-07-20 09:22:03.794401+00
58a3e39a-4d3f-4eeb-bf3e-fbf3ae866a53	03c131a9-29b0-4e66-8d67-be78cfa01885	cc0cec69-5ecb-4555-8ea2-926a450d3638	2026-07-20 09:22:03.794401+00	2026-07-20 09:22:03.794401+00
58a3e39a-4d3f-4eeb-bf3e-fbf3ae866a53	b720465e-b31b-4b9b-99d6-b303ca5f639d	806a314e-54f1-45e6-a77c-1b89fcd4b3dc	2026-07-20 09:22:03.794401+00	2026-07-20 09:22:03.794401+00
8d09c967-bbac-40b4-b041-c8ea0286cd15	b3e7b1f6-d818-46bc-a98e-9f7048e16f8f	801fdc6d-e1c0-4ea6-a073-648090c39721	2026-07-20 09:22:03.794401+00	2026-07-20 09:22:03.794401+00
8d09c967-bbac-40b4-b041-c8ea0286cd15	8a6bd071-9f82-4273-b101-9c763d6c4be4	671a5795-c7c4-4369-bada-f9239886270f	2026-07-20 09:22:03.794401+00	2026-07-20 09:22:03.794401+00
8d09c967-bbac-40b4-b041-c8ea0286cd15	b720465e-b31b-4b9b-99d6-b303ca5f639d	266e3481-bb17-4d85-908b-75ba0709c766	2026-07-20 09:22:03.794401+00	2026-07-20 09:22:03.794401+00
8d09c967-bbac-40b4-b041-c8ea0286cd15	1fd4dffb-d8db-4387-914a-be2a2a6fd6b1	6b429499-d3a6-4643-95d5-56d3044efa13	2026-07-20 09:22:03.794401+00	2026-07-20 09:22:03.794401+00
bd97c764-a55c-4687-96d6-225085ccda6f	b3e7b1f6-d818-46bc-a98e-9f7048e16f8f	dd88dad4-9caf-4ea5-ae25-a08a4be80168	2026-07-20 09:22:03.794401+00	2026-07-20 09:22:03.794401+00
bd97c764-a55c-4687-96d6-225085ccda6f	1bd96f4a-6acb-4464-8452-ca1d3114a328	5db1080e-b198-4b5f-a2ab-735ea348adca	2026-07-20 09:22:03.794401+00	2026-07-20 09:22:03.794401+00
bd97c764-a55c-4687-96d6-225085ccda6f	8cca3fcf-f7a7-421a-b9a4-5dab90fe1b83	6e1c711b-aa74-4e14-9dc6-ccc487a6858b	2026-07-20 09:22:03.794401+00	2026-07-20 09:22:03.794401+00
bd97c764-a55c-4687-96d6-225085ccda6f	1fd4dffb-d8db-4387-914a-be2a2a6fd6b1	e7f161f9-24a8-48e2-a228-2125853a4cc6	2026-07-20 09:22:03.794401+00	2026-07-20 09:22:03.794401+00
24aaff84-b716-40f0-bc01-1438192b4c8c	b3e7b1f6-d818-46bc-a98e-9f7048e16f8f	b980deb2-7fff-45c0-a4b2-b5ddd46ef061	2026-07-20 09:22:03.794401+00	2026-07-20 09:22:03.794401+00
24aaff84-b716-40f0-bc01-1438192b4c8c	1fd4dffb-d8db-4387-914a-be2a2a6fd6b1	92632ab3-c691-4cd4-8bff-02474043cd4e	2026-07-20 09:22:03.794401+00	2026-07-20 09:22:03.794401+00
24aaff84-b716-40f0-bc01-1438192b4c8c	1bd96f4a-6acb-4464-8452-ca1d3114a328	542b56ea-54f1-4dab-9fd4-4014be5aa05c	2026-07-20 09:22:03.794401+00	2026-07-20 09:22:03.794401+00
24aaff84-b716-40f0-bc01-1438192b4c8c	03c131a9-29b0-4e66-8d67-be78cfa01885	9a2d8f29-ee26-4bc9-9a6f-26c7ec52745b	2026-07-20 09:22:03.794401+00	2026-07-20 09:22:03.794401+00
31f35274-08e2-4c6a-8607-ad731054db18	b3e7b1f6-d818-46bc-a98e-9f7048e16f8f	2264e40a-f5ed-42bc-904a-fe11c03739a1	2026-07-20 09:22:03.794401+00	2026-07-20 09:22:03.794401+00
31f35274-08e2-4c6a-8607-ad731054db18	1fd4dffb-d8db-4387-914a-be2a2a6fd6b1	ae19b31f-2c40-48ce-b01f-0bd5288ab058	2026-07-20 09:22:03.794401+00	2026-07-20 09:22:03.794401+00
31f35274-08e2-4c6a-8607-ad731054db18	1bd96f4a-6acb-4464-8452-ca1d3114a328	d2bcb2a6-599d-4b46-bada-7fc5e9fa75be	2026-07-20 09:22:03.794401+00	2026-07-20 09:22:03.794401+00
31f35274-08e2-4c6a-8607-ad731054db18	03c131a9-29b0-4e66-8d67-be78cfa01885	81451bd8-71d3-4308-a39c-52c253059e41	2026-07-20 09:22:03.794401+00	2026-07-20 09:22:03.794401+00
d4c60db1-32fc-4fff-9b44-e4d116cb53d4	7891652b-f708-4834-90b3-b7e06f9dd5ab	f36df793-244b-41eb-ae5b-d220912377c4	2026-07-20 09:22:03.794401+00	2026-07-20 09:22:03.794401+00
d4c60db1-32fc-4fff-9b44-e4d116cb53d4	726b1bd0-c51d-4f38-9e37-f4c46a258d1b	73149bfa-1d13-46dd-96b2-33a7f249cbb3	2026-07-20 09:22:03.794401+00	2026-07-20 09:22:03.794401+00
d4c60db1-32fc-4fff-9b44-e4d116cb53d4	fc439dd8-ff4f-4760-bcc2-e3cddcba6888	c6853f91-b843-4f4c-b603-89459fbe1e40	2026-07-20 09:22:03.794401+00	2026-07-20 09:22:03.794401+00
d4c60db1-32fc-4fff-9b44-e4d116cb53d4	3623572f-edd3-4d8b-a827-788687faac93	a157c842-1bc9-4b94-af15-0408e13078cc	2026-07-20 09:22:03.794401+00	2026-07-20 09:22:03.794401+00
536ad236-1a6a-4963-aab2-e8e45fcc9989	7891652b-f708-4834-90b3-b7e06f9dd5ab	5e2eab06-1c9f-43ac-864f-ec0cbc696e62	2026-07-20 09:22:03.794401+00	2026-07-20 09:22:03.794401+00
536ad236-1a6a-4963-aab2-e8e45fcc9989	81977026-b6d9-4183-92f3-63f6484c7ae5	f908b0b1-b37d-476e-93db-39905adc96b4	2026-07-20 09:22:03.794401+00	2026-07-20 09:22:03.794401+00
536ad236-1a6a-4963-aab2-e8e45fcc9989	57b624b6-2a61-45ab-95e9-0d4965be1a7e	8b795f1b-e6b9-4ffd-b727-a0150ce3720a	2026-07-20 09:22:03.794401+00	2026-07-20 09:22:03.794401+00
536ad236-1a6a-4963-aab2-e8e45fcc9989	39f6a330-2d20-4870-ba2a-2457ecb3df8d	61183d00-9339-49bc-ad3b-5593c4ad3397	2026-07-20 09:22:03.794401+00	2026-07-20 09:22:03.794401+00
7f30992b-6766-462f-af35-f6ccf27fe636	7891652b-f708-4834-90b3-b7e06f9dd5ab	a94747a3-dbda-4dae-80d9-a1e92e97ee5a	2026-07-20 09:22:03.794401+00	2026-07-20 09:22:03.794401+00
7f30992b-6766-462f-af35-f6ccf27fe636	726b1bd0-c51d-4f38-9e37-f4c46a258d1b	97c384f0-0e15-420e-96b2-770f20279998	2026-07-20 09:22:03.794401+00	2026-07-20 09:22:03.794401+00
7f30992b-6766-462f-af35-f6ccf27fe636	57b624b6-2a61-45ab-95e9-0d4965be1a7e	68995fed-5777-42ec-a1e2-8977226bd1ae	2026-07-20 09:22:03.794401+00	2026-07-20 09:22:03.794401+00
7f30992b-6766-462f-af35-f6ccf27fe636	81977026-b6d9-4183-92f3-63f6484c7ae5	2eac22a5-138a-4580-9eaa-66a267be1623	2026-07-20 09:22:03.794401+00	2026-07-20 09:22:03.794401+00
8ea72ae4-a2b9-4204-98a6-7dfa14a12164	7891652b-f708-4834-90b3-b7e06f9dd5ab	f75fc45b-a284-43be-b9ea-82b916a8e546	2026-07-20 09:22:03.794401+00	2026-07-20 09:22:03.794401+00
8ea72ae4-a2b9-4204-98a6-7dfa14a12164	3623572f-edd3-4d8b-a827-788687faac93	3eec893a-08ad-4847-9cb5-b9881178e004	2026-07-20 09:22:03.794401+00	2026-07-20 09:22:03.794401+00
8ea72ae4-a2b9-4204-98a6-7dfa14a12164	81977026-b6d9-4183-92f3-63f6484c7ae5	e3a101c9-90ec-4048-b970-c06d4f554851	2026-07-20 09:22:03.794401+00	2026-07-20 09:22:03.794401+00
8ea72ae4-a2b9-4204-98a6-7dfa14a12164	726b1bd0-c51d-4f38-9e37-f4c46a258d1b	ea998f77-2d9c-4c37-9730-bf120619588f	2026-07-20 09:22:03.794401+00	2026-07-20 09:22:03.794401+00
be632b24-428c-485a-92f7-5e9d91fe40fc	7891652b-f708-4834-90b3-b7e06f9dd5ab	16cc6c56-5835-409b-8f1c-66e41acf3fa4	2026-07-20 09:22:03.794401+00	2026-07-20 09:22:03.794401+00
be632b24-428c-485a-92f7-5e9d91fe40fc	57b624b6-2a61-45ab-95e9-0d4965be1a7e	d4750ad6-2de2-4fee-b100-93ba670b8a6a	2026-07-20 09:22:03.794401+00	2026-07-20 09:22:03.794401+00
be632b24-428c-485a-92f7-5e9d91fe40fc	81977026-b6d9-4183-92f3-63f6484c7ae5	6059ceb1-ec7f-403e-82bf-3ee36cb41b32	2026-07-20 09:22:03.794401+00	2026-07-20 09:22:03.794401+00
be632b24-428c-485a-92f7-5e9d91fe40fc	fc439dd8-ff4f-4760-bcc2-e3cddcba6888	cfe57c55-92f1-4a4a-91e7-03c641f5bbf2	2026-07-20 09:22:03.794401+00	2026-07-20 09:22:03.794401+00
\.


--
-- Data for Name: projects; Type: TABLE DATA; Schema: public; Owner: -
--

COPY public.projects (organization_id, name, description, start_date, end_date, status, created_by_id, id, created_at, updated_at, manager_id, cooperation_start_date, department_id) FROM stdin;
1d224113-52fd-42ec-a3d9-ee5e9338d4af	بازطراحی وب‌سایت شرکتی	پروژهٔ مهندسی و فنی شماره 1	2026-06-16	2026-10-14	active	35524a39-bb53-4f81-b913-a64fc2c0bc5e	7e20e869-c4d2-4866-a078-03145a732db4	2026-07-20 09:22:03.794401+00	2026-07-20 09:22:03.794401+00	127c1187-f85a-48c8-82b5-451a4ccfeb71	2026-06-16	895d0d58-2797-442c-ab90-133cfd1997d5
1d224113-52fd-42ec-a3d9-ee5e9338d4af	توسعهٔ اپلیکیشن موبایل فروش	پروژهٔ مهندسی و فنی شماره 2	2026-06-16	2026-10-14	active	35524a39-bb53-4f81-b913-a64fc2c0bc5e	eada99a6-4c95-418c-8fa0-baf7c82570b1	2026-07-20 09:22:03.794401+00	2026-07-20 09:22:03.794401+00	127c1187-f85a-48c8-82b5-451a4ccfeb71	2026-06-16	895d0d58-2797-442c-ab90-133cfd1997d5
1d224113-52fd-42ec-a3d9-ee5e9338d4af	مهاجرت زیرساخت به ابر	پروژهٔ مهندسی و فنی شماره 3	2026-06-16	2026-10-14	active	35524a39-bb53-4f81-b913-a64fc2c0bc5e	61c13830-e388-41dc-bb0e-d6b8f1f0d634	2026-07-20 09:22:03.794401+00	2026-07-20 09:22:03.794401+00	127c1187-f85a-48c8-82b5-451a4ccfeb71	2026-06-16	895d0d58-2797-442c-ab90-133cfd1997d5
1d224113-52fd-42ec-a3d9-ee5e9338d4af	پیاده‌سازی سامانهٔ مانیتورینگ	پروژهٔ مهندسی و فنی شماره 4	2026-06-16	2026-10-14	active	35524a39-bb53-4f81-b913-a64fc2c0bc5e	91889926-2b3f-4643-8d23-0cd8a3d96488	2026-07-20 09:22:03.794401+00	2026-07-20 09:22:03.794401+00	127c1187-f85a-48c8-82b5-451a4ccfeb71	2026-06-16	895d0d58-2797-442c-ab90-133cfd1997d5
1d224113-52fd-42ec-a3d9-ee5e9338d4af	بهبود عملکرد پایگاه‌داده	پروژهٔ مهندسی و فنی شماره 5	2026-06-16	2026-10-14	active	35524a39-bb53-4f81-b913-a64fc2c0bc5e	d86107c2-52f7-48ef-847b-f82fecf566dd	2026-07-20 09:22:03.794401+00	2026-07-20 09:22:03.794401+00	127c1187-f85a-48c8-82b5-451a4ccfeb71	2026-06-16	895d0d58-2797-442c-ab90-133cfd1997d5
1d224113-52fd-42ec-a3d9-ee5e9338d4af	بستن حساب‌های مالی سال	پروژهٔ حسابداری و مالی شماره 1	2026-06-16	2026-10-14	active	35524a39-bb53-4f81-b913-a64fc2c0bc5e	58a3e39a-4d3f-4eeb-bf3e-fbf3ae866a53	2026-07-20 09:22:03.794401+00	2026-07-20 09:22:03.794401+00	b3e7b1f6-d818-46bc-a98e-9f7048e16f8f	2026-06-16	3203500b-f7b4-46ac-9894-9af6675608c0
1d224113-52fd-42ec-a3d9-ee5e9338d4af	پیاده‌سازی سامانهٔ فاکتور الکترونیک	پروژهٔ حسابداری و مالی شماره 2	2026-06-16	2026-10-14	active	35524a39-bb53-4f81-b913-a64fc2c0bc5e	8d09c967-bbac-40b4-b041-c8ea0286cd15	2026-07-20 09:22:03.794401+00	2026-07-20 09:22:03.794401+00	b3e7b1f6-d818-46bc-a98e-9f7048e16f8f	2026-06-16	3203500b-f7b4-46ac-9894-9af6675608c0
1d224113-52fd-42ec-a3d9-ee5e9338d4af	ممیزی مالی سه‌ماههٔ دوم	پروژهٔ حسابداری و مالی شماره 3	2026-06-16	2026-10-14	active	35524a39-bb53-4f81-b913-a64fc2c0bc5e	bd97c764-a55c-4687-96d6-225085ccda6f	2026-07-20 09:22:03.794401+00	2026-07-20 09:22:03.794401+00	b3e7b1f6-d818-46bc-a98e-9f7048e16f8f	2026-06-16	3203500b-f7b4-46ac-9894-9af6675608c0
1d224113-52fd-42ec-a3d9-ee5e9338d4af	تدوین بودجهٔ سال آینده	پروژهٔ حسابداری و مالی شماره 4	2026-06-16	2026-10-14	active	35524a39-bb53-4f81-b913-a64fc2c0bc5e	24aaff84-b716-40f0-bc01-1438192b4c8c	2026-07-20 09:22:03.794401+00	2026-07-20 09:22:03.794401+00	b3e7b1f6-d818-46bc-a98e-9f7048e16f8f	2026-06-16	3203500b-f7b4-46ac-9894-9af6675608c0
1d224113-52fd-42ec-a3d9-ee5e9338d4af	مدیریت مطالبات و بدهی‌ها	پروژهٔ حسابداری و مالی شماره 5	2026-06-16	2026-10-14	active	35524a39-bb53-4f81-b913-a64fc2c0bc5e	31f35274-08e2-4c6a-8607-ad731054db18	2026-07-20 09:22:03.794401+00	2026-07-20 09:22:03.794401+00	b3e7b1f6-d818-46bc-a98e-9f7048e16f8f	2026-06-16	3203500b-f7b4-46ac-9894-9af6675608c0
1d224113-52fd-42ec-a3d9-ee5e9338d4af	برگزاری دورهٔ آموزشی کارکنان	پروژهٔ منابع انسانی شماره 1	2026-06-16	2026-10-14	active	35524a39-bb53-4f81-b913-a64fc2c0bc5e	d4c60db1-32fc-4fff-9b44-e4d116cb53d4	2026-07-20 09:22:03.794401+00	2026-07-20 09:22:03.794401+00	7891652b-f708-4834-90b3-b7e06f9dd5ab	2026-06-16	0058b701-84a4-4426-9d09-f89608fd6adc
1d224113-52fd-42ec-a3d9-ee5e9338d4af	بازطراحی فرایند جذب و استخدام	پروژهٔ منابع انسانی شماره 2	2026-06-16	2026-10-14	active	35524a39-bb53-4f81-b913-a64fc2c0bc5e	536ad236-1a6a-4963-aab2-e8e45fcc9989	2026-07-20 09:22:03.794401+00	2026-07-20 09:22:03.794401+00	7891652b-f708-4834-90b3-b7e06f9dd5ab	2026-06-16	0058b701-84a4-4426-9d09-f89608fd6adc
1d224113-52fd-42ec-a3d9-ee5e9338d4af	ارزیابی عملکرد سالانهٔ کارکنان	پروژهٔ منابع انسانی شماره 3	2026-06-16	2026-10-14	active	35524a39-bb53-4f81-b913-a64fc2c0bc5e	7f30992b-6766-462f-af35-f6ccf27fe636	2026-07-20 09:22:03.794401+00	2026-07-20 09:22:03.794401+00	7891652b-f708-4834-90b3-b7e06f9dd5ab	2026-06-16	0058b701-84a4-4426-9d09-f89608fd6adc
1d224113-52fd-42ec-a3d9-ee5e9338d4af	طراحی برنامهٔ رفاهی کارکنان	پروژهٔ منابع انسانی شماره 4	2026-06-16	2026-10-14	active	35524a39-bb53-4f81-b913-a64fc2c0bc5e	8ea72ae4-a2b9-4204-98a6-7dfa14a12164	2026-07-20 09:22:03.794401+00	2026-07-20 09:22:03.794401+00	7891652b-f708-4834-90b3-b7e06f9dd5ab	2026-06-16	0058b701-84a4-4426-9d09-f89608fd6adc
1d224113-52fd-42ec-a3d9-ee5e9338d4af	پیاده‌سازی سامانهٔ حضور و غیاب	پروژهٔ منابع انسانی شماره 5	2026-06-16	2026-10-14	active	35524a39-bb53-4f81-b913-a64fc2c0bc5e	be632b24-428c-485a-92f7-5e9d91fe40fc	2026-07-20 09:22:03.794401+00	2026-07-20 09:22:03.794401+00	7891652b-f708-4834-90b3-b7e06f9dd5ab	2026-06-16	0058b701-84a4-4426-9d09-f89608fd6adc
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
1d224113-52fd-42ec-a3d9-ee5e9338d4af	7e20e869-c4d2-4866-a078-03145a732db4	\N	127c1187-f85a-48c8-82b5-451a4ccfeb71	127c1187-f85a-48c8-82b5-451a4ccfeb71	به‌روزرسانی کتابخانه‌های وابسته #1	\N	high	2026-07-08	08b6bdf5-5aa0-4e22-8716-8c5b419c5ce2	2026-07-20 09:22:03.794401+00	2026-07-20 09:22:03.794401+00	todo	\N	3	23.30	2026-06-29
1d224113-52fd-42ec-a3d9-ee5e9338d4af	7e20e869-c4d2-4866-a078-03145a732db4	\N	3940e09c-eede-4772-818b-3a4bc4703195	127c1187-f85a-48c8-82b5-451a4ccfeb71	بررسی و رفع آسیب‌پذیری امنیتی #2	\N	high	2026-07-21	d391b966-f5bc-4413-a9d4-80910cc91b86	2026-07-20 09:22:03.794401+00	2026-07-20 09:22:03.794401+00	completed	pending	100	12.60	2026-07-12
1d224113-52fd-42ec-a3d9-ee5e9338d4af	7e20e869-c4d2-4866-a078-03145a732db4	\N	6fb1a35d-b064-46b8-8796-54c4fec69d24	127c1187-f85a-48c8-82b5-451a4ccfeb71	نوشتن مستندات فنی API #3	\N	medium	2026-08-10	686cb886-3a4b-4703-a368-2730d18a0ed5	2026-07-20 09:22:03.794401+00	2026-07-20 09:22:03.794401+00	todo	\N	43	12.60	2026-08-03
1d224113-52fd-42ec-a3d9-ee5e9338d4af	7e20e869-c4d2-4866-a078-03145a732db4	\N	0132fd66-319f-4f6e-8e2f-d16328d278e8	127c1187-f85a-48c8-82b5-451a4ccfeb71	پیاده‌سازی صفحهٔ ورود جدید #4	\N	medium	2026-07-12	9be8a4f5-bcde-4fe7-81d8-5e49bd68c1ca	2026-07-20 09:22:03.794401+00	2026-07-20 09:22:03.794401+00	archived	\N	12	15.60	2026-07-07
1d224113-52fd-42ec-a3d9-ee5e9338d4af	7e20e869-c4d2-4866-a078-03145a732db4	\N	a2c3e527-82e9-4bd2-be63-85f6ead97337	127c1187-f85a-48c8-82b5-451a4ccfeb71	به‌روزرسانی کتابخانه‌های وابسته #5	\N	low	2026-07-04	28faaba2-c852-4bb9-82b4-9aacbb28b37a	2026-07-20 09:22:03.794401+00	2026-07-20 09:22:03.794401+00	completed	approved	100	39.00	2026-06-18
1d224113-52fd-42ec-a3d9-ee5e9338d4af	7e20e869-c4d2-4866-a078-03145a732db4	\N	f4e6dc2a-b9f2-43e2-8db1-3516a3e2985c	127c1187-f85a-48c8-82b5-451a4ccfeb71	بازنویسی ماژول اعلان‌ها #6	\N	high	2026-08-01	0a2d709d-3e5e-4c1b-8afe-f21e175075ae	2026-07-20 09:22:03.794401+00	2026-07-20 09:22:03.794401+00	todo	\N	79	35.60	2026-07-21
1d224113-52fd-42ec-a3d9-ee5e9338d4af	7e20e869-c4d2-4866-a078-03145a732db4	\N	a2c3e527-82e9-4bd2-be63-85f6ead97337	127c1187-f85a-48c8-82b5-451a4ccfeb71	تنظیم پایپ‌لاین CI/CD #7	\N	low	2026-06-23	12464624-7623-4db7-beed-bf673646034b	2026-07-20 09:22:03.794401+00	2026-07-20 09:22:03.794401+00	completed	approved	100	31.40	2026-06-20
1d224113-52fd-42ec-a3d9-ee5e9338d4af	7e20e869-c4d2-4866-a078-03145a732db4	\N	127c1187-f85a-48c8-82b5-451a4ccfeb71	127c1187-f85a-48c8-82b5-451a4ccfeb71	پیاده‌سازی احراز هویت دومرحله‌ای #8	\N	medium	2026-08-15	61614765-4c0b-49ba-9512-588294729146	2026-07-20 09:22:03.794401+00	2026-07-20 09:22:03.794401+00	in_progress	\N	58	26.20	2026-08-10
1d224113-52fd-42ec-a3d9-ee5e9338d4af	7e20e869-c4d2-4866-a078-03145a732db4	\N	a2c3e527-82e9-4bd2-be63-85f6ead97337	127c1187-f85a-48c8-82b5-451a4ccfeb71	افزودن تست واحد برای سرویس کاربران #9	\N	high	2026-07-22	71a4ddc5-528c-46bb-8ab8-82a644c60317	2026-07-20 09:22:03.794401+00	2026-07-20 09:22:03.794401+00	todo	\N	34	28.70	2026-07-09
1d224113-52fd-42ec-a3d9-ee5e9338d4af	7e20e869-c4d2-4866-a078-03145a732db4	\N	3940e09c-eede-4772-818b-3a4bc4703195	127c1187-f85a-48c8-82b5-451a4ccfeb71	به‌روزرسانی کتابخانه‌های وابسته #10	\N	high	2026-08-02	eef01f0a-0620-4249-8488-551b21bbc2ba	2026-07-20 09:22:03.794401+00	2026-07-20 09:22:03.794401+00	completed	approved	100	11.30	2026-07-26
1d224113-52fd-42ec-a3d9-ee5e9338d4af	7e20e869-c4d2-4866-a078-03145a732db4	\N	f4e6dc2a-b9f2-43e2-8db1-3516a3e2985c	127c1187-f85a-48c8-82b5-451a4ccfeb71	افزودن تست واحد برای سرویس کاربران #11	\N	high	2026-07-22	1d660afb-9ee2-45ce-a316-483405c3efc4	2026-07-20 09:22:03.794401+00	2026-07-20 09:22:03.794401+00	in_progress	\N	41	34.00	2026-07-03
1d224113-52fd-42ec-a3d9-ee5e9338d4af	7e20e869-c4d2-4866-a078-03145a732db4	\N	6fb1a35d-b064-46b8-8796-54c4fec69d24	127c1187-f85a-48c8-82b5-451a4ccfeb71	رفع مشکل ناسازگاری مرورگر #12	\N	medium	2026-07-03	3552d494-01de-460b-8b17-7777aada3988	2026-07-20 09:22:03.794401+00	2026-07-20 09:22:03.794401+00	todo	\N	51	12.20	2026-06-30
1d224113-52fd-42ec-a3d9-ee5e9338d4af	7e20e869-c4d2-4866-a078-03145a732db4	\N	0132fd66-319f-4f6e-8e2f-d16328d278e8	127c1187-f85a-48c8-82b5-451a4ccfeb71	تنظیم پایپ‌لاین CI/CD #13	\N	medium	2026-07-14	cdb0ff10-2e9e-414d-b8e2-0a0978bf4b34	2026-07-20 09:22:03.794401+00	2026-07-20 09:22:03.794401+00	completed	pending	100	17.00	2026-07-06
1d224113-52fd-42ec-a3d9-ee5e9338d4af	7e20e869-c4d2-4866-a078-03145a732db4	\N	3940e09c-eede-4772-818b-3a4bc4703195	127c1187-f85a-48c8-82b5-451a4ccfeb71	نوشتن مستندات فنی API #14	\N	high	2026-07-03	2fc2c5ea-092e-49cc-8d60-b57eba9e90b7	2026-07-20 09:22:03.794401+00	2026-07-20 09:22:03.794401+00	completed	approved	100	22.50	2026-06-24
1d224113-52fd-42ec-a3d9-ee5e9338d4af	7e20e869-c4d2-4866-a078-03145a732db4	\N	3940e09c-eede-4772-818b-3a4bc4703195	127c1187-f85a-48c8-82b5-451a4ccfeb71	رفع مشکل کندی بارگذاری صفحه #15	\N	low	2026-08-06	6c865051-e24c-4452-bbb9-579c19eeba07	2026-07-20 09:22:03.794401+00	2026-07-20 09:22:03.794401+00	completed	approved	100	39.90	2026-07-23
1d224113-52fd-42ec-a3d9-ee5e9338d4af	7e20e869-c4d2-4866-a078-03145a732db4	\N	0132fd66-319f-4f6e-8e2f-d16328d278e8	127c1187-f85a-48c8-82b5-451a4ccfeb71	بازنویسی ماژول اعلان‌ها #16	\N	low	2026-08-06	d4f816b1-d0a2-4fbc-833f-2668b871000e	2026-07-20 09:22:03.794401+00	2026-07-20 09:22:03.794401+00	completed	approved	100	7.80	2026-08-03
1d224113-52fd-42ec-a3d9-ee5e9338d4af	7e20e869-c4d2-4866-a078-03145a732db4	\N	0132fd66-319f-4f6e-8e2f-d16328d278e8	127c1187-f85a-48c8-82b5-451a4ccfeb71	پیاده‌سازی احراز هویت دومرحله‌ای #17	\N	high	2026-07-04	b66d2149-0c4e-4d83-8918-57fb47f3d170	2026-07-20 09:22:03.794401+00	2026-07-20 09:22:03.794401+00	completed	approved	100	39.90	2026-06-20
1d224113-52fd-42ec-a3d9-ee5e9338d4af	7e20e869-c4d2-4866-a078-03145a732db4	\N	054f46d3-1cc2-42df-9532-2b310816822b	127c1187-f85a-48c8-82b5-451a4ccfeb71	تنظیم پایپ‌لاین CI/CD #18	\N	high	2026-07-23	d0e4ab58-5e97-41f3-a33b-d4782982ca57	2026-07-20 09:22:03.794401+00	2026-07-20 09:22:03.794401+00	in_progress	\N	14	27.90	2026-07-21
1d224113-52fd-42ec-a3d9-ee5e9338d4af	eada99a6-4c95-418c-8fa0-baf7c82570b1	\N	054f46d3-1cc2-42df-9532-2b310816822b	127c1187-f85a-48c8-82b5-451a4ccfeb71	پیاده‌سازی صفحهٔ ورود جدید #19	\N	medium	2026-07-15	3bc9185c-349c-4dcc-89ca-afb1092ebccb	2026-07-20 09:22:03.794401+00	2026-07-20 09:22:03.794401+00	archived	\N	55	8.00	2026-07-03
1d224113-52fd-42ec-a3d9-ee5e9338d4af	eada99a6-4c95-418c-8fa0-baf7c82570b1	\N	127c1187-f85a-48c8-82b5-451a4ccfeb71	127c1187-f85a-48c8-82b5-451a4ccfeb71	به‌روزرسانی کتابخانه‌های وابسته #20	\N	low	2026-08-21	6733cdad-fd8b-4bbb-b75f-a085077d5f07	2026-07-20 09:22:03.794401+00	2026-07-20 09:22:03.794401+00	archived	\N	64	36.70	2026-08-11
1d224113-52fd-42ec-a3d9-ee5e9338d4af	eada99a6-4c95-418c-8fa0-baf7c82570b1	\N	6fb1a35d-b064-46b8-8796-54c4fec69d24	127c1187-f85a-48c8-82b5-451a4ccfeb71	پیاده‌سازی صفحهٔ داشبورد مدیریتی #21	\N	low	2026-08-13	4ebec8b6-f8d9-40c6-8e84-0780df9f741b	2026-07-20 09:22:03.794401+00	2026-07-20 09:22:03.794401+00	completed	approved	100	7.80	2026-07-26
1d224113-52fd-42ec-a3d9-ee5e9338d4af	eada99a6-4c95-418c-8fa0-baf7c82570b1	\N	6fb1a35d-b064-46b8-8796-54c4fec69d24	127c1187-f85a-48c8-82b5-451a4ccfeb71	افزودن قابلیت جست‌وجوی پیشرفته #22	\N	low	2026-08-07	533ecec9-d364-469b-ac14-726b43da90c3	2026-07-20 09:22:03.794401+00	2026-07-20 09:22:03.794401+00	todo	\N	76	14.30	2026-07-20
1d224113-52fd-42ec-a3d9-ee5e9338d4af	eada99a6-4c95-418c-8fa0-baf7c82570b1	\N	127c1187-f85a-48c8-82b5-451a4ccfeb71	127c1187-f85a-48c8-82b5-451a4ccfeb71	افزودن قابلیت جست‌وجوی پیشرفته #23	\N	medium	2026-08-27	2be9436a-9f8e-4cd8-a813-4a7c28e45b82	2026-07-20 09:22:03.794401+00	2026-07-20 09:22:03.794401+00	todo	\N	30	4.20	2026-08-14
1d224113-52fd-42ec-a3d9-ee5e9338d4af	eada99a6-4c95-418c-8fa0-baf7c82570b1	\N	054f46d3-1cc2-42df-9532-2b310816822b	127c1187-f85a-48c8-82b5-451a4ccfeb71	بازنویسی ماژول اعلان‌ها #24	\N	low	2026-07-08	f10e189e-f9a7-44e3-b3c4-b2ac297ff583	2026-07-20 09:22:03.794401+00	2026-07-20 09:22:03.794401+00	todo	\N	68	31.10	2026-06-21
1d224113-52fd-42ec-a3d9-ee5e9338d4af	eada99a6-4c95-418c-8fa0-baf7c82570b1	\N	0132fd66-319f-4f6e-8e2f-d16328d278e8	127c1187-f85a-48c8-82b5-451a4ccfeb71	طراحی API نسخهٔ دوم #25	\N	high	2026-07-28	80a197cb-7e36-44e7-a218-6e7d635b1f0d	2026-07-20 09:22:03.794401+00	2026-07-20 09:22:03.794401+00	completed	approved	100	35.20	2026-07-21
1d224113-52fd-42ec-a3d9-ee5e9338d4af	eada99a6-4c95-418c-8fa0-baf7c82570b1	\N	f4e6dc2a-b9f2-43e2-8db1-3516a3e2985c	127c1187-f85a-48c8-82b5-451a4ccfeb71	رفع مشکل ناسازگاری مرورگر #26	\N	high	2026-09-02	49d64b94-91ad-47f3-80da-0a18c2a4397a	2026-07-20 09:22:03.794401+00	2026-07-20 09:22:03.794401+00	in_progress	\N	25	29.10	2026-08-14
1d224113-52fd-42ec-a3d9-ee5e9338d4af	eada99a6-4c95-418c-8fa0-baf7c82570b1	\N	f4e6dc2a-b9f2-43e2-8db1-3516a3e2985c	127c1187-f85a-48c8-82b5-451a4ccfeb71	بررسی و رفع آسیب‌پذیری امنیتی #27	\N	low	2026-08-01	a80e9479-197d-46fc-9a38-afcf28eafa98	2026-07-20 09:22:03.794401+00	2026-07-20 09:22:03.794401+00	completed	pending	100	11.40	2026-07-14
1d224113-52fd-42ec-a3d9-ee5e9338d4af	eada99a6-4c95-418c-8fa0-baf7c82570b1	\N	127c1187-f85a-48c8-82b5-451a4ccfeb71	127c1187-f85a-48c8-82b5-451a4ccfeb71	به‌روزرسانی کتابخانه‌های وابسته #28	\N	low	2026-07-07	d7bbe2ef-961b-499f-ab23-de9f62cb8960	2026-07-20 09:22:03.794401+00	2026-07-20 09:22:03.794401+00	in_progress	\N	75	10.40	2026-06-17
1d224113-52fd-42ec-a3d9-ee5e9338d4af	eada99a6-4c95-418c-8fa0-baf7c82570b1	\N	127c1187-f85a-48c8-82b5-451a4ccfeb71	127c1187-f85a-48c8-82b5-451a4ccfeb71	افزودن تست واحد برای سرویس کاربران #29	\N	low	2026-07-29	bdac96fc-838e-4ad6-8910-02418cb5da92	2026-07-20 09:22:03.794401+00	2026-07-20 09:22:03.794401+00	archived	\N	4	34.70	2026-07-26
1d224113-52fd-42ec-a3d9-ee5e9338d4af	eada99a6-4c95-418c-8fa0-baf7c82570b1	\N	127c1187-f85a-48c8-82b5-451a4ccfeb71	127c1187-f85a-48c8-82b5-451a4ccfeb71	افزودن تست واحد برای سرویس کاربران #30	\N	high	2026-08-14	66785bb2-15d7-470b-966e-4508bfe0b1f7	2026-07-20 09:22:03.794401+00	2026-07-20 09:22:03.794401+00	completed	approved	100	7.00	2026-07-28
1d224113-52fd-42ec-a3d9-ee5e9338d4af	eada99a6-4c95-418c-8fa0-baf7c82570b1	\N	054f46d3-1cc2-42df-9532-2b310816822b	127c1187-f85a-48c8-82b5-451a4ccfeb71	رفع مشکل ناسازگاری مرورگر #31	\N	medium	2026-08-22	058a95ee-c022-44a2-bae4-a8d597aa64c1	2026-07-20 09:22:03.794401+00	2026-07-20 09:22:03.794401+00	completed	approved	100	9.20	2026-08-05
1d224113-52fd-42ec-a3d9-ee5e9338d4af	eada99a6-4c95-418c-8fa0-baf7c82570b1	\N	127c1187-f85a-48c8-82b5-451a4ccfeb71	127c1187-f85a-48c8-82b5-451a4ccfeb71	بررسی و رفع آسیب‌پذیری امنیتی #32	\N	high	2026-07-28	a5c50e16-3ca8-4a9b-b4a4-a857d59488d8	2026-07-20 09:22:03.794401+00	2026-07-20 09:22:03.794401+00	completed	approved	100	4.10	2026-07-13
1d224113-52fd-42ec-a3d9-ee5e9338d4af	eada99a6-4c95-418c-8fa0-baf7c82570b1	\N	3940e09c-eede-4772-818b-3a4bc4703195	127c1187-f85a-48c8-82b5-451a4ccfeb71	رفع مشکل ناسازگاری مرورگر #33	\N	low	2026-07-23	a85de88e-07a4-4424-a8d2-4db147382f9e	2026-07-20 09:22:03.794401+00	2026-07-20 09:22:03.794401+00	completed	approved	100	11.40	2026-07-11
1d224113-52fd-42ec-a3d9-ee5e9338d4af	eada99a6-4c95-418c-8fa0-baf7c82570b1	\N	0132fd66-319f-4f6e-8e2f-d16328d278e8	127c1187-f85a-48c8-82b5-451a4ccfeb71	طراحی API نسخهٔ دوم #34	\N	medium	2026-07-20	24ad9cb4-3448-4772-9488-9e0748c60808	2026-07-20 09:22:03.794401+00	2026-07-20 09:22:03.794401+00	completed	approved	100	11.50	2026-07-13
1d224113-52fd-42ec-a3d9-ee5e9338d4af	eada99a6-4c95-418c-8fa0-baf7c82570b1	\N	127c1187-f85a-48c8-82b5-451a4ccfeb71	127c1187-f85a-48c8-82b5-451a4ccfeb71	پیاده‌سازی صفحهٔ ورود جدید #35	\N	low	2026-08-28	f8bba7b1-a50e-423c-89c7-eca8b52dab41	2026-07-20 09:22:03.794401+00	2026-07-20 09:22:03.794401+00	completed	pending	100	26.80	2026-08-09
1d224113-52fd-42ec-a3d9-ee5e9338d4af	eada99a6-4c95-418c-8fa0-baf7c82570b1	\N	054f46d3-1cc2-42df-9532-2b310816822b	127c1187-f85a-48c8-82b5-451a4ccfeb71	بهینه‌سازی کوئری‌های گزارش‌گیری #36	\N	medium	2026-06-30	2a3e1131-0ffa-4212-981a-36fed377cda5	2026-07-20 09:22:03.794401+00	2026-07-20 09:22:03.794401+00	todo	\N	62	20.30	2026-06-21
1d224113-52fd-42ec-a3d9-ee5e9338d4af	61c13830-e388-41dc-bb0e-d6b8f1f0d634	\N	6fb1a35d-b064-46b8-8796-54c4fec69d24	127c1187-f85a-48c8-82b5-451a4ccfeb71	بهینه‌سازی کوئری‌های گزارش‌گیری #37	\N	medium	2026-08-15	78d11caa-4c8b-4ee2-bbd7-f40d8f3b4d7e	2026-07-20 09:22:03.794401+00	2026-07-20 09:22:03.794401+00	in_progress	\N	0	39.40	2026-08-12
1d224113-52fd-42ec-a3d9-ee5e9338d4af	61c13830-e388-41dc-bb0e-d6b8f1f0d634	\N	a2c3e527-82e9-4bd2-be63-85f6ead97337	127c1187-f85a-48c8-82b5-451a4ccfeb71	تنظیم پایپ‌لاین CI/CD #38	\N	high	2026-08-18	cb1cbb31-f0a3-4c9b-b75b-682dd1e4530e	2026-07-20 09:22:03.794401+00	2026-07-20 09:22:03.794401+00	completed	approved	100	20.50	2026-07-30
1d224113-52fd-42ec-a3d9-ee5e9338d4af	61c13830-e388-41dc-bb0e-d6b8f1f0d634	\N	0132fd66-319f-4f6e-8e2f-d16328d278e8	127c1187-f85a-48c8-82b5-451a4ccfeb71	پیاده‌سازی صفحهٔ داشبورد مدیریتی #39	\N	high	2026-07-02	c36a827a-f4bb-4a32-822b-97b8adafb475	2026-07-20 09:22:03.794401+00	2026-07-20 09:22:03.794401+00	in_progress	\N	69	4.30	2026-06-29
1d224113-52fd-42ec-a3d9-ee5e9338d4af	61c13830-e388-41dc-bb0e-d6b8f1f0d634	\N	a2c3e527-82e9-4bd2-be63-85f6ead97337	127c1187-f85a-48c8-82b5-451a4ccfeb71	بررسی و رفع آسیب‌پذیری امنیتی #40	\N	high	2026-07-09	2ffb0dc7-c91a-4bb5-8421-4b3ffd9a781e	2026-07-20 09:22:03.794401+00	2026-07-20 09:22:03.794401+00	todo	\N	67	8.00	2026-06-19
1d224113-52fd-42ec-a3d9-ee5e9338d4af	61c13830-e388-41dc-bb0e-d6b8f1f0d634	\N	054f46d3-1cc2-42df-9532-2b310816822b	127c1187-f85a-48c8-82b5-451a4ccfeb71	پیاده‌سازی صفحهٔ ورود جدید #41	\N	high	2026-08-16	1d44bd61-0674-46c9-9362-6233089b7c8a	2026-07-20 09:22:03.794401+00	2026-07-20 09:22:03.794401+00	todo	\N	8	27.70	2026-08-09
1d224113-52fd-42ec-a3d9-ee5e9338d4af	61c13830-e388-41dc-bb0e-d6b8f1f0d634	\N	0132fd66-319f-4f6e-8e2f-d16328d278e8	127c1187-f85a-48c8-82b5-451a4ccfeb71	افزودن تست واحد برای سرویس کاربران #42	\N	high	2026-07-13	69fa38b8-d82c-428f-ae06-c3e1f6949d37	2026-07-20 09:22:03.794401+00	2026-07-20 09:22:03.794401+00	in_progress	\N	76	3.50	2026-06-23
1d224113-52fd-42ec-a3d9-ee5e9338d4af	61c13830-e388-41dc-bb0e-d6b8f1f0d634	\N	127c1187-f85a-48c8-82b5-451a4ccfeb71	127c1187-f85a-48c8-82b5-451a4ccfeb71	پیاده‌سازی صفحهٔ داشبورد مدیریتی #43	\N	high	2026-08-17	9d8626d0-978e-401f-9cd7-2e5e762148ad	2026-07-20 09:22:03.794401+00	2026-07-20 09:22:03.794401+00	in_progress	\N	40	37.50	2026-07-28
1d224113-52fd-42ec-a3d9-ee5e9338d4af	61c13830-e388-41dc-bb0e-d6b8f1f0d634	\N	0132fd66-319f-4f6e-8e2f-d16328d278e8	127c1187-f85a-48c8-82b5-451a4ccfeb71	پیاده‌سازی احراز هویت دومرحله‌ای #44	\N	low	2026-07-11	76a26819-c895-4e37-b047-2785aa508043	2026-07-20 09:22:03.794401+00	2026-07-20 09:22:03.794401+00	completed	pending	100	27.50	2026-07-01
1d224113-52fd-42ec-a3d9-ee5e9338d4af	61c13830-e388-41dc-bb0e-d6b8f1f0d634	\N	a2c3e527-82e9-4bd2-be63-85f6ead97337	127c1187-f85a-48c8-82b5-451a4ccfeb71	رفع باگ در ماژول پرداخت #45	\N	medium	2026-08-07	3a6d8532-f891-48d0-9987-46ae1512bb6f	2026-07-20 09:22:03.794401+00	2026-07-20 09:22:03.794401+00	completed	approved	100	25.60	2026-08-03
1d224113-52fd-42ec-a3d9-ee5e9338d4af	61c13830-e388-41dc-bb0e-d6b8f1f0d634	\N	054f46d3-1cc2-42df-9532-2b310816822b	127c1187-f85a-48c8-82b5-451a4ccfeb71	افزودن تست واحد برای سرویس کاربران #46	\N	high	2026-07-09	9e6d786c-c3d9-4c98-9e3a-dc12f762b402	2026-07-20 09:22:03.794401+00	2026-07-20 09:22:03.794401+00	todo	\N	33	7.00	2026-06-20
1d224113-52fd-42ec-a3d9-ee5e9338d4af	61c13830-e388-41dc-bb0e-d6b8f1f0d634	\N	a2c3e527-82e9-4bd2-be63-85f6ead97337	127c1187-f85a-48c8-82b5-451a4ccfeb71	رفع مشکل کندی بارگذاری صفحه #47	\N	medium	2026-08-20	c5e45e6e-be18-4f34-ad2b-100f4643fa97	2026-07-20 09:22:03.794401+00	2026-07-20 09:22:03.794401+00	todo	\N	20	18.70	2026-08-11
1d224113-52fd-42ec-a3d9-ee5e9338d4af	61c13830-e388-41dc-bb0e-d6b8f1f0d634	\N	054f46d3-1cc2-42df-9532-2b310816822b	127c1187-f85a-48c8-82b5-451a4ccfeb71	رفع مشکل ناسازگاری مرورگر #48	\N	high	2026-07-26	666ed664-0ac2-47e4-927b-316e5ec921e7	2026-07-20 09:22:03.794401+00	2026-07-20 09:22:03.794401+00	archived	\N	67	2.30	2026-07-05
1d224113-52fd-42ec-a3d9-ee5e9338d4af	61c13830-e388-41dc-bb0e-d6b8f1f0d634	\N	6fb1a35d-b064-46b8-8796-54c4fec69d24	127c1187-f85a-48c8-82b5-451a4ccfeb71	افزودن قابلیت جست‌وجوی پیشرفته #49	\N	low	2026-08-02	5b41acf3-ae24-40b3-820e-222b9d85cbef	2026-07-20 09:22:03.794401+00	2026-07-20 09:22:03.794401+00	completed	approved	100	12.00	2026-07-28
1d224113-52fd-42ec-a3d9-ee5e9338d4af	61c13830-e388-41dc-bb0e-d6b8f1f0d634	\N	127c1187-f85a-48c8-82b5-451a4ccfeb71	127c1187-f85a-48c8-82b5-451a4ccfeb71	طراحی API نسخهٔ دوم #50	\N	medium	2026-07-27	e66c9902-38ba-42d3-8a58-f3c53796ceed	2026-07-20 09:22:03.794401+00	2026-07-20 09:22:03.794401+00	archived	\N	77	10.00	2026-07-21
1d224113-52fd-42ec-a3d9-ee5e9338d4af	61c13830-e388-41dc-bb0e-d6b8f1f0d634	\N	a2c3e527-82e9-4bd2-be63-85f6ead97337	127c1187-f85a-48c8-82b5-451a4ccfeb71	به‌روزرسانی کتابخانه‌های وابسته #51	\N	medium	2026-08-08	a4e01e36-47d0-4645-8e9a-8a01e6e480a4	2026-07-20 09:22:03.794401+00	2026-07-20 09:22:03.794401+00	in_progress	\N	32	36.40	2026-07-29
1d224113-52fd-42ec-a3d9-ee5e9338d4af	61c13830-e388-41dc-bb0e-d6b8f1f0d634	\N	6fb1a35d-b064-46b8-8796-54c4fec69d24	127c1187-f85a-48c8-82b5-451a4ccfeb71	بازنویسی ماژول اعلان‌ها #52	\N	medium	2026-07-06	73db901b-4ba5-4474-8824-2b3278c7f47c	2026-07-20 09:22:03.794401+00	2026-07-20 09:22:03.794401+00	todo	\N	5	2.10	2026-06-21
1d224113-52fd-42ec-a3d9-ee5e9338d4af	61c13830-e388-41dc-bb0e-d6b8f1f0d634	\N	6fb1a35d-b064-46b8-8796-54c4fec69d24	127c1187-f85a-48c8-82b5-451a4ccfeb71	بهینه‌سازی کوئری‌های گزارش‌گیری #53	\N	high	2026-08-05	3c635e6f-822b-4980-abce-abaa5bb8434c	2026-07-20 09:22:03.794401+00	2026-07-20 09:22:03.794401+00	todo	\N	56	23.00	2026-07-26
1d224113-52fd-42ec-a3d9-ee5e9338d4af	61c13830-e388-41dc-bb0e-d6b8f1f0d634	\N	f4e6dc2a-b9f2-43e2-8db1-3516a3e2985c	127c1187-f85a-48c8-82b5-451a4ccfeb71	به‌روزرسانی کتابخانه‌های وابسته #54	\N	low	2026-06-26	a52a2543-71a2-48bb-8bdf-73ff1a00935d	2026-07-20 09:22:03.794401+00	2026-07-20 09:22:03.794401+00	completed	approved	100	33.70	2026-06-20
1d224113-52fd-42ec-a3d9-ee5e9338d4af	91889926-2b3f-4643-8d23-0cd8a3d96488	\N	054f46d3-1cc2-42df-9532-2b310816822b	127c1187-f85a-48c8-82b5-451a4ccfeb71	طراحی API نسخهٔ دوم #55	\N	medium	2026-06-27	13180638-5211-4296-81b6-941a824e6d22	2026-07-20 09:22:03.794401+00	2026-07-20 09:22:03.794401+00	completed	approved	100	36.20	2026-06-24
1d224113-52fd-42ec-a3d9-ee5e9338d4af	91889926-2b3f-4643-8d23-0cd8a3d96488	\N	6fb1a35d-b064-46b8-8796-54c4fec69d24	127c1187-f85a-48c8-82b5-451a4ccfeb71	افزودن تست واحد برای سرویس کاربران #56	\N	high	2026-08-25	5e0ff624-846f-4262-9d28-c49ea158c7ee	2026-07-20 09:22:03.794401+00	2026-07-20 09:22:03.794401+00	todo	\N	31	27.30	2026-08-12
1d224113-52fd-42ec-a3d9-ee5e9338d4af	91889926-2b3f-4643-8d23-0cd8a3d96488	\N	a2c3e527-82e9-4bd2-be63-85f6ead97337	127c1187-f85a-48c8-82b5-451a4ccfeb71	پیاده‌سازی صفحهٔ داشبورد مدیریتی #57	\N	high	2026-08-05	d728f270-4ecb-428f-ac7c-68090153e516	2026-07-20 09:22:03.794401+00	2026-07-20 09:22:03.794401+00	archived	\N	19	37.20	2026-07-21
1d224113-52fd-42ec-a3d9-ee5e9338d4af	91889926-2b3f-4643-8d23-0cd8a3d96488	\N	0132fd66-319f-4f6e-8e2f-d16328d278e8	127c1187-f85a-48c8-82b5-451a4ccfeb71	افزودن قابلیت جست‌وجوی پیشرفته #58	\N	medium	2026-08-13	7dca4fea-4d9b-4b8f-b4bc-46e9eaf4ba39	2026-07-20 09:22:03.794401+00	2026-07-20 09:22:03.794401+00	todo	\N	3	8.80	2026-08-06
1d224113-52fd-42ec-a3d9-ee5e9338d4af	91889926-2b3f-4643-8d23-0cd8a3d96488	\N	a2c3e527-82e9-4bd2-be63-85f6ead97337	127c1187-f85a-48c8-82b5-451a4ccfeb71	طراحی API نسخهٔ دوم #59	\N	low	2026-08-15	2380c0c3-19ca-4f86-94b6-882ad9eda0c5	2026-07-20 09:22:03.794401+00	2026-07-20 09:22:03.794401+00	in_progress	\N	13	16.50	2026-08-06
1d224113-52fd-42ec-a3d9-ee5e9338d4af	91889926-2b3f-4643-8d23-0cd8a3d96488	\N	127c1187-f85a-48c8-82b5-451a4ccfeb71	127c1187-f85a-48c8-82b5-451a4ccfeb71	رفع مشکل کندی بارگذاری صفحه #60	\N	medium	2026-08-23	73da703c-e8e2-4f27-a10e-7da5eaf830b8	2026-07-20 09:22:03.794401+00	2026-07-20 09:22:03.794401+00	completed	approved	100	33.20	2026-08-07
1d224113-52fd-42ec-a3d9-ee5e9338d4af	91889926-2b3f-4643-8d23-0cd8a3d96488	\N	6fb1a35d-b064-46b8-8796-54c4fec69d24	127c1187-f85a-48c8-82b5-451a4ccfeb71	تنظیم پایپ‌لاین CI/CD #61	\N	low	2026-07-02	e245fd9f-8a19-428a-b04e-2565f3013906	2026-07-20 09:22:03.794401+00	2026-07-20 09:22:03.794401+00	in_progress	\N	51	14.50	2026-06-30
1d224113-52fd-42ec-a3d9-ee5e9338d4af	91889926-2b3f-4643-8d23-0cd8a3d96488	\N	6fb1a35d-b064-46b8-8796-54c4fec69d24	127c1187-f85a-48c8-82b5-451a4ccfeb71	رفع مشکل کندی بارگذاری صفحه #62	\N	high	2026-08-14	db55139b-946a-4d9f-9557-543e66f6ce41	2026-07-20 09:22:03.794401+00	2026-07-20 09:22:03.794401+00	todo	\N	65	17.20	2026-08-04
1d224113-52fd-42ec-a3d9-ee5e9338d4af	91889926-2b3f-4643-8d23-0cd8a3d96488	\N	6fb1a35d-b064-46b8-8796-54c4fec69d24	127c1187-f85a-48c8-82b5-451a4ccfeb71	افزودن قابلیت جست‌وجوی پیشرفته #63	\N	medium	2026-06-22	5be3ddde-0b79-47fe-bdc6-b79ea02b118b	2026-07-20 09:22:03.794401+00	2026-07-20 09:22:03.794401+00	completed	approved	100	8.80	2026-06-17
1d224113-52fd-42ec-a3d9-ee5e9338d4af	91889926-2b3f-4643-8d23-0cd8a3d96488	\N	a2c3e527-82e9-4bd2-be63-85f6ead97337	127c1187-f85a-48c8-82b5-451a4ccfeb71	پیاده‌سازی احراز هویت دومرحله‌ای #64	\N	medium	2026-07-13	a7239c5a-0056-4d2b-8edb-5622952e1694	2026-07-20 09:22:03.794401+00	2026-07-20 09:22:03.794401+00	todo	\N	40	18.60	2026-06-22
1d224113-52fd-42ec-a3d9-ee5e9338d4af	91889926-2b3f-4643-8d23-0cd8a3d96488	\N	054f46d3-1cc2-42df-9532-2b310816822b	127c1187-f85a-48c8-82b5-451a4ccfeb71	افزودن تست واحد برای سرویس کاربران #65	\N	medium	2026-07-30	43da6465-f2ca-4d09-9285-08673f74d5a6	2026-07-20 09:22:03.794401+00	2026-07-20 09:22:03.794401+00	todo	\N	5	28.90	2026-07-10
1d224113-52fd-42ec-a3d9-ee5e9338d4af	91889926-2b3f-4643-8d23-0cd8a3d96488	\N	127c1187-f85a-48c8-82b5-451a4ccfeb71	127c1187-f85a-48c8-82b5-451a4ccfeb71	رفع مشکل کندی بارگذاری صفحه #66	\N	medium	2026-07-28	ff44c3c7-aaa6-4553-9f2d-636394be7ab5	2026-07-20 09:22:03.794401+00	2026-07-20 09:22:03.794401+00	completed	rejected	100	4.70	2026-07-20
1d224113-52fd-42ec-a3d9-ee5e9338d4af	91889926-2b3f-4643-8d23-0cd8a3d96488	\N	3940e09c-eede-4772-818b-3a4bc4703195	127c1187-f85a-48c8-82b5-451a4ccfeb71	تنظیم پایپ‌لاین CI/CD #67	\N	low	2026-08-06	c8831502-fdef-4eb3-950e-83b2a8ca3aa6	2026-07-20 09:22:03.794401+00	2026-07-20 09:22:03.794401+00	in_progress	\N	38	21.30	2026-07-25
1d224113-52fd-42ec-a3d9-ee5e9338d4af	91889926-2b3f-4643-8d23-0cd8a3d96488	\N	3940e09c-eede-4772-818b-3a4bc4703195	127c1187-f85a-48c8-82b5-451a4ccfeb71	نوشتن مستندات فنی API #68	\N	medium	2026-07-20	627590b0-ad03-4543-a950-37cf4b8300ac	2026-07-20 09:22:03.794401+00	2026-07-20 09:22:03.794401+00	in_progress	\N	70	6.80	2026-07-06
1d224113-52fd-42ec-a3d9-ee5e9338d4af	91889926-2b3f-4643-8d23-0cd8a3d96488	\N	f4e6dc2a-b9f2-43e2-8db1-3516a3e2985c	127c1187-f85a-48c8-82b5-451a4ccfeb71	پیاده‌سازی صفحهٔ داشبورد مدیریتی #69	\N	high	2026-08-05	eb4c8dae-7381-4ddc-8126-a269eca1df6b	2026-07-20 09:22:03.794401+00	2026-07-20 09:22:03.794401+00	completed	rejected	100	13.40	2026-07-29
1d224113-52fd-42ec-a3d9-ee5e9338d4af	91889926-2b3f-4643-8d23-0cd8a3d96488	\N	054f46d3-1cc2-42df-9532-2b310816822b	127c1187-f85a-48c8-82b5-451a4ccfeb71	افزودن تست واحد برای سرویس کاربران #70	\N	medium	2026-07-16	8bc087a3-1d7c-4eb5-8659-f07cc4795460	2026-07-20 09:22:03.794401+00	2026-07-20 09:22:03.794401+00	todo	\N	74	25.10	2026-07-05
1d224113-52fd-42ec-a3d9-ee5e9338d4af	91889926-2b3f-4643-8d23-0cd8a3d96488	\N	a2c3e527-82e9-4bd2-be63-85f6ead97337	127c1187-f85a-48c8-82b5-451a4ccfeb71	به‌روزرسانی کتابخانه‌های وابسته #71	\N	medium	2026-08-06	efa97bec-f422-4b7a-a7d3-beb135cef3b7	2026-07-20 09:22:03.794401+00	2026-07-20 09:22:03.794401+00	completed	approved	100	32.20	2026-07-29
1d224113-52fd-42ec-a3d9-ee5e9338d4af	91889926-2b3f-4643-8d23-0cd8a3d96488	\N	6fb1a35d-b064-46b8-8796-54c4fec69d24	127c1187-f85a-48c8-82b5-451a4ccfeb71	طراحی API نسخهٔ دوم #72	\N	high	2026-06-30	893b4ac1-d92b-42b8-92f4-15b3e3483fb7	2026-07-20 09:22:03.794401+00	2026-07-20 09:22:03.794401+00	archived	\N	79	14.70	2026-06-26
1d224113-52fd-42ec-a3d9-ee5e9338d4af	d86107c2-52f7-48ef-847b-f82fecf566dd	\N	6fb1a35d-b064-46b8-8796-54c4fec69d24	127c1187-f85a-48c8-82b5-451a4ccfeb71	افزودن تست واحد برای سرویس کاربران #73	\N	low	2026-07-12	ade728f1-210b-4ecd-9741-37bd928aea54	2026-07-20 09:22:03.794401+00	2026-07-20 09:22:03.794401+00	archived	\N	18	2.90	2026-07-01
1d224113-52fd-42ec-a3d9-ee5e9338d4af	d86107c2-52f7-48ef-847b-f82fecf566dd	\N	0132fd66-319f-4f6e-8e2f-d16328d278e8	127c1187-f85a-48c8-82b5-451a4ccfeb71	بررسی و رفع آسیب‌پذیری امنیتی #74	\N	medium	2026-08-08	cc7ddcbe-ed8a-4da8-bf95-d047557671d1	2026-07-20 09:22:03.794401+00	2026-07-20 09:22:03.794401+00	completed	pending	100	35.70	2026-08-04
1d224113-52fd-42ec-a3d9-ee5e9338d4af	d86107c2-52f7-48ef-847b-f82fecf566dd	\N	054f46d3-1cc2-42df-9532-2b310816822b	127c1187-f85a-48c8-82b5-451a4ccfeb71	بررسی و رفع آسیب‌پذیری امنیتی #75	\N	medium	2026-08-14	9e097f6c-08bb-45dc-967d-a43f655f45bc	2026-07-20 09:22:03.794401+00	2026-07-20 09:22:03.794401+00	todo	\N	31	7.60	2026-07-31
1d224113-52fd-42ec-a3d9-ee5e9338d4af	d86107c2-52f7-48ef-847b-f82fecf566dd	\N	3940e09c-eede-4772-818b-3a4bc4703195	127c1187-f85a-48c8-82b5-451a4ccfeb71	رفع مشکل ناسازگاری مرورگر #76	\N	medium	2026-08-17	c84db642-a9a8-4790-93d7-5cf8240343ab	2026-07-20 09:22:03.794401+00	2026-07-20 09:22:03.794401+00	todo	\N	28	8.70	2026-08-12
1d224113-52fd-42ec-a3d9-ee5e9338d4af	d86107c2-52f7-48ef-847b-f82fecf566dd	\N	3940e09c-eede-4772-818b-3a4bc4703195	127c1187-f85a-48c8-82b5-451a4ccfeb71	افزودن قابلیت جست‌وجوی پیشرفته #77	\N	low	2026-07-30	d81eb2c6-c137-4cb4-abde-6940ceed9c29	2026-07-20 09:22:03.794401+00	2026-07-20 09:22:03.794401+00	completed	approved	100	19.30	2026-07-21
1d224113-52fd-42ec-a3d9-ee5e9338d4af	d86107c2-52f7-48ef-847b-f82fecf566dd	\N	6fb1a35d-b064-46b8-8796-54c4fec69d24	127c1187-f85a-48c8-82b5-451a4ccfeb71	رفع مشکل کندی بارگذاری صفحه #78	\N	medium	2026-08-11	9f846574-246e-4b90-aa31-33d534acbca8	2026-07-20 09:22:03.794401+00	2026-07-20 09:22:03.794401+00	completed	pending	100	25.30	2026-07-21
1d224113-52fd-42ec-a3d9-ee5e9338d4af	d86107c2-52f7-48ef-847b-f82fecf566dd	\N	3940e09c-eede-4772-818b-3a4bc4703195	127c1187-f85a-48c8-82b5-451a4ccfeb71	بررسی و رفع آسیب‌پذیری امنیتی #79	\N	low	2026-09-01	9000951f-4371-4f55-be51-eea18f121902	2026-07-20 09:22:03.794401+00	2026-07-20 09:22:03.794401+00	completed	approved	100	30.30	2026-08-13
1d224113-52fd-42ec-a3d9-ee5e9338d4af	d86107c2-52f7-48ef-847b-f82fecf566dd	\N	f4e6dc2a-b9f2-43e2-8db1-3516a3e2985c	127c1187-f85a-48c8-82b5-451a4ccfeb71	رفع مشکل ناسازگاری مرورگر #80	\N	high	2026-07-11	8bd308a6-b86d-4aa5-bb44-66cae32fbeac	2026-07-20 09:22:03.794401+00	2026-07-20 09:22:03.794401+00	completed	approved	100	20.40	2026-07-01
1d224113-52fd-42ec-a3d9-ee5e9338d4af	d86107c2-52f7-48ef-847b-f82fecf566dd	\N	0132fd66-319f-4f6e-8e2f-d16328d278e8	127c1187-f85a-48c8-82b5-451a4ccfeb71	نوشتن مستندات فنی API #81	\N	medium	2026-07-18	c4afd6ed-87c6-4942-9faf-19a578182a44	2026-07-20 09:22:03.794401+00	2026-07-20 09:22:03.794401+00	in_progress	\N	30	12.30	2026-07-14
1d224113-52fd-42ec-a3d9-ee5e9338d4af	d86107c2-52f7-48ef-847b-f82fecf566dd	\N	a2c3e527-82e9-4bd2-be63-85f6ead97337	127c1187-f85a-48c8-82b5-451a4ccfeb71	پیاده‌سازی احراز هویت دومرحله‌ای #82	\N	high	2026-07-04	0712063f-4808-43fd-8f3a-64af3b639ebc	2026-07-20 09:22:03.794401+00	2026-07-20 09:22:03.794401+00	completed	approved	100	7.80	2026-06-25
1d224113-52fd-42ec-a3d9-ee5e9338d4af	d86107c2-52f7-48ef-847b-f82fecf566dd	\N	0132fd66-319f-4f6e-8e2f-d16328d278e8	127c1187-f85a-48c8-82b5-451a4ccfeb71	رفع مشکل کندی بارگذاری صفحه #83	\N	high	2026-07-27	77ad1f54-817b-481f-8942-8b2c4bb5f6be	2026-07-20 09:22:03.794401+00	2026-07-20 09:22:03.794401+00	todo	\N	59	17.80	2026-07-12
1d224113-52fd-42ec-a3d9-ee5e9338d4af	d86107c2-52f7-48ef-847b-f82fecf566dd	\N	0132fd66-319f-4f6e-8e2f-d16328d278e8	127c1187-f85a-48c8-82b5-451a4ccfeb71	نوشتن مستندات فنی API #84	\N	low	2026-07-30	768df0d7-0482-4240-8e0e-ae107442d16c	2026-07-20 09:22:03.794401+00	2026-07-20 09:22:03.794401+00	in_progress	\N	73	16.50	2026-07-10
1d224113-52fd-42ec-a3d9-ee5e9338d4af	d86107c2-52f7-48ef-847b-f82fecf566dd	\N	127c1187-f85a-48c8-82b5-451a4ccfeb71	127c1187-f85a-48c8-82b5-451a4ccfeb71	بازنویسی ماژول اعلان‌ها #85	\N	medium	2026-07-19	5def895f-add8-4176-8acd-841ae92a81f7	2026-07-20 09:22:03.794401+00	2026-07-20 09:22:03.794401+00	in_progress	\N	68	30.40	2026-07-05
1d224113-52fd-42ec-a3d9-ee5e9338d4af	d86107c2-52f7-48ef-847b-f82fecf566dd	\N	054f46d3-1cc2-42df-9532-2b310816822b	127c1187-f85a-48c8-82b5-451a4ccfeb71	طراحی API نسخهٔ دوم #86	\N	medium	2026-07-26	4fb331b3-4777-4875-a846-e46cdf4d2f8c	2026-07-20 09:22:03.794401+00	2026-07-20 09:22:03.794401+00	completed	pending	100	20.50	2026-07-17
1d224113-52fd-42ec-a3d9-ee5e9338d4af	d86107c2-52f7-48ef-847b-f82fecf566dd	\N	f4e6dc2a-b9f2-43e2-8db1-3516a3e2985c	127c1187-f85a-48c8-82b5-451a4ccfeb71	نوشتن مستندات فنی API #87	\N	low	2026-08-11	69de88d8-c9e5-471a-b8e3-fdd25188a3b2	2026-07-20 09:22:03.794401+00	2026-07-20 09:22:03.794401+00	in_progress	\N	59	36.90	2026-07-28
1d224113-52fd-42ec-a3d9-ee5e9338d4af	d86107c2-52f7-48ef-847b-f82fecf566dd	\N	054f46d3-1cc2-42df-9532-2b310816822b	127c1187-f85a-48c8-82b5-451a4ccfeb71	پیاده‌سازی صفحهٔ داشبورد مدیریتی #88	\N	high	2026-07-31	176c85d9-b9f2-44bc-9a7b-3512715dd08d	2026-07-20 09:22:03.794401+00	2026-07-20 09:22:03.794401+00	completed	approved	100	3.00	2026-07-11
1d224113-52fd-42ec-a3d9-ee5e9338d4af	d86107c2-52f7-48ef-847b-f82fecf566dd	\N	3940e09c-eede-4772-818b-3a4bc4703195	127c1187-f85a-48c8-82b5-451a4ccfeb71	بهینه‌سازی کوئری‌های گزارش‌گیری #89	\N	low	2026-07-10	69265e2f-e932-47e5-afdd-4a458397d29a	2026-07-20 09:22:03.794401+00	2026-07-20 09:22:03.794401+00	in_progress	\N	33	16.40	2026-06-24
1d224113-52fd-42ec-a3d9-ee5e9338d4af	d86107c2-52f7-48ef-847b-f82fecf566dd	\N	0132fd66-319f-4f6e-8e2f-d16328d278e8	127c1187-f85a-48c8-82b5-451a4ccfeb71	طراحی API نسخهٔ دوم #90	\N	medium	2026-08-17	f33ec0ad-eb35-47ba-abe6-9b0ffbac9c39	2026-07-20 09:22:03.794401+00	2026-07-20 09:22:03.794401+00	completed	approved	100	11.60	2026-08-03
1d224113-52fd-42ec-a3d9-ee5e9338d4af	\N	\N	127c1187-f85a-48c8-82b5-451a4ccfeb71	127c1187-f85a-48c8-82b5-451a4ccfeb71	رفع مشکل کندی بارگذاری صفحه #91	\N	low	2026-07-23	1f69e85f-dfe1-4b9c-9ce6-2008357e4d3f	2026-07-20 09:22:03.794401+00	2026-07-20 09:22:03.794401+00	completed	approved	100	26.70	2026-07-20
1d224113-52fd-42ec-a3d9-ee5e9338d4af	\N	\N	6fb1a35d-b064-46b8-8796-54c4fec69d24	6fb1a35d-b064-46b8-8796-54c4fec69d24	افزودن تست واحد برای سرویس کاربران #92	\N	low	2026-06-26	b747d1a4-03ed-4dcf-9bab-0b8dc42937eb	2026-07-20 09:22:03.794401+00	2026-07-20 09:22:03.794401+00	completed	approved	100	25.60	2026-06-17
1d224113-52fd-42ec-a3d9-ee5e9338d4af	\N	\N	0132fd66-319f-4f6e-8e2f-d16328d278e8	0132fd66-319f-4f6e-8e2f-d16328d278e8	پیاده‌سازی صفحهٔ داشبورد مدیریتی #93	\N	low	2026-07-21	1174c520-add2-403d-99b5-b23d5c105a41	2026-07-20 09:22:03.794401+00	2026-07-20 09:22:03.794401+00	todo	\N	59	28.60	2026-07-16
1d224113-52fd-42ec-a3d9-ee5e9338d4af	\N	\N	6fb1a35d-b064-46b8-8796-54c4fec69d24	6fb1a35d-b064-46b8-8796-54c4fec69d24	پیاده‌سازی صفحهٔ داشبورد مدیریتی #94	\N	high	2026-07-17	5537ca85-4d6e-480e-9feb-c366761e62ca	2026-07-20 09:22:03.794401+00	2026-07-20 09:22:03.794401+00	in_progress	\N	14	31.60	2026-06-26
1d224113-52fd-42ec-a3d9-ee5e9338d4af	\N	\N	0132fd66-319f-4f6e-8e2f-d16328d278e8	0132fd66-319f-4f6e-8e2f-d16328d278e8	رفع باگ در ماژول پرداخت #95	\N	medium	2026-07-12	b6176adb-0e1a-4ef4-84a7-bff422ecf92e	2026-07-20 09:22:03.794401+00	2026-07-20 09:22:03.794401+00	in_progress	\N	73	27.70	2026-06-22
1d224113-52fd-42ec-a3d9-ee5e9338d4af	\N	\N	f4e6dc2a-b9f2-43e2-8db1-3516a3e2985c	f4e6dc2a-b9f2-43e2-8db1-3516a3e2985c	پیاده‌سازی صفحهٔ ورود جدید #96	\N	high	2026-08-23	1fd5e3b7-ef00-4c2b-81d7-524e9571836d	2026-07-20 09:22:03.794401+00	2026-07-20 09:22:03.794401+00	in_progress	\N	80	11.20	2026-08-15
1d224113-52fd-42ec-a3d9-ee5e9338d4af	\N	\N	3940e09c-eede-4772-818b-3a4bc4703195	3940e09c-eede-4772-818b-3a4bc4703195	رفع مشکل ناسازگاری مرورگر #97	\N	low	2026-07-26	62519614-e8b3-4332-86df-f81c95854780	2026-07-20 09:22:03.794401+00	2026-07-20 09:22:03.794401+00	archived	\N	72	31.70	2026-07-05
1d224113-52fd-42ec-a3d9-ee5e9338d4af	\N	\N	a2c3e527-82e9-4bd2-be63-85f6ead97337	a2c3e527-82e9-4bd2-be63-85f6ead97337	به‌روزرسانی کتابخانه‌های وابسته #98	\N	high	2026-07-13	ebc86503-f045-485d-acb2-b0f17e987865	2026-07-20 09:22:03.794401+00	2026-07-20 09:22:03.794401+00	completed	approved	100	15.00	2026-07-09
1d224113-52fd-42ec-a3d9-ee5e9338d4af	\N	\N	6fb1a35d-b064-46b8-8796-54c4fec69d24	6fb1a35d-b064-46b8-8796-54c4fec69d24	پیاده‌سازی صفحهٔ ورود جدید #99	\N	medium	2026-08-24	83b66213-b1a7-4ded-bfea-dedf5bfd0643	2026-07-20 09:22:03.794401+00	2026-07-20 09:22:03.794401+00	in_progress	\N	46	26.20	2026-08-07
1d224113-52fd-42ec-a3d9-ee5e9338d4af	\N	\N	6fb1a35d-b064-46b8-8796-54c4fec69d24	6fb1a35d-b064-46b8-8796-54c4fec69d24	نوشتن مستندات فنی API #100	\N	high	2026-07-20	d5848785-9c0a-4f11-b0c5-2ead6e842227	2026-07-20 09:22:03.794401+00	2026-07-20 09:22:03.794401+00	completed	pending	100	38.70	2026-07-13
1d224113-52fd-42ec-a3d9-ee5e9338d4af	\N	\N	a2c3e527-82e9-4bd2-be63-85f6ead97337	a2c3e527-82e9-4bd2-be63-85f6ead97337	بررسی و رفع آسیب‌پذیری امنیتی #101	\N	medium	2026-08-06	f475596b-8092-4b2c-a037-66b2466e6d09	2026-07-20 09:22:03.794401+00	2026-07-20 09:22:03.794401+00	completed	pending	100	33.40	2026-07-20
1d224113-52fd-42ec-a3d9-ee5e9338d4af	\N	\N	054f46d3-1cc2-42df-9532-2b310816822b	054f46d3-1cc2-42df-9532-2b310816822b	بازنویسی ماژول اعلان‌ها #102	\N	low	2026-07-15	a0f199b6-bd51-4957-8ccc-92700629b06c	2026-07-20 09:22:03.794401+00	2026-07-20 09:22:03.794401+00	in_progress	\N	35	35.50	2026-07-06
1d224113-52fd-42ec-a3d9-ee5e9338d4af	\N	\N	0132fd66-319f-4f6e-8e2f-d16328d278e8	0132fd66-319f-4f6e-8e2f-d16328d278e8	پیاده‌سازی صفحهٔ داشبورد مدیریتی #103	\N	high	2026-08-04	c441efdf-bbcd-4dae-b2b8-26d2a716ab17	2026-07-20 09:22:03.794401+00	2026-07-20 09:22:03.794401+00	archived	\N	48	14.80	2026-07-15
1d224113-52fd-42ec-a3d9-ee5e9338d4af	\N	\N	f4e6dc2a-b9f2-43e2-8db1-3516a3e2985c	f4e6dc2a-b9f2-43e2-8db1-3516a3e2985c	افزودن تست واحد برای سرویس کاربران #104	\N	medium	2026-07-14	eb82fb3a-460b-4573-9812-54361eb9bb74	2026-07-20 09:22:03.794401+00	2026-07-20 09:22:03.794401+00	in_progress	\N	33	14.90	2026-06-27
1d224113-52fd-42ec-a3d9-ee5e9338d4af	\N	\N	054f46d3-1cc2-42df-9532-2b310816822b	054f46d3-1cc2-42df-9532-2b310816822b	به‌روزرسانی کتابخانه‌های وابسته #105	\N	low	2026-07-23	11bf3e6f-8695-4755-9751-68b6afc7a19b	2026-07-20 09:22:03.794401+00	2026-07-20 09:22:03.794401+00	completed	pending	100	5.30	2026-07-21
1d224113-52fd-42ec-a3d9-ee5e9338d4af	58a3e39a-4d3f-4eeb-bf3e-fbf3ae866a53	\N	1fd4dffb-d8db-4387-914a-be2a2a6fd6b1	b3e7b1f6-d818-46bc-a98e-9f7048e16f8f	بررسی قراردادهای مالی جدید #1	\N	medium	2026-08-18	6db1c06c-9fde-4b8f-8197-01a04f12ad46	2026-07-20 09:22:03.794401+00	2026-07-20 09:22:03.794401+00	in_progress	\N	43	39.00	2026-08-02
1d224113-52fd-42ec-a3d9-ee5e9338d4af	58a3e39a-4d3f-4eeb-bf3e-fbf3ae866a53	\N	1fd4dffb-d8db-4387-914a-be2a2a6fd6b1	b3e7b1f6-d818-46bc-a98e-9f7048e16f8f	پیگیری مطالبات معوق مشتریان #2	\N	low	2026-09-01	10dcb8a8-1407-494c-8331-a090f11dd64e	2026-07-20 09:22:03.794401+00	2026-07-20 09:22:03.794401+00	completed	approved	100	29.60	2026-08-14
1d224113-52fd-42ec-a3d9-ee5e9338d4af	58a3e39a-4d3f-4eeb-bf3e-fbf3ae866a53	\N	b3e7b1f6-d818-46bc-a98e-9f7048e16f8f	b3e7b1f6-d818-46bc-a98e-9f7048e16f8f	تهیهٔ پیش‌نویس بودجهٔ واحد #3	\N	medium	2026-08-14	2b3ed621-e0ec-4cbf-b5c5-0607d2e5ee16	2026-07-20 09:22:03.794401+00	2026-07-20 09:22:03.794401+00	completed	pending	100	14.20	2026-08-07
1d224113-52fd-42ec-a3d9-ee5e9338d4af	58a3e39a-4d3f-4eeb-bf3e-fbf3ae866a53	\N	b3e7b1f6-d818-46bc-a98e-9f7048e16f8f	b3e7b1f6-d818-46bc-a98e-9f7048e16f8f	پیگیری مطالبات معوق مشتریان #4	\N	medium	2026-08-08	01789686-8935-49fd-be65-e81f1cbf8cfe	2026-07-20 09:22:03.794401+00	2026-07-20 09:22:03.794401+00	in_progress	\N	77	29.30	2026-07-28
1d224113-52fd-42ec-a3d9-ee5e9338d4af	58a3e39a-4d3f-4eeb-bf3e-fbf3ae866a53	\N	1bd96f4a-6acb-4464-8452-ca1d3114a328	b3e7b1f6-d818-46bc-a98e-9f7048e16f8f	تهیهٔ گزارش جریان نقدی #5	\N	medium	2026-07-17	1b9015fe-8f2d-48ec-ba19-68e9b51d02c6	2026-07-20 09:22:03.794401+00	2026-07-20 09:22:03.794401+00	completed	approved	100	25.40	2026-07-14
1d224113-52fd-42ec-a3d9-ee5e9338d4af	58a3e39a-4d3f-4eeb-bf3e-fbf3ae866a53	\N	1fd4dffb-d8db-4387-914a-be2a2a6fd6b1	b3e7b1f6-d818-46bc-a98e-9f7048e16f8f	تهیهٔ گزارش سود و زیان ماهانه #6	\N	high	2026-07-29	a795886c-f9f8-40af-a2cf-5f024439e800	2026-07-20 09:22:03.794401+00	2026-07-20 09:22:03.794401+00	in_progress	\N	51	15.80	2026-07-26
1d224113-52fd-42ec-a3d9-ee5e9338d4af	58a3e39a-4d3f-4eeb-bf3e-fbf3ae866a53	\N	03c131a9-29b0-4e66-8d67-be78cfa01885	b3e7b1f6-d818-46bc-a98e-9f7048e16f8f	بررسی و تأیید صورت‌حساب‌های خرید #7	\N	low	2026-08-05	75c8d753-c02e-46b3-9fff-fa9caea96566	2026-07-20 09:22:03.794401+00	2026-07-20 09:22:03.794401+00	archived	\N	77	27.80	2026-07-29
1d224113-52fd-42ec-a3d9-ee5e9338d4af	58a3e39a-4d3f-4eeb-bf3e-fbf3ae866a53	\N	1fd4dffb-d8db-4387-914a-be2a2a6fd6b1	b3e7b1f6-d818-46bc-a98e-9f7048e16f8f	ثبت اسناد حسابداری هفتگی #8	\N	high	2026-06-28	74ad957b-781b-40c3-baac-cfd3d0fba7d2	2026-07-20 09:22:03.794401+00	2026-07-20 09:22:03.794401+00	todo	\N	46	15.80	2026-06-24
1d224113-52fd-42ec-a3d9-ee5e9338d4af	58a3e39a-4d3f-4eeb-bf3e-fbf3ae866a53	\N	b720465e-b31b-4b9b-99d6-b303ca5f639d	b3e7b1f6-d818-46bc-a98e-9f7048e16f8f	تطبیق موجودی انبار با حساب‌ها #9	\N	medium	2026-07-30	9a73356f-cc88-402b-a33c-73a8c148729f	2026-07-20 09:22:03.794401+00	2026-07-20 09:22:03.794401+00	todo	\N	47	16.10	2026-07-24
1d224113-52fd-42ec-a3d9-ee5e9338d4af	58a3e39a-4d3f-4eeb-bf3e-fbf3ae866a53	\N	03c131a9-29b0-4e66-8d67-be78cfa01885	b3e7b1f6-d818-46bc-a98e-9f7048e16f8f	تهیهٔ پیش‌نویس بودجهٔ واحد #10	\N	medium	2026-07-28	d860af1f-9379-4786-97dd-f45eb0629994	2026-07-20 09:22:03.794401+00	2026-07-20 09:22:03.794401+00	todo	\N	50	13.90	2026-07-22
1d224113-52fd-42ec-a3d9-ee5e9338d4af	58a3e39a-4d3f-4eeb-bf3e-fbf3ae866a53	\N	8cca3fcf-f7a7-421a-b9a4-5dab90fe1b83	b3e7b1f6-d818-46bc-a98e-9f7048e16f8f	تهیهٔ گزارش جریان نقدی #11	\N	low	2026-06-25	ee655062-7021-435f-8af4-d3402372365e	2026-07-20 09:22:03.794401+00	2026-07-20 09:22:03.794401+00	in_progress	\N	63	21.70	2026-06-23
1d224113-52fd-42ec-a3d9-ee5e9338d4af	58a3e39a-4d3f-4eeb-bf3e-fbf3ae866a53	\N	b720465e-b31b-4b9b-99d6-b303ca5f639d	b3e7b1f6-d818-46bc-a98e-9f7048e16f8f	تهیهٔ گزارش جریان نقدی #12	\N	medium	2026-07-12	e174ec72-3ef4-4a3d-8dc2-b8aa56e5091d	2026-07-20 09:22:03.794401+00	2026-07-20 09:22:03.794401+00	todo	\N	27	39.90	2026-07-02
1d224113-52fd-42ec-a3d9-ee5e9338d4af	58a3e39a-4d3f-4eeb-bf3e-fbf3ae866a53	\N	8cca3fcf-f7a7-421a-b9a4-5dab90fe1b83	b3e7b1f6-d818-46bc-a98e-9f7048e16f8f	تهیهٔ گزارش سود و زیان ماهانه #13	\N	low	2026-07-25	7ae62839-3b23-4f35-9515-facb01064d2c	2026-07-20 09:22:03.794401+00	2026-07-20 09:22:03.794401+00	completed	rejected	100	34.40	2026-07-17
1d224113-52fd-42ec-a3d9-ee5e9338d4af	58a3e39a-4d3f-4eeb-bf3e-fbf3ae866a53	\N	1fd4dffb-d8db-4387-914a-be2a2a6fd6b1	b3e7b1f6-d818-46bc-a98e-9f7048e16f8f	تهیهٔ گزارش سود و زیان ماهانه #14	\N	high	2026-08-28	c38b027d-2e9a-4e98-80c5-9d583007adf2	2026-07-20 09:22:03.794401+00	2026-07-20 09:22:03.794401+00	todo	\N	40	27.40	2026-08-12
1d224113-52fd-42ec-a3d9-ee5e9338d4af	58a3e39a-4d3f-4eeb-bf3e-fbf3ae866a53	\N	8a6bd071-9f82-4273-b101-9c763d6c4be4	b3e7b1f6-d818-46bc-a98e-9f7048e16f8f	پیگیری مطالبات معوق مشتریان #15	\N	medium	2026-08-09	140dc9f0-da83-4866-ae13-8c6fc4e25931	2026-07-20 09:22:03.794401+00	2026-07-20 09:22:03.794401+00	todo	\N	20	29.00	2026-07-21
1d224113-52fd-42ec-a3d9-ee5e9338d4af	58a3e39a-4d3f-4eeb-bf3e-fbf3ae866a53	\N	8a6bd071-9f82-4273-b101-9c763d6c4be4	b3e7b1f6-d818-46bc-a98e-9f7048e16f8f	ثبت اسناد حسابداری هفتگی #16	\N	low	2026-07-27	d8fea49c-fb6a-46fc-9b02-98398000e505	2026-07-20 09:22:03.794401+00	2026-07-20 09:22:03.794401+00	completed	approved	100	39.40	2026-07-09
1d224113-52fd-42ec-a3d9-ee5e9338d4af	58a3e39a-4d3f-4eeb-bf3e-fbf3ae866a53	\N	03c131a9-29b0-4e66-8d67-be78cfa01885	b3e7b1f6-d818-46bc-a98e-9f7048e16f8f	بررسی و تأیید صورت‌حساب‌های خرید #17	\N	medium	2026-07-18	21846ebe-83d7-4dfd-ae7b-7af31122c69f	2026-07-20 09:22:03.794401+00	2026-07-20 09:22:03.794401+00	todo	\N	70	23.70	2026-07-01
1d224113-52fd-42ec-a3d9-ee5e9338d4af	58a3e39a-4d3f-4eeb-bf3e-fbf3ae866a53	\N	1fd4dffb-d8db-4387-914a-be2a2a6fd6b1	b3e7b1f6-d818-46bc-a98e-9f7048e16f8f	تهیهٔ گزارش سود و زیان ماهانه #18	\N	medium	2026-08-15	62477096-3bfd-4907-a8d9-d04175035898	2026-07-20 09:22:03.794401+00	2026-07-20 09:22:03.794401+00	completed	approved	100	17.10	2026-08-11
1d224113-52fd-42ec-a3d9-ee5e9338d4af	8d09c967-bbac-40b4-b041-c8ea0286cd15	\N	8a6bd071-9f82-4273-b101-9c763d6c4be4	b3e7b1f6-d818-46bc-a98e-9f7048e16f8f	بررسی فاکتورهای فروش صادرشده #19	\N	medium	2026-08-03	95103225-e42d-4c99-8383-5bac772b939f	2026-07-20 09:22:03.794401+00	2026-07-20 09:22:03.794401+00	archived	\N	73	4.80	2026-07-16
1d224113-52fd-42ec-a3d9-ee5e9338d4af	8d09c967-bbac-40b4-b041-c8ea0286cd15	\N	8cca3fcf-f7a7-421a-b9a4-5dab90fe1b83	b3e7b1f6-d818-46bc-a98e-9f7048e16f8f	تهیهٔ گزارش مالیاتی فصلی #20	\N	low	2026-08-02	b603f6d7-8510-4971-9705-8e7353bc21b1	2026-07-20 09:22:03.794401+00	2026-07-20 09:22:03.794401+00	completed	approved	100	35.40	2026-07-15
1d224113-52fd-42ec-a3d9-ee5e9338d4af	8d09c967-bbac-40b4-b041-c8ea0286cd15	\N	03c131a9-29b0-4e66-8d67-be78cfa01885	b3e7b1f6-d818-46bc-a98e-9f7048e16f8f	بررسی فاکتورهای فروش صادرشده #21	\N	high	2026-07-03	7125a74b-bf00-4e30-8278-c86777f6ea61	2026-07-20 09:22:03.794401+00	2026-07-20 09:22:03.794401+00	completed	pending	100	36.60	2026-06-27
1d224113-52fd-42ec-a3d9-ee5e9338d4af	8d09c967-bbac-40b4-b041-c8ea0286cd15	\N	b3e7b1f6-d818-46bc-a98e-9f7048e16f8f	b3e7b1f6-d818-46bc-a98e-9f7048e16f8f	پیگیری مطالبات معوق مشتریان #22	\N	low	2026-07-25	c9ceed82-e97c-4747-8fd0-3fb718160e75	2026-07-20 09:22:03.794401+00	2026-07-20 09:22:03.794401+00	todo	\N	20	14.30	2026-07-19
1d224113-52fd-42ec-a3d9-ee5e9338d4af	8d09c967-bbac-40b4-b041-c8ea0286cd15	\N	8a6bd071-9f82-4273-b101-9c763d6c4be4	b3e7b1f6-d818-46bc-a98e-9f7048e16f8f	بررسی قراردادهای مالی جدید #23	\N	medium	2026-07-26	ff5ee6ac-16fa-4940-99c2-40562fa4e90b	2026-07-20 09:22:03.794401+00	2026-07-20 09:22:03.794401+00	in_progress	\N	10	11.50	2026-07-08
1d224113-52fd-42ec-a3d9-ee5e9338d4af	8d09c967-bbac-40b4-b041-c8ea0286cd15	\N	8a6bd071-9f82-4273-b101-9c763d6c4be4	b3e7b1f6-d818-46bc-a98e-9f7048e16f8f	بررسی صورت وضعیت پیمانکاران #24	\N	high	2026-08-06	e4bcd66e-61b2-496b-b65a-8d2cbac9c246	2026-07-20 09:22:03.794401+00	2026-07-20 09:22:03.794401+00	completed	approved	100	5.60	2026-07-26
1d224113-52fd-42ec-a3d9-ee5e9338d4af	8d09c967-bbac-40b4-b041-c8ea0286cd15	\N	8a6bd071-9f82-4273-b101-9c763d6c4be4	b3e7b1f6-d818-46bc-a98e-9f7048e16f8f	مغایرت‌گیری حساب‌های بانکی #25	\N	low	2026-08-12	c3c9c444-0085-4862-a549-f3d4138e3b50	2026-07-20 09:22:03.794401+00	2026-07-20 09:22:03.794401+00	todo	\N	79	29.40	2026-07-23
1d224113-52fd-42ec-a3d9-ee5e9338d4af	8d09c967-bbac-40b4-b041-c8ea0286cd15	\N	b720465e-b31b-4b9b-99d6-b303ca5f639d	b3e7b1f6-d818-46bc-a98e-9f7048e16f8f	بررسی و تأیید صورت‌حساب‌های خرید #26	\N	low	2026-08-28	3d0f23ba-9349-4f64-be43-b5f4dd436851	2026-07-20 09:22:03.794401+00	2026-07-20 09:22:03.794401+00	in_progress	\N	10	3.70	2026-08-08
1d224113-52fd-42ec-a3d9-ee5e9338d4af	8d09c967-bbac-40b4-b041-c8ea0286cd15	\N	8a6bd071-9f82-4273-b101-9c763d6c4be4	b3e7b1f6-d818-46bc-a98e-9f7048e16f8f	تطبیق موجودی انبار با حساب‌ها #27	\N	low	2026-08-01	d3894ef0-0886-461d-b82d-ac06ca8b6889	2026-07-20 09:22:03.794401+00	2026-07-20 09:22:03.794401+00	archived	\N	73	17.80	2026-07-22
1d224113-52fd-42ec-a3d9-ee5e9338d4af	8d09c967-bbac-40b4-b041-c8ea0286cd15	\N	8a6bd071-9f82-4273-b101-9c763d6c4be4	b3e7b1f6-d818-46bc-a98e-9f7048e16f8f	پیگیری مطالبات معوق مشتریان #28	\N	high	2026-08-05	34174f6e-840f-41c8-88d0-0109fd6004ea	2026-07-20 09:22:03.794401+00	2026-07-20 09:22:03.794401+00	todo	\N	38	20.40	2026-07-17
1d224113-52fd-42ec-a3d9-ee5e9338d4af	8d09c967-bbac-40b4-b041-c8ea0286cd15	\N	03c131a9-29b0-4e66-8d67-be78cfa01885	b3e7b1f6-d818-46bc-a98e-9f7048e16f8f	تهیهٔ گزارش جریان نقدی #29	\N	low	2026-07-19	07ed9b96-4416-4e8b-8f75-9a23f3bb9be9	2026-07-20 09:22:03.794401+00	2026-07-20 09:22:03.794401+00	completed	approved	100	8.00	2026-07-15
1d224113-52fd-42ec-a3d9-ee5e9338d4af	8d09c967-bbac-40b4-b041-c8ea0286cd15	\N	1fd4dffb-d8db-4387-914a-be2a2a6fd6b1	b3e7b1f6-d818-46bc-a98e-9f7048e16f8f	مغایرت‌گیری حساب‌های بانکی #30	\N	medium	2026-07-28	dc524117-52f3-47f0-89d7-0965f46a4912	2026-07-20 09:22:03.794401+00	2026-07-20 09:22:03.794401+00	completed	approved	100	34.70	2026-07-07
1d224113-52fd-42ec-a3d9-ee5e9338d4af	8d09c967-bbac-40b4-b041-c8ea0286cd15	\N	8cca3fcf-f7a7-421a-b9a4-5dab90fe1b83	b3e7b1f6-d818-46bc-a98e-9f7048e16f8f	بررسی فاکتورهای فروش صادرشده #31	\N	low	2026-08-23	f352b24d-1988-418c-8e73-9b51ca72f56b	2026-07-20 09:22:03.794401+00	2026-07-20 09:22:03.794401+00	archived	\N	47	21.60	2026-08-10
1d224113-52fd-42ec-a3d9-ee5e9338d4af	8d09c967-bbac-40b4-b041-c8ea0286cd15	\N	b3e7b1f6-d818-46bc-a98e-9f7048e16f8f	b3e7b1f6-d818-46bc-a98e-9f7048e16f8f	تهیهٔ گزارش سود و زیان ماهانه #32	\N	medium	2026-07-17	83239164-5d8c-436b-a139-89eabcd1abc5	2026-07-20 09:22:03.794401+00	2026-07-20 09:22:03.794401+00	in_progress	\N	57	11.40	2026-07-01
1d224113-52fd-42ec-a3d9-ee5e9338d4af	8d09c967-bbac-40b4-b041-c8ea0286cd15	\N	b3e7b1f6-d818-46bc-a98e-9f7048e16f8f	b3e7b1f6-d818-46bc-a98e-9f7048e16f8f	پیگیری بیمهٔ کارکنان #33	\N	high	2026-07-18	83734e9e-aa97-4a25-963a-905692190844	2026-07-20 09:22:03.794401+00	2026-07-20 09:22:03.794401+00	todo	\N	53	11.40	2026-07-04
1d224113-52fd-42ec-a3d9-ee5e9338d4af	8d09c967-bbac-40b4-b041-c8ea0286cd15	\N	03c131a9-29b0-4e66-8d67-be78cfa01885	b3e7b1f6-d818-46bc-a98e-9f7048e16f8f	بررسی قراردادهای مالی جدید #34	\N	high	2026-08-19	f5b512d5-478e-470d-ada8-f065cd8c9b6e	2026-07-20 09:22:03.794401+00	2026-07-20 09:22:03.794401+00	todo	\N	40	9.20	2026-08-07
1d224113-52fd-42ec-a3d9-ee5e9338d4af	8d09c967-bbac-40b4-b041-c8ea0286cd15	\N	1bd96f4a-6acb-4464-8452-ca1d3114a328	b3e7b1f6-d818-46bc-a98e-9f7048e16f8f	بررسی قراردادهای مالی جدید #35	\N	medium	2026-08-01	d7b8b9a5-b7a9-49da-b438-1a5888788415	2026-07-20 09:22:03.794401+00	2026-07-20 09:22:03.794401+00	completed	rejected	100	20.90	2026-07-15
1d224113-52fd-42ec-a3d9-ee5e9338d4af	8d09c967-bbac-40b4-b041-c8ea0286cd15	\N	b3e7b1f6-d818-46bc-a98e-9f7048e16f8f	b3e7b1f6-d818-46bc-a98e-9f7048e16f8f	ثبت اسناد حسابداری هفتگی #36	\N	low	2026-08-03	5a5d0602-314a-46ab-8e0d-496f09a460e9	2026-07-20 09:22:03.794401+00	2026-07-20 09:22:03.794401+00	in_progress	\N	74	15.40	2026-07-18
1d224113-52fd-42ec-a3d9-ee5e9338d4af	bd97c764-a55c-4687-96d6-225085ccda6f	\N	b3e7b1f6-d818-46bc-a98e-9f7048e16f8f	b3e7b1f6-d818-46bc-a98e-9f7048e16f8f	بررسی قراردادهای مالی جدید #37	\N	high	2026-08-07	8bd0d0e8-63d6-4c50-a8c0-587e92ab2077	2026-07-20 09:22:03.794401+00	2026-07-20 09:22:03.794401+00	in_progress	\N	60	12.90	2026-07-17
1d224113-52fd-42ec-a3d9-ee5e9338d4af	bd97c764-a55c-4687-96d6-225085ccda6f	\N	b3e7b1f6-d818-46bc-a98e-9f7048e16f8f	b3e7b1f6-d818-46bc-a98e-9f7048e16f8f	بررسی قراردادهای مالی جدید #38	\N	medium	2026-07-19	7e098865-8849-4b72-b96a-9211a7957d79	2026-07-20 09:22:03.794401+00	2026-07-20 09:22:03.794401+00	todo	\N	46	31.00	2026-07-13
1d224113-52fd-42ec-a3d9-ee5e9338d4af	bd97c764-a55c-4687-96d6-225085ccda6f	\N	8cca3fcf-f7a7-421a-b9a4-5dab90fe1b83	b3e7b1f6-d818-46bc-a98e-9f7048e16f8f	بررسی صورت وضعیت پیمانکاران #39	\N	high	2026-07-14	bce5bf33-e7d8-45e5-a606-3578ad6022fc	2026-07-20 09:22:03.794401+00	2026-07-20 09:22:03.794401+00	todo	\N	24	15.80	2026-07-11
1d224113-52fd-42ec-a3d9-ee5e9338d4af	bd97c764-a55c-4687-96d6-225085ccda6f	\N	8cca3fcf-f7a7-421a-b9a4-5dab90fe1b83	b3e7b1f6-d818-46bc-a98e-9f7048e16f8f	به‌روزرسانی جدول حقوق و دستمزد #40	\N	high	2026-07-28	db25ea0e-5396-4272-ae49-f7d0a7becb87	2026-07-20 09:22:03.794401+00	2026-07-20 09:22:03.794401+00	todo	\N	35	33.40	2026-07-10
1d224113-52fd-42ec-a3d9-ee5e9338d4af	bd97c764-a55c-4687-96d6-225085ccda6f	\N	b720465e-b31b-4b9b-99d6-b303ca5f639d	b3e7b1f6-d818-46bc-a98e-9f7048e16f8f	بررسی فاکتورهای فروش صادرشده #41	\N	medium	2026-06-29	3ae8b516-af4d-44e2-a683-bb07d503329f	2026-07-20 09:22:03.794401+00	2026-07-20 09:22:03.794401+00	completed	pending	100	32.20	2026-06-24
1d224113-52fd-42ec-a3d9-ee5e9338d4af	bd97c764-a55c-4687-96d6-225085ccda6f	\N	8cca3fcf-f7a7-421a-b9a4-5dab90fe1b83	b3e7b1f6-d818-46bc-a98e-9f7048e16f8f	ثبت اسناد حسابداری هفتگی #42	\N	high	2026-08-09	f283bdee-db04-4959-96cd-9b351e81787a	2026-07-20 09:22:03.794401+00	2026-07-20 09:22:03.794401+00	completed	rejected	100	21.30	2026-08-03
1d224113-52fd-42ec-a3d9-ee5e9338d4af	bd97c764-a55c-4687-96d6-225085ccda6f	\N	b720465e-b31b-4b9b-99d6-b303ca5f639d	b3e7b1f6-d818-46bc-a98e-9f7048e16f8f	مغایرت‌گیری حساب‌های بانکی #43	\N	high	2026-06-21	3664ab98-49e6-4f75-ac3f-9e3b1757a822	2026-07-20 09:22:03.794401+00	2026-07-20 09:22:03.794401+00	todo	\N	42	32.60	2026-06-18
1d224113-52fd-42ec-a3d9-ee5e9338d4af	bd97c764-a55c-4687-96d6-225085ccda6f	\N	b720465e-b31b-4b9b-99d6-b303ca5f639d	b3e7b1f6-d818-46bc-a98e-9f7048e16f8f	مغایرت‌گیری حساب‌های بانکی #44	\N	medium	2026-08-30	a74d9b36-88c1-485a-852b-1b905081cc05	2026-07-20 09:22:03.794401+00	2026-07-20 09:22:03.794401+00	completed	approved	100	37.40	2026-08-12
1d224113-52fd-42ec-a3d9-ee5e9338d4af	bd97c764-a55c-4687-96d6-225085ccda6f	\N	8cca3fcf-f7a7-421a-b9a4-5dab90fe1b83	b3e7b1f6-d818-46bc-a98e-9f7048e16f8f	تهیهٔ گزارش جریان نقدی #45	\N	medium	2026-08-01	da1b7d10-9e68-43c6-8ddf-10ba2d05c229	2026-07-20 09:22:03.794401+00	2026-07-20 09:22:03.794401+00	todo	\N	75	14.80	2026-07-11
1d224113-52fd-42ec-a3d9-ee5e9338d4af	bd97c764-a55c-4687-96d6-225085ccda6f	\N	03c131a9-29b0-4e66-8d67-be78cfa01885	b3e7b1f6-d818-46bc-a98e-9f7048e16f8f	پیگیری مطالبات معوق مشتریان #46	\N	medium	2026-08-20	d15a1253-f522-4664-b60d-fa538b96961e	2026-07-20 09:22:03.794401+00	2026-07-20 09:22:03.794401+00	completed	approved	100	33.00	2026-07-31
1d224113-52fd-42ec-a3d9-ee5e9338d4af	bd97c764-a55c-4687-96d6-225085ccda6f	\N	8cca3fcf-f7a7-421a-b9a4-5dab90fe1b83	b3e7b1f6-d818-46bc-a98e-9f7048e16f8f	بررسی فاکتورهای فروش صادرشده #47	\N	high	2026-08-03	9bdba43d-bb38-4961-ab05-15c18af06988	2026-07-20 09:22:03.794401+00	2026-07-20 09:22:03.794401+00	in_progress	\N	39	32.30	2026-07-29
1d224113-52fd-42ec-a3d9-ee5e9338d4af	bd97c764-a55c-4687-96d6-225085ccda6f	\N	8a6bd071-9f82-4273-b101-9c763d6c4be4	b3e7b1f6-d818-46bc-a98e-9f7048e16f8f	پیگیری مطالبات معوق مشتریان #48	\N	high	2026-08-10	5229da09-6f16-4b36-804f-65939496195b	2026-07-20 09:22:03.794401+00	2026-07-20 09:22:03.794401+00	completed	pending	100	31.80	2026-07-24
1d224113-52fd-42ec-a3d9-ee5e9338d4af	bd97c764-a55c-4687-96d6-225085ccda6f	\N	03c131a9-29b0-4e66-8d67-be78cfa01885	b3e7b1f6-d818-46bc-a98e-9f7048e16f8f	بررسی صورت وضعیت پیمانکاران #49	\N	medium	2026-08-04	21708736-c68a-4fb1-9682-ae6813fc87a2	2026-07-20 09:22:03.794401+00	2026-07-20 09:22:03.794401+00	completed	approved	100	8.50	2026-08-01
1d224113-52fd-42ec-a3d9-ee5e9338d4af	bd97c764-a55c-4687-96d6-225085ccda6f	\N	8a6bd071-9f82-4273-b101-9c763d6c4be4	b3e7b1f6-d818-46bc-a98e-9f7048e16f8f	مغایرت‌گیری حساب‌های بانکی #50	\N	high	2026-08-08	b0caa4f2-0ac0-40e5-865e-a8285764a0b1	2026-07-20 09:22:03.794401+00	2026-07-20 09:22:03.794401+00	archived	\N	31	3.20	2026-07-25
1d224113-52fd-42ec-a3d9-ee5e9338d4af	bd97c764-a55c-4687-96d6-225085ccda6f	\N	8a6bd071-9f82-4273-b101-9c763d6c4be4	b3e7b1f6-d818-46bc-a98e-9f7048e16f8f	به‌روزرسانی جدول حقوق و دستمزد #51	\N	medium	2026-06-30	4a70632a-d18a-4a81-8078-133d64b9eefa	2026-07-20 09:22:03.794401+00	2026-07-20 09:22:03.794401+00	todo	\N	53	7.80	2026-06-28
1d224113-52fd-42ec-a3d9-ee5e9338d4af	bd97c764-a55c-4687-96d6-225085ccda6f	\N	8a6bd071-9f82-4273-b101-9c763d6c4be4	b3e7b1f6-d818-46bc-a98e-9f7048e16f8f	بررسی و تسویهٔ کارت اعتباری شرکت #52	\N	high	2026-07-30	642dd147-a87e-4218-b4af-0855b1ebdd0f	2026-07-20 09:22:03.794401+00	2026-07-20 09:22:03.794401+00	in_progress	\N	60	35.20	2026-07-12
1d224113-52fd-42ec-a3d9-ee5e9338d4af	bd97c764-a55c-4687-96d6-225085ccda6f	\N	8a6bd071-9f82-4273-b101-9c763d6c4be4	b3e7b1f6-d818-46bc-a98e-9f7048e16f8f	تهیهٔ پیش‌نویس بودجهٔ واحد #53	\N	low	2026-06-25	cb7a4bdd-6cff-4677-b115-687cf6cd4ad6	2026-07-20 09:22:03.794401+00	2026-07-20 09:22:03.794401+00	archived	\N	71	14.40	2026-06-19
1d224113-52fd-42ec-a3d9-ee5e9338d4af	bd97c764-a55c-4687-96d6-225085ccda6f	\N	8a6bd071-9f82-4273-b101-9c763d6c4be4	b3e7b1f6-d818-46bc-a98e-9f7048e16f8f	به‌روزرسانی جدول حقوق و دستمزد #54	\N	high	2026-07-13	749fcfe4-e973-476a-b95c-562e8d854613	2026-07-20 09:22:03.794401+00	2026-07-20 09:22:03.794401+00	completed	approved	100	15.00	2026-07-06
1d224113-52fd-42ec-a3d9-ee5e9338d4af	24aaff84-b716-40f0-bc01-1438192b4c8c	\N	8cca3fcf-f7a7-421a-b9a4-5dab90fe1b83	b3e7b1f6-d818-46bc-a98e-9f7048e16f8f	بررسی صورت وضعیت پیمانکاران #55	\N	medium	2026-08-11	bd622b78-8262-4575-af53-04a3c6704ef8	2026-07-20 09:22:03.794401+00	2026-07-20 09:22:03.794401+00	completed	pending	100	9.30	2026-08-01
1d224113-52fd-42ec-a3d9-ee5e9338d4af	24aaff84-b716-40f0-bc01-1438192b4c8c	\N	1bd96f4a-6acb-4464-8452-ca1d3114a328	b3e7b1f6-d818-46bc-a98e-9f7048e16f8f	ثبت اسناد حسابداری هفتگی #56	\N	medium	2026-08-01	05c62b82-c22c-459f-8666-cada75e9863d	2026-07-20 09:22:03.794401+00	2026-07-20 09:22:03.794401+00	in_progress	\N	36	28.80	2026-07-21
1d224113-52fd-42ec-a3d9-ee5e9338d4af	24aaff84-b716-40f0-bc01-1438192b4c8c	\N	8a6bd071-9f82-4273-b101-9c763d6c4be4	b3e7b1f6-d818-46bc-a98e-9f7048e16f8f	به‌روزرسانی جدول حقوق و دستمزد #57	\N	medium	2026-07-29	25df7d54-aee0-42c0-b55d-202978e9948b	2026-07-20 09:22:03.794401+00	2026-07-20 09:22:03.794401+00	archived	\N	71	37.50	2026-07-17
1d224113-52fd-42ec-a3d9-ee5e9338d4af	24aaff84-b716-40f0-bc01-1438192b4c8c	\N	03c131a9-29b0-4e66-8d67-be78cfa01885	b3e7b1f6-d818-46bc-a98e-9f7048e16f8f	تهیهٔ گزارش سود و زیان ماهانه #58	\N	high	2026-07-14	639e43e6-2067-4c94-888e-64ac90538ae9	2026-07-20 09:22:03.794401+00	2026-07-20 09:22:03.794401+00	archived	\N	69	16.40	2026-07-03
1d224113-52fd-42ec-a3d9-ee5e9338d4af	24aaff84-b716-40f0-bc01-1438192b4c8c	\N	1fd4dffb-d8db-4387-914a-be2a2a6fd6b1	b3e7b1f6-d818-46bc-a98e-9f7048e16f8f	پیگیری مطالبات معوق مشتریان #59	\N	low	2026-08-10	8e22f485-090b-49e5-af17-7a5f22edbb77	2026-07-20 09:22:03.794401+00	2026-07-20 09:22:03.794401+00	in_progress	\N	36	38.30	2026-08-04
1d224113-52fd-42ec-a3d9-ee5e9338d4af	24aaff84-b716-40f0-bc01-1438192b4c8c	\N	b3e7b1f6-d818-46bc-a98e-9f7048e16f8f	b3e7b1f6-d818-46bc-a98e-9f7048e16f8f	تطبیق موجودی انبار با حساب‌ها #60	\N	medium	2026-08-30	3c5ef3b5-f9b0-4536-aec7-db534c96733b	2026-07-20 09:22:03.794401+00	2026-07-20 09:22:03.794401+00	in_progress	\N	61	10.10	2026-08-14
1d224113-52fd-42ec-a3d9-ee5e9338d4af	24aaff84-b716-40f0-bc01-1438192b4c8c	\N	03c131a9-29b0-4e66-8d67-be78cfa01885	b3e7b1f6-d818-46bc-a98e-9f7048e16f8f	مغایرت‌گیری حساب‌های بانکی #61	\N	low	2026-07-31	e9d44ac8-7dac-4a12-85ee-b3d53f3af893	2026-07-20 09:22:03.794401+00	2026-07-20 09:22:03.794401+00	completed	approved	100	25.40	2026-07-21
1d224113-52fd-42ec-a3d9-ee5e9338d4af	24aaff84-b716-40f0-bc01-1438192b4c8c	\N	b720465e-b31b-4b9b-99d6-b303ca5f639d	b3e7b1f6-d818-46bc-a98e-9f7048e16f8f	تطبیق موجودی انبار با حساب‌ها #62	\N	high	2026-07-04	6f488f70-bc15-4c14-943d-807f19645408	2026-07-20 09:22:03.794401+00	2026-07-20 09:22:03.794401+00	in_progress	\N	28	26.20	2026-07-01
1d224113-52fd-42ec-a3d9-ee5e9338d4af	24aaff84-b716-40f0-bc01-1438192b4c8c	\N	b3e7b1f6-d818-46bc-a98e-9f7048e16f8f	b3e7b1f6-d818-46bc-a98e-9f7048e16f8f	تهیهٔ گزارش جریان نقدی #63	\N	medium	2026-07-24	1f961842-df01-4e1c-af10-a488db5c8be3	2026-07-20 09:22:03.794401+00	2026-07-20 09:22:03.794401+00	todo	\N	12	27.90	2026-07-12
1d224113-52fd-42ec-a3d9-ee5e9338d4af	24aaff84-b716-40f0-bc01-1438192b4c8c	\N	1bd96f4a-6acb-4464-8452-ca1d3114a328	b3e7b1f6-d818-46bc-a98e-9f7048e16f8f	بررسی فاکتورهای فروش صادرشده #64	\N	high	2026-07-28	2e066398-331d-43e4-9499-c5038ea5557e	2026-07-20 09:22:03.794401+00	2026-07-20 09:22:03.794401+00	todo	\N	60	20.10	2026-07-21
1d224113-52fd-42ec-a3d9-ee5e9338d4af	24aaff84-b716-40f0-bc01-1438192b4c8c	\N	1bd96f4a-6acb-4464-8452-ca1d3114a328	b3e7b1f6-d818-46bc-a98e-9f7048e16f8f	پیگیری مطالبات معوق مشتریان #65	\N	high	2026-07-16	b5be104b-77fa-414c-a3d5-eb8550ee2fef	2026-07-20 09:22:03.794401+00	2026-07-20 09:22:03.794401+00	archived	\N	7	36.50	2026-07-04
1d224113-52fd-42ec-a3d9-ee5e9338d4af	24aaff84-b716-40f0-bc01-1438192b4c8c	\N	b3e7b1f6-d818-46bc-a98e-9f7048e16f8f	b3e7b1f6-d818-46bc-a98e-9f7048e16f8f	بررسی قراردادهای مالی جدید #66	\N	low	2026-07-23	19688f35-cb03-41e0-9af7-6cc36f7e05ab	2026-07-20 09:22:03.794401+00	2026-07-20 09:22:03.794401+00	completed	approved	100	17.90	2026-07-20
1d224113-52fd-42ec-a3d9-ee5e9338d4af	24aaff84-b716-40f0-bc01-1438192b4c8c	\N	03c131a9-29b0-4e66-8d67-be78cfa01885	b3e7b1f6-d818-46bc-a98e-9f7048e16f8f	پیگیری بیمهٔ کارکنان #67	\N	medium	2026-08-17	d246a2a4-d11a-4484-9349-218f40be3b51	2026-07-20 09:22:03.794401+00	2026-07-20 09:22:03.794401+00	todo	\N	63	9.10	2026-08-14
1d224113-52fd-42ec-a3d9-ee5e9338d4af	24aaff84-b716-40f0-bc01-1438192b4c8c	\N	8a6bd071-9f82-4273-b101-9c763d6c4be4	b3e7b1f6-d818-46bc-a98e-9f7048e16f8f	بررسی و تأیید صورت‌حساب‌های خرید #68	\N	medium	2026-08-14	5485692d-cb8b-4e71-99fd-d5bebe87286a	2026-07-20 09:22:03.794401+00	2026-07-20 09:22:03.794401+00	in_progress	\N	72	24.90	2026-08-11
1d224113-52fd-42ec-a3d9-ee5e9338d4af	24aaff84-b716-40f0-bc01-1438192b4c8c	\N	8cca3fcf-f7a7-421a-b9a4-5dab90fe1b83	b3e7b1f6-d818-46bc-a98e-9f7048e16f8f	تهیهٔ پیش‌نویس بودجهٔ واحد #69	\N	medium	2026-08-03	d139c8a2-6d9b-4d4c-875c-835d7de13356	2026-07-20 09:22:03.794401+00	2026-07-20 09:22:03.794401+00	in_progress	\N	17	34.30	2026-07-15
1d224113-52fd-42ec-a3d9-ee5e9338d4af	24aaff84-b716-40f0-bc01-1438192b4c8c	\N	1fd4dffb-d8db-4387-914a-be2a2a6fd6b1	b3e7b1f6-d818-46bc-a98e-9f7048e16f8f	تهیهٔ گزارش مالیاتی فصلی #70	\N	low	2026-07-03	dd59d5df-3406-42b8-83b8-8cd9caea8164	2026-07-20 09:22:03.794401+00	2026-07-20 09:22:03.794401+00	in_progress	\N	58	26.60	2026-06-28
1d224113-52fd-42ec-a3d9-ee5e9338d4af	24aaff84-b716-40f0-bc01-1438192b4c8c	\N	8a6bd071-9f82-4273-b101-9c763d6c4be4	b3e7b1f6-d818-46bc-a98e-9f7048e16f8f	بررسی و تسویهٔ کارت اعتباری شرکت #71	\N	medium	2026-06-28	0cc9f148-2692-4159-833b-3d41ad6a5282	2026-07-20 09:22:03.794401+00	2026-07-20 09:22:03.794401+00	todo	\N	72	27.60	2026-06-16
1d224113-52fd-42ec-a3d9-ee5e9338d4af	24aaff84-b716-40f0-bc01-1438192b4c8c	\N	1bd96f4a-6acb-4464-8452-ca1d3114a328	b3e7b1f6-d818-46bc-a98e-9f7048e16f8f	پیگیری بیمهٔ کارکنان #72	\N	medium	2026-08-08	06c502b4-d83b-4869-a650-db9d8e0e5d00	2026-07-20 09:22:03.794401+00	2026-07-20 09:22:03.794401+00	todo	\N	65	14.50	2026-07-25
1d224113-52fd-42ec-a3d9-ee5e9338d4af	31f35274-08e2-4c6a-8607-ad731054db18	\N	1fd4dffb-d8db-4387-914a-be2a2a6fd6b1	b3e7b1f6-d818-46bc-a98e-9f7048e16f8f	تهیهٔ گزارش مالیاتی فصلی #73	\N	low	2026-07-11	0130c4d3-3b88-4c57-b75c-24e1b191a666	2026-07-20 09:22:03.794401+00	2026-07-20 09:22:03.794401+00	completed	approved	100	2.30	2026-06-24
1d224113-52fd-42ec-a3d9-ee5e9338d4af	31f35274-08e2-4c6a-8607-ad731054db18	\N	1fd4dffb-d8db-4387-914a-be2a2a6fd6b1	b3e7b1f6-d818-46bc-a98e-9f7048e16f8f	تهیهٔ گزارش مالیاتی فصلی #74	\N	medium	2026-07-24	4bbac3b6-84c1-4c65-9c9c-3fb57db804fb	2026-07-20 09:22:03.794401+00	2026-07-20 09:22:03.794401+00	in_progress	\N	74	29.50	2026-07-14
1d224113-52fd-42ec-a3d9-ee5e9338d4af	31f35274-08e2-4c6a-8607-ad731054db18	\N	b3e7b1f6-d818-46bc-a98e-9f7048e16f8f	b3e7b1f6-d818-46bc-a98e-9f7048e16f8f	تهیهٔ گزارش جریان نقدی #75	\N	low	2026-08-09	77f0157a-5583-4413-be3c-417168e86c76	2026-07-20 09:22:03.794401+00	2026-07-20 09:22:03.794401+00	in_progress	\N	7	27.40	2026-07-27
1d224113-52fd-42ec-a3d9-ee5e9338d4af	31f35274-08e2-4c6a-8607-ad731054db18	\N	1fd4dffb-d8db-4387-914a-be2a2a6fd6b1	b3e7b1f6-d818-46bc-a98e-9f7048e16f8f	تطبیق موجودی انبار با حساب‌ها #76	\N	high	2026-07-10	eb43a464-6a40-4c62-be89-3437e098d61c	2026-07-20 09:22:03.794401+00	2026-07-20 09:22:03.794401+00	in_progress	\N	39	28.20	2026-06-26
1d224113-52fd-42ec-a3d9-ee5e9338d4af	31f35274-08e2-4c6a-8607-ad731054db18	\N	8a6bd071-9f82-4273-b101-9c763d6c4be4	b3e7b1f6-d818-46bc-a98e-9f7048e16f8f	ثبت اسناد حسابداری هفتگی #77	\N	low	2026-07-30	b9a62bf1-a9be-4f68-bd18-04ab098bc10c	2026-07-20 09:22:03.794401+00	2026-07-20 09:22:03.794401+00	in_progress	\N	17	20.20	2026-07-09
1d224113-52fd-42ec-a3d9-ee5e9338d4af	31f35274-08e2-4c6a-8607-ad731054db18	\N	1fd4dffb-d8db-4387-914a-be2a2a6fd6b1	b3e7b1f6-d818-46bc-a98e-9f7048e16f8f	بررسی فاکتورهای فروش صادرشده #78	\N	high	2026-08-06	7268f9b7-e133-408c-aaac-6a437f9f5635	2026-07-20 09:22:03.794401+00	2026-07-20 09:22:03.794401+00	archived	\N	70	36.70	2026-07-24
1d224113-52fd-42ec-a3d9-ee5e9338d4af	31f35274-08e2-4c6a-8607-ad731054db18	\N	03c131a9-29b0-4e66-8d67-be78cfa01885	b3e7b1f6-d818-46bc-a98e-9f7048e16f8f	بررسی و تسویهٔ کارت اعتباری شرکت #79	\N	low	2026-08-15	baae3f31-78b2-49b6-b632-aa68105f87bc	2026-07-20 09:22:03.794401+00	2026-07-20 09:22:03.794401+00	completed	pending	100	27.90	2026-08-07
1d224113-52fd-42ec-a3d9-ee5e9338d4af	31f35274-08e2-4c6a-8607-ad731054db18	\N	b720465e-b31b-4b9b-99d6-b303ca5f639d	b3e7b1f6-d818-46bc-a98e-9f7048e16f8f	تهیهٔ پیش‌نویس بودجهٔ واحد #80	\N	high	2026-08-04	0ee054fc-e9de-4d2e-b6c5-ddc2cdc104b7	2026-07-20 09:22:03.794401+00	2026-07-20 09:22:03.794401+00	todo	\N	46	5.00	2026-07-19
1d224113-52fd-42ec-a3d9-ee5e9338d4af	31f35274-08e2-4c6a-8607-ad731054db18	\N	b720465e-b31b-4b9b-99d6-b303ca5f639d	b3e7b1f6-d818-46bc-a98e-9f7048e16f8f	بررسی قراردادهای مالی جدید #81	\N	high	2026-07-08	ccce2979-26f4-4b2c-b540-b572b9304d54	2026-07-20 09:22:03.794401+00	2026-07-20 09:22:03.794401+00	todo	\N	25	23.80	2026-06-19
1d224113-52fd-42ec-a3d9-ee5e9338d4af	31f35274-08e2-4c6a-8607-ad731054db18	\N	1bd96f4a-6acb-4464-8452-ca1d3114a328	b3e7b1f6-d818-46bc-a98e-9f7048e16f8f	به‌روزرسانی جدول حقوق و دستمزد #82	\N	low	2026-07-24	8b73c3bc-846e-46ae-9824-ce1d85faab37	2026-07-20 09:22:03.794401+00	2026-07-20 09:22:03.794401+00	todo	\N	26	29.20	2026-07-06
1d224113-52fd-42ec-a3d9-ee5e9338d4af	31f35274-08e2-4c6a-8607-ad731054db18	\N	1fd4dffb-d8db-4387-914a-be2a2a6fd6b1	b3e7b1f6-d818-46bc-a98e-9f7048e16f8f	به‌روزرسانی جدول حقوق و دستمزد #83	\N	low	2026-08-30	0dd4241c-5191-45c8-aae1-432d11a148d0	2026-07-20 09:22:03.794401+00	2026-07-20 09:22:03.794401+00	todo	\N	58	7.00	2026-08-12
1d224113-52fd-42ec-a3d9-ee5e9338d4af	31f35274-08e2-4c6a-8607-ad731054db18	\N	1fd4dffb-d8db-4387-914a-be2a2a6fd6b1	b3e7b1f6-d818-46bc-a98e-9f7048e16f8f	تطبیق موجودی انبار با حساب‌ها #84	\N	medium	2026-08-06	8f12587c-aba3-48cc-80fe-c92bf1030387	2026-07-20 09:22:03.794401+00	2026-07-20 09:22:03.794401+00	completed	approved	100	29.50	2026-07-21
1d224113-52fd-42ec-a3d9-ee5e9338d4af	31f35274-08e2-4c6a-8607-ad731054db18	\N	1fd4dffb-d8db-4387-914a-be2a2a6fd6b1	b3e7b1f6-d818-46bc-a98e-9f7048e16f8f	تهیهٔ گزارش جریان نقدی #85	\N	low	2026-08-09	0bf88304-610a-41f1-a215-54b1ecae8ebd	2026-07-20 09:22:03.794401+00	2026-07-20 09:22:03.794401+00	in_progress	\N	74	4.80	2026-08-07
1d224113-52fd-42ec-a3d9-ee5e9338d4af	31f35274-08e2-4c6a-8607-ad731054db18	\N	1fd4dffb-d8db-4387-914a-be2a2a6fd6b1	b3e7b1f6-d818-46bc-a98e-9f7048e16f8f	تهیهٔ پیش‌نویس بودجهٔ واحد #86	\N	low	2026-08-03	46ca34a6-c24a-4404-9242-43011128664b	2026-07-20 09:22:03.794401+00	2026-07-20 09:22:03.794401+00	in_progress	\N	8	39.50	2026-07-30
1d224113-52fd-42ec-a3d9-ee5e9338d4af	31f35274-08e2-4c6a-8607-ad731054db18	\N	1fd4dffb-d8db-4387-914a-be2a2a6fd6b1	b3e7b1f6-d818-46bc-a98e-9f7048e16f8f	مغایرت‌گیری حساب‌های بانکی #87	\N	low	2026-07-19	f79d0968-7592-4c68-a25c-15742191a18d	2026-07-20 09:22:03.794401+00	2026-07-20 09:22:03.794401+00	todo	\N	53	16.20	2026-07-04
1d224113-52fd-42ec-a3d9-ee5e9338d4af	31f35274-08e2-4c6a-8607-ad731054db18	\N	1fd4dffb-d8db-4387-914a-be2a2a6fd6b1	b3e7b1f6-d818-46bc-a98e-9f7048e16f8f	بررسی فاکتورهای فروش صادرشده #88	\N	low	2026-08-27	0d0b120f-2c5c-4449-b057-5a4ab6d3e6d5	2026-07-20 09:22:03.794401+00	2026-07-20 09:22:03.794401+00	completed	pending	100	27.90	2026-08-13
1d224113-52fd-42ec-a3d9-ee5e9338d4af	31f35274-08e2-4c6a-8607-ad731054db18	\N	8a6bd071-9f82-4273-b101-9c763d6c4be4	b3e7b1f6-d818-46bc-a98e-9f7048e16f8f	تهیهٔ گزارش سود و زیان ماهانه #89	\N	low	2026-08-23	b6f75765-69da-4dbb-b541-e2e3d1cd0841	2026-07-20 09:22:03.794401+00	2026-07-20 09:22:03.794401+00	completed	approved	100	39.70	2026-08-10
1d224113-52fd-42ec-a3d9-ee5e9338d4af	31f35274-08e2-4c6a-8607-ad731054db18	\N	1fd4dffb-d8db-4387-914a-be2a2a6fd6b1	b3e7b1f6-d818-46bc-a98e-9f7048e16f8f	بررسی و تسویهٔ کارت اعتباری شرکت #90	\N	low	2026-07-02	6a3f03a0-a072-48cb-a961-a1484f9c4fdf	2026-07-20 09:22:03.794401+00	2026-07-20 09:22:03.794401+00	completed	approved	100	39.20	2026-06-30
1d224113-52fd-42ec-a3d9-ee5e9338d4af	\N	\N	1fd4dffb-d8db-4387-914a-be2a2a6fd6b1	1fd4dffb-d8db-4387-914a-be2a2a6fd6b1	بررسی فاکتورهای فروش صادرشده #91	\N	low	2026-08-01	b5258bba-fa1f-4527-aa6a-07229b75073b	2026-07-20 09:22:03.794401+00	2026-07-20 09:22:03.794401+00	completed	pending	100	11.40	2026-07-13
1d224113-52fd-42ec-a3d9-ee5e9338d4af	\N	\N	8cca3fcf-f7a7-421a-b9a4-5dab90fe1b83	8cca3fcf-f7a7-421a-b9a4-5dab90fe1b83	بررسی قراردادهای مالی جدید #92	\N	high	2026-07-11	5938f3af-7731-4ad9-80ef-0cccc534f56f	2026-07-20 09:22:03.794401+00	2026-07-20 09:22:03.794401+00	todo	\N	14	3.20	2026-07-03
1d224113-52fd-42ec-a3d9-ee5e9338d4af	\N	\N	8a6bd071-9f82-4273-b101-9c763d6c4be4	8a6bd071-9f82-4273-b101-9c763d6c4be4	ثبت اسناد حسابداری هفتگی #93	\N	low	2026-07-27	e4c6e7c1-42e3-4ed6-8e62-788b0ba3683d	2026-07-20 09:22:03.794401+00	2026-07-20 09:22:03.794401+00	in_progress	\N	8	5.80	2026-07-25
1d224113-52fd-42ec-a3d9-ee5e9338d4af	\N	\N	b3e7b1f6-d818-46bc-a98e-9f7048e16f8f	b3e7b1f6-d818-46bc-a98e-9f7048e16f8f	ثبت اسناد حسابداری هفتگی #94	\N	high	2026-08-03	4ba10d86-4545-4a0f-9124-f84207c1178a	2026-07-20 09:22:03.794401+00	2026-07-20 09:22:03.794401+00	completed	approved	100	3.70	2026-07-31
1d224113-52fd-42ec-a3d9-ee5e9338d4af	\N	\N	1fd4dffb-d8db-4387-914a-be2a2a6fd6b1	1fd4dffb-d8db-4387-914a-be2a2a6fd6b1	بررسی و تسویهٔ کارت اعتباری شرکت #95	\N	low	2026-07-28	6bb0e8c9-4a4f-4acf-98c8-75aec82cb87b	2026-07-20 09:22:03.794401+00	2026-07-20 09:22:03.794401+00	in_progress	\N	17	21.10	2026-07-20
1d224113-52fd-42ec-a3d9-ee5e9338d4af	\N	\N	8cca3fcf-f7a7-421a-b9a4-5dab90fe1b83	8cca3fcf-f7a7-421a-b9a4-5dab90fe1b83	تهیهٔ گزارش مالیاتی فصلی #96	\N	high	2026-08-27	c4e7efbb-8c1e-40e1-be8b-02af0ac7cda6	2026-07-20 09:22:03.794401+00	2026-07-20 09:22:03.794401+00	in_progress	\N	76	31.40	2026-08-07
1d224113-52fd-42ec-a3d9-ee5e9338d4af	\N	\N	03c131a9-29b0-4e66-8d67-be78cfa01885	03c131a9-29b0-4e66-8d67-be78cfa01885	بررسی قراردادهای مالی جدید #97	\N	low	2026-07-12	73f34106-afbb-4e61-a946-70e5d0fa49e5	2026-07-20 09:22:03.794401+00	2026-07-20 09:22:03.794401+00	in_progress	\N	66	10.40	2026-07-01
1d224113-52fd-42ec-a3d9-ee5e9338d4af	\N	\N	8cca3fcf-f7a7-421a-b9a4-5dab90fe1b83	8cca3fcf-f7a7-421a-b9a4-5dab90fe1b83	بررسی صورت وضعیت پیمانکاران #98	\N	high	2026-07-08	f795fd57-3e97-454c-b3b5-c5d47d26c380	2026-07-20 09:22:03.794401+00	2026-07-20 09:22:03.794401+00	in_progress	\N	22	25.80	2026-06-19
1d224113-52fd-42ec-a3d9-ee5e9338d4af	\N	\N	1fd4dffb-d8db-4387-914a-be2a2a6fd6b1	1fd4dffb-d8db-4387-914a-be2a2a6fd6b1	بررسی و تسویهٔ کارت اعتباری شرکت #99	\N	high	2026-07-22	11325dfa-9c91-4ed0-a0b3-17d345346d30	2026-07-20 09:22:03.794401+00	2026-07-20 09:22:03.794401+00	completed	approved	100	14.10	2026-07-08
1d224113-52fd-42ec-a3d9-ee5e9338d4af	\N	\N	1fd4dffb-d8db-4387-914a-be2a2a6fd6b1	1fd4dffb-d8db-4387-914a-be2a2a6fd6b1	بررسی فاکتورهای فروش صادرشده #100	\N	low	2026-07-06	ea198778-638c-4f51-a9be-a043e8eeb661	2026-07-20 09:22:03.794401+00	2026-07-20 09:22:03.794401+00	in_progress	\N	68	20.00	2026-06-25
1d224113-52fd-42ec-a3d9-ee5e9338d4af	\N	\N	03c131a9-29b0-4e66-8d67-be78cfa01885	03c131a9-29b0-4e66-8d67-be78cfa01885	بررسی و تسویهٔ کارت اعتباری شرکت #101	\N	medium	2026-07-11	d20b6d7a-0603-4fac-ab05-775bd149f013	2026-07-20 09:22:03.794401+00	2026-07-20 09:22:03.794401+00	in_progress	\N	7	23.40	2026-07-05
1d224113-52fd-42ec-a3d9-ee5e9338d4af	\N	\N	1fd4dffb-d8db-4387-914a-be2a2a6fd6b1	1fd4dffb-d8db-4387-914a-be2a2a6fd6b1	پیگیری مطالبات معوق مشتریان #102	\N	low	2026-07-19	59107e6c-d1ae-48ef-9db3-5f1596fb0c87	2026-07-20 09:22:03.794401+00	2026-07-20 09:22:03.794401+00	completed	approved	100	14.50	2026-07-10
1d224113-52fd-42ec-a3d9-ee5e9338d4af	\N	\N	b3e7b1f6-d818-46bc-a98e-9f7048e16f8f	b3e7b1f6-d818-46bc-a98e-9f7048e16f8f	تهیهٔ گزارش جریان نقدی #103	\N	low	2026-07-10	56325046-44fa-4e2b-87da-d5f1cc91d591	2026-07-20 09:22:03.794401+00	2026-07-20 09:22:03.794401+00	completed	pending	100	4.00	2026-06-21
1d224113-52fd-42ec-a3d9-ee5e9338d4af	\N	\N	1fd4dffb-d8db-4387-914a-be2a2a6fd6b1	1fd4dffb-d8db-4387-914a-be2a2a6fd6b1	ثبت اسناد حسابداری هفتگی #104	\N	high	2026-06-22	bf169b5a-1754-4ab0-9dac-4918366a3573	2026-07-20 09:22:03.794401+00	2026-07-20 09:22:03.794401+00	completed	pending	100	29.50	2026-06-18
1d224113-52fd-42ec-a3d9-ee5e9338d4af	\N	\N	b720465e-b31b-4b9b-99d6-b303ca5f639d	b720465e-b31b-4b9b-99d6-b303ca5f639d	پیگیری بیمهٔ کارکنان #105	\N	medium	2026-07-24	75c8091a-8a9c-44bf-802a-6dfcd351fb10	2026-07-20 09:22:03.794401+00	2026-07-20 09:22:03.794401+00	in_progress	\N	38	38.40	2026-07-16
1d224113-52fd-42ec-a3d9-ee5e9338d4af	d4c60db1-32fc-4fff-9b44-e4d116cb53d4	\N	57b624b6-2a61-45ab-95e9-0d4965be1a7e	7891652b-f708-4834-90b3-b7e06f9dd5ab	تدوین برنامهٔ آموزشی سال آینده #1	\N	medium	2026-07-06	a2f68654-55f2-45fa-99e7-d7155dbb4359	2026-07-20 09:22:03.794401+00	2026-07-20 09:22:03.794401+00	todo	\N	45	36.70	2026-06-27
1d224113-52fd-42ec-a3d9-ee5e9338d4af	d4c60db1-32fc-4fff-9b44-e4d116cb53d4	\N	7891652b-f708-4834-90b3-b7e06f9dd5ab	7891652b-f708-4834-90b3-b7e06f9dd5ab	تدوین برنامهٔ آموزشی سال آینده #2	\N	high	2026-08-12	4503c816-147f-4892-9c61-7bc84c097a23	2026-07-20 09:22:03.794401+00	2026-07-20 09:22:03.794401+00	archived	\N	18	23.40	2026-07-30
1d224113-52fd-42ec-a3d9-ee5e9338d4af	d4c60db1-32fc-4fff-9b44-e4d116cb53d4	\N	726b1bd0-c51d-4f38-9e37-f4c46a258d1b	7891652b-f708-4834-90b3-b7e06f9dd5ab	بررسی رزومه‌های متقاضیان شغلی #3	\N	low	2026-07-14	287bba2f-f8f0-48dc-86cf-27b7ce5519cc	2026-07-20 09:22:03.794401+00	2026-07-20 09:22:03.794401+00	completed	approved	100	4.10	2026-06-27
1d224113-52fd-42ec-a3d9-ee5e9338d4af	d4c60db1-32fc-4fff-9b44-e4d116cb53d4	\N	fc439dd8-ff4f-4760-bcc2-e3cddcba6888	7891652b-f708-4834-90b3-b7e06f9dd5ab	برنامه‌ریزی رویداد تیم‌سازی #4	\N	low	2026-07-05	641e9bf0-459c-4c9b-832c-f9f25aa5fd28	2026-07-20 09:22:03.794401+00	2026-07-20 09:22:03.794401+00	in_progress	\N	42	36.90	2026-06-17
1d224113-52fd-42ec-a3d9-ee5e9338d4af	d4c60db1-32fc-4fff-9b44-e4d116cb53d4	\N	726b1bd0-c51d-4f38-9e37-f4c46a258d1b	7891652b-f708-4834-90b3-b7e06f9dd5ab	بررسی درخواست ترفیع کارکنان #5	\N	medium	2026-07-14	52499d36-49ff-4d41-8f4d-de0f7a332adf	2026-07-20 09:22:03.794401+00	2026-07-20 09:22:03.794401+00	todo	\N	7	2.80	2026-07-07
1d224113-52fd-42ec-a3d9-ee5e9338d4af	d4c60db1-32fc-4fff-9b44-e4d116cb53d4	\N	fc439dd8-ff4f-4760-bcc2-e3cddcba6888	7891652b-f708-4834-90b3-b7e06f9dd5ab	برگزاری نظرسنجی رضایت شغلی #6	\N	low	2026-08-19	708e2273-f30d-40b7-9118-3ba6a26bc8d6	2026-07-20 09:22:03.794401+00	2026-07-20 09:22:03.794401+00	archived	\N	67	34.70	2026-08-13
1d224113-52fd-42ec-a3d9-ee5e9338d4af	d4c60db1-32fc-4fff-9b44-e4d116cb53d4	\N	7891652b-f708-4834-90b3-b7e06f9dd5ab	7891652b-f708-4834-90b3-b7e06f9dd5ab	تدوین برنامهٔ آموزشی سال آینده #7	\N	low	2026-08-14	82357429-8f44-404e-8083-4192cf1f6a7e	2026-07-20 09:22:03.794401+00	2026-07-20 09:22:03.794401+00	in_progress	\N	43	13.50	2026-07-31
1d224113-52fd-42ec-a3d9-ee5e9338d4af	d4c60db1-32fc-4fff-9b44-e4d116cb53d4	\N	726b1bd0-c51d-4f38-9e37-f4c46a258d1b	7891652b-f708-4834-90b3-b7e06f9dd5ab	برگزاری نظرسنجی رضایت شغلی #8	\N	high	2026-08-16	b58252df-7bf3-4b09-a8e3-840999866e79	2026-07-20 09:22:03.794401+00	2026-07-20 09:22:03.794401+00	todo	\N	62	26.70	2026-08-01
1d224113-52fd-42ec-a3d9-ee5e9338d4af	d4c60db1-32fc-4fff-9b44-e4d116cb53d4	\N	726b1bd0-c51d-4f38-9e37-f4c46a258d1b	7891652b-f708-4834-90b3-b7e06f9dd5ab	برگزاری نظرسنجی رضایت شغلی #9	\N	medium	2026-08-11	b51e2aff-9f3c-4e38-94c3-53d6a8f11cbd	2026-07-20 09:22:03.794401+00	2026-07-20 09:22:03.794401+00	archived	\N	28	27.30	2026-07-21
1d224113-52fd-42ec-a3d9-ee5e9338d4af	d4c60db1-32fc-4fff-9b44-e4d116cb53d4	\N	39f6a330-2d20-4870-ba2a-2457ecb3df8d	7891652b-f708-4834-90b3-b7e06f9dd5ab	به‌روزرسانی پروندهٔ پرسنلی #10	\N	high	2026-07-21	c0420c64-1e43-4e4e-90c1-e81ab45f2d48	2026-07-20 09:22:03.794401+00	2026-07-20 09:22:03.794401+00	todo	\N	37	6.80	2026-07-10
1d224113-52fd-42ec-a3d9-ee5e9338d4af	d4c60db1-32fc-4fff-9b44-e4d116cb53d4	\N	81977026-b6d9-4183-92f3-63f6484c7ae5	7891652b-f708-4834-90b3-b7e06f9dd5ab	تهیهٔ فرم ارزیابی سه‌ماهه #11	\N	high	2026-09-04	28524f5b-689f-4410-b633-927563852732	2026-07-20 09:22:03.794401+00	2026-07-20 09:22:03.794401+00	todo	\N	4	8.90	2026-08-15
1d224113-52fd-42ec-a3d9-ee5e9338d4af	d4c60db1-32fc-4fff-9b44-e4d116cb53d4	\N	57b624b6-2a61-45ab-95e9-0d4965be1a7e	7891652b-f708-4834-90b3-b7e06f9dd5ab	بررسی درخواست ترفیع کارکنان #12	\N	medium	2026-07-27	bc884c44-ab60-4b24-ae74-252b63ed9529	2026-07-20 09:22:03.794401+00	2026-07-20 09:22:03.794401+00	completed	approved	100	7.30	2026-07-22
1d224113-52fd-42ec-a3d9-ee5e9338d4af	d4c60db1-32fc-4fff-9b44-e4d116cb53d4	\N	81977026-b6d9-4183-92f3-63f6484c7ae5	7891652b-f708-4834-90b3-b7e06f9dd5ab	پیگیری درخواست‌های رفاهی کارکنان #13	\N	low	2026-07-14	8482a2f0-4ebf-4d7f-a0ef-a54284f17e35	2026-07-20 09:22:03.794401+00	2026-07-20 09:22:03.794401+00	todo	\N	11	33.20	2026-07-01
1d224113-52fd-42ec-a3d9-ee5e9338d4af	d4c60db1-32fc-4fff-9b44-e4d116cb53d4	\N	81977026-b6d9-4183-92f3-63f6484c7ae5	7891652b-f708-4834-90b3-b7e06f9dd5ab	بررسی رزومه‌های متقاضیان شغلی #14	\N	medium	2026-07-23	a643faa6-7d65-481c-af43-65e718f48bb5	2026-07-20 09:22:03.794401+00	2026-07-20 09:22:03.794401+00	completed	pending	100	10.00	2026-07-07
1d224113-52fd-42ec-a3d9-ee5e9338d4af	d4c60db1-32fc-4fff-9b44-e4d116cb53d4	\N	81977026-b6d9-4183-92f3-63f6484c7ae5	7891652b-f708-4834-90b3-b7e06f9dd5ab	برگزاری نظرسنجی رضایت شغلی #15	\N	low	2026-07-18	b144382c-ab79-4b25-99d5-84606dad5cb5	2026-07-20 09:22:03.794401+00	2026-07-20 09:22:03.794401+00	todo	\N	0	3.80	2026-07-08
1d224113-52fd-42ec-a3d9-ee5e9338d4af	d4c60db1-32fc-4fff-9b44-e4d116cb53d4	\N	3623572f-edd3-4d8b-a827-788687faac93	7891652b-f708-4834-90b3-b7e06f9dd5ab	بررسی درخواست ترفیع کارکنان #16	\N	medium	2026-07-19	be8a8cdb-42e2-47c3-8943-ae13308ea5ee	2026-07-20 09:22:03.794401+00	2026-07-20 09:22:03.794401+00	archived	\N	63	35.50	2026-07-12
1d224113-52fd-42ec-a3d9-ee5e9338d4af	d4c60db1-32fc-4fff-9b44-e4d116cb53d4	\N	57b624b6-2a61-45ab-95e9-0d4965be1a7e	7891652b-f708-4834-90b3-b7e06f9dd5ab	برگزاری نظرسنجی رضایت شغلی #17	\N	high	2026-08-25	8b095cab-035d-4f6e-a7ef-76905cd2e38d	2026-07-20 09:22:03.794401+00	2026-07-20 09:22:03.794401+00	completed	approved	100	26.70	2026-08-08
1d224113-52fd-42ec-a3d9-ee5e9338d4af	d4c60db1-32fc-4fff-9b44-e4d116cb53d4	\N	81977026-b6d9-4183-92f3-63f6484c7ae5	7891652b-f708-4834-90b3-b7e06f9dd5ab	برنامه‌ریزی مصاحبهٔ استخدامی #18	\N	low	2026-07-12	86fdcd94-12c6-4040-acf6-7d83a89aca88	2026-07-20 09:22:03.794401+00	2026-07-20 09:22:03.794401+00	in_progress	\N	37	2.80	2026-06-26
1d224113-52fd-42ec-a3d9-ee5e9338d4af	536ad236-1a6a-4963-aab2-e8e45fcc9989	\N	57b624b6-2a61-45ab-95e9-0d4965be1a7e	7891652b-f708-4834-90b3-b7e06f9dd5ab	تهیهٔ گزارش ارزیابی عملکرد #19	\N	medium	2026-07-02	c1d03568-c651-4a7f-9806-6dcc84d287b6	2026-07-20 09:22:03.794401+00	2026-07-20 09:22:03.794401+00	todo	\N	20	29.80	2026-06-20
1d224113-52fd-42ec-a3d9-ee5e9338d4af	536ad236-1a6a-4963-aab2-e8e45fcc9989	\N	fc439dd8-ff4f-4760-bcc2-e3cddcba6888	7891652b-f708-4834-90b3-b7e06f9dd5ab	تدوین برنامهٔ آموزشی سال آینده #20	\N	medium	2026-07-28	1d1a6159-d185-4ed1-93b2-a6d371068829	2026-07-20 09:22:03.794401+00	2026-07-20 09:22:03.794401+00	todo	\N	3	18.40	2026-07-07
1d224113-52fd-42ec-a3d9-ee5e9338d4af	536ad236-1a6a-4963-aab2-e8e45fcc9989	\N	81977026-b6d9-4183-92f3-63f6484c7ae5	7891652b-f708-4834-90b3-b7e06f9dd5ab	تهیهٔ گزارش ارزیابی عملکرد #21	\N	low	2026-08-08	bda40039-a75e-4518-9b37-7eade18c9dec	2026-07-20 09:22:03.794401+00	2026-07-20 09:22:03.794401+00	todo	\N	12	14.60	2026-07-24
1d224113-52fd-42ec-a3d9-ee5e9338d4af	536ad236-1a6a-4963-aab2-e8e45fcc9989	\N	726b1bd0-c51d-4f38-9e37-f4c46a258d1b	7891652b-f708-4834-90b3-b7e06f9dd5ab	به‌روزرسانی پروندهٔ پرسنلی #22	\N	high	2026-08-18	0d6b7f47-6a69-4be7-b752-9d3c0a214fbd	2026-07-20 09:22:03.794401+00	2026-07-20 09:22:03.794401+00	in_progress	\N	69	12.10	2026-07-30
1d224113-52fd-42ec-a3d9-ee5e9338d4af	536ad236-1a6a-4963-aab2-e8e45fcc9989	\N	57b624b6-2a61-45ab-95e9-0d4965be1a7e	7891652b-f708-4834-90b3-b7e06f9dd5ab	بررسی رزومه‌های متقاضیان شغلی #23	\N	medium	2026-07-06	d6961189-d847-440d-9c88-f8239fbbde5c	2026-07-20 09:22:03.794401+00	2026-07-20 09:22:03.794401+00	in_progress	\N	73	22.90	2026-07-01
1d224113-52fd-42ec-a3d9-ee5e9338d4af	536ad236-1a6a-4963-aab2-e8e45fcc9989	\N	3623572f-edd3-4d8b-a827-788687faac93	7891652b-f708-4834-90b3-b7e06f9dd5ab	بررسی رزومه‌های متقاضیان شغلی #24	\N	medium	2026-07-02	76681b88-2116-44d3-8d2c-b5e0cdd728de	2026-07-20 09:22:03.794401+00	2026-07-20 09:22:03.794401+00	todo	\N	11	13.20	2026-06-19
1d224113-52fd-42ec-a3d9-ee5e9338d4af	536ad236-1a6a-4963-aab2-e8e45fcc9989	\N	81977026-b6d9-4183-92f3-63f6484c7ae5	7891652b-f708-4834-90b3-b7e06f9dd5ab	بررسی رزومه‌های متقاضیان شغلی #25	\N	low	2026-07-03	c7f6b758-d856-49ef-9470-444d5f9d6bef	2026-07-20 09:22:03.794401+00	2026-07-20 09:22:03.794401+00	completed	pending	100	8.50	2026-06-28
1d224113-52fd-42ec-a3d9-ee5e9338d4af	536ad236-1a6a-4963-aab2-e8e45fcc9989	\N	57b624b6-2a61-45ab-95e9-0d4965be1a7e	7891652b-f708-4834-90b3-b7e06f9dd5ab	به‌روزرسانی آیین‌نامهٔ داخلی شرکت #26	\N	medium	2026-07-21	52dbea9e-9365-4cf0-b1a0-506a1601db94	2026-07-20 09:22:03.794401+00	2026-07-20 09:22:03.794401+00	todo	\N	60	20.60	2026-07-16
1d224113-52fd-42ec-a3d9-ee5e9338d4af	536ad236-1a6a-4963-aab2-e8e45fcc9989	\N	81977026-b6d9-4183-92f3-63f6484c7ae5	7891652b-f708-4834-90b3-b7e06f9dd5ab	تهیهٔ فرم ارزیابی سه‌ماهه #27	\N	low	2026-07-10	22cfd323-875d-4e37-8323-e1e76ea1a529	2026-07-20 09:22:03.794401+00	2026-07-20 09:22:03.794401+00	in_progress	\N	47	35.60	2026-06-21
1d224113-52fd-42ec-a3d9-ee5e9338d4af	536ad236-1a6a-4963-aab2-e8e45fcc9989	\N	57b624b6-2a61-45ab-95e9-0d4965be1a7e	7891652b-f708-4834-90b3-b7e06f9dd5ab	به‌روزرسانی آیین‌نامهٔ داخلی شرکت #28	\N	medium	2026-07-17	91aebaa9-908b-4cb0-b24a-bfbfce1f9fdf	2026-07-20 09:22:03.794401+00	2026-07-20 09:22:03.794401+00	todo	\N	59	12.00	2026-07-14
1d224113-52fd-42ec-a3d9-ee5e9338d4af	536ad236-1a6a-4963-aab2-e8e45fcc9989	\N	39f6a330-2d20-4870-ba2a-2457ecb3df8d	7891652b-f708-4834-90b3-b7e06f9dd5ab	تهیهٔ گزارش ارزیابی عملکرد #29	\N	high	2026-07-25	caa2c341-f2a6-4ffb-9f63-42336db152d4	2026-07-20 09:22:03.794401+00	2026-07-20 09:22:03.794401+00	in_progress	\N	12	5.30	2026-07-22
1d224113-52fd-42ec-a3d9-ee5e9338d4af	536ad236-1a6a-4963-aab2-e8e45fcc9989	\N	57b624b6-2a61-45ab-95e9-0d4965be1a7e	7891652b-f708-4834-90b3-b7e06f9dd5ab	برگزاری جلسهٔ آموزش کارکنان جدید #30	\N	high	2026-08-23	59ee9e4f-b89b-4939-9c8e-51215f81e8df	2026-07-20 09:22:03.794401+00	2026-07-20 09:22:03.794401+00	completed	approved	100	4.30	2026-08-03
1d224113-52fd-42ec-a3d9-ee5e9338d4af	536ad236-1a6a-4963-aab2-e8e45fcc9989	\N	3623572f-edd3-4d8b-a827-788687faac93	7891652b-f708-4834-90b3-b7e06f9dd5ab	تدوین برنامهٔ آموزشی سال آینده #31	\N	low	2026-08-06	3fc39ded-af64-4a8a-bf6b-41535e01b64d	2026-07-20 09:22:03.794401+00	2026-07-20 09:22:03.794401+00	completed	approved	100	20.10	2026-07-20
1d224113-52fd-42ec-a3d9-ee5e9338d4af	536ad236-1a6a-4963-aab2-e8e45fcc9989	\N	7891652b-f708-4834-90b3-b7e06f9dd5ab	7891652b-f708-4834-90b3-b7e06f9dd5ab	بررسی و تمدید قراردادهای پرسنلی #32	\N	high	2026-08-15	8f9ad552-8676-4e76-bfb1-b2b48af2e0c5	2026-07-20 09:22:03.794401+00	2026-07-20 09:22:03.794401+00	in_progress	\N	66	32.40	2026-08-12
1d224113-52fd-42ec-a3d9-ee5e9338d4af	536ad236-1a6a-4963-aab2-e8e45fcc9989	\N	81977026-b6d9-4183-92f3-63f6484c7ae5	7891652b-f708-4834-90b3-b7e06f9dd5ab	تهیهٔ گزارش ارزیابی عملکرد #33	\N	low	2026-08-31	41c636a0-6e79-4a1d-b3eb-1d564279a3f1	2026-07-20 09:22:03.794401+00	2026-07-20 09:22:03.794401+00	completed	approved	100	38.90	2026-08-15
1d224113-52fd-42ec-a3d9-ee5e9338d4af	536ad236-1a6a-4963-aab2-e8e45fcc9989	\N	39f6a330-2d20-4870-ba2a-2457ecb3df8d	7891652b-f708-4834-90b3-b7e06f9dd5ab	تهیهٔ فرم ارزیابی سه‌ماهه #34	\N	low	2026-06-27	58e728a2-97ec-43b3-b7a4-e30a161dddf6	2026-07-20 09:22:03.794401+00	2026-07-20 09:22:03.794401+00	todo	\N	55	9.70	2026-06-24
1d224113-52fd-42ec-a3d9-ee5e9338d4af	536ad236-1a6a-4963-aab2-e8e45fcc9989	\N	39f6a330-2d20-4870-ba2a-2457ecb3df8d	7891652b-f708-4834-90b3-b7e06f9dd5ab	پیگیری درخواست‌های رفاهی کارکنان #35	\N	high	2026-08-03	675d0792-331c-4d16-90db-a3120d1d154b	2026-07-20 09:22:03.794401+00	2026-07-20 09:22:03.794401+00	completed	approved	100	36.70	2026-07-24
1d224113-52fd-42ec-a3d9-ee5e9338d4af	536ad236-1a6a-4963-aab2-e8e45fcc9989	\N	7891652b-f708-4834-90b3-b7e06f9dd5ab	7891652b-f708-4834-90b3-b7e06f9dd5ab	تهیهٔ فرم ارزیابی سه‌ماهه #36	\N	high	2026-07-29	757ca45a-5eb2-4a64-95db-e782fe7849c8	2026-07-20 09:22:03.794401+00	2026-07-20 09:22:03.794401+00	todo	\N	41	34.60	2026-07-10
1d224113-52fd-42ec-a3d9-ee5e9338d4af	7f30992b-6766-462f-af35-f6ccf27fe636	\N	fc439dd8-ff4f-4760-bcc2-e3cddcba6888	7891652b-f708-4834-90b3-b7e06f9dd5ab	تدوین برنامهٔ آموزشی سال آینده #37	\N	high	2026-07-07	6efe76f2-307b-4a26-9f4a-7e09d8da36e1	2026-07-20 09:22:03.794401+00	2026-07-20 09:22:03.794401+00	completed	rejected	100	31.70	2026-06-16
1d224113-52fd-42ec-a3d9-ee5e9338d4af	7f30992b-6766-462f-af35-f6ccf27fe636	\N	7891652b-f708-4834-90b3-b7e06f9dd5ab	7891652b-f708-4834-90b3-b7e06f9dd5ab	تدوین برنامهٔ آموزشی سال آینده #38	\N	high	2026-07-01	65152795-e64e-4859-9ea7-489dce79a688	2026-07-20 09:22:03.794401+00	2026-07-20 09:22:03.794401+00	in_progress	\N	74	30.80	2026-06-25
1d224113-52fd-42ec-a3d9-ee5e9338d4af	7f30992b-6766-462f-af35-f6ccf27fe636	\N	7891652b-f708-4834-90b3-b7e06f9dd5ab	7891652b-f708-4834-90b3-b7e06f9dd5ab	برگزاری نظرسنجی رضایت شغلی #39	\N	medium	2026-07-27	086d9ba8-9605-4320-9861-cd7db9b2d8df	2026-07-20 09:22:03.794401+00	2026-07-20 09:22:03.794401+00	todo	\N	68	35.40	2026-07-22
1d224113-52fd-42ec-a3d9-ee5e9338d4af	7f30992b-6766-462f-af35-f6ccf27fe636	\N	3623572f-edd3-4d8b-a827-788687faac93	7891652b-f708-4834-90b3-b7e06f9dd5ab	تدوین برنامهٔ آموزشی سال آینده #40	\N	high	2026-07-27	68e554a1-d5dd-4b48-b6f3-0f9acce63d7a	2026-07-20 09:22:03.794401+00	2026-07-20 09:22:03.794401+00	in_progress	\N	60	3.40	2026-07-10
1d224113-52fd-42ec-a3d9-ee5e9338d4af	7f30992b-6766-462f-af35-f6ccf27fe636	\N	57b624b6-2a61-45ab-95e9-0d4965be1a7e	7891652b-f708-4834-90b3-b7e06f9dd5ab	تدوین برنامهٔ آموزشی سال آینده #41	\N	high	2026-07-16	ce636946-4bd8-49e8-a032-6a90c02941b9	2026-07-20 09:22:03.794401+00	2026-07-20 09:22:03.794401+00	in_progress	\N	51	3.50	2026-06-25
1d224113-52fd-42ec-a3d9-ee5e9338d4af	7f30992b-6766-462f-af35-f6ccf27fe636	\N	57b624b6-2a61-45ab-95e9-0d4965be1a7e	7891652b-f708-4834-90b3-b7e06f9dd5ab	بررسی درخواست ترفیع کارکنان #42	\N	medium	2026-08-19	d569158d-2b15-4ab7-885f-799f74f6bde1	2026-07-20 09:22:03.794401+00	2026-07-20 09:22:03.794401+00	completed	approved	100	36.10	2026-08-02
1d224113-52fd-42ec-a3d9-ee5e9338d4af	7f30992b-6766-462f-af35-f6ccf27fe636	\N	7891652b-f708-4834-90b3-b7e06f9dd5ab	7891652b-f708-4834-90b3-b7e06f9dd5ab	به‌روزرسانی آیین‌نامهٔ داخلی شرکت #43	\N	medium	2026-08-18	a6cbe273-eb89-4f34-9137-254561f361d0	2026-07-20 09:22:03.794401+00	2026-07-20 09:22:03.794401+00	in_progress	\N	62	34.60	2026-08-07
1d224113-52fd-42ec-a3d9-ee5e9338d4af	7f30992b-6766-462f-af35-f6ccf27fe636	\N	81977026-b6d9-4183-92f3-63f6484c7ae5	7891652b-f708-4834-90b3-b7e06f9dd5ab	تهیهٔ گزارش ارزیابی عملکرد #44	\N	medium	2026-08-19	bf36dc64-08b7-4d96-b250-f39f5459dd63	2026-07-20 09:22:03.794401+00	2026-07-20 09:22:03.794401+00	todo	\N	56	31.40	2026-08-10
1d224113-52fd-42ec-a3d9-ee5e9338d4af	7f30992b-6766-462f-af35-f6ccf27fe636	\N	57b624b6-2a61-45ab-95e9-0d4965be1a7e	7891652b-f708-4834-90b3-b7e06f9dd5ab	تدوین برنامهٔ آموزشی سال آینده #45	\N	high	2026-08-16	04dae2a4-4c1e-4b06-8fa5-b9b263fd3858	2026-07-20 09:22:03.794401+00	2026-07-20 09:22:03.794401+00	in_progress	\N	11	9.10	2026-08-01
1d224113-52fd-42ec-a3d9-ee5e9338d4af	7f30992b-6766-462f-af35-f6ccf27fe636	\N	726b1bd0-c51d-4f38-9e37-f4c46a258d1b	7891652b-f708-4834-90b3-b7e06f9dd5ab	برگزاری نظرسنجی رضایت شغلی #46	\N	high	2026-08-19	3e20996f-29bc-4868-9d79-56af8acdff5d	2026-07-20 09:22:03.794401+00	2026-07-20 09:22:03.794401+00	in_progress	\N	47	33.20	2026-08-02
1d224113-52fd-42ec-a3d9-ee5e9338d4af	7f30992b-6766-462f-af35-f6ccf27fe636	\N	fc439dd8-ff4f-4760-bcc2-e3cddcba6888	7891652b-f708-4834-90b3-b7e06f9dd5ab	به‌روزرسانی پروندهٔ پرسنلی #47	\N	high	2026-07-01	1ce68c9e-5d3b-44ed-83d4-d747b99a5c9c	2026-07-20 09:22:03.794401+00	2026-07-20 09:22:03.794401+00	todo	\N	51	7.20	2026-06-20
1d224113-52fd-42ec-a3d9-ee5e9338d4af	7f30992b-6766-462f-af35-f6ccf27fe636	\N	39f6a330-2d20-4870-ba2a-2457ecb3df8d	7891652b-f708-4834-90b3-b7e06f9dd5ab	برگزاری جلسهٔ آموزش کارکنان جدید #48	\N	low	2026-06-24	ff012e5a-5b4f-42c8-99ce-02f23348bdf4	2026-07-20 09:22:03.794401+00	2026-07-20 09:22:03.794401+00	completed	pending	100	33.80	2026-06-17
1d224113-52fd-42ec-a3d9-ee5e9338d4af	7f30992b-6766-462f-af35-f6ccf27fe636	\N	726b1bd0-c51d-4f38-9e37-f4c46a258d1b	7891652b-f708-4834-90b3-b7e06f9dd5ab	بررسی درخواست ترفیع کارکنان #49	\N	medium	2026-07-18	dcb61598-a17f-46c0-991f-f5c91cb782bf	2026-07-20 09:22:03.794401+00	2026-07-20 09:22:03.794401+00	todo	\N	25	12.40	2026-07-15
1d224113-52fd-42ec-a3d9-ee5e9338d4af	7f30992b-6766-462f-af35-f6ccf27fe636	\N	39f6a330-2d20-4870-ba2a-2457ecb3df8d	7891652b-f708-4834-90b3-b7e06f9dd5ab	پیگیری مرخصی و مأموریت کارکنان #50	\N	low	2026-07-31	24324de2-fa2e-47ec-bcd5-fdbe8807dd02	2026-07-20 09:22:03.794401+00	2026-07-20 09:22:03.794401+00	completed	approved	100	11.20	2026-07-26
1d224113-52fd-42ec-a3d9-ee5e9338d4af	7f30992b-6766-462f-af35-f6ccf27fe636	\N	3623572f-edd3-4d8b-a827-788687faac93	7891652b-f708-4834-90b3-b7e06f9dd5ab	تدوین برنامهٔ آموزشی سال آینده #51	\N	high	2026-08-27	0ef90389-490d-4602-9222-7034cccd4a83	2026-07-20 09:22:03.794401+00	2026-07-20 09:22:03.794401+00	completed	approved	100	15.30	2026-08-10
1d224113-52fd-42ec-a3d9-ee5e9338d4af	7f30992b-6766-462f-af35-f6ccf27fe636	\N	726b1bd0-c51d-4f38-9e37-f4c46a258d1b	7891652b-f708-4834-90b3-b7e06f9dd5ab	به‌روزرسانی آیین‌نامهٔ داخلی شرکت #52	\N	low	2026-08-06	00847a5a-6e6f-4ba6-a9e0-8a7411c19113	2026-07-20 09:22:03.794401+00	2026-07-20 09:22:03.794401+00	in_progress	\N	49	3.90	2026-08-02
1d224113-52fd-42ec-a3d9-ee5e9338d4af	7f30992b-6766-462f-af35-f6ccf27fe636	\N	39f6a330-2d20-4870-ba2a-2457ecb3df8d	7891652b-f708-4834-90b3-b7e06f9dd5ab	پیگیری مرخصی و مأموریت کارکنان #53	\N	low	2026-07-08	5ef12672-e2e4-4c43-8783-477b94bbce9f	2026-07-20 09:22:03.794401+00	2026-07-20 09:22:03.794401+00	completed	pending	100	27.80	2026-06-29
1d224113-52fd-42ec-a3d9-ee5e9338d4af	7f30992b-6766-462f-af35-f6ccf27fe636	\N	57b624b6-2a61-45ab-95e9-0d4965be1a7e	7891652b-f708-4834-90b3-b7e06f9dd5ab	برنامه‌ریزی رویداد تیم‌سازی #54	\N	low	2026-06-19	98b46b79-cc9a-4bc9-ad94-ed09d64462fb	2026-07-20 09:22:03.794401+00	2026-07-20 09:22:03.794401+00	completed	approved	100	26.60	2026-06-17
1d224113-52fd-42ec-a3d9-ee5e9338d4af	8ea72ae4-a2b9-4204-98a6-7dfa14a12164	\N	fc439dd8-ff4f-4760-bcc2-e3cddcba6888	7891652b-f708-4834-90b3-b7e06f9dd5ab	تدوین برنامهٔ آموزشی سال آینده #55	\N	medium	2026-07-10	cf98d4eb-1697-4c67-ab0b-3d88ae43a593	2026-07-20 09:22:03.794401+00	2026-07-20 09:22:03.794401+00	todo	\N	35	18.10	2026-06-30
1d224113-52fd-42ec-a3d9-ee5e9338d4af	8ea72ae4-a2b9-4204-98a6-7dfa14a12164	\N	3623572f-edd3-4d8b-a827-788687faac93	7891652b-f708-4834-90b3-b7e06f9dd5ab	برگزاری جلسهٔ آموزش کارکنان جدید #56	\N	medium	2026-07-25	99499105-abc9-49fb-af15-db274aedec19	2026-07-20 09:22:03.794401+00	2026-07-20 09:22:03.794401+00	in_progress	\N	38	27.70	2026-07-15
1d224113-52fd-42ec-a3d9-ee5e9338d4af	8ea72ae4-a2b9-4204-98a6-7dfa14a12164	\N	39f6a330-2d20-4870-ba2a-2457ecb3df8d	7891652b-f708-4834-90b3-b7e06f9dd5ab	بررسی و تمدید قراردادهای پرسنلی #57	\N	high	2026-06-24	9f6a9fc2-b1e0-4dd7-9c14-eec8df132beb	2026-07-20 09:22:03.794401+00	2026-07-20 09:22:03.794401+00	completed	approved	100	38.70	2026-06-22
1d224113-52fd-42ec-a3d9-ee5e9338d4af	8ea72ae4-a2b9-4204-98a6-7dfa14a12164	\N	39f6a330-2d20-4870-ba2a-2457ecb3df8d	7891652b-f708-4834-90b3-b7e06f9dd5ab	تدوین برنامهٔ آموزشی سال آینده #58	\N	medium	2026-08-11	b2e4a4fa-c2c5-49e4-a5dc-efaf06290452	2026-07-20 09:22:03.794401+00	2026-07-20 09:22:03.794401+00	in_progress	\N	38	28.00	2026-07-21
1d224113-52fd-42ec-a3d9-ee5e9338d4af	8ea72ae4-a2b9-4204-98a6-7dfa14a12164	\N	3623572f-edd3-4d8b-a827-788687faac93	7891652b-f708-4834-90b3-b7e06f9dd5ab	پیگیری مرخصی و مأموریت کارکنان #59	\N	medium	2026-07-17	fed8c80b-e52e-40e9-a3c9-ac660af1c126	2026-07-20 09:22:03.794401+00	2026-07-20 09:22:03.794401+00	todo	\N	35	11.90	2026-07-07
1d224113-52fd-42ec-a3d9-ee5e9338d4af	8ea72ae4-a2b9-4204-98a6-7dfa14a12164	\N	81977026-b6d9-4183-92f3-63f6484c7ae5	7891652b-f708-4834-90b3-b7e06f9dd5ab	برگزاری نظرسنجی رضایت شغلی #60	\N	low	2026-07-13	1982e568-3559-4cb8-bdd5-30ec0252cbbb	2026-07-20 09:22:03.794401+00	2026-07-20 09:22:03.794401+00	completed	approved	100	36.20	2026-06-25
1d224113-52fd-42ec-a3d9-ee5e9338d4af	8ea72ae4-a2b9-4204-98a6-7dfa14a12164	\N	39f6a330-2d20-4870-ba2a-2457ecb3df8d	7891652b-f708-4834-90b3-b7e06f9dd5ab	به‌روزرسانی پروندهٔ پرسنلی #61	\N	low	2026-07-12	6b0d287c-8384-4d6b-b264-25f94a4c0800	2026-07-20 09:22:03.794401+00	2026-07-20 09:22:03.794401+00	completed	approved	100	26.90	2026-07-06
1d224113-52fd-42ec-a3d9-ee5e9338d4af	8ea72ae4-a2b9-4204-98a6-7dfa14a12164	\N	57b624b6-2a61-45ab-95e9-0d4965be1a7e	7891652b-f708-4834-90b3-b7e06f9dd5ab	تهیهٔ فرم ارزیابی سه‌ماهه #62	\N	medium	2026-08-28	e5972c36-cf09-462c-a08d-d67b4b82da1b	2026-07-20 09:22:03.794401+00	2026-07-20 09:22:03.794401+00	in_progress	\N	4	24.20	2026-08-13
1d224113-52fd-42ec-a3d9-ee5e9338d4af	8ea72ae4-a2b9-4204-98a6-7dfa14a12164	\N	fc439dd8-ff4f-4760-bcc2-e3cddcba6888	7891652b-f708-4834-90b3-b7e06f9dd5ab	پیگیری مرخصی و مأموریت کارکنان #63	\N	high	2026-07-16	4d96ee1a-e946-4b4d-b6e1-427dda5245c3	2026-07-20 09:22:03.794401+00	2026-07-20 09:22:03.794401+00	todo	\N	60	36.40	2026-07-07
1d224113-52fd-42ec-a3d9-ee5e9338d4af	8ea72ae4-a2b9-4204-98a6-7dfa14a12164	\N	81977026-b6d9-4183-92f3-63f6484c7ae5	7891652b-f708-4834-90b3-b7e06f9dd5ab	تهیهٔ گزارش غیبت و تأخیر #64	\N	low	2026-07-29	e8f07bec-d889-43a4-903d-0cbb8e93219c	2026-07-20 09:22:03.794401+00	2026-07-20 09:22:03.794401+00	in_progress	\N	71	8.90	2026-07-18
1d224113-52fd-42ec-a3d9-ee5e9338d4af	8ea72ae4-a2b9-4204-98a6-7dfa14a12164	\N	7891652b-f708-4834-90b3-b7e06f9dd5ab	7891652b-f708-4834-90b3-b7e06f9dd5ab	برگزاری نظرسنجی رضایت شغلی #65	\N	low	2026-07-21	89a2ff8d-9d77-459e-b131-6c8505b9f4bd	2026-07-20 09:22:03.794401+00	2026-07-20 09:22:03.794401+00	completed	approved	100	38.00	2026-07-02
1d224113-52fd-42ec-a3d9-ee5e9338d4af	8ea72ae4-a2b9-4204-98a6-7dfa14a12164	\N	57b624b6-2a61-45ab-95e9-0d4965be1a7e	7891652b-f708-4834-90b3-b7e06f9dd5ab	به‌روزرسانی پروندهٔ پرسنلی #66	\N	medium	2026-07-17	396a334e-f661-424c-811f-2d5bdd493292	2026-07-20 09:22:03.794401+00	2026-07-20 09:22:03.794401+00	completed	approved	100	18.00	2026-07-08
1d224113-52fd-42ec-a3d9-ee5e9338d4af	8ea72ae4-a2b9-4204-98a6-7dfa14a12164	\N	57b624b6-2a61-45ab-95e9-0d4965be1a7e	7891652b-f708-4834-90b3-b7e06f9dd5ab	به‌روزرسانی آیین‌نامهٔ داخلی شرکت #67	\N	medium	2026-07-22	d4b4aab1-c47c-4498-898a-9860226d1cc1	2026-07-20 09:22:03.794401+00	2026-07-20 09:22:03.794401+00	in_progress	\N	15	19.90	2026-07-02
1d224113-52fd-42ec-a3d9-ee5e9338d4af	8ea72ae4-a2b9-4204-98a6-7dfa14a12164	\N	39f6a330-2d20-4870-ba2a-2457ecb3df8d	7891652b-f708-4834-90b3-b7e06f9dd5ab	برنامه‌ریزی مصاحبهٔ استخدامی #68	\N	medium	2026-09-05	874fde8e-47c3-47cb-b8d6-ef6e9b70af65	2026-07-20 09:22:03.794401+00	2026-07-20 09:22:03.794401+00	completed	approved	100	35.80	2026-08-15
1d224113-52fd-42ec-a3d9-ee5e9338d4af	8ea72ae4-a2b9-4204-98a6-7dfa14a12164	\N	fc439dd8-ff4f-4760-bcc2-e3cddcba6888	7891652b-f708-4834-90b3-b7e06f9dd5ab	بررسی و تمدید قراردادهای پرسنلی #69	\N	medium	2026-08-24	cbf981fd-5d21-454a-adf2-c2fa6c5685b5	2026-07-20 09:22:03.794401+00	2026-07-20 09:22:03.794401+00	todo	\N	52	4.10	2026-08-10
1d224113-52fd-42ec-a3d9-ee5e9338d4af	8ea72ae4-a2b9-4204-98a6-7dfa14a12164	\N	39f6a330-2d20-4870-ba2a-2457ecb3df8d	7891652b-f708-4834-90b3-b7e06f9dd5ab	پیگیری درخواست‌های رفاهی کارکنان #70	\N	medium	2026-07-02	03a1f46a-e49d-40b0-ba03-4345ce6fe9db	2026-07-20 09:22:03.794401+00	2026-07-20 09:22:03.794401+00	todo	\N	72	35.90	2026-06-24
1d224113-52fd-42ec-a3d9-ee5e9338d4af	8ea72ae4-a2b9-4204-98a6-7dfa14a12164	\N	3623572f-edd3-4d8b-a827-788687faac93	7891652b-f708-4834-90b3-b7e06f9dd5ab	برگزاری نظرسنجی رضایت شغلی #71	\N	low	2026-07-13	54720941-de2f-4a16-8aba-afb560e6d130	2026-07-20 09:22:03.794401+00	2026-07-20 09:22:03.794401+00	todo	\N	62	14.60	2026-07-06
1d224113-52fd-42ec-a3d9-ee5e9338d4af	8ea72ae4-a2b9-4204-98a6-7dfa14a12164	\N	726b1bd0-c51d-4f38-9e37-f4c46a258d1b	7891652b-f708-4834-90b3-b7e06f9dd5ab	بررسی رزومه‌های متقاضیان شغلی #72	\N	medium	2026-07-29	56e0b273-4fe4-4b89-93f4-95ac8fbafc38	2026-07-20 09:22:03.794401+00	2026-07-20 09:22:03.794401+00	in_progress	\N	35	10.00	2026-07-26
1d224113-52fd-42ec-a3d9-ee5e9338d4af	be632b24-428c-485a-92f7-5e9d91fe40fc	\N	39f6a330-2d20-4870-ba2a-2457ecb3df8d	7891652b-f708-4834-90b3-b7e06f9dd5ab	برنامه‌ریزی رویداد تیم‌سازی #73	\N	low	2026-07-29	9774c769-e8d6-47af-b50a-7b59210ce745	2026-07-20 09:22:03.794401+00	2026-07-20 09:22:03.794401+00	todo	\N	16	25.40	2026-07-22
1d224113-52fd-42ec-a3d9-ee5e9338d4af	be632b24-428c-485a-92f7-5e9d91fe40fc	\N	81977026-b6d9-4183-92f3-63f6484c7ae5	7891652b-f708-4834-90b3-b7e06f9dd5ab	برنامه‌ریزی رویداد تیم‌سازی #74	\N	medium	2026-07-26	d26b38e8-6583-4897-9771-8483382a18a8	2026-07-20 09:22:03.794401+00	2026-07-20 09:22:03.794401+00	in_progress	\N	0	3.40	2026-07-11
1d224113-52fd-42ec-a3d9-ee5e9338d4af	be632b24-428c-485a-92f7-5e9d91fe40fc	\N	726b1bd0-c51d-4f38-9e37-f4c46a258d1b	7891652b-f708-4834-90b3-b7e06f9dd5ab	بررسی درخواست ترفیع کارکنان #75	\N	medium	2026-07-11	8d3f66b8-f22a-4902-b4c2-8f73d9756a98	2026-07-20 09:22:03.794401+00	2026-07-20 09:22:03.794401+00	archived	\N	67	9.20	2026-07-09
1d224113-52fd-42ec-a3d9-ee5e9338d4af	be632b24-428c-485a-92f7-5e9d91fe40fc	\N	81977026-b6d9-4183-92f3-63f6484c7ae5	7891652b-f708-4834-90b3-b7e06f9dd5ab	برگزاری جلسهٔ آموزش کارکنان جدید #76	\N	high	2026-08-04	10e92f1e-9745-462c-bfa9-d22eba9c50c0	2026-07-20 09:22:03.794401+00	2026-07-20 09:22:03.794401+00	todo	\N	44	13.90	2026-07-26
1d224113-52fd-42ec-a3d9-ee5e9338d4af	be632b24-428c-485a-92f7-5e9d91fe40fc	\N	7891652b-f708-4834-90b3-b7e06f9dd5ab	7891652b-f708-4834-90b3-b7e06f9dd5ab	به‌روزرسانی آیین‌نامهٔ داخلی شرکت #77	\N	low	2026-08-07	770039db-441f-4cc2-b605-4e0cb0f151ce	2026-07-20 09:22:03.794401+00	2026-07-20 09:22:03.794401+00	in_progress	\N	8	33.30	2026-07-18
1d224113-52fd-42ec-a3d9-ee5e9338d4af	be632b24-428c-485a-92f7-5e9d91fe40fc	\N	57b624b6-2a61-45ab-95e9-0d4965be1a7e	7891652b-f708-4834-90b3-b7e06f9dd5ab	تدوین برنامهٔ آموزشی سال آینده #78	\N	high	2026-08-02	5a41576c-95d9-4efb-a854-7b828fa94200	2026-07-20 09:22:03.794401+00	2026-07-20 09:22:03.794401+00	in_progress	\N	43	18.50	2026-07-15
1d224113-52fd-42ec-a3d9-ee5e9338d4af	be632b24-428c-485a-92f7-5e9d91fe40fc	\N	81977026-b6d9-4183-92f3-63f6484c7ae5	7891652b-f708-4834-90b3-b7e06f9dd5ab	پیگیری درخواست‌های رفاهی کارکنان #79	\N	low	2026-07-24	a57f42e3-e08f-454e-9ed1-10efe6c58d57	2026-07-20 09:22:03.794401+00	2026-07-20 09:22:03.794401+00	todo	\N	21	38.00	2026-07-07
1d224113-52fd-42ec-a3d9-ee5e9338d4af	be632b24-428c-485a-92f7-5e9d91fe40fc	\N	39f6a330-2d20-4870-ba2a-2457ecb3df8d	7891652b-f708-4834-90b3-b7e06f9dd5ab	برگزاری جلسهٔ آموزش کارکنان جدید #80	\N	high	2026-06-26	0783419f-5ca3-4fc7-bb09-0501a6ea5c37	2026-07-20 09:22:03.794401+00	2026-07-20 09:22:03.794401+00	in_progress	\N	16	10.00	2026-06-17
1d224113-52fd-42ec-a3d9-ee5e9338d4af	be632b24-428c-485a-92f7-5e9d91fe40fc	\N	7891652b-f708-4834-90b3-b7e06f9dd5ab	7891652b-f708-4834-90b3-b7e06f9dd5ab	به‌روزرسانی پروندهٔ پرسنلی #81	\N	high	2026-07-06	8e76c7d6-3833-4fe0-818a-a13651955628	2026-07-20 09:22:03.794401+00	2026-07-20 09:22:03.794401+00	completed	approved	100	32.10	2026-06-23
1d224113-52fd-42ec-a3d9-ee5e9338d4af	be632b24-428c-485a-92f7-5e9d91fe40fc	\N	3623572f-edd3-4d8b-a827-788687faac93	7891652b-f708-4834-90b3-b7e06f9dd5ab	بررسی رزومه‌های متقاضیان شغلی #82	\N	high	2026-08-10	dd8fc3d0-2e15-4138-81f3-664105bafaa5	2026-07-20 09:22:03.794401+00	2026-07-20 09:22:03.794401+00	completed	approved	100	39.80	2026-07-20
1d224113-52fd-42ec-a3d9-ee5e9338d4af	be632b24-428c-485a-92f7-5e9d91fe40fc	\N	81977026-b6d9-4183-92f3-63f6484c7ae5	7891652b-f708-4834-90b3-b7e06f9dd5ab	بررسی رزومه‌های متقاضیان شغلی #83	\N	high	2026-07-29	84323c1b-813f-4482-bf67-f9e6b4b6747e	2026-07-20 09:22:03.794401+00	2026-07-20 09:22:03.794401+00	todo	\N	14	17.80	2026-07-27
1d224113-52fd-42ec-a3d9-ee5e9338d4af	be632b24-428c-485a-92f7-5e9d91fe40fc	\N	3623572f-edd3-4d8b-a827-788687faac93	7891652b-f708-4834-90b3-b7e06f9dd5ab	برنامه‌ریزی رویداد تیم‌سازی #84	\N	high	2026-07-31	9c01068f-bf0a-43fb-aeff-35deba4437d1	2026-07-20 09:22:03.794401+00	2026-07-20 09:22:03.794401+00	todo	\N	19	9.80	2026-07-21
1d224113-52fd-42ec-a3d9-ee5e9338d4af	be632b24-428c-485a-92f7-5e9d91fe40fc	\N	81977026-b6d9-4183-92f3-63f6484c7ae5	7891652b-f708-4834-90b3-b7e06f9dd5ab	پیگیری مرخصی و مأموریت کارکنان #85	\N	high	2026-07-17	b29f012c-4631-479a-930b-5c1b65d98aa3	2026-07-20 09:22:03.794401+00	2026-07-20 09:22:03.794401+00	completed	approved	100	12.30	2026-07-12
1d224113-52fd-42ec-a3d9-ee5e9338d4af	be632b24-428c-485a-92f7-5e9d91fe40fc	\N	fc439dd8-ff4f-4760-bcc2-e3cddcba6888	7891652b-f708-4834-90b3-b7e06f9dd5ab	بررسی و تمدید قراردادهای پرسنلی #86	\N	high	2026-08-13	dbb7ceb3-b66b-4ee8-957d-e9a3a736af99	2026-07-20 09:22:03.794401+00	2026-07-20 09:22:03.794401+00	completed	approved	100	25.50	2026-08-08
1d224113-52fd-42ec-a3d9-ee5e9338d4af	be632b24-428c-485a-92f7-5e9d91fe40fc	\N	57b624b6-2a61-45ab-95e9-0d4965be1a7e	7891652b-f708-4834-90b3-b7e06f9dd5ab	برنامه‌ریزی رویداد تیم‌سازی #87	\N	low	2026-08-10	b4f1bc3f-69fb-46fb-94f6-edebb2c3f6ad	2026-07-20 09:22:03.794401+00	2026-07-20 09:22:03.794401+00	todo	\N	77	9.60	2026-08-05
1d224113-52fd-42ec-a3d9-ee5e9338d4af	be632b24-428c-485a-92f7-5e9d91fe40fc	\N	57b624b6-2a61-45ab-95e9-0d4965be1a7e	7891652b-f708-4834-90b3-b7e06f9dd5ab	به‌روزرسانی آیین‌نامهٔ داخلی شرکت #88	\N	low	2026-07-23	19fd8715-62be-4642-aeab-9b13cd01cc52	2026-07-20 09:22:03.794401+00	2026-07-20 09:22:03.794401+00	completed	rejected	100	3.50	2026-07-08
1d224113-52fd-42ec-a3d9-ee5e9338d4af	be632b24-428c-485a-92f7-5e9d91fe40fc	\N	3623572f-edd3-4d8b-a827-788687faac93	7891652b-f708-4834-90b3-b7e06f9dd5ab	پیگیری درخواست‌های رفاهی کارکنان #89	\N	low	2026-08-16	23d9de8d-2c9a-4a22-9a1a-ebef6b86bf2b	2026-07-20 09:22:03.794401+00	2026-07-20 09:22:03.794401+00	in_progress	\N	0	2.50	2026-07-30
1d224113-52fd-42ec-a3d9-ee5e9338d4af	be632b24-428c-485a-92f7-5e9d91fe40fc	\N	7891652b-f708-4834-90b3-b7e06f9dd5ab	7891652b-f708-4834-90b3-b7e06f9dd5ab	پیگیری مرخصی و مأموریت کارکنان #90	\N	medium	2026-08-28	426cf68e-2159-4452-994a-ac59f9af1474	2026-07-20 09:22:03.794401+00	2026-07-20 09:22:03.794401+00	todo	\N	19	38.10	2026-08-08
1d224113-52fd-42ec-a3d9-ee5e9338d4af	\N	\N	39f6a330-2d20-4870-ba2a-2457ecb3df8d	39f6a330-2d20-4870-ba2a-2457ecb3df8d	بررسی درخواست ترفیع کارکنان #91	\N	medium	2026-08-06	39eafe94-4c3e-4bca-85e2-84d53c0f83bb	2026-07-20 09:22:03.794401+00	2026-07-20 09:22:03.794401+00	completed	approved	100	26.50	2026-08-01
1d224113-52fd-42ec-a3d9-ee5e9338d4af	\N	\N	3623572f-edd3-4d8b-a827-788687faac93	3623572f-edd3-4d8b-a827-788687faac93	بررسی رزومه‌های متقاضیان شغلی #92	\N	low	2026-07-18	e0724e21-69c6-4ec6-8ad6-b8ff1e1f4d74	2026-07-20 09:22:03.794401+00	2026-07-20 09:22:03.794401+00	in_progress	\N	22	35.20	2026-07-02
1d224113-52fd-42ec-a3d9-ee5e9338d4af	\N	\N	39f6a330-2d20-4870-ba2a-2457ecb3df8d	39f6a330-2d20-4870-ba2a-2457ecb3df8d	تهیهٔ فرم ارزیابی سه‌ماهه #93	\N	high	2026-07-21	62658005-b240-4fd4-88bb-55a72d231297	2026-07-20 09:22:03.794401+00	2026-07-20 09:22:03.794401+00	in_progress	\N	14	5.60	2026-07-09
1d224113-52fd-42ec-a3d9-ee5e9338d4af	\N	\N	39f6a330-2d20-4870-ba2a-2457ecb3df8d	39f6a330-2d20-4870-ba2a-2457ecb3df8d	پیگیری مرخصی و مأموریت کارکنان #94	\N	high	2026-06-22	9ef3a378-2e43-4a60-ab6b-b2ebac89ecf6	2026-07-20 09:22:03.794401+00	2026-07-20 09:22:03.794401+00	todo	\N	21	14.50	2026-06-16
1d224113-52fd-42ec-a3d9-ee5e9338d4af	\N	\N	3623572f-edd3-4d8b-a827-788687faac93	3623572f-edd3-4d8b-a827-788687faac93	پیگیری درخواست‌های رفاهی کارکنان #95	\N	medium	2026-08-05	f2ee974e-4ecf-46f2-b9b2-983c9f119cb7	2026-07-20 09:22:03.794401+00	2026-07-20 09:22:03.794401+00	completed	approved	100	8.90	2026-08-01
1d224113-52fd-42ec-a3d9-ee5e9338d4af	\N	\N	3623572f-edd3-4d8b-a827-788687faac93	3623572f-edd3-4d8b-a827-788687faac93	تهیهٔ گزارش غیبت و تأخیر #96	\N	medium	2026-07-25	f96c62d1-cef6-434f-9969-a2fc15e1d12e	2026-07-20 09:22:03.794401+00	2026-07-20 09:22:03.794401+00	in_progress	\N	61	32.40	2026-07-15
1d224113-52fd-42ec-a3d9-ee5e9338d4af	\N	\N	81977026-b6d9-4183-92f3-63f6484c7ae5	81977026-b6d9-4183-92f3-63f6484c7ae5	به‌روزرسانی پروندهٔ پرسنلی #97	\N	high	2026-06-29	203310af-6688-4a7f-a978-aff617c56316	2026-07-20 09:22:03.794401+00	2026-07-20 09:22:03.794401+00	todo	\N	7	39.30	2026-06-23
1d224113-52fd-42ec-a3d9-ee5e9338d4af	\N	\N	39f6a330-2d20-4870-ba2a-2457ecb3df8d	39f6a330-2d20-4870-ba2a-2457ecb3df8d	بررسی درخواست ترفیع کارکنان #98	\N	high	2026-07-07	e15605b6-9d65-49d7-b6e0-af9fe456fc99	2026-07-20 09:22:03.794401+00	2026-07-20 09:22:03.794401+00	todo	\N	61	32.50	2026-06-22
1d224113-52fd-42ec-a3d9-ee5e9338d4af	\N	\N	81977026-b6d9-4183-92f3-63f6484c7ae5	81977026-b6d9-4183-92f3-63f6484c7ae5	تدوین برنامهٔ آموزشی سال آینده #99	\N	low	2026-07-23	b247543e-fcf7-4120-b673-74f67ecc18ef	2026-07-20 09:22:03.794401+00	2026-07-20 09:22:03.794401+00	completed	approved	100	34.80	2026-07-10
1d224113-52fd-42ec-a3d9-ee5e9338d4af	\N	\N	39f6a330-2d20-4870-ba2a-2457ecb3df8d	39f6a330-2d20-4870-ba2a-2457ecb3df8d	برنامه‌ریزی رویداد تیم‌سازی #100	\N	medium	2026-08-18	1a7ffe5a-3df8-4d68-897f-9dd208c53776	2026-07-20 09:22:03.794401+00	2026-07-20 09:22:03.794401+00	archived	\N	14	35.70	2026-08-12
1d224113-52fd-42ec-a3d9-ee5e9338d4af	\N	\N	3623572f-edd3-4d8b-a827-788687faac93	3623572f-edd3-4d8b-a827-788687faac93	پیگیری مرخصی و مأموریت کارکنان #101	\N	medium	2026-06-30	3e1585fc-e879-4e86-be41-409912e66596	2026-07-20 09:22:03.794401+00	2026-07-20 09:22:03.794401+00	todo	\N	1	28.80	2026-06-20
1d224113-52fd-42ec-a3d9-ee5e9338d4af	\N	\N	81977026-b6d9-4183-92f3-63f6484c7ae5	81977026-b6d9-4183-92f3-63f6484c7ae5	برگزاری جلسهٔ آموزش کارکنان جدید #102	\N	high	2026-08-11	e641aa1c-3723-4bed-8f71-b2147f5171d9	2026-07-20 09:22:03.794401+00	2026-07-20 09:22:03.794401+00	completed	pending	100	35.20	2026-07-22
1d224113-52fd-42ec-a3d9-ee5e9338d4af	\N	\N	fc439dd8-ff4f-4760-bcc2-e3cddcba6888	fc439dd8-ff4f-4760-bcc2-e3cddcba6888	تهیهٔ فرم ارزیابی سه‌ماهه #103	\N	high	2026-07-30	2c7b24f0-1f0f-415f-a14e-0c5400652707	2026-07-20 09:22:03.794401+00	2026-07-20 09:22:03.794401+00	completed	pending	100	29.60	2026-07-25
1d224113-52fd-42ec-a3d9-ee5e9338d4af	\N	\N	3623572f-edd3-4d8b-a827-788687faac93	3623572f-edd3-4d8b-a827-788687faac93	تهیهٔ گزارش ارزیابی عملکرد #104	\N	high	2026-08-11	21d8b389-f887-4d50-b9b2-855ccaeaeccf	2026-07-20 09:22:03.794401+00	2026-07-20 09:22:03.794401+00	in_progress	\N	78	4.10	2026-07-28
1d224113-52fd-42ec-a3d9-ee5e9338d4af	\N	\N	81977026-b6d9-4183-92f3-63f6484c7ae5	81977026-b6d9-4183-92f3-63f6484c7ae5	تهیهٔ گزارش غیبت و تأخیر #105	\N	medium	2026-08-04	23ab724a-af56-41cc-87c1-f3581ad151fe	2026-07-20 09:22:03.794401+00	2026-07-20 09:22:03.794401+00	todo	\N	21	4.80	2026-07-18
\.


--
-- Data for Name: users; Type: TABLE DATA; Schema: public; Owner: -
--

COPY public.users (organization_id, email, hashed_password, full_name, role, is_active, id, created_at, updated_at, phone_number, department_id) FROM stdin;
1d224113-52fd-42ec-a3d9-ee5e9338d4af	admin@test.local	$2b$12$r49d8SjcCfwMyW7XU9si5ejJVLuJG2iMFNNTIhT7PN80rJcM5UhhG	مدیر سازمان	org_admin	t	35524a39-bb53-4f81-b913-a64fc2c0bc5e	2026-07-20 09:22:03.794401+00	2026-07-20 09:22:03.794401+00	09100000001	895d0d58-2797-442c-ab90-133cfd1997d5
1d224113-52fd-42ec-a3d9-ee5e9338d4af	eng.manager@test.local	$2b$12$kH4HHjUenNYEd2gHu4ij4eHZppme8GDx5aOVz7mtdnsUJhxEIZhna	مدیر پروژه مهندسی و فنی	project_manager	t	127c1187-f85a-48c8-82b5-451a4ccfeb71	2026-07-20 09:22:03.794401+00	2026-07-20 09:22:03.794401+00	09111000000	895d0d58-2797-442c-ab90-133cfd1997d5
1d224113-52fd-42ec-a3d9-ee5e9338d4af	eng.emp1@test.local	$2b$12$qZCQoMbX.jHYiqGmDR/xXO.U/LWWc2PlMiT.V5hXRAXiIp.tcYovO	کارمند 1 مهندسی و فنی	employee	t	0132fd66-319f-4f6e-8e2f-d16328d278e8	2026-07-20 09:22:03.794401+00	2026-07-20 09:22:03.794401+00	09111000011	895d0d58-2797-442c-ab90-133cfd1997d5
1d224113-52fd-42ec-a3d9-ee5e9338d4af	eng.emp2@test.local	$2b$12$qbZie.62PcmG2e9Pw0nSCOGDcs2C5691PJmlurZik.N3s/BQkMFeC	کارمند 2 مهندسی و فنی	employee	t	a2c3e527-82e9-4bd2-be63-85f6ead97337	2026-07-20 09:22:03.794401+00	2026-07-20 09:22:03.794401+00	09111000012	895d0d58-2797-442c-ab90-133cfd1997d5
1d224113-52fd-42ec-a3d9-ee5e9338d4af	eng.emp3@test.local	$2b$12$yJ2gQ/GpRT1mOcXQ4JPcv.F7834/iEy4bZ2uAVNJagTjTjmYDto4q	کارمند 3 مهندسی و فنی	employee	t	f4e6dc2a-b9f2-43e2-8db1-3516a3e2985c	2026-07-20 09:22:03.794401+00	2026-07-20 09:22:03.794401+00	09111000013	895d0d58-2797-442c-ab90-133cfd1997d5
1d224113-52fd-42ec-a3d9-ee5e9338d4af	eng.emp4@test.local	$2b$12$yfrczOIIRcVHCWKcvXuLVupN4RMJQK2Bimo7vsNCYg2eQvWnZ3N62	کارمند 4 مهندسی و فنی	employee	t	054f46d3-1cc2-42df-9532-2b310816822b	2026-07-20 09:22:03.794401+00	2026-07-20 09:22:03.794401+00	09111000014	895d0d58-2797-442c-ab90-133cfd1997d5
1d224113-52fd-42ec-a3d9-ee5e9338d4af	eng.emp5@test.local	$2b$12$ZRS2EgAqk19rRTsL5vXLi.FfF707HuTtK8TSdrSra5Dw2awrMmyIW	کارمند 5 مهندسی و فنی	employee	t	3940e09c-eede-4772-818b-3a4bc4703195	2026-07-20 09:22:03.794401+00	2026-07-20 09:22:03.794401+00	09111000015	895d0d58-2797-442c-ab90-133cfd1997d5
1d224113-52fd-42ec-a3d9-ee5e9338d4af	eng.emp6@test.local	$2b$12$0ewGfdVXGOWD8TjK5qS39.5anXqeO7kIj2GQ.4/lw1Tw6OXtMEMYa	کارمند 6 مهندسی و فنی	employee	t	6fb1a35d-b064-46b8-8796-54c4fec69d24	2026-07-20 09:22:03.794401+00	2026-07-20 09:22:03.794401+00	09111000016	895d0d58-2797-442c-ab90-133cfd1997d5
1d224113-52fd-42ec-a3d9-ee5e9338d4af	fin.manager@test.local	$2b$12$bmZJdDFGfMAiEe4dcN3P2O6Uj.K3NB5K39TpNx9yM7Na7UXKgnqBW	مدیر پروژه حسابداری و مالی	project_manager	t	b3e7b1f6-d818-46bc-a98e-9f7048e16f8f	2026-07-20 09:22:03.794401+00	2026-07-20 09:22:03.794401+00	09121000100	3203500b-f7b4-46ac-9894-9af6675608c0
1d224113-52fd-42ec-a3d9-ee5e9338d4af	fin.emp1@test.local	$2b$12$tmQkGPtPD1tF5kM06aSwcuzmhgFpvvE7qlZWxux8MKH6zaGvzzyP.	کارمند 1 حسابداری و مالی	employee	t	1bd96f4a-6acb-4464-8452-ca1d3114a328	2026-07-20 09:22:03.794401+00	2026-07-20 09:22:03.794401+00	09121000111	3203500b-f7b4-46ac-9894-9af6675608c0
1d224113-52fd-42ec-a3d9-ee5e9338d4af	fin.emp2@test.local	$2b$12$oOTumCa1zbpCkx7v0b/FA.Z0hDv4Tbl0a03hcw0XyFSbcnlfDEp8e	کارمند 2 حسابداری و مالی	employee	t	8cca3fcf-f7a7-421a-b9a4-5dab90fe1b83	2026-07-20 09:22:03.794401+00	2026-07-20 09:22:03.794401+00	09121000112	3203500b-f7b4-46ac-9894-9af6675608c0
1d224113-52fd-42ec-a3d9-ee5e9338d4af	fin.emp3@test.local	$2b$12$hQrHq8JrkUpOOzK9kPL6Ge4Rky3TSMHhqgSmWQt6ljO/rqzjALuee	کارمند 3 حسابداری و مالی	employee	t	1fd4dffb-d8db-4387-914a-be2a2a6fd6b1	2026-07-20 09:22:03.794401+00	2026-07-20 09:22:03.794401+00	09121000113	3203500b-f7b4-46ac-9894-9af6675608c0
1d224113-52fd-42ec-a3d9-ee5e9338d4af	fin.emp4@test.local	$2b$12$1OV2mhTINpgueOsP1O3UuONQwKXor2FNyOroR8y5VjykjNylvPpPe	کارمند 4 حسابداری و مالی	employee	t	b720465e-b31b-4b9b-99d6-b303ca5f639d	2026-07-20 09:22:03.794401+00	2026-07-20 09:22:03.794401+00	09121000114	3203500b-f7b4-46ac-9894-9af6675608c0
1d224113-52fd-42ec-a3d9-ee5e9338d4af	fin.emp5@test.local	$2b$12$6uJE5oxhnhvoP2OQZk1tdec.s.DnSAabSwOdyU45P73iC6EFa6Xfu	کارمند 5 حسابداری و مالی	employee	t	8a6bd071-9f82-4273-b101-9c763d6c4be4	2026-07-20 09:22:03.794401+00	2026-07-20 09:22:03.794401+00	09121000115	3203500b-f7b4-46ac-9894-9af6675608c0
1d224113-52fd-42ec-a3d9-ee5e9338d4af	fin.emp6@test.local	$2b$12$dsHtUEXaBHcXuQuhpKY1bu6/rSO7t9PEakbyWjF5joDKjjEMEwESO	کارمند 6 حسابداری و مالی	employee	t	03c131a9-29b0-4e66-8d67-be78cfa01885	2026-07-20 09:22:03.794401+00	2026-07-20 09:22:03.794401+00	09121000116	3203500b-f7b4-46ac-9894-9af6675608c0
1d224113-52fd-42ec-a3d9-ee5e9338d4af	hr.manager@test.local	$2b$12$Ij0E3WOpuM8PVcxy1t93Nu42MedaLgNIDxPiZRJLbZtRuNzRGZDom	مدیر پروژه منابع انسانی	project_manager	t	7891652b-f708-4834-90b3-b7e06f9dd5ab	2026-07-20 09:22:03.794401+00	2026-07-20 09:22:03.794401+00	09131000200	0058b701-84a4-4426-9d09-f89608fd6adc
1d224113-52fd-42ec-a3d9-ee5e9338d4af	hr.emp1@test.local	$2b$12$fWJIGSmPW2xgERL79aHLIeBnFISoSpOCIAzjLyKRee.MpCmqVtwGK	کارمند 1 منابع انسانی	employee	t	726b1bd0-c51d-4f38-9e37-f4c46a258d1b	2026-07-20 09:22:03.794401+00	2026-07-20 09:22:03.794401+00	09131000211	0058b701-84a4-4426-9d09-f89608fd6adc
1d224113-52fd-42ec-a3d9-ee5e9338d4af	hr.emp2@test.local	$2b$12$VVGk1P8rRMlEh0RqIdfR8e2WJxvdF880.m1CFIKKfk9vywoh3dNPu	کارمند 2 منابع انسانی	employee	t	57b624b6-2a61-45ab-95e9-0d4965be1a7e	2026-07-20 09:22:03.794401+00	2026-07-20 09:22:03.794401+00	09131000212	0058b701-84a4-4426-9d09-f89608fd6adc
1d224113-52fd-42ec-a3d9-ee5e9338d4af	hr.emp3@test.local	$2b$12$Xkl8ApcrIquoWJa46VJo.uMIEbIK45Cm/MhXB4xc9PpZ7LnfFbtdK	کارمند 3 منابع انسانی	employee	t	3623572f-edd3-4d8b-a827-788687faac93	2026-07-20 09:22:03.794401+00	2026-07-20 09:22:03.794401+00	09131000213	0058b701-84a4-4426-9d09-f89608fd6adc
1d224113-52fd-42ec-a3d9-ee5e9338d4af	hr.emp4@test.local	$2b$12$PRz3dL1mkf3Khr5vq3YnN..XentmwbXgQ1PtV4fqS6otvjK.j2ACC	کارمند 4 منابع انسانی	employee	t	fc439dd8-ff4f-4760-bcc2-e3cddcba6888	2026-07-20 09:22:03.794401+00	2026-07-20 09:22:03.794401+00	09131000214	0058b701-84a4-4426-9d09-f89608fd6adc
1d224113-52fd-42ec-a3d9-ee5e9338d4af	hr.emp5@test.local	$2b$12$nTsC.JgVzKYeHEdNwp7Lw.LkFmLhHoStgvtLZMBIasgwZBMoGRJhm	کارمند 5 منابع انسانی	employee	t	81977026-b6d9-4183-92f3-63f6484c7ae5	2026-07-20 09:22:03.794401+00	2026-07-20 09:22:03.794401+00	09131000215	0058b701-84a4-4426-9d09-f89608fd6adc
1d224113-52fd-42ec-a3d9-ee5e9338d4af	hr.emp6@test.local	$2b$12$jkvZtRIyAoK7GwEP./nbr.OEcIThkw6ltbFXzObhH/gNRXBJx1/VK	کارمند 6 منابع انسانی	employee	t	39f6a330-2d20-4870-ba2a-2457ecb3df8d	2026-07-20 09:22:03.794401+00	2026-07-20 09:22:03.794401+00	09131000216	0058b701-84a4-4426-9d09-f89608fd6adc
\.


--
-- Data for Name: worklogs; Type: TABLE DATA; Schema: public; Owner: -
--

COPY public.worklogs (organization_id, task_id, user_id, activity_description, time_spent_minutes, progress_percent, log_date, status, reviewed_by_id, review_comment, id, created_at, updated_at) FROM stdin;
1d224113-52fd-42ec-a3d9-ee5e9338d4af	d391b966-f5bc-4413-a9d4-80910cc91b86	3940e09c-eede-4772-818b-3a4bc4703195	مستندسازی و نهایی‌سازی	224	27	2026-07-12	approved	127c1187-f85a-48c8-82b5-451a4ccfeb71	\N	b27344b5-eab1-4ce8-8152-d47168e988d4	2026-07-20 09:22:03.794401+00	2026-07-20 09:22:03.794401+00
1d224113-52fd-42ec-a3d9-ee5e9338d4af	d391b966-f5bc-4413-a9d4-80910cc91b86	3940e09c-eede-4772-818b-3a4bc4703195	تست و اطمینان از عملکرد صحیح	144	40	2026-07-16	approved	127c1187-f85a-48c8-82b5-451a4ccfeb71	\N	75086fca-c7fc-4176-a85d-010b2238bae9	2026-07-20 09:22:03.794401+00	2026-07-20 09:22:03.794401+00
1d224113-52fd-42ec-a3d9-ee5e9338d4af	d391b966-f5bc-4413-a9d4-80910cc91b86	3940e09c-eede-4772-818b-3a4bc4703195	رفع اشکالات و بازبینی	86	96	2026-07-14	approved	127c1187-f85a-48c8-82b5-451a4ccfeb71	\N	e634c4c6-2e47-48ab-9472-3bd2c15bf27b	2026-07-20 09:22:03.794401+00	2026-07-20 09:22:03.794401+00
1d224113-52fd-42ec-a3d9-ee5e9338d4af	d391b966-f5bc-4413-a9d4-80910cc91b86	3940e09c-eede-4772-818b-3a4bc4703195	رفع اشکالات و بازبینی	199	100	2026-07-16	approved	127c1187-f85a-48c8-82b5-451a4ccfeb71	\N	21c55080-077a-49b5-8aa8-94dca1703b66	2026-07-20 09:22:03.794401+00	2026-07-20 09:22:03.794401+00
1d224113-52fd-42ec-a3d9-ee5e9338d4af	9be8a4f5-bcde-4fe7-81d8-5e49bd68c1ca	0132fd66-319f-4f6e-8e2f-d16328d278e8	مستندسازی و نهایی‌سازی	165	31	2026-07-07	approved	127c1187-f85a-48c8-82b5-451a4ccfeb71	\N	9032eaa1-300e-4733-b553-efcd0686f15e	2026-07-20 09:22:03.794401+00	2026-07-20 09:22:03.794401+00
1d224113-52fd-42ec-a3d9-ee5e9338d4af	9be8a4f5-bcde-4fe7-81d8-5e49bd68c1ca	0132fd66-319f-4f6e-8e2f-d16328d278e8	مستندسازی و نهایی‌سازی	114	62	2026-07-11	approved	127c1187-f85a-48c8-82b5-451a4ccfeb71	\N	cdf58567-018c-4fd6-8d93-8af7e1b3ed16	2026-07-20 09:22:03.794401+00	2026-07-20 09:22:03.794401+00
1d224113-52fd-42ec-a3d9-ee5e9338d4af	9be8a4f5-bcde-4fe7-81d8-5e49bd68c1ca	0132fd66-319f-4f6e-8e2f-d16328d278e8	رفع اشکالات و بازبینی	108	84	2026-07-15	approved	127c1187-f85a-48c8-82b5-451a4ccfeb71	\N	6370c891-2cb6-48b0-ae89-5306859c44ef	2026-07-20 09:22:03.794401+00	2026-07-20 09:22:03.794401+00
1d224113-52fd-42ec-a3d9-ee5e9338d4af	28faaba2-c852-4bb9-82b4-9aacbb28b37a	a2c3e527-82e9-4bd2-be63-85f6ead97337	پیاده‌سازی بخش اصلی	110	23	2026-06-18	approved	127c1187-f85a-48c8-82b5-451a4ccfeb71	\N	abfdd0c7-020f-4eb8-a787-b01f6ac45779	2026-07-20 09:22:03.794401+00	2026-07-20 09:22:03.794401+00
1d224113-52fd-42ec-a3d9-ee5e9338d4af	28faaba2-c852-4bb9-82b4-9aacbb28b37a	a2c3e527-82e9-4bd2-be63-85f6ead97337	پیاده‌سازی بخش اصلی	85	70	2026-06-20	approved	127c1187-f85a-48c8-82b5-451a4ccfeb71	\N	17f084c7-ad98-4fd7-ab2d-333f8b909bf6	2026-07-20 09:22:03.794401+00	2026-07-20 09:22:03.794401+00
1d224113-52fd-42ec-a3d9-ee5e9338d4af	12464624-7623-4db7-beed-bf673646034b	a2c3e527-82e9-4bd2-be63-85f6ead97337	پیشرفت اولیه و بررسی نیازمندی‌ها	79	29	2026-06-20	approved	127c1187-f85a-48c8-82b5-451a4ccfeb71	\N	d3e6ac1a-448f-4b68-8540-805797f1d87f	2026-07-20 09:22:03.794401+00	2026-07-20 09:22:03.794401+00
1d224113-52fd-42ec-a3d9-ee5e9338d4af	12464624-7623-4db7-beed-bf673646034b	a2c3e527-82e9-4bd2-be63-85f6ead97337	رفع اشکالات و بازبینی	75	58	2026-06-22	approved	127c1187-f85a-48c8-82b5-451a4ccfeb71	\N	d53c8b40-26c5-4256-9b08-64ebdafb885b	2026-07-20 09:22:03.794401+00	2026-07-20 09:22:03.794401+00
1d224113-52fd-42ec-a3d9-ee5e9338d4af	12464624-7623-4db7-beed-bf673646034b	a2c3e527-82e9-4bd2-be63-85f6ead97337	مستندسازی و نهایی‌سازی	62	84	2026-06-22	approved	127c1187-f85a-48c8-82b5-451a4ccfeb71	\N	8f5c4d4f-186e-407a-b28f-7237172e69b3	2026-07-20 09:22:03.794401+00	2026-07-20 09:22:03.794401+00
1d224113-52fd-42ec-a3d9-ee5e9338d4af	61614765-4c0b-49ba-9512-588294729146	127c1187-f85a-48c8-82b5-451a4ccfeb71	پیاده‌سازی بخش اصلی	193	35	2026-07-16	approved	127c1187-f85a-48c8-82b5-451a4ccfeb71	\N	9beebe23-ddec-495a-81c7-d27a27409df4	2026-07-20 09:22:03.794401+00	2026-07-20 09:22:03.794401+00
1d224113-52fd-42ec-a3d9-ee5e9338d4af	eef01f0a-0620-4249-8488-551b21bbc2ba	3940e09c-eede-4772-818b-3a4bc4703195	مستندسازی و نهایی‌سازی	102	35	2026-07-16	approved	127c1187-f85a-48c8-82b5-451a4ccfeb71	\N	085e9e36-a336-4cb1-883b-fc3068cac68e	2026-07-20 09:22:03.794401+00	2026-07-20 09:22:03.794401+00
1d224113-52fd-42ec-a3d9-ee5e9338d4af	1d660afb-9ee2-45ce-a316-483405c3efc4	f4e6dc2a-b9f2-43e2-8db1-3516a3e2985c	پیشرفت اولیه و بررسی نیازمندی‌ها	94	35	2026-07-03	approved	127c1187-f85a-48c8-82b5-451a4ccfeb71	\N	9a85ce86-6703-4291-ba31-0ff869b9c8b4	2026-07-20 09:22:03.794401+00	2026-07-20 09:22:03.794401+00
1d224113-52fd-42ec-a3d9-ee5e9338d4af	1d660afb-9ee2-45ce-a316-483405c3efc4	f4e6dc2a-b9f2-43e2-8db1-3516a3e2985c	تست و اطمینان از عملکرد صحیح	155	44	2026-07-04	submitted	\N	\N	5168b93c-56ff-4ba9-97f4-adc06ca4a709	2026-07-20 09:22:03.794401+00	2026-07-20 09:22:03.794401+00
1d224113-52fd-42ec-a3d9-ee5e9338d4af	1d660afb-9ee2-45ce-a316-483405c3efc4	f4e6dc2a-b9f2-43e2-8db1-3516a3e2985c	مستندسازی و نهایی‌سازی	107	66	2026-07-05	approved	127c1187-f85a-48c8-82b5-451a4ccfeb71	\N	7a1c3139-6849-4add-a807-5019b08ac33f	2026-07-20 09:22:03.794401+00	2026-07-20 09:22:03.794401+00
1d224113-52fd-42ec-a3d9-ee5e9338d4af	1d660afb-9ee2-45ce-a316-483405c3efc4	f4e6dc2a-b9f2-43e2-8db1-3516a3e2985c	تست و اطمینان از عملکرد صحیح	185	100	2026-07-09	approved	127c1187-f85a-48c8-82b5-451a4ccfeb71	\N	e3c61fc5-3199-4c6c-93e4-207830da50e5	2026-07-20 09:22:03.794401+00	2026-07-20 09:22:03.794401+00
1d224113-52fd-42ec-a3d9-ee5e9338d4af	cdb0ff10-2e9e-414d-b8e2-0a0978bf4b34	0132fd66-319f-4f6e-8e2f-d16328d278e8	تست و اطمینان از عملکرد صحیح	143	29	2026-07-06	approved	127c1187-f85a-48c8-82b5-451a4ccfeb71	\N	da5bcc43-426b-488c-a2c4-a461257e78cb	2026-07-20 09:22:03.794401+00	2026-07-20 09:22:03.794401+00
1d224113-52fd-42ec-a3d9-ee5e9338d4af	cdb0ff10-2e9e-414d-b8e2-0a0978bf4b34	0132fd66-319f-4f6e-8e2f-d16328d278e8	رفع اشکالات و بازبینی	175	78	2026-07-10	approved	127c1187-f85a-48c8-82b5-451a4ccfeb71	\N	05f63b80-c562-4f1a-830b-4c5b30674e36	2026-07-20 09:22:03.794401+00	2026-07-20 09:22:03.794401+00
1d224113-52fd-42ec-a3d9-ee5e9338d4af	2fc2c5ea-092e-49cc-8d60-b57eba9e90b7	3940e09c-eede-4772-818b-3a4bc4703195	پیاده‌سازی بخش اصلی	190	26	2026-06-24	approved	127c1187-f85a-48c8-82b5-451a4ccfeb71	\N	03acaa76-1e46-4490-a368-185198b4288a	2026-07-20 09:22:03.794401+00	2026-07-20 09:22:03.794401+00
1d224113-52fd-42ec-a3d9-ee5e9338d4af	6c865051-e24c-4452-bbb9-579c19eeba07	3940e09c-eede-4772-818b-3a4bc4703195	پیاده‌سازی بخش اصلی	91	25	2026-07-16	approved	127c1187-f85a-48c8-82b5-451a4ccfeb71	\N	94f71941-6008-4d11-9c52-18099b736c31	2026-07-20 09:22:03.794401+00	2026-07-20 09:22:03.794401+00
1d224113-52fd-42ec-a3d9-ee5e9338d4af	6c865051-e24c-4452-bbb9-579c19eeba07	3940e09c-eede-4772-818b-3a4bc4703195	پیاده‌سازی بخش اصلی	30	66	2026-07-16	approved	127c1187-f85a-48c8-82b5-451a4ccfeb71	\N	be63965d-9858-4b93-b7fd-0ceb1eda5a16	2026-07-20 09:22:03.794401+00	2026-07-20 09:22:03.794401+00
1d224113-52fd-42ec-a3d9-ee5e9338d4af	6c865051-e24c-4452-bbb9-579c19eeba07	3940e09c-eede-4772-818b-3a4bc4703195	مستندسازی و نهایی‌سازی	150	87	2026-07-16	approved	127c1187-f85a-48c8-82b5-451a4ccfeb71	\N	979e15b5-3a63-46a0-970e-5b6a095f68d8	2026-07-20 09:22:03.794401+00	2026-07-20 09:22:03.794401+00
1d224113-52fd-42ec-a3d9-ee5e9338d4af	d4f816b1-d0a2-4fbc-833f-2668b871000e	0132fd66-319f-4f6e-8e2f-d16328d278e8	رفع اشکالات و بازبینی	210	29	2026-07-16	approved	127c1187-f85a-48c8-82b5-451a4ccfeb71	\N	8b291d5f-4c6c-440b-819b-44a452b22fec	2026-07-20 09:22:03.794401+00	2026-07-20 09:22:03.794401+00
1d224113-52fd-42ec-a3d9-ee5e9338d4af	b66d2149-0c4e-4d83-8918-57fb47f3d170	0132fd66-319f-4f6e-8e2f-d16328d278e8	پیاده‌سازی بخش اصلی	97	40	2026-06-20	approved	127c1187-f85a-48c8-82b5-451a4ccfeb71	\N	259b0d11-4f90-4717-b600-c6f27dab143a	2026-07-20 09:22:03.794401+00	2026-07-20 09:22:03.794401+00
1d224113-52fd-42ec-a3d9-ee5e9338d4af	b66d2149-0c4e-4d83-8918-57fb47f3d170	0132fd66-319f-4f6e-8e2f-d16328d278e8	تست و اطمینان از عملکرد صحیح	59	74	2026-06-22	approved	127c1187-f85a-48c8-82b5-451a4ccfeb71	\N	8adca167-b685-4d1f-91b6-fd423752c274	2026-07-20 09:22:03.794401+00	2026-07-20 09:22:03.794401+00
1d224113-52fd-42ec-a3d9-ee5e9338d4af	b66d2149-0c4e-4d83-8918-57fb47f3d170	0132fd66-319f-4f6e-8e2f-d16328d278e8	پیاده‌سازی بخش اصلی	98	72	2026-06-24	approved	127c1187-f85a-48c8-82b5-451a4ccfeb71	\N	2c5e25a2-94c7-48b5-9713-7b3e02624aaa	2026-07-20 09:22:03.794401+00	2026-07-20 09:22:03.794401+00
1d224113-52fd-42ec-a3d9-ee5e9338d4af	b66d2149-0c4e-4d83-8918-57fb47f3d170	0132fd66-319f-4f6e-8e2f-d16328d278e8	پیشرفت اولیه و بررسی نیازمندی‌ها	72	100	2026-06-23	approved	127c1187-f85a-48c8-82b5-451a4ccfeb71	\N	c64e040e-e229-45ae-a62f-3da7bffa2ece	2026-07-20 09:22:03.794401+00	2026-07-20 09:22:03.794401+00
1d224113-52fd-42ec-a3d9-ee5e9338d4af	d0e4ab58-5e97-41f3-a33b-d4782982ca57	054f46d3-1cc2-42df-9532-2b310816822b	رفع اشکالات و بازبینی	209	32	2026-07-16	approved	127c1187-f85a-48c8-82b5-451a4ccfeb71	\N	7ba63331-4174-4aee-abfb-38d3a49d597f	2026-07-20 09:22:03.794401+00	2026-07-20 09:22:03.794401+00
1d224113-52fd-42ec-a3d9-ee5e9338d4af	d0e4ab58-5e97-41f3-a33b-d4782982ca57	054f46d3-1cc2-42df-9532-2b310816822b	تست و اطمینان از عملکرد صحیح	142	44	2026-07-16	approved	127c1187-f85a-48c8-82b5-451a4ccfeb71	\N	cc580007-710a-4263-bf82-eb6f6e73841b	2026-07-20 09:22:03.794401+00	2026-07-20 09:22:03.794401+00
1d224113-52fd-42ec-a3d9-ee5e9338d4af	d0e4ab58-5e97-41f3-a33b-d4782982ca57	054f46d3-1cc2-42df-9532-2b310816822b	رفع اشکالات و بازبینی	184	84	2026-07-16	submitted	\N	\N	bf2100b3-4b9b-41cb-a04d-f16a481ccb4f	2026-07-20 09:22:03.794401+00	2026-07-20 09:22:03.794401+00
1d224113-52fd-42ec-a3d9-ee5e9338d4af	3bc9185c-349c-4dcc-89ca-afb1092ebccb	054f46d3-1cc2-42df-9532-2b310816822b	پیاده‌سازی بخش اصلی	202	38	2026-07-03	approved	127c1187-f85a-48c8-82b5-451a4ccfeb71	\N	043a4c01-58cd-41f2-8f78-9c9fb736da11	2026-07-20 09:22:03.794401+00	2026-07-20 09:22:03.794401+00
1d224113-52fd-42ec-a3d9-ee5e9338d4af	6733cdad-fd8b-4bbb-b75f-a085077d5f07	127c1187-f85a-48c8-82b5-451a4ccfeb71	مستندسازی و نهایی‌سازی	40	25	2026-07-16	approved	127c1187-f85a-48c8-82b5-451a4ccfeb71	\N	5a0cdbdb-506c-4dc7-90e4-a68ba1b13dce	2026-07-20 09:22:03.794401+00	2026-07-20 09:22:03.794401+00
1d224113-52fd-42ec-a3d9-ee5e9338d4af	4ebec8b6-f8d9-40c6-8e84-0780df9f741b	6fb1a35d-b064-46b8-8796-54c4fec69d24	رفع اشکالات و بازبینی	76	38	2026-07-16	approved	127c1187-f85a-48c8-82b5-451a4ccfeb71	\N	17b3636f-208f-4f7f-82d6-3b0a46e1e5b0	2026-07-20 09:22:03.794401+00	2026-07-20 09:22:03.794401+00
1d224113-52fd-42ec-a3d9-ee5e9338d4af	4ebec8b6-f8d9-40c6-8e84-0780df9f741b	6fb1a35d-b064-46b8-8796-54c4fec69d24	تست و اطمینان از عملکرد صحیح	53	70	2026-07-16	approved	127c1187-f85a-48c8-82b5-451a4ccfeb71	\N	5e02ea62-c536-4a13-83d1-40b79cfad340	2026-07-20 09:22:03.794401+00	2026-07-20 09:22:03.794401+00
1d224113-52fd-42ec-a3d9-ee5e9338d4af	4ebec8b6-f8d9-40c6-8e84-0780df9f741b	6fb1a35d-b064-46b8-8796-54c4fec69d24	تست و اطمینان از عملکرد صحیح	115	90	2026-07-16	approved	127c1187-f85a-48c8-82b5-451a4ccfeb71	\N	cd142012-cf68-4282-a7f7-8336014a85f1	2026-07-20 09:22:03.794401+00	2026-07-20 09:22:03.794401+00
1d224113-52fd-42ec-a3d9-ee5e9338d4af	4ebec8b6-f8d9-40c6-8e84-0780df9f741b	6fb1a35d-b064-46b8-8796-54c4fec69d24	پیاده‌سازی بخش اصلی	114	100	2026-07-16	approved	127c1187-f85a-48c8-82b5-451a4ccfeb71	\N	4b1aeeb8-6736-451d-9580-062e757c3406	2026-07-20 09:22:03.794401+00	2026-07-20 09:22:03.794401+00
1d224113-52fd-42ec-a3d9-ee5e9338d4af	80a197cb-7e36-44e7-a218-6e7d635b1f0d	0132fd66-319f-4f6e-8e2f-d16328d278e8	تست و اطمینان از عملکرد صحیح	238	37	2026-07-16	approved	127c1187-f85a-48c8-82b5-451a4ccfeb71	\N	dbd57b82-fc88-4fa7-ac9c-f5724fa3a2c3	2026-07-20 09:22:03.794401+00	2026-07-20 09:22:03.794401+00
1d224113-52fd-42ec-a3d9-ee5e9338d4af	80a197cb-7e36-44e7-a218-6e7d635b1f0d	0132fd66-319f-4f6e-8e2f-d16328d278e8	تست و اطمینان از عملکرد صحیح	52	60	2026-07-16	approved	127c1187-f85a-48c8-82b5-451a4ccfeb71	\N	bf57fdd8-c804-41d2-af0d-504fd843979b	2026-07-20 09:22:03.794401+00	2026-07-20 09:22:03.794401+00
1d224113-52fd-42ec-a3d9-ee5e9338d4af	80a197cb-7e36-44e7-a218-6e7d635b1f0d	0132fd66-319f-4f6e-8e2f-d16328d278e8	رفع اشکالات و بازبینی	59	96	2026-07-16	approved	127c1187-f85a-48c8-82b5-451a4ccfeb71	\N	6dc49f27-67f7-474d-ad3c-f96236eb782e	2026-07-20 09:22:03.794401+00	2026-07-20 09:22:03.794401+00
1d224113-52fd-42ec-a3d9-ee5e9338d4af	80a197cb-7e36-44e7-a218-6e7d635b1f0d	0132fd66-319f-4f6e-8e2f-d16328d278e8	مستندسازی و نهایی‌سازی	148	100	2026-07-16	approved	127c1187-f85a-48c8-82b5-451a4ccfeb71	\N	41ea7b96-3914-4a2a-bbc5-e5cda807d03d	2026-07-20 09:22:03.794401+00	2026-07-20 09:22:03.794401+00
1d224113-52fd-42ec-a3d9-ee5e9338d4af	49d64b94-91ad-47f3-80da-0a18c2a4397a	f4e6dc2a-b9f2-43e2-8db1-3516a3e2985c	مستندسازی و نهایی‌سازی	223	35	2026-07-16	approved	127c1187-f85a-48c8-82b5-451a4ccfeb71	\N	a9f1971e-2ee1-4682-8106-c81c4d0a98a6	2026-07-20 09:22:03.794401+00	2026-07-20 09:22:03.794401+00
1d224113-52fd-42ec-a3d9-ee5e9338d4af	a80e9479-197d-46fc-9a38-afcf28eafa98	f4e6dc2a-b9f2-43e2-8db1-3516a3e2985c	پیاده‌سازی بخش اصلی	98	37	2026-07-14	approved	127c1187-f85a-48c8-82b5-451a4ccfeb71	\N	46a629cf-818d-4b9a-b65d-b6e5d53447ca	2026-07-20 09:22:03.794401+00	2026-07-20 09:22:03.794401+00
1d224113-52fd-42ec-a3d9-ee5e9338d4af	a80e9479-197d-46fc-9a38-afcf28eafa98	f4e6dc2a-b9f2-43e2-8db1-3516a3e2985c	رفع اشکالات و بازبینی	142	70	2026-07-16	approved	127c1187-f85a-48c8-82b5-451a4ccfeb71	\N	c9916567-de6e-477a-ac06-c017dd1598bd	2026-07-20 09:22:03.794401+00	2026-07-20 09:22:03.794401+00
1d224113-52fd-42ec-a3d9-ee5e9338d4af	a80e9479-197d-46fc-9a38-afcf28eafa98	f4e6dc2a-b9f2-43e2-8db1-3516a3e2985c	پیشرفت اولیه و بررسی نیازمندی‌ها	191	100	2026-07-16	approved	127c1187-f85a-48c8-82b5-451a4ccfeb71	\N	7c4847e5-a1b2-44c0-9449-5456d45ab426	2026-07-20 09:22:03.794401+00	2026-07-20 09:22:03.794401+00
1d224113-52fd-42ec-a3d9-ee5e9338d4af	a80e9479-197d-46fc-9a38-afcf28eafa98	f4e6dc2a-b9f2-43e2-8db1-3516a3e2985c	پیاده‌سازی بخش اصلی	109	100	2026-07-16	approved	127c1187-f85a-48c8-82b5-451a4ccfeb71	\N	c1f44b66-6019-4dcf-ba33-f29b2a8085b4	2026-07-20 09:22:03.794401+00	2026-07-20 09:22:03.794401+00
1d224113-52fd-42ec-a3d9-ee5e9338d4af	d7bbe2ef-961b-499f-ab23-de9f62cb8960	127c1187-f85a-48c8-82b5-451a4ccfeb71	پیشرفت اولیه و بررسی نیازمندی‌ها	148	23	2026-06-17	approved	127c1187-f85a-48c8-82b5-451a4ccfeb71	\N	a34e8d2c-21f1-4e39-b2e7-24abf7a73826	2026-07-20 09:22:03.794401+00	2026-07-20 09:22:03.794401+00
1d224113-52fd-42ec-a3d9-ee5e9338d4af	bdac96fc-838e-4ad6-8910-02418cb5da92	127c1187-f85a-48c8-82b5-451a4ccfeb71	رفع اشکالات و بازبینی	160	28	2026-07-16	approved	127c1187-f85a-48c8-82b5-451a4ccfeb71	\N	f75ed4aa-7372-487d-a865-081a253356e0	2026-07-20 09:22:03.794401+00	2026-07-20 09:22:03.794401+00
1d224113-52fd-42ec-a3d9-ee5e9338d4af	bdac96fc-838e-4ad6-8910-02418cb5da92	127c1187-f85a-48c8-82b5-451a4ccfeb71	تست و اطمینان از عملکرد صحیح	150	54	2026-07-16	approved	127c1187-f85a-48c8-82b5-451a4ccfeb71	\N	064ac59f-cd22-43ce-8480-536f46053718	2026-07-20 09:22:03.794401+00	2026-07-20 09:22:03.794401+00
1d224113-52fd-42ec-a3d9-ee5e9338d4af	66785bb2-15d7-470b-966e-4508bfe0b1f7	127c1187-f85a-48c8-82b5-451a4ccfeb71	تست و اطمینان از عملکرد صحیح	78	39	2026-07-16	approved	127c1187-f85a-48c8-82b5-451a4ccfeb71	\N	8e1656e8-e239-49e9-9ece-d61ab79a9067	2026-07-20 09:22:03.794401+00	2026-07-20 09:22:03.794401+00
1d224113-52fd-42ec-a3d9-ee5e9338d4af	66785bb2-15d7-470b-966e-4508bfe0b1f7	127c1187-f85a-48c8-82b5-451a4ccfeb71	پیشرفت اولیه و بررسی نیازمندی‌ها	100	66	2026-07-16	approved	127c1187-f85a-48c8-82b5-451a4ccfeb71	\N	3f142b56-e273-4af4-81b0-99538ce5d48f	2026-07-20 09:22:03.794401+00	2026-07-20 09:22:03.794401+00
1d224113-52fd-42ec-a3d9-ee5e9338d4af	66785bb2-15d7-470b-966e-4508bfe0b1f7	127c1187-f85a-48c8-82b5-451a4ccfeb71	مستندسازی و نهایی‌سازی	98	60	2026-07-16	approved	127c1187-f85a-48c8-82b5-451a4ccfeb71	\N	96aa137f-aef9-4a51-be9c-58a6b84d065b	2026-07-20 09:22:03.794401+00	2026-07-20 09:22:03.794401+00
1d224113-52fd-42ec-a3d9-ee5e9338d4af	66785bb2-15d7-470b-966e-4508bfe0b1f7	127c1187-f85a-48c8-82b5-451a4ccfeb71	رفع اشکالات و بازبینی	180	100	2026-07-16	approved	127c1187-f85a-48c8-82b5-451a4ccfeb71	\N	0338ab9a-7ce5-4c2a-9335-ff61dd66feb3	2026-07-20 09:22:03.794401+00	2026-07-20 09:22:03.794401+00
1d224113-52fd-42ec-a3d9-ee5e9338d4af	058a95ee-c022-44a2-bae4-a8d597aa64c1	054f46d3-1cc2-42df-9532-2b310816822b	تست و اطمینان از عملکرد صحیح	167	35	2026-07-16	approved	127c1187-f85a-48c8-82b5-451a4ccfeb71	\N	31fcb4d8-260a-468f-b3d7-06d6c63bab2f	2026-07-20 09:22:03.794401+00	2026-07-20 09:22:03.794401+00
1d224113-52fd-42ec-a3d9-ee5e9338d4af	058a95ee-c022-44a2-bae4-a8d597aa64c1	054f46d3-1cc2-42df-9532-2b310816822b	رفع اشکالات و بازبینی	171	74	2026-07-16	approved	127c1187-f85a-48c8-82b5-451a4ccfeb71	\N	dafd6082-50f8-45cf-ade8-c7d70c617744	2026-07-20 09:22:03.794401+00	2026-07-20 09:22:03.794401+00
1d224113-52fd-42ec-a3d9-ee5e9338d4af	058a95ee-c022-44a2-bae4-a8d597aa64c1	054f46d3-1cc2-42df-9532-2b310816822b	تست و اطمینان از عملکرد صحیح	112	78	2026-07-16	approved	127c1187-f85a-48c8-82b5-451a4ccfeb71	\N	936e2816-d1d9-42b8-9d61-dd963f3bacf4	2026-07-20 09:22:03.794401+00	2026-07-20 09:22:03.794401+00
1d224113-52fd-42ec-a3d9-ee5e9338d4af	058a95ee-c022-44a2-bae4-a8d597aa64c1	054f46d3-1cc2-42df-9532-2b310816822b	مستندسازی و نهایی‌سازی	128	100	2026-07-16	approved	127c1187-f85a-48c8-82b5-451a4ccfeb71	\N	a1997249-607f-4d48-ab16-58ab42c3d3fe	2026-07-20 09:22:03.794401+00	2026-07-20 09:22:03.794401+00
1d224113-52fd-42ec-a3d9-ee5e9338d4af	a5c50e16-3ca8-4a9b-b4a4-a857d59488d8	127c1187-f85a-48c8-82b5-451a4ccfeb71	رفع اشکالات و بازبینی	220	35	2026-07-13	approved	127c1187-f85a-48c8-82b5-451a4ccfeb71	\N	9368e127-7fd8-47e2-aa4c-bb0ed33bf5b7	2026-07-20 09:22:03.794401+00	2026-07-20 09:22:03.794401+00
1d224113-52fd-42ec-a3d9-ee5e9338d4af	a5c50e16-3ca8-4a9b-b4a4-a857d59488d8	127c1187-f85a-48c8-82b5-451a4ccfeb71	تست و اطمینان از عملکرد صحیح	199	80	2026-07-16	approved	127c1187-f85a-48c8-82b5-451a4ccfeb71	\N	32163fac-ffaa-4906-a341-9cce3d17d83c	2026-07-20 09:22:03.794401+00	2026-07-20 09:22:03.794401+00
1d224113-52fd-42ec-a3d9-ee5e9338d4af	a5c50e16-3ca8-4a9b-b4a4-a857d59488d8	127c1187-f85a-48c8-82b5-451a4ccfeb71	تست و اطمینان از عملکرد صحیح	39	72	2026-07-16	approved	127c1187-f85a-48c8-82b5-451a4ccfeb71	\N	9878598c-2979-41ba-9b5c-93826dd7703b	2026-07-20 09:22:03.794401+00	2026-07-20 09:22:03.794401+00
1d224113-52fd-42ec-a3d9-ee5e9338d4af	a5c50e16-3ca8-4a9b-b4a4-a857d59488d8	127c1187-f85a-48c8-82b5-451a4ccfeb71	پیشرفت اولیه و بررسی نیازمندی‌ها	142	92	2026-07-16	approved	127c1187-f85a-48c8-82b5-451a4ccfeb71	\N	84fecd43-e9d5-4f8a-a8e0-df5c261e0423	2026-07-20 09:22:03.794401+00	2026-07-20 09:22:03.794401+00
1d224113-52fd-42ec-a3d9-ee5e9338d4af	a85de88e-07a4-4424-a8d2-4db147382f9e	3940e09c-eede-4772-818b-3a4bc4703195	پیاده‌سازی بخش اصلی	134	40	2026-07-11	approved	127c1187-f85a-48c8-82b5-451a4ccfeb71	\N	839e3fff-f093-416a-8c42-32077bdac108	2026-07-20 09:22:03.794401+00	2026-07-20 09:22:03.794401+00
1d224113-52fd-42ec-a3d9-ee5e9338d4af	a85de88e-07a4-4424-a8d2-4db147382f9e	3940e09c-eede-4772-818b-3a4bc4703195	پیشرفت اولیه و بررسی نیازمندی‌ها	150	56	2026-07-13	approved	127c1187-f85a-48c8-82b5-451a4ccfeb71	\N	fc3d1288-83b4-42ae-82ae-6bd8f2304daa	2026-07-20 09:22:03.794401+00	2026-07-20 09:22:03.794401+00
1d224113-52fd-42ec-a3d9-ee5e9338d4af	a85de88e-07a4-4424-a8d2-4db147382f9e	3940e09c-eede-4772-818b-3a4bc4703195	مستندسازی و نهایی‌سازی	207	96	2026-07-16	approved	127c1187-f85a-48c8-82b5-451a4ccfeb71	\N	3625eb4b-f5fe-41e4-998b-b44e1a2f0d2e	2026-07-20 09:22:03.794401+00	2026-07-20 09:22:03.794401+00
1d224113-52fd-42ec-a3d9-ee5e9338d4af	a85de88e-07a4-4424-a8d2-4db147382f9e	3940e09c-eede-4772-818b-3a4bc4703195	رفع اشکالات و بازبینی	202	100	2026-07-14	approved	127c1187-f85a-48c8-82b5-451a4ccfeb71	\N	5e071b6b-ca14-4099-8972-0b538b8c508c	2026-07-20 09:22:03.794401+00	2026-07-20 09:22:03.794401+00
1d224113-52fd-42ec-a3d9-ee5e9338d4af	24ad9cb4-3448-4772-9488-9e0748c60808	0132fd66-319f-4f6e-8e2f-d16328d278e8	تست و اطمینان از عملکرد صحیح	168	21	2026-07-13	approved	127c1187-f85a-48c8-82b5-451a4ccfeb71	\N	857a5903-8094-4a96-a9c6-55af86b9f1fc	2026-07-20 09:22:03.794401+00	2026-07-20 09:22:03.794401+00
1d224113-52fd-42ec-a3d9-ee5e9338d4af	24ad9cb4-3448-4772-9488-9e0748c60808	0132fd66-319f-4f6e-8e2f-d16328d278e8	پیاده‌سازی بخش اصلی	191	58	2026-07-14	approved	127c1187-f85a-48c8-82b5-451a4ccfeb71	\N	e7db5cfb-017c-4ec9-a1d9-787c638ec424	2026-07-20 09:22:03.794401+00	2026-07-20 09:22:03.794401+00
1d224113-52fd-42ec-a3d9-ee5e9338d4af	24ad9cb4-3448-4772-9488-9e0748c60808	0132fd66-319f-4f6e-8e2f-d16328d278e8	پیشرفت اولیه و بررسی نیازمندی‌ها	141	69	2026-07-16	approved	127c1187-f85a-48c8-82b5-451a4ccfeb71	\N	20e48640-ade5-4cc7-9643-1d40aa16f4dc	2026-07-20 09:22:03.794401+00	2026-07-20 09:22:03.794401+00
1d224113-52fd-42ec-a3d9-ee5e9338d4af	24ad9cb4-3448-4772-9488-9e0748c60808	0132fd66-319f-4f6e-8e2f-d16328d278e8	تست و اطمینان از عملکرد صحیح	72	100	2026-07-16	approved	127c1187-f85a-48c8-82b5-451a4ccfeb71	\N	1a73d269-6936-4ec2-bf43-7be840ff8eac	2026-07-20 09:22:03.794401+00	2026-07-20 09:22:03.794401+00
1d224113-52fd-42ec-a3d9-ee5e9338d4af	f8bba7b1-a50e-423c-89c7-eca8b52dab41	127c1187-f85a-48c8-82b5-451a4ccfeb71	رفع اشکالات و بازبینی	233	21	2026-07-16	approved	127c1187-f85a-48c8-82b5-451a4ccfeb71	\N	160f5e99-1962-44f4-a531-383d7e8cb4a4	2026-07-20 09:22:03.794401+00	2026-07-20 09:22:03.794401+00
1d224113-52fd-42ec-a3d9-ee5e9338d4af	78d11caa-4c8b-4ee2-bbd7-f40d8f3b4d7e	6fb1a35d-b064-46b8-8796-54c4fec69d24	پیاده‌سازی بخش اصلی	92	36	2026-07-16	approved	127c1187-f85a-48c8-82b5-451a4ccfeb71	\N	9c44cfee-902b-43cd-8b9b-d3c57ac2f368	2026-07-20 09:22:03.794401+00	2026-07-20 09:22:03.794401+00
1d224113-52fd-42ec-a3d9-ee5e9338d4af	78d11caa-4c8b-4ee2-bbd7-f40d8f3b4d7e	6fb1a35d-b064-46b8-8796-54c4fec69d24	پیاده‌سازی بخش اصلی	73	50	2026-07-16	approved	127c1187-f85a-48c8-82b5-451a4ccfeb71	\N	64965c1a-5cbd-41c3-9100-97d0070af192	2026-07-20 09:22:03.794401+00	2026-07-20 09:22:03.794401+00
1d224113-52fd-42ec-a3d9-ee5e9338d4af	78d11caa-4c8b-4ee2-bbd7-f40d8f3b4d7e	6fb1a35d-b064-46b8-8796-54c4fec69d24	تست و اطمینان از عملکرد صحیح	188	81	2026-07-16	approved	127c1187-f85a-48c8-82b5-451a4ccfeb71	\N	cd10513b-30c1-4098-ad30-fc10cee23525	2026-07-20 09:22:03.794401+00	2026-07-20 09:22:03.794401+00
1d224113-52fd-42ec-a3d9-ee5e9338d4af	cb1cbb31-f0a3-4c9b-b75b-682dd1e4530e	a2c3e527-82e9-4bd2-be63-85f6ead97337	پیاده‌سازی بخش اصلی	148	40	2026-07-16	approved	127c1187-f85a-48c8-82b5-451a4ccfeb71	\N	b9c67d29-9e21-44f6-8583-58eec114ebf3	2026-07-20 09:22:03.794401+00	2026-07-20 09:22:03.794401+00
1d224113-52fd-42ec-a3d9-ee5e9338d4af	cb1cbb31-f0a3-4c9b-b75b-682dd1e4530e	a2c3e527-82e9-4bd2-be63-85f6ead97337	تست و اطمینان از عملکرد صحیح	95	40	2026-07-16	approved	127c1187-f85a-48c8-82b5-451a4ccfeb71	\N	80fcb330-e637-400e-b448-eaaa9cdc4a36	2026-07-20 09:22:03.794401+00	2026-07-20 09:22:03.794401+00
1d224113-52fd-42ec-a3d9-ee5e9338d4af	cb1cbb31-f0a3-4c9b-b75b-682dd1e4530e	a2c3e527-82e9-4bd2-be63-85f6ead97337	رفع اشکالات و بازبینی	203	100	2026-07-16	approved	127c1187-f85a-48c8-82b5-451a4ccfeb71	\N	36aa1f62-95be-4fb0-8293-12ba1d0da277	2026-07-20 09:22:03.794401+00	2026-07-20 09:22:03.794401+00
1d224113-52fd-42ec-a3d9-ee5e9338d4af	cb1cbb31-f0a3-4c9b-b75b-682dd1e4530e	a2c3e527-82e9-4bd2-be63-85f6ead97337	پیشرفت اولیه و بررسی نیازمندی‌ها	143	100	2026-07-16	approved	127c1187-f85a-48c8-82b5-451a4ccfeb71	\N	e2799a78-1817-4057-a2e7-9ffc55011bdb	2026-07-20 09:22:03.794401+00	2026-07-20 09:22:03.794401+00
1d224113-52fd-42ec-a3d9-ee5e9338d4af	c36a827a-f4bb-4a32-822b-97b8adafb475	0132fd66-319f-4f6e-8e2f-d16328d278e8	تست و اطمینان از عملکرد صحیح	107	26	2026-06-29	approved	127c1187-f85a-48c8-82b5-451a4ccfeb71	\N	9d5a9f11-3967-4efa-beb1-d30406b04709	2026-07-20 09:22:03.794401+00	2026-07-20 09:22:03.794401+00
1d224113-52fd-42ec-a3d9-ee5e9338d4af	c36a827a-f4bb-4a32-822b-97b8adafb475	0132fd66-319f-4f6e-8e2f-d16328d278e8	پیشرفت اولیه و بررسی نیازمندی‌ها	90	64	2026-07-03	submitted	\N	\N	806dc38d-ea38-42b1-ac9a-e48e1da910fc	2026-07-20 09:22:03.794401+00	2026-07-20 09:22:03.794401+00
1d224113-52fd-42ec-a3d9-ee5e9338d4af	c36a827a-f4bb-4a32-822b-97b8adafb475	0132fd66-319f-4f6e-8e2f-d16328d278e8	رفع اشکالات و بازبینی	35	96	2026-07-05	approved	127c1187-f85a-48c8-82b5-451a4ccfeb71	\N	4f69a894-302c-47ec-ae53-ff6e2c440118	2026-07-20 09:22:03.794401+00	2026-07-20 09:22:03.794401+00
1d224113-52fd-42ec-a3d9-ee5e9338d4af	69fa38b8-d82c-428f-ae06-c3e1f6949d37	0132fd66-319f-4f6e-8e2f-d16328d278e8	پیشرفت اولیه و بررسی نیازمندی‌ها	185	35	2026-06-23	approved	127c1187-f85a-48c8-82b5-451a4ccfeb71	\N	7749f590-9a37-4444-8756-ffd50303897b	2026-07-20 09:22:03.794401+00	2026-07-20 09:22:03.794401+00
1d224113-52fd-42ec-a3d9-ee5e9338d4af	69fa38b8-d82c-428f-ae06-c3e1f6949d37	0132fd66-319f-4f6e-8e2f-d16328d278e8	پیاده‌سازی بخش اصلی	185	62	2026-06-26	submitted	\N	\N	ace015ea-c374-4f1c-8b14-1c07667f1610	2026-07-20 09:22:03.794401+00	2026-07-20 09:22:03.794401+00
1d224113-52fd-42ec-a3d9-ee5e9338d4af	69fa38b8-d82c-428f-ae06-c3e1f6949d37	0132fd66-319f-4f6e-8e2f-d16328d278e8	مستندسازی و نهایی‌سازی	94	72	2026-06-27	approved	127c1187-f85a-48c8-82b5-451a4ccfeb71	\N	7220aa95-5b9f-4b9c-a0ab-5b8149db9c08	2026-07-20 09:22:03.794401+00	2026-07-20 09:22:03.794401+00
1d224113-52fd-42ec-a3d9-ee5e9338d4af	9d8626d0-978e-401f-9cd7-2e5e762148ad	127c1187-f85a-48c8-82b5-451a4ccfeb71	تست و اطمینان از عملکرد صحیح	38	38	2026-07-16	approved	127c1187-f85a-48c8-82b5-451a4ccfeb71	\N	ec570739-9fcd-4957-bd98-063b8570dadc	2026-07-20 09:22:03.794401+00	2026-07-20 09:22:03.794401+00
1d224113-52fd-42ec-a3d9-ee5e9338d4af	76a26819-c895-4e37-b047-2785aa508043	0132fd66-319f-4f6e-8e2f-d16328d278e8	پیشرفت اولیه و بررسی نیازمندی‌ها	105	30	2026-07-01	approved	127c1187-f85a-48c8-82b5-451a4ccfeb71	\N	cb099e43-e59e-48d7-bfca-3799e4df40db	2026-07-20 09:22:03.794401+00	2026-07-20 09:22:03.794401+00
1d224113-52fd-42ec-a3d9-ee5e9338d4af	76a26819-c895-4e37-b047-2785aa508043	0132fd66-319f-4f6e-8e2f-d16328d278e8	پیاده‌سازی بخش اصلی	81	48	2026-07-05	approved	127c1187-f85a-48c8-82b5-451a4ccfeb71	\N	47e70d2d-c6ab-4eed-9693-bbd9a35093b8	2026-07-20 09:22:03.794401+00	2026-07-20 09:22:03.794401+00
1d224113-52fd-42ec-a3d9-ee5e9338d4af	76a26819-c895-4e37-b047-2785aa508043	0132fd66-319f-4f6e-8e2f-d16328d278e8	مستندسازی و نهایی‌سازی	158	84	2026-07-07	approved	127c1187-f85a-48c8-82b5-451a4ccfeb71	\N	97694e97-396a-438c-9164-c7d5ed83d14e	2026-07-20 09:22:03.794401+00	2026-07-20 09:22:03.794401+00
1d224113-52fd-42ec-a3d9-ee5e9338d4af	3a6d8532-f891-48d0-9987-46ae1512bb6f	a2c3e527-82e9-4bd2-be63-85f6ead97337	تست و اطمینان از عملکرد صحیح	236	29	2026-07-16	approved	127c1187-f85a-48c8-82b5-451a4ccfeb71	\N	47be5bd1-a321-4426-ac88-ab109313ed2c	2026-07-20 09:22:03.794401+00	2026-07-20 09:22:03.794401+00
1d224113-52fd-42ec-a3d9-ee5e9338d4af	3a6d8532-f891-48d0-9987-46ae1512bb6f	a2c3e527-82e9-4bd2-be63-85f6ead97337	پیشرفت اولیه و بررسی نیازمندی‌ها	149	44	2026-07-16	approved	127c1187-f85a-48c8-82b5-451a4ccfeb71	\N	cb3e25bd-7f9d-44c3-b938-4f5314bff39c	2026-07-20 09:22:03.794401+00	2026-07-20 09:22:03.794401+00
1d224113-52fd-42ec-a3d9-ee5e9338d4af	666ed664-0ac2-47e4-927b-316e5ec921e7	054f46d3-1cc2-42df-9532-2b310816822b	تست و اطمینان از عملکرد صحیح	235	37	2026-07-05	approved	127c1187-f85a-48c8-82b5-451a4ccfeb71	\N	83428d78-1833-4d48-8e88-b2b298bea7f5	2026-07-20 09:22:03.794401+00	2026-07-20 09:22:03.794401+00
1d224113-52fd-42ec-a3d9-ee5e9338d4af	666ed664-0ac2-47e4-927b-316e5ec921e7	054f46d3-1cc2-42df-9532-2b310816822b	پیشرفت اولیه و بررسی نیازمندی‌ها	232	64	2026-07-08	approved	127c1187-f85a-48c8-82b5-451a4ccfeb71	\N	06f95bfe-d81e-4e53-b7d3-e4311f4028d5	2026-07-20 09:22:03.794401+00	2026-07-20 09:22:03.794401+00
1d224113-52fd-42ec-a3d9-ee5e9338d4af	5b41acf3-ae24-40b3-820e-222b9d85cbef	6fb1a35d-b064-46b8-8796-54c4fec69d24	مستندسازی و نهایی‌سازی	61	34	2026-07-16	approved	127c1187-f85a-48c8-82b5-451a4ccfeb71	\N	7ec369cd-22f3-49be-b2e0-83e94b391af5	2026-07-20 09:22:03.794401+00	2026-07-20 09:22:03.794401+00
1d224113-52fd-42ec-a3d9-ee5e9338d4af	e66c9902-38ba-42d3-8a58-f3c53796ceed	127c1187-f85a-48c8-82b5-451a4ccfeb71	مستندسازی و نهایی‌سازی	127	40	2026-07-16	approved	127c1187-f85a-48c8-82b5-451a4ccfeb71	\N	2e3dbd2e-8355-4aba-85e3-fadad308ed60	2026-07-20 09:22:03.794401+00	2026-07-20 09:22:03.794401+00
1d224113-52fd-42ec-a3d9-ee5e9338d4af	e66c9902-38ba-42d3-8a58-f3c53796ceed	127c1187-f85a-48c8-82b5-451a4ccfeb71	پیشرفت اولیه و بررسی نیازمندی‌ها	202	54	2026-07-16	approved	127c1187-f85a-48c8-82b5-451a4ccfeb71	\N	c45a8f53-7578-46d6-806f-58364f6ad8e4	2026-07-20 09:22:03.794401+00	2026-07-20 09:22:03.794401+00
1d224113-52fd-42ec-a3d9-ee5e9338d4af	e66c9902-38ba-42d3-8a58-f3c53796ceed	127c1187-f85a-48c8-82b5-451a4ccfeb71	پیشرفت اولیه و بررسی نیازمندی‌ها	188	100	2026-07-16	approved	127c1187-f85a-48c8-82b5-451a4ccfeb71	\N	60547588-161c-4d2c-86ea-3cd9ecf695ec	2026-07-20 09:22:03.794401+00	2026-07-20 09:22:03.794401+00
1d224113-52fd-42ec-a3d9-ee5e9338d4af	a4e01e36-47d0-4645-8e9a-8a01e6e480a4	a2c3e527-82e9-4bd2-be63-85f6ead97337	تست و اطمینان از عملکرد صحیح	209	29	2026-07-16	approved	127c1187-f85a-48c8-82b5-451a4ccfeb71	\N	b5cb7cbf-83df-4f1d-ad3e-9f19dcb7e0cc	2026-07-20 09:22:03.794401+00	2026-07-20 09:22:03.794401+00
1d224113-52fd-42ec-a3d9-ee5e9338d4af	a4e01e36-47d0-4645-8e9a-8a01e6e480a4	a2c3e527-82e9-4bd2-be63-85f6ead97337	پیشرفت اولیه و بررسی نیازمندی‌ها	39	58	2026-07-16	approved	127c1187-f85a-48c8-82b5-451a4ccfeb71	\N	88241b42-950b-40b6-bdc7-c668c08ca04c	2026-07-20 09:22:03.794401+00	2026-07-20 09:22:03.794401+00
1d224113-52fd-42ec-a3d9-ee5e9338d4af	a4e01e36-47d0-4645-8e9a-8a01e6e480a4	a2c3e527-82e9-4bd2-be63-85f6ead97337	پیاده‌سازی بخش اصلی	167	72	2026-07-16	approved	127c1187-f85a-48c8-82b5-451a4ccfeb71	\N	d963f5a3-4f93-4722-ac6c-18302ae5188d	2026-07-20 09:22:03.794401+00	2026-07-20 09:22:03.794401+00
1d224113-52fd-42ec-a3d9-ee5e9338d4af	a52a2543-71a2-48bb-8bdf-73ff1a00935d	f4e6dc2a-b9f2-43e2-8db1-3516a3e2985c	رفع اشکالات و بازبینی	201	37	2026-06-20	approved	127c1187-f85a-48c8-82b5-451a4ccfeb71	\N	c1dd8aa6-276d-49bd-a219-63cb53dd98f1	2026-07-20 09:22:03.794401+00	2026-07-20 09:22:03.794401+00
1d224113-52fd-42ec-a3d9-ee5e9338d4af	a52a2543-71a2-48bb-8bdf-73ff1a00935d	f4e6dc2a-b9f2-43e2-8db1-3516a3e2985c	مستندسازی و نهایی‌سازی	220	48	2026-06-24	approved	127c1187-f85a-48c8-82b5-451a4ccfeb71	\N	05d133ce-0aae-4fa3-aea9-fd1be0dfe10c	2026-07-20 09:22:03.794401+00	2026-07-20 09:22:03.794401+00
1d224113-52fd-42ec-a3d9-ee5e9338d4af	a52a2543-71a2-48bb-8bdf-73ff1a00935d	f4e6dc2a-b9f2-43e2-8db1-3516a3e2985c	پیشرفت اولیه و بررسی نیازمندی‌ها	155	100	2026-06-28	approved	127c1187-f85a-48c8-82b5-451a4ccfeb71	\N	df01167f-b622-45fa-876a-2417bb82fabb	2026-07-20 09:22:03.794401+00	2026-07-20 09:22:03.794401+00
1d224113-52fd-42ec-a3d9-ee5e9338d4af	a52a2543-71a2-48bb-8bdf-73ff1a00935d	f4e6dc2a-b9f2-43e2-8db1-3516a3e2985c	رفع اشکالات و بازبینی	38	100	2026-07-02	approved	127c1187-f85a-48c8-82b5-451a4ccfeb71	\N	31fe1e12-64c0-4ec4-a664-67fd720d54a2	2026-07-20 09:22:03.794401+00	2026-07-20 09:22:03.794401+00
1d224113-52fd-42ec-a3d9-ee5e9338d4af	13180638-5211-4296-81b6-941a824e6d22	054f46d3-1cc2-42df-9532-2b310816822b	تست و اطمینان از عملکرد صحیح	90	31	2026-06-24	approved	127c1187-f85a-48c8-82b5-451a4ccfeb71	\N	04963569-1c3d-48af-b02c-2e40a15bb95c	2026-07-20 09:22:03.794401+00	2026-07-20 09:22:03.794401+00
1d224113-52fd-42ec-a3d9-ee5e9338d4af	13180638-5211-4296-81b6-941a824e6d22	054f46d3-1cc2-42df-9532-2b310816822b	رفع اشکالات و بازبینی	169	80	2026-06-25	approved	127c1187-f85a-48c8-82b5-451a4ccfeb71	\N	0d05098c-35f0-4dc0-826a-ce5aae7069a0	2026-07-20 09:22:03.794401+00	2026-07-20 09:22:03.794401+00
1d224113-52fd-42ec-a3d9-ee5e9338d4af	d728f270-4ecb-428f-ac7c-68090153e516	a2c3e527-82e9-4bd2-be63-85f6ead97337	تست و اطمینان از عملکرد صحیح	100	26	2026-07-16	approved	127c1187-f85a-48c8-82b5-451a4ccfeb71	\N	a2909940-88b2-48a2-bc6d-1d1eeff8ce39	2026-07-20 09:22:03.794401+00	2026-07-20 09:22:03.794401+00
1d224113-52fd-42ec-a3d9-ee5e9338d4af	d728f270-4ecb-428f-ac7c-68090153e516	a2c3e527-82e9-4bd2-be63-85f6ead97337	تست و اطمینان از عملکرد صحیح	53	52	2026-07-16	approved	127c1187-f85a-48c8-82b5-451a4ccfeb71	\N	4764dd91-16e1-4635-bbcf-ccc31ca6925b	2026-07-20 09:22:03.794401+00	2026-07-20 09:22:03.794401+00
1d224113-52fd-42ec-a3d9-ee5e9338d4af	d728f270-4ecb-428f-ac7c-68090153e516	a2c3e527-82e9-4bd2-be63-85f6ead97337	پیشرفت اولیه و بررسی نیازمندی‌ها	231	90	2026-07-16	approved	127c1187-f85a-48c8-82b5-451a4ccfeb71	\N	eb438273-e4bd-4c1d-bace-c669fb84b84e	2026-07-20 09:22:03.794401+00	2026-07-20 09:22:03.794401+00
1d224113-52fd-42ec-a3d9-ee5e9338d4af	2380c0c3-19ca-4f86-94b6-882ad9eda0c5	a2c3e527-82e9-4bd2-be63-85f6ead97337	پیاده‌سازی بخش اصلی	47	37	2026-07-16	submitted	\N	\N	29627a37-6c63-4488-8bbe-ee4e8c0d8540	2026-07-20 09:22:03.794401+00	2026-07-20 09:22:03.794401+00
1d224113-52fd-42ec-a3d9-ee5e9338d4af	2380c0c3-19ca-4f86-94b6-882ad9eda0c5	a2c3e527-82e9-4bd2-be63-85f6ead97337	پیاده‌سازی بخش اصلی	114	48	2026-07-16	approved	127c1187-f85a-48c8-82b5-451a4ccfeb71	\N	fe8abdec-bd2d-4e03-9174-58cc51978e67	2026-07-20 09:22:03.794401+00	2026-07-20 09:22:03.794401+00
1d224113-52fd-42ec-a3d9-ee5e9338d4af	73da703c-e8e2-4f27-a10e-7da5eaf830b8	127c1187-f85a-48c8-82b5-451a4ccfeb71	پیاده‌سازی بخش اصلی	63	37	2026-07-16	approved	127c1187-f85a-48c8-82b5-451a4ccfeb71	\N	6fcc1fa6-2913-4896-9814-3182f755b389	2026-07-20 09:22:03.794401+00	2026-07-20 09:22:03.794401+00
1d224113-52fd-42ec-a3d9-ee5e9338d4af	e245fd9f-8a19-428a-b04e-2565f3013906	6fb1a35d-b064-46b8-8796-54c4fec69d24	پیشرفت اولیه و بررسی نیازمندی‌ها	63	20	2026-06-30	approved	127c1187-f85a-48c8-82b5-451a4ccfeb71	\N	0db003f6-317d-4fdb-8813-6c7615f8b2ab	2026-07-20 09:22:03.794401+00	2026-07-20 09:22:03.794401+00
1d224113-52fd-42ec-a3d9-ee5e9338d4af	e245fd9f-8a19-428a-b04e-2565f3013906	6fb1a35d-b064-46b8-8796-54c4fec69d24	پیاده‌سازی بخش اصلی	180	60	2026-07-03	submitted	\N	\N	98a0ed2e-5da6-4735-95d4-faaf162e6898	2026-07-20 09:22:03.794401+00	2026-07-20 09:22:03.794401+00
1d224113-52fd-42ec-a3d9-ee5e9338d4af	e245fd9f-8a19-428a-b04e-2565f3013906	6fb1a35d-b064-46b8-8796-54c4fec69d24	پیشرفت اولیه و بررسی نیازمندی‌ها	62	99	2026-07-02	approved	127c1187-f85a-48c8-82b5-451a4ccfeb71	\N	b1c2c93c-c78e-43bb-b17f-15d2d9612b0e	2026-07-20 09:22:03.794401+00	2026-07-20 09:22:03.794401+00
1d224113-52fd-42ec-a3d9-ee5e9338d4af	5be3ddde-0b79-47fe-bdc6-b79ea02b118b	6fb1a35d-b064-46b8-8796-54c4fec69d24	تست و اطمینان از عملکرد صحیح	144	31	2026-06-17	approved	127c1187-f85a-48c8-82b5-451a4ccfeb71	\N	92023558-a29a-4474-aee7-c997d47db6a7	2026-07-20 09:22:03.794401+00	2026-07-20 09:22:03.794401+00
1d224113-52fd-42ec-a3d9-ee5e9338d4af	ff44c3c7-aaa6-4553-9f2d-636394be7ab5	127c1187-f85a-48c8-82b5-451a4ccfeb71	مستندسازی و نهایی‌سازی	86	39	2026-07-16	approved	127c1187-f85a-48c8-82b5-451a4ccfeb71	\N	e83af762-463c-4f7f-90f6-fe391e35d539	2026-07-20 09:22:03.794401+00	2026-07-20 09:22:03.794401+00
1d224113-52fd-42ec-a3d9-ee5e9338d4af	c8831502-fdef-4eb3-950e-83b2a8ca3aa6	3940e09c-eede-4772-818b-3a4bc4703195	پیشرفت اولیه و بررسی نیازمندی‌ها	45	35	2026-07-16	approved	127c1187-f85a-48c8-82b5-451a4ccfeb71	\N	caca9c6f-951e-4426-9ee5-dc57a1986a6a	2026-07-20 09:22:03.794401+00	2026-07-20 09:22:03.794401+00
1d224113-52fd-42ec-a3d9-ee5e9338d4af	627590b0-ad03-4543-a950-37cf4b8300ac	3940e09c-eede-4772-818b-3a4bc4703195	تست و اطمینان از عملکرد صحیح	212	34	2026-07-06	approved	127c1187-f85a-48c8-82b5-451a4ccfeb71	\N	0fac2b01-a014-4e49-a1b5-e758128da27c	2026-07-20 09:22:03.794401+00	2026-07-20 09:22:03.794401+00
1d224113-52fd-42ec-a3d9-ee5e9338d4af	627590b0-ad03-4543-a950-37cf4b8300ac	3940e09c-eede-4772-818b-3a4bc4703195	رفع اشکالات و بازبینی	185	48	2026-07-07	submitted	\N	\N	b233cd0e-cd36-41ad-a157-740fedd14ddb	2026-07-20 09:22:03.794401+00	2026-07-20 09:22:03.794401+00
1d224113-52fd-42ec-a3d9-ee5e9338d4af	627590b0-ad03-4543-a950-37cf4b8300ac	3940e09c-eede-4772-818b-3a4bc4703195	مستندسازی و نهایی‌سازی	192	100	2026-07-08	approved	127c1187-f85a-48c8-82b5-451a4ccfeb71	\N	fd55d4c4-67ea-4b2a-9bcd-344f8d87764c	2026-07-20 09:22:03.794401+00	2026-07-20 09:22:03.794401+00
1d224113-52fd-42ec-a3d9-ee5e9338d4af	627590b0-ad03-4543-a950-37cf4b8300ac	3940e09c-eede-4772-818b-3a4bc4703195	مستندسازی و نهایی‌سازی	165	100	2026-07-15	approved	127c1187-f85a-48c8-82b5-451a4ccfeb71	\N	e69a9629-2a93-4112-a2e1-cfd6aa1cc829	2026-07-20 09:22:03.794401+00	2026-07-20 09:22:03.794401+00
1d224113-52fd-42ec-a3d9-ee5e9338d4af	eb4c8dae-7381-4ddc-8126-a269eca1df6b	f4e6dc2a-b9f2-43e2-8db1-3516a3e2985c	پیشرفت اولیه و بررسی نیازمندی‌ها	233	23	2026-07-16	approved	127c1187-f85a-48c8-82b5-451a4ccfeb71	\N	c3d9d50c-90df-4828-8ad3-520403883c23	2026-07-20 09:22:03.794401+00	2026-07-20 09:22:03.794401+00
1d224113-52fd-42ec-a3d9-ee5e9338d4af	eb4c8dae-7381-4ddc-8126-a269eca1df6b	f4e6dc2a-b9f2-43e2-8db1-3516a3e2985c	تست و اطمینان از عملکرد صحیح	145	54	2026-07-16	approved	127c1187-f85a-48c8-82b5-451a4ccfeb71	\N	84c6ed10-211a-4f77-b2ca-4b22b1654e5a	2026-07-20 09:22:03.794401+00	2026-07-20 09:22:03.794401+00
1d224113-52fd-42ec-a3d9-ee5e9338d4af	eb4c8dae-7381-4ddc-8126-a269eca1df6b	f4e6dc2a-b9f2-43e2-8db1-3516a3e2985c	رفع اشکالات و بازبینی	146	96	2026-07-16	approved	127c1187-f85a-48c8-82b5-451a4ccfeb71	\N	0fa8918c-9e55-447b-9e49-26e3898f1c38	2026-07-20 09:22:03.794401+00	2026-07-20 09:22:03.794401+00
1d224113-52fd-42ec-a3d9-ee5e9338d4af	eb4c8dae-7381-4ddc-8126-a269eca1df6b	f4e6dc2a-b9f2-43e2-8db1-3516a3e2985c	پیشرفت اولیه و بررسی نیازمندی‌ها	110	100	2026-07-16	approved	127c1187-f85a-48c8-82b5-451a4ccfeb71	\N	82550e6a-9c87-4553-b3dc-f141239abde0	2026-07-20 09:22:03.794401+00	2026-07-20 09:22:03.794401+00
1d224113-52fd-42ec-a3d9-ee5e9338d4af	efa97bec-f422-4b7a-a7d3-beb135cef3b7	a2c3e527-82e9-4bd2-be63-85f6ead97337	رفع اشکالات و بازبینی	69	35	2026-07-16	approved	127c1187-f85a-48c8-82b5-451a4ccfeb71	\N	94519f55-c508-4c61-bb05-4aac685e5f98	2026-07-20 09:22:03.794401+00	2026-07-20 09:22:03.794401+00
1d224113-52fd-42ec-a3d9-ee5e9338d4af	efa97bec-f422-4b7a-a7d3-beb135cef3b7	a2c3e527-82e9-4bd2-be63-85f6ead97337	پیشرفت اولیه و بررسی نیازمندی‌ها	51	44	2026-07-16	approved	127c1187-f85a-48c8-82b5-451a4ccfeb71	\N	98f7de33-1a37-4080-ab49-dc529fa6e840	2026-07-20 09:22:03.794401+00	2026-07-20 09:22:03.794401+00
1d224113-52fd-42ec-a3d9-ee5e9338d4af	efa97bec-f422-4b7a-a7d3-beb135cef3b7	a2c3e527-82e9-4bd2-be63-85f6ead97337	پیشرفت اولیه و بررسی نیازمندی‌ها	220	93	2026-07-16	approved	127c1187-f85a-48c8-82b5-451a4ccfeb71	\N	cde7a787-32d4-4bd1-a30b-049fdd880fb3	2026-07-20 09:22:03.794401+00	2026-07-20 09:22:03.794401+00
1d224113-52fd-42ec-a3d9-ee5e9338d4af	893b4ac1-d92b-42b8-92f4-15b3e3483fb7	6fb1a35d-b064-46b8-8796-54c4fec69d24	مستندسازی و نهایی‌سازی	173	37	2026-06-26	approved	127c1187-f85a-48c8-82b5-451a4ccfeb71	\N	c269b831-0ada-4598-9dea-6849763d0029	2026-07-20 09:22:03.794401+00	2026-07-20 09:22:03.794401+00
1d224113-52fd-42ec-a3d9-ee5e9338d4af	893b4ac1-d92b-42b8-92f4-15b3e3483fb7	6fb1a35d-b064-46b8-8796-54c4fec69d24	پیشرفت اولیه و بررسی نیازمندی‌ها	135	62	2026-06-29	approved	127c1187-f85a-48c8-82b5-451a4ccfeb71	\N	673fc92a-b1fe-4c47-8c80-c2eb7594649e	2026-07-20 09:22:03.794401+00	2026-07-20 09:22:03.794401+00
1d224113-52fd-42ec-a3d9-ee5e9338d4af	ade728f1-210b-4ecd-9741-37bd928aea54	6fb1a35d-b064-46b8-8796-54c4fec69d24	رفع اشکالات و بازبینی	183	29	2026-07-01	approved	127c1187-f85a-48c8-82b5-451a4ccfeb71	\N	fbee7f27-adc2-44a2-95b3-aa28c7185273	2026-07-20 09:22:03.794401+00	2026-07-20 09:22:03.794401+00
1d224113-52fd-42ec-a3d9-ee5e9338d4af	ade728f1-210b-4ecd-9741-37bd928aea54	6fb1a35d-b064-46b8-8796-54c4fec69d24	پیشرفت اولیه و بررسی نیازمندی‌ها	177	72	2026-07-04	approved	127c1187-f85a-48c8-82b5-451a4ccfeb71	\N	9d37ab7d-e1f6-400a-a70a-0fc98d94ba91	2026-07-20 09:22:03.794401+00	2026-07-20 09:22:03.794401+00
1d224113-52fd-42ec-a3d9-ee5e9338d4af	ade728f1-210b-4ecd-9741-37bd928aea54	6fb1a35d-b064-46b8-8796-54c4fec69d24	پیاده‌سازی بخش اصلی	198	100	2026-07-05	approved	127c1187-f85a-48c8-82b5-451a4ccfeb71	\N	478fd6e1-cd40-40d9-9b5b-4b62bf744f9d	2026-07-20 09:22:03.794401+00	2026-07-20 09:22:03.794401+00
1d224113-52fd-42ec-a3d9-ee5e9338d4af	ade728f1-210b-4ecd-9741-37bd928aea54	6fb1a35d-b064-46b8-8796-54c4fec69d24	پیشرفت اولیه و بررسی نیازمندی‌ها	119	100	2026-07-07	approved	127c1187-f85a-48c8-82b5-451a4ccfeb71	\N	cf345890-bb7f-4ea3-a87e-7dbe31564bd1	2026-07-20 09:22:03.794401+00	2026-07-20 09:22:03.794401+00
1d224113-52fd-42ec-a3d9-ee5e9338d4af	cc7ddcbe-ed8a-4da8-bf95-d047557671d1	0132fd66-319f-4f6e-8e2f-d16328d278e8	رفع اشکالات و بازبینی	176	27	2026-07-16	approved	127c1187-f85a-48c8-82b5-451a4ccfeb71	\N	ab6ab072-e704-425e-ab17-ae4fe88247c3	2026-07-20 09:22:03.794401+00	2026-07-20 09:22:03.794401+00
1d224113-52fd-42ec-a3d9-ee5e9338d4af	cc7ddcbe-ed8a-4da8-bf95-d047557671d1	0132fd66-319f-4f6e-8e2f-d16328d278e8	مستندسازی و نهایی‌سازی	226	78	2026-07-16	approved	127c1187-f85a-48c8-82b5-451a4ccfeb71	\N	b0fb5fca-b2ed-4ecf-b731-cb4d8203fc1e	2026-07-20 09:22:03.794401+00	2026-07-20 09:22:03.794401+00
1d224113-52fd-42ec-a3d9-ee5e9338d4af	cc7ddcbe-ed8a-4da8-bf95-d047557671d1	0132fd66-319f-4f6e-8e2f-d16328d278e8	مستندسازی و نهایی‌سازی	198	84	2026-07-16	approved	127c1187-f85a-48c8-82b5-451a4ccfeb71	\N	603abe50-c575-4a2c-93c0-025865112a93	2026-07-20 09:22:03.794401+00	2026-07-20 09:22:03.794401+00
1d224113-52fd-42ec-a3d9-ee5e9338d4af	d81eb2c6-c137-4cb4-abde-6940ceed9c29	3940e09c-eede-4772-818b-3a4bc4703195	رفع اشکالات و بازبینی	209	29	2026-07-16	approved	127c1187-f85a-48c8-82b5-451a4ccfeb71	\N	f45078a7-1060-46e5-a2f8-db131bdbfdf7	2026-07-20 09:22:03.794401+00	2026-07-20 09:22:03.794401+00
1d224113-52fd-42ec-a3d9-ee5e9338d4af	9f846574-246e-4b90-aa31-33d534acbca8	6fb1a35d-b064-46b8-8796-54c4fec69d24	پیشرفت اولیه و بررسی نیازمندی‌ها	76	24	2026-07-16	approved	127c1187-f85a-48c8-82b5-451a4ccfeb71	\N	397c8a52-829d-44e6-b563-f444fee29bec	2026-07-20 09:22:03.794401+00	2026-07-20 09:22:03.794401+00
1d224113-52fd-42ec-a3d9-ee5e9338d4af	9f846574-246e-4b90-aa31-33d534acbca8	6fb1a35d-b064-46b8-8796-54c4fec69d24	پیشرفت اولیه و بررسی نیازمندی‌ها	66	80	2026-07-16	approved	127c1187-f85a-48c8-82b5-451a4ccfeb71	\N	72f0e280-047d-4fb9-9e1d-2eb4a6f09e74	2026-07-20 09:22:03.794401+00	2026-07-20 09:22:03.794401+00
1d224113-52fd-42ec-a3d9-ee5e9338d4af	9f846574-246e-4b90-aa31-33d534acbca8	6fb1a35d-b064-46b8-8796-54c4fec69d24	پیشرفت اولیه و بررسی نیازمندی‌ها	221	100	2026-07-16	approved	127c1187-f85a-48c8-82b5-451a4ccfeb71	\N	c04cdb33-4b65-4464-864a-7cf6faf12561	2026-07-20 09:22:03.794401+00	2026-07-20 09:22:03.794401+00
1d224113-52fd-42ec-a3d9-ee5e9338d4af	9000951f-4371-4f55-be51-eea18f121902	3940e09c-eede-4772-818b-3a4bc4703195	تست و اطمینان از عملکرد صحیح	146	30	2026-07-16	approved	127c1187-f85a-48c8-82b5-451a4ccfeb71	\N	4ec5cb7d-95d7-409c-bb21-86427a3e2384	2026-07-20 09:22:03.794401+00	2026-07-20 09:22:03.794401+00
1d224113-52fd-42ec-a3d9-ee5e9338d4af	9000951f-4371-4f55-be51-eea18f121902	3940e09c-eede-4772-818b-3a4bc4703195	رفع اشکالات و بازبینی	109	60	2026-07-16	approved	127c1187-f85a-48c8-82b5-451a4ccfeb71	\N	40c9c8ac-395c-4b20-b9a1-e34ef2f5de21	2026-07-20 09:22:03.794401+00	2026-07-20 09:22:03.794401+00
1d224113-52fd-42ec-a3d9-ee5e9338d4af	8bd308a6-b86d-4aa5-bb44-66cae32fbeac	f4e6dc2a-b9f2-43e2-8db1-3516a3e2985c	پیاده‌سازی بخش اصلی	70	39	2026-07-01	approved	127c1187-f85a-48c8-82b5-451a4ccfeb71	\N	5ac2587c-e8cb-458c-ba04-105f651d76ef	2026-07-20 09:22:03.794401+00	2026-07-20 09:22:03.794401+00
1d224113-52fd-42ec-a3d9-ee5e9338d4af	c4afd6ed-87c6-4942-9faf-19a578182a44	0132fd66-319f-4f6e-8e2f-d16328d278e8	تست و اطمینان از عملکرد صحیح	154	39	2026-07-14	approved	127c1187-f85a-48c8-82b5-451a4ccfeb71	\N	882af9c6-06c6-4919-8911-bfe52c8dfef2	2026-07-20 09:22:03.794401+00	2026-07-20 09:22:03.794401+00
1d224113-52fd-42ec-a3d9-ee5e9338d4af	0712063f-4808-43fd-8f3a-64af3b639ebc	a2c3e527-82e9-4bd2-be63-85f6ead97337	رفع اشکالات و بازبینی	85	36	2026-06-25	approved	127c1187-f85a-48c8-82b5-451a4ccfeb71	\N	78807ac6-2b7d-474c-963f-6ec841192f94	2026-07-20 09:22:03.794401+00	2026-07-20 09:22:03.794401+00
1d224113-52fd-42ec-a3d9-ee5e9338d4af	0712063f-4808-43fd-8f3a-64af3b639ebc	a2c3e527-82e9-4bd2-be63-85f6ead97337	رفع اشکالات و بازبینی	140	46	2026-06-26	approved	127c1187-f85a-48c8-82b5-451a4ccfeb71	\N	993c1c8d-042b-4552-9e73-1b63bc5d4d57	2026-07-20 09:22:03.794401+00	2026-07-20 09:22:03.794401+00
1d224113-52fd-42ec-a3d9-ee5e9338d4af	0712063f-4808-43fd-8f3a-64af3b639ebc	a2c3e527-82e9-4bd2-be63-85f6ead97337	مستندسازی و نهایی‌سازی	154	100	2026-07-01	approved	127c1187-f85a-48c8-82b5-451a4ccfeb71	\N	f02301c0-8db6-4ab1-b4c1-c708b0b7fa11	2026-07-20 09:22:03.794401+00	2026-07-20 09:22:03.794401+00
1d224113-52fd-42ec-a3d9-ee5e9338d4af	0712063f-4808-43fd-8f3a-64af3b639ebc	a2c3e527-82e9-4bd2-be63-85f6ead97337	پیشرفت اولیه و بررسی نیازمندی‌ها	86	100	2026-07-04	approved	127c1187-f85a-48c8-82b5-451a4ccfeb71	\N	cbbd2572-49e6-4b17-aa58-7744fd32006f	2026-07-20 09:22:03.794401+00	2026-07-20 09:22:03.794401+00
1d224113-52fd-42ec-a3d9-ee5e9338d4af	768df0d7-0482-4240-8e0e-ae107442d16c	0132fd66-319f-4f6e-8e2f-d16328d278e8	پیاده‌سازی بخش اصلی	226	24	2026-07-10	approved	127c1187-f85a-48c8-82b5-451a4ccfeb71	\N	074c145d-76ea-48aa-878b-6261b0614584	2026-07-20 09:22:03.794401+00	2026-07-20 09:22:03.794401+00
1d224113-52fd-42ec-a3d9-ee5e9338d4af	5def895f-add8-4176-8acd-841ae92a81f7	127c1187-f85a-48c8-82b5-451a4ccfeb71	پیشرفت اولیه و بررسی نیازمندی‌ها	157	33	2026-07-05	approved	127c1187-f85a-48c8-82b5-451a4ccfeb71	\N	6248c0b9-a6cb-441a-a484-a0e10c1f3448	2026-07-20 09:22:03.794401+00	2026-07-20 09:22:03.794401+00
1d224113-52fd-42ec-a3d9-ee5e9338d4af	5def895f-add8-4176-8acd-841ae92a81f7	127c1187-f85a-48c8-82b5-451a4ccfeb71	مستندسازی و نهایی‌سازی	210	54	2026-07-07	approved	127c1187-f85a-48c8-82b5-451a4ccfeb71	\N	8eaffb7e-2cd7-4d5b-87e5-3694bc21c43c	2026-07-20 09:22:03.794401+00	2026-07-20 09:22:03.794401+00
1d224113-52fd-42ec-a3d9-ee5e9338d4af	5def895f-add8-4176-8acd-841ae92a81f7	127c1187-f85a-48c8-82b5-451a4ccfeb71	پیشرفت اولیه و بررسی نیازمندی‌ها	141	60	2026-07-11	approved	127c1187-f85a-48c8-82b5-451a4ccfeb71	\N	3e299190-e003-46a5-92fa-9203c5f2d874	2026-07-20 09:22:03.794401+00	2026-07-20 09:22:03.794401+00
1d224113-52fd-42ec-a3d9-ee5e9338d4af	4fb331b3-4777-4875-a846-e46cdf4d2f8c	054f46d3-1cc2-42df-9532-2b310816822b	رفع اشکالات و بازبینی	177	33	2026-07-16	approved	127c1187-f85a-48c8-82b5-451a4ccfeb71	\N	a375bfbd-3f06-4fd5-8928-68aa7a370603	2026-07-20 09:22:03.794401+00	2026-07-20 09:22:03.794401+00
1d224113-52fd-42ec-a3d9-ee5e9338d4af	4fb331b3-4777-4875-a846-e46cdf4d2f8c	054f46d3-1cc2-42df-9532-2b310816822b	تست و اطمینان از عملکرد صحیح	104	46	2026-07-16	approved	127c1187-f85a-48c8-82b5-451a4ccfeb71	\N	c9d9fe21-cb6b-4d72-94dc-f904a048ae41	2026-07-20 09:22:03.794401+00	2026-07-20 09:22:03.794401+00
1d224113-52fd-42ec-a3d9-ee5e9338d4af	4fb331b3-4777-4875-a846-e46cdf4d2f8c	054f46d3-1cc2-42df-9532-2b310816822b	پیشرفت اولیه و بررسی نیازمندی‌ها	113	75	2026-07-16	approved	127c1187-f85a-48c8-82b5-451a4ccfeb71	\N	262efdae-5f16-4a0b-8ad4-9e871a844984	2026-07-20 09:22:03.794401+00	2026-07-20 09:22:03.794401+00
1d224113-52fd-42ec-a3d9-ee5e9338d4af	4fb331b3-4777-4875-a846-e46cdf4d2f8c	054f46d3-1cc2-42df-9532-2b310816822b	رفع اشکالات و بازبینی	52	100	2026-07-16	approved	127c1187-f85a-48c8-82b5-451a4ccfeb71	\N	7f0a4b10-5bfa-4970-ae70-8b1ebf1d20e2	2026-07-20 09:22:03.794401+00	2026-07-20 09:22:03.794401+00
1d224113-52fd-42ec-a3d9-ee5e9338d4af	69de88d8-c9e5-471a-b8e3-fdd25188a3b2	f4e6dc2a-b9f2-43e2-8db1-3516a3e2985c	تست و اطمینان از عملکرد صحیح	164	22	2026-07-16	approved	127c1187-f85a-48c8-82b5-451a4ccfeb71	\N	a6137f5e-82d9-48cb-ac06-87125e09e5c5	2026-07-20 09:22:03.794401+00	2026-07-20 09:22:03.794401+00
1d224113-52fd-42ec-a3d9-ee5e9338d4af	176c85d9-b9f2-44bc-9a7b-3512715dd08d	054f46d3-1cc2-42df-9532-2b310816822b	رفع اشکالات و بازبینی	86	30	2026-07-11	approved	127c1187-f85a-48c8-82b5-451a4ccfeb71	\N	982f77f5-dc6b-4733-953e-f0fd8d1f8ca3	2026-07-20 09:22:03.794401+00	2026-07-20 09:22:03.794401+00
1d224113-52fd-42ec-a3d9-ee5e9338d4af	176c85d9-b9f2-44bc-9a7b-3512715dd08d	054f46d3-1cc2-42df-9532-2b310816822b	پیشرفت اولیه و بررسی نیازمندی‌ها	160	80	2026-07-13	approved	127c1187-f85a-48c8-82b5-451a4ccfeb71	\N	0c86b22b-99a3-4620-8b0e-ae11d582000f	2026-07-20 09:22:03.794401+00	2026-07-20 09:22:03.794401+00
1d224113-52fd-42ec-a3d9-ee5e9338d4af	176c85d9-b9f2-44bc-9a7b-3512715dd08d	054f46d3-1cc2-42df-9532-2b310816822b	مستندسازی و نهایی‌سازی	160	78	2026-07-13	approved	127c1187-f85a-48c8-82b5-451a4ccfeb71	\N	d33d9db8-8bf0-4cb9-90fd-79816a7fb6b0	2026-07-20 09:22:03.794401+00	2026-07-20 09:22:03.794401+00
1d224113-52fd-42ec-a3d9-ee5e9338d4af	176c85d9-b9f2-44bc-9a7b-3512715dd08d	054f46d3-1cc2-42df-9532-2b310816822b	رفع اشکالات و بازبینی	216	100	2026-07-16	approved	127c1187-f85a-48c8-82b5-451a4ccfeb71	\N	6ad50f92-7d42-4999-ba1f-064b8ddd64df	2026-07-20 09:22:03.794401+00	2026-07-20 09:22:03.794401+00
1d224113-52fd-42ec-a3d9-ee5e9338d4af	69265e2f-e932-47e5-afdd-4a458397d29a	3940e09c-eede-4772-818b-3a4bc4703195	رفع اشکالات و بازبینی	80	25	2026-06-24	approved	127c1187-f85a-48c8-82b5-451a4ccfeb71	\N	017568aa-b6d8-4598-b3bf-26281a195bbc	2026-07-20 09:22:03.794401+00	2026-07-20 09:22:03.794401+00
1d224113-52fd-42ec-a3d9-ee5e9338d4af	69265e2f-e932-47e5-afdd-4a458397d29a	3940e09c-eede-4772-818b-3a4bc4703195	پیشرفت اولیه و بررسی نیازمندی‌ها	75	80	2026-06-26	submitted	\N	\N	0dbf9c58-b6ec-407f-9ce3-1211cfc3dbeb	2026-07-20 09:22:03.794401+00	2026-07-20 09:22:03.794401+00
1d224113-52fd-42ec-a3d9-ee5e9338d4af	f33ec0ad-eb35-47ba-abe6-9b0ffbac9c39	0132fd66-319f-4f6e-8e2f-d16328d278e8	مستندسازی و نهایی‌سازی	224	38	2026-07-16	approved	127c1187-f85a-48c8-82b5-451a4ccfeb71	\N	9d297cd6-8459-4876-92f9-c4253f5d78aa	2026-07-20 09:22:03.794401+00	2026-07-20 09:22:03.794401+00
1d224113-52fd-42ec-a3d9-ee5e9338d4af	f33ec0ad-eb35-47ba-abe6-9b0ffbac9c39	0132fd66-319f-4f6e-8e2f-d16328d278e8	مستندسازی و نهایی‌سازی	194	80	2026-07-16	approved	127c1187-f85a-48c8-82b5-451a4ccfeb71	\N	a94cf895-8b9b-4be1-a015-a880222a8b86	2026-07-20 09:22:03.794401+00	2026-07-20 09:22:03.794401+00
1d224113-52fd-42ec-a3d9-ee5e9338d4af	f33ec0ad-eb35-47ba-abe6-9b0ffbac9c39	0132fd66-319f-4f6e-8e2f-d16328d278e8	رفع اشکالات و بازبینی	68	100	2026-07-16	approved	127c1187-f85a-48c8-82b5-451a4ccfeb71	\N	a5e7ba2d-6368-4a7e-8f31-cf5d9e61c27f	2026-07-20 09:22:03.794401+00	2026-07-20 09:22:03.794401+00
1d224113-52fd-42ec-a3d9-ee5e9338d4af	f33ec0ad-eb35-47ba-abe6-9b0ffbac9c39	0132fd66-319f-4f6e-8e2f-d16328d278e8	تست و اطمینان از عملکرد صحیح	143	100	2026-07-16	approved	127c1187-f85a-48c8-82b5-451a4ccfeb71	\N	4bd032ff-833c-4111-8749-905efea10390	2026-07-20 09:22:03.794401+00	2026-07-20 09:22:03.794401+00
1d224113-52fd-42ec-a3d9-ee5e9338d4af	1f69e85f-dfe1-4b9c-9ce6-2008357e4d3f	127c1187-f85a-48c8-82b5-451a4ccfeb71	مستندسازی و نهایی‌سازی	44	31	2026-07-16	approved	127c1187-f85a-48c8-82b5-451a4ccfeb71	\N	f1553237-8b85-4de7-9ab1-31786287909c	2026-07-20 09:22:03.794401+00	2026-07-20 09:22:03.794401+00
1d224113-52fd-42ec-a3d9-ee5e9338d4af	1f69e85f-dfe1-4b9c-9ce6-2008357e4d3f	127c1187-f85a-48c8-82b5-451a4ccfeb71	رفع اشکالات و بازبینی	148	68	2026-07-16	approved	127c1187-f85a-48c8-82b5-451a4ccfeb71	\N	11952016-b92d-4174-8ddb-12828b8de304	2026-07-20 09:22:03.794401+00	2026-07-20 09:22:03.794401+00
1d224113-52fd-42ec-a3d9-ee5e9338d4af	1f69e85f-dfe1-4b9c-9ce6-2008357e4d3f	127c1187-f85a-48c8-82b5-451a4ccfeb71	پیشرفت اولیه و بررسی نیازمندی‌ها	124	87	2026-07-16	approved	127c1187-f85a-48c8-82b5-451a4ccfeb71	\N	3535af78-0350-48be-b11f-377756fb3e84	2026-07-20 09:22:03.794401+00	2026-07-20 09:22:03.794401+00
1d224113-52fd-42ec-a3d9-ee5e9338d4af	b747d1a4-03ed-4dcf-9bab-0b8dc42937eb	6fb1a35d-b064-46b8-8796-54c4fec69d24	مستندسازی و نهایی‌سازی	182	36	2026-06-17	approved	127c1187-f85a-48c8-82b5-451a4ccfeb71	\N	0061bf22-bff4-4113-972c-380c044bb67c	2026-07-20 09:22:03.794401+00	2026-07-20 09:22:03.794401+00
1d224113-52fd-42ec-a3d9-ee5e9338d4af	5537ca85-4d6e-480e-9feb-c366761e62ca	6fb1a35d-b064-46b8-8796-54c4fec69d24	پیشرفت اولیه و بررسی نیازمندی‌ها	145	38	2026-06-26	approved	127c1187-f85a-48c8-82b5-451a4ccfeb71	\N	a96f3b72-7b41-428f-b576-6ac0d5b0d18f	2026-07-20 09:22:03.794401+00	2026-07-20 09:22:03.794401+00
1d224113-52fd-42ec-a3d9-ee5e9338d4af	5537ca85-4d6e-480e-9feb-c366761e62ca	6fb1a35d-b064-46b8-8796-54c4fec69d24	تست و اطمینان از عملکرد صحیح	158	48	2026-06-28	approved	127c1187-f85a-48c8-82b5-451a4ccfeb71	\N	76825480-a299-4d0a-a824-4e0aaadebb65	2026-07-20 09:22:03.794401+00	2026-07-20 09:22:03.794401+00
1d224113-52fd-42ec-a3d9-ee5e9338d4af	5537ca85-4d6e-480e-9feb-c366761e62ca	6fb1a35d-b064-46b8-8796-54c4fec69d24	رفع اشکالات و بازبینی	212	66	2026-06-28	approved	127c1187-f85a-48c8-82b5-451a4ccfeb71	\N	79b07b07-a217-45ea-9614-074dd2af56f0	2026-07-20 09:22:03.794401+00	2026-07-20 09:22:03.794401+00
1d224113-52fd-42ec-a3d9-ee5e9338d4af	5537ca85-4d6e-480e-9feb-c366761e62ca	6fb1a35d-b064-46b8-8796-54c4fec69d24	تست و اطمینان از عملکرد صحیح	142	100	2026-07-02	approved	127c1187-f85a-48c8-82b5-451a4ccfeb71	\N	a089678d-125a-4a56-b94b-f7f08b9f489e	2026-07-20 09:22:03.794401+00	2026-07-20 09:22:03.794401+00
1d224113-52fd-42ec-a3d9-ee5e9338d4af	b6176adb-0e1a-4ef4-84a7-bff422ecf92e	0132fd66-319f-4f6e-8e2f-d16328d278e8	رفع اشکالات و بازبینی	129	33	2026-06-22	approved	127c1187-f85a-48c8-82b5-451a4ccfeb71	\N	74b0bc8d-e41c-45ba-8b08-c1d9c5b597a0	2026-07-20 09:22:03.794401+00	2026-07-20 09:22:03.794401+00
1d224113-52fd-42ec-a3d9-ee5e9338d4af	b6176adb-0e1a-4ef4-84a7-bff422ecf92e	0132fd66-319f-4f6e-8e2f-d16328d278e8	پیشرفت اولیه و بررسی نیازمندی‌ها	232	80	2026-06-25	approved	127c1187-f85a-48c8-82b5-451a4ccfeb71	\N	1494b64d-becb-4b13-aba1-6d6a0b2f8c6b	2026-07-20 09:22:03.794401+00	2026-07-20 09:22:03.794401+00
1d224113-52fd-42ec-a3d9-ee5e9338d4af	1fd5e3b7-ef00-4c2b-81d7-524e9571836d	f4e6dc2a-b9f2-43e2-8db1-3516a3e2985c	مستندسازی و نهایی‌سازی	203	32	2026-07-16	approved	127c1187-f85a-48c8-82b5-451a4ccfeb71	\N	f62954a1-7a5f-4dab-ae1f-64efd4c7314d	2026-07-20 09:22:03.794401+00	2026-07-20 09:22:03.794401+00
1d224113-52fd-42ec-a3d9-ee5e9338d4af	1fd5e3b7-ef00-4c2b-81d7-524e9571836d	f4e6dc2a-b9f2-43e2-8db1-3516a3e2985c	مستندسازی و نهایی‌سازی	68	60	2026-07-16	approved	127c1187-f85a-48c8-82b5-451a4ccfeb71	\N	365f551a-6769-4689-8179-e63ecb958a37	2026-07-20 09:22:03.794401+00	2026-07-20 09:22:03.794401+00
1d224113-52fd-42ec-a3d9-ee5e9338d4af	1fd5e3b7-ef00-4c2b-81d7-524e9571836d	f4e6dc2a-b9f2-43e2-8db1-3516a3e2985c	پیاده‌سازی بخش اصلی	119	87	2026-07-16	approved	127c1187-f85a-48c8-82b5-451a4ccfeb71	\N	90ad256c-7182-4d3d-99f7-06f010a16f22	2026-07-20 09:22:03.794401+00	2026-07-20 09:22:03.794401+00
1d224113-52fd-42ec-a3d9-ee5e9338d4af	62519614-e8b3-4332-86df-f81c95854780	3940e09c-eede-4772-818b-3a4bc4703195	مستندسازی و نهایی‌سازی	211	22	2026-07-05	approved	127c1187-f85a-48c8-82b5-451a4ccfeb71	\N	b7e4494e-c100-407d-a7e3-f2409c64eb98	2026-07-20 09:22:03.794401+00	2026-07-20 09:22:03.794401+00
1d224113-52fd-42ec-a3d9-ee5e9338d4af	62519614-e8b3-4332-86df-f81c95854780	3940e09c-eede-4772-818b-3a4bc4703195	مستندسازی و نهایی‌سازی	126	80	2026-07-08	approved	127c1187-f85a-48c8-82b5-451a4ccfeb71	\N	5e65d770-c912-4e9a-a5ac-39f0629bf236	2026-07-20 09:22:03.794401+00	2026-07-20 09:22:03.794401+00
1d224113-52fd-42ec-a3d9-ee5e9338d4af	62519614-e8b3-4332-86df-f81c95854780	3940e09c-eede-4772-818b-3a4bc4703195	پیاده‌سازی بخش اصلی	201	100	2026-07-11	approved	127c1187-f85a-48c8-82b5-451a4ccfeb71	\N	8e56087a-feef-475b-9fea-82d7ace7dd49	2026-07-20 09:22:03.794401+00	2026-07-20 09:22:03.794401+00
1d224113-52fd-42ec-a3d9-ee5e9338d4af	62519614-e8b3-4332-86df-f81c95854780	3940e09c-eede-4772-818b-3a4bc4703195	تست و اطمینان از عملکرد صحیح	160	100	2026-07-08	approved	127c1187-f85a-48c8-82b5-451a4ccfeb71	\N	e169869f-9cff-43ad-82b5-ac983cf742fb	2026-07-20 09:22:03.794401+00	2026-07-20 09:22:03.794401+00
1d224113-52fd-42ec-a3d9-ee5e9338d4af	ebc86503-f045-485d-acb2-b0f17e987865	a2c3e527-82e9-4bd2-be63-85f6ead97337	رفع اشکالات و بازبینی	76	26	2026-07-09	approved	127c1187-f85a-48c8-82b5-451a4ccfeb71	\N	9534e0e2-ab0b-4a8e-ab1e-3da728705e68	2026-07-20 09:22:03.794401+00	2026-07-20 09:22:03.794401+00
1d224113-52fd-42ec-a3d9-ee5e9338d4af	83b66213-b1a7-4ded-bfea-dedf5bfd0643	6fb1a35d-b064-46b8-8796-54c4fec69d24	پیاده‌سازی بخش اصلی	69	22	2026-07-16	approved	127c1187-f85a-48c8-82b5-451a4ccfeb71	\N	ddd0a0fb-3da2-4433-a1b9-2f9bb26368bf	2026-07-20 09:22:03.794401+00	2026-07-20 09:22:03.794401+00
1d224113-52fd-42ec-a3d9-ee5e9338d4af	83b66213-b1a7-4ded-bfea-dedf5bfd0643	6fb1a35d-b064-46b8-8796-54c4fec69d24	پیشرفت اولیه و بررسی نیازمندی‌ها	159	74	2026-07-16	submitted	\N	\N	54913d04-fd8e-4bbf-8b22-53702d58ce42	2026-07-20 09:22:03.794401+00	2026-07-20 09:22:03.794401+00
1d224113-52fd-42ec-a3d9-ee5e9338d4af	83b66213-b1a7-4ded-bfea-dedf5bfd0643	6fb1a35d-b064-46b8-8796-54c4fec69d24	مستندسازی و نهایی‌سازی	63	100	2026-07-16	approved	127c1187-f85a-48c8-82b5-451a4ccfeb71	\N	d870eb44-bedd-486e-b6e3-b23e42c08eea	2026-07-20 09:22:03.794401+00	2026-07-20 09:22:03.794401+00
1d224113-52fd-42ec-a3d9-ee5e9338d4af	d5848785-9c0a-4f11-b0c5-2ead6e842227	6fb1a35d-b064-46b8-8796-54c4fec69d24	پیاده‌سازی بخش اصلی	76	39	2026-07-13	approved	127c1187-f85a-48c8-82b5-451a4ccfeb71	\N	098c170b-1472-41f2-a019-27c656ed7079	2026-07-20 09:22:03.794401+00	2026-07-20 09:22:03.794401+00
1d224113-52fd-42ec-a3d9-ee5e9338d4af	d5848785-9c0a-4f11-b0c5-2ead6e842227	6fb1a35d-b064-46b8-8796-54c4fec69d24	تست و اطمینان از عملکرد صحیح	41	66	2026-07-15	approved	127c1187-f85a-48c8-82b5-451a4ccfeb71	\N	52adb756-2f70-4990-9b15-414118bbe4e5	2026-07-20 09:22:03.794401+00	2026-07-20 09:22:03.794401+00
1d224113-52fd-42ec-a3d9-ee5e9338d4af	d5848785-9c0a-4f11-b0c5-2ead6e842227	6fb1a35d-b064-46b8-8796-54c4fec69d24	پیاده‌سازی بخش اصلی	143	100	2026-07-16	approved	127c1187-f85a-48c8-82b5-451a4ccfeb71	\N	ee6aae95-a4f2-4dec-bf07-d27b157e6ca8	2026-07-20 09:22:03.794401+00	2026-07-20 09:22:03.794401+00
1d224113-52fd-42ec-a3d9-ee5e9338d4af	d5848785-9c0a-4f11-b0c5-2ead6e842227	6fb1a35d-b064-46b8-8796-54c4fec69d24	تست و اطمینان از عملکرد صحیح	89	100	2026-07-16	approved	127c1187-f85a-48c8-82b5-451a4ccfeb71	\N	c86580c5-87fc-4797-9dda-dd4a49dfe193	2026-07-20 09:22:03.794401+00	2026-07-20 09:22:03.794401+00
1d224113-52fd-42ec-a3d9-ee5e9338d4af	f475596b-8092-4b2c-a037-66b2466e6d09	a2c3e527-82e9-4bd2-be63-85f6ead97337	تست و اطمینان از عملکرد صحیح	79	31	2026-07-16	approved	127c1187-f85a-48c8-82b5-451a4ccfeb71	\N	2f228968-3da0-40b1-8a90-812feba446fe	2026-07-20 09:22:03.794401+00	2026-07-20 09:22:03.794401+00
1d224113-52fd-42ec-a3d9-ee5e9338d4af	f475596b-8092-4b2c-a037-66b2466e6d09	a2c3e527-82e9-4bd2-be63-85f6ead97337	تست و اطمینان از عملکرد صحیح	226	58	2026-07-16	approved	127c1187-f85a-48c8-82b5-451a4ccfeb71	\N	f969ac53-2953-48d9-8886-e5e12585e855	2026-07-20 09:22:03.794401+00	2026-07-20 09:22:03.794401+00
1d224113-52fd-42ec-a3d9-ee5e9338d4af	a0f199b6-bd51-4957-8ccc-92700629b06c	054f46d3-1cc2-42df-9532-2b310816822b	پیاده‌سازی بخش اصلی	235	39	2026-07-06	submitted	\N	\N	f90d5d05-4d9d-4185-adfc-3c5da1048a0f	2026-07-20 09:22:03.794401+00	2026-07-20 09:22:03.794401+00
1d224113-52fd-42ec-a3d9-ee5e9338d4af	a0f199b6-bd51-4957-8ccc-92700629b06c	054f46d3-1cc2-42df-9532-2b310816822b	پیشرفت اولیه و بررسی نیازمندی‌ها	194	70	2026-07-08	submitted	\N	\N	7bf8e05d-2a2c-4f8e-b733-1675659d4e5a	2026-07-20 09:22:03.794401+00	2026-07-20 09:22:03.794401+00
1d224113-52fd-42ec-a3d9-ee5e9338d4af	a0f199b6-bd51-4957-8ccc-92700629b06c	054f46d3-1cc2-42df-9532-2b310816822b	پیشرفت اولیه و بررسی نیازمندی‌ها	212	100	2026-07-12	approved	127c1187-f85a-48c8-82b5-451a4ccfeb71	\N	5c159d18-67ee-4767-9fa4-1a9c826346d2	2026-07-20 09:22:03.794401+00	2026-07-20 09:22:03.794401+00
1d224113-52fd-42ec-a3d9-ee5e9338d4af	a0f199b6-bd51-4957-8ccc-92700629b06c	054f46d3-1cc2-42df-9532-2b310816822b	پیاده‌سازی بخش اصلی	99	100	2026-07-09	approved	127c1187-f85a-48c8-82b5-451a4ccfeb71	\N	4d92be3a-891c-4169-88c3-f4c05df019c2	2026-07-20 09:22:03.794401+00	2026-07-20 09:22:03.794401+00
1d224113-52fd-42ec-a3d9-ee5e9338d4af	c441efdf-bbcd-4dae-b2b8-26d2a716ab17	0132fd66-319f-4f6e-8e2f-d16328d278e8	پیشرفت اولیه و بررسی نیازمندی‌ها	86	34	2026-07-15	approved	127c1187-f85a-48c8-82b5-451a4ccfeb71	\N	f2a3a2fa-e9ca-4794-a112-1f00abda312f	2026-07-20 09:22:03.794401+00	2026-07-20 09:22:03.794401+00
1d224113-52fd-42ec-a3d9-ee5e9338d4af	c441efdf-bbcd-4dae-b2b8-26d2a716ab17	0132fd66-319f-4f6e-8e2f-d16328d278e8	پیشرفت اولیه و بررسی نیازمندی‌ها	136	42	2026-07-16	approved	127c1187-f85a-48c8-82b5-451a4ccfeb71	\N	8c01e95e-bf53-4cf2-955a-90939f19c8db	2026-07-20 09:22:03.794401+00	2026-07-20 09:22:03.794401+00
1d224113-52fd-42ec-a3d9-ee5e9338d4af	eb82fb3a-460b-4573-9812-54361eb9bb74	f4e6dc2a-b9f2-43e2-8db1-3516a3e2985c	پیشرفت اولیه و بررسی نیازمندی‌ها	125	27	2026-06-27	approved	127c1187-f85a-48c8-82b5-451a4ccfeb71	\N	3f9f4c9b-53b9-4d74-be81-1d40ccb883c6	2026-07-20 09:22:03.794401+00	2026-07-20 09:22:03.794401+00
1d224113-52fd-42ec-a3d9-ee5e9338d4af	eb82fb3a-460b-4573-9812-54361eb9bb74	f4e6dc2a-b9f2-43e2-8db1-3516a3e2985c	پیشرفت اولیه و بررسی نیازمندی‌ها	212	80	2026-06-28	approved	127c1187-f85a-48c8-82b5-451a4ccfeb71	\N	6b32f334-97dd-4f9d-9026-3670ff29d499	2026-07-20 09:22:03.794401+00	2026-07-20 09:22:03.794401+00
1d224113-52fd-42ec-a3d9-ee5e9338d4af	eb82fb3a-460b-4573-9812-54361eb9bb74	f4e6dc2a-b9f2-43e2-8db1-3516a3e2985c	پیاده‌سازی بخش اصلی	39	87	2026-07-03	submitted	\N	\N	c34f2e7f-a5b5-414a-99ff-21cd5b655fe6	2026-07-20 09:22:03.794401+00	2026-07-20 09:22:03.794401+00
1d224113-52fd-42ec-a3d9-ee5e9338d4af	eb82fb3a-460b-4573-9812-54361eb9bb74	f4e6dc2a-b9f2-43e2-8db1-3516a3e2985c	پیاده‌سازی بخش اصلی	224	100	2026-07-09	approved	127c1187-f85a-48c8-82b5-451a4ccfeb71	\N	b91391f5-4c72-4293-9283-67f10a4a154e	2026-07-20 09:22:03.794401+00	2026-07-20 09:22:03.794401+00
1d224113-52fd-42ec-a3d9-ee5e9338d4af	11bf3e6f-8695-4755-9751-68b6afc7a19b	054f46d3-1cc2-42df-9532-2b310816822b	پیشرفت اولیه و بررسی نیازمندی‌ها	34	28	2026-07-16	approved	127c1187-f85a-48c8-82b5-451a4ccfeb71	\N	fdcbb1ca-5780-4563-8c0e-77e3245f2c81	2026-07-20 09:22:03.794401+00	2026-07-20 09:22:03.794401+00
1d224113-52fd-42ec-a3d9-ee5e9338d4af	11bf3e6f-8695-4755-9751-68b6afc7a19b	054f46d3-1cc2-42df-9532-2b310816822b	پیاده‌سازی بخش اصلی	170	78	2026-07-16	approved	127c1187-f85a-48c8-82b5-451a4ccfeb71	\N	8191ba25-d093-44f4-8c46-16ceb3f3eec5	2026-07-20 09:22:03.794401+00	2026-07-20 09:22:03.794401+00
1d224113-52fd-42ec-a3d9-ee5e9338d4af	11bf3e6f-8695-4755-9751-68b6afc7a19b	054f46d3-1cc2-42df-9532-2b310816822b	پیشرفت اولیه و بررسی نیازمندی‌ها	228	87	2026-07-16	approved	127c1187-f85a-48c8-82b5-451a4ccfeb71	\N	f4d9d849-907a-41dd-b2ef-e5d297cd9b47	2026-07-20 09:22:03.794401+00	2026-07-20 09:22:03.794401+00
1d224113-52fd-42ec-a3d9-ee5e9338d4af	11bf3e6f-8695-4755-9751-68b6afc7a19b	054f46d3-1cc2-42df-9532-2b310816822b	رفع اشکالات و بازبینی	61	84	2026-07-16	approved	127c1187-f85a-48c8-82b5-451a4ccfeb71	\N	5c71896b-4ad1-4c52-85d9-307dfce07c3e	2026-07-20 09:22:03.794401+00	2026-07-20 09:22:03.794401+00
1d224113-52fd-42ec-a3d9-ee5e9338d4af	6db1c06c-9fde-4b8f-8197-01a04f12ad46	1fd4dffb-d8db-4387-914a-be2a2a6fd6b1	پیشرفت اولیه و بررسی نیازمندی‌ها	221	35	2026-07-16	submitted	\N	\N	952e4b1f-ce4f-4bd3-a4e6-61f979029dea	2026-07-20 09:22:03.794401+00	2026-07-20 09:22:03.794401+00
1d224113-52fd-42ec-a3d9-ee5e9338d4af	10dcb8a8-1407-494c-8331-a090f11dd64e	1fd4dffb-d8db-4387-914a-be2a2a6fd6b1	تست و اطمینان از عملکرد صحیح	91	37	2026-07-16	approved	b3e7b1f6-d818-46bc-a98e-9f7048e16f8f	\N	fe61cbdf-916b-42dd-8414-49169a3d2767	2026-07-20 09:22:03.794401+00	2026-07-20 09:22:03.794401+00
1d224113-52fd-42ec-a3d9-ee5e9338d4af	10dcb8a8-1407-494c-8331-a090f11dd64e	1fd4dffb-d8db-4387-914a-be2a2a6fd6b1	رفع اشکالات و بازبینی	127	68	2026-07-16	approved	b3e7b1f6-d818-46bc-a98e-9f7048e16f8f	\N	68583dfa-37f2-413e-91d9-314213fc2d87	2026-07-20 09:22:03.794401+00	2026-07-20 09:22:03.794401+00
1d224113-52fd-42ec-a3d9-ee5e9338d4af	2b3ed621-e0ec-4cbf-b5c5-0607d2e5ee16	b3e7b1f6-d818-46bc-a98e-9f7048e16f8f	رفع اشکالات و بازبینی	122	36	2026-07-16	approved	b3e7b1f6-d818-46bc-a98e-9f7048e16f8f	\N	38000c34-d59c-4b10-a6da-2f66e8aebec8	2026-07-20 09:22:03.794401+00	2026-07-20 09:22:03.794401+00
1d224113-52fd-42ec-a3d9-ee5e9338d4af	2b3ed621-e0ec-4cbf-b5c5-0607d2e5ee16	b3e7b1f6-d818-46bc-a98e-9f7048e16f8f	تست و اطمینان از عملکرد صحیح	55	70	2026-07-16	approved	b3e7b1f6-d818-46bc-a98e-9f7048e16f8f	\N	cecb9da6-f155-466c-b538-d5ca3b8dd33c	2026-07-20 09:22:03.794401+00	2026-07-20 09:22:03.794401+00
1d224113-52fd-42ec-a3d9-ee5e9338d4af	2b3ed621-e0ec-4cbf-b5c5-0607d2e5ee16	b3e7b1f6-d818-46bc-a98e-9f7048e16f8f	پیاده‌سازی بخش اصلی	124	90	2026-07-16	approved	b3e7b1f6-d818-46bc-a98e-9f7048e16f8f	\N	b45548a0-7160-42ea-a2eb-8c74e12745bd	2026-07-20 09:22:03.794401+00	2026-07-20 09:22:03.794401+00
1d224113-52fd-42ec-a3d9-ee5e9338d4af	01789686-8935-49fd-be65-e81f1cbf8cfe	b3e7b1f6-d818-46bc-a98e-9f7048e16f8f	پیاده‌سازی بخش اصلی	219	24	2026-07-16	approved	b3e7b1f6-d818-46bc-a98e-9f7048e16f8f	\N	6aad4d01-09ba-4ae3-9d85-011f4478e62d	2026-07-20 09:22:03.794401+00	2026-07-20 09:22:03.794401+00
1d224113-52fd-42ec-a3d9-ee5e9338d4af	01789686-8935-49fd-be65-e81f1cbf8cfe	b3e7b1f6-d818-46bc-a98e-9f7048e16f8f	مستندسازی و نهایی‌سازی	178	66	2026-07-16	approved	b3e7b1f6-d818-46bc-a98e-9f7048e16f8f	\N	82503a20-c5bd-46ba-9ecb-7bca74a8a163	2026-07-20 09:22:03.794401+00	2026-07-20 09:22:03.794401+00
1d224113-52fd-42ec-a3d9-ee5e9338d4af	01789686-8935-49fd-be65-e81f1cbf8cfe	b3e7b1f6-d818-46bc-a98e-9f7048e16f8f	رفع اشکالات و بازبینی	88	96	2026-07-16	approved	b3e7b1f6-d818-46bc-a98e-9f7048e16f8f	\N	9e79c3fa-8d44-47bc-b6dc-6b19b9025491	2026-07-20 09:22:03.794401+00	2026-07-20 09:22:03.794401+00
1d224113-52fd-42ec-a3d9-ee5e9338d4af	01789686-8935-49fd-be65-e81f1cbf8cfe	b3e7b1f6-d818-46bc-a98e-9f7048e16f8f	رفع اشکالات و بازبینی	95	100	2026-07-16	approved	b3e7b1f6-d818-46bc-a98e-9f7048e16f8f	\N	76e6d141-c714-4142-aa64-b8801ff70f35	2026-07-20 09:22:03.794401+00	2026-07-20 09:22:03.794401+00
1d224113-52fd-42ec-a3d9-ee5e9338d4af	1b9015fe-8f2d-48ec-ba19-68e9b51d02c6	1bd96f4a-6acb-4464-8452-ca1d3114a328	پیاده‌سازی بخش اصلی	217	31	2026-07-14	approved	b3e7b1f6-d818-46bc-a98e-9f7048e16f8f	\N	57713843-2c76-4262-9536-697abb10eca7	2026-07-20 09:22:03.794401+00	2026-07-20 09:22:03.794401+00
1d224113-52fd-42ec-a3d9-ee5e9338d4af	1b9015fe-8f2d-48ec-ba19-68e9b51d02c6	1bd96f4a-6acb-4464-8452-ca1d3114a328	پیاده‌سازی بخش اصلی	214	74	2026-07-16	approved	b3e7b1f6-d818-46bc-a98e-9f7048e16f8f	\N	16b39aa5-9a43-40fc-8d51-40eb9a78b1f3	2026-07-20 09:22:03.794401+00	2026-07-20 09:22:03.794401+00
1d224113-52fd-42ec-a3d9-ee5e9338d4af	1b9015fe-8f2d-48ec-ba19-68e9b51d02c6	1bd96f4a-6acb-4464-8452-ca1d3114a328	پیاده‌سازی بخش اصلی	168	100	2026-07-16	approved	b3e7b1f6-d818-46bc-a98e-9f7048e16f8f	\N	dae6bfab-dd42-4698-8b04-dd677f935662	2026-07-20 09:22:03.794401+00	2026-07-20 09:22:03.794401+00
1d224113-52fd-42ec-a3d9-ee5e9338d4af	1b9015fe-8f2d-48ec-ba19-68e9b51d02c6	1bd96f4a-6acb-4464-8452-ca1d3114a328	مستندسازی و نهایی‌سازی	38	88	2026-07-16	approved	b3e7b1f6-d818-46bc-a98e-9f7048e16f8f	\N	65d45826-40bc-4e11-9672-957751c270e3	2026-07-20 09:22:03.794401+00	2026-07-20 09:22:03.794401+00
1d224113-52fd-42ec-a3d9-ee5e9338d4af	a795886c-f9f8-40af-a2cf-5f024439e800	1fd4dffb-d8db-4387-914a-be2a2a6fd6b1	پیاده‌سازی بخش اصلی	47	24	2026-07-16	approved	b3e7b1f6-d818-46bc-a98e-9f7048e16f8f	\N	288764ce-76ab-4a99-a442-7954ae5281b8	2026-07-20 09:22:03.794401+00	2026-07-20 09:22:03.794401+00
1d224113-52fd-42ec-a3d9-ee5e9338d4af	75c8d753-c02e-46b3-9fff-fa9caea96566	03c131a9-29b0-4e66-8d67-be78cfa01885	مستندسازی و نهایی‌سازی	146	31	2026-07-16	approved	b3e7b1f6-d818-46bc-a98e-9f7048e16f8f	\N	eff3ed8a-81f2-4242-86f1-0d1012d97f6b	2026-07-20 09:22:03.794401+00	2026-07-20 09:22:03.794401+00
1d224113-52fd-42ec-a3d9-ee5e9338d4af	ee655062-7021-435f-8af4-d3402372365e	8cca3fcf-f7a7-421a-b9a4-5dab90fe1b83	پیشرفت اولیه و بررسی نیازمندی‌ها	31	37	2026-06-23	approved	b3e7b1f6-d818-46bc-a98e-9f7048e16f8f	\N	db47b9d7-041d-4122-bf2f-877360c1d531	2026-07-20 09:22:03.794401+00	2026-07-20 09:22:03.794401+00
1d224113-52fd-42ec-a3d9-ee5e9338d4af	7ae62839-3b23-4f35-9515-facb01064d2c	8cca3fcf-f7a7-421a-b9a4-5dab90fe1b83	پیشرفت اولیه و بررسی نیازمندی‌ها	165	28	2026-07-16	approved	b3e7b1f6-d818-46bc-a98e-9f7048e16f8f	\N	7666684b-6e4a-4f82-8977-bfe9823c9a17	2026-07-20 09:22:03.794401+00	2026-07-20 09:22:03.794401+00
1d224113-52fd-42ec-a3d9-ee5e9338d4af	7ae62839-3b23-4f35-9515-facb01064d2c	8cca3fcf-f7a7-421a-b9a4-5dab90fe1b83	پیشرفت اولیه و بررسی نیازمندی‌ها	158	66	2026-07-16	approved	b3e7b1f6-d818-46bc-a98e-9f7048e16f8f	\N	028d7234-5562-4bc3-9b5b-5feecf38436a	2026-07-20 09:22:03.794401+00	2026-07-20 09:22:03.794401+00
1d224113-52fd-42ec-a3d9-ee5e9338d4af	7ae62839-3b23-4f35-9515-facb01064d2c	8cca3fcf-f7a7-421a-b9a4-5dab90fe1b83	پیشرفت اولیه و بررسی نیازمندی‌ها	54	100	2026-07-16	approved	b3e7b1f6-d818-46bc-a98e-9f7048e16f8f	\N	280d1f5f-f383-4d33-b596-7b884c0e2ab0	2026-07-20 09:22:03.794401+00	2026-07-20 09:22:03.794401+00
1d224113-52fd-42ec-a3d9-ee5e9338d4af	7ae62839-3b23-4f35-9515-facb01064d2c	8cca3fcf-f7a7-421a-b9a4-5dab90fe1b83	پیاده‌سازی بخش اصلی	79	100	2026-07-16	approved	b3e7b1f6-d818-46bc-a98e-9f7048e16f8f	\N	8f57791c-e276-47a8-b1fc-36d13ee12d5c	2026-07-20 09:22:03.794401+00	2026-07-20 09:22:03.794401+00
1d224113-52fd-42ec-a3d9-ee5e9338d4af	d8fea49c-fb6a-46fc-9b02-98398000e505	8a6bd071-9f82-4273-b101-9c763d6c4be4	رفع اشکالات و بازبینی	233	32	2026-07-09	approved	b3e7b1f6-d818-46bc-a98e-9f7048e16f8f	\N	36e015ce-3625-49a8-9aa3-63a27bb4934b	2026-07-20 09:22:03.794401+00	2026-07-20 09:22:03.794401+00
1d224113-52fd-42ec-a3d9-ee5e9338d4af	d8fea49c-fb6a-46fc-9b02-98398000e505	8a6bd071-9f82-4273-b101-9c763d6c4be4	رفع اشکالات و بازبینی	133	68	2026-07-10	approved	b3e7b1f6-d818-46bc-a98e-9f7048e16f8f	\N	22c8c2cb-de1c-4d10-894a-4f0007936704	2026-07-20 09:22:03.794401+00	2026-07-20 09:22:03.794401+00
1d224113-52fd-42ec-a3d9-ee5e9338d4af	d8fea49c-fb6a-46fc-9b02-98398000e505	8a6bd071-9f82-4273-b101-9c763d6c4be4	پیاده‌سازی بخش اصلی	106	66	2026-07-13	approved	b3e7b1f6-d818-46bc-a98e-9f7048e16f8f	\N	48bb2a1d-ad19-4b1d-85a2-d688dee9d43d	2026-07-20 09:22:03.794401+00	2026-07-20 09:22:03.794401+00
1d224113-52fd-42ec-a3d9-ee5e9338d4af	62477096-3bfd-4907-a8d9-d04175035898	1fd4dffb-d8db-4387-914a-be2a2a6fd6b1	تست و اطمینان از عملکرد صحیح	127	32	2026-07-16	approved	b3e7b1f6-d818-46bc-a98e-9f7048e16f8f	\N	800abad3-4a81-40aa-a8ac-df199b9c65d3	2026-07-20 09:22:03.794401+00	2026-07-20 09:22:03.794401+00
1d224113-52fd-42ec-a3d9-ee5e9338d4af	95103225-e42d-4c99-8383-5bac772b939f	8a6bd071-9f82-4273-b101-9c763d6c4be4	پیشرفت اولیه و بررسی نیازمندی‌ها	209	25	2026-07-16	approved	b3e7b1f6-d818-46bc-a98e-9f7048e16f8f	\N	ea88c64d-6ea2-470b-bc48-d83e1a4f89d0	2026-07-20 09:22:03.794401+00	2026-07-20 09:22:03.794401+00
1d224113-52fd-42ec-a3d9-ee5e9338d4af	95103225-e42d-4c99-8383-5bac772b939f	8a6bd071-9f82-4273-b101-9c763d6c4be4	تست و اطمینان از عملکرد صحیح	141	80	2026-07-16	approved	b3e7b1f6-d818-46bc-a98e-9f7048e16f8f	\N	626967f3-c8d2-4241-b83e-ff075e2196b2	2026-07-20 09:22:03.794401+00	2026-07-20 09:22:03.794401+00
1d224113-52fd-42ec-a3d9-ee5e9338d4af	95103225-e42d-4c99-8383-5bac772b939f	8a6bd071-9f82-4273-b101-9c763d6c4be4	مستندسازی و نهایی‌سازی	54	100	2026-07-16	approved	b3e7b1f6-d818-46bc-a98e-9f7048e16f8f	\N	3456f320-b63a-4b1a-8334-bb4d40078ec5	2026-07-20 09:22:03.794401+00	2026-07-20 09:22:03.794401+00
1d224113-52fd-42ec-a3d9-ee5e9338d4af	95103225-e42d-4c99-8383-5bac772b939f	8a6bd071-9f82-4273-b101-9c763d6c4be4	پیاده‌سازی بخش اصلی	84	100	2026-07-16	approved	b3e7b1f6-d818-46bc-a98e-9f7048e16f8f	\N	d99802ed-bc8f-4c4c-9ea2-3bde2f240522	2026-07-20 09:22:03.794401+00	2026-07-20 09:22:03.794401+00
1d224113-52fd-42ec-a3d9-ee5e9338d4af	b603f6d7-8510-4971-9705-8e7353bc21b1	8cca3fcf-f7a7-421a-b9a4-5dab90fe1b83	پیشرفت اولیه و بررسی نیازمندی‌ها	49	28	2026-07-15	approved	b3e7b1f6-d818-46bc-a98e-9f7048e16f8f	\N	ec6b369f-e7b4-46ca-b9e2-9de4dff387a5	2026-07-20 09:22:03.794401+00	2026-07-20 09:22:03.794401+00
1d224113-52fd-42ec-a3d9-ee5e9338d4af	b603f6d7-8510-4971-9705-8e7353bc21b1	8cca3fcf-f7a7-421a-b9a4-5dab90fe1b83	پیاده‌سازی بخش اصلی	110	40	2026-07-16	approved	b3e7b1f6-d818-46bc-a98e-9f7048e16f8f	\N	1406831e-206b-4911-8159-90e135d3c1fa	2026-07-20 09:22:03.794401+00	2026-07-20 09:22:03.794401+00
1d224113-52fd-42ec-a3d9-ee5e9338d4af	b603f6d7-8510-4971-9705-8e7353bc21b1	8cca3fcf-f7a7-421a-b9a4-5dab90fe1b83	مستندسازی و نهایی‌سازی	66	96	2026-07-16	approved	b3e7b1f6-d818-46bc-a98e-9f7048e16f8f	\N	44d2b0b2-6ab8-4c3d-9476-ed59a0c9e478	2026-07-20 09:22:03.794401+00	2026-07-20 09:22:03.794401+00
1d224113-52fd-42ec-a3d9-ee5e9338d4af	b603f6d7-8510-4971-9705-8e7353bc21b1	8cca3fcf-f7a7-421a-b9a4-5dab90fe1b83	رفع اشکالات و بازبینی	71	100	2026-07-16	approved	b3e7b1f6-d818-46bc-a98e-9f7048e16f8f	\N	79ec3cda-2601-42b0-a008-0977c4500724	2026-07-20 09:22:03.794401+00	2026-07-20 09:22:03.794401+00
1d224113-52fd-42ec-a3d9-ee5e9338d4af	7125a74b-bf00-4e30-8278-c86777f6ea61	03c131a9-29b0-4e66-8d67-be78cfa01885	مستندسازی و نهایی‌سازی	114	32	2026-06-27	approved	b3e7b1f6-d818-46bc-a98e-9f7048e16f8f	\N	47650000-7d6f-4370-9e72-f94f9a113a39	2026-07-20 09:22:03.794401+00	2026-07-20 09:22:03.794401+00
1d224113-52fd-42ec-a3d9-ee5e9338d4af	7125a74b-bf00-4e30-8278-c86777f6ea61	03c131a9-29b0-4e66-8d67-be78cfa01885	پیشرفت اولیه و بررسی نیازمندی‌ها	158	62	2026-06-29	approved	b3e7b1f6-d818-46bc-a98e-9f7048e16f8f	\N	1a055be6-fb77-4688-8223-686b5e4c1b64	2026-07-20 09:22:03.794401+00	2026-07-20 09:22:03.794401+00
1d224113-52fd-42ec-a3d9-ee5e9338d4af	ff5ee6ac-16fa-4940-99c2-40562fa4e90b	8a6bd071-9f82-4273-b101-9c763d6c4be4	پیشرفت اولیه و بررسی نیازمندی‌ها	117	39	2026-07-08	approved	b3e7b1f6-d818-46bc-a98e-9f7048e16f8f	\N	094b30d3-e4f0-4b1d-b8eb-f75e7d48b66b	2026-07-20 09:22:03.794401+00	2026-07-20 09:22:03.794401+00
1d224113-52fd-42ec-a3d9-ee5e9338d4af	e4bcd66e-61b2-496b-b65a-8d2cbac9c246	8a6bd071-9f82-4273-b101-9c763d6c4be4	پیشرفت اولیه و بررسی نیازمندی‌ها	192	28	2026-07-16	approved	b3e7b1f6-d818-46bc-a98e-9f7048e16f8f	\N	da911129-5c70-499b-a5de-1cdb7a22b493	2026-07-20 09:22:03.794401+00	2026-07-20 09:22:03.794401+00
1d224113-52fd-42ec-a3d9-ee5e9338d4af	e4bcd66e-61b2-496b-b65a-8d2cbac9c246	8a6bd071-9f82-4273-b101-9c763d6c4be4	تست و اطمینان از عملکرد صحیح	88	62	2026-07-16	approved	b3e7b1f6-d818-46bc-a98e-9f7048e16f8f	\N	bba51e27-581d-4473-822e-5414ea521026	2026-07-20 09:22:03.794401+00	2026-07-20 09:22:03.794401+00
1d224113-52fd-42ec-a3d9-ee5e9338d4af	e4bcd66e-61b2-496b-b65a-8d2cbac9c246	8a6bd071-9f82-4273-b101-9c763d6c4be4	تست و اطمینان از عملکرد صحیح	77	100	2026-07-16	approved	b3e7b1f6-d818-46bc-a98e-9f7048e16f8f	\N	06b23b23-f204-4897-b870-d170baa85d57	2026-07-20 09:22:03.794401+00	2026-07-20 09:22:03.794401+00
1d224113-52fd-42ec-a3d9-ee5e9338d4af	e4bcd66e-61b2-496b-b65a-8d2cbac9c246	8a6bd071-9f82-4273-b101-9c763d6c4be4	پیشرفت اولیه و بررسی نیازمندی‌ها	227	100	2026-07-16	approved	b3e7b1f6-d818-46bc-a98e-9f7048e16f8f	\N	35285439-f80a-4590-be26-0e575280644b	2026-07-20 09:22:03.794401+00	2026-07-20 09:22:03.794401+00
1d224113-52fd-42ec-a3d9-ee5e9338d4af	3d0f23ba-9349-4f64-be43-b5f4dd436851	b720465e-b31b-4b9b-99d6-b303ca5f639d	پیشرفت اولیه و بررسی نیازمندی‌ها	98	24	2026-07-16	submitted	\N	\N	0f61f4a1-155f-4c68-a028-52df3f4c4f35	2026-07-20 09:22:03.794401+00	2026-07-20 09:22:03.794401+00
1d224113-52fd-42ec-a3d9-ee5e9338d4af	3d0f23ba-9349-4f64-be43-b5f4dd436851	b720465e-b31b-4b9b-99d6-b303ca5f639d	پیاده‌سازی بخش اصلی	219	64	2026-07-16	submitted	\N	\N	66defa37-14d3-4edd-acb5-f21f0250037b	2026-07-20 09:22:03.794401+00	2026-07-20 09:22:03.794401+00
1d224113-52fd-42ec-a3d9-ee5e9338d4af	3d0f23ba-9349-4f64-be43-b5f4dd436851	b720465e-b31b-4b9b-99d6-b303ca5f639d	پیشرفت اولیه و بررسی نیازمندی‌ها	31	87	2026-07-16	approved	b3e7b1f6-d818-46bc-a98e-9f7048e16f8f	\N	620ce312-d395-498c-b3f8-56b3193a819b	2026-07-20 09:22:03.794401+00	2026-07-20 09:22:03.794401+00
1d224113-52fd-42ec-a3d9-ee5e9338d4af	d3894ef0-0886-461d-b82d-ac06ca8b6889	8a6bd071-9f82-4273-b101-9c763d6c4be4	رفع اشکالات و بازبینی	56	24	2026-07-16	approved	b3e7b1f6-d818-46bc-a98e-9f7048e16f8f	\N	cb655147-37fe-4d48-ad45-8121e4a663ee	2026-07-20 09:22:03.794401+00	2026-07-20 09:22:03.794401+00
1d224113-52fd-42ec-a3d9-ee5e9338d4af	d3894ef0-0886-461d-b82d-ac06ca8b6889	8a6bd071-9f82-4273-b101-9c763d6c4be4	پیاده‌سازی بخش اصلی	140	68	2026-07-16	approved	b3e7b1f6-d818-46bc-a98e-9f7048e16f8f	\N	20585ed7-e73f-4fb6-9f65-57d0ccef4bfa	2026-07-20 09:22:03.794401+00	2026-07-20 09:22:03.794401+00
1d224113-52fd-42ec-a3d9-ee5e9338d4af	d3894ef0-0886-461d-b82d-ac06ca8b6889	8a6bd071-9f82-4273-b101-9c763d6c4be4	پیشرفت اولیه و بررسی نیازمندی‌ها	36	66	2026-07-16	approved	b3e7b1f6-d818-46bc-a98e-9f7048e16f8f	\N	f14439b1-6ec2-4894-b6cf-678beb481044	2026-07-20 09:22:03.794401+00	2026-07-20 09:22:03.794401+00
1d224113-52fd-42ec-a3d9-ee5e9338d4af	d3894ef0-0886-461d-b82d-ac06ca8b6889	8a6bd071-9f82-4273-b101-9c763d6c4be4	مستندسازی و نهایی‌سازی	53	100	2026-07-16	approved	b3e7b1f6-d818-46bc-a98e-9f7048e16f8f	\N	333df82f-eb2a-46e9-bca9-985cd6959314	2026-07-20 09:22:03.794401+00	2026-07-20 09:22:03.794401+00
1d224113-52fd-42ec-a3d9-ee5e9338d4af	07ed9b96-4416-4e8b-8f75-9a23f3bb9be9	03c131a9-29b0-4e66-8d67-be78cfa01885	پیشرفت اولیه و بررسی نیازمندی‌ها	104	33	2026-07-15	approved	b3e7b1f6-d818-46bc-a98e-9f7048e16f8f	\N	8e26f9e4-6ce6-4c98-8aa3-495383c25e53	2026-07-20 09:22:03.794401+00	2026-07-20 09:22:03.794401+00
1d224113-52fd-42ec-a3d9-ee5e9338d4af	07ed9b96-4416-4e8b-8f75-9a23f3bb9be9	03c131a9-29b0-4e66-8d67-be78cfa01885	پیشرفت اولیه و بررسی نیازمندی‌ها	215	74	2026-07-16	approved	b3e7b1f6-d818-46bc-a98e-9f7048e16f8f	\N	c56893d5-f61e-40a3-a817-244884ddaff1	2026-07-20 09:22:03.794401+00	2026-07-20 09:22:03.794401+00
1d224113-52fd-42ec-a3d9-ee5e9338d4af	07ed9b96-4416-4e8b-8f75-9a23f3bb9be9	03c131a9-29b0-4e66-8d67-be78cfa01885	مستندسازی و نهایی‌سازی	163	75	2026-07-16	approved	b3e7b1f6-d818-46bc-a98e-9f7048e16f8f	\N	d85fdaf4-1de1-4e44-8e73-95a0acafaf49	2026-07-20 09:22:03.794401+00	2026-07-20 09:22:03.794401+00
1d224113-52fd-42ec-a3d9-ee5e9338d4af	dc524117-52f3-47f0-89d7-0965f46a4912	1fd4dffb-d8db-4387-914a-be2a2a6fd6b1	پیاده‌سازی بخش اصلی	98	29	2026-07-07	approved	b3e7b1f6-d818-46bc-a98e-9f7048e16f8f	\N	e119ee4e-f74c-4f2f-bab0-cbd6f62524e1	2026-07-20 09:22:03.794401+00	2026-07-20 09:22:03.794401+00
1d224113-52fd-42ec-a3d9-ee5e9338d4af	dc524117-52f3-47f0-89d7-0965f46a4912	1fd4dffb-d8db-4387-914a-be2a2a6fd6b1	تست و اطمینان از عملکرد صحیح	67	44	2026-07-10	approved	b3e7b1f6-d818-46bc-a98e-9f7048e16f8f	\N	efe00e7c-0518-4e29-b6e4-76fa1be00d19	2026-07-20 09:22:03.794401+00	2026-07-20 09:22:03.794401+00
1d224113-52fd-42ec-a3d9-ee5e9338d4af	dc524117-52f3-47f0-89d7-0965f46a4912	1fd4dffb-d8db-4387-914a-be2a2a6fd6b1	تست و اطمینان از عملکرد صحیح	100	99	2026-07-11	approved	b3e7b1f6-d818-46bc-a98e-9f7048e16f8f	\N	159f8b20-dbaa-44d4-ab07-26cafa686a70	2026-07-20 09:22:03.794401+00	2026-07-20 09:22:03.794401+00
1d224113-52fd-42ec-a3d9-ee5e9338d4af	dc524117-52f3-47f0-89d7-0965f46a4912	1fd4dffb-d8db-4387-914a-be2a2a6fd6b1	تست و اطمینان از عملکرد صحیح	230	88	2026-07-16	approved	b3e7b1f6-d818-46bc-a98e-9f7048e16f8f	\N	08e00eeb-784d-4092-81ee-8561ac6d200b	2026-07-20 09:22:03.794401+00	2026-07-20 09:22:03.794401+00
1d224113-52fd-42ec-a3d9-ee5e9338d4af	f352b24d-1988-418c-8e73-9b51ca72f56b	8cca3fcf-f7a7-421a-b9a4-5dab90fe1b83	پیاده‌سازی بخش اصلی	214	40	2026-07-16	approved	b3e7b1f6-d818-46bc-a98e-9f7048e16f8f	\N	7567b14f-f543-4fea-abae-0caa86e52820	2026-07-20 09:22:03.794401+00	2026-07-20 09:22:03.794401+00
1d224113-52fd-42ec-a3d9-ee5e9338d4af	f352b24d-1988-418c-8e73-9b51ca72f56b	8cca3fcf-f7a7-421a-b9a4-5dab90fe1b83	مستندسازی و نهایی‌سازی	187	52	2026-07-16	approved	b3e7b1f6-d818-46bc-a98e-9f7048e16f8f	\N	5956bfa6-4715-452b-af58-482b468152a3	2026-07-20 09:22:03.794401+00	2026-07-20 09:22:03.794401+00
1d224113-52fd-42ec-a3d9-ee5e9338d4af	f352b24d-1988-418c-8e73-9b51ca72f56b	8cca3fcf-f7a7-421a-b9a4-5dab90fe1b83	پیشرفت اولیه و بررسی نیازمندی‌ها	64	87	2026-07-16	approved	b3e7b1f6-d818-46bc-a98e-9f7048e16f8f	\N	974e23bd-f618-47f7-90c3-f11ddebe7718	2026-07-20 09:22:03.794401+00	2026-07-20 09:22:03.794401+00
1d224113-52fd-42ec-a3d9-ee5e9338d4af	83239164-5d8c-436b-a139-89eabcd1abc5	b3e7b1f6-d818-46bc-a98e-9f7048e16f8f	مستندسازی و نهایی‌سازی	127	30	2026-07-01	approved	b3e7b1f6-d818-46bc-a98e-9f7048e16f8f	\N	5e52a182-22ec-47aa-b063-c1f44aeb7fb5	2026-07-20 09:22:03.794401+00	2026-07-20 09:22:03.794401+00
1d224113-52fd-42ec-a3d9-ee5e9338d4af	d7b8b9a5-b7a9-49da-b438-1a5888788415	1bd96f4a-6acb-4464-8452-ca1d3114a328	تست و اطمینان از عملکرد صحیح	238	40	2026-07-15	approved	b3e7b1f6-d818-46bc-a98e-9f7048e16f8f	\N	b9df906b-d271-4479-8d69-e05e190fe953	2026-07-20 09:22:03.794401+00	2026-07-20 09:22:03.794401+00
1d224113-52fd-42ec-a3d9-ee5e9338d4af	d7b8b9a5-b7a9-49da-b438-1a5888788415	1bd96f4a-6acb-4464-8452-ca1d3114a328	رفع اشکالات و بازبینی	112	78	2026-07-16	approved	b3e7b1f6-d818-46bc-a98e-9f7048e16f8f	\N	66e05f78-7cf1-465c-b698-e0065b2bebf7	2026-07-20 09:22:03.794401+00	2026-07-20 09:22:03.794401+00
1d224113-52fd-42ec-a3d9-ee5e9338d4af	d7b8b9a5-b7a9-49da-b438-1a5888788415	1bd96f4a-6acb-4464-8452-ca1d3114a328	تست و اطمینان از عملکرد صحیح	110	75	2026-07-16	approved	b3e7b1f6-d818-46bc-a98e-9f7048e16f8f	\N	1316a3ea-b7a3-4395-b780-53a2f920a6cf	2026-07-20 09:22:03.794401+00	2026-07-20 09:22:03.794401+00
1d224113-52fd-42ec-a3d9-ee5e9338d4af	d7b8b9a5-b7a9-49da-b438-1a5888788415	1bd96f4a-6acb-4464-8452-ca1d3114a328	رفع اشکالات و بازبینی	104	100	2026-07-16	approved	b3e7b1f6-d818-46bc-a98e-9f7048e16f8f	\N	4391b2dd-b4c2-41e6-80e8-b1f8243b6405	2026-07-20 09:22:03.794401+00	2026-07-20 09:22:03.794401+00
1d224113-52fd-42ec-a3d9-ee5e9338d4af	5a5d0602-314a-46ab-8e0d-496f09a460e9	b3e7b1f6-d818-46bc-a98e-9f7048e16f8f	رفع اشکالات و بازبینی	239	32	2026-07-16	approved	b3e7b1f6-d818-46bc-a98e-9f7048e16f8f	\N	89118340-2bbc-4ad3-9f51-7821efd2dae3	2026-07-20 09:22:03.794401+00	2026-07-20 09:22:03.794401+00
1d224113-52fd-42ec-a3d9-ee5e9338d4af	5a5d0602-314a-46ab-8e0d-496f09a460e9	b3e7b1f6-d818-46bc-a98e-9f7048e16f8f	مستندسازی و نهایی‌سازی	81	76	2026-07-16	approved	b3e7b1f6-d818-46bc-a98e-9f7048e16f8f	\N	19433b66-10df-4206-86da-916eb2cd46eb	2026-07-20 09:22:03.794401+00	2026-07-20 09:22:03.794401+00
1d224113-52fd-42ec-a3d9-ee5e9338d4af	5a5d0602-314a-46ab-8e0d-496f09a460e9	b3e7b1f6-d818-46bc-a98e-9f7048e16f8f	مستندسازی و نهایی‌سازی	36	100	2026-07-16	approved	b3e7b1f6-d818-46bc-a98e-9f7048e16f8f	\N	109cf0c1-217d-4e12-9e2a-40691e2053ec	2026-07-20 09:22:03.794401+00	2026-07-20 09:22:03.794401+00
1d224113-52fd-42ec-a3d9-ee5e9338d4af	5a5d0602-314a-46ab-8e0d-496f09a460e9	b3e7b1f6-d818-46bc-a98e-9f7048e16f8f	رفع اشکالات و بازبینی	207	88	2026-07-16	approved	b3e7b1f6-d818-46bc-a98e-9f7048e16f8f	\N	1489ce63-c7db-4424-8ee5-5102805b4ad4	2026-07-20 09:22:03.794401+00	2026-07-20 09:22:03.794401+00
1d224113-52fd-42ec-a3d9-ee5e9338d4af	8bd0d0e8-63d6-4c50-a8c0-587e92ab2077	b3e7b1f6-d818-46bc-a98e-9f7048e16f8f	رفع اشکالات و بازبینی	91	28	2026-07-16	approved	b3e7b1f6-d818-46bc-a98e-9f7048e16f8f	\N	ebddd2c9-0681-4d56-98fb-96cd60ea49b8	2026-07-20 09:22:03.794401+00	2026-07-20 09:22:03.794401+00
1d224113-52fd-42ec-a3d9-ee5e9338d4af	8bd0d0e8-63d6-4c50-a8c0-587e92ab2077	b3e7b1f6-d818-46bc-a98e-9f7048e16f8f	تست و اطمینان از عملکرد صحیح	48	68	2026-07-16	submitted	\N	\N	c1da016f-064c-4b3a-9897-04b838fd6c40	2026-07-20 09:22:03.794401+00	2026-07-20 09:22:03.794401+00
1d224113-52fd-42ec-a3d9-ee5e9338d4af	8bd0d0e8-63d6-4c50-a8c0-587e92ab2077	b3e7b1f6-d818-46bc-a98e-9f7048e16f8f	مستندسازی و نهایی‌سازی	159	99	2026-07-16	approved	b3e7b1f6-d818-46bc-a98e-9f7048e16f8f	\N	f4b0e90b-cdaf-430d-b94f-23ea7886ac63	2026-07-20 09:22:03.794401+00	2026-07-20 09:22:03.794401+00
1d224113-52fd-42ec-a3d9-ee5e9338d4af	8bd0d0e8-63d6-4c50-a8c0-587e92ab2077	b3e7b1f6-d818-46bc-a98e-9f7048e16f8f	رفع اشکالات و بازبینی	209	100	2026-07-16	submitted	\N	\N	4d864d76-0e22-4af8-b1c7-dd4a1b640b28	2026-07-20 09:22:03.794401+00	2026-07-20 09:22:03.794401+00
1d224113-52fd-42ec-a3d9-ee5e9338d4af	3ae8b516-af4d-44e2-a683-bb07d503329f	b720465e-b31b-4b9b-99d6-b303ca5f639d	پیاده‌سازی بخش اصلی	198	31	2026-06-24	approved	b3e7b1f6-d818-46bc-a98e-9f7048e16f8f	\N	ac2c4443-7110-4ce6-b137-343283c5b3db	2026-07-20 09:22:03.794401+00	2026-07-20 09:22:03.794401+00
1d224113-52fd-42ec-a3d9-ee5e9338d4af	f283bdee-db04-4959-96cd-9b351e81787a	8cca3fcf-f7a7-421a-b9a4-5dab90fe1b83	مستندسازی و نهایی‌سازی	195	40	2026-07-16	approved	b3e7b1f6-d818-46bc-a98e-9f7048e16f8f	\N	4b55aab1-312a-413c-9eca-3ccfa78a1b64	2026-07-20 09:22:03.794401+00	2026-07-20 09:22:03.794401+00
1d224113-52fd-42ec-a3d9-ee5e9338d4af	f283bdee-db04-4959-96cd-9b351e81787a	8cca3fcf-f7a7-421a-b9a4-5dab90fe1b83	رفع اشکالات و بازبینی	233	66	2026-07-16	approved	b3e7b1f6-d818-46bc-a98e-9f7048e16f8f	\N	bea39288-67df-498b-9fe2-7af8e87e7bfb	2026-07-20 09:22:03.794401+00	2026-07-20 09:22:03.794401+00
1d224113-52fd-42ec-a3d9-ee5e9338d4af	a74d9b36-88c1-485a-852b-1b905081cc05	b720465e-b31b-4b9b-99d6-b303ca5f639d	پیشرفت اولیه و بررسی نیازمندی‌ها	96	27	2026-07-16	approved	b3e7b1f6-d818-46bc-a98e-9f7048e16f8f	\N	f1aa660c-4113-48e3-889a-b4d16670a88c	2026-07-20 09:22:03.794401+00	2026-07-20 09:22:03.794401+00
1d224113-52fd-42ec-a3d9-ee5e9338d4af	d15a1253-f522-4664-b60d-fa538b96961e	03c131a9-29b0-4e66-8d67-be78cfa01885	رفع اشکالات و بازبینی	130	34	2026-07-16	approved	b3e7b1f6-d818-46bc-a98e-9f7048e16f8f	\N	92147899-24f4-4dd2-a79f-941c8b6eeb97	2026-07-20 09:22:03.794401+00	2026-07-20 09:22:03.794401+00
1d224113-52fd-42ec-a3d9-ee5e9338d4af	d15a1253-f522-4664-b60d-fa538b96961e	03c131a9-29b0-4e66-8d67-be78cfa01885	رفع اشکالات و بازبینی	36	70	2026-07-16	approved	b3e7b1f6-d818-46bc-a98e-9f7048e16f8f	\N	619cf747-d96c-4bf0-a43f-6816901afae1	2026-07-20 09:22:03.794401+00	2026-07-20 09:22:03.794401+00
1d224113-52fd-42ec-a3d9-ee5e9338d4af	9bdba43d-bb38-4961-ab05-15c18af06988	8cca3fcf-f7a7-421a-b9a4-5dab90fe1b83	پیشرفت اولیه و بررسی نیازمندی‌ها	59	24	2026-07-16	approved	b3e7b1f6-d818-46bc-a98e-9f7048e16f8f	\N	24ef9d11-6df1-4e0c-9d58-6def1693a9fd	2026-07-20 09:22:03.794401+00	2026-07-20 09:22:03.794401+00
1d224113-52fd-42ec-a3d9-ee5e9338d4af	5229da09-6f16-4b36-804f-65939496195b	8a6bd071-9f82-4273-b101-9c763d6c4be4	رفع اشکالات و بازبینی	146	26	2026-07-16	approved	b3e7b1f6-d818-46bc-a98e-9f7048e16f8f	\N	2af58da7-4d0b-47bc-9abd-8a83071c838a	2026-07-20 09:22:03.794401+00	2026-07-20 09:22:03.794401+00
1d224113-52fd-42ec-a3d9-ee5e9338d4af	5229da09-6f16-4b36-804f-65939496195b	8a6bd071-9f82-4273-b101-9c763d6c4be4	رفع اشکالات و بازبینی	151	46	2026-07-16	approved	b3e7b1f6-d818-46bc-a98e-9f7048e16f8f	\N	fea417b9-5090-4184-814f-15bbf1c77aeb	2026-07-20 09:22:03.794401+00	2026-07-20 09:22:03.794401+00
1d224113-52fd-42ec-a3d9-ee5e9338d4af	5229da09-6f16-4b36-804f-65939496195b	8a6bd071-9f82-4273-b101-9c763d6c4be4	تست و اطمینان از عملکرد صحیح	111	66	2026-07-16	approved	b3e7b1f6-d818-46bc-a98e-9f7048e16f8f	\N	fd6b2835-cbc7-4a0a-85dc-866ea79430ad	2026-07-20 09:22:03.794401+00	2026-07-20 09:22:03.794401+00
1d224113-52fd-42ec-a3d9-ee5e9338d4af	21708736-c68a-4fb1-9682-ae6813fc87a2	03c131a9-29b0-4e66-8d67-be78cfa01885	پیشرفت اولیه و بررسی نیازمندی‌ها	35	30	2026-07-16	approved	b3e7b1f6-d818-46bc-a98e-9f7048e16f8f	\N	f44ff0c9-f21b-4e98-be70-adfe3be7b986	2026-07-20 09:22:03.794401+00	2026-07-20 09:22:03.794401+00
1d224113-52fd-42ec-a3d9-ee5e9338d4af	21708736-c68a-4fb1-9682-ae6813fc87a2	03c131a9-29b0-4e66-8d67-be78cfa01885	پیاده‌سازی بخش اصلی	219	54	2026-07-16	approved	b3e7b1f6-d818-46bc-a98e-9f7048e16f8f	\N	7be8b45b-b897-4355-aab0-097ee9d4b8d5	2026-07-20 09:22:03.794401+00	2026-07-20 09:22:03.794401+00
1d224113-52fd-42ec-a3d9-ee5e9338d4af	21708736-c68a-4fb1-9682-ae6813fc87a2	03c131a9-29b0-4e66-8d67-be78cfa01885	مستندسازی و نهایی‌سازی	70	90	2026-07-16	approved	b3e7b1f6-d818-46bc-a98e-9f7048e16f8f	\N	f74a0854-fb00-4ac7-b165-9c3c772e4b32	2026-07-20 09:22:03.794401+00	2026-07-20 09:22:03.794401+00
1d224113-52fd-42ec-a3d9-ee5e9338d4af	b0caa4f2-0ac0-40e5-865e-a8285764a0b1	8a6bd071-9f82-4273-b101-9c763d6c4be4	پیاده‌سازی بخش اصلی	234	32	2026-07-16	approved	b3e7b1f6-d818-46bc-a98e-9f7048e16f8f	\N	c39945a1-5654-4d98-9eb7-39414667eb56	2026-07-20 09:22:03.794401+00	2026-07-20 09:22:03.794401+00
1d224113-52fd-42ec-a3d9-ee5e9338d4af	b0caa4f2-0ac0-40e5-865e-a8285764a0b1	8a6bd071-9f82-4273-b101-9c763d6c4be4	پیاده‌سازی بخش اصلی	193	66	2026-07-16	approved	b3e7b1f6-d818-46bc-a98e-9f7048e16f8f	\N	cfa68ee9-d8f3-4d55-b8a8-f6b1b890276e	2026-07-20 09:22:03.794401+00	2026-07-20 09:22:03.794401+00
1d224113-52fd-42ec-a3d9-ee5e9338d4af	b0caa4f2-0ac0-40e5-865e-a8285764a0b1	8a6bd071-9f82-4273-b101-9c763d6c4be4	پیشرفت اولیه و بررسی نیازمندی‌ها	218	100	2026-07-16	approved	b3e7b1f6-d818-46bc-a98e-9f7048e16f8f	\N	8e98ef7e-7fdd-4d99-9a8f-348f2d8eeadf	2026-07-20 09:22:03.794401+00	2026-07-20 09:22:03.794401+00
1d224113-52fd-42ec-a3d9-ee5e9338d4af	b0caa4f2-0ac0-40e5-865e-a8285764a0b1	8a6bd071-9f82-4273-b101-9c763d6c4be4	تست و اطمینان از عملکرد صحیح	181	100	2026-07-16	approved	b3e7b1f6-d818-46bc-a98e-9f7048e16f8f	\N	10355c62-f196-4420-9d19-bfdac7f67489	2026-07-20 09:22:03.794401+00	2026-07-20 09:22:03.794401+00
1d224113-52fd-42ec-a3d9-ee5e9338d4af	642dd147-a87e-4218-b4af-0855b1ebdd0f	8a6bd071-9f82-4273-b101-9c763d6c4be4	پیاده‌سازی بخش اصلی	101	22	2026-07-12	submitted	\N	\N	b7266bbf-d2df-4a08-aa2f-36b631a1e17c	2026-07-20 09:22:03.794401+00	2026-07-20 09:22:03.794401+00
1d224113-52fd-42ec-a3d9-ee5e9338d4af	642dd147-a87e-4218-b4af-0855b1ebdd0f	8a6bd071-9f82-4273-b101-9c763d6c4be4	مستندسازی و نهایی‌سازی	77	62	2026-07-13	submitted	\N	\N	90654fd5-9fd7-486c-8aa4-ecccfb46f5c4	2026-07-20 09:22:03.794401+00	2026-07-20 09:22:03.794401+00
1d224113-52fd-42ec-a3d9-ee5e9338d4af	642dd147-a87e-4218-b4af-0855b1ebdd0f	8a6bd071-9f82-4273-b101-9c763d6c4be4	پیشرفت اولیه و بررسی نیازمندی‌ها	97	100	2026-07-16	approved	b3e7b1f6-d818-46bc-a98e-9f7048e16f8f	\N	a60f47eb-5f66-430f-8cde-9dc80164be38	2026-07-20 09:22:03.794401+00	2026-07-20 09:22:03.794401+00
1d224113-52fd-42ec-a3d9-ee5e9338d4af	642dd147-a87e-4218-b4af-0855b1ebdd0f	8a6bd071-9f82-4273-b101-9c763d6c4be4	مستندسازی و نهایی‌سازی	130	100	2026-07-16	approved	b3e7b1f6-d818-46bc-a98e-9f7048e16f8f	\N	a2504293-0936-4c66-b0b2-ca56c3ef2afe	2026-07-20 09:22:03.794401+00	2026-07-20 09:22:03.794401+00
1d224113-52fd-42ec-a3d9-ee5e9338d4af	cb7a4bdd-6cff-4677-b115-687cf6cd4ad6	8a6bd071-9f82-4273-b101-9c763d6c4be4	رفع اشکالات و بازبینی	147	39	2026-06-19	approved	b3e7b1f6-d818-46bc-a98e-9f7048e16f8f	\N	2fe19cf7-ceb7-4895-9d63-7023a160cf54	2026-07-20 09:22:03.794401+00	2026-07-20 09:22:03.794401+00
1d224113-52fd-42ec-a3d9-ee5e9338d4af	749fcfe4-e973-476a-b95c-562e8d854613	8a6bd071-9f82-4273-b101-9c763d6c4be4	مستندسازی و نهایی‌سازی	181	22	2026-07-06	approved	b3e7b1f6-d818-46bc-a98e-9f7048e16f8f	\N	67da6822-07bd-4166-aa9a-b366a29cdf65	2026-07-20 09:22:03.794401+00	2026-07-20 09:22:03.794401+00
1d224113-52fd-42ec-a3d9-ee5e9338d4af	749fcfe4-e973-476a-b95c-562e8d854613	8a6bd071-9f82-4273-b101-9c763d6c4be4	رفع اشکالات و بازبینی	60	54	2026-07-08	approved	b3e7b1f6-d818-46bc-a98e-9f7048e16f8f	\N	efdc9f46-8f1e-490f-94a0-32cc60dbd0ed	2026-07-20 09:22:03.794401+00	2026-07-20 09:22:03.794401+00
1d224113-52fd-42ec-a3d9-ee5e9338d4af	bd622b78-8262-4575-af53-04a3c6704ef8	8cca3fcf-f7a7-421a-b9a4-5dab90fe1b83	پیاده‌سازی بخش اصلی	125	24	2026-07-16	approved	b3e7b1f6-d818-46bc-a98e-9f7048e16f8f	\N	e8d32cd0-e10d-4119-9d59-e909bfdbb161	2026-07-20 09:22:03.794401+00	2026-07-20 09:22:03.794401+00
1d224113-52fd-42ec-a3d9-ee5e9338d4af	bd622b78-8262-4575-af53-04a3c6704ef8	8cca3fcf-f7a7-421a-b9a4-5dab90fe1b83	تست و اطمینان از عملکرد صحیح	182	48	2026-07-16	approved	b3e7b1f6-d818-46bc-a98e-9f7048e16f8f	\N	8866b484-b172-4739-b638-a8de0d2fcf7b	2026-07-20 09:22:03.794401+00	2026-07-20 09:22:03.794401+00
1d224113-52fd-42ec-a3d9-ee5e9338d4af	bd622b78-8262-4575-af53-04a3c6704ef8	8cca3fcf-f7a7-421a-b9a4-5dab90fe1b83	تست و اطمینان از عملکرد صحیح	77	100	2026-07-16	approved	b3e7b1f6-d818-46bc-a98e-9f7048e16f8f	\N	921f8c33-a779-4047-8db0-b7566868710c	2026-07-20 09:22:03.794401+00	2026-07-20 09:22:03.794401+00
1d224113-52fd-42ec-a3d9-ee5e9338d4af	05c62b82-c22c-459f-8666-cada75e9863d	1bd96f4a-6acb-4464-8452-ca1d3114a328	پیاده‌سازی بخش اصلی	77	30	2026-07-16	approved	b3e7b1f6-d818-46bc-a98e-9f7048e16f8f	\N	c8021e28-9f7e-4868-8f92-6564fce2908c	2026-07-20 09:22:03.794401+00	2026-07-20 09:22:03.794401+00
1d224113-52fd-42ec-a3d9-ee5e9338d4af	05c62b82-c22c-459f-8666-cada75e9863d	1bd96f4a-6acb-4464-8452-ca1d3114a328	رفع اشکالات و بازبینی	32	70	2026-07-16	approved	b3e7b1f6-d818-46bc-a98e-9f7048e16f8f	\N	5a19a6c5-35f1-4c4f-968f-21de8cedd104	2026-07-20 09:22:03.794401+00	2026-07-20 09:22:03.794401+00
1d224113-52fd-42ec-a3d9-ee5e9338d4af	25df7d54-aee0-42c0-b55d-202978e9948b	8a6bd071-9f82-4273-b101-9c763d6c4be4	تست و اطمینان از عملکرد صحیح	173	36	2026-07-16	approved	b3e7b1f6-d818-46bc-a98e-9f7048e16f8f	\N	f1a5d049-dc08-4a1e-92eb-b07bbdf9cc89	2026-07-20 09:22:03.794401+00	2026-07-20 09:22:03.794401+00
1d224113-52fd-42ec-a3d9-ee5e9338d4af	25df7d54-aee0-42c0-b55d-202978e9948b	8a6bd071-9f82-4273-b101-9c763d6c4be4	تست و اطمینان از عملکرد صحیح	205	70	2026-07-16	approved	b3e7b1f6-d818-46bc-a98e-9f7048e16f8f	\N	c9e6b60b-31cf-4bab-a424-c0a3a0307b11	2026-07-20 09:22:03.794401+00	2026-07-20 09:22:03.794401+00
1d224113-52fd-42ec-a3d9-ee5e9338d4af	639e43e6-2067-4c94-888e-64ac90538ae9	03c131a9-29b0-4e66-8d67-be78cfa01885	تست و اطمینان از عملکرد صحیح	72	22	2026-07-03	approved	b3e7b1f6-d818-46bc-a98e-9f7048e16f8f	\N	46b51c3e-62ad-4520-bce2-872b7d8560f8	2026-07-20 09:22:03.794401+00	2026-07-20 09:22:03.794401+00
1d224113-52fd-42ec-a3d9-ee5e9338d4af	639e43e6-2067-4c94-888e-64ac90538ae9	03c131a9-29b0-4e66-8d67-be78cfa01885	پیاده‌سازی بخش اصلی	104	42	2026-07-04	approved	b3e7b1f6-d818-46bc-a98e-9f7048e16f8f	\N	2c265c6d-b81c-432a-a32f-3a38da346322	2026-07-20 09:22:03.794401+00	2026-07-20 09:22:03.794401+00
1d224113-52fd-42ec-a3d9-ee5e9338d4af	639e43e6-2067-4c94-888e-64ac90538ae9	03c131a9-29b0-4e66-8d67-be78cfa01885	پیاده‌سازی بخش اصلی	167	87	2026-07-09	approved	b3e7b1f6-d818-46bc-a98e-9f7048e16f8f	\N	52aad2e8-8a18-40f4-861b-9ed89fec3344	2026-07-20 09:22:03.794401+00	2026-07-20 09:22:03.794401+00
1d224113-52fd-42ec-a3d9-ee5e9338d4af	639e43e6-2067-4c94-888e-64ac90538ae9	03c131a9-29b0-4e66-8d67-be78cfa01885	تست و اطمینان از عملکرد صحیح	174	100	2026-07-09	approved	b3e7b1f6-d818-46bc-a98e-9f7048e16f8f	\N	9bb36b21-e6d2-43c0-8570-1d97c2093915	2026-07-20 09:22:03.794401+00	2026-07-20 09:22:03.794401+00
1d224113-52fd-42ec-a3d9-ee5e9338d4af	8e22f485-090b-49e5-af17-7a5f22edbb77	1fd4dffb-d8db-4387-914a-be2a2a6fd6b1	مستندسازی و نهایی‌سازی	240	31	2026-07-16	approved	b3e7b1f6-d818-46bc-a98e-9f7048e16f8f	\N	63bc0dce-2832-42ec-b5d0-b95f732ebeb7	2026-07-20 09:22:03.794401+00	2026-07-20 09:22:03.794401+00
1d224113-52fd-42ec-a3d9-ee5e9338d4af	3c5ef3b5-f9b0-4536-aec7-db534c96733b	b3e7b1f6-d818-46bc-a98e-9f7048e16f8f	تست و اطمینان از عملکرد صحیح	56	40	2026-07-16	approved	b3e7b1f6-d818-46bc-a98e-9f7048e16f8f	\N	49970b86-e59c-4e61-a271-80a2968fa254	2026-07-20 09:22:03.794401+00	2026-07-20 09:22:03.794401+00
1d224113-52fd-42ec-a3d9-ee5e9338d4af	e9d44ac8-7dac-4a12-85ee-b3d53f3af893	03c131a9-29b0-4e66-8d67-be78cfa01885	پیشرفت اولیه و بررسی نیازمندی‌ها	145	28	2026-07-16	approved	b3e7b1f6-d818-46bc-a98e-9f7048e16f8f	\N	bbf7d8b6-c8af-4a8d-bf8d-bd3360b5306a	2026-07-20 09:22:03.794401+00	2026-07-20 09:22:03.794401+00
1d224113-52fd-42ec-a3d9-ee5e9338d4af	e9d44ac8-7dac-4a12-85ee-b3d53f3af893	03c131a9-29b0-4e66-8d67-be78cfa01885	پیشرفت اولیه و بررسی نیازمندی‌ها	142	46	2026-07-16	approved	b3e7b1f6-d818-46bc-a98e-9f7048e16f8f	\N	380cd3ea-e3ad-42e1-bf3a-44b36ff686dd	2026-07-20 09:22:03.794401+00	2026-07-20 09:22:03.794401+00
1d224113-52fd-42ec-a3d9-ee5e9338d4af	6f488f70-bc15-4c14-943d-807f19645408	b720465e-b31b-4b9b-99d6-b303ca5f639d	مستندسازی و نهایی‌سازی	206	31	2026-07-01	submitted	\N	\N	c14041e7-db6f-4311-9edf-693de644f7ad	2026-07-20 09:22:03.794401+00	2026-07-20 09:22:03.794401+00
1d224113-52fd-42ec-a3d9-ee5e9338d4af	6f488f70-bc15-4c14-943d-807f19645408	b720465e-b31b-4b9b-99d6-b303ca5f639d	پیاده‌سازی بخش اصلی	230	52	2026-07-05	approved	b3e7b1f6-d818-46bc-a98e-9f7048e16f8f	\N	71db55f1-b813-40bc-8097-eaf37af23233	2026-07-20 09:22:03.794401+00	2026-07-20 09:22:03.794401+00
1d224113-52fd-42ec-a3d9-ee5e9338d4af	b5be104b-77fa-414c-a3d5-eb8550ee2fef	1bd96f4a-6acb-4464-8452-ca1d3114a328	مستندسازی و نهایی‌سازی	119	37	2026-07-04	approved	b3e7b1f6-d818-46bc-a98e-9f7048e16f8f	\N	0c0d6ea1-0cbe-4474-8f73-1c43aa86fbf8	2026-07-20 09:22:03.794401+00	2026-07-20 09:22:03.794401+00
1d224113-52fd-42ec-a3d9-ee5e9338d4af	b5be104b-77fa-414c-a3d5-eb8550ee2fef	1bd96f4a-6acb-4464-8452-ca1d3114a328	مستندسازی و نهایی‌سازی	167	50	2026-07-07	approved	b3e7b1f6-d818-46bc-a98e-9f7048e16f8f	\N	7e3dfcd6-f342-4813-955d-3ed666626fd6	2026-07-20 09:22:03.794401+00	2026-07-20 09:22:03.794401+00
1d224113-52fd-42ec-a3d9-ee5e9338d4af	19688f35-cb03-41e0-9af7-6cc36f7e05ab	b3e7b1f6-d818-46bc-a98e-9f7048e16f8f	رفع اشکالات و بازبینی	176	28	2026-07-16	approved	b3e7b1f6-d818-46bc-a98e-9f7048e16f8f	\N	95bbfccf-8b88-411c-871d-682887f5485f	2026-07-20 09:22:03.794401+00	2026-07-20 09:22:03.794401+00
1d224113-52fd-42ec-a3d9-ee5e9338d4af	19688f35-cb03-41e0-9af7-6cc36f7e05ab	b3e7b1f6-d818-46bc-a98e-9f7048e16f8f	پیاده‌سازی بخش اصلی	222	66	2026-07-16	approved	b3e7b1f6-d818-46bc-a98e-9f7048e16f8f	\N	7ae83f06-b1b1-40d6-892a-3977b2d612de	2026-07-20 09:22:03.794401+00	2026-07-20 09:22:03.794401+00
1d224113-52fd-42ec-a3d9-ee5e9338d4af	19688f35-cb03-41e0-9af7-6cc36f7e05ab	b3e7b1f6-d818-46bc-a98e-9f7048e16f8f	رفع اشکالات و بازبینی	197	72	2026-07-16	approved	b3e7b1f6-d818-46bc-a98e-9f7048e16f8f	\N	e91a17e1-ac3b-4154-b9f8-ce1f48708923	2026-07-20 09:22:03.794401+00	2026-07-20 09:22:03.794401+00
1d224113-52fd-42ec-a3d9-ee5e9338d4af	5485692d-cb8b-4e71-99fd-d5bebe87286a	8a6bd071-9f82-4273-b101-9c763d6c4be4	رفع اشکالات و بازبینی	93	32	2026-07-16	approved	b3e7b1f6-d818-46bc-a98e-9f7048e16f8f	\N	adb97c53-29e7-4e61-8f2f-c0204e501155	2026-07-20 09:22:03.794401+00	2026-07-20 09:22:03.794401+00
1d224113-52fd-42ec-a3d9-ee5e9338d4af	5485692d-cb8b-4e71-99fd-d5bebe87286a	8a6bd071-9f82-4273-b101-9c763d6c4be4	رفع اشکالات و بازبینی	190	66	2026-07-16	approved	b3e7b1f6-d818-46bc-a98e-9f7048e16f8f	\N	a5948780-66e3-405d-a7fa-eaac772e83f6	2026-07-20 09:22:03.794401+00	2026-07-20 09:22:03.794401+00
1d224113-52fd-42ec-a3d9-ee5e9338d4af	d139c8a2-6d9b-4d4c-875c-835d7de13356	8cca3fcf-f7a7-421a-b9a4-5dab90fe1b83	پیشرفت اولیه و بررسی نیازمندی‌ها	133	36	2026-07-15	approved	b3e7b1f6-d818-46bc-a98e-9f7048e16f8f	\N	79f9d203-d654-4633-b500-605f1a031b41	2026-07-20 09:22:03.794401+00	2026-07-20 09:22:03.794401+00
1d224113-52fd-42ec-a3d9-ee5e9338d4af	d139c8a2-6d9b-4d4c-875c-835d7de13356	8cca3fcf-f7a7-421a-b9a4-5dab90fe1b83	رفع اشکالات و بازبینی	146	70	2026-07-16	approved	b3e7b1f6-d818-46bc-a98e-9f7048e16f8f	\N	84c9e629-5ac8-4100-b256-a607cc14a254	2026-07-20 09:22:03.794401+00	2026-07-20 09:22:03.794401+00
1d224113-52fd-42ec-a3d9-ee5e9338d4af	d139c8a2-6d9b-4d4c-875c-835d7de13356	8cca3fcf-f7a7-421a-b9a4-5dab90fe1b83	پیشرفت اولیه و بررسی نیازمندی‌ها	217	100	2026-07-16	approved	b3e7b1f6-d818-46bc-a98e-9f7048e16f8f	\N	dadba5ab-cd03-4312-a8e4-f3dbc40d9c3a	2026-07-20 09:22:03.794401+00	2026-07-20 09:22:03.794401+00
1d224113-52fd-42ec-a3d9-ee5e9338d4af	d139c8a2-6d9b-4d4c-875c-835d7de13356	8cca3fcf-f7a7-421a-b9a4-5dab90fe1b83	مستندسازی و نهایی‌سازی	131	100	2026-07-16	submitted	\N	\N	5c78db56-7d2b-46ed-9a74-68fc0e668acb	2026-07-20 09:22:03.794401+00	2026-07-20 09:22:03.794401+00
1d224113-52fd-42ec-a3d9-ee5e9338d4af	dd59d5df-3406-42b8-83b8-8cd9caea8164	1fd4dffb-d8db-4387-914a-be2a2a6fd6b1	رفع اشکالات و بازبینی	102	30	2026-06-28	approved	b3e7b1f6-d818-46bc-a98e-9f7048e16f8f	\N	2fb9b118-d630-4761-b553-e9ce76035e09	2026-07-20 09:22:03.794401+00	2026-07-20 09:22:03.794401+00
1d224113-52fd-42ec-a3d9-ee5e9338d4af	dd59d5df-3406-42b8-83b8-8cd9caea8164	1fd4dffb-d8db-4387-914a-be2a2a6fd6b1	تست و اطمینان از عملکرد صحیح	231	60	2026-06-30	approved	b3e7b1f6-d818-46bc-a98e-9f7048e16f8f	\N	f9562a9f-e075-4902-8b10-bf0d7156e66e	2026-07-20 09:22:03.794401+00	2026-07-20 09:22:03.794401+00
1d224113-52fd-42ec-a3d9-ee5e9338d4af	dd59d5df-3406-42b8-83b8-8cd9caea8164	1fd4dffb-d8db-4387-914a-be2a2a6fd6b1	تست و اطمینان از عملکرد صحیح	34	69	2026-06-30	approved	b3e7b1f6-d818-46bc-a98e-9f7048e16f8f	\N	0c2bd2d9-5eb6-44ac-b48b-3f7b808f93a1	2026-07-20 09:22:03.794401+00	2026-07-20 09:22:03.794401+00
1d224113-52fd-42ec-a3d9-ee5e9338d4af	dd59d5df-3406-42b8-83b8-8cd9caea8164	1fd4dffb-d8db-4387-914a-be2a2a6fd6b1	پیشرفت اولیه و بررسی نیازمندی‌ها	139	100	2026-07-04	approved	b3e7b1f6-d818-46bc-a98e-9f7048e16f8f	\N	2f8b901b-3a41-4d42-a329-5c3111acf12f	2026-07-20 09:22:03.794401+00	2026-07-20 09:22:03.794401+00
1d224113-52fd-42ec-a3d9-ee5e9338d4af	0130c4d3-3b88-4c57-b75c-24e1b191a666	1fd4dffb-d8db-4387-914a-be2a2a6fd6b1	پیاده‌سازی بخش اصلی	100	22	2026-06-24	approved	b3e7b1f6-d818-46bc-a98e-9f7048e16f8f	\N	5c20917a-7fd1-49e8-8e78-858e75d4d1df	2026-07-20 09:22:03.794401+00	2026-07-20 09:22:03.794401+00
1d224113-52fd-42ec-a3d9-ee5e9338d4af	0130c4d3-3b88-4c57-b75c-24e1b191a666	1fd4dffb-d8db-4387-914a-be2a2a6fd6b1	رفع اشکالات و بازبینی	51	62	2026-06-27	approved	b3e7b1f6-d818-46bc-a98e-9f7048e16f8f	\N	d5dfbad2-17dc-421b-ab88-6867e0636636	2026-07-20 09:22:03.794401+00	2026-07-20 09:22:03.794401+00
1d224113-52fd-42ec-a3d9-ee5e9338d4af	4bbac3b6-84c1-4c65-9c9c-3fb57db804fb	1fd4dffb-d8db-4387-914a-be2a2a6fd6b1	رفع اشکالات و بازبینی	215	27	2026-07-14	approved	b3e7b1f6-d818-46bc-a98e-9f7048e16f8f	\N	2b8e71f3-303e-4ec1-b4bb-8cb29ce55fc3	2026-07-20 09:22:03.794401+00	2026-07-20 09:22:03.794401+00
1d224113-52fd-42ec-a3d9-ee5e9338d4af	4bbac3b6-84c1-4c65-9c9c-3fb57db804fb	1fd4dffb-d8db-4387-914a-be2a2a6fd6b1	پیشرفت اولیه و بررسی نیازمندی‌ها	30	52	2026-07-16	approved	b3e7b1f6-d818-46bc-a98e-9f7048e16f8f	\N	efa9bffc-82e2-4dc8-b675-2c609ad55bf7	2026-07-20 09:22:03.794401+00	2026-07-20 09:22:03.794401+00
1d224113-52fd-42ec-a3d9-ee5e9338d4af	77f0157a-5583-4413-be3c-417168e86c76	b3e7b1f6-d818-46bc-a98e-9f7048e16f8f	پیاده‌سازی بخش اصلی	162	34	2026-07-16	approved	b3e7b1f6-d818-46bc-a98e-9f7048e16f8f	\N	696b1d1f-172d-433a-8f4c-6b3ad8670720	2026-07-20 09:22:03.794401+00	2026-07-20 09:22:03.794401+00
1d224113-52fd-42ec-a3d9-ee5e9338d4af	77f0157a-5583-4413-be3c-417168e86c76	b3e7b1f6-d818-46bc-a98e-9f7048e16f8f	رفع اشکالات و بازبینی	239	46	2026-07-16	approved	b3e7b1f6-d818-46bc-a98e-9f7048e16f8f	\N	9339aa4a-5f75-44ec-b8d2-7a2f5e4ed9b9	2026-07-20 09:22:03.794401+00	2026-07-20 09:22:03.794401+00
1d224113-52fd-42ec-a3d9-ee5e9338d4af	77f0157a-5583-4413-be3c-417168e86c76	b3e7b1f6-d818-46bc-a98e-9f7048e16f8f	تست و اطمینان از عملکرد صحیح	48	81	2026-07-16	approved	b3e7b1f6-d818-46bc-a98e-9f7048e16f8f	\N	e8ecf421-245b-45a4-8c35-c5756ea8e8c2	2026-07-20 09:22:03.794401+00	2026-07-20 09:22:03.794401+00
1d224113-52fd-42ec-a3d9-ee5e9338d4af	77f0157a-5583-4413-be3c-417168e86c76	b3e7b1f6-d818-46bc-a98e-9f7048e16f8f	پیشرفت اولیه و بررسی نیازمندی‌ها	56	100	2026-07-16	approved	b3e7b1f6-d818-46bc-a98e-9f7048e16f8f	\N	3eea86db-0383-45e1-8724-290881ea601b	2026-07-20 09:22:03.794401+00	2026-07-20 09:22:03.794401+00
1d224113-52fd-42ec-a3d9-ee5e9338d4af	eb43a464-6a40-4c62-be89-3437e098d61c	1fd4dffb-d8db-4387-914a-be2a2a6fd6b1	پیاده‌سازی بخش اصلی	194	24	2026-06-26	approved	b3e7b1f6-d818-46bc-a98e-9f7048e16f8f	\N	a997e252-1a2e-42b1-b02f-3ed3cac964b5	2026-07-20 09:22:03.794401+00	2026-07-20 09:22:03.794401+00
1d224113-52fd-42ec-a3d9-ee5e9338d4af	eb43a464-6a40-4c62-be89-3437e098d61c	1fd4dffb-d8db-4387-914a-be2a2a6fd6b1	پیشرفت اولیه و بررسی نیازمندی‌ها	186	80	2026-06-27	approved	b3e7b1f6-d818-46bc-a98e-9f7048e16f8f	\N	c21a9e32-52ce-4e77-aa42-dbfe1d86fd72	2026-07-20 09:22:03.794401+00	2026-07-20 09:22:03.794401+00
1d224113-52fd-42ec-a3d9-ee5e9338d4af	eb43a464-6a40-4c62-be89-3437e098d61c	1fd4dffb-d8db-4387-914a-be2a2a6fd6b1	پیاده‌سازی بخش اصلی	190	72	2026-06-30	approved	b3e7b1f6-d818-46bc-a98e-9f7048e16f8f	\N	a30f7d60-308c-4f20-a2f5-90c2a83ccef7	2026-07-20 09:22:03.794401+00	2026-07-20 09:22:03.794401+00
1d224113-52fd-42ec-a3d9-ee5e9338d4af	b9a62bf1-a9be-4f68-bd18-04ab098bc10c	8a6bd071-9f82-4273-b101-9c763d6c4be4	پیشرفت اولیه و بررسی نیازمندی‌ها	55	24	2026-07-09	submitted	\N	\N	1f59b0ab-67b8-4d2c-87df-5ad38e4d2811	2026-07-20 09:22:03.794401+00	2026-07-20 09:22:03.794401+00
1d224113-52fd-42ec-a3d9-ee5e9338d4af	b9a62bf1-a9be-4f68-bd18-04ab098bc10c	8a6bd071-9f82-4273-b101-9c763d6c4be4	تست و اطمینان از عملکرد صحیح	119	66	2026-07-10	approved	b3e7b1f6-d818-46bc-a98e-9f7048e16f8f	\N	ea441cb0-0b74-4486-b1b9-86ce5086692d	2026-07-20 09:22:03.794401+00	2026-07-20 09:22:03.794401+00
1d224113-52fd-42ec-a3d9-ee5e9338d4af	b9a62bf1-a9be-4f68-bd18-04ab098bc10c	8a6bd071-9f82-4273-b101-9c763d6c4be4	پیاده‌سازی بخش اصلی	100	100	2026-07-15	submitted	\N	\N	b2454e8d-eeb0-4c47-8207-8ba5f0b8f7ce	2026-07-20 09:22:03.794401+00	2026-07-20 09:22:03.794401+00
1d224113-52fd-42ec-a3d9-ee5e9338d4af	b9a62bf1-a9be-4f68-bd18-04ab098bc10c	8a6bd071-9f82-4273-b101-9c763d6c4be4	مستندسازی و نهایی‌سازی	183	100	2026-07-12	approved	b3e7b1f6-d818-46bc-a98e-9f7048e16f8f	\N	a76eb888-ef69-4faa-859d-38c06cbc5e8a	2026-07-20 09:22:03.794401+00	2026-07-20 09:22:03.794401+00
1d224113-52fd-42ec-a3d9-ee5e9338d4af	7268f9b7-e133-408c-aaac-6a437f9f5635	1fd4dffb-d8db-4387-914a-be2a2a6fd6b1	رفع اشکالات و بازبینی	82	36	2026-07-16	approved	b3e7b1f6-d818-46bc-a98e-9f7048e16f8f	\N	25ace6c1-e930-4580-9fa7-1ab244d0d5be	2026-07-20 09:22:03.794401+00	2026-07-20 09:22:03.794401+00
1d224113-52fd-42ec-a3d9-ee5e9338d4af	7268f9b7-e133-408c-aaac-6a437f9f5635	1fd4dffb-d8db-4387-914a-be2a2a6fd6b1	تست و اطمینان از عملکرد صحیح	105	80	2026-07-16	approved	b3e7b1f6-d818-46bc-a98e-9f7048e16f8f	\N	6d8e48f3-7d9a-47bd-b343-d5ad589963db	2026-07-20 09:22:03.794401+00	2026-07-20 09:22:03.794401+00
1d224113-52fd-42ec-a3d9-ee5e9338d4af	7268f9b7-e133-408c-aaac-6a437f9f5635	1fd4dffb-d8db-4387-914a-be2a2a6fd6b1	پیاده‌سازی بخش اصلی	156	96	2026-07-16	approved	b3e7b1f6-d818-46bc-a98e-9f7048e16f8f	\N	7350a647-19d5-4954-847a-44f602bf03ac	2026-07-20 09:22:03.794401+00	2026-07-20 09:22:03.794401+00
1d224113-52fd-42ec-a3d9-ee5e9338d4af	baae3f31-78b2-49b6-b632-aa68105f87bc	03c131a9-29b0-4e66-8d67-be78cfa01885	تست و اطمینان از عملکرد صحیح	193	39	2026-07-16	approved	b3e7b1f6-d818-46bc-a98e-9f7048e16f8f	\N	f1db7f3b-6bc8-4763-acdd-64ac105ff73a	2026-07-20 09:22:03.794401+00	2026-07-20 09:22:03.794401+00
1d224113-52fd-42ec-a3d9-ee5e9338d4af	8f12587c-aba3-48cc-80fe-c92bf1030387	1fd4dffb-d8db-4387-914a-be2a2a6fd6b1	رفع اشکالات و بازبینی	111	24	2026-07-16	approved	b3e7b1f6-d818-46bc-a98e-9f7048e16f8f	\N	36e405dd-e3b2-4c33-a473-9cee93193d24	2026-07-20 09:22:03.794401+00	2026-07-20 09:22:03.794401+00
1d224113-52fd-42ec-a3d9-ee5e9338d4af	0bf88304-610a-41f1-a215-54b1ecae8ebd	1fd4dffb-d8db-4387-914a-be2a2a6fd6b1	پیاده‌سازی بخش اصلی	225	35	2026-07-16	approved	b3e7b1f6-d818-46bc-a98e-9f7048e16f8f	\N	96dc3881-6dc3-4a7b-b493-757df377c4d4	2026-07-20 09:22:03.794401+00	2026-07-20 09:22:03.794401+00
1d224113-52fd-42ec-a3d9-ee5e9338d4af	0bf88304-610a-41f1-a215-54b1ecae8ebd	1fd4dffb-d8db-4387-914a-be2a2a6fd6b1	پیشرفت اولیه و بررسی نیازمندی‌ها	33	56	2026-07-16	approved	b3e7b1f6-d818-46bc-a98e-9f7048e16f8f	\N	7501a9b7-c831-4bbf-8392-c7cf0c86d991	2026-07-20 09:22:03.794401+00	2026-07-20 09:22:03.794401+00
1d224113-52fd-42ec-a3d9-ee5e9338d4af	0bf88304-610a-41f1-a215-54b1ecae8ebd	1fd4dffb-d8db-4387-914a-be2a2a6fd6b1	پیشرفت اولیه و بررسی نیازمندی‌ها	232	96	2026-07-16	approved	b3e7b1f6-d818-46bc-a98e-9f7048e16f8f	\N	b42a970e-c5ac-477b-9f1d-9c15b86d7d95	2026-07-20 09:22:03.794401+00	2026-07-20 09:22:03.794401+00
1d224113-52fd-42ec-a3d9-ee5e9338d4af	0bf88304-610a-41f1-a215-54b1ecae8ebd	1fd4dffb-d8db-4387-914a-be2a2a6fd6b1	مستندسازی و نهایی‌سازی	226	100	2026-07-16	approved	b3e7b1f6-d818-46bc-a98e-9f7048e16f8f	\N	0a9bd6c7-dc7d-41ca-8d7f-53e1f2f25ced	2026-07-20 09:22:03.794401+00	2026-07-20 09:22:03.794401+00
1d224113-52fd-42ec-a3d9-ee5e9338d4af	46ca34a6-c24a-4404-9242-43011128664b	1fd4dffb-d8db-4387-914a-be2a2a6fd6b1	مستندسازی و نهایی‌سازی	167	39	2026-07-16	approved	b3e7b1f6-d818-46bc-a98e-9f7048e16f8f	\N	66f6c0fc-b163-4a31-add0-4694ac11c0a1	2026-07-20 09:22:03.794401+00	2026-07-20 09:22:03.794401+00
1d224113-52fd-42ec-a3d9-ee5e9338d4af	46ca34a6-c24a-4404-9242-43011128664b	1fd4dffb-d8db-4387-914a-be2a2a6fd6b1	رفع اشکالات و بازبینی	50	72	2026-07-16	approved	b3e7b1f6-d818-46bc-a98e-9f7048e16f8f	\N	caa335d1-7183-4d51-94b2-2f25c1b6c91e	2026-07-20 09:22:03.794401+00	2026-07-20 09:22:03.794401+00
1d224113-52fd-42ec-a3d9-ee5e9338d4af	46ca34a6-c24a-4404-9242-43011128664b	1fd4dffb-d8db-4387-914a-be2a2a6fd6b1	پیاده‌سازی بخش اصلی	167	90	2026-07-16	submitted	\N	\N	9dfdaa0a-1793-4157-a9a2-91e1cc96277d	2026-07-20 09:22:03.794401+00	2026-07-20 09:22:03.794401+00
1d224113-52fd-42ec-a3d9-ee5e9338d4af	46ca34a6-c24a-4404-9242-43011128664b	1fd4dffb-d8db-4387-914a-be2a2a6fd6b1	پیشرفت اولیه و بررسی نیازمندی‌ها	109	100	2026-07-16	approved	b3e7b1f6-d818-46bc-a98e-9f7048e16f8f	\N	b647b9ee-1d06-4c19-9987-34aa0837a77c	2026-07-20 09:22:03.794401+00	2026-07-20 09:22:03.794401+00
1d224113-52fd-42ec-a3d9-ee5e9338d4af	0d0b120f-2c5c-4449-b057-5a4ab6d3e6d5	1fd4dffb-d8db-4387-914a-be2a2a6fd6b1	پیاده‌سازی بخش اصلی	52	33	2026-07-16	approved	b3e7b1f6-d818-46bc-a98e-9f7048e16f8f	\N	b53537e0-ec69-4abe-b9b2-d64b5a2a6cf9	2026-07-20 09:22:03.794401+00	2026-07-20 09:22:03.794401+00
1d224113-52fd-42ec-a3d9-ee5e9338d4af	0d0b120f-2c5c-4449-b057-5a4ab6d3e6d5	1fd4dffb-d8db-4387-914a-be2a2a6fd6b1	تست و اطمینان از عملکرد صحیح	186	78	2026-07-16	approved	b3e7b1f6-d818-46bc-a98e-9f7048e16f8f	\N	3c218400-1720-466b-9e1a-802bde0a586f	2026-07-20 09:22:03.794401+00	2026-07-20 09:22:03.794401+00
1d224113-52fd-42ec-a3d9-ee5e9338d4af	b6f75765-69da-4dbb-b541-e2e3d1cd0841	8a6bd071-9f82-4273-b101-9c763d6c4be4	پیاده‌سازی بخش اصلی	60	20	2026-07-16	approved	b3e7b1f6-d818-46bc-a98e-9f7048e16f8f	\N	78725ab5-f0e9-44c4-858c-b749e41ebed3	2026-07-20 09:22:03.794401+00	2026-07-20 09:22:03.794401+00
1d224113-52fd-42ec-a3d9-ee5e9338d4af	6a3f03a0-a072-48cb-a961-a1484f9c4fdf	1fd4dffb-d8db-4387-914a-be2a2a6fd6b1	پیاده‌سازی بخش اصلی	157	31	2026-06-30	approved	b3e7b1f6-d818-46bc-a98e-9f7048e16f8f	\N	a2171582-0bda-4274-8629-b45953ee1228	2026-07-20 09:22:03.794401+00	2026-07-20 09:22:03.794401+00
1d224113-52fd-42ec-a3d9-ee5e9338d4af	6a3f03a0-a072-48cb-a961-a1484f9c4fdf	1fd4dffb-d8db-4387-914a-be2a2a6fd6b1	پیاده‌سازی بخش اصلی	125	48	2026-07-03	approved	b3e7b1f6-d818-46bc-a98e-9f7048e16f8f	\N	5e2846d1-c221-4344-90c4-8f5e54570bd0	2026-07-20 09:22:03.794401+00	2026-07-20 09:22:03.794401+00
1d224113-52fd-42ec-a3d9-ee5e9338d4af	b5258bba-fa1f-4527-aa6a-07229b75073b	1fd4dffb-d8db-4387-914a-be2a2a6fd6b1	پیشرفت اولیه و بررسی نیازمندی‌ها	115	33	2026-07-13	approved	b3e7b1f6-d818-46bc-a98e-9f7048e16f8f	\N	314121f6-7d95-4add-bc86-523696a33b09	2026-07-20 09:22:03.794401+00	2026-07-20 09:22:03.794401+00
1d224113-52fd-42ec-a3d9-ee5e9338d4af	b5258bba-fa1f-4527-aa6a-07229b75073b	1fd4dffb-d8db-4387-914a-be2a2a6fd6b1	مستندسازی و نهایی‌سازی	46	56	2026-07-16	approved	b3e7b1f6-d818-46bc-a98e-9f7048e16f8f	\N	6b5a5c78-753c-49d2-8862-3755c3f78340	2026-07-20 09:22:03.794401+00	2026-07-20 09:22:03.794401+00
1d224113-52fd-42ec-a3d9-ee5e9338d4af	b5258bba-fa1f-4527-aa6a-07229b75073b	1fd4dffb-d8db-4387-914a-be2a2a6fd6b1	تست و اطمینان از عملکرد صحیح	146	100	2026-07-15	approved	b3e7b1f6-d818-46bc-a98e-9f7048e16f8f	\N	ecdd15b2-4e6a-491a-86f1-462316dab655	2026-07-20 09:22:03.794401+00	2026-07-20 09:22:03.794401+00
1d224113-52fd-42ec-a3d9-ee5e9338d4af	e4c6e7c1-42e3-4ed6-8e62-788b0ba3683d	8a6bd071-9f82-4273-b101-9c763d6c4be4	مستندسازی و نهایی‌سازی	72	31	2026-07-16	approved	b3e7b1f6-d818-46bc-a98e-9f7048e16f8f	\N	28adcfa5-a8b4-43e4-b03f-52f93741ba4d	2026-07-20 09:22:03.794401+00	2026-07-20 09:22:03.794401+00
1d224113-52fd-42ec-a3d9-ee5e9338d4af	e4c6e7c1-42e3-4ed6-8e62-788b0ba3683d	8a6bd071-9f82-4273-b101-9c763d6c4be4	پیشرفت اولیه و بررسی نیازمندی‌ها	176	46	2026-07-16	approved	b3e7b1f6-d818-46bc-a98e-9f7048e16f8f	\N	9ea686da-5847-41d5-9787-581c15e39de9	2026-07-20 09:22:03.794401+00	2026-07-20 09:22:03.794401+00
1d224113-52fd-42ec-a3d9-ee5e9338d4af	e4c6e7c1-42e3-4ed6-8e62-788b0ba3683d	8a6bd071-9f82-4273-b101-9c763d6c4be4	پیشرفت اولیه و بررسی نیازمندی‌ها	41	60	2026-07-16	submitted	\N	\N	3ac4254c-002f-4d52-a4d0-a9dc0d61d09f	2026-07-20 09:22:03.794401+00	2026-07-20 09:22:03.794401+00
1d224113-52fd-42ec-a3d9-ee5e9338d4af	4ba10d86-4545-4a0f-9124-f84207c1178a	b3e7b1f6-d818-46bc-a98e-9f7048e16f8f	تست و اطمینان از عملکرد صحیح	123	32	2026-07-16	approved	b3e7b1f6-d818-46bc-a98e-9f7048e16f8f	\N	b6c6a81f-dd55-45a0-862b-6ab9026804b4	2026-07-20 09:22:03.794401+00	2026-07-20 09:22:03.794401+00
1d224113-52fd-42ec-a3d9-ee5e9338d4af	4ba10d86-4545-4a0f-9124-f84207c1178a	b3e7b1f6-d818-46bc-a98e-9f7048e16f8f	پیاده‌سازی بخش اصلی	39	74	2026-07-16	approved	b3e7b1f6-d818-46bc-a98e-9f7048e16f8f	\N	1b4d8f02-f0fd-4008-8e67-458dca5196b5	2026-07-20 09:22:03.794401+00	2026-07-20 09:22:03.794401+00
1d224113-52fd-42ec-a3d9-ee5e9338d4af	6bb0e8c9-4a4f-4acf-98c8-75aec82cb87b	1fd4dffb-d8db-4387-914a-be2a2a6fd6b1	تست و اطمینان از عملکرد صحیح	214	30	2026-07-16	approved	b3e7b1f6-d818-46bc-a98e-9f7048e16f8f	\N	d72c8912-8609-40ce-a712-2306bc164ce2	2026-07-20 09:22:03.794401+00	2026-07-20 09:22:03.794401+00
1d224113-52fd-42ec-a3d9-ee5e9338d4af	6bb0e8c9-4a4f-4acf-98c8-75aec82cb87b	1fd4dffb-d8db-4387-914a-be2a2a6fd6b1	مستندسازی و نهایی‌سازی	125	46	2026-07-16	submitted	\N	\N	f7a47b82-1afc-4da4-bb6e-02b7c27f6954	2026-07-20 09:22:03.794401+00	2026-07-20 09:22:03.794401+00
1d224113-52fd-42ec-a3d9-ee5e9338d4af	6bb0e8c9-4a4f-4acf-98c8-75aec82cb87b	1fd4dffb-d8db-4387-914a-be2a2a6fd6b1	مستندسازی و نهایی‌سازی	41	96	2026-07-16	approved	b3e7b1f6-d818-46bc-a98e-9f7048e16f8f	\N	9aebb196-39d4-4fc5-9dc5-b28320aa3814	2026-07-20 09:22:03.794401+00	2026-07-20 09:22:03.794401+00
1d224113-52fd-42ec-a3d9-ee5e9338d4af	6bb0e8c9-4a4f-4acf-98c8-75aec82cb87b	1fd4dffb-d8db-4387-914a-be2a2a6fd6b1	رفع اشکالات و بازبینی	228	100	2026-07-16	submitted	\N	\N	591ead6b-fa8c-457d-8715-306ae74fb026	2026-07-20 09:22:03.794401+00	2026-07-20 09:22:03.794401+00
1d224113-52fd-42ec-a3d9-ee5e9338d4af	c4e7efbb-8c1e-40e1-be8b-02af0ac7cda6	8cca3fcf-f7a7-421a-b9a4-5dab90fe1b83	پیشرفت اولیه و بررسی نیازمندی‌ها	124	26	2026-07-16	approved	b3e7b1f6-d818-46bc-a98e-9f7048e16f8f	\N	808a1796-ec4a-4174-b0f0-ae1b2ae96f96	2026-07-20 09:22:03.794401+00	2026-07-20 09:22:03.794401+00
1d224113-52fd-42ec-a3d9-ee5e9338d4af	c4e7efbb-8c1e-40e1-be8b-02af0ac7cda6	8cca3fcf-f7a7-421a-b9a4-5dab90fe1b83	رفع اشکالات و بازبینی	219	78	2026-07-16	approved	b3e7b1f6-d818-46bc-a98e-9f7048e16f8f	\N	dcb4c060-d711-4657-9c17-c8847a2882da	2026-07-20 09:22:03.794401+00	2026-07-20 09:22:03.794401+00
1d224113-52fd-42ec-a3d9-ee5e9338d4af	c4e7efbb-8c1e-40e1-be8b-02af0ac7cda6	8cca3fcf-f7a7-421a-b9a4-5dab90fe1b83	مستندسازی و نهایی‌سازی	156	78	2026-07-16	approved	b3e7b1f6-d818-46bc-a98e-9f7048e16f8f	\N	3b164daf-d9aa-42d6-b221-18db0e5c1611	2026-07-20 09:22:03.794401+00	2026-07-20 09:22:03.794401+00
1d224113-52fd-42ec-a3d9-ee5e9338d4af	73f34106-afbb-4e61-a946-70e5d0fa49e5	03c131a9-29b0-4e66-8d67-be78cfa01885	تست و اطمینان از عملکرد صحیح	36	27	2026-07-01	approved	b3e7b1f6-d818-46bc-a98e-9f7048e16f8f	\N	6d714406-eeda-470e-992f-b35d81099132	2026-07-20 09:22:03.794401+00	2026-07-20 09:22:03.794401+00
1d224113-52fd-42ec-a3d9-ee5e9338d4af	73f34106-afbb-4e61-a946-70e5d0fa49e5	03c131a9-29b0-4e66-8d67-be78cfa01885	پیشرفت اولیه و بررسی نیازمندی‌ها	115	40	2026-07-04	approved	b3e7b1f6-d818-46bc-a98e-9f7048e16f8f	\N	f59c567b-18d6-483e-966d-db33e17f4d2f	2026-07-20 09:22:03.794401+00	2026-07-20 09:22:03.794401+00
1d224113-52fd-42ec-a3d9-ee5e9338d4af	f795fd57-3e97-454c-b3b5-c5d47d26c380	8cca3fcf-f7a7-421a-b9a4-5dab90fe1b83	مستندسازی و نهایی‌سازی	90	33	2026-06-19	approved	b3e7b1f6-d818-46bc-a98e-9f7048e16f8f	\N	45af3502-7035-4e3d-bc82-e2896354d43d	2026-07-20 09:22:03.794401+00	2026-07-20 09:22:03.794401+00
1d224113-52fd-42ec-a3d9-ee5e9338d4af	f795fd57-3e97-454c-b3b5-c5d47d26c380	8cca3fcf-f7a7-421a-b9a4-5dab90fe1b83	پیاده‌سازی بخش اصلی	212	56	2026-06-23	submitted	\N	\N	18e93dc8-0fa1-49e8-b77e-e4e398a60d1e	2026-07-20 09:22:03.794401+00	2026-07-20 09:22:03.794401+00
1d224113-52fd-42ec-a3d9-ee5e9338d4af	f795fd57-3e97-454c-b3b5-c5d47d26c380	8cca3fcf-f7a7-421a-b9a4-5dab90fe1b83	پیاده‌سازی بخش اصلی	163	99	2026-06-21	approved	b3e7b1f6-d818-46bc-a98e-9f7048e16f8f	\N	12a84c47-816e-49e1-b587-814dba965251	2026-07-20 09:22:03.794401+00	2026-07-20 09:22:03.794401+00
1d224113-52fd-42ec-a3d9-ee5e9338d4af	f795fd57-3e97-454c-b3b5-c5d47d26c380	8cca3fcf-f7a7-421a-b9a4-5dab90fe1b83	پیشرفت اولیه و بررسی نیازمندی‌ها	178	92	2026-06-28	approved	b3e7b1f6-d818-46bc-a98e-9f7048e16f8f	\N	08ad2fe0-41ee-4604-8d87-f8cb830a8ef5	2026-07-20 09:22:03.794401+00	2026-07-20 09:22:03.794401+00
1d224113-52fd-42ec-a3d9-ee5e9338d4af	11325dfa-9c91-4ed0-a0b3-17d345346d30	1fd4dffb-d8db-4387-914a-be2a2a6fd6b1	پیشرفت اولیه و بررسی نیازمندی‌ها	181	38	2026-07-08	approved	b3e7b1f6-d818-46bc-a98e-9f7048e16f8f	\N	bee4701e-f80a-4656-834c-426d19da4784	2026-07-20 09:22:03.794401+00	2026-07-20 09:22:03.794401+00
1d224113-52fd-42ec-a3d9-ee5e9338d4af	11325dfa-9c91-4ed0-a0b3-17d345346d30	1fd4dffb-d8db-4387-914a-be2a2a6fd6b1	تست و اطمینان از عملکرد صحیح	199	48	2026-07-09	approved	b3e7b1f6-d818-46bc-a98e-9f7048e16f8f	\N	2ca780f0-17d2-42a7-857c-d1fb173b6d50	2026-07-20 09:22:03.794401+00	2026-07-20 09:22:03.794401+00
1d224113-52fd-42ec-a3d9-ee5e9338d4af	ea198778-638c-4f51-a9be-a043e8eeb661	1fd4dffb-d8db-4387-914a-be2a2a6fd6b1	رفع اشکالات و بازبینی	235	32	2026-06-25	approved	b3e7b1f6-d818-46bc-a98e-9f7048e16f8f	\N	2dd1d7d4-3a72-425f-80fd-fe7bf7908221	2026-07-20 09:22:03.794401+00	2026-07-20 09:22:03.794401+00
1d224113-52fd-42ec-a3d9-ee5e9338d4af	ea198778-638c-4f51-a9be-a043e8eeb661	1fd4dffb-d8db-4387-914a-be2a2a6fd6b1	رفع اشکالات و بازبینی	89	44	2026-06-28	approved	b3e7b1f6-d818-46bc-a98e-9f7048e16f8f	\N	7eb1cd35-87f9-4fee-8c23-07a1f07ebefb	2026-07-20 09:22:03.794401+00	2026-07-20 09:22:03.794401+00
1d224113-52fd-42ec-a3d9-ee5e9338d4af	d20b6d7a-0603-4fac-ab05-775bd149f013	03c131a9-29b0-4e66-8d67-be78cfa01885	مستندسازی و نهایی‌سازی	57	24	2026-07-05	submitted	\N	\N	09b585d7-48db-4ca3-a0a8-fc3cb18851bb	2026-07-20 09:22:03.794401+00	2026-07-20 09:22:03.794401+00
1d224113-52fd-42ec-a3d9-ee5e9338d4af	d20b6d7a-0603-4fac-ab05-775bd149f013	03c131a9-29b0-4e66-8d67-be78cfa01885	تست و اطمینان از عملکرد صحیح	110	66	2026-07-06	approved	b3e7b1f6-d818-46bc-a98e-9f7048e16f8f	\N	fdc4d62e-d33e-450f-8ebf-98652a160f0b	2026-07-20 09:22:03.794401+00	2026-07-20 09:22:03.794401+00
1d224113-52fd-42ec-a3d9-ee5e9338d4af	59107e6c-d1ae-48ef-9db3-5f1596fb0c87	1fd4dffb-d8db-4387-914a-be2a2a6fd6b1	پیاده‌سازی بخش اصلی	145	29	2026-07-10	approved	b3e7b1f6-d818-46bc-a98e-9f7048e16f8f	\N	4e0fe9ca-3961-48ee-bc3d-88a5c6f4ca0a	2026-07-20 09:22:03.794401+00	2026-07-20 09:22:03.794401+00
1d224113-52fd-42ec-a3d9-ee5e9338d4af	56325046-44fa-4e2b-87da-d5f1cc91d591	b3e7b1f6-d818-46bc-a98e-9f7048e16f8f	پیشرفت اولیه و بررسی نیازمندی‌ها	53	25	2026-06-21	approved	b3e7b1f6-d818-46bc-a98e-9f7048e16f8f	\N	2a844a25-67bd-4d11-9d30-6fcc815daf0f	2026-07-20 09:22:03.794401+00	2026-07-20 09:22:03.794401+00
1d224113-52fd-42ec-a3d9-ee5e9338d4af	56325046-44fa-4e2b-87da-d5f1cc91d591	b3e7b1f6-d818-46bc-a98e-9f7048e16f8f	مستندسازی و نهایی‌سازی	40	52	2026-06-24	approved	b3e7b1f6-d818-46bc-a98e-9f7048e16f8f	\N	2ad012ee-5e26-498a-91a5-da147966ec4a	2026-07-20 09:22:03.794401+00	2026-07-20 09:22:03.794401+00
1d224113-52fd-42ec-a3d9-ee5e9338d4af	56325046-44fa-4e2b-87da-d5f1cc91d591	b3e7b1f6-d818-46bc-a98e-9f7048e16f8f	پیاده‌سازی بخش اصلی	53	81	2026-06-27	approved	b3e7b1f6-d818-46bc-a98e-9f7048e16f8f	\N	924644ad-6cf7-461e-b2ad-6893caa98f8f	2026-07-20 09:22:03.794401+00	2026-07-20 09:22:03.794401+00
1d224113-52fd-42ec-a3d9-ee5e9338d4af	56325046-44fa-4e2b-87da-d5f1cc91d591	b3e7b1f6-d818-46bc-a98e-9f7048e16f8f	تست و اطمینان از عملکرد صحیح	161	84	2026-06-30	approved	b3e7b1f6-d818-46bc-a98e-9f7048e16f8f	\N	130829b0-a85c-4642-8d92-618551033215	2026-07-20 09:22:03.794401+00	2026-07-20 09:22:03.794401+00
1d224113-52fd-42ec-a3d9-ee5e9338d4af	bf169b5a-1754-4ab0-9dac-4918366a3573	1fd4dffb-d8db-4387-914a-be2a2a6fd6b1	پیاده‌سازی بخش اصلی	37	32	2026-06-18	approved	b3e7b1f6-d818-46bc-a98e-9f7048e16f8f	\N	845cdb2c-a1ec-4e07-991e-604e79ff2ad9	2026-07-20 09:22:03.794401+00	2026-07-20 09:22:03.794401+00
1d224113-52fd-42ec-a3d9-ee5e9338d4af	bf169b5a-1754-4ab0-9dac-4918366a3573	1fd4dffb-d8db-4387-914a-be2a2a6fd6b1	مستندسازی و نهایی‌سازی	221	74	2026-06-22	approved	b3e7b1f6-d818-46bc-a98e-9f7048e16f8f	\N	3472b7dc-ca10-40dc-8b8f-82e49498724a	2026-07-20 09:22:03.794401+00	2026-07-20 09:22:03.794401+00
1d224113-52fd-42ec-a3d9-ee5e9338d4af	bf169b5a-1754-4ab0-9dac-4918366a3573	1fd4dffb-d8db-4387-914a-be2a2a6fd6b1	پیشرفت اولیه و بررسی نیازمندی‌ها	148	69	2026-06-22	approved	b3e7b1f6-d818-46bc-a98e-9f7048e16f8f	\N	4d68e01e-1a2a-492b-a9c8-6305818e8e4f	2026-07-20 09:22:03.794401+00	2026-07-20 09:22:03.794401+00
1d224113-52fd-42ec-a3d9-ee5e9338d4af	75c8091a-8a9c-44bf-802a-6dfcd351fb10	b720465e-b31b-4b9b-99d6-b303ca5f639d	پیاده‌سازی بخش اصلی	63	26	2026-07-16	approved	b3e7b1f6-d818-46bc-a98e-9f7048e16f8f	\N	2017e533-86fb-4485-90f8-1c20119ac64e	2026-07-20 09:22:03.794401+00	2026-07-20 09:22:03.794401+00
1d224113-52fd-42ec-a3d9-ee5e9338d4af	75c8091a-8a9c-44bf-802a-6dfcd351fb10	b720465e-b31b-4b9b-99d6-b303ca5f639d	پیشرفت اولیه و بررسی نیازمندی‌ها	179	76	2026-07-16	approved	b3e7b1f6-d818-46bc-a98e-9f7048e16f8f	\N	2deb9c65-3244-4966-bbed-036bd1a2dfba	2026-07-20 09:22:03.794401+00	2026-07-20 09:22:03.794401+00
1d224113-52fd-42ec-a3d9-ee5e9338d4af	4503c816-147f-4892-9c61-7bc84c097a23	7891652b-f708-4834-90b3-b7e06f9dd5ab	پیاده‌سازی بخش اصلی	114	28	2026-07-16	approved	7891652b-f708-4834-90b3-b7e06f9dd5ab	\N	a3c2da34-e312-4169-a043-7bb42f77b192	2026-07-20 09:22:03.794401+00	2026-07-20 09:22:03.794401+00
1d224113-52fd-42ec-a3d9-ee5e9338d4af	4503c816-147f-4892-9c61-7bc84c097a23	7891652b-f708-4834-90b3-b7e06f9dd5ab	مستندسازی و نهایی‌سازی	87	74	2026-07-16	approved	7891652b-f708-4834-90b3-b7e06f9dd5ab	\N	8c8d9371-7dd6-4362-a6dd-cb109c80601d	2026-07-20 09:22:03.794401+00	2026-07-20 09:22:03.794401+00
1d224113-52fd-42ec-a3d9-ee5e9338d4af	4503c816-147f-4892-9c61-7bc84c097a23	7891652b-f708-4834-90b3-b7e06f9dd5ab	تست و اطمینان از عملکرد صحیح	239	81	2026-07-16	approved	7891652b-f708-4834-90b3-b7e06f9dd5ab	\N	d921a62c-7718-4222-a7a4-a1e45382cb28	2026-07-20 09:22:03.794401+00	2026-07-20 09:22:03.794401+00
1d224113-52fd-42ec-a3d9-ee5e9338d4af	4503c816-147f-4892-9c61-7bc84c097a23	7891652b-f708-4834-90b3-b7e06f9dd5ab	تست و اطمینان از عملکرد صحیح	143	100	2026-07-16	approved	7891652b-f708-4834-90b3-b7e06f9dd5ab	\N	a594ff42-0478-4a44-b8af-a0ae8ef6bc91	2026-07-20 09:22:03.794401+00	2026-07-20 09:22:03.794401+00
1d224113-52fd-42ec-a3d9-ee5e9338d4af	287bba2f-f8f0-48dc-86cf-27b7ce5519cc	726b1bd0-c51d-4f38-9e37-f4c46a258d1b	تست و اطمینان از عملکرد صحیح	144	30	2026-06-27	approved	7891652b-f708-4834-90b3-b7e06f9dd5ab	\N	34df52e6-2118-41ad-b1fa-b0d5058652f4	2026-07-20 09:22:03.794401+00	2026-07-20 09:22:03.794401+00
1d224113-52fd-42ec-a3d9-ee5e9338d4af	287bba2f-f8f0-48dc-86cf-27b7ce5519cc	726b1bd0-c51d-4f38-9e37-f4c46a258d1b	تست و اطمینان از عملکرد صحیح	220	80	2026-06-28	approved	7891652b-f708-4834-90b3-b7e06f9dd5ab	\N	874b0cf6-98fa-4285-b18c-da364c2913b1	2026-07-20 09:22:03.794401+00	2026-07-20 09:22:03.794401+00
1d224113-52fd-42ec-a3d9-ee5e9338d4af	287bba2f-f8f0-48dc-86cf-27b7ce5519cc	726b1bd0-c51d-4f38-9e37-f4c46a258d1b	پیشرفت اولیه و بررسی نیازمندی‌ها	133	99	2026-06-29	approved	7891652b-f708-4834-90b3-b7e06f9dd5ab	\N	4f21b5b8-e840-456b-b1bc-f8d300de6d55	2026-07-20 09:22:03.794401+00	2026-07-20 09:22:03.794401+00
1d224113-52fd-42ec-a3d9-ee5e9338d4af	287bba2f-f8f0-48dc-86cf-27b7ce5519cc	726b1bd0-c51d-4f38-9e37-f4c46a258d1b	مستندسازی و نهایی‌سازی	170	80	2026-06-30	approved	7891652b-f708-4834-90b3-b7e06f9dd5ab	\N	c0ef2051-b990-46db-be0f-b4c5bfb8d23d	2026-07-20 09:22:03.794401+00	2026-07-20 09:22:03.794401+00
1d224113-52fd-42ec-a3d9-ee5e9338d4af	641e9bf0-459c-4c9b-832c-f9f25aa5fd28	fc439dd8-ff4f-4760-bcc2-e3cddcba6888	مستندسازی و نهایی‌سازی	82	40	2026-06-17	submitted	\N	\N	96e3db1a-83d1-4636-a852-f78d5751bb8d	2026-07-20 09:22:03.794401+00	2026-07-20 09:22:03.794401+00
1d224113-52fd-42ec-a3d9-ee5e9338d4af	708e2273-f30d-40b7-9118-3ba6a26bc8d6	fc439dd8-ff4f-4760-bcc2-e3cddcba6888	رفع اشکالات و بازبینی	43	27	2026-07-16	approved	7891652b-f708-4834-90b3-b7e06f9dd5ab	\N	1e541163-60a8-4155-9ab1-457977b0379b	2026-07-20 09:22:03.794401+00	2026-07-20 09:22:03.794401+00
1d224113-52fd-42ec-a3d9-ee5e9338d4af	708e2273-f30d-40b7-9118-3ba6a26bc8d6	fc439dd8-ff4f-4760-bcc2-e3cddcba6888	رفع اشکالات و بازبینی	173	78	2026-07-16	approved	7891652b-f708-4834-90b3-b7e06f9dd5ab	\N	8bfffbdc-20a0-4854-9bb3-879890902ac8	2026-07-20 09:22:03.794401+00	2026-07-20 09:22:03.794401+00
1d224113-52fd-42ec-a3d9-ee5e9338d4af	708e2273-f30d-40b7-9118-3ba6a26bc8d6	fc439dd8-ff4f-4760-bcc2-e3cddcba6888	رفع اشکالات و بازبینی	213	100	2026-07-16	approved	7891652b-f708-4834-90b3-b7e06f9dd5ab	\N	ae7b55c2-2600-4eff-a7be-f7f6f8f82aa9	2026-07-20 09:22:03.794401+00	2026-07-20 09:22:03.794401+00
1d224113-52fd-42ec-a3d9-ee5e9338d4af	708e2273-f30d-40b7-9118-3ba6a26bc8d6	fc439dd8-ff4f-4760-bcc2-e3cddcba6888	پیشرفت اولیه و بررسی نیازمندی‌ها	224	100	2026-07-16	approved	7891652b-f708-4834-90b3-b7e06f9dd5ab	\N	b90f3ed0-c1e9-46e2-b2fe-236fbb0b165b	2026-07-20 09:22:03.794401+00	2026-07-20 09:22:03.794401+00
1d224113-52fd-42ec-a3d9-ee5e9338d4af	82357429-8f44-404e-8083-4192cf1f6a7e	7891652b-f708-4834-90b3-b7e06f9dd5ab	رفع اشکالات و بازبینی	170	36	2026-07-16	approved	7891652b-f708-4834-90b3-b7e06f9dd5ab	\N	74d32b88-bbff-4b48-b23c-4ab803752c85	2026-07-20 09:22:03.794401+00	2026-07-20 09:22:03.794401+00
1d224113-52fd-42ec-a3d9-ee5e9338d4af	b51e2aff-9f3c-4e38-94c3-53d6a8f11cbd	726b1bd0-c51d-4f38-9e37-f4c46a258d1b	پیشرفت اولیه و بررسی نیازمندی‌ها	72	35	2026-07-16	approved	7891652b-f708-4834-90b3-b7e06f9dd5ab	\N	e70c16f8-bbdb-43b4-bc9f-72035d94d14d	2026-07-20 09:22:03.794401+00	2026-07-20 09:22:03.794401+00
1d224113-52fd-42ec-a3d9-ee5e9338d4af	b51e2aff-9f3c-4e38-94c3-53d6a8f11cbd	726b1bd0-c51d-4f38-9e37-f4c46a258d1b	تست و اطمینان از عملکرد صحیح	57	56	2026-07-16	approved	7891652b-f708-4834-90b3-b7e06f9dd5ab	\N	b9f08522-d829-4222-a59f-6960245276d1	2026-07-20 09:22:03.794401+00	2026-07-20 09:22:03.794401+00
1d224113-52fd-42ec-a3d9-ee5e9338d4af	b51e2aff-9f3c-4e38-94c3-53d6a8f11cbd	726b1bd0-c51d-4f38-9e37-f4c46a258d1b	پیاده‌سازی بخش اصلی	60	96	2026-07-16	approved	7891652b-f708-4834-90b3-b7e06f9dd5ab	\N	c9325fb2-0ce3-4c6d-bbb5-99ca69267a89	2026-07-20 09:22:03.794401+00	2026-07-20 09:22:03.794401+00
1d224113-52fd-42ec-a3d9-ee5e9338d4af	bc884c44-ab60-4b24-ae74-252b63ed9529	57b624b6-2a61-45ab-95e9-0d4965be1a7e	پیاده‌سازی بخش اصلی	213	30	2026-07-16	approved	7891652b-f708-4834-90b3-b7e06f9dd5ab	\N	fae49cae-88cb-477c-8fbb-721e749631f4	2026-07-20 09:22:03.794401+00	2026-07-20 09:22:03.794401+00
1d224113-52fd-42ec-a3d9-ee5e9338d4af	bc884c44-ab60-4b24-ae74-252b63ed9529	57b624b6-2a61-45ab-95e9-0d4965be1a7e	تست و اطمینان از عملکرد صحیح	41	80	2026-07-16	approved	7891652b-f708-4834-90b3-b7e06f9dd5ab	\N	50549cd6-016c-4986-ba2a-fb43b5325b32	2026-07-20 09:22:03.794401+00	2026-07-20 09:22:03.794401+00
1d224113-52fd-42ec-a3d9-ee5e9338d4af	a643faa6-7d65-481c-af43-65e718f48bb5	81977026-b6d9-4183-92f3-63f6484c7ae5	تست و اطمینان از عملکرد صحیح	198	38	2026-07-07	approved	7891652b-f708-4834-90b3-b7e06f9dd5ab	\N	5db2f87d-3f55-4946-b43b-4d5404a386b0	2026-07-20 09:22:03.794401+00	2026-07-20 09:22:03.794401+00
1d224113-52fd-42ec-a3d9-ee5e9338d4af	be8a8cdb-42e2-47c3-8943-ae13308ea5ee	3623572f-edd3-4d8b-a827-788687faac93	پیشرفت اولیه و بررسی نیازمندی‌ها	165	21	2026-07-12	approved	7891652b-f708-4834-90b3-b7e06f9dd5ab	\N	9991a309-585a-42d6-9f46-d944bbe045b4	2026-07-20 09:22:03.794401+00	2026-07-20 09:22:03.794401+00
1d224113-52fd-42ec-a3d9-ee5e9338d4af	be8a8cdb-42e2-47c3-8943-ae13308ea5ee	3623572f-edd3-4d8b-a827-788687faac93	مستندسازی و نهایی‌سازی	153	72	2026-07-16	approved	7891652b-f708-4834-90b3-b7e06f9dd5ab	\N	c0901c21-e0e7-4b1d-9ea2-1cd38ae13a0e	2026-07-20 09:22:03.794401+00	2026-07-20 09:22:03.794401+00
1d224113-52fd-42ec-a3d9-ee5e9338d4af	8b095cab-035d-4f6e-a7ef-76905cd2e38d	57b624b6-2a61-45ab-95e9-0d4965be1a7e	پیاده‌سازی بخش اصلی	56	32	2026-07-16	approved	7891652b-f708-4834-90b3-b7e06f9dd5ab	\N	95115e73-a0fc-498d-a1de-c1a77c144a68	2026-07-20 09:22:03.794401+00	2026-07-20 09:22:03.794401+00
1d224113-52fd-42ec-a3d9-ee5e9338d4af	8b095cab-035d-4f6e-a7ef-76905cd2e38d	57b624b6-2a61-45ab-95e9-0d4965be1a7e	مستندسازی و نهایی‌سازی	128	66	2026-07-16	approved	7891652b-f708-4834-90b3-b7e06f9dd5ab	\N	a2c42f2c-1a04-4470-b18f-ae083cb830d7	2026-07-20 09:22:03.794401+00	2026-07-20 09:22:03.794401+00
1d224113-52fd-42ec-a3d9-ee5e9338d4af	86fdcd94-12c6-4040-acf6-7d83a89aca88	81977026-b6d9-4183-92f3-63f6484c7ae5	رفع اشکالات و بازبینی	105	34	2026-06-26	approved	7891652b-f708-4834-90b3-b7e06f9dd5ab	\N	546e8deb-ff1b-4262-bf8b-82e475d1d06d	2026-07-20 09:22:03.794401+00	2026-07-20 09:22:03.794401+00
1d224113-52fd-42ec-a3d9-ee5e9338d4af	86fdcd94-12c6-4040-acf6-7d83a89aca88	81977026-b6d9-4183-92f3-63f6484c7ae5	مستندسازی و نهایی‌سازی	209	72	2026-06-28	approved	7891652b-f708-4834-90b3-b7e06f9dd5ab	\N	0378d9fc-50ae-4d1b-861e-c2d2a7af3f13	2026-07-20 09:22:03.794401+00	2026-07-20 09:22:03.794401+00
1d224113-52fd-42ec-a3d9-ee5e9338d4af	0d6b7f47-6a69-4be7-b752-9d3c0a214fbd	726b1bd0-c51d-4f38-9e37-f4c46a258d1b	مستندسازی و نهایی‌سازی	191	26	2026-07-16	submitted	\N	\N	8bed5427-ef1e-4903-b50a-d06a0a7f4968	2026-07-20 09:22:03.794401+00	2026-07-20 09:22:03.794401+00
1d224113-52fd-42ec-a3d9-ee5e9338d4af	0d6b7f47-6a69-4be7-b752-9d3c0a214fbd	726b1bd0-c51d-4f38-9e37-f4c46a258d1b	رفع اشکالات و بازبینی	205	62	2026-07-16	approved	7891652b-f708-4834-90b3-b7e06f9dd5ab	\N	99899dc4-a9ec-4c21-b64e-34d4cc9a4a6d	2026-07-20 09:22:03.794401+00	2026-07-20 09:22:03.794401+00
1d224113-52fd-42ec-a3d9-ee5e9338d4af	0d6b7f47-6a69-4be7-b752-9d3c0a214fbd	726b1bd0-c51d-4f38-9e37-f4c46a258d1b	پیاده‌سازی بخش اصلی	158	100	2026-07-16	submitted	\N	\N	3e0255be-40ee-4a82-b9d2-7eab1bbb6405	2026-07-20 09:22:03.794401+00	2026-07-20 09:22:03.794401+00
1d224113-52fd-42ec-a3d9-ee5e9338d4af	d6961189-d847-440d-9c88-f8239fbbde5c	57b624b6-2a61-45ab-95e9-0d4965be1a7e	مستندسازی و نهایی‌سازی	152	38	2026-07-01	submitted	\N	\N	c3039ff1-f700-4988-a073-5508d9268362	2026-07-20 09:22:03.794401+00	2026-07-20 09:22:03.794401+00
1d224113-52fd-42ec-a3d9-ee5e9338d4af	d6961189-d847-440d-9c88-f8239fbbde5c	57b624b6-2a61-45ab-95e9-0d4965be1a7e	مستندسازی و نهایی‌سازی	103	66	2026-07-05	approved	7891652b-f708-4834-90b3-b7e06f9dd5ab	\N	8d33db60-98a5-443f-9c24-b7deca7447a4	2026-07-20 09:22:03.794401+00	2026-07-20 09:22:03.794401+00
1d224113-52fd-42ec-a3d9-ee5e9338d4af	d6961189-d847-440d-9c88-f8239fbbde5c	57b624b6-2a61-45ab-95e9-0d4965be1a7e	پیشرفت اولیه و بررسی نیازمندی‌ها	127	72	2026-07-03	approved	7891652b-f708-4834-90b3-b7e06f9dd5ab	\N	f6760787-1e42-4128-a12c-4a50566ca1a1	2026-07-20 09:22:03.794401+00	2026-07-20 09:22:03.794401+00
1d224113-52fd-42ec-a3d9-ee5e9338d4af	c7f6b758-d856-49ef-9470-444d5f9d6bef	81977026-b6d9-4183-92f3-63f6484c7ae5	پیاده‌سازی بخش اصلی	98	25	2026-06-28	approved	7891652b-f708-4834-90b3-b7e06f9dd5ab	\N	eaf46a99-4a6f-4b47-8bb4-9cca1264aedd	2026-07-20 09:22:03.794401+00	2026-07-20 09:22:03.794401+00
1d224113-52fd-42ec-a3d9-ee5e9338d4af	22cfd323-875d-4e37-8323-e1e76ea1a529	81977026-b6d9-4183-92f3-63f6484c7ae5	پیشرفت اولیه و بررسی نیازمندی‌ها	206	29	2026-06-21	approved	7891652b-f708-4834-90b3-b7e06f9dd5ab	\N	f64e322b-c4e5-4225-8568-703c5c2f816d	2026-07-20 09:22:03.794401+00	2026-07-20 09:22:03.794401+00
1d224113-52fd-42ec-a3d9-ee5e9338d4af	22cfd323-875d-4e37-8323-e1e76ea1a529	81977026-b6d9-4183-92f3-63f6484c7ae5	پیشرفت اولیه و بررسی نیازمندی‌ها	121	68	2026-06-23	submitted	\N	\N	4f3e2caa-4b82-441d-8866-e94e1058cff2	2026-07-20 09:22:03.794401+00	2026-07-20 09:22:03.794401+00
1d224113-52fd-42ec-a3d9-ee5e9338d4af	22cfd323-875d-4e37-8323-e1e76ea1a529	81977026-b6d9-4183-92f3-63f6484c7ae5	مستندسازی و نهایی‌سازی	87	100	2026-06-23	approved	7891652b-f708-4834-90b3-b7e06f9dd5ab	\N	22e6f150-2a7d-4bfd-af2c-7110e242f114	2026-07-20 09:22:03.794401+00	2026-07-20 09:22:03.794401+00
1d224113-52fd-42ec-a3d9-ee5e9338d4af	caa2c341-f2a6-4ffb-9f63-42336db152d4	39f6a330-2d20-4870-ba2a-2457ecb3df8d	رفع اشکالات و بازبینی	207	21	2026-07-16	approved	7891652b-f708-4834-90b3-b7e06f9dd5ab	\N	9a16f83b-ad5e-47eb-b5ad-8cced156f801	2026-07-20 09:22:03.794401+00	2026-07-20 09:22:03.794401+00
1d224113-52fd-42ec-a3d9-ee5e9338d4af	caa2c341-f2a6-4ffb-9f63-42336db152d4	39f6a330-2d20-4870-ba2a-2457ecb3df8d	رفع اشکالات و بازبینی	171	42	2026-07-16	approved	7891652b-f708-4834-90b3-b7e06f9dd5ab	\N	de5212e5-6cd0-4415-9727-024ac80513d5	2026-07-20 09:22:03.794401+00	2026-07-20 09:22:03.794401+00
1d224113-52fd-42ec-a3d9-ee5e9338d4af	caa2c341-f2a6-4ffb-9f63-42336db152d4	39f6a330-2d20-4870-ba2a-2457ecb3df8d	پیاده‌سازی بخش اصلی	188	100	2026-07-16	submitted	\N	\N	5096f3fd-cec4-44ea-9f8f-ef5917e04096	2026-07-20 09:22:03.794401+00	2026-07-20 09:22:03.794401+00
1d224113-52fd-42ec-a3d9-ee5e9338d4af	caa2c341-f2a6-4ffb-9f63-42336db152d4	39f6a330-2d20-4870-ba2a-2457ecb3df8d	رفع اشکالات و بازبینی	223	100	2026-07-16	submitted	\N	\N	be51831f-566d-493e-b380-de91e07f1072	2026-07-20 09:22:03.794401+00	2026-07-20 09:22:03.794401+00
1d224113-52fd-42ec-a3d9-ee5e9338d4af	59ee9e4f-b89b-4939-9c8e-51215f81e8df	57b624b6-2a61-45ab-95e9-0d4965be1a7e	رفع اشکالات و بازبینی	144	25	2026-07-16	approved	7891652b-f708-4834-90b3-b7e06f9dd5ab	\N	4fa6b311-91de-4e0d-a800-7a7fbc12a6d7	2026-07-20 09:22:03.794401+00	2026-07-20 09:22:03.794401+00
1d224113-52fd-42ec-a3d9-ee5e9338d4af	59ee9e4f-b89b-4939-9c8e-51215f81e8df	57b624b6-2a61-45ab-95e9-0d4965be1a7e	پیاده‌سازی بخش اصلی	74	72	2026-07-16	approved	7891652b-f708-4834-90b3-b7e06f9dd5ab	\N	7945c485-3ddd-4cc6-b3aa-451c1f1fd7d2	2026-07-20 09:22:03.794401+00	2026-07-20 09:22:03.794401+00
1d224113-52fd-42ec-a3d9-ee5e9338d4af	3fc39ded-af64-4a8a-bf6b-41535e01b64d	3623572f-edd3-4d8b-a827-788687faac93	پیشرفت اولیه و بررسی نیازمندی‌ها	139	28	2026-07-16	approved	7891652b-f708-4834-90b3-b7e06f9dd5ab	\N	827aa260-7b27-46f5-b58b-c16e0cdc8671	2026-07-20 09:22:03.794401+00	2026-07-20 09:22:03.794401+00
1d224113-52fd-42ec-a3d9-ee5e9338d4af	8f9ad552-8676-4e76-bfb1-b2b48af2e0c5	7891652b-f708-4834-90b3-b7e06f9dd5ab	رفع اشکالات و بازبینی	31	30	2026-07-16	approved	7891652b-f708-4834-90b3-b7e06f9dd5ab	\N	bcb94aa6-9e8b-4f44-81fc-df555f3a282c	2026-07-20 09:22:03.794401+00	2026-07-20 09:22:03.794401+00
1d224113-52fd-42ec-a3d9-ee5e9338d4af	8f9ad552-8676-4e76-bfb1-b2b48af2e0c5	7891652b-f708-4834-90b3-b7e06f9dd5ab	پیاده‌سازی بخش اصلی	40	48	2026-07-16	submitted	\N	\N	3d60f591-eaff-4be6-9b02-b8334d49ac33	2026-07-20 09:22:03.794401+00	2026-07-20 09:22:03.794401+00
1d224113-52fd-42ec-a3d9-ee5e9338d4af	8f9ad552-8676-4e76-bfb1-b2b48af2e0c5	7891652b-f708-4834-90b3-b7e06f9dd5ab	مستندسازی و نهایی‌سازی	199	87	2026-07-16	approved	7891652b-f708-4834-90b3-b7e06f9dd5ab	\N	46ec7d42-56bb-418b-8242-a7da235cb92f	2026-07-20 09:22:03.794401+00	2026-07-20 09:22:03.794401+00
1d224113-52fd-42ec-a3d9-ee5e9338d4af	41c636a0-6e79-4a1d-b3eb-1d564279a3f1	81977026-b6d9-4183-92f3-63f6484c7ae5	پیشرفت اولیه و بررسی نیازمندی‌ها	230	30	2026-07-16	approved	7891652b-f708-4834-90b3-b7e06f9dd5ab	\N	d0c6127d-dd58-48c4-a48b-e415d1e74136	2026-07-20 09:22:03.794401+00	2026-07-20 09:22:03.794401+00
1d224113-52fd-42ec-a3d9-ee5e9338d4af	41c636a0-6e79-4a1d-b3eb-1d564279a3f1	81977026-b6d9-4183-92f3-63f6484c7ae5	پیاده‌سازی بخش اصلی	163	44	2026-07-16	approved	7891652b-f708-4834-90b3-b7e06f9dd5ab	\N	77fc754b-1da7-4db7-9ea3-9bf19ddf320f	2026-07-20 09:22:03.794401+00	2026-07-20 09:22:03.794401+00
1d224113-52fd-42ec-a3d9-ee5e9338d4af	41c636a0-6e79-4a1d-b3eb-1d564279a3f1	81977026-b6d9-4183-92f3-63f6484c7ae5	تست و اطمینان از عملکرد صحیح	169	100	2026-07-16	approved	7891652b-f708-4834-90b3-b7e06f9dd5ab	\N	a5b25faf-c0bb-467e-80e0-e2d29454fe9f	2026-07-20 09:22:03.794401+00	2026-07-20 09:22:03.794401+00
1d224113-52fd-42ec-a3d9-ee5e9338d4af	41c636a0-6e79-4a1d-b3eb-1d564279a3f1	81977026-b6d9-4183-92f3-63f6484c7ae5	پیشرفت اولیه و بررسی نیازمندی‌ها	119	100	2026-07-16	approved	7891652b-f708-4834-90b3-b7e06f9dd5ab	\N	0323aaca-dbd2-44b1-bee2-e5d230686be0	2026-07-20 09:22:03.794401+00	2026-07-20 09:22:03.794401+00
1d224113-52fd-42ec-a3d9-ee5e9338d4af	675d0792-331c-4d16-90db-a3120d1d154b	39f6a330-2d20-4870-ba2a-2457ecb3df8d	رفع اشکالات و بازبینی	122	29	2026-07-16	approved	7891652b-f708-4834-90b3-b7e06f9dd5ab	\N	dce04631-3a72-4d89-bd06-967f17d21066	2026-07-20 09:22:03.794401+00	2026-07-20 09:22:03.794401+00
1d224113-52fd-42ec-a3d9-ee5e9338d4af	675d0792-331c-4d16-90db-a3120d1d154b	39f6a330-2d20-4870-ba2a-2457ecb3df8d	مستندسازی و نهایی‌سازی	165	70	2026-07-16	approved	7891652b-f708-4834-90b3-b7e06f9dd5ab	\N	32bb90de-4a7c-493f-91b2-ef5da335252a	2026-07-20 09:22:03.794401+00	2026-07-20 09:22:03.794401+00
1d224113-52fd-42ec-a3d9-ee5e9338d4af	6efe76f2-307b-4a26-9f4a-7e09d8da36e1	fc439dd8-ff4f-4760-bcc2-e3cddcba6888	رفع اشکالات و بازبینی	144	27	2026-06-16	approved	7891652b-f708-4834-90b3-b7e06f9dd5ab	\N	36ac58de-9f3c-4f18-ad38-12ef888cf696	2026-07-20 09:22:03.794401+00	2026-07-20 09:22:03.794401+00
1d224113-52fd-42ec-a3d9-ee5e9338d4af	65152795-e64e-4859-9ea7-489dce79a688	7891652b-f708-4834-90b3-b7e06f9dd5ab	رفع اشکالات و بازبینی	127	23	2026-06-25	approved	7891652b-f708-4834-90b3-b7e06f9dd5ab	\N	3c5339d2-2074-494a-a7fc-2753a62ff6ba	2026-07-20 09:22:03.794401+00	2026-07-20 09:22:03.794401+00
1d224113-52fd-42ec-a3d9-ee5e9338d4af	65152795-e64e-4859-9ea7-489dce79a688	7891652b-f708-4834-90b3-b7e06f9dd5ab	رفع اشکالات و بازبینی	36	72	2026-06-29	approved	7891652b-f708-4834-90b3-b7e06f9dd5ab	\N	9339d642-3f64-41af-a959-f0d1acebff88	2026-07-20 09:22:03.794401+00	2026-07-20 09:22:03.794401+00
1d224113-52fd-42ec-a3d9-ee5e9338d4af	68e554a1-d5dd-4b48-b6f3-0f9acce63d7a	3623572f-edd3-4d8b-a827-788687faac93	رفع اشکالات و بازبینی	196	26	2026-07-10	approved	7891652b-f708-4834-90b3-b7e06f9dd5ab	\N	e4cc1746-27b4-4b29-b2cd-6615452bcf70	2026-07-20 09:22:03.794401+00	2026-07-20 09:22:03.794401+00
1d224113-52fd-42ec-a3d9-ee5e9338d4af	68e554a1-d5dd-4b48-b6f3-0f9acce63d7a	3623572f-edd3-4d8b-a827-788687faac93	پیشرفت اولیه و بررسی نیازمندی‌ها	72	74	2026-07-13	approved	7891652b-f708-4834-90b3-b7e06f9dd5ab	\N	a94f1ef2-694c-4856-849a-f49b392c4bf2	2026-07-20 09:22:03.794401+00	2026-07-20 09:22:03.794401+00
1d224113-52fd-42ec-a3d9-ee5e9338d4af	68e554a1-d5dd-4b48-b6f3-0f9acce63d7a	3623572f-edd3-4d8b-a827-788687faac93	پیاده‌سازی بخش اصلی	201	100	2026-07-12	approved	7891652b-f708-4834-90b3-b7e06f9dd5ab	\N	6e417e91-a790-48a3-9d7a-8deddf4a6cb9	2026-07-20 09:22:03.794401+00	2026-07-20 09:22:03.794401+00
1d224113-52fd-42ec-a3d9-ee5e9338d4af	ce636946-4bd8-49e8-a032-6a90c02941b9	57b624b6-2a61-45ab-95e9-0d4965be1a7e	پیاده‌سازی بخش اصلی	167	33	2026-06-25	submitted	\N	\N	07a14112-e375-445b-a5e3-7234653601a8	2026-07-20 09:22:03.794401+00	2026-07-20 09:22:03.794401+00
1d224113-52fd-42ec-a3d9-ee5e9338d4af	ce636946-4bd8-49e8-a032-6a90c02941b9	57b624b6-2a61-45ab-95e9-0d4965be1a7e	پیاده‌سازی بخش اصلی	36	68	2026-06-26	submitted	\N	\N	f87979a4-ce3b-48fb-9339-9190ed548883	2026-07-20 09:22:03.794401+00	2026-07-20 09:22:03.794401+00
1d224113-52fd-42ec-a3d9-ee5e9338d4af	d569158d-2b15-4ab7-885f-799f74f6bde1	57b624b6-2a61-45ab-95e9-0d4965be1a7e	پیشرفت اولیه و بررسی نیازمندی‌ها	48	21	2026-07-16	approved	7891652b-f708-4834-90b3-b7e06f9dd5ab	\N	76019c10-be6c-4319-8bc7-68791d5a0820	2026-07-20 09:22:03.794401+00	2026-07-20 09:22:03.794401+00
1d224113-52fd-42ec-a3d9-ee5e9338d4af	d569158d-2b15-4ab7-885f-799f74f6bde1	57b624b6-2a61-45ab-95e9-0d4965be1a7e	رفع اشکالات و بازبینی	172	44	2026-07-16	approved	7891652b-f708-4834-90b3-b7e06f9dd5ab	\N	a565d059-de9b-454e-999e-c90855270e8f	2026-07-20 09:22:03.794401+00	2026-07-20 09:22:03.794401+00
1d224113-52fd-42ec-a3d9-ee5e9338d4af	d569158d-2b15-4ab7-885f-799f74f6bde1	57b624b6-2a61-45ab-95e9-0d4965be1a7e	رفع اشکالات و بازبینی	134	96	2026-07-16	approved	7891652b-f708-4834-90b3-b7e06f9dd5ab	\N	c98590a6-c111-4431-bc4b-2508a20dc776	2026-07-20 09:22:03.794401+00	2026-07-20 09:22:03.794401+00
1d224113-52fd-42ec-a3d9-ee5e9338d4af	a6cbe273-eb89-4f34-9137-254561f361d0	7891652b-f708-4834-90b3-b7e06f9dd5ab	پیشرفت اولیه و بررسی نیازمندی‌ها	129	23	2026-07-16	approved	7891652b-f708-4834-90b3-b7e06f9dd5ab	\N	07a79548-b6e7-42d9-96fb-00a55cf40290	2026-07-20 09:22:03.794401+00	2026-07-20 09:22:03.794401+00
1d224113-52fd-42ec-a3d9-ee5e9338d4af	a6cbe273-eb89-4f34-9137-254561f361d0	7891652b-f708-4834-90b3-b7e06f9dd5ab	مستندسازی و نهایی‌سازی	46	76	2026-07-16	approved	7891652b-f708-4834-90b3-b7e06f9dd5ab	\N	6e3abe23-6c2f-4d74-914b-53509ebc0b25	2026-07-20 09:22:03.794401+00	2026-07-20 09:22:03.794401+00
1d224113-52fd-42ec-a3d9-ee5e9338d4af	a6cbe273-eb89-4f34-9137-254561f361d0	7891652b-f708-4834-90b3-b7e06f9dd5ab	پیشرفت اولیه و بررسی نیازمندی‌ها	121	100	2026-07-16	submitted	\N	\N	4b48dedc-b709-44eb-bea9-ab14720fd609	2026-07-20 09:22:03.794401+00	2026-07-20 09:22:03.794401+00
1d224113-52fd-42ec-a3d9-ee5e9338d4af	a6cbe273-eb89-4f34-9137-254561f361d0	7891652b-f708-4834-90b3-b7e06f9dd5ab	رفع اشکالات و بازبینی	185	88	2026-07-16	approved	7891652b-f708-4834-90b3-b7e06f9dd5ab	\N	941405db-8baa-4c73-9ddb-aafae7ae2c34	2026-07-20 09:22:03.794401+00	2026-07-20 09:22:03.794401+00
1d224113-52fd-42ec-a3d9-ee5e9338d4af	04dae2a4-4c1e-4b06-8fa5-b9b263fd3858	57b624b6-2a61-45ab-95e9-0d4965be1a7e	پیشرفت اولیه و بررسی نیازمندی‌ها	151	25	2026-07-16	approved	7891652b-f708-4834-90b3-b7e06f9dd5ab	\N	400d1115-0693-4746-9ffc-9f7ce8566342	2026-07-20 09:22:03.794401+00	2026-07-20 09:22:03.794401+00
1d224113-52fd-42ec-a3d9-ee5e9338d4af	04dae2a4-4c1e-4b06-8fa5-b9b263fd3858	57b624b6-2a61-45ab-95e9-0d4965be1a7e	تست و اطمینان از عملکرد صحیح	233	74	2026-07-16	approved	7891652b-f708-4834-90b3-b7e06f9dd5ab	\N	bc173039-c379-44e3-84b1-3a8faa780bcc	2026-07-20 09:22:03.794401+00	2026-07-20 09:22:03.794401+00
1d224113-52fd-42ec-a3d9-ee5e9338d4af	04dae2a4-4c1e-4b06-8fa5-b9b263fd3858	57b624b6-2a61-45ab-95e9-0d4965be1a7e	پیاده‌سازی بخش اصلی	106	100	2026-07-16	submitted	\N	\N	2f298c93-ed26-4c3c-be05-29c595e400c2	2026-07-20 09:22:03.794401+00	2026-07-20 09:22:03.794401+00
1d224113-52fd-42ec-a3d9-ee5e9338d4af	3e20996f-29bc-4868-9d79-56af8acdff5d	726b1bd0-c51d-4f38-9e37-f4c46a258d1b	مستندسازی و نهایی‌سازی	66	23	2026-07-16	approved	7891652b-f708-4834-90b3-b7e06f9dd5ab	\N	e75fd4d5-13e1-4b14-84c1-bc83ea56aef5	2026-07-20 09:22:03.794401+00	2026-07-20 09:22:03.794401+00
1d224113-52fd-42ec-a3d9-ee5e9338d4af	3e20996f-29bc-4868-9d79-56af8acdff5d	726b1bd0-c51d-4f38-9e37-f4c46a258d1b	مستندسازی و نهایی‌سازی	130	74	2026-07-16	approved	7891652b-f708-4834-90b3-b7e06f9dd5ab	\N	d5ad4f8d-694d-4946-8a71-0f329009451a	2026-07-20 09:22:03.794401+00	2026-07-20 09:22:03.794401+00
1d224113-52fd-42ec-a3d9-ee5e9338d4af	3e20996f-29bc-4868-9d79-56af8acdff5d	726b1bd0-c51d-4f38-9e37-f4c46a258d1b	رفع اشکالات و بازبینی	84	99	2026-07-16	approved	7891652b-f708-4834-90b3-b7e06f9dd5ab	\N	4f6c0066-fe08-4d24-b095-cfaf392909dd	2026-07-20 09:22:03.794401+00	2026-07-20 09:22:03.794401+00
1d224113-52fd-42ec-a3d9-ee5e9338d4af	ff012e5a-5b4f-42c8-99ce-02f23348bdf4	39f6a330-2d20-4870-ba2a-2457ecb3df8d	پیاده‌سازی بخش اصلی	86	39	2026-06-17	approved	7891652b-f708-4834-90b3-b7e06f9dd5ab	\N	fa347e28-6f82-4c1a-9e99-93b6cb544ab8	2026-07-20 09:22:03.794401+00	2026-07-20 09:22:03.794401+00
1d224113-52fd-42ec-a3d9-ee5e9338d4af	ff012e5a-5b4f-42c8-99ce-02f23348bdf4	39f6a330-2d20-4870-ba2a-2457ecb3df8d	پیاده‌سازی بخش اصلی	59	50	2026-06-20	approved	7891652b-f708-4834-90b3-b7e06f9dd5ab	\N	543ef1de-6c38-4b62-8c73-034a1063a00f	2026-07-20 09:22:03.794401+00	2026-07-20 09:22:03.794401+00
1d224113-52fd-42ec-a3d9-ee5e9338d4af	24324de2-fa2e-47ec-bcd5-fdbe8807dd02	39f6a330-2d20-4870-ba2a-2457ecb3df8d	مستندسازی و نهایی‌سازی	48	29	2026-07-16	approved	7891652b-f708-4834-90b3-b7e06f9dd5ab	\N	8edeae4f-f622-4b19-bc40-92fd23204ea0	2026-07-20 09:22:03.794401+00	2026-07-20 09:22:03.794401+00
1d224113-52fd-42ec-a3d9-ee5e9338d4af	0ef90389-490d-4602-9222-7034cccd4a83	3623572f-edd3-4d8b-a827-788687faac93	پیشرفت اولیه و بررسی نیازمندی‌ها	80	38	2026-07-16	approved	7891652b-f708-4834-90b3-b7e06f9dd5ab	\N	fa3bc0a8-0b0d-456a-bce2-c5371b09feeb	2026-07-20 09:22:03.794401+00	2026-07-20 09:22:03.794401+00
1d224113-52fd-42ec-a3d9-ee5e9338d4af	00847a5a-6e6f-4ba6-a9e0-8a7411c19113	726b1bd0-c51d-4f38-9e37-f4c46a258d1b	پیاده‌سازی بخش اصلی	55	29	2026-07-16	approved	7891652b-f708-4834-90b3-b7e06f9dd5ab	\N	53c569f6-22d5-41aa-9af7-9fa2928d0c53	2026-07-20 09:22:03.794401+00	2026-07-20 09:22:03.794401+00
1d224113-52fd-42ec-a3d9-ee5e9338d4af	00847a5a-6e6f-4ba6-a9e0-8a7411c19113	726b1bd0-c51d-4f38-9e37-f4c46a258d1b	رفع اشکالات و بازبینی	154	68	2026-07-16	submitted	\N	\N	bd406ca3-c34e-4276-9251-9788cd876b51	2026-07-20 09:22:03.794401+00	2026-07-20 09:22:03.794401+00
1d224113-52fd-42ec-a3d9-ee5e9338d4af	00847a5a-6e6f-4ba6-a9e0-8a7411c19113	726b1bd0-c51d-4f38-9e37-f4c46a258d1b	رفع اشکالات و بازبینی	207	100	2026-07-16	approved	7891652b-f708-4834-90b3-b7e06f9dd5ab	\N	bf202055-2717-4c1f-b863-7920a5f2dc97	2026-07-20 09:22:03.794401+00	2026-07-20 09:22:03.794401+00
1d224113-52fd-42ec-a3d9-ee5e9338d4af	00847a5a-6e6f-4ba6-a9e0-8a7411c19113	726b1bd0-c51d-4f38-9e37-f4c46a258d1b	رفع اشکالات و بازبینی	236	100	2026-07-16	approved	7891652b-f708-4834-90b3-b7e06f9dd5ab	\N	a93b9b94-e0a3-47e4-84fc-4500f1960600	2026-07-20 09:22:03.794401+00	2026-07-20 09:22:03.794401+00
1d224113-52fd-42ec-a3d9-ee5e9338d4af	5ef12672-e2e4-4c43-8783-477b94bbce9f	39f6a330-2d20-4870-ba2a-2457ecb3df8d	پیشرفت اولیه و بررسی نیازمندی‌ها	110	27	2026-06-29	approved	7891652b-f708-4834-90b3-b7e06f9dd5ab	\N	aa54143b-0f6e-44d7-b1e1-b8acf357e437	2026-07-20 09:22:03.794401+00	2026-07-20 09:22:03.794401+00
1d224113-52fd-42ec-a3d9-ee5e9338d4af	5ef12672-e2e4-4c43-8783-477b94bbce9f	39f6a330-2d20-4870-ba2a-2457ecb3df8d	تست و اطمینان از عملکرد صحیح	100	62	2026-07-01	approved	7891652b-f708-4834-90b3-b7e06f9dd5ab	\N	ce53135e-c0fb-4876-8903-485f3f1925e7	2026-07-20 09:22:03.794401+00	2026-07-20 09:22:03.794401+00
1d224113-52fd-42ec-a3d9-ee5e9338d4af	5ef12672-e2e4-4c43-8783-477b94bbce9f	39f6a330-2d20-4870-ba2a-2457ecb3df8d	رفع اشکالات و بازبینی	152	100	2026-07-03	approved	7891652b-f708-4834-90b3-b7e06f9dd5ab	\N	18b35152-5dde-4d28-8fbc-6ea2e0cbd4a7	2026-07-20 09:22:03.794401+00	2026-07-20 09:22:03.794401+00
1d224113-52fd-42ec-a3d9-ee5e9338d4af	5ef12672-e2e4-4c43-8783-477b94bbce9f	39f6a330-2d20-4870-ba2a-2457ecb3df8d	رفع اشکالات و بازبینی	228	100	2026-07-11	approved	7891652b-f708-4834-90b3-b7e06f9dd5ab	\N	8c9afc66-19b3-4b22-a48f-84987bae41b0	2026-07-20 09:22:03.794401+00	2026-07-20 09:22:03.794401+00
1d224113-52fd-42ec-a3d9-ee5e9338d4af	98b46b79-cc9a-4bc9-ad94-ed09d64462fb	57b624b6-2a61-45ab-95e9-0d4965be1a7e	پیاده‌سازی بخش اصلی	195	39	2026-06-17	approved	7891652b-f708-4834-90b3-b7e06f9dd5ab	\N	8a1cfedf-cddb-4257-82df-a7f595dcdfb8	2026-07-20 09:22:03.794401+00	2026-07-20 09:22:03.794401+00
1d224113-52fd-42ec-a3d9-ee5e9338d4af	98b46b79-cc9a-4bc9-ad94-ed09d64462fb	57b624b6-2a61-45ab-95e9-0d4965be1a7e	رفع اشکالات و بازبینی	65	74	2026-06-18	approved	7891652b-f708-4834-90b3-b7e06f9dd5ab	\N	7b9bff27-bb0d-42ad-b8e1-d3b9314ae371	2026-07-20 09:22:03.794401+00	2026-07-20 09:22:03.794401+00
1d224113-52fd-42ec-a3d9-ee5e9338d4af	98b46b79-cc9a-4bc9-ad94-ed09d64462fb	57b624b6-2a61-45ab-95e9-0d4965be1a7e	رفع اشکالات و بازبینی	217	100	2026-06-21	approved	7891652b-f708-4834-90b3-b7e06f9dd5ab	\N	17341673-4e6b-4a2f-822e-0eb4278975ed	2026-07-20 09:22:03.794401+00	2026-07-20 09:22:03.794401+00
1d224113-52fd-42ec-a3d9-ee5e9338d4af	98b46b79-cc9a-4bc9-ad94-ed09d64462fb	57b624b6-2a61-45ab-95e9-0d4965be1a7e	پیشرفت اولیه و بررسی نیازمندی‌ها	34	100	2026-06-20	approved	7891652b-f708-4834-90b3-b7e06f9dd5ab	\N	0ceb802f-d3cc-48fe-9cd2-621a44e51f1b	2026-07-20 09:22:03.794401+00	2026-07-20 09:22:03.794401+00
1d224113-52fd-42ec-a3d9-ee5e9338d4af	99499105-abc9-49fb-af15-db274aedec19	3623572f-edd3-4d8b-a827-788687faac93	پیاده‌سازی بخش اصلی	39	37	2026-07-15	submitted	\N	\N	30b6ebd9-41fa-44f0-89ad-9a2666b85e79	2026-07-20 09:22:03.794401+00	2026-07-20 09:22:03.794401+00
1d224113-52fd-42ec-a3d9-ee5e9338d4af	9f6a9fc2-b1e0-4dd7-9c14-eec8df132beb	39f6a330-2d20-4870-ba2a-2457ecb3df8d	پیاده‌سازی بخش اصلی	123	32	2026-06-22	approved	7891652b-f708-4834-90b3-b7e06f9dd5ab	\N	e6acf62e-de97-4554-8676-d8784084d6a2	2026-07-20 09:22:03.794401+00	2026-07-20 09:22:03.794401+00
1d224113-52fd-42ec-a3d9-ee5e9338d4af	9f6a9fc2-b1e0-4dd7-9c14-eec8df132beb	39f6a330-2d20-4870-ba2a-2457ecb3df8d	مستندسازی و نهایی‌سازی	217	58	2026-06-24	approved	7891652b-f708-4834-90b3-b7e06f9dd5ab	\N	addb94e6-cc1f-40a3-a093-0ebfac82bd40	2026-07-20 09:22:03.794401+00	2026-07-20 09:22:03.794401+00
1d224113-52fd-42ec-a3d9-ee5e9338d4af	9f6a9fc2-b1e0-4dd7-9c14-eec8df132beb	39f6a330-2d20-4870-ba2a-2457ecb3df8d	تست و اطمینان از عملکرد صحیح	158	100	2026-06-26	approved	7891652b-f708-4834-90b3-b7e06f9dd5ab	\N	984dc736-4b9b-4619-811b-c6d3bfdf5377	2026-07-20 09:22:03.794401+00	2026-07-20 09:22:03.794401+00
1d224113-52fd-42ec-a3d9-ee5e9338d4af	b2e4a4fa-c2c5-49e4-a5dc-efaf06290452	39f6a330-2d20-4870-ba2a-2457ecb3df8d	پیشرفت اولیه و بررسی نیازمندی‌ها	199	27	2026-07-16	approved	7891652b-f708-4834-90b3-b7e06f9dd5ab	\N	27ecdd65-7056-4193-80b9-a727ffee99c9	2026-07-20 09:22:03.794401+00	2026-07-20 09:22:03.794401+00
1d224113-52fd-42ec-a3d9-ee5e9338d4af	1982e568-3559-4cb8-bdd5-30ec0252cbbb	81977026-b6d9-4183-92f3-63f6484c7ae5	تست و اطمینان از عملکرد صحیح	70	25	2026-06-25	approved	7891652b-f708-4834-90b3-b7e06f9dd5ab	\N	f7f598ad-f734-4a5a-961a-29c87c52feeb	2026-07-20 09:22:03.794401+00	2026-07-20 09:22:03.794401+00
1d224113-52fd-42ec-a3d9-ee5e9338d4af	1982e568-3559-4cb8-bdd5-30ec0252cbbb	81977026-b6d9-4183-92f3-63f6484c7ae5	تست و اطمینان از عملکرد صحیح	121	42	2026-06-27	approved	7891652b-f708-4834-90b3-b7e06f9dd5ab	\N	9f8c2342-18ca-4c0b-ab15-6fff7ff31e17	2026-07-20 09:22:03.794401+00	2026-07-20 09:22:03.794401+00
1d224113-52fd-42ec-a3d9-ee5e9338d4af	6b0d287c-8384-4d6b-b264-25f94a4c0800	39f6a330-2d20-4870-ba2a-2457ecb3df8d	پیاده‌سازی بخش اصلی	46	28	2026-07-06	approved	7891652b-f708-4834-90b3-b7e06f9dd5ab	\N	d09cbcf3-a3ac-430c-9337-30aa05080fbf	2026-07-20 09:22:03.794401+00	2026-07-20 09:22:03.794401+00
1d224113-52fd-42ec-a3d9-ee5e9338d4af	6b0d287c-8384-4d6b-b264-25f94a4c0800	39f6a330-2d20-4870-ba2a-2457ecb3df8d	پیاده‌سازی بخش اصلی	40	52	2026-07-09	approved	7891652b-f708-4834-90b3-b7e06f9dd5ab	\N	41b986e0-fe40-4404-9156-c4d1c6ff542a	2026-07-20 09:22:03.794401+00	2026-07-20 09:22:03.794401+00
1d224113-52fd-42ec-a3d9-ee5e9338d4af	e5972c36-cf09-462c-a08d-d67b4b82da1b	57b624b6-2a61-45ab-95e9-0d4965be1a7e	تست و اطمینان از عملکرد صحیح	41	21	2026-07-16	approved	7891652b-f708-4834-90b3-b7e06f9dd5ab	\N	6d0fc39b-71f5-4fd3-a998-8ca4b5ed7f0e	2026-07-20 09:22:03.794401+00	2026-07-20 09:22:03.794401+00
1d224113-52fd-42ec-a3d9-ee5e9338d4af	e5972c36-cf09-462c-a08d-d67b4b82da1b	57b624b6-2a61-45ab-95e9-0d4965be1a7e	مستندسازی و نهایی‌سازی	192	56	2026-07-16	approved	7891652b-f708-4834-90b3-b7e06f9dd5ab	\N	17c940a3-edd9-4a32-bf72-10c82a5fdc45	2026-07-20 09:22:03.794401+00	2026-07-20 09:22:03.794401+00
1d224113-52fd-42ec-a3d9-ee5e9338d4af	e5972c36-cf09-462c-a08d-d67b4b82da1b	57b624b6-2a61-45ab-95e9-0d4965be1a7e	مستندسازی و نهایی‌سازی	74	96	2026-07-16	approved	7891652b-f708-4834-90b3-b7e06f9dd5ab	\N	ff98206d-1bbb-418a-9e3b-9414c8b95993	2026-07-20 09:22:03.794401+00	2026-07-20 09:22:03.794401+00
1d224113-52fd-42ec-a3d9-ee5e9338d4af	e8f07bec-d889-43a4-903d-0cbb8e93219c	81977026-b6d9-4183-92f3-63f6484c7ae5	پیشرفت اولیه و بررسی نیازمندی‌ها	162	28	2026-07-16	approved	7891652b-f708-4834-90b3-b7e06f9dd5ab	\N	9d313ecc-49b8-4eae-89ca-01388be668c4	2026-07-20 09:22:03.794401+00	2026-07-20 09:22:03.794401+00
1d224113-52fd-42ec-a3d9-ee5e9338d4af	e8f07bec-d889-43a4-903d-0cbb8e93219c	81977026-b6d9-4183-92f3-63f6484c7ae5	پیاده‌سازی بخش اصلی	162	64	2026-07-16	submitted	\N	\N	fa1c43d6-da17-42cd-ae41-f4c500c64e0e	2026-07-20 09:22:03.794401+00	2026-07-20 09:22:03.794401+00
1d224113-52fd-42ec-a3d9-ee5e9338d4af	e8f07bec-d889-43a4-903d-0cbb8e93219c	81977026-b6d9-4183-92f3-63f6484c7ae5	رفع اشکالات و بازبینی	154	100	2026-07-16	submitted	\N	\N	c9b6cc0a-b809-4e85-b6ce-3d35c5e37490	2026-07-20 09:22:03.794401+00	2026-07-20 09:22:03.794401+00
1d224113-52fd-42ec-a3d9-ee5e9338d4af	e8f07bec-d889-43a4-903d-0cbb8e93219c	81977026-b6d9-4183-92f3-63f6484c7ae5	پیاده‌سازی بخش اصلی	142	100	2026-07-16	approved	7891652b-f708-4834-90b3-b7e06f9dd5ab	\N	d70a5905-720f-4c20-9d8c-986e84976b61	2026-07-20 09:22:03.794401+00	2026-07-20 09:22:03.794401+00
1d224113-52fd-42ec-a3d9-ee5e9338d4af	89a2ff8d-9d77-459e-b131-6c8505b9f4bd	7891652b-f708-4834-90b3-b7e06f9dd5ab	مستندسازی و نهایی‌سازی	194	28	2026-07-02	approved	7891652b-f708-4834-90b3-b7e06f9dd5ab	\N	02e7cea0-8cc3-4247-8d9f-756db63a9e90	2026-07-20 09:22:03.794401+00	2026-07-20 09:22:03.794401+00
1d224113-52fd-42ec-a3d9-ee5e9338d4af	89a2ff8d-9d77-459e-b131-6c8505b9f4bd	7891652b-f708-4834-90b3-b7e06f9dd5ab	پیاده‌سازی بخش اصلی	77	50	2026-07-04	approved	7891652b-f708-4834-90b3-b7e06f9dd5ab	\N	63ed722d-4cc0-44e5-83df-8afbfbc6b6bb	2026-07-20 09:22:03.794401+00	2026-07-20 09:22:03.794401+00
1d224113-52fd-42ec-a3d9-ee5e9338d4af	396a334e-f661-424c-811f-2d5bdd493292	57b624b6-2a61-45ab-95e9-0d4965be1a7e	پیاده‌سازی بخش اصلی	136	30	2026-07-08	approved	7891652b-f708-4834-90b3-b7e06f9dd5ab	\N	545fe40f-a11b-43fc-bccd-bd1c7968cd7e	2026-07-20 09:22:03.794401+00	2026-07-20 09:22:03.794401+00
1d224113-52fd-42ec-a3d9-ee5e9338d4af	396a334e-f661-424c-811f-2d5bdd493292	57b624b6-2a61-45ab-95e9-0d4965be1a7e	تست و اطمینان از عملکرد صحیح	202	70	2026-07-09	approved	7891652b-f708-4834-90b3-b7e06f9dd5ab	\N	90c5177e-b9e0-4933-8974-b0e0e685aa3e	2026-07-20 09:22:03.794401+00	2026-07-20 09:22:03.794401+00
1d224113-52fd-42ec-a3d9-ee5e9338d4af	396a334e-f661-424c-811f-2d5bdd493292	57b624b6-2a61-45ab-95e9-0d4965be1a7e	پیاده‌سازی بخش اصلی	181	75	2026-07-16	approved	7891652b-f708-4834-90b3-b7e06f9dd5ab	\N	e993caed-4c54-46c9-95a4-e738d0ad9b23	2026-07-20 09:22:03.794401+00	2026-07-20 09:22:03.794401+00
1d224113-52fd-42ec-a3d9-ee5e9338d4af	d4b4aab1-c47c-4498-898a-9860226d1cc1	57b624b6-2a61-45ab-95e9-0d4965be1a7e	پیاده‌سازی بخش اصلی	176	38	2026-07-02	approved	7891652b-f708-4834-90b3-b7e06f9dd5ab	\N	e2a29690-fd26-49c7-ba85-3103fd3b6fe0	2026-07-20 09:22:03.794401+00	2026-07-20 09:22:03.794401+00
1d224113-52fd-42ec-a3d9-ee5e9338d4af	d4b4aab1-c47c-4498-898a-9860226d1cc1	57b624b6-2a61-45ab-95e9-0d4965be1a7e	مستندسازی و نهایی‌سازی	40	76	2026-07-04	approved	7891652b-f708-4834-90b3-b7e06f9dd5ab	\N	0b973771-b937-4a32-a003-a481cf5ba474	2026-07-20 09:22:03.794401+00	2026-07-20 09:22:03.794401+00
1d224113-52fd-42ec-a3d9-ee5e9338d4af	d4b4aab1-c47c-4498-898a-9860226d1cc1	57b624b6-2a61-45ab-95e9-0d4965be1a7e	رفع اشکالات و بازبینی	76	100	2026-07-06	approved	7891652b-f708-4834-90b3-b7e06f9dd5ab	\N	dfbc9d82-8f53-4ba9-a572-e857508785ae	2026-07-20 09:22:03.794401+00	2026-07-20 09:22:03.794401+00
1d224113-52fd-42ec-a3d9-ee5e9338d4af	d4b4aab1-c47c-4498-898a-9860226d1cc1	57b624b6-2a61-45ab-95e9-0d4965be1a7e	مستندسازی و نهایی‌سازی	193	80	2026-07-14	approved	7891652b-f708-4834-90b3-b7e06f9dd5ab	\N	e751d75f-a31c-4ff0-a6a9-1105f2fddded	2026-07-20 09:22:03.794401+00	2026-07-20 09:22:03.794401+00
1d224113-52fd-42ec-a3d9-ee5e9338d4af	874fde8e-47c3-47cb-b8d6-ef6e9b70af65	39f6a330-2d20-4870-ba2a-2457ecb3df8d	پیاده‌سازی بخش اصلی	144	39	2026-07-16	approved	7891652b-f708-4834-90b3-b7e06f9dd5ab	\N	0c3f00c5-9d13-4be2-ba42-26b596dad3c0	2026-07-20 09:22:03.794401+00	2026-07-20 09:22:03.794401+00
1d224113-52fd-42ec-a3d9-ee5e9338d4af	874fde8e-47c3-47cb-b8d6-ef6e9b70af65	39f6a330-2d20-4870-ba2a-2457ecb3df8d	تست و اطمینان از عملکرد صحیح	73	54	2026-07-16	approved	7891652b-f708-4834-90b3-b7e06f9dd5ab	\N	dae5c431-4154-43e3-89f8-50ac293cbdba	2026-07-20 09:22:03.794401+00	2026-07-20 09:22:03.794401+00
1d224113-52fd-42ec-a3d9-ee5e9338d4af	874fde8e-47c3-47cb-b8d6-ef6e9b70af65	39f6a330-2d20-4870-ba2a-2457ecb3df8d	مستندسازی و نهایی‌سازی	66	100	2026-07-16	approved	7891652b-f708-4834-90b3-b7e06f9dd5ab	\N	e74c41b4-580f-4c66-9a32-1baf3a7c6c21	2026-07-20 09:22:03.794401+00	2026-07-20 09:22:03.794401+00
1d224113-52fd-42ec-a3d9-ee5e9338d4af	56e0b273-4fe4-4b89-93f4-95ac8fbafc38	726b1bd0-c51d-4f38-9e37-f4c46a258d1b	رفع اشکالات و بازبینی	146	39	2026-07-16	approved	7891652b-f708-4834-90b3-b7e06f9dd5ab	\N	8b43a9c2-2d4e-4791-a719-69687149f242	2026-07-20 09:22:03.794401+00	2026-07-20 09:22:03.794401+00
1d224113-52fd-42ec-a3d9-ee5e9338d4af	56e0b273-4fe4-4b89-93f4-95ac8fbafc38	726b1bd0-c51d-4f38-9e37-f4c46a258d1b	تست و اطمینان از عملکرد صحیح	63	46	2026-07-16	approved	7891652b-f708-4834-90b3-b7e06f9dd5ab	\N	9009d8bb-905d-4f26-bb50-f09ea146f4e0	2026-07-20 09:22:03.794401+00	2026-07-20 09:22:03.794401+00
1d224113-52fd-42ec-a3d9-ee5e9338d4af	d26b38e8-6583-4897-9771-8483382a18a8	81977026-b6d9-4183-92f3-63f6484c7ae5	مستندسازی و نهایی‌سازی	205	33	2026-07-11	approved	7891652b-f708-4834-90b3-b7e06f9dd5ab	\N	ab6eaf99-3398-46a8-81b9-91579ddfedc2	2026-07-20 09:22:03.794401+00	2026-07-20 09:22:03.794401+00
1d224113-52fd-42ec-a3d9-ee5e9338d4af	8d3f66b8-f22a-4902-b4c2-8f73d9756a98	726b1bd0-c51d-4f38-9e37-f4c46a258d1b	پیاده‌سازی بخش اصلی	151	39	2026-07-09	approved	7891652b-f708-4834-90b3-b7e06f9dd5ab	\N	8282fa41-80b9-45f6-b65c-bc5e02b4e001	2026-07-20 09:22:03.794401+00	2026-07-20 09:22:03.794401+00
1d224113-52fd-42ec-a3d9-ee5e9338d4af	8d3f66b8-f22a-4902-b4c2-8f73d9756a98	726b1bd0-c51d-4f38-9e37-f4c46a258d1b	مستندسازی و نهایی‌سازی	158	46	2026-07-10	approved	7891652b-f708-4834-90b3-b7e06f9dd5ab	\N	5791b655-4fc3-4d6c-878a-ee008bb30dce	2026-07-20 09:22:03.794401+00	2026-07-20 09:22:03.794401+00
1d224113-52fd-42ec-a3d9-ee5e9338d4af	770039db-441f-4cc2-b605-4e0cb0f151ce	7891652b-f708-4834-90b3-b7e06f9dd5ab	مستندسازی و نهایی‌سازی	168	20	2026-07-16	approved	7891652b-f708-4834-90b3-b7e06f9dd5ab	\N	10caadac-e481-40b3-8a2d-5d2204860b3d	2026-07-20 09:22:03.794401+00	2026-07-20 09:22:03.794401+00
1d224113-52fd-42ec-a3d9-ee5e9338d4af	5a41576c-95d9-4efb-a854-7b828fa94200	57b624b6-2a61-45ab-95e9-0d4965be1a7e	پیشرفت اولیه و بررسی نیازمندی‌ها	208	36	2026-07-15	approved	7891652b-f708-4834-90b3-b7e06f9dd5ab	\N	0a16eadc-8493-46ac-a203-0c680c70789f	2026-07-20 09:22:03.794401+00	2026-07-20 09:22:03.794401+00
1d224113-52fd-42ec-a3d9-ee5e9338d4af	5a41576c-95d9-4efb-a854-7b828fa94200	57b624b6-2a61-45ab-95e9-0d4965be1a7e	تست و اطمینان از عملکرد صحیح	232	64	2026-07-16	approved	7891652b-f708-4834-90b3-b7e06f9dd5ab	\N	2bb131c1-2ee4-42be-a9f2-1daacbb84ec2	2026-07-20 09:22:03.794401+00	2026-07-20 09:22:03.794401+00
1d224113-52fd-42ec-a3d9-ee5e9338d4af	5a41576c-95d9-4efb-a854-7b828fa94200	57b624b6-2a61-45ab-95e9-0d4965be1a7e	مستندسازی و نهایی‌سازی	55	99	2026-07-16	approved	7891652b-f708-4834-90b3-b7e06f9dd5ab	\N	66a77af0-21a5-40f3-bf52-065af682d18d	2026-07-20 09:22:03.794401+00	2026-07-20 09:22:03.794401+00
1d224113-52fd-42ec-a3d9-ee5e9338d4af	5a41576c-95d9-4efb-a854-7b828fa94200	57b624b6-2a61-45ab-95e9-0d4965be1a7e	پیاده‌سازی بخش اصلی	51	100	2026-07-16	approved	7891652b-f708-4834-90b3-b7e06f9dd5ab	\N	25e9f18b-84e1-4970-b5bc-d80759406d33	2026-07-20 09:22:03.794401+00	2026-07-20 09:22:03.794401+00
1d224113-52fd-42ec-a3d9-ee5e9338d4af	0783419f-5ca3-4fc7-bb09-0501a6ea5c37	39f6a330-2d20-4870-ba2a-2457ecb3df8d	پیشرفت اولیه و بررسی نیازمندی‌ها	177	36	2026-06-17	approved	7891652b-f708-4834-90b3-b7e06f9dd5ab	\N	6ae31b2d-1422-40ef-88be-da481aeb0119	2026-07-20 09:22:03.794401+00	2026-07-20 09:22:03.794401+00
1d224113-52fd-42ec-a3d9-ee5e9338d4af	0783419f-5ca3-4fc7-bb09-0501a6ea5c37	39f6a330-2d20-4870-ba2a-2457ecb3df8d	تست و اطمینان از عملکرد صحیح	197	52	2026-06-18	approved	7891652b-f708-4834-90b3-b7e06f9dd5ab	\N	b1eda360-bcf0-4f87-abc9-4188f98eb4df	2026-07-20 09:22:03.794401+00	2026-07-20 09:22:03.794401+00
1d224113-52fd-42ec-a3d9-ee5e9338d4af	0783419f-5ca3-4fc7-bb09-0501a6ea5c37	39f6a330-2d20-4870-ba2a-2457ecb3df8d	پیشرفت اولیه و بررسی نیازمندی‌ها	69	99	2026-06-23	approved	7891652b-f708-4834-90b3-b7e06f9dd5ab	\N	940d466c-c5b3-4a32-a258-629cc11dc0a0	2026-07-20 09:22:03.794401+00	2026-07-20 09:22:03.794401+00
1d224113-52fd-42ec-a3d9-ee5e9338d4af	0783419f-5ca3-4fc7-bb09-0501a6ea5c37	39f6a330-2d20-4870-ba2a-2457ecb3df8d	مستندسازی و نهایی‌سازی	138	100	2026-06-26	approved	7891652b-f708-4834-90b3-b7e06f9dd5ab	\N	96a66b11-ba8f-4ea5-9581-92e3104e3f30	2026-07-20 09:22:03.794401+00	2026-07-20 09:22:03.794401+00
1d224113-52fd-42ec-a3d9-ee5e9338d4af	8e76c7d6-3833-4fe0-818a-a13651955628	7891652b-f708-4834-90b3-b7e06f9dd5ab	تست و اطمینان از عملکرد صحیح	223	26	2026-06-23	approved	7891652b-f708-4834-90b3-b7e06f9dd5ab	\N	5ee1fd5a-824f-4bb3-bfce-24b2426cfe8b	2026-07-20 09:22:03.794401+00	2026-07-20 09:22:03.794401+00
1d224113-52fd-42ec-a3d9-ee5e9338d4af	8e76c7d6-3833-4fe0-818a-a13651955628	7891652b-f708-4834-90b3-b7e06f9dd5ab	مستندسازی و نهایی‌سازی	230	74	2026-06-27	approved	7891652b-f708-4834-90b3-b7e06f9dd5ab	\N	b1dce4af-6471-496c-80a7-398defda43e9	2026-07-20 09:22:03.794401+00	2026-07-20 09:22:03.794401+00
1d224113-52fd-42ec-a3d9-ee5e9338d4af	8e76c7d6-3833-4fe0-818a-a13651955628	7891652b-f708-4834-90b3-b7e06f9dd5ab	پیاده‌سازی بخش اصلی	124	100	2026-07-01	approved	7891652b-f708-4834-90b3-b7e06f9dd5ab	\N	beae0f72-8523-4c16-a1a0-17bc3caf1add	2026-07-20 09:22:03.794401+00	2026-07-20 09:22:03.794401+00
1d224113-52fd-42ec-a3d9-ee5e9338d4af	dd8fc3d0-2e15-4138-81f3-664105bafaa5	3623572f-edd3-4d8b-a827-788687faac93	رفع اشکالات و بازبینی	177	31	2026-07-16	approved	7891652b-f708-4834-90b3-b7e06f9dd5ab	\N	2f3239eb-c898-4cee-a836-c35685e201ce	2026-07-20 09:22:03.794401+00	2026-07-20 09:22:03.794401+00
1d224113-52fd-42ec-a3d9-ee5e9338d4af	dd8fc3d0-2e15-4138-81f3-664105bafaa5	3623572f-edd3-4d8b-a827-788687faac93	پیاده‌سازی بخش اصلی	198	46	2026-07-16	approved	7891652b-f708-4834-90b3-b7e06f9dd5ab	\N	8bc60551-4c09-405c-a5d9-4c45f087edb7	2026-07-20 09:22:03.794401+00	2026-07-20 09:22:03.794401+00
1d224113-52fd-42ec-a3d9-ee5e9338d4af	dd8fc3d0-2e15-4138-81f3-664105bafaa5	3623572f-edd3-4d8b-a827-788687faac93	تست و اطمینان از عملکرد صحیح	230	75	2026-07-16	approved	7891652b-f708-4834-90b3-b7e06f9dd5ab	\N	649f692a-de72-49c9-9ede-b57686478d29	2026-07-20 09:22:03.794401+00	2026-07-20 09:22:03.794401+00
1d224113-52fd-42ec-a3d9-ee5e9338d4af	dd8fc3d0-2e15-4138-81f3-664105bafaa5	3623572f-edd3-4d8b-a827-788687faac93	پیاده‌سازی بخش اصلی	160	100	2026-07-16	approved	7891652b-f708-4834-90b3-b7e06f9dd5ab	\N	31a15145-ed05-47f8-98a3-33670694d425	2026-07-20 09:22:03.794401+00	2026-07-20 09:22:03.794401+00
1d224113-52fd-42ec-a3d9-ee5e9338d4af	b29f012c-4631-479a-930b-5c1b65d98aa3	81977026-b6d9-4183-92f3-63f6484c7ae5	پیاده‌سازی بخش اصلی	129	40	2026-07-12	approved	7891652b-f708-4834-90b3-b7e06f9dd5ab	\N	c0592a91-a97f-4300-a4e8-50617d018441	2026-07-20 09:22:03.794401+00	2026-07-20 09:22:03.794401+00
1d224113-52fd-42ec-a3d9-ee5e9338d4af	b29f012c-4631-479a-930b-5c1b65d98aa3	81977026-b6d9-4183-92f3-63f6484c7ae5	پیشرفت اولیه و بررسی نیازمندی‌ها	240	48	2026-07-13	approved	7891652b-f708-4834-90b3-b7e06f9dd5ab	\N	6a135cad-9632-4320-b4c6-0d1dace83aee	2026-07-20 09:22:03.794401+00	2026-07-20 09:22:03.794401+00
1d224113-52fd-42ec-a3d9-ee5e9338d4af	b29f012c-4631-479a-930b-5c1b65d98aa3	81977026-b6d9-4183-92f3-63f6484c7ae5	مستندسازی و نهایی‌سازی	141	66	2026-07-16	approved	7891652b-f708-4834-90b3-b7e06f9dd5ab	\N	a70882ac-9e4c-4b0f-97f6-dee05fdd326c	2026-07-20 09:22:03.794401+00	2026-07-20 09:22:03.794401+00
1d224113-52fd-42ec-a3d9-ee5e9338d4af	dbb7ceb3-b66b-4ee8-957d-e9a3a736af99	fc439dd8-ff4f-4760-bcc2-e3cddcba6888	پیاده‌سازی بخش اصلی	124	22	2026-07-16	approved	7891652b-f708-4834-90b3-b7e06f9dd5ab	\N	7aac73af-7134-41c6-a33f-8a29230874ec	2026-07-20 09:22:03.794401+00	2026-07-20 09:22:03.794401+00
1d224113-52fd-42ec-a3d9-ee5e9338d4af	19fd8715-62be-4642-aeab-9b13cd01cc52	57b624b6-2a61-45ab-95e9-0d4965be1a7e	تست و اطمینان از عملکرد صحیح	187	40	2026-07-08	approved	7891652b-f708-4834-90b3-b7e06f9dd5ab	\N	065a3082-f1ea-446e-9057-a84442c5b3c2	2026-07-20 09:22:03.794401+00	2026-07-20 09:22:03.794401+00
1d224113-52fd-42ec-a3d9-ee5e9338d4af	23d9de8d-2c9a-4a22-9a1a-ebef6b86bf2b	3623572f-edd3-4d8b-a827-788687faac93	پیاده‌سازی بخش اصلی	193	35	2026-07-16	submitted	\N	\N	4956bb82-bfc7-42c4-a597-fa2f5cdd2f20	2026-07-20 09:22:03.794401+00	2026-07-20 09:22:03.794401+00
1d224113-52fd-42ec-a3d9-ee5e9338d4af	23d9de8d-2c9a-4a22-9a1a-ebef6b86bf2b	3623572f-edd3-4d8b-a827-788687faac93	مستندسازی و نهایی‌سازی	103	52	2026-07-16	approved	7891652b-f708-4834-90b3-b7e06f9dd5ab	\N	fd90fcd4-89d7-421e-b5cc-87acb7f6a08d	2026-07-20 09:22:03.794401+00	2026-07-20 09:22:03.794401+00
1d224113-52fd-42ec-a3d9-ee5e9338d4af	23d9de8d-2c9a-4a22-9a1a-ebef6b86bf2b	3623572f-edd3-4d8b-a827-788687faac93	مستندسازی و نهایی‌سازی	162	81	2026-07-16	submitted	\N	\N	94be3797-e5dd-4471-9722-97434d5942a4	2026-07-20 09:22:03.794401+00	2026-07-20 09:22:03.794401+00
1d224113-52fd-42ec-a3d9-ee5e9338d4af	39eafe94-4c3e-4bca-85e2-84d53c0f83bb	39f6a330-2d20-4870-ba2a-2457ecb3df8d	رفع اشکالات و بازبینی	91	40	2026-07-16	approved	7891652b-f708-4834-90b3-b7e06f9dd5ab	\N	31e08095-7b58-4129-9ecd-e54c86cba641	2026-07-20 09:22:03.794401+00	2026-07-20 09:22:03.794401+00
1d224113-52fd-42ec-a3d9-ee5e9338d4af	39eafe94-4c3e-4bca-85e2-84d53c0f83bb	39f6a330-2d20-4870-ba2a-2457ecb3df8d	پیاده‌سازی بخش اصلی	52	56	2026-07-16	approved	7891652b-f708-4834-90b3-b7e06f9dd5ab	\N	69310157-43c0-4dd3-94f0-b0f093fbb7fe	2026-07-20 09:22:03.794401+00	2026-07-20 09:22:03.794401+00
1d224113-52fd-42ec-a3d9-ee5e9338d4af	e0724e21-69c6-4ec6-8ad6-b8ff1e1f4d74	3623572f-edd3-4d8b-a827-788687faac93	تست و اطمینان از عملکرد صحیح	180	26	2026-07-02	approved	7891652b-f708-4834-90b3-b7e06f9dd5ab	\N	718cd88b-c1e1-498d-8683-424fbcb3debe	2026-07-20 09:22:03.794401+00	2026-07-20 09:22:03.794401+00
1d224113-52fd-42ec-a3d9-ee5e9338d4af	e0724e21-69c6-4ec6-8ad6-b8ff1e1f4d74	3623572f-edd3-4d8b-a827-788687faac93	پیشرفت اولیه و بررسی نیازمندی‌ها	53	74	2026-07-03	submitted	\N	\N	2feff5c7-8cd5-40d0-b540-ae920962c55c	2026-07-20 09:22:03.794401+00	2026-07-20 09:22:03.794401+00
1d224113-52fd-42ec-a3d9-ee5e9338d4af	e0724e21-69c6-4ec6-8ad6-b8ff1e1f4d74	3623572f-edd3-4d8b-a827-788687faac93	مستندسازی و نهایی‌سازی	179	93	2026-07-08	submitted	\N	\N	4701e031-17bc-4d85-b7a6-9cf9ae1e60a9	2026-07-20 09:22:03.794401+00	2026-07-20 09:22:03.794401+00
1d224113-52fd-42ec-a3d9-ee5e9338d4af	e0724e21-69c6-4ec6-8ad6-b8ff1e1f4d74	3623572f-edd3-4d8b-a827-788687faac93	رفع اشکالات و بازبینی	87	100	2026-07-11	submitted	\N	\N	e12d57bf-9743-48b5-8197-b2fba5fc6262	2026-07-20 09:22:03.794401+00	2026-07-20 09:22:03.794401+00
1d224113-52fd-42ec-a3d9-ee5e9338d4af	62658005-b240-4fd4-88bb-55a72d231297	39f6a330-2d20-4870-ba2a-2457ecb3df8d	مستندسازی و نهایی‌سازی	31	28	2026-07-09	submitted	\N	\N	e4b63010-5ca0-4fb3-9087-a011cb79aed4	2026-07-20 09:22:03.794401+00	2026-07-20 09:22:03.794401+00
1d224113-52fd-42ec-a3d9-ee5e9338d4af	62658005-b240-4fd4-88bb-55a72d231297	39f6a330-2d20-4870-ba2a-2457ecb3df8d	پیشرفت اولیه و بررسی نیازمندی‌ها	173	44	2026-07-11	approved	7891652b-f708-4834-90b3-b7e06f9dd5ab	\N	776eda96-d36d-45b3-81f6-40229612c04a	2026-07-20 09:22:03.794401+00	2026-07-20 09:22:03.794401+00
1d224113-52fd-42ec-a3d9-ee5e9338d4af	f2ee974e-4ecf-46f2-b9b2-983c9f119cb7	3623572f-edd3-4d8b-a827-788687faac93	پیشرفت اولیه و بررسی نیازمندی‌ها	235	36	2026-07-16	approved	7891652b-f708-4834-90b3-b7e06f9dd5ab	\N	7dd8ca0d-5f16-4d2d-8dbb-0c34f227dab3	2026-07-20 09:22:03.794401+00	2026-07-20 09:22:03.794401+00
1d224113-52fd-42ec-a3d9-ee5e9338d4af	f2ee974e-4ecf-46f2-b9b2-983c9f119cb7	3623572f-edd3-4d8b-a827-788687faac93	مستندسازی و نهایی‌سازی	238	76	2026-07-16	approved	7891652b-f708-4834-90b3-b7e06f9dd5ab	\N	52696cd0-c1cd-429e-915f-692bccf9c0cd	2026-07-20 09:22:03.794401+00	2026-07-20 09:22:03.794401+00
1d224113-52fd-42ec-a3d9-ee5e9338d4af	f2ee974e-4ecf-46f2-b9b2-983c9f119cb7	3623572f-edd3-4d8b-a827-788687faac93	تست و اطمینان از عملکرد صحیح	126	100	2026-07-16	approved	7891652b-f708-4834-90b3-b7e06f9dd5ab	\N	7fe7bd7c-dcf1-4b32-b2e0-6a8725a376a1	2026-07-20 09:22:03.794401+00	2026-07-20 09:22:03.794401+00
1d224113-52fd-42ec-a3d9-ee5e9338d4af	f96c62d1-cef6-434f-9969-a2fc15e1d12e	3623572f-edd3-4d8b-a827-788687faac93	تست و اطمینان از عملکرد صحیح	204	34	2026-07-15	submitted	\N	\N	a1c18737-66b8-4b4b-a4c3-05d331f0050e	2026-07-20 09:22:03.794401+00	2026-07-20 09:22:03.794401+00
1d224113-52fd-42ec-a3d9-ee5e9338d4af	f96c62d1-cef6-434f-9969-a2fc15e1d12e	3623572f-edd3-4d8b-a827-788687faac93	رفع اشکالات و بازبینی	47	64	2026-07-16	approved	7891652b-f708-4834-90b3-b7e06f9dd5ab	\N	5745ba15-1919-4d5f-9cc7-547580818bb4	2026-07-20 09:22:03.794401+00	2026-07-20 09:22:03.794401+00
1d224113-52fd-42ec-a3d9-ee5e9338d4af	f96c62d1-cef6-434f-9969-a2fc15e1d12e	3623572f-edd3-4d8b-a827-788687faac93	پیاده‌سازی بخش اصلی	234	90	2026-07-16	approved	7891652b-f708-4834-90b3-b7e06f9dd5ab	\N	e09e9d13-41cb-4821-8660-b0ee14404854	2026-07-20 09:22:03.794401+00	2026-07-20 09:22:03.794401+00
1d224113-52fd-42ec-a3d9-ee5e9338d4af	f96c62d1-cef6-434f-9969-a2fc15e1d12e	3623572f-edd3-4d8b-a827-788687faac93	مستندسازی و نهایی‌سازی	167	80	2026-07-16	submitted	\N	\N	88f541d6-f77f-4194-9b23-863858e8b23f	2026-07-20 09:22:03.794401+00	2026-07-20 09:22:03.794401+00
1d224113-52fd-42ec-a3d9-ee5e9338d4af	b247543e-fcf7-4120-b673-74f67ecc18ef	81977026-b6d9-4183-92f3-63f6484c7ae5	رفع اشکالات و بازبینی	53	32	2026-07-10	approved	7891652b-f708-4834-90b3-b7e06f9dd5ab	\N	787b9666-0acd-47f5-b62d-aa442d910e65	2026-07-20 09:22:03.794401+00	2026-07-20 09:22:03.794401+00
1d224113-52fd-42ec-a3d9-ee5e9338d4af	b247543e-fcf7-4120-b673-74f67ecc18ef	81977026-b6d9-4183-92f3-63f6484c7ae5	پیشرفت اولیه و بررسی نیازمندی‌ها	171	50	2026-07-13	approved	7891652b-f708-4834-90b3-b7e06f9dd5ab	\N	f4d3b518-db5b-4ef9-b31d-63665dfcc28b	2026-07-20 09:22:03.794401+00	2026-07-20 09:22:03.794401+00
1d224113-52fd-42ec-a3d9-ee5e9338d4af	b247543e-fcf7-4120-b673-74f67ecc18ef	81977026-b6d9-4183-92f3-63f6484c7ae5	رفع اشکالات و بازبینی	120	78	2026-07-16	approved	7891652b-f708-4834-90b3-b7e06f9dd5ab	\N	96dc0f2e-9ef8-4eef-b256-28627d2e6c92	2026-07-20 09:22:03.794401+00	2026-07-20 09:22:03.794401+00
1d224113-52fd-42ec-a3d9-ee5e9338d4af	1a7ffe5a-3df8-4d68-897f-9dd208c53776	39f6a330-2d20-4870-ba2a-2457ecb3df8d	پیاده‌سازی بخش اصلی	157	26	2026-07-16	approved	7891652b-f708-4834-90b3-b7e06f9dd5ab	\N	8a16d654-34e7-4e48-8d37-a41e54688cce	2026-07-20 09:22:03.794401+00	2026-07-20 09:22:03.794401+00
1d224113-52fd-42ec-a3d9-ee5e9338d4af	1a7ffe5a-3df8-4d68-897f-9dd208c53776	39f6a330-2d20-4870-ba2a-2457ecb3df8d	پیاده‌سازی بخش اصلی	97	52	2026-07-16	approved	7891652b-f708-4834-90b3-b7e06f9dd5ab	\N	e7cd992a-2729-4a2a-965b-6620158f0124	2026-07-20 09:22:03.794401+00	2026-07-20 09:22:03.794401+00
1d224113-52fd-42ec-a3d9-ee5e9338d4af	1a7ffe5a-3df8-4d68-897f-9dd208c53776	39f6a330-2d20-4870-ba2a-2457ecb3df8d	پیاده‌سازی بخش اصلی	93	100	2026-07-16	approved	7891652b-f708-4834-90b3-b7e06f9dd5ab	\N	e3edf4a2-1f6f-40f4-a1b0-61f651cac999	2026-07-20 09:22:03.794401+00	2026-07-20 09:22:03.794401+00
1d224113-52fd-42ec-a3d9-ee5e9338d4af	e641aa1c-3723-4bed-8f71-b2147f5171d9	81977026-b6d9-4183-92f3-63f6484c7ae5	پیشرفت اولیه و بررسی نیازمندی‌ها	60	22	2026-07-16	approved	7891652b-f708-4834-90b3-b7e06f9dd5ab	\N	551517d0-f1c2-4d9f-85ad-6c7ae6db9165	2026-07-20 09:22:03.794401+00	2026-07-20 09:22:03.794401+00
1d224113-52fd-42ec-a3d9-ee5e9338d4af	e641aa1c-3723-4bed-8f71-b2147f5171d9	81977026-b6d9-4183-92f3-63f6484c7ae5	مستندسازی و نهایی‌سازی	31	74	2026-07-16	approved	7891652b-f708-4834-90b3-b7e06f9dd5ab	\N	829a741c-67b8-4e5a-b6da-bf4e1a46c7e9	2026-07-20 09:22:03.794401+00	2026-07-20 09:22:03.794401+00
1d224113-52fd-42ec-a3d9-ee5e9338d4af	e641aa1c-3723-4bed-8f71-b2147f5171d9	81977026-b6d9-4183-92f3-63f6484c7ae5	تست و اطمینان از عملکرد صحیح	125	100	2026-07-16	approved	7891652b-f708-4834-90b3-b7e06f9dd5ab	\N	d27525ee-73c8-4929-b168-2a4234b257ee	2026-07-20 09:22:03.794401+00	2026-07-20 09:22:03.794401+00
1d224113-52fd-42ec-a3d9-ee5e9338d4af	2c7b24f0-1f0f-415f-a14e-0c5400652707	fc439dd8-ff4f-4760-bcc2-e3cddcba6888	مستندسازی و نهایی‌سازی	100	35	2026-07-16	approved	7891652b-f708-4834-90b3-b7e06f9dd5ab	\N	500dbdc3-a130-4d70-8707-0c767a43761a	2026-07-20 09:22:03.794401+00	2026-07-20 09:22:03.794401+00
1d224113-52fd-42ec-a3d9-ee5e9338d4af	2c7b24f0-1f0f-415f-a14e-0c5400652707	fc439dd8-ff4f-4760-bcc2-e3cddcba6888	مستندسازی و نهایی‌سازی	101	64	2026-07-16	approved	7891652b-f708-4834-90b3-b7e06f9dd5ab	\N	5cf01f14-d8f8-4ad8-91eb-3b890cf9b4df	2026-07-20 09:22:03.794401+00	2026-07-20 09:22:03.794401+00
1d224113-52fd-42ec-a3d9-ee5e9338d4af	2c7b24f0-1f0f-415f-a14e-0c5400652707	fc439dd8-ff4f-4760-bcc2-e3cddcba6888	مستندسازی و نهایی‌سازی	62	63	2026-07-16	approved	7891652b-f708-4834-90b3-b7e06f9dd5ab	\N	55a823bf-1d96-4d79-8fc1-39432afbd183	2026-07-20 09:22:03.794401+00	2026-07-20 09:22:03.794401+00
1d224113-52fd-42ec-a3d9-ee5e9338d4af	21d8b389-f887-4d50-b9b2-855ccaeaeccf	3623572f-edd3-4d8b-a827-788687faac93	پیشرفت اولیه و بررسی نیازمندی‌ها	158	31	2026-07-16	submitted	\N	\N	3e16175f-621b-4711-b3fa-3dea39a00882	2026-07-20 09:22:03.794401+00	2026-07-20 09:22:03.794401+00
1d224113-52fd-42ec-a3d9-ee5e9338d4af	21d8b389-f887-4d50-b9b2-855ccaeaeccf	3623572f-edd3-4d8b-a827-788687faac93	پیاده‌سازی بخش اصلی	147	46	2026-07-16	submitted	\N	\N	10bd1d3f-8f6e-42de-94f3-6f81d77f34ac	2026-07-20 09:22:03.794401+00	2026-07-20 09:22:03.794401+00
1d224113-52fd-42ec-a3d9-ee5e9338d4af	21d8b389-f887-4d50-b9b2-855ccaeaeccf	3623572f-edd3-4d8b-a827-788687faac93	پیشرفت اولیه و بررسی نیازمندی‌ها	33	78	2026-07-16	approved	7891652b-f708-4834-90b3-b7e06f9dd5ab	\N	a39d1f60-4365-4c9b-8b33-0a9ea72ae6ac	2026-07-20 09:22:03.794401+00	2026-07-20 09:22:03.794401+00
1d224113-52fd-42ec-a3d9-ee5e9338d4af	21d8b389-f887-4d50-b9b2-855ccaeaeccf	3623572f-edd3-4d8b-a827-788687faac93	رفع اشکالات و بازبینی	122	100	2026-07-16	approved	7891652b-f708-4834-90b3-b7e06f9dd5ab	\N	28d2441a-659a-4395-a680-8889a12691f9	2026-07-20 09:22:03.794401+00	2026-07-20 09:22:03.794401+00
1d224113-52fd-42ec-a3d9-ee5e9338d4af	1b9015fe-8f2d-48ec-ba19-68e9b51d02c6	1bd96f4a-6acb-4464-8452-ca1d3114a328	تست نهایی	120	50	2026-07-15	approved	b3e7b1f6-d818-46bc-a98e-9f7048e16f8f	\N	7234ce3f-9db8-4122-8430-06e9fcf2a7db	2026-07-20 09:22:57.243373+00	2026-07-20 09:23:07.778503+00
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


