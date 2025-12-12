CREATE TYPE "public"."llm_model" AS ENUM('openai:gpt-4o', 'openai:gpt-4o-mini', 'openai:gpt-4-turbo', 'openai:gpt-4o-realtime', 'openai:gpt-4o-mini-realtime');--> statement-breakpoint
CREATE TYPE "public"."stt_model" AS ENUM('deepgram:nova-2', 'deepgram:nova-2-general', 'deepgram:nova-2-conversationalai');--> statement-breakpoint
CREATE TYPE "public"."stt_provider" AS ENUM('DEEPGRAM', 'WHISPER', 'GOOGLE', 'AZURE', 'AWS_TRANSCRIBE', 'ASSEMBLYAI');--> statement-breakpoint
CREATE TYPE "public"."tts_model" AS ENUM('elevenlabs:eleven_turbo_v2_5', 'elevenlabs:eleven_turbo_v2', 'elevenlabs:eleven_multilingual_v2', 'elevenlabs:eleven_flash_v2_5', 'elevenlabs:eleven_flash_v2');--> statement-breakpoint
CREATE TYPE "public"."tts_provider" AS ENUM('ELEVENLABS', 'OPENAI', 'GOOGLE', 'AZURE', 'AWS_POLLY', 'PLAYHT');--> statement-breakpoint
CREATE TYPE "public"."turn_detection_mode" AS ENUM('stt', 'vad', 'realtime_llm', 'manual');--> statement-breakpoint
CREATE TYPE "public"."voice_bot_status" AS ENUM('ACTIVE', 'INACTIVE', 'TESTING');--> statement-breakpoint
CREATE TYPE "public"."voice_call_status" AS ENUM('INITIATED', 'CONNECTING', 'IN_PROGRESS', 'COMPLETED', 'FAILED', 'DROPPED', 'TIMEOUT', 'USER_AWAY');--> statement-breakpoint
CREATE TYPE "public"."voice_gender" AS ENUM('MALE', 'FEMALE', 'NEUTRAL');--> statement-breakpoint
CREATE TYPE "public"."voice_widget_position" AS ENUM('bottom-right', 'bottom-left', 'top-right', 'top-left');--> statement-breakpoint
CREATE TYPE "public"."voice_widget_style" AS ENUM('floating-button', 'embedded', 'full-screen-overlay');--> statement-breakpoint
ALTER TYPE "public"."MessageChannel" ADD VALUE 'VOICE';--> statement-breakpoint
CREATE TABLE "voice_call_session" (
	"id" text PRIMARY KEY NOT NULL,
	"voice_config_id" text NOT NULL,
	"room_name" text NOT NULL,
	"participant_identity" text,
	"status" "voice_call_status" DEFAULT 'INITIATED' NOT NULL,
	"caller_metadata" json,
	"started_at" timestamp (6) with time zone,
	"connected_at" timestamp (6) with time zone,
	"ended_at" timestamp (6) with time zone,
	"duration_sec" integer,
	"full_transcript" json,
	"metrics" json,
	"end_reason" text,
	"error_message" text,
	"stt_duration_ms" integer,
	"tts_characters_used" integer,
	"llm_tokens_used" integer,
	"created_at" timestamp (6) with time zone DEFAULT now()
);
--> statement-breakpoint
CREATE TABLE "voice_config" (
	"id" text PRIMARY KEY NOT NULL,
	"chatbot_id" text NOT NULL,
	"status" "voice_bot_status" DEFAULT 'INACTIVE' NOT NULL,
	"turn_detection" "turn_detection_mode" DEFAULT 'stt' NOT NULL,
	"stt_model" "stt_model" DEFAULT 'deepgram:nova-2' NOT NULL,
	"tts_model" "tts_model" DEFAULT 'elevenlabs:eleven_turbo_v2_5' NOT NULL,
	"llm_model" "llm_model" DEFAULT 'openai:gpt-4o-mini' NOT NULL,
	"allow_interruptions" boolean DEFAULT true NOT NULL,
	"discard_audio_if_uninterruptible" boolean DEFAULT true NOT NULL,
	"min_interruption_duration" integer DEFAULT 500 NOT NULL,
	"min_interruption_words" integer DEFAULT 0 NOT NULL,
	"min_endpointing_delay" integer DEFAULT 500 NOT NULL,
	"max_endpointing_delay" integer DEFAULT 6000 NOT NULL,
	"max_tool_steps" integer DEFAULT 3 NOT NULL,
	"preemptive_generation" boolean DEFAULT false NOT NULL,
	"user_away_timeout" real DEFAULT 15,
	"voice_id" text NOT NULL,
	"voice_gender" "voice_gender" DEFAULT 'NEUTRAL',
	"language" varchar(10) DEFAULT 'en-US' NOT NULL,
	"voice_settings" json,
	"system_prompt" text,
	"initial_greeting" text DEFAULT 'Hello! How can I help you today?' NOT NULL,
	"closing_message" text DEFAULT 'Thank you for calling. Goodbye!',
	"max_call_duration_sec" integer DEFAULT 600 NOT NULL,
	"created_at" timestamp (6) with time zone DEFAULT now(),
	"updated_at" timestamp (6) with time zone DEFAULT now()
);
--> statement-breakpoint
CREATE TABLE "voice_widget_config" (
	"id" text PRIMARY KEY NOT NULL,
	"voice_config_id" text NOT NULL,
	"styles" json NOT NULL,
	"only_allow_on_added_domains" boolean DEFAULT false NOT NULL,
	"allowed_domains" text[] DEFAULT ARRAY[]::text[] NOT NULL,
	"created_at" timestamp (6) with time zone DEFAULT now(),
	"updated_at" timestamp (6) with time zone DEFAULT now(),
	CONSTRAINT "voice_widget_config_voice_config_id_unique" UNIQUE("voice_config_id")
);
--> statement-breakpoint
ALTER TABLE "auth_method" ALTER COLUMN "provider" SET DATA TYPE text;--> statement-breakpoint
DROP TYPE "public"."AuthProvider";--> statement-breakpoint
CREATE TYPE "public"."AuthProvider" AS ENUM('GOOGLE_OAUTH', 'EMAIL', 'EMAIL_PASSWORD');--> statement-breakpoint
ALTER TABLE "auth_method" ALTER COLUMN "provider" SET DATA TYPE "public"."AuthProvider" USING "provider"::"public"."AuthProvider";--> statement-breakpoint
ALTER TABLE "voice_call_session" ADD CONSTRAINT "voice_call_session_voice_config_id_voice_config_id_fk" FOREIGN KEY ("voice_config_id") REFERENCES "public"."voice_config"("id") ON DELETE set null ON UPDATE cascade;--> statement-breakpoint
ALTER TABLE "voice_config" ADD CONSTRAINT "voice_config_chatbot_id_chatbot_id_fk" FOREIGN KEY ("chatbot_id") REFERENCES "public"."chatbot"("id") ON DELETE cascade ON UPDATE cascade;--> statement-breakpoint
ALTER TABLE "voice_widget_config" ADD CONSTRAINT "voice_widget_config_voice_config_id_voice_config_id_fk" FOREIGN KEY ("voice_config_id") REFERENCES "public"."voice_config"("id") ON DELETE cascade ON UPDATE cascade;--> statement-breakpoint
CREATE INDEX "voice_call_session_voice_config_id_idx" ON "voice_call_session" USING btree ("voice_config_id");--> statement-breakpoint
CREATE INDEX "voice_call_session_started_at_idx" ON "voice_call_session" USING btree ("started_at" DESC NULLS LAST);--> statement-breakpoint
CREATE INDEX "voice_call_session_status_idx" ON "voice_call_session" USING btree ("status");--> statement-breakpoint
CREATE INDEX "voice_call_session_room_name_idx" ON "voice_call_session" USING btree ("room_name");--> statement-breakpoint
CREATE UNIQUE INDEX "voice_config_chatbot_active_unique" ON "voice_config" USING btree ("chatbot_id") WHERE "voice_config"."status" = 'ACTIVE';--> statement-breakpoint
CREATE INDEX "voice_config_chatbot_id_idx" ON "voice_config" USING btree ("chatbot_id");--> statement-breakpoint
CREATE INDEX "voice_widget_config_voice_config_id_idx" ON "voice_widget_config" USING btree ("voice_config_id");