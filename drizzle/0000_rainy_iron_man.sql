CREATE EXTENSION IF NOT EXISTS vector;--> statement-breakpoint
CREATE TYPE "public"."AuthProvider" AS ENUM('PHANTOM_WALLET', 'GOOGLE_OAUTH', 'EMAIL');--> statement-breakpoint
CREATE TYPE "public"."DataSourceType" AS ENUM('PDF', 'URL', 'TXT', 'DOCX', 'HTML', 'MD', 'CSV', 'QNA');--> statement-breakpoint
CREATE TABLE "analytics" (
	"id" serial PRIMARY KEY NOT NULL,
	"chatbot_id" integer NOT NULL,
	"responses" integer DEFAULT 0,
	"likes" integer DEFAULT 0,
	"dislikes" integer DEFAULT 0,
	"created_at" timestamp (6) with time zone DEFAULT now(),
	"updated_at" timestamp (6) with time zone DEFAULT now(),
	CONSTRAINT "unique_chatbot_id" UNIQUE("chatbot_id")
);
--> statement-breakpoint
CREATE TABLE "auth_method" (
	"created_at" timestamp(3) DEFAULT (now() AT TIME ZONE 'UTC'::text) NOT NULL,
	"updated_at" timestamp(3) DEFAULT (now() AT TIME ZONE 'UTC'::text) NOT NULL,
	"id" uuid PRIMARY KEY DEFAULT gen_random_uuid() NOT NULL,
	"user_id" uuid NOT NULL,
	"google_sub" text,
	"google_email" text,
	"provider" "AuthProvider" NOT NULL,
	"email" text
);
--> statement-breakpoint
CREATE TABLE "chatbot" (
	"id" serial PRIMARY KEY NOT NULL,
	"user_id" uuid NOT NULL,
	"name" varchar NOT NULL,
	"description" text NOT NULL,
	"system_prompt" text NOT NULL,
	"created_at" timestamp (6) with time zone DEFAULT now(),
	"updated_at" timestamp (6) with time zone DEFAULT now(),
	"api_key" varchar(255)
);
--> statement-breakpoint
CREATE TABLE "citation" (
	"id" serial PRIMARY KEY NOT NULL,
	"analytics_id" integer NOT NULL,
	"chatbot_id" integer NOT NULL,
	"source" text NOT NULL,
	"count" integer DEFAULT 1,
	"created_at" timestamp (6) DEFAULT now(),
	"updated_at" timestamp (6) DEFAULT now()
);
--> statement-breakpoint
CREATE TABLE "data_source" (
	"id" serial PRIMARY KEY NOT NULL,
	"chatbot_id" integer NOT NULL,
	"type" "DataSourceType" NOT NULL,
	"source_details" json NOT NULL,
	"created_at" timestamp (6) with time zone DEFAULT now(),
	"updated_at" timestamp (6) with time zone DEFAULT now(),
	"name" varchar NOT NULL,
	"citation" text
);
--> statement-breakpoint
CREATE TABLE "embeddings" (
	"id" serial PRIMARY KEY NOT NULL,
	"user_id" uuid NOT NULL,
	"chatbot_id" integer NOT NULL,
	"topic" varchar NOT NULL,
	"text" varchar NOT NULL,
	"vector" real[],
	"created_at" timestamp (6) with time zone DEFAULT now(),
	"updated_at" timestamp (6) with time zone DEFAULT now(),
	"data_source_id" integer,
	"citation" text
);
--> statement-breakpoint
CREATE TABLE "subscribed_users" (
	"subscription_id" serial PRIMARY KEY NOT NULL,
	"user_id" uuid NOT NULL,
	"plan_id" integer NOT NULL,
	"start_date" timestamp (6) DEFAULT now(),
	"expiry_date" timestamp (6) NOT NULL,
	"is_active" boolean DEFAULT true,
	"auto_renew" boolean DEFAULT false,
	"created_at" timestamp (6) DEFAULT now(),
	"updated_at" timestamp (6) DEFAULT now()
);
--> statement-breakpoint
CREATE TABLE "subscription_plans" (
	"plan_id" serial PRIMARY KEY NOT NULL,
	"plan_name" varchar(255) NOT NULL,
	"is_active" boolean DEFAULT true,
	"duration_in_days" integer NOT NULL,
	"created_at" timestamp (6) DEFAULT now(),
	"updated_at" timestamp (6) DEFAULT now(),
	"price_monthly" numeric(10, 2) NOT NULL,
	"price_annually" numeric(10, 2) NOT NULL
);
--> statement-breakpoint
CREATE TABLE "user" (
	"created_at" timestamp(3) DEFAULT (now() AT TIME ZONE 'UTC'::text) NOT NULL,
	"updated_at" timestamp(3) DEFAULT (now() AT TIME ZONE 'UTC'::text) NOT NULL,
	"is2fa_auth_enabled" boolean DEFAULT false NOT NULL,
	"is_banned" boolean DEFAULT false NOT NULL,
	"id" uuid PRIMARY KEY DEFAULT gen_random_uuid() NOT NULL,
	"email" text,
	"display_name" text NOT NULL,
	"avatar_url" text,
	"username" text
);
--> statement-breakpoint
ALTER TABLE "analytics" ADD CONSTRAINT "analytics_chatbot_id_fkey" FOREIGN KEY ("chatbot_id") REFERENCES "public"."chatbot"("id") ON DELETE cascade ON UPDATE cascade;--> statement-breakpoint
ALTER TABLE "auth_method" ADD CONSTRAINT "auth_method_user_id_fkey" FOREIGN KEY ("user_id") REFERENCES "public"."user"("id") ON DELETE cascade ON UPDATE cascade;--> statement-breakpoint
ALTER TABLE "chatbot" ADD CONSTRAINT "chatbot_user_id_fkey" FOREIGN KEY ("user_id") REFERENCES "public"."user"("id") ON DELETE cascade ON UPDATE cascade;--> statement-breakpoint
ALTER TABLE "citation" ADD CONSTRAINT "citation_analytics_id_fkey" FOREIGN KEY ("analytics_id") REFERENCES "public"."analytics"("id") ON DELETE cascade ON UPDATE cascade;--> statement-breakpoint
ALTER TABLE "citation" ADD CONSTRAINT "citation_chatbot_id_fkey" FOREIGN KEY ("chatbot_id") REFERENCES "public"."chatbot"("id") ON DELETE cascade ON UPDATE cascade;--> statement-breakpoint
ALTER TABLE "data_source" ADD CONSTRAINT "data_source_chatbot_id_fkey" FOREIGN KEY ("chatbot_id") REFERENCES "public"."chatbot"("id") ON DELETE cascade ON UPDATE cascade;--> statement-breakpoint
ALTER TABLE "embeddings" ADD CONSTRAINT "embeddings_user_id_fkey" FOREIGN KEY ("user_id") REFERENCES "public"."user"("id") ON DELETE cascade ON UPDATE cascade;--> statement-breakpoint
ALTER TABLE "embeddings" ADD CONSTRAINT "embeddings_chatbot_id_fkey" FOREIGN KEY ("chatbot_id") REFERENCES "public"."chatbot"("id") ON DELETE cascade ON UPDATE cascade;--> statement-breakpoint
ALTER TABLE "embeddings" ADD CONSTRAINT "embeddings_data_source_id_fkey" FOREIGN KEY ("data_source_id") REFERENCES "public"."data_source"("id") ON DELETE set null ON UPDATE cascade;--> statement-breakpoint
ALTER TABLE "subscribed_users" ADD CONSTRAINT "subscribed_users_user_id_fkey" FOREIGN KEY ("user_id") REFERENCES "public"."user"("id") ON DELETE cascade ON UPDATE cascade;--> statement-breakpoint
ALTER TABLE "subscribed_users" ADD CONSTRAINT "subscribed_users_plan_id_fkey" FOREIGN KEY ("plan_id") REFERENCES "public"."subscription_plans"("plan_id") ON DELETE restrict ON UPDATE cascade;--> statement-breakpoint
CREATE UNIQUE INDEX "auth_method_google_email_key" ON "auth_method" USING btree ("google_email");--> statement-breakpoint
CREATE UNIQUE INDEX "auth_method_google_sub_key" ON "auth_method" USING btree ("google_sub");--> statement-breakpoint
CREATE INDEX "auth_method_provider_idx" ON "auth_method" USING btree ("provider");--> statement-breakpoint
CREATE UNIQUE INDEX "auth_method_user_id_key" ON "auth_method" USING btree ("user_id");--> statement-breakpoint
CREATE INDEX "chatbot_user_id_idx" ON "chatbot" USING btree ("user_id");--> statement-breakpoint
CREATE UNIQUE INDEX "citation_chatbot_source_unq" ON "citation" USING btree ("chatbot_id","source");--> statement-breakpoint
CREATE INDEX "idx_datasource_citation" ON "data_source" USING btree ("citation");--> statement-breakpoint
CREATE INDEX "idx_embeddings_citation" ON "embeddings" USING btree ("citation");--> statement-breakpoint
CREATE INDEX "embeddings_chatbot_id_idx" ON "embeddings" USING btree ("chatbot_id");--> statement-breakpoint
CREATE INDEX "subscribed_users_user_id_idx" ON "subscribed_users" USING btree ("user_id");