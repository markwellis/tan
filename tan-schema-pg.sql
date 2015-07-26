BEGIN;
CREATE TYPE object_type AS ENUM ('link','blog','picture','profile','poll','video','forum');
CREATE TYPE plus_minus_type AS ENUM ('plus','minus');
CREATE TYPE user_token_type AS ENUM ('reg','forgot');
CREATE TYPE view_type AS ENUM ('internal','external');

CREATE TABLE "admin" (
  "admin_id" serial NOT NULL,
  "role" character varying(255) NOT NULL,
  PRIMARY KEY ("admin_id")
);

CREATE TABLE "admin_log" (
  "log_id" serial NOT NULL,
  "admin_id" integer NOT NULL,
  "action" character varying(255) NOT NULL,
  "reason" character varying(512) NOT NULL,
  "bulk" text,
  "user_id" integer NOT NULL,
  "comment_id" integer DEFAULT NULL,
  "object_id" integer DEFAULT NULL,
  "created" timestamp DEFAULT CURRENT_TIMESTAMP NOT NULL,
  "other" text,
  PRIMARY KEY ("log_id")
);
CREATE INDEX "admin_log-admin_id" on "admin_log" ("admin_id");
CREATE INDEX "admin_log-user_id" on "admin_log" ("user_id");
CREATE INDEX "admin_log-object_id" on "admin_log" ("object_id");
CREATE INDEX "admin_log-comment_id" on "admin_log" ("comment_id");

CREATE TABLE "cms" (
  "cms_id" serial NOT NULL,
  "url" character varying(255) NOT NULL,
  "content" text NOT NULL,
  "user_id" integer NOT NULL,
  "revision" integer NOT NULL,
  "created" timestamp DEFAULT CURRENT_TIMESTAMP NOT NULL,
  "title" character varying(255) NOT NULL,
  "comment" character varying(255) NOT NULL,
  "deleted" smallint DEFAULT 0 NOT NULL,
  "system" smallint DEFAULT 0 NOT NULL,
  "nowrapper" smallint DEFAULT 0 NOT NULL,
  PRIMARY KEY ("cms_id")
);
CREATE INDEX "cms-url:varchar_pattern_ops" on "cms" ("url" varchar_pattern_ops);
CREATE INDEX "cms-revision" on "cms" ("revision");
CREATE INDEX "cms-deleted" on "cms" ("deleted");
CREATE INDEX "cms-user_id" on "cms" ("user_id");

CREATE TABLE "comments" (
  "id" serial NOT NULL,
  "user_id" integer NOT NULL,
  "comment" text NOT NULL,
  "created" timestamp DEFAULT CURRENT_TIMESTAMP NOT NULL,
  "object_id" integer NOT NULL,
  "deleted" smallint DEFAULT 0 NOT NULL,
  "number" integer NOT NULL,
  "updated" timestamp DEFAULT CURRENT_TIMESTAMP NOT NULL,
  "plus" bigint DEFAULT 0 NOT NULL,
  "minus" bigint DEFAULT 0 NOT NULL,
  PRIMARY KEY ("id")
);
CREATE INDEX "comments-user_id" on "comments" ("user_id");
CREATE INDEX "comments-object_id" on "comments" ("object_id");
CREATE INDEX "comments-created-object_id-user_id-deleted" on "comments" ("created", "object_id", "user_id", "deleted");

CREATE TABLE "lotto" (
  "lotto_id" serial NOT NULL,
  "created" timestamp DEFAULT CURRENT_TIMESTAMP NOT NULL,
  "user_id" integer NOT NULL,
  "number" smallint NOT NULL,
  "confirmed" smallint DEFAULT 0 NOT NULL,
  "winner" smallint DEFAULT 0 NOT NULL,
  "txn_id" character varying(19) DEFAULT NULL,
  PRIMARY KEY ("lotto_id")
);
CREATE INDEX "lotto-created" on "lotto" ("created");
CREATE INDEX "lotto-confirmed-created" on "lotto" ("confirmed", "created");
CREATE INDEX "lotto-winner-created" on "lotto" ("winner", "created");
CREATE INDEX "lotto-txn_id" on "lotto" ("txn_id");
CREATE INDEX "lotto-user_id" on "lotto" ("user_id");

