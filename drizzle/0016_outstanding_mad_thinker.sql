CREATE TABLE "chatbot_topic_stats" (
	"id" serial PRIMARY KEY NOT NULL,
	"chatbot_id" integer NOT NULL,
	"topic_id" integer NOT NULL,
	"like_count" integer DEFAULT 0 NOT NULL,
	"dislike_count" integer DEFAULT 0 NOT NULL,
	"message_count" integer DEFAULT 0 NOT NULL,
	"date" date DEFAULT CURRENT_DATE NOT NULL,
	CONSTRAINT "chatbot_topic_date_unique" UNIQUE("chatbot_id","topic_id","date")
);
--> statement-breakpoint
CREATE TABLE "chatbot_topics" (
	"id" serial PRIMARY KEY NOT NULL,
	"chatbot_id" integer NOT NULL,
	"name" varchar(255) NOT NULL,
	"color" varchar(7) DEFAULT '#888888',
	"created_at" timestamp DEFAULT now()
);
--> statement-breakpoint
DROP INDEX "messages_chatbot_id_idx";--> statement-breakpoint
DROP INDEX "messages_unique_conv_id_idx";--> statement-breakpoint
DROP INDEX "messages_chatbot_id_created_at_idx";--> statement-breakpoint
ALTER TABLE "messages" ALTER COLUMN "citations" SET DEFAULT ARRAY[]::text[];--> statement-breakpoint
ALTER TABLE "messages" ALTER COLUMN "created_at" SET DATA TYPE timestamp with time zone;--> statement-breakpoint
ALTER TABLE "messages" ALTER COLUMN "created_at" SET DEFAULT now();--> statement-breakpoint
ALTER TABLE "chatbot" ADD COLUMN "topics" text[] DEFAULT ARRAY[]::text[] NOT NULL;--> statement-breakpoint
ALTER TABLE "messages" ADD COLUMN "topic_id" integer;--> statement-breakpoint
ALTER TABLE "chatbot_topic_stats" ADD CONSTRAINT "chatbot_topic_stats_chatbot_id_chatbot_id_fk" FOREIGN KEY ("chatbot_id") REFERENCES "public"."chatbot"("id") ON DELETE cascade ON UPDATE cascade;--> statement-breakpoint
ALTER TABLE "chatbot_topic_stats" ADD CONSTRAINT "chatbot_topic_stats_topic_id_chatbot_topics_id_fk" FOREIGN KEY ("topic_id") REFERENCES "public"."chatbot_topics"("id") ON DELETE cascade ON UPDATE cascade;--> statement-breakpoint
CREATE INDEX "chatbot_topic_stats_chatbot_date_idx" ON "chatbot_topic_stats" USING btree ("chatbot_id","date" DESC NULLS LAST);--> statement-breakpoint
CREATE INDEX "chatbot_topic_stats_chatbot_topic_date_idx" ON "chatbot_topic_stats" USING btree ("chatbot_id","topic_id","date" DESC NULLS LAST);--> statement-breakpoint
CREATE INDEX "chatbot_topics_chatbot_id_idx" ON "chatbot_topics" USING btree ("chatbot_id");--> statement-breakpoint
ALTER TABLE "messages" ADD CONSTRAINT "messages_topic_id_chatbot_topics_id_fk" FOREIGN KEY ("topic_id") REFERENCES "public"."chatbot_topics"("id") ON DELETE no action ON UPDATE no action;--> statement-breakpoint
CREATE INDEX "messages_chatbot_id_topic_id_created_at_idx" ON "messages" USING btree ("chatbot_id","topic_id","created_at" DESC NULLS LAST);--> statement-breakpoint
CREATE INDEX "messages_chatbot_id_created_at_idx" ON "messages" USING btree ("chatbot_id","created_at" DESC NULLS LAST);