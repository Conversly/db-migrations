ALTER TYPE "public"."AuthProvider" ADD VALUE 'EMAIL_PASSWORD';--> statement-breakpoint

--> statement-breakpoint
ALTER TABLE "auth_method" ADD COLUMN "password_hash" text;--> statement-breakpoint