CREATE TABLE "object" (
  "object_id" serial NOT NULL,
  "type" object_type NOT NULL,
  "created" timestamp DEFAULT CURRENT_TIMESTAMP NOT NULL,
  "promoted" timestamp DEFAULT NULL,
  "user_id" integer NOT NULL,
  "nsfw" smallint DEFAULT 0 NOT NULL,
  "views" integer DEFAULT 0 NOT NULL,
  "plus" integer DEFAULT 0 NOT NULL,
  "minus" integer DEFAULT 0 NOT NULL,
  "comments" integer DEFAULT 0 NOT NULL,
  "deleted" smallint DEFAULT 0 NOT NULL,
  "score" integer DEFAULT NULL,
  "locked" smallint DEFAULT 0 NOT NULL,
  PRIMARY KEY ("object_id")
);
CREATE INDEX "object-created" on "object" ("created");
CREATE INDEX "object-promoted" on "object" ("promoted");
CREATE INDEX "object-type-user_id-nsfw-created" on "object" ("type", "user_id", "nsfw", "created");
CREATE INDEX "object-nsfw-type-promoted-created-deleted" on "object" ("nsfw", "type", "promoted", "created", "deleted");
CREATE INDEX "object-user_id" on "object" ("user_id");

CREATE TABLE object_type_base (
  "title" character varying(255) NOT NULL,
  "description" character varying(1000) NOT NULL
);

CREATE TABLE "link" (
  "link_id" integer NOT NULL,
  "picture_id" integer NOT NULL,
  "url" character varying(400) NOT NULL,
  PRIMARY KEY ("link_id")
) INHERITS ("object_type_base");
CREATE INDEX "link-picture_id" on "link" ("picture_id");

CREATE TABLE "video" (
  "video_id" integer NOT NULL,
  "picture_id" integer NOT NULL,
  "url" character varying(400) NOT NULL,
  PRIMARY KEY ("video_id")
) INHERITS ("object_type_base");
CREATE INDEX "video-picture_id" on "video" ("picture_id");

CREATE TABLE "blog" (
  "blog_id" integer NOT NULL,
  "picture_id" integer NOT NULL,
  "details" text NOT NULL,
  PRIMARY KEY ("blog_id")
) INHERITS ("object_type_base");
CREATE INDEX "blog-picture_id" on "blog" ("picture_id");

CREATE TABLE "forum" (
  "forum_id" integer NOT NULL,
  "picture_id" integer NOT NULL,
  "details" text NOT NULL,
  PRIMARY KEY ("forum_id")
) INHERITS ("object_type_base");
CREATE INDEX "forum-picture_id" on "forum" ("picture_id");

CREATE TABLE "picture" (
  "picture_id" integer NOT NULL,
  "filename" character varying(300) NOT NULL,
  "x" integer NOT NULL,
  "y" integer NOT NULL,
  "size" numeric NOT NULL,
  "sha512sum" character varying(128) NOT NULL,
  PRIMARY KEY ("picture_id")
) INHERITS ("object_type_base");
CREATE INDEX "picture-filename:varchar_pattern_ops" on "picture" ("filename" varchar_pattern_ops);
CREATE INDEX "picture-sha512sum:" on "picture" ("sha512sum" varchar_pattern_ops);

CREATE TABLE "poll" (
  "poll_id" integer NOT NULL,
  "picture_id" integer NOT NULL,
  "end_date" timestamp DEFAULT NULL,
  "votes" integer DEFAULT 0 NOT NULL,
  PRIMARY KEY ("poll_id")
) INHERITS ("object_type_base");
CREATE INDEX "poll-picture_id" on "poll" ("picture_id");

CREATE TABLE "poll_answer" (
  "answer_id" serial NOT NULL,
  "poll_id" integer NOT NULL,
  "answer" character varying(255) NOT NULL,
  "votes" integer DEFAULT 0 NOT NULL,
  PRIMARY KEY ("answer_id")
);
CREATE INDEX "poll_answer-poll_id" on "poll_answer" ("poll_id");

