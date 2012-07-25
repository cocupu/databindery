--
-- PostgreSQL database dump
--

SET statement_timeout = 0;
SET client_encoding = 'UTF8';
SET standard_conforming_strings = on;
SET check_function_bodies = false;
SET client_min_messages = warning;

--
-- Name: plpgsql; Type: EXTENSION; Schema: -; Owner: -
--

CREATE EXTENSION IF NOT EXISTS plpgsql WITH SCHEMA pg_catalog;


--
-- Name: EXTENSION plpgsql; Type: COMMENT; Schema: -; Owner: -
--

COMMENT ON EXTENSION plpgsql IS 'PL/pgSQL procedural language';


--
-- Name: hstore; Type: EXTENSION; Schema: -; Owner: -
--

CREATE EXTENSION IF NOT EXISTS hstore WITH SCHEMA public;


--
-- Name: EXTENSION hstore; Type: COMMENT; Schema: -; Owner: -
--

COMMENT ON EXTENSION hstore IS 'data type for storing sets of (key, value) pairs';


SET search_path = public, pg_catalog;

SET default_tablespace = '';

SET default_with_oids = false;

--
-- Name: change_sets; Type: TABLE; Schema: public; Owner: -; Tablespace: 
--

CREATE TABLE change_sets (
    id integer NOT NULL,
    data hstore,
    pool_id integer,
    identity_id integer,
    parent_id integer,
    created_at timestamp without time zone NOT NULL,
    updated_at timestamp without time zone NOT NULL
);


--
-- Name: change_sets_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE change_sets_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: change_sets_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE change_sets_id_seq OWNED BY change_sets.id;


--
-- Name: chattels; Type: TABLE; Schema: public; Owner: -; Tablespace: 
--

CREATE TABLE chattels (
    id integer NOT NULL,
    attachment_content_type character varying(255),
    attachment_file_name character varying(255),
    attachment_extension character varying(255),
    created_at timestamp without time zone NOT NULL,
    updated_at timestamp without time zone NOT NULL
);


--
-- Name: chattels_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE chattels_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: chattels_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE chattels_id_seq OWNED BY chattels.id;


--
-- Name: exhibits; Type: TABLE; Schema: public; Owner: -; Tablespace: 
--

CREATE TABLE exhibits (
    id integer NOT NULL,
    title character varying(255),
    facets text,
    created_at timestamp without time zone NOT NULL,
    updated_at timestamp without time zone NOT NULL
);


--
-- Name: exhibits_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE exhibits_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: exhibits_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE exhibits_id_seq OWNED BY exhibits.id;


--
-- Name: identities; Type: TABLE; Schema: public; Owner: -; Tablespace: 
--

CREATE TABLE identities (
    id integer NOT NULL,
    name character varying(255),
    login_credential_id integer,
    created_at timestamp without time zone NOT NULL,
    updated_at timestamp without time zone NOT NULL
);


--
-- Name: identities_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE identities_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: identities_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE identities_id_seq OWNED BY identities.id;


--
-- Name: job_log_items; Type: TABLE; Schema: public; Owner: -; Tablespace: 
--

CREATE TABLE job_log_items (
    id integer NOT NULL,
    status character varying(255),
    name character varying(255),
    message text,
    data text,
    parent_id integer,
    type character varying(255),
    created_at timestamp without time zone NOT NULL,
    updated_at timestamp without time zone NOT NULL
);


--
-- Name: job_log_items_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE job_log_items_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: job_log_items_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE job_log_items_id_seq OWNED BY job_log_items.id;


--
-- Name: login_credentials; Type: TABLE; Schema: public; Owner: -; Tablespace: 
--

CREATE TABLE login_credentials (
    id integer NOT NULL,
    email character varying(255) DEFAULT ''::character varying NOT NULL,
    encrypted_password character varying(255) DEFAULT ''::character varying NOT NULL,
    reset_password_token character varying(255),
    reset_password_sent_at timestamp without time zone,
    remember_created_at timestamp without time zone,
    sign_in_count integer DEFAULT 0,
    current_sign_in_at timestamp without time zone,
    last_sign_in_at timestamp without time zone,
    current_sign_in_ip character varying(255),
    last_sign_in_ip character varying(255),
    created_at timestamp without time zone NOT NULL,
    updated_at timestamp without time zone NOT NULL
);


