-- enforce that there is only one record allowed in the table
CREATE TABLE "public"."id_tracker" (id integer primary key, track_id int NOT NULL UNIQUE, CHECK (id = 1));

-- start ids at 1500, more than most systems have by default
INSERT INTO "public"."id_tracker" (id,track_id) VALUES (1,1500);
