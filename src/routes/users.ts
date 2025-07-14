import { Hono } from 'hono';
import { db } from '../db/connection';
import { users, type NewUser } from '../db/schema';
import { eq } from 'drizzle-orm';

const app = new Hono();

app.get('/', async (c) => {
  try {
    const allUsers = await db.select().from(users);
    return c.json({ users: allUsers });
  } catch (error) {
    return c.json({ error: 'Failed to fetch users' }, 500);
  }
});

app.get('/:id', async (c) => {
  try {
    const id = parseInt(c.req.param('id'));
    const user = await db.select().from(users).where(eq(users.id, id));
    
    if (user.length === 0) {
      return c.json({ error: 'User not found' }, 404);
    }
    
    return c.json({ user: user[0] });
  } catch (error) {
    return c.json({ error: 'Failed to fetch user' }, 500);
  }
});

app.post('/', async (c) => {
  try {
    const body = await c.req.json();
    const newUser: NewUser = {
      name: body.name,
      email: body.email,
      isActive: body.isActive ?? true,
    };
    
    const createdUser = await db.insert(users).values(newUser).returning();
    return c.json({ user: createdUser[0] }, 201);
  } catch (error) {
    return c.json({ error: 'Failed to create user' }, 500);
  }
});

app.put('/:id', async (c) => {
  try {
    const id = parseInt(c.req.param('id'));
    const body = await c.req.json();
    
    const updatedUser = await db
      .update(users)
      .set({
        name: body.name,
        email: body.email,
        isActive: body.isActive,
        updatedAt: new Date(),
      })
      .where(eq(users.id, id))
      .returning();
    
    if (updatedUser.length === 0) {
      return c.json({ error: 'User not found' }, 404);
    }
    
    return c.json({ user: updatedUser[0] });
  } catch (error) {
    return c.json({ error: 'Failed to update user' }, 500);
  }
});

app.delete('/:id', async (c) => {
  try {
    const id = parseInt(c.req.param('id'));
    
    const deletedUser = await db
      .delete(users)
      .where(eq(users.id, id))
      .returning();
    
    if (deletedUser.length === 0) {
      return c.json({ error: 'User not found' }, 404);
    }
    
    return c.json({ message: 'User deleted successfully' });
  } catch (error) {
    return c.json({ error: 'Failed to delete user' }, 500);
  }
});

export default app;