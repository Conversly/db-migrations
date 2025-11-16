CREATE TYPE "public"."MessageChannel" AS ENUM('WIDGET', 'WHATSAPP');--> statement-breakpoint
CREATE TYPE "public"."WhatsappAccountStatus" AS ENUM('active', 'inactive');--> statement-breakpoint
CREATE TYPE "public"."WhatsappConversationStatus" AS ENUM('open', 'closed', 'pending', 'escalated');--> statement-breakpoint
CREATE TYPE "public"."WhatsappMessageStatus" AS ENUM('sent', 'delivered', 'read', 'failed');--> statement-breakpoint
CREATE TYPE "public"."WhatsappMessageType" AS ENUM('text', 'image', 'video', 'document', 'template');--> statement-breakpoint
CREATE TYPE "public"."WhatsappSenderType" AS ENUM('user', 'ai', 'agent', 'system');--> statement-breakpoint
CREATE TYPE "public"."WhatsappSource" AS ENUM('organic', 'imported', 'campaign', 'api');--> statement-breakpoint
ALTER TYPE "public"."MessageType" ADD VALUE 'agent';--> statement-breakpoint
CREATE TABLE "analytics_per_day" (
	"id" serial PRIMARY KEY NOT NULL,
	"chatbot_id" integer NOT NULL,
	"date" date DEFAULT CURRENT_DATE NOT NULL,
	"total_messages" integer DEFAULT 0 NOT NULL,
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
CREATE TABLE "whatapp_analytics_per_day" (
	"id" serial PRIMARY KEY NOT NULL,
	"chatbot_id" integer NOT NULL,
	"date" date DEFAULT CURRENT_DATE NOT NULL
);
--> statement-breakpoint
CREATE TABLE "whatsapp_contacts" (
	"id" serial PRIMARY KEY NOT NULL,
	"chatbot_id" integer NOT NULL,
	"phone_number" varchar(255) NOT NULL,
	"display_name" varchar(255),
	"whatsapp_user_metadata" json NOT NULL,
	"created_at" timestamp (6) DEFAULT now(),
	"updated_at" timestamp (6) DEFAULT now()
);
--> statement-breakpoint
CREATE TABLE "whatsapp_accounts" (
	"id" serial PRIMARY KEY NOT NULL,
	"chatbot_id" integer NOT NULL,
	"phone_number" varchar(20) NOT NULL,
	"waba_id" varchar(255) NOT NULL,
	"phone_number_id" varchar(255) NOT NULL,
	"display_phone_number" varchar(20) NOT NULL,
	"access_token" text NOT NULL,
	"verified_name" varchar(255) NOT NULL,
	"status" "WhatsappAccountStatus" DEFAULT 'active' NOT NULL,
	"webhook_url" text,
	"created_at" timestamp (6) DEFAULT now(),
	"updated_at" timestamp (6) DEFAULT now(),
	CONSTRAINT "whatsapp_accounts_phone_number_unique" UNIQUE("phone_number")
);
--> statement-breakpoint
ALTER TABLE "messages" DROP CONSTRAINT "messages_chatbot_id_fkey";
--> statement-breakpoint
ALTER TABLE "messages" DROP CONSTRAINT "messages_topic_id_chatbot_topics_id_fk";
--> statement-breakpoint
DROP INDEX "messages_chatbot_id_created_at_idx";--> statement-breakpoint
DROP INDEX "messages_chatbot_id_topic_id_created_at_idx";--> statement-breakpoint
DROP INDEX "messages_chatbot_id_unique_conv_id_created_at_idx";--> statement-breakpoint
ALTER TABLE "messages" ALTER COLUMN "id" SET DEFAULT gen_random_uuid();--> statement-breakpoint
ALTER TABLE "messages" ALTER COLUMN "type" SET DEFAULT 'user';--> statement-breakpoint
ALTER TABLE "messages" ALTER COLUMN "created_at" SET DATA TYPE timestamp (6) with time zone;--> statement-breakpoint
ALTER TABLE "messages" ALTER COLUMN "created_at" SET DEFAULT now();--> statement-breakpoint
ALTER TABLE "messages" ALTER COLUMN "unique_conv_id" SET DATA TYPE integer;--> statement-breakpoint
ALTER TABLE "messages" ALTER COLUMN "unique_conv_id" DROP NOT NULL;--> statement-breakpoint
ALTER TABLE "messages" ADD COLUMN "channel" "MessageChannel" DEFAULT 'WIDGET' NOT NULL;--> statement-breakpoint
ALTER TABLE "messages" ADD COLUMN "channel_message_metadata" json;--> statement-breakpoint
ALTER TABLE "analytics_per_day" ADD CONSTRAINT "analytics_per_day_chatbot_id_chatbot_id_fk" FOREIGN KEY ("chatbot_id") REFERENCES "public"."chatbot"("id") ON DELETE cascade ON UPDATE cascade;--> statement-breakpoint
ALTER TABLE "whatapp_analytics_per_day" ADD CONSTRAINT "whatapp_analytics_per_day_chatbot_id_chatbot_id_fk" FOREIGN KEY ("chatbot_id") REFERENCES "public"."chatbot"("id") ON DELETE cascade ON UPDATE cascade;--> statement-breakpoint
ALTER TABLE "whatsapp_contacts" ADD CONSTRAINT "whatsapp_contacts_chatbot_id_chatbot_id_fk" FOREIGN KEY ("chatbot_id") REFERENCES "public"."chatbot"("id") ON DELETE cascade ON UPDATE cascade;--> statement-breakpoint
ALTER TABLE "whatsapp_accounts" ADD CONSTRAINT "whatsapp_accounts_chatbot_id_chatbot_id_fk" FOREIGN KEY ("chatbot_id") REFERENCES "public"."chatbot"("id") ON DELETE cascade ON UPDATE cascade;--> statement-breakpoint
CREATE UNIQUE INDEX "analytics_per_day_chatbot_date_unique" ON "analytics_per_day" USING btree ("chatbot_id","date");--> statement-breakpoint
CREATE INDEX "analytics_per_day_chatbot_date_idx" ON "analytics_per_day" USING btree ("chatbot_id","date" DESC NULLS LAST);--> statement-breakpoint
CREATE UNIQUE INDEX "whatsapp_contacts_chatbot_id_phone_number_unique" ON "whatsapp_contacts" USING btree ("chatbot_id","phone_number");--> statement-breakpoint
CREATE INDEX "whatsapp_contacts_chatbot_id_idx" ON "whatsapp_contacts" USING btree ("chatbot_id");--> statement-breakpoint
CREATE INDEX "whatsapp_accounts_chatbot_id_idx" ON "whatsapp_accounts" USING btree ("chatbot_id");--> statement-breakpoint
CREATE INDEX "whatsapp_accounts_phone_number_idx" ON "whatsapp_accounts" USING btree ("phone_number");--> statement-breakpoint
ALTER TABLE "chatbot_topics" ADD CONSTRAINT "chatbot_topics_chatbot_id_fkey" FOREIGN KEY ("chatbot_id") REFERENCES "public"."chatbot"("id") ON DELETE cascade ON UPDATE cascade;--> statement-breakpoint
ALTER TABLE "messages" ADD CONSTRAINT "messages_chatbot_id_chatbot_id_fk" FOREIGN KEY ("chatbot_id") REFERENCES "public"."chatbot"("id") ON DELETE cascade ON UPDATE cascade;--> statement-breakpoint
ALTER TABLE "messages" ADD CONSTRAINT "messages_topic_id_chatbot_topics_id_fk" FOREIGN KEY ("topic_id") REFERENCES "public"."chatbot_topics"("id") ON DELETE set null ON UPDATE cascade;--> statement-breakpoint
CREATE INDEX "messages_unique_conv_id_created_idx" ON "messages" USING btree ("unique_conv_id","created_at" DESC NULLS LAST);--> statement-breakpoint
CREATE INDEX "messages_chatbot_id_created_idx" ON "messages" USING btree ("chatbot_id","created_at" DESC NULLS LAST);--> statement-breakpoint
CREATE INDEX "messages_chatbot_channel_idx" ON "messages" USING btree ("chatbot_id","channel");--> statement-breakpoint
CREATE INDEX "messages_chatbot_feedback_idx" ON "messages" USING btree ("chatbot_id","feedback");