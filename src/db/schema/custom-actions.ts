import { 
  pgTable, 
  text, 
  timestamp, 
  varchar, 
  index, 
  foreignKey,
  pgEnum,
  json,
  boolean,
  integer,
  unique
} from 'drizzle-orm/pg-core';
import { sql } from 'drizzle-orm';
import { createId } from './shared.ts';
import { user } from './users.ts';
import { chatBots } from './chatbots.ts';

// Enums specific to custom actions
export const apiMethod = pgEnum('ApiMethod', ['GET', 'POST', 'PUT', 'DELETE', 'PATCH']);
export const testStatus = pgEnum('TestStatus', ['passed', 'failed', 'not_tested']);

// Types for custom actions
export interface ApiConfig {
  method: 'GET' | 'POST' | 'PUT' | 'DELETE' | 'PATCH';
  baseUrl: string;
  endpoint: string;
  headers?: Record<string, string>;
  queryParams?: Record<string, string>;
  bodyParams?: Record<string, any>;
  timeout?: number;
}

export interface ToolSchema {
  type: 'object';
  properties: Record<string, any>;
  required?: string[];
}

// ============================================
// CUSTOM ACTIONS TABLES
// ============================================

export const customActions = pgTable('custom_actions', {
  id: text('id').primaryKey().notNull().$defaultFn(() => createId()),
  chatbotId: text('chatbot_id').notNull(),
  
  // Metadata
  name: varchar('name', { length: 100 }).notNull(),
  displayName: varchar('display_name', { length: 200 }).notNull(),
  description: text('description').notNull(),
  isEnabled: boolean('is_enabled').default(true).notNull(),
  
  // API Configuration
  apiConfig: json('api_config').$type<ApiConfig>().notNull(),
  
  // Tool Schema (for LLM)
  toolSchema: json('tool_schema').$type<ToolSchema>().notNull(),
  
  // Versioning & Testing
  version: integer('version').default(1).notNull(),
  createdAt: timestamp('created_at', { mode: 'date', precision: 6 }).defaultNow(),
  updatedAt: timestamp('updated_at', { mode: 'date', precision: 6 }).defaultNow(),
  createdBy: text('created_by'),
  lastTestedAt: timestamp('last_tested_at', { mode: 'date', precision: 6 }),
  testStatus: testStatus('test_status').default('not_tested'),
  testResult: json('test_result'),
}, (table) => [
  foreignKey({
    columns: [table.chatbotId],
    foreignColumns: [chatBots.id],
    name: 'custom_actions_chatbot_id_fkey',
  })
    .onUpdate('cascade')
    .onDelete('cascade'),
  foreignKey({
    columns: [table.createdBy],
    foreignColumns: [user.id],
    name: 'custom_actions_created_by_fkey',
  })
    .onUpdate('cascade')
    .onDelete('set null'),
  unique('unique_action_per_chatbot').on(table.chatbotId, table.name),
  index('custom_actions_chatbot_enabled_idx').on(table.chatbotId).where(sql`${table.isEnabled} = true`),
  index('custom_actions_chatbot_name_idx').on(table.chatbotId, table.name),
  index('custom_actions_updated_idx').on(table.updatedAt.desc()),
]);

export const actionTemplates = pgTable('action_templates', {
  id: text('id').primaryKey().notNull().$defaultFn(() => createId()),
  name: varchar('name', { length: 100 }).notNull().unique(),
  category: varchar('category', { length: 50 }).notNull(),
  displayName: varchar('display_name', { length: 200 }).notNull(),
  description: text('description').notNull(),
  iconUrl: text('icon_url'),
  
  // Pre-filled configuration
  templateConfig: json('template_config').notNull(),
  
  // Requirements
  requiredFields: text('required_fields').array().notNull().default(sql`ARRAY[]::text[]`),
  
  // Metadata
  isPublic: boolean('is_public').default(true).notNull(),
  usageCount: integer('usage_count').default(0).notNull(),
  createdAt: timestamp('created_at', { mode: 'date', precision: 6 }).defaultNow(),
}, (table) => [
  index('action_templates_category_idx').on(table.category),
  index('action_templates_usage_idx').on(table.usageCount.desc()),
]);
