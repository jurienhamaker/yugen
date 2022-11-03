import { StoryblokComponent } from "@storyblok/react";
import { asyncComponent } from "@utils/async-component";
import { getConfig } from "@utils/get-config";
import { getStory } from "@utils/get-story";
import { Layout } from "./Layout";

export interface PageProps {
  slug: string;
  locale: string;
  preview: boolean;
}

export const Page = asyncComponent(
  async ({ slug, locale, preview }: PageProps) => {
    const { story } = await getStory(slug, preview);
    const { mainNavigation, config } = await getConfig();

    return (
      <>
        <Layout locale={locale} mainNavigation={mainNavigation} config={config}>
          <StoryblokComponent blok={story.content} />
        </Layout>
      </>
    );
  }
);