CREATE TABLE "poll_vote" (
  "vote_id" serial NOT NULL,
  "answer_id" integer NOT NULL,
  "user_id" integer NOT NULL,
  PRIMARY KEY ("vote_id")
);
CREATE INDEX "poll_vote-answer_id" on "poll_vote" ("answer_id");
CREATE INDEX "poll_vote-user_id" on "poll_vote" ("user_id");

CREATE TABLE "profile" (
  "profile_id" integer NOT NULL,
  "details" text NOT NULL,
  PRIMARY KEY ("profile_id")
);

CREATE TABLE "plus_minus" (
  "id" serial NOT NULL,
  "type" plus_minus_type NOT NULL,
  "object_id" integer NOT NULL,
  "user_id" integer NOT NULL,
  "comment_id" integer DEFAULT NULL,
  "created" timestamp DEFAULT CURRENT_TIMESTAMP NOT NULL,
  PRIMARY KEY ("id"),
  CONSTRAINT "plus_minus-user_id-object_id-type:unique" UNIQUE ("user_id", "object_id", "type"),
  CONSTRAINT "plus_minus-user_id-comment_id-type:unique" UNIQUE ("user_id", "comment_id", "type")
);
CREATE INDEX "plus_minus-type" on "plus_minus" ("type");
CREATE INDEX "plus_minus-user_id" on "plus_minus" ("user_id");
CREATE INDEX "plus_minus-object_id" on "plus_minus" ("object_id");
CREATE INDEX "plus_minus-comment_id" on "plus_minus" ("comment_id");

CREATE TABLE "tag_objects" (
  "object_tag_id" serial NOT NULL,
  "tag_id" integer NOT NULL,
  "object_id" integer NOT NULL,
  PRIMARY KEY ("object_tag_id")
);
CREATE INDEX "tag_objects-tag_id" on "tag_objects" ("tag_id");
CREATE INDEX "tag_objects-object_id" on "tag_objects" ("object_id");

CREATE TABLE "tags" (
  "tag_id" serial NOT NULL,
  "tag" character varying(30) NOT NULL,
  "stem" character varying(30) NOT NULL,
  PRIMARY KEY ("tag_id")
);
CREATE INDEX "tags-tag:varchar_pattern_ops" on "tags" ("tag" varchar_pattern_ops);
CREATE INDEX "tags-stem:varchar_pattern_ops" on "tags" ("stem" varchar_pattern_ops);

CREATE TABLE "user" (
  "user_id" serial NOT NULL,
  "username" character varying(255) NOT NULL,
  "join_date" timestamp DEFAULT CURRENT_TIMESTAMP NOT NULL,
  "email" character varying(255) NOT NULL,
  "password" character varying(128) NOT NULL,
  "confirmed" smallint DEFAULT 0 NOT NULL,
  "deleted" smallint DEFAULT 0 NOT NULL,
  "paypal" character varying(255),
  "avatar" character varying(10),
  "tcs" integer DEFAULT NULL,
  PRIMARY KEY ("user_id"),
  CONSTRAINT "user-username" UNIQUE ("username")
);
CREATE INDEX "user-username:varchar_pattern_ops" on "user" ("username" varchar_pattern_ops);
CREATE INDEX "user-email:varchar_pattern_ops" on "user" ("email" varchar_pattern_ops);

CREATE TABLE "user_admin" (
  "user_id" integer NOT NULL,
  "admin_id" integer NOT NULL,
  PRIMARY KEY ("user_id", "admin_id")
);
CREATE INDEX "user_admin-admin_id" on "user_admin" ("admin_id");

CREATE TABLE "user_tokens" (
  "token_id" serial NOT NULL,
  "user_id" integer NOT NULL,
  "token" character varying(516) NOT NULL,
  "expires" timestamp DEFAULT CURRENT_TIMESTAMP NOT NULL,
  "type" user_token_type NOT NULL,
  PRIMARY KEY ("token_id")
);
CREATE INDEX "user_tokens-user_id" on "user_tokens" ("user_id");

CREATE TABLE "views" (
  "view_id" serial NOT NULL,
  "ip" character varying(15) NOT NULL,
  "object_id" integer DEFAULT NULL,
  "session_id" character varying(128) NOT NULL,
  "user_id" integer DEFAULT NULL,
  "created" timestamp DEFAULT CURRENT_TIMESTAMP NOT NULL,
  "type" view_type DEFAULT 'internal' NOT NULL,
  PRIMARY KEY ("view_id")
);
CREATE INDEX "views-object_id-session_id-type" on "views" ("object_id", "session_id", "type");
CREATE INDEX "views-created" on "views" ("created");
CREATE INDEX "views-user_id" on "views" ("user_id");

