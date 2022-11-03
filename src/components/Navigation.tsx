"use client";

import type { MainNavigation } from "@utils/get-config";
import Link from "next/link";
import { Button, Dropdown, Menu, Navbar } from "react-daisyui";

export interface NavigationProps extends MainNavigation {
  locale: string;
}

export const Navigation = ({ logo, links }: NavigationProps) => {
  return (
    <Navbar>
      <Navbar.Start>
        <Dropdown>
          <Button color="ghost" tabIndex={0} className="lg:hidden">
            <svg
              xmlns="http://www.w3.org/2000/svg"
              className="h-5 w-5"
              fill="none"
              viewBox="0 0 24 24"
              stroke="currentColor"
            >
              <path
                strokeLinecap="round"
                strokeLinejoin="round"
                strokeWidth={2}
                d="M4 6h16M4 12h8m-8 6h16"
              />
            </svg>
          </Button>
          <Dropdown.Menu tabIndex={0} className="menu-compact mt-3 w-52">
            {links.map((link, key) => (
              <Dropdown.Item href={link.link.url || "/"} key={key}>
                {link.label}
              </Dropdown.Item>
            ))}
          </Dropdown.Menu>
        </Dropdown>

        <Link href="/">
          {/* eslint-disable-next-line @next/next/no-img-element */}
          <img className="h-12" src={logo.filename} alt={logo.alt} />
        </Link>
      </Navbar.Start>
      <Navbar.End className="hidden lg:flex">
        <Menu horizontal className="p-0">
          {links.map((link, key) => (
            <Menu.Item key={key}>
              <Link href={link.link.url || "/"}>{link.label}</Link>
            </Menu.Item>
          ))}
        </Menu>
      </Navbar.End>
    </Navbar>
  );
};
