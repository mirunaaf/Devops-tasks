--
-- PostgreSQL database dump
--

-- Dumped from database version 17.4 (Debian 17.4-1.pgdg120+2)
-- Dumped by pg_dump version 17.4 (Debian 17.4-1.pgdg120+2)

SET statement_timeout = 0;
SET lock_timeout = 0;
SET idle_in_transaction_session_timeout = 0;
SET transaction_timeout = 0;
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
-- Name: departments; Type: TABLE; Schema: public; Owner: ituser
--

CREATE TABLE public.departments (
    department_id integer NOT NULL,
    department_name character varying(255) NOT NULL
);


ALTER TABLE public.departments OWNER TO ituser;

--
-- Name: departments_department_id_seq; Type: SEQUENCE; Schema: public; Owner: ituser
--

CREATE SEQUENCE public.departments_department_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER SEQUENCE public.departments_department_id_seq OWNER TO ituser;

--
-- Name: departments_department_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: ituser
--

ALTER SEQUENCE public.departments_department_id_seq OWNED BY public.departments.department_id;


--
-- Name: employees; Type: TABLE; Schema: public; Owner: ituser
--

CREATE TABLE public.employees (
    employee_id integer NOT NULL,
    first_name character varying(100) NOT NULL,
    last_name character varying(100) NOT NULL,
    department_id integer
);


ALTER TABLE public.employees OWNER TO ituser;

--
-- Name: employees_employee_id_seq; Type: SEQUENCE; Schema: public; Owner: ituser
--

CREATE SEQUENCE public.employees_employee_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER SEQUENCE public.employees_employee_id_seq OWNER TO ituser;

--
-- Name: employees_employee_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: ituser
--

ALTER SEQUENCE public.employees_employee_id_seq OWNED BY public.employees.employee_id;


--
-- Name: salaries; Type: TABLE; Schema: public; Owner: ituser
--

CREATE TABLE public.salaries (
    employee_id integer NOT NULL,
    salary numeric(10,2) NOT NULL
);


ALTER TABLE public.salaries OWNER TO ituser;

--
-- Name: departments department_id; Type: DEFAULT; Schema: public; Owner: ituser
--

ALTER TABLE ONLY public.departments ALTER COLUMN department_id SET DEFAULT nextval('public.departments_department_id_seq'::regclass);


--
-- Name: employees employee_id; Type: DEFAULT; Schema: public; Owner: ituser
--

ALTER TABLE ONLY public.employees ALTER COLUMN employee_id SET DEFAULT nextval('public.employees_employee_id_seq'::regclass);


--
-- Data for Name: departments; Type: TABLE DATA; Schema: public; Owner: ituser
--

COPY public.departments (department_id, department_name) FROM stdin;
1	HR
2	IT
3	Finance
4	Marketing
5	Sales
6	Customer Support
7	Operations
8	Legal
\.


--
-- Data for Name: employees; Type: TABLE DATA; Schema: public; Owner: ituser
--

COPY public.employees (employee_id, first_name, last_name, department_id) FROM stdin;
1	Alice	Smith	1
2	George	Anderson	1
3	Mia	Rodriguez	1
4	Ethan	Harris	1
5	Sophia	King	1
6	Bob	Johnson	2
7	Charlie	Brown	2
8	Hannah	Martinez	2
9	Noah	Lewis	2
10	Liam	Clark	2
11	Emma	Davis	2
12	Olivia	Taylor	2
13	Lucas	Baker	2
14	Ava	Evans	2
15	William	Nelson	2
16	David	Williams	3
17	Isaac	Thomas	3
18	Jack	White	3
19	Grace	Robinson	3
20	Daniel	Scott	3
21	Victoria	Lopez	3
22	Frank	Miller	4
23	Karen	Lopez	4
24	Henry	Wright	4
25	Zoe	Allen	4
26	Elijah	Parker	4
27	Charlotte	Adams	4
28	Samuel	Gonzalez	5
29	Eleanor	Carter	5
30	Jacob	Mitchell	5
31	Michael	Perez	5
32	Scarlett	Turner	5
33	Benjamin	Phillips	5
34	Madison	Campbell	5
35	Daniel	Stewart	5
36	Evelyn	Edwards	6
37	Anthony	Collins	6
38	Andrew	Morris	6
39	Sofia	Reed	6
40	Thomas	Ward	6
41	Mila	Peterson	6
42	Joshua	Howard	7
43	Penelope	Ross	7
44	Matthew	Cox	7
45	Aria	Diaz	7
46	Nathan	Sanchez	7
47	Sebastian	Russell	7
48	Nicholas	Bell	8
49	Emily	Hayes	8
50	Joseph	Perry	8
51	Addison	Wood	8
52	Ryan	Brooks	8
53	Aubrey	Bennett	8
\.


