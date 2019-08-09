BEGIN;

--
-- Name: object_type; Type: TYPE; Schema: public; Owner: -
--

CREATE TYPE public.object_type AS ENUM (
    'link',
    'blog',
    'picture',
    'profile',
    'poll',
    'video',
    'forum'
);


--
-- Name: plus_minus_type; Type: TYPE; Schema: public; Owner: -
--

CREATE TYPE public.plus_minus_type AS ENUM (
    'plus',
    'minus'
);


--
-- Name: user_token_type; Type: TYPE; Schema: public; Owner: -
--

CREATE TYPE public.user_token_type AS ENUM (
    'reg',
    'forgot'
);


--
-- Name: view_type; Type: TYPE; Schema: public; Owner: -
--

CREATE TYPE public.view_type AS ENUM (
    'internal',
    'external'
);


SET default_tablespace = '';

SET default_with_oids = false;

--
-- Name: admin; Type: TABLE; Schema: public; Owner: -; Tablespace:
--

CREATE TABLE public.admin (
    admin_id integer NOT NULL,
    role character varying(255) NOT NULL
);


--
-- Name: admin_admin_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public.admin_admin_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: admin_admin_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE public.admin_admin_id_seq OWNED BY public.admin.admin_id;


--
-- Name: admin_log; Type: TABLE; Schema: public; Owner: -; Tablespace:
--

CREATE TABLE public.admin_log (
    log_id integer NOT NULL,
    admin_id integer NOT NULL,
    action character varying(255) NOT NULL,
    reason character varying(512) NOT NULL,
    bulk text,
    user_id integer NOT NULL,
    comment_id integer,
    object_id integer,
    created timestamp without time zone DEFAULT now() NOT NULL,
    other text
);


--
-- Name: admin_log_log_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public.admin_log_log_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: admin_log_log_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE public.admin_log_log_id_seq OWNED BY public.admin_log.log_id;


--
-- Name: object_type_base; Type: TABLE; Schema: public; Owner: -; Tablespace:
--

CREATE TABLE public.object_type_base (
    title character varying(255) NOT NULL,
    description character varying(1000) NOT NULL
);


--
-- Name: blog; Type: TABLE; Schema: public; Owner: -; Tablespace:
--

CREATE TABLE public.blog (
    blog_id integer NOT NULL,
    picture_id integer NOT NULL,
    details text NOT NULL
)
INHERITS (public.object_type_base);


--
-- Name: cms; Type: TABLE; Schema: public; Owner: -; Tablespace:
--

CREATE TABLE public.cms (
    cms_id integer NOT NULL,
    url character varying(255) NOT NULL,
    content text NOT NULL,
    user_id integer NOT NULL,
    revision integer NOT NULL,
    created timestamp without time zone DEFAULT now() NOT NULL,
    title character varying(255) NOT NULL,
    comment character varying(255) NOT NULL,
    deleted smallint DEFAULT 0 NOT NULL,
    system smallint DEFAULT 0 NOT NULL,
    nowrapper smallint DEFAULT 0 NOT NULL
);


--
-- Name: cms_cms_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public.cms_cms_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: cms_cms_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE public.cms_cms_id_seq OWNED BY public.cms.cms_id;


--
-- Name: comments; Type: TABLE; Schema: public; Owner: -; Tablespace:
--

CREATE TABLE public.comments (
    id integer NOT NULL,
    user_id integer NOT NULL,
    comment text NOT NULL,
    created timestamp without time zone DEFAULT now() NOT NULL,
    object_id integer NOT NULL,
    deleted smallint DEFAULT 0 NOT NULL,
    number integer NOT NULL,
    updated timestamp without time zone DEFAULT now() NOT NULL,
    plus bigint DEFAULT 0 NOT NULL,
    minus bigint DEFAULT 0 NOT NULL
);


--
-- Name: comments_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public.comments_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: comments_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE public.comments_id_seq OWNED BY public.comments.id;


--
-- Name: forum; Type: TABLE; Schema: public; Owner: -; Tablespace:
--

CREATE TABLE public.forum (
    forum_id integer NOT NULL,
    picture_id integer NOT NULL,
    details text NOT NULL
)
INHERITS (public.object_type_base);


--
-- Name: link; Type: TABLE; Schema: public; Owner: -; Tablespace:
--

CREATE TABLE public.link (
    link_id integer NOT NULL,
    picture_id integer NOT NULL,
    url character varying(400) NOT NULL
)
INHERITS (public.object_type_base);


--
-- Name: lotto; Type: TABLE; Schema: public; Owner: -; Tablespace:
--