ALTER TABLE "admin_log" ADD CONSTRAINT "admin_log-comment" FOREIGN KEY ("comment_id")
  REFERENCES "comments" ("id") DEFERRABLE;

ALTER TABLE "admin_log" ADD CONSTRAINT "admin_log-admin" FOREIGN KEY ("admin_id")
  REFERENCES "user" ("user_id") ON DELETE NO ACTION ON UPDATE NO ACTION DEFERRABLE;

ALTER TABLE "admin_log" ADD CONSTRAINT "admin_log-user" FOREIGN KEY ("user_id")
  REFERENCES "user" ("user_id") ON DELETE NO ACTION ON UPDATE NO ACTION DEFERRABLE;

ALTER TABLE "admin_log" ADD CONSTRAINT "admin_log-object" FOREIGN KEY ("object_id")
  REFERENCES "object" ("object_id") ON DELETE NO ACTION ON UPDATE NO ACTION DEFERRABLE;

ALTER TABLE "blog" ADD CONSTRAINT "blog-object" FOREIGN KEY ("blog_id")
  REFERENCES "object" ("object_id") ON DELETE NO ACTION ON UPDATE NO ACTION DEFERRABLE;

ALTER TABLE "blog" ADD CONSTRAINT "blog-picture" FOREIGN KEY ("picture_id")
  REFERENCES "picture" ("picture_id") ON DELETE NO ACTION ON UPDATE NO ACTION DEFERRABLE;

ALTER TABLE "cms" ADD CONSTRAINT "cms-user" FOREIGN KEY ("user_id")
  REFERENCES "user" ("user_id") ON DELETE NO ACTION ON UPDATE NO ACTION DEFERRABLE;

ALTER TABLE "comments" ADD CONSTRAINT "comments-object" FOREIGN KEY ("object_id")
  REFERENCES "object" ("object_id") DEFERRABLE;

ALTER TABLE "comments" ADD CONSTRAINT "comments-user" FOREIGN KEY ("user_id")
  REFERENCES "user" ("user_id") DEFERRABLE;

ALTER TABLE "forum" ADD CONSTRAINT "forum-object" FOREIGN KEY ("forum_id")
  REFERENCES "object" ("object_id") ON DELETE NO ACTION ON UPDATE NO ACTION DEFERRABLE;

ALTER TABLE "forum" ADD CONSTRAINT "forum-picture" FOREIGN KEY ("picture_id")
  REFERENCES "picture" ("picture_id") ON DELETE NO ACTION ON UPDATE NO ACTION DEFERRABLE;

ALTER TABLE "link" ADD CONSTRAINT "link-object" FOREIGN KEY ("link_id")
  REFERENCES "object" ("object_id") ON DELETE NO ACTION ON UPDATE NO ACTION DEFERRABLE;

ALTER TABLE "link" ADD CONSTRAINT "link-picture" FOREIGN KEY ("picture_id")
  REFERENCES "picture" ("picture_id") ON DELETE NO ACTION ON UPDATE NO ACTION DEFERRABLE;

ALTER TABLE "lotto" ADD CONSTRAINT "lotto-user" FOREIGN KEY ("user_id")
  REFERENCES "user" ("user_id") ON DELETE NO ACTION ON UPDATE NO ACTION DEFERRABLE;

ALTER TABLE "object" ADD CONSTRAINT "object-user" FOREIGN KEY ("user_id")
  REFERENCES "user" ("user_id") ON DELETE NO ACTION ON UPDATE NO ACTION DEFERRABLE;

ALTER TABLE "picture" ADD CONSTRAINT "picture-object" FOREIGN KEY ("picture_id")
  REFERENCES "object" ("object_id") ON DELETE NO ACTION ON UPDATE NO ACTION DEFERRABLE;

ALTER TABLE "plus_minus" ADD CONSTRAINT "plus_minus-comment" FOREIGN KEY ("comment_id")
  REFERENCES "comments" ("id") DEFERRABLE;

