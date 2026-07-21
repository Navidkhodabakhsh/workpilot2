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
d817d362-a16b-49b6-a6a9-aaed37092f70	2026-07-21 12:23:05.653402+00	2026-07-21 12:23:05.653402+00	09100000001	$2b$12$oPNc92e.5I/zG/4qsNrggOnxINxc6DUx0A0s2NihY38hOwUnILCq2
ca463a2b-7f44-4111-a638-e8bc34a2eb8d	2026-07-21 12:23:05.653402+00	2026-07-21 12:23:05.653402+00	09111000000	$2b$12$IIWd2QStSXL/tH2jTWvv4OrXilfRojUO.YexamsKIPp5OHSHHe/qK
21520e01-4d42-4611-bca5-8b07e86755c2	2026-07-21 12:23:05.653402+00	2026-07-21 12:23:05.653402+00	09111000011	$2b$12$4tP5MXLzO80P0eJiujgAwuu2BAvJyiPtEmArwnv8DO1MnYpxoTM6i
ae52c012-e5ba-4f00-95d1-a941186744bd	2026-07-21 12:23:05.653402+00	2026-07-21 12:23:05.653402+00	09111000012	$2b$12$nfu9WjSaayGR1BNRQDl1fOU7QaNZjUC3jTiRY6dYHq.vDEsmlb5bi
8504ffd8-76b2-46c3-88b9-33994fad6f6f	2026-07-21 12:23:05.653402+00	2026-07-21 12:23:05.653402+00	09111000013	$2b$12$Fs2gbIKCximOT8hAhqK/O.STsV/3g8EIiP0BksUF/ZrBEccC6DNJe
8a20a6ca-77f1-4e63-954c-a9a165283bef	2026-07-21 12:23:05.653402+00	2026-07-21 12:23:05.653402+00	09111000014	$2b$12$PPntcIaFqZBiotBc7z3UvunK.7N3Ga.RtDZwYu1gu1ANgsn7uHtt6
3c56b23e-3994-4315-9abe-d4a0bdb8b096	2026-07-21 12:23:05.653402+00	2026-07-21 12:23:05.653402+00	09111000015	$2b$12$LNH.F3rhLRtBavvY4AbU5OtZQn7EDYWdrJ7d6u/DXVcW73VG880TO
5afcb24c-133b-46b6-8615-d69e266bc233	2026-07-21 12:23:05.653402+00	2026-07-21 12:23:05.653402+00	09111000016	$2b$12$dkBaD2xKe3yWiU78UJj2jubQdP5Ym6sWYHhs4Oeaey5So2Y1mpv8m
556bb4d3-9c73-45e8-b8d2-77afd7184b7a	2026-07-21 12:23:05.653402+00	2026-07-21 12:23:05.653402+00	09121000100	$2b$12$cfUfh8D4ImDh6MH25KXyhuRnYE7/FMt9jOx20R776NQC5HzZ5omG.
401ceb0c-1fca-45f6-ba52-20850f10c38c	2026-07-21 12:23:05.653402+00	2026-07-21 12:23:05.653402+00	09121000111	$2b$12$PLwMDsPTnKMyoVl0EhGLiul3.xUzWcpof/S9R/erVCMu/G9MPfJ9W
acffa94a-6195-417e-b0df-6df4a5ffd80b	2026-07-21 12:23:05.653402+00	2026-07-21 12:23:05.653402+00	09121000112	$2b$12$0MvLlu20pzl64Nk4LEQcEuLnw7P09bfAKnYum1boOI8WNjE9avAdW
46f5779e-941c-43b3-b11a-480740a9e007	2026-07-21 12:23:05.653402+00	2026-07-21 12:23:05.653402+00	09121000113	$2b$12$kanjJGUvcTswXKShGC5Qi.JAUvaYsUokJdh10sVRhRbgVZN8c4LfG
f6ab9826-ec45-4961-a642-0ee3bf00e58a	2026-07-21 12:23:05.653402+00	2026-07-21 12:23:05.653402+00	09121000114	$2b$12$4ZknHQyat9.zE2PJCdX7sOMqDvRW9MoMFQf/WwFGcx5YBh0kKNUXO
b30402cc-ab33-489a-8947-dd5c0754f8d1	2026-07-21 12:23:05.653402+00	2026-07-21 12:23:05.653402+00	09121000115	$2b$12$Q/F2Miwm5RPqmPfaBxtFfejrFqf.vEXnzbfvvj8iaCijFSnPoA9Ne
cf631693-3605-4012-980e-743cc9d5a209	2026-07-21 12:23:05.653402+00	2026-07-21 12:23:05.653402+00	09121000116	$2b$12$0dnTPvEscIjF/KUwqG0iwe1ZWfbV97.nZxd2fCHwd5OsDeiYVDTVO
41c66ae5-00f0-4248-a5d5-a4001c7047e1	2026-07-21 12:23:05.653402+00	2026-07-21 12:23:05.653402+00	09131000200	$2b$12$MYPbqCv7q.bYjl5jEwZgiuVUXYHb5UOUru7bZGSPHq.EBz0ZMkecW
d0c44ea5-94f1-4ad0-865a-d660006f7a7b	2026-07-21 12:23:05.653402+00	2026-07-21 12:23:05.653402+00	09131000211	$2b$12$UYQbuWQHY3kodJ/kBOHq3..2QH76IU4vWMHJgL.di/lXnGmPNDcQe
59ad45cb-ef50-46ae-ac4b-b32602ca8213	2026-07-21 12:23:05.653402+00	2026-07-21 12:23:05.653402+00	09131000212	$2b$12$GYOlWixcs3btdgZULl186uZoONgCgMGhPQs33WmWv/ApjCX3Zmsqq
cace6c02-5e04-4083-b05e-8eeb77cce34c	2026-07-21 12:23:05.653402+00	2026-07-21 12:23:05.653402+00	09131000213	$2b$12$Rxj2R/U832NEnxjL1NSYfebr/LkeZCgL0h6tmtpzO0PlNQMrIdHa2
8c85f4f1-412e-4869-aff0-f64200836c3a	2026-07-21 12:23:05.653402+00	2026-07-21 12:23:05.653402+00	09131000214	$2b$12$FyXY4WvMH9tm3PjdjacR.O3wwT4sE3kXSziPWa2JDd6R3Qf7XiQn6
23bceeb1-beb2-433b-9ffc-51379d578dbe	2026-07-21 12:23:05.653402+00	2026-07-21 12:23:05.653402+00	09131000215	$2b$12$xuXrNXMpv2QAn8J3GO0MieSHxQTYjnm2UZmk2MhNKdo4mkjB6MD2W
ec07ffa7-05d7-422d-ba55-c3ec21189b73	2026-07-21 12:23:05.653402+00	2026-07-21 12:23:05.653402+00	09131000216	$2b$12$zdCxvYkK2EjPPHyDAgZvFOAqZyqelwQuhEvNzsuPd121jGARrB0eq
\.


--
-- Data for Name: alembic_version; Type: TABLE DATA; Schema: public; Owner: -
--

COPY public.alembic_version (version_num) FROM stdin;
c2d5e8f1a4b6
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
4412ce02-204d-40d3-b1fa-73194e8ddfb5	2026-07-21 12:23:05.653402+00	2026-07-21 12:23:05.653402+00	9e026bc3-66b8-45d7-9c60-0989a6664192	75bbbdd2-5d00-4257-8e1e-c3881eebcf0e	9d142217-431d-4a0a-960e-8c6f0912f432	\N	جلسهٔ برنامه‌ریزی اسپرینت	\N	meeting	2026-06-20 10:00:00+00	2026-06-20 11:00:00+00	f
4fe2202c-5299-48b8-a5d7-1336a0fc4938	2026-07-21 12:23:05.653402+00	2026-07-21 12:23:05.653402+00	9e026bc3-66b8-45d7-9c60-0989a6664192	ad47309d-1c75-4d68-b779-348021512719	a2a211cb-0f9f-4af5-9766-66228a587300	\N	یادآوری ارسال گزارش	\N	reminder	2026-06-17 00:00:00+00	2026-06-17 01:00:00+00	t
07cb43be-cc3d-4f49-8c26-e4e431dc346a	2026-07-21 12:23:05.653402+00	2026-07-21 12:23:05.653402+00	9e026bc3-66b8-45d7-9c60-0989a6664192	75bbbdd2-5d00-4257-8e1e-c3881eebcf0e	9d142217-431d-4a0a-960e-8c6f0912f432	\N	جلسهٔ برنامه‌ریزی اسپرینت	\N	meeting	2026-06-27 10:00:00+00	2026-06-27 11:00:00+00	f
1807995f-11f6-4c6d-b85b-b5b9fcf4e6bc	2026-07-21 12:23:05.653402+00	2026-07-21 12:23:05.653402+00	9e026bc3-66b8-45d7-9c60-0989a6664192	ad47309d-1c75-4d68-b779-348021512719	40af2561-cb3f-4189-8722-0d90cf4e2a77	\N	یادآوری پیگیری مشتری	\N	reminder	2026-06-23 00:00:00+00	2026-06-23 01:00:00+00	t
b28672fa-c906-4362-93ed-02f0ad145366	2026-07-21 12:23:05.653402+00	2026-07-21 12:23:05.653402+00	9e026bc3-66b8-45d7-9c60-0989a6664192	75bbbdd2-5d00-4257-8e1e-c3881eebcf0e	40af2561-cb3f-4189-8722-0d90cf4e2a77	\N	جلسهٔ هماهنگی هفتگی	\N	meeting	2026-07-04 10:00:00+00	2026-07-04 11:00:00+00	f
e40c0c48-a05f-4f54-baeb-d9fc8050b1e1	2026-07-21 12:23:05.653402+00	2026-07-21 12:23:05.653402+00	9e026bc3-66b8-45d7-9c60-0989a6664192	6b87e773-3d93-47db-8dc6-37ca0e6e9b32	9d142217-431d-4a0a-960e-8c6f0912f432	\N	یادآوری پیگیری مشتری	\N	reminder	2026-07-03 00:00:00+00	2026-07-03 01:00:00+00	t
e956f056-bbc7-4b5a-b2ad-51fd26eaae44	2026-07-21 12:23:05.653402+00	2026-07-21 12:23:05.653402+00	9e026bc3-66b8-45d7-9c60-0989a6664192	75bbbdd2-5d00-4257-8e1e-c3881eebcf0e	a2a211cb-0f9f-4af5-9766-66228a587300	\N	جلسهٔ برنامه‌ریزی اسپرینت	\N	meeting	2026-07-09 10:00:00+00	2026-07-09 11:00:00+00	f
d8939c5f-d05d-498c-8b72-40bc4174eba6	2026-07-21 12:23:05.653402+00	2026-07-21 12:23:05.653402+00	9e026bc3-66b8-45d7-9c60-0989a6664192	24e34af4-1229-4d93-8615-b8479b51a37c	536e0e82-9dc4-4808-bd74-0dd75b0f2f8b	\N	یادآوری ارسال گزارش	\N	reminder	2026-07-12 00:00:00+00	2026-07-12 01:00:00+00	t
7a44c53d-a1a5-47d5-947e-df5c1e175bad	2026-07-21 12:23:05.653402+00	2026-07-21 12:23:05.653402+00	9e026bc3-66b8-45d7-9c60-0989a6664192	75bbbdd2-5d00-4257-8e1e-c3881eebcf0e	536e0e82-9dc4-4808-bd74-0dd75b0f2f8b	\N	جلسهٔ هماهنگی هفتگی	\N	meeting	2026-07-15 10:00:00+00	2026-07-15 11:00:00+00	f
d89b83c3-9f87-41a0-9466-578b30343829	2026-07-21 12:23:05.653402+00	2026-07-21 12:23:05.653402+00	9e026bc3-66b8-45d7-9c60-0989a6664192	ad47309d-1c75-4d68-b779-348021512719	536e0e82-9dc4-4808-bd74-0dd75b0f2f8b	\N	یادآوری ارسال گزارش	\N	reminder	2026-07-20 00:00:00+00	2026-07-20 01:00:00+00	t
83a9106c-b9a7-48e7-aaad-10c0e3663e1d	2026-07-21 12:23:05.653402+00	2026-07-21 12:23:05.653402+00	9e026bc3-66b8-45d7-9c60-0989a6664192	75bbbdd2-5d00-4257-8e1e-c3881eebcf0e	9d142217-431d-4a0a-960e-8c6f0912f432	\N	جلسهٔ برنامه‌ریزی اسپرینت	\N	meeting	2026-07-23 10:00:00+00	2026-07-23 11:00:00+00	f
77f5fe39-897f-4fa5-9f32-accd797f24f7	2026-07-21 12:23:05.653402+00	2026-07-21 12:23:05.653402+00	9e026bc3-66b8-45d7-9c60-0989a6664192	8c7cac5d-349c-4d45-ab78-f4e52554d784	bc18bca7-068d-4da6-a685-0070c009fe9f	\N	یادآوری پیگیری مشتری	\N	reminder	2026-07-27 00:00:00+00	2026-07-27 01:00:00+00	t
9c8c7711-387a-453e-8a04-ab41823ceff4	2026-07-21 12:23:05.653402+00	2026-07-21 12:23:05.653402+00	9e026bc3-66b8-45d7-9c60-0989a6664192	75bbbdd2-5d00-4257-8e1e-c3881eebcf0e	a2a211cb-0f9f-4af5-9766-66228a587300	\N	جلسهٔ بررسی پیشرفت پروژه	\N	meeting	2026-07-31 10:00:00+00	2026-07-31 11:00:00+00	f
57d83446-676f-4f81-b0b0-09e55f9118bc	2026-07-21 12:23:05.653402+00	2026-07-21 12:23:05.653402+00	9e026bc3-66b8-45d7-9c60-0989a6664192	dbe12768-1ffa-4f9b-8327-4558c4438ef6	9d142217-431d-4a0a-960e-8c6f0912f432	\N	یادآوری پیگیری مشتری	\N	reminder	2026-08-03 00:00:00+00	2026-08-03 01:00:00+00	t
7e7a3674-284c-482f-a683-7da54453ba15	2026-07-21 12:23:05.653402+00	2026-07-21 12:23:05.653402+00	9e026bc3-66b8-45d7-9c60-0989a6664192	75bbbdd2-5d00-4257-8e1e-c3881eebcf0e	a2a211cb-0f9f-4af5-9766-66228a587300	\N	جلسهٔ برنامه‌ریزی اسپرینت	\N	meeting	2026-08-04 10:00:00+00	2026-08-04 11:00:00+00	f
afa0c604-ba00-4daa-8060-3b737d0d2bb8	2026-07-21 12:23:05.653402+00	2026-07-21 12:23:05.653402+00	9e026bc3-66b8-45d7-9c60-0989a6664192	24e34af4-1229-4d93-8615-b8479b51a37c	bc18bca7-068d-4da6-a685-0070c009fe9f	\N	یادآوری ارسال گزارش	\N	reminder	2026-08-05 00:00:00+00	2026-08-05 01:00:00+00	t
23bbfae4-41e5-445b-9fa1-df7181eb842e	2026-07-21 12:23:05.653402+00	2026-07-21 12:23:05.653402+00	9e026bc3-66b8-45d7-9c60-0989a6664192	75bbbdd2-5d00-4257-8e1e-c3881eebcf0e	536e0e82-9dc4-4808-bd74-0dd75b0f2f8b	\N	جلسهٔ مرور با مدیریت	\N	meeting	2026-08-13 10:00:00+00	2026-08-13 11:00:00+00	f
db984c22-a704-406a-96c4-6fe6e831f426	2026-07-21 12:23:05.653402+00	2026-07-21 12:23:05.653402+00	9e026bc3-66b8-45d7-9c60-0989a6664192	ad47309d-1c75-4d68-b779-348021512719	a2a211cb-0f9f-4af5-9766-66228a587300	\N	یادآوری تمدید قرارداد	\N	reminder	2026-08-17 00:00:00+00	2026-08-17 01:00:00+00	t
e042b329-a0aa-4109-8b3b-355279d7a375	2026-07-21 12:23:05.653402+00	2026-07-21 12:23:05.653402+00	9e026bc3-66b8-45d7-9c60-0989a6664192	0aa7f564-65bd-473d-aa0e-3abc4663b507	f8f67ced-14a7-481c-8f04-dbff36848e4e	\N	جلسهٔ برنامه‌ریزی اسپرینت	\N	meeting	2026-06-17 10:00:00+00	2026-06-17 11:00:00+00	f
ed51de4d-accd-4272-96fb-61d897d8f576	2026-07-21 12:23:05.653402+00	2026-07-21 12:23:05.653402+00	9e026bc3-66b8-45d7-9c60-0989a6664192	515597de-809a-4b6a-9fb6-5e2cf6d9dfe2	f8f67ced-14a7-481c-8f04-dbff36848e4e	\N	یادآوری تمدید قرارداد	\N	reminder	2026-06-19 00:00:00+00	2026-06-19 01:00:00+00	t
c06ec32f-b5eb-4b07-9a7a-10e55ddf622d	2026-07-21 12:23:05.653402+00	2026-07-21 12:23:05.653402+00	9e026bc3-66b8-45d7-9c60-0989a6664192	0aa7f564-65bd-473d-aa0e-3abc4663b507	b2e41607-118c-4f69-a751-b623cfe694a9	\N	جلسهٔ برنامه‌ریزی اسپرینت	\N	meeting	2026-06-23 10:00:00+00	2026-06-23 11:00:00+00	f
af2b7f22-aac7-4123-88d7-e1c9957009d3	2026-07-21 12:23:05.653402+00	2026-07-21 12:23:05.653402+00	9e026bc3-66b8-45d7-9c60-0989a6664192	e5c268f5-5274-4960-be2b-6f7bbba26625	776f6076-91bd-4f6d-8fcd-ada6f5d2a107	\N	یادآوری ارسال گزارش	\N	reminder	2026-06-26 00:00:00+00	2026-06-26 01:00:00+00	t
c94f23bb-4439-4494-ac96-d7320a33e3aa	2026-07-21 12:23:05.653402+00	2026-07-21 12:23:05.653402+00	9e026bc3-66b8-45d7-9c60-0989a6664192	0aa7f564-65bd-473d-aa0e-3abc4663b507	f8f67ced-14a7-481c-8f04-dbff36848e4e	\N	جلسهٔ هماهنگی هفتگی	\N	meeting	2026-07-01 10:00:00+00	2026-07-01 11:00:00+00	f
ea4b3313-9eeb-48ae-922f-80c653bfb097	2026-07-21 12:23:05.653402+00	2026-07-21 12:23:05.653402+00	9e026bc3-66b8-45d7-9c60-0989a6664192	c17589b4-349d-4156-9b66-f7ecf971b52d	dfc1e39f-343f-43e4-a459-9626f69442a6	\N	یادآوری تمدید قرارداد	\N	reminder	2026-07-03 00:00:00+00	2026-07-03 01:00:00+00	t
1ae18d41-5d07-4518-be7d-7ed0fe32ea28	2026-07-21 12:23:05.653402+00	2026-07-21 12:23:05.653402+00	9e026bc3-66b8-45d7-9c60-0989a6664192	0aa7f564-65bd-473d-aa0e-3abc4663b507	f8f67ced-14a7-481c-8f04-dbff36848e4e	\N	جلسهٔ برنامه‌ریزی اسپرینت	\N	meeting	2026-07-10 10:00:00+00	2026-07-10 11:00:00+00	f
33e488ad-a3cc-4180-b775-7ab097cab49d	2026-07-21 12:23:05.653402+00	2026-07-21 12:23:05.653402+00	9e026bc3-66b8-45d7-9c60-0989a6664192	147770ac-f6f9-4af1-97c3-cccc614d44e9	dfc1e39f-343f-43e4-a459-9626f69442a6	\N	یادآوری تمدید قرارداد	\N	reminder	2026-07-11 00:00:00+00	2026-07-11 01:00:00+00	t
f5b4bc55-5fcb-4037-ba18-ec46fe993d12	2026-07-21 12:23:05.653402+00	2026-07-21 12:23:05.653402+00	9e026bc3-66b8-45d7-9c60-0989a6664192	0aa7f564-65bd-473d-aa0e-3abc4663b507	dfc1e39f-343f-43e4-a459-9626f69442a6	\N	جلسهٔ هماهنگی هفتگی	\N	meeting	2026-07-15 10:00:00+00	2026-07-15 11:00:00+00	f
393fa66a-f7cd-4e0e-8cf3-d5b952ce589d	2026-07-21 12:23:05.653402+00	2026-07-21 12:23:05.653402+00	9e026bc3-66b8-45d7-9c60-0989a6664192	147770ac-f6f9-4af1-97c3-cccc614d44e9	432d011d-9811-4926-818f-2b63ae8aa481	\N	یادآوری ارسال گزارش	\N	reminder	2026-07-16 00:00:00+00	2026-07-16 01:00:00+00	t
62093b99-8da1-4ee8-a4cc-e47407e7cb78	2026-07-21 12:23:05.653402+00	2026-07-21 12:23:05.653402+00	9e026bc3-66b8-45d7-9c60-0989a6664192	0aa7f564-65bd-473d-aa0e-3abc4663b507	dfc1e39f-343f-43e4-a459-9626f69442a6	\N	جلسهٔ مرور با مدیریت	\N	meeting	2026-07-21 10:00:00+00	2026-07-21 11:00:00+00	f
c95764ed-790a-42e6-97a2-13e0c201157d	2026-07-21 12:23:05.653402+00	2026-07-21 12:23:05.653402+00	9e026bc3-66b8-45d7-9c60-0989a6664192	6965fa45-fddb-4465-b0e6-042192ac6ee2	f8f67ced-14a7-481c-8f04-dbff36848e4e	\N	یادآوری ارسال گزارش	\N	reminder	2026-07-25 00:00:00+00	2026-07-25 01:00:00+00	t
58a5db8d-cb7b-4d09-8ccb-4fe8da7c4869	2026-07-21 12:23:05.653402+00	2026-07-21 12:23:05.653402+00	9e026bc3-66b8-45d7-9c60-0989a6664192	0aa7f564-65bd-473d-aa0e-3abc4663b507	432d011d-9811-4926-818f-2b63ae8aa481	\N	جلسهٔ بررسی پیشرفت پروژه	\N	meeting	2026-07-28 10:00:00+00	2026-07-28 11:00:00+00	f
01492d21-bcc2-4310-8d6e-b83d1ef7237e	2026-07-21 12:23:05.653402+00	2026-07-21 12:23:05.653402+00	9e026bc3-66b8-45d7-9c60-0989a6664192	e5c268f5-5274-4960-be2b-6f7bbba26625	dfc1e39f-343f-43e4-a459-9626f69442a6	\N	یادآوری پیگیری مشتری	\N	reminder	2026-08-02 00:00:00+00	2026-08-02 01:00:00+00	t
3a824dc5-855e-4ad8-a8b1-b02abb8a143c	2026-07-21 12:23:05.653402+00	2026-07-21 12:23:05.653402+00	9e026bc3-66b8-45d7-9c60-0989a6664192	0aa7f564-65bd-473d-aa0e-3abc4663b507	b2e41607-118c-4f69-a751-b623cfe694a9	\N	جلسهٔ مرور با مدیریت	\N	meeting	2026-08-05 10:00:00+00	2026-08-05 11:00:00+00	f
6ea72d58-7ec5-405d-94d7-3a54e957ab51	2026-07-21 12:23:05.653402+00	2026-07-21 12:23:05.653402+00	9e026bc3-66b8-45d7-9c60-0989a6664192	e5c268f5-5274-4960-be2b-6f7bbba26625	432d011d-9811-4926-818f-2b63ae8aa481	\N	یادآوری ارسال گزارش	\N	reminder	2026-08-06 00:00:00+00	2026-08-06 01:00:00+00	t
d14ad298-354d-48ed-803b-5818e2994318	2026-07-21 12:23:05.653402+00	2026-07-21 12:23:05.653402+00	9e026bc3-66b8-45d7-9c60-0989a6664192	0aa7f564-65bd-473d-aa0e-3abc4663b507	f8f67ced-14a7-481c-8f04-dbff36848e4e	\N	جلسهٔ برنامه‌ریزی اسپرینت	\N	meeting	2026-08-13 10:00:00+00	2026-08-13 11:00:00+00	f
f4b05997-67e0-4876-9781-363c9449c829	2026-07-21 12:23:05.653402+00	2026-07-21 12:23:05.653402+00	9e026bc3-66b8-45d7-9c60-0989a6664192	6115c41b-8c19-4fa9-b656-df967e8a945e	dfc1e39f-343f-43e4-a459-9626f69442a6	\N	یادآوری پیگیری مشتری	\N	reminder	2026-08-15 00:00:00+00	2026-08-15 01:00:00+00	t
db229aa3-62cd-4594-ab8f-d2b9f8c055e6	2026-07-21 12:23:05.653402+00	2026-07-21 12:23:05.653402+00	9e026bc3-66b8-45d7-9c60-0989a6664192	be682dce-6665-4ff0-8e8a-067602882309	8788d165-ed7c-43bd-97f4-f1190b5dba5a	\N	جلسهٔ هماهنگی هفتگی	\N	meeting	2026-06-20 10:00:00+00	2026-06-20 11:00:00+00	f
e5301e6d-21b2-4fe6-8744-aff1e8a6d36f	2026-07-21 12:23:05.653402+00	2026-07-21 12:23:05.653402+00	9e026bc3-66b8-45d7-9c60-0989a6664192	37e62239-b7c6-493c-9475-fe700a479e79	5bf8928f-5573-49a0-9ee7-59b30d16f60c	\N	یادآوری ارسال گزارش	\N	reminder	2026-06-19 00:00:00+00	2026-06-19 01:00:00+00	t
b121e660-5dc6-4502-ab6a-646c2694047e	2026-07-21 12:23:05.653402+00	2026-07-21 12:23:05.653402+00	9e026bc3-66b8-45d7-9c60-0989a6664192	be682dce-6665-4ff0-8e8a-067602882309	5bf8928f-5573-49a0-9ee7-59b30d16f60c	\N	جلسهٔ مرور با مدیریت	\N	meeting	2026-06-25 10:00:00+00	2026-06-25 11:00:00+00	f
aea5e113-1b78-4462-ad21-04896046962a	2026-07-21 12:23:05.653402+00	2026-07-21 12:23:05.653402+00	9e026bc3-66b8-45d7-9c60-0989a6664192	1f7a4d5f-3f0b-4a87-92e9-cf7057b674f5	97ebd5ca-a1b0-474f-8195-6ee131268149	\N	یادآوری تمدید قرارداد	\N	reminder	2026-06-29 00:00:00+00	2026-06-29 01:00:00+00	t
ae83c2d3-24c7-4869-b568-d3dde1f461e3	2026-07-21 12:23:05.653402+00	2026-07-21 12:23:05.653402+00	9e026bc3-66b8-45d7-9c60-0989a6664192	be682dce-6665-4ff0-8e8a-067602882309	3e1c6a65-ca90-48f7-ad09-df284b6601d0	\N	جلسهٔ برنامه‌ریزی اسپرینت	\N	meeting	2026-07-02 10:00:00+00	2026-07-02 11:00:00+00	f
136d276f-707a-4525-aec0-daa861103c94	2026-07-21 12:23:05.653402+00	2026-07-21 12:23:05.653402+00	9e026bc3-66b8-45d7-9c60-0989a6664192	3cdfd222-0ea4-4a30-b15b-036d1d733193	8788d165-ed7c-43bd-97f4-f1190b5dba5a	\N	یادآوری تمدید قرارداد	\N	reminder	2026-07-02 00:00:00+00	2026-07-02 01:00:00+00	t
c40c35ed-9e41-4e0b-997b-aa47b13dbae3	2026-07-21 12:23:05.653402+00	2026-07-21 12:23:05.653402+00	9e026bc3-66b8-45d7-9c60-0989a6664192	be682dce-6665-4ff0-8e8a-067602882309	3e1c6a65-ca90-48f7-ad09-df284b6601d0	\N	جلسهٔ مرور با مدیریت	\N	meeting	2026-07-07 10:00:00+00	2026-07-07 11:00:00+00	f
c0124483-698b-49d1-9389-1ed7210c11d9	2026-07-21 12:23:05.653402+00	2026-07-21 12:23:05.653402+00	9e026bc3-66b8-45d7-9c60-0989a6664192	2310cdf5-d549-4a28-bc04-2052038876fc	8788d165-ed7c-43bd-97f4-f1190b5dba5a	\N	یادآوری ارسال گزارش	\N	reminder	2026-07-07 00:00:00+00	2026-07-07 01:00:00+00	t
546f6d9d-c528-4277-802a-69d2b5499319	2026-07-21 12:23:05.653402+00	2026-07-21 12:23:05.653402+00	9e026bc3-66b8-45d7-9c60-0989a6664192	be682dce-6665-4ff0-8e8a-067602882309	8788d165-ed7c-43bd-97f4-f1190b5dba5a	\N	جلسهٔ بررسی پیشرفت پروژه	\N	meeting	2026-07-18 10:00:00+00	2026-07-18 11:00:00+00	f
80b4cfdd-52be-4024-99b1-f646f3460c82	2026-07-21 12:23:05.653402+00	2026-07-21 12:23:05.653402+00	9e026bc3-66b8-45d7-9c60-0989a6664192	2310cdf5-d549-4a28-bc04-2052038876fc	3e1c6a65-ca90-48f7-ad09-df284b6601d0	\N	یادآوری تمدید قرارداد	\N	reminder	2026-07-20 00:00:00+00	2026-07-20 01:00:00+00	t
e7fb282d-fab1-46d8-a8b0-86dc1cc42149	2026-07-21 12:23:05.653402+00	2026-07-21 12:23:05.653402+00	9e026bc3-66b8-45d7-9c60-0989a6664192	be682dce-6665-4ff0-8e8a-067602882309	8788d165-ed7c-43bd-97f4-f1190b5dba5a	\N	جلسهٔ مرور با مدیریت	\N	meeting	2026-07-24 10:00:00+00	2026-07-24 11:00:00+00	f
c382dc22-274d-4314-88aa-ecdc324270e4	2026-07-21 12:23:05.653402+00	2026-07-21 12:23:05.653402+00	9e026bc3-66b8-45d7-9c60-0989a6664192	220f13de-14e7-4c15-a3c3-d456ccb8f206	8788d165-ed7c-43bd-97f4-f1190b5dba5a	\N	یادآوری تمدید قرارداد	\N	reminder	2026-07-21 00:00:00+00	2026-07-21 01:00:00+00	t
b99d67a2-c803-4585-9fce-114749023551	2026-07-21 12:23:05.653402+00	2026-07-21 12:23:05.653402+00	9e026bc3-66b8-45d7-9c60-0989a6664192	be682dce-6665-4ff0-8e8a-067602882309	e8969525-8440-4cdc-9110-d6b5e43d877f	\N	جلسهٔ بررسی پیشرفت پروژه	\N	meeting	2026-07-29 10:00:00+00	2026-07-29 11:00:00+00	f
e2bf4938-ecfa-4424-b1f6-3d500bfb6655	2026-07-21 12:23:05.653402+00	2026-07-21 12:23:05.653402+00	9e026bc3-66b8-45d7-9c60-0989a6664192	2310cdf5-d549-4a28-bc04-2052038876fc	e8969525-8440-4cdc-9110-d6b5e43d877f	\N	یادآوری پیگیری مشتری	\N	reminder	2026-08-02 00:00:00+00	2026-08-02 01:00:00+00	t
7e156a64-832b-4513-808d-1588d7182f55	2026-07-21 12:23:05.653402+00	2026-07-21 12:23:05.653402+00	9e026bc3-66b8-45d7-9c60-0989a6664192	be682dce-6665-4ff0-8e8a-067602882309	8788d165-ed7c-43bd-97f4-f1190b5dba5a	\N	جلسهٔ مرور با مدیریت	\N	meeting	2026-08-08 10:00:00+00	2026-08-08 11:00:00+00	f
ef1739d6-b145-4375-9cf6-994e90d91d67	2026-07-21 12:23:05.653402+00	2026-07-21 12:23:05.653402+00	9e026bc3-66b8-45d7-9c60-0989a6664192	37e62239-b7c6-493c-9475-fe700a479e79	97ebd5ca-a1b0-474f-8195-6ee131268149	\N	یادآوری ارسال گزارش	\N	reminder	2026-08-10 00:00:00+00	2026-08-10 01:00:00+00	t
6c537daa-d339-43c4-8ee2-e982da5bb964	2026-07-21 12:23:05.653402+00	2026-07-21 12:23:05.653402+00	9e026bc3-66b8-45d7-9c60-0989a6664192	be682dce-6665-4ff0-8e8a-067602882309	3e1c6a65-ca90-48f7-ad09-df284b6601d0	\N	جلسهٔ برنامه‌ریزی اسپرینت	\N	meeting	2026-08-12 10:00:00+00	2026-08-12 11:00:00+00	f
d7098577-86ee-433f-86c0-e4708593df92	2026-07-21 12:23:05.653402+00	2026-07-21 12:23:05.653402+00	9e026bc3-66b8-45d7-9c60-0989a6664192	1f7a4d5f-3f0b-4a87-92e9-cf7057b674f5	3e1c6a65-ca90-48f7-ad09-df284b6601d0	\N	یادآوری پیگیری مشتری	\N	reminder	2026-08-13 00:00:00+00	2026-08-13 01:00:00+00	t
d33f942f-5e09-4338-be62-a386c9b958c5	2026-07-21 12:23:05.653402+00	2026-07-21 12:23:05.653402+00	9e026bc3-66b8-45d7-9c60-0989a6664192	817e2843-948e-4775-a2b7-3ded2f04feca	\N	\N	تعطیلی رسمی	\N	holiday	2026-06-18 00:00:00+00	2026-06-18 01:00:00+00	t
8d22697d-5483-4cc1-8705-5710199c81d4	2026-07-21 12:23:05.653402+00	2026-07-21 12:23:05.653402+00	9e026bc3-66b8-45d7-9c60-0989a6664192	817e2843-948e-4775-a2b7-3ded2f04feca	\N	\N	تعطیلی رسمی	\N	holiday	2026-07-16 00:00:00+00	2026-07-16 01:00:00+00	t
6e321c15-2c01-4936-8a93-97d110385130	2026-07-21 12:23:05.653402+00	2026-07-21 12:23:05.653402+00	9e026bc3-66b8-45d7-9c60-0989a6664192	817e2843-948e-4775-a2b7-3ded2f04feca	\N	\N	تعطیلی رسمی	\N	holiday	2026-08-13 00:00:00+00	2026-08-13 01:00:00+00	t
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
49967271-7dd9-4ecc-88ad-23270c530f3c	2026-07-21 12:23:05.653402+00	2026-07-21 12:23:05.653402+00	9e026bc3-66b8-45d7-9c60-0989a6664192	75bbbdd2-5d00-4257-8e1e-c3881eebcf0e	6e484715-c164-4c7b-b7a9-0a5b47a188a1	project_manager
bfeb8360-6395-40d4-bb52-847d2148e111	2026-07-21 12:23:05.653402+00	2026-07-21 12:23:05.653402+00	9e026bc3-66b8-45d7-9c60-0989a6664192	24e34af4-1229-4d93-8615-b8479b51a37c	6e484715-c164-4c7b-b7a9-0a5b47a188a1	employee
5671e510-dcdb-42d4-bd8b-880e0a42b269	2026-07-21 12:23:05.653402+00	2026-07-21 12:23:05.653402+00	9e026bc3-66b8-45d7-9c60-0989a6664192	dbe12768-1ffa-4f9b-8327-4558c4438ef6	6e484715-c164-4c7b-b7a9-0a5b47a188a1	employee
fc8cdcf8-4a6e-46c4-a9e6-e597bff2a59a	2026-07-21 12:23:05.653402+00	2026-07-21 12:23:05.653402+00	9e026bc3-66b8-45d7-9c60-0989a6664192	7e07497e-be59-442a-82ad-943e3bd502bb	6e484715-c164-4c7b-b7a9-0a5b47a188a1	employee
bb867a84-3353-4a0f-9f67-4ba8e9854863	2026-07-21 12:23:05.653402+00	2026-07-21 12:23:05.653402+00	9e026bc3-66b8-45d7-9c60-0989a6664192	6b87e773-3d93-47db-8dc6-37ca0e6e9b32	6e484715-c164-4c7b-b7a9-0a5b47a188a1	employee
d2e527c6-7606-4f85-a87e-93fd7b2cca17	2026-07-21 12:23:05.653402+00	2026-07-21 12:23:05.653402+00	9e026bc3-66b8-45d7-9c60-0989a6664192	ad47309d-1c75-4d68-b779-348021512719	6e484715-c164-4c7b-b7a9-0a5b47a188a1	employee
7cc6cc94-4291-4636-90d8-b41c1240eb5e	2026-07-21 12:23:05.653402+00	2026-07-21 12:23:05.653402+00	9e026bc3-66b8-45d7-9c60-0989a6664192	8c7cac5d-349c-4d45-ab78-f4e52554d784	6e484715-c164-4c7b-b7a9-0a5b47a188a1	employee
9bd14c7a-8c67-4b1c-8329-f8f3372016b3	2026-07-21 12:23:05.653402+00	2026-07-21 12:23:05.653402+00	9e026bc3-66b8-45d7-9c60-0989a6664192	0aa7f564-65bd-473d-aa0e-3abc4663b507	167ce15f-9954-4a63-a93b-54f6d1c3b955	project_manager
6fc55756-abe7-4975-90e1-a18378d2b1c1	2026-07-21 12:23:05.653402+00	2026-07-21 12:23:05.653402+00	9e026bc3-66b8-45d7-9c60-0989a6664192	6115c41b-8c19-4fa9-b656-df967e8a945e	167ce15f-9954-4a63-a93b-54f6d1c3b955	employee
a2ac524f-23a8-4a80-ba6d-20e66aadd4d0	2026-07-21 12:23:05.653402+00	2026-07-21 12:23:05.653402+00	9e026bc3-66b8-45d7-9c60-0989a6664192	e5c268f5-5274-4960-be2b-6f7bbba26625	167ce15f-9954-4a63-a93b-54f6d1c3b955	employee
593e99cf-f3e0-42c6-b390-edc6f3a63ab0	2026-07-21 12:23:05.653402+00	2026-07-21 12:23:05.653402+00	9e026bc3-66b8-45d7-9c60-0989a6664192	6965fa45-fddb-4465-b0e6-042192ac6ee2	167ce15f-9954-4a63-a93b-54f6d1c3b955	employee
a14a5882-0cfe-4923-9e76-289fe6f4aebb	2026-07-21 12:23:05.653402+00	2026-07-21 12:23:05.653402+00	9e026bc3-66b8-45d7-9c60-0989a6664192	515597de-809a-4b6a-9fb6-5e2cf6d9dfe2	167ce15f-9954-4a63-a93b-54f6d1c3b955	employee
cb016d1c-5ff4-4cdd-87d0-0eb4c2e645b5	2026-07-21 12:23:05.653402+00	2026-07-21 12:23:05.653402+00	9e026bc3-66b8-45d7-9c60-0989a6664192	147770ac-f6f9-4af1-97c3-cccc614d44e9	167ce15f-9954-4a63-a93b-54f6d1c3b955	employee
3f386f44-2a49-4698-a34d-db83cf14d08a	2026-07-21 12:23:05.653402+00	2026-07-21 12:23:05.653402+00	9e026bc3-66b8-45d7-9c60-0989a6664192	c17589b4-349d-4156-9b66-f7ecf971b52d	167ce15f-9954-4a63-a93b-54f6d1c3b955	employee
e87397c5-0826-4a28-b252-ef7af0e2fc91	2026-07-21 12:23:05.653402+00	2026-07-21 12:23:05.653402+00	9e026bc3-66b8-45d7-9c60-0989a6664192	be682dce-6665-4ff0-8e8a-067602882309	13fe4056-fcc6-4d8b-9bb2-6444c12239a5	project_manager
d6c1e4cd-46f2-491f-9b7a-fe3a6c88bbf1	2026-07-21 12:23:05.653402+00	2026-07-21 12:23:05.653402+00	9e026bc3-66b8-45d7-9c60-0989a6664192	37e62239-b7c6-493c-9475-fe700a479e79	13fe4056-fcc6-4d8b-9bb2-6444c12239a5	employee
6f1b0171-b300-4641-ac15-d52cfd5fe0ed	2026-07-21 12:23:05.653402+00	2026-07-21 12:23:05.653402+00	9e026bc3-66b8-45d7-9c60-0989a6664192	fe6b733f-8cf4-4df1-a83e-2e854a480178	13fe4056-fcc6-4d8b-9bb2-6444c12239a5	employee
6b5ac04f-6c3e-4ccc-b5be-b92edb5b3078	2026-07-21 12:23:05.653402+00	2026-07-21 12:23:05.653402+00	9e026bc3-66b8-45d7-9c60-0989a6664192	2310cdf5-d549-4a28-bc04-2052038876fc	13fe4056-fcc6-4d8b-9bb2-6444c12239a5	employee
b5484fde-9617-4f1f-aee5-3412786b0bec	2026-07-21 12:23:05.653402+00	2026-07-21 12:23:05.653402+00	9e026bc3-66b8-45d7-9c60-0989a6664192	220f13de-14e7-4c15-a3c3-d456ccb8f206	13fe4056-fcc6-4d8b-9bb2-6444c12239a5	employee
5a0aac56-5cf7-468f-9d95-9d9e7d642922	2026-07-21 12:23:05.653402+00	2026-07-21 12:23:05.653402+00	9e026bc3-66b8-45d7-9c60-0989a6664192	3cdfd222-0ea4-4a30-b15b-036d1d733193	13fe4056-fcc6-4d8b-9bb2-6444c12239a5	employee
618dad93-322f-4bc3-8f1e-04c733b1e179	2026-07-21 12:23:05.653402+00	2026-07-21 12:23:05.653402+00	9e026bc3-66b8-45d7-9c60-0989a6664192	1f7a4d5f-3f0b-4a87-92e9-cf7057b674f5	13fe4056-fcc6-4d8b-9bb2-6444c12239a5	employee
f4fad791-9128-4a35-acc9-62fb6c28dc83	2026-07-21 12:23:05.653402+00	2026-07-21 12:23:05.653402+00	9e026bc3-66b8-45d7-9c60-0989a6664192	be682dce-6665-4ff0-8e8a-067602882309	6e484715-c164-4c7b-b7a9-0a5b47a188a1	employee
2e49ef8b-e824-4dbb-9a32-11669b24a973	2026-07-21 12:23:05.653402+00	2026-07-21 12:23:05.653402+00	9e026bc3-66b8-45d7-9c60-0989a6664192	24e34af4-1229-4d93-8615-b8479b51a37c	167ce15f-9954-4a63-a93b-54f6d1c3b955	employee
\.


--
-- Data for Name: departments; Type: TABLE DATA; Schema: public; Owner: -
--

COPY public.departments (id, created_at, updated_at, organization_id, name) FROM stdin;
6e484715-c164-4c7b-b7a9-0a5b47a188a1	2026-07-21 12:23:05.653402+00	2026-07-21 12:23:05.653402+00	9e026bc3-66b8-45d7-9c60-0989a6664192	مهندسی و فنی
167ce15f-9954-4a63-a93b-54f6d1c3b955	2026-07-21 12:23:05.653402+00	2026-07-21 12:23:05.653402+00	9e026bc3-66b8-45d7-9c60-0989a6664192	حسابداری و مالی
13fe4056-fcc6-4d8b-9bb2-6444c12239a5	2026-07-21 12:23:05.653402+00	2026-07-21 12:23:05.653402+00	9e026bc3-66b8-45d7-9c60-0989a6664192	منابع انسانی
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
شرکت نمونهٔ آزمایشی	demo-org-3cec657b	t	9e026bc3-66b8-45d7-9c60-0989a6664192	2026-07-21 12:23:05.653402+00	2026-07-21 12:23:05.653402+00
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
9d142217-431d-4a0a-960e-8c6f0912f432	75bbbdd2-5d00-4257-8e1e-c3881eebcf0e	356d3141-5a08-4001-b5af-bcbebad50018	2026-07-21 12:23:05.653402+00	2026-07-21 12:23:05.653402+00
9d142217-431d-4a0a-960e-8c6f0912f432	8c7cac5d-349c-4d45-ab78-f4e52554d784	232aa49c-395f-4d3c-b151-453e8209f019	2026-07-21 12:23:05.653402+00	2026-07-21 12:23:05.653402+00
9d142217-431d-4a0a-960e-8c6f0912f432	24e34af4-1229-4d93-8615-b8479b51a37c	a1a4fa95-3dcb-4ec2-b314-a8764defab7b	2026-07-21 12:23:05.653402+00	2026-07-21 12:23:05.653402+00
9d142217-431d-4a0a-960e-8c6f0912f432	ad47309d-1c75-4d68-b779-348021512719	309996d2-5316-4c3d-81c3-3ec6944c8c22	2026-07-21 12:23:05.653402+00	2026-07-21 12:23:05.653402+00
bc18bca7-068d-4da6-a685-0070c009fe9f	75bbbdd2-5d00-4257-8e1e-c3881eebcf0e	1d8f0a6f-959f-46d2-8b4f-dc08a5f8880b	2026-07-21 12:23:05.653402+00	2026-07-21 12:23:05.653402+00
bc18bca7-068d-4da6-a685-0070c009fe9f	dbe12768-1ffa-4f9b-8327-4558c4438ef6	bca9b2c6-021e-425c-b151-101540361993	2026-07-21 12:23:05.653402+00	2026-07-21 12:23:05.653402+00
bc18bca7-068d-4da6-a685-0070c009fe9f	8c7cac5d-349c-4d45-ab78-f4e52554d784	4234b767-d838-4da1-9089-edc201346021	2026-07-21 12:23:05.653402+00	2026-07-21 12:23:05.653402+00
bc18bca7-068d-4da6-a685-0070c009fe9f	24e34af4-1229-4d93-8615-b8479b51a37c	774790e2-caf8-4b45-8815-9285417c7922	2026-07-21 12:23:05.653402+00	2026-07-21 12:23:05.653402+00
536e0e82-9dc4-4808-bd74-0dd75b0f2f8b	75bbbdd2-5d00-4257-8e1e-c3881eebcf0e	81343605-447d-4b64-adba-b2703c3e7aef	2026-07-21 12:23:05.653402+00	2026-07-21 12:23:05.653402+00
536e0e82-9dc4-4808-bd74-0dd75b0f2f8b	ad47309d-1c75-4d68-b779-348021512719	b617d574-7351-4bb4-98d0-d9e5bc604467	2026-07-21 12:23:05.653402+00	2026-07-21 12:23:05.653402+00
536e0e82-9dc4-4808-bd74-0dd75b0f2f8b	6b87e773-3d93-47db-8dc6-37ca0e6e9b32	93eff3fc-b525-4c44-a7c7-2b8c35819471	2026-07-21 12:23:05.653402+00	2026-07-21 12:23:05.653402+00
536e0e82-9dc4-4808-bd74-0dd75b0f2f8b	24e34af4-1229-4d93-8615-b8479b51a37c	10a496bd-9ea4-49ec-b6af-11ecc375c8b5	2026-07-21 12:23:05.653402+00	2026-07-21 12:23:05.653402+00
a2a211cb-0f9f-4af5-9766-66228a587300	75bbbdd2-5d00-4257-8e1e-c3881eebcf0e	e2866e0b-1f26-497e-871a-1cd65edc19f1	2026-07-21 12:23:05.653402+00	2026-07-21 12:23:05.653402+00
a2a211cb-0f9f-4af5-9766-66228a587300	dbe12768-1ffa-4f9b-8327-4558c4438ef6	df56c1ee-9754-4e79-becb-8004fe1d5c85	2026-07-21 12:23:05.653402+00	2026-07-21 12:23:05.653402+00
a2a211cb-0f9f-4af5-9766-66228a587300	8c7cac5d-349c-4d45-ab78-f4e52554d784	7eae40a5-5e91-4f78-8488-d4be41471a6e	2026-07-21 12:23:05.653402+00	2026-07-21 12:23:05.653402+00
a2a211cb-0f9f-4af5-9766-66228a587300	24e34af4-1229-4d93-8615-b8479b51a37c	16dcb572-cdf4-4a05-8bcd-a10aea2ab7f7	2026-07-21 12:23:05.653402+00	2026-07-21 12:23:05.653402+00
40af2561-cb3f-4189-8722-0d90cf4e2a77	75bbbdd2-5d00-4257-8e1e-c3881eebcf0e	e54bc407-b8f1-4a07-9b4e-95f9f4f11d1f	2026-07-21 12:23:05.653402+00	2026-07-21 12:23:05.653402+00
40af2561-cb3f-4189-8722-0d90cf4e2a77	8c7cac5d-349c-4d45-ab78-f4e52554d784	6796819d-4bb5-4cc2-b017-e9a3ce96858c	2026-07-21 12:23:05.653402+00	2026-07-21 12:23:05.653402+00
40af2561-cb3f-4189-8722-0d90cf4e2a77	ad47309d-1c75-4d68-b779-348021512719	3a9fa63a-9863-4d16-be77-8db591e009af	2026-07-21 12:23:05.653402+00	2026-07-21 12:23:05.653402+00
40af2561-cb3f-4189-8722-0d90cf4e2a77	6b87e773-3d93-47db-8dc6-37ca0e6e9b32	ce9fc133-4931-484e-867a-b1fb9eee950d	2026-07-21 12:23:05.653402+00	2026-07-21 12:23:05.653402+00
b2e41607-118c-4f69-a751-b623cfe694a9	0aa7f564-65bd-473d-aa0e-3abc4663b507	4f2140bc-2e79-44b7-b4e9-f48b6681e8ab	2026-07-21 12:23:05.653402+00	2026-07-21 12:23:05.653402+00
b2e41607-118c-4f69-a751-b623cfe694a9	6115c41b-8c19-4fa9-b656-df967e8a945e	2d2553e9-f3c9-4c86-8f73-bc42c4752d35	2026-07-21 12:23:05.653402+00	2026-07-21 12:23:05.653402+00
b2e41607-118c-4f69-a751-b623cfe694a9	e5c268f5-5274-4960-be2b-6f7bbba26625	ed94c1de-06c5-4bcd-802b-474f288fabcc	2026-07-21 12:23:05.653402+00	2026-07-21 12:23:05.653402+00
b2e41607-118c-4f69-a751-b623cfe694a9	6965fa45-fddb-4465-b0e6-042192ac6ee2	51afe931-bce8-4f1b-8904-aba7b4dc787b	2026-07-21 12:23:05.653402+00	2026-07-21 12:23:05.653402+00
432d011d-9811-4926-818f-2b63ae8aa481	0aa7f564-65bd-473d-aa0e-3abc4663b507	58e243ef-0492-49c0-9f81-2cfd61ba9307	2026-07-21 12:23:05.653402+00	2026-07-21 12:23:05.653402+00
432d011d-9811-4926-818f-2b63ae8aa481	6115c41b-8c19-4fa9-b656-df967e8a945e	d90f43ec-28be-444e-8850-99744f4aaaae	2026-07-21 12:23:05.653402+00	2026-07-21 12:23:05.653402+00
432d011d-9811-4926-818f-2b63ae8aa481	6965fa45-fddb-4465-b0e6-042192ac6ee2	642384e1-7c08-480b-b14f-3af8742e3dff	2026-07-21 12:23:05.653402+00	2026-07-21 12:23:05.653402+00
432d011d-9811-4926-818f-2b63ae8aa481	147770ac-f6f9-4af1-97c3-cccc614d44e9	507111dc-374f-4590-9ef9-8b081775a39c	2026-07-21 12:23:05.653402+00	2026-07-21 12:23:05.653402+00
dfc1e39f-343f-43e4-a459-9626f69442a6	0aa7f564-65bd-473d-aa0e-3abc4663b507	e101aaf8-eca4-463d-adbf-5c805f8c091c	2026-07-21 12:23:05.653402+00	2026-07-21 12:23:05.653402+00
dfc1e39f-343f-43e4-a459-9626f69442a6	6965fa45-fddb-4465-b0e6-042192ac6ee2	b29fe37a-c0e1-4d9a-a5b3-a1ad5a062ce4	2026-07-21 12:23:05.653402+00	2026-07-21 12:23:05.653402+00
dfc1e39f-343f-43e4-a459-9626f69442a6	515597de-809a-4b6a-9fb6-5e2cf6d9dfe2	5dac12dc-530c-4a72-87b4-639140a6968a	2026-07-21 12:23:05.653402+00	2026-07-21 12:23:05.653402+00
dfc1e39f-343f-43e4-a459-9626f69442a6	147770ac-f6f9-4af1-97c3-cccc614d44e9	1dba0860-fb41-451b-bfe9-2d6d2eccbd6b	2026-07-21 12:23:05.653402+00	2026-07-21 12:23:05.653402+00
776f6076-91bd-4f6d-8fcd-ada6f5d2a107	0aa7f564-65bd-473d-aa0e-3abc4663b507	b0828f55-5854-4897-84ca-b0be3af8fa55	2026-07-21 12:23:05.653402+00	2026-07-21 12:23:05.653402+00
776f6076-91bd-4f6d-8fcd-ada6f5d2a107	6965fa45-fddb-4465-b0e6-042192ac6ee2	5fa80475-c72a-4837-a075-64146fed8e73	2026-07-21 12:23:05.653402+00	2026-07-21 12:23:05.653402+00
776f6076-91bd-4f6d-8fcd-ada6f5d2a107	e5c268f5-5274-4960-be2b-6f7bbba26625	8b9e95a8-7732-46d6-917c-40c3f90d786d	2026-07-21 12:23:05.653402+00	2026-07-21 12:23:05.653402+00
776f6076-91bd-4f6d-8fcd-ada6f5d2a107	515597de-809a-4b6a-9fb6-5e2cf6d9dfe2	54f0704f-c33c-4ce6-9478-f1694b163777	2026-07-21 12:23:05.653402+00	2026-07-21 12:23:05.653402+00
f8f67ced-14a7-481c-8f04-dbff36848e4e	0aa7f564-65bd-473d-aa0e-3abc4663b507	208a0596-d900-45c8-ad3e-470edd15eb40	2026-07-21 12:23:05.653402+00	2026-07-21 12:23:05.653402+00
f8f67ced-14a7-481c-8f04-dbff36848e4e	147770ac-f6f9-4af1-97c3-cccc614d44e9	1ad99ea6-da23-4f5f-8004-b9b0559f544a	2026-07-21 12:23:05.653402+00	2026-07-21 12:23:05.653402+00
f8f67ced-14a7-481c-8f04-dbff36848e4e	6965fa45-fddb-4465-b0e6-042192ac6ee2	42d67537-116f-4f5e-91c7-0be98068f202	2026-07-21 12:23:05.653402+00	2026-07-21 12:23:05.653402+00
f8f67ced-14a7-481c-8f04-dbff36848e4e	6115c41b-8c19-4fa9-b656-df967e8a945e	51cd9900-f6c0-4bf6-9dd3-39277496a6be	2026-07-21 12:23:05.653402+00	2026-07-21 12:23:05.653402+00
97ebd5ca-a1b0-474f-8195-6ee131268149	be682dce-6665-4ff0-8e8a-067602882309	67af3050-a9c5-4024-8366-cd3d2e64905a	2026-07-21 12:23:05.653402+00	2026-07-21 12:23:05.653402+00
97ebd5ca-a1b0-474f-8195-6ee131268149	3cdfd222-0ea4-4a30-b15b-036d1d733193	141dc520-088a-4dd8-abac-2bf187efc805	2026-07-21 12:23:05.653402+00	2026-07-21 12:23:05.653402+00
97ebd5ca-a1b0-474f-8195-6ee131268149	fe6b733f-8cf4-4df1-a83e-2e854a480178	532c37a5-e543-4f0d-94f9-c4e0d9babed3	2026-07-21 12:23:05.653402+00	2026-07-21 12:23:05.653402+00
97ebd5ca-a1b0-474f-8195-6ee131268149	1f7a4d5f-3f0b-4a87-92e9-cf7057b674f5	ae92d579-4469-4741-921c-1c12acd55898	2026-07-21 12:23:05.653402+00	2026-07-21 12:23:05.653402+00
5bf8928f-5573-49a0-9ee7-59b30d16f60c	be682dce-6665-4ff0-8e8a-067602882309	f7499e7b-344d-4330-a5cc-cc7e7dcc38de	2026-07-21 12:23:05.653402+00	2026-07-21 12:23:05.653402+00
5bf8928f-5573-49a0-9ee7-59b30d16f60c	2310cdf5-d549-4a28-bc04-2052038876fc	91268833-2cb9-41f1-b6cc-a9eb45dd5df8	2026-07-21 12:23:05.653402+00	2026-07-21 12:23:05.653402+00
5bf8928f-5573-49a0-9ee7-59b30d16f60c	fe6b733f-8cf4-4df1-a83e-2e854a480178	e225f8b1-80d4-4705-8890-f1d76eb61db9	2026-07-21 12:23:05.653402+00	2026-07-21 12:23:05.653402+00
5bf8928f-5573-49a0-9ee7-59b30d16f60c	220f13de-14e7-4c15-a3c3-d456ccb8f206	b48b4293-e6a5-4e7e-962d-72ac6ef9127b	2026-07-21 12:23:05.653402+00	2026-07-21 12:23:05.653402+00
3e1c6a65-ca90-48f7-ad09-df284b6601d0	be682dce-6665-4ff0-8e8a-067602882309	b3bedb8a-68f3-4864-8713-84dc194d28b0	2026-07-21 12:23:05.653402+00	2026-07-21 12:23:05.653402+00
3e1c6a65-ca90-48f7-ad09-df284b6601d0	37e62239-b7c6-493c-9475-fe700a479e79	772b652d-abd1-4581-957f-43545bcc4c11	2026-07-21 12:23:05.653402+00	2026-07-21 12:23:05.653402+00
3e1c6a65-ca90-48f7-ad09-df284b6601d0	fe6b733f-8cf4-4df1-a83e-2e854a480178	be01b093-2540-40a8-8956-03a235ae05a3	2026-07-21 12:23:05.653402+00	2026-07-21 12:23:05.653402+00
3e1c6a65-ca90-48f7-ad09-df284b6601d0	3cdfd222-0ea4-4a30-b15b-036d1d733193	72133173-fed6-4fd9-ab07-c41a4b6f43fd	2026-07-21 12:23:05.653402+00	2026-07-21 12:23:05.653402+00
e8969525-8440-4cdc-9110-d6b5e43d877f	be682dce-6665-4ff0-8e8a-067602882309	acd77aa8-2d1f-4f38-a90f-e3de02b8694a	2026-07-21 12:23:05.653402+00	2026-07-21 12:23:05.653402+00
e8969525-8440-4cdc-9110-d6b5e43d877f	220f13de-14e7-4c15-a3c3-d456ccb8f206	e6ea71e7-ab4d-4424-a7ed-e754140bbbaa	2026-07-21 12:23:05.653402+00	2026-07-21 12:23:05.653402+00
e8969525-8440-4cdc-9110-d6b5e43d877f	37e62239-b7c6-493c-9475-fe700a479e79	e6af9002-5377-4366-be30-3006641822a1	2026-07-21 12:23:05.653402+00	2026-07-21 12:23:05.653402+00
e8969525-8440-4cdc-9110-d6b5e43d877f	2310cdf5-d549-4a28-bc04-2052038876fc	70ebc6e6-ddbb-4f36-aea3-d04b6d174f63	2026-07-21 12:23:05.653402+00	2026-07-21 12:23:05.653402+00
8788d165-ed7c-43bd-97f4-f1190b5dba5a	be682dce-6665-4ff0-8e8a-067602882309	28d03e35-ef94-4ba5-836c-908ae1b09ca5	2026-07-21 12:23:05.653402+00	2026-07-21 12:23:05.653402+00
8788d165-ed7c-43bd-97f4-f1190b5dba5a	fe6b733f-8cf4-4df1-a83e-2e854a480178	ca012a50-ff0d-4039-85ca-24b3552c9ff4	2026-07-21 12:23:05.653402+00	2026-07-21 12:23:05.653402+00
8788d165-ed7c-43bd-97f4-f1190b5dba5a	2310cdf5-d549-4a28-bc04-2052038876fc	4104b31e-9004-4df6-bfa1-7cbbdf00f7eb	2026-07-21 12:23:05.653402+00	2026-07-21 12:23:05.653402+00
8788d165-ed7c-43bd-97f4-f1190b5dba5a	1f7a4d5f-3f0b-4a87-92e9-cf7057b674f5	92d440bc-8097-4101-9608-4344a0ed559c	2026-07-21 12:23:05.653402+00	2026-07-21 12:23:05.653402+00
\.


--
-- Data for Name: projects; Type: TABLE DATA; Schema: public; Owner: -
--

COPY public.projects (organization_id, name, description, start_date, end_date, status, created_by_id, id, created_at, updated_at, manager_id, department_id) FROM stdin;
9e026bc3-66b8-45d7-9c60-0989a6664192	بازطراحی وب‌سایت شرکتی	پروژهٔ مهندسی و فنی شماره 1	2026-06-01	2026-08-16	active	817e2843-948e-4775-a2b7-3ded2f04feca	9d142217-431d-4a0a-960e-8c6f0912f432	2026-07-21 12:23:05.653402+00	2026-07-21 12:23:05.653402+00	75bbbdd2-5d00-4257-8e1e-c3881eebcf0e	6e484715-c164-4c7b-b7a9-0a5b47a188a1
9e026bc3-66b8-45d7-9c60-0989a6664192	توسعهٔ اپلیکیشن موبایل فروش	پروژهٔ مهندسی و فنی شماره 2	2026-04-28	2026-06-23	active	817e2843-948e-4775-a2b7-3ded2f04feca	bc18bca7-068d-4da6-a685-0070c009fe9f	2026-07-21 12:23:05.653402+00	2026-07-21 12:23:05.653402+00	75bbbdd2-5d00-4257-8e1e-c3881eebcf0e	6e484715-c164-4c7b-b7a9-0a5b47a188a1
9e026bc3-66b8-45d7-9c60-0989a6664192	مهاجرت زیرساخت به ابر	پروژهٔ مهندسی و فنی شماره 3	2026-07-03	2026-08-28	active	817e2843-948e-4775-a2b7-3ded2f04feca	536e0e82-9dc4-4808-bd74-0dd75b0f2f8b	2026-07-21 12:23:05.653402+00	2026-07-21 12:23:05.653402+00	75bbbdd2-5d00-4257-8e1e-c3881eebcf0e	6e484715-c164-4c7b-b7a9-0a5b47a188a1
9e026bc3-66b8-45d7-9c60-0989a6664192	پیاده‌سازی سامانهٔ مانیتورینگ	پروژهٔ مهندسی و فنی شماره 4	2026-04-26	2026-07-05	active	817e2843-948e-4775-a2b7-3ded2f04feca	a2a211cb-0f9f-4af5-9766-66228a587300	2026-07-21 12:23:05.653402+00	2026-07-21 12:23:05.653402+00	75bbbdd2-5d00-4257-8e1e-c3881eebcf0e	6e484715-c164-4c7b-b7a9-0a5b47a188a1
9e026bc3-66b8-45d7-9c60-0989a6664192	بهبود عملکرد پایگاه‌داده	پروژهٔ مهندسی و فنی شماره 5	2026-06-08	2026-09-18	active	817e2843-948e-4775-a2b7-3ded2f04feca	40af2561-cb3f-4189-8722-0d90cf4e2a77	2026-07-21 12:23:05.653402+00	2026-07-21 12:23:05.653402+00	75bbbdd2-5d00-4257-8e1e-c3881eebcf0e	6e484715-c164-4c7b-b7a9-0a5b47a188a1
9e026bc3-66b8-45d7-9c60-0989a6664192	بستن حساب‌های مالی سال	پروژهٔ حسابداری و مالی شماره 1	2026-05-22	2026-10-13	active	817e2843-948e-4775-a2b7-3ded2f04feca	b2e41607-118c-4f69-a751-b623cfe694a9	2026-07-21 12:23:05.653402+00	2026-07-21 12:23:05.653402+00	0aa7f564-65bd-473d-aa0e-3abc4663b507	167ce15f-9954-4a63-a93b-54f6d1c3b955
9e026bc3-66b8-45d7-9c60-0989a6664192	پیاده‌سازی سامانهٔ فاکتور الکترونیک	پروژهٔ حسابداری و مالی شماره 2	2026-06-21	2026-11-15	active	817e2843-948e-4775-a2b7-3ded2f04feca	432d011d-9811-4926-818f-2b63ae8aa481	2026-07-21 12:23:05.653402+00	2026-07-21 12:23:05.653402+00	0aa7f564-65bd-473d-aa0e-3abc4663b507	167ce15f-9954-4a63-a93b-54f6d1c3b955
9e026bc3-66b8-45d7-9c60-0989a6664192	ممیزی مالی سه‌ماههٔ دوم	پروژهٔ حسابداری و مالی شماره 3	2026-05-11	2026-08-13	active	817e2843-948e-4775-a2b7-3ded2f04feca	dfc1e39f-343f-43e4-a459-9626f69442a6	2026-07-21 12:23:05.653402+00	2026-07-21 12:23:05.653402+00	0aa7f564-65bd-473d-aa0e-3abc4663b507	167ce15f-9954-4a63-a93b-54f6d1c3b955
9e026bc3-66b8-45d7-9c60-0989a6664192	تدوین بودجهٔ سال آینده	پروژهٔ حسابداری و مالی شماره 4	2026-05-04	2026-08-04	active	817e2843-948e-4775-a2b7-3ded2f04feca	776f6076-91bd-4f6d-8fcd-ada6f5d2a107	2026-07-21 12:23:05.653402+00	2026-07-21 12:23:05.653402+00	0aa7f564-65bd-473d-aa0e-3abc4663b507	167ce15f-9954-4a63-a93b-54f6d1c3b955
9e026bc3-66b8-45d7-9c60-0989a6664192	مدیریت مطالبات و بدهی‌ها	پروژهٔ حسابداری و مالی شماره 5	2026-05-13	2026-07-07	active	817e2843-948e-4775-a2b7-3ded2f04feca	f8f67ced-14a7-481c-8f04-dbff36848e4e	2026-07-21 12:23:05.653402+00	2026-07-21 12:23:05.653402+00	0aa7f564-65bd-473d-aa0e-3abc4663b507	167ce15f-9954-4a63-a93b-54f6d1c3b955
9e026bc3-66b8-45d7-9c60-0989a6664192	برگزاری دورهٔ آموزشی کارکنان	پروژهٔ منابع انسانی شماره 1	2026-05-04	2026-08-26	active	817e2843-948e-4775-a2b7-3ded2f04feca	97ebd5ca-a1b0-474f-8195-6ee131268149	2026-07-21 12:23:05.653402+00	2026-07-21 12:23:05.653402+00	be682dce-6665-4ff0-8e8a-067602882309	13fe4056-fcc6-4d8b-9bb2-6444c12239a5
9e026bc3-66b8-45d7-9c60-0989a6664192	بازطراحی فرایند جذب و استخدام	پروژهٔ منابع انسانی شماره 2	2026-07-02	2026-08-27	active	817e2843-948e-4775-a2b7-3ded2f04feca	5bf8928f-5573-49a0-9ee7-59b30d16f60c	2026-07-21 12:23:05.653402+00	2026-07-21 12:23:05.653402+00	be682dce-6665-4ff0-8e8a-067602882309	13fe4056-fcc6-4d8b-9bb2-6444c12239a5
9e026bc3-66b8-45d7-9c60-0989a6664192	ارزیابی عملکرد سالانهٔ کارکنان	پروژهٔ منابع انسانی شماره 3	2026-07-04	2026-10-24	active	817e2843-948e-4775-a2b7-3ded2f04feca	3e1c6a65-ca90-48f7-ad09-df284b6601d0	2026-07-21 12:23:05.653402+00	2026-07-21 12:23:05.653402+00	be682dce-6665-4ff0-8e8a-067602882309	13fe4056-fcc6-4d8b-9bb2-6444c12239a5
9e026bc3-66b8-45d7-9c60-0989a6664192	طراحی برنامهٔ رفاهی کارکنان	پروژهٔ منابع انسانی شماره 4	2026-04-19	2026-06-28	active	817e2843-948e-4775-a2b7-3ded2f04feca	e8969525-8440-4cdc-9110-d6b5e43d877f	2026-07-21 12:23:05.653402+00	2026-07-21 12:23:05.653402+00	be682dce-6665-4ff0-8e8a-067602882309	13fe4056-fcc6-4d8b-9bb2-6444c12239a5
9e026bc3-66b8-45d7-9c60-0989a6664192	پیاده‌سازی سامانهٔ حضور و غیاب	پروژهٔ منابع انسانی شماره 5	2026-05-26	2026-07-17	active	817e2843-948e-4775-a2b7-3ded2f04feca	8788d165-ed7c-43bd-97f4-f1190b5dba5a	2026-07-21 12:23:05.653402+00	2026-07-21 12:23:05.653402+00	be682dce-6665-4ff0-8e8a-067602882309	13fe4056-fcc6-4d8b-9bb2-6444c12239a5
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
9e026bc3-66b8-45d7-9c60-0989a6664192	9d142217-431d-4a0a-960e-8c6f0912f432	\N	6b87e773-3d93-47db-8dc6-37ca0e6e9b32	75bbbdd2-5d00-4257-8e1e-c3881eebcf0e	رفع مشکل ناسازگاری مرورگر #1	\N	low	2026-08-08	80b7e505-b2e2-4615-b191-6aa2d479fb86	2026-07-21 12:23:05.653402+00	2026-07-21 12:23:05.653402+00	in_progress	\N	54	14.90	2026-08-06	medium
9e026bc3-66b8-45d7-9c60-0989a6664192	9d142217-431d-4a0a-960e-8c6f0912f432	\N	24e34af4-1229-4d93-8615-b8479b51a37c	75bbbdd2-5d00-4257-8e1e-c3881eebcf0e	پیاده‌سازی صفحهٔ ورود جدید #2	\N	low	2026-08-15	c5e73729-c2f0-4605-b8ae-2f03e19c9284	2026-07-21 12:23:05.653402+00	2026-07-21 12:23:05.653402+00	in_progress	\N	48	5.70	2026-08-03	medium
9e026bc3-66b8-45d7-9c60-0989a6664192	9d142217-431d-4a0a-960e-8c6f0912f432	\N	8c7cac5d-349c-4d45-ab78-f4e52554d784	75bbbdd2-5d00-4257-8e1e-c3881eebcf0e	رفع مشکل ناسازگاری مرورگر #3	\N	low	2026-08-03	5616b639-ee13-4b34-8cf9-cd29e32f2919	2026-07-21 12:23:05.653402+00	2026-07-21 12:23:05.653402+00	in_progress	\N	58	22.40	2026-07-24	medium
9e026bc3-66b8-45d7-9c60-0989a6664192	9d142217-431d-4a0a-960e-8c6f0912f432	\N	7e07497e-be59-442a-82ad-943e3bd502bb	75bbbdd2-5d00-4257-8e1e-c3881eebcf0e	بازنویسی ماژول اعلان‌ها #4	\N	high	2026-08-01	a38f2c1b-780d-431d-90d8-53a61a45115a	2026-07-21 12:23:05.653402+00	2026-07-21 12:23:05.653402+00	todo	\N	79	35.60	2026-07-21	medium
9e026bc3-66b8-45d7-9c60-0989a6664192	9d142217-431d-4a0a-960e-8c6f0912f432	\N	dbe12768-1ffa-4f9b-8327-4558c4438ef6	75bbbdd2-5d00-4257-8e1e-c3881eebcf0e	تنظیم پایپ‌لاین CI/CD #5	\N	low	2026-06-23	7d81592f-3335-49df-a269-8a8ec5b0c833	2026-07-21 12:23:05.653402+00	2026-07-21 12:23:05.653402+00	completed	approved	100	31.40	2026-06-20	medium
9e026bc3-66b8-45d7-9c60-0989a6664192	9d142217-431d-4a0a-960e-8c6f0912f432	\N	75bbbdd2-5d00-4257-8e1e-c3881eebcf0e	75bbbdd2-5d00-4257-8e1e-c3881eebcf0e	پیاده‌سازی احراز هویت دومرحله‌ای #6	\N	medium	2026-08-15	c6fe217b-6f18-4a84-addd-10458f437c50	2026-07-21 12:23:05.653402+00	2026-07-21 12:23:05.653402+00	in_progress	\N	58	26.20	2026-08-10	medium
9e026bc3-66b8-45d7-9c60-0989a6664192	9d142217-431d-4a0a-960e-8c6f0912f432	\N	dbe12768-1ffa-4f9b-8327-4558c4438ef6	75bbbdd2-5d00-4257-8e1e-c3881eebcf0e	افزودن تست واحد برای سرویس کاربران #7	\N	high	2026-07-22	99799cba-da5e-4e52-a7af-918721dfeac2	2026-07-21 12:23:05.653402+00	2026-07-21 12:23:05.653402+00	todo	\N	34	28.70	2026-07-09	medium
9e026bc3-66b8-45d7-9c60-0989a6664192	9d142217-431d-4a0a-960e-8c6f0912f432	\N	ad47309d-1c75-4d68-b779-348021512719	75bbbdd2-5d00-4257-8e1e-c3881eebcf0e	به‌روزرسانی کتابخانه‌های وابسته #8	\N	high	2026-08-02	b96e5c7b-a83e-4f53-a93c-a3569d39f792	2026-07-21 12:23:05.653402+00	2026-07-21 12:23:05.653402+00	completed	approved	100	11.30	2026-07-26	medium
9e026bc3-66b8-45d7-9c60-0989a6664192	9d142217-431d-4a0a-960e-8c6f0912f432	\N	7e07497e-be59-442a-82ad-943e3bd502bb	75bbbdd2-5d00-4257-8e1e-c3881eebcf0e	افزودن تست واحد برای سرویس کاربران #9	\N	high	2026-07-22	d092395f-c497-4ed1-ab80-39a29194ba05	2026-07-21 12:23:05.653402+00	2026-07-21 12:23:05.653402+00	in_progress	\N	41	34.00	2026-07-03	medium
9e026bc3-66b8-45d7-9c60-0989a6664192	9d142217-431d-4a0a-960e-8c6f0912f432	\N	8c7cac5d-349c-4d45-ab78-f4e52554d784	75bbbdd2-5d00-4257-8e1e-c3881eebcf0e	رفع مشکل ناسازگاری مرورگر #10	\N	medium	2026-07-03	8316df8b-ae5b-44c1-ac6e-e5e6c7326ba6	2026-07-21 12:23:05.653402+00	2026-07-21 12:23:05.653402+00	todo	\N	51	12.20	2026-06-30	medium
9e026bc3-66b8-45d7-9c60-0989a6664192	9d142217-431d-4a0a-960e-8c6f0912f432	\N	24e34af4-1229-4d93-8615-b8479b51a37c	75bbbdd2-5d00-4257-8e1e-c3881eebcf0e	تنظیم پایپ‌لاین CI/CD #11	\N	medium	2026-07-14	e0afa379-b68c-4b65-9461-8e1f4401762e	2026-07-21 12:23:05.653402+00	2026-07-21 12:23:05.653402+00	completed	pending	100	17.00	2026-07-06	medium
9e026bc3-66b8-45d7-9c60-0989a6664192	9d142217-431d-4a0a-960e-8c6f0912f432	\N	ad47309d-1c75-4d68-b779-348021512719	75bbbdd2-5d00-4257-8e1e-c3881eebcf0e	نوشتن مستندات فنی API #12	\N	high	2026-07-03	2bc046ad-45fb-479a-9dfd-f79a1815bd94	2026-07-21 12:23:05.653402+00	2026-07-21 12:23:05.653402+00	completed	approved	100	22.50	2026-06-24	medium
9e026bc3-66b8-45d7-9c60-0989a6664192	9d142217-431d-4a0a-960e-8c6f0912f432	\N	ad47309d-1c75-4d68-b779-348021512719	75bbbdd2-5d00-4257-8e1e-c3881eebcf0e	رفع مشکل کندی بارگذاری صفحه #13	\N	low	2026-08-06	ae5bf3b0-e950-4481-918c-c8a9eb0f6bb3	2026-07-21 12:23:05.653402+00	2026-07-21 12:23:05.653402+00	completed	approved	100	39.90	2026-07-23	medium
9e026bc3-66b8-45d7-9c60-0989a6664192	9d142217-431d-4a0a-960e-8c6f0912f432	\N	24e34af4-1229-4d93-8615-b8479b51a37c	75bbbdd2-5d00-4257-8e1e-c3881eebcf0e	بازنویسی ماژول اعلان‌ها #14	\N	low	2026-08-06	c6121599-2b02-4d9a-a2e9-50c293a10027	2026-07-21 12:23:05.653402+00	2026-07-21 12:23:05.653402+00	completed	approved	100	7.80	2026-08-03	medium
9e026bc3-66b8-45d7-9c60-0989a6664192	9d142217-431d-4a0a-960e-8c6f0912f432	\N	24e34af4-1229-4d93-8615-b8479b51a37c	75bbbdd2-5d00-4257-8e1e-c3881eebcf0e	پیاده‌سازی احراز هویت دومرحله‌ای #15	\N	high	2026-07-04	d4dbccdf-1a00-442c-86e3-e2948db5defd	2026-07-21 12:23:05.653402+00	2026-07-21 12:23:05.653402+00	completed	approved	100	39.90	2026-06-20	medium
9e026bc3-66b8-45d7-9c60-0989a6664192	9d142217-431d-4a0a-960e-8c6f0912f432	\N	6b87e773-3d93-47db-8dc6-37ca0e6e9b32	75bbbdd2-5d00-4257-8e1e-c3881eebcf0e	تنظیم پایپ‌لاین CI/CD #16	\N	high	2026-07-23	c3c8ddd0-30ac-42d2-8e0e-36fb3434b812	2026-07-21 12:23:05.653402+00	2026-07-21 12:23:05.653402+00	in_progress	\N	14	27.90	2026-07-21	medium
9e026bc3-66b8-45d7-9c60-0989a6664192	9d142217-431d-4a0a-960e-8c6f0912f432	\N	6b87e773-3d93-47db-8dc6-37ca0e6e9b32	75bbbdd2-5d00-4257-8e1e-c3881eebcf0e	پیاده‌سازی صفحهٔ ورود جدید #17	\N	medium	2026-07-15	ca7ca224-33f7-41bb-ae0c-19e75d269597	2026-07-21 12:23:05.653402+00	2026-07-21 12:23:05.653402+00	archived	\N	55	8.00	2026-07-03	medium
9e026bc3-66b8-45d7-9c60-0989a6664192	9d142217-431d-4a0a-960e-8c6f0912f432	\N	75bbbdd2-5d00-4257-8e1e-c3881eebcf0e	75bbbdd2-5d00-4257-8e1e-c3881eebcf0e	به‌روزرسانی کتابخانه‌های وابسته #18	\N	low	2026-08-21	86bfacbc-4e94-4412-b954-f6dfa54a194b	2026-07-21 12:23:05.653402+00	2026-07-21 12:23:05.653402+00	archived	\N	64	36.70	2026-08-11	medium
9e026bc3-66b8-45d7-9c60-0989a6664192	bc18bca7-068d-4da6-a685-0070c009fe9f	\N	8c7cac5d-349c-4d45-ab78-f4e52554d784	75bbbdd2-5d00-4257-8e1e-c3881eebcf0e	پیاده‌سازی صفحهٔ داشبورد مدیریتی #19	\N	low	2026-08-13	a5499073-6ec6-490c-84b7-841409ecc6be	2026-07-21 12:23:05.653402+00	2026-07-21 12:23:05.653402+00	completed	approved	100	7.80	2026-07-26	medium
9e026bc3-66b8-45d7-9c60-0989a6664192	bc18bca7-068d-4da6-a685-0070c009fe9f	\N	8c7cac5d-349c-4d45-ab78-f4e52554d784	75bbbdd2-5d00-4257-8e1e-c3881eebcf0e	افزودن قابلیت جست‌وجوی پیشرفته #20	\N	low	2026-08-07	1bfa1a34-c02f-4a3e-9b61-2fa469138efe	2026-07-21 12:23:05.653402+00	2026-07-21 12:23:05.653402+00	todo	\N	76	14.30	2026-07-20	medium
9e026bc3-66b8-45d7-9c60-0989a6664192	bc18bca7-068d-4da6-a685-0070c009fe9f	\N	75bbbdd2-5d00-4257-8e1e-c3881eebcf0e	75bbbdd2-5d00-4257-8e1e-c3881eebcf0e	افزودن قابلیت جست‌وجوی پیشرفته #21	\N	medium	2026-08-27	28969389-77fb-4e3b-a075-c83eaeac163c	2026-07-21 12:23:05.653402+00	2026-07-21 12:23:05.653402+00	todo	\N	30	4.20	2026-08-14	medium
9e026bc3-66b8-45d7-9c60-0989a6664192	bc18bca7-068d-4da6-a685-0070c009fe9f	\N	6b87e773-3d93-47db-8dc6-37ca0e6e9b32	75bbbdd2-5d00-4257-8e1e-c3881eebcf0e	بازنویسی ماژول اعلان‌ها #22	\N	low	2026-07-08	e555d5c4-d2a2-466c-887f-0eb9480dc5fe	2026-07-21 12:23:05.653402+00	2026-07-21 12:23:05.653402+00	todo	\N	68	31.10	2026-06-21	medium
9e026bc3-66b8-45d7-9c60-0989a6664192	bc18bca7-068d-4da6-a685-0070c009fe9f	\N	24e34af4-1229-4d93-8615-b8479b51a37c	75bbbdd2-5d00-4257-8e1e-c3881eebcf0e	طراحی API نسخهٔ دوم #23	\N	high	2026-07-28	64932e7e-ec78-4b39-ba42-cab3e667bc53	2026-07-21 12:23:05.653402+00	2026-07-21 12:23:05.653402+00	completed	approved	100	35.20	2026-07-21	medium
9e026bc3-66b8-45d7-9c60-0989a6664192	bc18bca7-068d-4da6-a685-0070c009fe9f	\N	7e07497e-be59-442a-82ad-943e3bd502bb	75bbbdd2-5d00-4257-8e1e-c3881eebcf0e	رفع مشکل ناسازگاری مرورگر #24	\N	high	2026-09-02	9d4696f2-d864-4245-a6fa-42999537ce31	2026-07-21 12:23:05.653402+00	2026-07-21 12:23:05.653402+00	in_progress	\N	25	29.10	2026-08-14	medium
9e026bc3-66b8-45d7-9c60-0989a6664192	bc18bca7-068d-4da6-a685-0070c009fe9f	\N	7e07497e-be59-442a-82ad-943e3bd502bb	75bbbdd2-5d00-4257-8e1e-c3881eebcf0e	بررسی و رفع آسیب‌پذیری امنیتی #25	\N	low	2026-08-01	5caa0362-108a-42ab-aa0f-f3fc672edaa2	2026-07-21 12:23:05.653402+00	2026-07-21 12:23:05.653402+00	completed	pending	100	11.40	2026-07-14	medium
9e026bc3-66b8-45d7-9c60-0989a6664192	bc18bca7-068d-4da6-a685-0070c009fe9f	\N	75bbbdd2-5d00-4257-8e1e-c3881eebcf0e	75bbbdd2-5d00-4257-8e1e-c3881eebcf0e	به‌روزرسانی کتابخانه‌های وابسته #26	\N	low	2026-07-07	d93fb70e-c209-4316-8bcb-c30bb27a2e17	2026-07-21 12:23:05.653402+00	2026-07-21 12:23:05.653402+00	in_progress	\N	75	10.40	2026-06-17	medium
9e026bc3-66b8-45d7-9c60-0989a6664192	bc18bca7-068d-4da6-a685-0070c009fe9f	\N	75bbbdd2-5d00-4257-8e1e-c3881eebcf0e	75bbbdd2-5d00-4257-8e1e-c3881eebcf0e	افزودن تست واحد برای سرویس کاربران #27	\N	low	2026-07-29	7b8ba467-7d0c-4e81-b296-49743f17ab66	2026-07-21 12:23:05.653402+00	2026-07-21 12:23:05.653402+00	archived	\N	4	34.70	2026-07-26	medium
9e026bc3-66b8-45d7-9c60-0989a6664192	bc18bca7-068d-4da6-a685-0070c009fe9f	\N	75bbbdd2-5d00-4257-8e1e-c3881eebcf0e	75bbbdd2-5d00-4257-8e1e-c3881eebcf0e	افزودن تست واحد برای سرویس کاربران #28	\N	high	2026-08-14	ab9670f6-32ee-42f5-a014-875b701dd355	2026-07-21 12:23:05.653402+00	2026-07-21 12:23:05.653402+00	completed	approved	100	7.00	2026-07-28	medium
9e026bc3-66b8-45d7-9c60-0989a6664192	bc18bca7-068d-4da6-a685-0070c009fe9f	\N	6b87e773-3d93-47db-8dc6-37ca0e6e9b32	75bbbdd2-5d00-4257-8e1e-c3881eebcf0e	رفع مشکل ناسازگاری مرورگر #29	\N	medium	2026-08-22	5dd2ce54-221d-4f4c-8a18-c929c7a8447a	2026-07-21 12:23:05.653402+00	2026-07-21 12:23:05.653402+00	completed	approved	100	9.20	2026-08-05	medium
9e026bc3-66b8-45d7-9c60-0989a6664192	bc18bca7-068d-4da6-a685-0070c009fe9f	\N	75bbbdd2-5d00-4257-8e1e-c3881eebcf0e	75bbbdd2-5d00-4257-8e1e-c3881eebcf0e	بررسی و رفع آسیب‌پذیری امنیتی #30	\N	high	2026-07-28	73d2938c-5350-4afe-a62d-01d192c02187	2026-07-21 12:23:05.653402+00	2026-07-21 12:23:05.653402+00	completed	approved	100	4.10	2026-07-13	medium
9e026bc3-66b8-45d7-9c60-0989a6664192	bc18bca7-068d-4da6-a685-0070c009fe9f	\N	ad47309d-1c75-4d68-b779-348021512719	75bbbdd2-5d00-4257-8e1e-c3881eebcf0e	رفع مشکل ناسازگاری مرورگر #31	\N	low	2026-07-23	8211d3d9-326b-46f2-8db1-1f3b7b9cee86	2026-07-21 12:23:05.653402+00	2026-07-21 12:23:05.653402+00	completed	approved	100	11.40	2026-07-11	medium
9e026bc3-66b8-45d7-9c60-0989a6664192	bc18bca7-068d-4da6-a685-0070c009fe9f	\N	24e34af4-1229-4d93-8615-b8479b51a37c	75bbbdd2-5d00-4257-8e1e-c3881eebcf0e	طراحی API نسخهٔ دوم #32	\N	medium	2026-07-20	3a720c1c-dd7b-4a63-b2a2-2f09d52d94c9	2026-07-21 12:23:05.653402+00	2026-07-21 12:23:05.653402+00	completed	approved	100	11.50	2026-07-13	medium
9e026bc3-66b8-45d7-9c60-0989a6664192	bc18bca7-068d-4da6-a685-0070c009fe9f	\N	75bbbdd2-5d00-4257-8e1e-c3881eebcf0e	75bbbdd2-5d00-4257-8e1e-c3881eebcf0e	پیاده‌سازی صفحهٔ ورود جدید #33	\N	low	2026-08-28	b5ccf468-16dc-4073-8429-c2f06428aaeb	2026-07-21 12:23:05.653402+00	2026-07-21 12:23:05.653402+00	completed	pending	100	26.80	2026-08-09	medium
9e026bc3-66b8-45d7-9c60-0989a6664192	bc18bca7-068d-4da6-a685-0070c009fe9f	\N	6b87e773-3d93-47db-8dc6-37ca0e6e9b32	75bbbdd2-5d00-4257-8e1e-c3881eebcf0e	بهینه‌سازی کوئری‌های گزارش‌گیری #34	\N	medium	2026-06-30	4f25d800-cf4a-4aae-9e32-a4e47aad388b	2026-07-21 12:23:05.653402+00	2026-07-21 12:23:05.653402+00	todo	\N	62	20.30	2026-06-21	medium
9e026bc3-66b8-45d7-9c60-0989a6664192	bc18bca7-068d-4da6-a685-0070c009fe9f	\N	8c7cac5d-349c-4d45-ab78-f4e52554d784	75bbbdd2-5d00-4257-8e1e-c3881eebcf0e	بهینه‌سازی کوئری‌های گزارش‌گیری #35	\N	medium	2026-08-15	fcabcba8-7531-4e0f-bac2-ca36c92ca763	2026-07-21 12:23:05.653402+00	2026-07-21 12:23:05.653402+00	in_progress	\N	0	39.40	2026-08-12	medium
9e026bc3-66b8-45d7-9c60-0989a6664192	bc18bca7-068d-4da6-a685-0070c009fe9f	\N	dbe12768-1ffa-4f9b-8327-4558c4438ef6	75bbbdd2-5d00-4257-8e1e-c3881eebcf0e	تنظیم پایپ‌لاین CI/CD #36	\N	high	2026-08-18	d388542e-9175-4e01-b686-79fffc764213	2026-07-21 12:23:05.653402+00	2026-07-21 12:23:05.653402+00	completed	approved	100	20.50	2026-07-30	medium
9e026bc3-66b8-45d7-9c60-0989a6664192	536e0e82-9dc4-4808-bd74-0dd75b0f2f8b	\N	24e34af4-1229-4d93-8615-b8479b51a37c	75bbbdd2-5d00-4257-8e1e-c3881eebcf0e	پیاده‌سازی صفحهٔ داشبورد مدیریتی #37	\N	high	2026-07-02	42a8743b-fee7-4961-a27f-f80c6193d70b	2026-07-21 12:23:05.653402+00	2026-07-21 12:23:05.653402+00	in_progress	\N	69	4.30	2026-06-29	medium
9e026bc3-66b8-45d7-9c60-0989a6664192	536e0e82-9dc4-4808-bd74-0dd75b0f2f8b	\N	dbe12768-1ffa-4f9b-8327-4558c4438ef6	75bbbdd2-5d00-4257-8e1e-c3881eebcf0e	بررسی و رفع آسیب‌پذیری امنیتی #38	\N	high	2026-07-09	27ad9c58-c64a-44b6-8ea1-b7dae95558b5	2026-07-21 12:23:05.653402+00	2026-07-21 12:23:05.653402+00	todo	\N	67	8.00	2026-06-19	medium
9e026bc3-66b8-45d7-9c60-0989a6664192	536e0e82-9dc4-4808-bd74-0dd75b0f2f8b	\N	6b87e773-3d93-47db-8dc6-37ca0e6e9b32	75bbbdd2-5d00-4257-8e1e-c3881eebcf0e	پیاده‌سازی صفحهٔ ورود جدید #39	\N	high	2026-08-16	bda5a512-95dc-4f2e-97ba-9953a877ae54	2026-07-21 12:23:05.653402+00	2026-07-21 12:23:05.653402+00	todo	\N	8	27.70	2026-08-09	medium
9e026bc3-66b8-45d7-9c60-0989a6664192	536e0e82-9dc4-4808-bd74-0dd75b0f2f8b	\N	24e34af4-1229-4d93-8615-b8479b51a37c	75bbbdd2-5d00-4257-8e1e-c3881eebcf0e	افزودن تست واحد برای سرویس کاربران #40	\N	high	2026-07-13	de2d0846-7d62-457f-8570-b56bb4e6ef9e	2026-07-21 12:23:05.653402+00	2026-07-21 12:23:05.653402+00	in_progress	\N	76	3.50	2026-06-23	medium
9e026bc3-66b8-45d7-9c60-0989a6664192	536e0e82-9dc4-4808-bd74-0dd75b0f2f8b	\N	75bbbdd2-5d00-4257-8e1e-c3881eebcf0e	75bbbdd2-5d00-4257-8e1e-c3881eebcf0e	پیاده‌سازی صفحهٔ داشبورد مدیریتی #41	\N	high	2026-08-17	7985ff09-e0c3-433c-ac26-5c42f9a8c12d	2026-07-21 12:23:05.653402+00	2026-07-21 12:23:05.653402+00	in_progress	\N	40	37.50	2026-07-28	medium
9e026bc3-66b8-45d7-9c60-0989a6664192	536e0e82-9dc4-4808-bd74-0dd75b0f2f8b	\N	24e34af4-1229-4d93-8615-b8479b51a37c	75bbbdd2-5d00-4257-8e1e-c3881eebcf0e	پیاده‌سازی احراز هویت دومرحله‌ای #42	\N	low	2026-07-11	84bae8c9-d2f3-47b4-bf55-23c14b31ee60	2026-07-21 12:23:05.653402+00	2026-07-21 12:23:05.653402+00	completed	pending	100	27.50	2026-07-01	medium
9e026bc3-66b8-45d7-9c60-0989a6664192	536e0e82-9dc4-4808-bd74-0dd75b0f2f8b	\N	dbe12768-1ffa-4f9b-8327-4558c4438ef6	75bbbdd2-5d00-4257-8e1e-c3881eebcf0e	رفع باگ در ماژول پرداخت #43	\N	medium	2026-08-07	1b46a05c-2f78-4c1f-b12f-14135e4007b2	2026-07-21 12:23:05.653402+00	2026-07-21 12:23:05.653402+00	completed	approved	100	25.60	2026-08-03	medium
9e026bc3-66b8-45d7-9c60-0989a6664192	536e0e82-9dc4-4808-bd74-0dd75b0f2f8b	\N	6b87e773-3d93-47db-8dc6-37ca0e6e9b32	75bbbdd2-5d00-4257-8e1e-c3881eebcf0e	افزودن تست واحد برای سرویس کاربران #44	\N	high	2026-07-09	3827b85f-e301-4012-8982-8e108a9b7b13	2026-07-21 12:23:05.653402+00	2026-07-21 12:23:05.653402+00	todo	\N	33	7.00	2026-06-20	medium
9e026bc3-66b8-45d7-9c60-0989a6664192	536e0e82-9dc4-4808-bd74-0dd75b0f2f8b	\N	dbe12768-1ffa-4f9b-8327-4558c4438ef6	75bbbdd2-5d00-4257-8e1e-c3881eebcf0e	رفع مشکل کندی بارگذاری صفحه #45	\N	medium	2026-08-20	1fef5acf-bccc-46bd-b2ea-7bdbbada6b32	2026-07-21 12:23:05.653402+00	2026-07-21 12:23:05.653402+00	todo	\N	20	18.70	2026-08-11	medium
9e026bc3-66b8-45d7-9c60-0989a6664192	536e0e82-9dc4-4808-bd74-0dd75b0f2f8b	\N	6b87e773-3d93-47db-8dc6-37ca0e6e9b32	75bbbdd2-5d00-4257-8e1e-c3881eebcf0e	رفع مشکل ناسازگاری مرورگر #46	\N	high	2026-07-26	98dcd0d1-1ca9-45eb-a46e-8aa3bbac9a55	2026-07-21 12:23:05.653402+00	2026-07-21 12:23:05.653402+00	archived	\N	67	2.30	2026-07-05	medium
9e026bc3-66b8-45d7-9c60-0989a6664192	536e0e82-9dc4-4808-bd74-0dd75b0f2f8b	\N	8c7cac5d-349c-4d45-ab78-f4e52554d784	75bbbdd2-5d00-4257-8e1e-c3881eebcf0e	افزودن قابلیت جست‌وجوی پیشرفته #47	\N	low	2026-08-02	fd54df2d-c561-41c4-8733-5df88c76024d	2026-07-21 12:23:05.653402+00	2026-07-21 12:23:05.653402+00	completed	approved	100	12.00	2026-07-28	medium
9e026bc3-66b8-45d7-9c60-0989a6664192	536e0e82-9dc4-4808-bd74-0dd75b0f2f8b	\N	75bbbdd2-5d00-4257-8e1e-c3881eebcf0e	75bbbdd2-5d00-4257-8e1e-c3881eebcf0e	طراحی API نسخهٔ دوم #48	\N	medium	2026-07-27	c98fb204-ee4c-48e7-b484-1bbb53138a4c	2026-07-21 12:23:05.653402+00	2026-07-21 12:23:05.653402+00	archived	\N	77	10.00	2026-07-21	medium
9e026bc3-66b8-45d7-9c60-0989a6664192	536e0e82-9dc4-4808-bd74-0dd75b0f2f8b	\N	dbe12768-1ffa-4f9b-8327-4558c4438ef6	75bbbdd2-5d00-4257-8e1e-c3881eebcf0e	به‌روزرسانی کتابخانه‌های وابسته #49	\N	medium	2026-08-08	4368f01b-93b2-4250-9079-c8ee2d86d9bb	2026-07-21 12:23:05.653402+00	2026-07-21 12:23:05.653402+00	in_progress	\N	32	36.40	2026-07-29	medium
9e026bc3-66b8-45d7-9c60-0989a6664192	536e0e82-9dc4-4808-bd74-0dd75b0f2f8b	\N	8c7cac5d-349c-4d45-ab78-f4e52554d784	75bbbdd2-5d00-4257-8e1e-c3881eebcf0e	بازنویسی ماژول اعلان‌ها #50	\N	medium	2026-07-06	16fe847e-28c0-4498-b758-f9a9e3e770f7	2026-07-21 12:23:05.653402+00	2026-07-21 12:23:05.653402+00	todo	\N	5	2.10	2026-06-21	medium
9e026bc3-66b8-45d7-9c60-0989a6664192	536e0e82-9dc4-4808-bd74-0dd75b0f2f8b	\N	8c7cac5d-349c-4d45-ab78-f4e52554d784	75bbbdd2-5d00-4257-8e1e-c3881eebcf0e	بهینه‌سازی کوئری‌های گزارش‌گیری #51	\N	high	2026-08-05	71dd9885-e5c3-4508-906a-53c945de7e13	2026-07-21 12:23:05.653402+00	2026-07-21 12:23:05.653402+00	todo	\N	56	23.00	2026-07-26	medium
9e026bc3-66b8-45d7-9c60-0989a6664192	536e0e82-9dc4-4808-bd74-0dd75b0f2f8b	\N	7e07497e-be59-442a-82ad-943e3bd502bb	75bbbdd2-5d00-4257-8e1e-c3881eebcf0e	به‌روزرسانی کتابخانه‌های وابسته #52	\N	low	2026-06-26	d8ffefef-037c-4ece-8197-b4cb5e613bda	2026-07-21 12:23:05.653402+00	2026-07-21 12:23:05.653402+00	completed	approved	100	33.70	2026-06-20	medium
9e026bc3-66b8-45d7-9c60-0989a6664192	536e0e82-9dc4-4808-bd74-0dd75b0f2f8b	\N	6b87e773-3d93-47db-8dc6-37ca0e6e9b32	75bbbdd2-5d00-4257-8e1e-c3881eebcf0e	طراحی API نسخهٔ دوم #53	\N	medium	2026-06-27	b775d91e-e5a2-4ad9-8c8e-8656ea113eab	2026-07-21 12:23:05.653402+00	2026-07-21 12:23:05.653402+00	completed	approved	100	36.20	2026-06-24	medium
9e026bc3-66b8-45d7-9c60-0989a6664192	536e0e82-9dc4-4808-bd74-0dd75b0f2f8b	\N	8c7cac5d-349c-4d45-ab78-f4e52554d784	75bbbdd2-5d00-4257-8e1e-c3881eebcf0e	افزودن تست واحد برای سرویس کاربران #54	\N	high	2026-08-25	dd3ba75e-3f9f-4bc8-a927-12337a8fba76	2026-07-21 12:23:05.653402+00	2026-07-21 12:23:05.653402+00	todo	\N	31	27.30	2026-08-12	medium
9e026bc3-66b8-45d7-9c60-0989a6664192	a2a211cb-0f9f-4af5-9766-66228a587300	\N	dbe12768-1ffa-4f9b-8327-4558c4438ef6	75bbbdd2-5d00-4257-8e1e-c3881eebcf0e	پیاده‌سازی صفحهٔ داشبورد مدیریتی #55	\N	high	2026-08-05	6dc0fd87-07d6-4bfd-b4cc-313065d2c92d	2026-07-21 12:23:05.653402+00	2026-07-21 12:23:05.653402+00	archived	\N	19	37.20	2026-07-21	medium
9e026bc3-66b8-45d7-9c60-0989a6664192	a2a211cb-0f9f-4af5-9766-66228a587300	\N	24e34af4-1229-4d93-8615-b8479b51a37c	75bbbdd2-5d00-4257-8e1e-c3881eebcf0e	افزودن قابلیت جست‌وجوی پیشرفته #56	\N	medium	2026-08-13	80cd58bf-f90b-4c6b-af9e-c2d5194347de	2026-07-21 12:23:05.653402+00	2026-07-21 12:23:05.653402+00	todo	\N	3	8.80	2026-08-06	medium
9e026bc3-66b8-45d7-9c60-0989a6664192	a2a211cb-0f9f-4af5-9766-66228a587300	\N	dbe12768-1ffa-4f9b-8327-4558c4438ef6	75bbbdd2-5d00-4257-8e1e-c3881eebcf0e	طراحی API نسخهٔ دوم #57	\N	low	2026-08-15	8e517e17-55d8-48dc-ac47-bae6c38f13e7	2026-07-21 12:23:05.653402+00	2026-07-21 12:23:05.653402+00	in_progress	\N	13	16.50	2026-08-06	medium
9e026bc3-66b8-45d7-9c60-0989a6664192	a2a211cb-0f9f-4af5-9766-66228a587300	\N	75bbbdd2-5d00-4257-8e1e-c3881eebcf0e	75bbbdd2-5d00-4257-8e1e-c3881eebcf0e	رفع مشکل کندی بارگذاری صفحه #58	\N	medium	2026-08-23	cda880d6-0be1-47e1-983e-d30e86db8256	2026-07-21 12:23:05.653402+00	2026-07-21 12:23:05.653402+00	completed	approved	100	33.20	2026-08-07	medium
9e026bc3-66b8-45d7-9c60-0989a6664192	a2a211cb-0f9f-4af5-9766-66228a587300	\N	8c7cac5d-349c-4d45-ab78-f4e52554d784	75bbbdd2-5d00-4257-8e1e-c3881eebcf0e	تنظیم پایپ‌لاین CI/CD #59	\N	low	2026-07-02	f641cf79-5cdd-4502-b7f1-511129d308bf	2026-07-21 12:23:05.653402+00	2026-07-21 12:23:05.653402+00	in_progress	\N	51	14.50	2026-06-30	medium
9e026bc3-66b8-45d7-9c60-0989a6664192	a2a211cb-0f9f-4af5-9766-66228a587300	\N	8c7cac5d-349c-4d45-ab78-f4e52554d784	75bbbdd2-5d00-4257-8e1e-c3881eebcf0e	رفع مشکل کندی بارگذاری صفحه #60	\N	high	2026-08-14	da3d64d6-e313-43b7-99f7-4cc59837790c	2026-07-21 12:23:05.653402+00	2026-07-21 12:23:05.653402+00	todo	\N	65	17.20	2026-08-04	medium
9e026bc3-66b8-45d7-9c60-0989a6664192	a2a211cb-0f9f-4af5-9766-66228a587300	\N	8c7cac5d-349c-4d45-ab78-f4e52554d784	75bbbdd2-5d00-4257-8e1e-c3881eebcf0e	افزودن قابلیت جست‌وجوی پیشرفته #61	\N	medium	2026-06-22	70d23c70-d7a9-43fe-94c2-9aba83ab49a7	2026-07-21 12:23:05.653402+00	2026-07-21 12:23:05.653402+00	completed	approved	100	8.80	2026-06-17	medium
9e026bc3-66b8-45d7-9c60-0989a6664192	a2a211cb-0f9f-4af5-9766-66228a587300	\N	dbe12768-1ffa-4f9b-8327-4558c4438ef6	75bbbdd2-5d00-4257-8e1e-c3881eebcf0e	پیاده‌سازی احراز هویت دومرحله‌ای #62	\N	medium	2026-07-13	25c17721-acd9-4394-8a4a-df53a73497e3	2026-07-21 12:23:05.653402+00	2026-07-21 12:23:05.653402+00	todo	\N	40	18.60	2026-06-22	medium
9e026bc3-66b8-45d7-9c60-0989a6664192	a2a211cb-0f9f-4af5-9766-66228a587300	\N	6b87e773-3d93-47db-8dc6-37ca0e6e9b32	75bbbdd2-5d00-4257-8e1e-c3881eebcf0e	افزودن تست واحد برای سرویس کاربران #63	\N	medium	2026-07-30	c50c9c81-d55a-433b-9bdd-809aae08f304	2026-07-21 12:23:05.653402+00	2026-07-21 12:23:05.653402+00	todo	\N	5	28.90	2026-07-10	medium
9e026bc3-66b8-45d7-9c60-0989a6664192	a2a211cb-0f9f-4af5-9766-66228a587300	\N	75bbbdd2-5d00-4257-8e1e-c3881eebcf0e	75bbbdd2-5d00-4257-8e1e-c3881eebcf0e	رفع مشکل کندی بارگذاری صفحه #64	\N	medium	2026-07-28	1089f18e-7134-4098-90b2-ae3c1cd5cc67	2026-07-21 12:23:05.653402+00	2026-07-21 12:23:05.653402+00	completed	rejected	100	4.70	2026-07-20	medium
9e026bc3-66b8-45d7-9c60-0989a6664192	a2a211cb-0f9f-4af5-9766-66228a587300	\N	ad47309d-1c75-4d68-b779-348021512719	75bbbdd2-5d00-4257-8e1e-c3881eebcf0e	تنظیم پایپ‌لاین CI/CD #65	\N	low	2026-08-06	6c88d4ad-bd92-4efb-a39c-57d3a924dfdb	2026-07-21 12:23:05.653402+00	2026-07-21 12:23:05.653402+00	in_progress	\N	38	21.30	2026-07-25	medium
9e026bc3-66b8-45d7-9c60-0989a6664192	a2a211cb-0f9f-4af5-9766-66228a587300	\N	ad47309d-1c75-4d68-b779-348021512719	75bbbdd2-5d00-4257-8e1e-c3881eebcf0e	نوشتن مستندات فنی API #66	\N	medium	2026-07-20	67088c66-1a1b-4f44-8f7c-f8345f63af48	2026-07-21 12:23:05.653402+00	2026-07-21 12:23:05.653402+00	in_progress	\N	70	6.80	2026-07-06	medium
9e026bc3-66b8-45d7-9c60-0989a6664192	a2a211cb-0f9f-4af5-9766-66228a587300	\N	7e07497e-be59-442a-82ad-943e3bd502bb	75bbbdd2-5d00-4257-8e1e-c3881eebcf0e	پیاده‌سازی صفحهٔ داشبورد مدیریتی #67	\N	high	2026-08-05	d641559c-4def-4f7b-b322-77c1fb25b141	2026-07-21 12:23:05.653402+00	2026-07-21 12:23:05.653402+00	completed	rejected	100	13.40	2026-07-29	medium
9e026bc3-66b8-45d7-9c60-0989a6664192	a2a211cb-0f9f-4af5-9766-66228a587300	\N	6b87e773-3d93-47db-8dc6-37ca0e6e9b32	75bbbdd2-5d00-4257-8e1e-c3881eebcf0e	افزودن تست واحد برای سرویس کاربران #68	\N	medium	2026-07-16	b83495f4-5e2e-492d-b094-8eae8b5c0370	2026-07-21 12:23:05.653402+00	2026-07-21 12:23:05.653402+00	todo	\N	74	25.10	2026-07-05	medium
9e026bc3-66b8-45d7-9c60-0989a6664192	a2a211cb-0f9f-4af5-9766-66228a587300	\N	dbe12768-1ffa-4f9b-8327-4558c4438ef6	75bbbdd2-5d00-4257-8e1e-c3881eebcf0e	به‌روزرسانی کتابخانه‌های وابسته #69	\N	medium	2026-08-06	fa73c231-65eb-4555-bb00-da4c4bd04300	2026-07-21 12:23:05.653402+00	2026-07-21 12:23:05.653402+00	completed	approved	100	32.20	2026-07-29	medium
9e026bc3-66b8-45d7-9c60-0989a6664192	a2a211cb-0f9f-4af5-9766-66228a587300	\N	8c7cac5d-349c-4d45-ab78-f4e52554d784	75bbbdd2-5d00-4257-8e1e-c3881eebcf0e	طراحی API نسخهٔ دوم #70	\N	high	2026-06-30	202c1031-0100-4b1a-8741-d9e13ce4f770	2026-07-21 12:23:05.653402+00	2026-07-21 12:23:05.653402+00	archived	\N	79	14.70	2026-06-26	medium
9e026bc3-66b8-45d7-9c60-0989a6664192	a2a211cb-0f9f-4af5-9766-66228a587300	\N	8c7cac5d-349c-4d45-ab78-f4e52554d784	75bbbdd2-5d00-4257-8e1e-c3881eebcf0e	افزودن تست واحد برای سرویس کاربران #71	\N	low	2026-07-12	c010a864-7757-4225-87b2-9c4267720de7	2026-07-21 12:23:05.653402+00	2026-07-21 12:23:05.653402+00	archived	\N	18	2.90	2026-07-01	medium
9e026bc3-66b8-45d7-9c60-0989a6664192	a2a211cb-0f9f-4af5-9766-66228a587300	\N	24e34af4-1229-4d93-8615-b8479b51a37c	75bbbdd2-5d00-4257-8e1e-c3881eebcf0e	بررسی و رفع آسیب‌پذیری امنیتی #72	\N	medium	2026-08-08	3a793043-2c7f-40f3-9aab-92464b07af1d	2026-07-21 12:23:05.653402+00	2026-07-21 12:23:05.653402+00	completed	pending	100	35.70	2026-08-04	medium
9e026bc3-66b8-45d7-9c60-0989a6664192	40af2561-cb3f-4189-8722-0d90cf4e2a77	\N	6b87e773-3d93-47db-8dc6-37ca0e6e9b32	75bbbdd2-5d00-4257-8e1e-c3881eebcf0e	بررسی و رفع آسیب‌پذیری امنیتی #73	\N	medium	2026-08-14	3eeae598-2cf0-436a-ae79-0bc4faecd8d0	2026-07-21 12:23:05.653402+00	2026-07-21 12:23:05.653402+00	todo	\N	31	7.60	2026-07-31	medium
9e026bc3-66b8-45d7-9c60-0989a6664192	40af2561-cb3f-4189-8722-0d90cf4e2a77	\N	ad47309d-1c75-4d68-b779-348021512719	75bbbdd2-5d00-4257-8e1e-c3881eebcf0e	رفع مشکل ناسازگاری مرورگر #74	\N	medium	2026-08-17	4b02147f-0e74-42cc-98d1-2e4db9f5689b	2026-07-21 12:23:05.653402+00	2026-07-21 12:23:05.653402+00	todo	\N	28	8.70	2026-08-12	medium
9e026bc3-66b8-45d7-9c60-0989a6664192	40af2561-cb3f-4189-8722-0d90cf4e2a77	\N	ad47309d-1c75-4d68-b779-348021512719	75bbbdd2-5d00-4257-8e1e-c3881eebcf0e	افزودن قابلیت جست‌وجوی پیشرفته #75	\N	low	2026-07-30	7e96cc37-bde4-4aa7-92fe-9a38d8d226d2	2026-07-21 12:23:05.653402+00	2026-07-21 12:23:05.653402+00	completed	approved	100	19.30	2026-07-21	medium
9e026bc3-66b8-45d7-9c60-0989a6664192	40af2561-cb3f-4189-8722-0d90cf4e2a77	\N	8c7cac5d-349c-4d45-ab78-f4e52554d784	75bbbdd2-5d00-4257-8e1e-c3881eebcf0e	رفع مشکل کندی بارگذاری صفحه #76	\N	medium	2026-08-11	8c6d86a6-09e2-41f4-b858-438331681ac4	2026-07-21 12:23:05.653402+00	2026-07-21 12:23:05.653402+00	completed	pending	100	25.30	2026-07-21	medium
9e026bc3-66b8-45d7-9c60-0989a6664192	40af2561-cb3f-4189-8722-0d90cf4e2a77	\N	ad47309d-1c75-4d68-b779-348021512719	75bbbdd2-5d00-4257-8e1e-c3881eebcf0e	بررسی و رفع آسیب‌پذیری امنیتی #77	\N	low	2026-09-01	6658675d-6e5e-44d9-a9f2-c02c5b5ef91b	2026-07-21 12:23:05.653402+00	2026-07-21 12:23:05.653402+00	completed	approved	100	30.30	2026-08-13	medium
9e026bc3-66b8-45d7-9c60-0989a6664192	40af2561-cb3f-4189-8722-0d90cf4e2a77	\N	7e07497e-be59-442a-82ad-943e3bd502bb	75bbbdd2-5d00-4257-8e1e-c3881eebcf0e	رفع مشکل ناسازگاری مرورگر #78	\N	high	2026-07-11	605e2165-503a-44f0-95df-47ecbc2ebe2f	2026-07-21 12:23:05.653402+00	2026-07-21 12:23:05.653402+00	completed	approved	100	20.40	2026-07-01	medium
9e026bc3-66b8-45d7-9c60-0989a6664192	40af2561-cb3f-4189-8722-0d90cf4e2a77	\N	24e34af4-1229-4d93-8615-b8479b51a37c	75bbbdd2-5d00-4257-8e1e-c3881eebcf0e	نوشتن مستندات فنی API #79	\N	medium	2026-07-18	f5379e51-f275-4add-9f47-16fb603d75a7	2026-07-21 12:23:05.653402+00	2026-07-21 12:23:05.653402+00	in_progress	\N	30	12.30	2026-07-14	medium
9e026bc3-66b8-45d7-9c60-0989a6664192	40af2561-cb3f-4189-8722-0d90cf4e2a77	\N	dbe12768-1ffa-4f9b-8327-4558c4438ef6	75bbbdd2-5d00-4257-8e1e-c3881eebcf0e	پیاده‌سازی احراز هویت دومرحله‌ای #80	\N	high	2026-07-04	75d0eda8-cd6a-4f07-8bc2-9af476a84a59	2026-07-21 12:23:05.653402+00	2026-07-21 12:23:05.653402+00	completed	approved	100	7.80	2026-06-25	medium
9e026bc3-66b8-45d7-9c60-0989a6664192	40af2561-cb3f-4189-8722-0d90cf4e2a77	\N	24e34af4-1229-4d93-8615-b8479b51a37c	75bbbdd2-5d00-4257-8e1e-c3881eebcf0e	رفع مشکل کندی بارگذاری صفحه #81	\N	high	2026-07-27	7bc3d707-404a-4fdf-83bb-a69e6b4fe3d7	2026-07-21 12:23:05.653402+00	2026-07-21 12:23:05.653402+00	todo	\N	59	17.80	2026-07-12	medium
9e026bc3-66b8-45d7-9c60-0989a6664192	40af2561-cb3f-4189-8722-0d90cf4e2a77	\N	24e34af4-1229-4d93-8615-b8479b51a37c	75bbbdd2-5d00-4257-8e1e-c3881eebcf0e	نوشتن مستندات فنی API #82	\N	low	2026-07-30	caae0cab-5b97-48df-8e2f-b328fdb2f89f	2026-07-21 12:23:05.653402+00	2026-07-21 12:23:05.653402+00	in_progress	\N	73	16.50	2026-07-10	medium
9e026bc3-66b8-45d7-9c60-0989a6664192	40af2561-cb3f-4189-8722-0d90cf4e2a77	\N	75bbbdd2-5d00-4257-8e1e-c3881eebcf0e	75bbbdd2-5d00-4257-8e1e-c3881eebcf0e	بازنویسی ماژول اعلان‌ها #83	\N	medium	2026-07-19	904931d4-970e-4cfd-971c-a3587d0b0141	2026-07-21 12:23:05.653402+00	2026-07-21 12:23:05.653402+00	in_progress	\N	68	30.40	2026-07-05	medium
9e026bc3-66b8-45d7-9c60-0989a6664192	40af2561-cb3f-4189-8722-0d90cf4e2a77	\N	6b87e773-3d93-47db-8dc6-37ca0e6e9b32	75bbbdd2-5d00-4257-8e1e-c3881eebcf0e	طراحی API نسخهٔ دوم #84	\N	medium	2026-07-26	8f470eac-bc9f-4435-84c1-a2b34feb3123	2026-07-21 12:23:05.653402+00	2026-07-21 12:23:05.653402+00	completed	pending	100	20.50	2026-07-17	medium
9e026bc3-66b8-45d7-9c60-0989a6664192	40af2561-cb3f-4189-8722-0d90cf4e2a77	\N	7e07497e-be59-442a-82ad-943e3bd502bb	75bbbdd2-5d00-4257-8e1e-c3881eebcf0e	نوشتن مستندات فنی API #85	\N	low	2026-08-11	aa2bf9a3-c5bf-4915-b090-18dc2d4b57ae	2026-07-21 12:23:05.653402+00	2026-07-21 12:23:05.653402+00	in_progress	\N	59	36.90	2026-07-28	medium
9e026bc3-66b8-45d7-9c60-0989a6664192	40af2561-cb3f-4189-8722-0d90cf4e2a77	\N	6b87e773-3d93-47db-8dc6-37ca0e6e9b32	75bbbdd2-5d00-4257-8e1e-c3881eebcf0e	پیاده‌سازی صفحهٔ داشبورد مدیریتی #86	\N	high	2026-07-31	573f9798-9939-452e-b67f-5cf2f2f34bfe	2026-07-21 12:23:05.653402+00	2026-07-21 12:23:05.653402+00	completed	approved	100	3.00	2026-07-11	medium
9e026bc3-66b8-45d7-9c60-0989a6664192	40af2561-cb3f-4189-8722-0d90cf4e2a77	\N	ad47309d-1c75-4d68-b779-348021512719	75bbbdd2-5d00-4257-8e1e-c3881eebcf0e	بهینه‌سازی کوئری‌های گزارش‌گیری #87	\N	low	2026-07-10	caab8809-28dd-43ed-af2f-cc00720fb37f	2026-07-21 12:23:05.653402+00	2026-07-21 12:23:05.653402+00	in_progress	\N	33	16.40	2026-06-24	medium
9e026bc3-66b8-45d7-9c60-0989a6664192	40af2561-cb3f-4189-8722-0d90cf4e2a77	\N	24e34af4-1229-4d93-8615-b8479b51a37c	75bbbdd2-5d00-4257-8e1e-c3881eebcf0e	طراحی API نسخهٔ دوم #88	\N	medium	2026-08-17	b23c3f20-b6af-4df0-a3ad-8a91ba1d6ccf	2026-07-21 12:23:05.653402+00	2026-07-21 12:23:05.653402+00	completed	approved	100	11.60	2026-08-03	medium
9e026bc3-66b8-45d7-9c60-0989a6664192	40af2561-cb3f-4189-8722-0d90cf4e2a77	\N	75bbbdd2-5d00-4257-8e1e-c3881eebcf0e	75bbbdd2-5d00-4257-8e1e-c3881eebcf0e	رفع مشکل کندی بارگذاری صفحه #89	\N	low	2026-07-23	83a6b329-8e08-4ed4-ba6a-99ae5f9b2134	2026-07-21 12:23:05.653402+00	2026-07-21 12:23:05.653402+00	completed	approved	100	26.70	2026-07-20	medium
9e026bc3-66b8-45d7-9c60-0989a6664192	40af2561-cb3f-4189-8722-0d90cf4e2a77	\N	8c7cac5d-349c-4d45-ab78-f4e52554d784	75bbbdd2-5d00-4257-8e1e-c3881eebcf0e	افزودن تست واحد برای سرویس کاربران #90	\N	low	2026-06-26	6394419d-c2f7-41ad-b6ba-8578d527971a	2026-07-21 12:23:05.653402+00	2026-07-21 12:23:05.653402+00	completed	approved	100	25.60	2026-06-17	medium
9e026bc3-66b8-45d7-9c60-0989a6664192	\N	\N	24e34af4-1229-4d93-8615-b8479b51a37c	24e34af4-1229-4d93-8615-b8479b51a37c	پیاده‌سازی صفحهٔ داشبورد مدیریتی #91	\N	low	2026-07-21	35ad4a77-99a9-4f83-acf2-3c4df93c6d8e	2026-07-21 12:23:05.653402+00	2026-07-21 12:23:05.653402+00	todo	\N	59	28.60	2026-07-16	medium
9e026bc3-66b8-45d7-9c60-0989a6664192	\N	\N	8c7cac5d-349c-4d45-ab78-f4e52554d784	8c7cac5d-349c-4d45-ab78-f4e52554d784	پیاده‌سازی صفحهٔ داشبورد مدیریتی #92	\N	high	2026-07-17	d89a3200-42ec-42cf-9207-85c492a7fb3b	2026-07-21 12:23:05.653402+00	2026-07-21 12:23:05.653402+00	in_progress	\N	14	31.60	2026-06-26	medium
9e026bc3-66b8-45d7-9c60-0989a6664192	\N	\N	24e34af4-1229-4d93-8615-b8479b51a37c	24e34af4-1229-4d93-8615-b8479b51a37c	رفع باگ در ماژول پرداخت #93	\N	medium	2026-07-12	d2e91ab2-e992-456d-8980-57db142a4dbc	2026-07-21 12:23:05.653402+00	2026-07-21 12:23:05.653402+00	in_progress	\N	73	27.70	2026-06-22	medium
9e026bc3-66b8-45d7-9c60-0989a6664192	\N	\N	7e07497e-be59-442a-82ad-943e3bd502bb	7e07497e-be59-442a-82ad-943e3bd502bb	پیاده‌سازی صفحهٔ ورود جدید #94	\N	high	2026-08-23	cc210f84-19b6-4d21-8a7c-1a7351ce6d8c	2026-07-21 12:23:05.653402+00	2026-07-21 12:23:05.653402+00	in_progress	\N	80	11.20	2026-08-15	medium
9e026bc3-66b8-45d7-9c60-0989a6664192	\N	\N	ad47309d-1c75-4d68-b779-348021512719	ad47309d-1c75-4d68-b779-348021512719	رفع مشکل ناسازگاری مرورگر #95	\N	low	2026-07-26	7dd88521-12aa-4744-b328-5a8ad2308a7a	2026-07-21 12:23:05.653402+00	2026-07-21 12:23:05.653402+00	archived	\N	72	31.70	2026-07-05	medium
9e026bc3-66b8-45d7-9c60-0989a6664192	\N	\N	dbe12768-1ffa-4f9b-8327-4558c4438ef6	dbe12768-1ffa-4f9b-8327-4558c4438ef6	به‌روزرسانی کتابخانه‌های وابسته #96	\N	high	2026-07-13	8e5bfb9e-46e7-4828-9ad5-926a91d62b17	2026-07-21 12:23:05.653402+00	2026-07-21 12:23:05.653402+00	completed	approved	100	15.00	2026-07-09	medium
9e026bc3-66b8-45d7-9c60-0989a6664192	\N	\N	8c7cac5d-349c-4d45-ab78-f4e52554d784	8c7cac5d-349c-4d45-ab78-f4e52554d784	پیاده‌سازی صفحهٔ ورود جدید #97	\N	medium	2026-08-24	2750b4df-e693-4abc-8cc5-d51b778f79f4	2026-07-21 12:23:05.653402+00	2026-07-21 12:23:05.653402+00	in_progress	\N	46	26.20	2026-08-07	medium
9e026bc3-66b8-45d7-9c60-0989a6664192	\N	\N	8c7cac5d-349c-4d45-ab78-f4e52554d784	8c7cac5d-349c-4d45-ab78-f4e52554d784	نوشتن مستندات فنی API #98	\N	high	2026-07-20	8074f30e-8be8-4973-9700-120faedfe782	2026-07-21 12:23:05.653402+00	2026-07-21 12:23:05.653402+00	completed	pending	100	38.70	2026-07-13	medium
9e026bc3-66b8-45d7-9c60-0989a6664192	\N	\N	dbe12768-1ffa-4f9b-8327-4558c4438ef6	dbe12768-1ffa-4f9b-8327-4558c4438ef6	بررسی و رفع آسیب‌پذیری امنیتی #99	\N	medium	2026-08-06	38693f0f-c6c2-42d1-8d78-723108c9b407	2026-07-21 12:23:05.653402+00	2026-07-21 12:23:05.653402+00	completed	pending	100	33.40	2026-07-20	medium
9e026bc3-66b8-45d7-9c60-0989a6664192	\N	\N	6b87e773-3d93-47db-8dc6-37ca0e6e9b32	6b87e773-3d93-47db-8dc6-37ca0e6e9b32	بازنویسی ماژول اعلان‌ها #100	\N	low	2026-07-15	f26a8423-9378-4555-8bb1-527e179ca942	2026-07-21 12:23:05.653402+00	2026-07-21 12:23:05.653402+00	in_progress	\N	35	35.50	2026-07-06	medium
9e026bc3-66b8-45d7-9c60-0989a6664192	\N	\N	24e34af4-1229-4d93-8615-b8479b51a37c	24e34af4-1229-4d93-8615-b8479b51a37c	پیاده‌سازی صفحهٔ داشبورد مدیریتی #101	\N	high	2026-08-04	389295d0-2c85-47e2-ad6e-0cc4a1b43942	2026-07-21 12:23:05.653402+00	2026-07-21 12:23:05.653402+00	archived	\N	48	14.80	2026-07-15	medium
9e026bc3-66b8-45d7-9c60-0989a6664192	\N	\N	7e07497e-be59-442a-82ad-943e3bd502bb	7e07497e-be59-442a-82ad-943e3bd502bb	افزودن تست واحد برای سرویس کاربران #102	\N	medium	2026-07-14	6c65e795-ea72-483f-9a50-2b23137ec837	2026-07-21 12:23:05.653402+00	2026-07-21 12:23:05.653402+00	in_progress	\N	33	14.90	2026-06-27	medium
9e026bc3-66b8-45d7-9c60-0989a6664192	\N	\N	6b87e773-3d93-47db-8dc6-37ca0e6e9b32	6b87e773-3d93-47db-8dc6-37ca0e6e9b32	به‌روزرسانی کتابخانه‌های وابسته #103	\N	low	2026-07-23	31767b9d-e552-4025-8d14-f63fa0842a97	2026-07-21 12:23:05.653402+00	2026-07-21 12:23:05.653402+00	completed	pending	100	5.30	2026-07-21	medium
9e026bc3-66b8-45d7-9c60-0989a6664192	\N	\N	ad47309d-1c75-4d68-b779-348021512719	ad47309d-1c75-4d68-b779-348021512719	رفع مشکل ناسازگاری مرورگر #104	\N	low	2026-08-05	2c25ae79-aad0-4e34-88fe-c705e6b25212	2026-07-21 12:23:05.653402+00	2026-07-21 12:23:05.653402+00	in_progress	\N	60	26.50	2026-07-17	medium
9e026bc3-66b8-45d7-9c60-0989a6664192	\N	\N	7e07497e-be59-442a-82ad-943e3bd502bb	7e07497e-be59-442a-82ad-943e3bd502bb	افزودن تست واحد برای سرویس کاربران #105	\N	medium	2026-07-02	29e2314a-b31d-44b6-add5-52ac5e3924eb	2026-07-21 12:23:05.653402+00	2026-07-21 12:23:05.653402+00	completed	pending	100	28.30	2026-06-21	medium
9e026bc3-66b8-45d7-9c60-0989a6664192	b2e41607-118c-4f69-a751-b623cfe694a9	\N	6965fa45-fddb-4465-b0e6-042192ac6ee2	0aa7f564-65bd-473d-aa0e-3abc4663b507	پیگیری مطالبات معوق مشتریان #1	\N	medium	2026-07-16	de54e3e2-8df2-4239-b9af-441648df6f6b	2026-07-21 12:23:05.653402+00	2026-07-21 12:23:05.653402+00	completed	rejected	100	5.90	2026-06-27	medium
9e026bc3-66b8-45d7-9c60-0989a6664192	b2e41607-118c-4f69-a751-b623cfe694a9	\N	e5c268f5-5274-4960-be2b-6f7bbba26625	0aa7f564-65bd-473d-aa0e-3abc4663b507	تهیهٔ گزارش جریان نقدی #2	\N	medium	2026-08-04	1375b177-1755-4d17-90ad-d6f5ad349196	2026-07-21 12:23:05.653402+00	2026-07-21 12:23:05.653402+00	completed	approved	100	8.30	2026-07-14	medium
9e026bc3-66b8-45d7-9c60-0989a6664192	b2e41607-118c-4f69-a751-b623cfe694a9	\N	6965fa45-fddb-4465-b0e6-042192ac6ee2	0aa7f564-65bd-473d-aa0e-3abc4663b507	تهیهٔ گزارش جریان نقدی #3	\N	medium	2026-07-17	b4fb2566-a13b-4657-9d57-e5e96cde6967	2026-07-21 12:23:05.653402+00	2026-07-21 12:23:05.653402+00	in_progress	\N	78	39.90	2026-07-14	medium
9e026bc3-66b8-45d7-9c60-0989a6664192	b2e41607-118c-4f69-a751-b623cfe694a9	\N	e5c268f5-5274-4960-be2b-6f7bbba26625	0aa7f564-65bd-473d-aa0e-3abc4663b507	تهیهٔ گزارش سود و زیان ماهانه #4	\N	high	2026-08-18	01b49f0a-27c9-4415-8fbb-3eb8037f4ea1	2026-07-21 12:23:05.653402+00	2026-07-21 12:23:05.653402+00	completed	rejected	100	26.20	2026-08-15	medium
9e026bc3-66b8-45d7-9c60-0989a6664192	b2e41607-118c-4f69-a751-b623cfe694a9	\N	e5c268f5-5274-4960-be2b-6f7bbba26625	0aa7f564-65bd-473d-aa0e-3abc4663b507	بررسی و تأیید صورت‌حساب‌های خرید #5	\N	low	2026-08-05	6be26401-c944-43d3-8423-c443f370f585	2026-07-21 12:23:05.653402+00	2026-07-21 12:23:05.653402+00	completed	pending	100	34.20	2026-07-29	medium
9e026bc3-66b8-45d7-9c60-0989a6664192	b2e41607-118c-4f69-a751-b623cfe694a9	\N	147770ac-f6f9-4af1-97c3-cccc614d44e9	0aa7f564-65bd-473d-aa0e-3abc4663b507	بررسی و تسویهٔ کارت اعتباری شرکت #6	\N	high	2026-06-29	0b8d2dbd-2a68-4bcf-a25d-f82d746c35df	2026-07-21 12:23:05.653402+00	2026-07-21 12:23:05.653402+00	completed	approved	100	15.90	2026-06-20	medium
9e026bc3-66b8-45d7-9c60-0989a6664192	b2e41607-118c-4f69-a751-b623cfe694a9	\N	6965fa45-fddb-4465-b0e6-042192ac6ee2	0aa7f564-65bd-473d-aa0e-3abc4663b507	تهیهٔ گزارش مالیاتی فصلی #7	\N	medium	2026-07-11	442c73bb-b175-46a9-8181-183573f175da	2026-07-21 12:23:05.653402+00	2026-07-21 12:23:05.653402+00	completed	approved	100	18.90	2026-06-25	medium
9e026bc3-66b8-45d7-9c60-0989a6664192	b2e41607-118c-4f69-a751-b623cfe694a9	\N	0aa7f564-65bd-473d-aa0e-3abc4663b507	0aa7f564-65bd-473d-aa0e-3abc4663b507	تهیهٔ گزارش مالیاتی فصلی #8	\N	high	2026-07-23	56038965-dd34-4362-9615-8d463cf92c8d	2026-07-21 12:23:05.653402+00	2026-07-21 12:23:05.653402+00	completed	approved	100	12.60	2026-07-09	medium
9e026bc3-66b8-45d7-9c60-0989a6664192	b2e41607-118c-4f69-a751-b623cfe694a9	\N	0aa7f564-65bd-473d-aa0e-3abc4663b507	0aa7f564-65bd-473d-aa0e-3abc4663b507	به‌روزرسانی جدول حقوق و دستمزد #9	\N	high	2026-08-09	0da642e0-ea94-4fb5-a2d3-e975ae959135	2026-07-21 12:23:05.653402+00	2026-07-21 12:23:05.653402+00	todo	\N	49	36.70	2026-08-02	medium
9e026bc3-66b8-45d7-9c60-0989a6664192	b2e41607-118c-4f69-a751-b623cfe694a9	\N	0aa7f564-65bd-473d-aa0e-3abc4663b507	0aa7f564-65bd-473d-aa0e-3abc4663b507	تهیهٔ گزارش جریان نقدی #10	\N	medium	2026-08-14	b1fa170e-0b4f-4bea-8e54-8cea68785878	2026-07-21 12:23:05.653402+00	2026-07-21 12:23:05.653402+00	in_progress	\N	27	39.90	2026-08-04	medium
9e026bc3-66b8-45d7-9c60-0989a6664192	b2e41607-118c-4f69-a751-b623cfe694a9	\N	e5c268f5-5274-4960-be2b-6f7bbba26625	0aa7f564-65bd-473d-aa0e-3abc4663b507	تهیهٔ گزارش سود و زیان ماهانه #11	\N	low	2026-07-25	2ac4b10f-88f3-4a72-9b60-450c048d241e	2026-07-21 12:23:05.653402+00	2026-07-21 12:23:05.653402+00	completed	rejected	100	34.40	2026-07-17	medium
9e026bc3-66b8-45d7-9c60-0989a6664192	b2e41607-118c-4f69-a751-b623cfe694a9	\N	6965fa45-fddb-4465-b0e6-042192ac6ee2	0aa7f564-65bd-473d-aa0e-3abc4663b507	تهیهٔ گزارش سود و زیان ماهانه #12	\N	high	2026-08-28	eab24f17-6b5f-40da-8dea-99ad33a75fbb	2026-07-21 12:23:05.653402+00	2026-07-21 12:23:05.653402+00	todo	\N	40	27.40	2026-08-12	medium
9e026bc3-66b8-45d7-9c60-0989a6664192	b2e41607-118c-4f69-a751-b623cfe694a9	\N	147770ac-f6f9-4af1-97c3-cccc614d44e9	0aa7f564-65bd-473d-aa0e-3abc4663b507	پیگیری مطالبات معوق مشتریان #13	\N	medium	2026-08-09	2370e4a5-9d9f-4670-bb47-45a494ef5f20	2026-07-21 12:23:05.653402+00	2026-07-21 12:23:05.653402+00	todo	\N	20	29.00	2026-07-21	medium
9e026bc3-66b8-45d7-9c60-0989a6664192	b2e41607-118c-4f69-a751-b623cfe694a9	\N	147770ac-f6f9-4af1-97c3-cccc614d44e9	0aa7f564-65bd-473d-aa0e-3abc4663b507	ثبت اسناد حسابداری هفتگی #14	\N	low	2026-07-27	263c7dd4-acce-4119-bea5-81237c1973f1	2026-07-21 12:23:05.653402+00	2026-07-21 12:23:05.653402+00	completed	approved	100	39.40	2026-07-09	medium
9e026bc3-66b8-45d7-9c60-0989a6664192	b2e41607-118c-4f69-a751-b623cfe694a9	\N	c17589b4-349d-4156-9b66-f7ecf971b52d	0aa7f564-65bd-473d-aa0e-3abc4663b507	بررسی و تأیید صورت‌حساب‌های خرید #15	\N	medium	2026-07-18	ac0ec3d8-550a-416f-b29f-7589e8635d4f	2026-07-21 12:23:05.653402+00	2026-07-21 12:23:05.653402+00	todo	\N	70	23.70	2026-07-01	medium
9e026bc3-66b8-45d7-9c60-0989a6664192	b2e41607-118c-4f69-a751-b623cfe694a9	\N	6965fa45-fddb-4465-b0e6-042192ac6ee2	0aa7f564-65bd-473d-aa0e-3abc4663b507	تهیهٔ گزارش سود و زیان ماهانه #16	\N	medium	2026-08-15	5f38861b-c5f4-4e76-9396-98fd8b9d0e22	2026-07-21 12:23:05.653402+00	2026-07-21 12:23:05.653402+00	completed	approved	100	17.10	2026-08-11	medium
9e026bc3-66b8-45d7-9c60-0989a6664192	b2e41607-118c-4f69-a751-b623cfe694a9	\N	147770ac-f6f9-4af1-97c3-cccc614d44e9	0aa7f564-65bd-473d-aa0e-3abc4663b507	بررسی فاکتورهای فروش صادرشده #17	\N	medium	2026-08-03	b6e85ad5-6c82-4471-a039-29fca8927c89	2026-07-21 12:23:05.653402+00	2026-07-21 12:23:05.653402+00	archived	\N	73	4.80	2026-07-16	medium
9e026bc3-66b8-45d7-9c60-0989a6664192	b2e41607-118c-4f69-a751-b623cfe694a9	\N	e5c268f5-5274-4960-be2b-6f7bbba26625	0aa7f564-65bd-473d-aa0e-3abc4663b507	تهیهٔ گزارش مالیاتی فصلی #18	\N	low	2026-08-02	f544ba33-3a9f-42fe-8cbd-89d420bad29b	2026-07-21 12:23:05.653402+00	2026-07-21 12:23:05.653402+00	completed	approved	100	35.40	2026-07-15	medium
9e026bc3-66b8-45d7-9c60-0989a6664192	432d011d-9811-4926-818f-2b63ae8aa481	\N	c17589b4-349d-4156-9b66-f7ecf971b52d	0aa7f564-65bd-473d-aa0e-3abc4663b507	بررسی فاکتورهای فروش صادرشده #19	\N	high	2026-07-03	734eee59-c99b-47a4-a7c8-e151c2ad9e69	2026-07-21 12:23:05.653402+00	2026-07-21 12:23:05.653402+00	completed	pending	100	36.60	2026-06-27	medium
9e026bc3-66b8-45d7-9c60-0989a6664192	432d011d-9811-4926-818f-2b63ae8aa481	\N	0aa7f564-65bd-473d-aa0e-3abc4663b507	0aa7f564-65bd-473d-aa0e-3abc4663b507	پیگیری مطالبات معوق مشتریان #20	\N	low	2026-07-25	15ad9885-f068-40e8-929e-9316f6a3dc41	2026-07-21 12:23:05.653402+00	2026-07-21 12:23:05.653402+00	todo	\N	20	14.30	2026-07-19	medium
9e026bc3-66b8-45d7-9c60-0989a6664192	432d011d-9811-4926-818f-2b63ae8aa481	\N	147770ac-f6f9-4af1-97c3-cccc614d44e9	0aa7f564-65bd-473d-aa0e-3abc4663b507	بررسی قراردادهای مالی جدید #21	\N	medium	2026-07-26	220be6a2-5e3b-4ffe-8455-b7b7a16c7812	2026-07-21 12:23:05.653402+00	2026-07-21 12:23:05.653402+00	in_progress	\N	10	11.50	2026-07-08	medium
9e026bc3-66b8-45d7-9c60-0989a6664192	432d011d-9811-4926-818f-2b63ae8aa481	\N	147770ac-f6f9-4af1-97c3-cccc614d44e9	0aa7f564-65bd-473d-aa0e-3abc4663b507	بررسی صورت وضعیت پیمانکاران #22	\N	high	2026-08-06	fb9c89ca-b1e6-4e7e-a421-a1378485faa4	2026-07-21 12:23:05.653402+00	2026-07-21 12:23:05.653402+00	completed	approved	100	5.60	2026-07-26	medium
9e026bc3-66b8-45d7-9c60-0989a6664192	432d011d-9811-4926-818f-2b63ae8aa481	\N	147770ac-f6f9-4af1-97c3-cccc614d44e9	0aa7f564-65bd-473d-aa0e-3abc4663b507	مغایرت‌گیری حساب‌های بانکی #23	\N	low	2026-08-12	a95dc8bd-12fd-4018-9415-6a5644c51316	2026-07-21 12:23:05.653402+00	2026-07-21 12:23:05.653402+00	todo	\N	79	29.40	2026-07-23	medium
9e026bc3-66b8-45d7-9c60-0989a6664192	432d011d-9811-4926-818f-2b63ae8aa481	\N	515597de-809a-4b6a-9fb6-5e2cf6d9dfe2	0aa7f564-65bd-473d-aa0e-3abc4663b507	بررسی و تأیید صورت‌حساب‌های خرید #24	\N	low	2026-08-28	8618fb26-1a21-45ef-825d-4f31b9a12e38	2026-07-21 12:23:05.653402+00	2026-07-21 12:23:05.653402+00	in_progress	\N	10	3.70	2026-08-08	medium
9e026bc3-66b8-45d7-9c60-0989a6664192	432d011d-9811-4926-818f-2b63ae8aa481	\N	147770ac-f6f9-4af1-97c3-cccc614d44e9	0aa7f564-65bd-473d-aa0e-3abc4663b507	تطبیق موجودی انبار با حساب‌ها #25	\N	low	2026-08-01	4b3648d6-d964-45e0-be52-016320b96c9d	2026-07-21 12:23:05.653402+00	2026-07-21 12:23:05.653402+00	archived	\N	73	17.80	2026-07-22	medium
9e026bc3-66b8-45d7-9c60-0989a6664192	432d011d-9811-4926-818f-2b63ae8aa481	\N	147770ac-f6f9-4af1-97c3-cccc614d44e9	0aa7f564-65bd-473d-aa0e-3abc4663b507	پیگیری مطالبات معوق مشتریان #26	\N	high	2026-08-05	ebe474c8-e487-47a7-8e82-e7e4d8513000	2026-07-21 12:23:05.653402+00	2026-07-21 12:23:05.653402+00	todo	\N	38	20.40	2026-07-17	medium
9e026bc3-66b8-45d7-9c60-0989a6664192	432d011d-9811-4926-818f-2b63ae8aa481	\N	c17589b4-349d-4156-9b66-f7ecf971b52d	0aa7f564-65bd-473d-aa0e-3abc4663b507	تهیهٔ گزارش جریان نقدی #27	\N	low	2026-07-19	3d72e27a-c79b-4f05-9db2-3c9931305876	2026-07-21 12:23:05.653402+00	2026-07-21 12:23:05.653402+00	completed	approved	100	8.00	2026-07-15	medium
9e026bc3-66b8-45d7-9c60-0989a6664192	432d011d-9811-4926-818f-2b63ae8aa481	\N	6965fa45-fddb-4465-b0e6-042192ac6ee2	0aa7f564-65bd-473d-aa0e-3abc4663b507	مغایرت‌گیری حساب‌های بانکی #28	\N	medium	2026-07-28	d3e5a802-b42d-4425-bc61-a93ad6db1f1b	2026-07-21 12:23:05.653402+00	2026-07-21 12:23:05.653402+00	completed	approved	100	34.70	2026-07-07	medium
9e026bc3-66b8-45d7-9c60-0989a6664192	432d011d-9811-4926-818f-2b63ae8aa481	\N	e5c268f5-5274-4960-be2b-6f7bbba26625	0aa7f564-65bd-473d-aa0e-3abc4663b507	بررسی فاکتورهای فروش صادرشده #29	\N	low	2026-08-23	1e786e46-b51c-4974-948b-c3bfb88aff9c	2026-07-21 12:23:05.653402+00	2026-07-21 12:23:05.653402+00	archived	\N	47	21.60	2026-08-10	medium
9e026bc3-66b8-45d7-9c60-0989a6664192	432d011d-9811-4926-818f-2b63ae8aa481	\N	0aa7f564-65bd-473d-aa0e-3abc4663b507	0aa7f564-65bd-473d-aa0e-3abc4663b507	تهیهٔ گزارش سود و زیان ماهانه #30	\N	medium	2026-07-17	8545ad17-216c-43ee-ad50-36d5fd9d59f7	2026-07-21 12:23:05.653402+00	2026-07-21 12:23:05.653402+00	in_progress	\N	57	11.40	2026-07-01	medium
9e026bc3-66b8-45d7-9c60-0989a6664192	432d011d-9811-4926-818f-2b63ae8aa481	\N	0aa7f564-65bd-473d-aa0e-3abc4663b507	0aa7f564-65bd-473d-aa0e-3abc4663b507	پیگیری بیمهٔ کارکنان #31	\N	high	2026-07-18	4ff8717f-ac13-4e1b-878c-266e3b02c7ec	2026-07-21 12:23:05.653402+00	2026-07-21 12:23:05.653402+00	todo	\N	53	11.40	2026-07-04	medium
9e026bc3-66b8-45d7-9c60-0989a6664192	432d011d-9811-4926-818f-2b63ae8aa481	\N	c17589b4-349d-4156-9b66-f7ecf971b52d	0aa7f564-65bd-473d-aa0e-3abc4663b507	بررسی قراردادهای مالی جدید #32	\N	high	2026-08-19	71b1898f-7016-4acb-b399-ff8b16e20438	2026-07-21 12:23:05.653402+00	2026-07-21 12:23:05.653402+00	todo	\N	40	9.20	2026-08-07	medium
9e026bc3-66b8-45d7-9c60-0989a6664192	432d011d-9811-4926-818f-2b63ae8aa481	\N	6115c41b-8c19-4fa9-b656-df967e8a945e	0aa7f564-65bd-473d-aa0e-3abc4663b507	بررسی قراردادهای مالی جدید #33	\N	medium	2026-08-01	6b878f5c-873d-4f9e-a001-74c6d6dec497	2026-07-21 12:23:05.653402+00	2026-07-21 12:23:05.653402+00	completed	rejected	100	20.90	2026-07-15	medium
9e026bc3-66b8-45d7-9c60-0989a6664192	432d011d-9811-4926-818f-2b63ae8aa481	\N	0aa7f564-65bd-473d-aa0e-3abc4663b507	0aa7f564-65bd-473d-aa0e-3abc4663b507	ثبت اسناد حسابداری هفتگی #34	\N	low	2026-08-03	b3fcaaad-e1de-484b-81f3-50bbbcad6db1	2026-07-21 12:23:05.653402+00	2026-07-21 12:23:05.653402+00	in_progress	\N	74	15.40	2026-07-18	medium
9e026bc3-66b8-45d7-9c60-0989a6664192	432d011d-9811-4926-818f-2b63ae8aa481	\N	0aa7f564-65bd-473d-aa0e-3abc4663b507	0aa7f564-65bd-473d-aa0e-3abc4663b507	بررسی قراردادهای مالی جدید #35	\N	high	2026-08-07	b1167940-3356-4243-939c-887247f09ab2	2026-07-21 12:23:05.653402+00	2026-07-21 12:23:05.653402+00	in_progress	\N	60	12.90	2026-07-17	medium
9e026bc3-66b8-45d7-9c60-0989a6664192	432d011d-9811-4926-818f-2b63ae8aa481	\N	0aa7f564-65bd-473d-aa0e-3abc4663b507	0aa7f564-65bd-473d-aa0e-3abc4663b507	بررسی قراردادهای مالی جدید #36	\N	medium	2026-07-19	b858afad-ea7a-42f5-892d-ba04178a1309	2026-07-21 12:23:05.653402+00	2026-07-21 12:23:05.653402+00	todo	\N	46	31.00	2026-07-13	medium
9e026bc3-66b8-45d7-9c60-0989a6664192	dfc1e39f-343f-43e4-a459-9626f69442a6	\N	e5c268f5-5274-4960-be2b-6f7bbba26625	0aa7f564-65bd-473d-aa0e-3abc4663b507	بررسی صورت وضعیت پیمانکاران #37	\N	high	2026-07-14	e34002ca-df94-45e0-8bd9-ce9aea4b9c92	2026-07-21 12:23:05.653402+00	2026-07-21 12:23:05.653402+00	todo	\N	24	15.80	2026-07-11	medium
9e026bc3-66b8-45d7-9c60-0989a6664192	dfc1e39f-343f-43e4-a459-9626f69442a6	\N	e5c268f5-5274-4960-be2b-6f7bbba26625	0aa7f564-65bd-473d-aa0e-3abc4663b507	به‌روزرسانی جدول حقوق و دستمزد #38	\N	high	2026-07-28	05e90a6a-0c57-4388-91f2-24272147184c	2026-07-21 12:23:05.653402+00	2026-07-21 12:23:05.653402+00	todo	\N	35	33.40	2026-07-10	medium
9e026bc3-66b8-45d7-9c60-0989a6664192	dfc1e39f-343f-43e4-a459-9626f69442a6	\N	515597de-809a-4b6a-9fb6-5e2cf6d9dfe2	0aa7f564-65bd-473d-aa0e-3abc4663b507	بررسی فاکتورهای فروش صادرشده #39	\N	medium	2026-06-29	d9b9ca9c-1e4c-4148-a032-2655fe6d185e	2026-07-21 12:23:05.653402+00	2026-07-21 12:23:05.653402+00	completed	pending	100	32.20	2026-06-24	medium
9e026bc3-66b8-45d7-9c60-0989a6664192	dfc1e39f-343f-43e4-a459-9626f69442a6	\N	e5c268f5-5274-4960-be2b-6f7bbba26625	0aa7f564-65bd-473d-aa0e-3abc4663b507	ثبت اسناد حسابداری هفتگی #40	\N	high	2026-08-09	f7b5ac0d-fe4e-4986-b496-06fb425ecfa2	2026-07-21 12:23:05.653402+00	2026-07-21 12:23:05.653402+00	completed	rejected	100	21.30	2026-08-03	medium
9e026bc3-66b8-45d7-9c60-0989a6664192	dfc1e39f-343f-43e4-a459-9626f69442a6	\N	515597de-809a-4b6a-9fb6-5e2cf6d9dfe2	0aa7f564-65bd-473d-aa0e-3abc4663b507	مغایرت‌گیری حساب‌های بانکی #41	\N	high	2026-06-21	7e7eb2a1-3b9e-4b34-ac0e-bba68a54bd51	2026-07-21 12:23:05.653402+00	2026-07-21 12:23:05.653402+00	todo	\N	42	32.60	2026-06-18	medium
9e026bc3-66b8-45d7-9c60-0989a6664192	dfc1e39f-343f-43e4-a459-9626f69442a6	\N	515597de-809a-4b6a-9fb6-5e2cf6d9dfe2	0aa7f564-65bd-473d-aa0e-3abc4663b507	مغایرت‌گیری حساب‌های بانکی #42	\N	medium	2026-08-30	46f27a2b-82e5-4f5c-96f3-5f5fc8eaabc4	2026-07-21 12:23:05.653402+00	2026-07-21 12:23:05.653402+00	completed	approved	100	37.40	2026-08-12	medium
9e026bc3-66b8-45d7-9c60-0989a6664192	dfc1e39f-343f-43e4-a459-9626f69442a6	\N	e5c268f5-5274-4960-be2b-6f7bbba26625	0aa7f564-65bd-473d-aa0e-3abc4663b507	تهیهٔ گزارش جریان نقدی #43	\N	medium	2026-08-01	ee857e37-b4ab-4ce1-bbb8-182247689def	2026-07-21 12:23:05.653402+00	2026-07-21 12:23:05.653402+00	todo	\N	75	14.80	2026-07-11	medium
9e026bc3-66b8-45d7-9c60-0989a6664192	dfc1e39f-343f-43e4-a459-9626f69442a6	\N	c17589b4-349d-4156-9b66-f7ecf971b52d	0aa7f564-65bd-473d-aa0e-3abc4663b507	پیگیری مطالبات معوق مشتریان #44	\N	medium	2026-08-20	65df4ed8-72c2-4fd0-a412-115499a4638d	2026-07-21 12:23:05.653402+00	2026-07-21 12:23:05.653402+00	completed	approved	100	33.00	2026-07-31	medium
9e026bc3-66b8-45d7-9c60-0989a6664192	dfc1e39f-343f-43e4-a459-9626f69442a6	\N	e5c268f5-5274-4960-be2b-6f7bbba26625	0aa7f564-65bd-473d-aa0e-3abc4663b507	بررسی فاکتورهای فروش صادرشده #45	\N	high	2026-08-03	34dd8e78-0904-412b-a2f5-87d3d1a1b208	2026-07-21 12:23:05.653402+00	2026-07-21 12:23:05.653402+00	in_progress	\N	39	32.30	2026-07-29	medium
9e026bc3-66b8-45d7-9c60-0989a6664192	dfc1e39f-343f-43e4-a459-9626f69442a6	\N	147770ac-f6f9-4af1-97c3-cccc614d44e9	0aa7f564-65bd-473d-aa0e-3abc4663b507	پیگیری مطالبات معوق مشتریان #46	\N	high	2026-08-10	1e61e1a5-9951-4cf5-94f5-478db93635c9	2026-07-21 12:23:05.653402+00	2026-07-21 12:23:05.653402+00	completed	pending	100	31.80	2026-07-24	medium
9e026bc3-66b8-45d7-9c60-0989a6664192	dfc1e39f-343f-43e4-a459-9626f69442a6	\N	c17589b4-349d-4156-9b66-f7ecf971b52d	0aa7f564-65bd-473d-aa0e-3abc4663b507	بررسی صورت وضعیت پیمانکاران #47	\N	medium	2026-08-04	c14ed08f-41b0-498a-87bb-bb99b8327f59	2026-07-21 12:23:05.653402+00	2026-07-21 12:23:05.653402+00	completed	approved	100	8.50	2026-08-01	medium
9e026bc3-66b8-45d7-9c60-0989a6664192	dfc1e39f-343f-43e4-a459-9626f69442a6	\N	147770ac-f6f9-4af1-97c3-cccc614d44e9	0aa7f564-65bd-473d-aa0e-3abc4663b507	مغایرت‌گیری حساب‌های بانکی #48	\N	high	2026-08-08	5e98d720-f979-41dd-b750-54ca05ccf2ed	2026-07-21 12:23:05.653402+00	2026-07-21 12:23:05.653402+00	archived	\N	31	3.20	2026-07-25	medium
9e026bc3-66b8-45d7-9c60-0989a6664192	dfc1e39f-343f-43e4-a459-9626f69442a6	\N	147770ac-f6f9-4af1-97c3-cccc614d44e9	0aa7f564-65bd-473d-aa0e-3abc4663b507	به‌روزرسانی جدول حقوق و دستمزد #49	\N	medium	2026-06-30	6f65cde0-5c20-47dd-a086-8f251c428bfa	2026-07-21 12:23:05.653402+00	2026-07-21 12:23:05.653402+00	todo	\N	53	7.80	2026-06-28	medium
9e026bc3-66b8-45d7-9c60-0989a6664192	dfc1e39f-343f-43e4-a459-9626f69442a6	\N	147770ac-f6f9-4af1-97c3-cccc614d44e9	0aa7f564-65bd-473d-aa0e-3abc4663b507	بررسی و تسویهٔ کارت اعتباری شرکت #50	\N	high	2026-07-30	813c667a-82df-4d32-84a3-3438832917ea	2026-07-21 12:23:05.653402+00	2026-07-21 12:23:05.653402+00	in_progress	\N	60	35.20	2026-07-12	medium
9e026bc3-66b8-45d7-9c60-0989a6664192	dfc1e39f-343f-43e4-a459-9626f69442a6	\N	147770ac-f6f9-4af1-97c3-cccc614d44e9	0aa7f564-65bd-473d-aa0e-3abc4663b507	تهیهٔ پیش‌نویس بودجهٔ واحد #51	\N	low	2026-06-25	27d643ad-9463-45d1-8ca7-7a1e79ce3c91	2026-07-21 12:23:05.653402+00	2026-07-21 12:23:05.653402+00	archived	\N	71	14.40	2026-06-19	medium
9e026bc3-66b8-45d7-9c60-0989a6664192	dfc1e39f-343f-43e4-a459-9626f69442a6	\N	147770ac-f6f9-4af1-97c3-cccc614d44e9	0aa7f564-65bd-473d-aa0e-3abc4663b507	به‌روزرسانی جدول حقوق و دستمزد #52	\N	high	2026-07-13	7edf3b53-728c-4e98-9da2-c9f3eceefb49	2026-07-21 12:23:05.653402+00	2026-07-21 12:23:05.653402+00	completed	approved	100	15.00	2026-07-06	medium
9e026bc3-66b8-45d7-9c60-0989a6664192	dfc1e39f-343f-43e4-a459-9626f69442a6	\N	e5c268f5-5274-4960-be2b-6f7bbba26625	0aa7f564-65bd-473d-aa0e-3abc4663b507	بررسی صورت وضعیت پیمانکاران #53	\N	medium	2026-08-11	67a9642f-6d75-475d-91c8-8bb6a85bf7dd	2026-07-21 12:23:05.653402+00	2026-07-21 12:23:05.653402+00	completed	pending	100	9.30	2026-08-01	medium
9e026bc3-66b8-45d7-9c60-0989a6664192	dfc1e39f-343f-43e4-a459-9626f69442a6	\N	6115c41b-8c19-4fa9-b656-df967e8a945e	0aa7f564-65bd-473d-aa0e-3abc4663b507	ثبت اسناد حسابداری هفتگی #54	\N	medium	2026-08-01	e4015f9d-8a47-4dcf-99fc-22fa90da53bd	2026-07-21 12:23:05.653402+00	2026-07-21 12:23:05.653402+00	in_progress	\N	36	28.80	2026-07-21	medium
9e026bc3-66b8-45d7-9c60-0989a6664192	776f6076-91bd-4f6d-8fcd-ada6f5d2a107	\N	147770ac-f6f9-4af1-97c3-cccc614d44e9	0aa7f564-65bd-473d-aa0e-3abc4663b507	به‌روزرسانی جدول حقوق و دستمزد #55	\N	medium	2026-07-29	682d3a66-75b7-4ebd-88dc-b2b5b65614e7	2026-07-21 12:23:05.653402+00	2026-07-21 12:23:05.653402+00	archived	\N	71	37.50	2026-07-17	medium
9e026bc3-66b8-45d7-9c60-0989a6664192	776f6076-91bd-4f6d-8fcd-ada6f5d2a107	\N	c17589b4-349d-4156-9b66-f7ecf971b52d	0aa7f564-65bd-473d-aa0e-3abc4663b507	تهیهٔ گزارش سود و زیان ماهانه #56	\N	high	2026-07-14	3b6d3f7f-79ed-4c89-a170-1a5e8280f81e	2026-07-21 12:23:05.653402+00	2026-07-21 12:23:05.653402+00	archived	\N	69	16.40	2026-07-03	medium
9e026bc3-66b8-45d7-9c60-0989a6664192	776f6076-91bd-4f6d-8fcd-ada6f5d2a107	\N	6965fa45-fddb-4465-b0e6-042192ac6ee2	0aa7f564-65bd-473d-aa0e-3abc4663b507	پیگیری مطالبات معوق مشتریان #57	\N	low	2026-08-10	a03714c0-3dba-4d34-ab9f-2d04174cbdc7	2026-07-21 12:23:05.653402+00	2026-07-21 12:23:05.653402+00	in_progress	\N	36	38.30	2026-08-04	medium
9e026bc3-66b8-45d7-9c60-0989a6664192	776f6076-91bd-4f6d-8fcd-ada6f5d2a107	\N	0aa7f564-65bd-473d-aa0e-3abc4663b507	0aa7f564-65bd-473d-aa0e-3abc4663b507	تطبیق موجودی انبار با حساب‌ها #58	\N	medium	2026-08-30	233fa2d3-a006-4168-b558-af0915e58186	2026-07-21 12:23:05.653402+00	2026-07-21 12:23:05.653402+00	in_progress	\N	61	10.10	2026-08-14	medium
9e026bc3-66b8-45d7-9c60-0989a6664192	776f6076-91bd-4f6d-8fcd-ada6f5d2a107	\N	c17589b4-349d-4156-9b66-f7ecf971b52d	0aa7f564-65bd-473d-aa0e-3abc4663b507	مغایرت‌گیری حساب‌های بانکی #59	\N	low	2026-07-31	e875c7fc-9add-48e7-9839-a28ccd683396	2026-07-21 12:23:05.653402+00	2026-07-21 12:23:05.653402+00	completed	approved	100	25.40	2026-07-21	medium
9e026bc3-66b8-45d7-9c60-0989a6664192	776f6076-91bd-4f6d-8fcd-ada6f5d2a107	\N	515597de-809a-4b6a-9fb6-5e2cf6d9dfe2	0aa7f564-65bd-473d-aa0e-3abc4663b507	تطبیق موجودی انبار با حساب‌ها #60	\N	high	2026-07-04	b2e96517-c909-470a-ba85-48c2550e0e9e	2026-07-21 12:23:05.653402+00	2026-07-21 12:23:05.653402+00	in_progress	\N	28	26.20	2026-07-01	medium
9e026bc3-66b8-45d7-9c60-0989a6664192	776f6076-91bd-4f6d-8fcd-ada6f5d2a107	\N	0aa7f564-65bd-473d-aa0e-3abc4663b507	0aa7f564-65bd-473d-aa0e-3abc4663b507	تهیهٔ گزارش جریان نقدی #61	\N	medium	2026-07-24	99a8fb60-0186-4529-8595-6a1a0bc57276	2026-07-21 12:23:05.653402+00	2026-07-21 12:23:05.653402+00	todo	\N	12	27.90	2026-07-12	medium
9e026bc3-66b8-45d7-9c60-0989a6664192	776f6076-91bd-4f6d-8fcd-ada6f5d2a107	\N	6115c41b-8c19-4fa9-b656-df967e8a945e	0aa7f564-65bd-473d-aa0e-3abc4663b507	بررسی فاکتورهای فروش صادرشده #62	\N	high	2026-07-28	289d1aff-e606-4e84-a4f4-2c74417e343f	2026-07-21 12:23:05.653402+00	2026-07-21 12:23:05.653402+00	todo	\N	60	20.10	2026-07-21	medium
9e026bc3-66b8-45d7-9c60-0989a6664192	776f6076-91bd-4f6d-8fcd-ada6f5d2a107	\N	6115c41b-8c19-4fa9-b656-df967e8a945e	0aa7f564-65bd-473d-aa0e-3abc4663b507	پیگیری مطالبات معوق مشتریان #63	\N	high	2026-07-16	96d5ce7e-ae2d-41a2-9069-faec402a0a72	2026-07-21 12:23:05.653402+00	2026-07-21 12:23:05.653402+00	archived	\N	7	36.50	2026-07-04	medium
9e026bc3-66b8-45d7-9c60-0989a6664192	776f6076-91bd-4f6d-8fcd-ada6f5d2a107	\N	0aa7f564-65bd-473d-aa0e-3abc4663b507	0aa7f564-65bd-473d-aa0e-3abc4663b507	بررسی قراردادهای مالی جدید #64	\N	low	2026-07-23	16d5e540-4815-45de-8f08-fe2c13720121	2026-07-21 12:23:05.653402+00	2026-07-21 12:23:05.653402+00	completed	approved	100	17.90	2026-07-20	medium
9e026bc3-66b8-45d7-9c60-0989a6664192	776f6076-91bd-4f6d-8fcd-ada6f5d2a107	\N	c17589b4-349d-4156-9b66-f7ecf971b52d	0aa7f564-65bd-473d-aa0e-3abc4663b507	پیگیری بیمهٔ کارکنان #65	\N	medium	2026-08-17	1c0debc4-5761-4205-a4cc-64e8c9a71c9a	2026-07-21 12:23:05.653402+00	2026-07-21 12:23:05.653402+00	todo	\N	63	9.10	2026-08-14	medium
9e026bc3-66b8-45d7-9c60-0989a6664192	776f6076-91bd-4f6d-8fcd-ada6f5d2a107	\N	147770ac-f6f9-4af1-97c3-cccc614d44e9	0aa7f564-65bd-473d-aa0e-3abc4663b507	بررسی و تأیید صورت‌حساب‌های خرید #66	\N	medium	2026-08-14	88ce644d-8820-4bfd-a7ef-c20dd0750e16	2026-07-21 12:23:05.653402+00	2026-07-21 12:23:05.653402+00	in_progress	\N	72	24.90	2026-08-11	medium
9e026bc3-66b8-45d7-9c60-0989a6664192	776f6076-91bd-4f6d-8fcd-ada6f5d2a107	\N	e5c268f5-5274-4960-be2b-6f7bbba26625	0aa7f564-65bd-473d-aa0e-3abc4663b507	تهیهٔ پیش‌نویس بودجهٔ واحد #67	\N	medium	2026-08-03	8cc37be7-c61a-4e75-8528-dfca5bfedf5b	2026-07-21 12:23:05.653402+00	2026-07-21 12:23:05.653402+00	in_progress	\N	17	34.30	2026-07-15	medium
9e026bc3-66b8-45d7-9c60-0989a6664192	776f6076-91bd-4f6d-8fcd-ada6f5d2a107	\N	6965fa45-fddb-4465-b0e6-042192ac6ee2	0aa7f564-65bd-473d-aa0e-3abc4663b507	تهیهٔ گزارش مالیاتی فصلی #68	\N	low	2026-07-03	8cfcf3d7-673a-44b9-93a4-905294b3d30e	2026-07-21 12:23:05.653402+00	2026-07-21 12:23:05.653402+00	in_progress	\N	58	26.60	2026-06-28	medium
9e026bc3-66b8-45d7-9c60-0989a6664192	776f6076-91bd-4f6d-8fcd-ada6f5d2a107	\N	147770ac-f6f9-4af1-97c3-cccc614d44e9	0aa7f564-65bd-473d-aa0e-3abc4663b507	بررسی و تسویهٔ کارت اعتباری شرکت #69	\N	medium	2026-06-28	9d5c62a7-179d-43de-88cb-db88cc39b37b	2026-07-21 12:23:05.653402+00	2026-07-21 12:23:05.653402+00	todo	\N	72	27.60	2026-06-16	medium
9e026bc3-66b8-45d7-9c60-0989a6664192	776f6076-91bd-4f6d-8fcd-ada6f5d2a107	\N	6115c41b-8c19-4fa9-b656-df967e8a945e	0aa7f564-65bd-473d-aa0e-3abc4663b507	پیگیری بیمهٔ کارکنان #70	\N	medium	2026-08-08	6571fb6d-89c7-49f9-b6da-edc6b54b5b69	2026-07-21 12:23:05.653402+00	2026-07-21 12:23:05.653402+00	todo	\N	65	14.50	2026-07-25	medium
9e026bc3-66b8-45d7-9c60-0989a6664192	776f6076-91bd-4f6d-8fcd-ada6f5d2a107	\N	6965fa45-fddb-4465-b0e6-042192ac6ee2	0aa7f564-65bd-473d-aa0e-3abc4663b507	تهیهٔ گزارش مالیاتی فصلی #71	\N	low	2026-07-11	3682d4bc-612a-4daf-8b8b-9ee7a1c0a989	2026-07-21 12:23:05.653402+00	2026-07-21 12:23:05.653402+00	completed	approved	100	2.30	2026-06-24	medium
9e026bc3-66b8-45d7-9c60-0989a6664192	776f6076-91bd-4f6d-8fcd-ada6f5d2a107	\N	6965fa45-fddb-4465-b0e6-042192ac6ee2	0aa7f564-65bd-473d-aa0e-3abc4663b507	تهیهٔ گزارش مالیاتی فصلی #72	\N	medium	2026-07-24	c5d15e1b-a189-4743-a902-05d64ea635d1	2026-07-21 12:23:05.653402+00	2026-07-21 12:23:05.653402+00	in_progress	\N	74	29.50	2026-07-14	medium
9e026bc3-66b8-45d7-9c60-0989a6664192	f8f67ced-14a7-481c-8f04-dbff36848e4e	\N	0aa7f564-65bd-473d-aa0e-3abc4663b507	0aa7f564-65bd-473d-aa0e-3abc4663b507	تهیهٔ گزارش جریان نقدی #73	\N	low	2026-08-09	695c5710-742b-473f-ac6d-9a3cac4c704a	2026-07-21 12:23:05.653402+00	2026-07-21 12:23:05.653402+00	in_progress	\N	7	27.40	2026-07-27	medium
9e026bc3-66b8-45d7-9c60-0989a6664192	f8f67ced-14a7-481c-8f04-dbff36848e4e	\N	6965fa45-fddb-4465-b0e6-042192ac6ee2	0aa7f564-65bd-473d-aa0e-3abc4663b507	تطبیق موجودی انبار با حساب‌ها #74	\N	high	2026-07-10	db1bc737-2567-486b-ac8c-2779b7c938d6	2026-07-21 12:23:05.653402+00	2026-07-21 12:23:05.653402+00	in_progress	\N	39	28.20	2026-06-26	medium
9e026bc3-66b8-45d7-9c60-0989a6664192	f8f67ced-14a7-481c-8f04-dbff36848e4e	\N	147770ac-f6f9-4af1-97c3-cccc614d44e9	0aa7f564-65bd-473d-aa0e-3abc4663b507	ثبت اسناد حسابداری هفتگی #75	\N	low	2026-07-30	bf26f4f3-8152-4e90-a844-4db1619a92e1	2026-07-21 12:23:05.653402+00	2026-07-21 12:23:05.653402+00	in_progress	\N	17	20.20	2026-07-09	medium
9e026bc3-66b8-45d7-9c60-0989a6664192	f8f67ced-14a7-481c-8f04-dbff36848e4e	\N	6965fa45-fddb-4465-b0e6-042192ac6ee2	0aa7f564-65bd-473d-aa0e-3abc4663b507	بررسی فاکتورهای فروش صادرشده #76	\N	high	2026-08-06	968a9092-0f8c-40ea-b609-2463495f3720	2026-07-21 12:23:05.653402+00	2026-07-21 12:23:05.653402+00	archived	\N	70	36.70	2026-07-24	medium
9e026bc3-66b8-45d7-9c60-0989a6664192	f8f67ced-14a7-481c-8f04-dbff36848e4e	\N	c17589b4-349d-4156-9b66-f7ecf971b52d	0aa7f564-65bd-473d-aa0e-3abc4663b507	بررسی و تسویهٔ کارت اعتباری شرکت #77	\N	low	2026-08-15	7a61eece-61d6-47ff-9ad0-1c250fc558c5	2026-07-21 12:23:05.653402+00	2026-07-21 12:23:05.653402+00	completed	pending	100	27.90	2026-08-07	medium
9e026bc3-66b8-45d7-9c60-0989a6664192	f8f67ced-14a7-481c-8f04-dbff36848e4e	\N	515597de-809a-4b6a-9fb6-5e2cf6d9dfe2	0aa7f564-65bd-473d-aa0e-3abc4663b507	تهیهٔ پیش‌نویس بودجهٔ واحد #78	\N	high	2026-08-04	a901438d-185b-4acb-9c71-1ddd4a1dfaae	2026-07-21 12:23:05.653402+00	2026-07-21 12:23:05.653402+00	todo	\N	46	5.00	2026-07-19	medium
9e026bc3-66b8-45d7-9c60-0989a6664192	f8f67ced-14a7-481c-8f04-dbff36848e4e	\N	515597de-809a-4b6a-9fb6-5e2cf6d9dfe2	0aa7f564-65bd-473d-aa0e-3abc4663b507	بررسی قراردادهای مالی جدید #79	\N	high	2026-07-08	ac456c62-fc6b-4eed-bb8b-9dd77bab5879	2026-07-21 12:23:05.653402+00	2026-07-21 12:23:05.653402+00	todo	\N	25	23.80	2026-06-19	medium
9e026bc3-66b8-45d7-9c60-0989a6664192	f8f67ced-14a7-481c-8f04-dbff36848e4e	\N	6115c41b-8c19-4fa9-b656-df967e8a945e	0aa7f564-65bd-473d-aa0e-3abc4663b507	به‌روزرسانی جدول حقوق و دستمزد #80	\N	low	2026-07-24	13c27eb6-3f82-4a4f-bfab-0952dda46af7	2026-07-21 12:23:05.653402+00	2026-07-21 12:23:05.653402+00	todo	\N	26	29.20	2026-07-06	medium
9e026bc3-66b8-45d7-9c60-0989a6664192	f8f67ced-14a7-481c-8f04-dbff36848e4e	\N	6965fa45-fddb-4465-b0e6-042192ac6ee2	0aa7f564-65bd-473d-aa0e-3abc4663b507	به‌روزرسانی جدول حقوق و دستمزد #81	\N	low	2026-08-30	8547b3a9-b735-4348-9c14-93a112add6d3	2026-07-21 12:23:05.653402+00	2026-07-21 12:23:05.653402+00	todo	\N	58	7.00	2026-08-12	medium
9e026bc3-66b8-45d7-9c60-0989a6664192	f8f67ced-14a7-481c-8f04-dbff36848e4e	\N	6965fa45-fddb-4465-b0e6-042192ac6ee2	0aa7f564-65bd-473d-aa0e-3abc4663b507	تطبیق موجودی انبار با حساب‌ها #82	\N	medium	2026-08-06	a9452d8d-6662-4386-a8eb-b769ae1bcd69	2026-07-21 12:23:05.653402+00	2026-07-21 12:23:05.653402+00	completed	approved	100	29.50	2026-07-21	medium
9e026bc3-66b8-45d7-9c60-0989a6664192	f8f67ced-14a7-481c-8f04-dbff36848e4e	\N	6965fa45-fddb-4465-b0e6-042192ac6ee2	0aa7f564-65bd-473d-aa0e-3abc4663b507	تهیهٔ گزارش جریان نقدی #83	\N	low	2026-08-09	3e629a15-a309-4ab9-b716-e7c474ef3425	2026-07-21 12:23:05.653402+00	2026-07-21 12:23:05.653402+00	in_progress	\N	74	4.80	2026-08-07	medium
9e026bc3-66b8-45d7-9c60-0989a6664192	f8f67ced-14a7-481c-8f04-dbff36848e4e	\N	6965fa45-fddb-4465-b0e6-042192ac6ee2	0aa7f564-65bd-473d-aa0e-3abc4663b507	تهیهٔ پیش‌نویس بودجهٔ واحد #84	\N	low	2026-08-03	4659f8dd-ddcd-4725-9ec9-9792b13fe6c9	2026-07-21 12:23:05.653402+00	2026-07-21 12:23:05.653402+00	in_progress	\N	8	39.50	2026-07-30	medium
9e026bc3-66b8-45d7-9c60-0989a6664192	f8f67ced-14a7-481c-8f04-dbff36848e4e	\N	6965fa45-fddb-4465-b0e6-042192ac6ee2	0aa7f564-65bd-473d-aa0e-3abc4663b507	مغایرت‌گیری حساب‌های بانکی #85	\N	low	2026-07-19	d58fe9bb-6498-401b-8343-66eae960567d	2026-07-21 12:23:05.653402+00	2026-07-21 12:23:05.653402+00	todo	\N	53	16.20	2026-07-04	medium
9e026bc3-66b8-45d7-9c60-0989a6664192	f8f67ced-14a7-481c-8f04-dbff36848e4e	\N	6965fa45-fddb-4465-b0e6-042192ac6ee2	0aa7f564-65bd-473d-aa0e-3abc4663b507	بررسی فاکتورهای فروش صادرشده #86	\N	low	2026-08-27	01e186df-6228-4ecf-88ee-e1732585bd62	2026-07-21 12:23:05.653402+00	2026-07-21 12:23:05.653402+00	completed	pending	100	27.90	2026-08-13	medium
9e026bc3-66b8-45d7-9c60-0989a6664192	f8f67ced-14a7-481c-8f04-dbff36848e4e	\N	147770ac-f6f9-4af1-97c3-cccc614d44e9	0aa7f564-65bd-473d-aa0e-3abc4663b507	تهیهٔ گزارش سود و زیان ماهانه #87	\N	low	2026-08-23	d8189b1d-dfac-4d17-85d3-ae548bd7f1fd	2026-07-21 12:23:05.653402+00	2026-07-21 12:23:05.653402+00	completed	approved	100	39.70	2026-08-10	medium
9e026bc3-66b8-45d7-9c60-0989a6664192	f8f67ced-14a7-481c-8f04-dbff36848e4e	\N	6965fa45-fddb-4465-b0e6-042192ac6ee2	0aa7f564-65bd-473d-aa0e-3abc4663b507	بررسی و تسویهٔ کارت اعتباری شرکت #88	\N	low	2026-07-02	61d9a59e-6de5-49a0-aeae-5d342a72136f	2026-07-21 12:23:05.653402+00	2026-07-21 12:23:05.653402+00	completed	approved	100	39.20	2026-06-30	medium
9e026bc3-66b8-45d7-9c60-0989a6664192	f8f67ced-14a7-481c-8f04-dbff36848e4e	\N	6965fa45-fddb-4465-b0e6-042192ac6ee2	0aa7f564-65bd-473d-aa0e-3abc4663b507	بررسی فاکتورهای فروش صادرشده #89	\N	low	2026-08-01	fe24aea6-e863-459e-9ab0-c5ec81c5f219	2026-07-21 12:23:05.653402+00	2026-07-21 12:23:05.653402+00	completed	pending	100	11.40	2026-07-13	medium
9e026bc3-66b8-45d7-9c60-0989a6664192	f8f67ced-14a7-481c-8f04-dbff36848e4e	\N	e5c268f5-5274-4960-be2b-6f7bbba26625	0aa7f564-65bd-473d-aa0e-3abc4663b507	بررسی قراردادهای مالی جدید #90	\N	high	2026-07-11	d558226b-00dc-4f77-8274-68d3583c8a8c	2026-07-21 12:23:05.653402+00	2026-07-21 12:23:05.653402+00	todo	\N	14	3.20	2026-07-03	medium
9e026bc3-66b8-45d7-9c60-0989a6664192	\N	\N	147770ac-f6f9-4af1-97c3-cccc614d44e9	147770ac-f6f9-4af1-97c3-cccc614d44e9	ثبت اسناد حسابداری هفتگی #91	\N	low	2026-07-27	6756ee7b-5220-454b-8443-a9185fdfba7a	2026-07-21 12:23:05.653402+00	2026-07-21 12:23:05.653402+00	in_progress	\N	8	5.80	2026-07-25	medium
9e026bc3-66b8-45d7-9c60-0989a6664192	\N	\N	0aa7f564-65bd-473d-aa0e-3abc4663b507	0aa7f564-65bd-473d-aa0e-3abc4663b507	ثبت اسناد حسابداری هفتگی #92	\N	high	2026-08-03	5603f2c3-3b95-400a-b1b2-e6b5f2f0d770	2026-07-21 12:23:05.653402+00	2026-07-21 12:23:05.653402+00	completed	approved	100	3.70	2026-07-31	medium
9e026bc3-66b8-45d7-9c60-0989a6664192	\N	\N	6965fa45-fddb-4465-b0e6-042192ac6ee2	6965fa45-fddb-4465-b0e6-042192ac6ee2	بررسی و تسویهٔ کارت اعتباری شرکت #93	\N	low	2026-07-28	8ed90b0b-bff2-4a60-9543-430d33ad04ff	2026-07-21 12:23:05.653402+00	2026-07-21 12:23:05.653402+00	in_progress	\N	17	21.10	2026-07-20	medium
9e026bc3-66b8-45d7-9c60-0989a6664192	\N	\N	e5c268f5-5274-4960-be2b-6f7bbba26625	e5c268f5-5274-4960-be2b-6f7bbba26625	تهیهٔ گزارش مالیاتی فصلی #94	\N	high	2026-08-27	94279e2b-2f2e-4c65-a538-9a8af31fcc28	2026-07-21 12:23:05.653402+00	2026-07-21 12:23:05.653402+00	in_progress	\N	76	31.40	2026-08-07	medium
9e026bc3-66b8-45d7-9c60-0989a6664192	\N	\N	c17589b4-349d-4156-9b66-f7ecf971b52d	c17589b4-349d-4156-9b66-f7ecf971b52d	بررسی قراردادهای مالی جدید #95	\N	low	2026-07-12	900b66d7-cd14-4586-b8a2-cd640bee326d	2026-07-21 12:23:05.653402+00	2026-07-21 12:23:05.653402+00	in_progress	\N	66	10.40	2026-07-01	medium
9e026bc3-66b8-45d7-9c60-0989a6664192	\N	\N	e5c268f5-5274-4960-be2b-6f7bbba26625	e5c268f5-5274-4960-be2b-6f7bbba26625	بررسی صورت وضعیت پیمانکاران #96	\N	high	2026-07-08	8843e95c-c043-4139-accf-c554bad4e803	2026-07-21 12:23:05.653402+00	2026-07-21 12:23:05.653402+00	in_progress	\N	22	25.80	2026-06-19	medium
9e026bc3-66b8-45d7-9c60-0989a6664192	\N	\N	6965fa45-fddb-4465-b0e6-042192ac6ee2	6965fa45-fddb-4465-b0e6-042192ac6ee2	بررسی و تسویهٔ کارت اعتباری شرکت #97	\N	high	2026-07-22	bfb2d86f-a464-43b5-b73a-26077a03d312	2026-07-21 12:23:05.653402+00	2026-07-21 12:23:05.653402+00	completed	approved	100	14.10	2026-07-08	medium
9e026bc3-66b8-45d7-9c60-0989a6664192	\N	\N	6965fa45-fddb-4465-b0e6-042192ac6ee2	6965fa45-fddb-4465-b0e6-042192ac6ee2	بررسی فاکتورهای فروش صادرشده #98	\N	low	2026-07-06	a2af9c87-07d7-48a0-a12d-14f87c4669ff	2026-07-21 12:23:05.653402+00	2026-07-21 12:23:05.653402+00	in_progress	\N	68	20.00	2026-06-25	medium
9e026bc3-66b8-45d7-9c60-0989a6664192	\N	\N	c17589b4-349d-4156-9b66-f7ecf971b52d	c17589b4-349d-4156-9b66-f7ecf971b52d	بررسی و تسویهٔ کارت اعتباری شرکت #99	\N	medium	2026-07-11	57f2887f-356d-4cef-bf91-5dd01c3b7f0a	2026-07-21 12:23:05.653402+00	2026-07-21 12:23:05.653402+00	in_progress	\N	7	23.40	2026-07-05	medium
9e026bc3-66b8-45d7-9c60-0989a6664192	\N	\N	6965fa45-fddb-4465-b0e6-042192ac6ee2	6965fa45-fddb-4465-b0e6-042192ac6ee2	پیگیری مطالبات معوق مشتریان #100	\N	low	2026-07-19	e6712361-5302-43f9-b1a8-27a620b2b9da	2026-07-21 12:23:05.653402+00	2026-07-21 12:23:05.653402+00	completed	approved	100	14.50	2026-07-10	medium
9e026bc3-66b8-45d7-9c60-0989a6664192	\N	\N	0aa7f564-65bd-473d-aa0e-3abc4663b507	0aa7f564-65bd-473d-aa0e-3abc4663b507	تهیهٔ گزارش جریان نقدی #101	\N	low	2026-07-10	0de7d11e-7e0b-4331-9df7-b2356b3a346e	2026-07-21 12:23:05.653402+00	2026-07-21 12:23:05.653402+00	completed	pending	100	4.00	2026-06-21	medium
9e026bc3-66b8-45d7-9c60-0989a6664192	\N	\N	6965fa45-fddb-4465-b0e6-042192ac6ee2	6965fa45-fddb-4465-b0e6-042192ac6ee2	ثبت اسناد حسابداری هفتگی #102	\N	high	2026-06-22	dbd913a6-1b8e-4e3d-83fc-62136f474292	2026-07-21 12:23:05.653402+00	2026-07-21 12:23:05.653402+00	completed	pending	100	29.50	2026-06-18	medium
9e026bc3-66b8-45d7-9c60-0989a6664192	\N	\N	515597de-809a-4b6a-9fb6-5e2cf6d9dfe2	515597de-809a-4b6a-9fb6-5e2cf6d9dfe2	پیگیری بیمهٔ کارکنان #103	\N	medium	2026-07-24	428518ff-1bc7-4c5c-8c76-00132bace5c5	2026-07-21 12:23:05.653402+00	2026-07-21 12:23:05.653402+00	in_progress	\N	38	38.40	2026-07-16	medium
9e026bc3-66b8-45d7-9c60-0989a6664192	\N	\N	0aa7f564-65bd-473d-aa0e-3abc4663b507	0aa7f564-65bd-473d-aa0e-3abc4663b507	تهیهٔ گزارش جریان نقدی #104	\N	low	2026-08-22	05f28521-2dc9-4e7b-ac1b-2d5be0e36248	2026-07-21 12:23:05.653402+00	2026-07-21 12:23:05.653402+00	in_progress	\N	61	36.70	2026-08-14	medium
9e026bc3-66b8-45d7-9c60-0989a6664192	\N	\N	147770ac-f6f9-4af1-97c3-cccc614d44e9	147770ac-f6f9-4af1-97c3-cccc614d44e9	تهیهٔ پیش‌نویس بودجهٔ واحد #105	\N	medium	2026-07-20	45622c7e-f4cb-47e1-a54e-5a92c367e785	2026-07-21 12:23:05.653402+00	2026-07-21 12:23:05.653402+00	completed	pending	100	31.50	2026-07-11	medium
9e026bc3-66b8-45d7-9c60-0989a6664192	97ebd5ca-a1b0-474f-8195-6ee131268149	\N	be682dce-6665-4ff0-8e8a-067602882309	be682dce-6665-4ff0-8e8a-067602882309	برگزاری نظرسنجی رضایت شغلی #1	\N	low	2026-07-29	3d2f2d69-e370-4dd7-a0a7-e2c156a91ccc	2026-07-21 12:23:05.653402+00	2026-07-21 12:23:05.653402+00	todo	\N	67	34.70	2026-07-23	medium
9e026bc3-66b8-45d7-9c60-0989a6664192	97ebd5ca-a1b0-474f-8195-6ee131268149	\N	be682dce-6665-4ff0-8e8a-067602882309	be682dce-6665-4ff0-8e8a-067602882309	تدوین برنامهٔ آموزشی سال آینده #2	\N	low	2026-08-14	b1e32fb9-b275-4e58-8251-182c11a5a872	2026-07-21 12:23:05.653402+00	2026-07-21 12:23:05.653402+00	in_progress	\N	43	13.50	2026-07-31	medium
9e026bc3-66b8-45d7-9c60-0989a6664192	97ebd5ca-a1b0-474f-8195-6ee131268149	\N	37e62239-b7c6-493c-9475-fe700a479e79	be682dce-6665-4ff0-8e8a-067602882309	برگزاری نظرسنجی رضایت شغلی #3	\N	high	2026-08-16	6e2e2e8c-b878-407a-98bb-7e74946673fa	2026-07-21 12:23:05.653402+00	2026-07-21 12:23:05.653402+00	todo	\N	62	26.70	2026-08-01	medium
9e026bc3-66b8-45d7-9c60-0989a6664192	97ebd5ca-a1b0-474f-8195-6ee131268149	\N	37e62239-b7c6-493c-9475-fe700a479e79	be682dce-6665-4ff0-8e8a-067602882309	برگزاری نظرسنجی رضایت شغلی #4	\N	medium	2026-08-11	4b08a485-43df-41e7-944d-f3d1f147ec5b	2026-07-21 12:23:05.653402+00	2026-07-21 12:23:05.653402+00	archived	\N	28	27.30	2026-07-21	medium
9e026bc3-66b8-45d7-9c60-0989a6664192	97ebd5ca-a1b0-474f-8195-6ee131268149	\N	1f7a4d5f-3f0b-4a87-92e9-cf7057b674f5	be682dce-6665-4ff0-8e8a-067602882309	به‌روزرسانی پروندهٔ پرسنلی #5	\N	high	2026-07-21	e59e620d-594a-487a-943e-1a672d972cd8	2026-07-21 12:23:05.653402+00	2026-07-21 12:23:05.653402+00	todo	\N	37	6.80	2026-07-10	medium
9e026bc3-66b8-45d7-9c60-0989a6664192	97ebd5ca-a1b0-474f-8195-6ee131268149	\N	3cdfd222-0ea4-4a30-b15b-036d1d733193	be682dce-6665-4ff0-8e8a-067602882309	تهیهٔ فرم ارزیابی سه‌ماهه #6	\N	high	2026-09-04	a4daa6a0-47ea-4b2e-b604-f6600ee31c04	2026-07-21 12:23:05.653402+00	2026-07-21 12:23:05.653402+00	todo	\N	4	8.90	2026-08-15	medium
9e026bc3-66b8-45d7-9c60-0989a6664192	97ebd5ca-a1b0-474f-8195-6ee131268149	\N	fe6b733f-8cf4-4df1-a83e-2e854a480178	be682dce-6665-4ff0-8e8a-067602882309	بررسی درخواست ترفیع کارکنان #7	\N	medium	2026-07-27	aa4bb3c3-7877-46cc-a19f-9da09052911b	2026-07-21 12:23:05.653402+00	2026-07-21 12:23:05.653402+00	completed	approved	100	7.30	2026-07-22	medium
9e026bc3-66b8-45d7-9c60-0989a6664192	97ebd5ca-a1b0-474f-8195-6ee131268149	\N	3cdfd222-0ea4-4a30-b15b-036d1d733193	be682dce-6665-4ff0-8e8a-067602882309	پیگیری درخواست‌های رفاهی کارکنان #8	\N	low	2026-07-14	9fbc6d03-f260-404f-845a-03d3bf3e656f	2026-07-21 12:23:05.653402+00	2026-07-21 12:23:05.653402+00	todo	\N	11	33.20	2026-07-01	medium
9e026bc3-66b8-45d7-9c60-0989a6664192	97ebd5ca-a1b0-474f-8195-6ee131268149	\N	3cdfd222-0ea4-4a30-b15b-036d1d733193	be682dce-6665-4ff0-8e8a-067602882309	بررسی رزومه‌های متقاضیان شغلی #9	\N	medium	2026-07-23	fddc6fc9-15f6-467c-a67d-607252d4a6cd	2026-07-21 12:23:05.653402+00	2026-07-21 12:23:05.653402+00	completed	pending	100	10.00	2026-07-07	medium
9e026bc3-66b8-45d7-9c60-0989a6664192	97ebd5ca-a1b0-474f-8195-6ee131268149	\N	3cdfd222-0ea4-4a30-b15b-036d1d733193	be682dce-6665-4ff0-8e8a-067602882309	برگزاری نظرسنجی رضایت شغلی #10	\N	low	2026-07-18	d0adbc73-d6ab-441d-a65a-29543536cea1	2026-07-21 12:23:05.653402+00	2026-07-21 12:23:05.653402+00	todo	\N	0	3.80	2026-07-08	medium
9e026bc3-66b8-45d7-9c60-0989a6664192	97ebd5ca-a1b0-474f-8195-6ee131268149	\N	2310cdf5-d549-4a28-bc04-2052038876fc	be682dce-6665-4ff0-8e8a-067602882309	بررسی درخواست ترفیع کارکنان #11	\N	medium	2026-07-19	47dc122d-49e5-4b1d-ac24-1bf52b4e9ae4	2026-07-21 12:23:05.653402+00	2026-07-21 12:23:05.653402+00	archived	\N	63	35.50	2026-07-12	medium
9e026bc3-66b8-45d7-9c60-0989a6664192	97ebd5ca-a1b0-474f-8195-6ee131268149	\N	fe6b733f-8cf4-4df1-a83e-2e854a480178	be682dce-6665-4ff0-8e8a-067602882309	برگزاری نظرسنجی رضایت شغلی #12	\N	high	2026-08-25	5a08fad3-9dc7-4de3-8e0b-37a3ea60bbed	2026-07-21 12:23:05.653402+00	2026-07-21 12:23:05.653402+00	completed	approved	100	26.70	2026-08-08	medium
9e026bc3-66b8-45d7-9c60-0989a6664192	97ebd5ca-a1b0-474f-8195-6ee131268149	\N	3cdfd222-0ea4-4a30-b15b-036d1d733193	be682dce-6665-4ff0-8e8a-067602882309	برنامه‌ریزی مصاحبهٔ استخدامی #13	\N	low	2026-07-12	929261b9-baa8-4785-90c4-b1e407e23115	2026-07-21 12:23:05.653402+00	2026-07-21 12:23:05.653402+00	in_progress	\N	37	2.80	2026-06-26	medium
9e026bc3-66b8-45d7-9c60-0989a6664192	97ebd5ca-a1b0-474f-8195-6ee131268149	\N	fe6b733f-8cf4-4df1-a83e-2e854a480178	be682dce-6665-4ff0-8e8a-067602882309	تهیهٔ گزارش ارزیابی عملکرد #14	\N	medium	2026-07-02	5d23685f-0643-4066-8713-f4b10789b680	2026-07-21 12:23:05.653402+00	2026-07-21 12:23:05.653402+00	todo	\N	20	29.80	2026-06-20	medium
9e026bc3-66b8-45d7-9c60-0989a6664192	97ebd5ca-a1b0-474f-8195-6ee131268149	\N	220f13de-14e7-4c15-a3c3-d456ccb8f206	be682dce-6665-4ff0-8e8a-067602882309	تدوین برنامهٔ آموزشی سال آینده #15	\N	medium	2026-07-28	e3ac1ed6-fb79-42c9-86c3-cab3a92942d4	2026-07-21 12:23:05.653402+00	2026-07-21 12:23:05.653402+00	todo	\N	3	18.40	2026-07-07	medium
9e026bc3-66b8-45d7-9c60-0989a6664192	97ebd5ca-a1b0-474f-8195-6ee131268149	\N	3cdfd222-0ea4-4a30-b15b-036d1d733193	be682dce-6665-4ff0-8e8a-067602882309	تهیهٔ گزارش ارزیابی عملکرد #16	\N	low	2026-08-08	2c9d8ca1-08ce-4bcc-b7d9-8d1125254788	2026-07-21 12:23:05.653402+00	2026-07-21 12:23:05.653402+00	todo	\N	12	14.60	2026-07-24	medium
9e026bc3-66b8-45d7-9c60-0989a6664192	97ebd5ca-a1b0-474f-8195-6ee131268149	\N	37e62239-b7c6-493c-9475-fe700a479e79	be682dce-6665-4ff0-8e8a-067602882309	به‌روزرسانی پروندهٔ پرسنلی #17	\N	high	2026-08-18	4402446b-0333-4bf9-bece-0d98b3462256	2026-07-21 12:23:05.653402+00	2026-07-21 12:23:05.653402+00	in_progress	\N	69	12.10	2026-07-30	medium
9e026bc3-66b8-45d7-9c60-0989a6664192	97ebd5ca-a1b0-474f-8195-6ee131268149	\N	fe6b733f-8cf4-4df1-a83e-2e854a480178	be682dce-6665-4ff0-8e8a-067602882309	بررسی رزومه‌های متقاضیان شغلی #18	\N	medium	2026-07-06	0b087d01-6c60-46b4-b185-e1c00f52b379	2026-07-21 12:23:05.653402+00	2026-07-21 12:23:05.653402+00	in_progress	\N	73	22.90	2026-07-01	medium
9e026bc3-66b8-45d7-9c60-0989a6664192	5bf8928f-5573-49a0-9ee7-59b30d16f60c	\N	2310cdf5-d549-4a28-bc04-2052038876fc	be682dce-6665-4ff0-8e8a-067602882309	بررسی رزومه‌های متقاضیان شغلی #19	\N	medium	2026-07-02	638541fe-5932-4cd1-82bc-b29d43e868d6	2026-07-21 12:23:05.653402+00	2026-07-21 12:23:05.653402+00	todo	\N	11	13.20	2026-06-19	medium
9e026bc3-66b8-45d7-9c60-0989a6664192	5bf8928f-5573-49a0-9ee7-59b30d16f60c	\N	3cdfd222-0ea4-4a30-b15b-036d1d733193	be682dce-6665-4ff0-8e8a-067602882309	بررسی رزومه‌های متقاضیان شغلی #20	\N	low	2026-07-03	86f0ac5e-c5de-4d44-8d92-250bdda21fdc	2026-07-21 12:23:05.653402+00	2026-07-21 12:23:05.653402+00	completed	pending	100	8.50	2026-06-28	medium
9e026bc3-66b8-45d7-9c60-0989a6664192	5bf8928f-5573-49a0-9ee7-59b30d16f60c	\N	fe6b733f-8cf4-4df1-a83e-2e854a480178	be682dce-6665-4ff0-8e8a-067602882309	به‌روزرسانی آیین‌نامهٔ داخلی شرکت #21	\N	medium	2026-07-21	6768c0f0-2827-47e4-94be-0924960c8631	2026-07-21 12:23:05.653402+00	2026-07-21 12:23:05.653402+00	todo	\N	60	20.60	2026-07-16	medium
9e026bc3-66b8-45d7-9c60-0989a6664192	5bf8928f-5573-49a0-9ee7-59b30d16f60c	\N	3cdfd222-0ea4-4a30-b15b-036d1d733193	be682dce-6665-4ff0-8e8a-067602882309	تهیهٔ فرم ارزیابی سه‌ماهه #22	\N	low	2026-07-10	45e1e171-e49a-4f18-b7d1-c6c1b5012c11	2026-07-21 12:23:05.653402+00	2026-07-21 12:23:05.653402+00	in_progress	\N	47	35.60	2026-06-21	medium
9e026bc3-66b8-45d7-9c60-0989a6664192	5bf8928f-5573-49a0-9ee7-59b30d16f60c	\N	fe6b733f-8cf4-4df1-a83e-2e854a480178	be682dce-6665-4ff0-8e8a-067602882309	به‌روزرسانی آیین‌نامهٔ داخلی شرکت #23	\N	medium	2026-07-17	3b890133-e2e0-4214-8e55-5e6ac8fb8911	2026-07-21 12:23:05.653402+00	2026-07-21 12:23:05.653402+00	todo	\N	59	12.00	2026-07-14	medium
9e026bc3-66b8-45d7-9c60-0989a6664192	5bf8928f-5573-49a0-9ee7-59b30d16f60c	\N	1f7a4d5f-3f0b-4a87-92e9-cf7057b674f5	be682dce-6665-4ff0-8e8a-067602882309	تهیهٔ گزارش ارزیابی عملکرد #24	\N	high	2026-07-25	1fc13c47-7465-47b0-9734-db741cadd6d3	2026-07-21 12:23:05.653402+00	2026-07-21 12:23:05.653402+00	in_progress	\N	12	5.30	2026-07-22	medium
9e026bc3-66b8-45d7-9c60-0989a6664192	5bf8928f-5573-49a0-9ee7-59b30d16f60c	\N	fe6b733f-8cf4-4df1-a83e-2e854a480178	be682dce-6665-4ff0-8e8a-067602882309	برگزاری جلسهٔ آموزش کارکنان جدید #25	\N	high	2026-08-23	40fbaefe-5c92-440b-b64b-44c208e07101	2026-07-21 12:23:05.653402+00	2026-07-21 12:23:05.653402+00	completed	approved	100	4.30	2026-08-03	medium
9e026bc3-66b8-45d7-9c60-0989a6664192	5bf8928f-5573-49a0-9ee7-59b30d16f60c	\N	2310cdf5-d549-4a28-bc04-2052038876fc	be682dce-6665-4ff0-8e8a-067602882309	تدوین برنامهٔ آموزشی سال آینده #26	\N	low	2026-08-06	055f4d59-9262-4e96-b469-c4abfd6803f3	2026-07-21 12:23:05.653402+00	2026-07-21 12:23:05.653402+00	completed	approved	100	20.10	2026-07-20	medium
9e026bc3-66b8-45d7-9c60-0989a6664192	5bf8928f-5573-49a0-9ee7-59b30d16f60c	\N	be682dce-6665-4ff0-8e8a-067602882309	be682dce-6665-4ff0-8e8a-067602882309	بررسی و تمدید قراردادهای پرسنلی #27	\N	high	2026-08-15	3a90a886-f73f-4281-91b6-56e9b0350fda	2026-07-21 12:23:05.653402+00	2026-07-21 12:23:05.653402+00	in_progress	\N	66	32.40	2026-08-12	medium
9e026bc3-66b8-45d7-9c60-0989a6664192	5bf8928f-5573-49a0-9ee7-59b30d16f60c	\N	3cdfd222-0ea4-4a30-b15b-036d1d733193	be682dce-6665-4ff0-8e8a-067602882309	تهیهٔ گزارش ارزیابی عملکرد #28	\N	low	2026-08-31	79f68967-c5d4-4983-a5c5-5acb172d0b1a	2026-07-21 12:23:05.653402+00	2026-07-21 12:23:05.653402+00	completed	approved	100	38.90	2026-08-15	medium
9e026bc3-66b8-45d7-9c60-0989a6664192	5bf8928f-5573-49a0-9ee7-59b30d16f60c	\N	1f7a4d5f-3f0b-4a87-92e9-cf7057b674f5	be682dce-6665-4ff0-8e8a-067602882309	تهیهٔ فرم ارزیابی سه‌ماهه #29	\N	low	2026-06-27	f33da112-5aa6-4294-84e3-f4e0a297d618	2026-07-21 12:23:05.653402+00	2026-07-21 12:23:05.653402+00	todo	\N	55	9.70	2026-06-24	medium
9e026bc3-66b8-45d7-9c60-0989a6664192	5bf8928f-5573-49a0-9ee7-59b30d16f60c	\N	1f7a4d5f-3f0b-4a87-92e9-cf7057b674f5	be682dce-6665-4ff0-8e8a-067602882309	پیگیری درخواست‌های رفاهی کارکنان #30	\N	high	2026-08-03	00e7bb3f-b02f-4548-bd86-092fbb3ecc83	2026-07-21 12:23:05.653402+00	2026-07-21 12:23:05.653402+00	completed	approved	100	36.70	2026-07-24	medium
9e026bc3-66b8-45d7-9c60-0989a6664192	5bf8928f-5573-49a0-9ee7-59b30d16f60c	\N	be682dce-6665-4ff0-8e8a-067602882309	be682dce-6665-4ff0-8e8a-067602882309	تهیهٔ فرم ارزیابی سه‌ماهه #31	\N	high	2026-07-29	23564621-0ca2-46ee-9efb-59c0b562a46b	2026-07-21 12:23:05.653402+00	2026-07-21 12:23:05.653402+00	todo	\N	41	34.60	2026-07-10	medium
9e026bc3-66b8-45d7-9c60-0989a6664192	5bf8928f-5573-49a0-9ee7-59b30d16f60c	\N	220f13de-14e7-4c15-a3c3-d456ccb8f206	be682dce-6665-4ff0-8e8a-067602882309	تدوین برنامهٔ آموزشی سال آینده #32	\N	high	2026-07-07	c0344d19-4dea-4562-b960-0614db284f60	2026-07-21 12:23:05.653402+00	2026-07-21 12:23:05.653402+00	completed	rejected	100	31.70	2026-06-16	medium
9e026bc3-66b8-45d7-9c60-0989a6664192	5bf8928f-5573-49a0-9ee7-59b30d16f60c	\N	be682dce-6665-4ff0-8e8a-067602882309	be682dce-6665-4ff0-8e8a-067602882309	تدوین برنامهٔ آموزشی سال آینده #33	\N	high	2026-07-01	c40801cc-305d-4c6b-850f-99d3acf65a18	2026-07-21 12:23:05.653402+00	2026-07-21 12:23:05.653402+00	in_progress	\N	74	30.80	2026-06-25	medium
9e026bc3-66b8-45d7-9c60-0989a6664192	5bf8928f-5573-49a0-9ee7-59b30d16f60c	\N	be682dce-6665-4ff0-8e8a-067602882309	be682dce-6665-4ff0-8e8a-067602882309	برگزاری نظرسنجی رضایت شغلی #34	\N	medium	2026-07-27	64485083-0488-48a0-a553-82d41dcaae08	2026-07-21 12:23:05.653402+00	2026-07-21 12:23:05.653402+00	todo	\N	68	35.40	2026-07-22	medium
9e026bc3-66b8-45d7-9c60-0989a6664192	5bf8928f-5573-49a0-9ee7-59b30d16f60c	\N	2310cdf5-d549-4a28-bc04-2052038876fc	be682dce-6665-4ff0-8e8a-067602882309	تدوین برنامهٔ آموزشی سال آینده #35	\N	high	2026-07-27	766e9f1b-a9e0-4fef-99e6-22a3be5ec330	2026-07-21 12:23:05.653402+00	2026-07-21 12:23:05.653402+00	in_progress	\N	60	3.40	2026-07-10	medium
9e026bc3-66b8-45d7-9c60-0989a6664192	5bf8928f-5573-49a0-9ee7-59b30d16f60c	\N	fe6b733f-8cf4-4df1-a83e-2e854a480178	be682dce-6665-4ff0-8e8a-067602882309	تدوین برنامهٔ آموزشی سال آینده #36	\N	high	2026-07-16	51d26d5b-f7e2-4ed5-bae5-ac1c2ec7f58d	2026-07-21 12:23:05.653402+00	2026-07-21 12:23:05.653402+00	in_progress	\N	51	3.50	2026-06-25	medium
9e026bc3-66b8-45d7-9c60-0989a6664192	3e1c6a65-ca90-48f7-ad09-df284b6601d0	\N	fe6b733f-8cf4-4df1-a83e-2e854a480178	be682dce-6665-4ff0-8e8a-067602882309	بررسی درخواست ترفیع کارکنان #37	\N	medium	2026-08-19	106dacc7-99df-41b9-958a-b00d16fbf069	2026-07-21 12:23:05.653402+00	2026-07-21 12:23:05.653402+00	completed	approved	100	36.10	2026-08-02	medium
9e026bc3-66b8-45d7-9c60-0989a6664192	3e1c6a65-ca90-48f7-ad09-df284b6601d0	\N	be682dce-6665-4ff0-8e8a-067602882309	be682dce-6665-4ff0-8e8a-067602882309	به‌روزرسانی آیین‌نامهٔ داخلی شرکت #38	\N	medium	2026-08-18	01c2ce79-aafb-4095-a965-b2a930ad556d	2026-07-21 12:23:05.653402+00	2026-07-21 12:23:05.653402+00	in_progress	\N	62	34.60	2026-08-07	medium
9e026bc3-66b8-45d7-9c60-0989a6664192	3e1c6a65-ca90-48f7-ad09-df284b6601d0	\N	3cdfd222-0ea4-4a30-b15b-036d1d733193	be682dce-6665-4ff0-8e8a-067602882309	تهیهٔ گزارش ارزیابی عملکرد #39	\N	medium	2026-08-19	cfffe5b2-774c-491d-9d17-ff09cd01c11e	2026-07-21 12:23:05.653402+00	2026-07-21 12:23:05.653402+00	todo	\N	56	31.40	2026-08-10	medium
9e026bc3-66b8-45d7-9c60-0989a6664192	3e1c6a65-ca90-48f7-ad09-df284b6601d0	\N	fe6b733f-8cf4-4df1-a83e-2e854a480178	be682dce-6665-4ff0-8e8a-067602882309	تدوین برنامهٔ آموزشی سال آینده #40	\N	high	2026-08-16	ab6c418d-3397-4b08-8457-9ff0a0a6d2fc	2026-07-21 12:23:05.653402+00	2026-07-21 12:23:05.653402+00	in_progress	\N	11	9.10	2026-08-01	medium
9e026bc3-66b8-45d7-9c60-0989a6664192	3e1c6a65-ca90-48f7-ad09-df284b6601d0	\N	37e62239-b7c6-493c-9475-fe700a479e79	be682dce-6665-4ff0-8e8a-067602882309	برگزاری نظرسنجی رضایت شغلی #41	\N	high	2026-08-19	cc45f175-3b4a-48ea-b745-7913bf02e906	2026-07-21 12:23:05.653402+00	2026-07-21 12:23:05.653402+00	in_progress	\N	47	33.20	2026-08-02	medium
9e026bc3-66b8-45d7-9c60-0989a6664192	3e1c6a65-ca90-48f7-ad09-df284b6601d0	\N	220f13de-14e7-4c15-a3c3-d456ccb8f206	be682dce-6665-4ff0-8e8a-067602882309	به‌روزرسانی پروندهٔ پرسنلی #42	\N	high	2026-07-01	192cb2b0-40f0-4f0a-9b94-547aeb9345b0	2026-07-21 12:23:05.653402+00	2026-07-21 12:23:05.653402+00	todo	\N	51	7.20	2026-06-20	medium
9e026bc3-66b8-45d7-9c60-0989a6664192	3e1c6a65-ca90-48f7-ad09-df284b6601d0	\N	1f7a4d5f-3f0b-4a87-92e9-cf7057b674f5	be682dce-6665-4ff0-8e8a-067602882309	برگزاری جلسهٔ آموزش کارکنان جدید #43	\N	low	2026-06-24	9a261b60-250e-449e-abaa-36d071f302e2	2026-07-21 12:23:05.653402+00	2026-07-21 12:23:05.653402+00	completed	pending	100	33.80	2026-06-17	medium
9e026bc3-66b8-45d7-9c60-0989a6664192	3e1c6a65-ca90-48f7-ad09-df284b6601d0	\N	37e62239-b7c6-493c-9475-fe700a479e79	be682dce-6665-4ff0-8e8a-067602882309	بررسی درخواست ترفیع کارکنان #44	\N	medium	2026-07-18	22312b2c-25a4-40a9-8746-0b44ab73e5e2	2026-07-21 12:23:05.653402+00	2026-07-21 12:23:05.653402+00	todo	\N	25	12.40	2026-07-15	medium
9e026bc3-66b8-45d7-9c60-0989a6664192	3e1c6a65-ca90-48f7-ad09-df284b6601d0	\N	1f7a4d5f-3f0b-4a87-92e9-cf7057b674f5	be682dce-6665-4ff0-8e8a-067602882309	پیگیری مرخصی و مأموریت کارکنان #45	\N	low	2026-07-31	8e6da4cf-9a57-4805-a5ae-90cd78c5d1a1	2026-07-21 12:23:05.653402+00	2026-07-21 12:23:05.653402+00	completed	approved	100	11.20	2026-07-26	medium
9e026bc3-66b8-45d7-9c60-0989a6664192	3e1c6a65-ca90-48f7-ad09-df284b6601d0	\N	2310cdf5-d549-4a28-bc04-2052038876fc	be682dce-6665-4ff0-8e8a-067602882309	تدوین برنامهٔ آموزشی سال آینده #46	\N	high	2026-08-27	4dd876d9-dbde-411f-95b9-038d7fecdd1f	2026-07-21 12:23:05.653402+00	2026-07-21 12:23:05.653402+00	completed	approved	100	15.30	2026-08-10	medium
9e026bc3-66b8-45d7-9c60-0989a6664192	3e1c6a65-ca90-48f7-ad09-df284b6601d0	\N	37e62239-b7c6-493c-9475-fe700a479e79	be682dce-6665-4ff0-8e8a-067602882309	به‌روزرسانی آیین‌نامهٔ داخلی شرکت #47	\N	low	2026-08-06	2940fa8f-f587-4504-9432-8c28e8374e51	2026-07-21 12:23:05.653402+00	2026-07-21 12:23:05.653402+00	in_progress	\N	49	3.90	2026-08-02	medium
9e026bc3-66b8-45d7-9c60-0989a6664192	3e1c6a65-ca90-48f7-ad09-df284b6601d0	\N	1f7a4d5f-3f0b-4a87-92e9-cf7057b674f5	be682dce-6665-4ff0-8e8a-067602882309	پیگیری مرخصی و مأموریت کارکنان #48	\N	low	2026-07-08	42e55e27-3abf-47f9-b5b5-b610b379058b	2026-07-21 12:23:05.653402+00	2026-07-21 12:23:05.653402+00	completed	pending	100	27.80	2026-06-29	medium
9e026bc3-66b8-45d7-9c60-0989a6664192	3e1c6a65-ca90-48f7-ad09-df284b6601d0	\N	fe6b733f-8cf4-4df1-a83e-2e854a480178	be682dce-6665-4ff0-8e8a-067602882309	برنامه‌ریزی رویداد تیم‌سازی #49	\N	low	2026-06-19	65c130f9-b51c-4960-8221-5f9061af16c8	2026-07-21 12:23:05.653402+00	2026-07-21 12:23:05.653402+00	completed	approved	100	26.60	2026-06-17	medium
9e026bc3-66b8-45d7-9c60-0989a6664192	3e1c6a65-ca90-48f7-ad09-df284b6601d0	\N	220f13de-14e7-4c15-a3c3-d456ccb8f206	be682dce-6665-4ff0-8e8a-067602882309	تدوین برنامهٔ آموزشی سال آینده #50	\N	medium	2026-07-10	7537cecd-701f-453d-a1f1-ffd20ea9124f	2026-07-21 12:23:05.653402+00	2026-07-21 12:23:05.653402+00	todo	\N	35	18.10	2026-06-30	medium
9e026bc3-66b8-45d7-9c60-0989a6664192	3e1c6a65-ca90-48f7-ad09-df284b6601d0	\N	2310cdf5-d549-4a28-bc04-2052038876fc	be682dce-6665-4ff0-8e8a-067602882309	برگزاری جلسهٔ آموزش کارکنان جدید #51	\N	medium	2026-07-25	d58bc5d6-c972-4927-85a4-0dff5346d9e7	2026-07-21 12:23:05.653402+00	2026-07-21 12:23:05.653402+00	in_progress	\N	38	27.70	2026-07-15	medium
9e026bc3-66b8-45d7-9c60-0989a6664192	3e1c6a65-ca90-48f7-ad09-df284b6601d0	\N	1f7a4d5f-3f0b-4a87-92e9-cf7057b674f5	be682dce-6665-4ff0-8e8a-067602882309	بررسی و تمدید قراردادهای پرسنلی #52	\N	high	2026-06-24	13db9a7c-bc64-4735-8262-fe6aa2a16ecc	2026-07-21 12:23:05.653402+00	2026-07-21 12:23:05.653402+00	completed	approved	100	38.70	2026-06-22	medium
9e026bc3-66b8-45d7-9c60-0989a6664192	3e1c6a65-ca90-48f7-ad09-df284b6601d0	\N	1f7a4d5f-3f0b-4a87-92e9-cf7057b674f5	be682dce-6665-4ff0-8e8a-067602882309	تدوین برنامهٔ آموزشی سال آینده #53	\N	medium	2026-08-11	b6256525-7416-4a4f-a2fe-8b4add569d11	2026-07-21 12:23:05.653402+00	2026-07-21 12:23:05.653402+00	in_progress	\N	38	28.00	2026-07-21	medium
9e026bc3-66b8-45d7-9c60-0989a6664192	3e1c6a65-ca90-48f7-ad09-df284b6601d0	\N	2310cdf5-d549-4a28-bc04-2052038876fc	be682dce-6665-4ff0-8e8a-067602882309	پیگیری مرخصی و مأموریت کارکنان #54	\N	medium	2026-07-17	2ecb55f9-9a8b-4678-81c5-8ba517caea91	2026-07-21 12:23:05.653402+00	2026-07-21 12:23:05.653402+00	todo	\N	35	11.90	2026-07-07	medium
9e026bc3-66b8-45d7-9c60-0989a6664192	e8969525-8440-4cdc-9110-d6b5e43d877f	\N	3cdfd222-0ea4-4a30-b15b-036d1d733193	be682dce-6665-4ff0-8e8a-067602882309	برگزاری نظرسنجی رضایت شغلی #55	\N	low	2026-07-13	fd5448b8-83f5-43f4-9408-eaae6e883a9b	2026-07-21 12:23:05.653402+00	2026-07-21 12:23:05.653402+00	completed	approved	100	36.20	2026-06-25	medium
9e026bc3-66b8-45d7-9c60-0989a6664192	e8969525-8440-4cdc-9110-d6b5e43d877f	\N	1f7a4d5f-3f0b-4a87-92e9-cf7057b674f5	be682dce-6665-4ff0-8e8a-067602882309	به‌روزرسانی پروندهٔ پرسنلی #56	\N	low	2026-07-12	305e1832-32f6-4e43-aab5-b6c918de689e	2026-07-21 12:23:05.653402+00	2026-07-21 12:23:05.653402+00	completed	approved	100	26.90	2026-07-06	medium
9e026bc3-66b8-45d7-9c60-0989a6664192	e8969525-8440-4cdc-9110-d6b5e43d877f	\N	fe6b733f-8cf4-4df1-a83e-2e854a480178	be682dce-6665-4ff0-8e8a-067602882309	تهیهٔ فرم ارزیابی سه‌ماهه #57	\N	medium	2026-08-28	dbfa8f3e-4ad3-4118-8df3-de493d866f5a	2026-07-21 12:23:05.653402+00	2026-07-21 12:23:05.653402+00	in_progress	\N	4	24.20	2026-08-13	medium
9e026bc3-66b8-45d7-9c60-0989a6664192	e8969525-8440-4cdc-9110-d6b5e43d877f	\N	220f13de-14e7-4c15-a3c3-d456ccb8f206	be682dce-6665-4ff0-8e8a-067602882309	پیگیری مرخصی و مأموریت کارکنان #58	\N	high	2026-07-16	6059a84e-e632-45ee-b0d7-eff90cc5dbdd	2026-07-21 12:23:05.653402+00	2026-07-21 12:23:05.653402+00	todo	\N	60	36.40	2026-07-07	medium
9e026bc3-66b8-45d7-9c60-0989a6664192	e8969525-8440-4cdc-9110-d6b5e43d877f	\N	3cdfd222-0ea4-4a30-b15b-036d1d733193	be682dce-6665-4ff0-8e8a-067602882309	تهیهٔ گزارش غیبت و تأخیر #59	\N	low	2026-07-29	9040cf8a-dede-460a-8a5c-d8346635204c	2026-07-21 12:23:05.653402+00	2026-07-21 12:23:05.653402+00	in_progress	\N	71	8.90	2026-07-18	medium
9e026bc3-66b8-45d7-9c60-0989a6664192	e8969525-8440-4cdc-9110-d6b5e43d877f	\N	be682dce-6665-4ff0-8e8a-067602882309	be682dce-6665-4ff0-8e8a-067602882309	برگزاری نظرسنجی رضایت شغلی #60	\N	low	2026-07-21	204ecc45-bf40-4500-8cc1-1df6b10cdaed	2026-07-21 12:23:05.653402+00	2026-07-21 12:23:05.653402+00	completed	approved	100	38.00	2026-07-02	medium
9e026bc3-66b8-45d7-9c60-0989a6664192	e8969525-8440-4cdc-9110-d6b5e43d877f	\N	fe6b733f-8cf4-4df1-a83e-2e854a480178	be682dce-6665-4ff0-8e8a-067602882309	به‌روزرسانی پروندهٔ پرسنلی #61	\N	medium	2026-07-17	022467d8-0685-4ebd-952a-6baa867212da	2026-07-21 12:23:05.653402+00	2026-07-21 12:23:05.653402+00	completed	approved	100	18.00	2026-07-08	medium
9e026bc3-66b8-45d7-9c60-0989a6664192	e8969525-8440-4cdc-9110-d6b5e43d877f	\N	fe6b733f-8cf4-4df1-a83e-2e854a480178	be682dce-6665-4ff0-8e8a-067602882309	به‌روزرسانی آیین‌نامهٔ داخلی شرکت #62	\N	medium	2026-07-22	0b565a41-5543-49e1-b676-da667b55769a	2026-07-21 12:23:05.653402+00	2026-07-21 12:23:05.653402+00	in_progress	\N	15	19.90	2026-07-02	medium
9e026bc3-66b8-45d7-9c60-0989a6664192	e8969525-8440-4cdc-9110-d6b5e43d877f	\N	1f7a4d5f-3f0b-4a87-92e9-cf7057b674f5	be682dce-6665-4ff0-8e8a-067602882309	برنامه‌ریزی مصاحبهٔ استخدامی #63	\N	medium	2026-09-05	f58ebd25-2170-44da-ae15-bbdd5fac043e	2026-07-21 12:23:05.653402+00	2026-07-21 12:23:05.653402+00	completed	approved	100	35.80	2026-08-15	medium
9e026bc3-66b8-45d7-9c60-0989a6664192	e8969525-8440-4cdc-9110-d6b5e43d877f	\N	220f13de-14e7-4c15-a3c3-d456ccb8f206	be682dce-6665-4ff0-8e8a-067602882309	بررسی و تمدید قراردادهای پرسنلی #64	\N	medium	2026-08-24	9eaa46f6-e7c4-42ff-987c-19055632ee82	2026-07-21 12:23:05.653402+00	2026-07-21 12:23:05.653402+00	todo	\N	52	4.10	2026-08-10	medium
9e026bc3-66b8-45d7-9c60-0989a6664192	e8969525-8440-4cdc-9110-d6b5e43d877f	\N	1f7a4d5f-3f0b-4a87-92e9-cf7057b674f5	be682dce-6665-4ff0-8e8a-067602882309	پیگیری درخواست‌های رفاهی کارکنان #65	\N	medium	2026-07-02	e09cb562-a500-4be0-9d92-3be3834aedb0	2026-07-21 12:23:05.653402+00	2026-07-21 12:23:05.653402+00	todo	\N	72	35.90	2026-06-24	medium
9e026bc3-66b8-45d7-9c60-0989a6664192	e8969525-8440-4cdc-9110-d6b5e43d877f	\N	2310cdf5-d549-4a28-bc04-2052038876fc	be682dce-6665-4ff0-8e8a-067602882309	برگزاری نظرسنجی رضایت شغلی #66	\N	low	2026-07-13	f48507ff-06bb-47b6-9d4d-0ca7f15267dd	2026-07-21 12:23:05.653402+00	2026-07-21 12:23:05.653402+00	todo	\N	62	14.60	2026-07-06	medium
9e026bc3-66b8-45d7-9c60-0989a6664192	e8969525-8440-4cdc-9110-d6b5e43d877f	\N	37e62239-b7c6-493c-9475-fe700a479e79	be682dce-6665-4ff0-8e8a-067602882309	بررسی رزومه‌های متقاضیان شغلی #67	\N	medium	2026-07-29	9a639442-bdc2-4252-b9b4-97bf8e7d0011	2026-07-21 12:23:05.653402+00	2026-07-21 12:23:05.653402+00	in_progress	\N	35	10.00	2026-07-26	medium
9e026bc3-66b8-45d7-9c60-0989a6664192	e8969525-8440-4cdc-9110-d6b5e43d877f	\N	1f7a4d5f-3f0b-4a87-92e9-cf7057b674f5	be682dce-6665-4ff0-8e8a-067602882309	برنامه‌ریزی رویداد تیم‌سازی #68	\N	low	2026-07-29	fcba4c5f-0b83-40fb-a2e7-0f66fa71e9f5	2026-07-21 12:23:05.653402+00	2026-07-21 12:23:05.653402+00	todo	\N	16	25.40	2026-07-22	medium
9e026bc3-66b8-45d7-9c60-0989a6664192	e8969525-8440-4cdc-9110-d6b5e43d877f	\N	3cdfd222-0ea4-4a30-b15b-036d1d733193	be682dce-6665-4ff0-8e8a-067602882309	برنامه‌ریزی رویداد تیم‌سازی #69	\N	medium	2026-07-26	02784266-0f81-4c85-bbd7-ea80c70b5b76	2026-07-21 12:23:05.653402+00	2026-07-21 12:23:05.653402+00	in_progress	\N	0	3.40	2026-07-11	medium
9e026bc3-66b8-45d7-9c60-0989a6664192	e8969525-8440-4cdc-9110-d6b5e43d877f	\N	37e62239-b7c6-493c-9475-fe700a479e79	be682dce-6665-4ff0-8e8a-067602882309	بررسی درخواست ترفیع کارکنان #70	\N	medium	2026-07-11	c68072c2-2d43-4763-8d49-c46bbec3577a	2026-07-21 12:23:05.653402+00	2026-07-21 12:23:05.653402+00	archived	\N	67	9.20	2026-07-09	medium
9e026bc3-66b8-45d7-9c60-0989a6664192	e8969525-8440-4cdc-9110-d6b5e43d877f	\N	3cdfd222-0ea4-4a30-b15b-036d1d733193	be682dce-6665-4ff0-8e8a-067602882309	برگزاری جلسهٔ آموزش کارکنان جدید #71	\N	high	2026-08-04	dd8a5766-ac30-4aaf-85e0-c17a3e0be64b	2026-07-21 12:23:05.653402+00	2026-07-21 12:23:05.653402+00	todo	\N	44	13.90	2026-07-26	medium
9e026bc3-66b8-45d7-9c60-0989a6664192	e8969525-8440-4cdc-9110-d6b5e43d877f	\N	be682dce-6665-4ff0-8e8a-067602882309	be682dce-6665-4ff0-8e8a-067602882309	به‌روزرسانی آیین‌نامهٔ داخلی شرکت #72	\N	low	2026-08-07	7c287773-9c2b-47fc-be28-77097444c921	2026-07-21 12:23:05.653402+00	2026-07-21 12:23:05.653402+00	in_progress	\N	8	33.30	2026-07-18	medium
9e026bc3-66b8-45d7-9c60-0989a6664192	8788d165-ed7c-43bd-97f4-f1190b5dba5a	\N	fe6b733f-8cf4-4df1-a83e-2e854a480178	be682dce-6665-4ff0-8e8a-067602882309	تدوین برنامهٔ آموزشی سال آینده #73	\N	high	2026-08-02	a0c4355b-fd52-423c-b19b-bd339758a79b	2026-07-21 12:23:05.653402+00	2026-07-21 12:23:05.653402+00	in_progress	\N	43	18.50	2026-07-15	medium
9e026bc3-66b8-45d7-9c60-0989a6664192	8788d165-ed7c-43bd-97f4-f1190b5dba5a	\N	3cdfd222-0ea4-4a30-b15b-036d1d733193	be682dce-6665-4ff0-8e8a-067602882309	پیگیری درخواست‌های رفاهی کارکنان #74	\N	low	2026-07-24	07f36bb3-762c-457a-acdc-b93e6f42f819	2026-07-21 12:23:05.653402+00	2026-07-21 12:23:05.653402+00	todo	\N	21	38.00	2026-07-07	medium
9e026bc3-66b8-45d7-9c60-0989a6664192	8788d165-ed7c-43bd-97f4-f1190b5dba5a	\N	1f7a4d5f-3f0b-4a87-92e9-cf7057b674f5	be682dce-6665-4ff0-8e8a-067602882309	برگزاری جلسهٔ آموزش کارکنان جدید #75	\N	high	2026-06-26	18bf57d8-c791-4c28-9d45-39459d513c7d	2026-07-21 12:23:05.653402+00	2026-07-21 12:23:05.653402+00	in_progress	\N	16	10.00	2026-06-17	medium
9e026bc3-66b8-45d7-9c60-0989a6664192	8788d165-ed7c-43bd-97f4-f1190b5dba5a	\N	be682dce-6665-4ff0-8e8a-067602882309	be682dce-6665-4ff0-8e8a-067602882309	به‌روزرسانی پروندهٔ پرسنلی #76	\N	high	2026-07-06	bcdd076d-8fd9-470a-90b7-a78fa59ded8e	2026-07-21 12:23:05.653402+00	2026-07-21 12:23:05.653402+00	completed	approved	100	32.10	2026-06-23	medium
9e026bc3-66b8-45d7-9c60-0989a6664192	8788d165-ed7c-43bd-97f4-f1190b5dba5a	\N	2310cdf5-d549-4a28-bc04-2052038876fc	be682dce-6665-4ff0-8e8a-067602882309	بررسی رزومه‌های متقاضیان شغلی #77	\N	high	2026-08-10	ad728572-6512-4248-806f-5589a8319f4e	2026-07-21 12:23:05.653402+00	2026-07-21 12:23:05.653402+00	completed	approved	100	39.80	2026-07-20	medium
9e026bc3-66b8-45d7-9c60-0989a6664192	8788d165-ed7c-43bd-97f4-f1190b5dba5a	\N	3cdfd222-0ea4-4a30-b15b-036d1d733193	be682dce-6665-4ff0-8e8a-067602882309	بررسی رزومه‌های متقاضیان شغلی #78	\N	high	2026-07-29	c3a24255-91e8-441c-b441-d5a428385aac	2026-07-21 12:23:05.653402+00	2026-07-21 12:23:05.653402+00	todo	\N	14	17.80	2026-07-27	medium
9e026bc3-66b8-45d7-9c60-0989a6664192	8788d165-ed7c-43bd-97f4-f1190b5dba5a	\N	2310cdf5-d549-4a28-bc04-2052038876fc	be682dce-6665-4ff0-8e8a-067602882309	برنامه‌ریزی رویداد تیم‌سازی #79	\N	high	2026-07-31	062dc73d-73e4-4e46-96cb-4808d5295752	2026-07-21 12:23:05.653402+00	2026-07-21 12:23:05.653402+00	todo	\N	19	9.80	2026-07-21	medium
9e026bc3-66b8-45d7-9c60-0989a6664192	8788d165-ed7c-43bd-97f4-f1190b5dba5a	\N	3cdfd222-0ea4-4a30-b15b-036d1d733193	be682dce-6665-4ff0-8e8a-067602882309	پیگیری مرخصی و مأموریت کارکنان #80	\N	high	2026-07-17	f116539f-0e27-46dc-9056-69d0fa44f0dc	2026-07-21 12:23:05.653402+00	2026-07-21 12:23:05.653402+00	completed	approved	100	12.30	2026-07-12	medium
9e026bc3-66b8-45d7-9c60-0989a6664192	8788d165-ed7c-43bd-97f4-f1190b5dba5a	\N	220f13de-14e7-4c15-a3c3-d456ccb8f206	be682dce-6665-4ff0-8e8a-067602882309	بررسی و تمدید قراردادهای پرسنلی #81	\N	high	2026-08-13	024d4d9e-430e-4265-ae75-839f812150c6	2026-07-21 12:23:05.653402+00	2026-07-21 12:23:05.653402+00	completed	approved	100	25.50	2026-08-08	medium
9e026bc3-66b8-45d7-9c60-0989a6664192	8788d165-ed7c-43bd-97f4-f1190b5dba5a	\N	fe6b733f-8cf4-4df1-a83e-2e854a480178	be682dce-6665-4ff0-8e8a-067602882309	برنامه‌ریزی رویداد تیم‌سازی #82	\N	low	2026-08-10	3f186f5c-f4de-413f-8f21-be9fd449d86b	2026-07-21 12:23:05.653402+00	2026-07-21 12:23:05.653402+00	todo	\N	77	9.60	2026-08-05	medium
9e026bc3-66b8-45d7-9c60-0989a6664192	8788d165-ed7c-43bd-97f4-f1190b5dba5a	\N	fe6b733f-8cf4-4df1-a83e-2e854a480178	be682dce-6665-4ff0-8e8a-067602882309	به‌روزرسانی آیین‌نامهٔ داخلی شرکت #83	\N	low	2026-07-23	55bbe9f3-a98e-448d-9b43-2e32179d888b	2026-07-21 12:23:05.653402+00	2026-07-21 12:23:05.653402+00	completed	rejected	100	3.50	2026-07-08	medium
9e026bc3-66b8-45d7-9c60-0989a6664192	8788d165-ed7c-43bd-97f4-f1190b5dba5a	\N	2310cdf5-d549-4a28-bc04-2052038876fc	be682dce-6665-4ff0-8e8a-067602882309	پیگیری درخواست‌های رفاهی کارکنان #84	\N	low	2026-08-16	16f0cec1-d074-4148-a4da-9f0d1f8da7ae	2026-07-21 12:23:05.653402+00	2026-07-21 12:23:05.653402+00	in_progress	\N	0	2.50	2026-07-30	medium
9e026bc3-66b8-45d7-9c60-0989a6664192	8788d165-ed7c-43bd-97f4-f1190b5dba5a	\N	be682dce-6665-4ff0-8e8a-067602882309	be682dce-6665-4ff0-8e8a-067602882309	پیگیری مرخصی و مأموریت کارکنان #85	\N	medium	2026-08-28	b813d5f7-47fa-4ced-b838-5f708d1a0120	2026-07-21 12:23:05.653402+00	2026-07-21 12:23:05.653402+00	todo	\N	19	38.10	2026-08-08	medium
9e026bc3-66b8-45d7-9c60-0989a6664192	8788d165-ed7c-43bd-97f4-f1190b5dba5a	\N	1f7a4d5f-3f0b-4a87-92e9-cf7057b674f5	be682dce-6665-4ff0-8e8a-067602882309	بررسی درخواست ترفیع کارکنان #86	\N	medium	2026-08-06	8d23a657-fce8-4c59-a6f0-321253215ea6	2026-07-21 12:23:05.653402+00	2026-07-21 12:23:05.653402+00	completed	approved	100	26.50	2026-08-01	medium
9e026bc3-66b8-45d7-9c60-0989a6664192	8788d165-ed7c-43bd-97f4-f1190b5dba5a	\N	2310cdf5-d549-4a28-bc04-2052038876fc	be682dce-6665-4ff0-8e8a-067602882309	بررسی رزومه‌های متقاضیان شغلی #87	\N	low	2026-07-18	7615aae6-409d-4877-a5a7-722bb0e4e4cb	2026-07-21 12:23:05.653402+00	2026-07-21 12:23:05.653402+00	in_progress	\N	22	35.20	2026-07-02	medium
9e026bc3-66b8-45d7-9c60-0989a6664192	8788d165-ed7c-43bd-97f4-f1190b5dba5a	\N	1f7a4d5f-3f0b-4a87-92e9-cf7057b674f5	be682dce-6665-4ff0-8e8a-067602882309	تهیهٔ فرم ارزیابی سه‌ماهه #88	\N	high	2026-07-21	11647cb9-3508-49f9-bfa5-2495ec0192c8	2026-07-21 12:23:05.653402+00	2026-07-21 12:23:05.653402+00	in_progress	\N	14	5.60	2026-07-09	medium
9e026bc3-66b8-45d7-9c60-0989a6664192	8788d165-ed7c-43bd-97f4-f1190b5dba5a	\N	1f7a4d5f-3f0b-4a87-92e9-cf7057b674f5	be682dce-6665-4ff0-8e8a-067602882309	پیگیری مرخصی و مأموریت کارکنان #89	\N	high	2026-06-22	90e1365d-6548-4bcb-bd04-baf74584d9f8	2026-07-21 12:23:05.653402+00	2026-07-21 12:23:05.653402+00	todo	\N	21	14.50	2026-06-16	medium
9e026bc3-66b8-45d7-9c60-0989a6664192	8788d165-ed7c-43bd-97f4-f1190b5dba5a	\N	2310cdf5-d549-4a28-bc04-2052038876fc	be682dce-6665-4ff0-8e8a-067602882309	پیگیری درخواست‌های رفاهی کارکنان #90	\N	medium	2026-08-05	42177bd4-9572-4f74-8fac-b03f732269d6	2026-07-21 12:23:05.653402+00	2026-07-21 12:23:05.653402+00	completed	approved	100	8.90	2026-08-01	medium
9e026bc3-66b8-45d7-9c60-0989a6664192	\N	\N	2310cdf5-d549-4a28-bc04-2052038876fc	2310cdf5-d549-4a28-bc04-2052038876fc	تهیهٔ گزارش غیبت و تأخیر #91	\N	medium	2026-07-25	1f220c67-b6eb-4b38-8539-7998b55fcb42	2026-07-21 12:23:05.653402+00	2026-07-21 12:23:05.653402+00	in_progress	\N	61	32.40	2026-07-15	medium
9e026bc3-66b8-45d7-9c60-0989a6664192	\N	\N	3cdfd222-0ea4-4a30-b15b-036d1d733193	3cdfd222-0ea4-4a30-b15b-036d1d733193	به‌روزرسانی پروندهٔ پرسنلی #92	\N	high	2026-06-29	08defca8-3913-489d-93e9-6a0241a84eb0	2026-07-21 12:23:05.653402+00	2026-07-21 12:23:05.653402+00	todo	\N	7	39.30	2026-06-23	medium
9e026bc3-66b8-45d7-9c60-0989a6664192	\N	\N	1f7a4d5f-3f0b-4a87-92e9-cf7057b674f5	1f7a4d5f-3f0b-4a87-92e9-cf7057b674f5	بررسی درخواست ترفیع کارکنان #93	\N	high	2026-07-07	4d1ccaa2-a377-43a5-aa3a-416aab14b9ad	2026-07-21 12:23:05.653402+00	2026-07-21 12:23:05.653402+00	todo	\N	61	32.50	2026-06-22	medium
9e026bc3-66b8-45d7-9c60-0989a6664192	\N	\N	3cdfd222-0ea4-4a30-b15b-036d1d733193	3cdfd222-0ea4-4a30-b15b-036d1d733193	تدوین برنامهٔ آموزشی سال آینده #94	\N	low	2026-07-23	be088583-a3c1-4b5a-ae96-5168463d5da9	2026-07-21 12:23:05.653402+00	2026-07-21 12:23:05.653402+00	completed	approved	100	34.80	2026-07-10	medium
9e026bc3-66b8-45d7-9c60-0989a6664192	\N	\N	1f7a4d5f-3f0b-4a87-92e9-cf7057b674f5	1f7a4d5f-3f0b-4a87-92e9-cf7057b674f5	برنامه‌ریزی رویداد تیم‌سازی #95	\N	medium	2026-08-18	fd0b3fce-b645-4d0d-914f-4a5b85fdd270	2026-07-21 12:23:05.653402+00	2026-07-21 12:23:05.653402+00	archived	\N	14	35.70	2026-08-12	medium
9e026bc3-66b8-45d7-9c60-0989a6664192	\N	\N	2310cdf5-d549-4a28-bc04-2052038876fc	2310cdf5-d549-4a28-bc04-2052038876fc	پیگیری مرخصی و مأموریت کارکنان #96	\N	medium	2026-06-30	23dfadbb-e398-407f-85fa-ebc522091740	2026-07-21 12:23:05.653402+00	2026-07-21 12:23:05.653402+00	todo	\N	1	28.80	2026-06-20	medium
9e026bc3-66b8-45d7-9c60-0989a6664192	\N	\N	3cdfd222-0ea4-4a30-b15b-036d1d733193	3cdfd222-0ea4-4a30-b15b-036d1d733193	برگزاری جلسهٔ آموزش کارکنان جدید #97	\N	high	2026-08-11	cb1fe65d-ac3d-4bba-97e9-a12f61183168	2026-07-21 12:23:05.653402+00	2026-07-21 12:23:05.653402+00	completed	pending	100	35.20	2026-07-22	medium
9e026bc3-66b8-45d7-9c60-0989a6664192	\N	\N	220f13de-14e7-4c15-a3c3-d456ccb8f206	220f13de-14e7-4c15-a3c3-d456ccb8f206	تهیهٔ فرم ارزیابی سه‌ماهه #98	\N	high	2026-07-30	af2b41ab-b779-4dcf-b555-1b1786194355	2026-07-21 12:23:05.653402+00	2026-07-21 12:23:05.653402+00	completed	pending	100	29.60	2026-07-25	medium
9e026bc3-66b8-45d7-9c60-0989a6664192	\N	\N	2310cdf5-d549-4a28-bc04-2052038876fc	2310cdf5-d549-4a28-bc04-2052038876fc	تهیهٔ گزارش ارزیابی عملکرد #99	\N	high	2026-08-11	109803ba-a3bb-482b-afd4-57f854298016	2026-07-21 12:23:05.653402+00	2026-07-21 12:23:05.653402+00	in_progress	\N	78	4.10	2026-07-28	medium
9e026bc3-66b8-45d7-9c60-0989a6664192	\N	\N	3cdfd222-0ea4-4a30-b15b-036d1d733193	3cdfd222-0ea4-4a30-b15b-036d1d733193	تهیهٔ گزارش غیبت و تأخیر #100	\N	medium	2026-08-04	666b24de-47e9-4135-8144-addd04d8cb39	2026-07-21 12:23:05.653402+00	2026-07-21 12:23:05.653402+00	todo	\N	21	4.80	2026-07-18	medium
9e026bc3-66b8-45d7-9c60-0989a6664192	\N	\N	2310cdf5-d549-4a28-bc04-2052038876fc	2310cdf5-d549-4a28-bc04-2052038876fc	به‌روزرسانی آیین‌نامهٔ داخلی شرکت #101	\N	low	2026-07-13	eb8250e8-9347-49da-aeee-518716b53a98	2026-07-21 12:23:05.653402+00	2026-07-21 12:23:05.653402+00	in_progress	\N	64	10.50	2026-07-01	medium
9e026bc3-66b8-45d7-9c60-0989a6664192	\N	\N	3cdfd222-0ea4-4a30-b15b-036d1d733193	3cdfd222-0ea4-4a30-b15b-036d1d733193	برنامه‌ریزی مصاحبهٔ استخدامی #102	\N	medium	2026-07-20	9778855a-b436-4ab7-ab4d-957c01fcc966	2026-07-21 12:23:05.653402+00	2026-07-21 12:23:05.653402+00	in_progress	\N	56	32.40	2026-07-11	medium
9e026bc3-66b8-45d7-9c60-0989a6664192	\N	\N	2310cdf5-d549-4a28-bc04-2052038876fc	2310cdf5-d549-4a28-bc04-2052038876fc	برنامه‌ریزی رویداد تیم‌سازی #103	\N	medium	2026-08-26	35bc28cf-2293-4eaf-9768-0005848a081c	2026-07-21 12:23:05.653402+00	2026-07-21 12:23:05.653402+00	todo	\N	15	39.30	2026-08-09	medium
9e026bc3-66b8-45d7-9c60-0989a6664192	\N	\N	3cdfd222-0ea4-4a30-b15b-036d1d733193	3cdfd222-0ea4-4a30-b15b-036d1d733193	بررسی رزومه‌های متقاضیان شغلی #104	\N	high	2026-07-26	1912c97e-1d15-4c25-9809-6302c5c59de6	2026-07-21 12:23:05.653402+00	2026-07-21 12:23:05.653402+00	completed	approved	100	22.90	2026-07-11	medium
9e026bc3-66b8-45d7-9c60-0989a6664192	\N	\N	1f7a4d5f-3f0b-4a87-92e9-cf7057b674f5	1f7a4d5f-3f0b-4a87-92e9-cf7057b674f5	تدوین برنامهٔ آموزشی سال آینده #105	\N	high	2026-08-26	a1516c6e-1f10-49a3-a90d-52eaba76008f	2026-07-21 12:23:05.653402+00	2026-07-21 12:23:05.653402+00	todo	\N	38	35.80	2026-08-05	medium
\.


--
-- Data for Name: users; Type: TABLE DATA; Schema: public; Owner: -
--

COPY public.users (organization_id, full_name, role, is_active, id, created_at, updated_at, department_id, account_id) FROM stdin;
9e026bc3-66b8-45d7-9c60-0989a6664192	مدیر سازمان	org_admin	t	817e2843-948e-4775-a2b7-3ded2f04feca	2026-07-21 12:23:05.653402+00	2026-07-21 12:23:05.653402+00	6e484715-c164-4c7b-b7a9-0a5b47a188a1	d817d362-a16b-49b6-a6a9-aaed37092f70
9e026bc3-66b8-45d7-9c60-0989a6664192	مدیر پروژه مهندسی و فنی	project_manager	t	75bbbdd2-5d00-4257-8e1e-c3881eebcf0e	2026-07-21 12:23:05.653402+00	2026-07-21 12:23:05.653402+00	6e484715-c164-4c7b-b7a9-0a5b47a188a1	ca463a2b-7f44-4111-a638-e8bc34a2eb8d
9e026bc3-66b8-45d7-9c60-0989a6664192	کارمند 1 مهندسی و فنی	employee	t	24e34af4-1229-4d93-8615-b8479b51a37c	2026-07-21 12:23:05.653402+00	2026-07-21 12:23:05.653402+00	6e484715-c164-4c7b-b7a9-0a5b47a188a1	21520e01-4d42-4611-bca5-8b07e86755c2
9e026bc3-66b8-45d7-9c60-0989a6664192	کارمند 2 مهندسی و فنی	employee	t	dbe12768-1ffa-4f9b-8327-4558c4438ef6	2026-07-21 12:23:05.653402+00	2026-07-21 12:23:05.653402+00	6e484715-c164-4c7b-b7a9-0a5b47a188a1	ae52c012-e5ba-4f00-95d1-a941186744bd
9e026bc3-66b8-45d7-9c60-0989a6664192	کارمند 3 مهندسی و فنی	employee	t	7e07497e-be59-442a-82ad-943e3bd502bb	2026-07-21 12:23:05.653402+00	2026-07-21 12:23:05.653402+00	6e484715-c164-4c7b-b7a9-0a5b47a188a1	8504ffd8-76b2-46c3-88b9-33994fad6f6f
9e026bc3-66b8-45d7-9c60-0989a6664192	کارمند 4 مهندسی و فنی	employee	t	6b87e773-3d93-47db-8dc6-37ca0e6e9b32	2026-07-21 12:23:05.653402+00	2026-07-21 12:23:05.653402+00	6e484715-c164-4c7b-b7a9-0a5b47a188a1	8a20a6ca-77f1-4e63-954c-a9a165283bef
9e026bc3-66b8-45d7-9c60-0989a6664192	کارمند 5 مهندسی و فنی	employee	t	ad47309d-1c75-4d68-b779-348021512719	2026-07-21 12:23:05.653402+00	2026-07-21 12:23:05.653402+00	6e484715-c164-4c7b-b7a9-0a5b47a188a1	3c56b23e-3994-4315-9abe-d4a0bdb8b096
9e026bc3-66b8-45d7-9c60-0989a6664192	کارمند 6 مهندسی و فنی	employee	t	8c7cac5d-349c-4d45-ab78-f4e52554d784	2026-07-21 12:23:05.653402+00	2026-07-21 12:23:05.653402+00	6e484715-c164-4c7b-b7a9-0a5b47a188a1	5afcb24c-133b-46b6-8615-d69e266bc233
9e026bc3-66b8-45d7-9c60-0989a6664192	مدیر پروژه حسابداری و مالی	project_manager	t	0aa7f564-65bd-473d-aa0e-3abc4663b507	2026-07-21 12:23:05.653402+00	2026-07-21 12:23:05.653402+00	167ce15f-9954-4a63-a93b-54f6d1c3b955	556bb4d3-9c73-45e8-b8d2-77afd7184b7a
9e026bc3-66b8-45d7-9c60-0989a6664192	کارمند 1 حسابداری و مالی	employee	t	6115c41b-8c19-4fa9-b656-df967e8a945e	2026-07-21 12:23:05.653402+00	2026-07-21 12:23:05.653402+00	167ce15f-9954-4a63-a93b-54f6d1c3b955	401ceb0c-1fca-45f6-ba52-20850f10c38c
9e026bc3-66b8-45d7-9c60-0989a6664192	کارمند 2 حسابداری و مالی	employee	t	e5c268f5-5274-4960-be2b-6f7bbba26625	2026-07-21 12:23:05.653402+00	2026-07-21 12:23:05.653402+00	167ce15f-9954-4a63-a93b-54f6d1c3b955	acffa94a-6195-417e-b0df-6df4a5ffd80b
9e026bc3-66b8-45d7-9c60-0989a6664192	کارمند 3 حسابداری و مالی	employee	t	6965fa45-fddb-4465-b0e6-042192ac6ee2	2026-07-21 12:23:05.653402+00	2026-07-21 12:23:05.653402+00	167ce15f-9954-4a63-a93b-54f6d1c3b955	46f5779e-941c-43b3-b11a-480740a9e007
9e026bc3-66b8-45d7-9c60-0989a6664192	کارمند 4 حسابداری و مالی	employee	t	515597de-809a-4b6a-9fb6-5e2cf6d9dfe2	2026-07-21 12:23:05.653402+00	2026-07-21 12:23:05.653402+00	167ce15f-9954-4a63-a93b-54f6d1c3b955	f6ab9826-ec45-4961-a642-0ee3bf00e58a
9e026bc3-66b8-45d7-9c60-0989a6664192	کارمند 5 حسابداری و مالی	employee	t	147770ac-f6f9-4af1-97c3-cccc614d44e9	2026-07-21 12:23:05.653402+00	2026-07-21 12:23:05.653402+00	167ce15f-9954-4a63-a93b-54f6d1c3b955	b30402cc-ab33-489a-8947-dd5c0754f8d1
9e026bc3-66b8-45d7-9c60-0989a6664192	کارمند 6 حسابداری و مالی	employee	t	c17589b4-349d-4156-9b66-f7ecf971b52d	2026-07-21 12:23:05.653402+00	2026-07-21 12:23:05.653402+00	167ce15f-9954-4a63-a93b-54f6d1c3b955	cf631693-3605-4012-980e-743cc9d5a209
9e026bc3-66b8-45d7-9c60-0989a6664192	مدیر پروژه منابع انسانی	project_manager	t	be682dce-6665-4ff0-8e8a-067602882309	2026-07-21 12:23:05.653402+00	2026-07-21 12:23:05.653402+00	13fe4056-fcc6-4d8b-9bb2-6444c12239a5	41c66ae5-00f0-4248-a5d5-a4001c7047e1
9e026bc3-66b8-45d7-9c60-0989a6664192	کارمند 1 منابع انسانی	employee	t	37e62239-b7c6-493c-9475-fe700a479e79	2026-07-21 12:23:05.653402+00	2026-07-21 12:23:05.653402+00	13fe4056-fcc6-4d8b-9bb2-6444c12239a5	d0c44ea5-94f1-4ad0-865a-d660006f7a7b
9e026bc3-66b8-45d7-9c60-0989a6664192	کارمند 2 منابع انسانی	employee	t	fe6b733f-8cf4-4df1-a83e-2e854a480178	2026-07-21 12:23:05.653402+00	2026-07-21 12:23:05.653402+00	13fe4056-fcc6-4d8b-9bb2-6444c12239a5	59ad45cb-ef50-46ae-ac4b-b32602ca8213
9e026bc3-66b8-45d7-9c60-0989a6664192	کارمند 3 منابع انسانی	employee	t	2310cdf5-d549-4a28-bc04-2052038876fc	2026-07-21 12:23:05.653402+00	2026-07-21 12:23:05.653402+00	13fe4056-fcc6-4d8b-9bb2-6444c12239a5	cace6c02-5e04-4083-b05e-8eeb77cce34c
9e026bc3-66b8-45d7-9c60-0989a6664192	کارمند 4 منابع انسانی	employee	t	220f13de-14e7-4c15-a3c3-d456ccb8f206	2026-07-21 12:23:05.653402+00	2026-07-21 12:23:05.653402+00	13fe4056-fcc6-4d8b-9bb2-6444c12239a5	8c85f4f1-412e-4869-aff0-f64200836c3a
9e026bc3-66b8-45d7-9c60-0989a6664192	کارمند 5 منابع انسانی	employee	t	3cdfd222-0ea4-4a30-b15b-036d1d733193	2026-07-21 12:23:05.653402+00	2026-07-21 12:23:05.653402+00	13fe4056-fcc6-4d8b-9bb2-6444c12239a5	23bceeb1-beb2-433b-9ffc-51379d578dbe
9e026bc3-66b8-45d7-9c60-0989a6664192	کارمند 6 منابع انسانی	employee	t	1f7a4d5f-3f0b-4a87-92e9-cf7057b674f5	2026-07-21 12:23:05.653402+00	2026-07-21 12:23:05.653402+00	13fe4056-fcc6-4d8b-9bb2-6444c12239a5	ec07ffa7-05d7-422d-ba55-c3ec21189b73
\.


--
-- Data for Name: worklogs; Type: TABLE DATA; Schema: public; Owner: -
--

COPY public.worklogs (organization_id, task_id, user_id, activity_description, time_spent_minutes, progress_percent, log_date, status, reviewed_by_id, review_comment, id, created_at, updated_at) FROM stdin;
9e026bc3-66b8-45d7-9c60-0989a6664192	80b7e505-b2e2-4615-b191-6aa2d479fb86	6b87e773-3d93-47db-8dc6-37ca0e6e9b32	مستندسازی و نهایی‌سازی	118	33	2026-07-16	approved	75bbbdd2-5d00-4257-8e1e-c3881eebcf0e	\N	5e5c8930-53dc-4999-ba3a-21cb994d862c	2026-07-21 12:23:05.653402+00	2026-07-21 12:23:05.653402+00
9e026bc3-66b8-45d7-9c60-0989a6664192	80b7e505-b2e2-4615-b191-6aa2d479fb86	6b87e773-3d93-47db-8dc6-37ca0e6e9b32	تست و اطمینان از عملکرد صحیح	99	58	2026-07-16	approved	75bbbdd2-5d00-4257-8e1e-c3881eebcf0e	\N	f8dbaf6a-c770-4453-b326-09684adec92f	2026-07-21 12:23:05.653402+00	2026-07-21 12:23:05.653402+00
9e026bc3-66b8-45d7-9c60-0989a6664192	80b7e505-b2e2-4615-b191-6aa2d479fb86	6b87e773-3d93-47db-8dc6-37ca0e6e9b32	پیاده‌سازی بخش اصلی	110	69	2026-07-16	approved	75bbbdd2-5d00-4257-8e1e-c3881eebcf0e	\N	53f50d85-ab6b-4d76-976f-d09e75873db3	2026-07-21 12:23:05.653402+00	2026-07-21 12:23:05.653402+00
9e026bc3-66b8-45d7-9c60-0989a6664192	c5e73729-c2f0-4605-b8ae-2f03e19c9284	24e34af4-1229-4d93-8615-b8479b51a37c	تست و اطمینان از عملکرد صحیح	100	38	2026-07-16	approved	75bbbdd2-5d00-4257-8e1e-c3881eebcf0e	\N	a5d994ad-6b58-450e-8bca-0c273605d1f3	2026-07-21 12:23:05.653402+00	2026-07-21 12:23:05.653402+00
9e026bc3-66b8-45d7-9c60-0989a6664192	c5e73729-c2f0-4605-b8ae-2f03e19c9284	24e34af4-1229-4d93-8615-b8479b51a37c	پیاده‌سازی بخش اصلی	105	54	2026-07-16	submitted	\N	\N	4862fa95-9548-4dbb-aa14-88a18df8989f	2026-07-21 12:23:05.653402+00	2026-07-21 12:23:05.653402+00
9e026bc3-66b8-45d7-9c60-0989a6664192	5616b639-ee13-4b34-8cf9-cd29e32f2919	8c7cac5d-349c-4d45-ab78-f4e52554d784	مستندسازی و نهایی‌سازی	62	28	2026-07-16	approved	75bbbdd2-5d00-4257-8e1e-c3881eebcf0e	\N	de533b58-2610-46f8-b7ca-1e8bce53900d	2026-07-21 12:23:05.653402+00	2026-07-21 12:23:05.653402+00
9e026bc3-66b8-45d7-9c60-0989a6664192	5616b639-ee13-4b34-8cf9-cd29e32f2919	8c7cac5d-349c-4d45-ab78-f4e52554d784	مستندسازی و نهایی‌سازی	104	48	2026-07-16	submitted	\N	\N	dbc80599-7e36-4038-882b-ae98541cfada	2026-07-21 12:23:05.653402+00	2026-07-21 12:23:05.653402+00
9e026bc3-66b8-45d7-9c60-0989a6664192	5616b639-ee13-4b34-8cf9-cd29e32f2919	8c7cac5d-349c-4d45-ab78-f4e52554d784	پیشرفت اولیه و بررسی نیازمندی‌ها	176	87	2026-07-16	approved	75bbbdd2-5d00-4257-8e1e-c3881eebcf0e	\N	5b66ac97-b19b-4c6e-81a7-eb2256783590	2026-07-21 12:23:05.653402+00	2026-07-21 12:23:05.653402+00
9e026bc3-66b8-45d7-9c60-0989a6664192	7d81592f-3335-49df-a269-8a8ec5b0c833	dbe12768-1ffa-4f9b-8327-4558c4438ef6	تست و اطمینان از عملکرد صحیح	117	25	2026-06-20	approved	75bbbdd2-5d00-4257-8e1e-c3881eebcf0e	\N	a3d7dbd7-bb89-43c8-aa1e-c4d9d376deef	2026-07-21 12:23:05.653402+00	2026-07-21 12:23:05.653402+00
9e026bc3-66b8-45d7-9c60-0989a6664192	7d81592f-3335-49df-a269-8a8ec5b0c833	dbe12768-1ffa-4f9b-8327-4558c4438ef6	رفع اشکالات و بازبینی	152	46	2026-06-21	approved	75bbbdd2-5d00-4257-8e1e-c3881eebcf0e	\N	9eac1ba9-9d6d-44dc-a37c-a9547d970c0e	2026-07-21 12:23:05.653402+00	2026-07-21 12:23:05.653402+00
9e026bc3-66b8-45d7-9c60-0989a6664192	7d81592f-3335-49df-a269-8a8ec5b0c833	dbe12768-1ffa-4f9b-8327-4558c4438ef6	تست و اطمینان از عملکرد صحیح	155	66	2026-06-22	approved	75bbbdd2-5d00-4257-8e1e-c3881eebcf0e	\N	96a536bc-50a3-44b8-a2b3-7bc2ead0e02d	2026-07-21 12:23:05.653402+00	2026-07-21 12:23:05.653402+00
9e026bc3-66b8-45d7-9c60-0989a6664192	7d81592f-3335-49df-a269-8a8ec5b0c833	dbe12768-1ffa-4f9b-8327-4558c4438ef6	پیاده‌سازی بخش اصلی	68	100	2026-06-23	approved	75bbbdd2-5d00-4257-8e1e-c3881eebcf0e	\N	ea4ec39c-53e7-467b-b380-aaeb2de8030d	2026-07-21 12:23:05.653402+00	2026-07-21 12:23:05.653402+00
9e026bc3-66b8-45d7-9c60-0989a6664192	c6fe217b-6f18-4a84-addd-10458f437c50	75bbbdd2-5d00-4257-8e1e-c3881eebcf0e	پیشرفت اولیه و بررسی نیازمندی‌ها	172	33	2026-07-16	submitted	\N	\N	957fb36c-5234-4d31-8a74-5cf1d8cdc90d	2026-07-21 12:23:05.653402+00	2026-07-21 12:23:05.653402+00
9e026bc3-66b8-45d7-9c60-0989a6664192	c6fe217b-6f18-4a84-addd-10458f437c50	75bbbdd2-5d00-4257-8e1e-c3881eebcf0e	تست و اطمینان از عملکرد صحیح	145	68	2026-07-16	submitted	\N	\N	2c41da07-f219-4011-8df6-3a9e5bb38e82	2026-07-21 12:23:05.653402+00	2026-07-21 12:23:05.653402+00
9e026bc3-66b8-45d7-9c60-0989a6664192	c6fe217b-6f18-4a84-addd-10458f437c50	75bbbdd2-5d00-4257-8e1e-c3881eebcf0e	تست و اطمینان از عملکرد صحیح	108	100	2026-07-16	submitted	\N	\N	724fdee5-6447-46b7-a144-19141b779862	2026-07-21 12:23:05.653402+00	2026-07-21 12:23:05.653402+00
9e026bc3-66b8-45d7-9c60-0989a6664192	b96e5c7b-a83e-4f53-a93c-a3569d39f792	ad47309d-1c75-4d68-b779-348021512719	پیاده‌سازی بخش اصلی	190	26	2026-07-16	approved	75bbbdd2-5d00-4257-8e1e-c3881eebcf0e	\N	c74f04bb-3200-4163-ac73-1447d1fe62d8	2026-07-21 12:23:05.653402+00	2026-07-21 12:23:05.653402+00
9e026bc3-66b8-45d7-9c60-0989a6664192	d092395f-c497-4ed1-ab80-39a29194ba05	7e07497e-be59-442a-82ad-943e3bd502bb	پیاده‌سازی بخش اصلی	171	22	2026-07-03	approved	75bbbdd2-5d00-4257-8e1e-c3881eebcf0e	\N	b36ac785-b1ec-414e-a4e6-b82c8bb73c61	2026-07-21 12:23:05.653402+00	2026-07-21 12:23:05.653402+00
9e026bc3-66b8-45d7-9c60-0989a6664192	d092395f-c497-4ed1-ab80-39a29194ba05	7e07497e-be59-442a-82ad-943e3bd502bb	تست و اطمینان از عملکرد صحیح	206	78	2026-07-05	approved	75bbbdd2-5d00-4257-8e1e-c3881eebcf0e	\N	776f3667-a874-48b2-ae61-14cc7af25a0a	2026-07-21 12:23:05.653402+00	2026-07-21 12:23:05.653402+00
9e026bc3-66b8-45d7-9c60-0989a6664192	d092395f-c497-4ed1-ab80-39a29194ba05	7e07497e-be59-442a-82ad-943e3bd502bb	پیاده‌سازی بخش اصلی	103	87	2026-07-11	approved	75bbbdd2-5d00-4257-8e1e-c3881eebcf0e	\N	5f34ddc8-ad79-4170-bd2e-59483282be93	2026-07-21 12:23:05.653402+00	2026-07-21 12:23:05.653402+00
9e026bc3-66b8-45d7-9c60-0989a6664192	e0afa379-b68c-4b65-9461-8e1f4401762e	24e34af4-1229-4d93-8615-b8479b51a37c	پیاده‌سازی بخش اصلی	97	40	2026-07-06	approved	75bbbdd2-5d00-4257-8e1e-c3881eebcf0e	\N	40cd7433-1416-4ac2-9faf-536ff500fa4b	2026-07-21 12:23:05.653402+00	2026-07-21 12:23:05.653402+00
9e026bc3-66b8-45d7-9c60-0989a6664192	e0afa379-b68c-4b65-9461-8e1f4401762e	24e34af4-1229-4d93-8615-b8479b51a37c	تست و اطمینان از عملکرد صحیح	59	74	2026-07-08	approved	75bbbdd2-5d00-4257-8e1e-c3881eebcf0e	\N	d4fb7a32-4d03-442f-bf53-1fbbc14b95ef	2026-07-21 12:23:05.653402+00	2026-07-21 12:23:05.653402+00
9e026bc3-66b8-45d7-9c60-0989a6664192	e0afa379-b68c-4b65-9461-8e1f4401762e	24e34af4-1229-4d93-8615-b8479b51a37c	پیاده‌سازی بخش اصلی	98	72	2026-07-10	approved	75bbbdd2-5d00-4257-8e1e-c3881eebcf0e	\N	13bfd03f-8650-4145-897c-802595064aee	2026-07-21 12:23:05.653402+00	2026-07-21 12:23:05.653402+00
9e026bc3-66b8-45d7-9c60-0989a6664192	e0afa379-b68c-4b65-9461-8e1f4401762e	24e34af4-1229-4d93-8615-b8479b51a37c	پیشرفت اولیه و بررسی نیازمندی‌ها	72	100	2026-07-09	approved	75bbbdd2-5d00-4257-8e1e-c3881eebcf0e	\N	ebd04959-1c7c-4561-9306-d449118dcab1	2026-07-21 12:23:05.653402+00	2026-07-21 12:23:05.653402+00
9e026bc3-66b8-45d7-9c60-0989a6664192	2bc046ad-45fb-479a-9dfd-f79a1815bd94	ad47309d-1c75-4d68-b779-348021512719	پیشرفت اولیه و بررسی نیازمندی‌ها	149	29	2026-06-24	approved	75bbbdd2-5d00-4257-8e1e-c3881eebcf0e	\N	3ffc4e1a-a1f9-4a53-b588-6b7755ef23cc	2026-07-21 12:23:05.653402+00	2026-07-21 12:23:05.653402+00
9e026bc3-66b8-45d7-9c60-0989a6664192	2bc046ad-45fb-479a-9dfd-f79a1815bd94	ad47309d-1c75-4d68-b779-348021512719	رفع اشکالات و بازبینی	158	74	2026-06-28	approved	75bbbdd2-5d00-4257-8e1e-c3881eebcf0e	\N	81f7ad8d-07e2-472a-8db2-b4e03aba065f	2026-07-21 12:23:05.653402+00	2026-07-21 12:23:05.653402+00
9e026bc3-66b8-45d7-9c60-0989a6664192	2bc046ad-45fb-479a-9dfd-f79a1815bd94	ad47309d-1c75-4d68-b779-348021512719	تست و اطمینان از عملکرد صحیح	50	100	2026-07-02	approved	75bbbdd2-5d00-4257-8e1e-c3881eebcf0e	\N	dfb25ce9-9280-46a3-8e38-725c8061a899	2026-07-21 12:23:05.653402+00	2026-07-21 12:23:05.653402+00
9e026bc3-66b8-45d7-9c60-0989a6664192	ae5bf3b0-e950-4481-918c-c8a9eb0f6bb3	ad47309d-1c75-4d68-b779-348021512719	رفع اشکالات و بازبینی	184	28	2026-07-16	approved	75bbbdd2-5d00-4257-8e1e-c3881eebcf0e	\N	5e2e5c5f-b07f-4cc8-850b-649c95497b5a	2026-07-21 12:23:05.653402+00	2026-07-21 12:23:05.653402+00
9e026bc3-66b8-45d7-9c60-0989a6664192	c6121599-2b02-4d9a-a2e9-50c293a10027	24e34af4-1229-4d93-8615-b8479b51a37c	پیاده‌سازی بخش اصلی	202	38	2026-07-16	approved	75bbbdd2-5d00-4257-8e1e-c3881eebcf0e	\N	660af355-6348-483c-ae5a-99d6b33ef4dc	2026-07-21 12:23:05.653402+00	2026-07-21 12:23:05.653402+00
9e026bc3-66b8-45d7-9c60-0989a6664192	d4dbccdf-1a00-442c-86e3-e2948db5defd	24e34af4-1229-4d93-8615-b8479b51a37c	مستندسازی و نهایی‌سازی	40	25	2026-06-20	approved	75bbbdd2-5d00-4257-8e1e-c3881eebcf0e	\N	f5c53ad6-b096-4d58-ab3c-fd48fa8da9f5	2026-07-21 12:23:05.653402+00	2026-07-21 12:23:05.653402+00
9e026bc3-66b8-45d7-9c60-0989a6664192	c3c8ddd0-30ac-42d2-8e0e-36fb3434b812	6b87e773-3d93-47db-8dc6-37ca0e6e9b32	پیاده‌سازی بخش اصلی	179	33	2026-07-16	submitted	\N	\N	5259adc5-736b-4606-b624-35cb398c9c8a	2026-07-21 12:23:05.653402+00	2026-07-21 12:23:05.653402+00
9e026bc3-66b8-45d7-9c60-0989a6664192	c3c8ddd0-30ac-42d2-8e0e-36fb3434b812	6b87e773-3d93-47db-8dc6-37ca0e6e9b32	تست و اطمینان از عملکرد صحیح	119	66	2026-07-16	submitted	\N	\N	8459c524-7ad7-4b03-bfd9-e17d32479a22	2026-07-21 12:23:05.653402+00	2026-07-21 12:23:05.653402+00
9e026bc3-66b8-45d7-9c60-0989a6664192	c3c8ddd0-30ac-42d2-8e0e-36fb3434b812	6b87e773-3d93-47db-8dc6-37ca0e6e9b32	پیشرفت اولیه و بررسی نیازمندی‌ها	71	90	2026-07-16	approved	75bbbdd2-5d00-4257-8e1e-c3881eebcf0e	\N	29c6fb1c-cbd0-4605-9219-bf094f1753db	2026-07-21 12:23:05.653402+00	2026-07-21 12:23:05.653402+00
9e026bc3-66b8-45d7-9c60-0989a6664192	c3c8ddd0-30ac-42d2-8e0e-36fb3434b812	6b87e773-3d93-47db-8dc6-37ca0e6e9b32	رفع اشکالات و بازبینی	199	100	2026-07-16	approved	75bbbdd2-5d00-4257-8e1e-c3881eebcf0e	\N	4e15c940-b556-4f28-b18f-0c18a0a8676d	2026-07-21 12:23:05.653402+00	2026-07-21 12:23:05.653402+00
9e026bc3-66b8-45d7-9c60-0989a6664192	ca7ca224-33f7-41bb-ae0c-19e75d269597	6b87e773-3d93-47db-8dc6-37ca0e6e9b32	پیشرفت اولیه و بررسی نیازمندی‌ها	110	28	2026-07-03	approved	75bbbdd2-5d00-4257-8e1e-c3881eebcf0e	\N	20099fd5-a412-47af-8700-7cd430412cbd	2026-07-21 12:23:05.653402+00	2026-07-21 12:23:05.653402+00
9e026bc3-66b8-45d7-9c60-0989a6664192	86bfacbc-4e94-4412-b954-f6dfa54a194b	75bbbdd2-5d00-4257-8e1e-c3881eebcf0e	تست و اطمینان از عملکرد صحیح	161	20	2026-07-16	approved	75bbbdd2-5d00-4257-8e1e-c3881eebcf0e	\N	d60a4e84-09e4-4073-9430-1dfaba7f1f58	2026-07-21 12:23:05.653402+00	2026-07-21 12:23:05.653402+00
9e026bc3-66b8-45d7-9c60-0989a6664192	86bfacbc-4e94-4412-b954-f6dfa54a194b	75bbbdd2-5d00-4257-8e1e-c3881eebcf0e	تست و اطمینان از عملکرد صحیح	43	52	2026-07-16	approved	75bbbdd2-5d00-4257-8e1e-c3881eebcf0e	\N	4cf87700-5f2a-4d3e-a6f0-d50d1514045d	2026-07-21 12:23:05.653402+00	2026-07-21 12:23:05.653402+00
9e026bc3-66b8-45d7-9c60-0989a6664192	86bfacbc-4e94-4412-b954-f6dfa54a194b	75bbbdd2-5d00-4257-8e1e-c3881eebcf0e	مستندسازی و نهایی‌سازی	223	100	2026-07-16	approved	75bbbdd2-5d00-4257-8e1e-c3881eebcf0e	\N	aa35ebd9-283d-4100-9760-226bd51f05e4	2026-07-21 12:23:05.653402+00	2026-07-21 12:23:05.653402+00
9e026bc3-66b8-45d7-9c60-0989a6664192	a5499073-6ec6-490c-84b7-841409ecc6be	8c7cac5d-349c-4d45-ab78-f4e52554d784	پیاده‌سازی بخش اصلی	98	37	2026-07-16	approved	75bbbdd2-5d00-4257-8e1e-c3881eebcf0e	\N	2bab9413-b329-45e8-9f19-3ef8aa0341b6	2026-07-21 12:23:05.653402+00	2026-07-21 12:23:05.653402+00
9e026bc3-66b8-45d7-9c60-0989a6664192	a5499073-6ec6-490c-84b7-841409ecc6be	8c7cac5d-349c-4d45-ab78-f4e52554d784	رفع اشکالات و بازبینی	142	70	2026-07-16	approved	75bbbdd2-5d00-4257-8e1e-c3881eebcf0e	\N	021dcc0f-b118-4536-8173-60e49c413701	2026-07-21 12:23:05.653402+00	2026-07-21 12:23:05.653402+00
9e026bc3-66b8-45d7-9c60-0989a6664192	a5499073-6ec6-490c-84b7-841409ecc6be	8c7cac5d-349c-4d45-ab78-f4e52554d784	پیشرفت اولیه و بررسی نیازمندی‌ها	191	100	2026-07-16	approved	75bbbdd2-5d00-4257-8e1e-c3881eebcf0e	\N	ad2c4f10-53f5-46d0-bfc3-6b6a527f070a	2026-07-21 12:23:05.653402+00	2026-07-21 12:23:05.653402+00
9e026bc3-66b8-45d7-9c60-0989a6664192	a5499073-6ec6-490c-84b7-841409ecc6be	8c7cac5d-349c-4d45-ab78-f4e52554d784	پیاده‌سازی بخش اصلی	109	100	2026-07-16	approved	75bbbdd2-5d00-4257-8e1e-c3881eebcf0e	\N	e760131f-f936-4a78-9128-e40e03e51072	2026-07-21 12:23:05.653402+00	2026-07-21 12:23:05.653402+00
9e026bc3-66b8-45d7-9c60-0989a6664192	64932e7e-ec78-4b39-ba42-cab3e667bc53	24e34af4-1229-4d93-8615-b8479b51a37c	پیشرفت اولیه و بررسی نیازمندی‌ها	87	23	2026-07-16	approved	75bbbdd2-5d00-4257-8e1e-c3881eebcf0e	\N	d6e74128-ac21-42e5-979b-4363518b99a5	2026-07-21 12:23:05.653402+00	2026-07-21 12:23:05.653402+00
9e026bc3-66b8-45d7-9c60-0989a6664192	9d4696f2-d864-4245-a6fa-42999537ce31	7e07497e-be59-442a-82ad-943e3bd502bb	پیاده‌سازی بخش اصلی	157	29	2026-07-16	approved	75bbbdd2-5d00-4257-8e1e-c3881eebcf0e	\N	7308e972-0537-448d-8bd5-c5fad824acf7	2026-07-21 12:23:05.653402+00	2026-07-21 12:23:05.653402+00
9e026bc3-66b8-45d7-9c60-0989a6664192	9d4696f2-d864-4245-a6fa-42999537ce31	7e07497e-be59-442a-82ad-943e3bd502bb	تست و اطمینان از عملکرد صحیح	150	54	2026-07-16	approved	75bbbdd2-5d00-4257-8e1e-c3881eebcf0e	\N	12febbf4-e5bb-473e-a7f1-156296115077	2026-07-21 12:23:05.653402+00	2026-07-21 12:23:05.653402+00
9e026bc3-66b8-45d7-9c60-0989a6664192	9d4696f2-d864-4245-a6fa-42999537ce31	7e07497e-be59-442a-82ad-943e3bd502bb	تست و اطمینان از عملکرد صحیح	78	100	2026-07-16	approved	75bbbdd2-5d00-4257-8e1e-c3881eebcf0e	\N	ac3dad48-5381-4350-a7da-541dd3ab9d62	2026-07-21 12:23:05.653402+00	2026-07-21 12:23:05.653402+00
9e026bc3-66b8-45d7-9c60-0989a6664192	9d4696f2-d864-4245-a6fa-42999537ce31	7e07497e-be59-442a-82ad-943e3bd502bb	رفع اشکالات و بازبینی	227	100	2026-07-16	submitted	\N	\N	fcb07c81-621a-4bdd-8117-968679f3c8d2	2026-07-21 12:23:05.653402+00	2026-07-21 12:23:05.653402+00
9e026bc3-66b8-45d7-9c60-0989a6664192	5caa0362-108a-42ab-aa0f-f3fc672edaa2	7e07497e-be59-442a-82ad-943e3bd502bb	پیشرفت اولیه و بررسی نیازمندی‌ها	102	29	2026-07-14	approved	75bbbdd2-5d00-4257-8e1e-c3881eebcf0e	\N	532f2221-6dff-4960-84e4-de934ebe31d1	2026-07-21 12:23:05.653402+00	2026-07-21 12:23:05.653402+00
9e026bc3-66b8-45d7-9c60-0989a6664192	5caa0362-108a-42ab-aa0f-f3fc672edaa2	7e07497e-be59-442a-82ad-943e3bd502bb	پیاده‌سازی بخش اصلی	144	74	2026-07-16	approved	75bbbdd2-5d00-4257-8e1e-c3881eebcf0e	\N	a8713269-5854-445a-b8ea-964f48273e1f	2026-07-21 12:23:05.653402+00	2026-07-21 12:23:05.653402+00
9e026bc3-66b8-45d7-9c60-0989a6664192	5caa0362-108a-42ab-aa0f-f3fc672edaa2	7e07497e-be59-442a-82ad-943e3bd502bb	رفع اشکالات و بازبینی	115	100	2026-07-16	approved	75bbbdd2-5d00-4257-8e1e-c3881eebcf0e	\N	e9fee10d-b40a-4dbd-8cc2-1340757c8c53	2026-07-21 12:23:05.653402+00	2026-07-21 12:23:05.653402+00
9e026bc3-66b8-45d7-9c60-0989a6664192	d93fb70e-c209-4316-8bcb-c30bb27a2e17	75bbbdd2-5d00-4257-8e1e-c3881eebcf0e	پیاده‌سازی بخش اصلی	208	27	2026-06-17	submitted	\N	\N	8990f26c-dfa4-4d9b-9fa8-698fc186abdb	2026-07-21 12:23:05.653402+00	2026-07-21 12:23:05.653402+00
9e026bc3-66b8-45d7-9c60-0989a6664192	d93fb70e-c209-4316-8bcb-c30bb27a2e17	75bbbdd2-5d00-4257-8e1e-c3881eebcf0e	تست و اطمینان از عملکرد صحیح	41	60	2026-06-21	approved	75bbbdd2-5d00-4257-8e1e-c3881eebcf0e	\N	78a990ad-932c-4b2e-a33f-4beb571d1ae7	2026-07-21 12:23:05.653402+00	2026-07-21 12:23:05.653402+00
9e026bc3-66b8-45d7-9c60-0989a6664192	d93fb70e-c209-4316-8bcb-c30bb27a2e17	75bbbdd2-5d00-4257-8e1e-c3881eebcf0e	تست و اطمینان از عملکرد صحیح	128	100	2026-06-25	submitted	\N	\N	4a09f064-283b-4af0-a828-988c54e65956	2026-07-21 12:23:05.653402+00	2026-07-21 12:23:05.653402+00
9e026bc3-66b8-45d7-9c60-0989a6664192	d93fb70e-c209-4316-8bcb-c30bb27a2e17	75bbbdd2-5d00-4257-8e1e-c3881eebcf0e	پیشرفت اولیه و بررسی نیازمندی‌ها	62	100	2026-06-23	approved	75bbbdd2-5d00-4257-8e1e-c3881eebcf0e	\N	415f4c40-7740-42cb-9f8e-375371836c8e	2026-07-21 12:23:05.653402+00	2026-07-21 12:23:05.653402+00
9e026bc3-66b8-45d7-9c60-0989a6664192	7b8ba467-7d0c-4e81-b296-49743f17ab66	75bbbdd2-5d00-4257-8e1e-c3881eebcf0e	تست و اطمینان از عملکرد صحیح	55	36	2026-07-16	approved	75bbbdd2-5d00-4257-8e1e-c3881eebcf0e	\N	d429dd51-620d-445d-b49e-6abe617776db	2026-07-21 12:23:05.653402+00	2026-07-21 12:23:05.653402+00
9e026bc3-66b8-45d7-9c60-0989a6664192	7b8ba467-7d0c-4e81-b296-49743f17ab66	75bbbdd2-5d00-4257-8e1e-c3881eebcf0e	پیشرفت اولیه و بررسی نیازمندی‌ها	214	48	2026-07-16	approved	75bbbdd2-5d00-4257-8e1e-c3881eebcf0e	\N	2b9961a9-085b-456e-b119-2ba8b64e2621	2026-07-21 12:23:05.653402+00	2026-07-21 12:23:05.653402+00
9e026bc3-66b8-45d7-9c60-0989a6664192	7b8ba467-7d0c-4e81-b296-49743f17ab66	75bbbdd2-5d00-4257-8e1e-c3881eebcf0e	پیاده‌سازی بخش اصلی	49	100	2026-07-16	approved	75bbbdd2-5d00-4257-8e1e-c3881eebcf0e	\N	8b06da0c-4ca1-4f3d-a795-be7cb2336cb4	2026-07-21 12:23:05.653402+00	2026-07-21 12:23:05.653402+00
9e026bc3-66b8-45d7-9c60-0989a6664192	ab9670f6-32ee-42f5-a014-875b701dd355	75bbbdd2-5d00-4257-8e1e-c3881eebcf0e	مستندسازی و نهایی‌سازی	207	32	2026-07-16	approved	75bbbdd2-5d00-4257-8e1e-c3881eebcf0e	\N	8f4b7701-c5f9-4ca9-ab0c-932cfbfcffdc	2026-07-21 12:23:05.653402+00	2026-07-21 12:23:05.653402+00
9e026bc3-66b8-45d7-9c60-0989a6664192	ab9670f6-32ee-42f5-a014-875b701dd355	75bbbdd2-5d00-4257-8e1e-c3881eebcf0e	رفع اشکالات و بازبینی	202	74	2026-07-16	approved	75bbbdd2-5d00-4257-8e1e-c3881eebcf0e	\N	f234dcb5-187e-4576-941e-a52cbed2216c	2026-07-21 12:23:05.653402+00	2026-07-21 12:23:05.653402+00
9e026bc3-66b8-45d7-9c60-0989a6664192	ab9670f6-32ee-42f5-a014-875b701dd355	75bbbdd2-5d00-4257-8e1e-c3881eebcf0e	رفع اشکالات و بازبینی	190	100	2026-07-16	approved	75bbbdd2-5d00-4257-8e1e-c3881eebcf0e	\N	95bc59b7-aa31-4cb9-b17d-7c94ff541f95	2026-07-21 12:23:05.653402+00	2026-07-21 12:23:05.653402+00
9e026bc3-66b8-45d7-9c60-0989a6664192	5dd2ce54-221d-4f4c-8a18-c929c7a8447a	6b87e773-3d93-47db-8dc6-37ca0e6e9b32	پیاده‌سازی بخش اصلی	191	29	2026-07-16	approved	75bbbdd2-5d00-4257-8e1e-c3881eebcf0e	\N	0f10bc23-65f7-4145-aaf5-661e384e5d1c	2026-07-21 12:23:05.653402+00	2026-07-21 12:23:05.653402+00
9e026bc3-66b8-45d7-9c60-0989a6664192	73d2938c-5350-4afe-a62d-01d192c02187	75bbbdd2-5d00-4257-8e1e-c3881eebcf0e	تست و اطمینان از عملکرد صحیح	55	40	2026-07-13	approved	75bbbdd2-5d00-4257-8e1e-c3881eebcf0e	\N	bb6ce4eb-a898-48e0-885e-661e090c8f66	2026-07-21 12:23:05.653402+00	2026-07-21 12:23:05.653402+00
9e026bc3-66b8-45d7-9c60-0989a6664192	73d2938c-5350-4afe-a62d-01d192c02187	75bbbdd2-5d00-4257-8e1e-c3881eebcf0e	تست و اطمینان از عملکرد صحیح	72	58	2026-07-14	approved	75bbbdd2-5d00-4257-8e1e-c3881eebcf0e	\N	e57c5908-5746-40f4-995e-cb3438851aba	2026-07-21 12:23:05.653402+00	2026-07-21 12:23:05.653402+00
9e026bc3-66b8-45d7-9c60-0989a6664192	8211d3d9-326b-46f2-8db1-1f3b7b9cee86	ad47309d-1c75-4d68-b779-348021512719	رفع اشکالات و بازبینی	233	21	2026-07-11	approved	75bbbdd2-5d00-4257-8e1e-c3881eebcf0e	\N	dddcf307-1537-479a-8943-188199cad82e	2026-07-21 12:23:05.653402+00	2026-07-21 12:23:05.653402+00
9e026bc3-66b8-45d7-9c60-0989a6664192	3a720c1c-dd7b-4a63-b2a2-2f09d52d94c9	24e34af4-1229-4d93-8615-b8479b51a37c	رفع اشکالات و بازبینی	140	24	2026-07-13	approved	75bbbdd2-5d00-4257-8e1e-c3881eebcf0e	\N	41fc7408-1768-4874-abab-5cbb30da145c	2026-07-21 12:23:05.653402+00	2026-07-21 12:23:05.653402+00
9e026bc3-66b8-45d7-9c60-0989a6664192	3a720c1c-dd7b-4a63-b2a2-2f09d52d94c9	24e34af4-1229-4d93-8615-b8479b51a37c	مستندسازی و نهایی‌سازی	135	76	2026-07-15	approved	75bbbdd2-5d00-4257-8e1e-c3881eebcf0e	\N	656b343d-2b3d-47e9-836d-950a68ee8aaf	2026-07-21 12:23:05.653402+00	2026-07-21 12:23:05.653402+00
9e026bc3-66b8-45d7-9c60-0989a6664192	3a720c1c-dd7b-4a63-b2a2-2f09d52d94c9	24e34af4-1229-4d93-8615-b8479b51a37c	پیاده‌سازی بخش اصلی	74	66	2026-07-16	approved	75bbbdd2-5d00-4257-8e1e-c3881eebcf0e	\N	d9ddaffc-3bc1-4e11-8457-f92d31865bd3	2026-07-21 12:23:05.653402+00	2026-07-21 12:23:05.653402+00
9e026bc3-66b8-45d7-9c60-0989a6664192	b5ccf468-16dc-4073-8429-c2f06428aaeb	75bbbdd2-5d00-4257-8e1e-c3881eebcf0e	تست و اطمینان از عملکرد صحیح	179	24	2026-07-16	approved	75bbbdd2-5d00-4257-8e1e-c3881eebcf0e	\N	427226e3-5619-4e54-81de-dc003e60cff6	2026-07-21 12:23:05.653402+00	2026-07-21 12:23:05.653402+00
9e026bc3-66b8-45d7-9c60-0989a6664192	b5ccf468-16dc-4073-8429-c2f06428aaeb	75bbbdd2-5d00-4257-8e1e-c3881eebcf0e	تست و اطمینان از عملکرد صحیح	193	56	2026-07-16	approved	75bbbdd2-5d00-4257-8e1e-c3881eebcf0e	\N	4ab19e41-cf23-4f4b-a3ee-ea553d1774bc	2026-07-21 12:23:05.653402+00	2026-07-21 12:23:05.653402+00
9e026bc3-66b8-45d7-9c60-0989a6664192	b5ccf468-16dc-4073-8429-c2f06428aaeb	75bbbdd2-5d00-4257-8e1e-c3881eebcf0e	رفع اشکالات و بازبینی	200	60	2026-07-16	approved	75bbbdd2-5d00-4257-8e1e-c3881eebcf0e	\N	3fdea57e-0f86-49c3-b8ea-5cd91d5908d9	2026-07-21 12:23:05.653402+00	2026-07-21 12:23:05.653402+00
9e026bc3-66b8-45d7-9c60-0989a6664192	b5ccf468-16dc-4073-8429-c2f06428aaeb	75bbbdd2-5d00-4257-8e1e-c3881eebcf0e	رفع اشکالات و بازبینی	203	100	2026-07-16	approved	75bbbdd2-5d00-4257-8e1e-c3881eebcf0e	\N	3cda141d-030b-4b52-96d5-51b75d255a7b	2026-07-21 12:23:05.653402+00	2026-07-21 12:23:05.653402+00
9e026bc3-66b8-45d7-9c60-0989a6664192	fcabcba8-7531-4e0f-bac2-ca36c92ca763	8c7cac5d-349c-4d45-ab78-f4e52554d784	رفع اشکالات و بازبینی	180	29	2026-07-16	approved	75bbbdd2-5d00-4257-8e1e-c3881eebcf0e	\N	8191e8bb-7ef9-453b-a516-5cb540f55e32	2026-07-21 12:23:05.653402+00	2026-07-21 12:23:05.653402+00
9e026bc3-66b8-45d7-9c60-0989a6664192	fcabcba8-7531-4e0f-bac2-ca36c92ca763	8c7cac5d-349c-4d45-ab78-f4e52554d784	تست و اطمینان از عملکرد صحیح	107	52	2026-07-16	approved	75bbbdd2-5d00-4257-8e1e-c3881eebcf0e	\N	f8c853ad-1606-46b4-b9c2-41cabed76fdb	2026-07-21 12:23:05.653402+00	2026-07-21 12:23:05.653402+00
9e026bc3-66b8-45d7-9c60-0989a6664192	d388542e-9175-4e01-b686-79fffc764213	dbe12768-1ffa-4f9b-8327-4558c4438ef6	پیشرفت اولیه و بررسی نیازمندی‌ها	90	32	2026-07-16	approved	75bbbdd2-5d00-4257-8e1e-c3881eebcf0e	\N	4bf1240c-178e-49de-95e2-f4fd1590c3d8	2026-07-21 12:23:05.653402+00	2026-07-21 12:23:05.653402+00
9e026bc3-66b8-45d7-9c60-0989a6664192	d388542e-9175-4e01-b686-79fffc764213	dbe12768-1ffa-4f9b-8327-4558c4438ef6	مستندسازی و نهایی‌سازی	105	58	2026-07-16	approved	75bbbdd2-5d00-4257-8e1e-c3881eebcf0e	\N	6490ce59-4bc1-454e-8de6-57fdf6e1413c	2026-07-21 12:23:05.653402+00	2026-07-21 12:23:05.653402+00
9e026bc3-66b8-45d7-9c60-0989a6664192	d388542e-9175-4e01-b686-79fffc764213	dbe12768-1ffa-4f9b-8327-4558c4438ef6	تست و اطمینان از عملکرد صحیح	100	60	2026-07-16	approved	75bbbdd2-5d00-4257-8e1e-c3881eebcf0e	\N	a9bfbf7f-48a5-4b00-8a64-736a49fd6882	2026-07-21 12:23:05.653402+00	2026-07-21 12:23:05.653402+00
9e026bc3-66b8-45d7-9c60-0989a6664192	d388542e-9175-4e01-b686-79fffc764213	dbe12768-1ffa-4f9b-8327-4558c4438ef6	مستندسازی و نهایی‌سازی	220	100	2026-07-16	approved	75bbbdd2-5d00-4257-8e1e-c3881eebcf0e	\N	dd561eeb-cddb-4989-8f20-7a43d4d8fca8	2026-07-21 12:23:05.653402+00	2026-07-21 12:23:05.653402+00
9e026bc3-66b8-45d7-9c60-0989a6664192	42a8743b-fee7-4961-a27f-f80c6193d70b	24e34af4-1229-4d93-8615-b8479b51a37c	رفع اشکالات و بازبینی	86	40	2026-06-29	approved	75bbbdd2-5d00-4257-8e1e-c3881eebcf0e	\N	3ae51609-e810-4e5d-bb81-8085e903260f	2026-07-21 12:23:05.653402+00	2026-07-21 12:23:05.653402+00
9e026bc3-66b8-45d7-9c60-0989a6664192	42a8743b-fee7-4961-a27f-f80c6193d70b	24e34af4-1229-4d93-8615-b8479b51a37c	پیاده‌سازی بخش اصلی	190	46	2026-07-01	approved	75bbbdd2-5d00-4257-8e1e-c3881eebcf0e	\N	b7cbba8e-946c-4fcd-af79-740f0e5941b9	2026-07-21 12:23:05.653402+00	2026-07-21 12:23:05.653402+00
9e026bc3-66b8-45d7-9c60-0989a6664192	42a8743b-fee7-4961-a27f-f80c6193d70b	24e34af4-1229-4d93-8615-b8479b51a37c	تست و اطمینان از عملکرد صحیح	38	100	2026-07-01	approved	75bbbdd2-5d00-4257-8e1e-c3881eebcf0e	\N	90a8da62-abde-4194-80d4-5071bf7c3b68	2026-07-21 12:23:05.653402+00	2026-07-21 12:23:05.653402+00
9e026bc3-66b8-45d7-9c60-0989a6664192	de2d0846-7d62-457f-8570-b56bb4e6ef9e	24e34af4-1229-4d93-8615-b8479b51a37c	رفع اشکالات و بازبینی	113	33	2026-06-23	approved	75bbbdd2-5d00-4257-8e1e-c3881eebcf0e	\N	bfc11676-7ca9-4c21-8b33-dce4337975bd	2026-07-21 12:23:05.653402+00	2026-07-21 12:23:05.653402+00
9e026bc3-66b8-45d7-9c60-0989a6664192	de2d0846-7d62-457f-8570-b56bb4e6ef9e	24e34af4-1229-4d93-8615-b8479b51a37c	مستندسازی و نهایی‌سازی	123	72	2026-06-25	approved	75bbbdd2-5d00-4257-8e1e-c3881eebcf0e	\N	b660cd4f-4afb-4700-acd8-52130b07b475	2026-07-21 12:23:05.653402+00	2026-07-21 12:23:05.653402+00
9e026bc3-66b8-45d7-9c60-0989a6664192	de2d0846-7d62-457f-8570-b56bb4e6ef9e	24e34af4-1229-4d93-8615-b8479b51a37c	رفع اشکالات و بازبینی	153	87	2026-06-29	submitted	\N	\N	07d2ddc1-74f4-44c4-8de1-0f4777c4e8c8	2026-07-21 12:23:05.653402+00	2026-07-21 12:23:05.653402+00
9e026bc3-66b8-45d7-9c60-0989a6664192	7985ff09-e0c3-433c-ac26-5c42f9a8c12d	75bbbdd2-5d00-4257-8e1e-c3881eebcf0e	پیشرفت اولیه و بررسی نیازمندی‌ها	66	27	2026-07-16	approved	75bbbdd2-5d00-4257-8e1e-c3881eebcf0e	\N	a999a4bf-6525-45d1-af84-d6e666a08b1d	2026-07-21 12:23:05.653402+00	2026-07-21 12:23:05.653402+00
9e026bc3-66b8-45d7-9c60-0989a6664192	7985ff09-e0c3-433c-ac26-5c42f9a8c12d	75bbbdd2-5d00-4257-8e1e-c3881eebcf0e	مستندسازی و نهایی‌سازی	123	44	2026-07-16	submitted	\N	\N	df990f94-db90-454d-92de-af042adbe4d2	2026-07-21 12:23:05.653402+00	2026-07-21 12:23:05.653402+00
9e026bc3-66b8-45d7-9c60-0989a6664192	7985ff09-e0c3-433c-ac26-5c42f9a8c12d	75bbbdd2-5d00-4257-8e1e-c3881eebcf0e	مستندسازی و نهایی‌سازی	61	100	2026-07-16	approved	75bbbdd2-5d00-4257-8e1e-c3881eebcf0e	\N	e561cc7b-afdf-4bc6-ba19-42680942e802	2026-07-21 12:23:05.653402+00	2026-07-21 12:23:05.653402+00
9e026bc3-66b8-45d7-9c60-0989a6664192	84bae8c9-d2f3-47b4-bf55-23c14b31ee60	24e34af4-1229-4d93-8615-b8479b51a37c	مستندسازی و نهایی‌سازی	127	40	2026-07-01	approved	75bbbdd2-5d00-4257-8e1e-c3881eebcf0e	\N	be781d53-d0f2-464d-adf7-0e433b3f9068	2026-07-21 12:23:05.653402+00	2026-07-21 12:23:05.653402+00
9e026bc3-66b8-45d7-9c60-0989a6664192	84bae8c9-d2f3-47b4-bf55-23c14b31ee60	24e34af4-1229-4d93-8615-b8479b51a37c	پیشرفت اولیه و بررسی نیازمندی‌ها	202	54	2026-07-04	approved	75bbbdd2-5d00-4257-8e1e-c3881eebcf0e	\N	d991be20-9355-44eb-bff6-428668eafd4f	2026-07-21 12:23:05.653402+00	2026-07-21 12:23:05.653402+00
9e026bc3-66b8-45d7-9c60-0989a6664192	84bae8c9-d2f3-47b4-bf55-23c14b31ee60	24e34af4-1229-4d93-8615-b8479b51a37c	پیشرفت اولیه و بررسی نیازمندی‌ها	188	100	2026-07-09	approved	75bbbdd2-5d00-4257-8e1e-c3881eebcf0e	\N	7c977466-0d22-4fd5-8c66-46bb70b32fbc	2026-07-21 12:23:05.653402+00	2026-07-21 12:23:05.653402+00
9e026bc3-66b8-45d7-9c60-0989a6664192	1b46a05c-2f78-4c1f-b12f-14135e4007b2	dbe12768-1ffa-4f9b-8327-4558c4438ef6	پیشرفت اولیه و بررسی نیازمندی‌ها	192	34	2026-07-16	approved	75bbbdd2-5d00-4257-8e1e-c3881eebcf0e	\N	054c37d1-8243-43bd-b160-957ccd82206d	2026-07-21 12:23:05.653402+00	2026-07-21 12:23:05.653402+00
9e026bc3-66b8-45d7-9c60-0989a6664192	1b46a05c-2f78-4c1f-b12f-14135e4007b2	dbe12768-1ffa-4f9b-8327-4558c4438ef6	تست و اطمینان از عملکرد صحیح	59	48	2026-07-16	approved	75bbbdd2-5d00-4257-8e1e-c3881eebcf0e	\N	a0f474df-5b18-4093-9ea3-30da9af284e6	2026-07-21 12:23:05.653402+00	2026-07-21 12:23:05.653402+00
9e026bc3-66b8-45d7-9c60-0989a6664192	1b46a05c-2f78-4c1f-b12f-14135e4007b2	dbe12768-1ffa-4f9b-8327-4558c4438ef6	پیشرفت اولیه و بررسی نیازمندی‌ها	107	100	2026-07-16	approved	75bbbdd2-5d00-4257-8e1e-c3881eebcf0e	\N	b57646dc-96ba-4668-aafa-8f48613b8b88	2026-07-21 12:23:05.653402+00	2026-07-21 12:23:05.653402+00
9e026bc3-66b8-45d7-9c60-0989a6664192	98dcd0d1-1ca9-45eb-a46e-8aa3bbac9a55	6b87e773-3d93-47db-8dc6-37ca0e6e9b32	پیاده‌سازی بخش اصلی	167	24	2026-07-05	approved	75bbbdd2-5d00-4257-8e1e-c3881eebcf0e	\N	74f0f64b-4e98-40e0-8d53-f83ded45050d	2026-07-21 12:23:05.653402+00	2026-07-21 12:23:05.653402+00
9e026bc3-66b8-45d7-9c60-0989a6664192	fd54df2d-c561-41c4-8733-5df88c76024d	8c7cac5d-349c-4d45-ab78-f4e52554d784	رفع اشکالات و بازبینی	201	37	2026-07-16	approved	75bbbdd2-5d00-4257-8e1e-c3881eebcf0e	\N	2ce7791e-0ead-42a3-97f4-7627477bee1e	2026-07-21 12:23:05.653402+00	2026-07-21 12:23:05.653402+00
9e026bc3-66b8-45d7-9c60-0989a6664192	fd54df2d-c561-41c4-8733-5df88c76024d	8c7cac5d-349c-4d45-ab78-f4e52554d784	مستندسازی و نهایی‌سازی	220	48	2026-07-16	approved	75bbbdd2-5d00-4257-8e1e-c3881eebcf0e	\N	def4d738-d1fa-4a87-96d3-2868252497e1	2026-07-21 12:23:05.653402+00	2026-07-21 12:23:05.653402+00
9e026bc3-66b8-45d7-9c60-0989a6664192	fd54df2d-c561-41c4-8733-5df88c76024d	8c7cac5d-349c-4d45-ab78-f4e52554d784	پیشرفت اولیه و بررسی نیازمندی‌ها	155	100	2026-07-16	approved	75bbbdd2-5d00-4257-8e1e-c3881eebcf0e	\N	322bda06-d5e3-4147-942a-e48962fe8850	2026-07-21 12:23:05.653402+00	2026-07-21 12:23:05.653402+00
9e026bc3-66b8-45d7-9c60-0989a6664192	fd54df2d-c561-41c4-8733-5df88c76024d	8c7cac5d-349c-4d45-ab78-f4e52554d784	رفع اشکالات و بازبینی	38	100	2026-07-16	approved	75bbbdd2-5d00-4257-8e1e-c3881eebcf0e	\N	ead15c13-a1a6-4499-b59a-b1b555866458	2026-07-21 12:23:05.653402+00	2026-07-21 12:23:05.653402+00
9e026bc3-66b8-45d7-9c60-0989a6664192	c98fb204-ee4c-48e7-b484-1bbb53138a4c	75bbbdd2-5d00-4257-8e1e-c3881eebcf0e	تست و اطمینان از عملکرد صحیح	90	31	2026-07-16	approved	75bbbdd2-5d00-4257-8e1e-c3881eebcf0e	\N	ee2c7293-3814-474f-a9a4-9739d19e50ac	2026-07-21 12:23:05.653402+00	2026-07-21 12:23:05.653402+00
9e026bc3-66b8-45d7-9c60-0989a6664192	c98fb204-ee4c-48e7-b484-1bbb53138a4c	75bbbdd2-5d00-4257-8e1e-c3881eebcf0e	رفع اشکالات و بازبینی	169	80	2026-07-16	approved	75bbbdd2-5d00-4257-8e1e-c3881eebcf0e	\N	a4a89963-d762-4261-9941-450cf3718c5b	2026-07-21 12:23:05.653402+00	2026-07-21 12:23:05.653402+00
9e026bc3-66b8-45d7-9c60-0989a6664192	4368f01b-93b2-4250-9079-c8ee2d86d9bb	dbe12768-1ffa-4f9b-8327-4558c4438ef6	پیاده‌سازی بخش اصلی	61	34	2026-07-16	approved	75bbbdd2-5d00-4257-8e1e-c3881eebcf0e	\N	b68cd8f9-c4bb-427b-9d7f-49508c4c9968	2026-07-21 12:23:05.653402+00	2026-07-21 12:23:05.653402+00
9e026bc3-66b8-45d7-9c60-0989a6664192	4368f01b-93b2-4250-9079-c8ee2d86d9bb	dbe12768-1ffa-4f9b-8327-4558c4438ef6	مستندسازی و نهایی‌سازی	35	42	2026-07-16	approved	75bbbdd2-5d00-4257-8e1e-c3881eebcf0e	\N	a447b407-f94c-42d1-a6b7-2ba84be69c89	2026-07-21 12:23:05.653402+00	2026-07-21 12:23:05.653402+00
9e026bc3-66b8-45d7-9c60-0989a6664192	4368f01b-93b2-4250-9079-c8ee2d86d9bb	dbe12768-1ffa-4f9b-8327-4558c4438ef6	پیاده‌سازی بخش اصلی	231	100	2026-07-16	approved	75bbbdd2-5d00-4257-8e1e-c3881eebcf0e	\N	8087cb24-2610-4b49-b53d-2f800fcd5a37	2026-07-21 12:23:05.653402+00	2026-07-21 12:23:05.653402+00
9e026bc3-66b8-45d7-9c60-0989a6664192	d8ffefef-037c-4ece-8197-b4cb5e613bda	7e07497e-be59-442a-82ad-943e3bd502bb	مستندسازی و نهایی‌سازی	83	38	2026-06-20	approved	75bbbdd2-5d00-4257-8e1e-c3881eebcf0e	\N	1cc1d973-bfaf-4de4-adb9-f6e2c3539759	2026-07-21 12:23:05.653402+00	2026-07-21 12:23:05.653402+00
9e026bc3-66b8-45d7-9c60-0989a6664192	d8ffefef-037c-4ece-8197-b4cb5e613bda	7e07497e-be59-442a-82ad-943e3bd502bb	پیاده‌سازی بخش اصلی	114	48	2026-06-22	approved	75bbbdd2-5d00-4257-8e1e-c3881eebcf0e	\N	98139c49-189f-4951-b599-c3b893048a34	2026-07-21 12:23:05.653402+00	2026-07-21 12:23:05.653402+00
9e026bc3-66b8-45d7-9c60-0989a6664192	b775d91e-e5a2-4ad9-8c8e-8656ea113eab	6b87e773-3d93-47db-8dc6-37ca0e6e9b32	پیاده‌سازی بخش اصلی	63	37	2026-06-24	approved	75bbbdd2-5d00-4257-8e1e-c3881eebcf0e	\N	24dd2cc1-4bf3-43f6-829a-0341dce86bc2	2026-07-21 12:23:05.653402+00	2026-07-21 12:23:05.653402+00
9e026bc3-66b8-45d7-9c60-0989a6664192	6dc0fd87-07d6-4bfd-b4cc-313065d2c92d	dbe12768-1ffa-4f9b-8327-4558c4438ef6	پیشرفت اولیه و بررسی نیازمندی‌ها	199	20	2026-07-16	approved	75bbbdd2-5d00-4257-8e1e-c3881eebcf0e	\N	32c24b9c-4725-4d60-9eb8-4311118083c9	2026-07-21 12:23:05.653402+00	2026-07-21 12:23:05.653402+00
9e026bc3-66b8-45d7-9c60-0989a6664192	6dc0fd87-07d6-4bfd-b4cc-313065d2c92d	dbe12768-1ffa-4f9b-8327-4558c4438ef6	پیشرفت اولیه و بررسی نیازمندی‌ها	121	54	2026-07-16	approved	75bbbdd2-5d00-4257-8e1e-c3881eebcf0e	\N	547c0e0a-d62e-4cba-ab10-6c9682dea5bc	2026-07-21 12:23:05.653402+00	2026-07-21 12:23:05.653402+00
9e026bc3-66b8-45d7-9c60-0989a6664192	6dc0fd87-07d6-4bfd-b4cc-313065d2c92d	dbe12768-1ffa-4f9b-8327-4558c4438ef6	پیشرفت اولیه و بررسی نیازمندی‌ها	74	84	2026-07-16	approved	75bbbdd2-5d00-4257-8e1e-c3881eebcf0e	\N	7bc442ee-e64b-4aeb-a189-eb4c9031156d	2026-07-21 12:23:05.653402+00	2026-07-21 12:23:05.653402+00
9e026bc3-66b8-45d7-9c60-0989a6664192	8e517e17-55d8-48dc-ac47-bae6c38f13e7	dbe12768-1ffa-4f9b-8327-4558c4438ef6	مستندسازی و نهایی‌سازی	59	22	2026-07-16	submitted	\N	\N	87c198b6-2b14-438d-a175-1d72f4207e3d	2026-07-21 12:23:05.653402+00	2026-07-21 12:23:05.653402+00
9e026bc3-66b8-45d7-9c60-0989a6664192	cda880d6-0be1-47e1-983e-d30e86db8256	75bbbdd2-5d00-4257-8e1e-c3881eebcf0e	رفع اشکالات و بازبینی	161	38	2026-07-16	approved	75bbbdd2-5d00-4257-8e1e-c3881eebcf0e	\N	8f677898-2c50-4877-bd72-8e00613a8f52	2026-07-21 12:23:05.653402+00	2026-07-21 12:23:05.653402+00
9e026bc3-66b8-45d7-9c60-0989a6664192	cda880d6-0be1-47e1-983e-d30e86db8256	75bbbdd2-5d00-4257-8e1e-c3881eebcf0e	تست و اطمینان از عملکرد صحیح	158	54	2026-07-16	approved	75bbbdd2-5d00-4257-8e1e-c3881eebcf0e	\N	5f9f454b-dd14-4d10-84ec-1ee2e23892c6	2026-07-21 12:23:05.653402+00	2026-07-21 12:23:05.653402+00
9e026bc3-66b8-45d7-9c60-0989a6664192	cda880d6-0be1-47e1-983e-d30e86db8256	75bbbdd2-5d00-4257-8e1e-c3881eebcf0e	مستندسازی و نهایی‌سازی	107	100	2026-07-16	approved	75bbbdd2-5d00-4257-8e1e-c3881eebcf0e	\N	5c1962fd-d37f-441e-bc58-9efc8d9a012d	2026-07-21 12:23:05.653402+00	2026-07-21 12:23:05.653402+00
9e026bc3-66b8-45d7-9c60-0989a6664192	cda880d6-0be1-47e1-983e-d30e86db8256	75bbbdd2-5d00-4257-8e1e-c3881eebcf0e	پیشرفت اولیه و بررسی نیازمندی‌ها	152	100	2026-07-16	approved	75bbbdd2-5d00-4257-8e1e-c3881eebcf0e	\N	a7d049fa-16f7-4cf6-9b51-4c3f4efd3fc7	2026-07-21 12:23:05.653402+00	2026-07-21 12:23:05.653402+00
9e026bc3-66b8-45d7-9c60-0989a6664192	f641cf79-5cdd-4502-b7f1-511129d308bf	8c7cac5d-349c-4d45-ab78-f4e52554d784	تست و اطمینان از عملکرد صحیح	48	22	2026-06-30	approved	75bbbdd2-5d00-4257-8e1e-c3881eebcf0e	\N	8d7b006f-4fb3-4c46-a2f2-b98ed9dcb348	2026-07-21 12:23:05.653402+00	2026-07-21 12:23:05.653402+00
9e026bc3-66b8-45d7-9c60-0989a6664192	f641cf79-5cdd-4502-b7f1-511129d308bf	8c7cac5d-349c-4d45-ab78-f4e52554d784	پیشرفت اولیه و بررسی نیازمندی‌ها	62	56	2026-07-03	approved	75bbbdd2-5d00-4257-8e1e-c3881eebcf0e	\N	4b467bee-89c7-4cff-92b2-09021c305965	2026-07-21 12:23:05.653402+00	2026-07-21 12:23:05.653402+00
9e026bc3-66b8-45d7-9c60-0989a6664192	f641cf79-5cdd-4502-b7f1-511129d308bf	8c7cac5d-349c-4d45-ab78-f4e52554d784	مستندسازی و نهایی‌سازی	165	87	2026-07-06	approved	75bbbdd2-5d00-4257-8e1e-c3881eebcf0e	\N	ea98df63-6cc6-4c6e-9837-1a7a8a6104d0	2026-07-21 12:23:05.653402+00	2026-07-21 12:23:05.653402+00
9e026bc3-66b8-45d7-9c60-0989a6664192	f641cf79-5cdd-4502-b7f1-511129d308bf	8c7cac5d-349c-4d45-ab78-f4e52554d784	تست و اطمینان از عملکرد صحیح	55	92	2026-07-12	approved	75bbbdd2-5d00-4257-8e1e-c3881eebcf0e	\N	f02fea68-457d-4609-82b9-825fef5bf846	2026-07-21 12:23:05.653402+00	2026-07-21 12:23:05.653402+00
9e026bc3-66b8-45d7-9c60-0989a6664192	70d23c70-d7a9-43fe-94c2-9aba83ab49a7	8c7cac5d-349c-4d45-ab78-f4e52554d784	تست و اطمینان از عملکرد صحیح	88	33	2026-06-17	approved	75bbbdd2-5d00-4257-8e1e-c3881eebcf0e	\N	20a06144-3b12-4f98-8143-0099fa59334e	2026-07-21 12:23:05.653402+00	2026-07-21 12:23:05.653402+00
9e026bc3-66b8-45d7-9c60-0989a6664192	70d23c70-d7a9-43fe-94c2-9aba83ab49a7	8c7cac5d-349c-4d45-ab78-f4e52554d784	تست و اطمینان از عملکرد صحیح	132	66	2026-06-20	approved	75bbbdd2-5d00-4257-8e1e-c3881eebcf0e	\N	a1e02aa2-7302-4af4-ad38-e8ed70934102	2026-07-21 12:23:05.653402+00	2026-07-21 12:23:05.653402+00
9e026bc3-66b8-45d7-9c60-0989a6664192	1089f18e-7134-4098-90b2-ae3c1cd5cc67	75bbbdd2-5d00-4257-8e1e-c3881eebcf0e	تست و اطمینان از عملکرد صحیح	110	28	2026-07-16	approved	75bbbdd2-5d00-4257-8e1e-c3881eebcf0e	\N	6bcab6ab-d38e-4ff9-8563-13d2c579d0b4	2026-07-21 12:23:05.653402+00	2026-07-21 12:23:05.653402+00
9e026bc3-66b8-45d7-9c60-0989a6664192	6c88d4ad-bd92-4efb-a39c-57d3a924dfdb	ad47309d-1c75-4d68-b779-348021512719	تست و اطمینان از عملکرد صحیح	47	22	2026-07-16	approved	75bbbdd2-5d00-4257-8e1e-c3881eebcf0e	\N	12df523b-ff4e-4304-8acc-a66c8c10b5f7	2026-07-21 12:23:05.653402+00	2026-07-21 12:23:05.653402+00
9e026bc3-66b8-45d7-9c60-0989a6664192	6c88d4ad-bd92-4efb-a39c-57d3a924dfdb	ad47309d-1c75-4d68-b779-348021512719	پیشرفت اولیه و بررسی نیازمندی‌ها	220	62	2026-07-16	approved	75bbbdd2-5d00-4257-8e1e-c3881eebcf0e	\N	846a8ee5-b9a8-4313-b6f4-aa9ce8d3f8f6	2026-07-21 12:23:05.653402+00	2026-07-21 12:23:05.653402+00
9e026bc3-66b8-45d7-9c60-0989a6664192	6c88d4ad-bd92-4efb-a39c-57d3a924dfdb	ad47309d-1c75-4d68-b779-348021512719	مستندسازی و نهایی‌سازی	173	100	2026-07-16	approved	75bbbdd2-5d00-4257-8e1e-c3881eebcf0e	\N	d5e34106-21fc-4368-af04-1cdce2805095	2026-07-21 12:23:05.653402+00	2026-07-21 12:23:05.653402+00
9e026bc3-66b8-45d7-9c60-0989a6664192	67088c66-1a1b-4f44-8f7c-f8345f63af48	ad47309d-1c75-4d68-b779-348021512719	تست و اطمینان از عملکرد صحیح	214	21	2026-07-06	approved	75bbbdd2-5d00-4257-8e1e-c3881eebcf0e	\N	323e64a1-aea6-4f03-83b7-179dd8bb7365	2026-07-21 12:23:05.653402+00	2026-07-21 12:23:05.653402+00
9e026bc3-66b8-45d7-9c60-0989a6664192	67088c66-1a1b-4f44-8f7c-f8345f63af48	ad47309d-1c75-4d68-b779-348021512719	رفع اشکالات و بازبینی	56	76	2026-07-09	approved	75bbbdd2-5d00-4257-8e1e-c3881eebcf0e	\N	09287e0c-71bc-4596-93a4-9cba68108177	2026-07-21 12:23:05.653402+00	2026-07-21 12:23:05.653402+00
9e026bc3-66b8-45d7-9c60-0989a6664192	67088c66-1a1b-4f44-8f7c-f8345f63af48	ad47309d-1c75-4d68-b779-348021512719	تست و اطمینان از عملکرد صحیح	87	69	2026-07-10	approved	75bbbdd2-5d00-4257-8e1e-c3881eebcf0e	\N	a61a4e83-3fe1-4024-a0b8-84a7802e988d	2026-07-21 12:23:05.653402+00	2026-07-21 12:23:05.653402+00
9e026bc3-66b8-45d7-9c60-0989a6664192	d641559c-4def-4f7b-b322-77c1fb25b141	7e07497e-be59-442a-82ad-943e3bd502bb	پیشرفت اولیه و بررسی نیازمندی‌ها	225	28	2026-07-16	approved	75bbbdd2-5d00-4257-8e1e-c3881eebcf0e	\N	e4047363-d79b-48ac-8653-dd7fc7239eb2	2026-07-21 12:23:05.653402+00	2026-07-21 12:23:05.653402+00
9e026bc3-66b8-45d7-9c60-0989a6664192	d641559c-4def-4f7b-b322-77c1fb25b141	7e07497e-be59-442a-82ad-943e3bd502bb	تست و اطمینان از عملکرد صحیح	173	78	2026-07-16	approved	75bbbdd2-5d00-4257-8e1e-c3881eebcf0e	\N	f35c6e4c-2e52-4fec-a8c8-5ff9b470aedd	2026-07-21 12:23:05.653402+00	2026-07-21 12:23:05.653402+00
9e026bc3-66b8-45d7-9c60-0989a6664192	d641559c-4def-4f7b-b322-77c1fb25b141	7e07497e-be59-442a-82ad-943e3bd502bb	مستندسازی و نهایی‌سازی	198	84	2026-07-16	approved	75bbbdd2-5d00-4257-8e1e-c3881eebcf0e	\N	25304bd0-0aa3-4311-9d40-71f68de7dd6a	2026-07-21 12:23:05.653402+00	2026-07-21 12:23:05.653402+00
9e026bc3-66b8-45d7-9c60-0989a6664192	fa73c231-65eb-4555-bb00-da4c4bd04300	dbe12768-1ffa-4f9b-8327-4558c4438ef6	رفع اشکالات و بازبینی	209	29	2026-07-16	approved	75bbbdd2-5d00-4257-8e1e-c3881eebcf0e	\N	573ebe96-f655-41b1-9b22-3e4d8da872d6	2026-07-21 12:23:05.653402+00	2026-07-21 12:23:05.653402+00
9e026bc3-66b8-45d7-9c60-0989a6664192	202c1031-0100-4b1a-8741-d9e13ce4f770	8c7cac5d-349c-4d45-ab78-f4e52554d784	پیشرفت اولیه و بررسی نیازمندی‌ها	76	24	2026-06-26	approved	75bbbdd2-5d00-4257-8e1e-c3881eebcf0e	\N	dff4de3b-0a8f-4c29-8705-40b9d6eec462	2026-07-21 12:23:05.653402+00	2026-07-21 12:23:05.653402+00
9e026bc3-66b8-45d7-9c60-0989a6664192	202c1031-0100-4b1a-8741-d9e13ce4f770	8c7cac5d-349c-4d45-ab78-f4e52554d784	پیشرفت اولیه و بررسی نیازمندی‌ها	66	80	2026-06-30	approved	75bbbdd2-5d00-4257-8e1e-c3881eebcf0e	\N	dce87b16-858e-4d23-9165-755e85bd757e	2026-07-21 12:23:05.653402+00	2026-07-21 12:23:05.653402+00
9e026bc3-66b8-45d7-9c60-0989a6664192	202c1031-0100-4b1a-8741-d9e13ce4f770	8c7cac5d-349c-4d45-ab78-f4e52554d784	پیشرفت اولیه و بررسی نیازمندی‌ها	221	100	2026-06-28	approved	75bbbdd2-5d00-4257-8e1e-c3881eebcf0e	\N	32612ff3-7cfc-40b9-af61-97457c0647cf	2026-07-21 12:23:05.653402+00	2026-07-21 12:23:05.653402+00
9e026bc3-66b8-45d7-9c60-0989a6664192	c010a864-7757-4225-87b2-9c4267720de7	8c7cac5d-349c-4d45-ab78-f4e52554d784	تست و اطمینان از عملکرد صحیح	146	30	2026-07-01	approved	75bbbdd2-5d00-4257-8e1e-c3881eebcf0e	\N	e414a07c-4c39-45b1-b335-655b27899b29	2026-07-21 12:23:05.653402+00	2026-07-21 12:23:05.653402+00
9e026bc3-66b8-45d7-9c60-0989a6664192	c010a864-7757-4225-87b2-9c4267720de7	8c7cac5d-349c-4d45-ab78-f4e52554d784	رفع اشکالات و بازبینی	109	60	2026-07-03	approved	75bbbdd2-5d00-4257-8e1e-c3881eebcf0e	\N	6abc59bc-66d6-466a-8764-675ed677fa9d	2026-07-21 12:23:05.653402+00	2026-07-21 12:23:05.653402+00
9e026bc3-66b8-45d7-9c60-0989a6664192	3a793043-2c7f-40f3-9aab-92464b07af1d	24e34af4-1229-4d93-8615-b8479b51a37c	پیاده‌سازی بخش اصلی	70	39	2026-07-16	approved	75bbbdd2-5d00-4257-8e1e-c3881eebcf0e	\N	2a9fa38b-ebd3-4da4-9029-d276fcf96839	2026-07-21 12:23:05.653402+00	2026-07-21 12:23:05.653402+00
9e026bc3-66b8-45d7-9c60-0989a6664192	7e96cc37-bde4-4aa7-92fe-9a38d8d226d2	ad47309d-1c75-4d68-b779-348021512719	رفع اشکالات و بازبینی	143	33	2026-07-16	approved	75bbbdd2-5d00-4257-8e1e-c3881eebcf0e	\N	c1f267c6-9162-4cf3-826c-42d237478275	2026-07-21 12:23:05.653402+00	2026-07-21 12:23:05.653402+00
9e026bc3-66b8-45d7-9c60-0989a6664192	8c6d86a6-09e2-41f4-b858-438331681ac4	8c7cac5d-349c-4d45-ab78-f4e52554d784	تست و اطمینان از عملکرد صحیح	99	26	2026-07-16	approved	75bbbdd2-5d00-4257-8e1e-c3881eebcf0e	\N	8d276d28-8554-43f2-9160-b6f4e2054c82	2026-07-21 12:23:05.653402+00	2026-07-21 12:23:05.653402+00
9e026bc3-66b8-45d7-9c60-0989a6664192	8c6d86a6-09e2-41f4-b858-438331681ac4	8c7cac5d-349c-4d45-ab78-f4e52554d784	رفع اشکالات و بازبینی	140	46	2026-07-16	approved	75bbbdd2-5d00-4257-8e1e-c3881eebcf0e	\N	eb56c3b1-7b9d-4a31-8fdd-17a92ef51bec	2026-07-21 12:23:05.653402+00	2026-07-21 12:23:05.653402+00
9e026bc3-66b8-45d7-9c60-0989a6664192	8c6d86a6-09e2-41f4-b858-438331681ac4	8c7cac5d-349c-4d45-ab78-f4e52554d784	مستندسازی و نهایی‌سازی	154	100	2026-07-16	approved	75bbbdd2-5d00-4257-8e1e-c3881eebcf0e	\N	79d16477-57f6-45ec-ab04-3db56472989d	2026-07-21 12:23:05.653402+00	2026-07-21 12:23:05.653402+00
9e026bc3-66b8-45d7-9c60-0989a6664192	8c6d86a6-09e2-41f4-b858-438331681ac4	8c7cac5d-349c-4d45-ab78-f4e52554d784	پیشرفت اولیه و بررسی نیازمندی‌ها	86	100	2026-07-16	approved	75bbbdd2-5d00-4257-8e1e-c3881eebcf0e	\N	1d8437a4-a79b-4afc-b491-8b74b956c913	2026-07-21 12:23:05.653402+00	2026-07-21 12:23:05.653402+00
9e026bc3-66b8-45d7-9c60-0989a6664192	6658675d-6e5e-44d9-a9f2-c02c5b5ef91b	ad47309d-1c75-4d68-b779-348021512719	پیاده‌سازی بخش اصلی	107	26	2026-07-16	approved	75bbbdd2-5d00-4257-8e1e-c3881eebcf0e	\N	4410c83f-fb52-4adf-b9a8-4da98406096b	2026-07-21 12:23:05.653402+00	2026-07-21 12:23:05.653402+00
9e026bc3-66b8-45d7-9c60-0989a6664192	605e2165-503a-44f0-95df-47ecbc2ebe2f	7e07497e-be59-442a-82ad-943e3bd502bb	رفع اشکالات و بازبینی	113	23	2026-07-01	approved	75bbbdd2-5d00-4257-8e1e-c3881eebcf0e	\N	ad25cefe-e817-44c8-8e75-31664566c20d	2026-07-21 12:23:05.653402+00	2026-07-21 12:23:05.653402+00
9e026bc3-66b8-45d7-9c60-0989a6664192	605e2165-503a-44f0-95df-47ecbc2ebe2f	7e07497e-be59-442a-82ad-943e3bd502bb	تست و اطمینان از عملکرد صحیح	221	66	2026-07-02	approved	75bbbdd2-5d00-4257-8e1e-c3881eebcf0e	\N	a2fd863f-a19f-4289-b367-302a2775ceba	2026-07-21 12:23:05.653402+00	2026-07-21 12:23:05.653402+00
9e026bc3-66b8-45d7-9c60-0989a6664192	f5379e51-f275-4add-9f47-16fb603d75a7	24e34af4-1229-4d93-8615-b8479b51a37c	پیاده‌سازی بخش اصلی	158	37	2026-07-14	approved	75bbbdd2-5d00-4257-8e1e-c3881eebcf0e	\N	ff8ddc10-5b6d-40f4-881f-82f723b16ecf	2026-07-21 12:23:05.653402+00	2026-07-21 12:23:05.653402+00
9e026bc3-66b8-45d7-9c60-0989a6664192	f5379e51-f275-4add-9f47-16fb603d75a7	24e34af4-1229-4d93-8615-b8479b51a37c	پیشرفت اولیه و بررسی نیازمندی‌ها	141	40	2026-07-16	approved	75bbbdd2-5d00-4257-8e1e-c3881eebcf0e	\N	36b93474-1d4d-4866-a2a5-b9012b058dc7	2026-07-21 12:23:05.653402+00	2026-07-21 12:23:05.653402+00
9e026bc3-66b8-45d7-9c60-0989a6664192	75d0eda8-cd6a-4f07-8bc2-9af476a84a59	dbe12768-1ffa-4f9b-8327-4558c4438ef6	رفع اشکالات و بازبینی	177	33	2026-06-25	approved	75bbbdd2-5d00-4257-8e1e-c3881eebcf0e	\N	6b2088ac-46d7-4c0b-b4e7-7c32e72b28cb	2026-07-21 12:23:05.653402+00	2026-07-21 12:23:05.653402+00
9e026bc3-66b8-45d7-9c60-0989a6664192	75d0eda8-cd6a-4f07-8bc2-9af476a84a59	dbe12768-1ffa-4f9b-8327-4558c4438ef6	تست و اطمینان از عملکرد صحیح	104	46	2026-06-29	approved	75bbbdd2-5d00-4257-8e1e-c3881eebcf0e	\N	788ad16b-c5a6-4fff-938a-40a51584a3a3	2026-07-21 12:23:05.653402+00	2026-07-21 12:23:05.653402+00
9e026bc3-66b8-45d7-9c60-0989a6664192	75d0eda8-cd6a-4f07-8bc2-9af476a84a59	dbe12768-1ffa-4f9b-8327-4558c4438ef6	پیشرفت اولیه و بررسی نیازمندی‌ها	113	75	2026-07-03	approved	75bbbdd2-5d00-4257-8e1e-c3881eebcf0e	\N	ba42862b-c620-48ea-9a29-d9225b3478a2	2026-07-21 12:23:05.653402+00	2026-07-21 12:23:05.653402+00
9e026bc3-66b8-45d7-9c60-0989a6664192	75d0eda8-cd6a-4f07-8bc2-9af476a84a59	dbe12768-1ffa-4f9b-8327-4558c4438ef6	رفع اشکالات و بازبینی	52	100	2026-07-07	approved	75bbbdd2-5d00-4257-8e1e-c3881eebcf0e	\N	118741fa-c8c0-4436-82fb-1f83e7bf9b37	2026-07-21 12:23:05.653402+00	2026-07-21 12:23:05.653402+00
9e026bc3-66b8-45d7-9c60-0989a6664192	caae0cab-5b97-48df-8e2f-b328fdb2f89f	24e34af4-1229-4d93-8615-b8479b51a37c	تست و اطمینان از عملکرد صحیح	164	22	2026-07-10	approved	75bbbdd2-5d00-4257-8e1e-c3881eebcf0e	\N	96417269-af4c-447c-858a-eb29e2ca72f0	2026-07-21 12:23:05.653402+00	2026-07-21 12:23:05.653402+00
9e026bc3-66b8-45d7-9c60-0989a6664192	904931d4-970e-4cfd-971c-a3587d0b0141	75bbbdd2-5d00-4257-8e1e-c3881eebcf0e	پیاده‌سازی بخش اصلی	115	25	2026-07-05	submitted	\N	\N	965dbd0d-4e34-4c2b-b139-a764291efed3	2026-07-21 12:23:05.653402+00	2026-07-21 12:23:05.653402+00
9e026bc3-66b8-45d7-9c60-0989a6664192	904931d4-970e-4cfd-971c-a3587d0b0141	75bbbdd2-5d00-4257-8e1e-c3881eebcf0e	پیشرفت اولیه و بررسی نیازمندی‌ها	165	72	2026-07-06	approved	75bbbdd2-5d00-4257-8e1e-c3881eebcf0e	\N	ffb18d9a-d25d-459a-9dc5-ef2973a6ea2e	2026-07-21 12:23:05.653402+00	2026-07-21 12:23:05.653402+00
9e026bc3-66b8-45d7-9c60-0989a6664192	904931d4-970e-4cfd-971c-a3587d0b0141	75bbbdd2-5d00-4257-8e1e-c3881eebcf0e	رفع اشکالات و بازبینی	119	100	2026-07-09	submitted	\N	\N	6c44851e-ed3e-4fcf-b5ab-fc6ca2cc6ca7	2026-07-21 12:23:05.653402+00	2026-07-21 12:23:05.653402+00
9e026bc3-66b8-45d7-9c60-0989a6664192	904931d4-970e-4cfd-971c-a3587d0b0141	75bbbdd2-5d00-4257-8e1e-c3881eebcf0e	پیاده‌سازی بخش اصلی	95	100	2026-07-11	approved	75bbbdd2-5d00-4257-8e1e-c3881eebcf0e	\N	c014ea2c-5a1f-4f24-9700-6eae6a804358	2026-07-21 12:23:05.653402+00	2026-07-21 12:23:05.653402+00
9e026bc3-66b8-45d7-9c60-0989a6664192	8f470eac-bc9f-4435-84c1-a2b34feb3123	6b87e773-3d93-47db-8dc6-37ca0e6e9b32	پیشرفت اولیه و بررسی نیازمندی‌ها	75	40	2026-07-16	approved	75bbbdd2-5d00-4257-8e1e-c3881eebcf0e	\N	1c1ef348-41ee-46f1-974f-b17c56253522	2026-07-21 12:23:05.653402+00	2026-07-21 12:23:05.653402+00
9e026bc3-66b8-45d7-9c60-0989a6664192	8f470eac-bc9f-4435-84c1-a2b34feb3123	6b87e773-3d93-47db-8dc6-37ca0e6e9b32	تست و اطمینان از عملکرد صحیح	223	76	2026-07-16	approved	75bbbdd2-5d00-4257-8e1e-c3881eebcf0e	\N	16034987-00c4-4919-91ad-a54265a908f3	2026-07-21 12:23:05.653402+00	2026-07-21 12:23:05.653402+00
9e026bc3-66b8-45d7-9c60-0989a6664192	aa2bf9a3-c5bf-4915-b090-18dc2d4b57ae	7e07497e-be59-442a-82ad-943e3bd502bb	رفع اشکالات و بازبینی	68	34	2026-07-16	submitted	\N	\N	b2719952-3930-4c9a-b806-8d311a0b7ec1	2026-07-21 12:23:05.653402+00	2026-07-21 12:23:05.653402+00
9e026bc3-66b8-45d7-9c60-0989a6664192	aa2bf9a3-c5bf-4915-b090-18dc2d4b57ae	7e07497e-be59-442a-82ad-943e3bd502bb	رفع اشکالات و بازبینی	233	56	2026-07-16	approved	75bbbdd2-5d00-4257-8e1e-c3881eebcf0e	\N	0fd271b0-3d70-4714-9720-4f19cb05a74b	2026-07-21 12:23:05.653402+00	2026-07-21 12:23:05.653402+00
9e026bc3-66b8-45d7-9c60-0989a6664192	aa2bf9a3-c5bf-4915-b090-18dc2d4b57ae	7e07497e-be59-442a-82ad-943e3bd502bb	پیشرفت اولیه و بررسی نیازمندی‌ها	109	100	2026-07-16	approved	75bbbdd2-5d00-4257-8e1e-c3881eebcf0e	\N	ee7ee42d-cd1c-4fee-a1c4-613f6baa2222	2026-07-21 12:23:05.653402+00	2026-07-21 12:23:05.653402+00
9e026bc3-66b8-45d7-9c60-0989a6664192	aa2bf9a3-c5bf-4915-b090-18dc2d4b57ae	7e07497e-be59-442a-82ad-943e3bd502bb	رفع اشکالات و بازبینی	103	88	2026-07-16	approved	75bbbdd2-5d00-4257-8e1e-c3881eebcf0e	\N	e7e210c8-5d5d-41e2-829b-60e352bfde37	2026-07-21 12:23:05.653402+00	2026-07-21 12:23:05.653402+00
9e026bc3-66b8-45d7-9c60-0989a6664192	573f9798-9939-452e-b67f-5cf2f2f34bfe	6b87e773-3d93-47db-8dc6-37ca0e6e9b32	تست و اطمینان از عملکرد صحیح	178	37	2026-07-11	approved	75bbbdd2-5d00-4257-8e1e-c3881eebcf0e	\N	6244b4ac-57d5-48d5-acfd-ec542295dbf0	2026-07-21 12:23:05.653402+00	2026-07-21 12:23:05.653402+00
9e026bc3-66b8-45d7-9c60-0989a6664192	caab8809-28dd-43ed-af2f-cc00720fb37f	ad47309d-1c75-4d68-b779-348021512719	مستندسازی و نهایی‌سازی	196	26	2026-06-24	submitted	\N	\N	4116dc31-3614-4e21-a8be-472f11f8df4f	2026-07-21 12:23:05.653402+00	2026-07-21 12:23:05.653402+00
9e026bc3-66b8-45d7-9c60-0989a6664192	b23c3f20-b6af-4df0-a3ad-8a91ba1d6ccf	24e34af4-1229-4d93-8615-b8479b51a37c	مستندسازی و نهایی‌سازی	68	21	2026-07-16	approved	75bbbdd2-5d00-4257-8e1e-c3881eebcf0e	\N	8452c9a9-92de-4135-8206-9c45dc02e8f6	2026-07-21 12:23:05.653402+00	2026-07-21 12:23:05.653402+00
9e026bc3-66b8-45d7-9c60-0989a6664192	b23c3f20-b6af-4df0-a3ad-8a91ba1d6ccf	24e34af4-1229-4d93-8615-b8479b51a37c	پیشرفت اولیه و بررسی نیازمندی‌ها	237	60	2026-07-16	approved	75bbbdd2-5d00-4257-8e1e-c3881eebcf0e	\N	976e9ac8-28fb-496a-92ba-6239b48ce27c	2026-07-21 12:23:05.653402+00	2026-07-21 12:23:05.653402+00
9e026bc3-66b8-45d7-9c60-0989a6664192	b23c3f20-b6af-4df0-a3ad-8a91ba1d6ccf	24e34af4-1229-4d93-8615-b8479b51a37c	مستندسازی و نهایی‌سازی	195	75	2026-07-16	approved	75bbbdd2-5d00-4257-8e1e-c3881eebcf0e	\N	a4781305-df6a-4b77-ba55-432e0f3eba62	2026-07-21 12:23:05.653402+00	2026-07-21 12:23:05.653402+00
9e026bc3-66b8-45d7-9c60-0989a6664192	83a6b329-8e08-4ed4-ba6a-99ae5f9b2134	75bbbdd2-5d00-4257-8e1e-c3881eebcf0e	تست و اطمینان از عملکرد صحیح	142	36	2026-07-16	approved	75bbbdd2-5d00-4257-8e1e-c3881eebcf0e	\N	a9f5ffaa-a1d8-4d7c-8957-204027072311	2026-07-21 12:23:05.653402+00	2026-07-21 12:23:05.653402+00
9e026bc3-66b8-45d7-9c60-0989a6664192	6394419d-c2f7-41ad-b6ba-8578d527971a	8c7cac5d-349c-4d45-ab78-f4e52554d784	رفع اشکالات و بازبینی	102	32	2026-06-17	approved	75bbbdd2-5d00-4257-8e1e-c3881eebcf0e	\N	a5645569-5ddb-487b-afea-c2334276c534	2026-07-21 12:23:05.653402+00	2026-07-21 12:23:05.653402+00
9e026bc3-66b8-45d7-9c60-0989a6664192	6394419d-c2f7-41ad-b6ba-8578d527971a	8c7cac5d-349c-4d45-ab78-f4e52554d784	رفع اشکالات و بازبینی	203	78	2026-06-21	approved	75bbbdd2-5d00-4257-8e1e-c3881eebcf0e	\N	23460104-d4ab-4ce5-85a0-83a7736ce9aa	2026-07-21 12:23:05.653402+00	2026-07-21 12:23:05.653402+00
9e026bc3-66b8-45d7-9c60-0989a6664192	d89a3200-42ec-42cf-9207-85c492a7fb3b	8c7cac5d-349c-4d45-ab78-f4e52554d784	پیشرفت اولیه و بررسی نیازمندی‌ها	172	32	2026-06-26	approved	75bbbdd2-5d00-4257-8e1e-c3881eebcf0e	\N	b07ea97c-863d-48a2-be24-7cc72a6b774c	2026-07-21 12:23:05.653402+00	2026-07-21 12:23:05.653402+00
9e026bc3-66b8-45d7-9c60-0989a6664192	d2e91ab2-e992-456d-8980-57db142a4dbc	24e34af4-1229-4d93-8615-b8479b51a37c	مستندسازی و نهایی‌سازی	68	30	2026-06-22	submitted	\N	\N	43ecf605-0509-4f11-9769-f9958daa6c97	2026-07-21 12:23:05.653402+00	2026-07-21 12:23:05.653402+00
9e026bc3-66b8-45d7-9c60-0989a6664192	d2e91ab2-e992-456d-8980-57db142a4dbc	24e34af4-1229-4d93-8615-b8479b51a37c	پیاده‌سازی بخش اصلی	119	58	2026-06-23	approved	75bbbdd2-5d00-4257-8e1e-c3881eebcf0e	\N	bb642507-f8b2-41ed-8578-8732daf2294e	2026-07-21 12:23:05.653402+00	2026-07-21 12:23:05.653402+00
9e026bc3-66b8-45d7-9c60-0989a6664192	d2e91ab2-e992-456d-8980-57db142a4dbc	24e34af4-1229-4d93-8615-b8479b51a37c	پیشرفت اولیه و بررسی نیازمندی‌ها	109	100	2026-06-30	approved	75bbbdd2-5d00-4257-8e1e-c3881eebcf0e	\N	d3c21cd8-c57d-4fe8-b9a2-12fe3818b95e	2026-07-21 12:23:05.653402+00	2026-07-21 12:23:05.653402+00
9e026bc3-66b8-45d7-9c60-0989a6664192	cc210f84-19b6-4d21-8a7c-1a7351ce6d8c	7e07497e-be59-442a-82ad-943e3bd502bb	مستندسازی و نهایی‌سازی	53	40	2026-07-16	submitted	\N	\N	fd1e217f-350b-472d-a2c0-e3cae9067376	2026-07-21 12:23:05.653402+00	2026-07-21 12:23:05.653402+00
9e026bc3-66b8-45d7-9c60-0989a6664192	cc210f84-19b6-4d21-8a7c-1a7351ce6d8c	7e07497e-be59-442a-82ad-943e3bd502bb	پیشرفت اولیه و بررسی نیازمندی‌ها	122	58	2026-07-16	approved	75bbbdd2-5d00-4257-8e1e-c3881eebcf0e	\N	5edd9e43-1491-4373-803a-adb2ba95d38c	2026-07-21 12:23:05.653402+00	2026-07-21 12:23:05.653402+00
9e026bc3-66b8-45d7-9c60-0989a6664192	cc210f84-19b6-4d21-8a7c-1a7351ce6d8c	7e07497e-be59-442a-82ad-943e3bd502bb	رفع اشکالات و بازبینی	226	100	2026-07-16	submitted	\N	\N	2be8bdf4-4d6d-4322-870d-859d28f6c4db	2026-07-21 12:23:05.653402+00	2026-07-21 12:23:05.653402+00
9e026bc3-66b8-45d7-9c60-0989a6664192	cc210f84-19b6-4d21-8a7c-1a7351ce6d8c	7e07497e-be59-442a-82ad-943e3bd502bb	پیاده‌سازی بخش اصلی	69	88	2026-07-16	approved	75bbbdd2-5d00-4257-8e1e-c3881eebcf0e	\N	1b208d55-1cae-449d-adab-e3b225e77590	2026-07-21 12:23:05.653402+00	2026-07-21 12:23:05.653402+00
9e026bc3-66b8-45d7-9c60-0989a6664192	7dd88521-12aa-4744-b328-5a8ad2308a7a	ad47309d-1c75-4d68-b779-348021512719	مستندسازی و نهایی‌سازی	227	37	2026-07-05	approved	75bbbdd2-5d00-4257-8e1e-c3881eebcf0e	\N	46f9194a-ed9a-4dd6-b65d-8dd2b9fdb7f0	2026-07-21 12:23:05.653402+00	2026-07-21 12:23:05.653402+00
9e026bc3-66b8-45d7-9c60-0989a6664192	7dd88521-12aa-4744-b328-5a8ad2308a7a	ad47309d-1c75-4d68-b779-348021512719	رفع اشکالات و بازبینی	226	78	2026-07-06	approved	75bbbdd2-5d00-4257-8e1e-c3881eebcf0e	\N	db9e8769-fcad-4713-b0b0-a5e3f1e51e43	2026-07-21 12:23:05.653402+00	2026-07-21 12:23:05.653402+00
9e026bc3-66b8-45d7-9c60-0989a6664192	7dd88521-12aa-4744-b328-5a8ad2308a7a	ad47309d-1c75-4d68-b779-348021512719	مستندسازی و نهایی‌سازی	126	72	2026-07-09	approved	75bbbdd2-5d00-4257-8e1e-c3881eebcf0e	\N	3ea7db57-add1-4bd9-a61f-decefe197581	2026-07-21 12:23:05.653402+00	2026-07-21 12:23:05.653402+00
9e026bc3-66b8-45d7-9c60-0989a6664192	8e5bfb9e-46e7-4828-9ad5-926a91d62b17	dbe12768-1ffa-4f9b-8327-4558c4438ef6	مستندسازی و نهایی‌سازی	237	25	2026-07-09	approved	75bbbdd2-5d00-4257-8e1e-c3881eebcf0e	\N	32948406-433a-4311-a840-04c839870f40	2026-07-21 12:23:05.653402+00	2026-07-21 12:23:05.653402+00
9e026bc3-66b8-45d7-9c60-0989a6664192	8e5bfb9e-46e7-4828-9ad5-926a91d62b17	dbe12768-1ffa-4f9b-8327-4558c4438ef6	پیشرفت اولیه و بررسی نیازمندی‌ها	135	62	2026-07-13	approved	75bbbdd2-5d00-4257-8e1e-c3881eebcf0e	\N	17617009-e579-44c0-99b1-b5da13492773	2026-07-21 12:23:05.653402+00	2026-07-21 12:23:05.653402+00
9e026bc3-66b8-45d7-9c60-0989a6664192	2750b4df-e693-4abc-8cc5-d51b778f79f4	8c7cac5d-349c-4d45-ab78-f4e52554d784	تست و اطمینان از عملکرد صحیح	89	37	2026-07-16	approved	75bbbdd2-5d00-4257-8e1e-c3881eebcf0e	\N	f4d28572-1855-49bd-a396-891c5300bc01	2026-07-21 12:23:05.653402+00	2026-07-21 12:23:05.653402+00
9e026bc3-66b8-45d7-9c60-0989a6664192	2750b4df-e693-4abc-8cc5-d51b778f79f4	8c7cac5d-349c-4d45-ab78-f4e52554d784	تست و اطمینان از عملکرد صحیح	79	62	2026-07-16	approved	75bbbdd2-5d00-4257-8e1e-c3881eebcf0e	\N	c5198cd7-33d7-474b-83f8-566227b09104	2026-07-21 12:23:05.653402+00	2026-07-21 12:23:05.653402+00
9e026bc3-66b8-45d7-9c60-0989a6664192	8074f30e-8be8-4973-9700-120faedfe782	8c7cac5d-349c-4d45-ab78-f4e52554d784	رفع اشکالات و بازبینی	229	32	2026-07-13	approved	75bbbdd2-5d00-4257-8e1e-c3881eebcf0e	\N	b360e215-6e6b-467e-bc19-ed66a09f70ca	2026-07-21 12:23:05.653402+00	2026-07-21 12:23:05.653402+00
9e026bc3-66b8-45d7-9c60-0989a6664192	8074f30e-8be8-4973-9700-120faedfe782	8c7cac5d-349c-4d45-ab78-f4e52554d784	پیاده‌سازی بخش اصلی	239	52	2026-07-16	approved	75bbbdd2-5d00-4257-8e1e-c3881eebcf0e	\N	249cf525-8883-456a-ad00-5847febf412e	2026-07-21 12:23:05.653402+00	2026-07-21 12:23:05.653402+00
9e026bc3-66b8-45d7-9c60-0989a6664192	8074f30e-8be8-4973-9700-120faedfe782	8c7cac5d-349c-4d45-ab78-f4e52554d784	رفع اشکالات و بازبینی	43	100	2026-07-16	approved	75bbbdd2-5d00-4257-8e1e-c3881eebcf0e	\N	370d3cc3-58ac-4bc0-b19c-7760b0fcf362	2026-07-21 12:23:05.653402+00	2026-07-21 12:23:05.653402+00
9e026bc3-66b8-45d7-9c60-0989a6664192	8074f30e-8be8-4973-9700-120faedfe782	8c7cac5d-349c-4d45-ab78-f4e52554d784	رفع اشکالات و بازبینی	171	92	2026-07-16	approved	75bbbdd2-5d00-4257-8e1e-c3881eebcf0e	\N	210fbc98-bbe3-47ca-b0e3-f431332409b9	2026-07-21 12:23:05.653402+00	2026-07-21 12:23:05.653402+00
9e026bc3-66b8-45d7-9c60-0989a6664192	38693f0f-c6c2-42d1-8d78-723108c9b407	dbe12768-1ffa-4f9b-8327-4558c4438ef6	پیشرفت اولیه و بررسی نیازمندی‌ها	225	25	2026-07-16	approved	75bbbdd2-5d00-4257-8e1e-c3881eebcf0e	\N	851dcee8-e02f-43e0-9ca5-fd65291a1041	2026-07-21 12:23:05.653402+00	2026-07-21 12:23:05.653402+00
9e026bc3-66b8-45d7-9c60-0989a6664192	f26a8423-9378-4555-8bb1-527e179ca942	6b87e773-3d93-47db-8dc6-37ca0e6e9b32	پیاده‌سازی بخش اصلی	141	22	2026-07-06	submitted	\N	\N	faad7324-2c02-4809-876c-e7a3f5f9b543	2026-07-21 12:23:05.653402+00	2026-07-21 12:23:05.653402+00
9e026bc3-66b8-45d7-9c60-0989a6664192	f26a8423-9378-4555-8bb1-527e179ca942	6b87e773-3d93-47db-8dc6-37ca0e6e9b32	رفع اشکالات و بازبینی	36	66	2026-07-08	submitted	\N	\N	73b3f808-b809-4c07-8bef-2d2430dc2b85	2026-07-21 12:23:05.653402+00	2026-07-21 12:23:05.653402+00
9e026bc3-66b8-45d7-9c60-0989a6664192	f26a8423-9378-4555-8bb1-527e179ca942	6b87e773-3d93-47db-8dc6-37ca0e6e9b32	رفع اشکالات و بازبینی	90	96	2026-07-08	approved	75bbbdd2-5d00-4257-8e1e-c3881eebcf0e	\N	9f34952d-ad43-43af-945b-c73d7373746b	2026-07-21 12:23:05.653402+00	2026-07-21 12:23:05.653402+00
9e026bc3-66b8-45d7-9c60-0989a6664192	389295d0-2c85-47e2-ad6e-0cc4a1b43942	24e34af4-1229-4d93-8615-b8479b51a37c	پیاده‌سازی بخش اصلی	37	30	2026-07-15	approved	75bbbdd2-5d00-4257-8e1e-c3881eebcf0e	\N	0c366c33-3dbe-49f5-ad97-97b87748d2ce	2026-07-21 12:23:05.653402+00	2026-07-21 12:23:05.653402+00
9e026bc3-66b8-45d7-9c60-0989a6664192	6c65e795-ea72-483f-9a50-2b23137ec837	7e07497e-be59-442a-82ad-943e3bd502bb	پیاده‌سازی بخش اصلی	39	29	2026-06-27	submitted	\N	\N	3b72e706-4e3b-457f-8b74-d3447ced25d3	2026-07-21 12:23:05.653402+00	2026-07-21 12:23:05.653402+00
9e026bc3-66b8-45d7-9c60-0989a6664192	31767b9d-e552-4025-8d14-f63fa0842a97	6b87e773-3d93-47db-8dc6-37ca0e6e9b32	تست و اطمینان از عملکرد صحیح	144	39	2026-07-16	approved	75bbbdd2-5d00-4257-8e1e-c3881eebcf0e	\N	ea7019ac-e550-46c0-99ea-eac03fba1188	2026-07-21 12:23:05.653402+00	2026-07-21 12:23:05.653402+00
9e026bc3-66b8-45d7-9c60-0989a6664192	31767b9d-e552-4025-8d14-f63fa0842a97	6b87e773-3d93-47db-8dc6-37ca0e6e9b32	پیشرفت اولیه و بررسی نیازمندی‌ها	34	56	2026-07-16	approved	75bbbdd2-5d00-4257-8e1e-c3881eebcf0e	\N	7b6c18f8-2d38-4945-9a17-020c0a8215b5	2026-07-21 12:23:05.653402+00	2026-07-21 12:23:05.653402+00
9e026bc3-66b8-45d7-9c60-0989a6664192	31767b9d-e552-4025-8d14-f63fa0842a97	6b87e773-3d93-47db-8dc6-37ca0e6e9b32	پیاده‌سازی بخش اصلی	170	100	2026-07-16	approved	75bbbdd2-5d00-4257-8e1e-c3881eebcf0e	\N	eb97bb30-062d-4a51-bd5b-d3b5c963c16b	2026-07-21 12:23:05.653402+00	2026-07-21 12:23:05.653402+00
9e026bc3-66b8-45d7-9c60-0989a6664192	31767b9d-e552-4025-8d14-f63fa0842a97	6b87e773-3d93-47db-8dc6-37ca0e6e9b32	پیشرفت اولیه و بررسی نیازمندی‌ها	228	100	2026-07-16	approved	75bbbdd2-5d00-4257-8e1e-c3881eebcf0e	\N	1a3ce99d-95d0-433e-8823-7cb94269e664	2026-07-21 12:23:05.653402+00	2026-07-21 12:23:05.653402+00
9e026bc3-66b8-45d7-9c60-0989a6664192	2c25ae79-aad0-4e34-88fe-c705e6b25212	ad47309d-1c75-4d68-b779-348021512719	پیاده‌سازی بخش اصلی	137	40	2026-07-16	approved	75bbbdd2-5d00-4257-8e1e-c3881eebcf0e	\N	5a8e8cdc-b0a9-4500-8318-296a7e6bb4ff	2026-07-21 12:23:05.653402+00	2026-07-21 12:23:05.653402+00
9e026bc3-66b8-45d7-9c60-0989a6664192	2c25ae79-aad0-4e34-88fe-c705e6b25212	ad47309d-1c75-4d68-b779-348021512719	تست و اطمینان از عملکرد صحیح	182	74	2026-07-16	approved	75bbbdd2-5d00-4257-8e1e-c3881eebcf0e	\N	6830efa8-cc1a-4b68-92b4-cf93701daa0b	2026-07-21 12:23:05.653402+00	2026-07-21 12:23:05.653402+00
9e026bc3-66b8-45d7-9c60-0989a6664192	29e2314a-b31d-44b6-add5-52ac5e3924eb	7e07497e-be59-442a-82ad-943e3bd502bb	پیاده‌سازی بخش اصلی	104	33	2026-06-21	approved	75bbbdd2-5d00-4257-8e1e-c3881eebcf0e	\N	1aede2c1-a108-4ea0-a0dd-411e2f5f0649	2026-07-21 12:23:05.653402+00	2026-07-21 12:23:05.653402+00
9e026bc3-66b8-45d7-9c60-0989a6664192	de54e3e2-8df2-4239-b9af-441648df6f6b	6965fa45-fddb-4465-b0e6-042192ac6ee2	مستندسازی و نهایی‌سازی	196	31	2026-06-27	approved	0aa7f564-65bd-473d-aa0e-3abc4663b507	\N	84fe79d0-b153-4cd1-9bed-d9f6f815371e	2026-07-21 12:23:05.653402+00	2026-07-21 12:23:05.653402+00
9e026bc3-66b8-45d7-9c60-0989a6664192	de54e3e2-8df2-4239-b9af-441648df6f6b	6965fa45-fddb-4465-b0e6-042192ac6ee2	رفع اشکالات و بازبینی	122	72	2026-06-30	approved	0aa7f564-65bd-473d-aa0e-3abc4663b507	\N	9f58b143-96c9-4a4e-8fbe-15d8f611e170	2026-07-21 12:23:05.653402+00	2026-07-21 12:23:05.653402+00
9e026bc3-66b8-45d7-9c60-0989a6664192	de54e3e2-8df2-4239-b9af-441648df6f6b	6965fa45-fddb-4465-b0e6-042192ac6ee2	تست و اطمینان از عملکرد صحیح	55	100	2026-07-05	approved	0aa7f564-65bd-473d-aa0e-3abc4663b507	\N	446b84b3-a19d-47a0-94b5-856572f81a8a	2026-07-21 12:23:05.653402+00	2026-07-21 12:23:05.653402+00
9e026bc3-66b8-45d7-9c60-0989a6664192	de54e3e2-8df2-4239-b9af-441648df6f6b	6965fa45-fddb-4465-b0e6-042192ac6ee2	پیاده‌سازی بخش اصلی	124	100	2026-07-06	approved	0aa7f564-65bd-473d-aa0e-3abc4663b507	\N	36dd52e1-9165-445a-a48a-47cff4eeb6ad	2026-07-21 12:23:05.653402+00	2026-07-21 12:23:05.653402+00
9e026bc3-66b8-45d7-9c60-0989a6664192	1375b177-1755-4d17-90ad-d6f5ad349196	e5c268f5-5274-4960-be2b-6f7bbba26625	مستندسازی و نهایی‌سازی	86	24	2026-07-14	approved	0aa7f564-65bd-473d-aa0e-3abc4663b507	\N	1d63f985-0cb0-4c56-9ecb-19f1dd49d351	2026-07-21 12:23:05.653402+00	2026-07-21 12:23:05.653402+00
9e026bc3-66b8-45d7-9c60-0989a6664192	1375b177-1755-4d17-90ad-d6f5ad349196	e5c268f5-5274-4960-be2b-6f7bbba26625	رفع اشکالات و بازبینی	171	76	2026-07-15	approved	0aa7f564-65bd-473d-aa0e-3abc4663b507	\N	7913e18c-6b87-4109-93cd-c4d28f36eb44	2026-07-21 12:23:05.653402+00	2026-07-21 12:23:05.653402+00
9e026bc3-66b8-45d7-9c60-0989a6664192	1375b177-1755-4d17-90ad-d6f5ad349196	e5c268f5-5274-4960-be2b-6f7bbba26625	رفع اشکالات و بازبینی	69	78	2026-07-16	approved	0aa7f564-65bd-473d-aa0e-3abc4663b507	\N	5372d938-145d-48b2-b6ba-2b8807e7273b	2026-07-21 12:23:05.653402+00	2026-07-21 12:23:05.653402+00
9e026bc3-66b8-45d7-9c60-0989a6664192	1375b177-1755-4d17-90ad-d6f5ad349196	e5c268f5-5274-4960-be2b-6f7bbba26625	پیاده‌سازی بخش اصلی	127	100	2026-07-16	approved	0aa7f564-65bd-473d-aa0e-3abc4663b507	\N	d87e6884-80fb-44b6-9ce3-89ad7045e392	2026-07-21 12:23:05.653402+00	2026-07-21 12:23:05.653402+00
9e026bc3-66b8-45d7-9c60-0989a6664192	b4fb2566-a13b-4657-9d57-e5e96cde6967	6965fa45-fddb-4465-b0e6-042192ac6ee2	رفع اشکالات و بازبینی	95	35	2026-07-14	approved	0aa7f564-65bd-473d-aa0e-3abc4663b507	\N	a3a8193a-2fdd-4e13-a62c-0926065a9991	2026-07-21 12:23:05.653402+00	2026-07-21 12:23:05.653402+00
9e026bc3-66b8-45d7-9c60-0989a6664192	b4fb2566-a13b-4657-9d57-e5e96cde6967	6965fa45-fddb-4465-b0e6-042192ac6ee2	رفع اشکالات و بازبینی	73	48	2026-07-16	approved	0aa7f564-65bd-473d-aa0e-3abc4663b507	\N	89a50e2a-e058-446e-8db0-bd2c237c2d38	2026-07-21 12:23:05.653402+00	2026-07-21 12:23:05.653402+00
9e026bc3-66b8-45d7-9c60-0989a6664192	01b49f0a-27c9-4415-8fbb-3eb8037f4ea1	e5c268f5-5274-4960-be2b-6f7bbba26625	مستندسازی و نهایی‌سازی	194	21	2026-07-16	approved	0aa7f564-65bd-473d-aa0e-3abc4663b507	\N	f0a67f57-a3e2-4015-9034-b92dd2c8e426	2026-07-21 12:23:05.653402+00	2026-07-21 12:23:05.653402+00
9e026bc3-66b8-45d7-9c60-0989a6664192	01b49f0a-27c9-4415-8fbb-3eb8037f4ea1	e5c268f5-5274-4960-be2b-6f7bbba26625	پیشرفت اولیه و بررسی نیازمندی‌ها	239	42	2026-07-16	approved	0aa7f564-65bd-473d-aa0e-3abc4663b507	\N	09a6a1f5-ce1c-403f-be67-95929260d911	2026-07-21 12:23:05.653402+00	2026-07-21 12:23:05.653402+00
9e026bc3-66b8-45d7-9c60-0989a6664192	01b49f0a-27c9-4415-8fbb-3eb8037f4ea1	e5c268f5-5274-4960-be2b-6f7bbba26625	تست و اطمینان از عملکرد صحیح	65	100	2026-07-16	approved	0aa7f564-65bd-473d-aa0e-3abc4663b507	\N	fd10c363-8d09-4109-b2b0-7b4d9d339539	2026-07-21 12:23:05.653402+00	2026-07-21 12:23:05.653402+00
9e026bc3-66b8-45d7-9c60-0989a6664192	01b49f0a-27c9-4415-8fbb-3eb8037f4ea1	e5c268f5-5274-4960-be2b-6f7bbba26625	پیشرفت اولیه و بررسی نیازمندی‌ها	211	96	2026-07-16	approved	0aa7f564-65bd-473d-aa0e-3abc4663b507	\N	44cb4a8f-2b5c-4f34-b319-e2c7366494dd	2026-07-21 12:23:05.653402+00	2026-07-21 12:23:05.653402+00
9e026bc3-66b8-45d7-9c60-0989a6664192	6be26401-c944-43d3-8423-c443f370f585	e5c268f5-5274-4960-be2b-6f7bbba26625	مستندسازی و نهایی‌سازی	146	31	2026-07-16	approved	0aa7f564-65bd-473d-aa0e-3abc4663b507	\N	31657b56-0662-4816-a8e5-64197ae9d922	2026-07-21 12:23:05.653402+00	2026-07-21 12:23:05.653402+00
9e026bc3-66b8-45d7-9c60-0989a6664192	0b8d2dbd-2a68-4bcf-a25d-f82d746c35df	147770ac-f6f9-4af1-97c3-cccc614d44e9	تست و اطمینان از عملکرد صحیح	34	20	2026-06-20	approved	0aa7f564-65bd-473d-aa0e-3abc4663b507	\N	51e5e2e8-5322-4474-b1c1-51caa5bed372	2026-07-21 12:23:05.653402+00	2026-07-21 12:23:05.653402+00
9e026bc3-66b8-45d7-9c60-0989a6664192	442c73bb-b175-46a9-8181-183573f175da	6965fa45-fddb-4465-b0e6-042192ac6ee2	پیشرفت اولیه و بررسی نیازمندی‌ها	165	28	2026-06-25	approved	0aa7f564-65bd-473d-aa0e-3abc4663b507	\N	a1e9e434-e7ca-4a0c-9dd7-7f1247148ebb	2026-07-21 12:23:05.653402+00	2026-07-21 12:23:05.653402+00
9e026bc3-66b8-45d7-9c60-0989a6664192	442c73bb-b175-46a9-8181-183573f175da	6965fa45-fddb-4465-b0e6-042192ac6ee2	پیشرفت اولیه و بررسی نیازمندی‌ها	158	66	2026-06-28	approved	0aa7f564-65bd-473d-aa0e-3abc4663b507	\N	d4344a67-36f9-4820-8dff-36bdb3eaba2f	2026-07-21 12:23:05.653402+00	2026-07-21 12:23:05.653402+00
9e026bc3-66b8-45d7-9c60-0989a6664192	442c73bb-b175-46a9-8181-183573f175da	6965fa45-fddb-4465-b0e6-042192ac6ee2	پیشرفت اولیه و بررسی نیازمندی‌ها	54	100	2026-06-29	approved	0aa7f564-65bd-473d-aa0e-3abc4663b507	\N	9baf5ab5-fd6c-40cd-9f89-555328217b09	2026-07-21 12:23:05.653402+00	2026-07-21 12:23:05.653402+00
9e026bc3-66b8-45d7-9c60-0989a6664192	442c73bb-b175-46a9-8181-183573f175da	6965fa45-fddb-4465-b0e6-042192ac6ee2	پیاده‌سازی بخش اصلی	79	100	2026-07-01	approved	0aa7f564-65bd-473d-aa0e-3abc4663b507	\N	fb0b5890-6c8f-40ec-8475-53d8d6cbeba5	2026-07-21 12:23:05.653402+00	2026-07-21 12:23:05.653402+00
9e026bc3-66b8-45d7-9c60-0989a6664192	56038965-dd34-4362-9615-8d463cf92c8d	0aa7f564-65bd-473d-aa0e-3abc4663b507	رفع اشکالات و بازبینی	233	32	2026-07-09	approved	0aa7f564-65bd-473d-aa0e-3abc4663b507	\N	ca1c6a11-49dc-4450-bcc3-0fd90a87c998	2026-07-21 12:23:05.653402+00	2026-07-21 12:23:05.653402+00
9e026bc3-66b8-45d7-9c60-0989a6664192	56038965-dd34-4362-9615-8d463cf92c8d	0aa7f564-65bd-473d-aa0e-3abc4663b507	رفع اشکالات و بازبینی	133	68	2026-07-10	approved	0aa7f564-65bd-473d-aa0e-3abc4663b507	\N	0f4c0a20-8413-43f4-ac25-3ba31358cb87	2026-07-21 12:23:05.653402+00	2026-07-21 12:23:05.653402+00
9e026bc3-66b8-45d7-9c60-0989a6664192	56038965-dd34-4362-9615-8d463cf92c8d	0aa7f564-65bd-473d-aa0e-3abc4663b507	پیاده‌سازی بخش اصلی	106	66	2026-07-13	approved	0aa7f564-65bd-473d-aa0e-3abc4663b507	\N	db8505ed-5fa5-4aa6-ae66-4315856719e4	2026-07-21 12:23:05.653402+00	2026-07-21 12:23:05.653402+00
9e026bc3-66b8-45d7-9c60-0989a6664192	b1fa170e-0b4f-4bea-8e54-8cea68785878	0aa7f564-65bd-473d-aa0e-3abc4663b507	تست و اطمینان از عملکرد صحیح	171	35	2026-07-16	approved	0aa7f564-65bd-473d-aa0e-3abc4663b507	\N	8178a04b-9235-4c54-a14f-9502ee932312	2026-07-21 12:23:05.653402+00	2026-07-21 12:23:05.653402+00
9e026bc3-66b8-45d7-9c60-0989a6664192	2ac4b10f-88f3-4a72-9b60-450c048d241e	e5c268f5-5274-4960-be2b-6f7bbba26625	پیاده‌سازی بخش اصلی	51	35	2026-07-16	approved	0aa7f564-65bd-473d-aa0e-3abc4663b507	\N	b12c4ff6-40f3-4a04-ac42-f5d2913416a3	2026-07-21 12:23:05.653402+00	2026-07-21 12:23:05.653402+00
9e026bc3-66b8-45d7-9c60-0989a6664192	263c7dd4-acce-4119-bea5-81237c1973f1	147770ac-f6f9-4af1-97c3-cccc614d44e9	مستندسازی و نهایی‌سازی	54	36	2026-07-09	approved	0aa7f564-65bd-473d-aa0e-3abc4663b507	\N	d4e0496a-3729-4577-a0bf-3b694284ad40	2026-07-21 12:23:05.653402+00	2026-07-21 12:23:05.653402+00
9e026bc3-66b8-45d7-9c60-0989a6664192	263c7dd4-acce-4119-bea5-81237c1973f1	147770ac-f6f9-4af1-97c3-cccc614d44e9	پیاده‌سازی بخش اصلی	84	76	2026-07-10	approved	0aa7f564-65bd-473d-aa0e-3abc4663b507	\N	a338c749-8799-4986-b00c-cb1f577803a6	2026-07-21 12:23:05.653402+00	2026-07-21 12:23:05.653402+00
9e026bc3-66b8-45d7-9c60-0989a6664192	263c7dd4-acce-4119-bea5-81237c1973f1	147770ac-f6f9-4af1-97c3-cccc614d44e9	رفع اشکالات و بازبینی	41	66	2026-07-16	approved	0aa7f564-65bd-473d-aa0e-3abc4663b507	\N	a6b10055-0775-430c-98a0-087d65b3aedd	2026-07-21 12:23:05.653402+00	2026-07-21 12:23:05.653402+00
9e026bc3-66b8-45d7-9c60-0989a6664192	263c7dd4-acce-4119-bea5-81237c1973f1	147770ac-f6f9-4af1-97c3-cccc614d44e9	مستندسازی و نهایی‌سازی	174	84	2026-07-16	approved	0aa7f564-65bd-473d-aa0e-3abc4663b507	\N	8cb2fa3f-720b-4606-9b24-1f28ba1f90f3	2026-07-21 12:23:05.653402+00	2026-07-21 12:23:05.653402+00
9e026bc3-66b8-45d7-9c60-0989a6664192	5f38861b-c5f4-4e76-9396-98fd8b9d0e22	6965fa45-fddb-4465-b0e6-042192ac6ee2	پیشرفت اولیه و بررسی نیازمندی‌ها	83	38	2026-07-16	approved	0aa7f564-65bd-473d-aa0e-3abc4663b507	\N	8463a467-0857-49ec-8180-1af4fb79276c	2026-07-21 12:23:05.653402+00	2026-07-21 12:23:05.653402+00
9e026bc3-66b8-45d7-9c60-0989a6664192	5f38861b-c5f4-4e76-9396-98fd8b9d0e22	6965fa45-fddb-4465-b0e6-042192ac6ee2	تست و اطمینان از عملکرد صحیح	49	58	2026-07-16	approved	0aa7f564-65bd-473d-aa0e-3abc4663b507	\N	9c9ccf88-e479-40ff-b7b4-4617fe4d20cf	2026-07-21 12:23:05.653402+00	2026-07-21 12:23:05.653402+00
9e026bc3-66b8-45d7-9c60-0989a6664192	b6e85ad5-6c82-4471-a039-29fca8927c89	147770ac-f6f9-4af1-97c3-cccc614d44e9	مستندسازی و نهایی‌سازی	129	37	2026-07-16	approved	0aa7f564-65bd-473d-aa0e-3abc4663b507	\N	99f0e75e-dd18-42cb-9575-d63d16998edf	2026-07-21 12:23:05.653402+00	2026-07-21 12:23:05.653402+00
9e026bc3-66b8-45d7-9c60-0989a6664192	b6e85ad5-6c82-4471-a039-29fca8927c89	147770ac-f6f9-4af1-97c3-cccc614d44e9	تست و اطمینان از عملکرد صحیح	223	48	2026-07-16	approved	0aa7f564-65bd-473d-aa0e-3abc4663b507	\N	83a1d01a-5cf0-4406-90b2-a7bd6db7f6fd	2026-07-21 12:23:05.653402+00	2026-07-21 12:23:05.653402+00
9e026bc3-66b8-45d7-9c60-0989a6664192	f544ba33-3a9f-42fe-8cbd-89d420bad29b	e5c268f5-5274-4960-be2b-6f7bbba26625	پیشرفت اولیه و بررسی نیازمندی‌ها	55	33	2026-07-15	approved	0aa7f564-65bd-473d-aa0e-3abc4663b507	\N	7b8aa1e3-e909-48fe-940f-3e61cba23c66	2026-07-21 12:23:05.653402+00	2026-07-21 12:23:05.653402+00
9e026bc3-66b8-45d7-9c60-0989a6664192	734eee59-c99b-47a4-a7c8-e151c2ad9e69	c17589b4-349d-4156-9b66-f7ecf971b52d	رفع اشکالات و بازبینی	184	39	2026-06-27	approved	0aa7f564-65bd-473d-aa0e-3abc4663b507	\N	fe9efd53-2fad-4ff9-9aeb-71ca9140aa3e	2026-07-21 12:23:05.653402+00	2026-07-21 12:23:05.653402+00
9e026bc3-66b8-45d7-9c60-0989a6664192	734eee59-c99b-47a4-a7c8-e151c2ad9e69	c17589b4-349d-4156-9b66-f7ecf971b52d	رفع اشکالات و بازبینی	37	80	2026-07-01	approved	0aa7f564-65bd-473d-aa0e-3abc4663b507	\N	23b674ab-4473-4c35-9607-6e703c5313ff	2026-07-21 12:23:05.653402+00	2026-07-21 12:23:05.653402+00
9e026bc3-66b8-45d7-9c60-0989a6664192	220be6a2-5e3b-4ffe-8455-b7b7a16c7812	147770ac-f6f9-4af1-97c3-cccc614d44e9	رفع اشکالات و بازبینی	171	32	2026-07-08	approved	0aa7f564-65bd-473d-aa0e-3abc4663b507	\N	ec3b1d28-91e1-4ffa-8de1-5fbbc9f62326	2026-07-21 12:23:05.653402+00	2026-07-21 12:23:05.653402+00
9e026bc3-66b8-45d7-9c60-0989a6664192	220be6a2-5e3b-4ffe-8455-b7b7a16c7812	147770ac-f6f9-4af1-97c3-cccc614d44e9	مستندسازی و نهایی‌سازی	199	64	2026-07-12	approved	0aa7f564-65bd-473d-aa0e-3abc4663b507	\N	1d9db761-a840-4701-b9f5-c067f8ba3393	2026-07-21 12:23:05.653402+00	2026-07-21 12:23:05.653402+00
9e026bc3-66b8-45d7-9c60-0989a6664192	220be6a2-5e3b-4ffe-8455-b7b7a16c7812	147770ac-f6f9-4af1-97c3-cccc614d44e9	رفع اشکالات و بازبینی	234	81	2026-07-10	submitted	\N	\N	6f10bd0c-8982-4801-a6a1-5ebc05449716	2026-07-21 12:23:05.653402+00	2026-07-21 12:23:05.653402+00
9e026bc3-66b8-45d7-9c60-0989a6664192	fb9c89ca-b1e6-4e7e-a421-a1378485faa4	147770ac-f6f9-4af1-97c3-cccc614d44e9	رفع اشکالات و بازبینی	69	32	2026-07-16	approved	0aa7f564-65bd-473d-aa0e-3abc4663b507	\N	59cd470e-1033-4c32-9cdc-8ed3f8702dbc	2026-07-21 12:23:05.653402+00	2026-07-21 12:23:05.653402+00
9e026bc3-66b8-45d7-9c60-0989a6664192	8618fb26-1a21-45ef-825d-4f31b9a12e38	515597de-809a-4b6a-9fb6-5e2cf6d9dfe2	پیشرفت اولیه و بررسی نیازمندی‌ها	53	20	2026-07-16	approved	0aa7f564-65bd-473d-aa0e-3abc4663b507	\N	855f49b1-b66b-46f9-ad1f-939fe6cad5a4	2026-07-21 12:23:05.653402+00	2026-07-21 12:23:05.653402+00
9e026bc3-66b8-45d7-9c60-0989a6664192	8618fb26-1a21-45ef-825d-4f31b9a12e38	515597de-809a-4b6a-9fb6-5e2cf6d9dfe2	رفع اشکالات و بازبینی	56	48	2026-07-16	approved	0aa7f564-65bd-473d-aa0e-3abc4663b507	\N	03c93186-1162-4ec7-82f4-8fee326e12a9	2026-07-21 12:23:05.653402+00	2026-07-21 12:23:05.653402+00
9e026bc3-66b8-45d7-9c60-0989a6664192	4b3648d6-d964-45e0-be52-016320b96c9d	147770ac-f6f9-4af1-97c3-cccc614d44e9	تست و اطمینان از عملکرد صحیح	144	37	2026-07-16	approved	0aa7f564-65bd-473d-aa0e-3abc4663b507	\N	3b9f5803-4141-48ff-a755-8b87e7dd5514	2026-07-21 12:23:05.653402+00	2026-07-21 12:23:05.653402+00
9e026bc3-66b8-45d7-9c60-0989a6664192	3d72e27a-c79b-4f05-9db2-3c9931305876	c17589b4-349d-4156-9b66-f7ecf971b52d	پیشرفت اولیه و بررسی نیازمندی‌ها	52	31	2026-07-15	approved	0aa7f564-65bd-473d-aa0e-3abc4663b507	\N	5fe38ff8-c87e-4661-8113-61fb498de919	2026-07-21 12:23:05.653402+00	2026-07-21 12:23:05.653402+00
9e026bc3-66b8-45d7-9c60-0989a6664192	3d72e27a-c79b-4f05-9db2-3c9931305876	c17589b4-349d-4156-9b66-f7ecf971b52d	مستندسازی و نهایی‌سازی	183	60	2026-07-16	approved	0aa7f564-65bd-473d-aa0e-3abc4663b507	\N	15a64b0e-f67f-4e84-ba5a-78146244d730	2026-07-21 12:23:05.653402+00	2026-07-21 12:23:05.653402+00
9e026bc3-66b8-45d7-9c60-0989a6664192	3d72e27a-c79b-4f05-9db2-3c9931305876	c17589b4-349d-4156-9b66-f7ecf971b52d	پیشرفت اولیه و بررسی نیازمندی‌ها	104	99	2026-07-16	approved	0aa7f564-65bd-473d-aa0e-3abc4663b507	\N	cc08736c-1396-492b-9ea8-491ad6635993	2026-07-21 12:23:05.653402+00	2026-07-21 12:23:05.653402+00
9e026bc3-66b8-45d7-9c60-0989a6664192	3d72e27a-c79b-4f05-9db2-3c9931305876	c17589b4-349d-4156-9b66-f7ecf971b52d	پیشرفت اولیه و بررسی نیازمندی‌ها	215	100	2026-07-16	approved	0aa7f564-65bd-473d-aa0e-3abc4663b507	\N	35f4778f-601f-43ee-8542-8007fe11a8b5	2026-07-21 12:23:05.653402+00	2026-07-21 12:23:05.653402+00
9e026bc3-66b8-45d7-9c60-0989a6664192	d3e5a802-b42d-4425-bc61-a93ad6db1f1b	6965fa45-fddb-4465-b0e6-042192ac6ee2	تست و اطمینان از عملکرد صحیح	73	24	2026-07-07	approved	0aa7f564-65bd-473d-aa0e-3abc4663b507	\N	6edcc0fc-8b23-4ab0-bf15-6a713805f30d	2026-07-21 12:23:05.653402+00	2026-07-21 12:23:05.653402+00
9e026bc3-66b8-45d7-9c60-0989a6664192	d3e5a802-b42d-4425-bc61-a93ad6db1f1b	6965fa45-fddb-4465-b0e6-042192ac6ee2	رفع اشکالات و بازبینی	98	70	2026-07-10	approved	0aa7f564-65bd-473d-aa0e-3abc4663b507	\N	78e39e64-a771-4ce8-b403-c9527305131a	2026-07-21 12:23:05.653402+00	2026-07-21 12:23:05.653402+00
9e026bc3-66b8-45d7-9c60-0989a6664192	1e786e46-b51c-4974-948b-c3bfb88aff9c	e5c268f5-5274-4960-be2b-6f7bbba26625	پیاده‌سازی بخش اصلی	141	28	2026-07-16	approved	0aa7f564-65bd-473d-aa0e-3abc4663b507	\N	8503f62b-3243-4de7-8a4a-2c5bdaa36938	2026-07-21 12:23:05.653402+00	2026-07-21 12:23:05.653402+00
9e026bc3-66b8-45d7-9c60-0989a6664192	1e786e46-b51c-4974-948b-c3bfb88aff9c	e5c268f5-5274-4960-be2b-6f7bbba26625	رفع اشکالات و بازبینی	153	44	2026-07-16	approved	0aa7f564-65bd-473d-aa0e-3abc4663b507	\N	3aeef751-712c-4064-bee6-e99b152c4c9d	2026-07-21 12:23:05.653402+00	2026-07-21 12:23:05.653402+00
9e026bc3-66b8-45d7-9c60-0989a6664192	8545ad17-216c-43ee-ad50-36d5fd9d59f7	0aa7f564-65bd-473d-aa0e-3abc4663b507	تست و اطمینان از عملکرد صحیح	182	39	2026-07-01	submitted	\N	\N	e42498fa-84da-487d-b7d2-d8e1c750a640	2026-07-21 12:23:05.653402+00	2026-07-21 12:23:05.653402+00
9e026bc3-66b8-45d7-9c60-0989a6664192	8545ad17-216c-43ee-ad50-36d5fd9d59f7	0aa7f564-65bd-473d-aa0e-3abc4663b507	پیاده‌سازی بخش اصلی	107	40	2026-07-03	approved	0aa7f564-65bd-473d-aa0e-3abc4663b507	\N	12c1261f-18d8-44ca-a832-8a7190d43f59	2026-07-21 12:23:05.653402+00	2026-07-21 12:23:05.653402+00
9e026bc3-66b8-45d7-9c60-0989a6664192	8545ad17-216c-43ee-ad50-36d5fd9d59f7	0aa7f564-65bd-473d-aa0e-3abc4663b507	مستندسازی و نهایی‌سازی	127	90	2026-07-09	approved	0aa7f564-65bd-473d-aa0e-3abc4663b507	\N	6e08a39d-859d-48f1-834f-470a89177578	2026-07-21 12:23:05.653402+00	2026-07-21 12:23:05.653402+00
9e026bc3-66b8-45d7-9c60-0989a6664192	6b878f5c-873d-4f9e-a001-74c6d6dec497	6115c41b-8c19-4fa9-b656-df967e8a945e	تست و اطمینان از عملکرد صحیح	238	40	2026-07-15	approved	0aa7f564-65bd-473d-aa0e-3abc4663b507	\N	686d97bc-a5ad-43d3-b91f-4be670899316	2026-07-21 12:23:05.653402+00	2026-07-21 12:23:05.653402+00
9e026bc3-66b8-45d7-9c60-0989a6664192	6b878f5c-873d-4f9e-a001-74c6d6dec497	6115c41b-8c19-4fa9-b656-df967e8a945e	رفع اشکالات و بازبینی	112	78	2026-07-16	approved	0aa7f564-65bd-473d-aa0e-3abc4663b507	\N	ef354d1a-f64d-421b-8b98-69b7759876c7	2026-07-21 12:23:05.653402+00	2026-07-21 12:23:05.653402+00
9e026bc3-66b8-45d7-9c60-0989a6664192	6b878f5c-873d-4f9e-a001-74c6d6dec497	6115c41b-8c19-4fa9-b656-df967e8a945e	تست و اطمینان از عملکرد صحیح	110	75	2026-07-16	approved	0aa7f564-65bd-473d-aa0e-3abc4663b507	\N	61aff6b1-8752-492e-9515-468ec874ecd9	2026-07-21 12:23:05.653402+00	2026-07-21 12:23:05.653402+00
9e026bc3-66b8-45d7-9c60-0989a6664192	6b878f5c-873d-4f9e-a001-74c6d6dec497	6115c41b-8c19-4fa9-b656-df967e8a945e	رفع اشکالات و بازبینی	104	100	2026-07-16	approved	0aa7f564-65bd-473d-aa0e-3abc4663b507	\N	c3cca792-6801-4aee-83d6-3bb963f9f138	2026-07-21 12:23:05.653402+00	2026-07-21 12:23:05.653402+00
9e026bc3-66b8-45d7-9c60-0989a6664192	b3fcaaad-e1de-484b-81f3-50bbbcad6db1	0aa7f564-65bd-473d-aa0e-3abc4663b507	رفع اشکالات و بازبینی	239	32	2026-07-16	approved	0aa7f564-65bd-473d-aa0e-3abc4663b507	\N	aa01c966-af03-460b-b32f-a779102cd64d	2026-07-21 12:23:05.653402+00	2026-07-21 12:23:05.653402+00
9e026bc3-66b8-45d7-9c60-0989a6664192	b3fcaaad-e1de-484b-81f3-50bbbcad6db1	0aa7f564-65bd-473d-aa0e-3abc4663b507	مستندسازی و نهایی‌سازی	81	76	2026-07-16	approved	0aa7f564-65bd-473d-aa0e-3abc4663b507	\N	7ad9cda9-7d30-4434-94e5-6e1a1950c392	2026-07-21 12:23:05.653402+00	2026-07-21 12:23:05.653402+00
9e026bc3-66b8-45d7-9c60-0989a6664192	b3fcaaad-e1de-484b-81f3-50bbbcad6db1	0aa7f564-65bd-473d-aa0e-3abc4663b507	مستندسازی و نهایی‌سازی	36	100	2026-07-16	approved	0aa7f564-65bd-473d-aa0e-3abc4663b507	\N	e9cff575-4c73-475c-8b09-89920d065111	2026-07-21 12:23:05.653402+00	2026-07-21 12:23:05.653402+00
9e026bc3-66b8-45d7-9c60-0989a6664192	b3fcaaad-e1de-484b-81f3-50bbbcad6db1	0aa7f564-65bd-473d-aa0e-3abc4663b507	رفع اشکالات و بازبینی	207	88	2026-07-16	approved	0aa7f564-65bd-473d-aa0e-3abc4663b507	\N	52962340-8b7d-4836-b8bf-72c4cd0fa2a2	2026-07-21 12:23:05.653402+00	2026-07-21 12:23:05.653402+00
9e026bc3-66b8-45d7-9c60-0989a6664192	b1167940-3356-4243-939c-887247f09ab2	0aa7f564-65bd-473d-aa0e-3abc4663b507	رفع اشکالات و بازبینی	91	28	2026-07-16	approved	0aa7f564-65bd-473d-aa0e-3abc4663b507	\N	dc931ade-006e-4681-a4cd-ac0084653d3e	2026-07-21 12:23:05.653402+00	2026-07-21 12:23:05.653402+00
9e026bc3-66b8-45d7-9c60-0989a6664192	b1167940-3356-4243-939c-887247f09ab2	0aa7f564-65bd-473d-aa0e-3abc4663b507	تست و اطمینان از عملکرد صحیح	48	68	2026-07-16	submitted	\N	\N	b8060f88-f317-4fae-992e-aec053e04f06	2026-07-21 12:23:05.653402+00	2026-07-21 12:23:05.653402+00
9e026bc3-66b8-45d7-9c60-0989a6664192	b1167940-3356-4243-939c-887247f09ab2	0aa7f564-65bd-473d-aa0e-3abc4663b507	مستندسازی و نهایی‌سازی	159	99	2026-07-16	approved	0aa7f564-65bd-473d-aa0e-3abc4663b507	\N	44cbf899-4d88-47cf-9fe0-df653e149c67	2026-07-21 12:23:05.653402+00	2026-07-21 12:23:05.653402+00
9e026bc3-66b8-45d7-9c60-0989a6664192	b1167940-3356-4243-939c-887247f09ab2	0aa7f564-65bd-473d-aa0e-3abc4663b507	رفع اشکالات و بازبینی	209	100	2026-07-16	submitted	\N	\N	aa420ec0-ca22-4f82-8e8b-3a67900e015c	2026-07-21 12:23:05.653402+00	2026-07-21 12:23:05.653402+00
9e026bc3-66b8-45d7-9c60-0989a6664192	d9b9ca9c-1e4c-4148-a032-2655fe6d185e	515597de-809a-4b6a-9fb6-5e2cf6d9dfe2	پیاده‌سازی بخش اصلی	198	31	2026-06-24	approved	0aa7f564-65bd-473d-aa0e-3abc4663b507	\N	e1e6a38f-c978-44b3-9fc4-1e3c0b9e2ffb	2026-07-21 12:23:05.653402+00	2026-07-21 12:23:05.653402+00
9e026bc3-66b8-45d7-9c60-0989a6664192	f7b5ac0d-fe4e-4986-b496-06fb425ecfa2	e5c268f5-5274-4960-be2b-6f7bbba26625	مستندسازی و نهایی‌سازی	195	40	2026-07-16	approved	0aa7f564-65bd-473d-aa0e-3abc4663b507	\N	b0a7c252-9135-4900-b473-fd8c29c00916	2026-07-21 12:23:05.653402+00	2026-07-21 12:23:05.653402+00
9e026bc3-66b8-45d7-9c60-0989a6664192	f7b5ac0d-fe4e-4986-b496-06fb425ecfa2	e5c268f5-5274-4960-be2b-6f7bbba26625	رفع اشکالات و بازبینی	233	66	2026-07-16	approved	0aa7f564-65bd-473d-aa0e-3abc4663b507	\N	5d5c600b-97e7-4f4e-87d7-cef024b45976	2026-07-21 12:23:05.653402+00	2026-07-21 12:23:05.653402+00
9e026bc3-66b8-45d7-9c60-0989a6664192	46f27a2b-82e5-4f5c-96f3-5f5fc8eaabc4	515597de-809a-4b6a-9fb6-5e2cf6d9dfe2	پیشرفت اولیه و بررسی نیازمندی‌ها	96	27	2026-07-16	approved	0aa7f564-65bd-473d-aa0e-3abc4663b507	\N	35d22d41-8481-4d14-8fa3-b9a8ea7506b9	2026-07-21 12:23:05.653402+00	2026-07-21 12:23:05.653402+00
9e026bc3-66b8-45d7-9c60-0989a6664192	65df4ed8-72c2-4fd0-a412-115499a4638d	c17589b4-349d-4156-9b66-f7ecf971b52d	رفع اشکالات و بازبینی	130	34	2026-07-16	approved	0aa7f564-65bd-473d-aa0e-3abc4663b507	\N	e8d1f658-8f23-4f9f-af9b-8e6b96c3a5ca	2026-07-21 12:23:05.653402+00	2026-07-21 12:23:05.653402+00
9e026bc3-66b8-45d7-9c60-0989a6664192	65df4ed8-72c2-4fd0-a412-115499a4638d	c17589b4-349d-4156-9b66-f7ecf971b52d	رفع اشکالات و بازبینی	36	70	2026-07-16	approved	0aa7f564-65bd-473d-aa0e-3abc4663b507	\N	e544ddd6-34c2-4863-a9a8-81ce6d7d95f5	2026-07-21 12:23:05.653402+00	2026-07-21 12:23:05.653402+00
9e026bc3-66b8-45d7-9c60-0989a6664192	34dd8e78-0904-412b-a2f5-87d3d1a1b208	e5c268f5-5274-4960-be2b-6f7bbba26625	پیشرفت اولیه و بررسی نیازمندی‌ها	59	24	2026-07-16	approved	0aa7f564-65bd-473d-aa0e-3abc4663b507	\N	3ee52fa2-c206-41d9-b040-edd2016c8ccd	2026-07-21 12:23:05.653402+00	2026-07-21 12:23:05.653402+00
9e026bc3-66b8-45d7-9c60-0989a6664192	1e61e1a5-9951-4cf5-94f5-478db93635c9	147770ac-f6f9-4af1-97c3-cccc614d44e9	رفع اشکالات و بازبینی	146	26	2026-07-16	approved	0aa7f564-65bd-473d-aa0e-3abc4663b507	\N	8cb7eb49-34b2-41c1-b6fd-fca948bcc268	2026-07-21 12:23:05.653402+00	2026-07-21 12:23:05.653402+00
9e026bc3-66b8-45d7-9c60-0989a6664192	1e61e1a5-9951-4cf5-94f5-478db93635c9	147770ac-f6f9-4af1-97c3-cccc614d44e9	رفع اشکالات و بازبینی	151	46	2026-07-16	approved	0aa7f564-65bd-473d-aa0e-3abc4663b507	\N	1fd6a7dc-7c60-48e2-a056-3eb7d6b26c44	2026-07-21 12:23:05.653402+00	2026-07-21 12:23:05.653402+00
9e026bc3-66b8-45d7-9c60-0989a6664192	1e61e1a5-9951-4cf5-94f5-478db93635c9	147770ac-f6f9-4af1-97c3-cccc614d44e9	تست و اطمینان از عملکرد صحیح	111	66	2026-07-16	approved	0aa7f564-65bd-473d-aa0e-3abc4663b507	\N	9362bb70-ce9c-4160-8d5a-0c24792a6aab	2026-07-21 12:23:05.653402+00	2026-07-21 12:23:05.653402+00
9e026bc3-66b8-45d7-9c60-0989a6664192	c14ed08f-41b0-498a-87bb-bb99b8327f59	c17589b4-349d-4156-9b66-f7ecf971b52d	پیشرفت اولیه و بررسی نیازمندی‌ها	35	30	2026-07-16	approved	0aa7f564-65bd-473d-aa0e-3abc4663b507	\N	d7721aa4-1f17-49af-bd16-88016a4ad1ba	2026-07-21 12:23:05.653402+00	2026-07-21 12:23:05.653402+00
9e026bc3-66b8-45d7-9c60-0989a6664192	c14ed08f-41b0-498a-87bb-bb99b8327f59	c17589b4-349d-4156-9b66-f7ecf971b52d	پیاده‌سازی بخش اصلی	219	54	2026-07-16	approved	0aa7f564-65bd-473d-aa0e-3abc4663b507	\N	6fcd14c0-5dfb-44c8-90a1-334bbf206afb	2026-07-21 12:23:05.653402+00	2026-07-21 12:23:05.653402+00
9e026bc3-66b8-45d7-9c60-0989a6664192	c14ed08f-41b0-498a-87bb-bb99b8327f59	c17589b4-349d-4156-9b66-f7ecf971b52d	مستندسازی و نهایی‌سازی	70	90	2026-07-16	approved	0aa7f564-65bd-473d-aa0e-3abc4663b507	\N	e11b81a2-e672-46d2-94c9-326763081c95	2026-07-21 12:23:05.653402+00	2026-07-21 12:23:05.653402+00
9e026bc3-66b8-45d7-9c60-0989a6664192	5e98d720-f979-41dd-b750-54ca05ccf2ed	147770ac-f6f9-4af1-97c3-cccc614d44e9	پیاده‌سازی بخش اصلی	234	32	2026-07-16	approved	0aa7f564-65bd-473d-aa0e-3abc4663b507	\N	903bfe82-e7fa-4a09-9add-d0a2cc6931e0	2026-07-21 12:23:05.653402+00	2026-07-21 12:23:05.653402+00
9e026bc3-66b8-45d7-9c60-0989a6664192	5e98d720-f979-41dd-b750-54ca05ccf2ed	147770ac-f6f9-4af1-97c3-cccc614d44e9	پیاده‌سازی بخش اصلی	193	66	2026-07-16	approved	0aa7f564-65bd-473d-aa0e-3abc4663b507	\N	8d648247-a332-4e14-a8e9-6fbfa7dfcb2b	2026-07-21 12:23:05.653402+00	2026-07-21 12:23:05.653402+00
9e026bc3-66b8-45d7-9c60-0989a6664192	5e98d720-f979-41dd-b750-54ca05ccf2ed	147770ac-f6f9-4af1-97c3-cccc614d44e9	پیشرفت اولیه و بررسی نیازمندی‌ها	218	100	2026-07-16	approved	0aa7f564-65bd-473d-aa0e-3abc4663b507	\N	37eb994a-343b-47d8-aa34-60b77d98f31e	2026-07-21 12:23:05.653402+00	2026-07-21 12:23:05.653402+00
9e026bc3-66b8-45d7-9c60-0989a6664192	5e98d720-f979-41dd-b750-54ca05ccf2ed	147770ac-f6f9-4af1-97c3-cccc614d44e9	تست و اطمینان از عملکرد صحیح	181	100	2026-07-16	approved	0aa7f564-65bd-473d-aa0e-3abc4663b507	\N	be63ec18-7772-46f4-b03e-7028c70a4d2b	2026-07-21 12:23:05.653402+00	2026-07-21 12:23:05.653402+00
9e026bc3-66b8-45d7-9c60-0989a6664192	813c667a-82df-4d32-84a3-3438832917ea	147770ac-f6f9-4af1-97c3-cccc614d44e9	پیاده‌سازی بخش اصلی	101	22	2026-07-12	submitted	\N	\N	5222922c-e1b8-41da-ba32-ccbbde665606	2026-07-21 12:23:05.653402+00	2026-07-21 12:23:05.653402+00
9e026bc3-66b8-45d7-9c60-0989a6664192	813c667a-82df-4d32-84a3-3438832917ea	147770ac-f6f9-4af1-97c3-cccc614d44e9	مستندسازی و نهایی‌سازی	77	62	2026-07-13	submitted	\N	\N	b99aa0fe-0b92-4d19-a2eb-1bdd216a1880	2026-07-21 12:23:05.653402+00	2026-07-21 12:23:05.653402+00
9e026bc3-66b8-45d7-9c60-0989a6664192	813c667a-82df-4d32-84a3-3438832917ea	147770ac-f6f9-4af1-97c3-cccc614d44e9	پیشرفت اولیه و بررسی نیازمندی‌ها	97	100	2026-07-16	approved	0aa7f564-65bd-473d-aa0e-3abc4663b507	\N	35209751-d4d5-43f8-9f8f-56b8d0bdbf7e	2026-07-21 12:23:05.653402+00	2026-07-21 12:23:05.653402+00
9e026bc3-66b8-45d7-9c60-0989a6664192	813c667a-82df-4d32-84a3-3438832917ea	147770ac-f6f9-4af1-97c3-cccc614d44e9	مستندسازی و نهایی‌سازی	130	100	2026-07-16	approved	0aa7f564-65bd-473d-aa0e-3abc4663b507	\N	a8bd1fdd-6264-4b28-829e-2dbbae45a643	2026-07-21 12:23:05.653402+00	2026-07-21 12:23:05.653402+00
9e026bc3-66b8-45d7-9c60-0989a6664192	27d643ad-9463-45d1-8ca7-7a1e79ce3c91	147770ac-f6f9-4af1-97c3-cccc614d44e9	رفع اشکالات و بازبینی	147	39	2026-06-19	approved	0aa7f564-65bd-473d-aa0e-3abc4663b507	\N	d9daef15-e8a5-45b5-b0a5-2eee136d04c5	2026-07-21 12:23:05.653402+00	2026-07-21 12:23:05.653402+00
9e026bc3-66b8-45d7-9c60-0989a6664192	7edf3b53-728c-4e98-9da2-c9f3eceefb49	147770ac-f6f9-4af1-97c3-cccc614d44e9	مستندسازی و نهایی‌سازی	181	22	2026-07-06	approved	0aa7f564-65bd-473d-aa0e-3abc4663b507	\N	224bb2b9-9c74-41e3-8829-d1554b19f13a	2026-07-21 12:23:05.653402+00	2026-07-21 12:23:05.653402+00
9e026bc3-66b8-45d7-9c60-0989a6664192	7edf3b53-728c-4e98-9da2-c9f3eceefb49	147770ac-f6f9-4af1-97c3-cccc614d44e9	رفع اشکالات و بازبینی	60	54	2026-07-08	approved	0aa7f564-65bd-473d-aa0e-3abc4663b507	\N	a46ecaee-c8d0-4cc5-a57b-1b39c02d8ed7	2026-07-21 12:23:05.653402+00	2026-07-21 12:23:05.653402+00
9e026bc3-66b8-45d7-9c60-0989a6664192	67a9642f-6d75-475d-91c8-8bb6a85bf7dd	e5c268f5-5274-4960-be2b-6f7bbba26625	پیاده‌سازی بخش اصلی	125	24	2026-07-16	approved	0aa7f564-65bd-473d-aa0e-3abc4663b507	\N	872eb039-1aeb-421c-9a5e-5a7cbcc6c2e7	2026-07-21 12:23:05.653402+00	2026-07-21 12:23:05.653402+00
9e026bc3-66b8-45d7-9c60-0989a6664192	67a9642f-6d75-475d-91c8-8bb6a85bf7dd	e5c268f5-5274-4960-be2b-6f7bbba26625	تست و اطمینان از عملکرد صحیح	182	48	2026-07-16	approved	0aa7f564-65bd-473d-aa0e-3abc4663b507	\N	7359cf24-584d-4c46-a308-620282b0311b	2026-07-21 12:23:05.653402+00	2026-07-21 12:23:05.653402+00
9e026bc3-66b8-45d7-9c60-0989a6664192	67a9642f-6d75-475d-91c8-8bb6a85bf7dd	e5c268f5-5274-4960-be2b-6f7bbba26625	تست و اطمینان از عملکرد صحیح	77	100	2026-07-16	approved	0aa7f564-65bd-473d-aa0e-3abc4663b507	\N	35b55dcb-4aaa-4492-ae7b-219b7a69d60f	2026-07-21 12:23:05.653402+00	2026-07-21 12:23:05.653402+00
9e026bc3-66b8-45d7-9c60-0989a6664192	e4015f9d-8a47-4dcf-99fc-22fa90da53bd	6115c41b-8c19-4fa9-b656-df967e8a945e	پیاده‌سازی بخش اصلی	77	30	2026-07-16	approved	0aa7f564-65bd-473d-aa0e-3abc4663b507	\N	00fb8a97-5614-4ad2-9e93-ac3309e7841e	2026-07-21 12:23:05.653402+00	2026-07-21 12:23:05.653402+00
9e026bc3-66b8-45d7-9c60-0989a6664192	e4015f9d-8a47-4dcf-99fc-22fa90da53bd	6115c41b-8c19-4fa9-b656-df967e8a945e	رفع اشکالات و بازبینی	32	70	2026-07-16	approved	0aa7f564-65bd-473d-aa0e-3abc4663b507	\N	0080bf58-6288-4ba4-9923-26e344fa5162	2026-07-21 12:23:05.653402+00	2026-07-21 12:23:05.653402+00
9e026bc3-66b8-45d7-9c60-0989a6664192	682d3a66-75b7-4ebd-88dc-b2b5b65614e7	147770ac-f6f9-4af1-97c3-cccc614d44e9	تست و اطمینان از عملکرد صحیح	173	36	2026-07-16	approved	0aa7f564-65bd-473d-aa0e-3abc4663b507	\N	27bebf17-8193-4ac9-9aee-262a29cee102	2026-07-21 12:23:05.653402+00	2026-07-21 12:23:05.653402+00
9e026bc3-66b8-45d7-9c60-0989a6664192	682d3a66-75b7-4ebd-88dc-b2b5b65614e7	147770ac-f6f9-4af1-97c3-cccc614d44e9	تست و اطمینان از عملکرد صحیح	205	70	2026-07-16	approved	0aa7f564-65bd-473d-aa0e-3abc4663b507	\N	82c66c8c-21c4-420a-beea-44b85741d0de	2026-07-21 12:23:05.653402+00	2026-07-21 12:23:05.653402+00
9e026bc3-66b8-45d7-9c60-0989a6664192	3b6d3f7f-79ed-4c89-a170-1a5e8280f81e	c17589b4-349d-4156-9b66-f7ecf971b52d	تست و اطمینان از عملکرد صحیح	72	22	2026-07-03	approved	0aa7f564-65bd-473d-aa0e-3abc4663b507	\N	9939a1f6-5fdd-4ce0-ab97-150a6494e53e	2026-07-21 12:23:05.653402+00	2026-07-21 12:23:05.653402+00
9e026bc3-66b8-45d7-9c60-0989a6664192	3b6d3f7f-79ed-4c89-a170-1a5e8280f81e	c17589b4-349d-4156-9b66-f7ecf971b52d	پیاده‌سازی بخش اصلی	104	42	2026-07-04	approved	0aa7f564-65bd-473d-aa0e-3abc4663b507	\N	fe20be62-a8ef-4a4c-8550-bc4b7c59fbd4	2026-07-21 12:23:05.653402+00	2026-07-21 12:23:05.653402+00
9e026bc3-66b8-45d7-9c60-0989a6664192	3b6d3f7f-79ed-4c89-a170-1a5e8280f81e	c17589b4-349d-4156-9b66-f7ecf971b52d	پیاده‌سازی بخش اصلی	167	87	2026-07-09	approved	0aa7f564-65bd-473d-aa0e-3abc4663b507	\N	a8cba950-9bfb-4406-8a5e-03f2614c262f	2026-07-21 12:23:05.653402+00	2026-07-21 12:23:05.653402+00
9e026bc3-66b8-45d7-9c60-0989a6664192	3b6d3f7f-79ed-4c89-a170-1a5e8280f81e	c17589b4-349d-4156-9b66-f7ecf971b52d	تست و اطمینان از عملکرد صحیح	174	100	2026-07-09	approved	0aa7f564-65bd-473d-aa0e-3abc4663b507	\N	c193ad1a-354a-48ec-8672-4c2a74fb2659	2026-07-21 12:23:05.653402+00	2026-07-21 12:23:05.653402+00
9e026bc3-66b8-45d7-9c60-0989a6664192	a03714c0-3dba-4d34-ab9f-2d04174cbdc7	6965fa45-fddb-4465-b0e6-042192ac6ee2	مستندسازی و نهایی‌سازی	240	31	2026-07-16	approved	0aa7f564-65bd-473d-aa0e-3abc4663b507	\N	640dd676-8f9b-4559-be53-c21dc0c3cd3d	2026-07-21 12:23:05.653402+00	2026-07-21 12:23:05.653402+00
9e026bc3-66b8-45d7-9c60-0989a6664192	233fa2d3-a006-4168-b558-af0915e58186	0aa7f564-65bd-473d-aa0e-3abc4663b507	تست و اطمینان از عملکرد صحیح	56	40	2026-07-16	approved	0aa7f564-65bd-473d-aa0e-3abc4663b507	\N	675e4830-850f-4b53-af91-0f52b5bd367a	2026-07-21 12:23:05.653402+00	2026-07-21 12:23:05.653402+00
9e026bc3-66b8-45d7-9c60-0989a6664192	e875c7fc-9add-48e7-9839-a28ccd683396	c17589b4-349d-4156-9b66-f7ecf971b52d	پیشرفت اولیه و بررسی نیازمندی‌ها	145	28	2026-07-16	approved	0aa7f564-65bd-473d-aa0e-3abc4663b507	\N	94903f62-aa34-49ca-a305-2f56faf0249a	2026-07-21 12:23:05.653402+00	2026-07-21 12:23:05.653402+00
9e026bc3-66b8-45d7-9c60-0989a6664192	e875c7fc-9add-48e7-9839-a28ccd683396	c17589b4-349d-4156-9b66-f7ecf971b52d	پیشرفت اولیه و بررسی نیازمندی‌ها	142	46	2026-07-16	approved	0aa7f564-65bd-473d-aa0e-3abc4663b507	\N	10a0d44c-c6da-48f3-90fd-6ca1c6c11c34	2026-07-21 12:23:05.653402+00	2026-07-21 12:23:05.653402+00
9e026bc3-66b8-45d7-9c60-0989a6664192	b2e96517-c909-470a-ba85-48c2550e0e9e	515597de-809a-4b6a-9fb6-5e2cf6d9dfe2	مستندسازی و نهایی‌سازی	206	31	2026-07-01	submitted	\N	\N	5422ac23-d91a-440a-9d5c-35c6fc4369ee	2026-07-21 12:23:05.653402+00	2026-07-21 12:23:05.653402+00
9e026bc3-66b8-45d7-9c60-0989a6664192	b2e96517-c909-470a-ba85-48c2550e0e9e	515597de-809a-4b6a-9fb6-5e2cf6d9dfe2	پیاده‌سازی بخش اصلی	230	52	2026-07-05	approved	0aa7f564-65bd-473d-aa0e-3abc4663b507	\N	0af20a1d-23b3-407e-b283-3999cbe38f34	2026-07-21 12:23:05.653402+00	2026-07-21 12:23:05.653402+00
9e026bc3-66b8-45d7-9c60-0989a6664192	96d5ce7e-ae2d-41a2-9069-faec402a0a72	6115c41b-8c19-4fa9-b656-df967e8a945e	مستندسازی و نهایی‌سازی	119	37	2026-07-04	approved	0aa7f564-65bd-473d-aa0e-3abc4663b507	\N	6a35de49-23e2-405d-b11d-a095997ba35c	2026-07-21 12:23:05.653402+00	2026-07-21 12:23:05.653402+00
9e026bc3-66b8-45d7-9c60-0989a6664192	96d5ce7e-ae2d-41a2-9069-faec402a0a72	6115c41b-8c19-4fa9-b656-df967e8a945e	مستندسازی و نهایی‌سازی	167	50	2026-07-07	approved	0aa7f564-65bd-473d-aa0e-3abc4663b507	\N	edc14b2d-4e0f-4c25-8ab1-a0ad9365784e	2026-07-21 12:23:05.653402+00	2026-07-21 12:23:05.653402+00
9e026bc3-66b8-45d7-9c60-0989a6664192	16d5e540-4815-45de-8f08-fe2c13720121	0aa7f564-65bd-473d-aa0e-3abc4663b507	رفع اشکالات و بازبینی	176	28	2026-07-16	approved	0aa7f564-65bd-473d-aa0e-3abc4663b507	\N	b3712504-92e6-406b-8f3e-398a33a11277	2026-07-21 12:23:05.653402+00	2026-07-21 12:23:05.653402+00
9e026bc3-66b8-45d7-9c60-0989a6664192	16d5e540-4815-45de-8f08-fe2c13720121	0aa7f564-65bd-473d-aa0e-3abc4663b507	پیاده‌سازی بخش اصلی	222	66	2026-07-16	approved	0aa7f564-65bd-473d-aa0e-3abc4663b507	\N	6d2df3e8-cbcf-466d-a851-cbc05826dfbc	2026-07-21 12:23:05.653402+00	2026-07-21 12:23:05.653402+00
9e026bc3-66b8-45d7-9c60-0989a6664192	16d5e540-4815-45de-8f08-fe2c13720121	0aa7f564-65bd-473d-aa0e-3abc4663b507	رفع اشکالات و بازبینی	197	72	2026-07-16	approved	0aa7f564-65bd-473d-aa0e-3abc4663b507	\N	27d6f2b3-2b7f-4ed5-b448-f6f5535cdf1c	2026-07-21 12:23:05.653402+00	2026-07-21 12:23:05.653402+00
9e026bc3-66b8-45d7-9c60-0989a6664192	88ce644d-8820-4bfd-a7ef-c20dd0750e16	147770ac-f6f9-4af1-97c3-cccc614d44e9	رفع اشکالات و بازبینی	93	32	2026-07-16	approved	0aa7f564-65bd-473d-aa0e-3abc4663b507	\N	34e57d55-b635-451c-96af-530af72753f8	2026-07-21 12:23:05.653402+00	2026-07-21 12:23:05.653402+00
9e026bc3-66b8-45d7-9c60-0989a6664192	88ce644d-8820-4bfd-a7ef-c20dd0750e16	147770ac-f6f9-4af1-97c3-cccc614d44e9	رفع اشکالات و بازبینی	190	66	2026-07-16	approved	0aa7f564-65bd-473d-aa0e-3abc4663b507	\N	9aad1cd8-dbcf-4e16-b522-bb5ea1e1ad86	2026-07-21 12:23:05.653402+00	2026-07-21 12:23:05.653402+00
9e026bc3-66b8-45d7-9c60-0989a6664192	8cc37be7-c61a-4e75-8528-dfca5bfedf5b	e5c268f5-5274-4960-be2b-6f7bbba26625	پیشرفت اولیه و بررسی نیازمندی‌ها	133	36	2026-07-15	approved	0aa7f564-65bd-473d-aa0e-3abc4663b507	\N	536f0232-913f-446e-b35d-4d4281fa1b94	2026-07-21 12:23:05.653402+00	2026-07-21 12:23:05.653402+00
9e026bc3-66b8-45d7-9c60-0989a6664192	8cc37be7-c61a-4e75-8528-dfca5bfedf5b	e5c268f5-5274-4960-be2b-6f7bbba26625	رفع اشکالات و بازبینی	146	70	2026-07-16	approved	0aa7f564-65bd-473d-aa0e-3abc4663b507	\N	4fe51b94-5c8d-4f8f-bf90-b1bb0a2cf59d	2026-07-21 12:23:05.653402+00	2026-07-21 12:23:05.653402+00
9e026bc3-66b8-45d7-9c60-0989a6664192	8cc37be7-c61a-4e75-8528-dfca5bfedf5b	e5c268f5-5274-4960-be2b-6f7bbba26625	پیشرفت اولیه و بررسی نیازمندی‌ها	217	100	2026-07-16	approved	0aa7f564-65bd-473d-aa0e-3abc4663b507	\N	59de9f65-c7fb-4c44-9d06-abc921bc64a9	2026-07-21 12:23:05.653402+00	2026-07-21 12:23:05.653402+00
9e026bc3-66b8-45d7-9c60-0989a6664192	8cc37be7-c61a-4e75-8528-dfca5bfedf5b	e5c268f5-5274-4960-be2b-6f7bbba26625	مستندسازی و نهایی‌سازی	131	100	2026-07-16	submitted	\N	\N	bf71ca3d-c7fb-4020-bf70-918db2d5f5d7	2026-07-21 12:23:05.653402+00	2026-07-21 12:23:05.653402+00
9e026bc3-66b8-45d7-9c60-0989a6664192	8cfcf3d7-673a-44b9-93a4-905294b3d30e	6965fa45-fddb-4465-b0e6-042192ac6ee2	رفع اشکالات و بازبینی	102	30	2026-06-28	approved	0aa7f564-65bd-473d-aa0e-3abc4663b507	\N	9fa0908f-260c-4258-86ca-7121302f964c	2026-07-21 12:23:05.653402+00	2026-07-21 12:23:05.653402+00
9e026bc3-66b8-45d7-9c60-0989a6664192	8cfcf3d7-673a-44b9-93a4-905294b3d30e	6965fa45-fddb-4465-b0e6-042192ac6ee2	تست و اطمینان از عملکرد صحیح	231	60	2026-06-30	approved	0aa7f564-65bd-473d-aa0e-3abc4663b507	\N	27699290-feda-4fc5-b0d1-3c6dd4e028f8	2026-07-21 12:23:05.653402+00	2026-07-21 12:23:05.653402+00
9e026bc3-66b8-45d7-9c60-0989a6664192	8cfcf3d7-673a-44b9-93a4-905294b3d30e	6965fa45-fddb-4465-b0e6-042192ac6ee2	تست و اطمینان از عملکرد صحیح	34	69	2026-06-30	approved	0aa7f564-65bd-473d-aa0e-3abc4663b507	\N	7574347f-6456-41ee-a769-6f9836e4210c	2026-07-21 12:23:05.653402+00	2026-07-21 12:23:05.653402+00
9e026bc3-66b8-45d7-9c60-0989a6664192	8cfcf3d7-673a-44b9-93a4-905294b3d30e	6965fa45-fddb-4465-b0e6-042192ac6ee2	پیشرفت اولیه و بررسی نیازمندی‌ها	139	100	2026-07-04	approved	0aa7f564-65bd-473d-aa0e-3abc4663b507	\N	7f5f82e3-09b3-4e8e-928b-5184e8ca7bcd	2026-07-21 12:23:05.653402+00	2026-07-21 12:23:05.653402+00
9e026bc3-66b8-45d7-9c60-0989a6664192	3682d4bc-612a-4daf-8b8b-9ee7a1c0a989	6965fa45-fddb-4465-b0e6-042192ac6ee2	پیاده‌سازی بخش اصلی	100	22	2026-06-24	approved	0aa7f564-65bd-473d-aa0e-3abc4663b507	\N	4bad31e9-c49e-4858-a5f1-cc2dac66abb1	2026-07-21 12:23:05.653402+00	2026-07-21 12:23:05.653402+00
9e026bc3-66b8-45d7-9c60-0989a6664192	3682d4bc-612a-4daf-8b8b-9ee7a1c0a989	6965fa45-fddb-4465-b0e6-042192ac6ee2	رفع اشکالات و بازبینی	51	62	2026-06-27	approved	0aa7f564-65bd-473d-aa0e-3abc4663b507	\N	1cbfe477-85bc-46f0-ab80-a00f53a38d05	2026-07-21 12:23:05.653402+00	2026-07-21 12:23:05.653402+00
9e026bc3-66b8-45d7-9c60-0989a6664192	c5d15e1b-a189-4743-a902-05d64ea635d1	6965fa45-fddb-4465-b0e6-042192ac6ee2	رفع اشکالات و بازبینی	215	27	2026-07-14	approved	0aa7f564-65bd-473d-aa0e-3abc4663b507	\N	8f5942ed-daec-47bc-aed0-faaf456022e4	2026-07-21 12:23:05.653402+00	2026-07-21 12:23:05.653402+00
9e026bc3-66b8-45d7-9c60-0989a6664192	c5d15e1b-a189-4743-a902-05d64ea635d1	6965fa45-fddb-4465-b0e6-042192ac6ee2	پیشرفت اولیه و بررسی نیازمندی‌ها	30	52	2026-07-16	approved	0aa7f564-65bd-473d-aa0e-3abc4663b507	\N	c9865b87-2875-4815-b194-614c545584a2	2026-07-21 12:23:05.653402+00	2026-07-21 12:23:05.653402+00
9e026bc3-66b8-45d7-9c60-0989a6664192	695c5710-742b-473f-ac6d-9a3cac4c704a	0aa7f564-65bd-473d-aa0e-3abc4663b507	پیاده‌سازی بخش اصلی	162	34	2026-07-16	approved	0aa7f564-65bd-473d-aa0e-3abc4663b507	\N	45faf2a1-1113-45f6-8f82-0883bc26c90e	2026-07-21 12:23:05.653402+00	2026-07-21 12:23:05.653402+00
9e026bc3-66b8-45d7-9c60-0989a6664192	695c5710-742b-473f-ac6d-9a3cac4c704a	0aa7f564-65bd-473d-aa0e-3abc4663b507	رفع اشکالات و بازبینی	239	46	2026-07-16	approved	0aa7f564-65bd-473d-aa0e-3abc4663b507	\N	b67dc95d-1bc6-4a37-91ce-7427324988bc	2026-07-21 12:23:05.653402+00	2026-07-21 12:23:05.653402+00
9e026bc3-66b8-45d7-9c60-0989a6664192	695c5710-742b-473f-ac6d-9a3cac4c704a	0aa7f564-65bd-473d-aa0e-3abc4663b507	تست و اطمینان از عملکرد صحیح	48	81	2026-07-16	approved	0aa7f564-65bd-473d-aa0e-3abc4663b507	\N	9502c337-3549-4131-bd27-37819d4b0527	2026-07-21 12:23:05.653402+00	2026-07-21 12:23:05.653402+00
9e026bc3-66b8-45d7-9c60-0989a6664192	695c5710-742b-473f-ac6d-9a3cac4c704a	0aa7f564-65bd-473d-aa0e-3abc4663b507	پیشرفت اولیه و بررسی نیازمندی‌ها	56	100	2026-07-16	approved	0aa7f564-65bd-473d-aa0e-3abc4663b507	\N	15f1a4a4-fce2-41e9-bbc6-db949c01bb84	2026-07-21 12:23:05.653402+00	2026-07-21 12:23:05.653402+00
9e026bc3-66b8-45d7-9c60-0989a6664192	db1bc737-2567-486b-ac8c-2779b7c938d6	6965fa45-fddb-4465-b0e6-042192ac6ee2	پیاده‌سازی بخش اصلی	194	24	2026-06-26	approved	0aa7f564-65bd-473d-aa0e-3abc4663b507	\N	11b47a1b-20fb-403d-99f3-e29b68e3d498	2026-07-21 12:23:05.653402+00	2026-07-21 12:23:05.653402+00
9e026bc3-66b8-45d7-9c60-0989a6664192	db1bc737-2567-486b-ac8c-2779b7c938d6	6965fa45-fddb-4465-b0e6-042192ac6ee2	پیشرفت اولیه و بررسی نیازمندی‌ها	186	80	2026-06-27	approved	0aa7f564-65bd-473d-aa0e-3abc4663b507	\N	769682aa-322b-4ced-b881-515b5eab5dcd	2026-07-21 12:23:05.653402+00	2026-07-21 12:23:05.653402+00
9e026bc3-66b8-45d7-9c60-0989a6664192	db1bc737-2567-486b-ac8c-2779b7c938d6	6965fa45-fddb-4465-b0e6-042192ac6ee2	پیاده‌سازی بخش اصلی	190	72	2026-06-30	approved	0aa7f564-65bd-473d-aa0e-3abc4663b507	\N	f3da06a6-babc-4376-bb04-542124802f90	2026-07-21 12:23:05.653402+00	2026-07-21 12:23:05.653402+00
9e026bc3-66b8-45d7-9c60-0989a6664192	bf26f4f3-8152-4e90-a844-4db1619a92e1	147770ac-f6f9-4af1-97c3-cccc614d44e9	پیشرفت اولیه و بررسی نیازمندی‌ها	55	24	2026-07-09	submitted	\N	\N	126eb417-3706-44a7-96e0-ed8678044919	2026-07-21 12:23:05.653402+00	2026-07-21 12:23:05.653402+00
9e026bc3-66b8-45d7-9c60-0989a6664192	bf26f4f3-8152-4e90-a844-4db1619a92e1	147770ac-f6f9-4af1-97c3-cccc614d44e9	تست و اطمینان از عملکرد صحیح	119	66	2026-07-10	approved	0aa7f564-65bd-473d-aa0e-3abc4663b507	\N	9b353bef-144f-4713-8367-d4ea3da258a5	2026-07-21 12:23:05.653402+00	2026-07-21 12:23:05.653402+00
9e026bc3-66b8-45d7-9c60-0989a6664192	bf26f4f3-8152-4e90-a844-4db1619a92e1	147770ac-f6f9-4af1-97c3-cccc614d44e9	پیاده‌سازی بخش اصلی	100	100	2026-07-15	submitted	\N	\N	6478dd14-8442-4d33-a8a1-d59dffb2087a	2026-07-21 12:23:05.653402+00	2026-07-21 12:23:05.653402+00
9e026bc3-66b8-45d7-9c60-0989a6664192	bf26f4f3-8152-4e90-a844-4db1619a92e1	147770ac-f6f9-4af1-97c3-cccc614d44e9	مستندسازی و نهایی‌سازی	183	100	2026-07-12	approved	0aa7f564-65bd-473d-aa0e-3abc4663b507	\N	e2144179-4df8-4278-9493-051aa3049cca	2026-07-21 12:23:05.653402+00	2026-07-21 12:23:05.653402+00
9e026bc3-66b8-45d7-9c60-0989a6664192	968a9092-0f8c-40ea-b609-2463495f3720	6965fa45-fddb-4465-b0e6-042192ac6ee2	رفع اشکالات و بازبینی	82	36	2026-07-16	approved	0aa7f564-65bd-473d-aa0e-3abc4663b507	\N	03803460-423a-42fd-8a50-e6353645592c	2026-07-21 12:23:05.653402+00	2026-07-21 12:23:05.653402+00
9e026bc3-66b8-45d7-9c60-0989a6664192	968a9092-0f8c-40ea-b609-2463495f3720	6965fa45-fddb-4465-b0e6-042192ac6ee2	تست و اطمینان از عملکرد صحیح	105	80	2026-07-16	approved	0aa7f564-65bd-473d-aa0e-3abc4663b507	\N	dc697d9f-def1-48a0-b224-7d1188c551fb	2026-07-21 12:23:05.653402+00	2026-07-21 12:23:05.653402+00
9e026bc3-66b8-45d7-9c60-0989a6664192	968a9092-0f8c-40ea-b609-2463495f3720	6965fa45-fddb-4465-b0e6-042192ac6ee2	پیاده‌سازی بخش اصلی	156	96	2026-07-16	approved	0aa7f564-65bd-473d-aa0e-3abc4663b507	\N	ed25dbea-0888-4e63-99b1-918591ebd46f	2026-07-21 12:23:05.653402+00	2026-07-21 12:23:05.653402+00
9e026bc3-66b8-45d7-9c60-0989a6664192	7a61eece-61d6-47ff-9ad0-1c250fc558c5	c17589b4-349d-4156-9b66-f7ecf971b52d	تست و اطمینان از عملکرد صحیح	193	39	2026-07-16	approved	0aa7f564-65bd-473d-aa0e-3abc4663b507	\N	ac54426f-8d80-4fee-a0e6-7ea3925eb1e1	2026-07-21 12:23:05.653402+00	2026-07-21 12:23:05.653402+00
9e026bc3-66b8-45d7-9c60-0989a6664192	a9452d8d-6662-4386-a8eb-b769ae1bcd69	6965fa45-fddb-4465-b0e6-042192ac6ee2	رفع اشکالات و بازبینی	111	24	2026-07-16	approved	0aa7f564-65bd-473d-aa0e-3abc4663b507	\N	b8ed6317-192c-4929-bdd3-43e1aeae1f17	2026-07-21 12:23:05.653402+00	2026-07-21 12:23:05.653402+00
9e026bc3-66b8-45d7-9c60-0989a6664192	3e629a15-a309-4ab9-b716-e7c474ef3425	6965fa45-fddb-4465-b0e6-042192ac6ee2	پیاده‌سازی بخش اصلی	225	35	2026-07-16	approved	0aa7f564-65bd-473d-aa0e-3abc4663b507	\N	f0d010cf-2729-4781-bab6-f13e524485b7	2026-07-21 12:23:05.653402+00	2026-07-21 12:23:05.653402+00
9e026bc3-66b8-45d7-9c60-0989a6664192	3e629a15-a309-4ab9-b716-e7c474ef3425	6965fa45-fddb-4465-b0e6-042192ac6ee2	پیشرفت اولیه و بررسی نیازمندی‌ها	33	56	2026-07-16	approved	0aa7f564-65bd-473d-aa0e-3abc4663b507	\N	8e7585f6-5245-445d-aa50-a7c590883ed5	2026-07-21 12:23:05.653402+00	2026-07-21 12:23:05.653402+00
9e026bc3-66b8-45d7-9c60-0989a6664192	3e629a15-a309-4ab9-b716-e7c474ef3425	6965fa45-fddb-4465-b0e6-042192ac6ee2	پیشرفت اولیه و بررسی نیازمندی‌ها	232	96	2026-07-16	approved	0aa7f564-65bd-473d-aa0e-3abc4663b507	\N	d20b26ac-f93b-4d10-9635-9b36375702ce	2026-07-21 12:23:05.653402+00	2026-07-21 12:23:05.653402+00
9e026bc3-66b8-45d7-9c60-0989a6664192	3e629a15-a309-4ab9-b716-e7c474ef3425	6965fa45-fddb-4465-b0e6-042192ac6ee2	مستندسازی و نهایی‌سازی	226	100	2026-07-16	approved	0aa7f564-65bd-473d-aa0e-3abc4663b507	\N	629bb6e8-531b-43f7-a076-8d4b718712c2	2026-07-21 12:23:05.653402+00	2026-07-21 12:23:05.653402+00
9e026bc3-66b8-45d7-9c60-0989a6664192	4659f8dd-ddcd-4725-9ec9-9792b13fe6c9	6965fa45-fddb-4465-b0e6-042192ac6ee2	مستندسازی و نهایی‌سازی	167	39	2026-07-16	approved	0aa7f564-65bd-473d-aa0e-3abc4663b507	\N	0dbb2636-18a5-4c73-b9bb-034dc2087eea	2026-07-21 12:23:05.653402+00	2026-07-21 12:23:05.653402+00
9e026bc3-66b8-45d7-9c60-0989a6664192	4659f8dd-ddcd-4725-9ec9-9792b13fe6c9	6965fa45-fddb-4465-b0e6-042192ac6ee2	رفع اشکالات و بازبینی	50	72	2026-07-16	approved	0aa7f564-65bd-473d-aa0e-3abc4663b507	\N	a9a17f2b-2c42-412a-b2e3-df7a8fd49e44	2026-07-21 12:23:05.653402+00	2026-07-21 12:23:05.653402+00
9e026bc3-66b8-45d7-9c60-0989a6664192	4659f8dd-ddcd-4725-9ec9-9792b13fe6c9	6965fa45-fddb-4465-b0e6-042192ac6ee2	پیاده‌سازی بخش اصلی	167	90	2026-07-16	submitted	\N	\N	74bea6f5-ca9b-40a1-93ac-34025029cd01	2026-07-21 12:23:05.653402+00	2026-07-21 12:23:05.653402+00
9e026bc3-66b8-45d7-9c60-0989a6664192	4659f8dd-ddcd-4725-9ec9-9792b13fe6c9	6965fa45-fddb-4465-b0e6-042192ac6ee2	پیشرفت اولیه و بررسی نیازمندی‌ها	109	100	2026-07-16	approved	0aa7f564-65bd-473d-aa0e-3abc4663b507	\N	c44f5496-7a5a-43ef-b846-d33141cbe96a	2026-07-21 12:23:05.653402+00	2026-07-21 12:23:05.653402+00
9e026bc3-66b8-45d7-9c60-0989a6664192	01e186df-6228-4ecf-88ee-e1732585bd62	6965fa45-fddb-4465-b0e6-042192ac6ee2	پیاده‌سازی بخش اصلی	52	33	2026-07-16	approved	0aa7f564-65bd-473d-aa0e-3abc4663b507	\N	d88cefe8-ad31-4831-a767-0d0143d1efd8	2026-07-21 12:23:05.653402+00	2026-07-21 12:23:05.653402+00
9e026bc3-66b8-45d7-9c60-0989a6664192	01e186df-6228-4ecf-88ee-e1732585bd62	6965fa45-fddb-4465-b0e6-042192ac6ee2	تست و اطمینان از عملکرد صحیح	186	78	2026-07-16	approved	0aa7f564-65bd-473d-aa0e-3abc4663b507	\N	658831fb-fbc9-4400-9d78-556a632a6695	2026-07-21 12:23:05.653402+00	2026-07-21 12:23:05.653402+00
9e026bc3-66b8-45d7-9c60-0989a6664192	d8189b1d-dfac-4d17-85d3-ae548bd7f1fd	147770ac-f6f9-4af1-97c3-cccc614d44e9	پیاده‌سازی بخش اصلی	60	20	2026-07-16	approved	0aa7f564-65bd-473d-aa0e-3abc4663b507	\N	c3dfe017-9286-4998-a8c6-0003b6300607	2026-07-21 12:23:05.653402+00	2026-07-21 12:23:05.653402+00
9e026bc3-66b8-45d7-9c60-0989a6664192	61d9a59e-6de5-49a0-aeae-5d342a72136f	6965fa45-fddb-4465-b0e6-042192ac6ee2	پیاده‌سازی بخش اصلی	157	31	2026-06-30	approved	0aa7f564-65bd-473d-aa0e-3abc4663b507	\N	58578727-05af-4bad-832e-c350957558f0	2026-07-21 12:23:05.653402+00	2026-07-21 12:23:05.653402+00
9e026bc3-66b8-45d7-9c60-0989a6664192	61d9a59e-6de5-49a0-aeae-5d342a72136f	6965fa45-fddb-4465-b0e6-042192ac6ee2	پیاده‌سازی بخش اصلی	125	48	2026-07-03	approved	0aa7f564-65bd-473d-aa0e-3abc4663b507	\N	116d91fb-b0a4-43f3-a678-129b826a86cc	2026-07-21 12:23:05.653402+00	2026-07-21 12:23:05.653402+00
9e026bc3-66b8-45d7-9c60-0989a6664192	fe24aea6-e863-459e-9ab0-c5ec81c5f219	6965fa45-fddb-4465-b0e6-042192ac6ee2	پیشرفت اولیه و بررسی نیازمندی‌ها	115	33	2026-07-13	approved	0aa7f564-65bd-473d-aa0e-3abc4663b507	\N	d9de67c7-a4dc-4823-93e0-e8ef41638657	2026-07-21 12:23:05.653402+00	2026-07-21 12:23:05.653402+00
9e026bc3-66b8-45d7-9c60-0989a6664192	fe24aea6-e863-459e-9ab0-c5ec81c5f219	6965fa45-fddb-4465-b0e6-042192ac6ee2	مستندسازی و نهایی‌سازی	46	56	2026-07-16	approved	0aa7f564-65bd-473d-aa0e-3abc4663b507	\N	b5dc99b8-42f9-4afd-94e6-bf897675c052	2026-07-21 12:23:05.653402+00	2026-07-21 12:23:05.653402+00
9e026bc3-66b8-45d7-9c60-0989a6664192	fe24aea6-e863-459e-9ab0-c5ec81c5f219	6965fa45-fddb-4465-b0e6-042192ac6ee2	تست و اطمینان از عملکرد صحیح	146	100	2026-07-15	approved	0aa7f564-65bd-473d-aa0e-3abc4663b507	\N	2b6237c8-ae1a-470b-b56c-5548deda4d2b	2026-07-21 12:23:05.653402+00	2026-07-21 12:23:05.653402+00
9e026bc3-66b8-45d7-9c60-0989a6664192	6756ee7b-5220-454b-8443-a9185fdfba7a	147770ac-f6f9-4af1-97c3-cccc614d44e9	مستندسازی و نهایی‌سازی	72	31	2026-07-16	approved	0aa7f564-65bd-473d-aa0e-3abc4663b507	\N	ac2c9a48-509f-49e2-875e-71de680e29e6	2026-07-21 12:23:05.653402+00	2026-07-21 12:23:05.653402+00
9e026bc3-66b8-45d7-9c60-0989a6664192	6756ee7b-5220-454b-8443-a9185fdfba7a	147770ac-f6f9-4af1-97c3-cccc614d44e9	پیشرفت اولیه و بررسی نیازمندی‌ها	176	46	2026-07-16	approved	0aa7f564-65bd-473d-aa0e-3abc4663b507	\N	06f02d6c-5210-4f3c-bfeb-0d889d57380b	2026-07-21 12:23:05.653402+00	2026-07-21 12:23:05.653402+00
9e026bc3-66b8-45d7-9c60-0989a6664192	6756ee7b-5220-454b-8443-a9185fdfba7a	147770ac-f6f9-4af1-97c3-cccc614d44e9	پیشرفت اولیه و بررسی نیازمندی‌ها	41	60	2026-07-16	submitted	\N	\N	e4a94463-0771-4bb0-bb95-d04f86b7870a	2026-07-21 12:23:05.653402+00	2026-07-21 12:23:05.653402+00
9e026bc3-66b8-45d7-9c60-0989a6664192	5603f2c3-3b95-400a-b1b2-e6b5f2f0d770	0aa7f564-65bd-473d-aa0e-3abc4663b507	تست و اطمینان از عملکرد صحیح	123	32	2026-07-16	approved	0aa7f564-65bd-473d-aa0e-3abc4663b507	\N	e324f44b-b6d8-4905-a33a-03f7478ad01d	2026-07-21 12:23:05.653402+00	2026-07-21 12:23:05.653402+00
9e026bc3-66b8-45d7-9c60-0989a6664192	5603f2c3-3b95-400a-b1b2-e6b5f2f0d770	0aa7f564-65bd-473d-aa0e-3abc4663b507	پیاده‌سازی بخش اصلی	39	74	2026-07-16	approved	0aa7f564-65bd-473d-aa0e-3abc4663b507	\N	19b7b882-92ce-45c9-9074-476f5e95921a	2026-07-21 12:23:05.653402+00	2026-07-21 12:23:05.653402+00
9e026bc3-66b8-45d7-9c60-0989a6664192	8ed90b0b-bff2-4a60-9543-430d33ad04ff	6965fa45-fddb-4465-b0e6-042192ac6ee2	تست و اطمینان از عملکرد صحیح	214	30	2026-07-16	approved	0aa7f564-65bd-473d-aa0e-3abc4663b507	\N	83bc4256-0f16-4b0e-b28d-011064fcd090	2026-07-21 12:23:05.653402+00	2026-07-21 12:23:05.653402+00
9e026bc3-66b8-45d7-9c60-0989a6664192	8ed90b0b-bff2-4a60-9543-430d33ad04ff	6965fa45-fddb-4465-b0e6-042192ac6ee2	مستندسازی و نهایی‌سازی	125	46	2026-07-16	submitted	\N	\N	5031ecd7-ef7b-4eb1-bce1-c4182d146668	2026-07-21 12:23:05.653402+00	2026-07-21 12:23:05.653402+00
9e026bc3-66b8-45d7-9c60-0989a6664192	8ed90b0b-bff2-4a60-9543-430d33ad04ff	6965fa45-fddb-4465-b0e6-042192ac6ee2	مستندسازی و نهایی‌سازی	41	96	2026-07-16	approved	0aa7f564-65bd-473d-aa0e-3abc4663b507	\N	911b792d-66eb-455b-bf3b-101444d70a26	2026-07-21 12:23:05.653402+00	2026-07-21 12:23:05.653402+00
9e026bc3-66b8-45d7-9c60-0989a6664192	8ed90b0b-bff2-4a60-9543-430d33ad04ff	6965fa45-fddb-4465-b0e6-042192ac6ee2	رفع اشکالات و بازبینی	228	100	2026-07-16	submitted	\N	\N	496af250-2131-4292-9b07-3c00ee68493f	2026-07-21 12:23:05.653402+00	2026-07-21 12:23:05.653402+00
9e026bc3-66b8-45d7-9c60-0989a6664192	94279e2b-2f2e-4c65-a538-9a8af31fcc28	e5c268f5-5274-4960-be2b-6f7bbba26625	پیشرفت اولیه و بررسی نیازمندی‌ها	124	26	2026-07-16	approved	0aa7f564-65bd-473d-aa0e-3abc4663b507	\N	b6c232e0-8a4b-4020-adab-8ea51d516ccf	2026-07-21 12:23:05.653402+00	2026-07-21 12:23:05.653402+00
9e026bc3-66b8-45d7-9c60-0989a6664192	94279e2b-2f2e-4c65-a538-9a8af31fcc28	e5c268f5-5274-4960-be2b-6f7bbba26625	رفع اشکالات و بازبینی	219	78	2026-07-16	approved	0aa7f564-65bd-473d-aa0e-3abc4663b507	\N	1978c2f1-532f-4b74-a287-a2f7d2be4e92	2026-07-21 12:23:05.653402+00	2026-07-21 12:23:05.653402+00
9e026bc3-66b8-45d7-9c60-0989a6664192	94279e2b-2f2e-4c65-a538-9a8af31fcc28	e5c268f5-5274-4960-be2b-6f7bbba26625	مستندسازی و نهایی‌سازی	156	78	2026-07-16	approved	0aa7f564-65bd-473d-aa0e-3abc4663b507	\N	959b5fbe-5a71-4b5a-bffb-b07a6233e376	2026-07-21 12:23:05.653402+00	2026-07-21 12:23:05.653402+00
9e026bc3-66b8-45d7-9c60-0989a6664192	900b66d7-cd14-4586-b8a2-cd640bee326d	c17589b4-349d-4156-9b66-f7ecf971b52d	تست و اطمینان از عملکرد صحیح	36	27	2026-07-01	approved	0aa7f564-65bd-473d-aa0e-3abc4663b507	\N	4be7d8a8-3dbd-45f2-a3c3-5bdb5065aa9b	2026-07-21 12:23:05.653402+00	2026-07-21 12:23:05.653402+00
9e026bc3-66b8-45d7-9c60-0989a6664192	900b66d7-cd14-4586-b8a2-cd640bee326d	c17589b4-349d-4156-9b66-f7ecf971b52d	پیشرفت اولیه و بررسی نیازمندی‌ها	115	40	2026-07-04	approved	0aa7f564-65bd-473d-aa0e-3abc4663b507	\N	c85cab04-30a1-46ce-9ee6-4d62c7b76dd0	2026-07-21 12:23:05.653402+00	2026-07-21 12:23:05.653402+00
9e026bc3-66b8-45d7-9c60-0989a6664192	8843e95c-c043-4139-accf-c554bad4e803	e5c268f5-5274-4960-be2b-6f7bbba26625	مستندسازی و نهایی‌سازی	90	33	2026-06-19	approved	0aa7f564-65bd-473d-aa0e-3abc4663b507	\N	5846add9-9b6c-444d-bbc5-4496277e8890	2026-07-21 12:23:05.653402+00	2026-07-21 12:23:05.653402+00
9e026bc3-66b8-45d7-9c60-0989a6664192	8843e95c-c043-4139-accf-c554bad4e803	e5c268f5-5274-4960-be2b-6f7bbba26625	پیاده‌سازی بخش اصلی	212	56	2026-06-23	submitted	\N	\N	20d39970-d849-47fb-a5c5-a5a391dd906b	2026-07-21 12:23:05.653402+00	2026-07-21 12:23:05.653402+00
9e026bc3-66b8-45d7-9c60-0989a6664192	8843e95c-c043-4139-accf-c554bad4e803	e5c268f5-5274-4960-be2b-6f7bbba26625	پیاده‌سازی بخش اصلی	163	99	2026-06-21	approved	0aa7f564-65bd-473d-aa0e-3abc4663b507	\N	6106592a-f741-4030-a7bb-402b4c7b5630	2026-07-21 12:23:05.653402+00	2026-07-21 12:23:05.653402+00
9e026bc3-66b8-45d7-9c60-0989a6664192	8843e95c-c043-4139-accf-c554bad4e803	e5c268f5-5274-4960-be2b-6f7bbba26625	پیشرفت اولیه و بررسی نیازمندی‌ها	178	92	2026-06-28	approved	0aa7f564-65bd-473d-aa0e-3abc4663b507	\N	030fc857-5dbd-47e5-9f5b-0bd348221d74	2026-07-21 12:23:05.653402+00	2026-07-21 12:23:05.653402+00
9e026bc3-66b8-45d7-9c60-0989a6664192	bfb2d86f-a464-43b5-b73a-26077a03d312	6965fa45-fddb-4465-b0e6-042192ac6ee2	پیشرفت اولیه و بررسی نیازمندی‌ها	181	38	2026-07-08	approved	0aa7f564-65bd-473d-aa0e-3abc4663b507	\N	0492657a-1558-4455-9796-c9a1bf11f799	2026-07-21 12:23:05.653402+00	2026-07-21 12:23:05.653402+00
9e026bc3-66b8-45d7-9c60-0989a6664192	bfb2d86f-a464-43b5-b73a-26077a03d312	6965fa45-fddb-4465-b0e6-042192ac6ee2	تست و اطمینان از عملکرد صحیح	199	48	2026-07-09	approved	0aa7f564-65bd-473d-aa0e-3abc4663b507	\N	67095d67-3874-4131-b8ac-99132c5759bd	2026-07-21 12:23:05.653402+00	2026-07-21 12:23:05.653402+00
9e026bc3-66b8-45d7-9c60-0989a6664192	a2af9c87-07d7-48a0-a12d-14f87c4669ff	6965fa45-fddb-4465-b0e6-042192ac6ee2	رفع اشکالات و بازبینی	235	32	2026-06-25	approved	0aa7f564-65bd-473d-aa0e-3abc4663b507	\N	8f886825-520a-469f-9210-58f4a4e4c9ae	2026-07-21 12:23:05.653402+00	2026-07-21 12:23:05.653402+00
9e026bc3-66b8-45d7-9c60-0989a6664192	a2af9c87-07d7-48a0-a12d-14f87c4669ff	6965fa45-fddb-4465-b0e6-042192ac6ee2	رفع اشکالات و بازبینی	89	44	2026-06-28	approved	0aa7f564-65bd-473d-aa0e-3abc4663b507	\N	5ac0a9d7-c7a8-4d5e-9e7b-3159043edbc1	2026-07-21 12:23:05.653402+00	2026-07-21 12:23:05.653402+00
9e026bc3-66b8-45d7-9c60-0989a6664192	57f2887f-356d-4cef-bf91-5dd01c3b7f0a	c17589b4-349d-4156-9b66-f7ecf971b52d	مستندسازی و نهایی‌سازی	57	24	2026-07-05	submitted	\N	\N	0df27017-bfee-4c2b-89fd-fea7717c3d73	2026-07-21 12:23:05.653402+00	2026-07-21 12:23:05.653402+00
9e026bc3-66b8-45d7-9c60-0989a6664192	57f2887f-356d-4cef-bf91-5dd01c3b7f0a	c17589b4-349d-4156-9b66-f7ecf971b52d	تست و اطمینان از عملکرد صحیح	110	66	2026-07-06	approved	0aa7f564-65bd-473d-aa0e-3abc4663b507	\N	137426bc-6c11-45fd-9d62-7198d27672d0	2026-07-21 12:23:05.653402+00	2026-07-21 12:23:05.653402+00
9e026bc3-66b8-45d7-9c60-0989a6664192	e6712361-5302-43f9-b1a8-27a620b2b9da	6965fa45-fddb-4465-b0e6-042192ac6ee2	پیاده‌سازی بخش اصلی	145	29	2026-07-10	approved	0aa7f564-65bd-473d-aa0e-3abc4663b507	\N	2c6f77d8-9728-44ee-a328-b4ae1e982578	2026-07-21 12:23:05.653402+00	2026-07-21 12:23:05.653402+00
9e026bc3-66b8-45d7-9c60-0989a6664192	0de7d11e-7e0b-4331-9df7-b2356b3a346e	0aa7f564-65bd-473d-aa0e-3abc4663b507	پیشرفت اولیه و بررسی نیازمندی‌ها	53	25	2026-06-21	approved	0aa7f564-65bd-473d-aa0e-3abc4663b507	\N	c93d452a-e5f8-4b2b-9fb1-1387ef1246bc	2026-07-21 12:23:05.653402+00	2026-07-21 12:23:05.653402+00
9e026bc3-66b8-45d7-9c60-0989a6664192	0de7d11e-7e0b-4331-9df7-b2356b3a346e	0aa7f564-65bd-473d-aa0e-3abc4663b507	مستندسازی و نهایی‌سازی	40	52	2026-06-24	approved	0aa7f564-65bd-473d-aa0e-3abc4663b507	\N	ee598aed-565e-41d5-aee3-9f6dab666608	2026-07-21 12:23:05.653402+00	2026-07-21 12:23:05.653402+00
9e026bc3-66b8-45d7-9c60-0989a6664192	0de7d11e-7e0b-4331-9df7-b2356b3a346e	0aa7f564-65bd-473d-aa0e-3abc4663b507	پیاده‌سازی بخش اصلی	53	81	2026-06-27	approved	0aa7f564-65bd-473d-aa0e-3abc4663b507	\N	f1a3cd31-1cba-4960-ad14-9de67a700672	2026-07-21 12:23:05.653402+00	2026-07-21 12:23:05.653402+00
9e026bc3-66b8-45d7-9c60-0989a6664192	0de7d11e-7e0b-4331-9df7-b2356b3a346e	0aa7f564-65bd-473d-aa0e-3abc4663b507	تست و اطمینان از عملکرد صحیح	161	84	2026-06-30	approved	0aa7f564-65bd-473d-aa0e-3abc4663b507	\N	5d83f405-bd68-4103-8158-87db4b15f5e7	2026-07-21 12:23:05.653402+00	2026-07-21 12:23:05.653402+00
9e026bc3-66b8-45d7-9c60-0989a6664192	dbd913a6-1b8e-4e3d-83fc-62136f474292	6965fa45-fddb-4465-b0e6-042192ac6ee2	پیاده‌سازی بخش اصلی	37	32	2026-06-18	approved	0aa7f564-65bd-473d-aa0e-3abc4663b507	\N	c2e71316-b710-47d6-922f-f02c8090f891	2026-07-21 12:23:05.653402+00	2026-07-21 12:23:05.653402+00
9e026bc3-66b8-45d7-9c60-0989a6664192	dbd913a6-1b8e-4e3d-83fc-62136f474292	6965fa45-fddb-4465-b0e6-042192ac6ee2	مستندسازی و نهایی‌سازی	221	74	2026-06-22	approved	0aa7f564-65bd-473d-aa0e-3abc4663b507	\N	4bffaccf-5732-43ce-b849-13d5bab6a981	2026-07-21 12:23:05.653402+00	2026-07-21 12:23:05.653402+00
9e026bc3-66b8-45d7-9c60-0989a6664192	dbd913a6-1b8e-4e3d-83fc-62136f474292	6965fa45-fddb-4465-b0e6-042192ac6ee2	پیشرفت اولیه و بررسی نیازمندی‌ها	148	69	2026-06-22	approved	0aa7f564-65bd-473d-aa0e-3abc4663b507	\N	9bae2be3-c274-40e2-a246-efa81e911d06	2026-07-21 12:23:05.653402+00	2026-07-21 12:23:05.653402+00
9e026bc3-66b8-45d7-9c60-0989a6664192	428518ff-1bc7-4c5c-8c76-00132bace5c5	515597de-809a-4b6a-9fb6-5e2cf6d9dfe2	پیاده‌سازی بخش اصلی	63	26	2026-07-16	approved	0aa7f564-65bd-473d-aa0e-3abc4663b507	\N	5c786d77-b274-4eeb-a718-a19f7e1d4d0f	2026-07-21 12:23:05.653402+00	2026-07-21 12:23:05.653402+00
9e026bc3-66b8-45d7-9c60-0989a6664192	428518ff-1bc7-4c5c-8c76-00132bace5c5	515597de-809a-4b6a-9fb6-5e2cf6d9dfe2	پیشرفت اولیه و بررسی نیازمندی‌ها	179	76	2026-07-16	approved	0aa7f564-65bd-473d-aa0e-3abc4663b507	\N	bef91396-486c-45c5-96fc-cd1f3344e536	2026-07-21 12:23:05.653402+00	2026-07-21 12:23:05.653402+00
9e026bc3-66b8-45d7-9c60-0989a6664192	05f28521-2dc9-4e7b-ac1b-2d5be0e36248	0aa7f564-65bd-473d-aa0e-3abc4663b507	پیشرفت اولیه و بررسی نیازمندی‌ها	80	40	2026-07-16	approved	0aa7f564-65bd-473d-aa0e-3abc4663b507	\N	c1eaa615-fcae-4189-a75f-6ced964a6686	2026-07-21 12:23:05.653402+00	2026-07-21 12:23:05.653402+00
9e026bc3-66b8-45d7-9c60-0989a6664192	05f28521-2dc9-4e7b-ac1b-2d5be0e36248	0aa7f564-65bd-473d-aa0e-3abc4663b507	پیشرفت اولیه و بررسی نیازمندی‌ها	237	60	2026-07-16	submitted	\N	\N	59d525ad-08f0-48ce-a448-f6f476fad503	2026-07-21 12:23:05.653402+00	2026-07-21 12:23:05.653402+00
9e026bc3-66b8-45d7-9c60-0989a6664192	05f28521-2dc9-4e7b-ac1b-2d5be0e36248	0aa7f564-65bd-473d-aa0e-3abc4663b507	تست و اطمینان از عملکرد صحیح	42	75	2026-07-16	approved	0aa7f564-65bd-473d-aa0e-3abc4663b507	\N	2fcf7cbe-544b-451c-95b6-8beebfb18fcc	2026-07-21 12:23:05.653402+00	2026-07-21 12:23:05.653402+00
9e026bc3-66b8-45d7-9c60-0989a6664192	45622c7e-f4cb-47e1-a54e-5a92c367e785	147770ac-f6f9-4af1-97c3-cccc614d44e9	تست و اطمینان از عملکرد صحیح	37	32	2026-07-11	approved	0aa7f564-65bd-473d-aa0e-3abc4663b507	\N	e4ab3f22-f195-480c-8c4d-1bdeeca53aa0	2026-07-21 12:23:05.653402+00	2026-07-21 12:23:05.653402+00
9e026bc3-66b8-45d7-9c60-0989a6664192	45622c7e-f4cb-47e1-a54e-5a92c367e785	147770ac-f6f9-4af1-97c3-cccc614d44e9	پیاده‌سازی بخش اصلی	120	52	2026-07-15	approved	0aa7f564-65bd-473d-aa0e-3abc4663b507	\N	2135e500-45d6-4b39-a77a-2d97ca6c1522	2026-07-21 12:23:05.653402+00	2026-07-21 12:23:05.653402+00
9e026bc3-66b8-45d7-9c60-0989a6664192	45622c7e-f4cb-47e1-a54e-5a92c367e785	147770ac-f6f9-4af1-97c3-cccc614d44e9	رفع اشکالات و بازبینی	101	100	2026-07-15	approved	0aa7f564-65bd-473d-aa0e-3abc4663b507	\N	a1b9278a-4cb8-479d-84fd-971541fdc628	2026-07-21 12:23:05.653402+00	2026-07-21 12:23:05.653402+00
9e026bc3-66b8-45d7-9c60-0989a6664192	45622c7e-f4cb-47e1-a54e-5a92c367e785	147770ac-f6f9-4af1-97c3-cccc614d44e9	پیشرفت اولیه و بررسی نیازمندی‌ها	187	100	2026-07-16	approved	0aa7f564-65bd-473d-aa0e-3abc4663b507	\N	ca364f38-36e2-473e-b497-84b788c6e27d	2026-07-21 12:23:05.653402+00	2026-07-21 12:23:05.653402+00
9e026bc3-66b8-45d7-9c60-0989a6664192	b1e32fb9-b275-4e58-8251-182c11a5a872	be682dce-6665-4ff0-8e8a-067602882309	رفع اشکالات و بازبینی	43	27	2026-07-16	submitted	\N	\N	5fe10451-227e-42f2-9452-952e6d26b25e	2026-07-21 12:23:05.653402+00	2026-07-21 12:23:05.653402+00
9e026bc3-66b8-45d7-9c60-0989a6664192	b1e32fb9-b275-4e58-8251-182c11a5a872	be682dce-6665-4ff0-8e8a-067602882309	مستندسازی و نهایی‌سازی	183	70	2026-07-16	approved	be682dce-6665-4ff0-8e8a-067602882309	\N	04b53227-224f-4f53-8302-3ee673086c50	2026-07-21 12:23:05.653402+00	2026-07-21 12:23:05.653402+00
9e026bc3-66b8-45d7-9c60-0989a6664192	4b08a485-43df-41e7-944d-f3d1f147ec5b	37e62239-b7c6-493c-9475-fe700a479e79	پیشرفت اولیه و بررسی نیازمندی‌ها	54	27	2026-07-16	approved	be682dce-6665-4ff0-8e8a-067602882309	\N	868edd15-dbe0-4ef3-830a-8327695fe9e6	2026-07-21 12:23:05.653402+00	2026-07-21 12:23:05.653402+00
9e026bc3-66b8-45d7-9c60-0989a6664192	4b08a485-43df-41e7-944d-f3d1f147ec5b	37e62239-b7c6-493c-9475-fe700a479e79	رفع اشکالات و بازبینی	120	80	2026-07-16	approved	be682dce-6665-4ff0-8e8a-067602882309	\N	676e2b01-824e-434a-aadd-84a72f3f9050	2026-07-21 12:23:05.653402+00	2026-07-21 12:23:05.653402+00
9e026bc3-66b8-45d7-9c60-0989a6664192	4b08a485-43df-41e7-944d-f3d1f147ec5b	37e62239-b7c6-493c-9475-fe700a479e79	مستندسازی و نهایی‌سازی	163	93	2026-07-16	approved	be682dce-6665-4ff0-8e8a-067602882309	\N	86c628cb-f8f7-45ca-81f7-d72d8b54ac1a	2026-07-21 12:23:05.653402+00	2026-07-21 12:23:05.653402+00
9e026bc3-66b8-45d7-9c60-0989a6664192	aa4bb3c3-7877-46cc-a19f-9da09052911b	fe6b733f-8cf4-4df1-a83e-2e854a480178	پیاده‌سازی بخش اصلی	156	24	2026-07-16	approved	be682dce-6665-4ff0-8e8a-067602882309	\N	c05d8a18-d92a-4d7a-9e2f-830798d2cb88	2026-07-21 12:23:05.653402+00	2026-07-21 12:23:05.653402+00
9e026bc3-66b8-45d7-9c60-0989a6664192	fddc6fc9-15f6-467c-a67d-607252d4a6cd	3cdfd222-0ea4-4a30-b15b-036d1d733193	رفع اشکالات و بازبینی	186	26	2026-07-07	approved	be682dce-6665-4ff0-8e8a-067602882309	\N	c359e99a-6c47-471c-8773-f33ac0c2e9a0	2026-07-21 12:23:05.653402+00	2026-07-21 12:23:05.653402+00
9e026bc3-66b8-45d7-9c60-0989a6664192	fddc6fc9-15f6-467c-a67d-607252d4a6cd	3cdfd222-0ea4-4a30-b15b-036d1d733193	پیشرفت اولیه و بررسی نیازمندی‌ها	130	52	2026-07-09	approved	be682dce-6665-4ff0-8e8a-067602882309	\N	bc53589b-8979-4918-af23-f61024f31003	2026-07-21 12:23:05.653402+00	2026-07-21 12:23:05.653402+00
9e026bc3-66b8-45d7-9c60-0989a6664192	fddc6fc9-15f6-467c-a67d-607252d4a6cd	3cdfd222-0ea4-4a30-b15b-036d1d733193	پیاده‌سازی بخش اصلی	213	90	2026-07-15	approved	be682dce-6665-4ff0-8e8a-067602882309	\N	df46180e-3873-40b9-96dc-3cfda9aee56b	2026-07-21 12:23:05.653402+00	2026-07-21 12:23:05.653402+00
9e026bc3-66b8-45d7-9c60-0989a6664192	fddc6fc9-15f6-467c-a67d-607252d4a6cd	3cdfd222-0ea4-4a30-b15b-036d1d733193	تست و اطمینان از عملکرد صحیح	41	100	2026-07-10	approved	be682dce-6665-4ff0-8e8a-067602882309	\N	38fbcb0c-ddf8-4f32-ac0f-ddda6a84123a	2026-07-21 12:23:05.653402+00	2026-07-21 12:23:05.653402+00
9e026bc3-66b8-45d7-9c60-0989a6664192	47dc122d-49e5-4b1d-ac24-1bf52b4e9ae4	2310cdf5-d549-4a28-bc04-2052038876fc	تست و اطمینان از عملکرد صحیح	198	38	2026-07-12	approved	be682dce-6665-4ff0-8e8a-067602882309	\N	ca8fe367-c3fa-4936-9405-0a52c4e1be20	2026-07-21 12:23:05.653402+00	2026-07-21 12:23:05.653402+00
9e026bc3-66b8-45d7-9c60-0989a6664192	5a08fad3-9dc7-4de3-8e0b-37a3ea60bbed	fe6b733f-8cf4-4df1-a83e-2e854a480178	پیشرفت اولیه و بررسی نیازمندی‌ها	165	21	2026-07-16	approved	be682dce-6665-4ff0-8e8a-067602882309	\N	d88f22ab-90ee-41cd-a8db-092c94d589b7	2026-07-21 12:23:05.653402+00	2026-07-21 12:23:05.653402+00
9e026bc3-66b8-45d7-9c60-0989a6664192	5a08fad3-9dc7-4de3-8e0b-37a3ea60bbed	fe6b733f-8cf4-4df1-a83e-2e854a480178	مستندسازی و نهایی‌سازی	153	72	2026-07-16	approved	be682dce-6665-4ff0-8e8a-067602882309	\N	a807aa9f-ab9f-4ecb-983e-c983e862445f	2026-07-21 12:23:05.653402+00	2026-07-21 12:23:05.653402+00
9e026bc3-66b8-45d7-9c60-0989a6664192	929261b9-baa8-4785-90c4-b1e407e23115	3cdfd222-0ea4-4a30-b15b-036d1d733193	پیاده‌سازی بخش اصلی	56	32	2026-06-26	submitted	\N	\N	4c34d6f7-0e5e-4089-8bee-d44219768548	2026-07-21 12:23:05.653402+00	2026-07-21 12:23:05.653402+00
9e026bc3-66b8-45d7-9c60-0989a6664192	929261b9-baa8-4785-90c4-b1e407e23115	3cdfd222-0ea4-4a30-b15b-036d1d733193	تست و اطمینان از عملکرد صحیح	137	78	2026-06-29	approved	be682dce-6665-4ff0-8e8a-067602882309	\N	5fa7795b-33be-41e3-b029-ea5abcd270d5	2026-07-21 12:23:05.653402+00	2026-07-21 12:23:05.653402+00
9e026bc3-66b8-45d7-9c60-0989a6664192	4402446b-0333-4bf9-bece-0d98b3462256	37e62239-b7c6-493c-9475-fe700a479e79	رفع اشکالات و بازبینی	105	34	2026-07-16	approved	be682dce-6665-4ff0-8e8a-067602882309	\N	9c537044-9e8f-4165-bfb6-1832c51a8a2a	2026-07-21 12:23:05.653402+00	2026-07-21 12:23:05.653402+00
9e026bc3-66b8-45d7-9c60-0989a6664192	4402446b-0333-4bf9-bece-0d98b3462256	37e62239-b7c6-493c-9475-fe700a479e79	مستندسازی و نهایی‌سازی	209	72	2026-07-16	approved	be682dce-6665-4ff0-8e8a-067602882309	\N	91c68ef3-ad80-4294-b83b-329fbe20fc76	2026-07-21 12:23:05.653402+00	2026-07-21 12:23:05.653402+00
9e026bc3-66b8-45d7-9c60-0989a6664192	0b087d01-6c60-46b4-b185-e1c00f52b379	fe6b733f-8cf4-4df1-a83e-2e854a480178	مستندسازی و نهایی‌سازی	191	26	2026-07-01	submitted	\N	\N	c3b17694-c075-4310-9b26-087eede2360b	2026-07-21 12:23:05.653402+00	2026-07-21 12:23:05.653402+00
9e026bc3-66b8-45d7-9c60-0989a6664192	0b087d01-6c60-46b4-b185-e1c00f52b379	fe6b733f-8cf4-4df1-a83e-2e854a480178	رفع اشکالات و بازبینی	205	62	2026-07-03	approved	be682dce-6665-4ff0-8e8a-067602882309	\N	163fa23c-7aca-483f-8a57-0479551b7d3d	2026-07-21 12:23:05.653402+00	2026-07-21 12:23:05.653402+00
9e026bc3-66b8-45d7-9c60-0989a6664192	0b087d01-6c60-46b4-b185-e1c00f52b379	fe6b733f-8cf4-4df1-a83e-2e854a480178	پیاده‌سازی بخش اصلی	158	100	2026-07-05	submitted	\N	\N	3e232664-a0a7-4a4d-99da-3481b8feb5ba	2026-07-21 12:23:05.653402+00	2026-07-21 12:23:05.653402+00
9e026bc3-66b8-45d7-9c60-0989a6664192	86f0ac5e-c5de-4d44-8d92-250bdda21fdc	3cdfd222-0ea4-4a30-b15b-036d1d733193	رفع اشکالات و بازبینی	173	35	2026-06-28	approved	be682dce-6665-4ff0-8e8a-067602882309	\N	688a3860-da03-4120-87fe-9140ee6509dc	2026-07-21 12:23:05.653402+00	2026-07-21 12:23:05.653402+00
9e026bc3-66b8-45d7-9c60-0989a6664192	86f0ac5e-c5de-4d44-8d92-250bdda21fdc	3cdfd222-0ea4-4a30-b15b-036d1d733193	مستندسازی و نهایی‌سازی	103	66	2026-07-02	approved	be682dce-6665-4ff0-8e8a-067602882309	\N	3a4c7257-577a-473c-9276-e05db4fc27b2	2026-07-21 12:23:05.653402+00	2026-07-21 12:23:05.653402+00
9e026bc3-66b8-45d7-9c60-0989a6664192	86f0ac5e-c5de-4d44-8d92-250bdda21fdc	3cdfd222-0ea4-4a30-b15b-036d1d733193	مستندسازی و نهایی‌سازی	57	60	2026-06-30	approved	be682dce-6665-4ff0-8e8a-067602882309	\N	23c3c222-3010-42a0-8de4-67a93fd77641	2026-07-21 12:23:05.653402+00	2026-07-21 12:23:05.653402+00
9e026bc3-66b8-45d7-9c60-0989a6664192	45e1e171-e49a-4f18-b7d1-c6c1b5012c11	3cdfd222-0ea4-4a30-b15b-036d1d733193	پیشرفت اولیه و بررسی نیازمندی‌ها	81	28	2026-06-21	approved	be682dce-6665-4ff0-8e8a-067602882309	\N	9522c816-19b3-412d-b039-11f18271c78a	2026-07-21 12:23:05.653402+00	2026-07-21 12:23:05.653402+00
9e026bc3-66b8-45d7-9c60-0989a6664192	45e1e171-e49a-4f18-b7d1-c6c1b5012c11	3cdfd222-0ea4-4a30-b15b-036d1d733193	رفع اشکالات و بازبینی	67	42	2026-06-23	submitted	\N	\N	79256b58-a53d-40ca-8d8d-96be4fd550df	2026-07-21 12:23:05.653402+00	2026-07-21 12:23:05.653402+00
9e026bc3-66b8-45d7-9c60-0989a6664192	45e1e171-e49a-4f18-b7d1-c6c1b5012c11	3cdfd222-0ea4-4a30-b15b-036d1d733193	مستندسازی و نهایی‌سازی	38	93	2026-06-27	approved	be682dce-6665-4ff0-8e8a-067602882309	\N	72c340e2-7fea-48c1-9657-aab9f22064e0	2026-07-21 12:23:05.653402+00	2026-07-21 12:23:05.653402+00
9e026bc3-66b8-45d7-9c60-0989a6664192	45e1e171-e49a-4f18-b7d1-c6c1b5012c11	3cdfd222-0ea4-4a30-b15b-036d1d733193	مستندسازی و نهایی‌سازی	87	100	2026-07-03	approved	be682dce-6665-4ff0-8e8a-067602882309	\N	08cfb75f-3f04-42b8-92f7-a20dfaf1a2c3	2026-07-21 12:23:05.653402+00	2026-07-21 12:23:05.653402+00
9e026bc3-66b8-45d7-9c60-0989a6664192	1fc13c47-7465-47b0-9734-db741cadd6d3	1f7a4d5f-3f0b-4a87-92e9-cf7057b674f5	رفع اشکالات و بازبینی	207	21	2026-07-16	approved	be682dce-6665-4ff0-8e8a-067602882309	\N	80151338-4d31-42d1-9fac-c5a3f93893d2	2026-07-21 12:23:05.653402+00	2026-07-21 12:23:05.653402+00
9e026bc3-66b8-45d7-9c60-0989a6664192	1fc13c47-7465-47b0-9734-db741cadd6d3	1f7a4d5f-3f0b-4a87-92e9-cf7057b674f5	رفع اشکالات و بازبینی	171	42	2026-07-16	approved	be682dce-6665-4ff0-8e8a-067602882309	\N	9ba98479-a407-4c56-9b35-1b910064b727	2026-07-21 12:23:05.653402+00	2026-07-21 12:23:05.653402+00
9e026bc3-66b8-45d7-9c60-0989a6664192	1fc13c47-7465-47b0-9734-db741cadd6d3	1f7a4d5f-3f0b-4a87-92e9-cf7057b674f5	پیاده‌سازی بخش اصلی	188	100	2026-07-16	submitted	\N	\N	f14276c6-ae7c-4427-ba82-656b95f926a6	2026-07-21 12:23:05.653402+00	2026-07-21 12:23:05.653402+00
9e026bc3-66b8-45d7-9c60-0989a6664192	1fc13c47-7465-47b0-9734-db741cadd6d3	1f7a4d5f-3f0b-4a87-92e9-cf7057b674f5	رفع اشکالات و بازبینی	223	100	2026-07-16	submitted	\N	\N	517c18d5-75f3-490a-8ca8-b859237bfb98	2026-07-21 12:23:05.653402+00	2026-07-21 12:23:05.653402+00
9e026bc3-66b8-45d7-9c60-0989a6664192	40fbaefe-5c92-440b-b64b-44c208e07101	fe6b733f-8cf4-4df1-a83e-2e854a480178	رفع اشکالات و بازبینی	144	25	2026-07-16	approved	be682dce-6665-4ff0-8e8a-067602882309	\N	1521f483-94a6-46ec-8efb-11a8508d2e46	2026-07-21 12:23:05.653402+00	2026-07-21 12:23:05.653402+00
9e026bc3-66b8-45d7-9c60-0989a6664192	40fbaefe-5c92-440b-b64b-44c208e07101	fe6b733f-8cf4-4df1-a83e-2e854a480178	پیاده‌سازی بخش اصلی	74	72	2026-07-16	approved	be682dce-6665-4ff0-8e8a-067602882309	\N	a281c10a-eb80-44cc-addd-df3fb33c2a4a	2026-07-21 12:23:05.653402+00	2026-07-21 12:23:05.653402+00
9e026bc3-66b8-45d7-9c60-0989a6664192	055f4d59-9262-4e96-b469-c4abfd6803f3	2310cdf5-d549-4a28-bc04-2052038876fc	پیشرفت اولیه و بررسی نیازمندی‌ها	139	28	2026-07-16	approved	be682dce-6665-4ff0-8e8a-067602882309	\N	4cbb4d2d-d77d-4750-b8d2-71dec5cd853f	2026-07-21 12:23:05.653402+00	2026-07-21 12:23:05.653402+00
9e026bc3-66b8-45d7-9c60-0989a6664192	3a90a886-f73f-4281-91b6-56e9b0350fda	be682dce-6665-4ff0-8e8a-067602882309	رفع اشکالات و بازبینی	31	30	2026-07-16	approved	be682dce-6665-4ff0-8e8a-067602882309	\N	38c9969c-2ee1-4cf8-9d32-9aa70bf60b85	2026-07-21 12:23:05.653402+00	2026-07-21 12:23:05.653402+00
9e026bc3-66b8-45d7-9c60-0989a6664192	3a90a886-f73f-4281-91b6-56e9b0350fda	be682dce-6665-4ff0-8e8a-067602882309	پیاده‌سازی بخش اصلی	40	48	2026-07-16	submitted	\N	\N	b6ecea6f-19fd-4d9c-9bc6-b4118c28455b	2026-07-21 12:23:05.653402+00	2026-07-21 12:23:05.653402+00
9e026bc3-66b8-45d7-9c60-0989a6664192	3a90a886-f73f-4281-91b6-56e9b0350fda	be682dce-6665-4ff0-8e8a-067602882309	مستندسازی و نهایی‌سازی	199	87	2026-07-16	approved	be682dce-6665-4ff0-8e8a-067602882309	\N	eba80937-b814-43a5-9c85-3b8e392f969d	2026-07-21 12:23:05.653402+00	2026-07-21 12:23:05.653402+00
9e026bc3-66b8-45d7-9c60-0989a6664192	79f68967-c5d4-4983-a5c5-5acb172d0b1a	3cdfd222-0ea4-4a30-b15b-036d1d733193	پیشرفت اولیه و بررسی نیازمندی‌ها	230	30	2026-07-16	approved	be682dce-6665-4ff0-8e8a-067602882309	\N	7815246a-3dd0-4f16-909e-8a9e5c360df2	2026-07-21 12:23:05.653402+00	2026-07-21 12:23:05.653402+00
9e026bc3-66b8-45d7-9c60-0989a6664192	79f68967-c5d4-4983-a5c5-5acb172d0b1a	3cdfd222-0ea4-4a30-b15b-036d1d733193	پیاده‌سازی بخش اصلی	163	44	2026-07-16	approved	be682dce-6665-4ff0-8e8a-067602882309	\N	4946d501-2777-4db7-8c4c-d96ba92e52ea	2026-07-21 12:23:05.653402+00	2026-07-21 12:23:05.653402+00
9e026bc3-66b8-45d7-9c60-0989a6664192	79f68967-c5d4-4983-a5c5-5acb172d0b1a	3cdfd222-0ea4-4a30-b15b-036d1d733193	تست و اطمینان از عملکرد صحیح	169	100	2026-07-16	approved	be682dce-6665-4ff0-8e8a-067602882309	\N	de780581-422f-4cf3-a198-ed20a734530b	2026-07-21 12:23:05.653402+00	2026-07-21 12:23:05.653402+00
9e026bc3-66b8-45d7-9c60-0989a6664192	79f68967-c5d4-4983-a5c5-5acb172d0b1a	3cdfd222-0ea4-4a30-b15b-036d1d733193	پیشرفت اولیه و بررسی نیازمندی‌ها	119	100	2026-07-16	approved	be682dce-6665-4ff0-8e8a-067602882309	\N	e618c216-7902-44a0-b42e-53c78150e0f2	2026-07-21 12:23:05.653402+00	2026-07-21 12:23:05.653402+00
9e026bc3-66b8-45d7-9c60-0989a6664192	00e7bb3f-b02f-4548-bd86-092fbb3ecc83	1f7a4d5f-3f0b-4a87-92e9-cf7057b674f5	رفع اشکالات و بازبینی	122	29	2026-07-16	approved	be682dce-6665-4ff0-8e8a-067602882309	\N	e20c7f35-9fcb-4744-ade5-9cedb108adfa	2026-07-21 12:23:05.653402+00	2026-07-21 12:23:05.653402+00
9e026bc3-66b8-45d7-9c60-0989a6664192	00e7bb3f-b02f-4548-bd86-092fbb3ecc83	1f7a4d5f-3f0b-4a87-92e9-cf7057b674f5	مستندسازی و نهایی‌سازی	165	70	2026-07-16	approved	be682dce-6665-4ff0-8e8a-067602882309	\N	f19ddde6-8959-4295-a77d-8626faa9be4d	2026-07-21 12:23:05.653402+00	2026-07-21 12:23:05.653402+00
9e026bc3-66b8-45d7-9c60-0989a6664192	c0344d19-4dea-4562-b960-0614db284f60	220f13de-14e7-4c15-a3c3-d456ccb8f206	رفع اشکالات و بازبینی	144	27	2026-06-16	approved	be682dce-6665-4ff0-8e8a-067602882309	\N	f823360d-58d8-48c8-be8e-2d1766afd7d6	2026-07-21 12:23:05.653402+00	2026-07-21 12:23:05.653402+00
9e026bc3-66b8-45d7-9c60-0989a6664192	c40801cc-305d-4c6b-850f-99d3acf65a18	be682dce-6665-4ff0-8e8a-067602882309	رفع اشکالات و بازبینی	127	23	2026-06-25	approved	be682dce-6665-4ff0-8e8a-067602882309	\N	82be0fb8-0c88-4fe5-8f15-2ad9d270a397	2026-07-21 12:23:05.653402+00	2026-07-21 12:23:05.653402+00
9e026bc3-66b8-45d7-9c60-0989a6664192	c40801cc-305d-4c6b-850f-99d3acf65a18	be682dce-6665-4ff0-8e8a-067602882309	رفع اشکالات و بازبینی	36	72	2026-06-29	approved	be682dce-6665-4ff0-8e8a-067602882309	\N	70eb5182-1ee2-45fb-bc3b-ba48d305e43a	2026-07-21 12:23:05.653402+00	2026-07-21 12:23:05.653402+00
9e026bc3-66b8-45d7-9c60-0989a6664192	766e9f1b-a9e0-4fef-99e6-22a3be5ec330	2310cdf5-d549-4a28-bc04-2052038876fc	رفع اشکالات و بازبینی	196	26	2026-07-10	approved	be682dce-6665-4ff0-8e8a-067602882309	\N	8bdc17ac-a88c-4417-a26d-1999cdbe1f99	2026-07-21 12:23:05.653402+00	2026-07-21 12:23:05.653402+00
9e026bc3-66b8-45d7-9c60-0989a6664192	766e9f1b-a9e0-4fef-99e6-22a3be5ec330	2310cdf5-d549-4a28-bc04-2052038876fc	پیشرفت اولیه و بررسی نیازمندی‌ها	72	74	2026-07-13	approved	be682dce-6665-4ff0-8e8a-067602882309	\N	af26a395-d4a6-4bba-93fd-790654720a71	2026-07-21 12:23:05.653402+00	2026-07-21 12:23:05.653402+00
9e026bc3-66b8-45d7-9c60-0989a6664192	766e9f1b-a9e0-4fef-99e6-22a3be5ec330	2310cdf5-d549-4a28-bc04-2052038876fc	پیاده‌سازی بخش اصلی	201	100	2026-07-12	approved	be682dce-6665-4ff0-8e8a-067602882309	\N	dfc7f573-6230-40e7-9616-369ccf27491e	2026-07-21 12:23:05.653402+00	2026-07-21 12:23:05.653402+00
9e026bc3-66b8-45d7-9c60-0989a6664192	51d26d5b-f7e2-4ed5-bae5-ac1c2ec7f58d	fe6b733f-8cf4-4df1-a83e-2e854a480178	پیاده‌سازی بخش اصلی	167	33	2026-06-25	submitted	\N	\N	ea9a9556-dce1-4af7-8ff2-b21b43428092	2026-07-21 12:23:05.653402+00	2026-07-21 12:23:05.653402+00
9e026bc3-66b8-45d7-9c60-0989a6664192	51d26d5b-f7e2-4ed5-bae5-ac1c2ec7f58d	fe6b733f-8cf4-4df1-a83e-2e854a480178	پیاده‌سازی بخش اصلی	36	68	2026-06-26	submitted	\N	\N	039a3f82-a152-42db-8395-fef58d7d38dd	2026-07-21 12:23:05.653402+00	2026-07-21 12:23:05.653402+00
9e026bc3-66b8-45d7-9c60-0989a6664192	106dacc7-99df-41b9-958a-b00d16fbf069	fe6b733f-8cf4-4df1-a83e-2e854a480178	پیشرفت اولیه و بررسی نیازمندی‌ها	48	21	2026-07-16	approved	be682dce-6665-4ff0-8e8a-067602882309	\N	1b96f3bc-1fec-4ce4-8f40-06a3bbf87ef8	2026-07-21 12:23:05.653402+00	2026-07-21 12:23:05.653402+00
9e026bc3-66b8-45d7-9c60-0989a6664192	106dacc7-99df-41b9-958a-b00d16fbf069	fe6b733f-8cf4-4df1-a83e-2e854a480178	رفع اشکالات و بازبینی	172	44	2026-07-16	approved	be682dce-6665-4ff0-8e8a-067602882309	\N	980119bc-e76b-4013-9fd8-d9b8975b915c	2026-07-21 12:23:05.653402+00	2026-07-21 12:23:05.653402+00
9e026bc3-66b8-45d7-9c60-0989a6664192	106dacc7-99df-41b9-958a-b00d16fbf069	fe6b733f-8cf4-4df1-a83e-2e854a480178	رفع اشکالات و بازبینی	134	96	2026-07-16	approved	be682dce-6665-4ff0-8e8a-067602882309	\N	d718fd7c-cb52-45e1-9f49-97aa11dfd457	2026-07-21 12:23:05.653402+00	2026-07-21 12:23:05.653402+00
9e026bc3-66b8-45d7-9c60-0989a6664192	01c2ce79-aafb-4095-a965-b2a930ad556d	be682dce-6665-4ff0-8e8a-067602882309	پیشرفت اولیه و بررسی نیازمندی‌ها	129	23	2026-07-16	approved	be682dce-6665-4ff0-8e8a-067602882309	\N	76d3ca0b-b030-47ef-b0b3-ef32a9f16878	2026-07-21 12:23:05.653402+00	2026-07-21 12:23:05.653402+00
9e026bc3-66b8-45d7-9c60-0989a6664192	01c2ce79-aafb-4095-a965-b2a930ad556d	be682dce-6665-4ff0-8e8a-067602882309	مستندسازی و نهایی‌سازی	46	76	2026-07-16	approved	be682dce-6665-4ff0-8e8a-067602882309	\N	d82296c8-c03a-437e-b1f5-7831838159f3	2026-07-21 12:23:05.653402+00	2026-07-21 12:23:05.653402+00
9e026bc3-66b8-45d7-9c60-0989a6664192	01c2ce79-aafb-4095-a965-b2a930ad556d	be682dce-6665-4ff0-8e8a-067602882309	پیشرفت اولیه و بررسی نیازمندی‌ها	121	100	2026-07-16	submitted	\N	\N	b23b36fd-a222-4ca7-9727-f5cd07fd3c25	2026-07-21 12:23:05.653402+00	2026-07-21 12:23:05.653402+00
9e026bc3-66b8-45d7-9c60-0989a6664192	01c2ce79-aafb-4095-a965-b2a930ad556d	be682dce-6665-4ff0-8e8a-067602882309	رفع اشکالات و بازبینی	185	88	2026-07-16	approved	be682dce-6665-4ff0-8e8a-067602882309	\N	7d94cf84-cefd-4c38-962c-b89e3dddee7f	2026-07-21 12:23:05.653402+00	2026-07-21 12:23:05.653402+00
9e026bc3-66b8-45d7-9c60-0989a6664192	ab6c418d-3397-4b08-8457-9ff0a0a6d2fc	fe6b733f-8cf4-4df1-a83e-2e854a480178	پیشرفت اولیه و بررسی نیازمندی‌ها	151	25	2026-07-16	approved	be682dce-6665-4ff0-8e8a-067602882309	\N	50153718-5c59-42ea-924f-b6efaa6ed0b5	2026-07-21 12:23:05.653402+00	2026-07-21 12:23:05.653402+00
9e026bc3-66b8-45d7-9c60-0989a6664192	ab6c418d-3397-4b08-8457-9ff0a0a6d2fc	fe6b733f-8cf4-4df1-a83e-2e854a480178	تست و اطمینان از عملکرد صحیح	233	74	2026-07-16	approved	be682dce-6665-4ff0-8e8a-067602882309	\N	4e1e66af-eff7-4fcc-b160-60e8805576ef	2026-07-21 12:23:05.653402+00	2026-07-21 12:23:05.653402+00
9e026bc3-66b8-45d7-9c60-0989a6664192	ab6c418d-3397-4b08-8457-9ff0a0a6d2fc	fe6b733f-8cf4-4df1-a83e-2e854a480178	پیاده‌سازی بخش اصلی	106	100	2026-07-16	submitted	\N	\N	d01f8224-8431-4c6e-bfc4-513e725ade15	2026-07-21 12:23:05.653402+00	2026-07-21 12:23:05.653402+00
9e026bc3-66b8-45d7-9c60-0989a6664192	cc45f175-3b4a-48ea-b745-7913bf02e906	37e62239-b7c6-493c-9475-fe700a479e79	مستندسازی و نهایی‌سازی	66	23	2026-07-16	approved	be682dce-6665-4ff0-8e8a-067602882309	\N	91850f32-b5ca-45e3-b4fd-8aa9c2ee0149	2026-07-21 12:23:05.653402+00	2026-07-21 12:23:05.653402+00
9e026bc3-66b8-45d7-9c60-0989a6664192	cc45f175-3b4a-48ea-b745-7913bf02e906	37e62239-b7c6-493c-9475-fe700a479e79	مستندسازی و نهایی‌سازی	130	74	2026-07-16	approved	be682dce-6665-4ff0-8e8a-067602882309	\N	2e4a5faa-0141-4362-b97b-02155c83f0f3	2026-07-21 12:23:05.653402+00	2026-07-21 12:23:05.653402+00
9e026bc3-66b8-45d7-9c60-0989a6664192	cc45f175-3b4a-48ea-b745-7913bf02e906	37e62239-b7c6-493c-9475-fe700a479e79	رفع اشکالات و بازبینی	84	99	2026-07-16	approved	be682dce-6665-4ff0-8e8a-067602882309	\N	463e5267-bbdc-4716-8f3d-42134e9e10e8	2026-07-21 12:23:05.653402+00	2026-07-21 12:23:05.653402+00
9e026bc3-66b8-45d7-9c60-0989a6664192	9a261b60-250e-449e-abaa-36d071f302e2	1f7a4d5f-3f0b-4a87-92e9-cf7057b674f5	پیاده‌سازی بخش اصلی	86	39	2026-06-17	approved	be682dce-6665-4ff0-8e8a-067602882309	\N	fe6d0e19-ce53-4c75-9b64-927eaed60abd	2026-07-21 12:23:05.653402+00	2026-07-21 12:23:05.653402+00
9e026bc3-66b8-45d7-9c60-0989a6664192	9a261b60-250e-449e-abaa-36d071f302e2	1f7a4d5f-3f0b-4a87-92e9-cf7057b674f5	پیاده‌سازی بخش اصلی	59	50	2026-06-20	approved	be682dce-6665-4ff0-8e8a-067602882309	\N	fe3a4fca-6911-4f0d-89e1-52a93f6be882	2026-07-21 12:23:05.653402+00	2026-07-21 12:23:05.653402+00
9e026bc3-66b8-45d7-9c60-0989a6664192	8e6da4cf-9a57-4805-a5ae-90cd78c5d1a1	1f7a4d5f-3f0b-4a87-92e9-cf7057b674f5	مستندسازی و نهایی‌سازی	48	29	2026-07-16	approved	be682dce-6665-4ff0-8e8a-067602882309	\N	bf97f99c-cf6f-4f65-934c-8a6b6e1a0535	2026-07-21 12:23:05.653402+00	2026-07-21 12:23:05.653402+00
9e026bc3-66b8-45d7-9c60-0989a6664192	4dd876d9-dbde-411f-95b9-038d7fecdd1f	2310cdf5-d549-4a28-bc04-2052038876fc	پیشرفت اولیه و بررسی نیازمندی‌ها	80	38	2026-07-16	approved	be682dce-6665-4ff0-8e8a-067602882309	\N	b9fad55a-e42f-43e8-8714-2c99fe32199c	2026-07-21 12:23:05.653402+00	2026-07-21 12:23:05.653402+00
9e026bc3-66b8-45d7-9c60-0989a6664192	2940fa8f-f587-4504-9432-8c28e8374e51	37e62239-b7c6-493c-9475-fe700a479e79	پیاده‌سازی بخش اصلی	55	29	2026-07-16	approved	be682dce-6665-4ff0-8e8a-067602882309	\N	06c9218f-c581-4a28-8cff-1e6323325451	2026-07-21 12:23:05.653402+00	2026-07-21 12:23:05.653402+00
9e026bc3-66b8-45d7-9c60-0989a6664192	2940fa8f-f587-4504-9432-8c28e8374e51	37e62239-b7c6-493c-9475-fe700a479e79	رفع اشکالات و بازبینی	154	68	2026-07-16	submitted	\N	\N	8f43fb23-a011-4c61-b631-662638a42b53	2026-07-21 12:23:05.653402+00	2026-07-21 12:23:05.653402+00
9e026bc3-66b8-45d7-9c60-0989a6664192	2940fa8f-f587-4504-9432-8c28e8374e51	37e62239-b7c6-493c-9475-fe700a479e79	رفع اشکالات و بازبینی	207	100	2026-07-16	approved	be682dce-6665-4ff0-8e8a-067602882309	\N	053a8584-ef22-4846-a4c4-f59801e85cf8	2026-07-21 12:23:05.653402+00	2026-07-21 12:23:05.653402+00
9e026bc3-66b8-45d7-9c60-0989a6664192	2940fa8f-f587-4504-9432-8c28e8374e51	37e62239-b7c6-493c-9475-fe700a479e79	رفع اشکالات و بازبینی	236	100	2026-07-16	approved	be682dce-6665-4ff0-8e8a-067602882309	\N	7163fe04-9c07-458d-bdb1-16db0f586f93	2026-07-21 12:23:05.653402+00	2026-07-21 12:23:05.653402+00
9e026bc3-66b8-45d7-9c60-0989a6664192	42e55e27-3abf-47f9-b5b5-b610b379058b	1f7a4d5f-3f0b-4a87-92e9-cf7057b674f5	پیشرفت اولیه و بررسی نیازمندی‌ها	110	27	2026-06-29	approved	be682dce-6665-4ff0-8e8a-067602882309	\N	fee16294-c373-4b97-9825-b57637c360b7	2026-07-21 12:23:05.653402+00	2026-07-21 12:23:05.653402+00
9e026bc3-66b8-45d7-9c60-0989a6664192	42e55e27-3abf-47f9-b5b5-b610b379058b	1f7a4d5f-3f0b-4a87-92e9-cf7057b674f5	تست و اطمینان از عملکرد صحیح	100	62	2026-07-01	approved	be682dce-6665-4ff0-8e8a-067602882309	\N	a5dcd431-7c71-4137-a5b2-295418795b3b	2026-07-21 12:23:05.653402+00	2026-07-21 12:23:05.653402+00
9e026bc3-66b8-45d7-9c60-0989a6664192	42e55e27-3abf-47f9-b5b5-b610b379058b	1f7a4d5f-3f0b-4a87-92e9-cf7057b674f5	رفع اشکالات و بازبینی	152	100	2026-07-03	approved	be682dce-6665-4ff0-8e8a-067602882309	\N	b21d3cac-f1dd-43f0-aaf1-4d3236e818bb	2026-07-21 12:23:05.653402+00	2026-07-21 12:23:05.653402+00
9e026bc3-66b8-45d7-9c60-0989a6664192	42e55e27-3abf-47f9-b5b5-b610b379058b	1f7a4d5f-3f0b-4a87-92e9-cf7057b674f5	رفع اشکالات و بازبینی	228	100	2026-07-11	approved	be682dce-6665-4ff0-8e8a-067602882309	\N	1c8c0ba1-63d2-4b15-b54c-766446f16e14	2026-07-21 12:23:05.653402+00	2026-07-21 12:23:05.653402+00
9e026bc3-66b8-45d7-9c60-0989a6664192	65c130f9-b51c-4960-8221-5f9061af16c8	fe6b733f-8cf4-4df1-a83e-2e854a480178	پیاده‌سازی بخش اصلی	195	39	2026-06-17	approved	be682dce-6665-4ff0-8e8a-067602882309	\N	efcdedc9-8371-4678-bdfc-29f4e6a8f6ac	2026-07-21 12:23:05.653402+00	2026-07-21 12:23:05.653402+00
9e026bc3-66b8-45d7-9c60-0989a6664192	65c130f9-b51c-4960-8221-5f9061af16c8	fe6b733f-8cf4-4df1-a83e-2e854a480178	رفع اشکالات و بازبینی	65	74	2026-06-18	approved	be682dce-6665-4ff0-8e8a-067602882309	\N	90c31255-fd26-421e-b393-6b6c544483b4	2026-07-21 12:23:05.653402+00	2026-07-21 12:23:05.653402+00
9e026bc3-66b8-45d7-9c60-0989a6664192	65c130f9-b51c-4960-8221-5f9061af16c8	fe6b733f-8cf4-4df1-a83e-2e854a480178	رفع اشکالات و بازبینی	217	100	2026-06-21	approved	be682dce-6665-4ff0-8e8a-067602882309	\N	ef4cc86b-1b99-4e49-9998-9bb01a3cffa2	2026-07-21 12:23:05.653402+00	2026-07-21 12:23:05.653402+00
9e026bc3-66b8-45d7-9c60-0989a6664192	65c130f9-b51c-4960-8221-5f9061af16c8	fe6b733f-8cf4-4df1-a83e-2e854a480178	پیشرفت اولیه و بررسی نیازمندی‌ها	34	100	2026-06-20	approved	be682dce-6665-4ff0-8e8a-067602882309	\N	0eede316-6703-42de-823d-96f7573166de	2026-07-21 12:23:05.653402+00	2026-07-21 12:23:05.653402+00
9e026bc3-66b8-45d7-9c60-0989a6664192	d58bc5d6-c972-4927-85a4-0dff5346d9e7	2310cdf5-d549-4a28-bc04-2052038876fc	پیاده‌سازی بخش اصلی	39	37	2026-07-15	submitted	\N	\N	54ce2ac3-f05b-43f3-a483-d1e02ed28e70	2026-07-21 12:23:05.653402+00	2026-07-21 12:23:05.653402+00
9e026bc3-66b8-45d7-9c60-0989a6664192	13db9a7c-bc64-4735-8262-fe6aa2a16ecc	1f7a4d5f-3f0b-4a87-92e9-cf7057b674f5	پیاده‌سازی بخش اصلی	123	32	2026-06-22	approved	be682dce-6665-4ff0-8e8a-067602882309	\N	bdc8d7f0-7770-42d2-8b94-f4dcdbeca51c	2026-07-21 12:23:05.653402+00	2026-07-21 12:23:05.653402+00
9e026bc3-66b8-45d7-9c60-0989a6664192	13db9a7c-bc64-4735-8262-fe6aa2a16ecc	1f7a4d5f-3f0b-4a87-92e9-cf7057b674f5	مستندسازی و نهایی‌سازی	217	58	2026-06-24	approved	be682dce-6665-4ff0-8e8a-067602882309	\N	167bf2fe-6e18-4730-84bd-237694adacc3	2026-07-21 12:23:05.653402+00	2026-07-21 12:23:05.653402+00
9e026bc3-66b8-45d7-9c60-0989a6664192	13db9a7c-bc64-4735-8262-fe6aa2a16ecc	1f7a4d5f-3f0b-4a87-92e9-cf7057b674f5	تست و اطمینان از عملکرد صحیح	158	100	2026-06-26	approved	be682dce-6665-4ff0-8e8a-067602882309	\N	f1c87147-500c-4248-b484-a5e6d9c5256e	2026-07-21 12:23:05.653402+00	2026-07-21 12:23:05.653402+00
9e026bc3-66b8-45d7-9c60-0989a6664192	b6256525-7416-4a4f-a2fe-8b4add569d11	1f7a4d5f-3f0b-4a87-92e9-cf7057b674f5	پیشرفت اولیه و بررسی نیازمندی‌ها	199	27	2026-07-16	approved	be682dce-6665-4ff0-8e8a-067602882309	\N	6a88d5f7-478a-4eb5-b141-575fa7d39549	2026-07-21 12:23:05.653402+00	2026-07-21 12:23:05.653402+00
9e026bc3-66b8-45d7-9c60-0989a6664192	fd5448b8-83f5-43f4-9408-eaae6e883a9b	3cdfd222-0ea4-4a30-b15b-036d1d733193	تست و اطمینان از عملکرد صحیح	70	25	2026-06-25	approved	be682dce-6665-4ff0-8e8a-067602882309	\N	aa077564-9b59-4d8e-a5d3-5fe2b1a496d8	2026-07-21 12:23:05.653402+00	2026-07-21 12:23:05.653402+00
9e026bc3-66b8-45d7-9c60-0989a6664192	fd5448b8-83f5-43f4-9408-eaae6e883a9b	3cdfd222-0ea4-4a30-b15b-036d1d733193	تست و اطمینان از عملکرد صحیح	121	42	2026-06-27	approved	be682dce-6665-4ff0-8e8a-067602882309	\N	3df7b5ff-5bba-4ce4-9f96-89fa638e9b9a	2026-07-21 12:23:05.653402+00	2026-07-21 12:23:05.653402+00
9e026bc3-66b8-45d7-9c60-0989a6664192	305e1832-32f6-4e43-aab5-b6c918de689e	1f7a4d5f-3f0b-4a87-92e9-cf7057b674f5	پیاده‌سازی بخش اصلی	46	28	2026-07-06	approved	be682dce-6665-4ff0-8e8a-067602882309	\N	83a4b494-57db-4e91-b0c2-a2da163df85b	2026-07-21 12:23:05.653402+00	2026-07-21 12:23:05.653402+00
9e026bc3-66b8-45d7-9c60-0989a6664192	305e1832-32f6-4e43-aab5-b6c918de689e	1f7a4d5f-3f0b-4a87-92e9-cf7057b674f5	پیاده‌سازی بخش اصلی	40	52	2026-07-09	approved	be682dce-6665-4ff0-8e8a-067602882309	\N	03855d19-af63-4a50-af4c-21125610113c	2026-07-21 12:23:05.653402+00	2026-07-21 12:23:05.653402+00
9e026bc3-66b8-45d7-9c60-0989a6664192	dbfa8f3e-4ad3-4118-8df3-de493d866f5a	fe6b733f-8cf4-4df1-a83e-2e854a480178	تست و اطمینان از عملکرد صحیح	41	21	2026-07-16	approved	be682dce-6665-4ff0-8e8a-067602882309	\N	f1a157e8-c17e-4844-961a-2d680397dfbc	2026-07-21 12:23:05.653402+00	2026-07-21 12:23:05.653402+00
9e026bc3-66b8-45d7-9c60-0989a6664192	dbfa8f3e-4ad3-4118-8df3-de493d866f5a	fe6b733f-8cf4-4df1-a83e-2e854a480178	مستندسازی و نهایی‌سازی	192	56	2026-07-16	approved	be682dce-6665-4ff0-8e8a-067602882309	\N	08604e58-6f54-470a-b6cc-d9bfb4a6894e	2026-07-21 12:23:05.653402+00	2026-07-21 12:23:05.653402+00
9e026bc3-66b8-45d7-9c60-0989a6664192	dbfa8f3e-4ad3-4118-8df3-de493d866f5a	fe6b733f-8cf4-4df1-a83e-2e854a480178	مستندسازی و نهایی‌سازی	74	96	2026-07-16	approved	be682dce-6665-4ff0-8e8a-067602882309	\N	6687f606-933f-4b46-9da4-cf6369079f66	2026-07-21 12:23:05.653402+00	2026-07-21 12:23:05.653402+00
9e026bc3-66b8-45d7-9c60-0989a6664192	9040cf8a-dede-460a-8a5c-d8346635204c	3cdfd222-0ea4-4a30-b15b-036d1d733193	پیشرفت اولیه و بررسی نیازمندی‌ها	162	28	2026-07-16	approved	be682dce-6665-4ff0-8e8a-067602882309	\N	e9c2fa20-93bb-49e9-bcdd-5c0657df7973	2026-07-21 12:23:05.653402+00	2026-07-21 12:23:05.653402+00
9e026bc3-66b8-45d7-9c60-0989a6664192	9040cf8a-dede-460a-8a5c-d8346635204c	3cdfd222-0ea4-4a30-b15b-036d1d733193	پیاده‌سازی بخش اصلی	162	64	2026-07-16	submitted	\N	\N	ac56f986-ca4c-4c0c-a300-c8c7574f0f8c	2026-07-21 12:23:05.653402+00	2026-07-21 12:23:05.653402+00
9e026bc3-66b8-45d7-9c60-0989a6664192	9040cf8a-dede-460a-8a5c-d8346635204c	3cdfd222-0ea4-4a30-b15b-036d1d733193	رفع اشکالات و بازبینی	154	100	2026-07-16	submitted	\N	\N	85ba12ef-adb1-4a07-ac8a-d833c02e7385	2026-07-21 12:23:05.653402+00	2026-07-21 12:23:05.653402+00
9e026bc3-66b8-45d7-9c60-0989a6664192	9040cf8a-dede-460a-8a5c-d8346635204c	3cdfd222-0ea4-4a30-b15b-036d1d733193	پیاده‌سازی بخش اصلی	142	100	2026-07-16	approved	be682dce-6665-4ff0-8e8a-067602882309	\N	c9e913fa-c4e1-44d5-a386-f097a441281b	2026-07-21 12:23:05.653402+00	2026-07-21 12:23:05.653402+00
9e026bc3-66b8-45d7-9c60-0989a6664192	204ecc45-bf40-4500-8cc1-1df6b10cdaed	be682dce-6665-4ff0-8e8a-067602882309	مستندسازی و نهایی‌سازی	194	28	2026-07-02	approved	be682dce-6665-4ff0-8e8a-067602882309	\N	38798a9b-4166-4579-894c-f551f4aab6b3	2026-07-21 12:23:05.653402+00	2026-07-21 12:23:05.653402+00
9e026bc3-66b8-45d7-9c60-0989a6664192	204ecc45-bf40-4500-8cc1-1df6b10cdaed	be682dce-6665-4ff0-8e8a-067602882309	پیاده‌سازی بخش اصلی	77	50	2026-07-04	approved	be682dce-6665-4ff0-8e8a-067602882309	\N	95a8a80c-5775-4480-877f-7a0603cadab2	2026-07-21 12:23:05.653402+00	2026-07-21 12:23:05.653402+00
9e026bc3-66b8-45d7-9c60-0989a6664192	022467d8-0685-4ebd-952a-6baa867212da	fe6b733f-8cf4-4df1-a83e-2e854a480178	پیاده‌سازی بخش اصلی	136	30	2026-07-08	approved	be682dce-6665-4ff0-8e8a-067602882309	\N	9d88f551-9343-4b0d-ac69-13b3f316a7c2	2026-07-21 12:23:05.653402+00	2026-07-21 12:23:05.653402+00
9e026bc3-66b8-45d7-9c60-0989a6664192	022467d8-0685-4ebd-952a-6baa867212da	fe6b733f-8cf4-4df1-a83e-2e854a480178	تست و اطمینان از عملکرد صحیح	202	70	2026-07-09	approved	be682dce-6665-4ff0-8e8a-067602882309	\N	5ccf4ac9-7daa-47cb-8d4d-681a1f99419a	2026-07-21 12:23:05.653402+00	2026-07-21 12:23:05.653402+00
9e026bc3-66b8-45d7-9c60-0989a6664192	022467d8-0685-4ebd-952a-6baa867212da	fe6b733f-8cf4-4df1-a83e-2e854a480178	پیاده‌سازی بخش اصلی	181	75	2026-07-16	approved	be682dce-6665-4ff0-8e8a-067602882309	\N	dfb4ca94-d326-4741-ac13-5fb2332f88d4	2026-07-21 12:23:05.653402+00	2026-07-21 12:23:05.653402+00
9e026bc3-66b8-45d7-9c60-0989a6664192	0b565a41-5543-49e1-b676-da667b55769a	fe6b733f-8cf4-4df1-a83e-2e854a480178	پیاده‌سازی بخش اصلی	176	38	2026-07-02	approved	be682dce-6665-4ff0-8e8a-067602882309	\N	34068320-d460-4676-9527-4c1f60d183d3	2026-07-21 12:23:05.653402+00	2026-07-21 12:23:05.653402+00
9e026bc3-66b8-45d7-9c60-0989a6664192	0b565a41-5543-49e1-b676-da667b55769a	fe6b733f-8cf4-4df1-a83e-2e854a480178	مستندسازی و نهایی‌سازی	40	76	2026-07-04	approved	be682dce-6665-4ff0-8e8a-067602882309	\N	4c64d2f6-f9dc-46d3-9861-2c900990b5dd	2026-07-21 12:23:05.653402+00	2026-07-21 12:23:05.653402+00
9e026bc3-66b8-45d7-9c60-0989a6664192	0b565a41-5543-49e1-b676-da667b55769a	fe6b733f-8cf4-4df1-a83e-2e854a480178	رفع اشکالات و بازبینی	76	100	2026-07-06	approved	be682dce-6665-4ff0-8e8a-067602882309	\N	db5c39b0-6d14-4a1f-b47d-4b30202e33c7	2026-07-21 12:23:05.653402+00	2026-07-21 12:23:05.653402+00
9e026bc3-66b8-45d7-9c60-0989a6664192	0b565a41-5543-49e1-b676-da667b55769a	fe6b733f-8cf4-4df1-a83e-2e854a480178	مستندسازی و نهایی‌سازی	193	80	2026-07-14	approved	be682dce-6665-4ff0-8e8a-067602882309	\N	96c9aede-716c-44dd-a447-221ff6220197	2026-07-21 12:23:05.653402+00	2026-07-21 12:23:05.653402+00
9e026bc3-66b8-45d7-9c60-0989a6664192	f58ebd25-2170-44da-ae15-bbdd5fac043e	1f7a4d5f-3f0b-4a87-92e9-cf7057b674f5	پیاده‌سازی بخش اصلی	144	39	2026-07-16	approved	be682dce-6665-4ff0-8e8a-067602882309	\N	88783cc4-943c-4a19-b0ed-951544e8424f	2026-07-21 12:23:05.653402+00	2026-07-21 12:23:05.653402+00
9e026bc3-66b8-45d7-9c60-0989a6664192	f58ebd25-2170-44da-ae15-bbdd5fac043e	1f7a4d5f-3f0b-4a87-92e9-cf7057b674f5	تست و اطمینان از عملکرد صحیح	73	54	2026-07-16	approved	be682dce-6665-4ff0-8e8a-067602882309	\N	12b4638e-8b31-4037-9bdc-14d4ca174df0	2026-07-21 12:23:05.653402+00	2026-07-21 12:23:05.653402+00
9e026bc3-66b8-45d7-9c60-0989a6664192	f58ebd25-2170-44da-ae15-bbdd5fac043e	1f7a4d5f-3f0b-4a87-92e9-cf7057b674f5	مستندسازی و نهایی‌سازی	66	100	2026-07-16	approved	be682dce-6665-4ff0-8e8a-067602882309	\N	088905e4-fa4b-4792-9d04-78c61e4d7269	2026-07-21 12:23:05.653402+00	2026-07-21 12:23:05.653402+00
9e026bc3-66b8-45d7-9c60-0989a6664192	9a639442-bdc2-4252-b9b4-97bf8e7d0011	37e62239-b7c6-493c-9475-fe700a479e79	رفع اشکالات و بازبینی	146	39	2026-07-16	approved	be682dce-6665-4ff0-8e8a-067602882309	\N	14854b1e-5266-4dca-a570-a8731c6e04cc	2026-07-21 12:23:05.653402+00	2026-07-21 12:23:05.653402+00
9e026bc3-66b8-45d7-9c60-0989a6664192	9a639442-bdc2-4252-b9b4-97bf8e7d0011	37e62239-b7c6-493c-9475-fe700a479e79	تست و اطمینان از عملکرد صحیح	63	46	2026-07-16	approved	be682dce-6665-4ff0-8e8a-067602882309	\N	6eb16663-0867-4616-a918-e8a1a2aec323	2026-07-21 12:23:05.653402+00	2026-07-21 12:23:05.653402+00
9e026bc3-66b8-45d7-9c60-0989a6664192	02784266-0f81-4c85-bbd7-ea80c70b5b76	3cdfd222-0ea4-4a30-b15b-036d1d733193	مستندسازی و نهایی‌سازی	205	33	2026-07-11	approved	be682dce-6665-4ff0-8e8a-067602882309	\N	d29e47b6-3069-4a7c-b874-6b87bcfded32	2026-07-21 12:23:05.653402+00	2026-07-21 12:23:05.653402+00
9e026bc3-66b8-45d7-9c60-0989a6664192	c68072c2-2d43-4763-8d49-c46bbec3577a	37e62239-b7c6-493c-9475-fe700a479e79	پیاده‌سازی بخش اصلی	151	39	2026-07-09	approved	be682dce-6665-4ff0-8e8a-067602882309	\N	b1ff945b-fec7-49ef-9a13-91fb4732c685	2026-07-21 12:23:05.653402+00	2026-07-21 12:23:05.653402+00
9e026bc3-66b8-45d7-9c60-0989a6664192	c68072c2-2d43-4763-8d49-c46bbec3577a	37e62239-b7c6-493c-9475-fe700a479e79	مستندسازی و نهایی‌سازی	158	46	2026-07-10	approved	be682dce-6665-4ff0-8e8a-067602882309	\N	747052b6-c73e-4f85-851e-e7cd86e0036a	2026-07-21 12:23:05.653402+00	2026-07-21 12:23:05.653402+00
9e026bc3-66b8-45d7-9c60-0989a6664192	7c287773-9c2b-47fc-be28-77097444c921	be682dce-6665-4ff0-8e8a-067602882309	مستندسازی و نهایی‌سازی	168	20	2026-07-16	approved	be682dce-6665-4ff0-8e8a-067602882309	\N	89f1a122-913a-4c32-902e-1ebeb0fe1b2c	2026-07-21 12:23:05.653402+00	2026-07-21 12:23:05.653402+00
9e026bc3-66b8-45d7-9c60-0989a6664192	a0c4355b-fd52-423c-b19b-bd339758a79b	fe6b733f-8cf4-4df1-a83e-2e854a480178	پیشرفت اولیه و بررسی نیازمندی‌ها	208	36	2026-07-15	approved	be682dce-6665-4ff0-8e8a-067602882309	\N	5d849a62-90fd-4262-81d4-b9bc9ab0707c	2026-07-21 12:23:05.653402+00	2026-07-21 12:23:05.653402+00
9e026bc3-66b8-45d7-9c60-0989a6664192	a0c4355b-fd52-423c-b19b-bd339758a79b	fe6b733f-8cf4-4df1-a83e-2e854a480178	تست و اطمینان از عملکرد صحیح	232	64	2026-07-16	approved	be682dce-6665-4ff0-8e8a-067602882309	\N	f1c43e48-8054-459c-b3db-371cfafa1d01	2026-07-21 12:23:05.653402+00	2026-07-21 12:23:05.653402+00
9e026bc3-66b8-45d7-9c60-0989a6664192	a0c4355b-fd52-423c-b19b-bd339758a79b	fe6b733f-8cf4-4df1-a83e-2e854a480178	مستندسازی و نهایی‌سازی	55	99	2026-07-16	approved	be682dce-6665-4ff0-8e8a-067602882309	\N	b1eb0ec9-f007-4e9a-8f24-ef1aa00aba38	2026-07-21 12:23:05.653402+00	2026-07-21 12:23:05.653402+00
9e026bc3-66b8-45d7-9c60-0989a6664192	a0c4355b-fd52-423c-b19b-bd339758a79b	fe6b733f-8cf4-4df1-a83e-2e854a480178	پیاده‌سازی بخش اصلی	51	100	2026-07-16	approved	be682dce-6665-4ff0-8e8a-067602882309	\N	41e61af5-0381-4c31-b35d-9d2ddf06af05	2026-07-21 12:23:05.653402+00	2026-07-21 12:23:05.653402+00
9e026bc3-66b8-45d7-9c60-0989a6664192	18bf57d8-c791-4c28-9d45-39459d513c7d	1f7a4d5f-3f0b-4a87-92e9-cf7057b674f5	پیشرفت اولیه و بررسی نیازمندی‌ها	177	36	2026-06-17	approved	be682dce-6665-4ff0-8e8a-067602882309	\N	1b4701f5-47c7-4352-8d91-7d6ca418cad2	2026-07-21 12:23:05.653402+00	2026-07-21 12:23:05.653402+00
9e026bc3-66b8-45d7-9c60-0989a6664192	18bf57d8-c791-4c28-9d45-39459d513c7d	1f7a4d5f-3f0b-4a87-92e9-cf7057b674f5	تست و اطمینان از عملکرد صحیح	197	52	2026-06-18	approved	be682dce-6665-4ff0-8e8a-067602882309	\N	17d5909e-9b74-4fdd-91e3-b7b8b4032ecf	2026-07-21 12:23:05.653402+00	2026-07-21 12:23:05.653402+00
9e026bc3-66b8-45d7-9c60-0989a6664192	18bf57d8-c791-4c28-9d45-39459d513c7d	1f7a4d5f-3f0b-4a87-92e9-cf7057b674f5	پیشرفت اولیه و بررسی نیازمندی‌ها	69	99	2026-06-23	approved	be682dce-6665-4ff0-8e8a-067602882309	\N	88d4f73a-e073-4191-ab43-bddf537d8eeb	2026-07-21 12:23:05.653402+00	2026-07-21 12:23:05.653402+00
9e026bc3-66b8-45d7-9c60-0989a6664192	18bf57d8-c791-4c28-9d45-39459d513c7d	1f7a4d5f-3f0b-4a87-92e9-cf7057b674f5	مستندسازی و نهایی‌سازی	138	100	2026-06-26	approved	be682dce-6665-4ff0-8e8a-067602882309	\N	502f5504-0f0b-4741-a963-d7896049ac49	2026-07-21 12:23:05.653402+00	2026-07-21 12:23:05.653402+00
9e026bc3-66b8-45d7-9c60-0989a6664192	bcdd076d-8fd9-470a-90b7-a78fa59ded8e	be682dce-6665-4ff0-8e8a-067602882309	تست و اطمینان از عملکرد صحیح	223	26	2026-06-23	approved	be682dce-6665-4ff0-8e8a-067602882309	\N	93df64d4-8499-47f0-86da-155c34bb2080	2026-07-21 12:23:05.653402+00	2026-07-21 12:23:05.653402+00
9e026bc3-66b8-45d7-9c60-0989a6664192	bcdd076d-8fd9-470a-90b7-a78fa59ded8e	be682dce-6665-4ff0-8e8a-067602882309	مستندسازی و نهایی‌سازی	230	74	2026-06-27	approved	be682dce-6665-4ff0-8e8a-067602882309	\N	a72c82cc-3573-4070-8690-2d7767e4b094	2026-07-21 12:23:05.653402+00	2026-07-21 12:23:05.653402+00
9e026bc3-66b8-45d7-9c60-0989a6664192	bcdd076d-8fd9-470a-90b7-a78fa59ded8e	be682dce-6665-4ff0-8e8a-067602882309	پیاده‌سازی بخش اصلی	124	100	2026-07-01	approved	be682dce-6665-4ff0-8e8a-067602882309	\N	c06c1225-3df4-4402-bf15-841754fa1758	2026-07-21 12:23:05.653402+00	2026-07-21 12:23:05.653402+00
9e026bc3-66b8-45d7-9c60-0989a6664192	ad728572-6512-4248-806f-5589a8319f4e	2310cdf5-d549-4a28-bc04-2052038876fc	رفع اشکالات و بازبینی	177	31	2026-07-16	approved	be682dce-6665-4ff0-8e8a-067602882309	\N	a84de915-66f0-4fe2-a475-b665f25c3064	2026-07-21 12:23:05.653402+00	2026-07-21 12:23:05.653402+00
9e026bc3-66b8-45d7-9c60-0989a6664192	ad728572-6512-4248-806f-5589a8319f4e	2310cdf5-d549-4a28-bc04-2052038876fc	پیاده‌سازی بخش اصلی	198	46	2026-07-16	approved	be682dce-6665-4ff0-8e8a-067602882309	\N	f2d4c6fc-0fb1-4994-94e1-66519c149b1e	2026-07-21 12:23:05.653402+00	2026-07-21 12:23:05.653402+00
9e026bc3-66b8-45d7-9c60-0989a6664192	ad728572-6512-4248-806f-5589a8319f4e	2310cdf5-d549-4a28-bc04-2052038876fc	تست و اطمینان از عملکرد صحیح	230	75	2026-07-16	approved	be682dce-6665-4ff0-8e8a-067602882309	\N	926b3c05-07dc-4c28-835e-231dafd25bc6	2026-07-21 12:23:05.653402+00	2026-07-21 12:23:05.653402+00
9e026bc3-66b8-45d7-9c60-0989a6664192	ad728572-6512-4248-806f-5589a8319f4e	2310cdf5-d549-4a28-bc04-2052038876fc	پیاده‌سازی بخش اصلی	160	100	2026-07-16	approved	be682dce-6665-4ff0-8e8a-067602882309	\N	e4c2f65c-4b9e-42aa-b89d-f7d322c96707	2026-07-21 12:23:05.653402+00	2026-07-21 12:23:05.653402+00
9e026bc3-66b8-45d7-9c60-0989a6664192	f116539f-0e27-46dc-9056-69d0fa44f0dc	3cdfd222-0ea4-4a30-b15b-036d1d733193	پیاده‌سازی بخش اصلی	129	40	2026-07-12	approved	be682dce-6665-4ff0-8e8a-067602882309	\N	fa652eea-812e-4980-8739-a79f26a660b7	2026-07-21 12:23:05.653402+00	2026-07-21 12:23:05.653402+00
9e026bc3-66b8-45d7-9c60-0989a6664192	f116539f-0e27-46dc-9056-69d0fa44f0dc	3cdfd222-0ea4-4a30-b15b-036d1d733193	پیشرفت اولیه و بررسی نیازمندی‌ها	240	48	2026-07-13	approved	be682dce-6665-4ff0-8e8a-067602882309	\N	a06e242a-3bdc-4261-b0ed-4345debcb63e	2026-07-21 12:23:05.653402+00	2026-07-21 12:23:05.653402+00
9e026bc3-66b8-45d7-9c60-0989a6664192	f116539f-0e27-46dc-9056-69d0fa44f0dc	3cdfd222-0ea4-4a30-b15b-036d1d733193	مستندسازی و نهایی‌سازی	141	66	2026-07-16	approved	be682dce-6665-4ff0-8e8a-067602882309	\N	cc2846c9-2cbd-4be8-824e-281d19885e5d	2026-07-21 12:23:05.653402+00	2026-07-21 12:23:05.653402+00
9e026bc3-66b8-45d7-9c60-0989a6664192	024d4d9e-430e-4265-ae75-839f812150c6	220f13de-14e7-4c15-a3c3-d456ccb8f206	پیاده‌سازی بخش اصلی	124	22	2026-07-16	approved	be682dce-6665-4ff0-8e8a-067602882309	\N	2ec277ab-2890-4589-84e7-f385ae5d65c4	2026-07-21 12:23:05.653402+00	2026-07-21 12:23:05.653402+00
9e026bc3-66b8-45d7-9c60-0989a6664192	55bbe9f3-a98e-448d-9b43-2e32179d888b	fe6b733f-8cf4-4df1-a83e-2e854a480178	تست و اطمینان از عملکرد صحیح	187	40	2026-07-08	approved	be682dce-6665-4ff0-8e8a-067602882309	\N	9292a74b-564d-4c80-b658-0ba823c3f851	2026-07-21 12:23:05.653402+00	2026-07-21 12:23:05.653402+00
9e026bc3-66b8-45d7-9c60-0989a6664192	16f0cec1-d074-4148-a4da-9f0d1f8da7ae	2310cdf5-d549-4a28-bc04-2052038876fc	پیاده‌سازی بخش اصلی	193	35	2026-07-16	submitted	\N	\N	dcdaa739-085e-418a-b8fa-19cfe8a5de3b	2026-07-21 12:23:05.653402+00	2026-07-21 12:23:05.653402+00
9e026bc3-66b8-45d7-9c60-0989a6664192	16f0cec1-d074-4148-a4da-9f0d1f8da7ae	2310cdf5-d549-4a28-bc04-2052038876fc	مستندسازی و نهایی‌سازی	103	52	2026-07-16	approved	be682dce-6665-4ff0-8e8a-067602882309	\N	52a760b1-2135-47cc-aafa-c98f8e0dcadf	2026-07-21 12:23:05.653402+00	2026-07-21 12:23:05.653402+00
9e026bc3-66b8-45d7-9c60-0989a6664192	16f0cec1-d074-4148-a4da-9f0d1f8da7ae	2310cdf5-d549-4a28-bc04-2052038876fc	مستندسازی و نهایی‌سازی	162	81	2026-07-16	submitted	\N	\N	2e471eba-555f-4a95-a341-bd4d75a95fda	2026-07-21 12:23:05.653402+00	2026-07-21 12:23:05.653402+00
9e026bc3-66b8-45d7-9c60-0989a6664192	8d23a657-fce8-4c59-a6f0-321253215ea6	1f7a4d5f-3f0b-4a87-92e9-cf7057b674f5	رفع اشکالات و بازبینی	91	40	2026-07-16	approved	be682dce-6665-4ff0-8e8a-067602882309	\N	893dae92-629a-44ea-ae2b-a4221516561b	2026-07-21 12:23:05.653402+00	2026-07-21 12:23:05.653402+00
9e026bc3-66b8-45d7-9c60-0989a6664192	8d23a657-fce8-4c59-a6f0-321253215ea6	1f7a4d5f-3f0b-4a87-92e9-cf7057b674f5	پیاده‌سازی بخش اصلی	52	56	2026-07-16	approved	be682dce-6665-4ff0-8e8a-067602882309	\N	8d192e95-972a-49d0-9e3d-c75bce385f4e	2026-07-21 12:23:05.653402+00	2026-07-21 12:23:05.653402+00
9e026bc3-66b8-45d7-9c60-0989a6664192	7615aae6-409d-4877-a5a7-722bb0e4e4cb	2310cdf5-d549-4a28-bc04-2052038876fc	تست و اطمینان از عملکرد صحیح	180	26	2026-07-02	approved	be682dce-6665-4ff0-8e8a-067602882309	\N	22de541b-9585-4bc5-a91d-8dc12eb61352	2026-07-21 12:23:05.653402+00	2026-07-21 12:23:05.653402+00
9e026bc3-66b8-45d7-9c60-0989a6664192	7615aae6-409d-4877-a5a7-722bb0e4e4cb	2310cdf5-d549-4a28-bc04-2052038876fc	پیشرفت اولیه و بررسی نیازمندی‌ها	53	74	2026-07-03	submitted	\N	\N	ad6730ad-1086-4222-882d-e943e66363e9	2026-07-21 12:23:05.653402+00	2026-07-21 12:23:05.653402+00
9e026bc3-66b8-45d7-9c60-0989a6664192	7615aae6-409d-4877-a5a7-722bb0e4e4cb	2310cdf5-d549-4a28-bc04-2052038876fc	مستندسازی و نهایی‌سازی	179	93	2026-07-08	submitted	\N	\N	444245ea-47ae-4e51-8d01-17c41278b71c	2026-07-21 12:23:05.653402+00	2026-07-21 12:23:05.653402+00
9e026bc3-66b8-45d7-9c60-0989a6664192	7615aae6-409d-4877-a5a7-722bb0e4e4cb	2310cdf5-d549-4a28-bc04-2052038876fc	رفع اشکالات و بازبینی	87	100	2026-07-11	submitted	\N	\N	2c388e52-5fd2-4d4f-8c07-ec9d45d75c15	2026-07-21 12:23:05.653402+00	2026-07-21 12:23:05.653402+00
9e026bc3-66b8-45d7-9c60-0989a6664192	11647cb9-3508-49f9-bfa5-2495ec0192c8	1f7a4d5f-3f0b-4a87-92e9-cf7057b674f5	مستندسازی و نهایی‌سازی	31	28	2026-07-09	submitted	\N	\N	fe0d34e5-3ada-4183-b40e-e10b5f2aa8cb	2026-07-21 12:23:05.653402+00	2026-07-21 12:23:05.653402+00
9e026bc3-66b8-45d7-9c60-0989a6664192	11647cb9-3508-49f9-bfa5-2495ec0192c8	1f7a4d5f-3f0b-4a87-92e9-cf7057b674f5	پیشرفت اولیه و بررسی نیازمندی‌ها	173	44	2026-07-11	approved	be682dce-6665-4ff0-8e8a-067602882309	\N	04603e80-1de6-40e4-8ca2-ab48794bff70	2026-07-21 12:23:05.653402+00	2026-07-21 12:23:05.653402+00
9e026bc3-66b8-45d7-9c60-0989a6664192	42177bd4-9572-4f74-8fac-b03f732269d6	2310cdf5-d549-4a28-bc04-2052038876fc	پیشرفت اولیه و بررسی نیازمندی‌ها	235	36	2026-07-16	approved	be682dce-6665-4ff0-8e8a-067602882309	\N	a31e46cc-9929-496d-8b38-1ebcca9a8114	2026-07-21 12:23:05.653402+00	2026-07-21 12:23:05.653402+00
9e026bc3-66b8-45d7-9c60-0989a6664192	42177bd4-9572-4f74-8fac-b03f732269d6	2310cdf5-d549-4a28-bc04-2052038876fc	مستندسازی و نهایی‌سازی	238	76	2026-07-16	approved	be682dce-6665-4ff0-8e8a-067602882309	\N	0587fca5-218a-4572-8a25-0171ca3bd3a8	2026-07-21 12:23:05.653402+00	2026-07-21 12:23:05.653402+00
9e026bc3-66b8-45d7-9c60-0989a6664192	42177bd4-9572-4f74-8fac-b03f732269d6	2310cdf5-d549-4a28-bc04-2052038876fc	تست و اطمینان از عملکرد صحیح	126	100	2026-07-16	approved	be682dce-6665-4ff0-8e8a-067602882309	\N	f67806ac-bf3b-4cdb-ad90-2f19e51cd264	2026-07-21 12:23:05.653402+00	2026-07-21 12:23:05.653402+00
9e026bc3-66b8-45d7-9c60-0989a6664192	1f220c67-b6eb-4b38-8539-7998b55fcb42	2310cdf5-d549-4a28-bc04-2052038876fc	تست و اطمینان از عملکرد صحیح	204	34	2026-07-15	submitted	\N	\N	15c8137b-8457-430d-87f2-265264caea65	2026-07-21 12:23:05.653402+00	2026-07-21 12:23:05.653402+00
9e026bc3-66b8-45d7-9c60-0989a6664192	1f220c67-b6eb-4b38-8539-7998b55fcb42	2310cdf5-d549-4a28-bc04-2052038876fc	رفع اشکالات و بازبینی	47	64	2026-07-16	approved	be682dce-6665-4ff0-8e8a-067602882309	\N	eeed4bfc-e142-4191-8398-536d765e7947	2026-07-21 12:23:05.653402+00	2026-07-21 12:23:05.653402+00
9e026bc3-66b8-45d7-9c60-0989a6664192	1f220c67-b6eb-4b38-8539-7998b55fcb42	2310cdf5-d549-4a28-bc04-2052038876fc	پیاده‌سازی بخش اصلی	234	90	2026-07-16	approved	be682dce-6665-4ff0-8e8a-067602882309	\N	c952881c-837f-4106-a37e-40b8f13742d8	2026-07-21 12:23:05.653402+00	2026-07-21 12:23:05.653402+00
9e026bc3-66b8-45d7-9c60-0989a6664192	1f220c67-b6eb-4b38-8539-7998b55fcb42	2310cdf5-d549-4a28-bc04-2052038876fc	مستندسازی و نهایی‌سازی	167	80	2026-07-16	submitted	\N	\N	a054fc42-daf0-42aa-afd1-a9157b3cb4cc	2026-07-21 12:23:05.653402+00	2026-07-21 12:23:05.653402+00
9e026bc3-66b8-45d7-9c60-0989a6664192	be088583-a3c1-4b5a-ae96-5168463d5da9	3cdfd222-0ea4-4a30-b15b-036d1d733193	رفع اشکالات و بازبینی	53	32	2026-07-10	approved	be682dce-6665-4ff0-8e8a-067602882309	\N	72918fa4-5b83-4d10-98a1-29db4cc0d08d	2026-07-21 12:23:05.653402+00	2026-07-21 12:23:05.653402+00
9e026bc3-66b8-45d7-9c60-0989a6664192	be088583-a3c1-4b5a-ae96-5168463d5da9	3cdfd222-0ea4-4a30-b15b-036d1d733193	پیشرفت اولیه و بررسی نیازمندی‌ها	171	50	2026-07-13	approved	be682dce-6665-4ff0-8e8a-067602882309	\N	1e01a01d-0c7c-435e-b98e-75101f5368af	2026-07-21 12:23:05.653402+00	2026-07-21 12:23:05.653402+00
9e026bc3-66b8-45d7-9c60-0989a6664192	be088583-a3c1-4b5a-ae96-5168463d5da9	3cdfd222-0ea4-4a30-b15b-036d1d733193	رفع اشکالات و بازبینی	120	78	2026-07-16	approved	be682dce-6665-4ff0-8e8a-067602882309	\N	d9c36c07-e6ab-4a47-971f-1a800d7e75e9	2026-07-21 12:23:05.653402+00	2026-07-21 12:23:05.653402+00
9e026bc3-66b8-45d7-9c60-0989a6664192	fd0b3fce-b645-4d0d-914f-4a5b85fdd270	1f7a4d5f-3f0b-4a87-92e9-cf7057b674f5	پیاده‌سازی بخش اصلی	157	26	2026-07-16	approved	be682dce-6665-4ff0-8e8a-067602882309	\N	a089b0c3-cf84-474c-abb5-55842e613ddd	2026-07-21 12:23:05.653402+00	2026-07-21 12:23:05.653402+00
9e026bc3-66b8-45d7-9c60-0989a6664192	fd0b3fce-b645-4d0d-914f-4a5b85fdd270	1f7a4d5f-3f0b-4a87-92e9-cf7057b674f5	پیاده‌سازی بخش اصلی	97	52	2026-07-16	approved	be682dce-6665-4ff0-8e8a-067602882309	\N	ee026584-61d1-47b0-8162-a858863bbb56	2026-07-21 12:23:05.653402+00	2026-07-21 12:23:05.653402+00
9e026bc3-66b8-45d7-9c60-0989a6664192	fd0b3fce-b645-4d0d-914f-4a5b85fdd270	1f7a4d5f-3f0b-4a87-92e9-cf7057b674f5	پیاده‌سازی بخش اصلی	93	100	2026-07-16	approved	be682dce-6665-4ff0-8e8a-067602882309	\N	2ed9ba15-1690-414a-8b7a-7cbdfe1d74a3	2026-07-21 12:23:05.653402+00	2026-07-21 12:23:05.653402+00
9e026bc3-66b8-45d7-9c60-0989a6664192	cb1fe65d-ac3d-4bba-97e9-a12f61183168	3cdfd222-0ea4-4a30-b15b-036d1d733193	پیشرفت اولیه و بررسی نیازمندی‌ها	60	22	2026-07-16	approved	be682dce-6665-4ff0-8e8a-067602882309	\N	811b8cab-3e75-4f88-b342-2b1a7a01f5ba	2026-07-21 12:23:05.653402+00	2026-07-21 12:23:05.653402+00
9e026bc3-66b8-45d7-9c60-0989a6664192	cb1fe65d-ac3d-4bba-97e9-a12f61183168	3cdfd222-0ea4-4a30-b15b-036d1d733193	مستندسازی و نهایی‌سازی	31	74	2026-07-16	approved	be682dce-6665-4ff0-8e8a-067602882309	\N	09a2af10-4335-455e-b20c-793dfe79b45f	2026-07-21 12:23:05.653402+00	2026-07-21 12:23:05.653402+00
9e026bc3-66b8-45d7-9c60-0989a6664192	cb1fe65d-ac3d-4bba-97e9-a12f61183168	3cdfd222-0ea4-4a30-b15b-036d1d733193	تست و اطمینان از عملکرد صحیح	125	100	2026-07-16	approved	be682dce-6665-4ff0-8e8a-067602882309	\N	76c37db1-28ad-4b8b-97e8-04e3ed853d24	2026-07-21 12:23:05.653402+00	2026-07-21 12:23:05.653402+00
9e026bc3-66b8-45d7-9c60-0989a6664192	af2b41ab-b779-4dcf-b555-1b1786194355	220f13de-14e7-4c15-a3c3-d456ccb8f206	مستندسازی و نهایی‌سازی	100	35	2026-07-16	approved	be682dce-6665-4ff0-8e8a-067602882309	\N	53b41fc6-9dba-4c7b-b56d-2d0f91c676d5	2026-07-21 12:23:05.653402+00	2026-07-21 12:23:05.653402+00
9e026bc3-66b8-45d7-9c60-0989a6664192	af2b41ab-b779-4dcf-b555-1b1786194355	220f13de-14e7-4c15-a3c3-d456ccb8f206	مستندسازی و نهایی‌سازی	101	64	2026-07-16	approved	be682dce-6665-4ff0-8e8a-067602882309	\N	70095db9-b98c-47d2-b107-462f19278e27	2026-07-21 12:23:05.653402+00	2026-07-21 12:23:05.653402+00
9e026bc3-66b8-45d7-9c60-0989a6664192	af2b41ab-b779-4dcf-b555-1b1786194355	220f13de-14e7-4c15-a3c3-d456ccb8f206	مستندسازی و نهایی‌سازی	62	63	2026-07-16	approved	be682dce-6665-4ff0-8e8a-067602882309	\N	02361a07-b49a-4a50-a126-2988f76bf6d6	2026-07-21 12:23:05.653402+00	2026-07-21 12:23:05.653402+00
9e026bc3-66b8-45d7-9c60-0989a6664192	109803ba-a3bb-482b-afd4-57f854298016	2310cdf5-d549-4a28-bc04-2052038876fc	پیشرفت اولیه و بررسی نیازمندی‌ها	158	31	2026-07-16	submitted	\N	\N	0a340624-27f3-477f-8eb8-66c9f5fa332f	2026-07-21 12:23:05.653402+00	2026-07-21 12:23:05.653402+00
9e026bc3-66b8-45d7-9c60-0989a6664192	109803ba-a3bb-482b-afd4-57f854298016	2310cdf5-d549-4a28-bc04-2052038876fc	پیاده‌سازی بخش اصلی	147	46	2026-07-16	submitted	\N	\N	8a000b12-8f6c-4a8e-bd40-0bbbe4a1acac	2026-07-21 12:23:05.653402+00	2026-07-21 12:23:05.653402+00
9e026bc3-66b8-45d7-9c60-0989a6664192	109803ba-a3bb-482b-afd4-57f854298016	2310cdf5-d549-4a28-bc04-2052038876fc	پیشرفت اولیه و بررسی نیازمندی‌ها	33	78	2026-07-16	approved	be682dce-6665-4ff0-8e8a-067602882309	\N	6d3ab5c6-b8a8-47f7-bf01-ff0f1d7a17ac	2026-07-21 12:23:05.653402+00	2026-07-21 12:23:05.653402+00
9e026bc3-66b8-45d7-9c60-0989a6664192	109803ba-a3bb-482b-afd4-57f854298016	2310cdf5-d549-4a28-bc04-2052038876fc	رفع اشکالات و بازبینی	122	100	2026-07-16	approved	be682dce-6665-4ff0-8e8a-067602882309	\N	280a6459-aa1d-4354-8a97-54a2f1781e01	2026-07-21 12:23:05.653402+00	2026-07-21 12:23:05.653402+00
9e026bc3-66b8-45d7-9c60-0989a6664192	eb8250e8-9347-49da-aeee-518716b53a98	2310cdf5-d549-4a28-bc04-2052038876fc	پیاده‌سازی بخش اصلی	98	35	2026-07-01	approved	be682dce-6665-4ff0-8e8a-067602882309	\N	4c7f76ac-d0a0-4cf5-ae88-e2bee7595175	2026-07-21 12:23:05.653402+00	2026-07-21 12:23:05.653402+00
9e026bc3-66b8-45d7-9c60-0989a6664192	eb8250e8-9347-49da-aeee-518716b53a98	2310cdf5-d549-4a28-bc04-2052038876fc	تست و اطمینان از عملکرد صحیح	138	52	2026-07-04	approved	be682dce-6665-4ff0-8e8a-067602882309	\N	8325fa35-27f1-4be0-a43c-337b3272606e	2026-07-21 12:23:05.653402+00	2026-07-21 12:23:05.653402+00
9e026bc3-66b8-45d7-9c60-0989a6664192	eb8250e8-9347-49da-aeee-518716b53a98	2310cdf5-d549-4a28-bc04-2052038876fc	رفع اشکالات و بازبینی	123	96	2026-07-09	submitted	\N	\N	aee32221-3888-414f-b4a0-454124fecdde	2026-07-21 12:23:05.653402+00	2026-07-21 12:23:05.653402+00
9e026bc3-66b8-45d7-9c60-0989a6664192	9778855a-b436-4ab7-ab4d-957c01fcc966	3cdfd222-0ea4-4a30-b15b-036d1d733193	پیاده‌سازی بخش اصلی	177	27	2026-07-11	approved	be682dce-6665-4ff0-8e8a-067602882309	\N	0e278008-db64-498b-8653-618d823aac15	2026-07-21 12:23:05.653402+00	2026-07-21 12:23:05.653402+00
9e026bc3-66b8-45d7-9c60-0989a6664192	9778855a-b436-4ab7-ab4d-957c01fcc966	3cdfd222-0ea4-4a30-b15b-036d1d733193	پیاده‌سازی بخش اصلی	172	66	2026-07-12	submitted	\N	\N	1c094336-1d8e-4605-be51-d517ead1ac9d	2026-07-21 12:23:05.653402+00	2026-07-21 12:23:05.653402+00
9e026bc3-66b8-45d7-9c60-0989a6664192	9778855a-b436-4ab7-ab4d-957c01fcc966	3cdfd222-0ea4-4a30-b15b-036d1d733193	پیاده‌سازی بخش اصلی	151	60	2026-07-16	approved	be682dce-6665-4ff0-8e8a-067602882309	\N	f3a5ec72-fc46-4c45-ac0d-cbb682cffabd	2026-07-21 12:23:05.653402+00	2026-07-21 12:23:05.653402+00
9e026bc3-66b8-45d7-9c60-0989a6664192	1912c97e-1d15-4c25-9809-6302c5c59de6	3cdfd222-0ea4-4a30-b15b-036d1d733193	تست و اطمینان از عملکرد صحیح	64	40	2026-07-11	approved	be682dce-6665-4ff0-8e8a-067602882309	\N	fa05d0e2-0661-4b25-8e21-151121b4c07d	2026-07-21 12:23:05.653402+00	2026-07-21 12:23:05.653402+00
9e026bc3-66b8-45d7-9c60-0989a6664192	1912c97e-1d15-4c25-9809-6302c5c59de6	3cdfd222-0ea4-4a30-b15b-036d1d733193	تست و اطمینان از عملکرد صحیح	106	56	2026-07-14	approved	be682dce-6665-4ff0-8e8a-067602882309	\N	df99ac8a-b80e-4e89-8256-0cc2c0506dca	2026-07-21 12:23:05.653402+00	2026-07-21 12:23:05.653402+00
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


