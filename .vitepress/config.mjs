import { defineConfig } from 'vitepress'

// DevOps Studio documentation site.
// Source markdown lives across the repo root: index.md (home), labs/*/README.md,
// docs/*.md, and docs/architecture-decisions/*.md. README.md is treated as the
// directory index, so links like ./labs/01-terraform-foundations/ resolve.
//
// Dead-link detection is left ON (the default): `npm run docs:build` fails if any
// internal markdown link is broken. That is our link-check CI.
export default defineConfig({
  title: 'DevOps Studio',
  description: 'Implementation patterns for bridging customer architecture into production-ready systems.',
  lang: 'en-US',

  // GitHub Pages project site is served from /devops-studio/.
  base: '/devops-studio/',

  cleanUrls: true,
  lastUpdated: true,

  srcExclude: ['**/node_modules/**'],

  // VitePress doesn't auto-map README.md -> index in this version, so directory
  // links like ./labs/01-terraform-foundations/ would 404. Rewrite each section's
  // README.md to that directory's index page so those links resolve.
  rewrites: {
    'labs/README.md': 'labs/index.md',
    'labs/:lab/README.md': 'labs/:lab/index.md',
    'docs/README.md': 'docs/index.md'
  },

  // LICENSE is not a markdown page, but MIT license badges across every README
  // link to it. Ignore only that target; every other internal link is still checked.
  ignoreDeadLinks: [/\/LICENSE$/],

  themeConfig: {
    nav: [
      { text: 'Home', link: '/' },
      { text: 'Labs', link: '/labs/' },
      {
        text: 'Guides',
        items: [
          { text: 'Getting Started', link: '/docs/getting-started' },
          { text: 'Prerequisites', link: '/docs/prerequisites' },
          { text: 'Learning Paths', link: '/docs/learning-paths' },
          { text: 'Cost Management', link: '/docs/cost-management' },
          { text: 'Troubleshooting', link: '/docs/troubleshooting' }
        ]
      },
      { text: 'Decisions', link: '/docs/architecture-decisions/001-terraform-structure' },
      {
        text: 'The Series',
        items: [
          { text: 'Solutions Playbook', link: 'https://wbhankins93.github.io/solutions-playbook/' },
          { text: 'AI Engineering Studio', link: 'https://wbhankins93.github.io/ai-engineering-studio/' },
          { text: 'DevOps Studio', link: 'https://wbhankins93.github.io/devops-studio/' },
          { text: 'Implementation Studio', link: 'https://wbhankins93.github.io/implementation-studio/' }
        ]
      }
    ],

    sidebar: {
      '/labs/': [
        {
          text: 'Labs',
          items: [
            { text: 'Overview', link: '/labs/' },
            { text: '01 · Terraform Foundations', link: '/labs/01-terraform-foundations/' },
            { text: '02 · Kubernetes Platform', link: '/labs/02-kubernetes-platform/' },
            { text: '03 · CI/CD Pipelines', link: '/labs/03-cicd-pipelines/' },
            { text: '04 · Observability Stack', link: '/labs/04-observability-stack/' },
            { text: '05 · Security Automation', link: '/labs/05-security-automation/' },
            { text: '06 · GitOps Workflows', link: '/labs/06-gitops-workflows/' },
            { text: '07 · Serverless Operations', link: '/labs/07-serverless-operations/' },
            { text: '08 · Platform Engineering', link: '/labs/08-platform-engineering/' }
          ]
        }
      ],
      '/docs/': [
        {
          text: 'Guides',
          items: [
            { text: 'Getting Started', link: '/docs/getting-started' },
            { text: 'Prerequisites', link: '/docs/prerequisites' },
            { text: 'Learning Paths', link: '/docs/learning-paths' },
            { text: 'Cost Management', link: '/docs/cost-management' },
            { text: 'Makefile Guide', link: '/docs/makefile-guide' },
            { text: 'Observability Tools', link: '/docs/observability-tools-explained' },
            { text: 'Troubleshooting', link: '/docs/troubleshooting' }
          ]
        },
        {
          text: 'Architecture Decisions',
          items: [
            { text: '001 · Terraform Structure', link: '/docs/architecture-decisions/001-terraform-structure' },
            { text: '002 · Kubernetes Platform', link: '/docs/architecture-decisions/002-kubernetes-platform' },
            { text: '003 · Monitoring Strategy', link: '/docs/architecture-decisions/003-monitoring-strategy' }
          ]
        }
      ]
    },

    search: { provider: 'local' },

    socialLinks: [
      { icon: 'github', link: 'https://github.com/WBHankins93/devops-studio' }
    ],

    editLink: {
      pattern: 'https://github.com/WBHankins93/devops-studio/edit/main/:path',
      text: 'Edit this page on GitHub'
    },

    footer: {
      message: 'Released under the MIT License.',
      copyright: 'DevOps Studio - architecture decisions, implementation patterns, and operational readiness.'
    }
  }
})