CREATE TABLE public.lotto (
    lotto_id integer NOT NULL,
    created timestamp without time zone DEFAULT now() NOT NULL,
    user_id integer NOT NULL,
    number smallint NOT NULL,
    confirmed smallint DEFAULT 0 NOT NULL,
    winner smallint DEFAULT 0 NOT NULL,
    txn_id character varying(19) DEFAULT NULL::character varying
);


--
-- Name: lotto_lotto_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public.lotto_lotto_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: lotto_lotto_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE public.lotto_lotto_id_seq OWNED BY public.lotto.lotto_id;


--
-- Name: object; Type: TABLE; Schema: public; Owner: -; Tablespace:
--

CREATE TABLE public.object (
    object_id integer NOT NULL,
    type public.object_type NOT NULL,
    created timestamp without time zone DEFAULT now() NOT NULL,
    promoted timestamp without time zone,
    user_id integer NOT NULL,
    nsfw smallint DEFAULT 0 NOT NULL,
    views integer DEFAULT 0 NOT NULL,
    plus integer DEFAULT 0 NOT NULL,
    minus integer DEFAULT 0 NOT NULL,
    comments integer DEFAULT 0 NOT NULL,
    deleted smallint DEFAULT 0 NOT NULL,
    score integer,
    locked smallint DEFAULT 0 NOT NULL
);


--
-- Name: object_object_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public.object_object_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: object_object_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE public.object_object_id_seq OWNED BY public.object.object_id;


--
-- Name: picture; Type: TABLE; Schema: public; Owner: -; Tablespace:
--

CREATE TABLE public.picture (
    picture_id integer NOT NULL,
    filename character varying(300) NOT NULL,
    x integer NOT NULL,
    y integer NOT NULL,
    size numeric NOT NULL,
    sha512sum character varying(128) NOT NULL
)
INHERITS (public.object_type_base);


--
-- Name: plus_minus; Type: TABLE; Schema: public; Owner: -; Tablespace:
--

CREATE TABLE public.plus_minus (
    id integer NOT NULL,
    type public.plus_minus_type NOT NULL,
    object_id integer NOT NULL,
    user_id integer NOT NULL,
    comment_id integer,
    created timestamp without time zone DEFAULT now() NOT NULL
);


--
-- Name: plus_minus_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public.plus_minus_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: plus_minus_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE public.plus_minus_id_seq OWNED BY public.plus_minus.id;


--
-- Name: poll; Type: TABLE; Schema: public; Owner: -; Tablespace:
--

CREATE TABLE public.poll (
    poll_id integer NOT NULL,
    picture_id integer NOT NULL,
    end_date timestamp without time zone,
    votes integer DEFAULT 0 NOT NULL
)
INHERITS (public.object_type_base);


--
-- Name: poll_answer; Type: TABLE; Schema: public; Owner: -; Tablespace:
--

CREATE TABLE public.poll_answer (
    answer_id integer NOT NULL,
    poll_id integer NOT NULL,
    answer character varying(255) NOT NULL,
    votes integer DEFAULT 0 NOT NULL
);


--
-- Name: poll_answer_answer_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public.poll_answer_answer_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: poll_answer_answer_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE public.poll_answer_answer_id_seq OWNED BY public.poll_answer.answer_id;


--
-- Name: poll_vote; Type: TABLE; Schema: public; Owner: -; Tablespace:
--

CREATE TABLE public.poll_vote (
    vote_id integer NOT NULL,
    answer_id integer NOT NULL,
    user_id integer NOT NULL
);


--
-- Name: poll_vote_vote_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public.poll_vote_vote_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: poll_vote_vote_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE public.poll_vote_vote_id_seq OWNED BY public.poll_vote.vote_id;


--
-- Name: profile; Type: TABLE; Schema: public; Owner: -; Tablespace:
--

CREATE TABLE public.profile (
    profile_id integer NOT NULL,
    details text NOT NULL
);


--
-- Name: tag_objects; Type: TABLE; Schema: public; Owner: -; Tablespace:
--

CREATE TABLE public.tag_objects (
    object_tag_id integer NOT NULL,
    tag_id integer NOT NULL,
    object_id integer NOT NULL
);


--
-- Name: tag_objects_object_tag_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public.tag_objects_object_tag_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: tag_objects_object_tag_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE public.tag_objects_object_tag_id_seq OWNED BY public.tag_objects.object_tag_id;


--
-- Name: tags; Type: TABLE; Schema: public; Owner: -; Tablespace:
--

CREATE TABLE public.tags (
    tag_id integer NOT NULL,
    tag character varying(30) NOT NULL,
    stem character varying(30) NOT NULL
);


