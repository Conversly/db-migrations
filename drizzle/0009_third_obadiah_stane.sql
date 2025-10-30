ALTER TABLE "messages" ALTER COLUMN "type" SET DATA TYPE text;--> statement-breakpoint
DROP TYPE "public"."MessageType";--> statement-breakpoint
CREATE TYPE "public"."MessageType" AS ENUM('user', 'assistant');--> statement-breakpoint
ALTER TABLE "messages" ALTER COLUMN "type" SET DATA TYPE "public"."MessageType" USING "type"::"public"."MessageType";