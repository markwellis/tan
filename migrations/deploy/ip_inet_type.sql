BEGIN;

    alter table views alter column ip type inet using ip::inet;

COMMIT;