--
-- Name: tags_tag_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public.tags_tag_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: tags_tag_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE public.tags_tag_id_seq OWNED BY public.tags.tag_id;


--
-- Name: user; Type: TABLE; Schema: public; Owner: -; Tablespace:
--

CREATE TABLE public."user" (
    user_id integer NOT NULL,
    username character varying(255) NOT NULL,
    join_date timestamp without time zone DEFAULT now() NOT NULL,
    email character varying(255) NOT NULL,
    password character varying(128) NOT NULL,
    confirmed smallint DEFAULT 0 NOT NULL,
    deleted smallint DEFAULT 0 NOT NULL,
    paypal character varying(255),
    avatar character varying(10),
    tcs integer
);


--
-- Name: user_admin; Type: TABLE; Schema: public; Owner: -; Tablespace:
--

CREATE TABLE public.user_admin (
    user_id integer NOT NULL,
    admin_id integer NOT NULL
);


--
-- Name: user_tokens; Type: TABLE; Schema: public; Owner: -; Tablespace:
--

CREATE TABLE public.user_tokens (
    token_id integer NOT NULL,
    user_id integer NOT NULL,
    token character varying(516) NOT NULL,
    expires timestamp without time zone DEFAULT now() NOT NULL,
    type public.user_token_type NOT NULL
);


--
-- Name: user_tokens_token_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public.user_tokens_token_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: user_tokens_token_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE public.user_tokens_token_id_seq OWNED BY public.user_tokens.token_id;


--
-- Name: user_user_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public.user_user_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: user_user_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE public.user_user_id_seq OWNED BY public."user".user_id;


--
-- Name: video; Type: TABLE; Schema: public; Owner: -; Tablespace:
--

CREATE TABLE public.video (
    video_id integer NOT NULL,
    picture_id integer NOT NULL,
    url character varying(400) NOT NULL
)
INHERITS (public.object_type_base);


--
-- Name: views; Type: TABLE; Schema: public; Owner: -; Tablespace:
--

CREATE TABLE public.views (
    view_id integer NOT NULL,
    ip inet NOT NULL,
    object_id integer,
    session_id character varying(128) NOT NULL,
    user_id integer,
    created timestamp without time zone DEFAULT now() NOT NULL,
    type public.view_type DEFAULT 'internal'::public.view_type NOT NULL
);


--
-- Name: views_view_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public.views_view_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: views_view_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE public.views_view_id_seq OWNED BY public.views.view_id;


--
-- Name: admin_id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.admin ALTER COLUMN admin_id SET DEFAULT nextval('public.admin_admin_id_seq'::regclass);


--
-- Name: log_id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.admin_log ALTER COLUMN log_id SET DEFAULT nextval('public.admin_log_log_id_seq'::regclass);


--
-- Name: cms_id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.cms ALTER COLUMN cms_id SET DEFAULT nextval('public.cms_cms_id_seq'::regclass);


--
-- Name: id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.comments ALTER COLUMN id SET DEFAULT nextval('public.comments_id_seq'::regclass);


--
-- Name: lotto_id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.lotto ALTER COLUMN lotto_id SET DEFAULT nextval('public.lotto_lotto_id_seq'::regclass);


--
-- Name: object_id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.object ALTER COLUMN object_id SET DEFAULT nextval('public.object_object_id_seq'::regclass);


--
-- Name: id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.plus_minus ALTER COLUMN id SET DEFAULT nextval('public.plus_minus_id_seq'::regclass);


--
-- Name: answer_id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.poll_answer ALTER COLUMN answer_id SET DEFAULT nextval('public.poll_answer_answer_id_seq'::regclass);


--
-- Name: vote_id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.poll_vote ALTER COLUMN vote_id SET DEFAULT nextval('public.poll_vote_vote_id_seq'::regclass);


--
-- Name: object_tag_id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.tag_objects ALTER COLUMN object_tag_id SET DEFAULT nextval('public.tag_objects_object_tag_id_seq'::regclass);


--
-- Name: tag_id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.tags ALTER COLUMN tag_id SET DEFAULT nextval('public.tags_tag_id_seq'::regclass);


--
-- Name: user_id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY public."user" ALTER COLUMN user_id SET DEFAULT nextval('public.user_user_id_seq'::regclass);


--
-- Name: token_id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.user_tokens ALTER COLUMN token_id SET DEFAULT nextval('public.user_tokens_token_id_seq'::regclass);


--
-- Name: view_id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.views ALTER COLUMN view_id SET DEFAULT nextval('public.views_view_id_seq'::regclass);


