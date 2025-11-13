# Repository Overview: Conversly DB Migrations

This is a **database migration management system** for a chatbot platform called "Conversly" using **Drizzle ORM** with **PostgreSQL**. It manages the database schema, migrations, and relationships for a multi-tenant chatbot SaaS application.

---

## 🏗️ System Architecture & Flow

```
┌─────────────────────────────────────────────────────────────────────┐
│                         DRIZZLE ORM WORKFLOW                         │
└─────────────────────────────────────────────────────────────────────┘

┌─────────────────┐
│  Developer      │
│  Modifies       │
│  schema.ts      │
└────────┬────────┘
         │
         ↓
┌─────────────────────────────────────────────────────────────────────┐
│  1. SCHEMA DEFINITION (src/db/schema.ts)                            │
│  ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━    │
│  • Defines all database tables (users, chatbots, embeddings, etc.)  │
│  • Enums: authProvider, dataSourceType, messageType, etc.           │
│  • Table relationships using foreign keys                           │
│  • Indexes for query optimization                                   │
└────────┬────────────────────────────────────────────────────────────┘
         │
         ↓
┌─────────────────────────────────────────────────────────────────────┐
│  2. RELATIONS (src/db/relations.ts)                                 │
│  ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━    │
│  • Defines ORM-level relationships between tables                   │
│  • One-to-many, many-to-one relationships                           │
│  • Used for easier querying with Drizzle ORM                        │
└────────┬────────────────────────────────────────────────────────────┘
         │
         ↓
┌─────────────────────────────────────────────────────────────────────┐
│  3. CONFIGURATION (drizzle.config.ts)                               │
│  ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━    │
│  • Points to schema file location                                   │
│  • Sets output directory for migrations (./drizzle)                 │
│  • Configures database connection (PostgreSQL)                      │
└────────┬────────────────────────────────────────────────────────────┘
         │
         ↓  npm run db:generate
┌─────────────────────────────────────────────────────────────────────┐
│  4. MIGRATION GENERATION (Drizzle Kit)                              │
│  ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━  │
│  • Compares schema.ts with database state                           │
│  • Generates SQL migration files (0000_*.sql)                       │
│  • Creates snapshots (meta/*.json) for tracking                     │
│  • Updates _journal.json with migration history                     │
└────────┬────────────────────────────────────────────────────────────┘
         │
         ↓
┌─────────────────────────────────────────────────────────────────────┐
│  5. MIGRATION FILES (drizzle/*.sql)                                 │
│  ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━  │
│  • 17 migration files (0000 to 0016)                                │
│  • Each contains SQL DDL statements (CREATE, ALTER, etc.)           │
│  • Tracked in meta/_journal.json                                    │
└────────┬────────────────────────────────────────────────────────────┘
         │
         ↓  npm run db:migrate
┌─────────────────────────────────────────────────────────────────────┐
│  6. MIGRATION EXECUTION (src/db/migrate.ts)                         │
│  ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━  │
│  • Connects to PostgreSQL database                                  │
│  • Reads migration files from ./drizzle                             │
│  • Executes pending migrations in order                             │
│  • Updates migration history in database                            │
└────────┬────────────────────────────────────────────────────────────┘
         │
         ↓
┌─────────────────────────────────────────────────────────────────────┐
│  7. DATABASE CONNECTION (src/index.ts)                              │
│  ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━  │
│  • Exports 'db' instance for application use                        │
│  • Configured with schema and relations                             │
│  • SSL enabled for production database                              │
└────────┬────────────────────────────────────────────────────────────┘
         │
         ↓
┌─────────────────────────────────────────────────────────────────────┐
│  8. POSTGRESQL DATABASE                                             │
│  ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━  │
│  • Production database with all tables                              │
│  • Schema up-to-date with latest migrations                         │
└─────────────────────────────────────────────────────────────────────┘
```

---

## 📁 File-by-File Explanation

### **1. `drizzle.config.ts`** - Configuration File
**Purpose:** Tells Drizzle Kit where everything is
```typescript
- out: './drizzle'           → Where to save migrations
- schema: './src/db/schema.ts' → Where table definitions are
- dialect: 'postgresql'      → Database type
- dbCredentials: DATABASE_URL → Connection string from .env
```

---

### **2. `src/db/schema.ts`** - Database Schema Definition
**Purpose:** Defines the entire database structure

