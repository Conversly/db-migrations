DO $$ BEGIN
 IF NOT EXISTS (SELECT 1 FROM pg_type WHERE typname = 'test_status' AND typnamespace = (SELECT oid FROM pg_namespace WHERE nspname = 'public')) THEN
  CREATE TYPE "public"."test_status" AS ENUM('not_tested', 'passed', 'failed', 'error');
 END IF;
END $$;--> statement-breakpoint
DO $$ BEGIN
 IF NOT EXISTS (SELECT 1 FROM pg_enum WHERE enumlabel = 'PHANTOM_WALLET' AND enumtypid = (SELECT oid FROM pg_type WHERE typname = 'AuthProvider')) THEN
  ALTER TYPE "public"."AuthProvider" ADD VALUE 'PHANTOM_WALLET' BEFORE 'GOOGLE_OAUTH';
 END IF;
END $$;--> statement-breakpoint
CREATE TABLE IF NOT EXISTS "chatbot_channel_prompts" (
	"id" text PRIMARY KEY NOT NULL,
	"chatbot_id" text NOT NULL,
	"channel" "MessageChannel" NOT NULL,
	"system_prompt" text NOT NULL,
	"created_at" timestamp (6) with time zone DEFAULT now(),
	"updated_at" timestamp (6) with time zone DEFAULT now(),
	CONSTRAINT "chatbot_channel_prompts_chatbot_channel_unique" UNIQUE("chatbot_id","channel")
);
--> statement-breakpoint
CREATE TABLE IF NOT EXISTS "product_launches" (
	"id" text PRIMARY KEY NOT NULL,
	"user_id" text NOT NULL,
	"name" text NOT NULL,
	"tagline" text,
	"description" text,
	"logo_url" text,
	"website_url" text,
	"launch_date" timestamp (6) with time zone DEFAULT now(),
	"chatbot_id" text,
	"tags" json DEFAULT '[]'::json,
	"likes_count" integer DEFAULT 0 NOT NULL,
	"key_features" json DEFAULT '[]'::json,
	"theme" json DEFAULT '{}'::json,
	"media" json DEFAULT '[]'::json,
	"team" json DEFAULT '[]'::json,
	"comments" json DEFAULT '[]'::json,
	"announcement" json DEFAULT '{}'::json,
	"countdown" json DEFAULT '{}'::json,
	"social_links" json DEFAULT '{}'::json,
	"created_at" timestamp (6) with time zone DEFAULT now(),
	"updated_at" timestamp (6) with time zone DEFAULT now()
);
--> statement-breakpoint
ALTER TABLE "custom_actions" ALTER COLUMN "test_status" DROP DEFAULT;--> statement-breakpoint
ALTER TABLE "custom_actions" ALTER COLUMN "test_status" SET DATA TYPE "public"."test_status" USING "test_status"::text::"public"."test_status";--> statement-breakpoint
ALTER TABLE "custom_actions" ALTER COLUMN "test_status" SET DEFAULT 'not_tested';--> statement-breakpoint
DO $$ BEGIN
 IF NOT EXISTS (SELECT 1 FROM pg_constraint WHERE conname = 'chatbot_channel_prompts_chatbot_id_chatbot_id_fk') THEN
  ALTER TABLE "chatbot_channel_prompts" ADD CONSTRAINT "chatbot_channel_prompts_chatbot_id_chatbot_id_fk" FOREIGN KEY ("chatbot_id") REFERENCES "public"."chatbot"("id") ON DELETE cascade ON UPDATE cascade;
 END IF;
END $$;--> statement-breakpoint
DO $$ BEGIN
 IF NOT EXISTS (SELECT 1 FROM pg_constraint WHERE conname = 'product_launches_user_id_user_id_fk') THEN
  ALTER TABLE "product_launches" ADD CONSTRAINT "product_launches_user_id_user_id_fk" FOREIGN KEY ("user_id") REFERENCES "public"."user"("id") ON DELETE cascade ON UPDATE cascade;
 END IF;
END $$;--> statement-breakpoint
DO $$ BEGIN
 IF NOT EXISTS (SELECT 1 FROM pg_constraint WHERE conname = 'product_launches_chatbot_id_chatbot_id_fk') THEN
  ALTER TABLE "product_launches" ADD CONSTRAINT "product_launches_chatbot_id_chatbot_id_fk" FOREIGN KEY ("chatbot_id") REFERENCES "public"."chatbot"("id") ON DELETE set null ON UPDATE cascade;
 END IF;
END $$;--> statement-breakpoint
CREATE INDEX IF NOT EXISTS "chatbot_channel_prompts_chatbot_id_idx" ON "chatbot_channel_prompts" USING btree ("chatbot_id");--> statement-breakpoint
CREATE INDEX IF NOT EXISTS "product_launches_user_id_idx" ON "product_launches" USING btree ("user_id");--> statement-breakpoint
CREATE INDEX IF NOT EXISTS "product_launches_chatbot_id_idx" ON "product_launches" USING btree ("chatbot_id");--> statement-breakpoint
CREATE INDEX IF NOT EXISTS "product_launches_launch_date_idx" ON "product_launches" USING btree ("launch_date" DESC NULLS LAST);--> statement-breakpoint
CREATE INDEX IF NOT EXISTS "product_launches_likes_count_idx" ON "product_launches" USING btree ("likes_count" DESC NULLS LAST);--> statement-breakpoint
DO $$ BEGIN
 IF EXISTS (SELECT 1 FROM information_schema.columns WHERE table_name = 'auth_method' AND column_name = 'password_hash') THEN
  ALTER TABLE "auth_method" DROP COLUMN "password_hash";
 END IF;
END $$;--> statement-breakpoint
DROP TYPE IF EXISTS "public"."ApiMethod";--> statement-breakpoint
DROP TYPE IF EXISTS "public"."TestStatus";