CREATE TYPE "public"."Align" AS ENUM('left', 'right');--> statement-breakpoint
CREATE TYPE "public"."AuthProvider" AS ENUM('PHANTOM_WALLET', 'GOOGLE_OAUTH', 'EMAIL');--> statement-breakpoint
CREATE TYPE "public"."ChatbotStatus" AS ENUM('DRAFT', 'TRAINING', 'ACTIVE', 'INACTIVE');--> statement-breakpoint
CREATE TYPE "public"."DataSourceStatus" AS ENUM('DRAFT', 'QUEUEING', 'PROCESSING', 'COMPLETED', 'FAILED');--> statement-breakpoint
CREATE TYPE "public"."DataSourceType" AS ENUM('PDF', 'URL', 'TXT', 'DOCX', 'HTML', 'MD', 'CSV', 'QNA', 'DOCUMENT');--> statement-breakpoint
CREATE TYPE "public"."DisplayStyle" AS ENUM('corner', 'overlay');--> statement-breakpoint
CREATE TYPE "public"."MessageChannel" AS ENUM('WIDGET', 'WHATSAPP');--> statement-breakpoint
CREATE TYPE "public"."MessageType" AS ENUM('user', 'assistant', 'agent');--> statement-breakpoint
CREATE TYPE "public"."Theme" AS ENUM('light', 'dark');--> statement-breakpoint
CREATE TYPE "public"."WhatsappAccountStatus" AS ENUM('active', 'inactive');--> statement-breakpoint
CREATE TYPE "public"."WhatsappConversationStatus" AS ENUM('open', 'closed', 'pending', 'escalated');--> statement-breakpoint
CREATE TYPE "public"."WhatsappMessageStatus" AS ENUM('sent', 'delivered', 'read', 'failed');--> statement-breakpoint
CREATE TYPE "public"."WhatsappMessageType" AS ENUM('text', 'image', 'video', 'document', 'template');--> statement-breakpoint
CREATE TYPE "public"."WhatsappSenderType" AS ENUM('user', 'ai', 'agent', 'system');--> statement-breakpoint
CREATE TYPE "public"."WhatsappSource" AS ENUM('organic', 'imported', 'campaign', 'api');--> statement-breakpoint
CREATE TABLE "analytics" (
	"id" text PRIMARY KEY NOT NULL,
	"chatbot_id" text NOT NULL,
	"responses" integer DEFAULT 0,
	"likes" integer DEFAULT 0,
	"dislikes" integer DEFAULT 0,
	"created_at" timestamp (6) with time zone DEFAULT now(),
	"updated_at" timestamp (6) with time zone DEFAULT now(),
	CONSTRAINT "unique_chatbot_id" UNIQUE("chatbot_id")
);
--> statement-breakpoint
CREATE TABLE "analytics_per_day" (
	"id" text PRIMARY KEY NOT NULL,
	"chatbot_id" text NOT NULL,
	"date" date DEFAULT CURRENT_DATE NOT NULL,
	"user_messages" integer DEFAULT 0 NOT NULL,
	"ai_responses" integer DEFAULT 0 NOT NULL,
	"agent_responses" integer DEFAULT 0 NOT NULL,
	"like_count" integer DEFAULT 0 NOT NULL,
	"dislike_count" integer DEFAULT 0 NOT NULL,
	"feedback_count" integer DEFAULT 0 NOT NULL,
	"unique_widget_conversations" integer DEFAULT 0 NOT NULL,
	"unique_whatsapp_conversations" integer DEFAULT 0 NOT NULL,
	"unique_contacts" integer DEFAULT 0 NOT NULL,
	"unique_topic_ids" text[] DEFAULT ARRAY[]::text[] NOT NULL,
	"created_at" timestamp (6) DEFAULT now(),
	"updated_at" timestamp (6) DEFAULT now()
);
--> statement-breakpoint
CREATE TABLE "auth_method" (
	"created_at" timestamp(3) DEFAULT (now() AT TIME ZONE 'UTC'::text) NOT NULL,
	"updated_at" timestamp(3) DEFAULT (now() AT TIME ZONE 'UTC'::text) NOT NULL,
	"id" text PRIMARY KEY NOT NULL,
	"user_id" text NOT NULL,
	"google_sub" text,
	"google_email" text,
	"provider" "AuthProvider" NOT NULL,
	"email" text
);
--> statement-breakpoint
CREATE TABLE "chatbot" (
	"id" text PRIMARY KEY NOT NULL,
	"user_id" text NOT NULL,
	"name" varchar NOT NULL,
	"description" text NOT NULL,
	"system_prompt" text NOT NULL,
	"logo_url" text DEFAULT '',
	"primary_color" varchar(7) DEFAULT '#007bff' NOT NULL,
	"topics" text[] DEFAULT ARRAY[]::text[] NOT NULL,
	"status" "ChatbotStatus" DEFAULT 'INACTIVE' NOT NULL,
	"created_at" timestamp (6) with time zone DEFAULT now(),
	"updated_at" timestamp (6) with time zone DEFAULT now(),
	"api_key" varchar(255)
);
--> statement-breakpoint
CREATE TABLE "chatbot_topic_stats" (
	"id" text PRIMARY KEY NOT NULL,
	"chatbot_id" text NOT NULL,
	"topic_id" text NOT NULL,
	"like_count" integer DEFAULT 0 NOT NULL,
	"dislike_count" integer DEFAULT 0 NOT NULL,
	"message_count" integer DEFAULT 0 NOT NULL,
	"date" date DEFAULT CURRENT_DATE NOT NULL,
	CONSTRAINT "chatbot_topic_date_unique" UNIQUE("chatbot_id","topic_id","date")
);
--> statement-breakpoint
CREATE TABLE "chatbot_topics" (
	"id" text PRIMARY KEY NOT NULL,
	"chatbot_id" text NOT NULL,
	"name" varchar(255) NOT NULL,
	"color" varchar(7) DEFAULT '#888888',
	"created_at" timestamp DEFAULT now()
);
--> statement-breakpoint
CREATE TABLE "citation" (
	"id" text PRIMARY KEY NOT NULL,
	"analytics_id" text NOT NULL,
	"chatbot_id" text NOT NULL,
	"source" text NOT NULL,
	"count" integer DEFAULT 1,
	"created_at" timestamp (6) DEFAULT now(),
	"updated_at" timestamp (6) DEFAULT now()
);
--> statement-breakpoint
CREATE TABLE "data_source" (
	"id" text PRIMARY KEY NOT NULL,
	"chatbot_id" text NOT NULL,
	"type" "DataSourceType" NOT NULL,
	"source_details" json NOT NULL,
	"created_at" timestamp (6) with time zone DEFAULT now(),
	"updated_at" timestamp (6) with time zone DEFAULT now(),
	"name" varchar NOT NULL,
	"status" "DataSourceStatus" DEFAULT 'QUEUEING' NOT NULL,
	"citation" text
);
--> statement-breakpoint
CREATE TABLE "embeddings" (
	"id" text PRIMARY KEY NOT NULL,
	"user_id" text NOT NULL,
	"chatbot_id" text NOT NULL,
	"text" varchar NOT NULL,
	"vector" real[],
	"created_at" timestamp (6) with time zone DEFAULT now(),
	"updated_at" timestamp (6) with time zone DEFAULT now(),
	"data_source_id" text,
	"citation" text
);
--> statement-breakpoint
CREATE TABLE "messages" (
	"id" text PRIMARY KEY NOT NULL,
	"unique_conv_id" text,
	"chatbot_id" text NOT NULL,
	"channel" "MessageChannel" DEFAULT 'WIDGET' NOT NULL,
	"type" "MessageType" DEFAULT 'user' NOT NULL,
	"content" text NOT NULL,
	"citations" text[] DEFAULT ARRAY[]::text[] NOT NULL,
	"feedback" smallint DEFAULT 0 NOT NULL,
	"feedback_comment" text,
	"channel_message_metadata" json,
	"created_at" timestamp (6) with time zone DEFAULT now(),
	"topic_id" text
);
--> statement-breakpoint
CREATE TABLE "origin_domains" (
	"id" text PRIMARY KEY NOT NULL,
	"user_id" text NOT NULL,
	"chatbot_id" text NOT NULL,
	"api_key" varchar(255) NOT NULL,
	"domain" varchar NOT NULL,
	"created_at" timestamp (6) DEFAULT now()
);
--> statement-breakpoint
CREATE TABLE "subscribed_users" (
	"subscription_id" text PRIMARY KEY NOT NULL,
	"user_id" text NOT NULL,
	"plan_id" text NOT NULL,
	"start_date" timestamp (6) DEFAULT now(),
	"expiry_date" timestamp (6) NOT NULL,
	"is_active" boolean DEFAULT true,
	"auto_renew" boolean DEFAULT false,
	"created_at" timestamp (6) DEFAULT now(),
	"updated_at" timestamp (6) DEFAULT now()
);
--> statement-breakpoint
CREATE TABLE "subscription_plans" (
	"plan_id" text PRIMARY KEY NOT NULL,
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
	"id" text PRIMARY KEY NOT NULL,
	"email" text,
	"display_name" text NOT NULL,
	"avatar_url" text,
	"username" text
);
--> statement-breakpoint
CREATE TABLE "whatsapp_analytics_per_day" (
	"id" text PRIMARY KEY NOT NULL,
	"chatbot_id" text NOT NULL,
	"date" date DEFAULT CURRENT_DATE NOT NULL
);
--> statement-breakpoint
CREATE TABLE "whatsapp_accounts" (
	"id" text PRIMARY KEY NOT NULL,
	"chatbot_id" text NOT NULL,
	"phone_number" varchar(20) NOT NULL,
	"waba_id" varchar(255) NOT NULL,
	"phone_number_id" varchar(255) NOT NULL,
	"access_token" text NOT NULL,
	"verified_name" varchar(255) NOT NULL,
	"status" "WhatsappAccountStatus" DEFAULT 'active' NOT NULL,
	"whatsapp_business_id" varchar(255) NOT NULL,
	"webhook_url" text,
	"verify_token" varchar(255),
	"created_at" timestamp (6) DEFAULT now(),
	"updated_at" timestamp (6) DEFAULT now(),
	CONSTRAINT "whatsapp_accounts_phone_number_unique" UNIQUE("phone_number"),
	CONSTRAINT "whatsapp_accounts_chatbot_id_unique" UNIQUE("chatbot_id")
);
--> statement-breakpoint
CREATE TABLE "whatsapp_contacts" (
	"id" text PRIMARY KEY NOT NULL,
	"chatbot_id" text NOT NULL,
	"phone_number" varchar(255) NOT NULL,
	"display_name" varchar(255),
	"whatsapp_user_metadata" json NOT NULL,
	"created_at" timestamp (6) DEFAULT now(),
	"updated_at" timestamp (6) DEFAULT now()
);
--> statement-breakpoint
CREATE TABLE "widget_config" (
	"id" text PRIMARY KEY NOT NULL,
	"chatbot_id" text NOT NULL,
	"styles" json NOT NULL,
	"only_allow_on_added_domains" boolean DEFAULT false NOT NULL,
	"initial_message" text NOT NULL,
	"suggested_messages" text[] DEFAULT ARRAY[]::text[] NOT NULL,
	"allowed_domains" text[] DEFAULT ARRAY[]::text[] NOT NULL,
	"created_at" timestamp (6) with time zone DEFAULT now(),
	"updated_at" timestamp (6) with time zone DEFAULT now(),
	CONSTRAINT "widget_config_chatbot_id_unique" UNIQUE("chatbot_id")
);
--> statement-breakpoint
ALTER TABLE "analytics" ADD CONSTRAINT "analytics_chatbot_id_fkey" FOREIGN KEY ("chatbot_id") REFERENCES "public"."chatbot"("id") ON DELETE cascade ON UPDATE cascade;--> statement-breakpoint
ALTER TABLE "analytics_per_day" ADD CONSTRAINT "analytics_per_day_chatbot_id_chatbot_id_fk" FOREIGN KEY ("chatbot_id") REFERENCES "public"."chatbot"("id") ON DELETE cascade ON UPDATE cascade;--> statement-breakpoint
ALTER TABLE "auth_method" ADD CONSTRAINT "auth_method_user_id_fkey" FOREIGN KEY ("user_id") REFERENCES "public"."user"("id") ON DELETE cascade ON UPDATE cascade;--> statement-breakpoint
ALTER TABLE "chatbot" ADD CONSTRAINT "chatbot_user_id_fkey" FOREIGN KEY ("user_id") REFERENCES "public"."user"("id") ON DELETE cascade ON UPDATE cascade;--> statement-breakpoint
ALTER TABLE "chatbot_topic_stats" ADD CONSTRAINT "chatbot_topic_stats_chatbot_id_chatbot_id_fk" FOREIGN KEY ("chatbot_id") REFERENCES "public"."chatbot"("id") ON DELETE cascade ON UPDATE cascade;--> statement-breakpoint
ALTER TABLE "chatbot_topic_stats" ADD CONSTRAINT "chatbot_topic_stats_topic_id_chatbot_topics_id_fk" FOREIGN KEY ("topic_id") REFERENCES "public"."chatbot_topics"("id") ON DELETE cascade ON UPDATE cascade;--> statement-breakpoint
ALTER TABLE "chatbot_topics" ADD CONSTRAINT "chatbot_topics_chatbot_id_fkey" FOREIGN KEY ("chatbot_id") REFERENCES "public"."chatbot"("id") ON DELETE cascade ON UPDATE cascade;--> statement-breakpoint
ALTER TABLE "citation" ADD CONSTRAINT "citation_analytics_id_fkey" FOREIGN KEY ("analytics_id") REFERENCES "public"."analytics"("id") ON DELETE cascade ON UPDATE cascade;--> statement-breakpoint
ALTER TABLE "citation" ADD CONSTRAINT "citation_chatbot_id_fkey" FOREIGN KEY ("chatbot_id") REFERENCES "public"."chatbot"("id") ON DELETE cascade ON UPDATE cascade;--> statement-breakpoint
ALTER TABLE "data_source" ADD CONSTRAINT "data_source_chatbot_id_fkey" FOREIGN KEY ("chatbot_id") REFERENCES "public"."chatbot"("id") ON DELETE cascade ON UPDATE cascade;--> statement-breakpoint
ALTER TABLE "embeddings" ADD CONSTRAINT "embeddings_user_id_fkey" FOREIGN KEY ("user_id") REFERENCES "public"."user"("id") ON DELETE cascade ON UPDATE cascade;--> statement-breakpoint
ALTER TABLE "embeddings" ADD CONSTRAINT "embeddings_chatbot_id_fkey" FOREIGN KEY ("chatbot_id") REFERENCES "public"."chatbot"("id") ON DELETE cascade ON UPDATE cascade;--> statement-breakpoint
ALTER TABLE "embeddings" ADD CONSTRAINT "embeddings_data_source_id_fkey" FOREIGN KEY ("data_source_id") REFERENCES "public"."data_source"("id") ON DELETE set null ON UPDATE cascade;--> statement-breakpoint
ALTER TABLE "messages" ADD CONSTRAINT "messages_chatbot_id_chatbot_id_fk" FOREIGN KEY ("chatbot_id") REFERENCES "public"."chatbot"("id") ON DELETE cascade ON UPDATE cascade;--> statement-breakpoint
ALTER TABLE "messages" ADD CONSTRAINT "messages_topic_id_chatbot_topics_id_fk" FOREIGN KEY ("topic_id") REFERENCES "public"."chatbot_topics"("id") ON DELETE set null ON UPDATE cascade;--> statement-breakpoint
ALTER TABLE "origin_domains" ADD CONSTRAINT "origin_domains_chatbot_id_fkey" FOREIGN KEY ("chatbot_id") REFERENCES "public"."chatbot"("id") ON DELETE cascade ON UPDATE cascade;--> statement-breakpoint
ALTER TABLE "origin_domains" ADD CONSTRAINT "origin_domains_user_id_fkey" FOREIGN KEY ("user_id") REFERENCES "public"."user"("id") ON DELETE cascade ON UPDATE cascade;--> statement-breakpoint
ALTER TABLE "subscribed_users" ADD CONSTRAINT "subscribed_users_user_id_fkey" FOREIGN KEY ("user_id") REFERENCES "public"."user"("id") ON DELETE cascade ON UPDATE cascade;--> statement-breakpoint
ALTER TABLE "subscribed_users" ADD CONSTRAINT "subscribed_users_plan_id_fkey" FOREIGN KEY ("plan_id") REFERENCES "public"."subscription_plans"("plan_id") ON DELETE restrict ON UPDATE cascade;--> statement-breakpoint
ALTER TABLE "whatsapp_analytics_per_day" ADD CONSTRAINT "whatsapp_analytics_per_day_chatbot_id_chatbot_id_fk" FOREIGN KEY ("chatbot_id") REFERENCES "public"."chatbot"("id") ON DELETE cascade ON UPDATE cascade;--> statement-breakpoint
ALTER TABLE "whatsapp_accounts" ADD CONSTRAINT "whatsapp_accounts_chatbot_id_chatbot_id_fk" FOREIGN KEY ("chatbot_id") REFERENCES "public"."chatbot"("id") ON DELETE cascade ON UPDATE cascade;--> statement-breakpoint
ALTER TABLE "whatsapp_contacts" ADD CONSTRAINT "whatsapp_contacts_chatbot_id_chatbot_id_fk" FOREIGN KEY ("chatbot_id") REFERENCES "public"."chatbot"("id") ON DELETE cascade ON UPDATE cascade;--> statement-breakpoint
ALTER TABLE "widget_config" ADD CONSTRAINT "widget_config_chatbot_id_chatbot_id_fk" FOREIGN KEY ("chatbot_id") REFERENCES "public"."chatbot"("id") ON DELETE cascade ON UPDATE cascade;--> statement-breakpoint
CREATE UNIQUE INDEX "analytics_per_day_chatbot_date_unique" ON "analytics_per_day" USING btree ("chatbot_id","date");--> statement-breakpoint
CREATE INDEX "analytics_per_day_chatbot_date_idx" ON "analytics_per_day" USING btree ("chatbot_id","date" DESC NULLS LAST);--> statement-breakpoint
CREATE UNIQUE INDEX "auth_method_google_email_key" ON "auth_method" USING btree ("google_email");--> statement-breakpoint
CREATE UNIQUE INDEX "auth_method_google_sub_key" ON "auth_method" USING btree ("google_sub");--> statement-breakpoint
CREATE INDEX "auth_method_provider_idx" ON "auth_method" USING btree ("provider");--> statement-breakpoint
CREATE UNIQUE INDEX "auth_method_user_id_key" ON "auth_method" USING btree ("user_id");--> statement-breakpoint
CREATE INDEX "chatbot_user_id_idx" ON "chatbot" USING btree ("user_id");--> statement-breakpoint
CREATE INDEX "chatbot_topic_stats_chatbot_date_idx" ON "chatbot_topic_stats" USING btree ("chatbot_id","date" DESC NULLS LAST);--> statement-breakpoint
CREATE INDEX "chatbot_topic_stats_chatbot_topic_date_idx" ON "chatbot_topic_stats" USING btree ("chatbot_id","topic_id","date" DESC NULLS LAST);--> statement-breakpoint
CREATE INDEX "chatbot_topics_chatbot_id_idx" ON "chatbot_topics" USING btree ("chatbot_id");--> statement-breakpoint
CREATE UNIQUE INDEX "citation_chatbot_source_unq" ON "citation" USING btree ("chatbot_id","source");--> statement-breakpoint
CREATE INDEX "idx_datasource_citation" ON "data_source" USING btree ("citation");--> statement-breakpoint
CREATE INDEX "idx_embeddings_citation" ON "embeddings" USING btree ("citation");--> statement-breakpoint
CREATE INDEX "embeddings_chatbot_id_idx" ON "embeddings" USING btree ("chatbot_id");--> statement-breakpoint
CREATE INDEX "messages_unique_conv_id_created_idx" ON "messages" USING btree ("unique_conv_id","created_at" DESC NULLS LAST);--> statement-breakpoint
CREATE INDEX "messages_chatbot_id_created_idx" ON "messages" USING btree ("chatbot_id","created_at" DESC NULLS LAST);--> statement-breakpoint
CREATE INDEX "messages_chatbot_channel_idx" ON "messages" USING btree ("chatbot_id","channel");--> statement-breakpoint
CREATE INDEX "messages_chatbot_feedback_idx" ON "messages" USING btree ("chatbot_id","feedback");--> statement-breakpoint
CREATE UNIQUE INDEX "origin_domains_chatbot_id_domain_unique" ON "origin_domains" USING btree ("chatbot_id","domain");--> statement-breakpoint
CREATE INDEX "origin_domains_api_key_idx" ON "origin_domains" USING btree ("api_key");--> statement-breakpoint
CREATE INDEX "origin_domains_chatbot_id_idx" ON "origin_domains" USING btree ("chatbot_id");--> statement-breakpoint
CREATE INDEX "subscribed_users_user_id_idx" ON "subscribed_users" USING btree ("user_id");--> statement-breakpoint
CREATE INDEX "whatsapp_accounts_chatbot_id_idx" ON "whatsapp_accounts" USING btree ("chatbot_id");--> statement-breakpoint
CREATE INDEX "whatsapp_accounts_phone_number_idx" ON "whatsapp_accounts" USING btree ("phone_number");--> statement-breakpoint
CREATE UNIQUE INDEX "whatsapp_contacts_chatbot_id_phone_number_unique" ON "whatsapp_contacts" USING btree ("chatbot_id","phone_number");--> statement-breakpoint
CREATE INDEX "whatsapp_contacts_chatbot_id_idx" ON "whatsapp_contacts" USING btree ("chatbot_id");--> statement-breakpoint
CREATE INDEX "widget_config_chatbot_id_idx" ON "widget_config" USING btree ("chatbot_id");