**Key Tables:**
- **`user`** - User accounts (UUID-based, auth, profile)
- **`authMethod`** - Authentication providers (Google, Email, Phantom Wallet)
- **`chatBots`** - AI chatbots created by users
- **`originDomains`** - Allowed domains for each chatbot
- **`dataSources`** - Training data for chatbots (PDF, URL, TXT, etc.)
- **`embeddings`** - Vector embeddings (768-dim) for semantic search
- **`messages`** - Chat conversation history
- **`analytics`** - Chatbot usage statistics
- **`citations`** - Source tracking for responses
- **`subscriptionPlans` / `subscribedUsers`** - Billing system
- **`widgetConfig`** - Customizable chat widget settings
- **`chatbotTopics` / `chatbotTopicStats`** - Conversation categorization

**Features:**
- Foreign keys with CASCADE deletes
- Indexes for performance
- Enums for type safety
- JSON columns for flexible data (widget styles, source details)
- Custom vector type for embeddings

---

### **3. `src/db/relations.ts`** - ORM Relationships
**Purpose:** Defines how tables relate to each other for Drizzle ORM queries

**Example:**
```typescript
// User has many chatbots
usersRelations = relations(user, ({ many }) => ({
  chatBots: many(chatBots),
  subscribedUsers: many(subscribedUsers)
}))

// ChatBot belongs to one user
chatBotsRelations = relations(chatBots, ({ one }) => ({
  user: one(user)
}))
```

**Benefits:**
- Enables `.with()` queries (joining related data)
- Type-safe nested queries
- Easier data fetching

---

### **4. `src/db/migrate.ts`** - Migration Runner
**Purpose:** Applies SQL migrations to the database

**Flow:**
1. Connects to PostgreSQL using connection pool
2. Reads migration files from `./drizzle` folder
3. Checks which migrations have already run
4. Executes pending migrations in order
5. Records migration history in database
6. Closes connection

**Usage:** `npm run db:migrate`

---

### **5. `src/index.ts`** - Database Instance
**Purpose:** Exports a configured Drizzle DB instance

**Features:**
- Creates reusable `db` object
- Includes schema for type inference
- SSL enabled for cloud databases
- Used throughout the application

**Usage:**
```typescript
import { db } from './index.js';
import { chatBots } from './db/schema.js';

// Query example
const bots = await db.select().from(chatBots);
```

---

### **6. `drizzle/` folder** - Migration Files
**Contains:**
- **`0000_*.sql` to `0016_*.sql`** - 17 sequential migrations
- **`meta/_journal.json`** - Migration history tracker
- **`meta/XXXX_snapshot.json`** - Schema snapshots for diffing

**How it works:**
- Each migration is named with a number + random name
- Migrations are NEVER edited after creation
- New changes = new migration file

---

### **7. `package.json`** - Scripts
**Key Commands:**
```bash
npm run db:generate  # Create new migration from schema changes
npm run db:migrate   # Apply migrations to database
npm run db:push      # Push schema directly (dev only, skips migrations)
npm run db:studio    # Open visual database browser
npm run dev          # Run application with hot reload
```

---

## 🔄 Complete Workflow Example

### **Scenario: Adding a new "webhooks" table**

```
Step 1: Edit src/db/schema.ts
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
export const webhooks = pgTable('webhooks', {
  id: serial('id').primaryKey(),
  chatbotId: integer('chatbot_id').notNull(),
  url: text('url').notNull(),
  events: text('events').array(),
  ...
});

Step 2: Run generation
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
$ npm run db:generate
→ Creates: drizzle/0017_magical_webhook.sql
→ Updates: drizzle/meta/_journal.json
→ Creates: drizzle/meta/0017_snapshot.json

Step 3: Review generated SQL
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
-- 0017_magical_webhook.sql
CREATE TABLE "webhooks" (
  "id" serial PRIMARY KEY,
  "chatbot_id" integer NOT NULL,
  ...
);

Step 4: Apply migration
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
$ npm run db:migrate
→ Connects to database
→ Executes 0017_magical_webhook.sql
→ Updates __drizzle_migrations table
✅ Migration complete!

Step 5: Use in application
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
import { db } from './index.js';
import { webhooks } from './db/schema.js';

await db.insert(webhooks).values({
  chatbotId: 1,
  url: 'https://example.com/webhook'
});
```

---

## 🎯 Key Concepts

### **1. Type Safety**
- TypeScript ensures correct queries
- Schema changes automatically update types
- Impossible to query non-existent columns

### **2. Migration Safety**
- Never modify existing migrations
- Always create new migrations
- Rollback possible via new migration

### **3. Version Control**
- All migrations committed to git
- Team members sync via `db:migrate`
- Production uses same migrations as dev

### **4. Development vs Production**
- **Dev:** Can use `db:push` for rapid prototyping
- **Prod:** Always use `db:migrate` for tracked changes

---

## 📊 Database Entity Relationship Diagram

