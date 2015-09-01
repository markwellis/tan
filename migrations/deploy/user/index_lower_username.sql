BEGIN;

    DROP INDEX "user-username:varchar_pattern_ops";
    CREATE INDEX "user-lower(username):varchar_pattern_ops" on "user" (LOWER("username") varchar_pattern_ops);

    DROP INDEX "user-email:varchar_pattern_ops";
    CREATE INDEX "user-lower(email):varchar_pattern_ops" on "user" (LOWER("email") varchar_pattern_ops);

COMMIT;
