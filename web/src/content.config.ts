import { defineCollection, z } from 'astro:content';
import { glob } from 'astro/loaders';

const blogSchema = z.object({
  title: z.string(),
  description: z.string(),
  pubDate: z.coerce.date(),
  updatedDate: z.coerce.date().optional(),
  heroImage: z.string().optional(),
});

const blog = defineCollection({
  loader: glob({ pattern: '**/*.{md,mdx}', base: './src/content/blog' }),
  schema: blogSchema,
});

const blogJa = defineCollection({
  loader: glob({ pattern: '**/*.{md,mdx}', base: './src/content/blog-ja' }),
  schema: blogSchema,
});

export const collections = { blog, 'blog-ja': blogJa };
