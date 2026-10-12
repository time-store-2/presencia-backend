import { MigrateUpArgs, MigrateDownArgs, sql } from '@payloadcms/db-postgres'

export async function up({ db, payload, req }: MigrateUpArgs): Promise<void> {
  await db.execute(sql`
   CREATE TYPE "public"."_locales" AS ENUM('en');
  CREATE TYPE "public"."enum_users_role" AS ENUM('admin', 'assistant');
  CREATE TYPE "public"."enum_members_gender" AS ENUM('male', 'female');
  CREATE TYPE "public"."enum_members_parent1_relation" AS ENUM('father', 'mother', 'guardian', 'other');
  CREATE TYPE "public"."enum_members_parent2_relation" AS ENUM('father', 'mother', 'guardian', 'other');
  CREATE TYPE "public"."enum_members_status" AS ENUM('active', 'inactive');
  CREATE TYPE "public"."enum_attendance_records_status" AS ENUM('present', 'absent', 'late', 'excused');
  CREATE TABLE "users_sessions" (
  	"_order" integer NOT NULL,
  	"_parent_id" integer NOT NULL,
  	"id" varchar PRIMARY KEY NOT NULL,
  	"created_at" timestamp(3) with time zone,
  	"expires_at" timestamp(3) with time zone NOT NULL
  );
  
  CREATE TABLE "users" (
  	"id" serial PRIMARY KEY NOT NULL,
  	"display_name" varchar NOT NULL,
  	"phone" varchar,
  	"role" "enum_users_role" DEFAULT 'admin' NOT NULL,
  	"updated_at" timestamp(3) with time zone DEFAULT now() NOT NULL,
  	"created_at" timestamp(3) with time zone DEFAULT now() NOT NULL,
  	"email" varchar NOT NULL,
  	"reset_password_token" varchar,
  	"reset_password_expiration" timestamp(3) with time zone,
  	"salt" varchar,
  	"hash" varchar,
  	"reset_password_requested_at" timestamp(3) with time zone,
  	"login_attempts" numeric DEFAULT 0,
  	"lock_until" timestamp(3) with time zone
  );
  
  CREATE TABLE "users_rels" (
  	"id" serial PRIMARY KEY NOT NULL,
  	"order" integer,
  	"parent_id" integer NOT NULL,
  	"path" varchar NOT NULL,
  	"groups_id" integer
  );
  
  CREATE TABLE "groups" (
  	"id" serial PRIMARY KEY NOT NULL,
  	"name" varchar NOT NULL,
  	"slug" varchar,
  	"description" varchar,
  	"color" varchar DEFAULT '#2196F3',
  	"meeting_day" varchar,
  	"meeting_time" varchar,
  	"updated_at" timestamp(3) with time zone DEFAULT now() NOT NULL,
  	"created_at" timestamp(3) with time zone DEFAULT now() NOT NULL
  );
  
  CREATE TABLE "members" (
  	"id" serial PRIMARY KEY NOT NULL,
  	"first_name" varchar NOT NULL,
  	"last_name" varchar NOT NULL,
  	"phone" varchar NOT NULL,
  	"email" varchar,
  	"gender" "enum_members_gender",
  	"birth_date" timestamp(3) with time zone,
  	"address" varchar,
  	"parent1_first_name" varchar,
  	"parent1_last_name" varchar,
  	"parent1_phone" varchar,
  	"parent1_relation" "enum_members_parent1_relation",
  	"parent2_first_name" varchar,
  	"parent2_last_name" varchar,
  	"parent2_phone" varchar,
  	"parent2_relation" "enum_members_parent2_relation",
  	"registration_date" timestamp(3) with time zone,
  	"status" "enum_members_status" DEFAULT 'active',
  	"updated_at" timestamp(3) with time zone DEFAULT now() NOT NULL,
  	"created_at" timestamp(3) with time zone DEFAULT now() NOT NULL
  );
  
  CREATE TABLE "members_rels" (
  	"id" serial PRIMARY KEY NOT NULL,
  	"order" integer,
  	"parent_id" integer NOT NULL,
  	"path" varchar NOT NULL,
  	"groups_id" integer
  );
  
  CREATE TABLE "attendance_sessions" (
  	"id" serial PRIMARY KEY NOT NULL,
  	"date" timestamp(3) with time zone NOT NULL,
  	"group_id" integer NOT NULL,
  	"leader_id" integer NOT NULL,
  	"notes" varchar,
  	"is_closed" boolean DEFAULT false,
  	"updated_at" timestamp(3) with time zone DEFAULT now() NOT NULL,
  	"created_at" timestamp(3) with time zone DEFAULT now() NOT NULL
  );
  
  CREATE TABLE "attendance_records" (
  	"id" serial PRIMARY KEY NOT NULL,
  	"session_id" integer NOT NULL,
  	"member_id" integer NOT NULL,
  	"status" "enum_attendance_records_status" DEFAULT 'present' NOT NULL,
  	"note" varchar,
  	"updated_at" timestamp(3) with time zone DEFAULT now() NOT NULL,
  	"created_at" timestamp(3) with time zone DEFAULT now() NOT NULL
  );
  
  CREATE TABLE "payload_kv" (
  	"id" serial PRIMARY KEY NOT NULL,
  	"key" varchar NOT NULL,
  	"data" jsonb NOT NULL
  );
  
  CREATE TABLE "payload_locked_documents" (
  	"id" serial PRIMARY KEY NOT NULL,
  	"global_slug" varchar,
  	"updated_at" timestamp(3) with time zone DEFAULT now() NOT NULL,
  	"created_at" timestamp(3) with time zone DEFAULT now() NOT NULL
  );
  
  CREATE TABLE "payload_locked_documents_rels" (
  	"id" serial PRIMARY KEY NOT NULL,
  	"order" integer,
  	"parent_id" integer NOT NULL,
  	"path" varchar NOT NULL,
  	"users_id" integer,
  	"groups_id" integer,
  	"members_id" integer,
  	"attendance_sessions_id" integer,
  	"attendance_records_id" integer
  );
  
  CREATE TABLE "payload_preferences" (
  	"id" serial PRIMARY KEY NOT NULL,
  	"key" varchar,
  	"value" jsonb,
  	"updated_at" timestamp(3) with time zone DEFAULT now() NOT NULL,
  	"created_at" timestamp(3) with time zone DEFAULT now() NOT NULL
  );
  
  CREATE TABLE "payload_preferences_rels" (
  	"id" serial PRIMARY KEY NOT NULL,
  	"order" integer,
  	"parent_id" integer NOT NULL,
  	"path" varchar NOT NULL,
  	"users_id" integer
  );
  
  CREATE TABLE "payload_migrations" (
  	"id" serial PRIMARY KEY NOT NULL,
  	"name" varchar,
  	"batch" numeric,
  	"updated_at" timestamp(3) with time zone DEFAULT now() NOT NULL,
  	"created_at" timestamp(3) with time zone DEFAULT now() NOT NULL
  );
  
  CREATE TABLE "settings" (
  	"id" serial PRIMARY KEY NOT NULL,
  	"absence_message" varchar DEFAULT 'Bonjour {prenom}, tu as manqué la séance de {groupe} du {date}. Tu nous as manqué, à bientôt !',
  	"updated_at" timestamp(3) with time zone,
  	"created_at" timestamp(3) with time zone
  );
  
  ALTER TABLE "users_sessions" ADD CONSTRAINT "users_sessions_parent_id_fk" FOREIGN KEY ("_parent_id") REFERENCES "public"."users"("id") ON DELETE cascade ON UPDATE no action;
  ALTER TABLE "users_rels" ADD CONSTRAINT "users_rels_parent_fk" FOREIGN KEY ("parent_id") REFERENCES "public"."users"("id") ON DELETE cascade ON UPDATE no action;
  ALTER TABLE "users_rels" ADD CONSTRAINT "users_rels_groups_fk" FOREIGN KEY ("groups_id") REFERENCES "public"."groups"("id") ON DELETE cascade ON UPDATE no action;
  ALTER TABLE "members_rels" ADD CONSTRAINT "members_rels_parent_fk" FOREIGN KEY ("parent_id") REFERENCES "public"."members"("id") ON DELETE cascade ON UPDATE no action;
  ALTER TABLE "members_rels" ADD CONSTRAINT "members_rels_groups_fk" FOREIGN KEY ("groups_id") REFERENCES "public"."groups"("id") ON DELETE cascade ON UPDATE no action;
  ALTER TABLE "attendance_sessions" ADD CONSTRAINT "attendance_sessions_group_id_groups_id_fk" FOREIGN KEY ("group_id") REFERENCES "public"."groups"("id") ON DELETE set null ON UPDATE no action;
  ALTER TABLE "attendance_sessions" ADD CONSTRAINT "attendance_sessions_leader_id_users_id_fk" FOREIGN KEY ("leader_id") REFERENCES "public"."users"("id") ON DELETE set null ON UPDATE no action;
  ALTER TABLE "attendance_records" ADD CONSTRAINT "attendance_records_session_id_attendance_sessions_id_fk" FOREIGN KEY ("session_id") REFERENCES "public"."attendance_sessions"("id") ON DELETE set null ON UPDATE no action;
  ALTER TABLE "attendance_records" ADD CONSTRAINT "attendance_records_member_id_members_id_fk" FOREIGN KEY ("member_id") REFERENCES "public"."members"("id") ON DELETE set null ON UPDATE no action;
  ALTER TABLE "payload_locked_documents_rels" ADD CONSTRAINT "payload_locked_documents_rels_parent_fk" FOREIGN KEY ("parent_id") REFERENCES "public"."payload_locked_documents"("id") ON DELETE cascade ON UPDATE no action;
  ALTER TABLE "payload_locked_documents_rels" ADD CONSTRAINT "payload_locked_documents_rels_users_fk" FOREIGN KEY ("users_id") REFERENCES "public"."users"("id") ON DELETE cascade ON UPDATE no action;
  ALTER TABLE "payload_locked_documents_rels" ADD CONSTRAINT "payload_locked_documents_rels_groups_fk" FOREIGN KEY ("groups_id") REFERENCES "public"."groups"("id") ON DELETE cascade ON UPDATE no action;
  ALTER TABLE "payload_locked_documents_rels" ADD CONSTRAINT "payload_locked_documents_rels_members_fk" FOREIGN KEY ("members_id") REFERENCES "public"."members"("id") ON DELETE cascade ON UPDATE no action;
  ALTER TABLE "payload_locked_documents_rels" ADD CONSTRAINT "payload_locked_documents_rels_attendance_sessions_fk" FOREIGN KEY ("attendance_sessions_id") REFERENCES "public"."attendance_sessions"("id") ON DELETE cascade ON UPDATE no action;
  ALTER TABLE "payload_locked_documents_rels" ADD CONSTRAINT "payload_locked_documents_rels_attendance_records_fk" FOREIGN KEY ("attendance_records_id") REFERENCES "public"."attendance_records"("id") ON DELETE cascade ON UPDATE no action;
  ALTER TABLE "payload_preferences_rels" ADD CONSTRAINT "payload_preferences_rels_parent_fk" FOREIGN KEY ("parent_id") REFERENCES "public"."payload_preferences"("id") ON DELETE cascade ON UPDATE no action;
  ALTER TABLE "payload_preferences_rels" ADD CONSTRAINT "payload_preferences_rels_users_fk" FOREIGN KEY ("users_id") REFERENCES "public"."users"("id") ON DELETE cascade ON UPDATE no action;
  CREATE INDEX "users_sessions_order_idx" ON "users_sessions" USING btree ("_order");
  CREATE INDEX "users_sessions_parent_id_idx" ON "users_sessions" USING btree ("_parent_id");
  CREATE INDEX "users_updated_at_idx" ON "users" USING btree ("updated_at");
  CREATE INDEX "users_created_at_idx" ON "users" USING btree ("created_at");
  CREATE UNIQUE INDEX "users_email_idx" ON "users" USING btree ("email");
  CREATE INDEX "users_rels_order_idx" ON "users_rels" USING btree ("order");
  CREATE INDEX "users_rels_parent_idx" ON "users_rels" USING btree ("parent_id");
  CREATE INDEX "users_rels_path_idx" ON "users_rels" USING btree ("path");
  CREATE INDEX "users_rels_groups_id_idx" ON "users_rels" USING btree ("groups_id");
  CREATE UNIQUE INDEX "groups_slug_idx" ON "groups" USING btree ("slug");
  CREATE INDEX "groups_updated_at_idx" ON "groups" USING btree ("updated_at");
  CREATE INDEX "groups_created_at_idx" ON "groups" USING btree ("created_at");
  CREATE INDEX "members_updated_at_idx" ON "members" USING btree ("updated_at");
  CREATE INDEX "members_created_at_idx" ON "members" USING btree ("created_at");
  CREATE INDEX "members_rels_order_idx" ON "members_rels" USING btree ("order");
  CREATE INDEX "members_rels_parent_idx" ON "members_rels" USING btree ("parent_id");
  CREATE INDEX "members_rels_path_idx" ON "members_rels" USING btree ("path");
  CREATE INDEX "members_rels_groups_id_idx" ON "members_rels" USING btree ("groups_id");
  CREATE INDEX "attendance_sessions_group_idx" ON "attendance_sessions" USING btree ("group_id");
  CREATE INDEX "attendance_sessions_leader_idx" ON "attendance_sessions" USING btree ("leader_id");
  CREATE INDEX "attendance_sessions_updated_at_idx" ON "attendance_sessions" USING btree ("updated_at");
  CREATE INDEX "attendance_sessions_created_at_idx" ON "attendance_sessions" USING btree ("created_at");
  CREATE INDEX "attendance_records_session_idx" ON "attendance_records" USING btree ("session_id");
  CREATE INDEX "attendance_records_member_idx" ON "attendance_records" USING btree ("member_id");
  CREATE INDEX "attendance_records_updated_at_idx" ON "attendance_records" USING btree ("updated_at");
  CREATE INDEX "attendance_records_created_at_idx" ON "attendance_records" USING btree ("created_at");
  CREATE UNIQUE INDEX "payload_kv_key_idx" ON "payload_kv" USING btree ("key");
  CREATE INDEX "payload_locked_documents_global_slug_idx" ON "payload_locked_documents" USING btree ("global_slug");
  CREATE INDEX "payload_locked_documents_updated_at_idx" ON "payload_locked_documents" USING btree ("updated_at");
  CREATE INDEX "payload_locked_documents_created_at_idx" ON "payload_locked_documents" USING btree ("created_at");
  CREATE INDEX "payload_locked_documents_rels_order_idx" ON "payload_locked_documents_rels" USING btree ("order");
  CREATE INDEX "payload_locked_documents_rels_parent_idx" ON "payload_locked_documents_rels" USING btree ("parent_id");
  CREATE INDEX "payload_locked_documents_rels_path_idx" ON "payload_locked_documents_rels" USING btree ("path");
  CREATE INDEX "payload_locked_documents_rels_users_id_idx" ON "payload_locked_documents_rels" USING btree ("users_id");
  CREATE INDEX "payload_locked_documents_rels_groups_id_idx" ON "payload_locked_documents_rels" USING btree ("groups_id");
  CREATE INDEX "payload_locked_documents_rels_members_id_idx" ON "payload_locked_documents_rels" USING btree ("members_id");
  CREATE INDEX "payload_locked_documents_rels_attendance_sessions_id_idx" ON "payload_locked_documents_rels" USING btree ("attendance_sessions_id");
  CREATE INDEX "payload_locked_documents_rels_attendance_records_id_idx" ON "payload_locked_documents_rels" USING btree ("attendance_records_id");
  CREATE INDEX "payload_preferences_key_idx" ON "payload_preferences" USING btree ("key");
  CREATE INDEX "payload_preferences_updated_at_idx" ON "payload_preferences" USING btree ("updated_at");
  CREATE INDEX "payload_preferences_created_at_idx" ON "payload_preferences" USING btree ("created_at");
  CREATE INDEX "payload_preferences_rels_order_idx" ON "payload_preferences_rels" USING btree ("order");
  CREATE INDEX "payload_preferences_rels_parent_idx" ON "payload_preferences_rels" USING btree ("parent_id");
  CREATE INDEX "payload_preferences_rels_path_idx" ON "payload_preferences_rels" USING btree ("path");
  CREATE INDEX "payload_preferences_rels_users_id_idx" ON "payload_preferences_rels" USING btree ("users_id");
  CREATE INDEX "payload_migrations_updated_at_idx" ON "payload_migrations" USING btree ("updated_at");
  CREATE INDEX "payload_migrations_created_at_idx" ON "payload_migrations" USING btree ("created_at");`)
}