ALTER TABLE "plus_minus" ADD CONSTRAINT "plus_minus-object" FOREIGN KEY ("object_id")
  REFERENCES "object" ("object_id") DEFERRABLE;

ALTER TABLE "plus_minus" ADD CONSTRAINT "plus_minus-user" FOREIGN KEY ("user_id")
  REFERENCES "user" ("user_id") DEFERRABLE;

ALTER TABLE "poll" ADD CONSTRAINT "poll-object" FOREIGN KEY ("poll_id")
  REFERENCES "object" ("object_id") ON DELETE NO ACTION ON UPDATE NO ACTION DEFERRABLE;

ALTER TABLE "poll" ADD CONSTRAINT "poll-picture" FOREIGN KEY ("picture_id")
  REFERENCES "picture" ("picture_id") ON DELETE NO ACTION ON UPDATE NO ACTION DEFERRABLE;

ALTER TABLE "poll_answer" ADD CONSTRAINT "poll-answer" FOREIGN KEY ("poll_id")
  REFERENCES "poll" ("poll_id") ON DELETE NO ACTION ON UPDATE NO ACTION DEFERRABLE;

ALTER TABLE "poll_vote" ADD CONSTRAINT "poll_vote-poll_answer" FOREIGN KEY ("answer_id")
  REFERENCES "poll_answer" ("answer_id") ON DELETE CASCADE ON UPDATE NO ACTION DEFERRABLE;

ALTER TABLE "poll_vote" ADD CONSTRAINT "poll_vote-user" FOREIGN KEY ("user_id")
  REFERENCES "user" ("user_id") ON DELETE NO ACTION ON UPDATE NO ACTION DEFERRABLE;

ALTER TABLE "profile" ADD CONSTRAINT "profile-object" FOREIGN KEY ("profile_id")
  REFERENCES "object" ("object_id") ON DELETE NO ACTION ON UPDATE NO ACTION DEFERRABLE;

ALTER TABLE "tag_objects" ADD CONSTRAINT "tag_objects-tag" FOREIGN KEY ("tag_id")
  REFERENCES "tags" ("tag_id") ON DELETE NO ACTION ON UPDATE NO ACTION DEFERRABLE;

ALTER TABLE "tag_objects" ADD CONSTRAINT "tag_objects-object" FOREIGN KEY ("object_id")
  REFERENCES "object" ("object_id") ON DELETE NO ACTION ON UPDATE NO ACTION DEFERRABLE;

ALTER TABLE "user_admin" ADD CONSTRAINT "user_admin-user" FOREIGN KEY ("user_id")
  REFERENCES "user" ("user_id") ON DELETE NO ACTION ON UPDATE NO ACTION DEFERRABLE;

ALTER TABLE "user_admin" ADD CONSTRAINT "user_admin-admin" FOREIGN KEY ("admin_id")
  REFERENCES "admin" ("admin_id") ON DELETE NO ACTION ON UPDATE NO ACTION DEFERRABLE;

ALTER TABLE "user_tokens" ADD CONSTRAINT "user_tokens-user" FOREIGN KEY ("user_id")
  REFERENCES "user" ("user_id") ON DELETE NO ACTION ON UPDATE NO ACTION DEFERRABLE;

ALTER TABLE "video" ADD CONSTRAINT "video-object" FOREIGN KEY ("video_id")
  REFERENCES "object" ("object_id") ON DELETE NO ACTION ON UPDATE NO ACTION DEFERRABLE;

ALTER TABLE "video" ADD CONSTRAINT "video-picture" FOREIGN KEY ("picture_id")
  REFERENCES "picture" ("picture_id") ON DELETE NO ACTION ON UPDATE NO ACTION DEFERRABLE;

ALTER TABLE "views" ADD CONSTRAINT "view-object" FOREIGN KEY ("object_id")
  REFERENCES "object" ("object_id") ON DELETE NO ACTION ON UPDATE NO ACTION DEFERRABLE;

ALTER TABLE "views" ADD CONSTRAINT "views-user" FOREIGN KEY ("user_id")
  REFERENCES "user" ("user_id") ON DELETE NO ACTION ON UPDATE NO ACTION DEFERRABLE;

COMMIT;
