import { 
  pgTable, 
  text, 
  timestamp,
  pgEnum,
  date,
  foreignKey,
  varchar,
  json,
  index,
  uniqueIndex,
  unique
} from 'drizzle-orm/pg-core';
import { sql } from 'drizzle-orm';
import { createId } from './shared.ts';
import { chatBots } from './chatbots.ts';

// Enums specific to WhatsApp
export const whatsappAccountStatus = pgEnum('WhatsappAccountStatus', ['active', 'inactive']);
export const whatsappSource = pgEnum('WhatsappSource', ['organic', 'imported', 'campaign', 'api']);
export const whatsappConversationStatus = pgEnum('WhatsappConversationStatus', ['open', 'closed', 'pending', 'escalated']);
export const whatsappSenderType = pgEnum('WhatsappSenderType', ['user', 'ai', 'agent', 'system']);
export const whatsappMessageType = pgEnum('WhatsappMessageType', ['text', 'image', 'video', 'document', 'template']);
export const whatsappMessageStatus = pgEnum('WhatsappMessageStatus', ['sent', 'delivered', 'read', 'failed']);

// ============================================
// WHATSAPP TABLES
// ============================================

export const whatsappAccounts = pgTable('whatsapp_accounts', {
  id: text('id').primaryKey().notNull().$defaultFn(() => createId()),
  chatbotId: text('chatbot_id').notNull().references(() => chatBots.id, { onDelete: 'cascade', onUpdate: 'cascade' }),
  phoneNumber: varchar('phone_number', { length: 20 }).notNull().unique(),
  wabaId: varchar('waba_id', { length: 255 }).notNull(),
  phoneNumberId: varchar('phone_number_id', { length: 255 }).notNull(),
  accessToken: text('access_token').notNull(),
  verifiedName: varchar('verified_name', { length: 255 }).notNull(),
  status: whatsappAccountStatus('status').default('active').notNull(),
  whatsappBusinessId: varchar('whatsapp_business_id', { length: 255 }).notNull(),
  webhookUrl: text('webhook_url'),
  verifyToken: varchar('verify_token', { length: 255 }), // Webhook verification token
  createdAt: timestamp('created_at', { mode: 'date', precision: 6 }).defaultNow(),
  updatedAt: timestamp('updated_at', { mode: 'date', precision: 6 }).defaultNow(),
}, (table) => [
  index('whatsapp_accounts_chatbot_id_idx').on(table.chatbotId),
  index('whatsapp_accounts_phone_number_idx').on(table.phoneNumber),
  unique('whatsapp_accounts_chatbot_id_unique').on(table.chatbotId), // One WhatsApp account per chatbot
]);

export const whatsappContacts = pgTable('whatsapp_contacts', {
  id: text('id').primaryKey().notNull().$defaultFn(() => createId()),
  chatbotId: text('chatbot_id').notNull(),
  phoneNumber: varchar('phone_number', { length: 255 }).notNull(),
  displayName: varchar('display_name', { length: 255 }),
  // Detailed metadata: { wa_id, profile, first_seen_at, last_seen_at, last_inbound_message_id, waba_id, phone_number_id, display_phone_number, source, opt_in_status, etc }
  userMetadata: json('whatsapp_user_metadata').notNull(),
  createdAt: timestamp('created_at', { mode: 'date', precision: 6 }).defaultNow(),
  updatedAt: timestamp('updated_at', { mode: 'date', precision: 6 }).defaultNow(),
}, (table) => [
  uniqueIndex('whatsapp_contacts_chatbot_id_phone_number_unique').on(table.chatbotId, table.phoneNumber),
  index('whatsapp_contacts_chatbot_id_idx').on(table.chatbotId),
  foreignKey({
    columns: [table.chatbotId],
    foreignColumns: [chatBots.id],
  })
    .onUpdate('cascade')
    .onDelete('cascade'),
]);

export const whataappAnalyticsPerDay = pgTable('whatsapp_analytics_per_day', {
  id: text('id').primaryKey().notNull().$defaultFn(() => createId()),
  chatbotId: text('chatbot_id').notNull(),
  date: date('date').notNull().default(sql`CURRENT_DATE`),
}, (table) => [
  foreignKey({
    columns: [table.chatbotId],
    foreignColumns: [chatBots.id],
  })
    .onUpdate('cascade')
    .onDelete('cascade'),
]);
