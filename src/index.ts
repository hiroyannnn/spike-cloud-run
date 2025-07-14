import 'dotenv/config';
import { serve } from '@hono/node-server';
import { Hono } from 'hono';
import { cors } from 'hono/cors';
import { logger } from 'hono/logger';
import { prettyJSON } from 'hono/pretty-json';
import usersRoutes from './routes/users';
import postsRoutes from './routes/posts';

const app = new Hono();

app.use('*', logger());
app.use('*', cors());
app.use('*', prettyJSON());

app.get('/', (c) => {
  return c.json({
    message: 'Hello Cloud Run + Hono + Drizzle!',
    timestamp: new Date().toISOString(),
    endpoints: {
      users: '/api/users',
      posts: '/api/posts',
      health: '/health',
    },
  });
});

app.get('/health', (c) => {
  return c.json({
    status: 'ok',
    timestamp: new Date().toISOString(),
  });
});

app.route('/api/users', usersRoutes);
app.route('/api/posts', postsRoutes);

const port = Number(process.env.PORT) || 8080;

console.log(`Server is running on port ${port}`);

serve({
  fetch: app.fetch,
  port,
});