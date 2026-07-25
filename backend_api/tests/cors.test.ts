import request from 'supertest';
import app from '../src/app';

test('CORS preflight allows configured origins', async () => {
  const res = await request(app)
    .options('/auth/firebase')
    .set('Origin', 'http://localhost:8081')
    .set('Access-Control-Request-Method', 'POST');

  expect(res.headers['access-control-allow-origin']).toBe('http://localhost:8081');
});

test('CORS preflight does not allow unknown origins', async () => {
  const res = await request(app)
    .options('/auth/firebase')
    .set('Origin', 'https://evil.example')
    .set('Access-Control-Request-Method', 'POST');

  expect(res.headers['access-control-allow-origin']).toBeUndefined();
});
