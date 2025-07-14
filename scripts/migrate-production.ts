import { migrate } from 'drizzle-orm/postgres-js/migrator';
import { drizzle } from 'drizzle-orm/postgres-js';
import postgres from 'postgres';
import * as schema from '../src/db/schema';

async function migrateProduction() {
  // Cloud Run Job では DATABASE_URL 環境変数がSecret Managerから自動設定される
  const databaseUrl = process.env.DATABASE_URL;
  
  if (!databaseUrl) {
    console.error('❌ DATABASE_URL environment variable is required');
    process.exit(1);
  }

  console.log('🔗 Connecting to production database...');
  
  const client = postgres(databaseUrl);
  const db = drizzle(client, { schema });

  try {
    console.log('🚀 Running production migrations...');
    
    await migrate(db, {
      migrationsFolder: './src/db/migrations',
    });
    
    console.log('✅ Production migrations completed successfully!');
  } catch (error) {
    console.error('❌ Production migration failed:', error);
    process.exit(1);
  } finally {
    await client.end();
  }
  
  process.exit(0);
}

migrateProduction();