--
-- Name: admin_log_pkey; Type: CONSTRAINT; Schema: public; Owner: -; Tablespace:
--

ALTER TABLE ONLY public.admin_log
    ADD CONSTRAINT admin_log_pkey PRIMARY KEY (log_id);


--
-- Name: admin_pkey; Type: CONSTRAINT; Schema: public; Owner: -; Tablespace:
--

ALTER TABLE ONLY public.admin
    ADD CONSTRAINT admin_pkey PRIMARY KEY (admin_id);


--
-- Name: blog_pkey; Type: CONSTRAINT; Schema: public; Owner: -; Tablespace:
--

ALTER TABLE ONLY public.blog
    ADD CONSTRAINT blog_pkey PRIMARY KEY (blog_id);


--
-- Name: cms_pkey; Type: CONSTRAINT; Schema: public; Owner: -; Tablespace:
--

ALTER TABLE ONLY public.cms
    ADD CONSTRAINT cms_pkey PRIMARY KEY (cms_id);


--
-- Name: comments_pkey; Type: CONSTRAINT; Schema: public; Owner: -; Tablespace:
--

ALTER TABLE ONLY public.comments
    ADD CONSTRAINT comments_pkey PRIMARY KEY (id);


--
-- Name: forum_pkey; Type: CONSTRAINT; Schema: public; Owner: -; Tablespace:
--

ALTER TABLE ONLY public.forum
    ADD CONSTRAINT forum_pkey PRIMARY KEY (forum_id);


--
-- Name: link_pkey; Type: CONSTRAINT; Schema: public; Owner: -; Tablespace:
--

ALTER TABLE ONLY public.link
    ADD CONSTRAINT link_pkey PRIMARY KEY (link_id);


--
-- Name: lotto_pkey; Type: CONSTRAINT; Schema: public; Owner: -; Tablespace:
--

ALTER TABLE ONLY public.lotto
    ADD CONSTRAINT lotto_pkey PRIMARY KEY (lotto_id);


--
-- Name: object_pkey; Type: CONSTRAINT; Schema: public; Owner: -; Tablespace:
--

ALTER TABLE ONLY public.object
    ADD CONSTRAINT object_pkey PRIMARY KEY (object_id);


--
-- Name: picture_pkey; Type: CONSTRAINT; Schema: public; Owner: -; Tablespace:
--

ALTER TABLE ONLY public.picture
    ADD CONSTRAINT picture_pkey PRIMARY KEY (picture_id);


--
-- Name: plus_minus-user_id-comment_id-type:unique; Type: CONSTRAINT; Schema: public; Owner: -; Tablespace:
--

ALTER TABLE ONLY public.plus_minus
    ADD CONSTRAINT "plus_minus-user_id-comment_id-type:unique" UNIQUE (user_id, comment_id, type);


--
-- Name: plus_minus-user_id-object_id-type:unique; Type: CONSTRAINT; Schema: public; Owner: -; Tablespace:
--

ALTER TABLE ONLY public.plus_minus
    ADD CONSTRAINT "plus_minus-user_id-object_id-type:unique" UNIQUE (user_id, object_id, type);


--
-- Name: plus_minus_pkey; Type: CONSTRAINT; Schema: public; Owner: -; Tablespace:
--

ALTER TABLE ONLY public.plus_minus
    ADD CONSTRAINT plus_minus_pkey PRIMARY KEY (id);


--
-- Name: poll_answer_pkey; Type: CONSTRAINT; Schema: public; Owner: -; Tablespace:
--

ALTER TABLE ONLY public.poll_answer
    ADD CONSTRAINT poll_answer_pkey PRIMARY KEY (answer_id);


--
-- Name: poll_pkey; Type: CONSTRAINT; Schema: public; Owner: -; Tablespace:
--

ALTER TABLE ONLY public.poll
    ADD CONSTRAINT poll_pkey PRIMARY KEY (poll_id);


--
-- Name: poll_vote_pkey; Type: CONSTRAINT; Schema: public; Owner: -; Tablespace:
--

ALTER TABLE ONLY public.poll_vote
    ADD CONSTRAINT poll_vote_pkey PRIMARY KEY (vote_id);


--
-- Name: profile_pkey; Type: CONSTRAINT; Schema: public; Owner: -; Tablespace:
--

ALTER TABLE ONLY public.profile
    ADD CONSTRAINT profile_pkey PRIMARY KEY (profile_id);


--
-- Name: tag_objects_pkey; Type: CONSTRAINT; Schema: public; Owner: -; Tablespace:
--

