<script lang="ts">
  import { page } from '$app/state';
  import {
    DEFAULT_OG_IMAGE,
    DEFAULT_ROBOTS,
    ORGANIZATION_SCHEMA,
    WEBSITE_SCHEMA,
    absoluteUrl,
    buildWebPageSchema,
    normalizePath,
    SITE_NAME
  } from '$lib/site';

  type Schema = Record<string, unknown>;

  let {
    title,
    description,
    type = 'website',
    image = DEFAULT_OG_IMAGE,
    canonicalPath = undefined,
    noindex = false,
    structuredData = [],
    publishedTime = undefined,
    modifiedTime = undefined
  }: {
    title: string;
    description: string;
    type?: 'website' | 'article';
    image?: string;
    canonicalPath?: string;
    noindex?: boolean;
    structuredData?: Schema | Schema[];
    publishedTime?: string;
    modifiedTime?: string;
  } = $props();

  const pathname = $derived(page.url.pathname);
  const resolvedPath = $derived(normalizePath(canonicalPath ?? pathname));
  const canonicalUrl = $derived(absoluteUrl(resolvedPath));
  const imageUrl = $derived(image.startsWith('http') ? image : absoluteUrl(image));
  const robots = $derived(
    noindex ? DEFAULT_ROBOTS.replace('index,follow', 'noindex,follow') : DEFAULT_ROBOTS
  );
  const pageSchema = $derived(
    noindex ? null : buildWebPageSchema({ title, description, path: resolvedPath, image })
  );
  const extraSchemas = $derived(
    Array.isArray(structuredData) ? structuredData : structuredData ? [structuredData] : []
  );
</script>

<svelte:head>
  <title>{title}</title>
  <meta name="description" content={description} />
  <meta name="robots" content={robots} />
  <link rel="canonical" href={canonicalUrl} />

  <meta property="og:site_name" content={SITE_NAME} />
  <meta property="og:type" content={type} />
  <meta property="og:title" content={title} />
  <meta property="og:description" content={description} />
  <meta property="og:url" content={canonicalUrl} />
  <meta property="og:image" content={imageUrl} />
  <meta name="twitter:card" content="summary_large_image" />
  <meta name="twitter:title" content={title} />
  <meta name="twitter:description" content={description} />
  <meta name="twitter:image" content={imageUrl} />

  {#if publishedTime}
    <meta property="article:published_time" content={publishedTime} />
  {/if}

  {#if modifiedTime}
    <meta property="article:modified_time" content={modifiedTime} />
  {/if}

  {#each [ORGANIZATION_SCHEMA, WEBSITE_SCHEMA, ...(pageSchema ? [pageSchema] : []), ...extraSchemas] as schema}
    <script type="application/ld+json">{JSON.stringify(schema)}</script>
  {/each}
</svelte:head>
