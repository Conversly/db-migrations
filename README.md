# Drizzle ORM Setup

This project is configured with Drizzle ORM for PostgreSQL database migrations and queries.

## Setup Complete! ✅

### Project Structure
```
├── drizzle/                 # Migration files (auto-generated)
├── src/
│   ├── db/
│   │   ├── schema.ts       # Database schema definitions
│   │   └── migrate.ts      # Migration runner
│   └── index.ts            # Main entry point with db instance
├── drizzle.config.ts       # Drizzle Kit configuration
└── .env                    # Database credentials
```

## Available Commands

### 1. **Generate Migration Files**
```bash
npm run db:generate
```
Creates migration SQL files in the `drizzle/` folder based on changes in your schema.

### 2. **Run Migrations**
```bash
npm run db:migrate
```
Executes pending migrations against your database.

### 3. **Push Schema (Development)**
```bash
npm run db:push
```
Pushes schema changes directly to the database without creating migration files (useful for rapid prototyping).

### 4. **Open Drizzle Studio**
```bash
npm run db:studio
```
Opens a visual database browser at `https://local.drizzle.studio`.

### 5. **Run Development Server**
```bash
npm run dev
```
Runs your application with hot reload.

## Workflow

### Making Schema Changes

1. **Edit your schema** in `src/db/schema.ts`:
   ```typescript
   export const posts = pgTable('posts', {
     id: serial('id').primaryKey(),
     title: varchar('title', { length: 255 }).notNull(),
     content: text('content'),
     userId: integer('user_id').references(() => users.id),
     createdAt: timestamp('created_at').defaultNow(),
   });
   ```

2. **Generate migration**:
   ```bash
   npm run db:generate
   ```

3. **Apply migration**:
   ```bash
   npm run db:migrate
   ```

### Quick Development (Skip Migrations)

For rapid development, you can push schema changes directly:
```bash
npm run db:push
```

⚠️ **Warning**: This should only be used in development!

## Using the Database in Your Code

```typescript
import { db } from './index.js';
import { users } from './db/schema.js';
import { eq } from 'drizzle-orm';

// Insert
await db.insert(users).values({
  name: 'John Doe',
  email: 'john@example.com',
});

// Select
const allUsers = await db.select().from(users);

// Select with WHERE
const user = await db.select()
  .from(users)
  .where(eq(users.email, 'john@example.com'));

// Update
await db.update(users)
  .set({ name: 'Jane Doe' })
  .where(eq(users.id, 1));

// Delete
await db.delete(users).where(eq(users.id, 1));
```

## Database Configuration

Your database URL is stored in `.env`:
```
DATABASE_URL=postgres://postgres:password@localhost:5432/conversly_dev?sslmode=disable
```

## Documentation

- [Drizzle ORM Docs](https://orm.drizzle.team/docs/overview)
- [Drizzle Kit Docs](https://orm.drizzle.team/kit-docs/overview)
- [PostgreSQL Column Types](https://orm.drizzle.team/docs/column-types/pg)

## Troubleshooting

### "Database connection failed"
- Ensure PostgreSQL is running
- Verify DATABASE_URL in `.env` is correct
- Check database exists: `conversly_dev`

### "Module not found" errors
- Run `npm install` to ensure all dependencies are installed

### Migration conflicts
- Check `drizzle/` folder for existing migrations
- Ensure migrations are run in order
# db-migrations
