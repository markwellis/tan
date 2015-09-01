BEGIN;

    DROP INDEX "user-lower(email):varchar_pattern_ops";
    CREATE INDEX "user-email:varchar_pattern_ops" on "user" ("email" varchar_pattern_ops);

    DROP INDEX "user-lower(username):varchar_pattern_ops";
    CREATE INDEX "user-username:varchar_pattern_ops" on "user" ("username" varchar_pattern_ops);

COMMIT;