ALTER TABLE ONLY public.tag_objects
    ADD CONSTRAINT tag_objects_pkey PRIMARY KEY (object_tag_id);


--
-- Name: tags_pkey; Type: CONSTRAINT; Schema: public; Owner: -; Tablespace:
--

ALTER TABLE ONLY public.tags
    ADD CONSTRAINT tags_pkey PRIMARY KEY (tag_id);


--
-- Name: user-username; Type: CONSTRAINT; Schema: public; Owner: -; Tablespace:
--

ALTER TABLE ONLY public."user"
    ADD CONSTRAINT "user-username" UNIQUE (username);


--
-- Name: user_admin_pkey; Type: CONSTRAINT; Schema: public; Owner: -; Tablespace:
--

ALTER TABLE ONLY public.user_admin
    ADD CONSTRAINT user_admin_pkey PRIMARY KEY (user_id, admin_id);


--
-- Name: user_pkey; Type: CONSTRAINT; Schema: public; Owner: -; Tablespace:
--

ALTER TABLE ONLY public."user"
    ADD CONSTRAINT user_pkey PRIMARY KEY (user_id);


--
-- Name: user_tokens_pkey; Type: CONSTRAINT; Schema: public; Owner: -; Tablespace:
--

ALTER TABLE ONLY public.user_tokens
    ADD CONSTRAINT user_tokens_pkey PRIMARY KEY (token_id);


--
-- Name: video_pkey; Type: CONSTRAINT; Schema: public; Owner: -; Tablespace:
--

ALTER TABLE ONLY public.video
    ADD CONSTRAINT video_pkey PRIMARY KEY (video_id);


--
-- Name: views_pkey; Type: CONSTRAINT; Schema: public; Owner: -; Tablespace:
--

ALTER TABLE ONLY public.views
    ADD CONSTRAINT views_pkey PRIMARY KEY (view_id);


--
-- Name: admin_log-admin_id; Type: INDEX; Schema: public; Owner: -; Tablespace:
--

CREATE INDEX "admin_log-admin_id" ON public.admin_log USING btree (admin_id);


--
-- Name: admin_log-comment_id; Type: INDEX; Schema: public; Owner: -; Tablespace:
--

CREATE INDEX "admin_log-comment_id" ON public.admin_log USING btree (comment_id);


--
-- Name: admin_log-object_id; Type: INDEX; Schema: public; Owner: -; Tablespace:
--

CREATE INDEX "admin_log-object_id" ON public.admin_log USING btree (object_id);


--
-- Name: admin_log-user_id; Type: INDEX; Schema: public; Owner: -; Tablespace:
--

CREATE INDEX "admin_log-user_id" ON public.admin_log USING btree (user_id);


--
-- Name: blog-picture_id; Type: INDEX; Schema: public; Owner: -; Tablespace:
--

CREATE INDEX "blog-picture_id" ON public.blog USING btree (picture_id);


--
-- Name: cms-deleted; Type: INDEX; Schema: public; Owner: -; Tablespace:
--

CREATE INDEX "cms-deleted" ON public.cms USING btree (deleted);


--
-- Name: cms-revision; Type: INDEX; Schema: public; Owner: -; Tablespace:
--

CREATE INDEX "cms-revision" ON public.cms USING btree (revision);


--
-- Name: cms-url:varchar_pattern_ops; Type: INDEX; Schema: public; Owner: -; Tablespace:
--

CREATE INDEX "cms-url:varchar_pattern_ops" ON public.cms USING btree (url varchar_pattern_ops);


--
-- Name: cms-user_id; Type: INDEX; Schema: public; Owner: -; Tablespace:
--

CREATE INDEX "cms-user_id" ON public.cms USING btree (user_id);


--
-- Name: comments-created-object_id-user_id-deleted; Type: INDEX; Schema: public; Owner: -; Tablespace:
--

CREATE INDEX "comments-created-object_id-user_id-deleted" ON public.comments USING btree (created, object_id, user_id, deleted);


--
-- Name: comments-object_id; Type: INDEX; Schema: public; Owner: -; Tablespace:
--

CREATE INDEX "comments-object_id" ON public.comments USING btree (object_id);


--
-- Name: comments-user_id; Type: INDEX; Schema: public; Owner: -; Tablespace:
--

CREATE INDEX "comments-user_id" ON public.comments USING btree (user_id);


--
-- Name: forum-picture_id; Type: INDEX; Schema: public; Owner: -; Tablespace:
--

CREATE INDEX "forum-picture_id" ON public.forum USING btree (picture_id);


--
-- Name: link-picture_id; Type: INDEX; Schema: public; Owner: -; Tablespace:
--

