/* eslint-disable @typescript-eslint/no-explicit-any */
import { StoryblokComponent, storyblokEditable } from "@storyblok/react";

const Page = ({ blok }: { blok: any }) => (
  <main {...storyblokEditable(blok)}>
    {blok.content.map((nestedBlok: any) => (
      <StoryblokComponent blok={nestedBlok} key={nestedBlok._uid} />
    ))}
  </main>
);

export default Page;
