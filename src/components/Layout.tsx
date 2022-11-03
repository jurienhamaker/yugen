"use client";

import { Footer } from "@components/Footer";
import type { Config, MainNavigation } from "@utils/get-config";
import { Theme } from "react-daisyui";
import { Navigation } from "./Navigation";

export interface LayoutProps {
  locale: string;
  // eslint-disable-next-line @typescript-eslint/no-explicit-any
  children: any;
  config: Config;
  mainNavigation: MainNavigation;
}

export const Layout = ({
  children,
  locale,
  mainNavigation,
  config,
}: LayoutProps) => {
  return (
    <Theme dataTheme={config.theme} className="flex h-screen w-full flex-col">
      <Navigation
        links={mainNavigation.links}
        locale={locale}
        logo={mainNavigation.logo}
      />
      {children}

      <Footer locale={locale} footerNavigation={{}} />
    </Theme>
  );
};
