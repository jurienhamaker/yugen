import { getStoryblokApi } from "@storyblok/react";
import type { THEME_CLASS } from "./consts";

export interface Config {
  title: string;
  title_position: "prefix" | "suffix";
  theme: THEME_CLASS;
}

export interface MainNavigation {
  links: [
    {
      link: {
        url: string;
      };
      label: string;
    }
  ];
  logo: {
    filename: string;
    alt: string;
    dimensions: {
      width: number;
      height: number;
    };
  };
}

export const getConfig = async (): Promise<{
  config: Config;
  mainNavigation: MainNavigation;
}> => {
  const params = {
    version: process.env.NODE_ENV === "production" ? "published" : "draft", // or 'published'
  };

  const storyblokApi = getStoryblokApi();

  const {
    data: {
      story: { content: mainNavigation },
    },
  } = await storyblokApi.get(
    `cdn/stories/configuration/main-navigation`,
    params
  );
  const {
    data: {
      story: { content: config },
    },
  } = await storyblokApi.get(`cdn/stories/configuration/config`, params);

  return {
    mainNavigation,
    config,
  };
};
