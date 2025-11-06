ALTER TABLE "messages" ADD COLUMN "feedback" smallint DEFAULT 0 NOT NULL;--> statement-breakpoint
ALTER TABLE "messages" ADD COLUMN "feedback_comment" text;