import 'dotenv/config';
import { drizzle } from 'drizzle-orm/node-postgres';
import * as schema from './db/schema.js';

export const db = drizzle({ 
  connection: { 
    connectionString: process.env.DATABASE_URL!,
    ssl: {
      rejectUnauthorized: false
    }
  },
  schema
});
async function main() {
  console.log('Database connected successfully!');
}

main().catch(console.error);

