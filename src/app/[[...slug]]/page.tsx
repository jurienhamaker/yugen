import { Page } from "@components/Page";

export default function SlugPage({
  params: { slug },
  searchParams: { secret, slug: previewSlug },
}: {
  params: { slug: string };
  searchParams: { secret: string; slug: string };
}) {
  const preview = secret === "YUUUGEN";
  let fetchSlug = preview ? previewSlug : slug;
  fetchSlug = fetchSlug?.length ? fetchSlug : "home";

  const locale = "en";
  return <Page locale={locale} slug={fetchSlug} preview={preview}></Page>;
}
