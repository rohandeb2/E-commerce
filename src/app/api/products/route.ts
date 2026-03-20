import { NextResponse, NextRequest } from 'next/server';
import dbConnect from '@/lib/db';
import Product from '@/lib/models/product';
import { requireAuth } from '@/lib/auth/utils';

// Prevent Next from prerendering this route during `next build`.
export const dynamic = 'force-dynamic';
export const runtime = 'nodejs';

export async function GET(request: NextRequest) {
  try {
    await dbConnect();
    
    const { searchParams } = new URL(request.url);
    const query: any = {};
    
    // Search by title or description
    if (searchParams.has('q')) {
      const searchRegex = new RegExp(searchParams.get('q') as string, 'i');
      query.$or = [
        { title: searchRegex },
        { description: searchRegex }
      ];
    }
    
    // Filter by shop category
    if (searchParams.has('shop_category')) {
      query.shop_category = searchParams.get('shop_category');
    }
    
    // Filter by categories
    if (searchParams.has('categories')) {
      const categories = searchParams.get('categories')?.split(',') || [];
      query.categories = { $in: categories };
    }

    // Filter by price range
    const minPrice = searchParams.get('minPrice')?.trim();
    const maxPrice = searchParams.get('maxPrice')?.trim();
    
    if ((minPrice && minPrice !== '') || (maxPrice && maxPrice !== '')) {
      query.price = {};
      if (minPrice && minPrice !== '') {
        query.price.$gte = parseFloat(minPrice);
      }
      if (maxPrice && maxPrice !== '') {
        query.price.$lte = parseFloat(maxPrice);
      }
    }

    // Pagination
    const page = parseInt(searchParams.get('page') || '1');
    const limit = parseInt(searchParams.get('limit') || '10');
    const skip = (page - 1) * limit;

    // Sorting
    let sort: any = { createdAt: -1 };
    if (searchParams.has('sort') && searchParams.get('sort') !== '') {
      const field = searchParams.get('sort') as string;
      const order = searchParams.get('order') || 'asc';
      sort = { [field]: order === 'desc' ? -1 : 1 };
    }

    const products = await Product.find(query)
      .sort(sort)
      .skip(skip)
      .limit(limit)
      .lean()
      .exec();

    const total = await Product.countDocuments(query);

    return NextResponse.json({
      products: products.map((product: any) => {
        // `lean()` results already contain `_id`, so avoid specifying it twice.
        const { _id, ...rest } = product;
        return {
          _id: _id?.toString?.() ?? _id,
          ...rest
        };
      }),
      pagination: {
        total,
        page,
        limit,
        pages: Math.ceil(total / limit)
      }
    });
  } catch (error) {
    const errorMessage = error instanceof Error ? error.message : String(error);
    console.error('Error fetching products:', errorMessage);
    console.error('Stack trace:', error instanceof Error ? error.stack : 'N/A');
    return NextResponse.json(
      { error: `Failed to fetch products: ${errorMessage}` },
      { status: 500 }
    );
  }
}

export async function POST(request: NextRequest) {
  try {
    const auth = await requireAuth(request);
    if (auth.role !== 'admin') {
      return NextResponse.json(
        { error: 'Unauthorized' },
        { status: 403 }
      );
    }

    await dbConnect();

    const body = await request.json();
    const product = await Product.create(body);

    return NextResponse.json(product, { status: 201 });
  } catch (error: any) {
    console.error('Error creating product:', error);
    return NextResponse.json(
      { error: error.message || 'Internal Server Error' },
      { status: error.message === 'Authentication required' ? 401 : 500 }
    );
  }
}
