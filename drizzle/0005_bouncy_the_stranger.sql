CREATE TABLE "origin_domains" (
	"id" serial PRIMARY KEY NOT NULL,
	"user_id" uuid NOT NULL,
	"chatbot_id" integer NOT NULL,
	"api_key" varchar(255) NOT NULL,
	"domain" varchar NOT NULL,
	"created_at" timestamp (6) DEFAULT now()
);
--> statement-breakpoint
ALTER TABLE "origin_domains" ADD CONSTRAINT "origin_domains_chatbot_id_fkey" FOREIGN KEY ("chatbot_id") REFERENCES "public"."chatbot"("id") ON DELETE cascade ON UPDATE cascade;--> statement-breakpoint
ALTER TABLE "origin_domains" ADD CONSTRAINT "origin_domains_user_id_fkey" FOREIGN KEY ("user_id") REFERENCES "public"."user"("id") ON DELETE cascade ON UPDATE cascade;--> statement-breakpoint
CREATE UNIQUE INDEX "origin_domains_chatbot_id_domain_unique" ON "origin_domains" USING btree ("chatbot_id","domain");--> statement-breakpoint
CREATE INDEX "origin_domains_api_key_idx" ON "origin_domains" USING btree ("api_key");--> statement-breakpoint
CREATE INDEX "origin_domains_chatbot_id_idx" ON "origin_domains" USING btree ("chatbot_id");