CREATE INDEX "link-picture_id" ON public.link USING btree (picture_id);


--
-- Name: lotto-confirmed-created; Type: INDEX; Schema: public; Owner: -; Tablespace:
--

CREATE INDEX "lotto-confirmed-created" ON public.lotto USING btree (confirmed, created);


--
-- Name: lotto-created; Type: INDEX; Schema: public; Owner: -; Tablespace:
--

CREATE INDEX "lotto-created" ON public.lotto USING btree (created);


--
-- Name: lotto-txn_id; Type: INDEX; Schema: public; Owner: -; Tablespace:
--

CREATE INDEX "lotto-txn_id" ON public.lotto USING btree (txn_id);


--
-- Name: lotto-user_id; Type: INDEX; Schema: public; Owner: -; Tablespace:
--

CREATE INDEX "lotto-user_id" ON public.lotto USING btree (user_id);


--
-- Name: lotto-winner-created; Type: INDEX; Schema: public; Owner: -; Tablespace:
--

CREATE INDEX "lotto-winner-created" ON public.lotto USING btree (winner, created);


--
-- Name: object-created; Type: INDEX; Schema: public; Owner: -; Tablespace:
--

CREATE INDEX "object-created" ON public.object USING btree (created);


--
-- Name: object-nsfw-type-promoted-created-deleted; Type: INDEX; Schema: public; Owner: -; Tablespace:
--

CREATE INDEX "object-nsfw-type-promoted-created-deleted" ON public.object USING btree (nsfw, type, promoted, created, deleted);


--
-- Name: object-promoted; Type: INDEX; Schema: public; Owner: -; Tablespace:
--

CREATE INDEX "object-promoted" ON public.object USING btree (promoted);


--
-- Name: object-type-user_id-nsfw-created; Type: INDEX; Schema: public; Owner: -; Tablespace:
--

CREATE INDEX "object-type-user_id-nsfw-created" ON public.object USING btree (type, user_id, nsfw, created);


--
-- Name: object-user_id; Type: INDEX; Schema: public; Owner: -; Tablespace:
--

CREATE INDEX "object-user_id" ON public.object USING btree (user_id);


--
-- Name: picture-filename:varchar_pattern_ops; Type: INDEX; Schema: public; Owner: -; Tablespace:
--

CREATE INDEX "picture-filename:varchar_pattern_ops" ON public.picture USING btree (filename varchar_pattern_ops);


--
-- Name: picture-sha512sum:; Type: INDEX; Schema: public; Owner: -; Tablespace:
--

CREATE INDEX "picture-sha512sum:" ON public.picture USING btree (sha512sum varchar_pattern_ops);


--
-- Name: plus_minus-comment_id; Type: INDEX; Schema: public; Owner: -; Tablespace:
--

CREATE INDEX "plus_minus-comment_id" ON public.plus_minus USING btree (comment_id);


--
-- Name: plus_minus-object_id; Type: INDEX; Schema: public; Owner: -; Tablespace:
--

CREATE INDEX "plus_minus-object_id" ON public.plus_minus USING btree (object_id);


--
-- Name: plus_minus-type; Type: INDEX; Schema: public; Owner: -; Tablespace:
--

CREATE INDEX "plus_minus-type" ON public.plus_minus USING btree (type);


--
-- Name: plus_minus-user_id; Type: INDEX; Schema: public; Owner: -; Tablespace:
--

CREATE INDEX "plus_minus-user_id" ON public.plus_minus USING btree (user_id);


--
-- Name: poll-picture_id; Type: INDEX; Schema: public; Owner: -; Tablespace:
--

CREATE INDEX "poll-picture_id" ON public.poll USING btree (picture_id);


--
-- Name: poll_answer-poll_id; Type: INDEX; Schema: public; Owner: -; Tablespace:
--

CREATE INDEX "poll_answer-poll_id" ON public.poll_answer USING btree (poll_id);


--
-- Name: poll_vote-answer_id; Type: INDEX; Schema: public; Owner: -; Tablespace:
--

CREATE INDEX "poll_vote-answer_id" ON public.poll_vote USING btree (answer_id);


--
-- Name: poll_vote-user_id; Type: INDEX; Schema: public; Owner: -; Tablespace:
--

CREATE INDEX "poll_vote-user_id" ON public.poll_vote USING btree (user_id);


--
-- Name: tag_objects-object_id; Type: INDEX; Schema: public; Owner: -; Tablespace:
--

CREATE INDEX "tag_objects-object_id" ON public.tag_objects USING btree (object_id);


--
-- Name: tag_objects-tag_id; Type: INDEX; Schema: public; Owner: -; Tablespace:
--

