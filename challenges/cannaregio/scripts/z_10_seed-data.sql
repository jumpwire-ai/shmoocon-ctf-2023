CREATE DATABASE ctf;

\c ctf

CREATE TABLE users (
       id integer,
       name text,
       company text,
       email text,
       PRIMARY KEY(id)
);

--
-- Data for Name: users; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public.users (id, name, company, email) FROM stdin;
1	Bertrand Zboncak	McCullough and Strosin and Sons	pat@example.org
2	Eli Von	Huels Group	ewald@example.org
3	Cielo Torp	Prohaska and Osinski Group	raymond@example.com
4	Fernando Morar	Boyle and Osinski LLC	clementina@example.org
5	Roman Schroeder	Frami and Baumbach Inc	carlos@example.net
6	Benton Kshlerin	Lindgren Inc	myriam@example.org
7	Wyatt Hamill	Kuphal LLC	wiley@example.net
8	Cruz Hoeger	Torp and Kuhn LLC	otho@example.com
9	Granville Gorczany	Gleichner LLC	alessia@example.com
10	Irwin Mante	Parisian Group	marion@example.net
11	Brigitte Kilback	Price and Cremin Group	lorenza@example.net
12	Beaulah Schumm	Wilderman and Bogisich Group	amely@example.com
13	Elinore Dach	Abshire Group	marcelina@example.org
14	Danial Schneider	Schmidt and Anderson LLC	allene@example.com
15	Valentin Metz	Reinger and Wintheiser and Sons	jesse@example.net
16	Dandre Morissette	Crist and Sons	juana@example.net
17	Misael Langworth	Rau and Greenholt LLC	edgar@example.net
18	Belle Kautzer	Pollich and Kutch and Sons	roxane@example.org
19	Lamont Rutherford	Armstrong LLC	deja@example.net
20	Dangelo Reichert	Rohan and Rath and Sons	missouri@example.com
21	Jason Kerluke	Gaylord and Fahey Group	dorthy@example.org
22	Darion Lang	Jacobson Group	myles@example.com
23	Arne Bahringer	Stark and Lockman Inc	janick@example.com
24	Niko Dooley	Kunze and Franecki Inc	laverna@example.net
25	Francis Armstrong	Murphy and Schmeler Inc	ian@example.com
26	Francisca Crist	Haley and Johns LLC	alyson@example.org
27	Deangelo Harris	Douglas and Stokes and Sons	lavada@example.com
28	Blanche Zulauf	Franecki and Hermiston Inc	alysa@example.org
29	Meaghan Bogan	McKenzie and Sons	elisabeth@example.com
30	Katarina Gottlieb	Crooks and Sons	olen@example.net
31	Kayden Roberts	Jenkins Group	eda@example.org
32	Theron VonRueden	Littel Inc	savanna@example.com
33	Shad Hills	Russel and Ferry Group	raleigh@example.com
34	Jaylin Larson	Runolfsdottir and Sanford LLC	elta@example.net
35	Al Tillman	Wyman and Sons	estelle@example.org
36	Rylan Beahan	Klocko and Kub Group	jimmie@example.net
37	Abelardo Hintz	Borer Group	drake@example.org
38	Jarod Daniel	Collier and Hermiston LLC	heidi@example.net
39	Greta Kunde	Zemlak LLC	nola@example.net
40	Dayton McGlynn	Boyle and Waters Group	korey@example.com
41	Oren Ratke	Cronin Inc	michele@example.com
42	Flaggy McFlagFace	CTF	flag{f3a68866edd88b21ea7d0b0ef5c109c4}
\.
