"use client";

import { Footer as DFooter } from "react-daisyui";

export interface FooterProps {
  locale: string;
  footerNavigation: {
    links?: {
      url: string;
    }[];
  };
}

export const Footer = ({ footerNavigation, locale }: FooterProps) => {
  return (
    <DFooter className="mt-auto bg-neutral p-10 text-neutral-content">
      <div>
        <DFooter.Title>Services</DFooter.Title>
        <a className="link-hover link">Branding</a>
        <a className="link-hover link">Design</a>
        <a className="link-hover link">Marketing</a>
        <a className="link-hover link">Advertisement</a>
      </div>
      <div>
        <DFooter.Title>Company</DFooter.Title>
        <a className="link-hover link">About us</a>
        <a className="link-hover link">Contact</a>
        <a className="link-hover link">Jobs</a>
        <a className="link-hover link">Press kit</a>
      </div>
      <div>
        <DFooter.Title>Legal</DFooter.Title>
        <a className="link-hover link">Terms of use</a>
        <a className="link-hover link">Privacy policy</a>
        <a className="link-hover link">Cookie policy</a>
      </div>
    </DFooter>
  );
};