--
-- Name: login_credentials_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE login_credentials_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: login_credentials_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE login_credentials_id_seq OWNED BY login_credentials.id;


--
-- Name: mapping_templates; Type: TABLE; Schema: public; Owner: -; Tablespace: 
--

CREATE TABLE mapping_templates (
    id integer NOT NULL,
    row_start integer,
    models text,
    created_at timestamp without time zone NOT NULL,
    updated_at timestamp without time zone NOT NULL
);


--
-- Name: mapping_templates_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE mapping_templates_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: mapping_templates_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE mapping_templates_id_seq OWNED BY mapping_templates.id;


--
-- Name: models; Type: TABLE; Schema: public; Owner: -; Tablespace: 
--

CREATE TABLE models (
    id integer NOT NULL,
    name character varying(255),
    fields hstore,
    created_at timestamp without time zone NOT NULL,
    updated_at timestamp without time zone NOT NULL
);


--
-- Name: models_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE models_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: models_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE models_id_seq OWNED BY models.id;


--
-- Name: nodes; Type: TABLE; Schema: public; Owner: -; Tablespace: 
--

CREATE TABLE nodes (
    id integer NOT NULL,
    data hstore,
    persistent_id character varying(255),
    parent_id character varying(255),
    pool_id integer,
    identity_id integer,
    created_at timestamp without time zone NOT NULL,
    updated_at timestamp without time zone NOT NULL,
    model_id integer
);


--
-- Name: nodes_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE nodes_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: nodes_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE nodes_id_seq OWNED BY nodes.id;


--
-- Name: pools; Type: TABLE; Schema: public; Owner: -; Tablespace: 
--

CREATE TABLE pools (
    id integer NOT NULL,
    name character varying(255),
    owner_id integer,
    created_at timestamp without time zone NOT NULL,
    updated_at timestamp without time zone NOT NULL,
    head_id integer
);


--
-- Name: pools_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE pools_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: pools_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE pools_id_seq OWNED BY pools.id;


--
-- Name: schema_migrations; Type: TABLE; Schema: public; Owner: -; Tablespace: 
--

CREATE TABLE schema_migrations (
    version character varying(255) NOT NULL
);


--
-- Name: spreadsheet_rows; Type: TABLE; Schema: public; Owner: -; Tablespace: 
--

CREATE TABLE spreadsheet_rows (
    id integer NOT NULL,
    row_number integer,
    worksheet_id integer,
    "values" text,
    created_at timestamp without time zone NOT NULL,
    updated_at timestamp without time zone NOT NULL
);


--
-- Name: spreadsheet_rows_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE spreadsheet_rows_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: spreadsheet_rows_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE spreadsheet_rows_id_seq OWNED BY spreadsheet_rows.id;


--
-- Name: worksheets; Type: TABLE; Schema: public; Owner: -; Tablespace: 
--

CREATE TABLE worksheets (
    id integer NOT NULL,
    name character varying(255),
    spreadsheet_id integer,
    created_at timestamp without time zone NOT NULL,
    updated_at timestamp without time zone NOT NULL
);


--
-- Name: worksheets_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE worksheets_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: worksheets_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE worksheets_id_seq OWNED BY worksheets.id;


--
-- Name: id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE change_sets ALTER COLUMN id SET DEFAULT nextval('change_sets_id_seq'::regclass);


--
-- Name: id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE chattels ALTER COLUMN id SET DEFAULT nextval('chattels_id_seq'::regclass);


--
-- Name: id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE exhibits ALTER COLUMN id SET DEFAULT nextval('exhibits_id_seq'::regclass);


--
-- Name: id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE identities ALTER COLUMN id SET DEFAULT nextval('identities_id_seq'::regclass);


