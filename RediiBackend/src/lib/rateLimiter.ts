export class RateLimiter {
  private env: any;
  private maxRequests = 100;
  private windowMinutes = 15;

  constructor(env: any) {
    this.env = env;
  }

  async checkLimit(request: Request): Promise<Response | null> {
    if (!this.env.RATE_LIMIT_STORE) {
      return null;
    }

    const clientIP = this.getClientIP(request);
    const key = `rate_limit:${clientIP}`;
    
    const currentCount = await this.env.RATE_LIMIT_STORE.get(key);
    const count = currentCount ? parseInt(currentCount) : 0;

    if (count >= this.maxRequests) {
      return new Response(JSON.stringify({ error: 'Rate limit exceeded' }), {
        status: 429,
        headers: { 'Content-Type': 'application/json' }
      });
    }

    const newCount = count + 1;
    await this.env.RATE_LIMIT_STORE.put(key, newCount.toString(), {
      expirationTtl: this.windowMinutes * 60
    });

    return null;
  }

  private getClientIP(request: Request): string {
    const forwarded = request.headers.get('CF-Connecting-IP');
    if (forwarded) return forwarded;
    
    const realIP = request.headers.get('X-Real-IP');
    if (realIP) return realIP;
    
    return 'unknown';
  }
}

