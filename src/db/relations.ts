import { relations } from 'drizzle-orm';
import {
  user,
  authMethod,
  chatBots,
  embeddings,
  dataSources,
  analytics,
  citations,
  subscriptionPlans,
  subscribedUsers,
  widgetConfig,
  originDomains,
  whatsapp_accounts,
  whatsapp_client_users,
  whatsapp_conversations,
  whatsapp_messages,
  whatsapp_analytics,
  chatbotTopics,
  chatbotTopicStats,
  messages,
} from './schema.js';

export const usersRelations = relations(user, ({ many }) => ({
  subscribedUsers: many(subscribedUsers),
  authMethods: many(authMethod),
  chatBots: many(chatBots),
  embeddings: many(embeddings),
  originDomains: many(originDomains),
}));


export const authMethodRelations = relations(authMethod, ({ one }) => ({
  user: one(user, {
    fields: [authMethod.userId],
    references: [user.id],
  }),
}));

export const chatBotsRelations = relations(chatBots, ({ many, one }) => ({
  dataSources: many(dataSources),
  embeddings: many(embeddings),
  analytics: one(analytics, {
    fields: [chatBots.id],
    references: [analytics.chatbotId],
  }),
  user: one(user, {
    fields: [chatBots.userId],
    references: [user.id],
  }),
  widgetConfig: one(widgetConfig, {
    fields: [chatBots.id],
    references: [widgetConfig.chatbotId],
  }),
  originDomains: many(originDomains),
  whatsapp_accounts: many(whatsapp_accounts), // NEW: Link to WA accounts
  chatbotTopics: many(chatbotTopics), // Assuming existing
  messages: many(messages),
}));

export const embeddingsRelations = relations(embeddings, ({ one }) => ({
  chatBot: one(chatBots, {
    fields: [embeddings.chatbotId],
    references: [chatBots.id],
  }),
  dataSource: one(dataSources, {
    fields: [embeddings.dataSourceId],
    references: [dataSources.id],
  }),
  user: one(user, {
    fields: [embeddings.userId],
    references: [user.id],
  }),
}));

export const dataSourcesRelations = relations(dataSources, ({ one, many }) => ({
  chatBot: one(chatBots, {
    fields: [dataSources.chatbotId],
    references: [chatBots.id],
  }),
  embeddings: many(embeddings),
}));

export const analyticsRelations = relations(analytics, ({ one, many }) => ({
  chatBot: one(chatBots, {
    fields: [analytics.chatbotId],
    references: [chatBots.id],
  }),
  citations: many(citations),
}));

export const citationsRelations = relations(citations, ({ one }) => ({
  analytics: one(analytics, {
    fields: [citations.analyticsId],
    references: [analytics.id],
  }),
}));

export const subscriptionPlansRelations = relations(subscriptionPlans, ({ many }) => ({
  subscribedUsers: many(subscribedUsers),
}));

export const subscribedUsersRelations = relations(subscribedUsers, ({ one }) => ({
  user: one(user, {
    fields: [subscribedUsers.userId],
    references: [user.id],
  }),
  subscriptionPlan: one(subscriptionPlans, {
    fields: [subscribedUsers.planId],
    references: [subscriptionPlans.planId],
  }),
}));

export const widgetConfigRelations = relations(widgetConfig, ({ one }) => ({
  chatBot: one(chatBots, {
    fields: [widgetConfig.chatbotId],
    references: [chatBots.id],
  }),
}));

export const originDomainsRelations = relations(originDomains, ({ one }) => ({
  chatBot: one(chatBots, {
    fields: [originDomains.chatbotId],
    references: [chatBots.id],
  }),
  user: one(user, {
    fields: [originDomains.userId],
    references: [user.id],
  }),
}));

// WhatsApp Relations
export const whatsappAccountsRelations = relations(whatsapp_accounts, ({ one, many }) => ({
  chatBot: one(chatBots, {
    fields: [whatsapp_accounts.chatbot_id],
    references: [chatBots.id],
  }),
  clientUsers: many(whatsapp_client_users),
  conversations: many(whatsapp_conversations),
}));

export const whatsappClientUsersRelations = relations(whatsapp_client_users, ({ one, many }) => ({
  whatsappAccount: one(whatsapp_accounts, {
    fields: [whatsapp_client_users.whatsapp_account_id],
    references: [whatsapp_accounts.id],
  }),
  conversations: many(whatsapp_conversations),
  analytics: one(whatsapp_analytics, {
    fields: [whatsapp_client_users.id],
    references: [whatsapp_analytics.whatsapp_client_user_id],
  }),
}));

export const whatsappConversationsRelations = relations(whatsapp_conversations, ({ one, many }) => ({
  whatsappAccount: one(whatsapp_accounts, {
    fields: [whatsapp_conversations.whatsapp_account_id],
    references: [whatsapp_accounts.id],
  }),
  whatsappClientUser: one(whatsapp_client_users, {
    fields: [whatsapp_conversations.whatsapp_client_user_id],
    references: [whatsapp_client_users.id],
  }),
  messages: many(whatsapp_messages),
}));

export const whatsappMessagesRelations = relations(whatsapp_messages, ({ one }) => ({
  conversation: one(whatsapp_conversations, {
    fields: [whatsapp_messages.conversation_id],
    references: [whatsapp_conversations.id],
  }),
}));

export const whatsappAnalyticsRelations = relations(whatsapp_analytics, ({ one }) => ({
  whatsappClientUser: one(whatsapp_client_users, {
    fields: [whatsapp_analytics.whatsapp_client_user_id],
    references: [whatsapp_client_users.id],
  }),
}));

// Existing topics relations (added for completeness)
export const chatbotTopicsRelations = relations(chatbotTopics, ({ one, many }) => ({
  chatBot: one(chatBots, {
    fields: [chatbotTopics.chatbotId],
    references: [chatBots.id],
  }),
  messages: many(messages),
  topicStats: many(chatbotTopicStats),
}));

export const chatbotTopicStatsRelations = relations(chatbotTopicStats, ({ one }) => ({
  chatBot: one(chatBots, {
    fields: [chatbotTopicStats.chatbotId],
    references: [chatBots.id],
  }),
  topic: one(chatbotTopics, {
    fields: [chatbotTopicStats.topicId],
    references: [chatbotTopics.id],
  }),
}));

export const messagesRelations = relations(messages, ({ one }) => ({
  chatBot: one(chatBots, {
    fields: [messages.chatbotId],
    references: [chatBots.id],
  }),
  topic: one(chatbotTopics, {
    fields: [messages.topicId],
    references: [chatbotTopics.id],
  }),
}));