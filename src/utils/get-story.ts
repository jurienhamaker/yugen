import { getStoryblokApi } from "@storyblok/react";

export const getStory = async (slug: string, preview = false) => {
  // load the draft version
  const sbParams = {
    version:
      process.env.NODE_ENV === "development" || preview ? "draft" : "published",
  };

  const storyblokApi = getStoryblokApi();
  const { data } = await storyblokApi.get(`cdn/stories/${slug}`, sbParams);

  return {
    story: data ? data.story : false,
    key: data ? data.story.id : false,
  };
};
