--
-- PostgreSQL database dump
--

-- Dumped from database version 17.5 (Debian 17.5-1.pgdg120+1)
-- Dumped by pg_dump version 17.5 (Debian 17.5-1.pgdg120+1)

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
-- Name: distributors; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.distributors (
    did integer NOT NULL,
    name character varying(255) NOT NULL
);

ALTER TABLE ONLY public.distributors REPLICA IDENTITY FULL;


ALTER TABLE public.distributors OWNER TO postgres;

--
-- Name: films; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.films (
    code integer NOT NULL,
    title character varying(255) NOT NULL
);

ALTER TABLE ONLY public.films REPLICA IDENTITY FULL;


ALTER TABLE public.films OWNER TO postgres;

--
-- Name: test_foreign; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.test_foreign (
    id integer NOT NULL,
    test_primary_id integer NOT NULL
);


ALTER TABLE public.test_foreign OWNER TO postgres;

--
-- Name: test_foreign_id_seq; Type: SEQUENCE; Schema: public; Owner: postgres
--

CREATE SEQUENCE public.test_foreign_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER SEQUENCE public.test_foreign_id_seq OWNER TO postgres;

--
-- Name: test_foreign_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: postgres
--

ALTER SEQUENCE public.test_foreign_id_seq OWNED BY public.test_foreign.id;


--
-- Name: test_primary; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.test_primary (
    first_name character varying(255),
    last_name character varying(255) NOT NULL,
    id integer NOT NULL
);


ALTER TABLE public.test_primary OWNER TO postgres;

--
-- Name: test_primary_id_seq; Type: SEQUENCE; Schema: public; Owner: postgres
--

CREATE SEQUENCE public.test_primary_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER SEQUENCE public.test_primary_id_seq OWNER TO postgres;

--
-- Name: test_primary_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: postgres
--

ALTER SEQUENCE public.test_primary_id_seq OWNED BY public.test_primary.id;


--
-- Name: test_foreign id; Type: DEFAULT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.test_foreign ALTER COLUMN id SET DEFAULT nextval('public.test_foreign_id_seq'::regclass);


--
-- Name: test_primary id; Type: DEFAULT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.test_primary ALTER COLUMN id SET DEFAULT nextval('public.test_primary_id_seq'::regclass);


--
-- Data for Name: distributors; Type: TABLE DATA; Schema: public; Owner: postgres
--

INSERT INTO public.distributors (did, name) VALUES (55, 'f033ab37c30201f73f142449d037028d');
INSERT INTO public.distributors (did, name) VALUES (11, 'ea5d2f1c4608232e07d3aa3d998e5135');
INSERT INTO public.distributors (did, name) VALUES (23, '17e62166fc8586dfa4d1bc0e1742c08b');
INSERT INTO public.distributors (did, name) VALUES (1, 'e4da3b7fbbce2345d7772b0674a318d5');
INSERT INTO public.distributors (did, name) VALUES (94, 'e2ef524fbf3d9fe611d5a8e90fefdc9c');
INSERT INTO public.distributors (did, name) VALUES (10, 'a1d0c6e83f027327d8461063f4ac58a6');
INSERT INTO public.distributors (did, name) VALUES (17, '26657d5ff9020d2abefe558796b99584');
INSERT INTO public.distributors (did, name) VALUES (33, 'ac627ab1ccbdb62ec96e702f07f6425b');
INSERT INTO public.distributors (did, name) VALUES (46, '8e296a067a37563370ded05f5a3bf3ec');
INSERT INTO public.distributors (did, name) VALUES (29, 'c7e1249ffc03eb9ded908c236bd1996d');


--
-- Data for Name: films; Type: TABLE DATA; Schema: public; Owner: postgres
--

INSERT INTO public.films (code, title) VALUES (74, 'd3d9446802a44259755d38e6d163e820');
INSERT INTO public.films (code, title) VALUES (64, 'e2ef524fbf3d9fe611d5a8e90fefdc9c');
INSERT INTO public.films (code, title) VALUES (36, 'ac627ab1ccbdb62ec96e702f07f6425b');
INSERT INTO public.films (code, title) VALUES (71, '34173cb38f07f89ddbebc2ac9128303f');
INSERT INTO public.films (code, title) VALUES (31, '093f65e080a295f8076b1c5722a46aa2');
INSERT INTO public.films (code, title) VALUES (85, '19ca14e7ea6328a42e0eb13d585e4c22');
INSERT INTO public.films (code, title) VALUES (74, '98f13708210194c475687be6106a3b84');
INSERT INTO public.films (code, title) VALUES (69, 'f899139df5e1059396431415e770c6dd');
INSERT INTO public.films (code, title) VALUES (65, '6364d3f0f495b6ab9dcf8d3b5c6e0b01');
INSERT INTO public.films (code, title) VALUES (38, '8f14e45fceea167a5a36dedd4bea2543');


--
-- Data for Name: test_foreign; Type: TABLE DATA; Schema: public; Owner: postgres
--



--
-- Data for Name: test_primary; Type: TABLE DATA; Schema: public; Owner: postgres
--

INSERT INTO public.test_primary (first_name, last_name, id) VALUES ('ja', 'on', 1);


--
-- Name: test_foreign_id_seq; Type: SEQUENCE SET; Schema: public; Owner: postgres
--

SELECT pg_catalog.setval('public.test_foreign_id_seq', 1, false);


--
-- Name: test_primary_id_seq; Type: SEQUENCE SET; Schema: public; Owner: postgres
--

SELECT pg_catalog.setval('public.test_primary_id_seq', 1, true);


--
-- Name: test_foreign test_foreign_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.test_foreign
    ADD CONSTRAINT test_foreign_pkey PRIMARY KEY (id);


--
-- Name: test_primary test_primary_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.test_primary
    ADD CONSTRAINT test_primary_pkey PRIMARY KEY (id);


--
-- Name: test_foreign test_foreign_test_primary_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.test_foreign
    ADD CONSTRAINT test_foreign_test_primary_id_fkey FOREIGN KEY (test_primary_id) REFERENCES public.test_primary(id) ON DELETE CASCADE;


--
-- Name: postgrex_example; Type: PUBLICATION; Schema: -; Owner: postgres
--

CREATE PUBLICATION postgrex_example WITH (publish = 'insert, update, delete, truncate');


ALTER PUBLICATION postgrex_example OWNER TO postgres;

--
-- Name: postgrex_example distributors; Type: PUBLICATION TABLE; Schema: public; Owner: postgres
--

ALTER PUBLICATION postgrex_example ADD TABLE ONLY public.distributors;


--
-- Name: postgrex_example films; Type: PUBLICATION TABLE; Schema: public; Owner: postgres
--

ALTER PUBLICATION postgrex_example ADD TABLE ONLY public.films;


--
-- Name: postgrex_example test_foreign; Type: PUBLICATION TABLE; Schema: public; Owner: postgres
--

ALTER PUBLICATION postgrex_example ADD TABLE ONLY public.test_foreign;


--
-- Name: postgrex_example test_primary; Type: PUBLICATION TABLE; Schema: public; Owner: postgres
--

ALTER PUBLICATION postgrex_example ADD TABLE ONLY public.test_primary;


--
-- PostgreSQL database dump complete
--

