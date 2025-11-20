import { 
  pgTable, 
  text, 
  timestamp, 
  varchar, 
  index, 
  foreignKey, 
  unique,
  pgEnum,
  json,
  boolean,
  uniqueIndex
} from 'drizzle-orm/pg-core';
import { sql } from 'drizzle-orm';
import { createId } from './shared.ts';
import { user } from './users.ts';

// Enums specific to chatbots
export const chatbotStatus = pgEnum('ChatbotStatus', [
  'DRAFT',
  'TRAINING',
  'ACTIVE',
  'INACTIVE',
]);

export const themeEnum = pgEnum('Theme', ['light', 'dark']);
export const alignEnum = pgEnum('Align', ['left', 'right']);
export const displayStyleEnum = pgEnum('DisplayStyle', ['corner', 'overlay']);

// Types for widget configuration
export type Theme = 'light' | 'dark';
export type Align = 'left' | 'right';
export type DisplayStyle = 'corner' | 'overlay';

export interface WidgetStyles {
  appearance: Theme;  // renamed from 'theme'
  displayStyle: DisplayStyle;  // NEW: corner or overlay
  displayName: string;  // keeping camelCase in DB
  
  // Colors
  primaryColor: string;  // replaces headerColor, buttonColor
  widgetBubbleColour: string;  // NEW: for message bubbles
  
  // Icons & Assets
  PrimaryIcon: string;  // renamed from profilePictureFile
  widgeticon: string;  // renamed from chatIcon (for the widget button icon)
  
  // Button Configuration
  alignChatButton: Align;  // maps to buttonAlignment in frontend
  showButtonText: boolean;  // NEW
  buttonText: string;  // NEW: text shown on widget button
  widgetButtonText: string;  // NEW: alternate button text
  
  // Messages & Placeholders
  messagePlaceholder: string;
  footerText: string;  // HTML
  dismissableNoticeText: string;  // maps to dismissibleNoticeText. HTML
  
  // Dimensions
  chatWidth: string;  // NEW
  chatHeight: string;  // NEW
  
  // Behavior Flags
  autoShowInitial: boolean;  // NEW: replaces autoOpenChatWindowAfter > 0 check
  autoShowDelaySec: number;  // renamed from autoOpenChatWindowAfter
  collectUserFeedback: boolean;  // maps to collectFeedback
  regenerateMessages: boolean;  // maps to allowRegenerate
  continueShowingSuggestedMessages: boolean;  // maps to keepShowingSuggested
  
  // REMOVED: hiddenPaths (if no longer needed)
  // REMOVED: userMessageColor (now using primaryColor)
}

// ============================================
// CHATBOT TABLES
// ============================================

export const chatBots = pgTable('chatbot', {
  id: text('id').primaryKey().notNull().$defaultFn(() => createId()),
  userId: text('user_id').notNull(),
  name: varchar('name').notNull(),
  description: text('description').notNull(),
  systemPrompt: text('system_prompt').notNull(),
  logoUrl: text('logo_url').default(''),
  primaryColor: varchar('primary_color', { length: 7 }).notNull().default('#007bff'),
  topics: text('topics').array().notNull().default(sql`ARRAY[]::text[]`),
  status: chatbotStatus().default('INACTIVE').notNull(),
  createdAt: timestamp('created_at', { mode: 'date', withTimezone: true, precision: 6 }).defaultNow(),
  updatedAt: timestamp('updated_at', { mode: 'date', withTimezone: true, precision: 6 }).defaultNow(),
  apiKey: varchar('api_key', { length: 255 }),
}, (table) => [
  foreignKey({
    columns: [table.userId],
    foreignColumns: [user.id],
    name: 'chatbot_user_id_fkey',
  })
    .onUpdate('cascade')
    .onDelete('cascade'),
  index('chatbot_user_id_idx').using('btree', table.userId.asc().nullsLast()),
]);

export const originDomains = pgTable('origin_domains', {
  id: text('id').primaryKey().notNull().$defaultFn(() => createId()),
  userId: text('user_id').notNull(),
  chatbotId: text('chatbot_id').notNull(),
  apiKey: varchar('api_key', { length: 255 }).notNull(),
  domain: varchar('domain').notNull(),
  createdAt: timestamp('created_at', { mode: 'date', precision: 6 }).defaultNow(),
}, (table) => [
  foreignKey({
    columns: [table.chatbotId],
    foreignColumns: [chatBots.id],
    name: 'origin_domains_chatbot_id_fkey',
  })
    .onUpdate('cascade')
    .onDelete('cascade'),
  foreignKey({
    columns: [table.userId],
    foreignColumns: [user.id],
    name: 'origin_domains_user_id_fkey',
  })
    .onUpdate('cascade')
    .onDelete('cascade'),
  uniqueIndex('origin_domains_chatbot_id_domain_unique').on(table.chatbotId, table.domain),
  index('origin_domains_api_key_idx').using('btree', table.apiKey.asc().nullsLast()),
  index('origin_domains_chatbot_id_idx').using('btree', table.chatbotId.asc().nullsLast()),
]);

export const widgetConfig = pgTable(
  'widget_config',
  {
    id: text('id').primaryKey().notNull().$defaultFn(() => createId()),
    chatbotId: text('chatbot_id')
      .notNull()
      .references(() => chatBots.id, { onUpdate: 'cascade', onDelete: 'cascade' }),
    styles: json('styles').$type<WidgetStyles>().notNull(),
    onlyAllowOnAddedDomains: boolean('only_allow_on_added_domains').notNull().default(false),
    initialMessage: text('initial_message').notNull(),
    suggestedMessages: text('suggested_messages').array().notNull().default(sql`ARRAY[]::text[]`),
    allowedDomains: text('allowed_domains').array().notNull().default(sql`ARRAY[]::text[]`),
    createdAt: timestamp('created_at', { mode: 'date', withTimezone: true, precision: 6 }).defaultNow(),
    updatedAt: timestamp('updated_at', { mode: 'date', withTimezone: true, precision: 6 }).defaultNow(),
  },
  (table) => [
    unique('widget_config_chatbot_id_unique').on(table.chatbotId),
    index('widget_config_chatbot_id_idx').using('btree', table.chatbotId.asc().nullsLast()),
  ]
);