--
-- Name: id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE job_log_items ALTER COLUMN id SET DEFAULT nextval('job_log_items_id_seq'::regclass);


--
-- Name: id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE login_credentials ALTER COLUMN id SET DEFAULT nextval('login_credentials_id_seq'::regclass);


--
-- Name: id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE mapping_templates ALTER COLUMN id SET DEFAULT nextval('mapping_templates_id_seq'::regclass);


--
-- Name: id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE models ALTER COLUMN id SET DEFAULT nextval('models_id_seq'::regclass);


--
-- Name: id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE nodes ALTER COLUMN id SET DEFAULT nextval('nodes_id_seq'::regclass);


--
-- Name: id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE pools ALTER COLUMN id SET DEFAULT nextval('pools_id_seq'::regclass);


--
-- Name: id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE spreadsheet_rows ALTER COLUMN id SET DEFAULT nextval('spreadsheet_rows_id_seq'::regclass);


--
-- Name: id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE worksheets ALTER COLUMN id SET DEFAULT nextval('worksheets_id_seq'::regclass);


--
-- Name: change_sets_pkey; Type: CONSTRAINT; Schema: public; Owner: -; Tablespace: 
--

ALTER TABLE ONLY change_sets
    ADD CONSTRAINT change_sets_pkey PRIMARY KEY (id);


--
-- Name: chattels_pkey; Type: CONSTRAINT; Schema: public; Owner: -; Tablespace: 
--

ALTER TABLE ONLY chattels
    ADD CONSTRAINT chattels_pkey PRIMARY KEY (id);


--
-- Name: exhibits_pkey; Type: CONSTRAINT; Schema: public; Owner: -; Tablespace: 
--

ALTER TABLE ONLY exhibits
    ADD CONSTRAINT exhibits_pkey PRIMARY KEY (id);


--
-- Name: identities_pkey; Type: CONSTRAINT; Schema: public; Owner: -; Tablespace: 
--

ALTER TABLE ONLY identities
    ADD CONSTRAINT identities_pkey PRIMARY KEY (id);


--
-- Name: job_log_items_pkey; Type: CONSTRAINT; Schema: public; Owner: -; Tablespace: 
--

ALTER TABLE ONLY job_log_items
    ADD CONSTRAINT job_log_items_pkey PRIMARY KEY (id);


--
-- Name: login_credentials_pkey; Type: CONSTRAINT; Schema: public; Owner: -; Tablespace: 
--

ALTER TABLE ONLY login_credentials
    ADD CONSTRAINT login_credentials_pkey PRIMARY KEY (id);


--
-- Name: mapping_templates_pkey; Type: CONSTRAINT; Schema: public; Owner: -; Tablespace: 
--

ALTER TABLE ONLY mapping_templates
    ADD CONSTRAINT mapping_templates_pkey PRIMARY KEY (id);


--
-- Name: models_pkey; Type: CONSTRAINT; Schema: public; Owner: -; Tablespace: 
--

ALTER TABLE ONLY models
    ADD CONSTRAINT models_pkey PRIMARY KEY (id);


--
-- Name: nodes_pkey; Type: CONSTRAINT; Schema: public; Owner: -; Tablespace: 
--

ALTER TABLE ONLY nodes
    ADD CONSTRAINT nodes_pkey PRIMARY KEY (id);


--
-- Name: pools_pkey; Type: CONSTRAINT; Schema: public; Owner: -; Tablespace: 
--

ALTER TABLE ONLY pools
    ADD CONSTRAINT pools_pkey PRIMARY KEY (id);


--
-- Name: spreadsheet_rows_pkey; Type: CONSTRAINT; Schema: public; Owner: -; Tablespace: 
--

ALTER TABLE ONLY spreadsheet_rows
    ADD CONSTRAINT spreadsheet_rows_pkey PRIMARY KEY (id);


--
-- Name: worksheets_pkey; Type: CONSTRAINT; Schema: public; Owner: -; Tablespace: 
--

ALTER TABLE ONLY worksheets
    ADD CONSTRAINT worksheets_pkey PRIMARY KEY (id);