```
┌────────────┐
│   USER     │◄───────────┐
└─────┬──────┘            │
      │ 1:N               │
      ↓                   │
┌─────────────┐           │
│ AUTH_METHOD │           │
└─────────────┘           │
                          │
┌─────────────┐           │
│  CHATBOT    │◄──────────┘ (userId)
└──────┬──────┘
       │ 1:N
       ├─────────→ DATA_SOURCES
       │               ↓
       ├─────────→ EMBEDDINGS (vector search)
       │               ↑
       │               │
       │          (citations)
       │               │
       ├─────────→ MESSAGES (conversations)
       │
       ├─────────→ ANALYTICS
       │               ↓
       │           CITATIONS (source tracking)
       │
       ├─────────→ WIDGET_CONFIG (appearance)
       │
       ├─────────→ ORIGIN_DOMAINS (security)
       │
       └─────────→ CHATBOT_TOPICS
                       ↓
                  CHATBOT_TOPIC_STATS

┌──────────────────┐
│ SUBSCRIPTION     │
│ PLANS            │
└────────┬─────────┘
         │ 1:N
         ↓
┌──────────────────┐
│ SUBSCRIBED_USERS │◄──── (user)
└──────────────────┘
```

---

## 🗂️ Database Tables Overview

### **Core Tables**

| Table | Purpose | Key Features |
|-------|---------|--------------|
| `user` | User accounts | UUID primary key, display name, avatar, username |
| `auth_method` | Authentication | Multiple auth providers per user (Google, Email, Wallet) |
| `chatbot` | AI Chatbots | Status tracking, system prompts, branding, API keys |
| `origin_domains` | Security | Domain whitelist for chatbot embedding |

### **Content & AI Tables**

| Table | Purpose | Key Features |
|-------|---------|--------------|
| `data_source` | Training Data | PDF/URL/TXT/DOCX support, processing status |
| `embeddings` | Vector Search | 768-dimensional vectors, citation tracking |
| `messages` | Conversations | User/assistant messages, feedback, unique conversation IDs |
| `chatbot_topics` | Categorization | Topic-based message organization with colors |

### **Analytics Tables**

| Table | Purpose | Key Features |
|-------|---------|--------------|
| `analytics` | Usage Stats | Response counts, likes/dislikes per chatbot |
| `citation` | Source Tracking | Which sources are used most frequently |
| `chatbot_topic_stats` | Topic Analytics | Daily aggregation of topic-level metrics |

### **Subscription Tables**

| Table | Purpose | Key Features |
|-------|---------|--------------|
| `subscription_plans` | Plan Definitions | Monthly/annual pricing, duration settings |
| `subscribed_users` | User Subscriptions | Expiry tracking, auto-renewal flags |

### **Configuration Tables**

| Table | Purpose | Key Features |
|-------|---------|--------------|
| `widget_config` | Chat Widget | Theme, colors, dimensions, behavior settings |

---

## 🔐 Security Features

- **Origin Domain Validation**: Prevents unauthorized chatbot embedding
- **API Key Authentication**: Secure chatbot access
- **User-level Isolation**: All data scoped to user accounts
- **SSL Database Connections**: Encrypted data in transit
- **Cascade Deletes**: Automatic cleanup of dependent data

---

## 🚀 Performance Optimizations

- **Indexes on Foreign Keys**: Fast joins and lookups
- **Composite Indexes**: Optimized for common query patterns
- **Vector Indexes**: Fast similarity search for embeddings
- **Unique Constraints**: Prevent duplicate data
- **Timestamp Tracking**: Audit trail for all records

---

## 📈 Scalability Considerations

- **UUID Primary Keys**: Distributed ID generation
- **Vector Embeddings**: Support for semantic search at scale
- **JSON Columns**: Flexible schema evolution
- **Enum Types**: Enforce data integrity
- **Separate Analytics Tables**: Query isolation for reporting

---

## 🛠️ Development Best Practices

1. **Never Edit Existing Migrations**: Always create new ones
2. **Test Migrations Locally First**: Before applying to production
3. **Use `db:studio` for Debugging**: Visual database inspection
4. **Keep Schema and Relations in Sync**: Update both files together
5. **Use Type-Safe Queries**: Leverage TypeScript inference
6. **Document Schema Changes**: Add comments for complex fields

---

## 📚 Technology Stack

- **ORM**: Drizzle ORM v0.44.6
- **Database**: PostgreSQL (with pgvector for embeddings)
- **Migration Tool**: Drizzle Kit v0.31.5
- **Runtime**: Node.js with TypeScript
- **Package Manager**: npm
- **Environment**: dotenv for configuration

---

This is a **production-grade database migration system** for a SaaS chatbot platform with features like vector embeddings, multi-tenancy, analytics, and billing! 🚀
