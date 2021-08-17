/** @type {import('@docusaurus/types').DocusaurusConfig} */
module.exports = {
  title: "Axelar Testnet Docs",
  // to be replaced with the site deployed
  url: "https://axelar.network/",
  baseUrl: "/",
  onBrokenLinks: "throw",
  onBrokenMarkdownLinks: "warn",
  favicon: "img/favicon.ico",
  organizationName: "Axelar",
  projectName: "docs-1",
  themeConfig: {
    // announcementBar: {
    //   id: "community_edition",
    //   content:
    //     'Sign up for our&nbsp;<a target="_blank" rel="noopener noreferrer" href="https://axelar.network/">Link Title</a>&nbsp;to test newest features!',
    //   backgroundColor: "#ffb800",
    //   textColor: "#060d0e",
    //   isCloseable: true,
    // },
    colorMode: {
      defaultMode: "dark",
      respectPrefersColorScheme: true,
      switchConfig: {
        darkIcon: "  ",
        darkIconStyle: {
          marginTop: "1px",
        },
        lightIcon: "  ",
        lightIconStyle: {
          marginTop: "1px",
        },
      },
    },
    navbar: {
      title: "Axelar Network Testnet Docs",
      logo: {
        alt: "Axelar Network",
        src: "img/favicon.ico",
      },
      items: [
        {
          to: "/setup",
          activeBasePath: "/setup",
          position: "left",
          label: "Setup",
        },
        {
          to: "/testnet-releases",
          activeBasePath: "/testnet-releases",
          position: "left",
          label: "Testnet Release",
        },
        {
          href: "https://github.com/axelarnetwork",
          className: "github",
          position: "right",
        },
        {
          href: "https://twitter.com/axelarcore",
          className: "twitter",
          position: "right",
        },
        {
          href: "https://discord.gg/aRZ3Ra6f7D",
          className: "discord",
          position: "right",
        },
        {
          type: "search",
          position: "right",
        },
      ],
    },
    prism: {
      theme: require("./src/future"),
    },
    footer: {
      style: "dark",
      links: [
        {
          title: "About",
          items: [
            {
              label: "Axelar Network",
              to: "https://axelar.network/",
            },
            {
              label: "Community Forum",
              to: "https://community.axelar.network/",
            },
            {
              label: " Testnet Form Submission Portal",
              to: "https://axelar.knack.com/testnet-portal",
            },
          ],
        },
        {
          title: "Docs",
          items: [
            {
              label: "Setup",
              to: "/setup",
            },
            {
              label: "Testnet Release Versions",
              to: "/testnet-releases",
            },
            {
              label: "FAQs",
              to: "/problem/p1",
            },
          ],
        },
        {
          title: "Community",
          items: [
            {
              label: "GitHub",
              href: "https://github.com/axelarnetwork",
            },
            {
              label: "Discord",
              href: "https://discord.gg/aRZ3Ra6f7D",
            },
            {
              label: "Twitter",
              href: "https://twitter.com/axelarcore",
            },
            {
              label: "Telegram",
              href: "https://t.me/axelarcommunity",
            }
          ],
        },
      ],
      // copyright: `Copyright © ${new Date().getFullYear()} ******* is developed by ******`,
    },
  },
  plugins: [require.resolve("docusaurus-lunr-search")],
  presets: [
    [
      "@docusaurus/preset-classic",
      {
        docs: {
          sidebarPath: require.resolve("./sidebars.js"),
          routeBasePath: "/",
          // editUrl: "https://github.com/repo-name/docs/edit/master/",
        },
        theme: {
          customCss: require.resolve("./src/css/custom.css"),
        },
      },
    ],
  ],
};
