export async function authMiddleware(request: Request, env: any): Promise<Response | null> {
  const authHeader = request.headers.get('Authorization');
  
  if (!authHeader) {
    return new Response(JSON.stringify({ error: 'Missing Authorization header' }), {
      status: 401,
      headers: { 'Content-Type': 'application/json' }
    });
  }

  const token = authHeader.replace('Bearer ', '');
  
  if (token !== env.API_TOKEN) {
    return new Response(JSON.stringify({ error: 'Invalid API token' }), {
      status: 401,
      headers: { 'Content-Type': 'application/json' }
    });
  }

  return null;
}

