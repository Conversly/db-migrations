-- Rename whatsapp_contacts to contacts and add new columns
ALTER TABLE "whatsapp_contacts" RENAME TO "contacts";

-- Add new columns to contacts table
ALTER TABLE "contacts" ADD COLUMN "email" varchar(255);
ALTER TABLE "contacts" ADD COLUMN "channels" text[] DEFAULT ARRAY[]::text[] NOT NULL;
ALTER TABLE "contacts" ADD COLUMN "metadata" json DEFAULT '{}'::json NOT NULL;

-- Rename column display_name if it doesn't exist (it might be named differently)
DO $$ 
BEGIN
  IF NOT EXISTS (SELECT 1 FROM information_schema.columns WHERE table_name = 'contacts' AND column_name = 'display_name') THEN
    IF EXISTS (SELECT 1 FROM information_schema.columns WHERE table_name = 'contacts' AND column_name = 'name') THEN
      ALTER TABLE "contacts" RENAME COLUMN "name" TO "display_name";
    END IF;
  END IF;
END $$;

-- Update channels array to include WHATSAPP for existing contacts
UPDATE "contacts" SET "channels" = ARRAY['WHATSAPP']::text[] WHERE "phone_number" IS NOT NULL;

-- Drop old indexes and constraints
DROP INDEX IF EXISTS "whatsapp_contacts_chatbot_id_phone_number_unique";
DROP INDEX IF EXISTS "whatsapp_contacts_chatbot_id_idx";

-- Recreate indexes with new names
CREATE INDEX IF NOT EXISTS "contacts_chatbot_idx" ON "contacts" USING btree ("chatbot_id");
CREATE INDEX IF NOT EXISTS "contacts_phone_number_idx" ON "contacts" USING btree ("phone_number");
CREATE INDEX IF NOT EXISTS "contacts_email_idx" ON "contacts" USING btree ("email");

-- Create new marketing tables
DO $$ BEGIN
 CREATE TYPE "public"."TemplateStatus" AS ENUM('APPROVED', 'PENDING', 'REJECTED', 'ACTIVE');
EXCEPTION
 WHEN duplicate_object THEN null;
END $$;

DO $$ BEGIN
 CREATE TYPE "public"."CampaignStatus" AS ENUM('DRAFT', 'SCHEDULED', 'PROCESSING', 'COMPLETED', 'FAILED');
EXCEPTION
 WHEN duplicate_object THEN null;
END $$;

DO $$ BEGIN
 CREATE TYPE "public"."CampaignAudienceStatus" AS ENUM('PENDING', 'SENT', 'DELIVERED', 'READ', 'FAILED');
EXCEPTION
 WHEN duplicate_object THEN null;
END $$;

-- Templates table
CREATE TABLE IF NOT EXISTS "templates" (
  "id" text PRIMARY KEY NOT NULL,
  "chatbot_id" text NOT NULL,
  "channel" text NOT NULL,
  "name" varchar(255) NOT NULL,
  "subject" varchar(255),
  "content" text NOT NULL,
  "variables" json DEFAULT '[]'::json NOT NULL,
  "status" "TemplateStatus" DEFAULT 'ACTIVE' NOT NULL,
  "meta_template_id" varchar(255),
  "language" varchar(10),
  "category" varchar(50),
  "components" json,
  "created_at" timestamp (6) DEFAULT now(),
  "updated_at" timestamp (6) DEFAULT now()
);

-- Campaigns table
CREATE TABLE IF NOT EXISTS "campaigns" (
  "id" text PRIMARY KEY NOT NULL,
  "chatbot_id" text NOT NULL,
  "name" varchar(255) NOT NULL,
  "channel" text NOT NULL,
  "template_id" text NOT NULL,
  "status" "CampaignStatus" DEFAULT 'DRAFT' NOT NULL,
  "scheduled_at" timestamp (6),
  "sent_count" integer DEFAULT 0 NOT NULL,
  "delivered_count" integer DEFAULT 0 NOT NULL,
  "read_count" integer DEFAULT 0 NOT NULL,
  "replied_count" integer DEFAULT 0 NOT NULL,
  "created_at" timestamp (6) DEFAULT now(),
  "updated_at" timestamp (6) DEFAULT now()
);

-- Campaign Audience table
CREATE TABLE IF NOT EXISTS "campaign_audience" (
  "id" text PRIMARY KEY NOT NULL,
  "campaign_id" text NOT NULL,
  "contact_id" text NOT NULL,
  "status" "CampaignAudienceStatus" DEFAULT 'PENDING' NOT NULL,
  "sent_at" timestamp (6),
  "delivered_at" timestamp (6),
  "read_at" timestamp (6),
  "message_id" text,
  "error_message" text,
  "created_at" timestamp (6) DEFAULT now(),
  "updated_at" timestamp (6) DEFAULT now()
);

-- Channel Accounts table
CREATE TABLE IF NOT EXISTS "channel_accounts" (
  "id" text PRIMARY KEY NOT NULL,
  "chatbot_id" text NOT NULL,
  "channel" text NOT NULL,
  "provider" varchar(50) NOT NULL,
  "account_ref_id" text NOT NULL,
  "is_default" boolean DEFAULT false,
  "is_active" boolean DEFAULT true,
  "created_at" timestamp (6) DEFAULT now()
);