--
-- Data for Name: salaries; Type: TABLE DATA; Schema: public; Owner: ituser
--

COPY public.salaries (employee_id, salary) FROM stdin;
1	50000.00
2	55000.00
3	52000.00
4	58000.00
5	60000.00
6	70000.00
7	80000.00
8	75000.00
9	72000.00
10	67000.00
11	85000.00
12	88000.00
13	90000.00
14	92000.00
15	94000.00
16	62000.00
17	65000.00
18	68000.00
19	70000.00
20	73000.00
21	76000.00
22	78000.00
23	81000.00
24	83000.00
25	86000.00
26	89000.00
27	91000.00
28	93000.00
29	95000.00
30	98000.00
31	99000.00
32	102000.00
33	104000.00
34	105000.00
35	107000.00
36	109000.00
37	111000.00
38	113000.00
39	115000.00
40	117000.00
41	119000.00
42	121000.00
43	123000.00
44	125000.00
45	127000.00
46	129000.00
47	131000.00
48	133000.00
49	91000.00
50	137000.00
51	139000.00
52	141000.00
53	143000.00
\.


--
-- Name: departments_department_id_seq; Type: SEQUENCE SET; Schema: public; Owner: ituser
--

SELECT pg_catalog.setval('public.departments_department_id_seq', 8, true);


--
-- Name: employees_employee_id_seq; Type: SEQUENCE SET; Schema: public; Owner: ituser
--

SELECT pg_catalog.setval('public.employees_employee_id_seq', 53, true);


--
-- Name: departments departments_department_name_key; Type: CONSTRAINT; Schema: public; Owner: ituser
--

ALTER TABLE ONLY public.departments
    ADD CONSTRAINT departments_department_name_key UNIQUE (department_name);


--
-- Name: departments departments_pkey; Type: CONSTRAINT; Schema: public; Owner: ituser
--

ALTER TABLE ONLY public.departments
    ADD CONSTRAINT departments_pkey PRIMARY KEY (department_id);


--
-- Name: employees employees_pkey; Type: CONSTRAINT; Schema: public; Owner: ituser
--

ALTER TABLE ONLY public.employees
    ADD CONSTRAINT employees_pkey PRIMARY KEY (employee_id);


--
-- Name: salaries salaries_pkey; Type: CONSTRAINT; Schema: public; Owner: ituser
--

ALTER TABLE ONLY public.salaries
    ADD CONSTRAINT salaries_pkey PRIMARY KEY (employee_id);


--
-- Name: employees employees_department_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: ituser
--

ALTER TABLE ONLY public.employees
    ADD CONSTRAINT employees_department_id_fkey FOREIGN KEY (department_id) REFERENCES public.departments(department_id) ON DELETE SET NULL;


--
-- Name: salaries salaries_employee_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: ituser
--

ALTER TABLE ONLY public.salaries
    ADD CONSTRAINT salaries_employee_id_fkey FOREIGN KEY (employee_id) REFERENCES public.employees(employee_id) ON DELETE CASCADE;


--
-- PostgreSQL database dump complete
--

