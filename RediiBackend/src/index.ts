import { OpenAI } from 'openai';
import { RateLimiter } from './lib/rateLimiter';
import { authMiddleware } from './lib/auth';
import { handleCors } from './lib/cors';
import type { RediiRequest } from './types';

export default {
  async fetch(request: Request, env: Env, ctx: ExecutionContext): Promise<Response> {
    return handleRequest(request, env, ctx);
  }
};

interface Env {
  OPENAI_API_KEY: string;
  API_TOKEN: string;
  RATE_LIMIT_STORE: KVNamespace;
}

async function handleRequest(request: Request, env: Env, ctx: ExecutionContext): Promise<Response> {
  const url = new URL(request.url);
  
  if (request.method === 'OPTIONS') {
    return handleCors(new Response(null, { status: 204 }), env);
  }

  try {
    switch (url.pathname) {
      case '/ai/message-polish':
        return handleMessagePolish(request, env);
      case '/ai/daily-prompt':
        return handleDailyPrompt(request, env);
      case '/ai/weekly-summary':
        return handleWeeklySummary(request, env);
      default:
        return new Response('Not Found', { status: 404 });
    }
  } catch (error) {
    console.error('Request error:', error);
    return new Response(JSON.stringify({ error: 'Internal Server Error' }), {
      status: 500,
      headers: { 'Content-Type': 'application/json' }
    });
  }
}

async function handleMessagePolish(request: Request, env: Env): Promise<Response> {
  const authResponse = await authMiddleware(request, env);
  if (authResponse) return handleCors(authResponse, env);

  const rateLimitResponse = await new RateLimiter(env).checkLimit(request);
  if (rateLimitResponse) return handleCors(rateLimitResponse, env);

  try {
    const { text } = await request.json();
    
    if (!text || typeof text !== 'string') {
      return handleCors(new Response(JSON.stringify({ error: 'Invalid request body' }), {
        status: 400,
        headers: { 'Content-Type': 'application/json' }
      }), env);
    }

    const openai = new OpenAI({ apiKey: env.OPENAI_API_KEY });
    const completion = await openai.chat.completions.create({
      model: 'gpt-4-turbo-preview',
      messages: [
        {
          role: 'system',
          content: 'You are a romantic writing assistant. Rewrite the given text in a soft, loving, romantic tone while preserving its core meaning and sentiment. Be gentle and tender.'
        },
        {
          role: 'user',
          content: text
        }
      ],
      temperature: 0.7,
      max_tokens: 500
    });

    const polishedText = completion.choices[0]?.message?.content || text;
    
    return handleCors(new Response(JSON.stringify({ polishedText }), {
      headers: { 'Content-Type': 'application/json' }
    }), env);
  } catch (error) {
    console.error('Error polishing message:', error);
    return handleCors(new Response(JSON.stringify({ error: 'Failed to polish message' }), {
      status: 500,
      headers: { 'Content-Type': 'application/json' }
    }), env);
  }
}

async function handleDailyPrompt(request: Request, env: Env): Promise<Response> {
  const authResponse = await authMiddleware(request, env);
  if (authResponse) return handleCors(authResponse, env);

  const rateLimitResponse = await new RateLimiter(env).checkLimit(request);
  if (rateLimitResponse) return handleCors(rateLimitResponse, env);

  try {
    const openai = new OpenAI({ apiKey: env.OPENAI_API_KEY });
    const completion = await openai.chat.completions.create({
      model: 'gpt-4-turbo-preview',
      messages: [
        {
          role: 'system',
          content: 'Generate a gentle, romantic daily prompt for couples to reflect on their relationship. Keep it sweet, meaningful, and easy to respond to. Return only the prompt, no extra text.'
        },
        {
          role: 'user',
          content: 'Generate today\'s daily prompt for couples.'
        }
      ],
      temperature: 0.8,
      max_tokens: 200
    });

    const prompt = completion.choices[0]?.message?.content || 'What made you smile today?';
    
    return handleCors(new Response(JSON.stringify({ prompt }), {
      headers: { 'Content-Type': 'application/json' }
    }), env);
  } catch (error) {
    console.error('Error generating prompt:', error);
    return handleCors(new Response(JSON.stringify({ error: 'Failed to generate prompt' }), {
      status: 500,
      headers: { 'Content-Type': 'application/json' }
    }), env);
  }
}

async function handleWeeklySummary(request: Request, env: Env): Promise<Response> {
  const authResponse = await authMiddleware(request, env);
  if (authResponse) return handleCors(authResponse, env);

  const rateLimitResponse = await new RateLimiter(env).checkLimit(request);
  if (rateLimitResponse) return handleCors(rateLimitResponse, env);

  try {
    const { moments } = await request.json();
    
    if (!moments || !Array.isArray(moments)) {
      return handleCors(new Response(JSON.stringify({ error: 'Invalid request body' }), {
        status: 400,
        headers: { 'Content-Type': 'application/json' }
      }), env);
    }

    const momentsText = moments
      .map((m: any) => `[${m.createdAt}] ${m.type}: ${m.content}`)
      .join('\n');

    const openai = new OpenAI({ apiKey: env.OPENAI_API_KEY });
    const completion = await openai.chat.completions.create({
      model: 'gpt-4-turbo-preview',
      messages: [
        {
          role: 'system',
          content: 'You are a romantic assistant for couples. Create a sweet, heartfelt weekly summary of their moments together. Highlight themes of love, connection, and growth. Be warm and tender.'
        },
        {
          role: 'user',
          content: `Create a weekly summary from these moments:\n\n${momentsText}`
        }
      ],
      temperature: 0.7,
      max_tokens: 800
    });

    const summary = completion.choices[0]?.message?.content || 'A beautiful week together.';
    
    return handleCors(new Response(JSON.stringify({ summary }), {
      headers: { 'Content-Type': 'application/json' }
    }), env);
  } catch (error) {
    console.error('Error generating summary:', error);
    return handleCors(new Response(JSON.stringify({ error: 'Failed to generate summary' }), {
      status: 500,
      headers: { 'Content-Type': 'application/json' }
    }), env);
  }
}

