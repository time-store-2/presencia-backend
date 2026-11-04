import { MigrateUpArgs, MigrateDownArgs, sql } from '@payloadcms/db-postgres'
import { normalizePhone } from '../lib/phone'

const TOKEN_ALPHABET = 'abcdefghijkmnpqrstuvwxyz23456789'

export async function up({ db, payload, req }: MigrateUpArgs): Promise<void> {
  await db.execute(sql`
   CREATE TABLE "registration_attempts" (
  	"id" serial PRIMARY KEY NOT NULL,
  	"ip_hash" varchar NOT NULL,
  	"updated_at" timestamp(3) with time zone DEFAULT now() NOT NULL,
  	"created_at" timestamp(3) with time zone DEFAULT now() NOT NULL
  );
  
  ALTER TABLE "users" ALTER COLUMN "role" SET DATA TYPE text;
  ALTER TABLE "users" ALTER COLUMN "role" SET DEFAULT 'admin'::text;
  UPDATE "users" SET "role" = 'pasteur' WHERE "role" = 'assistant';
  DROP TYPE "public"."enum_users_role";
  CREATE TYPE "public"."enum_users_role" AS ENUM('admin', 'pasteur');
  ALTER TABLE "users" ALTER COLUMN "role" SET DEFAULT 'admin'::"public"."enum_users_role";
  ALTER TABLE "users" ALTER COLUMN "role" SET DATA TYPE "public"."enum_users_role" USING "role"::"public"."enum_users_role";
  ALTER TABLE "groups" ALTER COLUMN "color" SET DEFAULT '#A13A15';
  ALTER TABLE "groups" ADD COLUMN "invite_token" varchar;
  ALTER TABLE "groups" ADD COLUMN "invite_enabled" boolean DEFAULT true;
  ALTER TABLE "groups" ADD COLUMN "owner_id" integer;
  ALTER TABLE "members" ADD COLUMN "created_by_id" integer;
  ALTER TABLE "payload_locked_documents_rels" ADD COLUMN "registration_attempts_id" integer;
  CREATE INDEX "registration_attempts_ip_hash_idx" ON "registration_attempts" USING btree ("ip_hash");
  CREATE INDEX "registration_attempts_updated_at_idx" ON "registration_attempts" USING btree ("updated_at");
  CREATE INDEX "registration_attempts_created_at_idx" ON "registration_attempts" USING btree ("created_at");
  ALTER TABLE "groups" ADD CONSTRAINT "groups_owner_id_users_id_fk" FOREIGN KEY ("owner_id") REFERENCES "public"."users"("id") ON DELETE set null ON UPDATE no action;
  ALTER TABLE "members" ADD CONSTRAINT "members_created_by_id_users_id_fk" FOREIGN KEY ("created_by_id") REFERENCES "public"."users"("id") ON DELETE set null ON UPDATE no action;
  ALTER TABLE "payload_locked_documents_rels" ADD CONSTRAINT "payload_locked_documents_rels_registration_attempts_fk" FOREIGN KEY ("registration_attempts_id") REFERENCES "public"."registration_attempts"("id") ON DELETE cascade ON UPDATE no action;
  CREATE UNIQUE INDEX "groups_invite_token_idx" ON "groups" USING btree ("invite_token");
  CREATE INDEX "groups_owner_idx" ON "groups" USING btree ("owner_id");
  CREATE INDEX "members_created_by_idx" ON "members" USING btree ("created_by_id");
  CREATE INDEX "payload_locked_documents_rels_registration_attempts_id_idx" ON "payload_locked_documents_rels" USING btree ("registration_attempts_id");`)

  // Liens d'inscription : un jeton aléatoire de 12 caractères par groupe
  // existant (les anciens liens ?groupe=<slug> ne fonctionnent plus).
  const groups = await db.execute(sql`SELECT "id" FROM "groups" WHERE "invite_token" IS NULL`)
  for (const row of groups.rows as Array<{ id: number }>) {
    const bytes = crypto.getRandomValues(new Uint8Array(12))
    let token = ''
    for (const b of bytes) token += TOKEN_ALPHABET[b % TOKEN_ALPHABET.length]
    await db.execute(sql`UPDATE "groups" SET "invite_token" = ${token}, "invite_enabled" = true WHERE "id" = ${row.id}`)
  }

  // Téléphones existants → format E.164 (+228…), membre et parents.
  const members = await db.execute(
    sql`SELECT "id", "phone", "parent1_phone", "parent2_phone" FROM "members"`,
  )
  for (const row of members.rows as Array<{
    id: number
    phone: string | null
    parent1_phone: string | null
    parent2_phone: string | null
  }>) {
    const phone = row.phone ? normalizePhone(row.phone) : row.phone
    const p1 = row.parent1_phone ? normalizePhone(row.parent1_phone) : row.parent1_phone
    const p2 = row.parent2_phone ? normalizePhone(row.parent2_phone) : row.parent2_phone
    if (phone !== row.phone || p1 !== row.parent1_phone || p2 !== row.parent2_phone) {
      await db.execute(
        sql`UPDATE "members" SET "phone" = ${phone}, "parent1_phone" = ${p1}, "parent2_phone" = ${p2} WHERE "id" = ${row.id}`,
      )
    }
  }
}

export async function down({ db, payload, req }: MigrateDownArgs): Promise<void> {
  await db.execute(sql`
   ALTER TABLE "registration_attempts" DISABLE ROW LEVEL SECURITY;
  DROP TABLE "registration_attempts" CASCADE;
  ALTER TABLE "groups" DROP CONSTRAINT "groups_owner_id_users_id_fk";
  
  ALTER TABLE "members" DROP CONSTRAINT "members_created_by_id_users_id_fk";
  
  ALTER TABLE "payload_locked_documents_rels" DROP CONSTRAINT "payload_locked_documents_rels_registration_attempts_fk";
  
  ALTER TABLE "users" ALTER COLUMN "role" SET DATA TYPE text;
  ALTER TABLE "users" ALTER COLUMN "role" SET DEFAULT 'admin'::text;
  UPDATE "users" SET "role" = 'assistant' WHERE "role" = 'pasteur';
  DROP TYPE "public"."enum_users_role";
  CREATE TYPE "public"."enum_users_role" AS ENUM('admin', 'assistant');
  ALTER TABLE "users" ALTER COLUMN "role" SET DEFAULT 'admin'::"public"."enum_users_role";
  ALTER TABLE "users" ALTER COLUMN "role" SET DATA TYPE "public"."enum_users_role" USING "role"::"public"."enum_users_role";
  DROP INDEX "groups_invite_token_idx";
  DROP INDEX "groups_owner_idx";
  DROP INDEX "members_created_by_idx";
  DROP INDEX "payload_locked_documents_rels_registration_attempts_id_idx";
  ALTER TABLE "groups" ALTER COLUMN "color" SET DEFAULT '#2196F3';
  ALTER TABLE "groups" DROP COLUMN "invite_token";
  ALTER TABLE "groups" DROP COLUMN "invite_enabled";
  ALTER TABLE "groups" DROP COLUMN "owner_id";
  ALTER TABLE "members" DROP COLUMN "created_by_id";
  ALTER TABLE "payload_locked_documents_rels" DROP COLUMN "registration_attempts_id";`)
}
