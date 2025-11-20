import { 
  pgTable, 
  text, 
  timestamp, 
  varchar, 
  index, 
  foreignKey,
  pgEnum,
  json,
  smallint,
  integer,
  unique,
  uniqueIndex,
  date
} from 'drizzle-orm/pg-core';
import { sql } from 'drizzle-orm';
import { createId } from './shared.ts';
import { chatBots } from './chatbots.ts';

// Enums specific to messages
export const messageChannel = pgEnum('MessageChannel', [
  'WIDGET',
  'WHATSAPP',
]);

export const messageType = pgEnum('MessageType', [
  'user',       // end customer
  'assistant',  // AI agent
  'agent',      // human support agent
]);

// ============================================
// TOPIC TABLES
// ============================================

export const chatbotTopics = pgTable('chatbot_topics', {
  id: text('id').primaryKey().notNull().$defaultFn(() => createId()),
  chatbotId: text('chatbot_id').notNull(),
  name: varchar('name', { length: 255 }).notNull(),
  color: varchar('color', { length: 7 }).default('#888888'),
  createdAt: timestamp('created_at').defaultNow(),
}, (table) => [
  foreignKey({
    columns: [table.chatbotId],
    foreignColumns: [chatBots.id],
    name: 'chatbot_topics_chatbot_id_fkey',
  })
    .onUpdate('cascade')
    .onDelete('cascade'),
  index('chatbot_topics_chatbot_id_idx').on(table.chatbotId),
]);

// ============================================
// MESSAGE TABLES
// ============================================

export const messages = pgTable('messages', {
  id: text('id').primaryKey().notNull().$defaultFn(() => createId()),
  uniqueConvId: text('unique_conv_id'),  /// contact, random generated id for widget 
  chatbotId: text('chatbot_id').notNull(),  // denormalized for fast filtering
  channel: messageChannel('channel').notNull().default('WIDGET'),  
  type: messageType('type').notNull().default('user'),
  content: text('content').notNull(),
  citations: text('citations').array().notNull().default(sql`ARRAY[]::text[]`),
  feedback: smallint('feedback').default(0).notNull(),  // 0=none, 1=like, 2=dislike, 3=neutral
  feedbackComment: text('feedback_comment'),
  channelMessageMetadata: json('channel_message_metadata'),   // whatsapp, widget metadata.
  createdAt: timestamp('created_at', { mode: 'date', withTimezone: true, precision: 6 }).defaultNow(),
  topicId: text('topic_id'),
}, (table) => [
  index('messages_unique_conv_id_created_idx').on(
    table.uniqueConvId,
    table.createdAt.desc(),
  ),
  index('messages_chatbot_id_created_idx').on(
    table.chatbotId,
    table.createdAt.desc(),
  ),
  index('messages_chatbot_channel_idx').on(table.chatbotId, table.channel),
  index('messages_chatbot_feedback_idx').on(table.chatbotId, table.feedback),
  foreignKey({
    columns: [table.chatbotId],
    foreignColumns: [chatBots.id],
  })
    .onUpdate('cascade')
    .onDelete('cascade'),
  foreignKey({
    columns: [table.topicId],
    foreignColumns: [chatbotTopics.id],
  })
    .onUpdate('cascade')
    .onDelete('set null'),
]);


export const chatbotTopicStats = pgTable("chatbot_topic_stats", {
  id: text("id").primaryKey().notNull().$defaultFn(() => createId()),
  chatbotId: text("chatbot_id").notNull(),
  topicId: text("topic_id").notNull(),
  likeCount: integer("like_count").default(0).notNull(),
  dislikeCount: integer("dislike_count").default(0).notNull(),
  messageCount: integer("message_count").default(0).notNull(),
  date: date("date").notNull().default(sql`CURRENT_DATE`),
}, (table) => [
  foreignKey({ columns: [table.chatbotId], foreignColumns: [chatBots.id] })
    .onUpdate("cascade")
    .onDelete("cascade"),
  foreignKey({ columns: [table.topicId], foreignColumns: [chatbotTopics.id] })
    .onUpdate("cascade")
    .onDelete("cascade"),
  unique("chatbot_topic_date_unique").on(table.chatbotId, table.topicId, table.date),
  index("chatbot_topic_stats_chatbot_date_idx").on(table.chatbotId, table.date.desc()),
  index("chatbot_topic_stats_chatbot_topic_date_idx").on(table.chatbotId, table.topicId, table.date.desc()),
]);

export const analyticsPerDay = pgTable('analytics_per_day', {
  id: text('id').primaryKey().notNull().$defaultFn(() => createId()),
  chatbotId: text('chatbot_id').notNull(),
  date: date('date').notNull().default(sql`CURRENT_DATE`),
  userMessages: integer('user_messages').default(0).notNull(),
  aiResponses: integer('ai_responses').default(0).notNull(),
  agentResponses: integer('agent_responses').default(0).notNull(),
  likeCount: integer('like_count').default(0).notNull(),
  dislikeCount: integer('dislike_count').default(0).notNull(),
  feedbackCount: integer('feedback_count').default(0).notNull(),
  uniqueWidgetConversations: integer('unique_widget_conversations').default(0).notNull(),
  uniqueWhatsappConversations: integer('unique_whatsapp_conversations').default(0).notNull(),
  uniqueContacts: integer('unique_contacts').default(0).notNull(),
  uniqueTopicIds: text('unique_topic_ids').array().notNull().default(sql`ARRAY[]::text[]`),
  createdAt: timestamp('created_at', { mode: 'date', precision: 6 }).defaultNow(),
  updatedAt: timestamp('updated_at', { mode: 'date', precision: 6 }).defaultNow(),
}, (table) => [
  uniqueIndex('analytics_per_day_chatbot_date_unique').on(table.chatbotId, table.date),
  index('analytics_per_day_chatbot_date_idx').on(table.chatbotId, table.date.desc()),
  foreignKey({
    columns: [table.chatbotId],
    foreignColumns: [chatBots.id],
  })
    .onUpdate('cascade')
    .onDelete('cascade'),
]);
