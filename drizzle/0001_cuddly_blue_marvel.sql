CREATE TABLE "product_launches" (
	"id" text PRIMARY KEY NOT NULL,
	"user_id" text NOT NULL,
	"name" text NOT NULL,
	"tagline" text,
	"description" text,
	"logo_url" text,
	"website_url" text,
	"launch_date" timestamp (6) with time zone DEFAULT now(),
	"chatbot_id" text,
	"tags" json DEFAULT '[]'::json,
	"likes_count" integer DEFAULT 0 NOT NULL,
	"key_features" json DEFAULT '[]'::json,
	"theme" json DEFAULT '{}'::json,
	"media" json DEFAULT '[]'::json,
	"team" json DEFAULT '[]'::json,
	"comments" json DEFAULT '[]'::json,
	"announcement" json DEFAULT '{}'::json,
	"countdown" json DEFAULT '{}'::json,
	"social_links" json DEFAULT '{}'::json,
	"created_at" timestamp (6) with time zone DEFAULT now(),
	"updated_at" timestamp (6) with time zone DEFAULT now()
);
--> statement-breakpoint
ALTER TABLE "product_launches" ADD CONSTRAINT "product_launches_user_id_user_id_fk" FOREIGN KEY ("user_id") REFERENCES "public"."user"("id") ON DELETE cascade ON UPDATE cascade;--> statement-breakpoint
ALTER TABLE "product_launches" ADD CONSTRAINT "product_launches_chatbot_id_chatbot_id_fk" FOREIGN KEY ("chatbot_id") REFERENCES "public"."chatbot"("id") ON DELETE set null ON UPDATE cascade;--> statement-breakpoint
CREATE INDEX "product_launches_user_id_idx" ON "product_launches" USING btree ("user_id");--> statement-breakpoint
CREATE INDEX "product_launches_chatbot_id_idx" ON "product_launches" USING btree ("chatbot_id");--> statement-breakpoint
CREATE INDEX "product_launches_launch_date_idx" ON "product_launches" USING btree ("launch_date" DESC NULLS LAST);--> statement-breakpoint
CREATE INDEX "product_launches_likes_count_idx" ON "product_launches" USING btree ("likes_count" DESC NULLS LAST);