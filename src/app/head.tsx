import { getConfig } from "@utils/get-config";
import { getStory } from "@utils/get-story";

export default async function Head() {
  const {
    story: {
      content: { meta_tags: meta },
    },
  } = await getStory("home");
  const { config } = await getConfig();

  return (
    <>
      <title>
        {config.title_position === "prefix"
          ? `${config.title} | ${meta.title}`
          : `${meta.title} | ${config.title}`}
      </title>
    </>
  );
}
