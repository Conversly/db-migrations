ALTER TYPE "public"."ChatbotStatus" ADD VALUE 'DRAFT' BEFORE 'TRAINING';--> statement-breakpoint
ALTER TABLE "chatbot" ADD COLUMN "logo_url" text DEFAULT '';--> statement-breakpoint
ALTER TABLE "chatbot" ADD COLUMN "primary_color" varchar(7) DEFAULT '#007bff' NOT NULL;