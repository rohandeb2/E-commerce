import { NextResponse } from 'next/server';
import dbConnect from '@/lib/db';
import Product from '@/lib/models/product';
import mongoose from 'mongoose';

// Prevent Next from prerendering this route during `next build`.
export const dynamic = 'force-dynamic';
export const runtime = 'nodejs';

export async function GET(
  request: Request,
  { params }: { params: { slug: string } }
) {
  try {
    await dbConnect();
    
    const { slug } = params;

    // When links are built from missing data, this route can be hit with
    // `slug === "undefined"` which would otherwise cause a CastError in
    // `findById(undefined)` and return 500.
    if (!slug || slug === 'undefined') {
      return NextResponse.json({ error: 'Product not found' }, { status: 404 });
    }
    
    // First try to find by originalId (which is used as slug)
    let product = await Product.findOne({ originalId: slug }).lean();
    
    // If not found by originalId, try by _id
    if (!product) {
      // Only try to find by _id if the slug looks like a valid ObjectId.
      if (mongoose.Types.ObjectId.isValid(slug)) {
        product = await Product.findById(slug).lean();
      }
    }
    
    if (!product) {
      return NextResponse.json(
        { error: 'Product not found' },
        { status: 404 }
      );
    }
    
    const { _id, ...rest } = product as any;
    return NextResponse.json({
      _id: _id?.toString?.() ?? _id,
      ...rest
    });
  } catch (error) {
    console.error('Error fetching single product:', error);
    return NextResponse.json(
      { error: 'Failed to fetch product' },
      { status: 500 }
    );
  }
}