CREATE INDEX "tag_objects-tag_id" ON public.tag_objects USING btree (tag_id);


--
-- Name: tags-stem:varchar_pattern_ops; Type: INDEX; Schema: public; Owner: -; Tablespace:
--

CREATE INDEX "tags-stem:varchar_pattern_ops" ON public.tags USING btree (stem varchar_pattern_ops);


--
-- Name: tags-tag:varchar_pattern_ops; Type: INDEX; Schema: public; Owner: -; Tablespace:
--

CREATE INDEX "tags-tag:varchar_pattern_ops" ON public.tags USING btree (tag varchar_pattern_ops);


--
-- Name: user-lower(email):varchar_pattern_ops; Type: INDEX; Schema: public; Owner: -; Tablespace:
--

CREATE INDEX "user-lower(email):varchar_pattern_ops" ON public."user" USING btree (lower((email)::text) varchar_pattern_ops);


--
-- Name: user-lower(username):varchar_pattern_ops; Type: INDEX; Schema: public; Owner: -; Tablespace:
--

CREATE INDEX "user-lower(username):varchar_pattern_ops" ON public."user" USING btree (lower((username)::text) varchar_pattern_ops);


--
-- Name: user_admin-admin_id; Type: INDEX; Schema: public; Owner: -; Tablespace:
--

CREATE INDEX "user_admin-admin_id" ON public.user_admin USING btree (admin_id);


--
-- Name: user_tokens-user_id; Type: INDEX; Schema: public; Owner: -; Tablespace:
--

CREATE INDEX "user_tokens-user_id" ON public.user_tokens USING btree (user_id);


--
-- Name: video-picture_id; Type: INDEX; Schema: public; Owner: -; Tablespace:
--

CREATE INDEX "video-picture_id" ON public.video USING btree (picture_id);


--
-- Name: views-created; Type: INDEX; Schema: public; Owner: -; Tablespace:
--

CREATE INDEX "views-created" ON public.views USING btree (created);


--
-- Name: views-object_id-session_id-type; Type: INDEX; Schema: public; Owner: -; Tablespace:
--

CREATE INDEX "views-object_id-session_id-type" ON public.views USING btree (object_id, session_id, type);


--
-- Name: views-user_id; Type: INDEX; Schema: public; Owner: -; Tablespace:
--

CREATE INDEX "views-user_id" ON public.views USING btree (user_id);


--
-- Name: admin_log-admin; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.admin_log
    ADD CONSTRAINT "admin_log-admin" FOREIGN KEY (admin_id) REFERENCES public."user"(user_id) DEFERRABLE;


--
-- Name: admin_log-comment; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.admin_log
    ADD CONSTRAINT "admin_log-comment" FOREIGN KEY (comment_id) REFERENCES public.comments(id) DEFERRABLE;


--
-- Name: admin_log-object; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.admin_log
    ADD CONSTRAINT "admin_log-object" FOREIGN KEY (object_id) REFERENCES public.object(object_id) DEFERRABLE;


--
-- Name: admin_log-user; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.admin_log
    ADD CONSTRAINT "admin_log-user" FOREIGN KEY (user_id) REFERENCES public."user"(user_id) DEFERRABLE;


--
-- Name: blog-object; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.blog
    ADD CONSTRAINT "blog-object" FOREIGN KEY (blog_id) REFERENCES public.object(object_id) DEFERRABLE;


--
-- Name: blog-picture; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.blog
    ADD CONSTRAINT "blog-picture" FOREIGN KEY (picture_id) REFERENCES public.picture(picture_id) DEFERRABLE;


--
-- Name: cms-user; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.cms
    ADD CONSTRAINT "cms-user" FOREIGN KEY (user_id) REFERENCES public."user"(user_id) DEFERRABLE;


--
-- Name: comments-object; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.comments
    ADD CONSTRAINT "comments-object" FOREIGN KEY (object_id) REFERENCES public.object(object_id) DEFERRABLE;


--
-- Name: comments-user; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.comments
    ADD CONSTRAINT "comments-user" FOREIGN KEY (user_id) REFERENCES public."user"(user_id) DEFERRABLE;


--
-- Name: forum-object; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.forum
    ADD CONSTRAINT "forum-object" FOREIGN KEY (forum_id) REFERENCES public.object(object_id) DEFERRABLE;


--
-- Name: forum-picture; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.forum
    ADD CONSTRAINT "forum-picture" FOREIGN KEY (picture_id) REFERENCES public.picture(picture_id) DEFERRABLE;