-- SMS Accounts table
CREATE TABLE IF NOT EXISTS "sms_accounts" (
  "id" text PRIMARY KEY NOT NULL,
  "chatbot_id" text NOT NULL,
  "provider" varchar(50) NOT NULL,
  "sender_id" varchar(50) NOT NULL,
  "api_key" text,
  "api_secret" text,
  "status" text DEFAULT 'active' NOT NULL,
  "created_at" timestamp (6) DEFAULT now(),
  "updated_at" timestamp (6) DEFAULT now()
);

-- Email Accounts table
CREATE TABLE IF NOT EXISTS "email_accounts" (
  "id" text PRIMARY KEY NOT NULL,
  "chatbot_id" text NOT NULL,
  "provider" varchar(50) NOT NULL,
  "from_email" varchar(255) NOT NULL,
  "from_name" varchar(255),
  "api_key" text,
  "api_secret" text,
  "smtp_host" varchar(255),
  "smtp_port" integer,
  "smtp_username" varchar(255),
  "smtp_password" text,
  "status" text DEFAULT 'active' NOT NULL,
  "created_at" timestamp (6) DEFAULT now(),
  "updated_at" timestamp (6) DEFAULT now()
);

-- Add foreign keys
DO $$ BEGIN
 ALTER TABLE "templates" ADD CONSTRAINT "templates_chatbot_id_chatbot_id_fk" FOREIGN KEY ("chatbot_id") REFERENCES "public"."chatbot"("id") ON DELETE cascade ON UPDATE cascade;
EXCEPTION
 WHEN duplicate_object THEN null;
END $$;

DO $$ BEGIN
 ALTER TABLE "campaigns" ADD CONSTRAINT "campaigns_chatbot_id_chatbot_id_fk" FOREIGN KEY ("chatbot_id") REFERENCES "public"."chatbot"("id") ON DELETE cascade ON UPDATE cascade;
EXCEPTION
 WHEN duplicate_object THEN null;
END $$;

DO $$ BEGIN
 ALTER TABLE "campaigns" ADD CONSTRAINT "campaigns_template_id_templates_id_fk" FOREIGN KEY ("template_id") REFERENCES "public"."templates"("id") ON DELETE cascade ON UPDATE cascade;
EXCEPTION
 WHEN duplicate_object THEN null;
END $$;

DO $$ BEGIN
 ALTER TABLE "campaign_audience" ADD CONSTRAINT "campaign_audience_campaign_id_campaigns_id_fk" FOREIGN KEY ("campaign_id") REFERENCES "public"."campaigns"("id") ON DELETE cascade ON UPDATE cascade;
EXCEPTION
 WHEN duplicate_object THEN null;
END $$;

DO $$ BEGIN
 ALTER TABLE "campaign_audience" ADD CONSTRAINT "campaign_audience_contact_id_contacts_id_fk" FOREIGN KEY ("contact_id") REFERENCES "public"."contacts"("id") ON DELETE cascade ON UPDATE cascade;
EXCEPTION
 WHEN duplicate_object THEN null;
END $$;

DO $$ BEGIN
 ALTER TABLE "channel_accounts" ADD CONSTRAINT "channel_accounts_chatbot_id_chatbot_id_fk" FOREIGN KEY ("chatbot_id") REFERENCES "public"."chatbot"("id") ON DELETE cascade ON UPDATE cascade;
EXCEPTION
 WHEN duplicate_object THEN null;
END $$;

DO $$ BEGIN
 ALTER TABLE "sms_accounts" ADD CONSTRAINT "sms_accounts_chatbot_id_chatbot_id_fk" FOREIGN KEY ("chatbot_id") REFERENCES "public"."chatbot"("id") ON DELETE cascade ON UPDATE cascade;
EXCEPTION
 WHEN duplicate_object THEN null;
END $$;

DO $$ BEGIN
 ALTER TABLE "email_accounts" ADD CONSTRAINT "email_accounts_chatbot_id_chatbot_id_fk" FOREIGN KEY ("chatbot_id") REFERENCES "public"."chatbot"("id") ON DELETE cascade ON UPDATE cascade;
EXCEPTION
 WHEN duplicate_object THEN null;
END $$;

-- Create indexes
CREATE INDEX IF NOT EXISTS "templates_chatbot_idx" ON "templates" USING btree ("chatbot_id");
CREATE INDEX IF NOT EXISTS "templates_channel_idx" ON "templates" USING btree ("channel");
CREATE INDEX IF NOT EXISTS "campaigns_chatbot_idx" ON "campaigns" USING btree ("chatbot_id");
CREATE INDEX IF NOT EXISTS "campaigns_channel_idx" ON "campaigns" USING btree ("channel");
CREATE INDEX IF NOT EXISTS "campaign_audience_campaign_idx" ON "campaign_audience" USING btree ("campaign_id");
CREATE INDEX IF NOT EXISTS "channel_accounts_chatbot_channel_idx" ON "channel_accounts" USING btree ("chatbot_id", "channel");
CREATE INDEX IF NOT EXISTS "sms_accounts_chatbot_idx" ON "sms_accounts" USING btree ("chatbot_id");
CREATE INDEX IF NOT EXISTS "email_accounts_chatbot_idx" ON "email_accounts" USING btree ("chatbot_id");

-- Create unique constraints
DO $$ BEGIN
 ALTER TABLE "campaign_audience" ADD CONSTRAINT "campaign_audience_unique" UNIQUE ("campaign_id", "contact_id");
EXCEPTION
 WHEN duplicate_object THEN null;
END $$;
