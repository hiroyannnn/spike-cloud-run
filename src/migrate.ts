import 'dotenv/config';
import { migrate } from 'drizzle-orm/postgres-js/migrator';
import { db } from './db/connection';

async function main() {
  console.log('Running migrations...');
  
  try {
    await migrate(db, {
      migrationsFolder: './src/db/migrations',
    });
    console.log('Migrations completed successfully!');
  } catch (error) {
    console.error('Migration failed:', error);
    process.exit(1);
  }
  
  process.exit(0);
}

main();