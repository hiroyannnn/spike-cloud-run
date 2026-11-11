import usersRoutes from '../users';
import postsRoutes from '../posts';
import { db } from '../../db/connection';

jest.mock('../../db/connection', () => ({
  db: { select: jest.fn(), insert: jest.fn() },
}));

const mockDb = db as unknown as { select: jest.Mock; insert: jest.Mock };

beforeEach(() => jest.resetAllMocks());

describe('Hono route contracts without a live database', () => {
  it('returns user lists as JSON', async () => {
    const users = [{ id: 1, name: 'Example', email: 'example@example.test' }];
    mockDb.select.mockReturnValue({ from: jest.fn().mockResolvedValue(users) });
    const response = await usersRoutes.request('/');
    expect(response.status).toBe(200);
    expect(response.headers.get('content-type')).toContain('application/json');
    expect(await response.json()).toEqual({ users });
  });

  it('returns 404 for a missing user', async () => {
    mockDb.select.mockReturnValue({
      from: () => ({ where: jest.fn().mockResolvedValue([]) }),
    });
    const response = await usersRoutes.request('/999');
    expect(response.status).toBe(404);
    expect(await response.json()).toEqual({ error: 'User not found' });
  });

  it('preserves the user creation response and default active flag', async () => {
    const user = { id: 1, name: 'Example', email: 'example@example.test', isActive: true };
    const values = jest.fn().mockReturnValue({ returning: jest.fn().mockResolvedValue([user]) });
    mockDb.insert.mockReturnValue({ values });
    const response = await usersRoutes.request('/', {
      method: 'POST',
      headers: { 'content-type': 'application/json' },
      body: JSON.stringify({ name: user.name, email: user.email }),
    });
    expect(response.status).toBe(201);
    expect(await response.json()).toEqual({ user });
    expect(values).toHaveBeenCalledWith({ name: user.name, email: user.email, isActive: true });
  });

  it('does not write to the database for malformed JSON', async () => {
    const response = await usersRoutes.request('/', {
      method: 'POST',
      headers: { 'content-type': 'application/json' },
      body: '{',
    });
    // Existing API behavior, not a claim that 500 is the ideal validation status.
    expect(response.status).toBe(500);
    expect(await response.json()).toEqual({ error: 'Failed to create user' });
    expect(mockDb.insert).not.toHaveBeenCalled();
  });

  it('does not expose database exception details', async () => {
    mockDb.select.mockImplementation(() => { throw new Error('private database detail'); });
    const response = await usersRoutes.request('/');
    expect(response.status).toBe(500);
    expect(await response.json()).toEqual({ error: 'Failed to fetch users' });
  });

  it('returns joined post lists', async () => {
    const posts = [{ id: 1, title: 'Example', author: { id: 1, name: 'Author' } }];
    mockDb.select.mockReturnValue({
      from: () => ({ leftJoin: jest.fn().mockResolvedValue(posts) }),
    });
    const response = await postsRoutes.request('/');
    expect(response.status).toBe(200);
    expect(await response.json()).toEqual({ posts });
  });

  it('returns 404 for a missing post', async () => {
    mockDb.select.mockReturnValue({
      from: () => ({ leftJoin: () => ({ where: jest.fn().mockResolvedValue([]) }) }),
    });
    const response = await postsRoutes.request('/999');
    expect(response.status).toBe(404);
    expect(await response.json()).toEqual({ error: 'Post not found' });
  });

  it('does not query the database for unmatched paths', async () => {
    const response = await usersRoutes.request('/not/a/route');
    expect(response.status).toBe(404);
    expect(mockDb.select).not.toHaveBeenCalled();
    expect(mockDb.insert).not.toHaveBeenCalled();
  });
});
