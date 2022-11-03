"use client";

import Link from "next/link";
import { Button, Hero as DHero } from "react-daisyui";
import { render } from "storyblok-rich-text-react-renderer";

export interface HeroProps {
  blok: {
    title: string;
    description: string;
    enable_button: boolean;
    button_text?: string;
    button_link?: {
      url: string;
    };
  };
}

export const Hero = ({
  blok: { title, description, enable_button, button_text, button_link },
}: HeroProps) => {
  return (
    <DHero>
      <DHero.Overlay className="bg-opacity-60" />
      <DHero.Content className="flex justify-center text-center">
        <div className="max-w-md">
          <h1 className="text-5xl font-bold">{title}</h1>

          <div className="py-6">{render(description)}</div>

          {enable_button && button_link?.url.length && (
            <Link href={button_link?.url}>
              <Button color="secondary">{button_text}</Button>
            </Link>
          )}
        </div>
      </DHero.Content>
    </DHero>
  );
};