--
-- Name: link-object; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.link
    ADD CONSTRAINT "link-object" FOREIGN KEY (link_id) REFERENCES public.object(object_id) DEFERRABLE;


--
-- Name: link-picture; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.link
    ADD CONSTRAINT "link-picture" FOREIGN KEY (picture_id) REFERENCES public.picture(picture_id) DEFERRABLE;


--
-- Name: lotto-user; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.lotto
    ADD CONSTRAINT "lotto-user" FOREIGN KEY (user_id) REFERENCES public."user"(user_id) DEFERRABLE;


--
-- Name: object-user; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.object
    ADD CONSTRAINT "object-user" FOREIGN KEY (user_id) REFERENCES public."user"(user_id) DEFERRABLE;


--
-- Name: picture-object; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.picture
    ADD CONSTRAINT "picture-object" FOREIGN KEY (picture_id) REFERENCES public.object(object_id) DEFERRABLE;


--
-- Name: plus_minus-comment; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.plus_minus
    ADD CONSTRAINT "plus_minus-comment" FOREIGN KEY (comment_id) REFERENCES public.comments(id) DEFERRABLE;


--
-- Name: plus_minus-object; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.plus_minus
    ADD CONSTRAINT "plus_minus-object" FOREIGN KEY (object_id) REFERENCES public.object(object_id) DEFERRABLE;


--
-- Name: plus_minus-user; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.plus_minus
    ADD CONSTRAINT "plus_minus-user" FOREIGN KEY (user_id) REFERENCES public."user"(user_id) DEFERRABLE;


--
-- Name: poll-answer; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.poll_answer
    ADD CONSTRAINT "poll-answer" FOREIGN KEY (poll_id) REFERENCES public.poll(poll_id) DEFERRABLE;


--
-- Name: poll-object; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.poll
    ADD CONSTRAINT "poll-object" FOREIGN KEY (poll_id) REFERENCES public.object(object_id) DEFERRABLE;


--
-- Name: poll-picture; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.poll
    ADD CONSTRAINT "poll-picture" FOREIGN KEY (picture_id) REFERENCES public.picture(picture_id) DEFERRABLE;


--
-- Name: poll_vote-poll_answer; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.poll_vote
    ADD CONSTRAINT "poll_vote-poll_answer" FOREIGN KEY (answer_id) REFERENCES public.poll_answer(answer_id) ON DELETE CASCADE DEFERRABLE;


--
-- Name: poll_vote-user; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.poll_vote
    ADD CONSTRAINT "poll_vote-user" FOREIGN KEY (user_id) REFERENCES public."user"(user_id) DEFERRABLE;


--
-- Name: profile-object; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.profile
    ADD CONSTRAINT "profile-object" FOREIGN KEY (profile_id) REFERENCES public.object(object_id) DEFERRABLE;


--
-- Name: tag_objects-object; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.tag_objects
    ADD CONSTRAINT "tag_objects-object" FOREIGN KEY (object_id) REFERENCES public.object(object_id) DEFERRABLE;


--
-- Name: tag_objects-tag; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.tag_objects
    ADD CONSTRAINT "tag_objects-tag" FOREIGN KEY (tag_id) REFERENCES public.tags(tag_id) DEFERRABLE;


--
-- Name: user_admin-admin; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.user_admin
    ADD CONSTRAINT "user_admin-admin" FOREIGN KEY (admin_id) REFERENCES public.admin(admin_id) DEFERRABLE;


--
-- Name: user_admin-user; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.user_admin
    ADD CONSTRAINT "user_admin-user" FOREIGN KEY (user_id) REFERENCES public."user"(user_id) DEFERRABLE;


--
-- Name: user_tokens-user; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.user_tokens
    ADD CONSTRAINT "user_tokens-user" FOREIGN KEY (user_id) REFERENCES public."user"(user_id) DEFERRABLE;


--
-- Name: video-object; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.video
    ADD CONSTRAINT "video-object" FOREIGN KEY (video_id) REFERENCES public.object(object_id) DEFERRABLE;


--
-- Name: video-picture; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.video
    ADD CONSTRAINT "video-picture" FOREIGN KEY (picture_id) REFERENCES public.picture(picture_id) DEFERRABLE;


--
-- Name: view-object; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.views
    ADD CONSTRAINT "view-object" FOREIGN KEY (object_id) REFERENCES public.object(object_id) DEFERRABLE;


--
-- Name: views-user; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.views
    ADD CONSTRAINT "views-user" FOREIGN KEY (user_id) REFERENCES public."user"(user_id) DEFERRABLE;

--
-- PostgreSQL database dump complete
--

COMMIT;
