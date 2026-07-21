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
    created_at timestamp with time zone DEFAULT now(),
    updated_at timestamp with time zone DEFAULT now(),
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
4b49b01e-742e-4448-94a7-cce610ef9084	2026-07-21 18:35:18.932907+00	2026-07-21 18:35:18.932907+00	09100000001	$2b$12$Xf8lfSgiNHeLX6bVNRs4Au6v.hQ9c8kZqteiaSu6wB/bxwm0Tw.cK
10e8e00c-ded0-4d26-bec6-27ad5e91181e	2026-07-21 18:35:18.932907+00	2026-07-21 18:35:18.932907+00	09111000000	$2b$12$MZjhFS2Yh5cmNxS3KxugPOW24TzH65.Dj7IGJ2IcPsooKfrR5fWOG
31e72aa3-59e9-4a27-a89f-9107b4745e19	2026-07-21 18:35:18.932907+00	2026-07-21 18:35:18.932907+00	09111000011	$2b$12$Gv23PZ1aRyo8jH3iMi3TXuBiGgP88TfW6XvSq2e3ZX8HO64vOaJkW
b57398af-b8bc-42b9-9af8-258d6b9a503b	2026-07-21 18:35:18.932907+00	2026-07-21 18:35:18.932907+00	09111000012	$2b$12$qgk7ouwZmY35oq9AZptJSOuZrSolU6R54HWGSoQbglhLoZ8JVS/pK
847cbd73-f8c1-42f2-a201-1ef8d03f3568	2026-07-21 18:35:18.932907+00	2026-07-21 18:35:18.932907+00	09111000013	$2b$12$.QVDgqX0MQc.5ZyXc6UE/uhHL8uUAG48BZZkwtu9ZGh7Xbc7yRhna
aa5b71b6-a0d8-43f3-b696-0188c6659df6	2026-07-21 18:35:18.932907+00	2026-07-21 18:35:18.932907+00	09111000014	$2b$12$N.oR6Wqo75i5KfmGTyLkSOKfoazlUzDfo/7v372GhEa/6myErenGm
4d5de859-c5d2-40aa-b5bd-6750522ccc15	2026-07-21 18:35:18.932907+00	2026-07-21 18:35:18.932907+00	09111000015	$2b$12$lY.8lpRN6RJTs1benCTqW.KDRbBFtKUZFx5PSbYr7Ghnt0khvvSq.
43703a0f-5bbf-499e-b150-b4166050b9a8	2026-07-21 18:35:18.932907+00	2026-07-21 18:35:18.932907+00	09111000016	$2b$12$b4tQnIWlDlGZo2VtzXr5EOc0DKAVXH92Gg.X0nwD93U.VU9DYpjcy
8f0c1180-b904-49e6-b320-5c6102502225	2026-07-21 18:35:18.932907+00	2026-07-21 18:35:18.932907+00	09121000100	$2b$12$3o6BcQuoOR98Gg/W9kluOOUk.F/OQNbQRpXhlk/rTNh2j1Ynvyjt.
843ff753-4370-4bc8-8e86-8d3da6e97416	2026-07-21 18:35:18.932907+00	2026-07-21 18:35:18.932907+00	09121000111	$2b$12$hS0wHp1cS.AKSNtFnpWhHOWk0xYA2HMJxzS9myUqFrJMSLjk9jF3u
1c16d574-41cd-45e5-bff5-eb00ddf1f90e	2026-07-21 18:35:18.932907+00	2026-07-21 18:35:18.932907+00	09121000112	$2b$12$arvnAyR0Vc/mPZl.NWw0gOBjthxwzSOF.4YfJueaW1jVqjPxNygdK
3f0a94fd-4199-44c4-a7b9-dcce9406af77	2026-07-21 18:35:18.932907+00	2026-07-21 18:35:18.932907+00	09121000113	$2b$12$X.A8xYIyXG9H6yRvEDXEEe10I4MLls5QCPrkj3WC3RG7D7yEhWmi.
5a105954-dd93-4e72-9ea8-6a038545fb19	2026-07-21 18:35:18.932907+00	2026-07-21 18:35:18.932907+00	09121000114	$2b$12$nLc2KpKjeemMNFw0IoIvbOrdrYg4t4nd52yvtaTlvUaj0vZbIVS8m
f2793500-0cc7-42de-88eb-f054d563b036	2026-07-21 18:35:18.932907+00	2026-07-21 18:35:18.932907+00	09121000115	$2b$12$WaI/DcU2oxHLQRXsQJjZfOGifWLADz/CSZleHCgzyfv.KGMIW2Heu
4b7fd3d9-dec3-4323-b845-3e21fcb9f5b5	2026-07-21 18:35:18.932907+00	2026-07-21 18:35:18.932907+00	09121000116	$2b$12$gYPWg4qLLrqPolcuoz/Q2O4hcmTRnOuiVAgoI8gfU.BTV83anGR5u
30933020-1975-49aa-a568-b42795f02f50	2026-07-21 18:35:18.932907+00	2026-07-21 18:35:18.932907+00	09131000200	$2b$12$b1x2dgLLNWh8XZs1Q/oVtehFl/i9KYUhmRxl9KnQ/x.UfRKi6KWmm
36d26141-c6e3-4be6-9f53-574eb940b9d9	2026-07-21 18:35:18.932907+00	2026-07-21 18:35:18.932907+00	09131000211	$2b$12$wau5srBEBhua.4S4TQuBuecWNSA5AdKdk5c/stdOC8IqCZb9uJ5Yi
9ff96b48-f0c4-4a7a-b91d-61ecfa082913	2026-07-21 18:35:18.932907+00	2026-07-21 18:35:18.932907+00	09131000212	$2b$12$UK3V/hGg2od6uZ.4Ooni4OFWR2HnfOGj8bY12ARXo43dg8dNwKtce
4cf6809c-116a-43d8-9d46-36e081499444	2026-07-21 18:35:18.932907+00	2026-07-21 18:35:18.932907+00	09131000213	$2b$12$maaQRNS9.7eRBPFaAv2aIu/AKwpTPjxFMIUIGX7ksj9xa3wJi.PmC
3277ac40-85b1-406d-b0c2-8830e1f4d03d	2026-07-21 18:35:18.932907+00	2026-07-21 18:35:18.932907+00	09131000214	$2b$12$3FVOnlgU73WSlFQ4kcwoN.WX0t.aBfB.yfEMhXEvK7qYi1lIdi0US
2fde7a9c-d11d-4417-bf46-37c0eedad436	2026-07-21 18:35:18.932907+00	2026-07-21 18:35:18.932907+00	09131000215	$2b$12$0LySKxCJG828xTwdjmFjgedtx5bGso5ZWAqsxpE8PjOOYD3NCxYIO
c6919541-2fec-4438-b146-59f0397a48b2	2026-07-21 18:35:18.932907+00	2026-07-21 18:35:18.932907+00	09131000216	$2b$12$X6bh7sCFzpYPHGugGkonTesDvZKUMVqH3K49ZeLRFO31h4g59GKGm
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
\.


--
-- Data for Name: audit_logs; Type: TABLE DATA; Schema: public; Owner: -
--

COPY public.audit_logs (created_at, organization_id, actor_user_id, action, entity_type, entity_id, extra_metadata, id) FROM stdin;
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
63c5e5e8-fba3-4a2b-9e72-2fc69030d79f	2026-07-21 18:35:18.932907+00	2026-07-21 18:35:18.932907+00	efb263c4-05b2-42d2-bc77-af9f0cbd846e	c0c1258a-257b-4a56-bc50-4efdde442732	a256424e-8cd7-4ffb-b83d-74e08a248892	\N	جلسهٔ برنامه‌ریزی اسپرینت	\N	meeting	2026-06-20 10:00:00+00	2026-06-20 11:00:00+00	f	\N
776ca2f7-b421-479c-ac0c-a7e7aa36c17e	2026-07-21 18:35:18.932907+00	2026-07-21 18:35:18.932907+00	efb263c4-05b2-42d2-bc77-af9f0cbd846e	4cef53c1-898c-4945-b51b-a1d36322bb51	d2117d77-f066-4ab6-9678-e32a36d45c1a	\N	یادآوری ارسال گزارش	\N	reminder	2026-06-17 00:00:00+00	2026-06-17 01:00:00+00	t	\N
e128c4fa-089c-4abb-985d-f290710263fa	2026-07-21 18:35:18.932907+00	2026-07-21 18:35:18.932907+00	efb263c4-05b2-42d2-bc77-af9f0cbd846e	c0c1258a-257b-4a56-bc50-4efdde442732	a256424e-8cd7-4ffb-b83d-74e08a248892	\N	جلسهٔ برنامه‌ریزی اسپرینت	\N	meeting	2026-06-27 10:00:00+00	2026-06-27 11:00:00+00	f	\N
a7a5a5ef-eaa4-452d-b76a-741fdd18e78f	2026-07-21 18:35:18.932907+00	2026-07-21 18:35:18.932907+00	efb263c4-05b2-42d2-bc77-af9f0cbd846e	4cef53c1-898c-4945-b51b-a1d36322bb51	654a21fd-66c7-412b-9936-bb14abeb65b1	\N	یادآوری پیگیری مشتری	\N	reminder	2026-06-23 00:00:00+00	2026-06-23 01:00:00+00	t	\N
eec14bbb-9ffc-41ab-a7af-d32840491e5c	2026-07-21 18:35:18.932907+00	2026-07-21 18:35:18.932907+00	efb263c4-05b2-42d2-bc77-af9f0cbd846e	c0c1258a-257b-4a56-bc50-4efdde442732	654a21fd-66c7-412b-9936-bb14abeb65b1	\N	جلسهٔ هماهنگی هفتگی	\N	meeting	2026-07-04 10:00:00+00	2026-07-04 11:00:00+00	f	\N
13de5aa4-c408-4344-8494-e48ca3ad0088	2026-07-21 18:35:18.932907+00	2026-07-21 18:35:18.932907+00	efb263c4-05b2-42d2-bc77-af9f0cbd846e	2a912655-64c4-44a5-9beb-6093704c47bd	a256424e-8cd7-4ffb-b83d-74e08a248892	\N	یادآوری پیگیری مشتری	\N	reminder	2026-07-03 00:00:00+00	2026-07-03 01:00:00+00	t	\N
3bc5ccee-3177-461a-b13d-848211b713fc	2026-07-21 18:35:18.932907+00	2026-07-21 18:35:18.932907+00	efb263c4-05b2-42d2-bc77-af9f0cbd846e	c0c1258a-257b-4a56-bc50-4efdde442732	d2117d77-f066-4ab6-9678-e32a36d45c1a	\N	جلسهٔ برنامه‌ریزی اسپرینت	\N	meeting	2026-07-09 10:00:00+00	2026-07-09 11:00:00+00	f	\N
1e4e7749-b75a-471d-b275-bba4e246d945	2026-07-21 18:35:18.932907+00	2026-07-21 18:35:18.932907+00	efb263c4-05b2-42d2-bc77-af9f0cbd846e	caaef6d7-fee2-48a7-bd4b-3697a88773ea	e79efaad-56e0-4883-adb3-699fa5b5b4e1	\N	یادآوری ارسال گزارش	\N	reminder	2026-07-12 00:00:00+00	2026-07-12 01:00:00+00	t	\N
08641453-6b11-4c88-9df7-8c019d20d3da	2026-07-21 18:35:18.932907+00	2026-07-21 18:35:18.932907+00	efb263c4-05b2-42d2-bc77-af9f0cbd846e	c0c1258a-257b-4a56-bc50-4efdde442732	e79efaad-56e0-4883-adb3-699fa5b5b4e1	\N	جلسهٔ هماهنگی هفتگی	\N	meeting	2026-07-15 10:00:00+00	2026-07-15 11:00:00+00	f	\N
fecc9844-74d9-4f67-8260-ff64044fcbeb	2026-07-21 18:35:18.932907+00	2026-07-21 18:35:18.932907+00	efb263c4-05b2-42d2-bc77-af9f0cbd846e	4cef53c1-898c-4945-b51b-a1d36322bb51	e79efaad-56e0-4883-adb3-699fa5b5b4e1	\N	یادآوری ارسال گزارش	\N	reminder	2026-07-20 00:00:00+00	2026-07-20 01:00:00+00	t	\N
4a7f4f7c-6f5e-4b9e-a2a3-ee3469e3e257	2026-07-21 18:35:18.932907+00	2026-07-21 18:35:18.932907+00	efb263c4-05b2-42d2-bc77-af9f0cbd846e	c0c1258a-257b-4a56-bc50-4efdde442732	a256424e-8cd7-4ffb-b83d-74e08a248892	\N	جلسهٔ برنامه‌ریزی اسپرینت	\N	meeting	2026-07-23 10:00:00+00	2026-07-23 11:00:00+00	f	\N
1a2b8370-2ef9-4568-9144-3c9f3a023ed8	2026-07-21 18:35:18.932907+00	2026-07-21 18:35:18.932907+00	efb263c4-05b2-42d2-bc77-af9f0cbd846e	1bc00cf9-0b6c-453b-8f81-55a9f72ad244	c6d8abca-4a0d-480d-85f7-d34d1d133855	\N	یادآوری پیگیری مشتری	\N	reminder	2026-07-27 00:00:00+00	2026-07-27 01:00:00+00	t	\N
e04d02b1-86d2-4d43-961e-19501f3e7eee	2026-07-21 18:35:18.932907+00	2026-07-21 18:35:18.932907+00	efb263c4-05b2-42d2-bc77-af9f0cbd846e	c0c1258a-257b-4a56-bc50-4efdde442732	d2117d77-f066-4ab6-9678-e32a36d45c1a	\N	جلسهٔ بررسی پیشرفت پروژه	\N	meeting	2026-07-31 10:00:00+00	2026-07-31 11:00:00+00	f	\N
27409f77-7c05-4160-905d-db69359216b3	2026-07-21 18:35:18.932907+00	2026-07-21 18:35:18.932907+00	efb263c4-05b2-42d2-bc77-af9f0cbd846e	14420cd5-d1bc-4e91-8063-b90ed9c1d745	a256424e-8cd7-4ffb-b83d-74e08a248892	\N	یادآوری پیگیری مشتری	\N	reminder	2026-08-03 00:00:00+00	2026-08-03 01:00:00+00	t	\N
ac624365-09a4-447e-8733-9cca03f5f713	2026-07-21 18:35:18.932907+00	2026-07-21 18:35:18.932907+00	efb263c4-05b2-42d2-bc77-af9f0cbd846e	c0c1258a-257b-4a56-bc50-4efdde442732	d2117d77-f066-4ab6-9678-e32a36d45c1a	\N	جلسهٔ برنامه‌ریزی اسپرینت	\N	meeting	2026-08-04 10:00:00+00	2026-08-04 11:00:00+00	f	\N
725594df-e2a9-47f6-9993-f9a13a22d56e	2026-07-21 18:35:18.932907+00	2026-07-21 18:35:18.932907+00	efb263c4-05b2-42d2-bc77-af9f0cbd846e	caaef6d7-fee2-48a7-bd4b-3697a88773ea	c6d8abca-4a0d-480d-85f7-d34d1d133855	\N	یادآوری ارسال گزارش	\N	reminder	2026-08-05 00:00:00+00	2026-08-05 01:00:00+00	t	\N
149fdf06-58c9-4945-9f5c-72c866a5fd0a	2026-07-21 18:35:18.932907+00	2026-07-21 18:35:18.932907+00	efb263c4-05b2-42d2-bc77-af9f0cbd846e	c0c1258a-257b-4a56-bc50-4efdde442732	e79efaad-56e0-4883-adb3-699fa5b5b4e1	\N	جلسهٔ مرور با مدیریت	\N	meeting	2026-08-13 10:00:00+00	2026-08-13 11:00:00+00	f	\N
bbd33926-0fe1-427f-a32a-cbc4e9bd4c76	2026-07-21 18:35:18.932907+00	2026-07-21 18:35:18.932907+00	efb263c4-05b2-42d2-bc77-af9f0cbd846e	4cef53c1-898c-4945-b51b-a1d36322bb51	d2117d77-f066-4ab6-9678-e32a36d45c1a	\N	یادآوری تمدید قرارداد	\N	reminder	2026-08-17 00:00:00+00	2026-08-17 01:00:00+00	t	\N
efc9d33d-9124-4db3-a181-82d7ce3e672e	2026-07-21 18:35:18.932907+00	2026-07-21 18:35:18.932907+00	efb263c4-05b2-42d2-bc77-af9f0cbd846e	e262d280-b97e-4087-8e78-a66519bae4d1	53b4a7c0-5ff9-4b29-a337-82321def0955	\N	جلسهٔ برنامه‌ریزی اسپرینت	\N	meeting	2026-06-17 10:00:00+00	2026-06-17 11:00:00+00	f	\N
5f00c2ec-1e6f-4276-b22c-382de4ec5d1d	2026-07-21 18:35:18.932907+00	2026-07-21 18:35:18.932907+00	efb263c4-05b2-42d2-bc77-af9f0cbd846e	1d9f738d-866c-4e32-9fe8-b80f0b30a62b	53b4a7c0-5ff9-4b29-a337-82321def0955	\N	یادآوری تمدید قرارداد	\N	reminder	2026-06-19 00:00:00+00	2026-06-19 01:00:00+00	t	\N
04bbe3c1-f2d9-4df8-aaea-628a3f1eeb8c	2026-07-21 18:35:18.932907+00	2026-07-21 18:35:18.932907+00	efb263c4-05b2-42d2-bc77-af9f0cbd846e	e262d280-b97e-4087-8e78-a66519bae4d1	e35b32f7-7e12-42fe-912f-f80b60c4ace4	\N	جلسهٔ برنامه‌ریزی اسپرینت	\N	meeting	2026-06-23 10:00:00+00	2026-06-23 11:00:00+00	f	\N
8d677617-1362-4b5f-9878-ee6da28adca9	2026-07-21 18:35:18.932907+00	2026-07-21 18:35:18.932907+00	efb263c4-05b2-42d2-bc77-af9f0cbd846e	e73ec14e-ca0c-4615-92d5-5bc43c14999a	e2872a09-ca5b-4560-b31c-9639fc42eeb2	\N	یادآوری ارسال گزارش	\N	reminder	2026-06-26 00:00:00+00	2026-06-26 01:00:00+00	t	\N
3cc689cf-a0da-4ac3-9fbf-7e48649c8848	2026-07-21 18:35:18.932907+00	2026-07-21 18:35:18.932907+00	efb263c4-05b2-42d2-bc77-af9f0cbd846e	e262d280-b97e-4087-8e78-a66519bae4d1	53b4a7c0-5ff9-4b29-a337-82321def0955	\N	جلسهٔ هماهنگی هفتگی	\N	meeting	2026-07-01 10:00:00+00	2026-07-01 11:00:00+00	f	\N
066d25c3-3b0f-43a5-b65c-34ccf792c274	2026-07-21 18:35:18.932907+00	2026-07-21 18:35:18.932907+00	efb263c4-05b2-42d2-bc77-af9f0cbd846e	faf489ef-0410-4dca-bec1-65dd2fb904ba	009a2a44-5f53-4b44-a083-b37afdcd5b4d	\N	یادآوری تمدید قرارداد	\N	reminder	2026-07-03 00:00:00+00	2026-07-03 01:00:00+00	t	\N
9fc4e9c6-5c0f-4e5d-9168-a587324a6eba	2026-07-21 18:35:18.932907+00	2026-07-21 18:35:18.932907+00	efb263c4-05b2-42d2-bc77-af9f0cbd846e	e262d280-b97e-4087-8e78-a66519bae4d1	53b4a7c0-5ff9-4b29-a337-82321def0955	\N	جلسهٔ برنامه‌ریزی اسپرینت	\N	meeting	2026-07-10 10:00:00+00	2026-07-10 11:00:00+00	f	\N
20630cde-9b1f-45c1-b792-e5195f2c60ee	2026-07-21 18:35:18.932907+00	2026-07-21 18:35:18.932907+00	efb263c4-05b2-42d2-bc77-af9f0cbd846e	1c37102f-d8b4-4bea-bd82-5b862cd46e2b	009a2a44-5f53-4b44-a083-b37afdcd5b4d	\N	یادآوری تمدید قرارداد	\N	reminder	2026-07-11 00:00:00+00	2026-07-11 01:00:00+00	t	\N
118bdd3f-7e7d-4d85-82ab-586549ec9f70	2026-07-21 18:35:18.932907+00	2026-07-21 18:35:18.932907+00	efb263c4-05b2-42d2-bc77-af9f0cbd846e	e262d280-b97e-4087-8e78-a66519bae4d1	009a2a44-5f53-4b44-a083-b37afdcd5b4d	\N	جلسهٔ هماهنگی هفتگی	\N	meeting	2026-07-15 10:00:00+00	2026-07-15 11:00:00+00	f	\N
17243cb2-4161-4042-a4cb-bf7203313054	2026-07-21 18:35:18.932907+00	2026-07-21 18:35:18.932907+00	efb263c4-05b2-42d2-bc77-af9f0cbd846e	1c37102f-d8b4-4bea-bd82-5b862cd46e2b	6b87fbf4-f215-4875-9b6d-ba65c7cae7e2	\N	یادآوری ارسال گزارش	\N	reminder	2026-07-16 00:00:00+00	2026-07-16 01:00:00+00	t	\N
dd001ca6-56e5-4438-b08b-9903e5033ef6	2026-07-21 18:35:18.932907+00	2026-07-21 18:35:18.932907+00	efb263c4-05b2-42d2-bc77-af9f0cbd846e	e262d280-b97e-4087-8e78-a66519bae4d1	009a2a44-5f53-4b44-a083-b37afdcd5b4d	\N	جلسهٔ مرور با مدیریت	\N	meeting	2026-07-21 10:00:00+00	2026-07-21 11:00:00+00	f	\N
38cc45e7-8708-42cc-bc71-b001816c7a89	2026-07-21 18:35:18.932907+00	2026-07-21 18:35:18.932907+00	efb263c4-05b2-42d2-bc77-af9f0cbd846e	c288bac5-e3a4-4f1f-a050-de12845acf11	53b4a7c0-5ff9-4b29-a337-82321def0955	\N	یادآوری ارسال گزارش	\N	reminder	2026-07-25 00:00:00+00	2026-07-25 01:00:00+00	t	\N
170cbc99-500f-4432-a238-c37aab3beb22	2026-07-21 18:35:18.932907+00	2026-07-21 18:35:18.932907+00	efb263c4-05b2-42d2-bc77-af9f0cbd846e	e262d280-b97e-4087-8e78-a66519bae4d1	6b87fbf4-f215-4875-9b6d-ba65c7cae7e2	\N	جلسهٔ بررسی پیشرفت پروژه	\N	meeting	2026-07-28 10:00:00+00	2026-07-28 11:00:00+00	f	\N
3afe509d-5022-42fb-a4b3-ac772ffb1d3f	2026-07-21 18:35:18.932907+00	2026-07-21 18:35:18.932907+00	efb263c4-05b2-42d2-bc77-af9f0cbd846e	e73ec14e-ca0c-4615-92d5-5bc43c14999a	009a2a44-5f53-4b44-a083-b37afdcd5b4d	\N	یادآوری پیگیری مشتری	\N	reminder	2026-08-02 00:00:00+00	2026-08-02 01:00:00+00	t	\N
b2e434d5-7538-41ba-85d6-b5571837da79	2026-07-21 18:35:18.932907+00	2026-07-21 18:35:18.932907+00	efb263c4-05b2-42d2-bc77-af9f0cbd846e	e262d280-b97e-4087-8e78-a66519bae4d1	e35b32f7-7e12-42fe-912f-f80b60c4ace4	\N	جلسهٔ مرور با مدیریت	\N	meeting	2026-08-05 10:00:00+00	2026-08-05 11:00:00+00	f	\N
5d00e7df-e0b6-4cc8-8e67-18a84c70c285	2026-07-21 18:35:18.932907+00	2026-07-21 18:35:18.932907+00	efb263c4-05b2-42d2-bc77-af9f0cbd846e	e73ec14e-ca0c-4615-92d5-5bc43c14999a	6b87fbf4-f215-4875-9b6d-ba65c7cae7e2	\N	یادآوری ارسال گزارش	\N	reminder	2026-08-06 00:00:00+00	2026-08-06 01:00:00+00	t	\N
039da950-228f-4f66-9a4b-f731fe486072	2026-07-21 18:35:18.932907+00	2026-07-21 18:35:18.932907+00	efb263c4-05b2-42d2-bc77-af9f0cbd846e	e262d280-b97e-4087-8e78-a66519bae4d1	53b4a7c0-5ff9-4b29-a337-82321def0955	\N	جلسهٔ برنامه‌ریزی اسپرینت	\N	meeting	2026-08-13 10:00:00+00	2026-08-13 11:00:00+00	f	\N
e5a887e9-2430-4b44-90ae-35128c38cd27	2026-07-21 18:35:18.932907+00	2026-07-21 18:35:18.932907+00	efb263c4-05b2-42d2-bc77-af9f0cbd846e	7dcd0e37-2d6c-4eab-8a6a-3598c4e01433	009a2a44-5f53-4b44-a083-b37afdcd5b4d	\N	یادآوری پیگیری مشتری	\N	reminder	2026-08-15 00:00:00+00	2026-08-15 01:00:00+00	t	\N
925c536f-af30-424e-8d9c-7d2355820ff3	2026-07-21 18:35:18.932907+00	2026-07-21 18:35:18.932907+00	efb263c4-05b2-42d2-bc77-af9f0cbd846e	89f48814-745b-462e-820c-aff4124c3949	7f7c651b-87ea-4b3a-8b88-3bec205cfc31	\N	جلسهٔ هماهنگی هفتگی	\N	meeting	2026-06-20 10:00:00+00	2026-06-20 11:00:00+00	f	\N
76dfead9-c63f-43f9-9b09-91041bfe65c2	2026-07-21 18:35:18.932907+00	2026-07-21 18:35:18.932907+00	efb263c4-05b2-42d2-bc77-af9f0cbd846e	63d308ce-8593-4f45-8c4b-1df63a00732c	65f2eec9-9404-43e1-bfd6-2f22321a8701	\N	یادآوری ارسال گزارش	\N	reminder	2026-06-19 00:00:00+00	2026-06-19 01:00:00+00	t	\N
c98b3c68-1e74-4224-90d8-d59d9f077e9a	2026-07-21 18:35:18.932907+00	2026-07-21 18:35:18.932907+00	efb263c4-05b2-42d2-bc77-af9f0cbd846e	89f48814-745b-462e-820c-aff4124c3949	65f2eec9-9404-43e1-bfd6-2f22321a8701	\N	جلسهٔ مرور با مدیریت	\N	meeting	2026-06-25 10:00:00+00	2026-06-25 11:00:00+00	f	\N
2e320704-d418-45a9-bd7d-4e6fc12467f5	2026-07-21 18:35:18.932907+00	2026-07-21 18:35:18.932907+00	efb263c4-05b2-42d2-bc77-af9f0cbd846e	4bfc028f-1c19-4b0c-9188-9fe233b49cb4	4554595d-9245-40e3-b08c-d872099d1fc1	\N	یادآوری تمدید قرارداد	\N	reminder	2026-06-29 00:00:00+00	2026-06-29 01:00:00+00	t	\N
317a35a0-e3c1-401f-873a-b39d18233405	2026-07-21 18:35:18.932907+00	2026-07-21 18:35:18.932907+00	efb263c4-05b2-42d2-bc77-af9f0cbd846e	89f48814-745b-462e-820c-aff4124c3949	f3b6db39-3c7b-41fa-bfa4-b7ae409a154a	\N	جلسهٔ برنامه‌ریزی اسپرینت	\N	meeting	2026-07-02 10:00:00+00	2026-07-02 11:00:00+00	f	\N
a1d3b326-242a-45e9-8f1a-4770158429d5	2026-07-21 18:35:18.932907+00	2026-07-21 18:35:18.932907+00	efb263c4-05b2-42d2-bc77-af9f0cbd846e	e38a8fbd-4c9d-4475-ae1b-150a034a6936	7f7c651b-87ea-4b3a-8b88-3bec205cfc31	\N	یادآوری تمدید قرارداد	\N	reminder	2026-07-02 00:00:00+00	2026-07-02 01:00:00+00	t	\N
66ebd97e-c4b3-468a-949e-5a77d971e936	2026-07-21 18:35:18.932907+00	2026-07-21 18:35:18.932907+00	efb263c4-05b2-42d2-bc77-af9f0cbd846e	89f48814-745b-462e-820c-aff4124c3949	f3b6db39-3c7b-41fa-bfa4-b7ae409a154a	\N	جلسهٔ مرور با مدیریت	\N	meeting	2026-07-07 10:00:00+00	2026-07-07 11:00:00+00	f	\N
f4cdbba5-0948-477c-805a-c28fef6ba047	2026-07-21 18:35:18.932907+00	2026-07-21 18:35:18.932907+00	efb263c4-05b2-42d2-bc77-af9f0cbd846e	eb0b5b71-65c1-4694-a9d0-5b2b7aea8eae	7f7c651b-87ea-4b3a-8b88-3bec205cfc31	\N	یادآوری ارسال گزارش	\N	reminder	2026-07-07 00:00:00+00	2026-07-07 01:00:00+00	t	\N
e22367b4-98ce-4dc6-bc9d-95e4fe1214d2	2026-07-21 18:35:18.932907+00	2026-07-21 18:35:18.932907+00	efb263c4-05b2-42d2-bc77-af9f0cbd846e	89f48814-745b-462e-820c-aff4124c3949	7f7c651b-87ea-4b3a-8b88-3bec205cfc31	\N	جلسهٔ بررسی پیشرفت پروژه	\N	meeting	2026-07-18 10:00:00+00	2026-07-18 11:00:00+00	f	\N
7168814e-e4f8-47ba-8842-9e21787cdc84	2026-07-21 18:35:18.932907+00	2026-07-21 18:35:18.932907+00	efb263c4-05b2-42d2-bc77-af9f0cbd846e	eb0b5b71-65c1-4694-a9d0-5b2b7aea8eae	f3b6db39-3c7b-41fa-bfa4-b7ae409a154a	\N	یادآوری تمدید قرارداد	\N	reminder	2026-07-20 00:00:00+00	2026-07-20 01:00:00+00	t	\N
b9c30ee2-ae34-4370-ab24-57d800a61b49	2026-07-21 18:35:18.932907+00	2026-07-21 18:35:18.932907+00	efb263c4-05b2-42d2-bc77-af9f0cbd846e	89f48814-745b-462e-820c-aff4124c3949	7f7c651b-87ea-4b3a-8b88-3bec205cfc31	\N	جلسهٔ مرور با مدیریت	\N	meeting	2026-07-24 10:00:00+00	2026-07-24 11:00:00+00	f	\N
f1a8ea7a-a7fa-4422-8752-24541a3cb6af	2026-07-21 18:35:18.932907+00	2026-07-21 18:35:18.932907+00	efb263c4-05b2-42d2-bc77-af9f0cbd846e	3d944638-fc96-463d-84ac-c7c861324cbe	7f7c651b-87ea-4b3a-8b88-3bec205cfc31	\N	یادآوری تمدید قرارداد	\N	reminder	2026-07-21 00:00:00+00	2026-07-21 01:00:00+00	t	\N
bd06181c-fc92-48d9-b63b-d2cba180053e	2026-07-21 18:35:18.932907+00	2026-07-21 18:35:18.932907+00	efb263c4-05b2-42d2-bc77-af9f0cbd846e	89f48814-745b-462e-820c-aff4124c3949	af916260-f69c-4181-a986-3df8a4df7239	\N	جلسهٔ بررسی پیشرفت پروژه	\N	meeting	2026-07-29 10:00:00+00	2026-07-29 11:00:00+00	f	\N
e4416706-c188-4f62-9eeb-1638816f1901	2026-07-21 18:35:18.932907+00	2026-07-21 18:35:18.932907+00	efb263c4-05b2-42d2-bc77-af9f0cbd846e	eb0b5b71-65c1-4694-a9d0-5b2b7aea8eae	af916260-f69c-4181-a986-3df8a4df7239	\N	یادآوری پیگیری مشتری	\N	reminder	2026-08-02 00:00:00+00	2026-08-02 01:00:00+00	t	\N
6fe1c9ad-84b8-40aa-80ff-82ea105b2120	2026-07-21 18:35:18.932907+00	2026-07-21 18:35:18.932907+00	efb263c4-05b2-42d2-bc77-af9f0cbd846e	89f48814-745b-462e-820c-aff4124c3949	7f7c651b-87ea-4b3a-8b88-3bec205cfc31	\N	جلسهٔ مرور با مدیریت	\N	meeting	2026-08-08 10:00:00+00	2026-08-08 11:00:00+00	f	\N
5e5e2317-dccc-4a91-967c-be40e8bb7459	2026-07-21 18:35:18.932907+00	2026-07-21 18:35:18.932907+00	efb263c4-05b2-42d2-bc77-af9f0cbd846e	63d308ce-8593-4f45-8c4b-1df63a00732c	4554595d-9245-40e3-b08c-d872099d1fc1	\N	یادآوری ارسال گزارش	\N	reminder	2026-08-10 00:00:00+00	2026-08-10 01:00:00+00	t	\N
1852d8bc-8b0c-4b7e-9db7-88539a33de6f	2026-07-21 18:35:18.932907+00	2026-07-21 18:35:18.932907+00	efb263c4-05b2-42d2-bc77-af9f0cbd846e	89f48814-745b-462e-820c-aff4124c3949	f3b6db39-3c7b-41fa-bfa4-b7ae409a154a	\N	جلسهٔ برنامه‌ریزی اسپرینت	\N	meeting	2026-08-12 10:00:00+00	2026-08-12 11:00:00+00	f	\N
571abd30-d55c-4595-889f-b256a61d59d5	2026-07-21 18:35:18.932907+00	2026-07-21 18:35:18.932907+00	efb263c4-05b2-42d2-bc77-af9f0cbd846e	4bfc028f-1c19-4b0c-9188-9fe233b49cb4	f3b6db39-3c7b-41fa-bfa4-b7ae409a154a	\N	یادآوری پیگیری مشتری	\N	reminder	2026-08-13 00:00:00+00	2026-08-13 01:00:00+00	t	\N
4da940c5-449c-4d4a-99bf-2c6202dbfe62	2026-07-21 18:35:18.932907+00	2026-07-21 18:35:18.932907+00	efb263c4-05b2-42d2-bc77-af9f0cbd846e	5015f0ba-e578-4955-b532-c78d5f462686	\N	\N	تعطیلی رسمی	\N	holiday	2026-06-18 00:00:00+00	2026-06-18 01:00:00+00	t	\N
d7fe6643-8701-4375-b633-0a0d420559e4	2026-07-21 18:35:18.932907+00	2026-07-21 18:35:18.932907+00	efb263c4-05b2-42d2-bc77-af9f0cbd846e	5015f0ba-e578-4955-b532-c78d5f462686	\N	\N	تعطیلی رسمی	\N	holiday	2026-07-16 00:00:00+00	2026-07-16 01:00:00+00	t	\N
a52a8d60-2a5c-4359-a17c-948e6d1daef3	2026-07-21 18:35:18.932907+00	2026-07-21 18:35:18.932907+00	efb263c4-05b2-42d2-bc77-af9f0cbd846e	5015f0ba-e578-4955-b532-c78d5f462686	\N	\N	تعطیلی رسمی	\N	holiday	2026-08-13 00:00:00+00	2026-08-13 01:00:00+00	t	\N
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
3a7b7038-9dad-42cc-b92d-814cef3201f8	2026-07-21 18:35:18.932907+00	2026-07-21 18:35:18.932907+00	efb263c4-05b2-42d2-bc77-af9f0cbd846e	c0c1258a-257b-4a56-bc50-4efdde442732	0a2e6fe5-66bd-43c4-aeda-995263e906bf	project_manager
2d34b376-609c-484e-973e-e332762b4728	2026-07-21 18:35:18.932907+00	2026-07-21 18:35:18.932907+00	efb263c4-05b2-42d2-bc77-af9f0cbd846e	caaef6d7-fee2-48a7-bd4b-3697a88773ea	0a2e6fe5-66bd-43c4-aeda-995263e906bf	employee
7c09f842-1e07-4d98-b327-f990124f2ff9	2026-07-21 18:35:18.932907+00	2026-07-21 18:35:18.932907+00	efb263c4-05b2-42d2-bc77-af9f0cbd846e	14420cd5-d1bc-4e91-8063-b90ed9c1d745	0a2e6fe5-66bd-43c4-aeda-995263e906bf	employee
8864aada-c327-4ed2-b773-841251fb9b84	2026-07-21 18:35:18.932907+00	2026-07-21 18:35:18.932907+00	efb263c4-05b2-42d2-bc77-af9f0cbd846e	2505504d-a7d6-4a58-975c-bed21d1319bd	0a2e6fe5-66bd-43c4-aeda-995263e906bf	employee
da56eb74-44b9-4c1e-873a-a6812751efe2	2026-07-21 18:35:18.932907+00	2026-07-21 18:35:18.932907+00	efb263c4-05b2-42d2-bc77-af9f0cbd846e	2a912655-64c4-44a5-9beb-6093704c47bd	0a2e6fe5-66bd-43c4-aeda-995263e906bf	employee
6d5640c5-9e29-48aa-8089-34e70a43accd	2026-07-21 18:35:18.932907+00	2026-07-21 18:35:18.932907+00	efb263c4-05b2-42d2-bc77-af9f0cbd846e	4cef53c1-898c-4945-b51b-a1d36322bb51	0a2e6fe5-66bd-43c4-aeda-995263e906bf	employee
c6c68eec-e6dd-4d02-b989-aec55d273779	2026-07-21 18:35:18.932907+00	2026-07-21 18:35:18.932907+00	efb263c4-05b2-42d2-bc77-af9f0cbd846e	1bc00cf9-0b6c-453b-8f81-55a9f72ad244	0a2e6fe5-66bd-43c4-aeda-995263e906bf	employee
cadaa208-9baf-428d-a199-4fc98f8a11f3	2026-07-21 18:35:18.932907+00	2026-07-21 18:35:18.932907+00	efb263c4-05b2-42d2-bc77-af9f0cbd846e	e262d280-b97e-4087-8e78-a66519bae4d1	55d14f8b-02b1-4ecf-8561-574e34605a92	project_manager
6bbf0ce2-325c-4648-8553-ddebbb923625	2026-07-21 18:35:18.932907+00	2026-07-21 18:35:18.932907+00	efb263c4-05b2-42d2-bc77-af9f0cbd846e	7dcd0e37-2d6c-4eab-8a6a-3598c4e01433	55d14f8b-02b1-4ecf-8561-574e34605a92	employee
71886290-5c8b-46b5-b5a0-b151c1d4a2ed	2026-07-21 18:35:18.932907+00	2026-07-21 18:35:18.932907+00	efb263c4-05b2-42d2-bc77-af9f0cbd846e	e73ec14e-ca0c-4615-92d5-5bc43c14999a	55d14f8b-02b1-4ecf-8561-574e34605a92	employee
0e881056-2a94-46a2-aad2-0f2bcfb2343f	2026-07-21 18:35:18.932907+00	2026-07-21 18:35:18.932907+00	efb263c4-05b2-42d2-bc77-af9f0cbd846e	c288bac5-e3a4-4f1f-a050-de12845acf11	55d14f8b-02b1-4ecf-8561-574e34605a92	employee
5c7756e0-44e6-4857-ad92-b72431fef13d	2026-07-21 18:35:18.932907+00	2026-07-21 18:35:18.932907+00	efb263c4-05b2-42d2-bc77-af9f0cbd846e	1d9f738d-866c-4e32-9fe8-b80f0b30a62b	55d14f8b-02b1-4ecf-8561-574e34605a92	employee
8a828ead-753d-42f6-9faf-01601cd091bb	2026-07-21 18:35:18.932907+00	2026-07-21 18:35:18.932907+00	efb263c4-05b2-42d2-bc77-af9f0cbd846e	1c37102f-d8b4-4bea-bd82-5b862cd46e2b	55d14f8b-02b1-4ecf-8561-574e34605a92	employee
09c5bee8-64a8-45bb-887a-cbcc565af24b	2026-07-21 18:35:18.932907+00	2026-07-21 18:35:18.932907+00	efb263c4-05b2-42d2-bc77-af9f0cbd846e	faf489ef-0410-4dca-bec1-65dd2fb904ba	55d14f8b-02b1-4ecf-8561-574e34605a92	employee
0dcc9f81-ca6f-459a-863a-50c60f55170c	2026-07-21 18:35:18.932907+00	2026-07-21 18:35:18.932907+00	efb263c4-05b2-42d2-bc77-af9f0cbd846e	89f48814-745b-462e-820c-aff4124c3949	206f67b3-5950-4801-bb4f-194bcf765fdc	project_manager
4278a76f-3390-49be-bf4d-a05a84bd6080	2026-07-21 18:35:18.932907+00	2026-07-21 18:35:18.932907+00	efb263c4-05b2-42d2-bc77-af9f0cbd846e	63d308ce-8593-4f45-8c4b-1df63a00732c	206f67b3-5950-4801-bb4f-194bcf765fdc	employee
1e80c488-07da-4b07-901f-0e2df9bbbffc	2026-07-21 18:35:18.932907+00	2026-07-21 18:35:18.932907+00	efb263c4-05b2-42d2-bc77-af9f0cbd846e	d9facd7e-b4bd-497f-9f4f-f75e6a932da0	206f67b3-5950-4801-bb4f-194bcf765fdc	employee
a0d030dd-794b-4b8d-b5f6-92c2bf1c0377	2026-07-21 18:35:18.932907+00	2026-07-21 18:35:18.932907+00	efb263c4-05b2-42d2-bc77-af9f0cbd846e	eb0b5b71-65c1-4694-a9d0-5b2b7aea8eae	206f67b3-5950-4801-bb4f-194bcf765fdc	employee
52615cf0-1e70-432e-9060-724c3943c3cb	2026-07-21 18:35:18.932907+00	2026-07-21 18:35:18.932907+00	efb263c4-05b2-42d2-bc77-af9f0cbd846e	3d944638-fc96-463d-84ac-c7c861324cbe	206f67b3-5950-4801-bb4f-194bcf765fdc	employee
dc3aed98-d449-41dd-9d15-5142b329b81c	2026-07-21 18:35:18.932907+00	2026-07-21 18:35:18.932907+00	efb263c4-05b2-42d2-bc77-af9f0cbd846e	e38a8fbd-4c9d-4475-ae1b-150a034a6936	206f67b3-5950-4801-bb4f-194bcf765fdc	employee
5319c230-0964-4dc0-8f7e-7f1c06a5fa81	2026-07-21 18:35:18.932907+00	2026-07-21 18:35:18.932907+00	efb263c4-05b2-42d2-bc77-af9f0cbd846e	4bfc028f-1c19-4b0c-9188-9fe233b49cb4	206f67b3-5950-4801-bb4f-194bcf765fdc	employee
b0c2dec2-3941-4a31-9235-679622787496	2026-07-21 18:35:18.932907+00	2026-07-21 18:35:18.932907+00	efb263c4-05b2-42d2-bc77-af9f0cbd846e	89f48814-745b-462e-820c-aff4124c3949	0a2e6fe5-66bd-43c4-aeda-995263e906bf	employee
69817311-dae0-4b69-9b18-b6d9ed6ed120	2026-07-21 18:35:18.932907+00	2026-07-21 18:35:18.932907+00	efb263c4-05b2-42d2-bc77-af9f0cbd846e	caaef6d7-fee2-48a7-bd4b-3697a88773ea	55d14f8b-02b1-4ecf-8561-574e34605a92	employee
\.


--
-- Data for Name: departments; Type: TABLE DATA; Schema: public; Owner: -
--

COPY public.departments (id, created_at, updated_at, organization_id, name) FROM stdin;
0a2e6fe5-66bd-43c4-aeda-995263e906bf	2026-07-21 18:35:18.932907+00	2026-07-21 18:35:18.932907+00	efb263c4-05b2-42d2-bc77-af9f0cbd846e	مهندسی و فنی
55d14f8b-02b1-4ecf-8561-574e34605a92	2026-07-21 18:35:18.932907+00	2026-07-21 18:35:18.932907+00	efb263c4-05b2-42d2-bc77-af9f0cbd846e	حسابداری و مالی
206f67b3-5950-4801-bb4f-194bcf765fdc	2026-07-21 18:35:18.932907+00	2026-07-21 18:35:18.932907+00	efb263c4-05b2-42d2-bc77-af9f0cbd846e	منابع انسانی
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
شرکت نمونهٔ آزمایشی	demo-org-f654aba3	t	efb263c4-05b2-42d2-bc77-af9f0cbd846e	2026-07-21 18:35:18.932907+00	2026-07-21 18:35:18.932907+00
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
a256424e-8cd7-4ffb-b83d-74e08a248892	c0c1258a-257b-4a56-bc50-4efdde442732	649cbd29-13fc-4c43-86a0-09dfa92386da	2026-07-21 18:35:18.932907+00	2026-07-21 18:35:18.932907+00
a256424e-8cd7-4ffb-b83d-74e08a248892	1bc00cf9-0b6c-453b-8f81-55a9f72ad244	a38ceb44-a461-4d12-ad29-c8dee7e5e4df	2026-07-21 18:35:18.932907+00	2026-07-21 18:35:18.932907+00
a256424e-8cd7-4ffb-b83d-74e08a248892	caaef6d7-fee2-48a7-bd4b-3697a88773ea	2107b372-ee46-4f71-a5c2-a7502f9c636d	2026-07-21 18:35:18.932907+00	2026-07-21 18:35:18.932907+00
a256424e-8cd7-4ffb-b83d-74e08a248892	4cef53c1-898c-4945-b51b-a1d36322bb51	0be375d1-4887-4907-b5cb-b8997bdb9154	2026-07-21 18:35:18.932907+00	2026-07-21 18:35:18.932907+00
c6d8abca-4a0d-480d-85f7-d34d1d133855	c0c1258a-257b-4a56-bc50-4efdde442732	ff277cb9-7cef-4387-926f-6545c9bb69a3	2026-07-21 18:35:18.932907+00	2026-07-21 18:35:18.932907+00
c6d8abca-4a0d-480d-85f7-d34d1d133855	14420cd5-d1bc-4e91-8063-b90ed9c1d745	bbf05e41-c9bb-4318-bb3e-33d21ad3722b	2026-07-21 18:35:18.932907+00	2026-07-21 18:35:18.932907+00
c6d8abca-4a0d-480d-85f7-d34d1d133855	1bc00cf9-0b6c-453b-8f81-55a9f72ad244	081549b8-f693-45b9-b739-b74736d8cf5f	2026-07-21 18:35:18.932907+00	2026-07-21 18:35:18.932907+00
c6d8abca-4a0d-480d-85f7-d34d1d133855	caaef6d7-fee2-48a7-bd4b-3697a88773ea	5f20fba7-100e-40a4-bc34-ca058c0a16f2	2026-07-21 18:35:18.932907+00	2026-07-21 18:35:18.932907+00
e79efaad-56e0-4883-adb3-699fa5b5b4e1	c0c1258a-257b-4a56-bc50-4efdde442732	7f30001e-f3fa-469b-a2f7-9d97c1cacb14	2026-07-21 18:35:18.932907+00	2026-07-21 18:35:18.932907+00
e79efaad-56e0-4883-adb3-699fa5b5b4e1	4cef53c1-898c-4945-b51b-a1d36322bb51	97cbd609-18e2-429d-8690-52895d5d3c3b	2026-07-21 18:35:18.932907+00	2026-07-21 18:35:18.932907+00
e79efaad-56e0-4883-adb3-699fa5b5b4e1	2a912655-64c4-44a5-9beb-6093704c47bd	b050cdde-8a6c-4aa0-a263-76672f517dcd	2026-07-21 18:35:18.932907+00	2026-07-21 18:35:18.932907+00
e79efaad-56e0-4883-adb3-699fa5b5b4e1	caaef6d7-fee2-48a7-bd4b-3697a88773ea	0c3b7607-aca3-4690-a9d1-68dd8a5c45cd	2026-07-21 18:35:18.932907+00	2026-07-21 18:35:18.932907+00
d2117d77-f066-4ab6-9678-e32a36d45c1a	c0c1258a-257b-4a56-bc50-4efdde442732	65d72c6d-4f89-4a91-a13d-4ce9845ce6c5	2026-07-21 18:35:18.932907+00	2026-07-21 18:35:18.932907+00
d2117d77-f066-4ab6-9678-e32a36d45c1a	14420cd5-d1bc-4e91-8063-b90ed9c1d745	9cba0915-9e21-4cfb-baf3-d69b844d9051	2026-07-21 18:35:18.932907+00	2026-07-21 18:35:18.932907+00
d2117d77-f066-4ab6-9678-e32a36d45c1a	1bc00cf9-0b6c-453b-8f81-55a9f72ad244	407ecf2d-d4a6-42b4-a6dd-5a2a11d7380e	2026-07-21 18:35:18.932907+00	2026-07-21 18:35:18.932907+00
d2117d77-f066-4ab6-9678-e32a36d45c1a	caaef6d7-fee2-48a7-bd4b-3697a88773ea	068afa60-d73f-4097-a235-9658195559d5	2026-07-21 18:35:18.932907+00	2026-07-21 18:35:18.932907+00
654a21fd-66c7-412b-9936-bb14abeb65b1	c0c1258a-257b-4a56-bc50-4efdde442732	4fdd1352-8acd-46a8-a699-1ea53df1f992	2026-07-21 18:35:18.932907+00	2026-07-21 18:35:18.932907+00
654a21fd-66c7-412b-9936-bb14abeb65b1	1bc00cf9-0b6c-453b-8f81-55a9f72ad244	45ee4ce1-714f-4c3a-997f-d8aa130ac25c	2026-07-21 18:35:18.932907+00	2026-07-21 18:35:18.932907+00
654a21fd-66c7-412b-9936-bb14abeb65b1	4cef53c1-898c-4945-b51b-a1d36322bb51	a4ae5385-24fa-4803-b03d-563134c2ad07	2026-07-21 18:35:18.932907+00	2026-07-21 18:35:18.932907+00
654a21fd-66c7-412b-9936-bb14abeb65b1	2a912655-64c4-44a5-9beb-6093704c47bd	deac008d-c3ba-4bad-8a81-fa6298d6bbc2	2026-07-21 18:35:18.932907+00	2026-07-21 18:35:18.932907+00
e35b32f7-7e12-42fe-912f-f80b60c4ace4	e262d280-b97e-4087-8e78-a66519bae4d1	38b25b7c-3ed1-4276-872d-cdb0a4a1dbd4	2026-07-21 18:35:18.932907+00	2026-07-21 18:35:18.932907+00
e35b32f7-7e12-42fe-912f-f80b60c4ace4	7dcd0e37-2d6c-4eab-8a6a-3598c4e01433	7c4f2ef5-2fd5-41d1-ab5e-d96e756a44a9	2026-07-21 18:35:18.932907+00	2026-07-21 18:35:18.932907+00
e35b32f7-7e12-42fe-912f-f80b60c4ace4	e73ec14e-ca0c-4615-92d5-5bc43c14999a	d93e428e-0c02-42d2-a881-260bb507f5fb	2026-07-21 18:35:18.932907+00	2026-07-21 18:35:18.932907+00
e35b32f7-7e12-42fe-912f-f80b60c4ace4	c288bac5-e3a4-4f1f-a050-de12845acf11	eae367a4-894c-4cbf-85d6-6dd8119f7f45	2026-07-21 18:35:18.932907+00	2026-07-21 18:35:18.932907+00
6b87fbf4-f215-4875-9b6d-ba65c7cae7e2	e262d280-b97e-4087-8e78-a66519bae4d1	12f12dfe-6176-418b-9d39-b3f020b13877	2026-07-21 18:35:18.932907+00	2026-07-21 18:35:18.932907+00
6b87fbf4-f215-4875-9b6d-ba65c7cae7e2	7dcd0e37-2d6c-4eab-8a6a-3598c4e01433	b23af74a-3aa8-4cd0-a99e-68ab301612d8	2026-07-21 18:35:18.932907+00	2026-07-21 18:35:18.932907+00
6b87fbf4-f215-4875-9b6d-ba65c7cae7e2	c288bac5-e3a4-4f1f-a050-de12845acf11	15ae5f80-11b3-41dd-a6d8-b18a64e1c27f	2026-07-21 18:35:18.932907+00	2026-07-21 18:35:18.932907+00
6b87fbf4-f215-4875-9b6d-ba65c7cae7e2	1c37102f-d8b4-4bea-bd82-5b862cd46e2b	60b04582-2ed3-4633-83af-01016d317033	2026-07-21 18:35:18.932907+00	2026-07-21 18:35:18.932907+00
009a2a44-5f53-4b44-a083-b37afdcd5b4d	e262d280-b97e-4087-8e78-a66519bae4d1	7bdce85f-54f1-4aad-9b51-6b0f63bcb97b	2026-07-21 18:35:18.932907+00	2026-07-21 18:35:18.932907+00
009a2a44-5f53-4b44-a083-b37afdcd5b4d	c288bac5-e3a4-4f1f-a050-de12845acf11	f04aac13-3bfe-4c05-b25f-25a2cd2d976a	2026-07-21 18:35:18.932907+00	2026-07-21 18:35:18.932907+00
009a2a44-5f53-4b44-a083-b37afdcd5b4d	1d9f738d-866c-4e32-9fe8-b80f0b30a62b	9422773b-2b89-444c-969a-7cb21dc14553	2026-07-21 18:35:18.932907+00	2026-07-21 18:35:18.932907+00
009a2a44-5f53-4b44-a083-b37afdcd5b4d	1c37102f-d8b4-4bea-bd82-5b862cd46e2b	a3189d45-1899-43f3-9447-e1eb9fd74f48	2026-07-21 18:35:18.932907+00	2026-07-21 18:35:18.932907+00
e2872a09-ca5b-4560-b31c-9639fc42eeb2	e262d280-b97e-4087-8e78-a66519bae4d1	67f19a0d-6b42-4569-932c-c733e3a551d2	2026-07-21 18:35:18.932907+00	2026-07-21 18:35:18.932907+00
e2872a09-ca5b-4560-b31c-9639fc42eeb2	c288bac5-e3a4-4f1f-a050-de12845acf11	46892a18-bb3f-42d6-8f01-c67844472ca1	2026-07-21 18:35:18.932907+00	2026-07-21 18:35:18.932907+00
e2872a09-ca5b-4560-b31c-9639fc42eeb2	e73ec14e-ca0c-4615-92d5-5bc43c14999a	f1d56295-4ab0-4491-b600-374b26620fa5	2026-07-21 18:35:18.932907+00	2026-07-21 18:35:18.932907+00
e2872a09-ca5b-4560-b31c-9639fc42eeb2	1d9f738d-866c-4e32-9fe8-b80f0b30a62b	8bb10a37-5105-4c42-a1e2-040d84fafd2f	2026-07-21 18:35:18.932907+00	2026-07-21 18:35:18.932907+00
53b4a7c0-5ff9-4b29-a337-82321def0955	e262d280-b97e-4087-8e78-a66519bae4d1	f513db65-1bbb-46e5-b2b7-9311970c7b5a	2026-07-21 18:35:18.932907+00	2026-07-21 18:35:18.932907+00
53b4a7c0-5ff9-4b29-a337-82321def0955	1c37102f-d8b4-4bea-bd82-5b862cd46e2b	d8b7dd12-263e-4017-b564-7a0b19bdf154	2026-07-21 18:35:18.932907+00	2026-07-21 18:35:18.932907+00
53b4a7c0-5ff9-4b29-a337-82321def0955	c288bac5-e3a4-4f1f-a050-de12845acf11	bedc7d95-8da3-4134-b018-a53b70b89c9b	2026-07-21 18:35:18.932907+00	2026-07-21 18:35:18.932907+00
53b4a7c0-5ff9-4b29-a337-82321def0955	7dcd0e37-2d6c-4eab-8a6a-3598c4e01433	29b00965-de0a-4053-83ba-c8c7b0c086dc	2026-07-21 18:35:18.932907+00	2026-07-21 18:35:18.932907+00
4554595d-9245-40e3-b08c-d872099d1fc1	89f48814-745b-462e-820c-aff4124c3949	d2f5b8a4-6db7-4872-9e87-710fb0c6df9c	2026-07-21 18:35:18.932907+00	2026-07-21 18:35:18.932907+00
4554595d-9245-40e3-b08c-d872099d1fc1	e38a8fbd-4c9d-4475-ae1b-150a034a6936	29634383-367d-4ae1-a474-c48f2eeef098	2026-07-21 18:35:18.932907+00	2026-07-21 18:35:18.932907+00
4554595d-9245-40e3-b08c-d872099d1fc1	d9facd7e-b4bd-497f-9f4f-f75e6a932da0	03741248-6f80-4ad3-ad98-06872b71c8e5	2026-07-21 18:35:18.932907+00	2026-07-21 18:35:18.932907+00
4554595d-9245-40e3-b08c-d872099d1fc1	4bfc028f-1c19-4b0c-9188-9fe233b49cb4	44218057-b9ac-4527-a4f3-f5345bbdc1cd	2026-07-21 18:35:18.932907+00	2026-07-21 18:35:18.932907+00
65f2eec9-9404-43e1-bfd6-2f22321a8701	89f48814-745b-462e-820c-aff4124c3949	d05c63ee-ac5a-4ead-a5f8-9139071c6e03	2026-07-21 18:35:18.932907+00	2026-07-21 18:35:18.932907+00
65f2eec9-9404-43e1-bfd6-2f22321a8701	eb0b5b71-65c1-4694-a9d0-5b2b7aea8eae	2613f3af-9418-4238-93d6-2b3d0412c612	2026-07-21 18:35:18.932907+00	2026-07-21 18:35:18.932907+00
65f2eec9-9404-43e1-bfd6-2f22321a8701	d9facd7e-b4bd-497f-9f4f-f75e6a932da0	3232a796-2174-42fc-9367-b617970ae44b	2026-07-21 18:35:18.932907+00	2026-07-21 18:35:18.932907+00
65f2eec9-9404-43e1-bfd6-2f22321a8701	3d944638-fc96-463d-84ac-c7c861324cbe	876748f2-4684-46b6-a57f-716d1382521d	2026-07-21 18:35:18.932907+00	2026-07-21 18:35:18.932907+00
f3b6db39-3c7b-41fa-bfa4-b7ae409a154a	89f48814-745b-462e-820c-aff4124c3949	0ba3e847-9602-4f48-be35-a8646884191a	2026-07-21 18:35:18.932907+00	2026-07-21 18:35:18.932907+00
f3b6db39-3c7b-41fa-bfa4-b7ae409a154a	63d308ce-8593-4f45-8c4b-1df63a00732c	ef7f9bd4-4172-4dff-a483-0ddf65906d6e	2026-07-21 18:35:18.932907+00	2026-07-21 18:35:18.932907+00
f3b6db39-3c7b-41fa-bfa4-b7ae409a154a	d9facd7e-b4bd-497f-9f4f-f75e6a932da0	482e3269-3003-46b1-8f9f-f0d7b072a42b	2026-07-21 18:35:18.932907+00	2026-07-21 18:35:18.932907+00
f3b6db39-3c7b-41fa-bfa4-b7ae409a154a	e38a8fbd-4c9d-4475-ae1b-150a034a6936	9fa8ef35-a82b-4c3b-ae4d-83e6dc2228be	2026-07-21 18:35:18.932907+00	2026-07-21 18:35:18.932907+00
af916260-f69c-4181-a986-3df8a4df7239	89f48814-745b-462e-820c-aff4124c3949	fd0d68cc-bceb-40b2-ac9b-c25370cf128d	2026-07-21 18:35:18.932907+00	2026-07-21 18:35:18.932907+00
af916260-f69c-4181-a986-3df8a4df7239	3d944638-fc96-463d-84ac-c7c861324cbe	fc238dd1-698a-424c-ad72-d477420bb98f	2026-07-21 18:35:18.932907+00	2026-07-21 18:35:18.932907+00
af916260-f69c-4181-a986-3df8a4df7239	63d308ce-8593-4f45-8c4b-1df63a00732c	879242e4-2202-42a2-996e-b5f494ac6d63	2026-07-21 18:35:18.932907+00	2026-07-21 18:35:18.932907+00
af916260-f69c-4181-a986-3df8a4df7239	eb0b5b71-65c1-4694-a9d0-5b2b7aea8eae	2ba9f746-e010-4fd9-8da4-129454f43a6d	2026-07-21 18:35:18.932907+00	2026-07-21 18:35:18.932907+00
7f7c651b-87ea-4b3a-8b88-3bec205cfc31	89f48814-745b-462e-820c-aff4124c3949	4083a0d3-5ca3-49ae-8bd0-e2b84b39202f	2026-07-21 18:35:18.932907+00	2026-07-21 18:35:18.932907+00
7f7c651b-87ea-4b3a-8b88-3bec205cfc31	d9facd7e-b4bd-497f-9f4f-f75e6a932da0	d62f02c7-f84b-4cb7-a6f3-33c4ea41a257	2026-07-21 18:35:18.932907+00	2026-07-21 18:35:18.932907+00
7f7c651b-87ea-4b3a-8b88-3bec205cfc31	eb0b5b71-65c1-4694-a9d0-5b2b7aea8eae	105fcf46-61db-4cd9-b8d3-82ae449ff309	2026-07-21 18:35:18.932907+00	2026-07-21 18:35:18.932907+00
7f7c651b-87ea-4b3a-8b88-3bec205cfc31	4bfc028f-1c19-4b0c-9188-9fe233b49cb4	78974395-52dd-4560-996e-72773351dfe9	2026-07-21 18:35:18.932907+00	2026-07-21 18:35:18.932907+00
\.


--
-- Data for Name: projects; Type: TABLE DATA; Schema: public; Owner: -
--

COPY public.projects (organization_id, name, description, start_date, end_date, status, created_by_id, id, created_at, updated_at, manager_id, department_id) FROM stdin;
efb263c4-05b2-42d2-bc77-af9f0cbd846e	بازطراحی وب‌سایت شرکتی	پروژهٔ مهندسی و فنی شماره 1	2026-06-01	2026-08-16	active	5015f0ba-e578-4955-b532-c78d5f462686	a256424e-8cd7-4ffb-b83d-74e08a248892	2026-07-21 18:35:18.932907+00	2026-07-21 18:35:18.932907+00	c0c1258a-257b-4a56-bc50-4efdde442732	0a2e6fe5-66bd-43c4-aeda-995263e906bf
efb263c4-05b2-42d2-bc77-af9f0cbd846e	توسعهٔ اپلیکیشن موبایل فروش	پروژهٔ مهندسی و فنی شماره 2	2026-04-28	2026-06-23	active	5015f0ba-e578-4955-b532-c78d5f462686	c6d8abca-4a0d-480d-85f7-d34d1d133855	2026-07-21 18:35:18.932907+00	2026-07-21 18:35:18.932907+00	c0c1258a-257b-4a56-bc50-4efdde442732	0a2e6fe5-66bd-43c4-aeda-995263e906bf
efb263c4-05b2-42d2-bc77-af9f0cbd846e	مهاجرت زیرساخت به ابر	پروژهٔ مهندسی و فنی شماره 3	2026-07-03	2026-08-28	active	5015f0ba-e578-4955-b532-c78d5f462686	e79efaad-56e0-4883-adb3-699fa5b5b4e1	2026-07-21 18:35:18.932907+00	2026-07-21 18:35:18.932907+00	c0c1258a-257b-4a56-bc50-4efdde442732	0a2e6fe5-66bd-43c4-aeda-995263e906bf
efb263c4-05b2-42d2-bc77-af9f0cbd846e	پیاده‌سازی سامانهٔ مانیتورینگ	پروژهٔ مهندسی و فنی شماره 4	2026-04-26	2026-07-05	active	5015f0ba-e578-4955-b532-c78d5f462686	d2117d77-f066-4ab6-9678-e32a36d45c1a	2026-07-21 18:35:18.932907+00	2026-07-21 18:35:18.932907+00	c0c1258a-257b-4a56-bc50-4efdde442732	0a2e6fe5-66bd-43c4-aeda-995263e906bf
efb263c4-05b2-42d2-bc77-af9f0cbd846e	بهبود عملکرد پایگاه‌داده	پروژهٔ مهندسی و فنی شماره 5	2026-06-08	2026-09-18	active	5015f0ba-e578-4955-b532-c78d5f462686	654a21fd-66c7-412b-9936-bb14abeb65b1	2026-07-21 18:35:18.932907+00	2026-07-21 18:35:18.932907+00	c0c1258a-257b-4a56-bc50-4efdde442732	0a2e6fe5-66bd-43c4-aeda-995263e906bf
efb263c4-05b2-42d2-bc77-af9f0cbd846e	بستن حساب‌های مالی سال	پروژهٔ حسابداری و مالی شماره 1	2026-05-22	2026-10-13	active	5015f0ba-e578-4955-b532-c78d5f462686	e35b32f7-7e12-42fe-912f-f80b60c4ace4	2026-07-21 18:35:18.932907+00	2026-07-21 18:35:18.932907+00	e262d280-b97e-4087-8e78-a66519bae4d1	55d14f8b-02b1-4ecf-8561-574e34605a92
efb263c4-05b2-42d2-bc77-af9f0cbd846e	پیاده‌سازی سامانهٔ فاکتور الکترونیک	پروژهٔ حسابداری و مالی شماره 2	2026-06-21	2026-11-15	active	5015f0ba-e578-4955-b532-c78d5f462686	6b87fbf4-f215-4875-9b6d-ba65c7cae7e2	2026-07-21 18:35:18.932907+00	2026-07-21 18:35:18.932907+00	e262d280-b97e-4087-8e78-a66519bae4d1	55d14f8b-02b1-4ecf-8561-574e34605a92
efb263c4-05b2-42d2-bc77-af9f0cbd846e	ممیزی مالی سه‌ماههٔ دوم	پروژهٔ حسابداری و مالی شماره 3	2026-05-11	2026-08-13	active	5015f0ba-e578-4955-b532-c78d5f462686	009a2a44-5f53-4b44-a083-b37afdcd5b4d	2026-07-21 18:35:18.932907+00	2026-07-21 18:35:18.932907+00	e262d280-b97e-4087-8e78-a66519bae4d1	55d14f8b-02b1-4ecf-8561-574e34605a92
efb263c4-05b2-42d2-bc77-af9f0cbd846e	تدوین بودجهٔ سال آینده	پروژهٔ حسابداری و مالی شماره 4	2026-05-04	2026-08-04	active	5015f0ba-e578-4955-b532-c78d5f462686	e2872a09-ca5b-4560-b31c-9639fc42eeb2	2026-07-21 18:35:18.932907+00	2026-07-21 18:35:18.932907+00	e262d280-b97e-4087-8e78-a66519bae4d1	55d14f8b-02b1-4ecf-8561-574e34605a92
efb263c4-05b2-42d2-bc77-af9f0cbd846e	مدیریت مطالبات و بدهی‌ها	پروژهٔ حسابداری و مالی شماره 5	2026-05-13	2026-07-07	active	5015f0ba-e578-4955-b532-c78d5f462686	53b4a7c0-5ff9-4b29-a337-82321def0955	2026-07-21 18:35:18.932907+00	2026-07-21 18:35:18.932907+00	e262d280-b97e-4087-8e78-a66519bae4d1	55d14f8b-02b1-4ecf-8561-574e34605a92
efb263c4-05b2-42d2-bc77-af9f0cbd846e	برگزاری دورهٔ آموزشی کارکنان	پروژهٔ منابع انسانی شماره 1	2026-05-04	2026-08-26	active	5015f0ba-e578-4955-b532-c78d5f462686	4554595d-9245-40e3-b08c-d872099d1fc1	2026-07-21 18:35:18.932907+00	2026-07-21 18:35:18.932907+00	89f48814-745b-462e-820c-aff4124c3949	206f67b3-5950-4801-bb4f-194bcf765fdc
efb263c4-05b2-42d2-bc77-af9f0cbd846e	بازطراحی فرایند جذب و استخدام	پروژهٔ منابع انسانی شماره 2	2026-07-02	2026-08-27	active	5015f0ba-e578-4955-b532-c78d5f462686	65f2eec9-9404-43e1-bfd6-2f22321a8701	2026-07-21 18:35:18.932907+00	2026-07-21 18:35:18.932907+00	89f48814-745b-462e-820c-aff4124c3949	206f67b3-5950-4801-bb4f-194bcf765fdc
efb263c4-05b2-42d2-bc77-af9f0cbd846e	ارزیابی عملکرد سالانهٔ کارکنان	پروژهٔ منابع انسانی شماره 3	2026-07-04	2026-10-24	active	5015f0ba-e578-4955-b532-c78d5f462686	f3b6db39-3c7b-41fa-bfa4-b7ae409a154a	2026-07-21 18:35:18.932907+00	2026-07-21 18:35:18.932907+00	89f48814-745b-462e-820c-aff4124c3949	206f67b3-5950-4801-bb4f-194bcf765fdc
efb263c4-05b2-42d2-bc77-af9f0cbd846e	طراحی برنامهٔ رفاهی کارکنان	پروژهٔ منابع انسانی شماره 4	2026-04-19	2026-06-28	active	5015f0ba-e578-4955-b532-c78d5f462686	af916260-f69c-4181-a986-3df8a4df7239	2026-07-21 18:35:18.932907+00	2026-07-21 18:35:18.932907+00	89f48814-745b-462e-820c-aff4124c3949	206f67b3-5950-4801-bb4f-194bcf765fdc
efb263c4-05b2-42d2-bc77-af9f0cbd846e	پیاده‌سازی سامانهٔ حضور و غیاب	پروژهٔ منابع انسانی شماره 5	2026-05-26	2026-07-17	active	5015f0ba-e578-4955-b532-c78d5f462686	7f7c651b-87ea-4b3a-8b88-3bec205cfc31	2026-07-21 18:35:18.932907+00	2026-07-21 18:35:18.932907+00	89f48814-745b-462e-820c-aff4124c3949	206f67b3-5950-4801-bb4f-194bcf765fdc
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
efb263c4-05b2-42d2-bc77-af9f0cbd846e	a256424e-8cd7-4ffb-b83d-74e08a248892	\N	2a912655-64c4-44a5-9beb-6093704c47bd	c0c1258a-257b-4a56-bc50-4efdde442732	رفع مشکل ناسازگاری مرورگر #1	\N	low	2026-08-08	3344b271-a7a4-426c-9d85-1c3406530ce8	2026-07-21 18:35:18.932907+00	2026-07-21 18:35:18.932907+00	in_progress	\N	54	14.90	2026-08-06	medium
efb263c4-05b2-42d2-bc77-af9f0cbd846e	a256424e-8cd7-4ffb-b83d-74e08a248892	\N	caaef6d7-fee2-48a7-bd4b-3697a88773ea	c0c1258a-257b-4a56-bc50-4efdde442732	پیاده‌سازی صفحهٔ ورود جدید #2	\N	low	2026-08-15	efe378eb-0255-4614-9018-f550a6109b77	2026-07-21 18:35:18.932907+00	2026-07-21 18:35:18.932907+00	in_progress	\N	48	5.70	2026-08-03	medium
efb263c4-05b2-42d2-bc77-af9f0cbd846e	a256424e-8cd7-4ffb-b83d-74e08a248892	\N	1bc00cf9-0b6c-453b-8f81-55a9f72ad244	c0c1258a-257b-4a56-bc50-4efdde442732	رفع مشکل ناسازگاری مرورگر #3	\N	low	2026-08-03	d6029d28-fbd1-4a66-9931-22fce6ddc7a6	2026-07-21 18:35:18.932907+00	2026-07-21 18:35:18.932907+00	in_progress	\N	58	22.40	2026-07-24	medium
efb263c4-05b2-42d2-bc77-af9f0cbd846e	a256424e-8cd7-4ffb-b83d-74e08a248892	\N	2505504d-a7d6-4a58-975c-bed21d1319bd	c0c1258a-257b-4a56-bc50-4efdde442732	بازنویسی ماژول اعلان‌ها #4	\N	high	2026-08-01	80b30c77-94ee-4827-986a-ca0b85c92133	2026-07-21 18:35:18.932907+00	2026-07-21 18:35:18.932907+00	todo	\N	79	35.60	2026-07-21	medium
efb263c4-05b2-42d2-bc77-af9f0cbd846e	a256424e-8cd7-4ffb-b83d-74e08a248892	\N	14420cd5-d1bc-4e91-8063-b90ed9c1d745	c0c1258a-257b-4a56-bc50-4efdde442732	تنظیم پایپ‌لاین CI/CD #5	\N	low	2026-06-23	bf0c6407-bb76-4975-b590-3ad017813129	2026-07-21 18:35:18.932907+00	2026-07-21 18:35:18.932907+00	completed	approved	100	31.40	2026-06-20	medium
efb263c4-05b2-42d2-bc77-af9f0cbd846e	a256424e-8cd7-4ffb-b83d-74e08a248892	\N	c0c1258a-257b-4a56-bc50-4efdde442732	c0c1258a-257b-4a56-bc50-4efdde442732	پیاده‌سازی احراز هویت دومرحله‌ای #6	\N	medium	2026-08-15	9298c330-ac91-4c64-8125-7cf3a6cf2ae8	2026-07-21 18:35:18.932907+00	2026-07-21 18:35:18.932907+00	in_progress	\N	58	26.20	2026-08-10	medium
efb263c4-05b2-42d2-bc77-af9f0cbd846e	a256424e-8cd7-4ffb-b83d-74e08a248892	\N	14420cd5-d1bc-4e91-8063-b90ed9c1d745	c0c1258a-257b-4a56-bc50-4efdde442732	افزودن تست واحد برای سرویس کاربران #7	\N	high	2026-07-22	85ff395e-b667-4e16-8f43-dafbadb88552	2026-07-21 18:35:18.932907+00	2026-07-21 18:35:18.932907+00	todo	\N	34	28.70	2026-07-09	medium
efb263c4-05b2-42d2-bc77-af9f0cbd846e	a256424e-8cd7-4ffb-b83d-74e08a248892	\N	4cef53c1-898c-4945-b51b-a1d36322bb51	c0c1258a-257b-4a56-bc50-4efdde442732	به‌روزرسانی کتابخانه‌های وابسته #8	\N	high	2026-08-02	66681e8b-5a94-48c4-8c1d-55304a7e72e8	2026-07-21 18:35:18.932907+00	2026-07-21 18:35:18.932907+00	completed	approved	100	11.30	2026-07-26	medium
efb263c4-05b2-42d2-bc77-af9f0cbd846e	a256424e-8cd7-4ffb-b83d-74e08a248892	\N	2505504d-a7d6-4a58-975c-bed21d1319bd	c0c1258a-257b-4a56-bc50-4efdde442732	افزودن تست واحد برای سرویس کاربران #9	\N	high	2026-07-22	e6775c6f-be2a-4808-a240-264f48dc3c4f	2026-07-21 18:35:18.932907+00	2026-07-21 18:35:18.932907+00	in_progress	\N	41	34.00	2026-07-03	medium
efb263c4-05b2-42d2-bc77-af9f0cbd846e	a256424e-8cd7-4ffb-b83d-74e08a248892	\N	1bc00cf9-0b6c-453b-8f81-55a9f72ad244	c0c1258a-257b-4a56-bc50-4efdde442732	رفع مشکل ناسازگاری مرورگر #10	\N	medium	2026-07-03	f0e82635-2aaa-4f03-9240-40ef8f413ab4	2026-07-21 18:35:18.932907+00	2026-07-21 18:35:18.932907+00	todo	\N	51	12.20	2026-06-30	medium
efb263c4-05b2-42d2-bc77-af9f0cbd846e	a256424e-8cd7-4ffb-b83d-74e08a248892	\N	caaef6d7-fee2-48a7-bd4b-3697a88773ea	c0c1258a-257b-4a56-bc50-4efdde442732	تنظیم پایپ‌لاین CI/CD #11	\N	medium	2026-07-14	6815e38a-f877-422d-bae7-f753339d7801	2026-07-21 18:35:18.932907+00	2026-07-21 18:35:18.932907+00	completed	pending	100	17.00	2026-07-06	medium
efb263c4-05b2-42d2-bc77-af9f0cbd846e	a256424e-8cd7-4ffb-b83d-74e08a248892	\N	4cef53c1-898c-4945-b51b-a1d36322bb51	c0c1258a-257b-4a56-bc50-4efdde442732	نوشتن مستندات فنی API #12	\N	high	2026-07-03	3dee5261-53c4-4b23-9696-6b8b40719822	2026-07-21 18:35:18.932907+00	2026-07-21 18:35:18.932907+00	completed	approved	100	22.50	2026-06-24	medium
efb263c4-05b2-42d2-bc77-af9f0cbd846e	a256424e-8cd7-4ffb-b83d-74e08a248892	\N	4cef53c1-898c-4945-b51b-a1d36322bb51	c0c1258a-257b-4a56-bc50-4efdde442732	رفع مشکل کندی بارگذاری صفحه #13	\N	low	2026-08-06	7a7351b6-2750-4846-90f1-9ab74835ec05	2026-07-21 18:35:18.932907+00	2026-07-21 18:35:18.932907+00	completed	approved	100	39.90	2026-07-23	medium
efb263c4-05b2-42d2-bc77-af9f0cbd846e	a256424e-8cd7-4ffb-b83d-74e08a248892	\N	caaef6d7-fee2-48a7-bd4b-3697a88773ea	c0c1258a-257b-4a56-bc50-4efdde442732	بازنویسی ماژول اعلان‌ها #14	\N	low	2026-08-06	c9507331-b60c-41d6-a434-8d64b6332108	2026-07-21 18:35:18.932907+00	2026-07-21 18:35:18.932907+00	completed	approved	100	7.80	2026-08-03	medium
efb263c4-05b2-42d2-bc77-af9f0cbd846e	a256424e-8cd7-4ffb-b83d-74e08a248892	\N	caaef6d7-fee2-48a7-bd4b-3697a88773ea	c0c1258a-257b-4a56-bc50-4efdde442732	پیاده‌سازی احراز هویت دومرحله‌ای #15	\N	high	2026-07-04	edd10da0-cbb2-4fa4-87f6-d682a5627958	2026-07-21 18:35:18.932907+00	2026-07-21 18:35:18.932907+00	completed	approved	100	39.90	2026-06-20	medium
efb263c4-05b2-42d2-bc77-af9f0cbd846e	a256424e-8cd7-4ffb-b83d-74e08a248892	\N	2a912655-64c4-44a5-9beb-6093704c47bd	c0c1258a-257b-4a56-bc50-4efdde442732	تنظیم پایپ‌لاین CI/CD #16	\N	high	2026-07-23	ef57cf52-d9fe-4495-b739-6c30e2a9476d	2026-07-21 18:35:18.932907+00	2026-07-21 18:35:18.932907+00	in_progress	\N	14	27.90	2026-07-21	medium
efb263c4-05b2-42d2-bc77-af9f0cbd846e	a256424e-8cd7-4ffb-b83d-74e08a248892	\N	2a912655-64c4-44a5-9beb-6093704c47bd	c0c1258a-257b-4a56-bc50-4efdde442732	پیاده‌سازی صفحهٔ ورود جدید #17	\N	medium	2026-07-15	6550c1b4-a467-4d56-8740-f7537ccc917d	2026-07-21 18:35:18.932907+00	2026-07-21 18:35:18.932907+00	archived	\N	55	8.00	2026-07-03	medium
efb263c4-05b2-42d2-bc77-af9f0cbd846e	a256424e-8cd7-4ffb-b83d-74e08a248892	\N	c0c1258a-257b-4a56-bc50-4efdde442732	c0c1258a-257b-4a56-bc50-4efdde442732	به‌روزرسانی کتابخانه‌های وابسته #18	\N	low	2026-08-21	454fbd0e-4232-4719-8654-793379dc63da	2026-07-21 18:35:18.932907+00	2026-07-21 18:35:18.932907+00	archived	\N	64	36.70	2026-08-11	medium
efb263c4-05b2-42d2-bc77-af9f0cbd846e	c6d8abca-4a0d-480d-85f7-d34d1d133855	\N	1bc00cf9-0b6c-453b-8f81-55a9f72ad244	c0c1258a-257b-4a56-bc50-4efdde442732	پیاده‌سازی صفحهٔ داشبورد مدیریتی #19	\N	low	2026-08-13	a887db68-83b4-4099-bb12-c4b2c13b3f5c	2026-07-21 18:35:18.932907+00	2026-07-21 18:35:18.932907+00	completed	approved	100	7.80	2026-07-26	medium
efb263c4-05b2-42d2-bc77-af9f0cbd846e	c6d8abca-4a0d-480d-85f7-d34d1d133855	\N	1bc00cf9-0b6c-453b-8f81-55a9f72ad244	c0c1258a-257b-4a56-bc50-4efdde442732	افزودن قابلیت جست‌وجوی پیشرفته #20	\N	low	2026-08-07	6197d72d-b523-4a0f-83ea-e9ceefcd318d	2026-07-21 18:35:18.932907+00	2026-07-21 18:35:18.932907+00	todo	\N	76	14.30	2026-07-20	medium
efb263c4-05b2-42d2-bc77-af9f0cbd846e	c6d8abca-4a0d-480d-85f7-d34d1d133855	\N	c0c1258a-257b-4a56-bc50-4efdde442732	c0c1258a-257b-4a56-bc50-4efdde442732	افزودن قابلیت جست‌وجوی پیشرفته #21	\N	medium	2026-08-27	d854e6d3-210c-4cdd-af21-57dc2afe4ca5	2026-07-21 18:35:18.932907+00	2026-07-21 18:35:18.932907+00	todo	\N	30	4.20	2026-08-14	medium
efb263c4-05b2-42d2-bc77-af9f0cbd846e	c6d8abca-4a0d-480d-85f7-d34d1d133855	\N	2a912655-64c4-44a5-9beb-6093704c47bd	c0c1258a-257b-4a56-bc50-4efdde442732	بازنویسی ماژول اعلان‌ها #22	\N	low	2026-07-08	6db646a8-1617-47be-b885-317b4ad30da8	2026-07-21 18:35:18.932907+00	2026-07-21 18:35:18.932907+00	todo	\N	68	31.10	2026-06-21	medium
efb263c4-05b2-42d2-bc77-af9f0cbd846e	c6d8abca-4a0d-480d-85f7-d34d1d133855	\N	caaef6d7-fee2-48a7-bd4b-3697a88773ea	c0c1258a-257b-4a56-bc50-4efdde442732	طراحی API نسخهٔ دوم #23	\N	high	2026-07-28	3b1f6aab-0c85-4ac1-99bc-93033b4880ce	2026-07-21 18:35:18.932907+00	2026-07-21 18:35:18.932907+00	completed	approved	100	35.20	2026-07-21	medium
efb263c4-05b2-42d2-bc77-af9f0cbd846e	c6d8abca-4a0d-480d-85f7-d34d1d133855	\N	2505504d-a7d6-4a58-975c-bed21d1319bd	c0c1258a-257b-4a56-bc50-4efdde442732	رفع مشکل ناسازگاری مرورگر #24	\N	high	2026-09-02	db934a4a-92bc-4232-8d8e-65ad0bbdca7f	2026-07-21 18:35:18.932907+00	2026-07-21 18:35:18.932907+00	in_progress	\N	25	29.10	2026-08-14	medium
efb263c4-05b2-42d2-bc77-af9f0cbd846e	c6d8abca-4a0d-480d-85f7-d34d1d133855	\N	2505504d-a7d6-4a58-975c-bed21d1319bd	c0c1258a-257b-4a56-bc50-4efdde442732	بررسی و رفع آسیب‌پذیری امنیتی #25	\N	low	2026-08-01	1bcab334-e818-4747-82d8-de6d19656265	2026-07-21 18:35:18.932907+00	2026-07-21 18:35:18.932907+00	completed	pending	100	11.40	2026-07-14	medium
efb263c4-05b2-42d2-bc77-af9f0cbd846e	c6d8abca-4a0d-480d-85f7-d34d1d133855	\N	c0c1258a-257b-4a56-bc50-4efdde442732	c0c1258a-257b-4a56-bc50-4efdde442732	به‌روزرسانی کتابخانه‌های وابسته #26	\N	low	2026-07-07	0453889c-4326-48b8-b698-7df925d456a0	2026-07-21 18:35:18.932907+00	2026-07-21 18:35:18.932907+00	in_progress	\N	75	10.40	2026-06-17	medium
efb263c4-05b2-42d2-bc77-af9f0cbd846e	c6d8abca-4a0d-480d-85f7-d34d1d133855	\N	c0c1258a-257b-4a56-bc50-4efdde442732	c0c1258a-257b-4a56-bc50-4efdde442732	افزودن تست واحد برای سرویس کاربران #27	\N	low	2026-07-29	5b92ff8d-9192-46ba-ae78-48b8dd2fe13a	2026-07-21 18:35:18.932907+00	2026-07-21 18:35:18.932907+00	archived	\N	4	34.70	2026-07-26	medium
efb263c4-05b2-42d2-bc77-af9f0cbd846e	c6d8abca-4a0d-480d-85f7-d34d1d133855	\N	c0c1258a-257b-4a56-bc50-4efdde442732	c0c1258a-257b-4a56-bc50-4efdde442732	افزودن تست واحد برای سرویس کاربران #28	\N	high	2026-08-14	15f99e35-3c31-4ff9-833c-ebb62cbd2a5d	2026-07-21 18:35:18.932907+00	2026-07-21 18:35:18.932907+00	completed	approved	100	7.00	2026-07-28	medium
efb263c4-05b2-42d2-bc77-af9f0cbd846e	c6d8abca-4a0d-480d-85f7-d34d1d133855	\N	2a912655-64c4-44a5-9beb-6093704c47bd	c0c1258a-257b-4a56-bc50-4efdde442732	رفع مشکل ناسازگاری مرورگر #29	\N	medium	2026-08-22	18d0e16f-b59b-4542-bf28-fa231b18cf60	2026-07-21 18:35:18.932907+00	2026-07-21 18:35:18.932907+00	completed	approved	100	9.20	2026-08-05	medium
efb263c4-05b2-42d2-bc77-af9f0cbd846e	c6d8abca-4a0d-480d-85f7-d34d1d133855	\N	c0c1258a-257b-4a56-bc50-4efdde442732	c0c1258a-257b-4a56-bc50-4efdde442732	بررسی و رفع آسیب‌پذیری امنیتی #30	\N	high	2026-07-28	45612307-60b2-4a3d-afaf-4599f436f141	2026-07-21 18:35:18.932907+00	2026-07-21 18:35:18.932907+00	completed	approved	100	4.10	2026-07-13	medium
efb263c4-05b2-42d2-bc77-af9f0cbd846e	c6d8abca-4a0d-480d-85f7-d34d1d133855	\N	4cef53c1-898c-4945-b51b-a1d36322bb51	c0c1258a-257b-4a56-bc50-4efdde442732	رفع مشکل ناسازگاری مرورگر #31	\N	low	2026-07-23	b5d9b271-c257-43dc-bd40-ab2dbbc9cd49	2026-07-21 18:35:18.932907+00	2026-07-21 18:35:18.932907+00	completed	approved	100	11.40	2026-07-11	medium
efb263c4-05b2-42d2-bc77-af9f0cbd846e	c6d8abca-4a0d-480d-85f7-d34d1d133855	\N	caaef6d7-fee2-48a7-bd4b-3697a88773ea	c0c1258a-257b-4a56-bc50-4efdde442732	طراحی API نسخهٔ دوم #32	\N	medium	2026-07-20	c0cbabcd-1910-4b2c-8e59-087db2c5294e	2026-07-21 18:35:18.932907+00	2026-07-21 18:35:18.932907+00	completed	approved	100	11.50	2026-07-13	medium
efb263c4-05b2-42d2-bc77-af9f0cbd846e	c6d8abca-4a0d-480d-85f7-d34d1d133855	\N	c0c1258a-257b-4a56-bc50-4efdde442732	c0c1258a-257b-4a56-bc50-4efdde442732	پیاده‌سازی صفحهٔ ورود جدید #33	\N	low	2026-08-28	9a0fc5c3-2243-4069-9920-cd38d27460f1	2026-07-21 18:35:18.932907+00	2026-07-21 18:35:18.932907+00	completed	pending	100	26.80	2026-08-09	medium
efb263c4-05b2-42d2-bc77-af9f0cbd846e	c6d8abca-4a0d-480d-85f7-d34d1d133855	\N	2a912655-64c4-44a5-9beb-6093704c47bd	c0c1258a-257b-4a56-bc50-4efdde442732	بهینه‌سازی کوئری‌های گزارش‌گیری #34	\N	medium	2026-06-30	0a3345d0-c6c0-4727-bfe1-8e0f6289f542	2026-07-21 18:35:18.932907+00	2026-07-21 18:35:18.932907+00	todo	\N	62	20.30	2026-06-21	medium
efb263c4-05b2-42d2-bc77-af9f0cbd846e	c6d8abca-4a0d-480d-85f7-d34d1d133855	\N	1bc00cf9-0b6c-453b-8f81-55a9f72ad244	c0c1258a-257b-4a56-bc50-4efdde442732	بهینه‌سازی کوئری‌های گزارش‌گیری #35	\N	medium	2026-08-15	c335afdd-276e-436b-83e4-c02473666c0c	2026-07-21 18:35:18.932907+00	2026-07-21 18:35:18.932907+00	in_progress	\N	0	39.40	2026-08-12	medium
efb263c4-05b2-42d2-bc77-af9f0cbd846e	c6d8abca-4a0d-480d-85f7-d34d1d133855	\N	14420cd5-d1bc-4e91-8063-b90ed9c1d745	c0c1258a-257b-4a56-bc50-4efdde442732	تنظیم پایپ‌لاین CI/CD #36	\N	high	2026-08-18	27764649-b103-41dc-913a-f199c17c985b	2026-07-21 18:35:18.932907+00	2026-07-21 18:35:18.932907+00	completed	approved	100	20.50	2026-07-30	medium
efb263c4-05b2-42d2-bc77-af9f0cbd846e	e79efaad-56e0-4883-adb3-699fa5b5b4e1	\N	caaef6d7-fee2-48a7-bd4b-3697a88773ea	c0c1258a-257b-4a56-bc50-4efdde442732	پیاده‌سازی صفحهٔ داشبورد مدیریتی #37	\N	high	2026-07-02	841d82b4-0920-4bca-8a90-efd6cf388417	2026-07-21 18:35:18.932907+00	2026-07-21 18:35:18.932907+00	in_progress	\N	69	4.30	2026-06-29	medium
efb263c4-05b2-42d2-bc77-af9f0cbd846e	e79efaad-56e0-4883-adb3-699fa5b5b4e1	\N	14420cd5-d1bc-4e91-8063-b90ed9c1d745	c0c1258a-257b-4a56-bc50-4efdde442732	بررسی و رفع آسیب‌پذیری امنیتی #38	\N	high	2026-07-09	aca62750-f381-41b3-97c5-9f7acf3f4b90	2026-07-21 18:35:18.932907+00	2026-07-21 18:35:18.932907+00	todo	\N	67	8.00	2026-06-19	medium
efb263c4-05b2-42d2-bc77-af9f0cbd846e	e79efaad-56e0-4883-adb3-699fa5b5b4e1	\N	2a912655-64c4-44a5-9beb-6093704c47bd	c0c1258a-257b-4a56-bc50-4efdde442732	پیاده‌سازی صفحهٔ ورود جدید #39	\N	high	2026-08-16	7e1f0046-a305-44e7-8da0-e34305e2f596	2026-07-21 18:35:18.932907+00	2026-07-21 18:35:18.932907+00	todo	\N	8	27.70	2026-08-09	medium
efb263c4-05b2-42d2-bc77-af9f0cbd846e	e79efaad-56e0-4883-adb3-699fa5b5b4e1	\N	caaef6d7-fee2-48a7-bd4b-3697a88773ea	c0c1258a-257b-4a56-bc50-4efdde442732	افزودن تست واحد برای سرویس کاربران #40	\N	high	2026-07-13	a64c7b6a-1ec6-42b0-b46a-259eff9045ce	2026-07-21 18:35:18.932907+00	2026-07-21 18:35:18.932907+00	in_progress	\N	76	3.50	2026-06-23	medium
efb263c4-05b2-42d2-bc77-af9f0cbd846e	e79efaad-56e0-4883-adb3-699fa5b5b4e1	\N	c0c1258a-257b-4a56-bc50-4efdde442732	c0c1258a-257b-4a56-bc50-4efdde442732	پیاده‌سازی صفحهٔ داشبورد مدیریتی #41	\N	high	2026-08-17	b3e1ccce-64c8-41d8-915d-11d9b09f8dcf	2026-07-21 18:35:18.932907+00	2026-07-21 18:35:18.932907+00	in_progress	\N	40	37.50	2026-07-28	medium
efb263c4-05b2-42d2-bc77-af9f0cbd846e	e79efaad-56e0-4883-adb3-699fa5b5b4e1	\N	caaef6d7-fee2-48a7-bd4b-3697a88773ea	c0c1258a-257b-4a56-bc50-4efdde442732	پیاده‌سازی احراز هویت دومرحله‌ای #42	\N	low	2026-07-11	3b75f8c8-8d28-44cf-bd8b-7871813f362b	2026-07-21 18:35:18.932907+00	2026-07-21 18:35:18.932907+00	completed	pending	100	27.50	2026-07-01	medium
efb263c4-05b2-42d2-bc77-af9f0cbd846e	e79efaad-56e0-4883-adb3-699fa5b5b4e1	\N	14420cd5-d1bc-4e91-8063-b90ed9c1d745	c0c1258a-257b-4a56-bc50-4efdde442732	رفع باگ در ماژول پرداخت #43	\N	medium	2026-08-07	c74728c1-1ae1-4d91-8664-04e0b701683c	2026-07-21 18:35:18.932907+00	2026-07-21 18:35:18.932907+00	completed	approved	100	25.60	2026-08-03	medium
efb263c4-05b2-42d2-bc77-af9f0cbd846e	e79efaad-56e0-4883-adb3-699fa5b5b4e1	\N	2a912655-64c4-44a5-9beb-6093704c47bd	c0c1258a-257b-4a56-bc50-4efdde442732	افزودن تست واحد برای سرویس کاربران #44	\N	high	2026-07-09	acc4b9de-dd69-465c-a5f6-21e4f46a9f54	2026-07-21 18:35:18.932907+00	2026-07-21 18:35:18.932907+00	todo	\N	33	7.00	2026-06-20	medium
efb263c4-05b2-42d2-bc77-af9f0cbd846e	e79efaad-56e0-4883-adb3-699fa5b5b4e1	\N	14420cd5-d1bc-4e91-8063-b90ed9c1d745	c0c1258a-257b-4a56-bc50-4efdde442732	رفع مشکل کندی بارگذاری صفحه #45	\N	medium	2026-08-20	50a4ad06-7bba-47e0-916a-cdf37a01a6ff	2026-07-21 18:35:18.932907+00	2026-07-21 18:35:18.932907+00	todo	\N	20	18.70	2026-08-11	medium
efb263c4-05b2-42d2-bc77-af9f0cbd846e	e79efaad-56e0-4883-adb3-699fa5b5b4e1	\N	2a912655-64c4-44a5-9beb-6093704c47bd	c0c1258a-257b-4a56-bc50-4efdde442732	رفع مشکل ناسازگاری مرورگر #46	\N	high	2026-07-26	075d8f7b-41b1-4cff-b496-b492d10c23a7	2026-07-21 18:35:18.932907+00	2026-07-21 18:35:18.932907+00	archived	\N	67	2.30	2026-07-05	medium
efb263c4-05b2-42d2-bc77-af9f0cbd846e	e79efaad-56e0-4883-adb3-699fa5b5b4e1	\N	1bc00cf9-0b6c-453b-8f81-55a9f72ad244	c0c1258a-257b-4a56-bc50-4efdde442732	افزودن قابلیت جست‌وجوی پیشرفته #47	\N	low	2026-08-02	3791d80e-99a6-411b-bdea-d9517fd5c36b	2026-07-21 18:35:18.932907+00	2026-07-21 18:35:18.932907+00	completed	approved	100	12.00	2026-07-28	medium
efb263c4-05b2-42d2-bc77-af9f0cbd846e	e79efaad-56e0-4883-adb3-699fa5b5b4e1	\N	c0c1258a-257b-4a56-bc50-4efdde442732	c0c1258a-257b-4a56-bc50-4efdde442732	طراحی API نسخهٔ دوم #48	\N	medium	2026-07-27	e11a60a4-7173-4948-8808-dcb128b3daa4	2026-07-21 18:35:18.932907+00	2026-07-21 18:35:18.932907+00	archived	\N	77	10.00	2026-07-21	medium
efb263c4-05b2-42d2-bc77-af9f0cbd846e	e79efaad-56e0-4883-adb3-699fa5b5b4e1	\N	14420cd5-d1bc-4e91-8063-b90ed9c1d745	c0c1258a-257b-4a56-bc50-4efdde442732	به‌روزرسانی کتابخانه‌های وابسته #49	\N	medium	2026-08-08	a90befd3-4dc2-402d-ae24-14a542bc0c3c	2026-07-21 18:35:18.932907+00	2026-07-21 18:35:18.932907+00	in_progress	\N	32	36.40	2026-07-29	medium
efb263c4-05b2-42d2-bc77-af9f0cbd846e	e79efaad-56e0-4883-adb3-699fa5b5b4e1	\N	1bc00cf9-0b6c-453b-8f81-55a9f72ad244	c0c1258a-257b-4a56-bc50-4efdde442732	بازنویسی ماژول اعلان‌ها #50	\N	medium	2026-07-06	fbd287d4-f053-4ac7-a5df-3bb200c93e60	2026-07-21 18:35:18.932907+00	2026-07-21 18:35:18.932907+00	todo	\N	5	2.10	2026-06-21	medium
efb263c4-05b2-42d2-bc77-af9f0cbd846e	e79efaad-56e0-4883-adb3-699fa5b5b4e1	\N	1bc00cf9-0b6c-453b-8f81-55a9f72ad244	c0c1258a-257b-4a56-bc50-4efdde442732	بهینه‌سازی کوئری‌های گزارش‌گیری #51	\N	high	2026-08-05	70b359bd-a577-4f0c-9935-5238053668b8	2026-07-21 18:35:18.932907+00	2026-07-21 18:35:18.932907+00	todo	\N	56	23.00	2026-07-26	medium
efb263c4-05b2-42d2-bc77-af9f0cbd846e	e79efaad-56e0-4883-adb3-699fa5b5b4e1	\N	2505504d-a7d6-4a58-975c-bed21d1319bd	c0c1258a-257b-4a56-bc50-4efdde442732	به‌روزرسانی کتابخانه‌های وابسته #52	\N	low	2026-06-26	fdaa2c25-eb79-49e0-b3d7-4e171c04f3cd	2026-07-21 18:35:18.932907+00	2026-07-21 18:35:18.932907+00	completed	approved	100	33.70	2026-06-20	medium
efb263c4-05b2-42d2-bc77-af9f0cbd846e	e79efaad-56e0-4883-adb3-699fa5b5b4e1	\N	2a912655-64c4-44a5-9beb-6093704c47bd	c0c1258a-257b-4a56-bc50-4efdde442732	طراحی API نسخهٔ دوم #53	\N	medium	2026-06-27	fb201f49-11a4-427f-95db-aea2cf4f40f8	2026-07-21 18:35:18.932907+00	2026-07-21 18:35:18.932907+00	completed	approved	100	36.20	2026-06-24	medium
efb263c4-05b2-42d2-bc77-af9f0cbd846e	e79efaad-56e0-4883-adb3-699fa5b5b4e1	\N	1bc00cf9-0b6c-453b-8f81-55a9f72ad244	c0c1258a-257b-4a56-bc50-4efdde442732	افزودن تست واحد برای سرویس کاربران #54	\N	high	2026-08-25	57722106-8abd-4bba-ba26-55ae45dcb457	2026-07-21 18:35:18.932907+00	2026-07-21 18:35:18.932907+00	todo	\N	31	27.30	2026-08-12	medium
efb263c4-05b2-42d2-bc77-af9f0cbd846e	d2117d77-f066-4ab6-9678-e32a36d45c1a	\N	14420cd5-d1bc-4e91-8063-b90ed9c1d745	c0c1258a-257b-4a56-bc50-4efdde442732	پیاده‌سازی صفحهٔ داشبورد مدیریتی #55	\N	high	2026-08-05	b8d38bee-ce44-450c-a615-f3474837e8a0	2026-07-21 18:35:18.932907+00	2026-07-21 18:35:18.932907+00	archived	\N	19	37.20	2026-07-21	medium
efb263c4-05b2-42d2-bc77-af9f0cbd846e	d2117d77-f066-4ab6-9678-e32a36d45c1a	\N	caaef6d7-fee2-48a7-bd4b-3697a88773ea	c0c1258a-257b-4a56-bc50-4efdde442732	افزودن قابلیت جست‌وجوی پیشرفته #56	\N	medium	2026-08-13	b2bce02c-8984-4f0d-8841-4a9efad6ce90	2026-07-21 18:35:18.932907+00	2026-07-21 18:35:18.932907+00	todo	\N	3	8.80	2026-08-06	medium
efb263c4-05b2-42d2-bc77-af9f0cbd846e	d2117d77-f066-4ab6-9678-e32a36d45c1a	\N	14420cd5-d1bc-4e91-8063-b90ed9c1d745	c0c1258a-257b-4a56-bc50-4efdde442732	طراحی API نسخهٔ دوم #57	\N	low	2026-08-15	0f6696ea-1eb8-430a-844a-6ef38e0dc872	2026-07-21 18:35:18.932907+00	2026-07-21 18:35:18.932907+00	in_progress	\N	13	16.50	2026-08-06	medium
efb263c4-05b2-42d2-bc77-af9f0cbd846e	d2117d77-f066-4ab6-9678-e32a36d45c1a	\N	c0c1258a-257b-4a56-bc50-4efdde442732	c0c1258a-257b-4a56-bc50-4efdde442732	رفع مشکل کندی بارگذاری صفحه #58	\N	medium	2026-08-23	f2bbd36f-6f4c-470e-af4c-f26b9bfddf16	2026-07-21 18:35:18.932907+00	2026-07-21 18:35:18.932907+00	completed	approved	100	33.20	2026-08-07	medium
efb263c4-05b2-42d2-bc77-af9f0cbd846e	d2117d77-f066-4ab6-9678-e32a36d45c1a	\N	1bc00cf9-0b6c-453b-8f81-55a9f72ad244	c0c1258a-257b-4a56-bc50-4efdde442732	تنظیم پایپ‌لاین CI/CD #59	\N	low	2026-07-02	714ba6fa-5a76-4eb6-bdc8-15b425f93b60	2026-07-21 18:35:18.932907+00	2026-07-21 18:35:18.932907+00	in_progress	\N	51	14.50	2026-06-30	medium
efb263c4-05b2-42d2-bc77-af9f0cbd846e	d2117d77-f066-4ab6-9678-e32a36d45c1a	\N	1bc00cf9-0b6c-453b-8f81-55a9f72ad244	c0c1258a-257b-4a56-bc50-4efdde442732	رفع مشکل کندی بارگذاری صفحه #60	\N	high	2026-08-14	38289f1f-1fe6-4d9c-b543-33497ac7151b	2026-07-21 18:35:18.932907+00	2026-07-21 18:35:18.932907+00	todo	\N	65	17.20	2026-08-04	medium
efb263c4-05b2-42d2-bc77-af9f0cbd846e	d2117d77-f066-4ab6-9678-e32a36d45c1a	\N	1bc00cf9-0b6c-453b-8f81-55a9f72ad244	c0c1258a-257b-4a56-bc50-4efdde442732	افزودن قابلیت جست‌وجوی پیشرفته #61	\N	medium	2026-06-22	c7712c68-ca32-4e14-9907-167b4afa05aa	2026-07-21 18:35:18.932907+00	2026-07-21 18:35:18.932907+00	completed	approved	100	8.80	2026-06-17	medium
efb263c4-05b2-42d2-bc77-af9f0cbd846e	d2117d77-f066-4ab6-9678-e32a36d45c1a	\N	14420cd5-d1bc-4e91-8063-b90ed9c1d745	c0c1258a-257b-4a56-bc50-4efdde442732	پیاده‌سازی احراز هویت دومرحله‌ای #62	\N	medium	2026-07-13	52c30bce-a2ff-4409-bd18-bbac3fa3154c	2026-07-21 18:35:18.932907+00	2026-07-21 18:35:18.932907+00	todo	\N	40	18.60	2026-06-22	medium
efb263c4-05b2-42d2-bc77-af9f0cbd846e	d2117d77-f066-4ab6-9678-e32a36d45c1a	\N	2a912655-64c4-44a5-9beb-6093704c47bd	c0c1258a-257b-4a56-bc50-4efdde442732	افزودن تست واحد برای سرویس کاربران #63	\N	medium	2026-07-30	155b7b61-ac76-4a1e-bd33-eba437eff247	2026-07-21 18:35:18.932907+00	2026-07-21 18:35:18.932907+00	todo	\N	5	28.90	2026-07-10	medium
efb263c4-05b2-42d2-bc77-af9f0cbd846e	d2117d77-f066-4ab6-9678-e32a36d45c1a	\N	c0c1258a-257b-4a56-bc50-4efdde442732	c0c1258a-257b-4a56-bc50-4efdde442732	رفع مشکل کندی بارگذاری صفحه #64	\N	medium	2026-07-28	d54dd4a5-2f9f-4bf8-b43b-761d8beb2d5c	2026-07-21 18:35:18.932907+00	2026-07-21 18:35:18.932907+00	completed	rejected	100	4.70	2026-07-20	medium
efb263c4-05b2-42d2-bc77-af9f0cbd846e	d2117d77-f066-4ab6-9678-e32a36d45c1a	\N	4cef53c1-898c-4945-b51b-a1d36322bb51	c0c1258a-257b-4a56-bc50-4efdde442732	تنظیم پایپ‌لاین CI/CD #65	\N	low	2026-08-06	fc483c0f-30f7-43fb-a97b-feec44fa7179	2026-07-21 18:35:18.932907+00	2026-07-21 18:35:18.932907+00	in_progress	\N	38	21.30	2026-07-25	medium
efb263c4-05b2-42d2-bc77-af9f0cbd846e	d2117d77-f066-4ab6-9678-e32a36d45c1a	\N	4cef53c1-898c-4945-b51b-a1d36322bb51	c0c1258a-257b-4a56-bc50-4efdde442732	نوشتن مستندات فنی API #66	\N	medium	2026-07-20	a92504ef-d988-417f-8bb1-23034f926ed9	2026-07-21 18:35:18.932907+00	2026-07-21 18:35:18.932907+00	in_progress	\N	70	6.80	2026-07-06	medium
efb263c4-05b2-42d2-bc77-af9f0cbd846e	d2117d77-f066-4ab6-9678-e32a36d45c1a	\N	2505504d-a7d6-4a58-975c-bed21d1319bd	c0c1258a-257b-4a56-bc50-4efdde442732	پیاده‌سازی صفحهٔ داشبورد مدیریتی #67	\N	high	2026-08-05	4302bf33-e671-4c88-b2be-e08e75316dc1	2026-07-21 18:35:18.932907+00	2026-07-21 18:35:18.932907+00	completed	rejected	100	13.40	2026-07-29	medium
efb263c4-05b2-42d2-bc77-af9f0cbd846e	d2117d77-f066-4ab6-9678-e32a36d45c1a	\N	2a912655-64c4-44a5-9beb-6093704c47bd	c0c1258a-257b-4a56-bc50-4efdde442732	افزودن تست واحد برای سرویس کاربران #68	\N	medium	2026-07-16	32d8da58-ca8b-4c33-9bd2-c09c2a4b28b8	2026-07-21 18:35:18.932907+00	2026-07-21 18:35:18.932907+00	todo	\N	74	25.10	2026-07-05	medium
efb263c4-05b2-42d2-bc77-af9f0cbd846e	d2117d77-f066-4ab6-9678-e32a36d45c1a	\N	14420cd5-d1bc-4e91-8063-b90ed9c1d745	c0c1258a-257b-4a56-bc50-4efdde442732	به‌روزرسانی کتابخانه‌های وابسته #69	\N	medium	2026-08-06	f25c38bf-4590-485d-975f-c2b5b94a3565	2026-07-21 18:35:18.932907+00	2026-07-21 18:35:18.932907+00	completed	approved	100	32.20	2026-07-29	medium
efb263c4-05b2-42d2-bc77-af9f0cbd846e	d2117d77-f066-4ab6-9678-e32a36d45c1a	\N	1bc00cf9-0b6c-453b-8f81-55a9f72ad244	c0c1258a-257b-4a56-bc50-4efdde442732	طراحی API نسخهٔ دوم #70	\N	high	2026-06-30	f3195044-6591-4435-b7ea-3364ab0b9bf7	2026-07-21 18:35:18.932907+00	2026-07-21 18:35:18.932907+00	archived	\N	79	14.70	2026-06-26	medium
efb263c4-05b2-42d2-bc77-af9f0cbd846e	d2117d77-f066-4ab6-9678-e32a36d45c1a	\N	1bc00cf9-0b6c-453b-8f81-55a9f72ad244	c0c1258a-257b-4a56-bc50-4efdde442732	افزودن تست واحد برای سرویس کاربران #71	\N	low	2026-07-12	65cc8675-ba88-457d-a8f1-f3031eaac383	2026-07-21 18:35:18.932907+00	2026-07-21 18:35:18.932907+00	archived	\N	18	2.90	2026-07-01	medium
efb263c4-05b2-42d2-bc77-af9f0cbd846e	d2117d77-f066-4ab6-9678-e32a36d45c1a	\N	caaef6d7-fee2-48a7-bd4b-3697a88773ea	c0c1258a-257b-4a56-bc50-4efdde442732	بررسی و رفع آسیب‌پذیری امنیتی #72	\N	medium	2026-08-08	f01306bc-7e74-45d5-bde8-f320fa448f0a	2026-07-21 18:35:18.932907+00	2026-07-21 18:35:18.932907+00	completed	pending	100	35.70	2026-08-04	medium
efb263c4-05b2-42d2-bc77-af9f0cbd846e	654a21fd-66c7-412b-9936-bb14abeb65b1	\N	2a912655-64c4-44a5-9beb-6093704c47bd	c0c1258a-257b-4a56-bc50-4efdde442732	بررسی و رفع آسیب‌پذیری امنیتی #73	\N	medium	2026-08-14	e31daa2d-f3ff-47b5-8419-503f38df8eee	2026-07-21 18:35:18.932907+00	2026-07-21 18:35:18.932907+00	todo	\N	31	7.60	2026-07-31	medium
efb263c4-05b2-42d2-bc77-af9f0cbd846e	654a21fd-66c7-412b-9936-bb14abeb65b1	\N	4cef53c1-898c-4945-b51b-a1d36322bb51	c0c1258a-257b-4a56-bc50-4efdde442732	رفع مشکل ناسازگاری مرورگر #74	\N	medium	2026-08-17	e6f201bd-9cfa-4056-b329-95f77360b35c	2026-07-21 18:35:18.932907+00	2026-07-21 18:35:18.932907+00	todo	\N	28	8.70	2026-08-12	medium
efb263c4-05b2-42d2-bc77-af9f0cbd846e	654a21fd-66c7-412b-9936-bb14abeb65b1	\N	4cef53c1-898c-4945-b51b-a1d36322bb51	c0c1258a-257b-4a56-bc50-4efdde442732	افزودن قابلیت جست‌وجوی پیشرفته #75	\N	low	2026-07-30	e7e5502f-4477-4c02-ba3c-d7cca9877322	2026-07-21 18:35:18.932907+00	2026-07-21 18:35:18.932907+00	completed	approved	100	19.30	2026-07-21	medium
efb263c4-05b2-42d2-bc77-af9f0cbd846e	654a21fd-66c7-412b-9936-bb14abeb65b1	\N	1bc00cf9-0b6c-453b-8f81-55a9f72ad244	c0c1258a-257b-4a56-bc50-4efdde442732	رفع مشکل کندی بارگذاری صفحه #76	\N	medium	2026-08-11	5edb49c7-499d-4c72-a80a-9a0bb90a3a6d	2026-07-21 18:35:18.932907+00	2026-07-21 18:35:18.932907+00	completed	pending	100	25.30	2026-07-21	medium
efb263c4-05b2-42d2-bc77-af9f0cbd846e	654a21fd-66c7-412b-9936-bb14abeb65b1	\N	4cef53c1-898c-4945-b51b-a1d36322bb51	c0c1258a-257b-4a56-bc50-4efdde442732	بررسی و رفع آسیب‌پذیری امنیتی #77	\N	low	2026-09-01	f02bc276-e245-4283-af2e-f11ba41321f3	2026-07-21 18:35:18.932907+00	2026-07-21 18:35:18.932907+00	completed	approved	100	30.30	2026-08-13	medium
efb263c4-05b2-42d2-bc77-af9f0cbd846e	654a21fd-66c7-412b-9936-bb14abeb65b1	\N	2505504d-a7d6-4a58-975c-bed21d1319bd	c0c1258a-257b-4a56-bc50-4efdde442732	رفع مشکل ناسازگاری مرورگر #78	\N	high	2026-07-11	fb5297e0-559f-4b4d-9a75-973ca0f975d6	2026-07-21 18:35:18.932907+00	2026-07-21 18:35:18.932907+00	completed	approved	100	20.40	2026-07-01	medium
efb263c4-05b2-42d2-bc77-af9f0cbd846e	654a21fd-66c7-412b-9936-bb14abeb65b1	\N	caaef6d7-fee2-48a7-bd4b-3697a88773ea	c0c1258a-257b-4a56-bc50-4efdde442732	نوشتن مستندات فنی API #79	\N	medium	2026-07-18	a049df99-8a33-478f-9d08-e8d0dadc420f	2026-07-21 18:35:18.932907+00	2026-07-21 18:35:18.932907+00	in_progress	\N	30	12.30	2026-07-14	medium
efb263c4-05b2-42d2-bc77-af9f0cbd846e	654a21fd-66c7-412b-9936-bb14abeb65b1	\N	14420cd5-d1bc-4e91-8063-b90ed9c1d745	c0c1258a-257b-4a56-bc50-4efdde442732	پیاده‌سازی احراز هویت دومرحله‌ای #80	\N	high	2026-07-04	9d3df6fa-2252-44db-a9f8-c564fd0df0f0	2026-07-21 18:35:18.932907+00	2026-07-21 18:35:18.932907+00	completed	approved	100	7.80	2026-06-25	medium
efb263c4-05b2-42d2-bc77-af9f0cbd846e	654a21fd-66c7-412b-9936-bb14abeb65b1	\N	caaef6d7-fee2-48a7-bd4b-3697a88773ea	c0c1258a-257b-4a56-bc50-4efdde442732	رفع مشکل کندی بارگذاری صفحه #81	\N	high	2026-07-27	c914f1bc-34ac-4014-94a6-563bd5f413e5	2026-07-21 18:35:18.932907+00	2026-07-21 18:35:18.932907+00	todo	\N	59	17.80	2026-07-12	medium
efb263c4-05b2-42d2-bc77-af9f0cbd846e	654a21fd-66c7-412b-9936-bb14abeb65b1	\N	caaef6d7-fee2-48a7-bd4b-3697a88773ea	c0c1258a-257b-4a56-bc50-4efdde442732	نوشتن مستندات فنی API #82	\N	low	2026-07-30	f6238a47-74a9-45b1-a854-95c1b95fd176	2026-07-21 18:35:18.932907+00	2026-07-21 18:35:18.932907+00	in_progress	\N	73	16.50	2026-07-10	medium
efb263c4-05b2-42d2-bc77-af9f0cbd846e	654a21fd-66c7-412b-9936-bb14abeb65b1	\N	c0c1258a-257b-4a56-bc50-4efdde442732	c0c1258a-257b-4a56-bc50-4efdde442732	بازنویسی ماژول اعلان‌ها #83	\N	medium	2026-07-19	306ded86-10c9-4162-aca5-788cc1303b9f	2026-07-21 18:35:18.932907+00	2026-07-21 18:35:18.932907+00	in_progress	\N	68	30.40	2026-07-05	medium
efb263c4-05b2-42d2-bc77-af9f0cbd846e	654a21fd-66c7-412b-9936-bb14abeb65b1	\N	2a912655-64c4-44a5-9beb-6093704c47bd	c0c1258a-257b-4a56-bc50-4efdde442732	طراحی API نسخهٔ دوم #84	\N	medium	2026-07-26	15a8dc90-da00-44a8-8f2f-32b8cd105393	2026-07-21 18:35:18.932907+00	2026-07-21 18:35:18.932907+00	completed	pending	100	20.50	2026-07-17	medium
efb263c4-05b2-42d2-bc77-af9f0cbd846e	654a21fd-66c7-412b-9936-bb14abeb65b1	\N	2505504d-a7d6-4a58-975c-bed21d1319bd	c0c1258a-257b-4a56-bc50-4efdde442732	نوشتن مستندات فنی API #85	\N	low	2026-08-11	d0e54a07-5987-43c1-bb8d-a10e549b2fd0	2026-07-21 18:35:18.932907+00	2026-07-21 18:35:18.932907+00	in_progress	\N	59	36.90	2026-07-28	medium
efb263c4-05b2-42d2-bc77-af9f0cbd846e	654a21fd-66c7-412b-9936-bb14abeb65b1	\N	2a912655-64c4-44a5-9beb-6093704c47bd	c0c1258a-257b-4a56-bc50-4efdde442732	پیاده‌سازی صفحهٔ داشبورد مدیریتی #86	\N	high	2026-07-31	84d9625a-5d63-473b-a718-ba0cd166b287	2026-07-21 18:35:18.932907+00	2026-07-21 18:35:18.932907+00	completed	approved	100	3.00	2026-07-11	medium
efb263c4-05b2-42d2-bc77-af9f0cbd846e	654a21fd-66c7-412b-9936-bb14abeb65b1	\N	4cef53c1-898c-4945-b51b-a1d36322bb51	c0c1258a-257b-4a56-bc50-4efdde442732	بهینه‌سازی کوئری‌های گزارش‌گیری #87	\N	low	2026-07-10	693c8a31-9916-42db-8feb-7856ac1aacb3	2026-07-21 18:35:18.932907+00	2026-07-21 18:35:18.932907+00	in_progress	\N	33	16.40	2026-06-24	medium
efb263c4-05b2-42d2-bc77-af9f0cbd846e	654a21fd-66c7-412b-9936-bb14abeb65b1	\N	caaef6d7-fee2-48a7-bd4b-3697a88773ea	c0c1258a-257b-4a56-bc50-4efdde442732	طراحی API نسخهٔ دوم #88	\N	medium	2026-08-17	45b0fc8f-5be0-4375-b8d8-1afc6d35855b	2026-07-21 18:35:18.932907+00	2026-07-21 18:35:18.932907+00	completed	approved	100	11.60	2026-08-03	medium
efb263c4-05b2-42d2-bc77-af9f0cbd846e	654a21fd-66c7-412b-9936-bb14abeb65b1	\N	c0c1258a-257b-4a56-bc50-4efdde442732	c0c1258a-257b-4a56-bc50-4efdde442732	رفع مشکل کندی بارگذاری صفحه #89	\N	low	2026-07-23	15eb3157-a61c-470b-bbae-7f6ce6fce19e	2026-07-21 18:35:18.932907+00	2026-07-21 18:35:18.932907+00	completed	approved	100	26.70	2026-07-20	medium
efb263c4-05b2-42d2-bc77-af9f0cbd846e	654a21fd-66c7-412b-9936-bb14abeb65b1	\N	1bc00cf9-0b6c-453b-8f81-55a9f72ad244	c0c1258a-257b-4a56-bc50-4efdde442732	افزودن تست واحد برای سرویس کاربران #90	\N	low	2026-06-26	ec602b79-a5c9-4b8e-8a62-ced4b9fe8cf7	2026-07-21 18:35:18.932907+00	2026-07-21 18:35:18.932907+00	completed	approved	100	25.60	2026-06-17	medium
efb263c4-05b2-42d2-bc77-af9f0cbd846e	\N	\N	caaef6d7-fee2-48a7-bd4b-3697a88773ea	caaef6d7-fee2-48a7-bd4b-3697a88773ea	پیاده‌سازی صفحهٔ داشبورد مدیریتی #91	\N	low	2026-07-21	923e658f-b62c-4612-9cc7-9e199946a5c2	2026-07-21 18:35:18.932907+00	2026-07-21 18:35:18.932907+00	todo	\N	59	28.60	2026-07-16	medium
efb263c4-05b2-42d2-bc77-af9f0cbd846e	\N	\N	1bc00cf9-0b6c-453b-8f81-55a9f72ad244	1bc00cf9-0b6c-453b-8f81-55a9f72ad244	پیاده‌سازی صفحهٔ داشبورد مدیریتی #92	\N	high	2026-07-17	8f3eceb4-347a-44e4-9bd7-63d6dc62173a	2026-07-21 18:35:18.932907+00	2026-07-21 18:35:18.932907+00	in_progress	\N	14	31.60	2026-06-26	medium
efb263c4-05b2-42d2-bc77-af9f0cbd846e	\N	\N	caaef6d7-fee2-48a7-bd4b-3697a88773ea	caaef6d7-fee2-48a7-bd4b-3697a88773ea	رفع باگ در ماژول پرداخت #93	\N	medium	2026-07-12	79e100bb-328e-4455-9039-0465f662a92b	2026-07-21 18:35:18.932907+00	2026-07-21 18:35:18.932907+00	in_progress	\N	73	27.70	2026-06-22	medium
efb263c4-05b2-42d2-bc77-af9f0cbd846e	\N	\N	2505504d-a7d6-4a58-975c-bed21d1319bd	2505504d-a7d6-4a58-975c-bed21d1319bd	پیاده‌سازی صفحهٔ ورود جدید #94	\N	high	2026-08-23	6f779aec-3bd2-42ec-ba74-9b9890639cc2	2026-07-21 18:35:18.932907+00	2026-07-21 18:35:18.932907+00	in_progress	\N	80	11.20	2026-08-15	medium
efb263c4-05b2-42d2-bc77-af9f0cbd846e	\N	\N	4cef53c1-898c-4945-b51b-a1d36322bb51	4cef53c1-898c-4945-b51b-a1d36322bb51	رفع مشکل ناسازگاری مرورگر #95	\N	low	2026-07-26	49dd9ffa-a0b9-419c-9811-d0768bc61346	2026-07-21 18:35:18.932907+00	2026-07-21 18:35:18.932907+00	archived	\N	72	31.70	2026-07-05	medium
efb263c4-05b2-42d2-bc77-af9f0cbd846e	\N	\N	14420cd5-d1bc-4e91-8063-b90ed9c1d745	14420cd5-d1bc-4e91-8063-b90ed9c1d745	به‌روزرسانی کتابخانه‌های وابسته #96	\N	high	2026-07-13	e623f740-7c20-4584-ae69-9e868e282490	2026-07-21 18:35:18.932907+00	2026-07-21 18:35:18.932907+00	completed	approved	100	15.00	2026-07-09	medium
efb263c4-05b2-42d2-bc77-af9f0cbd846e	\N	\N	1bc00cf9-0b6c-453b-8f81-55a9f72ad244	1bc00cf9-0b6c-453b-8f81-55a9f72ad244	پیاده‌سازی صفحهٔ ورود جدید #97	\N	medium	2026-08-24	c319e479-88b0-4cfe-8301-f7a4bdf8d30a	2026-07-21 18:35:18.932907+00	2026-07-21 18:35:18.932907+00	in_progress	\N	46	26.20	2026-08-07	medium
efb263c4-05b2-42d2-bc77-af9f0cbd846e	\N	\N	1bc00cf9-0b6c-453b-8f81-55a9f72ad244	1bc00cf9-0b6c-453b-8f81-55a9f72ad244	نوشتن مستندات فنی API #98	\N	high	2026-07-20	e5570023-f0a9-4675-9b9c-0d676223cc1d	2026-07-21 18:35:18.932907+00	2026-07-21 18:35:18.932907+00	completed	pending	100	38.70	2026-07-13	medium
efb263c4-05b2-42d2-bc77-af9f0cbd846e	\N	\N	14420cd5-d1bc-4e91-8063-b90ed9c1d745	14420cd5-d1bc-4e91-8063-b90ed9c1d745	بررسی و رفع آسیب‌پذیری امنیتی #99	\N	medium	2026-08-06	99d0f3e7-d936-421f-81e3-e26903aa5f31	2026-07-21 18:35:18.932907+00	2026-07-21 18:35:18.932907+00	completed	pending	100	33.40	2026-07-20	medium
efb263c4-05b2-42d2-bc77-af9f0cbd846e	\N	\N	2a912655-64c4-44a5-9beb-6093704c47bd	2a912655-64c4-44a5-9beb-6093704c47bd	بازنویسی ماژول اعلان‌ها #100	\N	low	2026-07-15	12022810-31c6-45c6-b150-a33faaa015a5	2026-07-21 18:35:18.932907+00	2026-07-21 18:35:18.932907+00	in_progress	\N	35	35.50	2026-07-06	medium
efb263c4-05b2-42d2-bc77-af9f0cbd846e	\N	\N	caaef6d7-fee2-48a7-bd4b-3697a88773ea	caaef6d7-fee2-48a7-bd4b-3697a88773ea	پیاده‌سازی صفحهٔ داشبورد مدیریتی #101	\N	high	2026-08-04	567bde4f-d879-41c3-86ea-de4eec839239	2026-07-21 18:35:18.932907+00	2026-07-21 18:35:18.932907+00	archived	\N	48	14.80	2026-07-15	medium
efb263c4-05b2-42d2-bc77-af9f0cbd846e	\N	\N	2505504d-a7d6-4a58-975c-bed21d1319bd	2505504d-a7d6-4a58-975c-bed21d1319bd	افزودن تست واحد برای سرویس کاربران #102	\N	medium	2026-07-14	daa5ebf4-98cf-4dc9-85b1-9c7bed044a6d	2026-07-21 18:35:18.932907+00	2026-07-21 18:35:18.932907+00	in_progress	\N	33	14.90	2026-06-27	medium
efb263c4-05b2-42d2-bc77-af9f0cbd846e	\N	\N	2a912655-64c4-44a5-9beb-6093704c47bd	2a912655-64c4-44a5-9beb-6093704c47bd	به‌روزرسانی کتابخانه‌های وابسته #103	\N	low	2026-07-23	11457458-d260-4f02-b762-73c5c387f186	2026-07-21 18:35:18.932907+00	2026-07-21 18:35:18.932907+00	completed	pending	100	5.30	2026-07-21	medium
efb263c4-05b2-42d2-bc77-af9f0cbd846e	\N	\N	4cef53c1-898c-4945-b51b-a1d36322bb51	4cef53c1-898c-4945-b51b-a1d36322bb51	رفع مشکل ناسازگاری مرورگر #104	\N	low	2026-08-05	9b8da72e-1223-424b-91fa-7e95e03acb03	2026-07-21 18:35:18.932907+00	2026-07-21 18:35:18.932907+00	in_progress	\N	60	26.50	2026-07-17	medium
efb263c4-05b2-42d2-bc77-af9f0cbd846e	\N	\N	2505504d-a7d6-4a58-975c-bed21d1319bd	2505504d-a7d6-4a58-975c-bed21d1319bd	افزودن تست واحد برای سرویس کاربران #105	\N	medium	2026-07-02	8f064f74-f642-4b2a-861d-bcf97c6d0419	2026-07-21 18:35:18.932907+00	2026-07-21 18:35:18.932907+00	completed	pending	100	28.30	2026-06-21	medium
efb263c4-05b2-42d2-bc77-af9f0cbd846e	e35b32f7-7e12-42fe-912f-f80b60c4ace4	\N	c288bac5-e3a4-4f1f-a050-de12845acf11	e262d280-b97e-4087-8e78-a66519bae4d1	پیگیری مطالبات معوق مشتریان #1	\N	medium	2026-07-16	0c23799e-a645-4119-8928-4a5d9711d023	2026-07-21 18:35:18.932907+00	2026-07-21 18:35:18.932907+00	completed	rejected	100	5.90	2026-06-27	medium
efb263c4-05b2-42d2-bc77-af9f0cbd846e	e35b32f7-7e12-42fe-912f-f80b60c4ace4	\N	e73ec14e-ca0c-4615-92d5-5bc43c14999a	e262d280-b97e-4087-8e78-a66519bae4d1	تهیهٔ گزارش جریان نقدی #2	\N	medium	2026-08-04	6dd2cdc1-fe8c-46e5-939f-1d2c1a708da2	2026-07-21 18:35:18.932907+00	2026-07-21 18:35:18.932907+00	completed	approved	100	8.30	2026-07-14	medium
efb263c4-05b2-42d2-bc77-af9f0cbd846e	e35b32f7-7e12-42fe-912f-f80b60c4ace4	\N	c288bac5-e3a4-4f1f-a050-de12845acf11	e262d280-b97e-4087-8e78-a66519bae4d1	تهیهٔ گزارش جریان نقدی #3	\N	medium	2026-07-17	eaf6c486-17f6-4c9e-8339-bc5ab7f02fcb	2026-07-21 18:35:18.932907+00	2026-07-21 18:35:18.932907+00	in_progress	\N	78	39.90	2026-07-14	medium
efb263c4-05b2-42d2-bc77-af9f0cbd846e	e35b32f7-7e12-42fe-912f-f80b60c4ace4	\N	e73ec14e-ca0c-4615-92d5-5bc43c14999a	e262d280-b97e-4087-8e78-a66519bae4d1	تهیهٔ گزارش سود و زیان ماهانه #4	\N	high	2026-08-18	a68be9c7-45fc-4d3f-b2bb-6fd43189d249	2026-07-21 18:35:18.932907+00	2026-07-21 18:35:18.932907+00	completed	rejected	100	26.20	2026-08-15	medium
efb263c4-05b2-42d2-bc77-af9f0cbd846e	e35b32f7-7e12-42fe-912f-f80b60c4ace4	\N	e73ec14e-ca0c-4615-92d5-5bc43c14999a	e262d280-b97e-4087-8e78-a66519bae4d1	بررسی و تأیید صورت‌حساب‌های خرید #5	\N	low	2026-08-05	4064be31-8705-417d-befb-6e95c97682f7	2026-07-21 18:35:18.932907+00	2026-07-21 18:35:18.932907+00	completed	pending	100	34.20	2026-07-29	medium
efb263c4-05b2-42d2-bc77-af9f0cbd846e	e35b32f7-7e12-42fe-912f-f80b60c4ace4	\N	1c37102f-d8b4-4bea-bd82-5b862cd46e2b	e262d280-b97e-4087-8e78-a66519bae4d1	بررسی و تسویهٔ کارت اعتباری شرکت #6	\N	high	2026-06-29	2573af8d-1cda-49b6-b677-189bfb2973df	2026-07-21 18:35:18.932907+00	2026-07-21 18:35:18.932907+00	completed	approved	100	15.90	2026-06-20	medium
efb263c4-05b2-42d2-bc77-af9f0cbd846e	e35b32f7-7e12-42fe-912f-f80b60c4ace4	\N	c288bac5-e3a4-4f1f-a050-de12845acf11	e262d280-b97e-4087-8e78-a66519bae4d1	تهیهٔ گزارش مالیاتی فصلی #7	\N	medium	2026-07-11	8c94b3aa-779a-416e-9873-14c5dc474eba	2026-07-21 18:35:18.932907+00	2026-07-21 18:35:18.932907+00	completed	approved	100	18.90	2026-06-25	medium
efb263c4-05b2-42d2-bc77-af9f0cbd846e	e35b32f7-7e12-42fe-912f-f80b60c4ace4	\N	e262d280-b97e-4087-8e78-a66519bae4d1	e262d280-b97e-4087-8e78-a66519bae4d1	تهیهٔ گزارش مالیاتی فصلی #8	\N	high	2026-07-23	4abe51a8-2374-4e6a-89ac-7806f3a73dca	2026-07-21 18:35:18.932907+00	2026-07-21 18:35:18.932907+00	completed	approved	100	12.60	2026-07-09	medium
efb263c4-05b2-42d2-bc77-af9f0cbd846e	e35b32f7-7e12-42fe-912f-f80b60c4ace4	\N	e262d280-b97e-4087-8e78-a66519bae4d1	e262d280-b97e-4087-8e78-a66519bae4d1	به‌روزرسانی جدول حقوق و دستمزد #9	\N	high	2026-08-09	63f30634-241e-47c0-9543-30579a205c4e	2026-07-21 18:35:18.932907+00	2026-07-21 18:35:18.932907+00	todo	\N	49	36.70	2026-08-02	medium
efb263c4-05b2-42d2-bc77-af9f0cbd846e	e35b32f7-7e12-42fe-912f-f80b60c4ace4	\N	e262d280-b97e-4087-8e78-a66519bae4d1	e262d280-b97e-4087-8e78-a66519bae4d1	تهیهٔ گزارش جریان نقدی #10	\N	medium	2026-08-14	8f5f2e3c-0399-45b9-98e7-9a3f6bd1e990	2026-07-21 18:35:18.932907+00	2026-07-21 18:35:18.932907+00	in_progress	\N	27	39.90	2026-08-04	medium
efb263c4-05b2-42d2-bc77-af9f0cbd846e	e35b32f7-7e12-42fe-912f-f80b60c4ace4	\N	e73ec14e-ca0c-4615-92d5-5bc43c14999a	e262d280-b97e-4087-8e78-a66519bae4d1	تهیهٔ گزارش سود و زیان ماهانه #11	\N	low	2026-07-25	355e701a-1e73-4c94-aa41-970531d9badf	2026-07-21 18:35:18.932907+00	2026-07-21 18:35:18.932907+00	completed	rejected	100	34.40	2026-07-17	medium
efb263c4-05b2-42d2-bc77-af9f0cbd846e	e35b32f7-7e12-42fe-912f-f80b60c4ace4	\N	c288bac5-e3a4-4f1f-a050-de12845acf11	e262d280-b97e-4087-8e78-a66519bae4d1	تهیهٔ گزارش سود و زیان ماهانه #12	\N	high	2026-08-28	f3874a02-9099-428a-9c5f-1200d6c30d17	2026-07-21 18:35:18.932907+00	2026-07-21 18:35:18.932907+00	todo	\N	40	27.40	2026-08-12	medium
efb263c4-05b2-42d2-bc77-af9f0cbd846e	e35b32f7-7e12-42fe-912f-f80b60c4ace4	\N	1c37102f-d8b4-4bea-bd82-5b862cd46e2b	e262d280-b97e-4087-8e78-a66519bae4d1	پیگیری مطالبات معوق مشتریان #13	\N	medium	2026-08-09	6bc38a23-bdba-479c-a20b-64382824072a	2026-07-21 18:35:18.932907+00	2026-07-21 18:35:18.932907+00	todo	\N	20	29.00	2026-07-21	medium
efb263c4-05b2-42d2-bc77-af9f0cbd846e	e35b32f7-7e12-42fe-912f-f80b60c4ace4	\N	1c37102f-d8b4-4bea-bd82-5b862cd46e2b	e262d280-b97e-4087-8e78-a66519bae4d1	ثبت اسناد حسابداری هفتگی #14	\N	low	2026-07-27	2e59f706-e7ed-4117-93c8-ec3eb3bbb249	2026-07-21 18:35:18.932907+00	2026-07-21 18:35:18.932907+00	completed	approved	100	39.40	2026-07-09	medium
efb263c4-05b2-42d2-bc77-af9f0cbd846e	e35b32f7-7e12-42fe-912f-f80b60c4ace4	\N	faf489ef-0410-4dca-bec1-65dd2fb904ba	e262d280-b97e-4087-8e78-a66519bae4d1	بررسی و تأیید صورت‌حساب‌های خرید #15	\N	medium	2026-07-18	1a1f11cc-1573-42dd-917b-acbb6fa6b14a	2026-07-21 18:35:18.932907+00	2026-07-21 18:35:18.932907+00	todo	\N	70	23.70	2026-07-01	medium
efb263c4-05b2-42d2-bc77-af9f0cbd846e	e35b32f7-7e12-42fe-912f-f80b60c4ace4	\N	c288bac5-e3a4-4f1f-a050-de12845acf11	e262d280-b97e-4087-8e78-a66519bae4d1	تهیهٔ گزارش سود و زیان ماهانه #16	\N	medium	2026-08-15	06af65da-1ce2-405c-beb9-00f9999e3bc8	2026-07-21 18:35:18.932907+00	2026-07-21 18:35:18.932907+00	completed	approved	100	17.10	2026-08-11	medium
efb263c4-05b2-42d2-bc77-af9f0cbd846e	e35b32f7-7e12-42fe-912f-f80b60c4ace4	\N	1c37102f-d8b4-4bea-bd82-5b862cd46e2b	e262d280-b97e-4087-8e78-a66519bae4d1	بررسی فاکتورهای فروش صادرشده #17	\N	medium	2026-08-03	47637e11-1ad4-4446-8361-78123fdd9f3a	2026-07-21 18:35:18.932907+00	2026-07-21 18:35:18.932907+00	archived	\N	73	4.80	2026-07-16	medium
efb263c4-05b2-42d2-bc77-af9f0cbd846e	e35b32f7-7e12-42fe-912f-f80b60c4ace4	\N	e73ec14e-ca0c-4615-92d5-5bc43c14999a	e262d280-b97e-4087-8e78-a66519bae4d1	تهیهٔ گزارش مالیاتی فصلی #18	\N	low	2026-08-02	c08b3f07-9cd5-48a6-b614-543fd53ca59f	2026-07-21 18:35:18.932907+00	2026-07-21 18:35:18.932907+00	completed	approved	100	35.40	2026-07-15	medium
efb263c4-05b2-42d2-bc77-af9f0cbd846e	6b87fbf4-f215-4875-9b6d-ba65c7cae7e2	\N	faf489ef-0410-4dca-bec1-65dd2fb904ba	e262d280-b97e-4087-8e78-a66519bae4d1	بررسی فاکتورهای فروش صادرشده #19	\N	high	2026-07-03	2eac4f11-9363-411e-a835-168b6fbcb7e2	2026-07-21 18:35:18.932907+00	2026-07-21 18:35:18.932907+00	completed	pending	100	36.60	2026-06-27	medium
efb263c4-05b2-42d2-bc77-af9f0cbd846e	6b87fbf4-f215-4875-9b6d-ba65c7cae7e2	\N	e262d280-b97e-4087-8e78-a66519bae4d1	e262d280-b97e-4087-8e78-a66519bae4d1	پیگیری مطالبات معوق مشتریان #20	\N	low	2026-07-25	00a95515-8cc7-4c2b-aa6b-d41882e09fca	2026-07-21 18:35:18.932907+00	2026-07-21 18:35:18.932907+00	todo	\N	20	14.30	2026-07-19	medium
efb263c4-05b2-42d2-bc77-af9f0cbd846e	6b87fbf4-f215-4875-9b6d-ba65c7cae7e2	\N	1c37102f-d8b4-4bea-bd82-5b862cd46e2b	e262d280-b97e-4087-8e78-a66519bae4d1	بررسی قراردادهای مالی جدید #21	\N	medium	2026-07-26	dbdc5b5f-eb78-4fe9-a3d1-af21873b7177	2026-07-21 18:35:18.932907+00	2026-07-21 18:35:18.932907+00	in_progress	\N	10	11.50	2026-07-08	medium
efb263c4-05b2-42d2-bc77-af9f0cbd846e	6b87fbf4-f215-4875-9b6d-ba65c7cae7e2	\N	1c37102f-d8b4-4bea-bd82-5b862cd46e2b	e262d280-b97e-4087-8e78-a66519bae4d1	بررسی صورت وضعیت پیمانکاران #22	\N	high	2026-08-06	c25344c8-3b4e-41bd-9452-662f17489692	2026-07-21 18:35:18.932907+00	2026-07-21 18:35:18.932907+00	completed	approved	100	5.60	2026-07-26	medium
efb263c4-05b2-42d2-bc77-af9f0cbd846e	6b87fbf4-f215-4875-9b6d-ba65c7cae7e2	\N	1c37102f-d8b4-4bea-bd82-5b862cd46e2b	e262d280-b97e-4087-8e78-a66519bae4d1	مغایرت‌گیری حساب‌های بانکی #23	\N	low	2026-08-12	fccbd9ee-5cbe-43a1-844c-46311686b3c9	2026-07-21 18:35:18.932907+00	2026-07-21 18:35:18.932907+00	todo	\N	79	29.40	2026-07-23	medium
efb263c4-05b2-42d2-bc77-af9f0cbd846e	6b87fbf4-f215-4875-9b6d-ba65c7cae7e2	\N	1d9f738d-866c-4e32-9fe8-b80f0b30a62b	e262d280-b97e-4087-8e78-a66519bae4d1	بررسی و تأیید صورت‌حساب‌های خرید #24	\N	low	2026-08-28	0c27ef13-8a84-4aac-bcdd-323d5fa916cc	2026-07-21 18:35:18.932907+00	2026-07-21 18:35:18.932907+00	in_progress	\N	10	3.70	2026-08-08	medium
efb263c4-05b2-42d2-bc77-af9f0cbd846e	6b87fbf4-f215-4875-9b6d-ba65c7cae7e2	\N	1c37102f-d8b4-4bea-bd82-5b862cd46e2b	e262d280-b97e-4087-8e78-a66519bae4d1	تطبیق موجودی انبار با حساب‌ها #25	\N	low	2026-08-01	6ab0ab9d-d2d6-43b9-be3a-0a6569ad194f	2026-07-21 18:35:18.932907+00	2026-07-21 18:35:18.932907+00	archived	\N	73	17.80	2026-07-22	medium
efb263c4-05b2-42d2-bc77-af9f0cbd846e	6b87fbf4-f215-4875-9b6d-ba65c7cae7e2	\N	1c37102f-d8b4-4bea-bd82-5b862cd46e2b	e262d280-b97e-4087-8e78-a66519bae4d1	پیگیری مطالبات معوق مشتریان #26	\N	high	2026-08-05	8968853d-b925-40e7-b0b7-5bb0ed565790	2026-07-21 18:35:18.932907+00	2026-07-21 18:35:18.932907+00	todo	\N	38	20.40	2026-07-17	medium
efb263c4-05b2-42d2-bc77-af9f0cbd846e	6b87fbf4-f215-4875-9b6d-ba65c7cae7e2	\N	faf489ef-0410-4dca-bec1-65dd2fb904ba	e262d280-b97e-4087-8e78-a66519bae4d1	تهیهٔ گزارش جریان نقدی #27	\N	low	2026-07-19	a7e0571d-10a2-4d1d-bce6-8e5fa2be06a6	2026-07-21 18:35:18.932907+00	2026-07-21 18:35:18.932907+00	completed	approved	100	8.00	2026-07-15	medium
efb263c4-05b2-42d2-bc77-af9f0cbd846e	6b87fbf4-f215-4875-9b6d-ba65c7cae7e2	\N	c288bac5-e3a4-4f1f-a050-de12845acf11	e262d280-b97e-4087-8e78-a66519bae4d1	مغایرت‌گیری حساب‌های بانکی #28	\N	medium	2026-07-28	3f85fa25-fb5f-4e20-9b45-86d41f11d457	2026-07-21 18:35:18.932907+00	2026-07-21 18:35:18.932907+00	completed	approved	100	34.70	2026-07-07	medium
efb263c4-05b2-42d2-bc77-af9f0cbd846e	6b87fbf4-f215-4875-9b6d-ba65c7cae7e2	\N	e73ec14e-ca0c-4615-92d5-5bc43c14999a	e262d280-b97e-4087-8e78-a66519bae4d1	بررسی فاکتورهای فروش صادرشده #29	\N	low	2026-08-23	4e03791a-b45c-43cd-89fc-cdca1b66daba	2026-07-21 18:35:18.932907+00	2026-07-21 18:35:18.932907+00	archived	\N	47	21.60	2026-08-10	medium
efb263c4-05b2-42d2-bc77-af9f0cbd846e	6b87fbf4-f215-4875-9b6d-ba65c7cae7e2	\N	e262d280-b97e-4087-8e78-a66519bae4d1	e262d280-b97e-4087-8e78-a66519bae4d1	تهیهٔ گزارش سود و زیان ماهانه #30	\N	medium	2026-07-17	2852312f-f6d1-4e39-b466-b0e92f13921d	2026-07-21 18:35:18.932907+00	2026-07-21 18:35:18.932907+00	in_progress	\N	57	11.40	2026-07-01	medium
efb263c4-05b2-42d2-bc77-af9f0cbd846e	6b87fbf4-f215-4875-9b6d-ba65c7cae7e2	\N	e262d280-b97e-4087-8e78-a66519bae4d1	e262d280-b97e-4087-8e78-a66519bae4d1	پیگیری بیمهٔ کارکنان #31	\N	high	2026-07-18	17bb2e5f-6883-46f1-a7e0-de92452b4a64	2026-07-21 18:35:18.932907+00	2026-07-21 18:35:18.932907+00	todo	\N	53	11.40	2026-07-04	medium
efb263c4-05b2-42d2-bc77-af9f0cbd846e	6b87fbf4-f215-4875-9b6d-ba65c7cae7e2	\N	faf489ef-0410-4dca-bec1-65dd2fb904ba	e262d280-b97e-4087-8e78-a66519bae4d1	بررسی قراردادهای مالی جدید #32	\N	high	2026-08-19	9059d634-04d5-48e2-97e6-49b7e9a01dc3	2026-07-21 18:35:18.932907+00	2026-07-21 18:35:18.932907+00	todo	\N	40	9.20	2026-08-07	medium
efb263c4-05b2-42d2-bc77-af9f0cbd846e	6b87fbf4-f215-4875-9b6d-ba65c7cae7e2	\N	7dcd0e37-2d6c-4eab-8a6a-3598c4e01433	e262d280-b97e-4087-8e78-a66519bae4d1	بررسی قراردادهای مالی جدید #33	\N	medium	2026-08-01	e0c94bd9-24ee-4cf5-a2cc-b6a84691e032	2026-07-21 18:35:18.932907+00	2026-07-21 18:35:18.932907+00	completed	rejected	100	20.90	2026-07-15	medium
efb263c4-05b2-42d2-bc77-af9f0cbd846e	6b87fbf4-f215-4875-9b6d-ba65c7cae7e2	\N	e262d280-b97e-4087-8e78-a66519bae4d1	e262d280-b97e-4087-8e78-a66519bae4d1	ثبت اسناد حسابداری هفتگی #34	\N	low	2026-08-03	a9563a01-036c-427e-ade8-36f60580a921	2026-07-21 18:35:18.932907+00	2026-07-21 18:35:18.932907+00	in_progress	\N	74	15.40	2026-07-18	medium
efb263c4-05b2-42d2-bc77-af9f0cbd846e	6b87fbf4-f215-4875-9b6d-ba65c7cae7e2	\N	e262d280-b97e-4087-8e78-a66519bae4d1	e262d280-b97e-4087-8e78-a66519bae4d1	بررسی قراردادهای مالی جدید #35	\N	high	2026-08-07	443949c4-d85a-4d4d-8f46-4a27cf02327c	2026-07-21 18:35:18.932907+00	2026-07-21 18:35:18.932907+00	in_progress	\N	60	12.90	2026-07-17	medium
efb263c4-05b2-42d2-bc77-af9f0cbd846e	6b87fbf4-f215-4875-9b6d-ba65c7cae7e2	\N	e262d280-b97e-4087-8e78-a66519bae4d1	e262d280-b97e-4087-8e78-a66519bae4d1	بررسی قراردادهای مالی جدید #36	\N	medium	2026-07-19	30a43208-e74b-4a4c-9a2f-7c7fda7ab840	2026-07-21 18:35:18.932907+00	2026-07-21 18:35:18.932907+00	todo	\N	46	31.00	2026-07-13	medium
efb263c4-05b2-42d2-bc77-af9f0cbd846e	009a2a44-5f53-4b44-a083-b37afdcd5b4d	\N	e73ec14e-ca0c-4615-92d5-5bc43c14999a	e262d280-b97e-4087-8e78-a66519bae4d1	بررسی صورت وضعیت پیمانکاران #37	\N	high	2026-07-14	302144bc-c972-45ff-979b-cae49a81d69f	2026-07-21 18:35:18.932907+00	2026-07-21 18:35:18.932907+00	todo	\N	24	15.80	2026-07-11	medium
efb263c4-05b2-42d2-bc77-af9f0cbd846e	009a2a44-5f53-4b44-a083-b37afdcd5b4d	\N	e73ec14e-ca0c-4615-92d5-5bc43c14999a	e262d280-b97e-4087-8e78-a66519bae4d1	به‌روزرسانی جدول حقوق و دستمزد #38	\N	high	2026-07-28	2d6d4af2-b9a6-4924-a6bc-c9b4609a2357	2026-07-21 18:35:18.932907+00	2026-07-21 18:35:18.932907+00	todo	\N	35	33.40	2026-07-10	medium
efb263c4-05b2-42d2-bc77-af9f0cbd846e	009a2a44-5f53-4b44-a083-b37afdcd5b4d	\N	1d9f738d-866c-4e32-9fe8-b80f0b30a62b	e262d280-b97e-4087-8e78-a66519bae4d1	بررسی فاکتورهای فروش صادرشده #39	\N	medium	2026-06-29	fc9c27a2-b091-433b-b48b-74cb7b339a12	2026-07-21 18:35:18.932907+00	2026-07-21 18:35:18.932907+00	completed	pending	100	32.20	2026-06-24	medium
efb263c4-05b2-42d2-bc77-af9f0cbd846e	009a2a44-5f53-4b44-a083-b37afdcd5b4d	\N	e73ec14e-ca0c-4615-92d5-5bc43c14999a	e262d280-b97e-4087-8e78-a66519bae4d1	ثبت اسناد حسابداری هفتگی #40	\N	high	2026-08-09	3d2be215-2408-4b23-9dda-25dab29e6ff5	2026-07-21 18:35:18.932907+00	2026-07-21 18:35:18.932907+00	completed	rejected	100	21.30	2026-08-03	medium
efb263c4-05b2-42d2-bc77-af9f0cbd846e	009a2a44-5f53-4b44-a083-b37afdcd5b4d	\N	1d9f738d-866c-4e32-9fe8-b80f0b30a62b	e262d280-b97e-4087-8e78-a66519bae4d1	مغایرت‌گیری حساب‌های بانکی #41	\N	high	2026-06-21	949c4887-321a-4c4e-a58f-23f790b8d543	2026-07-21 18:35:18.932907+00	2026-07-21 18:35:18.932907+00	todo	\N	42	32.60	2026-06-18	medium
efb263c4-05b2-42d2-bc77-af9f0cbd846e	009a2a44-5f53-4b44-a083-b37afdcd5b4d	\N	1d9f738d-866c-4e32-9fe8-b80f0b30a62b	e262d280-b97e-4087-8e78-a66519bae4d1	مغایرت‌گیری حساب‌های بانکی #42	\N	medium	2026-08-30	061387ea-6729-41b7-bc34-6f6f75aa20a6	2026-07-21 18:35:18.932907+00	2026-07-21 18:35:18.932907+00	completed	approved	100	37.40	2026-08-12	medium
efb263c4-05b2-42d2-bc77-af9f0cbd846e	009a2a44-5f53-4b44-a083-b37afdcd5b4d	\N	e73ec14e-ca0c-4615-92d5-5bc43c14999a	e262d280-b97e-4087-8e78-a66519bae4d1	تهیهٔ گزارش جریان نقدی #43	\N	medium	2026-08-01	ddea8bf2-fe55-4ba7-a5e2-042254fc4151	2026-07-21 18:35:18.932907+00	2026-07-21 18:35:18.932907+00	todo	\N	75	14.80	2026-07-11	medium
efb263c4-05b2-42d2-bc77-af9f0cbd846e	009a2a44-5f53-4b44-a083-b37afdcd5b4d	\N	faf489ef-0410-4dca-bec1-65dd2fb904ba	e262d280-b97e-4087-8e78-a66519bae4d1	پیگیری مطالبات معوق مشتریان #44	\N	medium	2026-08-20	25de42a2-b7e6-402d-b89b-8ac93239ff6d	2026-07-21 18:35:18.932907+00	2026-07-21 18:35:18.932907+00	completed	approved	100	33.00	2026-07-31	medium
efb263c4-05b2-42d2-bc77-af9f0cbd846e	009a2a44-5f53-4b44-a083-b37afdcd5b4d	\N	e73ec14e-ca0c-4615-92d5-5bc43c14999a	e262d280-b97e-4087-8e78-a66519bae4d1	بررسی فاکتورهای فروش صادرشده #45	\N	high	2026-08-03	888303ad-666d-498d-a8b1-7f0269dba779	2026-07-21 18:35:18.932907+00	2026-07-21 18:35:18.932907+00	in_progress	\N	39	32.30	2026-07-29	medium
efb263c4-05b2-42d2-bc77-af9f0cbd846e	009a2a44-5f53-4b44-a083-b37afdcd5b4d	\N	1c37102f-d8b4-4bea-bd82-5b862cd46e2b	e262d280-b97e-4087-8e78-a66519bae4d1	پیگیری مطالبات معوق مشتریان #46	\N	high	2026-08-10	f328986f-35ff-4b68-979e-ac51e0dc3fe2	2026-07-21 18:35:18.932907+00	2026-07-21 18:35:18.932907+00	completed	pending	100	31.80	2026-07-24	medium
efb263c4-05b2-42d2-bc77-af9f0cbd846e	009a2a44-5f53-4b44-a083-b37afdcd5b4d	\N	faf489ef-0410-4dca-bec1-65dd2fb904ba	e262d280-b97e-4087-8e78-a66519bae4d1	بررسی صورت وضعیت پیمانکاران #47	\N	medium	2026-08-04	8263a9d6-34f0-41fd-b8d7-aac8a3ffc2ec	2026-07-21 18:35:18.932907+00	2026-07-21 18:35:18.932907+00	completed	approved	100	8.50	2026-08-01	medium
efb263c4-05b2-42d2-bc77-af9f0cbd846e	009a2a44-5f53-4b44-a083-b37afdcd5b4d	\N	1c37102f-d8b4-4bea-bd82-5b862cd46e2b	e262d280-b97e-4087-8e78-a66519bae4d1	مغایرت‌گیری حساب‌های بانکی #48	\N	high	2026-08-08	45ee5568-2972-4ca1-b419-7856f78c2315	2026-07-21 18:35:18.932907+00	2026-07-21 18:35:18.932907+00	archived	\N	31	3.20	2026-07-25	medium
efb263c4-05b2-42d2-bc77-af9f0cbd846e	009a2a44-5f53-4b44-a083-b37afdcd5b4d	\N	1c37102f-d8b4-4bea-bd82-5b862cd46e2b	e262d280-b97e-4087-8e78-a66519bae4d1	به‌روزرسانی جدول حقوق و دستمزد #49	\N	medium	2026-06-30	73c730d7-09ac-42ea-826f-12ccca6afded	2026-07-21 18:35:18.932907+00	2026-07-21 18:35:18.932907+00	todo	\N	53	7.80	2026-06-28	medium
efb263c4-05b2-42d2-bc77-af9f0cbd846e	009a2a44-5f53-4b44-a083-b37afdcd5b4d	\N	1c37102f-d8b4-4bea-bd82-5b862cd46e2b	e262d280-b97e-4087-8e78-a66519bae4d1	بررسی و تسویهٔ کارت اعتباری شرکت #50	\N	high	2026-07-30	f997864a-36e5-4fdb-9fc3-64d0e1f084da	2026-07-21 18:35:18.932907+00	2026-07-21 18:35:18.932907+00	in_progress	\N	60	35.20	2026-07-12	medium
efb263c4-05b2-42d2-bc77-af9f0cbd846e	009a2a44-5f53-4b44-a083-b37afdcd5b4d	\N	1c37102f-d8b4-4bea-bd82-5b862cd46e2b	e262d280-b97e-4087-8e78-a66519bae4d1	تهیهٔ پیش‌نویس بودجهٔ واحد #51	\N	low	2026-06-25	3b2ddafb-cf85-460c-81c2-033f4dd6af90	2026-07-21 18:35:18.932907+00	2026-07-21 18:35:18.932907+00	archived	\N	71	14.40	2026-06-19	medium
efb263c4-05b2-42d2-bc77-af9f0cbd846e	009a2a44-5f53-4b44-a083-b37afdcd5b4d	\N	1c37102f-d8b4-4bea-bd82-5b862cd46e2b	e262d280-b97e-4087-8e78-a66519bae4d1	به‌روزرسانی جدول حقوق و دستمزد #52	\N	high	2026-07-13	e112eaac-5914-4e6d-9a6c-889375357a3d	2026-07-21 18:35:18.932907+00	2026-07-21 18:35:18.932907+00	completed	approved	100	15.00	2026-07-06	medium
efb263c4-05b2-42d2-bc77-af9f0cbd846e	009a2a44-5f53-4b44-a083-b37afdcd5b4d	\N	e73ec14e-ca0c-4615-92d5-5bc43c14999a	e262d280-b97e-4087-8e78-a66519bae4d1	بررسی صورت وضعیت پیمانکاران #53	\N	medium	2026-08-11	b56bc6c2-3669-4ad2-a35e-aaf256ab2df3	2026-07-21 18:35:18.932907+00	2026-07-21 18:35:18.932907+00	completed	pending	100	9.30	2026-08-01	medium
efb263c4-05b2-42d2-bc77-af9f0cbd846e	009a2a44-5f53-4b44-a083-b37afdcd5b4d	\N	7dcd0e37-2d6c-4eab-8a6a-3598c4e01433	e262d280-b97e-4087-8e78-a66519bae4d1	ثبت اسناد حسابداری هفتگی #54	\N	medium	2026-08-01	110663bf-7858-466a-a4d8-6d6ab83c284d	2026-07-21 18:35:18.932907+00	2026-07-21 18:35:18.932907+00	in_progress	\N	36	28.80	2026-07-21	medium
efb263c4-05b2-42d2-bc77-af9f0cbd846e	e2872a09-ca5b-4560-b31c-9639fc42eeb2	\N	1c37102f-d8b4-4bea-bd82-5b862cd46e2b	e262d280-b97e-4087-8e78-a66519bae4d1	به‌روزرسانی جدول حقوق و دستمزد #55	\N	medium	2026-07-29	15bd443f-1c58-4b82-b933-3f3dbd15ad26	2026-07-21 18:35:18.932907+00	2026-07-21 18:35:18.932907+00	archived	\N	71	37.50	2026-07-17	medium
efb263c4-05b2-42d2-bc77-af9f0cbd846e	e2872a09-ca5b-4560-b31c-9639fc42eeb2	\N	faf489ef-0410-4dca-bec1-65dd2fb904ba	e262d280-b97e-4087-8e78-a66519bae4d1	تهیهٔ گزارش سود و زیان ماهانه #56	\N	high	2026-07-14	5a0c3ad0-c55e-4a09-ac80-555a3586e715	2026-07-21 18:35:18.932907+00	2026-07-21 18:35:18.932907+00	archived	\N	69	16.40	2026-07-03	medium
efb263c4-05b2-42d2-bc77-af9f0cbd846e	e2872a09-ca5b-4560-b31c-9639fc42eeb2	\N	c288bac5-e3a4-4f1f-a050-de12845acf11	e262d280-b97e-4087-8e78-a66519bae4d1	پیگیری مطالبات معوق مشتریان #57	\N	low	2026-08-10	e7cc4676-81c6-430b-bce1-39ba5b5927a1	2026-07-21 18:35:18.932907+00	2026-07-21 18:35:18.932907+00	in_progress	\N	36	38.30	2026-08-04	medium
efb263c4-05b2-42d2-bc77-af9f0cbd846e	e2872a09-ca5b-4560-b31c-9639fc42eeb2	\N	e262d280-b97e-4087-8e78-a66519bae4d1	e262d280-b97e-4087-8e78-a66519bae4d1	تطبیق موجودی انبار با حساب‌ها #58	\N	medium	2026-08-30	71b9390b-6f92-4150-954f-48a43c9b9af0	2026-07-21 18:35:18.932907+00	2026-07-21 18:35:18.932907+00	in_progress	\N	61	10.10	2026-08-14	medium
efb263c4-05b2-42d2-bc77-af9f0cbd846e	e2872a09-ca5b-4560-b31c-9639fc42eeb2	\N	faf489ef-0410-4dca-bec1-65dd2fb904ba	e262d280-b97e-4087-8e78-a66519bae4d1	مغایرت‌گیری حساب‌های بانکی #59	\N	low	2026-07-31	82ccc342-d80e-4c98-a0bc-883d9b740ce6	2026-07-21 18:35:18.932907+00	2026-07-21 18:35:18.932907+00	completed	approved	100	25.40	2026-07-21	medium
efb263c4-05b2-42d2-bc77-af9f0cbd846e	e2872a09-ca5b-4560-b31c-9639fc42eeb2	\N	1d9f738d-866c-4e32-9fe8-b80f0b30a62b	e262d280-b97e-4087-8e78-a66519bae4d1	تطبیق موجودی انبار با حساب‌ها #60	\N	high	2026-07-04	78245f50-9f95-4855-a82b-9395d159212a	2026-07-21 18:35:18.932907+00	2026-07-21 18:35:18.932907+00	in_progress	\N	28	26.20	2026-07-01	medium
efb263c4-05b2-42d2-bc77-af9f0cbd846e	e2872a09-ca5b-4560-b31c-9639fc42eeb2	\N	e262d280-b97e-4087-8e78-a66519bae4d1	e262d280-b97e-4087-8e78-a66519bae4d1	تهیهٔ گزارش جریان نقدی #61	\N	medium	2026-07-24	cbf1dee9-89f1-4180-85f4-d17c00e8496c	2026-07-21 18:35:18.932907+00	2026-07-21 18:35:18.932907+00	todo	\N	12	27.90	2026-07-12	medium
efb263c4-05b2-42d2-bc77-af9f0cbd846e	e2872a09-ca5b-4560-b31c-9639fc42eeb2	\N	7dcd0e37-2d6c-4eab-8a6a-3598c4e01433	e262d280-b97e-4087-8e78-a66519bae4d1	بررسی فاکتورهای فروش صادرشده #62	\N	high	2026-07-28	50983d51-c1cd-4e35-842f-f78c2e69a6c8	2026-07-21 18:35:18.932907+00	2026-07-21 18:35:18.932907+00	todo	\N	60	20.10	2026-07-21	medium
efb263c4-05b2-42d2-bc77-af9f0cbd846e	e2872a09-ca5b-4560-b31c-9639fc42eeb2	\N	7dcd0e37-2d6c-4eab-8a6a-3598c4e01433	e262d280-b97e-4087-8e78-a66519bae4d1	پیگیری مطالبات معوق مشتریان #63	\N	high	2026-07-16	31d5b0cc-0bea-4135-a4d9-e98eaaa61148	2026-07-21 18:35:18.932907+00	2026-07-21 18:35:18.932907+00	archived	\N	7	36.50	2026-07-04	medium
efb263c4-05b2-42d2-bc77-af9f0cbd846e	e2872a09-ca5b-4560-b31c-9639fc42eeb2	\N	e262d280-b97e-4087-8e78-a66519bae4d1	e262d280-b97e-4087-8e78-a66519bae4d1	بررسی قراردادهای مالی جدید #64	\N	low	2026-07-23	fea5dc03-3e76-4b65-be14-4a248c0c7a8f	2026-07-21 18:35:18.932907+00	2026-07-21 18:35:18.932907+00	completed	approved	100	17.90	2026-07-20	medium
efb263c4-05b2-42d2-bc77-af9f0cbd846e	e2872a09-ca5b-4560-b31c-9639fc42eeb2	\N	faf489ef-0410-4dca-bec1-65dd2fb904ba	e262d280-b97e-4087-8e78-a66519bae4d1	پیگیری بیمهٔ کارکنان #65	\N	medium	2026-08-17	473bee2a-a5e0-4413-918f-695a31ad0b56	2026-07-21 18:35:18.932907+00	2026-07-21 18:35:18.932907+00	todo	\N	63	9.10	2026-08-14	medium
efb263c4-05b2-42d2-bc77-af9f0cbd846e	e2872a09-ca5b-4560-b31c-9639fc42eeb2	\N	1c37102f-d8b4-4bea-bd82-5b862cd46e2b	e262d280-b97e-4087-8e78-a66519bae4d1	بررسی و تأیید صورت‌حساب‌های خرید #66	\N	medium	2026-08-14	b454f7e0-49b2-457d-a74f-e7473510df34	2026-07-21 18:35:18.932907+00	2026-07-21 18:35:18.932907+00	in_progress	\N	72	24.90	2026-08-11	medium
efb263c4-05b2-42d2-bc77-af9f0cbd846e	e2872a09-ca5b-4560-b31c-9639fc42eeb2	\N	e73ec14e-ca0c-4615-92d5-5bc43c14999a	e262d280-b97e-4087-8e78-a66519bae4d1	تهیهٔ پیش‌نویس بودجهٔ واحد #67	\N	medium	2026-08-03	27885bbd-aa1e-4479-b8c7-9838c0900aa9	2026-07-21 18:35:18.932907+00	2026-07-21 18:35:18.932907+00	in_progress	\N	17	34.30	2026-07-15	medium
efb263c4-05b2-42d2-bc77-af9f0cbd846e	e2872a09-ca5b-4560-b31c-9639fc42eeb2	\N	c288bac5-e3a4-4f1f-a050-de12845acf11	e262d280-b97e-4087-8e78-a66519bae4d1	تهیهٔ گزارش مالیاتی فصلی #68	\N	low	2026-07-03	9153f009-744b-427f-a0ed-6ef1d88683c8	2026-07-21 18:35:18.932907+00	2026-07-21 18:35:18.932907+00	in_progress	\N	58	26.60	2026-06-28	medium
efb263c4-05b2-42d2-bc77-af9f0cbd846e	e2872a09-ca5b-4560-b31c-9639fc42eeb2	\N	1c37102f-d8b4-4bea-bd82-5b862cd46e2b	e262d280-b97e-4087-8e78-a66519bae4d1	بررسی و تسویهٔ کارت اعتباری شرکت #69	\N	medium	2026-06-28	2617dcdb-d385-4de4-863b-7e45eb8fa738	2026-07-21 18:35:18.932907+00	2026-07-21 18:35:18.932907+00	todo	\N	72	27.60	2026-06-16	medium
efb263c4-05b2-42d2-bc77-af9f0cbd846e	e2872a09-ca5b-4560-b31c-9639fc42eeb2	\N	7dcd0e37-2d6c-4eab-8a6a-3598c4e01433	e262d280-b97e-4087-8e78-a66519bae4d1	پیگیری بیمهٔ کارکنان #70	\N	medium	2026-08-08	eeefa894-4c0f-4999-8640-045497c09215	2026-07-21 18:35:18.932907+00	2026-07-21 18:35:18.932907+00	todo	\N	65	14.50	2026-07-25	medium
efb263c4-05b2-42d2-bc77-af9f0cbd846e	e2872a09-ca5b-4560-b31c-9639fc42eeb2	\N	c288bac5-e3a4-4f1f-a050-de12845acf11	e262d280-b97e-4087-8e78-a66519bae4d1	تهیهٔ گزارش مالیاتی فصلی #71	\N	low	2026-07-11	fc23ecfd-d090-489e-8e9b-28eb2056c4e6	2026-07-21 18:35:18.932907+00	2026-07-21 18:35:18.932907+00	completed	approved	100	2.30	2026-06-24	medium
efb263c4-05b2-42d2-bc77-af9f0cbd846e	e2872a09-ca5b-4560-b31c-9639fc42eeb2	\N	c288bac5-e3a4-4f1f-a050-de12845acf11	e262d280-b97e-4087-8e78-a66519bae4d1	تهیهٔ گزارش مالیاتی فصلی #72	\N	medium	2026-07-24	daf690b2-f62b-4a5c-b566-d5d1c69d9c18	2026-07-21 18:35:18.932907+00	2026-07-21 18:35:18.932907+00	in_progress	\N	74	29.50	2026-07-14	medium
efb263c4-05b2-42d2-bc77-af9f0cbd846e	53b4a7c0-5ff9-4b29-a337-82321def0955	\N	e262d280-b97e-4087-8e78-a66519bae4d1	e262d280-b97e-4087-8e78-a66519bae4d1	تهیهٔ گزارش جریان نقدی #73	\N	low	2026-08-09	03b62107-913a-4a84-9e12-2781603405a3	2026-07-21 18:35:18.932907+00	2026-07-21 18:35:18.932907+00	in_progress	\N	7	27.40	2026-07-27	medium
efb263c4-05b2-42d2-bc77-af9f0cbd846e	53b4a7c0-5ff9-4b29-a337-82321def0955	\N	c288bac5-e3a4-4f1f-a050-de12845acf11	e262d280-b97e-4087-8e78-a66519bae4d1	تطبیق موجودی انبار با حساب‌ها #74	\N	high	2026-07-10	968d800b-6e71-47aa-8117-1055ba4b3d11	2026-07-21 18:35:18.932907+00	2026-07-21 18:35:18.932907+00	in_progress	\N	39	28.20	2026-06-26	medium
efb263c4-05b2-42d2-bc77-af9f0cbd846e	53b4a7c0-5ff9-4b29-a337-82321def0955	\N	1c37102f-d8b4-4bea-bd82-5b862cd46e2b	e262d280-b97e-4087-8e78-a66519bae4d1	ثبت اسناد حسابداری هفتگی #75	\N	low	2026-07-30	e30b7dab-fa94-41fb-96c8-501d1c828ae2	2026-07-21 18:35:18.932907+00	2026-07-21 18:35:18.932907+00	in_progress	\N	17	20.20	2026-07-09	medium
efb263c4-05b2-42d2-bc77-af9f0cbd846e	53b4a7c0-5ff9-4b29-a337-82321def0955	\N	c288bac5-e3a4-4f1f-a050-de12845acf11	e262d280-b97e-4087-8e78-a66519bae4d1	بررسی فاکتورهای فروش صادرشده #76	\N	high	2026-08-06	13715022-72ea-4b63-8300-90cf3c6717bb	2026-07-21 18:35:18.932907+00	2026-07-21 18:35:18.932907+00	archived	\N	70	36.70	2026-07-24	medium
efb263c4-05b2-42d2-bc77-af9f0cbd846e	53b4a7c0-5ff9-4b29-a337-82321def0955	\N	faf489ef-0410-4dca-bec1-65dd2fb904ba	e262d280-b97e-4087-8e78-a66519bae4d1	بررسی و تسویهٔ کارت اعتباری شرکت #77	\N	low	2026-08-15	55e7f6c9-ab93-4352-aa7d-c90ce96b6be6	2026-07-21 18:35:18.932907+00	2026-07-21 18:35:18.932907+00	completed	pending	100	27.90	2026-08-07	medium
efb263c4-05b2-42d2-bc77-af9f0cbd846e	53b4a7c0-5ff9-4b29-a337-82321def0955	\N	1d9f738d-866c-4e32-9fe8-b80f0b30a62b	e262d280-b97e-4087-8e78-a66519bae4d1	تهیهٔ پیش‌نویس بودجهٔ واحد #78	\N	high	2026-08-04	35a7d2c2-4610-40d2-b223-55e3228eeb02	2026-07-21 18:35:18.932907+00	2026-07-21 18:35:18.932907+00	todo	\N	46	5.00	2026-07-19	medium
efb263c4-05b2-42d2-bc77-af9f0cbd846e	53b4a7c0-5ff9-4b29-a337-82321def0955	\N	1d9f738d-866c-4e32-9fe8-b80f0b30a62b	e262d280-b97e-4087-8e78-a66519bae4d1	بررسی قراردادهای مالی جدید #79	\N	high	2026-07-08	9d676c5e-cf03-4418-8cff-1cabefdc6d74	2026-07-21 18:35:18.932907+00	2026-07-21 18:35:18.932907+00	todo	\N	25	23.80	2026-06-19	medium
efb263c4-05b2-42d2-bc77-af9f0cbd846e	53b4a7c0-5ff9-4b29-a337-82321def0955	\N	7dcd0e37-2d6c-4eab-8a6a-3598c4e01433	e262d280-b97e-4087-8e78-a66519bae4d1	به‌روزرسانی جدول حقوق و دستمزد #80	\N	low	2026-07-24	d52f72bc-24d2-4d7d-aa5c-843ba3c02d30	2026-07-21 18:35:18.932907+00	2026-07-21 18:35:18.932907+00	todo	\N	26	29.20	2026-07-06	medium
efb263c4-05b2-42d2-bc77-af9f0cbd846e	53b4a7c0-5ff9-4b29-a337-82321def0955	\N	c288bac5-e3a4-4f1f-a050-de12845acf11	e262d280-b97e-4087-8e78-a66519bae4d1	به‌روزرسانی جدول حقوق و دستمزد #81	\N	low	2026-08-30	7d723d25-7c9a-43c2-a740-049eaab0b95f	2026-07-21 18:35:18.932907+00	2026-07-21 18:35:18.932907+00	todo	\N	58	7.00	2026-08-12	medium
efb263c4-05b2-42d2-bc77-af9f0cbd846e	53b4a7c0-5ff9-4b29-a337-82321def0955	\N	c288bac5-e3a4-4f1f-a050-de12845acf11	e262d280-b97e-4087-8e78-a66519bae4d1	تطبیق موجودی انبار با حساب‌ها #82	\N	medium	2026-08-06	edfaad63-64ef-44d3-bab3-5051742ac16d	2026-07-21 18:35:18.932907+00	2026-07-21 18:35:18.932907+00	completed	approved	100	29.50	2026-07-21	medium
efb263c4-05b2-42d2-bc77-af9f0cbd846e	53b4a7c0-5ff9-4b29-a337-82321def0955	\N	c288bac5-e3a4-4f1f-a050-de12845acf11	e262d280-b97e-4087-8e78-a66519bae4d1	تهیهٔ گزارش جریان نقدی #83	\N	low	2026-08-09	1ec5d985-c518-4e2e-ba2d-07978f8ed220	2026-07-21 18:35:18.932907+00	2026-07-21 18:35:18.932907+00	in_progress	\N	74	4.80	2026-08-07	medium
efb263c4-05b2-42d2-bc77-af9f0cbd846e	53b4a7c0-5ff9-4b29-a337-82321def0955	\N	c288bac5-e3a4-4f1f-a050-de12845acf11	e262d280-b97e-4087-8e78-a66519bae4d1	تهیهٔ پیش‌نویس بودجهٔ واحد #84	\N	low	2026-08-03	d47b8fd7-706a-4a6c-af44-72409f357990	2026-07-21 18:35:18.932907+00	2026-07-21 18:35:18.932907+00	in_progress	\N	8	39.50	2026-07-30	medium
efb263c4-05b2-42d2-bc77-af9f0cbd846e	53b4a7c0-5ff9-4b29-a337-82321def0955	\N	c288bac5-e3a4-4f1f-a050-de12845acf11	e262d280-b97e-4087-8e78-a66519bae4d1	مغایرت‌گیری حساب‌های بانکی #85	\N	low	2026-07-19	774523be-3294-4266-985b-4d36bc7dbb1e	2026-07-21 18:35:18.932907+00	2026-07-21 18:35:18.932907+00	todo	\N	53	16.20	2026-07-04	medium
efb263c4-05b2-42d2-bc77-af9f0cbd846e	53b4a7c0-5ff9-4b29-a337-82321def0955	\N	c288bac5-e3a4-4f1f-a050-de12845acf11	e262d280-b97e-4087-8e78-a66519bae4d1	بررسی فاکتورهای فروش صادرشده #86	\N	low	2026-08-27	8ca10d05-0530-41a2-8542-a11f8e7907d2	2026-07-21 18:35:18.932907+00	2026-07-21 18:35:18.932907+00	completed	pending	100	27.90	2026-08-13	medium
efb263c4-05b2-42d2-bc77-af9f0cbd846e	53b4a7c0-5ff9-4b29-a337-82321def0955	\N	1c37102f-d8b4-4bea-bd82-5b862cd46e2b	e262d280-b97e-4087-8e78-a66519bae4d1	تهیهٔ گزارش سود و زیان ماهانه #87	\N	low	2026-08-23	d2141cf0-81bf-4684-aff7-19f7c886fbd5	2026-07-21 18:35:18.932907+00	2026-07-21 18:35:18.932907+00	completed	approved	100	39.70	2026-08-10	medium
efb263c4-05b2-42d2-bc77-af9f0cbd846e	53b4a7c0-5ff9-4b29-a337-82321def0955	\N	c288bac5-e3a4-4f1f-a050-de12845acf11	e262d280-b97e-4087-8e78-a66519bae4d1	بررسی و تسویهٔ کارت اعتباری شرکت #88	\N	low	2026-07-02	544f4a3f-f4bd-47fc-9547-08406cfdfced	2026-07-21 18:35:18.932907+00	2026-07-21 18:35:18.932907+00	completed	approved	100	39.20	2026-06-30	medium
efb263c4-05b2-42d2-bc77-af9f0cbd846e	53b4a7c0-5ff9-4b29-a337-82321def0955	\N	c288bac5-e3a4-4f1f-a050-de12845acf11	e262d280-b97e-4087-8e78-a66519bae4d1	بررسی فاکتورهای فروش صادرشده #89	\N	low	2026-08-01	ba7c0c05-1326-4d2e-b956-58934e8b9cae	2026-07-21 18:35:18.932907+00	2026-07-21 18:35:18.932907+00	completed	pending	100	11.40	2026-07-13	medium
efb263c4-05b2-42d2-bc77-af9f0cbd846e	53b4a7c0-5ff9-4b29-a337-82321def0955	\N	e73ec14e-ca0c-4615-92d5-5bc43c14999a	e262d280-b97e-4087-8e78-a66519bae4d1	بررسی قراردادهای مالی جدید #90	\N	high	2026-07-11	75dfb8c0-4532-4a77-b8e5-d847cf20bc3b	2026-07-21 18:35:18.932907+00	2026-07-21 18:35:18.932907+00	todo	\N	14	3.20	2026-07-03	medium
efb263c4-05b2-42d2-bc77-af9f0cbd846e	\N	\N	1c37102f-d8b4-4bea-bd82-5b862cd46e2b	1c37102f-d8b4-4bea-bd82-5b862cd46e2b	ثبت اسناد حسابداری هفتگی #91	\N	low	2026-07-27	70999110-8650-4a8c-b996-d7a8f0409f66	2026-07-21 18:35:18.932907+00	2026-07-21 18:35:18.932907+00	in_progress	\N	8	5.80	2026-07-25	medium
efb263c4-05b2-42d2-bc77-af9f0cbd846e	\N	\N	e262d280-b97e-4087-8e78-a66519bae4d1	e262d280-b97e-4087-8e78-a66519bae4d1	ثبت اسناد حسابداری هفتگی #92	\N	high	2026-08-03	467bd0e9-6bf1-4ed3-8cc4-2bf94a39139a	2026-07-21 18:35:18.932907+00	2026-07-21 18:35:18.932907+00	completed	approved	100	3.70	2026-07-31	medium
efb263c4-05b2-42d2-bc77-af9f0cbd846e	\N	\N	c288bac5-e3a4-4f1f-a050-de12845acf11	c288bac5-e3a4-4f1f-a050-de12845acf11	بررسی و تسویهٔ کارت اعتباری شرکت #93	\N	low	2026-07-28	d97aa84e-a1fc-4ad4-8985-6fa18bc40e94	2026-07-21 18:35:18.932907+00	2026-07-21 18:35:18.932907+00	in_progress	\N	17	21.10	2026-07-20	medium
efb263c4-05b2-42d2-bc77-af9f0cbd846e	\N	\N	e73ec14e-ca0c-4615-92d5-5bc43c14999a	e73ec14e-ca0c-4615-92d5-5bc43c14999a	تهیهٔ گزارش مالیاتی فصلی #94	\N	high	2026-08-27	faea8981-516d-4c7b-9150-42ff706a58c8	2026-07-21 18:35:18.932907+00	2026-07-21 18:35:18.932907+00	in_progress	\N	76	31.40	2026-08-07	medium
efb263c4-05b2-42d2-bc77-af9f0cbd846e	\N	\N	faf489ef-0410-4dca-bec1-65dd2fb904ba	faf489ef-0410-4dca-bec1-65dd2fb904ba	بررسی قراردادهای مالی جدید #95	\N	low	2026-07-12	ed644312-db89-439e-b70b-9a22a4c6364c	2026-07-21 18:35:18.932907+00	2026-07-21 18:35:18.932907+00	in_progress	\N	66	10.40	2026-07-01	medium
efb263c4-05b2-42d2-bc77-af9f0cbd846e	\N	\N	e73ec14e-ca0c-4615-92d5-5bc43c14999a	e73ec14e-ca0c-4615-92d5-5bc43c14999a	بررسی صورت وضعیت پیمانکاران #96	\N	high	2026-07-08	32091cbb-b9a5-4dc9-ba32-a5d7bf51216b	2026-07-21 18:35:18.932907+00	2026-07-21 18:35:18.932907+00	in_progress	\N	22	25.80	2026-06-19	medium
efb263c4-05b2-42d2-bc77-af9f0cbd846e	\N	\N	c288bac5-e3a4-4f1f-a050-de12845acf11	c288bac5-e3a4-4f1f-a050-de12845acf11	بررسی و تسویهٔ کارت اعتباری شرکت #97	\N	high	2026-07-22	468e8ffd-1f2a-494e-91cb-3f36317389c8	2026-07-21 18:35:18.932907+00	2026-07-21 18:35:18.932907+00	completed	approved	100	14.10	2026-07-08	medium
efb263c4-05b2-42d2-bc77-af9f0cbd846e	\N	\N	c288bac5-e3a4-4f1f-a050-de12845acf11	c288bac5-e3a4-4f1f-a050-de12845acf11	بررسی فاکتورهای فروش صادرشده #98	\N	low	2026-07-06	2d552189-1da8-426f-b59c-7720020591db	2026-07-21 18:35:18.932907+00	2026-07-21 18:35:18.932907+00	in_progress	\N	68	20.00	2026-06-25	medium
efb263c4-05b2-42d2-bc77-af9f0cbd846e	\N	\N	faf489ef-0410-4dca-bec1-65dd2fb904ba	faf489ef-0410-4dca-bec1-65dd2fb904ba	بررسی و تسویهٔ کارت اعتباری شرکت #99	\N	medium	2026-07-11	c5ca0f17-9de8-4302-b3aa-8d4fe30f442e	2026-07-21 18:35:18.932907+00	2026-07-21 18:35:18.932907+00	in_progress	\N	7	23.40	2026-07-05	medium
efb263c4-05b2-42d2-bc77-af9f0cbd846e	\N	\N	c288bac5-e3a4-4f1f-a050-de12845acf11	c288bac5-e3a4-4f1f-a050-de12845acf11	پیگیری مطالبات معوق مشتریان #100	\N	low	2026-07-19	907b0366-6731-4c71-8179-2a14e2c2c863	2026-07-21 18:35:18.932907+00	2026-07-21 18:35:18.932907+00	completed	approved	100	14.50	2026-07-10	medium
efb263c4-05b2-42d2-bc77-af9f0cbd846e	\N	\N	e262d280-b97e-4087-8e78-a66519bae4d1	e262d280-b97e-4087-8e78-a66519bae4d1	تهیهٔ گزارش جریان نقدی #101	\N	low	2026-07-10	b7203177-a7c2-4bd2-821b-6ba5d58d5a96	2026-07-21 18:35:18.932907+00	2026-07-21 18:35:18.932907+00	completed	pending	100	4.00	2026-06-21	medium
efb263c4-05b2-42d2-bc77-af9f0cbd846e	\N	\N	c288bac5-e3a4-4f1f-a050-de12845acf11	c288bac5-e3a4-4f1f-a050-de12845acf11	ثبت اسناد حسابداری هفتگی #102	\N	high	2026-06-22	107f6541-f82e-4f29-8be2-5e624ce04d16	2026-07-21 18:35:18.932907+00	2026-07-21 18:35:18.932907+00	completed	pending	100	29.50	2026-06-18	medium
efb263c4-05b2-42d2-bc77-af9f0cbd846e	\N	\N	1d9f738d-866c-4e32-9fe8-b80f0b30a62b	1d9f738d-866c-4e32-9fe8-b80f0b30a62b	پیگیری بیمهٔ کارکنان #103	\N	medium	2026-07-24	21726a7c-90e3-4517-834e-4d7e1eb13abb	2026-07-21 18:35:18.932907+00	2026-07-21 18:35:18.932907+00	in_progress	\N	38	38.40	2026-07-16	medium
efb263c4-05b2-42d2-bc77-af9f0cbd846e	\N	\N	e262d280-b97e-4087-8e78-a66519bae4d1	e262d280-b97e-4087-8e78-a66519bae4d1	تهیهٔ گزارش جریان نقدی #104	\N	low	2026-08-22	f7374ca9-2a7e-454b-a979-dc35709b5e48	2026-07-21 18:35:18.932907+00	2026-07-21 18:35:18.932907+00	in_progress	\N	61	36.70	2026-08-14	medium
efb263c4-05b2-42d2-bc77-af9f0cbd846e	\N	\N	1c37102f-d8b4-4bea-bd82-5b862cd46e2b	1c37102f-d8b4-4bea-bd82-5b862cd46e2b	تهیهٔ پیش‌نویس بودجهٔ واحد #105	\N	medium	2026-07-20	871b54fe-a37f-4e8d-8c51-398c4f3d5206	2026-07-21 18:35:18.932907+00	2026-07-21 18:35:18.932907+00	completed	pending	100	31.50	2026-07-11	medium
efb263c4-05b2-42d2-bc77-af9f0cbd846e	4554595d-9245-40e3-b08c-d872099d1fc1	\N	89f48814-745b-462e-820c-aff4124c3949	89f48814-745b-462e-820c-aff4124c3949	برگزاری نظرسنجی رضایت شغلی #1	\N	low	2026-07-29	5a077522-3c40-45d9-91ee-299369083cbf	2026-07-21 18:35:18.932907+00	2026-07-21 18:35:18.932907+00	todo	\N	67	34.70	2026-07-23	medium
efb263c4-05b2-42d2-bc77-af9f0cbd846e	4554595d-9245-40e3-b08c-d872099d1fc1	\N	89f48814-745b-462e-820c-aff4124c3949	89f48814-745b-462e-820c-aff4124c3949	تدوین برنامهٔ آموزشی سال آینده #2	\N	low	2026-08-14	5907d363-cd92-4ba6-be90-26658facfb10	2026-07-21 18:35:18.932907+00	2026-07-21 18:35:18.932907+00	in_progress	\N	43	13.50	2026-07-31	medium
efb263c4-05b2-42d2-bc77-af9f0cbd846e	4554595d-9245-40e3-b08c-d872099d1fc1	\N	63d308ce-8593-4f45-8c4b-1df63a00732c	89f48814-745b-462e-820c-aff4124c3949	برگزاری نظرسنجی رضایت شغلی #3	\N	high	2026-08-16	588f848c-223c-4f61-ab09-d71d081cb6a1	2026-07-21 18:35:18.932907+00	2026-07-21 18:35:18.932907+00	todo	\N	62	26.70	2026-08-01	medium
efb263c4-05b2-42d2-bc77-af9f0cbd846e	4554595d-9245-40e3-b08c-d872099d1fc1	\N	63d308ce-8593-4f45-8c4b-1df63a00732c	89f48814-745b-462e-820c-aff4124c3949	برگزاری نظرسنجی رضایت شغلی #4	\N	medium	2026-08-11	995bc8fb-cd08-49cf-b653-14ee6e9e976f	2026-07-21 18:35:18.932907+00	2026-07-21 18:35:18.932907+00	archived	\N	28	27.30	2026-07-21	medium
efb263c4-05b2-42d2-bc77-af9f0cbd846e	4554595d-9245-40e3-b08c-d872099d1fc1	\N	4bfc028f-1c19-4b0c-9188-9fe233b49cb4	89f48814-745b-462e-820c-aff4124c3949	به‌روزرسانی پروندهٔ پرسنلی #5	\N	high	2026-07-21	45fabe28-7252-45ff-b265-42e9b68bef44	2026-07-21 18:35:18.932907+00	2026-07-21 18:35:18.932907+00	todo	\N	37	6.80	2026-07-10	medium
efb263c4-05b2-42d2-bc77-af9f0cbd846e	4554595d-9245-40e3-b08c-d872099d1fc1	\N	e38a8fbd-4c9d-4475-ae1b-150a034a6936	89f48814-745b-462e-820c-aff4124c3949	تهیهٔ فرم ارزیابی سه‌ماهه #6	\N	high	2026-09-04	800b58ab-2d8c-4a81-a578-bb2ecf2f8f16	2026-07-21 18:35:18.932907+00	2026-07-21 18:35:18.932907+00	todo	\N	4	8.90	2026-08-15	medium
efb263c4-05b2-42d2-bc77-af9f0cbd846e	4554595d-9245-40e3-b08c-d872099d1fc1	\N	d9facd7e-b4bd-497f-9f4f-f75e6a932da0	89f48814-745b-462e-820c-aff4124c3949	بررسی درخواست ترفیع کارکنان #7	\N	medium	2026-07-27	71084f62-63bc-46bc-86b6-0faaba87417d	2026-07-21 18:35:18.932907+00	2026-07-21 18:35:18.932907+00	completed	approved	100	7.30	2026-07-22	medium
efb263c4-05b2-42d2-bc77-af9f0cbd846e	4554595d-9245-40e3-b08c-d872099d1fc1	\N	e38a8fbd-4c9d-4475-ae1b-150a034a6936	89f48814-745b-462e-820c-aff4124c3949	پیگیری درخواست‌های رفاهی کارکنان #8	\N	low	2026-07-14	54ad91f3-bff5-4aa7-a3ed-86b3839b3f97	2026-07-21 18:35:18.932907+00	2026-07-21 18:35:18.932907+00	todo	\N	11	33.20	2026-07-01	medium
efb263c4-05b2-42d2-bc77-af9f0cbd846e	4554595d-9245-40e3-b08c-d872099d1fc1	\N	e38a8fbd-4c9d-4475-ae1b-150a034a6936	89f48814-745b-462e-820c-aff4124c3949	بررسی رزومه‌های متقاضیان شغلی #9	\N	medium	2026-07-23	2d1419cb-98de-4a01-a7ab-6b9ad702a1d5	2026-07-21 18:35:18.932907+00	2026-07-21 18:35:18.932907+00	completed	pending	100	10.00	2026-07-07	medium
efb263c4-05b2-42d2-bc77-af9f0cbd846e	4554595d-9245-40e3-b08c-d872099d1fc1	\N	e38a8fbd-4c9d-4475-ae1b-150a034a6936	89f48814-745b-462e-820c-aff4124c3949	برگزاری نظرسنجی رضایت شغلی #10	\N	low	2026-07-18	6e3a7729-4b1c-4698-b0a5-59229298c50e	2026-07-21 18:35:18.932907+00	2026-07-21 18:35:18.932907+00	todo	\N	0	3.80	2026-07-08	medium
efb263c4-05b2-42d2-bc77-af9f0cbd846e	4554595d-9245-40e3-b08c-d872099d1fc1	\N	eb0b5b71-65c1-4694-a9d0-5b2b7aea8eae	89f48814-745b-462e-820c-aff4124c3949	بررسی درخواست ترفیع کارکنان #11	\N	medium	2026-07-19	94bffb01-029a-4a96-8ede-6caa9f1cf254	2026-07-21 18:35:18.932907+00	2026-07-21 18:35:18.932907+00	archived	\N	63	35.50	2026-07-12	medium
efb263c4-05b2-42d2-bc77-af9f0cbd846e	4554595d-9245-40e3-b08c-d872099d1fc1	\N	d9facd7e-b4bd-497f-9f4f-f75e6a932da0	89f48814-745b-462e-820c-aff4124c3949	برگزاری نظرسنجی رضایت شغلی #12	\N	high	2026-08-25	3adf2f30-f09e-4935-a65b-f5cb2e3c67fb	2026-07-21 18:35:18.932907+00	2026-07-21 18:35:18.932907+00	completed	approved	100	26.70	2026-08-08	medium
efb263c4-05b2-42d2-bc77-af9f0cbd846e	4554595d-9245-40e3-b08c-d872099d1fc1	\N	e38a8fbd-4c9d-4475-ae1b-150a034a6936	89f48814-745b-462e-820c-aff4124c3949	برنامه‌ریزی مصاحبهٔ استخدامی #13	\N	low	2026-07-12	4f022722-5b34-49f3-b021-fe7948e3ee41	2026-07-21 18:35:18.932907+00	2026-07-21 18:35:18.932907+00	in_progress	\N	37	2.80	2026-06-26	medium
efb263c4-05b2-42d2-bc77-af9f0cbd846e	4554595d-9245-40e3-b08c-d872099d1fc1	\N	d9facd7e-b4bd-497f-9f4f-f75e6a932da0	89f48814-745b-462e-820c-aff4124c3949	تهیهٔ گزارش ارزیابی عملکرد #14	\N	medium	2026-07-02	45aadacb-ffb4-4111-a96e-2ec2b2ba6cfb	2026-07-21 18:35:18.932907+00	2026-07-21 18:35:18.932907+00	todo	\N	20	29.80	2026-06-20	medium
efb263c4-05b2-42d2-bc77-af9f0cbd846e	4554595d-9245-40e3-b08c-d872099d1fc1	\N	3d944638-fc96-463d-84ac-c7c861324cbe	89f48814-745b-462e-820c-aff4124c3949	تدوین برنامهٔ آموزشی سال آینده #15	\N	medium	2026-07-28	b35667c6-2ed6-478e-b365-9eff91121be8	2026-07-21 18:35:18.932907+00	2026-07-21 18:35:18.932907+00	todo	\N	3	18.40	2026-07-07	medium
efb263c4-05b2-42d2-bc77-af9f0cbd846e	4554595d-9245-40e3-b08c-d872099d1fc1	\N	e38a8fbd-4c9d-4475-ae1b-150a034a6936	89f48814-745b-462e-820c-aff4124c3949	تهیهٔ گزارش ارزیابی عملکرد #16	\N	low	2026-08-08	277aaefa-fea5-4576-abc8-0674cc6e8843	2026-07-21 18:35:18.932907+00	2026-07-21 18:35:18.932907+00	todo	\N	12	14.60	2026-07-24	medium
efb263c4-05b2-42d2-bc77-af9f0cbd846e	4554595d-9245-40e3-b08c-d872099d1fc1	\N	63d308ce-8593-4f45-8c4b-1df63a00732c	89f48814-745b-462e-820c-aff4124c3949	به‌روزرسانی پروندهٔ پرسنلی #17	\N	high	2026-08-18	88005a8d-c8d5-459d-809d-d77b34e9dab6	2026-07-21 18:35:18.932907+00	2026-07-21 18:35:18.932907+00	in_progress	\N	69	12.10	2026-07-30	medium
efb263c4-05b2-42d2-bc77-af9f0cbd846e	4554595d-9245-40e3-b08c-d872099d1fc1	\N	d9facd7e-b4bd-497f-9f4f-f75e6a932da0	89f48814-745b-462e-820c-aff4124c3949	بررسی رزومه‌های متقاضیان شغلی #18	\N	medium	2026-07-06	562e15f5-fe67-4cd8-bf8c-ed8b7fff0e2f	2026-07-21 18:35:18.932907+00	2026-07-21 18:35:18.932907+00	in_progress	\N	73	22.90	2026-07-01	medium
efb263c4-05b2-42d2-bc77-af9f0cbd846e	65f2eec9-9404-43e1-bfd6-2f22321a8701	\N	eb0b5b71-65c1-4694-a9d0-5b2b7aea8eae	89f48814-745b-462e-820c-aff4124c3949	بررسی رزومه‌های متقاضیان شغلی #19	\N	medium	2026-07-02	add8b08b-68cd-458e-9980-9fd151afba5b	2026-07-21 18:35:18.932907+00	2026-07-21 18:35:18.932907+00	todo	\N	11	13.20	2026-06-19	medium
efb263c4-05b2-42d2-bc77-af9f0cbd846e	65f2eec9-9404-43e1-bfd6-2f22321a8701	\N	e38a8fbd-4c9d-4475-ae1b-150a034a6936	89f48814-745b-462e-820c-aff4124c3949	بررسی رزومه‌های متقاضیان شغلی #20	\N	low	2026-07-03	c8635c31-1ce5-4d56-91bd-a86aa218ea8d	2026-07-21 18:35:18.932907+00	2026-07-21 18:35:18.932907+00	completed	pending	100	8.50	2026-06-28	medium
efb263c4-05b2-42d2-bc77-af9f0cbd846e	65f2eec9-9404-43e1-bfd6-2f22321a8701	\N	d9facd7e-b4bd-497f-9f4f-f75e6a932da0	89f48814-745b-462e-820c-aff4124c3949	به‌روزرسانی آیین‌نامهٔ داخلی شرکت #21	\N	medium	2026-07-21	3f6f08c5-122f-42d2-b6e0-7a0552c35f6f	2026-07-21 18:35:18.932907+00	2026-07-21 18:35:18.932907+00	todo	\N	60	20.60	2026-07-16	medium
efb263c4-05b2-42d2-bc77-af9f0cbd846e	65f2eec9-9404-43e1-bfd6-2f22321a8701	\N	e38a8fbd-4c9d-4475-ae1b-150a034a6936	89f48814-745b-462e-820c-aff4124c3949	تهیهٔ فرم ارزیابی سه‌ماهه #22	\N	low	2026-07-10	a58d7d60-6128-4057-aa98-d7d5e0218d75	2026-07-21 18:35:18.932907+00	2026-07-21 18:35:18.932907+00	in_progress	\N	47	35.60	2026-06-21	medium
efb263c4-05b2-42d2-bc77-af9f0cbd846e	65f2eec9-9404-43e1-bfd6-2f22321a8701	\N	d9facd7e-b4bd-497f-9f4f-f75e6a932da0	89f48814-745b-462e-820c-aff4124c3949	به‌روزرسانی آیین‌نامهٔ داخلی شرکت #23	\N	medium	2026-07-17	b54ef96c-078b-4723-9433-f2b46f9177e5	2026-07-21 18:35:18.932907+00	2026-07-21 18:35:18.932907+00	todo	\N	59	12.00	2026-07-14	medium
efb263c4-05b2-42d2-bc77-af9f0cbd846e	65f2eec9-9404-43e1-bfd6-2f22321a8701	\N	4bfc028f-1c19-4b0c-9188-9fe233b49cb4	89f48814-745b-462e-820c-aff4124c3949	تهیهٔ گزارش ارزیابی عملکرد #24	\N	high	2026-07-25	ba8fac48-6e18-4be4-a17f-83504d3d8e64	2026-07-21 18:35:18.932907+00	2026-07-21 18:35:18.932907+00	in_progress	\N	12	5.30	2026-07-22	medium
efb263c4-05b2-42d2-bc77-af9f0cbd846e	65f2eec9-9404-43e1-bfd6-2f22321a8701	\N	d9facd7e-b4bd-497f-9f4f-f75e6a932da0	89f48814-745b-462e-820c-aff4124c3949	برگزاری جلسهٔ آموزش کارکنان جدید #25	\N	high	2026-08-23	b51c640e-81ab-4fe6-b384-0ca593c2321d	2026-07-21 18:35:18.932907+00	2026-07-21 18:35:18.932907+00	completed	approved	100	4.30	2026-08-03	medium
efb263c4-05b2-42d2-bc77-af9f0cbd846e	65f2eec9-9404-43e1-bfd6-2f22321a8701	\N	eb0b5b71-65c1-4694-a9d0-5b2b7aea8eae	89f48814-745b-462e-820c-aff4124c3949	تدوین برنامهٔ آموزشی سال آینده #26	\N	low	2026-08-06	a529f544-746d-422e-acb0-a3ff2a79f3d0	2026-07-21 18:35:18.932907+00	2026-07-21 18:35:18.932907+00	completed	approved	100	20.10	2026-07-20	medium
efb263c4-05b2-42d2-bc77-af9f0cbd846e	65f2eec9-9404-43e1-bfd6-2f22321a8701	\N	89f48814-745b-462e-820c-aff4124c3949	89f48814-745b-462e-820c-aff4124c3949	بررسی و تمدید قراردادهای پرسنلی #27	\N	high	2026-08-15	97e70d52-34cb-4b86-b324-b634d9d11f96	2026-07-21 18:35:18.932907+00	2026-07-21 18:35:18.932907+00	in_progress	\N	66	32.40	2026-08-12	medium
efb263c4-05b2-42d2-bc77-af9f0cbd846e	65f2eec9-9404-43e1-bfd6-2f22321a8701	\N	e38a8fbd-4c9d-4475-ae1b-150a034a6936	89f48814-745b-462e-820c-aff4124c3949	تهیهٔ گزارش ارزیابی عملکرد #28	\N	low	2026-08-31	ca08407b-c5e9-4a35-ad6c-4be1bbdccbdd	2026-07-21 18:35:18.932907+00	2026-07-21 18:35:18.932907+00	completed	approved	100	38.90	2026-08-15	medium
efb263c4-05b2-42d2-bc77-af9f0cbd846e	65f2eec9-9404-43e1-bfd6-2f22321a8701	\N	4bfc028f-1c19-4b0c-9188-9fe233b49cb4	89f48814-745b-462e-820c-aff4124c3949	تهیهٔ فرم ارزیابی سه‌ماهه #29	\N	low	2026-06-27	e0c97c33-490f-4350-bc64-cf879d5f43a7	2026-07-21 18:35:18.932907+00	2026-07-21 18:35:18.932907+00	todo	\N	55	9.70	2026-06-24	medium
efb263c4-05b2-42d2-bc77-af9f0cbd846e	65f2eec9-9404-43e1-bfd6-2f22321a8701	\N	4bfc028f-1c19-4b0c-9188-9fe233b49cb4	89f48814-745b-462e-820c-aff4124c3949	پیگیری درخواست‌های رفاهی کارکنان #30	\N	high	2026-08-03	254ef22b-654f-4b84-9d24-62206c567d89	2026-07-21 18:35:18.932907+00	2026-07-21 18:35:18.932907+00	completed	approved	100	36.70	2026-07-24	medium
efb263c4-05b2-42d2-bc77-af9f0cbd846e	65f2eec9-9404-43e1-bfd6-2f22321a8701	\N	89f48814-745b-462e-820c-aff4124c3949	89f48814-745b-462e-820c-aff4124c3949	تهیهٔ فرم ارزیابی سه‌ماهه #31	\N	high	2026-07-29	6cd348eb-5c4b-4f65-8c4a-a935f8a199d1	2026-07-21 18:35:18.932907+00	2026-07-21 18:35:18.932907+00	todo	\N	41	34.60	2026-07-10	medium
efb263c4-05b2-42d2-bc77-af9f0cbd846e	65f2eec9-9404-43e1-bfd6-2f22321a8701	\N	3d944638-fc96-463d-84ac-c7c861324cbe	89f48814-745b-462e-820c-aff4124c3949	تدوین برنامهٔ آموزشی سال آینده #32	\N	high	2026-07-07	a7185f55-4b28-4dc3-9ac4-cdf19ef27efa	2026-07-21 18:35:18.932907+00	2026-07-21 18:35:18.932907+00	completed	rejected	100	31.70	2026-06-16	medium
efb263c4-05b2-42d2-bc77-af9f0cbd846e	65f2eec9-9404-43e1-bfd6-2f22321a8701	\N	89f48814-745b-462e-820c-aff4124c3949	89f48814-745b-462e-820c-aff4124c3949	تدوین برنامهٔ آموزشی سال آینده #33	\N	high	2026-07-01	ca23af76-5ceb-4718-b158-14926e5a8015	2026-07-21 18:35:18.932907+00	2026-07-21 18:35:18.932907+00	in_progress	\N	74	30.80	2026-06-25	medium
efb263c4-05b2-42d2-bc77-af9f0cbd846e	65f2eec9-9404-43e1-bfd6-2f22321a8701	\N	89f48814-745b-462e-820c-aff4124c3949	89f48814-745b-462e-820c-aff4124c3949	برگزاری نظرسنجی رضایت شغلی #34	\N	medium	2026-07-27	823810f5-340c-4208-b900-79582a6ea162	2026-07-21 18:35:18.932907+00	2026-07-21 18:35:18.932907+00	todo	\N	68	35.40	2026-07-22	medium
efb263c4-05b2-42d2-bc77-af9f0cbd846e	65f2eec9-9404-43e1-bfd6-2f22321a8701	\N	eb0b5b71-65c1-4694-a9d0-5b2b7aea8eae	89f48814-745b-462e-820c-aff4124c3949	تدوین برنامهٔ آموزشی سال آینده #35	\N	high	2026-07-27	825dbd19-25dd-490b-8399-5dfed374e651	2026-07-21 18:35:18.932907+00	2026-07-21 18:35:18.932907+00	in_progress	\N	60	3.40	2026-07-10	medium
efb263c4-05b2-42d2-bc77-af9f0cbd846e	65f2eec9-9404-43e1-bfd6-2f22321a8701	\N	d9facd7e-b4bd-497f-9f4f-f75e6a932da0	89f48814-745b-462e-820c-aff4124c3949	تدوین برنامهٔ آموزشی سال آینده #36	\N	high	2026-07-16	f3a4e93e-7446-4e20-93f5-162e2dd4f040	2026-07-21 18:35:18.932907+00	2026-07-21 18:35:18.932907+00	in_progress	\N	51	3.50	2026-06-25	medium
efb263c4-05b2-42d2-bc77-af9f0cbd846e	f3b6db39-3c7b-41fa-bfa4-b7ae409a154a	\N	d9facd7e-b4bd-497f-9f4f-f75e6a932da0	89f48814-745b-462e-820c-aff4124c3949	بررسی درخواست ترفیع کارکنان #37	\N	medium	2026-08-19	d25a1834-7de4-439f-9667-cf707b9a9b13	2026-07-21 18:35:18.932907+00	2026-07-21 18:35:18.932907+00	completed	approved	100	36.10	2026-08-02	medium
efb263c4-05b2-42d2-bc77-af9f0cbd846e	f3b6db39-3c7b-41fa-bfa4-b7ae409a154a	\N	89f48814-745b-462e-820c-aff4124c3949	89f48814-745b-462e-820c-aff4124c3949	به‌روزرسانی آیین‌نامهٔ داخلی شرکت #38	\N	medium	2026-08-18	0b395e7a-e9d2-40f2-8e75-b679a9c55541	2026-07-21 18:35:18.932907+00	2026-07-21 18:35:18.932907+00	in_progress	\N	62	34.60	2026-08-07	medium
efb263c4-05b2-42d2-bc77-af9f0cbd846e	f3b6db39-3c7b-41fa-bfa4-b7ae409a154a	\N	e38a8fbd-4c9d-4475-ae1b-150a034a6936	89f48814-745b-462e-820c-aff4124c3949	تهیهٔ گزارش ارزیابی عملکرد #39	\N	medium	2026-08-19	a269e4c4-9ec3-49ac-a831-47c45d7621a7	2026-07-21 18:35:18.932907+00	2026-07-21 18:35:18.932907+00	todo	\N	56	31.40	2026-08-10	medium
efb263c4-05b2-42d2-bc77-af9f0cbd846e	f3b6db39-3c7b-41fa-bfa4-b7ae409a154a	\N	d9facd7e-b4bd-497f-9f4f-f75e6a932da0	89f48814-745b-462e-820c-aff4124c3949	تدوین برنامهٔ آموزشی سال آینده #40	\N	high	2026-08-16	9b5f8e12-182d-4496-bdab-dab07ec918f9	2026-07-21 18:35:18.932907+00	2026-07-21 18:35:18.932907+00	in_progress	\N	11	9.10	2026-08-01	medium
efb263c4-05b2-42d2-bc77-af9f0cbd846e	f3b6db39-3c7b-41fa-bfa4-b7ae409a154a	\N	63d308ce-8593-4f45-8c4b-1df63a00732c	89f48814-745b-462e-820c-aff4124c3949	برگزاری نظرسنجی رضایت شغلی #41	\N	high	2026-08-19	6f5c75a3-f807-4c42-ba79-5eac3f1c5e14	2026-07-21 18:35:18.932907+00	2026-07-21 18:35:18.932907+00	in_progress	\N	47	33.20	2026-08-02	medium
efb263c4-05b2-42d2-bc77-af9f0cbd846e	f3b6db39-3c7b-41fa-bfa4-b7ae409a154a	\N	3d944638-fc96-463d-84ac-c7c861324cbe	89f48814-745b-462e-820c-aff4124c3949	به‌روزرسانی پروندهٔ پرسنلی #42	\N	high	2026-07-01	535c78f1-0901-4b82-9449-dd024e717c3f	2026-07-21 18:35:18.932907+00	2026-07-21 18:35:18.932907+00	todo	\N	51	7.20	2026-06-20	medium
efb263c4-05b2-42d2-bc77-af9f0cbd846e	f3b6db39-3c7b-41fa-bfa4-b7ae409a154a	\N	4bfc028f-1c19-4b0c-9188-9fe233b49cb4	89f48814-745b-462e-820c-aff4124c3949	برگزاری جلسهٔ آموزش کارکنان جدید #43	\N	low	2026-06-24	4f6ea181-d2bd-4bbd-8eb7-ddf97104414c	2026-07-21 18:35:18.932907+00	2026-07-21 18:35:18.932907+00	completed	pending	100	33.80	2026-06-17	medium
efb263c4-05b2-42d2-bc77-af9f0cbd846e	f3b6db39-3c7b-41fa-bfa4-b7ae409a154a	\N	63d308ce-8593-4f45-8c4b-1df63a00732c	89f48814-745b-462e-820c-aff4124c3949	بررسی درخواست ترفیع کارکنان #44	\N	medium	2026-07-18	0e4d859f-7d19-4b1f-a165-b48cf323828f	2026-07-21 18:35:18.932907+00	2026-07-21 18:35:18.932907+00	todo	\N	25	12.40	2026-07-15	medium
efb263c4-05b2-42d2-bc77-af9f0cbd846e	f3b6db39-3c7b-41fa-bfa4-b7ae409a154a	\N	4bfc028f-1c19-4b0c-9188-9fe233b49cb4	89f48814-745b-462e-820c-aff4124c3949	پیگیری مرخصی و مأموریت کارکنان #45	\N	low	2026-07-31	ea093497-b96a-4380-a707-8559da4ff12f	2026-07-21 18:35:18.932907+00	2026-07-21 18:35:18.932907+00	completed	approved	100	11.20	2026-07-26	medium
efb263c4-05b2-42d2-bc77-af9f0cbd846e	f3b6db39-3c7b-41fa-bfa4-b7ae409a154a	\N	eb0b5b71-65c1-4694-a9d0-5b2b7aea8eae	89f48814-745b-462e-820c-aff4124c3949	تدوین برنامهٔ آموزشی سال آینده #46	\N	high	2026-08-27	c361fa3b-4136-4a9a-ae89-33e0ce4cc9f7	2026-07-21 18:35:18.932907+00	2026-07-21 18:35:18.932907+00	completed	approved	100	15.30	2026-08-10	medium
efb263c4-05b2-42d2-bc77-af9f0cbd846e	f3b6db39-3c7b-41fa-bfa4-b7ae409a154a	\N	63d308ce-8593-4f45-8c4b-1df63a00732c	89f48814-745b-462e-820c-aff4124c3949	به‌روزرسانی آیین‌نامهٔ داخلی شرکت #47	\N	low	2026-08-06	2905a818-7c05-4dbc-88c3-1ac82d16866d	2026-07-21 18:35:18.932907+00	2026-07-21 18:35:18.932907+00	in_progress	\N	49	3.90	2026-08-02	medium
efb263c4-05b2-42d2-bc77-af9f0cbd846e	f3b6db39-3c7b-41fa-bfa4-b7ae409a154a	\N	4bfc028f-1c19-4b0c-9188-9fe233b49cb4	89f48814-745b-462e-820c-aff4124c3949	پیگیری مرخصی و مأموریت کارکنان #48	\N	low	2026-07-08	9f17ed6d-a670-486b-93d5-4e8106cd865a	2026-07-21 18:35:18.932907+00	2026-07-21 18:35:18.932907+00	completed	pending	100	27.80	2026-06-29	medium
efb263c4-05b2-42d2-bc77-af9f0cbd846e	f3b6db39-3c7b-41fa-bfa4-b7ae409a154a	\N	d9facd7e-b4bd-497f-9f4f-f75e6a932da0	89f48814-745b-462e-820c-aff4124c3949	برنامه‌ریزی رویداد تیم‌سازی #49	\N	low	2026-06-19	a0c3171e-3128-4cab-a404-534a72304fee	2026-07-21 18:35:18.932907+00	2026-07-21 18:35:18.932907+00	completed	approved	100	26.60	2026-06-17	medium
efb263c4-05b2-42d2-bc77-af9f0cbd846e	f3b6db39-3c7b-41fa-bfa4-b7ae409a154a	\N	3d944638-fc96-463d-84ac-c7c861324cbe	89f48814-745b-462e-820c-aff4124c3949	تدوین برنامهٔ آموزشی سال آینده #50	\N	medium	2026-07-10	7cbc4be4-26b6-459c-9365-773c0394fc67	2026-07-21 18:35:18.932907+00	2026-07-21 18:35:18.932907+00	todo	\N	35	18.10	2026-06-30	medium
efb263c4-05b2-42d2-bc77-af9f0cbd846e	f3b6db39-3c7b-41fa-bfa4-b7ae409a154a	\N	eb0b5b71-65c1-4694-a9d0-5b2b7aea8eae	89f48814-745b-462e-820c-aff4124c3949	برگزاری جلسهٔ آموزش کارکنان جدید #51	\N	medium	2026-07-25	19191629-71a7-4566-a50d-dbc903e1df37	2026-07-21 18:35:18.932907+00	2026-07-21 18:35:18.932907+00	in_progress	\N	38	27.70	2026-07-15	medium
efb263c4-05b2-42d2-bc77-af9f0cbd846e	f3b6db39-3c7b-41fa-bfa4-b7ae409a154a	\N	4bfc028f-1c19-4b0c-9188-9fe233b49cb4	89f48814-745b-462e-820c-aff4124c3949	بررسی و تمدید قراردادهای پرسنلی #52	\N	high	2026-06-24	d8941b2b-18b5-4fd6-8c49-ce7a587c6294	2026-07-21 18:35:18.932907+00	2026-07-21 18:35:18.932907+00	completed	approved	100	38.70	2026-06-22	medium
efb263c4-05b2-42d2-bc77-af9f0cbd846e	f3b6db39-3c7b-41fa-bfa4-b7ae409a154a	\N	4bfc028f-1c19-4b0c-9188-9fe233b49cb4	89f48814-745b-462e-820c-aff4124c3949	تدوین برنامهٔ آموزشی سال آینده #53	\N	medium	2026-08-11	b511a8ec-7a72-432a-b887-b2211017181f	2026-07-21 18:35:18.932907+00	2026-07-21 18:35:18.932907+00	in_progress	\N	38	28.00	2026-07-21	medium
efb263c4-05b2-42d2-bc77-af9f0cbd846e	f3b6db39-3c7b-41fa-bfa4-b7ae409a154a	\N	eb0b5b71-65c1-4694-a9d0-5b2b7aea8eae	89f48814-745b-462e-820c-aff4124c3949	پیگیری مرخصی و مأموریت کارکنان #54	\N	medium	2026-07-17	78f1ed81-ee33-493d-8a0f-e9db45e71dc0	2026-07-21 18:35:18.932907+00	2026-07-21 18:35:18.932907+00	todo	\N	35	11.90	2026-07-07	medium
efb263c4-05b2-42d2-bc77-af9f0cbd846e	af916260-f69c-4181-a986-3df8a4df7239	\N	e38a8fbd-4c9d-4475-ae1b-150a034a6936	89f48814-745b-462e-820c-aff4124c3949	برگزاری نظرسنجی رضایت شغلی #55	\N	low	2026-07-13	d5a2fb29-fd48-4d18-b48c-e9f193e5a048	2026-07-21 18:35:18.932907+00	2026-07-21 18:35:18.932907+00	completed	approved	100	36.20	2026-06-25	medium
efb263c4-05b2-42d2-bc77-af9f0cbd846e	af916260-f69c-4181-a986-3df8a4df7239	\N	4bfc028f-1c19-4b0c-9188-9fe233b49cb4	89f48814-745b-462e-820c-aff4124c3949	به‌روزرسانی پروندهٔ پرسنلی #56	\N	low	2026-07-12	2308411f-3ee4-4cb1-9288-95aa8b5f5a0f	2026-07-21 18:35:18.932907+00	2026-07-21 18:35:18.932907+00	completed	approved	100	26.90	2026-07-06	medium
efb263c4-05b2-42d2-bc77-af9f0cbd846e	af916260-f69c-4181-a986-3df8a4df7239	\N	d9facd7e-b4bd-497f-9f4f-f75e6a932da0	89f48814-745b-462e-820c-aff4124c3949	تهیهٔ فرم ارزیابی سه‌ماهه #57	\N	medium	2026-08-28	848d12a2-059e-4d93-9830-ec8989b61523	2026-07-21 18:35:18.932907+00	2026-07-21 18:35:18.932907+00	in_progress	\N	4	24.20	2026-08-13	medium
efb263c4-05b2-42d2-bc77-af9f0cbd846e	af916260-f69c-4181-a986-3df8a4df7239	\N	3d944638-fc96-463d-84ac-c7c861324cbe	89f48814-745b-462e-820c-aff4124c3949	پیگیری مرخصی و مأموریت کارکنان #58	\N	high	2026-07-16	62bc2611-6b5c-418b-bc28-0a193bc0ec42	2026-07-21 18:35:18.932907+00	2026-07-21 18:35:18.932907+00	todo	\N	60	36.40	2026-07-07	medium
efb263c4-05b2-42d2-bc77-af9f0cbd846e	af916260-f69c-4181-a986-3df8a4df7239	\N	e38a8fbd-4c9d-4475-ae1b-150a034a6936	89f48814-745b-462e-820c-aff4124c3949	تهیهٔ گزارش غیبت و تأخیر #59	\N	low	2026-07-29	80e826dd-d725-405b-970b-acff1efdd669	2026-07-21 18:35:18.932907+00	2026-07-21 18:35:18.932907+00	in_progress	\N	71	8.90	2026-07-18	medium
efb263c4-05b2-42d2-bc77-af9f0cbd846e	af916260-f69c-4181-a986-3df8a4df7239	\N	89f48814-745b-462e-820c-aff4124c3949	89f48814-745b-462e-820c-aff4124c3949	برگزاری نظرسنجی رضایت شغلی #60	\N	low	2026-07-21	ebc9d9c0-5170-4d8b-b571-3cebe2e7c076	2026-07-21 18:35:18.932907+00	2026-07-21 18:35:18.932907+00	completed	approved	100	38.00	2026-07-02	medium
efb263c4-05b2-42d2-bc77-af9f0cbd846e	af916260-f69c-4181-a986-3df8a4df7239	\N	d9facd7e-b4bd-497f-9f4f-f75e6a932da0	89f48814-745b-462e-820c-aff4124c3949	به‌روزرسانی پروندهٔ پرسنلی #61	\N	medium	2026-07-17	5b6afa48-43df-4285-8023-70f8dc938f44	2026-07-21 18:35:18.932907+00	2026-07-21 18:35:18.932907+00	completed	approved	100	18.00	2026-07-08	medium
efb263c4-05b2-42d2-bc77-af9f0cbd846e	af916260-f69c-4181-a986-3df8a4df7239	\N	d9facd7e-b4bd-497f-9f4f-f75e6a932da0	89f48814-745b-462e-820c-aff4124c3949	به‌روزرسانی آیین‌نامهٔ داخلی شرکت #62	\N	medium	2026-07-22	3018d0f4-c0af-4b6f-a47d-f51a3d4be997	2026-07-21 18:35:18.932907+00	2026-07-21 18:35:18.932907+00	in_progress	\N	15	19.90	2026-07-02	medium
efb263c4-05b2-42d2-bc77-af9f0cbd846e	af916260-f69c-4181-a986-3df8a4df7239	\N	4bfc028f-1c19-4b0c-9188-9fe233b49cb4	89f48814-745b-462e-820c-aff4124c3949	برنامه‌ریزی مصاحبهٔ استخدامی #63	\N	medium	2026-09-05	d037bb17-23c3-44ec-9129-84976bcd7798	2026-07-21 18:35:18.932907+00	2026-07-21 18:35:18.932907+00	completed	approved	100	35.80	2026-08-15	medium
efb263c4-05b2-42d2-bc77-af9f0cbd846e	af916260-f69c-4181-a986-3df8a4df7239	\N	3d944638-fc96-463d-84ac-c7c861324cbe	89f48814-745b-462e-820c-aff4124c3949	بررسی و تمدید قراردادهای پرسنلی #64	\N	medium	2026-08-24	98cf91f9-ce41-40bc-94d4-69fc8ed96b99	2026-07-21 18:35:18.932907+00	2026-07-21 18:35:18.932907+00	todo	\N	52	4.10	2026-08-10	medium
efb263c4-05b2-42d2-bc77-af9f0cbd846e	af916260-f69c-4181-a986-3df8a4df7239	\N	4bfc028f-1c19-4b0c-9188-9fe233b49cb4	89f48814-745b-462e-820c-aff4124c3949	پیگیری درخواست‌های رفاهی کارکنان #65	\N	medium	2026-07-02	8c9ce4c6-81b7-4241-8af1-21a77d95b028	2026-07-21 18:35:18.932907+00	2026-07-21 18:35:18.932907+00	todo	\N	72	35.90	2026-06-24	medium
efb263c4-05b2-42d2-bc77-af9f0cbd846e	af916260-f69c-4181-a986-3df8a4df7239	\N	eb0b5b71-65c1-4694-a9d0-5b2b7aea8eae	89f48814-745b-462e-820c-aff4124c3949	برگزاری نظرسنجی رضایت شغلی #66	\N	low	2026-07-13	a65f1eb5-94cf-484d-a4ea-8c0cd82774cb	2026-07-21 18:35:18.932907+00	2026-07-21 18:35:18.932907+00	todo	\N	62	14.60	2026-07-06	medium
efb263c4-05b2-42d2-bc77-af9f0cbd846e	af916260-f69c-4181-a986-3df8a4df7239	\N	63d308ce-8593-4f45-8c4b-1df63a00732c	89f48814-745b-462e-820c-aff4124c3949	بررسی رزومه‌های متقاضیان شغلی #67	\N	medium	2026-07-29	bca843db-6607-4a7b-bbd2-75cadd75edb0	2026-07-21 18:35:18.932907+00	2026-07-21 18:35:18.932907+00	in_progress	\N	35	10.00	2026-07-26	medium
efb263c4-05b2-42d2-bc77-af9f0cbd846e	af916260-f69c-4181-a986-3df8a4df7239	\N	4bfc028f-1c19-4b0c-9188-9fe233b49cb4	89f48814-745b-462e-820c-aff4124c3949	برنامه‌ریزی رویداد تیم‌سازی #68	\N	low	2026-07-29	52c28e76-5d38-4eb9-ac2e-dd443f334dc6	2026-07-21 18:35:18.932907+00	2026-07-21 18:35:18.932907+00	todo	\N	16	25.40	2026-07-22	medium
efb263c4-05b2-42d2-bc77-af9f0cbd846e	af916260-f69c-4181-a986-3df8a4df7239	\N	e38a8fbd-4c9d-4475-ae1b-150a034a6936	89f48814-745b-462e-820c-aff4124c3949	برنامه‌ریزی رویداد تیم‌سازی #69	\N	medium	2026-07-26	219cb336-304b-4d97-8343-89ad766e3e36	2026-07-21 18:35:18.932907+00	2026-07-21 18:35:18.932907+00	in_progress	\N	0	3.40	2026-07-11	medium
efb263c4-05b2-42d2-bc77-af9f0cbd846e	af916260-f69c-4181-a986-3df8a4df7239	\N	63d308ce-8593-4f45-8c4b-1df63a00732c	89f48814-745b-462e-820c-aff4124c3949	بررسی درخواست ترفیع کارکنان #70	\N	medium	2026-07-11	c668a551-dcb1-4d8d-b2fe-7726027eacc3	2026-07-21 18:35:18.932907+00	2026-07-21 18:35:18.932907+00	archived	\N	67	9.20	2026-07-09	medium
efb263c4-05b2-42d2-bc77-af9f0cbd846e	af916260-f69c-4181-a986-3df8a4df7239	\N	e38a8fbd-4c9d-4475-ae1b-150a034a6936	89f48814-745b-462e-820c-aff4124c3949	برگزاری جلسهٔ آموزش کارکنان جدید #71	\N	high	2026-08-04	58c36eee-e25d-443a-b3a5-cb4184f09190	2026-07-21 18:35:18.932907+00	2026-07-21 18:35:18.932907+00	todo	\N	44	13.90	2026-07-26	medium
efb263c4-05b2-42d2-bc77-af9f0cbd846e	af916260-f69c-4181-a986-3df8a4df7239	\N	89f48814-745b-462e-820c-aff4124c3949	89f48814-745b-462e-820c-aff4124c3949	به‌روزرسانی آیین‌نامهٔ داخلی شرکت #72	\N	low	2026-08-07	c83cf8c9-11b7-491a-9bbd-5ab5f05c4f1d	2026-07-21 18:35:18.932907+00	2026-07-21 18:35:18.932907+00	in_progress	\N	8	33.30	2026-07-18	medium
efb263c4-05b2-42d2-bc77-af9f0cbd846e	7f7c651b-87ea-4b3a-8b88-3bec205cfc31	\N	d9facd7e-b4bd-497f-9f4f-f75e6a932da0	89f48814-745b-462e-820c-aff4124c3949	تدوین برنامهٔ آموزشی سال آینده #73	\N	high	2026-08-02	f4b7a9d8-7e89-40ff-a296-e21182ff3d8d	2026-07-21 18:35:18.932907+00	2026-07-21 18:35:18.932907+00	in_progress	\N	43	18.50	2026-07-15	medium
efb263c4-05b2-42d2-bc77-af9f0cbd846e	7f7c651b-87ea-4b3a-8b88-3bec205cfc31	\N	e38a8fbd-4c9d-4475-ae1b-150a034a6936	89f48814-745b-462e-820c-aff4124c3949	پیگیری درخواست‌های رفاهی کارکنان #74	\N	low	2026-07-24	89a6136b-c662-44fe-85d9-31edd1a5a6b1	2026-07-21 18:35:18.932907+00	2026-07-21 18:35:18.932907+00	todo	\N	21	38.00	2026-07-07	medium
efb263c4-05b2-42d2-bc77-af9f0cbd846e	7f7c651b-87ea-4b3a-8b88-3bec205cfc31	\N	4bfc028f-1c19-4b0c-9188-9fe233b49cb4	89f48814-745b-462e-820c-aff4124c3949	برگزاری جلسهٔ آموزش کارکنان جدید #75	\N	high	2026-06-26	e49193f3-b748-41f0-9138-9c1f609b50ad	2026-07-21 18:35:18.932907+00	2026-07-21 18:35:18.932907+00	in_progress	\N	16	10.00	2026-06-17	medium
efb263c4-05b2-42d2-bc77-af9f0cbd846e	7f7c651b-87ea-4b3a-8b88-3bec205cfc31	\N	89f48814-745b-462e-820c-aff4124c3949	89f48814-745b-462e-820c-aff4124c3949	به‌روزرسانی پروندهٔ پرسنلی #76	\N	high	2026-07-06	304ef989-3b69-4dab-bd18-3ded35188a10	2026-07-21 18:35:18.932907+00	2026-07-21 18:35:18.932907+00	completed	approved	100	32.10	2026-06-23	medium
efb263c4-05b2-42d2-bc77-af9f0cbd846e	7f7c651b-87ea-4b3a-8b88-3bec205cfc31	\N	eb0b5b71-65c1-4694-a9d0-5b2b7aea8eae	89f48814-745b-462e-820c-aff4124c3949	بررسی رزومه‌های متقاضیان شغلی #77	\N	high	2026-08-10	cfce63b5-b043-4e85-86d7-bb4f1b249a0e	2026-07-21 18:35:18.932907+00	2026-07-21 18:35:18.932907+00	completed	approved	100	39.80	2026-07-20	medium
efb263c4-05b2-42d2-bc77-af9f0cbd846e	7f7c651b-87ea-4b3a-8b88-3bec205cfc31	\N	e38a8fbd-4c9d-4475-ae1b-150a034a6936	89f48814-745b-462e-820c-aff4124c3949	بررسی رزومه‌های متقاضیان شغلی #78	\N	high	2026-07-29	3dbf4d8f-4c6b-4444-8f7b-9d86644660b4	2026-07-21 18:35:18.932907+00	2026-07-21 18:35:18.932907+00	todo	\N	14	17.80	2026-07-27	medium
efb263c4-05b2-42d2-bc77-af9f0cbd846e	7f7c651b-87ea-4b3a-8b88-3bec205cfc31	\N	eb0b5b71-65c1-4694-a9d0-5b2b7aea8eae	89f48814-745b-462e-820c-aff4124c3949	برنامه‌ریزی رویداد تیم‌سازی #79	\N	high	2026-07-31	1a17f432-5f50-4474-a0a1-c8c1bb2b6bf9	2026-07-21 18:35:18.932907+00	2026-07-21 18:35:18.932907+00	todo	\N	19	9.80	2026-07-21	medium
efb263c4-05b2-42d2-bc77-af9f0cbd846e	7f7c651b-87ea-4b3a-8b88-3bec205cfc31	\N	e38a8fbd-4c9d-4475-ae1b-150a034a6936	89f48814-745b-462e-820c-aff4124c3949	پیگیری مرخصی و مأموریت کارکنان #80	\N	high	2026-07-17	155014d5-f841-48cf-a590-f17c8c086f97	2026-07-21 18:35:18.932907+00	2026-07-21 18:35:18.932907+00	completed	approved	100	12.30	2026-07-12	medium
efb263c4-05b2-42d2-bc77-af9f0cbd846e	7f7c651b-87ea-4b3a-8b88-3bec205cfc31	\N	3d944638-fc96-463d-84ac-c7c861324cbe	89f48814-745b-462e-820c-aff4124c3949	بررسی و تمدید قراردادهای پرسنلی #81	\N	high	2026-08-13	766b9ecd-c93b-4013-a75e-5c7f77b6b199	2026-07-21 18:35:18.932907+00	2026-07-21 18:35:18.932907+00	completed	approved	100	25.50	2026-08-08	medium
efb263c4-05b2-42d2-bc77-af9f0cbd846e	7f7c651b-87ea-4b3a-8b88-3bec205cfc31	\N	d9facd7e-b4bd-497f-9f4f-f75e6a932da0	89f48814-745b-462e-820c-aff4124c3949	برنامه‌ریزی رویداد تیم‌سازی #82	\N	low	2026-08-10	ec38e6d3-b976-436c-b6f7-cd3e8de294de	2026-07-21 18:35:18.932907+00	2026-07-21 18:35:18.932907+00	todo	\N	77	9.60	2026-08-05	medium
efb263c4-05b2-42d2-bc77-af9f0cbd846e	7f7c651b-87ea-4b3a-8b88-3bec205cfc31	\N	d9facd7e-b4bd-497f-9f4f-f75e6a932da0	89f48814-745b-462e-820c-aff4124c3949	به‌روزرسانی آیین‌نامهٔ داخلی شرکت #83	\N	low	2026-07-23	a51cc1a1-36a3-4155-a7b4-e3098d34ca36	2026-07-21 18:35:18.932907+00	2026-07-21 18:35:18.932907+00	completed	rejected	100	3.50	2026-07-08	medium
efb263c4-05b2-42d2-bc77-af9f0cbd846e	7f7c651b-87ea-4b3a-8b88-3bec205cfc31	\N	eb0b5b71-65c1-4694-a9d0-5b2b7aea8eae	89f48814-745b-462e-820c-aff4124c3949	پیگیری درخواست‌های رفاهی کارکنان #84	\N	low	2026-08-16	4fb36fd5-7d0b-4144-9003-9f117b6e6038	2026-07-21 18:35:18.932907+00	2026-07-21 18:35:18.932907+00	in_progress	\N	0	2.50	2026-07-30	medium
efb263c4-05b2-42d2-bc77-af9f0cbd846e	7f7c651b-87ea-4b3a-8b88-3bec205cfc31	\N	89f48814-745b-462e-820c-aff4124c3949	89f48814-745b-462e-820c-aff4124c3949	پیگیری مرخصی و مأموریت کارکنان #85	\N	medium	2026-08-28	9d56c4c1-358b-4ca9-8b46-82d9ca93689f	2026-07-21 18:35:18.932907+00	2026-07-21 18:35:18.932907+00	todo	\N	19	38.10	2026-08-08	medium
efb263c4-05b2-42d2-bc77-af9f0cbd846e	7f7c651b-87ea-4b3a-8b88-3bec205cfc31	\N	4bfc028f-1c19-4b0c-9188-9fe233b49cb4	89f48814-745b-462e-820c-aff4124c3949	بررسی درخواست ترفیع کارکنان #86	\N	medium	2026-08-06	866a5ea4-ce84-437a-82b7-f5fed243dcb8	2026-07-21 18:35:18.932907+00	2026-07-21 18:35:18.932907+00	completed	approved	100	26.50	2026-08-01	medium
efb263c4-05b2-42d2-bc77-af9f0cbd846e	7f7c651b-87ea-4b3a-8b88-3bec205cfc31	\N	eb0b5b71-65c1-4694-a9d0-5b2b7aea8eae	89f48814-745b-462e-820c-aff4124c3949	بررسی رزومه‌های متقاضیان شغلی #87	\N	low	2026-07-18	0fec87a5-0ac1-4ee1-8412-a802286353a3	2026-07-21 18:35:18.932907+00	2026-07-21 18:35:18.932907+00	in_progress	\N	22	35.20	2026-07-02	medium
efb263c4-05b2-42d2-bc77-af9f0cbd846e	7f7c651b-87ea-4b3a-8b88-3bec205cfc31	\N	4bfc028f-1c19-4b0c-9188-9fe233b49cb4	89f48814-745b-462e-820c-aff4124c3949	تهیهٔ فرم ارزیابی سه‌ماهه #88	\N	high	2026-07-21	4fe5f8f9-7ffb-4196-9cb4-619ffc0dc8b8	2026-07-21 18:35:18.932907+00	2026-07-21 18:35:18.932907+00	in_progress	\N	14	5.60	2026-07-09	medium
efb263c4-05b2-42d2-bc77-af9f0cbd846e	7f7c651b-87ea-4b3a-8b88-3bec205cfc31	\N	4bfc028f-1c19-4b0c-9188-9fe233b49cb4	89f48814-745b-462e-820c-aff4124c3949	پیگیری مرخصی و مأموریت کارکنان #89	\N	high	2026-06-22	ff8c761b-f447-4b31-bb41-9920d6ef01bd	2026-07-21 18:35:18.932907+00	2026-07-21 18:35:18.932907+00	todo	\N	21	14.50	2026-06-16	medium
efb263c4-05b2-42d2-bc77-af9f0cbd846e	7f7c651b-87ea-4b3a-8b88-3bec205cfc31	\N	eb0b5b71-65c1-4694-a9d0-5b2b7aea8eae	89f48814-745b-462e-820c-aff4124c3949	پیگیری درخواست‌های رفاهی کارکنان #90	\N	medium	2026-08-05	62777b43-0ae3-42e9-8497-985de756f991	2026-07-21 18:35:18.932907+00	2026-07-21 18:35:18.932907+00	completed	approved	100	8.90	2026-08-01	medium
efb263c4-05b2-42d2-bc77-af9f0cbd846e	\N	\N	eb0b5b71-65c1-4694-a9d0-5b2b7aea8eae	eb0b5b71-65c1-4694-a9d0-5b2b7aea8eae	تهیهٔ گزارش غیبت و تأخیر #91	\N	medium	2026-07-25	7a28d385-5b14-42a5-bc6b-772ca3be48f7	2026-07-21 18:35:18.932907+00	2026-07-21 18:35:18.932907+00	in_progress	\N	61	32.40	2026-07-15	medium
efb263c4-05b2-42d2-bc77-af9f0cbd846e	\N	\N	e38a8fbd-4c9d-4475-ae1b-150a034a6936	e38a8fbd-4c9d-4475-ae1b-150a034a6936	به‌روزرسانی پروندهٔ پرسنلی #92	\N	high	2026-06-29	5fefbf39-086e-4647-b201-605ae10bde32	2026-07-21 18:35:18.932907+00	2026-07-21 18:35:18.932907+00	todo	\N	7	39.30	2026-06-23	medium
efb263c4-05b2-42d2-bc77-af9f0cbd846e	\N	\N	4bfc028f-1c19-4b0c-9188-9fe233b49cb4	4bfc028f-1c19-4b0c-9188-9fe233b49cb4	بررسی درخواست ترفیع کارکنان #93	\N	high	2026-07-07	fd2a08cd-9c1e-4826-9410-3e959ae0d758	2026-07-21 18:35:18.932907+00	2026-07-21 18:35:18.932907+00	todo	\N	61	32.50	2026-06-22	medium
efb263c4-05b2-42d2-bc77-af9f0cbd846e	\N	\N	e38a8fbd-4c9d-4475-ae1b-150a034a6936	e38a8fbd-4c9d-4475-ae1b-150a034a6936	تدوین برنامهٔ آموزشی سال آینده #94	\N	low	2026-07-23	5f1388c4-0d20-41b5-9a62-5304f675a943	2026-07-21 18:35:18.932907+00	2026-07-21 18:35:18.932907+00	completed	approved	100	34.80	2026-07-10	medium
efb263c4-05b2-42d2-bc77-af9f0cbd846e	\N	\N	4bfc028f-1c19-4b0c-9188-9fe233b49cb4	4bfc028f-1c19-4b0c-9188-9fe233b49cb4	برنامه‌ریزی رویداد تیم‌سازی #95	\N	medium	2026-08-18	22632b7f-790a-465b-8077-4b987ebf75ac	2026-07-21 18:35:18.932907+00	2026-07-21 18:35:18.932907+00	archived	\N	14	35.70	2026-08-12	medium
efb263c4-05b2-42d2-bc77-af9f0cbd846e	\N	\N	eb0b5b71-65c1-4694-a9d0-5b2b7aea8eae	eb0b5b71-65c1-4694-a9d0-5b2b7aea8eae	پیگیری مرخصی و مأموریت کارکنان #96	\N	medium	2026-06-30	4b868695-1950-43b5-9b22-94a6dc0558e9	2026-07-21 18:35:18.932907+00	2026-07-21 18:35:18.932907+00	todo	\N	1	28.80	2026-06-20	medium
efb263c4-05b2-42d2-bc77-af9f0cbd846e	\N	\N	e38a8fbd-4c9d-4475-ae1b-150a034a6936	e38a8fbd-4c9d-4475-ae1b-150a034a6936	برگزاری جلسهٔ آموزش کارکنان جدید #97	\N	high	2026-08-11	615a8b04-5cfd-44a2-9970-fd612747ca83	2026-07-21 18:35:18.932907+00	2026-07-21 18:35:18.932907+00	completed	pending	100	35.20	2026-07-22	medium
efb263c4-05b2-42d2-bc77-af9f0cbd846e	\N	\N	3d944638-fc96-463d-84ac-c7c861324cbe	3d944638-fc96-463d-84ac-c7c861324cbe	تهیهٔ فرم ارزیابی سه‌ماهه #98	\N	high	2026-07-30	478a4a7b-abf8-49ff-993d-9ab84ead7de3	2026-07-21 18:35:18.932907+00	2026-07-21 18:35:18.932907+00	completed	pending	100	29.60	2026-07-25	medium
efb263c4-05b2-42d2-bc77-af9f0cbd846e	\N	\N	eb0b5b71-65c1-4694-a9d0-5b2b7aea8eae	eb0b5b71-65c1-4694-a9d0-5b2b7aea8eae	تهیهٔ گزارش ارزیابی عملکرد #99	\N	high	2026-08-11	f0cfd6bc-5d7b-4042-a6eb-54813dc0602e	2026-07-21 18:35:18.932907+00	2026-07-21 18:35:18.932907+00	in_progress	\N	78	4.10	2026-07-28	medium
efb263c4-05b2-42d2-bc77-af9f0cbd846e	\N	\N	e38a8fbd-4c9d-4475-ae1b-150a034a6936	e38a8fbd-4c9d-4475-ae1b-150a034a6936	تهیهٔ گزارش غیبت و تأخیر #100	\N	medium	2026-08-04	462f9cc1-83aa-463d-b582-1c9a140efa4a	2026-07-21 18:35:18.932907+00	2026-07-21 18:35:18.932907+00	todo	\N	21	4.80	2026-07-18	medium
efb263c4-05b2-42d2-bc77-af9f0cbd846e	\N	\N	eb0b5b71-65c1-4694-a9d0-5b2b7aea8eae	eb0b5b71-65c1-4694-a9d0-5b2b7aea8eae	به‌روزرسانی آیین‌نامهٔ داخلی شرکت #101	\N	low	2026-07-13	6d48d261-0b8d-4a47-81da-87454373e500	2026-07-21 18:35:18.932907+00	2026-07-21 18:35:18.932907+00	in_progress	\N	64	10.50	2026-07-01	medium
efb263c4-05b2-42d2-bc77-af9f0cbd846e	\N	\N	e38a8fbd-4c9d-4475-ae1b-150a034a6936	e38a8fbd-4c9d-4475-ae1b-150a034a6936	برنامه‌ریزی مصاحبهٔ استخدامی #102	\N	medium	2026-07-20	e022ec53-f367-46d7-970f-bbb9e2a6898a	2026-07-21 18:35:18.932907+00	2026-07-21 18:35:18.932907+00	in_progress	\N	56	32.40	2026-07-11	medium
efb263c4-05b2-42d2-bc77-af9f0cbd846e	\N	\N	eb0b5b71-65c1-4694-a9d0-5b2b7aea8eae	eb0b5b71-65c1-4694-a9d0-5b2b7aea8eae	برنامه‌ریزی رویداد تیم‌سازی #103	\N	medium	2026-08-26	20fc850c-3760-4f5b-9808-97a902e04f71	2026-07-21 18:35:18.932907+00	2026-07-21 18:35:18.932907+00	todo	\N	15	39.30	2026-08-09	medium
efb263c4-05b2-42d2-bc77-af9f0cbd846e	\N	\N	e38a8fbd-4c9d-4475-ae1b-150a034a6936	e38a8fbd-4c9d-4475-ae1b-150a034a6936	بررسی رزومه‌های متقاضیان شغلی #104	\N	high	2026-07-26	203825b9-41d2-43ae-995e-8d6d2f9bb1da	2026-07-21 18:35:18.932907+00	2026-07-21 18:35:18.932907+00	completed	approved	100	22.90	2026-07-11	medium
efb263c4-05b2-42d2-bc77-af9f0cbd846e	\N	\N	4bfc028f-1c19-4b0c-9188-9fe233b49cb4	4bfc028f-1c19-4b0c-9188-9fe233b49cb4	تدوین برنامهٔ آموزشی سال آینده #105	\N	high	2026-08-26	c3c59c9d-91cb-4b25-aa72-c0de2c3b1e4b	2026-07-21 18:35:18.932907+00	2026-07-21 18:35:18.932907+00	todo	\N	38	35.80	2026-08-05	medium
\.


--
-- Data for Name: users; Type: TABLE DATA; Schema: public; Owner: -
--

COPY public.users (organization_id, full_name, role, is_active, id, created_at, updated_at, department_id, account_id) FROM stdin;
efb263c4-05b2-42d2-bc77-af9f0cbd846e	مدیر سازمان	org_admin	t	5015f0ba-e578-4955-b532-c78d5f462686	2026-07-21 18:35:18.932907+00	2026-07-21 18:35:18.932907+00	0a2e6fe5-66bd-43c4-aeda-995263e906bf	4b49b01e-742e-4448-94a7-cce610ef9084
efb263c4-05b2-42d2-bc77-af9f0cbd846e	مدیر پروژه مهندسی و فنی	project_manager	t	c0c1258a-257b-4a56-bc50-4efdde442732	2026-07-21 18:35:18.932907+00	2026-07-21 18:35:18.932907+00	0a2e6fe5-66bd-43c4-aeda-995263e906bf	10e8e00c-ded0-4d26-bec6-27ad5e91181e
efb263c4-05b2-42d2-bc77-af9f0cbd846e	کارمند 1 مهندسی و فنی	employee	t	caaef6d7-fee2-48a7-bd4b-3697a88773ea	2026-07-21 18:35:18.932907+00	2026-07-21 18:35:18.932907+00	0a2e6fe5-66bd-43c4-aeda-995263e906bf	31e72aa3-59e9-4a27-a89f-9107b4745e19
efb263c4-05b2-42d2-bc77-af9f0cbd846e	کارمند 2 مهندسی و فنی	employee	t	14420cd5-d1bc-4e91-8063-b90ed9c1d745	2026-07-21 18:35:18.932907+00	2026-07-21 18:35:18.932907+00	0a2e6fe5-66bd-43c4-aeda-995263e906bf	b57398af-b8bc-42b9-9af8-258d6b9a503b
efb263c4-05b2-42d2-bc77-af9f0cbd846e	کارمند 3 مهندسی و فنی	employee	t	2505504d-a7d6-4a58-975c-bed21d1319bd	2026-07-21 18:35:18.932907+00	2026-07-21 18:35:18.932907+00	0a2e6fe5-66bd-43c4-aeda-995263e906bf	847cbd73-f8c1-42f2-a201-1ef8d03f3568
efb263c4-05b2-42d2-bc77-af9f0cbd846e	کارمند 4 مهندسی و فنی	employee	t	2a912655-64c4-44a5-9beb-6093704c47bd	2026-07-21 18:35:18.932907+00	2026-07-21 18:35:18.932907+00	0a2e6fe5-66bd-43c4-aeda-995263e906bf	aa5b71b6-a0d8-43f3-b696-0188c6659df6
efb263c4-05b2-42d2-bc77-af9f0cbd846e	کارمند 5 مهندسی و فنی	employee	t	4cef53c1-898c-4945-b51b-a1d36322bb51	2026-07-21 18:35:18.932907+00	2026-07-21 18:35:18.932907+00	0a2e6fe5-66bd-43c4-aeda-995263e906bf	4d5de859-c5d2-40aa-b5bd-6750522ccc15
efb263c4-05b2-42d2-bc77-af9f0cbd846e	کارمند 6 مهندسی و فنی	employee	t	1bc00cf9-0b6c-453b-8f81-55a9f72ad244	2026-07-21 18:35:18.932907+00	2026-07-21 18:35:18.932907+00	0a2e6fe5-66bd-43c4-aeda-995263e906bf	43703a0f-5bbf-499e-b150-b4166050b9a8
efb263c4-05b2-42d2-bc77-af9f0cbd846e	مدیر پروژه حسابداری و مالی	project_manager	t	e262d280-b97e-4087-8e78-a66519bae4d1	2026-07-21 18:35:18.932907+00	2026-07-21 18:35:18.932907+00	55d14f8b-02b1-4ecf-8561-574e34605a92	8f0c1180-b904-49e6-b320-5c6102502225
efb263c4-05b2-42d2-bc77-af9f0cbd846e	کارمند 1 حسابداری و مالی	employee	t	7dcd0e37-2d6c-4eab-8a6a-3598c4e01433	2026-07-21 18:35:18.932907+00	2026-07-21 18:35:18.932907+00	55d14f8b-02b1-4ecf-8561-574e34605a92	843ff753-4370-4bc8-8e86-8d3da6e97416
efb263c4-05b2-42d2-bc77-af9f0cbd846e	کارمند 2 حسابداری و مالی	employee	t	e73ec14e-ca0c-4615-92d5-5bc43c14999a	2026-07-21 18:35:18.932907+00	2026-07-21 18:35:18.932907+00	55d14f8b-02b1-4ecf-8561-574e34605a92	1c16d574-41cd-45e5-bff5-eb00ddf1f90e
efb263c4-05b2-42d2-bc77-af9f0cbd846e	کارمند 3 حسابداری و مالی	employee	t	c288bac5-e3a4-4f1f-a050-de12845acf11	2026-07-21 18:35:18.932907+00	2026-07-21 18:35:18.932907+00	55d14f8b-02b1-4ecf-8561-574e34605a92	3f0a94fd-4199-44c4-a7b9-dcce9406af77
efb263c4-05b2-42d2-bc77-af9f0cbd846e	کارمند 4 حسابداری و مالی	employee	t	1d9f738d-866c-4e32-9fe8-b80f0b30a62b	2026-07-21 18:35:18.932907+00	2026-07-21 18:35:18.932907+00	55d14f8b-02b1-4ecf-8561-574e34605a92	5a105954-dd93-4e72-9ea8-6a038545fb19
efb263c4-05b2-42d2-bc77-af9f0cbd846e	کارمند 5 حسابداری و مالی	employee	t	1c37102f-d8b4-4bea-bd82-5b862cd46e2b	2026-07-21 18:35:18.932907+00	2026-07-21 18:35:18.932907+00	55d14f8b-02b1-4ecf-8561-574e34605a92	f2793500-0cc7-42de-88eb-f054d563b036
efb263c4-05b2-42d2-bc77-af9f0cbd846e	کارمند 6 حسابداری و مالی	employee	t	faf489ef-0410-4dca-bec1-65dd2fb904ba	2026-07-21 18:35:18.932907+00	2026-07-21 18:35:18.932907+00	55d14f8b-02b1-4ecf-8561-574e34605a92	4b7fd3d9-dec3-4323-b845-3e21fcb9f5b5
efb263c4-05b2-42d2-bc77-af9f0cbd846e	مدیر پروژه منابع انسانی	project_manager	t	89f48814-745b-462e-820c-aff4124c3949	2026-07-21 18:35:18.932907+00	2026-07-21 18:35:18.932907+00	206f67b3-5950-4801-bb4f-194bcf765fdc	30933020-1975-49aa-a568-b42795f02f50
efb263c4-05b2-42d2-bc77-af9f0cbd846e	کارمند 1 منابع انسانی	employee	t	63d308ce-8593-4f45-8c4b-1df63a00732c	2026-07-21 18:35:18.932907+00	2026-07-21 18:35:18.932907+00	206f67b3-5950-4801-bb4f-194bcf765fdc	36d26141-c6e3-4be6-9f53-574eb940b9d9
efb263c4-05b2-42d2-bc77-af9f0cbd846e	کارمند 2 منابع انسانی	employee	t	d9facd7e-b4bd-497f-9f4f-f75e6a932da0	2026-07-21 18:35:18.932907+00	2026-07-21 18:35:18.932907+00	206f67b3-5950-4801-bb4f-194bcf765fdc	9ff96b48-f0c4-4a7a-b91d-61ecfa082913
efb263c4-05b2-42d2-bc77-af9f0cbd846e	کارمند 3 منابع انسانی	employee	t	eb0b5b71-65c1-4694-a9d0-5b2b7aea8eae	2026-07-21 18:35:18.932907+00	2026-07-21 18:35:18.932907+00	206f67b3-5950-4801-bb4f-194bcf765fdc	4cf6809c-116a-43d8-9d46-36e081499444
efb263c4-05b2-42d2-bc77-af9f0cbd846e	کارمند 4 منابع انسانی	employee	t	3d944638-fc96-463d-84ac-c7c861324cbe	2026-07-21 18:35:18.932907+00	2026-07-21 18:35:18.932907+00	206f67b3-5950-4801-bb4f-194bcf765fdc	3277ac40-85b1-406d-b0c2-8830e1f4d03d
efb263c4-05b2-42d2-bc77-af9f0cbd846e	کارمند 5 منابع انسانی	employee	t	e38a8fbd-4c9d-4475-ae1b-150a034a6936	2026-07-21 18:35:18.932907+00	2026-07-21 18:35:18.932907+00	206f67b3-5950-4801-bb4f-194bcf765fdc	2fde7a9c-d11d-4417-bf46-37c0eedad436
efb263c4-05b2-42d2-bc77-af9f0cbd846e	کارمند 6 منابع انسانی	employee	t	4bfc028f-1c19-4b0c-9188-9fe233b49cb4	2026-07-21 18:35:18.932907+00	2026-07-21 18:35:18.932907+00	206f67b3-5950-4801-bb4f-194bcf765fdc	c6919541-2fec-4438-b146-59f0397a48b2
\.


--
-- Data for Name: worklogs; Type: TABLE DATA; Schema: public; Owner: -
--

COPY public.worklogs (organization_id, task_id, user_id, activity_description, time_spent_minutes, progress_percent, log_date, status, reviewed_by_id, review_comment, id, created_at, updated_at) FROM stdin;
efb263c4-05b2-42d2-bc77-af9f0cbd846e	3344b271-a7a4-426c-9d85-1c3406530ce8	2a912655-64c4-44a5-9beb-6093704c47bd	مستندسازی و نهایی‌سازی	118	33	2026-07-16	approved	c0c1258a-257b-4a56-bc50-4efdde442732	\N	9b984acb-f56a-4cbf-86a8-37506e486289	2026-07-21 18:35:18.932907+00	2026-07-21 18:35:18.932907+00
efb263c4-05b2-42d2-bc77-af9f0cbd846e	3344b271-a7a4-426c-9d85-1c3406530ce8	2a912655-64c4-44a5-9beb-6093704c47bd	تست و اطمینان از عملکرد صحیح	99	58	2026-07-16	approved	c0c1258a-257b-4a56-bc50-4efdde442732	\N	161e720a-bc26-4f20-b6c7-9045b7b9409d	2026-07-21 18:35:18.932907+00	2026-07-21 18:35:18.932907+00
efb263c4-05b2-42d2-bc77-af9f0cbd846e	3344b271-a7a4-426c-9d85-1c3406530ce8	2a912655-64c4-44a5-9beb-6093704c47bd	پیاده‌سازی بخش اصلی	110	69	2026-07-16	approved	c0c1258a-257b-4a56-bc50-4efdde442732	\N	5d22d487-eaab-4b47-8b34-6a22c4688026	2026-07-21 18:35:18.932907+00	2026-07-21 18:35:18.932907+00
efb263c4-05b2-42d2-bc77-af9f0cbd846e	efe378eb-0255-4614-9018-f550a6109b77	caaef6d7-fee2-48a7-bd4b-3697a88773ea	تست و اطمینان از عملکرد صحیح	100	38	2026-07-16	approved	c0c1258a-257b-4a56-bc50-4efdde442732	\N	390e5059-d03b-4d20-b660-7e4b86ee11f8	2026-07-21 18:35:18.932907+00	2026-07-21 18:35:18.932907+00
efb263c4-05b2-42d2-bc77-af9f0cbd846e	efe378eb-0255-4614-9018-f550a6109b77	caaef6d7-fee2-48a7-bd4b-3697a88773ea	پیاده‌سازی بخش اصلی	105	54	2026-07-16	submitted	\N	\N	3fdd078a-7a0c-4f95-8ffe-579f227aa9be	2026-07-21 18:35:18.932907+00	2026-07-21 18:35:18.932907+00
efb263c4-05b2-42d2-bc77-af9f0cbd846e	d6029d28-fbd1-4a66-9931-22fce6ddc7a6	1bc00cf9-0b6c-453b-8f81-55a9f72ad244	مستندسازی و نهایی‌سازی	62	28	2026-07-16	approved	c0c1258a-257b-4a56-bc50-4efdde442732	\N	d8178a91-558e-4bf5-b524-eef8aefe714f	2026-07-21 18:35:18.932907+00	2026-07-21 18:35:18.932907+00
efb263c4-05b2-42d2-bc77-af9f0cbd846e	d6029d28-fbd1-4a66-9931-22fce6ddc7a6	1bc00cf9-0b6c-453b-8f81-55a9f72ad244	مستندسازی و نهایی‌سازی	104	48	2026-07-16	submitted	\N	\N	f30f5063-cd3c-480b-aaa4-fbf57373f63a	2026-07-21 18:35:18.932907+00	2026-07-21 18:35:18.932907+00
efb263c4-05b2-42d2-bc77-af9f0cbd846e	d6029d28-fbd1-4a66-9931-22fce6ddc7a6	1bc00cf9-0b6c-453b-8f81-55a9f72ad244	پیشرفت اولیه و بررسی نیازمندی‌ها	176	87	2026-07-16	approved	c0c1258a-257b-4a56-bc50-4efdde442732	\N	686f3f8a-605c-4e86-9e95-96ce4881d26a	2026-07-21 18:35:18.932907+00	2026-07-21 18:35:18.932907+00
efb263c4-05b2-42d2-bc77-af9f0cbd846e	bf0c6407-bb76-4975-b590-3ad017813129	14420cd5-d1bc-4e91-8063-b90ed9c1d745	تست و اطمینان از عملکرد صحیح	117	25	2026-06-20	approved	c0c1258a-257b-4a56-bc50-4efdde442732	\N	19af8a89-6798-4111-9aac-4dba157954e5	2026-07-21 18:35:18.932907+00	2026-07-21 18:35:18.932907+00
efb263c4-05b2-42d2-bc77-af9f0cbd846e	bf0c6407-bb76-4975-b590-3ad017813129	14420cd5-d1bc-4e91-8063-b90ed9c1d745	رفع اشکالات و بازبینی	152	46	2026-06-21	approved	c0c1258a-257b-4a56-bc50-4efdde442732	\N	7764c24f-5d1a-4a75-803d-2a3b5c144066	2026-07-21 18:35:18.932907+00	2026-07-21 18:35:18.932907+00
efb263c4-05b2-42d2-bc77-af9f0cbd846e	bf0c6407-bb76-4975-b590-3ad017813129	14420cd5-d1bc-4e91-8063-b90ed9c1d745	تست و اطمینان از عملکرد صحیح	155	66	2026-06-22	approved	c0c1258a-257b-4a56-bc50-4efdde442732	\N	599221d3-d0ff-4e68-b349-5db54ea6c17d	2026-07-21 18:35:18.932907+00	2026-07-21 18:35:18.932907+00
efb263c4-05b2-42d2-bc77-af9f0cbd846e	bf0c6407-bb76-4975-b590-3ad017813129	14420cd5-d1bc-4e91-8063-b90ed9c1d745	پیاده‌سازی بخش اصلی	68	100	2026-06-23	approved	c0c1258a-257b-4a56-bc50-4efdde442732	\N	11531b84-58e2-444e-a162-727d78f11816	2026-07-21 18:35:18.932907+00	2026-07-21 18:35:18.932907+00
efb263c4-05b2-42d2-bc77-af9f0cbd846e	9298c330-ac91-4c64-8125-7cf3a6cf2ae8	c0c1258a-257b-4a56-bc50-4efdde442732	پیشرفت اولیه و بررسی نیازمندی‌ها	172	33	2026-07-16	submitted	\N	\N	52bd290c-25b5-447f-b600-b1ae531308f3	2026-07-21 18:35:18.932907+00	2026-07-21 18:35:18.932907+00
efb263c4-05b2-42d2-bc77-af9f0cbd846e	9298c330-ac91-4c64-8125-7cf3a6cf2ae8	c0c1258a-257b-4a56-bc50-4efdde442732	تست و اطمینان از عملکرد صحیح	145	68	2026-07-16	submitted	\N	\N	19eb09c0-b46d-4667-b51d-a679482da0b8	2026-07-21 18:35:18.932907+00	2026-07-21 18:35:18.932907+00
efb263c4-05b2-42d2-bc77-af9f0cbd846e	9298c330-ac91-4c64-8125-7cf3a6cf2ae8	c0c1258a-257b-4a56-bc50-4efdde442732	تست و اطمینان از عملکرد صحیح	108	100	2026-07-16	submitted	\N	\N	1e7f389b-5de7-47f6-804c-491a83ce93b5	2026-07-21 18:35:18.932907+00	2026-07-21 18:35:18.932907+00
efb263c4-05b2-42d2-bc77-af9f0cbd846e	66681e8b-5a94-48c4-8c1d-55304a7e72e8	4cef53c1-898c-4945-b51b-a1d36322bb51	پیاده‌سازی بخش اصلی	190	26	2026-07-16	approved	c0c1258a-257b-4a56-bc50-4efdde442732	\N	d5e436a3-34a9-4df8-beac-744d6689aee1	2026-07-21 18:35:18.932907+00	2026-07-21 18:35:18.932907+00
efb263c4-05b2-42d2-bc77-af9f0cbd846e	e6775c6f-be2a-4808-a240-264f48dc3c4f	2505504d-a7d6-4a58-975c-bed21d1319bd	پیاده‌سازی بخش اصلی	171	22	2026-07-03	approved	c0c1258a-257b-4a56-bc50-4efdde442732	\N	2923e75d-a717-4d84-ae40-23a4162f8f75	2026-07-21 18:35:18.932907+00	2026-07-21 18:35:18.932907+00
efb263c4-05b2-42d2-bc77-af9f0cbd846e	e6775c6f-be2a-4808-a240-264f48dc3c4f	2505504d-a7d6-4a58-975c-bed21d1319bd	تست و اطمینان از عملکرد صحیح	206	78	2026-07-05	approved	c0c1258a-257b-4a56-bc50-4efdde442732	\N	30e1fbaf-5295-4f35-a86f-728602ceb435	2026-07-21 18:35:18.932907+00	2026-07-21 18:35:18.932907+00
efb263c4-05b2-42d2-bc77-af9f0cbd846e	e6775c6f-be2a-4808-a240-264f48dc3c4f	2505504d-a7d6-4a58-975c-bed21d1319bd	پیاده‌سازی بخش اصلی	103	87	2026-07-11	approved	c0c1258a-257b-4a56-bc50-4efdde442732	\N	afd0453f-eee7-49c2-a14f-81a028268dbc	2026-07-21 18:35:18.932907+00	2026-07-21 18:35:18.932907+00
efb263c4-05b2-42d2-bc77-af9f0cbd846e	6815e38a-f877-422d-bae7-f753339d7801	caaef6d7-fee2-48a7-bd4b-3697a88773ea	پیاده‌سازی بخش اصلی	97	40	2026-07-06	approved	c0c1258a-257b-4a56-bc50-4efdde442732	\N	f49f93cb-f425-48c3-a46e-96d2a6f60eef	2026-07-21 18:35:18.932907+00	2026-07-21 18:35:18.932907+00
efb263c4-05b2-42d2-bc77-af9f0cbd846e	6815e38a-f877-422d-bae7-f753339d7801	caaef6d7-fee2-48a7-bd4b-3697a88773ea	تست و اطمینان از عملکرد صحیح	59	74	2026-07-08	approved	c0c1258a-257b-4a56-bc50-4efdde442732	\N	8898486a-e057-44b6-8ed8-97aa1ef74450	2026-07-21 18:35:18.932907+00	2026-07-21 18:35:18.932907+00
efb263c4-05b2-42d2-bc77-af9f0cbd846e	6815e38a-f877-422d-bae7-f753339d7801	caaef6d7-fee2-48a7-bd4b-3697a88773ea	پیاده‌سازی بخش اصلی	98	72	2026-07-10	approved	c0c1258a-257b-4a56-bc50-4efdde442732	\N	a18f96a2-0927-46f7-9dfa-04d1dd7f819a	2026-07-21 18:35:18.932907+00	2026-07-21 18:35:18.932907+00
efb263c4-05b2-42d2-bc77-af9f0cbd846e	6815e38a-f877-422d-bae7-f753339d7801	caaef6d7-fee2-48a7-bd4b-3697a88773ea	پیشرفت اولیه و بررسی نیازمندی‌ها	72	100	2026-07-09	approved	c0c1258a-257b-4a56-bc50-4efdde442732	\N	ac51fa43-1025-4365-abab-759d3bfd8238	2026-07-21 18:35:18.932907+00	2026-07-21 18:35:18.932907+00
efb263c4-05b2-42d2-bc77-af9f0cbd846e	3dee5261-53c4-4b23-9696-6b8b40719822	4cef53c1-898c-4945-b51b-a1d36322bb51	پیشرفت اولیه و بررسی نیازمندی‌ها	149	29	2026-06-24	approved	c0c1258a-257b-4a56-bc50-4efdde442732	\N	468d21d4-f841-4268-a21f-a6c81c2271ff	2026-07-21 18:35:18.932907+00	2026-07-21 18:35:18.932907+00
efb263c4-05b2-42d2-bc77-af9f0cbd846e	3dee5261-53c4-4b23-9696-6b8b40719822	4cef53c1-898c-4945-b51b-a1d36322bb51	رفع اشکالات و بازبینی	158	74	2026-06-28	approved	c0c1258a-257b-4a56-bc50-4efdde442732	\N	c3e5de02-f238-4ecf-ab44-a84dc21af945	2026-07-21 18:35:18.932907+00	2026-07-21 18:35:18.932907+00
efb263c4-05b2-42d2-bc77-af9f0cbd846e	3dee5261-53c4-4b23-9696-6b8b40719822	4cef53c1-898c-4945-b51b-a1d36322bb51	تست و اطمینان از عملکرد صحیح	50	100	2026-07-02	approved	c0c1258a-257b-4a56-bc50-4efdde442732	\N	cd1d9998-ee0c-482e-8012-bb7af591123c	2026-07-21 18:35:18.932907+00	2026-07-21 18:35:18.932907+00
efb263c4-05b2-42d2-bc77-af9f0cbd846e	7a7351b6-2750-4846-90f1-9ab74835ec05	4cef53c1-898c-4945-b51b-a1d36322bb51	رفع اشکالات و بازبینی	184	28	2026-07-16	approved	c0c1258a-257b-4a56-bc50-4efdde442732	\N	151f7ecb-27b0-4b9e-b98e-0d53d91e7205	2026-07-21 18:35:18.932907+00	2026-07-21 18:35:18.932907+00
efb263c4-05b2-42d2-bc77-af9f0cbd846e	c9507331-b60c-41d6-a434-8d64b6332108	caaef6d7-fee2-48a7-bd4b-3697a88773ea	پیاده‌سازی بخش اصلی	202	38	2026-07-16	approved	c0c1258a-257b-4a56-bc50-4efdde442732	\N	b79581a7-f3d5-46b7-9e72-dde5a92b206f	2026-07-21 18:35:18.932907+00	2026-07-21 18:35:18.932907+00
efb263c4-05b2-42d2-bc77-af9f0cbd846e	edd10da0-cbb2-4fa4-87f6-d682a5627958	caaef6d7-fee2-48a7-bd4b-3697a88773ea	مستندسازی و نهایی‌سازی	40	25	2026-06-20	approved	c0c1258a-257b-4a56-bc50-4efdde442732	\N	82857e4a-3aff-42ac-8e53-8fb145d80191	2026-07-21 18:35:18.932907+00	2026-07-21 18:35:18.932907+00
efb263c4-05b2-42d2-bc77-af9f0cbd846e	ef57cf52-d9fe-4495-b739-6c30e2a9476d	2a912655-64c4-44a5-9beb-6093704c47bd	پیاده‌سازی بخش اصلی	179	33	2026-07-16	submitted	\N	\N	120e78d5-e6da-4a3e-b7a4-a3f8ded3f0d4	2026-07-21 18:35:18.932907+00	2026-07-21 18:35:18.932907+00
efb263c4-05b2-42d2-bc77-af9f0cbd846e	ef57cf52-d9fe-4495-b739-6c30e2a9476d	2a912655-64c4-44a5-9beb-6093704c47bd	تست و اطمینان از عملکرد صحیح	119	66	2026-07-16	submitted	\N	\N	a1603dad-e8a5-429a-823a-2e4079038fb4	2026-07-21 18:35:18.932907+00	2026-07-21 18:35:18.932907+00
efb263c4-05b2-42d2-bc77-af9f0cbd846e	ef57cf52-d9fe-4495-b739-6c30e2a9476d	2a912655-64c4-44a5-9beb-6093704c47bd	پیشرفت اولیه و بررسی نیازمندی‌ها	71	90	2026-07-16	approved	c0c1258a-257b-4a56-bc50-4efdde442732	\N	dc8620fc-5b6a-4d4a-bd72-a74e67d946bc	2026-07-21 18:35:18.932907+00	2026-07-21 18:35:18.932907+00
efb263c4-05b2-42d2-bc77-af9f0cbd846e	ef57cf52-d9fe-4495-b739-6c30e2a9476d	2a912655-64c4-44a5-9beb-6093704c47bd	رفع اشکالات و بازبینی	199	100	2026-07-16	approved	c0c1258a-257b-4a56-bc50-4efdde442732	\N	05329bab-c949-4a88-adc4-fadb82b88500	2026-07-21 18:35:18.932907+00	2026-07-21 18:35:18.932907+00
efb263c4-05b2-42d2-bc77-af9f0cbd846e	6550c1b4-a467-4d56-8740-f7537ccc917d	2a912655-64c4-44a5-9beb-6093704c47bd	پیشرفت اولیه و بررسی نیازمندی‌ها	110	28	2026-07-03	approved	c0c1258a-257b-4a56-bc50-4efdde442732	\N	3356298a-9b29-44e6-a898-c706b8d886b3	2026-07-21 18:35:18.932907+00	2026-07-21 18:35:18.932907+00
efb263c4-05b2-42d2-bc77-af9f0cbd846e	454fbd0e-4232-4719-8654-793379dc63da	c0c1258a-257b-4a56-bc50-4efdde442732	تست و اطمینان از عملکرد صحیح	161	20	2026-07-16	approved	c0c1258a-257b-4a56-bc50-4efdde442732	\N	6ce96ea4-9eae-42c2-939d-26e7e7f4d18a	2026-07-21 18:35:18.932907+00	2026-07-21 18:35:18.932907+00
efb263c4-05b2-42d2-bc77-af9f0cbd846e	454fbd0e-4232-4719-8654-793379dc63da	c0c1258a-257b-4a56-bc50-4efdde442732	تست و اطمینان از عملکرد صحیح	43	52	2026-07-16	approved	c0c1258a-257b-4a56-bc50-4efdde442732	\N	5cad58f7-9359-484f-9482-897377b4374c	2026-07-21 18:35:18.932907+00	2026-07-21 18:35:18.932907+00
efb263c4-05b2-42d2-bc77-af9f0cbd846e	454fbd0e-4232-4719-8654-793379dc63da	c0c1258a-257b-4a56-bc50-4efdde442732	مستندسازی و نهایی‌سازی	223	100	2026-07-16	approved	c0c1258a-257b-4a56-bc50-4efdde442732	\N	67679121-1c67-43d7-8531-f9b49df412d6	2026-07-21 18:35:18.932907+00	2026-07-21 18:35:18.932907+00
efb263c4-05b2-42d2-bc77-af9f0cbd846e	a887db68-83b4-4099-bb12-c4b2c13b3f5c	1bc00cf9-0b6c-453b-8f81-55a9f72ad244	پیاده‌سازی بخش اصلی	98	37	2026-07-16	approved	c0c1258a-257b-4a56-bc50-4efdde442732	\N	d2a491be-e9f4-4c8a-8bdf-197f7ac848d7	2026-07-21 18:35:18.932907+00	2026-07-21 18:35:18.932907+00
efb263c4-05b2-42d2-bc77-af9f0cbd846e	a887db68-83b4-4099-bb12-c4b2c13b3f5c	1bc00cf9-0b6c-453b-8f81-55a9f72ad244	رفع اشکالات و بازبینی	142	70	2026-07-16	approved	c0c1258a-257b-4a56-bc50-4efdde442732	\N	5c947168-7608-463f-8c85-8078a1e00e3a	2026-07-21 18:35:18.932907+00	2026-07-21 18:35:18.932907+00
efb263c4-05b2-42d2-bc77-af9f0cbd846e	a887db68-83b4-4099-bb12-c4b2c13b3f5c	1bc00cf9-0b6c-453b-8f81-55a9f72ad244	پیشرفت اولیه و بررسی نیازمندی‌ها	191	100	2026-07-16	approved	c0c1258a-257b-4a56-bc50-4efdde442732	\N	077a6c68-6937-4b07-85f8-a77d7f8d6464	2026-07-21 18:35:18.932907+00	2026-07-21 18:35:18.932907+00
efb263c4-05b2-42d2-bc77-af9f0cbd846e	a887db68-83b4-4099-bb12-c4b2c13b3f5c	1bc00cf9-0b6c-453b-8f81-55a9f72ad244	پیاده‌سازی بخش اصلی	109	100	2026-07-16	approved	c0c1258a-257b-4a56-bc50-4efdde442732	\N	7ff556c0-cfdc-4747-b83d-2390108575cd	2026-07-21 18:35:18.932907+00	2026-07-21 18:35:18.932907+00
efb263c4-05b2-42d2-bc77-af9f0cbd846e	3b1f6aab-0c85-4ac1-99bc-93033b4880ce	caaef6d7-fee2-48a7-bd4b-3697a88773ea	پیشرفت اولیه و بررسی نیازمندی‌ها	87	23	2026-07-16	approved	c0c1258a-257b-4a56-bc50-4efdde442732	\N	9ddc2c07-7a61-42bc-ad87-62e5242ce3a1	2026-07-21 18:35:18.932907+00	2026-07-21 18:35:18.932907+00
efb263c4-05b2-42d2-bc77-af9f0cbd846e	db934a4a-92bc-4232-8d8e-65ad0bbdca7f	2505504d-a7d6-4a58-975c-bed21d1319bd	پیاده‌سازی بخش اصلی	157	29	2026-07-16	approved	c0c1258a-257b-4a56-bc50-4efdde442732	\N	6f8a4638-b92c-4c94-b1c2-8f32388d923d	2026-07-21 18:35:18.932907+00	2026-07-21 18:35:18.932907+00
efb263c4-05b2-42d2-bc77-af9f0cbd846e	db934a4a-92bc-4232-8d8e-65ad0bbdca7f	2505504d-a7d6-4a58-975c-bed21d1319bd	تست و اطمینان از عملکرد صحیح	150	54	2026-07-16	approved	c0c1258a-257b-4a56-bc50-4efdde442732	\N	25134b97-2eb0-4836-b043-bfe959180a0e	2026-07-21 18:35:18.932907+00	2026-07-21 18:35:18.932907+00
efb263c4-05b2-42d2-bc77-af9f0cbd846e	db934a4a-92bc-4232-8d8e-65ad0bbdca7f	2505504d-a7d6-4a58-975c-bed21d1319bd	تست و اطمینان از عملکرد صحیح	78	100	2026-07-16	approved	c0c1258a-257b-4a56-bc50-4efdde442732	\N	b633594a-4ee0-4c67-a000-79469fbda07d	2026-07-21 18:35:18.932907+00	2026-07-21 18:35:18.932907+00
efb263c4-05b2-42d2-bc77-af9f0cbd846e	db934a4a-92bc-4232-8d8e-65ad0bbdca7f	2505504d-a7d6-4a58-975c-bed21d1319bd	رفع اشکالات و بازبینی	227	100	2026-07-16	submitted	\N	\N	a79ebdd7-7397-45a3-9eb6-bd67bd817322	2026-07-21 18:35:18.932907+00	2026-07-21 18:35:18.932907+00
efb263c4-05b2-42d2-bc77-af9f0cbd846e	1bcab334-e818-4747-82d8-de6d19656265	2505504d-a7d6-4a58-975c-bed21d1319bd	پیشرفت اولیه و بررسی نیازمندی‌ها	102	29	2026-07-14	approved	c0c1258a-257b-4a56-bc50-4efdde442732	\N	3384dec7-4280-47b4-bd58-523dd798f07b	2026-07-21 18:35:18.932907+00	2026-07-21 18:35:18.932907+00
efb263c4-05b2-42d2-bc77-af9f0cbd846e	1bcab334-e818-4747-82d8-de6d19656265	2505504d-a7d6-4a58-975c-bed21d1319bd	پیاده‌سازی بخش اصلی	144	74	2026-07-16	approved	c0c1258a-257b-4a56-bc50-4efdde442732	\N	1608b445-957f-4419-b168-2799ba661354	2026-07-21 18:35:18.932907+00	2026-07-21 18:35:18.932907+00
efb263c4-05b2-42d2-bc77-af9f0cbd846e	1bcab334-e818-4747-82d8-de6d19656265	2505504d-a7d6-4a58-975c-bed21d1319bd	رفع اشکالات و بازبینی	115	100	2026-07-16	approved	c0c1258a-257b-4a56-bc50-4efdde442732	\N	cf2667ea-b984-49f1-9fea-c17435dd8c1a	2026-07-21 18:35:18.932907+00	2026-07-21 18:35:18.932907+00
efb263c4-05b2-42d2-bc77-af9f0cbd846e	0453889c-4326-48b8-b698-7df925d456a0	c0c1258a-257b-4a56-bc50-4efdde442732	پیاده‌سازی بخش اصلی	208	27	2026-06-17	submitted	\N	\N	26bd4433-51b4-43de-84d5-92eef4497ac1	2026-07-21 18:35:18.932907+00	2026-07-21 18:35:18.932907+00
efb263c4-05b2-42d2-bc77-af9f0cbd846e	0453889c-4326-48b8-b698-7df925d456a0	c0c1258a-257b-4a56-bc50-4efdde442732	تست و اطمینان از عملکرد صحیح	41	60	2026-06-21	approved	c0c1258a-257b-4a56-bc50-4efdde442732	\N	4aa3aecd-134c-46c2-a259-e36544b2d8ee	2026-07-21 18:35:18.932907+00	2026-07-21 18:35:18.932907+00
efb263c4-05b2-42d2-bc77-af9f0cbd846e	0453889c-4326-48b8-b698-7df925d456a0	c0c1258a-257b-4a56-bc50-4efdde442732	تست و اطمینان از عملکرد صحیح	128	100	2026-06-25	submitted	\N	\N	4ff7a4e9-5bc1-477d-b64d-acea67fe9cff	2026-07-21 18:35:18.932907+00	2026-07-21 18:35:18.932907+00
efb263c4-05b2-42d2-bc77-af9f0cbd846e	0453889c-4326-48b8-b698-7df925d456a0	c0c1258a-257b-4a56-bc50-4efdde442732	پیشرفت اولیه و بررسی نیازمندی‌ها	62	100	2026-06-23	approved	c0c1258a-257b-4a56-bc50-4efdde442732	\N	c77438da-264e-47f3-81ed-2c33ad8f5e6a	2026-07-21 18:35:18.932907+00	2026-07-21 18:35:18.932907+00
efb263c4-05b2-42d2-bc77-af9f0cbd846e	5b92ff8d-9192-46ba-ae78-48b8dd2fe13a	c0c1258a-257b-4a56-bc50-4efdde442732	تست و اطمینان از عملکرد صحیح	55	36	2026-07-16	approved	c0c1258a-257b-4a56-bc50-4efdde442732	\N	ca1a76df-6eb1-4b35-9011-f963c4c666d4	2026-07-21 18:35:18.932907+00	2026-07-21 18:35:18.932907+00
efb263c4-05b2-42d2-bc77-af9f0cbd846e	5b92ff8d-9192-46ba-ae78-48b8dd2fe13a	c0c1258a-257b-4a56-bc50-4efdde442732	پیشرفت اولیه و بررسی نیازمندی‌ها	214	48	2026-07-16	approved	c0c1258a-257b-4a56-bc50-4efdde442732	\N	424f11cf-52cf-4cf9-bccd-aef304b60fb9	2026-07-21 18:35:18.932907+00	2026-07-21 18:35:18.932907+00
efb263c4-05b2-42d2-bc77-af9f0cbd846e	5b92ff8d-9192-46ba-ae78-48b8dd2fe13a	c0c1258a-257b-4a56-bc50-4efdde442732	پیاده‌سازی بخش اصلی	49	100	2026-07-16	approved	c0c1258a-257b-4a56-bc50-4efdde442732	\N	4e74d8c7-3f7a-4b6e-b2af-7f69c3c2d956	2026-07-21 18:35:18.932907+00	2026-07-21 18:35:18.932907+00
efb263c4-05b2-42d2-bc77-af9f0cbd846e	15f99e35-3c31-4ff9-833c-ebb62cbd2a5d	c0c1258a-257b-4a56-bc50-4efdde442732	مستندسازی و نهایی‌سازی	207	32	2026-07-16	approved	c0c1258a-257b-4a56-bc50-4efdde442732	\N	9da4079d-4173-4b9e-81f0-9ef6511c1785	2026-07-21 18:35:18.932907+00	2026-07-21 18:35:18.932907+00
efb263c4-05b2-42d2-bc77-af9f0cbd846e	15f99e35-3c31-4ff9-833c-ebb62cbd2a5d	c0c1258a-257b-4a56-bc50-4efdde442732	رفع اشکالات و بازبینی	202	74	2026-07-16	approved	c0c1258a-257b-4a56-bc50-4efdde442732	\N	17698d2c-35b9-4d8c-bcaf-8a2b0fb055d8	2026-07-21 18:35:18.932907+00	2026-07-21 18:35:18.932907+00
efb263c4-05b2-42d2-bc77-af9f0cbd846e	15f99e35-3c31-4ff9-833c-ebb62cbd2a5d	c0c1258a-257b-4a56-bc50-4efdde442732	رفع اشکالات و بازبینی	190	100	2026-07-16	approved	c0c1258a-257b-4a56-bc50-4efdde442732	\N	a6b1aaa0-4b06-450a-a1f4-39dad7ab7f10	2026-07-21 18:35:18.932907+00	2026-07-21 18:35:18.932907+00
efb263c4-05b2-42d2-bc77-af9f0cbd846e	18d0e16f-b59b-4542-bf28-fa231b18cf60	2a912655-64c4-44a5-9beb-6093704c47bd	پیاده‌سازی بخش اصلی	191	29	2026-07-16	approved	c0c1258a-257b-4a56-bc50-4efdde442732	\N	a11d8fd6-9519-4be8-ba90-e4be9f1b8daa	2026-07-21 18:35:18.932907+00	2026-07-21 18:35:18.932907+00
efb263c4-05b2-42d2-bc77-af9f0cbd846e	45612307-60b2-4a3d-afaf-4599f436f141	c0c1258a-257b-4a56-bc50-4efdde442732	تست و اطمینان از عملکرد صحیح	55	40	2026-07-13	approved	c0c1258a-257b-4a56-bc50-4efdde442732	\N	c829bc8b-ab70-484c-b5ab-4794839ecc63	2026-07-21 18:35:18.932907+00	2026-07-21 18:35:18.932907+00
efb263c4-05b2-42d2-bc77-af9f0cbd846e	45612307-60b2-4a3d-afaf-4599f436f141	c0c1258a-257b-4a56-bc50-4efdde442732	تست و اطمینان از عملکرد صحیح	72	58	2026-07-14	approved	c0c1258a-257b-4a56-bc50-4efdde442732	\N	56a0e842-1a10-47c9-a0c8-592cdd30e21c	2026-07-21 18:35:18.932907+00	2026-07-21 18:35:18.932907+00
efb263c4-05b2-42d2-bc77-af9f0cbd846e	b5d9b271-c257-43dc-bd40-ab2dbbc9cd49	4cef53c1-898c-4945-b51b-a1d36322bb51	رفع اشکالات و بازبینی	233	21	2026-07-11	approved	c0c1258a-257b-4a56-bc50-4efdde442732	\N	833ff73c-1e57-4022-8f2b-be6ec19b1dff	2026-07-21 18:35:18.932907+00	2026-07-21 18:35:18.932907+00
efb263c4-05b2-42d2-bc77-af9f0cbd846e	c0cbabcd-1910-4b2c-8e59-087db2c5294e	caaef6d7-fee2-48a7-bd4b-3697a88773ea	رفع اشکالات و بازبینی	140	24	2026-07-13	approved	c0c1258a-257b-4a56-bc50-4efdde442732	\N	4f54fabe-0cd4-4421-8209-f9a39af396ea	2026-07-21 18:35:18.932907+00	2026-07-21 18:35:18.932907+00
efb263c4-05b2-42d2-bc77-af9f0cbd846e	c0cbabcd-1910-4b2c-8e59-087db2c5294e	caaef6d7-fee2-48a7-bd4b-3697a88773ea	مستندسازی و نهایی‌سازی	135	76	2026-07-15	approved	c0c1258a-257b-4a56-bc50-4efdde442732	\N	74534380-2079-4073-8f15-833435cc49dc	2026-07-21 18:35:18.932907+00	2026-07-21 18:35:18.932907+00
efb263c4-05b2-42d2-bc77-af9f0cbd846e	c0cbabcd-1910-4b2c-8e59-087db2c5294e	caaef6d7-fee2-48a7-bd4b-3697a88773ea	پیاده‌سازی بخش اصلی	74	66	2026-07-16	approved	c0c1258a-257b-4a56-bc50-4efdde442732	\N	2415fb79-a7a8-4ce8-bd9a-966fc712ff38	2026-07-21 18:35:18.932907+00	2026-07-21 18:35:18.932907+00
efb263c4-05b2-42d2-bc77-af9f0cbd846e	9a0fc5c3-2243-4069-9920-cd38d27460f1	c0c1258a-257b-4a56-bc50-4efdde442732	تست و اطمینان از عملکرد صحیح	179	24	2026-07-16	approved	c0c1258a-257b-4a56-bc50-4efdde442732	\N	cf1f216f-c00b-4134-a961-53ba0c3b9883	2026-07-21 18:35:18.932907+00	2026-07-21 18:35:18.932907+00
efb263c4-05b2-42d2-bc77-af9f0cbd846e	9a0fc5c3-2243-4069-9920-cd38d27460f1	c0c1258a-257b-4a56-bc50-4efdde442732	تست و اطمینان از عملکرد صحیح	193	56	2026-07-16	approved	c0c1258a-257b-4a56-bc50-4efdde442732	\N	bc5a10b2-cc57-4175-afaf-87938bbd2e75	2026-07-21 18:35:18.932907+00	2026-07-21 18:35:18.932907+00
efb263c4-05b2-42d2-bc77-af9f0cbd846e	9a0fc5c3-2243-4069-9920-cd38d27460f1	c0c1258a-257b-4a56-bc50-4efdde442732	رفع اشکالات و بازبینی	200	60	2026-07-16	approved	c0c1258a-257b-4a56-bc50-4efdde442732	\N	cc4df751-6da2-4c06-b8d9-42fe151b3a1b	2026-07-21 18:35:18.932907+00	2026-07-21 18:35:18.932907+00
efb263c4-05b2-42d2-bc77-af9f0cbd846e	9a0fc5c3-2243-4069-9920-cd38d27460f1	c0c1258a-257b-4a56-bc50-4efdde442732	رفع اشکالات و بازبینی	203	100	2026-07-16	approved	c0c1258a-257b-4a56-bc50-4efdde442732	\N	4e90d0bb-3eb5-46b7-9373-bb562034ab9e	2026-07-21 18:35:18.932907+00	2026-07-21 18:35:18.932907+00
efb263c4-05b2-42d2-bc77-af9f0cbd846e	c335afdd-276e-436b-83e4-c02473666c0c	1bc00cf9-0b6c-453b-8f81-55a9f72ad244	رفع اشکالات و بازبینی	180	29	2026-07-16	approved	c0c1258a-257b-4a56-bc50-4efdde442732	\N	023a6497-aed9-40f0-9d3a-7d735ba9e29c	2026-07-21 18:35:18.932907+00	2026-07-21 18:35:18.932907+00
efb263c4-05b2-42d2-bc77-af9f0cbd846e	c335afdd-276e-436b-83e4-c02473666c0c	1bc00cf9-0b6c-453b-8f81-55a9f72ad244	تست و اطمینان از عملکرد صحیح	107	52	2026-07-16	approved	c0c1258a-257b-4a56-bc50-4efdde442732	\N	3a6d239d-c838-4658-aace-0b3265dcacd2	2026-07-21 18:35:18.932907+00	2026-07-21 18:35:18.932907+00
efb263c4-05b2-42d2-bc77-af9f0cbd846e	27764649-b103-41dc-913a-f199c17c985b	14420cd5-d1bc-4e91-8063-b90ed9c1d745	پیشرفت اولیه و بررسی نیازمندی‌ها	90	32	2026-07-16	approved	c0c1258a-257b-4a56-bc50-4efdde442732	\N	983bedef-4e2b-43d4-b65a-223ea04bd1a0	2026-07-21 18:35:18.932907+00	2026-07-21 18:35:18.932907+00
efb263c4-05b2-42d2-bc77-af9f0cbd846e	27764649-b103-41dc-913a-f199c17c985b	14420cd5-d1bc-4e91-8063-b90ed9c1d745	مستندسازی و نهایی‌سازی	105	58	2026-07-16	approved	c0c1258a-257b-4a56-bc50-4efdde442732	\N	6217535d-305f-4025-8120-018ae6e2b4d4	2026-07-21 18:35:18.932907+00	2026-07-21 18:35:18.932907+00
efb263c4-05b2-42d2-bc77-af9f0cbd846e	27764649-b103-41dc-913a-f199c17c985b	14420cd5-d1bc-4e91-8063-b90ed9c1d745	تست و اطمینان از عملکرد صحیح	100	60	2026-07-16	approved	c0c1258a-257b-4a56-bc50-4efdde442732	\N	e8fc8674-5718-4b10-8115-e52ab727e84e	2026-07-21 18:35:18.932907+00	2026-07-21 18:35:18.932907+00
efb263c4-05b2-42d2-bc77-af9f0cbd846e	27764649-b103-41dc-913a-f199c17c985b	14420cd5-d1bc-4e91-8063-b90ed9c1d745	مستندسازی و نهایی‌سازی	220	100	2026-07-16	approved	c0c1258a-257b-4a56-bc50-4efdde442732	\N	af5ccea2-d87e-4ff3-8af8-41cd380db597	2026-07-21 18:35:18.932907+00	2026-07-21 18:35:18.932907+00
efb263c4-05b2-42d2-bc77-af9f0cbd846e	841d82b4-0920-4bca-8a90-efd6cf388417	caaef6d7-fee2-48a7-bd4b-3697a88773ea	رفع اشکالات و بازبینی	86	40	2026-06-29	approved	c0c1258a-257b-4a56-bc50-4efdde442732	\N	cb7615c4-8204-4237-b322-5b412a324716	2026-07-21 18:35:18.932907+00	2026-07-21 18:35:18.932907+00
efb263c4-05b2-42d2-bc77-af9f0cbd846e	841d82b4-0920-4bca-8a90-efd6cf388417	caaef6d7-fee2-48a7-bd4b-3697a88773ea	پیاده‌سازی بخش اصلی	190	46	2026-07-01	approved	c0c1258a-257b-4a56-bc50-4efdde442732	\N	d9299297-0005-4c79-8533-67333317075a	2026-07-21 18:35:18.932907+00	2026-07-21 18:35:18.932907+00
efb263c4-05b2-42d2-bc77-af9f0cbd846e	841d82b4-0920-4bca-8a90-efd6cf388417	caaef6d7-fee2-48a7-bd4b-3697a88773ea	تست و اطمینان از عملکرد صحیح	38	100	2026-07-01	approved	c0c1258a-257b-4a56-bc50-4efdde442732	\N	5e88c042-1cd4-4059-a713-63189cd98b0c	2026-07-21 18:35:18.932907+00	2026-07-21 18:35:18.932907+00
efb263c4-05b2-42d2-bc77-af9f0cbd846e	a64c7b6a-1ec6-42b0-b46a-259eff9045ce	caaef6d7-fee2-48a7-bd4b-3697a88773ea	رفع اشکالات و بازبینی	113	33	2026-06-23	approved	c0c1258a-257b-4a56-bc50-4efdde442732	\N	c5cfead7-d2f1-4454-820d-2742c21ed215	2026-07-21 18:35:18.932907+00	2026-07-21 18:35:18.932907+00
efb263c4-05b2-42d2-bc77-af9f0cbd846e	a64c7b6a-1ec6-42b0-b46a-259eff9045ce	caaef6d7-fee2-48a7-bd4b-3697a88773ea	مستندسازی و نهایی‌سازی	123	72	2026-06-25	approved	c0c1258a-257b-4a56-bc50-4efdde442732	\N	6d004f77-1d11-4c5c-b346-86cb1672b8d3	2026-07-21 18:35:18.932907+00	2026-07-21 18:35:18.932907+00
efb263c4-05b2-42d2-bc77-af9f0cbd846e	a64c7b6a-1ec6-42b0-b46a-259eff9045ce	caaef6d7-fee2-48a7-bd4b-3697a88773ea	رفع اشکالات و بازبینی	153	87	2026-06-29	submitted	\N	\N	8f5eb7e8-3fb3-44fe-a4a8-6283bfd34cb0	2026-07-21 18:35:18.932907+00	2026-07-21 18:35:18.932907+00
efb263c4-05b2-42d2-bc77-af9f0cbd846e	b3e1ccce-64c8-41d8-915d-11d9b09f8dcf	c0c1258a-257b-4a56-bc50-4efdde442732	پیشرفت اولیه و بررسی نیازمندی‌ها	66	27	2026-07-16	approved	c0c1258a-257b-4a56-bc50-4efdde442732	\N	81f0871d-775c-4410-b739-f047c295c15e	2026-07-21 18:35:18.932907+00	2026-07-21 18:35:18.932907+00
efb263c4-05b2-42d2-bc77-af9f0cbd846e	b3e1ccce-64c8-41d8-915d-11d9b09f8dcf	c0c1258a-257b-4a56-bc50-4efdde442732	مستندسازی و نهایی‌سازی	123	44	2026-07-16	submitted	\N	\N	9612b85f-a0c1-4520-919f-f9c4d23d7c4d	2026-07-21 18:35:18.932907+00	2026-07-21 18:35:18.932907+00
efb263c4-05b2-42d2-bc77-af9f0cbd846e	b3e1ccce-64c8-41d8-915d-11d9b09f8dcf	c0c1258a-257b-4a56-bc50-4efdde442732	مستندسازی و نهایی‌سازی	61	100	2026-07-16	approved	c0c1258a-257b-4a56-bc50-4efdde442732	\N	3d7c3646-d13e-4572-a239-85840ea6f1f8	2026-07-21 18:35:18.932907+00	2026-07-21 18:35:18.932907+00
efb263c4-05b2-42d2-bc77-af9f0cbd846e	3b75f8c8-8d28-44cf-bd8b-7871813f362b	caaef6d7-fee2-48a7-bd4b-3697a88773ea	مستندسازی و نهایی‌سازی	127	40	2026-07-01	approved	c0c1258a-257b-4a56-bc50-4efdde442732	\N	ed5d78c3-53eb-448e-b115-68e3aecac21c	2026-07-21 18:35:18.932907+00	2026-07-21 18:35:18.932907+00
efb263c4-05b2-42d2-bc77-af9f0cbd846e	3b75f8c8-8d28-44cf-bd8b-7871813f362b	caaef6d7-fee2-48a7-bd4b-3697a88773ea	پیشرفت اولیه و بررسی نیازمندی‌ها	202	54	2026-07-04	approved	c0c1258a-257b-4a56-bc50-4efdde442732	\N	305f2e78-d9cc-43e2-a39d-6852cccb048b	2026-07-21 18:35:18.932907+00	2026-07-21 18:35:18.932907+00
efb263c4-05b2-42d2-bc77-af9f0cbd846e	3b75f8c8-8d28-44cf-bd8b-7871813f362b	caaef6d7-fee2-48a7-bd4b-3697a88773ea	پیشرفت اولیه و بررسی نیازمندی‌ها	188	100	2026-07-09	approved	c0c1258a-257b-4a56-bc50-4efdde442732	\N	c4ba9434-e47a-4f7f-ab2d-ab2ee3612147	2026-07-21 18:35:18.932907+00	2026-07-21 18:35:18.932907+00
efb263c4-05b2-42d2-bc77-af9f0cbd846e	c74728c1-1ae1-4d91-8664-04e0b701683c	14420cd5-d1bc-4e91-8063-b90ed9c1d745	پیشرفت اولیه و بررسی نیازمندی‌ها	192	34	2026-07-16	approved	c0c1258a-257b-4a56-bc50-4efdde442732	\N	628690be-00dd-4e90-b0e7-532ff440f162	2026-07-21 18:35:18.932907+00	2026-07-21 18:35:18.932907+00
efb263c4-05b2-42d2-bc77-af9f0cbd846e	c74728c1-1ae1-4d91-8664-04e0b701683c	14420cd5-d1bc-4e91-8063-b90ed9c1d745	تست و اطمینان از عملکرد صحیح	59	48	2026-07-16	approved	c0c1258a-257b-4a56-bc50-4efdde442732	\N	bd4dee3f-1669-4f51-abb5-fe6ca3110fdf	2026-07-21 18:35:18.932907+00	2026-07-21 18:35:18.932907+00
efb263c4-05b2-42d2-bc77-af9f0cbd846e	c74728c1-1ae1-4d91-8664-04e0b701683c	14420cd5-d1bc-4e91-8063-b90ed9c1d745	پیشرفت اولیه و بررسی نیازمندی‌ها	107	100	2026-07-16	approved	c0c1258a-257b-4a56-bc50-4efdde442732	\N	30d4750e-b8e5-43d5-ac52-334e621cbf72	2026-07-21 18:35:18.932907+00	2026-07-21 18:35:18.932907+00
efb263c4-05b2-42d2-bc77-af9f0cbd846e	075d8f7b-41b1-4cff-b496-b492d10c23a7	2a912655-64c4-44a5-9beb-6093704c47bd	پیاده‌سازی بخش اصلی	167	24	2026-07-05	approved	c0c1258a-257b-4a56-bc50-4efdde442732	\N	94c411ce-c596-4a8c-b710-59b445e3a508	2026-07-21 18:35:18.932907+00	2026-07-21 18:35:18.932907+00
efb263c4-05b2-42d2-bc77-af9f0cbd846e	3791d80e-99a6-411b-bdea-d9517fd5c36b	1bc00cf9-0b6c-453b-8f81-55a9f72ad244	رفع اشکالات و بازبینی	201	37	2026-07-16	approved	c0c1258a-257b-4a56-bc50-4efdde442732	\N	5583d375-c3c9-43c8-bcfc-7199b0259006	2026-07-21 18:35:18.932907+00	2026-07-21 18:35:18.932907+00
efb263c4-05b2-42d2-bc77-af9f0cbd846e	3791d80e-99a6-411b-bdea-d9517fd5c36b	1bc00cf9-0b6c-453b-8f81-55a9f72ad244	مستندسازی و نهایی‌سازی	220	48	2026-07-16	approved	c0c1258a-257b-4a56-bc50-4efdde442732	\N	f68415a1-f7d6-461e-a118-0939da63aa1d	2026-07-21 18:35:18.932907+00	2026-07-21 18:35:18.932907+00
efb263c4-05b2-42d2-bc77-af9f0cbd846e	3791d80e-99a6-411b-bdea-d9517fd5c36b	1bc00cf9-0b6c-453b-8f81-55a9f72ad244	پیشرفت اولیه و بررسی نیازمندی‌ها	155	100	2026-07-16	approved	c0c1258a-257b-4a56-bc50-4efdde442732	\N	bb982ef7-fb8b-4d3b-8383-58a6aefb4396	2026-07-21 18:35:18.932907+00	2026-07-21 18:35:18.932907+00
efb263c4-05b2-42d2-bc77-af9f0cbd846e	3791d80e-99a6-411b-bdea-d9517fd5c36b	1bc00cf9-0b6c-453b-8f81-55a9f72ad244	رفع اشکالات و بازبینی	38	100	2026-07-16	approved	c0c1258a-257b-4a56-bc50-4efdde442732	\N	378ef2a3-e4c3-464b-94f9-2705df932654	2026-07-21 18:35:18.932907+00	2026-07-21 18:35:18.932907+00
efb263c4-05b2-42d2-bc77-af9f0cbd846e	e11a60a4-7173-4948-8808-dcb128b3daa4	c0c1258a-257b-4a56-bc50-4efdde442732	تست و اطمینان از عملکرد صحیح	90	31	2026-07-16	approved	c0c1258a-257b-4a56-bc50-4efdde442732	\N	c19052bc-7948-4f38-90b7-460ebc974c05	2026-07-21 18:35:18.932907+00	2026-07-21 18:35:18.932907+00
efb263c4-05b2-42d2-bc77-af9f0cbd846e	e11a60a4-7173-4948-8808-dcb128b3daa4	c0c1258a-257b-4a56-bc50-4efdde442732	رفع اشکالات و بازبینی	169	80	2026-07-16	approved	c0c1258a-257b-4a56-bc50-4efdde442732	\N	ba5f98b7-c8e8-41ef-9074-746e0fcd5830	2026-07-21 18:35:18.932907+00	2026-07-21 18:35:18.932907+00
efb263c4-05b2-42d2-bc77-af9f0cbd846e	a90befd3-4dc2-402d-ae24-14a542bc0c3c	14420cd5-d1bc-4e91-8063-b90ed9c1d745	پیاده‌سازی بخش اصلی	61	34	2026-07-16	approved	c0c1258a-257b-4a56-bc50-4efdde442732	\N	a7d34c83-c628-4be6-b1b0-119803d9d0ed	2026-07-21 18:35:18.932907+00	2026-07-21 18:35:18.932907+00
efb263c4-05b2-42d2-bc77-af9f0cbd846e	a90befd3-4dc2-402d-ae24-14a542bc0c3c	14420cd5-d1bc-4e91-8063-b90ed9c1d745	مستندسازی و نهایی‌سازی	35	42	2026-07-16	approved	c0c1258a-257b-4a56-bc50-4efdde442732	\N	08e7ed42-86e0-46e7-aff6-c78bd27b0334	2026-07-21 18:35:18.932907+00	2026-07-21 18:35:18.932907+00
efb263c4-05b2-42d2-bc77-af9f0cbd846e	a90befd3-4dc2-402d-ae24-14a542bc0c3c	14420cd5-d1bc-4e91-8063-b90ed9c1d745	پیاده‌سازی بخش اصلی	231	100	2026-07-16	approved	c0c1258a-257b-4a56-bc50-4efdde442732	\N	3c87dc29-97db-46fc-a71b-c936e88f4870	2026-07-21 18:35:18.932907+00	2026-07-21 18:35:18.932907+00
efb263c4-05b2-42d2-bc77-af9f0cbd846e	fdaa2c25-eb79-49e0-b3d7-4e171c04f3cd	2505504d-a7d6-4a58-975c-bed21d1319bd	مستندسازی و نهایی‌سازی	83	38	2026-06-20	approved	c0c1258a-257b-4a56-bc50-4efdde442732	\N	a8756124-36f8-4f5a-9920-fca8868eaa10	2026-07-21 18:35:18.932907+00	2026-07-21 18:35:18.932907+00
efb263c4-05b2-42d2-bc77-af9f0cbd846e	fdaa2c25-eb79-49e0-b3d7-4e171c04f3cd	2505504d-a7d6-4a58-975c-bed21d1319bd	پیاده‌سازی بخش اصلی	114	48	2026-06-22	approved	c0c1258a-257b-4a56-bc50-4efdde442732	\N	6f45537d-ba58-4e19-a793-894a8caacabf	2026-07-21 18:35:18.932907+00	2026-07-21 18:35:18.932907+00
efb263c4-05b2-42d2-bc77-af9f0cbd846e	fb201f49-11a4-427f-95db-aea2cf4f40f8	2a912655-64c4-44a5-9beb-6093704c47bd	پیاده‌سازی بخش اصلی	63	37	2026-06-24	approved	c0c1258a-257b-4a56-bc50-4efdde442732	\N	9a376950-b188-4041-9a69-289f72532073	2026-07-21 18:35:18.932907+00	2026-07-21 18:35:18.932907+00
efb263c4-05b2-42d2-bc77-af9f0cbd846e	b8d38bee-ce44-450c-a615-f3474837e8a0	14420cd5-d1bc-4e91-8063-b90ed9c1d745	پیشرفت اولیه و بررسی نیازمندی‌ها	199	20	2026-07-16	approved	c0c1258a-257b-4a56-bc50-4efdde442732	\N	f668c85e-7e45-4346-98ac-535bee8d2953	2026-07-21 18:35:18.932907+00	2026-07-21 18:35:18.932907+00
efb263c4-05b2-42d2-bc77-af9f0cbd846e	b8d38bee-ce44-450c-a615-f3474837e8a0	14420cd5-d1bc-4e91-8063-b90ed9c1d745	پیشرفت اولیه و بررسی نیازمندی‌ها	121	54	2026-07-16	approved	c0c1258a-257b-4a56-bc50-4efdde442732	\N	dfd87f63-b13c-4ced-9de7-7f8c5c544708	2026-07-21 18:35:18.932907+00	2026-07-21 18:35:18.932907+00
efb263c4-05b2-42d2-bc77-af9f0cbd846e	b8d38bee-ce44-450c-a615-f3474837e8a0	14420cd5-d1bc-4e91-8063-b90ed9c1d745	پیشرفت اولیه و بررسی نیازمندی‌ها	74	84	2026-07-16	approved	c0c1258a-257b-4a56-bc50-4efdde442732	\N	de5abe5c-34cc-4f8a-a33c-bdc92723c1af	2026-07-21 18:35:18.932907+00	2026-07-21 18:35:18.932907+00
efb263c4-05b2-42d2-bc77-af9f0cbd846e	0f6696ea-1eb8-430a-844a-6ef38e0dc872	14420cd5-d1bc-4e91-8063-b90ed9c1d745	مستندسازی و نهایی‌سازی	59	22	2026-07-16	submitted	\N	\N	e2b3109f-64e8-4207-872a-2da42cbe6579	2026-07-21 18:35:18.932907+00	2026-07-21 18:35:18.932907+00
efb263c4-05b2-42d2-bc77-af9f0cbd846e	f2bbd36f-6f4c-470e-af4c-f26b9bfddf16	c0c1258a-257b-4a56-bc50-4efdde442732	رفع اشکالات و بازبینی	161	38	2026-07-16	approved	c0c1258a-257b-4a56-bc50-4efdde442732	\N	0d157c17-8e5c-48f1-9385-a4703abd9865	2026-07-21 18:35:18.932907+00	2026-07-21 18:35:18.932907+00
efb263c4-05b2-42d2-bc77-af9f0cbd846e	f2bbd36f-6f4c-470e-af4c-f26b9bfddf16	c0c1258a-257b-4a56-bc50-4efdde442732	تست و اطمینان از عملکرد صحیح	158	54	2026-07-16	approved	c0c1258a-257b-4a56-bc50-4efdde442732	\N	d68df280-ec12-474a-a2bb-c1f23a582334	2026-07-21 18:35:18.932907+00	2026-07-21 18:35:18.932907+00
efb263c4-05b2-42d2-bc77-af9f0cbd846e	f2bbd36f-6f4c-470e-af4c-f26b9bfddf16	c0c1258a-257b-4a56-bc50-4efdde442732	مستندسازی و نهایی‌سازی	107	100	2026-07-16	approved	c0c1258a-257b-4a56-bc50-4efdde442732	\N	d3c5892b-fdc9-46a4-b6dd-ce615b4e1189	2026-07-21 18:35:18.932907+00	2026-07-21 18:35:18.932907+00
efb263c4-05b2-42d2-bc77-af9f0cbd846e	f2bbd36f-6f4c-470e-af4c-f26b9bfddf16	c0c1258a-257b-4a56-bc50-4efdde442732	پیشرفت اولیه و بررسی نیازمندی‌ها	152	100	2026-07-16	approved	c0c1258a-257b-4a56-bc50-4efdde442732	\N	1ff0a13e-2a10-4b00-9315-eb57982ee0b4	2026-07-21 18:35:18.932907+00	2026-07-21 18:35:18.932907+00
efb263c4-05b2-42d2-bc77-af9f0cbd846e	714ba6fa-5a76-4eb6-bdc8-15b425f93b60	1bc00cf9-0b6c-453b-8f81-55a9f72ad244	تست و اطمینان از عملکرد صحیح	48	22	2026-06-30	approved	c0c1258a-257b-4a56-bc50-4efdde442732	\N	45b8dd32-ed1e-4f0b-a74d-557c10e65c66	2026-07-21 18:35:18.932907+00	2026-07-21 18:35:18.932907+00
efb263c4-05b2-42d2-bc77-af9f0cbd846e	714ba6fa-5a76-4eb6-bdc8-15b425f93b60	1bc00cf9-0b6c-453b-8f81-55a9f72ad244	پیشرفت اولیه و بررسی نیازمندی‌ها	62	56	2026-07-03	approved	c0c1258a-257b-4a56-bc50-4efdde442732	\N	24f93e2b-9bb1-4e5f-b35d-47c8824c3bbc	2026-07-21 18:35:18.932907+00	2026-07-21 18:35:18.932907+00
efb263c4-05b2-42d2-bc77-af9f0cbd846e	714ba6fa-5a76-4eb6-bdc8-15b425f93b60	1bc00cf9-0b6c-453b-8f81-55a9f72ad244	مستندسازی و نهایی‌سازی	165	87	2026-07-06	approved	c0c1258a-257b-4a56-bc50-4efdde442732	\N	72ac2516-b0ae-41a1-99cc-beafbb60a18a	2026-07-21 18:35:18.932907+00	2026-07-21 18:35:18.932907+00
efb263c4-05b2-42d2-bc77-af9f0cbd846e	714ba6fa-5a76-4eb6-bdc8-15b425f93b60	1bc00cf9-0b6c-453b-8f81-55a9f72ad244	تست و اطمینان از عملکرد صحیح	55	92	2026-07-12	approved	c0c1258a-257b-4a56-bc50-4efdde442732	\N	5c42f671-95c9-467f-b6db-95cfb0083de6	2026-07-21 18:35:18.932907+00	2026-07-21 18:35:18.932907+00
efb263c4-05b2-42d2-bc77-af9f0cbd846e	c7712c68-ca32-4e14-9907-167b4afa05aa	1bc00cf9-0b6c-453b-8f81-55a9f72ad244	تست و اطمینان از عملکرد صحیح	88	33	2026-06-17	approved	c0c1258a-257b-4a56-bc50-4efdde442732	\N	bf267cc2-b339-44f6-8cdc-c8795a047ab3	2026-07-21 18:35:18.932907+00	2026-07-21 18:35:18.932907+00
efb263c4-05b2-42d2-bc77-af9f0cbd846e	c7712c68-ca32-4e14-9907-167b4afa05aa	1bc00cf9-0b6c-453b-8f81-55a9f72ad244	تست و اطمینان از عملکرد صحیح	132	66	2026-06-20	approved	c0c1258a-257b-4a56-bc50-4efdde442732	\N	8ea939ce-ebf0-4b7e-8b6f-6ffd0314f9ab	2026-07-21 18:35:18.932907+00	2026-07-21 18:35:18.932907+00
efb263c4-05b2-42d2-bc77-af9f0cbd846e	d54dd4a5-2f9f-4bf8-b43b-761d8beb2d5c	c0c1258a-257b-4a56-bc50-4efdde442732	تست و اطمینان از عملکرد صحیح	110	28	2026-07-16	approved	c0c1258a-257b-4a56-bc50-4efdde442732	\N	222bf329-db9d-49c7-b218-fa72be1d7288	2026-07-21 18:35:18.932907+00	2026-07-21 18:35:18.932907+00
efb263c4-05b2-42d2-bc77-af9f0cbd846e	fc483c0f-30f7-43fb-a97b-feec44fa7179	4cef53c1-898c-4945-b51b-a1d36322bb51	تست و اطمینان از عملکرد صحیح	47	22	2026-07-16	approved	c0c1258a-257b-4a56-bc50-4efdde442732	\N	12546f10-6ad6-41ab-94a5-e6c24994b0f9	2026-07-21 18:35:18.932907+00	2026-07-21 18:35:18.932907+00
efb263c4-05b2-42d2-bc77-af9f0cbd846e	fc483c0f-30f7-43fb-a97b-feec44fa7179	4cef53c1-898c-4945-b51b-a1d36322bb51	پیشرفت اولیه و بررسی نیازمندی‌ها	220	62	2026-07-16	approved	c0c1258a-257b-4a56-bc50-4efdde442732	\N	1c452319-c307-4f12-a09c-11bc9c7a08fd	2026-07-21 18:35:18.932907+00	2026-07-21 18:35:18.932907+00
efb263c4-05b2-42d2-bc77-af9f0cbd846e	fc483c0f-30f7-43fb-a97b-feec44fa7179	4cef53c1-898c-4945-b51b-a1d36322bb51	مستندسازی و نهایی‌سازی	173	100	2026-07-16	approved	c0c1258a-257b-4a56-bc50-4efdde442732	\N	d3186bff-8a76-4128-ae24-87e57d2327ac	2026-07-21 18:35:18.932907+00	2026-07-21 18:35:18.932907+00
efb263c4-05b2-42d2-bc77-af9f0cbd846e	a92504ef-d988-417f-8bb1-23034f926ed9	4cef53c1-898c-4945-b51b-a1d36322bb51	تست و اطمینان از عملکرد صحیح	214	21	2026-07-06	approved	c0c1258a-257b-4a56-bc50-4efdde442732	\N	ef8137ea-ab1c-4af3-a5db-95ea1883ad74	2026-07-21 18:35:18.932907+00	2026-07-21 18:35:18.932907+00
efb263c4-05b2-42d2-bc77-af9f0cbd846e	a92504ef-d988-417f-8bb1-23034f926ed9	4cef53c1-898c-4945-b51b-a1d36322bb51	رفع اشکالات و بازبینی	56	76	2026-07-09	approved	c0c1258a-257b-4a56-bc50-4efdde442732	\N	1ddde68c-4282-4409-99d2-6de5661f542f	2026-07-21 18:35:18.932907+00	2026-07-21 18:35:18.932907+00
efb263c4-05b2-42d2-bc77-af9f0cbd846e	a92504ef-d988-417f-8bb1-23034f926ed9	4cef53c1-898c-4945-b51b-a1d36322bb51	تست و اطمینان از عملکرد صحیح	87	69	2026-07-10	approved	c0c1258a-257b-4a56-bc50-4efdde442732	\N	7ecc6ebc-bd5e-4a84-8387-24a6e358ac1b	2026-07-21 18:35:18.932907+00	2026-07-21 18:35:18.932907+00
efb263c4-05b2-42d2-bc77-af9f0cbd846e	4302bf33-e671-4c88-b2be-e08e75316dc1	2505504d-a7d6-4a58-975c-bed21d1319bd	پیشرفت اولیه و بررسی نیازمندی‌ها	225	28	2026-07-16	approved	c0c1258a-257b-4a56-bc50-4efdde442732	\N	8c40c20a-21e0-417d-935b-b35571766360	2026-07-21 18:35:18.932907+00	2026-07-21 18:35:18.932907+00
efb263c4-05b2-42d2-bc77-af9f0cbd846e	4302bf33-e671-4c88-b2be-e08e75316dc1	2505504d-a7d6-4a58-975c-bed21d1319bd	تست و اطمینان از عملکرد صحیح	173	78	2026-07-16	approved	c0c1258a-257b-4a56-bc50-4efdde442732	\N	cf840fd6-c340-4316-8c48-4ffbb11919a9	2026-07-21 18:35:18.932907+00	2026-07-21 18:35:18.932907+00
efb263c4-05b2-42d2-bc77-af9f0cbd846e	4302bf33-e671-4c88-b2be-e08e75316dc1	2505504d-a7d6-4a58-975c-bed21d1319bd	مستندسازی و نهایی‌سازی	198	84	2026-07-16	approved	c0c1258a-257b-4a56-bc50-4efdde442732	\N	e7bc0da0-36df-4cf5-b91b-ce7756a93858	2026-07-21 18:35:18.932907+00	2026-07-21 18:35:18.932907+00
efb263c4-05b2-42d2-bc77-af9f0cbd846e	f25c38bf-4590-485d-975f-c2b5b94a3565	14420cd5-d1bc-4e91-8063-b90ed9c1d745	رفع اشکالات و بازبینی	209	29	2026-07-16	approved	c0c1258a-257b-4a56-bc50-4efdde442732	\N	6a1e5a8b-1024-46dc-a4a5-d0e93d8e310f	2026-07-21 18:35:18.932907+00	2026-07-21 18:35:18.932907+00
efb263c4-05b2-42d2-bc77-af9f0cbd846e	f3195044-6591-4435-b7ea-3364ab0b9bf7	1bc00cf9-0b6c-453b-8f81-55a9f72ad244	پیشرفت اولیه و بررسی نیازمندی‌ها	76	24	2026-06-26	approved	c0c1258a-257b-4a56-bc50-4efdde442732	\N	2107052a-7be6-4218-b0f4-47caeaa6b724	2026-07-21 18:35:18.932907+00	2026-07-21 18:35:18.932907+00
efb263c4-05b2-42d2-bc77-af9f0cbd846e	f3195044-6591-4435-b7ea-3364ab0b9bf7	1bc00cf9-0b6c-453b-8f81-55a9f72ad244	پیشرفت اولیه و بررسی نیازمندی‌ها	66	80	2026-06-30	approved	c0c1258a-257b-4a56-bc50-4efdde442732	\N	bddbc377-c84d-4cff-ba44-0ab799212262	2026-07-21 18:35:18.932907+00	2026-07-21 18:35:18.932907+00
efb263c4-05b2-42d2-bc77-af9f0cbd846e	f3195044-6591-4435-b7ea-3364ab0b9bf7	1bc00cf9-0b6c-453b-8f81-55a9f72ad244	پیشرفت اولیه و بررسی نیازمندی‌ها	221	100	2026-06-28	approved	c0c1258a-257b-4a56-bc50-4efdde442732	\N	08240e4d-eb2f-4cfd-bd16-e5d31219b660	2026-07-21 18:35:18.932907+00	2026-07-21 18:35:18.932907+00
efb263c4-05b2-42d2-bc77-af9f0cbd846e	65cc8675-ba88-457d-a8f1-f3031eaac383	1bc00cf9-0b6c-453b-8f81-55a9f72ad244	تست و اطمینان از عملکرد صحیح	146	30	2026-07-01	approved	c0c1258a-257b-4a56-bc50-4efdde442732	\N	a07b9cb6-27a7-4af8-b18f-02d6e2c1bad1	2026-07-21 18:35:18.932907+00	2026-07-21 18:35:18.932907+00
efb263c4-05b2-42d2-bc77-af9f0cbd846e	65cc8675-ba88-457d-a8f1-f3031eaac383	1bc00cf9-0b6c-453b-8f81-55a9f72ad244	رفع اشکالات و بازبینی	109	60	2026-07-03	approved	c0c1258a-257b-4a56-bc50-4efdde442732	\N	a9ddd97b-b401-4806-a2dc-1c9d7dca7f5c	2026-07-21 18:35:18.932907+00	2026-07-21 18:35:18.932907+00
efb263c4-05b2-42d2-bc77-af9f0cbd846e	f01306bc-7e74-45d5-bde8-f320fa448f0a	caaef6d7-fee2-48a7-bd4b-3697a88773ea	پیاده‌سازی بخش اصلی	70	39	2026-07-16	approved	c0c1258a-257b-4a56-bc50-4efdde442732	\N	d1bd4443-9f6e-4141-881f-cc0b5113d01a	2026-07-21 18:35:18.932907+00	2026-07-21 18:35:18.932907+00
efb263c4-05b2-42d2-bc77-af9f0cbd846e	e7e5502f-4477-4c02-ba3c-d7cca9877322	4cef53c1-898c-4945-b51b-a1d36322bb51	رفع اشکالات و بازبینی	143	33	2026-07-16	approved	c0c1258a-257b-4a56-bc50-4efdde442732	\N	9099e0b3-1be6-4f5c-8669-3285ba9ced95	2026-07-21 18:35:18.932907+00	2026-07-21 18:35:18.932907+00
efb263c4-05b2-42d2-bc77-af9f0cbd846e	5edb49c7-499d-4c72-a80a-9a0bb90a3a6d	1bc00cf9-0b6c-453b-8f81-55a9f72ad244	تست و اطمینان از عملکرد صحیح	99	26	2026-07-16	approved	c0c1258a-257b-4a56-bc50-4efdde442732	\N	512cfbf2-343f-44dc-900c-790b7fe5d85f	2026-07-21 18:35:18.932907+00	2026-07-21 18:35:18.932907+00
efb263c4-05b2-42d2-bc77-af9f0cbd846e	5edb49c7-499d-4c72-a80a-9a0bb90a3a6d	1bc00cf9-0b6c-453b-8f81-55a9f72ad244	رفع اشکالات و بازبینی	140	46	2026-07-16	approved	c0c1258a-257b-4a56-bc50-4efdde442732	\N	1b2c78e8-fa48-47db-a4d1-f24391da49a4	2026-07-21 18:35:18.932907+00	2026-07-21 18:35:18.932907+00
efb263c4-05b2-42d2-bc77-af9f0cbd846e	5edb49c7-499d-4c72-a80a-9a0bb90a3a6d	1bc00cf9-0b6c-453b-8f81-55a9f72ad244	مستندسازی و نهایی‌سازی	154	100	2026-07-16	approved	c0c1258a-257b-4a56-bc50-4efdde442732	\N	4873ce7b-b24e-4297-898c-0196299652b4	2026-07-21 18:35:18.932907+00	2026-07-21 18:35:18.932907+00
efb263c4-05b2-42d2-bc77-af9f0cbd846e	5edb49c7-499d-4c72-a80a-9a0bb90a3a6d	1bc00cf9-0b6c-453b-8f81-55a9f72ad244	پیشرفت اولیه و بررسی نیازمندی‌ها	86	100	2026-07-16	approved	c0c1258a-257b-4a56-bc50-4efdde442732	\N	882d3722-e78c-41c2-a714-dad005553abc	2026-07-21 18:35:18.932907+00	2026-07-21 18:35:18.932907+00
efb263c4-05b2-42d2-bc77-af9f0cbd846e	f02bc276-e245-4283-af2e-f11ba41321f3	4cef53c1-898c-4945-b51b-a1d36322bb51	پیاده‌سازی بخش اصلی	107	26	2026-07-16	approved	c0c1258a-257b-4a56-bc50-4efdde442732	\N	7a64b5ba-1df3-4f01-9916-a1b8487c0bb5	2026-07-21 18:35:18.932907+00	2026-07-21 18:35:18.932907+00
efb263c4-05b2-42d2-bc77-af9f0cbd846e	fb5297e0-559f-4b4d-9a75-973ca0f975d6	2505504d-a7d6-4a58-975c-bed21d1319bd	رفع اشکالات و بازبینی	113	23	2026-07-01	approved	c0c1258a-257b-4a56-bc50-4efdde442732	\N	7caff8dc-4007-4677-8b05-fa9367ba2146	2026-07-21 18:35:18.932907+00	2026-07-21 18:35:18.932907+00
efb263c4-05b2-42d2-bc77-af9f0cbd846e	fb5297e0-559f-4b4d-9a75-973ca0f975d6	2505504d-a7d6-4a58-975c-bed21d1319bd	تست و اطمینان از عملکرد صحیح	221	66	2026-07-02	approved	c0c1258a-257b-4a56-bc50-4efdde442732	\N	726beaff-d57b-43de-848f-2af11acc9ab4	2026-07-21 18:35:18.932907+00	2026-07-21 18:35:18.932907+00
efb263c4-05b2-42d2-bc77-af9f0cbd846e	a049df99-8a33-478f-9d08-e8d0dadc420f	caaef6d7-fee2-48a7-bd4b-3697a88773ea	پیاده‌سازی بخش اصلی	158	37	2026-07-14	approved	c0c1258a-257b-4a56-bc50-4efdde442732	\N	d6b1fec5-d45a-4bcc-ada5-263e5f5ec13f	2026-07-21 18:35:18.932907+00	2026-07-21 18:35:18.932907+00
efb263c4-05b2-42d2-bc77-af9f0cbd846e	a049df99-8a33-478f-9d08-e8d0dadc420f	caaef6d7-fee2-48a7-bd4b-3697a88773ea	پیشرفت اولیه و بررسی نیازمندی‌ها	141	40	2026-07-16	approved	c0c1258a-257b-4a56-bc50-4efdde442732	\N	d8b72433-d2b6-4335-8a68-3a7d67cf66bd	2026-07-21 18:35:18.932907+00	2026-07-21 18:35:18.932907+00
efb263c4-05b2-42d2-bc77-af9f0cbd846e	9d3df6fa-2252-44db-a9f8-c564fd0df0f0	14420cd5-d1bc-4e91-8063-b90ed9c1d745	رفع اشکالات و بازبینی	177	33	2026-06-25	approved	c0c1258a-257b-4a56-bc50-4efdde442732	\N	9b19a67f-c268-43ce-a01a-3ae46ac84509	2026-07-21 18:35:18.932907+00	2026-07-21 18:35:18.932907+00
efb263c4-05b2-42d2-bc77-af9f0cbd846e	9d3df6fa-2252-44db-a9f8-c564fd0df0f0	14420cd5-d1bc-4e91-8063-b90ed9c1d745	تست و اطمینان از عملکرد صحیح	104	46	2026-06-29	approved	c0c1258a-257b-4a56-bc50-4efdde442732	\N	56fbf200-8669-4bc6-a128-2cbc350f131d	2026-07-21 18:35:18.932907+00	2026-07-21 18:35:18.932907+00
efb263c4-05b2-42d2-bc77-af9f0cbd846e	9d3df6fa-2252-44db-a9f8-c564fd0df0f0	14420cd5-d1bc-4e91-8063-b90ed9c1d745	پیشرفت اولیه و بررسی نیازمندی‌ها	113	75	2026-07-03	approved	c0c1258a-257b-4a56-bc50-4efdde442732	\N	03135aed-4191-4443-8717-62d0d6757c11	2026-07-21 18:35:18.932907+00	2026-07-21 18:35:18.932907+00
efb263c4-05b2-42d2-bc77-af9f0cbd846e	9d3df6fa-2252-44db-a9f8-c564fd0df0f0	14420cd5-d1bc-4e91-8063-b90ed9c1d745	رفع اشکالات و بازبینی	52	100	2026-07-07	approved	c0c1258a-257b-4a56-bc50-4efdde442732	\N	618c9912-ec36-440e-885f-a9c34858e6e4	2026-07-21 18:35:18.932907+00	2026-07-21 18:35:18.932907+00
efb263c4-05b2-42d2-bc77-af9f0cbd846e	f6238a47-74a9-45b1-a854-95c1b95fd176	caaef6d7-fee2-48a7-bd4b-3697a88773ea	تست و اطمینان از عملکرد صحیح	164	22	2026-07-10	approved	c0c1258a-257b-4a56-bc50-4efdde442732	\N	2b450e55-d7da-437d-a927-47289bd2a130	2026-07-21 18:35:18.932907+00	2026-07-21 18:35:18.932907+00
efb263c4-05b2-42d2-bc77-af9f0cbd846e	306ded86-10c9-4162-aca5-788cc1303b9f	c0c1258a-257b-4a56-bc50-4efdde442732	پیاده‌سازی بخش اصلی	115	25	2026-07-05	submitted	\N	\N	d71ace45-628a-4486-bf66-b083fc5a1606	2026-07-21 18:35:18.932907+00	2026-07-21 18:35:18.932907+00
efb263c4-05b2-42d2-bc77-af9f0cbd846e	306ded86-10c9-4162-aca5-788cc1303b9f	c0c1258a-257b-4a56-bc50-4efdde442732	پیشرفت اولیه و بررسی نیازمندی‌ها	165	72	2026-07-06	approved	c0c1258a-257b-4a56-bc50-4efdde442732	\N	cd08bea1-67c2-4c08-9fd6-36fdd0455e57	2026-07-21 18:35:18.932907+00	2026-07-21 18:35:18.932907+00
efb263c4-05b2-42d2-bc77-af9f0cbd846e	306ded86-10c9-4162-aca5-788cc1303b9f	c0c1258a-257b-4a56-bc50-4efdde442732	رفع اشکالات و بازبینی	119	100	2026-07-09	submitted	\N	\N	89d9f06e-b261-4489-afdd-4abbad071687	2026-07-21 18:35:18.932907+00	2026-07-21 18:35:18.932907+00
efb263c4-05b2-42d2-bc77-af9f0cbd846e	306ded86-10c9-4162-aca5-788cc1303b9f	c0c1258a-257b-4a56-bc50-4efdde442732	پیاده‌سازی بخش اصلی	95	100	2026-07-11	approved	c0c1258a-257b-4a56-bc50-4efdde442732	\N	386b816f-e6c2-428c-977a-2653bac2efa4	2026-07-21 18:35:18.932907+00	2026-07-21 18:35:18.932907+00
efb263c4-05b2-42d2-bc77-af9f0cbd846e	15a8dc90-da00-44a8-8f2f-32b8cd105393	2a912655-64c4-44a5-9beb-6093704c47bd	پیشرفت اولیه و بررسی نیازمندی‌ها	75	40	2026-07-16	approved	c0c1258a-257b-4a56-bc50-4efdde442732	\N	23206e79-5695-4dbf-8374-f98a4ab3349c	2026-07-21 18:35:18.932907+00	2026-07-21 18:35:18.932907+00
efb263c4-05b2-42d2-bc77-af9f0cbd846e	15a8dc90-da00-44a8-8f2f-32b8cd105393	2a912655-64c4-44a5-9beb-6093704c47bd	تست و اطمینان از عملکرد صحیح	223	76	2026-07-16	approved	c0c1258a-257b-4a56-bc50-4efdde442732	\N	44412370-6bd8-4e1a-80e1-753902ff7591	2026-07-21 18:35:18.932907+00	2026-07-21 18:35:18.932907+00
efb263c4-05b2-42d2-bc77-af9f0cbd846e	d0e54a07-5987-43c1-bb8d-a10e549b2fd0	2505504d-a7d6-4a58-975c-bed21d1319bd	رفع اشکالات و بازبینی	68	34	2026-07-16	submitted	\N	\N	1f8dff64-a951-4994-821f-0a9f55fc3d0c	2026-07-21 18:35:18.932907+00	2026-07-21 18:35:18.932907+00
efb263c4-05b2-42d2-bc77-af9f0cbd846e	d0e54a07-5987-43c1-bb8d-a10e549b2fd0	2505504d-a7d6-4a58-975c-bed21d1319bd	رفع اشکالات و بازبینی	233	56	2026-07-16	approved	c0c1258a-257b-4a56-bc50-4efdde442732	\N	90b3ddc0-4a93-480d-b065-bb55de213f24	2026-07-21 18:35:18.932907+00	2026-07-21 18:35:18.932907+00
efb263c4-05b2-42d2-bc77-af9f0cbd846e	d0e54a07-5987-43c1-bb8d-a10e549b2fd0	2505504d-a7d6-4a58-975c-bed21d1319bd	پیشرفت اولیه و بررسی نیازمندی‌ها	109	100	2026-07-16	approved	c0c1258a-257b-4a56-bc50-4efdde442732	\N	a766f83e-46a2-41fd-9828-0a065b0d540c	2026-07-21 18:35:18.932907+00	2026-07-21 18:35:18.932907+00
efb263c4-05b2-42d2-bc77-af9f0cbd846e	d0e54a07-5987-43c1-bb8d-a10e549b2fd0	2505504d-a7d6-4a58-975c-bed21d1319bd	رفع اشکالات و بازبینی	103	88	2026-07-16	approved	c0c1258a-257b-4a56-bc50-4efdde442732	\N	88bf1e78-2193-45bf-81a2-e344f62d549a	2026-07-21 18:35:18.932907+00	2026-07-21 18:35:18.932907+00
efb263c4-05b2-42d2-bc77-af9f0cbd846e	84d9625a-5d63-473b-a718-ba0cd166b287	2a912655-64c4-44a5-9beb-6093704c47bd	تست و اطمینان از عملکرد صحیح	178	37	2026-07-11	approved	c0c1258a-257b-4a56-bc50-4efdde442732	\N	86644ad3-bc92-4300-ae49-70d8a6aaec32	2026-07-21 18:35:18.932907+00	2026-07-21 18:35:18.932907+00
efb263c4-05b2-42d2-bc77-af9f0cbd846e	693c8a31-9916-42db-8feb-7856ac1aacb3	4cef53c1-898c-4945-b51b-a1d36322bb51	مستندسازی و نهایی‌سازی	196	26	2026-06-24	submitted	\N	\N	3c730bd4-b167-42e1-b517-90a216df88ec	2026-07-21 18:35:18.932907+00	2026-07-21 18:35:18.932907+00
efb263c4-05b2-42d2-bc77-af9f0cbd846e	45b0fc8f-5be0-4375-b8d8-1afc6d35855b	caaef6d7-fee2-48a7-bd4b-3697a88773ea	مستندسازی و نهایی‌سازی	68	21	2026-07-16	approved	c0c1258a-257b-4a56-bc50-4efdde442732	\N	65188128-a0b9-437c-92f1-26285a0eb0a4	2026-07-21 18:35:18.932907+00	2026-07-21 18:35:18.932907+00
efb263c4-05b2-42d2-bc77-af9f0cbd846e	45b0fc8f-5be0-4375-b8d8-1afc6d35855b	caaef6d7-fee2-48a7-bd4b-3697a88773ea	پیشرفت اولیه و بررسی نیازمندی‌ها	237	60	2026-07-16	approved	c0c1258a-257b-4a56-bc50-4efdde442732	\N	2dd7268b-9aaa-412f-b849-eb41e1540db2	2026-07-21 18:35:18.932907+00	2026-07-21 18:35:18.932907+00
efb263c4-05b2-42d2-bc77-af9f0cbd846e	45b0fc8f-5be0-4375-b8d8-1afc6d35855b	caaef6d7-fee2-48a7-bd4b-3697a88773ea	مستندسازی و نهایی‌سازی	195	75	2026-07-16	approved	c0c1258a-257b-4a56-bc50-4efdde442732	\N	8bfe9776-9890-42db-bbfc-96cd8245cdbc	2026-07-21 18:35:18.932907+00	2026-07-21 18:35:18.932907+00
efb263c4-05b2-42d2-bc77-af9f0cbd846e	15eb3157-a61c-470b-bbae-7f6ce6fce19e	c0c1258a-257b-4a56-bc50-4efdde442732	تست و اطمینان از عملکرد صحیح	142	36	2026-07-16	approved	c0c1258a-257b-4a56-bc50-4efdde442732	\N	0c82c59e-062c-45e4-baf6-a0acd1f8bf07	2026-07-21 18:35:18.932907+00	2026-07-21 18:35:18.932907+00
efb263c4-05b2-42d2-bc77-af9f0cbd846e	ec602b79-a5c9-4b8e-8a62-ced4b9fe8cf7	1bc00cf9-0b6c-453b-8f81-55a9f72ad244	رفع اشکالات و بازبینی	102	32	2026-06-17	approved	c0c1258a-257b-4a56-bc50-4efdde442732	\N	a19ec278-92da-46c2-a688-a19477257119	2026-07-21 18:35:18.932907+00	2026-07-21 18:35:18.932907+00
efb263c4-05b2-42d2-bc77-af9f0cbd846e	ec602b79-a5c9-4b8e-8a62-ced4b9fe8cf7	1bc00cf9-0b6c-453b-8f81-55a9f72ad244	رفع اشکالات و بازبینی	203	78	2026-06-21	approved	c0c1258a-257b-4a56-bc50-4efdde442732	\N	1933abdb-4801-4fe6-9ca5-09adb831939f	2026-07-21 18:35:18.932907+00	2026-07-21 18:35:18.932907+00
efb263c4-05b2-42d2-bc77-af9f0cbd846e	8f3eceb4-347a-44e4-9bd7-63d6dc62173a	1bc00cf9-0b6c-453b-8f81-55a9f72ad244	پیشرفت اولیه و بررسی نیازمندی‌ها	172	32	2026-06-26	approved	c0c1258a-257b-4a56-bc50-4efdde442732	\N	9db7070f-ba82-489f-856e-4140440deb7b	2026-07-21 18:35:18.932907+00	2026-07-21 18:35:18.932907+00
efb263c4-05b2-42d2-bc77-af9f0cbd846e	79e100bb-328e-4455-9039-0465f662a92b	caaef6d7-fee2-48a7-bd4b-3697a88773ea	مستندسازی و نهایی‌سازی	68	30	2026-06-22	submitted	\N	\N	9d31a814-3104-44d6-9cf8-2e73cd95f939	2026-07-21 18:35:18.932907+00	2026-07-21 18:35:18.932907+00
efb263c4-05b2-42d2-bc77-af9f0cbd846e	79e100bb-328e-4455-9039-0465f662a92b	caaef6d7-fee2-48a7-bd4b-3697a88773ea	پیاده‌سازی بخش اصلی	119	58	2026-06-23	approved	c0c1258a-257b-4a56-bc50-4efdde442732	\N	b4ceeff9-baa7-4127-b802-12176ead21d8	2026-07-21 18:35:18.932907+00	2026-07-21 18:35:18.932907+00
efb263c4-05b2-42d2-bc77-af9f0cbd846e	79e100bb-328e-4455-9039-0465f662a92b	caaef6d7-fee2-48a7-bd4b-3697a88773ea	پیشرفت اولیه و بررسی نیازمندی‌ها	109	100	2026-06-30	approved	c0c1258a-257b-4a56-bc50-4efdde442732	\N	c530fc78-9266-4d17-810b-e2edca08a0ed	2026-07-21 18:35:18.932907+00	2026-07-21 18:35:18.932907+00
efb263c4-05b2-42d2-bc77-af9f0cbd846e	6f779aec-3bd2-42ec-ba74-9b9890639cc2	2505504d-a7d6-4a58-975c-bed21d1319bd	مستندسازی و نهایی‌سازی	53	40	2026-07-16	submitted	\N	\N	b78ed81b-f5fa-4df2-b431-d5186dc8222e	2026-07-21 18:35:18.932907+00	2026-07-21 18:35:18.932907+00
efb263c4-05b2-42d2-bc77-af9f0cbd846e	6f779aec-3bd2-42ec-ba74-9b9890639cc2	2505504d-a7d6-4a58-975c-bed21d1319bd	پیشرفت اولیه و بررسی نیازمندی‌ها	122	58	2026-07-16	approved	c0c1258a-257b-4a56-bc50-4efdde442732	\N	7a0d5427-23c9-4f5b-ba34-3225db9fc85a	2026-07-21 18:35:18.932907+00	2026-07-21 18:35:18.932907+00
efb263c4-05b2-42d2-bc77-af9f0cbd846e	6f779aec-3bd2-42ec-ba74-9b9890639cc2	2505504d-a7d6-4a58-975c-bed21d1319bd	رفع اشکالات و بازبینی	226	100	2026-07-16	submitted	\N	\N	6012e1a1-da0b-4cbf-8419-75d8bc674e50	2026-07-21 18:35:18.932907+00	2026-07-21 18:35:18.932907+00
efb263c4-05b2-42d2-bc77-af9f0cbd846e	6f779aec-3bd2-42ec-ba74-9b9890639cc2	2505504d-a7d6-4a58-975c-bed21d1319bd	پیاده‌سازی بخش اصلی	69	88	2026-07-16	approved	c0c1258a-257b-4a56-bc50-4efdde442732	\N	ab482428-4dcb-4a15-a29c-c1b8be3811b8	2026-07-21 18:35:18.932907+00	2026-07-21 18:35:18.932907+00
efb263c4-05b2-42d2-bc77-af9f0cbd846e	49dd9ffa-a0b9-419c-9811-d0768bc61346	4cef53c1-898c-4945-b51b-a1d36322bb51	مستندسازی و نهایی‌سازی	227	37	2026-07-05	approved	c0c1258a-257b-4a56-bc50-4efdde442732	\N	d98e5619-cfdc-4bab-b885-e87a98f05e56	2026-07-21 18:35:18.932907+00	2026-07-21 18:35:18.932907+00
efb263c4-05b2-42d2-bc77-af9f0cbd846e	49dd9ffa-a0b9-419c-9811-d0768bc61346	4cef53c1-898c-4945-b51b-a1d36322bb51	رفع اشکالات و بازبینی	226	78	2026-07-06	approved	c0c1258a-257b-4a56-bc50-4efdde442732	\N	0c6d6b19-d50f-4cfc-8810-077ac330ef37	2026-07-21 18:35:18.932907+00	2026-07-21 18:35:18.932907+00
efb263c4-05b2-42d2-bc77-af9f0cbd846e	49dd9ffa-a0b9-419c-9811-d0768bc61346	4cef53c1-898c-4945-b51b-a1d36322bb51	مستندسازی و نهایی‌سازی	126	72	2026-07-09	approved	c0c1258a-257b-4a56-bc50-4efdde442732	\N	0ed75bd2-662f-48f2-87af-ffd7ce570efa	2026-07-21 18:35:18.932907+00	2026-07-21 18:35:18.932907+00
efb263c4-05b2-42d2-bc77-af9f0cbd846e	e623f740-7c20-4584-ae69-9e868e282490	14420cd5-d1bc-4e91-8063-b90ed9c1d745	مستندسازی و نهایی‌سازی	237	25	2026-07-09	approved	c0c1258a-257b-4a56-bc50-4efdde442732	\N	141641f8-eafd-4155-90dd-e0776119321c	2026-07-21 18:35:18.932907+00	2026-07-21 18:35:18.932907+00
efb263c4-05b2-42d2-bc77-af9f0cbd846e	e623f740-7c20-4584-ae69-9e868e282490	14420cd5-d1bc-4e91-8063-b90ed9c1d745	پیشرفت اولیه و بررسی نیازمندی‌ها	135	62	2026-07-13	approved	c0c1258a-257b-4a56-bc50-4efdde442732	\N	825ec487-3788-4de6-90e7-faaf4fe380de	2026-07-21 18:35:18.932907+00	2026-07-21 18:35:18.932907+00
efb263c4-05b2-42d2-bc77-af9f0cbd846e	c319e479-88b0-4cfe-8301-f7a4bdf8d30a	1bc00cf9-0b6c-453b-8f81-55a9f72ad244	تست و اطمینان از عملکرد صحیح	89	37	2026-07-16	approved	c0c1258a-257b-4a56-bc50-4efdde442732	\N	ccf8ce29-8d3e-4457-8a80-22532170d2fc	2026-07-21 18:35:18.932907+00	2026-07-21 18:35:18.932907+00
efb263c4-05b2-42d2-bc77-af9f0cbd846e	c319e479-88b0-4cfe-8301-f7a4bdf8d30a	1bc00cf9-0b6c-453b-8f81-55a9f72ad244	تست و اطمینان از عملکرد صحیح	79	62	2026-07-16	approved	c0c1258a-257b-4a56-bc50-4efdde442732	\N	9a6fefdc-c970-42ac-89ec-a585ad843929	2026-07-21 18:35:18.932907+00	2026-07-21 18:35:18.932907+00
efb263c4-05b2-42d2-bc77-af9f0cbd846e	e5570023-f0a9-4675-9b9c-0d676223cc1d	1bc00cf9-0b6c-453b-8f81-55a9f72ad244	رفع اشکالات و بازبینی	229	32	2026-07-13	approved	c0c1258a-257b-4a56-bc50-4efdde442732	\N	3ccc803e-dbd3-4fd8-8889-f9fe20bb87ee	2026-07-21 18:35:18.932907+00	2026-07-21 18:35:18.932907+00
efb263c4-05b2-42d2-bc77-af9f0cbd846e	e5570023-f0a9-4675-9b9c-0d676223cc1d	1bc00cf9-0b6c-453b-8f81-55a9f72ad244	پیاده‌سازی بخش اصلی	239	52	2026-07-16	approved	c0c1258a-257b-4a56-bc50-4efdde442732	\N	0a588a29-19e2-4245-a2c8-e4fcff4f64e5	2026-07-21 18:35:18.932907+00	2026-07-21 18:35:18.932907+00
efb263c4-05b2-42d2-bc77-af9f0cbd846e	e5570023-f0a9-4675-9b9c-0d676223cc1d	1bc00cf9-0b6c-453b-8f81-55a9f72ad244	رفع اشکالات و بازبینی	43	100	2026-07-16	approved	c0c1258a-257b-4a56-bc50-4efdde442732	\N	7f3f3509-9e45-4766-bda1-8d8752da3c35	2026-07-21 18:35:18.932907+00	2026-07-21 18:35:18.932907+00
efb263c4-05b2-42d2-bc77-af9f0cbd846e	e5570023-f0a9-4675-9b9c-0d676223cc1d	1bc00cf9-0b6c-453b-8f81-55a9f72ad244	رفع اشکالات و بازبینی	171	92	2026-07-16	approved	c0c1258a-257b-4a56-bc50-4efdde442732	\N	cde937e3-c3f7-4f14-96b5-6f4e540bdea4	2026-07-21 18:35:18.932907+00	2026-07-21 18:35:18.932907+00
efb263c4-05b2-42d2-bc77-af9f0cbd846e	99d0f3e7-d936-421f-81e3-e26903aa5f31	14420cd5-d1bc-4e91-8063-b90ed9c1d745	پیشرفت اولیه و بررسی نیازمندی‌ها	225	25	2026-07-16	approved	c0c1258a-257b-4a56-bc50-4efdde442732	\N	a86faee6-b101-461c-9d77-d1df0daca4f3	2026-07-21 18:35:18.932907+00	2026-07-21 18:35:18.932907+00
efb263c4-05b2-42d2-bc77-af9f0cbd846e	12022810-31c6-45c6-b150-a33faaa015a5	2a912655-64c4-44a5-9beb-6093704c47bd	پیاده‌سازی بخش اصلی	141	22	2026-07-06	submitted	\N	\N	dd4197ad-7a8d-455d-a944-eed57f3359c0	2026-07-21 18:35:18.932907+00	2026-07-21 18:35:18.932907+00
efb263c4-05b2-42d2-bc77-af9f0cbd846e	12022810-31c6-45c6-b150-a33faaa015a5	2a912655-64c4-44a5-9beb-6093704c47bd	رفع اشکالات و بازبینی	36	66	2026-07-08	submitted	\N	\N	a002a775-024a-410a-a025-5091cd8974ea	2026-07-21 18:35:18.932907+00	2026-07-21 18:35:18.932907+00
efb263c4-05b2-42d2-bc77-af9f0cbd846e	12022810-31c6-45c6-b150-a33faaa015a5	2a912655-64c4-44a5-9beb-6093704c47bd	رفع اشکالات و بازبینی	90	96	2026-07-08	approved	c0c1258a-257b-4a56-bc50-4efdde442732	\N	58eb2deb-f8df-44de-8e31-bec6f2750cd2	2026-07-21 18:35:18.932907+00	2026-07-21 18:35:18.932907+00
efb263c4-05b2-42d2-bc77-af9f0cbd846e	567bde4f-d879-41c3-86ea-de4eec839239	caaef6d7-fee2-48a7-bd4b-3697a88773ea	پیاده‌سازی بخش اصلی	37	30	2026-07-15	approved	c0c1258a-257b-4a56-bc50-4efdde442732	\N	b437aa03-3c27-408c-bc2a-18d2fb49e906	2026-07-21 18:35:18.932907+00	2026-07-21 18:35:18.932907+00
efb263c4-05b2-42d2-bc77-af9f0cbd846e	daa5ebf4-98cf-4dc9-85b1-9c7bed044a6d	2505504d-a7d6-4a58-975c-bed21d1319bd	پیاده‌سازی بخش اصلی	39	29	2026-06-27	submitted	\N	\N	81f98b51-84b4-4e72-97c9-5e2372313cfb	2026-07-21 18:35:18.932907+00	2026-07-21 18:35:18.932907+00
efb263c4-05b2-42d2-bc77-af9f0cbd846e	11457458-d260-4f02-b762-73c5c387f186	2a912655-64c4-44a5-9beb-6093704c47bd	تست و اطمینان از عملکرد صحیح	144	39	2026-07-16	approved	c0c1258a-257b-4a56-bc50-4efdde442732	\N	4d4a6536-38d0-4af5-800b-163baef33d36	2026-07-21 18:35:18.932907+00	2026-07-21 18:35:18.932907+00
efb263c4-05b2-42d2-bc77-af9f0cbd846e	11457458-d260-4f02-b762-73c5c387f186	2a912655-64c4-44a5-9beb-6093704c47bd	پیشرفت اولیه و بررسی نیازمندی‌ها	34	56	2026-07-16	approved	c0c1258a-257b-4a56-bc50-4efdde442732	\N	db259191-eab3-4752-881d-1e37f583bb39	2026-07-21 18:35:18.932907+00	2026-07-21 18:35:18.932907+00
efb263c4-05b2-42d2-bc77-af9f0cbd846e	11457458-d260-4f02-b762-73c5c387f186	2a912655-64c4-44a5-9beb-6093704c47bd	پیاده‌سازی بخش اصلی	170	100	2026-07-16	approved	c0c1258a-257b-4a56-bc50-4efdde442732	\N	50941888-1412-40a2-9a77-fabe5fcb21fc	2026-07-21 18:35:18.932907+00	2026-07-21 18:35:18.932907+00
efb263c4-05b2-42d2-bc77-af9f0cbd846e	11457458-d260-4f02-b762-73c5c387f186	2a912655-64c4-44a5-9beb-6093704c47bd	پیشرفت اولیه و بررسی نیازمندی‌ها	228	100	2026-07-16	approved	c0c1258a-257b-4a56-bc50-4efdde442732	\N	d6dc27d8-931d-4f2e-80a6-b62016408b58	2026-07-21 18:35:18.932907+00	2026-07-21 18:35:18.932907+00
efb263c4-05b2-42d2-bc77-af9f0cbd846e	9b8da72e-1223-424b-91fa-7e95e03acb03	4cef53c1-898c-4945-b51b-a1d36322bb51	پیاده‌سازی بخش اصلی	137	40	2026-07-16	approved	c0c1258a-257b-4a56-bc50-4efdde442732	\N	7cba38e9-ac51-4ae5-8109-e2073eb8a294	2026-07-21 18:35:18.932907+00	2026-07-21 18:35:18.932907+00
efb263c4-05b2-42d2-bc77-af9f0cbd846e	9b8da72e-1223-424b-91fa-7e95e03acb03	4cef53c1-898c-4945-b51b-a1d36322bb51	تست و اطمینان از عملکرد صحیح	182	74	2026-07-16	approved	c0c1258a-257b-4a56-bc50-4efdde442732	\N	8f52d2d1-d8d8-4d05-9316-707a95d1ed8c	2026-07-21 18:35:18.932907+00	2026-07-21 18:35:18.932907+00
efb263c4-05b2-42d2-bc77-af9f0cbd846e	8f064f74-f642-4b2a-861d-bcf97c6d0419	2505504d-a7d6-4a58-975c-bed21d1319bd	پیاده‌سازی بخش اصلی	104	33	2026-06-21	approved	c0c1258a-257b-4a56-bc50-4efdde442732	\N	c9b394ab-e205-4683-85bd-59a4979b8deb	2026-07-21 18:35:18.932907+00	2026-07-21 18:35:18.932907+00
efb263c4-05b2-42d2-bc77-af9f0cbd846e	0c23799e-a645-4119-8928-4a5d9711d023	c288bac5-e3a4-4f1f-a050-de12845acf11	مستندسازی و نهایی‌سازی	196	31	2026-06-27	approved	e262d280-b97e-4087-8e78-a66519bae4d1	\N	a2b45429-b351-4def-ace6-bfcea2088db3	2026-07-21 18:35:18.932907+00	2026-07-21 18:35:18.932907+00
efb263c4-05b2-42d2-bc77-af9f0cbd846e	0c23799e-a645-4119-8928-4a5d9711d023	c288bac5-e3a4-4f1f-a050-de12845acf11	رفع اشکالات و بازبینی	122	72	2026-06-30	approved	e262d280-b97e-4087-8e78-a66519bae4d1	\N	4e84e46d-ee48-44cf-9008-bf806e02ee2d	2026-07-21 18:35:18.932907+00	2026-07-21 18:35:18.932907+00
efb263c4-05b2-42d2-bc77-af9f0cbd846e	0c23799e-a645-4119-8928-4a5d9711d023	c288bac5-e3a4-4f1f-a050-de12845acf11	تست و اطمینان از عملکرد صحیح	55	100	2026-07-05	approved	e262d280-b97e-4087-8e78-a66519bae4d1	\N	29a9383b-7084-4612-a411-c386b4232254	2026-07-21 18:35:18.932907+00	2026-07-21 18:35:18.932907+00
efb263c4-05b2-42d2-bc77-af9f0cbd846e	0c23799e-a645-4119-8928-4a5d9711d023	c288bac5-e3a4-4f1f-a050-de12845acf11	پیاده‌سازی بخش اصلی	124	100	2026-07-06	approved	e262d280-b97e-4087-8e78-a66519bae4d1	\N	db74587e-2f76-4305-b5c2-82dfcd09ac8b	2026-07-21 18:35:18.932907+00	2026-07-21 18:35:18.932907+00
efb263c4-05b2-42d2-bc77-af9f0cbd846e	6dd2cdc1-fe8c-46e5-939f-1d2c1a708da2	e73ec14e-ca0c-4615-92d5-5bc43c14999a	مستندسازی و نهایی‌سازی	86	24	2026-07-14	approved	e262d280-b97e-4087-8e78-a66519bae4d1	\N	d59e84b7-2476-433f-9291-17afafcf478e	2026-07-21 18:35:18.932907+00	2026-07-21 18:35:18.932907+00
efb263c4-05b2-42d2-bc77-af9f0cbd846e	6dd2cdc1-fe8c-46e5-939f-1d2c1a708da2	e73ec14e-ca0c-4615-92d5-5bc43c14999a	رفع اشکالات و بازبینی	171	76	2026-07-15	approved	e262d280-b97e-4087-8e78-a66519bae4d1	\N	2cb59bd2-323f-453f-9209-06f8dea545c3	2026-07-21 18:35:18.932907+00	2026-07-21 18:35:18.932907+00
efb263c4-05b2-42d2-bc77-af9f0cbd846e	6dd2cdc1-fe8c-46e5-939f-1d2c1a708da2	e73ec14e-ca0c-4615-92d5-5bc43c14999a	رفع اشکالات و بازبینی	69	78	2026-07-16	approved	e262d280-b97e-4087-8e78-a66519bae4d1	\N	d0983abf-3068-4556-a4c0-bacae1016eca	2026-07-21 18:35:18.932907+00	2026-07-21 18:35:18.932907+00
efb263c4-05b2-42d2-bc77-af9f0cbd846e	6dd2cdc1-fe8c-46e5-939f-1d2c1a708da2	e73ec14e-ca0c-4615-92d5-5bc43c14999a	پیاده‌سازی بخش اصلی	127	100	2026-07-16	approved	e262d280-b97e-4087-8e78-a66519bae4d1	\N	676e22f7-e96e-426b-955c-efdbcd8173b6	2026-07-21 18:35:18.932907+00	2026-07-21 18:35:18.932907+00
efb263c4-05b2-42d2-bc77-af9f0cbd846e	eaf6c486-17f6-4c9e-8339-bc5ab7f02fcb	c288bac5-e3a4-4f1f-a050-de12845acf11	رفع اشکالات و بازبینی	95	35	2026-07-14	approved	e262d280-b97e-4087-8e78-a66519bae4d1	\N	dc05b0df-3746-42c1-9222-7f0a52c843a5	2026-07-21 18:35:18.932907+00	2026-07-21 18:35:18.932907+00
efb263c4-05b2-42d2-bc77-af9f0cbd846e	eaf6c486-17f6-4c9e-8339-bc5ab7f02fcb	c288bac5-e3a4-4f1f-a050-de12845acf11	رفع اشکالات و بازبینی	73	48	2026-07-16	approved	e262d280-b97e-4087-8e78-a66519bae4d1	\N	82f13b35-61f5-4d9c-ba1a-b2bfd931b9de	2026-07-21 18:35:18.932907+00	2026-07-21 18:35:18.932907+00
efb263c4-05b2-42d2-bc77-af9f0cbd846e	a68be9c7-45fc-4d3f-b2bb-6fd43189d249	e73ec14e-ca0c-4615-92d5-5bc43c14999a	مستندسازی و نهایی‌سازی	194	21	2026-07-16	approved	e262d280-b97e-4087-8e78-a66519bae4d1	\N	d136d2ba-1ef4-4ee4-9d16-c01a0747edbf	2026-07-21 18:35:18.932907+00	2026-07-21 18:35:18.932907+00
efb263c4-05b2-42d2-bc77-af9f0cbd846e	a68be9c7-45fc-4d3f-b2bb-6fd43189d249	e73ec14e-ca0c-4615-92d5-5bc43c14999a	پیشرفت اولیه و بررسی نیازمندی‌ها	239	42	2026-07-16	approved	e262d280-b97e-4087-8e78-a66519bae4d1	\N	dea394eb-9702-4c89-ac37-90490a81bdd3	2026-07-21 18:35:18.932907+00	2026-07-21 18:35:18.932907+00
efb263c4-05b2-42d2-bc77-af9f0cbd846e	a68be9c7-45fc-4d3f-b2bb-6fd43189d249	e73ec14e-ca0c-4615-92d5-5bc43c14999a	تست و اطمینان از عملکرد صحیح	65	100	2026-07-16	approved	e262d280-b97e-4087-8e78-a66519bae4d1	\N	9c09084a-9720-4080-9b0c-8699c732d0dd	2026-07-21 18:35:18.932907+00	2026-07-21 18:35:18.932907+00
efb263c4-05b2-42d2-bc77-af9f0cbd846e	a68be9c7-45fc-4d3f-b2bb-6fd43189d249	e73ec14e-ca0c-4615-92d5-5bc43c14999a	پیشرفت اولیه و بررسی نیازمندی‌ها	211	96	2026-07-16	approved	e262d280-b97e-4087-8e78-a66519bae4d1	\N	f6295d1a-91fd-44a4-b0af-3e31d9a9703e	2026-07-21 18:35:18.932907+00	2026-07-21 18:35:18.932907+00
efb263c4-05b2-42d2-bc77-af9f0cbd846e	4064be31-8705-417d-befb-6e95c97682f7	e73ec14e-ca0c-4615-92d5-5bc43c14999a	مستندسازی و نهایی‌سازی	146	31	2026-07-16	approved	e262d280-b97e-4087-8e78-a66519bae4d1	\N	51fc1249-b3f2-4dcc-b916-d4d87a02a384	2026-07-21 18:35:18.932907+00	2026-07-21 18:35:18.932907+00
efb263c4-05b2-42d2-bc77-af9f0cbd846e	2573af8d-1cda-49b6-b677-189bfb2973df	1c37102f-d8b4-4bea-bd82-5b862cd46e2b	تست و اطمینان از عملکرد صحیح	34	20	2026-06-20	approved	e262d280-b97e-4087-8e78-a66519bae4d1	\N	ce3291f1-ed18-4cb7-b48d-10059f3ac131	2026-07-21 18:35:18.932907+00	2026-07-21 18:35:18.932907+00
efb263c4-05b2-42d2-bc77-af9f0cbd846e	8c94b3aa-779a-416e-9873-14c5dc474eba	c288bac5-e3a4-4f1f-a050-de12845acf11	پیشرفت اولیه و بررسی نیازمندی‌ها	165	28	2026-06-25	approved	e262d280-b97e-4087-8e78-a66519bae4d1	\N	92a5c92c-6bc7-4395-98d0-dd5704fc2cad	2026-07-21 18:35:18.932907+00	2026-07-21 18:35:18.932907+00
efb263c4-05b2-42d2-bc77-af9f0cbd846e	8c94b3aa-779a-416e-9873-14c5dc474eba	c288bac5-e3a4-4f1f-a050-de12845acf11	پیشرفت اولیه و بررسی نیازمندی‌ها	158	66	2026-06-28	approved	e262d280-b97e-4087-8e78-a66519bae4d1	\N	4652d0d4-9aee-4af2-983c-17360a773015	2026-07-21 18:35:18.932907+00	2026-07-21 18:35:18.932907+00
efb263c4-05b2-42d2-bc77-af9f0cbd846e	8c94b3aa-779a-416e-9873-14c5dc474eba	c288bac5-e3a4-4f1f-a050-de12845acf11	پیشرفت اولیه و بررسی نیازمندی‌ها	54	100	2026-06-29	approved	e262d280-b97e-4087-8e78-a66519bae4d1	\N	1891fab5-1905-42d6-8182-cf1aed5dce0c	2026-07-21 18:35:18.932907+00	2026-07-21 18:35:18.932907+00
efb263c4-05b2-42d2-bc77-af9f0cbd846e	8c94b3aa-779a-416e-9873-14c5dc474eba	c288bac5-e3a4-4f1f-a050-de12845acf11	پیاده‌سازی بخش اصلی	79	100	2026-07-01	approved	e262d280-b97e-4087-8e78-a66519bae4d1	\N	4496174b-ed48-4e15-a05f-9ddb30046012	2026-07-21 18:35:18.932907+00	2026-07-21 18:35:18.932907+00
efb263c4-05b2-42d2-bc77-af9f0cbd846e	4abe51a8-2374-4e6a-89ac-7806f3a73dca	e262d280-b97e-4087-8e78-a66519bae4d1	رفع اشکالات و بازبینی	233	32	2026-07-09	approved	e262d280-b97e-4087-8e78-a66519bae4d1	\N	5524866d-84f4-4efa-ba13-74088b23e730	2026-07-21 18:35:18.932907+00	2026-07-21 18:35:18.932907+00
efb263c4-05b2-42d2-bc77-af9f0cbd846e	4abe51a8-2374-4e6a-89ac-7806f3a73dca	e262d280-b97e-4087-8e78-a66519bae4d1	رفع اشکالات و بازبینی	133	68	2026-07-10	approved	e262d280-b97e-4087-8e78-a66519bae4d1	\N	648fcb99-2d19-4993-b8cc-da2b7b3c1197	2026-07-21 18:35:18.932907+00	2026-07-21 18:35:18.932907+00
efb263c4-05b2-42d2-bc77-af9f0cbd846e	4abe51a8-2374-4e6a-89ac-7806f3a73dca	e262d280-b97e-4087-8e78-a66519bae4d1	پیاده‌سازی بخش اصلی	106	66	2026-07-13	approved	e262d280-b97e-4087-8e78-a66519bae4d1	\N	bc3852d3-9cec-4af2-b18a-65c9489a7296	2026-07-21 18:35:18.932907+00	2026-07-21 18:35:18.932907+00
efb263c4-05b2-42d2-bc77-af9f0cbd846e	8f5f2e3c-0399-45b9-98e7-9a3f6bd1e990	e262d280-b97e-4087-8e78-a66519bae4d1	تست و اطمینان از عملکرد صحیح	171	35	2026-07-16	approved	e262d280-b97e-4087-8e78-a66519bae4d1	\N	f761bc3d-8f6e-4694-8f54-89d93baa5d47	2026-07-21 18:35:18.932907+00	2026-07-21 18:35:18.932907+00
efb263c4-05b2-42d2-bc77-af9f0cbd846e	355e701a-1e73-4c94-aa41-970531d9badf	e73ec14e-ca0c-4615-92d5-5bc43c14999a	پیاده‌سازی بخش اصلی	51	35	2026-07-16	approved	e262d280-b97e-4087-8e78-a66519bae4d1	\N	742d57a3-c506-4a5a-8872-81ca4ef4f1ef	2026-07-21 18:35:18.932907+00	2026-07-21 18:35:18.932907+00
efb263c4-05b2-42d2-bc77-af9f0cbd846e	2e59f706-e7ed-4117-93c8-ec3eb3bbb249	1c37102f-d8b4-4bea-bd82-5b862cd46e2b	مستندسازی و نهایی‌سازی	54	36	2026-07-09	approved	e262d280-b97e-4087-8e78-a66519bae4d1	\N	35abae2b-1432-4434-88d1-3611a3a1bad0	2026-07-21 18:35:18.932907+00	2026-07-21 18:35:18.932907+00
efb263c4-05b2-42d2-bc77-af9f0cbd846e	2e59f706-e7ed-4117-93c8-ec3eb3bbb249	1c37102f-d8b4-4bea-bd82-5b862cd46e2b	پیاده‌سازی بخش اصلی	84	76	2026-07-10	approved	e262d280-b97e-4087-8e78-a66519bae4d1	\N	09f3e04a-5cae-4e22-b0d9-c069563f54a3	2026-07-21 18:35:18.932907+00	2026-07-21 18:35:18.932907+00
efb263c4-05b2-42d2-bc77-af9f0cbd846e	2e59f706-e7ed-4117-93c8-ec3eb3bbb249	1c37102f-d8b4-4bea-bd82-5b862cd46e2b	رفع اشکالات و بازبینی	41	66	2026-07-16	approved	e262d280-b97e-4087-8e78-a66519bae4d1	\N	089877ce-19f0-4be0-bfb9-9333d7fe32fc	2026-07-21 18:35:18.932907+00	2026-07-21 18:35:18.932907+00
efb263c4-05b2-42d2-bc77-af9f0cbd846e	2e59f706-e7ed-4117-93c8-ec3eb3bbb249	1c37102f-d8b4-4bea-bd82-5b862cd46e2b	مستندسازی و نهایی‌سازی	174	84	2026-07-16	approved	e262d280-b97e-4087-8e78-a66519bae4d1	\N	51c79a14-9d9b-4966-998b-d523c69f81b5	2026-07-21 18:35:18.932907+00	2026-07-21 18:35:18.932907+00
efb263c4-05b2-42d2-bc77-af9f0cbd846e	06af65da-1ce2-405c-beb9-00f9999e3bc8	c288bac5-e3a4-4f1f-a050-de12845acf11	پیشرفت اولیه و بررسی نیازمندی‌ها	83	38	2026-07-16	approved	e262d280-b97e-4087-8e78-a66519bae4d1	\N	1f699345-9492-4cfb-800f-8bc0a614e9b7	2026-07-21 18:35:18.932907+00	2026-07-21 18:35:18.932907+00
efb263c4-05b2-42d2-bc77-af9f0cbd846e	06af65da-1ce2-405c-beb9-00f9999e3bc8	c288bac5-e3a4-4f1f-a050-de12845acf11	تست و اطمینان از عملکرد صحیح	49	58	2026-07-16	approved	e262d280-b97e-4087-8e78-a66519bae4d1	\N	6d14e8bb-96e4-4561-b30b-dd12a04264d4	2026-07-21 18:35:18.932907+00	2026-07-21 18:35:18.932907+00
efb263c4-05b2-42d2-bc77-af9f0cbd846e	47637e11-1ad4-4446-8361-78123fdd9f3a	1c37102f-d8b4-4bea-bd82-5b862cd46e2b	مستندسازی و نهایی‌سازی	129	37	2026-07-16	approved	e262d280-b97e-4087-8e78-a66519bae4d1	\N	27673769-b14a-4d30-b0ec-88ada2f0b7b0	2026-07-21 18:35:18.932907+00	2026-07-21 18:35:18.932907+00
efb263c4-05b2-42d2-bc77-af9f0cbd846e	47637e11-1ad4-4446-8361-78123fdd9f3a	1c37102f-d8b4-4bea-bd82-5b862cd46e2b	تست و اطمینان از عملکرد صحیح	223	48	2026-07-16	approved	e262d280-b97e-4087-8e78-a66519bae4d1	\N	bc4b0dda-1cb4-42b5-bb3c-52880c15713e	2026-07-21 18:35:18.932907+00	2026-07-21 18:35:18.932907+00
efb263c4-05b2-42d2-bc77-af9f0cbd846e	c08b3f07-9cd5-48a6-b614-543fd53ca59f	e73ec14e-ca0c-4615-92d5-5bc43c14999a	پیشرفت اولیه و بررسی نیازمندی‌ها	55	33	2026-07-15	approved	e262d280-b97e-4087-8e78-a66519bae4d1	\N	2edd0650-e9f0-4937-a0a4-b5187fa62fa4	2026-07-21 18:35:18.932907+00	2026-07-21 18:35:18.932907+00
efb263c4-05b2-42d2-bc77-af9f0cbd846e	2eac4f11-9363-411e-a835-168b6fbcb7e2	faf489ef-0410-4dca-bec1-65dd2fb904ba	رفع اشکالات و بازبینی	184	39	2026-06-27	approved	e262d280-b97e-4087-8e78-a66519bae4d1	\N	b6d74c96-d73a-4927-b991-5aceb860ea03	2026-07-21 18:35:18.932907+00	2026-07-21 18:35:18.932907+00
efb263c4-05b2-42d2-bc77-af9f0cbd846e	2eac4f11-9363-411e-a835-168b6fbcb7e2	faf489ef-0410-4dca-bec1-65dd2fb904ba	رفع اشکالات و بازبینی	37	80	2026-07-01	approved	e262d280-b97e-4087-8e78-a66519bae4d1	\N	b5b4d8be-6c9d-4137-b4be-eeb7f1cf2088	2026-07-21 18:35:18.932907+00	2026-07-21 18:35:18.932907+00
efb263c4-05b2-42d2-bc77-af9f0cbd846e	dbdc5b5f-eb78-4fe9-a3d1-af21873b7177	1c37102f-d8b4-4bea-bd82-5b862cd46e2b	رفع اشکالات و بازبینی	171	32	2026-07-08	approved	e262d280-b97e-4087-8e78-a66519bae4d1	\N	3cc78a82-1ae7-4ad2-a1bc-e3925f705a6d	2026-07-21 18:35:18.932907+00	2026-07-21 18:35:18.932907+00
efb263c4-05b2-42d2-bc77-af9f0cbd846e	dbdc5b5f-eb78-4fe9-a3d1-af21873b7177	1c37102f-d8b4-4bea-bd82-5b862cd46e2b	مستندسازی و نهایی‌سازی	199	64	2026-07-12	approved	e262d280-b97e-4087-8e78-a66519bae4d1	\N	9ea6d13c-8bf3-4b61-a854-1163dd9a6c7b	2026-07-21 18:35:18.932907+00	2026-07-21 18:35:18.932907+00
efb263c4-05b2-42d2-bc77-af9f0cbd846e	dbdc5b5f-eb78-4fe9-a3d1-af21873b7177	1c37102f-d8b4-4bea-bd82-5b862cd46e2b	رفع اشکالات و بازبینی	234	81	2026-07-10	submitted	\N	\N	d4f4665a-dd47-40df-bca5-fe597daee782	2026-07-21 18:35:18.932907+00	2026-07-21 18:35:18.932907+00
efb263c4-05b2-42d2-bc77-af9f0cbd846e	c25344c8-3b4e-41bd-9452-662f17489692	1c37102f-d8b4-4bea-bd82-5b862cd46e2b	رفع اشکالات و بازبینی	69	32	2026-07-16	approved	e262d280-b97e-4087-8e78-a66519bae4d1	\N	6fb635c5-2832-43ac-8998-2a965a351a4d	2026-07-21 18:35:18.932907+00	2026-07-21 18:35:18.932907+00
efb263c4-05b2-42d2-bc77-af9f0cbd846e	0c27ef13-8a84-4aac-bcdd-323d5fa916cc	1d9f738d-866c-4e32-9fe8-b80f0b30a62b	پیشرفت اولیه و بررسی نیازمندی‌ها	53	20	2026-07-16	approved	e262d280-b97e-4087-8e78-a66519bae4d1	\N	a20787dd-c83f-4262-bdca-1c618e31f384	2026-07-21 18:35:18.932907+00	2026-07-21 18:35:18.932907+00
efb263c4-05b2-42d2-bc77-af9f0cbd846e	0c27ef13-8a84-4aac-bcdd-323d5fa916cc	1d9f738d-866c-4e32-9fe8-b80f0b30a62b	رفع اشکالات و بازبینی	56	48	2026-07-16	approved	e262d280-b97e-4087-8e78-a66519bae4d1	\N	2b70dfe3-20ce-4f70-a382-74b99fa16e76	2026-07-21 18:35:18.932907+00	2026-07-21 18:35:18.932907+00
efb263c4-05b2-42d2-bc77-af9f0cbd846e	6ab0ab9d-d2d6-43b9-be3a-0a6569ad194f	1c37102f-d8b4-4bea-bd82-5b862cd46e2b	تست و اطمینان از عملکرد صحیح	144	37	2026-07-16	approved	e262d280-b97e-4087-8e78-a66519bae4d1	\N	020b01e3-0ed8-45ec-84f6-c370804e5115	2026-07-21 18:35:18.932907+00	2026-07-21 18:35:18.932907+00
efb263c4-05b2-42d2-bc77-af9f0cbd846e	a7e0571d-10a2-4d1d-bce6-8e5fa2be06a6	faf489ef-0410-4dca-bec1-65dd2fb904ba	پیشرفت اولیه و بررسی نیازمندی‌ها	52	31	2026-07-15	approved	e262d280-b97e-4087-8e78-a66519bae4d1	\N	5fe65dd2-a647-4570-a879-24b1a729ecdd	2026-07-21 18:35:18.932907+00	2026-07-21 18:35:18.932907+00
efb263c4-05b2-42d2-bc77-af9f0cbd846e	a7e0571d-10a2-4d1d-bce6-8e5fa2be06a6	faf489ef-0410-4dca-bec1-65dd2fb904ba	مستندسازی و نهایی‌سازی	183	60	2026-07-16	approved	e262d280-b97e-4087-8e78-a66519bae4d1	\N	906fad44-8847-48d5-9b83-979fd6c59f48	2026-07-21 18:35:18.932907+00	2026-07-21 18:35:18.932907+00
efb263c4-05b2-42d2-bc77-af9f0cbd846e	a7e0571d-10a2-4d1d-bce6-8e5fa2be06a6	faf489ef-0410-4dca-bec1-65dd2fb904ba	پیشرفت اولیه و بررسی نیازمندی‌ها	104	99	2026-07-16	approved	e262d280-b97e-4087-8e78-a66519bae4d1	\N	493afa96-9abf-4d04-b4fa-6717ff48cefe	2026-07-21 18:35:18.932907+00	2026-07-21 18:35:18.932907+00
efb263c4-05b2-42d2-bc77-af9f0cbd846e	a7e0571d-10a2-4d1d-bce6-8e5fa2be06a6	faf489ef-0410-4dca-bec1-65dd2fb904ba	پیشرفت اولیه و بررسی نیازمندی‌ها	215	100	2026-07-16	approved	e262d280-b97e-4087-8e78-a66519bae4d1	\N	b1599695-5953-486f-815e-649fa0a0b892	2026-07-21 18:35:18.932907+00	2026-07-21 18:35:18.932907+00
efb263c4-05b2-42d2-bc77-af9f0cbd846e	3f85fa25-fb5f-4e20-9b45-86d41f11d457	c288bac5-e3a4-4f1f-a050-de12845acf11	تست و اطمینان از عملکرد صحیح	73	24	2026-07-07	approved	e262d280-b97e-4087-8e78-a66519bae4d1	\N	144657f3-2f7b-47b6-a814-a45a9809951b	2026-07-21 18:35:18.932907+00	2026-07-21 18:35:18.932907+00
efb263c4-05b2-42d2-bc77-af9f0cbd846e	3f85fa25-fb5f-4e20-9b45-86d41f11d457	c288bac5-e3a4-4f1f-a050-de12845acf11	رفع اشکالات و بازبینی	98	70	2026-07-10	approved	e262d280-b97e-4087-8e78-a66519bae4d1	\N	ae2e6719-cf35-40cd-968e-feed46067c57	2026-07-21 18:35:18.932907+00	2026-07-21 18:35:18.932907+00
efb263c4-05b2-42d2-bc77-af9f0cbd846e	4e03791a-b45c-43cd-89fc-cdca1b66daba	e73ec14e-ca0c-4615-92d5-5bc43c14999a	پیاده‌سازی بخش اصلی	141	28	2026-07-16	approved	e262d280-b97e-4087-8e78-a66519bae4d1	\N	7bbb4bc3-4b38-497a-99b8-a2cdcb69591d	2026-07-21 18:35:18.932907+00	2026-07-21 18:35:18.932907+00
efb263c4-05b2-42d2-bc77-af9f0cbd846e	4e03791a-b45c-43cd-89fc-cdca1b66daba	e73ec14e-ca0c-4615-92d5-5bc43c14999a	رفع اشکالات و بازبینی	153	44	2026-07-16	approved	e262d280-b97e-4087-8e78-a66519bae4d1	\N	5bb5ab8e-beac-4c9e-9d6c-b81409eb2b46	2026-07-21 18:35:18.932907+00	2026-07-21 18:35:18.932907+00
efb263c4-05b2-42d2-bc77-af9f0cbd846e	2852312f-f6d1-4e39-b466-b0e92f13921d	e262d280-b97e-4087-8e78-a66519bae4d1	تست و اطمینان از عملکرد صحیح	182	39	2026-07-01	submitted	\N	\N	844bc2ad-5982-47be-9d2d-1bc200f8a022	2026-07-21 18:35:18.932907+00	2026-07-21 18:35:18.932907+00
efb263c4-05b2-42d2-bc77-af9f0cbd846e	2852312f-f6d1-4e39-b466-b0e92f13921d	e262d280-b97e-4087-8e78-a66519bae4d1	پیاده‌سازی بخش اصلی	107	40	2026-07-03	approved	e262d280-b97e-4087-8e78-a66519bae4d1	\N	8874ae9a-a204-4d77-a100-1a21f50267af	2026-07-21 18:35:18.932907+00	2026-07-21 18:35:18.932907+00
efb263c4-05b2-42d2-bc77-af9f0cbd846e	2852312f-f6d1-4e39-b466-b0e92f13921d	e262d280-b97e-4087-8e78-a66519bae4d1	مستندسازی و نهایی‌سازی	127	90	2026-07-09	approved	e262d280-b97e-4087-8e78-a66519bae4d1	\N	9df7e05c-6283-4ae4-a0d2-03a7cedc5bee	2026-07-21 18:35:18.932907+00	2026-07-21 18:35:18.932907+00
efb263c4-05b2-42d2-bc77-af9f0cbd846e	e0c94bd9-24ee-4cf5-a2cc-b6a84691e032	7dcd0e37-2d6c-4eab-8a6a-3598c4e01433	تست و اطمینان از عملکرد صحیح	238	40	2026-07-15	approved	e262d280-b97e-4087-8e78-a66519bae4d1	\N	62eef155-1f22-4854-bea3-1279f267d02b	2026-07-21 18:35:18.932907+00	2026-07-21 18:35:18.932907+00
efb263c4-05b2-42d2-bc77-af9f0cbd846e	e0c94bd9-24ee-4cf5-a2cc-b6a84691e032	7dcd0e37-2d6c-4eab-8a6a-3598c4e01433	رفع اشکالات و بازبینی	112	78	2026-07-16	approved	e262d280-b97e-4087-8e78-a66519bae4d1	\N	19e9a0d4-20d7-4958-9e96-c8af8a700d22	2026-07-21 18:35:18.932907+00	2026-07-21 18:35:18.932907+00
efb263c4-05b2-42d2-bc77-af9f0cbd846e	e0c94bd9-24ee-4cf5-a2cc-b6a84691e032	7dcd0e37-2d6c-4eab-8a6a-3598c4e01433	تست و اطمینان از عملکرد صحیح	110	75	2026-07-16	approved	e262d280-b97e-4087-8e78-a66519bae4d1	\N	d8c4c153-0a36-4e07-bf4d-f5c89967b767	2026-07-21 18:35:18.932907+00	2026-07-21 18:35:18.932907+00
efb263c4-05b2-42d2-bc77-af9f0cbd846e	e0c94bd9-24ee-4cf5-a2cc-b6a84691e032	7dcd0e37-2d6c-4eab-8a6a-3598c4e01433	رفع اشکالات و بازبینی	104	100	2026-07-16	approved	e262d280-b97e-4087-8e78-a66519bae4d1	\N	8ac3c95d-b96f-4dc5-b713-266d93cc5598	2026-07-21 18:35:18.932907+00	2026-07-21 18:35:18.932907+00
efb263c4-05b2-42d2-bc77-af9f0cbd846e	a9563a01-036c-427e-ade8-36f60580a921	e262d280-b97e-4087-8e78-a66519bae4d1	رفع اشکالات و بازبینی	239	32	2026-07-16	approved	e262d280-b97e-4087-8e78-a66519bae4d1	\N	8def48d1-ccd6-47ea-8462-3a4616e0e1c3	2026-07-21 18:35:18.932907+00	2026-07-21 18:35:18.932907+00
efb263c4-05b2-42d2-bc77-af9f0cbd846e	a9563a01-036c-427e-ade8-36f60580a921	e262d280-b97e-4087-8e78-a66519bae4d1	مستندسازی و نهایی‌سازی	81	76	2026-07-16	approved	e262d280-b97e-4087-8e78-a66519bae4d1	\N	98c0b010-73bd-42dd-8890-53ece2cb23c8	2026-07-21 18:35:18.932907+00	2026-07-21 18:35:18.932907+00
efb263c4-05b2-42d2-bc77-af9f0cbd846e	a9563a01-036c-427e-ade8-36f60580a921	e262d280-b97e-4087-8e78-a66519bae4d1	مستندسازی و نهایی‌سازی	36	100	2026-07-16	approved	e262d280-b97e-4087-8e78-a66519bae4d1	\N	d7ee66dd-300e-46df-a1b6-43eb2a8fe616	2026-07-21 18:35:18.932907+00	2026-07-21 18:35:18.932907+00
efb263c4-05b2-42d2-bc77-af9f0cbd846e	a9563a01-036c-427e-ade8-36f60580a921	e262d280-b97e-4087-8e78-a66519bae4d1	رفع اشکالات و بازبینی	207	88	2026-07-16	approved	e262d280-b97e-4087-8e78-a66519bae4d1	\N	675327d5-d5a9-4a33-a297-2d15a2cdb0a5	2026-07-21 18:35:18.932907+00	2026-07-21 18:35:18.932907+00
efb263c4-05b2-42d2-bc77-af9f0cbd846e	443949c4-d85a-4d4d-8f46-4a27cf02327c	e262d280-b97e-4087-8e78-a66519bae4d1	رفع اشکالات و بازبینی	91	28	2026-07-16	approved	e262d280-b97e-4087-8e78-a66519bae4d1	\N	229cf7ef-85ee-41b4-aaa3-7951c36f106a	2026-07-21 18:35:18.932907+00	2026-07-21 18:35:18.932907+00
efb263c4-05b2-42d2-bc77-af9f0cbd846e	443949c4-d85a-4d4d-8f46-4a27cf02327c	e262d280-b97e-4087-8e78-a66519bae4d1	تست و اطمینان از عملکرد صحیح	48	68	2026-07-16	submitted	\N	\N	08409525-09e8-43b8-8625-c5b7b0fa05f6	2026-07-21 18:35:18.932907+00	2026-07-21 18:35:18.932907+00
efb263c4-05b2-42d2-bc77-af9f0cbd846e	443949c4-d85a-4d4d-8f46-4a27cf02327c	e262d280-b97e-4087-8e78-a66519bae4d1	مستندسازی و نهایی‌سازی	159	99	2026-07-16	approved	e262d280-b97e-4087-8e78-a66519bae4d1	\N	0f314286-df8d-4047-a993-6fe04fcb1bec	2026-07-21 18:35:18.932907+00	2026-07-21 18:35:18.932907+00
efb263c4-05b2-42d2-bc77-af9f0cbd846e	443949c4-d85a-4d4d-8f46-4a27cf02327c	e262d280-b97e-4087-8e78-a66519bae4d1	رفع اشکالات و بازبینی	209	100	2026-07-16	submitted	\N	\N	7fac5d14-8df9-4fdf-bd37-b25039f5acf6	2026-07-21 18:35:18.932907+00	2026-07-21 18:35:18.932907+00
efb263c4-05b2-42d2-bc77-af9f0cbd846e	fc9c27a2-b091-433b-b48b-74cb7b339a12	1d9f738d-866c-4e32-9fe8-b80f0b30a62b	پیاده‌سازی بخش اصلی	198	31	2026-06-24	approved	e262d280-b97e-4087-8e78-a66519bae4d1	\N	3be318a8-29ea-4972-886c-eee7efa92057	2026-07-21 18:35:18.932907+00	2026-07-21 18:35:18.932907+00
efb263c4-05b2-42d2-bc77-af9f0cbd846e	3d2be215-2408-4b23-9dda-25dab29e6ff5	e73ec14e-ca0c-4615-92d5-5bc43c14999a	مستندسازی و نهایی‌سازی	195	40	2026-07-16	approved	e262d280-b97e-4087-8e78-a66519bae4d1	\N	3a3fc654-9ebb-4282-848b-b9eddc29e9a1	2026-07-21 18:35:18.932907+00	2026-07-21 18:35:18.932907+00
efb263c4-05b2-42d2-bc77-af9f0cbd846e	3d2be215-2408-4b23-9dda-25dab29e6ff5	e73ec14e-ca0c-4615-92d5-5bc43c14999a	رفع اشکالات و بازبینی	233	66	2026-07-16	approved	e262d280-b97e-4087-8e78-a66519bae4d1	\N	c13c32cb-e135-4e1c-954f-1922f71bc637	2026-07-21 18:35:18.932907+00	2026-07-21 18:35:18.932907+00
efb263c4-05b2-42d2-bc77-af9f0cbd846e	061387ea-6729-41b7-bc34-6f6f75aa20a6	1d9f738d-866c-4e32-9fe8-b80f0b30a62b	پیشرفت اولیه و بررسی نیازمندی‌ها	96	27	2026-07-16	approved	e262d280-b97e-4087-8e78-a66519bae4d1	\N	0ddad8b2-3da1-4c4a-a219-be4e2a4afadd	2026-07-21 18:35:18.932907+00	2026-07-21 18:35:18.932907+00
efb263c4-05b2-42d2-bc77-af9f0cbd846e	25de42a2-b7e6-402d-b89b-8ac93239ff6d	faf489ef-0410-4dca-bec1-65dd2fb904ba	رفع اشکالات و بازبینی	130	34	2026-07-16	approved	e262d280-b97e-4087-8e78-a66519bae4d1	\N	e4c2f4cd-551c-428f-be66-596def5f0ad0	2026-07-21 18:35:18.932907+00	2026-07-21 18:35:18.932907+00
efb263c4-05b2-42d2-bc77-af9f0cbd846e	25de42a2-b7e6-402d-b89b-8ac93239ff6d	faf489ef-0410-4dca-bec1-65dd2fb904ba	رفع اشکالات و بازبینی	36	70	2026-07-16	approved	e262d280-b97e-4087-8e78-a66519bae4d1	\N	6756889c-bde2-4c02-bfff-c8d0fe715417	2026-07-21 18:35:18.932907+00	2026-07-21 18:35:18.932907+00
efb263c4-05b2-42d2-bc77-af9f0cbd846e	888303ad-666d-498d-a8b1-7f0269dba779	e73ec14e-ca0c-4615-92d5-5bc43c14999a	پیشرفت اولیه و بررسی نیازمندی‌ها	59	24	2026-07-16	approved	e262d280-b97e-4087-8e78-a66519bae4d1	\N	b6e035f5-9355-45c7-837e-f8c0a47c69ac	2026-07-21 18:35:18.932907+00	2026-07-21 18:35:18.932907+00
efb263c4-05b2-42d2-bc77-af9f0cbd846e	f328986f-35ff-4b68-979e-ac51e0dc3fe2	1c37102f-d8b4-4bea-bd82-5b862cd46e2b	رفع اشکالات و بازبینی	146	26	2026-07-16	approved	e262d280-b97e-4087-8e78-a66519bae4d1	\N	d71b18da-aa60-40c8-ba41-8461d1bd0bca	2026-07-21 18:35:18.932907+00	2026-07-21 18:35:18.932907+00
efb263c4-05b2-42d2-bc77-af9f0cbd846e	f328986f-35ff-4b68-979e-ac51e0dc3fe2	1c37102f-d8b4-4bea-bd82-5b862cd46e2b	رفع اشکالات و بازبینی	151	46	2026-07-16	approved	e262d280-b97e-4087-8e78-a66519bae4d1	\N	db58aa0e-7fce-473a-98c9-92845d4af438	2026-07-21 18:35:18.932907+00	2026-07-21 18:35:18.932907+00
efb263c4-05b2-42d2-bc77-af9f0cbd846e	f328986f-35ff-4b68-979e-ac51e0dc3fe2	1c37102f-d8b4-4bea-bd82-5b862cd46e2b	تست و اطمینان از عملکرد صحیح	111	66	2026-07-16	approved	e262d280-b97e-4087-8e78-a66519bae4d1	\N	f6015077-9edf-4aab-ad0c-066cccbead8c	2026-07-21 18:35:18.932907+00	2026-07-21 18:35:18.932907+00
efb263c4-05b2-42d2-bc77-af9f0cbd846e	8263a9d6-34f0-41fd-b8d7-aac8a3ffc2ec	faf489ef-0410-4dca-bec1-65dd2fb904ba	پیشرفت اولیه و بررسی نیازمندی‌ها	35	30	2026-07-16	approved	e262d280-b97e-4087-8e78-a66519bae4d1	\N	755fed27-c6d4-4497-82ed-8f756aacf31f	2026-07-21 18:35:18.932907+00	2026-07-21 18:35:18.932907+00
efb263c4-05b2-42d2-bc77-af9f0cbd846e	8263a9d6-34f0-41fd-b8d7-aac8a3ffc2ec	faf489ef-0410-4dca-bec1-65dd2fb904ba	پیاده‌سازی بخش اصلی	219	54	2026-07-16	approved	e262d280-b97e-4087-8e78-a66519bae4d1	\N	ee0e4ba3-fb53-441c-b3e9-a8ede5f47993	2026-07-21 18:35:18.932907+00	2026-07-21 18:35:18.932907+00
efb263c4-05b2-42d2-bc77-af9f0cbd846e	8263a9d6-34f0-41fd-b8d7-aac8a3ffc2ec	faf489ef-0410-4dca-bec1-65dd2fb904ba	مستندسازی و نهایی‌سازی	70	90	2026-07-16	approved	e262d280-b97e-4087-8e78-a66519bae4d1	\N	c57ca3d8-5e63-4cf6-9214-901255e62e07	2026-07-21 18:35:18.932907+00	2026-07-21 18:35:18.932907+00
efb263c4-05b2-42d2-bc77-af9f0cbd846e	45ee5568-2972-4ca1-b419-7856f78c2315	1c37102f-d8b4-4bea-bd82-5b862cd46e2b	پیاده‌سازی بخش اصلی	234	32	2026-07-16	approved	e262d280-b97e-4087-8e78-a66519bae4d1	\N	7c1df5b5-3cb7-4db0-a32f-f9333e442d3a	2026-07-21 18:35:18.932907+00	2026-07-21 18:35:18.932907+00
efb263c4-05b2-42d2-bc77-af9f0cbd846e	45ee5568-2972-4ca1-b419-7856f78c2315	1c37102f-d8b4-4bea-bd82-5b862cd46e2b	پیاده‌سازی بخش اصلی	193	66	2026-07-16	approved	e262d280-b97e-4087-8e78-a66519bae4d1	\N	8e4481d1-6ddb-4d98-9874-3fd105f54caf	2026-07-21 18:35:18.932907+00	2026-07-21 18:35:18.932907+00
efb263c4-05b2-42d2-bc77-af9f0cbd846e	45ee5568-2972-4ca1-b419-7856f78c2315	1c37102f-d8b4-4bea-bd82-5b862cd46e2b	پیشرفت اولیه و بررسی نیازمندی‌ها	218	100	2026-07-16	approved	e262d280-b97e-4087-8e78-a66519bae4d1	\N	e922b54e-94e5-4f8e-b9f6-e3c22bf35957	2026-07-21 18:35:18.932907+00	2026-07-21 18:35:18.932907+00
efb263c4-05b2-42d2-bc77-af9f0cbd846e	45ee5568-2972-4ca1-b419-7856f78c2315	1c37102f-d8b4-4bea-bd82-5b862cd46e2b	تست و اطمینان از عملکرد صحیح	181	100	2026-07-16	approved	e262d280-b97e-4087-8e78-a66519bae4d1	\N	b8551569-4ca9-41d8-a270-c48ab2b7d400	2026-07-21 18:35:18.932907+00	2026-07-21 18:35:18.932907+00
efb263c4-05b2-42d2-bc77-af9f0cbd846e	f997864a-36e5-4fdb-9fc3-64d0e1f084da	1c37102f-d8b4-4bea-bd82-5b862cd46e2b	پیاده‌سازی بخش اصلی	101	22	2026-07-12	submitted	\N	\N	c021880c-23b9-4c64-aeee-9f76385bfac9	2026-07-21 18:35:18.932907+00	2026-07-21 18:35:18.932907+00
efb263c4-05b2-42d2-bc77-af9f0cbd846e	f997864a-36e5-4fdb-9fc3-64d0e1f084da	1c37102f-d8b4-4bea-bd82-5b862cd46e2b	مستندسازی و نهایی‌سازی	77	62	2026-07-13	submitted	\N	\N	bb8a72ed-c318-4a17-a9c4-45c904db7973	2026-07-21 18:35:18.932907+00	2026-07-21 18:35:18.932907+00
efb263c4-05b2-42d2-bc77-af9f0cbd846e	f997864a-36e5-4fdb-9fc3-64d0e1f084da	1c37102f-d8b4-4bea-bd82-5b862cd46e2b	پیشرفت اولیه و بررسی نیازمندی‌ها	97	100	2026-07-16	approved	e262d280-b97e-4087-8e78-a66519bae4d1	\N	e5145687-deff-4e58-9b91-f29e23f823ae	2026-07-21 18:35:18.932907+00	2026-07-21 18:35:18.932907+00
efb263c4-05b2-42d2-bc77-af9f0cbd846e	f997864a-36e5-4fdb-9fc3-64d0e1f084da	1c37102f-d8b4-4bea-bd82-5b862cd46e2b	مستندسازی و نهایی‌سازی	130	100	2026-07-16	approved	e262d280-b97e-4087-8e78-a66519bae4d1	\N	53bc69c9-cccb-4e4f-ba08-f78f26356b3c	2026-07-21 18:35:18.932907+00	2026-07-21 18:35:18.932907+00
efb263c4-05b2-42d2-bc77-af9f0cbd846e	3b2ddafb-cf85-460c-81c2-033f4dd6af90	1c37102f-d8b4-4bea-bd82-5b862cd46e2b	رفع اشکالات و بازبینی	147	39	2026-06-19	approved	e262d280-b97e-4087-8e78-a66519bae4d1	\N	51ab0bdd-1c0f-4877-85ec-f50e8fddb454	2026-07-21 18:35:18.932907+00	2026-07-21 18:35:18.932907+00
efb263c4-05b2-42d2-bc77-af9f0cbd846e	e112eaac-5914-4e6d-9a6c-889375357a3d	1c37102f-d8b4-4bea-bd82-5b862cd46e2b	مستندسازی و نهایی‌سازی	181	22	2026-07-06	approved	e262d280-b97e-4087-8e78-a66519bae4d1	\N	92ac5d58-a9c0-4e5e-9817-f6b05f4f4269	2026-07-21 18:35:18.932907+00	2026-07-21 18:35:18.932907+00
efb263c4-05b2-42d2-bc77-af9f0cbd846e	e112eaac-5914-4e6d-9a6c-889375357a3d	1c37102f-d8b4-4bea-bd82-5b862cd46e2b	رفع اشکالات و بازبینی	60	54	2026-07-08	approved	e262d280-b97e-4087-8e78-a66519bae4d1	\N	ed696331-658a-4e81-81fb-c42b6eabda50	2026-07-21 18:35:18.932907+00	2026-07-21 18:35:18.932907+00
efb263c4-05b2-42d2-bc77-af9f0cbd846e	b56bc6c2-3669-4ad2-a35e-aaf256ab2df3	e73ec14e-ca0c-4615-92d5-5bc43c14999a	پیاده‌سازی بخش اصلی	125	24	2026-07-16	approved	e262d280-b97e-4087-8e78-a66519bae4d1	\N	feaf3803-88dd-4b63-abdd-650ddb3f844b	2026-07-21 18:35:18.932907+00	2026-07-21 18:35:18.932907+00
efb263c4-05b2-42d2-bc77-af9f0cbd846e	b56bc6c2-3669-4ad2-a35e-aaf256ab2df3	e73ec14e-ca0c-4615-92d5-5bc43c14999a	تست و اطمینان از عملکرد صحیح	182	48	2026-07-16	approved	e262d280-b97e-4087-8e78-a66519bae4d1	\N	1eac1f8b-319c-4483-a397-b7398dc1d801	2026-07-21 18:35:18.932907+00	2026-07-21 18:35:18.932907+00
efb263c4-05b2-42d2-bc77-af9f0cbd846e	b56bc6c2-3669-4ad2-a35e-aaf256ab2df3	e73ec14e-ca0c-4615-92d5-5bc43c14999a	تست و اطمینان از عملکرد صحیح	77	100	2026-07-16	approved	e262d280-b97e-4087-8e78-a66519bae4d1	\N	48301cdb-08f5-4900-901f-7ec14bed4007	2026-07-21 18:35:18.932907+00	2026-07-21 18:35:18.932907+00
efb263c4-05b2-42d2-bc77-af9f0cbd846e	110663bf-7858-466a-a4d8-6d6ab83c284d	7dcd0e37-2d6c-4eab-8a6a-3598c4e01433	پیاده‌سازی بخش اصلی	77	30	2026-07-16	approved	e262d280-b97e-4087-8e78-a66519bae4d1	\N	ae3ff732-bebe-4b26-b83c-11349ecf4322	2026-07-21 18:35:18.932907+00	2026-07-21 18:35:18.932907+00
efb263c4-05b2-42d2-bc77-af9f0cbd846e	110663bf-7858-466a-a4d8-6d6ab83c284d	7dcd0e37-2d6c-4eab-8a6a-3598c4e01433	رفع اشکالات و بازبینی	32	70	2026-07-16	approved	e262d280-b97e-4087-8e78-a66519bae4d1	\N	c23ef362-775e-4714-8e20-14c97bc40ff1	2026-07-21 18:35:18.932907+00	2026-07-21 18:35:18.932907+00
efb263c4-05b2-42d2-bc77-af9f0cbd846e	15bd443f-1c58-4b82-b933-3f3dbd15ad26	1c37102f-d8b4-4bea-bd82-5b862cd46e2b	تست و اطمینان از عملکرد صحیح	173	36	2026-07-16	approved	e262d280-b97e-4087-8e78-a66519bae4d1	\N	bc7d2869-9ad6-4a23-ac36-00df5244f657	2026-07-21 18:35:18.932907+00	2026-07-21 18:35:18.932907+00
efb263c4-05b2-42d2-bc77-af9f0cbd846e	15bd443f-1c58-4b82-b933-3f3dbd15ad26	1c37102f-d8b4-4bea-bd82-5b862cd46e2b	تست و اطمینان از عملکرد صحیح	205	70	2026-07-16	approved	e262d280-b97e-4087-8e78-a66519bae4d1	\N	f68ba557-480c-419f-b891-12fb35e00e23	2026-07-21 18:35:18.932907+00	2026-07-21 18:35:18.932907+00
efb263c4-05b2-42d2-bc77-af9f0cbd846e	5a0c3ad0-c55e-4a09-ac80-555a3586e715	faf489ef-0410-4dca-bec1-65dd2fb904ba	تست و اطمینان از عملکرد صحیح	72	22	2026-07-03	approved	e262d280-b97e-4087-8e78-a66519bae4d1	\N	d0f68f34-0735-4d3a-814d-b543e434d67b	2026-07-21 18:35:18.932907+00	2026-07-21 18:35:18.932907+00
efb263c4-05b2-42d2-bc77-af9f0cbd846e	5a0c3ad0-c55e-4a09-ac80-555a3586e715	faf489ef-0410-4dca-bec1-65dd2fb904ba	پیاده‌سازی بخش اصلی	104	42	2026-07-04	approved	e262d280-b97e-4087-8e78-a66519bae4d1	\N	9191728b-1879-47dc-9a4c-c3d5af24e2b0	2026-07-21 18:35:18.932907+00	2026-07-21 18:35:18.932907+00
efb263c4-05b2-42d2-bc77-af9f0cbd846e	5a0c3ad0-c55e-4a09-ac80-555a3586e715	faf489ef-0410-4dca-bec1-65dd2fb904ba	پیاده‌سازی بخش اصلی	167	87	2026-07-09	approved	e262d280-b97e-4087-8e78-a66519bae4d1	\N	a1cbae5c-119c-4f95-8e7f-b98a9a25ebd8	2026-07-21 18:35:18.932907+00	2026-07-21 18:35:18.932907+00
efb263c4-05b2-42d2-bc77-af9f0cbd846e	5a0c3ad0-c55e-4a09-ac80-555a3586e715	faf489ef-0410-4dca-bec1-65dd2fb904ba	تست و اطمینان از عملکرد صحیح	174	100	2026-07-09	approved	e262d280-b97e-4087-8e78-a66519bae4d1	\N	8d639290-5cf5-46f9-99ae-98c8d7497df4	2026-07-21 18:35:18.932907+00	2026-07-21 18:35:18.932907+00
efb263c4-05b2-42d2-bc77-af9f0cbd846e	e7cc4676-81c6-430b-bce1-39ba5b5927a1	c288bac5-e3a4-4f1f-a050-de12845acf11	مستندسازی و نهایی‌سازی	240	31	2026-07-16	approved	e262d280-b97e-4087-8e78-a66519bae4d1	\N	6dc41576-108f-4184-a72a-bf2b1b269255	2026-07-21 18:35:18.932907+00	2026-07-21 18:35:18.932907+00
efb263c4-05b2-42d2-bc77-af9f0cbd846e	71b9390b-6f92-4150-954f-48a43c9b9af0	e262d280-b97e-4087-8e78-a66519bae4d1	تست و اطمینان از عملکرد صحیح	56	40	2026-07-16	approved	e262d280-b97e-4087-8e78-a66519bae4d1	\N	702b2efe-0b39-45f2-87c5-c6a1b7058cf4	2026-07-21 18:35:18.932907+00	2026-07-21 18:35:18.932907+00
efb263c4-05b2-42d2-bc77-af9f0cbd846e	82ccc342-d80e-4c98-a0bc-883d9b740ce6	faf489ef-0410-4dca-bec1-65dd2fb904ba	پیشرفت اولیه و بررسی نیازمندی‌ها	145	28	2026-07-16	approved	e262d280-b97e-4087-8e78-a66519bae4d1	\N	c968c39f-4115-4a9d-b4ad-6c7502e37e4e	2026-07-21 18:35:18.932907+00	2026-07-21 18:35:18.932907+00
efb263c4-05b2-42d2-bc77-af9f0cbd846e	82ccc342-d80e-4c98-a0bc-883d9b740ce6	faf489ef-0410-4dca-bec1-65dd2fb904ba	پیشرفت اولیه و بررسی نیازمندی‌ها	142	46	2026-07-16	approved	e262d280-b97e-4087-8e78-a66519bae4d1	\N	1bc08d95-3052-4d70-b9da-7201dbe34297	2026-07-21 18:35:18.932907+00	2026-07-21 18:35:18.932907+00
efb263c4-05b2-42d2-bc77-af9f0cbd846e	78245f50-9f95-4855-a82b-9395d159212a	1d9f738d-866c-4e32-9fe8-b80f0b30a62b	مستندسازی و نهایی‌سازی	206	31	2026-07-01	submitted	\N	\N	31561474-19af-48c0-83c4-82ad7686d018	2026-07-21 18:35:18.932907+00	2026-07-21 18:35:18.932907+00
efb263c4-05b2-42d2-bc77-af9f0cbd846e	78245f50-9f95-4855-a82b-9395d159212a	1d9f738d-866c-4e32-9fe8-b80f0b30a62b	پیاده‌سازی بخش اصلی	230	52	2026-07-05	approved	e262d280-b97e-4087-8e78-a66519bae4d1	\N	a8d645e3-f3b5-4d70-a21e-1e61a4b8c50e	2026-07-21 18:35:18.932907+00	2026-07-21 18:35:18.932907+00
efb263c4-05b2-42d2-bc77-af9f0cbd846e	31d5b0cc-0bea-4135-a4d9-e98eaaa61148	7dcd0e37-2d6c-4eab-8a6a-3598c4e01433	مستندسازی و نهایی‌سازی	119	37	2026-07-04	approved	e262d280-b97e-4087-8e78-a66519bae4d1	\N	207a0e61-1389-4a35-87a8-89b7bb919ba1	2026-07-21 18:35:18.932907+00	2026-07-21 18:35:18.932907+00
efb263c4-05b2-42d2-bc77-af9f0cbd846e	31d5b0cc-0bea-4135-a4d9-e98eaaa61148	7dcd0e37-2d6c-4eab-8a6a-3598c4e01433	مستندسازی و نهایی‌سازی	167	50	2026-07-07	approved	e262d280-b97e-4087-8e78-a66519bae4d1	\N	aad6c212-3283-4ae6-85d7-d0affe3f268f	2026-07-21 18:35:18.932907+00	2026-07-21 18:35:18.932907+00
efb263c4-05b2-42d2-bc77-af9f0cbd846e	fea5dc03-3e76-4b65-be14-4a248c0c7a8f	e262d280-b97e-4087-8e78-a66519bae4d1	رفع اشکالات و بازبینی	176	28	2026-07-16	approved	e262d280-b97e-4087-8e78-a66519bae4d1	\N	91cf7948-7f57-4de6-b5a9-b28787b03714	2026-07-21 18:35:18.932907+00	2026-07-21 18:35:18.932907+00
efb263c4-05b2-42d2-bc77-af9f0cbd846e	fea5dc03-3e76-4b65-be14-4a248c0c7a8f	e262d280-b97e-4087-8e78-a66519bae4d1	پیاده‌سازی بخش اصلی	222	66	2026-07-16	approved	e262d280-b97e-4087-8e78-a66519bae4d1	\N	4f14ce97-5ad8-4f06-bd8c-30aa44f2300c	2026-07-21 18:35:18.932907+00	2026-07-21 18:35:18.932907+00
efb263c4-05b2-42d2-bc77-af9f0cbd846e	fea5dc03-3e76-4b65-be14-4a248c0c7a8f	e262d280-b97e-4087-8e78-a66519bae4d1	رفع اشکالات و بازبینی	197	72	2026-07-16	approved	e262d280-b97e-4087-8e78-a66519bae4d1	\N	ad66a128-8853-414c-9991-12ea72a7c01a	2026-07-21 18:35:18.932907+00	2026-07-21 18:35:18.932907+00
efb263c4-05b2-42d2-bc77-af9f0cbd846e	b454f7e0-49b2-457d-a74f-e7473510df34	1c37102f-d8b4-4bea-bd82-5b862cd46e2b	رفع اشکالات و بازبینی	93	32	2026-07-16	approved	e262d280-b97e-4087-8e78-a66519bae4d1	\N	7761d2c0-7d2c-4bbf-b9a4-a756bcab6ef1	2026-07-21 18:35:18.932907+00	2026-07-21 18:35:18.932907+00
efb263c4-05b2-42d2-bc77-af9f0cbd846e	b454f7e0-49b2-457d-a74f-e7473510df34	1c37102f-d8b4-4bea-bd82-5b862cd46e2b	رفع اشکالات و بازبینی	190	66	2026-07-16	approved	e262d280-b97e-4087-8e78-a66519bae4d1	\N	455ecdf3-e012-492c-b899-a53a98d91c0c	2026-07-21 18:35:18.932907+00	2026-07-21 18:35:18.932907+00
efb263c4-05b2-42d2-bc77-af9f0cbd846e	27885bbd-aa1e-4479-b8c7-9838c0900aa9	e73ec14e-ca0c-4615-92d5-5bc43c14999a	پیشرفت اولیه و بررسی نیازمندی‌ها	133	36	2026-07-15	approved	e262d280-b97e-4087-8e78-a66519bae4d1	\N	f589ea14-8cd1-4b01-b557-576db8ad67d6	2026-07-21 18:35:18.932907+00	2026-07-21 18:35:18.932907+00
efb263c4-05b2-42d2-bc77-af9f0cbd846e	27885bbd-aa1e-4479-b8c7-9838c0900aa9	e73ec14e-ca0c-4615-92d5-5bc43c14999a	رفع اشکالات و بازبینی	146	70	2026-07-16	approved	e262d280-b97e-4087-8e78-a66519bae4d1	\N	e090c046-8d04-47ee-b3c6-7294407450d7	2026-07-21 18:35:18.932907+00	2026-07-21 18:35:18.932907+00
efb263c4-05b2-42d2-bc77-af9f0cbd846e	27885bbd-aa1e-4479-b8c7-9838c0900aa9	e73ec14e-ca0c-4615-92d5-5bc43c14999a	پیشرفت اولیه و بررسی نیازمندی‌ها	217	100	2026-07-16	approved	e262d280-b97e-4087-8e78-a66519bae4d1	\N	d4187cf2-88f1-44e9-8180-f97f47cf7c3e	2026-07-21 18:35:18.932907+00	2026-07-21 18:35:18.932907+00
efb263c4-05b2-42d2-bc77-af9f0cbd846e	27885bbd-aa1e-4479-b8c7-9838c0900aa9	e73ec14e-ca0c-4615-92d5-5bc43c14999a	مستندسازی و نهایی‌سازی	131	100	2026-07-16	submitted	\N	\N	7591c071-748d-4ae8-80d7-a60b1dc0069a	2026-07-21 18:35:18.932907+00	2026-07-21 18:35:18.932907+00
efb263c4-05b2-42d2-bc77-af9f0cbd846e	9153f009-744b-427f-a0ed-6ef1d88683c8	c288bac5-e3a4-4f1f-a050-de12845acf11	رفع اشکالات و بازبینی	102	30	2026-06-28	approved	e262d280-b97e-4087-8e78-a66519bae4d1	\N	a7beb8e3-fff1-4a4c-9670-acc9d7cea929	2026-07-21 18:35:18.932907+00	2026-07-21 18:35:18.932907+00
efb263c4-05b2-42d2-bc77-af9f0cbd846e	9153f009-744b-427f-a0ed-6ef1d88683c8	c288bac5-e3a4-4f1f-a050-de12845acf11	تست و اطمینان از عملکرد صحیح	231	60	2026-06-30	approved	e262d280-b97e-4087-8e78-a66519bae4d1	\N	8493baa2-fd58-452a-8ed9-55cc9b42df64	2026-07-21 18:35:18.932907+00	2026-07-21 18:35:18.932907+00
efb263c4-05b2-42d2-bc77-af9f0cbd846e	9153f009-744b-427f-a0ed-6ef1d88683c8	c288bac5-e3a4-4f1f-a050-de12845acf11	تست و اطمینان از عملکرد صحیح	34	69	2026-06-30	approved	e262d280-b97e-4087-8e78-a66519bae4d1	\N	e2abf0dd-2ba2-4c64-bf5f-92beb2a68b23	2026-07-21 18:35:18.932907+00	2026-07-21 18:35:18.932907+00
efb263c4-05b2-42d2-bc77-af9f0cbd846e	9153f009-744b-427f-a0ed-6ef1d88683c8	c288bac5-e3a4-4f1f-a050-de12845acf11	پیشرفت اولیه و بررسی نیازمندی‌ها	139	100	2026-07-04	approved	e262d280-b97e-4087-8e78-a66519bae4d1	\N	a6f39741-f650-46a7-aade-40db1d249d12	2026-07-21 18:35:18.932907+00	2026-07-21 18:35:18.932907+00
efb263c4-05b2-42d2-bc77-af9f0cbd846e	fc23ecfd-d090-489e-8e9b-28eb2056c4e6	c288bac5-e3a4-4f1f-a050-de12845acf11	پیاده‌سازی بخش اصلی	100	22	2026-06-24	approved	e262d280-b97e-4087-8e78-a66519bae4d1	\N	53df6407-8d1d-47b8-9ae8-3634c378cd59	2026-07-21 18:35:18.932907+00	2026-07-21 18:35:18.932907+00
efb263c4-05b2-42d2-bc77-af9f0cbd846e	fc23ecfd-d090-489e-8e9b-28eb2056c4e6	c288bac5-e3a4-4f1f-a050-de12845acf11	رفع اشکالات و بازبینی	51	62	2026-06-27	approved	e262d280-b97e-4087-8e78-a66519bae4d1	\N	70119f1e-1077-47c4-b8e4-ed0de652a324	2026-07-21 18:35:18.932907+00	2026-07-21 18:35:18.932907+00
efb263c4-05b2-42d2-bc77-af9f0cbd846e	daf690b2-f62b-4a5c-b566-d5d1c69d9c18	c288bac5-e3a4-4f1f-a050-de12845acf11	رفع اشکالات و بازبینی	215	27	2026-07-14	approved	e262d280-b97e-4087-8e78-a66519bae4d1	\N	00e8b6d4-6d0c-4126-b254-7aead9cf1f29	2026-07-21 18:35:18.932907+00	2026-07-21 18:35:18.932907+00
efb263c4-05b2-42d2-bc77-af9f0cbd846e	daf690b2-f62b-4a5c-b566-d5d1c69d9c18	c288bac5-e3a4-4f1f-a050-de12845acf11	پیشرفت اولیه و بررسی نیازمندی‌ها	30	52	2026-07-16	approved	e262d280-b97e-4087-8e78-a66519bae4d1	\N	c216a832-40d0-43dc-bacc-c61196486ba3	2026-07-21 18:35:18.932907+00	2026-07-21 18:35:18.932907+00
efb263c4-05b2-42d2-bc77-af9f0cbd846e	03b62107-913a-4a84-9e12-2781603405a3	e262d280-b97e-4087-8e78-a66519bae4d1	پیاده‌سازی بخش اصلی	162	34	2026-07-16	approved	e262d280-b97e-4087-8e78-a66519bae4d1	\N	a6aa962d-55d7-4527-a6b6-bcfe70b59438	2026-07-21 18:35:18.932907+00	2026-07-21 18:35:18.932907+00
efb263c4-05b2-42d2-bc77-af9f0cbd846e	03b62107-913a-4a84-9e12-2781603405a3	e262d280-b97e-4087-8e78-a66519bae4d1	رفع اشکالات و بازبینی	239	46	2026-07-16	approved	e262d280-b97e-4087-8e78-a66519bae4d1	\N	6784305c-61d6-4783-b557-ba95a3da3d26	2026-07-21 18:35:18.932907+00	2026-07-21 18:35:18.932907+00
efb263c4-05b2-42d2-bc77-af9f0cbd846e	03b62107-913a-4a84-9e12-2781603405a3	e262d280-b97e-4087-8e78-a66519bae4d1	تست و اطمینان از عملکرد صحیح	48	81	2026-07-16	approved	e262d280-b97e-4087-8e78-a66519bae4d1	\N	c6da649a-0194-4b03-9dc8-bbfd53e6d42c	2026-07-21 18:35:18.932907+00	2026-07-21 18:35:18.932907+00
efb263c4-05b2-42d2-bc77-af9f0cbd846e	03b62107-913a-4a84-9e12-2781603405a3	e262d280-b97e-4087-8e78-a66519bae4d1	پیشرفت اولیه و بررسی نیازمندی‌ها	56	100	2026-07-16	approved	e262d280-b97e-4087-8e78-a66519bae4d1	\N	5c9a692e-76a2-4151-8af2-f14e97e49a21	2026-07-21 18:35:18.932907+00	2026-07-21 18:35:18.932907+00
efb263c4-05b2-42d2-bc77-af9f0cbd846e	968d800b-6e71-47aa-8117-1055ba4b3d11	c288bac5-e3a4-4f1f-a050-de12845acf11	پیاده‌سازی بخش اصلی	194	24	2026-06-26	approved	e262d280-b97e-4087-8e78-a66519bae4d1	\N	17c093c5-aa14-4444-8254-2a6dc21e6e82	2026-07-21 18:35:18.932907+00	2026-07-21 18:35:18.932907+00
efb263c4-05b2-42d2-bc77-af9f0cbd846e	968d800b-6e71-47aa-8117-1055ba4b3d11	c288bac5-e3a4-4f1f-a050-de12845acf11	پیشرفت اولیه و بررسی نیازمندی‌ها	186	80	2026-06-27	approved	e262d280-b97e-4087-8e78-a66519bae4d1	\N	ca1759ef-5e53-4cfc-93c9-8705f0ace53c	2026-07-21 18:35:18.932907+00	2026-07-21 18:35:18.932907+00
efb263c4-05b2-42d2-bc77-af9f0cbd846e	968d800b-6e71-47aa-8117-1055ba4b3d11	c288bac5-e3a4-4f1f-a050-de12845acf11	پیاده‌سازی بخش اصلی	190	72	2026-06-30	approved	e262d280-b97e-4087-8e78-a66519bae4d1	\N	1039fa46-87cc-4495-a996-24937a38241e	2026-07-21 18:35:18.932907+00	2026-07-21 18:35:18.932907+00
efb263c4-05b2-42d2-bc77-af9f0cbd846e	e30b7dab-fa94-41fb-96c8-501d1c828ae2	1c37102f-d8b4-4bea-bd82-5b862cd46e2b	پیشرفت اولیه و بررسی نیازمندی‌ها	55	24	2026-07-09	submitted	\N	\N	de21a6f8-6667-4ce7-926c-034adc480435	2026-07-21 18:35:18.932907+00	2026-07-21 18:35:18.932907+00
efb263c4-05b2-42d2-bc77-af9f0cbd846e	e30b7dab-fa94-41fb-96c8-501d1c828ae2	1c37102f-d8b4-4bea-bd82-5b862cd46e2b	تست و اطمینان از عملکرد صحیح	119	66	2026-07-10	approved	e262d280-b97e-4087-8e78-a66519bae4d1	\N	1e4c468e-efcc-4843-8d43-1d55ab11a9b5	2026-07-21 18:35:18.932907+00	2026-07-21 18:35:18.932907+00
efb263c4-05b2-42d2-bc77-af9f0cbd846e	e30b7dab-fa94-41fb-96c8-501d1c828ae2	1c37102f-d8b4-4bea-bd82-5b862cd46e2b	پیاده‌سازی بخش اصلی	100	100	2026-07-15	submitted	\N	\N	b39de22d-68a8-44af-a4c4-df0063348c08	2026-07-21 18:35:18.932907+00	2026-07-21 18:35:18.932907+00
efb263c4-05b2-42d2-bc77-af9f0cbd846e	e30b7dab-fa94-41fb-96c8-501d1c828ae2	1c37102f-d8b4-4bea-bd82-5b862cd46e2b	مستندسازی و نهایی‌سازی	183	100	2026-07-12	approved	e262d280-b97e-4087-8e78-a66519bae4d1	\N	2f802c7e-cd1a-4389-b13e-9abe266faba1	2026-07-21 18:35:18.932907+00	2026-07-21 18:35:18.932907+00
efb263c4-05b2-42d2-bc77-af9f0cbd846e	13715022-72ea-4b63-8300-90cf3c6717bb	c288bac5-e3a4-4f1f-a050-de12845acf11	رفع اشکالات و بازبینی	82	36	2026-07-16	approved	e262d280-b97e-4087-8e78-a66519bae4d1	\N	8a6964d3-a4c0-4d7c-9220-2da063353a37	2026-07-21 18:35:18.932907+00	2026-07-21 18:35:18.932907+00
efb263c4-05b2-42d2-bc77-af9f0cbd846e	13715022-72ea-4b63-8300-90cf3c6717bb	c288bac5-e3a4-4f1f-a050-de12845acf11	تست و اطمینان از عملکرد صحیح	105	80	2026-07-16	approved	e262d280-b97e-4087-8e78-a66519bae4d1	\N	15c755fe-d4e1-4f8d-a267-9d348e1b37e3	2026-07-21 18:35:18.932907+00	2026-07-21 18:35:18.932907+00
efb263c4-05b2-42d2-bc77-af9f0cbd846e	13715022-72ea-4b63-8300-90cf3c6717bb	c288bac5-e3a4-4f1f-a050-de12845acf11	پیاده‌سازی بخش اصلی	156	96	2026-07-16	approved	e262d280-b97e-4087-8e78-a66519bae4d1	\N	998d7832-af71-42f3-a51e-5ad957b964a2	2026-07-21 18:35:18.932907+00	2026-07-21 18:35:18.932907+00
efb263c4-05b2-42d2-bc77-af9f0cbd846e	55e7f6c9-ab93-4352-aa7d-c90ce96b6be6	faf489ef-0410-4dca-bec1-65dd2fb904ba	تست و اطمینان از عملکرد صحیح	193	39	2026-07-16	approved	e262d280-b97e-4087-8e78-a66519bae4d1	\N	184948e8-3f23-4cbf-934c-3b34339a3dc9	2026-07-21 18:35:18.932907+00	2026-07-21 18:35:18.932907+00
efb263c4-05b2-42d2-bc77-af9f0cbd846e	edfaad63-64ef-44d3-bab3-5051742ac16d	c288bac5-e3a4-4f1f-a050-de12845acf11	رفع اشکالات و بازبینی	111	24	2026-07-16	approved	e262d280-b97e-4087-8e78-a66519bae4d1	\N	7ec2edd4-d441-4b09-9346-d1a6a3e0b13d	2026-07-21 18:35:18.932907+00	2026-07-21 18:35:18.932907+00
efb263c4-05b2-42d2-bc77-af9f0cbd846e	1ec5d985-c518-4e2e-ba2d-07978f8ed220	c288bac5-e3a4-4f1f-a050-de12845acf11	پیاده‌سازی بخش اصلی	225	35	2026-07-16	approved	e262d280-b97e-4087-8e78-a66519bae4d1	\N	09cd0784-2e28-4103-b9b0-30a29397b993	2026-07-21 18:35:18.932907+00	2026-07-21 18:35:18.932907+00
efb263c4-05b2-42d2-bc77-af9f0cbd846e	1ec5d985-c518-4e2e-ba2d-07978f8ed220	c288bac5-e3a4-4f1f-a050-de12845acf11	پیشرفت اولیه و بررسی نیازمندی‌ها	33	56	2026-07-16	approved	e262d280-b97e-4087-8e78-a66519bae4d1	\N	2d1a6e49-94d7-4663-b0b5-a6c081be7a24	2026-07-21 18:35:18.932907+00	2026-07-21 18:35:18.932907+00
efb263c4-05b2-42d2-bc77-af9f0cbd846e	1ec5d985-c518-4e2e-ba2d-07978f8ed220	c288bac5-e3a4-4f1f-a050-de12845acf11	پیشرفت اولیه و بررسی نیازمندی‌ها	232	96	2026-07-16	approved	e262d280-b97e-4087-8e78-a66519bae4d1	\N	6b3c224e-3d51-4e8a-8b3b-d0bf360b7d10	2026-07-21 18:35:18.932907+00	2026-07-21 18:35:18.932907+00
efb263c4-05b2-42d2-bc77-af9f0cbd846e	1ec5d985-c518-4e2e-ba2d-07978f8ed220	c288bac5-e3a4-4f1f-a050-de12845acf11	مستندسازی و نهایی‌سازی	226	100	2026-07-16	approved	e262d280-b97e-4087-8e78-a66519bae4d1	\N	395cf3f5-6154-4c79-b56e-a463ff569551	2026-07-21 18:35:18.932907+00	2026-07-21 18:35:18.932907+00
efb263c4-05b2-42d2-bc77-af9f0cbd846e	d47b8fd7-706a-4a6c-af44-72409f357990	c288bac5-e3a4-4f1f-a050-de12845acf11	مستندسازی و نهایی‌سازی	167	39	2026-07-16	approved	e262d280-b97e-4087-8e78-a66519bae4d1	\N	4440a286-9b38-4343-83ee-0c40b7506b3c	2026-07-21 18:35:18.932907+00	2026-07-21 18:35:18.932907+00
efb263c4-05b2-42d2-bc77-af9f0cbd846e	d47b8fd7-706a-4a6c-af44-72409f357990	c288bac5-e3a4-4f1f-a050-de12845acf11	رفع اشکالات و بازبینی	50	72	2026-07-16	approved	e262d280-b97e-4087-8e78-a66519bae4d1	\N	6f23622a-ff52-4806-8796-e95cdb8776b0	2026-07-21 18:35:18.932907+00	2026-07-21 18:35:18.932907+00
efb263c4-05b2-42d2-bc77-af9f0cbd846e	d47b8fd7-706a-4a6c-af44-72409f357990	c288bac5-e3a4-4f1f-a050-de12845acf11	پیاده‌سازی بخش اصلی	167	90	2026-07-16	submitted	\N	\N	e654bca3-5fa0-43c1-b82a-5f2ffd8970b1	2026-07-21 18:35:18.932907+00	2026-07-21 18:35:18.932907+00
efb263c4-05b2-42d2-bc77-af9f0cbd846e	d47b8fd7-706a-4a6c-af44-72409f357990	c288bac5-e3a4-4f1f-a050-de12845acf11	پیشرفت اولیه و بررسی نیازمندی‌ها	109	100	2026-07-16	approved	e262d280-b97e-4087-8e78-a66519bae4d1	\N	370bf60e-bf4e-45c8-8de7-9b5dbfca1da0	2026-07-21 18:35:18.932907+00	2026-07-21 18:35:18.932907+00
efb263c4-05b2-42d2-bc77-af9f0cbd846e	8ca10d05-0530-41a2-8542-a11f8e7907d2	c288bac5-e3a4-4f1f-a050-de12845acf11	پیاده‌سازی بخش اصلی	52	33	2026-07-16	approved	e262d280-b97e-4087-8e78-a66519bae4d1	\N	4be38602-4d82-4a1c-94a3-85f35239b3df	2026-07-21 18:35:18.932907+00	2026-07-21 18:35:18.932907+00
efb263c4-05b2-42d2-bc77-af9f0cbd846e	8ca10d05-0530-41a2-8542-a11f8e7907d2	c288bac5-e3a4-4f1f-a050-de12845acf11	تست و اطمینان از عملکرد صحیح	186	78	2026-07-16	approved	e262d280-b97e-4087-8e78-a66519bae4d1	\N	663c3591-1f4c-40ac-924e-bf6910c52cf2	2026-07-21 18:35:18.932907+00	2026-07-21 18:35:18.932907+00
efb263c4-05b2-42d2-bc77-af9f0cbd846e	d2141cf0-81bf-4684-aff7-19f7c886fbd5	1c37102f-d8b4-4bea-bd82-5b862cd46e2b	پیاده‌سازی بخش اصلی	60	20	2026-07-16	approved	e262d280-b97e-4087-8e78-a66519bae4d1	\N	9d6b2cf1-2b1e-4dbd-b9dc-3b9972c48e23	2026-07-21 18:35:18.932907+00	2026-07-21 18:35:18.932907+00
efb263c4-05b2-42d2-bc77-af9f0cbd846e	544f4a3f-f4bd-47fc-9547-08406cfdfced	c288bac5-e3a4-4f1f-a050-de12845acf11	پیاده‌سازی بخش اصلی	157	31	2026-06-30	approved	e262d280-b97e-4087-8e78-a66519bae4d1	\N	55abff3e-0183-46ae-ac0f-da300d418e93	2026-07-21 18:35:18.932907+00	2026-07-21 18:35:18.932907+00
efb263c4-05b2-42d2-bc77-af9f0cbd846e	544f4a3f-f4bd-47fc-9547-08406cfdfced	c288bac5-e3a4-4f1f-a050-de12845acf11	پیاده‌سازی بخش اصلی	125	48	2026-07-03	approved	e262d280-b97e-4087-8e78-a66519bae4d1	\N	fb8b1e19-6203-4ffd-90d7-66a45038f1a3	2026-07-21 18:35:18.932907+00	2026-07-21 18:35:18.932907+00
efb263c4-05b2-42d2-bc77-af9f0cbd846e	ba7c0c05-1326-4d2e-b956-58934e8b9cae	c288bac5-e3a4-4f1f-a050-de12845acf11	پیشرفت اولیه و بررسی نیازمندی‌ها	115	33	2026-07-13	approved	e262d280-b97e-4087-8e78-a66519bae4d1	\N	887fd2cd-b39f-463a-a2e8-3c12a8358a4c	2026-07-21 18:35:18.932907+00	2026-07-21 18:35:18.932907+00
efb263c4-05b2-42d2-bc77-af9f0cbd846e	ba7c0c05-1326-4d2e-b956-58934e8b9cae	c288bac5-e3a4-4f1f-a050-de12845acf11	مستندسازی و نهایی‌سازی	46	56	2026-07-16	approved	e262d280-b97e-4087-8e78-a66519bae4d1	\N	19917e87-a39d-4df6-9c76-9c0d8371c861	2026-07-21 18:35:18.932907+00	2026-07-21 18:35:18.932907+00
efb263c4-05b2-42d2-bc77-af9f0cbd846e	ba7c0c05-1326-4d2e-b956-58934e8b9cae	c288bac5-e3a4-4f1f-a050-de12845acf11	تست و اطمینان از عملکرد صحیح	146	100	2026-07-15	approved	e262d280-b97e-4087-8e78-a66519bae4d1	\N	b9c7459e-763c-4cb8-ad93-99efdd892030	2026-07-21 18:35:18.932907+00	2026-07-21 18:35:18.932907+00
efb263c4-05b2-42d2-bc77-af9f0cbd846e	70999110-8650-4a8c-b996-d7a8f0409f66	1c37102f-d8b4-4bea-bd82-5b862cd46e2b	مستندسازی و نهایی‌سازی	72	31	2026-07-16	approved	e262d280-b97e-4087-8e78-a66519bae4d1	\N	0e245c50-cea6-449c-8055-ad9e1508f28c	2026-07-21 18:35:18.932907+00	2026-07-21 18:35:18.932907+00
efb263c4-05b2-42d2-bc77-af9f0cbd846e	70999110-8650-4a8c-b996-d7a8f0409f66	1c37102f-d8b4-4bea-bd82-5b862cd46e2b	پیشرفت اولیه و بررسی نیازمندی‌ها	176	46	2026-07-16	approved	e262d280-b97e-4087-8e78-a66519bae4d1	\N	9770ae32-5694-4916-bb22-e473b823998d	2026-07-21 18:35:18.932907+00	2026-07-21 18:35:18.932907+00
efb263c4-05b2-42d2-bc77-af9f0cbd846e	70999110-8650-4a8c-b996-d7a8f0409f66	1c37102f-d8b4-4bea-bd82-5b862cd46e2b	پیشرفت اولیه و بررسی نیازمندی‌ها	41	60	2026-07-16	submitted	\N	\N	f2214717-2459-4fa2-a0ad-d4af972887be	2026-07-21 18:35:18.932907+00	2026-07-21 18:35:18.932907+00
efb263c4-05b2-42d2-bc77-af9f0cbd846e	467bd0e9-6bf1-4ed3-8cc4-2bf94a39139a	e262d280-b97e-4087-8e78-a66519bae4d1	تست و اطمینان از عملکرد صحیح	123	32	2026-07-16	approved	e262d280-b97e-4087-8e78-a66519bae4d1	\N	8627d88c-bb0c-48ba-ad11-4cf2f765c1ad	2026-07-21 18:35:18.932907+00	2026-07-21 18:35:18.932907+00
efb263c4-05b2-42d2-bc77-af9f0cbd846e	467bd0e9-6bf1-4ed3-8cc4-2bf94a39139a	e262d280-b97e-4087-8e78-a66519bae4d1	پیاده‌سازی بخش اصلی	39	74	2026-07-16	approved	e262d280-b97e-4087-8e78-a66519bae4d1	\N	6316944f-bb8f-4278-86b2-6c07c9bddc20	2026-07-21 18:35:18.932907+00	2026-07-21 18:35:18.932907+00
efb263c4-05b2-42d2-bc77-af9f0cbd846e	d97aa84e-a1fc-4ad4-8985-6fa18bc40e94	c288bac5-e3a4-4f1f-a050-de12845acf11	تست و اطمینان از عملکرد صحیح	214	30	2026-07-16	approved	e262d280-b97e-4087-8e78-a66519bae4d1	\N	7ae1d2b6-7316-4aff-bea6-f5919e161817	2026-07-21 18:35:18.932907+00	2026-07-21 18:35:18.932907+00
efb263c4-05b2-42d2-bc77-af9f0cbd846e	d97aa84e-a1fc-4ad4-8985-6fa18bc40e94	c288bac5-e3a4-4f1f-a050-de12845acf11	مستندسازی و نهایی‌سازی	125	46	2026-07-16	submitted	\N	\N	99ce85cc-1ab2-4332-b203-879fb3841da2	2026-07-21 18:35:18.932907+00	2026-07-21 18:35:18.932907+00
efb263c4-05b2-42d2-bc77-af9f0cbd846e	d97aa84e-a1fc-4ad4-8985-6fa18bc40e94	c288bac5-e3a4-4f1f-a050-de12845acf11	مستندسازی و نهایی‌سازی	41	96	2026-07-16	approved	e262d280-b97e-4087-8e78-a66519bae4d1	\N	1fa4eb8c-814b-4dad-9968-206d0d67b518	2026-07-21 18:35:18.932907+00	2026-07-21 18:35:18.932907+00
efb263c4-05b2-42d2-bc77-af9f0cbd846e	d97aa84e-a1fc-4ad4-8985-6fa18bc40e94	c288bac5-e3a4-4f1f-a050-de12845acf11	رفع اشکالات و بازبینی	228	100	2026-07-16	submitted	\N	\N	44a4ea48-7f70-4353-90b4-da4f56ec3e79	2026-07-21 18:35:18.932907+00	2026-07-21 18:35:18.932907+00
efb263c4-05b2-42d2-bc77-af9f0cbd846e	faea8981-516d-4c7b-9150-42ff706a58c8	e73ec14e-ca0c-4615-92d5-5bc43c14999a	پیشرفت اولیه و بررسی نیازمندی‌ها	124	26	2026-07-16	approved	e262d280-b97e-4087-8e78-a66519bae4d1	\N	a32bd8da-d078-4ea5-931d-17f7f3a766e5	2026-07-21 18:35:18.932907+00	2026-07-21 18:35:18.932907+00
efb263c4-05b2-42d2-bc77-af9f0cbd846e	faea8981-516d-4c7b-9150-42ff706a58c8	e73ec14e-ca0c-4615-92d5-5bc43c14999a	رفع اشکالات و بازبینی	219	78	2026-07-16	approved	e262d280-b97e-4087-8e78-a66519bae4d1	\N	fd4d838c-00a4-4bf9-a507-bc12001e1a2d	2026-07-21 18:35:18.932907+00	2026-07-21 18:35:18.932907+00
efb263c4-05b2-42d2-bc77-af9f0cbd846e	faea8981-516d-4c7b-9150-42ff706a58c8	e73ec14e-ca0c-4615-92d5-5bc43c14999a	مستندسازی و نهایی‌سازی	156	78	2026-07-16	approved	e262d280-b97e-4087-8e78-a66519bae4d1	\N	5db9dcfd-7651-44a3-bbc9-7f5a5821ba40	2026-07-21 18:35:18.932907+00	2026-07-21 18:35:18.932907+00
efb263c4-05b2-42d2-bc77-af9f0cbd846e	ed644312-db89-439e-b70b-9a22a4c6364c	faf489ef-0410-4dca-bec1-65dd2fb904ba	تست و اطمینان از عملکرد صحیح	36	27	2026-07-01	approved	e262d280-b97e-4087-8e78-a66519bae4d1	\N	549e00a7-1553-4d68-afc2-4493a7fed6c5	2026-07-21 18:35:18.932907+00	2026-07-21 18:35:18.932907+00
efb263c4-05b2-42d2-bc77-af9f0cbd846e	ed644312-db89-439e-b70b-9a22a4c6364c	faf489ef-0410-4dca-bec1-65dd2fb904ba	پیشرفت اولیه و بررسی نیازمندی‌ها	115	40	2026-07-04	approved	e262d280-b97e-4087-8e78-a66519bae4d1	\N	c53f228d-74d8-4f0f-b428-8551c9c74b9a	2026-07-21 18:35:18.932907+00	2026-07-21 18:35:18.932907+00
efb263c4-05b2-42d2-bc77-af9f0cbd846e	32091cbb-b9a5-4dc9-ba32-a5d7bf51216b	e73ec14e-ca0c-4615-92d5-5bc43c14999a	مستندسازی و نهایی‌سازی	90	33	2026-06-19	approved	e262d280-b97e-4087-8e78-a66519bae4d1	\N	8dd66211-3854-4225-bc30-03253126b8a9	2026-07-21 18:35:18.932907+00	2026-07-21 18:35:18.932907+00
efb263c4-05b2-42d2-bc77-af9f0cbd846e	32091cbb-b9a5-4dc9-ba32-a5d7bf51216b	e73ec14e-ca0c-4615-92d5-5bc43c14999a	پیاده‌سازی بخش اصلی	212	56	2026-06-23	submitted	\N	\N	9f3005e2-ad78-4610-9ffe-5aa47caf42c6	2026-07-21 18:35:18.932907+00	2026-07-21 18:35:18.932907+00
efb263c4-05b2-42d2-bc77-af9f0cbd846e	32091cbb-b9a5-4dc9-ba32-a5d7bf51216b	e73ec14e-ca0c-4615-92d5-5bc43c14999a	پیاده‌سازی بخش اصلی	163	99	2026-06-21	approved	e262d280-b97e-4087-8e78-a66519bae4d1	\N	74808c07-06c0-41d3-a843-ecdc4099408c	2026-07-21 18:35:18.932907+00	2026-07-21 18:35:18.932907+00
efb263c4-05b2-42d2-bc77-af9f0cbd846e	32091cbb-b9a5-4dc9-ba32-a5d7bf51216b	e73ec14e-ca0c-4615-92d5-5bc43c14999a	پیشرفت اولیه و بررسی نیازمندی‌ها	178	92	2026-06-28	approved	e262d280-b97e-4087-8e78-a66519bae4d1	\N	a14e9df8-7788-4094-97bc-1a3d5b18ce36	2026-07-21 18:35:18.932907+00	2026-07-21 18:35:18.932907+00
efb263c4-05b2-42d2-bc77-af9f0cbd846e	468e8ffd-1f2a-494e-91cb-3f36317389c8	c288bac5-e3a4-4f1f-a050-de12845acf11	پیشرفت اولیه و بررسی نیازمندی‌ها	181	38	2026-07-08	approved	e262d280-b97e-4087-8e78-a66519bae4d1	\N	4275b8af-9cc2-4da8-980b-7f4e1a3f839d	2026-07-21 18:35:18.932907+00	2026-07-21 18:35:18.932907+00
efb263c4-05b2-42d2-bc77-af9f0cbd846e	468e8ffd-1f2a-494e-91cb-3f36317389c8	c288bac5-e3a4-4f1f-a050-de12845acf11	تست و اطمینان از عملکرد صحیح	199	48	2026-07-09	approved	e262d280-b97e-4087-8e78-a66519bae4d1	\N	a824df37-b81d-4da4-bf48-7cd3bf50e77f	2026-07-21 18:35:18.932907+00	2026-07-21 18:35:18.932907+00
efb263c4-05b2-42d2-bc77-af9f0cbd846e	2d552189-1da8-426f-b59c-7720020591db	c288bac5-e3a4-4f1f-a050-de12845acf11	رفع اشکالات و بازبینی	235	32	2026-06-25	approved	e262d280-b97e-4087-8e78-a66519bae4d1	\N	33da6070-69fd-4a35-baf2-67fb9c743fe7	2026-07-21 18:35:18.932907+00	2026-07-21 18:35:18.932907+00
efb263c4-05b2-42d2-bc77-af9f0cbd846e	2d552189-1da8-426f-b59c-7720020591db	c288bac5-e3a4-4f1f-a050-de12845acf11	رفع اشکالات و بازبینی	89	44	2026-06-28	approved	e262d280-b97e-4087-8e78-a66519bae4d1	\N	07b3cdee-19e5-440d-8e91-6810c4d031ad	2026-07-21 18:35:18.932907+00	2026-07-21 18:35:18.932907+00
efb263c4-05b2-42d2-bc77-af9f0cbd846e	c5ca0f17-9de8-4302-b3aa-8d4fe30f442e	faf489ef-0410-4dca-bec1-65dd2fb904ba	مستندسازی و نهایی‌سازی	57	24	2026-07-05	submitted	\N	\N	8763fabb-bc10-44eb-9750-2d9ab198ea8e	2026-07-21 18:35:18.932907+00	2026-07-21 18:35:18.932907+00
efb263c4-05b2-42d2-bc77-af9f0cbd846e	c5ca0f17-9de8-4302-b3aa-8d4fe30f442e	faf489ef-0410-4dca-bec1-65dd2fb904ba	تست و اطمینان از عملکرد صحیح	110	66	2026-07-06	approved	e262d280-b97e-4087-8e78-a66519bae4d1	\N	b0d78a50-5735-4bd2-8048-c89645238edd	2026-07-21 18:35:18.932907+00	2026-07-21 18:35:18.932907+00
efb263c4-05b2-42d2-bc77-af9f0cbd846e	907b0366-6731-4c71-8179-2a14e2c2c863	c288bac5-e3a4-4f1f-a050-de12845acf11	پیاده‌سازی بخش اصلی	145	29	2026-07-10	approved	e262d280-b97e-4087-8e78-a66519bae4d1	\N	dab47b23-0060-4d95-9d4f-0d500b93fb63	2026-07-21 18:35:18.932907+00	2026-07-21 18:35:18.932907+00
efb263c4-05b2-42d2-bc77-af9f0cbd846e	b7203177-a7c2-4bd2-821b-6ba5d58d5a96	e262d280-b97e-4087-8e78-a66519bae4d1	پیشرفت اولیه و بررسی نیازمندی‌ها	53	25	2026-06-21	approved	e262d280-b97e-4087-8e78-a66519bae4d1	\N	7e0a3533-3f10-436e-9691-b60090f297ff	2026-07-21 18:35:18.932907+00	2026-07-21 18:35:18.932907+00
efb263c4-05b2-42d2-bc77-af9f0cbd846e	b7203177-a7c2-4bd2-821b-6ba5d58d5a96	e262d280-b97e-4087-8e78-a66519bae4d1	مستندسازی و نهایی‌سازی	40	52	2026-06-24	approved	e262d280-b97e-4087-8e78-a66519bae4d1	\N	4052813e-f755-4904-97d4-1d27985d3748	2026-07-21 18:35:18.932907+00	2026-07-21 18:35:18.932907+00
efb263c4-05b2-42d2-bc77-af9f0cbd846e	b7203177-a7c2-4bd2-821b-6ba5d58d5a96	e262d280-b97e-4087-8e78-a66519bae4d1	پیاده‌سازی بخش اصلی	53	81	2026-06-27	approved	e262d280-b97e-4087-8e78-a66519bae4d1	\N	6f4d8a86-582d-45e4-a238-27b5dceba3a9	2026-07-21 18:35:18.932907+00	2026-07-21 18:35:18.932907+00
efb263c4-05b2-42d2-bc77-af9f0cbd846e	b7203177-a7c2-4bd2-821b-6ba5d58d5a96	e262d280-b97e-4087-8e78-a66519bae4d1	تست و اطمینان از عملکرد صحیح	161	84	2026-06-30	approved	e262d280-b97e-4087-8e78-a66519bae4d1	\N	e9ff1c09-9270-4470-9254-86a2f95a10bc	2026-07-21 18:35:18.932907+00	2026-07-21 18:35:18.932907+00
efb263c4-05b2-42d2-bc77-af9f0cbd846e	107f6541-f82e-4f29-8be2-5e624ce04d16	c288bac5-e3a4-4f1f-a050-de12845acf11	پیاده‌سازی بخش اصلی	37	32	2026-06-18	approved	e262d280-b97e-4087-8e78-a66519bae4d1	\N	02cd5ecf-8ff3-444a-a7f5-3f1639b99856	2026-07-21 18:35:18.932907+00	2026-07-21 18:35:18.932907+00
efb263c4-05b2-42d2-bc77-af9f0cbd846e	107f6541-f82e-4f29-8be2-5e624ce04d16	c288bac5-e3a4-4f1f-a050-de12845acf11	مستندسازی و نهایی‌سازی	221	74	2026-06-22	approved	e262d280-b97e-4087-8e78-a66519bae4d1	\N	90408151-4932-4eeb-aec8-449b14f6f3d4	2026-07-21 18:35:18.932907+00	2026-07-21 18:35:18.932907+00
efb263c4-05b2-42d2-bc77-af9f0cbd846e	107f6541-f82e-4f29-8be2-5e624ce04d16	c288bac5-e3a4-4f1f-a050-de12845acf11	پیشرفت اولیه و بررسی نیازمندی‌ها	148	69	2026-06-22	approved	e262d280-b97e-4087-8e78-a66519bae4d1	\N	173410f8-6ea5-4b96-bbe6-bc99619576e1	2026-07-21 18:35:18.932907+00	2026-07-21 18:35:18.932907+00
efb263c4-05b2-42d2-bc77-af9f0cbd846e	21726a7c-90e3-4517-834e-4d7e1eb13abb	1d9f738d-866c-4e32-9fe8-b80f0b30a62b	پیاده‌سازی بخش اصلی	63	26	2026-07-16	approved	e262d280-b97e-4087-8e78-a66519bae4d1	\N	b5b125e5-1740-43e7-9f5d-7a6991f08940	2026-07-21 18:35:18.932907+00	2026-07-21 18:35:18.932907+00
efb263c4-05b2-42d2-bc77-af9f0cbd846e	21726a7c-90e3-4517-834e-4d7e1eb13abb	1d9f738d-866c-4e32-9fe8-b80f0b30a62b	پیشرفت اولیه و بررسی نیازمندی‌ها	179	76	2026-07-16	approved	e262d280-b97e-4087-8e78-a66519bae4d1	\N	b6932808-2e10-444f-af6d-f87378763946	2026-07-21 18:35:18.932907+00	2026-07-21 18:35:18.932907+00
efb263c4-05b2-42d2-bc77-af9f0cbd846e	f7374ca9-2a7e-454b-a979-dc35709b5e48	e262d280-b97e-4087-8e78-a66519bae4d1	پیشرفت اولیه و بررسی نیازمندی‌ها	80	40	2026-07-16	approved	e262d280-b97e-4087-8e78-a66519bae4d1	\N	63c2eff8-bbdf-4abb-8f5c-7a1db761a104	2026-07-21 18:35:18.932907+00	2026-07-21 18:35:18.932907+00
efb263c4-05b2-42d2-bc77-af9f0cbd846e	f7374ca9-2a7e-454b-a979-dc35709b5e48	e262d280-b97e-4087-8e78-a66519bae4d1	پیشرفت اولیه و بررسی نیازمندی‌ها	237	60	2026-07-16	submitted	\N	\N	6420a3e4-df26-45bf-9699-d45c73c2ec92	2026-07-21 18:35:18.932907+00	2026-07-21 18:35:18.932907+00
efb263c4-05b2-42d2-bc77-af9f0cbd846e	f7374ca9-2a7e-454b-a979-dc35709b5e48	e262d280-b97e-4087-8e78-a66519bae4d1	تست و اطمینان از عملکرد صحیح	42	75	2026-07-16	approved	e262d280-b97e-4087-8e78-a66519bae4d1	\N	a5f312ff-dce9-4ff6-bb3c-696874b491c3	2026-07-21 18:35:18.932907+00	2026-07-21 18:35:18.932907+00
efb263c4-05b2-42d2-bc77-af9f0cbd846e	871b54fe-a37f-4e8d-8c51-398c4f3d5206	1c37102f-d8b4-4bea-bd82-5b862cd46e2b	تست و اطمینان از عملکرد صحیح	37	32	2026-07-11	approved	e262d280-b97e-4087-8e78-a66519bae4d1	\N	e1eb9183-9449-465f-93e4-e8a57ef957d1	2026-07-21 18:35:18.932907+00	2026-07-21 18:35:18.932907+00
efb263c4-05b2-42d2-bc77-af9f0cbd846e	871b54fe-a37f-4e8d-8c51-398c4f3d5206	1c37102f-d8b4-4bea-bd82-5b862cd46e2b	پیاده‌سازی بخش اصلی	120	52	2026-07-15	approved	e262d280-b97e-4087-8e78-a66519bae4d1	\N	e62cc015-b13e-4560-856d-7f0609348bee	2026-07-21 18:35:18.932907+00	2026-07-21 18:35:18.932907+00
efb263c4-05b2-42d2-bc77-af9f0cbd846e	871b54fe-a37f-4e8d-8c51-398c4f3d5206	1c37102f-d8b4-4bea-bd82-5b862cd46e2b	رفع اشکالات و بازبینی	101	100	2026-07-15	approved	e262d280-b97e-4087-8e78-a66519bae4d1	\N	ca2f7d16-d67f-440d-9d24-3a69e202f9fd	2026-07-21 18:35:18.932907+00	2026-07-21 18:35:18.932907+00
efb263c4-05b2-42d2-bc77-af9f0cbd846e	871b54fe-a37f-4e8d-8c51-398c4f3d5206	1c37102f-d8b4-4bea-bd82-5b862cd46e2b	پیشرفت اولیه و بررسی نیازمندی‌ها	187	100	2026-07-16	approved	e262d280-b97e-4087-8e78-a66519bae4d1	\N	02cd3de4-59ab-42dc-a3be-36c6ad38d59d	2026-07-21 18:35:18.932907+00	2026-07-21 18:35:18.932907+00
efb263c4-05b2-42d2-bc77-af9f0cbd846e	5907d363-cd92-4ba6-be90-26658facfb10	89f48814-745b-462e-820c-aff4124c3949	رفع اشکالات و بازبینی	43	27	2026-07-16	submitted	\N	\N	b5e78135-7a54-4d7f-be4b-787b61cc8aa2	2026-07-21 18:35:18.932907+00	2026-07-21 18:35:18.932907+00
efb263c4-05b2-42d2-bc77-af9f0cbd846e	5907d363-cd92-4ba6-be90-26658facfb10	89f48814-745b-462e-820c-aff4124c3949	مستندسازی و نهایی‌سازی	183	70	2026-07-16	approved	89f48814-745b-462e-820c-aff4124c3949	\N	78d41e1c-8978-4748-99fb-8cf9e54c8842	2026-07-21 18:35:18.932907+00	2026-07-21 18:35:18.932907+00
efb263c4-05b2-42d2-bc77-af9f0cbd846e	995bc8fb-cd08-49cf-b653-14ee6e9e976f	63d308ce-8593-4f45-8c4b-1df63a00732c	پیشرفت اولیه و بررسی نیازمندی‌ها	54	27	2026-07-16	approved	89f48814-745b-462e-820c-aff4124c3949	\N	8d1e4663-bce8-4f70-a4fa-90499b291089	2026-07-21 18:35:18.932907+00	2026-07-21 18:35:18.932907+00
efb263c4-05b2-42d2-bc77-af9f0cbd846e	995bc8fb-cd08-49cf-b653-14ee6e9e976f	63d308ce-8593-4f45-8c4b-1df63a00732c	رفع اشکالات و بازبینی	120	80	2026-07-16	approved	89f48814-745b-462e-820c-aff4124c3949	\N	90ec6dea-7ea1-418f-8088-4a9506bb0fc7	2026-07-21 18:35:18.932907+00	2026-07-21 18:35:18.932907+00
efb263c4-05b2-42d2-bc77-af9f0cbd846e	995bc8fb-cd08-49cf-b653-14ee6e9e976f	63d308ce-8593-4f45-8c4b-1df63a00732c	مستندسازی و نهایی‌سازی	163	93	2026-07-16	approved	89f48814-745b-462e-820c-aff4124c3949	\N	df58c403-9fd5-44a2-bd17-5f90ce7c1f8d	2026-07-21 18:35:18.932907+00	2026-07-21 18:35:18.932907+00
efb263c4-05b2-42d2-bc77-af9f0cbd846e	71084f62-63bc-46bc-86b6-0faaba87417d	d9facd7e-b4bd-497f-9f4f-f75e6a932da0	پیاده‌سازی بخش اصلی	156	24	2026-07-16	approved	89f48814-745b-462e-820c-aff4124c3949	\N	5163b5dd-ef1c-40c5-b17f-f7d20f50ece1	2026-07-21 18:35:18.932907+00	2026-07-21 18:35:18.932907+00
efb263c4-05b2-42d2-bc77-af9f0cbd846e	2d1419cb-98de-4a01-a7ab-6b9ad702a1d5	e38a8fbd-4c9d-4475-ae1b-150a034a6936	رفع اشکالات و بازبینی	186	26	2026-07-07	approved	89f48814-745b-462e-820c-aff4124c3949	\N	aa9d3565-b84e-4bf0-a6f0-34bbcbcaa823	2026-07-21 18:35:18.932907+00	2026-07-21 18:35:18.932907+00
efb263c4-05b2-42d2-bc77-af9f0cbd846e	2d1419cb-98de-4a01-a7ab-6b9ad702a1d5	e38a8fbd-4c9d-4475-ae1b-150a034a6936	پیشرفت اولیه و بررسی نیازمندی‌ها	130	52	2026-07-09	approved	89f48814-745b-462e-820c-aff4124c3949	\N	9eddd619-bd10-4e9f-bc08-69b5cffc86a7	2026-07-21 18:35:18.932907+00	2026-07-21 18:35:18.932907+00
efb263c4-05b2-42d2-bc77-af9f0cbd846e	2d1419cb-98de-4a01-a7ab-6b9ad702a1d5	e38a8fbd-4c9d-4475-ae1b-150a034a6936	پیاده‌سازی بخش اصلی	213	90	2026-07-15	approved	89f48814-745b-462e-820c-aff4124c3949	\N	6ed1c778-e058-4eda-a5fc-8dd198ac408a	2026-07-21 18:35:18.932907+00	2026-07-21 18:35:18.932907+00
efb263c4-05b2-42d2-bc77-af9f0cbd846e	2d1419cb-98de-4a01-a7ab-6b9ad702a1d5	e38a8fbd-4c9d-4475-ae1b-150a034a6936	تست و اطمینان از عملکرد صحیح	41	100	2026-07-10	approved	89f48814-745b-462e-820c-aff4124c3949	\N	30bb6587-a316-4a71-abf1-9fb6864590ff	2026-07-21 18:35:18.932907+00	2026-07-21 18:35:18.932907+00
efb263c4-05b2-42d2-bc77-af9f0cbd846e	94bffb01-029a-4a96-8ede-6caa9f1cf254	eb0b5b71-65c1-4694-a9d0-5b2b7aea8eae	تست و اطمینان از عملکرد صحیح	198	38	2026-07-12	approved	89f48814-745b-462e-820c-aff4124c3949	\N	2fbb743c-4b0a-4d17-8019-a802a81391c3	2026-07-21 18:35:18.932907+00	2026-07-21 18:35:18.932907+00
efb263c4-05b2-42d2-bc77-af9f0cbd846e	3adf2f30-f09e-4935-a65b-f5cb2e3c67fb	d9facd7e-b4bd-497f-9f4f-f75e6a932da0	پیشرفت اولیه و بررسی نیازمندی‌ها	165	21	2026-07-16	approved	89f48814-745b-462e-820c-aff4124c3949	\N	5ebda786-2e41-4558-a692-eecd570be683	2026-07-21 18:35:18.932907+00	2026-07-21 18:35:18.932907+00
efb263c4-05b2-42d2-bc77-af9f0cbd846e	3adf2f30-f09e-4935-a65b-f5cb2e3c67fb	d9facd7e-b4bd-497f-9f4f-f75e6a932da0	مستندسازی و نهایی‌سازی	153	72	2026-07-16	approved	89f48814-745b-462e-820c-aff4124c3949	\N	ee4f3a10-2e43-4237-8d31-4ae52affa365	2026-07-21 18:35:18.932907+00	2026-07-21 18:35:18.932907+00
efb263c4-05b2-42d2-bc77-af9f0cbd846e	4f022722-5b34-49f3-b021-fe7948e3ee41	e38a8fbd-4c9d-4475-ae1b-150a034a6936	پیاده‌سازی بخش اصلی	56	32	2026-06-26	submitted	\N	\N	a2c9f336-1d06-410c-8560-8a20f79f7f54	2026-07-21 18:35:18.932907+00	2026-07-21 18:35:18.932907+00
efb263c4-05b2-42d2-bc77-af9f0cbd846e	4f022722-5b34-49f3-b021-fe7948e3ee41	e38a8fbd-4c9d-4475-ae1b-150a034a6936	تست و اطمینان از عملکرد صحیح	137	78	2026-06-29	approved	89f48814-745b-462e-820c-aff4124c3949	\N	1c065e63-9a92-4fa9-b712-f4d40e3be576	2026-07-21 18:35:18.932907+00	2026-07-21 18:35:18.932907+00
efb263c4-05b2-42d2-bc77-af9f0cbd846e	88005a8d-c8d5-459d-809d-d77b34e9dab6	63d308ce-8593-4f45-8c4b-1df63a00732c	رفع اشکالات و بازبینی	105	34	2026-07-16	approved	89f48814-745b-462e-820c-aff4124c3949	\N	352733cf-ea4f-4550-8e8e-41d74d5a8d92	2026-07-21 18:35:18.932907+00	2026-07-21 18:35:18.932907+00
efb263c4-05b2-42d2-bc77-af9f0cbd846e	88005a8d-c8d5-459d-809d-d77b34e9dab6	63d308ce-8593-4f45-8c4b-1df63a00732c	مستندسازی و نهایی‌سازی	209	72	2026-07-16	approved	89f48814-745b-462e-820c-aff4124c3949	\N	b3411097-c01b-4867-9b02-2386f3430655	2026-07-21 18:35:18.932907+00	2026-07-21 18:35:18.932907+00
efb263c4-05b2-42d2-bc77-af9f0cbd846e	562e15f5-fe67-4cd8-bf8c-ed8b7fff0e2f	d9facd7e-b4bd-497f-9f4f-f75e6a932da0	مستندسازی و نهایی‌سازی	191	26	2026-07-01	submitted	\N	\N	864a2ac9-2d26-4a42-9e13-540b6a2e0763	2026-07-21 18:35:18.932907+00	2026-07-21 18:35:18.932907+00
efb263c4-05b2-42d2-bc77-af9f0cbd846e	562e15f5-fe67-4cd8-bf8c-ed8b7fff0e2f	d9facd7e-b4bd-497f-9f4f-f75e6a932da0	رفع اشکالات و بازبینی	205	62	2026-07-03	approved	89f48814-745b-462e-820c-aff4124c3949	\N	f4b3f519-96f3-485d-ac52-fca07e70e4b1	2026-07-21 18:35:18.932907+00	2026-07-21 18:35:18.932907+00
efb263c4-05b2-42d2-bc77-af9f0cbd846e	562e15f5-fe67-4cd8-bf8c-ed8b7fff0e2f	d9facd7e-b4bd-497f-9f4f-f75e6a932da0	پیاده‌سازی بخش اصلی	158	100	2026-07-05	submitted	\N	\N	988b5c19-ba0c-4c47-9508-7daca75e8d3a	2026-07-21 18:35:18.932907+00	2026-07-21 18:35:18.932907+00
efb263c4-05b2-42d2-bc77-af9f0cbd846e	c8635c31-1ce5-4d56-91bd-a86aa218ea8d	e38a8fbd-4c9d-4475-ae1b-150a034a6936	رفع اشکالات و بازبینی	173	35	2026-06-28	approved	89f48814-745b-462e-820c-aff4124c3949	\N	2ed84c24-3ed7-4686-ae36-51159f545633	2026-07-21 18:35:18.932907+00	2026-07-21 18:35:18.932907+00
efb263c4-05b2-42d2-bc77-af9f0cbd846e	c8635c31-1ce5-4d56-91bd-a86aa218ea8d	e38a8fbd-4c9d-4475-ae1b-150a034a6936	مستندسازی و نهایی‌سازی	103	66	2026-07-02	approved	89f48814-745b-462e-820c-aff4124c3949	\N	a45f7049-360a-4958-84f8-54695ded3423	2026-07-21 18:35:18.932907+00	2026-07-21 18:35:18.932907+00
efb263c4-05b2-42d2-bc77-af9f0cbd846e	c8635c31-1ce5-4d56-91bd-a86aa218ea8d	e38a8fbd-4c9d-4475-ae1b-150a034a6936	مستندسازی و نهایی‌سازی	57	60	2026-06-30	approved	89f48814-745b-462e-820c-aff4124c3949	\N	523f44a6-806a-4d43-9948-adac4efc9a91	2026-07-21 18:35:18.932907+00	2026-07-21 18:35:18.932907+00
efb263c4-05b2-42d2-bc77-af9f0cbd846e	a58d7d60-6128-4057-aa98-d7d5e0218d75	e38a8fbd-4c9d-4475-ae1b-150a034a6936	پیشرفت اولیه و بررسی نیازمندی‌ها	81	28	2026-06-21	approved	89f48814-745b-462e-820c-aff4124c3949	\N	03f5e5f4-2115-48e1-a515-c2e2048a937a	2026-07-21 18:35:18.932907+00	2026-07-21 18:35:18.932907+00
efb263c4-05b2-42d2-bc77-af9f0cbd846e	a58d7d60-6128-4057-aa98-d7d5e0218d75	e38a8fbd-4c9d-4475-ae1b-150a034a6936	رفع اشکالات و بازبینی	67	42	2026-06-23	submitted	\N	\N	631dfb91-5ab5-49d4-956e-2751c5919d1e	2026-07-21 18:35:18.932907+00	2026-07-21 18:35:18.932907+00
efb263c4-05b2-42d2-bc77-af9f0cbd846e	a58d7d60-6128-4057-aa98-d7d5e0218d75	e38a8fbd-4c9d-4475-ae1b-150a034a6936	مستندسازی و نهایی‌سازی	38	93	2026-06-27	approved	89f48814-745b-462e-820c-aff4124c3949	\N	e629152d-7a0f-444b-8624-9e8b30fd3bc0	2026-07-21 18:35:18.932907+00	2026-07-21 18:35:18.932907+00
efb263c4-05b2-42d2-bc77-af9f0cbd846e	a58d7d60-6128-4057-aa98-d7d5e0218d75	e38a8fbd-4c9d-4475-ae1b-150a034a6936	مستندسازی و نهایی‌سازی	87	100	2026-07-03	approved	89f48814-745b-462e-820c-aff4124c3949	\N	fed4192a-ce8a-4c12-b84b-67fde2ca8bc6	2026-07-21 18:35:18.932907+00	2026-07-21 18:35:18.932907+00
efb263c4-05b2-42d2-bc77-af9f0cbd846e	ba8fac48-6e18-4be4-a17f-83504d3d8e64	4bfc028f-1c19-4b0c-9188-9fe233b49cb4	رفع اشکالات و بازبینی	207	21	2026-07-16	approved	89f48814-745b-462e-820c-aff4124c3949	\N	469d04c8-e488-4b23-a6ca-e73922680f2f	2026-07-21 18:35:18.932907+00	2026-07-21 18:35:18.932907+00
efb263c4-05b2-42d2-bc77-af9f0cbd846e	ba8fac48-6e18-4be4-a17f-83504d3d8e64	4bfc028f-1c19-4b0c-9188-9fe233b49cb4	رفع اشکالات و بازبینی	171	42	2026-07-16	approved	89f48814-745b-462e-820c-aff4124c3949	\N	8bc1b5dd-b633-42bc-837b-08e53b50d1d8	2026-07-21 18:35:18.932907+00	2026-07-21 18:35:18.932907+00
efb263c4-05b2-42d2-bc77-af9f0cbd846e	ba8fac48-6e18-4be4-a17f-83504d3d8e64	4bfc028f-1c19-4b0c-9188-9fe233b49cb4	پیاده‌سازی بخش اصلی	188	100	2026-07-16	submitted	\N	\N	b012d238-160a-4752-9e38-ec5c4800bf6d	2026-07-21 18:35:18.932907+00	2026-07-21 18:35:18.932907+00
efb263c4-05b2-42d2-bc77-af9f0cbd846e	ba8fac48-6e18-4be4-a17f-83504d3d8e64	4bfc028f-1c19-4b0c-9188-9fe233b49cb4	رفع اشکالات و بازبینی	223	100	2026-07-16	submitted	\N	\N	c8bddf33-099b-4f8a-af47-aecd766222cb	2026-07-21 18:35:18.932907+00	2026-07-21 18:35:18.932907+00
efb263c4-05b2-42d2-bc77-af9f0cbd846e	b51c640e-81ab-4fe6-b384-0ca593c2321d	d9facd7e-b4bd-497f-9f4f-f75e6a932da0	رفع اشکالات و بازبینی	144	25	2026-07-16	approved	89f48814-745b-462e-820c-aff4124c3949	\N	4c592326-3383-4563-a7ad-a09021436e1d	2026-07-21 18:35:18.932907+00	2026-07-21 18:35:18.932907+00
efb263c4-05b2-42d2-bc77-af9f0cbd846e	b51c640e-81ab-4fe6-b384-0ca593c2321d	d9facd7e-b4bd-497f-9f4f-f75e6a932da0	پیاده‌سازی بخش اصلی	74	72	2026-07-16	approved	89f48814-745b-462e-820c-aff4124c3949	\N	bef42f5f-00cb-4a1b-82d3-e077a423d4e3	2026-07-21 18:35:18.932907+00	2026-07-21 18:35:18.932907+00
efb263c4-05b2-42d2-bc77-af9f0cbd846e	a529f544-746d-422e-acb0-a3ff2a79f3d0	eb0b5b71-65c1-4694-a9d0-5b2b7aea8eae	پیشرفت اولیه و بررسی نیازمندی‌ها	139	28	2026-07-16	approved	89f48814-745b-462e-820c-aff4124c3949	\N	39baddf2-1d44-4e18-a7ec-8614f6224c35	2026-07-21 18:35:18.932907+00	2026-07-21 18:35:18.932907+00
efb263c4-05b2-42d2-bc77-af9f0cbd846e	97e70d52-34cb-4b86-b324-b634d9d11f96	89f48814-745b-462e-820c-aff4124c3949	رفع اشکالات و بازبینی	31	30	2026-07-16	approved	89f48814-745b-462e-820c-aff4124c3949	\N	42dc3e53-5e21-4b97-8ce2-58474b04e383	2026-07-21 18:35:18.932907+00	2026-07-21 18:35:18.932907+00
efb263c4-05b2-42d2-bc77-af9f0cbd846e	97e70d52-34cb-4b86-b324-b634d9d11f96	89f48814-745b-462e-820c-aff4124c3949	پیاده‌سازی بخش اصلی	40	48	2026-07-16	submitted	\N	\N	e4fee3b5-a02f-42d6-9549-2116834f9138	2026-07-21 18:35:18.932907+00	2026-07-21 18:35:18.932907+00
efb263c4-05b2-42d2-bc77-af9f0cbd846e	97e70d52-34cb-4b86-b324-b634d9d11f96	89f48814-745b-462e-820c-aff4124c3949	مستندسازی و نهایی‌سازی	199	87	2026-07-16	approved	89f48814-745b-462e-820c-aff4124c3949	\N	386a360f-5cb6-4bc6-b258-2f4577559cfc	2026-07-21 18:35:18.932907+00	2026-07-21 18:35:18.932907+00
efb263c4-05b2-42d2-bc77-af9f0cbd846e	ca08407b-c5e9-4a35-ad6c-4be1bbdccbdd	e38a8fbd-4c9d-4475-ae1b-150a034a6936	پیشرفت اولیه و بررسی نیازمندی‌ها	230	30	2026-07-16	approved	89f48814-745b-462e-820c-aff4124c3949	\N	49181611-a12f-40ef-862e-25b29cc126de	2026-07-21 18:35:18.932907+00	2026-07-21 18:35:18.932907+00
efb263c4-05b2-42d2-bc77-af9f0cbd846e	ca08407b-c5e9-4a35-ad6c-4be1bbdccbdd	e38a8fbd-4c9d-4475-ae1b-150a034a6936	پیاده‌سازی بخش اصلی	163	44	2026-07-16	approved	89f48814-745b-462e-820c-aff4124c3949	\N	255fa8be-42e0-4f67-bee9-82d9398c4d7d	2026-07-21 18:35:18.932907+00	2026-07-21 18:35:18.932907+00
efb263c4-05b2-42d2-bc77-af9f0cbd846e	ca08407b-c5e9-4a35-ad6c-4be1bbdccbdd	e38a8fbd-4c9d-4475-ae1b-150a034a6936	تست و اطمینان از عملکرد صحیح	169	100	2026-07-16	approved	89f48814-745b-462e-820c-aff4124c3949	\N	6d47985c-15dc-4cb2-88cf-6fc2d017badc	2026-07-21 18:35:18.932907+00	2026-07-21 18:35:18.932907+00
efb263c4-05b2-42d2-bc77-af9f0cbd846e	ca08407b-c5e9-4a35-ad6c-4be1bbdccbdd	e38a8fbd-4c9d-4475-ae1b-150a034a6936	پیشرفت اولیه و بررسی نیازمندی‌ها	119	100	2026-07-16	approved	89f48814-745b-462e-820c-aff4124c3949	\N	46d629b9-20b3-421f-88fb-a32af678d541	2026-07-21 18:35:18.932907+00	2026-07-21 18:35:18.932907+00
efb263c4-05b2-42d2-bc77-af9f0cbd846e	254ef22b-654f-4b84-9d24-62206c567d89	4bfc028f-1c19-4b0c-9188-9fe233b49cb4	رفع اشکالات و بازبینی	122	29	2026-07-16	approved	89f48814-745b-462e-820c-aff4124c3949	\N	8a1e7c4a-1a4c-4e3a-8fdf-3e7efe657b42	2026-07-21 18:35:18.932907+00	2026-07-21 18:35:18.932907+00
efb263c4-05b2-42d2-bc77-af9f0cbd846e	254ef22b-654f-4b84-9d24-62206c567d89	4bfc028f-1c19-4b0c-9188-9fe233b49cb4	مستندسازی و نهایی‌سازی	165	70	2026-07-16	approved	89f48814-745b-462e-820c-aff4124c3949	\N	b2d318b0-8b2e-4348-a17b-5a97fd237f49	2026-07-21 18:35:18.932907+00	2026-07-21 18:35:18.932907+00
efb263c4-05b2-42d2-bc77-af9f0cbd846e	a7185f55-4b28-4dc3-9ac4-cdf19ef27efa	3d944638-fc96-463d-84ac-c7c861324cbe	رفع اشکالات و بازبینی	144	27	2026-06-16	approved	89f48814-745b-462e-820c-aff4124c3949	\N	50f9bf8e-5147-4b6c-981b-f0bb2c0e84a1	2026-07-21 18:35:18.932907+00	2026-07-21 18:35:18.932907+00
efb263c4-05b2-42d2-bc77-af9f0cbd846e	ca23af76-5ceb-4718-b158-14926e5a8015	89f48814-745b-462e-820c-aff4124c3949	رفع اشکالات و بازبینی	127	23	2026-06-25	approved	89f48814-745b-462e-820c-aff4124c3949	\N	9a3eb0c3-9acb-4b4e-9254-62324eb9d0c7	2026-07-21 18:35:18.932907+00	2026-07-21 18:35:18.932907+00
efb263c4-05b2-42d2-bc77-af9f0cbd846e	ca23af76-5ceb-4718-b158-14926e5a8015	89f48814-745b-462e-820c-aff4124c3949	رفع اشکالات و بازبینی	36	72	2026-06-29	approved	89f48814-745b-462e-820c-aff4124c3949	\N	4927f179-012d-426f-a9a1-fa4e6a0c400c	2026-07-21 18:35:18.932907+00	2026-07-21 18:35:18.932907+00
efb263c4-05b2-42d2-bc77-af9f0cbd846e	825dbd19-25dd-490b-8399-5dfed374e651	eb0b5b71-65c1-4694-a9d0-5b2b7aea8eae	رفع اشکالات و بازبینی	196	26	2026-07-10	approved	89f48814-745b-462e-820c-aff4124c3949	\N	6b92f120-1238-4096-a1cd-23e7874e2488	2026-07-21 18:35:18.932907+00	2026-07-21 18:35:18.932907+00
efb263c4-05b2-42d2-bc77-af9f0cbd846e	825dbd19-25dd-490b-8399-5dfed374e651	eb0b5b71-65c1-4694-a9d0-5b2b7aea8eae	پیشرفت اولیه و بررسی نیازمندی‌ها	72	74	2026-07-13	approved	89f48814-745b-462e-820c-aff4124c3949	\N	491b9767-ed87-4c4b-9cc4-921e1f428ede	2026-07-21 18:35:18.932907+00	2026-07-21 18:35:18.932907+00
efb263c4-05b2-42d2-bc77-af9f0cbd846e	825dbd19-25dd-490b-8399-5dfed374e651	eb0b5b71-65c1-4694-a9d0-5b2b7aea8eae	پیاده‌سازی بخش اصلی	201	100	2026-07-12	approved	89f48814-745b-462e-820c-aff4124c3949	\N	b964fac0-2ef6-4884-9971-31d05c030057	2026-07-21 18:35:18.932907+00	2026-07-21 18:35:18.932907+00
efb263c4-05b2-42d2-bc77-af9f0cbd846e	f3a4e93e-7446-4e20-93f5-162e2dd4f040	d9facd7e-b4bd-497f-9f4f-f75e6a932da0	پیاده‌سازی بخش اصلی	167	33	2026-06-25	submitted	\N	\N	3f8880b1-146b-4197-87ab-9ebff0417e5b	2026-07-21 18:35:18.932907+00	2026-07-21 18:35:18.932907+00
efb263c4-05b2-42d2-bc77-af9f0cbd846e	f3a4e93e-7446-4e20-93f5-162e2dd4f040	d9facd7e-b4bd-497f-9f4f-f75e6a932da0	پیاده‌سازی بخش اصلی	36	68	2026-06-26	submitted	\N	\N	684165fc-4ea6-4189-a6aa-39d798f6cf43	2026-07-21 18:35:18.932907+00	2026-07-21 18:35:18.932907+00
efb263c4-05b2-42d2-bc77-af9f0cbd846e	d25a1834-7de4-439f-9667-cf707b9a9b13	d9facd7e-b4bd-497f-9f4f-f75e6a932da0	پیشرفت اولیه و بررسی نیازمندی‌ها	48	21	2026-07-16	approved	89f48814-745b-462e-820c-aff4124c3949	\N	04bdea3c-23bd-4e56-aa4b-278d45dcc8d0	2026-07-21 18:35:18.932907+00	2026-07-21 18:35:18.932907+00
efb263c4-05b2-42d2-bc77-af9f0cbd846e	d25a1834-7de4-439f-9667-cf707b9a9b13	d9facd7e-b4bd-497f-9f4f-f75e6a932da0	رفع اشکالات و بازبینی	172	44	2026-07-16	approved	89f48814-745b-462e-820c-aff4124c3949	\N	1c956df0-7102-44e6-8b96-ce5a6e9d225a	2026-07-21 18:35:18.932907+00	2026-07-21 18:35:18.932907+00
efb263c4-05b2-42d2-bc77-af9f0cbd846e	d25a1834-7de4-439f-9667-cf707b9a9b13	d9facd7e-b4bd-497f-9f4f-f75e6a932da0	رفع اشکالات و بازبینی	134	96	2026-07-16	approved	89f48814-745b-462e-820c-aff4124c3949	\N	b73d4aca-fbaf-43cb-a483-f5010edee08a	2026-07-21 18:35:18.932907+00	2026-07-21 18:35:18.932907+00
efb263c4-05b2-42d2-bc77-af9f0cbd846e	0b395e7a-e9d2-40f2-8e75-b679a9c55541	89f48814-745b-462e-820c-aff4124c3949	پیشرفت اولیه و بررسی نیازمندی‌ها	129	23	2026-07-16	approved	89f48814-745b-462e-820c-aff4124c3949	\N	4918b91d-9066-43ca-9746-3d895160ef13	2026-07-21 18:35:18.932907+00	2026-07-21 18:35:18.932907+00
efb263c4-05b2-42d2-bc77-af9f0cbd846e	0b395e7a-e9d2-40f2-8e75-b679a9c55541	89f48814-745b-462e-820c-aff4124c3949	مستندسازی و نهایی‌سازی	46	76	2026-07-16	approved	89f48814-745b-462e-820c-aff4124c3949	\N	8475eb16-6cd7-4d96-98dd-4fab974f5946	2026-07-21 18:35:18.932907+00	2026-07-21 18:35:18.932907+00
efb263c4-05b2-42d2-bc77-af9f0cbd846e	0b395e7a-e9d2-40f2-8e75-b679a9c55541	89f48814-745b-462e-820c-aff4124c3949	پیشرفت اولیه و بررسی نیازمندی‌ها	121	100	2026-07-16	submitted	\N	\N	02fd6727-7d62-4688-b13f-bcf996fa9e9e	2026-07-21 18:35:18.932907+00	2026-07-21 18:35:18.932907+00
efb263c4-05b2-42d2-bc77-af9f0cbd846e	0b395e7a-e9d2-40f2-8e75-b679a9c55541	89f48814-745b-462e-820c-aff4124c3949	رفع اشکالات و بازبینی	185	88	2026-07-16	approved	89f48814-745b-462e-820c-aff4124c3949	\N	7053ecdc-8e5c-46e4-9bd4-19717f5c1e92	2026-07-21 18:35:18.932907+00	2026-07-21 18:35:18.932907+00
efb263c4-05b2-42d2-bc77-af9f0cbd846e	9b5f8e12-182d-4496-bdab-dab07ec918f9	d9facd7e-b4bd-497f-9f4f-f75e6a932da0	پیشرفت اولیه و بررسی نیازمندی‌ها	151	25	2026-07-16	approved	89f48814-745b-462e-820c-aff4124c3949	\N	b763c750-ed38-459d-b7be-a44c7e7087d3	2026-07-21 18:35:18.932907+00	2026-07-21 18:35:18.932907+00
efb263c4-05b2-42d2-bc77-af9f0cbd846e	9b5f8e12-182d-4496-bdab-dab07ec918f9	d9facd7e-b4bd-497f-9f4f-f75e6a932da0	تست و اطمینان از عملکرد صحیح	233	74	2026-07-16	approved	89f48814-745b-462e-820c-aff4124c3949	\N	b0946ed3-4a78-4102-b1e1-17564b331850	2026-07-21 18:35:18.932907+00	2026-07-21 18:35:18.932907+00
efb263c4-05b2-42d2-bc77-af9f0cbd846e	9b5f8e12-182d-4496-bdab-dab07ec918f9	d9facd7e-b4bd-497f-9f4f-f75e6a932da0	پیاده‌سازی بخش اصلی	106	100	2026-07-16	submitted	\N	\N	d37658fd-5117-43dc-95a1-ff38f0693b46	2026-07-21 18:35:18.932907+00	2026-07-21 18:35:18.932907+00
efb263c4-05b2-42d2-bc77-af9f0cbd846e	6f5c75a3-f807-4c42-ba79-5eac3f1c5e14	63d308ce-8593-4f45-8c4b-1df63a00732c	مستندسازی و نهایی‌سازی	66	23	2026-07-16	approved	89f48814-745b-462e-820c-aff4124c3949	\N	a39b5f7b-3bfd-4259-90e5-71776075a418	2026-07-21 18:35:18.932907+00	2026-07-21 18:35:18.932907+00
efb263c4-05b2-42d2-bc77-af9f0cbd846e	6f5c75a3-f807-4c42-ba79-5eac3f1c5e14	63d308ce-8593-4f45-8c4b-1df63a00732c	مستندسازی و نهایی‌سازی	130	74	2026-07-16	approved	89f48814-745b-462e-820c-aff4124c3949	\N	99d41af2-a27e-4fc4-9bd5-d6e667393922	2026-07-21 18:35:18.932907+00	2026-07-21 18:35:18.932907+00
efb263c4-05b2-42d2-bc77-af9f0cbd846e	6f5c75a3-f807-4c42-ba79-5eac3f1c5e14	63d308ce-8593-4f45-8c4b-1df63a00732c	رفع اشکالات و بازبینی	84	99	2026-07-16	approved	89f48814-745b-462e-820c-aff4124c3949	\N	140e8b02-3e36-4f4c-a281-4642adbcd100	2026-07-21 18:35:18.932907+00	2026-07-21 18:35:18.932907+00
efb263c4-05b2-42d2-bc77-af9f0cbd846e	4f6ea181-d2bd-4bbd-8eb7-ddf97104414c	4bfc028f-1c19-4b0c-9188-9fe233b49cb4	پیاده‌سازی بخش اصلی	86	39	2026-06-17	approved	89f48814-745b-462e-820c-aff4124c3949	\N	e6f8dbe4-72cc-48e4-bac4-f359010ad6dc	2026-07-21 18:35:18.932907+00	2026-07-21 18:35:18.932907+00
efb263c4-05b2-42d2-bc77-af9f0cbd846e	4f6ea181-d2bd-4bbd-8eb7-ddf97104414c	4bfc028f-1c19-4b0c-9188-9fe233b49cb4	پیاده‌سازی بخش اصلی	59	50	2026-06-20	approved	89f48814-745b-462e-820c-aff4124c3949	\N	b51c28af-d3b4-4dfd-9d59-6712f8c3af74	2026-07-21 18:35:18.932907+00	2026-07-21 18:35:18.932907+00
efb263c4-05b2-42d2-bc77-af9f0cbd846e	ea093497-b96a-4380-a707-8559da4ff12f	4bfc028f-1c19-4b0c-9188-9fe233b49cb4	مستندسازی و نهایی‌سازی	48	29	2026-07-16	approved	89f48814-745b-462e-820c-aff4124c3949	\N	21981a51-f10b-4237-a9ad-ce80264f0b2b	2026-07-21 18:35:18.932907+00	2026-07-21 18:35:18.932907+00
efb263c4-05b2-42d2-bc77-af9f0cbd846e	c361fa3b-4136-4a9a-ae89-33e0ce4cc9f7	eb0b5b71-65c1-4694-a9d0-5b2b7aea8eae	پیشرفت اولیه و بررسی نیازمندی‌ها	80	38	2026-07-16	approved	89f48814-745b-462e-820c-aff4124c3949	\N	2a8da154-88a7-4770-8df2-e6d83d609bac	2026-07-21 18:35:18.932907+00	2026-07-21 18:35:18.932907+00
efb263c4-05b2-42d2-bc77-af9f0cbd846e	2905a818-7c05-4dbc-88c3-1ac82d16866d	63d308ce-8593-4f45-8c4b-1df63a00732c	پیاده‌سازی بخش اصلی	55	29	2026-07-16	approved	89f48814-745b-462e-820c-aff4124c3949	\N	dbfaccb4-acab-4097-80c5-eb8afe7bbbbd	2026-07-21 18:35:18.932907+00	2026-07-21 18:35:18.932907+00
efb263c4-05b2-42d2-bc77-af9f0cbd846e	2905a818-7c05-4dbc-88c3-1ac82d16866d	63d308ce-8593-4f45-8c4b-1df63a00732c	رفع اشکالات و بازبینی	154	68	2026-07-16	submitted	\N	\N	384f897a-4c85-4054-a640-c689cde84028	2026-07-21 18:35:18.932907+00	2026-07-21 18:35:18.932907+00
efb263c4-05b2-42d2-bc77-af9f0cbd846e	2905a818-7c05-4dbc-88c3-1ac82d16866d	63d308ce-8593-4f45-8c4b-1df63a00732c	رفع اشکالات و بازبینی	207	100	2026-07-16	approved	89f48814-745b-462e-820c-aff4124c3949	\N	d8e40170-5121-41a1-898c-83c5ec7239b4	2026-07-21 18:35:18.932907+00	2026-07-21 18:35:18.932907+00
efb263c4-05b2-42d2-bc77-af9f0cbd846e	2905a818-7c05-4dbc-88c3-1ac82d16866d	63d308ce-8593-4f45-8c4b-1df63a00732c	رفع اشکالات و بازبینی	236	100	2026-07-16	approved	89f48814-745b-462e-820c-aff4124c3949	\N	843eb4a1-6848-4b89-89b7-6d92802f1490	2026-07-21 18:35:18.932907+00	2026-07-21 18:35:18.932907+00
efb263c4-05b2-42d2-bc77-af9f0cbd846e	9f17ed6d-a670-486b-93d5-4e8106cd865a	4bfc028f-1c19-4b0c-9188-9fe233b49cb4	پیشرفت اولیه و بررسی نیازمندی‌ها	110	27	2026-06-29	approved	89f48814-745b-462e-820c-aff4124c3949	\N	b81b7daf-ca7b-41cd-926b-2e701366db88	2026-07-21 18:35:18.932907+00	2026-07-21 18:35:18.932907+00
efb263c4-05b2-42d2-bc77-af9f0cbd846e	9f17ed6d-a670-486b-93d5-4e8106cd865a	4bfc028f-1c19-4b0c-9188-9fe233b49cb4	تست و اطمینان از عملکرد صحیح	100	62	2026-07-01	approved	89f48814-745b-462e-820c-aff4124c3949	\N	a54262bf-a760-4bf0-a58d-932ea8501438	2026-07-21 18:35:18.932907+00	2026-07-21 18:35:18.932907+00
efb263c4-05b2-42d2-bc77-af9f0cbd846e	9f17ed6d-a670-486b-93d5-4e8106cd865a	4bfc028f-1c19-4b0c-9188-9fe233b49cb4	رفع اشکالات و بازبینی	152	100	2026-07-03	approved	89f48814-745b-462e-820c-aff4124c3949	\N	bcd19fb5-1eba-485e-a4ad-4252e2167cdc	2026-07-21 18:35:18.932907+00	2026-07-21 18:35:18.932907+00
efb263c4-05b2-42d2-bc77-af9f0cbd846e	9f17ed6d-a670-486b-93d5-4e8106cd865a	4bfc028f-1c19-4b0c-9188-9fe233b49cb4	رفع اشکالات و بازبینی	228	100	2026-07-11	approved	89f48814-745b-462e-820c-aff4124c3949	\N	30472e2e-2eb8-4234-98d5-1266f21732e9	2026-07-21 18:35:18.932907+00	2026-07-21 18:35:18.932907+00
efb263c4-05b2-42d2-bc77-af9f0cbd846e	a0c3171e-3128-4cab-a404-534a72304fee	d9facd7e-b4bd-497f-9f4f-f75e6a932da0	پیاده‌سازی بخش اصلی	195	39	2026-06-17	approved	89f48814-745b-462e-820c-aff4124c3949	\N	15e5ddf8-b47d-4908-9094-e23b7bd92dbb	2026-07-21 18:35:18.932907+00	2026-07-21 18:35:18.932907+00
efb263c4-05b2-42d2-bc77-af9f0cbd846e	a0c3171e-3128-4cab-a404-534a72304fee	d9facd7e-b4bd-497f-9f4f-f75e6a932da0	رفع اشکالات و بازبینی	65	74	2026-06-18	approved	89f48814-745b-462e-820c-aff4124c3949	\N	27c0c380-db21-48e8-a109-33fe0fc92b40	2026-07-21 18:35:18.932907+00	2026-07-21 18:35:18.932907+00
efb263c4-05b2-42d2-bc77-af9f0cbd846e	a0c3171e-3128-4cab-a404-534a72304fee	d9facd7e-b4bd-497f-9f4f-f75e6a932da0	رفع اشکالات و بازبینی	217	100	2026-06-21	approved	89f48814-745b-462e-820c-aff4124c3949	\N	d802446b-c62b-4d94-a497-027f9dbfdae8	2026-07-21 18:35:18.932907+00	2026-07-21 18:35:18.932907+00
efb263c4-05b2-42d2-bc77-af9f0cbd846e	a0c3171e-3128-4cab-a404-534a72304fee	d9facd7e-b4bd-497f-9f4f-f75e6a932da0	پیشرفت اولیه و بررسی نیازمندی‌ها	34	100	2026-06-20	approved	89f48814-745b-462e-820c-aff4124c3949	\N	65bb71ca-45ca-45a8-9c4a-ec6b5561e019	2026-07-21 18:35:18.932907+00	2026-07-21 18:35:18.932907+00
efb263c4-05b2-42d2-bc77-af9f0cbd846e	19191629-71a7-4566-a50d-dbc903e1df37	eb0b5b71-65c1-4694-a9d0-5b2b7aea8eae	پیاده‌سازی بخش اصلی	39	37	2026-07-15	submitted	\N	\N	ba31fe06-3b4e-4de6-8485-3c4ecc019c0b	2026-07-21 18:35:18.932907+00	2026-07-21 18:35:18.932907+00
efb263c4-05b2-42d2-bc77-af9f0cbd846e	d8941b2b-18b5-4fd6-8c49-ce7a587c6294	4bfc028f-1c19-4b0c-9188-9fe233b49cb4	پیاده‌سازی بخش اصلی	123	32	2026-06-22	approved	89f48814-745b-462e-820c-aff4124c3949	\N	fbba6e33-ae4e-4e3d-a776-32c8335f5051	2026-07-21 18:35:18.932907+00	2026-07-21 18:35:18.932907+00
efb263c4-05b2-42d2-bc77-af9f0cbd846e	d8941b2b-18b5-4fd6-8c49-ce7a587c6294	4bfc028f-1c19-4b0c-9188-9fe233b49cb4	مستندسازی و نهایی‌سازی	217	58	2026-06-24	approved	89f48814-745b-462e-820c-aff4124c3949	\N	0f64b453-9e0f-4a3c-b511-796a2cdcfb88	2026-07-21 18:35:18.932907+00	2026-07-21 18:35:18.932907+00
efb263c4-05b2-42d2-bc77-af9f0cbd846e	d8941b2b-18b5-4fd6-8c49-ce7a587c6294	4bfc028f-1c19-4b0c-9188-9fe233b49cb4	تست و اطمینان از عملکرد صحیح	158	100	2026-06-26	approved	89f48814-745b-462e-820c-aff4124c3949	\N	ec01d0e2-d31a-43d4-bf3c-0e883b91b41d	2026-07-21 18:35:18.932907+00	2026-07-21 18:35:18.932907+00
efb263c4-05b2-42d2-bc77-af9f0cbd846e	b511a8ec-7a72-432a-b887-b2211017181f	4bfc028f-1c19-4b0c-9188-9fe233b49cb4	پیشرفت اولیه و بررسی نیازمندی‌ها	199	27	2026-07-16	approved	89f48814-745b-462e-820c-aff4124c3949	\N	0de55fbc-778a-4256-9a79-b8f2109366e7	2026-07-21 18:35:18.932907+00	2026-07-21 18:35:18.932907+00
efb263c4-05b2-42d2-bc77-af9f0cbd846e	d5a2fb29-fd48-4d18-b48c-e9f193e5a048	e38a8fbd-4c9d-4475-ae1b-150a034a6936	تست و اطمینان از عملکرد صحیح	70	25	2026-06-25	approved	89f48814-745b-462e-820c-aff4124c3949	\N	04870cce-b439-48f9-adbb-5d6c85477482	2026-07-21 18:35:18.932907+00	2026-07-21 18:35:18.932907+00
efb263c4-05b2-42d2-bc77-af9f0cbd846e	d5a2fb29-fd48-4d18-b48c-e9f193e5a048	e38a8fbd-4c9d-4475-ae1b-150a034a6936	تست و اطمینان از عملکرد صحیح	121	42	2026-06-27	approved	89f48814-745b-462e-820c-aff4124c3949	\N	4af7835f-4f15-4dde-a44e-6f69f654c6c9	2026-07-21 18:35:18.932907+00	2026-07-21 18:35:18.932907+00
efb263c4-05b2-42d2-bc77-af9f0cbd846e	2308411f-3ee4-4cb1-9288-95aa8b5f5a0f	4bfc028f-1c19-4b0c-9188-9fe233b49cb4	پیاده‌سازی بخش اصلی	46	28	2026-07-06	approved	89f48814-745b-462e-820c-aff4124c3949	\N	843b3802-5502-4386-8430-94358d709d65	2026-07-21 18:35:18.932907+00	2026-07-21 18:35:18.932907+00
efb263c4-05b2-42d2-bc77-af9f0cbd846e	2308411f-3ee4-4cb1-9288-95aa8b5f5a0f	4bfc028f-1c19-4b0c-9188-9fe233b49cb4	پیاده‌سازی بخش اصلی	40	52	2026-07-09	approved	89f48814-745b-462e-820c-aff4124c3949	\N	dbdedde7-43dd-48ab-bb3f-a3ac20f93771	2026-07-21 18:35:18.932907+00	2026-07-21 18:35:18.932907+00
efb263c4-05b2-42d2-bc77-af9f0cbd846e	848d12a2-059e-4d93-9830-ec8989b61523	d9facd7e-b4bd-497f-9f4f-f75e6a932da0	تست و اطمینان از عملکرد صحیح	41	21	2026-07-16	approved	89f48814-745b-462e-820c-aff4124c3949	\N	b9bb357e-f223-44ea-9123-0f77db415893	2026-07-21 18:35:18.932907+00	2026-07-21 18:35:18.932907+00
efb263c4-05b2-42d2-bc77-af9f0cbd846e	848d12a2-059e-4d93-9830-ec8989b61523	d9facd7e-b4bd-497f-9f4f-f75e6a932da0	مستندسازی و نهایی‌سازی	192	56	2026-07-16	approved	89f48814-745b-462e-820c-aff4124c3949	\N	40febc4c-6747-49e1-bc26-a5a343b7a217	2026-07-21 18:35:18.932907+00	2026-07-21 18:35:18.932907+00
efb263c4-05b2-42d2-bc77-af9f0cbd846e	848d12a2-059e-4d93-9830-ec8989b61523	d9facd7e-b4bd-497f-9f4f-f75e6a932da0	مستندسازی و نهایی‌سازی	74	96	2026-07-16	approved	89f48814-745b-462e-820c-aff4124c3949	\N	f648c964-0abc-4815-828c-ea88f24e68a9	2026-07-21 18:35:18.932907+00	2026-07-21 18:35:18.932907+00
efb263c4-05b2-42d2-bc77-af9f0cbd846e	80e826dd-d725-405b-970b-acff1efdd669	e38a8fbd-4c9d-4475-ae1b-150a034a6936	پیشرفت اولیه و بررسی نیازمندی‌ها	162	28	2026-07-16	approved	89f48814-745b-462e-820c-aff4124c3949	\N	cf8d1955-2577-430b-99f4-60881b9a218c	2026-07-21 18:35:18.932907+00	2026-07-21 18:35:18.932907+00
efb263c4-05b2-42d2-bc77-af9f0cbd846e	80e826dd-d725-405b-970b-acff1efdd669	e38a8fbd-4c9d-4475-ae1b-150a034a6936	پیاده‌سازی بخش اصلی	162	64	2026-07-16	submitted	\N	\N	85f0b905-8e38-4f1a-9c78-bb309989622a	2026-07-21 18:35:18.932907+00	2026-07-21 18:35:18.932907+00
efb263c4-05b2-42d2-bc77-af9f0cbd846e	80e826dd-d725-405b-970b-acff1efdd669	e38a8fbd-4c9d-4475-ae1b-150a034a6936	رفع اشکالات و بازبینی	154	100	2026-07-16	submitted	\N	\N	54b91a44-b8a0-4fbb-b24e-e495900025b7	2026-07-21 18:35:18.932907+00	2026-07-21 18:35:18.932907+00
efb263c4-05b2-42d2-bc77-af9f0cbd846e	80e826dd-d725-405b-970b-acff1efdd669	e38a8fbd-4c9d-4475-ae1b-150a034a6936	پیاده‌سازی بخش اصلی	142	100	2026-07-16	approved	89f48814-745b-462e-820c-aff4124c3949	\N	a8aaab21-ba00-4dbc-bc9b-85bb2c755b60	2026-07-21 18:35:18.932907+00	2026-07-21 18:35:18.932907+00
efb263c4-05b2-42d2-bc77-af9f0cbd846e	ebc9d9c0-5170-4d8b-b571-3cebe2e7c076	89f48814-745b-462e-820c-aff4124c3949	مستندسازی و نهایی‌سازی	194	28	2026-07-02	approved	89f48814-745b-462e-820c-aff4124c3949	\N	5f439af0-159d-4e4a-acb3-e112bccfba66	2026-07-21 18:35:18.932907+00	2026-07-21 18:35:18.932907+00
efb263c4-05b2-42d2-bc77-af9f0cbd846e	ebc9d9c0-5170-4d8b-b571-3cebe2e7c076	89f48814-745b-462e-820c-aff4124c3949	پیاده‌سازی بخش اصلی	77	50	2026-07-04	approved	89f48814-745b-462e-820c-aff4124c3949	\N	1b58384c-3fcc-4947-9b09-0e5c9a937c97	2026-07-21 18:35:18.932907+00	2026-07-21 18:35:18.932907+00
efb263c4-05b2-42d2-bc77-af9f0cbd846e	5b6afa48-43df-4285-8023-70f8dc938f44	d9facd7e-b4bd-497f-9f4f-f75e6a932da0	پیاده‌سازی بخش اصلی	136	30	2026-07-08	approved	89f48814-745b-462e-820c-aff4124c3949	\N	34223851-395f-4675-b3f1-e0c47bfd0012	2026-07-21 18:35:18.932907+00	2026-07-21 18:35:18.932907+00
efb263c4-05b2-42d2-bc77-af9f0cbd846e	5b6afa48-43df-4285-8023-70f8dc938f44	d9facd7e-b4bd-497f-9f4f-f75e6a932da0	تست و اطمینان از عملکرد صحیح	202	70	2026-07-09	approved	89f48814-745b-462e-820c-aff4124c3949	\N	24512f74-20e0-4b21-973e-ae334c578e47	2026-07-21 18:35:18.932907+00	2026-07-21 18:35:18.932907+00
efb263c4-05b2-42d2-bc77-af9f0cbd846e	5b6afa48-43df-4285-8023-70f8dc938f44	d9facd7e-b4bd-497f-9f4f-f75e6a932da0	پیاده‌سازی بخش اصلی	181	75	2026-07-16	approved	89f48814-745b-462e-820c-aff4124c3949	\N	29f3c574-a676-42ac-877f-9e783362b1ee	2026-07-21 18:35:18.932907+00	2026-07-21 18:35:18.932907+00
efb263c4-05b2-42d2-bc77-af9f0cbd846e	3018d0f4-c0af-4b6f-a47d-f51a3d4be997	d9facd7e-b4bd-497f-9f4f-f75e6a932da0	پیاده‌سازی بخش اصلی	176	38	2026-07-02	approved	89f48814-745b-462e-820c-aff4124c3949	\N	00fcf381-a636-48ec-bf1c-acef3c3c6b56	2026-07-21 18:35:18.932907+00	2026-07-21 18:35:18.932907+00
efb263c4-05b2-42d2-bc77-af9f0cbd846e	3018d0f4-c0af-4b6f-a47d-f51a3d4be997	d9facd7e-b4bd-497f-9f4f-f75e6a932da0	مستندسازی و نهایی‌سازی	40	76	2026-07-04	approved	89f48814-745b-462e-820c-aff4124c3949	\N	78e506d0-e6b5-4b28-bc16-30a288d6478d	2026-07-21 18:35:18.932907+00	2026-07-21 18:35:18.932907+00
efb263c4-05b2-42d2-bc77-af9f0cbd846e	3018d0f4-c0af-4b6f-a47d-f51a3d4be997	d9facd7e-b4bd-497f-9f4f-f75e6a932da0	رفع اشکالات و بازبینی	76	100	2026-07-06	approved	89f48814-745b-462e-820c-aff4124c3949	\N	f9955cc8-e0e4-412a-8bd8-6fe0effceba8	2026-07-21 18:35:18.932907+00	2026-07-21 18:35:18.932907+00
efb263c4-05b2-42d2-bc77-af9f0cbd846e	3018d0f4-c0af-4b6f-a47d-f51a3d4be997	d9facd7e-b4bd-497f-9f4f-f75e6a932da0	مستندسازی و نهایی‌سازی	193	80	2026-07-14	approved	89f48814-745b-462e-820c-aff4124c3949	\N	16289e66-17cb-490b-9ee4-fb60fed77c8a	2026-07-21 18:35:18.932907+00	2026-07-21 18:35:18.932907+00
efb263c4-05b2-42d2-bc77-af9f0cbd846e	d037bb17-23c3-44ec-9129-84976bcd7798	4bfc028f-1c19-4b0c-9188-9fe233b49cb4	پیاده‌سازی بخش اصلی	144	39	2026-07-16	approved	89f48814-745b-462e-820c-aff4124c3949	\N	453f2e03-027b-4f02-905b-b2a99f06f087	2026-07-21 18:35:18.932907+00	2026-07-21 18:35:18.932907+00
efb263c4-05b2-42d2-bc77-af9f0cbd846e	d037bb17-23c3-44ec-9129-84976bcd7798	4bfc028f-1c19-4b0c-9188-9fe233b49cb4	تست و اطمینان از عملکرد صحیح	73	54	2026-07-16	approved	89f48814-745b-462e-820c-aff4124c3949	\N	ac85da28-656b-4914-b6af-a813257302fb	2026-07-21 18:35:18.932907+00	2026-07-21 18:35:18.932907+00
efb263c4-05b2-42d2-bc77-af9f0cbd846e	d037bb17-23c3-44ec-9129-84976bcd7798	4bfc028f-1c19-4b0c-9188-9fe233b49cb4	مستندسازی و نهایی‌سازی	66	100	2026-07-16	approved	89f48814-745b-462e-820c-aff4124c3949	\N	a4ec50b3-2e84-4153-bb49-5feea314ef5a	2026-07-21 18:35:18.932907+00	2026-07-21 18:35:18.932907+00
efb263c4-05b2-42d2-bc77-af9f0cbd846e	bca843db-6607-4a7b-bbd2-75cadd75edb0	63d308ce-8593-4f45-8c4b-1df63a00732c	رفع اشکالات و بازبینی	146	39	2026-07-16	approved	89f48814-745b-462e-820c-aff4124c3949	\N	7cadd7bb-8a36-49a0-8fa8-4774d345e70e	2026-07-21 18:35:18.932907+00	2026-07-21 18:35:18.932907+00
efb263c4-05b2-42d2-bc77-af9f0cbd846e	bca843db-6607-4a7b-bbd2-75cadd75edb0	63d308ce-8593-4f45-8c4b-1df63a00732c	تست و اطمینان از عملکرد صحیح	63	46	2026-07-16	approved	89f48814-745b-462e-820c-aff4124c3949	\N	2e4f075b-5c80-4e85-9131-1ff65bbbde19	2026-07-21 18:35:18.932907+00	2026-07-21 18:35:18.932907+00
efb263c4-05b2-42d2-bc77-af9f0cbd846e	219cb336-304b-4d97-8343-89ad766e3e36	e38a8fbd-4c9d-4475-ae1b-150a034a6936	مستندسازی و نهایی‌سازی	205	33	2026-07-11	approved	89f48814-745b-462e-820c-aff4124c3949	\N	c2418888-24a5-44e5-8605-72af986a7e35	2026-07-21 18:35:18.932907+00	2026-07-21 18:35:18.932907+00
efb263c4-05b2-42d2-bc77-af9f0cbd846e	c668a551-dcb1-4d8d-b2fe-7726027eacc3	63d308ce-8593-4f45-8c4b-1df63a00732c	پیاده‌سازی بخش اصلی	151	39	2026-07-09	approved	89f48814-745b-462e-820c-aff4124c3949	\N	49e78d7a-97cc-441b-816a-9d45545d09fc	2026-07-21 18:35:18.932907+00	2026-07-21 18:35:18.932907+00
efb263c4-05b2-42d2-bc77-af9f0cbd846e	c668a551-dcb1-4d8d-b2fe-7726027eacc3	63d308ce-8593-4f45-8c4b-1df63a00732c	مستندسازی و نهایی‌سازی	158	46	2026-07-10	approved	89f48814-745b-462e-820c-aff4124c3949	\N	1b29f951-48e8-4a4d-a521-1a1288971ae7	2026-07-21 18:35:18.932907+00	2026-07-21 18:35:18.932907+00
efb263c4-05b2-42d2-bc77-af9f0cbd846e	c83cf8c9-11b7-491a-9bbd-5ab5f05c4f1d	89f48814-745b-462e-820c-aff4124c3949	مستندسازی و نهایی‌سازی	168	20	2026-07-16	approved	89f48814-745b-462e-820c-aff4124c3949	\N	a93a8ce9-6c82-4d88-bb77-349ca3586ff3	2026-07-21 18:35:18.932907+00	2026-07-21 18:35:18.932907+00
efb263c4-05b2-42d2-bc77-af9f0cbd846e	f4b7a9d8-7e89-40ff-a296-e21182ff3d8d	d9facd7e-b4bd-497f-9f4f-f75e6a932da0	پیشرفت اولیه و بررسی نیازمندی‌ها	208	36	2026-07-15	approved	89f48814-745b-462e-820c-aff4124c3949	\N	d743a15c-edfa-4213-963d-5cb81b033013	2026-07-21 18:35:18.932907+00	2026-07-21 18:35:18.932907+00
efb263c4-05b2-42d2-bc77-af9f0cbd846e	f4b7a9d8-7e89-40ff-a296-e21182ff3d8d	d9facd7e-b4bd-497f-9f4f-f75e6a932da0	تست و اطمینان از عملکرد صحیح	232	64	2026-07-16	approved	89f48814-745b-462e-820c-aff4124c3949	\N	1135455a-0f7f-4e50-8c6c-ffe6a2a11e91	2026-07-21 18:35:18.932907+00	2026-07-21 18:35:18.932907+00
efb263c4-05b2-42d2-bc77-af9f0cbd846e	f4b7a9d8-7e89-40ff-a296-e21182ff3d8d	d9facd7e-b4bd-497f-9f4f-f75e6a932da0	مستندسازی و نهایی‌سازی	55	99	2026-07-16	approved	89f48814-745b-462e-820c-aff4124c3949	\N	debf0bdc-8273-4d48-a15c-30a86aa62901	2026-07-21 18:35:18.932907+00	2026-07-21 18:35:18.932907+00
efb263c4-05b2-42d2-bc77-af9f0cbd846e	f4b7a9d8-7e89-40ff-a296-e21182ff3d8d	d9facd7e-b4bd-497f-9f4f-f75e6a932da0	پیاده‌سازی بخش اصلی	51	100	2026-07-16	approved	89f48814-745b-462e-820c-aff4124c3949	\N	21ef2ac7-ae74-4a02-aebf-e2478c654c70	2026-07-21 18:35:18.932907+00	2026-07-21 18:35:18.932907+00
efb263c4-05b2-42d2-bc77-af9f0cbd846e	e49193f3-b748-41f0-9138-9c1f609b50ad	4bfc028f-1c19-4b0c-9188-9fe233b49cb4	پیشرفت اولیه و بررسی نیازمندی‌ها	177	36	2026-06-17	approved	89f48814-745b-462e-820c-aff4124c3949	\N	04628f9a-0439-4b4d-b5a7-84cf302db6ef	2026-07-21 18:35:18.932907+00	2026-07-21 18:35:18.932907+00
efb263c4-05b2-42d2-bc77-af9f0cbd846e	e49193f3-b748-41f0-9138-9c1f609b50ad	4bfc028f-1c19-4b0c-9188-9fe233b49cb4	تست و اطمینان از عملکرد صحیح	197	52	2026-06-18	approved	89f48814-745b-462e-820c-aff4124c3949	\N	f4055794-fe43-4d82-a261-18702784a7a7	2026-07-21 18:35:18.932907+00	2026-07-21 18:35:18.932907+00
efb263c4-05b2-42d2-bc77-af9f0cbd846e	e49193f3-b748-41f0-9138-9c1f609b50ad	4bfc028f-1c19-4b0c-9188-9fe233b49cb4	پیشرفت اولیه و بررسی نیازمندی‌ها	69	99	2026-06-23	approved	89f48814-745b-462e-820c-aff4124c3949	\N	27a7bf73-fa37-4147-bc6a-a3e0e6cec856	2026-07-21 18:35:18.932907+00	2026-07-21 18:35:18.932907+00
efb263c4-05b2-42d2-bc77-af9f0cbd846e	e49193f3-b748-41f0-9138-9c1f609b50ad	4bfc028f-1c19-4b0c-9188-9fe233b49cb4	مستندسازی و نهایی‌سازی	138	100	2026-06-26	approved	89f48814-745b-462e-820c-aff4124c3949	\N	8148ba84-94e2-406d-9e36-ba9053ba7dd7	2026-07-21 18:35:18.932907+00	2026-07-21 18:35:18.932907+00
efb263c4-05b2-42d2-bc77-af9f0cbd846e	304ef989-3b69-4dab-bd18-3ded35188a10	89f48814-745b-462e-820c-aff4124c3949	تست و اطمینان از عملکرد صحیح	223	26	2026-06-23	approved	89f48814-745b-462e-820c-aff4124c3949	\N	3b36a8d3-0a59-4abf-984e-2960d8900301	2026-07-21 18:35:18.932907+00	2026-07-21 18:35:18.932907+00
efb263c4-05b2-42d2-bc77-af9f0cbd846e	304ef989-3b69-4dab-bd18-3ded35188a10	89f48814-745b-462e-820c-aff4124c3949	مستندسازی و نهایی‌سازی	230	74	2026-06-27	approved	89f48814-745b-462e-820c-aff4124c3949	\N	9b4d68d1-33b4-4ac0-9bd0-33b969ded692	2026-07-21 18:35:18.932907+00	2026-07-21 18:35:18.932907+00
efb263c4-05b2-42d2-bc77-af9f0cbd846e	304ef989-3b69-4dab-bd18-3ded35188a10	89f48814-745b-462e-820c-aff4124c3949	پیاده‌سازی بخش اصلی	124	100	2026-07-01	approved	89f48814-745b-462e-820c-aff4124c3949	\N	e453e161-1a4b-41db-b496-3aa4adc0e13c	2026-07-21 18:35:18.932907+00	2026-07-21 18:35:18.932907+00
efb263c4-05b2-42d2-bc77-af9f0cbd846e	cfce63b5-b043-4e85-86d7-bb4f1b249a0e	eb0b5b71-65c1-4694-a9d0-5b2b7aea8eae	رفع اشکالات و بازبینی	177	31	2026-07-16	approved	89f48814-745b-462e-820c-aff4124c3949	\N	f732d4b2-f626-42eb-a6ba-a13f868b0533	2026-07-21 18:35:18.932907+00	2026-07-21 18:35:18.932907+00
efb263c4-05b2-42d2-bc77-af9f0cbd846e	cfce63b5-b043-4e85-86d7-bb4f1b249a0e	eb0b5b71-65c1-4694-a9d0-5b2b7aea8eae	پیاده‌سازی بخش اصلی	198	46	2026-07-16	approved	89f48814-745b-462e-820c-aff4124c3949	\N	7a2d0094-d898-46bb-87a3-fff4f09972aa	2026-07-21 18:35:18.932907+00	2026-07-21 18:35:18.932907+00
efb263c4-05b2-42d2-bc77-af9f0cbd846e	cfce63b5-b043-4e85-86d7-bb4f1b249a0e	eb0b5b71-65c1-4694-a9d0-5b2b7aea8eae	تست و اطمینان از عملکرد صحیح	230	75	2026-07-16	approved	89f48814-745b-462e-820c-aff4124c3949	\N	082daa44-206f-4f77-be34-d97dd94a5eda	2026-07-21 18:35:18.932907+00	2026-07-21 18:35:18.932907+00
efb263c4-05b2-42d2-bc77-af9f0cbd846e	cfce63b5-b043-4e85-86d7-bb4f1b249a0e	eb0b5b71-65c1-4694-a9d0-5b2b7aea8eae	پیاده‌سازی بخش اصلی	160	100	2026-07-16	approved	89f48814-745b-462e-820c-aff4124c3949	\N	6c3c9ad5-5f58-4f27-bd78-9f1d37650461	2026-07-21 18:35:18.932907+00	2026-07-21 18:35:18.932907+00
efb263c4-05b2-42d2-bc77-af9f0cbd846e	155014d5-f841-48cf-a590-f17c8c086f97	e38a8fbd-4c9d-4475-ae1b-150a034a6936	پیاده‌سازی بخش اصلی	129	40	2026-07-12	approved	89f48814-745b-462e-820c-aff4124c3949	\N	fda02caf-2bae-4a8d-9c32-778da1907645	2026-07-21 18:35:18.932907+00	2026-07-21 18:35:18.932907+00
efb263c4-05b2-42d2-bc77-af9f0cbd846e	155014d5-f841-48cf-a590-f17c8c086f97	e38a8fbd-4c9d-4475-ae1b-150a034a6936	پیشرفت اولیه و بررسی نیازمندی‌ها	240	48	2026-07-13	approved	89f48814-745b-462e-820c-aff4124c3949	\N	86e22908-96d0-4436-ad85-986931628475	2026-07-21 18:35:18.932907+00	2026-07-21 18:35:18.932907+00
efb263c4-05b2-42d2-bc77-af9f0cbd846e	155014d5-f841-48cf-a590-f17c8c086f97	e38a8fbd-4c9d-4475-ae1b-150a034a6936	مستندسازی و نهایی‌سازی	141	66	2026-07-16	approved	89f48814-745b-462e-820c-aff4124c3949	\N	ffe3d696-d96e-4862-a1c6-97eebe3e72b0	2026-07-21 18:35:18.932907+00	2026-07-21 18:35:18.932907+00
efb263c4-05b2-42d2-bc77-af9f0cbd846e	766b9ecd-c93b-4013-a75e-5c7f77b6b199	3d944638-fc96-463d-84ac-c7c861324cbe	پیاده‌سازی بخش اصلی	124	22	2026-07-16	approved	89f48814-745b-462e-820c-aff4124c3949	\N	d5a857d4-ac0a-417c-8885-e7e6e57aa9bf	2026-07-21 18:35:18.932907+00	2026-07-21 18:35:18.932907+00
efb263c4-05b2-42d2-bc77-af9f0cbd846e	a51cc1a1-36a3-4155-a7b4-e3098d34ca36	d9facd7e-b4bd-497f-9f4f-f75e6a932da0	تست و اطمینان از عملکرد صحیح	187	40	2026-07-08	approved	89f48814-745b-462e-820c-aff4124c3949	\N	1d2339d4-ef3f-465a-b7f2-df87be490abc	2026-07-21 18:35:18.932907+00	2026-07-21 18:35:18.932907+00
efb263c4-05b2-42d2-bc77-af9f0cbd846e	4fb36fd5-7d0b-4144-9003-9f117b6e6038	eb0b5b71-65c1-4694-a9d0-5b2b7aea8eae	پیاده‌سازی بخش اصلی	193	35	2026-07-16	submitted	\N	\N	e3cdf6d9-05a9-4a6b-9de2-fe2aecba103a	2026-07-21 18:35:18.932907+00	2026-07-21 18:35:18.932907+00
efb263c4-05b2-42d2-bc77-af9f0cbd846e	4fb36fd5-7d0b-4144-9003-9f117b6e6038	eb0b5b71-65c1-4694-a9d0-5b2b7aea8eae	مستندسازی و نهایی‌سازی	103	52	2026-07-16	approved	89f48814-745b-462e-820c-aff4124c3949	\N	d2a06fe6-10b2-47a7-a029-71e3af73f707	2026-07-21 18:35:18.932907+00	2026-07-21 18:35:18.932907+00
efb263c4-05b2-42d2-bc77-af9f0cbd846e	4fb36fd5-7d0b-4144-9003-9f117b6e6038	eb0b5b71-65c1-4694-a9d0-5b2b7aea8eae	مستندسازی و نهایی‌سازی	162	81	2026-07-16	submitted	\N	\N	db1c1669-9c0f-473d-ad1e-99349c6b1c60	2026-07-21 18:35:18.932907+00	2026-07-21 18:35:18.932907+00
efb263c4-05b2-42d2-bc77-af9f0cbd846e	866a5ea4-ce84-437a-82b7-f5fed243dcb8	4bfc028f-1c19-4b0c-9188-9fe233b49cb4	رفع اشکالات و بازبینی	91	40	2026-07-16	approved	89f48814-745b-462e-820c-aff4124c3949	\N	0d39f28b-02b5-444b-bb96-96f624b1f10d	2026-07-21 18:35:18.932907+00	2026-07-21 18:35:18.932907+00
efb263c4-05b2-42d2-bc77-af9f0cbd846e	866a5ea4-ce84-437a-82b7-f5fed243dcb8	4bfc028f-1c19-4b0c-9188-9fe233b49cb4	پیاده‌سازی بخش اصلی	52	56	2026-07-16	approved	89f48814-745b-462e-820c-aff4124c3949	\N	21d6b085-e015-4fef-a784-4fc189209ccf	2026-07-21 18:35:18.932907+00	2026-07-21 18:35:18.932907+00
efb263c4-05b2-42d2-bc77-af9f0cbd846e	0fec87a5-0ac1-4ee1-8412-a802286353a3	eb0b5b71-65c1-4694-a9d0-5b2b7aea8eae	تست و اطمینان از عملکرد صحیح	180	26	2026-07-02	approved	89f48814-745b-462e-820c-aff4124c3949	\N	44434bef-28c1-43e0-9b89-e17db2812a0a	2026-07-21 18:35:18.932907+00	2026-07-21 18:35:18.932907+00
efb263c4-05b2-42d2-bc77-af9f0cbd846e	0fec87a5-0ac1-4ee1-8412-a802286353a3	eb0b5b71-65c1-4694-a9d0-5b2b7aea8eae	پیشرفت اولیه و بررسی نیازمندی‌ها	53	74	2026-07-03	submitted	\N	\N	bdcd6616-7661-4da3-bdb3-0dccc0b03e7c	2026-07-21 18:35:18.932907+00	2026-07-21 18:35:18.932907+00
efb263c4-05b2-42d2-bc77-af9f0cbd846e	0fec87a5-0ac1-4ee1-8412-a802286353a3	eb0b5b71-65c1-4694-a9d0-5b2b7aea8eae	مستندسازی و نهایی‌سازی	179	93	2026-07-08	submitted	\N	\N	109cb5f2-9e6c-4df1-be04-c987444ab815	2026-07-21 18:35:18.932907+00	2026-07-21 18:35:18.932907+00
efb263c4-05b2-42d2-bc77-af9f0cbd846e	0fec87a5-0ac1-4ee1-8412-a802286353a3	eb0b5b71-65c1-4694-a9d0-5b2b7aea8eae	رفع اشکالات و بازبینی	87	100	2026-07-11	submitted	\N	\N	6369424c-5b66-4e26-b632-dfe939f1d5f8	2026-07-21 18:35:18.932907+00	2026-07-21 18:35:18.932907+00
efb263c4-05b2-42d2-bc77-af9f0cbd846e	4fe5f8f9-7ffb-4196-9cb4-619ffc0dc8b8	4bfc028f-1c19-4b0c-9188-9fe233b49cb4	مستندسازی و نهایی‌سازی	31	28	2026-07-09	submitted	\N	\N	f3666215-2d6e-4169-876c-072c5e4970eb	2026-07-21 18:35:18.932907+00	2026-07-21 18:35:18.932907+00
efb263c4-05b2-42d2-bc77-af9f0cbd846e	4fe5f8f9-7ffb-4196-9cb4-619ffc0dc8b8	4bfc028f-1c19-4b0c-9188-9fe233b49cb4	پیشرفت اولیه و بررسی نیازمندی‌ها	173	44	2026-07-11	approved	89f48814-745b-462e-820c-aff4124c3949	\N	e28de5fc-abf3-4082-8225-4c58c3c3a701	2026-07-21 18:35:18.932907+00	2026-07-21 18:35:18.932907+00
efb263c4-05b2-42d2-bc77-af9f0cbd846e	62777b43-0ae3-42e9-8497-985de756f991	eb0b5b71-65c1-4694-a9d0-5b2b7aea8eae	پیشرفت اولیه و بررسی نیازمندی‌ها	235	36	2026-07-16	approved	89f48814-745b-462e-820c-aff4124c3949	\N	b4e8f731-38cd-4fec-bd4a-d5c4ae27c338	2026-07-21 18:35:18.932907+00	2026-07-21 18:35:18.932907+00
efb263c4-05b2-42d2-bc77-af9f0cbd846e	62777b43-0ae3-42e9-8497-985de756f991	eb0b5b71-65c1-4694-a9d0-5b2b7aea8eae	مستندسازی و نهایی‌سازی	238	76	2026-07-16	approved	89f48814-745b-462e-820c-aff4124c3949	\N	09caa50b-37bd-42d4-9035-5ed332506097	2026-07-21 18:35:18.932907+00	2026-07-21 18:35:18.932907+00
efb263c4-05b2-42d2-bc77-af9f0cbd846e	62777b43-0ae3-42e9-8497-985de756f991	eb0b5b71-65c1-4694-a9d0-5b2b7aea8eae	تست و اطمینان از عملکرد صحیح	126	100	2026-07-16	approved	89f48814-745b-462e-820c-aff4124c3949	\N	1cb79437-b4f4-4a8e-996f-504ef40a9be8	2026-07-21 18:35:18.932907+00	2026-07-21 18:35:18.932907+00
efb263c4-05b2-42d2-bc77-af9f0cbd846e	7a28d385-5b14-42a5-bc6b-772ca3be48f7	eb0b5b71-65c1-4694-a9d0-5b2b7aea8eae	تست و اطمینان از عملکرد صحیح	204	34	2026-07-15	submitted	\N	\N	d5987ac5-4cf8-4721-b4e0-bca2202b298b	2026-07-21 18:35:18.932907+00	2026-07-21 18:35:18.932907+00
efb263c4-05b2-42d2-bc77-af9f0cbd846e	7a28d385-5b14-42a5-bc6b-772ca3be48f7	eb0b5b71-65c1-4694-a9d0-5b2b7aea8eae	رفع اشکالات و بازبینی	47	64	2026-07-16	approved	89f48814-745b-462e-820c-aff4124c3949	\N	bbe42d1b-dd26-4028-a91d-33fc68c24524	2026-07-21 18:35:18.932907+00	2026-07-21 18:35:18.932907+00
efb263c4-05b2-42d2-bc77-af9f0cbd846e	7a28d385-5b14-42a5-bc6b-772ca3be48f7	eb0b5b71-65c1-4694-a9d0-5b2b7aea8eae	پیاده‌سازی بخش اصلی	234	90	2026-07-16	approved	89f48814-745b-462e-820c-aff4124c3949	\N	45617c30-c204-4336-9c0c-376f353a0c65	2026-07-21 18:35:18.932907+00	2026-07-21 18:35:18.932907+00
efb263c4-05b2-42d2-bc77-af9f0cbd846e	7a28d385-5b14-42a5-bc6b-772ca3be48f7	eb0b5b71-65c1-4694-a9d0-5b2b7aea8eae	مستندسازی و نهایی‌سازی	167	80	2026-07-16	submitted	\N	\N	8b3b89c1-91c1-473c-b33b-bcef6db2e99d	2026-07-21 18:35:18.932907+00	2026-07-21 18:35:18.932907+00
efb263c4-05b2-42d2-bc77-af9f0cbd846e	5f1388c4-0d20-41b5-9a62-5304f675a943	e38a8fbd-4c9d-4475-ae1b-150a034a6936	رفع اشکالات و بازبینی	53	32	2026-07-10	approved	89f48814-745b-462e-820c-aff4124c3949	\N	7755dd50-ac38-488f-b50b-8b2e2ea10cf1	2026-07-21 18:35:18.932907+00	2026-07-21 18:35:18.932907+00
efb263c4-05b2-42d2-bc77-af9f0cbd846e	5f1388c4-0d20-41b5-9a62-5304f675a943	e38a8fbd-4c9d-4475-ae1b-150a034a6936	پیشرفت اولیه و بررسی نیازمندی‌ها	171	50	2026-07-13	approved	89f48814-745b-462e-820c-aff4124c3949	\N	72d71fc4-107b-4d62-a8b7-976d2e40a1e2	2026-07-21 18:35:18.932907+00	2026-07-21 18:35:18.932907+00
efb263c4-05b2-42d2-bc77-af9f0cbd846e	5f1388c4-0d20-41b5-9a62-5304f675a943	e38a8fbd-4c9d-4475-ae1b-150a034a6936	رفع اشکالات و بازبینی	120	78	2026-07-16	approved	89f48814-745b-462e-820c-aff4124c3949	\N	a7156312-c23f-4be5-ae3c-adcfd7d98e0f	2026-07-21 18:35:18.932907+00	2026-07-21 18:35:18.932907+00
efb263c4-05b2-42d2-bc77-af9f0cbd846e	22632b7f-790a-465b-8077-4b987ebf75ac	4bfc028f-1c19-4b0c-9188-9fe233b49cb4	پیاده‌سازی بخش اصلی	157	26	2026-07-16	approved	89f48814-745b-462e-820c-aff4124c3949	\N	475fa698-0595-491f-a75a-2d143c601ffd	2026-07-21 18:35:18.932907+00	2026-07-21 18:35:18.932907+00
efb263c4-05b2-42d2-bc77-af9f0cbd846e	22632b7f-790a-465b-8077-4b987ebf75ac	4bfc028f-1c19-4b0c-9188-9fe233b49cb4	پیاده‌سازی بخش اصلی	97	52	2026-07-16	approved	89f48814-745b-462e-820c-aff4124c3949	\N	38713313-2da0-4953-b0b2-ff2cc0ee573c	2026-07-21 18:35:18.932907+00	2026-07-21 18:35:18.932907+00
efb263c4-05b2-42d2-bc77-af9f0cbd846e	22632b7f-790a-465b-8077-4b987ebf75ac	4bfc028f-1c19-4b0c-9188-9fe233b49cb4	پیاده‌سازی بخش اصلی	93	100	2026-07-16	approved	89f48814-745b-462e-820c-aff4124c3949	\N	e7705ec5-1d09-4d52-a5c0-efe4042f031e	2026-07-21 18:35:18.932907+00	2026-07-21 18:35:18.932907+00
efb263c4-05b2-42d2-bc77-af9f0cbd846e	615a8b04-5cfd-44a2-9970-fd612747ca83	e38a8fbd-4c9d-4475-ae1b-150a034a6936	پیشرفت اولیه و بررسی نیازمندی‌ها	60	22	2026-07-16	approved	89f48814-745b-462e-820c-aff4124c3949	\N	dbc2ed93-2740-4d8f-ba27-beb465e73d07	2026-07-21 18:35:18.932907+00	2026-07-21 18:35:18.932907+00
efb263c4-05b2-42d2-bc77-af9f0cbd846e	615a8b04-5cfd-44a2-9970-fd612747ca83	e38a8fbd-4c9d-4475-ae1b-150a034a6936	مستندسازی و نهایی‌سازی	31	74	2026-07-16	approved	89f48814-745b-462e-820c-aff4124c3949	\N	63a41a41-8e79-494f-8c41-4ad76718831c	2026-07-21 18:35:18.932907+00	2026-07-21 18:35:18.932907+00
efb263c4-05b2-42d2-bc77-af9f0cbd846e	615a8b04-5cfd-44a2-9970-fd612747ca83	e38a8fbd-4c9d-4475-ae1b-150a034a6936	تست و اطمینان از عملکرد صحیح	125	100	2026-07-16	approved	89f48814-745b-462e-820c-aff4124c3949	\N	b515f0fb-d643-416c-bcd6-31cee97e184c	2026-07-21 18:35:18.932907+00	2026-07-21 18:35:18.932907+00
efb263c4-05b2-42d2-bc77-af9f0cbd846e	478a4a7b-abf8-49ff-993d-9ab84ead7de3	3d944638-fc96-463d-84ac-c7c861324cbe	مستندسازی و نهایی‌سازی	100	35	2026-07-16	approved	89f48814-745b-462e-820c-aff4124c3949	\N	4359f439-c9b0-4188-af2f-3e632b09a8d7	2026-07-21 18:35:18.932907+00	2026-07-21 18:35:18.932907+00
efb263c4-05b2-42d2-bc77-af9f0cbd846e	478a4a7b-abf8-49ff-993d-9ab84ead7de3	3d944638-fc96-463d-84ac-c7c861324cbe	مستندسازی و نهایی‌سازی	101	64	2026-07-16	approved	89f48814-745b-462e-820c-aff4124c3949	\N	3df4c68e-dcd0-4c24-8b8a-5c519db9d21d	2026-07-21 18:35:18.932907+00	2026-07-21 18:35:18.932907+00
efb263c4-05b2-42d2-bc77-af9f0cbd846e	478a4a7b-abf8-49ff-993d-9ab84ead7de3	3d944638-fc96-463d-84ac-c7c861324cbe	مستندسازی و نهایی‌سازی	62	63	2026-07-16	approved	89f48814-745b-462e-820c-aff4124c3949	\N	5d73b986-1c70-4712-9e9c-98f154452404	2026-07-21 18:35:18.932907+00	2026-07-21 18:35:18.932907+00
efb263c4-05b2-42d2-bc77-af9f0cbd846e	f0cfd6bc-5d7b-4042-a6eb-54813dc0602e	eb0b5b71-65c1-4694-a9d0-5b2b7aea8eae	پیشرفت اولیه و بررسی نیازمندی‌ها	158	31	2026-07-16	submitted	\N	\N	998b26ec-55ba-4e6d-8085-be06c52babe9	2026-07-21 18:35:18.932907+00	2026-07-21 18:35:18.932907+00
efb263c4-05b2-42d2-bc77-af9f0cbd846e	f0cfd6bc-5d7b-4042-a6eb-54813dc0602e	eb0b5b71-65c1-4694-a9d0-5b2b7aea8eae	پیاده‌سازی بخش اصلی	147	46	2026-07-16	submitted	\N	\N	092c408e-75d5-4d09-b35b-598e04802100	2026-07-21 18:35:18.932907+00	2026-07-21 18:35:18.932907+00
efb263c4-05b2-42d2-bc77-af9f0cbd846e	f0cfd6bc-5d7b-4042-a6eb-54813dc0602e	eb0b5b71-65c1-4694-a9d0-5b2b7aea8eae	پیشرفت اولیه و بررسی نیازمندی‌ها	33	78	2026-07-16	approved	89f48814-745b-462e-820c-aff4124c3949	\N	0a6f0f5a-832f-4b76-a9cd-d7899dea7cbd	2026-07-21 18:35:18.932907+00	2026-07-21 18:35:18.932907+00
efb263c4-05b2-42d2-bc77-af9f0cbd846e	f0cfd6bc-5d7b-4042-a6eb-54813dc0602e	eb0b5b71-65c1-4694-a9d0-5b2b7aea8eae	رفع اشکالات و بازبینی	122	100	2026-07-16	approved	89f48814-745b-462e-820c-aff4124c3949	\N	221e62f0-10dd-4bd2-8de2-439752e5df4b	2026-07-21 18:35:18.932907+00	2026-07-21 18:35:18.932907+00
efb263c4-05b2-42d2-bc77-af9f0cbd846e	6d48d261-0b8d-4a47-81da-87454373e500	eb0b5b71-65c1-4694-a9d0-5b2b7aea8eae	پیاده‌سازی بخش اصلی	98	35	2026-07-01	approved	89f48814-745b-462e-820c-aff4124c3949	\N	a8711361-966a-4284-81aa-2ecc9d888f5a	2026-07-21 18:35:18.932907+00	2026-07-21 18:35:18.932907+00
efb263c4-05b2-42d2-bc77-af9f0cbd846e	6d48d261-0b8d-4a47-81da-87454373e500	eb0b5b71-65c1-4694-a9d0-5b2b7aea8eae	تست و اطمینان از عملکرد صحیح	138	52	2026-07-04	approved	89f48814-745b-462e-820c-aff4124c3949	\N	070085e9-1375-4001-90cb-1432ad20c9de	2026-07-21 18:35:18.932907+00	2026-07-21 18:35:18.932907+00
efb263c4-05b2-42d2-bc77-af9f0cbd846e	6d48d261-0b8d-4a47-81da-87454373e500	eb0b5b71-65c1-4694-a9d0-5b2b7aea8eae	رفع اشکالات و بازبینی	123	96	2026-07-09	submitted	\N	\N	dbe8ba09-5f9f-4f09-ac58-0821dc14ae44	2026-07-21 18:35:18.932907+00	2026-07-21 18:35:18.932907+00
efb263c4-05b2-42d2-bc77-af9f0cbd846e	e022ec53-f367-46d7-970f-bbb9e2a6898a	e38a8fbd-4c9d-4475-ae1b-150a034a6936	پیاده‌سازی بخش اصلی	177	27	2026-07-11	approved	89f48814-745b-462e-820c-aff4124c3949	\N	f8fb87d3-0158-42fc-8b03-65d48130420b	2026-07-21 18:35:18.932907+00	2026-07-21 18:35:18.932907+00
efb263c4-05b2-42d2-bc77-af9f0cbd846e	e022ec53-f367-46d7-970f-bbb9e2a6898a	e38a8fbd-4c9d-4475-ae1b-150a034a6936	پیاده‌سازی بخش اصلی	172	66	2026-07-12	submitted	\N	\N	e296cc61-8826-48ba-a4d0-61cc11ca25ae	2026-07-21 18:35:18.932907+00	2026-07-21 18:35:18.932907+00
efb263c4-05b2-42d2-bc77-af9f0cbd846e	e022ec53-f367-46d7-970f-bbb9e2a6898a	e38a8fbd-4c9d-4475-ae1b-150a034a6936	پیاده‌سازی بخش اصلی	151	60	2026-07-16	approved	89f48814-745b-462e-820c-aff4124c3949	\N	4d31f895-e215-47a1-af29-0fdb6006c324	2026-07-21 18:35:18.932907+00	2026-07-21 18:35:18.932907+00
efb263c4-05b2-42d2-bc77-af9f0cbd846e	203825b9-41d2-43ae-995e-8d6d2f9bb1da	e38a8fbd-4c9d-4475-ae1b-150a034a6936	تست و اطمینان از عملکرد صحیح	64	40	2026-07-11	approved	89f48814-745b-462e-820c-aff4124c3949	\N	c7708628-b9a7-420f-8e9e-d118cd39e09c	2026-07-21 18:35:18.932907+00	2026-07-21 18:35:18.932907+00
efb263c4-05b2-42d2-bc77-af9f0cbd846e	203825b9-41d2-43ae-995e-8d6d2f9bb1da	e38a8fbd-4c9d-4475-ae1b-150a034a6936	تست و اطمینان از عملکرد صحیح	106	56	2026-07-14	approved	89f48814-745b-462e-820c-aff4124c3949	\N	dbd6a00c-385b-4d20-9633-c302740b7dae	2026-07-21 18:35:18.932907+00	2026-07-21 18:35:18.932907+00
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


