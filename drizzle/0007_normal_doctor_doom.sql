CREATE TYPE "public"."Align" AS ENUM('left', 'right');--> statement-breakpoint
CREATE TYPE "public"."Theme" AS ENUM('light', 'dark');--> statement-breakpoint
CREATE TABLE "widget_config" (
	"id" serial PRIMARY KEY NOT NULL,
	"chatbot_id" integer NOT NULL,
	"styles" json NOT NULL,
	"only_allow_on_added_domains" boolean DEFAULT false NOT NULL,
	"initial_message" text DEFAULT '' NOT NULL,
	"suggested_messages" text[] DEFAULT ARRAY[]::text[] NOT NULL,
	"allowed_domains" text[] DEFAULT ARRAY[]::text[] NOT NULL,
	"created_at" timestamp (6) with time zone DEFAULT now(),
	"updated_at" timestamp (6) with time zone DEFAULT now(),
	CONSTRAINT "widget_config_chatbot_id_unique" UNIQUE("chatbot_id")
);
--> statement-breakpoint
ALTER TABLE "widget_config" ADD CONSTRAINT "widget_config_chatbot_id_chatbot_id_fk" FOREIGN KEY ("chatbot_id") REFERENCES "public"."chatbot"("id") ON DELETE cascade ON UPDATE cascade;--> statement-breakpoint
CREATE INDEX "widget_config_chatbot_id_idx" ON "widget_config" USING btree ("chatbot_id");