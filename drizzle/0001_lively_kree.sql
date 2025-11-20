CREATE TYPE "public"."ApiMethod" AS ENUM('GET', 'POST', 'PUT', 'DELETE', 'PATCH');--> statement-breakpoint
CREATE TYPE "public"."TestStatus" AS ENUM('passed', 'failed', 'not_tested');--> statement-breakpoint
CREATE TABLE "action_templates" (
	"id" text PRIMARY KEY NOT NULL,
	"name" varchar(100) NOT NULL,
	"category" varchar(50) NOT NULL,
	"display_name" varchar(200) NOT NULL,
	"description" text NOT NULL,
	"icon_url" text,
	"template_config" json NOT NULL,
	"required_fields" text[] DEFAULT ARRAY[]::text[] NOT NULL,
	"is_public" boolean DEFAULT true NOT NULL,
	"usage_count" integer DEFAULT 0 NOT NULL,
	"created_at" timestamp (6) DEFAULT now(),
	CONSTRAINT "action_templates_name_unique" UNIQUE("name")
);
--> statement-breakpoint
CREATE TABLE "custom_actions" (
	"id" text PRIMARY KEY NOT NULL,
	"chatbot_id" text NOT NULL,
	"name" varchar(100) NOT NULL,
	"display_name" varchar(200) NOT NULL,
	"description" text NOT NULL,
	"is_enabled" boolean DEFAULT true NOT NULL,
	"api_config" json NOT NULL,
	"tool_schema" json NOT NULL,
	"version" integer DEFAULT 1 NOT NULL,
	"created_at" timestamp (6) DEFAULT now(),
	"updated_at" timestamp (6) DEFAULT now(),
	"created_by" text,
	"last_tested_at" timestamp (6),
	"test_status" "TestStatus" DEFAULT 'not_tested',
	"test_result" json,
	CONSTRAINT "unique_action_per_chatbot" UNIQUE("chatbot_id","name")
);
--> statement-breakpoint
DROP TABLE "analytics" CASCADE;--> statement-breakpoint
DROP TABLE "citation" CASCADE;--> statement-breakpoint
ALTER TABLE "custom_actions" ADD CONSTRAINT "custom_actions_chatbot_id_fkey" FOREIGN KEY ("chatbot_id") REFERENCES "public"."chatbot"("id") ON DELETE cascade ON UPDATE cascade;--> statement-breakpoint
ALTER TABLE "custom_actions" ADD CONSTRAINT "custom_actions_created_by_fkey" FOREIGN KEY ("created_by") REFERENCES "public"."user"("id") ON DELETE set null ON UPDATE cascade;--> statement-breakpoint
CREATE INDEX "action_templates_category_idx" ON "action_templates" USING btree ("category");--> statement-breakpoint
CREATE INDEX "action_templates_usage_idx" ON "action_templates" USING btree ("usage_count" DESC NULLS LAST);--> statement-breakpoint
CREATE INDEX "custom_actions_chatbot_enabled_idx" ON "custom_actions" USING btree ("chatbot_id") WHERE "custom_actions"."is_enabled" = true;--> statement-breakpoint
CREATE INDEX "custom_actions_chatbot_name_idx" ON "custom_actions" USING btree ("chatbot_id","name");--> statement-breakpoint
CREATE INDEX "custom_actions_updated_idx" ON "custom_actions" USING btree ("updated_at" DESC NULLS LAST);