--
-- Name: change_sets_gist_data; Type: INDEX; Schema: public; Owner: -; Tablespace: 
--

CREATE INDEX change_sets_gist_data ON change_sets USING gist (data);


--
-- Name: index_login_credentials_on_email; Type: INDEX; Schema: public; Owner: -; Tablespace: 
--

CREATE UNIQUE INDEX index_login_credentials_on_email ON login_credentials USING btree (email);


--
-- Name: index_login_credentials_on_reset_password_token; Type: INDEX; Schema: public; Owner: -; Tablespace: 
--

CREATE UNIQUE INDEX index_login_credentials_on_reset_password_token ON login_credentials USING btree (reset_password_token);


--
-- Name: index_nodes_on_model_id; Type: INDEX; Schema: public; Owner: -; Tablespace: 
--

CREATE INDEX index_nodes_on_model_id ON nodes USING btree (model_id);


--
-- Name: nodes_gist_data; Type: INDEX; Schema: public; Owner: -; Tablespace: 
--

CREATE INDEX nodes_gist_data ON nodes USING gist (data);


--
-- Name: unique_schema_migrations; Type: INDEX; Schema: public; Owner: -; Tablespace: 
--

CREATE UNIQUE INDEX unique_schema_migrations ON schema_migrations USING btree (version);


--
-- Name: change_sets_identity_id_fk; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY change_sets
    ADD CONSTRAINT change_sets_identity_id_fk FOREIGN KEY (identity_id) REFERENCES identities(id);


--
-- Name: change_sets_parent_id_fk; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY change_sets
    ADD CONSTRAINT change_sets_parent_id_fk FOREIGN KEY (parent_id) REFERENCES change_sets(id);


--
-- Name: change_sets_pool_id_fk; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY change_sets
    ADD CONSTRAINT change_sets_pool_id_fk FOREIGN KEY (pool_id) REFERENCES pools(id);


--
-- Name: identities_login_credential_id_fk; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY identities
    ADD CONSTRAINT identities_login_credential_id_fk FOREIGN KEY (login_credential_id) REFERENCES login_credentials(id);


--
-- Name: nodes_identity_id_fk; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY nodes
    ADD CONSTRAINT nodes_identity_id_fk FOREIGN KEY (identity_id) REFERENCES identities(id);


--
-- Name: nodes_pool_id_fk; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY nodes
    ADD CONSTRAINT nodes_pool_id_fk FOREIGN KEY (pool_id) REFERENCES pools(id);


--
-- Name: pools_head_id_fk; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY pools
    ADD CONSTRAINT pools_head_id_fk FOREIGN KEY (head_id) REFERENCES change_sets(id);


--
-- Name: pools_owner_id_fk; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY pools
    ADD CONSTRAINT pools_owner_id_fk FOREIGN KEY (owner_id) REFERENCES identities(id);


--
-- PostgreSQL database dump complete
--

INSERT INTO schema_migrations (version) VALUES ('20120712154638');

INSERT INTO schema_migrations (version) VALUES ('20120712190103');

INSERT INTO schema_migrations (version) VALUES ('20120712193715');

INSERT INTO schema_migrations (version) VALUES ('20120712193817');

INSERT INTO schema_migrations (version) VALUES ('20120712193900');

INSERT INTO schema_migrations (version) VALUES ('20120712195104');

INSERT INTO schema_migrations (version) VALUES ('20120712195528');

INSERT INTO schema_migrations (version) VALUES ('20120724185116');

INSERT INTO schema_migrations (version) VALUES ('20120724185452');

INSERT INTO schema_migrations (version) VALUES ('20120724185825');

INSERT INTO schema_migrations (version) VALUES ('20120724190302');

INSERT INTO schema_migrations (version) VALUES ('20120724191351');

INSERT INTO schema_migrations (version) VALUES ('20120724192025');

INSERT INTO schema_migrations (version) VALUES ('20120724192751');

INSERT INTO schema_migrations (version) VALUES ('20120724200226');