export async function down({ db, payload, req }: MigrateDownArgs): Promise<void> {
  await db.execute(sql`
   DROP TABLE "users_sessions" CASCADE;
  DROP TABLE "users" CASCADE;
  DROP TABLE "users_rels" CASCADE;
  DROP TABLE "groups" CASCADE;
  DROP TABLE "members" CASCADE;
  DROP TABLE "members_rels" CASCADE;
  DROP TABLE "attendance_sessions" CASCADE;
  DROP TABLE "attendance_records" CASCADE;
  DROP TABLE "payload_kv" CASCADE;
  DROP TABLE "payload_locked_documents" CASCADE;
  DROP TABLE "payload_locked_documents_rels" CASCADE;
  DROP TABLE "payload_preferences" CASCADE;
  DROP TABLE "payload_preferences_rels" CASCADE;
  DROP TABLE "payload_migrations" CASCADE;
  DROP TABLE "settings" CASCADE;
  DROP TYPE "public"."_locales";
  DROP TYPE "public"."enum_users_role";
  DROP TYPE "public"."enum_members_gender";
  DROP TYPE "public"."enum_members_parent1_relation";
  DROP TYPE "public"."enum_members_parent2_relation";
  DROP TYPE "public"."enum_members_status";
  DROP TYPE "public"."enum_attendance_records_status";`)
}
