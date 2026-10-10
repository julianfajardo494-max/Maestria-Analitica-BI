--
-- PostgreSQL database dump
--

\restrict TsTSLVeUPWJ33CKDR2rZT0dyjFXhVmdhKPby5IkMaceBEDfUQn6NlDLMqLeDhcE

-- Dumped from database version 15.18
-- Dumped by pg_dump version 15.18

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
-- Data for Name: usuarios; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public.usuarios (id, nombre, email, fecha_registro) FROM stdin;
1	Julian Fajardo	julian.fajardo@correounivalle.edu.co	2026-10-10 21:58:00.814799
2	Nicolas Galeano	nicolas.galeano@correounivalle.edu.co	2026-10-10 21:58:00.814799
3	Maria Rodriguez	maria.rodriguez@empresa.com	2026-10-10 21:58:00.814799
4	Carlos Perez	carlos.perez@empresa.com	2026-10-10 21:58:00.814799
5	Ana Martinez	ana.martinez@empresa.com	2026-10-10 21:58:00.814799
\.


--
-- Name: usuarios_id_seq; Type: SEQUENCE SET; Schema: public; Owner: postgres
--

SELECT pg_catalog.setval('public.usuarios_id_seq', 5, true);


--
-- PostgreSQL database dump complete
--

\unrestrict TsTSLVeUPWJ33CKDR2rZT0dyjFXhVmdhKPby5IkMaceBEDfUQn6NlDLMqLeDhcE

