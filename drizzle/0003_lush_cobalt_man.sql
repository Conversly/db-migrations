CREATE TYPE "public"."ChatbotStatus" AS ENUM('TRAINING', 'ACTIVE', 'INACTIVE');--> statement-breakpoint
ALTER TABLE "chatbot" ADD COLUMN "status" "ChatbotStatus" DEFAULT 'INACTIVE' NOT NULL;