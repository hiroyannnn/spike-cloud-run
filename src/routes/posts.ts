import { Hono } from 'hono';
import { db } from '../db/connection';
import { posts, users, type NewPost } from '../db/schema';
import { eq } from 'drizzle-orm';

const app = new Hono();

app.get('/', async (c) => {
  try {
    const allPosts = await db
      .select({
        id: posts.id,
        title: posts.title,
        content: posts.content,
        published: posts.published,
        createdAt: posts.createdAt,
        updatedAt: posts.updatedAt,
        author: {
          id: users.id,
          name: users.name,
          email: users.email,
        },
      })
      .from(posts)
      .leftJoin(users, eq(posts.userId, users.id));
    
    return c.json({ posts: allPosts });
  } catch (error) {
    return c.json({ error: 'Failed to fetch posts' }, 500);
  }
});

app.get('/:id', async (c) => {
  try {
    const id = parseInt(c.req.param('id'));
    const post = await db
      .select({
        id: posts.id,
        title: posts.title,
        content: posts.content,
        published: posts.published,
        createdAt: posts.createdAt,
        updatedAt: posts.updatedAt,
        author: {
          id: users.id,
          name: users.name,
          email: users.email,
        },
      })
      .from(posts)
      .leftJoin(users, eq(posts.userId, users.id))
      .where(eq(posts.id, id));
    
    if (post.length === 0) {
      return c.json({ error: 'Post not found' }, 404);
    }
    
    return c.json({ post: post[0] });
  } catch (error) {
    return c.json({ error: 'Failed to fetch post' }, 500);
  }
});

app.post('/', async (c) => {
  try {
    const body = await c.req.json();
    const newPost: NewPost = {
      title: body.title,
      content: body.content,
      userId: body.userId,
      published: body.published ?? false,
    };
    
    const createdPost = await db.insert(posts).values(newPost).returning();
    return c.json({ post: createdPost[0] }, 201);
  } catch (error) {
    return c.json({ error: 'Failed to create post' }, 500);
  }
});

app.put('/:id', async (c) => {
  try {
    const id = parseInt(c.req.param('id'));
    const body = await c.req.json();
    
    const updatedPost = await db
      .update(posts)
      .set({
        title: body.title,
        content: body.content,
        published: body.published,
        updatedAt: new Date(),
      })
      .where(eq(posts.id, id))
      .returning();
    
    if (updatedPost.length === 0) {
      return c.json({ error: 'Post not found' }, 404);
    }
    
    return c.json({ post: updatedPost[0] });
  } catch (error) {
    return c.json({ error: 'Failed to update post' }, 500);
  }
});

app.delete('/:id', async (c) => {
  try {
    const id = parseInt(c.req.param('id'));
    
    const deletedPost = await db
      .delete(posts)
      .where(eq(posts.id, id))
      .returning();
    
    if (deletedPost.length === 0) {
      return c.json({ error: 'Post not found' }, 404);
    }
    
    return c.json({ message: 'Post deleted successfully' });
  } catch (error) {
    return c.json({ error: 'Failed to delete post' }, 500);
  }
});

export default app;