/** @type {import('next').NextConfig} */
const nextConfig = {
  // Essential for Docker optimized builds
  output: 'standalone',
  
  // Improves production performance by minifying JavaScript with SWC
  swcMinify: true,

  // Recommended: Prevents large image optimization issues in containers
  images: {
    unoptimized: false,
    remotePatterns: [
      {
        protocol: 'https',
        hostname: '**', // Adjust this to your specific image CDN for better security
      },
    ],
  },

  // Ensure environment variables are handled correctly
  env: {
    NEXTAUTH_URL: process.env.NEXTAUTH_URL,
  },
};

module.exports = nextConfig;