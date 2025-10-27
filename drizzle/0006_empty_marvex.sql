CREATE TYPE "public"."MessageType" AS ENUM('USER', 'ASSISTANT');--> statement-breakpoint
CREATE TABLE "messages" (
	"id" serial PRIMARY KEY NOT NULL,
	"chatbot_id" integer NOT NULL,
	"citations" text[] NOT NULL,
	"type" "MessageType" NOT NULL,
	"content" text NOT NULL,
	"created_at" timestamp (6) with time zone DEFAULT now(),
	"unique_conv_id" varchar(255) NOT NULL
);
--> statement-breakpoint
ALTER TABLE "messages" ADD CONSTRAINT "messages_chatbot_id_fkey" FOREIGN KEY ("chatbot_id") REFERENCES "public"."chatbot"("id") ON DELETE cascade ON UPDATE cascade;--> statement-breakpoint
CREATE INDEX "messages_chatbot_id_idx" ON "messages" USING btree ("chatbot_id");--> statement-breakpoint
CREATE INDEX "messages_unique_conv_id_idx" ON "messages" USING btree ("unique_conv_id");