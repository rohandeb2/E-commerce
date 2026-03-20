import { register, collectDefaultMetrics } from 'prom-client';
import { NextResponse } from 'next/server';

// This initializes default Node.js metrics (CPU, Memory, Event Loop Lag)
collectDefaultMetrics();

export async function GET() {
  try {
    const metrics = await register.metrics();
    return new NextResponse(metrics, {
      headers: { 'Content-Type': register.contentType },
    });
  } catch (err) {
    return new NextResponse('Internal Server Error', { status: 500 });
  }
}